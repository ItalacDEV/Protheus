/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MCOM012
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 01/11/2019
===============================================================================================================================
Descri��o---------: Rotina para reprocessar todos os CT-es listados com erro de processamento. Rotina necess�ria porque a TOTVS
					resolveu validar se a NF-e referenciada est� lan�ada na SF1 (COM044). Todos os CT-es do leite est�o ficando
					na lista de erros e precisando ser reprocessados. Chamado 31060
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM012

Local _cQuery 	:= ""
Local _lRet 	:= .T.

If MsgYesNo("Confirma o reprocessamento de todos os CT-es que est�o na fila de erros?","MCOM01201" )
	
	_cQuery:=" UPDATE "+RETSQLNAME('CKO')+" SET CKO_FLAG = '0'"
	_cQuery+="   WHERE D_E_L_E_T_ = ' '"
	_cQuery+="   AND CKO_FLAG = '2'"
	_cQuery+="   AND CKO_CODEDI = '214'"
	_cQuery+="   AND CKO_FILPRO = '"+cFilAnt+"'"
	
	If TCSqlExec( _cQuery ) < 0
		_lRet := .F.
		MsgStop("Erro ao atualizar flag dos CT-es: "+AllTrim(TCSQLError()),"MCOM01202")
	Else
		MsgInfo("CT-es retornados para a fila de processamento!","MCOM01203")
	EndIf
EndIf
	
Return