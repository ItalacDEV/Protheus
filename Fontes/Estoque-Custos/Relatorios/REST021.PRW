/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |29/11/2022| Chamado 41968. Prametro novo MV_PAR05 e aumentado o tamanho da fonte do codigo do produto.
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/

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
Programa----------: REST021
Autor-------------: Alex Wallauer
Data da Criacao---: 19/09/2022
Descrição---------: Emissão de etiquetas Almoxarifado para Endereçamento de Produtos, CHAMADO 41354 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function REST021()

LOCAL   nI
LOCAL _aParAux:={}
LOCAL _aParRet:={}
LOCAL _bOK:=NIL
PRIVATE _aItensSB1:= {}
PRIVATE _cDifVal:=""

_aItalac_F3:={}
DbSelectArea("SBZ")
DbSelectArea("SB1")

_BSelectSBZ:={|| "SELECT DISTINCT BZ_I_LOCAL , BZ_COD FROM "+RETSQLNAME("SBZ")+" SBZ WHERE"+;
                 " SBZ.BZ_FILIAL = '"+cFilAnt+"' AND"+;
				 IF(!EMPTY(MV_PAR02)," SUBSTR(SBZ.BZ_COD,1,4) IN "+FormatIn(ALLTRIM(MV_PAR02),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR04)," BZ_COD IN "+FormatIn(ALLTRIM(MV_PAR04),";")+" AND","")+;
				 " SBZ.BZ_I_LOCAL <> ' '  AND "+;	
				 " SBZ.BZ_TIPO  NOT IN ('SV', 'PA', 'MP', 'MO', 'BN', 'PP', 'PI') AND "+;				 
				 " SUBSTR(SBZ.BZ_COD,1,4) NOT IN ('1000', '0800' ) AND "+;	
				 " SUBSTR(SBZ.BZ_COD,1,4) NOT BETWEEN '0001' AND '0100'  AND "+;	
				 " SUBSTR(SBZ.BZ_COD,1,4) NOT BETWEEN '0300' AND '0399'  AND "+;	
				 " SBZ.D_E_L_E_T_ = ' ' ORDER BY SBZ.BZ_I_LOCAL " }

//Italac_F3:={}         1           2         3                          4                       5            6             7         8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave               , _nCpoDesc               ,_bCondTab , _cTitAux      , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR01"   ,_BSelectSBZ,{|Tab|(Tab)->BZ_I_LOCAL},{|Tab| (Tab)->BZ_COD},          ,"Enderecos"  ,LEN(SBZ->BZ_I_LOCAL),          ,        ,.F.        ,       , } )

_BSelectSB1:={|| "SELECT DISTINCT B1_GRUPO FROM "+RETSQLNAME("SB1")+" SB1 WHERE"+;
				 IF(!EMPTY(MV_PAR03)," B1_TIPO IN "+FormatIn(ALLTRIM(MV_PAR03),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR04)," B1_COD  IN "+FormatIn(ALLTRIM(MV_PAR04),";")+" AND","")+;
				 " SB1.B1_TIPO  NOT IN ('SV', 'PA', 'MP', 'MO', 'BN', 'PP', 'PI','AD','AJ','BO','GG','IM') AND "+;				 
				 " SB1.B1_GRUPO NOT IN ('1000', '0800' ) AND "+;	
				 " SB1.B1_GRUPO NOT BETWEEN '0001' AND '0100'  AND "+;	
				 " SB1.B1_GRUPO NOT BETWEEN '0300' AND '0399'  AND "+;	
				 " SB1.B1_GRUPO  <> ' '  AND "+;	
				 " D_E_L_E_T_ = ' ' ORDER BY B1_GRUPO " }

//Italac_F3:={}         1           2         3                                   4                                                                                        5            6             7             8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave                         , _nCpoDesc                                                                              ,_bCondTab , _cTitAux, _nTamChv            , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR02"   ,_BSelectSB1,{|Tab| (Tab)->B1_GRUPO },{|Tab| AllTrim(Posicione("SBM",1,xFilial("SBM")+(Tab)->B1_GRUPO,"BM_DESC")) },          ,"Grupos"  , LEN(SB1->B1_GRUPO),          ,           ,.F.       ,       , } )


_BSelectSB1:={|| "SELECT DISTINCT B1_TIPO FROM "+RETSQLNAME("SB1")+" SB1 WHERE"+;
				 IF(!EMPTY(MV_PAR02)," B1_GRUPO IN "+FormatIn(ALLTRIM(MV_PAR02),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR04)," B1_COD   IN "+FormatIn(ALLTRIM(MV_PAR04),";")+" AND","")+;
				 " SB1.B1_TIPO  <>  ' ' AND "+;	
				 " SB1.B1_TIPO  NOT IN ('SV', 'PA', 'MP', 'MO', 'BN', 'PP', 'PI','AD','AJ','BO','GG','IM') AND "+;				 
				 " SB1.B1_GRUPO NOT IN ('1000', '0800' ) AND "+;	
				 " SB1.B1_GRUPO NOT BETWEEN '0001' AND '0100'  AND "+;	
				 " SB1.B1_GRUPO NOT BETWEEN '0300' AND '0399'  AND "+;	
				 " D_E_L_E_T_ = ' ' ORDER BY B1_TIPO " }

//Italac_F3:={}         1           2         3                                   4                                                                                        5            6             7             8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave                         , _nCpoDesc                                                                              ,_bCondTab , _cTitAux, _nTamChv            , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03"   ,_BSelectSB1,{|Tab| (Tab)->B1_TIPO },{|Tab| AllTrim(Posicione("SX5",1,xFilial("SX5")+"02"+AllTrim((Tab)->B1_TIPO),"X5_DESCRI")) },          ,"Grupos"  , LEN(SB1->B1_TIPO),          ,           ,.F.       ,       , } )

_bSelSB1:={|| "SELECT DISTINCT B1_COD , B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE"+;
                 " B1_FILIAL = '  ' AND"+;
				 IF(!EMPTY(MV_PAR01)," EXISTS (SELECT 'Y' FROM " +RetSqlName("SBZ")+" BZ WHERE BZ.D_E_L_E_T_ = ' '  AND BZ.BZ_FILIAL = '"+cFilAnt+"' AND SB1.B1_COD = BZ.BZ_COD  AND BZ_I_LOCAL IN "+FormatIn(ALLTRIM(MV_PAR01),";")+") AND","")+;
				 IF(!EMPTY(MV_PAR02)," B1_GRUPO   IN "+FormatIn(ALLTRIM(MV_PAR02),";")+" AND","")+;
				 IF(!EMPTY(MV_PAR03)," B1_TIPO    IN "+FormatIn(ALLTRIM(MV_PAR03),";")+" AND","")+;
				 " SB1.B1_TIPO  NOT IN ('SV', 'PA', 'MP', 'MO', 'BN', 'PP', 'PI','AD','AJ','BO','GG','IM') AND "+;				 
				 " SB1.B1_GRUPO NOT IN ('1000', '0800' ) AND "+;	
				 " SB1.B1_GRUPO NOT BETWEEN '0001' AND '0100'  AND "+;	
				 " SB1.B1_GRUPO NOT BETWEEN '0300' AND '0399'  AND "+;	
				 " SB1.D_E_L_E_T_ = ' ' AND SB1.B1_MSBLQL = '2'  ORDER BY B1_COD " }

//Italac_F3:={}         1           2         3                             4                 5            6             7             8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave                   , _nCpoDesc       ,_bCondTab , _cTitAux, _nTamChv  , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR04"   ,_bSelSB1,{|Tab|AllTrim((Tab)->B1_COD)},{|Tab|(Tab)->B1_DESC}   , ,"Produtos", LEN(SB1->B1_COD),          ,        ,.F.        ,       , } )

MV_PAR01:=SPACE(200)
MV_PAR02:=SPACE(200)
MV_PAR03:=SPACE(200)
MV_PAR04:=SPACE(300)
MV_PAR05:="1"

AADD( _aParAux , { 1 , "Endereco"          , MV_PAR01, "@!"  , ""  ,"F3ITLC", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Grupo de Produto"  , MV_PAR02, "@!"  , ""  ,"F3ITLC", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Tipo de Produto"   , MV_PAR03, "@!"  , ""  ,"F3ITLC", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Produtos"          , MV_PAR04, "@!"  , ""  ,"F3ITLC", "" , 100 , .F. } ) 
AADD( _aParAux , { 2 , "Imprimir Descricao", MV_PAR05,{"1-Detalhada","2-Item ","3-Ambas "}, 070 ,".T.",.T.,".T."}) 
   
For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next 

aTitCol:={}
AADD(aTitCol,"")                   //01
AADD(aTitCol,"Produto")            //02
AADD(aTitCol,"Descricao")          //03
AADD(aTitCol,"Descricao Detalhada")//04
AADD(aTitCol,"Localizacao")        //05
AADD(aTitCol,"Tipo")               //06
AADD(aTitCol,"Grupo")              //07
AADD(aTitCol,"Registro")           //08

DO WHILE .T.
	
	IF !ParamBox( _aParAux , "GERACAO DE ETIQUETAS ALMOXARIFADO" , @_aParRet, _bOK  ,, .T. , , , , , .T. , .T.)
		EXIT
	EndIf

    U_ITLOGACS()

	_aItensSB1:={}

    FWMSGRUN( ,{|oproc| REST021Ler(oproc) } ,'Aguarde!','Lendo produtos...'  )

    IF LEN(_aItensSB1) > 0
       
       aSize:=NIL
       cTit1:="Lista dos produtos para imprimir as etiquetas"
       cTit2:=cTit1
       DO WHILE .T.    
    //            ITListBox(_cTitAux , _aHeader , _aCols     , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda)
          lRet:=U_ITLISTBOX(cTit1    , aTitCol  , _aItensSB1, .T.      , 2      , cTit2    ,          , aSize   ,         ,     ,        ,          ,       ,        )
    
          IF lRet
	         lSair:=.F.
             
			 Processa( {||  lSair:=REST021B() }, "Aguarde...", "Gerando Etiquetas...",.F.)

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
Programa----------: REST021Ler
Autor-------------: Alex Wallauer
Data da Criacao---: 19/09/2022
Descrição---------: LER OS ITENS DA NF
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================*/  

STATIC FUNCTION REST021Ler(oProc)
Local _cAlias := GetNextAlias()
Local _nConta :=0
Local _cQrySB1:= " SELECT R_E_C_N_O_  RECSB1 "

_cQrySB1 += " FROM " + RetSqlName("SB1") + " SB1 "
_cQrySB1 += " WHERE SB1.D_E_L_E_T_ = ' ' AND "
_cQrySB1 += " B1_TIPO  NOT IN ('SV', 'PA', 'MP', 'MO', 'BN', 'PP', 'PI','AD','AJ','BO','GG','IM') AND "
_cQrySB1 += " B1_GRUPO NOT IN ('1000', '0800' ) AND "
_cQrySB1 += " B1_GRUPO NOT BETWEEN '0001' AND '0100'  AND "	
_cQrySB1 += " B1_GRUPO NOT BETWEEN '0300' AND '0399' "
IF !EMPTY(MV_PAR01)
   _cQrySB1 += " AND EXISTS (SELECT 'Y' FROM " +RetSqlName("SBZ")+" BZ WHERE BZ.D_E_L_E_T_ = ' '  AND BZ.BZ_FILIAL = '"+cFilAnt+"' AND SB1.B1_COD = BZ.BZ_COD AND BZ_I_LOCAL IN "+FormatIn(ALLTRIM(MV_PAR01),";")+" ) "
ENDIF
IF !EMPTY(MV_PAR02)
   _cQrySB1 += " AND B1_GRUPO IN "+FormatIn(ALLTRIM(MV_PAR02),";")
ENDIF
IF !EMPTY(MV_PAR03)
   _cQrySB1 += " AND B1_TIPO    IN "+FormatIn(ALLTRIM(MV_PAR03),";")
ENDIF
IF !EMPTY(MV_PAR04)
   _cQrySB1 += " AND B1_COD IN "+FormatIn(ALLTRIM(MV_PAR04),";")
ENDIF
_cQrySB1 += " ORDER BY B1_COD"
_cQrySB1 := ChangeQuery(_cQrySB1)

MPSysOpenQuery(_cQrySB1,_cAlias)
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

SB1->(DBSetOrder(1))
_aItensSB1:= {}

DO While ! (_cAlias)->(EOF())                           
  
   SB1->(DBGOTO((_cAlias)->RECSB1))

   _nConta++
   oProc:cCaption := "Lendo Item: "+SB1->B1_COD+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal
   PROCESSMESSAGES()
   
    _aItem:={}
	AADD(_aItem,.T.)                  //01
	AADD(_aItem,SB1->B1_COD)          //02
	AADD(_aItem,SB1->B1_DESC   )      //03 - ITEM
	AADD(_aItem,SB1->B1_I_DESCD)      //04 - Detalhada
	AADD(_aItem,Posicione("SBZ",1,xFilial("SBZ")+SB1->B1_COD,"BZ_I_LOCAL"))    //05
	AADD(_aItem,SB1->B1_TIPO)         //06
	AADD(_aItem,SB1->B1_GRUPO)        //07
	AADD(_aItem,SB1->(RECNO()) )      //08

    AADD(_aItensSB1,_aItem)

   
    (_cAlias)->(DbSkip())
EndDo   

RETURN .T.

/*
===============================================================================================================================
Programa----------: REST021B
Autor-------------: Alex Wallauer
Data da Criacao---: 19/09/2022
Descrição---------: Ler os dados do listbox
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function REST021B()
LOCAL NF
Local cLocal:=GetTempPath()

cFileName:="REST021_"
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

PROCREGUA(LEN(_aItensSB1))

FOR NF:= 1 to LEN(_aItensSB1)

	INCPROC("Imprimindo etiqueta: " + STRZERO(NF,5) + " de " + STRZERO(LEN(_aItensSB1),5))
	
    IF !_aItensSB1[NF,1]
	   LOOP
	ENDIF

	SB1->(DBGOTO(_aItensSB1[NF, LEN(_aItensSB1[NF]) ]))

    _cProduto  := ALLTRIM(_aItensSB1[NF,2])
    _cDescricao:= ALLTRIM(_aItensSB1[NF,3])
	_cDetalhada:= ALLTRIM(_aItensSB1[NF,4])
	_cLocal    := ALLTRIM(_aItensSB1[NF,5])

    lSair:=REST021C() 

	IF lSair
	   RETURN .F.
	ENDIF

NEXT

LjMsgRun( "Gerando a visualização..." , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir

Return .F.
/*
===============================================================================================================================
Programa----------: REST021C
Autor-------------: Alex Wallauer
Data da Criacao---: 19/09/2022
Descrição---------: Impressão de multiplas etiquetas
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function REST021C()
Local nColini  :=50
Local nLinhaIni:=1
Local nLinhaux1:=0
Local ntamh    :=600 //COLUNA DA DIREITA / LARGURA DA ETIQUETsA

//                       Fonte      Tamanho         Negrito
oFont05  := TFont():New("Courier new", , 08 , .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Courier new", , 10 , .T., .T., 5,,, .T., .F.,,,,,, oPrint)
                                  // AJUSTAR AQUI
oFontG   := TFont():New("Courier new", , 12 , .T., .T., 5,,, .T., .F.,,,,,, oPrint)

SA1->(DbSetOrder(1))

	nLinha := nLinhaIni
	
	oPrint:StartPage()              // Inicializa a Pagina de Impressao

	nLargura := 999
	nAltura  := 100
	nLinBar  := 001
	nColBar  := nColini
	nLagBar  := 001
	nAltBar  := 025
    nLagBar2 := 150
	
//======================================= PRODUTO =========================================================
	
    ccodbar1:=ALLTRIM(_cProduto)
               
    oPrint:Code128(nLinBar ,nColBar ,ccodbar1,nLagBar,nAltBar,.F./*lSay*/,,nLagBar2)//CODIGO DE BARRA 
	nLinha += 099

    IF MV_PAR05 = "3" // TAMANHO ANTIGO
   	   oFontAux:=oFont10n
	ELSE// TAMANHO COM UMA DAS DESCRICAO
   	   oFontAux:=oFontG
    ENDIF
    oPrint:SayAlign(nLinha+nLinhaux1, nColini , ccodbar1 , oFontAux,nLargura,nAltura,,/*ALIGN_H_CENTER*/)//CODIGO DO PRODUTO DO CODIGO DE BARA ACIMA
    
	IF MV_PAR05 = "3" // TAMANHO ANTIGO
	   nLinha += 030
	ELSE// TAMANHO COM UMA DAS DESCRICAO
	   nLinha += 040 // AJUSTAR AQUI
    ENDIF


//***************************************** Descricao ****************************************************************//
 
 IF MV_PAR05 = "1"

    IF LEN(_cDetalhada) > 40
	   oFontAux:=oFont05
	   nLinha +=005
	ELSE
	   oFontAux:=oFont10n
	ENDIF
	oPrint:SayAlign(nLinha+nLinhaux1, nColini ,_cDetalhada, oFontAux,nLargura,nAltura,        ,)
	nLinha +=040

 ELSEIF MV_PAR05 = "2"

    IF LEN(_cDescricao) > 72//dobro do 36, manter essa proporcao
	   nTamM:=60
	   oFontAux:=oFont05
	   nLinha +=005
	ELSE
	   nTamM:=36
	   oFontAux:=oFont10n
	ENDIF
	oPrint:SayAlign(nLinha+nLinhaux1, nColini ,MEMOLINE(_cDescricao,nTamM,1), oFontAux,nLargura,nAltura,        ,)
	nLinha +=030
	oPrint:SayAlign(nLinha+nLinhaux1, nColini ,MEMOLINE(_cDescricao,nTamM,2), oFontAux,nLargura,nAltura,        ,)
	nLinha +=040

 ELSEIF MV_PAR05 = "3"
    IF LEN(_cDetalhada) > 40
	   oFontAux:=oFont05
	   nLinha +=005
	ELSE
	   oFontAux:=oFont10n
	ENDIF
	oPrint:SayAlign(nLinha+nLinhaux1, nColini ,_cDetalhada, oFontAux,nLargura,nAltura,        ,)
	nLinha +=030

    IF LEN(_cDescricao) > 72//dobro do 36, manter essa proporcao
	   nTamM:=60
	   oFontAux:=oFont05
	   nLinha +=005
	ELSE
	   nTamM:=36
	   oFontAux:=oFont10n
	ENDIF
	oPrint:SayAlign(nLinha+nLinhaux1, nColini ,MEMOLINE(_cDescricao,nTamM,1), oFontAux,nLargura,nAltura,        ,)
	nLinha +=030
	oPrint:SayAlign(nLinha+nLinhaux1, nColini ,MEMOLINE(_cDescricao,nTamM,2), oFontAux,nLargura,nAltura,        ,)
	nLinha +=040
ENDIF
//**************************************** LOCAL *****************************************************************//
	oPrint:Line(nLinha+nLinhaux1   ,nColini - 5       , nLinha+nLinhaux1 ,nColini + ntamh, 0 , "-6")//FECHA A LINHA
	nLinha += 000
	
	oPrint:SayAlign(nLinha+nLinhaux1, nColini, "LOCALIZAÇÃO | "+_cLocal, oFont10n,nLargura,nAltura,        ,)//170
	nLinha += 050
	
	oPrint:Line(nLinha+nLinhaux1,nColini - 5,nLinha+nLinhaux1,nColini + ntamh, 0 , "-6")

	oPrint:EndPage()                // Finaliza a Pagina de Impressao

Return .F. //NAO SAIR 
