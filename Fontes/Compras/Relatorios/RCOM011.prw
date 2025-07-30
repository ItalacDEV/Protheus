/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |08/02/2023| Chamado 42719 - Acrescentada a opcao NF no campo C7_I_URGEN : S(SIM), N(NAO) F(NF).
Igor Melgaço  |04/09/2024| Chamado 48417 - Acrescentado o campo E4_DESCRI no relatorio analitico.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
==================================================================================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==================================================================================================================================================================================================================
André    - Julio Paz     - 28/02/25 -          -  50030  - Inclusão de novas informações referentes a centro de custo no relatório.
==================================================================================================================================================================================================================

*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa----------: RCOM011
Autor-------------: Darcio R Sporl
Data da Criacao---: 22/03/2016
Descrição---------: Relatório de pedido completo
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM011()

Local oReport	:= nil
Private cPerg	:= "RCOM011"
Private aOrd	:= {"Filial"} 
Private aSelFil := {}

If !Pergunte(cPerg,.T.)
   return
Else
	If mv_par01 == 3
		aSelFil := AdmGetFil()
		If len(aSelFil) < 1
			return
		Endif
	EndIf
EndIf

oReport := RCOM011D(cPerg)
oReport:PrintDialog()

U_ITLOGACS( "RCOM011" )

Return

/*
===============================================================================================================================
Programa----------: RCOM011D
Autor-------------: Darcio R Sporl
Data da Criacao---: 22/03/2016
Descrição---------: Função que faz a montagem do relatório
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM011D(cNome)

Local oReport	:= Nil
Local oSection1	:= Nil
Local oSection2	:= Nil

oReport:= TReport():New("RCOM011","Relacao de Pedidos de Compras","RCOM011", {|oReport| RCOM011R(oReport)},"Emissao da Relacao de Pedidos de Compras.")
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

If MV_PAR13 == 1
	oSection1:= TRSection():New(oReport, "Pedidos", {"TRBPED"}, , .F., .T.)

	TRCell():New(oSection1,"C7_FILIAL"	,"TRBPED","Filial"  		,"@!",5)
	TRCell():New(oSection1,"NOMEFIL"  	,"TRBPED","Nome"			,"@!",30)
	TRCell():New(oSection1,"C7_NUM"		,"TRBPED","Pedido"  		,"@!",10)  
	TRCell():New(oSection1,"C7_NUMSC"	,"TRBPED","SC"  			,"@!",10)
	TRCell():New(oSection1,"NOMSC"		,""		 ,"Solicitante"		,"@!",15)
	TRCell():New(oSection1,"C7_EMISSAO"	,"TRBPED","Emissao"			,"@D",10)
	TRCell():New(oSection1,"C7_I_DTFAT"	,"TRBPED","Dt.Faturamento"	,"@D",10)
	TRCell():New(oSection1,"C7_DATPRF"	,"TRBPED","Dt.Entrega"		,"@D",10)
	TRCell():New(oSection1,"A2_NREDUZ"	,"TRBPED","Fornecedor"		,"@!",50)
	TRCell():New(oSection1,"Y1_NOME"  	,"TRBPED","Comprador"		,"@!",50)
	TRCell():New(oSection1,"C7_I_APLIC"	,"TRBPED","Aplicacao"		,"@!",14)
	TRCell():New(oSection1,"ZZI_DESINV"	,"TRBPED","Investimento"	,"@!",50)
	TRCell():New(oSection1,"C7_GRUPCOM"	,"TRBPED","Grupo"			,"@!",8)
	TRCell():New(oSection1,"C7_I_URGEN"	,"TRBPED","Urgente"			,"@!",4)
	TRCell():New(oSection1,"C7_I_CMPDI"	,"TRBPED","Compra Direta"	,"@!",4)
	TRCell():New(oSection1,"E4_DESCRI"	,"TRBPED","Cond. pgto"	   ,"@!",50)
    TRCell():New(oSection1,"C7_CC"	    ,"TRBPED","Centro de custo","@!",25)
	
    TRCell():New(oSection1,"CONSMSG"	,"TRBDAD","Obs"				,"@!",40)
	oSection1:OnPrintLine({|| cNomeFil := TRBPED->C7_FILIAL  + " -  " + AllTrim(FWFilialName(cEmpAnt,TRBPED->C7_FILIAL))  })
	oSection1:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})	
	
	oSection2:= TRSection():New(oSection1, "Pedidos", {"TRBDAD"}, NIL, .F., .T.)
	TRCell():New(oSection2,"C7_ITEM"	,"TRBDAD","Item"		,"@!",8)
	TRCell():New(oSection2,"C7_PRODUTO"	,"TRBDAD","Produto"		,"@!",15)
	TRCell():New(oSection2,"B1_DESC"	,"TRBDAD","Descrição"	,"@!",50)
	TRCell():New(oSection2,"C7_QUANT"	,"TRBDAD","Quantidade"	,"@E 999,999,999",11)
	TRCell():New(oSection2,"C7_QUJE"	,"TRBDAD","Qtd.Entreg."	,"@E 999,999,999",11) 
	TRCell():New(oSection2,"C7_PRECO"	,"TRBDAD","Preço"		,"@E 999,999,999.999",16)
	TRCell():New(oSection2,"C7_TOTAL"	,"TRBDAD","Total"		,"@E 999,999,999.999",16)
	TRCell():New(oSection2,"C7_VLDESC"	,"TRBDAD","Desconto"	,"@E 999,999,999.999",16)
	TRCell():New(oSection2,"C7_VALIPI"	,"TRBDAD","Ipi"			,"@E 999,999,999.999",16)
	TRCell():New(oSection2,"C7_ICMSRET"	,"TRBDAD","Icms Ret"	,"@E 999,999,999.999",16)
	TRCell():New(oSection2,"C7_RESIDUO"	,"TRBDAD","Residuo" 	,"@!",01)
	TRCell():New(oSection2,"CONSNOTA"	,"TRBDAD","Notas"		,"@!",40)
    TRCell():New(oSection2,"C7_CC"	    ,"TRBDAD","Centro de custo","@!",25)

	TRFunction():New(oSection2:Cell("C7_QUANT"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection2:Cell("C7_PRECO"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection2:Cell("C7_TOTAL"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection2:Cell("C7_VLDESC"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection2:Cell("C7_VALIPI"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection2:Cell("C7_ICMSRET"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	oSection2:SetTotalInLine(.F.)

Else
	oSection1:= TRSection():New(oReport, "Pedidos", {"SC7"}, , .F., .T.)
	TRCell():New(oSection1,"C7_FILIAL"	,"TRBPED","Filial"  		,"@!",5)
	TRCell():New(oSection1,"NOMEFIL"  	,"TRBPED","Nome"			,"@!",30)
	TRCell():New(oSection1,"C7_NUM"		,"TRBPED","Pedido"  		,"@!",10)
	TRCell():New(oSection1,"C7_EMISSAO"	,"TRBPED","Emissao"			,"@D",10)
	TRCell():New(oSection1,"C7_I_DTFAT"	,"TRBPED","Dt.Faturamento"	,"@D",10)
	TRCell():New(oSection1,"C7_DATPRF"	,"TRBPED","Dt.Entrega"		,"@D",10)
	TRCell():New(oSection1,"A2_NREDUZ"	,"TRBPED","Fornecedor"		,"@!",50)
	TRCell():New(oSection1,"Y1_NOME"  	,"TRBPED","Comprador"		,"@!",50)
	TRCell():New(oSection1,"C7_I_APLIC"	,"TRBPED","Aplicacao"		,"@!",14)
	TRCell():New(oSection1,"ZZI_DESINV"	,"TRBPED","Investimento"	,"@!",50)
	TRCell():New(oSection1,"C7_GRUPCOM"	,"TRBPED","Grupo"			,"@!",8)
	TRCell():New(oSection1,"C7_I_URGEN"	,"TRBPED","Urgente"			,"@!",4)
	TRCell():New(oSection1,"C7_I_CMPDI"	,"TRBPED","Compra Direta"	,"@!",4)
	TRCell():New(oSection1,"TOTAL"		,"TRBDAD","Total"			,"@E 999,999,999.999",16)
	TRCell():New(oSection1,"VLDESC"		,"TRBDAD","Desconto"		,"@E 999,999,999.999",16)
	TRCell():New(oSection1,"VALIPI"		,"TRBDAD","Ipi"				,"@E 999,999,999.999",16)
	TRCell():New(oSection1,"ICMSRET"	,"TRBDAD","Icms Ret"		,"@E 999,999,999.999",16)
	TRCell():New(oSection1,"CONSNOTA"	,"TRBDAD","Notas"			,"@!",40)
	TRCell():New(oSection1,"CONSMSG"	,"TRBDAD","Obs"				,"@!",40)
	TRCell():New(oSection1,"E4_DESCRI"	,"TRBPED","Cond. pgto"	    ,"@!",50)
    TRCell():New(oSection1,"C7_CC"	    ,"TRBPED","Centro de custo" ,"@!",25)
	
	TRFunction():New(oSection1:Cell("TOTAL"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection1:Cell("VLDESC"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection1:Cell("VALIPI"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
	TRFunction():New(oSection1:Cell("ICMSRET"),NIL,"SUM",,,"@E 999,999,999.999",,.F.,.T.)
EndIf
	
oReport:SetTotalInLine(.F.)

//=================================
//Aqui, farei uma quebra  por seção
//=================================
oSection1:SetPageBreak(.T.)
oSection1:SetTotalText("TOTAL GERAL ")				

Return(oReport)

/*
===============================================================================================================================
Programa----------: RCOM011R
Autor-------------: Darcio R Sporl
Data da Criacao---: 22/03/2016
Descrição---------: Função que imprime o relatório
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM011R(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cQry1		:= ""
Local cQry2		:= ""
Local cin       := ""
Local nI		:= 0
Local nQuant := 0
Local nPreco := 0
Local nTotal := 0
Local nVldes := 0
Local nVlIpi := 0
Local nVlIcm := 0

If MV_PAR13 == 1    // Relatório Analitico
	cQry1 := "SELECT  DISTINCT(C7_NUM) C7_NUM, C7_NUMSC, "
	cQry1 += "        C7_FILIAL, "
	cQry1 += "        C7_EMISSAO, "
	cQry1 += "        (SELECT MIN(C7_I_DTFAT) C7_I_DTFAT FROM " + RetSqlName("SC7") + " SC7A WHERE SC7A.C7_FILIAL = SC7.C7_FILIAL AND SC7A.C7_NUM = SC7.C7_NUM AND SC7A.D_E_L_E_T_ = ' ') C7_I_DTFAT, "
	cQry1 += "        (SELECT MIN(C7_DATPRF) C7_DATPRF FROM " + RetSqlName("SC7") + " SC7B WHERE SC7B.C7_FILIAL = SC7.C7_FILIAL AND SC7B.C7_NUM = SC7.C7_NUM AND SC7B.D_E_L_E_T_ = ' ') C7_DATPRF, "
	cQry1 += "        C7_I_APLIC, "
	cQry1 += "		  C7_I_CDINV, "
	cQry1 += "        ZZI_DESINV, "
	cQry1 += "        C7_I_URGEN, "
	cQry1 += "        C7_I_CMPDI, "
	cQry1 += "        C7_FORNECE, "
	cQry1 += "        C7_LOJA, "
	cQry1 += "        C7_USER,"
	cQry1 += "        C7_GRUPCOM, "
	cQry1 += "        A2_NREDUZ, "
    cQry1 += "        E4_DESCRI, "
    cQry1 += "        C7_CC, "
	cQry1 += "        Y1_NOME "
	cQry1 += "FROM " + RetSqlName("SC7") + " SC7 "
	cQry1 += "JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	cQry1 += "LEFT JOIN " + RetSqlName("SY1") + " SY1 ON Y1_FILIAL = '" + xFilial("SY1") + "' AND Y1_USER = C7_USER AND SY1.D_E_L_E_T_ = ' ' "
	cQry1 += "LEFT JOIN " + RetSqlName("ZZI") + " ZZI ON ZZI_FILIAL = C7_FILIAL AND ZZI_CODINV = C7_I_CDINV AND ZZI.D_E_L_E_T_ = ' ' "
	cQry1 += "LEFT JOIN " + RetSqlName("SE4") + " SE4 ON E4_FILIAL =  '" + xFilial("SE4") + "' AND E4_CODIGO = C7_COND  AND SE4.D_E_L_E_T_ = ' ' "
   cQry1 += "WHERE C7_EMISSAO BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
	
	If MV_PAR01 == 1
		cQry1 += " AND C7_FILIAL <> '  ' "
	ElseIf MV_PAR01 == 2
		cQry1 += " AND C7_FILIAL = '" + xFilial("SC7") + "' "
	ElseIf MV_PAR01 == 3
		For nI := 1 To Len(aSelFil)
			cIn += "'" + aSelFil[nI] + "',"
		Next nI
		cIn		:= SubStr(cIn,1,Len(cIn)-1)
		cQry1	+= " AND C7_FILIAL IN (" + cIn + ") "
	EndIf
	
	//=========================================
	//Tratamento da clausula where da aplicacao
	//=========================================
	If MV_PAR02 == 1				//Consumo
		cQry1 += " AND C7_I_APLIC = 'C' "
	ElseIf MV_PAR02 == 2			//Investimento
		cQry1 += " AND C7_I_APLIC = 'I' "
	ElseIf MV_PAR02 == 3			//Manutenção
		cQry1 += " AND C7_I_APLIC = 'M' "
	ElseIf MV_PAR02 == 4			//Serviço
		cQry1 += " AND C7_I_APLIC = 'S' "
	EndIf
	
	//=======================
	//Filtra grupo de compras
	//=======================
	If !Empty(MV_PAR03)
		cQry1 += " AND C7_GRUPCOM = '" + MV_PAR03 + "' "
	EndIf
	
	//================
	//Filtra comprador
	//================
	If !Empty(MV_PAR04)
		cQry1 += " AND C7_USER = '" + MV_PAR04 + "' "
	EndIf

	//================
	//Filtra Fonecedor
	//================
	cQry1 += " AND C7_FORNECE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR09 + "' "
	cQry1 += " AND C7_LOJA BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "' "

	//==============
	//Filtra urgente
	//==============
	If MV_PAR11 = 1				//Sim
		cQry1 += " AND C7_I_URGEN = 'S' "
	ElseIf MV_PAR11 = 2			//Nao
		cQry1 += " AND C7_I_URGEN = 'N' "
	ElseIf MV_PAR11 = 3			//NF
		cQry1 += " AND C7_I_URGEN = 'F' "
	EndIf
	
	//==============================================
	// Tratamento da clausula where do compra direta
	//==============================================
	If MV_PAR12 == 1				//Sim
		cQry1 += " AND C7_I_CMPDI = 'S' "
	ElseIf MV_PAR12 == 2			//Nao 
		cQry1 += " AND C7_I_CMPDI = 'N' "
	EndIf
	
	//==============================================
	// Filtro por Posição de Pedidos de Compras
	//==============================================
	If MV_PAR14 == 2				//Pedidos Atendidos
	   cQry1 += " AND C7_QUJE <> 0 "
	ElseIf MV_PAR14 == 3			//Pedidos Não Atendidos
       cQry1 += "AND NOT EXISTS (SELECT 'Y' FROM " + RetSqlName("SC7") + " SC7D WHERE SC7D.C7_FILIAL = SC7.C7_FILIAL AND SC7D.C7_NUM = SC7.C7_NUM AND SC7D.C7_QUJE <> 0 AND SC7D.D_E_L_E_T_ = ' ') "
	ElseIf MV_PAR14 == 4			//"Parc. Atendidos"
	   cQry1 += " AND C7_QUJE > 0 AND C7_QUANT > C7_QUJE "
	EndIf

	If MV_PAR15 = 1				//Pedidos COM RESIDUOS
	   cQry1 += " AND  C7_RESIDUO = 'S'  "
	ElseIf MV_PAR15 = 2			//Pedidos SEM RESIDUOS
	   cQry1 += " AND  C7_RESIDUO <> 'S'  "
	EndIf
	
	cQry1 += "  AND SC7.D_E_L_E_T_ = ' ' "
	cQry1 += "GROUP BY C7_FILIAL, C7_NUM, C7_NUMSC, C7_EMISSAO, C7_I_DTFAT, C7_DATPRF, C7_I_APLIC, C7_I_CDINV, ZZI_DESINV, C7_I_URGEN, C7_I_CMPDI, C7_FORNECE, C7_LOJA, C7_USER, C7_GRUPCOM, A2_NREDUZ, Y1_NOME, E4_DESCRI, C7_CC "
	cQry1 += "ORDER BY C7_FILIAL, C7_NUM, C7_EMISSAO "

	//=================================================================
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	//=================================================================
	If Select("TRBPED") <> 0
		DbSelectArea("TRBPED")
		DbCloseArea()
	EndIf

	//=================
	//crio o novo alias
	//=================
	TCQUERY cQry1 NEW ALIAS "TRBPED"
		
	dbSelectArea("TRBPED")
	_ntot:=0
	COUNT TO _ntot
	TRBPED->(dbGoTop())
		
	oReport:SetMeter(_ntot)

	//=================================
	//Irei percorrer todos os registros
	//=================================
	While !TRBPED->(Eof())
	
		If oReport:Cancel()
			Exit
		EndIf

		//===========================
		//inicializo a primeira seção
		//===========================
		oSection1:Init()
	
		oReport:IncMeter()
	
		//IncProc("Imprimindo Filial " + Alltrim(TRBPED->C7_FILIAL) + " - " + AllTrim(FWFilialName(cEmpAnt,TRBPED->C7_FILIAL)))

		//========================
		//imprimo a primeira seção
		//========================
		oSection1:Cell("C7_FILIAL")	:SetValue(TRBPED->C7_FILIAL)
		oSection1:Cell("NOMEFIL")	:SetValue(AllTrim(FWFilialName(cEmpAnt,TRBPED->C7_FILIAL)))
		oSection1:Cell("C7_NUM")	:SetValue(TRBPED->C7_NUM)
		
		oSection1:Cell("C7_NUMSC")	:SetValue(TRBPED->C7_NUMSC)
		oSection1:Cell("NOMSC")		:SetValue(POSICIONE("SC1",6,TRBPED->C7_FILIAL+TRBPED->C7_NUM,"C1_SOLICIT"))
				
		oSection1:Cell("C7_EMISSAO"):SetValue(StoD(TRBPED->C7_EMISSAO))
		oSection1:Cell("C7_I_DTFAT"):SetValue(StoD(TRBPED->C7_I_DTFAT))
		oSection1:Cell("C7_DATPRF")	:SetValue(StoD(TRBPED->C7_DATPRF))
		oSection1:Cell("A2_NREDUZ")	:SetValue(TRBPED->A2_NREDUZ)
		oSection1:Cell("Y1_NOME")	:SetValue(TRBPED->Y1_NOME)
		oSection1:Cell("C7_I_APLIC"):SetValue(TRBPED->C7_I_APLIC)
		oSection1:Cell("C7_GRUPCOM"):SetValue(TRBPED->C7_GRUPCOM)
		oSection1:Cell("C7_I_URGEN"):SetValue(TRBPED->C7_I_URGEN)
		oSection1:Cell("C7_I_CMPDI"):SetValue(TRBPED->C7_I_CMPDI)
		oSection1:Cell("CONSMSG")	:SetValue(U_RCOM011O(TRBPED->C7_FILIAL,TRBPED->C7_NUM))
		oSection1:Cell("E4_DESCRI") :SetValue(TRBPED->E4_DESCRI)
		oSection1:Cell("C7_CC")     :SetValue(TRBPED->C7_CC) 
		
      oSection1:Printline()

		//==========================
		//inicializo a segunda seção
		//==========================
		oSection2:init()
	
		cQry2 := "SELECT C7_FILIAL, C7_NUM, C7_NUMSC, C7_TIPO, C7_ITEM, C7_PRODUTO, C7_UM, C7_QUANT, C7_QUJE, C7_PRECO, C7_TOTAL, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_USER, Y1_NOME, C7_RESIDUO, "
		cQry2 += "		 C7_I_APLIC, C7_GRUPCOM, C7_EMISSAO, C7_I_URGEN, C7_I_CMPDI, B1_DESC, B1_I_DESCD, C7_VLDESC, C7_VALIPI, C7_ICMSRET, C7_CC "  
		cQry2 += "FROM " + RetSqlName("SC7") + " SC7 "
		cQry2 += "JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
		cQry2 += "LEFT JOIN " + RetSqlName("SY1") + " SY1 ON Y1_FILIAL = '" + xFilial("SY1") + "' AND Y1_USER = C7_USER AND SY1.D_E_L_E_T_ = ' ' "
		cQry2 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
		cQry2 += "WHERE C7_FILIAL = '" + TRBPED->C7_FILIAL + "' "
		cQry2 += "  AND C7_NUM = '" + TRBPED->C7_NUM + "' "
		cQry2 += "  AND SC7.D_E_L_E_T_ = ' ' "
	    //==============================================
	    // Filtro por Posição de Pedidos de Compras
	    //==============================================
	    If MV_PAR14 == 2				//Pedidos Atendidos
	       cQry2 += " AND C7_QUJE <> 0 "
	    ElseIf MV_PAR14 == 4			//"Parc. Atendidos"
	       cQry2 += " AND C7_QUJE > 0 AND C7_QUANT > C7_QUJE "
	    EndIf

	    If MV_PAR15 = 1				//Pedidos COM RESIDUOS
	       cQry2 += " AND  C7_RESIDUO = 'S'  "
	    ElseIf MV_PAR15 = 2			//Pedidos SEM RESIDUOS
	       cQry2 += " AND  C7_RESIDUO <> 'S'  "
	    EndIf
		cQry2 += "ORDER BY C7_FILIAL, C7_NUM, C7_ITEM, C7_EMISSAO "
	
		If Select("TRBDAD") <> 0
			DbSelectArea("TRBDAD")
			DbCloseArea()
		EndIf
	
		TCQUERY cQry2 NEW ALIAS "TRBDAD"
		
		dbSelectArea("TRBDAD")
		TRBDAD->(dbGoTop())
		
		While !TRBDAD->(Eof())

			//=======================
			//Imprime a segunda seção
			//=======================
			//IncProc("Imprimindo produto "+alltrim(TRBDAD->C7_PRODUTO))
			oSection2:Cell("C7_ITEM")	:SetValue(TRBDAD->C7_ITEM)
			oSection2:Cell("C7_PRODUTO"):SetValue(TRBDAD->C7_PRODUTO)
			oSection2:Cell("B1_DESC")	:SetValue(Iif(AllTrim(TRBDAD->B1_I_DESCD) $ AllTrim(TRBDAD->B1_DESC), AllTrim(TRBDAD->B1_DESC), AllTrim(TRBDAD->B1_DESC) + " " + AllTrim(TRBDAD->B1_I_DESCD)))
			oSection2:Cell("C7_QUANT")	:SetValue(TRBDAD->C7_QUANT)
			oSection2:Cell("C7_QUJE")	:SetValue(TRBDAD->C7_QUJE)
			oSection2:Cell("C7_PRECO")	:SetValue(TRBDAD->C7_PRECO)
			oSection2:Cell("C7_TOTAL")	:SetValue(TRBDAD->C7_TOTAL)
			oSection2:Cell("C7_VLDESC")	:SetValue(TRBDAD->C7_VLDESC)
			oSection2:Cell("C7_VALIPI")	:SetValue(TRBDAD->C7_VALIPI)
			oSection2:Cell("C7_ICMSRET"):SetValue(TRBDAD->C7_ICMSRET)
			oSection2:Cell("C7_RESIDUO"):SetValue(TRBDAD->C7_RESIDUO)
            oSection2:Cell("C7_CC")     :SetValue(TRBDAD->C7_CC) 

			oSection2:Cell("CONSNOTA")	:SetValue(U_RCOM011U(TRBDAD->C7_FILIAL,TRBDAD->C7_NUM,TRBDAD->C7_ITEM))
			oSection2:Printline()
	
			TRBDAD->(dbSkip())
		End
		oReport:ThinLine()
		oSection2:Finish()
		TRBPED->(dbSkip())
	End
	oSection1:Finish()
	oSection1:Enable()
	oSection2:Enable()
Else   // Relatório Sintetico.
	cQry1 := "SELECT  DISTINCT(C7_NUM) C7_NUM, "
	cQry1 += "        C7_FILIAL, "
	cQry1 += "        C7_EMISSAO, "
	cQry1 += "        (SELECT MIN(C7_I_DTFAT) C7_I_DTFAT FROM " + RetSqlName("SC7") + " SC7A WHERE SC7A.C7_FILIAL = SC7.C7_FILIAL AND SC7A.C7_NUM = SC7.C7_NUM AND SC7A.D_E_L_E_T_ = ' ') C7_I_DTFAT, "
	cQry1 += "        (SELECT MIN(C7_DATPRF) C7_DATPRF FROM " + RetSqlName("SC7") + " SC7B WHERE SC7B.C7_FILIAL = SC7.C7_FILIAL AND SC7B.C7_NUM = SC7.C7_NUM AND SC7B.D_E_L_E_T_ = ' ') C7_DATPRF, "
	cQry1 += "        C7_I_APLIC, "
	cQry1 += "		  C7_I_CDINV, "
	cQry1 += "        ZZI_DESINV, "
	cQry1 += "        C7_I_URGEN, "
	cQry1 += "        C7_I_CMPDI, "
	cQry1 += "        C7_FORNECE, "
	cQry1 += "        C7_LOJA, "
	cQry1 += "        C7_USER,"
	cQry1 += "        C7_GRUPCOM, "
	cQry1 += "        A2_NREDUZ, "
	cQry1 += "        Y1_NOME, "
    cQry1 += "        C7_CC "
	cQry1 += "FROM " + RetSqlName("SC7") + " SC7 "
	cQry1 += "JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	cQry1 += "LEFT JOIN " + RetSqlName("SY1") + " SY1 ON Y1_FILIAL = '" + xFilial("SY1") + "' AND Y1_USER = C7_USER AND SY1.D_E_L_E_T_ = ' ' "
	cQry1 += "LEFT JOIN " + RetSqlName("ZZI") + " ZZI ON ZZI_FILIAL = C7_FILIAL AND ZZI_CODINV = C7_I_CDINV AND ZZI.D_E_L_E_T_ = ' ' "
	cQry1 += "WHERE C7_EMISSAO BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
	
	If MV_PAR01 == 1
		cQry1 += " AND C7_FILIAL <> '  ' "
	ElseIf MV_PAR01 == 2
		cQry1 += " AND C7_FILIAL = '" + xFilial("SC7") + "' "
	ElseIf MV_PAR01 == 3
		For nI := 1 To Len(aSelFil)
			cIn += "'" + aSelFil[nI] + "',"
		Next nI
		cIn		:= SubStr(cIn,1,Len(cIn)-1)
		cQry1	+= " AND C7_FILIAL IN (" + cIn + ") "
	EndIf
	
	//=========================================
	//Tratamento da clausula where da aplicacao
	//=========================================
	If MV_PAR02 == 1				//Consumo
		cQry1 += " AND C7_I_APLIC = 'C' "
	ElseIf MV_PAR02 == 2			//Investimento
		cQry1 += " AND C7_I_APLIC = 'I' "
	ElseIf MV_PAR02 == 3			//Manutenção
		cQry1 += " AND C7_I_APLIC = 'M' "
	ElseIf MV_PAR02 == 4			//Serviço
		cQry1 += " AND C7_I_APLIC = 'S' "
	ElseIf MV_PAR02 == 5			//Todos
		cQry1 += " AND C7_I_APLIC <> ' ' "
	EndIf
	
	//=======================
	//Filtra grupo de compras
	//=======================
	If !Empty(MV_PAR03)
		cQry1 += " AND C7_GRUPCOM = '" + MV_PAR03 + "' "
	EndIf
	
	//================
	//Filtra comprador
	//================
	If !Empty(MV_PAR04)
		cQry1 += " AND C7_USER = '" + MV_PAR04 + "' "
	EndIf

	//================
	//Filtra Fonecedor
	//================
	cQry1 += " AND C7_FORNECE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR09 + "' "
	cQry1 += " AND C7_LOJA BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "' "

	//==============
	//Filtra urgente
	//==============
	If MV_PAR11 = 1				//Sim
		cQry1 += " AND C7_I_URGEN = 'S' "
	ElseIf MV_PAR11 = 2			//Nao
		cQry1 += " AND C7_I_URGEN = 'N' "
	ElseIf MV_PAR11 = 3			//NF
		cQry1 += " AND C7_I_URGEN = 'F' "
	EndIf
	
	//=============================================
	//Tratamento da clausula where do compra direta
	//=============================================
	If MV_PAR12 == 1				//Sim
		cQry1 += " AND C7_I_CMPDI = 'S' "
	ElseIf MV_PAR12 == 2			//Nao
		cQry1 += " AND C7_I_CMPDI = 'N' "
	EndIf
	
	//==============================================
	// Filtro por Posição de Pedidos de Compras
	//==============================================
	If MV_PAR14 == 2				//Pedidos Atendidos - Se existir um item não atendido, não mostra nada.
	   cQry1 += " AND NOT EXISTS (SELECT 'Y' FROM "+RetSqlName("SC7") + " SC7Q2 "+" WHERE SC7Q2.C7_FILIAL = SC7.C7_FILIAL AND SC7Q2.C7_NUM = SC7.C7_NUM AND SC7Q2.C7_QUJE = 0 AND SC7Q2.D_E_L_E_T_ = ' ')
	ElseIf MV_PAR14 == 3			//Pedidos Não Atendidos - Se existir algum item atendido, mostra os dados.
	   cQry1 += " AND EXISTS (SELECT 'Y' FROM "+RetSqlName("SC7") + " SC7Q2 "+" WHERE SC7Q2.C7_FILIAL = SC7.C7_FILIAL AND SC7Q2.C7_NUM = SC7.C7_NUM AND SC7Q2.C7_QUJE = 0 AND SC7Q2.D_E_L_E_T_ = ' ')
	ElseIf MV_PAR14 == 4			//"Parc. Atendidos"
	   cQry1 += " AND C7_QUJE > 0 AND C7_QUANT > C7_QUJE "
	ElseIf MV_PAR14 == 5			//"Parc. Atendidos+ Nao Atendidos"
	   cQry1 += " AND C7_QUJE >= 0 AND C7_QUANT > C7_QUJE "
	EndIf

	If MV_PAR15 = 1				//Pedidos COM RESIDUOS
	   cQry1 += " AND  C7_RESIDUO = 'S'  "
	ElseIf MV_PAR15 = 2			//Pedidos SEM RESIDUOS
	   cQry1 += " AND  C7_RESIDUO <> 'S'  "
	EndIf

	cQry1 += "  AND SC7.D_E_L_E_T_ = ' ' "
	cQry1 += " GROUP BY C7_NUM, C7_FILIAL, C7_EMISSAO, C7_I_DTFAT, C7_DATPRF, C7_I_APLIC, C7_I_CDINV, ZZI_DESINV, C7_I_URGEN, C7_I_CMPDI, C7_FORNECE, C7_LOJA, C7_USER, C7_GRUPCOM, A2_NREDUZ, Y1_NOME, C7_CC "
	cQry1 += " ORDER BY C7_FILIAL, C7_NUM, C7_EMISSAO "

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	If Select("TRBPED") <> 0
		DbSelectArea("TRBPED")
		DbCloseArea()
	EndIf
		
	//crio o novo alias
	TCQUERY cQry1 NEW ALIAS "TRBPED"
		
	dbSelectArea("TRBPED")
	_ntot:=0
	COUNT TO _ntot
	TRBPED->(dbGoTop())
		
	oReport:SetMeter(_ntot)
	
	//Irei percorrer todos os meus registros
	While !TRBPED->(Eof())
	
		If oReport:Cancel()
			Exit
		EndIf
	
		//inicializo a primeira seção
		oSection1:Init()
	
		oReport:IncMeter()
	
		//IncProc("Imprimindo Filial " + Alltrim(TRBPED->C7_FILIAL) + " - " + AllTrim(FWFilialName(cEmpAnt,TRBPED->C7_FILIAL)))

		cQry2 := "SELECT C7_QUANT, C7_PRECO, C7_TOTAL, C7_VLDESC, C7_VALIPI, C7_ICMSRET "
		cQry2 += "FROM " + RetSqlName("SC7") + " SC7 "
		cQry2 += "JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
		cQry2 += "LEFT JOIN " + RetSqlName("SY1") + " SY1 ON Y1_FILIAL = '" + xFilial("SY1") + "' AND Y1_USER = C7_USER AND SY1.D_E_L_E_T_ = ' ' "
		cQry2 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
		cQry2 += "WHERE C7_FILIAL = '" + TRBPED->C7_FILIAL + "' "
		cQry2 += "  AND C7_NUM = '" + TRBPED->C7_NUM + "' "
		cQry2 += "  AND SC7.D_E_L_E_T_ = ' ' "

	    //==============================================
	    // Filtro por Posição de Pedidos de Compras
	    //==============================================
	    If MV_PAR14 == 4			//"Parc. Atendidos"
	       cQry2 += " AND C7_QUJE > 0 AND C7_QUANT > C7_QUJE "
	    EndIf

	    If MV_PAR15 = 1				//Pedidos COM RESIDUOS
	       cQry2 += " AND  C7_RESIDUO = 'S'  "
	    ElseIf MV_PAR15 = 2			//Pedidos SEM RESIDUOS
	       cQry2 += " AND  C7_RESIDUO <> 'S'  "
	    EndIf

		cQry2 += "ORDER BY C7_FILIAL, C7_NUM, C7_ITEM, C7_EMISSAO "
	
		If Select("TRBDAD") <> 0
			DbSelectArea("TRBDAD")
			DbCloseArea()
		EndIf
	
		TCQUERY cQry2 NEW ALIAS "TRBDAD"
		
		dbSelectArea("TRBDAD")
		TRBDAD->(dbGoTop())
		
		While !TRBDAD->(Eof())
			nQuant += TRBDAD->C7_QUANT
			nPreco += TRBDAD->C7_PRECO
			nTotal += TRBDAD->C7_TOTAL
			nVldes += TRBDAD->C7_VLDESC
			nVlIpi += TRBDAD->C7_VALIPI
			nVlIcm += TRBDAD->C7_ICMSRET
			TRBDAD->(dbSkip())
		End

		//imprimo a primeira seção
		oSection1:Cell("C7_FILIAL")	:SetValue(TRBPED->C7_FILIAL)
		oSection1:Cell("NOMEFIL")	:SetValue(AllTrim(FWFilialName(cEmpAnt,TRBPED->C7_FILIAL)))
		oSection1:Cell("C7_NUM")	:SetValue(TRBPED->C7_NUM)
		oSection1:Cell("C7_EMISSAO"):SetValue(StoD(TRBPED->C7_EMISSAO))
		oSection1:Cell("C7_I_DTFAT"):SetValue(StoD(TRBPED->C7_I_DTFAT))
		oSection1:Cell("C7_DATPRF")	:SetValue(StoD(TRBPED->C7_DATPRF))
		oSection1:Cell("A2_NREDUZ")	:SetValue(TRBPED->A2_NREDUZ)
		oSection1:Cell("Y1_NOME")	:SetValue(TRBPED->Y1_NOME)
		oSection1:Cell("C7_I_APLIC"):SetValue(TRBPED->C7_I_APLIC)
		oSection1:Cell("C7_GRUPCOM"):SetValue(TRBPED->C7_GRUPCOM)
		oSection1:Cell("C7_I_URGEN"):SetValue(TRBPED->C7_I_URGEN)
		oSection1:Cell("C7_I_CMPDI"):SetValue(TRBPED->C7_I_CMPDI)
		oSection1:Cell("TOTAL")		:SetValue(nTotal)
		oSection1:Cell("VLDESC")	:SetValue(nVldes)
		oSection1:Cell("VALIPI")	:SetValue(nVlIpi)
		oSection1:Cell("ICMSRET")	:SetValue(nVlIcm)
		oSection1:Cell("CONSNOTA")	:SetValue(U_RCOM011U(TRBPED->C7_FILIAL,TRBPED->C7_NUM))
		oSection1:Cell("CONSMSG")	:SetValue(U_RCOM011O(TRBPED->C7_FILIAL,TRBPED->C7_NUM))
		oSection1:Cell("C7_CC")     :SetValue(TRBPED->C7_CC)
		oSection1:Printline()

		nQuant := 0
		nPreco := 0
		nTotal := 0
		nVldes := 0
		nVlIpi := 0
		nVlIcm := 0

		TRBPED->(dbSkip())
	End
	oSection1:Finish()
	oSection1:Enable()
EndIf

Return

/*
===============================================================================================================================
Programa----------: RCOM011U
Autor-------------: Darcio R Sporl
Data da Criacao---: 22/03/2016
Descrição---------: Rotina que retorna a lista de NF vinculadas ao PC
Parametros--------: cFilPCx		- Filial do Pedido
------------------: cNumPCx		- Número do Pedido
------------------: cItemPCx	- Item do Pedido
Retorno-----------: cListaNF	- Retorna a lista com as NF's de cada pedido/item
===============================================================================================================================
*/
User Function RCOM011U(cFilPCx,cNumPCx,cItemPCx)
Local cListaNF		:= ""     
Local cQuery		:= ""

Default cFilPCx		:= ""
Default cNumPCx		:= ""
Default cItemPCx	:= ""

cQuery := "SELECT DISTINCT D1_DOC, D1_DTDIGIT "
cQuery += "FROM " + RetSqlName("SC7") + " C7 "
cQuery += "JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE C7.C7_FILIAL = '" + cFilPCx + "' "
cQuery += "  AND C7_NUM = '" + cNumPCx + "' "
If !Empty(cItemPCx)
	cQuery += "  AND C7_ITEM = '" + cItemPCx + "' "
EndIf
cQuery += "  AND C7.D_E_L_E_T_ = ' ' "
cQuery += "  AND C7.C7_QUJE <> 0 "
cQuery += "ORDER BY C7_FILIAL, C7_NUM " 

//===================================================================================
//Para que nao ocorra erro, quando duas pessoas acessarem o relatorio simultaneamente
//===================================================================================
If Select("TMPLSTNF") > 0 
	TMPLSTNF->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, cQuery ) , 'TMPLSTNF' , .F. , .T. )

DbSelectArea("TMPLSTNF")
TMPLSTNF->( DbGotop() )  

If !TMPLSTNF->(Eof())

	While !TMPLSTNF->(Eof())
	
		cListaNF += AllTrim( TMPLSTNF->D1_DOC ) + "-" + Alltochar(StoD(TMPLSTNF->D1_DTDIGIT)) + "; "
		TMPLSTNF->(dbSkip())
	End          
	
EndIf                

TMPLSTNF->(DBCloseArea())

Return( cListaNF )

/*
===============================================================================================================================
Programa----------: RCOM011O
Autor-------------: Darcio R Sporl
Data da Criacao---: 29/03/2016
Descrição---------: Função para retornar a Observação do pedido
Parametros--------: cFilEx - Filial do Pedido
------------------: cNumEx - Número do Pedido
Retorno-----------: cRet - Retorna a Observação do primeiro item do pedido
===============================================================================================================================
*/
User Function RCOM011O(cFilEx,cNumEx)
Local cRet	:= ""
Local cQry	:= ""

Default cFilEx	:= ""
Default cNumEx	:= ""

If !Empty(cFilEx) .And. !Empty(cNumEx)
	cQry := "SELECT C7_OBS "
	cQry += "FROM " + RetSqlName("SC7") + " C7 "
	cQry += "WHERE C7.C7_FILIAL = '" + cFilEx + "' "
	cQry += "  AND C7_NUM = '" + cNumEx + "' "
	cQry += "  AND C7.D_E_L_E_T_ = ' ' "
	cQry += "ORDER BY C7_FILIAL, C7_NUM " 

	//===================================================================================
	//Para que nao ocorra erro, quando duas pessoas acessarem o relatorio simultaneamente
	//===================================================================================
	If Select("TMPOBS") > 0 
		TMPOBS->( DBCloseArea() )
	EndIf

	DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, cQry ) , 'TMPOBS' , .F. , .T. )

	DbSelectArea("TMPOBS")
	TMPOBS->( DbGotop() )  

	If !TMPOBS->(Eof())
		cRet := AllTrim( TMPOBS->C7_OBS )
	EndIf                

	TMPOBS->(DBCloseArea())
EndIf

Return(cRet)
