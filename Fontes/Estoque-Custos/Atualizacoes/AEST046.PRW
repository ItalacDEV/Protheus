/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |07/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
===============================================================================================================================
Andre          - Alex Wallauer   - 02/06/2021 - 05/05/25 - 32139   - Correção no calculo do custo do ICMS (não foi na época)
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================

*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"   

/*
===============================================================================================================================
Programa----------: AEST046
Autor-------------: Alex Wallauer
Data da Criacao---: 27/03/2019
Descrição---------: Cadastro de Regras de Calculo de custo do ICMS - CHAMADO 28650
Parametros--------: Nenhum 
Retorno-----------: Nenhum 
===============================================================================================================================
*/
User Function AEST046()

Private cCadastro 	:= "Calculo de custo do ICMS"
Private aRotina   	:= {}
Private aCores    	:= {}
Private aLegenda 	:= {} 

aLegenda 	:= {{"BR_VERMELHO","Bloqueado"}, {"BR_VERDE", "Ativo"}} 

Aadd(aRotina,{"Pesquisar" 	,"AxPesqui"  	 ,0,1 })//1
Aadd(aRotina,{"Executar"	,"U_AEST046I"   ,0,2 })//2
Aadd(aRotina,{"Incluir"		,"U_AEST046I"	 ,0,3 })//3
Aadd(aRotina,{"Alterar"		,"U_AEST046I"   ,0,4 })//4
Aadd(aRotina,{"Visualizar"	,"U_AEST046I"   ,0,2 })//5
Aadd(aRotina,{"Excluir"		,"U_AEST046I"   ,0,5 })//6
Aadd(aRotina,{"Copiar"		,"U_AEST046I"   ,0,4 })//7
Aadd(aRotina,{"Historico"  ,"U_AEST046I"   ,0,4 })//8
Aadd(aRotina,{"Legenda"		,"BrwLegenda('Status das regras','Legenda',aLegenda)",0,7 })
AADD(aCores,{"ZM0_MSBLQL <> '1'","BR_VERDE" })   
AADD(aCores,{"ZM0_MSBLQL = '1'" ,"BR_VERMELHO" })    

_aItalac_F3:={}
_cSelectSB1:="SELECT B1_COD, B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE B1_TIPO IN ('MP','PP','PI') AND D_E_L_E_T_ = ' ' ORDER BY B1_COD " 
//   _aItalac_F3:={}         1           2         3                                4             5          6                             7         8          9         10         11        12
//DD(_aItalac_F3,{"1CPO_CAMPO1"  ,_cTabela   ,_nCpoChave                     , _nCpoDesc     , _bCondTab , _cTitAux                   , _nTamChv , _aDados , _nMaxSel , _lFilAtual,_cMVRET,_bValida})  
AADD(_aItalac_F3,{"M->ZM0_MPCONS",_cSelectSB1,{|Tab| ALLTRIM((Tab)->B1_COD) }, {|Tab| (Tab)->B1_DESC } , ,"Produtos Tipos: [MP,PP,PI]",          ,         , 40       ,.F.        ,       , } )

DbSelectArea("ZM0")
ZM0->(DbSetOrder(1))
ZM0->(DbGoTop())

mBrowse(,,,,"ZM0",,,,, ,aCores)

Return(.T.)

/*
===============================================================================================================================
Programa----------: AEST046I
Autor-------------: Alex Wallauer
Data da Criacao---: 27/03/2019
Descrição---------: Rotina de ações do mbrowse 
Parametros--------: _nOpc: 1 - Ececutar / 7 - Copiar
Retorno-----------: .T.
===============================================================================================================================
*/
User Function AEST046I(cAlias,nReg,_nOpc)

Local nI
Local _lRetMod3:= .F.
Local _aarea	:= getarea()
Local _nReg		:= ZM0->( Recno() )
Local aObjects := {}
Local _aParRet :={}
Local _aParAux :={} 
Local _bOK     :={|| IF(MV_PAR02 >= MV_PAR01,.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo",3),.F.) ) }
PRIVATE _lLog  := .F.

IF _nOpc = 2

   MV_PAR01:=dDataBase
   MV_PAR02:=dDataBase
   MV_PAR03:="1–Estornar cred x Estrutura "
   MV_PAR04:="212020;212021"+SPACE(100)
   MV_PAR05:="232016"+SPACE(100)
   MV_PAR06:=SPACE(100)//"313001"+
   MV_PAR07:="4–Nenhum                  "
   MV_PAR08:=0
   MV_PAR09:=0
   MV_PAR10:=0
   MV_PAR11:=SPACE(100)
   MV_PAR12:=SPACE(100)
   MV_PAR13:="1–Geral           "
   MV_PAR14:="4–Nenhum             "
   MV_PAR15:="2–Nao"
   MV_PAR16:="2–Nao"
   
   _aOpcao3:={}
   AADD( _aOpcao3 , "1–Estornar cred x Estrutura ")
   AADD( _aOpcao3 , "2–Estornar cred x Percentual")
   AADD( _aOpcao3 , "3–Nenhum                    ") 

   _aOpcoes:={}
   AADD( _aOpcoes , "1–Estorna cred x Estrutura")
   AADD( _aOpcoes , "2–Estorna cred x operacao ")
   AADD( _aOpcoes , "3–Credita pela operacao   ")
   AADD( _aOpcoes , "4–Nenhum                  ") 
   
   _aOpca13:={}
   AADD( _aOpca13 , "1–Geral           ")
   AADD( _aOpca13 , "2–Somente Produção")

   _aOpca14:={}
   AADD( _aOpca14 , "1–Anulacao de Credito")
   AADD( _aOpca14 , "2–Glosa de Credito   ")
   AADD( _aOpca14 , "3–Ambos              ")
   AADD( _aOpca14 , "4–Nenhum             ")

   _aOpca15:={}
   AADD( _aOpca15 , "1–Sim")
   AADD( _aOpca15 , "2–Nao")

   AADD( _aParAux , { 1 , "Data de" 	             , MV_PAR01, "@D", "", ""	    , "", 050, .T.})
   AADD( _aParAux , { 1 , "Data ate"	             , MV_PAR02, "@D", "", ""	    , "", 050, .T.})
   AADD( _aParAux , { 2 , "Quanto a perda"           , MV_PAR03, _aOpcao3         ,090,".T.",.T.}) 
   AADD( _aParAux , { 1 , "Naturezas Desp. Programa ", MV_PAR04, "@!", "", "LSTNAT","", 100, .T.}) 
   AADD( _aParAux , { 1 , "Naturezas Multas Fiscais ", MV_PAR05, "@!", "", "LSTNAT","", 100, .T.}) 
   AADD( _aParAux , { 1 , "Naturezas Bolsa Garantia ", MV_PAR06, "@!", "", "LSTNAT","", 100, .F.}) 
   AADD( _aParAux , { 2 , "Quanto a ZFM?"            , MV_PAR07, _aOpcoes         ,090,".T.",.T.}) 
   AADD( _aParAux , { 1 , "% Programa financiado "   , MV_PAR08, "@E 999.99","","","",040 ,  .F.})
   AADD( _aParAux , { 1 , "% Bolsa Garantia s/ finan", MV_PAR09, "@E 999.99","","","",040 ,  .F.})
   AADD( _aParAux , { 1 , "% Protege s/ financiado " , MV_PAR10, "@E 999.99","","","",040 ,  .F.})
   AADD( _aParAux , { 1 , "Debito / Codigo Apur ICMS", MV_PAR11, "@!"      , "", "","", 100, .F.}) 
   AADD( _aParAux , { 1 , "Credito/ Codigo Apur ICMS", MV_PAR12, "@!"      , "", "","", 100, .F.}) 
   AADD( _aParAux , { 2 , "Rateio Codigo Apur ICMS"  , MV_PAR13, _aOpca13         ,090,".T.",.F.}) 
   AADD( _aParAux , { 2 , "Soma em Outros Debitos"   , MV_PAR14, _aOpca14         ,090,".T.",.T.}) 
   AADD( _aParAux , { 2 , "Ratear Sobra Cred.Producao",MV_PAR15, _aOpca15         ,090,".T.",.T.}) 
   AADD( _aParAux , { 2 , "Desc. Benef. LP recebido Transf.",MV_PAR16, _aOpca15   ,090,".T.",.T.}) 

   
   For nI := 1 To Len( _aParAux )
   	aAdd( _aParRet , _aParAux[nI][03] )
   Next nI

             //aParametros, cTitle       , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
   IF !ParamBox( _aParAux , "Parametros" , @_aParRet, _bOK, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
	  RETURN .T.
   EndIf
   //MsNewProcess(): New ( [ bAction], [ cTitle], [ cMsg], [ lAbort] )    
   cHoraIni:=TIME()
   oProcess:= MsNewProcess():New({|_lEnd,oProcess| AEST046E(@oProcess, @_lEnd) },"Calculo de custo do ICMS - H.I.: "+cHoraIni,"Processando",.T.) 
   oProcess:Activate()

   RETURN .T.

 ELSEIF _nOpc = 8

   DbSelectArea("ZM1")
   ZM1->(DbSetOrder(1))
   ZM1->(DbGoTop())

   aOldRotina:=ACLONE(aRotina)
   aRotina:={}
   Aadd(aRotina,{"Pesquisar" 	,"AxPesqui"  	 ,0,1 })
   Aadd(aRotina,{"Visualizar"	,"AxVisual"     ,0,2 })

   mBrowse(,,,,"ZM1")

   aRotina:=aOldRotina

   RETURN .T.

ENDIF

cCadastro:= "Calculo de custo do ICMS - "+IF(_nOpc = 8,"COPIA","") 
Private cAlias1:="ZM0"
Private aGets:={}
Private aTela:={}

Regtomemory(cAlias1,(_nOpc=3))

If _nOpc <> 3

     DBSELECTAREA("ZM0")
     IF Bof() .AND. Eof()
        Return _nOpc
     EndIf
     FOR nI := 1 TO FCount()
        M->&(FIELDNAME(nI)) := FieldGet(nI)
     NEXT
	If _nOpc == 7 // Copia
	   M->ZM0_CODEVE:= U_AEST046G() //Caso seja copia valida ultimo cod. de numero do evento
	Endif	

EndIf 

aSize:= MsAdvSize()
aInfo:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 3 }
AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )
aPosObj := MsObjSize( aInfo , aObjects )
//====================================================================
//Abre tela de visulização do registro
//====================================================================
DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 to 35,170 //of oMainWnd

	oEnCh1:=MsMget():New(cAlias1,_nReg,_nOpc,,,,,{15,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,3,,,,,,.F.)
	oDlg:lMaximized:=.T.
	
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .AND. AEST46Val(),(oDlg:End(),_lRetMod3:=.T.),.f.)},{||oDlg:End()},,) , oEnCh1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT)


If _lRetMod3 .And. ( (_nOpc == 3 ) /* Inclusão */ .OR. (_nOpc == 7 )) // Copia
	
    IF ZM0->(DBSEEK(XFilial("ZM0")+M->ZM0_CODEVE))
	   M->ZM0_CODEVE:= U_AEST046G() //Caso seja copia valida ultimo cod. de numero do evento
    ENDIF
    ZM0->(RecLock("ZM0",.T.))
    AVREPLACE("M","ZM0")
	ZM0->ZM0_FILIAL:=XFilial("ZM0") 
	ZM0->(MsUnLock())
	
ElseIf _lRetMod3 .And. (_nOpc == 4 ) // Alteração
	
    ZM0->(RecLock("ZM0",.F.))
    AVREPLACE("M","ZM0")
	ZM0->ZM0_FILIAL:=XFilial("ZM0") 
	ZM0->(MsUnLock())

ElseIf _lRetMod3 .And. (_nOpc == 6 ) // Exclusão
	
    ZM0->(RecLock("ZM0",.F.))
	ZM0->(DbDelete())
	ZM0->(MsUnLock())

Else

	If _nOpc == 3 .or. _nOpc == 7

		RollBackSX8()

	EndIf

Endif

restarea(_aarea)

Return .T.

/*
===============================================================================================================================
Programa----------: AEST046G
Autor-------------: Alex Wallauer
Data da Criacao---: 27/03/2019
Descrição---------: Rotina para retornar próximo código , usada no dicionario campo "ZM0_CODEVE"
Parametros--------: Ver descrição abaixo
Retorno-----------: _ccod - próximo valor 
===============================================================================================================================
*/
User Function AEST046G()

Local _ccod 	:= "000001"
Local _cQuery := ""
Local _aarea	:= getarea()

_cQuery	:= " SELECT " 
_cQuery  	+= 	" MAX(ZM0_CODEVE) AS CODI" 
_cQuery  	+= 	" FROM " + RetSqlName("ZM0") + " ZM0 "
_cQuery  	+= 	" WHERE ZM0_FILIAL = '" + xFilial("ZM0") + "'"
_cQuery 	+= 	" AND ZM0.D_E_L_E_T_ = ' '	"
_cQuery := ChangeQuery(_cQuery)

MPSysOpenQuery(_cQuery,"ZM0T")
	
If ZM0T->(!Eof())

	_ccod := strzero( ( val( ZM0T->CODI) + 1 ), LEN(ZM0->ZM0_CODEVE) )

Endif

If Select("ZM0T") > 0 

	ZM0T->( DBCloseArea() )

EndIf

restarea(_aarea)

RETURN _ccod
/*
===============================================================================================================================
Programa----------: AEST046E()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/03/2019
Descricao---------: Calcula e Grava dados
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function AEST046E(_oSelf,_lEnd)

LOCAL nConta := 0 , I  , T
LOCAL nTotal := 0 , _nQtde
PRIVATE aDadosCalc :={}
PRIVATE aDadosTela :={}
PRIVATE _cEstFilAnt:= Posicione("ZZM",1,xFilial("ZZM")+cFilAnt,"ZZM_EST")
PRIVATE _cValores:=""

_oSelf:SetRegua1( 0 )
_oSelf:SetRegua2( 0 )
_oSelf:IncRegua1("Iniciando os trabalhos, Aguarde..." )
_oSelf:IncRegua2("Iniciando os trabalhos, Aguarde..." )

DbSelectArea("ZM0")
ZM0->(DbSetOrder(1))
ZM0->(DBSEEK(xFilial()))

MV_PAR01 := alltrim(str(year(MV_PAR01))) + strzero((month(MV_PAR01)),2)+"01"
If month(STOD(MV_PAR01)) < 12
   MV_PAR02 := DTOS(STOD( alltrim(str(year(STOD(MV_PAR01)))) + strzero( month(STOD(MV_PAR01))+1 ,2)+"01" ) - 1)
Else
   MV_PAR02 := alltrim(str((year(STOD(MV_PAR01)))) + "1231")
Endif

aCampos:={}
AADD(aCampos,{"ZM1_DATARQ","Periodo"     ,035})//01
AADD(aCampos,{"ZM1_CODEVE","Evento"      ,070})//02
//Valores
AADD(aCampos,{"ZM1_VLROP" ,"B-Vlr Saidas",050})//03
AADD(aCampos,{"ZM1_ICMSAI","D-ICMS saida",050})//04
AADD(aCampos,{"ZM1_CREDS" ,"C-Beneficio" ,050})//05
AADD(aCampos,{"ZM1_VLROPD","B-Devolucoes",050})//06
AADD(aCampos,{"ZM1_ICMSD" ,"C-Cred Dev"  ,050})//07
AADD(aCampos,{"ZM1_ESTCRD","D-Estorn bnf",050})//08
AADD(aCampos,{"ZM1_ICMAPG","D-Icm a Pagr",050})//09
AADD(aCampos,{"ZM1_DBBENF","D-Deb s/ Bnf",050})//10
AADD(aCampos,{"ZM1_DBVND" ,"D-Deb s/ Vnd",050})//11
AADD(aCampos,{"ZM1_ESTPRD","D-Estn perda",050})//12
AADD(aCampos,{"ZM1_JUROSI","D-Desp progr",050})//13
AADD(aCampos,{"ZM1_MTFISC","D-Multa Fisc",050})//14
AADD(aCampos,{"ZM1_BGARAN","D-Bls Garant",050})//15
AADD(aCampos,{"ZM1_OCRED" ,"C-Outros Crd",050})//16
AADD(aCampos,{"ZM1_DESP"  ,"Total Despes",050})//17
AADD(aCampos,{"ZM1_CUSICM","% Custo ICMS",050})//18
//NOVOS
AADD(aCampos,{"ZM1_PRSPRD","C-Presm Prod",050})//19
AADD(aCampos,{"ZM1_PRSOPE","C-Presm Oper",050})//20
AADD(aCampos,{"ZM1_CDBENF","C-Crd S/ Bnf",050})//21
AADD(aCampos,{"ZM1_ODEB"  ,"D-Outros Deb",050})//22

// VARIAVEIS DE LOG
_cLogQuerys:=CRLF
_cTeste:=CRLF
_cVal2:=CRLF
_cVal2+="ZM0->ZM0_CODEVE;_nZM1_PRSOPE:=; ((_nQuantVLROP;-_nQuant); * _nRen ); * _nMix ;* (ZM0->ZM0_PRSOPE/100);ou ZM0->ZM0_LMT1P"+CRLF
_cVal3:=CRLF
_cVal3+="ZM0->ZM0_CODEVE+;+aProComprados[T,1]+;+STR(aTp_EM_IN[nPos,2],22,7)+;+STR(aProComprados[T,2],22,7)+;+STR((aProComprados[T,3]),22,7)"+CRLF
// VARIAVEIS DE LOG

cTot:="/16"
_oSelf:SetRegua1( 15 )
_oSelf:SetRegua2( 00 )
nSeq:=1

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )

_nEPSE :=0 
IF MV_PAR03 = "1" //Estornar cred x estrutura
   _oSelf:SetRegua2( 3 )
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno de perda sem estrutura1/3" )
   aProdutos:=AEST046R(_oSelf,_lEnd,"SELECT_EPSE_MV03=1")//SEM ESTRUTURA

   cProd_EN_IN:=""//Preenchido ABAIXO e Variavel cProd_EN_IN usa na AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")
   FOR T := 1 TO LEN(aProdutos)
       IF !aProdutos[T,1]  $ cProd_EN_IN
          cProd_EN_IN+=aProdutos[T,1]+";"
       ENDIF   
   NEXT
   aTp_EM_IN:=ACLONE(aProdutos)

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 2/3" )
   _cValores+="SELECT_EPSE_MV03=1;cProd_EN_IN: ; "+cProd_EN_IN+";"+STR(LEN(aTp_EM_IN),22)+CRLF
   aProCompDT:=AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")

   cProd_SEM_DT:=""
   FOR T := 1 TO LEN(aTp_EM_IN)
       IF ASCAN(aProCompDT , {|P| P[1] == aTp_EM_IN[T,1]  })  = 0
          cProd_SEM_DT+=aTp_EM_IN[T,1]+";"
       ENDIF   
   NEXT

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 3/3" )
   _cValores+="SELECT_EPSE_MV03=1;cProd_SEM_DT: ; "+cProd_SEM_DT+CRLF
   cProd_EN_IN:=cProd_SEM_DT//Variavel cProd_EN_IN Usa na AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")
   aProComprados:=AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")//SELECT SEM FILTRO DE DATA
   FOR T := 1 TO LEN(aProCompDT)
       AADD(aProComprados,aProCompDT[T])
   NEXT
   _nEPSE :=0 
   FOR T := 1 TO LEN(aProComprados)
       IF (nPos:=ASCAN(aTp_EM_IN , {|P| P[1] == aProComprados[T,1]  } )) <> 0       
          _nEPSE +=  ( aTp_EM_IN[nPos,2] * aProComprados[T,2] * aProComprados[T,3] )
          _cValores+="SELECT_EPSE_MV03=1;"+aProComprados[T,1]+";"+STR(aTp_EM_IN[nPos,2],22,7)+";"+STR(aProComprados[T,2],22,7)+";"+STR((aProComprados[T,3]),22,7)+CRLF
       ENDIF
   NEXT   

ELSEIF MV_PAR03 = "2"

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno de perda sem estrutura..." )
   _nEPSE:=AEST046R(_oSelf,_lEnd,"SELECT_EPSE")//SEM ESTRUTURA

ENDIF
_oSelf:SetRegua2( 0 )

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+" - Lendo Anulacao de Credito..." )
_nAnulaCred:=0
IF MV_PAR14 = "1" .OR. MV_PAR14 = "3"
   _nAnulaCred:=AEST046R(_oSelf,_lEnd,"SELECT_ANULACAO_CREDITO")
ENDIF

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+" - Lendo Glosa de Credito..." )
_nGlosaCred:=0
IF MV_PAR14 = "2" .OR. MV_PAR14 = "3"
   _nGlosaCred:=AEST046R(_oSelf,_lEnd,"SELECT_GLOSA_CREDITO")
ENDIF

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+" - Lendo Deb/cod apur ICMS..." )

_nDebApurICMS:=0
IF !EMPTY(MV_PAR11)
   _nDebApurICMS:=AEST046R(_oSelf,_lEnd,"SELECT_DEB_COD_APUR_ICMS")
ENDIF

_nCredApurICMS:=0
IF !EMPTY(MV_PAR12)
   _nCredApurICMS:=AEST046R(_oSelf,_lEnd,"SELECT_CRE_COD_APUR_ICMS")
ENDIF


nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+" - Lendo Despesas do programa..." )
_nDP:=AEST046R(_oSelf,_lEnd,"SELECT_DP")

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+"- Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+"- Lendo Multas fiscais..." )
_nMF:=AEST046R(_oSelf,_lEnd,"SELECT_MF")

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+" - Lendo Bolsa Garantia..." )

_nBG:=0
IF !EMPTY(MV_PAR06)
   _nBG:=AEST046R(_oSelf,_lEnd,"SELECT_BG_SE5")
   IF _nBG = 0
      _nBG:=AEST046R(_oSelf,_lEnd,"SELECT_BG_SE2")
   ENDIF   
ENDIF

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+" - Lendo Valor do Mix do Leite..." )
_nMixVLR:=AEST046R(_oSelf,_lEnd,"SELECT_MIX_VLR")

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )
_oSelf:IncRegua2(_cSeq+"- Lendo Volme do Mix do Leite..." )
_nMixVOL:=AEST046R(_oSelf,_lEnd,"SELECT_MIX_VOL")
_nMix:=_nMixVLR / _nMixVOL

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores" )
_oSelf:IncRegua2(_cSeq+" - Lendo Rendimento do integral..." )
_cTipo:= "INTEGRAL"
_aRenUnt:=AEST046R(_oSelf,_lEnd,"SELECT_GRUPO_002")

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores" )
_oSelf:IncRegua2(_cSeq+" - Lendo Rendimento do desnatado..." )
_cTipo:= "DESNATADO"
_aRenDes:=AEST046R(_oSelf,_lEnd,"SELECT_GRUPO_002")

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores" )
_oSelf:IncRegua2(_cSeq+" - Lendo Rendimento do desnatado..." )
_cTipo:= "LEITE CONDESADO"
_aRenLCon:=AEST046R(_oSelf,_lEnd,"SELECT_GRUPO_002")

nSeq++
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Calculo da Necessidade" )

nTotLP   :=0
IF MV_PAR16 = "1"//Valor Desconciderado LP Recebido em Transferencia

   nQtdBaseI:=0
   nQtdBaseD:=0
   nTotLP   :=0
   _aNeceI  :={}
   _aNeceD  :={}

   _oSelf:SetRegua2( 4 )

   _oSelf:IncRegua2(_cSeq+" - Lendo Desc Benef LP Integral 1/4" )
   nQtdBaseI:=AEST046R(_oSelf,_lEnd,"SELECT_DESC_BENEF_LP_INTEGRAL")

   IF nQtdBaseI > 0

		_oSelf:IncRegua2(_cSeq+" - Lendo Necessidade Integral 2/4" )

		aTab:=AEST046R(_oSelf,_lEnd,"SELECT_NECESSIDADE_INTEGRAL")
		//AADD(_aTab,{TRB->D3_COD,     //1
		//            TRB->PERC_PRD,   //2
		//            TRB->MINVENDA,   //3
		//            TRB->B1_CONV,    //4
		//            TRB->B1_TIPCONV})//5
        _aNeceI:=AEST046Necess( nQtdBaseI , aTab )

   ENDIF

   _oSelf:IncRegua2(_cSeq+" - Lendo Desc Desc Benef LP Desnatado 3/4" )
   nQtdBaseD:=AEST046R(_oSelf,_lEnd,"SELECT_DESC_BENEF_LP_DESNATADO")

   IF nQtdBaseD > 0

       _oSelf:IncRegua2(_cSeq+" - Lendo Necessidade Desnatado 4/4" )

       aTab:=AEST046R(_oSelf,_lEnd,"SELECT_NECESSIDADE_DESNATADO")
		//AADD(_aTab,{TRB->D3_COD,     //1
		//            TRB->PERC_PRD,   //2
		//            TRB->MINVENDA,   //3
		//            TRB->B1_CONV,    //4
		//            TRB->B1_TIPCONV})//5
       _aNeceD:= AEST046Necess( nQtdBaseD , aTab )

   ENDIF

   nTotLP:=0
   IF LEN(_aNeceI) > 0
      FOR I := 1 TO LEN(_aNeceI) 
          //FCalcVlrLPI_noBenfic( aTab[I,1] , ( nPerQtde + _aNece[LEN(_aNece),2] ) - nResto , _nMINVENDA )
          _aNeceI[I,5] := FCalcVlrLPI_noBenfic(_aNeceI[I,1] , _aNeceI[I,3], _aNeceI[I,4])
          nTotLP+=_aNeceI[I,5]
      NEXT   
   ENDIF

   IF LEN(_aNeceD) > 0
      FOR I := 1 TO LEN(_aNeceD) 
          //FCalcVlrLPI_noBenfic( aTab[I,1] , ( nPerQtde + _aNece[LEN(_aNece),2] ) - nResto , _nMINVENDA )
          _aNeceD[I,5] := FCalcVlrLPI_noBenfic(_aNeceD[I,1] , _aNeceD[I,3], _aNeceD[I,4])
          nTotLP+=_aNeceD[I,5]
      NEXT   
   ENDIF

ENDIF

_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para Rateio" )

_nEPCE :=0 
IF MV_PAR03 = "1" //Estornar cred x estrutura
   _oSelf:SetRegua2( 4 )
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno de perda com estrutura 1/4" )
   aProdutos:=AEST046R(_oSelf,_lEnd,"SELECT_EPCE")//COM ESTRUTURA
   
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno de perda com estrutura 2/4" )
   
   cProd_EN_IN:=""//Preenchido na função AEST46Estr(aProdutos) e Variavel cProd_EN_IN usa na AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")
   aTp_EM_IN:=AEST46Estr(aProdutos)///EXPLODE A ESTRURA
   aProdutos:=AEST046R(_oSelf,_lEnd,"SELECT_EPCE_2")//('IN','EM','MC') //COM ESTRUTURA
   
   FOR T := 1 TO LEN(aProdutos)
       IF ASCAN(aTp_EM_IN , {|P| P[1] == aProdutos[T,1]  })  = 0
          cProd_EN_IN+=aProdutos[T,1] +";"
          _cValores+="LISTA1 da SELECT_05_COM_DT cProd_EN_IN: ;"+aProdutos[T,1]+";"+STR(aProdutos[T,2],22,7)+CRLF
       ENDIF   
       AADD(aTp_EM_IN,aProdutos[T])
   NEXT
   
   IF _lLog
      FOR T := 1 TO LEN(aTp_EM_IN)
          _cValores+="LISTA2 DA JUNTA1 aTp_EM_IN;"+aTp_EM_IN[T,1]+";"+STR(aTp_EM_IN[T,2],22,7)+CRLF//OK
      NEXT
   ENDIF
   
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno de perda com estrutura 3/4" )
   
   _cValores+="SELECT_EPCE;cProd_EN_IN: ; "+cProd_EN_IN+";"+STR(LEN(aTp_EM_IN),22,7)+CRLF
   aProCompDT:=AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")
   
   cProd_SEM_DT:=""
   FOR T := 1 TO LEN(aTp_EM_IN)
       IF ASCAN(aProCompDT , {|P| P[1] == aTp_EM_IN[T,1]  })  = 0
          cProd_SEM_DT+=aTp_EM_IN[T,1]+";"
          _cValores+="LISTA3 da SELECT_05_SEM_DT cProd_SEM_DT:;"+aTp_EM_IN[T,1]+";"+STR(aTp_EM_IN[T,2],22,7)+CRLF
       ENDIF
   NEXT
   
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno de perda com estrutura 4/4..." )
   _cValores+="SELECT_EPCE;cProd_SEM_DT: ; "+cProd_SEM_DT+CRLF
   cProd_EN_IN:=cProd_SEM_DT//Variavel cProd_EN_IN Usa na AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")
   aProComprados:=AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")
   FOR T := 1 TO LEN(aProCompDT)
       AADD(aProComprados,aProCompDT[T])
   NEXT
   IF _lLog
      FOR T := 1 TO LEN(aProComprados)
          _cValores+="LISTA4 da JUNTA2 aProComprados:;"+aProComprados[T,1]+";"+STR(aProComprados[T,2],22,7)+";"+STR(aProComprados[T,3],22,7)+CRLF
      NEXT
   ENDIF
   _nEPCE :=0 
   FOR T := 1 TO LEN(aTp_EM_IN)
       IF (nPos:=ASCAN(aProComprados , {|P| P[1] == aTp_EM_IN[T,1]  } )) <> 0       
          _nEPCE +=  ( aTp_EM_IN[T,2] * aProComprados[nPos,2] * aProComprados[nPos,3] )
          _cValores+="LISTA5 SOMA DO _nEPCE;"+aProComprados[nPos,1]+";"+STR(aTp_EM_IN[T,2],22,7)+";"+STR(aProComprados[nPos,2],22,7)+";"+STR((aProComprados[nPos,3]),22,7)+CRLF
       ENDIF
   NEXT   

ELSEIF MV_PAR03 = "2"//b.	2 - Estornar cred x percentual

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno de perda com estrutura" )
   _nEPCE:=AEST046R(_oSelf,_lEnd,"SELECT_EPCE_5")//COM ESTRUTURA

ENDIF
// *************************  CALCULOS PARA MANAUS  ****************************************************************
_oSelf:SetRegua2( 0 )
_cSeq:=STRZERO(nSeq,2)+cTot
_oSelf:IncRegua1(_cSeq+" - Executando Leitura de Valores para MANAUS" )

_nODEB :=0 
_nODEB2:=0 
IF MV_PAR07 = "2" .OR.  MV_PAR07 = "3" //2 – Estorna cred x operação .OR. //3 – Credita pela operação 
   _oSelf:SetRegua2( 3 )
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorna / Credita pela Operacao  1/3" )
   nVlrCreditos:=AEST046R(_oSelf,_lEnd,"SELECT_ODEB_1")

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorna / Credita pela Operacaoa 2/3" )
   nVlrZFM     :=AEST046R(_oSelf,_lEnd,"SELECT_ODEB_2")

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorna / Credita pela Operacao 3/3..." )
   nVlrTotal   :=AEST046R(_oSelf,_lEnd,"SELECT_ODEB_3")
   _nODEB:=nVlrCreditos * (nVlrZFM/nVlrTotal)

   _cValores+="SELECT_ODEB;nVlrCreditos * (nVlrZFM/nVlrTotal): ; "+STR(nVlrCreditos,22,7)+";"+STR(nVlrZFM,22,7)+";"+STR(nVlrTotal,22,7)+CRLF

ELSEIF MV_PAR07 = "1" 

// *************************  _nODEB  **************************************************************** MANAUS
   _oSelf:SetRegua2( 4 )
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 1/4" )
   aProdutos:=AEST046R(_oSelf,_lEnd,"SELECT_EPCE_3")

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 2/4" )
   cProd_EN_IN:=""//Preenchido na função AEST46Estr(aProdutos) e Variavel cProd_EN_IN usa na AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")
   aTp_EM_IN:=AEST46Estr(aProdutos)///EXPLODE A ESTRURA

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 3/4" )
   _cValores+="SELECT_ODEB;cProd_EN_IN: ; "+cProd_EN_IN+";"+STR(LEN(aTp_EM_IN),22)+CRLF
   aProCompDT:=AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")

   cProd_SEM_DT:=""
   FOR T := 1 TO LEN(aTp_EM_IN)
       IF ASCAN(aProCompDT , {|P| P[1] == aTp_EM_IN[T,1]  })  = 0
          cProd_SEM_DT+=aTp_EM_IN[T,1]+";"
       ENDIF   
   NEXT

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 4/4" )
   _cValores+="SELECT_ODEB;cProd_SEM_DT: ; "+cProd_SEM_DT+CRLF
   cProd_EN_IN:=cProd_SEM_DT//Variavel cProd_EN_IN Usa na AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")
   aProComprados:=AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")//SELECT SEM FILTRO DE DATA
   FOR T := 1 TO LEN(aProCompDT)
       AADD(aProComprados,aProCompDT[T])
   NEXT
   _nODEB :=0 
   FOR T := 1 TO LEN(aProComprados)
       IF (nPos:=ASCAN(aTp_EM_IN , {|P| P[1] == aProComprados[T,1]  } )) <> 0       
          _nODEB +=  ( aTp_EM_IN[nPos,2] * aProComprados[T,2] * aProComprados[T,3] )
          _cValores+="SELECT_ODEB;"+aProComprados[T,1]+";"+STR(aTp_EM_IN[nPos,2],22,7)+";"+STR(aProComprados[T,2],22,7)+";"+STR((aProComprados[T,3]),22,7)+CRLF
       ENDIF
   NEXT   

// *************************  _nODEB2  **************************************************************** MANAUS
   _oSelf:SetRegua2( 3 )
   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 1/3" )
   aProdutos:=AEST046R(_oSelf,_lEnd,"SELECT_EPCE_4")

   
   cProd_EN_IN:=""//Preenchido ABAIXO e Variavel cProd_EN_IN usa na AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")
   FOR T := 1 TO LEN(aProdutos)
       IF !aProdutos[T,1]  $ cProd_EN_IN
          cProd_EN_IN+=aProdutos[T,1]+";"
       ENDIF   
   NEXT
   aTp_EM_IN:=ACLONE(aProdutos)

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 2/3" )
   _cValores+="SELECT_ODEB2;cProd_EN_IN: ; "+cProd_EN_IN+";"+STR(LEN(aTp_EM_IN),22)+CRLF
   aProCompDT:=AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")

   cProd_SEM_DT:=""
   FOR T := 1 TO LEN(aTp_EM_IN)
       IF ASCAN(aProCompDT , {|P| P[1] == aTp_EM_IN[T,1]  })  = 0
          cProd_SEM_DT+=aTp_EM_IN[T,1]+";"
       ENDIF   
   NEXT

   _oSelf:IncRegua2(_cSeq+" - Lendo Estorno Credito x Estrutura 3/3" )
   _cValores+="SELECT_ODEB2;cProd_SEM_DT: ; "+cProd_SEM_DT+CRLF
   cProd_EN_IN:=cProd_SEM_DT//Variavel cProd_EN_IN Usa na AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")
   aProComprados:=AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")//SELECT SEM FILTRO DE DATA
   FOR T := 1 TO LEN(aProCompDT)
       AADD(aProComprados,aProCompDT[T])
   NEXT
   _nODEB2 :=0 
   FOR T := 1 TO LEN(aProComprados)
       IF (nPos:=ASCAN(aTp_EM_IN , {|P| P[1] == aProComprados[T,1]  } )) <> 0       
          _nODEB2 +=  ( aTp_EM_IN[nPos,2] * aProComprados[T,2] * aProComprados[T,3] )
          _cValores+="SELECT_ODEB2;"+aProComprados[T,1]+";"+STR(aTp_EM_IN[nPos,2],22,7)+";"+STR(aProComprados[T,2],22,7)+";"+STR((aProComprados[T,3]),22,7)+CRLF
       ENDIF
   NEXT   

ENDIF
// *************************  CALCULOS PARA MANAUS  ****************************************************************

_oself:IncRegua1("Calculando Regra...")
_oself:IncRegua2("Calculando Regra...")

ZM0->(DBSEEK(xFilial()))
ZM0->(dbEval({|| nTotal++},Nil,	{||	xFilial("ZM0")	 ==	ZM0->ZM0_FILIAL },Nil,Nil,.T.))
ZM0->(DBSEEK(xFilial()))
_cTotReg:=ALLTRIM(STR(nTotal))
_oSelf:SetRegua1( nTotal )
_oSelf:SetRegua2( nTotal )

_nBaseGeral:=0
_nBaseCFinan:=0
_nBaseT1Geral:=0
_nBaseT2Geral:=0
_aBasePresumido:={}
_nBaseLPOGeral:=0

_nRatGeral:=0
_nRatT1Geral:=0
_nRatT2Geral:=0

_nQuant:=0
_nQuantVLROP:=0
_nVLROPDQuant:=0

IF _lLog
   _cValores+=_cLogQuerys
   _cValores+=_cVal2
   _cValores+=_cVal3
   _cValores+=_cTeste
   _cValores:=STRTRAN(_cValores,".",",")
   _cValores+="MIX:; "+STR(_nMix,22,7)+CRLF+CRLF
   _cValores+="REGRA;GRUPO;PERC;SOMA;VLR SD3"+CRLF
   _cValores+="ZM0->ZM0_CODEVE+;+ZM0->ZM0_GRPPRS+;+STR(ZM0->ZM0_PRSPRD,5,2)+;+STR((aCalc[03]-aCalc[06]),22,7)+;+STR(_aBasePresumido[_nPos,3],22,7)"+CRLF
ENDIF

DO While ZM0->(!Eof()) .AND. ZM0->ZM0_FILIAL == xFilial("ZM0")
   nConta++
   _oself:IncRegua1("Calculando Regra: "+LEFT(ZM0->ZM0_EVDESC,25))
   _oself:IncRegua2("Calculando Regra: "+ALLTRIM(STR(nConta,6))+" de "+_cTotReg)
    ProcessMessages()
    IF _lEnd 
       IF (_lEnd:=U_ITMSG("Confirma Cancelamento? .","Atenção",,3,2,2))
          RETURN .F.
       ENDIF   
    ENDIF

    aCalc:=ARRAY(LEN(aCampos)+1)

    IF ZM0->ZM0_MSBLQL <> '1'

       aCalc[01]:=SUBSTR(MV_PAR01,5,2)+SUBSTR(MV_PAR01,1,4)  //01-ZM1_DATARQ 
       aCalc[02]:=ZM0->ZM0_CODEVE+"-"+Posicione("ZM0",1,xFilial("ZM0")+ZM0->ZM0_CODEVE,"ZM0_EVDESC")//02-ZM1_CODEVE

       aCalc[03]:=AEST046R(_oSelf,_lEnd,"SELECT_01")         //03-ZM1_VLROP
       _nQuantVLROP:=_nQuant//Variavel _nQuant preenchida na função AEST046R(_oSelf,_lEnd,"SELECT_01")  

       aCalc[04]:=aCalc[03]*(ZM0->ZM0_ALIQ/100)              //04-ZM1_ICMSAI :=ZM1_VLROP * ZM0->ZM0_ALIQ
       aCalc[05]:=aCalc[03]*(ZM0->ZM0_BENEF/100)             //05-ZM1_CREDS  :=ZM1_VLROP * ZM0->ZM0_BENEF

       aCalc[06]:=AEST046R(_oSelf,_lEnd,"SELECT_02")         //06-ZM1_VLROPD    
       _nVLROPDQuant:=_nQuant//Variavel _nQuant preenchida na função AEST046R(_oSelf,_lEnd,"SELECT_02")  

       aCalc[07]:=aCalc[06]*(ZM0->ZM0_ALIQ/100)              //07-ZM1_ICMSD  :=ZM1_VLROPD * ZM0->ZM0_ALIQ
       aCalc[08]:=aCalc[06]*(ZM0->ZM0_BENEF/100)             //08-ZM1_ESTCRD :=ZM1_VLROPD * ZM0->ZM0_BENEF
       aCalc[09]:=aCalc[04]-aCalc[05]-aCalc[07]+aCalc[08]    //09-ZM1_ICMAPG :=(ZM1_ICMSAI - ZM1_CREDS - ZM1_ICMSD + ZM1_ESTCRD)
       aCalc[10]:=(aCalc[05]-aCalc[08])*(ZM0->ZM0_DEBBNF/100)//10-ZM1_DBBENF :=(ZM1_CREDS  - ZM1_ESTCRD) * ZM0->ZM0_DEBBNF
       aCalc[11]:=(aCalc[03]-aCalc[06])*(ZM0->ZM0_DEBVND/100)//11-ZM1_DBVND  :=(ZM1_VLROP  - ZM1_VLROPD) * ZM0->ZM0_DEBVND
       aCalc[16]:=0//"ZM1_OCRED" ,"C-Outros Crd"
       aCalc[19]:=0//"ZM1_PRSPRD","C-Presm Prod"
       aCalc[20]:=0//"ZM1_PRSOPE","C-Presm Oper"
       aCalc[21]:=0//"ZM1_CDBENF","C-Crd S/ Bnf"
       aCalc[22]:=0//"ZM1_ODEB"  ,"D-Outros Deb

       _nZM1_PRSOPE:=0

       IF ZM0->ZM0_PRSPRD > 0
          IF (_nPos:=ASCAN(_aBasePresumido , {|G| G[1] = ZM0->ZM0_GRPPRS } )) = 0 
             _nQtde:=AEST046R(_oSelf,_lEnd,"SELECT_03")//ZM1_PRSPRD = 
             AADD(_aBasePresumido, {ZM0->ZM0_GRPPRS , (aCalc[03]-aCalc[06])  , _nQtde } )//SOMA: ZM1_VLROP-ZM1_VLROPD
             _nPos:=LEN(_aBasePresumido)
          ELSE
              _aBasePresumido[_nPos,2]+=(aCalc[03]-aCalc[06]) //SOMA: ZM1_VLROP-ZM1_VLROPD
          ENDIF
           _cValores+=ZM0->ZM0_CODEVE+";"+ZM0->ZM0_GRPPRS+";"+STR(ZM0->ZM0_PRSPRD,5,2)+";"+STR((aCalc[03]-aCalc[06]),22,7)+";"+STR(_aBasePresumido[_nPos,3],22,7)+CRLF
       ENDIF
       
       IF  ZM0->ZM0_PRSOPE > 0  

          _nRen:=0
	       
          If EMPTY(ZM0->ZM0_OPREN) .AND. !EMPTY(ZM0->ZM0_MPCONS) .AND. !EMPTY(ZM0->ZM0_CCCONS)
             aRegra:=STRTRAN(ALLTRIM(ZM0->ZM0_BASREN),"/",";")
             aRegra:=STRTOKARR(aRegra,';')
             _aRendim:=AEST046R(_oSelf,_lEnd,"SELECT_04")//ZM1_PRSOPE =
             _nRen:=AEST46Ren(_aRendim,aRegra)//PADRAO DAS REGRAS ZM0

          ELSEIF ZM0->ZM0_OPREN = "1"
//           aRegra:={"08000000028","RE1" , '08140000001', 'PR0', '08140000011', 'PR0'}//INTEGRAL
             aRegra:=StrTokArr(ALLTRIM(U_ITGETMV("ITAEST46_01", "08000000028;RE1;08140000001;PR0;08140000011;PR0" )) ,';')
             _nRen:=AEST46Ren(_aRenUnt,aRegra)

//            aRegra:={"00020010501","RE1" }//LEITE CONDESADO
             aRegra:=StrTokArr(ALLTRIM(U_ITGETMV("ITAEST46_02", "00020010501;RE1" )) ,';')
             nValor1:=0
             AEST46Ren(_aRenLCon,aRegra)
             nLeiteLPI:=nValor1*_nRen

//           aRegra:={"08000000051","RE1" , '00030041402', 'PR0'}//LEITE CONDESADO
             aRegra:=StrTokArr(ALLTRIM(U_ITGETMV("ITAEST46_03","08000000051;RE1;08140000026;PR0" )) ,';')
             nValor1:=0
             nValor2:=0
             AEST46Ren(_aRenLCon,aRegra)
             _nRen:= (nValor1 + nLeiteLPI) / nValor2
             
          ELSEIF ZM0->ZM0_OPREN = "2"
//           aRegra:={"08000000028","RE1" , '08140000001', 'PR0', '08140000011', 'PR0'}//INTEGRAL
             aRegra:=StrTokArr(ALLTRIM(U_ITGETMV("ITAEST46_04", "08000000028;RE1;08140000001;PR0;08140000011;PR0" )) ,';')
             nValor1:=0
             nValor2:=0
             nValor3:=0
             AEST46Ren(_aRenUnt,aRegra)
             nValorA:=nValor1
             nValorB:=nValor2
             nValorC:=nValor3

//           aRegra:={"08000000050","RE1" , '08140000002', 'PR0', '08140000012', 'PR0'}//DESNATADO
             aRegra:=StrTokArr(ALLTRIM(U_ITGETMV("ITAEST46_05", "08000000050;RE1;08140000002;PR0;08140000012;PR0" )) ,';')
             nValor1:=0
             nValor2:=0
             nValor3:=0
             AEST46Ren(_aRenDes,aRegra)
             nValorA:=nValor1+nValorA
             nValorB:=nValorB+nValor2+nValorC+nValor3
             _nRen:= nValorA / nValorB

          ELSEIF ZM0->ZM0_OPREN = "3"//INTEGRAL
//           aRegra:={"08000000028","RE1" , '08140000001', 'PR0', '08140000011', 'PR0'}
             aRegra:=StrTokArr(ALLTRIM(U_ITGETMV("ITAEST46_06", "08000000028;RE1;08140000001;PR0;08140000011;PR0" )) ,';')
             _nRen:=AEST46Ren(_aRenUnt,aRegra)

          ELSEIF ZM0->ZM0_OPREN = "4"//DESNATADO
//           aRegra:={"08000000050","RE1" , '08140000002', 'PR0', '08140000012', 'PR0'}
             aRegra:=StrTokArr(ALLTRIM(U_ITGETMV("ITAEST46_07", "08000000050;RE1;08140000002;PR0;08140000012;PR0" )) ,';')/////////////
             _nRen:=AEST46Ren(_aRenDes,aRegra)

          ELSEIF ZM0->ZM0_OPREN = "5"//1 POR 1
             
             _nZM1_PRSOPE:= (_nQuantVLROP-_nVLROPDQuant) * _nMix * (ZM0->ZM0_PRSOPE/100)

          ENDIF

          IF ZM0->ZM0_OPREN <> "5"
             //ZM1_PRSOPE = ((ZM1_VLROP - ZM1_VLROPD) * rendimento Leite) * MIX * _nRen
             _nZM1_PRSOPE:= ((_nQuantVLROP-_nVLROPDQuant) * _nRen ) * _nMix * (ZM0->ZM0_PRSOPE/100)
          ENDIF

          _cVal2+=ZM0->ZM0_CODEVE+";"+STR(_nZM1_PRSOPE,22,7)+";"+STR(_nQuantVLROP,22,7)+";"+STR(_nVLROPDQuant,22,7)+";"+STR((_nRen),22,7)+";"+STR(_nMix,22,7)+";"+STR((ZM0->ZM0_PRSOPE/100),22,7)+";"+STR((ZM0->ZM0_LMT1P),22,7)+CRLF

          IF !EMPTY(ZM0->ZM0_LMT1P)
         
             //Limitador = (ZM1_ICMSAI - ZM1_ICMSD) * ZM0_LMT1P
             nLimitador := (aCalc[04] - aCalc[07]) * (ZM0->ZM0_LMT1P/100)
             //Resultado = Se cálculo > Limitador, mantém limitador, se não mantém o Cálculo
             IF _nZM1_PRSOPE > nLimitador
                _nZM1_PRSOPE:= nLimitador
             ENDIF
         
         ELSEIF ZM0->ZM0_LMT2C = '1'
         
             aProdutos:=AEST046R(_oSelf,_lEnd,"SELECT_01_B")
             
             aProdSD1:=AEST046R(_oSelf,_lEnd,"SELECT_02_B")

             FOR T := 1 TO LEN(aProdSD1)
                 nQTSD2:=0
                 IF (nPos:=ASCAN(aProdutos , {|P| P[1] == aProdSD1[T,1]  })  ) <> 0
                    aProdutos[nPos,2]:=aProdutos[nPos,2] - aProdSD1[T,2]
                    nQTSD2:=aProdutos[nPos,2] 
                  ELSE
                    AADD(aProdutos,aProdSD1[T])  
                    aProdutos[LEN(aProdutos),2]:=(aProdutos[LEN(aProdutos),2] * -1)
                 ENDIF   
                 _cVal3+="RG: "+ZM0->ZM0_CODEVE+";"+aProdSD1[T,1] +"; SD2: "+STR(nQTSD2,22) +"; - SD1: "+STR(aProdSD1[T,2],22) +CRLF
             NEXT

             cProd_EN_IN:=""//Preenchido na função AEST46Estr(aProdutos) e Variavel cProd_EN_IN usa na AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")
             aTp_EM_IN:=AEST46Estr(aProdutos)///EXPLODE A ESTRURA

             _cVal3+="RG: "+ZM0->ZM0_CODEVE+";cProd_EN_IN: ; "+cProd_EN_IN+";"+STR(LEN(aTp_EM_IN),22)+CRLF

             aProCompDT:=AEST046R(_oSelf,_lEnd,"SELECT_05_COM_DT")
             
             cProd_SEM_DT:=""
             FOR T := 1 TO LEN(aTp_EM_IN)
                 IF ASCAN(aProCompDT , {|P| P[1] == aTp_EM_IN[T,1]  })  = 0
                    cProd_SEM_DT+=aTp_EM_IN[T,1]+";"
                 ENDIF   
             NEXT
             _cVal3+="RG: "+ZM0->ZM0_CODEVE+";cProd_SEM_DT: ; "+cProd_SEM_DT+CRLF
             
             cProd_EN_IN:=cProd_SEM_DT//Variavel cProd_EN_IN Usa na AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")
             aProComprados:=AEST046R(_oSelf,_lEnd,"SELECT_05_SEM_DT")

             FOR T := 1 TO LEN(aProCompDT)
                 AADD(aProComprados,aProCompDT[T])
             NEXT

             nLimitador :=0 //(ZM1_ICMSAI - ZM1_ICMSD)  - ((QTD_ZM1_VLROP - QTD_ZM1_VLROPD)  (Estrutura)  preço compra * Alíq. ICMS )

             FOR T := 1 TO LEN(aProComprados)

                 IF (nPos:=ASCAN(aTp_EM_IN , {|P| P[1] == aProComprados[T,1]  } )) <> 0
                    
                    nLimitador +=  ( aTp_EM_IN[nPos,2] * aProComprados[T,2] * aProComprados[T,3] )

                    _cVal3+="RG: "+ZM0->ZM0_CODEVE+";"+aProComprados[T,1]+";"+STR(aTp_EM_IN[nPos,2],22,7)+";"+STR(aProComprados[T,2],22,7)+";"+STR((aProComprados[T,3]),22,7)+CRLF

                 ENDIF   

             NEXT
             _cVal3+="RG: "+ZM0->ZM0_CODEVE+";TOTAL: ; +STR((aCalc[04] - aCalc[07]),22,7)+;+STR(nLimitador,22,7)"+CRLF
             _cVal3+="RG: "+ZM0->ZM0_CODEVE+";TOTAL: ; "+STR((aCalc[04] - aCalc[07]),22,7)+";"+STR(nLimitador,22,7)+CRLF
             
             nLimitador := (aCalc[04] - aCalc[07])  - nLimitador

             IF _nZM1_PRSOPE > nLimitador
                _nZM1_PRSOPE:= nLimitador
             ENDIF

          ELSEIF ZM0->ZM0_OPREN = "6" //d.	Quando "ZM0_OPREN" estiver como "6 - % direto VLR operação"
             
	          IF ZM0->ZM0_RDBASE = "1"  //                  (aCalc[03]-aCalc[06]) 
                //i.	(((ZM0_ALIQ - ZM0_BENEF)/ZM0_ALIQ) * (ZM1_VLROP - ZM1_VLROPD)) * (ZM0_PRSOPE/100)
                _nZM1_PRSOPE:=(((ZM0->ZM0_ALIQ - ZM0->ZM0_BENEF)/ZM0->ZM0_ALIQ)  * (aCalc[03]-aCalc[06]) ) * (ZM0->ZM0_PRSOPE/100)
	          ELSEIF ZM0->ZM0_RDBASE = "2"
                //i.	(ZM0_ALIQ * (ZM1_VLROP - ZM1_VLROPD)) * (ZM0_PRSOPE/100)
                _nZM1_PRSOPE:=((ZM0->ZM0_ALIQ/100) * (aCalc[03]-aCalc[06]) ) * (ZM0->ZM0_PRSOPE/100)
	          ENDIF

          ENDIF

          aCalc[20]:=_nZM1_PRSOPE//ZM1_PRSOPE =  ((ZM1_VLROP - ZM1_VLROPD) * rendimento Leite) * MIX * _nRen*/

       ELSE   
          aCalc[20]:=0
       ENDIF   

       aCalc[21]:=(aCalc[05]-aCalc[08])*(ZM0->ZM0_CRDBNF/100)//21-ZM1_CDBENF := (ZM1_CREDS - ZM1_ESTCRD) * ZM0_CRDBNF           

       _nBaseGeral+=(aCalc[03]-aCalc[06])     //SOMA: ZM1_VLROP-ZM1_VLROPD
       IF ZM0->ZM0_TIPO = '1'
          _nBaseT1Geral+=(aCalc[03]-aCalc[06])//SOMA: ZM1_VLROP-ZM1_VLROPD
       ELSEIF ZM0->ZM0_TIPO = '2'
          _nBaseT2Geral+=(aCalc[03]-aCalc[06])//SOMA: ZM1_VLROP-ZM1_VLROPD
       ENDIF   
       
       IF IF(ZM0->(FIELDPOS("ZM0_DSCBNT"))=0,(ZM0->ZM0_CODEVE $ "000022/000006"),(ZM0->ZM0_DSCBNT = '1'))
          _nBaseLPOGeral+=(aCalc[03]-aCalc[06])
       ENDIF   

	    IF ZM0->ZM0_RDBASE = "1"
//        _nBaseCFinan += ((ZM1_CREDS - ZM1_ESTCRD) - ((ZM1_VLROP - ZM1_VLROPD) * (ZM0_BENEF/100))) 
          _nBaseCFinan += ((aCalc[05]-aCalc[08]) - ((aCalc[03]-aCalc[06]) * (ZM0->ZM0_BENEF/100))) 
       ELSEIF ZM0->ZM0_RDBASE = "2"
//        _nBaseCFinan += (ZM1_CREDS - ZM1_ESTCRD)
          _nBaseCFinan += (aCalc[05]-aCalc[08])
	    ENDIF

	   aCalc[LEN(aCalc)]:=ZM0->(RECNO())//ULTIMA POSICAO  LEN(aCampos)+1

    ELSE
       aCalc:=ARRAY(LEN(aCampos)+1)//{"","",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	   FOR T := 1 TO LEN(aCampos)
	      aCalc[T]:=0
	   NEXT
      aCalc[01]:=SUBSTR(MV_PAR01,5,2) +  SUBSTR(MV_PAR01,1,4) 
      aCalc[02]:="RG: "+ZM0->ZM0_CODEVE+" - [BLOQUEADO]"//+Posicione("ZM0",1,xFilial("ZM0")+ZM0->ZM0_CODEVE,"ZM0_EVDESC")//ZM1_CODEVE
	   aCalc[LEN(aCalc)]:=ZM0->(RECNO())//ULTIMA POSICAO  LEN(aCampos)+1
    ENDIF
    
    AADD(aDadosCalc,aCalc)   
   
    _cVal3+=CRLF

    ZM0->(DBSKIP())

ENDDO

_cSegfOR:=CRLF+"FOR 2"+CRLF

IF EMPTY(MV_PAR06) .AND. !EMPTY(MV_PAR08) .AND. (!EMPTY(MV_PAR09) .OR. !EMPTY(MV_PAR10))
   _oSelf:SetRegua1( 2 )
   _oSelf:SetRegua2( 2 )
   _oSelf:IncRegua1("Executando Leitura de Valores para Rateio" )
   _oSelf:IncRegua2("Lendo Bolsa Garantia..." )
   _nBG_Ori:=AEST046R(_oSelf,_lEnd,"SELECT_BG_GIGANTE")

   IF !EMPTY(MV_PAR09)
//    _nBG := (Resultado * (% Programa financiado/100)) * (% Bolsa Garantia sobre financiado/100) 
      _cSegfOR+="(_nBG_Ori * (MV_PAR08/100)) * (MV_PAR09/100) ;"+STR(_nBG_Ori,22,7)+";"+STR(MV_PAR08,5,2)+";"+STR(MV_PAR09,5,2)+CRLF
      _nBG := (_nBG_Ori * (MV_PAR08/100)) * (MV_PAR09/100) 
   ENDIF
 
   IF !EMPTY(MV_PAR10)
//    _nBG += (Resultado * (% Programa financiado/100)) * (% Protege sobre financiado/100)
      _nBG += (_nBG_Ori * (MV_PAR08/100)) * (MV_PAR10/100) 
      _cSegfOR+="(_nBG_Ori * (MV_PAR08/100)) * (MV_PAR10/100) ;"+STR(_nBG_Ori,22,7)+";"+STR(MV_PAR08,5,2)+";"+STR(MV_PAR10,5,2)+CRLF
   ENDIF
   _cSegfOR+="_nBG: ;"+STR(_nBG,22,7)+CRLF

ENDIF

nConta:=0
nTotal:=LEN(aDadosCalc)
_cTotReg:=ALLTRIM(STR(nTotal))
_oSelf:SetRegua1( nTotal )
_oSelf:SetRegua2( nTotal )

IF _lLog
   _cValores+=_cLogQuerys
   _cValores+=_cVal2
   _cValores+=_cVal3
   _cValores+=_cTeste
   _cValores:=STRTRAN(_cValores,".",",")
   _cValores+=CRLF+"FOR 2"+CRLF
   _cValores+=CRLF+"REGRA;GRUPO;PERC;RATEIO;VLR SD3"+CRLF
ENDIF

PRIVATE nTotal17:=0
nVlrDesLPRecTrans:=0

FOR T :=  1 TO LEN(aDadosCalc)
	
    nConta++
    _oself:IncRegua2("Recalculando Regra: "+ALLTRIM(STR(nConta,6))+" de "+_cTotReg)

	aCalc:=aDadosCalc[T]
	IF aCalc[LEN(aCalc)] = 0
       _oself:IncRegua1("Recalculando Regra: ")
	   LOOP
	ELSE
	   ZM0->(DBGOTO(aCalc[LEN(aCalc)]))
	ENDIF
    _oself:IncRegua1("Recalculando Regra: "+LEFT(ZM0->ZM0_EVDESC,25))
    ProcessMessages()

   IF (_nPos:=ASCAN(_aBasePresumido , {|G| G[1] = ZM0->ZM0_GRPPRS } )) <> 0 
      _nRatPresumido:=((aCalc[03]-aCalc[06])/_aBasePresumido[_nPos,2] )//Rateio
      aCalc[19] := (_nRatPresumido * (_nMix * _aBasePresumido[_nPos,3] )) * (ZM0->ZM0_PRSPRD/100) //ZM1_PRSPRD = Rateio * Preco Unt MIX * Qtde MP consumida
      _cValores+="RG: "+ZM0->ZM0_CODEVE+";"+ZM0->ZM0_GRPPRS+";"+STR(ZM0->ZM0_PRSPRD,5,2)+";"+STR(_nRatPresumido,22,7)+";"+STR(_aBasePresumido[_nPos,3],22,7)+CRLF
   ENDIF
   aCalc[09] := (aCalc[09] - aCalc[19] - aCalc[20] ) //09-ZM1_ICMAPG - ZM1_PRSPRD - ZM1_PRSOPE

	_nRatGeral   :=((aCalc[03]-aCalc[06]) / _nBaseGeral)//Rateio
	_nRatT1Geral :=((aCalc[03]-aCalc[06]) / _nBaseT1Geral)//Rateio
	_nRatT2Geral :=((aCalc[03]-aCalc[06]) / _nBaseT2Geral)//Rateio
	_nRatT3Geral :=((aCalc[03]-aCalc[06]) / (_nBaseGeral-_nBaseT1Geral-_nBaseT2Geral))//Rateio
	_nRatGerT1Sem:=((aCalc[03]-aCalc[06]) / (_nBaseGeral-_nBaseT2Geral))//Rateio
	_nRatGerT2Sem:=((aCalc[03]-aCalc[06]) / (_nBaseGeral-_nBaseT1Geral))//Rateio
	_nRatLPOGeral:=((aCalc[03]-aCalc[06]) / _nBaseLPOGeral)
   
   aCalc[12]:=0
   aCalc[13]:=0
   aCalc[15]:=0
   aCalc[16]:=0
   aCalc[22]:=0
	
   IF ZM0->ZM0_TIPO = '1'//1=Producao Propria
      IF MV_PAR03 = "1" //1 – Estorna cred x Estrutura 
		   aCalc[12]:=_nEPCE * _nRatT1Geral //12-ZM1_ESTPRD:=
      ELSEIF MV_PAR03 = "2"//b.	2 - Estornar cred x percentual
		   aCalc[12]:=_nEPCE * _nRatT1Geral * (ZM0->ZM0_ESPERD/100)  //12-ZM1_ESTPRD:=
      ENDIF   
	   aCalc[13]:=(_nDP*_nRatT1Geral)//13-ZM1_JUROSI:=	
	   aCalc[15]:=(_nBG*_nRatT1Geral)//15-ZM1_BGARAN:=

      IF MV_PAR07 = "1" //1 – Estorna cred x Estrutura 
		   aCalc[22]:=_nODEB * _nRatT1Geral //22-ZM1_ODEB:=
      ENDIF   

   ELSEIF ZM0->ZM0_TIPO = '2'//2=Mercadoria Adquirida
      IF MV_PAR03 = "1" //1 – Estorna cred x Estrutura 
		   aCalc[12]:= (_nEPSE - (_nEPSE * ((_nBaseGeral-_nBaseT1Geral-_nBaseT2Geral) / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT2Geral //12-ZM1_ESTPRD:=   
      ELSEIF MV_PAR03 = "2"//b.	2 - Estornar cred x percentual
		   aCalc[12]:= (_nEPSE - (_nEPSE * ((_nBaseGeral-_nBaseT1Geral-_nBaseT2Geral) / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT2Geral * (ZM0->ZM0_ESPERD/100) //12-ZM1_ESTPRD:=
      ENDIF   
      IF MV_PAR07 = "1" //1 – Estorna cred x Estrutura 
		   aCalc[22]:= (_nODEB2 - (_nODEB2 * ((_nBaseGeral-_nBaseT1Geral-_nBaseT2Geral) / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT2Geral //22-ZM1_ODEB:=
      ENDIF
  
   ELSE //ZM0->ZM0_TIPO = '3'//3=Ambas	
      IF _nBaseT1Geral = 0
         IF MV_PAR03 = "1" //1 – Estorna cred x Estrutura 
		      aCalc[12]:=(_nEPCE * _nRatGerT1Sem) //12-ZM1_ESTPRD:=
         ELSEIF MV_PAR03 = "2"//b.	2 - Estornar cred x percentual
		      aCalc[12]:=(_nEPCE * _nRatGerT1Sem * (ZM0->ZM0_ESPERD/100))  //12-ZM1_ESTPRD:=
         ENDIF   
	   	 aCalc[13]:=(_nDP * _nRatGerT1Sem)//13-ZM1_JUROSI:=
   	     aCalc[15]:=(_nBG * _nRatGerT1Sem)  //15-ZM1_BGARAN:=
	   	 IF MV_PAR07 = "1" //1 – Estorna cred x Estrutura 
	   		aCalc[22]:=(_nODEB * _nRatGerT1Sem) // 22-ZM1_ODEB:=
	   	 ENDIF

	  ENDIF
   
	  IF _nBaseT2Geral = 0
         IF MV_PAR03 = "1" //1 – Estorna cred x Estrutura 
		      aCalc[12]+=(_nEPSE * _nRatGerT2Sem) //12-ZM1_ESTPRD:=
         ELSEIF MV_PAR03 = "2"//b.	2 - Estornar cred x percentual
		      aCalc[12]+=(_nEPSE * _nRatGerT2Sem * (ZM0->ZM0_ESPERD/100)) //12-ZM1_ESTPRD:=
         ENDIF   
	   	IF MV_PAR07 = "1" //1 – Estorna cred x Estrutura
	   		aCalc[22]+=(_nODEB2 * _nRatGerT2Sem)  //22-ZM1_ODEB:=
	   	ENDIF
	  ENDIF   

      IF _nBaseT1Geral > 0 .AND. _nBaseT2Geral > 0
         IF MV_PAR03 = "1" //1 – Estorna cred x Estrutura 
		      aCalc[12]+=((_nEPSE - (_nEPSE * (_nBaseT2Geral / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT3Geral) //12-ZM1_ESTPRD:=
         ELSEIF MV_PAR03 = "2"//b.	2 - Estornar cred x percentual
		      aCalc[12]+=((_nEPSE - (_nEPSE * (_nBaseT2Geral / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT3Geral * (ZM0->ZM0_ESPERD/100)) //12-ZM1_ESTPRD:=
         ENDIF             
   	    
	   	 IF MV_PAR07 = "1" //1 – Estorna cred x Estrutura 
	   		aCalc[22]+=((_nODEB2 - (_nODEB2 * (_nBaseT2Geral / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT3Geral)  //22-ZM1_ODEB:=
	   	 ENDIF

	  ENDIF
	     
   ENDIF

   IF IF(ZM0->(FIELDPOS("ZM0_DSCBNT"))=0,(ZM0->ZM0_CODEVE $ "000022/000006"),(ZM0->ZM0_DSCBNT = '1')) .AND. nTotLP > 0//ou "Sim"
      nTotLPAux:=  ( (nTotLP * _nRatLPOGeral) * (ZM0->ZM0_BENEF/100) ) - ( ((nTotLP * _nRatLPOGeral) * (ZM0->ZM0_BENEF/100)) * (ZM0->ZM0_DEBBNF/100) )  + ( ((nTotLP * _nRatLPOGeral) * (ZM0->ZM0_BENEF/100)) * (ZM0->ZM0_CRDBNF/100) ) 
      aCalc[22]+= nTotLPAux           //já possui várias valores/rateios
      nVlrDesLPRecTrans += nTotLPAux  //para informar na aDadosTela
   ENDIF
   	 

   aCalc[14]:=(_nMF*_nRatGeral)//14-ZM1_MTFISC:=
   aCalc[22]+=(_nAnulaCred * _nRatGeral)//22-ZM1_ODEB :=      
   aCalc[22]+=(_nGlosaCred * _nRatGeral)//22-ZM1_ODEB :=    

   IF MV_PAR13 = "1"  // Geral
      aCalc[22]+=(_nDebApurICMS  * _nRatGeral)//22-ZM1_ODEB :=
      aCalc[16]+=(_nCredApurICMS * _nRatGeral)//16- ZM1_OCRED :=
   ELSEIF MV_PAR13 = "2"//Somente Produção
      IF ZM0->ZM0_TIPO = '1'//1=Producao Propria
         aCalc[22]+=(_nDebApurICMS  * _nRatT1Geral)//22-ZM1_ODEB :=
         aCalc[16]+=(_nCredApurICMS * _nRatT1Geral)//16- ZM1_OCRED :=
      ENDIF   
   ENDIF

   IF MV_PAR07 = "2" //2 – Estorna cred x operação
      aCalc[22]+=(_nODEB * _nRatGeral) //22-ZM1_ODEB :=         
   ELSEIF MV_PAR07 = "3" //3 – Credita pela operação 
      aCalc[16]+=(_nODEB * _nRatGeral) //16-ZM1_OCRED:=
   EndIf

   //17-ZM1_DESP:=(ZM1_ICMAPG+ZM1_DBBENF+ZM1_DBVND+ZM1_ESTPRD+ZM1_JUROSI+ZM1_MTFISC+ZM1_BGARAN-ZM1_OCRED-ZM1_CDBENF+ZM1_ODEB)
   aCalc[17]:=(aCalc[09] +aCalc[10] +aCalc[11]+aCalc[12] +aCalc[13] +aCalc[14] +aCalc[15] -aCalc[16] - aCalc[21] +aCalc[22]  )
   aCalc[18]:=( (aCalc[17]/ (aCalc[03]-aCalc[06] )) *100 ) //18-ZM1_CUSICM:=( (ZM1_DESP / (ZM1_VLROP-ZM1_VLROPD)) *100 )
	
   aDadosCalc[T]:=aCalc
   
   IF ZM0->ZM0_TIPO = '1'//1=Producao Propria
      nTotal17+=aCalc[17]//17-ZM1_DESP
   ENDIF   

NEXT

lRecalc:=.F.
iF MV_PAR15 = "1" .AND. nTotal17 < 0
   nTotal17:= nTotal17 * -1
   lRecalc:=.T.
ENDIF

nConta:=0
nTotal:=LEN(aDadosCalc)
_cTotReg:=ALLTRIM(STR(nTotal))
_oSelf:SetRegua1( nTotal )
_oSelf:SetRegua2( nTotal )
	
FOR T :=  1 TO LEN(aDadosCalc)
	
	nConta++
	_oself:IncRegua2("Recalculando Regra: "+ALLTRIM(STR(nConta,6))+" de "+_cTotReg)
	
	aCalc:=aDadosCalc[T]
	IF aCalc[LEN(aCalc)] = 0
		_oself:IncRegua1("Recalculando Regra: ")
		LOOP
	ELSE
		ZM0->(DBGOTO(aCalc[LEN(aCalc)]))
	ENDIF
	_oself:IncRegua1("Recalculando Regra: "+LEFT(ZM0->ZM0_EVDESC,25))
	ProcessMessages()
	
	iF lRecalc
		
		_nRatGeral   :=((aCalc[03]-aCalc[06]) / _nBaseGeral)//Rateio
		_nRatT1Geral :=((aCalc[03]-aCalc[06]) / _nBaseT1Geral)//Rateio
		_nRatT2Geral :=((aCalc[03]-aCalc[06]) / _nBaseT2Geral)//Rateio
		_nRatT3Geral :=((aCalc[03]-aCalc[06]) / (_nBaseGeral-_nBaseT1Geral-_nBaseT2Geral))//Rateio
		_nRatGerT1Sem:=((aCalc[03]-aCalc[06]) / (_nBaseGeral-_nBaseT2Geral))//Rateio
		_nRatGerT2Sem:=((aCalc[03]-aCalc[06]) / (_nBaseGeral-_nBaseT1Geral))//Rateio
		
		IF ZM0->ZM0_TIPO = '1'//1=Producao Propria /DEBITO
			
			aCalc[22]+=nTotal17 * _nRatT1Geral //22-ZM1_ODEB :=
			aCalc[17]+=nTotal17 * _nRatT1Geral//17-ZM1_DESP
			
		ELSEIF ZM0->ZM0_TIPO = '2'//2=Mercadoria Adquirida //CREDITO
			
			aCalc[16]+= (nTotal17 - (nTotal17 * ((_nBaseGeral-_nBaseT1Geral-_nBaseT2Geral) / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT2Geral //16-ZM1_OCRED :=
			aCalc[17]-= (nTotal17 - (nTotal17 * ((_nBaseGeral-_nBaseT1Geral-_nBaseT2Geral) / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT2Geral//17-ZM1_DESP
			
		ELSE //ZM0->ZM0_TIPO = '3'//3=Ambas	//CREDITO
			
			IF _nBaseT2Geral = 0
				
				aCalc[16]+= (nTotal17 * _nRatGerT2Sem)  //16-ZM1_OCRED :=
				aCalc[17]-= (nTotal17 * _nRatGerT2Sem)//17-ZM1_DESP
				
			ENDIF
			
			IF _nBaseT1Geral > 0 .AND. _nBaseT2Geral > 0
				
				aCalc[16]+=((nTotal17 - (nTotal17 * (_nBaseT2Geral / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT3Geral)   //16-ZM1_OCRED :=
				aCalc[17]-=((nTotal17 - (nTotal17 * (_nBaseT2Geral / (_nBaseGeral - _nBaseT1Geral) ))) * _nRatT3Geral)//17-ZM1_DESP
				
			ENDIF
			
		ENDIF
   
        aCalc[18]:=( (aCalc[17]/ (aCalc[03]-aCalc[06] )) *100 ) //18-ZM1_CUSICM:=( (ZM1_DESP / (ZM1_VLROP-ZM1_VLROPD)) *100 )
		
	ENDIF
	
	aCalcTela:=ARRAY(LEN(aCampos))
	FOR I := 1 TO LEN(aCampos)
		IF VALTYPE(aCalc[I]) = "N" //I > 2 // NUMERICOS
			aCalcTela[I]:=Transform(aCalc[I],"@E 999,999,999,999.99")
		ELSEIF I = 2
			aCalcTela[I]:=ZM0->ZM0_TIPO+"-"+aCalc[I]
		ELSE
			aCalcTela[I]:=aCalc[I]
		ENDIF
	NEXT
	AADD(aDadosTela,aCalcTela)
	
NEXT

IF _lLog
   _cValores+=_cSegfOR
   _cValores:=STRTRAN(_cValores,".",",")
ENDIF

_cMsgTop:='AEST046 - Calculo de custo do ICMS da filial atual / H.I.: '+cHoraIni+" - H.F.: "+TIME()+" / Dt Inicial: "+DTOC(STOD(MV_PAR01))+" - Dt Final: "+DTOC(STOD(MV_PAR02))

aTitAux:={}
aSizesAux:={}
FOR I := 1 TO LEN(aCampos)
    AADD(aTitAux,aCampos[I,2])
    AADD(aSizesAux,aCampos[I,3])
NEXT

aTit:={}
aSizes:={}
FOR I := 1 TO (LEN(aTitAux)-4)
    AADD(aTit,aTitAux[I])
    AADD(aSizes,aSizesAux[I])
    IF I = 8
       AADD(aTit,aTitAux[19])
       AADD(aSizes,aSizesAux[19])
       AADD(aTit,aTitAux[20])
       AADD(aSizes,aSizesAux[20])
    ELSEIF I = 10
       AADD(aTit,aTitAux[21])
       AADD(aSizes,aSizesAux[21])
    ELSEIF I = 16
       AADD(aTit,aTitAux[22])
       AADD(aSizes,aSizesAux[22])
    ENDIF
NEXT

aDadosAux:=ACLONE(aDadosTela)
aDadosTela:={}
FOR I := 1 TO LEN(aDadosAux)
    aDadosTAux:={}
    FOR T := 1 TO (LEN(aDadosAux[I])-4)
        AADD(aDadosTAux,aDadosAux[I][T])
        IF T = 8
           AADD(aDadosTAux,aDadosAux[I][19])
           AADD(aDadosTAux,aDadosAux[I][20])
        ELSEIF T = 10
           AADD(aDadosTAux,aDadosAux[I][21])
        ELSEIF T = 16
           AADD(aDadosTAux,aDadosAux[I][22])
        ENDIF
    NEXT
    AADD(aDadosTela,aDadosTAux)
NEXT

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Estorno de perda com estrutura:"
aDadosTela[nPos,3]:=Transform(_nEPCE,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Estorno de perda sem estrutura:"
aDadosTela[nPos,3]:=Transform(_nEPSE,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Despesas do programa:"
aDadosTela[nPos,3]:=Transform(_nDP,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Multas fiscais:" 
aDadosTela[nPos,3]:=Transform(_nMF,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Bolsa Garantia:"
aDadosTela[nPos,3]:=Transform(_nBG,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Anulacao de Credito:"
aDadosTela[nPos,3]:=Transform(_nAnulaCred,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Glosa de Credito:"
aDadosTela[nPos,3]:=Transform(_nGlosaCred,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Debito / codigo apuracao ICMS:"
aDadosTela[nPos,3]:=Transform(_nDebApurICMS,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Credito / codigo apuracao ICMS:"
aDadosTela[nPos,3]:=Transform(_nCredApurICMS,"@E 999,999,999,999.99")

AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
nPos:=LEN(aDadosTela)
aDadosTela[nPos,1]:=aCalc[01]
aDadosTela[nPos,2]:="Valor Operacao Manaus:"
aDadosTela[nPos,3]:=Transform(_nODEB+_nODEB2,"@E 999,999,999,999.99")

IF MV_PAR15 = "1"
	AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
	nPos:=LEN(aDadosTela)
	aDadosTela[nPos,1]:=aCalc[01]
	aDadosTela[nPos,2]:="Valor da compensação Sobras de Credito:"
	aDadosTela[nPos,3]:=Transform(IF(lRecalc,nTotal17,0),"@E 999,999,999,999.99")
ENDIF

IF MV_PAR16 = "1"
	AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
	nPos:=LEN(aDadosTela)
	aDadosTela[nPos,1]:=aCalc[01]
	aDadosTela[nPos,2]:="Valor Desconciderado LP Recebido em Transferencia"
	aDadosTela[nPos,3]:=Transform(nVlrDesLPRecTrans,"@E 999,999,999,999.99")
ENDIF

DO WHILE  LEN(aDadosTela) > 0
                                  // , _aCols   ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,aSizes, _nCampo , bOk , bCancel, _abuttons )
   lRet:=U_ITListBox( _cMsgTop, aTit ,aDadosTela, .T.    , 1    ,_cMsgTop,          ,aSizes , 1       ,     ,        , )
                                                                                                 
   IF  lRet 
       IF !U_ITMSG("Confirmar gravar os dados calculados ?",'Atenção!',,2,2,2)
          LOOP
       ENDIF   
       
       AEST46Grv(_oSelf,_lEnd)

   ELSEIF !U_ITMSG("TODOS OS CALCULOS SERÃO PERDIDOS, Confirmar SAIDA ?",'Atenção!',,3,2,2)
       LOOP
   ENDIF

   EXIT

ENDDO

RETURN .T.

/*
===============================================================================================================================
Programa----------: AEST046R()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/03/2019
Descricao---------: Executa as SELECTs
Parametros--------: _oSelf,_lEnd,cSelect
Retorno-----------: Valor
===============================================================================================================================
*/
Static Function AEST046R(_oSelf,_lEnd,cSelect)
LOCAL _nVlr:=0
LOCAL _aTab:={}
LOCAL _cQuery:=""

_nQuant:=0

IF cSelect == "SELECT_01_B" .OR.  cSelect == "SELECT_01"

   IF cSelect == "SELECT_01_B"
	   _cQuery:=" SELECT D2_COD D_COD, SUM(D2_QUANT) AS QTDE  "
   ELSEIF cSelect == "SELECT_01"
	   _cQuery:=" SELECT SUM(D2_QUANT * SB1.B1_PESO) AS QTDE , SUM(D2_TOTAL) AS VLR "
   ENDIF
   _cQuery+="       FROM "+RETSQLNAME("SD2")+" SD2"
   _cQuery+="       JOIN "+RetSqlName("SB1")+" SB1 ON SD2.D2_COD = SB1.B1_COD "
	_cQuery+=" WHERE SD2.D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery+="       SD2.D2_TP = 'PA' AND " 

	If !EMPTY(ZM0->ZM0_FILIS)
	   _cQuery+="    SD2.D2_FILIAL  IN " + FormatIn(ALLTRIM(ZM0->ZM0_FILIS),";")+" AND "
    ELSE
	   _cQuery+="    SD2.D2_FILIAL  = '"+cFilAnt+"' AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_PROD)
		_cQuery+="    SD2.D2_COD     IN " + FormatIn(ALLTRIM(ZM0->ZM0_PROD),";")+" AND "
	ELSEIf !EMPTY(ZM0->ZM0_NPROD)
		_cQuery+="    SD2.D2_COD NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NPROD),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_ARMZ)
		_cQuery+="    SD2.D2_LOCAL  IN " + FormatIn(ALLTRIM(ZM0->ZM0_ARMZ),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_GRUPO)
		_cQuery+="    SD2.D2_GRUPO     IN " + FormatIn(ALLTRIM(ZM0->ZM0_GRUPO),";")+" AND "
	ELSEIf !EMPTY(ZM0->ZM0_NGRUPO)
		_cQuery+="    SD2.D2_GRUPO NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NGRUPO),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_CFOPV)
		_cQuery+="    SD2.D2_CF  IN " + FormatIn(ALLTRIM(ZM0->ZM0_CFOPV),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_TES)
		_cQuery+="    SD2.D2_TES     IN " + FormatIn(ALLTRIM(ZM0->ZM0_TES),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_NTES)
		_cQuery+="    SD2.D2_TES NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NTES),";")+" AND "
	ENDIF
	
	If	!EMPTY(ZM0->ZM0_UF)
		_cQuery+="    SD2.D2_EST      IN " + FormatIn(ALLTRIM(ZM0->ZM0_UF),";")+" AND "
	ELSEIf !EMPTY(ZM0->ZM0_NUF)
		_cQuery+="    SD2.D2_EST  NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NUF),";")+" AND "
	ENDIF
	
	IF ZM0->ZM0_RDBASE = "1"
  		_cQuery+=" ((SD2.D2_EST = '"+_cEstFilAnt+"' AND D2_TOTAL <> D2_BASEICM) OR SD2.D2_EST <> '"+_cEstFilAnt+"') AND "
	ELSEIF ZM0->ZM0_RDBASE = "2"
  		_cQuery+=" ((SD2.D2_EST = '"+_cEstFilAnt+"' AND D2_TOTAL =  D2_BASEICM) OR SD2.D2_EST <> '"+_cEstFilAnt+"') AND "
	ENDIF
	
	IF ZM0->ZM0_TIPO = "1"
		_cQuery+=" D2_COD     IN (SELECT DISTINCT G1_COD FROM "+RETSQLNAME("SG1")+" WHERE D_E_L_E_T_ = ' ' AND G1_FILIAL = '"+cFilAnt+"') AND "
	ELSEIF ZM0->ZM0_TIPO = "2"
		_cQuery+=" D2_COD NOT IN (SELECT DISTINCT G1_COD FROM "+RETSQLNAME("SG1")+" WHERE D_E_L_E_T_ = ' ' AND G1_FILIAL = '"+cFilAnt+"') AND "
	ENDIF
	_cQuery+=" SD2.D_E_L_E_T_ = ' '  AND  SB1.D_E_L_E_T_ = ' ' "//NÃO PONHA O DELETE PARA CIMA DEIXE SEMPRE POR ULTIMO POR CAUSA DOS AND

   IF cSelect == "SELECT_01_B"
	   _cQuery+=" GROUP BY D2_COD "
   ENDIF

ELSEIF cSelect == "SELECT_02" .OR. cSelect == "SELECT_02_B"

   IF cSelect == "SELECT_02_B"
	   _cQuery:=" SELECT D1_COD D_COD, SUM(D1_QUANT) AS QTDE  "
   ELSEIF cSelect == "SELECT_02"
	   _cQuery:="SELECT SUM(D1_QUANT * SB1.B1_PESO) AS QTDE, SUM(D1_TOTAL) AS VLR 
   ENDIF   
   _cQuery+="       FROM "+RETSQLNAME("SD1")+" SD1"
   _cQuery+="       JOIN "+RetSqlName("SB1")+" SB1 ON SD1.D1_COD = B1_COD "
	_cQuery+="       JOIN "+RETSQLNAME("SF1")+" SF1 ON SD1.D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "  
	_cQuery+=" WHERE SD1.D1_DTDIGIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery+="       SD1.D1_TP = 'PA' AND " 

	If !EMPTY(ZM0->ZM0_FILIS)
	   _cQuery+="    SD1.D1_FILIAL  IN " + FormatIn(ALLTRIM(ZM0->ZM0_FILIS),";")+" AND "
    ELSE
	   _cQuery+="    SD1.D1_FILIAL  = '"+cFilAnt+"' AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_PROD)
		_cQuery+="    SD1.D1_COD     IN " + FormatIn(ALLTRIM(ZM0->ZM0_PROD),";")+" AND "
	ELSEIf !EMPTY(ZM0->ZM0_NPROD)
		_cQuery+="    SD1.D1_COD NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NPROD),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_ARMZ)
		_cQuery+="    SD1.D1_LOCAL  IN " + FormatIn(ALLTRIM(ZM0->ZM0_ARMZ),";")+" AND "
	ENDIF

	If !EMPTY(ZM0->ZM0_GRUPO)
	   _cQuery+="   SD1.D1_GRUPO     IN " + FormatIn(ALLTRIM(ZM0->ZM0_GRUPO ),";")+" AND "
	ELSEIf !EMPTY(ZM0->ZM0_NGRUPO)
		_cQuery+="   SD1.D1_GRUPO NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NGRUPO),";")+" AND "
	ENDIF
	
	If !EMPTY(ZM0->ZM0_CFOPD)
	   _cQuery+="   SD1.D1_CF IN " + FormatIn(ALLTRIM(ZM0->ZM0_CFOPD),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_TES)
		_cQuery+="    SD1.D1_TES     IN " + FormatIn(ALLTRIM(ZM0->ZM0_TES),";")+" AND "
	ENDIF

	If	!EMPTY(ZM0->ZM0_NTES)
		_cQuery+="    SD1.D1_TES NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NTES),";")+" AND "
	ENDIF
	
	If !EMPTY(ZM0->ZM0_UF)
	   _cQuery+="   SF1.F1_EST     IN " + FormatIn(ALLTRIM(ZM0->ZM0_UF),";")+" AND "
	ELSEIf !EMPTY(ZM0->ZM0_NUF)
	   _cQuery+="   SF1.F1_EST NOT IN " + FormatIn(ALLTRIM(ZM0->ZM0_NUF),";")+" AND "
	ENDIF
	
	IF ZM0->ZM0_RDBASE = "1"
  	   _cQuery+=" ((SF1.F1_EST = '"+_cEstFilAnt+"' AND SD1.D1_TOTAL <> SD1.D1_BASEICM) OR SF1.F1_EST <> '"+_cEstFilAnt+"') AND "
	ELSEIF ZM0->ZM0_RDBASE = "2"
  	   _cQuery+=" ((SF1.F1_EST = '"+_cEstFilAnt+"' AND SD1.D1_TOTAL =  SD1.D1_BASEICM) OR SF1.F1_EST <> '"+_cEstFilAnt+"') AND "
	ENDIF
	
	IF ZM0->ZM0_TIPO = "1"
	   _cQuery+=" D1_COD     IN (SELECT DISTINCT G1_COD FROM "+RETSQLNAME("SG1")+" WHERE D_E_L_E_T_ = ' ' AND G1_FILIAL = '"+cFilAnt+"') AND "
	ELSEIF ZM0->ZM0_TIPO = "2"
	   _cQuery+=" D1_COD NOT IN (SELECT DISTINCT G1_COD FROM "+RETSQLNAME("SG1")+" WHERE D_E_L_E_T_ = ' ' AND G1_FILIAL = '"+cFilAnt+"') AND "
	ENDIF
	_cQuery+=" SD1.D_E_L_E_T_ = ' ' AND  SF1.D_E_L_E_T_ = ' '  AND  SB1.D_E_L_E_T_ = ' ' "//NÃO PONHA O DELETE PARA CIMA DEIXE SEMPRE POR ULTIMO POR CAUSA DOS AND

   IF cSelect == "SELECT_02_B"
	   _cQuery+=" GROUP BY D1_COD "
   ENDIF

ELSEIF cSelect == "SELECT_03"

	_cQuery:=" SELECT SUM(SD3.D3_QUANT) AS VLR FROM " + RetSqlName("SD3") + " SD3 "
	_cQuery+=" WHERE SD3.D3_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery+="       SD3.D3_FILIAL = '" + cFilAnt + "' AND "
   _cQuery+="       SD3.D3_CF = 'RE1' AND "

	If	!EMPTY(ZM0->ZM0_MPCONS)
		_cQuery+="    SD3.D3_COD     IN " + FormatIn(ALLTRIM(ZM0->ZM0_MPCONS),";")+" AND "
	ENDIF
	If	!EMPTY(ZM0->ZM0_CCCONS)
		_cQuery+="    SD3.D3_CC      IN " + FormatIn(ALLTRIM(ZM0->ZM0_CCCONS),";")+" AND "
	ENDIF
	_cQuery  += "    SD3.D3_ESTORNO <> 'S' AND  SD3.D_E_L_E_T_ = ' '	"

ELSEIF cSelect == "SELECT_04"

	_cQuery:="SELECT  D3_COD, D3_CF, SUM(D3_QUANT) QTDE FROM  " + RetSqlName("SD3") + " SD3 "
	_cQuery+=" WHERE  SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       (SD3.D3_CF = 'RE1'  OR SD3.D3_CF = 'PR0') AND "
	_cQuery+="        SD3.D3_ESTORNO <> 'S' AND SD3.D3_I_ORIGE <> 'MATA685' AND "
	If	!EMPTY(ZM0->ZM0_MPCONS)
		_cQuery+="    SD3.D3_COD     IN " + FormatIn(ALLTRIM(ZM0->ZM0_MPCONS),";")+" AND "
	ENDIF
	If	!EMPTY(ZM0->ZM0_CCCONS)
		_cQuery+="    SD3.D3_CC      IN " + FormatIn(ALLTRIM(ZM0->ZM0_CCCONS),";")+" AND "
	ENDIF
	_cQuery+="        SD3.D3_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQuery+="  GROUP BY D3_COD, D3_CF "

ELSEIF cSelect == "SELECT_05_COM_DT" .OR. cSelect == "SELECT_05_SEM_DT"

   _cQuery+=" SELECT D1_COD, MAX(D1_PICM) PICM, MAX(D1_VUNIT) VUNIT, MAX(D1_DTDIGIT) MAXDAT "
   _cQuery+=" FROM  " + RetSqlName("SD1") + " SD1 "  
   _cQuery+=" WHERE SD1.D_E_L_E_T_ = ' ' AND " 
   _cQuery+="       SD1.D1_FILIAL  = '" + cFilAnt + "' AND "
   _cQuery+="       SD1.D1_CF NOT IN ('1910', '2910', '1911', '2911', '1949', '2949','1920','1921','2920','2921') AND "
   _cQuery+="       SD1.D1_TIPO = 'N' AND "
   _cQuery+="       SD1.D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT) "
   _cQuery+="                         FROM  " + RetSqlName("SD1") + " SD1 " 
   _cQuery+="                         WHERE SD1.D_E_L_E_T_ = ' ' AND "
   _cQuery+="                               SD1.D1_FILIAL  = '" + cFilAnt + "' AND " 
   _cQuery+="                               SD1.D1_CF NOT IN ('1910', '2910', '1911', '2911', '1949', '2949','1920','1921','2920','2921') AND "
   _cQuery+="                               SD1.D1_TIPO = 'N' AND "
   _cQuery+="                               SD1.D1_DTDIGIT <= '"+ MV_PAR02 + "' AND "
   _cQuery+="                               SD1.D1_COD IN " + FormatIn(ALLTRIM(cProd_EN_IN),";") + " AND " 
   _cQuery+="                               SD1.D_E_L_E_T_ = ' ') AND "
   _cQuery+="       SD1.D1_COD IN " + FormatIn(ALLTRIM(cProd_EN_IN),";") + " AND " 
   _cQuery+="       SD1.D_E_L_E_T_ = ' ' "
   _cQuery+=" GROUP BY D1_COD "

ELSEIF cSelect == "SELECT_GRUPO_002"

	_cQuery:="SELECT  D3_COD, D3_CF, SUM(D3_QUANT) QTDE FROM  " + RetSqlName("SD3") + " SD3 "
	_cQuery+=" WHERE  SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       (SD3.D3_CF = 'RE1'  OR SD3.D3_CF = 'PR0') AND "
	_cQuery+="        SD3.D3_ESTORNO <> 'S' AND SD3.D3_I_ORIGE <> 'MATA685' AND "
	If _cTipo = "INTEGRAL"
       _cItens:=ALLTRIM(U_ITGETMV("ITAEST46_IN", "08000000028;08140000001;08140000011" ))
   	   _cQuery+="     SD3.D3_COD IN "+FormatIn(_cItens,";")+" AND "
    ELSEIF _cTipo = "DESNATADO"
       _cItens:=ALLTRIM(U_ITGETMV("ITAEST46_DE", "08000000050;08140000002;08140000012" ))
   	   _cQuery+="     SD3.D3_COD IN "+FormatIn(_cItens,";")+" AND "
    ELSEIF _cTipo = "LEITE CONDESADO"
       _cItens:=ALLTRIM(U_ITGETMV("ITAEST46_CO", "00030041402;08000000051" ))
   	   _cQuery+="     SD3.D3_COD IN "+FormatIn(_cItens,";")+" AND "
    ENDIF
	_cQuery+="        SD3.D3_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQuery+="  GROUP BY D3_COD, D3_CF "

ELSEIF cSelect == "SELECT_EPCE" .OR. cSelect == "SELECT_EPCE_2" .OR. cSelect == "SELECT_EPCE_3" .OR. cSelect == "SELECT_EPCE_4" .OR. cSelect == "SELECT_EPCE_5" 

   IF cSelect == "SELECT_EPCE_5"
      _cQuery:=" SELECT SUM(D2_TOTAL) AS VLR  "
   ELSE 
      _cQuery:=" SELECT D2_COD D_COD, SUM(D2_QUANT) AS QTDE  "
   ENDIF
	_cQuery+=" FROM "+RETSQLNAME("SD2")+" SD2"
	_cQuery+=" WHERE SD2.D2_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       SD2.D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
   IF cSelect == "SELECT_EPCE_3"
	   
      _cQuery+="    SD2.D2_CF = '6109' AND "
   
   ELSEIF cSelect == "SELECT_EPCE_4"
	   
      _cQuery+="    SD2.D2_CF = '6110' AND "
   ELSE
	   
      _cQuery+="    SD2.D2_CF = '5927' AND "
   ENDIF
   IF cSelect == "SELECT_EPCE" .OR. cSelect == "SELECT_EPCE_5"
	    
      _cQuery+="    SD2.D2_COD IN " 
	   _cQuery+="    (SELECT G1_COD FROM "+RETSQLNAME("SG1")+" SG1 WHERE SG1.D_E_L_E_T_ = ' ' AND SG1.G1_FILIAL IN '"+cFilAnt+"' GROUP BY G1_COD "
	   _cQuery+="     UNION "
	   _cQuery+="     SELECT G1_COMP FROM "+RETSQLNAME("SG1")+" SG1 JOIN "+RETSQLNAME("SB1")+" SB1 ON G1_COMP = B1_COD "
	   _cQuery+="            WHERE SG1.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND SG1.G1_FILIAL IN '"+cFilAnt+"' AND B1_TIPO IN ('MP','PP','PI','EM','IN','MC') GROUP BY G1_COMP "
      _cQuery+="    ) AND "
   
   ELSEIF cSelect == "SELECT_EPCE_2"
	    
      _cQuery+="    SD2.D2_TP IN  ('IN','EM','MC') AND "
   ENDIF    
	_cQuery+="       SD2.D_E_L_E_T_ = ' ' "

   IF cSelect <> "SELECT_EPCE_5"
      _cQuery+="  GROUP BY D2_COD "
   ENDIF   

ELSEIF cSelect == "SELECT_ODEB_1"// VALOR DOS CRÉDITOS:

   _cQuery:=" SELECT (NVL(T.VLR1,0) - NVL(D.VLR2,0)) AS VLR "
	_cQuery+="       FROM (SELECT D1_FILIAL, DECODE(SUM(D1_VALICM),NULL,0,SUM(D1_VALICM)) AS VLR1
   _cQuery+="                    FROM "+RETSQLNAME("SD1")+" SD1 "
   _cQuery+="                    JOIN "+RETSQLNAME("SF4")+" SF4 ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES "
   _cQuery+="                    WHERE  SD1.D_E_L_E_T_ = ' ' AND SF4.D_E_L_E_T_ = ' ' AND  "
   _cQuery+="                           SD1.D1_FILIAL = '"+cFilAnt+"'  AND D1_DTDIGIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND F4_CREDICM = 'S' GROUP BY D1_FILIAL) T "
   _cQuery+="            FULL OUTER JOIN "
	_cQuery+="            (SELECT D1_FILIAL, DECODE(SUM(D1_VALICM),NULL,0,SUM(D1_VALICM))  AS VLR2 "
   _cQuery+="                    FROM "+RETSQLNAME("SD1")+" SD1 "
   _cQuery+="                    JOIN "+RETSQLNAME("SF4")+" SF4 ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES "
   _cQuery+="                    WHERE  SD1.D_E_L_E_T_ = ' ' AND SF4.D_E_L_E_T_ = ' ' AND  "
   _cQuery+="                           SD1.D1_FILIAL = '"+cFilAnt+"'  AND D1_DTDIGIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND F4_CREDICM = 'S' AND F4_SITTRIB = '90' "
   _cQuery+="                           AND D1_CF IN ('1101', '2101') AND D1_TIPO = 'N' GROUP BY D1_FILIAL) D "
   _cQuery+="       ON D.D1_FILIAL = T.D1_FILIAL "

ELSEIF cSelect == "SELECT_ODEB_2" //VALOR ZONA FRANCA DE MANAUS:

   _cQuery:=" SELECT SUM(D2_VALBRUT) AS VLR "
   _cQuery+="        FROM "+RETSQLNAME("SD2")+" SD2 "
   _cQuery+="        WHERE  SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL  = '"+cFilAnt+"'  AND "
   _cQuery+="               SD2.D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND D2_CF IN ('6109', '6110') "

ELSEIF cSelect == "SELECT_ODEB_3" //VALOR TOTAL:

   _cQuery:=" SELECT SUM(D2_VALBRUT) AS VLR "
   _cQuery+="        FROM "+RETSQLNAME("SD2")+" SD2 "
   _cQuery+="        WHERE  SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL  = '"+cFilAnt+"'  AND "
   _cQuery+="               SD2.D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
   
ELSEIF cSelect == "SELECT_EPSE" .OR. cSelect == "SELECT_EPSE_MV03=1"

   IF cSelect == "SELECT_EPSE"
	   _cQuery:="SELECT SUM(D2_TOTAL) AS VLR FROM "+RETSQLNAME("SD2")+" SD2"
   ELSE //cSelect == "SELECT_EPSE_MV03=1"
      _cQuery:="SELECT D2_COD D_COD, SUM(D2_QUANT) AS QTDE FROM "+RETSQLNAME("SD2")+" SD2"
   ENDIF

	_cQuery+=" WHERE SD2.D2_FILIAL = '"+cFilAnt+"' AND
	_cQuery+="       SD2.D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery+="       SD2.D_E_L_E_T_ = ' ' AND "
	_cQuery+="       SD2.D2_CF = '5927' AND "
	_cQuery+="       SD2.D2_COD NOT IN " 
	_cQuery+="   (SELECT G1_COD FROM "+RETSQLNAME("SG1")+" SG1 WHERE SG1.D_E_L_E_T_ = ' ' AND SG1.G1_FILIAL IN '"+cFilAnt+"' GROUP BY G1_COD "
   _cQuery+="     UNION "
	_cQuery+="     SELECT G1_COMP FROM "+RETSQLNAME("SG1")+" SG1 JOIN "+RETSQLNAME("SB1")+" SB1 ON G1_COMP = B1_COD "
	_cQuery+="            WHERE SG1.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND SG1.G1_FILIAL IN '"+cFilAnt+"' AND B1_TIPO IN ('MP','PP','PI','EM','IN','MC') GROUP BY G1_COMP "
   _cQuery+="    )"
   IF cSelect = "SELECT_EPSE_MV03=1"
      _cQuery+="  GROUP BY D2_COD "
   ENDIF   

// * ZM0_ESPERD

ELSEIF cSelect == "SELECT_DP"

	_cQuery:="SELECT SUM(E5_VALOR) AS VLR FROM "+RETSQLNAME("SE5")+" SE5 " 
	_cQuery+=" WHERE SE5.E5_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       SE5.E5_DATA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery+="       SE5.D_E_L_E_T_ = ' ' AND "
	_cQuery+="       SE5.E5_NATUREZ IN " + FormatIn(ALLTRIM(MV_PAR04),";")

ELSEIF cSelect == "SELECT_MF"

	_cQuery:="SELECT SUM(E5_VALOR) AS VLR FROM "+RETSQLNAME("SE5")+" SE5 " 
	_cQuery+=" WHERE SE5.E5_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       SE5.E5_DATA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
 	_cQuery+="       SE5.D_E_L_E_T_ = ' ' AND "
	_cQuery+="       SE5.E5_NATUREZ IN " + FormatIn(ALLTRIM(MV_PAR05),";")+" AND "
	_cQuery+="       SE5.E5_TIPO = 'ICM' "

ELSEIF cSelect == "SELECT_BG_SE5"

	_dInicial := DTOS(MonthSum(STOD(MV_PAR01),1)) //Soma Meses em Uma Data
	_dFinal	  := DTOS(MonthSum(STOD(MV_PAR02),1)) //Soma Meses em Uma Data	 

	_cQuery:="SELECT SUM(E5_VALOR) AS VLR FROM "+RETSQLNAME("SE5")+" SE5 " 
	_cQuery+=" WHERE SE5.E5_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       SE5.E5_DATA BETWEEN '"+_dInicial+"' AND '"+_dFinal+"' AND "
   IF !EMPTY(MV_PAR06)
	   _cQuery+="    SE5.E5_NATUREZ IN " + FormatIn(ALLTRIM(MV_PAR06),";")+" AND "
   ENDIF   
	_cQuery+="       SE5.D_E_L_E_T_ = ' '"

ELSEIF cSelect == "SELECT_BG_SE2"

	_dInicial := DTOS(MonthSum(STOD(MV_PAR01),1)) //Soma Meses em Uma Data
	_dFinal	  := DTOS(MonthSum(STOD(MV_PAR02),1)) //Soma Meses em Uma Data	 

	_cQuery:="SELECT SUM(E2_VALOR) AS VLR FROM "+RETSQLNAME("SE2")+" SE2 " 
	_cQuery+=" WHERE SE2.E2_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       SE2.E2_VENCREA  BETWEEN '"+_dInicial+"' AND '"+_dFinal+"' AND "
   IF !EMPTY(MV_PAR06)
	   _cQuery+="    SE2.E2_NATUREZ IN " + FormatIn(ALLTRIM(MV_PAR06),";")+" AND "
   ENDIF
	_cQuery+="       SE2.D_E_L_E_T_ = ' '"

ELSEIF cSelect == "SELECT_ANULACAO_CREDITO"

	_cQuery:="SELECT NVL(DECODE(SUM(SD2.D2_VALICM),0,SUM(D1_VALICM),SUM(D2_VALICM)),0) AS VLR "
 	_cQuery+="       FROM "+RETSQLNAME("SD2")+" SD2 INNER JOIN "+RETSQLNAME("SD1")+"  SD1 "
   _cQuery+="         ON SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_NFORI = SD1.D1_DOC AND "
   _cQuery+="            SD2.D2_COD = SD1.D1_COD  AND SD2.D2_CLIENTE = SD1.D1_FORNECE "
	_cQuery+=" WHERE SD2.D2_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="       SD2.D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery+="       SD2.D_E_L_E_T_ = ' ' AND SD1.D_E_L_E_T_ = ' ' AND "
	_cQuery+="       SD2.D2_CF IN ('5206', '6206') "

ELSEIF cSelect == "SELECT_GLOSA_CREDITO"

	_cQuery:="SELECT NVL(SUM(D2_TOTAL),0) AS VLR "
 	_cQuery+="     FROM "+RETSQLNAME("SD2")+" SD2 "
   _cQuery+="     JOIN "+RETSQLNAME("SF4")+" SF4 ON F4_FILIAL = D2_FILIAL  AND F4_CODIGO = D2_TES "
   _cQuery+="     WHERE SD2.D_E_L_E_T_ = ' ' AND  SF4.D_E_L_E_T_ = ' ' AND "
	_cQuery+="           SD2.D2_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="           SD2.D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
 	_cQuery+="           SF4.F4_FINALID LIKE '%GLOSA%' "


ELSEIF cSelect == "SELECT_DEB_COD_APUR_ICMS"

	_cQuery:="SELECT NVL(SUM(CDH_VALOR),0) AS VLR "
 	_cQuery+="     FROM "+RETSQLNAME("CDH")+" CDH "
    _cQuery+="     WHERE CDH.D_E_L_E_T_ = ' ' AND CDH_LA = 'S' AND "
	_cQuery+="           CDH_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="           CDH_DTINI = '"+MV_PAR01+"' AND CDH_DTFIM  = '"+MV_PAR02+"' AND "
	_cQuery+="           CDH_CODLAN IN " + FormatIn(ALLTRIM(MV_PAR11),";") 

ELSEIF cSelect == "SELECT_CRE_COD_APUR_ICMS"

	_cQuery:="SELECT NVL(SUM(CDH_VALOR),0) AS VLR "
 	_cQuery+="     FROM "+RETSQLNAME("CDH")+" CDH "
    _cQuery+="     WHERE CDH.D_E_L_E_T_ = ' ' AND CDH_LA = 'S' AND "
	_cQuery+="           CDH_FILIAL = '"+cFilAnt+"' AND "
	_cQuery+="           CDH_DTINI = '"+MV_PAR01+"' AND CDH_DTFIM  = '"+MV_PAR02+"' AND "
	_cQuery+="           CDH_CODLAN IN " + FormatIn(ALLTRIM(MV_PAR12),";") 

ELSEIF cSelect == "SELECT_DESC_BENEF_LP_INTEGRAL"

	_cQuery:="  SELECT (NVL(ENTRLP.QTD, 0) - NVL(SAIDLP.QTD, 0) ) AS VLR"//NQTD 
 	_cQuery+="     FROM
 	_cQuery+="  (SELECT DECODE(SUM(D1_QUANT),NULL,0,SUM(D1_QUANT)) AS QTD FROM "+RETSQLNAME("SD1")+" SD1 " 
 	_cQuery+="     WHERE SD1.D_E_L_E_T_ = ' ' AND D1_FILIAL = '"+cFilAnt+"' AND 
 	_cQuery+="           D1_DTDIGIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
 	_cQuery+="           D1_CF = '2151' AND 
 	_cQuery+="           SUBSTR(D1_COD,1,9) = '000200105') ENTRLP, 
 	_cQuery+="  (SELECT DECODE(SUM(D2_QUANT),NULL,0,SUM(D2_QUANT)) AS QTD FROM "+RETSQLNAME("SD2")+" SD2 " 
 	_cQuery+="     WHERE SD2.D_E_L_E_T_ = ' ' AND " 
 	_cQuery+="           D2_FILIAL = '"+cFilAnt+"' AND 
    _cQuery+="         	 D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"' AND "
    _cQuery+="           D2_CF = '6102' AND "
 	_cQuery+="           SUBSTR(D2_COD,1,9) = '000200105') SAIDLP   "

ELSEIF cSelect == "SELECT_DESC_BENEF_LP_DESNATADO"

	_cQuery:="  SELECT (NVL(ENTRLP.QTD, 0) - NVL(SAIDLP.QTD, 0) ) AS VLR"//NQTD 
 	_cQuery+="     FROM
 	_cQuery+="  (SELECT DECODE(SUM(D1_QUANT),NULL,0,SUM(D1_QUANT)) AS QTD FROM "+RETSQLNAME("SD1")+" SD1 " 
 	_cQuery+="     WHERE SD1.D_E_L_E_T_ = ' ' AND D1_FILIAL = '"+cFilAnt+"' AND 
 	_cQuery+="           D1_DTDIGIT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
 	_cQuery+="           D1_CF = '2151' AND 
 	_cQuery+="           SUBSTR(D1_COD,1,9) = '000200205') ENTRLP, 
 	_cQuery+="  (SELECT DECODE(SUM(D2_QUANT),NULL,0,SUM(D2_QUANT)) AS QTD FROM "+RETSQLNAME("SD2")+" SD2 " 
 	_cQuery+="     WHERE SD2.D_E_L_E_T_ = ' ' AND " 
 	_cQuery+="           D2_FILIAL = '"+cFilAnt+"' AND 
    _cQuery+="         	 D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"' AND "
    _cQuery+="           D2_CF = '6102' "
 	_cQuery+="     AND SUBSTR(D2_COD,1,9) = '000200205') SAIDLP   "

ELSEIF cSelect == "SELECT_NECESSIDADE_INTEGRAL"

	_cQuery:="  SELECT D3_COD, "
	_cQuery+="         (RATIO_TO_REPORT(SUM(D3_QTSEGUM)) OVER () ) AS PERC_PRD, "
	_cQuery+="         B1_I_QT3UM AS MINVENDA, B1_CONV, " 
	_cQuery+="         B1_TIPCONV "
	_cQuery+="         FROM "+RETSQLNAME("SD3")+" SD3 JOIN "+RETSQLNAME("SB1")+" SB1  ON D3_COD = B1_COD "
	_cQuery+="         WHERE SD3.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
	_cQuery+="         AND D3_FILIAL IN ('01') AND SUBSTR(D3_COD,1,7) = '0002001' AND D3_SEGUM = 'KG' "
	_cQuery+="         AND D3_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQuery+="         AND D3_ESTORNO <> 'S' AND D3_CF = 'PR0' AND D3_LOCAL = '30' "
	_cQuery+="         GROUP BY D3_COD, B1_I_QT3UM, B1_CONV, B1_TIPCONV  " 
	_cQuery+="         ORDER BY B1_I_QT3UM DESC "

ELSEIF cSelect == "SELECT_NECESSIDADE_DESNATADO"

	_cQuery:="  SELECT D3_COD, "
	_cQuery+="         (RATIO_TO_REPORT(SUM(D3_QTSEGUM)) OVER () ) AS PERC_PRD, "
	_cQuery+="         B1_I_QT3UM AS MINVENDA, B1_CONV, " 
	_cQuery+="         B1_TIPCONV "
	_cQuery+="         FROM "+RETSQLNAME("SD3")+" SD3 JOIN "+RETSQLNAME("SB1")+" SB1  ON D3_COD = B1_COD "
	_cQuery+="         WHERE SD3.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
	_cQuery+="         AND D3_FILIAL IN ('01') AND SUBSTR(D3_COD,1,7) = '0002002' AND D3_SEGUM = 'KG' "
	_cQuery+="         AND D3_EMISSAO BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"' "
	_cQuery+="         AND D3_ESTORNO <> 'S' AND D3_CF = 'PR0' AND D3_LOCAL = '30' "
	_cQuery+="         GROUP BY D3_COD, B1_I_QT3UM, B1_CONV, B1_TIPCONV  " 
	_cQuery+="         ORDER BY B1_I_QT3UM DESC "

ELSEIF cSelect == "SELECT_BG_GIGANTE"

   _cQuery:=AEST46BG()

ELSEIF cSelect == "SELECT_MIX_VLR"

   _cQuery:=GetVlrMix()

ELSEIF cSelect == "SELECT_MIX_VOL"

   _cQuery:=VolLeite()

ENDIF

BEGIN SEQUENCE

   _cQValores:=""
   _lRetTab:=(cSelect == "SELECT_GRUPO_002" .OR. cSelect == "SELECT_04"        .OR. cSelect == "SELECT_01_B" .OR. cSelect == "SELECT_EPCE"   .OR.;
              cSelect == "SELECT_05_COM_DT" .OR. cSelect == "SELECT_05_SEM_DT" .OR. cSelect == "SELECT_02_B" .OR. cSelect == "SELECT_EPCE_2" .OR.;
              cSelect == "SELECT_EPCE_3"    .OR. cSelect == "SELECT_EPCE_4"    .OR. cSelect == "SELECT_EPSE_MV03=1" .OR. "SELECT_NECESSIDADE" $ cSelect)

   _lRetCOD_QTDE:=(cSelect == "SELECT_01_B"   .OR. cSelect == "SELECT_02_B"   .OR. cSelect == "SELECT_EPCE"  .OR. cSelect == "SELECT_EPCE_2" .OR.;
                   cSelect == "SELECT_EPCE_3" .OR. cSelect == "SELECT_EPCE_4" .OR. cSelect == "SELECT_EPSE_MV03=1")
   
   MPSysOpenQuery( ChangeQuery(_cQuery) ,"TRB" ) 

   IF _lRetTab//QUANDO O RETORNO É UMA TABELA DE VARIAS COLUNAS E LINHAS
      
      DO WHILE .NOT. TRB->( EOF() )
         
         IF _lRetCOD_QTDE//DEVOLVE CODIGO + QTDE
            AADD(_aTab,{TRB->D_COD,TRB->QTDE})
            _cQValores+= "RG: "+ZM0->ZM0_CODEVE+" ; "+TRB->D_COD+" ; "+STR(TRB->QTDE,22,7)+CRLF
         
         ELSEIF cSelect == "SELECT_05_COM_DT" .OR. cSelect == "SELECT_05_SEM_DT"// DEVOLVE CODIGO + VLR UNIT + ICMS
            AADD(_aTab,{TRB->D1_COD,TRB->VUNIT,(TRB->PICM/100)})
            _cQValores+= "RG: "+ZM0->ZM0_CODEVE+" ; "+TRB->D1_COD+" ; "+STR(TRB->VUNIT,22,7)+" ; "+STR(TRB->PICM/100,22,7)+CRLF

         ELSEIF "SELECT_NECESSIDADE" $ cSelect
         
            AADD(_aTab,{TRB->D3_COD,TRB->PERC_PRD,TRB->MINVENDA,TRB->B1_CONV,TRB->B1_TIPCONV})

            _cQValores+= "RG: "+ZM0->ZM0_CODEVE+" ; "+TRB->D3_COD+" ; "+STR(TRB->PERC_PRD,22,7)+" ; "+STR(TRB->MINVENDA,22,7)+" ; "+STR(TRB->B1_CONV,22,7)+" ; "+TRB->B1_TIPCONV+CRLF

         ELSE //DEVOLVE CODIGO + CF + QTDE
            AADD(_aTab,{TRB->D3_COD,TRB->D3_CF,TRB->QTDE})
            _cQValores+= "RG: "+ZM0->ZM0_CODEVE+" ; "+TRB->D3_COD+" ; "+TRB->D3_CF+" ; "+STR(TRB->QTDE,22,7)+CRLF
         ENDIF
         TRB->( DBSKIP() )
      ENDDO
   
   ELSE//RETORNA UM VALOR OU/E UMA QUANTIDADE 
   
      If .NOT. TRB->( EOF() )
         _nVlr:=TRB->VLR
         IF cSelect == "SELECT_01" .OR. cSelect == "SELECT_02"
            _nQuant:=TRB->QTDE
            _cQValores+="RG: "+ZM0->ZM0_CODEVE+"; "+STR(_nQuant,22,7)+CRLF
         ENDIF
      Endif
      _cQValores+="RG: "+ZM0->ZM0_CODEVE+"; "+STR(_nVlr,22,7)+CRLF
   
   Endif

RECOVER
   
END SEQUENCE

_cLogQuerys+="RG: "+ZM0->ZM0_CODEVE+"; "+cSelect+"; "+_cQuery+CRLF+_cQValores
_cLogQuerys+="********************************************************************************************************"+CRLF

TRB->( DBCloseArea() )

IF _lRetTab
   RETURN _aTab
ELSE
   RETURN _nVlr
ENDIF

/*
===============================================================================================================================
Programa----------: AEST46Grv()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/03/2019
Descricao---------: Grava dados
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function AEST46Grv(_oSelf,_lEnd)
LOCAL nConta:= 0 , I , C
LOCAL nTotal:=LEN(aDadosCalc)

IF nTotal = 0
   U_ITMSG("Não tem registros para gravação",'Atenção!',,1)
   RETURN .F.
ENDIF
_oSelf:SetRegua1( nTotal+1 )
_oSelf:SetRegua2( nTotal+1 )
_oSelf:IncRegua1("Gravando Dados, Aguarde..." )
_oSelf:IncRegua2("Gravando Dados, Aguarde..." )
_cTotReg:=ALLTRIM(STR(nTotal))

ZM1->(DBSETORDER(1))//ZM1_FILIAL+ZM1_DATARQ+ZM1_CODEVE
ZM0->(DBSETORDER(1))//"ZM0_FILIAL+ZM0_CODEVE"

FOR I := 1 TO nTotal

    nConta++
    _oself:IncRegua1("Gravando Regra: "+LEFT(aDadosCalc[I,2],25))
    _oself:IncRegua2("Gravando Regra: "+ALLTRIM(STR(nConta,6))+" de "+_cTotReg)
    ProcessMessages()
    IF "[BLOQUEADO]" $ aDadosCalc[I,2]//ZM0->(DBSEEK( xFilial()+ LEFT(aDadosCalc[I,2],LEN(ZM0->ZM0_CODEVE)))) .AND. ZM0->ZM0_MSBLQL = "1"
       LOOP
    ENDIF    

    IF ZM1->(DBSEEK( xFilial()+ aDadosCalc[I,1] + LEFT(aDadosCalc[I,2],LEN(ZM1->ZM1_CODEVE))))
       ZM1->(RECLOCK("ZM1",.F.))
    ELSE
       ZM1->(RECLOCK("ZM1",.T.))   
    ENDIF
    ZM1->ZM1_FILIAL:=xFilial("ZM1")
    FOR C := 1 TO LEN(aCampos)
        ZM1->(FieldPut( FieldPos(aCampos[C][1]),aDadosCalc[I,C]))
    NEXT    
    ZM1->(MSUNLOCK())

NEXT    
nConta:=0
ZM1->(DBSEEK( xFilial()+ aDadosCalc[1,1]))
DO While ZM1->(!Eof()) .AND. ZM1->ZM1_FILIAL == xFilial("ZM0") .AND. ZM1->ZM1_DATARQ == aDadosCalc[1,1] 
   nConta++
    _oself:IncRegua2("Limpando Regras: "+ALLTRIM(STR(nConta,6)) )
    ProcessMessages()
    IF !ZM0->(DBSEEK( xFilial()+ZM1->ZM1_CODEVE)) .OR. ZM0->ZM0_MSBLQL = "1"
       ZM1->(RECLOCK("ZM1",.F.))
       ZM1->(DBDELETE())
       ZM1->(MSUNLOCK())
    ENDIF
    ZM1->(DBSKIP())
ENDDO

U_ITMSG("Dados gravados com sucesso",'Atenção!',_cTotReg+" regras gravadas para "+aDadosCalc[1,1],2)

RETURN

/*
===============================================================================================================================
Programa----------: GetVlrMix
Autor-------------: Alex Wallauer
Data da Criacao---: 14/05/2019
Descrição---------: Retorna total de movimentos na ZLF de determinado evento
Parametros--------: Nenhum
Retorno-----------: Valor Total do volume de leite
===============================================================================================================================*/
STATIC FUNCTION GetVlrMix()
Local cQuery := '' , _ni
LOCAL _cSetor:= ""
ZLT->(DBSETORDER(1))
ZLT->(DBSEEK(xFilial()+cFilant))
_cSetor:=ALLTRIM(ZLT->ZLT_SETOR)
IF RIGHT(_cSetor,1) = ";"
   _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )
ENDIF
_aSetor :=STRTOKARR(_cSetor,';')
_cSetor:=""
FOR _ni := 1 TO LEN(_aSetor)
    IF LEFT(_aSetor[_ni],2) = cFilant
       _cSetor+=_aSetor[_ni]+";"
    ENDIF   
NEXT              
IF RIGHT(_cSetor,1) = ";"
   _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )
ENDIF

// Obtendo movimentos na ZLF do grupo corrente                                  |
cQuery := " SELECT SUM(ZLF.ZLF_TOTAL) AS VLR "
cQuery += " FROM "+ RetSqlName("ZLF") +" ZLF "
cQuery += " WHERE D_E_L_E_T_	= ' ' "
cQuery += "  AND ZLF.ZLF_DTINI BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
cQuery += "  AND ZLF.ZLF_DTFIM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
cQuery += "  AND ZLF_SETOR IN " + FormatIn(ALLTRIM(_cSetor),";")
cQuery += "  AND ZLF.ZLF_TP_MIX = 'L' "
cQuery += "  AND ZLF.ZLF_ENTMIX = 'S' "
cQuery += "  AND ZLF.ZLF_DEBCRE = 'C' "
cQuery += "  AND EXISTS ( SELECT ZL8.ZL8_COD "
cQuery += "              FROM "+ RetSqlName("ZL8") +" ZL8 "
cQuery += "              WHERE ZL8.D_E_L_E_T_ = ' '  "
cQuery += "              AND ZL8.ZL8_FILIAL = ZLF.ZLF_FILIAL "
cQuery += "              AND ZL8.ZL8_COD    = ZLF.ZLF_EVENTO "
cQuery += "              AND ZL8.ZL8_MIX    = 'S' ) "
Return( cQuery )

/*
===============================================================================================================================
Programa----------: VolLeite(()
Autor-------------: Alex Wallauer
Data da Criacao---: 14/05/2019
Descrição---------: Retorna volume de leite (ZLD)
Parametros--------: Nenhum
Retorno-----------: Total do volume de leite
===============================================================================================================================*/
STATIC Function VolLeite()
Local _cQuery	:= '' , _ni
LOCAL _cSetor  := ""
ZLT->(DBSETORDER(1))
ZLT->(DBSEEK(xFilial()+cFilant))
_cSetor:=ALLTRIM(ZLT->ZLT_SETOR)
IF RIGHT(_cSetor,1) = ";"
   _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )
ENDIF
_aSetor :=STRTOKARR(_cSetor,';')
_cSetor:=""
FOR _ni := 1 TO LEN(_aSetor)
    IF LEFT(_aSetor[_ni],2) = cFilant
       _cSetor+=_aSetor[_ni]+";"
    ENDIF   
NEXT              
IF RIGHT(_cSetor,1) = ";"
   _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )
ENDIF

_cQuery := " SELECT 	SUM(ZLD_QTDBOM) AS VLR "
_cQuery += " FROM  "+ RETSQLNAME( 'ZLD' ) +" ZLD "
_cQuery += " WHERE ZLD_SETOR  IN " + FormatIn(ALLTRIM(_cSetor),";")
_cQuery += " AND ZLD_DTCOLE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
_cQuery += " AND ZLD.D_E_L_E_T_ = ' ' "

Return _cQuery

/*
===============================================================================================================================
Programa----------: AEST46Ren
Autor-------------: Alex Wallauer
Data da Criacao---: 14/05/2019
Descrição---------: Retorna volume de leite (ZLD)
Parametros--------: Nenhum
Retorno-----------: Total do volume de leite
===============================================================================================================================*/
STATIC Function AEST46Ren(_aRendim,aRegra)
LOCAL _nRen:=0
nValor1:=0
nValor2:=0
nValor3:=0

if (nPos:=ASCAN(_aRendim, { |R| R[1] = aRegra[1] .AND. R[2] = aRegra[2]  })) <> 0
   nValor1:=_aRendim[nPos,3]
ENDIF
IF LEN(aRegra) > 2
   IF (nPos:=ASCAN(_aRendim, { |R| R[1] = aRegra[3] .AND. R[2] = aRegra[4]  })) <> 0
      nValor2:=_aRendim[nPos,3]
   ENDIF
ENDIF
IF LEN(aRegra) > 4
   IF (nPos:=ASCAN(_aRendim, { |R| R[1] = aRegra[5] .AND. R[2] = aRegra[6]  })) <> 0
      nValor3:=_aRendim[nPos,3]
   ENDIF 
ENDIF 

_nRen:=nValor1/(nValor2+nValor3)

RETURN _nRen

/*
===============================================================================================================================
Programa----------: AEST46Val
Autor-------------: Alex Wallauer
Data da Criacao---: 14/05/2019
Descrição---------: Retorna volume de leite (ZLD)
Parametros--------: Nenhum
Retorno-----------: Total do volume de leite
===============================================================================================================================*/
STATIC Function AEST46Val()
LOCAL aRegra:=STRTRAN(ALLTRIM(M->ZM0_BASREN),"/",";")

aRegra:=STRTOKARR(aRegra,';')
IF !EMPTY(M->ZM0_PRSOPE) .AND. EMPTY(M->ZM0_OPREN) .AND. (LEN(aRegra) < 4 .OR. (!aRegra[1] $ M->ZM0_MPCONS .OR. !aRegra[3] $ M->ZM0_MPCONS))
   U_ITMSG("Campo Base Rendimento [ZM0_BASREN] preenchido incorretamente. Formato [ Produto ; Tipo de movimento / Produto ; Tipo de movimento ] ","Atenção!",;
           "Os 2 produtos desse campo tambem devem estar no campo MP Consumo [ZM0_MPCONS].",1 )
   RETURN .F.    
ENDIF

RETURN .T.
/*
===============================================================================================================================
Programa----------: AEST46Estr
Autor-------------: Alex Wallauer
Data da Criacao---: 14/05/2019
Descrição---------: Itens da explosao
Parametros--------: _aProdutos: codigos pai para explosão da estrutura
Retorno-----------: aTp_EM_IN: tabela com os itens da explosao / cProd_EN_IN: codigos dos itens da explosao
===============================================================================================================================*/
STATIC Function AEST46Estr(_aProdutos)
LOCAL E , P
LOCAL aEstrProd:={}
LOCAL _nQtde := 0
LOCAL aTp_EM_IN:={}
PRIVATE nEstru:= 0

_cTeste+="REGRA;ITEM PAI ; QTDE ; ITEM FILHO ; QTDE "+CRLF
aTp_EM_IN:={}
FOR E := 1 TO LEN(_aProdutos)
	_cCodAux:=_aProdutos[E,1]
  	_nQtde:=_aProdutos[E,2]
  	nEstru:= 0
	aEstrProd:=Estrut(AVKEY(_cCodAux,"G1_COD"),_nQtde)
	
	FOR P := 1 TO LEN(aEstrProd)

		SB1->(DBSEEK(xFILIAL()+aEstrProd[P,3]))
		IF SB1->B1_TIPO $ "EM,IN,MC"  //aEstrProd[P,1] = 1 .AND. 
         _nQtde:=aEstrProd[P,4] 
         IF (nPos:=ASCAN(aTp_EM_IN, {|S| S[1] == aEstrProd[P,3] } )) = 0
			   AADD(aTp_EM_IN,{aEstrProd[P,3],_nQtde})
            cProd_EN_IN+=aEstrProd[P,3]+";"
         ELSE
            aTp_EM_IN[nPos,2]+=_nQtde
         ENDIF   
			_cTeste += "RG: "+ZM0->ZM0_CODEVE+";"+_cCodAux+";"+STR(_aProdutos[E,2],22,7)+";"+aEstrProd[P,3]+";"+STR(_nQtde,22,7) + CRLF
		ENDIF

	NEXT
NEXT

cProd_EN_IN:=LEFT(cProd_EN_IN,LEN(cProd_EN_IN)-1)
_cTeste += cProd_EN_IN + CRLF
_cTeste += "*************************************************************************************************************************"

RETURN aTp_EM_IN

/*
===============================================================================================================================
Programa----------: AEST46BG()
Autor-------------: Alex Wallauer
Data da Criacao---: 24/05/2019
Descrição---------: Retorna SELECT GIGANTE
Parametros--------: Nenhum
Retorno-----------: Retorna SELECT GIGANTE
===============================================================================================================================*/
STATIC Function AEST46BG()
LOCAL _cQuery := " "

_cQuery+=" SELECT (NVL(INCENT.VLR,0)- ((NVL(CREDAPUR.VLR,0)+ "+STR(_nBaseCFinan,22,7)+"+ NVL(CIAP.VLR,0) + NVL(LENHA.VLR,0) + NVL(RTNCRD.VLR,0) + NVL(SIMPLN.VLR,0))* NVL(FATOR.VLR,0))) AS VLR FROM "

_cQuery+="   ( SELECT D2_FILIAL, DECODE(SUM(D2_VALICM),NULL,0,SUM(D2_VALICM)) AS VLR "
_cQuery+="            FROM "+RETSQLNAME('SD2')+" SD2 "
_cQuery+="            WHERE SD2.D_E_L_E_T_ =  ' ' AND D2_FILIAL  = '"+cFilAnt+"'  AND D2_EMISSAO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="              AND D2_CF IN ('5101', '5103', '5105', '5109', '5116', '5118', '5122', '5124', '5125', '5151', '5153', '5155', '5201', '5207', '5208', '5251', '5252', '5253', '5254', '5255', '5256', '5257', '5258', '5401', '5402', '5408', '5410', '5501', '5651', '5652', '5653', '5658', '5660', '5917', '5918', '5925', '5927', '5928', '6101', '6103', '6105', '6107', '6109', '6116', '6118', '6122', '6124', '6125', '6151', '6153', '6155', '6201', '6207', '6208', '6251', '6252', '6253', '6254', '6255', '6256', '6257', '6258', '6401', '6402', '6408', '6410', '6501', '6651', '6652', '6653', '6658', '6660', '6905', '6917', '6918', '6925') "
_cQuery+="     GROUP BY D2_FILIAL) INCENT "

_cQuery+="     FULL OUTER JOIN "

_cQuery+=" ( ( SELECT T1.D2_FILIAL AS FILIAL, ROUND(T1.VLR/(T2.VLR+ T3.VLR),4) as VLR FROM "
_cQuery+="           (SELECT D2_FILIAL, DECODE(SUM(D2_VALBRUT), null, 0, SUM(D2_VALBRUT)) AS VLR, SUM(D2_VALICM) as ICM FROM "+RETSQLNAME('SD2')+" SD2 "// SD2  
_cQuery+="                  WHERE SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL  = '"+cFilAnt+"'  AND D2_EMISSAO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="                    AND D2_CF IN ('5101', '5103', '5105', '5109', '5116', '5118', '5122', '5124', '5125', '5151', '5153', '5155', '5201', '5207', '5208', '5251', '5252', '5253', '5254', '5255', '5256', '5257', '5258', '5401', '5402', '5408', '5410', '5501', '5651', '5652', '5653', '5658', '5660', '5917', '5918', '5925', '5927', '5928', '6101', '6103', '6105', '6107', '6109', '6116', '6118', '6122', '6124', '6125', '6151', '6153', '6155', '6201', '6207', '6208', '6251', '6252', '6253', '6254', '6255', '6256', '6257', '6258', '6401', '6402', '6408', '6410', '6501', '6651', '6652', '6653', '6658', '6660', '6905', '6917', '6918', '6925') "
_cQuery+="     GROUP BY D2_FILIAL) T1 "

_cQuery+="     FULL OUTER JOIN "

_cQuery+="     (SELECT D2_FILIAL, DECODE(SUM(D2_VALBRUT), null, 0, SUM(D2_VALBRUT)) AS VLR FROM "+RETSQLNAME('SD2')+" SD2 "// SD2  
_cQuery+="             WHERE SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL  = '"+cFilAnt+"'  AND D2_EMISSAO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="               AND D2_CF NOT IN ('5112','5113','5114','5119','5120','5205','5206','5301','5302','5303','5304','5305','5306','5307','5351','5352','5353','5354','5355','5356','5357','5359','5414','5415','5451','5554','5601','5602','5603','5605','5606','5657','5663','5664','5665','5666','5901','5904','5905','5906','5907','5908','5909','5912','5915','5916','5919','5920','5921','5922','5923','5924','5926','5929','5931','5932','5933','5949','6111','6112','6113','6114','6120','6205','6206','6301','6302','6303','6304','6305','6306','6307','6351','6352','6353','6354','6355','6356','6357','6359','6414','6415','6554','6603','6657','6663','6664','6665','6666','6901','6904','6906','6907','6908','6909','6912','6914','6915','6916','6919','6920','6921','6922','6923','6924','6929','6931','6932','6933', '6949') "
_cQuery+="     GROUP BY D2_FILIAL) T2 "
_cQuery+="   ON t1.D2_FILIAL = t2.D2_FILIAL "

_cQuery+="     FULL OUTER JOIN "

_cQuery+="   (SELECT D2_FILIAL, DECODE(SUM(D2_VALBRUT), null, 0, SUM(D2_VALBRUT)) AS VLR FROM "+RETSQLNAME('SD2')+" SD2 "// SD2  
_cQuery+="             WHERE SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL  = '"+cFilAnt+"'  AND D2_EMISSAO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="               AND D2_CF IN ('5949', '6949') AND D2_VALICM > 0  "
_cQuery+="               GROUP BY D2_FILIAL) T3 "
_cQuery+="   ON T1.D2_FILIAL = T3.D2_FILIAL) FATOR  "
_cQuery+=" )  ON INCENT.D2_FILIAL = FATOR.FILIAL  "

_cQuery+="     FULL OUTER JOIN "

_cQuery+=" ( (SELECT T.D1_FILIAL, (T.VLR - NVL(D.VLR,0)) AS VLR FROM "
_cQuery+="          (SELECT D1_FILIAL, DECODE(SUM(D1_VALICM),NULL,0,SUM(D1_VALICM)) AS VLR "
_cQuery+="                  FROM "+RETSQLNAME('SD1')+" SD1 " 
_cQuery+="                  JOIN "+RETSQLNAME('SF4')+" SF4 ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES "
_cQuery+="                  WHERE   SD1.D_E_L_E_T_ = ' ' AND  SF4.D_E_L_E_T_ = ' ' "
_cQuery+="                      AND D1_FILIAL  = '"+cFilAnt+"'  AND D1_DTDIGIT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="                      AND F4_CREDICM = 'S' GROUP BY D1_FILIAL) T "

_cQuery+="     FULL OUTER JOIN "

_cQuery+="   (SELECT D1_FILIAL, SUM(D1_VALICM) AS VLR "
_cQuery+="          FROM  "+RETSQLNAME('SD1')+" SD1 "
_cQuery+="          JOIN  "+RETSQLNAME('SF4')+" SF4 ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES "
_cQuery+="          WHERE   SD1.D_E_L_E_T_ = ' ' AND  SF4.D_E_L_E_T_ = ' ' "
_cQuery+="              AND D1_FILIAL  = '"+cFilAnt+"'  AND D1_DTDIGIT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="              AND F4_CREDICM = 'S' AND F4_SITTRIB = '90' AND D1_CF in ('1101', '2101') AND D1_TIPO = 'N' GROUP BY D1_FILIAL) D "
_cQuery+="          ON D.D1_FILIAL = T.D1_FILIAL) CREDAPUR "
_cQuery+=" )  ON INCENT.D2_FILIAL = CREDAPUR.D1_FILIAL  "

_cQuery+="     FULL OUTER JOIN "

_cQuery+="  (SELECT CDH_FILIAL, DECODE(SUM(CDH_VALOR),NULL,0,SUM(CDH_VALOR))  AS VLR "
_cQuery+="          FROM "+RETSQLNAME('CDH')+" CDH "
_cQuery+="          WHERE CDH.D_E_L_E_T_ = ' ' AND CDH_FILIAL  = '"+cFilAnt+"'  AND CDH_LA = 'S' "
_cQuery+="            AND CDH_DTINI = '" + MV_PAR01 + "' AND CDH_DTFIM = '" + MV_PAR02 + "'"  //AND CDH_DTINI = '20190401' AND CDH_DTFIM = '20190430' 
_cQuery+="            AND CDH_DESC LIKE '%CIAP%' GROUP BY CDH_FILIAL) CIAP  "
_cQuery+="    ON INCENT.D2_FILIAL = CIAP.CDH_FILIAL " 

_cQuery+="     FULL OUTER JOIN "

_cQuery+="  (SELECT D1_FILIAL, DECODE(SUM(D1_VALICM),NULL,0, SUM(D1_VALICM))  AS VLR "
_cQuery+="          FROM "+RETSQLNAME('SD1')+" SD1 "
_cQuery+="          JOIN "+RETSQLNAME('SF4')+" SF4 ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES "
_cQuery+="          WHERE SD1.D_E_L_E_T_ = ' ' AND  SF4.D_E_L_E_T_ = ' '  "
_cQuery+="            AND D1_FILIAL  = '"+cFilAnt+"'  AND D1_DTDIGIT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="            AND D1_GRUPO = '0807' AND F4_CREDICM = 'N' AND D1_CF in ('1101', '2101') "
_cQuery+="   GROUP BY D1_FILIAL) LENHA "
_cQuery+="    ON INCENT.D2_FILIAL = LENHA.D1_FILIAL" 

_cQuery+="     FULL OUTER JOIN "

_cQuery+="  (SELECT D2_FILIAL, DECODE(SUM(D2_VALICM),NULL,0,SUM(D2_VALICM))  as VLR  
_cQuery+="            FROM  "+RETSQLNAME('SD2')+" SD2 "//SD2  
_cQuery+="            WHERE SD2.D_E_L_E_T_ = ' '  "
_cQuery+="              AND D2_FILIAL  = '"+cFilAnt+"'  "
_cQuery+="              AND D2_EMISSAO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="              AND (D2_CF IN ('5556','6556','5557','6557') "
_cQuery+="              OR (D2_CF IN ('6949') AND D2_CLIENTE = 'F00004' AND D2_NFORI > '         ') "
_cQuery+="              OR (D2_CF IN ('5949', '6949') AND D2_CLIENTE NOT IN ('000001', 'F00004') AND D2_UM = 'PC' AND D2_TP = 'AI' AND D2_GRUPO <> '0600'))  "
_cQuery+="   GROUP BY D2_FILIAL) RTNCRD "
_cQuery+="    ON INCENT.D2_FILIAL = RTNCRD.D2_FILIAL " 

_cQuery+="     FULL OUTER JOIN "

_cQuery+="  (SELECT D1_FILIAL, DECODE(SUM(D1_VALICM),NULL,0,SUM(D1_VALICM)) AS VLR "
_cQuery+="     FROM "+RETSQLNAME('SD1')+" SD1 "
_cQuery+="     JOIN "+RETSQLNAME('SF4')+" SF4 ON F4_FILIAL = D1_FILIAL AND F4_CODIGO = D1_TES "
_cQuery+="            WHERE SD1.D_E_L_E_T_ = ' ' AND  SF4.D_E_L_E_T_ = ' ' "
_cQuery+="              AND D1_FILIAL  = '"+cFilAnt+"'  AND D1_DTDIGIT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
_cQuery+="              AND F4_CREDICM = 'S' AND F4_SITTRIB = '90' AND D1_CF in ('1101', '2101') AND D1_TIPO = 'N' "
_cQuery+="   GROUP BY D1_FILIAL) SIMPLN "
_cQuery+="    ON INCENT.D2_FILIAL = SIMPLN.D1_FILIAL" 

RETURN  _cQuery

/*
===============================================================================================================================
Programa----------: AEST046Necess()
Autor-------------: Alex Wallauer
Data da Criacao---: 14/10/2019
Descrição---------: _aNece
Parametros--------: nQtdBase , aTab
Retorno-----------: Retorna Valor das notas
===============================================================================================================================*/
STATIC Function AEST046Necess( nQtdBase , aTab )
LOCAL I,_nMINVENDA,nPerQtde,nResto
LOCAL _aNece:={}

FOR I := 1 TO LEN(aTab)                        
	
	If aTab[I,5] == 'D'
		_nMINVENDA := Round( aTab[I,3] / aTab[I,4] , 0 )
	Else
		_nMINVENDA := Round( aTab[I,3] * aTab[I,4] , 0 )
	EndIf
	
	IF LEN(_aNece) = 0//SE Loop está na linha 0, executa:
		//ARRAY[i][1] = D3_COD
		//ARRAY[i][2] /*Resto*/ ]      = Round(PERC_PRD * QTDBASE) MOD (_nMINVENDA)
		//ARRAY[i][3] /*Necessidade*/] = Round(PERC_PRD * QTDBASE) -array[i][1]
		nPerQtde:=Round(aTab[I,2] * nQtdBase,0)
		                nResto  :=MOD(nPerQtde,_nMINVENDA)
		                AADD(_aNece,{aTab[I,1],;       //1
		                nResto,;           //2
		                nPerQtde- nResto,; //3
		                _nMINVENDA,;       //4
		                0})                //5
	ELSE//Se não, executa:
		//ARRAY[i][1] = D3_COD
		//ARRAY[i][2] /*Resto*// ]      = ( Round(PERC_PRD * QTDBASE) + array[I -1][2] ) MOD (MINVENDA * B1_CONV)
		//ARRAY[i][3]  /*Necessidade/*] =   Round(PERC_PRD * QTDBASE) + array[I -1][2] ) - array[i][2]
		nPerQtde:=Round(aTab[I,2] * nQtdBase,0)
		nResto  :=MOD( ( nPerQtde + _aNece[LEN(_aNece),2] ) , _nMINVENDA )
		AADD(_aNece,{aTab[I,1],;  //1
		             nResto,;     //2
		             ( nPerQtde + _aNece[LEN(_aNece),2] ) - nResto,;//3
		             _nMINVENDA,;//4
		             0})         //5
	ENDIF
NEXT

RETURN _aNece
/*
===============================================================================================================================
Programa----------: FCalcVlrLPI_noBenfic()
Autor-------------: Alex Wallauer
Data da Criacao---: 09/10/2019
Descrição---------: Retorna Valor das notas
Parametros--------: CodProd_Size9 , NecsLp_1UndMed , _nMINVENDA
Retorno-----------: Retorna Valor das notas
===============================================================================================================================*/
STATIC Function FCalcVlrLPI_noBenfic( CodProd_Size9 , NecsLp_1UndMed , _nMINVENDA )
LOCAL QtdAcumulada:=0
LOCAL VlrAcumulado:=0
LOCAL Tp_Cf , I
LOCAL QtdDistinct:={}
LOCAL cFListAux:= ALLTRIM(U_ITGETMV("ITAEST46_08","6151;6101;6118;6401;6402;6404"))
LOCAL _cValores:="FILIAL;COD.PRODUTO;DOCUMENTO;QUANTIDADE;VALOR;CFOP"+CRLF

For Tp_Cf := 1 To 2
	
	//	'Prioriza Transferências, depois Vendas
	If Tp_Cf = 1 
	   IF "6151" $ cFListAux
		  cFList := "6151"
	   ELSE
	      LOOP
	   ENDIF	  
	Else
	   IF "6151" $ cFListAux
	      cFList:=STRTRAN(cFListAux,"6151;","")
	      cFList:=STRTRAN(cFList,"6151","")
	   ELSE   
	      cFList:=cFListAux
	   ENDIF
	ENDIF
	
	//	'VERIFICA NECESSIDADE DE CONTINUAR: Caso chame a função com Qtd. 0 ou quando alterar de Transf. para Venda
	If NecsLp_1UndMed <= 0
		Exit
	ENDIF
	
	cQuery := " SELECT DISTINCT(D2_QTSEGUM) AS QTD  "
	cQuery += " FROM "+ RetSqlName("SD2") +" SD2 "
	cQuery += " WHERE D_E_L_E_T_	= ' ' "
	cQuery += "  AND D2_FILIAL  = '"+cFilAnt+"'  "
	cQuery += "  AND D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	cQuery += "  AND D2_CF IN " + FormatIn(ALLTRIM(CFList),";")
	cQuery += "  AND SUBSTR(D2_COD,1,9) = SUBSTR('"+CodProd_Size9+"',1,9)"
	cQuery += "  ORDER BY D2_QTSEGUM DESC "
   cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery ,"TRB" )
	
	//	'Armazena quantidades distintas
	QtdDistinct:={}
	DO WHILE TRB->(!EOF())
		AADD(QtdDistinct, TRB->QTD )
		TRB->(DBSKIP())
	ENDDO
	TRB->( DBCloseArea() )
	
	//	'Contador de registros
	NumRegProd:=LEN(QtdDistinct)
	NFsRel:=""
	For I = 1 To NumRegProd
		
		If NecsLp_1UndMed > 0   ///51.380
			
			If (NecsLp_1UndMed < QtdDistinct[I] .AND. NecsLp_1UndMed >= _nMINVENDA )
				LOOP
			ENDIF
			
			If (NecsLp_1UndMed < _nMINVENDA) 
							
				//consulta Nfs
				cQuery := " SELECT D2_FILIAL,D2_COD,D2_DOC,D2_CF"
				cQuery += "        ((D2_TOTAL/D2_QTSEGUM) * "+ALLTRIM(STR(NecsLp_1UndMed,15))+"  as VLR "//????? tem decimais
				cQuery += " FROM "+ RetSqlName("SD2") +" SD2 "
				cQuery += " WHERE D_E_L_E_T_	= ' ' "
				cQuery += "  AND D2_FILIAL  = '"+cFilAnt+"'  "
				cQuery += "  AND D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
				cQuery += "  AND D2_CF IN " + FormatIn(ALLTRIM(CFList),";")
				cQuery += "  AND SUBSTR(D2_COD,1,9) = SUBSTR('"+CodProd_Size9+"',1,9)"
				cQuery += "  AND D2_DOC NOT IN " + FormatIn(ALLTRIM(NFsRel),";")
				cQuery += "  AND ROWNUM <= 1 "
				cQuery += "  ORDER BY D2_DOC "
            cQuery := ChangeQuery(cQuery)
                MPSysOpenQuery( cQuery ,"TRB2" ) 
				
			    _cValores    += "F"+TRB2->D2_FILIAL+";"+TRB2->D2_COD+";"+TRB2->D2_DOC+";"+STR(NecsLp_1UndMed,22,7)+";"+STR(TRB2->VLR,22,7)+";"+TRB2->D2_CF+CRLF
				QtdAcumulada += NecsLp_1UndMed
				VlrAcumulado += TRB2->VLR
				NecsLp_1UndMed = 0
				TRB2->( DBCloseArea() )
				
			Else
				
				// 51.100 / 101 =  51,1
				
				N_INTEIRO:= INT( NecsLp_1UndMed / QtdDistinct[I]) //51
				N_RESTO  := MOD( NecsLp_1UndMed , QtdDistinct[I]) // ,1'Dif. Qtd em unidades, necessárias de LPi
				
				//'Select Limitando qtd de linhas conforme necessidade de N_INTEIRO
				cQuery := " SELECT D2_FILIAL,D2_COD,D2_DOC,D2_QTSEGUM,D2_TOTAL,D2_CF"
				cQuery += " FROM "+ RetSqlName("SD2") +" SD2 "
				cQuery += " WHERE D_E_L_E_T_	= ' ' "
				cQuery += "  AND D2_FILIAL  = '"+cFilAnt+"'  "
				cQuery += "  AND D2_EMISSAO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
				cQuery += "  AND D2_CF IN " + FormatIn(ALLTRIM(CFList),";")
				cQuery += "  AND SUBSTR(D2_COD,1,9) = SUBSTR('"+CodProd_Size9+"',1,9)"
				cQuery += "  AND D2_QTSEGUM = "+ALLTRIM(STR(QtdDistinct[I],15))///??? decimais
				cQuery += "  AND ROWNUM <= "+ALLTRIM(STR(N_INTEIRO))
				cQuery += "  ORDER BY D2_DOC "
            cQuery := ChangeQuery(cQuery)
                MPSysOpenQuery( cQuery ,"TRB2" ) 
				
				//'Contador de registros
				NumReg = 0
				TRB2->(DBGOTOP())				
				DO WHILE TRB2->(!EOF())
					
					If NumReg < N_INTEIRO
						
						QtdAcumulada += TRB2->D2_QTSEGUM
						VlrAcumulado += TRB2->D2_TOTAL
						If EMPTY(NFsRel)
							NFsRel:= TRB2->D2_DOC
						ELSE
							NFsRel:= NFsRel+';'+TRB2->D2_DOC //'posterior consulta
						ENDif
						_cValores+=TRB2->D2_FILIAL+";"+TRB2->D2_COD+";"+TRB2->D2_DOC+";"+STR(TRB2->D2_QTSEGUM,22,7)+";"+STR(TRB2->D2_TOTAL,22,7)+";"+TRB2->D2_CF+CRLF
						NumReg++
					Else
						Exit
					ENDIF
					
					TRB2->(DBSKIP())
					
				ENDDO
				TRB2->( DBCloseArea() )
			ENDIF
			
			If (NumReg < N_INTEIRO)
				NecsLp_1UndMed:=N_RESTO + ((N_INTEIRO - NumReg) * QtdDistinct[I])
			Else
				NecsLp_1UndMed:=N_RESTO
			ENDIF
			
		Else
			EXIT
		ENDIF
		
	Next i
	
Next Tp_Cf

RETURN VlrAcumulado
/*
  
Boa tarde!
Para tratativa em Corumbaíba referente ao Leite em pó recebido em Transferência, serão necessários os seguintes desenvolvimentos:

1)	No cadastro de regras colocar um indicativo que identifique que poderá ser executado o cálculo referente ao Leite em pó.
Exemplo de criação: campo "ZM0_DSCBNT", com descrição "Desc LP Trsf" e ao clicar F1 exibir a ajuda: 
"Indicativo para execução de tratativa para o leite em pó recebido em transferência, desconsiderando o benefício quando o parâmetro "
Desc. Benef. LP recebido em Transf.?" estiver preenchido com "Sim".

2)	Criar parâmetro com a seguinte pergunta:   "Desc. Benef. LP recebido em Transf.?"
OBS.: Padrão "Não", porém caso o parâmetro esteja preenchido como "Sim" continua os seguintes passos:

3)	Verificar a quantidade de leite em pó recebida em transferência (CFOP 2151), já descontado a quantidade vendida dessa mercadoria, 
se houver (CFOP 6102), query abaixo:

(SELECT (NVL(ENTRLP.QTD, 0) - NVL(SAIDLP.QTD, 0) ) AS NQTD 
FROM
(SELECT DECODE(SUM(D1_QUANT),NULL,0,SUM(D1_QUANT)) AS QTD 
FROM + RetSqlName("SD1")
WHERE D_E_L_E_T_ = ' ' AND D1_FILIAL IN ('01') AND D1_DTDIGIT BETWEEN '20190801' AND'20190831' AND D1_CF IN ('2151') 
AND SUBSTR(D1_COD,1,9) IN ('000200105')) ENTRLP, 
(SELECT DECODE(SUM(D2_QUANT),NULL,0,SUM(D2_QUANT)) AS QTD 
FROM + RetSqlName("SD2")
WHERE D_E_L_E_T_ = ' ' AND D2_FILIAL IN ('01') AND D2_EMISSAO BETWEEN '20190801' AND'20190831' AND D2_CF IN ('6102') 
AND SUBSTR(D2_COD,1,9) IN ('000200105')) SaidLP) 

OBS.: Ideal salvar o resultado da query em uma variável, exemplo "QtdBase".
OBS.2: Ideal manter os códigos dos produtos como parâmetros, executando 1 vez para Integral e outra para Desnatado ('000200205').
**************************************ok

//4)	Consulta quantidades produzidas de Leite em pó fracionado para cálculo de proporção da necessidade de desconto do benefício, 
já informando quantidade mínima de venda e os fatores de conversões. Query abaixo:

//Atenção: Query acima (passo 3) ou variável "QtdBase"//, 

SELECT D3_COD, 
       (RATIO_TO_REPORT(SUM(D3_QTSEGUM)) OVER () ) AS PERC_PRD, 
       B1_I_QT3UM AS MINVENDA, 
       B1_CONV,;
       B1_TIPCONV 
FROM RetSqlName("SD3") SD3 JOIN RetSqlName("SB1") SB1 ON D3_COD = B1_COD 
WHERE SD3.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' 
AND D3_FILIAL IN ('01') AND SUBSTR(D3_COD,1,7) IN ('0002001') AND D3_SEGUM = 'KG' 
AND D3_EMISSAO BETWEEN '20190801' AND '20190831' 
AND D3_ESTORNO <> 'S' AND D3_CF = 'PR0' AND D3_LOCAL = '30' 
GROUP BY D3_COD, B1_I_QT3UM, B1_CONV, B1_TIPCONV  
ORDER BY B1_I_QT3UM DESC

Obs.: Necessário criar uma relação de notas utilizadas a partir desses dados e disponibilizar ao usuário, abaixo [item 5] uma sugestão 
similar à que utilizei em VBA.

//5)	Criar um laço de repetição para cálculo da necessidade, gravando (ARRAY) produto, necessidade e resto, considerando que a ordem da 
    consulta anterior (SQL) está em ondem decrescente do campo "B1_I_QT3UM", logo vamos acumular o resto no cálculo da próxima linha, por exemplo:
//Loop ...

	If B1_TIPCONV == 'D'
		_nMINVENDA := Round( MINVENDA / B1_CONV , 2 )
	Else
		_nMINVENDA := Round( MINVENDA * B1_CONV , 2 )
	EndIf

//SE Loop está na linha 0, executa:
                ARRRAY[i][0] = D3_COD
                ARRAY[i][1 /*Resto ] = Round(PERC_PRD * QTDBASE) MOD (_nMINVENDA) 
                ARRAY[i][2  /*Necessidade] = Round(PERC_PRD * QTDBASE) -array[i][1]
                
Obs.: Lembrando de analisar o campo "B1_TIPCONV"

//Se não, executa:
                ARRRAY[i][0] = D3_COD
                ARRAY [i][1 /*Resto/ ] = ( Round(PERC_PRD * QTDBASE) + array[I -1][1] ) MOD (MINVENDA * B1_CONV) 
                ARRAY [i][2  /*Necessidade] = Round( (PERC_PRD * QTDBASE) + array[i -1][1] ) - array[i][1]

Obs.: Lembrando de analisar o campo "B1_TIPCONV"

       Fim Se.
//Fim Loop
//////// ************************************* ATE AQUI DEU

Criar banco de dados relacionando as notas que atenderam as necessidades informadas de cada produto.

a.	Verifica os CFOPs contidos nas regras com indicação que haverá o cálculo (excluindo os repetidos). //ZM0-> ZM0_DSCBNT = '1' 

b.	[s] Relaciona as quantidades contidas nesses CFOPs para posterior consulta de notas e composição de quantidade da necessidade, 
faça da forma que preferir até que totalize a necessidade. //ZM0_CFOPV" "CFOP Venda" 

c.	[s] Limita o Loop baseado na unidade de venda "MINVENDA * B1_CONV", lembrando de analisar o campo "B1_TIPCONV"

d.	Se não conseguir atender toda a quantidade necessária, a diferença deve ser somada na necessidade do próximo produto do loop.

e.	Necessário fazer um acumulador ou somar ao final da execução os valores das notas fiscais relacionadas, pois estas serão desconsideradas os valores do benefício.

f.	O banco das notas deve conter: NF, Código do produto, quantidade 1, quantidade 2, unidades de medidas, valor total, alíquota de ICMS e valor de ICMS.
Obs.: Lembrando que esse banco/relação das notas deve estar disponível ao usuário.


//6)	Toda lógica acima vai acumular o valor D2_TOTAL conforme o banco/relação de notas fiscais, qual haverá cálculos 
posteriores e o resultado será alocado na variável "aCalc[22]+=   //ZM1_ODEB", 
verificando ainda necessidade de rateio entre as regras que houveram o indicativo "ZM0_DSCBNT" preenchido.

Será necessário:
*a) Criar uma base de rateio (1º for do programa já existente), caso seja indicado mais de 1 regra.

*b) Realizar o rateio no 2º for do programa já existente) 
ex.:

IF ZM0-> ZM0_DSCBNT = '1'  //ou "Sim"
      resultado =  (SOMA(D2_TOTAL) das NOTAS * Base Rateio) * (ZM0_BENEF/100)) - ((SOMA(D2_TOTAL) das NOTAS * Base Rateio) * (ZM0_BENEF/100)) * (ZM0_CRDBNF/100)) 

      aCalc[22]+= resultado //já possui várias valores/rateios
      resultado2 += resultado  //para informar na aDadosTela
ENDIF

Informar na coluna "A" para posterior validação: 
     AADD(aDadosTela,ARRAY(LEN(aCalcTela)))
     nPos:=LEN(aDadosTela)
     aDadosTela[nPos,1]:= aCalc[01]
     aDadosTela[nPos,2]:="Valor desc. LP transf."
     aDadosTela[nPos,3]:= Transform( resultado2 ,"@E 999,999,999,999.99")


*/
