/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 26/09/2019 | Chamado 28346. Revis�o de fontes.
Lucas Borges  | 22/07/2022 | Chamado 40778. Tratamento para Extrato Seco Total (EST).
Lucas Borges  | 24/03/2025 | Chamado 48203. Inclu�do campo ZZX_FLOGID no grupo correto.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: AGLT029
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para cadastrar an�lise da qualidade do Leite de Terceiros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT029()

Local _oBrowse := Nil

// Configura e inicializa a Classe do Browse
_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( 'ZZX' )
_oBrowse:SetMenuDef( 'AGLT029' )
_oBrowse:SetDescription( 'An�lise de Qualidade - Leite de Terceiros' )
_oBrowse:DisableDetails()

_oBrowse:AddLegend( ' Empty( Posicione("ZLX",7,xFILIAL("ZLX")+ZZX->ZZX_CODIGO,"ZLX_CODIGO") )' , 'GREEN'	, 'An�lise Pendente'				)
_oBrowse:AddLegend( '!Empty( Posicione("ZLX",7,xFILIAL("ZLX")+ZZX->ZZX_CODIGO,"ZLX_CODIGO") )' , 'RED'		, 'An�lise Vinculada � Recep��o'	)

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
Return( FWMVCMenu("AGLT029") )

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

Local _oStruZZX	:= FWFormStruct( 1 , 'ZZX' )
Local _oStruZAP	:= FWFormStruct( 1 , 'ZAP' )
Local _oModel	:= Nil
Local _aGatAux	:= {}

_aGatAux := FwStruTrigger( 'ZZX_FORNEC'	, 'ZZX_NOMFOR' , 'POSICIONE("SA2",1,xFilial("SA2")+M->(ZZX_FORNEC)+AllTrim(M->ZZX_LJFORN),"A2_NREDUZ")'	, .F. )
_oStruZZX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZZX_LJFORN'	, 'ZZX_NOMFOR' , 'POSICIONE("SA2",1,xFilial("SA2")+M->(ZZX_FORNEC+ZZX_LJFORN),"A2_NREDUZ")'				, .F. )
_oStruZZX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZZX_FORNEC'	, 'ZZX_LJFORN' , 'POSICIONE("SA2",1,xFilial("SA2")+M->(ZZX_FORNEC)+AllTrim(M->ZZX_LJFORN),"A2_LOJA")'	, .F. )
_oStruZZX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZZX_LJTRAN'	, 'ZZX_NOMTRA' , 'POSICIONE("SA2",1,xFilial("SA2")+M->(ZZX_TRANSP+ZZX_LJTRAN),"A2_NREDUZ")'				, .F. )
_oStruZZX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZZX_CODPRD'	, 'ZZX_DESPRD' , 'POSICIONE("SX5",1,xFilial("SX5")+"Z7"+M->ZZX_CODPRD,"X5_DESCRI")'		   				, .F. )
_oStruZZX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZZX_CODPRD'	, 'ZZX_DENSID' , 'POSICIONE("ZA7",1,xFilial("ZA7")+M->ZZX_CODPRD,"ZA7_DENPAD")'	   		  				, .F. )
_oStruZZX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel := MpFormModel():New( "AGLT029M" ,, {|_oModel| VALIDCOMIT(_oModel) } )

_oModel:AddFields(	'ZZXMASTER'	,				, _oStruZZX )
_oModel:AddGrid(	'ZAPDETAIL'	, 'ZZXMASTER'	, _oStruZAP )

_oModel:SetRelation( 'ZAPDETAIL', { { 'ZAP_FILIAL' , 'xFilial( "ZAP" )' } , { 'ZAP_CODIGO' , 'ZZX_CODIGO' } } , ZAP->( IndexKey(1) ) )

_oModel:AddCalc( 'STRCALC01' , 'ZZXMASTER' , 'ZAPDETAIL' , 'ZAP_GORD' , 'XXX_CAUX01' , 'AVERAGE' , {|| .T. } ,, 'Gordura M�dia' )
_oModel:AddCalc( 'STRCALC01' , 'ZZXMASTER' , 'ZAPDETAIL' , 'ZAP_EST' , 'XXX_CAUX02' , 'AVERAGE' , {|| .T. } ,, 'EST M�dio' )

_oModel:SetDescription( 'Lan�amento de An�lise da Qualidade - Leite de Terceiros' )

_oModel:GetModel( 'ZZXMASTER' ):SetDescription( 'Dados da An�lise'	)
_oModel:GetModel( 'ZAPDETAIL' ):SetDescription( 'Resultados'		)

_oModel:GetModel( 'ZAPDETAIL' ):SetUniqueLine( { 'ZAP_ITEM' } )
_oModel:GetModel( 'ZAPDETAIL' ):SetOptional( .T. )

_oModel:SetPrimaryKey( {'ZZX_FILIAL','ZZX_CODIGO' } )

_oModel:SetVldActivate( {|_oModel| AGLT029VLI(_oModel) } )

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

Local _oModel	:= FWLoadModel( 'AGLT029' )
Local _oCalc	:= FWCalcStruct( _oModel:GetModel( 'STRCALC01') )
Local _oStruZZX	:= FWFormStruct( 2 , 'ZZX' )
Local _oStruZAP	:= FWFormStruct( 2 , 'ZAP' )
Local _oView	:= FWFormView():New()

_oStruZAP:RemoveField( "ZAP_CODIGO" )

_oStruZZX:AddGroup( 'GRUPO01' , 'Dados da An�lise'	, " " , 2 )
_oStruZZX:AddGroup( 'GRUPO02' , 'Fornecedor'		, " " , 2 )
_oStruZZX:AddGroup( 'GRUPO03' , 'Transportadora'	, " " , 2 )

_oStruZZX:SetProperty( 'ZZX_CODIGO'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZX:SetProperty( 'ZZX_CODPRD'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZX:SetProperty( 'ZZX_DESPRD'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZX:SetProperty( 'ZZX_DATA' 	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZX:SetProperty( 'ZZX_HORA' 	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZX:SetProperty( 'ZZX_DENSID'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZX:SetProperty( 'ZZX_FLOGID'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )

_oStruZZX:SetProperty( 'ZZX_FORNEC'	, MVC_VIEW_GROUP_NUMBER , "GRUPO02" )
_oStruZZX:SetProperty( 'ZZX_LJFORN'	, MVC_VIEW_GROUP_NUMBER , "GRUPO02" )
_oStruZZX:SetProperty( 'ZZX_NOMFOR'	, MVC_VIEW_GROUP_NUMBER , "GRUPO02" )

_oStruZZX:SetProperty( 'ZZX_PLACA'	, MVC_VIEW_GROUP_NUMBER , "GRUPO03" )
_oStruZZX:SetProperty( 'ZZX_TRANSP'	, MVC_VIEW_GROUP_NUMBER , "GRUPO03" )
_oStruZZX:SetProperty( 'ZZX_LJTRAN'	, MVC_VIEW_GROUP_NUMBER , "GRUPO03" )
_oStruZZX:SetProperty( 'ZZX_NOMTRA'	, MVC_VIEW_GROUP_NUMBER , "GRUPO03" )

_oView:SetModel( _oModel )

_oView:AddField(	'VIEW_CAB'	, _oStruZZX	, 'ZZXMASTER'	)
_oView:AddGrid(		'VIEW_DET'	, _oStruZAP	, 'ZAPDETAIL'	)
_oView:AddField(	'VIEW_CAL'	, _oCalc	, 'STRCALC01'	)

_oView:CreateHorizontalBox( 'SUPERIOR'	, 50 )
_oView:CreateHorizontalBox( 'INFERIOR'	, 40 )
_oView:CreateHorizontalBox( 'RODAPE'	, 10 )

_oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR'	)
_oView:SetOwnerView( 'VIEW_DET'	, 'INFERIOR'	)
_oView:SetOwnerView( 'VIEW_CAL'	, 'RODAPE'		)

_oView:EnableTitleView( 'VIEW_DET' , 'Resultados das An�lises:' )

_oView:AddIncrementField( 'VIEW_DET' , 'ZAP_ITEM' )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT029VLI
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para processamento da valida��o inicial das opera��es
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT029VLI( _oModel )  

Local _nOper		:= _oModel:GetOperation()
Local _lRet			:= .T.
Local _cCodRec		:= ''

If _nOper == MODEL_OPERATION_DELETE .Or. _nOper == MODEL_OPERATION_UPDATE

	_cCodRec := Posicione( "ZLX" , 7 , xFilial("ZLX") + ZZX->ZZX_CODIGO , "ZLX_CODIGO" )
	
	If !Empty(_cCodRec)
		Help(NIL, NIL, "AGLT02901", NIL, 'A an�lise de Qualidade selecionada est� vinculada � uma recep��o de Leite de terceiros! ('+ _cCodRec +')';
				, 1, 0, NIL, NIL, NIL, NIL, NIL, {'N�o ser� poss�vel excluir ou alterar a an�lise sem efetuar o cancelamento da recep��o.'})
	    _lRet := .F.
	EndIf

EndIf

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
Static Function VALIDCOMIT( _oModAux )

Local _oModel	:= FWModelActive()
Local _aArea	:= GetArea()
Local _cAlias	:= ''
Local _lRet		:= .T.
Local _nOper	:= _oModel:GetOperation()
Local _cFiltro	:= '%'
Local _dData	:= _oModel:GetValue( 'ZZXMASTER' , 'ZZX_DATA'	)
Local _cForn	:= _oModel:GetValue( 'ZZXMASTER' , 'ZZX_FORNEC'	)
Local _cLjFor	:= _oModel:GetValue( 'ZZXMASTER' , 'ZZX_LJFORN'	)
Local _cPlaca	:= _oModel:GetValue( 'ZZXMASTER' , 'ZZX_PLACA'	)

If _nOper == MODEL_OPERATION_INSERT .Or. _nOper == MODEL_OPERATION_UPDATE
	
	DBSelectArea('SA2')
	SA2->( DBSetOrder(1) )
	If SA2->( DBSeek( xFilial('SA2') + _cForn + _cLjFor ) )
	
		If SA2->A2_MSBLQL == '1'
			Help(NIL, NIL, "AGLT02902", NIL, 'O Fornecedor atual encontra-se Bloqueado ou Inativo no cadastro de Fornecedores do Sistema!';
				, 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do Fornecedor ou os dados informados e tente novamente. '})
			_lRet := .F.
		Else
			If _nOper == MODEL_OPERATION_UPDATE
				_cFiltro += " AND R_E_C_N_O_ <> '"+ cValToChar( ZZX->( Recno() ) ) +"' "
			EndIf
			_cFiltro += "%"
			_cAlias := GetNextAlias()

			BeginSql alias _cAlias
				SELECT ZZX_CODIGO
				FROM  %Table:ZZX%
				WHERE D_E_L_E_T_ = ' '
				AND ZZX_FILIAL = %xFilial:ZZX%
				AND ZZX_DATA = %exp:_dData%
				AND ZZX_FORNEC = %exp:_cForn%
				AND ZZX_LJFORN = %exp:_cLjFor%
				AND ZZX_PLACA = %exp:_cPlaca%
			EndSql

			If (_cAlias)->( !Eof() )
				If MsgYesNo( "J� existe uma analise registrada nesse mesmo dia para o fornecedor informado e com essa placa, deseja confirmar o registro?","AGLT02903")
					_lRet := .T.
				Else
					Help(NIL, NIL, "AGLT02904", NIL, "Opera��o cancelada pelo usu�rio!", 1, 0, NIL, NIL, NIL, NIL, NIL, {'Caso n�o queira gravar os dados atuais utilize a op��o "Fechar" para sair sem Salvar. '})
					_lRet := .F.
				EndIf
			EndIf
			
			(_cAlias)->( DBCloseArea() )
		
		EndIf
	
	Else
		Help(NIL, NIL, "AGLT02905", NIL, 'Fornecedor informado n�o foi encontrado no cadastro de Fornecedores do Sistema!';
		, 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do Fornecedor ou os dados informados e tente novamente. '})
		_lRet := .F.
	EndIf
	
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT029V
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para processamento da valida��o final das opera��es ao confirmar o modelo de dados
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT029V( _nOpc , _cCodTip , _nVarAux )

Local _lRet		:= .F.
Local _cValMin	:= ''
Local _cValMax	:= ''

DBSelectArea('ZA7')
ZA7->( DBSetOrder(1) )
If ZA7->( DBSeek( xFilial('ZA7') + AllTrim(_cCodTip) ) )

	If _nOpc == 1
		
		If ZA7->ZA7_DENMIN > _nVarAux .Or. _nVarAux > ZA7->ZA7_DENMAX
			_cValMin := AllTrim( Transform( ZA7->ZA7_DENMIN , PesqPict( 'ZA7' , 'ZA7_DENMIN' ) ) )
			_cValMax := AllTrim( Transform( ZA7->ZA7_DENMAX , PesqPict( 'ZA7' , 'ZA7_DENMAX' ) ) )
			Help(NIL, NIL, "AGLT02906", NIL, 'Informa��o referente � densidade est� fora dos par�metros configurados para o produto da an�lise atual!';
				, 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique os dados informados ou o cadastro de regras. Val.M�nimo('+ _cValMin +') Val.M�ximo('+ _cValMax +') '})
			_lRet := .F.
		Else
			_lRet := .T.
		EndIf
	
	ElseIf _nOpc == 2
	
		If ZA7->ZA7_GORMIN > _nVarAux .Or. _nVarAux > ZA7->ZA7_GORMAX
			_cValMin := AllTrim( Transform( ZA7->ZA7_GORMIN , PesqPict( 'ZA7' , 'ZA7_GORMIN' ) ) )
			_cValMax := AllTrim( Transform( ZA7->ZA7_GORMAX , PesqPict( 'ZA7' , 'ZA7_GORMAX' ) ) )
			Help(NIL, NIL, "AGLT02907", NIL, 'Informa��o referente � gordura est� fora dos par�metros configurados para o produto da an�lise atual!';
				, 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique os dados informados ou o cadastro de regras. Val.M�nimo('+ _cValMin +') Val.M�ximo('+ _cValMax +') '})			
			_lRet := .F.
		Else
			_lRet := .T.
		EndIf
	
	ElseIf _nOpc == 3
	
		If ZA7->ZA7_ESTMIN > _nVarAux .Or. _nVarAux > ZA7->ZA7_ESTMAX
			_cValMin := AllTrim( Transform( ZA7->ZA7_ESTMIN , PesqPict( 'ZA7' , 'ZA7_ESTMIN' ) ) )
			_cValMax := AllTrim( Transform( ZA7->ZA7_ESTMAX , PesqPict( 'ZA7' , 'ZA7_ESTMAX' ) ) )
			Help(NIL, NIL, "AGLT02911", NIL, 'Informa��o referente ao Extrato Seco Total est� fora dos par�metros configurados para o produto da an�lise atual!';
				, 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique os dados informados ou o cadastro de regras. Val.M�nimo('+ _cValMin +') Val.M�ximo('+ _cValMax +') '})			
			_lRet := .F.
		Else
			_lRet := .T.
		EndIf
	
	EndIf

Else
	Help(NIL, NIL, "AGLT02908", NIL, 'O produto informado n�o possui cadastro de regras para recep��o de Leite!', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique os dados informados ou o cadastro de regras.'})
	_lRet := .F.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT029F
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
Descri��o---------: Rotina para valida��o do c�digo de Fornecedor digitado na tela
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT029F( _nOpc )

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _oModel	:= FWModelActive()
Local _cCodFor	:= ''
Local _cLojFor	:= ''

_cCodFor	:= _oModel:GetValue( 'ZZXMASTER' , 'ZZX_FORNEC' )
_cLojFor	:= _oModel:GetValue( 'ZZXMASTER' , 'ZZX_LJFORN' )

DBSelectArea('SA2')
SA2->( DBSetOrder(1) )
If SA2->( DBSeek( xFilial('SA2') + _cCodFor + AllTrim( _cLojFor ) ) )
	If ( SA2->A2_I_CLASS $ 'ZLF' )
		_oModel:LoadValue( 'ZZXMASTER' , 'ZZX_LJFORN' , SA2->A2_LOJA )
	Else
		Help(NIL, NIL, "AGLT02909", NIL, "O Fornecedor informado n�o � v�lido para a Opera��o atual!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para esse campo � obrigat�rio informar um fornecedor de classe: Z, L ou F."})
		_lRet := .F.
	EndIf
Else
	Help(NIL, NIL, "AGLT02910", NIL, "O Fornecedor digitado n�o foi encontrado no cadastro de Fornecedores do Sistema!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do Fornecedor no Sistema ou os dados informados."})
	_lRet := .F.
EndIf

RestArea( _aArea )

Return( _lRet )
