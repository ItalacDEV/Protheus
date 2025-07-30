 /*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 30/12/21   | Nova validacao para deletar o SCR: LEFT(ZZL->ZZL_MATRIC,2) <> SCR->CR_FILIAL. Chamado: 38778
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 07/01/22   | Mais uma validacao para deletar o SCR: !SCR->CR_FILIAL $ ZZL->ZZL_FILAPSA. Chamado: 38855
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: MT105FIM
Autor-------------: Alex Wallauer
Data da Criacao---: 25/06/2020
===============================================================================================================================
Descrição---------: Este Ponto de Entrada e no final da inclusao ou alteracao de dados no arquivo SCP. Chamado 33355
===============================================================================================================================
Parametros--------: PARAMIXB => nOpcao (Numerico)
                    [1] Inclusado
                    [2] Alteracao
                    [3] Exclusao
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT105FIM()
Local _aArea:= GetArea()
Local nOpcao:= PARAMIXB
Local _cNum	:= SCP->CP_NUM
Local _cGrup:= SCP->CP_I_GRAPR
Local nLenSC:= LEN(SCP->CP_NUM)//-- Controle de tamanho de campo do documento

IF nOpcao = 3 .OR. ISINCALLSTACK("MDTA695") //Exclusao 
   RETURN .T.
ENDIF		

DBSELECTAREA("SCR")
DBCOMMIT()
DBCOMMITALL()

SCR->(dbSetOrder(1))
SCR->(DBSEEK(xfilial("SCR")+"SA"+ _cNum))

DO WHILE (!SCR->(EOF()) .AND. ( SCR->CR_FILIAL+SCR->CR_TIPO+LEFT(SCR->CR_NUM,nLenSC)  == xfilial("SCR")+"SA"+ _cNum ) )

   _cGRPAPR := Posicione("ZZL",3,xFilial("ZZL")+SCR->CR_USER,"ZZL_GRPAPR")

   IF (_cGrup <> _cGRPAPR .AND. _cGRPAPR <> "0") .OR. IF( ZZL->(FIELDPOS("ZZL_FLAPSA")) <> 0 .AND. !EMPTY(ZZL->ZZL_FLAPSA),!SCR->CR_FILIAL $ ZZL->ZZL_FLAPSA,LEFT(ZZL->ZZL_MATRIC,2) <> SCR->CR_FILIAL)
	   SCR->(RECLOCK("SCR",.F.))
	   SCR->(DBDELETE())
	   SCR->(MsUnlock())
   ENDIF
   SCR->(DBSKIP())

ENDDO
RestArea(_aArea)		
RETURN .T.
