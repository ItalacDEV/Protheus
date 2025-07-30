/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 02/05/2017 | Chamado 19813. Inclus�o da fun��o de Log ITLOGACS().
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  | 02/05/2017 | Chamado 33589. Inclus�o dos campos Endere�o, bairro, municipio, uf e CEP na impress�o.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 12/09/2024 | Chamado 48465. Removendo warning de compila��o.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa----------: REST009
Autor-------------: Darcio R Sporl
Data da Criacao---: 23/08/2016
===============================================================================================================================
Descri��o---------: Relat�rio Pallets Chep para clientes n�o cadastrados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function REST009()
Local oReport	:= nil
Private _cPerg	:= "REST009"
Private aOrd	:= {} 

If !Pergunte(_cPerg,.T.)
     return
EndIf

oReport := RptDef(_cPerg)
oReport:PrintDialog()

//========================================================================
// Grava log de Relat�rio Pallets Chep para clientes n�o cadastrados
//======================================================================== 
U_ITLOGACS('REST009')

Return

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Darcio R Sporl
Data da Criacao---: 23/08/2016
===============================================================================================================================
Descri��o---------: Fun��o que faz a montagem do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RptDef(cNome)
Local oReport	:= Nil
Local oSection1	:= Nil
	
oReport:= TReport():New("REST009","Relat�rio Pallets Chep.","REST009", {|oReport| ReportPrint(oReport)},"Emissao da Relacao dos Pallets Chep para Clientes n�o Cadastrados.")
oReport:SetLandscape()

oSection1 := TRSection():New(oReport, "Movimenta��es por Produto", {"TRBPAL"},aOrd , .F., .T.)
oSection1:SetTotalInLine(.T.)

TRCell():New(oSection1,"DATADOC"	,"TRBPAL","Data"				,"@D",10)
TRCell():New(oSection1,"TRANSP"		,"TRBPAL","Transportadora"		,"@!",50)
TRCell():New(oSection1,"MOTORI"		,"TRBPAL","Motorista"			,"@!",50)
TRCell():New(oSection1,"OCARGA"		,"TRBPAL","Ordem de Carga"		,"@!",10)
TRCell():New(oSection1,"NFISCA"		,"TRBPAL","Nota Fiscal"			,"@!",10)
TRCell():New(oSection1,"CLIENT"		,"TRBPAL","Cliente"				,"@!",50)
TRCell():New(oSection1,"END"		,"TRBPAL","Endere�o"			,"@!",50)
TRCell():New(oSection1,"BAIRRO"		,"TRBPAL","Bairro"				,"@!",50)
TRCell():New(oSection1,"MUN"		,"TRBPAL","Cidade"				,"@!",50)
TRCell():New(oSection1,"EST"		,"TRBPAL","UF"	    			,"@!",02)
TRCell():New(oSection1,"CEP"		,"TRBPAL","CEP"		    		,"@R 99999-999",09)

TRCell():New(oSection1,"QTDPAL"		,"TRBPAL","Qtde Pallets"  		,"@E 999,999,999.999",20)
TRCell():New(oSection1,"DATADEV"	,"TRBPAL","Data Devolu��o"		,"@D",10)
TRCell():New(oSection1,"QTDDEV"		,"TRBPAL","Qtde Devolvida"		,"@E 999,999,999.999",20)
TRCell():New(oSection1,"CDCHEP"		,"TRBPAL","Cod. Chep"			,"@!",10)
TRCell():New(oSection1,"CCHEP"		,"TRBPAL","Chep?"				,"@!",10)
TRCell():New(oSection1, "TOTSET"	,		 ,""					,"@E 999,999,999.999",20)

TRFunction():New(oSection1:Cell("QTDPAL")  ,NIL,"SUM",,"Total Carregado",/*cPicture*/,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("QTDDEV")  ,NIL,"SUM",,"Total Devolvido",/*cPicture*/,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("TOTSET")  ,NIL,"SUM",,"Saldo","@E 999,999,999.999"/*cPicture*/,{||oSection1:Cell("QTDPAL"):GetValue() - oSection1:Cell("QTDDEV"):GetValue()} /*uFormula*/,.F.,.T.)

Return(oReport)

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Darcio R Sporl
Data da Criacao---: 23/08/2016
===============================================================================================================================
Descri��o---------: Fun��o que imprime o relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)
Local cQry1		:= ""

cQry1 := "SELECT F2_FILIAL, F2_EMISSAO, F2_DOC, F2_SERIE, F2_I_CTRA, F2_I_LTRA, F2_I_NTRAN, F2_I_MOTOR, F2_I_NMOT, F2_CARGA, F2_CLIENTE, F2_LOJA, "
cQry1 += "       A1_NOME, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_I_CCHEP, A1_I_CHEP, D2_QUANT, D1_NFORI, D1_ITEMORI, D1_SERIORI, D1_EMISSAO, D1_QUANT "
cQry1 += "FROM " + RetSqlName("SF2") + " SF2 "
cQry1 += "JOIN " + RetSqlName("SD2") + " SD2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SD2.D_E_L_E_T_ = ' ' "
cQry1 += "JOIN " + RetSqlName("SB5") + " SB5 ON B5_FILIAL = '" + xFilial("SB5") + "' AND B5_COD = D2_COD AND B5_I_PALCH = 'S' AND SB5.D_E_L_E_T_ = ' ' "
cQry1 += "JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQry1 += "LEFT JOIN " + RetSqlName("SD1") + " SD1 ON D1_FILIAL = D2_FILIAL AND D1_NFORI = D2_DOC AND D1_SERIORI = D2_SERIE AND D1_ITEMORI = D2_ITEM AND SD1.D_E_L_E_T_ = ' ' "
cQry1 += "WHERE F2_FILIAL IN " + FormatIn( MV_PAR01 , ";" )
cQry1 += "  AND F2_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' "
cQry1 += "  AND F2_LOJA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' "
cQry1 += "  AND F2_DOC BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "
cQry1 += "  AND F2_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' "
cQry1 += "  AND F2_I_CTRA BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR12 + "' "
cQry1 += "  AND F2_I_LTRA BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR13 + "' "
If MV_PAR14 == 1
	cQry1 += "  AND F2_I_CLICH = 'S' "
ElseIf MV_PAR14 == 2
	cQry1 += "  AND F2_I_CLICH = 'N' "
ElseIf MV_PAR14 == 3
	cQry1 += "  AND (F2_I_CLICH = 'N' OR F2_I_CLICH = 'S') "
EndIf
cQry1 += "  AND SF2.D_E_L_E_T_ = ' ' "
cQry1 += "ORDER BY F2_FILIAL, F2_EMISSAO, F2_DOC, F2_SERIE "

If Select("TRBPAL") <> 0
	DbSelectArea("TRBPAL")
	DbCloseArea()
EndIf

TCQUERY cQry1 NEW ALIAS "TRBPAL"
		
TRBPAL->(dbGoTop())
		
oReport:SetMeter(TRBPAL->(LastRec()))

While !TRBPAL->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	oSection1:Init()
	
	oReport:IncMeter()
	
	IncProc("Imprimindo Documento " + AllTrim(TRBPAL->F2_DOC) + " - " + AllTrim(TRBPAL->F2_SERIE))

	oSection1:Cell("DATADOC")	:SetValue(StoD(TRBPAL->F2_EMISSAO))
	oSection1:Cell("TRANSP")	:SetValue(TRBPAL->F2_I_CTRA + "/" + TRBPAL->F2_I_LTRA + " - " + AllTrim(TRBPAL->F2_I_NTRAN))
	oSection1:Cell("MOTORI")	:SetValue(TRBPAL->F2_I_MOTOR + " - " + AllTrim(TRBPAL->F2_I_NMOT))
	oSection1:Cell("OCARGA")	:SetValue(TRBPAL->F2_CARGA)
	oSection1:Cell("NFISCA")	:SetValue(AllTrim(TRBPAL->F2_DOC) + " - " + AllTrim(TRBPAL->F2_SERIE))
	oSection1:Cell("CLIENT")	:SetValue(TRBPAL->F2_CLIENTE + "/" + TRBPAL->F2_LOJA + " - " + AllTrim(TRBPAL->A1_NOME))
    oSection1:Cell("END")	    :SetValue(TRBPAL->A1_END)
    oSection1:Cell("BAIRRO")	:SetValue(TRBPAL->A1_BAIRRO)
    oSection1:Cell("MUN")	    :SetValue(TRBPAL->A1_MUN)
    oSection1:Cell("EST")	    :SetValue(TRBPAL->A1_EST)
    oSection1:Cell("CEP")	    :SetValue(TRBPAL->A1_CEP)
	oSection1:Cell("QTDPAL")	:SetValue(TRBPAL->D2_QUANT)
	oSection1:Cell("DATADEV")	:SetValue(StoD(TRBPAL->D1_EMISSAO))
	oSection1:Cell("QTDDEV")	:SetValue(TRBPAL->D1_QUANT)
	oSection1:Cell("CDCHEP")	:SetValue(TRBPAL->A1_I_CCHEP)
	oSection1:Cell("CCHEP")		:SetValue(TRBPAL->A1_I_CHEP)
	
	oSection1:Printline()

	TRBPAL->(dbSkip())
End
	
oSection1:Finish()
oSection1:Enable()

Return
