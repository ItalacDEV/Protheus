/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 14/11/2019 | Corrigida transfer�ncia de empr�stimos. Chamado 31192
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/02/2020 | Corrigida efetiva��o de empr�stimos. Chamado 31974
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 29/12/2020 | Retirada fun��o UCFG001. Chamado 35123
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch' 
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: AGLT016
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para lan�amentos dos empr�stimos de terceiros, c�pia do AGLT012 - Chamado 11132
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT016

Local _oBrowse := Nil

Private	_cNUseAp	:= Substr(UsrFullName(RetCodUsr()),1,GetSX3Cache("ZLN_NUSEAP","X3_TAMANHO"))
Private _cMatUsr	:= FWSFAllUsers({RetCodUsr()},{"USR_FILIAL","USR_CODFUNC"})[1][3]+FWSFAllUsers({RetCodUsr()},{"USR_FILIAL","USR_CODFUNC"})[1][4]
Private	_cTipo01	:= SuperGetMV("LT_3EMPTP1",.F.,"NDF")
Private	_cTipo02	:= SuperGetMV("LT_3EMPTP2",.F.,"NF")
Private	_cNaturez	:= SuperGetMV("LT_3EMPNAT",.F.,"222009")
Private _cPrefixo	:= ""

If dDataBase <> LastDate(dDataBase)
	MsgStop("Opera��es permitidas somente com ultimo dia do m�s!",'AGLT01601')
	Return()
EndIf

//====================================================================================================
// Configura e inicializa a Classe do Browse
//====================================================================================================
_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( 'ZLN' )
_oBrowse:SetMenuDef( 'AGLT016' )
_oBrowse:SetDescription( 'Administra��o do Leite - Empr�stimos Terceiros' )

_oBrowse:AddLegend( "ZLN_STATUS == '2'" , 'GREEN'	, 'Aprovada'		)
_oBrowse:AddLegend( "ZLN_STATUS == '3'" , 'RED'		, 'Reprovada'		)
_oBrowse:AddLegend( "ZLN_STATUS == '4'" , 'BLUE'	, 'Efetivado'		)
_oBrowse:AddLegend( "ZLN_STATUS == '1'" , 'WHITE'	, 'Em Aberto'		)
_oBrowse:AddLegend( "ZLN_STATUS == '5'" , 'BLACK'	, 'Transferido'		)
_oBrowse:AddLegend( "ZLN_STATUS == '6'" , 'GRAY'	, 'Transfer�ncia'	)

_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para cria��o do menu da tela principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title 'Visualizar'		   		Action 'VIEWDEF.AGLT016'			OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'   		   		Action 'VIEWDEF.AGLT016'			OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'   		   		Action 'VIEWDEF.AGLT016'			OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'	   	   	  		Action 'VIEWDEF.AGLT016'			OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Avaliar'   		   		Action 'U_AGLT016A()'				OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Avalia��o M�ltipla'		Action 'U_AGLT016T(1)'				OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Efetivacao Multipla'		Action 'U_AGLT016T(2)'				OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Estorna'					Action 'U_AGLT016E()'				OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Transferencia'			Action 'U_AGLT016B()'				OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Estorno Transf.'			Action 'U_AGLT016C()'				OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Recibo Pagamento'		Action 'U_RGLT049()'				OPERATION 8 ACCESS 0
ADD OPTION _aRotina Title 'Declara��o'				Action 'U_RGLT052()'				OPERATION 8 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para montagem do modelo de dados para o processamento
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oStruZLN	:= FWFormStruct( 1 , 'ZLN' )
Local _oStruZLQ	:= FWFormStruct( 1 , 'ZLQ' )
Local _oModel	:= MpFormModel():New( "AGLT016M" ,, {|_oModel| VALIDCOMIT(_oModel) } )
Local _aGatAux	:= {}

//====================================================================================================
// Monta a estrutura de gatilhos
//====================================================================================================
_aGatAux := FwStruTrigger( 'ZLN_SA2COD' , 'ZLN_SA2LJ' , 'SA2->A2_LOJA' , .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLN_SA2COD+IF(SA2->A2_COD==M->ZLN_SA2COD,SA2->A2_LOJA,"")' )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLN_SA2COD' , 'ZLN_SA2NOM' , 'SA2->A2_NOME' , .T. , 'SA2' , 1 , 'xFilial("SA2")+M->(ZLN_SA2COD)' )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLN_SA2LJ' , 'ZLN_SA2NOM' , 'SA2->A2_NOME' , .T. , 'SA2' , 1 , 'xFilial("SA2")+M->(ZLN_SA2COD+ZLN_SA2LJ)' )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLN_TOTAL'	, 'ZLN_PAGTO' , 'U_AGLT016JUR()' , .F. )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLN_JUROS'	, 'ZLN_PAGTO' , 'U_AGLT016JUR()' , .F. )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLN_PARC'	, 'ZLN_PAGTO' , 'U_AGLT016JUR()' , .F. )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLN_VENCTO'	, 'ZLN_PAGTO' , 'U_AGLT016JUR()' , .F. )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLN_TOTAL'	, 'ZLN_DATA'  , 'dDataBase' , .F. )
_oStruZLN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel:AddFields(	'ZLNMASTER'	,				, _oStruZLN )
_oModel:AddGrid(	'ZLQDETAIL'	, 'ZLNMASTER'	, _oStruZLQ )

_oModel:SetRelation( 'ZLQDETAIL', { { 'ZLQ_FILIAL' , 'xFilial( "ZLQ" )' } , { 'ZLQ_COD' , 'ZLN_COD' } } , ZLQ->( IndexKey(1) ) )

_oModel:SetDescription( 'Administra��o do Leite - Solicita��o de Empr�stimos' )

_oModel:GetModel( 'ZLNMASTER' ):SetDescription( 'Dados do Produtor'		)
_oModel:GetModel( 'ZLQDETAIL' ):SetDescription( 'Dados do Empr�stimo'	)

_oModel:GetModel( 'ZLQDETAIL' ):SetUniqueLine( { 'ZLQ_ITEM' } )
_oModel:GetModel( 'ZLQDETAIL' ):SetOptional( .T. )

_oModel:SetPrimaryKey( { 'ZLN_FILIAL' , 'ZLN_COD' } )

_oModel:SetVldActivate( {|_oModel| AGLT016L(_oModel) } )

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para montar a View de Dados para exibi��o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()

Local _oModel	:= FWLoadModel( 'AGLT016' )
Local _oStruZLN	:= FWFormStruct( 2 , 'ZLN' )
Local _oStruZLQ	:= FWFormStruct( 2 , 'ZLQ' )
Local _oView	:= FWFormView():New()

_oStruZLQ:RemoveField( "ZLQ_FILIAL"	)
_oStruZLQ:RemoveField( "ZLQ_COD"	)

_oView:SetModel( _oModel )

_oView:AddField(	'VIEW_CAB' , _oStruZLN	, 'ZLNMASTER' )
_oView:AddGrid(		'VIEW_DET' , _oStruZLQ	, 'ZLQDETAIL' )

_oView:CreateHorizontalBox( 'SUPERIOR'	, 60 )
_oView:CreateHorizontalBox( 'INFERIOR'	, 40 )

_oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR'	)
_oView:SetOwnerView( 'VIEW_DET'	, 'INFERIOR'	)

_oView:EnableTitleView( 'VIEW_DET' , 'InForma��es dos Vencimentos:' )

_oView:AddIncrementField( 'VIEW_DET' , 'ZLQ_ITEM' )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT016L
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para processamento da valida��o inicial das opera��es
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016L( _oModel )

Local _nOper		:= _oModel:GetOperation()
Local _lRet			:= .T.
Local _aArea		:= GetArea()

If _nOper == MODEL_OPERATION_DELETE .Or. _nOper == MODEL_OPERATION_UPDATE
	If ZLN->ZLN_STATUS <> '1'
		Help(NIL, NIL, "AGLT01602", NIL, "N�o � poss�vel alterar um registro que n�o esteja com status: 'Em Aberto'!", 1, 0, NIL, NIL, NIL, NIL, NIL, ;
		{"Verique o Status da solicitacao! Uma vez aprovada ou efetivada n�o poder� mais sofrer altera��es."})
		_lRet := .F.
	EndIf
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: VALIDCOMIT
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para processamento da valida��o final das opera��es ao confirmar o modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VALIDCOMIT( _oModel )

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cCODSA2	:= ''
Local _cLOJSA2	:= ''
Local _dDtVenc	:= _oModel:GetValue( 'ZLNMASTER' , 'ZLN_VENCTO' )
Local _dDtCred	:= _oModel:GetValue( 'ZLNMASTER' , 'ZLN_DTCRED' )
Local _nOper	:= _oModel:GetOperation()

If dDataBase <> LastDate(dDataBase)
	Help(NIL, NIL, "AGLT01603", NIL, "Opera��es permitidas somente com ultimo dia do m�s!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verique as datas informadas!"})
	_lRet := .F.
EndIf

If _lRet .And. _dDtCred < dDataBase
	Help(NIL, NIL, "AGLT01604", NIL, "N�o � permitido informar uma data de Cr�dito menor que a data atual!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verique as datas informadas!"})
	_lRet := .F.
EndIf

If _lRet .And. _dDtVenc < _dDtCred
	Help(NIL, NIL, "AGLT01605", NIL, "N�o � permitido informar uma data de 1� vencimento menor que a data do Cr�dito!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verique as datas informadas!"})
	_lRet := .F.
EndIF

If _lRet .And. _nOper == MODEL_OPERATION_INSERT
	
	_cCODSA2 := _oModel:GetValue( 'ZLNMASTER' , 'ZLN_SA2COD' )
	_cLOJSA2 := _oModel:GetValue( 'ZLNMASTER' , 'ZLN_SA2LJ'  )
	
	If !Empty( _cCODSA2 ) .And. !Empty( _cLOJSA2 )
	
		DBSelectArea('SA2')
		SA2->( DBSetOrder(1) )
		If SA2->( DBSeek( xFilial('SA2') + _cCODSA2 + _cLOJSA2 ) )
			If SA2->A2_MSBLQL == '1'
				MsgStop("Produtor/Fretista informado encontra-se Bloqueado no cadastro de Fornecedores do Sistema! Verifique o Fornecedor selecionado ou o cadastro do mesmo no Sistema!","AGLT01606")
				_lRet := .F.
			Else
				_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_USER'  , _cMatUsr )
				_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_NUSER' , _cNUseAp	)
			EndIf
		Else
			MsgStop("Produtor/Fretista informado n�o foi encontrado no cadastro de Fornecedores do Sistema! Verifique o Fornecedor selecionado ou o cadastro do mesmo no Sistema!","AGLT01607")
			_lRet := .F.
		EndIf
	
	EndIf
	If _oModel:GetValue( 'ZLNMASTER' , 'ZLN_VLRPAR' ) == 0
		MsgStop("O valor da parcela deve ser maior que 0! Verifique os dados informados!","AGLT01608")
		_lRet := .F.
	EndIf
EndIf

RestArea(_aArea)

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT016JUR
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Gatilho que calcula juros e cria os itens com vencimento e valores das presta��es
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT016JUR()

Local _oModel		:= FWModelActive()
Local _oView		:= FWViewActive()
Local _oModZLQ		:= _oModel:GetModel('ZLQDETAIL')

Local _nValTot		:= _oModel:GetValue( 'ZLNMASTER' , 'ZLN_TOTAL' )
Local _nParc		:= _oModel:GetValue( 'ZLNMASTER' , 'ZLN_PARC'  )
Local _nJuros		:= _oModel:GetValue( 'ZLNMASTER' , 'ZLN_JUROS' )
Local _nLenZLQ		:= 0
Local _nValPag		:= 0

Local _nI			:= 0
Local _nRest		:= 0
Local _aVenctos		:= {}
Local _dDtAux		:= StoD('')

Local _nTxJuro		:= 0
Local _nTemp		:= 0
Local _nTemp2		:= 0
Local _nTemp3		:= 0

If ( _nValTot <> 0 ) .And. ( _nParc <> 0 )

	//====================================================================================================
	// Novo Calculo dos juros e valor das parcelas
	//====================================================================================================
	_nValPag := Round( _nValTot , 2 )
	
	//====================================================================================================
	// Calculo do Juro Composto estava fazendo o c�lculo achando o montante total de juros e dividindo 
	// pela qde de parcelas. Foi feito a implementa��o para o c�lculo do PMT seguindo a Formula correta.
	//====================================================================================================
	If _nJuros == 0
		
		_nValPar := Round( _nValPag / _nParc	, 2 )
		
		
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_VLRPAR' , _nValPar )
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_PAGTO'  , _nValPag )
	
	Else
		
		For _nI := 1 To _nParc
			_nValPag *= ( ( _nJuros / 100 ) + 1 )
		Next _nI
		
		_nTxJuro	:= round( ( _nJuros / 100 ) , 3 )
		_nTemp		:= ( 1 + _nTxJuro )
		
		For _nI:=1 To int(_nParc) - 1
        	_nTemp *= ( 1 + _nTxJuro )
        Next _nI
        
        _nTemp2			:= _nTemp - 1
        _nTemp3			:= ( _nTxJuro / _nTemp2 )
        _nValPar		:= Round( _nValPag * _nTemp3	, 2 )
        _nValPag		:= Round( _nValPar * _nParc		, 2 )
        
        _oModel:LoadValue( 'ZLNMASTER' , 'ZLN_VLRPAR' , _nValPar )
        _oModel:LoadValue( 'ZLNMASTER' , 'ZLN_PAGTO'  , _nValPag )
        
	EndIf
	
	//====================================================================================================
	// Preenche os itens                          
	//====================================================================================================
	_aVenctos	:= {}
	_dDtAux		:= _oModel:GetValue( 'ZLNMASTER' , 'ZLN_VENCTO' )
	_nRest		:= _nValPag
	
	For _nI := 1 To _nParc
	
		aAdd( _aVenctos , _dDtAux )
		_dDtAux := MonthSum( _dDtAux , 1 )
	
	Next _nI
	
	_nLenZLQ := _oModZLQ:Length()
	
	For _nI := 1 To _nLenZLQ
	
		_oModZLQ:GoLine( _nI )
		
		If !_oModZLQ:IsDeleted()
			_oModZLQ:DeleteLine()
		EndIf
		
	Next
	
	For _nI := 1 to Len( _aVenctos )
	
		If _nI <= _nLenZLQ
		    
			_oModZLQ:GoLine( _nI )
			
			If _oModZLQ:IsDeleted()
				_oModZLQ:UnDeleteLine()
			EndIf
			
			_oView:Refresh()
			
		Else
		
			_nLenZLQ := _oModZLQ:AddLine()
			_oView:Refresh()
			_oModZLQ:GoLine(_nI)
			
		EndIf
		
		_oModZLQ:LoadValue( 'ZLQ_VECTO' , _aVenctos[_nI] )
		
		If _nI < Len( _aVenctos )
		    
			_oModZLQ:LoadValue( 'ZLQ_VALOR' , Round( _nValPar , 2 ) )
			_nRest := _nRest - Round( _nValPar , 2 )
			
		Else
			
			_oModZLQ:LoadValue('ZLQ_VALOR' , _nRest )
			
		EndIf
		
	Next _nI
	
EndIf

_oModZLQ:GoLine(01)
_oView:Refresh()

Return( _nValPag )

/*
===============================================================================================================================
Programa----------: AGLT016A
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para processamento da Avalia��o de solicita��es (Aprovar/Reprovar)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT016A()

FWExecView( '[ Avalia��o da Solicita��o ]' , 'AGLT016' , 4 ,, {|| .T. } , {|| AGLT016ATU() } , 010 )

Return()

/*
===============================================================================================================================
Programa----------: AGLT016ATU
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para atualizar a solicita��o com os dados da avalia��o (Aprovar/Reprovar)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016ATU()

Local _oModel	:= FWModelActive()
Local _oView	:= FWViewActive()
Local _lRet		:= .T.
Local _aParAux	:= {}
Local _aParRet	:= {}
Local _aOpcoes	:= { 'Aprovar' , 'Reprovar' }

aAdd( _aParAux , { 2 , "Avalia��o do registro:" , "Aprovar" , _aOpcoes , 65 ,, .T. } ) ; aAdd( _aParRet , '1' )
	
If ParamBox( _aParAux , "InFormar o Status da Avalia��o:" , @_aParRet ,,, .F. ,,,,, .F. )

	If Upper( AllTrim( _aParRet[01] ) ) == 'APROVAR'
	
	   	_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_STATUS' , "2" )
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_DTAPRO' , ddatabase)
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_USERAP' , _cMatUsr )
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_NUSEAP' , _cNUseAp )
		
		_oView:Refresh()
	
	Else
		
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_STATUS' , "3" )
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_DTAPRO' , ddatabase)
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_USERAP' , _cMatUsr )
		_oModel:LoadValue( 'ZLNMASTER' , 'ZLN_NUSEAP' , _cNUseAp )
		
		_oView:Refresh()
		
	EndIf
	
Else
	_lRet := .F.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT016T
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina de processamento de Avalia��o/Efetiva��o m�ltipla de solicita��es
===============================================================================================================================
Parametros--------: _cTpAplic : 1= Avalia��o / 2= Efetiva��o
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT016T( _cTpAplic )

Local cLabel	:= ""
Local cVarQ		:= "  "
Local nOpcA		:= 0
Local x			:= 0
Local oDlg		:= Nil
Local oGet01	:= Nil

Private cPerg		:= "AGLT016" 
Private oF3			:= Nil
Private aDados		:= {}
Private oVlrTotal	:= Nil
Private _nVlrTot	:= 0
Private oOk			:= LoadBitmap( GetResources(), "LBOK" )
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )

If !Pergunte(cPerg)
	Return()
EndIf

ZLN->( DbSetOrder(1) )
ZLN->( DbGoTop() )

Processa({|| AGLT016GET( _cTpAplic ) })

If Len( aDados ) == 0

	MsgStop('Nao Foram encontrados registros de solicita��es para o processamento! � preciso que existam solicita��es '	+;
				IIf( _cTpAplic == 1 , '"em aberto"' , '"aprovadas"' )											+;
				' para processar a '+ IIf( _cTpAplic == 1 , '"Avalia��o M�ltipla"' , '"Efetiva��o M�ltipla"' ) +'!.' ,"AGLT01609" )
	Return()
	
EndIf

aSort( aDados ,,, {|x,y| x[3] < y[3] } )

//====================================================================================================
// Montando o listbox
//====================================================================================================
DEFINE MSDIALOG oDlg TITLE "Emprestimos - "+ IIf( _cTpAplic == 1 , "Aprovar" , "Efetivar" ) From 000,000 To 025,095 OF oMainWnd

	@ 005,005 TO 150,365 LABEL cLabel Pixel OF oDlg
	
	@ 010,010 LISTBOX oF3	VAR cVarQ ;
							Fields HEADER "",OemToAnsi("Solicitacao"),OemToAnsi("Nome"),OemToAnsi("Valor Total"),OemToAnsi("Parcelas"),OemToAnsi("Juros"),OemToAnsi("Vlr. Parcela"),OemToAnsi("Data 1o. Vencto"),OemToAnsi("Data Credito"),OemToAnsi("Obs.") ;
							COLSIZES 12,25,25,40,25,25,25,25,25,25,25,25,40 ;
							SIZE 350,135 ;
							ON DBLCLICK ( aDados := AGLT016MRK( oF3:nAt , aDados , oGet01 , 1 , 1 ) , oF3:Refresh() , AGLT016RCL( aDados , 5 ) , oVlrTotal:Refresh() ) ;
							PIXEL OF oDlg
	
	oF3:SetArray( aDados )
	oF3:bLine := {|| {	IIf(	aDados[oF3:nAt][01] , oOk , oNo )										,;
								aDados[oF3:nAt][02]														,;
								aDados[oF3:nAt][08] +'/'+ aDados[oF3:nAt,09] +' - '+ aDados[oF3:nAt,03]	,;
								aDados[oF3:nAt][04]														,;
								aDados[oF3:nAt][05]														,;
								aDados[oF3:nAt][06]														,;
								aDados[oF3:nAt][07]														,;
					DtoC( StoD(	aDados[oF3:nAt][10] ) )													,;
					DtoC( StoD(	aDados[oF3:nAt][11] ) )													,;
								aDados[oF3:nAt][12]														}}
	
	oF3:bHeaderClick := {|| AGLT016MTD() , oF3:Refresh() }
	
	DEFINE SBUTTON FROM 160,010 TYPE 01 ACTION Processa( {|| nOpcA := 1 , AGLT016APR( aDados , _cTpAplic ) , oDlg:End() } )	ENABLE OF oDlg
	DEFINE SBUTTON FROM 160,050 TYPE 02 ACTION ( nOpcA := 0 , oDlg:End() )													ENABLE OF oDlg
	
	@160,090 Button	OemToAnsi( "Visualizar"			) Size 50,11 OF oDlg PIXEL Action {|| ZLN->(DBSeek(xFilial("ZLN")+aDados[oF3:nAt][02])), FWExecView( '[ Avalia��o da Solicita��o ]' , 'AGLT016' , 1 ,, {|| .T. } ,, 010 ) }
	@160,150 Button	OemToAnsi( "Imprimir"			) Size 50,11 OF oDlg PIXEL Action {|| U_RGLT030( aDados ) }
	@160,210 Button	OemToAnsi( "An�lise Financeira"	) Size 50,11 OF oDlg PIXEL Action {|| U_RGLT045( aDados[oF3:nAt][08] , aDados[oF3:nAt][09] ) }
	
	@162,280 SAY	"Valor Total:"															OF oDlg PIXEL
	@160,310 MSGET	oVlrTotal VAR _nVlrTot PICTURE "@E 99,999,999.99" WHEN .F. SIZE 50,10	OF oDlg PIXEL
	
	//====================================================================================================
	// Calcula total dos selecionados
	//====================================================================================================
	AGLT016RCL( aDados , 5 )
	oVlrTotal:Refresh()

ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*
===============================================================================================================================
Programa----------: AGLT016E
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina de processamento do Estorno de processamentos das solicita��es
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function AGLT016E()

Local nParcelas	:= 0
Local _lOk		:= .T.

If ZLN->ZLN_STATUS <> "4" .And. ZLN->ZLN_STATUS <> "2"

	MsgStop("Essa solicitacao nao pode ser Estornada por nao ter sido Efetivada/Aprovada!","AGLT01610")
	Return()
	
EndIf

//====================================================================================================
// Status Efetivado
//====================================================================================================
If ZLN->ZLN_STATUS == '4'
	//====================================================================================================
	// Obtendo Parametos dos EMPRESTIMOS
	//====================================================================================================
	If ZLN->ZLN_TIPO == 'E'
		_cPrefixo:= SuperGetMV("LT_3EMPPRE",.F.,"G3E")
	EndIf
	
	//====================================================================================================
	// Obtendo Parametos dos ADIANTAMENTOS
	//====================================================================================================
	If ZLN->ZLN_TIPO == 'A'
		_cPrefixo := SuperGetMV("LT_3ADTPRE",.F.,"G3A")
	EndIf
	
	//====================================================================================================
	// Obtendo Parametos das ANTECIPACOES  
	//====================================================================================================
	If ZLN->ZLN_TIPO == "N"
		_cPrefixo := SuperGetMV("LT_3ANTPRE",.F.,"G3N")
	EndIf
	
	If !MsgYesNo( "Essa rotina ir� cancelar a efetivacao dessa solicitacao. Deseja continuar?" )
		Return()
	EndIf
	
	Begin Transaction
    	
    	//====================================================================================================
	    // Deleta o T�tulo no Financeiro
	    //====================================================================================================
	   	If AGLT016DE2( _cPrefixo , ZLN->ZLN_COD , padr("1",TamSx3("E2_PARCELA")[1]) , "NF " , ZLN->ZLN_SA2COD , ZLN->ZLN_SA2LJ , _cNaturez )
	   	    
	   		// Deleta as Parcelas
			For nParcelas := 1 To Int( ZLN->ZLN_PARC )
			
		    	If !AGLT016DE2( _cPrefixo , ZLN->ZLN_COD , PadR(AllTrim(Str(nParcelas)) , TamSx3("E2_PARCELA")[1]) , "NDF" , ZLN->ZLN_SA2COD , ZLN->ZLN_SA2LJ , _cNaturez )
		    		_lOk := .F.
		    	EndIf
		    	
			Next nParcelas
	   	
	   	Else
	   	
		   	_lOk := .F.
		   	
	   	EndIf
		
		If _lOk
		
	   		ZLN->( RecLock( 'ZLN' , .F. ) )
		    ZLN->ZLN_STATUS := '2'
		    ZLN->( MsUnLock() )
		    
		Else
		
			MsgStop("Falha ao processar a exclus�o dos T�tulos no Financeiro! InForme a �rea de TI/ERP.","AGLT01611")
		    DisarmTransaction()
		    
		EndIf
	
	End Transaction

//====================================================================================================
// Status Aprovado
//====================================================================================================
ElseIf ZLN->ZLN_STATUS == '2'

	If !MsgYesNo( "Essa rotina ir� cancelar a aprova��o dessa solicitacao. Deseja continuar?" )
		Return()
	EndIf

	ZLN->( RecLock( 'ZLN' , .F. ) )
	
	    ZLN->ZLN_STATUS := '1'
	    ZLN->ZLN_DTAPRO := StoD('')
	    ZLN->ZLN_USERAP	:= ''
	    ZLN->ZLN_NUSEAP	:= ''
	    
    ZLN->( MsUnLock() )

EndIf

Return()

/*
===============================================================================================================================
Programa----------: AGLT016DE2
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina para processar a exclus�o de t�tulos no Financeiro
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function AGLT016DE2( _cPrefixo , _cNum , _cParcela , _cTipo , _cForn , _cLoja , _cNaturez )

Local _aAutoSE2	:= {}
Local _lOk		:= .T.
Local _nModAux	:= nModulo
Local _cModAux	:= cModulo

Private lMsErroAuto := .f.

AAdd( _aAutoSE2 , { "E2_PREFIXO"	, _cPrefixo		, Nil } )
AAdd( _aAutoSE2 , { "E2_NUM"		, _cNum			, nil } )
AAdd( _aAutoSE2 , { "E2_PARCELA"	, _cParcela		, nil } )
AAdd( _aAutoSE2 , { "E2_TIPO"		, _cTipo		, nil } )
AAdd( _aAutoSE2 , { "E2_NATUREZ"	, _cNaturez		, nil } )
AAdd( _aAutoSE2 , { "E2_FORNECE"	, _cForn		, nil } )
AAdd( _aAutoSE2 , { "E2_LOJA"		, _cLoja		, nil } )

nModulo := 6
cModulo := "FIN"

DBSelectArea("SE2")
SE2->( DBSetOrder(1) )
SE2->( DBGoTop() )
If SE2->( DBSeek( xFilial("SE2") + _cPrefixo + _cNum + _cParcela + _cTipo + _cForn + _cLoja ) )

	MSExecAuto( {|x,y,z| Fina050(x,y,z) } , _aAutoSE2 ,, 5 )
	
	If lMsErroAuto
		
		MsgStop("Falha ao processar a exclus�o do T�tulo: ("+ _cPrefixo +"-"+ _cNum +"-"+ _cForn +")! InForme a �rea de TI/ERP.","AGLT01612")
		mostraerro()
		_lOk := .F.
		
	EndIf
	
Else

	MsgStop("T�tulo n�o encontrado: ("+_cPrefixo+_cNum+_cParcela+_cTipo+_cForn+_cLoja+")! InForme a �rea de TI/ERP.","AGLT01613")
	_lOk := .F.
	
EndIf

nModulo := _nModAux
cModulo := _cModAux

Return( _lOk )

/*
===============================================================================================================================
Programa----------: AGLT016GET
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que verIfica e monta a estrutura de dados para o processamento
===============================================================================================================================
Parametros--------: _cTpAplic = 1-Em aberto 2-Aprovada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016GET( _cTpAplic )

Local _nQtdReg	:= 0
Local _cXtipo	:= ''
Local _cAlias	:= GetNextAlias()
Local _nFatura	:= 0

Do Case
	Case MV_PAR05 == 1 // Emprestimo
		_cXtipo := "E"
	Case MV_PAR05 == 2 // Antecipacao
		_cXtipo := "N"
	OtherWise
		_cXtipo := "A"
EndCase

BeginSql alias _cAlias
	SELECT ZLN_COD, ZLN_SA2COD, ZLN_SA2LJ, A2_NOME, ZLN_TOTAL, ZLN_JUROS, ZLN_JUROS, ZLN_VLRPAR, ZLN_VENCTO, ZLN_DTCRED, ZLN_OBS, ZLN_PARC
	FROM %table:ZLN% ZLN, %table:SA2% SA2
	WHERE ZLN.D_E_L_E_T_ = ' '
	AND SA2.D_E_L_E_T_ = ' '
	AND A2_COD = ZLN_SA2COD
	AND A2_LOJA = ZLN_SA2LJ
	AND ZLN_FILIAL = %xFilial:ZLN%
	AND ZLN_STATUS = %exp:cValToChar(_cTpAplic)%
	AND ZLN_DATA   BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
	AND ZLN_COD	BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
	AND ZLN_TIPO = %exp:_cXtipo%
EndSql

Count to _nQtdReg

ProcRegua( _nQtdReg )

(_cAlias)->( DBGoTop() )
While (_cAlias)->( !Eof() )

	IncProc()
	
	aAdd( aDados , {	IIf( ( _nFatura * 0.5 ) > (_cAlias)->ZLN_VLRPAR , .T. , .F. )				   								,; //01
						(_cAlias)->ZLN_COD											   				   								,; //02
						(_cAlias)->A2_NOME											   				   								,; //03
						(_cAlias)->ZLN_TOTAL																						,; //04
						(_cAlias)->ZLN_PARC																							,; //05
						(_cAlias)->ZLN_JUROS																						,; //06
						(_cAlias)->ZLN_VLRPAR																						,; //07
						(_cAlias)->ZLN_SA2COD																						,; //08
						(_cAlias)->ZLN_SA2LJ																						,; //09
						(_cAlias)->ZLN_VENCTO																						,; //10
						(_cAlias)->ZLN_DTCRED																						,; //11
						(_cAlias)->ZLN_OBS																							}) //12
	
	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

Return()

/*
===============================================================================================================================
Programa----------: AGLT016RCL
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que recalcula o totalizador de acordo com os registros selecionados
===============================================================================================================================
Parametros--------: _aLista    - Lista de dados
------------------: _nPosTotal - Posi��o do valor que deve ser totalizado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016RCL( _aLista , _nPosTotal )

Local _nI	:= 0

_nVlrTot := 0

For _nI := 1 To Len( _aLista )

	If _aLista[_nI][01]
		_nVlrTot += _aLista[_nI][_nPosTotal]
	EndIf
	
Next _nI

Return()

/*
===============================================================================================================================
Programa----------: AGLT016APR
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que processa a grava��o das Avalia��es/Efetiva��es
===============================================================================================================================
Parametros--------: _aGrava	- Dados para a grava��o
------------------: _cTipo	- Tipo de Processamento ( 1 - Aprova��o / 2 - Efetiva��o )
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016APR( _aGrava , _cTipo )

Local aTCab		:= {}
Local aTItens	:= {}
Local lOk		:= .T.
Local _lValid	:= .T.
Local _nI		:= 0
Local _dMV_DATAFIN:= GetMV( 'MV_DATAFIN' )

ProcRegua( Len( _aGrava ) )

For _nI := 1 to len(_aGrava)

	IncProc( "Gerando Titulo "+ _aGrava[_nI][02] )
	_lValid := .T.
	
	Begin Transaction
	
	//====================================================================================================
	// Processa os registros selecionados - Aprovar/Efetivar
	//====================================================================================================
	If _aGrava[_nI][01] == .T.
	
		ZLN->( DBSetorder(1) )
		If ZLN->( DBSeek( XFILIAL("ZLN") + _aGrava[_nI][02] ) )
			
			//====================================================================================================
			// Valida a data de libera��o para n�o dar erro no ExecAuto
			//====================================================================================================
			If _cTipo == 2
			
				IF dDataBase < _dMV_DATAFIN
					MsgStop("N�o � poss�vel efetivar a solicita��o ["+ ZLN->ZLN_COD +"]!"+ CRLF			 																		+;
								"A data de Efetiva��o ["+ DtoC( dDataBase ) +"] � anterior � data Limite Cont�bil para lan�amentos Financeiros ["+ DtoC(_dMV_DATAFIN) +"]."	,;
								"AGLT01614")
					_lValid := .F.
				EndIf
				
				If _lValid .And. dDataBase > ZLN->ZLN_VENCTO
					MsgStop("N�o � poss�vel efetivar a solicita��o ["+ ZLN->ZLN_COD +"]!"+ CRLF+;
								"A data de Efetiva��o ["+ DtoC( dDataBase ) +"] � posterior � data do 1� Vencimento configurada ["+ DtoC( ZLN->ZLN_VENCTO ) +"]."	,;
								"AGLT01615")
					_lValid := .F.
				EndIf
				
			EndIf
			
			If _lValid
			
				ZLN->( RecLock( "ZLN" , .F. ) )
				
		          	If _cTipo == 1 // aprovar
	   				
				     	ZLN->ZLN_STATUS := "2"
				     	ZLN->ZLN_DTAPRO := ddatabase
				  		ZLN->ZLN_USERAP := _cMatUsr
	  					ZLN->ZLN_NUSEAP := _cNUseAp
	  					
	  				ElseIf _cTipo == 2 // efetivar
	  					
	  					ZLN->ZLN_DTLIB	:= dDataBase
	  					
	   					aTCab	:= { ZLN->ZLN_COD , ZLN->ZLN_SA2COD , ZLN->ZLN_SA2LJ , ZLN->ZLN_TOTAL , ZLN->ZLN_DTLIB , ZLN->ZLN_TIPO , ZLN->ZLN_DATA , ZLN->ZLN_DTCRED }
	  					aTItens	:= {}
	  					
	  					ZLQ->( DBSetOrder(1) )
	  					ZLQ->( DBSeek( XFILIAL("ZLN") + ZLN->ZLN_COD ) )
	  					While ZLQ->( !Eof() ) .And. XFILIAL("ZLN") + ZLN->ZLN_COD == ZLQ->(ZLQ_FILIAL+ZLQ_COD)
	  					
	  					    aAdd( aTItens , { ZLQ->ZLQ_VECTO , ZLQ->ZLQ_VALOR } )
	  					    
	  					ZLQ->( DBSkip() )
	  					EndDo
						
	  					lOk := .T.
	  					lOk := AGLT016IE2(aTCab,aTItens)
					
	  				EndIf
	  				
				ZLN->( MSUNLOCK() )
			
			EndIf
			
	    EndIf
	
	//====================================================================================================
	// Processa os registros n�o selecionados - Reprovar
	//====================================================================================================
	Else

		ZLN->( DBSetorder(1) )
		If ZLN->( DBSeek( XFILIAL("ZLN") + _aGrava[_nI][02] ) )
		
			ZLN->( RECLOCK( "ZLN" , .F. ) )
			
				ZLN->ZLN_DTAPRO := ddatabase
				ZLN->ZLN_STATUS := "3"
				ZLN->ZLN_USERAP := _cMatUsr
				ZLN->ZLN_NUSEAP := _cNUseAp
				
			ZLN->( MSUNLOCK() )
		
		EndIf	
 		 
	EndIf

	If !lOk
	     DisarmTransaction()
	EndIf
	
	End Transaction
	
Next _nI

Return()

/*
===============================================================================================================================
Programa----------: AGLT016MTD
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que processa a invers�o da sele��o ao clicar no cabe�alho do ListBox
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016MTD()

Local _nI := 0

For _nI := 1 To Len( aDados )

	aDados[_nI][01] := !aDados[_nI][01]

Next _nI

oF3:Refresh()

AGLT016RCL( aDados , 5 )

oVlrTotal:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: AGLT016IE2
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Cria titulos no contas a receber referentes ao emprestimo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016IE2( aCab , aItens )

Local lok1		:= .T.
Local lok2		:= .T.
Local nRest		:= 0
Local _nI		:= 0
Local _nModAux	:= 0
Local _cModAux	:= ''
Local _cAlias	:= GetNextAlias()
Local _DescHist	:= ""

Private _aAutoSE2	:= {}
Private lMsErroAuto	:= .F.

ProcRegua(2)
IncProc()

//====================================================================================================
// Obtendo Parametos dos EMPRESTIMOS
//====================================================================================================
If aCab[6] == 'E'
	_cPrefixo := SuperGetMV("LT_3EMPPRE",.F.,"G3E")
	_DescHist := "EMPRESTIMO"
EndIf

//====================================================================================================
// Obtendo Parametos dos ADIANTAMENTOS
//====================================================================================================
If aCab[6] == "A"
	_cPrefixo := SuperGetMV("LT_3ADTPRE",.F.,"G3A")
	_DescHist := "ADIANTAMENTO"
EndIf

//====================================================================================================
// Obtendo Parametos das ANTECIPACOES  
//====================================================================================================
If aCab[6] == "N"
	_cPrefixo := SuperGetMV("LT_3ANTPRE",.F.,"G3N")
	_DescHist := "ANTECIPACAO"
EndIf

Begin Transaction

BeginSql alias _cAlias
	SELECT COUNT(1) QTD
	FROM %table:SE2%
	WHERE D_E_L_E_T_ = ' '
	AND E2_FILIAL = %xFilial:SE2%
	AND E2_PREFIXO = %exp:_cPrefixo%
	AND E2_NUM = %exp:aCab[1]%
	AND E2_TIPO IN( %exp:_cTipo01% , %exp:_cTipo02%)
	AND E2_FORNECE = %exp:aCab[2]%
	AND E2_LOJA = %exp:aCab[3]%
EndSql
If (_cAlias)->QTD == 0
	For _nI := 1 To Len( aItens )
		
		//====================================================================================================
		// Gravando t�tulo � pagar
		//====================================================================================================
		If _nI < Len( aItens )
			nValor	:= Round( aCab[4] / len(aItens) , 2 )
			nRest	+= nValor
		Else
			nValor	:= aCab[4] - nRest
		EndIf
		
		_aAutoSE2 := {}
		
		AAdd( _aAutoSE2 , { "E2_PREFIXO"	, _cPrefixo			, nil } )		
		AAdd( _aAutoSE2 , { "E2_NUM"		, aCab[1]			, nil } )
		AAdd( _aAutoSE2 , { "E2_PARCELA"	, AllTrim(str(_nI))	, nil } )	
		AAdd( _aAutoSE2 , { "E2_TIPO"		, _cTipo01			, nil } )
		AAdd( _aAutoSE2 , { "E2_NATUREZ"	, _cNaturez			, nil } ) 
		AAdd( _aAutoSE2 , { "E2_FORNECE"	, aCab[2]			, nil } )	
		AAdd( _aAutoSE2 , { "E2_LOJA"		, aCab[3]			, nil } )	
		AAdd( _aAutoSE2 , { "E2_EMISSAO"	, aCab[5]			, nil } )
		AAdd( _aAutoSE2 , { "E2_EMIS1"		, aCab[5]			, nil } )
		AAdd( _aAutoSE2 , { "E2_VENCTO"		, aItens[_nI,1]		, nil } )
		AAdd( _aAutoSE2 , { "E2_VALOR"		, nValor			, nil } )
		AAdd( _aAutoSE2 , { "E2_HIST"		, "GLT "+_DescHist+" TERCEIROS " + AllTrim( STR( _nI ) ) +"/"+ AllTrim( STR( Len( aItens ) ) ) , Nil } )
		AAdd( _aAutoSE2 , { "E2_DATALIB"	, aCab[7]			, nil } )
		AAdd( _aAutoSE2 , { "E2_USUALIB"	, cUserName			, nil } )
		AAdd( _aAutoSE2 , { "E2_ACRESC"		, Round( aItens[_nI][02] - nValor , 2 )			, nil } )
		AAdd( _aAutoSE2 , { "E2_ORIGEM"		, "AGLT016"			, nil } )
				
		lMsErroAuto := .F.
		
		_nModAux	:= nModulo
		_cModAux	:= cModulo
		
		nModulo		:= 6
		cModulo		:= "FIN"
		
		MSExecAuto({|x,y| Fina050(x,y)},_aAutoSE2,3) //Inclusao
		
		If lMsErroAuto
			lok1 := .F.
			MsgStop("Erro ao gravar o Titulo: ("+ _cPrefixo +"-"+ aCab[1] +")! Comunique a �rea de TI/ERP.","AGLT01616")
			mostraerro()
		EndIf
		
		nModulo := _nModAux
		cModulo := _cModAux
		
	Next _nI
		
	//====================================================================================================
	// Gravando t�tulo usado para fazer pagamento ao fornecedor
	//====================================================================================================
	_aAutoSE2 := {}
	
	AAdd( _aAutoSE2 , { "E2_PREFIXO"	, _cPrefixo						, nil } )
	AAdd( _aAutoSE2 , { "E2_NUM"		, aCab[1]						, nil } )
	AAdd( _aAutoSE2 , { "E2_PARCELA"	, "1"							, nil } )
	AAdd( _aAutoSE2 , { "E2_TIPO"		, _cTipo02						, nil } )
	AAdd( _aAutoSE2 , { "E2_NATUREZ"	, _cNaturez						, nil } )
	AAdd( _aAutoSE2 , { "E2_FORNECE"	, aCab[2]						, nil } )
	AAdd( _aAutoSE2 , { "E2_LOJA"		, aCab[3]						, nil } )
	AAdd( _aAutoSE2 , { "E2_EMISSAO"	, aCab[7]						, nil } )
	AAdd( _aAutoSE2 , { "E2_EMIS1"		, aCab[7]						, nil } )
	AAdd( _aAutoSE2 , { "E2_VENCTO"		, aCab[8]						, nil } )
	AAdd( _aAutoSE2 , { "E2_VALOR"		, aCab[4]						, nil } )
	AAdd( _aAutoSE2 , { "E2_HIST"		,"GLT "+_DescHist+" TERCEIROS"	, nil } )
	AAdd( _aAutoSE2 , { "E2_ORIGEM"		,"AGLT016"						, nil } )
	
	lMsErroAuto	:= .F.
	
	_nModAux	:= nModulo
	_cModAux	:= cModulo
	
	nModulo		:= 6
	cModulo		:= "FIN"
	
	MSExecAuto({|x,y| Fina050(x,y)},_aAutoSE2,3) //Inclusao
	
	If lMsErroAuto
	
		lok2 := .F.
		MsgStop("Erro ao gravar o Titulo: ("+ _cPrefixo +"-"+ aCab[1] +")! Comunique a �rea de TI/ERP.","AGLT01617")
 	   	mostraerro()
	EndIf  		
	
	nModulo := _nModAux
	cModulo := _cModAux
Else
	MsgStop("J� foram encontrados t�tulos para esse fornecedor e o processo ser� abortado. Acione a TI/Sistemas.","AGLT01618")
	lok1 := .F.
EndIf
(_cAlias)->(DbCloseArea())

If lok1 .and. lok2
	
	//====================================================================================================
	// Grava solicita��o como efetivada
	//====================================================================================================
	ZLN->( DBSetorder(1) )
	If ZLN->( DBSeek( xFilial('ZLN') + aCab[1] ) )
	
		ZLN->( RecLock( 'ZLN' , .F. ) )
	   	ZLN->ZLN_STATUS := "4"
		ZLN->( MsUnlock() )
	
	Else
			
		MsgStop("Erro ao gravar o Status na Solicita��o: ("+ aCab[1] +")! Comunique a �rea de TI/ERP.","AGLT01619")
		DisarmTransaction()
		lok1:=.F.
	
	EndIf
	
Else
    
	DisarmTransaction()
	
EndIf

End Transaction

Return( lok1 .and. lok2 )

/*
===============================================================================================================================
Programa----------: AGLT016MRK
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que realiza a marca��o dos registros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT016MRK( nIt , aArray , oGet , nOpc , nPos )

Local _nI      := 0
Local lMarca := If( !aArray[nIt][nPos] , .T. , .F. )

If nOpc == 1 // Marca/Desmarca
	aArray[nIt][nPos] := !aArray[nIt][nPos]
Else // Marca Todos/Desmarca Todos
	For _nI := 1 To Len(aArray)
		aArray[_nI,nPos] := lMarca
	Next _nI
EndIf

If oGet != Nil
	oGet:Refresh()
EndIf

Return( aArray )

/*
===============================================================================================================================
Programa----------: AGLT016V
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que realiza datas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT016V()

Local _lRet		:= .T.
Local _cCampo	:= ReadVar()
Local _dDtAux	:= &( _cCampo )

If Upper( AllTrim( _cCampo ) ) == "M->ZLN_DTCRED"
	If _dDtAux < dDataBase
		MsgStop("N�o � permitido informar uma data de cr�dito menor que a data atual! Verique as datas informadas!","AGLT01620")
		_lRet := .F.
	ElseIf !Empty(M->ZLN_VENCTO) .And. _dDtAux > M->ZLN_VENCTO
		MsgStop("N�o � permitido informar uma data de Cr�dito maior que a data de vencimento! Verique as datas informadas!","AGLT01621")
		_lRet := .F.
	EndIf
EndIf

If Upper( AllTrim( _cCampo ) ) == "M->ZLN_VENCTO"
	If _dDtAux < M->ZLN_DTCRED
		MsgStop("N�o � permitido informar uma data de 1� vencimento menor que a data do Cr�dito! Verique as datas informadas!","AGLT01622")	
		_lRet := .F.
	EndIf
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT016B
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que possibilita realizar a transferencia do emprestimo para determinado produtor informado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT016B()

Local oDlg		:= Nil
Local oGDescri	:= Nil
Local oGEmprest	:= Nil
Local oGFornec	:= Nil
Local oGLjForn	:= Nil
Local oMObs		:= Nil
Local oPriVenct	:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oSay3		:= Nil
Local oSay5		:= Nil
Local oSay6		:= Nil
Local oSay7		:= Nil
Local oFont12b	:= Nil
Local nopc		:= 0  
Local _aArea	:= GetArea()       
Local lVldTrans	:= .F.   
Local cGDescri	:= Space(70)
Private cGEmprest	:= Space(09)
Private cGFornec	:= Space(06)
Private cGLjForn	:= Space(04)  
Private cMObs		:= ""    
Private dDtPriVen	:= dDataBase
Private _cCodOrig	:= ""	// Armazena o codigo do fornecedor do emprestimo de origem
Private _cljOrig	:= ""	// Armazena o codigo da loja do fornecedor do emprestimo de origem  
Private _nJuros		:= 0	// Armazena o % de juros para replicar para o emprestimo de destino 
Private _aTitulos	:= {}	// Armazena os t�tulos e suas parcelas com os respectivos valores    
Private lDeuErro	:= .F.	// Controla se deu erro em algum ponto do sistema
Private _cTipo		:= ""
Private _cZLNTipo	:= ""
Define Font oFont12b   Name "Courier New"       Size 0,-12 Bold  // Tamanho 12 Negrito

// Monta tela para configura��o da transfer�ncia
DEFINE MSDIALOG oDlg TITLE "Transfer�ncia de Empr�stimos" FROM 000,000 TO 350,425 COLORS 0,16777215 PIXEL

    @ 039, 012 SAY oSay1     PROMPT "Empr�stimo:"			SIZE 031,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 059, 012 SAY oSay2     PROMPT "Fornecedor:"			SIZE 031,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 059, 120 SAY oSay3     PROMPT "Loja:"       			SIZE 025,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 079, 012 SAY oSay5     PROMPT "Descri��o:"  			SIZE 025,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 099, 012 SAY oSay6     PROMPT "1 Vencto: "  			SIZE 030,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 119, 012 SAY oSay7     PROMPT "Observa��o:"			SIZE 030,007 OF oDlg COLORS 0,16777215 PIXEL
    
    @ 035, 044 MSGET oGEmprest VAR cGEmprest	SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL F3 "ZLN" Valid !Empty(cGEmprest) .And. ExistCPO("ZLN", cGEmprest, 1) 
    @ 055, 044 MSGET oGFornec  VAR cGFornec		SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SA2" Valid !Empty(cGFornec) .And. AGLT016VLF(cGFornec, @cGLjForn, @cGDescri)
    @ 055, 145 MSGET oGLjForn  VAR cGLjForn		SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL Valid !Empty(cGLjForn) .And. AGLT016VLF(cGFornec, @cGLjForn, @cGDescri)
    @ 075, 044 MSGET oGDescri  VAR cGDescri		SIZE 160,010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
    @ 095, 044 MSGET oPriVenct VAR dDtPriVen	SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL Valid !Empty(dDtPriVen)
    @ 115, 044 GET	 oMObs     VAR cMObs		SIZE 160,033 OF oDlg MULTILINE COLORS 0, 16777215 HSCROLL PIXEL Valid !Empty(cMObs)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| MsgRun("Realizando a valida��o da transfer�ncia...",,{||CursorWait(),lVldTrans:=VldTransf(cGEmprest,cGFornec,cGLjForn,cMObs,dDtPriVen),CursorArrow()}),IIf(lVldTrans,Eval({|| nopc:=1,oDlg:End()}),)}, {||oDlg:End()},,)    

// Caso confirmado, processa a transfer�ncia
If nopc == 1
 	MsgRun( "Processando a transfer�ncia..." , 'Aguarde!' , {|| CursorWait() , ProcTransf() , CursorArrow() } )
EndIf

RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: VldTransf
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que valida os dados informados pelo usu�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VldTransf( cCodEmpres , cCodForn , cLjForn , cObs , dt1Vencto)
      
Local _lRet		:= .T.
Local _cAlias	:= GetNextAlias()

If dt1Vencto < dDataBase
	MsgStop("A data do primeiro vencimento n�o pode ser menor que a data atual!","AGLT01623")
	_lRet := .F.
EndIf
			
ZLN->( DBSetOrder(1) )
ZLN->(DBSeek( xFilial("ZLN") + cCodEmpres ))
	_cCodOrig	:= ZLN->ZLN_SA2COD 
	_cljOrig	:= ZLN->ZLN_SA2LJ
	_nJuros		:= ZLN->ZLN_JUROS
	_cZLNTipo	:= ZLN->ZLN_TIPO
	//====================================================================================================
	// Obtendo Parametos dos EMPRESTIMOS
	//====================================================================================================
	If ZLN->ZLN_TIPO == 'E'
		_cPrefixo := SuperGetMV("LT_3EMPPRE",.F.,"G3E")
		_cTipo	:= "Empr�stimo"
	//====================================================================================================
	// Obtendo Parametos dos ADIANTAMENTOS
	//====================================================================================================
	ElseIf ZLN->ZLN_TIPO == 'A'
		_cPrefixo := SuperGetMV("LT_3ADTPRE",.F.,"G3A")
		_cTipo	:= "Adiantamento"
	//====================================================================================================
	// Obtendo Parametos das ANTECIPACOES  
	//====================================================================================================
	ElseIf ZLN->ZLN_TIPO == "N"
		_cPrefixo := SuperGetMV("LT_3ANTPRE",.F.,"G3N")
		_cTipo	:= "Antecipa��o"
	EndIf
//================================================
// Valida se est� efetivado
//================================================
If _lRet .And. !(ZLN->ZLN_STATUS == '4')
	MsgStop("Somente " + _cTipo + " efetivado(a) pode ser transferido(a)!","AGLT01624")
	_lRet := .F.
EndIf	

//======================================================================================
// Verifica se foi informado o mesmo Fornecedor no emprestimo de origem com o de destino
//======================================================================================
If _lRet .And. cCodForn + cLjForn == ZLN->( ZLN_SA2COD + ZLN_SA2LJ )
	MsgStop("N�o � poss�vel transferir um(a) " + _cTipo + "  para o mesmo Fornecedor j� registrado!","AGLT01625")
	_lRet := .F.	
EndIf
	
If _lRet
	//======================================================================================
	// Verifica se o emprestimo gerou baixas, se n�o ter� que ser exclu�do e n�o transferido
	//======================================================================================
	BeginSql Alias _cAlias
	 SELECT COUNT(1) NREG
	   FROM %Table:SE2% SE2
	  WHERE SE2.D_E_L_E_T_ = ' '
	    AND SE2.E2_FILIAL = %xFilial:SE2%
	    AND ((SE2.E2_PREFIXO = %exp:_cPrefixo%
	    	AND SE2.E2_TIPO = %exp:_cTipo01%)
	    	OR (SE2.E2_PREFIXO = %exp:_cPrefixo%
	    	AND SE2.E2_TIPO = %exp:_cTipo02%))
	    AND SE2.E2_NUM = %exp:cCodEmpres%
	    AND SE2.E2_FORNECE = %exp:_cCodOrig%
	    AND SE2.E2_LOJA = %exp:_cljOrig%
	    AND SE2.E2_BAIXA <> ' '
	EndSql
	
	If (_cAlias)->NREG == 0
		MsgStop("N�o � permitido transferir " + _cTipo + "  sem baixas Financeiras! Para esse caso dever� ser exclu�do "+;
				"o(a) " + _cTipo + "  atual e inclu�do um novo manualmente para o fornecedor desejado.","AGLT01626")
		_lRet := .F.
	EndIf
	
	(_cAlias)->( DBCloseArea() )

EndIf
	
Return( _lRet )

/*
===============================================================================================================================
Programa----------: ProcTransf
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que processa a transfer�ncia do empr�stimo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ProcTransf()

Local _cAlias		:= GetNextAlias()
Local _nSaldoTit	:= 0
Local _nY			:= 0

Private nTotSaldo	:= 0
Private _nTotAcDc	:= 0
Private _nCodEmp	:= 0

//========================================================
// Verifica as NDF dos titulos do emprestimo no financeiro
//========================================================
BeginSql Alias _cAlias

SELECT SE2.E2_FILIAL,
       SE2.E2_PREFIXO,
       SE2.E2_TIPO,
       SE2.E2_NUM,
       SE2.E2_PARCELA,
       SE2.E2_FORNECE,
       SE2.E2_LOJA,
       SA2.A2_NOME,
       SE2.E2_TXMOEDA,
       SE2.E2_BAIXA,
       SE2.E2_NATUREZ,
       SE2.E2_VENCREA,
       SE2.E2_SALDO,
       SE2.E2_SDACRES,
       SE2.E2_SDDECRE,
       SE2.E2_VALOR,
       SE2.E2_DECRESC,
       SE2.E2_ACRESC,
       SE2.E2_VALJUR,
       SE2.E2_PORCJUR,
       SE2.E2_EMISSAO,
       SE2.E2_VENCTO,
       SE2.E2_DATALIB,
       SE2.R_E_C_N_O_ RECNOSE2
  FROM %Table:SE2% SE2, %Table:SA2% SA2
 WHERE SE2.D_E_L_E_T_ = ' '
   AND SA2.D_E_L_E_T_ = ' '
   AND SA2.A2_COD = SE2.E2_FORNECE
   AND SA2.A2_LOJA = SE2.E2_LOJA
   AND SE2.E2_FILIAL = %xFilial:SE2%
   AND SE2.E2_PREFIXO = %exp:_cPrefixo%
   AND SE2.E2_TIPO = %exp:_cTipo01%
   AND SE2.E2_NUM = %exp:cGEmprest%
   AND SE2.E2_FORNECE = %exp:_cCodOrig%
   AND SE2.E2_LOJA = %exp:_cljOrig%
 ORDER BY SE2.E2_VENCTO
EndSql

While (_cAlias)->( !Eof() )

	_nSaldoTit := (_cAlias)->(E2_SALDO + E2_SDACRES - E2_SDDECRE)
	
	//================================================================
	// Somente se houver saldo no Titulo corrente para ser considerado
	//================================================================
	If Abs(_nSaldoTit) > 0.0001
		
		nTotSaldo += _nSaldoTit
		_nTotAcDc += (_cAlias)->(E2_SDACRES - E2_SDDECRE)
		
		aAdd( _aTitulos , {	(_cAlias)->E2_PREFIXO																	,; //01 - Prefixo
							(_cAlias)->E2_TIPO																		,; //02 - Tipo
							(_cAlias)->E2_NUM																		,; //03 - Numero do Titulo
							(_cAlias)->E2_PARCELA																	,; //04 - Parcela do Titulo
							(_cAlias)->E2_FORNECE																	,; //05 - C�digo do Fornecedor
							(_cAlias)->E2_LOJA																		,; //06 - Loja do Fornecedor
							(_cAlias)->E2_VENCREA																	,; //07 - Vencimento Real
							(_cAlias)->E2_VENCTO																	,; //08 - Vencimento
							(_cAlias)->E2_SALDO																		,; //09 - Saldo
							(_cAlias)->A2_NOME																		,; //10 - Nome do Fornecedor
							(_cAlias)->E2_EMISSAO																	,; //11 - Data de Emiss�o
							(_cAlias)->E2_DATALIB																	,; //12 - Data de Libera��o
							(_cAlias)->E2_SDACRES																	,; //13 - Acrescimo (no acrescimo uso apenas o saldo)
							(_cAlias)->E2_SDDECRE																	}) //14 - Decrescimo (no decrescimo uso apenas o saldo)
							
	EndIf

	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

//=================================================
// N�o podem ser transferidos empr�stimos sem saldo
//=================================================
If nTotSaldo == 0
	MsgStop("N�o � permitido transferir " + _cTipo + "  que n�o possui mais saldo em aberto!",;
			"Para esse caso dever� ser exclu�do o(a) " + _cTipo + "  atual e inclu�do um novo manualmente para o fornecedor desejado.","AGLT01627")
Else
	
	//===========================================================================================
	// Alteracao na data de vencimento de acordo com o primeiro vencimento fornecido pelo usuario
	//===========================================================================================
	
	For _nY := 1 To Len(_aTitulos)
	
		_aTitulos[_nY][8] := DToS(IIf(_nY==1,dDtPriVen, MonthSum(dDtPriVen,_nY-1)))

	Next _nY
	
	Begin Transaction
	
		//=====================================================
		// Realiza as baixas dos titulos do emprestimo original
		//=====================================================
		For _nY := 1 To Len(_aTitulos)
		    
			MsgRun( "Processando baixas no(a) " + _cTipo + "  de origem..." , 'Aguarde!' , {|| CursorWait() , BaixaSE2(_aTitulos[_nY][9]+_aTitulos[_nY][13]-_aTitulos[_nY][14],_aTitulos[_nY][1],_aTitulos[_nY][3],_aTitulos[_nY][4],_aTitulos[_nY][2],_aTitulos[_nY][5],_aTitulos[_nY][6],_aTitulos[_nY][10]) , CursorArrow() } )
			
			// Verifica se ocorreu erro durante a baixa
			If lDeuErro
				DisarmTransaction()
				Exit
			EndIf
		
		Next _nY
		
		//============================================================================
		//Caso nao ocorra nenhum erro nas baixas realiza a inclusao do novo emprestimo
		//============================================================================
        If !lDeuErro
        
			//===================================================
			// Seleciona o codigo do novo emprestimo a ser gerado
			//===================================================
        	_nCodEmp := GetSx8Num("ZLN","ZLN_COD")
        	
        	//==============================
        	// Insere os dados do emprestimo
        	//==============================
        	MsgRun( "Processando a inclus�o do novo(a) " + _cTipo + " ..." , 'Aguarde!' , {|| CursorWait() , incEmprest() , CursorArrow() } )
        	
			//=============================================================
			// Se nao ocorrer erro abre para visualizacao o novo emprestimo
			//=============================================================
        	If !lDeuErro
        		
				//=============================================
        		// Seta o emprestimo de origem como transferido
				//=============================================
        		ZLN->( DBSetOrder(1) )
        		If ZLN->( DBSeek( xFilial("ZLN") + cGEmprest ) )
        			
        			RecLock( "ZLN" , .F. )
					
					ZLN->ZLN_STATUS := "5"
					ZLN->ZLN_CODTRA := _nCodEmp
					ZLN->ZLN_USRTRA := _cMatUsr
					ZLN->ZLN_DATTRA := Date()
					ZLN->ZLN_HORTRA := Time()
					ZLN->ZLN_OBSTRA := cMObs
					
        			ZLN->( MsUnlock() )
        			
        		EndIf
        		
       			MsgRun( "Processando inclus�es no Financeiro..." , 'Aguarde!' , {|| CursorWait() , IncSE2() , CursorArrow() } )
        		
        		//===========================================================
       			// Se nao ocorrer erro na inclusao das NDF do novo emprestimo
       			//===========================================================
	        	If !lDeuErro
	        		ConfirmSX8()
	        		MsgInfo("A transfer�ncia do(a) " + _cTipo + "  foi realizada com sucesso!","AGLT01628")
	        	Else
	        		RollBackSX8()
	        		DisarmTransaction()
	        	EndIf
		        
		    Else
			    RollBackSX8()
		    	DisarmTransaction()
        	EndIf
        	
        EndIf
	
	End Transaction

EndIf

Return()

/*
===============================================================================================================================
Programa----------: BaixaSE2
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que processa as baixas de T�tulos via ExecAuto
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function BaixaSE2( nVlrBx , cPrefixo , cNroTit , cParcela , cTipo , cFornec , cLjForn , cA2Nome )

Local nModAnt      := nModulo
Local cModAnt      := cModulo
Local cMotBaixa    := GetMv("IT_MOTBXTR")
Local cHist        := "Transferencia " + _cTipo

Private lMsErroAuto:= .F.
Private lMsHelpAuto:= .T.

//==========================================================
// Tratamento para liberar o titulo para baixa no financeiro
//==========================================================
DBSelectArea("SE2")
SE2->( DBSetOrder(1) )
If SE2->( DBSeek( xFILIAL("SE2") + cPrefixo + cNroTit + cParcela + cTipo + cFornec + cLjForn ) )

	If Empty(SE2->E2_DATALIB) //Se nao foi liberado ainda
	
		RecLock("SE2",.F.)
		SE2->E2_DATALIB := dDataBase
		SE2->E2_USUALIB := cUserName
	
	EndIf
	
EndIf

aTitulo := {	{ "E2_PREFIXO"		, cPrefixo							, Nil },;
				{ "E2_NUM"			, cNroTit							, Nil },;
				{ "E2_PARCELA"		, cParcela							, Nil },;
				{ "E2_TIPO"			, cTipo								, Nil },;
				{ "E2_FORNECE"		, cFornec							, Nil },;
				{ "E2_LOJA"			, cLjForn							, Nil },;
				{ "AUTBANCO"		, ""								, Nil },;
				{ "AUTAGENCIA"		, ""								, Nil },;
				{ "AUTCONTA"		, ""								, Nil },;
				{ "AUTCHEQUE"		, ""								, Nil },;
				{ "AUTMOTBX"		, cMotBaixa							, Nil },;
				{ "AUTDTBAIXA"		, dDataBase							, Nil },;
				{ "AUTDTCREDITO"	, dDataBase							, Nil },;
				{ "AUTBENEF"		, cFornec +" - "+ ALLTRIM(cA2Nome)	, Nil },;
				{ "AUTHIST"			, cHist								, Nil },;
				{ "AUTVLRPG"		, nVlrBx							, Nil } }

//==============================================================
// Altera o modulo para Financeiro, senao o SigaAuto nao executa
//==============================================================
nModulo := 6
cModulo := "FIN"

// SigaAuto de Baixa de Contas a Pagar
MSExecAuto( {|x,y| Fina080(x,y) } , aTitulo , 3 )

SE2->( MsUnLock() )

// Restaura o modulo em uso
nModulo := nModAnt
cModulo := cModAnt

// Verifica se houve erro no SigaAuto, caso haja mostra o erro
If lMsErroAuto
	lDeuErro := .T.
	MsgStop("Existe uma n�o conformidade no SigaAuto de Baixa de Contas a Pagar. Chave "+	xFilial("SE2")+cPrefixo+cNroTit+cParcela+cTipo+cFornec+cLjForn +;
			" Ap�s confirmar esta tela, sera apresentada a tela de N�o Conformidade do SigaAuto.","AGLT01629")
	MostraErro()
EndIf

Return

/*
===============================================================================================================================
Programa----------: incEmprest
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina que processa a inclus�o de empr�stimos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function incEmprest() 

Local _nX := 0

DBSelectArea("SA2")
SA2->( DBSetOrder(1) )
If SA2->( DBSeek( xFilial("SA2") + cGFornec + cGLjForn ) )

	ZLN->( RecLock( "ZLN" , .T. ) )
	
		ZLN->ZLN_FILIAL	:= xFilial("ZLN")
		ZLN->ZLN_COD	:= _nCodEmp
		ZLN->ZLN_SA2COD	:= SA2->A2_COD
		ZLN->ZLN_SA2LJ	:= SA2->A2_LOJA
		ZLN->ZLN_SA2NOM	:= SA2->A2_NOME
		ZLN->ZLN_DATA	:= dDataBase
		ZLN->ZLN_OBS	:= "Transfer�ncia: "+ cGEmprest
		ZLN->ZLN_VENCTO	:= StoD( _aTitulos[1][8] ) // Passa o menor vencimento
		ZLN->ZLN_TOTAL	:= nTotSaldo-_nTotAcDc
		ZLN->ZLN_PARC	:= Len( _aTitulos )
		ZLN->ZLN_JUROS	:= _nJuros
		ZLN->ZLN_VLRPAR	:= 0 // O valor da parcela pode variar neste caso diante disto eh passado o valor 0
		ZLN->ZLN_STATUS	:= "6"
		ZLN->ZLN_USER	:= _cMatUsr
		ZLN->ZLN_NUSER	:= _cNUseAp
		ZLN->ZLN_PAGTO	:= nTotSaldo    // Valor total a pagar pelo fornecedor
		ZLN->ZLN_DTLIB	:= dDataBase
		ZLN->ZLN_TIPO	:= _cZLNTipo
		ZLN->ZLN_DTCRED	:= CtoD("")
		ZLN->ZLN_CODTRA	:= cGEmprest
		ZLN->ZLN_USRTRA	:= _cMatUsr
		ZLN->ZLN_DATTRA	:= Date()
		ZLN->ZLN_HORTRA	:= Time()
		ZLN->ZLN_OBSTRA	:= cMObs
	
	ZLN->( MsUnlock() )
	
	//=======================================
	// Gera as NDF que o fornecedor ira pagar
	//=======================================
	For _nX := 1 to Len( _aTitulos )
	
		RecLock( "ZLQ" , .T. )
			
		    ZLQ->ZLQ_FILIAL	:= xFilial("ZLQ")
			ZLQ->ZLQ_COD	:= _nCodEmp
			ZLQ->ZLQ_ITEM	:= StrZero( _nX , 3 )
			ZLQ->ZLQ_VECTO	:= StoD( _aTitulos[_nX][8] )
			ZLQ->ZLQ_VALOR	:= _aTitulos[_nX][9]+_aTitulos[_nX][13]+_aTitulos[_nX][14]
		    ZLQ->ZLQ_CHAVET	:= xFilial("ZLQ") + _aTitulos[_nX][1] + _aTitulos[_nX][3] + _aTitulos[_nX][4] + _aTitulos[_nX][2] + _aTitulos[_nX][5] + _aTitulos[_nX][6]
		
		ZLQ->( MsUnlock() )
	
	Next _nX
		
	ConfirmSx8()
	
//=========================================================
// Nao foi encontrado o fornecedor do emprestimo de destino
//=========================================================
Else    
	lDeuErro := .T.
	MsgStop("Nao foi encontrado os dados do cadastro do fornecedor indicado para gerar o(a) " + _cTipo + "  de transfer�ncia. Favor checar se os dados foram corretamente inseridos.","AGLT01630")
EndIf

Return()

/*
===============================================================================================================================
Programa--------: incSE2
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o-------: Cria titulos no contas a pagar referentes a NDF'S do novo emprestimo
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function IncSE2()

Local _nX 		:= 0
Local _cAlias   := GetNextAlias()

Private _aAutoSE2   := {}
Private lMsErroAuto := .F.

BeginSql alias _cAlias
	SELECT COUNT(1) NREG
	FROM %table:SE2%
	WHERE D_E_L_E_T_ = ' '
	AND E2_FILIAL = %xFilial:SE2%
	AND E2_PREFIXO = %exp:_cPrefixo%
	AND E2_NUM = %exp:_nCodEmp%
	AND E2_FORNECE = %exp:cGFornec%
	AND E2_LOJA = %exp:cGLjForn%
	AND E2_TIPO = %exp:_cTipo01%
EndSql

If(_cAlias)->NREG == 0

	For _nX := 1 to Len( _aTitulos )
	
		_aAutoSE2 := {}
		
		AAdd( _aAutoSE2 , { "E2_PREFIXO"	, _cPrefixo									, Nil } )
		AAdd( _aAutoSE2 , { "E2_NUM"		, _nCodEmp									, Nil } )
		AAdd( _aAutoSE2 , { "E2_PARCELA"	, alltrim( str(_nX) )						, Nil } )
		AAdd( _aAutoSE2 , { "E2_TIPO"		, _cTipo01									, Nil } )
		AAdd( _aAutoSE2 , { "E2_NATUREZ"	, _cNaturez									, Nil } )
		AAdd( _aAutoSE2 , { "E2_FORNECE"	, cGFornec									, Nil } )
		AAdd( _aAutoSE2 , { "E2_LOJA"		, cGLjForn									, Nil } )
		AAdd( _aAutoSE2 , { "E2_EMISSAO"	, dDataBase									, Nil } )
		AAdd( _aAutoSE2 , { "E2_EMIS1"		, dDataBase									, Nil } )
		AAdd( _aAutoSE2 , { "E2_VENCTO"		, DataValida(StoD( _aTitulos[_nX][8] ))		, Nil } )
		AAdd( _aAutoSE2 , { "E2_VALOR"		, _aTitulos[_nX][9]							, Nil } )
		AAdd( _aAutoSE2 , { "E2_HIST"		, "TRANSFERENCIA " + Upper(_cTipo) + ":" + cGEmprest	, Nil } )
		AAdd( _aAutoSE2 , { "E2_DATALIB"	, StoD(_aTitulos[_nX][12])					, Nil } )
		AAdd( _aAutoSE2 , { "E2_USUALIB"	, cUserName									, Nil } )
		AAdd( _aAutoSE2 , { "E2_ACRESC"		, _aTitulos[_nX][13]						, Nil } )
		AAdd( _aAutoSE2 , { "E2_DECRESC"	, _aTitulos[_nX][14]						, Nil } )
		AAdd( _aAutoSE2 , { "E2_ORIGEM"		, "AGLT016"									, Nil } )
		
		lMsErroAuto := .F.
		
		nModulo := 6
		cModulo := "FIN"
		
		MSExecAuto( {|x,y| Fina050( x , y ) } , _aAutoSE2 , 3 ) //Inclusao
		
		If lMsErroAuto 
			lDeuErro := .T.
	 	   	MsgStop("N�o foi possivel gravar os dados! Erro ao gravar T�tulo: "+ _cPrefixo +"-"+ _nCodEmp + " Comunique ao Suporte!!!","AGLT01631")
	 	   	Mostraerro()
	 	   	Exit
		EndIf
		
		nModulo := 2
		cModulo := "COM"
		
	Next _nX
	
Else
	lDeuErro := .T.
   	MsgStop("J� existe no financeiro um t�tulo com os dados: "+ _cPrefixo +"-"+ _nCodEmp + "Comunique ao Suporte!!!","AGLT01632")
EndIf

(_cAlias)->( DBCloseArea() )

Return( .T. )

/*
===============================================================================================================================
Programa--------: AGLT016VLF
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o-------: Valida o fornecedor
===============================================================================================================================
Parametros------: cGFornec , cGLjForn , cGDescri
===============================================================================================================================
Retorno---------: _lRet
===============================================================================================================================
*/
Static Function AGLT016VLF( cGFornec , cGLjForn , cGDescri )

Local _lRet := .T.
Local _cChave := IIF(Empty(cGLjForn),cGFornec,cGFornec+cGLjForn)

DBSelectArea("SA2")
SA2->( DBSetOrder(1) )
If SA2->( DBSeek( xFilial("SA2") + _cChave ) )
	If !Empty(cGLjForn)
		If SA2->A2_MSBLQL == '1'
			MsgStop( "N�o � poss�vel transferir um(a) " + _cTipo + "  para um fornecedor inativo no Leite!"+; 
					" Para processar a transfer�ncia informe um fornecedor ativo na Gest�o do Leite.","AGLT01633")
			_lRet := .F.
		EndIf
	EndIf
	cGLjForn:= SA2->A2_LOJA
	cGDescri := SA2->A2_NOME		
Else
	MsgStop("C�digo de Fornecedor/Loja inv�lido! Informe um c�digo de fornecedor que seja v�lido e esteja ativo.","AGLT01634")
	_lRet := .F.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT016C
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Rotina desenvolvida para realizar o estorno de uma transferencia de emprestimo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT016C()
                               
Local lProcEstor	:= .F.
Private cPerg		:= "AGLT016C"   
Private lDeuErro	:= .F.     
Private _cCodEmp	:= ""
Private _cCodForn	:= ""
Private _cLjForn	:= ""     
Private _cCodEmpOr	:= ""
Private _cTipo		:= ""

If !Pergunte(cPerg,.T.) 
     return
EndIf      

dBSetOrder(1)

Processa( {||lProcEstor:=vldEstorno()}/*bAction*/, "Aguarde..."/*cTitle */, "Processando valida��es para realizar o estorno!"/*cMsg */,.F./*lAbort */)
     
//Verifica se eh possivel processar o estorno da transferencia do emprestimo
If lProcEstor
	Processa( {||ProcEstor()}/*bAction*/, "Aguarde..."/*cTitle */, "Processando o estorno da transfer�ncia!"/*cMsg */,.F./*lAbort */)
EndIf

Return       

/*
===============================================================================================================================
Programa----------: vldEstorno
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Valida se pode ser reaizado o estorno da transfer�ncia
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function vldEstorno()   

Local _lRet		:= .T.
Local _cAlias	:= GetNextAlias()

If ZLN->(DbSeek(xFilial('ZLN')+MV_PAR01)) .And. ZLN->ZLN_STATUS == "6"
	_cCodEmp	:= ZLN->ZLN_COD   //Armazena o codigo do emprestimo transferido a ser estornado
	_cCodForn	:= ZLN->ZLN_SA2COD
	_cLjForn	:= ZLN->ZLN_SA2LJ      
	_cCodEmpOr	:= ZLN->ZLN_CODTRA //Armazena o codigo do emprestimo de origem
	//====================================================================================================
	// Obtendo Parametos dos EMPRESTIMOS
	//====================================================================================================
	If ZLN->ZLN_TIPO == 'E'
		_cPrefixo := SuperGetMV("LT_3EMPPRE",.F.,"G3E")
		_cTipo	:= "Empr�stimo"
	//====================================================================================================
	// Obtendo Parametos dos ADIANTAMENTOS
	//====================================================================================================
	ElseIf ZLN->ZLN_TIPO == 'A'
		_cPrefixo := SuperGetMV("LT_3ADTPRE",.F.,"G3A")
		_cTipo	:= "Adiantamento"
	//====================================================================================================
	// Obtendo Parametos das ANTECIPACOES  
	//====================================================================================================
	ElseIf ZLN->ZLN_TIPO == "N"
		_cPrefixo := SuperGetMV("LT_3ANTPRE",.F.,"G3N")
		_cTipo	:= "Antecipa��o"
	EndIf
	
	//Verifica se o mvimento a ser estornado sofre alguma baixa, pois somente podera ser realizado o estorno de um movimento que n�o sofreu nenhuma baixa
	BeginSql alias _cAlias
		SELECT COUNT(1) QTD
		FROM %table:SE2%
		WHERE D_E_L_E_T_ = ' '
		AND E2_FILIAL = %xFilial:SE2%
		AND E2_PREFIXO = %exp:_cPrefixo%
		AND E2_NUM = %exp:_cCodEmp%
		AND E2_FORNECE = %exp:_cCodForn%
		AND E2_LOJA = %exp:_cLjForn%
		AND E2_VALOR <> E2_SALDO
	EndSql
	
	If (_cAlias)->QTD > 0
		MsgStop("N�o poder� ser realizado o estorno do(a) " + _cTipo + " informado! " + _cTipo + " " + MV_PAR01 + " encontra-se com baixa(s) realizada(s) no financeiro.","AGLT01635")
		_lRet:= .F.
	EndIf	 
Else
	MsgStop("Esta rotina somente poder� ser executada para movimentos que foram inseridos atrav�s da rotina de transfer�ncia." +;
			"Favor verificar o status do movimento que esteja tentando efetivar o seu estorno, ou se o codigo fornecido do movimento a realizar o estorno esteja corretamente preenchido.","AGLT01636")
	_lRet:= .F.
EndIf

(_cAlias)->(DbCloseArea())

Return _lRet     

/*
===============================================================================================================================
Programa----------: ProcEstor
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Processa o estorno
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ProcEstor

	Begin Transaction

		Processa( {||ExcluiSE2()}/*bAction*/, "Aguarde..."/*cTitle */, "Processando a exclus�o dos dados financeiro do(a) " + _cTipo/*cMsg */,.F./*lAbort */)

		//=============================================================================================================
		//Caso encontre problemas na exclusao dos titulos no financeiro dos emprestimo transferido desarma a transacao
		//=============================================================================================================
		If lDeuErro
			DisarmTransaction()
			//===========================================================================================================================================
	   		//Caso nao encontre problema na exclusao dos titulos no financeiro realiza o cancelamento das baixas do emprestimo de origem da transferencia
			//===========================================================================================================================================
		Else
			Processa( {||CancBxSE2()}/*bAction*/, "Aguarde..."/*cTitle */, "Processando o cancelamento das baixas do financeiro..."/*cMsg */,.F./*lAbort */)
			If lDeuErro
				DisarmTransaction()  
			Else    
				//Efetua o delete do emprestimo transferido e ajusta algumas informacoes no emprestimo de origem
				Processa( {||ProcZLN()}/*bAction*/, "Aguarde..."/*cTitle */, "Processando atualiza��o da tabela de " + _cTipo/*cMsg */,.F./*lAbort */)
				If lDeuErro
					DisarmTransaction()
				Else
					MsgInfo("O estorno da transferencia do(a) " + _cTipo + " foi realizado com sucesso!")
				EndIf	
			EndIf	
		EndIf	
	
	End Transaction  

Return

/*
===============================================================================================================================
Programa----------: ExcluiSE2
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Exlcui titulo no contas a pagar via SigaAuto
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ExcluiSE2()     

Local nModAnt	:= nModulo
Local cModAnt	:= cModulo
Local _aArea	:= GetArea()
Local _aAutoSE2	:= {}
Local _nContReg	:= 0
Local _cAlias	:= GetNextAlias()
Private lMsErroAuto:= .F.
Private lMsHelpAuto:= .T. 

BeginSql alias _cAlias
	SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
	FROM %table:SE2%
	WHERE D_E_L_E_T_ = ' '
	AND E2_FILIAL = %xFilial:SE2%
	AND E2_PREFIXO = %exp:_cPrefixo%
	AND E2_NUM = %exp:_cCodEmp%
	AND E2_FORNECE = %exp:_cCodForn%
	AND E2_LOJA = %exp:_cLjForn%
EndSql
	
COUNT TO _nContReg //Contabiliza o numero de registros encontrados pela query  
(_cAlias)->(DbGoTop())

//=============================================
//Econtrou registros para realizar a exclusao
//=============================================
If _nContReg > 0
	While (_cAlias)->(!Eof()) .And. !lDeuErro
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		If SE2->(DbSeek(xFILIAL("SE2")+(_cAlias)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
			
			//=============================================
			//Array com os dados a serem passados para o SigaAuto
			//=============================================
			_aAutoSE2:={{"E2_PREFIXO",SE2->E2_PREFIXO,Nil},;
			{"E2_NUM"    ,SE2->E2_NUM     ,Nil},;
			{"E2_TIPO"   ,SE2->E2_TIPO    ,Nil},;
			{"E2_PARCELA",SE2->E2_PARCELA ,Nil},;
			{"E2_NATUREZ",SE2->E2_NATUREZ ,Nil},;
			{"E2_FORNECE",SE2->E2_FORNECE ,Nil},;
			{"E2_LOJA"   ,SE2->E2_LOJA    ,Nil}}
	
			//=============================================================
			//Altera o modulo para Financeiro, senao o SigaAuto nao executa
			//=============================================================
			nModulo := 6
			cModulo := "FIN"
			
			//=============================================
			//Roda SigaAuto de Exclusao de Titulos a Pagar
			//=============================================
			MSExecAuto({|x,y,z| Fina050(x,y,z)},_aAutoSE2,.T.,5)
			
			If lMsErroAuto
				lDeuErro := .T.
				MsgStop("O titulo "+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+" n�o foi excluido! Fornecedor: "+SE2->E2_FORNECE+"/"+SE2->E2_LOJA+"-"+SE2->E2_NOMFOR;
						+ "Verifique no financeiro se este titulo ja foi baixado ou o motivo pelo qual n�o pode ser exclu�do."+;
						" Ao confimar esta tela, sera apresentada a tela do SigaAuto, que possui informa��es mais detalhadas.", "AGLT01637")
			   		Mostraerro()
			EndIf
			
			//=============================================
			//Restaura o modulo em uso.
			//=============================================
			nModulo := nModAnt
			cModulo := cModAnt           
		EndIf	
	
		(_cAlias)->(DbSkip())
	EndDo  
(_cAlias)->(DbCloseArea())

Else
	lDeuErro := .T.
	MsgStop("N�o foi(ram) econtrado(s) t�tulo(s) no financeiro para realizar a exclus�o. Favor acionar a �rea de TI/Sistemas.","AGLT01638")
EndIf   

RestArea(_aArea)

Return  

/*
===============================================================================================================================
Programa----------: CancBxSE2
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Cancela Baixa de titulo no contas a pagar via SigaAuto
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CancBxSE2()

Local nModAnt		:= nModulo
Local cModAnt		:= cModulo
Local _aArea		:= GetArea()
Local _nContReg		:= 0      
Local _cMotBaixa	:= GetMv("IT_MOTBXTR") 
Local _aTitulo		:= {}
Local _cAliasZLQ	:= GetNextAlias() 
Local _cAliasSE5	:= GetNextAlias()
Local _cFilial		:= ""
Local _cNumero		:= ""
Local _cParcela		:= ""
Local _cTp			:= ""
Local _cFornece		:= ""
Local _cLoja		:= ""

Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.

BeginSql alias _cAliasZLQ
	SELECT ZLQ_VALOR,ZLQ_CHAVET
	FROM %table:ZLQ%
	WHERE D_E_L_E_T_ = ' '
	AND ZLQ_FILIAL = %xFilial:ZLQ%
	AND ZLQ_COD = %exp:_cCodEmp%
EndSql
	
COUNT TO _nContReg //Contabiliza o numero de registros encontrados pela query  
(_cAliasZLQ)->(DbGoTop())

If _nContReg > 0
	While !(_cAliasZLQ)->(Eof()) .And. !lDeuErro
		_cFilial	:= SubStr((_cAliasZLQ)->ZLQ_CHAVET,1,2)
		_cPrefixo	:= SubStr((_cAliasZLQ)->ZLQ_CHAVET,3,3)
		_cNumero	:= SubStr((_cAliasZLQ)->ZLQ_CHAVET,6,9)
		_cParcela	:= SubStr((_cAliasZLQ)->ZLQ_CHAVET,15,2)
		_cTp		:= SubStr((_cAliasZLQ)->ZLQ_CHAVET,17,3)
		_cFornece	:= SubStr((_cAliasZLQ)->ZLQ_CHAVET,20,6)
		_cLoja		:= SubStr((_cAliasZLQ)->ZLQ_CHAVET,26,4)
		
		If !Empty(_cNumero)
		
			//============================================================================================
			//Chama funcao para criar tabela Temporaria contendo os dados das baixas a serem canceladas
			//============================================================================================
			BeginSql alias _cAliasSE5
				SELECT E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_VALOR,E5_SEQ,E5_MOTBX,E5_DATA,E5_CLIFOR,E5_LOJA
				FROM %table:SE5%
				WHERE D_E_L_E_T_ = ' '
				AND E5_TIPODOC = 'BA'
				AND E5_SITUACA <> 'C'
				AND E5_MOTBX = %exp:_cMotBaixa%
				AND E5_VALOR = %exp:Str((_cAliasZLQ)->ZLQ_VALOR )%
				AND E5_FILIAL = %exp:_cFilial%
				AND E5_PREFIXO = %exp:_cPrefixo%
				AND E5_NUMERO = %exp:_cNumero%
				AND E5_PARCELA = %exp:_cParcela%
				AND E5_TIPO = %exp:_cTp%
				AND E5_CLIFOR = %exp:_cFornece%
				AND E5_LOJA = %exp:_cLoja%
			EndSql

			COUNT TO _cContReg //Contabiliza o numero de registros encontrados pela query  
			(_cAliasSE5)->(DbGoTop())
			If _cContReg > 0        
				While !(_cAliasSE5)->(Eof()) .And. !lDeuErro
					DbSelectArea("SE2")
					SE2->(DbSetOrder(1))
					
					_aTitulo := {{"E2_PREFIXO",(_cAliasSE5)->E5_PREFIXO						,Nil},;
					{"E2_NUM"	    ,(_cAliasSE5)->E5_NUMERO          						,Nil},;
					{"E2_PARCELA"   ,(_cAliasSE5)->E5_PARCELA         						,Nil},;
					{"E2_TIPO"	    ,(_cAliasSE5)->E5_TIPO            						,Nil},;
					{"E2_FORNECE"   ,(_cAliasSE5)->E5_CLIFOR          						,Nil},;
					{"E2_LOJA"	    ,(_cAliasSE5)->E5_LOJA            						,Nil},;
					{"AUTJUROS"		,0				        		   						,Nil},;
					{"AUTDESCONT"	,0		 		                   						,Nil},;
					{"AUTMOTBX"		,(_cAliasSE5)->E5_MOTBX           						,Nil},;
					{"AUTDTBAIXA"	,(_cAliasSE5)->E5_DATA	           						,Nil},;
					{"AUTDTCREDITO"	,(_cAliasSE5)->E5_DATA           						,Nil},;
					{"AUTHIST"		,"Cancto Bx Tr - " + (_cAliasSE5)->(E5_CLIFOR+E5_LOJA)	,Nil},;
					{"AUTVLRPG"		,(_cAliasSE5)->E5_VALOR									,Nil},;
					{"AUTVALREC"	,(_cAliasSE5)->E5_VALOR									,Nil}}
					
					//=============================================================
					//Altera o modulo para Financeiro, senao o SigaAuto nao executa
					//=============================================================
					nModulo := 6
					cModulo := "FIN"
		
					//=========================
					//Busca o numero da Baixa
					//=========================
					_nBaixa := NroSeq((_cAliasSE5)->E5_PREFIXO,(_cAliasSE5)->E5_NUMERO,(_cAliasSE5)->E5_PARCELA,(_cAliasSE5)->E5_TIPO,(_cAliasSE5)->E5_CLIFOR,(_cAliasSE5)->E5_LOJA,(_cAliasSE5)->E5_SEQ)
		
					//=============================================================
					//SigaAuto de Cancelamento de Baixa de Contas a Pagar
					//=============================================================
					MSExecAuto( {|x,y,z,k| Fina080(x,y,z,k)},_aTitulo,5,,_nBaixa)
					
					//Restaura o modulo em uso
					nModulo := nModAnt
					cModulo := cModAnt 
					
				    If lMsErroAuto
						lDeuErro:=.T.
						MsgStop("Erro ao excluir a baixa no Contas a Pagar, t�tulo " + (_cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) + "Favor acionar a equipe de TI/Sistemas.","AGLT01639")
					  	Mostraerro()
				    EndIf       				    		
													
					(_cAliasSE5)->(DbSkip())			
				EndDo
				(_cAliasSE5)->(DbCloseArea())
			Else
				lDeuErro := .T.
				MsgStop("N�o foram econtrados dados para a realiza��o do cancelamento das baixas no financeiro do(a) " + _cTipo + " de origem. Favor acionar a equipe de TI/Sistemas.","AGLT01640")
			EndIf
		Else 
			lDeuErro := .T.
			MsgStop("A chave de estorno do(a) " + _cTipo +" " + _cCodEmp + " esta vazia. Favor acionar a equipe de TI/Sistemas.", "AGLT01641")
		EndIf	
		
		(_cAliasZLQ)->(DbSkip())
	EndDo
	(_cAliasZLQ)->(DbCloseArea())	  
//=============================================================
//Nao encontrou dados do emprestimo de origem
//=============================================================
Else
	lDeuErro := .T.
	MsgStop("N�o foram encontrados os dados do(a)" + _cTipo +" " + _cCodEmp + " Favor acionar a equipe de TI/Sistemas.", "AGLT01642")
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: ProcZLN
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Atualiza registros na ZLN
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ProcZLN()

Local _aArea:= GetArea()
                   
//Efetua exclusao do cabecalho do emprestimo transferido bem como de seus itens
If ZLN->(DbSeek(xFilial("ZLN") + _cCodEmp))  
	ZLN->(RecLock("ZLN",.F.)) 
		ZLN->(dbDelete())
	ZLN->(MsUnlock())    
	
	ZLQ->(DbSetOrder(1))
	If ZLQ->(DbSeek(xFilial("ZLQ") + _cCodEmp))  
		While !ZLQ->(Eof()) .And. xFilial("ZLQ") == ZLQ->ZLQ_FILIAL .And. _cCodEmp == ZLQ->ZLQ_COD
			ZLQ->(RecLock("ZLQ",.F.))    
				ZLQ->(dbDelete())  
			ZLQ->(MsUnlock()) 
		ZLQ->(DbSkip())
		EndDo  
	//Nao foram encontrados os dados dos itens do emprestimo para realizar a sua exclusao
	Else  
		lDeuErro := .T.
		MsgStop("N�o foram encontrados os dados dos itens do(A)" + _cTipo +" " + _cCodEmp + " para realizar a sua exclus�o na tabela ZLQ. Favor acionar a equipe de TI/Sistemas.", "AGLT01643")
	EndIf 
	     
//Nao foi encontrado o registro dos dados do cabecalho de origem 
Else  
	lDeuErro := .T.
	MsgStop("N�o foram encontrados os dados do cabecalho do(A)" + _cTipo +" " + _cCodEmp + " para realizar a sua exclus�o na tabela ZLN. Favor acionar a equipe de TI/Sistemas.","AGLT01644")
EndIf     
     
//Caso nao ocorra erro na exclusao dos dados do emprestimo de transferencia atualiza os dados do emprestimo de origem para que ele volte o 
//seu status como antes da realizacao da transferencia
If !lDeuErro  

	ZLN->(dbCommit()) 
	ZLQ->(dbCommit()) 

	If ZLN->(dbSeek(xFilial("ZLN") + _cCodEmpOr))   
		ZLN->(RecLock("ZLN",.F.))    
	 		ZLN->ZLN_STATUS:= "4" //Efetivado     
        	ZLN->ZLN_CODTRA:= ""
			ZLN->ZLN_USRTRA:= ""
			ZLN->ZLN_DATTRA:= CtoD("")
			ZLN->ZLN_HORTRA:= ""
			ZLN->ZLN_OBSTRA:= ""    			
		ZLN->(MsUnlock()) 
	Else
		lDeuErro := .T.
		Help(NIL, NIL, "AGLT01645", NIL, "N�o foram encontrados os dados do cabecalho do(A)" + _cTipo +" " + _cCodEmp + " para realizar a sua altera��o na tabela ZLN.";
			, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor acionar a equipe de TI/Sistemas."})
	EndIf
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: NroSeq
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2019
===============================================================================================================================
Descri��o---------: Busca numero de sequencia da baixa no array de baixas do titulo
===============================================================================================================================
Parametros--------: cPrefixo   = Prefixo do titulo a ser cancelado a baixa
					cNum       = Numero do titulo a ser cancelado a baixa
					cParc      = Parcela do titulo a ser cancelado a baixa
					cTipo      = Tipo do titulo a ser cancelado a baixa
					cFor       = Fornecedor do titulo a ser cancelado a baixa
					cLoja      = Loja do Fornecedor do titulo a ser cancelado a baixa
					cSeq       = Sequencia da baixa
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function NroSeq(cPrefixo,cNum,cParcela,cTipo,cFor,cLoja,cSeq)

Local nRet := 0
Local nPos := 0

Private lBaixaAbat:= .F.
Private lNotBax   := .F.
Private lAglImp   := .F.
Private lBxCec    := .F.
Private nTotImpost:= 0
Private nTotAdto  := 0
Private aBaixaSE5 := {}

DbSelectArea("SE2")
SE2->(DbSetOrder(1))
SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cFor+cLoja))

//Funcao Padrao do Sistema que retorna um array com as baixas a serem canceladas
aBaixaSE5 := Sel080Baixa("VL /V2 /BA /RA /CP /LJ /NCC/",cPrefixo,cNum,cParcela,cTipo,@nTotAdto,@lBaixaAbat,cFor,cLoja,@lBxCec,.T.,@lNotBax,@nTotImpost,@lAglImp)
For nPos := 1 to len(aBaixaSE5)
	If Substr(aBaixaSE5[nPos],LEN(aBaixaSE5[nPos])-1,2) == cSeq
		nRet := nPos
		Exit
	Endif
Next nPos

Return nRet
