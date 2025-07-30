/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |17/04/2023| Chamado 43586. Inclusao da frase "ESTOQUE LIBERADO".
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE ALIGN_H_LEFT   	0
#DEFINE ALIGN_H_RIGHT  	1
#DEFINE ALIGN_H_CENTER 	2
#DEFINE ALIGN_V_CENTER 	0
#DEFINE ALIGN_V_TOP	   	1
#DEFINE ALIGN_V_BOTTON 	2

/*
===============================================================================================================================
Programa----------: REST020
Autor-------------: Alex Wallauer
Data da Criacao---: 08/08/2022
Descrição---------: Emissão de etiquetas de produtos, CHAMADO 40573
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function REST020

LOCAL nI
LOCAL _bOK:=NIL
PRIVATE _aParAux:={}
PRIVATE _aParRet:={}
PRIVATE _aItensLote:= {}
PRIVATE _cDifVal:=""

_aItalac_F3:={}


_BSelectSB8:={|| "SELECT DISTINCT B8_LOCAL, NNR_DESCRI  FROM "+RETSQLNAME("SB8")+" SB8, "+RETSQLNAME("NNR")+" NNR WHERE"+;
                 " B8_FILIAL = '"+cFilAnt+"' AND"+;
                 " B8_LOCAL = NNR_CODIGO AND"+;
				 IF(!EMPTY(MV_PAR02)," B8_LOTECTL IN "+FormatIn(ALLTRIM(MV_PAR02),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR03)," B8_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR03),";")+" AND","")+;
				 " SB8.D_E_L_E_T_ = ' ' AND NNR.D_E_L_E_T_ = ' ' ORDER BY B8_LOCAL " }

//Italac_F3:={}         1           2         3                          4                       5            6             7         8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave               , _nCpoDesc               ,_bCondTab , _cTitAux      , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR01"   ,_BSelectSB8,{|Tab|(Tab)->B8_LOCAL},{|Tab| (Tab)->NNR_DESCRI},          ,"Locais"       ,          ,          ,        ,.F.        ,       , } )

_BSelectSB8:={|| "SELECT DISTINCT B8_LOTECTL, B8_DFABRIC, B8_DTVALID FROM "+RETSQLNAME("SB8")+" SB8 WHERE"+;
                 " B8_FILIAL = '"+cFilAnt+"' AND"+;
                 " SUBSTR(B8_LOTECTL,1,1) <> '#' AND"+;
                 " B8_SALDO > 0 AND"+;
				 IF(!EMPTY(MV_PAR01)," B8_LOCAL   IN "+FormatIn(ALLTRIM(MV_PAR01),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR03)," B8_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR03),";")+" AND","")+;
				 " D_E_L_E_T_ = ' ' ORDER BY B8_LOTECTL " }

//Italac_F3:={}         1           2         3                                   4                                                                                        5            6             7             8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave                         , _nCpoDesc                                                                              ,_bCondTab , _cTitAux, _nTamChv            , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR02"   ,_BSelectSB8,{|Tab| (Tab)->B8_LOTECTL },{|Tab| "Dt Fab.: "+DTOC(STOD((Tab)->B8_DFABRIC))+", Dt Val.: "+DTOC(STOD((Tab)->B8_DTVALID)) },          ,"Lotes"  , LEN(SB8->B8_LOTECTL),          ,           ,.F.       ,       , } )


_bSelItemSB8:={|| "SELECT DISTINCT B8_PRODUTO, B1_DESC  FROM "+RETSQLNAME("SB8")+" SB8,"+RETSQLNAME("SB1")+" SB1 WHERE"+;
                 " B8_FILIAL = '"+cFilAnt+"' AND"+;
                 " B8_PRODUTO = B1_COD AND"+;
                 " B8_PRODUTO <> '   ' AND"+;
				 IF(!EMPTY(MV_PAR01)," B8_LOCAL   IN "+FormatIn(ALLTRIM(MV_PAR01),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR02)," B8_LOTECTL IN "+FormatIn(ALLTRIM(MV_PAR02),";")+" AND","")+;
				 " SB8.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' '  ORDER BY B8_PRODUTO " }

//Italac_F3:={}         1           2         3                                   4                 5            6             7             8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave                         , _nCpoDesc       ,_bCondTab , _cTitAux, _nTamChv  , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03"   ,_bSelItemSB8,{|Tab|AllTrim((Tab)->B8_PRODUTO)},{|Tab|(Tab)->B1_DESC}   , ,"Produtos", 11       ,          ,        ,.F.        ,       , } )

aTitCol:={}
AADD(aTitCol,"Local")          //01
AADD(aTitCol,"Lote")           //02
AADD(aTitCol,"Data Fabricacao")//03
AADD(aTitCol,"Data Validade")  //04
AADD(aTitCol,"Produto")        //05
AADD(aTitCol,"Descricao")      //06
nPosDes:=LEN(aTitCol)
AADD(aTitCol,"Saldo")          //07
AADD(aTitCol,"Qtde Etiquetas") //08
AADD(aTitCol,"Registro")       //09


_lNovo:=U_ITMSG( "IMPRESSAO: É Referente a lote Novo ou Existente ? ",'IMPRESSAO',,2,2,3,,"NOVO","EXISTENTE")

DO WHILE .T.

    IF !_lNovo
    
       MV_PAR01:=SPACE(100)
       MV_PAR02:=SPACE(350)
       MV_PAR03:=SPACE(100)
	   _aParAux:={}
       AADD( _aParAux , { 1 , "Local"    , MV_PAR01, "@!"  , ""  ,"F3ITLC", "" , 100 , .T. } ) 
       AADD( _aParAux , { 1 , "Lotes"    , MV_PAR02, "@!"  , ""  ,"F3ITLC", "" , 100 , .T. } ) 
       AADD( _aParAux , { 1 , "Produtos" , MV_PAR03, "@!"  , ""  ,"F3ITLC", "" , 100 , .T. } ) 
	   _aParRet:={}
       For nI := 1 To Len( _aParAux )
           AADD( _aParRet , _aParAux[nI][03] )
       Next nI
    
                                                      //        aParametros,cTitle,aRet      ,bOk  ,aButtons,lCentered,nPosX,nPosY,oDlgWizard,cLoad,lCanSave,lUserSave
    	IF !ParamBox( _aParAux , "GERACAO DE ETIQUETAS DE ITENS - LOTE Existente" , @_aParRet, _bOK,        ,         ,     ,     ,          ,     ,.F.     ,.F. )
    		EXIT
    	EndIf
    
    ELSE // NOVO LOTE
    
       MV_PAR01:=SPACE(11)
       MV_PAR02:=DATE()
       MV_PAR03:=SPACE(LEN(SA2->A2_COD))
       MV_PAR04:=SPACE(LEN(SA2->A2_LOJA))
       MV_PAR05:=SPACE(LEN(SB8->B8_PRODUTO))
       
	   _aParAux:={}
       AADD( _aParAux , { 1 , "Lote"          , MV_PAR01, "@!"  , ""  ,"   ", "" , 050 , .T. } ) 
       AADD( _aParAux , { 1 , "Data Validade" , MV_PAR02, "@D"  , ""  ,"   ", "" , 050 , .T. } ) 
       AADD( _aParAux , { 1 , "Fornecedor"    , MV_PAR03, "@!"  , ""  ,"SA2", "" , 050 , .T. } ) 
       AADD( _aParAux , { 1 , "Loja"          , MV_PAR04, "@!"  , ""  ,"   ", "" , 050 , .T. } ) 
       AADD( _aParAux , { 1 , "Produto"       , MV_PAR05, "@!"  , ""  ,"SB1", "" , 050 , .T. } ) 
    
	   _aParRet:={}
       For nI := 1 To Len( _aParAux )
           AADD( _aParRet , _aParAux[nI][03] )
       Next nI
                                                      //        aParametros,cTitle,aRet      ,bOk  ,aButtons,lCentered,nPosX,nPosY,oDlgWizard,cLoad,lCanSave,lUserSave
    	IF !ParamBox( _aParAux , "GERACAO DE ETIQUETAS DE ITENS - LOTE Novo"      , @_aParRet, _bOK,        ,         ,     ,     ,          ,     ,.F.     ,.F. )
    		EXIT
    	EndIf
    
    ENDIF
	
    U_ITLOGACS()

	lTemSobra:=.F.
	_aItensLote:={}
	_aBrowseT:={}

    FWMSGRUN( ,{|oproc| REST020Ler(oproc,_lNovo) } ,'Aguarde!','lendo itens/Lotes...'  )

    IF LEN(_aItensLote) > 0
       
       aSize:=NIL
       cTit1:="Lista dos Lotes / itens para imprimir as etiquetas"
       cTit2:=cTit1
       bDblClk:={|| REST020GET(@oLbxAux)}

       _abuttons:={}
      IF _lNovo
	     aAdd(_abuttons,{"",{|| REST020Ler(,.T.) },"","Incluir Etiquetas"} )
	  ENDIF

       DO WHILE .T.    

    //            ITListBox(_cTitAux , _aHeader , _aCols     , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda)
          lRet:=U_ITLISTBOX(cTit1    , aTitCol  , _aItensLote, .T.      , 1      , cTit2    ,          , aSize   ,         ,     ,        , _abuttons,       ,bDblClk )//, _aColXML , bCondMarca,_bLegenda)
    
          IF lRet
	         lSair:=.F.
             
			 Processa( {||  lSair:=REST020B() }, "Aguarde...", "Gerando Etiquetas...",.F.)

             IF !lSair
		        Loop
		     ENDIF
          ENDIF
	      EXIT
	   ENDDO
    ELSE
       Loop
    ENDIF
   
ENDDO

RETURN 
/*
===============================================================================================================================
Programa----------: REST020Ler
Autor-------------: Alex Wallauer
Data da Criacao---: 08/08/2022
Descrição---------: LER OS ITENS DA NF
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================*/  

STATIC FUNCTION REST020Ler(oProc,_lNovo)
Local _cAlias := GetNextAlias()
Local _nConta :=0
Local _cQrySB8:= " SELECT R_E_C_N_O_  RECSB8 "
SB1->(DBSetOrder(1))

IF _lNovo

   IF oProc = NIL
	  IF !ParamBox( _aParAux , "GERACAO DE ETIQUETAS NOVAS" , @_aParRet,   ,, .T. , , , , , .T. , .T.)
	  	 RETURN .F.
	  EndIf
   EndIf


   SB1->(DBSEEK(xFilial("SB1")+MV_PAR05))
   _aItem:={}
   AADD(_aItem,"")      //01
   AADD(_aItem,ALLTRIM(MV_PAR01)+ALLTRIM(MV_PAR03)+ALLTRIM(MV_PAR04))//02
   AADD(_aItem,"")                   //03
   AADD(_aItem,DTOC(MV_PAR02))       //04
   AADD(_aItem,MV_PAR05)             //05
   AADD(_aItem,SB1->B1_DESC)         //06
   AADD(_aItem,0)                    //07
   AADD(_aItem,1)                    //08
   AADD(_aItem,0)                    //09   
   AADD(_aItensLote,_aItem)
   IF oProc = NIL
      oLbxAux:Refresh()
      PROCESSMESSAGES()
   ENDIF

   RETURN .T./////////////////////////// SAIDA QUANDO É NOVO
ENDIF

_cQrySB8 += " FROM " + RetSqlName("SB8") + " SB8 "
_cQrySB8 += " WHERE SB8.D_E_L_E_T_ = ' ' "
_cQrySB8 += " AND B8_FILIAL = '"+cFilAnt+"' "
_cQrySB8 += " AND SUBSTR(B8_LOTECTL,1,1) <> '#' "
_cQrySB8 += " AND B8_SALDO > 0 "
IF !EMPTY(MV_PAR01)
   _cQrySB8 += " AND B8_LOCAL IN "+FormatIn(ALLTRIM(MV_PAR01),";")
ENDIF
IF !EMPTY(MV_PAR02)
   _cQrySB8 += " AND B8_LOTECTL IN "+FormatIn(ALLTRIM(MV_PAR02),";")
ENDIF
IF !EMPTY(MV_PAR03)
   _cQrySB8 += " AND B8_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR03),";")
ENDIF
_cQrySB8 += " ORDER BY B8_LOCAL, B8_LOTECTL, B8_PRODUTO"
_cQrySB8 := ChangeQuery(_cQrySB8)

MPSysOpenQuery(_cQrySB8,_cAlias)

DbSelectArea(_cAlias)
COUNT TO _nQtdReg
(_cAlias)->(DBGOTOP())
_cTotal:=ALLTRIM(STR(_nQtdReg))

IF EMPTY( _nQtdReg )
   U_ITMSG("Nao tem dados para consultar com os filtros selecionados","Atenção","Verifique / altere o filtros selecionados",3)
   RETURN .F.
ELSEIF _nQtdReg > 500 .AND. !U_ITMSG( "Serão processados "+_cTotal+" registros. Deseja Continuar?",'ATENCAO!',,3,2,2)
   RETURN .F.
ENDIF

_aItensLote:= {}

DO While ! (_cAlias)->(EOF())                           
  
   SB8->(DBGOTO((_cAlias)->RECSB8))

   _nConta++
   oProc:cCaption := "Lendo Item: "+SB8->B8_PRODUTO+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal
   PROCESSMESSAGES()
   
   SB1->(DBSEEK(xFilial("SB1")+SB8->B8_PRODUTO))
      
    _aItem:={}
	AADD(_aItem,SB8->B8_LOCAL  )      //01
	AADD(_aItem,SB8->B8_LOTECTL)      //02
	AADD(_aItem,DTOC(SB8->B8_DFABRIC))//03
	AADD(_aItem,DTOC(SB8->B8_DTVALID))//04
	AADD(_aItem,SB8->B8_PRODUTO)      //05
	AADD(_aItem,SB1->B1_DESC   )      //06
	AADD(_aItem,SB8->B8_SALDO  )      //07
	AADD(_aItem,1  )                  //08
	AADD(_aItem,SB8->(RECNO()) )      //09

    AADD(_aItensLote,_aItem)

   
    (_cAlias)->(DbSkip())
EndDo   

RETURN .T.

/*
===============================================================================================================================
Programa----------: REST020B
Autor-------------: Alex Wallauer
Data da Criacao---: 08/08/2022
Descrição---------: Ler os dados do listbox
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function REST020B()
LOCAL NF
Local cLocal:=GetTempPath()

lImpDataVal:=!U_ITMSG( "IMPRESSAO: É Embalagem Tetra ? ",'IMPRESSAO',,2,2,2)

cFileName:="REST020_"
cFileName+=DToS( DATE() ) + "_"
cFileName+=StrTran(TIME(), ":" , "" )
cFileName:=cFileName+".pdf"
       //FWMsPrinter():New(cFilePrintert,nDevice],lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
oPrint:= FwMsPrinter():New(cFileName    , IMP_PDF, .T.            , cLocal          , .T.          )//, .T.        ,  NIL           , NIL        , NIL       , NIL         , NIL    , .F.        , NIL         )
oPrint:SetPortrait()            // Fixa a Impressao em Retrato //oPrint:SetLandScape()
oPrint:cPathPDF := cLocal	// Caso seja utilizada impressão em IMP_PDF
oPrint:Setup()
IF UPPER(oPrint:cPathPDF) == "C:\" .OR. EMPTY(oPrint:cPathPDF)
   oPrint:cPathPDF := cLocal
ENDIF

IF oPrint:nModalResult = 2//APERTOU O CANCELA
   RETURN .F.
ENDIF

FOR NF:= 1 to LEN(_aItensLote)

    _nAte:= _aItensLote[NF,  LEN(_aItensLote[NF])-1 ]
	IF _nAte = 0
	   LOOP
	ENDIF
	IF _lNovo
	   _cLote     :=_aItensLote[NF,2] 
	   _cDtVal    :=CTOD(_aItensLote[NF,4])
       _cProduto  :=_aItensLote[NF,5]
       _cDescricao:=_aItensLote[NF,6] 
    ELSE
	   SB8->(DBGOTO(_aItensLote[NF, LEN(_aItensLote[NF]) ]))
       _cProduto  := SB8->B8_PRODUTO
       _cDescricao:= Posicione('SB1',1,xFilial("SB1")+SB8->B8_PRODUTO,"B1_DESC")//_aItensLote[NF,  nPosDes ]
	   _cLote     := SB8->B8_LOTECTL
	   _cDtVal    := SB8->B8_DTVALID//SB8->B8_LOCAL
    ENDIF

    lSair:=REST020C(NF) 

	IF lSair
	   RETURN .F.
	ENDIF

NEXT NF

LjMsgRun( "Gerando a visualização..." , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir

Return .T.
/*
===============================================================================================================================
Programa----------: REST020C
Autor-------------: Alex Wallauer
Data da Criacao---: 08/08/2022
Descrição---------: Impressão de multiplas etiquetas
Parametros--------: _nTotEtiq
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function REST020C(_nTotEtiq)
Local  ni
Local ncoluna  :=15
Local nTamFonte:=05
Local nlinhaIni:=35
Local nLinhAux1:=10//35
Local _nEsqu1  :=010  //COLUNA INICIAL ESQUERDA
Local ntamh    :=1080 //COLUNA DA DIREITA / LARGURA DA ETIQUETA
Local nMeio    :=100//(ncoluna+ntamh)/2 //COLUNA do MEIO

//                       Fonte      Tamanho         Negrito
oFont15  := TFont():New("Arial", , (15+nTamFonte  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Arial", , (10+nTamFonte  ), .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont12n := TFont():New("Arial", , (10+nTamFonte+1), .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont20  := TFont():New("Arial", , (20+nTamFonte  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)

cerros := ""
procregua(LEN(_aItensLote))
SA1->(DbSetOrder(1))

FOR ni := 1 TO  _nAte
	
	nlinha := nlinhaIni
	
	incproc("Imprimindo etiqueta: " + strzero(_nTotEtiq,5) + " de " + strzero(LEN(_aItensLote),5))

	
	oPrint:StartPage()              // Inicializa a Pagina de Impressao

	oPrint:Line(nlinha+nLinhAux1,ncoluna - 5 , nlinha+nLinhAux1 , ncoluna + ntamh, 0 , "-6")//LINHA INICIAL
	nLinha += 001
//======================================= EMPRESA =========================================================

	nColTot	:= oPrint:nPageWidth / oPrint:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels
	nMeio    := int(nColTot / 4)
	nColCab2 := ( nColTot / 3 ) * 2
	nLargura := 800
	nAltura  := 100

   //SayAlign ( < nRow>, < nCol>                   , < cText>                          , oFont   ,nWidth ,nHeigth,nClrText,nAlignHorz,nAlignVert)
	oPrint:SayAlign(nLinha+nLinhAux1, nMeio,"Goiasminas Indústria de Laticínios Ltda"  , oFont12n,nLargura,nAltura,       ,ALIGN_H_CENTER)
	nLinha += 050
	oPrint:Line(nlinha+nLinhAux1,ncoluna - 5,nlinha+nLinhAux1,ncoluna + ntamh, 0 , "-6")
	nLinha += 010
		
	oPrint:SayAlign(nLinha+nLinhAux1, nMeio, cFilAnt + "  -  " + AllTrim(FWFilialName(cEmpAnt,cFilAnt,1)) , oFont12n,nLargura,nAltura,        ,ALIGN_H_CENTER)
	nLinha += 050
	oPrint:Line(nlinha+nLinhAux1,ncoluna - 5,nlinha+nLinhAux1,ncoluna + ntamh, 0 , "-6")
	nLinha += 075

//======================================= PRODUTO =========================================================
    _cDescricao:=alltrim(_cDescricao)
    nColAux:=40
    nTam:=30
	IF LEN(_CDESCRICAO) > nTam
	   oPrint:Say(nLinha+nLinhAux1, nColuna+nColAux,+MEMOLINE(_CDESCRICAO,nTam,1),oFont20)
	   nLinha += 075
	   oPrint:Say(nLinha+nLinhAux1, nColuna+nColAux,+MEMOLINE(_CDESCRICAO,nTam,2),oFont20)
	ELSE
	   oPrint:Say(nLinha+nLinhAux1, nColuna+nColAux,_CDESCRICAO,oFont20)
	ENDIF
	nLinha += 025

	oPrint:Line(nlinha+nLinhAux1,ncoluna - 5,nlinha+nLinhAux1,ncoluna + ntamh, 0 , "-6")
	
	nLinha   += 030
	nLinBar  :=nLinha+nLinhAux1
	nColBar  :=nColuna + _nEsqu1+20
	nLagBar  :=1//0.0167
	nAltBar  :=50//0.7
    nLagBar2 :=270
	
    ccodbar1:=ALLTRIM(_cProduto)
               
    oPrint:Code128(nLinBar ,nColBar ,ccodbar1,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)//CODIGO DE BARRA DO PEDIDO DE COMPRA
	nLinha += 210

    oPrint:SayAlign(nLinha+nLinhAux1, nMeio , ccodbar1 , oFont12n,nLargura,nAltura,,ALIGN_H_CENTER)//NUMERO DO PRODUTO DO CODIGO DE BARA ACIMA

//***************************************** LOTE ****************************************************************//
	nLinha += 075
	oPrint:Line(nlinha+nLinhAux1   ,ncoluna - 5       , nlinha+nLinhAux1 ,ncoluna + ntamh, 0 , "-6")//FECHA A LINHA
	nLinha += 075
	
	oPrint:Say(nLinha+nLinhAux1, nColuna+nColAux , "LOTE: "+_cLote , oFont20)
	nLinha += 025
	
	oPrint:Line(nlinha+nLinhAux1,ncoluna - 5,nlinha+nLinhAux1,ncoluna + ntamh, 0 , "-6")
	nLinha +=030
	
	ccodbar2 := ALLTRIM(_cLote)
	nLinBar  := nLinha +nLinhAux1
	nLagBar  := 1//0.0166//01//
	
    oPrint:Code128(nLinBar ,nColBar    ,ccodbar2,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)//CODIGO DE BARRA
    
	nLinha += 210
	_lColAux:=48
	oPrint:SayAlign(nLinha+nLinhAux1, (nMeio-_lColAux) , ccodbar2 , oFont12n,(nLargura+200),nAltura,,ALIGN_H_CENTER)//NUMERO DO LOTE DO CODIGO DE BARRA
	nLinha += 050

//**************************************** DATA DE VALIDADE **************************************************//
	IF lImpDataVal
  	   oPrint:Line(nlinha+nLinhAux1   ,ncoluna - 5       , nlinha+nLinhAux1 ,ncoluna + ntamh, 0 , "-6")//FECHA A LINHA
  	   nLinha += 075
       oPrint:Say(nLinha+nLinhAux1, nColuna+nColAux , "DATA DE VALIDADE: "+DTOC(_cDtVal) , oFont20)
   	   nLinha += 025
    ENDIF
	
	oPrint:Line(nlinha+nLinhAux1,ncoluna - 5,nlinha+nLinhAux1,ncoluna + ntamh, 0 , "-6")
	nLinha +=030
	
	ccodbar2 := DTOS(_cDtVal)
	nLinBar  := nLinha+nLinhAux1 
	nLagBar  := 1//0.0166//01//
	nLagBar2 := 100
    oPrint:Code128(nLinBar ,nColBar+340 ,ccodbar2,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)//CODIGO DE BARRAS
    
	nLinha += 250
	_lColAux:=475
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1+_lColAux, ccodbar2 , oFont12n)//DATA DO CODIGO DE BARRA

	nLinha += 025
	
	oPrint:Line(nlinha+nLinhAux1,ncoluna - 5,nlinha+nLinhAux1,ncoluna + ntamh, 0 , "-6")
    
	nLinha += 075
    
	_lColAux:=180
	oPrint:Say(nLinha+nLinhAux1, nColuna+nColAux+_lColAux , "ESTOQUE LIBERADO" , oFont20)

	oPrint:EndPage()                // Finaliza a Pagina de Impressao

NEXT ni
Return .F. //NAO SAIR 

/*
===============================================================================================================================
Programa----------: REST020GET
Autor-------------: Alex Wallauer
Data da Criacao---: 08/08/2022
Descrição---------: Rotina de duplo clique na linha do browse
Parametros--------: oLbxAux
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST020GET(oLbxAux)
Local _nLinPos  := oLbxAux:nAt
Local _bOK
Local _nlin:=10
Local _nPula:=20
LOCAL _nColQtde:=LEN(_aItensLote[_nLinPos])-1

_nQtde :=_aItensLote[_nLinPos,_nColQtde]

_bOK:={|| IF(_nQtde >= 0 ,.T.,(U_ITMSG("Quantidade INVALIDA",'Atenção!',"A quantidade deve ser maior que zero",3),.F.) ) }

lOK:=.F.	
@ 00,00 To 145,280 Dialog oDlgDes Title "Quantidade de copias de Etiqueta"
    
    @ _nlin,10 say "Quantidade:" Pixel of oDlgDes
    @ _nlin,50 MsGet _nQtde Picture "@E 999,999"  Pixel Of oDlgDes

    _nlin += _nPula
	@ _nlin,50 BMPBUTTON Type 1 ACTION (IF(EVAL(_bOK),(lOK:=.T.,Close(oDlgDes)),))
	@ _nlin,82 BMPBUTTON TYPE 2 ACTION Close(oDlgDes)

Activate Dialog oDlgDes Center

IF lOK
   _aItensLote[_nLinPos,_nColQtde]:=_nQtde
ENDIF

oLbxAux:Refresh()
PROCESSMESSAGES()

Return .T.

/*
===============================================================================================================================
Programa----------: REST020GET
Autor-------------: Alex Wallauer
Data da Criacao---: 08/08/2022
Descrição---------: ROTINA PARA CHAMAR A IMPRESSAO DIRETO DE UMA ETIQUETA
Parametros--------: nRecSB8
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function REST20Etiq(nRecSB8)//U_REST20Etiq( SB8->(RECNO()) )
PRIVATE  _aItensLote:={}

SB8->(DBGOTO(nRecSB8))

_aItem:={}
AADD(_aItem,SB8->B8_LOCAL  )      //01
AADD(_aItem,SB8->B8_LOTECTL)      //02
AADD(_aItem,DTOC(SB8->B8_DFABRIC))//03
AADD(_aItem,DTOC(SB8->B8_DTVALID))//04
AADD(_aItem,SB8->B8_PRODUTO)      //05
AADD(_aItem,""             )      //06
AADD(_aItem,SB8->B8_SALDO  )      //07
AADD(_aItem,1  )                  //08
AADD(_aItem,SB8->(RECNO()) )      //09

AADD(_aItensLote,_aItem)

MV_PAR01:=SB8->B8_LOCAL 
MV_PAR02:=SB8->B8_LOTECTL
MV_PAR03:=SB8->B8_PRODUTO

Processa( {|| REST020B() }, "Aguarde...", "Gerando Etiqueta...",.F.)

RETURN .T.
