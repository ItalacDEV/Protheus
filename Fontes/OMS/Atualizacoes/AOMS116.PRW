/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
    Autor     |   Data   |                              Motivo                                                          
================================================================================================================================
 Alex Walaluer| 12/05/20 | Chamado 31089. Criacao de novos campos e tratamentos para os mesmos. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Walaluer| 09/09/21 | Chamado 37704. Criacao e tratamentos  do campo Z19_OPERAC. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Walaluer| 15/09/21 | Chamado 37739. Novo tratamentos para o Schedule, nova funcao SchedDef(). 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Walaluer| 16/09/21 | Chamado 37739. Aumento da capacidade de itens do MsGetDados() para 999. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Walaluer| 20/09/21 | Chamado 37739. Novas Selects de PV de Transferias para o tipo 2=Operador Logistico. 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 20/09/22 | Chamado 41205. Alteração na forma de validar a terceira unidade de medida, para Qtde Fracionada.
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 24/06/24 | Chamado 47634. Lucas. Ajuste dinâmico das linhas no array _aTransferecias do MSExecAuto(MATA261()).
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 16/07/24 | Chamado 47873. Andre. Correção do error.log: variable does not exist _COBST on AOMS116EML().
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/07/25 | Chamado 51340. Ajustar função para validação de ambiente de teste
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
Programa----------: AOMS116
Autor-------------: Alex Wallauer
Data da Criacao---: 07/11/2019
==================================================================================================================================
Descrição---------: Cadastro de Reposição automática de estoque CHAMADO 31089
==================================================================================================================================
Parametros--------: Nenhum
==================================================================================================================================
*/
*====================================================*
User Function AOMS116()
*====================================================*
Local _cAlias := "Z19"
Local _aCores := {	{ "Z19_MSBLQL <> '1' ", "BR_VERDE"	 },;//
					{ "Z19_MSBLQL == '1'" , "BR_VERMELHO"}}  //Bloqueado

Private cCadastro:= "Cadastro de Reposição automatica de estoque"
Private aRotina		:= {}                

AADD(aRotina,{"Pesquisar"	  ,"AxPesqui"  ,0,1})
AADD(aRotina,{"Visualizar"	  ,"U_AOMS116M",0,2})
AADD(aRotina,{"Incluir"		  ,"U_AOMS116M",0,3})
AADD(aRotina,{"Alterar"		  ,"U_AOMS116M",0,4})
AADD(aRotina,{"Excluir"		  ,"U_AOMS116M",0,5})
AADD(aRotina,{"Executar Regra","U_AOMS116M",0,2})
aAdd(aRotina,{"Legenda"       ,"U_AOMS_LEGE(.F.)",0,7})

dbSelectArea(_cAlias)
dbSetOrder(1)


// owse(,,,,cAli>  ,<aFixe, <cCpo>, <nPar>, <cCorFun>, <nClickDef>, <aColors>, <cTopFun>, <cBotFun>, <nPar14>, <bInitBloc>, <lNoMnuFilter>, <lSeeAll>, <lChgAll>, <cExprFilTop>, <nInterval>, <uPar22>, <uPar23> )
mBrowse(,,,,_cAlias,      ,       ,       ,          ,            , _aCores)

Return

/*
=================================================================================================================================
Programa----------: U_AOMS_LEGE
Autor-------------: Alex Wallauer
Data da Criacao---: 07/11/2019
==================================================================================================================================
Descrição---------: Cadastro de Reposição automática de estoque LEGENDA
==================================================================================================================================
Parametros--------: lBotao
==================================================================================================================================
*/
User Function AOMS_LEGE(lBotao)
   
Local _aLegenda := {{ "BR_VERMELHO","Bloqueado" },;
                 	{ "BR_VERDE"   ,"Liberado"  } }
IF lBotao             
   _aLegenda := {{ "BR_VERMELHO" ,"Tem Reposicao Critica e vai Gerar Pedido"},;//BOLINHA VERMELHO
               	 { "BR_AZUL"     ,"Tem Reposicao e vai Gerar Pedido"        },;//BOLINHA AZUL
               	 { "BR_AMARELO"  ,"Já Repos, Falta Confirmar"               },;//BOLINHA AMARELO
               	 { "BR_VERDE"    ,"Tudo OK, nao tem Reposicao"              } }//BOLINHA VERDE

   AADD(_aLegenda,{ "PMSTASK1"      ,"Lista Tem Reposicao Critica e vai Gerar Pedido"})//QUADRADO VERMELHO
   AADD(_aLegenda,{ "PMSTASK6"      ,"Lista Tem Reposicao e vai Gerar Pedidor"       })//QUADRADO AZUL    
   AADD(_aLegenda,{ "PMSTASK2"      ,"Lista Já Repos, Falta Confirmar"               })//QUADRADO AMARELO 
   AADD(_aLegenda,{ "PMSTASK4"      ,"Lista Tudo OK, nao tem Reposicao"              })//QUADRADO VERDE    
ENDIF

BRWLEGENDA(cCadastro, "Legenda", _aLegenda )
   
Return 

/*
===============================================================================================================================
Programa--------: AOMS116M
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: Cadastro de Reposição automática de estoque MANUTENÇÃO
==================================================================================================================================
Parametros------: cAlias,nReg,_nOpcx
==================================================================================================================================
*/
User Function AOMS116M(cAlias,nReg,_nOpcx)
Local _aObjects, _aPosObj, _aInfo, _oDlgEnch ,_nni//, _nnj
Local _aSizeAut := MsAdvSize(.T.)
Local _cTitulo  :=cCadastro
Local _bOk      := {|| If(AOMS116Grv(_nOpcx),(_lRet := .T., _oDlgEnch:End()),)} 
Local _bCancel  := {|| _lRet := .F., _oDlgEnch:End()}
Local bCampo    := {|nCPO| Field(nCPO) }
//PRIVATE _cPrd3Um:= U_ITGETMV( "IT_PRD3UM","  ")//Produtos a validar pela 3ª unidade de medida

IF _nOpcx = 6 // EXECUTA AS REGRAS
   U_AOMS116S()
   RETURN .T.
ENDIF   

Private aHeader:= {}
Private aCols  := {}       
Private aTELA  := {} // Variáveis que serão atualizadas pela Enchoice
Private aGETS  := {} // e utilizadas pela função OBRIGATORIO()

DbSelectArea("Z19")//INICIA VARIAVIES DA CAPA
Z20->(DBSETORDER(1))

If _nOpcx # 3  //se nao for inclusao
	For _nni := 1 TO FCount()
		M->&(EVAL(bCampo,_nni)) := FieldGet(_nni)
	Next 
ELSE	
	For _nni := 1 TO FCount()
		M->&(EVAL(bCampo,_nni)) := CriaVar(EVAL(bCampo,_nni),.F.)
	Next 
Endif

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
M->Z20_COD:=""//Inicia Branco por causa do X3_RELACAO
_lCntrlDescIni:=.T.//Controla de qual campo pega a descrição do item se data tabela Z20 (.T.) ou memoria (.F.)
cSeek  := xFilial("Z19")+Z19->Z19_REGRA
lTemItens:=_nOpcx # 3 .AND. Z20->(DBSEEK(cSeek))
IF !lTemItens
    nOpc:=3
    FillGetDados(_nOpcx,"Z20",1,/*cSeek*/,/*bWhile*/,,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T.,/*aHeaderAux*/,/*aColsAux*/,,/*bBeforeCols*/,/*bAfterHeader*/,)
ELSE    
    bWhile := {|| Z20_FILIAL+Z20_REGRA }
    nOpc:=_nOpcx
    FillGetDados(_nOpcx,"Z20",1,cSeek   ,bWhile    ,,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,,/*bBeforeCols*/,/*bAfterHeader*/,)
ENDIF    
_lCntrlDescIni:=.F.//Controla de qual campo pega a descrição do item se data tabela Z20 (.T.) ou memoria (.F.)

//==============================================================================================================
// Montagem do aHeader na mão para não aparecer os campos extras criados pela função FillGetDados
/*
aHeader:= {}                   // cAlias , lVirtual 
_aZ20 := FWSX3Util():GetAllFields( "Z20" , .T.     )
FOR _NNJ := 1 TO LEN(_aZ20)
    _cUsado:=Getsx3cache(_aZ20[_NNJ],"X3_USADO")
    If X3USO(_cUsado)
	   AADD( aHeader, {   Getsx3cache(_aZ20[_NNJ],"X3_TITULO")  ,;
	                      Getsx3cache(_aZ20[_NNJ],"X3_CAMPO")   ,;
                      	  Getsx3cache(_aZ20[_NNJ],"X3_PICTURE") ,;
	                      Getsx3cache(_aZ20[_NNJ],"X3_TAMANHO") ,;
	                      Getsx3cache(_aZ20[_NNJ],"X3_DECIMAL") ,;
	                      Getsx3cache(_aZ20[_NNJ],"X3_VALID")   ,;
	                      Getsx3cache(_aZ20[_NNJ],"X3_USADO")   ,;
	                      Getsx3cache(_aZ20[_NNJ],"X3_TIPO")	,;
	                      Getsx3cache(_aZ20[_NNJ],"X3_ARQUIVO") ,;
                          Getsx3cache(_aZ20[_NNJ],"X3_CONTEXT") })
    ENDIF                      
Next*/
//==============================================================================================================

// Tela de Manutenção
_aObjects:= {}
AAdd( _aObjects, { 100, 050, .T., .T. } )
AAdd( _aObjects, { 100, 100, .T., .T. } )
_aInfo   := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 }
_aPosObj := MsObjSize( _aInfo, _aObjects, .T. )
_lDeleta :=((nOpc = 3) .or. (nOpc = 4))

Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel
      
   EnChoice( "Z19" ,nReg, _nOpcx, , , , , _aPosObj[1], , 3 )
            
	//        MsGetDados(): New( < nTop>        , < nLeft>    , < nBottom>     , < nRight>,< nOpc>,[ cLinhaOk]     , [ cTudoOk],[ cIniCpos],[ lDeleta],[ aAlter]  , [ nFreeze], [ lEmpty], [ nMax], [ cFieldOk], [ cSuperDel], [ uPar], [ cDelOk], [ oWnd], [ lUseFreeze], [ cTela] )
   _oGetDados := MsGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], nOpc, /*"U_LINHAOK"*/,           ,           ,  _lDeleta, /*aAlter*/,           , .F.      , 999   , /*FIELDOK*/, /*SUPERDEL*/,        , /*DELOK*/, _oDlgEnch)
   
Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel) 
   
Return 


/*
===============================================================================================================================
Programa--------: U_AOMS116G()
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: Função chamada do X3_VALID do campo Z20_COD //ExistCpo("SB1") .AND. U_AOMS116G()
==================================================================================================================================
Parametros------: Nenhum
==================================================================================================================================
*/
User Function AOMS116G(_lValid,cGruCpo)
LOCAL _nPos1:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_COD"	 } )
LOCAL _nPos2:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_DESCPR"} )
//LOCAL _nPos3:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_ESTI1M"} ) 
LOCAL _nPos4:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_ESTIDE"} )
Local _cCrtl3Um := "N" // Produtos a validar quantidade fracionada na terceira unidade de medida.

DEFAULT cGruCpo :="1"

IF cGruCpo="1" .AND. _lValid

   IF aCols[n][_nPos1] <> M->Z20_COD .AND. Z20->(DBSEEK(xFilial("Z20")+M->Z19_REGRA+aCols[n][_nPos1] ))
      U_ITMSG("Codigo do produto não pode ser alterado por que é chave de pesquisa.","Atenção",;
	           "Delete essa linha e insira uma com o novo codigo de produto",1)
      RETURN .F.
   ELSE
      aCols[n,_nPos2] := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+M->Z20_COD,"B1_DESC"))+" ["+SB1->B1_SEGUM+"]"
   ENDIF

ELSEIF cGruCpo="1" 

  IF _lCntrlDescIni //Controla de qual campo pega a descrição do item se data tabela Z20 (.T.) ou memoria (.F.)
     IF !Inclui
        RETURN ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+Z20->Z20_COD,"B1_DESC"))+" ["+SB1->B1_SEGUM+"]"
     ENDIF
  ENDIF   
  RETURN " "

ELSEIF cGruCpo="2" .AND. _lValid
       _nQtde := aCols[n][_nPos4] // _nQtde :=ConvUM(aCols[n][_nPos1],0,@_n2Qtde)
       _cCrtl3Um := Posicione("SBZ",1,xFilial("SBZ")+AllTrim(aCols[n][_nPos1]),"BZ_I_PR3UM")
       If _cCrtl3Um == "S"
          If Mod(_nQtde,2) <> 0
             U_ITMSG("O Calculo da terceira unidade não pode ser Fracionada  [ "+CVALTOCHAR(_nQtde)+" "+SB1->B1_I_3UM+" ] ","Atenção",;
	                 "Digite valores inteiros.",1)
             RETURN .F.
          EndIf                 
	    ELSE
          _nQtde := aCols[n][_nPos4] // ConvUM(aCols[n][_nPos1],0,M->Z20_ESTIDE,.F.)
          If _nQtde <> Int(_nQtde)  
             U_ITMSG("O Calculo da primeira unidade não pode ser Fracionada  [ "+CVALTOCHAR(_nQtde)+" "+SB1->B1_UM+" ] ","Atenção",;
	                  "Digite a Segunda Unidade inteira, sem decimais",1)
             RETURN .F.
          EndIf 
	    ENDIF	             

ELSEIF cGruCpo="2" 

  IF _lCntrlDescIni //Controla de qual campo pega a descrição do item se data tabela Z20 (.T.) ou memoria (.F.)
     IF !Inclui
        _nQtde:=ConvUM(Z20->Z20_COD,0,Z20->Z20_ESTIDE,.F.)
        RETURN TRANSF(_nQtde,"@E 999,999,999.99")+" "+SB1->B1_UM
     ENDIF
  ENDIF   
  RETURN " "

ENDIF   

RETURN .T.
/*
===============================================================================================================================
Programa--------: AOMS116Grv()
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: Cadastro de Reposição automática de estoque GRAVAÇÃO
==================================================================================================================================
Parametros------: cAlias,nReg,_nOpcx
==================================================================================================================================
*/
STATIC Function AOMS116Grv(_nOpcx)
LOCAL nConIten  ,nConCmp
LOCAL cAliasItm:="Z20"
LOCAL _nPos := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_COD"	 } )
LOCAL _nPos1:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_ESTIDE"} )
LOCAL _nPos2:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_MINREP"} )
LOCAL _nPos3:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "Z20_MSBLQL"} )
LOCAL lTudoOK:=.F.
LOCAL aProd  :={}

Z19->(DBSETORDER(1))
Z20->(DBSETORDER(1))

IF _nOpcx = 2
   RETURN .T.
ELSEIF _nOpcx = 5
   BEGIN TRANSACTION
   Z19->(RECLOCK("Z19",.F.))
   Z19->(DBDELETE())
   For nConIten := 1 to Len(aCols)
       IF Z20->(DBSEEK(xFilial("Z20")+M->Z19_REGRA+aCols[nConIten][_nPos] ))
	      Z20->(RecLock("Z20",.F.))
	      Z20->(DBDELETE())
	   ENDIF   
   Next 
   END TRANSACTION
   U_ITMSG("DADOS EXCUIDOS COM SUCESSO","Atenção",,2)
   RETURN .T.
ENDIF

If !Obrigatorio(aGets,aTela)
   RETURN .F.
ENDIF

For nConIten := 1 to Len(aCols)
	If aCols[nConIten][LEN(aCols[nConIten])]//DELETADOS
       LOOP
    ENDIF	    
	IF  !EMPTY(aCols[nConIten][_nPos ]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos1]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos2]) .AND.;
	    !EMPTY(aCols[nConIten][_nPos3])
        
        IF ASCAN(aProd,aCols[nConIten][_nPos]) = 0
	       AADD(aProd,aCols[nConIten][_nPos])
	    ELSE   
           lTudoOK:=.F.
	       U_ITMSG("Produto: "+aCols[nConIten][_nPos]+" Repetido.","Atenção",;
	               "Apague ou Altere o codigo do produto da linha: "+ALLTRIM(STR(nConIten)),1)
	       RETURN .F.
	    ENDIF   
        
        lTudoOK:=.T.  
        
    ELSE
        lTudoOK:=.F.
        EXIT
    ENDIF    
NEXT

If !lTudoOK
	U_ITMSG("É necessário informar Produtos antes da gravação.","Atenção",;
	        "Insira produtos validos, não repetidos e preencha todos os campos obrigatorios da linha",1)
	RETURN .F.
EndIf

BEGIN TRANSACTION
Z19->(RECLOCK("Z19", !DBSEEK(xFilial("Z19")+M->Z19_REGRA) ))
AVREPLACE("M","Z19")
M->Z19_FILIAL:= xFilial("Z19")
Z19->(MSUNLOCK())

// Gravacao dos Itens
DBSELECTAREA("Z20")
For nConIten := 1 to Len(aCols)
	
	// Valida se o registro nao esta deletado
	If !aCols[nConIten][LEN(aCols[nConIten])]//DELETADOS

        IF Z20->(DBSEEK(xFilial("Z20")+M->Z19_REGRA+aCols[nConIten][_nPos] ))
		   Z20->(RecLock("Z20",.F.))
		ELSE
		   Z20->(RecLock("Z20",.T.))
		ENDIF   
		For nConCmp := 1 to Len(aHeader)
			If (aHeader[nConCmp,10] <> "V")
				FieldPut(FieldPos(aHeader[nConCmp,2]), aCols[nConIten, nConCmp])
			EndIf
		Next 
		(cAliasItm)->Z20_FILIAL := xFilial("Z20")
		(cAliasItm)->Z20_REGRA  := M->Z19_REGRA	
	    (cAliasItm)->(MsUnlock())
    ELSE
       IF Z20->(DBSEEK(xFilial("Z20")+M->Z19_REGRA+aCols[nConIten][_nPos] ))
	      Z20->(RecLock("Z20",.F.))
	      Z20->(DBDELETE())
	   ENDIF   
	EndIf

Next 

END TRANSACTION

U_ITMSG("DADOS GRAVADOS COM SUCESSO","Atenção",,2)

RETURN .T.

/*
===============================================================================================================================
Programa--------: AOMS116S
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: Cadastro de Reposição automática de estoque EXECUTA AS REGRAS
==================================================================================================================================
Parametros------: _lSchedule
==================================================================================================================================
*/
User Function AOMS116S(aParam)
LOCAL nPos
Local _lSchedule := FWGetRunSchedule()
DEFAULT aParam	:= {"01","40"}
PRIVATE _cTimeIni:=TIME()


IF _lSchedule 

   IF SELECT("SX3") = 0 .OR. SELECT("SM0") = 0

      U_ITCONOUT('INCIANDO AOMS116: '+aParam[01]+' FILIAL '+aParam[02]+" H.I.:"+_cTimeIni)
   
      RpcSetType(3)
      PREPARE ENVIRONMENT EMPRESA aParam[01] FILIAL aParam[02] MODULO "OMS" TABLES "Z19","Z20","SC5","SC6","ZZM","SD2","SA1"
   
      Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.
      U_ITCONOUT('INCIADO AOMS116: '+aParam[01]+' FILIAL '+aParam[02]+" H.F.: "+TIME())
      cFilAnt := aParam[02]
   
   ELSE

      U_ITCONOUT('INCIADO AOMS116: FILIAL '+cFilAnt+" H.I.:"+_cTimeIni)
      DBSELECTAREA("Z19")
      DBSELECTAREA("Z20")      

   ENDIF                   

ELSE

   IF !U_ITMSG("Cofirma Execução da Regra "+Z19->Z19_REGRA+" ?",'Atenção!',,2,2,2)//ALERT
      RETURN .F.
   ENDIF
   _lSchedule:=.F.

ENDIF

Z19->(DBSETORDER(1))
Z20->(DBSETORDER(1))

PRIVATE _aLinhas:={}
PRIVATE _aPts:={}
PRIVATE _aCab:={}
PRIVATE _aSize:={}

//MONTA _aCab PARA QUANDO NÃO É lRepoeArmazens
aadd(_aCab,"")//01
aadd(_aSize,1)
AAdd(_aCab,"Filial")//02
aadd(_aSize,05)
AAdd(_aCab,"Produto")//03
_nPosColProd:=LEN(_aCab)
aadd(_aSize,15)
AAdd(_aCab,"Descrição")//04
aadd(_aSize,100)
AAdd(_aCab,"Reposição")//05
_nPosColRepo:=LEN(_aCab)
aadd(_aSize,40)
AAdd(_aCab,"Fil.Ped.")//06
_nPosColFil:=LEN(_aCab)
aadd(_aSize,40)
AAdd(_aCab,"Carteira")//07
_nPosColCar:=LEN(_aCab)
aadd(_aSize,40)
AAdd(_aCab,"Estoque")//08
_nPosColEst:=LEN(_aCab)
aadd(_aSize,40)
AAdd(_aCab,"Transito")//09
aadd(_aSize,40)
AAdd(_aCab,"PV.Transf.")//10
aadd(_aSize,40)
AAdd(_aCab,"Disponivel")//11
aadd(_aSize,40)
AAdd(_aCab,"Est.Ideal")//12
aadd(_aSize,40)
AAdd(_aCab,"Ped.Minimo")//13
aadd(_aSize,40)
AAdd(_aCab,"Qtde.Repor")//14
aadd(_aSize,40)
AAdd(_aCab,"Qtde.Poder3o")//15 - NOVO
_nColPoder3o:=LEN(_aCab)
aadd(_aSize,45)
AAdd(_aCab,"Multiplicador") //16
aadd(_aSize,40)
AAdd(_aCab,"Peso Reposicao")//17 - NOVO
aadd(_aSize,45)
AAdd(_aCab,"Seg.UM")        //18 - NOVO
aadd(_aSize,20)
AAdd(_aCab,"Acao")          //19 - NOVO
_nPosColAcao:=LEN(_aCab)
aadd(_aSize,10)
_aCabPT:={"Produto","Descricao","Filial","Pedido","Emissao","Seg.UM","Quantidade"}//USA NA FUNCAO AOMS13PT() E AOMS116EML() por Schedule

PRIVATE _cTRB:=GetNextAlias()

If _lSchedule

   AAdd(_aCab,"Ped. Gerado")// 20 // antigo 16
   _nPosPedGer:=LEN(_aCab)
   aadd(_aSize,50)
   AAdd(_aCab,"Observação") // 21 // antigo 17
   _nPosObs:=LEN(_aCab)
   aadd(_aSize,200)
   AAdd(_aCab,"Cod.Item")   // 22 // antigo 18
   _nPosCodItem:=LEN(_aCab)
   aadd(_aSize,50)

   Z19->(DBGOTOP())

   DO WHILE Z19->(!EOF())

      IF Z19->Z19_MSBLQL="1" .OR. cFilAnt <> Z19->Z19_FILIAL
         Z19->(DBSKIP())
         LOOP      
      ENDIF
      cFilAnt:=Z19->Z19_FILIAL
      _aLinhas:={}

	  U_ITConOut('Executando regra: '+Z19->Z19_FILIAL+" "+Z19->Z19_REGRA)

      lRepoeArmazens:= (Z19->Z19_TIPO = "3" .OR. (EMPTY(Z19->Z19_TIPO) .AND. ("70;72" $ ALLTRIM(Z19->Z19_LOCAL) .OR. "72;70" $ ALLTRIM(Z19->Z19_LOCAL) ) ) )

      IF  lRepoeArmazens
          
//        Ver_Est_AM(,.T.) //NAO PODE SER SCHEDULADO PQ TEM DECISAO DO USUARIO
          
      ELSE
      
          AOMS116L(,Z19->Z19_TIPO)//EXECUTAS AS SELECTS CONFORME AS REGRAS
      
          AOMSGerPed(,.T.) //GERA OS PVS E ENVIA E-MAIL
      ENDIF    

      Z19->(DBSKIP())

   ENDDO   
	
ELSE

    lRepoeArmazens:= (Z19->Z19_TIPO = "3" .OR. (EMPTY(Z19->Z19_TIPO) .AND. ("70;72" $ ALLTRIM(Z19->Z19_LOCAL) .OR. "72;70" $ ALLTRIM(Z19->Z19_LOCAL) ) ) )

    IF lRepoeArmazens

       PRIVATE _cProdutos:=""
       FWMSGRUN(,{|oProc| Ver_Est_AM(oProc,.F.) },"Executando Regra "+Z19->Z19_REGRA,'Lendo dados dos Produtos...')
          
    ELSE
	       
       FWMSGRUN(,{|oProc| AOMS116L(oProc,Z19->Z19_TIPO) },"Executando Regra "+Z19->Z19_REGRA,'Lendo dados dos Produtos...')

	ENDIF
    
	aBotoes:={}
    bDblClk:=NIL
    bCondMarca:=NIL
    IF lRepoeArmazens/// *******************  ARMAZENS ***************************
       _cMsgTop:='Regra: '+Z19->Z19_REGRA+' - Tempo de execução: Hr. Inicial: '+_cTimeIni+", Hr. Final: "+TIME()

       _aCab:={" "," ","Produto","Descricao","1aUM / 2aUM","Est.Ideal 2UM","Ped.Minimo","Qtde.Repor 2UM","Atual 70 2UM","Atual 72 2UM","Arm 20 2UM","Arm 22 2UM","Repor. 70 1UM","Repor. 70 2UM","Qtde 70 3UM","Repor. 72 1UM","Repor. 72 2UM","Qtde 72 3UM","Acao","Observacao"}
       _aSize:={ 1, 1 ,       15,         60,             05,             40,        40,              45,            40,            40,          40,          40,             40,            40 ,           40,            40 ,            40 ,          40 ,    20,         200}
       _nTipo:=2

       _nPosColProd:=3//PARA lRepoeArmazens
	   AADD( aBotoes , { "" , {|| CADSB1(oLbxAux) } , "" , "Visualisar Prod."  } )
   	   bCondMarca:={|oLbxAux,nAt| oLbxAux:aArray[nAt][2] }
	   _bLegenda:=NIL
       _aColXML:={}
       FOR nPos:= 1 TO LEN(_aLinhas)
           AADD(_aColXML,ACLONE(_aLinhas[nPos]))
           _aColXML[nPos,1]:=IF(_aColXML[nPos,1],"X","")
           _aColXML[nPos,2]:=IF(_aColXML[nPos,2],"OK","NO")
       NEXT
       _cTitAux:="TRANSFERENCIAS DE ARMAZENS"
    ELSE/// *******************  GERA PEDIDOS ***************************
	   _aLinhas := ASORT(_aLinhas,,,{|x,y| x[_nPosColFil]+x[_nPosColProd] < y[_nPosColFil]+y[_nPosColProd]})
       _cTitAux:="GERACAO DE PEDIDOS"
       _cMsgTop:='Regra: '+Z19->Z19_REGRA+' - [ 2 cliques na colua de "Reposição" ou "Fil.Ped." para editar ] - Tempo de execução: Hr. Inicial: '+_cTimeIni+", Hr. Final: "+TIME()
	   IF LEN(_aPts) > 0
	      AADD( aBotoes , { "" , {|| AOMS13PT(_aPts) } , "" , "Visualisar os P.T."  } )
	   ENDIF
	   AADD( aBotoes , { "" , {|| FWMSGRUN(,{|oProc|  AOMS116EML(.T., _aLinhas,oProc,{},_aPts) },"Enviando E-MAIL...") }, "" , "Envia E-MAIL"  } )
       AADD( aBotoes , { "" , {|| U_AOMS_LEGE(.T.) } , "" , "LEGENDA"  } )
	   bDblClk:={|| AOMS116GET(@oLbxAux)}
	   _bLegenda:={|C,L| U_AOMS13Leg(C,L) }
       _aColXML:={}
       FOR nPos:= 1 TO LEN(_aLinhas)
           AADD(_aColXML,ACLONE(_aLinhas[nPos]))
           _aColXML[nPos,1]:=IF(_aColXML[nPos,1],"X","")
       NEXT
       _nTipo:=4
	   // _aCab DESSE ELSE MONTANDO NO INICO DO PROGRAMA
    ENDIF
    
	DO WHILE Len(_aLinhas) > 0		
	//         ITListBox(_cTitAux , _aHeader , _aCols    , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda)
	   lRet:=U_ITLISTBOX(cCadastro, _aCab    , _aLinhas  , .T.      , _nTipo , _cMsgTop ,          , _aSize  ,         ,     ,        , aBotoes  ,       ,bDblClk , _aColXML , bCondMarca,_bLegenda)

       IF lRet
          IF lRepoeArmazens
             FWMSGRUN(,{|oProc| Ver_Est_AM(oProc,.T.) },'Aguarde processamento...',"Gerando Transferencias...")
          ELSE
             FWMSGRUN(,{|oProc| AOMSGerPed(oProc,.F.) },'Aguarde processamento...',"Gerando Pedidos...") //GERA OS PEDIDOS E MOSTRA A TELA DE LOG E ENVIA E-MAIL
          ENDIF   
       ELSEIF !U_ITMSG("Cofirma SAIR ?",'Atenção!',,3,2,2)
          LOOP
       ENDIF

       EXIT

	ENDDO

	IF Len(_aLinhas) = 0

		U_ITMSG("Nenhum registro localizado","Atenção",,1)

	Endif
	
ENDIF 
RETURN .T.

/*
===============================================================================================================================
Programa--------: AOMSGerPed()
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: GERA OS PEDIDOS E MOSTRA A TELA DE LOG E ENVIA E-MAIL
==================================================================================================================================
Parametros------: oProc,_lSchedule
==================================================================================================================================
*/
STATIC Function AOMSGerPed(oProc,_lSchedule)
LOCAL _aLog:={} , _nI ,L , _nPos
LOCAL _cTimeIni:=TIME()
LOCAL _aLog2:={}
PRIVATE _nQtdePV:=0

//_cTeste:="INICIO"+ENTER

 IF _lSchedule
    IF LEN(_aLinhas) > 0
       AOMS116EML(.F., _aLinhas,,{} ,_aPts)//ENVIA E-MAIL ANTES DE GERAR SEMPRE NO SCHEDULE
    ENDIF
ELSE

    AAdd(_aCab,"Ped. Gerado")// 20 // antigo 16
    _nPosPedGer:=LEN(_aCab)
    aadd(_aSize,50)
    AAdd(_aCab,"Observação") // 21 // antigo 17
    _nPosObs:=LEN(_aCab)
    aadd(_aSize,200)
    AAdd(_aCab,"Cod.Item")   // 22 // antigo 18
    _nPosCodItem:=LEN(_aCab)
    aadd(_aSize,50)

ENDIF

If !_lSchedule
   _nConta:= Len( _aLinhas )
   _cTot  :=ALLTRIM(STR(_nConta))
   _nTam  :=LEN(_cTot)
   _nConta:=0
   oProc:cCaption := ("Gerando Pedidos de "+_cTot+" Produtos ")
   ProcessMessages()
   SLEEP(1000)
EndIf

Z09->(DBSETORDER(3)) // Z09_FILIAL+Z09_FILORI+Z09_FILDES+Z09_CODOPE+Z09_CODPRO 
_cCnrtlFilRepo:="XX"
aItensGeraFil:={}
_lEnviaEnailLog:=.F.
For _nI := 1 To Len( _aLinhas )

    aItens:=_aLinhas[_nI]
    If !_lSchedule
       _nConta++
	   oProc:cCaption := ("Gerando PV Prod: "+aItens[_nPosColFil]+" "+aItens[_nPosColProd]+" / "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
	   ProcessMessages()
    EndIf
	IF aItens[_nPosColAcao] = "1"//Broqueados e listados
	   LOOP
	ENDIF
    IF _cCnrtlFilRepo = "XX"//PRIMIERA VEZ
       _cCnrtlFilRepo:=aItens[_nPosColFil]
    ENDIF

    IF _cCnrtlFilRepo <> aItens[_nPosColFil]//GERA  O PV DOS ITENS DA MESMA FILIAL DE REPOSICAO
       
       IF !EMPTY(_cCnrtlFilRepo) .AND. LEN(aItensGeraFil) > 0
//***************  CRIA O PEDIDO ************************************************************************//
          _aRet  :=AOMSCriaPed(_cCnrtlFilRepo, aItensGeraFil,_lSchedule )
//***************  CRIA O PEDIDO ************************************************************************//
          _cPV   :=_aRet[1]
          _cErro :=_aRet[2]       

          IF !EMPTY(_cPV) .AND. ASCAN(_aLog,{|P| P[_nPosPedGer]==_cPV}) = 0
            _nQtdePV++
          ENDIF  

          FOR L := 1 TO LEN(aItensGeraFil)
              IF (_nPos:=ASCAN(_aLog2,{|P| P[7] == aItensGeraFil[L,_nPosColProd]} )) <> 0
                 _aLog2[_nPos,01]:=EMPTY(_cErro)//.T. ou .F.
                 _aLog2[_nPos,03]:=_cPV
                 _aLog2[_nPos,06]:=_cErro
              ENDIF
              IF (_nPos:=ASCAN(_aLog,{|P| P[_nPosCodItem] == aItensGeraFil[L,_nPosColProd]} )) <> 0
                 _aLog[_nPos,01]:=EMPTY(_cErro)//.T. ou .F.
                 _aLog[_nPos,_nPosPedGer]:=_cPV
                 _aLog[_nPos,_nPosObs]:=_cErro
              ENDIF
          NEXT

       ENDIF   
       //REINICIA
       _cCnrtlFilRepo:=aItens[_nPosColFil]
       aItensGeraFil:={}

    ENDIF

    _nQtde2UM :=STRTRAN(aItens[_nPosColRepo],"." ,"" )  //Tira o ponto dos milhar
    _nQtde2UM :=VAL(STRTRAN(_nQtde2UM       ,"," ,".") )//Tira a virgula e poe o ponto para o val não comer a decimal

    _cPV:="  "
    _cErro:="  "
    IF _nQtde2UM = 0//QUANTIDADE DE REPOSICAO

       aItens[1]:=.F.
       AADD(aItens," ")//Ped. Gerado
       AADD(aItens,"Não tem necessidade de repor ainda")//

	ELSEIF !EMPTY( aItens[_nPosColFil] ) .AND. aItens[_nPosColAcao] = "3"//listados

       aItens[1]:=.F.
       AADD(aItens," ")//Ped. Gerado
       AADD(aItens,"A acao desse item é so listar")//Observação

    ELSEIF !EMPTY( aItens[_nPosColFil] )//FILIAL DE REPOSICAO

        _cMensagem:=""
	    If (Z09->(DBSEEK(xFilial()+         aItens[_nPosColFil]+cFilAnt  +"20"+aItens[_nPosColProd] ))   .OR.;
		    Z09->(DBSEEK(xFilial()+SPACE(LEN(aItens[_nPosColFil]+cFilAnt))+"20"+aItens[_nPosColProd] )) ) .AND.;
		   (DATE() >= Z09->Z09_INIVIG .AND. DATE() <= Z09->Z09_FIMVIG) 
		ELSE  
     		_cMensagem+="Prod.: "+aItens[_nPosColProd]+" sem Preco na tabela de tranferencia"
         IF !EMPTY(Z09->Z09_INIVIG)
		       _cMensagem+=" ou fora da data de vigencia: de "+DTOC(Z09->Z09_INIVIG)+" ate "+DTOC(Z09->Z09_FIMVIG)
         ENDIF
	      _cMensagem+=CHR(13)+CHR(10)
	    ENDIF
        
	    IF _nQtde2UM > 99999 // não pode ser maior que (99.999) noventa e nove mil e novecentos e noventa e nove pq estora o campo 
   		   _cMensagem+="Prod.: "+aItens[_nPosColProd]+" com quantidade na 2a U.M. maior que 99.999 "+CHR(13)+CHR(10)
	    ENDIF

	    SB1->(DbSeek(xFilial()+aItens[_nPosColProd]))
	    If SB1->B1_I_CXPAL <> 0
		   If mod(_nQtde2UM,SB1->B1_I_CXPAL) > 0
		      _nqtv := int(_nQtde2UM /SB1->B1_I_CXPAL) + 1
		   ELSE
			   _nqtv := int(_nQtde2UM /SB1->B1_I_CXPAL)
		   ENDIF
	    ENDIF

	    IF _nqtv > 999 // não pode ser maior que (999) novecentos e noventa e nove pq estora o campo 
   		   _cMensagem+="Prod.: "+aItens[_nPosColProd]+"  com quantidade de Pallet maior que 999 "
	    ENDIF

        IF EMPTY(_cMensagem)
           AADD(aItensGeraFil,_aLinhas[_nI])
        ENDIF
        AADD(aItens," ")//Ped. Gerado
        AADD(aItens,_cMensagem)//Observação
        _lEnviaEnailLog:=.T.
       
    ELSE   //SEM FILIAL DE REPOSICAO MAS COM QUANTIDADE
       aItens[1]:=.F.
       AADD(aItens," ")//Ped. Gerado
       AADD(aItens,"GERAR MANUAL, pois não foi indicada a Filial de reposição")//Observação
       
    ENDIF

//PEDIDOS DOS PRODUTOS NO E-MAIL
    aItens2:={}
    AADD(aItens2, aItens[1] )              //1-Gerado
    AADD(aItens2, aItens[_nPosColFil] )    //2-Filial
    AADD(aItens2, " " )                    //3-Pedido
    AADD(aItens2, aItens[3]+"-"+aItens[4] )//4-Produto
    AADD(aItens2, aItens[_nPosColRepo] )   //5-Quantidade
    AADD(aItens2, aItens[_nPosObs] )       //6-Erro
    AADD(aItens2, aItens[03] )             //7-Para pesquisar no ASCAN()

    AADD(_aLog2,aItens2)
//PEDIDOS DOS PRODUTOS NO E-MAIL

//DETALHAMENTO DOS PRODUTOS NO E-MAIL
    aItens[4]:=LEFT(aItens[4],32)
    AADD(aItens, aItens[03] ) //21 - para pesquisar no ASCAN()

    AADD(_aLog,aItens)
//DETALHAMENTO DOS PRODUTOS NO E-MAIL
   

NEXT

IF !EMPTY(_cCnrtlFilRepo) .AND. LEN(aItensGeraFil) > 0
	_aRet :=AOMSCriaPed(_cCnrtlFilRepo, aItensGeraFil,_lSchedule )
	_cPV  :=_aRet[1]
	_cErro:=_aRet[2]
	
	IF !EMPTY(_cPV) .AND. ASCAN(_aLog,{|P| P[_nPosPedGer]==_cPV}) = 0
		_nQtdePV++
	ENDIF
	
	FOR L := 1 TO LEN(aItensGeraFil)
		IF (nPos:=ASCAN(_aLog2,{|P| P[7] == aItensGeraFil[L,_nPosColProd]} )) <> 0
			_aLog2[nPos,01]:=EMPTY(_cErro)//SE EM BRANCO .T. GEROU
			_aLog2[nPos,03]:=_cPV
			_aLog2[nPos,06]:=_cErro
		ENDIF
		IF (_nPos:=ASCAN(_aLog,{|P| P[_nPosCodItem] == aItensGeraFil[L,_nPosColProd]} )) <> 0
			_aLog[_nPos,01]:=EMPTY(_cErro)//SE EM BRANCO .T. GEROU
			_aLog[_nPos,_nPosPedGer]:=_cPV
			_aLog[_nPos,_nPosObs]:=_cErro
		ENDIF
	NEXT
ENDIF

If !_lSchedule .AND. LEN(_aLog) > 0
   _cTitAux:="GERACAO DOS PEDIDOS"
   _cMsgTop:="Tempo de execução: Hr. Inicial: "+_cTimeIni+", Hr. Final: "+TIME()
	aBotoes:={}
	AADD( aBotoes , { "" , {|| FWMSGRUN(,{|oProc|  AOMS116EML(.T., _aLog,oProc,_aLog2,_aPts) },"Enviando E-MAIL...") }, "" , "Envia E-MAIL"  } )
   AADD( aBotoes , { "" , {|| AVISO("ATENCAO",oLbxAux:aArray[oLbxAux:nAt][ LEN(_aLog[1])-1 ],{"Fechar"},3) }	, "" , "Ver Erro"		  } )

//   ITListBox(_cTitAux , _aHeader , _aCols , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca)
   U_ITLISTBOX(_cTitAux , _aCab    , _aLog  , .T.      , 4      , _cMsgTop ,          , _aSize  ,         ,     ,        , aBotoes  ,       , )

ELSEIF _lSchedule .AND. LEN(_aLog) > 0

   IF _lEnviaEnailLog//SÓ SE GEROU OU TENTOU GERAR
      AOMS116EML(.F., _aLog,,_aLog2,_aPts)//ENVIA E-MAIL DEPOIS DE GERAR 
   ENDIF

ENDIF   

Z09->(DBSETORDER(1))

RETURN .T.
/*
===============================================================================================================================
Programa--------: AOMS116L
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: EXECUTAS AS SELECTS CONFORME AS REGRAS
==================================================================================================================================
Parametros------: oProc , _cTipo
==================================================================================================================================
*/
STATIC Function AOMS116L(oProc,_cTipo)
LOCAL cQuery1:=""
LOCAL cQuery2:=""
LOCAL cQuery3:=""
LOCAL cQuery4:=""
LOCAL nDias  :=Z19->Z19_DIAS
LOCAL _aStru :={}

IF oProc <> nil
   oProc:cCaption:="Criando Temporario..."
   ProcessMessages()
ENDIF

aAdd(_aStru,{"FILIAL"	,"C",GetSX3Cache("B1_FILIAL","X3_TAMANHO"),0})
aAdd(_aStru,{"PRODUTO"	,"C",LEN(SB1->B1_COD),00})
aAdd(_aStru,{"DESCRI"	,"C",LEN(SB1->B1_DESC),0})
aAdd(_aStru,{"QTDE_C"	,"N",17,2})
aAdd(_aStru,{"QTDE_E"	,"N",17,2})
aAdd(_aStru,{"QTDE_T"	,"N",17,2})
aAdd(_aStru,{"QTDE_PT"	,"N",17,2})
aAdd(_aStru,{"QTDE_RE"	,"N",17,2})
aAdd(_aStru,{"QTDE_P3"	,"N",17,2})
aAdd(_aStru,{"FILREPO"	,"C",GetSX3Cache("B1_FILIAL","X3_TAMANHO"),0})

_oTempTable:=FWTemporaryTable():New( _cTRB, _aStru )
_oTempTable:AddIndex( "01", {"FILIAL","FILREPO","PRODUTO"} )
_oTempTable:Create()

IF oProc <> nil
   oProc:cCaption:="1/4-Lendo CARTEIRA..."
   ProcessMessages()
ENDIF

IF _cTipo = "1" //1=Reposicao entre Filiais
   cQuery1+="  SELECT C6_FILIAL FILIAL,C6_PRODUTO PRODUTO,C6_DESCRI DESCRI,SUM (C6_UNSVEN) QTDE_C , 0 QTDE_E , 0 QTDE_T , 0 QTDE_PT , 0 QTDE_P3"+ENTER
   cQuery1+="    FROM " + RetSqlName("SC6")+" SC6, " + RetSqlName("SC5")+" SC5, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SB1")+" SB1 "+ENTER
   cQuery1+="   WHERE     C6_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery1+="         AND C6_NOTA = ' '      "+ENTER
   cQuery1+="         AND C5_FILIAL = C6_FILIAL "+ENTER
   cQuery1+="         AND C5_NUM = C6_NUM "+ENTER
   cQuery1+="         AND C5_EMISSAO >= '"+DTOS(DATE()-nDias)+"'"+ENTER
   cQuery1+="         AND F4_FILIAL = C6_FILIAL"+ENTER
   cQuery1+="         AND F4_CODIGO = C6_TES    "
   cQuery1+="         AND F4_ESTOQUE = 'S'      "
   cQuery1+="         AND B1_COD = C6_PRODUTO   "
   cQuery1+="         AND B1_TIPO = 'PA'        "
   cQuery1+="         AND SC5.D_E_L_E_T_ = ' '"
   cQuery1+="         AND SF4.D_E_L_E_T_ = ' '  "
   cQuery1+="         AND SC6.D_E_L_E_T_ = ' '"
   cQuery1+="         AND SB1.D_E_L_E_T_ = ' '  "+ENTER
   cQuery1+="         AND C6_LOCAL IN " + FormatIn(ALLTRIM(Z19->Z19_LOCAL),";")+ENTER
   cQuery1+="         AND EXISTS (SELECT 'x' FROM "+RetSqlName("Z20")+" Z20 "+ENTER
   cQuery1+="                     WHERE Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "
   cQuery1+="                       AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "
   cQuery1+="                       AND Z20_COD    = SC6.C6_PRODUTO "
   cQuery1+="                       AND Z20_MSBLQL <> '1' "
   cQuery1+="                       AND Z20.D_E_L_E_T_ = ' ') "+ENTER
   cQuery1+=" GROUP BY C6_FILIAL, C6_PRODUTO, C6_DESCRI "+ENTER
   cQuery1+=" ORDER BY 2"

ELSEIF _cTipo = "2" //2=Operador Logistico

   cQuery1+="  SELECT C6_FILIAL FILIAL,C6_PRODUTO PRODUTO,C6_DESCRI DESCRI,SUM (C6_UNSVEN) QTDE_C , 0 QTDE_E , 0 QTDE_T , 0 QTDE_PT , 0 QTDE_P3 "+ENTER
   cQuery1+="    FROM " + RetSqlName("SC6")+" SC6, " + RetSqlName("SC5")+" SC5, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SB1")+" SB1, "+RetSqlName("CC2")+" CC2 "+ENTER
   cQuery1+="   WHERE      C6_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery1+="          AND C6_NOTA = ' '"+ENTER
   cQuery1+="          AND C5_FILIAL = C6_FILIAL"+ENTER
   cQuery1+="          AND C5_NUM = C6_NUM"+ENTER
   cQuery1+="          AND C5_EMISSAO >= '"+DTOS(DATE()-nDias)+"'"+ENTER
   IF Z19->(FIELDPOS("Z19_OPERAC")) <> 0 .AND. !EMPTY(Z19->Z19_OPERAC)
      cQuery1+="       AND C5_I_OPER  IN " + FormatIn(ALLTRIM(Z19->Z19_OPERAC),";")+ENTER
   ELSE
      cQuery1+="       AND C5_I_OPER = '12' "+ENTER
   ENDIF
   cQuery1+="          AND F4_FILIAL = C6_FILIAL"+ENTER
   cQuery1+="          AND F4_CODIGO = C6_TES"+ENTER
   cQuery1+="          AND F4_ESTOQUE = 'S'"+ENTER
   cQuery1+="          AND B1_COD = C6_PRODUTO"+ENTER
   cQuery1+="          AND B1_TIPO = 'PA'"+ENTER
   cQuery1+="          AND CC2_FILIAL = ' '"+ENTER
   cQuery1+="          AND CC2_EST = C5_I_EST"+ENTER
   cQuery1+="          AND CC2_CODMUN = C5_I_CMUN"+ENTER
   cQuery1+="          AND SC5.D_E_L_E_T_ = ' '"+ENTER
   cQuery1+="          AND SF4.D_E_L_E_T_ = ' '"+ENTER
   cQuery1+="          AND SC6.D_E_L_E_T_ = ' '"+ENTER
   cQuery1+="          AND SB1.D_E_L_E_T_ = ' '"+ENTER
   cQuery1+="          AND CC2.D_E_L_E_T_ = ' '"+ENTER
   cQuery1+="          AND C6_LOCAL IN " + FormatIn(ALLTRIM(Z19->Z19_LOCAL),";")+ENTER
   //cQuery1+="          AND C6_LOCAL IN ('50', '52')
   IF !EMPTY(Z19->Z19_OPERAD)
      cQuery1+="       AND CC2_I_OPCO = '"+Z19->Z19_OPERAD+"' "
      cQuery1+="       AND CC2_I_OPLO = '"+Z19->Z19_OPELOJ+"' "
   ENDIF
   cQuery1+="          AND EXISTS"+ENTER
   cQuery1+="                 (SELECT 'x'"+ENTER
   cQuery1+="                    FROM Z20010 Z20"+ENTER
   cQuery1+="                     WHERE Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "
   cQuery1+="                       AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "
   cQuery1+="                         AND Z20_COD = SC6.C6_PRODUTO"+ENTER
   cQuery1+="                         AND Z20_MSBLQL <> '1'"+ENTER
   cQuery1+="                         AND Z20.D_E_L_E_T_ = ' ')"+ENTER
   cQuery1+=" GROUP BY C6_FILIAL, C6_PRODUTO, C6_DESCRI"+ENTER
   cQuery1+=" ORDER BY 2"+ENTER

ENDIF
_cAlias:=GetNextAlias()
MPSysOpenQuery( cQuery1 , _cAlias ) 
AOMS116A(oProc,_cAlias,_cTRB)//GRAVA O SELECT (_cAlias) NA TABELA (_cTRB)
(_cAlias)->(DBCLOSEAREA())

IF oProc <> nil
   oProc:cCaption:="2/4-Lendo ESTOQUE 1/2 ..."
   ProcessMessages()
ENDIF

IF _cTipo = "1" //1=Reposicao entre Filiais
   cQuery2+=" SELECT B2_FILIAL FILIAL, B2_COD PRODUTO, B1_DESC DESCRI, 0 QTDE_C , SUM(B2_QATU) QTDE_E , 0 QTDE_T , 0 QTDE_PT , 0 QTDE_P3  "+ENTER
   cQuery2+=" FROM "+RetSqlName("SB2")+" SB2, "+RetSqlName("SB1")+" SB1 "+ENTER
   cQuery2+=" WHERE B2_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery2+="   AND SB2.D_E_L_E_T_ = ' ' "+ENTER
   cQuery2+="   AND B1_COD    = B2_COD "+ENTER
   cQuery2+="   AND B1_TIPO   = 'PA' "+ENTER
   cQuery2+="   AND SB1.D_E_L_E_T_ = ' ' "+ENTER
   cQuery2+="   AND B2_LOCAL IN " + FormatIn(ALLTRIM(Z19->Z19_LOCAL),";")+ENTER
   cQuery2+="   AND EXISTS (SELECT 'x' FROM "+RetSqlName("Z20")+" Z20 "+ENTER
   cQuery2+="                     WHERE Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery2+="                       AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery2+="                       AND Z20_COD    = SB2.B2_COD "+ENTER
   cQuery2+="                       AND Z20_MSBLQL <> '1'  "+ENTER
   cQuery2+="                       AND Z20.D_E_L_E_T_ = ' ') "+ENTER
   cQuery2+=" GROUP BY B2_FILIAL, B2_COD, B1_DESC  HAVING SUM(B2_QATU) <> 0 "+ENTER
   cQuery2+=" ORDER BY B2_COD "

ELSEIF _cTipo = "2" //2=Operador Logistico
   cQuery2+=" SELECT B6_FILIAL FILIAL, B6_PRODUTO PRODUTO, B1_DESC DESCRI, 0 QTDE_C , SUM(B6_SALDO) QTDE_E , 0 QTDE_T , 0 QTDE_PT , 0 QTDE_P3  "+ENTER
   cQuery2+=" FROM "+RetSqlName("SB6")+" SB6, "+RetSqlName("SB1")+" SB1 "+ENTER
   cQuery2+=" WHERE B6_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery2+="          AND B6_TIPO = 'E'
   cQuery2+="          AND B6_PODER3 = 'R'
   cQuery2+="          AND B6_SALDO <> 0
   cQuery2+="          AND SB6.D_E_L_E_T_ = ' '
   cQuery2+="          AND B1_COD = B6_PRODUTO
   cQuery2+="          AND B1_TIPO = 'PA'
   cQuery2+="          AND SB1.D_E_L_E_T_ = ' '
   cQuery2+="          AND B6_LOCAL IN " + FormatIn(ALLTRIM(Z19->Z19_LOCAL),";")+ENTER
   IF !EMPTY(Z19->Z19_OPERAD)
      cQuery2+="          AND B6_CLIFOR = '"+Z19->Z19_OPERAD+"' "
      cQuery2+="          AND B6_LOJA = '"+Z19->Z19_OPELOJ+"' "
   ENDIF
   cQuery2+="          AND EXISTS
   cQuery2+="                 (SELECT 'x'
   cQuery2+="                    FROM Z20010 Z20
   cQuery2+="                     WHERE Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery2+="                       AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery2+="                         AND Z20_COD = SB6.B6_PRODUTO
   cQuery2+="                         AND Z20_MSBLQL <> '1'
   cQuery2+="                         AND Z20.D_E_L_E_T_ = ' ')
   cQuery2+=" GROUP BY B6_FILIAL, B6_PRODUTO, B1_DESC
   cQuery2+="   HAVING SUM (B6_SALDO) <> 0
   cQuery2+=" ORDER BY B6_PRODUTO

ENDIF
cQueryP2:=cQuery2

_cAlias:=GetNextAlias()
MPSysOpenQuery( cQuery2 , _cAlias) 
AOMS116A(oProc,_cAlias ,_cTRB)//GRAVA O SELECT (_cAlias) NA TABELA (_cTRB)
(_cAlias)->(DBCLOSEAREA())


IF _cTipo = "1" //1=Reposicao entre Filiais

   IF oProc <> nil
      oProc:cCaption:="2/4-Lendo ESTOQUE PODER 3o 2/2..."
      ProcessMessages()
   ENDIF

   cQuery2:=" SELECT B6_FILIAL FILIAL, B6_PRODUTO PRODUTO, B1_DESC DESCRI, 0 QTDE_C , 0 QTDE_E , 0 QTDE_T , 0 QTDE_PT , SUM(B6_SALDO) QTDE_P3  "+ENTER
   cQuery2+=" FROM "+RetSqlName("SB6")+" SB6, "+RetSqlName("SB1")+" SB1 "+ENTER
   cQuery2+=" WHERE B6_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery2+="          AND B6_TIPO = 'E'
   cQuery2+="          AND B6_PODER3 = 'R'
   cQuery2+="          AND B6_SALDO <> 0
   cQuery2+="          AND SB6.D_E_L_E_T_ = ' '
   cQuery2+="          AND B1_COD = B6_PRODUTO
   cQuery2+="          AND B1_TIPO = 'PA'
   cQuery2+="          AND SB1.D_E_L_E_T_ = ' '
// cQuery2+="          AND B6_LOCAL IN " + FormatIn(ALLTRIM(Z19->Z19_LOCAL),";")+ENTER
   cQuery2+="          AND EXISTS
   cQuery2+="                 (SELECT 'x'
   cQuery2+="                    FROM Z20010 Z20
   cQuery2+="                     WHERE Z20_FILIAL   = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery2+="                       AND Z20_REGRA    = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery2+="                         AND Z20_COD    = SB6.B6_PRODUTO "
   cQuery2+="                         AND Z20_FORN3O = SB6.B6_CLIFOR "
   cQuery2+="                         AND Z20_FO3OLJ = SB6.B6_LOJA "
   cQuery2+="                         AND Z20_PODER3 = '1' "
   cQuery2+="                         AND Z20_MSBLQL <> '1' "
   cQuery2+="                         AND Z20.D_E_L_E_T_ = ' ')
   cQuery2+=" GROUP BY B6_FILIAL, B6_PRODUTO, B1_DESC
   cQuery2+="   HAVING SUM (B6_SALDO) <> 0
   cQuery2+=" ORDER BY B6_PRODUTO
   cQueryP3:=cQuery2
    _cAlias:=GetNextAlias()
    MPSysOpenQuery( cQuery2 , _cAlias) 
    AOMS116A(oProc,_cAlias ,_cTRB)//GRAVA O SELECT (_cAlias) NA TABELA (_cTRB)
    (_cAlias)->(DBCLOSEAREA())

ELSEIF _cTipo = "2" //2=Operador Logistico
    cQueryP3:=""
ENDIF

IF _cTipo = "1" //1=Reposicao entre Filiais

   IF oProc <> nil
      oProc:cCaption:="3/4-Lendo TRANSITO..."
      ProcessMessages()
   ENDIF


   cQuery3+=" SELECT D2_COD PRODUTO, '"+Z19->Z19_FILIAL+"' FILIAL,  ' ' DESCRI, 0 QTDE_C , 0 QTDE_E , SUM(D2_QTSEGUM) QTDE_T , 0 QTDE_PT , 0 QTDE_P3  "+ENTER
   cQuery3+="    FROM "+RetSqlName("SD2")+" SD2, "+ENTER
   cQuery3+="         "+RetSqlName("SC5")+" SC5, "+ENTER
   cQuery3+="         "+RetSqlName("ZZM")+" ZZMO,"+ENTER
   cQuery3+="         "+RetSqlName("ZZM")+" ZZMD,"+ENTER
   cQuery3+="         "+RetSqlName("SA1")+" SA1, "+ENTER
   cQuery3+="         "+RetSqlName("SF4")+" SF4  "+ENTER
   cQuery3+="   WHERE     ZZMO.ZZM_FILIAL = ' '  "+ENTER
   cQuery3+="         AND ZZMO.ZZM_CODIGO = D2_FILIAL "+ENTER
   cQuery3+="         AND ZZMO.D_E_L_E_T_ = ' '  "+ENTER
   cQuery3+="         AND ZZMD.ZZM_FILIAL = ' ' "+ENTER
   cQuery3+="         AND ZZMD.ZZM_CODIGO = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery3+="         AND ZZMD.D_E_L_E_T_ = ' ' "+ENTER
   cQuery3+="         AND A1_FILIAL = ' ' "+ENTER
   cQuery3+="         AND A1_CGC = ZZMD.ZZM_CGC "+ENTER
   cQuery3+="         AND ZZMO.ZZM_CODIGO <> ZZMD.ZZM_CODIGO "+ENTER
   cQuery3+="         AND SA1.D_E_L_E_T_ = ' ' "+ENTER
   cQuery3+="         AND D2_EMISSAO >= '"+DTOS(DATE()-nDias)+"'"+ENTER
   cQuery3+="         AND D2_CLIENTE = A1_COD "+ENTER
   cQuery3+="         AND D2_LOJA = A1_LOJA "+ENTER
   cQuery3+="         AND SD2.D_E_L_E_T_ = ' ' "+ENTER
   cQuery3+="         AND C5_FILIAL = D2_FILIAL "+ENTER
   cQuery3+="         AND C5_NUM = D2_PEDIDO "+ENTER
   cQuery3+="         AND C5_I_OPER = '20' "+ENTER
   cQuery3+="         AND C5_I_TRCNF <> 'S' "+ENTER
   cQuery3+="         AND SC5.D_E_L_E_T_ = ' ' "+ENTER
   cQuery3+="         AND F4_FILIAL = D2_FILIAL "+ENTER
   cQuery3+="         AND F4_CODIGO = D2_TES "+ENTER
   cQuery3+="         AND F4_ESTOQUE = 'S' "+ENTER
   cQuery3+="         AND SF4.D_E_L_E_T_ = ' '"+ENTER
   cQuery3+="         AND EXISTS "+ENTER
   cQuery3+="                (SELECT 'x' "+ENTER
   cQuery3+="                   FROM  "+RetSqlName("Z20")+" Z20 "+ENTER
   cQuery3+="                  WHERE     Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery3+="                        AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery3+="                        AND Z20_COD = SD2.D2_COD "+ENTER
   cQuery3+="                        AND Z20_MSBLQL <> '1' "+ENTER
   cQuery3+="                        AND Z20.D_E_L_E_T_ = ' ')"+ENTER
   cQuery3+="         AND NOT EXISTS "+ENTER
   cQuery3+="                    (SELECT 'x' FROM "+RetSqlName("SD1")+" SD1A,  "+RetSqlName("SF4")+" SF4 "+ENTER 
   cQuery3+="                      WHERE     SD1A.D1_FILIAL = D2_FILIAL "+ENTER
   cQuery3+="                            AND SD1A.D1_TIPO = 'D' "+ENTER
   cQuery3+="                            AND SD1A.D1_FORNECE = D2_CLIENTE "+ENTER
   cQuery3+="                            AND SD1A.D1_LOJA = D2_LOJA "+ENTER
   cQuery3+="                            AND SD1A.D1_COD = D2_COD "+ENTER
   cQuery3+="                            AND SD1A.D1_NFORI = D2_DOC "+ENTER
   cQuery3+="                            AND SD1A.D1_SERIORI = D2_SERIE "+ENTER
   cQuery3+="                            AND SD1A.D1_TES <> ' ' "+ENTER
   cQuery3+="                            AND SD1A.D1_FORMUL = 'S' "+ENTER
   cQuery3+="                            AND SD1A.D_E_L_E_T_ = ' ' "+ENTER
   cQuery3+="                            AND F4_FILIAL = SD1A.D1_FILIAL "+ENTER
   cQuery3+="                            AND F4_CODIGO = D1_TES "+ENTER
   cQuery3+="                            AND F4_ESTOQUE = 'S' "+ENTER
   cQuery3+="                            AND SF4.D_E_L_E_T_ = ' ')  "+ENTER
   cQuery3+="         AND NOT EXISTS "+ENTER
   cQuery3+="                    (SELECT 'x' FROM "+RetSqlName("SD1")+" SD1R,  "+RetSqlName("SF4")+" SF4 "+ENTER 
   cQuery3+="                      WHERE     SD1R.D1_FILIAL = ZZMD.ZZM_CODIGO "+ENTER
   cQuery3+="                            AND SD1R.D1_FORNECE = "+ENTER
   cQuery3+="                                   (SELECT A2_COD FROM  "+RetSqlName("SA2")+" SA2 "+ENTER
   cQuery3+="                                     WHERE     A2_FILIAL = ' ' "+ENTER
   cQuery3+="                                           AND A2_CGC = ZZMO.ZZM_CGC
   cQuery3+="                                           AND A2_I_CLASS = 'F' "+ENTER
   cQuery3+="                                           AND SA2.D_E_L_E_T_ = ' ') "+ENTER
   cQuery3+="                            AND SD1R.D1_LOJA = "+ENTER
   cQuery3+="                                   (SELECT A2_LOJA FROM "+RetSqlName("SA2")+" SA2 "+ENTER 
   cQuery3+="                                     WHERE     A2_FILIAL = ' ' "+ENTER
   cQuery3+="                                           AND A2_CGC = ZZMO.ZZM_CGC "+ENTER
   cQuery3+="                                           AND A2_I_CLASS = 'F' "+ENTER
   cQuery3+="                                           AND SA2.D_E_L_E_T_ = ' ') "+ENTER
   cQuery3+="                            AND SD1R.D1_DOC = D2_DOC "+ENTER
   cQuery3+="                            AND SD1R.D1_SERIE = D2_SERIE "+ENTER
   cQuery3+="                            AND SD1R.D1_COD = D2_COD "+ENTER
   cQuery3+="                            AND SD1R.D1_TES <> ' ' "+ENTER
   cQuery3+="                            AND SD1R.D_E_L_E_T_ = ' ' "+ENTER
   cQuery3+="                            AND F4_FILIAL = SD1R.D1_FILIAL "+ENTER
   cQuery3+="                            AND F4_CODIGO = SD1R.D1_TES "+ENTER
   cQuery3+="                            AND F4_ESTOQUE = 'S' "+ENTER
   cQuery3+="                            AND SF4.D_E_L_E_T_ = ' ') "+ENTER
   cQuery3+=" GROUP BY D2_COD "+ENTER
   cQuery3+=" ORDER BY 1 "
   
   _cAlias:=GetNextAlias()
   MPSysOpenQuery( cQuery3 , _cAlias) 
   AOMS116A(oProc,_cAlias ,_cTRB)//GRAVA O SELECT (_cAlias) NA TABELA (_cTRB)
   (_cAlias)->(DBCLOSEAREA())

//ELSEIF _cTipo = "2" //2=Operador Logistico

ENDIF


IF oProc <> nil
   oProc:cCaption:="4/4-Lendo PED. TRANSFERENCIA 1/2..."
   ProcessMessages()
ENDIF

IF _cTipo = "1" //1=Reposicao entre Filiais
   cQuery4+=" SELECT C6_PRODUTO PRODUTO, '"+Z19->Z19_FILIAL+"' FILIAL,  C6_DESCRI DESCRI, 0 QTDE_C , 0 QTDE_E , 0 QTDE_T , SUM(C6_UNSVEN) QTDE_PT , 0 QTDE_P3  "+ENTER
   cQuery4+="    FROM "+RetSqlName("SC6")+" SC6, "+ENTER
   cQuery4+="         "+RetSqlName("SC5")+" SC5, "+ENTER
   cQuery4+="         "+RetSqlName("ZZM")+" ZZMO,"+ENTER
   cQuery4+="         "+RetSqlName("ZZM")+" ZZMD,"+ENTER
   cQuery4+="         "+RetSqlName("SA1")+" SA1, "+ENTER
   cQuery4+="         "+RetSqlName("SF4")+" SF4  "+ENTER
   cQuery4+="   WHERE     ZZMO.ZZM_FILIAL = ' ' "+ENTER
   cQuery4+="         AND ZZMO.ZZM_CODIGO = C6_FILIAL
   cQuery4+="         AND ZZMO.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND ZZMD.ZZM_FILIAL = ' ' "+ENTER
   cQuery4+="         AND ZZMD.ZZM_CODIGO = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery4+="         AND ZZMD.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND A1_FILIAL = ' ' "+ENTER
   cQuery4+="         AND A1_CGC = ZZMD.ZZM_CGC "+ENTER
   cQuery4+="         AND ZZMO.ZZM_CODIGO <> ZZMD.ZZM_CODIGO "+ENTER
   cQuery4+="         AND SA1.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND C6_CLI = A1_COD "+ENTER
   cQuery4+="         AND C6_LOJA = A1_LOJA "+ENTER
   cQuery4+="         AND C6_NOTA = ' ' "+ENTER
   cQuery4+="         AND SC6.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND C5_FILIAL = C6_FILIAL "+ENTER
   cQuery4+="         AND C5_NUM = C6_NUM "+ENTER
   cQuery4+="         AND C5_I_OPER = '20' "+ENTER
   cQuery4+="         AND C5_I_TRCNF <> 'S' "+ENTER
   cQuery4+="         AND C5_EMISSAO >= '"+DTOS(DATE()-nDias)+"'"+ENTER
   cQuery4+="         AND SC5.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND F4_FILIAL = C6_FILIAL "+ENTER
   cQuery4+="         AND F4_CODIGO = C6_TES "+ENTER
   cQuery4+="         AND F4_ESTOQUE = 'S' "+ENTER
   cQuery4+="         AND SF4.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND EXISTS "+ENTER
   cQuery4+="                (SELECT 'x' "+ENTER
   cQuery4+="                   FROM  "+RetSqlName("Z20")+" Z20 "+ENTER
   cQuery4+="                  WHERE     Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery4+="                        AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery4+="                        AND Z20_COD = SC6.C6_PRODUTO "+ENTER
   cQuery4+="                        AND Z20_MSBLQL <> '1' "+ENTER
   cQuery4+="                        AND Z20.D_E_L_E_T_ = ' ')"+ENTER
   cQuery4+="GROUP BY C6_PRODUTO, C6_DESCRI "+ENTER
   cQuery4+="ORDER BY 1 "
   cQueryPT:=cQuery4

   _cAlias:=GetNextAlias()
   MPSysOpenQuery( cQuery4 , _cAlias) 
   AOMS116A(oProc,_cAlias ,_cTRB)//GRAVA O SELECT (_cAlias) NA TABELA (_cTRB)
   (_cAlias)->(DBCLOSEAREA())

ELSEIF _cTipo = "2" //2=Operador Logistico
  
   cQuery4+=" SELECT C6_PRODUTO PRODUTO, '"+Z19->Z19_FILIAL+"' FILIAL,  C6_DESCRI DESCRI, 0 QTDE_C , 0 QTDE_E , 0 QTDE_T , SUM(C6_UNSVEN) QTDE_PT , 0 QTDE_P3  "+ENTER
   cQuery4+="    FROM "+RetSqlName("SC6")+" SC6, "+ENTER
   cQuery4+="         "+RetSqlName("SC5")+" SC5, "+ENTER
   cQuery4+="         "+RetSqlName("SF4")+" SF4  "+ENTER
   cQuery4+="       WHERE C6_FILIAL   = '"+Z19->Z19_FILIAL+"' "+ENTER
   IF !EMPTY(Z19->Z19_OPERAD)
      cQuery4+="      AND C6_CLI = '"+Z19->Z19_OPERAD+"' "
      cQuery4+="      AND C6_LOJA = '"+Z19->Z19_OPELOJ+"' "
   ENDIF
   cQuery4+="         AND SC6.C6_NOTA = ' ' "
   cQuery4+="         AND SC6.D_E_L_E_T_ = ' ' "
   cQuery4+="         AND SC5.C5_FILIAL = C6_FILIAL "
   cQuery4+="         AND SC5.C5_NUM = C6_NUM "
   cQuery4+="         AND SC5.C5_I_OPER = ' ' "
   cQuery4+="         AND SC5.C5_TIPO = 'B' "   
   cQuery4+="         AND C5_EMISSAO >= '"+DTOS(DATE()-nDias)+"'"+ENTER
   cQuery4+="         AND SC5.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND F4_FILIAL = C6_FILIAL "+ENTER
   cQuery4+="         AND F4_CODIGO = C6_TES "+ENTER
   cQuery4+="         AND F4_ESTOQUE = 'S' "+ENTER
   cQuery4+="         AND SF4.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND EXISTS "+ENTER
   cQuery4+="                (SELECT 'x' "+ENTER
   cQuery4+="                   FROM  "+RetSqlName("Z20")+" Z20 "+ENTER
   cQuery4+="                  WHERE     Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery4+="                        AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery4+="                        AND Z20_COD = SC6.C6_PRODUTO "+ENTER
   cQuery4+="                        AND Z20_MSBLQL <> '1' "+ENTER
   cQuery4+="                        AND Z20.D_E_L_E_T_ = ' ')"+ENTER
   cQuery4+="GROUP BY C6_PRODUTO, C6_DESCRI "+ENTER
   cQuery4+="ORDER BY 1 "
   cQueryPT:=cQuery4

   _cAlias:=GetNextAlias()
   MPSysOpenQuery( cQuery4 , _cAlias) 
   AOMS116A(oProc,_cAlias ,_cTRB)//GRAVA O SELECT (_cAlias) NA TABELA (_cTRB)
   (_cAlias)->(DBCLOSEAREA())

ENDIF

IF oProc <> nil
   oProc:cCaption:="4/4-Lendo PED. TRANSFERENCIA 2/2..."
   ProcessMessages()
ENDIF

IF _cTipo = "1" //1=Reposicao entre Filiais
   cQuery4:=""
   cQuery4+=" SELECT C6_NUM , C6_PRODUTO PRODUTO, C6_FILIAL FILIAL, C5_EMISSAO ,  C6_DESCRI DESCRI, SUM(C6_UNSVEN) QTDE_PT , 0 QTDE_P3  "+ENTER
   cQuery4+="    FROM "+RetSqlName("SC6")+" SC6, "+ENTER
   cQuery4+="         "+RetSqlName("SC5")+" SC5, "+ENTER
   cQuery4+="         "+RetSqlName("ZZM")+" ZZMO,"+ENTER
   cQuery4+="         "+RetSqlName("ZZM")+" ZZMD,"+ENTER
   cQuery4+="         "+RetSqlName("SA1")+" SA1, "+ENTER
   cQuery4+="         "+RetSqlName("SF4")+" SF4  "+ENTER
   cQuery4+="   WHERE     ZZMO.ZZM_FILIAL = ' ' "+ENTER
   cQuery4+="         AND ZZMO.ZZM_CODIGO = C6_FILIAL
   cQuery4+="         AND ZZMO.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND ZZMD.ZZM_FILIAL = ' ' "+ENTER
   cQuery4+="         AND ZZMD.ZZM_CODIGO = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery4+="         AND ZZMD.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND A1_FILIAL = ' ' "+ENTER
   cQuery4+="         AND A1_CGC = ZZMD.ZZM_CGC "+ENTER
   cQuery4+="         AND ZZMO.ZZM_CODIGO <> ZZMD.ZZM_CODIGO "+ENTER
   cQuery4+="         AND SA1.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND C6_CLI = A1_COD "+ENTER
   cQuery4+="         AND C6_LOJA = A1_LOJA "+ENTER
   cQuery4+="         AND C6_NOTA = ' ' "+ENTER
   cQuery4+="         AND SC6.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND C5_FILIAL = C6_FILIAL "+ENTER
   cQuery4+="         AND C5_NUM = C6_NUM "+ENTER
   cQuery4+="         AND C5_I_OPER = '20' "+ENTER
   cQuery4+="         AND C5_I_TRCNF <> 'S' "+ENTER
   cQuery4+="         AND C5_EMISSAO >= '"+DTOS(DATE()-nDias)+"'"+ENTER
   cQuery4+="         AND SC5.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND F4_FILIAL = C6_FILIAL "+ENTER
   cQuery4+="         AND F4_CODIGO = C6_TES "+ENTER
   cQuery4+="         AND F4_ESTOQUE = 'S' "+ENTER
   cQuery4+="         AND SF4.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND EXISTS "+ENTER
   cQuery4+="                (SELECT 'x' "+ENTER
   cQuery4+="                   FROM  "+RetSqlName("Z20")+" Z20 "+ENTER
   cQuery4+="                  WHERE     Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery4+="                        AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery4+="                        AND Z20_COD = SC6.C6_PRODUTO "+ENTER
   cQuery4+="                        AND Z20_MSBLQL <> '1' "+ENTER
   cQuery4+="                        AND Z20.D_E_L_E_T_ = ' ')"+ENTER
   cQuery4+="GROUP BY C6_FILIAL , C6_NUM ,C5_EMISSAO, C6_PRODUTO, C6_DESCRI "+ENTER
   cQuery4+="ORDER BY C6_PRODUTO ,  C6_FILIAL , C6_NUM "

   _cAlias2:=GetNextAlias()
   MPSysOpenQuery( cQuery4 , _cAlias2) 

ELSEIF _cTipo = "2" //2=Operador Logistico

   cQuery4:=""
   cQuery4+=" SELECT C6_NUM , C6_PRODUTO PRODUTO, C6_FILIAL FILIAL, C5_EMISSAO ,  C6_DESCRI DESCRI, SUM(C6_UNSVEN) QTDE_PT , 0 QTDE_P3  "+ENTER
   cQuery4+="    FROM "+RetSqlName("SC6")+" SC6, "+ENTER
   cQuery4+="         "+RetSqlName("SC5")+" SC5, "+ENTER
   cQuery4+="         "+RetSqlName("SF4")+" SF4  "+ENTER
   cQuery4+="       WHERE C6_FILIAL   = '"+Z19->Z19_FILIAL+"' "+ENTER
   IF !EMPTY(Z19->Z19_OPERAD)
      cQuery4+="      AND C6_CLI = '"+Z19->Z19_OPERAD+"' "
      cQuery4+="      AND C6_LOJA = '"+Z19->Z19_OPELOJ+"' "
   ENDIF
   cQuery4+="         AND SC6.C6_NOTA = ' ' "
   cQuery4+="         AND SC6.D_E_L_E_T_ = ' ' "
   cQuery4+="         AND SC5.C5_FILIAL = C6_FILIAL "
   cQuery4+="         AND SC5.C5_NUM = C6_NUM "
   cQuery4+="         AND SC5.C5_I_OPER = ' ' "
   cQuery4+="         AND SC5.C5_TIPO = 'B' "   
   cQuery4+="         AND SC5.C5_EMISSAO >= '"+DTOS(DATE()-nDias)+"'"+ENTER
   cQuery4+="         AND SC5.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND F4_FILIAL = C6_FILIAL "+ENTER
   cQuery4+="         AND F4_CODIGO = C6_TES "+ENTER
   cQuery4+="         AND F4_ESTOQUE = 'S' "+ENTER
   cQuery4+="         AND SF4.D_E_L_E_T_ = ' ' "+ENTER
   cQuery4+="         AND EXISTS "+ENTER
   cQuery4+="                (SELECT 'x' "+ENTER
   cQuery4+="                   FROM  "+RetSqlName("Z20")+" Z20 "+ENTER
   cQuery4+="                  WHERE     Z20_FILIAL = '"+Z19->Z19_FILIAL+"' "+ENTER
   cQuery4+="                        AND Z20_REGRA  = '"+Z19->Z19_REGRA+"' "+ENTER
   cQuery4+="                        AND Z20_COD = SC6.C6_PRODUTO "+ENTER
   cQuery4+="                        AND Z20_MSBLQL <> '1' "+ENTER
   cQuery4+="                        AND Z20.D_E_L_E_T_ = ' ')"+ENTER
   cQuery4+="GROUP BY C6_FILIAL , C6_NUM ,C5_EMISSAO, C6_PRODUTO, C6_DESCRI "+ENTER
   cQuery4+="ORDER BY C6_PRODUTO ,  C6_FILIAL , C6_NUM "

   _cAlias2:=GetNextAlias()
   MPSysOpenQuery( cQuery4 , _cAlias2) 

ENDIF


IF oProc <> nil
   oProc:cCaption:="GRAVANDO TEMPORARIO..."
   ProcessMessages()
ENDIF

AOMS116TRB(oProc,_cTRB,_cAlias2)//GRAVA O TRB (_cAlias) NA ARRAY (_aLinhas) e _cAlias2 na array _aPts

IF _cAlias2 <> NIL
   (_cAlias2)->(DBCLOSEAREA())
ENDIF

(_cTRB)->(DbClosearea())
_oTempTable:Delete()

_cTeste:="Tempo de execução: Hr. Inicial: "+_cTimeIni+", Hr. Final: "+TIME()+ENTER+ENTER
_cTeste+="CARTEIRA:  "+ENTER+cQuery1 +ENTER+ENTER
_cTeste+="ESTOQUE:   "+ENTER+cQueryP2+ENTER+ENTER
_cTeste+="ESTOQUE P3:"+ENTER+cQueryP3+ENTER+ENTER
_cTeste+="TRANSITO:  "+ENTER+cQuery3 +ENTER+ENTER
_cTeste+="PV TRANS:  "+ENTER+cQueryPT+ENTER+ENTER
_cTeste+="PV TRANS LISTA:"+ENTER+cQuery4+ENTER+ENTER
_cFileNome:="\DATA\ITALAC\CONTROLE\AOMS116_"+cFilAnt+"_"+STRTRAN(TIME(),":","_")+".TXT"
MemoWrite(_cFileNome,_cTeste)

RETURN .T.

/*
===============================================================================================================================
Programa--------: AOMS116A()
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: GRAVA O SELECT (_cAlias) NA TABELA (_cTRB)
==================================================================================================================================
Parametros------: oProc,_cAlias,_cTRB
==================================================================================================================================
*/
STATIC Function AOMS116A(oProc,_cAlias,_cTRB)
LOCAL _nConta := 0
LOCAL _cTot   :=""
LOCAL _nTam   :=5

DBSELECTAREA(_cAlias)
COUNT TO _nConta
_cTot  :=ALLTRIM(STR(_nConta))
_nTam  :=LEN(_cTot)
_nConta:=0

(_cAlias)->(DBGOTOP())
DO WHILE (_cAlias)->(!EOF())
	
	_nConta++
	_aItens:={}
	
	IF oProc <> nil
		oProc:cCaption := ("1/2-Gravando Temporario: "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
		ProcessMessages()
	ENDIF
    Z20->(DBSEEK((_cAlias)->FILIAL+Z19->Z19_REGRA+(_cAlias)->PRODUTO))
    IF  !(_cTRB)->(DBSEEK((_cAlias)->FILIAL+Z20->Z20_FILREP+(_cAlias)->PRODUTO))
         (_cTRB)->(DBAPPEND())
	     (_cTRB)->FILIAL :=(_cAlias)->FILIAL //02
	     (_cTRB)->PRODUTO:=(_cAlias)->PRODUTO//03
	     (_cTRB)->DESCRI :=ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+(_cAlias)->PRODUTO,"B1_DESC")) //04
	     (_cTRB)->FILREPO:=Z20->Z20_FILREP   //15
    ENDIF    
	(_cTRB)->QTDE_C +=(_cAlias)->QTDE_C  //05
	(_cTRB)->QTDE_E +=(_cAlias)->QTDE_E  //06
	(_cTRB)->QTDE_T +=(_cAlias)->QTDE_T  //07
	(_cTRB)->QTDE_PT+=(_cAlias)->QTDE_PT //08
	(_cTRB)->QTDE_P3+=(_cAlias)->QTDE_P3 //09
    (_cAlias)->(DBSKIP())

ENDDO  

RETURN .T.
/*
===============================================================================================================================
Programa--------: AOMS116TRB
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2019
==================================================================================================================================
Descrição-------: GRAVA O TRB (_cAlias) NA ARRAY (_aLinhas)
==================================================================================================================================
Parametros------: oProc,_cAlias
==================================================================================================================================
*/
STATIC Function AOMS116TRB(oProc,_cAlias,_cPTAlias)
LOCAL _nConta := 0
LOCAL _cTot   :=""
LOCAL _nTam   :=5
LOCAL _cPict  :="@E 999,999,999,999.99"

IF oProc <> nil
   oProc:cCaption:="Contando os dados lidos..."
   ProcessMessages()
ENDIF

DBSELECTAREA(_cAlias)
_nConta := 0
COUNT TO _nConta
_cTot:=ALLTRIM(STR(_nConta))
_nTam:=LEN(_cTot)
_nConta:=0

(_cAlias)->(DBGOTOP())
DO WHILE (_cAlias)->(!EOF())
	
	_nConta++
	_aItens:={}

    IF oProc <> nil
       oProc:cCaption := ("1/2-Gravando Temporario: "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
       ProcessMessages()
    ENDIF   

    Z20->(DBSEEK((_cAlias)->FILIAL+Z19->Z19_REGRA+(_cAlias)->PRODUTO))
    SB1->(DBSEEK(xFilial()+(_cAlias)->PRODUTO))
    
	If SB1->B1_CONV == 0
    	If SB1->B1_I_FATCO > 0	//SB1->B1_I_QQUEI == 'S' .and. 
    		_nfator := IF(SB1->B1_TIPCONV=="M" , SB1->B1_I_FATCO , 1/SB1->B1_I_FATCO )	
    	Else	
    		_nfator := 0		
    	Endif	
    Else
    	_nfator := IF(SB1->B1_TIPCONV=="M" , SB1->B1_CONV , 1/SB1->B1_CONV )	
    Endif
	(_cAlias)->QTDE_P3:= ( (_cAlias)->QTDE_P3*_nfator )//CONVERTO PARA A SEGUNDA UNIDADE DE MEDIDA
	(_cAlias)->QTDE_E := ( (_cAlias)->QTDE_E *_nfator )//CONVERTO PARA A SEGUNDA UNIDADE DE MEDIDA
    
    _nEstDisp:=(_cAlias)->QTDE_E+(_cAlias)->QTDE_P3+(_cAlias)->QTDE_T+(_cAlias)->QTDE_PT-(_cAlias)->QTDE_C
    _nQtdeaRepor:=nFator:=0
    IF Z20->Z20_ESTIDE >_nEstDisp
       _nQtdeaRepor:=Z20->Z20_ESTIDE-_nEstDisp
       nFator:=_nQtdeaRepor/Z20->Z20_MINREP
       IF nFator > INT(nFator)
          nFator:= INT(nFator)+1
       ENDIF
       (_cAlias)->QTDE_RE:=nFator*Z20->Z20_MINREP
    ENDIF  
    _nPeso := ( ((_cAlias)->QTDE_RE/_nfator) * SB1->B1_PESBRU )//CONVERTO PARA A PRIMEIRA UNIDADE E FAÇO X O PESO BRUTO
	AADD(_aItens, EMPTY((_cAlias)->QTDE_RE) )          //01// .T. NAÕ GERA .F. GERA
	AADD(_aItens,(_cAlias)->FILIAL)                    //02
	AADD(_aItens,ALLTRIM((_cAlias)->PRODUTO))          //03
	AADD(_aItens,(_cAlias)->DESCRI)                    //04
	AAdd(_aItens,TRANSFORM((_cAlias)->QTDE_RE,_cPict)) //05 //CALCULADO
	AAdd(_aItens,(_cAlias)->FILREPO)                   //06
	AAdd(_aItens,TRANSFORM((_cAlias)->QTDE_C ,_cPict)) //07
	AAdd(_aItens,TRANSFORM((_cAlias)->QTDE_E ,_cPict)) //08
	AAdd(_aItens,TRANSFORM((_cAlias)->QTDE_T ,_cPict)) //09
	AAdd(_aItens,TRANSFORM((_cAlias)->QTDE_PT,_cPict)) //10
	AAdd(_aItens,TRANSFORM(_nEstDisp         ,_cPict)) //11 //CALCULADO
	AAdd(_aItens,TRANSFORM(Z20->Z20_ESTIDE   ,_cPict)) //12
	AAdd(_aItens,TRANSFORM(Z20->Z20_MINREP   ,_cPict)) //13
	AAdd(_aItens,TRANSFORM(_nQtdeaRepor      ,_cPict)) //14 //CALCULADO
	AAdd(_aItens,TRANSFORM((_cAlias)->QTDE_P3,_cPict)) //15 // poder de terceiro novo
	AAdd(_aItens,TRANSFORM(nFator            ,_cPict)) //16 //CALCULADO
	AAdd(_aItens,TRANSFORM(_nPeso            ,_cPict)) //17 //CALCULADO - NOVO
	AAdd(_aItens,SB1->B1_SEGUM                       ) //18 - NOVO
	AAdd(_aItens,Z20->Z20_MSBLQL                     ) //19 - NOVO

    AADD(_aLinhas,_aItens)

	(_cAlias)->(DBSKIP())

ENDDO  

IF _cPTAlias <> NIL
   _cAlias:=_cPTAlias
   DBSELECTAREA(_cAlias)
   _nConta := 0
   COUNT TO _nConta
   _cTot:=ALLTRIM(STR(_nConta))
   _nTam:=LEN(_cTot)
   _nConta:=0
   _aPts:={}

    (_cAlias)->(DBGOTOP())
	_cProd:=""
    DO WHILE (_cAlias)->(!EOF())
    	
    	_nConta++
    	_aItens:={}
    
        IF oProc <> nil
           oProc:cCaption := ("2/2-Gravando Temporario: "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
           ProcessMessages()
        ENDIF   
//    	AADD(_aItens,ALLTRIM((_cAlias)->PRODUTO))       //01
        IF _cProd = (_cAlias)->PRODUTO
    	   AADD(_aItens," ")          //01
    	   AADD(_aItens," ")          //02
		ELSE
    	   AADD(_aItens,ALLTRIM((_cAlias)->PRODUTO))       //01
    	   AADD(_aItens,(_cAlias)->DESCRI)                 //02
		   _cProd:= (_cAlias)->PRODUTO
        ENDIF   
    	
		AADD(_aItens,(_cAlias)->FILIAL)                    //03
    	AADD(_aItens,(_cAlias)->C6_NUM)                    //04
		AADD(_aItens,DTOC(STOD((_cAlias)->C5_EMISSAO)))    //05
    	AAdd(_aItens,POSICIONE("SB1",1,XFILIAL("SB1")+(_cAlias)->PRODUTO,"B1_SEGUM"))//06
    	AAdd(_aItens,TRANSFORM((_cAlias)->QTDE_PT,_cPict)) //07
    
        AADD(_aPts,_aItens)
    
    	(_cAlias)->(DBSKIP())
    
    ENDDO  

ENDIF

RETURN .T.


/*
===============================================================================================================================
Programa----------: AOMS116EML()
Autor-------------: Alex Wallauer
Data da Criacao---: 11/11/2019
===============================================================================================================================
Descrição---------: Rotina para enviar e-mail de notificação 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function AOMS116EML(_lProcessa,_aLog,oProc,_aLog2,_aPts)

Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= '',_nI , E
Local _cData	:= Dtoc(DATE())
Local _cHoraT   := _cTimeIni
Local _cNomeFil := cFilant+" - "+AllTrim( Posicione('SM0',1,"01"+cFilant,'M0_FILIAL') )
Local _cAssunto := "Workflow - Execução das Regras de Reposição automatica de estoque, Regra: "+Z19->Z19_REGRA//1=Reposicao entre Filiais;2=Operador Logistico;3=Reposicao entre Armazens
Local _aEmail   := {}
Local _cEmail	:= ALLTRIM(Z19->Z19_EMAIL)
Local _cEmailCo := ""

If _lProcessa
   PswOrder(1)
   PswSeek(__cUserID,.T.)
   aUsuario:=PswRet()	
   _cEmailCo:=Alltrim(aUsuario[1,14])
Else
   If Empty(_cEmail)
	  U_ITConOut('Sem e-mail cadastrado, verifique o campo de de E-Mmail [Z19_EMAIL] da regra: '+Z19->Z19_REGRA)
      Return .F.
   EndIf
EndIf

_cMsgEml := '<html>'
_cMsgEml += '<head><title>'+(_cAssunto+" - "+Z19->Z19_DESC)+'</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += 'td.AZUL    { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #0000FF; }'
_cMsgEml += 'td.amarelo { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFF00; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center>Log de Processamento</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">'+(_cAssunto+" - "+Z19->Z19_DESC)+'</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Data:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cData +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora inicial:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cHoraT +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora final:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ TIME() +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
_cMsgEml += '      <td class="itens" >'+ _cNomeFil +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Observação:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >#OBS#</td>'
_cMsgEml += '    </tr>'
If !_lProcessa
    _cAssunto += " - "+_cNomeFil
    _cAssunto += ' - Processamento agendado (Schedule)'
   _cMsgEml += ' <tr>'
   _cMsgEml += '   <td class="titulos" align="center" colspan="2"><font color="red">Esta é uma mensagem automática. Por favor não responder!</font></td>'
   _cMsgEml += ' </tr>'
ENDIF
_cMsgEml += '</table>'

If _aLog2 # NIL .AND. !Empty(_aLog2)  .AND. Len( _aLog2 ) > 0
	
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1300">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(Len( _aLog2[1])))+'" class="grupos"><b>PEDIDOS DOS PRODUTOS</b></td>'
	_cMsgEml += '    </tr>'

	_aSizes:={"01","05","05","36","10","43"}

	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>Gerado</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>Filial</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>Pedido</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>Produto</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%"><b>Quantidade</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%"><b>Erro</b></td>'
	_cMsgEml += '    </tr>'

	If _lProcessa
       _nConta:= Len( _aLog2 )
       _cTot  :=ALLTRIM(STR(_nConta))
       _nTam  :=LEN(_cTot)
       _nConta:=0
	EndIf

	For _nI := 1 To Len( _aLog2 )
	    If _lProcessa
		   oProc:cCaption := ("1/1-Enviando Produto: "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
		   ProcessMessages()
	    EndIf
	    _nQtde2UM :=STRTRAN(_aLog2[_nI,5] ,"." ,"" )  //Tira o ponto dos milhar
        _nQtde2UM :=VAL(STRTRAN(_nQtde2UM            ,"," ,".") )//Tira a virgula e poe o ponto para o val não comer a decimal

		IF _nQtde2UM = 0 .OR. _aLog[_nI][_nPosColAcao] = "3"
		  //-RETIRA OS:
          //-Não tem necessidade de repor ainda
          //-A acao desse item é so listar
		  LOOP
		ENDIF

		_cMsgEml += '    <tr>'
		If _aLog2[_nI][01] 
		   _cMsgEml += '    <td class="aceito"  align="center" width="'+_aSizes[01]+'%"><b>Sim</b></td>'
		Else
		   _cMsgEml += '    <td class="recusa"  align="center" width="'+_aSizes[01]+'%"><b>Não</b></td>'
		EndIf
        _cMsgEml += '     <td class="itens" align="center" width="'+_aSizes[02]+'%">'+_aLog2[_nI][02]+'</td>'
        _cMsgEml += '     <td class="itens" align="center" width="'+_aSizes[03]+'%">'+_aLog2[_nI][03]+'</td>'
  	    _cMsgEml += '      <td class="itens" align="left"   width="'+_aSizes[04]+'%">'+_aLog2[_nI][04]+'</td>'
	    _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[05]+'%">'+_aLog2[_nI][05]+'</td>'
	    _cMsgEml += '      <td class="itens" align="left"   width="'+_aSizes[06]+'%">'+_aLog2[_nI][06]+'</td>'
		_cMsgEml += '    </tr>'
    	
	Next _nI
	
	_cMsgEml += '</table>'

    _aCab[01]:="Gerado"
ELSE
    _aCab[01]:="Repor"
EndIf
_cObsT:=""
////////////////////////    DETALHAMENTO DOS PRODUTOS   /////////////////////////////////////////////
If _aLog # NIL .AND. !Empty(_aLog)  .AND. Len( _aLog ) > 0
	//         01   02   03   04   05   06   07   08   09   10   11   12   13   14   15   16   17
	_aSizes:={"01","xx","50","xx","12","05","05","04","05","05","05","05","xx","05","05","05","05"}
	_aCab[16]:="Peso"

	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1900">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(Len(_aSizes)-3))+'" class="grupos"><b>DETALHAMENTO DOS PRODUTOS</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCab[01]+'</b></td>'
//	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCab[02]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>'+_aCab[03]+'</b></td>'
//	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>'+_aCab[04]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[17]+'%"><b>'+_aCab[17]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%"><b>'+_aCab[05]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[16]+'%"><b>'+_aCab[16]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%"><b>'+_aCab[06]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[07]+'%"><b>'+_aCab[07]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[08]+'%"><b>'+_aCab[08]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[09]+'%"><b>'+_aCab[09]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[10]+'%"><b>'+_aCab[10]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[11]+'%"><b>'+_aCab[11]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[12]+'%"><b>'+_aCab[12]+'</b></td>'
//	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[13]+'%"><b>'+_aCab[13]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[14]+'%"><b>'+_aCab[14]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[15]+'%"><b>'+_aCab[_nColPoder3o]+'</b></td>'
	_cMsgEml += '    </tr>'
	
	If _lProcessa
       _nConta:= Len( _aLog )
       _cTot  :=ALLTRIM(STR(_nConta))
       _nTam  :=LEN(_cTot)
       _nConta:=0
	EndIf

    _nCriado:=0
    _nNCriado:=0

	For _nI := 1 To Len( _aLog )
	    If _lProcessa
		   oProc:cCaption := ("1/1-Enviando Produto: "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
		   ProcessMessages()
	    EndIf

		_cMsgEml += '    <tr>'
        
		_cListar:=""
		IF _aLog[_nI][_nPosColAcao]  = "3"
		   _cListar:="(*)"
		ENDIF

	    _nEstoque :=STRTRAN(_aLog[_nI,_nPosColEst],"." , "" )  //Tira o ponto dos milhar
	    _nEstoque :=VAL(STRTRAN(_nEstoque         ,"," , ".") )//Tira a virgula e poe o ponto para o val não comer a decimal
    
	    _nCarteir :=STRTRAN(_aLog[_nI,_nPosColCar],"." , "" )  //Tira o ponto dos milhar
	    _nCarteir :=VAL(STRTRAN(_nCarteir         ,"," , ".") )//Tira a virgula e poe o ponto para o val não comer a decimal

		IF _aCab[01] = "Repor"// TELA ANTES DE GERAR
		   If _aLog[_nI][01] 
              _nNCriado++
		      If _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
		   	     _cMsgEml += '      <td class="amarelo" align="center" width="'+_aSizes[01]+'%"><b>Não'+_cListar+'</b></td>'
			  ELSE//ESTOQUE >= CARTEIRA
		         _cMsgEml += '      <td class="aceito" align="center" width="'+_aSizes[01]+'%"><b>Não'+_cListar+'</b></td>'
			  ENDIF
		   Else
		      _nCriado++
		      If _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
		   	     _cMsgEml += '      <td class="recusa" align="center" width="'+_aSizes[01]+'%"><b>Sim'+_cListar+'</b></td>'
			  ELSE//ESTOQUE >= CARTEIRA
		         _cMsgEml += '      <td class="AZUL" align="center" width="'+_aSizes[01]+'%"><b>Sim'+_cListar+'</b></td>'
			  ENDIF
		   EndIf
        ELSE//"Gerado" Tela depois de gerar e schedule // A LOGICA AQUI É INVERTIDA: O .T. GEROU E É VERDE, NA TELA ERA VERMELHO 
		   If _aLog[_nI][01] //O .T. GEROU PEDIDO É VERDE, NA TELA ERA VERMELHO
              _nCriado++
		      If _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
		   	     _cMsgEml += '      <td class="aceito" align="center" width="'+_aSizes[01]+'%"><b>Sim'+_cListar+'</b></td>'
			  ELSE//ESTOQUE > CARTEIRA
		         _cMsgEml += '      <td class="AZUL" align="center" width="'+_aSizes[01]+'%"><b>Sim'+_cListar+'</b></td>'
			  ENDIF
		   Else//E O .F. NÃO GEROU E É VERMELHO, NA TELA ERA VERDE 
              _nNCriado++
		      If _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
		         _cMsgEml += '      <td class="amarelo" align="center" width="'+_aSizes[01]+'%"><b>Não'+_cListar+'</b></td>'
			  ELSE//ESTOQUE > CARTEIRA
		         _cMsgEml += '      <td class="recusa" align="center" width="'+_aSizes[01]+'%"><b>Não'+_cListar+'</b></td>'
			  ENDIF
		   EndIf
		EndIf
//     _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%">'+_aLog[_nI][02]+'</td>'
       _cMsgEml += '      <td class="itens" align="left"   width="'+_aSizes[03]+'%">'+_aLog[_nI][03]+"-"+_aLog[_nI][04]+'</td>'
//	    _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[04]+'%">'+_aLog[_nI][04]+'</td>'
	    _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[17]+'%">'+_aLog[_nI][17]+'</td>'
	    _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[05]+'%">'+_aLog[_nI][05]+'</td>'
       _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[16]+'%">'+_aLog[_nI][16]+'</td>'
	    _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%">'+_aLog[_nI][06]+'</td>'
	    _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[07]+'%">'+_aLog[_nI][07]+'</td>'
    	 _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[08]+'%">'+_aLog[_nI][08]+'</td>'
	    _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[09]+'%">'+_aLog[_nI][09]+'</td>'
    	 _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[10]+'%">'+_aLog[_nI][10]+'</td>'
	    _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[11]+'%">'+_aLog[_nI][11]+'</td>'
    	 _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[12]+'%">'+_aLog[_nI][12]+'</td>'
//     _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[13]+'%">'+_aLog[_nI][13]+'</td>'
    	 _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[14]+'%">'+_aLog[_nI][14]+'</td>'
   	 _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[15]+'%">'+_aLog[_nI][_nColPoder3o]+'</td>'
		 _cMsgEml += '    </tr>'
        
    	
	Next _nI
////////////////////////    DETALHAMENTO DOS PRODUTOS   /////////////////////////////////////////////
	
	_cMsgEml += '</table>'

	IF _aCab[01] = "Repor"
       _cObsT:=STRZERO(_nCriado ,4)+' Produtos que precisam de reposição  = "Sim" (vermelho) '+CHR(13)+CHR(10)
       _cObsT+=STRZERO(_nNCriado,4)+' Produtos que NÃO precisam de reposição = "Não" (verde) '+CHR(13)+CHR(10)
    ELSE
       _cObsT:=STRZERO(_nCriado ,4)+' Produtos que geraram Pedidos ('+TRIM(STR(_nQtdePV))+') = "Sim" (verde) '+CHR(13)+CHR(10)
       _cObsT+=STRZERO(_nNCriado,4)+' Produtos que NÃO geraram Pedidos = "Não" (vermelho) '+CHR(13)+CHR(10)
    ENDIF   
    _cObsT+='(*) Produtos somente Listados e não processados'+CHR(13)+CHR(10)
	
EndIf

If _aPts # NIL .AND. !Empty(_aPts)  .AND. Len( _aPts ) > 0
	_aSizes:={"10","40","10","10","10","10","10"}

	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1300">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(Len(_aSizes)))+'" class="grupos"><b>DETALHAMENTO DOS PEDIDOS DE TRANSFERENCIA</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCabPT[01]+'</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCabPT[02]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>'+_aCabPT[03]+'</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>'+_aCabPT[04]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%"><b>'+_aCabPT[05]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%"><b>'+_aCabPT[06]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[07]+'%"><b>'+_aCabPT[07]+'</b></td>'
	_cMsgEml += '    </tr>'
	
	If _lProcessa
       _nConta:= Len( _aPts )
       _cTot  :=ALLTRIM(STR(_nConta))
       _nTam  :=LEN(_cTot)
       _nConta:=0
	EndIf

	For _nI := 1 To Len( _aPts )
	    If _lProcessa
		   oProc:cCaption := ("1/1-Enviando Produto: "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
		   ProcessMessages()
	    EndIf

		_cMsgEml += '    <tr>'
        _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%">'+_aPts[_nI][01]+'</td>'
        _cMsgEml += '      <td class="itens" align="left"   width="'+_aSizes[02]+'%">'+_aPts[_nI][02]+'</td>'
  	    _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%">'+_aPts[_nI][03]+'</td>'
	    _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%">'+_aPts[_nI][04]+'</td>'
	    _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%">'+_aPts[_nI][05]+'</td>'
	    _cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%">'+_aPts[_nI][06]+'</td>'
	    _cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[07]+'%">'+_aPts[_nI][07]+'</td>'
		_cMsgEml += '    </tr>'        
    	
	Next _nI
	
	_cMsgEml += '</table>'

EndIf

_cMsgEml += '</center>'
_cMsgEml += '    <br>'
_cMsgEml += '    <br>'
_cMsgEml += '    <br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [AOMS116]</td>'
_cMsgEml += '    </tr>'

_cMsgEml += '</body>'
_cMsgEml += '</html>'
_cEmlLog := ''

_cEmail:=STRTRAN(_cEmail,";",",")
_aEmail:=STRTOKARR(_cEmail,",")// Lista de email

_cMsgEml:=STRTRAN(_cMsgEml,"#OBS#",_cObsT)

_cFileNome:="\DATA\ITALAC\CONTROLE\AOMS116_"+cFilAnt+"_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".HTM"
MemoWrite(_cFileNome,_cMsgEml)

For E := 1 TO LEN(_aEmail)

    
    _cEmail:=_aEmail[E]
    U_ITConOut('Enviando E-mail(s) para: '+_cEmail+ " - Log de Processamento - "+TIME()+" - [ Enviando E-mail para Filial: "+cFilAnt+" ]")

    //    ITEnvMail(cFrom     ,cEmailTo ,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
    U_ITENVMAIL( _aConfig[01] , _cEmail ,_cEmailCo,         ,_cAssunto, _cMsgEml ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

    If !Empty( _cEmlLog )
       If _lProcessa
          U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+"E-mail para: "+_cEmail+CHR(13)+CHR(10)+"Com Copia: "+_cEmailCo,"Envio do E-MAIL",,2)
       Else
          U_ITConOut(_cEmlLog+CHR(13)+CHR(10)+" E-mails: "+_cEmail)
       EndIf
    EndIf

Next

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS115INV
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2019
===============================================================================================================================
Descrição---------: Rotina de duplo clique na linha do browse
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS116GET(oLbxAux)

Local _nLinPos  := oLbxAux:nAt
Local _bOK
LOCAL _cPict  :="@E 999,999,999.99"

If oLbxAux:nColPos == _nPosColRepo
	
    _bOK:={|| IF(_nQtde >= 0,.T.,(U_ITMSG("Quantidade INVALIDO",'Atenção!',"Tente novamente com valor maior que zero",3),.F.) ) }
	_nQtde :=STRTRAN(_aLinhas[_nLinPos,_nPosColRepo],".","") //Tira o ponto dos milhar
	_nQtde :=VAL(STRTRAN(_nQtde,",",".") )//Tira a virgula e poe o ponto para o val não comer a decimal
	lOK:=.F.
	@ 00,00 To 100,280 Dialog oDlgDes Title "Quantidade de Reposição"
	@ 11,10 say "Quantidade:" Pixel of oDlgDes
	@ 10,50 MsGet _nQtde Picture "@E 999,999,999.99"  Pixel Of oDlgDes
	@ 30,50 BMPBUTTON Type 1 ACTION (IF(EVAL(_bOK),(lOK:=.T.,Close(oDlgDes)),))
	@ 30,82 BMPBUTTON TYPE 2 ACTION Close(oDlgDes)
	Activate Dialog oDlgDes Center

   IF lOK
       _aLinhas[_nLinPos,_nPosColRepo]:=TRANSFORM(_nQtde,_cPict)
       oLbxAux:aArray[ _nLinPos , _nPosColRepo ] := TRANSFORM(_nQtde,_cPict)
       oLbxAux:aArray[ _nLinPos , 1 ] := (_nQtde = 0)       
   ENDIF

ELSEIf oLbxAux:nColPos == _nPosColFil
	
    _bOK:={|| EMPTY(_cFilRep) .OR. ExistCpo("SM0",cEmpAnt+_cFilRep,1) }
	_cFilRep:=_aLinhas[_nLinPos,_nPosColFil]
	lOK:=.F.
	@ 00,00 To 100,300 Dialog oDlgDes Title "Filial de Transferencia"
	@ 12,10 say "Filial:" Pixel of oDlgDes
	@ 10,48 MsGet _cFilRep Picture "!!"  Pixel Of oDlgDes SIZE 25, 10 F3 "SM0" //SM0001
	@ 30,50 BMPBUTTON Type 1 ACTION (IF(EVAL(_bOK),(lOK:=.T.,Close(oDlgDes)),))
	@ 30,82 BMPBUTTON TYPE 2 ACTION Close(oDlgDes)
	Activate Dialog oDlgDes Center

   IF lOK
       _aLinhas[_nLinPos,_nPosColFil]:=_cFilRep
       oLbxAux:aArray[ _nLinPos , _nPosColFil ] := _cFilRep
   ENDIF
   
ENDIF

//oLbxAux:Setarray(_aLinhas)
oLbxAux:Refresh()
PROCESSMESSAGES()

Return()


/*
===============================================================================================================================
Programa----------: AOMSCriaPed()
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2019
===============================================================================================================================
Descrição---------: Rotina de duplo clique na linha do browse
===============================================================================================================================
Parametros--------: _cFilRepo,_aItens,_lSchedule
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMSCriaPed(_cFilRepo,_aItens,_lSchedule)
LOCAL _cMensagem:=""  , P  , L
LOCAL cPV       :=""
LOCAL _aCabPV   :={}
LOCAL _aItensPV :={}
LOCAL _aItemPV  :={}
LOCAL nRecSM0   :=SM0->(RECNO())
LOCAL _nDias    :=0,_dDtEnt
LOCAL _cSalveFil:=cFilAnt//90 - Filial de Destino

//====================================================================================================
// BUSCA O TRANSATE TIME DA FILIAL ORIGEM
//====================================================================================================
cFilAnt:=_cFilRepo       //01 - Filial de Origem
SM0->(DBSETORDER(1) )
SM0->(DBSEEK(cEmpAnt + cFilAnt))//01 - Filial de Origem
SA1->(DBSETORDER(3))
SA1->(DBSEEK(xFilial("SA1")+SM0->M0_CGC))//01 - Filial de Origem
aHeader:={}
AADD(aHeader,{,"C6_ITEM"   })
AADD(aHeader,{,"C6_PRODUTO"})
AADD(aHeader,{,"C6_LOCAL"  })
acols:={{" "," "," "}}
_nDias := U_OMSVLDENT(DATE(),SA1->A1_COD,SA1->A1_LOJA,cFilAnt,"",1,.F.)//01 - Filial de Origem
_dDtEnt := (DATE() + _ndias + 1)

//====================================================================================================
// BUSCA O CLIENTE DA FILIAL DE DESTINO
//====================================================================================================
SM0->(DBSEEK(cEmpAnt + _cSalveFil))      //90 - Filial de Destino
SA1->(DBSEEK(xFilial("SA1")+SM0->M0_CGC))//90 - Filial de Destino CLIENTE

//====================================================================================================
// Monta o cabeçalho do pedido 
//====================================================================================================
SM0->(DBSEEK(cEmpAnt + cFilAnt))//VOLTA PARA 01 - Filial de Origem

Aadd( _aCabPV, { "C5_FILIAL "	,cFilAnt     , Nil})//FILIAL

IF Z19->Z19_TIPO = "2"//2=Operador Logistico

   SA2->(DBSETORDER(1))
   SA2->(DBSEEK(xFilial()+Z19->Z19_OPERAD+Z19->Z19_OPELOJ))
   Aadd( _aCabPV, { "C5_TIPO   "   ,"B"         , Nil})//Tipo de pedido
// Aadd( _aCabPV, { "C5_I_OPER "   ,"  "        , Nil})//Tipo da operacao
   Aadd( _aCabPV, { "C5_CLIENTE"	,SA2->A2_COD , NiL})//Codigo do cliente
   Aadd( _aCabPV, { "C5_LOJAENT"	,SA2->A2_LOJA, NiL})//Loja para entrada
   Aadd( _aCabPV, { "C5_LOJACLI"	,SA2->A2_LOJA, NiL})//Loja do cliente
   Aadd( _aCabPV, { "C5_TIPOCLI"	,"R", NiL})//Tipo do Cliente

ELSEIF Z19->Z19_TIPO = "1"//1=Reposicao entre Filiais
   
   Aadd( _aCabPV, { "C5_TIPO   "   ,"N"         , Nil})//Tipo de pedido
   Aadd( _aCabPV, { "C5_I_OPER "   ,"20"        , Nil})//Tipo da operacao
   Aadd( _aCabPV, { "C5_CLIENTE"	,SA1->A1_COD , NiL})//Codigo do cliente
   Aadd( _aCabPV, { "C5_LOJAENT"	,SA1->A1_LOJA, NiL})//Loja para entrada
   Aadd( _aCabPV, { "C5_LOJACLI"	,SA1->A1_LOJA, NiL})//Loja do cliente
   Aadd( _aCabPV, { "C5_TIPOCLI"	,SA1->A1_TIPO, NiL})//Tipo do Cliente

ENDIF

Aadd( _aCabPV, { "C5_EMISSAO"	,DATE()      , NiL})//Data de emissao
Aadd( _aCabPV, { "C5_CONDPAG"	,"001"       , NiL})//Codigo da condicao de pagamanto*
Aadd( _aCabPV, { "C5_VEND1  "   , SA1->A1_VEND												, Nil })
Aadd( _aCabPV, { "C5_VEND2  "   , Posicione('SA3',1,xFilial('SA3')+SA1->A1_VEND,'A3_SUPER')	, Nil })
Aadd( _aCabPV, { "C5_VEND3  "   , SA3->A3_GEREN												, Nil })
Aadd( _aCabPV, { "C5_I_DTENT"	,_dDtEnt     								                , Nil})//Dt de Entrega
Aadd( _aCabPV, { "C5_I_AGEND"	,"I"         								                , Nil})
Aadd( _aCabPV, { "C5_I_OBPED" 	,'Pedido de reposicao automatica de estoque - AOMS116'		, Nil })

_cLogCpos:="DATA: "+DTOC(DATE())+ " HORA: "+TIME()+ENTER+ENTER
_cLogCpos+="DADOS DA CAPA:"+ENTER
FOR P := 1 TO LEN(_aCabPV) 
    IF VALTYPE(_aCabPV[P,2]) = "D"
       _cLogCpos+=_aCabPV[P,1]+" = "+DTOC(_aCabPV[P,2])+ENTER
    ELSE   
       _cLogCpos+=_aCabPV[P,1]+" = "+_aCabPV[P,2]+ENTER
    ENDIF   
NEXT
_cLogCpos+=ENTER

//====================================================================================================
// Monta o item do pedido
//====================================================================================================
cPV:=""
_cMensagem:=""

BEGIN SEQUENCE

SB1->(DbSetOrder(1))
SBZ->(DbSetOrder(1))
Z09->(DBSETORDER(3)) // Z09_FILIAL+Z09_FILORI+Z09_FILDES+Z09_CODOPE+Z09_CODPRO 
FOR P := 1 TO LEN(_aItens)
	
	_nQtde2UM :=STRTRAN(_aItens[P,_nPosColRepo],".","") //Tira o ponto dos milhar
	_nQtde2UM :=VAL(STRTRAN(_nQtde2UM,",",".") )//Tira a virgula e poe o ponto para o val não comer a decimal
	_nPreco:=0
	SB1->(DbSeek(xFilial()+_aItens[P,_nPosColProd]))
	SBZ->(DbSeek(cFilAnt+SB1->B1_COD))
	
	IF SB1->B1_CONV = 0 //SB1->B1_I_QQUEI == 'S'//QUEIJOS
		nFator:=SB1->B1_I_FATCO
	ELSE
		nFator:=SB1->B1_CONV
	ENDIF
	
	If SB1->B1_TIPCONV == "D" // TIPO DE CONVERSAO INVERTIDA PQ É PARA VOLTAR PARA PRIMIERA
		_nQtd1UM := _nQtde2UM * nFator
	Else
		_nQtd1UM := _nQtde2UM / nFator
	EndIf
	
	If SB1->B1_I_CXPAL <> 0
		If mod(_nQtde2UM,SB1->B1_I_CXPAL) > 0
			_nqtv := int(_nQtde2UM /SB1->B1_I_CXPAL) + 1
		ELSE
			_nqtv := int(_nQtde2UM /SB1->B1_I_CXPAL)
		ENDIF
	ENDIF
	
	If (Z09->(DBSEEK(xFilial()+         cFilAnt+_cSalveFil  +"20"+SB1->B1_COD )) .OR.;
		Z09->(DBSEEK(xFilial()+SPACE(LEN(cFilAnt+_cSalveFil))+"20"+SB1->B1_COD )) ) .AND.;
		(DATE() >= Z09->Z09_INIVIG .AND. DATE() <= Z09->Z09_FIMVIG)
		_nPreco:=Z09->Z09_PRECO
	ELSE
		_cMensagem+="Prod.: "+SB1->B1_COD+" sem Preco na tabela de tranferencia"
      IF !EMPTY(Z09->Z09_INIVIG)
		   _cMensagem+=" ou fora da data de vigencia: de "+DTOC(Z09->Z09_INIVIG)+" ate "+DTOC(Z09->Z09_FIMVIG)
      ENDIF
	   _cMensagem+=CHR(13)+CHR(10)
	ENDIF
    
    IF _nqtv > 999 // não pode ser maior que (999) novecentos e noventa e nove pq estora o campo 
 	   _cMensagem+="Prod.: "+SB1->B1_COD+" com quantidade de Pallet maior que 999 "+CHR(13)+CHR(10)
    ENDIF
	
	_aItemPV:={}
	AAdd( _aItemPV , { "C6_ITEM   "  ,STRZERO(P,2)      , Nil }) // Numero do Item no Pedido
	AAdd( _aItemPV , { "C6_FILIAL "  ,cFilAnt           , Nil }) // FILIAL
	AAdd( _aItemPV , { "C6_PRODUTO"  ,SB1->B1_COD       , Nil }) // Codigo do Produto
	AAdd( _aItemPV , { "C6_QTDVEN "  ,_nQtd1UM          , Nil }) // Quantidade Vendida 1a U.M.
	AAdd( _aItemPV , { "C6_UNSVEN "  ,_nQtde2UM         , Nil }) // Quantidade Vendida 2a U.M.
	AAdd( _aItemPV , { "C6_PRCVEN "  ,_nPreco           , Nil }) // Preco Unitario Liquido
	AAdd( _aItemPV , { "C6_PRUNIT "  ,_nPreco           , Nil }) // Preco Unitario Liquido
	AAdd( _aItemPV , { "C6_ENTREG "  ,_dDtEnt           , Nil }) // Data da Entrega
	AAdd( _aItemPV , { "C6_VALOR  "  ,(_nPreco*_nQtd1UM), Nil }) // valor total do item
	AAdd( _aItemPV , { "C6_UM     "  ,SB1->B1_UM        , Nil }) // Unidade de Medida Primar.
   IF Z19->Z19_TIPO = "2"//2=Operador Logistico
	   AAdd( _aItemPV , { "C6_OPER"  ,"06"    , Nil }) // Tipo da operacao para gatilhar a TES
	   AAdd( _aItemPV , { "C6_LOCAL" ,"52"    , Nil }) // Almoxarifado
   ELSEIF Z19->Z19_TIPO = "1"//1=Reposicao entre Filiais
	   AAdd( _aItemPV , { "C6_LOCAL  "  ,SBZ->BZ_LOCPAD    , Nil }) // Almoxarifado
   ENDIF
	AAdd( _aItemPV , { "C6_I_QPALT"  ,_nqtv             , Nil }) // Almoxarifado
	
	_cLogCpos+="DADOS DO ITEM "+ALLTRIM(STR(P))+" :"+ENTER
	FOR L := 1 TO LEN(_aItemPV)
		IF VALTYPE(_aItemPV[L,2]) = "N"
			_cLogCpos+=_aItemPV[L,1]+" = "+STR(_aItemPV[L,2],20,5)+ENTER
        ELSEIF VALTYPE(_aItemPV[L,2]) = "D"
            _cLogCpos+=_aItemPV[L,1]+" = "+DTOC(_aItemPV[L,2])+ENTER
		ELSE
			_cLogCpos+=_aItemPV[L,1]+" = "+_aItemPV[L,2]+ENTER
		ENDIF
	NEXT
	_cLogCpos+="MESAGEM: ["+_cMensagem+"]"
	_cLogCpos+=ENTER	
	
	AAdd( _aItensPV ,_aItemPV )
	
NEXT

_cFileNome:="\DATA\ITALAC\CONTROLE\AOMS116_"+cFilAnt+"_"+ALLTRIM(_aItensPV[1,3,2])+".LOG"
MemoWrite(_cFileNome,_cLogCpos)
   
lMsErroAuto:=.F.
//====================================================================================================
// Geração do pedido de Carregamento NOVO
//====================================================================================================
IF EMPTY(_cMensagem)

   _cAOMS074   :="AOMS116"//DesAtiva o _lMsgEmTela := .F. no MT410TOK.PRW
   _cAOMS074Vld:=""//Pega as mensagens de erro
   IF _lSchedule
      MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 3 )
   ELSE
      FWMSGRUN(, { || MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 3 ) },"Aguarde...","Criando PEDIDO...")
   ENDIF  

ELSE

   BREAK

ENDIF   

If lMsErroAuto 
	
	If (__lSx8 )
	   RollBackSx8()
	EndIf
	
	IF EMPTY(_cMensagem)
	   _cMensagem:=_cAOMS074Vld+" ["+MostraErro( GETTEMPPATH() )+"] "
	ENDIF
	
ELSE
	
	cPV:=SC5->C5_NUM
	
ENDIF

IF EMPTY(_cMensagem)
   _cMensagem:=_cAOMS074Vld
ENDIF

END SEQUENCE

SM0->(DBGOTO(nRecSM0))
cFilAnt:=_cSalveFil

RETURN {cPV,_cMensagem,_aItensPV}


/*
===============================================================================================================================
Programa--------: Ver_Lib_AM
Autor-----------: Alex Wallauer
Data da Criacao-: 30/01/2020
===============================================================================================================================
Descrição-------: Verefica se no SC9 esta tudo OK ou tenta liberar o Pedido
===============================================================================================================================
Parametros------: oProc
==============================================================================================================================
Retorno---------: (.T.) ou (.F.)
===============================================================================================================================
*/
*====================================================================================================*
Static Function Ver_Est_AM(oProc,lEfetiva)
*====================================================================================================*
LOCAL _cQuery:=""
Local _cAlias:= GetNextAlias()
Local nPos:=0
Local _aResulAux:={}

Z20->(DBSEEK(Z19->Z19_FILIAL+Z19->Z19_REGRA))
cFil:=Z20->Z20_FILIAL

IF EMPTY(_aLinhas)

   _cProdutos:=""
	
	Do While Z20->( !EOF() ) .AND. Z20->Z20_FILIAL+Z20->Z20_REGRA == Z19->Z19_FILIAL+Z19->Z19_REGRA
		
		IF oProc <> nil
			oProc:cCaption := "Lendo Regra do Produto: "+Z20->Z20_COD
			ProcessMessages()
		EndIf
		
		IF Z20->Z20_MSBLQL = "1" 
			Z20->(DBSKIP())
			LOOP
		ENDIF
		
		_cProdutos+=Z20->Z20_COD +";"
		
		_aResulAux:={}
		AADD(_aResulAux, .F. )                //01
		AADD(_aResulAux, .F. )                //02
		AADD(_aResulAux,Z20->Z20_COD)         //03
		AADD(_aResulAux,POSICIONE("SB1",1,XFILIAL("SB1")+Z20->Z20_COD,"B1_DESC"))//04
		AADD(_aResulAux,SB1->B1_UM+" / "+SB1->B1_SEGUM)//05
		AAdd(_aResulAux,Z20->Z20_ESTIDE)      //06,"Est.Ideal 2 UM"
		AAdd(_aResulAux,Z20->Z20_MINREP)      //07,"Ped.Minimo"
		AAdd(_aResulAux,0)                    //08,"Qtde.Repor 2 RM "
		AAdd(_aResulAux,0)                    //09,"Atual 70 2 UM"
		AAdd(_aResulAux,0)                    //10,"Atual 72 2 UM"
		AAdd(_aResulAux,0)                    //11,"Arm 20 2 UM"
		AAdd(_aResulAux,0)                    //12,"Arm 22 2 UM"
		AAdd(_aResulAux,0)                    //13,"Acerto 70 1 UM"
		AAdd(_aResulAux,0)                    //14,"Acerto 70 2 UM"
		AAdd(_aResulAux,"")                   //15,"Acerto 70 3 UM"
		AAdd(_aResulAux,0)                    //16,"Acerto 72 1 UM"
		AAdd(_aResulAux,0)                    //17,"Acerto 72 2 UM"
		AAdd(_aResulAux,"")                   //18,"Acerto 72 3 UM"
		AAdd(_aResulAux,IF(Z20->Z20_MSBLQL="2","2-Repoe","3-Lista"))//19,ACAO
		AAdd(_aResulAux,"")                   //20,"Observação"
		
		AADD(_aLinhas,_aResulAux)
		
		Z20->( DBSKIP() )
		
	ENDDO
	
	IF EMPTY(_aLinhas)
		AADD(_aResulAux,.F.)//01
		AADD(_aResulAux,.F.)//02
		AADD(_aResulAux,"" )//03
		AADD(_aResulAux,"" )//04
		AADD(_aResulAux,"" )//05
		AAdd(_aResulAux,0)  //06,"Est.Ideal"
		AAdd(_aResulAux,0)  //07,"Ped.Minimo"
		AAdd(_aResulAux,0)  //08,"Qtde.Repor"
		AAdd(_aResulAux,0)  //09,"Atual 70"
		AAdd(_aResulAux,0)  //10,"Atual 72"å
		AAdd(_aResulAux,0)  //11,"Arm 20 2 UM"
		AAdd(_aResulAux,0)  //12,"Arm 22 2 UM"
		AAdd(_aResulAux,0)  //13,"Acerto 70 1 UM"
		AAdd(_aResulAux,0)  //14,"Acerto 70 2 UM"
		AAdd(_aResulAux,0)  //15,"Acerto 70 3 UM"
		AAdd(_aResulAux,0)  //16,"Acerto 72 1 UM"
		AAdd(_aResulAux,0)  //17,"Acerto 72 2 UM"
		AAdd(_aResulAux,0)  //18,"Acerto 72 3 UM"
		AAdd(_aResulAux,"") //19,ACAO
		AAdd(_aResulAux,"SEM REGRAS HABILITADAS PARA EXECUTAR")//20,"Observação"
		AADD(_aLinhas,_aResulAux)
		RETURN .F. /// ******************** RETORNA *******************************
	ENDIF

    _cProdutos:=LEFT(_cProdutos,LEN(_cProdutos)-1)

ENDIF

_cQuery += " SELECT DISTINCT B2_COD,"
_cQuery += "        NVL ((SELECT (B2_QATU - (B2_QEMP + B2_RESERVA + B2_QACLASS))"
_cQuery += "             FROM " + RetSqlName("SB2")+ " SB270"
_cQuery += "            WHERE     SB270.B2_FILIAL = SB2.B2_FILIAL"
_cQuery += "                  AND SB270.B2_COD = SB2.B2_COD"
_cQuery += "                  AND SB270.B2_LOCAL = '70' "
_cQuery += "                  AND SB270.D_E_L_E_T_ = ' '),0)  SALDO70,"
_cQuery += "       NVL ((SELECT (B2_QATU - (B2_QEMP + B2_RESERVA + B2_QACLASS))"
_cQuery += "             FROM " + RetSqlName("SB2")+ " SB272"
_cQuery += "            WHERE     SB272.B2_FILIAL = SB2.B2_FILIAL"
_cQuery += "                  AND SB272.B2_COD = SB2.B2_COD"
_cQuery += "                  AND SB272.B2_LOCAL = '72' "
_cQuery += "                  AND SB272.D_E_L_E_T_ = ' '),0)  SALDO72, "
_cQuery += "        NVL ((SELECT (B2_QATU - (B2_QEMP + B2_RESERVA + B2_QACLASS))"
_cQuery += "             FROM " + RetSqlName("SB2")+ " SB220"
_cQuery += "            WHERE     SB220.B2_FILIAL = SB2.B2_FILIAL"
_cQuery += "                  AND SB220.B2_COD = SB2.B2_COD"
_cQuery += "                  AND SB220.B2_LOCAL = '20' "
_cQuery += "                  AND SB220.D_E_L_E_T_ = ' '),0)  SALDO20,"
_cQuery += "       NVL ((SELECT (B2_QATU - (B2_QEMP + B2_RESERVA + B2_QACLASS))"
_cQuery += "             FROM " + RetSqlName("SB2")+ " SB222"
_cQuery += "            WHERE     SB222.B2_FILIAL = SB2.B2_FILIAL"
_cQuery += "                  AND SB222.B2_COD = SB2.B2_COD"
_cQuery += "                  AND SB222.B2_LOCAL = '22' "
_cQuery += "                  AND SB222.D_E_L_E_T_ = ' '),0)  SALDO22 "
_cQuery += "  FROM " + RetSqlName("SB2")+ " SB2 "
_cQuery += " WHERE     B2_FILIAL = '"+cFil+"' "
_cQuery += "       AND B2_COD IN "+FormatIn(_cProdutos,";")
_cQuery += "       AND B2_LOCAL IN ('70', '72','20', '22') "
_cQuery += "       AND SB2.D_E_L_E_T_ = ' ' "
_cQuery += "       ORDER BY B2_COD "

DBUSEAREA(.T., "TOPCONN", TCGenQry(,,_cQuery), _cAlias, .T., .F.)

//_cLOG:="QUERY: "+_cQuery+ENTER
//_cFileNome:="C:\SMARTCLIENT\AOMS016_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+".CSV"
//_cLOG:=STRTRAN(_cLOG,".",",")
//MemoWrite(_cFileNome,_cLOG)

IF oProc <> nil
   oProc:cCaption := "Calculando reposicao"
   ProcessMessages()
   COUNT TO _nConta
   _cTot  :=ALLTRIM(STR(_nConta))
   _nTam  :=LEN(_cTot)
   _nConta:=0
EndIf

DBSelectArea(_cAlias)
DBGOTOP()
DO WHILE (_cAlias)->(!EOF())

    If oProc <> nil
       _nConta++
	   oProc:cCaption := ("Calculando reposicao Prod: "+ALLTRIM((_cAlias)->B2_COD)+" / "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
	   ProcessMessages()
    EndIf

	IF (nPos:=ASCAN(_aLinhas, {|P| ALLTRIM(P[3]) == ALLTRIM((_cAlias)->B2_COD) } )) <> 0

       IF lEfetiva .AND. (!_aLinhas[nPos,1] .OR. !_aLinhas[nPos,2])//SE O USUARIO MARCOU PARA GERAR E SE É E VERDE
          _aLinhas[nPos,1]:=.F.//LEGENDA VERMELHO
          (_cAlias)->(DBSKIP())
          LOOP
       ENDIF	
		
		nSaldo70:=ConvUM(_aLinhas[nPos,3],(_cAlias)->SALDO70,0,.F.)//2 UM
		nSaldo72:=ConvUM(_aLinhas[nPos,3],(_cAlias)->SALDO72,0,.F.)//2 UM
		nSaldo20:=ConvUM(_aLinhas[nPos,3],(_cAlias)->SALDO20,0,.F.)//2 UM
		nSaldo22:=ConvUM(_aLinhas[nPos,3],(_cAlias)->SALDO22,0,.F.)//2 UM
		
		_n2EstDisp:=(nSaldo70+nSaldo72)//2 UM
		
		_nQtdeRepor:=nFator:=0
		_nEstIdeal :=_aLinhas[nPos,6]//Z20->Z20_ESTIDE//07,"Est.Ideal"
		_nPedMinimo:=_aLinhas[nPos,7]//Z20->Z20_MINREP//08,"Ped.Minimo"

		IF _nEstIdeal > _n2EstDisp
			
		   _nQtdeRepor:=(_nEstIdeal-_n2EstDisp)//2 UM
			nFator:=_nQtdeRepor/_nPedMinimo
			IF nFator > INT(nFator)
			   nFator:=INT(nFator)+1
			ENDIF
			_nQtdeRepor:=(nFator*_nPedMinimo)//"Qtde.Repor" inteiro// 2 um
			
		ENDIF

		_aLinhas[nPos,08]:=_nQtdeRepor //08,"Qtde.Repor" 
		_aLinhas[nPos,09]:=nSaldo70    //09,"Arm 70 2 UM"
		_aLinhas[nPos,10]:=nSaldo72    //10,"Arm 72 2 UM"
		_aLinhas[nPos,11]:=nSaldo20    //11,"Arm 20 2 UM"
		_aLinhas[nPos,12]:=nSaldo22    //12,"Arm 22 2 UM"

		nAcerto70:=0
		nAcerto72:=0
		_aLinhas[nPos,LEN(_aLinhas[nPos])]:=""//LIMPA PARA NAO ACUMULAR NA EFETIVACAO

        IF nSaldo20 > 0.AND. _nQtdeRepor > 0
           IF nSaldo20 > _nQtdeRepor
              nAcerto70:=_nQtdeRepor
              _nQtdeRepor:=0
           ELSE
              nAcerto70:=nSaldo20
              _nQtdeRepor:=(_nQtdeRepor-nSaldo20)
           ENDIF
	       _aLinhas[nPos,LEN(_aLinhas[nPos])]:="[ Pegou do 20 ]"
        ENDIF
        
        IF nSaldo22 > 0 .AND. _nQtdeRepor > 0
           IF nSaldo22 > _nQtdeRepor
              nAcerto72:=_nQtdeRepor
           ELSE
              nAcerto72:=nSaldo22
           ENDIF
	       _aLinhas[nPos,LEN(_aLinhas[nPos])]+="[ Pegou do 22 ]"
        ENDIF
        
		_n3Qtde:=0//Pega o valor dentro da ConvUM() se for usado
		_aLinhas[nPos,13]:=ConvUM(_aLinhas[nPos,3],0,@nAcerto70)    //"Acerto 70"--> 1UM
		_aLinhas[nPos,14]:=nAcerto70                                //"Acerto 70"--> 2UM
        IF _n3Qtde <> 0
		   _aLinhas[nPos,15]:=CVALTOCHAR(_n3Qtde)+" "+SB1->B1_I_3UM //"Acerto 70"--> 3UM
		ENDIF  

		_n3Qtde:=0//Pega o valor dentro da ConvUM() se for usado
		_aLinhas[nPos,16]:=ConvUM(_aLinhas[nPos,3],0,@nAcerto72)    //"Acerto 72"--> 1UM
		_aLinhas[nPos,17]:=nAcerto72                                //"Acerto 72"--> 2UM
        IF _n3Qtde <> 0
		   _aLinhas[nPos,18]:=CVALTOCHAR(_n3Qtde)+" "+SB1->B1_I_3UM //"Acerto 72"--> 3UM
		ENDIF  

        IF lEfetiva
           cRet:=""
           IF nAcerto70 > 0 
              cRet:=AOMS116Trans(_aLinhas[nPos,3],"20","70",_aLinhas[nPos,13],nAcerto70)//70
           ENDIF

           IF nAcerto72 > 0 
              cRet+=AOMS116Trans(_aLinhas[nPos,3],"22","72",_aLinhas[nPos,16],nAcerto72)//72
           ENDIF

           IF nAcerto70+nAcerto72 = 0            
              cRet:="Sem saldos para repor"
           ENDIF   

           _aLinhas[nPos,LEN(_aLinhas[nPos])]:=cRet

           IF "sucesso" $ cRet
              _aLinhas[nPos,1]:=.T.//LEGENDA VERDE
           ELSE   
              _aLinhas[nPos,1]:=.F.//LEGENDA VERMELHO
           ENDIF

        ELSEIF nAcerto70+nAcerto72 > 0

           _aLinhas[nPos,1]:=.T.//MARCA LINHA
           _aLinhas[nPos,2]:=.T.//LEGENDA VERDE
           IF LEFT(_aLinhas[nPos,19],1) = "3"//SÓ LISTA
              _aLinhas[nPos,1]:=.F.//MARCA LINHA
              _aLinhas[nPos,2]:=.F.//LEGENDA VERMELHA
		   ENDIF

        ELSEIF nAcerto70+nAcerto72 = 0

		   _aLinhas[nPos,LEN(_aLinhas[nPos])]:=""//LIMPA PQ PODE SER QUE O SALDO DOS ARMAGENS NÃO SEJA O SUFUCIENTE

        ENDIF
		
	ENDIF
	(_cAlias)->(DBSKIP())
ENDDO

(_cAlias)->(dbCloseArea())

IF lEfetiva

	IF Len(_aLinhas) > 0
	
	   _aCab[2]:="Filial"//A LEGENDA VIRA A FILIAL E O MARCA VIRA LEGENDA
	   _aColXML:={}
       FOR nPos:= 1 TO LEN(_aLinhas)
           _aLinhas[nPos,2]:=cFil//A LEGENDA VIRA A FILIAL E O MARCA VIRA LEGENDA
           AADD(_aColXML,ACLONE(_aLinhas[nPos]))
           _aColXML[nPos,1]:=IF(_aColXML[nPos,1],"ALTERADO","")
       NEXT
       _cTitAux:="TRANSFERENCIA DE ARMAZENS"
	   nPosResu:=LEN(_aLinhas[1])
	   aBotoes:={}
	   AADD( aBotoes , { "" , {|| AVISO("ATENCAO",oLbxAux:aArray[oLbxAux:nAt][ nPosResu ],{"Fechar"},3) }	, "" , "Ver Resultado"		  } )
		
	//         ITListBox(_cTitAux , _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca)
	   lRet:=U_ITLISTBOX(_cTitAux , _aCab    , _aLinhas  , .T.      , 4      , _cMsgTop ,          , _aSize  ,         ,     ,        , aBotoes  ,       ,        , _aColXML )

    ENDIF

ENDIF

RETURN .T.


/*
===============================================================================================================================
Programa--------: ConvUM()
Autor-----------: Alex Wallauer
Data da Criacao-: 04/02/2020
===============================================================================================================================
Descrição-------: Devolve a 2UM
===============================================================================================================================
Parametros------: cProd,_nQtde,_n2Qtde,lInteira
==============================================================================================================================
Retorno---------: _n2Qtde
===============================================================================================================================
*/
*====================================================================================================*
Static Function ConvUM(cProd,_nQtde,_n2Qtde,lInteira)
*====================================================================================================*
LOCAL nFator := 0
LOCAL nNewFat:= 0
Local _cCrtl3Um := "N"

DEFAULT lInteira := .T.

SB1->(dbSeek(xFilial("SB1")+AllTrim(cProd)))
nFator := SB1->B1_CONV
nNewFat:= SB1->B1_I_FATCO
nFator := (If(nFator = 0, nNewFat, nFator))
	
IF _n2Qtde = 0 .AND. _nQtde <> 0//DEVOLVE A SEGNDA UNIDADE    **************************************
	
   _cCrtl3Um := Posicione("SBZ",1,xFilial("SBZ")+cProd,"BZ_I_PR3UM")
      
	If lInteira .AND. _cCrtl3Um == "S" //(AllTrim(cProd) $ _cPrd3Um)
		
		_n3Qtde:=(_nQtde / SB1->B1_I_QT3UM)//CALCULA A 3UM
		
		If _n3Qtde <> Int(_n3Qtde)
			
			_n3Qtde:=Int(_n3Qtde)//PEGA SÓ O INTEIRO DA 3UM
			
			_nQtde:=(_n3Qtde*SB1->B1_I_QT3UM)//RECACULA A 1UM COM A 3UM INTEIRA
			
		EndIf
		
	ENDIF
	
	IF SB1->B1_TIPCONV = 'D'
		_n2Qtde:=(_nQtde/nFator)//CALCULA A 2UM
	ELSE
		_n2Qtde:=(_nQtde*nFator)//CALCULA A 2UM
	ENDIF
	
	RETURN _n2Qtde
	
ELSEIF _nQtde = 0 .AND. _n2Qtde <> 0//DEVOLVE A PRIMEIRA UNIDADE    **************************************
	_cCrtl3Um := Posicione("SBZ",1,xFilial("SBZ")+cProd,"BZ_I_PR3UM")

	If _cCrtl3Um == "S" //(AllTrim(cProd) $ _cPrd3Um) //Calcula a 1um
		
	   IF SB1->B1_TIPCONV = 'D'
		  _nQtde:=(_n2Qtde*nFator)//CACULA A 1UM COM A 2UM INTEIRA
	   	  nFatorUM:=SB1->B1_I_QT3UM / nFator
	   ELSE
	   	  _nQtde:=(_n2Qtde/nFator)//CACULA A 1UM COM A 2UM INTEIRA
	   	  nFatorUM:=SB1->B1_I_QT3UM * nFator
	   ENDIF

	   _n3Qtde:=(_nQtde / SB1->B1_I_QT3UM)//CALCULA A 3UM

	   If !lInteira 
	      RETURN _nQtde
	   ENDIF
	
	   If _n3Qtde <> Int(_n3Qtde)
		  _n3Qtde:=Int(_n3Qtde)//PEGA SÓ O INTEIRO DA 3UM			
	   EndIf

	   _nQtde:=(_n3Qtde*SB1->B1_I_QT3UM)//**RECACULA** A 1UM COM A 3UM INTEIRA

	   IF SB1->B1_TIPCONV = 'D'
	      _n2Qtde:=(_nQtde/nFator)//RECALCULA A 2UM
	   ELSE
	      _n2Qtde:=(_nQtde*nFator)//RECALCULA A 2UM
	   ENDIF
		
	ELSE
		
		IF lInteira .AND. _n2Qtde <> Int(_n2Qtde)
		   _n2Qtde:=Int(_n2Qtde)
		ENDIF

		IF SB1->B1_TIPCONV = 'D'
			_nQtde:=(_n2Qtde*nFator)//CACULA A 1UM COM A 2UM INTEIRA
		ELSE
			_nQtde:=(_n2Qtde/nFator)//CACULA A 1UM COM A 2UM INTEIRA
		ENDIF
		
	ENDIF
	
	RETURN _nQtde
	
ENDIF

RETURN 0

/*
===============================================================================================================================
Programa--------: AOMS116Trans()
Autor-----------: Alex Wallauer
Data da Criacao-: 30/01/2020
===============================================================================================================================
Descrição-------: Verefica se no SC9 esta tudo OK ou tenta liberar o Pedido
===============================================================================================================================
Parametros------: cProduto,cArmOri,cArmDest,nQtde,n2UMQtde
==============================================================================================================================
Retorno---------: (.T.) ou (.F.)
===============================================================================================================================
*/
*====================================================================================================*
Static Function AOMS116Trans(cProduto,cArmOri,cArmDest,nQtde,n2UMQtde)
*====================================================================================================*
Local _cFilVld34:= U_ITGETMV( 'IT_FILVLD34','')

//****** Cabecalho a Incluir ***
cDoc:=GetSxENum("SD3","D3_DOC",1)
aAuto:={}
AADD(aAuto,{cDoc,dDataBase})  //Cabecalho

//****** Cabecalho a Incluir ***

//****** Itens a Incluir  ******
SB1->(Dbsetorder(1))
SB1->(DBSEEK(xFilial()+cProduto)) 
aItem:={}
// ORIGEM
AADD(aItem,cProduto)    //D3_COD
AADD(aItem,SB1->B1_DESC)//D3_DESCRI
AADD(aItem,SB1->B1_UM)  //D3_UM
AADD(aItem,cArmOri)     //D3_LOCAL
AADD(aItem,"")		    //D3_LOCALIZ //Endereço Orig
// DESTINO
AADD(aItem,cProduto)    //D3_COD
AADD(aItem,SB1->B1_DESC)//D3_DESCRI
AADD(aItem,SB1->B1_UM)  //D3_UM
AADD(aItem,cArmDest)    //D3_LOCAL
AADD(aItem,"")		    //D3_LOCALIZ //Endereço Dest
AADD(aItem,"")          //D3_NUMSERI
AADD(aItem,"")  	    //D3_LOTECTL
AADD(aItem,"")         	//D3_NUMLOTE
AADD(aItem,CTOD(""))	//D3_DTVALID
AADD(aItem,0)		    //D3_POTENCI
AADD(aItem,nQtde)       //D3_QUANT
AADD(aItem,n2UMQtde)	//D3_QTSEGUM
AADD(aItem,"")          //D3_ESTORNO
AADD(aItem,"")      	//D3_NUMSEQ
AADD(aItem,"")  	    //D3_LOTECTL
AADD(aItem,CTOD(""))	//D3_DTVALID
AADD(aItem,"")	 	    //D3_ITEMGRD
AADD(aItem,"")	 	    //D3_OBSERVA  //Observação C        30
//Campos Customizados:
AADD(aItem,"")	 	    //D3_I_OBS    // Observação C       254 		
  If ! cFilant $ _cFilVld34 // Este campo não deve estar disponível para filiais de validação do armazém 34 (Descarte).
     //Aadd(aHeader, {'Tipo TRS'        ,'D3_I_TPTRS' , PesqPict('SD3', 'D3_I_TPTRS' , 1) , 1, 0, '', USADO, 'C', '', ''})
     //Aadd(aHeader, {'Descric.Tipo TRS','D3_I_DSCTM' , PesqPict('SD3', 'D3_I_DSCTM' , 1) , 1, 0, '', USADO, 'C', '', ''})
   AADD(aItem,"")	 	              //D3_I_TPTRS  // Mot.Tran.R C  1
   AADD(aItem,"")	 	              //D3_I_DSCTM  // Des.Mot.Tr C  1
  EndIf 
  If cFilant $ _cFilVld34 // Este campo não deve estar disponível para filiais de validação do armazém 34 (Descarte).
 //Aadd(aHeader, {'Mot.Tran.Ref','D3_I_MOTTR' , PesqPict('SD3', 'D3_I_MOTTR' , 01) , 08, 0, '', USADO, 'C', '', ''})        
 //Aadd(aHeader, {'Des.Mot.Tr.R','D3_I_DSCMT' , PesqPict('SD3', 'D3_I_DSCMT' , 01) , 40, 0, '', USADO, 'C', '', ''})  
 //Aadd(aHeader, {'Origem Trf.' ,'D3_I_SETOR' , PesqPict('SD3', 'D3_I_SETOR' , 40) , 40, 0, '', USADO, 'C', '', ''}) 
 //Aadd(aHeader, {'Destino'     ,'D3_I_DESTI' , PesqPict('SD3', 'D3_I_DESTI' , 40) , 40, 0, '', USADO, 'C', '', ''}) 
   AADD(aItem,"")	 	          //D3_I_MOTTR  // Mot.Tran.R C         8 
   AADD(aItem,"")	 	          //D3_I_DSCMT  // Des.Mot.Tr C        40 
   AADD(aItem,"")	 	          //D3_I_SETOR  // Origem Trf C        40 
   AADD(aItem,"")	 	          //D3_I_DESTI  // Destino    C        40 
EndIf 
//****** Itens a Incluir  ******

AADD(aAuto,aItem)

lMsErroAuto := .F.

MSExecAuto({|x,y| MATA261(x,y)},aAuto,3)

If lMsErroAuto   //Para recepção automatica esta dentro de transacao
	If __lSx8
		RollBackSX8()
	EndIf
   _cMensagem:="Erro ao transferir da "+cArmOri+" p/ "+cArmDest
   _cMensagem+=" [ "+ALLTRIM(MostraErro(GETTEMPPATH()))+" ]"
Else
	ConfirmSX8()
	_cMensagem:="[ Transferido com sucesso da "+cArmOri+" p/ "+cArmDest+" ]"
EndIf

RETURN _cMensagem

/*
===============================================================================================================================
Programa--------: CADSB1()
Autor-----------: Alex Wallauer
Data da Criacao-: 06/02/2020
===============================================================================================================================
Descrição-------: VERSB1
===============================================================================================================================
Parametros------: Nenhum
==============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function CADSB1(oLbxAux)

Local _nLinPos  := oLbxAux:nAt
Local _aArea:= GetArea()
Private cCadastro:= OemToAnsi( "Visualizar" )

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

If SB1->(dbSeek(  xFILIAL("SB1") + _aLinhas[_nLinPos,_nPosColProd] ))
   AxVisual( "SB1", SB1->( Recno() ), 2 )
EndIf

RestArea( _aArea )        

Return

/*
===============================================================================================================================
Programa--------: AOMS13PT()
Autor-----------: Alex Wallauer
Data da Criacao-: 28/04/2021
===============================================================================================================================
Descrição-------: LISTA DOS PEDIDOS DE TRANSFERICIA 
===============================================================================================================================
Parametros------: _aPts
==============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function AOMS13PT(_aPts)
LOCAL _aSize:={"15","40","10","10","10","15"}
LOCAL _cMsgTop:=NIL
LOCAL _cTitAux:="PEDIDOS DE TRANSFERNCIA DOS PRODUTOS"

	//         ITListBox(_cTitAux, _aHeader , _aCols , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca)
	   lRet:=U_ITLISTBOX(_cTitAux, _aCabPT  , _aPts  , .F.      , 1      , _cMsgTop ,          , _aSize  ,         ,     ,        ,          ,       ,        ,          ,           )

RETURN .T.
/*
===============================================================================================================================
Programa--------: AOMS13PT()
Autor-----------: Alex Wallauer
Data da Criacao-: 29/04/2021
===============================================================================================================================
Descrição-------: DEVOLVE AS CORES PARA A LEGENDA
===============================================================================================================================
Parametros------: _aCol,_nLinha
==============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
USER Function AOMS13Leg(_aCol,_nLinha)
Local oGeraCri := LoadBitmap( , "BR_VERMELHO")// VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO
Local oGerar   := LoadBitmap( , "BR_AZUL"    )// AZUL TEM QUE GERA REPOSICAO .F. MAS TEM AINDA
Local oGerado  := LoadBitmap( , "BR_AMARELO" )// AMARELO ESTOQUE TUDO OK .T. SQN
Local oNaoGera := LoadBitmap( , "BR_VERDE"   )// VERDE ESTOQUE TUDO OK .T.

Local o3GeraCri:= LoadBitmap( , "PMSTASK1"   )// VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO (SO MOSTRA)
Local o3Gerar  := LoadBitmap( , "PMSTASK6"   )// AZUL TEM QUE GERA REPOSICAO .F. MAS TEM AINDA (SO MOSTRA)
Local o3Gerado := LoadBitmap( , "PMSTASK2"   )// AMARELO ESTOQUE TUDO OK .T. SQN (SO MOSTRA)
Local o3NaoGera:= LoadBitmap( , "PMSTASK4"   )// VERDE ESTOQUE TUDO OK .T. (SO MOSTRA)

Local oBloquead:= LoadBitmap( GetResources() , "BR_PRETO"   )// BLOQUEADO INDEPENDENTE DE .T. OU .F.
Local _nCol    := _nPosColAcao

Local _nEstoque :=STRTRAN(_aLinhas[_nLinha,_nPosColEst],"." , "") //Tira o ponto dos milhar
Local _nCarteir :=STRTRAN(_aLinhas[_nLinha,_nPosColCar],"." , "") //Tira o ponto dos milhar
_nEstoque :=VAL(STRTRAN(_nEstoque,"," , ".") )//Tira a virgula e poe o ponto para o val não comer a decimal
_nCarteir :=VAL(STRTRAN(_nCarteir,"," , ".") )//Tira a virgula e poe o ponto para o val não comer a decimal

IF _aCol[_nLinha,_nCol] = "1"//BLOQUEADO NAO GERA E TEORICAMENTE NÃO TEM LINHA DELE PQ JÁ IGNORA NA SELECT
   RETURN oBloquead //BLOQUEADO INDEPENDENTE DE .T. OU .F.
//****************************************************************************//
ELSEIF _aCol[_nLinha,_nCol] <> "3" //"2" E BRANCO E QQ OUTRA COISA
   IF _aCol[_nLinha,1] // SE .T. ****************  NAO GERA *********************
      IF _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
         RETURN oGerado  // AMARELO TUDO OK .T. SQN
	  ELSE//estoque > carteira
         RETURN oNaoGera // VERDE TUDO OK .T.
	  ENDIF
   ELSE//SE .F.  **************** GERA ****************
      IF _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
         RETURN oGeraCri// VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO
	  ELSE//ESTOQUE > CARTEIRA
         RETURN oGerar  // AZUL TEM QUE GERA REPOSICAO .F. MAS TEM AINDA
	  ENDIF
   ENDIF
//****************************************************************************//
ELSEIF _aCol[_nLinha,_nCol] = "3"//SO MOSTRA  MAS NÃO GERA SE TIVER
   IF _aCol[_nLinha,1] //SE .T. **************** NAO GERA ****************
      IF _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
         RETURN o3Gerado //AMARELO TUDO OK .T. SQN
	  ELSE//ESTOQUE > CARTEIRA
         RETURN o3NaoGera //VERDE TUDO OK .T.
	  ENDIF
   ELSE//SE .F. **************** GERA ***************
      IF _nEstoque < _nCarteir//ESTOQUE < CARTEIRA
         RETURN o3GeraCri// VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO
	  ELSE//ESTOQUE > CARTEIRA
         RETURN o3Gerar  // AZUL TEM QUE GERA REPOSICAO .F. MAS TEM AINDA (SO MOSTRA)
	  ENDIF
   ENDIF
ENDIF
RETURN oBloquead

/*
===============================================================================================================================
Programa----------: SchedDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 25/05/2017
===============================================================================================================================
Descrição---------: Definição de Static Function SchedDef para o novo Schedule
					No novo Schedule existe uma forma para a definição dos Perguntes para o botão Parâmetros, além do cadastro 
					das funções no SXD. Ao definir em sua rotina a static function SchedDef(), no cadastro da rotina no Agenda-
					mento do Schedule será verificado se existe esta static function e irá executá-la habilitando o botão Parâ-
					metros com as informações do retorno da SchedDef(), deixando de verificar assim as informações na SXD. O 
					retorno da SchedDef deverá ser um array.
					Válido para Function e User Function, lembrando que uma vez definido a SchedDef, ao chamar a rotina o ambi-
					ente já está inicializado.
					Uma vez definido a Static Function SchedDef(), a rotina deixa de ser uma execução como processo especial, 
					ou seja, não se deve cadastrá-la no Agendamento passando parâmetros de linha. Ex: Funcao("A","B") ou 
					U_Funcao("A","B").
===============================================================================================================================
Parametros--------: aReturn[1] - Tipo: "P" - para Processo, "R" -  para Relatórios
					aReturn[2] - Nome do Pergunte, caso nao use passar PARAMDEF
					aReturn[3] - Alias  (para Relatório)
					aReturn[4] - Array de ordem  (para Relatório)
					aReturn[5] - Título (para Relatório)
===============================================================================================================================
Retorno-----------: aParam
===============================================================================================================================
*/
Static Function SchedDef()

Local aParam  := {}
Local aOrd := {}

aParam := { "P",;
            "PARAMDEFF",;
            "",;
            aOrd,;
            }

Return aParam

