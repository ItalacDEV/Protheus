/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 07/05/2018 | Padroniza��o dos cabe�alhos dos fontes e fun��es do m�dulo financeiro. Chamado 24726.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*
===============================================================================================================================
Programa--------: AFIN005
Autor-----------: Alexandre Villar
Data da Criacao-: 14/01/2016
===============================================================================================================================
Descri��o-------: Rotina para cadastrar o hist�rico de altera��o nos t�tulos de contas a receber
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AFIN005()

Local _oBrowse	:= Nil
Local _aRotAux	:= aRotina

aRotina := {}

AADD( aRotina , { "Pesquisar"	, "AxPesqui" , 0 , 1 } )
AADD( aRotina , { "Visualizar"	, "AxVisual" , 0 , 2 } )

If Type( 'Altera' ) == 'L' .And. Altera

	AADD( aRotina , { "Incluir"		, "AxInclui" , 0 , 3 } )
	AADD( aRotina , { "Alterar"		, "AxAltera" , 0 , 4 } )
	AADD( aRotina , { "Excluir"		, "AxDeleta" , 0 , 5 } )

EndIf

_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( "Z15" )
_oBrowse:SetDescription( "Hist�rico de altera��es do t�tulo: "+ SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) )
_oBrowse:DisableDetails()
_oBrowse:SetFilterDefault( ' Z15->Z15_CHAVE == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) ' )
_oBrowse:Activate()

aRotina := _aRotAux

Return()

/*
===============================================================================================================================
Programa--------: AFIN005S
Autor-----------: Alexandre Villar
Data da Criacao-: 14/01/2016
===============================================================================================================================
Descri��o-------: Rotina de inicializador padr�o para o campo sequencia
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AFIN005S()

Local _cRet := ''

DBSelectArea('Z15')
Z15->( DBSetOrder(1) )
If Z15->( DBSeek( xFilial('Z15') + SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) ) )
	
	While Z15->( !Eof() ) .And. Z15->( Z15_FILIAL + Z15_CHAVE ) == xFilial('Z15') + SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
		
		_cRet := Z15->Z15_SEQ
		
	Z15->( DBSkip() )
	EndDo
	
	_cRet := Soma1( _cRet )
	
Else

	_cRet := '001'
	
EndIf

Return( _cRet )