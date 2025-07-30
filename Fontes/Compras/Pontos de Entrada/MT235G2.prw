/*
=====================================================================================================================================
         							ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																|
------------:-----------:-----------------------------------------------------------------------------------------------------------:
Darcio		| 15/10/15	| Criada a valida��o na elimina��o de res�duo, onde o usu�rio corrente somente poder� eliminar res�duo caso |
			|			| este seja o aprovador da SC, ou o solicitante da SC ou caso este seja administrador de SC's. Chamado:12316|
=====================================================================================================================================
*/
#include "rwmake.ch"
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: MT235G2
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 15/10/2015
===============================================================================================================================
Descri��o---------: LOCALIZA��O : Fun��es MA235PC(), MA235CP(), MA235SC()
                  : EM QUE PONTO : Antes de processar a elimina��o de cada Pedido de Compra, por residuo.
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: PARAMIXB[1] - Alias do arq. em verifica��o: "SC7", "SC3" ou "SC1"
------------------: PARAMIXB[2] - N�mero indicativo do arq. em verifica��o: 1 para "SC7", 2 para "SC3", 3 para "SC1"
===============================================================================================================================
Retorno-----------: lRet - .T. permite eliminar os res�duos e .F. n�o elimina os res�duos.
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: Compras
===============================================================================================================================
*/
User Function MT235G2()
Local _aArea	:= GetArea()  
Local _lRet		:= .T.
Local _cAlias	:= ParamIXB[1]
Local _nIndex	:= ParamIXB[2]
Local _xValid	:= U_ITACSUSR( 'ZZL_ADMSC' , 'S' )

If _nIndex == 3		//Valida��o apenas para solicita��o de compras
	dbSelectArea("SC1")
	dbGoTo((_cAlias)->SC1RECNO)
	
	If ValType(_xValid) == 'L' .And. !_xValid
		If SC1->C1_I_CODAP <> __cUserID
			If SC1->C1_I_CDSOL <> __cUserID
				_lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(_aArea)
Return(_lRet)