/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 26/09/2019 | Revis�o de fontes. Chamado 28346
Lucas Borges  | 22/07/2022 | Tratamento para Extrato Seco Total (EST). Chamado 40778
Lucas Borges  | 24/03/2025 | Chamado 48203. Inclu�do campo para integra��o com app da Qualidade
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"

/*
===============================================================================================================================
Programa----------: AGLT007
Autor-------------: Alexandre Villar
Data da Criacao---: 13/11/2014
Descri��o---------: Rotina para cadastro das regras de produtos da Gest�o do Leite
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT007()

Local oBrowse	:= Nil

Private aRotina	:= MenuDef()

// Instancia a classe do Browse
oBrowse := FWMBrowse():New()

// Configura e inicia a tela principal
oBrowse:SetAlias("ZA7")
oBrowse:SetDescription( "Cadastro das Regras para os Produtos - Gest�o do Leite" )
oBrowse:DisableReport()
oBrowse:Activate()

Return()

//-------------------------------------------------------------------
Static Function MenuDef()
Return( FWMVCMenu("AGLT007") )

//-------------------------------------------------------------------
Static Function ModelDef()

Local _aGatAux	:= {}
Local _oStrCAB	:= FWFormStruct( 1 , "ZA7" , {|_cCampo| AGLT007CPO( 1 , _cCampo ) } )
Local _oStrITN	:= FWFormStruct( 1 , "ZA7" , {|_cCampo| AGLT007CPO( 2 , _cCampo ) } )
Local _oModel	:= Nil

// Cria��o dos gatilhos para o cabe�alho da rotina
_aGatAux := FwStruTrigger( 'ZA7_TIPPRD'	, 'ZA7_DESTIP'	, 'POSICIONE("SX5",1,xFilial("SX5")+"Z7"+M->ZA7_TIPPRD,"X5DESCRI()")'	, .F. )
_oStrCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZA7_CODPRD'	, 'ZA7_DESPRD'	, 'POSICIONE("SB1",1,xFilial("SB1")+M->ZA7_CODPRD,"B1_DESC")'			, .F. )
_oStrITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

// Cria o objeto do Modelo de Dados
_oModel := MPFormModel():New( "AGLT007M" )

// Configura��es do modelo para exibi��o na tela
_oModel:SetDescription( "Cadastro de Regras dos Produtos - Gest�o do Leite" )
_oModel:AddFields( "ZA7MASTER" ,             , _oStrCAB )
_oModel:AddGrid(   "ZA7DETAIL" , "ZA7MASTER" , _oStrITN )

_oModel:SetRelation( 'ZA7DETAIL' , {	{ 'ZA7_FILIAL' , 'xFilial( "ZA7" )'	} ,;
										{ 'ZA7_TIPPRD' , 'ZA7_TIPPRD'		} ,;
										{ 'ZA7_DENMIN' , 'ZA7_DENMIN'		} ,;
										{ 'ZA7_DENMAX' , 'ZA7_DENMAX'		} ,;
										{ 'ZA7_DENPAD' , 'ZA7_DENPAD'		} ,;
										{ 'ZA7_DPADIN' , 'ZA7_DPADIN'		} ,;
										{ 'ZA7_GORMIN' , 'ZA7_GORMIN'		} ,;
										{ 'ZA7_GORMAX' , 'ZA7_GORMAX'		} ,;
										{ 'ZA7_GORPAD' , 'ZA7_GORPAD'		} ,;
										{ 'ZA7_ESTMIN' , 'ZA7_ESTMIN'		} ,;
										{ 'ZA7_ESTMAX' , 'ZA7_ESTMAX'		} ,;
										{ 'ZA7_ESTPAD' , 'ZA7_ESTPAD'		} } , ZA7->( IndexKey(1) ) )

_oModel:SetPrimaryKey( { "ZA7_FILIAL" , "ZA7_TIPPRD" } )

Return( _oModel )

//-------------------------------------------------------------------
Static Function ViewDef()

Local _oModel  	:= FWLoadModel( "AGLT007" )
Local _oStrCAB	:= FWFormStruct( 2 , "ZA7" , {|_cCampo| AGLT007CPO( 1 , _cCampo ) } )
Local _oStrITN	:= FWFormStruct( 2 , "ZA7" , {|_cCampo| AGLT007CPO( 2 , _cCampo ) } )
Local _oView	:= Nil

// Cria o objeto de View
_oView := FWFormView():New()

// Configura��es do objeto da View
_oView:SetModel( _oModel )

_oStrCAB:AddGroup( 'GRUPO01' , 'Tipo de Produto Produto'	, '' , 2 )
_oStrCAB:AddGroup( 'GRUPO02' , 'Regras'						, '' , 2 )

_oStrCAB:SetProperty( 'ZA7_TIPPRD' , MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStrCAB:SetProperty( 'ZA7_DESTIP' , MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )

_oStrCAB:SetProperty( 'ZA7_DENMIN' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_DENMAX' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_DENPAD' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_DPADIN' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_GORMIN' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_GORMAX' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_GORPAD' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_ESTMIN' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_ESTMAX' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStrCAB:SetProperty( 'ZA7_ESTPAD' , MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )

_oView:AddField( "VIEW_CAB"	, _oStrCAB	, "ZA7MASTER" )
_oView:AddGrid(  "VIEW_ITN"	, _oStrITN	, "ZA7DETAIL" )

// Cria os Box horizontais para a View
_oView:CreateHorizontalBox( 'BOX0101' , 50 )
_oView:CreateHorizontalBox( 'BOX0102' , 50 )

_oView:SetOwnerView( "VIEW_CAB" , "BOX0101" )
_oView:SetOwnerView( "VIEW_ITN" , "BOX0102" )

//_oView:AVIEWS[2][3]:BCHANGELINE := {|_oView| U_AFIN004L(_oView) }

_oView:EnableTitleView( 'VIEW_CAB' , 'Defini��o das Regras'  )
_oView:EnableTitleView( 'VIEW_ITN' , 'Produtos relacionados' )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT007T
Autor-------------: Alexandre Villar
Data da Criacao---: 13/11/2014
Descri��o---------: Rotina para verificar a configura��o do produto informado
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT007T( _lInclui , _lAltera )

Local _oModel	:= FWModelActive()
Local _cAlias	:= GetNextAlias()
Local _cFiltro	:= "% "
Local _lRet		:= .T.
Local _cCodPrd	:= _oModel:GetValue( 'ZA7DETAIL' , 'ZA7_CODPRD' )
Local _cTipPrd 	:= _oModel:GetValue( 'ZA7MASTER' , 'ZA7_TIPPRD' )

If _lInclui .Or. _lAltera

	If _lAltera
		_cFiltro += " AND R_E_C_N_O_ <> '"+ cValToChar( ZA7->( Recno() ) ) +"' "
	EndIf
	_cFiltro += " %"
	
	BeginSQL Alias _cAlias
		SELECT ZA7_CODPRD
		FROM %Table:ZA7%
		WHERE D_E_L_E_T_ =' '
		%exp:_cFiltro%
		AND ZA7_FILIAL = %xFilial:ZA7%
		AND ZA7_CODPRD = %exp:_cCodPrd%
		AND ZA7_TIPPRD = %exp:_cTipPrd%
	EndSQL
	
	If (_cAlias)->( !Eof() ) .And. !Empty( (_cAlias)->ZA7_CODPRD )
		Help(NIL, NIL, "AGLT00701", NIL, "J� existe outro cadastro com o mesmo C�digo e Tipo de Produto.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os dados digitados, e caso necess�rio utilize a op��o alterar no cadastro j� existente."})
		_lRet := .F.
	EndIf
	(_cAlias)->( DBCloseArea() )
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT007T
Autor-------------: Alexandre Villar
Data da Criacao---: 13/11/2014
Descri��o---------: Rotina para definir a exibi��o dos campos na tela
Parametros--------: Nenhum
Setor-------------: Gest�o do Leite
===============================================================================================================================
*/
Static Function AGLT007CPO( _nOpc , _cCampo )

Local _lRet := Upper(AllTrim(_cCampo)) $ "ZA7_CODPRD/ZA7_DESPRD/ZA7_CODINT"

IIf( _nOpc == 1 , _lRet := !_lRet , Nil )

Return( _lRet )
