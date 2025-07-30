/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
                  |            |                                                                                              |
===============================================================================================================================
*/

#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*
===============================================================================================================================
Programa----------: AOMS012
Autor-------------: Alexandre Villar
Data da Criacao---: 21/09/2015
===============================================================================================================================
Descri��o---------: Rotina de configura��o das regi�es das tabelas de frete
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Setor-------------: Log�stica
===============================================================================================================================
*/

User Function AOMS012()

Local _oBrowse	:= Nil
Local _xAces01	:= U_ITAcsUsr( 'ZZL_CADFRT' , '1' )
Local _xAces02	:= U_ITAcsUsr( 'ZZL_CADFRT' , '2' )

//====================================================================================================
// Verifica acesso do usu�rio
//====================================================================================================
If ValType( _xAces01 ) == 'N' .And. _xAces01 == 0

	Aviso( 'Aten��o!' , 'Usu�rio n�o est� cadastrado na Gest�o de Usu�rios do Configurador Italac!' , {'Fechar'} )
	Return()

ElseIf !_xAces01 .And. !_xAces02
	
	Aviso( 'Aten��o!' , 'Usu�rio sem acesso �s rotinas de cadastros da tabela de Frete!'			, {'Fechar'} )
	Return()
	
EndIf

//===============================================================================================
// Verifica situa��o do SX2->X2_UNICO pra n�o dar erro no MVC
//===============================================================================================
U_ITUNQSX2( "ZF1" , "ZF1_FILIAL+ZF1_CODREG"				)
U_ITUNQSX2( "ZF2" , "ZF2_FILIAL+ZF2_CODREG+ZF2_CODMUN"	)
U_ITUNQSX2( "ZFA" , "ZFA_FILIAL+ZFA_CODREG+ZFA_CFGPRZ"	)

//===============================================================================================
// Configura��o da Classe do Browse
//===============================================================================================
_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( "ZF1" )
_oBrowse:SetDescription( "Regi�es das tabelas de frete" )
_oBrowse:DisableDetails()
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 21/09/2015
===============================================================================================================================
Descri��o---------: Rotina de constru��o do menu do browse principal
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aRotina - Array com a configura��o do menu
===============================================================================================================================
Setor-------------: Log�stica
===============================================================================================================================
*/

Static Function MenuDef()
Return( FWMVCMenu( "AOMS012" ) )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Alexandre Villar
Data da Criacao---: 21/09/2015
===============================================================================================================================
Descri��o---------: Rotina de configura��o do modelo de dados
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _oModel - Modelo do Objeto de dados
===============================================================================================================================
Setor-------------: Log�stica
===============================================================================================================================
*/

Static Function ModelDef()

Local _aGatAux	:= {}
Local _oStrZF1 	:= FWFormStruct( 1 , "ZF1" )
Local _oStrZF2 	:= FWFormStruct( 1 , "ZF2" , {|_cCampo| AOMS012CPO( _cCampo , 'ZF2' ) } )
Local _oStrZFA 	:= FWFormStruct( 1 , "ZFA" , {|_cCampo| AOMS012CPO( _cCampo , 'ZFA' ) } )
Local _oModel	:= Nil

_aGatAux := FwStruTrigger( 'ZF2_CODMUN' , 'ZF2_MUN'		, 'CC2->CC2_MUN'	, .T. , 'CC2' , 1 , 'xFilial("CC2")+M->ZF2_CODMUN'	)
_oStrZF2:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZFA_CFGPRZ' , 'ZFA_DESCFG'	, 'AllTrim( U_ITRETBOX( M->ZFA_CFGPRZ , "ZF7_PRAZO" ) )'		, .F.	)
_oStrZFA:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel := MPFormModel():New( "AOMS012M" )

_oModel:SetDescription( "Regi�es da Tabela de Frete" )

_oModel:AddFields(	'ZF1MASTER' ,				, _oStrZF1 )
_oModel:AddGrid(	'ZF2DETAIL'	, 'ZF1MASTER'	, _oStrZF2 )
_oModel:AddGrid(	'ZFADETAIL'	, 'ZF1MASTER'	, _oStrZFA )

_oModel:SetRelation( 'ZF2DETAIL' , {	{ 'ZF2_FILIAL' , 'xFilial("ZF2")'	} , ;
										{ 'ZF2_CODREG' , 'ZF1_CODREG'		} } , ZF2->( IndexKey(1) ) )

_oModel:SetRelation( 'ZFADETAIL' , {	{ 'ZFA_FILIAL' , 'xFilial("ZFA")'	} , ;
										{ 'ZFA_CODREG' , 'ZF1_CODREG'		} } , ZFA->( IndexKey(1) ) )

_oModel:GetModel( 'ZF2DETAIL' ):SetOptional( .T. )
_oModel:GetModel( 'ZFADETAIL' ):SetOptional( .T. )

_oModel:GetModel( 'ZF2DETAIL' ):SetUniqueLine( { 'ZF2_CODMUN' } )
_oModel:GetModel( 'ZFADETAIL' ):SetUniqueLine( { 'ZFA_CFGPRZ' } )

_oModel:SetPrimaryKey( { 'ZF1_FILIAL' , 'ZF1_CODREG' } )

_oModel:GetModel( "ZF1MASTER" ):SetDescription( "Regi�es"		)
_oModel:GetModel( "ZF2DETAIL" ):SetDescription( "Munic�pios"	)
_oModel:GetModel( "ZFADETAIL" ):SetDescription( "Configura��o"	)

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Alexandre Villar
Data da Criacao---: 21/09/2015
===============================================================================================================================
Descri��o---------: Rotina de configura��o da interface de execu��o
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _oView - Modelo da interface de execu��o
===============================================================================================================================
Setor-------------: Log�stica
===============================================================================================================================
*/

Static Function ViewDef()

Local _oModel	:= FWLoadModel( "AOMS012" )
Local _oStrZF1	:= FWFormStruct( 2 , "ZF1" )
Local _oStrZF2	:= FWFormStruct( 2 , "ZF2" , {|_cCampo| AOMS012CPO( _cCampo , 'ZF2' ) } )
Local _oStrZFA 	:= FWFormStruct( 2 , "ZFA" , {|_cCampo| AOMS012CPO( _cCampo , 'ZFA' ) } )
Local _oView	:= Nil

_oView := FWFormView():New()

_oView:SetModel( _oModel )

_oView:AddField( 'VIEW_CAB' , _oStrZF1	, 'ZF1MASTER' )
_oView:AddGrid(  'VIEW_DET' , _oStrZF2	, 'ZF2DETAIL' )
_oView:AddGrid(  'VIEW_CFG' , _oStrZFA	, 'ZFADETAIL' )

_oView:CreateHorizontalBox( 'SUPERIOR'	, 20 )
_oView:CreateHorizontalBox( 'INTERMED'	, 50 )
_oView:CreateHorizontalBox( 'INFERIOR'	, 30 )

_oView:SetOwnerView( 'VIEW_CAB' , 'SUPERIOR' )
_oView:SetOwnerView( 'VIEW_DET' , 'INTERMED' )
_oView:SetOwnerView( 'VIEW_CFG' , 'INFERIOR' )

_oView:EnableTitleView( 'VIEW_DET' , 'Munic�pios:'		)
_oView:EnableTitleView( 'VIEW_CFG' , 'Configura��o:'	)

Return( _oView )

/*
===============================================================================================================================
Programa----------: AOMS012CPO
Autor-------------: Alexandre Villar
Data da Criacao---: 21/09/2015
===============================================================================================================================
Descri��o---------: Rotina de configura��o da dos campos a serem exibidos na interface de execu��o
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _oView - Modelo da interface de execu��o
===============================================================================================================================
Setor-------------: Log�stica
===============================================================================================================================
*/

Static Function AOMS012CPO( _cCampo , _cAlias )

Local _lRet := .T.

If _cAlias == 'ZF2'
	_lRet := !( Upper( AllTrim( _cCampo ) ) $ 'ZF2_CODREG' )
ElseIf _cAlias == 'ZFA'
	_lRet := !( Upper( AllTrim( _cCampo ) ) $ 'ZFA_CODREG' )
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS012I
Autor-------------: Alexandre Villar
Data da Criacao---: 21/09/2015
===============================================================================================================================
Descri��o---------: Inicializador padr�o de campos
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Setor-------------: Log�stica
===============================================================================================================================
*/

User Function AOMS012I( _nOpc )

Local _xRet		:= NIL
Local _cQuery	:= ''
Local _cAlias	:= ''

//====================================================================================================
// (1) - Inicializador do campo C�digo da Tabela
//====================================================================================================
If _nOpc == 1
	
	_cQuery := " SELECT "
	_cQuery += "     NVL( MAX( ZF1.ZF1_CODREG ) , '0' ) AS CODIGO "
	_cQuery += " FROM  "+ RETSQLNAME('ZF1') +" ZF1 "
	_cQuery += " WHERE "+ RETSQLCOND('ZF1')
	
	_cAlias := GetNextAlias()
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->( !Eof() )
		_xRet := StrZero( Val( (_cAlias)->CODIGO ) , TamSX3('ZF1_CODREG')[01] )
	Else
		_xRet := StrZero( 0 , TamSX3('ZF1_CODREG')[01] )
	EndIf
	
	(_cAlias)->( DBCloseArea() )
	
	_xRet := Soma1( _xRet )
	
	While !MayIUseCod( 'ZF1_CODREG_'+ _xRet )
		_xRet := Soma1( _xRet )
	EndDo
	
EndIf

Return( _xRet )