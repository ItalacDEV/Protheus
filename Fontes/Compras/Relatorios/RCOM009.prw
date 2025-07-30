/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 10/06/2019 | Chamado 29593. Ajuste para lobo gara
-------------------------------------------------------------------------------------------------------------------------------
Jonathan      | 17/08/2020 | Chamado 33777. Novas colunas, Código CC, Sugunda unidade de medida e Qtde. Segum
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 09/09/2024 | Chamado 48465. Removendo warning de compilação.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================================================================
Programa----------: RCOM009 
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/09/2014
===============================================================================================================================
Descrição---------: Relatório Relacoes NFs Entrada por Custo
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM009()

Local oReport

oReport:= RCOM009D()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: RCOM009D
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/09/2014
===============================================================================================================================
Descrição---------: Emissao da relacao de Compras
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------: oExpO1: Objeto do relatorio
===============================================================================================================================
*/

Static Function RCOM009D()

Local aOrdem   := {"Fornecedor","Data De Digitacao","Tipo+Grupo+Codigo"," Grupo+Codigo"}
Local lVeiculo := Upper(GetMV("MV_VEICULO")) == "S"
Local nTamCli  := Max(TAMSX3("A1_NOME")[1],TAMSX3("A2_NOME")[1])-15
Local cTitle   := "Conferencia NFs de Entrada"
Local cPictImp := X3Picture("D1_TOTAL")
Local oReport
Local oSection1
Local oSection2
#IFDEF TOP
	Local cAliasSD1 := GetNextAlias()
#ELSE
	Local cAliasSD1 := "SD1"
#ENDIF

//===========================================================
// Variaveis utilizadas para parametros                     |
// mv_par01			Produto De                              |
// mv_par02         Produto Ate                             |
// mv_par03			Grupo Produto De						|
// mv_par04			Grupo Produto Ate						|
// mv_par05         Data Emissao De		                    |
// mv_par06         Data Emissao Ate    		            |
// mv_par07			Data Digitacao De						|
// mv_par08			Data Digitacao Ate						|
// mv_par09         Fornecedor de                           |
// mv_par10         Fornecedor Ate                          |
// mv_par11         Imprime Devolucao Compra ?              |
// mv_par12         Filtra Dt Devolucao ?                   |
// mv_par13         Moeda                                   |
// mv_par14         Outras moedas                           |
// mv_par15         Somente NFE com TES                     |
// mv_par16         Imprime Devolucao Venda  ?              |
// mv_par17       	CFOPs	                                |
// mv_par18       	Centro de Custo De                      |
// mv_par19       	Centro de Custo Ate                     |
// mv_par20       	Natureza De                             |
// mv_par21       	Natureza Ate                            |
// mv_par22       	TES Atualiza estoque ? (Sim/Nao/Ambas)	|
// mv_par23			Campos Novos ? (Sim/Nao)				|
//===========================================================
Pergunte("RCOM009",.T.)

oReport:= TReport():New("RCOM009",cTitle,"RCOM009", {|oReport| RCOM009R(oReport,aOrdem,cAliasSD1)},"Este relatorio ira imprimir a relacao de itens"+" "+"referentes a compras efetuadas.")
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()

oSection1:= TRSection():New(oReport,"Itens de Notas Fiscais",{"SD1","SF1","SD2","SF2","SB1","SA1","SA2","SF4"},aOrdem)
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderPage()
oSection1:SetLineStyle(.F.)
oSection1:SetReadOnly() //NAO RETIRAR

oSection1:SetNoFilter("SA1")
oSection1:SetNoFilter("SA2")
oSection1:SetNoFilter("SF1")
oSection1:SetNoFilter("SF2")
oSection1:SetNoFilter("SD2")
oSection1:SetNoFilter("SF4")
oSection1:SetNoFilter("SD2")
oSection1:SetNoFilter("SB1")

TRCell():New(oSection1,"D1_FORNECE","SD1","For/Cli"	    ,/*Picture*/,TamSX3("D1_FORNECE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"RAZAOSOC"  ,"   ","Rz.Social"	,/*Picture*/,nTamCli-10	,/*lPixel*/,{|| cRazao })
TRCell():New(oSection1,"D1_COD"    ,"SD1",/*Titulo*/	,/*Picture*/,TamSX3("D1_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/,/**/,/**/, /**/, /**/, /**/,.F.)
TRCell():New(oSection1,"B1_DESC"   ,"SB1",/*Titulo*/	,/*Picture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_TP"     ,"SD1","TP"			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_GRUPO"  ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_UM"     ,"SD1","UM"			,/*Picture*/,3,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_QUANT"  ,"SD1","Qtd."		,/*Picture*/,13,/*lPixel*/,/*{|| code-block de impressao }*/)
IF MV_PAR23 == 1
	TRCell():New(oSection1,"D1_SEGUM"  ,"SD1","Seg. UM"		,/*Picture*/,3,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"D1_QTSEGUM","SD1","Qtd. Segum"	,/*Picture*/,13,/*lPixel*/,/*{|| code-block de impressao }*/)
ENDIF
If lVeiculo
	TRCell():New(oSection1,"D1_CODITE" ,"SD1",RetTitle("B1_CODITE"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oSection1,"D1_DOC"    ,"SD1",/*Titulo*/	,/*Picture*/, TamSX3("D1_DOC")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"COD"       ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cCod })  // Célula para controle do código do produto, não será impressa
oSection1:Cell("COD"):Disable()
TRCell():New(oSection1,"D1_TIPO"   ,"SD1","T.Doc"		,/*Picture*/,2,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_DTDIGIT","SD1","Dt.Dig."		,/*Picture*/,9,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_LOCAL"  ,"SD1","Amz"			,/*Picture*/,3,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_TES"    ,"SD1","TES"			,/*Picture*/,4,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_CF"     ,"SD1","CFOP"		,/*Picture*/,TamSX3("D1_CF")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALUNIT"   ,"SD1","Vlr. Unit."	,"@E 999,999,999.99999999",15,/*lPixel*/,{|| nValUnit },"RIGHT",,"RIGHT")
TRCell():New(oSection1,"VALTOTAL"  ,"SD1","Valor"		,"@E 999,999,999.99",13,/*lPixel*/,{|| nValTot  },"RIGHT",,"RIGHT")
TRCell():New(oSection1,"VALCUSTO"  ,"SD1","Custo"		,"@E 999,999,999.99",13,/*lPixel*/,{|| nValCusto },"RIGHT",,"RIGHT")
IF MV_PAR23 == 1
	TRCell():New(oSection1,"D1_CC"	   ,"SD1","CC"		,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)
ENDIF
TRCell():New(oSection1,"DescCC" ,"","Desc CC"			,,17,/*lPixel*/,{|| RCOM009C((cAliasSD1)->D1_CC) })
TRCell():New(oSection1,"CodNat" ,"","Cod. Nat."			,,10/*Tamanho*/,/*lPixel*/,{|| RCOM009N((cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,1) })
TRCell():New(oSection1,"DescNat","","Natureza"			,,25/*Tamanho*/,/*lPixel*/,{|| RCOM009N((cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,2) })

oSection2:= TRSection():New(oSection1,"Itens de Notas Fiscais",{"SD2","SF2","SD1","SF1","SB1","SA1","SA2","SF4"})
oSection2:SetHeaderPage()
oSection2:SetTotalInLine(.F.)
oSection2:SetLineStyle()
oSection2:SetReadOnly() //NAO RETIRAR

oSection2:SetNoFilter("SA1")
oSection2:SetNoFilter("SA2")
oSection2:SetNoFilter("SF1")
oSection2:SetNoFilter("SF2")
oSection2:SetNoFilter("SD2")
oSection2:SetNoFilter("SF4")
oSection2:SetNoFilter("SD1")
oSection2:SetNoFilter("SB1")

TRCell():New(oSection2,"D2_DOC"    ,"SD2",/*Titulo*/,/*Picture*/,6			 ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_COD"    ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B1_DESC"   ,"SB1",/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_QUANT"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| SD2->D2_QUANT * -1 })
TRCell():New(oSection2,"D2_UM"     ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"PRCVEN"    ,"   ","Vlr. Unit."	 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValUnit })

If cPaisloc=="BRA"
	TRCell():New(oSection2,"D2_IPI","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
	TRCell():New(oSection2,"IMPNOINC","   ","Imp.NInc.",cPictImp,/*Tamanho*/,/*lPixel*/,{|| nImpNoInc })
EndIf

TRCell():New(oSection2,"VALTOTAL"  ,"SD2","Valor","@E 999,999,999.99",12,/*lPixel*/,{|| nValTot * -1 })

If cPaisloc=="BRA"
	TRCell():New(oSection2,"D2_PICM","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
Else
	TRCell():New(oSection2,"IMPINC","   ","Imp.Inc.",cPictImp,/*Tamanho*/,/*lPixel*/,{|| nImpInc })
EndIf

TRCell():New(oSection2,"D2_CLIENTE","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"RAZAOSOC"  ,"   ","Rz.Social",/*Picture*/,nTamCli-10 ,/*lPixel*/,{|| cRazao })
TRCell():New(oSection2,"D2_TIPO"   ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_TES"    ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_CF"     ,"SD2",/*Titulo*/,/*Picture*/,TamSX3("D2_CF")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_TP"     ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_GRUPO"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_EMISSAO","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"VALCUSTO"  ,"   ","Custo"	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValCusto * -1 })
TRCell():New(oSection2,"D2_LOCAL"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:Cell("PRCVEN"  	):GetFieldInfo("D2_PRCVEN"	)
oSection2:Cell("VALTOTAL"	):GetFieldInfo("D2_TOTAL"	)
oSection2:Cell("VALCUSTO"	):GetFieldInfo("D2_CUSTO"	)
oSection2:Cell("D2_DOC"		):GetFieldInfo("D1_DOC"		)
oSection2:Cell("D2_CLIENTE"	):GetFieldInfo("D1_FORNECE"	)
oSection2:Cell("D2_TIPO"	):GetFieldInfo("D1_TIPO"	)
oSection2:Cell("D2_TES"		):GetFieldInfo("D1_TES"		)
oSection2:Cell("D2_CF"		):GetFieldInfo("D1_CF"		)
oSection2:Cell("D2_TP"		):GetFieldInfo("D1_TP"		)
oSection2:Cell("D2_GRUPO"	):GetFieldInfo("D1_GRUPO"	)
oSection2:Cell("D2_EMISSAO"	):GetFieldInfo("D1_DTDIGIT"	)

oSection2:Cell("D2_DOC"		):HideHeader()
oSection2:Cell("D2_COD"		):HideHeader()
oSection2:Cell("B1_DESC"	):HideHeader()
oSection2:Cell("D2_QUANT"	):HideHeader()
oSection2:Cell("D2_UM"		):HideHeader()
oSection2:Cell("PRCVEN"		):HideHeader()
If cPaisloc=="BRA"
	oSection2:Cell("D2_IPI"	):HideHeader()
Else
	oSection2:Cell("IMPNOINC"):HideHeader()
EndIf
oSection2:Cell("VALTOTAL"):HideHeader()
If cPaisloc=="BRA"
	oSection2:Cell("D2_PICM"):HideHeader()
Else
	oSection2:Cell("IMPINC"	):HideHeader()
EndIf
oSection2:Cell("D2_CLIENTE"	):HideHeader()
oSection2:Cell("RAZAOSOC"	):HideHeader()
oSection2:Cell("D2_TIPO"	):HideHeader()
oSection2:Cell("D2_TES"		):HideHeader()
oSection2:Cell("D2_CF"		):HideHeader()
oSection2:Cell("D2_TP"		):HideHeader()
oSection2:Cell("D2_GRUPO"	):HideHeader()
oSection2:Cell("D2_EMISSAO"	):HideHeader()
oSection2:Cell("VALCUSTO"	):HideHeader()
oSection2:Cell("D2_LOCAL"	):HideHeader()

Return(oReport)

/*
===============================================================================================================================
Programa----------: RCOM009R
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/09/2014
===============================================================================================================================
Descrição---------: Emissao da relacao de Compras
===============================================================================================================================
Parametros--------: ExpO1: Objeto Report do Relatório
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/

Static Function RCOM009R(oReport,aOrdem,cAliasSD1)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local nOrdem     := oReport:Section(1):GetOrder()
Local aImpostos  := {}
Local aRecno     := {}
Local cCampImp   := ""
Local cTipo1	 := ""
Local cTipo2	 := ""
Local cFilUsrSD1 := ""
Local cCondSD2   := ""
Local cArqTrbSD2 := ""
Local nNewIndSD2 := 0
Local nImpos     := 0
Local nY         := 0
Local nDecs      := Msdecimais(mv_par13) //casas decimais utilizadas na moeda da impressao
Local oBreak
Local oBreak1
Local oBreak2
Local oBreak3
Local lQuery     := .F.
Local lMoeda     := .T.
Local cAtuEst	 := ""
Local lPar15	 := .F.
Local cCFOP		 := ""

#IFDEF TOP
	Local cSelect   := ""
	Local cSelect1  := ""
	Local cOrder    := ""
	Local cWhereSB1 := ""
	Local cWhereSF1 := ""
	Local cWhereSF4 := "%%"
	Local cWhereCF	:= "%%"
	Local cWhereEST := "%%"
	Local cFrom     := "%%"
	Local cAliasSF4 := cAliasSD1
	Local aStrucSD1 := SD1->(dbStruct())
	Local cName		:= ""
	Local nX        := 0
#ELSE
	Local cCondicao := ""
	Local cIndexKey := ""
	Local cAliasSF4 := "SF4"
#ENDIF

PRIVATE cRazao   := ""
PRIVATE lVeiculo := Upper(GetMV("MV_VEICULO")) == "S"
PRIVATE nValUnit := 0
PRIVATE nValTot  := 0
PRIVATE nValCusto:= 0
PRIVATE	nImpInc  :=	0
PRIVATE	nImpNoInc:=	0
PRIVATE cCod	 := ""

//=====================================================
// Adiciona a ordem escolhida ao titulo do relatorio  |
//=====================================================
oReport:SetTitle(oReport:Title() + " ("+AllTrim(aOrdem[nOrdem])+") ")

dbSelectArea("SD1")
//=====================================================
// Filtragem do relatório                             |
//=====================================================

MakeSqlExpr(oReport:uParam)

oReport:Section(1):BeginQuery()

lQuery := .T.

cSelect := "%"
cSelect += ", " + "D1_VALIMP1,D1_VALIMP2,D1_VALIMP3,D1_VALIMP4"

If lVeiculo
	cSelect   += ",B1_CODITE "
	cWhereSB1 := "%"
	cWhereSB1 += " B1_CODITE >= '" + MV_PAR01 + "'"
	cWhereSB1 += " AND B1_CODITE <= '" + MV_PAR02 + "'"
	cWhereSB1 += "%"
Else
	cWhereSB1 := "%"
	cWhereSB1 += " SD1.D1_COD >= '" + MV_PAR01 + "'"
	cWhereSB1 += " AND SD1.D1_COD <= '" + MV_PAR02 + "'"
	cWhereSB1 += " AND SD1.D1_GRUPO >= '" + MV_PAR03 + "'"
	cWhereSB1 += " AND SD1.D1_GRUPO <= '" + MV_PAR04 + "'"
	cWhereSB1 += "%"
Endif

//=====================================================================
// Esta rotina foi escrita para adicionar no select os campos         |
// usados no filtro do usuario quando houver. A rotina acrescenta     |
// somente os campos que forem adicionados ao filtro testando         |
// se os mesmo já existem no select ou se forem definidos novamente   |
// pelo o usuario no filtro. Esta rotina acrescenta o minimo possivel |
// de campos no select pois pelo fato da tabela SD1 ter muitos campos |
// e a query ter UNION, ao adicionar todos os campos do SD1 podera    |
// derrubar o TOP CONNECT e abortar o sistema.                        |
//=====================================================================
cSelect1 := "D1_FILIAL, D1_CC, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_DTDIGIT, D1_COD,   D1_QUANT, D1_VUNIT,"
cSelect1 += "D1_TOTAL,  D1_TES, D1_CF, D1_IPI,   D1_PICM,    D1_TIPO, D1_TP,      D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, D1_ITEM, D1_UM,"
cFilUsrSD1:= oSection1:GetAdvplExp()
If !Empty(cFilUsrSD1)
	For nX := 1 To SD1->(FCount())
		cName := SD1->(FieldName(nX))
		If AllTrim( cName ) $ cFilUsrSD1
			If aStrucSD1[nX,2] <> "M"
				If !cName $ cSelect .And. !cName $ cSelect1
					cSelect += ","+cName
				Endif
			EndIf
		EndIf
	Next
Endif

If mv_par15 == 1
	cSelect += ", F4_AGREG "
	cFrom := "%"
	cFrom += "," + RetSqlName("SF4") + " SF4 "
	cFrom += "%"
	
	cWhereSF4 := "%"
	cWhereSF4 += " SF4.F4_FILIAL ='" + xFilial("SF4") + "'"
	cWhereSF4 += " AND SF4.F4_CODIGO = SD1.D1_TES"
	cWhereSF4 += " AND SF4.D_E_L_E_T_ <> '*' AND "
	cWhereSF4 += "%"
	
	lPar15 := .T.
EndIf

//busca CFOPS de acordo com parametro definido por usuario	
mv_par17 := Alltrim(mv_par17)
If RIGHT(mv_par17,1) == ";"                       
	mv_par17 := SubStr(mv_par17,1,Len(mv_par17)-1) //retira ultimo ';' caso tenha
Endif
If !EMPTY(mv_par17)
	cWhereCF   := "%"
	cWhereCF   += " SD1.D1_CF IN " + FormatIn(mv_par17,";")+" AND "
	cWhereCF   += "%"
Endif


If mv_par22 == 1 .and. lPar15
	cWhereEST := "% SF4.F4_ESTOQUE = 'S' AND %"
Elseif mv_par22 == 2 .and. !lPar15
	cFrom := "%"
	cFrom += "," + RetSqlName("SF4") + " SF4 "
	cFrom += "%"
	
	cWhereEST := "%"
	cWhereEST += " SF4.F4_FILIAL ='" + xFilial("SF4") + "'"
	cWhereEST += " AND SF4.F4_CODIGO = SD1.D1_TES"
	cWhereEST += " AND SF4.F4_ESTOQUE = 'N' "
	cWhereEST += " AND SF4.D_E_L_E_T_ <> '*' AND "
	cWhereEST += "%"
Endif

If (mv_par16 == 1)
	cTipo1 := "D','B"
	cTipo2 := cTipo1
Else
	cTipo1 := "B"
	cTipo2 := "D','B"
EndIf

cSelect += "%"

cWhereSF1 := "%"
cWhereSF1 += "NOT ("+IsRemito(3,'SF1.F1_TIPODOC')+ ") AND "
cWhereSF1 += "%"

If nOrdem == 1
	cOrder := "% D1_FILIAL, D1_FORNECE, D1_LOJA,    D1_DOC,   D1_SERIE,  D1_ITEM %"
ElseIf nOrdem == 2
	cOrder := "% D1_FILIAL, D1_DTDIGIT, D1_FORNECE, D1_LOJA,   D1_DOC,   D1_SERIE, D1_ITEM %"
ElseIf nOrdem == 3 .And. lVeiculo
	cOrder := "% D1_FILIAL, D1_TP,	    D1_GRUPO,   B1_CODITE, D1_DTDIGIT %"
ElseIf nOrdem == 3 .And. !lVeiculo
	cOrder := "% D1_FILIAL, D1_TP,		D1_GRUPO,   D1_COD,    D1_DTDIGIT %"
ElseIf nOrdem == 4 .And. lVeiculo
	cOrder := "% D1_FILIAL, D1_GRUPO,   D1_CODITE,  D1_DTDIGIT %"
ElseIf nOrdem == 4 .And. !lVeiculo
	cOrder := "% D1_FILIAL, D1_GRUPO,   D1_COD,     D1_DTDIGIT %"
EndIf

BeginSql Alias cAliasSD1
	
	SELECT D1_FILIAL, D1_DOC, D1_CC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_DTDIGIT, D1_COD, D1_QUANT, D1_VUNIT,
	D1_TOTAL, D1_TES, D1_CF, D1_IPI, D1_PICM, D1_TIPO, D1_TP, D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, D1_ITEM, D1_UM,
	F1_MOEDA, F1_TXMOEDA, F1_DTDIGIT, B1_DESC, B1_UM, A1_NOME RAZAO, A1_NREDUZ RAZAORED, SD1.R_E_C_N_O_ SD1RECNO,
	B1_CODITE D1_CODITE,  'C' TIPO, D1_SEGUM, D1_QTSEGUM
	%Exp:cSelect%
	
	FROM %table:SF1% SF1 , %table:SD1% SD1 , %table:SB1% SB1 , %table:SA1% SA1 %Exp:cFrom%
	
	WHERE SF1.F1_FILIAL   = %xFilial:SF1%   AND
	%Exp:cWhereSF1%
	SF1.%NotDel%                      AND
	SD1.D1_FILIAL   =  %xFilial:SD1%  AND
	SD1.D1_DOC      =  SF1.F1_DOC     AND
	SD1.D1_SERIE    =  SF1.F1_SERIE   AND
	SD1.D1_FORNECE  =  SF1.F1_FORNECE AND
	SD1.D1_LOJA     =  SF1.F1_LOJA    AND
	SD1.D1_TIPO  IN (%Exp:cTipo1%)    AND
	SD1.%NotDel%                      AND
	SB1.B1_FILIAL   =  %xFilial:SB1%  AND
	SB1.B1_COD      =  SD1.D1_COD     AND
	SB1.%NotDel%                      AND
	SA1.A1_FILIAL   =  %xFilial:SA1%  AND
	SA1.A1_COD      =  SD1.D1_FORNECE AND
	SA1.A1_LOJA     =  SD1.D1_LOJA    AND
	SA1.%NotDel%                      AND	
	%Exp:cWhereSF4%
	SD1.D1_EMISSAO >= %Exp:Dtos(mv_par05)% AND
	SD1.D1_EMISSAO <= %Exp:Dtos(mv_par06)% AND
	SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par07)% AND
	SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par08)% AND	
	%Exp:cWhereEST%
	SD1.D1_FORNECE >= %Exp:mv_par09% AND
	SD1.D1_FORNECE <= %Exp:mv_par10% AND
	%Exp:cWhereCF%	
	SD1.D1_CC 	 >= %Exp:mv_par18% AND  	
	SD1.D1_CC 	 <= %Exp:mv_par19% AND  
	%Exp:cWhereSB1%
	
	UNION
	
	SELECT D1_FILIAL, D1_DOC, D1_CC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_DTDIGIT, D1_COD, D1_QUANT, D1_VUNIT,
	D1_TOTAL, D1_TES, D1_CF, D1_IPI, D1_PICM, D1_TIPO, D1_TP, D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, D1_ITEM, D1_UM,
	F1_MOEDA, F1_TXMOEDA, F1_DTDIGIT, B1_DESC, B1_UM, A2_NOME RAZAO, A2_NREDUZ RAZAORED, SD1.R_E_C_N_O_ SD1RECNO,
	B1_CODITE  D1_CODITE,  'F' TIPO, D1_SEGUM, D1_QTSEGUM
	%Exp:cSelect%
	
	FROM %table:SF1% SF1 , %table:SD1% SD1 , %table:SB1% SB1 , %table:SA2% SA2, %table:SE2% SE2 %Exp:cFrom%
	
	WHERE SF1.F1_FILIAL   = %xFilial:SF1%   AND
	%Exp:cWhereSF1%
	SF1.%NotDel%                      AND
	SD1.D1_FILIAL   =  %xFilial:SD1%  AND
	SD1.D1_DOC      =  SF1.F1_DOC     AND
	SD1.D1_SERIE    =  SF1.F1_SERIE   AND
	SD1.D1_FORNECE  =  SF1.F1_FORNECE AND
	SD1.D1_LOJA     =  SF1.F1_LOJA    AND
	SD1.D1_TIPO NOT IN (%Exp:cTipo2%) AND
	SD1.%NotDel%                      AND
	SB1.B1_FILIAL   =  %xFilial:SB1%  AND
	SB1.B1_COD      =  SD1.D1_COD     AND
	SB1.%NotDel%                      AND
	SA2.A2_FILIAL   =  %xFilial:SA2%  AND
	SA2.A2_COD      =  SD1.D1_FORNECE AND
	SA2.A2_LOJA     =  SD1.D1_LOJA    AND
	SA2.%NotDel%                      AND
	SE2.E2_FILIAL (+)  = SD1.D1_FILIAL  AND
	SE2.E2_NUM    (+)  = SD1.D1_DOC     AND
	SE2.E2_PREFIXO (+) = SD1.D1_SERIE   AND
	SE2.E2_FORNECE (+) = SD1.D1_FORNECE AND
	SE2.E2_LOJA   (+)  = SD1.D1_LOJA    AND
	SE2.D_E_L_E_T_ (+) <> '*'           AND	
	%Exp:cWhereSF4%
	SD1.D1_EMISSAO >= %Exp:Dtos(mv_par05)% AND
	SD1.D1_EMISSAO <= %Exp:Dtos(mv_par06)% AND   
	SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par07)% AND
	SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par08)% AND	
	SD1.D1_FORNECE >= %Exp:mv_par09% AND
	SD1.D1_FORNECE <= %Exp:mv_par10% AND
	%Exp:cWhereEST%
	SD1.D1_CC 	 >= %Exp:mv_par18% AND
	SD1.D1_CC 	 <= %Exp:mv_par19% AND
	%Exp:cWhereCF%
	SE2.E2_NATUREZ (+)  >= %Exp:mv_par20% AND
	SE2.E2_NATUREZ (+) <= %Exp:mv_par21% AND                                                   
	%Exp:cWhereSB1%  
	
	ORDER BY %Exp:cOrder%
	
EndSql

oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)


//====================================================
// Monta IndRegua caso liste NFs de devolucao        |
//====================================================
If mv_par11 == 1
	cArqTrbSD2:= CriaTrab("",.F.)
	//==============================================================
	// Verifica data caso FILTRE NFs de devolucao fora do periodo  |
	//==============================================================
	If mv_par12 == 1
		cCondSD2	:=	( "D2_FILIAL == '" + xFilial("SD2") + "'" )
		cCondSD2	+=	( " .And. DTOS(D2_EMISSAO)>='" + DTOS(mv_par05) + "'" )
		cCondSD2	+=	( " .And. DTOS(D2_EMISSAO)<='" + DTOS(mv_par06) + "'" )
	Else
		cCondSD2	:=	( "D2_FILIAL == '" + xFilial("SD2") + "'")
	EndIf
	cCondSD2 +=	( ".And. !(" + IsRemito(2,'SD2->D2_TIPODOC') + ")" )
	
	dbSelectArea("SD2")
	IndRegua("SD2",cArqTrbSD2,"D2_FILIAL+D2_COD+D2_NFORI+D2_ITEMORI+D2_SERIORI+D2_CLIENTE+D2_LOJA",,cCondSD2,"Selecionando Registros...")
	nNewIndSD2 := RetIndex("SD2")
	dbSelectArea("SD2")
	#IFNDEF TOP
		
		dbSetIndex(cArqTrbSD2+OrdBagExt())
	#ENDIF
	dbSetOrder(nNewIndSD2+1)
	dbGoTop()
EndIf

cFilUsrSD1:= oSection1:GetAdvplExp()

If nOrdem == 1
	
	//==============================================================
	// Definicao das quebras e totalizadores que serao Impressos.  |
	//==============================================================
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("D1_DOC")    ,"TOTAL NOTA FISCAL --> ",.F.,"NFE")
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_FORNECE"),"TOTAL FORNECEDOR  --> ",.F.)
	
	//============================================================================================================================
	// A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML   |
	//============================================================================================================================
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	
	//================================================================
	// Dispara a funcao RCOM009P() para a impressao da oSection2   |
	// apartir do Break NFE abaixo apos a impressao do totalizador.  |
	//================================================================
	oBreak:= oReport:Section(1):GetBreak("NFE")
	oBreak:OnPrintTotal({|| RCOM009P(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })
	
	//================================================================
	// Impressao dos totalizadores SD1 (-) SD2 Devolucoes.           |
	//================================================================
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() , oSection1:GetFunction("SD1QTD2"):ReportValue() + oSection2:GetFunction("SD2QTD2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() , oSection1:GetFunction("SD1NIC2"):ReportValue() + oSection2:GetFunction("SD2NIC2"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() , oSection1:GetFunction("SD1TOT2"):ReportValue() + oSection2:GetFunction("SD2TOT2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() , oSection1:GetFunction("SD1INC2"):ReportValue() + oSection2:GetFunction("SD2INC2"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() , oSection1:GetFunction("SD1CUS2"):ReportValue() + oSection2:GetFunction("SD2CUS2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	
ElseIf nOrdem == 2
	
	//================================================================
	// Definicao das quebras e totalizadores que serao Impressos.    |
	//================================================================
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("D1_DOC")    ,"TOTAL NOTA FISCAL --> ",.F.,"NFE")
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_FORNECE"),"TOTAL FORNECEDOR  --> ",.F.)
	oBreak3 := TRBreak():New(oSection1,oSection1:Cell("D1_DTDIGIT"),"TOT. NA DATA ",.F.)
	
	//===========================================================================================================================
	// A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  |
	//===========================================================================================================================
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	
	//===============================================================
	// Dispara a funcao RCOM009P() para a impressao da oSection2  |
	// apartir do Break NFE abaixo apos a impressao do totalizador. |
	//===============================================================
	oBreak:= oReport:Section(1):GetBreak("NFE")
	oBreak:OnPrintTotal({|| RCOM009P(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })
	
	//===============================================================
	// Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          |
	//===============================================================
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD3"):GetValue() + oSection2:GetFunction("SD2QTD3"):GetValue() , oSection1:GetFunction("SD1QTD3"):ReportValue() + oSection2:GetFunction("SD2QTD3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC3"):GetValue() + oSection2:GetFunction("SD2NIC3"):GetValue() , oSection1:GetFunction("SD1NIC3"):ReportValue() + oSection2:GetFunction("SD2NIC3"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT3"):GetValue() + oSection2:GetFunction("SD2TOT3"):GetValue() , oSection1:GetFunction("SD1TOT3"):ReportValue() + oSection2:GetFunction("SD2TOT3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC3"):GetValue() + oSection2:GetFunction("SD2INC3"):GetValue() , oSection1:GetFunction("SD1INC3"):ReportValue() + oSection2:GetFunction("SD2INC3"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS3"):GetValue() + oSection2:GetFunction("SD2CUS3"):GetValue() , oSection1:GetFunction("SD1CUS3"):ReportValue() + oSection2:GetFunction("SD2CUS3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	
ElseIf nOrdem == 3
	
	//===============================================================
	// Definicao das quebras e totalizadores que serao Impressos.   |
	//===============================================================
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("COD"),"TOTAL PRODUTO     --> ",.F.,"PROD")
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_GRUPO")  ,"TOTAL GRUPO ",.F.)
	oBreak3 := TRBreak():New(oSection1,oSection1:Cell("D1_TP")     ,"TOTAL TIPO  ",.F.)
	
	//==============================================================
	// Dispara a funcao RCOM009P() para a impressao da oSection2 |
	// apartir do Break NFE abaixo apos a impressao do totalizador.|
	//==============================================================
	oBreak:= oReport:Section(1):GetBreak("PROD")
	oBreak:OnBreak({|| RCOM009P(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })
	
	//===============================================================
	// Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          |
	//===============================================================
	//===========================================================================================================================
	// A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  |
	//===========================================================================================================================
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD1"):GetValue() + oSection2:GetFunction("SD2QTD1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC1"):GetValue() + oSection2:GetFunction("SD2NIC1"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT1"):GetValue() + oSection2:GetFunction("SD2TOT1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC1"):GetValue() + oSection2:GetFunction("SD2INC1"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS1"):GetValue() + oSection2:GetFunction("SD2CUS1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD3"):GetValue() + oSection2:GetFunction("SD2QTD3"):GetValue() , oSection1:GetFunction("SD1QTD3"):ReportValue() + oSection2:GetFunction("SD2QTD3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC3"):GetValue() + oSection2:GetFunction("SD2NIC3"):GetValue() , oSection1:GetFunction("SD1NIC3"):ReportValue() + oSection2:GetFunction("SD2NIC3"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT3"):GetValue() + oSection2:GetFunction("SD2TOT3"):GetValue() , oSection1:GetFunction("SD1TOT3"):ReportValue() + oSection2:GetFunction("SD2TOT3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC3"):GetValue() + oSection2:GetFunction("SD2INC3"):GetValue() , oSection1:GetFunction("SD1INC3"):ReportValue() + oSection2:GetFunction("SD2INC3"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS3"):GetValue() + oSection2:GetFunction("SD2CUS3"):GetValue() , oSection1:GetFunction("SD1CUS3"):ReportValue() + oSection2:GetFunction("SD2CUS3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	
ElseIf nOrdem == 4
	
	//==============================================================
	// Definicao das quebras e totalizadores que serao Impressos.  |
	//==============================================================
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("COD"),"TOTAL PRODUTO     --> ",.F.,"PROD")
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_GRUPO")  ,"TOTAL GRUPO ",.F.)
	
	//===============================================================
	// Dispara a funcao RCOM009P() para a impressao da oSection2  |
	// apartir do Break NFE abaixo apos a impressao do totalizador. |
	//===============================================================
	oBreak:= oReport:Section(1):GetBreak("PROD")
	oBreak:OnBreak({|| RCOM009P(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })
	
	//===============================================================
	// Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          |
	//===============================================================
	//===========================================================================================================================
	// A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  |
	//===========================================================================================================================
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD1"):GetValue() + oSection2:GetFunction("SD2QTD1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1NIC1"):GetValue() + oSection2:GetFunction("SD2NIC1"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT1"):GetValue() + oSection2:GetFunction("SD2TOT1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1INC1"):GetValue() + oSection2:GetFunction("SD2INC1"):GetValue() },.F.,.F.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS1"):GetValue() + oSection2:GetFunction("SD2CUS1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() , oSection1:GetFunction("SD1QTD2"):ReportValue() + oSection2:GetFunction("SD2QTD2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1NIC2"):GetValue() + oSection2:GetFunction("SD2NIC2"):GetValue() , oSection1:GetFunction("SD1NIC2"):ReportValue() + oSection2:GetFunction("SD2NIC2"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() , oSection1:GetFunction("SD1TOT2"):ReportValue() + oSection2:GetFunction("SD2TOT2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPINC")  ,NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1INC2"):GetValue() + oSection2:GetFunction("SD2INC2"):GetValue() , oSection1:GetFunction("SD1INC2"):ReportValue() + oSection2:GetFunction("SD2INC2"):ReportValue() ) },.F.,.T.)
	EndIf
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() , oSection1:GetFunction("SD1CUS2"):ReportValue() + oSection2:GetFunction("SD2CUS2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	
EndIf

//==============================================================
// Os TRFunctions abaixo nao sao impressos, servem apenas para |
// acumular os valores das oSection1 e oSection2 para serem    |
// utilizados na impressao do totalizador geral da oSection1   |
// acima ONPRINT que subtrai as devolucoes SD1 - SD2.          |
//==============================================================
If nOrdem == 3 .Or. nOrdem == 4
	
	TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	oSection1:GetFunction("SD1QTD1"):Disable()
	oSection1:GetFunction("SD1TOT1"):Disable()
	oSection1:GetFunction("SD1CUS1"):Disable()
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),"SD1NIC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection1:Cell("IMPINC")  ,"SD1INC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		oSection1:GetFunction("SD1NIC1"):Disable()
		oSection1:GetFunction("SD1INC1"):Disable()
	EndIf
	
	TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	oSection2:GetFunction("SD2QTD1"):Disable()
	oSection2:GetFunction("SD2TOT1"):Disable()
	oSection2:GetFunction("SD2CUS1"):Disable()
	If cPaisloc <> "BRA"
		TRFunction():New(oSection2:Cell("IMPNOINC"),"SD2NIC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection2:Cell("IMPINC")  ,"SD2INC1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		oSection2:GetFunction("SD2NIC1"):Disable()
		oSection2:GetFunction("SD2INC1"):Disable()
	EndIf
	
EndIf

TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
oSection1:GetFunction("SD1QTD2"):Disable()
oSection1:GetFunction("SD1TOT2"):Disable()
oSection1:GetFunction("SD1CUS2"):Disable()
If cPaisloc <> "BRA"
	TRFunction():New(oSection1:Cell("IMPNOINC"),"SD1NIC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("IMPINC")  ,"SD1INC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	oSection1:GetFunction("SD1NIC2"):Disable()
	oSection1:GetFunction("SD1INC2"):Disable()
EndIf

TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
oSection2:GetFunction("SD2QTD2"):Disable()                                                                                 
oSection2:GetFunction("SD2TOT2"):Disable()
oSection2:GetFunction("SD2CUS2"):Disable()
If cPaisloc <> "BRA"
	TRFunction():New(oSection2:Cell("IMPNOINC"),"SD2NIC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection2:Cell("IMPINC")  ,"SD2INC2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	oSection2:GetFunction("SD2NIC2"):Disable()
	oSection2:GetFunction("SD2INC2"):Disable()
EndIf

If nOrdem == 2 .Or. nOrdem == 3
	
	TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	oSection1:GetFunction("SD1QTD3"):Disable()
	oSection1:GetFunction("SD1TOT3"):Disable()
	oSection1:GetFunction("SD1CUS3"):Disable()
	If cPaisloc <> "BRA"
		TRFunction():New(oSection1:Cell("IMPNOINC"),"SD1NIC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection1:Cell("IMPINC")  ,"SD1INC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		oSection1:GetFunction("SD1NIC3"):Disable()
		oSection1:GetFunction("SD1INC3"):Disable()
	EndIf
	
	TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par15 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
	oSection2:GetFunction("SD2QTD3"):Disable()
	oSection2:GetFunction("SD2TOT3"):Disable()
	oSection2:GetFunction("SD2CUS3"):Disable()
	If cPaisloc <> "BRA"
		TRFunction():New(oSection2:Cell("IMPNOINC"),"SD2NIC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		TRFunction():New(oSection2:Cell("IMPINC")  ,"SD2INC3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T.)
		oSection2:GetFunction("SD2NIC3"):Disable()
		oSection2:GetFunction("SD2INC3"):Disable()
	EndIf
	
EndIf

oReport:SetMeter((cAliasSD1)->(RecCount()))
dbSelectArea(cAliasSD1)

oSection1:Init()

While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())
	
	lMoeda := .T.
	
	If oReport:Cancel()
		Exit
	EndIf
	
	//=================================
	// Considera filtro escolhido     |
	//=================================
	dbSelectArea(cAliasSD1)
	If !Empty(cFilUsrSD1)
		If !(&(cFilUsrSD1))
			dbSkip()
			Loop
		EndIf
	EndIf
	
	If lQuery
		//===============================================================================
		// Desconsidera quando for Cliente e Tipo da NF <> Devolucao ou Beneficiamento  |
		// Em situações onde o Código do Cliente e Código do Fornecedor são iguais      |
		// e necessário este critério para não imprimir o relatório incorretamente.     |
		//===============================================================================
		if (cAliasSD1)->TIPO == "C"
			If !(cAliasSD1)->D1_TIPO $ "DB"
				dbSkip()
				Loop
			EndIf
		EndIf
		
		//==============================================================
		// Nao imprimir notas com moeda diferente da escolhida.        |
		//==============================================================
		If mv_par14==2
			If If((cAliasSD1)->F1_MOEDA==0,1,(cAliasSD1)->F1_MOEDA) != mv_par13
				lMoeda := .F.
			Endif
		EndIf
		
		cRazao   := (cAliasSD1)->RAZAO
		nValUnit := xmoeda((cAliasSD1)->D1_VUNIT,(cAliasSD1)->F1_MOEDA,mv_par13,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
		nValTot  := xmoeda((cAliasSD1)->D1_TOTAL,(cAliasSD1)->F1_MOEDA,mv_par13,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
		nValCusto:= xmoeda((cAliasSD1)->D1_CUSTO,1,mv_par13,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
		
		// Variável para atualizar o Código quando for estiver usando veículo ou não
		If lVeiculo
			cCod:=(cAliasSD1)->D1_CODITE
		Else
			cCod:= (cAliasSD1)->D1_COD
		EndIf
		
		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf((cAliasSD1)->D1_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:=(cAliasSD1)+"->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,(cAliasSD1)->F1_MOEDA,mv_par13,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next
		EndIf
	Else
		//==============================================================
		// Nao imprimir notas com moeda diferente da escolhida.        |
		//==============================================================
		If mv_par14==2
			If If(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA) != mv_par13
				lMoeda := .F.
			Endif
		EndIf
		
		//=================================================================
		// Posiciona o Fornecedor SA2 ou Cliente SA1 conf. o tipo da Nota |
		//=================================================================
		If (cAliasSD1)->D1_TIPO $ "DB"
			SA1->(dbSetOrder(1))
			SA1->(MsSeek( xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
			cRazao := SA1->A1_NOME
		Else
			SA2->(dbSetOrder(1))
			SA2->(MsSeek( xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
			cRazao := SA2->A2_NOME
		EndIf
		
		//=====================
		// Posiciona o SF1    |
		//=====================
		SF1->(MsSeek((cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		
		//=====================
		// Posiciona o SF4    |
		//=====================
		If mv_par15 == 1
			SF4->(MsSeek( xFilial("SF4") + (cAliasSD1)->D1_TES ))
		EndIf
		
		nValUnit := xmoeda((cAliasSD1)->D1_VUNIT,SF1->F1_MOEDA,mv_par13,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		nValTot  := xmoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,mv_par13,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		nValCusto:= xmoeda((cAliasSD1)->D1_CUSTO,1,mv_par13,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
		
		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf((cAliasSD1)->D1_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:=(cAliasSD1)+"->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,SF1->F1_MOEDA,mv_par13,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next
		EndIf
		
	EndIf
	
	If lMoeda
		
		oReport:IncMeter()
		oSection1:PrintLine()
		
		//================================================================
		// Verificar a existencia de Devolucoes de Compras.              |
		//================================================================
		If (cAliasSD1)->D1_QTDEDEV <> 0 .And. mv_par11 == 1
			AADD(aRecno,IIf(lQuery,(cAliasSD1)->SD1RECNO,Recno()))
		Endif
		
	EndIf
	
	dbSelectArea(cAliasSD1)
	dbSkip()
	
EndDo

oSection1:Finish()

//================================================================
// Exclui o Arquivo Trabalho SD2 quando imprime NFs de devolucao |
//================================================================
If mv_par11 == 1
	
	RetIndex("SD2")
	dbSelectArea("SD2")
	dbClearFilter()
	dbSetOrder(1)
	
	If File(cArqTrbSD2+OrdBagExt())
		Ferase(cArqTrbSD2+OrdBagExt())
	EndIf
	
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: RCOM009P
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/09/2014
===============================================================================================================================
Descrição---------: Imprime as devolucoes de compras SD2
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/

Static Function RCOM009P(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,nRecno)

Local nDecs    := Msdecimais(mv_par13) //casas decimais utilizadas na moeda da impressao
Local nX       := 0
Local nY       := 0
Local nSaveRec := If( lQuery, nRecno, Recno() )

oSection2:Init()

TRPosition():New(oSection2,"SB1",1,{|| xFilial("SB1")+SD2->D2_COD })

For nX :=1 to Len(aRecno)
	
	dbSelectArea("SD1")
	dbGoto(aRecno[nX])
	dbSelectArea("SD2")
	MsSeek(SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_DOC+SD1->D1_ITEM+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
	SF2->(MsSeek(SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
	
	While !Eof() .And. SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_DOC+SD1->D1_ITEM+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
		SD2->D2_FILIAL+SD2->D2_COD+SD2->D2_NFORI+SD2->D2_ITEMORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA
		
		If nX == 1
			oReport:PrintText('-Devolucoes:',,oSection2:Cell("D2_DOC"):ColPos())
		Endif
		
		If lVeiculo
			oReport:PrintText("[ " + SD2->D2_CODITE + " ]",,oSection2:Cell("D2_COD"):ColPos())
		EndIf
		
		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf(SD2->D2_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD2->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,SF2->F2_MOEDA,mv_par13,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next nY
		Endif
		
		nValUnit := xmoeda(SD2->D2_PRCVEN,SF2->F2_MOEDA,mv_par13,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
		nValTot  := xmoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,mv_par13,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
		nValCusto:= xmoeda(SD2->D2_CUSTO1,1,mv_par13,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
		
		SA2->(dbSetOrder(1))
		SA2->(MsSeek( xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA ))
		cRazao := SA2->A2_NOME
		
		oSection2:PrintLine()
		
		dbSelectArea("SD2")
		dbSkip()
		
	EndDo
	
	If nX == Len(aRecno)
		oReport:ThinLine()
		oReport:SkipLine()
	EndIf
	
Next nX

oSection2:Finish()

dbSelectArea(cAliasSD1)
dbgoto(nSaveRec)
aRecno := {}

Return

/*
===============================================================================================================================
Programa----------: RCOM009C
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/09/2014
===============================================================================================================================
Descrição---------: Busca a Descricao do Centro de Custo
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/
Static Function RCOM009C(_CC)

cDescCC := ""
cDescCC := POSICIONE("CTT",1,XFILIAL("CTT")+_CC,"CTT_DESC01")
cDescCC := ALLTRIM(cDescCC)

Return(cDescCC)

/*
===============================================================================================================================
Programa----------: RCOM009N
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/09/2014
===============================================================================================================================
Descrição---------: Busca a Natureza e Descricao
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/

Static Function RCOM009N(_DOC,_SERIE,_FORNECE,_LOJA,nNum)
Local cNatureza 	:= ""
Local cQuery		:= ""
Local cQuery2		:= ""

cQuery := " SELECT E2_NATUREZ FROM " + RetSqlName("SE2")+" SE2 "
cQuery += " WHERE E2_NUM 	= '"+_DOC+"' "
cQuery += " AND E2_FORNECE 	= '"+_FORNECE+"'"
cQuery += " AND E2_LOJA		= '"+_LOJA+"'"
cQuery += " AND E2_FILIAL 	= '"+xFilial("SE2")+"' "
cQuery += " AND SE2.D_E_L_E_T_ <> '*'"
cQuery += " AND E2_PREFIXO = '"+_SERIE+"'"
TcQuery cQuery New Alias "cQuery"

cNatureza := ALLTRIM(cQuery->E2_NATUREZ)

If !EMPTY(cQuery->E2_NATUREZ) .and. nNum == 2
	cQuery2 := " SELECT ED_DESCRIC FROM " + RetSqlName("SED")+" SED "
	cQuery2 += " WHERE ED_CODIGO = '"+cQuery->E2_NATUREZ+"' "
	cQuery2 += " AND ED_FILIAL = '"+xFilial("SED")+"' "
	cQuery2 += " AND SED.D_E_L_E_T_ <> '*'"
	TcQuery cQuery2 New Alias "cQuery2"
	
	cNatureza := ALLTRIM(cQuery2->ED_DESCRIC)
	
	cQuery2->(DbCloseArea())
Endif

cQuery->(DbCloseArea())

Return(cNatureza)
