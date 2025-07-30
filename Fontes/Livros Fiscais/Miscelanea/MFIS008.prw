/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO                             
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include 'protheus.ch'
#include "topconn.ch"

/*
===============================================================================================================================
Programa--------: MFIS008
Autor-----------: Igor Melgaco
Data da Criacao-: 03/05/2022
===============================================================================================================================
Descrição-------: CHAMADO 39972 - Rotina para limpeza de códigos de ajuste com valor zerado da Tabela CDA.
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================

Esta rotina é uma medida paliativa para atender a usuária até que o departamento 
fiscal de Corumbaiba, consiga analisar e separar quais são as operações isentas que 
não geram valor, e assim crie uma TES separada sem o código de ajuste amarrado.

*/
User Function MFIS008()

   fwMsgRun( , {|| MFIS008A() } ,'Processando...' , 'Aguarde!' )

Return


/*
===============================================================================================================================
Programa----------: MFIS008A
Autor-------------: Igor Melgaco
Data da Criacao---: 03/05/2022
===============================================================================================================================
Descrição---------: Executa a query e o processamento da exclusão
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS008A()
Local cQuery   := ""
Local cCodAjus := U_ITGETMV("ITCODLAN",'GO40000029') 
Local i        := 0
Local aLog     := {}
Local aCab     := {}
Local _cTitulo := "Registros a deletar"

aCab := {"","Filial","Especie","Numero","Serie","Cliente/Fornecedor","Loja","Valor","Cod. Lanc.","Recno"}

If Select("TRB_CDA") <> 0
	TRB_CDA->( DBCloseArea() )
EndIf

cQuery := " SELECT CDA_FILIAL,CDA_ESPECI,CDA_NUMERO,CDA_SERIE,CDA_CLIFOR,CDA_LOJA, CDA_VALOR,CDA_CODLAN,R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("CDA") + " CDA " 
cQuery += " WHERE CDA_VALOR = 0 "
cQuery += "  AND CDA_CODLAN = '"+cCodAjus+"' "
cQuery += "  AND D_E_L_E_T_ = ' ' "
cQuery += "  AND CDA_FILIAL = '" + xFilial("CDA") + "' "

TCQUERY cQuery NEW ALIAS "TRB_CDA"

DbSelectArea("TRB_CDA")
TRB_CDA->( DBGoTop() )
While TRB_CDA->(!EOF())

   AADD(aLog,{.F.,;
   TRB_CDA->CDA_FILIAL,;
   TRB_CDA->CDA_ESPECI,;
   TRB_CDA->CDA_NUMERO,;
   TRB_CDA->CDA_SERIE,;
   TRB_CDA->CDA_CLIFOR,;
   TRB_CDA->CDA_LOJA,;
   TRB_CDA->CDA_VALOR,;
   TRB_CDA->CDA_CODLAN,;
   TRB_CDA->R_E_C_N_O_})
   
   TRB_CDA->(DbSkip())

EndDo

TRB_CDA->(DbCloseArea())

If Len(aLog) > 0
   _lRet := U_ITListBox(_cTitulo,aCab,aLog   , .T.    , 2    ,_cTitulo /*_cMsgTop*/,          ,        ,         ,     ,        ,          ,       ,         ,          , /*bCondMarca*/)

   If _lRet

      For i := 1 to Len(aLog)
         If aLog[i,1]
            DbSelectArea("CDA")
            CDA->(DbGoTo(aLog[i,10]))
            CDA->(RecLock("CDA", .F.))
            DbDelete()
            MsUnlock()

         EndIf
      Next

      U_ITMSG("Processamento concluído!","Atenção",,2)

   EndIf
Else
   U_ITMSG("Não encontrado registros para deleção!","Atenção",,2)
EndIf

Return
