/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Darcio Sporl	  | 14/09/2016 | Rotina cria para impressão do relatório de devolução de epi's. Chamado 16904
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 18/09/2019 | Retirada chamada da função itputx1. Chamado 28346 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa----------: RMDT002
Autor-------------: Darcio R Sporl
Data da Criacao---: 14/09/2016
===============================================================================================================================
Descrição---------: Relatório Devolução de EPI's
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RMDT002()
Local oReport	:= nil
Private _cPerg	:= "RMDT002"
Private aOrd	:= {} 

If !Pergunte(_cPerg,.T.)
     return
EndIf

oReport := RptDef(_cPerg)
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Darcio R Sporl
Data da Criacao---: 14/09/2016
===============================================================================================================================
Descrição---------: Função que faz a montagem do relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RptDef(cNome)

Local oReport	:= Nil
Local oSection1	:= Nil
Local oSection2	:= Nil
	
oReport:= TReport():New("RMDT002","Relatório Devolução de EPI's.","RMDT002",{|oReport| ReportPrint(oReport)},"Emissao da Relacao das Devoluções de EPI's.")
oReport:SetLandscape()

If mv_par07 == 1
	oSection1 := TRSection():New(oReport, "Devoluções EPI's - Por Epi's", {"TRBEPI"},aOrd , .F., .T.)
	oSection1:SetTotalInLine(.T.)

	//======================================
	//Definição das células para impressão |
	//======================================
	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("TLW_CODEPI")
	TRCell():New(oSection1,"CODEPI"		,"TRBEPI",X3TITULO()	,"@!",20)
	dbSeek("B1_DESC")
	TRCell():New(oSection1,"DESEPI"		,"TRBEPI",X3TITULO()	,"@!",50)

	oSection2 := TRSection():New(oSection1, "Devoluções EPI's - Por Epi's", {"TRBEPI"},aOrd , .F., .T.)
	//======================================
	//Definição das células para impressão |
	//======================================
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	dbSeek("TLW_MAT")
	TRCell():New(oSection2,"MATRIC"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("RA_NOME")
	TRCell():New(oSection2,"NOMFUN"		,"TRBEPI",X3TITULO()	,"@!",40)
	dbSeek("TLW_DTENTR")
	TRCell():New(oSection2,"DTENTR"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_HRENTR")
	TRCell():New(oSection2,"HRENTR"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_DTDEVO")
	TRCell():New(oSection2,"DTDEVO"		,"TRBEPI",X3TITULO() 	,"@D",10)
	dbSeek("TLW_HRDEVO")
	TRCell():New(oSection2,"HRDEVO"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_QTDEVO")
	TRCell():New(oSection2,"QTDDEV"		,"TRBEPI",X3TITULO()	,"@E 999,999",10)
	dbSeek("TLW_LOCAL")
	TRCell():New(oSection2,"ARMZEM"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_TIPODV")
	TRCell():New(oSection2,"TIPODV"		,"TRBEPI",X3TITULO()	,"@!",10)
ElseIf mv_par07 == 2
	oSection1 := TRSection():New(oReport, "Devoluções EPI's - Por Matrícula", {"TRBEPI"},aOrd , .F., .T.)
	oSection1:SetTotalInLine(.T.)

	//======================================
	//Definição das células para impressão |
	//======================================
	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("TLW_MAT")
	TRCell():New(oSection1,"MATRIC"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("RA_NOME")
	TRCell():New(oSection1,"NOMFUN"		,"TRBEPI",X3TITULO()	,"@!",40)

	oSection2 := TRSection():New(oSection1, "Devoluções EPI's - Por Matrícula", {"TRBEPI"},aOrd , .F., .T.)

	//======================================
	//Definição das células para impressão |
	//======================================
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	dbSeek("TLW_CODEPI")
	TRCell():New(oSection2,"CODEPI"		,"TRBEPI",X3TITULO()	,"@!",20)
	dbSeek("B1_DESC")
	TRCell():New(oSection2,"DESEPI"		,"TRBEPI",X3TITULO()	,"@!",50)
	dbSeek("TLW_DTENTR")
	TRCell():New(oSection2,"DTENTR"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_HRENTR")
	TRCell():New(oSection2,"HRENTR"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_DTDEVO")
	TRCell():New(oSection2,"DTDEVO"		,"TRBEPI",X3TITULO() 	,"@D",10)
	dbSeek("TLW_HRDEVO")
	TRCell():New(oSection2,"HRDEVO"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_QTDEVO")
	TRCell():New(oSection2,"QTDDEV"		,"TRBEPI",X3TITULO()	,"@E 999,999",10)
	dbSeek("TLW_LOCAL")
	TRCell():New(oSection2,"ARMZEM"		,"TRBEPI",X3TITULO()	,"@!",10)
	dbSeek("TLW_TIPODV")
	TRCell():New(oSection2,"TIPODV"		,"TRBEPI",X3TITULO()	,"@!",10)
Else
	oSection1 := TRSection():New(oReport, "Devoluções EPI's - Por Dt Devolução", {"TRBEPI"},aOrd , .F., .T.)
	oSection1:SetTotalInLine(.T.)

	//======================================
	//Definição das células para impressão |
	//======================================
	TRCell():New(oSection1,"DTDEVO"		,"TRBEPI",GetSX3Cache("TLW_DTDEVO","X3_TITULO") 	,"@D",10)

	oSection2 := TRSection():New(oSection1, "Devoluções EPI's - Por Matrícula", {"TRBEPI"},aOrd , .F., .T.)

	//======================================
	//Definição das células para impressão |
	//======================================
	TRCell():New(oSection2,"MATRIC"		,"TRBEPI",GetSX3Cache("TLW_MAT","X3_TITULO")	,"@!",10)
	TRCell():New(oSection2,"NOMFUN"		,"TRBEPI",GetSX3Cache("RA_NOME","X3_TITULO")	,"@!",40)
	TRCell():New(oSection2,"CODEPI"		,"TRBEPI",GetSX3Cache("TLW_CODEPI","X3_TITULO")	,"@!",20)
	TRCell():New(oSection2,"DESEPI"		,"TRBEPI",GetSX3Cache("B1_DESC","X3_TITULO")	,"@!",50)
	TRCell():New(oSection2,"DTENTR"		,"TRBEPI",GetSX3Cache("TLW_DTENTR","X3_TITULO")	,"@!",10)
	TRCell():New(oSection2,"HRENTR"		,"TRBEPI",GetSX3Cache("TLW_HRENTR","X3_TITULO")	,"@!",10)
	TRCell():New(oSection2,"HRDEVO"		,"TRBEPI",GetSX3Cache("TLW_HRDEVO","X3_TITULO")	,"@!",10)
	TRCell():New(oSection2,"QTDDEV"		,"TRBEPI",GetSX3Cache("TLW_QTDEVO","X3_TITULO")	,"@E 999,999",10)
	TRCell():New(oSection2,"ARMZEM"		,"TRBEPI",GetSX3Cache("TLW_LOCAL","X3_TITULO")	,"@!",10)
	TRCell():New(oSection2,"TIPODV"		,"TRBEPI",GetSX3Cache("TLW_TIPODV","X3_TITULO")	,"@!",10)
EndIf

Return(oReport)

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Darcio R Sporl
Data da Criacao---: 23/08/2016
===============================================================================================================================
Descrição---------: Função que imprime o relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cQry1		:= ""
Local cQry2		:= ""

If mv_par07 == 1

	cQry1 := "SELECT DISTINCT(TLW_CODEPI) AS TLW_CODEPI, B1_DESC "
	cQry1 += "FROM " + RetSqlName("TLW") + " TLW "
	cQry1 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = TLW_CODEPI AND SB1.D_E_L_E_T_ = ' ' "
	cQry1 += "JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = TLW_FILIAL AND RA_MAT = TLW_MAT AND SRA.D_E_L_E_T_ = ' ' "
	cQry1 += "WHERE TLW_FILIAL = '" + xFilial("TLW") + "' "
	cQry1 += "  AND TLW_CODEPI BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQry1 += "  AND TLW_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQry1 += "  AND TLW_DTDEVO BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06) + "' "
	cQry1 += "  AND TLW.D_E_L_E_T_ = ' ' "
	cQry1 += "ORDER BY TLW_CODEPI "

	If Select("TRBEPI") <> 0
		DbSelectArea("TRBEPI")
		DbCloseArea()
	EndIf
	
	TCQUERY cQry1 NEW ALIAS "TRBEPI"
			
	dbSelectArea("TRBEPI")
	TRBEPI->(dbGoTop())
			
	oReport:SetMeter(TRBEPI->(LastRec()))
	
	While !TRBEPI->(Eof())
	
		If oReport:Cancel()
			Exit
		EndIf
	
		oSection1:Init()
		
		oReport:IncMeter()
		
		IncProc("Imprimindo Devoluções...")

		oSection1:Cell("CODEPI")	:SetValue(TRBEPI->TLW_CODEPI)
		oSection1:Cell("DESEPI")	:SetValue(AllTrim(TRBEPI->B1_DESC))
		oSection1:Printline()

		oSection2:Init()

		cQry2 := "SELECT TLW_FILIAL, TLW_CODEPI, TLW_MAT, TLW_DTENTR, TLW_HRENTR, TLW_DTDEVO, TLW_HRDEVO, TLW_QTDEVO, TLW_LOCAL, "
		cQry2 += "CASE  WHEN TLW_TIPODV = 1 THEN 'SIM' "
		cQry2 += "      ELSE 'NÃO' END AS TLW_TIPODV, RA_NOME, B1_DESC "
		cQry2 += "FROM " + RetSqlName("TLW") + " TLW "
		cQry2 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = TLW_CODEPI AND SB1.D_E_L_E_T_ = ' ' "
		cQry2 += "JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = TLW_FILIAL AND RA_MAT = TLW_MAT AND SRA.D_E_L_E_T_ = ' ' "
		cQry2 += "WHERE TLW_FILIAL = '" + xFilial("TLW") + "' "
		cQry2 += "  AND TLW_CODEPI = '" + TRBEPI->TLW_CODEPI + "' "
		cQry2 += "  AND TLW_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
		cQry2 += "  AND TLW_DTDEVO BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06) + "' "
		cQry2 += "  AND TLW.D_E_L_E_T_ = ' ' "
		cQry2 += "ORDER BY TLW_FILIAL, TLW_CODEPI "

		If Select("TRBEPT") <> 0
			DbSelectArea("TRBEPT")
			DbCloseArea()
		EndIf
	
		TCQUERY cQry2 NEW ALIAS "TRBEPT"
			
		dbSelectArea("TRBEPT")
		TRBEPT->(dbGoTop())
			
		oReport:SetMeter(TRBEPT->(LastRec()))
	
		While !TRBEPT->(Eof())
	
			If oReport:Cancel()
				Exit
			EndIf
		
			oReport:IncMeter()
		
			IncProc("Imprimindo Devoluções...")

			oSection2:Cell("MATRIC")	:SetValue(TRBEPT->TLW_MAT)
			oSection2:Cell("NOMFUN")	:SetValue(AllTrim(TRBEPT->RA_NOME))
			oSection2:Cell("DTENTR")	:SetValue(StoD(TRBEPT->TLW_DTENTR))
			oSection2:Cell("HRENTR")	:SetValue(TRBEPT->TLW_HRENTR)
			oSection2:Cell("DTDEVO")	:SetValue(StoD(TRBEPT->TLW_DTDEVO))
			oSection2:Cell("HRDEVO")	:SetValue(TRBEPT->TLW_HRDEVO)
			oSection2:Cell("QTDDEV")	:SetValue(TRBEPT->TLW_QTDEVO)
			oSection2:Cell("QTDDEV")	:SetAlign("CENTER")
			oSection2:Cell("ARMZEM")	:SetValue(TRBEPT->TLW_LOCAL)
			oSection2:Cell("ARMZEM")	:SetAlign("CENTER")
			oSection2:Cell("TIPODV")	:SetValue(TRBEPT->TLW_TIPODV)
			oSection2:Cell("TIPODV")	:SetAlign("RIGHT")
			
			oSection2:Printline()
			
			TRBEPT->(dbSkip())
		End

		oSection2:Finish()
		oSection1:Finish()
		TRBEPI->(dbSkip())
	End
		
ElseIf mv_par07 == 2

	cQry1 := "SELECT DISTINCT(TLW_MAT) AS TLW_MAT, RA_NOME "
	cQry1 += "FROM " + RetSqlName("TLW") + " TLW "
	cQry1 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = TLW_CODEPI AND SB1.D_E_L_E_T_ = ' ' "
	cQry1 += "JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = TLW_FILIAL AND RA_MAT = TLW_MAT AND SRA.D_E_L_E_T_ = ' ' "
	cQry1 += "WHERE TLW_FILIAL = '" + xFilial("TLW") + "' "
	cQry1 += "  AND TLW_CODEPI BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQry1 += "  AND TLW_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQry1 += "  AND TLW_DTDEVO BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06) + "' "
	cQry1 += "  AND TLW.D_E_L_E_T_ = ' ' "
	cQry1 += "ORDER BY TLW_MAT "

	If Select("TRBEPI") <> 0
		DbSelectArea("TRBEPI")
		DbCloseArea()
	EndIf
	
	TCQUERY cQry1 NEW ALIAS "TRBEPI"
			
	dbSelectArea("TRBEPI")
	TRBEPI->(dbGoTop())
			
	oReport:SetMeter(TRBEPI->(LastRec()))
	
	While !TRBEPI->(Eof())
	
		If oReport:Cancel()
			Exit
		EndIf
	
		oSection1:Init()
		
		oReport:IncMeter()
		
		IncProc("Imprimindo Devoluções...")

		oSection1:Cell("MATRIC")	:SetValue(TRBEPI->TLW_MAT)
		oSection1:Cell("NOMFUN")	:SetValue(AllTrim(TRBEPI->RA_NOME))
		oSection1:Printline()

		oSection2:Init()

		cQry2 := "SELECT TLW_FILIAL, TLW_CODEPI, TLW_MAT, TLW_DTENTR, TLW_HRENTR, TLW_DTDEVO, TLW_HRDEVO, TLW_QTDEVO, TLW_LOCAL, "
		cQry2 += "CASE  WHEN TLW_TIPODV = 1 THEN 'SIM' "
		cQry2 += "      ELSE 'NÃO' END AS TLW_TIPODV, RA_NOME, B1_DESC "
		cQry2 += "FROM " + RetSqlName("TLW") + " TLW "
		cQry2 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = TLW_CODEPI AND SB1.D_E_L_E_T_ = ' ' "
		cQry2 += "JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = TLW_FILIAL AND RA_MAT = TLW_MAT AND SRA.D_E_L_E_T_ = ' ' "
		cQry2 += "WHERE TLW_FILIAL = '" + xFilial("TLW") + "' "
		cQry2 += "  AND TLW_CODEPI BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
		cQry2 += "  AND TLW_MAT = '" + TRBEPI->TLW_MAT + "' "
		cQry2 += "  AND TLW_DTDEVO BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06) + "' "
		cQry2 += "  AND TLW.D_E_L_E_T_ = ' ' "
		cQry2 += "ORDER BY TLW_FILIAL, TLW_MAT "

		If Select("TRBEPT") <> 0
			DbSelectArea("TRBEPT")
			DbCloseArea()
		EndIf
	
		TCQUERY cQry2 NEW ALIAS "TRBEPT"
			
		dbSelectArea("TRBEPT")
		TRBEPT->(dbGoTop())
			
		oReport:SetMeter(TRBEPT->(LastRec()))
	
		While !TRBEPT->(Eof())
	
			If oReport:Cancel()
				Exit
			EndIf
		
			oReport:IncMeter()
		
			IncProc("Imprimindo Devoluções...")

			oSection2:Cell("CODEPI")	:SetValue(TRBEPT->TLW_CODEPI)
			oSection2:Cell("DESEPI")	:SetValue(AllTrim(TRBEPT->B1_DESC))
			oSection2:Cell("DTENTR")	:SetValue(StoD(TRBEPT->TLW_DTENTR))
			oSection2:Cell("HRENTR")	:SetValue(TRBEPT->TLW_HRENTR)
			oSection2:Cell("DTDEVO")	:SetValue(StoD(TRBEPT->TLW_DTDEVO))
			oSection2:Cell("HRDEVO")	:SetValue(TRBEPT->TLW_HRDEVO)
			oSection2:Cell("QTDDEV")	:SetValue(TRBEPT->TLW_QTDEVO)
			oSection2:Cell("QTDDEV")	:SetAlign("CENTER")
			oSection2:Cell("ARMZEM")	:SetValue(TRBEPT->TLW_LOCAL)
			oSection2:Cell("ARMZEM")	:SetAlign("CENTER")
			oSection2:Cell("TIPODV")	:SetValue(TRBEPT->TLW_TIPODV)
			oSection2:Cell("TIPODV")	:SetAlign("RIGHT")
			
			oSection2:Printline()

			TRBEPT->(dbSkip())
		End

		oSection2:Finish()
		oSection1:Finish()
		TRBEPI->(dbSkip())
	End
		
Else

	cQry1 := "SELECT DISTINCT(TLW_DTDEVO) AS TLW_DTDEVO "
	cQry1 += "FROM " + RetSqlName("TLW") + " TLW "
	cQry1 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = TLW_CODEPI AND SB1.D_E_L_E_T_ = ' ' "
	cQry1 += "JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = TLW_FILIAL AND RA_MAT = TLW_MAT AND SRA.D_E_L_E_T_ = ' ' "
	cQry1 += "WHERE TLW_FILIAL = '" + xFilial("TLW") + "' "
	cQry1 += "  AND TLW_CODEPI BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQry1 += "  AND TLW_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQry1 += "  AND TLW_DTDEVO BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06) + "' "
	cQry1 += "  AND TLW.D_E_L_E_T_ = ' ' "
	cQry1 += "ORDER BY TLW_DTDEVO "

	If Select("TRBEPI") <> 0
		DbSelectArea("TRBEPI")
		DbCloseArea()
	EndIf
	
	TCQUERY cQry1 NEW ALIAS "TRBEPI"
			
	dbSelectArea("TRBEPI")
	TRBEPI->(dbGoTop())
			
	oReport:SetMeter(TRBEPI->(LastRec()))
	
	While !TRBEPI->(Eof())
	
		If oReport:Cancel()
			Exit
		EndIf
	
		oSection1:Init()
		
		oReport:IncMeter()
		
		IncProc("Imprimindo Devoluções...")

		oSection1:Cell("DTDEVO")	:SetValue(StoD(TRBEPI->TLW_DTDEVO))
		oSection1:Printline()

		oSection2:Init()

		cQry2 := "SELECT TLW_FILIAL, TLW_CODEPI, TLW_MAT, TLW_DTENTR, TLW_HRENTR, TLW_DTDEVO, TLW_HRDEVO, TLW_QTDEVO, TLW_LOCAL, "
		cQry2 += "CASE  WHEN TLW_TIPODV = 1 THEN 'SIM' "
		cQry2 += "      ELSE 'NÃO' END AS TLW_TIPODV, RA_NOME, B1_DESC "
		cQry2 += "FROM " + RetSqlName("TLW") + " TLW "
		cQry2 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = TLW_CODEPI AND SB1.D_E_L_E_T_ = ' ' "
		cQry2 += "JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = TLW_FILIAL AND RA_MAT = TLW_MAT AND SRA.D_E_L_E_T_ = ' ' "
		cQry2 += "WHERE TLW_FILIAL = '" + xFilial("TLW") + "' "
		cQry2 += "  AND TLW_CODEPI BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
		cQry2 += "  AND TLW_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
		cQry2 += "  AND TLW_DTDEVO = '" + TRBEPI->TLW_DTDEVO + "' "
		cQry2 += "  AND TLW.D_E_L_E_T_ = ' ' "
		cQry2 += "ORDER BY TLW_FILIAL, TLW_FORNEC, TLW_LOJA "

		If Select("TRBEPT") <> 0
			DbSelectArea("TRBEPT")
			DbCloseArea()
		EndIf
	
		TCQUERY cQry2 NEW ALIAS "TRBEPT"
			
		dbSelectArea("TRBEPT")
		TRBEPT->(dbGoTop())
			
		oReport:SetMeter(TRBEPT->(LastRec()))
	
		While !TRBEPT->(Eof())
	
			If oReport:Cancel()
				Exit
			EndIf
		
			oReport:IncMeter()
		
			IncProc("Imprimindo Devoluções...")

			oSection2:Cell("MATRIC")	:SetValue(TRBEPT->TLW_MAT)
			oSection2:Cell("NOMFUN")	:SetValue(AllTrim(TRBEPT->RA_NOME))
			oSection2:Cell("CODEPI")	:SetValue(TRBEPT->TLW_CODEPI)
			oSection2:Cell("DESEPI")	:SetValue(AllTrim(TRBEPT->B1_DESC))
			oSection2:Cell("DTENTR")	:SetValue(StoD(TRBEPT->TLW_DTENTR))
			oSection2:Cell("HRENTR")	:SetValue(TRBEPT->TLW_HRENTR)
			oSection2:Cell("HRDEVO")	:SetValue(TRBEPT->TLW_HRDEVO)
			oSection2:Cell("QTDDEV")	:SetValue(TRBEPT->TLW_QTDEVO)
			oSection2:Cell("QTDDEV")	:SetAlign("CENTER")
			oSection2:Cell("ARMZEM")	:SetValue(TRBEPT->TLW_LOCAL)
			oSection2:Cell("ARMZEM")	:SetAlign("CENTER")
			oSection2:Cell("TIPODV")	:SetValue(TRBEPT->TLW_TIPODV)
			oSection2:Cell("TIPODV")	:SetAlign("RIGHT")
			
			oSection2:Printline()

			TRBEPT->(dbSkip())
		End

		oSection2:Finish()
		oSection1:Finish()
		TRBEPI->(dbSkip())
	End

EndIf

oSection1:Enable()
oSection2:Enable()

Return