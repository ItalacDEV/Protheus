/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 21/09/2015 | Foi implementada a grava��o do Aprovador da Solicita��o de Compras. Chamado 10999
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 24/11/2015 | Foi inserido o tratamento do novo campo de Observa��o no cabe�alho da SC. Chamado 12838
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT110END
Autor-------------: Tiago Correa Castro
Data da Criacao---: 31/07/2008
===============================================================================================================================
Descri��o---------: Ponto de Entrada para gravar dados da Aprovacao da Solicitacao de Compras
					Localiza��o: Function A110APROV - Fun��o da Solicita��o de Compras responsavel pela aprova��o das SCs
					Em que Ponto: Ap�s o acionamento dos bot�es Solicita��o Aprovada, Rejeita ou Bloqueada, deve ser utilizado 
					para valida��es do usuario ap�s a execu��o das a��es dos bot�es.
===============================================================================================================================
Parametros--------: Paramixb[1] -> C -> Numero da Solicita��o de compras
					Paramixb[2] -> N -> 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT110END

Local _aArea	:= GetArea()
Local nOpca		:= PARAMIXB[2]       // 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear
Local _cUsu		:= __cUserId

If nOpca == 1
	RecLock("SC1",.F.)
		SC1->C1_APROV	:= "L"
		SC1->C1_I_DTAPR	:= DATE()
		SC1->C1_I_HRAPR	:= TIME()
		SC1->C1_I_APROV	:= _cUsu
		SC1->C1_I_OBSAP	:= "SC Aprovada via acesso ao Protheus"
	MsUnLock()
ElseIf nOpca == 2
	RecLock("SC1",.F.)
		SC1->C1_APROV	:= "R"
		SC1->C1_I_DTAPR	:= DATE()
		SC1->C1_I_HRAPR	:= TIME()
		SC1->C1_I_APROV	:= _cUsu
		SC1->C1_I_OBSAP	:= "SC Rejeitada via acesso ao Protheus"
	MsUnLock()
ElseIf nOpca == 3
	RecLock("SC1",.F.)
		SC1->C1_APROV	:= "B"
		SC1->C1_I_DTAPR	:= StoD("")
		SC1->C1_I_HRAPR	:= ""
		SC1->C1_I_OBSAP	:= "SC Bloqueada via acesso ao Protheus"
	MsUnLock()
EndIf

RestArea(_aArea)
Return