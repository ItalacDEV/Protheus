/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |13/07/2023| Chamado 44351. Correção de error.log da variavel nPosC.
Julio Paz     |20/08/2024| Chamado 48228. Incluir uma nova coluna para informar o grupo de produtos.
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*
===============================================================================================================================
Programa----------: REST010
Autor-------------: Alex Wallauer
Data da Criacao---: 23/05/2017
===============================================================================================================================
Descrição---------: Relatório de baixas consolidadas do almoxarifado - CHAMADO 20155
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function REST010()
Local oReport	:= nil
	Private _cPerg	:= "REST010"
Private aOrd	:= {} 

DO WHILE .T.

   If !Pergunte(_cPerg,.T.)
      return .f.
   EndIf

   IF MV_PAR01 > MV_PAR02
      MSGSTOP("Periodo de datas invalido.")
      LOOP
   ENDIF
   
   IF MV_PAR04 > MV_PAR05
      MSGSTOP("Periodo de produtos invalido.")
      LOOP
   ENDIF
   
   IF MV_PAR06 > 12
      MSGSTOP("Media retroativa maior que 12 meses.")
      LOOP
   ENDIF
   
   EXIT
   
ENDDO

oReport := RptDef(_cPerg)
oReport:PrintDialog()  

//========================================================================
// Grava log de Relatório de Relatório Clientes com Contrato.
//======================================================================== 
U_ITLOGACS('REST010')

Return

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Alex Wallauer
Data da Criacao---: 23/05/2017
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
//Local bReport :={|oReport| FWMSGRUN( , {|oProc|  ReportPrint(oReport,oProc)}, "Aguarde!" , 'Lendo Dados...' ) }
Local bReport   :={|oReport| ReportPrint(oReport,) }
	
oReport:= TReport():New("REST010","Relatório de baixas consolidadas do almoxarifado.","REST010", bReport ,"Baixas consolidadas do almoxarifado.")

oReport:SetLandscape()

oSection1 := TRSection():New(oReport, "Movimentações por Produto", {"TRB"},aOrd , .F., .T.)

	TRCell():New(oSection1,"PRODUTO"	,"TRB","Produto"  		    ,"@!",50) // 100
	TRCell():New(oSection1,"GRUPO"	    ,"TRB","Grupo"  		    ,"@!",25)
	TRCell():New(oSection1,"DESCR"	    ,"TRB","Descrição " 	    ,"@!",100)
	TRCell():New(oSection1,"DESCR_DET" 	,"TRB","Descrição Detalhada","@!",100)
	TRCell():New(oSection1,"TOTSAIDA"   ,"TRB","Total Saida"   		,"@E 99999,999,999.9999",20) // 25
	TRCell():New(oSection1,"MEDIA"  	,"TRB","Media "+ALLTRIM(STR(MV_PAR06))+" Meses","@E 99999,999,999.9999",20) // 25
	TRCell():New(oSection1,"LOCAL"      ,"TRB","Localização"		,"@!",50)
	TRCell():New(oSection1,"ESTSEG"     ,"TRB","Est. Mínimo"		,PesqPict( "SBZ", "BZ_ESTSEG" ),50)
	TRCell():New(oSection1,"EMAX"       ,"TRB","Est. Máximo"		,PesqPict( "SBZ", "BZ_EMAX"   ),50)
	IF MV_PAR08 = 1
		TRCell():New(oSection1, "BZ_PE"     ,"TRB","Lead Time"          ,PesqPict( "SBZ", "BZ_PE     "),50)//VALIDAR SOMENTE SE O MV_PAR08 == 1 - SIM
	ENDIF
	TRCell():New(oSection1,"PRCUNIT"	,"TRB","Custo Unit."		,PesqPict( "SB2", "B2_CM1" ),20) //25
	TRCell():New(oSection1,"VLRTOTAL"	,"TRB","Saldo atual"		,"@E 99999,999,999.9999",20) // 25
	TRCell():New(oSection1,"QTDE_TOT"	,"TRB","Qtde em PC" 		,"@E 99999,999,999.9999",20) // 25
	TRCell():New(oSection1,"QTDE_ABE"	,"TRB","Qtde Aberta SC" 	,"@E 99999,999,999.9999",20) // 25
	TRCell():New(oSection1,"CENTROC"    ,"TRB","Centro de Custo"	,"@!",50)
	TRCell():New(oSection1,"ULT_DATA"   ,"TRB","Ultima Data"	    ,"@D",10)
	IF MV_PAR08 = 1
		TRCell():New(oSection1,"STATUS"     ,"TRB","Status"         ,"@!",100)
		TRCell():New(oSection1,"QTDSUG"     ,"TRB","Qtde Sugerida"  ,"@E 99,999,999.999",25)
	ENDIF


oSection2 := TRSection():New(oReport, "Movimentações por CC", {"TRB"},aOrd , .F., .T.)

	TRCell():New(oSection2,"COD_CC"     ,"TRB","Codigo CC"			,"@!",50)
	TRCell():New(oSection2,"CENTROC"    ,"TRB","Centro de Custo"	,"@!",50)
	TRCell():New(oSection2,"TOTSAIDA"   ,"TRB","Total Saida"   		,"@E 9,9999,999,999.9999",50)
	TRCell():New(oSection2,"CUSTOTOT"   ,"TRB","Custo Total"   		,"@E 9,9999,999,999.9999",50)


Return(oReport)

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Alex Wallauer
Data da Criacao---: 23/05/2017
===============================================================================================================================
Descrição---------: Função que imprime o relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,oProc)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local cQryMedia := ""//MEDIA
Local cQryData  := ""//SOMATORIA
Local cQryRec   := ""
Local cQryUDT   := ""
Local cQry		:= ""//=
Local cQryM		:= ""//MEDIA
Local cQryS		:= ""//SOMATORIA
Local cQryOrdem := ""//=
LOCAL S2
Local nResult := 0
Local nQtdSug := 0

oSection1:Init()
oReport:SetMeter(0)

BEGIN SEQUENCE
	
    oReport:IncMeter()

 	cQry += " FROM " + RetSqlName("SD3") + " D3 "
	cQry += "WHERE D3.D_E_L_E_T_ = ' ' AND D3.D3_TM = '560' AND D3_ESTORNO <> 'S' AND D3.D3_FILIAL = '"+xFilial("SD3")+"' "

  	If !Empty(MV_PAR04)
	   cQry += "  AND D3_COD >= '" + ALLTRIM(MV_PAR04) + "' "
    ENDIF

  	If !Empty(MV_PAR05)
	   cQry += "  AND D3_COD <= '" + ALLTRIM(MV_PAR05) + "' "
    ENDIF

	If !Empty(MV_PAR07)
		cQry += "  AND D3.D3_LOCAL IN " + FormatIn( ALLTRIM(MV_PAR07) , ";" )
	EndIf

	If !Empty(MV_PAR03)
		cQry += "  AND D3.D3_GRUPO IN " + FormatIn( ALLTRIM(MV_PAR03) , ";" )
 	EndIf

    oReport:SetMsgPrint("1/9-Lendo dados da SD3...")
//******************  MEDIA
	If Select("TRB") <> 0
	   TRB->(DbCloseArea())
	EndIf

	cQryMedia  := "SELECT D3.D3_FILIAL , D3.D3_COD , D3.D3_LOCAL, D3.D3_GRUPO , SUM(D3_QUANT) MEDIA "//MEDIA  
    //_dDAtaIncio:=(MV_PAR01 - (MV_PAR06*30))
    _dDAtaIncio:= DATE() - (MV_PAR06*30) //Alteração solicitada pelo Coordenador geral dos almoxarifados 32048.
	cQryM      := " AND D3.D3_EMISSAO BETWEEN '" + DtoS(_dDAtaIncio) + "' AND '" + DtoS(DATE()) + "' "//MEDIA
  	cQryOrdem  := " GROUP BY D3.D3_FILIAL , D3.D3_COD , D3.D3_LOCAL, D3.D3_GRUPO  " 
  	cQryOrdem  += " ORDER BY D3.D3_FILIAL , D3.D3_COD , D3.D3_LOCAL "
	
	TCQUERY cQryMedia + cQry + cQryM + cQryOrdem  NEW ALIAS "TRB"//MEDIA

    oReport:SetMsgPrint("2/9-Lendo dados da Media...")
    _nTot:=0
    COUNT TO _nTot
  	oReport:SetMeter(_nTot)
    _cTot:=ALLTRIM(STR(_nTot))
    _nTam:=LEN(_cTot)+1
    _nConta:=0
    TRB->(dbGoTop())
    _aMedia:={}
   	DO While !TRB->(Eof())
       _nConta++
       oReport:IncMeter()
       oReport:SetMsgPrint("3/9-Acumulando Media: "+ALLTRIM(STR(_nConta,_nTam)) +" de "+ _cTot)
   	   AADD(_aMedia,{TRB->D3_FILIAL+TRB->D3_COD+TRB->D3_LOCAL,;//1
   	                                    (TRB->MEDIA/MV_PAR06),;//2
   	                                               TRB->MEDIA,;//3
   	                                                      " ",;//4
   	                                                      " "})//5
	   TRB->(dbSkip())
	ENDDO
		
//******************  MAIOR DATA
    oReport:SetMsgPrint("4/9-Lendo dados da SD3 para Media...")

	If Select("TRB") <> 0
	   TRB->(DbCloseArea())
	EndIf
	
	cQryData:= "SELECT D3.D3_FILIAL , D3.D3_COD , D3.D3_LOCAL, D3.D3_GRUPO, MAX(D3.D3_EMISSAO) ULTDATA "//ULTIMA DATA  
	cQryS   := "  AND D3.D3_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "//UTILIZADO A SOMATORIA E MAIOR DATA

	TCQUERY cQryData + cQry + cQryS + cQryOrdem  NEW ALIAS "TRB"//MAIOR DATA

	_nTot:=0
    COUNT TO _nTot
  	oReport:SetMeter(_nTot)

    cQryRec := "SELECT D3.D3_FILIAL , D3.D3_COD , D3.D3_LOCAL, D3.D3_GRUPO, MAX(D3.R_E_C_N_O_) REC_SD3 "//ULTIMO CC DENTRO DA MAIOR DATA

    _cTot:=ALLTRIM(STR(_nTot))
    _nTam:=LEN(_cTot)+1
    _nConta:=0

    TRB->(dbGoTop())
   	DO While !TRB->(Eof())

       _nConta++
  	   oReport:IncMeter()
       oReport:SetMsgPrint("5/9-Lendo Media, Registro: "+ALLTRIM(STR(_nConta,_nTam)) +" de "+ _cTot)
     //******************  MAIOR REC
	   cQryUDT := " AND D3.D3_EMISSAO = '" + TRB->ULTDATA + "' "
	   cQryUDT += " AND D3.D3_FILIAL||D3.D3_COD||D3.D3_LOCAL = '"+TRB->D3_FILIAL+TRB->D3_COD+TRB->D3_LOCAL+"' "
	   TCQUERY cQryRec + cQry + cQryUDT + cQryOrdem  NEW ALIAS "TRB_REC"//MAIOR RECNO  TRAZ  O ULTIMO CC UTILIZADO

	   IF TRB_REC->REC_SD3 # 0 .AND. (nPosC := nPos:=ASCAN(_aMedia, {|M| M[1] == TRB->D3_FILIAL+TRB->D3_COD+TRB->D3_LOCAL } )) # 0 
	       SD3->(DBGOTO(TRB_REC->REC_SD3))
	      _aMedia[nPos,4]:=SD3->D3_CC
	      _aMedia[nPos,5]:=SD3->D3_EMISSAO
	   ENDIF

	   TRB_REC->(DbCloseArea())
    //******************  MAIOR REC

	   DBSELECTAREA("TRB")

	   TRB->(dbSkip())
	ENDDO
		
//******************  SOMATORIA
	If Select("TRB") <> 0
	   TRB->(DbCloseArea())
	EndIf
    oReport:SetMsgPrint("6/9-Lendo dados da SD3 de Custo...")

	cQrySoma:= "SELECT D3.D3_FILIAL , D3.D3_COD , D3.D3_LOCAL, D3.D3_GRUPO, SUM(D3_QUANT) TOTSAIDA, SUM(D3_CUSTO1) CUSSAIDA "//SOMATORIA

	TCQUERY cQrySoma+cQry+cQryS+cQryOrdem NEW ALIAS "TRB"//SOMATORIA

	SBZ->( DBSetOrder(6) )
	SB2->( DBSetOrder(1) )

	cQry1 := "SELECT SUM(C7_QUANT) - SUM(C7_QUJE) QTD_TOT "
	cQry1 += "FROM " + RetSqlName("SC7") + " C7 "
	cQry1 += "WHERE C7.D_E_L_E_T_ = ' ' "
	cQry1 += "  AND C7_RESIDUO = ' ' "
	cQry1 += "  AND C7_ENCER = ' ' "
	cQry1 += "  AND C7.C7_FILIAL = '"+xFilial("SC7")+"' "
	If !Empty(MV_PAR07)
		cQry1 += "  AND C7.C7_LOCAL IN " + FormatIn( ALLTRIM(MV_PAR07) , ";" )
	EndIf

    _cQuerySC := " SELECT SUM(C1_QUANT) QTD_TOT  "
    _cQuerySC += "        FROM " + RETSQLNAME("SC1") + " C1 "
    _cQuerySC += "        WHERE C1_FILIAL= '"+xFilial("SC1")+"' AND  C1_PEDIDO = ' ' AND D_E_L_E_T_ = ' ' AND C1_RESIDUO <> 'S' AND C1_QUANT > C1_QUJE "
	If !Empty(MV_PAR07)
		_cQuerySC += "  AND C1.C1_LOCAL IN " + FormatIn( ALLTRIM(MV_PAR07) , ";" )
	EndIf

	_nTot:=0
    COUNT TO _nTot
  	oReport:SetMeter(_nTot)
    _cTot:=ALLTRIM(STR(_nTot))
    _nTam:=LEN(_cTot)+1
    _nConta:=0

	TRB->(dbGoTop())
	_aCustos:={}
    aAbertosSC:={}
    aAbertosPC:={}
		
	DO While !TRB->(Eof())
       _nConta++
  	   oReport:IncMeter()
       oReport:SetMsgPrint("7/9-Imprimindo Produto "+ALLTRIM(STR(_nConta,_nTam)) +" de "+ _cTot)

	    SBZ->( DBSeek( TRB->D3_FILIAL + TRB->D3_COD + TRB->D3_LOCAL) )
	    SB2->( DBSeek( TRB->D3_FILIAL + TRB->D3_COD + TRB->D3_LOCAL) )

		oSection1:Cell("PRODUTO")  :SetValue(TRB->D3_COD)
		oSection1:Cell("GRUPO")    :SetValue(TRB->D3_GRUPO)      
		oSection1:Cell("DESCR")    :SetValue(SBZ->BZ_I_DESCR)		
		oSection1:Cell("DESCR_DET"):SetValue(SBZ->BZ_I_DETPR)
		oSection1:Cell("LOCAL")    :SetValue(SBZ->BZ_I_LOCAL)
		oSection1:Cell("ESTSEG")   :SetValue(SBZ->BZ_ESTSEG)
		oSection1:Cell("EMAX")     :SetValue(SBZ->BZ_EMAX)
		oSection1:Cell("TOTSAIDA") :SetValue(TRB->TOTSAIDA)
		IF MV_PAR08 = 1
			oSection1:Cell("BZ_PE"):SetValue(SBZ->BZ_PE)
		ENDIF
		IF (nPosD := nPos:=ASCAN(_aMedia, {|M| M[1] == TRB->D3_FILIAL+TRB->D3_COD+TRB->D3_LOCAL } )) # 0 
		   oSection1:Cell("MEDIA")   :SetValue( _aMedia[nPos,2] )	   
//		   oSection1:Cell("TOTMEDIA"):SetValue( _aMedia[nPos,3] )//PARA TESTES
		   oSection1:Cell("CENTROC") :SetValue( Posicione("CTT",1,xFilial("CTT")+_aMedia[nPos,4],"CTT_DESC01") )
		   oSection1:Cell("ULT_DATA"):SetValue( _aMedia[nPos,5] )
		ENDIF
		oSection1:Cell("PRCUNIT") :SetValue(SB2->B2_CM1)
		oSection1:Cell("VLRTOTAL"):SetValue(SB2->B2_QATU)

        IF (nPosA := nPos:=ASCAN(aAbertosPC,{|A| A[1]==TRB->D3_COD } )) > 0
		   oSection1:Cell("QTDE_TOT"):SetValue(aAbertosPC[nPos,2])
		ELSE
		   nPosA := nPos:=MTLista(TRB->D3_COD,.T.)
		   oSection1:Cell("QTDE_TOT"):SetValue(aAbertosPC[nPos,2])
		ENDIF   

        IF (nPosB := nPos:=ASCAN(aAbertosSC,{|A| A[1]==TRB->D3_COD } )) > 0
		   oSection1:Cell("QTDE_ABE"):SetValue(aAbertosSC[nPos,2])
		ELSE
		   nPosB := nPos:=MTLista(TRB->D3_COD,.F.)
		   oSection1:Cell("QTDE_ABE"):SetValue(aAbertosSC[nPos,2])
		ENDIF

		IF MV_PAR08 = 1 
		
		    IF (nPosC:=ASCAN(_aMedia, {|M| M[1] == TRB->D3_FILIAL+TRB->D3_COD+TRB->D3_LOCAL } ) ) > 0
			    nResult := (TRB->TOTSAIDA/_aMedia[nPosC,2])*SBZ->BZ_PE //(MED CONSUMO/PERIODO)*LEADTIME			
			ELSE
			    nResult := 0
			ENDIF
			IF (nResult > 0 .AND. SBZ->BZ_ESTSEG = 0 ) 
				oSection1:Cell("QTDSUG")    :SetValue(nQtdSug)
				oSection1:Cell("STATUS")   :SetValue("REVALIDAR ESTOQUE MINIMO")
			ELSEIF SB2->B2_QATU > SBZ->BZ_EMAX //ESTOQUE ATUAL > ESTOQUE MAXIMO
				oSection1:Cell("QTDSUG")    :SetValue(nQtdSug)
				oSection1:Cell("STATUS")  :SetValue("REVALIDAR ESTOQUE MAXIMO")
			ELSEIF (SB2->B2_QATU < (IIF(nPosA <> 0,aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0,aAbertosSC[nPosB,2],0) +  SBZ->BZ_ESTSEG)) ;
			  .OR. (SB2->B2_QATU = (SBZ->BZ_ESTSEG + IIF(nPosA <> 0, aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0, aAbertosSC[nPosB,2],0)) ;
			  .AND. SBZ->BZ_PE > 45)//(ESTOQUE ATUAL < (ESTOQUE MIN E SOMA DE PC E SC EM ABERTO), ESTOQUE ATUAL = ESTOQUE MIN E PC+SC = 0 E LEADTIME > 45
				//.AND. (DATE() - CTOD(_aMedia[nPosD,5])) >= SBZ->BZ_PE
				oSection1:Cell("STATUS")   :SetValue("REPOR ESTOQUE")
				nQtdSug := SBZ->BZ_ESTSEG - (IIF(nPosA <> 0,aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0,aAbertosSC[nPosB,2],0) + SB2->B2_QATU)
				IF nQtdSug > 0
					oSection1:Cell("QTDSUG")    :SetValue(nQtdSug)
				ELSEIF nQtdSug <= 0
					IF (IIF(nPosA <> 0,aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0,aAbertosSC[nPosB,2],0) + SB2->B2_QATU) >= SBZ->BZ_ESTSEG .AND. (IIF(nPosA <> 0,aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0,aAbertosSC[nPosB,2],0) + SB2->B2_QATU) <= SBZ->BZ_EMAX
						oSection1:Cell("QTDSUG")    :SetValue(0)
						oSection1:Cell("STATUS")   :SetValue("OK")
					ELSEIF (IIF(nPosA <> 0,aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0,aAbertosSC[nPosB,2],0) + SB2->B2_QATU) >= SBZ->BZ_EMAX
						oSection1:Cell("QTDSUG")    :SetValue(0)
						oSection1:Cell("STATUS")  :SetValue("REVALIDAR ESTOQUE MAXIMO")
					ELSE
						nQtdSug := ROUND(_aMedia[nPosC,2],0)
						IF nQtdSug < _aMedia[nPosC,2]
							nQtdSug += 1
						ENDIF
						oSection1:Cell("QTDSUG")    :SetValue(nQtdSug)
					ENDIF
				ENDIF
				
				
				nQtdSug := 0
			ELSEIF SB2->B2_QATU = SBZ->BZ_ESTSEG .AND. IIF(nPosA <> 0, aAbertosPC[nPosA,2],0) <> 0 ;
			.AND. SB2->B2_QATU < (SBZ->BZ_ESTSEG +	IIF(nPosA <> 0, aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0, aAbertosSC[nPosB,2],0))//Avaliar com o André -- (ESTOQUE ATUAL = ESTOQUE MIN) E (PC <> 0),  ESTOQUE ATUAL < (ESTOQUE MIN E SOMA DE PC E SC EM ABERTO)
				oSection1:Cell("QTDSUG")    :SetValue(nQtdSug)
				oSection1:Cell("STATUS")   :SetValue("CONFERIR PC")
			ELSEIF SB2->B2_QATU = SBZ->BZ_ESTSEG .AND. IIF(nPosB <> 0,aAbertosSC[nPosB,2],0) <> 0 ;
			.AND. SB2->B2_QATU < (SBZ->BZ_ESTSEG + IIF(nPosA <> 0, aAbertosPC[nPosA,2],0) + IIF(nPosB <> 0, aAbertosSC[nPosB,2],0))//Avaliar com o André -- (ESTOQUE ATUAL = ESTOQUE MIN) E (SC <> 0),  ESTOQUE ATUAL < (ESTOQUE MIN E SOMA DE PC E SC EM ABERTO)
				oSection1:Cell("QTDSUG")    :SetValue(nQtdSug)
				oSection1:Cell("STATUS")   :SetValue("CONFERIR SC")
			ELSE
				oSection1:Cell("QTDSUG")    :SetValue(nQtdSug)
				oSection1:Cell("STATUS")   :SetValue("OK")
			ENDIF

		ENDIF

		oSection1:Printline()

		TRB->(dbSkip())
	
	ENDDO

	If Select("TRB") <> 0
	   TRB->(DbCloseArea())
	EndIf

//////////////////////// 3-Movimentações por CC ////////////////////////////////////////////////////////////////////

	cQryCC     := "SELECT D3.D3_FILIAL , D3.D3_CC, SUM(D3_QUANT) TOTSAIDA , SUM(D3_CUSTO1) CUSSAIDA "
	cQryM      := " AND D3.D3_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
  	cQryOrdem  := " GROUP BY D3.D3_FILIAL , D3.D3_CC "
  	cQryOrdem  += " ORDER BY D3.D3_FILIAL , D3.D3_CC "
	
	TCQUERY cQryCC + cQry + cQryM + cQryOrdem  NEW ALIAS "TRB"

	_nTot:=0
    COUNT TO _nTot
  	oReport:SetMeter(_nTot)

	TRB->(dbGoTop())
	_aCustos:={}
		
	DO While !TRB->(Eof())

  	   oReport:IncMeter()
       oReport:SetMsgPrint("8/9-Acumulando CC: "+TRB->D3_CC)
       IF nPos # 0
		   IF (nPosCC:=ASCAN(_aCustos, {|M| M[1] == TRB->D3_CC } )) = 0 
              AADD(_aCustos,{TRB->D3_CC,TRB->TOTSAIDA,TRB->CUSSAIDA})
           ELSE    
              _aCustos[nPosCC,2]+=TRB->TOTSAIDA
              _aCustos[nPosCC,3]+=TRB->CUSSAIDA
		   ENDIF		
		ENDIF
		TRB->(dbSkip())
	
	ENDDO

    oSection2:Init()
  	oReport:SetMeter(LEN(_aCustos))
    FOR S2 := 1 TO LEN(_aCustos)
  	    oReport:IncMeter()
        oReport:SetMsgPrint("9/9-Imprimindo CC: "+_aCustos[S2,1])
        oSection2:Cell("COD_CC")  :SetValue(_aCustos[S2,1] )
        oSection2:Cell("CENTROC") :SetValue(Posicione("CTT",1,xFilial("CTT")+_aCustos[S2,1],"CTT_DESC01")  )
	    oSection2:Cell("TOTSAIDA"):SetValue(_aCustos[S2,2] )
	    oSection2:Cell("CUSTOTOT"):SetValue(_aCustos[S2,3] )
		oSection2:Printline()
    NEXT

//////////////////////// 3-Movimentações por CC ////////////////////////////////////////////////////////////////////

    If Select("TRB_REC") <> 0
	   TRB_REC->(DbCloseArea())
	EndIf
    If Select("TRB_SC7") <> 0
	   TRB_SC7->(DbCloseArea())
	EndIf
	If Select("TRB") <> 0
	   TRB->(DbCloseArea())
	EndIf

END SEQUENCE

SBZ->( DBSetOrder(1) )

oSection1:Finish()
oSection1:Enable()

Return .T.

/*
===============================================================================================================================
Programa----------: MTLista
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 05/07/2019
===============================================================================================================================
Descrição---------: Seleciona e lista itens em aberto
===============================================================================================================================
Parametros--------:_cItem,lPC
===============================================================================================================================
Retorno-----------: Posicao
===============================================================================================================================*/
STATIC FUNCTION  MTLista(_cItem,lPC)
LOCAL _cQuery := " AND C1_PRODUTO = '"+_cItem+"'"
LOCAL cQry2   := " AND C7_PRODUTO = '"+_cItem+"' "
LOCAL _cAlias := "TRB2"

IF lPC
	MPSysOpenQuery( cQry1+cQry2 ,_cAlias )

	IF !((_cAlias)->(EOF()))
		AADD(aAbertosPC,{ _cItem , (_cAlias)->QTD_TOT } )
	ELSE
		AADD(aAbertosPC,{ _cItem, 0 } )
	ENDIF
	nPos:=LEN(aAbertosPC)
ELSE
	MPSysOpenQuery( _cQuerySC+_cQuery ,_cAlias )
	
	IF  !((_cAlias)->(EOF()))
		AADD(aAbertosSC,{ _cItem , (_cAlias)->QTD_TOT } )
	ELSE
		AADD(aAbertosSC,{ _cItem, 0 } )
	ENDIF
	nPos:=LEN(aAbertosSC)
ENDIF

(_cAlias)->(DbCloseArea())
DBSELECTAREA("TRB")

RETURN nPos
