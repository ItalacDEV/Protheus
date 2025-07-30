/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre V. | 01/10/2015 | Ajuste na valida��o do acesso dos usu�rios para tratar corretamente o retorno da fun��o e exibir
              |            | corretamente as mensagens de ajuda. Chamado 12110
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre V. | 22/12/2015 | Tratativa na cl�usula "ORDER BY" para remover a refer�ncia num�rica. Chamado 13062
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#Include "FwMVCDef.ch"

/*
===============================================================================================================================
Programa--------: AOMS069
Autor-----------: Alexandre Villar
Data da Criacao-: 25/08/2015
===============================================================================================================================
Descri��o-------: Cadastro das tabelas de pre�o para venda de produtos � funcion�rios
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS069()

Local _oBrowse	:= Nil
Local _xAcesso	:= U_ITACSUSR( 'ZZL_ADMPFU' , 'S' )

If ValType( _xAcesso ) == 'N' .And. _xAcesso == 0

	Aviso( 'Aten��o!' , 'Usu�rio n�o est� cadastrado na Gest�o de Usu�rios do Configurador Italac!'					, {'Fechar'} )
	Return()

ElseIf !_xAcesso
	
	Aviso( 'Aten��o!' , 'Usu�rio sem acesso �s rotinas de cadastro da tabela de pre�os de venda � funcion�rios!'	, {'Fechar'} )
	Return()
	
EndIf

//====================================================================================================
// Configura e inicializa a Classe do Browse
//====================================================================================================
_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( "Z11" )
_oBrowse:SetMenuDef( 'AOMS069' )
_oBrowse:SetDescription( "Tabela de pre�os de produtos - vendas para funcion�rios" )
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa--------: MenuDef
Autor-----------: Alexandre Villar
Data da Criacao-: 25/08/2015
===============================================================================================================================
Descri��o-------: Rotina de defini��o autom�tica do menu via MVC
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef()
Return( FWMVCMenu( 'AOMS069' ) )

/*
===============================================================================================================================
Programa--------: ModelDef
Autor-----------: Alexandre Villar
Data da Criacao-: 25/08/2015
===============================================================================================================================
Descri��o-------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: oModel - Objeto do modelo de dados do MVC
===============================================================================================================================
*/
Static Function ModelDef()

//====================================================================================================
// Inicializa a estrutura do modelo de dados
//====================================================================================================
Local _aGatAux	:= {}
Local _oStrCAB	:= FWFormStruct( 1 , "Z11" , {|_cCampo| AOMS069CPO( _cCampo , 1 ) } )
Local _oStrITN	:= FWFormStruct( 1 , "Z11" , {|_cCampo| AOMS069CPO( _cCampo , 2 ) } )
Local _oModel	:= Nil
Local _bValid	:= {|_oModel| AOMS069INC() }

_aGatAux := FwStruTrigger( 'Z11_CODPRD' , 'Z11_DESPRD'	, 'SB1->B1_DESC'	, .T. , 'SB1' , 1 , 'xFilial("SB1")+M->Z11_CODPRD' )
_oStrITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'Z11_CODPRD' , 'Z11_UM'		, 'SB1->B1_UM'		, .T. , 'SB1' , 1 , 'xFilial("SB1")+M->Z11_CODPRD' )
_oStrITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

//====================================================================================================
// Inicializa e configura o modelo de dados
//====================================================================================================
_oModel := MPFormModel():New( "AOMS069M" ,, _bValid )

_oModel:SetDescription( 'Tabela de Pre�os' )

_oModel:AddFields( 'Z11MASTER' ,				, _oStrCAB )
_oModel:AddGrid(   'Z11DETAIL' , "Z11MASTER"	, _oStrITN )

_oModel:GetModel( 'Z11MASTER' ):SetDescription( 'Configura��o da Tabela'	)
_oModel:GetModel( 'Z11DETAIL' ):SetDescription( 'Configura��o dos Produtos'	)

_oModel:SetRelation( "Z11DETAIL" , {	{ "Z11_FILIAL"	, 'xFilial("Z11")'	} ,;
										{ "Z11_CODTAB"	, "Z11_CODTAB"		} ,;
										{ "Z11_FILTAB"	, "Z11_FILTAB"		} ,;
										{ "Z11_DATINI"	, "Z11_DATINI"		} ,;
										{ "Z11_DATFIM"	, "Z11_DATFIM"		}  } , Z11->( IndexKey( 1 ) ) )

_oModel:GetModel( 'Z11DETAIL' ):SetUniqueLine( { 'Z11_CODPRD' } )

_oModel:SetPrimaryKey( { 'Z11_FILIAL' , 'Z11_CODTAB' , 'Z11_FILTAB' } )

Return( _oModel )

/*
===============================================================================================================================
Programa--------: ViewDef
Autor-----------: Alexandre Villar
Data da Criacao-: 25/08/2015
===============================================================================================================================
Descri��o-------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function ViewDef()

Local _oStrCAB	:= FWFormStruct( 2 , "Z11" , {|_cCampo| AOMS069CPO( _cCampo , 1 ) } )
Local _oStrITN	:= FWFormStruct( 2 , "Z11" , {|_cCampo| AOMS069CPO( _cCampo , 2 ) } )
Local _oModel	:= FWLoadModel( "AOMS069" )
Local _oView	:= Nil

//====================================================================================================
// Inicializa o Objeto da View
//====================================================================================================
_oView := FWFormView():New()

_oView:SetModel( _oModel )

_oView:AddField( "VIEW_CAB" , _oStrCAB , "Z11MASTER" )
_oView:AddGrid(  "VIEW_ITN" , _oStrITN , "Z11DETAIL" )

_oView:CreateHorizontalBox( 'BOX0101' , 020 )
_oView:CreateHorizontalBox( 'BOX0102' , 080 )

_oView:SetOwnerView( "VIEW_CAB" , "BOX0101" )
_oView:SetOwnerView( "VIEW_ITN" , "BOX0102" )

_oView:AddUserButton( 'Carregar Produtos' , 'CLIPS' , {|| AOMS069CAR() } )

Return( _oView )

/*
===============================================================================================================================
Programa--------: AOMS069INC
Autor-----------: Alexandre Villar
Data da Criacao-: 25/08/2015
===============================================================================================================================
Descri��o-------: Valida��o da inclus�o de registros
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function AOMS069INC()

Local _lRet		:= .T.
Local _aInfHlp	:= {}
Local _aFilDup	:= {}
Local _aArea	:= GetArea()
Local _oModel	:= FWModelActive()
Local _nOper	:= _oModel:GetOperation()
Local _nI		:= 0

If _nOper == MODEL_OPERATION_INSERT
	
	_cFilAux := AllTrim( _oModel:GetValue( 'Z11MASTER' , 'Z11_FILTAB' ) ) +';'
	_aFilDup := StrTokArr( _cFilAux , ';' )
	
	For _nI := 1 To Len( _aFilDup )
		
		DBSelectArea('Z11')
		Z11->( DBGoTop() )
		While Z11->( !Eof() )
			
			If _aFilDup[_nI] $ AllTrim( Z11->Z11_FILTAB )
				
				_aInfHlp := {}
				//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|       |....:....|....:....|....:....|....:....|
				aAdd( _aInfHlp , { "A Filial ["+ _aFilDup[_nI] +"] j� foi configurada na"	, " tabela ["+ Z11->Z11_CODTAB +"] e n�o pode ser gravada "	, " em duplicidade!"	} )
				aAdd( _aInfHlp , { "Verifique as configura��es da tabela"		, " atual e caso necess�rio altere a tabela"	, " existente."									} )
				
				U_ITCADHLP( _aInfHlp , "AOMS06901" )
				
				_lRet := .F.
				Exit
				
			EndIf
			
		Z11->( DBSkip() )
		EndDo
		
		If !_lRet
			Exit
		EndIf
		
	Next _nI
	
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa--------: AOMS069CPO
Autor-----------: Alexandre Villar
Data da Criacao-: 25/08/2015
===============================================================================================================================
Descri��o-------: Configura��o da inicializa��o de campos na tela
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function AOMS069CPO( _cCampo , _nOpc )

Local _lRet := AllTrim(_cCampo) $ 'Z11_CODTAB;Z11_FILTAB;Z11_DATINI;Z11_DATFIM'

If _nOpc == 2
	_lRet := !_lRet
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004L
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Valida��o da inclus�o de novas linhas na estrutura de regras
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS069L(_oView)

Local _oModel	:= FWModelActive()
Local _oModDet	:= _oModel:GetModel( 'Z11DETAIL' )

If !Inclui .And. _oModDet:IsInserted()
	
	If Empty( _oModDet:GetValue('Z11_CODPRD') )
		_oModDet:LoadValue( 'Z11_DESPRD'	, '' )
	EndIf
	
	If Empty( _oModDet:GetValue('Z11_CODPRD') )
		_oModDet:LoadValue( 'Z11_UM'		, '' )
	EndIf
	
	_oView:Refresh()
	_oView:ACURRENTSELECT[1] := 'VIEW_ITN'
	_oView:ACURRENTSELECT[2] := 'Z11_CODPRD'
	
EndIf

Return()

/*
===============================================================================================================================
Programa--------: AOMS069CAR
Autor-----------: Alexandre Villar
Data da Criacao-: 01/09/2015
===============================================================================================================================
Descri��o-------: Rotina para carregar automaticamente todos os produtos na tabela pre�os
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS069CAR()

Local _oModel	:= FWModelActive()
Local _oView	:= FWViewActive()
Local _oZ11DET	:= _oModel:GetModel( "Z11DETAIL" )

Local _cQuery	:= ''
Local _cAlias	:= ''

Local _nLenAux	:= _oZ11DET:Length()
Local _nI		:= 0

If _nLenAux > 1
	
	_lExec := .F.
	
	If MsgYesNo( 'Ao fazer a carga de todos os produtos os registros da tabela atual ser�o perdidos! Deseja continuar?' )
		_lExec := .T.
	EndIf
	
Else

_lExec := .T.

EndIf
		
If _lExec

	_cQuery := " SELECT "
	_cQuery += "     SB1.B1_COD		AS CODSB1,"
	_cQuery += "     SB1.R_E_C_N_O_ AS REGSB1 "
	_cQuery += " FROM  "+ RETSQLNAME('SB1') +" SB1 "
	_cQuery += " WHERE "+ RETSQLCOND('SB1')
	_cQuery += " AND SB1.B1_TIPO   = 'PA' "
	_cQuery += " AND SB1.B1_MSBLQL <> '1' "
	_cQuery += " ORDER BY SB1.B1_COD "
	
	_cAlias := GetNextAlias()
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	While (_cAlias)->( !Eof() )
		
		_nI++
		
		If _nI > _oZ11DET:Length()
			_oZ11DET:AddLine()
		EndIf
		
		_oZ11DET:GoLine( _nI )
		
		DBSelectArea('SB1')
		SB1->( DBGoTo( (_cAlias)->REGSB1 ) )
		
		_oZ11DET:LoadValue( 'Z11_CODPRD'	, SB1->B1_COD				)
		_oZ11DET:LoadValue( 'Z11_DESPRD'	, AllTrim( SB1->B1_DESC )	)
		_oZ11DET:LoadValue( 'Z11_STATUS'	, 'S'						)
		_oZ11DET:LoadValue( 'Z11_UM'		, SB1->B1_UM				)
		_oZ11DET:LoadValue( 'Z11_VALOR'		, 0							)
		
		
	(_cAlias)->( DBSkip() )
	EndDo
	
	_oView:Refresh()
	_oZ11DET:GoLine(1)
	
EndIf

Return()