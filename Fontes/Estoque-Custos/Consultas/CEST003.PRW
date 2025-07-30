/*
==============================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre    - Alex Walauer  - 07/11/24 - 21/11/24 -  48952  - Copia do Programa de rastreamento dos Lotes da producao (MATC040.PRX)
==============================================================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa----------: CEST003
Autor-------------: Alex Wallauer
Data da Criacao---: 07/11/2024
Descricao---------: Copia do Programa de rastreamento dos Lotes da producao (MATC040.PRX) - Chamado: 48952
Caminho-----------: SIGAEST -> CONSULTAS -> ESPECIFICO ITALAC -> Rastreamento
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
User Function CEST003()//U_CEST003

 LOCAL cFiltraSB1 :="SB1->B1_RASTRO$'LS'"

 PRIVATE aRotina  := MenuDef()
 PRIVATE cCadastro:= "Rastreamento de Lotes - ITALAC"
 
 SB1->(dbSetOrder(1))
 SB1->(DBGOTOP())
 _aCmp := {}
 AADD(_aCmp,{ "Codigo Prod.", {|| SB1->B1_COD } ,"C",LEN(SB1->B1_COD ),0,"" })
 AADD(_aCmp,{ "Descri.Prod.", {|| SB1->B1_DESC} ,"C",LEN(SB1->B1_DESC),0,"" })

  //rowse(,,,,cAli>,<aFixe, <cCpo>, <nPar>, <cCorFun>, <nClickDef>, <aColors>, <cTopFun>, <cBotFun>, <nPar14>, <bInitBloc>, <lNoMnuFilter>, <lSeeAll>, <lChgAll>, <cExprFilTop>, <nInterval>, <uPar22>, <uPar23> )
  mBrowse(,,,,"SB1",_aCmp,,,,,,,,,,,,,,,,,cFiltraSB1)

 SB1->(dbSetOrder(1))

RETURN
/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alex Wallauer
Data da Criacao---: 13/11/2024
Descricao---------: Copia da Funcao Static Function MenuDef () do (MATC040.PRX)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function MenuDef()     
 Private aRotina:= {{"Pesquisar","PesqBrw"     ,0,1,0,.F.},;	
					{"Rastrear" ,"U_MTC040Rast",0,4,0,NIL}}
Return (aRotina)

/*
===============================================================================================================================
Programa----------: MTC040Rast
Autor-------------: Alex Wallauer
Data da Criacao---: 07/11/2024
Descricao---------: Tela principal do rastreamento dos Lotes ITALAC
Parametros--------: cAlias,nReg,nOpc
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
User Function MTC040Rast(cAlias,nReg,nOpc)

 Local nOrder   :=IndexOrd()
 Local _cTimeIni:=TIME()
 Local cTit1    :="Rastremento do Produto: "+SB1->B1_COD+" - "+ALLTRIM(SB1->B1_DESC)+". (MTC040MNU.PRW)"
 Local _aSize   :={}
 Local _aInfo   :={}
 Local aObjects :={}
 Local aPosObj  :={}
 Local aFoders1 :={}
 Local nLin01   :=05
 Local nLin03   :=25 
 Local nCol01   :=02
  
 Static nNivMax :=SuperGetMV("MV_C040NIV",.F.,30)
 Static lEmpPrev:=If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)

 PRIVATE cLocCQ	   := GetMvNNR('MV_CQ','98')
 PRIVATE _oLbx1    as object
 PRIVATE _oLbx2    as object
 PRIVATE _oPanelA  as object   
 PRIVATE _oPanel1A as object    
 PRIVATE _oPanelB  as object   
 PRIVATE _oPanel1B as object    
 PRIVATE _oScrollA as object
 PRIVATE _oScrollB as object
 PRIVATE _oSay01   as object
 PRIVATE _oSay02   as object
 PRIVATE _oSay03   as object
 PRIVATE _oSay04   as object
 PRIVATE _oSay05   as object
 PRIVATE _oSay06   as object
 PRIVATE _oGet01   as object
 PRIVATE _oGet02   as object
 PRIVATE _oGet03   as object
 PRIVATE _oGet04   as object
 PRIVATE _oGet05   as object
 PRIVATE _oGet06   as object
 PRIVATE _oTree1   as object
 PRIVATE _oTree2   as object
 PRIVATE _aObjetos := {_oTree1,_oTree2}
 PRIVATE _aRegsA   := {}
 PRIVATE _aRegsB   := {}
 PRIVATE _aDadoTre1:= {} 
 PRIVATE _aDadoTre2:= {} 
 PRIVATE aLine	   := {}
 PRIVATE c040LotCtl:= ""
 PRIVATE cLoteFor  := ""
 PRIVATE cSaldoLt  := ""
 PRIVATE nPotencia := 0
 PRIVATE nSaldoLote:= 0
 PRIVATE _dDTValid := CTOD("")
 //      _aTotais  := { {nTotVenc,nTotZera,nTotUsad,nSaldo,nSaldoLote} , {nTotVenc,nTotZera,nTotUsad,nSaldo,nSaldoLote} }
 PRIVATE _aTotais  := { {0,0,0,0,0,0,0,0,} , {0,0,0,0,0,0,0,0,0,} }
 
 //  Variaveis utilizadas para parametros                                     
 //  MV_PAR01  // Tipo do Rastremento ? Onde e' usado/Composicao        
 //  MV_PAR02  // Exibir Lotes Zerados ? Sim/Nao                        
 //  MV_PAR03  // Cli / Forn. de ?                                      
 //  MV_PAR04  // Cli / Forn. ate ?                                     
 //  MV_PAR05  // Loja de ?                                             
 //  MV_PAR06  // Loja ate ?                                            
 //  MV_PAR07  // De Lote ?                                             
 //  MV_PAR08  // Ate Lote ?                                            
 //  MV_PAR09  // De Sub-Lote ?                                         
 //  MV_PAR10  // Ate Sub-Lote ?                                        
 //  MV_PAR11  // de Data de Validade ?                                 
 //  MV_PAR12  // Ate Data de Validade ?                                
           
 IF !Pergunte("CEST003",.T.)//MTC040
    RETURN .F.
 ENDIF
 
 SD3->(DBSETORDER(4))
 DBSELECTAREA(CALIAS)

 // PEGA TAMANHOS DAS TELAS
 _aSize := MsAdvSize()
 _aInfo := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 3 , 3 }
 aObjects := {}
 AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
 AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )
 aPosObj  := MsObjSize( _aInfo , aObjects )
 
 aFoders1:={}
 AADD(aFoders1,"Rastremento: Onde é usado")
 AADD(aFoders1,"Rastremento: Composicao")
 
 _aLegenda := {{ "PMSEDT4", "Produto"        },;
  			   { "PMSEDT1", "Lotes Vencidos" },;
  			   { "PMSEDT2", "Lotes Zerados"  },;
               { "PMSEDT3", "Lotes Em Uso"   } }


 DEFINE MSDIALOG oDlg2 TITLE cTit1  PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5] OF oMainWnd

       oPnlTopTop := TPanel():New( 1 , 0 , , oDlg2 , , , , , , 80 , 20 , .F. , .F. )   

	   @ nLin01, nCol01 BUTTON  "SAIR"                    SIZE 040, 14 OF oPnlTopTop ACTION (oDlg2:End()) PIXEL
	   nCol01+=50
	   @ nLin01, nCol01 BUTTON  "Legenda"                 SIZE 040, 14 OF oPnlTopTop ACTION (BRWLEGENDA( "LEGENDA", "Legenda", _aLegenda )) PIXEL
	   nCol01+=50
	   @ nLin01, nCol01 BUTTON  "Pesquisar"               SIZE 040, 14 OF oPnlTopTop ACTION (CEST3Pesq()) PIXEL
	   nCol01+=50
	   @ nLin01, nCol01 BUTTON  "Imprimir os Movimentos"  SIZE 080, 14 OF oPnlTopTop ACTION (A040Imp()) PIXEL
	   nCol01+=95
	   @ nLin01, nCol01 BUTTON  "Visualiza Lotes"         SIZE 080, 14 OF oPnlTopTop ACTION (C040Graph(_aTotais[(oTFolder01:nOption),1],;
	                                                                                                   _aTotais[(oTFolder01:nOption),2],;
	      																							   _aTotais[(oTFolder01:nOption),3] )) PIXEL

       //FOLDER PRINCIPAL COM 2 PASTAS **************************************************************************
	   _nColFolder:=aPosObj[2,4]-3
       _nLinFolder:=aPosObj[2,3]-34
       //                                                              LARGURA     ALTURA 
       oTFolder01:= TFolder():New( nLin03,1,aFoders1,,oDlg2,,,,.T., , _nColFolder,_nLinFolder )
	   oTFolder01:bChange:={|| CETS3Change()  }
       _nLinFolder-=5
	   _nColFolder-=5
         //       TScrollBox():New( [ oWnd ]             ,[ nTop ],[ nLeft],[ altura  ] , [ LARGURA],lVertical,lHorizontal,lBorder)
  	   oTela1 :=TScrollBox():New(oTFolder01:aDialogs[1], 1      ,1       ,_nLinFolder,_nColFolder,.T.      ,.T.        ,.T.)
         
	   _lSair:=.F.
	   _lPerguntou:=.F.
       MV_PAR01:=1//PASTA: "Rastremento: Onde é usado"
       FWMSGRUN( ,{|oProc| oTela1:=U_MC040Con(@oTela1,oProc,@_oTree1,@_oLbx1,@_oPanelA,@_oPanel1A,@_oScrollA,_aRegsA,_aDadoTre1) } , "Aguarde!" , "Hor Inicial: "+_cTimeIni )

       IF !_lSair
          //         TScrollBox():New( [ oWnd ]             ,[ nTop ],[ nLeft],[ nHeight ] , [ nWidth],lVertical,lHorizontal,lBorder)
  	      oTela2 :=TScrollBox():New(oTFolder01:aDialogs[2], 1      ,1       ,_nLinFolder,_nColFolder,.T.      ,.T.        ,.T.)
   
          MV_PAR01:=2//PASTA: "Rastremento: Composicao"
          FWMSGRUN( ,{|oProc| oTela2:=U_MC040Con(@oTela2,oProc,@_oTree2,@_oLbx2,@_oPanelB,@_oPanel1B,@_oScrollB,_aRegsB,_aDadoTre2) } , "Aguarde!" , "Hor Inicial: "+_cTimeIni )
	   ENDIF
  
 ACTIVATE MSDIALOG oDlg2 ON INIT (IF(_lSair,oDlg2:End()                    ,;
	                             (oPnlTopTop:Align:= CONTROL_ALIGN_TOP     ,;
	                             oTFolder01:Align:= CONTROL_ALIGN_ALLCLIENT,;
								 oTela1:Align:= CONTROL_ALIGN_ALLCLIENT    ,;
	   							 oTela2:Align:= CONTROL_ALIGN_ALLCLIENT    )))
 
 (cAlias)->(DBSETORDER(nOrder))
 (cAlias)->(MSGOTO(nReg))
  
RETURN

/*
===============================================================================================================================
Programa----------: MC040Con
Autor-------------: Alex Wallauer
Data da Criacao---: 08/11/2024
Descricao---------: Copia da Funcao Static Function MC040Con () do (MATC040.PRX)
Parametros--------: oFolder,oProc,oTree,oLbx,oPanel,oPanel1,oScroll,aRegs,aDadosSB8
Retorno-----------: oFolder
===============================================================================================================================
*/ 
USER Function MC040Con(oFolder,oProc,oTree,oLbx,oPanel,oPanel1,oScroll,aRegs,aDadosSB8)
 Local aDados     := {}
 Local aSVAlias   := {}
 Local aPos       := {}
 Local nTop       := oMainWnd:nTop+23
 Local nLeft      := oMainWnd:nLeft+5
 Local nBottom    := oMainWnd:nBottom-60
 Local nRight     := oMainWnd:nRight-10
 Local nTotVenc   := nTotZera := nTotUsad := 0
 Local dDtValid   := STOD("")
 Local cSeekSD5   := ''
 Local cQuery     := ''
 Local cAliasNew  := 'SB8'
 Local nSaldoSB8  := 0
 Local nRecSldAtu := 0
 Local cPictSaldo := PesqPictQt("B8_SALDO",15)
 Local lEmpPrev   := If(SuperGetMV("MV_QTDPREV")=="S",.T.,.F.)
 local cNomeFolder:= ""
 Local lSoma      := .F.
 local nPos       As Numeric
 
 PRIVATE nSaldo    := 0
 PRIVATE nLotes    := 0
 PRIVATE nSldTot   := 0
 PRIVATE lSubLote  := .F.
 
 nSaldoLote:= 0
 
 aRegs:={}// Cria uma linha na ListBox em Branco
 If Rastro(SB1->B1_COD,"L")
	AADD(aRegs,{'','','','','',''   ,nil,'',''})//9
 Else
	AADD(aRegs,{'','','','','','','',nil,'',''})//10
 EndIf
 
 // Carrega as variaveis de memoria do SB1                
 AADD(aSVAlias,"SB1")
 RegToMemory("SB1",.F.)
 
 dbSelectArea(cAliasNew)
 dbSetOrder(3) //B8_FILIAL+B8_PRODUTO+ B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
 
 cAliasNew := GetNextAlias()
 cQuery := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, B8_DATA,"
 cQuery += " B8_SALDO, B8_SALDO2, B8_QACLASS, B8_QACLAS2, B8_EMPENHO, B8_EMPENH2, B8_QEMPPRE, B8_QEPRE2, R_E_C_N_O_ SB8RECNO"
 cQuery += " FROM "+RetSqlName('SB8')
 cQuery += " WHERE "
 cQuery += " B8_FILIAL      = '"+xFilial("SB8")+"'"
 cQuery += " AND B8_PRODUTO = '"+SB1->B1_COD+"'"
 cQuery += " AND B8_LOTECTL>= '"+MV_PAR07+"'"
 cQuery += " AND B8_LOTECTL<= '"+MV_PAR08+"'"
 If Rastro(SB1->B1_COD,"S")
	 cQuery += " AND B8_NUMLOTE>= '"+MV_PAR09+"'"
	 cQuery += " AND B8_NUMLOTE<= '"+MV_PAR10+"'"
 EndIf
 cQuery += " AND B8_DTVALID>= '"+DTOS(MV_PAR11)+"'"
 cQuery += " AND B8_DTVALID<= '"+DTOS(MV_PAR12)+"'"
 cQuery += " AND D_E_L_E_T_ = ' '"
 cQuery += " ORDER BY "+SqlOrder(SB8->(IndexKey()))
 cQuery := ChangeQuery(cQuery)
 
 MPSysOpenQuery( cQuery,cAliasNew )
 
 aEval(SB8->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasNew,x[1],x[2],x[3],x[4]),Nil)})
 
 dbSelectArea(cAliasNew)
 
 _nTot:=nConta:=0
 COUNT TO _nTot
 _cTot:=ALLTRIM(STR(_nTot))
  DBGOTOP()
 _lSair:=.F.
 IF _nTot > 500 .AND. !_lPerguntou
     _lPerguntou:=.T.
	 IF !U_ITMSG("Serão processado "+_cTot+" registros, CONFIRMA?","Atenção",,3,2,2)
	     _lSair:=.T.
		 RETURN oFolder
	 ENDIF
	 cTimeInicial:=TIME()
 ENDIF
 

 If (cAliasNew)->(!Eof())

	aAdd(aSVAlias,"SB8")

	DO WHILE (cAliasNew)->(!Eof()) 

	    nConta++
	    oProc:cCaption := (If(MV_PAR01==1,"1/2 - ","2/2 -")+"Lendo Lotes "+If(MV_PAR01==1,"(Onde é Usado):","(Composicao):")+STRZERO(nConta,5) +" de "+ _cTot )
	    ProcessMessages()

		cProd    := (cAliasNew)->B8_PRODUTO
		cLocal   := (cAliasNew)->B8_LOCAL
		cLote    := (cAliasNew)->B8_LOTECTL
		cSubL    := (cAliasNew)->B8_NUMLOTE
		lSubLote := Rastro(cProd,"S")
		nSaldoSB8:= 0
		
		nRecSldAtu := (cAliasNew)->SB8RECNO

		DO While (cAliasNew)->(!Eof() .And. cProd+cLocal+cLote+If(lSubLote,cSubL,"") == B8_PRODUTO+B8_LOCAL+B8_LOTECTL+If(lSubLote,B8_NUMLOTE,""))

			// Para Rastro = S, verificar se ha movimento no SD5     
			// com D5_ORIGLAN == 999                                |
			If lSubLote

				SD5->(dbSetOrder(2))
				If SD5->(dbSeek(xFilial("SD5")+(cAliasNew)->B8_PRODUTO+(cAliasNew)->B8_LOCAL+(cAliasNew)->B8_LOTECTL+(cAliasNew)->B8_NUMLOTE))
					cSeekSD5:= xFilial("SD5")+SD5->D5_NUMSEQ+(cAliasNew)->B8_PRODUTO+(cAliasNew)->B8_LOCAL+(cAliasNew)->B8_LOTECTL+(cAliasNew)->B8_NUMLOTE
					SD5->(dbSetOrder(3))
					If SD5->(dbSeek(cSeekSD5))
						While !SD5->(Eof()) .And. cSeekSD5 == SD5->D5_FILIAL+SD5->D5_NUMSEQ+SD5->D5_PRODUTO+SD5->D5_LOCAL+SD5->D5_LOTECTL+SD5->D5_NUMLOTE
							If SD5->D5_ORIGLAN == "999" .And. SD5->D5_ESTORNO # "S"
								lSoma := .F.
								Exit
							EndIf
							SD5->(dbSkip())
						EndDo
					EndIf
				EndIf
			EndIf

			//Recupera o Saldo por Lote                                   
			nSaldoSB8:=SB8SALDO(,,,,cAliasNew,lEmpPrev,,,.T.)

			//Nao considerar Lotes/SubLotes com saldo zerado na consulta. 
			If MV_PAR02 == 2 .And. nSaldoSB8 == 0
				(cAliasNew)->(dbSkip())
				Loop
			EndIf

			lSoma    := .T.
			dDtValid := (cAliasNew)->B8_DTVALID
			nSaldo   := nSaldoSB8
			nSldTot  += nSaldoSB8	// Saldo Total (saldo do lote)
			nPos     := aScan(aDadosSB8, { |x| x[1] == "Amz "+cLocal+" -> "+cLote+If(lSubLote," - "+cSubL,"") })
			If nSaldo <> 0
				// Captura RECNO do ultimo lote com Saldo   			  
				nRecSldAtu := (cAliasNew)->SB8RECNO
		    EndIf
			If nPos = 0
				// Cria Array com os Lotes/SubLotes para exibir no Tree  
				aAdd(aDadosSB8,{"Amz "+cLocal+" -> "+cLote+If(lSubLote," - "+cSubL,""),"SB8", StrZero((cAliasNew)->SB8RECNO,12) })  //"Amz "
				// Soma a quantidade de Lotes/SubLotes do Tree			  
				// nLotes ++  
			ElseIf nSldTot == 0 .And. nSaldo == 0
				// Lote com saldo Zerado                   			  
				aDadosSB8[nPos,3] := StrZero((cAliasNew)->SB8RECNO,12)
			Else	
				// Posiciona RECNO com ultimo saldo para exibicao correta de legenda  		  
				aDadosSB8[nPos,3] := StrZero((nRecSldAtu),12)
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		
		nLotes:=LEN(aDadosSB8)// Soma a quantidade de Lotes/SubLotes do Tree
        If lSoma
			// Total de quantidades dos Lotes/SubLotes do Produto 	  
			If dDtValid < dDataBase  .And. nSaldo > 0
				nTotVenc ++			// Total de Lotes Vencidos
			ElseIf nSaldo == 0 
				nTotZera ++			// Total de Lotes Zerados
			Else
				nTotUsad ++			// Total de Lotes Em Uso
			EndIf
		EndIf
	
	EndDo
    
	dbSelectArea(cAliasNew)
	dbCloseArea()

	// Posiciona para carregar variaveis de memoria do SD5   
	// Executa esse processo para agilizar na visualizacao   
	dbSelectArea("SD5")
	dbSetOrder(2)
	If dbSeek(xFilial("SD5")+SB1->B1_COD)
		aAdd(aSVAlias,"SD5")
	EndIf

	cNomeFolder := If(Rastro(SB1->B1_COD,"L"),"Lotes","Sub-Lotes")
	cNomeFolder += " -" + If(MV_PAR01==1," Onde é Usado "," Composicao ")

  	//****************** PANEL DAS INFORMACOES DO PRODUTO COM LOGO DA TOTVS ****************** 
	//                                                             LARGURA     ALTURA 
  	oPanel := TPanel():New(1,130,'',oFolder,,.T., .T.,, ,(nRight-nLeft)/2-130,(_nLinFolder-1),.T.,.T. )//(nRight-nLeft)/2-130,nBottom-nTop,.T.,.T. )
  	
  	AADD(aDados,{"Codigo do Produto:"     ,+ALLTRIM(SB1->B1_COD)              })
  	AADD(aDados,{"",""})
  	AADD(aDados,{"Descricao do Produto:"  ,ALLTRIM(SB1->B1_DESC)              })
  	AADD(aDados,{"",""})
  	AADD(aDados,{"Saldo Total do Produto:",ALLTRIM(Trans(nSldTot ,cPictSaldo))})	
  	AADD(aDados,{"",""})
  	AADD(aDados,{"Quantidades de Lotes:"  ,ALLTRIM(Trans(nLotes  ,cPictSaldo))})	
  	AADD(aDados,{"",""})
  	AADD(aDados,{"Qtde. Lotes Vencidos:"  ,ALLTRIM(Trans(nTotVenc,cPictSaldo))})	
  	AADD(aDados,{"",""})
  	AADD(aDados,{"Qtde. Lotes Zerados:"   ,ALLTRIM(Trans(nTotZera,cPictSaldo))})	
  	AADD(aDados,{"",""})
  	AADD(aDados,{"Qtde. Lotes Em Uso:"    ,ALLTRIM(Trans(nTotUsad,cPictSaldo))})	
    
    _nMenos:=19
	aPos:= {0,0,;
	       ((nBottom-nTop)/2)-_nMenos,;//ALTURA
		   (nRight-nLeft)/2-130       }//LARGURA

   	MatScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})

  	//****************** PANEL DAS MOVIMENTACOES DO LOTE/SUBLOTE LISTBOX ****************** 
	//                                                             LARGURA     ALTURA 
  	oPanel1:= TPanel():New(1,130,'',oFolder,,.T., .T.,, ,(nRight-nLeft)/2-130,(_nLinFolder-1),.T.,.T. )//(nRight-nLeft)/2-130,nBottom-nTop,.T.,.T. )
  
	nLargura:=((nRight-nLeft)/2)-130
	nAltura :=((nBottom-nTop)/2)-_nMenos-48

  	If Rastro(SB1->B1_COD,"L")		
       //AADD(aRegs,{cLote,      cHist,cProd,cLocD,cQtde,cLoteForD5,nQtde,cEnde,cNroSerie})
  	   //              1           2     3     4     5       6        7     8       9
  	   @ 46,2 LISTBOX oLbx FIELDS HEADER "Lote"           ,"Historico",If(MV_PAR01==1,"Prod.Dest.","Prod.Orig."),"Amz. Dest","Endereço Requisitado","Num.Serie","Quantidade","Lote do Fornecedor:" SIZE nLargura,nAltura OF oPanel1 PIXEL  
  	Else		
       //AADD(aRegs,{cLote,cSubL,cHist,cProd,cLocD,cQtde,cLoteForD5,nQtde,cEnde,cNroSerie})
  	   //              1      2    3     4     5     6       7        8     9      10    
  	   @ 46,2 LISTBOX oLbx FIELDS HEADER "Lote","Sub-Lote","Historico",If(MV_PAR01==1,"Prod.Dest.","Prod.Orig."),"Amz. Dest","Endereço Requisitado","Num.Serie","Quantidade","Lote do Fornecedor:",SIZE nLargura,nAltura OF oPanel1 PIXEL  
  	EndIf
  	oLbx:SetArray(aRegs)
  	
  	If Len(aRegs) > 0
  	   If Rastro(SB1->B1_COD,"L")					
  	      oLbx:bLine := {|| {aRegs[oLbx:nAT,1],                    aRegs[oLbx:nAT,2], aRegs[oLbx:nAT,3], aRegs[oLbx:nAT,4], aRegs[oLbx:nAT,8], aRegs[oLbx:nAT,09], aRegs[oLbx:nAT,5], aRegs[oLbx:nAT,6]} }
  	   Else			
  	   	  oLbx:bLine := {|| {aRegs[oLbx:nAT,1], aRegs[oLbx:nAT,2], aRegs[oLbx:nAT,3], aRegs[oLbx:nAT,4], aRegs[oLbx:nAT,5], aRegs[oLbx:nAT,9], aRegs[oLbx:nAT,10], aRegs[oLbx:nAT,6], aRegs[oLbx:nAT,7]} }
  	   EndIf
  	EndIf
  
  	oLbx:Hide()
  	oPanel1:Hide()

	//******************** INFORMACOES PARA MONTAGEM DO TREE  ****************************
	nAltura:=((nBottom-nTop)/2)-_nMenos
	nLargura:=129
	//                   nTop,nLeft,nBottom,nRight
	oTree:= dbTree():New(1   , 2   ,nAltura,nLargura   ,oFolder,,,.T.)
	
    oTree:bChange := {|| MC040View(@oTree,@oLbx,@oPanel,@oScroll,@oPanel1,aRegs,aLine) }
	
	oTree:lShowHint:= .F.

	MTC040Tree(@oTree,aDadosSB8,"SB8",.T.)

  	If MV_PAR01 == 1
	   _aTotais[1]:= {nTotVenc,nTotZera,nTotUsad,nSaldo,nSaldoLote}
	   _aObjetos[1]:=oTree
	ELSEIf MV_PAR01 == 2
	   _aTotais[2]:= {nTotVenc,nTotZera,nTotUsad,nSaldo,nSaldoLote} 
	   _aObjetos[2]:=oTree
	ENDIF

 Else

	Help("",1,"Recno")
    _lSair:=.T.

 EndIf

Return oFolder


/*
===============================================================================================================================
Programa----------: MC040View
Autor-------------: Alex Wallauer
Data da Criacao---: 07/11/2024
Descricao---------: Copia da Funcao Static Function MC040View () do (MATC040.PRX)
Parametros--------: oTree,oLbx,oPanel,oScroll,oPanel1,aRegs,aLine,nPasta,lImp
Retorno-----------: .T.
===============================================================================================================================
*/ 
Static Function MC040View(oTree,oLbx,oPanel,oScroll,oPanel1,aRegs,aLine,nPasta,lImp)
 Local cAlias	:= SubStr(oTree:GetCargo(),1,3)
 Local nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
 Local nX
 Local lEmpPrev  := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
 
 DEFAULT nPasta:=(oTFolder01:nOption)
 DEFAULT lImp  :=.F.
 
 IF lImp
    cAlias:="SB8"
 ENDIF
 MV_PAR01:=nPasta//DEFINE O FILTRO PELO FOLDER
 
 Do Case
	
	Case cAlias == "SB1"
		// Exibe informacoes de saldo do Lote/SubLote do Produto 
		oScroll:Hide()
		oPanel1:Hide()
		oLbx:Hide()
		oScroll:Show()
	
	Case cAlias == "SB8"
		
		// Monta ListBox das movimentacoes                       
		aLine := {}
		aRegs := {}
		
		SB8->(MsGoTo(nRecView))
		c040Lote   := SB8->B8_NUMLOTE
		c040LotCtl := SB8->B8_LOTECTL
		c040Produt := SB8->B8_PRODUTO
		c040Local  := SB8->B8_LOCAL
		c040LoteFor:= SB8->B8_LOTEFOR
		nSaldo 	   := SB8SALDO(,,,,,lEmpPrev,,,.T.)
		_dDTValid  := SB8->B8_DTVALID
		nPotencia  := SB8->B8_POTENCI
		cLoteFor   := SB8->B8_LOTEFOR
		lSubLote   := Rastro(c040Produt,"S")
		dCriacao   := DtoC(SB8->B8_DATA)
		aProd      := {}

		If !lSubLote
			nSaldoLote := SaldoLote(c040Produt,c040Local,c040LotCtl)
		Else
			nSaldoLote := SB8SALDO(,,,,,lEmpPrev,,,.T.)
		EndIf

		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+c040Produt))

		//Processa({|lEnd| MontaLine(aLine,NIL,c040LotCtl,c040Lote,c040Produt,c040Local,If(MV_PAR01 == 1,"U","C"),NIL,c040LoteFor,NIL,NIL,@lEnd)},"Rastreamento de Lotes","Aguarde... Rastreando o "+If(Rastro(SB1->B1_COD,"L"),AllTrim("Lote")+" "+c040LotCtl,"Sub-Lote"+" "+c040LotCtl+"/"+c040Lote),.F.)
		MontaLine(aLine,NIL,c040LotCtl,c040Lote,c040Produt,c040Local,If(MV_PAR01 == 1,"U","C"),NIL,c040LoteFor,NIL,NIL)

		If Len(aLine) == 0
			If !lSubLote
				AADD(aRegs,{c040LotCtl         ,"SEM MOVIMENTACAO",'','','','',nil,'',''})
			Else
				AADD(aRegs,{c040LotCtl,c040Lote,"SEM MOVIMENTACAO",'','','','',nil,'',''})
			EndIf
		Else
			cProd := CRIAVAR("B1_COD", .F.)
			For nX := 1 To Len(aLine)
				cLote     := ALLTrim(aLine[nX,1])
				cSubL     := ALLTrim(aLine[nX,2])
				cHist     := ALLTrim(aLine[nX,3])
				cQtde     := ALLTrim(aLine[nX,4])
				cProd     := ALLTrim(aLine[nX,5])
				cLocD     := ALLTrim(aLine[nX,6])
				cLoteForD5:= ALLTrim(aLine[nX,7])
				nQtde     := aLine[nX,8]
				cEnde     := aLine[nX,11]
				cNroSerie := aLine[nX,12]
				
				// Produto Destino
				If !Empty(cProd) .And. MV_PAR01 == 1
					cProd := If(cProd==SB1->B1_COD.And.cLocd==RetFldProd(SB1->B1_COD,"B1_LOCPAD"),CRIAVAR("B1_COD", .F.),cProd)
					cLocD := If(cProd==SB1->B1_COD.And.cLocd==RetFldProd(SB1->B1_COD,"B1_LOCPAD"),CRIAVAR("B1_LOCPAD", .F.),cLocD)
				EndIf

				// Procura Produto Origem
				SD5->(dbSetOrder(1))
				SD5->(dbSeek(xFilial("SD5")+cSubL))
				If Rastro(SB1->B1_COD,"S") .And. SD5->D5_PRODUTO # SB1->B1_COD .And. MV_PAR01 == 2
					cProd := SD5->D5_PRODUTO
					cLocD := SD5->D5_LOCAL
				EndIf

				// Monta array aRegs conforme o rastro do produto
				If !lSubLote
					AADD(aRegs,{cLote      ,cHist,cProd,cLocD,cQtde,cLoteForD5,nQtde,cEnde,cNroSerie})
				Else
					AADD(aRegs,{cLote,cSubL,cHist,cProd,cLocD,cQtde,cLoteForD5,nQtde,cEnde,cNroSerie})
				EndIf
			Next nX
		EndIf
        
	    IF !lImp//QUANDO NÃO CHAMADA DA IMPRESSÃO NÃO TEM TELA PAR ATUALIZAR
 
		    FreeObj(_oSay01)
		    FreeObj(_oSay02)
		    FreeObj(_oSay03)
		    FreeObj(_oSay04)
		    FreeObj(_oSay05)
		    FreeObj(_oSay06)

		    FreeObj(_oGet01)
		    FreeObj(_oGet02)
		    FreeObj(_oGet03)
		    FreeObj(_oGet04)
		    FreeObj(_oGet05)
		    FreeObj(_oGet06)
			
			cSaldoLt := Transform(nSaldoLote,PesqPictQT("B8_SALDO",14))
    
		    // Montagem da tela das informacoes e movimentacoes do   
		    // Lote/SubLote do Produto.                              
		    SB8->(MsGoTo(nRecView))
    
		    @ 04,005 Say _oSay01 PROMPT "Produto:"            Of oPanel1 Size  30,8 Pixel
		    @ 04,210 Say _oSay02 PROMPT "Lote:"               Of oPanel1 Size  30,8 Pixel
		    @ 17,005 Say _oSay03 PROMPT "Lote do Fornecedor:" Of oPanel1 Size  50,8 Pixel
		    @ 17,147 Say _oSay04 PROMPT "Potencia:"           Of oPanel1 Size  30,8 Pixel
		    @ 30,005 Say _oSay05 PROMPT "Saldo do Lote:"      Of oPanel1 Size  40,8 Pixel
		    @ 30,100 Say _oSay06 PROMPT "Validade do Lote:"   Of oPanel1 Size  50,8 Pixel
    
		    //@ 27,210 Button oBtnL Prompt "Visualiza Saldo" Size 48, 13 Of oPanel1 Pixel Action (CEST3ViSa())
    
		    @ 03,030 MsGet _oGet01 VAR SB1->B1_DESC		Of oPanel1 Size 158,8 Pixel READONLY
		    @ 03,230 MsGet _oGet02 VAR c040LotCtl		Of oPanel1 Size  70,8 Pixel READONLY
		    @ 16,060 MsGet _oGet03 VAR cLoteFor 	  	Of oPanel1 Size  70,8 Pixel READONLY
		    @ 16,173 MsGet _oGet04 VAR nPotencia 		Of oPanel1 Size  15,8 Pixel READONLY
		    @ 29,045 MsGet _oGet05 VAR cSaldoLt 	 	Of oPanel1 Size  40,8 Pixel READONLY Right
		    @ 29,148 MsGet _oGet06 VAR DtoC(_dDTValid)	Of oPanel1 Size  40,8 Pixel READONLY Center
    
		    oLbx:SetArray(aRegs)
		    
		    If !lSubLote			
		    	oLbx:bLine := {|| {aRegs[oLbx:nAT,1], aRegs[oLbx:nAT,2], aRegs[oLbx:nAT,3], aRegs[oLbx:nAT,4], aRegs[oLbx:nAT,8], aRegs[oLbx:nAT,9], aRegs[oLbx:nAT,5], aRegs[oLbx:nAT,6]} }		
		    Else			
		    	oLbx:bLine := {|| {aRegs[oLbx:nAT,1], aRegs[oLbx:nAT,2], aRegs[oLbx:nAT,3], aRegs[oLbx:nAT,4], aRegs[oLbx:nAT,5], aRegs[oLbx:nAT,9], aRegs[oLbx:nAT,10], aRegs[oLbx:nAT,6], aRegs[oLbx:nAT,7]} }			
		    EndIf    		
		    oLbx:Show()
		    oLbx:Refresh()
		    oPanel1:Show()
	    ENDIF
 EndCase

 IF !lImp
    oPanel:Refresh()
    oPanel1:Refresh()
    oScroll:Refresh()
 ENDIF
 
Return aRegs


/*
===============================================================================================================================
Programa----------: MTC040Rast
Autor-------------: Alex Wallauer
Data da Criacao---: 07/11/2024
Descricao---------: Copia da Funcao Static Function MontaLine () do (MATC040.PRX)
Parametros--------: aLine,nQuantOrig,c040LotCtl,c040Lote,c040Produt,c040Local,cTipo,aRecOrig,c040LoteFor,cUltSeq,cOP,lEnde,nChamad
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function MontaLine(aLine,nQuantOrig,c040LotCtl,c040Lote,c040Produt,c040Local,cTipo,aRecOrig,c040LoteFor,cUltSeq,cOP,lEnde,nChamad)
 Local aArea    := GetArea()
 Local aAreaSD5 := {}
 Local aAreaSB1 := {}
 Local aAreaBack:= {}
 Local aVarAux  := {}
 Local cLine    := ""
 Local cOpAnt   := ""
 Local cTmSD3   := ""
 Local cNomeCli := ""
 Local cDadosPrd:= ""
 Local cQuery   := ""
 Local cCampos  := "D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL"
 Local cProduto := CriaVar("B1_COD", .F.)
 Local cLocal   := CriaVar("B1_LOCPAD", .F.)
 Local cNewProd := cProduto
 Local cNewLocal:= cLocal
 Local cCompara := xFilial('SD5')+c040Produt+c040Local+c040LotCtl
 Local lSubLote := Rastro(c040Produt,"S")
 Local nSeekChav:= 0 
 Local lRet     := .T.
 Local lNfiscal := .F.
 Local aTamSB1  := TamSX3('B1_COD')
 Local nLote    := TamSX3("D5_LOTECTL")[1]  
 Local nSubLote := TamSX3("D5_NUMLOTE")[1]  
 Local nArmazem := TamSX3("D1_LOCAL")[1] 
 Local nTamLabor:= TamSX3("QEL_LABOR")[1]
 Local cPictQtde:= PesqPictQt("D5_QUANT",15)
 Local cAliasSD5:= "SD5"
 Local cNumOp   := CriaVar("D5_OP", .F.) 
 Local aSDB     := {{"","",0}}
 Local nX := 1
 Local nI := 0
 Local aLotVolta := {}
 Local nD5LotCtl := TamSX3("D5_LOTECTL")[1]
 Local nQELLabor := TamSX3("QEL_LABOR")[1]
 Local cLotAnt   := ""
 Local cFuncSubst:= "SUBSTR"//SUBSTRING
 Local cNumSeri	 := ''
 Local cLocaliz	 := ''
 Local nRecSDB 	 := 0
 
 Default cUltSeq	:= ""
 Default cOP    	:= CriaVar("D5_OP", .F.)
 Default nChamad	:= 0
 Default lEnde		:= .F.
 Default aRecOrig	:= {}
 
 dbSelectArea("SD5")
 dbSetOrder(2)
 aAreaSD5:=GetArea()
 If !Empty(c040Lote).And.lSubLote
 	cCampos +="+D5_NUMLOTE"
 	cCompara+=c040Lote
 EndIf
 RestArea(aAreaSD5)
 
 dbSelectArea("SB1")
 aAreaSB1 := GetArea()
 SB1->(MsSeek(xFilial("SB1") + c040Produt))
 If RetFldProd(SB1->B1_COD,"B1_LOCALIZ") == "S"   
 	lEnde := .T.
 EndIf   
 
 RestArea(aAreaSB1)

	cAliasSD5 := GetNextAlias()
	If Select(cAliasSD5) > 0 
		dbSelectArea(cAliasSD5)
		dbCloseArea()
	EndIf
	cQuery := " SELECT D5_FILIAL,D5_PRODUTO,D5_LOCAL,D5_LOTECTL,D5_NUMLOTE,D5_NUMSEQ,D5_ESTORNO,D5_CLIFOR,D5_LOJA, "
	cQuery += " D5_ORIGLAN,D5_DOC,D5_SERIE,D5_QUANT,D5_OP,D5_LOTEPRD,D5_SLOTEPR,D5_LOTEFOR,SD5.R_E_C_N_O_ RECNOSD5 "
	If lEnde
		cQuery += ", DB_LOCALIZ, DB_NUMSERI, DB_QUANT, SDB.R_E_C_N_O_ RECNOSDB "
		cQuery += " FROM " +RetSqlName('SD5') + ' SD5 '
		cQuery += " LEFT JOIN " +RetSqlName('SDB') + ' SDB'
		cQuery += " ON SD5.D5_FILIAL = SDB.DB_FILIAL AND SD5.D5_PRODUTO = SDB.DB_PRODUTO AND SD5.D5_LOCAL = SDB.DB_LOCAL"
		cQuery += " AND SD5.D5_LOTECTL = SDB.DB_LOTECTL AND SD5.D5_NUMSEQ = SDB.DB_NUMSEQ AND SD5.D5_DOC = SDB.DB_DOC"
		cQuery += " AND SDB.DB_ESTORNO = ' '"
		cQuery += " AND SDB.D_E_L_E_T_ = ' '"
	Else
		cQuery += " FROM " +RetSqlName('SD5') + ' SD5 '
	EndIf

	cQuery += " WHERE "
	cQuery += " SD5.D5_FILIAL      = '"+xFilial("SD5")+"'"
	cQuery += " AND SD5.D5_PRODUTO = '"+c040Produt+"'"
	cQuery += " AND SD5.D5_LOCAL   = '"+c040Local+"'"
	cQuery += " AND SD5.D5_LOTECTL = '"+c040LotCtl+"'"
	If !Empty(c040Lote) .And. lSubLote	
		cQuery += " AND SD5.D5_NUMLOTE = '"+c040Lote+"'"
	EndIf	
	cQuery += " AND SD5.D5_ESTORNO = ' '"
	If Len(aRecOrig) > 0
		cQuery += " AND ("
		For nI:=1 to Len(aRecOrig)
			cQuery += " SD5.R_E_C_N_O_ <> "+ AllTrim(Str(aRecOrig[nI]))
			If Len(aRecOrig) # nI
				cQuery += " OR "
			EndIf
		Next nI	
		cQuery += " )"
	EndIf
	If !Empty(cUltSeq)
		cQuery += " AND SD5.D5_NUMSEQ > '"+cUltSeq+"'"
	EndIf
	cQuery += " AND (SD5.D5_CLIFOR BETWEEN '"+mv_par03+"' AND '"+mv_par04+"')"
	cQuery += " AND (SD5.D5_LOJA BETWEEN '"+mv_par05+"' AND '"+mv_par06+"')"
	
	If cTipo == "C"
		cQuery += " AND ((SD5.D5_ORIGLAN < '500') OR ("+cFuncSubst+"(SD5.D5_ORIGLAN,1,1) IN ('D','P','M'))) "
	ElseIf cTipo == "U"
		cQuery += " AND ((SD5.D5_ORIGLAN > '500') OR ("+cFuncSubst+"(SD5.D5_ORIGLAN,1,1) IN ('R'))) "
	EndIf
	cQuery += " AND SD5.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY "+SqlOrder(SD5->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	
	MPSysOpenQuery( cQuery , cAliasSD5 )
	
	aEval(SD5->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSD5,x[1],x[2],x[3],x[4]),Nil)})
	dbSelectArea(cAliasSD5)

 //ProcRegua(SD5->(LastRec()),23,4) 

 aLotVolta:={}
 Do While (cAliasSD5)->(!Eof()) .And. cCompara == (cAliasSD5)->(&cCampos)
	//IncProc()
	cLine   :=""
	cOpAnt  :=""
	cTmSD3  :=""   
	cProduto:=cNewProd
	cLocal  :=cNewLocal 
	lNfiscal:=.F.
	If lEnde .And. !Empty((cAliasSD5)->DB_NUMSERI)
		If aScan(aLine,{|x|x[5]==(cAliasSD5)->D5_PRODUTO .And. x[1]==(cAliasSD5)->D5_LOTECTL .And. x[12]==(cAliasSD5)->DB_NUMSERI}) <> 0
			(cAliasSD5)->(dbSkip())
			Loop
		EndIf
	Else
		If aScan(aLine,{|x| x[10]==(cAliasSD5)->RECNOSD5 .And. IIF(lEnde,x[13] ==(cAliasSD5)->RECNOSDB,.T.) }) <> 0
			(cAliasSD5)->(dbSkip())
			Loop
		EndIf
	EndIf	

	// Entrada de Material
	If cTipo == "C"
		dbSelectArea("SD1")
		SD1->(dbSetOrder(5))
		// Nota fiscal de Entrada
		If SD1->(MsSeek(xFilial("SD1")+(cAliasSD5)->D5_PRODUTO+(cAliasSD5)->D5_LOCAL+(cAliasSD5)->D5_NUMSEQ ))
			dbSelectArea("SF4")
			If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
				// Pesquisa pelo Nome Reduzido do Cliente OU FORNECEDOR
				dbSelectArea(If(SD1->D1_TIPO $ "DB","SA1","SA2"))
				dbSetOrder(1)
				If MsSeek(xFilial(If(SD1->D1_TIPO $ "DB","SA1","SA2"))+SD1->D1_FORNECE+SD1->D1_LOJA)
					cNomeCli := SubStr(AllTrim(If(SD1->D1_TIPO $ "DB",SA1->A1_NREDUZ,SA2->A2_NREDUZ)),1,15)
				EndIf
				dbSelectArea(cAliasSD5)
				// Remessa para beneficiamento
				If SF4->F4_PODER3 == "R"
					// XXXXXXXXXX XXXXXX NF. p/Benef. N.XXXXXX/XXX
					cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  NF. p/Benef. N."+(cAliasSD5)->D5_DOC+"/"+(cAliasSD5)->D5_SERIE+" "+SD1->D1_LOJA+"-"+AllTrim(SD1->D1_FORNECE)+"/"+cNomeCli	//"  NF. p/Benef. N."
					// Devolucao de beneficiamento
				ElseIf SF4->F4_PODER3 == "D"
					// XXXXXXXXXX XXXXXX Dev. Benef.  N.XXXXXX/XXX
					cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Dev. Benef. N."+(cAliasSD5)->D5_DOC+"/"+(cAliasSD5)->D5_SERIE+" "+SD1->D1_LOJA+"-"+AllTrim(SD1->D1_FORNECE)+"/"+cNomeCli	//"  Dev. Benef. N."
				Else
					// Compra
					If SD1->D1_TIPO == "N"
						// XXXXXXXXXX XXXXXX NF. Compra   N.XXXXXX/XXX
						cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  NF. Compra N."+(cAliasSD5)->D5_DOC+"/"+(cAliasSD5)->D5_SERIE+" "+SD1->D1_FORNECE+"-"+SD1->D1_LOJA+"/"+cNomeCli	//"  NF. Compra N."
						// Devolucao
					ElseIf SD1->D1_TIPO == "D"
						// XXXXXXXXXX XXXXXX NF.Dev.Venda N.XXXXXX/XXX
						cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  NF.Dev.Venda N."+(cAliasSD5)->D5_DOC+"/"+(cAliasSD5)->D5_SERIE	//"  NF.Dev.Venda N."
					EndIf
				EndIf
			EndIf
			lNfiscal := .T.
			dbSelectArea(cAliasSD5)
			// Entrada por movimentos internos
		Else
			dbSelectArea(cAliasSD5)
			cTmSD3:=AC040TM((cAliasSD5)->D5_NUMSEQ,(cAliasSD5)->D5_ORIGLAN)
			If cTmSD3 $ "MAN"
				// XXXXXXXXXX XXXXXX Manutencao de Lote
				cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Manutencao de Lote"	//
			ElseIf cTmSD3 $ "DE0"
				// XXXXXXXXXX XXXXXX Devolucao Manual
				cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Devolucao Manual"	//
			ElseIF cTmSD3 $ "DE1"
				// XXXXXXXXXX XXXXXX Devolucao Automatica
				cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Devolucao Automatica"	//
			ElseIf cTmSD3 $ "DE3/DE4/RE3"
				aLotePara := BuscaLoteRE4((cAliasSD5)->D5_NUMSEQ,(cAliasSD5)->RECNOSD5)
				// XXXXXXXXXX XXXXXX Trf. de  XXXXXXXXXX/XXXXXX
				If !Empty(aLotePara)
					cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+If(cTmSD3=="RE3"," Transferido para processo de ",If(cTmSD3=="DE3"," Transferido de processo ","Transfer.  de   "))+aLotePara[1]+If(Rastro(SB1->B1_COD,"S"),"/"+aLotePara[2],"")
				EndIf
			ElseIf cTmSD3 == "DE6"
				aLotePara := BuscaLoteRE4( (cAliasSD5)->D5_NUMSEQ, (cAliasSD5)->RECNOSD5 )
				If Len(aLotePara) > 0   
					If (cAliasSD5)->D5_LOCAL == cLocCQ
						// XXXXXXXXXX XXXXXX Rejeitado de  XXXXXXXXXX/XXXXXX
						cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Rejeitado de  "+aLotePara[1]+If(Rastro(aLotePara[3],"S"),"/"+aLotePara[2],"")
					Else
						// XXXXXXXXXX XXXXXX Liberado de  XXXXXXXXXX/XXXXXX
						cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Liberado de  "+aLotePara[1]+If(Rastro(aLotePara[3],"S"),"/"+aLotePara[2],"")
					EndIf
					If aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } ) == 0
						aAdd(aRecOrig,(cAliasSD5)->RECNOSD5)
					EndIf
					MontaLine(aLine,(cAliasSD5)->D5_QUANT,aLotePara[1],aLotePara[2],aLotePara[3],aLotePara[4],cTipo,aRecOrig,aLotePara[5],aLotePara[6],/*cOP*/,/*lEnd*/,@nChamad)
					nPos := aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } )
			        If nPos > 0
			           aDel( aRecOrig, nPos )
					   aSize( aRecOrig, Len(aRecOrig)-1 )
					EndIf
				EndIf

			ElseIf cTmSD3 == "DE7"
				aLotePara := BuscaLtRE7( (cAliasSD5)->D5_NUMSEQ , cNumOp )
				// XXXXXXXXXX XXXXXX Desmontagem de XXXXXXXXXX/XXXXXX
				cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+" Desmontagem de "+aLotePara[1]+If(Rastro(aLotePara[3],"S"),"/"+aLotePara[2],"")

			ElseIf Substr(cTmSD3,1,2) == "PR"
				If Len(aLotePara:=BuscaOP(.T.,.T.,(cAliasSD5)->D5_LOTECTL,(cAliasSD5)->D5_NUMLOTE,(cAliasSD5)->D5_NUMSEQ,(cAliasSD5)->D5_OP,(cAliasSD5)->D5_LOTEPRD,(cAliasSD5)->D5_SLOTEPR, (cAliasSD5)->RECNOSD5) ) > 0
					cDadosPrd:= aLotePara[1]+If(lSubLote,aLotePara[2],"")
					cProduto := aLotePara[3]
					cLocal   := aLotePara[4]
				EndIf
				// XXXXXXXXXX XXXXXX Prod. p/OP No. XXXXXXXXXXX
				cLine    := cProduto+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+" Prod. p/OP No. "+(cAliasSD5)->D5_OP	//" Prod. p/OP No. "
				aAreaBack:= GetArea()
				cOpAnt   := (cAliasSD5)->D5_OP
				
				If nNivMax > nChamad
					nChamad++
					dbSelectArea("SD5")
			   		SD5->(dbSetOrder(4))
			   		SD5->(MsSeek(xFilial("SD5")+cOPAnt))
			   		Do While SD5->(!Eof()) .And. xFilial("SD5")+cOpAnt == SD5->D5_FILIAL+SD5->D5_OP
				 		cTmSD3:=AC040TM(SD5->D5_NUMSEQ,SD5->D5_ORIGLAN)
				 		If Substr(cTmSD3,1,2) == "RE" .And. If(!Empty(SD5->D5_LOTEPRD),cDadosPrd == SD5->D5_LOTEPRD+If(lSubLote,SD5->D5_SLOTEPR,""),.T.)
							If aScan( aRecOrig, {|x| x == SD5->(Recno()) } ) == 0
								aAdd(aRecOrig,SD5->(Recno()))
							EndIf
							MontaLine(aLine,SD5->D5_QUANT,SD5->D5_LOTECTL,SD5->D5_NUMLOTE,SD5->D5_PRODUTO,SD5->D5_LOCAL,cTipo,aRecOrig,SD5->D5_LOTEFOR,,,,@nChamad)
							nPos := aScan( aRecOrig, {|x| x == SD5->(Recno()) } )
							If nPos > 0
								aDel( aRecOrig, nPos )
								aSize( aRecOrig, Len(aRecOrig)-1 )
							EndIf
						EndIf					
						SD5->(dbSkip())
					EndDo   
					nChamad--
				EndIf
				RestArea(aAreaBack) 
				dbSelectArea(cAliasSD5)
			EndIf
		EndIf       
		
		// Saida de Material
	ElseIf cTipo == "U" 
		dbSelectArea("SD2")
		SD2->(dbSetOrder(1))
		// Saida atraves de NF
		If SD2->(MsSeek(xFilial("SD2")+(cAliasSD5)->D5_PRODUTO+(cAliasSD5)->D5_LOCAL+(cAliasSD5)->D5_NUMSEQ ))
			dbSelectArea("SF4")
			If SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))
				// Pesquisa pelo Nome Reduzido do Cliente OU FORNECEDOR
				dbSelectArea(If(SD2->D2_TIPO $ "DB","SA2","SA1"))
				dbSetOrder(1)
				If MsSeek(xFilial(If(SD2->D2_TIPO $ "DB","SA2","SA1"))+SD2->D2_CLIENTE+SD2->D2_LOJA)
					cNomeCli := SubStr(AllTrim(If(SD2->D2_TIPO $ "DB",SA2->A2_NREDUZ,SA1->A1_NREDUZ)),1,15)
				EndIf
				dbSelectArea(cAliasSD5)
				// Remessa para beneficiamento
				If SF4->F4_PODER3 == "R"
					// XXXXXXXXXX XXXXXX NF. p/Benef. N.XXXXXX/XXX
					cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  NF. p/Benef. N."+(cAliasSD5)->D5_DOC+"/"+SD5->D5_SERIE+" "+SD2->D2_LOJA+"-"+Alltrim(SD2->D2_CLIENTE)+"/"+cNomeCli	//"  NF. p/Benef. N."
					// Devolucao de beneficiamento
				ElseIf SF4->F4_PODER3 == "D"
					// XXXXXXXXXX XXXXXX Dev. Benef.  N.XXXXXX/XXX
					cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Dev. Benef. N."+(cAliasSD5)->D5_DOC+"/"+(cAliasSD5)->D5_SERIE+" "+SD2->D2_LOJA+"-"+AllTrim(SD2->D2_CLIENTE)+"/"+cNomeCli	//"  Dev. Benef. N."
				Else
					// Venda
					If SD2->D2_TIPO == "N"
						// XXXXXXXXXX XXXXXX NF. Venda    N.XXXXXX/XXX XXXXXX-XX
						cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  NF. Venda N."+(cAliasSD5)->D5_DOC+"/"+(cAliasSD5)->D5_SERIE+" "+SD2->D2_CLIENTE+"-"+SD2->D2_LOJA+"/"+cNomeCli	//"  NF. Venda N."
						// Devolucao
					ElseIf SD2->D2_TIPO == "D"
						// XXXXXXXXXX XXXXXX NF.Dv.Compra N.XXXXXX/XXX
						cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  NF.Dv.Compra N."+(cAliasSD5)->D5_DOC+"/"+(cAliasSD5)->D5_SERIE	//"  NF.Dv.Compra N."
					EndIf
				EndIf
				nQuantOrig:=(cAliasSD5)->D5_QUANT
				lNfiscal := .T.
			EndIf
			dbSelectArea(cAliasSD5)
			// Saida por movimentos internos
		Else	
			dbSelectArea(cAliasSD5)
			cTmSD3:=AC040TM((cAliasSD5)->D5_NUMSEQ,(cAliasSD5)->D5_ORIGLAN)
			If cTmSD3 $ "RE3/RE4"
				aLotePara := BuscaLoteRE4((cAliasSD5)->D5_NUMSEQ,  (cAliasSD5)->RECNOSD5 )
				If Len(aLotePara) > 0
					// XXXXXXXXXX XXXXXX Trf. p/ XXXXXXXXXX/XXXXXX
					cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+If(cTmSD3=="RE3"," Transferido para processo ","Transfer. para  ")+aLotePara[1]+If(Rastro(aLotePara[3],"S"),"/"+aLotePara[2],"")
					nQuantOrig:=(cAliasSD5)->D5_QUANT
					If lSubLote .Or. aLotePara[1] # (cAliasSD5)->D5_LOTECTL
						If aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } ) == 0
							aAdd(aRecOrig,(cAliasSD5)->RECNOSD5)
						EndIf
						MontaLine(aLine,(cAliasSD5)->D5_QUANT,aLotePara[1],aLotePara[2],aLotePara[3],aLotePara[4],cTipo,aRecOrig,aLotePara[5],aLotePara[6],,,@nChamad)
						nPos := aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } )
						If nPos > 0
							aDel( aRecOrig, nPos )
							aSize( aRecOrig, Len(aRecOrig)-1 )
						EndIf
					EndIf
				Else
					cProdD3 := ""
					cLocal  := ""
					SD3->(dbSetOrder(4))
					If SD3->(dbSeek(xFilial("SD3")+(cAliasSD5)->D5_NUMSEQ))
						SD3->(dbSkip())
						cProdD3 := SD3->D3_COD
						cLocal  := SD3->D3_LOCAL
					EndIf
					cLine := cProdD3+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"Transfer. para  "+"PRODUTO SEM RASTREABILIDADE"	//"  Trf. p/ "
					nQuantOrig:=(cAliasSD5)->D5_QUANT
				EndIf

			ElseIf cTmSD3 == "RE6"
				aLotePara := BuscaLoteRE4((cAliasSD5)->D5_NUMSEQ, (cAliasSD5)->RECNOSD5 )
				If (cAliasSD5)->D5_LOCAL == cLocCq
					If SB8->B8_LOCAL == cLocCQ
						// XXXXXXXXXX XXXXXX Rejeitado p/  XXXXXXXXXX/XXXXXX
						cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Rejeitado p/  "+aLotePara[1]+If(Rastro(aLotePara[3],"S"),"/"+aLotePara[2],"")	//"  Rejeitado p/  "
					Else
					// XXXXXXXXXX XXXXXX Liberado p/  XXXXXXXXXX/XXXXXX
						cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Liberado p/  "+aLotePara[1]+If(Rastro(aLotePara[3],"S"),"/"+aLotePara[2],"") //"  Liberado p/  "
					EndIf
					nQuantOrig:=(cAliasSD5)->D5_QUANT
					If lSubLote
						If aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } ) == 0
							aAdd(aRecOrig,(cAliasSD5)->RECNOSD5)
						EndIf
						MontaLine(aLine,(cAliasSD5)->D5_QUANT,aLotePara[1],aLotePara[2],aLotePara[3],aLotePara[4],cTipo,aRecOrig,aLotePara[5],aLotePara[6],,,@nChamad)
						nPos := aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } )
						If nPos > 0
							aDel( aRecOrig, nPos )
							aSize( aRecOrig, Len(aRecOrig)-1 )
						EndIf
					EndIf
				Else
					// XXXXXXXXXX XXXXXX Consumo Interno
					cLine := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Consumo Interno"	// "  Consumo Interno"
				EndIf

			ElseIf cTmSD3 $ "RE0/RE1/RE2/RE5/RE9"
				If !Empty((cAliasSD5)->D5_OP)
					If Len(aLotePara:=BuscaOP(.T.,.T.,(cAliasSD5)->D5_LOTECTL,(cAliasSD5)->D5_NUMLOTE,(cAliasSD5)->D5_NUMSEQ,(cAliasSD5)->D5_OP,(cAliasSD5)->D5_LOTEPRD,(cAliasSD5)->D5_SLOTEPR, (cAliasSD5)->RECNOSD5 ,aLotVolta)) > 0
						// XXXXXXXXXX XXXXXX Op N. XXXXXXXXXXX  XXXXXXXXXX/XXXXXX
						cLine := aLotePara[3]+aLotePara[4]+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Op N. "+(cAliasSD5)->D5_OP+"  "+aLotePara[1]+If(Rastro(aLotePara[3],"S"),"/"+aLotePara[2],"")	//"  Op N. "
						If aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } ) == 0
							aAdd(aRecOrig,(cAliasSD5)->RECNOSD5)
						EndIf
						MontaLine(aLine,(cAliasSD5)->D5_QUANT,aLotePara[1],aLotePara[2],aLotePara[3],aLotePara[4],cTipo,aRecOrig,aLotePara[5],(cAliasSD5)->D5_NUMSEQ,aLotePara[6],,@nChamad)
						nPos := aScan( aRecOrig, {|x| x == (cAliasSD5)->RECNOSD5 } )
						If nPos > 0
							aDel( aRecOrig, nPos )
							aSize( aRecOrig, Len(aRecOrig)-1 )
						EndIf
					Else
						// XXXXXXXXXX XXXXXX Op N. XXXXXXXXXXX  XXXXXXXXXX/XXXXXX
						cLine     := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Op N. "+(cAliasSD5)->D5_OP	//"  Op N. "
						nQuantOrig:=(cAliasSD5)->D5_QUANT
					EndIf	
				Else
					// XXXXXXXXXX XXXXXX Consumo Interno
					cLine     := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+"  Consumo Interno"	//"  Consumo Interno"
					nQuantOrig:=(cAliasSD5)->D5_QUANT
				EndIf
			ElseIf cTmSD3 == "RE7" .And. Empty(cOP)
				// XXXXXXXXXXX XXXXXX Desmontagem p/
				cLine     := c040Produt+cLocal+(cAliasSD5)->D5_LOTECTL+" "+(cAliasSD5)->D5_NUMLOTE+" Desmontagem p/ "+(cAliasSD5)->D5_LOTECTL+If(lSubLote,"/"+(cAliasSD5)->D5_NUMLOTE,"")	   //" Desmontagem p/ "
				nQuantOrig:=(cAliasSD5)->D5_QUANT
			EndIf
		EndIf
	EndIf

	If !Empty(cLine)
		aTam := aTamSB1
		lOp  := .T.
		If Len(aLine) > 0
			// Verifica se o ultimo registro e a da mesma OP
			If SubStr(cLine,aTam[1]+20,6) == "  Op N. "
				If SubStr(cLine,aTam[1]+20,12) == SubStr(aLine[Len(aLine),3],1,12)
					lOp := .F.
				EndIf
			EndIf
		EndIf
		cProduto:= SubStr(cLine,1,aTam[1])
		
		cNumSeri:= IF( lEnde ,(cAliasSD5)->DB_NUMSERI, aSDB[nX][2] )
		cLocaliz:= IF( lEnde ,(cAliasSD5)->DB_LOCALIZ, aSDB[nX][1] )
		nRecSDB := IF( lEnde ,(cAliasSD5)->RECNOSDB  , aSDB[nX][3] )
		
		aVarAux := {SubStr(cLine,aTam[1]+1+ nArmazem, nLote),;                     					    	  				//[01] Lote
					SubStr(cLine,aTam[1]+2+ nArmazem + nLote , nSubLote),;							   						//[02] SubLote
					SubStr(cLine,aTam[1]+2+ nArmazem + nLote + nSubLote,55),;												//[03] Historico
					Trans(IIF(lEnde,(cAliasSD5)->DB_QUANT,(cAliasSD5)->D5_QUANT),cPictQtde),;								//[04] Quantidade (c)
					cProduto,;																								//[05] Prod.Destino/Origem
					SubStr(cLine,aTam[1]+1,len(cLocal)),;																	//[06] Amz Dest
					(cAliasSD5)->D5_LOTEFOR,;																				//[07] Lote do Fornecedor
					If(SubStr(cLine,aTam[1]+1,len(cLocal))==cLocCQ.Or.!lOp,"0",Trans((cAliasSD5)->D5_QUANT,cPictQtde)),; 	//[08] Quantidade (n)
					If(lNfiscal,(cAliasSD5)->D5_NUMSEQ,""),; 																//[09] Se for nota fiscal grava o numero sequencial
					(cAliasSD5)->RECNOSD5,;                 																//[10] Nro registro SD5
					cLocaliz											,;													//[11] Endereço
					cNumSeri											,;													//[12] Nro Serie
					nRecSDB 											}													//[13] Nro Registro SBF
					 

		If !Empty(aLine)
			If lSubLote
				nSeekChav := AsCan(aLine,{|x|x[1]+x[2]+x[3]+x[4]+x[9]==aVarAux[1]+aVarAux[2]+aVarAux[3]+aVarAux[4]+aVarAux[9] .And. x[5]==cProduto .And. x[ 12 ] == cNumSeri .And. x[ 13 ] == nRecSDB } )
 			Else
				nSeekChav := AsCan(aLine,{|x|x[1]+x[3]+x[4]+x[9]==aVarAux[1]+aVarAux[3]+aVarAux[4]+aVarAux[9] .And. x[5]==cProduto .And. x[ 12 ] == cNumSeri .And. x[ 13 ] == nRecSDB } )
			EndIf
			If !Empty(nSeekChav)
				If !lSubLote .And. ( "PR" $ AC040TM((cAliasSD5)->D5_NUMSEQ,(cAliasSD5)->D5_ORIGLAN) )
					aLine[nSeekChav,4] := Trans(Val(aLine[nSeekChav,4])+(cAliasSD5)->D5_QUANT,cPictQtde)
					dbSelectArea(cAliasSD5)
					(cAliasSD5)->(dbSkip())
					Loop
				EndIf
			EndIf
			If lEnde
				nSeekChav := AsCan(aLine,{|x|x[1]+x[3]+x[4]+x[9]+x[11]==aVarAux[1]+aVarAux[3]+aVarAux[4]+aVarAux[9]+aVarAux[11] .And. x[5]==cProduto .And. x[ 12 ] == cNumSeri .And. x[ 13 ] == nRecSDB } )
				If !Empty(nSeekChav)
					dbSelectArea(cAliasSD5)
					(cAliasSD5)->(dbSkip())
					Loop			
				EndIf
			EndIf
		EndIf
	        
		If lRet
			// Cria array com as informacoes das movimentacoes do Lote/SubLote
			aAdd(aLine,aVarAux)
		Endif
		
	EndIf
	dbSelectArea(cAliasSD5)
	(cAliasSD5)->(dbSkip())
 EndDo
 
 (cAliasSD5)->(dbCloseArea())
 
 RestArea(aAreaSD5)
 RestArea(aArea)

Return

/*
===============================================================================================================================
Programa----------: BuscaLoteRE4
Autor-------------: Alex Wallauer
Data da Criacao---: 11/11/2024
Descricao---------: Copia da Funcao Static Function BuscaLoteRE4 () do (MATC040.PRX)
Parametros--------: cNumSeq,nRecno
Retorno-----------: aRetorno
===============================================================================================================================
*/ 
Static Function BuscaLoteRE4(cNumSeq,nRecno)
 Local aOldAlias:= GetArea()
 Local aVolta   := {}
 Default cNumSeq := ""
 Default nRecno  := 0
 
 SD5->(dbSetOrder(3))
 SD5->(dbSeek(xFilial("SD5")+cNumSeq))
 DO While SD5->(!Eof()) .And. xFilial("SD5")+cNumSeq == SD5->(D5_FILIAL+D5_NUMSEQ)
 	//-- Impede o Processamento de Movimenta‡oes Estornadas
 	If !Empty(SD5->D5_ESTORNO)
 		SD5->(dbSkip())
 		Loop
 	EndIf
 	If SD5->(Recno()) != nRecno
 	   aVolta:={SD5->D5_LOTECTL,SD5->D5_NUMLOTE,SD5->D5_PRODUTO,SD5->D5_LOCAL,SD5->D5_LOTEFOR,SD5->D5_NUMSEQ}//06 colunas
 	   Exit
 	EndIf
 	SD5->(dbSkip())
 End
 
 SB8->(dbSetOrder(3))
 SB8->(dbSeek(xFilial("SB8")+SD5->D5_PRODUTO+SD5->D5_LOCAL+SD5->D5_LOTECTL+SD5->D5_NUMLOTE))
 
 RestArea(aOldAlias)
Return (aVolta)

/*
===============================================================================================================================
Programa----------: BuscaLtRE7
Autor-------------: Alex Wallauer
Data da Criacao---: 11/11/2024
Descricao---------: Copia da Funcao Static Function BuscaLtRE7 () do (MATC040.PRX)
Parametros--------: cNumSeq,nRecno
Retorno-----------: aVolta
===============================================================================================================================
*/ 
Static Function BuscaLtRE7(cNumSeqSD5,cNumOp)
 Local aVolta:= {}
 Default cNumSeqSD5 := "" 
 SD5->(DBSETORDER(4))
 If SD5->(MsSeek(xFilial("SD5")+cNumOP+cNumSeqSD5))
 	aVolta:={SD5->D5_LOTECTL,SD5->D5_NUMLOTE,SD5->D5_PRODUTO,SD5->D5_LOCAL,SD5->D5_LOTEFOR,SD5->D5_NUMSEQ}//06 colunas
 EndIf
Return (aVolta)

/*
===============================================================================================================================
Programa----------: BuscaOP
Autor-------------: Alex Wallauer
Data da Criacao---: 11/11/2024
Descricao---------: Copia da Funcao Static Function BuscaOP () do (MATC040.PRX)
Parametros--------: lProducao,lDadosPrd,cLoteCtl,cNumLote,cNumSeq,cOp,cLotePrd,cSLotePr,nRecno,aLotVolta
Retorno-----------: aVolta
===============================================================================================================================
*/ 
Static Function BuscaOP(lProducao,lDadosPrd,cLoteCtl,cNumLote,cNumSeq,cOp,cLotePrd,cSLotePr,nRecno,aLotVolta)
 Local aAreaAnt   := GetArea()
 Local aAreaSD5   := SD5->(GetArea())
 Local cDadosPrd1 := If(lDadosPrd,cLotePrd,"")
 Local cDadosPrd2 := If(lDadosPrd .And. !Empty(cSLotePr),cSLotePR,"")
 Local aVolta     := {}
 Local cSeek     := ""
 Local lAchou     := .F.
 Local nScan		 := 0
 
 Default cLoteCtl := ""
 Default cNumlote := ""
 Default cNumSeq  := ""
 Default cOp      := ""
 Default nRecno   := 0
 Default aLotVolta:= {}
 
 //-- Realiza a Pesquisa nas Movimentacoes pelo Numero da OP
 //-- (Mesmo que as Requisicoes tenham sido Manuais pode-se achar a Producao)
 
 If !Empty(cOP)
	dbSelectArea("SD3")
	dbSetOrder(1)
	SD3->(dbSeek(cSeek := xFilial("SD3")+cOP, .F.))
	
	While !Eof() .And. cSeek == SD3->D3_FILIAL + SD3->D3_OP .And. !lAchou
		If !Empty(SD3->D3_ESTORNO) .And. Empty(SD3->D3_OP)
			SD3->(dbSkip())
			Loop
		EndIf
		If SD3->D3_TM < '500'
			//Se o protudo destino nao tiver rastro, buscar os dados na SD3
			If !Rastro(SD3->D3_COD)
				
				aVolta := {SD3->D3_LOTECTL, SD3->D3_NUMLOTE, SD3->D3_COD, SD3->D3_LOCAL,Posicione("SD5",4,xFilial("SD3")+cOp,"D5_LOTEFOR"),cOP}//06 colunas
			
			//Se tiver rastro, buscar os dados na SD5
			Else
				dbSelectArea("SD5")
				dbSetOrder(4)
				SD5->(dbSeek(cSeek := xFilial("SD5")+cOP, .F.))
	
				//-- Procura Inicialmente pelo Movimento de Producao
				Do While SD5->(!Eof()) .And. cSeek == SD5->D5_FILIAL+SD5->D5_OP .And. !lAchou
					If !Empty(SD5->D5_ESTORNO) .Or. Recno() == nRecno .And. Empty(SD5->D5_OP)
						SD5->(dbSkip())
						Loop
					EndIf
			        nScan := aScan(aLotVolta, SD5->D5_LOTECTL)
					If SD5->D5_ORIGLAN < '500' .And. If(lProducao,(cLoteCtl+cNumLote==SD5->D5_LOTECTL+SD5->D5_NUMLOTE),!(cLoteCtl+cNumLote==SD5->D5_LOTECTL+SD5->D5_NUMLOTE) .and. nScan=0)
						
						aVolta := {SD5->D5_LOTECTL, SD5->D5_NUMLOTE, SD5->D5_PRODUTO, SD5->D5_LOCAL, SD5->D5_LOTEFOR,cOP}//06 colunas
						
						aadd(aLotVolta,SD5->D5_LOTECTL) 
						lAchou := .T.
						If SD5->D5_NUMSEQ == cNumSeq .Or. (!lProducao .And. lDadosPrd .And. cDadosPrd1 == SD5->D5_LOTECTL .And. If(Empty(cDadosPrd2),.T.,cDadosPrd2 == SD5->D5_NUMLOTE))
							lAchou := .T.
						EndIf  
						Loop
					EndIf
					SD5->(dbSkip())
				EndDo
			EndIf						
			If SD3->D3_NUMSEQ == cNumSeq
				lAchou := .T.
			EndIf
		Endif	
		SD3->(dbSkip())
	End    
 EndIf

 RestArea(aAreaSD5)
 RestArea(aAreaAnt)

Return (aVolta)

/*
===============================================================================================================================
Programa----------: A040Imp
Autor-------------: Alex Wallauer
Data da Criacao---: 11/11/2024
Descricao---------: Copia da Funcao Static Function A040Imp () do (MATC040.PRX)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function A040Imp()
 Local cTitulo := "Rastreamento de Lotes"
 Local cDesc1  := "Este programa ira imprimir a Consulta do Produto selecionado"
 Local cDesc2  := "informando o Rastreamento do seu Lote"
 Local cString := "SB8"
 Local cTamanho:= "G"
 Local cPergRel:= "      "
 Local oTree   := _aObjetos[oTFolder01:nOption]//pega o tree da pasta selecionada
 IF oTree = NIL 
 	U_ITMSG("Posicione sobre algum item da consulta do lote de uma das pastas !!!",'Atenção!',,3)
    RETURN .F.
 ENDIF

 Private aReturn := {"Zebrado", 1,"Administracao", 1, 2, 1, "", 1 }   
 Private nLastKey:= 0
 Private wnrel 	:= "MATC040"

 If SubStr(oTree:GetCargo(),1,3) == "SB1"
 	U_ITMSG("Posicione sobre algum item da consulta do lote de uma das pastas !!!",'Atenção!',,3)
 Else
 	wnRel:= SetPrint(cString,wnrel,cPergRel,@cTitulo,cDesc1,cDesc2,"",.F.,"",.F.,cTamanho)
 	If !nLastKey == 27
 		SetDefault( aReturn, cString )
 		If !nLastKey == 27
           _aRegsA:=MC040View(oTree,,,,,_aRegsA,aLine,1,.T.)
           _aRegsB:=MC040View(oTree,,,,,_aRegsB,aLine,2,.T.)

 	       RptStatus({|lEnd| C040Imp(@lEnd,ctitulo,wnRel,0,0,cTamanho,{_aRegsA,_aRegsB})},ctitulo)

		   CETS3Change()

 		EndIf
 	EndIf
 EndIf

Return 


/*
===============================================================================================================================
Programa----------: C040Imp
Autor-------------: Alex Wallauer
Data da Criacao---: 11/11/2024
Descricao---------: Copia da Funcao Static Function C040Imp () do (MATC040.PRX)
Parametros--------: lEnd,ctitulo,wnRel,nSaldo,nSaldoLote,cTamanho,aRegs2
Retorno-----------: .T.
===============================================================================================================================
*/ 
Static Function C040Imp(lEnd,ctitulo,wnRel,nSaldo,nSaldoLote,cTamanho,aRegs2)
 LOCAL cCabec1   := ""
 LOCAL cCabec2   := ""
 LOCAL cNomeProg := "MATC040"
 LOCAL cbtxt     := Space( 10 )
 LOCAL cbcont    := 0
 LOCAL nI := R   := 0
 LOCAL lCol      := .T.
 LOCAL nDifTam   := TamSX3("B1_COD")[1]  // diferenca a ser acrescida as colunas 
 Local nLote	 := TamSX3("D5_LOTECTL")[1]
 Local nLocal    := TamSX3('B2_LOCAL')[1]    
 Local nEnd	     := TamSX3('DB_LOCALIZ')[1]
 Local nNumSeri  := TamSX3('DB_NUMSERI')[1] 
 Local nHistorico:= 0
 Local nEspaco   := 2                   
 Local nTot1 	
 Local nTot2 
 Local nTot3 
 Local nTot4 
 Local nTot5	
 Local nTot6
 Local cPicB8Sld:= PesqPictQT("B8_SALDO",14)
 PRIVATE li:= 80
 PRIVATE m_pag:= 1
 
 //  Posicao do inicio das colunas dos registros impressos         
 For R:=1 to Len(aRegs2)
     aRegsI:=ACLONE(aRegs2[R])
     For nI:=1 to Len(aRegsI) 
     	if (len(aRegsI[nI,2]) > nHistorico)
     		nHistorico := len(aRegsI[nI,2])
     	EndIf
     Next nI
 Next R
 If nHistorico < 24 
 	nHistorico := 55
 EndIf
 If nLote < 10 
 	nLote:=10
 EndIf
 
 If Rastro(SB8->B8_PRODUTO, "L")     
 
 	nTot1 	:= nLote+nEspaco+1 		    	//Historico
 	nTot2 	:= nTot1+nHistorico+nEspaco 	//Produto Origem/Dest.
 	nTot3 	:= nTot2+nDifTam+nEspaco     	//Amz Dest
 	nTot4 	:= nTot3+8+nEspaco 	   			//Endereco	
 	nTot5	:= nTot4+nEnd+nEspaco			//Nro Serie
 	nTot6	:= nTot5+nNumSeri+nEspaco		//Quantidade
 
 Else
 
 	nTot1 	:= nLote+nEspaco+1 		    	//Sublote
    nTot2	:= nTot1+8+nEspaco	   			//Historico
 	nTot3 	:= nTot2+nHistorico+nEspaco 	//Produto Origem/Dest.
 	nTot4 	:= nTot3+nDifTam+nEspaco    	//Amz Dest
 	nTot5 	:= nTot4+8+nEspaco 	   			//Endereco	
 	nTot6	:= nTot5+nEnd+nEspaco			//Nro Serie
 	nTot7	:= nTot6+nNumSeri+nEspaco		//Quantidad	     
 	
 EndIf
 
 //  Inicializa variaveis para controlar cursor de progressao      
 SetRegua( Len(aRegs2[1]) + Len(aRegs2[2]) )
 MV_PAR01=1
 For R:=1 to Len(aRegs2)// 1 e 2

     aRegsI:=ACLONE(aRegs2[R])
     li:=80
     nSaldo    :=_aTotais[R,4]
     nSaldoLote:=_aTotais[R,5]
     cCabec1   := "Rastreamento de Lotes/SubLotes"+" -"+If(R==1," Onde é Usado "," Composicao ")
 
     For nI:=1 to Len(aRegsI)
     
     	Incregua()
     
     	If li > 60
     		li := cabec( cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho )
     		li++
     		@ li,  005 PSAY "Lote" + " " + SB8->B8_LOTECTL  						
     		If Rastro(SB1->B1_COD, "S")
     			@ li,030 PSAY "Sub-Lote" + " " + SB8->B8_NUMLOTE    				
     		EndIf
     		@ li++,050 PSAY "Validade: " + DtoC(SB8->B8_DTVALID)
     		@ li++,005 PSAY "Produto: " + SB8->B8_PRODUTO + " - " + SB1->B1_DESC 
     		@ li++,005 PSAY "Armazem: " + SB8->B8_LOCAL
     		If Rastro(SB1->B1_COD, "S")
     			@ li,005 PSAY  "Lote do Fornecedor: " + SB8->B8_LOTEFOR
     		EndIf
     		li++
     		@ li,  005 PSAY "Saldo:"
     		@ li++,011 PSAY If(Rastro(SB1->B1_COD, "S"), nSaldo, nSaldoLote)  Picture cPicB8Sld 
     		If Rastro(SB1->B1_COD, "S")
     			@ li,005 PSAY "Criacao: " + DtoC(SB8->B8_DATA)
     		EndIf
             li++
     		@ li++,000 PSAY __PrtThinLine()
     		If Rastro(SB8->B8_PRODUTO,"L")
     			@ li,001 PSAY "Lote"+Space(nLote-4+nEspaco)+"Historico dos Movimentos" +Space(nHistorico-24+nEspaco)+If(MV_PAR01=1,"Prod.Dest." ,"Prod.Orig.")+Space(nDifTam+nEspaco-10)+"Amz Dest"+Space(nEspaco)+"Endereço"+Space(nEnd+nEspaco-8)+"Num. de série"+Space(nNumSeri+nEspaco-13)+"Quantidade"
     			lCol := .F.
     		Else	
     			@ li,001 PSAY "Lote"+Space(nLote-4+nEspaco)+"Sub-Lote"+Space(nEspaco)+"Historico dos Movimentos" +Space(nHistorico-24+nEspaco)+If(mv_par01==1,"Prod.Dest." ,"Prod.Orig.")+Space(nDifTam+nEspaco-10)+"Amz Dest"+Space(nEspaco)+"Endereço"+Space(nEnd+nEspaco-8)+"Num. de série"+Space(nNumSeri+nEspaco-13)+"Quantidade"
     		EndIf
     		li ++
     		@ li,000 PSAY __PrtThinLine()
     		li ++
     	EndIf
     
     	@ li,001 	 PSAY  aRegsI[nI,1]		//Lote
     	If lCol
     		@ li,nTot1 PSAY  aRegsI[nI,2]		//SubLote
     		@ li,nTot2 PSAY  aRegsI[nI,3]		//Historico
     		@ li,nTot3 PSAY  aRegsI[nI,4]		//Produto Origem/Dest. 
     		IF len( aRegsI[nI,5]) >0
     	   		@ li,nTot4 PSAY  aRegsI[nI,5]	//Amz Dest
     	 	Else
     			@ li,nTot4 PSAY Space (8)
     		EndIf
     		IF len( aRegsI[nI,8]) >0
     			@ li,nTot5 PSAY  aRegsI[nI,9]		 //Endereco
     		Else     
     			@ li,nTot5 PSAY Space (nEnd)
     		EndIf
     	    If !lSubLote
     	   		@ li,nTot6 PSAY  aRegsI[nI,9]      //Nro Serie
     	   	Else
     			@ li,nTot6 PSAY  aRegsI[nI,10]      //Nro Serie
     			@ li,nTot7  PSAY  aRegsI[nI,6]    //Quantidade	   	
     	   	EndIf	
     	Else
     		@ li,nTot1 PSAY  aRegsI[nI,2]		//Historico
     		@ li,nTot2 PSAY  aRegsI[nI,3]		//Produto Origem/Dest.
     		IF len( aRegsI[nI,4]) >0
     	   		@ li,nTot3 PSAY  aRegsI[nI,4]	//Amz Dest
     		Else
     			@ li,nTot3 PSAY Space (nLocal)
     		EndIf
     		IF len( aRegsI[nI,8]) >0
     			@ li,nTot4 PSAY  aRegsI[nI,8]		//Endereco	
     		Else
     	    	@ li,nTot4 PSAY Space (nEnd)
     	 	EndIf
     		@ li,nTot5 PSAY  aRegsI[nI,9]    //Nro Serie
     		@ li,nTot6 PSAY  aRegsI[nI,5]		//Quantidade
     	EndIf
     	li++
     Next nI
     MV_PAR01=2
 NEXT T

 If li != 80
 	li++
 	roda(cbcont,cbtxt,cTamanho)
 EndIf
 
 If aReturn[5] = 1
 	Set Printer To
 	dbCommitAll()
 	ourspool(wnrel)
 EndIf
 
 MS_FLUSH()

Return( .T. )


/*
===============================================================================================================================
Programa----------: CETS3Change
Autor-------------: Alex Wallauer
Data da Criacao---: 11/11/2024
Descricao---------: Funcao Executa na troca de pasta, pesquisa e impressao
Parametros--------: Nenhum
Retorno-----------: .T.
===============================================================================================================================
*/ 
Static Function CETS3Change()

 IF oTFolder01:nOption = 1
   IF LEN(_aRegsA) > 0
      MC040View(@_oTree1,@_oLbx1,@_oPanelA,@_oScrollA,@_oPanel1A,_aRegsA,aLine)
   ENDIF
 ELSE
   IF LEN(_aRegsB) > 0
      MC040View(@_oTree2,@_oLbx2,@_oPanelB,@_oScrollB,@_oPanel1B,_aRegsB,aLine)
   ENDIF
 Endif

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS66Pesq
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/06/2022
Descrição---------: Pesquisa de Armazem + Lote ou somente Lote
Parametros--------: Nenhum
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function CEST3Pesq()
 Local _oGet1  as object
 Local _oDlg	  as object
 Local _cGet1  := Space(25)
 Local _nOpca  := 0
 Local nPos	  := 0
 Local _lAchou := .F.
 Local oTree   := _aObjetos[oTFolder01:nOption]//pega o tree da pasta selecionada
  
 IF oTree = NIL 
    U_ITMSG("Posicione sobre algum item da consulta do lote de uma das pastas !!!",'Atenção!',,3)
    RETURN .F.
 ENDIF
 
 DEFINE MSDIALOG _oDlg TITLE "Pesquisa de Armazem + Lote ou somente Lote" FROM 178,181 TO 259,697 PIXEL 
 
 @005,003 SAY "Digite Arm + -> + Lote, Ex.: 11 -> 123456789012345678 "Of _oDlg Size  330,8 Pixel	//cLocal+" -> "+cLote
 
 @020,003 MsGet _oGet1 Var _cGet1 Size 212,009 PIXEL OF _oDlg COLOR CLR_BLACK Picture "@!" 
 
 DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlg:End() ) OF _oDlg
 DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlg:End() ) OF _oDlg
 
 ACTIVATE MSDIALOG _oDlg CENTERED
 
 If _nOpca == 1
    _cGet1 := ALLTRIM( _cGet1 )
    IF oTFolder01:nOption = 1 
       _aDadosTree:=_aDadoTre1
    ELSE
       _aDadosTree:=_aDadoTre2
    ENDIF
    If (nPos := ASCAN(_aDadosTree,{|P| _cGet1 $ P[1]  }) ) <> 0 
       _cCargo:=AllTrim(_aDadosTree[nPos,2]+_aDadosTree[nPos,3])
    	  _lAchou:=oTree:TreeSeek(_cCargo)
    EndIf				
 ELSE
    RETURN .F.
 EndIf
 
 If _lAchou
    //U_ITMSG("O Lote "+_cGet1+" esta na linha "+ALLTRIM(STR(nPos)) ,'Atenção!',,2) 
    CETS3Change()
 ELSE
    U_ITMSG("O Lote "+_cGet1+" não foi encontrado." ,'Atenção!',,3) 
 EndIf

RETURN .T.


/*
===============================================================================================================================
Programa----------: MOMS66Pesq
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/06/2022
Descrição---------: Visualiza Saldo
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
//Static Function CEST3ViSa()
// //Verifica quel é o folder atual FOLDER ATUAL
// IF oTFolder01:nOption = 1
//    nSaldoLote:=_aTotais[1,5]
//    aRegs:=ACLONE(_aRegsA)
//	_oPanel1A:End()
// ELSE
//    nSaldoLote:=_aTotais[2,5]
//    aRegs:=ACLONE(_aRegsB)
//	_oPanel1B:End()
// ENDIF 
// IF LEN(aRegs) > 0
//    C040SldLT(SB8->B8_LOTECTL,SB8->B8_NUMLOTE,nSaldoLote)
// ENDIF
//RETURN
