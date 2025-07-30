/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  |28/02/2019| Chamado 28267. Ajuste de opções de aplicação direta
Lucas Borges  |17/10/2019| Chamado 28346. Removidos os Warning na compilação da release 12.1.25
Lucas Borges  |22/06/2025| Chamado 50617. Revisões diversas visando padronizar os fontes
===============================================================================================================================
*/

#Include 'Protheus.ch'

#define	MB_OK			0
#define MB_ICONASTERISK	64

/*
===============================================================================================================================
Programa----------: ACOM035
Autor-------------: Jerry
Data da Criacao---: 26/07/2017
Descrição---------: Rotina para alteração Aplicação Direta 
Parametros--------: _nopc - igual a 1 se for chamado do MT120FIM
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM035(_nopc)

Local aArea			:= FWGetArea() As Array
Local nX			:= 0 As Numeric
Local cQry			:= "" As Character
Local cAliasQry		:= GetNextAlias() As Character
Local aHeader		:= {} As Array
Local aCols			:= {} As Array
Local aFields		:= {"C7_I_USOD","C7_NUM","C7_TIPO","C7_ITEM","C7_NUMSC","C7_ITEMSC","C1_I_USOD","C7_PRODUTO","C7_DESCRI","C7_I_DTFAT","A2_NOME"} As Array
Local nOpc			:= 0 As Numeric
Local oSButton1		:= Nil As Object
Local oSButton2		:= Nil as Object

Default _nopc       := 0

Private oDlg		:= Nil As Object
Private oMSNewSC7	:= Nil As Object

//===============================================================
// Grava log da montagem de menu customizados Pedidos de Compras
//=============================================================== 
U_ITLOGACS('ACOM035')


dbSelectArea("SY1")
SY1->(dbSetOrder(3)) //Y1_FILIAL + Y1_USER

If SY1->(dbSeek(xFilial("SY1") + __cUserID))
   //=============================================================================
   //Montagem do aheader                                                        
   //=============================================================================
   aHeader := {}
   aCols   := {}
   For nX := 1 To Len(aFields)
       _cCampoSX3 := aFields[nX]
       aAdd( aHeader , {   Getsx3cache(_cCampoSX3,"X3_TITULO")  ,;
                           Getsx3cache(_cCampoSX3,"X3_CAMPO")   ,;
                           Getsx3cache(_cCampoSX3,"X3_PICTURE") ,;
                           Getsx3cache(_cCampoSX3,"X3_TAMANHO") ,;
                           Getsx3cache(_cCampoSX3,"X3_DECIMAL") ,;
                           Getsx3cache(_cCampoSX3,"X3_VALID")   ,;
                           Getsx3cache(_cCampoSX3,"X3_USADO")   ,;
                           Getsx3cache(_cCampoSX3,"X3_TIPO")    ,;
                           Getsx3cache(_cCampoSX3,"X3_F3")      ,;
                           Getsx3cache(_cCampoSX3,"X3_CONTEXT")  })
   Next nX
        	
	// Somente sao selecionados itens que nao possuem restricoes
	cQry := "SELECT C7_NUM,C7_TIPO,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_I_DTFAT,C7_FORNECE,C7_LOJA, "
	cQry += " SC7.R_E_C_N_O_ AS RECSC7,A2_NOME,C7_NUMSC, C7_ITEMSC, C7_I_USOD, C7_NUMSC,C7_ITEMSC "
	cQry += "FROM " + RetSqlName("SC7") + " SC7 "
	cQry += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	cQry += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQry += "  AND C7_NUM = '" + SC7->C7_NUM + "' "
	
	If _nopc == 0
		cQry += "  AND C7_QUJE = 0 "   
		cQry += "  AND C7_RESIDUO <> 'S' " 
		cQry += "  AND NOT EXISTS (SELECT 'Y' FROM " +  RetSqlName("SC7") + " SC7B WHERE SC7B.C7_FILIAL = SC7.C7_FILIAL AND SC7B.C7_NUM = SC7.C7_NUM AND SC7.C7_QUJE <> 0 AND SC7.D_E_L_E_T_ = ' ') "
	Endif

	cQry += "  AND SC7.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	MPSysOpenQuery(cQry,cAliasQry)

	(cAliasQry)->( DBGoTop() )

	If !(cAliasQry)->(Eof())
		
		_aStructQry := {}
		Aadd(_aStructQry, {"C7_I_USOD"   ,"C" ,1  ,0})
		Aadd(_aStructQry, {"C7_NUM"   ,"C" ,6  ,0})
		Aadd(_aStructQry, {"C7_TIPO"   ,"N" ,1  ,0})
		Aadd(_aStructQry, {"C7_NUMSC"   ,"C" ,6  ,0})
		Aadd(_aStructQry, {"C7_ITEMSC"   ,"C" ,4  ,0})
		Aadd(_aStructQry, {"C1_I_USOD"   ,"C" ,1  ,0})
		Aadd(_aStructQry, {"C7_PRODUTO"   ,"C" ,20  ,0})
		Aadd(_aStructQry, {"C7_ITEM"   ,"C" ,4  ,0})
		Aadd(_aStructQry, {"C7_DESCRI"   ,"C" ,30  ,0})
		Aadd(_aStructQry, {"C7_I_DTFAT"   ,"C" ,15  ,0})
		Aadd(_aStructQry, {"A2_NOME"   ,"C" ,30  ,0})
		Aadd(_aStructQry, {"RECNO"   ,"N" ,18  ,0})

		//Cria tabela temporária a partir da query
		_oTemp := FWTemporaryTable():New( "TEMP",  _aStructQry )
		_oTemp:Create()
		
		While (cAliasQry)->(!Eof())
	
			Reclock("TEMP",.T.)
			TEMP->C7_I_USOD := (cAliasQry)->C7_I_USOD
			TEMP->C7_NUM := (cAliasQry)->C7_NUM
			TEMP->C7_NUMSC := (cAliasQry)->C7_NUMSC
			TEMP->C7_ITEMSC := (cAliasQry)->C7_ITEMSC
			TEMP->C1_I_USOD := POSICIONE("SC1",1,XFILIAL("SC1")+(cAliasQry)->C7_NUMSC+(cAliasQry)->C7_ITEMSC,"C1_I_USOD")
			TEMP->C7_TIPO := (cAliasQry)->C7_TIPO
			TEMP->C7_PRODUTO := (cAliasQry)->C7_PRODUTO
			TEMP->C7_ITEM := (cAliasQry)->C7_ITEM
			TEMP->C7_DESCRI := (cAliasQry)->C7_DESCRI
			TEMP->C7_I_DTFAT := (cAliasQry)->C7_I_DTFAT
			TEMP->A2_NOME := (cAliasQry)->A2_NOME
			TEMP->RECNO := (cAliasQry)->RECSC7

			(cAliasQry)->(dbSkip())
		End

		aCpoBrw := {}
		Aadd(aCpoBrw,{{||IIF(TEMP->C7_I_USOD=="S","Sim","Não")},,"Ap Direta?"})
		Aadd(aCpoBrw,{"C7_NUM",,"Pedido"})
		Aadd(aCpoBrw,{"C7_TIPO",,"Tipo"})
		Aadd(aCpoBrw,{"C7_ITEM",,"Item"})
		Aadd(aCpoBrw,{"C7_NUMSC",,"SC"})
		Aadd(aCpoBrw,{"C7_ITEMSC",,"Item SC"})
		Aadd(aCpoBrw,{{||IIF(TEMP->C1_I_USOD=="S","Sim",IIF(TEMP->C1_I_USOD=="N","Não","   "))},,"Ap Direta SC?"})
		Aadd(aCpoBrw,{"C7_PRODUTO",,"Produto"})
		Aadd(aCpoBrw,{"C7_DESCRI",,"Descrição"})
		Aadd(aCpoBrw,{{|| STod(TEMP->C7_I_DTFAT)},,"Dt Faturamento"})
		Aadd(aCpoBrw,{"A2_NOME",,"Fornecedor"})

		TEMP->(Dbgotop())
		
		If _nopc == 1 //Se foi chamado do mt120fim a opção de salvar é default no fechamento da tela pelo x
			nopc := 1
		Endif

		DEFINE MSDIALOG oDlg TITLE "Alterar Aplicação Direta" FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL
			
			oMSNewSC7:=MsSelect():New("TEMP",,,aCpoBrw,.F.,,{001,002,101, 348},,,oDlg)
         	oMSNewSC7:bAval:= {|| U_ACOM035M() } 
	     	oMSNewSC7:oBrowse:lhasMark    := .T.
	     	oMSNewSC7:oBrowse:lCanAllmark := .T.
	
			DEFINE SBUTTON oSButton1 FROM 129, 142 TYPE 01 OF oDlg ENABLE ACTION (nOpc := 1, oDlg:End())
		
			If _nopc == 0 //Só pode cancelar se não veio do mt120fim
				DEFINE SBUTTON oSButton2 FROM 129, 175 TYPE 02 OF oDlg ENABLE ACTION (nOpc := 2, oDlg:End())
			Endif
		
			@ 129,208 BUTTON "Inverte todos" SIZE 35,10 PIXEL OF oDlg ACTION (U_ACOM035T())
	
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If nOpc == 1

			TEMP->(Dbgotop())
			Do while !(TEMP->(Eof()))

				BEGIN TRANSACTION

				dbSelectArea("SC7")
				SC7->(dbGoTo(TEMP->RECNO))
   				RecLock("SC7",.F.)
    				Replace SC7->C7_I_USOD With TEMP->C7_I_USOD
				SC7->(MsUnLock())
				
				If !Empty(SC7->C7_NUMSC)
				    dbSelectArea("SC1")
					SC1->(dbSetOrder(1))
					If SC1->(dbSeek(xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC ))
   			   			RecLock("SC1",.F.)
    					Replace SC1->C1_I_USOD With TEMP->C7_I_USOD
			   			SC1->(MsUnLock())
					EndIf                    
				EndIf

				END TRANSACTION

				TEMP->(Dbskip())
			Enddo
			FWAlertSuccess("Aplicação Direta Alterada com sucesso para todos os itens.","ACOM03501")
		Else
			FWAlertInfo("Processo cancelado pelo usuário.","ACOM03502")
		EndIf
	Else
		FWAlertInfo("Não houveram dados para esta seleção ou Pedido. Favor selecionar um pedido de compras válido!","ACOM03503")
	EndIf
	
	(cAliasQry)->( DBCloseArea() )
	
	If select("TEMP")
		TEMP->( DBCloseArea() )
	Endif
Else
	FWAlertWarning("O usuário: " + cUserName + " não possui acesso para utilizar esta rotina. "+;
				"Verifique o cadastro deste usuário como comprador.","ACOM03504")
EndIf

FWRestArea(aArea)
Return    

/*
===============================================================================================================================
Programa----------: ACOM035M
Autor-------------: Josué Danich
Data da Criacao---: 01/03/2019
Descrição---------: Altera linha de aplicação direta
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM035M

Local _copc := "" As Character

If TEMP->C7_I_USOD == "S"
	_copc := "N"
Else
	_copc := "S"
EndIf

Reclock("TEMP",.F.)
TEMP->C7_I_USOD := _copc
TEMP->(Msunlock())

oMSNewSC7:oBrowse:Refresh()

Return

/*
===============================================================================================================================
Programa----------: ACOM035T
Autor-------------: Josué Danich
Data da Criacao---: 01/03/2019
Descrição---------: Altera todas as linhas de aplicação direta
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM035T

Local _copc := "" As Character

TEMP->(Dbgotop())

Do while !(TEMP->(Eof()))
	If TEMP->C7_I_USOD == "S"
		_copc := "N"
	Else
		_copc := "S"
	EndIf

	Reclock("TEMP",.F.)
	TEMP->C7_I_USOD := _copc
	TEMP->(Msunlock())

	TEMP->(Dbskip())
Enddo

TEMP->(Dbgotop())
oMSNewSC7:oBrowse:Refresh()

Return
