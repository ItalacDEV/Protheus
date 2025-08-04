/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Prestes | 22/07/2015 | Chamado 10828. Inclu�do tratamento para atualizar tabela ZZH de acordo.                               
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 18/07/2017 | Chamado 20777. Virada de vers�o da P11 para a vers�o P12. Ajustes no fonte para a vers�o P12. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 31/05/2023 | Chamado 43996. Validacao de acesso do usuario para colocar a data em branco.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

#define	MB_OK				0
#define MB_ICONASTERISK		64



/*
===============================================================================================================================
Programa----------: ACOM004
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 30/06/2015                                    .
===============================================================================================================================
Descri��o---------: Rotina para altera��o de data de faturamento por item.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM004()
Local _aArea		:= GetArea()
Local _nOpc			:= 0

Local dGetDtf		:= SC7->C7_I_DTFAT
Local cGetFor		:= SC7->C7_FORNECE
Local cGetIte		:= SC7->C7_ITEM
Local dGetNdf		:= StoD("//")
Local cGetNum		:= SC7->C7_NUM
Local cGetPro		:= SC7->C7_PRODUTO

Local oGetDtf
Local oGetFor
Local oGetIte
Local oGetNdf
Local oGetNum
Local oGetPro

Local oSayDTF
Local oSayFor
Local oSayIte
Local oSayNDF
Local oSayNum
Local oSayPro
Local oSButton1
Local oSButton2

//Private oDlg
Local oDlg

dbSelectArea("SY1")
dbSetOrder(3) //Y1_FILIAL + Y1_USER
If dbSeek(xFilial("SY1") + __cUserID)

	// Monta tela com os dados do item do pedido de compras posicionado
	DEFINE MSDIALOG oDlg TITLE "Pedido Compra - Alt.Dt.Fat.ITEM" FROM 000, 000  TO 190, 385 COLORS 0, 16777215 PIXEL
		@ 005, 006 SAY oSayFor PROMPT "Fornecedor:" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 005, 069 SAY oSayNum PROMPT "N�mero:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 005, 133 SAY oSayIte PROMPT "Item:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 029, 006 SAY oSayPro PROMPT "Produto:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 029, 071 SAY oSayDTF PROMPT "Dt. Faturamento:" SIZE 041, 007 OF oDlg COLORS 16711680, 16777215 PIXEL
	    @ 059, 030 SAY oSayNDF PROMPT "Nova Dt. Faturamento:" SIZE 056, 007 OF oDlg COLORS 16711680, 16777215 PIXEL
	
	    @ 017, 006 MSGET oGetFor VAR cGetFor SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	    @ 017, 070 MSGET oGetNum VAR cGetNum SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	    @ 017, 134 MSGET oGetIte VAR cGetIte SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	    @ 041, 005 MSGET oGetPro VAR cGetPro SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	    @ 041, 071 MSGET oGetDtf VAR dGetDtf SIZE 060, 010 OF oDlg COLORS 0, 12632256 READONLY PIXEL
	    @ 059, 087 MSGET oGetNdf VAR dGetNdf SIZE 060, 010 OF oDlg VALID U_VLDDTFAT(dGetNdf,1) COLORS 0, 16777215 PIXEL
	
		DEFINE SBUTTON oSButton1 FROM 075, 074 TYPE 01 OF oDlg ENABLE ACTION (_nOpc := 1, oDlg:End())
		DEFINE SBUTTON oSButton2 FROM 075, 108 TYPE 02 OF oDlg ENABLE ACTION (_nOpc := 2, oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED

   If _nOpc == 1
      If U_VLDDTFAT(dGetNdf,1) .AND. VLDUSER(dGetNdf)
		  If Empty(dGetNdf)
            RecLock("SC7",.F.)
            Replace SC7->C7_I_DTFAT With StoD("//")
            MsUnLock()
         Else
            RecLock("SC7",.F.)
            Replace SC7->C7_I_DTFAT With dGetNdf
            MsUnLock()
         EndIf   
			
		  //Atualiza tabela ZZH de indicadores de pagamentos para pedidos de compra
         U_ACOM008ZZH(alltrim(SC7->C7_FILIAL), alltrim(SC7->C7_NUM))
			
         U_ITMSG("Data de Faturamento alterada com sucesso.",;
                 "Aten��o",,3) 
      Else         
         U_ITMSG("Processo n�o p�de ser finalizado.",;
		           "Aten��o",,3)
      EndIf
   Else
      U_ITMSG("Processo cancelado pelo usu�rio.",;
               "Aten��o",,3)
   EndIf
Else
	U_ITMSG("O usu�rio: " + cUserName + " n�o possui acesso para utilizar esta rotina.",;
            "Usu�rio Inv�lido",;
            "Verifique o cadastro deste usu�rio como comprador.",2)
EndIf

//===============================================================
// Grava log da altera��o de data de faturamento por item.
//=============================================================== 
U_ITLOGACS('ACOM004')


RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: VLDUSER()
Autor-------------: Alex Wallauer
Data da Criacao---: 30/05/2023
===============================================================================================================================
Descri��o---------: Validacao do acesso do usuario 
===============================================================================================================================
Parametros--------: cGet1
===============================================================================================================================
Retorno-----------: _lRet := .T. OU .F. 
===============================================================================================================================
*/

STATIC FUNCTION VLDUSER(cGet1)
LOCAL _lRet:=.T.
IF ZZL->(FIELDPOS("ZZL_AUDTFA")) <> 0 .AND. EMPTY(cGet1)
   IF !U_ITVACESS( 'ZZL' , 3 , 'ZZL_AUDTFA' , "S" )
      U_ITMSG("O campo data de faturamento n�o pode ficar em branco.","VALIDACAO DA DATA",;
	          "Para deixar em branco, favor entrar em contato com Supervisor da Area de Compras!",3)
      _lRet := .F.
   ENDIF
ENDIF
RETURN _lRet

