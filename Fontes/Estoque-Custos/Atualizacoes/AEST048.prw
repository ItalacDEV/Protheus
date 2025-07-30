/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
      Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer   | 09/05/2022 | Chamado 40033. Criação botão copia e acerto da validação dos campos ZAM_COOCOD/ZAM_GERCOD/OK.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa--------: AEST048
Autor-----------: Alex Wallauer
Data da Criacao-: 21/02/2020
===============================================================================================================================
Descrição-------: Cadastro de amarração regional para gerentes e coordenadores - chamado 32088
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AEST048()
Local _bok := {|| AEST048OK() }
LOCAL aRotAdic:={}

aAdd(aRotAdic,{"Copiar","U_AESTS48Copia", 0, 9, 0, Nil })

//Cadastro("ZAM","Cadastro de Amarração Regional para Gerentes e Coordenadores", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )
AxCadastro("ZAM","Cadastro de Amarração Regional para Gerentes e Coordenadores",            ,          , aRotAdic,      ,_bok)	

Return

/*
===============================================================================================================================
Programa--------: AEST048OK
Autor-----------: Alex Wallauer
Data da Criacao-: 26/02/2020
===============================================================================================================================
Descrição-------: Validação no OK final
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
STATIC Function AEST048OK()
IF INCLUI  .OR. ALTERA
	ZAM->(DBSETORDER(1))
	IF ZAM->(DBSEEK(xFilial()+M->ZAM_COOCOD+M->ZAM_GERCOD+M->ZAM_REGCOD))
		U_ITMSG("A combinação Cordenador + Gerente + Regional já existe",'Atenção!',"Conbine codigos diferente do atual",1) // CANCEL
		Return .F.
	ENDIF
ENDIF


RETURN .T.
/*
===============================================================================================================================
Programa--------: AEST048
Autor-----------: Alex Wallauer
Data da Criacao-: 21/02/2020
===============================================================================================================================
Descrição-------: Validação dos campos no X3_VLDUSER - ZAM_COOCOD: U_AESTS48Val("C")
Descrição-------:                                      ZAM_GERCOD: U_AESTS48Val("G")
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AESTS48Val(cTipo)
Local _cCampo:= ReadVar() , _cConteudo

IF !ExistCpo("SA3")
   Return .F.
ENDIF

_cConteudo:=&(_cCampo)
_cConteudo:=POSICIONE("SA3",1,XFILIAL("SA3")+_cConteudo,"A3_I_TIPV")
IF _cConteudo <> cTipo//SA3 JÁ´POSICONADO PELO ExistCpo("SA3") NO X3_VALID
   U_ITMSG("TIPO do vendedor invalido",'Atenção!',"O vendedor deve ser do tipo: "+cTipo,1) // CANCEL
   Return .F.
ENDIF

Return .T.

/*
===============================================================================================================================
Programa----------: ACFG003CAD
Autor-------------: Fabiano Dias
Data da Criacao---: 01/08/2011
===============================================================================================================================
Descrição---------: Rotina de controle do cadastro e manutenção dos dados.   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AESTS48Copia(  )
Local bCampo  := { |nCPO| Field(nCPO) }
Local _nni	  := 0
Local nReg    := 0
Private aObjects:= {}
Private aPosObj := {}
Private aSize   := MsAdvSize()
Private aInfo   := { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 3 }

aGets := {}
aTela := {}
nOpcE := 3

// pega tamanhos das telas
AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )
aPosObj := MsObjSize( aInfo , aObjects )

//| Cria variaveis M->????? da Enchoice                          
aCpoEnchoice  :={}
_astruct := ZAM->(Dbstruct())

For _nni := 1 to len(_astruct)
	
	AADD( aCpoEnchoice , alltrim(_astruct[_nni][1]) )
	
	wVar	:= "M->"+ alltrim(_astruct[_nni][1])
	&wVar	:= CriaVar( alltrim(_astruct[_nni][1]) ) // executa x3_relacao

Next _nni

DbSelectArea("ZAM")	
For _nni := 1 TO FCount()
	M->&(EVAL(bCampo,_nni)) := FieldGet(_nni)
Next _nni
	

//| Executa a Modelo 2                                           |
cTitulo			:= "Copia"
cAliasEnchoice	:= "ZAM"
cTudOk			:= "AllwaysTrue()"

DEFINE MSDIALOG oDlg2 TITLE cTitulo From 9,0 to 35,170	of oMainWnd

	oEnCh1:=MsMget():New(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,3,,,,,,.F.)
	oDlg2:lMaximized:=.T.
	
ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,{|| If(obrigatorio(aGets,aTela),AESTS48GRA(),.f.)},{||oDlg2:End()},,) , oEnch1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT)

Return()

/* 
===============================================================================================================================
Programa----------: AESTS48GRA 
Autor-------------: Enilton
Data da Criacao---: 13/12/2005
===============================================================================================================================
Descrição---------: Funcao de Gravacao     
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function AESTS48GRA()
Local x,wVar,ax
INCLUI:=.T.
IF AEST048OK()
   ZAM->(RecLock( "ZAM" ,  .T.  ))		
   ZAM->ZAM_FILIAL := xFilial("ZAM")
		
	FOR X:=1 TO LEN(aCpoEnchoice)
	
		wVar := "M->"  + aCpoEnchoice[x]
		ax   :="ZAM->" + aCpoEnchoice[x]
		
		IF ZAM->(FIELDPOS(aCpoEnchoice[x])) <> 0
			&(ax) := &(wVar)
		ENDIF
		
	next
	ZAM->(MsUnlock())

	oDlg2:End()
ELSE
    RETURN .F.
Endif

RETURN .T. 
