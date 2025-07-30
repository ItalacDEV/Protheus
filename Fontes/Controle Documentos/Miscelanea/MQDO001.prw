
/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"
//#INCLUDE "QDOA090.CH"

/*
===============================================================================================================================
Programa--------: MQDO001
Autor-----------: Alex Wallauer 
Data da Criacao-: 29/12/2020
===============================================================================================================================
Descri��o-------: SELECAO DE ARQUIVOS PARA GUARDAR - CHAMADO 35427
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
USER Function MQDO001() // U_MQDO001

Local oBtn1
Local oDlg
Local oArquivo
Local oCodDocto
Local oRevisao
//Local oTitulo
Local oScroll
Local oQAAMat
Local oQAANom
Local oTpCod
Local oTpDes
Local aUsrMat := QA_USUARIO()
Local lApelido:= aUsrMat[1]
Local oQAAFil
//Local cF3	  := GetNewPar("MV_QA090F3","")		//Consulta Padrao do campo Documento
//Local aButtons := {}

Private cRevisao := Space( TamSx3("QDH_RV")[1] )
Private cArquivo := Space( TamSx3("QDH_NOMDOC")[1] )
Private cCodDocto:= Space( TamSX3("QDH_DOCTO")[1] )
Private cTitulo  := Space( TamSX3("QDH_TITULO")[1] )
Private cQAAMat  := Space( TamSX3("QAA_MAT")[1] )
Private cQAANom  := Space( TamSX3("QAA_NOME")[1] )
Private cTpDes   := Space( TamSX3("QD2_DESCTP")[1] )
Private cTpCod   := Space( TamSX3("QD2_CODTP")[1] )
Private	Inclui   := .t.
Private cFilMat  := xFilial("QAA")
Private nQaConPad:= 4

If !lApelido
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
	Return .f.
Endif

IF QDOChkRmt() //Checa se o Remote e Linux
	Return .f.
Endif

DbSelectArea("QAA")
DbSetOrder(1)

DbSelectArea("QDH")
DbSetOrder(1)

DbSelectArea("QD2")
DbSetOrder(1)

Private aLista:={}
nLinha:=5
nPula:=13

DEFINE MSDIALOG oDlg TITLE "Importacao de Arquivo Documento" FROM 000,000 TO 330,595 OF oMainWnd PIXEL // "Importa‡„o de Arquivo Documento"
oScroll := TScrollBox():new(oDlg,035,003,075,293,.T.,.T.,.T.)

@ nLinha+1, 003 SAY "Nome do Documento" SIZE 060,010 COLOR CLR_HBLUE OF oScroll PIXEL //"Nome do Documento"
@ nLinha, 054 MSGET oArquivo  VAR cArquivo  PICTURE "@!" SIZE 200,007 OF oScroll PIXEL

DEFINE SBUTTON oBtn1 FROM nLinha,258 TYPE 4 ENABLE OF oScroll ACTION cArquivo := QD090VArq("*.Doc","*.Docx") 
oBtn1:cToolTip := "Abre arquivo documento (*.doc)" // "Abre arquivo documento (*.doc)"
nLinha+=nPula

//@ nLinha+1, 003 SAY "Titulo Documento" SIZE 060,007 COLOR CLR_HBLUE OF oScroll PIXEL //"T¡tulo Documento"
//@ nLinha, 054 MSGET oTitulo VAR cTitulo SIZE 231,007 OF oScroll PIXEL
//nLinha+=nPula

@ nLinha+1, 003 SAY " Digitador " COLOR CLR_HBLUE OF oScroll PIXEL //" Digitador "
@ nLinha, 054 MSGET oQAAFil VAR cFilMat F3 "SM0" SIZE 010,007 OF oScroll PIXEL VALID QA_CHKFIL(cFilMat,@cFilMat)
@ nLinha, 080 MSGET oQAAMat VAR cQAAMat F3 "QDE" PICTURE '@!' SIZE 037,007 OF oScroll PIXEL VALID QD090ValQAA(@oQAANom,cFilMat)

@ nLinha, 122 MSGET oQAANom VAR cQAANom PICTURE '@!' SIZE 163,007 OF oScroll PIXEL
oQAANom:lReadOnly:= .T.
nLinha+=nPula

@ nLinha+1, 003 SAY " Tipo de Documento" COLOR CLR_HBLUE OF oScroll PIXEL //" Tipo de Documento "
@ nLinha, 054 MSGET oTpCod VAR cTpCod F3 "QD2" PICTURE '@!' SIZE 025,007 OF oScroll PIXEL 	VALID QD090ValQD2(@oTpDes)
@ nLinha, 089 MSGET oTpDes VAR cTpDes PICTURE '@!' SIZE 116,007 OF oScroll PIXEL
oTpDes:lReadOnly:= .T.
nLinha+=nPula

@ nLinha+1, 003 SAY "Documento" SIZE 060,007 COLOR CLR_HBLUE OF oScroll PIXEL //"Documento"
@ nLinha, 054 MSGET oCodDocto VAR cCodDocto F3 "QD2" VALID QD090VAL(cCodDocto,@cRevisao,oRevisao)	SIZE 070,007 OF oScroll PIXEL WHEN .F.

@ nLinha+1, 130 SAY "Revisao" SIZE 025,007 COLOR CLR_HBLUE OF oScroll PIXEL //"Revis„o"
@ nLinha, 155 MSGET oRevisao VAR cRevisao PICTURE "999" VALID QD090VAL(cCodDocto,@cRevisao,oRevisao) SIZE 015,007 OF oScroll PIXEL  WHEN .F.


ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {||QD090GrImp(cFilMat),oQAANom:Refresh(),oTpDes:Refresh()},{||oDlg:End()}),oArquivo:SetFocus(.t.)) CENTERED

Return

/*±³Fun‡ao	 ³ QD090VArq³ Autor ³Cicero Odilio Cruz        ³ Data ³ 05/09/06 ³±±
±±³Descri‡ao ³ Valida a extencao do arquivo a ser anexado( Devido a erro na  ³±±
±±³          ³ cGetFile )                                                    ³±±
±±³Sintaxe	 ³QD090VArq()                                                    ³±±
±±³Uso		 ³QDOA090()                                                     */
STATIC Function QD090VArq(cExt,cExt2)
Local cFile := " "
//cFile := cGetFile("*.Doc|*.doc|*.Docx|*.docx",,0,,.T.,49)       aLista

cFile:=MQDOFile(.T.)+SPACE(200)

// Analiso a extensao do arquivo anexado para garantir apenas arquivos *.Doc
//If (Upper(Right(cExt,3)) != Upper(Right(Alltrim(cFile),3)) .and. Upper(Right(cExt2,4)) != Upper(Right(Alltrim(cFile),4)) )
//	 U_ITMSG("Favor informar arquivos .doc.",'Aten��o!',,3)
//	cFile:= " "
//EndIf

Return cFile

/*
Funcao:	QD090GrImp
Autor : Alex
Data  : 04/09/00 
Descricao: Grava o arquivo documento importado dentro do sistema          
*/
STATIC Function QD090GrImp(cFilMat)
Local nC             
Local nI
Local cStrTrab := ""
Local aQPath   := QDOPATH()
Local cQPath   := aQPath[1]	// Diretorio que contem os .CEL
Local aUsrMat  := QA_USUARIO()
Local cMatFil  := aUsrMat[2]
Local lCopiou  := .F.
Local cUltRev  := "" , A

Private cFileCEL := "000001"+SubStr(StrZero(Year(dDataBase),4),3,2)+".CEL"
Private bCampo   := { |nCPO| Field( nCPO ) }
Private cMatDep  := aUsrMat[4]
Private cMatCod  := aUsrMat[3]

If	Empty(cArquivo) .Or. Empty(cCodDocto) .Or. Empty(cRevisao) .Or. ;
	Empty(cQAAMat) .Or. Empty(cTpCod)//Empty(cTitulo) .Or.
	Help(" ",1,"QD090COBRI")  // Campos obrigatorios
	Return .f.
EndIf

FOR A := 1 TO LEN(aLista)

    cArquivo:=aLista[A,2]
    M->QDH_CODTP :=cTpcod
	M->QDH_FILIAL:=xFilial("QDH")//cFilAnt
	M->QDH_DOCTO :=""
	CHKSEQDOC()
    cCodDocto:=M->QDH_DOCTO
    cTitulo:=ALLTRIM(cCodDocto)+"-"+ALLTRIM(cArquivo)

    If !FreeForUse("DOC",xFilial("QDH")+cCodDocto+cRevisao)
    	aLista[A,3]:="Chave invalida: "+xFilial("QDH")+cCodDocto+cRevisao
        //Return .F.
        LOOP
    EndIf
    
    If !File( cArquivo )
    	MsgAlert( "Arquivo documento nao existe no diretorio especificado: "+cArquivo, "ATENCAO") // "Arquivo documento n„o existe no diret¢rio especificado." ### "Aten‡„o"
    	aLista[A,3]:="Arquivo documento nao existe no diretorio especificado: "+cArquivo
        LOOP
    //	Return .f.
    EndIf

    If !ChkDocto(xFilial("QDH"),cCodDocto,cRevisao)
    	aLista[A,3]:="Chave invalida: "+xFilial("QDH")+cCodDocto+cRevisao
        LOOP
    //	Return .f.
    EndIf
    
    //³verifica se existe revisao e se esta pendente  ³
    QDH->(DbSetOrder(6)) //Revisao invertida
    If QDH->(DbSeek(xFilial("QDH")+cCodDocto))  
    	cStrTrab := QDH->QDH_STATUS
    	cUltRev	 := QDH->QDH_RV
    	If cStrTrab != "L  " .Or. (cStrTrab == "L  " .And. QDH->QDH_CANCEL = 'S')
    	   aLista[A,3]:="Ja existe uma revisao Pendente para este Documento"
            LOOP
    		//Help( " ", 1, "QDA090DRVA" ) //"Ja existe uma revisao Pendente para este Documento.Não será possivel a Importação.
    		//Return .f.
    	EndIf
    	IF cUltRev > cRevisao                
    	   aLista[A,3]:="Documento ja existe, para Gerar Revisao escolha a opcao no Menu"
            LOOP
    //		Help( " ", 1, "QD050DOCEX" )  //"Documento ja existe, para Gerar Revisao escolha a opcao no Menu"
    //		Return .f.
    	Endif
    EndIf
    QDH->(DbSetOrder(1)) 

    //Posiciona Arquivos
    QAA->(DbSeek(cFilMat+cQAAMat))
    QD2->(DbSeek(xFilial("QD2")+cTpCod))
    
    nC := 1
    M->QDH_DOCTO := cCodDocto
    M->QDH_RV    := cRevisao    
    
    While File( cQPath + cFileCEL )
    	cFileCEL := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 ) + SubStr(StrZero(year(dDataBase),4),3,2)+".CEL"
    Enddo
    
    ProcessaDoc( { || QD090IpDoc(@lCopiou) } )////////

    If lCopiou
    	DbSelectArea("QDH")
    	Begin Transaction
    
    		For nI:= 1 To FCount()
    			M->&(Eval(bCampo,nI)):= FieldGet(nI)
    			lInit := .F.
    			If ExistIni(Eval(bCampo,nI))
    				lInit := .T.
    				M->&(Eval(bCampo,nI)):= InitPad(GetSx3Cache(Eval(bCampo,nI),"X3_RELACAO"))
    				If ValType(M->&(Eval(bCampo,nI))) == "C"
    					M->&(Eval(bCampo,nI)):= Padr(M->&(Eval(bCampo,nI)),GetSx3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
    				EndIf
    				If M->&(Eval(bCampo,nI)) == NIL
    					lInit := .F.
    				EndIf
    			EndIf
    			If !lInit
    				If ValType(M->&(Eval(bCampo,nI))) == "C"
    					M->&(Eval(bCampo,nI)):= Space(Len(M->&(Eval(bCampo,nI))))
    				ElseIf ValType(M->&(Eval(bCampo,nI))) == "N"
    					M->&(Eval(bCampo,nI)):= 0
    				ElseIf ValType(M->&(Eval(bCampo,nI))) == "D"
    					M->&(Eval(bCampo,nI)):= Ctod("  /  /  ", "DDMMYY")
    				ElseIf ValType(M->&(Eval(bCampo,nI))) == "L"
    					M->&(Eval(bCampo,nI)):= .F.
    				EndIf
    			EndIf
       		Next nI
    
    	If RecLock("QDH",.T.)
    		
    		For nI := 1 TO FCount()
    			FieldPut( nI, M->&( Eval( bCampo, nI ) ) )
    		Next nI
    		
    		QDH->QDH_FILIAL := xFilial("QDH")
    		QDH->QDH_DOCTO  := cCodDocto
    		QDH->QDH_RV     := cRevisao
    		QDH->QDH_REVINV := INVERTE(cRevisao) //Revisao Invertida
    		QDH->QDH_TITULO := cTitulo
    		QDH->QDH_CODTP  := QD2->QD2_CODTP
    		QDH->QDH_FILDEP := QD2->QD2_FILDEP
    		QDH->QDH_DEPTOD := QD2->QD2_DEPTO
    		QDH->QDH_DTCAD  := dDatabase
    		QDH->QDH_OBSOL  := "N"
    		QDH->QDH_CANCEL := "N"
    		QDH->QDH_STATUS := "D"
    		QDH->QDH_FILMAT := QAA->QAA_FILIAL
    		QDH->QDH_MAT    := QAA->QAA_MAT
    		QDH->QDH_DEPTOE := QAA->QAA_CC
    		QDH->QDH_HORCAD := Left(Time(),5)
    		QDH->QDH_NOMDOC := cFileCEL
    		QDH->QDH_DTOIE  :="I"
    		QDH->( MsUnlock() )
    		For nC := 1 To QDH->( FCount() )
    			cCampo      := Upper( AllTrim( QDH->( FieldName( nC ) ) ) )
    			M->&cCampo. := QDH->( FieldGet( FieldPos( cCampo ) ) )
    		Next
    	Endif
    	
    	QD050GrDst(.f.,QAA->QAA_FILIAL,QAA->QAA_CC,QAA->QAA_MAT,,QAA->QAA_TPRCBT,1,,3 )
    	
    	QD110GrLog(.T.,"Importacao de documento","U",1, cMatFil,cMatCod,QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_TPRCBT) //"Importa‡„o de documento"
    
    	End Transaction
    
    ELSE
    
    	aLista[A,3]:="Nao copiou"
        LOOP
    
    EndIf

	aLista[A,1]:=.T.

Next


MQDOFile(.F.)

//MsgInfo( "Importacao finalizada com sucesso." , "Aviso" ) 

cRevisao := "000"
cArquivo := Space( TamSx3("QDH_NOMDOC")[1] )
cCodDocto:= Space( TamSx3("QDH_DOCTO")[1] )
cTitulo  := Space( TamSx3("QDH_TITULO")[1] )
cQAAMat  := Space( TamSX3("QAA_MAT")[1] )
cTpCod   := Space( TamSX3("QD2_CODTP")[1] )
cQAANom  := Space( TamSX3("QAA_NOME")[1] )
cTpDes   := Space( TamSX3("QD2_DESCTP")[1] )

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD090IpDoc³ Autor ³Newton Rogerio Ghiraldelli³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Faz a importacao do documento atraves de OLE                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090IpDoc(ExpL1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - Verfica se copiou do Terminal para o Servidor          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function QD090IpDoc(lCopiou)

Local cFileTrm := ""
Local aQPath    := QDOPATH()
Local cQPath    := aQPath[1]
Local cQPathTrm := aQPath[3]
Local oWord
Local cMvSalvaDoc := GETMV("MV_QSAVEDC",.F.,1) // 1-Padrao Salva como DOC
Local cMvSave   := IIf( GetMV("MV_QSAVPSW",.F.,"1") == "1","CELEWIN400","" ) // "Verifica se insere senha ou nao
Local nTrm		:= 1 

Private cEdit   := Alltrim( GetMV( "MV_QDTIPED" ) )
Private cEditor := "TMsOleWord97" //ultima versão

RegProcDoc( 04 )

cFileTrm := ""
For nTrm:= Len(cArquivo) to 1 STEP -1
	If SubStr(cArquivo,nTrm,1) == "\"
		Exit
	Endif
	cFileTrm := SubStr(cArquivo,nTrm,1)+cFileTrm
Next
If At(":",cArquivo) == 0
	CpyS2T(cArquivo,cQPathTrm,.T.)
Else
	__CopyFile(cArquivo,cQPathTrm+cFileTrm)
Endif
If File(cQPathTrm+cFileTrm)
	IncProcDoc( "Criando link de comunicacao com o editor" ) // "Criando link de comunica‡„o com o editor"
	oWord:=OLE_CreateLink( cEditor )
	IncProcDoc( "Abrindo documento a ser importado" ) // "Abrindo documento a ser importado"
	OLE_OpenFile( oWord, cQPathTrm+cFileTrm, .f., cMvSave, cMvSave )
	IncProcDoc(  "Salvando no formato Quality" ) // "Salvando no formato Quality"
	If cMvSalvaDoc == 1
		OLE_SaveAsFile( oWord, ( cQPathTrm + cFileCel ), cMvSave, cMvSave, .f., oleWdFormatDocument )
	Else
		OLE_SaveAsFile( oWord, ( cQPathTrm + cFileCel ), cMvSave, cMvSave, .f., oleWdFormatRTF )
	Endif
	OLE_SetProperty( oWord, oleWdPrintBack, .f. )
	OLE_Closefile( oWord )
	IncProcDoc( "Fechando links de comunicacao" ) // "Fechando links de comunica‡„o"
	OLE_CloseLink( oWord )
	
	If CpyT2S(cQPathTrm+cFileCel,cQPath,.T.)
		lCopiou:= .T.
	Else
		lCopiou:= .F.
	EndIf			

	If File(cQPathTrm+cFileCel)
		FErase(cQPathTrm+cFileCel)
	Endif
	If File(cQPathTrm+cFileTrm)
		FErase(cQPathTrm+cFileTrm)
	Endif
Endif


Return nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD090ValQD2³ Autor ³Eduardo de Souza         ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica Tipo de Documento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090ValQD2()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function QD090ValQD2(oTpDes)

Local lRet:= .t.

If !Empty(cTpCod)
	cTpDes:= QDXFNANTPD(cTpcod)
	If Empty(cTpDes)
		Help(" ",1,"QD050TDNE") // Tipo de Documento nao existe
		lRet:= .f.
	Else
		oTpDes:Refresh()
	EndIf
Else
	cTpDes:= " "
	oTpDes:Refresh()
EndIf

M->QDH_CODTP:=cTpcod
M->QDH_FILIAL:=xFilial("QDH")//cFilAnt
M->QDH_DOCTO:=""
M->QDH_RV:=""
CHKSEQDOC()
cCodDocto:=M->QDH_DOCTO
//cTitulo:=cCodDocto+"-"+cArquivo
cRevisao:=M->QDH_RV

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD090ValQAA³ Autor ³Eduardo de Souza         ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica Funcionario                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090ValQAA()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function QD090ValQAA(oQAANom,cFilMat)

Local lRet:= .t.

If !Empty(cQAAMat)
	cQAANom:= QA_NUSR(cFilMat,cQAAMat)
	If Empty(cQAANom)
		Help(" ",1,"QD050FNE") // Funcionario nao Existe
		lRet:= .f.
	Else
		oQAANom:Refresh()
	EndIf
Else
	cQAANom:= " "
	oQAANom:Refresh()
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD090VAL  ³ Autor ³Cicero Cruz              ³ Data ³ 19/02/08 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o codigo do docuemnto esta  na  memória           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA090()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function QD090VAL(cCodDocto, cRevisao, oRevisao)	
// Iif(!FreeForUse("DOC",xFilial("QDH")+cCodDocto),.F.,.T.)
Local lRet:= .T.
Local lTemLetra := .F.
Local nX := 0
Local cRev := AllTrim(cRevisao)

If !Empty(cRev) 
    nX := 1
	While nX <= Len(cRev)
		If !IsDigit(Substr(cRev,nX,1))
			lTemLetra := .T.
			Exit
		EndIf
		nX ++			
	EndDo
	If !lTemLetra
		cRevisao := STRZERO(Val(cRev),TamSX3("QDH_RV")[1],0)
		oRevisao:Refresh()                                      
	EndIf
	If !FreeForUse("DOC",xFilial("QDH")+cCodDocto+cRevisao)
		lRet := .F.
	EndIf

	If lRet
		lRet := QDXVLREV(cRevisao)
	EndIf
EndIf

Return lRet


STATIC Function MQDOFile(lMostra) // U_ACDO001

Local _lOK   := .F.
Local _nLinha:=05
Local _nPula :=20
Local _nCol1 :=10
Local _nCol2 :=_nCol1+60
//Local _nCol3 :=_nCol1+150
//Local _nTam	 :=55
//Local nLarg	 :=_nTam
Local nAltu	 :=120
Local _cTit	 :="SELECAO DE ARQUIVOS PARA GUARDAR"
Local _bValid := {|| NaoVazio(aLista) }
Local _bOK    := {|| (If(EVAL(_bValid) ,(_lOK:=.T.,_oDlg:End()),))  }

Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
PRIVATE cPath0 :=SPACE(400)
PRIVATE cPath1 :=SPACE(400)
PRIVATE cPath2 :=SPACE(400)
PRIVATE cPath  :=SPACE(400)
IF lMostra
   aLista := {{.F.,"",""}}
ENDIF
DO While .T.

   _lOK   := .F.
   _nLinha := _nLinSalva := 05

   Define MSDialog _oDlg Title _cTit From 000,000 To 420,800 Pixel
   
	@ _nLinha, _nCol1 Button "Selecione o Diretorio:" Size 75,12 PIXEL OF _oDlg ACTION(cPath0:=cPath:=cGetFile("","SELECIONE O DIRETORIO",,,.F.,GETF_LOCALHARD + GETF_RETDIRECTORY) , AGLTLista("VARIOS")) when lMostra
	@ _nLinha, _nCol2+20 MSGet _oTeor VAR cPath0  Picture "@!" Size 300,11 OF _oDlg Pixel WHEN .F.
	_nLinha+=_nPula
/*	
	@ _nLinha+2, _nCol1    Say "Selecione Arquivos: " Pixel
	@ _nLinha  , _nCol2    Button "..." Size 12,12 PIXEL OF _oDlg ACTION(cPath1:=cPath:=cGetFile("","SELECIONE 1 OU MAIS ARQUIVOS",,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_MULTISELECT) , AGLTLista("VARIOS2"))
	@ _nLinha  , _nCol2+20 MSGet _oTeor VAR cPath1  Picture "@!" Size 300,11 OF _oDlg Pixel WHEN .F.
	_nLinha+=_nPula

	@ _nLinha, _nCol1 Say "Selecione 1 Arquivo: " Pixel
	@ _nLinha, _nCol2    Button "..." Size 12,12 PIXEL OF _oDlg ACTION(cPath2:=cPath:=cGetFile("","SELECIONE 1 ARQUIVO",,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE))
	@ _nLinha, _nCol2+20 MSGet _oTeor VAR cPath2  Picture "@!" Size 300,11 OF _oDlg Pixel WHEN .F.
	_nLinha+=_nPula*/
   _nLinSalva := _nLinha

//  @ _nLinha, _nCol1    Button " + " Size 12,12 Action (AGLTLista("ADD")) OF _oDlg Pixel
    IF lMostra
	   @ _nLinha, _nCol1 Say "Selecione 1 Arquivo: " Pixel
	   DEFINE SBUTTON oBtn2 FROM _nLinha,_nCol1 TYPE 3 ENABLE OF _oDlg ACTION (AGLTLista("DEL"))
       oBtn2:cToolTip := "Retira o documento selecionado da lista"
//     @ _nLinha, _nCol1 Button "RETIRA" Size 45,15 Action (AGLTLista("DEL")) OF _oDlg Pixel 
       _nLinha+=_nPula
    ENDIF

    oList:=TWBrowse():New(_nLinSalva,_nCol2,320,nAltu,,{"","DOCUMENTO","Observacao"},{10,100,10},_oDlg,,,,,,,,,,,,,"ARRAY",.T.)
    oList:SetArray(aLista)					
    oList:bLine:={|| {if(aLista[oList:nAt,1] = .F.,oVermelho,oVerde) , TRANS(aLista[oList:nAt,2],"@!"),aLista[oList:nAt,3]  } }//
    IF lMostra
        @_nLinha,_nCol1 Button "CONFIRMA" Size 45,15 Action (EVAL(_bOK)) OF _oDlg Pixel
    	_nLinha+=_nPula
    ENDIF
    @_nLinha,_nCol1 Button "SAIR"    Size 45,15 Action (_lOK:=.F.,_oDlg:End()) OF _oDlg Pixel
					
   Activate MSDialog _oDlg Centered

   If !_lOK .AND. lMostra
      cPath0:=SPACE(100)
   EndIf

   Exit

EndDo

Return cPath0


/*
===============================================================================================================================
Programa--------: AGLTLista()
Autor-----------: Alex Wallauer 
Data da Criacao-: 29/12/2020
===============================================================================================================================
Descri��o-------: add aLista
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AGLTLista(cManut)

If cManut=="DEL"
   If oList:nAt > Len(aLista) 
     //FAZ NADA
   ELSEIf Len(aLista) > 1 
	  aDel(aLista,oList:nAt)
	  aSize(aLista,Len(aLista)-1)      
     If oList:nAt > Len(aLista) 
        oList:nAt:=Len(aLista)
     ENDIF   
   Else
      aLista[1,2]:=""
   EndIf
ELSEIf cManut=="VARIOS2"

    if EMPTY(cPath)
       U_ITMSG("Favor selecionar 1 ou mais arquivos.",'Aten��o!',,3)
       Return .F.
    EndIf            
    //Funcao utilizada para pegar os arquivos .TXT no diretorio especificado pelo usuario
    MontaLista(cManut)   
ELSEIf cManut=="VARIOS"

    if EMPTY(cPath)
       U_ITMSG("Favor informar o caminho onde se encontram os arquivos.",'Aten��o!',,3)
       Return .F.
    EndIf            
    //Funcao utilizada para pegar os arquivos .TXT no diretorio especificado pelo usuario
    MontaLista(cManut) 
Else
   If Empty(aLista[1,2])
      aLista [1,2]:=cPath2
   ElseIf !Empty(cPath2)
      AADD(aLista,{.F.,cPath2," "})
   EndIf
EndIf

oList:Refresh()
oList:SetFocus()

Return .T.

Static Function MontaLista(cManut)

Local aArqOri   := {}
Local nXi		:= 0

IF cManut=="VARIOS2"
   aArqOri := StrToKArr( ALLTRIM(cPath1), "|" )
   IF EMPTY(aArqOri)
      Return 
   ENDIF
   _nIni:=1
   If Empty(aLista[1,1])
      aLista [1,2]:=aArqOri[1]
      _nIni:=2
   ENDIF
    for nXi := _nIni to Len(aArqOri)         
         aadd(aLista, { .F.,ALLTRIM(aArqOri[nXi])," " } ) 
    next nXi

ELSEIF cManut=="VARIOS"
   aArqOri := directory(cPath + "*.doc*")  
   IF EMPTY(aArqOri)
      Return 
   ENDIF
   _nIni:=1
   If Empty(aLista[1,2])
      aLista [1,2]:=ALLTRIM(cPath)+ALLTRIM(aArqOri[1,1])
      _nIni:=2
   ENDIF
    for nXi := _nIni to Len(aArqOri)         
         aadd(aLista, {  .F., ALLTRIM(cPath)+ALLTRIM(aArqOri[nXi,1])," " } ) 
    next nXi
EndIf
oList:Refresh()

Return
