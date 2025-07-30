/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 20/08/2021 | Usu�rio j� conseguiu mudar de ideia sobre os campos a serem obrigat�rios. Chamado 37531
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/12/2021 | Corrigida valida��o para n�o ser chamada na exclus�o. Chamado 38586
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 13/05/2022 | Ajustado para validar se os dados n�o foram alterados. Chamado 40106
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MTCHKNFE
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 19/08/2021
===============================================================================================================================
Descrição---------: Ponto de Entrada para valida��es adicionais dos campos contidos na Pasta "Nota Fiscal Eletr�nica".Ser� 
						sempre executado na confirma��o da nota fiscal. Chamado 37521
===============================================================================================================================
Parametros--------: aNfetr -> A -> Array com os campos da Pasta "Nota Fiscal Eletr�nica".
					ParamIxb[1][1] -> C -> F1_NFELETR
					ParamIxb[1][2] -> C -> F1_CODNFE
					ParamIxb[1][3] -> D -> F1_EMINFE
					ParamIxb[1][4] -> C -> F1_HORNFE
					ParamIxb[1][5] -> N -> F1_CREDNFE
					ParamIxb[1][6] -> C -> F1_NUMRPS
					ParamIxb[1][7] -> C -> F1_MENNOTA
					ParamIxb[1][8] -> C -> F1_MENPAD

===============================================================================================================================
Retorno-----------: _lRet -> L -> .T. - Passou pela valida��o / .F. - N�o passou pela valida��o
===============================================================================================================================
*/
User Function MTCHKNFE

Local _lITVNFDS := .F.
Local _lRet	:= .T.
If AllTrim(cEspecie) == "NFDS" .And. (Inclui .Or. Altera)
	_lITVNFDS := SuperGetMV("IT_VALNFDS",.F.,.F.)
	If _lITVNFDS .And. ((Empty(PARAMIXB[1][1]) .Or. Empty(PARAMIXB[1][2]) .Or. Empty(PARAMIXB[1][3]));
		.Or. !(ParamIxb[1][1]==cNFiscal .And. ParamIxb[1][3]==dDEmissao))
		_lRet := .F.
		If l103Auto
			AutoGRLog("MTCHKNFE001"+CRLF+"Verifique os campos obrigat�rios para documentos cuja esp�cie � NFDS na aba Nota Fiscal Eletr�nica,D�vidas, acionar o Departamento Fiscal.")
		Else
			MsgAlert("Verifique os campos obrigat�rios para documentos cuja esp�cie � NFDS na aba Nota Fiscal Eletr�nica. D�vidas, acionar o Departamento Fiscal.","MTCHKNFE001")
		EndIf
	EndIf
EndIf
Return (_lRet)
