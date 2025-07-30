/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Jerry Santiago    | 12/06/2018 | Ajustes na numeracao dos parametros de Nota/Serie Fim. Chamado: 25191 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich      | 26/06/2019 | Ajuste para loboguara - Chamado 28886
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "RwMake.ch"
#include "TopConn.ch"         
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MOMS006
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Geracao de arquivo de texdo contendo informacoes de notas fiscais e pedido de venda no Layout proposta pela 
                  : empresa Neogrid. 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS006()

Private cPerg   	:= 	"MOMS006"
Private cArqTxt 	:= 	""
Private cEOL    	:= 	CHR(13)+CHR(10)
Private cFile
Private nHdl
	
// Matriz com as nota que serao geradas no EDI
Private aNotas		:= {}
Private cChave		:= ""
Private aNotMark	:= {}

// Variaveis para o registro 09 -> SUMARIO
Private nConta		:= 0
Private nQtUnid		:= 0
Private nICMSSub	:= 0  
	
// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

Pergunte(cPerg,.F.)
                                   
DEFINE MSDIALOG oDlg TITLE "REALIZAR GERAÇÃO DO EDI DAS NOTAS FISCAIS" FROM MOMS006F(178),MOMS006F(181) TO MOMS006F(391),MOMS006F(717) PIXEL

	// Cria as Groups do Sistema
	@ MOMS006F(000),MOMS006F(001) TO MOMS006F(062),MOMS006F(269) LABEL "INFORMAÇÃO:" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ MOMS006F(021),MOMS006F(013) Say "Esta rotina irá efetuar a geração dos arquivos de faturamento das notas fiscais do cliente indicado de acordo com os parâmetros fornecidos pelo usuário, qualquer problema que ocorra favor contactar o departamento de infomática da ITALAC." Size MOMS006F(242),MOMS006F(028) COLOR CLR_BLACK PIXEL OF oDlg
	@ MOMS006F(080),MOMS006F(047) Button "Parâmetros" Size MOMS006F(037),MOMS006F(012) PIXEL OF oDlg Action(Pergunte(cPerg,.T.))
	@ MOMS006F(080),MOMS006F(111) Button "Gerar Notas Fiscais" Size MOMS006F(048),MOMS006F(012) PIXEL OF oDlg ACTION(MOMS006A())
	@ MOMS006F(080),MOMS006F(185) Button "Cancelar" Size MOMS006F(037),MOMS006F(012) PIXEL OF oDlg ACTION(Close(oDlg))


ACTIVATE MSDIALOG oDlg CENTERED        

Return(.T.)

/*
===============================================================================================================================
Programa----------: MOMS006A
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: EDI com carrefour.   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS006A()                                  

	Local cQryF2		:= ""
	Local i				:= 0                 
	
	If Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or. Empty(MV_PAR06) .Or.;
	   Empty(MV_PAR08) .Or. Empty(MV_PAR09) .Or. Empty(MV_PAR10) 
	        
	   	xMagHelpFis("INFORMAÇÃO",;
		"Para executar esta rotina é necessário o preenchimento dos seguintes parâmetros: " + cEOL + "Ate nota fiscal" + cEOL + "Ate serie" + cEOL + "Caminho do arquivo" + cEOL + "Ate a Loja" + cEOL + "Dt. Faturamento Inicial" + cEOL + "Dt. Final do Faturamento",;
		"Favor preencher os parâmetros citados acima. Qualquer dúvida ou problema favor contactar o departamento de informática.")  
	   
	   Return
	   
	EndIf   	
	
	Close(oDlg)

		// seleciona as notas de acordo com parametros
		cQryF2 := "SELECT F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_VALMERC, F2_EMISSAO
		cQryF2 += " FROM " + RETSQLNAME("SF2")
		cQryF2 += " WHERE F2_FILIAL = '"    + xFilial("SF2") + "'"
		cQryF2 += " AND F2_DOC BETWEEN '"   + MV_PAR01 + "' AND '" + MV_PAR03 + "'"
		cQryF2 += " AND F2_SERIE BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "'"
		cQryF2 += " AND F2_CLIENTE = '"     + MV_PAR06 + "'"
		cQryF2 += " AND F2_LOJA BETWEEN '"  + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
		cQryF2 += " AND F2_EMISSAO  BETWEEN '" + DTOS(MV_PAR09) + "' AND '" + DTOS(MV_PAR10) + "'"
		cQryF2 += " AND D_E_L_E_T_  = ' '"

		if Select("TRAB") > 0
			TRAB->(DbCloseArea())
		endif

		TCQUERY cQryF2 NEW ALIAS "TRAB"
		
		While  !TRAB->(Eof())

			aAdd(aNotas,{	.F.,;
							TRAB->F2_DOC,;
							TRAB->F2_SERIE,;
							TRAB->F2_CLIENTE,;
							TRAB->F2_LOJA,;
							TRAB->F2_EMISSAO})

			cChave		+= TRAB->F2_DOC
			aAdd(aNotMark, TRAB->F2_SERIE + " - " + TRAB->F2_CLIENTE + " - " + TRAB->F2_LOJA + " - " +;
								AllTrim(Posicione("SA1", 1, xFilial("SA1") + TRAB->F2_CLIENTE + TRAB->F2_LOJA ,"A1_NREDUZ")) + " - " +;
								AllTrim(Transform(TRAB->F2_VALMERC,"@E 999,999,999.99")) )

			TRAB->(DbSkip())
        enddo

		TRAB->(DbCloseArea())
		
		MOMS006E()

		for i:=1 to len(aNotas)
		
			if (aNotas[i][1])

				nConta		:= 0
				nQtUnid		:= 0
				nICMSSub	:= 0
				
				If !MOMS006C(aNotas[i][4], aNotas[i][5], aNotas[i][2], aNotas[i][3])
				
					MsgAlert("Não existe pedido para a seguinte Nota Fiscal - Numero/Serie: " + ALLTRIM(aNotas[i][2]) + "/" +;
						ALLTRIM(aNotas[i][3]) + " - Cliente/Loja: " + ALLTRIM(aNotas[i][4]) + "/" + ALLTRIM(aNotas[i][5]))
				
				Else
					cFile   := "NF" + AllTrim(aNotas[i][6]) + alltrim(aNotas[i][2])+ ".txt"
					cArqTxt := ALLTRIM(MV_PAR05) + cFile
					nHdl    := fCreate(cArqTxt)
			
					If nHdl == -1
						MsgAlert("O arquivo de nome " + cfile + " nao pode ser executado! Verifique os parametros.","Atencao!")
						Return
					Endif
			
					// Gera registro tipo "01"
					Processa({|| MOMS0061(aNotas[i][4], aNotas[i][5], aNotas[i][2], aNotas[i][3]) },"Processando registro 01...")
					// Gera registro tipo "02"
					Processa({|| MOMS0062(aNotas[i][4], aNotas[i][5], aNotas[i][2], aNotas[i][3]) },"Processando registro 02...")
					// Gera registro tipo "03"
					Processa({|| MOMS0063() },"Processando registro 03...")
					// Gera registro tipo "04"
					Processa({|| MOMS0064(aNotas[i][4], aNotas[i][5], aNotas[i][2], aNotas[i][3]) },"Processando registro 04...")
					// Gera registro tipo "09"
					Processa({|| MOMS0069(aNotas[i][4], aNotas[i][5], aNotas[i][2], aNotas[i][3]) },"Processando registro 09...")
				
					fClose(nHdl)
					
				EndIf
			endif	
		next
Return

/*
===============================================================================================================================
Programa----------: MOMS0063
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Geracao de dados do registro tipo "03".   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS0063()

	Local nTamLin, cLin, cCpo

	nTamLin :=	122
	cLin    := 	Space(nTamLin) // Variavel para criacao da linha do registros para gravacao
    
	//Tipo do Registro
	cCpo 	:= 	PADR("03",02)
	cLin 	:= 	Stuff(cLin,01,02,cCpo)
	
	//Percentual de Desconto Financeiro
	cCpo 	:= 	PADL("",05,"0")
	cLin 	:= 	Stuff(cLin,03,07,cCpo)	
	
	//Valor de desconto financeiro
	cCpo 	:= 	PADL("",15,"0")
	cLin 	:= 	Stuff(cLin,08,22,cCpo)	
	
	//Percentual de desconto comercial
	cCpo 	:= 	PADL("",05,"0")
	cLin 	:= 	Stuff(cLin,23,27,cCpo)	
	
	//Valor de desconto comercial
	cCpo 	:= 	PADL("",15,"0")
	cLin 	:= 	Stuff(cLin,28,42,cCpo)	
	
	//Percentual de desconto promocional
	cCpo 	:= 	PADL("",05,"0")
	cLin 	:= 	Stuff(cLin,43,47,cCpo)	
	
	//Valor de desconto Promocional
	cCpo 	:= 	PADL("",15,"0")
	cLin 	:= 	Stuff(cLin,48,62,cCpo)	
	
	//Percentual de encargos financeiros
	cCpo 	:= 	PADL("",05,"0")
	cLin 	:= 	Stuff(cLin,63,67,cCpo)	
	
	//Valor de encargos financeiros
	cCpo 	:= 	PADL("",15,"0")
	cLin 	:= 	Stuff(cLin,68,82,cCpo)	
	
	//Percentual de encargos de frete
	cCpo 	:= 	PADL("",05,"0")
	cLin 	:= 	Stuff(cLin,83,87,cCpo)	
	
	//Valor de encargos de frete
	cCpo 	:= 	PADL("",15,"0")
	cLin 	:= 	Stuff(cLin,88,102,cCpo)	
	
	//Percentual de encargos de seguro
	cCpo 	:= 	PADL("",05,"0")
	cLin 	:= 	Stuff(cLin,103,107,cCpo)	
	
	//Valor de encargos de seguro
	cCpo 	:= 	PADL("",15,"0")
	cLin 	:= 	Stuff(cLin,108,122,cCpo)	
	
	cLin	+= cEOL
	
	FWrite(nHdl,cLin,Len(cLin))
	
Return

/*
===============================================================================================================================
Programa----------: MOMS0061 
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Geracao de dados do registro tipo "01".  
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS0061(_pcCliente,_pcLoja,_pcDoc,_pcSerie)

	Local nTamLin, cLin, cCpo
	Local cCliEnt, cLojEnt, cCNPJ1, cEAN1
	Local cCfop, cPedVen, cPedCli, dDatEnt, cCNPJ, cIe, cEAN, cTpFrete
	
	nTamLin := 340
	cLin    := Space(nTamLin) // Variavel para criacao da linha do registros para gravacao
	
	//Tipo do Registro
	cCpo := PADR("01",02)
	cLin := Stuff(cLin,01,02,cCpo)    
	
	//Funcao da mensagem
	cCpo := PADR("9",03)
	cLin := Stuff(cLin,03,05,cCpo)    
	
	//Tipo da Nota Fiscal
	cCpo := PADR("380",03)
	cLin := Stuff(cLin,06,08,cCpo)
	
	DbSelectArea("SF2")
	DbSetOrder(2)
	If DbSeek(xFilial("SF2")+_pcCliente+_pcLoja+_pcDoc+_pcSerie)
	
		cCliEnt	:= SF2->F2_CLIENT
		cLojEnt	:= SF2->F2_LOJENT
		
		//Numero da Nota Fiscal
		cCpo := StrZero(Val(SF2->F2_DOC),09)
		cLin := Stuff(cLin,09,17,cCpo)
		
		//Serie da Nota Fiscal
		cCpo := PADR(SF2->F2_SERIE,03)
		cLin := Stuff(cLin,18,20,cCpo) 
		
		//SubSerie da Nota Fiscal 
		cCpo := PADR(" ",02)
		cLin := Stuff(cLin,21,22,cCpo)
		
		//Data da Emissao da Nota Fiscal. Formato AAAAMMDDHHMM
		cCpo := PADR(DtoS(SF2->F2_EMISSAO)+"0000",12)
		cLin := Stuff(cLin,23,34,cCpo)
		
		//Data do Despacho/Embarque. Formato AAAAMMDDHHMM
		cCpo := PADR(DtoS(SF2->F2_EMISSAO)+"0000",12)
		cLin := Stuff(cLin,35,46,cCpo)
		
		cCfop   := ""
		cPedVen := ""
		DbSelectArea("SD2")
		DbSetOrder(3)
		If DbSeek(xFilial("SD2")+_pcDoc+_pcSerie+_pcCliente+_pcLoja)
			cCfop		:= 	SD2->D2_CF
			cPedVen 	:=	SD2->D2_PEDIDO
		EndIf

		//Data de Entrega. Formato AAAAMMDDHHMM
		dDatEnt	:= ""
		cPedCli	:= ""
		DbSelectArea("SC6")
		DbSetOrder(1)	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If DbSeek(xFilial("SC6") + cPedVen)
			dDatEnt	:= SC6->C6_ENTREG
			cPedCli	:= SC6->C6_PEDCLI
		EndIf                   
		
		//Data de Entrega
		cCpo := PADR(DtoS(dDatEnt)+"0000",12)
		cLin := Stuff(cLin,47,58,cCpo)
		
		//Codigo Fiscal de Operacao
		cCpo := Padr(cCfop,05)
		cLin := Stuff(cLin,59,63,cCpo)  
		
		//Numero  do Pedido de Compra do comprador
		cCpo := Padr(cPedCli,20)
		cLin := Stuff(cLin,64,83,cCpo)
		
		//Numero  do Pedido de Compra do sistema de Emissao
		cCpo := Padr(cPedVen,20)
		cLin := Stuff(cLin,84,103,cCpo)
		                                      
		//Numero do contrato
		cCpo := Padr(" ",15)
		cLin := Stuff(cLin,104,118,cCpo)
		
		//Numero da Lista de Preco
		cCpo := Padr(" ",15)
		cLin := Stuff(cLin,119,133,cCpo)

		cCNPJ	:= ""
		cIe		:= ""
		cEAN	:= ""

		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+_pcCliente+_pcLoja)
			cCNPJ	:= SA1->A1_CGC
			cIe		:= SA1->A1_INSCR
			cEAN	:= SA1->A1_I_CDEAN
		EndIf

		//EAN de localizacao do Comprador
		cCpo := PADL(cEAN,13,"0")
		cLin := Stuff(cLin,134,146,cCpo)
		  
		cCNPJ1	:= ""
		cEAN1	:= ""
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+cCliEnt+cLojEnt)
			cCNPJ1	:= SA1->A1_CGC
			cEAN1	:= SA1->A1_I_CDEAN
		EndIf        
		
		//EAN de localizacao da cobranca da Fatura
		cCpo := PADL(cEAN,13,"0")
		cLin := Stuff(cLin,147,159,cCpo)

		//EAN de localizacao do local de entrega.
		cCpo := PADL(cEAN1,13,"0")
		cLin := Stuff(cLin,160,172,cCpo)
		
		//EAN de Localizacao do Fornecedor
		cCpo := PADL(GetMV("IT_CODEAN"),13,"0")
		cLin := Stuff(cLin,173,185,cCpo) 
		
		//EAN do emitente da nota fiscal.
		cCpo := PADL(GetMV("IT_CODEAN"),13,"0")
		cLin := Stuff(cLin,186,198,cCpo)
		                          
		//CNPJ Comprador
		cCpo := PADL(cCNPJ,14,"0")
		cLin := Stuff(cLin,199,212,cCpo)
		
		//CNPJ do local da cobranca da Fatura
		cCpo := PADL(cCNPJ,14,"0")
		cLin := Stuff(cLin,213,226,cCpo)    
		
		//CNPJ do local de entrega
		cCpo := PADL(cCNPJ1,14,"0")
		cLin := Stuff(cLin,227,240,cCpo)
		
		//CNPJ do fornecedor
		cCpo := PADL(SM0->M0_CGC,14,"0")
		cLin := Stuff(cLin,241,254,cCpo)
		
		//CNPJ do Emissor da Nota Fiscal
		cCpo := PADL(SM0->M0_CGC,14,"0")
		cLin := Stuff(cLin,255,268,cCpo)
		
		//UF do Emissor da Nota Fiscal
		cCpo := Padr(SM0->M0_ESTCOB,02)
		cLin := Stuff(cLin,269,270,cCpo)
		
		//IE do emitente da Nota Fiscal
		cCpo := Padr(SM0->M0_INSC,20)
		cLin := Stuff(cLin,271,290,cCpo)                          
		
		//Tipo de Codigo da Transportadora
		cCpo := Padr("9",03)
		cLin := Stuff(cLin,291,293,cCpo)                          
		
		//Codigo da Transportadora   
		cCpo := PADL(MOMS006D(cPedVen,4),14,"0")
		cLin := Stuff(cLin,294,307,cCpo)
		
		//Nome da transportadora
		cCpo := Padr(MOMS006D(cPedVen,2),30)
		cLin := Stuff(cLin,308,337,cCpo)
		
		//Condicao de entrega
		cTpFrete   := ""
		DbSelectArea("SC5")
		DbSetOrder(1)
		If DbSeek(xFilial("SC5")+cPedVen)
			cTpFrete   := IIF(SC5->C5_TPFRETE == "C","CIF","FOB")
		EndIf
		
		//Condicao de Entrega
		cCpo := Padr(cTpFrete,03)
		cLin := Stuff(cLin,338,340,cCpo) 

		cLin += cEOL
	EndIf
	
	FWrite(nHdl,cLin,Len(cLin))

Return

/*
===============================================================================================================================
Programa----------: MOMS0062
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Geracao de dados do registro tipo "02".
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS0062(_pcCliente,_pcLoja,_pcDoc,_pcSerie)

	Local nTamLin, cLin, cCpo
	Local nDiasPagto	:= 0
	Local dFatur
	Local aParc			:= {}
	Local nTotFat		:= 0
	Local i				:= 0
	
	DbSelectArea("SF2")
	DbSetOrder(2)
	If DbSeek(xFilial("SF2")+_pcCliente+_pcLoja+_pcDoc+_pcSerie)
		dFatur	:= SF2->F2_EMISSAO

		DbSelectArea("SE1")
		SE1->(DbSetOrder(2))
		If SE1->(DbSeek(xFilial("SE1")+_pcCliente+_pcLoja+_pcSerie+_pcDoc))
			While !SE1->(Eof()) .And. (SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+_pcCliente+_pcLoja+_pcSerie+_pcDoc)
				
				aAdd(aParc,{SE1->E1_VENCTO, SE1->E1_VALOR})
				nTotFat += SE1->E1_VALOR

				SE1->(DbSkip())
			EndDo
		Endif
		
		for i := 1 to len(aParc)
			
			nTamLin := 51
			cLin    := Space(nTamLin)	// Variavel para criacao da linha do registros para gravacao

			// Tipo do Registro			
			cCpo := PADR("02",02)
			cLin := Stuff(cLin,01,02,cCpo)
			
			//Condicao de pagamento
			cCpo := PADR("3",03)
			cLin := Stuff(cLin,03,05,cCpo)
			
			//Referencia de Data
			cCpo := PADR("5",03)
			cLin := Stuff(cLin,06,08,cCpo)
			
			//Referencia de tempo
			cCpo := PADR("3",03)
			cLin := Stuff(cLin,09,11,cCpo)
			
			//Tipo de periodo
			cCpo := PADR("CD",03)
			cLin := Stuff(cLin,12,14,cCpo)
			
			//Numero de Periodos
			//Numero de Dias para Pagamento. Ex.: 30, 45..
			nDiasPagto	:= aParc[i][1] - dFatur
			cCpo := PADR(StrZero( nDiasPagto,3),03)
			cLin := Stuff(cLin,15,17,cCpo)  
			                    
			//Data de Vencimento
			cCpo := PADR(DTOS(aParc[i][1]),08)
			cLin := Stuff(cLin,18,25,cCpo)
			
			//Tipo de percentual da condicao de pagamento
			cCpo := PADR("12E",03)
			cLin := Stuff(cLin,26,28,cCpo)
			
			//Percentual da condicao de pagamento
			cCpo := PADR(StrZero(aParc[i][2]/nTotFat*10000,05),05)
			cLin := Stuff(cLin,29,33,cCpo)
			                                             
			//Tipo de valor da condicao de pagamento
			cCpo := PADR("262",03)
			cLin := Stuff(cLin,34,36,cCpo)
			
			//Valor da condicao de pagamento
			cCpo := PADR(StrZero(aParc[i][2]*100,15),15)
			cLin := Stuff(cLin,37,51,cCpo)

			cLin += cEOL
			
			FWrite(nHdl,cLin,Len(cLin))
		Next
    Endif
Return

/*
===============================================================================================================================
Programa----------: MOMS0064
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Geracao de dados do registro tipo "04".
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS0064(_pcCliente,_pcLoja,_pcDoc,_pcSerie)

	Local nTamLin, cLin, cCpo
	Local nPesoB, nPesoL, cUM, nConv, cDesc, cNCM
	Local nQtFat      := 0
	Local cUnMedidad  := ""
	Local cUM2        := ""  
	Local cDUN14      := ""
	Local cEANProduto := "" 
	Local cGrupoCli   := ""
	Local cTipoUM     := "" // Envia na 1a UM ou na 2a UM
	Local cEnviaCod   := "" // Envia Código de EAN ou DUN14 do Produto   
	Local nConv3aUM   := 0
	Local cTpCon      := ""
	         
	//Seta a variavel de controle da numeracao dos itens sem ser o codigo do item dos pedidos
	nConta:=0

	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+_pcCliente+_pcLoja)
		cGrupoCli	:= SA1->A1_GRPVEN
	EndIf

	DbSelectArea("ACY")
	DbSetOrder(1)
	If DbSeek(xFilial("ACY")+cGrupoCli)
		cTipoUM     := ACY->ACY_I_UM
		cEnviaCod   := ACY->ACY_I_COD
	EndIf

	DbSelectArea("SD2")
	SD2->(DbSetOrder(3))
	If SD2->(DbSeek(xFilial("SD2")+_pcDoc+_pcSerie+_pcCliente+_pcLoja))
		While !SD2->(Eof()) .And. (SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2")+_pcDoc+_pcSerie+_pcCliente+_pcLoja)

			// Variaveis totalizadoras para registro "09"
			nConta	 +=	1
			nQtUnid	 +=	SD2->D2_QTSEGUM

			nQtFat	 := SD2->D2_QTSEGUM
			nICMSSub +=	SD2->D2_BRICMS    
			
 			nPesoB   := 0
			nPesoL	 := 0
			cUM		 := ""
			nConv	 := 0
			cDesc	 := ""
			cNCM	 := ""    
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			If (DbSeek(xfilial("SB1")+SD2->D2_COD))
				nPesoB	    :=	nQtFat * SB1->B1_PESBRU
				nPesoL	    :=	nQtFat * SB1->B1_PESO
				cUM		    :=	SB1->B1_SEGUM
				nConv   	:=	SB1->B1_CONV
				cDesc	    :=	SB1->B1_I_DESCD
				cNCM     	:=	SB1->B1_POSIPI       
				cDUN14      :=  Alltrim(SB1->B1_I_DUN14)
     			cEANProduto :=  Alltrim(SB1->B1_CODBAR)
			Endif     

			nConv3aUM   := 0
	        cTpCon      := ""
	        
			DbSelectArea("SA7")
			DbSetOrder(1)
			If (DbSeek(xfilial("SA7")+_pcCliente+_pcLoja+SD2->D2_COD))
				nConv3aUM := SA7->A7_I_FTCON
				cTpCon	  := SA7->A7_I_TPCON
			Endif

			nTamLin := 408
			cLin    := Space(nTamLin)	// Variavel para criacao da linha do registros para gravacao

			// Tipo do Registro			
			cCpo := PADR("04",02)
			cLin := Stuff(cLin,01,02,cCpo)
			
			//Numero sequencial da linha de item
			cCpo := PADR(StrZero(nConta,04),04)
			cLin := Stuff(cLin,03,06,cCpo)     
			
			//Numero do item no Pedido
			cCpo := PADR(StrZero(Val(SD2->D2_ITEM),05),05)
			cLin := Stuff(cLin,07,11,cCpo)     
			
			//Tipo do codigo de produto
			cCpo := PADR("EN",03)
			cLin := Stuff(cLin,12,14,cCpo)
 
			//Codigo do Produto 
			If cEnviaCod == '2' //DUN14
				cCpo := PADR(cDUN14,14)
			Else
				cCpo := PADR(cEANProduto,14)
			EndIf
			
			cLin := Stuff(cLin,15,28,cCpo)
			
			//Referencia do Produto
			cCpo := PADR(" ",20)
			cLin := Stuff(cLin,29,48,cCpo)  
			
			//Unidade de medida do produto  
            If (cTipoUM == '2')
				cUM2:= SD2->D2_SEGUM
	        Else 
				cUM2:= SD2->D2_UM       
    		EndIf

			Do Case  
				Case cUM2 == 'UN' 
					cUnMedidad:='EA'
				Case cUM2 == 'G' 
					cUnMedidad:='GRM'	
				Case cUM2 == 'KG' 
					cUnMedidad:='KGM'
				Case cUM2 == 'L' 
					cUnMedidad:='LTR'
				Case cUM2 == 'MT' 
					cUnMedidad:='MTR'	
				Case cUM2 == 'M2' 
					cUnMedidad:='MTK'
				Case cUM2 == 'M3' 
					cUnMedidad:='MTQ'
				Case cUM2 == 'ML' 
					cUnMedidad:='MLT'	
				Case cUM2 == 'TL' 
					cUnMedidad:='TNE'
				Case cUM2 == 'PC' 
					cUnMedidad:='PCE'
				OtherWise
					cUnMedidad:='EA'								
			EndCase
			//Unidade de medida
			cCpo := PADR(cUnMedidad,03)
			cLin := Stuff(cLin,49,51,cCpo) 
			
			//Numero Unidades Consumo na Embalagem
			//cCpo := PADL(nConv,05,"0")
			cCpo := PADL("0",05,"0")
			cLin := Stuff(cLin,52,56,cCpo)

			//Quantidade

			Do Case  
				Case cTipoUM == '2' 
					If nConv3aUM <> 0 
						If cTpCon == 'D'
							cCpo := PADR(StrZero((SD2->D2_QUANT/nConv3aUM) * 100,15),15) 	
					 	Else 
							cCpo := PADR(StrZero((SD2->D2_QUANT*nConv3aUM) * 100,15),15) 						 	
						EndIf
					Else 
						cCpo := PADR(StrZero(SD2->D2_QTSEGUM * 100,15),15) 					
					EndIf

				OtherWise
					cCpo := PADR(StrZero(SD2->D2_QUANT * 100,15),15)   
			EndCase

			cLin := Stuff(cLin,57,71,cCpo)
	
			//Tipo de Embalagem
			cCpo := PADR(" ",03)
			cLin := Stuff(cLin,72,74,cCpo)
			
			//Valor total bruto do item
			cCpo := PADR(strzero(SD2->D2_TOTAL * 100,15),15)
			cLin := Stuff(cLin,75,89,cCpo)
			
			//Valor total liquido do item
			cCpo := PADR(strzero(SD2->D2_TOTAL * 100,15),15)
			cLin := Stuff(cLin,90,104,cCpo)
			 
			//preco bruto/liquido unitario
					
			Do Case  
				Case cTipoUM == '2'  
					If nConv3aUM <> 0 
						cCpo := PADR(strzero((SD2->D2_PRUNIT*nConv3aUM) * 100,15),15)
					Else 
						cCpo := PADR(strzero((SD2->D2_PRUNIT*nConv) * 100,15),15)					
					EndIf
				OtherWise
					cCpo := PADR(strzero(SD2->D2_PRUNIT  * 100,15),15)     
			EndCase
			cLin := Stuff(cLin,105,119,cCpo)			
			cLin := Stuff(cLin,120,134,cCpo)
                                      
            //Numero do Lote
            cCpo := PADR(" ",20)
			cLin := Stuff(cLin,135,154,cCpo)
			
			//Numero do Pedido do Comprador
            cCpo := PADR(" ",20)
			cLin := Stuff(cLin,155,174,cCpo)
			
			//Peso Bruto do item
			cCpo	:= PADR(Replicate("0",15),15)
			cLin	:= Stuff(cLin,175,189,cCpo)
			
			//Volume Bruto do item
			cCpo := PADR(Replicate("0",15),15)          
			cLin := Stuff(cLin,190,204,cCpo)
			
			//Codigo classificacao fiscal
			cCpo := PADR(" ",14)
			cLin := Stuff(cLin,205,218,cCpo)
			                                  
			//codigo situacao tributaria
			cCpo := PADR(" ",05)
			cLin := Stuff(cLin,219,223,cCpo)
			
			//codigo fiscal de operacoes e prestacoes
			cCpo := PADR(SD2->D2_CF,05)
			cLin := Stuff(cLin,224,228,cCpo)
			
			//Percentual de Desconto Financeiro
			cCpo := PADR(Replicate("0",05),05)
			cLin := Stuff(cLin,229,233,cCpo)
			
			//Valor de Desconto Financeiro
			cCpo := PADR(Replicate("0",15),15)
			cLin := Stuff(cLin,234,248,cCpo)
			
			//Percentual de Desconto Comercial
			cCpo := PADR(Replicate("0",05),05)
			cLin := Stuff(cLin,249,253,cCpo)
			
			//Valor de Desconto Comercial
			cCpo := PADR(Replicate("0",15),15)
			cLin := Stuff(cLin,254,268,cCpo)
			
			//Percentual de Desconto Promocional
			cCpo := PADR(Replicate("0",05),05)
			cLin := Stuff(cLin,269,273,cCpo)
			
			//Valor de Desconto Promocional
			cCpo := PADR(Replicate("0",15),15)
			cLin := Stuff(cLin,274,288,cCpo)
			
			//Percentual de Encargos Financeiros
			cCpo := PADR(Replicate("0",05),05)
			cLin := Stuff(cLin,289,293,cCpo)
			
			//Valor de Encargos Financeiros
			cCpo := PADR(Replicate("0",15),15)
			cLin := Stuff(cLin,294,308,cCpo)
			
			//Aliquota de IPI
			cCpo := PADR(StrZero(SD2->D2_IPI * 100,05),05)
			cLin := Stuff(cLin,309,313,cCpo)
			
			//Valor Unitario de IPI
			cCpo := PADR(StrZero(SD2->D2_VALIPI * 100,15),15)
			cLin := Stuff(cLin,314,328,cCpo)
			
			//Aliquota de ICMS
			cCpo := PADR(StrZero(SD2->D2_PICM * 100,05),05)
			cLin := Stuff(cLin,329,333,cCpo)			
			
			//Valor de ICMS
			cCpo := PADR(StrZero(SD2->D2_VALICM * 100,15),15)
			cLin := Stuff(cLin,334,348,cCpo)			
			
			//Aliquota de ICMS com Substituicao Tributaria
			cCpo := PADR(Replicate("0",05),05)
			cLin := Stuff(cLin,349,353,cCpo)			                         
			
			//Valor de ICMS com Substituicao Tributaria
			cCpo := PADR(Replicate("0",15),15)
			cLin := Stuff(cLin,354,368,cCpo)
			
			//Aliquota de reducao de base de ICMS
			cCpo := PADR(Replicate("0",05),05)
			cLin := Stuff(cLin,369,373,cCpo)
			
			//Valor de Reducao da Base de ICMS
			cCpo := PADR(Replicate("0",15),15)
			cLin := Stuff(cLin,374,388,cCpo)
			
			//Percentual de Desconto do repasse de ICMS
			cCpo := PADR(Replicate("0",05),05)
			cLin := Stuff(cLin,389,393,cCpo)
			
			//Valor de Desconto do Repasse de ICMS
			cCpo := PADR(Replicate("0",15),15)
			cLin := Stuff(cLin,394,408,cCpo)			

			cLin += cEOL
			
			FWrite(nHdl,cLin,Len(cLin))
			SD2->(DbSkip())
		EndDo
	Endif

Return

/*
===============================================================================================================================
Programa----------: MOMS0069
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Geracao de dados do registro tipo "09".
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS0069(_pcCliente,_pcLoja,_pcDoc,_pcSerie)

	Local nTamLin, cLin, cCpo
	
	DbSelectArea("SF2")
	DbSetOrder(2)
	DbSeek(xFilial("SF2")+_pcCliente+_pcLoja+_pcDoc+_pcSerie)
	
	nTamLin := 306
	cLin    := Space(nTamLin)	// Variavel para criacao da linha do registros para gravacao
	
	//Tipo de Registro
	cCpo := PADR("09",02)
	cLin := Stuff(cLin,01,02,cCpo)
	
	// numero de linhas itens da nota fiscal
	cCpo := PADR(strzero(nConta,04),04)
	cLin := Stuff(cLin,03,06,cCpo)
	
	//Quantidade total de Embalagens
	cCpo := PADR(Replicate("0",15),15)
	cLin := Stuff(cLin,07,21,cCpo)
	
	//Peso Bruto Total
	cCpo := PADR(strzero(SF2->F2_PBRUTO*100,15),15)
	cLin := Stuff(cLin,22,36,cCpo)
	
	//Peso Liquido Total 
	cCpo := PADR(strzero(SF2->F2_PLIQUI*100,15),15)
	cLin := Stuff(cLin,37,51,cCpo)
	
	//Cubagem Total
	cCpo := PADR(Replicate("0",15),15)
	cLin := Stuff(cLin,52,66,cCpo)
	
	// valor total das linhas da Nota
	cCpo := PADR(strzero(SF2->F2_VALBRUT*100,15),15)
	cLin := Stuff(cLin,67,81,cCpo)  
	
	// valor total dos descontos
	cCpo := PADR(strzero(SF2->F2_DESCONT*100,15),15)
	cLin := Stuff(cLin,82,96,cCpo)
	                                
	// valor total de encargos
	cCpo := PADR(strzero(SF2->F2_VALICM * 100,15),15)
	cLin := Stuff(cLin,97,111,cCpo)	                        
	
	//Valor total de Abatimentos
	cCpo := PADR(replicate("0",15),15)
	cLin := Stuff(cLin,112,126,cCpo)	
	
	//Valor total do Frete
	cCpo := PADR(strzero(SF2->F2_FRETE * 100,15),15)
	cLin := Stuff(cLin,127,141,cCpo)
	
	//Valor total do Seguro	                
	cCpo := PADR(strzero(SF2->F2_SEGURO * 100,15),15)
	cLin := Stuff(cLin,142,156,cCpo)
	
	//Valor despesas acessorias     
	cCpo := PADR(strzero(SF2->F2_DESPESA*100,15),15)
	cLin := Stuff(cLin,157,171,cCpo)
	
	//Valor Base de calculo do ICMS 
	cCpo := PADR(strzero(SF2->F2_BASEICMS*100,15),15)
	cLin := Stuff(cLin,172,186,cCpo)        
	
	//Valor total de ICMS
	cCpo := PADR(strzero(SF2->F2_VALICM*100,15),15)
	cLin := Stuff(cLin,187,201,cCpo) 
	
	//Valor base de Calculo ICMS com Substituicao Tributaria
	cCpo := PADR(strzero(nICMSSub * 100,15),15)
	cLin := Stuff(cLin,202,216,cCpo)
	
	//Valor total de ICMS com Substituicao Tributaria
	cCpo := PADR(replicate("0",15),15)
	cLin := Stuff(cLin,217,231,cCpo)
	
	//Valor base de calculo do ICMS com reducao Tributaria
	cCpo := PADR(replicate("0",15),15)
	cLin := Stuff(cLin,232,246,cCpo)
	
	//Valor total de ICMS com reducao Tributaria
	cCpo := PADR(replicate("0",15),15)
	cLin := Stuff(cLin,247,261,cCpo)
	
	//Valor base de calculo do IPI
	cCpo := PADR(strzero(SF2->F2_BASEIPI*100,15),15)
	cLin := Stuff(cLin,262,276,cCpo)
	
	//Valor total de IPI
	cCpo := PADR(strzero(SF2->F2_VALIPI*100,15),15)
	cLin := Stuff(cLin,277,291,cCpo)
	
	//Valor total da Nota
	cCpo := PADR(strzero(SF2->F2_VALMERC*100,15),15)
	cLin := Stuff(cLin,292,306,cCpo)  
	
	cLin += cEOL
	
	FWrite(nHdl,cLin,Len(cLin))

Return

/*
===============================================================================================================================
Programa----------: MOMS006C
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Verifica se existe pedido de venda para a nota fiscal
===============================================================================================================================
Parametros--------: cCliente = Codigo do cliente	   							      
                    cLoja    = Loja do cliente  	   							      
                    cDoc     = Numero da nota fiscal 						          
                    cSerie   = Serie da nota fiscal    
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS006C(cCliente,cLoja,cDoc,cSerie)

	Local lRet   := .F.
	Local aArea  := GetArea()
	Local cQry
	Local cAlias := CriaTrab(Nil,.F.)
	
	cQry := "SELECT C9_PEDIDO FROM " + RETSQLNAME("SC9")
	cQry += " WHERE C9_FILIAL = '" + xFilial("SC9") + "'"
	cQry += " AND C9_NFISCAL  = '" + cDoc     + "'"
	cQry += " AND C9_SERIENF  = '" + cSerie   + "'"
	cQry += " AND C9_CLIENTE  = '" + cCliente + "'"
	cQry += " AND C9_LOJA     = '" + cLoja    + "'"
	cQry += " AND D_E_L_E_T_  = ' '"
	TCQUERY cQry NEW ALIAS (cAlias)
	
	If !(cAlias)->(Eof())
		lRet := .T.
	EndIf
	
	(cAlias)->(DbCloseArea())

	RestArea(aArea)
Return (lRet)

/*
===============================================================================================================================
Programa----------: MOMS006D
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Retorna informacoes da Transportadora.
===============================================================================================================================
Parametros--------: _pcPedido = Numero de pedido	
					_ntipo    = Opcao de Retorno (1= Retorna o CNPJ,2= Retorna o Nome da Transportadora e 3= Placa,4= Codigo)
===============================================================================================================================
Retorno-----------: _cRetorno = Retorna o CNPJ ou Nome da Transportadora		
===============================================================================================================================
*/
Static Function MOMS006D(_pcPedido,_ntipo)

	Local _aArea		:=	GetArea()     
	Local _cCarga		:=	""	
	Local _cCodVeic		:=	""
	Local _cCodMotor	:=	""		
	Local _cRetorno 	:= 	""

	dbSelectArea("DAI")
	dbSetOrder(4)//DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
	DbSeek(xfilial("DAI")+_pcPedido)
	_cCarga	:=	DAI->DAI_COD	

	dbSelectArea("DAK")
	dbSetOrder(1)//DAK_FILIAL+DAK_COD+DAK_SEQCAR
	DbSeek(xfilial("DAK")+_cCarga)
	_cCodVeic	:=	DAK->DAK_CAMINH
	_cCodMotor	:=	DAK->DAK_MOTORI		

	dbSelectArea("DA4")
	dbSetOrder(1)//DA4_FILIAL+DA4_COD
	DbSeek(xfilial("DA4")+_cCodMotor)
	_cCodigo:=  DA4->DA4_COD
    _cNome	:=	ALLTRIM(DA4->DA4_NOME)
    _cCGC	:=	ALLTRIM(DA4->DA4_CGC)

	dbSelectArea("DA3")
	dbSetOrder(1)//DA3_FILIAL+DA3_COD
	DbSeek(xfilial("DA3")+_cCodVeic)
   	_cPlaca	:=	ALLTRIM(DA3->DA3_PLACA)
	
	If _ntipo == 1//Retorna CNPJ
		_cRetorno := _cCGC
	ElseIf _ntipo == 2//Retorna Nome da Transportadora
		_cRetorno := _cNome
	ElseIf _ntipo == 3//Placa do Veiculo
		_cRetorno := _cPlaca     
	ElseIf _ntipo == 4 //Codigo do Motorista
		_cRetorno := _cCodigo		
	Endif 

	RestArea(_aArea)
Return(_cRetorno)

/*
===============================================================================================================================
Programa----------: MOMS006E
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Programa para selecao das notas a serem geradas no EDI do Carrefour	 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: Matriz com as notas a serem geradas no EDI do Carrefour   		
===============================================================================================================================
*/
Static Function MOMS006E()

	Local i				:= 0
	Local nPos			:= 0

	Private nTam		:= 9
	Private nMaxSelect	:= 5000
	Private cRet		:= ""
	Private cTitulo		:= "Seleção de Notas para geração do EDI"
	
	#IFDEF WINDOWS
		oWnd := GetWndDefault()
	#ENDIF

	//Executa funcao que monta tela de opcoes
	f_Opcoes(@cRet,cTitulo,aNotMark,cChave,12,49,.F.,nTam,nMaxSelect)
	
	//Retorno
	cRet	:= AllTrim(StrTran(cRet,"*",""))
	
	for i := 1 to (len(cRet)/9)
	                           
		nPos := aScan(aNotas,{|x| alltrim(x[2]) == SubStr(cRet, 1+(9*(i-1)), 9)})
		
		if (nPos <> 0)
			aNotas[nPos][1] := .T.
		endif
	
	next
	
Return(.T.)

/*
===============================================================================================================================
Programa----------: MOMS006F()
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/01/2010
===============================================================================================================================
Descrição---------: Funcao responsavel por manter o Layout  
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function MOMS006F(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1   	                                                               
	Else	// Resolucao 1024x768 e acima faz proporcao                                          
		nTam = (nTam * 1)                                                               
	EndIf                                                                         
                                                                                
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                 