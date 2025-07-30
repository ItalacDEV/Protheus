/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Walauer  |28/10/2022| Chamado 41709. Correcao do erro: variable is not an object. 
Alex Wallauer |08/02/2023| Chamado 42719. Acrescentada a opcao NF no campo C7_I_URGEN : S(SIM), N(NAO) F(NF).
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*
===============================================================================================================================
Programa----------: RCOM016
Autor-------------: Alex Wallauer
Data da Criacao---: 14/08/2019
===============================================================================================================================
Descri��o---------: Relacao de Pedidos Por Forncecedor - CHAMADO: 30238
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM016()
Local oReport:= NIL
Local _cPerg := "RCOM016"
Private _aItalac_F3:= {}
//Private aOrd	:= {"Fornecedor"} 
//Private aSelFil := {}
Private _aDadosF:= {}
_nTamChv:=LEN(SA2->A2_COD+SA2->A2_LOJA)

//FWMSGRUN(,{ |_oProc| _aDadosF:=RCOM016F(_oProc) },"Pr�-Processando...","Aguarde...")

_cSelectSB1:="SELECT B1_COD , B1_TIPO, B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ = ' ' ORDER BY B1_COD "
_bCondTab:={|| IF(EMPTY(MV_PAR06),.T.,B1_TIPO $ MV_PAR06) }

//Italac_F3:={}         1           2         3                        4                            5            6             7         8               9         10             11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave              , _nCpoDesc                   ,_bCondTab , _cTitAux      , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03",_cSelectSB1,{|Tab|(Tab)->B1_COD},{|Tab|(Tab)->B1_TIPO+" "+(Tab)->B1_DESC},_bCondTab,"Produtos",         ,          ,20        ,.F.        ,       , } )//Tipo: [PP,PI,MP,PA]
//AADD(_aItalac_F3,{"MV_PAR03","SB1", SB1->(FIELDPOS("B1_COD"))  , SB1->(FIELDPOS("B1_DESC"))  ,_bCondTab ,"Produtos"     ,          ,          ,20        ,.F.        ,       , } )//Tipo: [PP,PI,MP,PA]
AADD(_aItalac_F3,{"MV_PAR04","SY1",                              ,                             ,          ,"Compradores"  ,          ,          ,20                              } )
AADD(_aItalac_F3,{"MV_PAR05",     ,                              ,                             ,          ,"Fornecedores" , _nTamChv ,_aDadosF  ,20                              } )
//AADD(_aItalac_F3,{"MV_PAR05",_cSelSA2,{|Tab|(Tab)->A2_COD+(Tab)->A2_LOJA},{|Tab| (Tab)->A2_NREDUZ},     ,"Fornecedores" ,          ,          ,20        ,.F.        ,       , } )
//AADD(_aItalac_F3,{"MV_PAR05","SA2",{||SA2->A2_COD+SA2->A2_LOJA },SA2->(FIELDPOS("A2_NREDUZ")),          ,"Fornecedores" ,          ,          ,20} )

If !Pergunte(_cPerg,.T.)
   RETURN
EndIf

oReport := RCOM016D()
oReport:PrintDialog()

U_ITLOGACS( "RCOM016" )

Return

/*
===============================================================================================================================
Programa----------: RCOM016D
Autor-------------: Alex Wallauer
Data da Criacao---: 14/08/2019
===============================================================================================================================
Descri��o---------: Fun��o que faz a montagem do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM016D()
Local oReport	:= Nil
Local oSection1	:= Nil
Local oSection2	:= Nil
Local oSection3 := Nil
//Local oBreak
//Local oFunction
	
oReport:= TReport():New("RCOM016","Relacao de Pedidos Por Forncecedor","RCOM016", {|oReport| RCOM016R(oReport)},"Emissao da Relacao de Pedidos Por Forncecedor.")
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

//If MV_PAR13 == 1

	oSection1:= TRSection():New(oReport, "Analitico", {"TRBPED"}, , .F., .T.)

	TRCell():New(oSection1,"C7_FORNECE" ,"TRBPED","Cod."     		,"@!",10)
	TRCell():New(oSection1,"C7_LOJA"    ,"TRBPED","Loja"     		,"@!",05)
	TRCell():New(oSection1,"A2_NREDUZ"	,"TRBPED","Fornecedor"		,"@!",50)
	TRCell():New(oSection1,"C7_NUM"		,"TRBPED","Pedido"  		,"@!",10)  
	TRCell():New(oSection1,"C7_EMISSAO"	,"TRBPED","Emissao"			,"@D",10)
	TRCell():New(oSection1,"C7_TOTAL"	,"TRBDAD","Total"		    ,"@E 999,999,999.999",16)
	TRCell():New(oSection1,"C7_COMPRA"  ,"TRBPED","Cod."     		,"@!",10)
	TRCell():New(oSection1,"Y1_NOME"  	,"TRBPED","Comprador"		,"@!",50)
	TRCell():New(oSection1,"C7_I_APLIC"	,"TRBPED","Aplicacao"		,"@!",04)
	TRCell():New(oSection1,"C7_I_USOD"	,"TRBPED","Aplicacao Direta","@!",04)
	TRCell():New(oSection1,"C7_I_URGEN"	,"TRBPED","Urgente"			,"@!",04)
	TRCell():New(oSection1,"C7_I_CMPDI"	,"TRBPED","Compra Direta"	,"@!",04)
	TRCell():New(oSection1,"C7_ENCER"	,"TRBPED","Encerrado"		,"@!",04)

	oSection2:= TRSection():New(oReport, "Sintetico", {""}, NIL, .F., .T.)
	TRCell():New(oSection2,"C7_FORNECE" ,"TRBPED","Cod."     		,"@!",10)
	TRCell():New(oSection2,"C7_LOJA"    ,"TRBPED","Loja"     		,"@!",05)
	TRCell():New(oSection2,"A2_NREDUZ"	,"TRBPED","Fornecedor"		,"@!",50)
	TRCell():New(oSection2,"QTDE_PC"	,"TRBDAD","Quantidade PC"   ,"@E 999,999,999",16)
	TRCell():New(oSection2,"C7_TOTAL"	,"TRBDAD","Total"		    ,"@E 999,999,999.999",16)

	IF MV_PAR12 == 1
		oSection3 := TRSection():New(oReport, "Analitico - Item", {""}, NIL, .F., .T.)
		TRCell():New(oSection3,"C7_FORNECE" ,"","Cod."     		,"@!",10)
		TRCell():New(oSection3,"C7_LOJA"    ,"","Loja"     		,"@!",05)
		TRCell():New(oSection3,"A2_NREDUZ"	,"","Fornecedor"		,"@!",50)
		TRCell():New(oSection3,"C7_NUM"		,"","Pedido"  		,"@!",10)
		TRCell():New(oSection3,"C7_EMISSAO"	,"","Emissao"			,"@D",10)
		
		TRCell():New(oSection3,"C7_PRODUTO"	,"","Produto"  		,"@!",10)
		TRCell():New(oSection3,"C7_DESCRI"	,"","Descri��o"  		,"@!",50)
		TRCell():New(oSection3,"C7_ITEM"	,"","Item"  			,"@!",04)
		TRCell():New(oSection3,"C7_QUANT"	,"","Qtde"  			,"@E 999,999,999.999",16)
		TRCell():New(oSection3,"C7_PRECO"	,"","Pre�o Unit�rio"  ,"@E 999,999,999.999",16)
		TRCell():New(oSection3,"C7_TOTAL"	,"","Total"		    ,"@E 999,999,999.999",16)
		TRCell():New(oSection3,"C7_OBS"		,"","Obs"  		,"@!",50)

		TRCell():New(oSection3,"C7_COMPRA"  ,"","Cod."     		,"@!",10)
		TRCell():New(oSection3,"Y1_NOME"  	,"","Comprador"		,"@!",50)
		TRCell():New(oSection3,"C7_I_APLIC"	,"","Aplicacao"		,"@!",04)
		TRCell():New(oSection3,"C7_I_USOD"	,"","Aplicacao Direta","@!",04)
		TRCell():New(oSection3,"C7_I_URGEN"	,"","Urgente"			,"@!",04)
		TRCell():New(oSection3,"C7_I_CMPDI"	,"","Compra Direta"	,"@!",04)
		TRCell():New(oSection3,"C7_ENCER"	,"","Encerrado"		,"@!",04)
	ENDIF

Return(oReport)

/*
===============================================================================================================================
Programa----------: RCOM016R
Autor-------------: Alex Wallauer
Data da Criacao---: 14/08/2019
===============================================================================================================================
Descri��o---------: Fun��o que imprime o relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM016R(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := Nil
	Local cQry1		:= RCO16QRY()   , P
	Local cQry2		:= ""
	Local _cAlias	:= Nil

	IF MV_PAR12 == 1
		_cAlias	:= GetNextAlias()
		oSection3 := oReport:Section(3)
		cQry2	:= RCO16QRY(.T.)
		DBUseArea( .T. , "TOPCONN" , TCGenQry(,, cQry2 ) , _cAlias , .F. , .T. )
	ENDIF
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
	_nConta:=0
	aTotais:={}
	aPCs   :={}
	TRBPED->(dbGoTop())
	Count to _nConta
	oReport:SetMeter(_nConta)
	oSection1:Init()
	//IMPRIMO A PRIMEIRA SE��O
	TRBPED->(dbGoTop())
	DO While !TRBPED->(Eof())
        cAplic:=""
		If TRBPED->C7_I_APLIC == "C"
			cAplic := "Consumo"
		ElseIf TRBPED->C7_I_APLIC == "I"
			cAplic := "Investimento"
		ElseIf TRBPED->C7_I_APLIC == "M"
			cAplic := "Manutencao"
		ElseIf TRBPED->C7_I_APLIC == "S"
			cAplic := "Servico"
		EndIf
	
		oReport:IncMeter()
		oSection1:Cell("C7_FORNECE"):SetValue(TRBPED->C7_FORNECE)
		oSection1:Cell("C7_LOJA")   :SetValue(TRBPED->C7_LOJA)
		oSection1:Cell("A2_NREDUZ")	:SetValue(TRBPED->A2_NREDUZ)
		oSection1:Cell("C7_NUM")	:SetValue(TRBPED->C7_NUM)
		oSection1:Cell("C7_EMISSAO"):SetValue(StoD(TRBPED->C7_EMISSAO))
		oSection1:Cell("C7_TOTAL")  :SetValue(TRBPED->C7_TOTAL)
		oSection1:Cell("C7_COMPRA") :SetValue(TRBPED->C7_COMPRA)
		oSection1:Cell("Y1_NOME")	:SetValue(TRBPED->Y1_NOME)
		oSection1:Cell("C7_I_APLIC"):SetValue(cAplic)
		oSection1:Cell("C7_I_URGEN"):SetValue(IF(TRBPED->C7_I_URGEN="S","SIM",IF(TRBPED->C7_I_URGEN="F","NF","N�O")))
		oSection1:Cell("C7_I_USOD") :SetValue(IF(TRBPED->C7_I_USOD ="S","Sim","Nao"))
		oSection1:Cell("C7_I_CMPDI"):SetValue(IF(TRBPED->C7_I_CMPDI="S","Sim","Nao"))
		oSection1:Cell("C7_ENCER")  :SetValue(IF(TRBPED->C7_ENCER  =" ","Nao","Sim"))
		
		oSection1:Printline()
		
		IF (nPos:=ASCAN(aTotais,{|F| F[1] == TRBPED->C7_FORNECE+TRBPED->C7_LOJA} )) = 0
		   AADD(aTotais,{TRBPED->C7_FORNECE+TRBPED->C7_LOJA,;//1
		                 TRBPED->C7_FORNECE,;                //2
		                 TRBPED->C7_LOJA,;                   //3 
		                 TRBPED->A2_NREDUZ,;                 //4
		                 0,0})                               //5,6
		   nPos:=LEN(aTotais)
		ENDIF           
		IF ASCAN(aPCs,TRBPED->C7_NUM) = 0// PARA N�O CONTAR O PC MAIS DE MA VEZ
		   aTotais[nPos,5]++
		   AADD(aPCs,TRBPED->C7_NUM)
		ENDIF   
	    aTotais[nPos,6]+=TRBPED->C7_TOTAL
  
		TRBPED->(dbSkip())
	End

    aTotais2:={0,0,0}
	oReport:SetMeter(LEN(aTotais))
	//inicializo a segunda se��o
	oSection2:init()
	FOR P := 1 TO LEN(aTotais)

		oReport:IncMeter()

		oSection2:Cell("C7_FORNECE"):SetValue(aTotais[P,2])
		oSection2:Cell("C7_LOJA")   :SetValue(aTotais[P,3])
		oSection2:Cell("A2_NREDUZ")	:SetValue(aTotais[P,4])
		oSection2:Cell("QTDE_PC")	:SetValue(aTotais[P,5])
		oSection2:Cell("C7_TOTAL")	:SetValue(aTotais[P,6])
		oSection2:Printline()

		aTotais2[1]++
		aTotais2[2]+=aTotais[P,5]
		aTotais2[3]+=aTotais[P,6]
	
    NEXT

	oSection2:Cell("C7_FORNECE"):SetValue("TOTAIS")
	oSection2:Cell("C7_LOJA")   :SetValue("")
	oSection2:Cell("A2_NREDUZ")	:SetValue(ALLTRIM(STR(aTotais2[1]))+" Fornecedores" )
	oSection2:Cell("QTDE_PC")	:SetValue(aTotais2[2])
	oSection2:Cell("C7_TOTAL")	:SetValue(aTotais2[3])
	oSection2:Printline()

	IF MV_PAR12 == 1
		(_cAlias)->(dbGoTop())
		Count to _nConta
		oReport:SetMeter(_nConta)
		oSection3:init()
		WHILE (_cAlias)->(!EOF())

			cAplic:=""
			If TRBPED->C7_I_APLIC == "C"
				cAplic := "Consumo"
			ElseIf TRBPED->C7_I_APLIC == "I"
				cAplic := "Investimento"
			ElseIf TRBPED->C7_I_APLIC == "M"
				cAplic := "Manutencao"
			ElseIf TRBPED->C7_I_APLIC == "S"
				cAplic := "Servico"
			EndIf

			oReport:IncMeter()
			oSection3:Cell("C7_FORNECE"):SetValue((_cAlias)->C7_FORNECE)
			oSection3:Cell("C7_LOJA")   :SetValue((_cAlias)->C7_LOJA)
			oSection3:Cell("A2_NREDUZ")	:SetValue((_cAlias)->A2_NREDUZ)
			oSection3:Cell("C7_NUM")	:SetValue((_cAlias)->C7_NUM)
			oSection3:Cell("C7_EMISSAO"):SetValue(StoD((_cAlias)->C7_EMISSAO))

			oSection3:Cell("C7_PRODUTO")	:SetValue((_cAlias)->C7_PRODUTO)
			oSection3:Cell("C7_DESCRI")	:SetValue((_cAlias)->C7_DESCRI)
			oSection3:Cell("C7_ITEM")	:SetValue((_cAlias)->C7_ITEM)
			oSection3:Cell("C7_QUANT")	:SetValue((_cAlias)->C7_QUANT)
			oSection3:Cell("C7_PRECO")	:SetValue((_cAlias)->C7_PRECO)
			oSection3:Cell("C7_TOTAL")  :SetValue((_cAlias)->C7_TOTAL)
			oSection3:Cell("C7_OBS")	:SetValue((_cAlias)->C7_OBS)

			oSection3:Cell("C7_COMPRA") :SetValue((_cAlias)->C7_COMPRA)
			oSection3:Cell("Y1_NOME")	:SetValue((_cAlias)->Y1_NOME)
			oSection3:Cell("C7_I_APLIC"):SetValue(cAplic)
			oSection3:Cell("C7_I_URGEN"):SetValue(IF((_cAlias)->C7_I_URGEN="S","Sim","Nao"))
			oSection3:Cell("C7_I_USOD") :SetValue(IF((_cAlias)->C7_I_USOD ="S","Sim","Nao"))
			oSection3:Cell("C7_I_CMPDI"):SetValue(IF((_cAlias)->C7_I_CMPDI="S","Sim","Nao"))
			oSection3:Cell("C7_ENCER")  :SetValue(IF((_cAlias)->C7_ENCER  =" ","Nao","Sim"))
			oSection3:Printline()
			(_cAlias)->(dbSkip())
		ENDDO

	ENDIF
    
	oSection1:Finish()
	oSection2:Finish()
    IF MV_PAR12 == 1
	   oSection3:Finish()
	ENDIF

Return

/*
===============================================================================================================================
Programa----------: RCOM016F
Autor-------------: Alex Wallauer
Data da Criacao---: 01/09/2019
===============================================================================================================================
Descri��o---------: Carga dos dos dados do forncedor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM016F(_oProc)
//LOCAL _cTabela:="SA2"

lRet := ConPad1(,,,"NNR",,,.F.)

RETURN lRet

/*
===============================================================================================================================
Programa----------: RCO16QRY
Autor-------------: Jonathan Torioni
Data da Criacao---: 10/09/2020
===============================================================================================================================
Descri��o---------: Retorna query
===============================================================================================================================
Parametros--------: lItem - Identifica se a query � para o Analitico - Itens (Section3)
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCO16QRY(lItem)
	Local _cQuery := ""
	DEFAULT lItem := .F.

	IF !lItem
		_cQuery := "SELECT  SUM(C7_TOTAL) C7_TOTAL,"
	ELSE
		_cQuery := "SELECT C7_TOTAL,"
	ENDIF
	_cQuery += "        C7_NUM    , C7_EMISSAO, C7_COMPRA ,"
	_cQuery += "        C7_I_APLIC, C7_ENCER  ,"
	_cQuery += "        C7_I_URGEN, "
	_cQuery += "        C7_I_CMPDI, "
	_cQuery += "        C7_I_USOD,  "
	_cQuery += "        C7_FORNECE, "
	_cQuery += "        C7_LOJA   , "
	_cQuery += "        A2_NREDUZ , "
	IF lItem
		_cQuery += "	C7_PRODUTO, "
		_cQuery += "	C7_ITEM, 	"
		_cQuery += "	C7_QUANT, 	"
		_cQuery += "	C7_PRECO, 	"
		_cQuery += "	C7_DESCRI, 	"
		_cQuery += "	C7_OBS, 	"

	ENDIF
	_cQuery += "        Y1_NOME     "
	_cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
	_cQuery += "      JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	_cQuery += " LEFT JOIN " + RetSqlName("SY1") + " SY1 ON Y1_FILIAL = '" + xFilial("SY1") + "' AND Y1_COD = C7_COMPRA  AND SY1.D_E_L_E_T_ = ' ' "
	IF !EMPTY(MV_PAR06)
	   _cQuery += "   JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
	ENDIF
	_cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "

	//Filtra DATA EMISSAO
    IF !EMPTY(MV_PAR02)
       _cQuery += "  AND C7_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
    ELSEIF !EMPTY(MV_PAR01) 
       _cQuery += "  AND C7_EMISSAO >= '" + DTOS(MV_PAR01) + "'"
    ENDIF

	//Filtra produto
	If !Empty(MV_PAR03)
	    _cQuery += " AND C7_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR03),";")
	EndIf

	//Filtra comprador
	If !Empty(MV_PAR04)
	    _cQuery += " AND C7_COMPRA IN "+FormatIn(ALLTRIM(MV_PAR04),";")
	EndIf

	//Filtra Fonecedor
	If !Empty(MV_PAR05)
	    _cQuery += " AND C7_FORNECE||C7_LOJA  IN "+FormatIn(ALLTRIM(MV_PAR05),";")
	EndIf

	If !Empty(MV_PAR06)
	    _cQuery += " AND B1_TIPO IN "+FormatIn(ALLTRIM(MV_PAR06),";")
	EndIf

	//Filtra URGENTE
	If MV_PAR07 == 1				//Sim
		_cQuery += " AND C7_I_URGEN = 'S' "
	ElseIf MV_PAR07 == 2			//Nao
		_cQuery += " AND C7_I_URGEN = 'N' "
	ElseIf MV_PAR07 == 3			//NF
		_cQuery += " AND C7_I_URGEN = 'F' "
	EndIf

	// Tratamento da clausula da APLICACAO DIRETA
	If MV_PAR08 == 1				//Sim
		_cQuery += " AND C7_I_USOD = 'S' "
	ElseIf MV_PAR08 == 2			//Nao 
		_cQuery += " AND C7_I_USOD = 'N' "
	EndIf

	// Tratamento da clausula da COMPRA DIRETA
	If MV_PAR09 == 1				//Sim
		_cQuery += " AND C7_I_CMPDI = 'S' "
	ElseIf MV_PAR09 == 2			//Nao 
		_cQuery += " AND C7_I_CMPDI = 'N' "
	EndIf

	// Filtro por Posi��o de Pedidos de Compras PEDIDOS ATENDIDOS
	If MV_PAR10 == 1				//Pedidos Atendidos
	   _cQuery += " AND C7_ENCER <> ' ' "
	ElseIf MV_PAR10 == 2			//Pedidos N�o Atendidos
       _cQuery += " AND C7_ENCER  = ' ' "
	EndIf

	//Tratamento da clausula where da APLICACAO
	If MV_PAR11 == 1				//Consumo
		_cQuery += " AND C7_I_APLIC = 'C' "
	ElseIf MV_PAR11 == 2			//Investimento
		_cQuery += " AND C7_I_APLIC = 'I' "
	ElseIf MV_PAR11 == 3			//Manuten��o
		_cQuery += " AND C7_I_APLIC = 'M' "
	ElseIf MV_PAR11 == 4			//Servi�o
		_cQuery += " AND C7_I_APLIC = 'S' "
	EndIf
	
	_cQuery += "  AND SC7.D_E_L_E_T_ = ' ' "

	IF !lItem
		_cQuery += "GROUP BY 
		_cQuery += "        C7_NUM    , C7_EMISSAO, C7_COMPRA ,"
		_cQuery += "        C7_I_APLIC, C7_ENCER  ,"
		_cQuery += "        C7_I_URGEN, "
		_cQuery += "        C7_I_CMPDI, "
		_cQuery += "        C7_I_USOD,  "
		_cQuery += "        C7_FORNECE, "
		_cQuery += "        C7_LOJA   , "
		_cQuery += "        A2_NREDUZ , "
		_cQuery += "        Y1_NOME     "
	ENDIF

	IF lItem
		_cQuery += " ORDER BY "
		_cQuery += " A2_NREDUZ, "
		_cQuery += " C7_NUM, "
		_cQuery += " C7_ITEM "
	ELSE
		_cQuery += "ORDER BY A2_NREDUZ  "
	ENDIF

RETURN _cQuery
