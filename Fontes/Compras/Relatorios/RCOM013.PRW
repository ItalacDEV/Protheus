/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 10/06/2019 | Chamado 29593. Ajuste para lobo guara.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 08/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 03/05/2022 | Chamado 39940. Correção nas select do SD1 para ignorar campos memos. 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "MATR080.CH"
#INCLUDE "PROTHEUS.CH"          

/*
===============================================================================================================================
Programa----------: RCOM013
Autor-------------: Josué Danich Prestes
Data da Criacao---: 21/03/2018
===============================================================================================================================
Descrição---------: Relatório de notas de entrada - personalização do MATR080 - Chamado 24036
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM013()
Local oReport

If TRepInUse()
	//=====================================
	//interface de impressao                                                  ?
	//=====================================
	oReport:= RCOM013D()
	oReport:PrintDialog()
Else
	U_RCOM013R()
EndIf

Return

/*
===============================================================================================================================
Programa----------: RCOM013D
Autor-------------: Josué Danich Prestes
Data da Criacao---: 21/03/2018
===============================================================================================================================
Descrição---------: Reportdef do relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM013D()

Local oReport 
Local oSection1
Local oSection2 
Local oSection3 
Local oSection4
Local aOrdem := {}
Local cTamVlr := TamSX3('D1_TOTAL')[1]
//Local cTamImp := TamSX3('F1_VALIMP1')[1]
Local cAliasSD1 := GetNextAlias()


//=====================================
//criacao do componente de impressao                                      ?
//?                                                                       ?
// Report():New                                                           ?
// xpC1 : Nome do relatorio                                               ?
// xpC2 : Titulo                                                          ?
// xpC3 : Pergunte                                                        ?
// xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ?
// xpC5 : Descricao                                                       ?
//?                                                                       ?
//=====================================
oReport:= TReport():New("MATR080",STR0001,"MTR080", {|oReport| RCOM013P(oReport,cAliasSD1)},STR0002+" "+STR0003+" "+STR0004) //"Relacao de Notas Fiscais"##"Emissa da Relacao de Notas de Compras"##"A opcao de filtragem deste relatoio s??vaida na opcao que lista os"##"itens. Os parraetros funcionam normalmente em qualquer opcao."
oReport:SetTotalInLine(.F.)
If TamSX3("D1_COD")[1] > 15 
	oReport:SetLandScape()
Else
	oReport:SetPortrait()
EndIf

Pergunte("MTR080",.F.)

Aadd( aOrdem, STR0005 ) // Por Nota
Aadd( aOrdem, STR0006 ) // Por Produto 
Aadd( aOrdem, STR0043 ) // Por Data Digitacao
Aadd( aOrdem, STR0059 ) // Por Data Emissao
Aadd( aOrdem, STR0062 ) // Por Fornecedor

//================================
//?Definicao da Sessao 1                                        ?
//================================
oSection1 := TRSection():New(oReport,STR0073,{"SD1","SF1","SA1","SA2","SB1"},aOrdem) //"Relacao de Notas Fiscais"
oSection1 :SetTotalInLine(.F.)
oSection1 :SetReadOnly()

//--------- Celulas utilizadas para ordem de Produto --------
TRCell():New(oSection1,"D1_COD","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cDescri","   ",STR0067,"@!",28,/*lPixel*/,/*{|| code-block de impressao }*/) //Descricao
TRCell():New(oSection1,"B1_GRUPO","SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//--------- Celulas utilizadas para ordem de Nota --------
TRCell():New(oSection1,"D1_DOC","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection1,SerieNfId("SD1",3,"D1_SERIE"),"SD1",SerieNfId("SD1",7,"D1_SERIE"),/*Picture*/,SerieNfId("SD1",6,"D1_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_EMISSAO","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_DTDIGIT","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_TIPO","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_FORNECE","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_LOJA","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cRazSoc","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("cRazSoc"):GetFieldInfo("A2_NOME")
oSection1:Cell("cRazSoc"):SetSize(30)

TRCell():New(oSection1,"cMunic","   ",STR0068,"@!",15,/*lPixel*/,/*{|| code-block de impressao }*/) //"Praca"
TRCell():New(oSection1,"F1_COND","SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"nValIcm1","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("nValIcm1"):GetFieldInfo("F1_VALICM")
TRCell():New(oSection1,"nValIpi1","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("nValIpi1"):GetFieldInfo("F1_VALIPI")
TRCell():New(oSection1,"nTotNF1","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("nTotNF1"):GetFieldInfo("F1_VALMERC")

oSection1:SetNoFilter("SF1")
oSection1:SetNoFilter("SA1")
oSection1:SetNoFilter("SA2")
oSection1:SetNoFilter("SB1")

//================================
//?Definicao da Sessao 2                                        ?
//================================
oSection2 := TRSection():New(oSection1,STR0074,{"SD1","SF1","SA1","SA2","SB1"}) 
oSection2 :SetTotalInLine(.F.)
oSection2 :SetReadOnly()

//--------- Celulas utilizadas para ordem de Produto -----
TRCell():New(oSection2,"D1_DOC","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oSection2,"D1_EMISSAO","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D1_DTDIGIT","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D1_FORNECE","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"cRazSoc","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection2:Cell("cRazSoc"):GetFieldInfo("A2_NOME")   
oSection2:Cell("cRazSoc"):SetSize(30)

//--------- Celulas utilizadas para ordem de Nota --------
TRCell():New(oSection2,"D1_COD","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"cDescri","   ",STR0067,"@!",28,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D1_CF","SD1",STR0085/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Cd.Fisc."
TRCell():New(oSection2,"D1_TES","SD1",STR0086/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"TES"
TRCell():New(oSection2,"D1_PICM","SD1",STR0087/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"%ICMS"
TRCell():New(oSection2,"D1_IPI","SD1",STR0088/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"%IPI"
TRCell():New(oSection2,"D1_LOCAL","SD1",STR0089/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Amz"
//--------- Celulas utilizadas para ordem de Produto -----
TRCell():New(oSection2,"D1_TIPO","SD1",STR0090/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tp.Doc."
//--------------------------------------------------------
TRCell():New(oSection2,"D1_QUANT","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"nVunit","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection2:Cell("nVunit"):GetFieldInfo("D1_VUNIT")
TRCell():New(oSection2,"nVtotal","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection2:Cell("nVtotal"):GetFieldInfo("D1_TOTAL")  
oSection2:Cell("nVtotal"):SetTitle(STR0091)

oSection2:SetNoFilter("SF1")
oSection2:SetNoFilter("SA1")
oSection2:SetNoFilter("SA2")
oSection2:SetNoFilter("SB1")

//================================
//?Definicao da Sessao 3                                        ?
//================================
oSection3 := TRSection():New(oSection2,STR0075,{"SD1","SF1","SB1"}) 
oSection3 :SetTotalInLine(.F.)
oSection3 :SetReadOnly()

//--------- Celulas utilizadas para ordem de Nota --------
TRCell():New(oSection3,"F1_COND","SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nValIcm","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection3:Cell("nValIcm"):GetFieldInfo("F1_VALICM")
TRCell():New(oSection3,"nValIpi","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection3:Cell("nValIpi"):GetFieldInfo("F1_VALIPI")
//--------- Celulas utilizadas para ordem de Produto -----
TRCell():New(oSection3,"nTotImp","   ",STR0066,Pesqpict("SF1","F1_VALMERC",14),cTamVlr,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection3:SetNoFilter("SF1")
oSection3:SetNoFilter("SB1")

//================================
//?Definicao da Sessao 4                                        ?
//================================
oSection4 := TRSection():New(oSection3,STR0076,{"SD1","SF1","SB1"}) 
oSection4 :SetTotalInLine(.F.)
oSection4 :SetReadOnly()
TRCell():New(oSection4,"nFrete","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection4:Cell("nFrete"):GetFieldInfo("F1_FRETE")
TRCell():New(oSection4,"nDespesa","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection4:Cell("nDespesa"):GetFieldInfo("F1_DESPESA")
TRCell():New(oSection4,"nDesconto","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection4:Cell("nDesconto"):GetFieldInfo("F1_DESCONT")
TRCell():New(oSection4,"nTotNF","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection4:Cell("nTotNF"):GetFieldInfo("F1_VALMERC")
		
oSection4:SetNoFilter("SF1")
oSection4:SetNoFilter("SB1")


oSection3:SetEdit(.T.)
oSection4:SetEdit(.T.)

oSection1:SetEditCell(.T.)
oSection2:SetEditCell(.T.)

Return(oReport)

/*
===============================================================================================================================
Programa----------: RCOM013P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 21/03/2018
===============================================================================================================================
Descrição---------: Reportprint do relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM013P(oReport,cAliasSD1,nReg)

Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1)  
Local oSection3 := oReport:Section(1):Section(1):Section(1)  
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)    
Local nOrdem    := oReport:Section(1):GetOrder() 
Local aCampos   := {}                     
Local cFilUsrSD1:= ""
Local cSelect   := ""
Local cSelect1  := ""
Local cSelect2  := "%%"
Local cSelect3  := "%%"
Local cSelect4  := ""
Local cFrom     := "%%"
Local cWhereSF1 := ""
Local cWhereSB1 := "%%"
Local cOrder    := ""
LOCAL cDocAnt     := ""
LOCAL cCodAnt     := ""
LOCAL cAliasSF1   := "SF1"
LOCAL cAliasSB1   := "SB1"
LOCAL cAliasSA1   := "SA1"
LOCAL cAliasSA2   := "SA2"
LOCAL cAliasSF4   := "SF4"
LOCAL cForCli     := ""
LOCAL cMuni       := ""
LOCAL cFornF1     := ""
LOCAL cLojaF1     := ""
LOCAL cDocF1      := ""
LOCAL cSerieF1    := ""
LOCAL cCondF1     := ""
LOCAL cTipoF1     := ""
LOCAL cDescri     := ""
LOCAL cFornAnt    := ""
LOCAL cName       := ""
LOCAL nMoedaF1    := 0
LOCAL nTxMoedaF1  := 0
LOCAL nFreteF1    := 0
LOCAL nDespesaF1  := 0
LOCAL nSeguroF1   := 0
LOCAL nValTotF1   := 0
LOCAL nValMerc    := 0
LOCAL nValDesc    := 0
LOCAL nValIcm     := 0
LOCAL nValIpi     := 0
LOCAL nValImpInc  := 0
LOCAL nValImpNoInc:= 0
LOCAL nTotGeral   := 0
LOCAL nTotGerImp  := 0
LOCAL nTotDesco   := 0
LOCAL nTotFrete   := 0
LOCAL nTotSeguro  := 0
LOCAL nTotDesp    := 0
LOCAL nTotProd    := 0
LOCAL nTotQger    := 0
LOCAL nTotData    := 0
LOCAL nTotForn    := 0
LOCAL nTotquant   := 0
LOCAL nTGerIcm    := 0
LOCAL nTGerIpi    := 0
LOCAL nTGImpInc   := 0
LOCAL nTGImpNoInc := 0
LOCAL nImpInc     := 0
LOCAL nImpNoInc   := 0
LOCAL nImpos      := 0
LOCAL nCount      := 0
LOCAL nTaxa       := 1
LOCAL nMoeda      := 1
LOCAL nTpImp	  := IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0)	// Tipo de Impressao
LOCAL nPageWidth  := oReport:PageHeight(.F.)								// Altura da pagina
LOCAL nDecs       := Msdecimais(mv_par18)
LOCAL lQuery      := .F.
LOCAL lImp	      := .F.
LOCAL lFiltro     := .T.
LOCAL lDescLine   := .T.
LOCAL lPrintLine  := .F.
LOCAL lEasy       := If(GetMV("MV_EASY")=="S",.T.,.F.)
LOCAL lPlanTab    := oReport:lXlsTable
LOCAL aImpostos   := {} 
LOCAL dDtDig      := dDataBase
LOCAL dDataAnt    := dDataBase
LOCAL dEmissaoF1  := dDataBase
LOCAL dDtDigitF1  := dDataBase
LOCAL nX       := 0
Local nY       := 0
LOCAL aStrucSD1   := {}
Local cIdWhere := ""
//Local nF1VldC := 0

_atcam := SD1->(Dbstruct())

For nX := 1 To Len(_atcam)
    IF !ALLTRIM(_atcam[nX][1]) $ "D1_OBSCONT,D1_OBSFISC"//campos memos
	   AAdd(aCampos,alltrim(_atcam[nX][1]))
	ENDIF
	DbSkip()
Next

cIdWhere := "%"
cIdWhere += "SD1." + SerieNfId("SD1",3,"D1_SERIE") + " >= '" + mv_par14 + "'	AND "		
cIdWhere += "SD1." + SerieNfId("SD1",3,"D1_SERIE") + " <= '" + mv_par15 + "'	AND "
cIdWhere += "%"

If nOrdem == 1
	oReport:SetTitle( oReport:Title()+" - "+STR0005) //"Por Nota"

	oSection1:Cell("D1_COD"):Disable()
	oSection1:Cell("cDescri"):Disable()
	oSection1:Cell("B1_GRUPO"):Disable()
	
	oSection2:Cell("D1_DOC"):Disable()
	oSection2:Cell("D1_EMISSAO"):Disable()
	oSection2:Cell("D1_DTDIGIT"):Disable()
	oSection2:Cell("D1_FORNECE"):Disable()
	oSection2:Cell("cRazSoc"):Disable()
	oSection2:Cell("D1_TIPO"):Disable()
	
	oSection3:Cell("nTotImp"):Disable()
	
ElseIf nOrdem == 2
	oReport:SetTitle( oReport:Title()+" - "+STR0006) //"Por Produto"
	
	oSection1:Cell("D1_DOC"):Disable()
	oSection1:Cell(SerieNfId("SD1",3,"D1_SERIE")):Disable()
	oSection1:Cell("D1_EMISSAO"):Disable()
	oSection1:Cell("D1_DTDIGIT"):Disable()
	oSection1:Cell("D1_TIPO"):Disable()
	oSection1:Cell("D1_FORNECE"):Disable()
	oSection1:Cell("D1_LOJA"):Disable()
	oSection1:Cell("cRazSoc"):Disable()
	oSection1:Cell("cMunic"):Disable()
	oSection1:Cell("F1_COND"):Disable()
	If cPaisLoc == "BRA"
		oSection1:Cell("nValIcm1"):Disable()
		oSection1:Cell("nValIpi1"):Disable()
	Else
		oSection1:Cell("nImpNoInc1"):Disable()
		oSection1:Cell("nImpInc1"):Disable()
	Endif	
	oSection1:Cell("nTotNF1"):Disable()
	
	oSection2:Cell("D1_COD"):Disable()
	oSection2:Cell("cDescri"):Disable()
	oSection2:Cell("D1_DTDIGIT"):Disable()
	
	oSection3:Cell("F1_COND"):Disable()
	
ElseIf nOrdem == 3 .Or. nOrdem == 4
	If nOrdem == 3
		oReport:SetTitle( oReport:Title()+" - "+STR0043) //"Por Data Digitacao"
		oSection1:Cell("D1_EMISSAO"):Disable()
	Else
		oReport:SetTitle( oReport:Title()+" - "+STR0059) //"Por Data Emissao"
		oSection1:Cell("D1_DTDIGIT"):Disable()
	Endif	
	oSection1:Cell("D1_COD"):Disable()
	oSection1:Cell("cDescri"):Disable()
	oSection1:Cell("B1_GRUPO"):Disable()	
	oSection1:Cell("D1_TIPO"):Disable()
	oSection1:Cell("D1_LOJA"):Disable()
    If mv_par05 == 1
		oSection1:Cell("D1_DOC"):Disable()
		oSection1:Cell(SerieNfId("SD1",3,"D1_SERIE")):Disable()
		oSection1:Cell("D1_FORNECE"):Disable()
		oSection1:Cell("cRazSoc"):Disable()
		oSection1:Cell("cMunic"):Disable()
		oSection1:Cell("F1_COND"):Disable()
		If cPaisLoc == "BRA"
			oSection1:Cell("nValIcm1"):Disable()
			oSection1:Cell("nValIpi1"):Disable()
		Else
			oSection1:Cell("nImpNoInc1"):Disable()
			oSection1:Cell("nImpInc1"):Disable()
		Endif	
		oSection1:Cell("nTotNF1"):Disable()
	Else
		oSection1:Cell("D1_DOC"):Enable()
		oSection1:Cell(SerieNfId("SD1",3,"D1_SERIE")):Enable()
		oSection1:Cell("D1_FORNECE"):Enable()
		oSection1:Cell("cRazSoc"):Enable()
		oSection1:Cell("cMunic"):Enable()
		oSection1:Cell("F1_COND"):Enable()
		If cPaisLoc == "BRA"
			oSection1:Cell("nValIcm1"):Enable()
			oSection1:Cell("nValIpi1"):Enable()
		Else
			oSection1:Cell("nImpNoInc1"):Enable()
			oSection1:Cell("nImpInc1"):Enable()
		Endif	
		oSection1:Cell("nTotNF1"):Enable()
	Endif
	oSection2:Cell("D1_EMISSAO"):Disable()
	oSection2:Cell("D1_DTDIGIT"):Disable()
	oSection2:Cell("cDescri"):Disable()	
	
	oSection3:Cell("F1_COND"):Disable()

ElseIf nOrdem == 5
	oReport:SetTitle( oReport:Title()+" - "+STR0062) //"Por Fornecedor"	
	
	oSection1:Cell("D1_COD"):Disable()
	oSection1:Cell("cDescri"):Disable()
	oSection1:Cell("B1_GRUPO"):Disable()	
	oSection1:Cell("D1_TIPO"):Disable()
    If mv_par05 == 1
		oSection1:Cell("D1_DOC"):Disable()
		oSection1:Cell(SerieNfId("SD1",3,"D1_SERIE")):Disable()
		oSection1:Cell("D1_EMISSAO"):Disable()
		oSection1:Cell("D1_DTDIGIT"):Disable()
		oSection1:Cell("cMunic"):Disable()
		oSection1:Cell("F1_COND"):Disable()
		If cPaisLoc == "BRA"
			oSection1:Cell("nValIcm1"):Disable()
			oSection1:Cell("nValIpi1"):Disable()
		Else
			oSection1:Cell("nImpNoInc1"):Disable()
			oSection1:Cell("nImpInc1"):Disable()
		Endif	
		oSection1:Cell("nTotNF1"):Disable()
	Else
		oSection1:Cell("D1_DOC"):Enable()
		oSection1:Cell(SerieNfId("SD1",3,"D1_SERIE")):Enable()
		oSection1:Cell("D1_FORNECE"):Enable()
		oSection1:Cell("cRazSoc"):Enable()
		oSection1:Cell("cMunic"):Enable()
		oSection1:Cell("F1_COND"):Enable()
		If cPaisLoc == "BRA"
			oSection1:Cell("nValIcm1"):Enable()
			oSection1:Cell("nValIpi1"):Enable()
		Else
			oSection1:Cell("nImpNoInc1"):Enable()
			oSection1:Cell("nImpInc1"):Enable()
		Endif	
		oSection1:Cell("nTotNF1"):Enable()
	Endif
	oSection2:Cell("cDescri"):Disable()	
	oSection2:Cell("D1_FORNECE"):Disable()	
	oSection2:Cell("cRazSoc"):Disable()	
	
	oSection3:Cell("F1_COND"):Disable()	
	
Endif

If mv_par05 == 1
	oSection1:Cell("cMunic"):Disable()
	oSection1:Cell("F1_COND"):Disable()
	If cPaisLoc == "BRA"
		oSection1:Cell("nValIcm1"):Disable()
		oSection1:Cell("nValIpi1"):Disable()
	Else	
		oSection1:Cell("nImpNoInc1"):Disable()
		oSection1:Cell("nImpInc1"):Disable()
	Endif	
	oSection1:Cell("nTotNF1"):Disable()
Else
	If nOrdem <> 2
		oSection1:SetHeaderPage()
	Endif	
	If nOrdem == 1 .Or. nOrdem == 4 .Or. nOrdem == 5
		oSection1:Cell("D1_DTDIGIT"):Disable()
	Endif	
	If nOrdem == 3 
		oSection1:Cell("D1_EMISSAO"):Disable()
	Endif		
	oSection1:Cell("D1_TIPO"):Disable()
	oSection1:Cell("D1_LOJA"):Disable()
Endif

//================================
//?Posiciona a Ordem de todos os Arquivos usados no Relatorio   ?
//================================
dbSelectArea("SA1")
dbSetOrder(1)
dbSelectArea("SA2")
dbSetOrder(1)
dbSelectArea("SB1")
dbSetOrder(1)
dbSelectArea("SF4")
dbSetOrder(1)
dbselectarea("SF1")
dbsetorder(1)
dbSelectArea("SD1")
dbSetOrder(1)

//=====================================
//=iltragem do relatoio                                                  ?
//=====================================
cALiasSF1 := cAliasSD1
cALiasSB1 := IIF(!lEasy,cAliasSD1,"SB1")
cALiasSA1 := cAliasSD1
cALiasSA2 := cAliasSD1
lQuery :=.T.
aStrucSD1 := SD1->(dbStruct())     
//=====================================
// ransforma parametros Range em expressao SQL                            ?
//=====================================
MakeSqlExpr(oReport:uParam)
//=====================================
// uery do relatoio da secao 1                                           ?
//=====================================
oReport:Section(1):BeginQuery()	
//=====================================
//composicao do Select Inicial de acordo com a ordem escolhida            ?
//=====================================
cSelect := "%"
 	If nOrdem == 1
    	cSelect += "SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC,","")
    	cSelect += "SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_COD,SD1.D1_ITEM,"
    ElseIf nOrdem == 2 
	cSelect += "SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC,","")
	cSelect += "SD1.D1_FORNECE,SD1.D1_LOJA,"
ElseIf nOrdem == 3 
	cSelect += "SD1.D1_FILIAL,SD1.D1_DTDIGIT,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC,","")
	cSelect += "SD1.D1_FORNECE,SD1.D1_LOJA,"
    ElseIf nOrdem == 4 
    cSelect += "SD1.D1_FILIAL,SD1.D1_EMISSAO,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC,","")
    cSelect += "SD1.D1_FORNECE,SD1.D1_LOJA,"
    ElseIf nOrdem == 5 
    cSelect += "SD1.D1_FILIAL,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC,","") + "SD1.D1_ITEM,"
    Endif    
cSelect += "%"
//=====================================
//composicao do Select dos impostos variaveis                             ?
//=====================================	
cSelect1 := "%"

   
    For nX := 1 To Len(acampos)
	    cSelect1 +=acampos[nX]+"," 		 		
    Next nX	
cSelect1 += "%"
//=====================================
//composicao do Select da tabela SB1 quando nao for integrado com o EIC   ?
//=====================================		
If !lEasy        
	cSelect2 := "%"
		 cSelect2 += Iif(SerieNfId("SF1",3,"F1_SERIE")<>"F1_SERIE","F1_SDOC,","")
        cSelect2 += "B1_DESC,B1_GRUPO,"
        cSelect2 += "%"
    EndIf	
    //==================================?
    // sta rotina foi escrita para adicionar no select os campos         ?
    // sados no filtro do usuario quando houver, a rotina acrecenta      ?
    //omente os campos que forem adicionados ao filtro testando         ?
    //e os mesmo j?existem no select ou se forem definidos novamente   ?
    //elo o usuario no filtro, esta rotina acrecenta o minimo possivel  ?
    //e campos no select pois pelo fato da tabela SD1 ter muitos campos |
    // a query ter UNION ao adicionar todos os campos do SD1 estava     |
    //errubando o TOP CONNECT e abortando o sistema.                    |
    //==================================?   	
   	cFilUsrSD1:= oSection1:GetAdvplExp()
    If !Empty(cFilUsrSD1)
	cSelect4 := "D1_FILIAL,D1_DOC,D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","D1_SDOC,","")
	cSelect4 += "D1_FORNECE,D1_LOJA,D1_COD,D1_DTDIGIT,D1_QUANT,D1_TES,D1_IPI,"
	cSelect4 += "D1_VUNIT,D1_TOTAL,D1_VALFRE,D1_DESPESA,D1_SEGURO,D1_PEDIDO,D1_ITEMPC,D1_PICM,D1_TIPO,D1_CF," 
 	cSelect4 += "D1_GRUPO,D1_LOCAL,D1_ITEM,D1_EMISSAO,D1_VALDESC,D1_ICMSRET,D1_VALICM,D1_VALIPI"				    
	cSelect3 := "%"   
	For nX := 1 To SD1->(FCount())
		cName := SD1->(FieldName(nX))
	 	If AllTrim( cName ) $ cFilUsrSD1
      		If aStrucSD1[nX,2] <> "M"  
      			If !cName $ cSelect .And. !cName $ cSelect1 .And. !cName $ cSelect4
	        		cSelect3 += cName +","
	          	Endif 	
	       	EndIf
		EndIf 			       	
	Next nX 
	cSelect3 += "%"
    Endif    
//=====================================
//composicao do From da tabela SB1 quando nao for integrado com o EIC     ?
//=====================================		
If !lEasy        	  
	cFrom := "%"
    	cFrom += ","
    	cFrom += RetSqlName("SB1")+" SB1 "
    	cFrom += "%"
    EndIf
//=====================================
//composicao do Where para Remito                                         ?
//=====================================		
cWhereSF1 := "%"
cWhereSF1 += "NOT ("+IsRemito(3,'SF1.F1_TIPODOC')+ ") " 
cWhereSF1 += "%"
//=====================================
//composicao do Where para tabela SB1 quando nao for integrado com o EIC  ?
//=====================================			
If !lEasy        	        
	cWhereSB1 := "%"
        cWhereSB1 += "SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
        cWhereSB1 += "SB1.B1_COD = SD1.D1_COD AND "
        cWhereSB1 += "SB1.D_E_L_E_T_ <> '*' AND "
        cWhereSB1 += "%"	
    EndIf
//=====================================
//composicao do Order By de acordo com a ordem escolhida                  ?
//=====================================			
cOrder := "%"
 	If nOrdem == 1
    	cOrder += "1,2,3,4,5,6,7"		
    Else
    cOrder += "1,2,3,4,5,6"		
    Endif	
cOrder += "%"

BeginSql Alias cAliasSD1

	SELECT %Exp:cSelect%
	 	  	D1_DTDIGIT,D1_COD,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_VALFRE,D1_DESPESA,D1_SEGURO,D1_PEDIDO,D1_ITEMPC,
	 	  	%Exp:cSelect3%	 			
 			D1_TES,D1_IPI,D1_PICM,D1_TIPO,D1_CF,D1_GRUPO,D1_LOCAL,D1_ITEM,D1_EMISSAO,D1_VALDESC,D1_ICMSRET,D1_VALICM,D1_VALIPI,
 			%Exp:cSelect1%
 		    F1_FILIAL,F1_MOEDA,F1_TXMOEDA,F1_DTDIGIT,F1_TIPO,F1_COND,F1_VALICM,F1_VALIPI,F1_VALIMP1,
		    F1_FRETE,F1_DESPESA,F1_SEGURO,F1_DESCONT,F1_VALMERC,F1_DOC,F1_SERIE,F1_EMISSAO,F1_FORNECE,F1_LOJA,F1_VALBRUT,
		    %Exp:cSelect2%
		    A1_NOME RAZAO,A1_MUN RAZMUNI,SD1.R_E_C_N_O_ SD1RECNO 

	FROM %table:SF1% SF1,%table:SD1% SD1,%table:SA1% SA1 %Exp:cFrom%

	WHERE 	SF1.F1_FILIAL  =  %xFilial:SF1% 	AND
	      	%Exp:cWhereSF1%	  	    	        AND			
	      	SF1.%NotDel%          		        AND						   		  
	      	SD1.D1_FILIAL  =  	%xFilial:SD1%  	AND
	      	SD1.D1_DOC     = 	SF1.F1_DOC     	AND
	      	SD1.D1_SERIE   = 	SF1.F1_SERIE    AND
			SD1.D1_FORNECE = 	SF1.F1_FORNECE  AND
			SD1.D1_LOJA    = 	SF1.F1_LOJA     AND
			SD1.D1_TIPO IN ('D','B') 			AND 
			SD1.D1_TIPODOC = SF1.F1_TIPODOC 	AND 
			SD1.%NotDel%          		        AND						   		  
			%Exp:cWhereSB1%		    	           							
			SA1.A1_FILIAL  =  %xFilial:SA1% 	AND
			SA1.A1_COD     = 	 SD1.D1_FORNECE 	AND
			SA1.A1_LOJA    =  SD1.D1_LOJA    	AND 
			SA1.%NotDel%          		        AND						   		  
			SD1.D1_COD     >= %Exp:mv_par01%	AND		
			SD1.D1_COD     <= %Exp:mv_par02%	AND
			SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par03)% AND 
			SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par04)% AND 
			SD1.D1_GRUPO   >= %Exp:mv_par06%	AND		
			SD1.D1_GRUPO   <= %Exp:mv_par07%	AND                      
   			SD1.D1_FORNECE >= %Exp:mv_par08%	AND		
			SD1.D1_FORNECE <= %Exp:mv_par09%	AND
			SD1.D1_LOCAL   >= %Exp:mv_par10%	AND		
			SD1.D1_LOCAL   <= %Exp:mv_par11%	AND		
			SD1.D1_DOC     >= %Exp:mv_par12%	AND		
			SD1.D1_DOC     <= %Exp:mv_par13%	AND
			%Exp:cIdWhere%	
			SD1.D1_TES     >= %Exp:mv_par16%	AND		
			SD1.D1_TES     <= %Exp:mv_par17%	   		

    UNION
    
	SELECT %Exp:cSelect%
	 	  	D1_DTDIGIT,D1_COD,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_VALFRE,D1_DESPESA,D1_SEGURO,D1_PEDIDO,D1_ITEMPC,
 			%Exp:cSelect3%		 	  	
 			D1_TES,D1_IPI,D1_PICM,D1_TIPO,D1_CF,D1_GRUPO,D1_LOCAL,D1_ITEM,D1_EMISSAO,D1_VALDESC,D1_ICMSRET,D1_VALICM,D1_VALIPI,
 			%Exp:cSelect1%
 		    F1_FILIAL,F1_MOEDA,F1_TXMOEDA,F1_DTDIGIT,F1_TIPO,F1_COND,F1_VALICM,F1_VALIPI,F1_VALIMP1,
		    F1_FRETE,F1_DESPESA,F1_SEGURO,F1_DESCONT,F1_VALMERC,F1_DOC,F1_SERIE,F1_EMISSAO,F1_FORNECE,F1_LOJA,F1_VALBRUT,
		    %Exp:cSelect2%
		    A2_NOME RAZAO,A2_MUN RAZMUNI,SD1.R_E_C_N_O_ SD1RECNO 
		    
	FROM %table:SF1% SF1,%table:SD1% SD1,%table:SA2% SA2 %Exp:cFrom%

	WHERE 	SF1.F1_FILIAL  =  %xFilial:SF1% 	AND
	      	%Exp:cWhereSF1%	  	    	        AND			
	      	SF1.%NotDel%          		        AND						   		  
	      	SD1.D1_FILIAL  = %xFilial:SD1%  	AND
	      	SD1.D1_DOC     = 	SF1.F1_DOC     	AND
	      	SD1.D1_SERIE   = 	SF1.F1_SERIE    AND
			SD1.D1_FORNECE = 	SF1.F1_FORNECE  AND
			SD1.D1_LOJA    = 	SF1.F1_LOJA     AND
			SD1.D1_TIPO NOT IN ('D','B') 		AND 
			SD1.D1_TIPODOC = SF1.F1_TIPODOC 	AND 
			SD1.%NotDel%          		        AND						   		  
			%Exp:cWhereSB1%	  	    	           							
			SA2.A2_FILIAL  =  %xFilial:SA2% 	AND
			SA2.A2_COD     = 	SD1.D1_FORNECE 	AND
			SA2.A2_LOJA    =   	SD1.D1_LOJA    	AND 
			SA2.%NotDel%          		        AND						   		  
			SD1.D1_COD     >= %Exp:mv_par01%	AND		
			SD1.D1_COD     <= %Exp:mv_par02%	AND
			SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par03)% AND 
			SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par04)% AND 
			SD1.D1_GRUPO   >= %Exp:mv_par06%	AND		
			SD1.D1_GRUPO   <= %Exp:mv_par07%	AND                      
   			SD1.D1_FORNECE >= %Exp:mv_par08%	AND		
			SD1.D1_FORNECE <= %Exp:mv_par09%	AND
			SD1.D1_LOCAL   >= %Exp:mv_par10%	AND		
			SD1.D1_LOCAL   <= %Exp:mv_par11%	AND		
			SD1.D1_DOC     >= %Exp:mv_par12%	AND		
			SD1.D1_DOC     <= %Exp:mv_par13%	AND
			%Exp:cIdWhere%	
			SD1.D1_TES     >= %Exp:mv_par16%	AND		
			SD1.D1_TES     <= %Exp:mv_par17%	   			   		  

	ORDER BY %Exp:cOrder%		
		
EndSql 
//=====================================
// etodo EndQuery ( Classe TRSection )                                    ?
//?                                                                       ?
//=repara o relatoio para executar o Embedded SQL.                       ?
//?                                                                       ?
// xpA1 : Array com os parametros do tipo Range                           ?
//?                                                                       ?
//=====================================
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

oSection2:SetParentQuery()
oSection3:SetParentQuery()
oSection4:SetParentQuery()

cFilUsrSD1:= oSection1:GetAdvplExp()

//=====================================
//inicio da impressao do fluxo do relatoio                               ?
//=====================================
dbselectArea(cAliasSD1)
oReport:SetMeter(SD1->(LastRec()))

If !lquery
	(cAliasSF1)->(dbseek( xFilial("SF1") + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA)) //posiciona o cabecalho da nota
Endif

nTaxa   := (cAliasSF1)->F1_TXMOEDA
nMoeda  := (cAliasSF1)->F1_MOEDA
dDtDig  := (cAliasSF1)->F1_DTDIGIT
cDocAnt := (cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA

While !oReport:Cancel() .And. (cAliasSD1)->(!Eof()) .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") 

	lFiltro := .T.  
	nCount++
	//================================
	//?Se cancelado pelo usuario                            	     ?
	//================================
	If oReport:Cancel()
		Exit
	EndIf
	//================================
	//verifica moeda nao imprimir com moeda diferente da escolhida  ?
	//================================
	If mv_par19 == 2
		if if((cAliasSF1)->F1_MOEDA == 0,1,(cAliasSF1)->F1_MOEDA) != mv_par18
			lFiltro := .F.
		Endif
	Endif
		
	//================================
	//?Despreza Nota Fiscal sem TES de acordo com parametro         ?
	//================================
	If mv_par22 == 2 .And. Empty(D1_TES)
		lFiltro := .F.
	Endif
	
	//================================
	//?Considera filtro escolhido                                   ?
	//================================
	dbSelectArea(cAliasSD1)
	If !Empty(cFilUsrSD1)
	    If !(&(cFilUsrSD1))
			lFiltro := .F.
    	EndIf   
	EndIf

	If lFiltro
		
		lImp := .T.
		cDescri := ""
		//================================
		//?Verifica o parametro para imprimir a descricao do produto    ?
		//================================
		If Empty(mv_par21)
			mv_par21 := "B1_DESC"
		ElseIf AllTrim(mv_par21) == "B5_CEME" // Impressao da descricao cientifica do Produto.
			dbSelectArea("SB5")
			dbSetOrder(1)
			If dbSeek( xFilial("SB5")+(cAliasSD1)->D1_COD )
				cDescri := Alltrim(B5_CEME)
			EndIf
		ElseIf AllTrim(mv_par21) == "C7_DESCRI" // Impressao da descricao do Produto no pedido de compras.
			dbSelectArea("SC7")
			dbSetOrder(4)
			If dbSeek( xFilial("SC7")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC )
				cDescri := Alltrim(SC7->C7_DESCRI)
			EndIf
		EndIf
		//================================
		//?Faz a Quebra da Linha de descricao para todas ordens do Rela.?
		//================================
		If lDescLine == .T.

			// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
			If nTpImp == 6
				If oReport:Row() > (nPageWidth-500)
					oSection1:SetPageBreak(.T.)
				Else
					oSection1:SetPageBreak(.F.)
				EndIf
			EndIf

			If nOrdem == 1 .And. mv_par05 == 1
				
				If (cAliasSD1)->D1_TIPO $ "BD"
					If !lQuery
						(cAliasSA1)->(dbSeek(xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
						oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->A1_NOME)
                    Else
						oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
					Endif                                                       
				Else
					If !lQuery
						(cAliasSA2)->(dbSeek(xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
						oSection1:Cell("cRazSoc"):SetValue((cAliasSA2)->A2_NOME)
					Else
						oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
					Endif
				EndIf

				oSection1:Init() 
				oSection1:PrintLine()
				
			Elseif nOrdem == 2
				
				// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
				If nTpImp == 6
					If oReport:Row() > (nPageWidth-500)
						oSection1:SetPageBreak(.T.)
					Else
						oSection1:SetPageBreak(.F.)
					EndIf
				EndIf

				 If !lPlanTab 
							If !lQuery .Or. lEasy
						 		(cAliasSB1)->(dbSeek(xFilial("SB1") + (cAliasSD1)->D1_COD))
							EndIf
						 	
							If Empty(cDescri) .Or. AllTrim(mv_par21) == "B1_DESC" // Impressao da descricao generica do Produto.
								cDescri := Alltrim((cAliasSB1)->B1_DESC)
							EndIf
							 
							oSection1:Cell("cDescri"):SetValue(cDescri)
			
							oSection1:Init() 
							oSection1:PrintLine()
							
							cCodAnt   := (cAliasSD1)->D1_COD
							nTotProd  := 0
							nTotQuant := 0
					
				 Else          
							While (cAliasSD1)->(!EOF())
	
							If Empty(cDescri) .Or. AllTrim(mv_par21) == "B1_DESC" // Impressao da descricao generica do Produto.
								cDescri := Alltrim((cAliasSB1)->B1_DESC)
							EndIf
							oSection1:Cell("cDescri"):SetValue(cDescri)
							oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
							oSection1:Cell("nValIcm1"):SetValue((cAliasSD1)->D1_VALICM)
							oSection1:Cell("nValIpi1"):SetValue((cAliasSD1)->D1_VALIPI)
							
			              oSection1:Cell("nTotNF1"):SetValue((cAliasSD1)->D1_TOTAL)
			              
			              
			              
							oSection1:Init() 
							oSection1:PrintLine()
							
							cCodAnt   := (cAliasSD1)->D1_COD
							nTotProd  := 0
							nTotQuant := 0
												    
						   (cAliasSD1)->(DbSkip())
						   					   				    
							EndDo
							oSection1:Finish()
				 EndIf
				
			Elseif nOrdem == 3 .Or. nOrdem == 4

				// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
				If nTpImp == 6
					If oReport:Row() > (nPageWidth-500)
						oSection1:SetPageBreak(.T.)
					Else
						oSection1:SetPageBreak(.F.)
					EndIf
				EndIf

				If mv_par05 == 1
				   	oSection1:Cell("cRazSoc"):SetValue((cAliasSA2)->RAZAO)
					oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
					oSection1:Init() 
					oSection1:PrintLine()
				Endif	
				
				dDataAnt := IIf(nOrdem == 3,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_EMISSAO)
			Elseif nOrdem == 5
				If mv_par05 == 1

					// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
					If nTpImp == 6
						If oReport:Row() > (nPageWidth-500)
							oSection1:SetPageBreak(.T.)
						Else
							oSection1:SetPageBreak(.F.)
						EndIf
					EndIf

					If (cAliasSD1)->D1_TIPO $ "BD"
						If !lquery
							(cAliasSA1)->(dbSeek(xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
							oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->A1_NOME)
        	            Else
							oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
						Endif
					Else
						If !lquery
							(cAliasSA2)->(dbSeek(xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
							oSection1:Cell("cRazSoc"):SetValue((cAliasSA2)->A2_NOME)
						Else
							oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
						Endif
					EndIf

					oSection1:Init() 
					oSection1:PrintLine()
				Endif
				cFornAnt := (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA
			Endif
			lDescLine := .F.
		Endif
		
		//================================
		//=osiciona o F4 para todas as ordens quando nao for query TES  ?
		//================================
		(cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
		
		//================================
		//impressao do corpo do relatorio para todas as ordens          ?
		//================================
		If nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem ==5
			
			If mv_par05 == 1
				
				If !lQuery .Or. lEasy
					(cAliasSB1)->(dbSeek(xFilial("SB1") + (cAliasSD1)->D1_COD))
				EndIf
				
				If Empty(cDescri) .Or. AllTrim(mv_par21) == "B1_DESC" // Impressao da descricao generica do Produto.
					cDescri := Alltrim((cAliasSB1)->B1_DESC)
				EndIf
				
				If Empty(cDescri) 
					cDescri := Space(28)
				Endif
				
				oSection2:Cell("cDescri"):SetValue(cDescri)

                    nValIcm   += (cAliasSD1)->D1_VALICM
                    nValIpi   += (cAliasSD1)->D1_VALIPI						
                    nTgerIcm  += (cAliasSD1)->D1_VALICM
                    nTgerIpi  += (cAliasSD1)->D1_VALIPI

					// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
					If nTpImp == 6
						If oReport:Row() > (nPageWidth-500)
							oSection2:SetPageBreak(.T.)
						Else
							oSection2:SetPageBreak(.F.)
						EndIf
					EndIf

					If (cAliasSF4)->F4_AGREG != "N"
						nValMerc  := nValMerc + (cAliasSD1)->D1_TOTAL + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0)
						nTotGeral := nTotGeral + (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
			            If (cAliasSF4)->F4_AGREG = "I"
				           nValMerc  += (cAliasSD1)->D1_VALICM
				           nTotGeral += (cAliasSD1)->D1_VALICM
                        Endif 
					Else 
						nTotGeral := nTotGeral - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
					Endif
					
					//================================
					//?Soma valor do IPI caso a nota nao seja compl. de IPI    	 ?
					//?e o TES Calcula IPI nao seja "R"                             ?
					//================================
					If (cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
						If (cAliasSD1)->D1_TIPO != "P" .And. (cAliasSF4)->F4_IPI != "R"
							nValMerc  += (cAliasSD1)->D1_VALIPI
							nTotGeral += (cAliasSD1)->D1_VALIPI
						EndIf
					Else
						If (cAliasSD1)->D1_TIPO != "P"
							nValMerc  += (cAliasSD1)->D1_VALIPI
							nTotGeral += (cAliasSD1)->D1_VALIPI
						EndIf
					EndIf

				oSection2:Cell("nVunit"):SetValue(xmoeda((cAliasSD1)->D1_VUNIT,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa))
				oSection2:Cell("nVtotal"):SetValue(xmoeda((cAliasSD1)->D1_TOTAL,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa))
				
				nValDesc  += xmoeda((cAliasSD1)->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				nTotDesco += xmoeda((cAliasSD1)->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				oSection2:Cell("cRazSoc"):SetValue((cAliasSA2)->RAZAO)
				oSection2:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
				oSection2:Init() 
				oSection2:PrintLine()
				
			ElseIf mv_par05 == 2
				
				If cPaisLoc <> "BRA"
					aImpostos := TesImpInf((cAliasSD1)->D1_TES)
					For nY := 1 to Len(aImpostos)
						cCampImp := (cAliasSD1)+"->" + (aImpostos[nY][2])
						nImpos   := &cCampImp
						nImpos   := xmoeda(nImpos,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
						If cPaisLoc == "PER"
							//================================
							//?Se for Peru, realiza os calculos de impostos como no         ?
							//?relatorio em modelo nao personalizado (R3)                   ?
							//================================
							If ( aImpostos[nY][3] == "1" )
								nImpInc	+= nImpos
							Else
								If aImpostos[nY][3] == "2" 
									nImpInc -= nImpos
								Else
									nImpNoInc += nImpos
								Endif
							EndIf
						Else
							If ( aImpostos[nY][3] == "1" )
								If Len(aImpostos[nY]) >= 12
									If( aImpostos[nY][1] == "IVA" .Or. aImpostos[nY][12] == "IVA" )
										nImpInc	+= nImpos
									EndIf
								Else
									nImpInc	+= nImpos
								EndIf
							Else
								If aImpostos[nY][3] == "2"
									If Len(aImpostos[nY]) >= 12 
										If( aImpostos[nY][1] == "IVA" .Or. aImpostos[nY][12] == "IVA" )
											nImpInc -= nImpos
										EndIf
									Else
										nImpInc -= nImpos
									EndIf
								Else
									If Len(aImpostos[nY]) >= 12
										If( aImpostos[nY][1] == "IVA" .Or. aImpostos[nY][12] == "IVA" )
											nImpNoInc += nImpos
										EndIf
									Else
										nImpNoInc += nImpos
									EndIf
								Endif
							EndIf
						EndIf	
					Next
					nValMerc := nValMerc + xmoeda(D1_TOTAL - D1_VALDESC,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
				Else

                    nValIcm  += (cAliasSD1)->D1_VALICM
                    nValIpi  += (cAliasSD1)->D1_VALIPI
					
					If (cAliasSF4)->F4_AGREG != "N"
						nValMerc := nValMerc + (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
			            If (cAliasSF4)->F4_AGREG = "I"
				            nValMerc += (cAliasSD1)->D1_VALICM
                        Endif 
					Else	
						nValMerc := nValMerc - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
					Endif
					
					If (cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
						nValMerc += IF((cAliasSF1)->F1_TIPO != "P" .And. (cAliasSF4)->F4_IPI != "R",(cAliasSD1)->D1_VALIPI,0)
					Else
						nValMerc += IF((cAliasSF1)->F1_TIPO != "P",(cAliasSD1)->D1_VALIPI,0)
					EndIf
				EndIf
			Endif
		Else
			If nOrdem <> 5 .and. (!lPlanTab .AND. nOrdem == 2)			
				If (cAliasSD1)->D1_TIPO $ "BD"
					If !lquery
						(cAliasSA1)->(dbSeek(xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
						oSection2:Cell("cRazSoc"):SetValue((cAliasSA1)->A1_NOME)
      				Else
						oSection2:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
					Endif
				Else
					If !lquery
					(cAliasSA2)->(dbSeek(xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
						oSection2:Cell("cRazSoc"):SetValue((cAliasSA2)->A2_NOME)
					Else
						oSection2:Cell("cRazSoc"):SetValue((cAliasSA1)->RAZAO)
					Endif
				EndIf				
			EndIf
			   If !lPlanTab .AND. nOrdem == 2			
					oSection2:Cell("nVunit"):SetValue(xmoeda((cAliasSD1)->D1_VUNIT,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa))
					oSection2:Cell("nVtotal"):SetValue(xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa))			
					
					If (cAliasSF4)->F4_AGREG != "N"
						nTotProd  += xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
						nTotQuant += (cAliasSD1)->D1_QUANT
						nTotData  += xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)
						nTotForn  += xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)
					    If (cAliasSF4)->F4_AGREG = "I"
						    nTotProd  += xmoeda((cAliasSD1)->D1_VALICM,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
						    nTotData  += xmoeda((cAliasSD1)->D1_VALICM,nMoeda,mv_par18,,nDecs+1,nTaxa)
						    nTotForn  += xmoeda((cAliasSD1)->D1_VALICM,nMoeda,mv_par18,,nDecs+1,nTaxa)
		                Endif 
					Else
						nTotProd  -= xmoeda((cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
						nTotData  -= xmoeda((cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)				
						nTotForn  -= xmoeda((cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)				
					Endif
				EndIf
			If cPaisLoc <> "BRA" // Inserido BOPS 92436
				aImpostos := TesImpInf((cAliasSD1)->D1_TES)
				For nY := 1 to Len(aImpostos)
					cCampImp := (cAliasSD1)+"->" + (aImpostos[nY][2])
					nImpos   := &cCampImp
					nImpos   := xmoeda(nImpos,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
					If ( aImpostos[nY][3] == "1" )
						nImpInc	+= nImpos
					Else
						If aImpostos[nY][3] == "2" 
							nImpInc -= nImpos
						Else
							nImpNoInc += nImpos
						Endif
					EndIf
				Next
				nValMerc := nValMerc + xmoeda(D1_TOTAL - D1_VALDESC,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
			Else
                nValIcm  += (cAliasSD1)->D1_VALICM
                nValIpi  += (cAliasSD1)->D1_VALIPI
				
				If (cAliasSF4)->F4_AGREG != "N"
					nValMerc := nValMerc + (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
		            If (cAliasSF4)->F4_AGREG = "I"
			            nValMerc += (cAliasSD1)->D1_VALICM
                    Endif 
				Else	
					nValMerc := nValMerc - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
				Endif
					
				If (cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
					nValMerc += IF((cAliasSF1)->F1_TIPO != "P" .And. (cAliasSF4)->F4_IPI != "R",(cAliasSD1)->D1_VALIPI,0)
				Else
					nValMerc += IF((cAliasSF1)->F1_TIPO != "P",(cAliasSD1)->D1_VALIPI,0)
				EndIf
			EndIf
            lPrintLine:= .T.

			// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
			If nTpImp == 6
				If oReport:Row() > (nPageWidth-500)
					oSection2:SetPageBreak(.T.)
				Else
					oSection2:SetPageBreak(.F.)
				EndIf
			EndIf
         If !lPlanTab .AND. nOrdem == 2
			oSection2:Init() 
			oSection2:PrintLine()
         EndIf

		Endif
  		
		nTotFrete += xmoeda((cAliasSD1)->D1_VALFRE,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		nTotSeguro+= xmoeda((cAliasSD1)->D1_SEGURO ,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		nTotDesp  += xmoeda((cAliasSD1)->D1_DESPESA,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
			  		
		cFornF1     := (cAliasSF1)->F1_FORNECE
		cLojaF1     := (cAliasSF1)->F1_LOJA
		cDocF1      := (cAliasSF1)->F1_DOC
		cSerieF1    := Alltrim((cAliasSF1)->&(SerieNfId("SF1",3,"F1_SERIE")))
		cTipoF1     := (cAliasSF1)->F1_TIPO
		cCondF1     := (cAliasSF1)->F1_COND
		nMoedaF1    := (cAliasSF1)->F1_MOEDA
		nTxMoedaF1  := (cAliasSF1)->F1_TXMOEDA
		nFreteF1    := (cAliasSF1)->F1_FRETE
		nDespesaF1  := (cAliasSF1)->F1_DESPESA
		nSeguroF1   := (cAliasSF1)->F1_SEGURO
		nValTotF1   := (cAliasSF1)->F1_VALBRUT
		dEmissaoF1  := (cAliasSF1)->F1_EMISSAO
		dDtDigitF1  := (cAliasSF1)->F1_DTDIGIT
		
		If lQuery
			cForCli  := (cAliasSF1)->RAZAO
			cMuni    := (cAliasSF1)->RAZMUNI
		Endif
	ElseIf nOrdem == 5 .And. "D1_TOTAL" $ cFilUsrSD1
		//=======================?
		//?Limpa os registros que nao serao filtrados  ?
		//=======================?
		cFornAnt := (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA

		lDescLine := .F.
		
		cFornF1     := ""
		cLojaF1     := ""
		cDocF1      := ""
		cSerieF1    := ""
		cTipoF1     := ""
		cCondF1     := ""
		nMoedaF1    := 0
		nTxMoedaF1  := 0
		nFreteF1    := 0
		nDespesaF1  := 0
		nSeguroF1   := 0
		nValTotF1   := 0
		dEmissaoF1  := ctod("  /  /  ")
		dDtDigitF1  := ctod("  /  /  ")
		
		If lQuery
			cForCli  := ""
			cMuni    := ""
		Endif
	Endif
	//================================
	//incrementa a Regua de processamento no salto do registro      ?
	//================================
	dbSelectArea(cAliasSD1)
	dbSkip()

	oReport:IncMeter()
	
	If nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5
		
		If ((cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA <> cDocAnt) .Or. ( lPlanTab .And. nCount == 1 )
			
			If (nValIcm + nValMerc + nValIpi + nValImpInc + nValImpNoInc) > 0
				If mv_par05 == 1

					// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
					If nTpImp == 6
						If oReport:Row() > (nPageWidth-500)
							oSection3:SetPageBreak(.T.)
						Else
							oSection3:SetPageBreak(.F.)
						EndIf
					EndIf

					oSection3:Init() 
					oSection3:Cell("F1_COND"):SetValue(cCondF1)
					oSection3:Cell("nValIcm"):SetValue(nValIcm)
					oSection3:Cell("nValIpi"):SetValue(nValIpi)	
					If lPlanTab
						If nCount == 1 .And. ((cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA) == cDocAnt
							oSection3:Cell("F1_COND"):Hide()
							oSection3:Cell("nValIcm"):Hide()
							oSection3:Cell("nValIpi"):Hide()	
						Else
							oSection3:Cell("F1_COND"):Show()
							oSection3:Cell("nValIcm"):Show()
							oSection3:Cell("nValIpi"):Show()	
						EndIf
					EndIf
					oSection3:PrintLine()
					oSection4:Cell("nFrete"):SetValue(nTotFrete)
					oSection4:Cell("nDespesa"):SetValue(nTotDesp+nTotSeguro)
					oSection4:Cell("nDesconto"):SetValue(nValDesc)
					If mv_par20 == 2
						oSection4:Cell("nTotNF"):SetValue((nValMerc - nValDesc) + nTotDesp + nTotFrete + nTotSeguro)
						nTotGeral := nTotGeral + nTotDesp + nTotFrete + nTotSeguro
					Else
						oSection4:Cell("nTotNF"):SetValue(xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa))
						nTotGeral := nTotGeral - (nValMerc - nValDesc) + xmoeda( nValTotF1 ,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
					EndIf
					If lPlanTab
						If nCount == 1 .And. ((cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA) == cDocAnt
							oSection4:Cell("nFrete"):Hide()
							oSection4:Cell("nDespesa"):Hide()
							oSection4:Cell("nDesconto"):Hide()
							oSection4:Cell("nTotNF"):Hide()
						Else
							oSection4:Cell("nFrete"):Show()
							oSection4:Cell("nDespesa"):Show()
							oSection4:Cell("nDesconto"):Show()
							oSection4:Cell("nTotNF"):Show()
						EndIf
					EndIf

					oSection4:Init()
					oSection4:PrintLine()
					oReport:SkipLine()
					oReport:FatLine()

					oSection1:Finish()
					oSection2:Finish()
					oSection3:Finish()
					oSection4:Finish()

				ElseIf mv_par05 == 2
					
						// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
						If nTpImp == 6
							If oReport:Row() > (nPageWidth-500)
								oSection1:SetPageBreak(.T.)
							Else
								oSection1:SetPageBreak(.F.)
							EndIf
						EndIf

						//================================
						//?Imprime a linha da nota fiscal                               ?
						//================================
						oSection1:Cell("D1_DOC"):SetValue(cDocF1)
						oSection1:Cell(SerieNfId("SD1",3,"D1_SERIE")):SetValue(cSerieF1)
						oSection1:Cell("D1_EMISSAO"):SetValue(dEmissaoF1)
						oSection1:Cell("D1_DTDIGIT"):SetValue(dDtDigitF1)
						oSection1:Cell("D1_FORNECE"):SetValue(cFornF1)
						oSection1:Cell("F1_COND"):SetValue(cCondF1)
						oSection1:Cell("nValIcm1"):SetValue(nValIcm)
						oSection1:Cell("nValIpi1"):SetValue(nValIpi)
						If mv_par20 == 2
							oSection1:Cell("nTotNF1"):SetValue((nValMerc + nTotDesp + nTotFrete + nTotSeguro))
						Else
				   			oSection1:Cell("nTotNF1"):SetValue(xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa))
				 		Endif
						If cTipoF1 $ "BD"
							If !lQuery
								(cAliasSA1)->(dbSeek( xFilial("SA1") + (cAliasSF1)->F1_FORNECE + (cAliasSF1)->F1_LOJA ))
								oSection1:Cell("cRazSoc"):SetValue((cAliasSA1)->A1_NOME)
								oSection1:Cell("cMunic"):SetValue((cAliasSA1)->A1_MUN)
							Else
								oSection1:Cell("cRazSoc"):SetValue(cForCli)
								oSection1:Cell("cMunic"):SetValue(cMuni)
							Endif
						Else
							If !lQuery
								(cAliasSA2)->(dbSeek( xFilial("SA2") + (cAliasSF1)->F1_FORNECE + (cAliasSF1)->F1_LOJA))
								oSection1:Cell("cRazSoc"):SetValue((cAliasSA2)->A2_NOME)
								oSection1:Cell("cMunic"):SetValue((cAliasSA2)->A2_MUN)
							Else
								oSection1:Cell("cRazSoc"):SetValue(cForCli)
								oSection1:Cell("cMunic"):SetValue(cMuni)							
							Endif
						EndIf
						nTgerIcm += nValIcm
						nTgerIpi += nValIpi

	  					oSection1:Init() 
	  					oSection1:PrintLine()
					
						If mv_par20 == 2
							nTotGeral:= nTotGeral + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
							nTotData := nTotData + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
							nTotForn := nTotForn + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
						Else
							nTotGeral:= nTotGeral + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
							nTotData := nTotData + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
							nTotForn := nTotForn + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
						EndIf
                    
				   If nOrdem == 5
						If cFornAnt != (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA 
							lDescLine := .T.
							oReport:SkipLine()
							nLin := oReport:Row()
							oReport:PrintText(STR0065,nLin)	//"TOTAL DO FORNECEDOR :"
							oReport:PrintText(TransForm(nTotForn,Pesqpict("SD1","D1_TOTAL")),nLin,oSection1:Cell('nTotNF1'):ColPos()-30)											
							oReport:SkipLine()
							oReport:FatLine()							
							oReport:SkipLine()
							nTotForn := 0
						Endif				
				   Else                                                      
						If (dDataAnt != (cAliasSD1)->D1_DTDIGIT) .And. nOrdem == 3 .Or. (dDataAnt != (cAliasSD1)->D1_EMISSAO) .And. nOrdem == 4 
							lDescLine := .T.
							oReport:SkipLine()
							nLin := oReport:Row()
							oReport:PrintText(STR0046,nLin)	//"TOTAL NA DATA : "
							oReport:PrintText(TransForm(nTotData,Pesqpict("SD1","D1_TOTAL")),nLin,oSection1:Cell('nTotNF1'):ColPos()-35)
							oReport:SkipLine()
							oReport:FatLine()
							oReport:SkipLine()
							nTotData := 0
						Endif	
					   EndIf
					
				Endif
			Endif
			
			//================================
			//?Imprime a linha totalizadora considerando as notas que nao   ?
			//?filtradas considerando a soma do valor 0 ao total            ?
			//================================
			If !lFiltro .And. nOrdem == 5 .And. "D1_TOTAL" $ cFilUsrSD1
				If mv_par20 == 2
					nTotGeral:= nTotGeral + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
					nTotData := nTotData + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
					nTotForn := nTotForn + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
				Else
					nTotGeral:= nTotGeral + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
					nTotData := nTotData + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
					nTotForn := nTotForn + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				EndIf
	                    
              If nOrdem == 5
             		If nTotForn > 0
						If cFornAnt != (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA 
							lDescLine := .T.
							oReport:SkipLine()
							nLin := oReport:Row()
							oReport:PrintText(STR0065,nLin)	//"TOTAL DO FORNECEDOR :"
							oReport:PrintText(TransForm(nTotForn,Pesqpict("SD1","D1_TOTAL")),nLin,oSection1:Cell('nTotNF1'):ColPos()-30)											
							oReport:SkipLine()
							oReport:FatLine()							
							oReport:SkipLine()
							nTotForn := 0
						Endif	
					EndIf			
              Else        
              		If nTotData > 0                                               
						If (dDataAnt != (cAliasSD1)->D1_DTDIGIT) .And. nOrdem == 3 .Or. (dDataAnt != (cAliasSD1)->D1_EMISSAO) .And. nOrdem == 4 
							lDescLine := .T.
							oReport:SkipLine()
							nLin := oReport:Row()
							oReport:PrintText(STR0046,nLin)	//"TOTAL NA DATA : "
							oReport:PrintText(TransForm(nTotData,Pesqpict("SD1","D1_TOTAL")),nLin,oSection1:Cell('nTotNF1'):ColPos()-35)
							oReport:SkipLine()
							oReport:FatLine()
							oReport:SkipLine()
					       nTotData := 0
						Endif
					EndIf	
              EndIf
           EndIf

			If ((cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA <> cDocAnt)
				nValIpi     := 0
				nValMerc    := 0
				nValDesc    := 0
				nTotDesp    := 0
				nTotFrete   := 0
				nTotSeguro  := 0
				nValIcm     := 0
				nValImpInc	:= 0
				nValImpNoInc:= 0
				nImpInc		:= 0
				nImpNoInc	:= 0
				If nOrdem <> 3 .Or. nOrdem <> 4 .Or. nOrdem <> 5
					lDescLine  := .T.
				EndIf
			EndIf

			cDocAnt := (cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA

		EndIf

	Elseif nOrdem == 2 .AND. !lPlanTab 
		
		If cCodant != (cAliasSD1)->D1_COD .And. lPrintLine
			lDescLine := .T.
			nLin := oReport:Row()
			oReport:PrintText(STR0041)	//"TOTAL DO PRODUTO : "
		   	oReport:PrintText(TransForm(nTotQuant,Pesqpict("SD1","D1_QUANT",15)),nLin,oSection2:Cell('D1_QUANT'):ColPos()-53)	
			oReport:PrintText(TransForm(nTotProd,Pesqpict("SD1","D1_TOTAL")),nLin,oSection2:Cell('nVtotal'):ColPos()-73)	

			// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
			If nTpImp == 6
				If oReport:Row() > (nPageWidth-500)
					oSection3:SetPageBreak(.T.)
				Else
					oSection3:SetPageBreak(.F.)
				EndIf
			EndIf

			oSection3:Init() 
			If ( cPaisLoc == "BRA" )
				oSection3:Cell("nValIcm"):SetValue(nValIcm)
				oSection3:Cell("nValIpi"):SetValue(nValIpi)	
				oSection3:Cell("nTotImp"):SetValue(nValMerc + nTotDesp + nTotFrete + nTotSeguro)					
				
				nTgerIcm += nValIcm
				nTgerIpi += nValIpi
			Else
				oSection3:Cell("nValImpNoInc"):SetValue(nImpNoInc)
				oSection3:Cell("nValImpInc"):SetValue(nImpInc)						
				oSection3:Cell("nTotImp"):SetValue(nValMerc + nTotDesp + nTotFrete + nTotSeguro)					
				
				nTgImpInc   += nImpInc
				nTgImpNoInc += nImpNoInc
			EndIf
			nTotGerImp += nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )

			oSection3:PrintLine()
			oReport:FatLine()
			
            oSection1:Finish() 
            oSection2:Finish() 
            oSection3:Finish() 
		 	
			nTotQger   += nTotQuant
			nTotGeral  += nTotProd
			nValIpi     := 0
			nValMerc    := 0
			nValDesc    := 0
			nTotDesp    := 0
			nTotFrete   := 0
			nTotSeguro  := 0
			nValIcm     := 0
			nValImpInc	:= 0
			nValImpNoInc:= 0
			nImpInc		:= 0
			nImpNoInc	:= 0
	        lPrintLine := .F.
		Endif
		
	Elseif nOrdem == 3 .Or. nOrdem == 4 
		
		If dDataAnt != Iif(nOrdem == 3,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_EMISSAO) .And. lPrintLine // nTotData > 0 
			lDescLine := .T.
			oReport:SkipLine()
			nLin := oReport:Row()
			oReport:PrintText(STR0046,nLin)	//"TOTAL NA DATA : "
			oReport:PrintText(TransForm(nTotData,Pesqpict("SD1","D1_TOTAL")),nLin,oSection2:Cell('nVtotal'):ColPos()-80)				
			oReport:SkipLine()

			// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
			If nTpImp == 6
				If oReport:Row() > (nPageWidth-500)
					oSection3:SetPageBreak(.T.)
				Else
					oSection3:SetPageBreak(.F.)
				EndIf
			EndIf

			oSection3:Init() 
			If ( cPaisLoc == "BRA" )
				oSection3:Cell("nValIcm"):SetValue(nValIcm)
				oSection3:Cell("nValIpi"):SetValue(nValIpi)	
				oSection3:Cell("nTotImp"):SetValue(nValMerc + nTotDesp + nTotFrete + nTotSeguro)					
				
				nTgerIcm += nValIcm
				nTgerIpi += nValIpi
			Else
				oSection3:Cell("nValImpNoInc"):SetValue(nImpNoInc)
				oSection3:Cell("nValImpInc"):SetValue(nImpInc)						
				oSection3:Cell("nTotImp"):SetValue(nValMerc + nTotDesp + nTotFrete + nTotSeguro)									
				
				nTgImpInc   += nImpInc
				nTgImpNoInc += nImpNoInc
			EndIf
			nTotGerImp += nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )

			oSection3:PrintLine()
			oReport:FatLine()
			oReport:SkipLine()
			
            oSection1:Finish() 
            oSection2:Finish() 
            oSection3:Finish() 			
			
			nTotGeral += nTotData
			dDataAnt := Iif(nOrdem == 3,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_EMISSAO)
			nTotData := 0
			nValIpi     := 0
			nValMerc    := 0
			nValDesc    := 0
			nTotDesp    := 0
			nTotFrete   := 0
			nTotSeguro  := 0
			nValIcm     := 0
			nValImpInc	:= 0
			nValImpNoInc:= 0
			nImpInc		:= 0
			nImpNoInc	:= 0
            lPrintLine := .F.
		Endif

	Elseif nOrdem == 5 
		
		If cFornAnt != (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA .And. lPrintLine // nTotForn > 0 
			lDescLine := .T.
			oReport:SkipLine()
			nLin := oReport:Row()
			oReport:PrintText(STR0065,nLin)	//"TOTAL DO FORNECEDOR :"
			oReport:PrintText(TransForm(nTotForn,Pesqpict("SD1","D1_TOTAL")),nLin,oSection2:Cell('nVtotal'):ColPos()-30)											
			oReport:SkipLine()

			// Para impressao em PDF inicia nova pagina antes de chegar ao fim de cada pagina para que as ultimas linhas nao fiquem cortadas
			If nTpImp == 6
				If oReport:Row() > (nPageWidth-500)
					oSection3:SetPageBreak(.T.)
				Else
					oSection3:SetPageBreak(.F.)
				EndIf
			EndIf

			oSection3:Init() 
			If ( cPaisLoc == "BRA" )
				oSection3:Cell("nValIcm"):SetValue(nValIcm)
				oSection3:Cell("nValIpi"):SetValue(nValIpi)	
				oSection3:Cell("nTotImp"):SetValue(nValMerc + nTotDesp + nTotFrete + nTotSeguro)									
				nTgerIcm += nValIcm
				nTgerIpi += nValIpi
			Else
				oSection3:Cell("nValImpNoInc"):SetValue(nImpNoInc)
				oSection3:Cell("nValImpInc"):SetValue(nImpInc)						
				oSection3:Cell("nTotImp"):SetValue(nValMerc + nTotDesp + nTotFrete + nTotSeguro)													
				nTgImpInc   += nImpInc
				nTgImpNoInc += nImpNoInc
			EndIf
			nTotGerImp += nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
			
			oSection3:PrintLine()
			oReport:FatLine()
			
            oSection1:Finish() 
            oSection2:Finish() 
            oSection3:Finish() 						
			
			nTotGeral += nTotForn
			cFornAnt := (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA
			nTotForn := 0
			nValIpi     := 0
			nValMerc    := 0
			nValDesc    := 0
			nTotDesp    := 0
			nTotFrete   := 0
			nTotSeguro  := 0
			nValIcm     := 0
			nValImpInc	:= 0
 			nValImpNoInc:= 0
			nImpInc		:= 0
			nImpNoInc	:= 0
	  		lPrintLine := .F.
		Endif
		
	Endif
	
	If !lquery
		(cAliasSF1)->(dbseek( xFilial("SF1") + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA)) //posiciona o cabecalho da nota
	Endif
	
	nTaxa  := (cAliasSF1)->F1_TXMOEDA
	nMoeda := (cAliasSF1)->F1_MOEDA
	dDtDig := (cAliasSF1)->F1_DTDIGIT
	
EndDo
oSection1:Finish()
If lImp	
	If nOrdem == 1 .And. MV_PAR05 == 1
		If (nTgerIcm + nTgerIpi + nTotGeral + nTgImpInc + nTgImpNoInc) > 0
			oReport:FatLine()			
			oReport:PrintText(STR0042+"    "+STR0022+TransForm(nTgerIcm,tm(nTGerIcm,15))+"    "+STR0023+TransForm(nTGerIpi,tm(nTGerIpi,15))+"    "+STR0024+TransForm(nTotDesco,tm(nTotDesco,13,nDecs))+"    "+STR0025+TransForm(nTotGeral,tm(nTotGeral,17,nDecs)))	
		Endif
	ElseIf (nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5) .And. MV_PAR05 == 2
		If (cPaisLoc == "BRA")
			oReport:SkipLine()
			nLin := oReport:Row()
			oReport:PrintText(STR0042,nLin)	
			oReport:PrintText(TransForm(nTgerIcm,tm(nTGerIcm,14)),nLin,oSection1:Cell('nValIcm1'):ColPos()-20)	
			oReport:PrintText(TransForm(nTgerIpi,tm(nTgerIpi,14)),nLin,oSection1:Cell('nValIpi1'):ColPos()-25)	
			oReport:PrintText(TransForm(nTotGeral,PesqPict("SF1","F1_VALMERC",17)),nLin,oSection1:Cell('nTotNF1'):ColPos()-25)	
		Else
			nLin := oReport:Row()
			oReport:PrintText(STR0042,nLin)	
			oReport:PrintText(TransForm(nTgImpInc+nTgImpNoInc,Pesqpict("SF1","F1_VALIMP1",16)),nLin,oSection1:Cell('nImpInc1'):ColPos()-36)	
			oReport:PrintText(TransForm(nTotGeral,PesqPict("SF1","F1_VALMERC",17)),nLin,oSection1:Cell('nTotNF1'):ColPos()-36)				
		Endif
		oReport:SkipLine()
	ElseIf nOrdem == 2 .AND. !lPlanTab 
		oReport:FatLine()
		nLin := oReport:Row()
		oReport:PrintText(STR0042)	
		oReport:PrintText(TransForm(nTotQger,pesqpict("SD1","D1_QUANT",15)),nLin,oSection2:Cell('D1_QUANT'):ColPos()-85)	
		oReport:PrintText(TransForm(nTotGeral,PesqPict("SF1","F1_VALMERC",17)),nLin,oSection2:Cell('nVtotal'):ColPos()-75)				
	ElseIf (nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5) .And. MV_PAR05 == 1
		oReport:SkipLine()
		nLin := oReport:Row()
		oReport:PrintText(STR0042,nLin)	
		oReport:PrintText(TransForm(nTotGeral,PesqPict("SF1","F1_VALMERC",17)),nLin,oSection2:Cell('nVtotal'):ColPos()-IIF(nOrdem==5,30,80))				
		oReport:SkipLine()
	Endif	
	
	If nOrdem == 2 .Or. ( (nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem ==5) .And. MV_PAR05 == 1)
		//================================
		//?Linha de total adicional p/ a quebra, com totais de Impostos ?
		//================================
		If (nTgerIcm + nTgerIpi + nTotGerImp + nTgImpInc + nTgImpNoInc) > 0
			oReport:SkipLine()
			oReport:PrintText(STR0015+TransForm(nTgerIcm,tm(nTGerIcm,15))+"     "+STR0016+TransForm(nTgerIpi,tm(nTGerIpi,15))+"     "+STR0066+TransForm(nTotGerImp,tm(nTotGerImp,17,nDecs)))	
		Endif
    EndIf
    If mv_par05 == 2 .And. nOrdem == 1
	    oSection1:Finish()
    Endif
Endif	

Return NIL

/*
===============================================================================================================================
Programa----------: RCOM013R
Autor-------------: Josué Danich Prestes
Data da Criacao---: 21/03/2018
===============================================================================================================================
Descrição---------: Chamada R3 do relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
/*/
USER Function RCOM013R()

LOCAL titulo     := STR0001	//"Relacao de Notas Fiscais" 
LOCAL cDesc1     := STR0002	//"Emissa da Relacao de Notas de Compras"
LOCAL cDesc2     := STR0003	//"A opcao de filtragem deste relatoio s??vaida na opcao que lista os"
LOCAL cDesc3     := STR0004	//"itens. Os parraetros funcionam normalmente em qualquer opcao."
LOCAL cString    := "SD1"
LOCAL wnrel      := "MATR080"
LOCAL nomeprog   := "MATR080"
LOCAL lRet		 := .T.

PRIVATE Tamanho  := "M"
PRIVATE limite   := 132
PRIVATE aOrdem   := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0043),OemToAnsi(STR0059),OemToAnsi(STR0062)}		//" Por Nota           "###" Por Produto        "###" Por Data Digitacao "###" Por Data Emissao "###" Por Fornecedor "
PRIVATE cPerg    := "MTR080"
PRIVATE aReturn  := {OemToAnsi(STR0007), 1,OemToAnsi(STR0008), 2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE lEnd     := .F.
PRIVATE m_pag    := 1
PRIVATE li       := 80
PRIVATE nLastKey := 0

//================================
//?Verifica as perguntas selecionadas                           ?
//================================
Pergunte("MTR080",.F.)
//================================
//?Variaveis utilizadas para parametros                         ?
//?mv_par01 // Produto de                                       ?
//?mv_par02 // Produto ate                                      ?
//?mv_par03 // Data de                                          ?
//?mv_par04 // Data ate                                         ?
//?mv_par05 // Lista os itens da nota                           ?
//?mv_par06 // Grupo de                                         ?
//?mv_par07 // Grupo ate                                        ?
//?mv_par08 // Fornecedor de                                    ?
//?mv_par09 // Fornecedor ate                                   ?
//?mv_par10 // Almoxarifado de                                  ?
//?mv_par11 // Almoxarifado ate                                 ?
//?mv_par12 // De  Nota                                         ?
//?mv_par13 // Ate Nota                                         ?
//?mv_par14 // De  Serie                                        ?
//?mv_par15 // Ate Serie                                        ?
//?mv_par16 // Do  Tes                                          ?
//?mv_par17 // Ate Tes                                          ?
//?mv_par18 // Moeda                                            ?
//?mv_par19 // Otras moedas                                     ?
//?mv_par20 // Imprime Total                                    ?
//?mv_par21 // Descricao do produto                             ?
//================================
//================================
//?Envia controle para a funcao SETPRINT                        ?
//================================
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrdem,,Tamanho)

lRet := ! ( nLastKey == 27 )
If lRet
	SetDefault(aReturn,cString)
	lRet := ! ( nLastKey == 27 )
Endif
If lRet
	RptStatus({|lEnd| C080Imp(@lEnd,wnrel,cString,nomeprog,Titulo)},Titulo)
Else
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
EndIf	

Return(lRet)


/*
======================================?
======================================?
======================================?
==un=o    ?C080IMP  ?Autor ?Alex Lemes            ?Data ?0/05/2002=? 
======================================?
==escri=o ?Chamada do Relatorio                                       =?
======================================?
==intaxe   ?C080Imp(ExpL1,ExpC1,ExpC2,ExpC3,ExpC4)					  =?
======================================?
==arametros?ExpL1 = controle para interrupcao pelo usuario		      =?
=?         ?ExpC1 = nome do relatorio	                              =?
=?         ?ExpC2 = Alias do arquivo principal     		              =?
=?         ?ExpC3 = nome do programa 			                      =?
=?         ?ExpC4 = titulo do relatorio           		              =?
======================================?
==etorno   ?.T.                                                        =?
======================================?
=?Uso      ?MATR080			                                          =?
======================================?
======================================?
======================================?
*/
Static Function C080Imp(lEnd,wnrel,cString,nomeprog,Titulo)

LOCAL cCabec      := ""
LOCAL cabec1      := ""
LOCAL cabec2      := ""
LOCAL cQuery	  := ""
LOCAL cDocAnt     := ""
LOCAL cCodAnt     := ""
LOCAL cbText      := ""
LOCAL cQryAd      := ""     
LOCAL cName       := ""
LOCAL cAliasSF1   := "SF1"
LOCAL cAliasSD1   := "SD1"
LOCAL cAliasSB1   := "SB1"
LOCAL cAliasSA1   := "SA1"
LOCAL cAliasSA2   := "SA2"
LOCAL cAliasSF4   := "SF4"
LOCAL cIndex 	  := CriaTrab("",.F.)
LOCAL cForCli     := ""
LOCAL cMuni       := ""
LOCAL cFornF1     := ""
LOCAL cLojaF1     := ""
LOCAL cDocF1      := ""
LOCAL cSerieF1    := ""
LOCAL cCondF1     := ""
LOCAL cTipoF1     := ""
LOCAL cDescri     := ""
LOCAL cFornAnt    := ""
LOCAL nMoedaF1    := 0
LOCAL nTxMoedaF1  := 0
LOCAL nFreteF1    := 0
LOCAL nDespesaF1  := 0
LOCAL nSeguroF1   := 0
LOCAL nValTotF1   := 0
LOCAL nValMerc    := 0
LOCAL nValDesc    := 0
LOCAL nValIcm     := 0
LOCAL nValIpi     := 0
LOCAL nValImpInc  := 0
LOCAL nValImpNoInc:= 0
LOCAL nTotGeral   := 0
LOCAL nTotGerImp  := 0
LOCAL nTotDesco   := 0
LOCAL nTotFrete   := 0
LOCAL nTotSeguro  := 0
LOCAL nTotDesp    := 0
LOCAL nTotProd    := 0
LOCAL nTotQger    := 0
LOCAL nTotData    := 0
LOCAL nTotForn    := 0
LOCAL nTotquant   := 0
LOCAL nTGerIcm    := 0
LOCAL nTGerIpi    := 0
LOCAL nTGImpInc   := 0
LOCAL nTGImpNoInc := 0
LOCAL nImpInc     := 0
LOCAL nImpNoInc   := 0
LOCAL nImpos      := 0
LOCAL nPosNome    := 0
LOCAL nTamNome    := 0
LOCAL cbCont      := 0
LOCAL nLinha      := 0
LOCAL nTaxa       := 1
LOCAL nMoeda      := 1
LOCAL nTamDesc    := 28
LOCAL nDecs       := Msdecimais(mv_par18)
LOCAL nOrdem 	  := aReturn[8]
LOCAL lQuery      := .F.
LOCAL lImp	      := .F.
LOCAL lFiltro     := .T.
LOCAL lDescLine   := .T.
LOCAL lPrintLine  := .F.
LOCAL lEasy       := If(GetMV("MV_EASY")=="S",.T.,.F.)
LOCAL aTamSXG     := TamSXG("001")
LOCAL aTamSXG2    := TamSXG("002")
LOCAL aImpostos   := {} 
LOCAL aStrucSF1   := {}
LOCAL aStrucSD1   := {}
LOCAL dDtDig      := dDataBase
LOCAL dDataAnt    := dDataBase
LOCAL dEmissaoF1  := dDataBase
LOCAL dDtDigitF1  := dDataBase
LOCAL aCampos   :={}                     
LOCAL nX       := 0
Local nY       := 0
LOCAL cAlias   := Alias()
LOCAL nIndice  := indexord()
LOCAL nIncCol  := 0

PRIVATE nTipo  	 := IIF(aReturn[4]=1,15,18)

_atcam := SD1->(Dbstruct())

For nX := 1 To Len(_atcam)
	AAdd(aCampos,alltrim(_atcam[nX][1]))    
	DbSkip()
Next nX

DbSelectArea(cAlias)
DbSetOrder(nIndice)

//================================
//?Define o Cabecalho em todas as Ordens do Relatorio           ?
//================================
// Regua 			                      1         2         3         4         5         6         7         8         9        10        11        12        13
//		            	       0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
If nOrdem == 1 .And. mv_par05 == 1
	nPosNome := 92
	nTamNome := 34
	cabec1   := STR0011	//"RELACAO DOS ITENS DAS NOTAS"
	cCabec   := IIF(cPaisLoc == "BRA",STR0012,STR0050)	//"CODIGO DO MATERIAL   D E S C R I C A O             CFO  TE  ICM  IPI  LOCAL             QUANTIDADE   VALOR UNITARIO      VALOR TOTAL"
Elseif nOrdem == 1 .And. mv_par05 == 2
	nPosNome := 35
	nTamNome := 30
	cabec2   := IIF(cPaisLoc == "MEX",STR0079,STR0034)	//"                  EMISSAO   FORNEC "
	If aTamSXG[1]  !=  aTamSXG[3] //"NUMERO     SER   DATA       CODIGO               RAZAO SOCIAL     PRACA           PGTO           ICMS           IPI     VLR. MERCAD." 
		cabec1   := IIF(cPaisLoc == "MEX", STR0077, STR0047)        // 123456789012  123 99/99/9999 12345678901234567890 1234567890123456 123456789012345 XXX 999,999,999.99 999,999,999.99 9,999,999,999.99
	Else                                                       //"NUMERO       SER DATA       CODIGO RAZAO SOCIAL                   PRACA           PGTO          ICMS            IPI     VLR. MERCAD."
		cabec1   := IIF(cPaisLoc == "BRA", STR0033, IIF(cPaisLoc == "MEX",STR0078,STR0053))  // 123456789012 123 99/99/9999 123456 123456789012345678901234567890 123456789012345 XXX 999,999,999.99 999,999,999.99 9,999,999,999.99
	Endif
Elseif nOrdem == 2
	nPosNome := 29
	nTamNome := 30
	cabec1   := STR0036	 //"RELACAO DAS NOTAS FISCAIS DE COMPRAS"
	If aTamSXG[1] != aTamSXG[3]			                     //"NUMERO       EMISSAO  FORNECEDOR           RAZAO SOCIAL     LC CFO    TE   ICMS  IPI TP    QUANTIDADE VALOR UNITARIO    VLR. MERCAD."
		cCabec  := IIF(cPaisLoc == "BRA", STR0048, IIF(cPaisLoc == "MEX",STR0080,STR0054)) // 012345678901 99/99/9999 12345678901234567890 1234567890123456 12 123 123 12345 12345 1  1234567890123 12345678901234  12345678901234
	Else
		cCabec  := IIF(cPaisLoc == "MEX",STR0081,STR0037)	   //"NUMERO       EMISSAO  FORNEC RAZAO SOCIAL                   LC CFO   TE  ICMS  IPI   TP    QUANTIDADE VALOR UNITARIO    VLR. MERCAD."
		// 						  012345678901 99/99/9999 123456 12345679012345678901234567890  12 123 123 12345 12345 1  1234567890123 12345678901234   12345678901234
	Endif
Elseif (nOrdem == 3 .Or. nOrdem == 4) .And. mv_par05 == 1
	nPosNome    := 35
	nTamNome    := 23
	cabec1      := STR0036	 //"RELACAO DAS NOTAS FISCAIS DE COMPRAS"
	If aTamSXG[1] != aTamSXG[3]                             //"NUMERO    PRODUTO         FORNECEDOR         RAZAO SOCIAL  LC CFO    TE   ICMS  IPI TP    QUANTIDADE VALOR UNITARIO     VLR. MERCAD."
		cCabec  := IIF(cPaisLoc == "BRA", STR0049, IIF(cPaisLoc == "MEX",STR0082,STR0055)) // 123456789012 123456789012345 12345678901234567890 12345678901 12 123 001 12345 12345 1  9,999,999,999 99,999,999,999 9999,999,999,999
	Else                         //"NUMERO       PRODUTO        FORNEC RAZAO SOCIAL             LC CFO   TE  ICMS  IPI   TP    QUANTIDADE VALOR UNITARIO    VLR. MERCAD."
		cCabec  := IIF(cPaisLoc == "MEX",STR0083,STR0044)	     // 123456789012 123456789012345 123456 1234567890123456789012345 12 123 001 12345 12345 1  9,999,999,999 99,999,999,999 9999,999,999,999
	Endif
Elseif (nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5) .And. mv_par05 == 2
	nPosNome := 35
	nTamNome := 30
	cabec2   := Iif(nOrdem == 3,STR0058,STR0060)	//"                  DIGITAC   FORNEC "
	If cPaisLoc == "MEX"
		cabec2 := Space(nIncCol)+cabec2
	Endif
	If aTamSXG[1] != aTamSXG[3]   //"NUMERO     SER   DATA       CODIGO               RAZAO SOCIAL     PRACA           PGTO           ICMS           IPI     VLR. MERCAD." 
		cabec1 := IIF(cPaisLoc == "MEX", STR0077, STR0047)         // 123456789012  123 99/99/9999 12345678901234567890 1234567890123456 123456789012345 XXX 999,999,999.99 999,999,999.99 9,999,999,999.99
	Else                                                     //"NUMERO       SER DATA       CODIGO RAZAO SOCIAL                   PRACA           PGTO          ICMS            IPI     VLR. MERCAD." 
		cabec1 := IIF(cPaisLoc == "BRA", STR0033, IIF(cPaisLoc == "MEX",STR0078,STR0053))  // 123456789012 123 99/99/9999 123456 123456789012345678901234567890 123456789012345 XXX 999,999,999.99 999,999,999.99 9,999,999,999.99
	Endif
Elseif nOrdem == 5 .And. mv_par05 == 1
	cabec1 := STR0036	 //"RELACAO DAS NOTAS FISCAIS DE COMPRAS"
	                     //"NUMERO       PRODUTO          EMISSAO       DIGITACAO       LC CFO   TE  ICMS  IPI   TP    QUANTIDADE VALOR UNITARIO    VLR. MERCAD."
	cCabec := IIF(cPaisLoc == "MEX", STR0084, STR0063)	 // 123456789012 123456789012345   1234567890     1234567890      12 123 001 12345 12345 1  9,999,999,999 99,999,999,999 9999,999,999,999
Endif

//================================
//caso nao utilize tamanho min, considera tamanho max e altera  ?
//layout de impressao ref grupo 001                             ?
//================================
If aTamSXG[1] != aTamSXG[3]
	nPosNome += aTamSXG[4]-aTamSXG[3]
	nTamNome -= aTamSXG[4]-aTamSXG[3]
EndIf

If aTamSXG2[1] != aTamSXG2[3]
	nPosNome += aTamSXG2[4]-aTamSXG2[3]
	nTamNome -= aTamSXG2[4]-aTamSXG2[3]
EndIf

//================================
//?Posiciona a Ordem de todos os Arquivos usados no Relatorio   ?
//================================
dbSelectArea("SA1")
dbSetOrder(1)
dbSelectArea("SA2")
dbSetOrder(1)
dbSelectArea("SB1")
dbSetOrder(1)
dbSelectArea("SF4")
dbSetOrder(1)
dbselectarea("SF1")
dbsetorder(1)
dbSelectArea("SD1")
dbSetOrder(1)

//=================
//?Query para SQL                 ?
//=================
aStrucSF1 := SF1->(dbStruct())
aStrucSD1 := SD1->(dbStruct())
cALiasSF1 := "QRYSD1"
cAliasSD1 := "QRYSD1"
cALiasSB1 := IIF(!lEasy,"QRYSD1","SB1")
cALiasSA1 := "QRYSD1"
cALiasSA2 := "QRYSD1"
lQuery :=.T.
  
cQuery := "SELECT "
If nOrdem == 1
     cQuery += "SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_COD,SD1.D1_ITEM,"
ElseIf nOrdem == 2 
     cQuery += "SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,"
ElseIf nOrdem == 3 
     cQuery += "SD1.D1_FILIAL,SD1.D1_DTDIGIT,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,"
ElseIf nOrdem == 4 
     cQuery += "SD1.D1_FILIAL,SD1.D1_EMISSAO,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,"
ElseIf nOrdem == 5 
     cQuery += "SD1.D1_FILIAL,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += " SD1.D1_ITEM,"
Endif    

cQuery += "D1_DTDIGIT,D1_COD,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_VALFRE,D1_DESPESA,D1_SEGURO,D1_PEDIDO,D1_ITEMPC,"      
cQuery += "D1_TES,D1_IPI,D1_PICM,D1_TIPO,D1_CF,D1_GRUPO,D1_LOCAL,D1_ITEM,D1_EMISSAO,D1_VALDESC,D1_ICMSRET,D1_VALICM,D1_VALIPI,D1_TIPODOC,"
For nX := 1 To Len(acampos)
    cQuery +=acampos[nX]+"," 		 		
Next nX
 
//==================================?
// sta rotina foi escrita para adicionar no select os campos         ?
// sados no filtro do usuario quando houver, a rotina acrecenta      ?
//omente os campos que forem adicionados ao filtro testando         ?
//e os mesmo j?existem no select ou se forem definidos novamente   ?
//elo o usuario no filtro, esta rotina acrecenta o minimo possivel  ?
//e campos no select pois pelo fato da tabela SD1 ter muitos campos |
// a query ter UNION ao adicionar todos os campos do SD1 estava     |
//errubando o TOP CONNECT e abortando o sistema.                    |
//==================================?   	
If !Empty(aReturn[7])
   For nX := 1 To SD1->(FCount())
 	   cName := SD1->(FieldName(nX))
 	   If AllTrim( cName ) $ aReturn[7]
          If aStrucSD1[nX,2] <> "M"  
             If !cName $ cQuery .And. !cName $ cQryAd
        		cQryAd += cName +","
          	 Endif 	
          EndIf
       EndIf 			       	
   Next nX
Endif    
     
cQuery += cQryAd		
  
cQuery += "F1_FILIAL,F1_MOEDA,F1_TXMOEDA,F1_DTDIGIT,F1_TIPO,F1_COND,F1_VALICM,F1_VALIPI,F1_VALIMP1,"
cQuery += "F1_FRETE,F1_DESPESA,F1_SEGURO,F1_DESCONT,F1_VALMERC,F1_DOC,F1_SERIE," + Iif(SerieNfId("SF1",3,"F1_SERIE")<>"F1_SERIE","F1_SDOC","")
cQuery += "F1_EMISSAO,F1_FORNECE,F1_LOJA,F1_VALBRUT,"

If !lEasy        
   cQuery += "B1_DESC,B1_GRUPO,"
EndIf

cQuery += "A1_NOME,A1_MUN,SD1.R_E_C_N_O_ SD1RECNO "
cQuery += "FROM "+RetSqlName("SF1")+" SF1 ,"+RetSqlName("SD1")+" SD1 ,"

If !lEasy        	  
     cQuery += RetSqlName("SB1")+" SB1 ,"
EndIf

cQuery += RetSqlName("SA1")+" SA1  "
cQuery += "WHERE "
cQuery += "SF1.F1_FILIAL='"+xFilial("SF1")+"' AND "
cQuery += "NOT ("+IsRemito(3,'SF1.F1_TIPODOC')+ ") AND "
cQuery += "SF1.D_E_L_E_T_ <> '*' AND "
cQuery += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
cQuery += "SD1.D1_DOC = SF1.F1_DOC AND "
cQuery += "SD1.D1_SERIE = SF1.F1_SERIE AND "
cQuery += "SD1.D1_FORNECE = SF1.F1_FORNECE AND "
cQuery += "SD1.D1_LOJA = SF1.F1_LOJA AND "
cQuery += "SD1.D1_TIPO IN ('D','B') AND "
cQuery += "SD1.D1_TIPODOC = SF1.F1_TIPODOC AND "
cQuery += "SD1.D_E_L_E_T_ <> '*' AND "

If !lEasy        	        
   cQuery += "SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
   cQuery += "SB1.B1_COD = SD1.D1_COD AND "
   cQuery += "SB1.D_E_L_E_T_ <> '*' AND "
EndIf
      
cQuery += "SA1.A1_FILIAL ='"+xFilial("SA1")+"' AND "
cQuery += "SA1.A1_COD = SD1.D1_FORNECE AND "
cQuery += "SA1.A1_LOJA = SD1.D1_LOJA AND "
cQuery += "SA1.D_E_L_E_T_ <> '*' AND "
cQuery += "D1_COD >= '"  		    + MV_PAR01	+ "' AND "
cQuery += "D1_COD <= '"  	        + MV_PAR02	+ "' AND "
cQuery += "D1_DTDIGIT >= '" + DTOS(MV_PAR03)	+ "' AND "
cQuery += "D1_DTDIGIT <= '" + DTOS(MV_PAR04)	+ "' AND "
cQuery += "D1_GRUPO >= '"  		+ MV_PAR06	+ "' AND "
cQuery += "D1_GRUPO <= '"  		+ MV_PAR07	+ "' AND "
cQuery += "D1_FORNECE >= '"  		+ MV_PAR08	+ "' AND "
cQuery += "D1_FORNECE <= '"  		+ MV_PAR09	+ "' AND "
cQuery += "D1_LOCAL >= '"  		+ MV_PAR10	+ "' AND "
cQuery += "D1_LOCAL <= '"  		+ MV_PAR11	+ "' AND "
cQuery += "D1_DOC >= '"  	    	+ MV_PAR12	+ "' AND "
cQuery += "D1_DOC <= '"  		    + MV_PAR13	+ "' AND "
cQuery += SerieNfId("SD1",3,"D1_SERIE") + " >= '" + MV_PAR14	+ "' AND "
cQuery += SerieNfId("SD1",3,"D1_SERIE") + " <= '" 	+ MV_PAR15	+ "' AND "
cQuery += "D1_TES >= '"  	        + MV_PAR16	+ "' AND "
cQuery += "D1_TES <= '"  	        + MV_PAR17	+ "' "
cQuery += "UNION "

  cQuery += "SELECT "
  If nOrdem == 1
     cQuery += "SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","") 
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_COD,SD1.D1_ITEM,"
  ElseIf nOrdem == 2 
     cQuery += "SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","") 
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,"
  ElseIf nOrdem == 3 
     cQuery += "SD1.D1_FILIAL,SD1.D1_DTDIGIT,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,"
  ElseIf nOrdem == 4 
     cQuery += "SD1.D1_FILIAL,SD1.D1_EMISSAO,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += "SD1.D1_FORNECE,SD1.D1_LOJA,"
  ElseIf nOrdem == 5 
     cQuery += "SD1.D1_FILIAL,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_DOC,SD1.D1_SERIE," + Iif(SerieNfId("SD1",3,"D1_SERIE")<>"D1_SERIE","SD1.D1_SDOC","")
     cQuery += "SD1.D1_ITEM,"
  Endif    

  cQuery += "D1_DTDIGIT,D1_COD,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_VALFRE,D1_DESPESA,D1_SEGURO,D1_PEDIDO,D1_ITEMPC,"
  cQuery += "D1_TES,D1_IPI,D1_PICM,D1_TIPO,D1_CF,D1_GRUPO,D1_LOCAL,D1_ITEM,D1_EMISSAO,D1_VALDESC,D1_ICMSRET,D1_VALICM,D1_VALIPI,D1_TIPODOC,"
  For nX := 1 To Len(acampos)
      cQuery +=acampos[nX]+"," 		 		
  Next nX
     
  cQuery += cQryAd		      		
  cQuery += "F1_FILIAL,F1_MOEDA,F1_TXMOEDA,F1_DTDIGIT,F1_TIPO,F1_COND,F1_VALICM,F1_VALIPI,F1_VALIMP1,"
  cQuery += "F1_FRETE,F1_DESPESA,F1_SEGURO,F1_DESCONT,F1_VALMERC,F1_DOC,F1_SERIE,"+ Iif(SerieNfId("SF1",3,"F1_SERIE")<>"F1_SERIE","F1_SDOC","")
  cQuery += "F1_EMISSAO,F1_FORNECE,F1_LOJA,F1_VALBRUT,"

  If !lEasy        
     cQuery += "B1_DESC,B1_GRUPO,"
  EndIf

  cQuery += "A2_NOME,A2_MUN,SD1.R_E_C_N_O_ SD1RECNO "
  cQuery += "FROM "+RetSqlName("SF1")+" SF1 ,"+RetSqlName("SD1")+" SD1 ,"

  If !lEasy        	  
     cQuery += RetSqlName("SB1")+" SB1 ,"
  EndIf

  cQuery += RetSqlName("SA2")+" SA2 "
  cQuery += "WHERE "
  cQuery += "SF1.F1_FILIAL='"+xFilial("SF1")+"' AND "
  cQuery += "SF1.D_E_L_E_T_ <> '*' AND "
  cQuery += "NOT ("+IsRemito(3,'SF1.F1_TIPODOC')+ ") AND "
  cQuery += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
  cQuery += "SD1.D1_DOC = SF1.F1_DOC AND "
  cQuery += "SD1.D1_SERIE = SF1.F1_SERIE AND "
  cQuery += "SD1.D1_FORNECE = SF1.F1_FORNECE AND "
  cQuery += "SD1.D1_LOJA = SF1.F1_LOJA AND "
  cQuery += "SD1.D1_TIPO NOT IN ('D','B') AND "                       
  cQuery += "SD1.D1_TIPODOC = SF1.F1_TIPODOC AND "
  cQuery += "SD1.D_E_L_E_T_ <> '*' AND "

   If !lEasy        	        
      cQuery += "SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
      cQuery += "SB1.B1_COD = SD1.D1_COD AND "
      cQuery += "SB1.D_E_L_E_T_ <> '*' AND "
   EndIf
      
  cQuery += "SA2.A2_FILIAL ='"+xFilial("SA2")+"' AND "
  cQuery += "SA2.A2_COD = SD1.D1_FORNECE AND "
  cQuery += "SA2.A2_LOJA = SD1.D1_LOJA AND "
  cQuery += "SA2.D_E_L_E_T_ <> '*' AND "
  cQuery += "D1_COD >= '"  		    + MV_PAR01	+ "' AND "
  cQuery += "D1_COD <= '"  	        + MV_PAR02	+ "' AND "
  cQuery += "D1_DTDIGIT >= '" + DTOS(MV_PAR03)	+ "' AND "
  cQuery += "D1_DTDIGIT <= '" + DTOS(MV_PAR04)	+ "' AND "
  cQuery += "D1_GRUPO >= '"  		+ MV_PAR06	+ "' AND "
  cQuery += "D1_GRUPO <= '"  		+ MV_PAR07	+ "' AND "
  cQuery += "D1_FORNECE >= '"  		+ MV_PAR08	+ "' AND "
  cQuery += "D1_FORNECE <= '"  		+ MV_PAR09	+ "' AND "
  cQuery += "D1_LOCAL >= '"  		+ MV_PAR10	+ "' AND "
  cQuery += "D1_LOCAL <= '"  		+ MV_PAR11	+ "' AND "
  cQuery += "D1_DOC >= '"  	    	+ MV_PAR12	+ "' AND "
  cQuery += "D1_DOC <= '"  		    + MV_PAR13	+ "' AND "
  cQuery += SerieNfId("SD1",3,"D1_SERIE")+ " >= '" + MV_PAR14	+ "' AND "
  cQuery += SerieNfId("SD1",3,"D1_SERIE")+ " <= '" + MV_PAR15	+ "' AND "
  cQuery += "D1_TES >= '" + MV_PAR16	+ "' AND "
  cQuery += "D1_TES <= '" + MV_PAR17	+ "' "

If nOrdem == 1
     cQuery += " ORDER BY 1,2,3,4,5,6,7"		
ElseIf nOrdem == 2 
     cQuery += " ORDER BY 1,2,3,4,5,6"		
ElseIf nOrdem == 3 
     cQuery += " ORDER BY 1,2,3,4,5,6"
ElseIf nOrdem == 4 
     cQuery += " ORDER BY 1,2,3,4,5,6"
ElseIf nOrdem == 5 
     cQuery += " ORDER BY 1,2,3,4,5,6"
Endif
cQuery := ChangeQuery(cQuery)
  
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'QRYSD1', .T., .T.)

      For nX := 1 to Len(aStrucSD1)
         If aStrucSD1[nX,2] != 'C'
            TCSetField('QRYSD1', aStrucSD1[nX,1], aStrucSD1[nX,2],aStrucSD1[nX,3],aStrucSD1[nX,4])
         EndIf	
      Next nX

      For nX := 1 to Len(aStrucSF1)
         If aStrucSF1[nX,2] != 'C'
            TCSetField('QRYSD1', aStrucSF1[nX,1], aStrucSF1[nX,2],aStrucSF1[nX,3],aStrucSF1[nX,4])
         EndIf	
      Next nX

//================================
//?Posiciona o cabecalho da Nota Fiscal                         ?
//================================
If !lQuery
	(cAliasSF1)->(dbseek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
EndIf	
nTaxa  := (cAliasSF1)->F1_TXMOEDA
nMoeda := (cAliasSF1)->F1_MOEDA
dDtDig := (cAliasSF1)->F1_DTDIGIT

//================================
//?Seleciona Area do While e retorna o total Elementos da regua ?
//================================
dbselectArea(cAliasSD1)
SetRegua(SD1->(RecCount()))

cDocAnt := (cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA

While !Eof() .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") 
	
	//================================
	//?Se cancelado pelo usuario                            	     ?
	//================================
	If lEnd
		@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	                                                        
	If IsRemito(1,cAliasSD1+"->D1_TIPODOC")
		dbSkip()
		Loop
	Endif	

	//================================
	//?Executa a validacao dos filtros do usuario           	     ?
	//================================
	lFiltro := IIf((!Empty(aReturn[7]).And.!&(aReturn[7])) .Or.;
	(D1_COD     < mv_par01 .Or. D1_COD     > mv_par02) .Or. ;
	(D1_DTDIGIT < mv_par03 .Or. D1_DTDIGIT > mv_par04) .Or. ;
	(D1_GRUPO   < mv_par06 .Or. D1_GRUPO   > mv_par07) .Or. ;
	(D1_FORNECE < mv_par08 .Or. D1_FORNECE > mv_par09) .Or. ;
	(D1_LOCAL   < mv_par10 .Or. D1_LOCAL   > mv_par11) .Or. ;
	(D1_DOC     < mv_par12 .Or. D1_DOC     > mv_par13) .Or. ;
	(&(SerieNfId("SD1",3,"D1_SERIE"))   < mv_par14 .Or. &(SerieNfId("SD1",3,"D1_SERIE"))   > mv_par15) .Or. ;
	(D1_TES     < mv_par16 .Or. D1_TES     > mv_par17),.F.,.T.)
	
	//================================
	//verifica moeda nao imprimir com moeda diferente da escolhida  ?
	//================================
	if mv_par19 == 2
		if if((cAliasSF1)->F1_MOEDA == 0,1,(cAliasSF1)->F1_MOEDA) != mv_par18
			lFiltro := .F. 
		Endif
	Endif
	
	
	//================================
	//?Despreza Nota Fiscal sem TES de acordo com parametro         ?
	//================================
	If mv_par22 == 2 .And. Empty(D1_TES)
		lFiltro := .F.
	Endif
	
	If lFiltro
		
		If li > 56
			cabec(Titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		Endif
		
		lImp := .T.
		cDescri := ""
		//================================
		//?Verifica o parametro para imprimir a descricao do produto    ?
		//================================
		If Empty(mv_par21)
			mv_par21 := "B1_DESC"
		ElseIf AllTrim(mv_par21) == "B5_CEME" // Impressao da descricao cientifica do Produto.
			dbSelectArea("SB5")
			dbSetOrder(1)
			If dbSeek( xFilial("SB5")+(cAliasSD1)->D1_COD )
				cDescri := Alltrim(B5_CEME)
			EndIf
		ElseIf AllTrim(mv_par21) == "C7_DESCRI" // Impressao da descricao do Produto no pedido de compras.
			dbSelectArea("SC7")
			dbSetOrder(4)
			If dbSeek( xFilial("SC7")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC )
				cDescri := Alltrim(SC7->C7_DESCRI)
			EndIf
		EndIf
		
		//================================
		//?Faz a Quebra da Linha de descricao para todas ordens do Rela.?
		//================================
		If lDescLine == .T.
			
			If nOrdem == 1 .And. mv_par05 == 1
				li++
				@li,000 PSAY STR0026 + (cAliasSD1)->D1_DOC + " " + Alltrim((cAliasSD1)->&(SerieNfId("SD1",3,"D1_SERIE")))	 //" NUMERO : "
				@li,026+nIncCol PSAY STR0027 + Dtoc((cAliasSD1)->D1_EMISSAO)		                     //" EMISSAO: "
				@li,045+nIncCol PSAY STR0028 + Dtoc((cAliasSD1)->D1_DTDIGIT)		                     //" DIG.:    "
				@li,061+nIncCol PSAY STR0029 + (cAliasSD1)->D1_TIPO				                     //" TIPO:    "
				
				If (cAliasSD1)->D1_TIPO $ "BD"
					@li,068+nIncCol PSAY STR0030 + (cAliasSD1)->D1_FORNECE + " " + (cAliasSD1)->D1_LOJA	 //" CLIENTE    : "
					If !lQuery
						(cAliasSA1)->(dbSeek(xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
					Endif
					@li,nPosNome+nIncCol PSAY SUBSTR((cAliasSA1)->A1_NOME,1,nTamNome)
				Else
					@li,068+nIncCol PSAY STR0031 + (cAliasSD1)->D1_FORNECE + " " + (cAliasSD1)->D1_LOJA	 //" FORNECEDOR : "
					If !lQuery
						(cAliasSA2)->(dbSeek(xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
						@li,nPosNome+nIncCol PSAY SUBSTR((cAliasSA2)->A2_NOME,1,nTamNome)
					Else
						@li,nPosNome+nIncCol PSAY SUBSTR((cAliasSA1)->A1_NOME,1,nTamNome)
					Endif
				EndIf
				
				li++
				@li,000 PSAY cCabec
				li++
				
			Elseif nOrdem == 2
				@li,000 PSAY STR0038 + (cAliasSD1)->D1_COD  	//"PRODUTO : "
				@li,042 PSAY STR0039		              		//"DESCRICAO : "
				
				If !lQuery .Or. lEasy
					(cAliasSB1)->(dbSeek(xFilial("SB1") + (cAliasSD1)->D1_COD))
				EndIf
				
				If Empty(cDescri) .Or. AllTrim(mv_par21) == "B1_DESC" // Impressao da descricao generica do Produto.
					cDescri := Alltrim((cAliasSB1)->B1_DESC)
				EndIf
				
				dbSelectArea(cAliasSD1)
				nLinha:= MLCount(cDescri,nTamDesc)
				@ li,055 PSAY MemoLine(cDescri,nTamDesc,1)
				@li ,87 PSAY STR0040			                 //"GRUPO : "
				@li ,96 PSAY (cAliasSB1)->B1_GRUPO				
				For nX := 2 To nLinha
					li++
					If li > 56
						cabec(Titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
					Endif
					@ li,055 PSAY Memoline(cDescri,nTamDesc,nX)
				Next nX
												
				li++
				@li,000 PSAY cCabec
				cCodAnt   := (cAliasSD1)->D1_COD
				nTotProd  := 0
				nTotQuant := 0
				
			Elseif nOrdem == 3 .Or. nOrdem == 4
				If mv_par05 == 1
					@li,000 PSAY IIf(nOrdem == 3,STR0045,STR0061) //"DATA DE DIGITACAO : "  ### "DATA DE EMISSAO : "
					@li,020 PSAY IIf(nOrdem == 3,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_EMISSAO)
					@li+1,0 PSAY cCabec
				Endif
				li++
				dDataAnt := IIf(nOrdem == 3,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_EMISSAO)
			Elseif nOrdem == 5
				If mv_par05 == 1
					@li,000 PSAY STR0064 //"FORNECEDOR :"

					If (cAliasSD1)->D1_TIPO $ "BD"
						If !lquery
							(cAliasSA1)->(dbSeek(xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
						Endif
						@li,020 PSAY (cAliasSD1)->D1_FORNECE+" "+(cAliasSD1)->D1_LOJA+" "+(cAliasSA1)->A1_NOME
					Else
						If !lquery
							(cAliasSA2)->(dbSeek(xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
							@li,020 PSAY (cAliasSD1)->D1_FORNECE+" "+(cAliasSD1)->D1_LOJA+" "+(cAliasSA2)->A2_NOME
						Else
							@li,020 PSAY (cAliasSD1)->D1_FORNECE+" "+(cAliasSD1)->D1_LOJA+" "+(cAliasSA1)->A1_NOME
						Endif
					EndIf
		
					@li+1,0 PSAY cCabec
				Endif
				li++
				cFornAnt := (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA
			Endif
			lDescLine := .F.
		Endif
		
		//================================
		//=osiciona o F4 para todas as ordens quando nao for query TES  ?
		//================================
		(cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
		
		//================================
		//impressao do corpo do relatorio para todas as ordens          ?
		//================================
		If nOrdem == 1 .Or. (nOrdem == 3 .And. mv_par05 == 2) .Or. (nOrdem == 4 .And. mv_par05 == 2) .Or. (nOrdem == 5 .And. mv_par05 == 2)
			
			If mv_par05 == 1
				
				@li,00 PSAY (cAliasSD1)->D1_COD

				If !lQuery .Or. lEasy
					(cAliasSB1)->(dbSeek(xFilial("SB1") + (cAliasSD1)->D1_COD))
				EndIf
				
				If Empty(cDescri) .Or. AllTrim(mv_par21) == "B1_DESC" // Impressao da descricao generica do Produto.
					cDescri := Alltrim((cAliasSB1)->B1_DESC)
				EndIf
				
				If Empty(cDescri) 
					cDescri := Space(28)
				Endif
				
				dbSelectArea(cAliasSD1)
				nLinha:= MLCount(cDescri,nTamDesc)
				@ li,021 PSAY MemoLine(cDescri,nTamDesc,1)
				For nX := 2 To nLinha
					li++
					If li > 56
						cabec(Titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
					Endif
					@ li,021 PSAY Memoline(cDescri,nTamDesc,nX)
				Next nX
				
				If cPaisLoc <> "BRA"
					
					nImpInc	  := 0
					nImpNoInc := 0
					nImpos	  := 0
					
					aImpostos := TesImpInf((cAliasSD1)->D1_TES)
					For nY := 1 to Len(aImpostos)
						cCampImp := (cAliasSD1)+"->" + (aImpostos[nY][2])
						nImpos   := &cCampImp
						nImpos   := xmoeda(nImpos,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
						If ( aImpostos[nY][3] == "1" )
							nImpInc	+= nImpos
						Else
							If aImpostos[nY][3] == "2" 
								nImpinc -= nImpos
							Else
								nImpNoInc += nImpos
							Endif
						EndIf
					Next
					
					@li,051 PSAY (cAliasSD1)->D1_TES
					@li,055 PSAY nImpNoInc   Picture TM(nImpNoInc,9)
					@li,065 PSAY nImpInc     Picture TM(nImpInc,9)
					@li,078 PSAY (cAliasSD1)->D1_LOCAL
					
					nValImpInc	+= nImpInc
					nValImpNoInc+= nImpNoInc
					nValMerc 	:= nValMerc + xmoeda((cAliasSD1)->D1_TOTAL,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
					
					nTgImpInc 	+= nImpInc
					nTgImpNoInc += nImpNoInc
					nTotGeral 	:= nTotGeral + xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
					
					nValMerc    += nImpInc
					nTotGeral   += nImpInc
				Else
					@li,050 PSAY (cAliasSD1)->D1_CF
					@li,056 PSAY (cAliasSD1)->D1_TES
					@li,060 PSAY (cAliasSD1)->D1_PICM    Picture PesqPict("SD1","D1_PICM")
					@li,066 PSAY (cAliasSD1)->D1_IPI     Picture PesqPict("SD1","D1_IPI")
					@li,072 PSAY (cAliasSD1)->D1_LOCAL

                    nValIcm   += (cAliasSD1)->D1_VALICM
                    nValIpi   += (cAliasSD1)->D1_VALIPI						
                    nTgerIcm  += (cAliasSD1)->D1_VALICM
                    nTgerIpi  += (cAliasSD1)->D1_VALIPI

					If (cAliasSF4)->F4_AGREG != "N"
						nValMerc  := nValMerc + (cAliasSD1)->D1_TOTAL + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0)
						nTotGeral := nTotGeral + (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
			            If (cAliasSF4)->F4_AGREG = "I"
				           nValMerc  += (cAliasSD1)->D1_VALICM
				           nTotGeral += (cAliasSD1)->D1_VALICM
                        Endif 
					Else 
						nTotGeral := nTotGeral - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
					Endif
					
					//================================
					//?Soma valor do IPI caso a nota nao seja compl. de IPI    	 ?
					//?e o TES Calcula IPI nao seja "R"                             ?
					//================================
					If (cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
						If (cAliasSD1)->D1_TIPO != "P" .And. (cAliasSF4)->F4_IPI != "R"
							nValMerc  += (cAliasSD1)->D1_VALIPI
							nTotGeral += (cAliasSD1)->D1_VALIPI
						EndIf
					Else
						If (cAliasSD1)->D1_TIPO != "P"
							nValMerc  += (cAliasSD1)->D1_VALIPI
							nTotGeral += (cAliasSD1)->D1_VALIPI
						EndIf
					EndIf
				EndIf
				
				@li,084 PSAY (cAliasSD1)->D1_QUANT		Picture tm((cAliasSD1)->D1_QUANT,14)
				@li,101 PSAY xmoeda((cAliasSD1)->D1_VUNIT,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_VUNIT",14,mv_par18)
				@li,115 PSAY xmoeda((cAliasSD1)->D1_TOTAL,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
				li++
				
				nValDesc  += xmoeda((cAliasSD1)->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				nTotDesco += xmoeda((cAliasSD1)->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				
			ElseIf mv_par05 == 2
				
				If cPaisLoc <> "BRA"
					aImpostos := TesImpInf((cAliasSD1)->D1_TES)
					For nY := 1 to Len(aImpostos)
						cCampImp := (cAliasSD1)+"->" + (aImpostos[nY][2])
						nImpos   := &cCampImp
						nImpos   := xmoeda(nImpos,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
						If ( aImpostos[nY][3] == "1" )
							nImpInc	+= nImpos
						Else
							If aImpostos[nY][3] == "2" 
								nImpInc -= nImpos
							Else
								nImpNoInc += nImpos
							Endif
						EndIf
					Next
					nValMerc := nValMerc + xmoeda(D1_TOTAL - D1_VALDESC,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
				Else

                    nValIcm  += (cAliasSD1)->D1_VALICM
                    nValIpi  += (cAliasSD1)->D1_VALIPI
					
					If (cAliasSF4)->F4_AGREG != "N"
						nValMerc := nValMerc + (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
			            If (cAliasSF4)->F4_AGREG = "I"
				            nValMerc += (cAliasSD1)->D1_VALICM
                        Endif 
					Else	
						nValMerc := nValMerc - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
					Endif
					
					If (cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
						nValMerc += IF((cAliasSF1)->F1_TIPO != "P" .And. (cAliasSF4)->F4_IPI != "R",(cAliasSD1)->D1_VALIPI,0)
					Else
						nValMerc += IF((cAliasSF1)->F1_TIPO != "P",(cAliasSD1)->D1_VALIPI,0)
					EndIf
				EndIf
			Endif
		Else
			li++
			@li,00 PSAY (cAliasSD1)->D1_DOC
			If nOrdem == 2
				@li,13+nIncCol PSAY (cAliasSD1)->D1_EMISSAO
				@li,22+nIncCol PSAY (cAliasSD1)->D1_FORNECE
			Elseif nOrdem == 3 .Or. nOrdem == 4
				@li,13+nIncCol PSAY (cAliasSD1)->D1_COD
				@li,28+nIncCol PSAY (cAliasSD1)->D1_FORNECE
			Elseif nOrdem == 5
				@li,13+nIncCol PSAY (cAliasSD1)->D1_COD
				@li,30+nIncCol PSAY (cAliasSD1)->D1_EMISSAO
				@li,44+nIncCol PSAY (cAliasSD1)->D1_DTDIGIT
			Endif
			
			If nOrdem <> 5			
				If (cAliasSD1)->D1_TIPO $ "BD"
					If !lquery
						(cAliasSA1)->(dbSeek(xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
					Endif
					@li,nPosNome+nIncCol PSAY SUBSTR((cAliasSA1)->A1_NOME,1,nTamNome)
				Else
					If !lquery
					(cAliasSA2)->(dbSeek(xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA))
						@li,nPosNome+nIncCol PSAY SUBSTR((cAliasSA2)->A2_NOME,1,nTamNome)
					Else
						@li,nPosNome+nIncCol PSAY SUBSTR((cAliasSA1)->A1_NOME,1,nTamNome)
					Endif
				EndIf				
			EndIf
			
			@li,060+nIncCol PSAY (cAliasSD1)->D1_LOCAL
			@li,063 PSAY (cAliasSD1)->D1_CF
			@li,069 PSAY (cAliasSD1)->D1_TES
			@li,073 PSAY (cAliasSD1)->D1_PICM	Picture PesqPict("SD1","D1_PICM",5)
			@li,079+nIncCol PSAY (cAliasSD1)->D1_IPI		Picture PesqPict("SD1","D1_IPI",5)
			@li,085+nIncCol PSAY (cAliasSD1)->D1_TIPO
			@li,088+nIncCol PSAY (cAliasSD1)->D1_QUANT	    Picture TM((cAliasSD1)->D1_QUANT,13)
			@li,102+nIncCol PSAY xmoeda((cAliasSD1)->D1_VUNIT,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_VUNIT",14,mv_par18)
			@li,118+nIncCol PSAY xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_TOTAL",14,mv_par18)
			
			If (cAliasSF4)->F4_AGREG != "N"
				nTotProd  += xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				nTotQuant += (cAliasSD1)->D1_QUANT
				nTotData  += xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)
				nTotForn  += xmoeda((cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)
			    If (cAliasSF4)->F4_AGREG = "I"
				    nTotProd  += xmoeda((cAliasSD1)->D1_VALICM,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				    nTotData  += xmoeda((cAliasSD1)->D1_VALICM,nMoeda,mv_par18,,nDecs+1,nTaxa)
				    nTotForn  += xmoeda((cAliasSD1)->D1_VALICM,nMoeda,mv_par18,,nDecs+1,nTaxa)
                Endif 
			Else
				nTotProd  -= xmoeda((cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				nTotData  -= xmoeda((cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)				
				nTotForn  -= xmoeda((cAliasSD1)->D1_VALDESC + IIF(!(cAliasSF4)->F4_INCSOL$"A|N",(cAliasSD1)->D1_ICMSRET,0),nMoeda,mv_par18,,nDecs+1,nTaxa)				
			Endif

			If cPaisLoc <> "BRA" // Inserido BOPS 92436
				aImpostos := TesImpInf((cAliasSD1)->D1_TES)
				For nY := 1 to Len(aImpostos)
					cCampImp := (cAliasSD1)+"->" + (aImpostos[nY][2])
					nImpos   := &cCampImp
					nImpos   := xmoeda(nImpos,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
					If ( aImpostos[nY][3] == "1" )
						nImpInc	+= nImpos
					Else
						If aImpostos[nY][3] == "2" 
							nImpInc -= nImpos
						Else
							nImpNoInc += nImpos
						Endif
					EndIf
				Next
				nValMerc := nValMerc + xmoeda(D1_TOTAL - D1_VALDESC,(cAliasSF1)->F1_MOEDA,mv_par18,(cAliasSF1)->F1_DTDIGIT,nDecs+1,(cAliasSF1)->F1_TXMOEDA)
			Else
                nValIcm  += (cAliasSD1)->D1_VALICM
                nValIpi  += (cAliasSD1)->D1_VALIPI
				
				If (cAliasSF4)->F4_AGREG != "N"
					nValMerc := nValMerc + (cAliasSD1)->D1_TOTAL - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
		            If (cAliasSF4)->F4_AGREG = "I"
			            nValMerc += (cAliasSD1)->D1_VALICM
                    Endif 
				Else	
					nValMerc := nValMerc - (cAliasSD1)->D1_VALDESC + IIF((cAliasSF4)->F4_INCSOL!="A",(cAliasSD1)->D1_ICMSRET,0)
				Endif
					
				If (cAliasSF4)->(dbSeek(xFilial("SF4") + (cAliasSD1)->D1_TES))
					nValMerc += IF((cAliasSF1)->F1_TIPO != "P" .And. (cAliasSF4)->F4_IPI != "R",(cAliasSD1)->D1_VALIPI,0)
				Else
					nValMerc += IF((cAliasSF1)->F1_TIPO != "P",(cAliasSD1)->D1_VALIPI,0)
				EndIf
			EndIf
            lPrintLine:= .T.

		Endif
  		
		nTotFrete += xmoeda((cAliasSD1)->D1_VALFRE,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		nTotSeguro+= xmoeda((cAliasSD1)->D1_SEGURO ,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		nTotDesp  += xmoeda((cAliasSD1)->D1_DESPESA,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
			  		
		cFornF1     := (cAliasSF1)->F1_FORNECE
		cLojaF1     := (cAliasSF1)->F1_LOJA
		cDocF1      := (cAliasSF1)->F1_DOC
		cSerieF1    := PadR(Alltrim((cAliasSF1)->&(SerieNfId("SF1",3,"F1_SERIE"))),TAMSX3("F1_SERIE")[1])
		cTipoF1     := (cAliasSF1)->F1_TIPO
		cCondF1     := (cAliasSF1)->F1_COND
		nMoedaF1    := (cAliasSF1)->F1_MOEDA
		nTxMoedaF1  := (cAliasSF1)->F1_TXMOEDA
		nFreteF1    := (cAliasSF1)->F1_FRETE
		nDespesaF1  := (cAliasSF1)->F1_DESPESA
		nSeguroF1   := (cAliasSF1)->F1_SEGURO
		nValTotF1   := (cAliasSF1)->F1_VALBRUT
		dEmissaoF1  := (cAliasSF1)->F1_EMISSAO
		dDtDigitF1  := (cAliasSF1)->F1_DTDIGIT
		
		If lQuery
			cForCli  := (cAliasSF1)->A1_NOME
			cMuni    := (cAliasSF1)->A1_MUN
		Endif
		 
	Endif
	//================================
	//incrementa a Regua de processamento no salto do registro      ?
	//================================
	dbSelectArea(cAliasSD1)
	dbSkip()
	cbCont++
	IncRegua()
	
	If nOrdem == 1 .Or. (nOrdem == 3 .And. mv_par05 == 2) .Or. (nOrdem == 4 .And. mv_par05 == 2) .Or. (nOrdem == 5 .And. mv_par05 == 2)
		
		If ((cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA <> cDocAnt)
			
			If (nValIcm + nValMerc + nValIpi + nValImpInc + nValImpNoInc) > 0
				
				If mv_par05 == 1
				
					li++
					@li,000 PSAY STR0014 + cCondF1		                 //"COND. PAGTO :"
					@li,029 PSAY IIF(cPaisLoc == "BRA",STR0015,STR0051) //"TOTAL ICM :"
					
					If ( cPaisLoc == "BRA" )
						@li,040 PSAY nValIcm   	Picture tm((cAliasSF1)->F1_VALICM,15)
						@li,056 PSAY STR0016							 //"TOTAL IPI :"
						@li,067 PSAY nValIpi    Picture tm((cAliasSF1)->F1_VALIPI,15)
						
					Else
						@li,045 PSAY nValImpNoInc Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
						@li,061 PSAY STR0056							 //"TOTAL IPI :"   "TOT. I.INC.:"
						@li,077 PSAY nValImpInc Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
					EndIf
					
					li++
					@li,000 PSAY STR0017							    //"FRETE :"
					@li,010 PSAY nTotFrete Picture pesqpict("SF1","F1_FRETE",15,mv_par18)
					@li,029 PSAY STR0018							    //"DESP.:"
					@li,040 PSAY nTotDesp + nTotSeguro Picture pesqpict("SF1","F1_DESPESA",15,mv_par18)
					@li,056 PSAY STR0019							    //"DESC.:"
					@li,067 PSAY nValDesc Picture pesqpict("SF1","F1_DESCONT",15,mv_par18)
					@li,096 PSAY STR0020							    //"TOTAL NOTA   :"
					if mv_par20 == 2
						@li,115 PSAY (nValMerc - nValDesc) + ( nTotDesp + nTotFrete + nTotSeguro ) Picture pesqpict("SF1","F1_VALMERC",17,mv_par18)
						nTotGeral := nTotGeral + ( nTotDesp + nTotFrete + nTotSeguro )
					else
						@li,115 PSAY xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SF1","F1_VALMERC",17,mv_par18)
						nTotGeral := nTotGeral - (nValMerc - nValDesc) + xmoeda( nValTotF1 ,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
					endIf
					
					li++
	  	            @li,000 PSAY __PrtThinLine()

				ElseIf mv_par05 == 2
					
					//================================
					//?Imprime a linha da nota fiscal                               ?
					//================================
					@li,000 PSAY cDocF1
					@li,013+nIncCol PSAY cSerieF1
					@li,017+nIncCol PSAY Iif(nOrdem == 3,dDtDigitF1,dEmissaoF1)
					@li,028+nIncCol PSAY cFornF1
					
					If cTipoF1 $ "BD"
						If !lQuery
							(cAliasSA1)->(dbSeek( xFilial("SA1") + (cAliasSF1)->F1_FORNECE + (cAliasSF1)->F1_LOJA ))
							@li,nPosNome+nIncCol PSAY SubStr((cAliasSA1)->A1_NOME,1,nTamNome)
							@li,066+nIncCol PSAY SubStr((cAliasSA1)->A1_MUN,1,15)
						Else
							@li,nPosNome+nIncCol PSAY SubStr(cForCli,1,nTamNome)
							@li,066+nIncCol PSAY SubStr(cMuni,1,15)
						Endif
					Else
						If !lQuery
							(cAliasSA2)->(dbSeek( xFilial("SA2") + (cAliasSF1)->F1_FORNECE + (cAliasSF1)->F1_LOJA))
							@li,nPosNome+nIncCol PSAY SubStr((cAliasSA2)->A2_NOME,1,nTamNome)
							@li,066+nIncCol PSAY SubStr((cAliasSA2)->A2_MUN,1,15)
						Else
							@li,nPosNome+nIncCol PSAY SubStr(cForCli,1,nTamNome)
							@li,066+nIncCol PSAY SubStr(cMuni,1,15)
						Endif
					EndIf
					@li,082+nIncCol PSAY cCondF1 Picture "!!!"
					If ( cPaisLoc == "BRA" )
						@li,086 PSAY nValIcm    Picture tm((cAliasSF1)->F1_VALICM ,14)
						@li,101 PSAY nValIpi    Picture tm((cAliasSF1)->F1_VALIPI ,14)
						If mv_par20 == 2
							@li,115 PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
						else
					   	@li,115 PSAY xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SF1","F1_VALMERC",17,mv_par18)
					 	endif
						nTgerIcm += nValIcm
						nTgerIpi += nValIpi
					Else
						@li,93+nIncCol PSAY nImpInc+nImpNoInc  Picture pesqpict("SF1","F1_VALIMP1",14,mv_par18)
						If mv_par20 == 2 // total listado
							@li,115+nIncCol PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
						else
							@li,115+nIncCol PSAY xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SF1","F1_VALMERC",17,mv_par18)
						endif
						nTgImpInc   += nImpInc
						nTgImpNoInc += nImpNoInc

					EndIf
					li++
					
					If mv_par20 == 2
						nTotGeral:= nTotGeral + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
						nTotData := nTotData + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
						nTotForn := nTotForn + nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
					Else
						nTotGeral:= nTotGeral + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
						nTotData := nTotData + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
						nTotForn := nTotForn + xmoeda(nValTotF1,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
					EndIf
                    
                    If nOrdem == 5
						If cFornAnt != (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA 
							lDescLine := .T.
							li++
							@li,000  PSAY STR0065	// "TOTAL DO FORNECEDOR :"
							@li,115+nIncCol  PSAY  nTotForn  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
							li++
						    @li,000 PSAY __PrtThinLine()
							li++
							nTotForn := 0
						Endif				
                    Else                                                      
						If (dDataAnt != (cAliasSD1)->D1_DTDIGIT) .And. nOrdem == 3 .Or. (dDataAnt != (cAliasSD1)->D1_EMISSAO) .And. nOrdem == 4 
							lDescLine := .T.
							li++
							@li,000  PSAY STR0046		//"TOTAL NA DATA : "
							@li,115+nIncCol  PSAY  nTotData  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
							li++
			    			@li,000 PSAY __PrtThinLine()
							li++
					        nTotData := 0
						Endif	
                    EndIf
					
				Endif
				
			Endif
			
			cDocAnt := (cAliasSD1)->D1_FILIAL + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA
			
			nValIpi     := 0
			nValMerc    := 0
			nValDesc    := 0
			nTotDesp    := 0
			nTotFrete   := 0
			nTotSeguro  := 0
			nValIcm     := 0
			nValImpInc	:= 0
			nValImpNoInc:= 0
			nImpInc		:= 0
			nImpNoInc	:= 0
			If nOrdem <> 3 .Or. nOrdem <> 4 .Or. nOrdem <> 5
				lDescLine  := .T.
			Endif
		Endif

	Elseif nOrdem == 2
		
		If cCodant != (cAliasSD1)->D1_COD .And. lPrintLine
			lDescLine := .T.
			li++
			@li,000  PSAY  STR0041		//"TOTAL DO PRODUTO : "
			@li,085+nIncCol  PSAY  nTotQuant Picture pesqpict("SD1","D1_TOTAL",16)
			@li,115+nIncCol  PSAY  nTotProd  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18) 
			li++

			@li,027 PSAY IIF(cPaisLoc == "BRA",STR0015,STR0051)	        //"TOTAL ICMS:"
			If ( cPaisLoc == "BRA" )
				@li,040 PSAY nValIcm    Picture tm((cAliasSF1)->F1_VALICM ,15)
				@li,057 PSAY STR0016			                            //"TOTAL IPI :"
				@li,068 PSAY nValIpi    Picture tm((cAliasSF1)->F1_VALIPI ,15)
				@li,084 PSAY STR0066 //"TOTAL C/IMP.:"
				@li,097 PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
				nTgerIcm += nValIcm
				nTgerIpi += nValIpi
			Else
				@li,040 PSAY nImpNoInc Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
				@li,057 PSAY STR0056			                            //"TOTAL INI :" "TOT. I.INC.:"
				@li,069 PSAY nImpInc   Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
				@li,085 PSAY STR0025         								// TOTAL :
				@li,093 PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
				nTgImpInc   += nImpInc
				nTgImpNoInc += nImpNoInc
			EndIf
			nTotGerImp += nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
			li++

		 	@li,000 PSAY __PrtThinLine()
			li++
			nTotQger   += nTotQuant
			nTotGeral  += nTotProd
			nValIpi     := 0
			nValMerc    := 0
			nValDesc    := 0
			nTotDesp    := 0
			nTotFrete   := 0
			nTotSeguro  := 0
			nValIcm     := 0
			nValImpInc	:= 0
			nValImpNoInc:= 0
			nImpInc		:= 0
			nImpNoInc	:= 0
	        lPrintLine := .F.
		Endif
		
	Elseif nOrdem == 3 .Or. nOrdem == 4 
		
		If dDataAnt != Iif(nOrdem == 3,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_EMISSAO) .And. lPrintLine // nTotData > 0 
			lDescLine := .T.
			li++
			@li,000  PSAY STR0046		//"TOTAL NA DATA : "
			@li,115+nIncCol  PSAY  nTotData  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
			li++

			@li,027 PSAY IIF(cPaisLoc == "BRA",STR0015,STR0051)	        //"TOTAL ICMS:"
			If ( cPaisLoc == "BRA" )
				@li,040 PSAY nValIcm    Picture tm((cAliasSF1)->F1_VALICM ,15)
				@li,057 PSAY STR0016			                            //"TOTAL IPI :"
				@li,068 PSAY nValIpi    Picture tm((cAliasSF1)->F1_VALIPI ,15)
				@li,084 PSAY STR0066 //"TOTAL C/IMP.:"
				@li,097 PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
				nTgerIcm += nValIcm
				nTgerIpi += nValIpi
			Else
				@li,040 PSAY nImpNoInc Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
				@li,057 PSAY STR0056			                            //"TOTAL INI :"
				@li,069 PSAY nImpInc   Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
				@li,085 PSAY STR0025         								// TOTAL
				@li,093 PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
				nTgImpInc   += nImpInc
				nTgImpNoInc += nImpNoInc
			EndIf
			nTotGerImp += nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
			li++

		    @li,000 PSAY __PrtThinLine()
			li++
			nTotGeral += nTotData
			dDataAnt := Iif(nOrdem == 3,(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_EMISSAO)
			nTotData := 0
			nValIpi     := 0
			nValMerc    := 0
			nValDesc    := 0
			nTotDesp    := 0
			nTotFrete   := 0
			nTotSeguro  := 0
			nValIcm     := 0
			nValImpInc	:= 0
			nValImpNoInc:= 0
			nImpInc		:= 0
			nImpNoInc	:= 0
            lPrintLine := .F.
		Endif

	Elseif nOrdem == 5 
		
		If cFornAnt != (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA .And. lPrintLine // nTotForn > 0 
			lDescLine := .T.
			li++
			@li,000  PSAY STR0065	// "TOTAL DO FORNECEDOR :"
			@li,115+nIncCol  PSAY  nTotForn  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
			li++

			@li,027 PSAY IIF(cPaisLoc == "BRA",STR0015,STR0051)	        //"TOTAL ICMS:"
			If ( cPaisLoc == "BRA" )
				@li,040 PSAY nValIcm    Picture tm((cAliasSF1)->F1_VALICM ,15)
				@li,057 PSAY STR0016			                            //"TOTAL IPI :"
				@li,068 PSAY nValIpi    Picture tm((cAliasSF1)->F1_VALIPI ,15)
				@li,084 PSAY STR0066 //"TOTAL C/IMP.:"
				@li,097 PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
				nTgerIcm += nValIcm
				nTgerIpi += nValIpi
			Else
				@li,040 PSAY nImpNoInc+nImpNoInc Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
				@li,057 PSAY STR0056			                            //"TOTAL INI :" "TOT. I.INC.:"
				@li,069 PSAY nImpInc   Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
				@li,085 PSAY STR0025         								// TOTAL :
				@li,093 PSAY (nValMerc + nTotDesp + nTotFrete + nTotSeguro) Picture tm((cAliasSF1)->F1_VALMERC,17)
				nTgImpInc   += nImpInc
				nTgImpNoInc += nImpNoInc
			EndIf
			nTotGerImp += nValMerc + ( nTotDesp + nTotFrete + nTotSeguro )
			li++

		    @li,000 PSAY __PrtThinLine()
			li++
			nTotGeral += nTotForn
			cFornAnt := (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA
			nTotForn := 0
			nValIpi     := 0
			nValMerc    := 0
			nValDesc    := 0
			nTotDesp    := 0
			nTotFrete   := 0
			nTotSeguro  := 0
			nValIcm     := 0
			nValImpInc	:= 0
			nValImpNoInc:= 0
			nImpInc		:= 0
			nImpNoInc	:= 0
	  		lPrintLine := .F.
		Endif
		
	Endif
	
	If !lquery
		(cAliasSF1)->(dbseek( xFilial("SF1") + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA)) //posiciona o cabecalho da nota
	Endif
	
	nTaxa  := (cAliasSF1)->F1_TXMOEDA
	nMoeda := (cAliasSF1)->F1_MOEDA
	dDtDig := (cAliasSF1)->F1_DTDIGIT
	
EndDo

If lImp
	li++
	
	If li > 56
		cabec(Titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
	Endif
	
	@li,000  PSAY STR0042	                                                 //"T O T A L  G E R A L : "
	
	If nOrdem == 1 .And. MV_PAR05 == 1
		If (nTgerIcm + nTgerIpi + nTotGeral + nTgImpInc + nTgImpNoInc) > 0
			@li,027 PSAY IIF(cPaisLoc == "BRA",STR0022,STR0052)	        //"ICMS :"
			If ( cPaisLoc=="BRA" )
				@li,036 PSAY nTgerIcm		Picture tm(nTGerIcm,15)
				@li,052 PSAY STR0023			                            //"IPI :"
				@li,063 PSAY nTgerIpi		Picture tm(nTGerIpi,15)				
			Else
				@li,036 PSAY nTgImpNoInc Picture tm(nTGImpNoInc,15,nDecs)
				@li,052 PSAY STR0057			                            //"IPI :"
				@li,063 PSAY nTgImpInc Picture tm(nTGImpInc,15,nDecs)				
			EndIf
			@li,080 PSAY STR0024			                               //"DESC.:"
			@li,088 PSAY nTotDesco Picture tm(nTotDesco,13,nDecs)
			@li,105 PSAY STR0025			                               //"TOTAL :"
		Endif
		nIncCol := 0
	ElseIf (nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5) .And. MV_PAR05 == 2
		If (cPaisLoc == "BRA")
			@li,086 PSAY nTgerIcm  Picture tm(nTGerIcm,14)
			@li,101 PSAY nTgerIpi  Picture tm(nTGerIpi,14)
		Else
			@li,93+nIncCol PSAY nTgImpInc+nTgImpNoInc  Picture tm(nTGImpInc,14,nDecs)
		Endif
	ElseIf nOrdem == 2
		@li,087+nIncCol  PSAY  nTotQger  Picture pesqpict("SD1","D1_QUANT",15)
	Endif
	
	@li,115+nIncCol PSAY nTotGeral Picture tm(nTotGeral,17,nDecs)

	If nOrdem == 2 .Or. ( (nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem ==5) .And. MV_PAR05 == 1)
		//================================
		//?Linha de total adicional p/ a quebra, com totais de Impostos ?
		//================================
		If (nTgerIcm + nTgerIpi + nTotGerImp + nTgImpInc + nTgImpNoInc) > 0
			li++
			@li,027 PSAY IIF(cPaisLoc == "BRA",STR0015,STR0051)	        //"TOTAL ICMS:"
			If ( cPaisLoc=="BRA" )
				@li,040 PSAY nTgerIcm		Picture tm(nTGerIcm,15)
				@li,057 PSAY STR0016			                            //"TOTAL IPI :"
				@li,068 PSAY nTgerIpi		Picture tm(nTGerIpi,15)				
				@li,084 PSAY STR0066 //"TOTAL C/IMP.:"
				@li,097 PSAY nTotGerImp Picture tm(nTotGerImp,17,nDecs)
			Else
				@li,040 PSAY nTgImpNoInc Picture tm(nTGImpNoInc,15,nDecs)
				@li,057 PSAY STR0056			                            //"TOTAL INI :""TOT. I.INC.:"
				@li,069 PSAY nTgImpInc Picture tm(nTGImpInc,15,nDecs)				        
				@li,085 PSAY STR0025         								// TOTAL
				@li,093 PSAY nTotGerImp Picture tm(nTotGerImp,17,nDecs)
			EndIf
		Endif
    EndIf
	
	roda(cbCont,cbText,Tamanho)
Endif

dbSelectArea(cAliasSD1)
dbCloseArea()

dbSelectArea("SD1")
dbClearFilter()
dbSetOrder(1)

RetIndex("SD1")
If File(cIndex+OrdBagExt())
	Ferase(cIndex+OrdBagExt())
Endif

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()
Return(.T.)
