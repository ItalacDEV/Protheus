/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
Darcio Spörl      | 28/12/2016 | Programa criado para gerar a primeira carga da tabela TN3. Chamado: 18122					  |
===============================================================================================================================
*/
#Include 'Protheus.ch'
#Include 'rwmake.ch'
/*
===============================================================================================================================
Programa----------: MMDT001
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 28/12/2016
===============================================================================================================================
Descrição---------: Rotina criada para gerar a primeira carga das descrições da tabela TN3 Chamado: 18122oe
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/
User Function MMDT001()
Local _oGroup1
Local _oSay1
Local _oSay2
Local _oSay3
Local _oSButton1
Local _oSButton2
Local _lOk	:= .F.

Private _oDlg

DEFINE MSDIALOG _oDlg TITLE "ATUALIZAÇÃO DAS DESCRIÇÕES DOS EPI'S" FROM 000, 000  TO 100, 396 COLORS 0, 16777215 PIXEL

	@ 003, 004 GROUP _oGroup1 TO 036, 195 OF _oDlg COLOR 0, 16777215 PIXEL
	@ 008, 008 SAY _oSay1 PROMPT "Esta rotina tem como função fazer a atualização das descrições dos EPI's" SIZE 190, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 015, 008 SAY _oSay2 PROMPT "Este processo tem a finalidade de criar mais um índice na consulta padrão" SIZE 230, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 022, 008 SAY _oSay3 PROMPT "utilizada na rotina de Funcionários x EPI's, no campo código do EPI." SIZE 144, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	DEFINE SBUTTON _oSButton1 FROM 037, 075 TYPE 01 OF _oDlg ENABLE ACTION (_lOk := .T., _oDlg:End())
	DEFINE SBUTTON _oSButton2 FROM 037, 106 TYPE 02 OF _oDlg ENABLE ACTION (_lOk := .F., _oDlg:End())

ACTIVATE MSDIALOG _oDlg CENTERED

If _lOk
	FwMsgRun( ,{|| RunProc() }, , "Aguarde, atualizando descrições...")
Else
	MsgAlert("Rotina Cancelada pelo Usuário.")
EndIf

Return

/*
===============================================================================================================================
Programa----------: RunProc
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 28/12/2016
===============================================================================================================================
Descrição---------: Rotina criada para executar o processamento de gravação entre as tabelas TN3 e SB1.
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/Static Function RunProc()
Local _aArea := GetArea()

dbSelectArea("TN3")
TN3->(dbSetOrder(1))

While !TN3->(Eof())
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If dbSeek(xFilial("SB1") + TN3->TN3_CODEPI)
		RecLock("TN3", .F.)
		TN3->TN3_I_DESC := SB1->B1_DESC
		MsUnLock()
	EndIf
	TN3->(dbSkip())
End

RestArea(_aArea)
Return