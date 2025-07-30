/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |     Data   |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 02/08/2017 | Chamado 20782. Ajustes para versão 12. 
-------------------------------------------------------------------------------------------------------------------------------                            
Josué Prestes | 10/06/2019 | Chamado 29593. Revisão para loboguara.    
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 06/06/2022 | Chamado 40380. Novo botão para buscar a matricula do usuario. 
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "rwmake.ch"
#Include "protheus.CH"

/*
===============================================================================================================================
Programa----------: ACFG003
Autor-------------: Fabiano Dias
Data da Criacao---: 01/08/2011
===============================================================================================================================
Descrição---------: Rotina desenvolvida para realizar o cadastramento dos usuarios que terao acesso para efetuar a aprovacao
					dos pedidos de venda do tipo bonificacao, neste cadastro constara o e-mail dos aprovadores para onde sera
					enviado um e-mail para que ele possa efetuar a aprovacao via workflow ou em uma rotina manual.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACFG003()

// VARIAVEIS DE VISUALIZACAO DA TELA
Private aObjects    := {}
Private aPosObj     := {}
Private aSize       := MsAdvSize()
Private aInfo       := { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 3 }
Private lMsErroAuto := .F. 
Private _lCopia := .F.

// pega tamanhos das telas
AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )
aPosObj := MsObjSize( aInfo , aObjects )

//Variaveis privadas usadas no modelo 3
SetPrvt("AROTINA,CCADASTRO,CALIAS")
SetPrvt("NOPCE,NOPCG,NUSADO")
SetPrvt("CTITULO,CALIASENCHOICE,CLINOK,CTUDOK,CFIELDOK")
SetPrvt("NREG,NOPC")

nOpc:=0

aRotina := {{ OemToAnsi("Pesquisar")  ,"axPesqui"		, 0 , 1		},; // Pesquisar
            { OemToAnsi("Visualizar") ,'U_ACFG003CAD(2)'	, 0 , 2		},; // Visualizar
            { OemToAnsi("Incluir")    ,'U_ACFG003CAD(3)'	, 0 , 3		},; // Incluir
            { OemToAnsi("Alterar")    ,'U_ACFG003CAD(4)'	, 0 , 4 , 2	},; // Alterar
            { OemToAnsi("Excluir")    ,'U_ACFG003CAD(5)'	, 0 , 5 , 1	},; // Excluir
            { OemToAnsi("Copiar")     ,'U_ACFG003CAD(6)'	, 0 , 6 , 3	}}  // Copiar
            

cCadastro := OemToAnsi("GESTÃO DO USUÁRIO ITALAC")
cAlias := "ZZL"

//| Endereca a funcao de BROWSE                                  |
mBrowse(6, 1,22,75,cAlias,,,,,,)

Return

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
User Function ACFG003CAD( nOpc )

Local aButtons  := {} 
Local bCampo    := { |nCPO| Field(nCPO) }
Local _nni		:= 0
Private aTELA[0][0],aGETS[0]
Private AHEADER := {}, ACOLS := {}

nReg := 0
aGets := {}
aTela := {}
SetPrvt("wVar")                   

_lcopia := .F.

if  nOpc == 3	  // Incluir
	nOpcE := 3
	nOpcG := 3 
elseif nOpc == 4 	// Alterar
	nOpcE := 4
	nOpcG := 4
elseif nOpc == 2 	// Visualizar
	nOpcE := 2
	nOpcG := 2
elseif nOpc == 6   // Copiar
	nOpcE := 3
	nOpcG := 3 
	_lcopia := .T.
else                // Excluir
	nOpcE := 5
	nOpcG := 5
endif

if nOpcE == 3 .OR. nOpcE == 4 
   Aadd(aButtons, {"Atualiza Matricula" , {|| ACFG003Mat() } , "Atualiza Matricula"})
ENDIF

//| Cria variaveis M->????? da Enchoice                          
aCpoEnchoice  :={}
_astruct := ZZL->(Dbstruct())


For _nni := 1 to len(_astruct)
	
	AADD( aCpoEnchoice , alltrim(_astruct[_nni][1]) )
	
	wVar	:= "M->"+ alltrim(_astruct[_nni][1])
	&wVar	:= CriaVar( alltrim(_astruct[_nni][1]) ) // executa x3_relacao

Next _nni

If nOpc # 3  //se nao for inclusao 

	DbSelectArea("ZZL")
	
	For _nni := 1 TO FCount()
		M->&(EVAL(bCampo,_nni)) := FieldGet(_nni)
	Next _nni
	
Endif

if nOpc == 6    //se for cópia

  M->ZZL_USER := "                         "
  M->ZZL_NOME := "                              "
  M->ZZL_MATRIC := "        "
  M->ZZL_EMAIL := "                                                            "
  M->ZZL_CODUSU := "      "
  
endif 

//| Executa a Modelo 2                                           |
cTitulo			:= OemToAnsi("Cadastro de Usuarios")
cAliasEnchoice	:= "ZZL"
cTudOk			:= "AllwaysTrue()"
cFieldOk		:= ""

nOpca := 0

DEFINE MSDIALOG oDlg2 TITLE cTitulo From 9,0 to 35,170	of oMainWnd

	oEnCh1:=MsMget():New(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,3,,,,,,.F.)
	oDlg2:lMaximized:=.T.
	
ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,{|| If(obrigatorio(aGets,aTela),ACFG003GRA(),.f.),nOpca := 1},{||oDlg2:End()},,aButtons) , oEnch1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT)

Return()

/* 
===============================================================================================================================
Programa----------: ACFG003GRA 
Autor-------------: Enilton
Data da Criacao---: 13/12/2005
===============================================================================================================================
Descrição---------: Funcao de Gravacao     
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function ACFG003GRA()

Local _lVldInc 		:= .T.
Local x				:= 0
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

//Caso esteja realizando uma inclusao valida se o usuario ja nao possui cadastro
If Inclui
	
	_lVldInc:= U_ACFG003VLD()	

EndIf

If nOpcG # 2 .And. _lVldInc // nao for consulta
    

	If Inclui .or. Altera .or. _lCopia
	
		RecLock( "ZZL" , If( Altera , .F. , .T. ) )
		
		ZZL->ZZL_FILIAL := xFilial("ZZL")
		
		for x:=1 to len(aCpoEnchoice)
		
			wVar := "M->"  + aCpoEnchoice[x]
			ax   :="ZZL->" + aCpoEnchoice[x]
			
			if (POSICIONE("SX3",2,aCpoEnchoice[x],"X3_CONTEXT")!="V")
				&ax := &wVar
			endif
			
		next x
		MsUnlock()

		if Inclui .or. Altera .or. _lCopia
			ConfirmSx8()
		Endif
		
	Else  // exclusao

			RecLock("ZZL",.F.)
			dbdelete()
			MsUnlock()
			WriteSx2("ZZL")  
		
	Endif
	
Endif

If _lVldInc
	oDlg2:End()
EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: ACFG003VLD
Autor-------------: 
Data da Criacao---: 
===============================================================================================================================
Descrição---------: Valida dados antes da inclusão do usuário
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACFG003VLD() 

Local _lRet:= .T.

dbSelectArea("ZZL") 
ZZL->(dbSetOrder(3))
If  ZZL->(dbSeek(xFilial("ZZL") + M->ZZL_CODUSU))

	_lRet:= .F.                                                                                                 
	
	u_itmsg("O usuário: " + IIF(PSWSEEK(M->ZZL_CODUSU),PSWRET(1)[1,4]," ")   + " já está cadastrado!","Atenção",,1)

EndIf

Return _lRet

/* 
===============================================================================================================================
Programa----------: ACFG003Mat 
Autor-------------: Alex Wallauer
Data da Criacao---: 06/06/2022
===============================================================================================================================
Descrição---------: Busca a matriula do usuario novamente 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function ACFG003Mat()
LOCAL _aUser
IF PSWSEEK(ALLTRIM(M->ZZL_CODUSU))
   _aUser := PSWRET(1)[1]
   M->ZZL_MATRIC := STRTRAN(SUBSTR(_aUser[22],3)," ","")
   IF EMPTY(M->ZZL_MATRIC)
      U_ITMSG("Usuário informado não tem a matricula informada no módulo configurador do sistema: "+M->ZZL_CODUSU,'Atenção!',"Verifique o código informado.",3) // ALERT
   ELSE
      U_ITMSG("Matricula atualizada com: "+M->ZZL_MATRIC,'Atenção!',,2) // ALERT
   ENDIF
ELSE
   U_ITMSG("Usuário informado não tem informações no módulo configurador do sistema: "+M->ZZL_CODUSU,'Atenção!',"Verifique o código informado.",3) // ALERT
ENDIF
RETURN
