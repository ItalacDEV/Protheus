/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor              |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
  Alex Wallauer     | 08/08/2017 | Ajustes para versão 12 - Chamado 20782
-------------------------------------------------------------------------------------------------------------------------------                            
  Josué Prestes     | 10/06/2019 | Revisão para loboguara - Chamado 29593     
-------------------------------------------------------------------------------------------------------------------------------
  Lucas Borges 	    | 17/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
  Alex Wallauer     | 30/08/2021 | Criacao e tratamento do campo novo Z14_TIPO.  Chamado 37602
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "rwmake.ch"
#Include "protheus.CH"

/*
===============================================================================================================================
Programa----------: ACFG004
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/09/2015
===============================================================================================================================
Descrição---------: Cadastro de usuários x filiais x armazéns - Chamado 12079
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACFG004()

// VARIAVEIS DE VISUALIZACAO DA TELA
Private aObjects    := {}
Private aPosObj     := {}
Private aSize       := MsAdvSize()
Private aInfo       := { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 3 }
Private lMsErroAuto := .F. 
Private _lCopia := .F.


//VERIFICA PERMISSÃO DE ACESSO
_lAcesso := U_ITVACESS( 'ZZL' , 3 , 'ZZL_USRFIL' , "S" )

If !_lAcesso

//									|....:....|....:....|....:....|....:....|
	ShowHelpDlg( 'Atenção!' ,	{	'Usuário sem acesso à rotina de usuários '	,;
									'xfiliaisxarmazéns Italac!'						} , 2 ,;
								{	'Caso necessário solicite a manutenção à '		,;
									'um usuário com acesso ou, se necessário, '		,;
									'solicite o acesso à área de TI/ERP.'			} , 3  )
	
	Return()
	
EndIf

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
            { OemToAnsi("Visualizar") ,'U_ACFG004CAD(2)'	, 0 , 2		},; // Visualizar
            { OemToAnsi("Incluir")    ,'U_ACFG004CAD(3)'	, 0 , 3		},; // Incluir
            { OemToAnsi("Alterar")    ,'U_ACFG004CAD(4)'	, 0 , 4 , 2	},; // Alterar
            { OemToAnsi("Excluir")    ,'U_ACFG004CAD(5)'	, 0 , 5 , 1	},; // Excluir
            { OemToAnsi("Copiar")     ,'U_ACFG004CAD(6)'	, 0 , 6 , 3	}}  // Copiar
            
//================================================================
//| Define o cabecalho da tela de atualizacoes                   |
//================================================================

cCadastro := OemToAnsi("Gestão de usuários x filiais x armazéns")
cAlias := "Z14"

//================================================================
//| Endereca a funcao de BROWSE                                  |
//================================================================
mBrowse(6, 1,22,75,cAlias,,,,,,)

Return


/*
===============================================================================================================================
Programa----------: ACFG004CAD
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/09/2015
===============================================================================================================================
Descrição---------: Rotina de controle do cadastro e manutenção dos dados.   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACFG004CAD( nOpc )
Local aButtons  := {} , _nni
Local bCampo    := { |nCPO| Field(nCPO) }

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


//================================================================
//| Cria variaveis M->????? da Enchoice                          |
//================================================================
aCpoEnchoice  :={}
_astruct := Z14->(Dbstruct())

For _nni := 1 to len(_astruct)
	
	AADD( aCpoEnchoice , alltrim(_astruct[_nni][1]) )
	
	wVar	:= "M->"+ alltrim(_astruct[_nni][1])
	&wVar	:= CriaVar( alltrim(_astruct[_nni][1]) ) // executa x3_relacao

Next _nni

If nOpc # 3  //se nao for inclusao 

	DbSelectArea("Z14")
	
	For _nni := 1 TO FCount()
		M->&(EVAL(bCampo,_nni)) := FieldGet(_nni)
	Next _nni
	
Endif

if nOpc == 6    //se for cópia

  M->Z14_USER := "                         "
  M->Z14_NOME := "                              "
  M->Z14_CODUSU := "      "
 
endif 

//Log de utilização
U_ITLOGACS()

//================================================================
//| Executa a Modelo 2                                           |
//================================================================
cTitulo			:= OemToAnsi("Cadastro de Usuarios")
cAliasEnchoice	:= "Z14"
cTudOk			:= "AllwaysTrue()"
cFieldOk		:= ""

nOpca := 0

DEFINE MSDIALOG oDlg2 TITLE cTitulo From 9,0 to 35,170	of oMainWnd

	oMsMGet:=MsMGet():New(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,3,,,,,,.F.)

	oDlg2:lMaximized:=.T.
	
ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,{|| If(obrigatorio(aGets,aTela),ACFG004GRA(),.f.),nOpca := 1},{||oDlg2:End()},,aButtons) , oMsMGet:oBox:Align:=CONTROL_ALIGN_ALLCLIENT )

Return()

/* 
===============================================================================================================================
Programa----------: ACFG004GRA 
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/09/2015
===============================================================================================================================
Descrição---------: Funcao de Gravacao     
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ACFG004GRA()

Local x				:= 0
Local _lVldInc 		:= .T.

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

//Caso esteja realizando uma inclusao valida se o usuario ja nao possui cadastro
If Inclui
	
	_lVldInc:= U_ACFG004VLD()	

EndIf

If nOpcG # 2 .And. _lVldInc // nao for consulta
    

	If Inclui .or. Altera .or. _lCopia
	
		RecLock( "Z14" , If( Altera , .F. , .T. ) )
		
		Z14->Z14_FILIAL := xFilial("Z14")
		
		for x:=1 to len(aCpoEnchoice)
		
			wVar := "M->"  + aCpoEnchoice[x]
			ax   :="Z14->" + aCpoEnchoice[x]
			
			if (POSICIONE("SX3",2,aCpoEnchoice[x],"X3_CONTEXT")!="V")
	
				&ax := &wVar
	
			endif
			
		next x

		MsUnlock()

		if Inclui .or. Altera .or. _lCopia
	
			ConfirmSx8()
	
		Endif
		
	Else  // exclusao

			RecLock("Z14",.F.)
			dbdelete()
			MsUnlock()
			WriteSx2("Z14")  
		
	Endif
	
Endif

If _lVldInc

	oDlg2:End()

EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: ACFG004VLD
Autor-------------:Josué Danich Prestes 
Data da Criacao---: 24/09/2015
===============================================================================================================================
Descrição---------: Valida dados antes da inclusão do usuário
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACFG004VLD() 

Local _lRet:= .T.
Local _npos := Z14->( RECNO() )

dbSelectArea("Z14") 
Z14->(dbSetOrder(1))

If  Z14->(dbSeek(xFilial("Z14") + M->Z14_CODUSU +M->Z14_FILACE))

	_lRet:= .F.                                                                                                 
	
	Alert("O usuário: " + IIF(PSWSEEK(M->Z14_CODUSU),PSWRET(1)[1,4]," ")   + " já está cadastrado para essa filial de acesso!")

EndIf

Z14-> ( DBGOTO( _npos ) )

Return _lRet

/*
===============================================================================================================================
Programa----------: ACFG004R
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/09/2015
===============================================================================================================================
Descrição---------: Retorna nome completo do usuário
===============================================================================================================================
Parametros--------: _ccodusu - código do usuário no configurador padrão
===============================================================================================================================
Retorno-----------: _cNome - nome completo do usuário
===============================================================================================================================
*/
User Function ACFG004R(_ccodusu)

Local _cNome := ""

//Escolhe ordem de procura por código do usuário
PswOrder(1)

//Se achar usuário carrega nome completo
If PswSeek(_ccodusu,.T.)

	_aRetUser := PswRet(1)

   _cNome   := upper(alltrim(_aRetUser[1,4]))

Endif

Return _cNome

/*
===============================================================================================================================
Programa----------: ACFG004E
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/09/2015
===============================================================================================================================
Descrição---------: Valida filial x usuário x armazém
===============================================================================================================================
Parametros--------: _ccodusu - código do usuário no configurador padrão
					_cfilace - filial sendo acessada
					_carma - armazém em uso
					_cproduto - produto em uso
					_lmens - apresenta mensagem de erro ou não
					_cmens - string com armazéns que já apresentaram mensagem de bloqueio
===============================================================================================================================
Retorno-----------: _aret[1] - Lógico liberando ou não o uso do armazém
				    _aret[2] - String com armazéns bloqueados
===============================================================================================================================
*/
User Function ACFG004E(_ccodusu, _cfilace, _carma,_cproduto,_lmen)

//Local _aarea 		:= Getarea()
Local _lRet 		:= .T.
Local _Ni 			:= 1
Local _aarmaz		:= {}
Local _aRet 		:= {}
Local _cmens		:= ""
Local _cTipos       := ""
Default _lmen		:= .F.

DBSelectArea("Z14")
Z14->( DBSetOrder(1) )
	
If Z14->( DBSeek( xFilial("Z14") + alltrim(_ccodusu)+ _cfilace ) ) 

   IF Z14->(FIELDPOS("Z14_TIPO")) <> 0 .AND. !EMPTY(Z14->Z14_TIPO)
	  _cTipos:= ALLTRIM(Z14->Z14_TIPO)
   ENDIF	
   _cTpProd:=Posicione("SB1",1,xfilial("SB1")+_cproduto,"B1_TIPO")

	//se achou usuário e filial de acesso pesquisa para ver se armazém está liberado
	IF EMPTY(_cTipos)
	   If !(_carma $ alltrim(Z14->Z14_LOCAL)) //Armazens dos produtos acabados
		
		    //Se for PA marca o produto x armazém como acesso restrito
		    If _cTpProd = "PA"
		    	If ascan(_aarmaz, _carma ) == 0
		    		aadd(_aarmaz, _carma+" e "+_cTpProd )
		    	Endif
		    	_lRet := .F.
		    Endif
		Endif
	Else
	   If !(_carma $ alltrim(Z14->Z14_LOCAL)) //Armazens dos produtos acados
			
			If ascan(_aarmaz, _carma ) == 0
				aadd(_aarmaz, _carma+" e / ou "+_cTpProd  )
			Endif
			_lRet := .F.
		Else
		   IF !_cTpProd $ _cTipos
			   If ascan(_aarmaz, _carma ) == 0
				  aadd(_aarmaz, _carma+" e / ou "+_cTpProd)
			   Endif
			   _lRet := .F.
		   ENDIF

		ENDIF

	Endif
		
Endif
 
//apresenta mensagem se teve problemas
If !(_lRet) .and. len(_aarmaz) > 0 

	_Ni := 1
	
	For _ni := 1 to len(_aarmaz)
	
		if len(alltrim(_cmens)) > 0
		
			_cmens += " ,"
			
		Endif
		
		_cmens += _aarmaz[_ni]
		
	Next
	
	if _lmen
	
		MessageBox( 'Usuário sem acesso ao(s) Armazém / Tipo abaixo nessa filial: ' + CRLF + _cmens + CRLF + CRLF+;
					'Caso necessário solicite a manutenção à um usuário com acesso ou, se necessário, solicite o acesso à área de TI/ERP.' , 'Atenção!' , 48 )
					
	Endif
			
Endif

_aRet := { _lRet, _cmens } 
	
Return _aRet
