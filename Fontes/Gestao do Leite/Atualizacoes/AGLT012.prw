/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |   Data   |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |16/07/2024| Chamado 47889. Permitir transfer�ncia entre filiais
Lucas Borges  |02/01/2025| Chamado 49500. Inclu�do no tipo P-Pagamento
Lucas Borges  |07/01/2025| Chamado 49528. Corrigida sintaxe da query
===============================================================================================================================
*/

//===========================================================================
//Defini��es de Includes
//===========================================================================
#INCLUDE 'Protheus.ch' 
#INCLUDE "FWMVCDEF.CH"

/*
===============================================================================================================================
Programa----------: AGLT012
Autor-------------: Alexandre Villar - Rotina Revisada/Atualizada - Chamado 8049
Data da Criacao---: 08/01/2015
Descri��o---------: Rotina para administra��o do cadastro de solicita��es de empr�stimos (Vers�o com modelo em MVC)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012

Local _oBrowse := Nil

Private	_cNUseAp	:= Substr(UsrFullName(RetCodUsr()),1,GetSX3Cache("ZLM_NUSEAP","X3_TAMANHO"))
Private _cMatUsr	:= FWSFAllUsers({RetCodUsr()},{"USR_FILIAL","USR_CODFUNC"})[1][3]+FWSFAllUsers({RetCodUsr()},{"USR_FILIAL","USR_CODFUNC"})[1][4]
Private	_cTipo01	:= SuperGetMV("LT_3EMPTP1",.F.,"NDF")
Private	_cTipo02	:= SuperGetMV("LT_3EMPTP2",.F.,"NF")
Private	_cNaturez	:= ""
Private _cPrefixo	:= ""

If dDataBase <> LastDate(dDataBase)
	MsgStop("Opera��es permitidas somente com ultimo dia do m�s!",'AGLT01201')
	Return()
EndIf

//====================================================================================================
// Configura e inicializa a Classe do Browse
//====================================================================================================
_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( 'ZLM' )
_oBrowse:SetMenuDef( 'AGLT012' )
_oBrowse:SetDescription( 'Administra��o do Leite - Empr�stimos a Produtores' )

_oBrowse:AddLegend( "ZLM_STATUS == '2'" , 'GREEN'	, 'Aprovada'		)
_oBrowse:AddLegend( "ZLM_STATUS == '3'" , 'RED'		, 'Reprovada'		)
_oBrowse:AddLegend( "ZLM_STATUS == '4'" , 'BLUE'	, 'Efetivado'		)
_oBrowse:AddLegend( "ZLM_STATUS == '1'" , 'WHITE'	, 'Em Aberto'		)
_oBrowse:AddLegend( "ZLM_STATUS == '5'" , 'BLACK'	, 'Transferido'		)
_oBrowse:AddLegend( "ZLM_STATUS == '6'" , 'GRAY'	, 'Transfer�ncia'	)

_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para cria��o do menu da tela principal
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title 'Visualizar'		   		Action 'VIEWDEF.AGLT012'			OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'   		   		Action 'VIEWDEF.AGLT012'			OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Inclus�o M�ltipla' 		Action 'U_AGLT012I()'				OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'   		   		Action 'VIEWDEF.AGLT012'			OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'	   	   	  		Action 'VIEWDEF.AGLT012'			OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Avaliar'   		   		Action 'U_AGLT012A()'				OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Avalia��o M�ltipla'		Action 'U_AGLT012T(1)'				OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Efetivacao Multipla'		Action 'U_AGLT012T(2)'				OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Estorna'					Action 'U_AGLT012E()'				OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Transferencia'			Action 'U_AGLT012B()'				OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Estorno Transf.'			Action 'U_AGLT012C()'				OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Recibo Pagamento'		Action 'U_RGLT049()'				OPERATION 8 ACCESS 0
ADD OPTION _aRotina Title 'Declara��o'				Action 'U_RGLT052()'				OPERATION 8 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para montagem do modelo de dados para o processamento
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oStruZLM	:= FWFormStruct( 1 , 'ZLM' )
Local _oStruZLO	:= FWFormStruct( 1 , 'ZLO' )
Local _oModel	:= MpFormModel():New( "AGLT012M" ,, {|_oModel| VALIDCOMIT(_oModel) } )
Local _aGatAux	:= {}

//====================================================================================================
// Monta a estrutura de gatilhos
//====================================================================================================
_aGatAux := FwStruTrigger( 'ZLM_SA2COD' , 'ZLM_SA2LJ' , 'SA2->A2_LOJA' , .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLM_SA2COD+IF(SA2->A2_COD==M->ZLM_SA2COD,SA2->A2_LOJA,"")' )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_SA2COD' , 'ZLM_SA2NOM' , 'SA2->A2_NOME' , .T. , 'SA2' , 1 , 'xFilial("SA2")+M->(ZLM_SA2COD)' )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_SA2LJ' , 'ZLM_SA2NOM' , 'SA2->A2_NOME' , .T. , 'SA2' , 1 , 'xFilial("SA2")+M->(ZLM_SA2COD+ZLM_SA2LJ)' )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_SA2LJ' , 'ZLM_SETOR' , 'U_AGLT012SET( M->ZLM_SA2COD , M->ZLM_SA2LJ )' , .F.	)
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_TOTAL'	, 'ZLM_PAGTO' , 'U_AGLT012JUR()' , .F. )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_JUROS'	, 'ZLM_PAGTO' , 'U_AGLT012JUR()' , .F. )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_PARC'	, 'ZLM_PAGTO' , 'U_AGLT012JUR()' , .F. )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_VENCTO'	, 'ZLM_PAGTO' , 'U_AGLT012JUR()' , .F. )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLM_TOTAL'	, 'ZLM_DATA'  , 'dDataBase' , .F. )
_oStruZLM:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel:AddFields(	'ZLMMASTER'	,				, _oStruZLM )
_oModel:AddGrid(	'ZLODETAIL'	, 'ZLMMASTER'	, _oStruZLO )

_oModel:SetRelation( 'ZLODETAIL', { { 'ZLO_FILIAL' , 'xFilial( "ZLO" )' } , { 'ZLO_COD' , 'ZLM_COD' } } , ZLO->( IndexKey(1) ) )

_oModel:SetDescription( 'Administra��o do Leite - Solicita��o de Empr�stimos' )

_oModel:GetModel( 'ZLMMASTER' ):SetDescription( 'Dados do Produtor'		)
_oModel:GetModel( 'ZLODETAIL' ):SetDescription( 'Dados do Empr�stimo'	)

_oModel:GetModel( 'ZLODETAIL' ):SetUniqueLine( { 'ZLO_ITEM' } )
_oModel:GetModel( 'ZLODETAIL' ):SetOptional( .T. )

_oModel:SetPrimaryKey( { 'ZLM_FILIAL' , 'ZLM_COD' } )

_oModel:SetVldActivate( {|_oModel| AGLT012L(_oModel) } )

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para montar a View de Dados para exibi��o
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()

Local _oModel	:= FWLoadModel( 'AGLT012' )
Local _oStruZLM	:= FWFormStruct( 2 , 'ZLM' )
Local _oStruZLO	:= FWFormStruct( 2 , 'ZLO' )
Local _oView	:= FWFormView():New()

_oStruZLO:RemoveField( "ZLO_FILIAL"	)
_oStruZLO:RemoveField( "ZLO_COD"	)

_oView:SetModel( _oModel )

_oView:AddField(	'VIEW_CAB' , _oStruZLM	, 'ZLMMASTER' )
_oView:AddGrid(		'VIEW_DET' , _oStruZLO	, 'ZLODETAIL' )

_oView:CreateHorizontalBox( 'SUPERIOR'	, 60 )
_oView:CreateHorizontalBox( 'INFERIOR'	, 40 )

_oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR'	)
_oView:SetOwnerView( 'VIEW_DET'	, 'INFERIOR'	)

_oView:EnableTitleView( 'VIEW_DET' , 'InForma��es dos Vencimentos:' )

_oView:AddIncrementField( 'VIEW_DET' , 'ZLO_ITEM' )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT012L
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para processamento da valida��o inicial das opera��es
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012L( _oModel )

Local _nOper		:= _oModel:GetOperation()
Local _lRet			:= .T.
Local _aArea		:= GetArea()

If _nOper == MODEL_OPERATION_DELETE .Or. _nOper == MODEL_OPERATION_UPDATE
	If ZLM->ZLM_STATUS <> '1'
		Help(NIL, NIL, "AGLT01202", NIL, "N�o � poss�vel alterar um registro que n�o esteja com status: 'Em Aberto'!", 1, 0, NIL, NIL, NIL, NIL, NIL, ;
		{"Verique o Status da solicitacao! Uma vez aprovada ou efetivada n�o poder� mais sofrer altera��es."})
		_lRet := .F.
	EndIf
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: VALIDCOMIT
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para processamento da valida��o final das opera��es ao confirmar o modelo de dados
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VALIDCOMIT( _oModel )

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cCODSA2	:= ''
Local _cLOJSA2	:= ''
Local _dDtVenc	:= _oModel:GetValue( 'ZLMMASTER' , 'ZLM_VENCTO' )
Local _dDtCred	:= _oModel:GetValue( 'ZLMMASTER' , 'ZLM_DTCRED' )
Local _nOper	:= _oModel:GetOperation()

If dDataBase <> LastDate(dDataBase)
	Help(NIL, NIL, "AGLT01203", NIL, "Opera��es permitidas somente com ultimo dia do m�s!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verique as datas informadas!"})
	_lRet := .F.
EndIf

If _lRet .And. _dDtCred < dDataBase
	Help(NIL, NIL, "AGLT01204", NIL, "N�o � permitido informar uma data de Cr�dito menor que a data atual!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verique as datas informadas!"})
	_lRet := .F.
EndIf

If _lRet .And. _dDtVenc < _dDtCred
	Help(NIL, NIL, "AGLT01205", NIL, "N�o � permitido informar uma data de 1� vencimento menor que a data do Cr�dito!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verique as datas informadas!"})
	_lRet := .F.
EndIF

If _lRet .And. _nOper == MODEL_OPERATION_INSERT
	
	_cCODSA2 := _oModel:GetValue( 'ZLMMASTER' , 'ZLM_SA2COD' )
	_cLOJSA2 := _oModel:GetValue( 'ZLMMASTER' , 'ZLM_SA2LJ'  )
	
	If !Empty( _cCODSA2 ) .And. !Empty( _cLOJSA2 )
	
		DBSelectArea('SA2')
		SA2->( DBSetOrder(1) )
		If SA2->( DBSeek( xFilial('SA2') + _cCODSA2 + _cLOJSA2 ) )
			If SA2->A2_MSBLQL == '1' .Or. SA2->A2_L_ATIVO == 'N'
				MsgStop("Produtor/Fretista informado encontra-se Bloqueado ou Inativo no cadastro de Fornecedores do Sistema! Verifique o Fornecedor selecionado ou o cadastro do mesmo no Sistema!","AGLT01206")
				_lRet := .F.
			Else
				_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_USER'  , _cMatUsr )
				_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_NUSER' , _cNUseAp	)
			EndIf
		Else
			MsgStop("Produtor/Fretista informado n�o foi encontrado no cadastro de Fornecedores do Sistema! Verifique o Fornecedor selecionado ou o cadastro do mesmo no Sistema!","AGLT01207")
			_lRet := .F.
		EndIf
	
	EndIf
	If _oModel:GetValue( 'ZLMMASTER' , 'ZLM_VLRPAR' ) == 0
		MsgStop("O valor da parcela deve ser maior que 0! Verifique os dados informados!","AGLT01208")
		_lRet := .F.
	EndIf
EndIf

RestArea(_aArea)

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT012SET
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para retornar o c�digo do Setor de acordo com o cadastro do Fornecedor (SA2)
Parametros--------: _cSA2COD, _cSA2LOJ
Retorno-----------: _cRet - Setor do Fornecedor informado
===============================================================================================================================
*/
User Function AGLT012SET( _cSA2COD , _cSA2LOJ )

Local _aArea	:= GetArea()
Local _cLinha	:= Posicione( 'SA2' , 1 , xFilial('SA2') + _cSA2COD + IF(SA2->A2_COD==_cSA2COD,SA2->A2_LOJA,_cSA2LOJ), 'A2_L_LI_RO')
Local _cRet		:= Posicione( 'ZL3' , 1 , xFilial('ZL3') + _cLinha				                                     , 'ZL3_SETOR' )

RestArea( _aArea )

Return( _cRet )

/*
===============================================================================================================================
Programa----------: AGLT012JUR
Autor-------------: Alexandre Villar
Data da Criacao---: 08/01/2015
Descri��o---------: Gatilho que calcula juros e cria os itens com vencimento e valores das presta��es
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012JUR()

Local _oModel		:= FWModelActive()
Local _oView		:= FWViewActive()
Local _oModZLO		:= _oModel:GetModel('ZLODETAIL')

Local _nValTot		:= _oModel:GetValue( 'ZLMMASTER' , 'ZLM_TOTAL' )
Local _nParc		:= _oModel:GetValue( 'ZLMMASTER' , 'ZLM_PARC'  )
Local _nJuros		:= _oModel:GetValue( 'ZLMMASTER' , 'ZLM_JUROS' )
Local _nLenZLO		:= 0
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
	// Novo Calculo dos juros e valor das parcelas
	_nValPag := Round( _nValTot , 2 )
	
	//====================================================================================================
	// Calculo do Juro Composto estava fazendo o c�lculo achando o montante total de juros e dividindo 
	// pela qde de parcelas. Foi feito a implementa��o para o c�lculo do PMT seguindo a Formula correta.
	//====================================================================================================
	If _nJuros == 0
		_nValPar := Round( _nValPag / _nParc	, 2 )
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_VLRPAR' , _nValPar )
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_PAGTO'  , _nValPag )
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
        
        _oModel:LoadValue( 'ZLMMASTER' , 'ZLM_VLRPAR' , _nValPar )
        _oModel:LoadValue( 'ZLMMASTER' , 'ZLM_PAGTO'  , _nValPag )
	EndIf
	
	// Preenche os itens                          
	_aVenctos	:= {}
	_dDtAux		:= _oModel:GetValue( 'ZLMMASTER' , 'ZLM_VENCTO' )
	_nRest		:= _nValPag
	
	For _nI := 1 To _nParc
		aAdd( _aVenctos , _dDtAux )
		_dDtAux := MonthSum( _dDtAux , 1 )
	Next _nI
	
	_nLenZLO := _oModZLO:Length()
	
	For _nI := 1 To _nLenZLO
		_oModZLO:GoLine( _nI )
		If !_oModZLO:IsDeleted()
			_oModZLO:DeleteLine()
		EndIf
	Next _nI
	
	For _nI := 1 to Len( _aVenctos )
		If _nI <= _nLenZLO
			_oModZLO:GoLine( _nI )
			If _oModZLO:IsDeleted()
				_oModZLO:UnDeleteLine()
			EndIf
			_oView:Refresh()
		Else
			_nLenZLO := _oModZLO:AddLine()
			_oView:Refresh()
			_oModZLO:GoLine(_nI)
		EndIf
		
		_oModZLO:LoadValue( 'ZLO_VECTO' , _aVenctos[_nI] )
		
		If _nI < Len( _aVenctos )
			_oModZLO:LoadValue( 'ZLO_VALOR' , Round( _nValPar , 2 ) )
			_nRest := _nRest - Round( _nValPar , 2 )
		Else
			_oModZLO:LoadValue('ZLO_VALOR' , _nRest )
		EndIf
	Next _nI
EndIf

_oModZLO:GoLine(01)
_oView:Refresh()

Return( _nValPag )

/*
===============================================================================================================================
Programa----------: AGLT012A
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para processamento da Avalia��o de solicita��es (Aprovar/Reprovar)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012A()

FWExecView( '[ Avalia��o da Solicita��o ]' , 'AGLT012' , 4 ,, {|| .T. } , {|| AGLT012ATU() } , 010 )

Return()

/*
===============================================================================================================================
Programa----------: AGLT012ATU
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para atualizar a solicita��o com os dados da avalia��o (Aprovar/Reprovar)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012ATU()

Local _oModel	:= FWModelActive()
Local _oView	:= FWViewActive()
Local _lRet		:= .T.
Local _aParAux	:= {}
Local _aParRet	:= {}
Local _aOpcoes	:= { 'Aprovar' , 'Reprovar' }

aAdd( _aParAux , { 2 , "Avalia��o do registro:" , "Aprovar" , _aOpcoes , 65 ,, .T. } ) ; aAdd( _aParRet , '1' )
	
If ParamBox( _aParAux , "InFormar o Status da Avalia��o:" , @_aParRet ,,, .F. ,,,,, .F. )
	If Upper( AllTrim( _aParRet[01] ) ) == 'APROVAR'
	   	_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_STATUS' , "2" )
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_DTAPRO' , ddatabase)
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_USERAP' , _cMatUsr )
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_NUSEAP' , _cNUseAp )
		_oView:Refresh()
	Else
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_STATUS' , "3" )
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_DTAPRO' , ddatabase)
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_USERAP' , _cMatUsr )
		_oModel:LoadValue( 'ZLMMASTER' , 'ZLM_NUSEAP' , _cNUseAp)
		_oView:Refresh()
	EndIf
Else
	_lRet := .F.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT012I
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina para inclus�o m�ltipla de empr�stimos/adiantamentos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012I()

Local _cPerg	:= 'AGLT012I'

If Pergunte(_cPerg)
	Processa( {|| AGLT012DLG() } , 'Aguarde!' , 'Montando a tela de processamento...' )
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AGLT012DLG
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Monta a tela de processamento da inclus�o m�ltipla
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012DLG()

Local _oDlg			:= Nil
Local _oLbxDados	:= Nil
Local _bOk			:= {|x| Processa( {|| AGLT012PRO( _oLbxDados:aArray ) } , 'Aguarde!' , 'Iniciando o processamento...' ) , _oDlg:End() }
Local _bCancel		:= {|x| _oDlg:End() }
Local bExpExcel		:= {|| DlgToExcel( { {"ARRAY","",_oLbxDados:AHeaders,_oLbxDados:aArray} } ) }
Local aPosObj   	:= {}
Local aObjects  	:= {}
Local _aButtons		:= {}
Local aSize     	:= MsAdvSize()
Local cTotReg		:= ""
Local bMntDados		:= {|| Processa({|lEnd| AGLT012SEL( @_oLbxDados , @cTotReg) }) } 
Local aCabecLbx		:= {	"Fornecedor"			,; //01
							"Loja"					,; //02
							"Nome"					,; //03
							"Setor"					,; //04
							"Descri��o"				,; //05
							"Data Inicial"			,; //06
							"Data Final"			,; //07
							"Qtd. Entregue"			,; //08
							"Val. Ref."				,; //09
							"Val. Total"			 } //10

Private	cCadastro	:= 'Inclus�o M�ltipla de Empr�stimos/Adiantamentos'

aAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
aPosObj := MsObjSize( aInfo, aObjects )
                                       
aAdd( _aButtons , { PmsBExcel()[1] , bExpExcel , "Exportar dados para Excel..." , PmsBExcel()[3] } )

DEFINE MSDIALOG _oDlg TITLE cCadastro From aSize[7],000 to aSize[6],aSize[5] Of oMainWnd Pixel
	// Monta ListBox com os dados.
	@aPosObj[01][01]+08,aPosObj[01][02]+3 	Listbox _oLbxDados Fields	;
											HEADER 	""		 			;
											On DbLCLICK ( Nil )			;
											Size aPosObj[01][04]-10,( aPosObj[01][03] - aPosObj[01][01] ) - 10 Of _oDlg Pixel
	
	_oLbxDados:AHeaders := aClone(aCabecLbx)
	
	Eval(bMntDados)
    
	@aPosObj[01][01],aPosObj[01][02] To aPosObj[01][03]+10,aPosObj[01][04] LABEL 'Fornecedores x Entregas' COLOR CLR_HBLUE OF _oDlg PIXEL
	
	_oDlg:lMaximized := .T.
	
ACTIVATE MSDIALOG _oDlg	ON INIT EnchoiceBar(_oDlg,_bOk,_bCancel,,_aButtons) CENTERED

Return()

/*
===============================================================================================================================
Programa----------: AGLT012SEL
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Monta a estrutura de dados para o processamento da inclus�o m�ltipla
Parametros--------: _oLbxAux , cTotReg
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012SEL( _oLbxAux , cTotReg )

Local _aDados	:= {}
Local _cAlias	:= GetNextAlias()

BeginSql alias _cAlias
	SELECT SA2.A2_COD FORNECE, SA2.A2_LOJA LOJA, SA2.A2_NOME NOME, SUM(ZLD_QTDBOM) TOTAL
	FROM %table:ZLD% ZLD, %table:SA2% SA2
	WHERE ZLD.D_E_L_E_T_ = ' '
	AND SA2.D_E_L_E_T_ = ' '
	AND ZLD_FILIAL = %xFilial:ZLD%
	AND A2_FILIAL = %xFilial:SA2%	
	AND A2_COD BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR06%
	AND A2_LOJA BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
	AND A2_MSBLQL  <> '1'
	AND A2_L_ATIVO <> 'N'
	AND ZLD_DTCOLE BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR03%
	AND ZLD_SETOR = %exp:MV_PAR01%
	AND ( CASE WHEN SUBSTR( A2_COD , 1 , 1 ) = 'P' THEN ZLD_RETIRO
			ELSE ZLD_FRETIS END ) = A2_COD
	AND ( CASE WHEN SUBSTR( A2_COD , 1 , 1 ) = 'P' THEN ZLD_RETILJ
			ELSE ZLD_LJFRET END ) = A2_LOJA
	GROUP BY A2_COD, A2_LOJA, A2_NOME
	ORDER BY A2_COD, A2_LOJA
EndSql

While (_cAlias)->( !Eof() )
	aAdd( _aDados , {	(_cAlias)->ForNECE													,;
						(_cAlias)->LOJA														,;
						(_cAlias)->NOME														,;
						MV_PAR01															,;
						AllTrim( Posicione('ZL2',1,xFilial('ZL2')+MV_PAR01,'ZL2_DESCRI') )	,;
						DtoC( MV_PAR02 )													,;
						DtoC( MV_PAR03 )													,;
						TransForm( (_cAlias)->TOTAL				, '@E 999,999,999'		)	,;
						TransForm( MV_PAR09						, '@E 99.99'			)	,;
						TransForm( (_cAlias)->TOTAL * MV_PAR09	, '@E 999,999,999.99'	)	})

	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

If Empty(_aDados)
	_aDados := { { '' , '' , '' , '' , '' , '  /  /' , '  /  /' , '0' , '0,00' , '0,00' } }
EndIf

If ValType(_oLbxAux) == "O"
	_oLbxAux:SetArray(_aDados)
	_oLbxAux:bLine := {||	{	_aDados[_oLbxAux:nAt][01]	,;
								_aDados[_oLbxAux:nAt][02]	,;
								_aDados[_oLbxAux:nAt][03]	,;
								_aDados[_oLbxAux:nAt][04]	,;
								_aDados[_oLbxAux:nAt][05]	,;
								_aDados[_oLbxAux:nAt][06]	,;
								_aDados[_oLbxAux:nAt][07]	,;
								_aDados[_oLbxAux:nAt][08]	,;
								_aDados[_oLbxAux:nAt][09]	,;
								_aDados[_oLbxAux:nAt][10]	}}
	_oLbxAux:Refresh()
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AGLT012PRO
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina de processamento da inclus�o m�ltipla
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012PRO( _aDados )

Local _nI		:= 0
Local _nValTot	:= 0

If !Empty(_aDados)
	ProcRegua( Len(_aDados) )
		
	For _nI := 1 To Len( _aDados )
		IncProc( 'Gravando dados...['+ StrZero(_nI,9) +']' )
		_nValTot := Val( StrTran( StrTran( _aDados[_nI][10] , '.' , '' ) , ',' , '.' ) )
		
		Begin Transaction
			If !Empty(_aDados[_nI][01]) .And. !Empty(_aDados[_nI][02]) .And. _nValTot > 0
				_cCodigo := GetSx8Num("ZLM","ZLM_COD")
				
				ZLM->( DBSetOrder(1) )
				ZLM->( RecLock( 'ZLM' , .T. ) )
					ZLM->ZLM_FILIAL		:= xFilial('ZLM')
					ZLM->ZLM_COD		:= _cCodigo
					ZLM->ZLM_SA2COD		:= _aDados[_nI][01]
					ZLM->ZLM_SA2LJ		:= _aDados[_nI][02]
					ZLM->ZLM_SA2NOM		:= _aDados[_nI][03]
					ZLM->ZLM_DATA		:= dDataBase
					ZLM->ZLM_OBS		:= 'Lan�amento Autom�tico'
					ZLM->ZLM_VENCTO		:= MV_PAR11
					ZLM->ZLM_TOTAL		:= _nValTot
					ZLM->ZLM_PARC		:= 1
					ZLM->ZLM_JUROS		:= 0
					ZLM->ZLM_VLRPAR		:= _nValTot
					ZLM->ZLM_STATUS		:= '1'
					ZLM->ZLM_USER		:= _cMatUsr
					ZLM->ZLM_NUSER		:= _cNUseAp 
					ZLM->ZLM_TIPO		:= IIf(MV_PAR08==1,'E',IIf(MV_PAR08==2,'N',IIf(MV_PAR08==3,'A','P'))) //{'Empr�stimo','Antecipa��o','Adiantamento','Pagamentos'}
					ZLM->ZLM_SETOR		:= MV_PAR01
					ZLM->ZLM_DTCRED		:= MV_PAR10
					ZLM->ZLM_DTLIB		:= LastDay( MonthSub( MV_PAR11 , 1 ) )
					ZLM->ZLM_PAGTO		:= _nValTot
				ZLM->( MsUnlock() )
				ConfirmSx8()
				
				ZLO->( DBSetOrder(1) )
				ZLO->( RecLock( 'ZLO' , .T. ) )
					ZLO->ZLO_FILIAL	:= XFILIAL("ZLO")
					ZLO->ZLO_COD	:= ZLM->ZLM_COD
					ZLO->ZLO_ITEM	:= '001'
					ZLO->ZLO_VECTO	:= ZLM->ZLM_VENCTO
					ZLO->ZLO_VALOR	:= ZLM->ZLM_VLRPAR
				ZLO->( MsUnlock() )
			EndIf
		End Transaction
	Next _nI
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ITVForGP
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: VerIfica se o Fornecedor inFormado atende �s restri��es da rotina
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITVForGP()

Local _lRet		:= .T.
Local _cVarAux	:= &( ReadVar() )

If !( SubStr(_cVarAux,1,1) $ ' GP' )
	Aviso( 'AGLT01209' , 'Para essa rotina � necess�rio inFormar um Fornecedor do Tipo "P" - Produtor ou "G" - Transportador.' , {'Voltar'} )
	_lRet := .F.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT012T
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina de processamento de Avalia��o/Efetiva��o m�ltipla de solicita��es
Parametros--------: _cTpAplic : 1= Avalia��o / 2= Efetiva��o
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012T( _cTpAplic )

Local cLabel	:= ""
Local cVarQ		:= "  "
Local nOpcA		:= 0
Local x			:= 0
Local oDlg		:= Nil
Local oGet01	:= Nil

Private cPerg		:= "AGLT012" 
Private oF3			:= Nil
Private aDados		:= {}
Private oVlrTotal	:= Nil
Private _nVlrTot	:= 0
Private oOk			:= LoadBitmap( GetResources(), "LBOK" )
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )

If !Pergunte(cPerg)
	Return()
EndIf

ZLM->( DbSetOrder(1) )
ZLM->( DbGoTop() )

Processa({|| AGLT012GET( _cTpAplic ) })

If Len( aDados ) == 0
	MsgStop('Nao Foram encontrados registros de solicita��es para o processamento! � preciso que existam solicita��es '	+;
				IIf( _cTpAplic == 1 , '"em aberto"' , '"aprovadas"' )											+;
				' para processar a '+ IIf( _cTpAplic == 1 , '"Avalia��o M�ltipla"' , '"Efetiva��o M�ltipla"' ) +'!.' ,"AGLT01210" )
	Return()
EndIf

aSort( aDados ,,, {|x,y| x[3] < y[3] } )

//====================================================================================================
// Montando o listbox
//====================================================================================================
DEFINE MSDIALOG oDlg TITLE "Emprestimos - "+ IIf( _cTpAplic == 1 , "Aprovar" , "Efetivar" ) From 000,000 To 025,095 OF oMainWnd

	@ 005,005 TO 150,365 LABEL cLabel Pixel OF oDlg
	
	@ 010,010 LISTBOX oF3	VAR cVarQ ;
							Fields HEADER "",OemToAnsi("Solicitacao"),OemToAnsi("Setor"),OemToAnsi("Nome"),OemToAnsi("Valor Total"),OemToAnsi("Parcelas"),OemToAnsi("Juros"),OemToAnsi("Vlr. Parcela"),OemToAnsi("Volume(M�dio)"),OemToAnsi("Renda Liq.(M�dia)"),OemToAnsi("Data 1o. Vencto"),OemToAnsi("Data Credito"),OemToAnsi("Obs.") ;
							COLSIZES 12,25,25,40,25,25,25,25,25,25,25,25,40 ;
							SIZE 350,135 ;
							ON DBLCLICK ( aDados := AGLT012MRK( oF3:nAt , aDados , oGet01 , 1 , 1 ) , oF3:Refresh() , AGLT012RCL( aDados , 5 ) , oVlrTotal:Refresh() ) ;
							PIXEL OF oDlg
	
	oF3:SetArray( aDados )
	oF3:bLine := {|| {	IIf(	aDados[oF3:nAt][01] , oOk , oNo )										,;
								aDados[oF3:nAt][02]														,;
								aDados[oF3:nAt][03]														,;
								aDados[oF3:nAt][11] +'/'+ aDados[oF3:nAt,12] +' - '+ aDados[oF3:nAt,4]	,;
								aDados[oF3:nAt][05]														,;
								aDados[oF3:nAt][06]														,;
								aDados[oF3:nAt][07]														,;
								aDados[oF3:nAt][08]														,;
								aDados[oF3:nAt][09]														,;
								aDados[oF3:nAt][10]														,;
					DtoC( StoD(	aDados[oF3:nAt][13] ) )													,;
					DtoC( StoD(	aDados[oF3:nAt][14] ) )													,;
								aDados[oF3:nAt][15]														}}
	
	oF3:bHeaderClick := {|| AGLT012MTD() , oF3:Refresh() }
	
	DEFINE SBUTTON FROM 160,010 TYPE 01 ACTION Processa( {|| nOpca := 1 , AGLT012APR( aDados , _cTpAplic ) , oDlg:End() } )	ENABLE OF oDlg
	DEFINE SBUTTON FROM 160,050 TYPE 02 ACTION ( nOpca := 0 , oDlg:End() )													ENABLE OF oDlg
	
	@160,090 Button	OemToAnsi( "Visualizar"			) Size 50,11 OF oDlg PIXEL Action {|| ZLM->(DBSeek(xFilial("ZLM")+aDados[oF3:nAt][02])),FWExecView( '[ Avalia��o da Solicita��o ]' , 'AGLT012' , 1 ,, {|| .T. } ,, 010 ) }
	@160,150 Button	OemToAnsi( "Imprimir"			) Size 50,11 OF oDlg PIXEL Action {|| U_RGLT030( aDados ) }
	@160,210 Button	OemToAnsi( "An�lise Financeira"	) Size 50,11 OF oDlg PIXEL Action {|| U_RGLT045( aDados[oF3:nAt][11] , aDados[oF3:nAt][12] ) }
	
	@162,280 SAY	"Valor Total:"															OF oDlg PIXEL
	@160,310 MSGET	oVlrTotal VAR _nVlrTot PICTURE "@E 99,999,999.99" WHEN .F. SIZE 50,10	OF oDlg PIXEL
	
	@175,010 SAY	"As linhas que n�o vieram marcadas � devido aos 50 % da m�dia dos 3 �ltimos pagamentos para o Fornecedor n�o ser maior que a sua solicita��o." COLORS 255, 16777215 Pixel OF oDlg
	
	// Calcula total dos selecionados
	AGLT012RCL( aDados , 5 )
	oVlrTotal:Refresh()

ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*
===============================================================================================================================
Programa----------: AGLT012E
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina de processamento do Estorno de processamentos das solicita��es
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function AGLT012E()

Local nParcelas	:= 0
Local _lOk		:= .T.

If ZLM->ZLM_STATUS <> "4" .And. ZLM->ZLM_STATUS <> "2"
	MsgStop("Essa solicitacao nao pode ser Estornada por nao ter sido Efetivada/Aprovada!","AGLT01211")
	Return()
EndIf

//====================================================================================================
// Status Efetivado
//====================================================================================================
If ZLM->ZLM_STATUS == '4'
	// Obtendo Parametos dos EMPRESTIMOS
	If ZLM->ZLM_TIPO == 'E'
		_cPrefixo:= SuperGetMV("LT_EMPPRE",.F.,"GLE")
		If Left( ZLM->ZLM_SA2COD , 1 ) == 'P'
			_cNaturez	:= SuperGetMV("LT_EMPNAT1",.F.,"222003")
		Else
			_cNaturez	:= SuperGetMV("LT_EMPNAT2",.F.,"222005")		
		EndIf
	// Obtendo Parametos dos ADIANTAMENTOS
	ElseIf ZLM->ZLM_TIPO == 'A'
		_cPrefixo := SuperGetMV("LT_ADTPRE",.F.,"GLA")
		If Left( ZLM->ZLM_SA2COD , 1 ) == "P"
			_cNaturez	:= SuperGetMV("LT_EMPNAT1",.F.,"222003")
		Else
			_cNaturez	:= SuperGetMV("LT_EMPNAT2",.F.,"222003")
		EndIf
	// Obtendo Parametos das ANTECIPACOES  
	ElseIf ZLM->ZLM_TIPO == "N"
		_cPrefixo := SuperGetMV("LT_ANTPRE",.F.,"GLN")
		If left(ZLM->ZLM_SA2COD,1) == "P"
			_cNaturez	:= SuperGetMV("LT_ANTNAT1",.F.,"222052")
		Else
			_cNaturez	:= SuperGetMV("LT_ANTNAT2",.F.,"222071")
		EndIf
	// Obtendo Parametos das ANTECIPACOES  
	ElseIf ZLM->ZLM_TIPO == "P"
		_cPrefixo := SuperGetMV("LT_PAGPRE",.F.,"GUB")
		If left(ZLM->ZLM_SA2COD,1) == "P"
			_cNaturez	:= SuperGetMV("LT_PAGNAT1",.F.,"211023")
		Else
			_cNaturez	:= SuperGetMV("LT_PAGNAT2",.F.,"211023")
		EndIf
	EndIf
	
	If !MsgYesNo( "Essa rotina ir� cancelar a efetivacao dessa solicitacao. Deseja continuar?" )
		Return()
	EndIf
	
	Begin Transaction
    	
    	//====================================================================================================
	    // Deleta o T�tulo no Financeiro
	    //====================================================================================================
	   	If AGLT012DE2( _cPrefixo , ZLM->ZLM_COD , padr("1",TamSx3("E2_PARCELA")[1]) , "NF " , ZLM->ZLM_SA2COD , ZLM->ZLM_SA2LJ , _cNaturez )
	   		// Deleta as Parcelas
			If ZLM->ZLM_TIPO <> 'P' //Pagamentos n�o possuem NDF
				For nParcelas := 1 To Int( ZLM->ZLM_PARC )
					If !AGLT012DE2( _cPrefixo , ZLM->ZLM_COD , PadR(AllTrim(Str(nParcelas)) , TamSx3("E2_PARCELA")[1]) , "NDF" , ZLM->ZLM_SA2COD , ZLM->ZLM_SA2LJ , _cNaturez )
						_lOk := .F.
					EndIf
				Next nParcelas
	   		EndIf
	   	Else
		   	_lOk := .F.
	   	EndIf
		
		If _lOk
	  		ZLM->( RecLock( 'ZLM' , .F. ) )
		    ZLM->ZLM_STATUS := '2'
		    ZLM->( MsUnLock() )
		Else
			MsgStop("Falha ao processar a exclus�o dos T�tulos no Financeiro! InForme a �rea de TI/ERP.","AGLT01212")
		    DisarmTransaction()
		EndIf
	End Transaction

//====================================================================================================
// Status Aprovado
//====================================================================================================
ElseIf ZLM->ZLM_STATUS == '2'
	If !MsgYesNo( "Essa rotina ir� cancelar a aprova��o dessa solicitacao. Deseja continuar?" )
		Return()
	EndIf

	ZLM->( RecLock( 'ZLM' , .F. ) )
	    ZLM->ZLM_STATUS := '1'
	    ZLM->ZLM_DTAPRO := StoD('')
	    ZLM->ZLM_USERAP	:= ''
	    ZLM->ZLM_NUSEAP	:= ''
    ZLM->( MsUnLock() )
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AGLT012DE2
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina para processar a exclus�o de t�tulos no Financeiro
Par�metros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function AGLT012DE2( _cPrefixo , _cNum , _cParcela , _cTipo , _cForn , _cLoja , _cNaturez )

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
		MsgStop("Falha ao processar a exclus�o do T�tulo: ("+ _cPrefixo +"-"+ _cNum +"-"+ _cForn +")! InForme a �rea de TI/ERP.","AGLT01213")
		mostraerro()
		_lOk := .F.
	EndIf
Else
	MsgStop("T�tulo n�o encontrado: ("+_cPrefixo+_cNum+_cParcela+_cTipo+_cForn+_cLoja+")! InForme a �rea de TI/ERP.","AGLT01214")
	_lOk := .F.
EndIf

nModulo := _nModAux
cModulo := _cModAux

Return( _lOk )

/*
===============================================================================================================================
Programa----------: AGLT012GET
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina que verIfica e monta a estrutura de dados para o processamento
Parametros--------: _cTpAplic = 1-Em aberto 2-Aprovada
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012GET( _cTpAplic )

Local _nQtdReg	:= 0
Local _cXtipo	:= ''
Local _cAlias	:= GetNextAlias()

Do Case
	Case MV_PAR06 == 1 // Emprestimo
		_cXtipo := "E"
	Case MV_PAR06 == 2 // Antecipacao
		_cXtipo := "N"
	Case MV_PAR06 == 3 // Adiantamento
		_cXtipo := "A"
	OtherWise
		_cXtipo := "P" // Pagamentos
EndCase

BeginSql alias _cAlias
	SELECT ZLM_SETOR, ZL2_DESCRI, ZLM_COD, ZLM_SA2COD, ZLM_SA2LJ, A2_NOME, ZLM_TOTAL, ZLM_JUROS, ZLM_JUROS, ZLM_VLRPAR, ZLM_VENCTO, ZLM_DTCRED, ZLM_OBS, ZLM_PARC,
	(SELECT ROUND(NVL(AVG(VOL),0),2) 
		FROM (SELECT ZLE_COD, SUM(ZLD_QTDBOM) VOL
			FROM %Table:ZLD% ZLD,
				(SELECT ZLE_COD, ZLE_DTINI, ZLE_DTFIM FROM %Table:ZLE%
					WHERE D_E_L_E_T_ = ' '
					AND ZLE_STATUS = 'F'
					ORDER BY ZLE_DTINI DESC
					FETCH FIRST 3 ROWS ONLY)
			WHERE ZLD.D_E_L_E_T_ = ' '
			AND ZLD_DTCOLE BETWEEN ZLE_DTINI AND ZLE_DTFIM
			AND ZLD_FILIAL = ZL2_FILIAL
			AND ZLD_RETIRO = A2_COD
			AND ZLD_RETILJ = A2_LOJA
			GROUP BY ZLE_COD)) MEDIA_VOL,
	(SELECT ROUND(NVL(AVG(VALOR),0), 2) 
		FROM (SELECT ZLE_COD, SUM(CASE WHEN ZLF_DEBCRE = 'C' THEN ZLF_TOTAL ELSE ZLF_TOTAL * -1 END) VALOR
			FROM %Table:ZLF% ZLF,
				(SELECT ZLE_COD FROM %Table:ZLE%
					WHERE D_E_L_E_T_ = ' '
					AND ZLE_STATUS = 'F'
					ORDER BY ZLE_COD DESC
					FETCH FIRST 3 ROWS ONLY)
			WHERE ZLF.D_E_L_E_T_ = ' '
			AND ZLF_CODZLE = ZLE_COD
			AND ZLF_FILIAL = ZL2_FILIAL
			AND ZLF_A2COD = A2_COD
			AND ZLF_A2LOJA = A2_LOJA
			GROUP BY ZLE_COD)) MEDIA_VALOR
	FROM %table:ZLM% ZLM, %table:SA2% SA2, %table:ZL2% ZL2
	WHERE ZLM.D_E_L_E_T_ = ' '
	AND SA2.D_E_L_E_T_ = ' '
	AND ZL2.D_E_L_E_T_ = ' '
	AND A2_COD = ZLM_SA2COD
	AND A2_LOJA = ZLM_SA2LJ
	AND ZLM_FILIAL = %xFilial:ZLN%
	AND ZLM_FILIAL = ZL2_FILIAL
	AND ZLM_SETOR = ZL2_COD
	AND ZLM_STATUS = %exp:cValToChar(_cTpAplic)%
	AND ZLM_DATA   BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR03%
	AND ZLM_COD	BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
	AND ZLM_TIPO = %exp:_cXtipo%
	AND ZLM_SETOR  = %exp:MV_PAR01%
EndSql

Count to _nQtdReg

ProcRegua( _nQtdReg )

(_cAlias)->( DBGoTop() )
While (_cAlias)->( !Eof() )
	IncProc()
	aAdd( aDados , {	IIf( ( (_cAlias)->MEDIA_VALOR * 0.5 ) > (_cAlias)->ZLM_VLRPAR , .T. , .F. )	,; //01
						(_cAlias)->ZLM_COD											   	,; //02
						(_cAlias)->ZL2_DESCRI											,; //03
						(_cAlias)->A2_NOME												,; //04
						(_cAlias)->ZLM_TOTAL											,; //05
						(_cAlias)->ZLM_PARC												,; //06
						(_cAlias)->ZLM_JUROS											,; //07
						(_cAlias)->ZLM_VLRPAR											,; //08
						(_cAlias)->MEDIA_VOL											,; //09
						(_cAlias)->MEDIA_VALOR											,; //10
						(_cAlias)->ZLM_SA2COD											,; //11
						(_cAlias)->ZLM_SA2LJ											,; //12
						(_cAlias)->ZLM_VENCTO											,; //13
						(_cAlias)->ZLM_DTCRED											,; //14
						(_cAlias)->ZLM_OBS												}) //15
	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

Return()

/*
===============================================================================================================================
Programa----------: AGLT012RCL
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina que recalcula o totalizador de acordo com os registros selecionados
Parametros--------: _aLista    - Lista de dados
------------------: _nPosTotal - Posi��o do valor que deve ser totalizado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012RCL( _aLista , _nPosTotal )

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
Programa----------: AGLT012APR
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina que processa a grava��o das Avalia��es/Efetiva��es
Parametros--------: _aGrava	- Dados para a grava��o
------------------: _cTipo	- Tipo de Processamento ( 1 - Aprova��o / 2 - Efetiva��o )
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012APR( _aGrava , _cTipo )

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
			ZLM->( DBSetorder(1) )
			If ZLM->( DBSeek( XFILIAL("ZLM") + _aGrava[_nI][02] ) )
				//====================================================================================================
				// Valida a data de libera��o para n�o dar erro no ExecAuto
				//====================================================================================================
				If _cTipo == 2
					IF dDataBase < _dMV_DATAFIN
						MsgStop("N�o � poss�vel efetivar a solicita��o ["+ ZLM->ZLM_COD +"]!"+ CRLF			 																		+;
									"A data de Efetiva��o ["+ DtoC( dDataBase ) +"] � anterior � data Limite Cont�bil para lan�amentos Financeiros ["+ DtoC(_dMV_DATAFIN) +"]."	,;
									"AGLT01215")
						_lValid := .F.
					EndIf
					
					If _lValid .And. dDataBase > ZLM->ZLM_VENCTO
						MsgStop("N�o � poss�vel efetivar a solicita��o ["+ ZLM->ZLM_COD +"]!"+ CRLF+;
									"A data de Efetiva��o ["+ DtoC( dDataBase ) +"] � posterior � data do 1� Vencimento configurada ["+ DtoC( ZLM->ZLM_VENCTO ) +"]."	,;
									"AGLT01216")
						_lValid := .F.
					EndIf
				EndIf
				
				If _lValid
					ZLM->( RecLock( "ZLM" , .F. ) )
						If _cTipo == 1 // aprovar
							ZLM->ZLM_STATUS := "2"
							ZLM->ZLM_DTAPRO := ddatabase
							ZLM->ZLM_USERAP := _cMatUsr
							ZLM->ZLM_NUSEAP := _cNUseAp
						ElseIf _cTipo == 2 // efetivar
							ZLM->ZLM_DTLIB	:= dDataBase
							
							aTCab	:= { ZLM->ZLM_COD , ZLM->ZLM_SA2COD , ZLM->ZLM_SA2LJ , ZLM->ZLM_TOTAL , ZLM->ZLM_DTLIB , ZLM->ZLM_TIPO , ZLM->ZLM_DATA , ZLM->ZLM_DTCRED }
							aTItens	:= {}
							
							ZLO->( DBSetOrder(1) )
							ZLO->( DBSeek( XFILIAL("ZLM") + ZLM->ZLM_COD ) )
							While ZLO->( !Eof() ) .And. XFILIAL("ZLM") + ZLM->ZLM_COD == ZLO->(ZLO_FILIAL+ZLO_COD)
								aAdd( aTItens , { ZLO->ZLO_VECTO , ZLO->ZLO_VALOR } )
								ZLO->( DBSkip() )
							EndDo
							
							lOk := .T.
							lOk := AGLT012IE2(aTCab,aTItens)
						EndIf
					ZLM->( MSUNLOCK() )
				EndIf
			EndIf
		
		//====================================================================================================
		// Processa os registros n�o selecionados - Reprovar
		//====================================================================================================
		Else
			ZLM->( DBSetorder(1) )
			If ZLM->( DBSeek( XFILIAL("ZLM") + _aGrava[_nI][02] ) )
				ZLM->( RECLOCK( "ZLM" , .F. ) )
					ZLM->ZLM_DTAPRO := ddatabase
					ZLM->ZLM_STATUS := "3"
					ZLM->ZLM_USERAP := _cMatUsr
					ZLM->ZLM_NUSEAP := _cNUseAp
				ZLM->( MSUNLOCK() )
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
Programa----------: AGLT012MTD
Autor-------------: Alexandre Villar
Data da Criacao---: 27/11/2014
Descri��o---------: Rotina que processa a invers�o da sele��o ao clicar no cabe�alho do ListBox
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012MTD()

Local _nI := 0

For _nI := 1 To Len( aDados )
	aDados[_nI][01] := !aDados[_nI][01]
Next _nI

oF3:Refresh()

AGLT012RCL( aDados , 5 )

oVlrTotal:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: AGLT012IE2
Autor-------------: Abrahao
Data da Criacao---: 29/09/2008
Descri��o---------: Cria titulos no contas a receber referentes ao emprestimo
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012IE2( aCab , aItens )

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

// Obtendo Parametos dos EMPRESTIMOS
If aCab[6] == 'E'
	_cPrefixo:= SuperGetMV("LT_EMPPRE",.F.,"GLE")
	_DescHist := "EMPRESTIMO"
	If left(aCab[2],1) == "P"
		_cNaturez	:= SuperGetMV("LT_EMPNAT1",.F.,"222003")
	Else
		_cNaturez	:= SuperGetMV("LT_EMPNAT2",.F.,"222005")
	EndIf
// Obtendo Parametos dos ADIANTAMENTOS
ElseIf aCab[6] == "A"
	_cPrefixo := SuperGetMV("LT_ADTPRE",.F.,"GLA")
	_DescHist := "ADIANTAMENTO"
	If left(aCab[2],1) == "P"
		_cNaturez	:= SuperGetMV("LT_EMPNAT1",.F.,"222003")
	Else
		_cNaturez	:= SuperGetMV("LT_EMPNAT2",.F.,"222003")
	EndIf
// Obtendo Parametos das ANTECIPACOES  
ElseIf aCab[6] == "N"
	_cPrefixo := SuperGetMV("LT_ANTPRE",.F.,"GLN")
	_DescHist := "ANTECIPACAO"
	If left(aCab[2],1) == "P"
		_cNaturez	:= SuperGetMV("LT_ANTNAT1",.F.,"222052")
	Else
		_cNaturez	:= SuperGetMV("LT_ANTNAT2",.F.,"222071")
	EndIf
// Obtendo Parametos dos PAGAMENTOS
ElseIf aCab[6] == "P"
	_cPrefixo := SuperGetMV("LT_PAGPRE",.F.,"GUB")
	_DescHist := "ANTECIPACAO"
	If left(aCab[2],1) == "P"
		_cNaturez	:= SuperGetMV("LT_PAGNAT1",.F.,"211023")
	Else
		_cNaturez	:= SuperGetMV("LT_PAGNAT2",.F.,"211023")
	EndIf
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
		If aCab[6] <> "P" //Para P-Pagamentos s� deve ser gerada a NF
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
				AAdd( _aAutoSE2 , { "E2_HIST"		, "GLT "+_DescHist+" PROPRIO " + AllTrim( STR( _nI ) ) +"/"+ AllTrim( STR( Len( aItens ) ) ) , Nil } )
				AAdd( _aAutoSE2 , { "E2_DATALIB"	, aCab[7]			, nil } )
				AAdd( _aAutoSE2 , { "E2_USUALIB"	, cUserName			, nil } )
				AAdd( _aAutoSE2 , { "E2_ACRESC"		, Round( aItens[_nI][02] - nValor , 2 )			, nil } )
				AAdd( _aAutoSE2 , { "E2_L_SETOR"	, MV_PAR01			, nil } )
				AAdd( _aAutoSE2 , { "E2_ORIGEM"		, "AGLT012"			, nil } )
				
				lMsErroAuto := .F.
				
				_nModAux	:= nModulo
				_cModAux	:= cModulo
				
				nModulo		:= 6
				cModulo		:= "FIN"
				
				MSExecAuto({|x,y| Fina050(x,y)},_aAutoSE2,3) //Inclusao
				
				If lMsErroAuto
					lok1 := .F.
					MsgStop("Erro ao gravar o Titulo: ("+ _cPrefixo +"-"+ aCab[1] +")! Comunique a �rea de TI/ERP.","AGLT01217")
					mostraerro()
				EndIf
				
				nModulo := _nModAux
				cModulo := _cModAux
			Next _nI
		EndIf
			
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
		AAdd( _aAutoSE2 , { "E2_HIST"		,"GLT "+_DescHist+" PROPRIO"	, nil } )
		AAdd( _aAutoSE2 , { "E2_L_SETOR"	,MV_PAR01						, nil } )
		AAdd( _aAutoSE2 , { "E2_ORIGEM"		, "AGLT012"						, nil } )
		
		lMsErroAuto	:= .F.
		
		_nModAux	:= nModulo
		_cModAux	:= cModulo
		
		nModulo		:= 6
		cModulo		:= "FIN"
		
		MSExecAuto({|x,y| Fina050(x,y)},_aAutoSE2,3) //Inclusao
		
		If lMsErroAuto
			lok2 := .F.
			MsgStop("Erro ao gravar o Titulo: ("+ _cPrefixo +"-"+ aCab[1] +")! Comunique a �rea de TI/ERP.","AGLT01218")
			mostraerro()
		EndIf  		
		
		nModulo := _nModAux
		cModulo := _cModAux
	Else
		MsgStop("J� foram encontrados t�tulos para esse fornecedor e o processo ser� abortado. Acione a TI/Sistemas.","AGLT01219")
		lok1 := .F.
	EndIf
	(_cAlias)->(DbCloseArea())

	If lok1 .and. lok2
		//====================================================================================================
		// Grava solicita��o como efetivada
		//====================================================================================================
		ZLM->( DBSetorder(1) )
		If ZLM->( DBSeek( xFilial('ZLM') + aCab[1] ) )
			ZLM->( RecLock( 'ZLM' , .F. ) )
			ZLM->ZLM_STATUS := "4"
			ZLM->( MsUnlock() )
		Else
			MsgStop("Erro ao gravar o Status na Solicita��o: ("+ aCab[1] +")! Comunique a �rea de TI/ERP.","AGLT01220")
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
Programa----------: AGLT012MRK
Autor-------------: Abrahao
Data da Criacao---: 29/09/2008
Descri��o---------: Rotina que realiza a marca��o dos registros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT012MRK( nIt , aArray , oGet , nOpc , nPos )

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
Programa----------: AGLT012V
Autor-------------: Abrahao
Data da Criacao---: 29/09/2008
Descri��o---------: Rotina que realiza datas
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012V()

Local _lRet		:= .T.
Local _cCampo	:= ReadVar()
Local _dDtAux	:= &( _cCampo )

If Upper( AllTrim( _cCampo ) ) == "M->ZLM_DTCRED"
	If _dDtAux < dDataBase
		MsgStop("N�o � permitido informar uma data de cr�dito menor que a data atual! Verique as datas informadas!","AGLT01221")
		_lRet := .F.
	ElseIf !Empty(M->ZLM_VENCTO) .And. _dDtAux > M->ZLM_VENCTO
		MsgStop("N�o � permitido informar uma data de Cr�dito maior que a data de vencimento! Verique as datas informadas!","AGLT01222")
		_lRet := .F.
	EndIf
EndIf

If Upper( AllTrim( _cCampo ) ) == "M->ZLM_VENCTO"
	If _dDtAux < M->ZLM_DTCRED
		MsgStop("N�o � permitido informar uma data de 1� vencimento menor que a data do Cr�dito! Verique as datas informadas!","AGLT01223")	
		_lRet := .F.
	EndIf
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT012B
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Rotina que possibilita realizar a transferencia do emprestimo para determinado produtor informado.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012B()

Local oDlg		:= Nil
Local oGDescri	:= Nil
Local oGEmprest	:= Nil
Local oGFornec	:= Nil
Local oGLjForn	:= Nil
Local oMObs		:= Nil
Local oPriVenct	:= Nil
Local oGSetor	:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oSay3		:= Nil
Local oSay4		:= Nil
Local oSay5		:= Nil
Local oSay6		:= Nil
Local oSay7		:= Nil
Local oFont12b	:= Nil
Local nopc		:= 0  
Local _aArea	:= GetArea()       
Local lVldTrans	:= .F.   
Local cGDescri	:= Space(70)

Private cGEmprest	:= Space(09)
Private cGFil		:= Space(02)
Private cGFornec	:= Space(06)
Private cGLjForn	:= Space(04)  
Private cMObs		:= ""    
Private dDtPriVen	:= dDataBase
Private cGSetor		:= Space(06)      
Private oSDescSet	:= Nil
Private _cDescSet	:= "" 
Private _cCodOrig	:= ""	// Armazena o codigo do fornecedor do emprestimo de origem
Private _cljOrig	:= ""	// Armazena o codigo da loja do fornecedor do emprestimo de origem  
Private _nJuros		:= 0	// Armazena o % de juros para replicar para o emprestimo de destino 
Private _aTitulos	:= {}	// Armazena os t�tulos e suas parcelas com os respectivos valores    
Private lDeuErro	:= .F.	// Controla se deu erro em algum ponto do sistema
Private _cTipo		:= ""
Private _cZLMTipo	:= ""
Define Font oFont12b   Name "Courier New"       Size 0,-12 Bold  // Tamanho 12 Negrito

// Monta tela para configura��o da transfer�ncia
DEFINE MSDIALOG oDlg TITLE "Transfer�ncia de Empr�stimos" FROM 000,000 TO 350,425 COLORS 0,16777215 PIXEL

    @ 039, 012 SAY oSay1     PROMPT "Empr�stimo:"			SIZE 031,007 OF oDlg COLORS 0,16777215 PIXEL
	@ 039, 120 SAY oSay1     PROMPT "Filial Dest.:"			SIZE 031,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 059, 012 SAY oSay2     PROMPT "Fornecedor:"			SIZE 031,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 059, 120 SAY oSay3     PROMPT "Loja:"       			SIZE 025,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 079, 012 SAY oSay5     PROMPT "Descri��o:"  			SIZE 025,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 099, 012 SAY oSay4     PROMPT "Setor:"      			SIZE 025,007 OF oDlg COLORS 0,16777215 PIXEL
	@ 099, 120 SAY oSDescSet PROMPT SubStr(_cDescSet,1,24)	SIZE 175,009 OF oDlg COLORS 0,16777215 PIXEL FONT oFont12b
    @ 119, 012 SAY oSay6     PROMPT "1 Vencto: "  			SIZE 030,007 OF oDlg COLORS 0,16777215 PIXEL
    @ 139, 012 SAY oSay7     PROMPT "Observa��o:"			SIZE 030,007 OF oDlg COLORS 0,16777215 PIXEL
    
    @ 035, 044 MSGET oGEmprest VAR cGEmprest	SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL F3 "ZLM" Valid !Empty(cGEmprest) .And. ExistCPO("ZLM", cGEmprest, 1) 
	@ 035, 145 MSGET oGEmprest VAR cGFil		SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SM0" Valid !Empty(cGFil) .And. ExistCPO("SM0", cEmpAnt+cGFil, 1) 
    @ 055, 044 MSGET oGFornec  VAR cGFornec		SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SA2" Valid !Empty(cGFornec) .And. AGLT012VLF(cGFornec, @cGLjForn, @cGDescri)
    @ 055, 145 MSGET oGLjForn  VAR cGLjForn		SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL Valid !Empty(cGLjForn) .And. AGLT012VLF(cGFornec, @cGLjForn, @cGDescri)
    @ 075, 044 MSGET oGDescri  VAR cGDescri		SIZE 160,010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
    @ 095, 044 MSGET oGSetor   VAR cGSetor		SIZE 060,010 OF oDlg VALID !Empty(cGSetor) .And. validSetor() F3 "ZL2_01" PIXEL
    @ 115, 044 MSGET oPriVenct VAR dDtPriVen	SIZE 060,010 OF oDlg COLORS 0, 16777215 PIXEL Valid !Empty(dDtPriVen)
    @ 135, 044 GET	 oMObs     VAR cMObs		SIZE 160,033 OF oDlg MULTILINE COLORS 0, 16777215 HSCROLL PIXEL Valid !Empty(cMObs)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| MsgRun("Realizando a valida��o da transfer�ncia...",,{||CursorWait(),lVldTrans:=VldTransf(cGEmprest,cGFornec,cGLjForn,cMObs,dDtPriVen,cGSetor,cGFil),CursorArrow()}),IIf(lVldTrans,Eval({|| nopc:=1,oDlg:End()}),)}, {||oDlg:End()},,)    

// Caso confirmado, processa a transfer�ncia
If nopc == 1
 	MsgRun( "Processando a transfer�ncia..." , 'Aguarde!' , {|| CursorWait() , ProcTransf() , CursorArrow() } )
EndIf

RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: VldTransf
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Rotina que valida os dados informados pelo usu�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VldTransf( cCodEmpres , cCodForn , cLjForn , cObs , dt1Vencto , cCodSetor , cGfil )
      
Local _lRet		:= .T.
Local _cAlias	:= GetNextAlias()
Local _cFilOri 	:= cFilAnt

cFilAnt := cGfil

If dt1Vencto < dDataBase
	MsgStop("A data do primeiro vencimento n�o pode ser menor que a data atual!","AGLT01224")
	_lRet := .F.
Else
	//============================================================================================
	// Verifica se o setor informado para um produtor � o mesmo da linha informada no seu cadastro
	//============================================================================================
	If SubStr( cGFornec , 1 , 1 ) == 'P'
		If cGSetor <> Posicione( "ZL3" , 1 , xFilial("ZL3") + SA2->A2_L_LI_RO , "ZL3->ZL3_SETOR" )
			MsgStop( "O produtor informado como destinat�rio n�o pertence ao Setor informado!","AGLT01225")
			_lRet := .F.
		EndIf
	EndIf
EndIf
			
ZLM->( DBSetOrder(1) )
ZLM->(DBSeek( _cFilOri + cCodEmpres ))
	_cCodOrig	:= ZLM->ZLM_SA2COD 
	_cljOrig	:= ZLM->ZLM_SA2LJ
	_nJuros		:= ZLM->ZLM_JUROS
	_cZLMTipo	:= ZLM->ZLM_TIPO

	// Obtendo Parametos dos EMPRESTIMOS
	If ZLM->ZLM_TIPO == 'E'
		_cPrefixo:= SuperGetMV("LT_EMPPRE",.F.,"GLE")
		_cTipo	:= "Empr�stimo"
		If Left( ZLM->ZLM_SA2COD , 1 ) == 'P'
			_cNaturez	:= SuperGetMV("LT_EMPNAT1",.F.,"222003")
		Else
			_cNaturez	:= SuperGetMV("LT_EMPNAT2",.F.,"222005")
		EndIf
	// Obtendo Parametos dos ADIANTAMENTOS
	ElseIf ZLM->ZLM_TIPO == 'A'
		_cPrefixo := SuperGetMV("LT_ADTPRE",.F.,"GLA")
		_cTipo	:= "Adiantamento"
		If Left( ZLM->ZLM_SA2COD , 1 ) == "P"
			_cNaturez	:= SuperGetMV("LT_EMPNAT1",.F.,"222003")
		Else
			_cNaturez	:= SuperGetMV("LT_EMPNAT2",.F.,"222003")
		EndIf
	// Obtendo Parametos das ANTECIPACOES  
	ElseIf ZLM->ZLM_TIPO == "N"
		_cPrefixo := SuperGetMV("LT_ANTPRE",.F.,"GLN")
		_cTipo	:= "Antecipa��o"
		If left(ZLM->ZLM_SA2COD,1) == "P"
			_cNaturez	:= SuperGetMV("LT_ANTNAT1",.F.,"222052")
		Else
			_cNaturez	:= SuperGetMV("LT_ANTNAT2",.F.,"222071")
		EndIf
	EndIf
//================================================
// Valida se est� efetivado
//================================================
If _lRet .And. !(ZLM->ZLM_STATUS == '4')
	MsgStop("Somente " + _cTipo + " efetivado(a) pode ser transferido(a)!","AGLT01226")
	_lRet := .F.
EndIf	

//======================================================================================
// Verifica se foi informado o mesmo Fornecedor no emprestimo de origem com o de destino
//======================================================================================
If _lRet .And. cCodForn + cLjForn == ZLM->( ZLM_SA2COD + ZLM_SA2LJ ) .And. cCodSetor == ZLM->ZLM_SETOR
	MsgStop("N�o � poss�vel transferir um(a) " + _cTipo + "  para o mesmo Fornecedor e Setor j� registrado!","AGLT01227")
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
	    AND SE2.E2_FILIAL = %exp:_cFilOri%
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
				"o(a) " + _cTipo + "  atual e inclu�do um novo manualmente para o fornecedor desejado.","AGLT01228")
		_lRet := .F.
	EndIf
	
	(_cAlias)->( DBCloseArea() )

EndIf

cFilAnt := _cFilOri

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ProcTransf
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Rotina que processa a transfer�ncia do empr�stimo
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ProcTransf()

Local _cAlias		:= GetNextAlias()
Local _nSaldoTit	:= 0
Local _nY			:= 0
Local _cFilOri		:= cFilAnt

Private nTotSaldo	:= 0
Private _nTotAcDc	:= 0
Private _nCodEmp	:= 0

//========================================================
// Verifica as NDF dos titulos do emprestimo no financeiro
//========================================================
BeginSql Alias _cAlias

SELECT E2_FILIAL, E2_PREFIXO, E2_TIPO, E2_NUM, E2_PARCELA, SE2.E2_FORNECE, E2_LOJA, A2_NOME, E2_TXMOEDA, E2_BAIXA,
       E2_NATUREZ, E2_VENCREA, E2_SALDO, E2_SDACRES, E2_SDDECRE, E2_VALOR, E2_DECRESC, E2_ACRESC, E2_VALJUR, E2_PORCJUR,
       E2_EMISSAO, E2_VENCTO, E2_DATALIB, SE2.R_E_C_N_O_ RECNOSE2
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
			"Para esse caso dever� ser exclu�do o(a) " + _cTipo + "  atual e inclu�do um novo manualmente para o fornecedor desejado.","AGLT01229")
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
			cFilAnt := cGFil
			//===================================================
			// Seleciona o codigo do novo emprestimo a ser gerado
			//===================================================
        	_nCodEmp := GetSx8Num("ZLM","ZLM_COD")
        	
        	//==============================
        	// Insere os dados do emprestimo
        	//==============================
        	MsgRun( "Processando a inclus�o do novo(a) " + _cTipo + " ..." , 'Aguarde!' , {|| CursorWait() , incEmprest(_cFilOri) , CursorArrow() } )
        	
			//=============================================================
			// Se nao ocorrer erro abre para visualizacao o novo emprestimo
			//=============================================================
        	If !lDeuErro
        		
				//=============================================
        		// Seta o emprestimo de origem como transferido
				//=============================================
        		ZLM->( DBSetOrder(1) )
        		If ZLM->( DBSeek( _cFilOri + cGEmprest ) )
        			ZLM->(RecLock( "ZLM" , .F. ))
					ZLM->ZLM_STATUS := "5"
					ZLM->ZLM_CODTRA := _nCodEmp
					ZLM->ZLM_FILTRA := cFilAnt
					ZLM->ZLM_USRTRA := _cMatUsr
					ZLM->ZLM_DATTRA := Date()
					ZLM->ZLM_HORTRA := Time()
					ZLM->ZLM_OBSTRA := cMObs
        			ZLM->( MsUnlock() )
        		EndIf
        		
       			MsgRun( "Processando inclus�es no Financeiro..." , 'Aguarde!' , {|| CursorWait() , IncSE2(_cFilOri) , CursorArrow() } )
        		
        		//===========================================================
       			// Se nao ocorrer erro na inclusao das NDF do novo emprestimo
       			//===========================================================
	        	If !lDeuErro
	        		ConfirmSX8()
	        		MsgInfo("A transfer�ncia do(a) " + _cTipo + "  foi realizada com sucesso!","AGLT01230")
	        	Else
	        		RollBackSX8()
	        		DisarmTransaction()
	        	EndIf
		        
		    Else
			    RollBackSX8()
		    	DisarmTransaction()
        	EndIf
			cFilAnt := _cFilOri
        EndIf
	
	End Transaction

EndIf

Return()

/*
===============================================================================================================================
Programa----------: BaixaSE2
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Rotina que processa as baixas de T�tulos via ExecAuto
Parametros--------: Nenhum
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
			" Ap�s confirmar esta tela, sera apresentada a tela de N�o Conformidade do SigaAuto.","AGLT01231")
	MostraErro()
EndIf

Return

/*
===============================================================================================================================
Programa----------: incEmprest
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Rotina que processa a inclus�o de empr�stimos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function incEmprest(_cFilOri)

Local _nX := 0

DBSelectArea("SA2")
SA2->( DBSetOrder(1) )
If SA2->( DBSeek( xFilial("SA2") + cGFornec + cGLjForn ) )
	ZLM->( RecLock( "ZLM" , .T. ) )
		ZLM->ZLM_FILIAL	:= xFilial("ZLM")
		ZLM->ZLM_COD	:= _nCodEmp
		ZLM->ZLM_SA2COD	:= SA2->A2_COD
		ZLM->ZLM_SA2LJ	:= SA2->A2_LOJA
		ZLM->ZLM_SA2NOM	:= SA2->A2_NOME
		ZLM->ZLM_DATA	:= dDataBase
		ZLM->ZLM_OBS	:= "Transfer�ncia: "+ _cFilOri+"-"+cGEmprest
		ZLM->ZLM_VENCTO	:= StoD( _aTitulos[1][8] ) // Passa o menor vencimento
		ZLM->ZLM_TOTAL	:= nTotSaldo-_nTotAcDc
		ZLM->ZLM_PARC	:= Len( _aTitulos )
		ZLM->ZLM_JUROS	:= _nJuros
		ZLM->ZLM_VLRPAR	:= 0 // O valor da parcela pode variar neste caso diante disto eh passado o valor 0
		ZLM->ZLM_STATUS	:= "6"
		ZLM->ZLM_USER	:= _cMatUsr
		ZLM->ZLM_NUSER	:= _cNUseAp
		ZLM->ZLM_PAGTO	:= nTotSaldo    // Valor total a pagar pelo fornecedor
		ZLM->ZLM_DTLIB	:= dDataBase
		ZLM->ZLM_TIPO	:= _cZLMTipo
		ZLM->ZLM_SETOR	:= cGSetor
		ZLM->ZLM_DTCRED	:= CtoD("")
		ZLM->ZLM_CODTRA	:= cGEmprest
		ZLM->ZLM_FILTRA := _cFilOri
		ZLM->ZLM_USRTRA	:= _cMatUsr
		ZLM->ZLM_DATTRA	:= Date()
		ZLM->ZLM_HORTRA	:= Time()
		ZLM->ZLM_OBSTRA	:= cMObs
	ZLM->( MsUnlock() )
	
	//=======================================
	// Gera as NDF que o fornecedor ira pagar
	//=======================================
	For _nX := 1 to Len( _aTitulos )
		ZLO->(RecLock( "ZLO" , .T. ))
		    ZLO->ZLO_FILIAL	:= xFilial("ZLO")
			ZLO->ZLO_COD	:= _nCodEmp
			ZLO->ZLO_ITEM	:= StrZero( _nX , 3 )
			ZLO->ZLO_VECTO	:= StoD( _aTitulos[_nX][8] )
			ZLO->ZLO_VALOR	:= _aTitulos[_nX][9]+_aTitulos[_nX][13]+_aTitulos[_nX][14]
		    ZLO->ZLO_CHAVET	:= _cFilOri + _aTitulos[_nX][1] + _aTitulos[_nX][3] + _aTitulos[_nX][4] + _aTitulos[_nX][2] + _aTitulos[_nX][5] + _aTitulos[_nX][6]
		ZLO->( MsUnlock() )
	Next _nX
		
	ConfirmSx8()
	
//=========================================================
// Nao foi encontrado o fornecedor do emprestimo de destino
//=========================================================
Else    
	lDeuErro := .T.
	MsgStop("Nao foi encontrado os dados do cadastro do fornecedor indicado para gerar o(a) " + _cTipo + "  de transfer�ncia. Favor checar se os dados foram corretamente inseridos.","AGLT01232")
EndIf

Return()

/*
===============================================================================================================================
Programa--------: incSE2
Autor-----------: Fabiano Dias da Silva
Data da Criacao-: 29/11/2010
Descri��o-------: Cria titulos no contas a pagar referentes a NDF'S do novo emprestimo
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function IncSE2(_cFilOri)

Local _nX 		:= 0
Local _cAlias   := GetNextAlias()

Private _aAutoSE2   := {}
Private lMsErroAuto := .F.

BeginSql alias _cAlias
	SELECT COUNT(1) NREG
	FROM %table:SE2%
	WHERE D_E_L_E_T_ = ' '
	AND E2_FILIAL = %exp:_cFilOri%
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
		AAdd( _aAutoSE2 , { "E2_HIST"		, "TRANSFERENCIA " + Upper(_cTipo) + " :" + _cFilori+"-"+cGEmprest	, Nil } )
		AAdd( _aAutoSE2 , { "E2_DATALIB"	, StoD(_aTitulos[_nX][12])					, Nil } )
		AAdd( _aAutoSE2 , { "E2_USUALIB"	, cUserName									, Nil } )
		AAdd( _aAutoSE2 , { "E2_ACRESC"		, _aTitulos[_nX][13]						, Nil } )
		AAdd( _aAutoSE2 , { "E2_DECRESC"	, _aTitulos[_nX][14]						, Nil } )
		AAdd( _aAutoSE2 , { "E2_L_SETOR"	, cGSetor									, Nil } )
		AAdd( _aAutoSE2 , { "E2_ORIGEM"		, "AGLT012"									, nil } )
		
		lMsErroAuto := .F.
		
		nModulo := 6
		cModulo := "FIN"
		
		MSExecAuto( {|x,y| Fina050( x , y ) } , _aAutoSE2 , 3 ) //Inclusao
		
		If lMsErroAuto 
			lDeuErro := .T.
	 	   	MsgStop("N�o foi possivel gravar os dados! Erro ao gravar T�tulo: "+ _cPrefixo +"-"+ _nCodEmp + " Comunique ao Suporte!!!","AGLT01233")
	 	   	Mostraerro()
	 	   	Exit
		EndIf
		
		nModulo := 2
		cModulo := "COM"
	Next _nX
Else
	lDeuErro := .T.
   	MsgStop("J� existe no financeiro um t�tulo com os dados: "+ _cPrefixo +"-"+ _nCodEmp + "Comunique ao Suporte!!!","AGLT01234")
EndIf

(_cAlias)->( DBCloseArea() )

Return( .T. )

/*
===============================================================================================================================
Programa--------: validSetor
Autor-----------: Fabiano Dias da Silva
Data da Criacao-: 29/11/2010
Descri��o-------: Valida o setor informado
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function validSetor()

Local aArea     := GetArea()
Local _lRet     := .F.

If SubStr( cGFornec , 1 , 1 ) == 'P'
	cGSetor:= Posicione( "ZL3" , 1 , cGFil + SA2->A2_L_LI_RO , "ZL3->ZL3_SETOR" )
EndIf

_lRet:= U_VSetor(.F.,cGSetor)

If _lRet
	DBSelectArea("ZL2")
	ZL2->( DBSetOrder(1) )
	ZL2->( DBSeek( cGFil + cGSetor ) )
	_cDescSet:= ZL2->ZL2_DESCRI
EndIf

ZL2->( DBCloseArea() )
RestArea(aArea)

Return(_lRet)

/*
===============================================================================================================================
Programa--------: AGLT012VLF
Autor-----------: Lucas Borges Ferreira
Data da Criacao-: 05/06/2017
Descri��o-------: Valida o fornecedor
Parametros------: cGFornec , cGLjForn , cGDescri
Retorno---------: _lRet
===============================================================================================================================
*/
Static Function AGLT012VLF( cGFornec , cGLjForn , cGDescri )

Local _lRet := .T.
Local _cChave := IIF(Empty(cGLjForn),cGFornec,cGFornec+cGLjForn)

DBSelectArea("SA2")
SA2->( DBSetOrder(1) )
If SA2->( DBSeek( xFilial("SA2") + _cChave ) )
	If !Empty(cGLjForn)
		If SA2->A2_L_ATIVO <> 'S'  .Or. SA2->A2_MSBLQL == '1'
			MsgStop( "N�o � poss�vel transferir um(a) " + _cTipo + "  para um fornecedor inativo no Leite!"+; 
					" Para processar a transfer�ncia informe um fornecedor ativo na Gest�o do Leite.","AGLT01235")
			_lRet := .F.
		EndIf
	EndIf
	cGLjForn:= SA2->A2_LOJA
	cGDescri := SA2->A2_NOME		
	If SubStr( cGFornec , 1 , 1 ) == 'P'
		validSetor()
	EndIf
Else
	MsgStop("C�digo de Fornecedor/Loja inv�lido! Informe um c�digo de fornecedor que seja v�lido e esteja ativo.","AGLT01236")
	_lRet := .F.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT012C
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Rotina desenvolvida para realizar o estorno de uma transferencia de emprestimo
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT012C()
                               
Local lProcEstor	:= .F.
Private cPerg		:= "AGLT012C"   
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
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Valida se pode ser reaizado o estorno da transfer�ncia
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function vldEstorno()   

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cAlias	:= GetNextAlias()
Local _cFilOri 	:= cFilAnt

If ZLM->(DbSeek(xFilial('ZLM')+MV_PAR01)) .And. ZLM->ZLM_STATUS == "6"
	_cCodEmp	:= ZLM->ZLM_COD   //Armazena o codigo do emprestimo transferido a ser estornado
	_cCodForn	:= ZLM->ZLM_SA2COD
	_cLjForn	:= ZLM->ZLM_SA2LJ      
	_cCodEmpOr	:= ZLM->ZLM_CODTRA //Armazena o codigo do emprestimo de origem
	cFilant 	:= ZLM->ZLM_FILTRA
	// Obtendo Parametos dos EMPRESTIMOS
	If ZLM->ZLM_TIPO == 'E'
		_cPrefixo:= SuperGetMV("LT_EMPPRE",.F.,"GLE")
		_cTipo	:= "Empr�stimo"
	// Obtendo Parametos dos ADIANTAMENTOS
	ElseIf ZLM->ZLM_TIPO == 'A'
		_cPrefixo := SuperGetMV("LT_ADTPRE",.F.,"GLA")
		_cTipo	:= "Adiantamento"
	// Obtendo Parametos das ANTECIPACOES  
	ElseIf ZLM->ZLM_TIPO == "N"
		_cPrefixo := SuperGetMV("LT_ANTPRE",.F.,"GLN")
		_cTipo	:= "Antecipa��o"
	// Obtendo Parametos dos PAGAMENTOS
	ElseIf ZLM->ZLM_TIPO == "P"
		_cPrefixo := SuperGetMV("LT_PAGPRE",.F.,"GUB")
		_cTipo	:= "Pagamento"
	EndIf
	
	//Verifica se o mvimento a ser estornado sofre alguma baixa, pois somente podera ser realizado o estorno de um movimento que n�o sofreu nenhuma baixa
	BeginSql alias _cAlias
		SELECT COUNT(1) QTD
		FROM %table:SE2%
		WHERE D_E_L_E_T_ = ' '
		AND E2_FILIAL = %exp:_cFilOri%
		AND E2_PREFIXO = %exp:_cPrefixo%
		AND E2_NUM = %exp:_cCodEmp%
		AND E2_FORNECE = %exp:_cCodForn%
		AND E2_LOJA = %exp:_cLjForn%
		AND E2_VALOR <> E2_SALDO
	EndSql
	
	If (_cAlias)->QTD > 0
		MsgStop("N�o poder� ser realizado o estorno do(a) " + _cTipo + " informado! " + _cTipo + " " + MV_PAR01 + " encontra-se com baixa(s) realizada(s) no financeiro.","AGLT01237")
		_lRet:= .F.
	EndIf	 
Else
	MsgStop("Esta rotina somente poder� ser executada para movimentos que foram inseridos atrav�s da rotina de transfer�ncia." +;
			"Favor verificar o status do movimento que esteja tentando efetivar o seu estorno, ou se o codigo fornecido do movimento a realizar o estorno esteja corretamente preenchido.","AGLT01238")
	_lRet:= .F.
EndIf

(_cAlias)->(DbCloseArea())

cFilAnt := _cFilOri
RestArea( _aArea )

Return _lRet     

/*
===============================================================================================================================
Programa----------: ProcEstor
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Processa o estorno
Parametros--------: Nenhum
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
				Processa( {||ProcZLM()}/*bAction*/, "Aguarde..."/*cTitle */, "Processando atualiza��o da tabela de " + _cTipo/*cMsg */,.F./*lAbort */)
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
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Exlcui titulo no contas a pagar via SigaAuto
Parametros--------: Nenhum
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
						" Ao confimar esta tela, sera apresentada a tela do SigaAuto, que possui informa��es mais detalhadas.", "AGLT01239")
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
	MsgStop("N�o foi(ram) econtrado(s) t�tulo(s) no financeiro para realizar a exclus�o. Favor acionar a �rea de TI/Sistemas.","AGLT01240")
EndIf   

RestArea(_aArea)

Return  

/*
===============================================================================================================================
Programa----------: CancBxSE2
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Cancela Baixa de titulo no contas a pagar via SigaAuto
Parametros--------: Nenhum
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
Local _cAliasZLO	:= GetNextAlias() 
Local _cAliasSE5	:= GetNextAlias()
Local _cFilOri		:= cFilAnt
Local _cNumero		:= ""
Local _cParcela		:= ""
Local _cTp			:= ""
Local _cFornece		:= ""
Local _cLoja		:= ""

Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.

BeginSql alias _cAliasZLO
	SELECT ZLO_VALOR,ZLO_CHAVET
	FROM %table:ZLO%
	WHERE D_E_L_E_T_ = ' '
	AND ZLO_FILIAL = %xFilial:ZLO%
	AND ZLO_COD = %exp:_cCodEmp%
EndSql
	
COUNT TO _nContReg //Contabiliza o numero de registros encontrados pela query  
(_cAliasZLO)->(DbGoTop())

If _nContReg > 0
	While !(_cAliasZLO)->(Eof()) .And. !lDeuErro
		cFilAnt		:= SubStr((_cAliasZLO)->ZLO_CHAVET,1,2)
		_cPrefixo	:= SubStr((_cAliasZLO)->ZLO_CHAVET,3,3)
		_cNumero	:= SubStr((_cAliasZLO)->ZLO_CHAVET,6,9)
		_cParcela	:= SubStr((_cAliasZLO)->ZLO_CHAVET,15,2)
		_cTp		:= SubStr((_cAliasZLO)->ZLO_CHAVET,17,3)
		_cFornece	:= SubStr((_cAliasZLO)->ZLO_CHAVET,20,6)
		_cLoja		:= SubStr((_cAliasZLO)->ZLO_CHAVET,26,4)
		
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
				AND E5_VALOR = %exp:Str((_cAliasZLO)->ZLO_VALOR )%
				AND E5_FILIAL = %exp:cFilAnt%
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
						MsgStop("Erro ao excluir a baixa no Contas a Pagar, t�tulo " + (_cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) + "Favor acionar a equipe de TI/Sistemas.","AGLT01241")
					  	Mostraerro()
				    EndIf       				    		
													
					(_cAliasSE5)->(DbSkip())			
				EndDo
				(_cAliasSE5)->(DbCloseArea())
			Else
				lDeuErro := .T.
				MsgStop("N�o foram econtrados dados para a realiza��o do cancelamento das baixas no financeiro do(a) " + _cTipo + " de origem. Favor acionar a equipe de TI/Sistemas.","AGLT01242")
			EndIf
		Else 
			lDeuErro := .T.
			MsgStop("A chave de estorno do(a) " + _cTipo +" " + _cCodEmp + " esta vazia. Favor acionar a equipe de TI/Sistemas.", "AGLT01243")
		EndIf	
		
		(_cAliasZLO)->(DbSkip())
	EndDo
	(_cAliasZLO)->(DbCloseArea())	  
//=============================================================
//Nao encontrou dados do emprestimo de origem
//=============================================================
Else
	lDeuErro := .T.
	MsgStop("N�o foram encontrados os dados do(a)" + _cTipo +" " + _cCodEmp + " Favor acionar a equipe de TI/Sistemas.", "AGLT01244")
EndIf
cFilAnt := _cFilOri

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: ProcZLM
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/11/2010
Descri��o---------: Atualiza registros na ZLM
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ProcZLM()

Local _aArea:= GetArea()
Local _cFilOri := ""

//Efetua exclusao do cabecalho do emprestimo transferido bem como de seus itens
If ZLM->(DbSeek(xFilial("ZLM") + _cCodEmp))
	_cFilOri := ZLM->ZLM_FILTRA
	ZLM->(RecLock("ZLM",.F.)) 
		ZLM->(dbDelete())
	ZLM->(MsUnlock())    
	
	ZLO->(DbSetOrder(1))
	If ZLO->(DbSeek(xFilial("ZLO") + _cCodEmp))  
		While !ZLO->(Eof()) .And. xFilial("ZLO") == ZLO->ZLO_FILIAL .And. _cCodEmp == ZLO->ZLO_COD
			ZLO->(RecLock("ZLO",.F.))    
				ZLO->(dbDelete())  
			ZLO->(MsUnlock()) 
		ZLO->(DbSkip())
		EndDo  
	//Nao foram encontrados os dados dos itens do emprestimo para realizar a sua exclusao
	Else  
		lDeuErro := .T.
		MsgStop("N�o foram encontrados os dados dos itens do(A)" + _cTipo +" " + _cCodEmp + " para realizar a sua exclus�o na tabela ZLO. Favor acionar a equipe de TI/Sistemas.", "AGLT01245")
	EndIf 
	     
//Nao foi encontrado o registro dos dados do cabecalho de origem 
Else  
	lDeuErro := .T.
	MsgStop("N�o foram encontrados os dados do cabecalho do(A)" + _cTipo +" " + _cCodEmp + " para realizar a sua exclus�o na tabela ZLM. Favor acionar a equipe de TI/Sistemas.","AGLT01246")
EndIf     
     
//Caso nao ocorra erro na exclusao dos dados do emprestimo de transferencia atualiza os dados do emprestimo de origem para que ele volte o 
//seu status como antes da realizacao da transferencia
If !lDeuErro  

	ZLM->(dbCommit()) 
	ZLO->(dbCommit()) 

	If ZLM->(dbSeek(_cFilOri + _cCodEmpOr))
		ZLM->(RecLock("ZLM",.F.))
	 		ZLM->ZLM_STATUS:= "4" //Efetivado
        	ZLM->ZLM_CODTRA:= ""
			ZLM->ZLM_FILTRA:= ""
			ZLM->ZLM_USRTRA:= ""
			ZLM->ZLM_DATTRA:= CtoD("")
			ZLM->ZLM_HORTRA:= ""
			ZLM->ZLM_OBSTRA:= ""
		ZLM->(MsUnlock())
	Else
		lDeuErro := .T.
		Help(NIL, NIL, "AGLT01247", NIL, "N�o foram encontrados os dados do cabecalho do(A)" + _cTipo +" " + _cCodEmp + " para realizar a sua altera��o na tabela ZLM.";
			, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor acionar a equipe de TI/Sistemas."})
	EndIf
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: NroSeq
Autor-------------: Jeovane
Data da Criacao---: 19/11/2008
Descri��o---------: Busca numero de sequencia da baixa no array de baixas do titulo
Parametros--------: cPrefixo   = Prefixo do titulo a ser cancelado a baixa
					cNum       = Numero do titulo a ser cancelado a baixa
					cParc      = Parcela do titulo a ser cancelado a baixa
					cTipo      = Tipo do titulo a ser cancelado a baixa
					cFor       = Fornecedor do titulo a ser cancelado a baixa
					cLoja      = Loja do Fornecedor do titulo a ser cancelado a baixa
					cSeq       = Sequencia da baixa
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
