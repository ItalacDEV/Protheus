/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 18/06/2021 | Inclu�da nova situa��o para troca da s�rie. Chamado 36876
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 
/*
===============================================================================================================================
Programa----------: A140IDOC
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/04/2017
===============================================================================================================================
Descri��o---------: O Ponto de Entrada A140IDOC � utilizado para manipular o n�mero e a s�rie da NFe importada por meio do TOTVS
					Colabora��o. O Ponto de Entrada � executado ao processar a importa��o de uma NFe por meio do TOTVS Colabora��o.
===============================================================================================================================
Parametros--------: PARAMIXB[1]: String, contendo o n�mero do documento. 
					PARAMIXB[2]: String, contendo a s�rie do documento.
					PARAMIXB[3]: String, contendo o c�digo do fornecedor.
					PARAMIXB[4]: String, contendo a loja do fornecedor.
===============================================================================================================================
Retorno-----------: Array "aRet" de 2 posi��es, no seguinte formato: 
					aRet[1] - String - Numero do documento - Obrigat�rio
					aRet[2] - String - Serie do documento - Obrigat�rio
					aRet[3] - String - C�digo do Fornecedor - Opcional
					aRet[4] - String - Loja do Fornecedor - Opcional
===============================================================================================================================
*/
User Function A140IDOC()

Local _aRet	 := PARAMIXB
Local _aArea := GetArea()

DBSelectArea('SF1')
SF1->( DBSetOrder(1) )
If SF1->( DBSeek( xFilial('SF1') + _aRet[01] + _aRet[02] + _aRet[03] + _aRet[04] ) ) 
	While !SF1->(EOF()) .And. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)==(xFilial('SF1') + _aRet[01] + _aRet[02] + _aRet[03] + _aRet[04]);
		.And. ((SF1->F1_FORMUL == ' ' .And. !AllTrim(SF1->F1_ESPECIE)=='SPED') .Or. (SF1->F1_FORMUL == 'S'))
		_aRet[02]:=PadL(AllTrim(_aRet[02]),3,'0')
		SF1->(DBSkip())
	EndDo
EndIf

RestArea(_aArea)

Return _aRet
