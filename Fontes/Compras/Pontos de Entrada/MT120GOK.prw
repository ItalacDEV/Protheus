/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 04/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 11/04/2022 | Chamado 38650. Altera��es de Conout() para melhor monitoramento.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 24/09/2024 | Chamado 48465. Sanado problemas apresentados no Code Analysis
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT120GOK
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 07/12/2015
===============================================================================================================================
Descri��o---------: Ponto de Entrada executado ap�s a fun��o A120GRAVA e antes da contabiliza��o do pedido de compras
					Localiza��o: Function A120PEDIDO - Fun��o do Pedido de Compras e Autoriza��o de Entrega responsavel pela 
					inclus�o, altera��o, exclus�o e c�pia dos PCs.
					Em que Ponto: Ap�s a execu��o da fun��o de grava��o A120GRAVA e antes da contabiliza��o do Pedido de compras
					/ AE, Pode ser utilizado para qualquer tratamento que o usuario necessite realizar no PC antes da 
					contabiliza��o do mesmo.
===============================================================================================================================
Parametros--------: PARAMIXB[1] -> C -> cA120Num - Numero do Pedido de compras / AE.
					PARAMIXB[2] -> L -> l120Inclui - .T. indica se � inclus�o
					PARAMIXB[3] -> L -> l120Altera - .T. indica se � altera��o
					PARAMIXB[4] -> L -> l120Deleta - .T. indica se � exclus�o
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT120GOK()

Local _cPedido		:= PARAMIXB[1] // Numero do Pedido
Local lAltera		:= PARAMIXB[3] // Altera��o
Local _aArea		:= GetArea()
Local _aAreaSC7		:= SC7->(GetArea())
Local cFilPC		:= U_ItGetMV("IT_FILWFPC","01")
Local lFilPC		:= Iif(cFilAnt $ cFilPC,.T.,.F.)
Local _lHtml		:= .F.
Local _cHtml		:= ""
Local _nPosWRK		:= 0
Local _aHtml		:= {}
Local _nI			:= 0
Local _cArq			:= ""
Local _cHtmlMode	:= "\Workflow\htm\pc_manutencao.htm"

//Codigo do Usuario para tratamento do Pedido de compras antes da Contabiliza��o.

DbSelectArea("SC7")
SC7->(DbSetOrder(1))
SC7->(DbSeek(XFilial("SC7") + _cPedido))

If lAltera
	If !Empty(SC7->C7_I_HTM)
		_lHtml := .T.
		_cHtml := AllTrim(SC7->C7_I_HTM)
	EndIf
EndIf

While SC7->C7_FILIAL + SC7->C7_NUM == XFilial("SC7") + _cPedido
	Reclock("SC7",.F.)
		If lFilPC
			SC7->C7_APROV	:= "PENLIB"
			SC7->C7_CONAPRO	:= "B"
		Else
			SC7->C7_APROV	:= ""
			SC7->C7_CONAPRO	:= "L"
		EndIf
	MsUnLock()
	SC7->(DbSkip())
End

//========================================================================================
//No caso de altera��o do pedido de compras, o sistema trocar� o aquivo a ser apresentado,
//caso j� tenha sido enviado o e-mail de aprova��o.
//========================================================================================
If _lHtml
	_aHtml	:= StrTokArr(_cHtml,"/")
	_nPosWRK:= aScan(_aHtml, {|x| LOWER(x) == "workflow"})
    IF _nPosWRK <> 0
	   For _nI := _nPosWRK To Len(_aHtml)
	       _cArq += "\" + _aHtml[_nI]
	   Next _nI
    EndIf
	If File(_cArq)
		If fErase(_cArq) == 0
			If __CopyFile(_cHtmlMode, _cArq)
			   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MATA120"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MT120GOK01"/*cMsgId*/, "MT120GOK - C�pia de arquivo WFPC de manuten��o efetuada com sucesso. DE: "+_cHtmlMode+" PARA: "+_cArq /*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			Else
			   FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MATA120"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MT120GOK02"/*cMsgId*/, "MT120GOK - Problema na c�pia de arquivo WFPC de manuten��o. DE: "+_cHtmlMode+" PARA: "+_cArq /*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			EndIf
		Else
			FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MATA120"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MT120GOK03"/*cMsgId*/, "MT120GOK - N�o foi poss�vel excluir o arquivo " + _cArq + ".htm" /*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
	EndIf
EndIf

RestArea(_aAreaSC7)
RestArea(_aArea)

Return
