/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |09/02/2022| Chamado 39162. Acerto do formato do campo data de emissão
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*
===============================================================================================================================
Programa----------: REST019
Autor-------------: Alex Wallauer
Data da Criacao---: 11/01/2022
===============================================================================================================================
Descrição---------: Relatório de transferências do armazém - CHAMADO 38824
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function REST019()
Local oReport	:= nil
Private _cPerg	:= "REST019"
Private aOrd	:= {} 
/*
aDados := {}
AADD( _aDados , "RE0-Requisição manual." )
AADD( _aDados , "RE1-Requisição automática." )
AADD( _aDados , "RE2-Requisição automática de material de apropriação indireta." )
AADD( _aDados , "RE3-Transferência em geral." )
AADD( _aDados , "RE4-Requisição por transferência." )
AADD( _aDados , "RE5-Requisição informando OP na nota fiscal de entrada." ) 
AADD( _aDados , "RE6-Requisição valorizada." )
AADD( _aDados , "RE7-Requisição para transferência de um para “N”." )
AADD( _aDados , "RE9-Requisição para OP sem agregar custo." )
AADD( _aDados , "DE0-Devolução manual." )
AADD( _aDados , "DE1-Devolução automática - estorno da produção." )
AADD( _aDados , "DE2-Devolução automática de material de apropriação indireta - estorno da produção." )
AADD( _aDados , "DE3-Estorno de transferência para local de apropriação indireta." )
AADD( _aDados , "DE4-Devolução de transferência entre locais." )
AADD( _aDados , "DE5-Devolução de material apropriado em OP – (exclusão de nota fiscal de entrada)." )
AADD( _aDados , "DE6-Devolução valorizada." )
AADD( _aDados , "DE7-Devolução de transferência de um para “N”." )
AADD( _aDados , "DE9-Devolução para OP sem agregar custo." )
AADD( _aDados , "PR0-Produção manual." )
AADD( _aDados , "PR1-Produção automática." )
AADD( _aDados , "ER0-Estorno de produção manual." )
AADD( _aDados , "ER1-Estorno de produção automática." )
*/
_aDados2 := {}
AADD( _aDados2 , "RE1-Consumo (RE1)" )
AADD( _aDados2 , "DE1-Retorno Producao (DE1)" )
AADD( _aDados2 , "PR0-Producao (PR0)" )
AADD( _aDados2 , "RE0-Perdas (RE0)" )
AADD( _aDados2 , "RE4-Saidas Transferencias (RE4)" )
AADD( _aDados2 , "DE4-Entradas Transferencias (DE4)" )
AADD( _aDados2 , "RE7-Saida Desmontagem (RE7)" )
AADD( _aDados2 , "DE7-Entrada Desmontagem (DE7)" )

_aItalac_F3:={}
//                      1           2         3                        4                            5            6             7         8        9         10       11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave              , nCpoDesc                  ,bCondTab , cTitAux           , nTamChv , aDados  , nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR08",           ,                        ,                           ,         ,"Tipos do Movimento",3        ,_aDados2 ,Len(_aDados2)} )
//AADD(_aItalac_F3,{"MV_PAR11",           ,                        ,                           ,         ,"Tipos do Movimento",3        ,_aDados  ,Len(_aDados)} )

DO WHILE .T.

   If !Pergunte(_cPerg,.T.)
      return .f.
   EndIf

   IF MV_PAR01 > MV_PAR02
      MSGSTOP("Periodo de datas invalido.")
      LOOP
   ENDIF
   
   IF MV_PAR04 > MV_PAR05
      MSGSTOP("Intervalo de produtos invalido.")
      LOOP
   ENDIF

   IF MV_PAR09 > MV_PAR10
      MSGSTOP("Intervalo de OPs invalido.")
      LOOP
   ENDIF

   IF MV_PAR06 > 12 .OR. MV_PAR06 < 2
      MSGSTOP("Media retroativa nao pode ser maior que 12 meses ou menor 2 meses.")
      LOOP
   ENDIF
   
   EXIT
   
ENDDO

PRIVATE cAliasSD3 := GetNextAlias()

oReport := RptDef(_cPerg)
oReport:PrintDialog()  

//========================================================================
// Grava log de Relatório de Relatório Clientes com Contrato.
//======================================================================== 
U_ITLOGACS('REST019')

Return

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Alex Wallauer
Data da Criacao---: 11/01/2022
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
Local bReport   :={|oReport| ReportPrint(oReport,) }


oReport:= TReport():New("REST019","Relatório de transferências dos armazéns. Filial: "+cFilAnt,"REST019", bReport ,;
                                  "Relatório de transferências dos armazéns. Filial: "+cFilAnt)

oReport:SetLandscape()

oSection1 := TRSection():New(oReport, "Movimentações por Produto", {cAliasSD3},aOrd , .F., .T.)

TRCell():New(oSection1,"D3_COD"    ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_DESC"   ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_TIPO"   ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_GRUPO"  ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_UM"     ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection1,"D3_LOCAL"  ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_QUANT"  ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CUSTOUNIT" ,"   ","Custo Unitario",PesqPict("SD3", "D3_CUSTO1"),/*Tamanho*/,/*lPixel*/,{|| (cAliasSD3)->D3_CUSTO1 / If((cAliasSD3)->D3_QUANT == 0,1,(cAliasSD3)->D3_QUANT ) })
TRCell():New(oSection1,"CUSTO"     ,"   ","Custo Total"   ,PesqPict("SD3", "D3_CUSTO1"),/*Tamanho*/,/*lPixel*/,{||  If((cAliasSD3)->D3_TM > "500",((cAliasSD3)->D3_CUSTO1)* -1,(cAliasSD3)->D3_CUSTO1) })
TRCell():New(oSection1,"D3_TM"     ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_CF"     ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_OP"     ,cAliasSD3) //
TRCell():New(oSection1,"D3_NUMSEQ" ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_CC"     ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_DOC"    ,cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_EMISSAO",cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D3_USUARIO",cAliasSD3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2 := TRSection():New(oReport, "Totalizadores", {""},aOrd , .F., .T.)
TRCell():New(oSection2,"PRODUTO"	,"","Produto"  		    ,"@!",100)
TRCell():New(oSection2,"DESCR"      ,"","Descrição " 	    ,"@!",100)
TRCell():New(oSection2,"QTDDIASTRAN" ,"","QTD DIAS TRANSF"   	   ,"@E 99999,999,999"   ,25)
TRCell():New(oSection2,"TRANSFTOTAL","","TRANSF TOTAL"     		   ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"TRANSFMEDIA","","TRANSF MÉDIA DIARIA"	   ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"TRANSFMEDIR","","TRANSF MÉDIA RETRO MES"   ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"QTDDIASCONS","","QTD DIAS CONSUMO"   	   ,"@E 99999,999,999"   ,25)
TRCell():New(oSection2,"CONSUMOTOT" ,"","CONSUMO TOTAL"   		   ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"CONSUMEDIA" ,"","CONSUMO MÉDIA DIARIA"	   ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"CONSUMEDIAR","","CONSUMO MÉDIA RETRO MES"  ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"QTDDIASPROD","","QTD DIAS PRODUÇÃO"   	   ,"@E 99999,999,999"   ,25)
TRCell():New(oSection2,"PRODUCAOTOT","","PRODUÇÃO TOTAL"   		   ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"PRODUCMEDIA","","PRODUÇÃO MÉDIA DIARIA"    ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"PRODUCMEDIR","","PRODUÇÃO MÉDIA RETRO MES" ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"QTDDIASPERD","","QTD DIAS PERDA"   	       ,"@E 99999,999,999"   ,25)
TRCell():New(oSection2,"PERDATOTAL" ,"","PERDA TOTAL"   		   ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"PERDAMEDIA" ,"","PERDA MÉDIA DIARIA"       ,"@E 99999,999,999.99",25)
TRCell():New(oSection2,"PERDAMEDIAR","","PERDA MÉDIA RETRO MES"    ,"@E 99999,999,999.99",25)

Return(oReport)

/*
===============================================================================================================================
Programa----------: RptDef
Autor-------------: Alex Wallauer
Data da Criacao---: 11/01/2022
===============================================================================================================================
Descrição---------: Função que imprime o relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,oProc)

Local oSection1 := oReport:Section(1) ,nX
Local oSection2 := oReport:Section(2) ,S2
Local cQryM:=""

oSection1:Init()
oReport:SetMeter(0)

BEGIN SEQUENCE
	
    oReport:IncMeter()
    oReport:SetMsgPrint("Lendo dados da SD3...")
    
    // monta os campos que tem nas colunas da 1a seç?o do treport para o SELECT
    cSQLFields := ""
    nQtdCol := Len(oSection1:aCell)
    For nX := 1 to nQtdCol
    	If !Empty(oSection1:aCell[nX]:cAlias)
    	   cSQLFields += " ,"
    	   cSQLFields += "S"+SUBSTR(oSection1:aCell[nX]:cName,1,2)
    	   cSQLFields += "."
    	   cSQLFields += oSection1:aCell[nX]:cName
    	EndIf
    Next

	cQry  := "SELECT SD3.R_E_C_N_O_ SD3RECNO, SD3.D3_CUSTO1, SD3.D3_QUANT "+cSQLFields

 	cQry += " FROM " + RetSqlName("SD3") + " SD3 "
 	cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' '"
	cQry += " WHERE SD3.D_E_L_E_T_ = ' ' AND D3_ESTORNO <> 'S' AND D3_FILIAL = '"+xFilial("SD3")+"' "
  	If !Empty(MV_PAR01)
	   cQry += "  AND D3_EMISSAO >= '" + DTOS(MV_PAR01) + "' "
    ENDIF

  	If !Empty(MV_PAR02)
	   cQry += "  AND D3_EMISSAO <= '" + DTOS(MV_PAR02) + "' "
    ENDIF

	If !Empty(MV_PAR03)
		cQry += "  AND D3_GRUPO IN " + FormatIn( ALLTRIM(MV_PAR03) , ";" )
		cQryM+= "  AND D3_GRUPO IN " + FormatIn( ALLTRIM(MV_PAR03) , ";" )
 	EndIf

  	If !Empty(MV_PAR04)
	   cQry += "  AND D3_COD >= '" + ALLTRIM(MV_PAR04) + "' "
	   cQryM+= "  AND D3_COD >= '" + ALLTRIM(MV_PAR04) + "' "
    ENDIF

  	If !Empty(MV_PAR05)
	   cQry += "  AND D3_COD <= '" + ALLTRIM(MV_PAR05) + "' "
	   cQryM+= "  AND D3_COD <= '" + ALLTRIM(MV_PAR05) + "' "
    ENDIF

	If !Empty(MV_PAR07)
		cQry += "  AND D3_LOCAL IN " + FormatIn( ALLTRIM(MV_PAR07) , ";" )
		cQryM+= "  AND D3_LOCAL IN " + FormatIn( ALLTRIM(MV_PAR07) , ";" )
	EndIf

	If !Empty(MV_PAR08) 
		cQry += "  AND D3_CF IN " + FormatIn( ALLTRIM(MV_PAR08) , ";" )
	EndIf

  	If !Empty(MV_PAR09)
	   cQry += "  AND D3_OP >= '" + ALLTRIM(MV_PAR09) + "' "
	   cQryM+= "  AND D3_OP >= '" + ALLTRIM(MV_PAR09) + "' "
    ENDIF

  	If !Empty(MV_PAR10)
	   cQry += "  AND D3_OP <= '" + ALLTRIM(MV_PAR10) + "' "
	   cQryM+= "  AND D3_OP <= '" + ALLTRIM(MV_PAR10) + "' "
    ENDIF

  	If MV_PAR11 = 1
	   cQry += "  AND D3_OP <> ' ' "
	   cQryM+= "  AND D3_OP <> ' ' "
    ENDIF

  	cQry  += " ORDER BY D3_FILIAL , D3_CF , D3_COD , D3_LOCAL "
	
	TCQUERY cQry NEW ALIAS (cAliasSD3)

    TCSetField(cAliasSD3,"D3_EMISSAO","D",08,0)

    nTot:=0
    dbSelectArea(cAliasSD3)
    COUNT TO nTot
    oReport:SetMeter(nTot)
    
    DBGOTOP()

    oSection1:Init()


//AADD( _aDados2 , "RE1-Consumo (RE1)" )
//AADD( _aDados2 , "DE1-Retorno Producao (DE1)" )
//AADD( _aDados2 , "PR0-Producao (PR0)" )
//AADD( _aDados2 , "RE0-Perdas (RE0)" )
//AADD( _aDados2 , "RE4-Saidas Transferencias (RE4)" )
//AADD( _aDados2 , "DE4-Entradas Transferencias (DE4)" )
//AADD( _aDados2 , "RE7-Saida Desmontagem (RE7)" )
//AADD( _aDados2 , "DE7-Entrada Desmontagem (DE7)" )

	_aTotais  :={}
	_aContaRE4:={}//só RE4 por produto //QTD DIAS TRANSF TOTAL 
	_aContaRE1:={}//só RE1 por produto //QTD DIAS consumo PRODUÇÃO TOTAL
	_aContaPR0:={}//só PR0 por produto //QTD DIAS PRODUÇÃO TOTAL
	_aContaRE0:={}//só RE0 por produto //QTD DIAS PERDAS TOTAL
	_aTotRE4  :={}//só RE4 por produto TRANSF TOTAL
	_aTotRE1  :={}//só RE1 por produto TRANSF TOTAL
	_aTotPR0  :={}//só PR0 por produto TRANSF TOTAL
	_aTotRE0  :={}//só RE0 por produto TRANSF TOTAL

	DO While !oReport:Cancel() .And. !(cAliasSD3)->(Eof())

	   oReport:IncMeter()
	   If oReport:Cancel()
	   	  Exit
	   EndIf
       
	   oReport:SetMsgPrint("Imprimindo Produto: "+(cAliasSD3)->D3_COD )
	   
	   IF (ASCAN(_aTotais,{|A|A[1]=(cAliasSD3)->D3_COD })) = 0 
          AADD(_aTotais,{(cAliasSD3)->D3_COD,(cAliasSD3)->B1_DESC,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
	   ENDIF
       IF (cAliasSD3)->D3_CF = "RE4"
	      IF ASCAN(_aContaRE4,{|A| A[1]==(cAliasSD3)->D3_COD .AND. A[2]=(cAliasSD3)->D3_EMISSAO  }) = 0 
             AADD(_aContaRE4,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_EMISSAO})
		  ENDIF
	      IF (nPos:=ASCAN(_aTotRE4,{|A|A[1]=(cAliasSD3)->D3_COD })) = 0 
             AADD(_aTotRE4,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_QUANT})
		  ELSE
		     _aTotRE4[nPos,2]+=(cAliasSD3)->D3_QUANT
		  ENDIF
       ELSEIF (cAliasSD3)->D3_CF = "RE1"
	      IF ASCAN(_aContaRE1,{|A| A[1]==(cAliasSD3)->D3_COD .AND. A[2]=(cAliasSD3)->D3_EMISSAO  }) = 0 
             AADD(_aContaRE1,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_EMISSAO})
		  ENDIF
	      IF (nPos:=ASCAN(_aTotRE1,{|A|A[1]=(cAliasSD3)->D3_COD })) = 0 
             AADD(_aTotRE1,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_QUANT})
		  ELSE
		     _aTotRE1[nPos,2]+=(cAliasSD3)->D3_QUANT
		  ENDIF
       ELSEIF (cAliasSD3)->D3_CF = "PR0"
	      IF ASCAN(_aContaPR0,{|A| A[1]==(cAliasSD3)->D3_COD .AND. A[2]=(cAliasSD3)->D3_EMISSAO  }) = 0 
             AADD(_aContaPR0,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_EMISSAO})
		  ENDIF
	      IF (nPos:=ASCAN(_aTotPR0,{|A|A[1]=(cAliasSD3)->D3_COD })) = 0 
             AADD(_aTotPR0,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_QUANT})
		  ELSE
		     _aTotPR0[nPos,2]+=(cAliasSD3)->D3_QUANT
		  ENDIF
       ELSEIF (cAliasSD3)->D3_CF = "RE0" .AND. (cAliasSD3)->D3_TM = "999"
	      IF ASCAN(_aContaRE0,{|A| A[1]==(cAliasSD3)->D3_COD .AND. A[2]=(cAliasSD3)->D3_EMISSAO  }) = 0 
             AADD(_aContaRE0,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_EMISSAO})
		  ENDIF
	      IF (nPos:=ASCAN(_aTotRE0,{|A|A[1]=(cAliasSD3)->D3_COD })) = 0 
             AADD(_aTotRE0,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_QUANT})
		  ELSE
		     _aTotRE0[nPos,2]+=(cAliasSD3)->D3_QUANT
		  ENDIF
       ENDIF
	   //SD3->(MsGoto((cAliasSD3)->SD3RECNO))
 	   
		oSection1:PrintLine()
   
	   (cAliasSD3)->(dbSkip())
    ENDDO
    oSection1:Finish()

    oReport:SetMsgPrint("Processando CF RE4")
    _aDiasRE4:={}
	FOR S2 := 1 TO LEN(_aContaRE4)
	    IF (nPosD:=ASCAN(_aDiasRE4,{|A|A[1]==_aContaRE4[S2,1] })) = 0 
           AADD(_aDiasRE4,{_aContaRE4[S2,1],1})
		   nPosD:=LEN(_aDiasRE4)
		ELSE
		   _aDiasRE4[nPosD,2]++
		ENDIF    
	    IF (nPosC:=ASCAN(_aTotais,{|A|A[1]==_aContaRE4[S2,1] })) <> 0 
	        _aTotais[nPosC,3]:=_aDiasRE4[nPosD,2]
	        IF (nPosT:=ASCAN(_aTotRE4,{|A|A[1]==_aContaRE4[S2,1] })) <> 0 
	            _aTotais[nPosC,4]:=_aTotRE4[nPosT,2]
	            _aTotais[nPosC,5]:=_aTotRE4[nPosT,2]/_aDiasRE4[nPosD,2]
	        ENDIF
	    ENDIF
	NEXT

    oReport:SetMsgPrint("Processando CF RE1")
    _aDiasRE1:={}
	FOR S2 := 1 TO LEN(_aContaRE1)
	    IF (nPosD:=ASCAN(_aDiasRE1,{|A|A[1]==_aContaRE1[S2,1] })) = 0 
           AADD(_aDiasRE1,{_aContaRE1[S2,1],1})
		   nPosD:=LEN(_aDiasRE1)
		ELSE
		   _aDiasRE1[nPosD,2]++
		ENDIF    
	    IF (nPosC:=ASCAN(_aTotais,{|A|A[1]==_aContaRE1[S2,1] })) <> 0 
	        _aTotais[nPosC,7]:=_aDiasRE1[nPosD,2]
	        IF (nPosT:=ASCAN(_aTotRE1,{|A|A[1]==_aContaRE1[S2,1] })) <> 0 
	            _aTotais[nPosC,8]:=_aTotRE1[nPosT,2]
	            _aTotais[nPosC,9]:=_aTotRE1[nPosT,2]/_aDiasRE1[nPosD,2]
	        ENDIF
	    ENDIF
	NEXT

    oReport:SetMsgPrint("Processando CF PR0")
    _aDiasPR0:={}
	FOR S2 := 1 TO LEN(_aContaPR0)
	    IF (nPosD:=ASCAN(_aDiasPR0,{|A|A[1]==_aContaPR0[S2,1] })) = 0 
           AADD(_aDiasPR0,{_aContaPR0[S2,1],1})
		   nPosD:=LEN(_aDiasPR0)
		ELSE
		   _aDiasPR0[nPosD,2]++
		ENDIF    
	    IF (nPosC:=ASCAN(_aTotais,{|A|A[1]=_aContaPR0[S2,1] })) <> 0 
	        _aTotais[nPosC,11]:=_aDiasPR0[nPosD,2]
	        IF (nPosT:=ASCAN(_aTotPR0,{|A|A[1]=_aContaPR0[S2,1] })) <> 0 
	            _aTotais[nPosC,12]:=_aTotPR0[nPosT,2]
	            _aTotais[nPosC,13]:=_aTotPR0[nPosT,2]/_aDiasPR0[nPosD,2]
	        ENDIF
	    ENDIF
	NEXT

    oReport:SetMsgPrint("Processando CF RE0")
    _aDiasRE0:={}
	FOR S2 := 1 TO LEN(_aContaRE0)
	    IF (nPosD:=ASCAN(_aDiasRE0,{|A|A[1]==_aContaRE0[S2,1] })) = 0 
           AADD(_aDiasRE0,{_aContaRE0[S2,1],1})
		   nPosD:=LEN(_aDiasRE0)
		ELSE
		   _aDiasRE0[nPosD,2]++
		ENDIF    
	    IF (nPosC:=ASCAN(_aTotais,{|A|A[1]=_aContaRE0[S2,1] })) <> 0 
	        _aTotais[nPosC,15]:=_aDiasRE0[nPosD,2]
	        IF (nPosT:=ASCAN(_aTotRE0,{|A|A[1]=_aContaRE0[S2,1] })) <> 0 
	            _aTotais[nPosC,16]:=_aTotRE0[nPosT,2]
	            _aTotais[nPosC,17]:=_aTotRE0[nPosT,2]/_aDiasRE0[nPosD,2]
	        ENDIF
	    ENDIF
	NEXT

//******************  MEDIA
    oReport:SetMsgPrint("Lendo dados da Media...")

	If Select("TRB") <> 0
	   TRB->(DbCloseArea())
	EndIf
    _dDAtaIncio:= DATE() - (MV_PAR06*30) 

	cQryMedia  := "SELECT SD3.D3_FILIAL , SD3.D3_COD , SD3.D3_CF, SUM(D3_QUANT) MEDIA "
 	cQryMedia  += "  FROM " + RetSqlName("SD3") + " SD3 "
 	cQryMedia  += " WHERE     D_E_L_E_T_ = ' ' AND D3_ESTORNO <> 'S' AND D3_FILIAL = '"+xFilial("SD3")+"' "
	
	cQryM      += "  AND SD3.D3_EMISSAO BETWEEN '" + DtoS(_dDAtaIncio) + "' AND '" + DtoS(DATE()) + "' "
	cQryM      += "  AND (D3_CF IN ('RE4','RE1','PR0') OR (D3_CF = 'RE0' AND D3_TM = '999')) "
  	
	cQryOrdem  := "  GROUP BY SD3.D3_FILIAL , SD3.D3_COD , SD3.D3_CF "
  	cQryOrdem  += "  ORDER BY SD3.D3_FILIAL , SD3.D3_COD , SD3.D3_CF "
	
	TCQUERY cQryMedia + cQryM + cQryOrdem  NEW ALIAS "TRB"//MEDIA

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
       oReport:SetMsgPrint("Acumulando Media: "+ALLTRIM(STR(_nConta,_nTam)) +" de "+ _cTot)

	    IF (nPosC:=ASCAN(_aTotais,{|A|A[1]=TRB->D3_COD })) <> 0 
            IF TRB->D3_CF = "RE4"
			   _aTotais[nPosC,06]:=ROUND(TRB->MEDIA/MV_PAR06,2)
            ELSEIF TRB->D3_CF = "RE1"
			   _aTotais[nPosC,10]:=ROUND(TRB->MEDIA/MV_PAR06,2)
            ELSEIF TRB->D3_CF = "PR0"
			   _aTotais[nPosC,14]:=ROUND(TRB->MEDIA/MV_PAR06,2)
            ELSEIF TRB->D3_CF = "RE0" 
			   _aTotais[nPosC,18]:=ROUND(TRB->MEDIA/MV_PAR06,2)
            ENDIF
	    ENDIF

	   TRB->(dbSkip())
	ENDDO

    oSection2:Init()
  	oReport:SetMeter(LEN(_aTotais))
    FOR S2 := 1 TO LEN(_aTotais)
  	    oReport:IncMeter()
        oReport:SetMsgPrint("Imprimindo Totais: "+_aTotais[S2,1])
        
		oSection2:Cell("PRODUTO"):SetValue(_aTotais[S2,01] )
        oSection2:Cell("DESCR"  ):SetValue(_aTotais[S2,02] )
	    
		oSection2:Cell("QTDDIASTRAN"):SetValue(_aTotais[S2,03] )
	    oSection2:Cell("TRANSFTOTAL"):SetValue(_aTotais[S2,04] )
	    oSection2:Cell("TRANSFMEDIA"):SetValue(_aTotais[S2,05] )
	    oSection2:Cell("TRANSFMEDIR"):SetValue(_aTotais[S2,06] )

	    oSection2:Cell("QTDDIASCONS"):SetValue(_aTotais[S2,07] )
	    oSection2:Cell("CONSUMOTOT" ):SetValue(_aTotais[S2,08] )
	    oSection2:Cell("CONSUMEDIA" ):SetValue(_aTotais[S2,09] )
	    oSection2:Cell("CONSUMEDIAR"):SetValue(_aTotais[S2,10] )
	    
		oSection2:Cell("QTDDIASPROD"):SetValue(_aTotais[S2,11] )
	    oSection2:Cell("PRODUCAOTOT"):SetValue(_aTotais[S2,12] )
	    oSection2:Cell("PRODUCMEDIA"):SetValue(_aTotais[S2,13] )
	    oSection2:Cell("PRODUCMEDIR"):SetValue(_aTotais[S2,14] )

		oSection2:Cell("QTDDIASPERD"):SetValue(_aTotais[S2,15] )
	    oSection2:Cell("PERDATOTAL" ):SetValue(_aTotais[S2,16] )
	    oSection2:Cell("PERDAMEDIA" ):SetValue(_aTotais[S2,17] )
	    oSection2:Cell("PERDAMEDIAR"):SetValue(_aTotais[S2,18] )
		oSection2:Printline()
    NEXT
		
END SEQUENCE

If Select("TRB") <> 0
   TRB->(DbCloseArea())
EndIf
SBZ->( DBSetOrder(1) )

oSection1:Finish()
oSection1:Enable()

Return .T.

/*
===============================================================================================================================
Programa----------: MTLista
Autor-------------: Alex Wallauer
Data da Criacao---: 11/01/2022
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
