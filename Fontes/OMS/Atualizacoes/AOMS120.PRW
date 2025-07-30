/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
================================================================================================================================
*/
//==============================================================================================================================
// Definicoes de Includes da Rotina.
//==============================================================================================================================
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE ENTER CHR(13)+CHR(10)
/*
=================================================================================================================================
Programa----------: U_AOMS120()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/12/2020
==================================================================================================================================
Descrição---------: Tabela de Precos para exibicao no portal. CHAMADO 34937
==================================================================================================================================
Parametros--------: Nenhum
==================================================================================================================================
*/
*====================================================*
User Function AOMS120()
*====================================================*
Local _cAlias := "DA0"
Local _aCores := {{ "DA0_ATIVO <> '1' ", "BR_VERMELHO" },;
					   { "DA0_ATIVO == '1'" , "BR_VERDE"   }}  

Private cCadastro:= "Tabela de Precos para exibicao no portal"
Private aRotina		:= {}                

AADD(aRotina,{"Pesquisar"	       ,"AxPesqui"   ,0,1}) // 1
aAdd(aRotina,{"Visualizar"        ,"U_AOMS120M" ,0,2}) // 2
//aAdd(aRotina,{"Incluir"         ,"U_AOMS120M" ,0,3})
aAdd(aRotina,{"Inclui / Altera"   ,"U_AOMS120M" ,0,4}) // 3
aAdd(aRotina,{"Excluir"           ,"U_AOMS120M" ,0,5}) // 4
//aAdd(aRotina,{"Alteracao em Massa","U_AOMSMASSA",0,4})
aAdd(aRotina,{"Legenda"           ,"U_AOMSLEGE" ,0,7}) 

dbSelectArea(_cAlias)
dbSetOrder(1)


// owse(,,,,cAli>  ,<aFixe, <cCpo>, <nPar>, <cCorFun>, <nClickDef>, <aColors>, <cTopFun>, <cBotFun>, <nPar14>, <bInitBloc>, <lNoMnuFilter>, <lSeeAll>, <lChgAll>, <cExprFilTop>, <nInterval>, <uPar22>, <uPar23> )
mBrowse(,,,,_cAlias,      ,       ,       ,          ,            , _aCores )

Return


/*
===============================================================================================================================
Programa--------: AOMS120M
Autor-----------: Alex Wallauer
Data da Criacao-: 10/12/2020
==================================================================================================================================
Descrição-------: Tabela de Precos para exibicao no portal. MANUTENÇÃO
==================================================================================================================================
Parametros------: cAlias,nReg,_nOpcx
==================================================================================================================================
*/
User Function AOMS120M(cAlias,nReg,_nOpcx)
Local _aObjects, _aPosObj, _aInfo, _oDlgEnch ,_nni, _nnj
Local _aSizeAut := MsAdvSize(.T.)
Local _cTitulo  :=cCadastro
Local _bOk      := {|| If(AOMS120Grv(_nOpcx),(_lRet := .T., _oDlgEnch:End()),)}
Local _bCancel  := {|| _lRet := .F., _oDlgEnch:End()}
Local bCampo    := {|nCPO| Field(nCPO) }

ZZL->(DBSETORDER(3)) //ZZL_FILIAL + ZZL_CODUSU

IF !ZZL->(DBSEEK(xFilial("ZZL") + __cUserId)) 

	U_ITMSG("O usuário: " + cUserName + " não possui permissão para executar esta ação neste cadastro.",;
		    "Usuário Sem Acesso",;
		    "Verificar com a área responsavel a possibilidade de habilitar o seu usuário.",1)

	RETURN .F.	    

ELSEIF (ZZL->(FIELDPOS("ZZL_TABPRD")) <> 0 .AND. !DA0->DA0_CODTAB $ ZZL->ZZL_TABPRD) .AND. ALLTRIM(ZZL->ZZL_TABPRD) <> "*"

	U_ITMSG("O usuário: " + cUserName + " não possui permissão para executar esta ação nessa tabela.",;
		    "Usuário Sem Acesso",;
		    "Verificar com a área responsavel a possibilidade de habilitar o seu usuário a mais tabelas alem dessas: "+ ZZL->ZZL_TABPRD,1)

	RETURN .F.	    

ELSEIF (ZZL->(FIELDPOS("ZZL_TABPRD")) = 0 .AND. !DA0->DA0_CODTAB $ '100/101/102/103/104/105')

	U_ITMSG("O usuário: " + cUserName + " não possui permissão para executar esta ação nessa tabela.",;
		    "Usuário Sem Acesso",;
		    "Verificar com a área responsavel a possibilidade de habilitar o seu usuário a mais tabelas alem dessas: '100/101/102/103/104/105'",1)

	RETURN .F.   

ENDIF

Private aHeader:= {}
Private aCols  := {}       
Private aTELA  := {} // Variáveis que serão atualizadas pela Enchoice
Private aGETS  := {} // e utilizadas pela função OBRIGATORIO()
Private _lRet  := .F.

DbSelectArea("DA0")//INICIA VARIAVIES DA CAPA
For _nni := 1 TO FCount()
	M->&(EVAL(bCampo,_nni)) := FieldGet(_nni)
Next 


DbSelectArea("ZDA")//INICIA VARIAVIES DOS ITENS
For _nni := 1 TO FCount()
	M->&(EVAL(bCampo,_nni)) := CriaVar(EVAL(bCampo,_nni),.F.)
Next 


//==============================================================================================================
// Montagem do aCols
//==============================================================================================================
//FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,cQuery, bMountFile, lInclui )
//nOpcx			- Opcao (inclusao, exclusao, etc).
//cAlias		- Alias da tabela referente aos itens
//nOrder		- Ordem do SINDEX
//cSeekKey		- Chave de pesquisa
//bSeekWhile	- Loop na tabela cAlias
//uSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar o registro)
//aNoFields	    - Array com nome dos campos que serao excluidos na montagem do aHeader
//aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader
//lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario
//cQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera parametros cSeekKey e bSeekWhiele)
//bMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)
//lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco
//aHeaderAux	-
//aColsAux		-
//bAfterCols	- Bloco executado apos inclusao de cada linha no aCols
//bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols
//bAfterHeader  -
//cAliasQry   	- Alias para a Query
//==============================================================================================================
M->ZDA_CODTAB:=DA0->DA0_CODTAB//Inicia Branco por causa do X3_RELACAO
_lCntrlDescIni:=.T.//Controla de qual campo pega a descrição do item se data tabela ZDA (.T.) ou memoria (.F.)
cSeek  := xFilial("ZDA")+DA0->DA0_CODTAB
lTemItens:=ZDA->(DBSEEK(cSeek))
IF !lTemItens
   
   IF _nOpcx # 3//Imclui/Altera
      U_ITMSG("SEM DADOS. CLIQUE NO BOTAO INCLUI/ALTERA","ATENCAO",,3)
      RETURN .F.
   ENDIF

    nOpc:=3
    FillGetDados(nOpc,"ZDA",1,/*cSeek*/,/*bWhile*/,,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T.,/*aHeaderAux*/,/*aColsAux*/,,/*bBeforeCols*/,/*bAfterHeader*/,)
    
    IF U_ITMSG("Nao há dados do Portal para essa tabela, deseja carregar todos os Produtos?",'ATENCAO!',"",3,2,2)
       aCols:={}
       DbSelectArea("ZDA")
       DA1->(DBSETORDER(1))
	    DA1->(DbSeek(DA0->DA0_FILIAL+DA0->DA0_CODTAB))
	    DO WHILE DA1->(!EOF()) .AND. DA1->DA1_FILIAL+DA1->DA1_CODTAB == DA0->DA0_FILIAL+DA0->DA0_CODTAB
       //DA1 TIRA INATIVO OS PRECO ZERADOS
          IF DA1->DA1_ATIVO <> "2" 
           
             _lDel := DA1->DA1_PRCVEN = 0 .OR.;
                      DA1->DA1_I_PMFE = 0 .OR.;
                      DA1->DA1_I_PRCA = 0 .OR.;
                      DA1->DA1_I_PRFE = 0 .OR.;
                      DA1->DA1_I_PMFR = 0 

	    	    AADD(aCols,{ DA1->DA1_CODPRO,;
                          POSICIONE("SB1",1,XFILIAL("SB1")+DA1->DA1_CODPRO,"B1_DESC"),;
                          DA1->DA1_PRCVEN,;
                          DA1->DA1_I_PMFE,;
                          DA1->DA1_I_PRCA,;
                          DA1->DA1_I_PRFE,;
                          DA1->DA1_I_PMFR,;
                          DA1->DA1_I_PRCA,;
                          "2",_lDel})
          ENDIF

	    	 DA1->(DBSKIP())
	    ENDDO
    ENDIF
ELSE    
    DbSelectArea("ZDA")//INICIA VARIAVIES DOS ITENS
    bWhile := {|| ZDA_FILIAL+ZDA_CODTAB }
    nOpc:=4
    FillGetDados(nOpc,"ZDA",1,cSeek,bWhile)
ENDIF    
_lCntrlDescIni:=.F.//Controla de qual campo pega a descrição do item se data tabela ZDA (.T.) ou memoria (.F.)
nOpc:=_nOpcx

//==============================================================================================================
// Montagem do aHeader na mão para Nao aparecer os campos extras criados pela função FillGetDados
aHeader:= {}                   // cAlias , lVirtual 
_aZDA := FWSX3Util():GetAllFields( "ZDA" , .T.     )
FOR _NNJ := 1 TO LEN(_aZDA)
    _cUsado:=Getsx3cache(_aZDA[_NNJ],"X3_USADO")
    If X3USO(_cUsado)
	    AADD( aHeader, {  Getsx3cache(_aZDA[_NNJ],"X3_TITULO")  ,;
	                      Getsx3cache(_aZDA[_NNJ],"X3_CAMPO")   ,;
                      	 Getsx3cache(_aZDA[_NNJ],"X3_PICTURE") ,;
	                      Getsx3cache(_aZDA[_NNJ],"X3_TAMANHO") ,;
	                      Getsx3cache(_aZDA[_NNJ],"X3_DECIMAL") ,;
	                      Getsx3cache(_aZDA[_NNJ],"X3_VALID")   ,;
	                      Getsx3cache(_aZDA[_NNJ],"X3_USADO")   ,;
	                      Getsx3cache(_aZDA[_NNJ],"X3_TIPO")	   ,;
	                      Getsx3cache(_aZDA[_NNJ],"X3_ARQUIVO") ,;
                         Getsx3cache(_aZDA[_NNJ],"X3_CONTEXT") })
    ENDIF                      
Next
//==============================================================================================================

// Tela de Manutenção
  _aObjects:= {}
AAdd( _aObjects, { 100, 050, .T., .T. } )
AAdd( _aObjects, { 100, 100, .T., .T. } )
_aInfo   := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 }
_aPosObj := MsObjSize( _aInfo, _aObjects, .T. )
_lDeleta :=(nOpc = 3) //.or. (nOpc = 4))
_aCamposCapa:={}

DO WHILE .T.
   
   Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel
      
   EnChoice( "DA0" ,nReg, 2, , , ,_aCamposCapa , _aPosObj[1], , 3 )
            
	//        MsGetDados(): New( < nTop>        , < nLeft>    , < nBottom>     , < nRight>,< nOpc>,[ cLinhaOk]     , [ cTudoOk],[ cIniCpos],[ lDeleta],[ aAlter]  , [ nFreeze], [ lEmpty], [ nMax], [ cFieldOk], [ cSuperDel], [ uPar], [ cDelOk], [ oWnd], [ lUseFreeze], [ cTela] )
   _oGetDados := MsGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], nOpc, /*"U_LINHAOK"*/,           ,           ,  _lDeleta, /*aAlter*/,           , .F.      ,        , /*FIELDOK*/, /*SUPERDEL*/,        , /*DELOK*/, _oDlgEnch)
   
   Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel) 

   IF _lRet .OR. !_lDeleta .OR. U_ITMSG("CONFIRMA SAIR?",'ATENCAO!',"TODAS AS ALTERACOES SERAO PERDIDAS",3,2,2)
      EXIT
   ENDIF

ENDDO

Return 

/*
===============================================================================================================================
Programa--------: AOMS120Grv()
Autor-----------: Alex Wallauer
Data da Criacao-: 10/12/2020
==================================================================================================================================
Descrição-------:  Tabela de Precos para exibicao no portal. GRAVAÇÃO
==================================================================================================================================
Parametros------: cAlias,nReg,_nOpcx
==================================================================================================================================
*/
STATIC Function AOMS120Grv(_nOpcx)
LOCAL nConIten  ,nConCmp
LOCAL cAliasItm:="ZDA"
LOCAL _nPos1:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_CODPRO"} )
LOCAL _nPos2:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PRCVEN"} )
LOCAL _nPos3:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMINFE"} )
LOCAL _nPos4:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMAXFE"} )
LOCAL _nPos5:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PRCFRA"} )
LOCAL _nPos6:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMINFR"} )
LOCAL _nPos7:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMAXFR"} )
LOCAL _nPos8:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_MSBLQL"} )
LOCAL lTudoOK:=.F.
LOCAL aProd  :={}

ZDA->(DBSETORDER(1))

IF _nOpcx = 2//VISUALIZAR
   RETURN .T.
ELSEIF _nOpcx = 4 //EXCLUIR
   IF !U_ITMSG("CONFIRMA A EXCLUSAO DE TODOS OS PRODUTOS?",'ATENCAO!',"",3,2,2)
      RETURN .F.
   ENDIF
   BEGIN TRANSACTION
   For nConIten := 1 to Len(aCols)
       IF ZDA->(DBSEEK(xFilial("ZDA")+M->DA0_CODTAB+aCols[nConIten][_nPos1] ))
	      ZDA->(RecLock("ZDA",.F.))
	      ZDA->(DBDELETE())
	   ENDIF   
   Next 
   END TRANSACTION
   U_ITMSG("DADOS EXCUIDOS COM SUCESSO","ATENCAO",,2)
   RETURN .T.
ENDIF

IF !U_ITMSG("CONFIRMA  A GRAVAÇÃO?",'ATENCAO!',"",3,2,2)
   RETURN .F.
ENDIF

For nConIten := 1 to Len(aCols)
	If aCols[nConIten][LEN(aCols[nConIten])]//DELETADOS
      LOOP
   ENDIF	    
	IF  !EMPTY(aCols[nConIten][_nPos1]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos2]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos3]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos4]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos5]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos6]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos7]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos8])
        
       IF ASCAN(aProd,aCols[nConIten][_nPos1]) = 0
	       AADD(aProd,aCols[nConIten][_nPos1])
	    ELSE   
          lTudoOK:=.F.
	       U_ITMSG("Produto: "+aCols[nConIten][_nPos1]+" Repetido.","ATENCAO",;
	               "Apague ou Altere o codigo do produto da linha: "+ALLTRIM(STR(nConIten)),1)
	       EXIT
	    ENDIF   
        
        lTudoOK:=.T.  
        
    ELSE
        lTudoOK:=.F.
	     U_ITMSG("Produto: "+aCols[nConIten][_nPos1]+" com Preco zerado.","ATENCAO",;
	             "Apague ou Altere o codigo do produto da linha: "+ALLTRIM(STR(nConIten)),1)
        EXIT
    ENDIF    
NEXT

If !lTudoOK
   n:=nConIten
	//U_ITMSG("É necessário informar Produtos antes da gravação.","ATENCAO",;
	//        "Insira produtos validos, Nao repetidos e preencha todos os campos obrigatorios da linha",1)
	RETURN .F.
EndIf

BEGIN TRANSACTION

// Gravacao dos Itens
DBSELECTAREA("ZDA")
For nConIten := 1 to Len(aCols)
	
	// Valida se o registro nao esta deletado
	If !aCols[nConIten][LEN(aCols[nConIten])]//DELETADOS

      IF ZDA->(DBSEEK(xFilial("ZDA")+M->DA0_CODTAB+aCols[nConIten][_nPos1] ))
		   ZDA->(RecLock("ZDA",.F.))
		ELSE
		   ZDA->(RecLock("ZDA",.T.))
		ENDIF   
		For nConCmp := 1 to Len(aHeader)
			If (aHeader[nConCmp,10] <> "V")
				FieldPut(FieldPos(aHeader[nConCmp,2]), aCols[nConIten, nConCmp])
			EndIf
		Next 
		(cAliasItm)->ZDA_FILIAL := xFilial("ZDA")
		(cAliasItm)->ZDA_CODTAB := M->DA0_CODTAB	
	   (cAliasItm)->(MsUnlock())
    ELSE
      IF ZDA->(DBSEEK(xFilial("ZDA")+M->ZDA_CODTAB+aCols[nConIten][_nPos1] ))
	      ZDA->(RecLock("ZDA",.F.))
	      ZDA->(DBDELETE())
	   ENDIF   
	EndIf

Next 

END TRANSACTION

U_ITMSG("DADOS GRAVADOS COM SUCESSO","ATENCAO",,2)

RETURN .T.
/*
=================================================================================================================================
Programa----------: U_AOMSMASSA()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/12/2020
==================================================================================================================================
Descrição---------: Alteraçao em massa
==================================================================================================================================
Parametros--------: Nenhum
==================================================================================================================================

User Function AOMSMASSA()

U_ITMSG("EM ANALISE PARA DESENVOLVIMENTO",'ATENCAO!',"ME PASSA OS FILTROS CERTINHO QUE JÁ TENHO UMA IDEIA",1)

RETURN .T.
/*
=================================================================================================================================
Programa----------: AOMSLEGE
Autor-------------: Alex Wallauer
Data da Criacao---: 10/12/2020
==================================================================================================================================
Descrição---------: Cadastro de Reposição automática de estoque LEGENDA
==================================================================================================================================
Parametros--------: Nenhum
==================================================================================================================================
*/
User Function AOMSLEGE()
   
Local _aLegenda := {{ "BR_VERMELHO","Bloqueado" },;
                 	  { "BR_VERDE"   ,"Ativo"  } }
                 
BRWLEGENDA(cCadastro, "Legenda", _aLegenda )
   
Return 
/*
=================================================================================================================================
Programa----------: U_AOMS120Val()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/12/2020
==================================================================================================================================
Descrição---------: Validação de todos os campos
==================================================================================================================================
Parametros--------: Nenhum
==================================================================================================================================
*/
User Function AOMS120Val(_lValid)//U_AOMS120Val()
Local _cCampo	:= UPPER(ALLTRIM(ReadVar()))
LOCAL _nPos1:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_CODPRO"} )
LOCAL _nPos2:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PRCVEN"} )//
LOCAL _nPos3:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMINFE"} )
LOCAL _nPos4:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMAXFE"} )
LOCAL _nPos5:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PRCFRA"} )//
LOCAL _nPos6:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMINFR"} )
LOCAL _nPos7:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "ZDA_PMAXFR"} )

DEFAULT _lValid := .T.

IF !_lValid
   IF _lCntrlDescIni //Controla de qual campo pega a descrição do item se data tabela Z20 (.T.) ou memoria (.F.)
      IF !Inclui
         RETURN ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+ZDA->ZDA_CODPRO,"B1_DESC"))
      ENDIF
   ENDIF   
   RETURN " "
ENDIF   
/*
IF "ZDA_CODTAB" $ _cCampo

   IF !DA1->(DBSEEK(xFilial("DA1")+M->ZDA_CODTAB)) .OR. !DA0->(DBSEEK(xFilial("DA0")+M->ZDA_CODTAB)) .OR. DA0->DA0_ATIVO <>'1'
      U_ITMSG("A tabela deve existir na tabela de Precos oficial e ATIVA",'ATENCAO!',"",1)
      RETURN .F.
   ENDIF*/
IF "ZDA_CODPRO" $ _cCampo .AND. !EMPTY(M->ZDA_CODPRO)

   IF !DA1->(DBSEEK(xFilial("DA1")+M->DA0_CODTAB+M->ZDA_CODPRO)) .OR. DA1->DA1_ATIVO <> '1'
      U_ITMSG("O produto inserido na tabela deve existir na tabela de Precos oficial e ATIVO",'ATENCAO!',"",1)
      RETURN .F.
   ENDIF
// IF ZDA->(DBSEEK(xFilial()+M->DA0_CODTAB+M->ZDA_CODPRO)) 
//    U_ITMSG("Tabela + Produto já cadastrados",'ATENCAO!',"",1)
//    RETURN .F.
// ENDIF

   DA1->(dbSetOrder(1))
   DA1->(DBSEEK(xFilial("DA1")+M->DA0_CODTAB+M->ZDA_CODPRO))

   M->ZDA_PRCVEN   := DA1->DA1_PRCVEN
   M->ZDA_PMINFE   := DA1->DA1_I_PMFE
   M->ZDA_PMAXFE   := DA1->DA1_I_PRCA
   M->ZDA_PRCFRA   := DA1->DA1_I_PRFE
   M->ZDA_PMINFR   := DA1->DA1_I_PMFR
   M->ZDA_PMAXFR   := DA1->DA1_I_PRCA
	aCols[n][_nPos2]:= M->ZDA_PRCVEN 
	aCols[n][_nPos3]:= M->ZDA_PMINFE 
	aCols[n][_nPos4]:= M->ZDA_PMAXFE 
	aCols[n][_nPos5]:= M->ZDA_PRCFRA 
	aCols[n][_nPos6]:= M->ZDA_PMINFR 
	aCols[n][_nPos7]:= M->ZDA_PMAXFR 
   RETURN .T.
ENDIF

DA1->(dbSetOrder(1))
DA1->(DBSEEK(xFilial("DA1")+M->DA0_CODTAB+aCols[n][_nPos1]))

IF "ZDA_PRCVEN" $ _cCampo//ZDA_PRCVEN: Deve ser maior que zero e Nao pode ser menor que o campo DA1_PRCVEN

   IF M->ZDA_PRCVEN <= 0 .OR. M->ZDA_PRCVEN < DA1->DA1_PRCVEN .OR. M->ZDA_PRCVEN > DA1->DA1_I_PRCA 
      U_ITMSG("Valor invalido. Deve ser maior que zero",'ATENCAO!',"Nao pode ser menor que o campo (DA1_PRCVEN) "+ALLTRIM(STR(DA1->DA1_PRCVEN,11,2))+ENTER+;
                                                                   "Nao pode ser maior que o campo (DA1_I_PRCA) "+ALLTRIM(STR(DA1->DA1_I_PRCA,11,2)),1)
      RETURN .F.
   ELSE
      IF M->ZDA_PRCVEN < aCols[n][_nPos3]//minimo
   	   aCols[n][_nPos3]:= M->ZDA_PRCVEN 
      ENDIF
      IF M->ZDA_PRCVEN > aCols[n][_nPos4]//maximo
	      aCols[n][_nPos4]:= M->ZDA_PRCVEN
      ENDIF
   ENDIF

ELSEIF "ZDA_PMINFE" $ _cCampo//ZDA_PMINFE: Deve ser maior que zero e Nao pode ser menor que o campo DA1_I_PMFE

   IF M->ZDA_PMINFE <= 0 .OR. M->ZDA_PMINFE < DA1->DA1_I_PMFE .OR. M->ZDA_PMINFE > aCols[n][_nPos2]
      U_ITMSG("Valor invalido. Deve ser maior que zero.",'ATENCAO!',"Nao pode ser menor que o campo (DA1_I_PMFE) "+ALLTRIM(STR(DA1->DA1_I_PMFE,11,2))+ENTER+;
                                                                    "Nao pode ser maior que o Preco carga fechada (ZDA_PRCVEN) "+ALLTRIM(STR(aCols[n][_nPos2],11,2)),1)
      RETURN .F.
   ENDIF

ELSEIF "ZDA_PMAXFE" $ _cCampo//ZDA_PMAXFE: Deve ser maior que zero e Nao pode ser maior que o campo DA1_I_PRCA

   IF M->ZDA_PMAXFE <= 0 .OR. M->ZDA_PMAXFE > DA1->DA1_I_PRCA .OR. M->ZDA_PMAXFE < aCols[n][_nPos2]
      U_ITMSG("Valor invalido. Deve ser maior que zero.",'ATENCAO!',"Nao pode ser maior que o campo (DA1_I_PRCA) "+ALLTRIM(STR(DA1->DA1_I_PRCA,11,2))+ENTER+;
                                                                    "Nao pode ser menor que o Preco carga fechada (ZDA_PRCVEN) "+ALLTRIM(STR(aCols[n][_nPos2],11,2)),1)
      RETURN .F.
   ENDIF

ELSEIF "ZDA_PRCFRA" $ _cCampo//ZDA_PRCFRA: Deve ser maior que zero e Nao pode ser menor que o campo DA1_I_PRFE (gatilhar o conteúdo do campo XXX_PRCVEN na inclusão)

   IF M->ZDA_PRCFRA <= 0 .OR. M->ZDA_PRCFRA < DA1->DA1_I_PRFE .OR. M->ZDA_PRCFRA > DA1->DA1_I_PRCA  
      U_ITMSG("Valor invalido. Deve ser maior que zero.",'ATENCAO!',"Nao pode ser menor que o campo (DA1_I_PRFE) "+ALLTRIM(STR(DA1->DA1_I_PRFE,11,2))+ENTER+;
                                                                    "Nao pode ser maior que o campo (DA1_I_PRCA) "+ALLTRIM(STR(DA1->DA1_I_PRCA,11,2)),1)
      RETURN .F.
   ELSE
      IF M->ZDA_PRCFRA < aCols[n][_nPos6]//minimo
   	   aCols[n][_nPos6]:= M->ZDA_PRCFRA 
      ENDIF
      IF M->ZDA_PRCFRA > aCols[n][_nPos7]//maximo
	      aCols[n][_nPos7]:= M->ZDA_PRCFRA
      ENDIF
   ENDIF

ELSEIF "ZDA_PMINFR" $ _cCampo//ZDA_PMINFR: Deve ser maior que zero e Nao pode ser menor que o campo DA1_I_PMFR (gatilhar o conteúdo do campo XXX_PMINFE na inclusão)

   IF M->ZDA_PMINFR <= 0 .OR. M->ZDA_PMINFR < DA1->DA1_I_PMFR .OR. M->ZDA_PMINFR > aCols[n][_nPos5]
      U_ITMSG("Valor invalido. Deve ser maior que zero.",'ATENCAO!',"Nao pode ser menor que o campo (DA1_I_PMFR) "+ALLTRIM(STR(DA1->DA1_I_PMFR,11,2))+ENTER+;
                                                                    "Nao pode ser maior que o Preco carga fechada (ZDA_PRCFRA) "+ALLTRIM(STR(aCols[n][_nPos5],11,2)),1)
      RETURN .F.
   ENDIF

ELSEIF "ZDA_PMAXFR" $ _cCampo//ZDA_PMAXFR: Deve ser maior que zero e Nao pode ser maior que o campo DA1_I_PRCA (gatilhar o conteúdo do campo XXX_PMAXFE na inclusão)

   IF M->ZDA_PMAXFR <= 0 .OR. M->ZDA_PMAXFR > DA1->DA1_I_PRCA .OR. M->ZDA_PMAXFR < aCols[n][_nPos5]
      U_ITMSG("Valor invalido. Deve ser maior que zero.",'ATENCAO!',"Nao pode ser maior que o campo (DA1_I_PRCA) "+ALLTRIM(STR(DA1->DA1_I_PRCA,11,2))+ENTER+;
                                                                    "Nao pode ser menor que o Preco carga fechada (ZDA_PRCFRA) "+ALLTRIM(STR(aCols[n][_nPos5],11,2)),1)
      RETURN .F.
   ENDIF

ENDIF
/*   
Validações:
XXX_CODPRO: O produto inserido na tabela deve existir na tabela de Precos oficial 
(verificar se existe um registro na tabela DA1 com DA1_FILIAL = ‘01’, 
DA1_CODPRO = XXX_CODPRO e verificar também se o registro correspondente na tabela 
DA0 está válido (ativo e dentro da data de validade)).

ZDA_PRCVEN: Deve ser maior que zero e Nao pode ser menor que o campo DA1_PRCVEN
ZDA_PMINFE: Deve ser maior que zero e Nao pode ser menor que o campo DA1_I_PMFE
ZDA_PMAXFE: Deve ser maior que zero e Nao pode ser maior que o campo DA1_I_PRCA
ZDA_PRCFRA: Deve ser maior que zero e Nao pode ser menor que o campo DA1_I_PRFE (gatilhar o conteúdo do campo XXX_PRCVEN na inclusão)
ZDA_PMINFR: Deve ser maior que zero e Nao pode ser menor que o campo DA1_I_PMFR (gatilhar o conteúdo do campo XXX_PMINFE na inclusão)
ZDA_PMAXFR: Deve ser maior que zero e Nao pode ser maior que o campo DA1_I_PRCA (gatilhar o conteúdo do campo XXX_PMAXFE na inclusão)
*/

Return .T.
