/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  |13/07/2022| Chamado 43230. Ajuste para inclusão de parametro para comparação com B1_TIPO
Lucas Borges  |07/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MT120QRY
Autor-------------: Alex Wallauer
Data da Criacao---: 21/03/2022
Descrição---------: P.E. para filtrar o browse dos pedidos de compras, MATA120.PRW. Chamado 38650
Parametros--------: Nenhum
Retorno-----------: lRet -> cFilQuery
===============================================================================================================================
*/
USER FUNCTION MT120QRY() 
LOCAL cFilQuery  := ""
Local _cGrpLeite := U_ItGetMV("IT_GRPFLEIT","000008,000009,000010,000011")   
Local _cPCGERAL  := U_ItGetMV("IT_PCGERAL"," ")   
Local _cTipos    := U_ItGetMV("IT_TPPRDPC","MP,PP,PI" ) 
SY1->(dbSetOrder(3))
SY1->(dbSeek(xFilial("SY1") + ALLTRIM(__cUserID)))
IF !SY1->Y1_COD $ _cPCGERAL
   IF SY1->Y1_GRUPCOM $ _cGrpLeite
      cFilQuery+=" C7_PRODUTO IN (SELECT B1_COD FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = ' ' AND B1_TIPO IN "+ FormatIn(_cTipos,";") + ")"
   ELSE
      cFilQuery+=" C7_PRODUTO IN (SELECT B1_COD FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = ' ' AND B1_TIPO NOT IN "+ FormatIn(_cTipos,";") + ")"
   ENDIF
ENDIF
SY1->(dbSetOrder(1))
RETURN cFilQuery
