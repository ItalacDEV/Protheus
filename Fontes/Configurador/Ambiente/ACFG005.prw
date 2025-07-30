/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Darcio Sporl  |	10/10/2016 | Rotina criada para fazer a configuração de perguntas por usuários automaticamente. Chamado 17066
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "protheus.ch"      

/*
===============================================================================================================================
Programa----------: ACFG005
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 10/10/2016
===============================================================================================================================
Descrição---------: Rotina criada para fazer configuração de perguntas por usuários automaticamente. Chamado 17066
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACFG005()

Local _oGetCon
Local _oGetGru
Local _oGetSeq
Local _oLabCon
Local _oLabGru
Local _oLabSeq
Local _oSBtCN
Local _oSBtOK
Local _oSBtDel

Local _cGetGru	:= Space(10)
Local _cGetSeq	:= Space(2)
Local _cGetCon	:= Space(250)

Local _nOpc		:= 0
Local _cQry		:= ""

Private _oDlg

DEFINE MSDIALOG _oDlg TITLE "Configuração Perguntas" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL

	@ 005, 006 SAY _oLabGru PROMPT "Grupo de Perguntas:" SIZE 052, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 017, 006 MSGET _oGetGru VAR _cGetGru SIZE 052, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 005, 066 SAY _oLabSeq PROMPT "Sequencia:" SIZE 030, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 017, 066 MSGET _oGetSeq VAR _cGetSeq SIZE 029, 010 OF _oDlg PICTURE "99" COLORS 0, 16777215 PIXEL

	@ 005, 106 SAY _oLabCon PROMPT "Conteúdo:" SIZE 028, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 017, 106 MSGET _oGetCon VAR _cGetCon SIZE 136, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	DEFINE SBUTTON _oSBtOK	FROM 033, 152 TYPE 01 OF _oDlg ENABLE ACTION (_nOpc := 1, _oDlg:End())
	DEFINE SBUTTON _oSBtDel	FROM 033, 184 TYPE 03 OF _oDlg ENABLE ACTION (_nOpc := 2, _oDlg:End())
	DEFINE SBUTTON _oSBtCN	FROM 033, 216 TYPE 02 OF _oDlg ENABLE ACTION _oDlg:End()

ACTIVATE MSDIALOG _oDlg CENTERED

If _nOpc == 1

	_cQry := "SELECT COUNT(*) AS ZZL_REGS "
	_cQry += "FROM " + RetSqlName("ZZL") + " "
	_cQry += "WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "' "
	_cQry += "  AND D_E_L_E_T_ = ' '"

	dbUseArea(.T., 'TOPCONN', tcgenqry(,,_cQry), 'TMPZZL', .F., .T.)

	dbSelectArea("TMPZZL")
	TMPZZL->(dbGoTop())

	If !TMPZZL->(Eof())

		Processa({|| U_CFG005GRV(TMPZZL->ZZL_REGS, _cGetGru, _cGetSeq, _cGetCon, "I") }, "Configuração Perguntas", "Processando, aguarde...", .F.)

	EndIf

	dbSelectArea("TMPZZL")
	TMPZZL->(dbCloseArea())

ElseIf _nOpc == 2

	_cQry := "SELECT COUNT(*) AS ZZL_REGS "
	_cQry += "FROM " + RetSqlName("ZZL") + " "
	_cQry += "WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "' "
	_cQry += "  AND D_E_L_E_T_ = ' '"

	dbUseArea(.T., 'TOPCONN', tcgenqry(,,_cQry), 'TMPZZL', .F., .T.)

	dbSelectArea("TMPZZL")
	TMPZZL->(dbGoTop())

	If !TMPZZL->(Eof())

		Processa({|| U_CFG005GRV(TMPZZL->ZZL_REGS, _cGetGru, _cGetSeq, _cGetCon, "D") }, "Configuração Perguntas", "Processando, aguarde...", .F.)

	EndIf

	dbSelectArea("TMPZZL")
	TMPZZL->(dbCloseArea())

EndIf

Return

/*
===============================================================================================================================
Programa----------: CFG005GRV
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 10/10/2016
===============================================================================================================================
Descrição---------: Função que processa a gravação das perguntas por usuário
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CFG005GRV(_nRegs, _cCodGru, _cCodSeq, _cConteud, _cTipo)
Local _cQry := ""

ProcRegua(_nRegs)

If _cTipo == "I"

	_cQry := "SELECT ZZL_CODUSU "
	_cQry += "FROM " + RetSqlName("ZZL") + " "
	_cQry += "WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "' "
	_cQry += "  AND D_E_L_E_T_ = ' '"
	
	dbUseArea(.T., 'TOPCONN', tcgenqry(,,_cQry), 'TRBZZL', .F., .T.)
	
	dbSelectArea("TRBZZL")
	TRBZZL->(dbGoTop())
	
	While !TRBZZL->(Eof())
	
		IncProc("Gravando dados do usuário " + TRBZZL->ZZL_CODUSU)
	
		dbSelectArea("SXK")
		dbSetOrder(1)
		If DbSeek(_cCodGru + _cCodSeq + "U" + TRBZZL->ZZL_CODUSU)
			RecLock("SXK", .F.)
		Else
			RecLock("SXK", .T.)
		EndIf
	
		SXK->XK_GRUPO	:= _cCodGru
		SXK->XK_SEQ		:= _cCodSeq
		SXK->XK_IDUSER	:= "U" + TRBZZL->ZZL_CODUSU
		SXK->XK_CONTEUD	:= _cConteud
	
		SXK->(MsUnLock())
		TRBZZL->(dbSkip())
	End

	MsgInfo("Foram atualizados [" + AllTrim(Str(_nRegs)) + "] usuários.", "Configuração Perguntas")

ElseIf _cTipo == "D"

	_cQry := "SELECT ZZL_CODUSU "
	_cQry += "FROM " + RetSqlName("ZZL") + " "
	_cQry += "WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "' "
	_cQry += "  AND D_E_L_E_T_ = ' '"
	
	dbUseArea(.T., 'TOPCONN', tcgenqry(,,_cQry), 'TRBZZL', .F., .T.)
	
	dbSelectArea("TRBZZL")
	TRBZZL->(dbGoTop())
	
	While !TRBZZL->(Eof())
	
		IncProc("Gravando dados do usuário " + TRBZZL->ZZL_CODUSU)
	
		dbSelectArea("SXK")
		dbSetOrder(1)
		If DbSeek(_cCodGru + _cCodSeq + "U" + TRBZZL->ZZL_CODUSU)

			RecLock("SXK", .F.)
			SXK->(dbDelete())
			SXK->(MsUnLock())

		EndIf
		TRBZZL->(dbSkip())
	End

	MsgInfo("Foram excluídos [" + AllTrim(Str(_nRegs)) + "] usuários.", "Configuração Perguntas")

EndIf

dbSelectArea("TRBZZL")
TRBZZL->(dbCloseArea())

Return