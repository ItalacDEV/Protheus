/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 17/09/2018 | Aumento de limite de linhas para 9999 - Chamado 26256 
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 05/11/2018 | Revis�o para novos padr�es de codifica��o Totvs - Chamado 26709 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 14/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
/*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

#Define _ENTER CHR(13) + CHR(10)

/*
===============================================================================================================================
Programa--------: AOMS056
Autor-----------: Fabiano Dias
Data da Criacao-: 19/08/2011
===============================================================================================================================
Descri��o-------: Rotina desenvolvida para possibilitar a insercao e manutencao dos dados referentes a TES INTELIGENTE.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function AOMS056()

Private aObjects := {}
Private aPosObj  := {}
Private aSize    := MsAdvSize()
Private aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Private _cAlias1 :="ZZP"
Private cTipoOPFor:= "9F"//Para TES dos forncedores


Private AROTINA
Private CCADASTRO
Private CALIAS
Private NOPCE
Private NOPCG
Private NUSADO
Private CTITULO
Private CALIASENCHOICE
Private CLINOK
Private CTUDOK
Private CFIELDOK
Private NREG
Private NOPC

AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )

aPosObj := MsObjSize( aInfo , aObjects )

nOpc := 0

aRotina := {{ OemToAnsi("Pesquisar")  , "axPesqui"      , 0 , 1 },; && Pesquisar
            { OemToAnsi("Visualizar") , 'U_AOMS056T(2)' , 0 , 2 },; && Visualizar
            { OemToAnsi("Incluir")    , 'U_AOMS056T(3)' , 0 , 3 },; && Incluir
            { OemToAnsi("Alterar")    , 'U_AOMS056T(4)' , 0 , 4 },; && Alterar
            { OemToAnsi("Excluir")    , 'U_AOMS056T(5)' , 0 , 5 },; && Excluir
            { OemToAnsi("Copia")      , 'U_AOMS056T(6)' , 0 , 6 } } && Copia

cCadastro := OemToAnsi( "TES INTELIGENTE" )

MBrowse( ,,,, _cAlias1 )

Return()

/*
===============================================================================================================================
Programa--------: AOMS056T
Autor-----------: Fabiano Dias
Data da Criacao-: 19/08/2011
===============================================================================================================================
Descri��o-------: Tela de inclusao/alteracao/visualizacao/exclusao/copia dos dados referentes a TES INTELIGENTE.
===============================================================================================================================
Parametros------: nOpc (tipo 3-inclusao,2-visualizar,etc..)
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function AOMS056T( nOpc )

Local bCampo   		:= { |nCPO| Field(nCPO) }
Local vCampos  		:= {} // campos de visuzaliacao
Local aButtons 		:= {}
Local _nnk			:= 0
Local _nPosItem		:= 0 , nCntFor , v  ,_nI  

Static oGetDados

nReg  := 0
aGets := {}
aTela := {}     

SetPrvt("wVar")

Private aTELA[0][0]
Private aGETS[0]
Private AHEADER		:= {}
Private ACOLS		:= {}
Private _oTotFatura
Private _cTotFatura := 0
Private oFont14b 
Private _lTESimplesNac:=ZZP->(FIELDPOS("ZZP_SIMPNA")) # 0 .AND. ZZP->(FIELDPOS(" ZZP_CONTRI")) # 0//Tratamento da TES do Simples Nacional.

//Log de utiliza��o
U_ITLOGACS()

Define Font oFont14b   Name "Courier New"       Size 0,-12 Bold  // Tamanho 14

If nOpc == 6 // Copia

	nOpcE := 4
	nOpcG := 4

Else

	nOpcE := nOpc
	nOpcG := nOpc
	
EndIf

//====================================================================================================
// Cria variaveis M->????? da Enchoice
//====================================================================================================
aCpoEnchoice  :={}
_acampos := {"ZZP_CODIGO","ZZP_TIPO","ZZP_CLIENT","ZZP_LOJA","ZZP_DESCLI","ZZP_CLIZN","ZZP_SIMPNA","ZZP_CONTRI"}
vcampos := {}
aadd(vcampos,{"ZZP_DESCLI",'IIF(INCLUI,"",POSICIONE("SA1",1,XFILIAL("SA1")+M->ZZP_CLIENT+M->ZZP_LOJA,"SA1->A1_NOME"))'})

For _nnk := 1 to len(_acampos)
                                                  
	AADD(aCpoEnchoice,_acampos[_nnk])
	wVar := "M->" + _acampos[_nnk]
	&wVar:= CriaVar(_acampos[_nnk])

Next

//====================================================================================================
//Para que somente os campos citados acima para o cabecalho sejam impressos e nao todos da tabela ZZN 
//deve-se acrescentar a instrucao abaixo
//====================================================================================================
AADD( aCpoEnchoice , "NOUSER" )

If nOpc#3 // se nao for inclusao preenche os campos do cabecalho

	DbSelectArea(_cAlias1)
	
	For nCntFor := 1 TO FCount()      
	
		If AllTrim((EVAL(bCampo,nCntFor))) $ "ZZP_CODIGO/ZZP_TIPO/ZZP_CLIENT/ZZP_LOJA/ZZP_DESCLI/ZZP_CLIZN/ZZP_SIMPNA/ZZP_CONTRI"
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		EndIf
		
	Next nCntFor
	
	For v:=1 to len(vCampos) // CAMPOS DE VISUALIZACAO  
	
		If AllTrim(vCampos[v,1]) $ "ZZP_CODIGO/ZZP_TIPO/ZZP_CLIENT/ZZP_LOJA/ZZP_DESCLI/ZZP_CLIZN/ZZP_SIMPNA/ZZP_CONTRI"
			wVar  := "M->"+vCampos[v,1]
			&wVar := &(vCampos[v,2])         
		EndIf     
		
	next v
	
Endif

//====================================================================================================
// Cria aHeader e aCols da GetDados
//====================================================================================================
nUsado := 7
_acampos := {}

aadd(aheader,{"Item","ZZP_ITEM  ","@!                                           ",3,0," ","���������������","C","ZZP","R"," ","��"})
aadd(aheader,{"Produto","ZZP_PRODUT","@!                                           ",15,0," ","���������������","C","ZZP","R"," ","��"})
aadd(aheader,{"Descr. Prod.","ZZP_DESCRI","@!                                           ",100,0," ","���������������","C","ZZP","V",'IIF(INCLUI,"",POSICIONE("SB1",1,XFILIAL("SB1") + ZZP->ZZP_PRODUT,"SB1->B1_I_DESCD" ))                                           ',"��"})
aadd(aheader,{"TES Interna","ZZP_TSIN  ","@!                                           ",3,0," ","���������������","C","ZZP","R"," ","��"})
aadd(aheader,{"TES Externa","ZZP_TSOUT ","@!                                           ",3,0," ","���������������","C","ZZP","R"," ","��"})
aadd(aheader,{"Estado","ZZP_ESTADO","@!                                           ",2,0," ","���������������","C","ZZP","R"," ","��"})
aadd(aheader,{"Armazem","ZZP_LOCAL ","@99                                          ",2,0," ","���������������","C","ZZP","R"," ","�A"})

M->ZZP_ITEM 	:= 	CriaVar("ZZP_ITEM")	
M->ZZP_PRODUT 	:= 	CriaVar("ZZP_PRODUT")
M->ZZP_DESCRI 	:= 	CriaVar("ZZP_DESCRI")
M->ZZP_TSIN 	:= 	CriaVar("ZZP_TSIN")
M->ZZP_TSOUT 	:= 	CriaVar("ZZP_TSOUT")
M->ZZP_ESTADO 	:= 	CriaVar("ZZP_ESTADO")
M->ZZP_LOCAL 	:= 	CriaVar("ZZP_LOCAL")
	
DBSelectArea(_cAlias1)

//====================================================================================================
// PREENCHENDO ACOLS
//====================================================================================================
If nOpc == 3 // Incluir
    
    _nPosItem := aScan( aHeader , {|K| Upper( allTrim( K[2] ) ) == "ZZP_ITEM" } )
	
	aCols := { Array( nUsado + 1 ) }
	
	aCols[1][nUsado+1] := .F.
	
	For _nI := 1 to nUsado
		aCols[1][_ni]  := CriaVar( aHeader[_nI][2] )
	Next
	
	aCols[1][_nPosItem] := "001"
	
Else

	aCols := {}
	
	DBSelectArea(_cAlias1)
	(_cAlias1)->( DBSetOrder(1) )
	
	IF (_cAlias1)->( DBSeek( xFilial("ZZP") + ZZP->ZZP_CODIGO ) )
		
        nReg  := ZZP->(RECNO())//Guarda o recno
		
		While !ZZP->(Eof()) .And. ZZP->ZZP_FILIAL == xFilial("ZZP") .And. ZZP->ZZP_CODIGO == M->ZZP_CODIGO
			
			AADD(aCols,Array(nUsado+1))
			
			For _nI := 1 to nUsado
				aCols[Len(aCols)][_ni] := IIf( aHeader[_ni][10] # "V" , FieldGet( FieldPos( aHeader[_ni][2] ) ) , CriaVar( aHeader[_ni][2] ) )
			Next
			
			aCols[Len(aCols)][nUsado+1] := .F.
			
		ZZP->( DBSkip() )
		EndDo
		
	Else
	
		u_itmsg(	"N�o foram encontrados registros de dados da linha posicionada"	,;
					"INFORMA��O"													,;
					"Favor comunicar ao suporte de tal problema encontrado",1		 )
		Return()
		
	EndIf
	
EndIf

If Len( aHeader ) > 0
	
	//====================================================================================================
	// Verifica se esta sendo realiazada uma copia da TES inteligente e passa o novo codigo a ser gerado.
	//====================================================================================================
	If nOpc == 6
		
		M->ZZP_CODIGO := U_AOMS056N()
	
	EndIf
	
	//====================================================================================================
	// Executa a Modelo 3
	//====================================================================================================
	cTitulo			:= OemToAnsi( "TES INTELIGENTE" )
	cAliasEnchoice	:= _cAlias1
	cAliasGetd		:= _cAlias1
	cAlias			:= _cAlias1
    cLinOk			:= "U_AOMS056V()"
    cTudOk			:= "AllwaysTrue()"
    cFieldOk		:= ""
	nOpca			:= 0
	IF _lTESimplesNac .AND. ( M->ZZP_TIPO $ cTipoOPFor )
		aTrocaF3 := {{"ZZP_CLIENT","FOR"}}
	Else
		aTrocaF3 = {}//Variavel private usada para troca o F3 de um campo  no MsMGet
	EndIf

	IF nReg # 0
	   ZZP->( DBGOTO( nReg ) )//Reposiciona no ZZP por causa da descri��o do forncedor/cliente que vinha errada
	ENDIF

	aSize    := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo   := { aSize[ 1 ],aSize[ 2 ],aSize[ 3 ],aSize[ 4 ],03,03 }
	aPosObj := MsObjSize( aInfo, aObjects )

	aPosObj[1,3]:=097//Meio - MsMGet()
	aPosObj[2,1]:=100//Meio - MsGetDados()
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
//                           [ cAlias], [ uPar2],  nOpc>,4,5,6,   [ aAcho]   , [ aPos]    , [ aCpos], [ nModelo], [ uPar11], [ uPar12], [ uPar13], [ oWnd], [ lF3], [ lMemoria], [ lColumn], [ caTela], [ lNoFolder], [ lProperty], [ aField], [ aFolder], [ lCreate], [ lNoMDIStretch]
	oMsMGet:=MsMGet():New(cAliasEnchoice , nReg , nOpcE , , , , aCpoEnchoice , aPosObj[1] ,         , 3         ,          ,          ,          ,        ,       , .T. ) 

	IF _lTESimplesNac .AND. ( M->ZZP_TIPO $ cTipoOPFor )
       U_AOMS56Val(.F.,"M->ZZP_TIPO")//Acerta o titutlo do codigo do cliente / fornecedor
	ENDIF
	
	oGetDados := MsGetDados():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4] , nOpcG , cLinOk , cTudOk , "+ZZP_ITEM" , .T. ,,,, 9999 )
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , {|| IIf( obrigatorio( aGets , aTela ) .And. AOMS056E() , AOMS056G() .AND. oDlg:End() , .F. ) , nOpca := 1 } , {|| oDlg:End() } ,, aButtons )
	
EndIf

Return()

/*
===============================================================================================================================
Programa--------: AOMS056G
Autor-----------: Fabiano Dias
Data da Criacao-: 19/08/2011
===============================================================================================================================
Descri��o-------: Rotina para Gravar os dados do cabecalho e dos itens na tabela do banco
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/          

Static Function AOMS056G()         

Local wProcura , i            
                                                                             
Local _nPosItem  := AsCan( aHeader , {|W| Upper(AllTrim(W[2])) == "ZZP_ITEM"   } )
Local _nPosProd  := AsCan( aHeader , {|W| Upper(AllTrim(W[2])) == "ZZP_PRODUT" } )
Local _nPosTESIn := AsCan( aHeader , {|W| Upper(AllTrim(W[2])) == "ZZP_TSIN"   } )
Local _nPosTESOu := AsCan( aHeader , {|W| Upper(AllTrim(W[2])) == "ZZP_TSOUT"  } )
Local _nPosEst   := AsCan( aHeader , {|W| Upper(AllTrim(W[2])) == "ZZP_ESTADO" } )
Local _nPosLoc   := AsCan( aHeader , {|W| Upper(AllTrim(W[2])) == "ZZP_LOCAL" } )

//====================================================================================================
// Se nao for consulta
//====================================================================================================
If nOpcG # 2

	//====================================================================================================
	// grava os itens
	//====================================================================================================
	For i:=1 to len(aCols)     
	
		DBSelectArea("ZZP")
		ZZP->( DBSetOrder(1) )
		
		wProcura := ZZP->( DBSeek( xFilial("ZZP") + M->ZZP_CODIGO + aCols[i,1] ) )
		
		//====================================================================================================
		// A opcao nOpcG == 4 eh para o caso da copia, para efetuar a insercao dos dados
		//====================================================================================================
		If Inclui .or. Altera .Or. nOpcG == 4
		
			//====================================================================================================
			// Deleta a linha caso o registro exista no banco
			//====================================================================================================
			If aCols[i][Len(aCols[i])] .And. wProcura // exclusao
			
				RecLock( "ZZP" , .F. )
				ZZP->( DBDelete() )
				ZZP->( MsUnlock() )
				
				WriteSx2("ZZP")
				
			Else
			
				//====================================================================================================
				// Se a linha nao estiver deletada efetua a insercao ou alteracao
				//====================================================================================================
				If !aCols[i][len(aCols[i])]
					
					RecLock( "ZZP" , IIf( wProcura , .F. , .T.) )
					
					ZZP->ZZP_FILIAL  	:= XFILIAL("ZZP")
					ZZP->ZZP_CODIGO  	:= M->ZZP_CODIGO
					ZZP->ZZP_TIPO   	:= M->ZZP_TIPO
					ZZP->ZZP_CLIENT 	:= M->ZZP_CLIENT
					ZZP->ZZP_LOJA   	:= M->ZZP_LOJA
					ZZP->ZZP_CLIZN  	:= M->ZZP_CLIZN
					IF _lTESimplesNac
					   ZZP->ZZP_SIMPNA 	:= M->ZZP_SIMPNA
					   ZZP->ZZP_CONTRI 	:= M->ZZP_CONTRI
					ENDIF   
					ZZP->ZZP_ITEM  	    := aCols[i,_nPosItem]
					ZZP->ZZP_PRODUT  	:= aCols[i,_nPosProd]
					ZZP->ZZP_TSIN    	:= aCols[i,_nPosTESIn]
					ZZP->ZZP_TSOUT   	:= aCols[i,_nPosTESOu]
					ZZP->ZZP_ESTADO  	:= aCols[i,_nPosEst]
					ZZP->ZZP_LOCAL	    := aCols[i,_nPosLoc]

					ZZP->( MsUnlock() )
					
					If Inclui
						ConfirmSx8()
					EndIf
					
				EndIf
				
			EndIf
			
		Else
			
			//====================================================================================================
			// Op��o exclus�o do menu
			//====================================================================================================
			If wProcura
			
				RecLock("ZZP",.F.)
				ZZP->( DBDelete() )
				ZZP->( MsUnlock() )
				
				WriteSx2("ZZP")
			
			EndIf
			
		EndIf
		
	Next i
	
EndIf

Return( .T. )

/*
===============================================================================================================================
Programa--------: AOMS056V
Autor-----------: Fabiano Dias
Data da Criacao-: 19/08/2011
===============================================================================================================================
Descri��o-------: Funcao para validar os dados da linha inserida pelo usuario na getDados.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/ 

User Function AOMS056V()

Local _nPosItem		:= AsCan( aHeader , {|W| Upper(AllTrim(W[2]) ) == "ZZP_ITEM"   } )
Local _nPosProd		:= AsCan( aHeader , {|W| Upper(AllTrim(W[2]) ) == "ZZP_PRODUT" } )
Local _nPosTESIn	   	:= AsCan( aHeader , {|W| Upper(AllTrim(W[2]) ) == "ZZP_TSIN"   } )
Local _nPosTESOu		:= AsCan( aHeader , {|W| Upper(AllTrim(W[2]) ) == "ZZP_TSOUT"  } )
Local _nPosEst		:= AsCan( aHeader , {|W| Upper(AllTrim(W[2]) ) == "ZZP_ESTADO" } )
Local _nPosLoc		:= AsCan( aHeader , {|W| Upper(AllTrim(W[2]) ) == "ZZP_LOCAL" } )
Local _lRet			:= .T. , k
                             
//====================================================================================================
// Caso esteja sendo realizada uma inclusao ou alteracao as validacoes abaixo serao efetuadas.
//====================================================================================================
If nOpcG == 3 .Or. nOpcG == 4

	//====================================================================================================
	// Se a linha nao estiver deletada e nao foi validada, ou ja foi e sofreu algum tipo de alteracao
	//====================================================================================================
	If !aTail( aCols[n] )
		
		//====================================================================================================
		// Verifica se o produto ja foi lancado anteriormente em uma outra linha
		//====================================================================================================
		For k := 1 to Len(aCols)
		
			If !aTail(aCols[k])
			
				If _lret 
				
				   If aCols[k][_nPosProd] == aCols[n][_nPosProd]
				   
				   		If aCols[k][_nPosEst] == aCols[n][_nPosEst]
				   		
				   		 	If aCols[k][_nPosLoc] == aCols[n][_nPosLoc] 
				   		 	
				   		 		If !(k == n)
				
				   		 			_lRet := .F.
					
				   		 			u_itmsg( "O produto lan�ado na linha atual ja foi lan�ando para o mesmo estado e armazem fornecido anteriormente na linha: "+ aCols[k,_nPosItem]		,;
				   		 					"INFORMA��O"																												 		,;
				   		 				"Favor checar se o codigo do produto ou o estado/armazem fornecidos estejam corretos, pois n�o sera poss�vel realizar a inclus�o de dois "	+;
				   		 				"produtos com o mesmo c�digo para o mesmo estado/armazem dentro do mesmo cadastro de TES inteligente.",1										 )	
				   		 			
				   		 			Exit
					
				   		 		EndIf
				
				   		 	EndIf
				   		 	
				   		Endif
				   		 
				   	Endif
				   	
				Endif
				
			Endif
			
		Next k
		
		//====================================================================================================
		// Verifica se o usuario forneceu pelo menos umas das TES.
		//====================================================================================================
		If Len( AllTrim( aCols[n][_nPosTESIn] ) ) == 0 .And. Len( AllTrim( aCols[n][_nPosTESOu] ) ) == 0
			
			u_itmsg(		"Favor informar no m�nimo um tipo de TES: interna ou externa para confirmar a inclus�o da linha corrente."	,;
							"INFORMA��O"	,,1)
										
			_lRet := .F.
		
		EndIf
	
	EndIf
	
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: AOMS056E
Autor-----------: Fabiano Dias
Data da Criacao-: 22/08/2011
===============================================================================================================================
Descri��o-------: Funcao usada para validar de forma geral os dados da insercao da TES inteligente.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/ 

Static Function AOMS056E()

Local _lRet			:= .T.  , k , w
Local _cAlias			:= ""
Local _nPosItem		:= AsCan( aHeader , {|W| Upper( AllTrim( W[2] ) ) == "ZZP_ITEM"	} )
Local _nPosProd		:= AsCan( aHeader , {|W| Upper( AllTrim( W[2] ) ) == "ZZP_PRODUT"	} )
Local _nPosTESIn		:= AsCan( aHeader , {|W| Upper( AllTrim( W[2] ) ) == "ZZP_TSIN"	} )
Local _nPosTESOu		:= AsCan( aHeader , {|W| Upper( AllTrim( W[2] ) ) == "ZZP_TSOUT"	} )
Local _nPosEst		:= AsCan( aHeader , {|W| Upper( AllTrim( W[2] ) ) == "ZZP_ESTADO"	} )
Local _nPosLoc		:= AsCan( aHeader , {|W| Upper( AllTrim( W[2] ) ) == "ZZP_LOCAL"	} )

//====================================================================================================
// Caso esteja sendo realizada uma inclusao ou alteracao as validacoes abaixo serao efetuadas.
//====================================================================================================
If nOpcG == 3 .Or. nOpcG == 4

	//====================================================================================================
	// Valida se o usuario forneceu somente uma loja e nao preencheu o codigo do cliente, desta forma nao
	// sera possivel realizar a operacao
	//====================================================================================================
	If Len( AllTrim( M->ZZP_CLIENT ) ) == 0 .And. Len( AllTrim( M->ZZP_LOJA ) ) > 0
	
		u_itmsg(		"N�o ser� possivel realizar a inser��o de uma regra de TES INTELIGENTE somente preenchendo a loja do cliente."					,;
						"INFORMA��O"																													,;
						"Favor preencher o codigo do cliente ou deixar os campos cliente e loja vazios representando desta forma uma regra generica.",1	 )
		_lRet := .F.
	
	EndIf
	
	//====================================================================================================
	// Valida se na inclusao, alteracao ou copia ja exista um cadastro de TES inteligente com os mesmos
	// dados de Filial, tipo de operacao, cliente, loja e no caso do cliente e loja estarem vazios
	// indicando um cadastro geral considerar a zona Franca como meio de distinguir.
	//====================================================================================================
	If _lRet
	
		_cAlias := GetNextAlias()
		
		AOMS056Q( 1 , _cAlias , nOpcG )
		
		DBSelectArea( _cAlias )
		(_cAlias)->( DBGotop() )
		If (_cAlias)->NUMREG > 0
		
			u_itmsg(		"Tipo de Opera��o j� informado para esse Cliente/Loja nessa filial."															,;
							"INFORMA��O"																													,;
							"Para incluir/alterar mais produtos, posicione em algum produto cadastrado para essa Opera��o e Cliente e clique em alterar.",1	 )
			_lRet := .F.
		
		EndIf
		
		(_cAlias)->( DBCloseArea() )
		
	EndIf
	
	If _lRet
		_lRet := U_AOMS056O()
	EndIf
	
	If _lRet
		
		//====================================================================================================
		// Verifica se o produto ja foi lancado anteriormente em uma outra linha
		//====================================================================================================
		For k := 1 to Len(aCols)
		
			For w := 1 To Len(aCols)
			
			  If !aTail(aCols[k])
			
				If _lret 
				
				   If aCols[k][_nPosProd] == aCols[n][_nPosProd]
				   
				   		If aCols[k][_nPosEst] == aCols[n][_nPosEst]
				   		
				   		 	If aCols[k][_nPosLoc] == aCols[n][_nPosLoc] 
				   		 	
				   		 		If !(k == n)
				
				   		 			_lRet := .F.
					
				   		 			u_itmsg("O produto lan�ado na linha atual ja foi lan�ando para o mesmo estado e armazem fornecido anteriormente na linha: "+ aCols[k,_nPosItem]		,;
				   		 					"INFORMA��O"																												 		,;
				   		 				"Favor checar se o codigo do produto ou o estado/armazem fornecidos estejam corretos, pois n�o sera poss�vel realizar a inclus�o de dois "	+;
				   		 				"produtos com o mesmo c�digo para o mesmo estado/armazem dentro do mesmo cadastro de TES inteligente.",1										 )	
				   		 			
				   		 			Exit
					
				   		 		EndIf
				
				   		 	EndIf
				   		 	
				   		Endif
				   		 
				   	Endif
				   	
				Endif
				
			  Endif
			
			Next w
			
			//====================================================================================================
			// Para que a mensagem nao seja emitida duas vezes
			//====================================================================================================
			If !_lRet
			     Exit
			EndIf
			
		Next k
	
	EndIf
	
	If _lRet
	     
		For k := 1 To Len(aCols)
			
			//====================================================================================================
			// Verifica se o usuario forneceu pelo menos umas das TES.
			//====================================================================================================
			If Len( AllTrim( aCols[k][_nPosTESIn] ) ) == 0 .And. Len( AllTrim( aCols[k][_nPosTESOu] ) ) == 0 .And. !aTail( aCols[k] )
				
				u_itmsg(		"Favor informar no m�nimo um tipo de TES: interna ou externa para confirmar a inclus�o da linha: "+ aCols[k,_nPosItem] +"."	,;
								"INFORMA��O"																												,;
								"Favor proceder como indicado acima."																						 )
				_lRet:= .F.
				Exit
				
			EndIf
		
		Next k
	
	EndIf
    
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: AOMS056Q
Autor-----------: Fabiano Dias
Data da Criacao-: 22/08/2011
===============================================================================================================================
Descri��o-------: Funcao usada para realizar consultas no banco de dados.
===============================================================================================================================
Parametros------: _nOpcao		- numero da query a ser executada
----------------: _cAlias		- Alias da query a ser executada
----------------: _nOperacao	- Tipo da opercao que esta sendo realizada no momemnto(Ex: 3 - Inclusao, 4 - Alteracao, etc)
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function AOMS056Q( _nOpcao , _cAlias , _nOperacao )

Local _cFiltro := "%"

//====================================================================================================
// Valida se na inclusao, alteracao ou copia ja exista um cadastro de TES inteligente com os mesmos
// dados de Filial, tipo de operacao, cliente, loja e no caso do cliente e loja estarem vazios
// indicando um cadastro geral considerar a zona Franca como meio de distinguir.
//====================================================================================================
If _nOpcao == 1		     

	_cFiltro += " AND ZZP_FILIAL = '"+ xFilial("ZZP") +"' "
	_cFiltro += " AND ZZP_TIPO   = '"+ M->ZZP_TIPO    +"' "
	_cFiltro += " AND ZZP_CLIENT = '"+ M->ZZP_CLIENT  +"' "
	_cFiltro += " AND ZZP_LOJA   = '"+ M->ZZP_LOJA    +"' "
	
	//====================================================================================================
	// Regra geral considera Zona Franca / Simples Nacional / Contribuinte ICMS
	//====================================================================================================
	If EMPTY( M->ZZP_LOJA ) 
		_cFiltro += " AND ZZP_CLIZN  = '"+ M->ZZP_CLIZN  +"' "
		IF _lTESimplesNac
		   _cFiltro += " AND ZZP_SIMPNA = '"+ M->ZZP_SIMPNA +"' "
		   _cFiltro += " AND ZZP_CONTRI = '"+ M->ZZP_CONTRI +"' "
		ENDIF
	EndIf
	
	//====================================================================================================
	// Para verifica se nao existe algum tupo de duplicidade no banco deve-se desconsiderar no caso da
	// alteracao o codigo do lancamento corrente que esta sendo alterado.
	//====================================================================================================
	If _nOperacao == 4
		_cFiltro += " AND ZZP_CODIGO <> '"+ M->ZZP_CODIGO  +"' "
	EndIf
	
	_cFiltro += "%"
	
	BeginSql alias _cAlias
	
		SELECT COUNT(*) NUMREG
		FROM %table:ZZP%
		WHERE
			D_E_L_E_T_ = ' '
		%exp:_cFiltro%
		
	EndSql

EndIf

Return()
      
/*
===============================================================================================================================
Programa--------: AOMS056N
Autor-----------: Fabiano Dias
Data da Criacao-: 19/08/2011
===============================================================================================================================
Descri��o-------: Funcao usada para pegar numero maximo para o lacamento do cadastro da TES INTELIGENTE.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User function AOMS056N()

Local _cRet    := ""
Local _aArea   := GetArea()     

Local _cAlias  := GetNextAlias()
Local _cFiltro := "%"  

_cFiltro += " AND ZZP_FILIAL = '" + xFilial("ZZP") + "'"
_cFiltro += "%"

BeginSql alias _cAlias
	SELECT
	      TO_NUMBER(NVL(MAX(ZZP_CODIGO),'0')) AS CODIGO
	FROM
	      %table:ZZP%
	WHERE
	      D_E_L_E_T_ = ' '
	      %exp:_cFiltro%	      
EndSql

dbSelectArea(_cAlias)
(_cAlias)->(dbGotop())    

_cRet:= StrZero((_cAlias)->CODIGO + 1,6)          

//====================================================================================================
// Finaliza a area criada anteriormente.
//====================================================================================================
DBSelectArea(_cAlias)
(_cAlias)->( DBCloseArea() )

While !MayIUseCode( "ZZP_CODIGO_"+ xFilial("ZZP") + _cRet ) // verifica se esta na memoria, sendo usado busca o proximo numero disponivel
	_cRet := Soma1(_cRet)
EndDo

RestArea(_aArea)

Return( _cRet )

/*
===============================================================================================================================
Programa--------: AOMS056O
Autor-----------: Fabiano Dias
Data da Criacao-: 19/08/2011
===============================================================================================================================
Descri��o-------: Funcao usada para validar o tipo de operacao e cliente fornecido para realizar o cadastro ou alteracao de
----------------: uma TES INTELIGENTE.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function AOMS056O()

Local _lRet		:= .T.
Local _cTpOper2	:= GETMV( "IT_TPOPER2" ) //Armazena o tipo de operacao que na TES INTELIGENTE pode ser utilizado para cliente 000001 - Italac //Lucas Borges Ferreira - 09/05/2012
Local _cTpOper3	:= GETMV( "IT_TPOPER3" )
Local _cFiltro	:= "%"
Local cAliasSRA	:= "SRA"

If Len(AllTrim(M->ZZP_TIPO)) > 0                      

	//====================================================================================================
	// Operacao que estiverem contidas no parametro IT_TPOPER2 so poderao ser utilizadas para o cliente
	// 000001, ou seja, a propria ITALAC e suas lojas. Lucas Borges Ferreira - 09/05/2012
	// Alterado para que seja validada as operacoes que estiverem no parametro IT_TPOPER2.
	//====================================================================================================
	If M->ZZP_TIPO $ AllTrim(_cTpOper2)
	
		If M->ZZP_CLIENT <> '000001'
		
		   	u_itmsg(		"Para o tipo de operacao: "+ AllTrim(_cTpOper2) +", somente podera ser informado o cliente 000001(ITALAC)."	,;
		   					"INFORMA��O"																								,;
							"Favor verificar se o tipo de operacao indicado esta correto, ou alterar o codigo do cliente informado.",1	 )
			_lRet := .F.
			
	    EndIf
		
	//====================================================================================================
	// Outros tipo de operacao nao podem ter como cliente o codigo: 000001(ITALAC)
	//====================================================================================================
	Else
	
	    If M->ZZP_CLIENT == '000001'
	    
	    	u_itmsg(		"Para o tipo de operacao diferente de:"+ AllTrim(_cTpOper2) +", nao podera ser informado o cliente 000001(ITALAC)."	,;
	    					"INFORMA��O"																										,;
							"Favor verificar se o tipo de operacao indicado esta correto, ou alterar o codigo do cliente informado.",1			 )
			_lRet := .F.
		
	  	EndIf
	  	
	EndIf
	
	//====================================================================================================
	// Operacao que estiverem contidas no parametro IT_TPOPER3 so poderao ser utilizadas para cliente que
	// s�o funcion�rios ativos. Lucas Borges Ferreira - 02/08/2012 
	// Incluida valida��o para venda para funcion�rios
	//====================================================================================================
	If M->ZZP_TIPO $ AllTrim(_cTpOper3).AND. M->ZZP_CLIENT <> ' '
	
		DBSelectArea("SA1")
		SA1->( DBSetOrder(1) )
		If SA1->( DBSeek( xFilial("SA1") + M->( ZZP_CLIENT + ZZP_LOJA ) ) )
		
			_cFiltro += " AND RA_CIC = '" + SA1->A1_CGC + "'%"
			
			cAliasSRA := GetNextAlias()
			
			BeginSql Alias cAliasSRA
			
				SELECT COUNT(1) NUMREG
				FROM %table:SRA%
				WHERE
					D_E_L_E_T_ = ' '
				AND RA_SITFOLH IN (' ','F','A')
				AND RA_CATFUNC IN ('M','E')
				%exp:_cFiltro%
				
	        EndSql
			
			If (cAliasSRA)->NUMREG = 0
			
			   	u_itmsg(		"Para o tipo de operacao: "+ AllTrim(_cTpOper3) +", somente poder�o ser informados clientes que tamb�m s�o funcion�rios."	,;
			   					"INFORMA��O"																												,;
								"Favor verificar se o tipo de operacao indicado esta correto, ou alterar o codigo do cliente informado.",1					 )
				_lRet := .F.
				
			EndIf
		
		Else
		
		   	u_itmsg(	"O cliente informado: "+ M->ZZP_CLIENT +'-'+ M->ZZP_LOJA +" n�o foi encontrado no cadastro do Sistema!"		,;
		   					"INFORMA��O"																								,;
							"Favor verificar se o c�digo indicado esta correto, ou informar um codigo de cliente v�lido.",1				 )
			_lRet := .F.
		
		EndIf
		
	EndIf

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: AOMS056D
Autor-----------: Fabiano Dias
Data da Criacao-: 26/10/2011
===============================================================================================================================
Descri��o-------: Funcao usada para verificar se os campos TES INTERNA E ESTADO podem ser editados, pois somente um destes
----------------: campos pode ser editado por linha, desta forma nao sera possivel fornecer uma TES INTERNA e o estado em uma
----------------: mesma linha.
===============================================================================================================================
Parametros------: _nCampo  - 1 Indica que se esta validando edicao do campo TES INTERNA e 2 - O campo ESTADO
===============================================================================================================================
Retorno---------: _lEdicao - Retorno da valida��o
===============================================================================================================================
*/

User Function AOMS056D(_nCampo)

Local _lEdicao:= .F.
     
//====================================================================================================
// Verifica se o campo TES INTERNA(ZZP_TSIN) pode ser editado, este valor somente podera ser editado
// caso nao tenha sido fornecido um estado, lembrando que o estado eh utilizado para a TES esterna.
//====================================================================================================
If _nCampo == 1

	If Len( AllTrim( aCols[n][ aScan( aHeader , {|x| Upper( AllTrim( x[2] ) ) == "ZZP_ESTADO" } ) ] ) ) == 0
		_lEdicao := .T.
	EndIf
	
//====================================================================================================
// Verifica se o campo ESTADO(ZZP_ESTADO) pode ser editado este campo somente podera ser editado caso
// nao tenha sido fornecido na linha atual uma TES INTERNA.
//====================================================================================================
Else
	
	If Len( AllTrim( aCols[n][ aScan( aHeader , {|x| Upper( AllTrim( x[2] ) ) == "ZZP_TSIN" } ) ] ) ) == 0
		_lEdicao := .T.
	EndIf

EndIf

Return( _lEdicao )

/*
===============================================================================================================================
Programa--------: getNumZZP
Autor-----------: Fabiano Dias
Data da Criacao-: 19/08/2011
===============================================================================================================================
Descri��o-------: Funcao usada para pegar numero maximo para o lacamento do cadastro da TES INTELIGENTE.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User function getZZPNum()

Local _cRet    := ""
Local _aArea   := GetArea()     

Local _cAlias  := GetNextAlias()
Local _cFiltro := "%"  

_cFiltro += " AND ZZP_FILIAL = '" + xFilial("ZZP") + "'"
_cFiltro += "%"

BeginSql alias _cAlias
	SELECT
	      TO_NUMBER(NVL(MAX(ZZP_CODIGO),'0')) AS CODIGO
	FROM
	      %table:ZZP%
	WHERE
	      D_E_L_E_T_ = ' '
	      %exp:_cFiltro%	      
EndSql

dbSelectArea(_cAlias)
(_cAlias)->(dbGotop())    

_cRet:= StrZero((_cAlias)->CODIGO + 1,6)          

//====================================================================================================
// Finaliza a area criada anteriormente.
//====================================================================================================
DBSelectArea(_cAlias)
(_cAlias)->( DBCloseArea() )

While !MayIUseCode( "ZZP_CODIGO_"+ xFilial("ZZP") + _cRet ) // verifica se esta na memoria, sendo usado busca o proximo numero disponivel
	_cRet := Soma1(_cRet)
EndDo

RestArea(_aArea)

Return( _cRet )

/*
===============================================================================================================================
Programa--------: AOMS56Val(lLimpa,cCampo)
Autor-----------: Alex Wallauer
Data da Criacao-: 07/07/2017
===============================================================================================================================
Descri��o-------: Funcao usada em valid e x3_relacao e rdmake
===============================================================================================================================
Parametros------: lLimpa: Limpa os campos , cCampo:= campo que chamou
===============================================================================================================================
Retorno---------: .T. OU .f. ou Descricao
===============================================================================================================================
*/
USER Function AOMS56Val(lLimpa,cCampo)

Local aArea     := GetArea()
Local IsEnchOld := GetMv("MV_ENCHOLD",,"2") == "1"
Local nPosCpo   := 0
Local nPos1     := 0
Local nPos2     := 0
Local cText	    := ""	
Local cVar      := ""
Local _lRet     := .T.
LOCAL _cAliasBusca:="SA1"
LOCAL _cCampoBusca:="A1_NOME"

DEFAULT cCampo := ReadVar()
DEFAULT lLimpa := .F.

IF cCampo = "M->ZZP_CLIENT" //"X3_VLDUSER"

  IF Empty(M->ZZP_CLIENT)
     M->ZZP_DESCLI := " "
     RETURN .T.
  ENDIF

  If M->ZZP_TIPO $ cTipoOPFor
     _cAliasBusca:="SA2"
     _cCampoBusca:="A2_NOME"
  ENDIF

  IF !Empty(M->ZZP_LOJA)
      _lRet:=EXISTCPO(_cAliasBusca,M->ZZP_CLIENT+M->ZZP_LOJA)
  ELSE
      _lRet:=EXISTCPO(_cAliasBusca,M->ZZP_CLIENT)
  ENDIF

  IF _lRet
     M->ZZP_DESCLI := POSICIONE(_cAliasBusca,1,XFILIAL(_cAliasBusca)+M->ZZP_CLIENT+M->ZZP_LOJA,_cCampoBusca)
  ENDIF

  RETURN _lRet
  
ELSEIF cCampo = "M->ZZP_LOJA" //"X3_VLDUSER"

  IF Empty(M->ZZP_LOJA)
     M->ZZP_DESCLI := " "
     RETURN .T.
  ENDIF

  If M->ZZP_TIPO $ cTipoOPFor
     _cAliasBusca:="SA2"
     _cCampoBusca:="A2_NOME"
  ENDIF

  IF ExistCpo(_cAliasBusca,M->ZZP_CLIENT+M->ZZP_LOJA)
     M->ZZP_DESCLI := POSICIONE(_cAliasBusca,1,XFILIAL(_cAliasBusca)+M->ZZP_CLIENT+M->ZZP_LOJA,_cCampoBusca)
     RETURN .T.
  ELSE
     RETURN .F.
  ENDIF

ELSEIF cCampo = "ZZP_DESCLI"//"X3_RELACAO" 

  IF INCLUI
     RETURN " "
  ENDIF

  If ZZP->ZZP_TIPO $ cTipoOPFor
     _cAliasBusca:="SA2"
     _cCampoBusca:="A2_NOME"
  ENDIF

  RETURN  POSICIONE(_cAliasBusca,1,XFILIAL(_cAliasBusca)+ZZP->ZZP_CLIENT+ZZP->ZZP_LOJA,_cCampoBusca)

ELSEIF cCampo = "M->ZZP_TIPO" //"X3_VALID"  

   cVar  := M->ZZP_TIPO

ENDIF

If IsEnchOld
   nPosCpo := aScan(oMsMGet:aGets, {|x| "ZZP_CLIENT" $ x })
   nPos1   := Val(SubStr(oMsMGet:aGets[nPosCpo],1,2))
   nPos2   := Val(SubStr(oMsMGet:aGets[nPosCpo],3,1))
   If nPos2 = 2
      nPos2:= 3
   Endif
   cText:= aTela[nPos1][nPos2]
Else
   cText:= oMsMGet:GetText("ZZP_CLIENT")
Endif

If cVar $ cTipoOPFor
   cText := "Cod. Fornece"
Else
   cText := AllTrim(RetTitle("ZZP_CLIENT"))
EndIf

If IsEnchOld
   oMsMGet:aTela[nPos1][nPos2]:= cText
Else
   oMsMGet:SetText("ZZP_CLIENT", cText )
Endif
    
If lLimpa .AND. _lTESimplesNac
   //Array criado para trocar o F3 do cliente quando FOR O CODIGO 9F
   IF ( cVar $ cTipoOPFor )
      aTrocaF3 := {{"ZZP_CLIENT","FOR"}}
   Else
      aTrocaF3 = {}
   EndIf
   M->ZZP_CLIENT:=Space(Len(ZZP->ZZP_CLIENT))
   M->ZZP_LOJA  :=Space(Len(ZZP->ZZP_LOJA))
   M->ZZP_DESCLI:= " "
EndIf

lRefresh := .T.
RestArea(aArea)
Return .T.