 /*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
     Autor      |    Data    |                                             Motivo                                            
------------------------------------------------------------------------------------------------------------------------------- 
 Alex Wallauer  | 02/06/2023 | Chamado 44435. Tratamento para a Nova pergunta "Imprimir etiqueta com o produto?".
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Alex     - Igor Melgaço  - 02/05/25 - 06/05/25 -  50525  - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
==============================================================================================================================================================
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
===============================================================================================================================
Programa----------: ROMS066
Autor-------------: Alex Wallauer
Data da Criacao---: 29/11/2021
===============================================================================================================================
Descrição---------: Emissão de etiquetas de produtos PARA AMAZON, CHAMADO 38440
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

User Function ROMS066()

LOCAL   nI
LOCAL _aParAux:={}
LOCAL _aParRet:={}
LOCAL _bOK:=NIL
PRIVATE _aItensNF:= {}
PRIVATE _cDifVal:=""

_aItalac_F3:={}

_cSelectSA1:="SELECT DISTINCT A1_COD, A1_NOME, A1_LOJA   FROM "+RETSQLNAME("SA1")+" SA1 WHERE A1_MSBLQL <> '1' AND A1_NOME LIKE '%AMAZON S%' AND D_E_L_E_T_ <> '*' ORDER BY A1_COD, A1_LOJA " 
_bCondSA1  :=NIL//{|| IF(MV_PAR07="2",(A1_MSBLQL = "1"),(A1_MSBLQL <> "1")) }
//AADD(_aItalac_F3,{"MV_PAR01","SA1",SA1->(FIELDPOS("A1_COD")),{|| SA1->A1_LOJA+"-"+SA1->A1_NOME } ,_bCondSA1 ,"Clientes",,,} )
AADD(_aItalac_F3,{"MV_PAR02",_cSelectSA1,{|Tab| (Tab)->A1_COD }, {|Tab| (Tab)->A1_LOJA+" "+(Tab)->A1_NOME } ,_bCondSA1 ,"Clientes",,,,.F.        ,       , } )

// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 
_BSelectSF2:={|| "SELECT DISTINCT D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA FROM "+RETSQLNAME("SD2")+" SD2 WHERE"+;
                 " D2_FILIAL  IN "+FormatIn(ALLTRIM(MV_PAR01),";")+" AND"+;
                 " D2_TP = 'PA' AND "+;
				 IF(!EMPTY(MV_PAR02)," D2_CLIENTE IN "+FormatIn(ALLTRIM(MV_PAR02),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR03)," D2_SERIE   IN "+FormatIn(ALLTRIM(MV_PAR03),";")+" AND","")+;
                 IF(!EMPTY(MV_PAR06)," D2_EMISSAO >= '"+Dtos(MV_PAR06) + "' AND"             ,"")+;
                 IF(!EMPTY(MV_PAR07)," D2_EMISSAO <= '"+Dtos(MV_PAR07) + "' AND"             ,"")+;
				 " D_E_L_E_T_ <> '*' ORDER BY D2_FILIAL, D2_DOC, D2_SERIE " }
AADD(_aItalac_F3,{"MV_PAR04",_BSelectSF2,{|Tab| (Tab)->D2_DOC }, {|Tab| (Tab)->D2_FILIAL+" "+ALLTRIM((Tab)->D2_SERIE)+" "+(Tab)->D2_CLIENTE+" "+(Tab)->D2_LOJA } , ,"NOTAS",,,,.F.        ,       ,{|L,D| U_ROM66VAL(L,D) } } )

_BSelectDAI:={|| "SELECT DISTINCT DAI_FILIAL, DAI_COD, DAI_CLIENT, DAI_NFISCA, DAI_SERIE FROM "+RETSQLNAME("DAI")+" DAI "+;
	             " 		INNER JOIN "+ RetSqlName("SD2") +" SD2 "+;
	             " 		ON	SD2.D2_FILIAL				= DAI.DAI_FILIAL "+;
	             " 		AND	SD2.D2_DOC					= DAI.DAI_NFISCA "+;
                 " 		AND SD2.D2_SERIE				= DAI.DAI_SERIE "+;
                 " 		AND SD2.D2_CLIENTE				= DAI.DAI_CLIENT "+;
                 " 		AND SD2.D2_LOJA					= DAI.DAI_LOJA "+;
                 "      AND SD2.D2_TP = 'PA' AND "+;
                 IF(!EMPTY(MV_PAR06)," SD2.D2_EMISSAO >= '"+Dtos(MV_PAR06) + "' AND"          ,"")+;
                 IF(!EMPTY(MV_PAR07)," SD2.D2_EMISSAO <= '"+Dtos(MV_PAR07) + "' AND"          ,"")+;
				 " SD2.D_E_L_E_T_ <> '*' "+;
                 " WHERE DAI_FILIAL IN "+FormatIn(ALLTRIM(MV_PAR01),";")+" AND "+;
                 IF(!EMPTY(MV_PAR02)," DAI.DAI_CLIENT IN "+FormatIn(ALLTRIM(MV_PAR02),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR03)," DAI.DAI_SERIE  IN "+FormatIn(ALLTRIM(MV_PAR03),";")+" AND","")+;
                 IF(!EMPTY(MV_PAR04)," DAI.DAI_NFISCA IN "+FormatIn(ALLTRIM(MV_PAR04),";")+" AND","")+;
                 " DAI.D_E_L_E_T_ <> '*' ORDER BY DAI_FILIAL, DAI_COD, DAI_CLIENT, DAI_NFISCA " }
AADD(_aItalac_F3,{"MV_PAR05",_BSelectDAI,{|Tab| (Tab)->DAI_COD }, {|Tab| (Tab)->DAI_FILIAL+" "+ALLTRIM((Tab)->DAI_CLIENT)+" "+(Tab)->DAI_NFISCA+" "+(Tab)->DAI_SERIE } , ,"CARGAS",,,,.F.  ,       ,{|L,D| U_ROM66VAL(L,D) } } )

MV_PAR01:=SPACE(100)
MV_PAR02:=SPACE(100)
MV_PAR03:=SPACE(050)
MV_PAR04:=SPACE(100)
MV_PAR05:=SPACE(100)
MV_PAR06:=CTOD("")
MV_PAR07:=CTOD("")
MV_PAR08:=1
//MV_PAR09:="5"
AADD( _aParAux , { 1 , "Filiais"         , MV_PAR01, "@!"   , ""  ,"LSTFIL"  , "" , 100 , .T. } )
AADD( _aParAux , { 1 , "Clientes"        , MV_PAR02, "@!"   , ""  , "F3ITLC" , "" , 100 , .T. } )
AADD( _aParAux , { 1 , "Series"          , MV_PAR03, "@!"	, ""  ,          , "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Notas"           , MV_PAR04, "@!"	, ""  , "F3ITLC" , "" , 100 , .F. } )
AADD( _aParAux , { 1 , "Cargas"	         , MV_PAR05, "@!" 	, ""  , "F3ITLC" , "" , 100 , .F. } )
AADD( _aParAux , { 1 , "Data Emissao de" , MV_PAR06, "@D"	, ""  , ""		 , "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Data Emissao ate", MV_PAR07, "@D"	, ""  , ""		 , "" , 050 , .F. } )
AADD( _aParAux , { 3 , "Tipo Etiqueta"   , MV_PAR08, {"Etiqueta da Caixa","Etiqueta do Pallet"}, 99, "", .T., .T. , .T. } )
//AADD( _aParAux , { 1 , "Tamanho"	     , MV_PAR09, "99" 	, ""  ,          , "" , 15 , .F. } )

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next 

aTitCol:={}
AADD(aTitCol,"Nota Fiscal / Carga")                       //01
AADD(aTitCol,"Chave")                                     //02
AADD(aTitCol,"Cliente")                                   //03
AADD(aTitCol,"Fornecedor")                                //04
AADD(aTitCol,"Pedido Cliente") ;_nPosColPC :=LEN(aTitCol) //05
AADD(aTitCol,"Produto")        ;_nPosColPR :=LEN(aTitCol) //06
AADD(aTitCol,"Lote")           ;_nPosColLO :=LEN(aTitCol) //07
AADD(aTitCol,"Data Fabricacao");_nPosColDF :=LEN(aTitCol) //08
AADD(aTitCol,"Data Validade")  ;_nPosColDV :=LEN(aTitCol) //09
AADD(aTitCol,"Imprimir De")    ;_nPosColDE :=LEN(aTitCol) //10
AADD(aTitCol,"Ate")            ;_nPosColAte:=LEN(aTitCol) //11
AADD(aTitCol,"Qtde Etiquetas") ;_nPosColQE :=LEN(aTitCol) //12
AADD(aTitCol,"Caixas Sobra")   ;_nPosColCS :=LEN(aTitCol) //13
AADD(aTitCol,"Registro")                                  //14

DO WHILE .T.
	
	IF !ParamBox( _aParAux , "GERACAO DE ETIQUETAS PARA AMAZON" , @_aParRet, _bOK  ,, .T. , , , , , .T. , .T.)
		EXIT
	EndIf
	//_nTam:=VAL(MV_PAR09)
    U_ITLOGACS()
	lEtiqporitem:=.T.
	lPallporitem:=.T.
	IF MV_PAR08 = 1
	   lEtiqporitem:=U_ITMSG("Imprimir etiqueta com o produto?",'Atenção!',,2,2,2)
	ELSEIF MV_PAR08 = 2
	   lPallporitem:=U_ITMSG("Imprimir Etiquetas de Pallet por Item?",'Atenção!',,2,2,2)
	ENDIF
	lTemSobra:=.F.
	_aItensSobra:={}
	_aBrowseT:={}

    FWMSGRUN( ,{|oproc| ROMS066Ler(oproc) } ,'Aguarde!','lendo itens da NF...'  )

    IF LEN(_aItensNF) > 0
       
       aSize:=NIL
       cTit1:="Lista dos itens para imprimir as etiquetas"
       cTit2:=cTit1
       bDblClk:={|| ROMS066GET(@oLbxAux,.F.)}
       DO WHILE .T.    
    //            ITListBox(_cTitAux , _aHeader , _aCols    , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda)
          lRet:=U_ITLISTBOX(cTit1    , aTitCol  , _aItensNF , .T.      , 1      , cTit2    ,          , aSize   ,         ,     ,        ,          ,       ,bDblClk )//, _aColXML , bCondMarca,_bLegenda)
    
          IF lRet
             IF !ROMS066B()
		        Loop
		     ENDIF
          ENDIF
	      EXIT
	   ENDDO
    ELSE
       
       //U_ITMSG("Nao foi possivel ler os itens da NF","Atenção","Verifique se o Cliente é AMAZON",3)
    
       Loop
    ENDIF
   
ENDDO

RETURN 
/*
===============================================================================================================================
Programa----------: ROMS066Ler
Autor-------------: Alex Wallauer
Data da Criacao---: 29/11/2021
===============================================================================================================================
Descrição---------: LER OS ITENS DA NF
===============================================================================================================================
Parametros--------: oProc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/  

STATIC FUNCTION ROMS066Ler(oProc)
Local _cAlias := GetNextAlias()
Local _nConta :=0
Local _cQrySD2:= " SELECT R_E_C_N_O_  RECSD2 "
_cQrySD2 += " FROM " + RetSqlName("SD2") + " SD2 "
_cQrySD2 += " WHERE SD2.D_E_L_E_T_ = ' ' "
_cQrySD2 += " AND D2_FILIAL IN " +FormatIn(ALLTRIM(MV_PAR01),";")
_cQrySD2 += " AND D2_CLIENTE IN "+FormatIn(ALLTRIM(MV_PAR02),";")
_cQrySD2 += " AND D2_TP = 'PA' "
IF !EMPTY(MV_PAR03)
   _cQrySD2 += " AND D2_SERIE IN "+FormatIn(ALLTRIM(MV_PAR03),";")
ENDIF
IF !EMPTY(MV_PAR04)
   _cQrySD2 += " AND D2_DOC IN "+FormatIn(ALLTRIM(MV_PAR04),";")
ENDIF
IF !EMPTY(MV_PAR06)
   _cQrySD2 += " AND D2_EMISSAO >= '"+Dtos(MV_PAR06) + "' "
ENDIF
IF !EMPTY(MV_PAR07)
   _cQrySD2 += " AND D2_EMISSAO <= '"+Dtos(MV_PAR07) + "' "
ENDIF
_cQrySD2 += " ORDER BY D2_DOC,D2_SERIE "

DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQrySD2 ) , _cAlias , .T., .F. )

COUNT TO _nQtdReg
DBGOTOP()
_cTotal:=ALLTRIM(STR(_nQtdReg))

IF EMPTY( _nQtdReg )
   U_ITMSG("Nao tem dados para consultar com os filtros selecionados","Atenção","Verifique / altere o filtros selecionados",3)
   RETURN .F.
ELSEIF _nQtdReg > 500 .AND. !U_ITMSG( "Serão processados "+_cTotal+" registros. Deseja Continuar?",'ATENCAO!',,3,2,2)
   RETURN .F.
ENDIF

SC6->(dbSetOrder(2))
SF2->(DBSetOrder(1))
SB1->(DBSetOrder(1))
_aItensNF:= {}

//SD2->(DbSetOrder(3)) // ITENS DA NOTA FISCAL DE SAÍDA   // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
//SD2->(DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 
DO While ! (_cAlias)->(EOF()) //.And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
                          //    SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
  
   SD2->(DBGOTO((_cAlias)->RECSD2))
   SF2->(DBSEEK(SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE ))

   _nConta++
   oProc:cCaption := "Lendo NF: "+SD2->D2_DOC+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal
   PROCESSMESSAGES()
   
   If !EMPTY(MV_PAR05) .AND. !Empty( SF2->F2_CARGA ) .AND. !ALLTRIM(SF2->F2_CARGA) $ AllTrim(MV_PAR05)
      (_cAlias)->(DbSkip())
      Loop
   ENDIF

   SC6->(DBSEEK(SD2->D2_FILIAL+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV)) 
   SB1->(DBSEEK(xFilial("SB1")+SD2->D2_COD))

   _cChaveNF:=SF2->F2_DOC+"-"+SF2->F2_SERIE+IF(!EMPTY(SF2->F2_CARGA),"/ "+SF2->F2_CARGA,"")
   _nQtdeEtiqueta:= 0
   _nQtSobra := 0
   _cProduto:=SD2->D2_COD
   IF MV_PAR08 = 1
      _nQtdeEtiqueta:=SD2->D2_QTSEGUM
      IF POSICIONE("SBZ",1,SD2->D2_FILIAL+SD2->D2_COD,"BZ_I_PR3UM") = "S"
	     _nQtdeEtiqueta:=(SD2->D2_QUANT / SB1->B1_I_QT3UM)//CONVERTER DA 1A UM PARA A 3AUM (C6_QTDVEN / SB1->B1_I_QT3UM), PARA ESSES PRODUTOS ESSE SERÁ O VALOR DAS "CAIXAS".
	  ENDIF

      IF !lEtiqporitem
         _cProduto:=""	  
	  ENDIF

      IF !lEtiqporitem .AND. (_nPos:=ASCAN(_aItensNF, {|A| A[1] == _cChaveNF  })) <> 0
         _aItensNF[_nPos,_nPosColAte]+=_nQtdeEtiqueta
         _aItensNF[_nPos,_nPosColQE ]+=_nQtdeEtiqueta
		 IF !ALLTRIM(SC6->C6_PEDCLI) $ _aItensNF[_nPos,_nPosColPC ]
             _aItensNF[_nPos,_nPosColPC ]+=";"+ALLTRIM(SC6->C6_PEDCLI)
		 ENDIF 
		 (_cAlias)->(DbSkip())
		 LOOP//******************************** LOOP DO PALLET ************************************
	  ENDIF

   ELSEIF MV_PAR08 = 2
      _cProduto:=""
      If SB1->B1_I_UMPAL == '1'		
      	 _nQtdeEtiqueta:= Int( SD2->D2_QUANT / SB1->B1_I_CXPAL )
		 _nQtNoPl	   := ( _nQtdeEtiqueta * SB1->B1_I_CXPAL )
		_nQtSobra	   := SD2->D2_QUANT - _nQtNoPl
      	
      ElseIf SB1->B1_I_UMPAL == '2'		
      	 _nQtdeEtiqueta:= Int(  SD2->D2_QTSEGUM  / SB1->B1_I_CXPAL )
		 _nQtNoPl	   := ( _nQtdeEtiqueta * SB1->B1_I_CXPAL )
		 _nQtSobra	   := SD2->D2_QTSEGUM - _nQtNoPl
      	
      ElseIf SB1->B1_I_UMPAL == '3'		
         _nQtde3UM     := SD2->D2_QUANT / SB1->B1_I_QT3UM
      	 _nQtdeEtiqueta:= Int( _nQtde3UM / SB1->B1_I_CXPAL )
		 _nQtNoPl	   := ( _nQtdeEtiqueta * SB1->B1_I_CXPAL )
		 _nQtSobra	   := _nQtde3UM - _nQtNoPl
      ENDIF
	  IF _nQtSobra > 0
	     lTemSobra:=.T.
	  ENDIF
   
      IF !lPallporitem .AND. (_nPos:=ASCAN(_aItensNF, {|A| A[1] == _cChaveNF  })) <> 0
         _aItensNF[_nPos,_nPosColPR ]:="Múltiplos SKUs"
         _aItensNF[_nPos,_nPosColAte]+=_nQtdeEtiqueta
         _aItensNF[_nPos,_nPosColQE ]+=_nQtdeEtiqueta
		 IF !ALLTRIM(SC6->C6_PEDCLI) $ _aItensNF[_nPos,_nPosColPC ]
            _aItensNF[_nPos,_nPosColPC ]+=";"+ALLTRIM(SC6->C6_PEDCLI)
		 ENDIF
		 (_cAlias)->(DbSkip())
		 LOOP//******************************** LOOP DO PALLET ************************************
      ELSEIF lPallporitem 
	  	 _cProduto:= cValToChar(SB1->B1_I_CXPAL)+" cx(s) de "+ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+SD2->D2_COD,"B1_DESC"))//ex.: 90 CX(s) de BEBIDA LACTEA UHT CHOCOLATE 200 ML ITALAC
      ELSEIF !lPallporitem 
	     _nQtSobra:=0
	  ENDIF
    ENDIF
      
    _aItem:={}
	AADD(_aItem,_cChaveNF)//01
    AADD(_aItem,SF2->F2_CHVNFE)                                  //02
    AADD(_aItem,SF2->F2_CLIENTE+SF2->F2_LOJA)                    //03
    AADD(_aItem,FWSM0Util():GetSM0FullName("01",SF2->F2_FILIAL)) //04
    AADD(_aItem,ALLTRIM(SC6->C6_PEDCLI))                         //05
    AADD(_aItem,_cProduto)                                       //06
    AADD(_aItem,SPACE(20))                                       //07
    AADD(_aItem,CTOD(""))                                        //08
    AADD(_aItem,CTOD(""))                                        //09
    AADD(_aItem,IF(_nQtdeEtiqueta>0,1,0))                        //10
    AADD(_aItem,_nQtdeEtiqueta)                                  //11
    AADD(_aItem,_nQtdeEtiqueta)                                  //12
    AADD(_aItem,_nQtSobra)                                       //13
    AADD(_aItem,SD2->(RECNO()))                                  //14

    AADD(_aItensNF,_aItem)

    IF _nQtSobra > 0
	   _aItem:={}
       AADD(_aItem,.F.)
       AADD(_aItem,ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+SD2->D2_COD,"B1_DESC")))
       AADD(_aItem,0)
       AADD(_aItem,_nQtSobra)
       AADD(_aItem,ALLTRIM(SC6->C6_PEDCLI)) 
       AADD(_aItem,SF2->F2_CHVNFE)               
       AADD(_aItem,SF2->F2_CLIENTE+SF2->F2_LOJA) 
       AADD(_aItem,SD2->(RECNO())) 
   
       AADD(_aItensSobra,_aItem)
       
	   _aItem:={}
       AADD(_aItem,_nQtSobra)
       AADD(_aItem,ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+SD2->D2_COD,"B1_DESC")))
	   
	   AADD(_aBrowseT,_aItem)

    ENDIF

    (_cAlias)->(DbSkip())
EndDo   

SC6->(dbSetOrder(1))
SD2->(DbSetOrder(1)) 

IF lTemSobra .AND. lPallporitem
   ROMS066S()
ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa----------: ROMS066S()
Autor-------------: Alex Wallauer
Data da Criacao---: 29/11/2021
===============================================================================================================================
Descrição---------: Ler os dados do listbox
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function ROMS066S()
LOCAL _nQtdeP:=0
Local _bOK , P , S
Local _nlin:=05
Local _nPula:=15
Local _nCol1:=160
Local _nAlt :=120
Local _nLag :=200
lOK:=.F.

_bOK:={|| IF(_nQtdeP > 0 ,.T.,(U_ITMSG("Quantidade INVALIDA",'Atenção!',"Deve ter pelo menos 1 etiqueta para prosseguir senão cancele",3),.F.) ) }

@ 00,00 To 350,410 Dialog oDlgDes Title "Dados da Etiquetas de Sobra"

@ _nlin,05 say "Existem Produtos com sobra que podem formar outro Pallet" Pixel of oDlgDes
_nlin += _nPula
@ _nlin,05 say "Se deseja imprmir etiquetas de pallet de sobra digite quantas:" Pixel of oDlgDes
@ (_nlin-2),_nCol1 MsGet _nQtdeP Picture "@E 9,999"  Pixel Of oDlgDes
_nlin += _nPula

@ _nlin,005 LISTBOX _oVencto FIELDS TITLE "Caixas","Descricao do Produto" SIZE _nLag,_nAlt PIXEL
_oVencto:SetArray(_aBrowseT)
_oVencto:bLine := {|| _aBrowseT[_oVencto:nAt] }
_nlin += _nAlt+5

@ _nlin,70 BMPBUTTON Type 1 ACTION (IF(EVAL(_bOK),(lOK:=.T.,Close(oDlgDes)),))
@ _nlin,99 BMPBUTTON TYPE 2 ACTION Close(oDlgDes)

Activate Dialog oDlgDes Center

IF !lOK
   RETURN .F.
ENDIF

cTit1:="Lista dos itens para selecionar"
bDblClk:={|| ROMS066GET(@oLbxAux,.T.)}
aTitCol2:={}
AADD(aTitCol2,"")                //01
AADD(aTitCol2,"Produto")         //02
AADD(aTitCol2,"Qtde Pallet")     //03
AADD(aTitCol2,"Qtde Total")      //04
AADD(aTitCol2,"Pedido Cliente")  //05
AADD(aTitCol2,"Chave")           //06
AADD(aTitCol2,"Cliente")         //07
AADD(aTitCol2,"Registro")        //08

FOR  P := 1 TO  _nQtdeP
     _cDifVal:=""
     cTit2:="Selecione os itens do Etiqueta de Pallet "+cValToChar(P)+" de "+cValToChar(_nQtdeP)
    //      ITListBox(_cTitAux , _aHeader , _aCols    , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda)
    lRet:=U_ITLISTBOX(cTit1    , aTitCol2 , _aItensSobra , .F.   , 4      , cTit2    ,          ,         ,         ,     ,        ,          ,       ,bDblClk )//, _aColXML , bCondMarca,_bLegenda)
    
	IF lRet
	    _aItem:={}
	    _cPedCli:=""
		_cProduto:=""
		_nContaItem:=0
	    FOR S := 1 TO LEN(_aItensSobra)
	       IF _aItensSobra[S,1]
			  _aItensSobra[S,4]:=_aItensSobra[S,4]-_aItensSobra[S,3]
			  _cPedCli+=ALLTRIM(_aItensSobra[S,5])+";"
              _cProduto+=CValToChar(_aItensSobra[S,3])+" CX(s) de "+_aItensSobra[S,2]+";"
		  	  SD2->(DBGOTO(_aItensSobra[S,LEN(_aItensSobra[S])]))
			  _aItensSobra[S,3]:=0
			  _aItensSobra[S,1]:=.F.
			  _nContaItem++
		   ENDIF
	    NEXT
	    _cPedCli :=LEFT( _cPedCli , LEN(_cPedCli )-1 )
		_cProduto:=LEFT( _cProduto, LEN(_cProduto)-1 )

	    AADD(_aItem,"Etiqueta de sobra")                             //01
        AADD(_aItem,SF2->F2_CHVNFE)                                  //02
        AADD(_aItem,SF2->F2_CLIENTE+SF2->F2_LOJA)                    //03
        AADD(_aItem,FWSM0Util():GetSM0FullName("01",SF2->F2_FILIAL)) //04
        AADD(_aItem,_cPedCli)                                        //05
        AADD(_aItem,_cProduto)                                       //06
        AADD(_aItem,_cDifVal)                                        //07
        AADD(_aItem,CTOD(""))                                        //08
        AADD(_aItem,CTOD(""))                                        //09
        AADD(_aItem,1)					                             //10
        AADD(_aItem,1)                  		                     //11
        AADD(_aItem,1)                           		             //12
        AADD(_aItem,_nContaItem)                                     //13
        AADD(_aItem,SD2->(RECNO()))                                  //14
    
        AADD(_aItensNF,_aItem)
	ENDIF

NEXT
RETURN .T.
/*
===============================================================================================================================
Programa----------: ROMS066B
Autor-------------: Alex Wallauer
Data da Criacao---: 29/11/2021
===============================================================================================================================
Descrição---------: Ler os dados do listbox
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function ROMS066B()
LOCAL NF
Local cLocal:=GetTempPath()

cFileName:="ROM046_"
cFileName+=DToS( DATE() ) + "_"
cFileName+=StrTran(TIME(), ":" , "" )
cFileName:=cFileName+".pdf"
//CB5SetImp("ZEBRA")//chama MSCBPRINTER()
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

//CB5SetImp("ZEBRA")//chama MSCBPRINTER()

FOR NF:= 1 to LEN(_aItensNF)

	SD2->(DBGOTO(_aItensNF[NF,LEN(_aItensNF[NF])]))

     _nDe   := _aItensNF[NF,_nPosColDE]
	 IF _nDe = 0
	    LOOP
	 ENDIF
     _nTotEtiq:= _aItensNF[NF,_nPosColQE]
     _nAte    := _aItensNF[NF,_nPosColAte]
	 _cLote   := _aItensNF[NF,_nPosColLO]
	 _dValid  := _aItensNF[NF,_nPosColDV]
	 _cPedCli := _aItensNF[NF,_nPosColPC]
	 _cChave  := _aItensNF[NF,2]
	 _aProduto:={}

     lSair:=.F.
	 IF MV_PAR08 = 1
       IF lEtiqporitem
          _cProduto:= SD2->D2_COD
	      _nQuant  := SD2->D2_QUANT
	      _c1Unid  := SD2->D2_UM   
	   ENDIF
        Processa( {||  lSair:=ROMS066C(_nTotEtiq) }, "Aguarde...", "Gerando Etiquetas de Caixa...",.F.)
	 ELSEIF MV_PAR08 = 2
	    //_lMaisde1:=.F.
        _cProduto:= _aItensNF[NF,_nPosColPR]
		IF lPallporitem 
		   IF  "Etiqueta de sobra" $ _aItensNF[NF,1]
	           IF _aItensNF[NF,_nPosColCS] > 1		   
	              _cProduto:= "Múltiplos SKUs"
                  _aProduto:= StrToArray(_aItensNF[NF,_nPosColPR],";") //Ex.: 52 CX(s) de LEITE UHT INTEGRAL C/TAMPA 1 L EDGE ITALAC
			   ENDIF
		   ENDIF	   
		ENDIF
        Processa( {||  lSair:=ROMS066P(_nTotEtiq) }, "Aguarde...", "Gerando Etiquetas de Pallet...",.F.)
	 ENDIF
	 IF lSair
	    RETURN .F.
	 ENDIF

NEXT

//CB5SetImp("ZEBRA")//chama MSCBPRINTER()

LjMsgRun( "Gerando a visualização..." , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir

Return .T.
/*
===============================================================================================================================
Programa----------: ROMS066C
Autor-------------: Alex Wallauer
Data da Criacao---: 29/11/2021
===============================================================================================================================
Descrição---------: Impressão de multiplas etiquetas DE CAIXAS
===============================================================================================================================
Parametros--------: _nTotEtiq
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function ROMS066C(_nTotEtiq)

Local  ni , P
Local ncoluna  :=15
Local nTamFonte:=03
Local nlinhaIni:=35
Local nLinhAux1:=35
Local nLinhAux2:=15
Local _nEsqu1  :=010  //COLUNA INICIAL ESQUERDA
Local nLinMeio :=610  //COLUNA DO MEIO
Local _nEsqu2  :=nLinMeio+15//DADOS DA COLUNA DO MEIO
Local ntamh    :=1080 //COLUNA DA DIREITA / LARGURA DA ETIQUETA

//                       Fonte      Tamanho         Negrito
oFont10  := TFont():New("Arial", , (10+nTamFonte-1), .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Arial", , (10+nTamFonte  ), .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont12n := TFont():New("Arial", , (10+nTamFonte+1), .T., .T., 5,,, .T., .F.,,,,,, oPrint)//TITULO
oFont20  := TFont():New("Arial", , (28+nTamFonte  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)//CAIXAS

cerros := ""
procregua(_nTotEtiq)
SA1->(DbSetOrder(1))
//_cTypeBar:="EAN128"//"GS1128"//CODE128

FOR ni := _nDe TO  _nAte
	
	nlinha := nlinhaIni
	
	incproc("Imprimindo etiqueta CAIXAS: " + strzero(ni,5) + " de " + strzero(_nAte,5))

	
	oPrint:StartPage()              // Inicializa a Pagina de Impressao

	oPrint:Line(nlinha,ncoluna - 5 , nlinha , ncoluna + ntamh)//LINHA INICIAL
	
	nLinha += 010
//=======================================	
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1,"Endereço de destino:"   , oFont12n,,,,2)
//	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2,"Endereço do fornecedor:", oFont12n,,,,2)
	nLinha += 050
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	
	nPula:=040	
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "AMAZON CD: "+ALLTRIM(SA1->A1_COMPENT), oFont10)//200
	nLinhaSalva:=nLinha
	nLinha += nPula
    SA1->(Dbseek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, SA1->A1_NOME , oFont10)
	nLinha += nPula

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "CNPJ: "+SA1->A1_CGC+"  IE: "+SA1->A1_INSCR+" CEP:"+Transform(SA1->A1_CEP,"@R 99999-999"), oFont10)
	nLinha += nPula

//	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "IE: "+SA1->A1_INSCR+" CEP:"+Transform(SA1->A1_CEP,"@R 99999-999"), oFont10)
//	nLinha += nPula

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, ALLTRIM(SA1->A1_END), oFont10)
	nLinha += nPula

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, ALLTRIM(SA1->A1_BAIRRO)+"-"+ALLTRIM(SA1->A1_MUN)+"-"+ALLTRIM(SA1->A1_EST), oFont10)
	nLinha += 060

//Endereço do fornecedor 
	aEmp := FWSM0Util():GetSM0Data("01",SF2->F2_FILIAL,{"M0_ENDCOB","M0_CEPCOB","M0_CIDCOB","M0_ESTCOB","M0_BAIRCOB","M0_NOMECOM","M0_NOME"})

	cEndFil	:= AllTrim(aEmp[1,2])+" "
	cCepFil	:= "CEP: "+SubStr(AllTrim(aEmp[2,2]),1,2) + "." + SubStr(AllTrim(aEmp[2,2]),3,3) + "-" + SubStr(AllTrim(aEmp[2,2]),6,3)
	cCidFil	:= AllTrim(aEmp[3,2])+" - "
	cEstFil	:= AllTrim(aEmp[4,2])
	cBaiFil	:= AllTrim(aEmp[5,2])
	cNomeEmp:= AllTrim(aEmp[6,2])

	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	nLinha += 010

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1,"Endereço do fornecedor:", oFont12n,,,,2)
	nLinha += 050
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	nLinha += 020    

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cNomeEmp       , oFont10)
	nlinha +=nPula

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cEndFil        , oFont10)
	nlinha +=nPula

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cCepFil+"  "+cBaiFil        , oFont10)
	nlinha +=nPula

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cCidFil+cEstFil, oFont10)
	nLinha += 050
//Endereço do fornecedor ****************************
		
	nLinhaSalva:=nLinha
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	nLinha += 020
//==============================================================================================	
    aPedidos:=StrToArray(_cPedCli,";")
    IF LEN(aPedidos) > 1
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Pedidos de compra abaixo", oFont10n)//70
       ccodbar1:=""
    ELSE
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Pedido de compra", oFont10n)//70
       ccodbar1:=ALLTRIM(_cPedCli)
	ENDIF
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Número de caixas", oFont10n)//610
	nLinha += 010
	
	nLinha += 060-nLinhAux2
	nLinBar:=nLinha
	nColBar:=nColuna + _nEsqu1+10
	nLagBar:=1//0.0167
	nAltBar:=25//0.7
	IF LEN(ALLTRIM(_cPedCli)) > 15
	   nLagBar2:=150
	ELSE
	   nLagBar2:=NIL
	ENDIF
    //_cTypeBar:="CODE128"
	
               
//  oPrint:FWMsBar(_cTypeBar,nRow   ,nCol,cCode   ,oPrint,lCheck,Color,lHorz, LARGUR,nALTERA,lBanner,cFont  ,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
//	oPrint:FWMSBAR(_cTypeBar,nLinBar,0.4 ,ccodbar1,oPrint,.T.   ,     ,.T.  ,nLagBar,nAltBar,.F.    ,"Arial","C"  ,.F.   ,1       ,1        ,.F.)
//  oPrint:Code128(/*nRow*/,/*nCol*/,*cCode*/,nWidth*,nHeigth,.T./*lSay*/,,100)
    IF !EMPTY(ccodbar1)
       oPrint:Code128(nLinBar ,nColBar ,ccodbar1,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)//CODIGO DE BARRA DO PEDIDO DE COMPRA
	ENDIF
 	
	//oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, dtoc(dvalid), oFont10)//210
    
	_cCaixa := CValToChar(ni)+" / "+CValToChar(_nAte)
	nCentral:=20
	oPrint:Say(nLinha+nLinhAux1+nCentral+20, nColuna + _nEsqu2+nCentral, _cCaixa , oFont20)//"Número de caixas"

	nLinha += 100
    IF !EMPTY(ccodbar1)
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, ccodbar1 , oFont10)//NUMERO DO PEDIDO DO CODIGO DE BARA ACIMA
	ENDIF

	nLinha += 090
	oPrint:Line(nlinha   ,ncoluna - 5       , nlinha+1 ,ncoluna + ntamh)//FECHA A LINHA
	oPrint:Line(nLinhaSalva,ncoluna + nLinMeio, nlinha ,ncoluna + nLinMeio)//LINHA DA COLUNA DO MEIO
	nLinha += 015
	
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Nota fiscal:", oFont10n)//170
	nLinha += 055
	//oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)//FECHA A LINHA
	nLinha += 030
	
	ccodbar2:=ALLTRIM(_cChave)
	nLinBar:=19//nLinha+5//
	nLagBar:=0.0166//01//
	//nAltBar:=25//0.7
	//nLagBar2:=270
	_cTypeBar:="CODE128"
	
//  oPrint:FWMsBar(_cTypeBar,nRow   ,nCol,cCode   ,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont  ,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
  	oPrint:FWMSBAR(_cTypeBar,nLinBar,0.8 ,ccodbar2,oPrint,.T.    ,    ,.T.  ,nLagBar,0.7    ,.F.    ,"Arial","C"  ,.F.   ,1       ,1        ,.F.)
//  oPrint:Code128(/*nRow*/,/*nCol*/,*cCode*/,nWidth*,nHeigth,.T./*lSay*/,,100)
//  oPrint:Code128(nLinBar ,nColBar ,ccodbar2,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)
    
	nLinha += 080-nLinhAux2
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1+200, ccodbar2 , oFont10)//NUMERO DA NF NO CODIGO DE BARRA
	nLinha += 070

  	oPrint:Line(nlinha   ,ncoluna - 5     , nlinha , ncoluna + ntamh )//LINHA FINAL
	nLinha += 030

 IF lEtiqporitem
// BLOCO EXTRA DO PRODUTO :	
	SB1->(DBSEEK(xFilial("SB1") + _cProduto))
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "PRODUTO : "+ALLTRIM(SB1->B1_DESC), oFont10)//170

	nLinha += 050
	//oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)//FECHA A LINHA
	//nLinha += 030

	nLinBar:=nLinha
	nColBar:=nColuna + _nEsqu1+10
	nLagBar:=1
	nAltBar:=25
	nLagBar2:=nil//250
    //_cTypeBar:="CODE128"
	
    ccodbar3:=ALLTRIM(SB1->B1_CODBAR)
               
//  oPrint:Code128(/*nRow*/,/*nCol*/,*cCode*/,nWidth*,nHeigth,.T./*lSay*/,,100)
    oPrint:Code128(nLinBar ,nColBar ,ccodbar3,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)//CODIGO DE BARRA DO SB1->B1_CODBAR 

	nLinha += 090
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1+150, ccodbar3 , oFont10)//CODIGO DO SB1->B1_CODBAR                

	nLinha += 085
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)//FECHA A LINHA
	nLinha += 035

	IF !EMPTY(_nQuant)
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Número de unidades do itens: "+ALLTRIM(TRANS(_nQuant,"@E 999,999,999,999.99"))+" "+_c1Unid, oFont10)
	   nLinha += nPula
    ENDIF
	IF !EMPTY(_cLote)
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Número do Lote: "+ALLTRIM(_cLote), oFont10)
	   nLinha += nPula
	ENDIF
	IF !EMPTY(_dValid)
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Data de Validade: "+DTOC(_dValid), oFont10)
	   nLinha += 085
	ENDIF
//	oPrint:Line(nlinhaIni,ncoluna - 5     , nlinha , ncoluna - 5     )//LINHA LATERAL ESQUERDA 
//	oPrint:Line(nlinhaIni,ncoluna + ntamh , nlinha , ncoluna + ntamh )//LINHA LATERAL DIRETA
  	oPrint:Line(nlinha   ,ncoluna - 5     , nlinha , ncoluna + ntamh )//LINHA FINAL
  
  ELSEIF LEN(aPedidos) > 1 // !lEtiqporitem

//PEDIDOS DO PALLET
    //aPedidos:=StrToArray(_cPedCli,";")
    IF LEN(aPedidos) > 1
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Pedidos de compra" , oFont10n)
	ELSE
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Pedido de compra" , oFont10n)
	ENDIF
	nLinha += 010
    nLinha += 060-nLinhAux2

    FOR P := 1 TO LEN(aPedidos)

        _lPar:=MOD(P,2)=0
        ccodbar1:=aPedidos[P]
		IF _lPar
	       nColBar:=nColuna + _nEsqu2+06//LADO DIREITO 
		ELSE
	       nColBar:=nColuna + _nEsqu1+10//LADO ESQUERDO
		ENDIF  
	    nLinBar:=nLinha
		
	    nLagBar:=1
	    nAltBar:=23
	    IF LEN(ALLTRIM(_cPedCli)) > 15
	       nLagBar2:=125
	    ELSE
	       nLagBar2:=NIL
	    ENDIF
        IF !EMPTY(ccodbar1)
//         oPrint:Code128(/*nRow*/,/*nCol*/,*cCode*/,nWidth*,nHeigth,.T./*lSay*/,,100)
           oPrint:Code128(nLinBar ,nColBar ,ccodbar1,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)
		   nLinBar+=120
	       oPrint:Say(nLinBar, nColBar , ccodbar1 , oFont10)
		   IF LEN(_aProduto) >= P
		      nLinBar+=030
	          oPrint:Say(nLinBar, nColBar , MEMOLINE(_aProduto[P],55,1) , oFontCX)
		   ENDIF	   
	    ENDIF
		IF _lPar
	       nLinha += 170
		ENDIF

	NEXT
	IF !_lPar
	   nLinha += 170
	ENDIF

  	oPrint:Line(nlinha   ,ncoluna - 5     , nlinha , ncoluna + ntamh )//LINHA FINAL

  ENDIF //IF lEtiqporitem

	oPrint:EndPage()                // Finaliza a Pagina de Impressao

NEXT
Return .F. //NAO SAIR 

/*
===============================================================================================================================
Programa----------: ROMS066P
Autor-------------: Alex Wallauer
Data da Criacao---: 29/11/2021
===============================================================================================================================
Descrição---------: Impressão de multiplas etiquetas DE PALLET
===============================================================================================================================
Parametros--------: _nTotEtiq
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function ROMS066P(_nTotEtiq)

Local  ni , p
Local ncoluna  :=15
Local nTamFonte:=04
Local nTamFont2:=00
Local nlinhaIni:=35
Local nLinhAux1:=35
Local nLinhAux2:=15
Local _nEsqu1  :=010  //COLUNA INICIAL ESQUERDA
Local nLinMeio :=610  //COLUNA DO MEIO
Local _nEsqu2  :=nLinMeio+17//DADOS DA COLUNA DO MEIO
Local ntamh    :=1150 //COLUNA DA DIREITA / LARGURA DA ETIQUETA

//                       Fonte      Tamanho  Negrito
//oFont8   := TFont():New("Arial",, 08, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFontCX  := TFont():New("Arial", , (08+nTamFont2  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFontEX  := TFont():New("Arial", , (10+nTamFont2  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10  := TFont():New("Arial", , (10+nTamFonte-1), .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Arial", , (10+nTamFonte  ), .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont12n := TFont():New("Arial", , (10+nTamFonte+1), .T., .T., 5,,, .T., .F.,,,,,, oPrint)//TITULO
oFont20  := TFont():New("Arial", , (28+nTamFont2  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)//CAIXAS
cerros := ""
procregua(_nTotEtiq)
SA1->(DbSetOrder(1))
//_cTypeBar:="EAN128"//"GS1128"//CODE128

FOR ni := _nDe TO  _nAte
	
	nlinha := nlinhaIni
	
	incproc("Imprimindo etiqueta PALLET: " + strzero(ni,5) + " de " + strzero(_nAte,5))

	
	oPrint:StartPage()              // Inicializa a Pagina de Impressao

	oPrint:Line(nlinha,ncoluna - 5 , nlinha , ncoluna + ntamh)//LINHA INICIAL
	
	nLinha += 010
	
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1,"Endereço de destino:"   , oFont12n,,,,2)

    nLinha+=050
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	nPula:=040	

    SA1->(Dbseek(xFilial()+SF2->F2_CLIENTE+SF2->F2_LOJA))
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "AMAZON CD: "+ALLTRIM(SA1->A1_COMPENT), oFont10)//200
	nLinhaSalva:=nLinha
	nLinha += nPula
		
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, SA1->A1_NOME , oFont10)
	nLinha += nPula

	//oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "CNPJ: "+SA1->A1_CGC, oFont10)
	//nLinha += nPula

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "CNPJ: "+SA1->A1_CGC+"  IE: "+SA1->A1_INSCR+" CEP:"+Transform(SA1->A1_CEP,"@R 99999-999"), oFont10)
	nLinha += nPula

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, ALLTRIM(SA1->A1_END), oFont10)
	nLinha += nPula

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, ALLTRIM(SA1->A1_BAIRRO)+"-"+ALLTRIM(SA1->A1_MUN)+"-"+ALLTRIM(SA1->A1_EST), oFont10)
	nLinha += 060

//Endereço do fornecedor LADO DIREITO VOLTA NA LINHA SALVA ****************
	aEmp := FWSM0Util():GetSM0Data("01",SF2->F2_FILIAL,{"M0_ENDCOB","M0_CEPCOB","M0_CIDCOB","M0_ESTCOB","M0_BAIRCOB","M0_NOMECOM","M0_NOME"})

	cEndFil	:= AllTrim(aEmp[1,2])+" "
	cCepFil	:= "CEP: "+SubStr(AllTrim(aEmp[2,2]),1,2) + "." + SubStr(AllTrim(aEmp[2,2]),3,3) + "-" + SubStr(AllTrim(aEmp[2,2]),6,3)
	cCidFil	:= AllTrim(aEmp[3,2])+" - "
	cEstFil	:= AllTrim(aEmp[4,2])
	cBaiFil	:= AllTrim(aEmp[5,2])
	cNomeEmp:= AllTrim(aEmp[6,2])

	oPrint:Line(nlinha,ncoluna - 5,nlinha+1,ncoluna + ntamh)
	nLinha += 010

	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1,"Endereço do fornecedor:", oFont12n,,,,2)

    nLinha+=050
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	nPula:=040	

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cNomeEmp       , oFont10)
	nlinha +=nPula

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cEndFil        , oFont10)
	nlinha +=nPula

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cCepFil+"  "+cBaiFil        , oFont10)
	nlinha +=nPula

	//oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cBaiFil        , oFont10)
	//nlinha +=nPula

	oPrint:Say(nlinha+nLinhAux1, nColuna + _nEsqu1, cCidFil+cEstFil, oFont10)
	nLinha += 050
//Endereço do fornecedor ****************************
		
	nLinhaSalva:=nLinha
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	nLinha += 030

// BLOCO EXTRA DO PRODUTO :	
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, ALLTRIM(_cLote)   , oFontEX)
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Número de pallets", oFont10n)

	nLinha += nPula
	oPrint:Say(nLinha+nLinhAux1      , nColuna + _nEsqu1, ALLTRIM(MEMOLINE(_cProduto,35,1)), oFontEX)
	oPrint:Say(nLinha+nLinhAux1+nPula, nColuna + _nEsqu1, ALLTRIM(MEMOLINE(_cProduto,35,2)), oFontEX)
// BLOCO EXTRA DO PRODUTO :	

	nLinha += 010

	_cCaixa := CValToChar(ni)+" / "+CValToChar(_nAte)
	nCentral:=14
	oPrint:Say(nLinha+nLinhAux1+nCentral+20, nColuna + _nEsqu2+nCentral, _cCaixa , oFont20)//9999 / 9999
	nLinha += 090

	oPrint:Line(nlinha   ,ncoluna - 5       , nlinha+1 ,ncoluna + ntamh)//FECHA A LINHA
	oPrint:Line(nLinhaSalva,ncoluna + nLinMeio, nlinha ,ncoluna + nLinMeio)//LINHA DA COLUNA DO MEIO
	nLinha += 015
	
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Nota fiscal:", oFont10n)//170

	nLinha += 050
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)//FECHA A LINHA
	nLinha += 030
	
	ccodbar2:=ALLTRIM(_cChave)
	nLinBar:=18//nLinha+5//
	nLagBar:=0.0165//01//
	nAltBar:=0.7//25//
	nLagBar2:=255
	nColBar:=0.8//nColuna + _nEsqu1-10//
	
//  oPrint:FWMsBar(_cTypeBar,nRow   ,nCol   ,cCode   ,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont  ,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
              ///*cTypeBar*/,/*nRow*/,/*nCol*,*cCode*/,oPrint,lCheck/,Color,lHorz,nWidth ,nHeigth,lBanner,cFont*/,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
  	oPrint:FWMSBAR("CODE128",nLinBar ,nColBar,ccodbar2,oPrint,.T.    ,     ,.T.  ,nLagBar,0.7    ,.F.    ,"Arial","C"  ,.F.   ,1       ,1        ,.T.      )

	nLinha += 120-nLinhAux2
	oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1+200, ccodbar2 , oFont10)//NUMERO DA NF DO CODIGO DE BARRA	
	
	nLinha += 055
  	oPrint:Line(nlinha   ,ncoluna - 5     , nlinha , ncoluna + ntamh )//LINHA FINAL
	nLinha += 025

//PEDIDOS DO PALLET
    aPedidos:=StrToArray(_cPedCli,";")
    IF LEN(aPedidos) > 1
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Pedidos de compra" , oFont10n)
	ELSE
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Pedido de compra" , oFont10n)
	ENDIF
	nLinha += 010
    nLinha += 060-nLinhAux2

    FOR P := 1 TO LEN(aPedidos)

        _lPar:=MOD(P,2)=0
        ccodbar1:=aPedidos[P]
		IF _lPar
	       nColBar:=nColuna + _nEsqu2+06//LADO DIREITO 
		ELSE
	       nColBar:=nColuna + _nEsqu1+10//LADO ESQUERDO
		ENDIF  
	    nLinBar:=nLinha
		
	    nLagBar:=1
	    nAltBar:=23
	    IF LEN(ALLTRIM(_cPedCli)) > 15
	       nLagBar2:=125
	    ELSE
	       nLagBar2:=NIL
	    ENDIF
        IF !EMPTY(ccodbar1)
//         oPrint:Code128(/*nRow*/,/*nCol*/,*cCode*/,nWidth*,nHeigth,.T./*lSay*/,,100)
           oPrint:Code128(nLinBar ,nColBar ,ccodbar1,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)
		   nLinBar+=120
	       oPrint:Say(nLinBar, nColBar , ccodbar1 , oFont10)
		   IF LEN(_aProduto) >= P
		      nLinBar+=030
	          oPrint:Say(nLinBar, nColBar , MEMOLINE(_aProduto[P],55,1) , oFontCX)
		   ENDIF	   
	    ENDIF
		IF _lPar
	       nLinha += 170
		ENDIF

	NEXT
	IF !_lPar
	   nLinha += 170
	ENDIF

//	nLinha += 055
  	//oPrint:Line(nlinhaIni,ncoluna - 5     , nlinha , ncoluna - 5     )//LINHA LATERAL ESQUERDA 
  	//oPrint:Line(nlinhaIni,ncoluna + ntamh , nlinha , ncoluna + ntamh )//LINHA LATERAL DIRETA
  	oPrint:Line(nlinha   ,ncoluna - 5     , nlinha , ncoluna + ntamh )//LINHA FINAL

	oPrint:EndPage()                // Finaliza a Pagina de Impressao pallet

NEXT
Return .F. //NAO SAIR 

/*
===============================================================================================================================
Programa----------: ROMS066GET
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2019
===============================================================================================================================
Descrição---------: Rotina de duplo clique na linha do browse
===============================================================================================================================
Parametros--------: oLbxAux,lTelaItens
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ROMS066GET(oLbxAux,lTelaItens)
Local _nLinPos  := oLbxAux:nAt
Local _bOK
Local _nlin:=10
Local _nPula:=20
if lTelaItens
    IF _aItensSobra[_nLinPos,3] = 0
	   _nQtde :=_aItensSobra[_nLinPos,4]
	ELSE
	   _nQtde :=_aItensSobra[_nLinPos,3]
	ENDIF
    _nQtdeT:=_aItensSobra[_nLinPos,4]
    _bOK:={|| IF(_nQtde >= 0 .and. _nQtde <=_nQtdeT ,.T.,(U_ITMSG("Quantidade INVALIDA",'Atenção!',"A quantidade não pode ser maior que a qtde total e deve ser maior igual a zero",3),.F.) ) }

ELSE
    _bOK:={|| IF(_nQtde >= 0 .AND. _nQtdeAte > 0,.T.,(U_ITMSG("Quantidades INVALIDA",'Atenção!',"Tente novamente com valor maior que zero",3),.F.) ) }
	_nQtde    :=_aItensNF[_nLinPos,_nPosColDE]
	_nQtdeAte :=_aItensNF[_nLinPos,_nPosColAte]
	_cLote    :=_aItensNF[_nLinPos,_nPosColLO]
	IF _nQtdeAte = 0
	   U_ITMSG("Nao tem quantidade desse produto suficiente para montar um Pallet",'Atenção!',"Gere etiquetas por caixa",3) // ALERT
	   RETURN .F.
	ENDIF
	IF EMPTY(_aItensNF[_nLinPos,_nPosColDF])
	   _dDtFabr:=DATE() 
	ELSE
	   _dDtFabr:=_aItensNF[_nLinPos,_nPosColDF]
    ENDIF
	SD2->(DBGOTO(_aItensNF[_nLinPos,LEN(_aItensNF[_nLinPos])]))
	IF EMPTY(_aItensNF[_nLinPos,_nPosColDV])
	   _nDtVali:=_dDtFabr + POSICIONE("SBZ", 1, SD2->D2_FILIAL + SD2->D2_COD, "BZ_I_DIVLD")
	ELSE
	   _nDtVali:=_aItensNF[_nLinPos,_nPosColDV]
    ENDIF
ENDIF

lOK:=.F.	
@ 00,00 To 280,280 Dialog oDlgDes Title "Dados da Etiqueta"
    
	if lTelaItens
	   @ _nlin,10 say "Qtde nesse Pallet:" Pixel of oDlgDes
	   @ _nlin,75 MsGet _nQtde Picture "@E 999,999"  Pixel Of oDlgDes
	ELSE
	   @ _nlin,10 say "Quantidade de:" Pixel of oDlgDes
	   @ _nlin,50 MsGet _nQtde Picture "@E 999,999"  Pixel Of oDlgDes
	ENDIF
	_nlin += _nPula

	if !lTelaItens
	   @ _nlin,10 say "Quantidade Ate:" Pixel of oDlgDes
	   @ _nlin,50 MsGet _nQtdeAte Picture "@E 999,999,999"  Pixel Of oDlgDes
	   _nlin += _nPula
	ENDIF
	
    IF MV_PAR08 = 1

	   @ _nlin,10 say "Lote:" Pixel of oDlgDes
	   @ _nlin,50 MsGet _cLote Picture "@!"  Pixel Of oDlgDes SIZE 50,10
	   _nlin += _nPula
   
	   @ _nlin,10 say "Dt Fabricacao:" Pixel of oDlgDes
	   @ _nlin,50 MsGet _dDtFabr Picture "@D"  Pixel Of oDlgDes VALID {|| IF(!EMPTY(_dDtFabr),_nDtVali:=_dDtFabr + POSICIONE("SBZ", 1, xFilial("SBZ") + SD2->D2_COD, "BZ_I_DIVLD"),) , .T. }
	   _nlin += _nPula
   
	   @ _nlin,10 say "Dt Validade:" Pixel of oDlgDes
	   @ _nlin,50 MsGet _nDtVali Picture "@D"  Pixel Of oDlgDes
	   _nlin += _nPula
	
	ELSE

	   @ _nlin,10 say "Diferentes Validades ?" Pixel of oDlgDes
	   @ _nlin,75 MSCOMBOBOX _cDifVal ITEMS {"1=Sim","2=Não"} SIZE 040, 010 OF oDlgDes PIXEL Valid {|| Pertence('12')} 
	   _nlin += _nPula
	
	ENDIF   

	@ _nlin,50 BMPBUTTON Type 1 ACTION (IF(EVAL(_bOK),(lOK:=.T.,Close(oDlgDes)),))
	@ _nlin,82 BMPBUTTON TYPE 2 ACTION Close(oDlgDes)

Activate Dialog oDlgDes Center

IF lOK

   if lTelaItens
	  _aItensSobra[_nLinPos,1]:=(_nQtde > 0)
      _aItensSobra[_nLinPos,3]:=_nQtde
	  IF _cDifVal = "1"
	     _cDifVal:="Diferentes validades" 
	  ELSE
	     _cDifVal:="" 
	  ENDIF
   ELSE
      _aItensNF[_nLinPos,_nPosColDE ]:=_nQtde
      _aItensNF[_nLinPos,_nPosColAte]:=_nQtdeAte
      IF MV_PAR08 = 1
	     _aItensNF[_nLinPos,_nPosColLO ]:=_cLote
	     _aItensNF[_nLinPos,_nPosColDF ]:=_dDtFabr  
	     _aItensNF[_nLinPos,_nPosColDV ]:=_nDtVali  
	  ELSE
	     IF _cDifVal = "1"
	        _aItensNF[_nLinPos,_nPosColLO ]:="Diferentes validades" 
	     ELSE
	        _aItensNF[_nLinPos,_nPosColLO ]:="" 
	     ENDIF
	  ENDIF
/*	  IF EMPTY(_aItensNF[_nLinPos,5 ])
	     _aItensNF[_nLinPos,5 ]:=_aItensNF[_nLinPos,_nPosColLO ]    //TESTE
	  ENDIF*/
   ENDIF
ENDIF

oLbxAux:Refresh()
PROCESSMESSAGES()
Return .T.
/*
===============================================================================================================================
Programa----------: ROM66VAL
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2019
===============================================================================================================================
Descrição---------: VALIDA F3 SEM DADOS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function ROM66VAL(cChamada,_aDados)
_cRetorno:=.T.

IF cChamada = "D"
  IF LEN(_aDados) =0 
       U_ITMSG("Nao tem dados para Consultar com os filtros selecionados","Atenção","Verifique / altere o filtros selecionados",3)
      _cRetorno:=.F.
  ENDIF
ENDIF
RETURN _cRetorno
