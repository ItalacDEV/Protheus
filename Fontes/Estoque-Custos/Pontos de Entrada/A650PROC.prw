/*
======================================================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
======================================================================================================================================================
   Autor      |    Data    |                                             Motivo                                            
------------------------------------------------------------------------------------------------------------------------------------------------------
Andre Lisboa  | 27/11/2017 | Fechado Alias "TRB" para não causar problema em outras rotinas - Chamado 22556
------------------------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 07/12/2018 | Nas OPs automáticas, o CC da OP Pai tem que ser o mesmo p/ todas as OP FIlhas - Chamado 27300
------------------------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 07/11/2019 | Correção nas OPs automáticas, o CC de cada OP Pai tem que ser o mesmo p/ todas as OP FIlhas - Chamado 31126
------------------------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 09/03/2019 | Correção da SELECT DO SD4 para gravar a descricao de item com mais de um lote - Chamado 34943
======================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "vKey.ch"
#Include "TBICONN.CH"
#include "ap5mail.ch"  
#include "Protheus.ch" 

/*
===============================================================================================================================
Programa----------: A650PROC
Autor-------------: Erich Buttner
Data da Criacao---: 25/09/2013
===============================================================================================================================
Descricao---------: Ponto de entrada no MATA650.PRX executado apos o processamento da inclusao da Op e os pedidos de compras.  
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

USER FUNCTION A650PROC ()

//Local TRB := CriaTrab(Nil,.F.)
//Local TRB1 := CriaTrab(Nil,.F.)
LOCAL _cCentroC:=""

cSc2:= " SELECT C2_NUM cNum, C2_ITEM cIt, C2_SEQUEN cSeq FROM "+RetSqlName("SC2")
cSc2+= " WHERE C2_I_DESC = ' ' AND C2_CC = ' ' "
cSc2+= " AND C2_FILIAL = '"+xFilial("SC2")+"' "
cSc2+= " AND D_E_L_E_T_ = ' ' "

cSc2:= ChangeQuery(cSc2)

//============================================
//Fecha Alias se tiver em uso
//============================================

If Select("TRB") >0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

//============================================
// Monta Area de Trabalho executando a Query
//============================================
TCQUERY cSc2 New Alias "TRB"
dbSelectArea("TRB")

dbGoTop()

//MSGINFO("1 OP: "+SC2->C2_NUM +" CC: "+ SC2->C2_CC+" SEQ: "+SC2->C2_SEQUEN)	

SC2->(DBSETORDER(1))

//MSGINFO("2 OP: "+SC2->C2_NUM +" CC: "+ SC2->C2_CC+" SEQ: "+SC2->C2_SEQUEN)	
   
DO While TRB->(!(Eof()))

    If SC2->(DBSEEK(xFilial("SC2")+TRB->cNum+TRB->cIt+"001"))
       _cCentroC:=SC2->C2_CC
    ENDIF
	
	If SC2->(DbSeek(xFilial("SC2")+TRB->cNum+TRB->cIt+TRB->cSeq))
		SC2->(RecLock("SC2",.F.))
		SC2->C2_I_DESC := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SC2->C2_PRODUTO,1,"")
		SC2->C2_CC:=_cCentroC
        SC2->(MsUnLock())
   	EndIf

//     MSGINFO(" OP: "+SC2->C2_NUM +" CC: "+ SC2->C2_CC+" SEQ: "+C2_SEQUEN)	
	
	TRB->(DbSkip())

ENDDO

cSd4:= " SELECT D4.R_E_C_N_O_ RECSD4 ,D4_OP cNum, D4_COD COD, B1_DESC DESCR, D4_LOCAL ARM FROM SD4010 D4, SB1010 B1 "
cSd4+= " WHERE D4_I_NPROD = ' '  "
cSd4+= " AND D4_COD = B1_COD "
cSd4+= " AND D4_FILIAL = '"+xFilial("SD4")+"' "
cSd4+= " AND B1_FILIAL = '"+xFilial("SB1")+"' "
cSd4+= " AND D4.D_E_L_E_T_ = ' ' "
cSd4+= " AND B1.D_E_L_E_T_ = ' ' "

cSd4:= ChangeQuery(cSd4)

//============================================
//Fecha Alias se tiver em uso
//============================================
If Select("TRB1") >0
	dbSelectArea("TRB1")
	dbCloseArea()
Endif

//============================================
// Monta Area de Trabalho executando a Query
//============================================
TCQUERY cSd4 New Alias "TRB1"
dbSelectArea("TRB1")

dbGoTop()

	
DO While TRB1->(!Eof())

	SD4->(DBGOTO(TRB1->RECSD4))
	SD4->(RECLOCK("SD4",.F.))
	SD4->D4_I_NPROD := TRB1->DESCR
    SD4->(MSUNLOCK())
	TRB1->(DBSKIP())

EndDo

//============================================
//Fecha Alias se tiver em uso
//============================================
If Select("TRB") >0
	dbSelectArea("TRB")
	dbCloseArea()
Endif
    

RETURN 
