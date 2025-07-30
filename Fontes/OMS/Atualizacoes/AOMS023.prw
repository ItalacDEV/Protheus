/*
================================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
================================================================================================================================
       Autor  |    Data    |                                             Motivo                                          
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 24/05/2019 | Chamado 29319. Incluir um bot�o e uma rotina que permita a copia de descontos contratuais. 
--------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 14/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
--------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 15/10/2019 | Chamado 30895. Corrigido error.log na inclus�o de descontos. 
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 03/01/2022 | Chamado 32176. Alterar Rotina Inser��o de Abatimento Descontos Contratuais e Incluir Valida��o. 
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 08/04/2022 | Chamado 39590. Corre��o na Inclus�o novos itens via tecla F3 e corre��o Error log na filtragem. 
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 14/04/2022 | Chamado 39177. Inclus�o de filtro p/grupo de produto e bot�o para atualizar percentual em lotes.
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 30/05/2022 | Chamado 40234. Realiza��o de corre��es na rotina de descontos contratuais.
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 02/03/2023 | Chamado 42820. Criar nova op��o de filtro % desconto possibilitando alterar em lotes pelo filtro.
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 01/09/2023 | Chamado 44635. Criar uma nova op��o de filtro por Mix BI. 
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 21/09/2023 | Chamado 45027. Desenvolver rotina que permite exportar dados do contrato posicionado para Excel. 
 -------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 27/09/2023 | Chamado 45155. Ajustar rotina para permitir filtrar produtos e clientes bloqueados. 
 -------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 13/10/2023 | Chamado 45217. Corre��o da valida��o do abatimento n�o preenchido na tela de aprova��o.
=-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 22/12/2023 | Chamado 45933. Corre��o DO ERROR.LOG da variavel _lHaFiltro.
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================
Ant�nio  - Julio Paz     - 13/02/25 - 17/02/25 - 49768   - Corre��es na exclus�o e inclus�o de itens na rotina de manuten��o de descontos contratuais.
==============================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa----------: AOMS023
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Rotina para dar manuten��o no cadastro de Descontos Contratuais
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS023()

Private cCadastro	:= "Descontos Contratuais"
Private cDelFunc	:= ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private aCores		:= {}
Private bVisual   	:= {|| AOMS023Q('V')}
Private bInclui		:= {|| AOMS023Q('I')}
Private bAltera		:= {|| AOMS023Q('A')}
Private bExclui		:= {|| AOMS023Q('E')}
Private bAprovacao	:= {|| AOMS023Q('P')}
Private bhistorico 	:= {|| AOMS023H()}
Private bLegend		:= {|| AOMS023Y()}
Private bCopiar		:= {|| U_AOMS023F()}

Private aRotina	:= {	{ "Pesquisar"      , "AxPesqui"        ,0,1    },;
						      { "Visualizar"     , 'Eval(bVisual)'   ,0,2    },;
						      { "Incluir"        , 'Eval(bInclui)'   ,0,3    },;
						      { "Alterar"        , 'Eval(bAltera)'   ,0,4,20 },;
						      { "Excluir"        , 'Eval(bExclui)'   ,0,5,21 },;
						      { "Aprovacao"      , 'Eval(bAprovacao)',0,6,21 },;
						      { "Historico"      , 'Eval(bhistorico)',0,6,21 },;
						      { "Conhecimento"   , 'MsDocument'      ,0,4,00 },;
						      { "Legenda"        , 'Eval(bLegend)'   ,0,4,20 },;
						      { "Imprimir"       , "U_ROMS012()"     ,0,4,20 },;
						      { "Gera Excel"     , "U_AOMS023J()"    ,0,4,20 },; 
                        { "Copiar Contrato","Eval(bCopiar)"    ,0,4,20 }}

Private _cProduto, _cCliente, _cLoja, _cRede

Private _cFiltroContrato := Space(12)
Private _cFiltroCliente  := Space(6)
Private _cFiltroLoja     := Space(4)
Private _cFiltroPrd      := Space(15)
Private _cFiltroUF       := Space(2)
Private _cFiltroExato    := Space(1)
Private _cGrupoPrd       := Space(4) // Grupo de Produtos 
Private _nFiltPerc       := 0   
Private _oBrowse	     := Nil
Private _aBkpACols       := {}
Private _aBkpFiltro      := {}
Private oGetDados
Private _nLinFiltro := 0
Private _lHaFiltro := .F.

aCores := {	{ "ZAZ_DTFIM<DDATABASE .And. ZAZ_MSBLQL == '2' "	, 'BR_PRETO'	},; //Encerrado( Preto )
			 {   "ZAZ_MSBLQL == '2' .And. ZAZ_STATUS == 'N' "		, 'BR_AMARELO'	},; //Ativo( Amarelo )
			 {   "ZAZ_STATUS == 'S' .And. ZAZ_MSBLQL =='2' "		, 'ENABLE'		},; //Aprovado pelo financeiro( VERDE )
			 {   "ZAZ_MSBLQL == '1'"								      , 'DISABLE'		} } //Bloqueado( Vermelho )

DBSelectArea("ZAZ")
ZAZ->( DBSetOrder(1) )
mBrowse( ,,,, "ZAZ" ,,,,,, aCores )

Return()

/*
===============================================================================================================================
Programa----------: AOMS023Y
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Mostra a tela de legendas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS023Y()

Local aLegenda  := {}

aLegenda := {{"ENABLE"		, "Aprovado pelo Financeiro"				      },;
				{ "BR_AMARELO"	, "Ativo - Aguardando liberacao Financeiro"	},;
				{ "DISABLE"		, "Bloqueado"								         },;
				{ "BR_PRETO"	, "Encerrado"								         } }

BrwLegenda( cCadastro , "Legenda" , aLegenda )

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS023Q
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Mostra a tela de manuten��o do cadastro
===============================================================================================================================
Parametros--------: cOpcBrw - op��o de browse - 	V - Visualiza
														I - Inclui
														A - Altera
														P - Aprova��o
														E - Exclui
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS023Q( cOpcBrw )

Local cTitulo		:= "Descontos Contratuais"
Local nOpcao		:= 0
Local nUsado		:= 0
Local nProc			:= 0
Local aSize			:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
Local lBotaoOk		:= .F.			//Valida se o usuario pressionou o botao de Ok da Tela
Local lInclui		:= .F.			//Valida se trata de Inclusao
Local lAltera		:= .F.			//Valida se trata de Alteracao
Local lExclui		:= .F.			//Valida se trata de Exclusao
Local lEdita		:= .F.			//Define o acesso a rotina, Edicao(.T.) ou Visualizacao(.F.).
Local nStack		:= GetSX8Len()	//Tratamento para executar o RollBack no codigo
Local aTela			:= {}
Local aGets			:= {}
Local oDlg1			:= Nil
Local aBotoes		:= {} 
Local _nI, x
Local _nPosItem
Local _nLinha       := 0 //105  
Local _nCliente	
Local _aBackHead  := {}   
Local _aCmpEdit   := {}
                                                  
Private cOpcaoMenu	:= cOpcBrw								             // Armazena a opcao escolhida(Inserir, Aprovar, excluir, alterar) pelo usuario para posterior validacao
Private bVldLin		:= {|| AOMS023L()}					             // Bloco de execucao de validacao da linha
Private bVldTela	:= {|| AOMS023T()}						             // Bloco de execucao de validacao da tela
Private aHeader		:= {}										             // Campos dos Itens
Private aCols		:= {}											             // Conteudo dos campos dos Itens
Private aAux		:= {}											             // aCols auxiliar para gravacao dos dados
Private cAliasCab	:= "ZAZ"										             // Nome da Tabela do Cabecalho
Private cLogCab	    := "Z17"								             // Nome da Tabela de log do Cabecalho
Private cLogItm	    := "Z18"								             // Nome da Tabela de log do item
Private cCmpCod1	:= "ZAZ_COD"								             // Nome do campo Codigo no cabecalho
Private cCmpFil1	:= "ZAZ_FILIAL"							             // Nome do campo Filial no cabecalho
Private cChaveCab	:= (cAliasCab)->(ZAZ_FILIAL+ZAZ_COD)             // Chave de indice do cabecalho
Private cAliasItm	:= "ZB0"										             // Nome da Tabela de Itens
Private cCondicao	:= "(cAliasItm)->(ZB0_FILIAL+ZB0_COD)"			    // Condicao de comparacao ou relacionamento entre o cabecalho e item(Filial + Codigo)
Private cIndItem	:= "(cAliasItm)->(ZB0_FILIAL+ZB0_COD+ZB0_ITEM)"	 // Indice do Item
Private cCmpFil2	:= "ZB0_FILIAL"									       // Nome do campo Filial no item
Private cCmpCod2	:= "ZB0_COD"									          // Nome do campo Codigo no item
Private cCmpItem	:= "ZB0_ITEM"									          // Nome do Campo de item
Private cCmpPro		:= "ZB0_SB1COD"									    // Nome do Campo de Produto ou algo do tipo no item
Private cUsuario	:= ""
Private cContrato	:= ""
Private _cZ17Alterados, _aZ18Alterados   
Private _lGravaDados := .F.
Private aHeaderZAZ	:= {}											          // Campos dos Itens
Private _lHaFiltro := .F.
Private _aItemMix  := {"G1=Grupo 1","G2=Grupo 2","G3=Grupo 3","G9=Outros","G0=Indefinido","  "}
Private _cGrpMix := Space(2)
Private _oGrpMix := Nil 

Begin Sequence
   //============================================================================
   //Montagem do aheader                                                        
   //=============================================================================
   FillGetDados(1,"ZAZ",1,,,{||.T.},,,,,,.T.)
   aHeaderZAZ	:= AClone(aHeader)

   aHeader := {}
   FillGetDados(1,"ZB0",1,,,{||.T.},,,,,,.T.)
   //nUsado := Len(aHeader)
   
   _nCliente := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_CLIENT"})
   
   aHeader[_nCliente,6] := 'U_AOMS023X("ZB0_CLIENT")'  // Grava para o campo ZB0_CLIENT fun��o customizada de valida��o.

   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   _aBackHead := AClone(aHeader)
   
   aHeader := {}

   For _nI := 1 To Len(_aBackHead)  
       
       Aadd(aHeader  , _aBackHead[_nI])
       Aadd(_aCmpEdit, _aBackHead[_nI,2])

       If AllTrim(_aBackHead[_nI,2]) == "ZB0_ITEM"
          
          //AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
          AADD(aHeader, {Getsx3cache("BM_GRUPO","X3_TITULO"),;
                         "BM_GRUPO",;
                         Getsx3cache("BM_GRUPO","X3_PICTURE"),;
                         Getsx3cache("BM_GRUPO","X3_TAMANHO"),;
                         Getsx3cache("BM_GRUPO","X3_DECIMAL"),;
                         "AllwaysTrue()",;
                         Getsx3cache("BM_GRUPO","X3_USADO"),;
                         Getsx3cache("BM_GRUPO","X3_TIPO"),;
                         Getsx3cache("BM_GRUPO","X3_ARQUIVO"),;
                         "V"})                                  // Getsx3cache("BM_GRUPO","X3_CONTEXT")
       
       ElseIf AllTrim(_aBackHead[_nI,2]) == "ZB0_EST"   
          AADD(aHeader, {Getsx3cache("B1_I_BIMIX","X3_TITULO"),;
                                     "B1_I_BIMIX",;
                                     Getsx3cache("B1_I_BIMIX","X3_PICTURE"),;
                                     Getsx3cache("B1_I_BIMIX","X3_TAMANHO"),;
                                     Getsx3cache("B1_I_BIMIX","X3_DECIMAL"),;
                                     "AllwaysTrue()",;
                                     Getsx3cache("B1_I_BIMIX","X3_USADO"),;
                                     Getsx3cache("B1_I_BIMIX","X3_TIPO"),;
                                     Getsx3cache("B1_I_BIMIX","X3_ARQUIVO"),;
                                     "V"})                                  // Getsx3cache("BM_GRUPO","X3_CONTEXT")
       EndIf 

   Next 

   nUsado := Len(aHeader)

   aGets := {}
   aTela := {}
   
   Aadd( aBotoes , { "RESPONSA" , {|| AOMS023Z() }  , "Replicar Abatimento..." , "Abatimento" } )
   Aadd( aBotoes , { "RESPONSA" , {|| U_AOMS023G()} , "% Desconto em Lotes..." , "% Desconto em Lotes" } )

   cUsuario := U_UCFG001(1)

   DBSelectArea("ZZL")
   DBSetOrder(1)
   If DBSeek(xFilial("ZZL") + cUsuario )

	  If cOpcBrw == "P" .And. ZZL->ZZL_APRCON <> 'S'
	     u_itmsg("Voce nao tem acesso ao sistema, favor contactatar o depto financeiro.","INFORMACAO",;
		         "O usuario pode estar sem matricula no cadastro de usuarios ou nao ter acesso ao sistema. Caso o problema persista favor contactar o administrador do sistema.",1)
	     Break 
	  EndIf

	  If ( ( cOpcBrw == "I" ) .Or. ( cOpcBrw == "A" ) .Or. ( cOpcBrw == "E" ) ) .And. ZZL->ZZL_CONTRA <> 'S'
	
	     u_itmsg("Voce nao tem acesso ao sistema, favor contactatar o depto comercial.","INFORMACAO",;
			     "O usuario pode estar sem matricula no cadastro de usuarios ou nao ter acesso ao sistema. Caso o problema persista favor contactar o administrador do sistema.",1)
	     Break 
		
      EndIf
   Else
      u_itmsg("Voce nao tem acesso ao sistema, favor contactatar o depto financeiro.",;
			  "O usuario pode estar sem matricula no cadastro de usuarios ou nao ter acesso ao sistema. Caso o problema persista favor contactar o administrador do sistema.",1)
      Break 
   EndIf

   //====================================================================================================
   // Verifica qual opcao no Browse o usuario acessou
   //====================================================================================================
   Do Case
	  Case cOpcBrw == "V" // Visualizar
		   nOpcao := 2
		   lEdita := .F.
	  Case cOpcBrw == "I" // Incluir
		   nOpcao  := 3
		   lInclui := .T.
		   lEdita  := .T.
		   _lGravaDados := .T.
	  Case cOpcBrw == "A" // Alterar
		   nOpcao  := 3
		   lAltera := .T.
		   lEdita  := .T.
	  Case cOpcBrw == "E" // Excluir
		   nOpcao  := 2
		   lExclui := .T.
		   lEdita  := .F.
		   _lGravaDados := .T.
		
	  Case cOpcBrw == "P" // Aprovacao do Financeiro
		   nOpcao  := 3
		   lAltera := .T.
		   lEdita  := .F.	
		   _lGravaDados := .T.
   EndCase

   //====================================================================================================
   // Carrega os campos do cabecalho como variaveis de Memoria( M->XX_XXX )
   //====================================================================================================
   RegToMemory( cAliasCab , (cOpcBrw == "I") )

   //====================================================================================================
   // Verifica a opcao escolhida no Browse: Visualizar ou Incluir ou Alterar ou Excluir.
   //====================================================================================================
   If nOpcao != 0
	  //====================================================================================================
	  // Armazena a posicao que identifica se o item esta deletado
	  //====================================================================================================
	  nPosDel := Len(aHeader)+1
	
	  //====================================================================================================
	  // Verifica se o usuario escolheu a opcao Incluir no Browse
	  //====================================================================================================
	  If cOpcBrw == "I"
		 aCols := { Array(nUsado+1) }
		 aCols[1,nUsado+1] := .F.
		
		 For x:= 1 to nUsado
		     If ! AllTrim(aHeader[x,2]) $ "ZB0_ALI_WT/ZB0_REC_WT" // /BM_GRUPO/B1_I_BIMIX
			    aCols[1,x]:= CriaVar(aHeader[x,2])
			    If ( AllTrim(aHeader[x][2]) == cCmpItem )
				   aCols[1][x] := "000001"
			    EndIf
		     EndIf
		 Next x
	  Else // Visualizacao / Alteracao / Exclusao
		 //====================================================================================================
		 // Limpa o aCols e o aCols Auxiliar para prenchelos com os itens ja existentes na tabela
		 //====================================================================================================
		 aCols := {}
		 aAux  := {}

		 //====================================================================================================
		 // Posiciona no primeiro registro da Tabela para montar o aCols com os itens
		 //====================================================================================================
		 dbSelectArea(cAliasItm)
		 dbSetOrder(1)
		 MsSeek(cChaveCab)
		 Do While (cAliasItm)->(!Eof()) .And. &(cCondicao) == cChaveCab
			AAdd(aCols,Array(nUsado+1))
			For nProc := 1 to nUsado
             If AllTrim(aHeader[nProc,2]) == "BM_GRUPO"
                aCols[Len(aCols),nProc] := Posicione("SBM",1,xFilial('SBM')+ (cAliasItm)->ZB0_SB1COD,"BM_GRUPO")   
//----------------------------------------------------
             ElseIf AllTrim(aHeader[nProc,2]) == "B1_I_BIMIX"  
                aCols[Len(aCols),nProc] := Posicione("SB1",1,xFilial('SB1')+ (cAliasItm)->ZB0_SB1COD,"B1_I_BIMIX") 
//----------------------------------------------------
			    ElseIf ! AllTrim(aHeader[nProc,2]) $ "ZB0_ALI_WT/ZB0_REC_WT/BM_GRUPO/B1_I_BIMIX"  
				   aCols[Len(aCols),nProc]:= FieldGet(FieldPos(aHeader[nProc,2]))
				   If AllTrim(aHeader[nProc,2]) == cCmpItem
					  AAdd(aAux,{&cIndItem})
				   Endif
				EndIf

			Next nProc
			aCols[Len(aCols),nUsado+1]:= .F.
			
		    (cAliasItm)->(dbSkip())
		 EndDo
	  Endif
	
      //====================================================================================================
	  // Se existe itens para mostrar, chama a tela com os dados a serem apresentados
	  //====================================================================================================
	  If Len(aCols) > 0
		 //====================================================================================================
		 // Define o tamanho da tela e faz tratamento para dimensionamento qdo usado resolucoes diferentes
		 //====================================================================================================
		 aSize := MsAdvSize()
	  	 aObjects := {}
		 AAdd( aObjects, { 100, 100, .T., .T. } )
		 AAdd( aObjects, { 100, 100, .T., .T. } )
		 AAdd( aObjects, { 100, 015, .T., .F. } )
		
		 aInfo         := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
		 aPosObj       := MsObjSize(aInfo,aObjects)
		
		 //====================================================================================================
		 // Ajuste Manual no tamanho da Tela
		 //====================================================================================================
		 aPosObj[1][3] -= 55.5 //Aumenta para cima  a Enchoice
		 aPosObj[2][1] -= 55.0 //Aumenta para cima  a MsGetDados
		 aPosObj[2][3] += 15.0 //Aumenta para baixo a MsGetDados
		
		 _aPosGetD := AClone(aPosObj)
		
		 _aPosGetD[2,1] += 30  // Posiciona o objeto MSGETDADOS um pouco mais abaixo na tela.
		 aPosObj[1,3] -= 15  // Diminui o espa�o ocupado pelo objeto Enchoice na tela, em algumas linha.
		
       _aBkpACols := AClone(aCols) 
       
		 //====================================================================================================
		 // Tela estilo Modelo 3 - Cabecalho e Itens
		 //====================================================================================================
		 DEFINE MSDIALOG oDlg1 TITLE cTitulo FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		    
		    EnChoice(cAliasCab,(cAliasCab)->(Recno()),nOpcao,  ,   ,  ,  ,aPosObj[1],,3)
		    
		    _nLinha := _aPosGetD[2,1] - 45
		            
            @ _nLinha, 015 Button 'FILTRAR' Size 45, 15 Message 'Filtrar dados de regras de comiss�o' Pixel Action AOMS023M( 'FILTRAR' ) of oDlg1
            @ _nLinha + 20, 015 Button 'LIMPAR FILTRO' Size 45, 15 Message 'Limpar o filtro das regras de comiss�o' Pixel Action AOMS023M( 'LIMPARFILTRO' ) of oDlg1

            @ _nLinha, 070 Say "Grupo Produtos:"	Pixel Size 018,006  Of oDlg1
            //@ _nLinha + 10, 070 MSGet _cGrupoPrd F3 "SBM" Valid(Vazio() .Or. ExistCpo("SBM",_cGrupoPrd)) Pixel Size 060,009 Of oDlg1
            @ _nLinha + 10, 070 MSGet _cGrupoPrd F3 "SBM" Valid(Vazio() .Or. AOMS23VLD("GRUPO_PRODUTO")) Pixel Size 060,009 Of oDlg1

            @ _nLinha, 070 + 70 Say "Produto:"	Pixel Size 018,006  Of oDlg1  
            //@ _nLinha + 10, 070 + 70 MSGet _cFiltroPrd F3 "SB1" Valid(Vazio() .Or. ExistCpo("SB1",_cFiltroPrd)) Pixel Size 060,009 Of oDlg1
            @ _nLinha + 10, 070 + 70 MSGet _cFiltroPrd F3 "SB1" Valid(Vazio() .Or. AOMS23VLD("PRODUTO")) Pixel Size 060,009 Of oDlg1

            @ _nLinha, 140 + 70 Say "Contrato Italac:"	Pixel Size 018,006 Of oDlg1
            @ _nLinha + 10, 140 + 70 MSGet _cFiltroContrato  Pixel Size 040,009 Of oDlg1

            @ _nLinha, 190 + 70 Say "Cliente:"	Pixel Size 018,006 Of oDlg1  
            //@ _nLinha + 10, 190 + 70 MSGet _cFiltroCliente  F3 "SA1" Valid(Vazio() .Or. ExistCpo("SA1",_cFiltroCliente)) Pixel Size 040,009 Of oDlg1
            @ _nLinha + 10, 190 + 70 MSGet _cFiltroCliente  F3 "SA1" Valid(Vazio() .Or. AOMS23VLD("CLIENTE")) Pixel Size 040,009 Of oDlg1

            @ _nLinha, 240 + 70 Say "Loja:"	Pixel Size 018,006 Of oDlg1     
            //@ _nLinha + 10, 240 + 70 MSGet _cFiltroLoja Valid(Vazio() .Or. ExistCpo("SA1",_cFiltroCliente+_cFiltroLoja)) Pixel Size 030,009 Of oDlg1
            @ _nLinha + 10, 240 + 70 MSGet _cFiltroLoja Valid(Vazio() .Or. AOMS23VLD("CLIENTE_LOJA")) Pixel Size 030,009 Of oDlg1
            
            @ _nLinha , 280 + 70 Say "Estado:"	Pixel Size 018,006  Of oDlg1
            @ _nLinha + 10, 280 + 70 MSGet _cFiltroUF F3 "12" Valid(Vazio() .Or. ExistCpo("SX5","12" + _cFiltroUF)) Pixel Size 040,009 Of oDlg1
      
            @ _nLinha, 330 + 70 Say "% Desconto:"	Pixel Size 030,006 Of oDlg1
            @ _nLinha + 10, 330 + 70 MSGet _nFiltPerc Picture "@E 999.99" Pixel Size 040,009 Of oDlg1
 
            @ _nLinha, 380 + 70 Say "Mix BI:"	Pixel Size 030,006 Of oDlg1
            @ _nLinha + 10, 380 + 70 MSCOMBOBOX _oGrpMix Var _cGrpMix ITEMS _aItemMix Pixel Size 050, 020 Of oDlg1

            @ _nLinha, 440 + 70 Say "Filtro Exato?"	Pixel Size 030,006 Of oDlg1
            @ _nLinha + 10, 440 + 70 MSCOMBOBOX _oFiltroExato Var _cFiltroExato ITEMS {"S=Sim","N=Nao"} Valid (Pertence('SN')) Pixel Size 040, 020 Of oDlg1

    //    oGetDados := MsGetDados():New(05            , 05           , 145          , 195          , 4    , "U_LINHAOK"   , "U_TUDOOK"     , "+A1_COD"    , .T.  , {"A1_NOME"},   , .F., 200   , "U_FIELDOK"   , "U_SUPERDEL", , "U_DELOK", oDlg)
		    oGetDados := MsGetDados():New(_aPosGetD[2,1],_aPosGetD[2,2],_aPosGetD[2,3],_aPosGetD[2,4],nOpcao,"Eval(bVldLin)","Eval(bVldTela)",("+"+cCmpItem),lEdita, _aCmpEdit  ,1  ,    ,99999  , "U_AOMS023C" )
		    
		    // Foi declarado o numero maximo de linhas igual a 99999 pois o mesmo n�o havia sido declarado e o sistema reconhece como padr�o 99 o que estava impedindo
		    // o usuario de incluir mais produtos no com mais de 100 itens. 
	  		
		 ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||lBotaoOk:=.T.,If(AOMS023O() ,If(!oGetdados:TudoOk(),lBotaoOk:=.F.,;
				  If (!U_AOMS023I(M->ZAZ_GRPVEN,M->ZAZ_CLIENT,M->ZAZ_LOJA),lBotaoOk:=.F.,Eval({||lBotaoOk:=.T.,oDlg1:End()}))),lBotaoOk:=.T.)},{||oDlg1:End()},,aBotoes)

		 //====================================================================================================
		 // Se o usuario confirmar no botao de Ok da tela
		 //====================================================================================================
		 If lBotaoOk
			If lInclui
			   Begin Transaction
			      fwmsgrun( ,{|| U_AOMS023N() }, "Aguarde...", "Incluindo contrato...",.F.)
			      ConfirmSX8()
			   End Transaction
			ElseIf lAltera
			   //===================================================================================
			   // Criar variaveis privates para armazenar os itens alterados
			   // Apenas se existirem itens alterados os dados ser�o atualizados. 
			   //===================================================================================
			   _cZ17Alterados := ""
			   _aZ18Alterados := {}
			    
			   ZB0->(DbSetOrder(1))
	     
	           //===================================================================================
			   // Verifica se existe algum item excluido ou incluido
			   //===================================================================================
			   _nPosItem := Ascan(aHeader,{|x| AllTrim(x[2]) == "ZB0_ITEM" })
			    
			   For _nI := 1 To Len(aCols)
                   If aCols[_nI,nPosDel]			    
			          _lGravaDados := .T. // Existe item excluido   
                   ElseIf !ZB0->(DbSeek(xFilial("ZB0")+M->ZAZ_COD+aCols[_nI,_nPosItem]))	    
                      _lGravaDados := .T. // Existe item incluido 
                   EndIf
			   Next
			    
			   If U_AOMS023V(@_cZ17Alterados,@_aZ18Alterados) .Or. _lGravaDados
				  fwmsgrun( , {|| U_AOMS023A() }, "Aguarde...", "Alterando contrato...",.F.)
			   Else
				  U_ItMsg("Nenhum dado foi alterado!","Aten��o",,1)
		       EndIf
		    ElseIf lExclui
			   fwmsgrun( , {|oproc| U_AOMS023E(oproc) }, "Aguarde...", "Excluindo contrato...",.F.)
		    Endif
		 Else //Botao Cancelar
			While GetSX8Len() > nStack
			   RollBackSX8()
			EndDo
		 Endif
	  Else
		 u_itmsg("Nao existem itens para este documento!","Aten��o",,1)
		 Break 
	  Endif
	
   Endif
End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS023N
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Rotina para Incluir os Registros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS023N()
Local _nPosItem   := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ITEM"})
Local nConIten := 0			//Conta os itens do aCols
Local nConCmp  := 0			//Conta os campos do aHeader
Local nConCab  := 0			//Conta os campos do Cabecalho
Local cCodReg  := ""		//Armazena o Codigo dos Registros
Local cItem    := "000001"	//Incrementa o Codigo do Item do aCols

//====================================================================================================
// Verifica se a Numeracao ja existe, se sim incrementa p/ nao duplicar
//====================================================================================================
dbSelectArea(cAliasCab)
cCodReg := M->&(cCmpCod1)
(cAliasCab)->(dbSetOrder(1))
While ( DbSeek(xFilial(cAliasCab)+cCodReg))
	cCodReg := SOMA1(cCodReg)
	(cAliasCab)->(DbSkip())
EndDo
M->&(cCmpCod1) := cCodReg

//====================================================================================================
// Gravacao dos campos do log do  cabecalho
//====================================================================================================
dbSelectArea(cLogCab)
RecLock(cLogCab,.T.)
For nConCab := 1 To FCount()                                                         
	If !( "FILIAL" $ FieldName(nConCab) ) .And. !( "VERSAO" $ FieldName(nConCab) ) .And. !( "DELET" $ FieldName(nConCab) ) .And. !( "DATA" $ FieldName(nConCab) ) .And. !( "HORA" $ FieldName(nConCab) ) .And. !( "USUAR" $ FieldName(nConCab) ) .And. !( "DSCALT" $ FieldName(nConCab) ) 
		FieldPut(nConCab,M->&("ZAZ" + SUBSTR(FieldName(nConCab),4,50)))
	EndIf
Next nConCab

(cLogCab)->Z17_DSCALT := "Inclus�o de Contrato."

//Gera pr�xima vers�o
cQuery := "SELECT max(Z17_VERSAO) numrec" 
cQuery += " FROM " + RetSqlName("Z17")
cQuery += " WHERE D_E_L_E_T_  <> '*' "
cQuery += " AND Z17_COD = '" + M->ZAZ_COD + "'"

If Select("TMP16") > 0
	TMP16->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP16",.T.,.T.)

If TMP16->( Eof() )

	 _cseque := '00'
	 
Else

	_cseque := soma1(TMP16->numrec)
	
Endif


(cLogCab)->Z17_DSCALT := "INCLUS�O DE DADOS"
(cLogCab)->Z17_DATA := DATE()
(cLogCab)->Z17_HORA := TIME()
(cLogCab)->Z17_USUAR := U_UCFG001(1)
(cLogCab)->Z17_VERSAO := _cseque

(cLogCab)->(MsUnlock())

//====================================================================================================
// Gravacao dos Itens
//====================================================================================================
For nConIten := 1 to Len(aCols)
	
	//====================================================================================================
	// Valida se o registro nao esta deletado
	//====================================================================================================
	If (! GdDeleted(nConIten))
		dbSelectArea(cLogItm)
		RecLock(cLogItm, .T.)
		For nConCmp := 1 to Len(aHeader)
			//====================================================
			// Validacao de campo virtual, so grava se nao for. 
			//====================================================
							
			If (aHeader[nConCmp,10] <> "V")
				FieldPut(FieldPos("Z18" + SUBSTR(aHeader[nConCmp,2],4,50)), aCols[nConIten, nConCmp])
			EndIf
		Next nConCmp
		
		(cLogItm)->&(cCmpFil2) := xFilial(cLogItm)
		(cLogItm)->&(cCmpCod2) := cCodReg
		(cLogItm)->&(cCmpItem) := cItem
		(cLogItm)->Z18_DATA := DATE()
		(cLogItm)->Z18_HORA := TIME()
		(cLogItm)->Z18_USUAR := U_UCFG001(1)
		(cLogItm)->Z18_COD := Z17->Z17_COD
		(cLogItm)->Z18_VERSAO := _cseque
		(cLogItm)->Z18_DSCALT := "INCLUS�O DE DADOS"		
		
		(cLogItm)->(MsUnlock())
		cItem := SOMA1(cItem)
	EndIf
Next nConIten

//====================================================================================================
// Gravacao dos campos do cabecalho
//====================================================================================================
dbSelectArea(cAliasCab)
RecLock(cAliasCab,.T.)
For nConCab := 1 To FCount()
	If ("FILIAL" $ FieldName(nConCab) )
		FieldPut(nConCab,xFilial(cAliasCab))
	Else
		FieldPut(nConCab,M->&(FieldName(nConCab)))
	EndIf
Next nConCab

(cAliasCab)->(MsUnlock())

//====================================================================================================
// Gravacao dos Itens
//====================================================================================================
For nConIten := 1 to Len(aCols)
	
	//====================================================================================================
	// Valida se o registro nao esta deletado
	//====================================================================================================
	If (! GdDeleted(nConIten))
		dbSelectArea(cAliasItm)
		RecLock(cAliasItm, .T.)
		For nConCmp := 1 to Len(aHeader)
			//====================================================
			// Validacao de campo virtual, so grava se nao for. 
			//====================================================
			If (aHeader[nConCmp,10] <> "V")
				FieldPut(FieldPos(aHeader[nConCmp,2]), aCols[nConIten, nConCmp])
			EndIf
		Next nConCmp
		
		(cAliasItm)->&(cCmpFil2) := xFilial(cAliasItm)
		(cAliasItm)->&(cCmpCod2) := cCodReg
		
		If Empty(aCols[nConIten, _nPosItem])
		   (cAliasItm)->&(cCmpItem) := cItem
		   cItem := SOMA1(cItem)
		Else
		   (cAliasItm)->&(cCmpItem) := aCols[nConIten, _nPosItem]
		EndIf

	   (cAliasItm)->(MsUnlock())
	EndIf
Next nConIten

Return

/*
===============================================================================================================================
Programa----------: AOMS023A
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Alteracao dos arquivos de Cabecalho e Item.  
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS023A()

Local aItemDel := {}
Local nConCab  := 1
Local nConIten := 1
Local nConCmp  := 1
Local _nI, _lEstaAlterado, _nJ
Local _cParteNome
Local _nPosDel := Len(aHeader)+1
Local _nPosCod, _nPosItem
Local _lAchouZB0
Local _nNrItem

Begin Sequence
   If Empty(_cZ17Alterados) .And. Empty(_aZ18Alterados) .And. !_lGravaDados // Significa que n�o houve altera��es e Existe uma Inclus�o ou Exclus�o de item.  
      Break
   EndIf
   
   //==========================================================================
   // Gravacao do log dos campos Alterados no cabecalho.                            
   //==========================================================================
   dbSelectArea(cLogCab)
   (cLogCab)->(RecLock(cLogCab,.T.))
   For nConCab := 1 To (cLogCab)->(FCount())
       If !( "FILIAL" $ FieldName(nConCab) ) .And. !( "VERSAO" $ FieldName(nConCab) ) .And. !( "DELET" $ FieldName(nConCab) ) .And. !( "DATA" $ FieldName(nConCab) ) .And. !( "HORA" $ FieldName(nConCab) ) .And. !( "USUAR" $ FieldName(nConCab)) .And. !( "DSCALT" $ FieldName(nConCab)) 
          _cParteNome := SubStr((cLogCab)->(FieldName(nConCab)),5,6)
          
          &("Z17->"+(cLogCab)->(FieldName(nConCab))) := &("M->ZAZ_"+_cParteNome)
       EndIf
   Next nConCab  
   Z17->Z17_FILIAL := ZAZ->ZAZ_FILIAL
   Z17->Z17_DSCALT := _cZ17Alterados // Grava quais s�o os campos e o que foi alterado.  
   
   //Grava os dados como filial + matricula do usuario que realizou a aprovacao e a data e hora que foi realiada
   If cOpcaoMenu = 'P'
      Z17->Z17_MATAPR:=u_UCFG001(1)
      Z17->Z17_DTAPRO:=date()
      Z17->Z17_HRAPRO:=time()     
      Z17->Z17_STATUS:='S'
	  // Na alteracao do acordo comercial alterar o status do acordo comercial para haver uma nova liberacao do financeiro,
      // caso ele ja tenho sido liberado anteriormente
   ElseIf cOpcaoMenu = 'A'      
      Z17->Z17_STATUS:='N'    
   EndIf

   //Gera pr�xima vers�o
   cQuery := "SELECT max(Z17_VERSAO) numrec" 
   cQuery += " FROM " + RetSqlName("Z17")
   cQuery += " WHERE D_E_L_E_T_  <> '*' "
   cQuery += " AND Z17_COD = '" + M->ZAZ_COD + "'"

   If Select("TMP16") > 0
	  TMP16->(dbCloseArea())
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP16",.T.,.T.)

   If TMP16->( Eof() )

	  _cseque := '00'
	 
   Else

	  _cseque := soma1(TMP16->numrec)
	
   Endif

   (cLogCab)->Z17_VERSAO := _cseque

   (cLogCab)->Z17_DATA := DATE()
   (cLogCab)->Z17_HORA := TIME()
   (cLogCab)->Z17_USUAR := U_UCFG001(1)

   (cLogCab)->(MsUnlock())

   //==========================================================================
   // Gravacao DO LOG dos Itens.                                                    
   // Altera os registros contidos anteriormente na 1a Inclusao.             
   //==========================================================================
   For nConIten := 1 to Len(acols)
	   //====================================================
	   // Verifica se a atual linha do aCols foi alterada.
	   //====================================================
	   _lEstaAlterado := .F.
	   _nJ := 0
	   For _nI := 1 To Len(_aZ18Alterados) 
	       If _aZ18Alterados[_nI,1] == nConIten
	          _lEstaAlterado := .T.
	          _nJ := _nI // Pega a linha do array _aZ18Alterados referente a atual linha do aCols.
	       EndIf
	   Next
	   
	   If ! _lEstaAlterado .And. ! aCols[nConIten,_nPosDel]	// A atual linha do aCols n�o foi alterada ou n�o foi excluida. Le o proximo registro/linha do aCols.
	      Loop
	   EndIf
	   
	   //===========================================
	   // Valida se o registro nao esta deletado. 
	   //===========================================
	   If ! aCols[nConIten,_nPosDel]	 
		  DbSelectArea(CLogItm)
		  DbSetOrder(1)
		  RecLock(CLogItm, .T.)
		  For nConCmp := 1 to Len(aHeader)
		      //====================================================
	          // Validacao de campo virtual, so grava se nao for. 
		      //====================================================
	          If (aHeader[nConCmp,10] <> "V")
		         FieldPut(FieldPos("Z18" + SUBSTR(aHeader[nConCmp,2],4,50)), aCols[nConIten, nConCmp])
	          EndIf
		  Next nConCmp
          
          (cLogItm)->Z18_COD    := ZAZ->ZAZ_COD  // Grava o c�digo do contrato.
          (cLogItm)->Z18_DSCALT := _aZ18Alterados[_nJ,2] // Grava as altera��es realizadas nos itens dos contratados. 
          (cLogItm)->Z18_DATA   := DATE()
          (cLogItm)->Z18_HORA   := TIME()
          (cLogItm)->Z18_USUAR  := U_UCFG001(1)
          (cLogItm)->Z18_COD    := Z17->Z17_COD
          (cLogItm)->Z18_VERSAO := _cseque
          
          (CLogItm)->(MsUnlock())
       Else
          //========================================================
          // Registra no hist�rico o item excluido 
          //========================================================
          DbSelectArea(CLogItm)
		  DbSetOrder(1)
		  RecLock(CLogItm, .T.)
		  For nConCmp := 1 to Len(aHeader)
		      //====================================================
	          // Validacao de campo virtual, so grava se nao for. 
		      //====================================================
	          If (aHeader[nConCmp,10] <> "V")
		         FieldPut(FieldPos("Z18" + SUBSTR(aHeader[nConCmp,2],4,50)), aCols[nConIten, nConCmp])
	          EndIf
		  Next nConCmp
          
          (cLogItm)->Z18_COD    := ZAZ->ZAZ_COD  // Grava o c�digo do contrato.
          (cLogItm)->Z18_DSCALT := "Registro Excluido." 
          (cLogItm)->Z18_DATA   := DATE()
          (cLogItm)->Z18_HORA   := TIME()
          (cLogItm)->Z18_USUAR  := U_UCFG001(1)
          (cLogItm)->Z18_COD    := Z17->Z17_COD
          (cLogItm)->Z18_VERSAO := _cseque
          
          (CLogItm)->(MsUnlock())
       EndIf
   Next nConIten

   //==========================================================================================================
   // Inclui no array aItemDel os registros deletados pelo usuario e inclui os registros novos da alteracao. 
   //==========================================================================================================
   For nConIten := 1 to Len(aCols)

       If aCols[nConIten,nPosDel] == .T.
		  AAdd( aItemDel, M->&(cCmpCod1)+GdFieldGet(cCmpItem,nConIten) )
		  Loop
	   Endif
	
   Next nConIten

   //==========================================================================
   // Gravacao dos campos Alterados no cabecalho.                            
   //==========================================================================
   dbSelectArea(cAliasCab)
   RecLock(cAliasCab,.F.)
   For nConCab := 1 To FCount()
	   If !( "FILIAL" $ FieldName(nConCab) ) .And. !( "COD" $ FieldName(nConCab) )
		  FieldPut(nConCab,M->&(FieldName(nConCab)))
	   EndIf
   Next nConCab  

   //Grava os dados como filial + matricula do usuario que realizou a aprovacao e a data e hora que foi realiada
   If cOpcaoMenu = 'P'

	  ZAZ->ZAZ_MATAPR:=u_UCFG001(1)
	  ZAZ->ZAZ_DTAPRO:=date()
      ZAZ->ZAZ_HRAPRO:=time()     
	  ZAZ->ZAZ_STATUS:='S'
	                                             
	  //Na alteracao do acordo comercial alterar o status do acordo comercial para haver uma nova liberacao do financeiro,
	  //caso ele ja tenho sido liberado anteriormente
   ElseIf cOpcaoMenu = 'A'      

	  ZAZ->ZAZ_STATUS:='N'    

   EndIf

   (cAliasCab)->(MsUnlock())
    
   //==========================================================================
   // Gravacao dos Itens.                                                    
   // Altera os registros contidos anteriormente na 1a Inclusao.             
   //==========================================================================
   //============================================================
   // Efetua a grava��o dos itens.
   //============================================================
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   _nPosCod    := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_COD"})
   _nPosItem   := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ITEM"}) 
   
   Begin Transaction
      ZB0->(DbSetOrder(1)) // ZB0_FILIAL+ZB0_COD+ZB0_ITEM  
      For _nI := 1 To Len(aCols)
          If ZB0->(DbSeek(xFilial("ZB0")+U_ITKEY(aCols[_nI,_nPosCod],"ZB0_COD")+U_ITKEY(aCols[_nI,_nPosItem],"ZB0_ITEM")))
             _lAchouZB0 := .T.      
          Else
             _lAchouZB0 := .F.
          EndIf
       
          //===================================================
          // Exclui os registros deletados.
          //===================================================
          If aCols[_nI,nPosDel]
             // Se existir excluir os registros deletados.
             If _lAchouZB0
                ZB0->(RecLock("ZB0",.F.))
                ZB0->(DbDelete())
                ZB0->(MsUnLock())
             EndIf
          
             //===================================================
             // Realiza a altera��o dos registros.
             //===================================================
          ElseIf _lAchouZB0
                 ZB0->(RecLock("ZB0",.F.))
              
                 For _nJ := 1 To Len(aHeader)
                     If (aHeader[_nJ,10] <> "V") .And. ! AllTrim(aHeader[_nJ,2]) $ "ZB0_ALI_WT/ZB0_REC_WT/ZB0_COD/ZB0_ITEM/BM_GRUPO/B1_I_BIMIX"
                        &("ZB0->"+aHeader[_nJ,2]) := aCols[_nI,_nJ]
                     EndIf
                 Next
              
                 ZB0->(MsUnLock())
             //===================================================
             // Realiza a inclus�o dos registros novos.
             //===================================================
          Else
             _nNrItem := 0
          
             For _nJ := 1 To Len(aCols)      
                 If Val(aCols[_nI,_nPosItem]) > _nNrItem
                    _nNrItem := Val(aCols[_nI,_nPosItem])
                 EndIf
             Next
          
             _nNrItem += 1
     
             ZB0->(RecLock("ZB0",.T.))
             ZB0->ZB0_FILIAL := xFilial("ZB0")
             ZB0->ZB0_COD    := M->ZAZ_COD
             If Empty(aCols[_nI,_nPosItem])
                ZB0->ZB0_ITEM := StrZero(_nNrItem,6)
             Else
                ZB0->ZB0_ITEM := aCols[_nI,_nPosItem]
             EndIf
          
             For _nJ := 1 To Len(aHeader)
                 If (aHeader[_nJ,10] <> "V") .And. ! AllTrim(aHeader[_nJ,2]) $ "ZB0_ALI_WT/ZB0_REC_WT/ZB0_FILIAL/ZB0_COD/ZB0_ITEM/BM_GRUPO/B1_I_BIMIX"
                    &("ZB0->"+aHeader[_nJ,2]) := aCols[_nI,_nJ]
                 EndIf
             Next
             ZB0->(MsUnLock())
          EndIf
      Next   
   End Transaction
End Sequence 

Return

/*
===============================================================================================================================
Programa----------: AOMS023E
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Exclusao dos arquivos de Cabecalho e Item.
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS023E(oproc)

Local nConIten	:= 1  //Conta os itens do aCols
Local lRet		:= .T.
Local cQuery	:= ""
Local cVend		:= "ITEM  VEND.   NOME VENDEDOR"+Chr(10)+Chr(13)
Local nConCab	:= 0
Default oproc := nil

Begin Sequence
   IF Valtype(oproc) = "O"
  	  oproc:cCaption := ("Validando exclus�o...")
	  ProcessMessages()
   ENDIF

   lRet:= AOMS023U( M->&(cCmpCod1),"E" )

   //Caso exista algum pedido de venda relacionado a este contrato nao sera possivel dar sequencia a rotina de exclusao
   If !lRet
      Break 
   EndIf 

   IF valtype(oproc) = "O"
  	  oproc:cCaption := ("Excluindo contrato...")
	  ProcessMessages()
   ENDIF

   If lRet
	  //==========================================================================
	  // Gravacao do log dos campos Alterados no cabecalho.                            
	  //==========================================================================
	  dbSelectArea(cLogCab)
	  RecLock(cLogCab,.T.)
	  For nConCab := 1 To FCount()
	      If !( "VERSAO" $ FieldName(nConCab) ) .And. !( "FILIAL" $ FieldName(nConCab) ) .And. !( "DELET" $ FieldName(nConCab) ) .And. !( "DATA" $ FieldName(nConCab) ) .And. !( "HORA" $ FieldName(nConCab) ) .And. !( "USUAR" $ FieldName(nConCab) ) .And. !( "DSCALT" $ FieldName(nConCab) )
		     FieldPut(nConCab,M->&("ZAZ"+SUBSTR(FieldName(nConCab),4,50)))
	      EndIf
	  Next nConCab  
	
	  //Gera pr�xima vers�o
	  cQuery := "SELECT max(Z17_VERSAO) numrec" 
	  cQuery += " FROM " + RetSqlName("Z17")
	  cQuery += " WHERE D_E_L_E_T_  <> '*' "
	  cQuery += " AND Z17_COD = '" + M->ZAZ_COD + "'"

	  If Select("TMP16") > 0
		 TMP16->(dbCloseArea())
	  EndIf
	
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP16",.T.,.T.)

	  If TMP16->( Eof() )
		 _cseque := '00'
	  Else
         _cseque := soma1(TMP16->numrec)
	  Endif

	  (cLogCab)->Z17_VERSAO := _cseque
	
      (cLogCab)->Z17_DSCALT := "Exclus�o do Contrato."
	  (cLogCab)->Z17_DATA := DATE()
	  (cLogCab)->Z17_HORA := TIME()
	  (cLogCab)->Z17_USUAR := U_UCFG001(1)
	  (cLogCab)->Z17_DELET := 'DELETADO'

	  (cLogCab)->(MsUnlock())

      For nConIten := 1 to Len(aCols)
		  DbSelectArea(cAliasItm)
		  DbSetOrder(1)
		  If DbSeek( xFilial(cAliasItm) + M->&(cCmpCod1)+GdFieldGet(cCmpItem,nConIten) )
			 RecLock(cAliasItm,.F.)
			 DbDelete()
			 MsUnLock()
		  Endif
	  Next nConIten
	
	  DbSelectArea(cAliasCab)
	  RecLock(cAliasCab,.F.)
	  DbDelete()
	  MsUnLock()
   Else
	  u_itmsg("Nao sera permitido a exclusao deste contrato.","Exclusao Contrato",;
	          "Existe Regra de Comissao vinculada a este contrato. Altere a regra de comissao e entao voce podera excluir o contrato."+Chr(10)+Chr(13)+;
	          cVend,1)
   EndIf

End Sequence

Return

/*
===============================================================================================================================
Programa----------: AOMS023L
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Adiciona botoes na Enchoice.   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS023L()
Local _lRet := .T.
Local nTam		:= Len(aHeader)
Local nProc		:= 0
Local cProduto	:= ""           
Local aAux		:= aClone(aCols)	
Local nContador	:= 1

Local nProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_SB1COD"})
Local nCliente	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_CLIENT"})
Local nLoja		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_LOJA"})
Local nEstado	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_EST"})    
Local nDescTot	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_DESCTO"})
Local nDescPar	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_DESCPA"}) 
Local nAbatime	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ABATIM"})
Local _nItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ITEM"})
Local _nGrupo  := aScan(aHeader,{|x| AllTrim(x[2])=="BM_GRUPO"})

Begin Sequence
   //========================================================
   //  Caso o item nao esteja deletado                     
   //========================================================
   If ( !aCols[n][Len(aCols[n])])

      //=========================================================================
      // Atualiza grupo de produtos, com base no c�digo de produto informado.
      //=========================================================================
      cProduto	:= aCols[n,nProduto]
      aCols[n,_nGrupo] := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_GRUPO")

	  //==========================================================================
	  //Verifica se os campos obrigatorios estao em branco, logo bloqueia.      
	  //==========================================================================
	  For nProc := 1 To nTam
		  Do Case
			 Case ( AllTrim(aHeader[nProc][2]) == cCmpPro )
			      cProduto := aCols[n][nProc]
		  EndCase
	  Next nProc
	
	  If Empty(cProduto)
		 u_itmsg("O produto deve ser informado!","Campo Obrigatorio","Informe um produto nos itens!",1)
		 _lRet := .F.
		 Break 
	  EndIf    
	
	  If (aCols[n][nDescPar] >= aCols[n][nDescTot]) .And. (aCols[n][nDescPar] <> 0) 
		 u_itmsg("O desconto parcial deve ser menor que o desconto total.","INFORMA��O","Fornecer um valor menor para o desconto parcial, comparado ao valor de desconto total.",1)
		 _lRet := .F.
		 Break 
	  EndIf    
	
	  //Se a opcao escolhida for aprovacao no menu, verifica o tipo de abatimento para validacao
	  If cOpcaoMenu == 'P'    	
		 If aCols[n][nDescPar] == 0 .And. aCols[n][nAbatime] == 'P'
			u_itmsg("Para o tipo de abatimento parcial deve-se informar o valor do desconto parcial.","INFORMA��O",;
							"Favor fornecer o valor do desconto parcial ou alterar o tipo do abatimento.",1)
			_lRet := .F.
			Break 
		 EndIf
	  EndIf
   EndIf                         

   //Verifica se os dados informados na linha atual se ja nao foram inseridos em outra linha
   If Len(aCols) > 1
	  Do While nContador <= Len(aCols)
         //Verifica se a linha atual nao esta deletada       
	     If aCols[n][Len(aCols[nContador])] == .F.
	
		    If aCols[n][nProduto] == aAux[nContador][nProduto] .And. ; // PRODUTO   
		       aCols[n][nCliente] == aAux[nContador][nCliente] .And. ; // CLIENTE
		       aCols[n][nLoja] == aAux[nContador][nLoja] .And. ; // LOJA
		       aCols[n][nEstado] == aAux[nContador][nEstado] .And. ; // ESTADO
		       aAux[nContador][Len(aAux[nContador])] == .F. .And.;//Verifica se a linha nao esta deletada
		       n <> nContador // PARA NAO COMPARAR A LINHA ATUAL COM ELA MESMA

			   U_ItMsg("Os dados inseridos nesta linha ja foram inseridos anteriormente na linha: " + AllTrim(str(nContador)) + " favor verificar os dados nesta linha.",;
					   "Dados incorretos","Ou verificar os dados contidos na linha atual.",1)
			   _lRet := .F.
			   Break 
		    EndIf    
         EndIf   
		 ++nContador
	  EndDo
   EndIf
   
   //Verifica se os dados informados na linha atual se ja nao foram inseridos em outra linha
   If Len(_aBkpACols) > 1
      nContador := 1
	  Do While nContador <= Len(_aBkpACols)
         //Verifica se a linha atual nao esta deletada       
	     If _aBkpACols[nContador][Len(_aBkpACols[nContador])] == .F.  .And. aCols[n][Len(aCols[n])] == .F. 
	
		    If aCols[n][nProduto] == _aBkpACols[nContador][nProduto] .And. ; // PRODUTO   
		       aCols[n][nCliente] == _aBkpACols[nContador][nCliente] .And. ; // CLIENTE
		       aCols[n][nLoja] == _aBkpACols[nContador][nLoja] .And. ; // LOJA
		       aCols[n][nEstado] == _aBkpACols[nContador][nEstado] .And. ; // ESTADO
		       _aBkpACols[nContador][Len(_aBkpACols[nContador])] == .F. .And.;//Verifica se a linha nao esta deletada
		       aCols[n][_nItem] <> _aBkpACols[nContador][_nItem]    //n <> nContador // PARA NAO COMPARAR A LINHA ATUAL COM ELA MESMA

			   U_ItMsg("Os dados inseridos nesta linha ja foram inseridos anteriormente na linha: " + AllTrim(str(nContador)) + " favor verificar os dados nesta linha.",;
					   "Dados incorretos","Ou verificar os dados contidos na linha atual.",1)
			   _lRet := .F.
			   Break 
		    EndIf    
         EndIf   
		 ++nContador
	  EndDo
   EndIf
      
   //================================================================
   // Atualiza o aCols principal com as atualiza��es realizadas.
   //================================================================
   AOMS023S()
   
End Sequence


Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS023T
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao para validacao da tela.   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS023T()
Local _lRet         := .T.
Local nTam			:= Len(aCols)
Local nPosProd		:= aScan(aHeader,{|x| AllTrim(x[2])==cCmpPro})
Local aAux			:= aCols
Local nContador		:= 1   
Local nDescPar		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_DESCPA"})
Local nAbatim		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ABATIM"})
Local nRegistros	:= 0
Local lAbatiment	:= .F.
Local lDescPar		:= .F. 
Local cAuxLinAb		:= "" 
Local nCont			:= 0

Begin Sequence

   If !Empty(M->ZAZ_CLIENT)
	  If Empty(M->ZAZ_LOJA)
		 u_itmsg("Contrato com o c�digo do cliente preenchido, � necess�rio preencher a loja.","INFORMACAO","Informe uma loja v�lida no cabe�alho contrato.",1)
		 
		 _lRet := .F. 
		 Break
	  EndIf
   EndIf

   //===============================================================================
   // Verifica se o filtro de dados est� ativo, se estiver remove o filtro antes das
   // Valida��es.
   //===============================================================================
   If _lHaFiltro  
      U_ItMsg("Os dados em tela est�o com o filtro ativo. Os filtros de dados ser�o removidos antes das valida��es dos itens!","Aten��o",,1)
      AOMS023M('LIMPARFILTRO')
      nTam:=Len(aCols)
      aAux:=aCols
   EndIf 

   //===============================================================================
   // D� conitunidade nas valida��es em tela.
   //===============================================================================
   For nCont:=1 to Len(aCols) 
       //Verifica se o registro nao esta deletado
	   If !aTail(aCols[nCont])
		  ++nRegistros
	   EndIf
   Next nCont
                                          
   //Indica que nao tem nenhum registro ativo no contrato depois da alteracao
   If cOpcaoMenu == 'A' .And. nRegistros == 0
	  u_itmsg("� necess�rio informar pelo menos um desconto contratual para um produto nos itens do contrato.","INFORMACAO","Informe um produto nos itens!",1)
	  
	  _lRet := .F. 
	  Break 
   EndIf

   //==========================================
   // Verifica se o aCols soh possui um item. 
   //==========================================
   If ( nTam == 1  )
	  //===================================================
	  // Verifica se o unico item do aCols esta deletado. 
	  //===================================================
	  If ( aCols[nTam][Len(aCols[nTam])])
		 u_itmsg("O item esta deletado!","Item Deletado","Informe um produto nos itens!",1)
		 
		 _lRet := .F. 
		 Break
	  EndIf
	
	  //==================================================
	  // Verifica se existe pelo menos um Item no aCols. 
	  //==================================================
	  If Empty(aCols[nTam][nPosProd])
		 u_itmsg("O produto deve ser informado!","Campo Obrigatorio","Informe um produto nos itens!",1)
		
		 _lRet := .F. 
		 Break
	  EndIf
   EndIf   

   //Se a opcao escolhida for aprovacao no menu, verifica o tipo de abatimento para validacao
   If cOpcaoMenu == 'P'
      cAuxLinAb:="" 	     
	  nContador:=1	
	  Do While nContador <= Len(aAux)  
	     If Len(AllTrim(aAux[nContador][nAbatim])) == 0	
		 	  lAbatiment:= .T. 
		 	  cAuxLinAb += AllTrim(Str(nContador)) + ' - '     
        EndIf 
		 	
		 If aAux[nContador][nAbatim] == 'P' .And. aAux[nContador][nDescPar] == 0
          lDescPar:= .T.
			 cAuxLinAb += AllTrim(Str(nContador)) + ' - '
		 EndIf
         
	     ++nContador
	  EndDo     
		 
	  If lAbatiment
		 u_itmsg("Deve-se informar o tipo do abatimento.","INFORMACAO",;
		 		 "Favor informar o tipo do abatimento para todos os itens do desconto contratual. As seguintes linhas encontram-se sem preenchimento: ";
		 		 + SubStr(cAuxLinAb,1,Len(cAuxLinAb)-2),1)
		 _lRet := .F. 
		 Break
	  EndIf   
		 
	  If lDescPar
		 u_itmsg("Para o tipo de abatimento parcial deve-se fornecer o valor do desconto parcial.","INFORMACAO",;
		             "Favor inserir o valor do desconto parcial nas seguintes linhas que se encontram sem preenchimento: " + SubStr(cAuxLinAb,1,Len(cAuxLinAb)-2),1)
		_lRet := .F. 
		 Break
	  EndIf
   EndIf

   //================================================
   // Verifica se as validacoes de linha estao OK.  
   //================================================
   _lRet :=  AOMS023L()

End Sequence
 
Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS023U
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao utilizada para validar a exclusao e bloqueio do contrato, impedindo que se exclua um contrato que tiver um
						 pedido de venda relacionado a ele, mantendo a integridade do sistema.
===============================================================================================================================
Parametros--------: cNumContrato - Numero do contrato
					_cmov - movimento, "B" bloqueio, "E" exclus�o
===============================================================================================================================
Retorno-----------: lRet - l�gico indicando libera��o ou n�o do movimento
===============================================================================================================================
*/

static function AOMS023U(cNumContrato, _cmov)

Local lRet		:= .T.
Local cQuery	:= ""
Local nQtdReg	:= 0
Local _alog := {}

If _cmov == "E"

	cQuery := "SELECT C5_FILIAL, C5_NUM, C5_I_NRZAZ, C5_I_DTENT, C5_EMISSAO" 
	cQuery += " FROM " + RetSqlName("SC5")
	cQuery += " WHERE D_E_L_E_T_  <> '*' "
	cQuery += " AND C5_I_NRZAZ = '" + cNumContrato + "' AND C5_TIPO = 'N' 
	cQuery += " ORDER BY C5_FILIAL,C5_NUM"

Endif

If _cmov == "B"

	cQuery := "SELECT C5_FILIAL, C5_NUM, C5_I_NRZAZ, C5_I_DTENT, C5_EMISSAO" 
	cQuery += " FROM " + RetSqlName("SC5")
	cQuery += " WHERE D_E_L_E_T_  <> '*' "
	cQuery += " AND C5_I_NRZAZ = '" + cNumContrato + "' AND C5_NOTA = ' ' AND C5_I_OPER > ' ' AND C5_TIPO = 'N' 
	cQuery += " ORDER BY C5_FILIAL,C5_NUM"

Endif

If Select("TMP16") > 0
	TMP16->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP16",.T.,.T.)
//Contabiliza o numero de registros encontrados pela query
COUNT TO nQtdReg

TMP16->( Dbgotop() )


If nQtdReg > 0

	Do while .not. TMP16->( Eof() )
	
		aadd(_alog,{TMP16->C5_FILIAL,TMP16->C5_NUM, dtoc(stod(TMP16->C5_I_DTENT)),dtoc(stod(TMP16->C5_EMISSAO))})	
	
		TMP16->( DbSkip() )
	
	Enddo

	If _cmov == "B"
	
		U_ITMSG("Existe(m) pedido(s) de venda relacionado(s) a este contrato. ",'Aten��o',"Por isso nao e possivel realizar o bloqueio sem excluir ou encerrar tal(is) pedido(s) de vendas.",1)
	
	Else
	
		U_ITMSG("Existe(m) pedido(s) de venda relacionado(s) a este contrato. ",'Aten��o',"Por isso nao e possivel realizar a exclus�o sem excluir tal(is) pedido(s) de vendas.",1)
	
	Endif
	
	U_ITListBox( 'Exclus�o ou bloqueio n�o permitido, existe(m) pedido(s) de venda relacionado(s) a este contrato!' ,  {"Filial","Pedido", "Entrega", "Emiss�o"},_aLog,.T.,1)
	
	lRet:= .F.      

EndIf

//===================================
// Deleta os arquivos temporarios. 
//===================================
TMP16->(dbCloseArea()) 


return lRet    

/*
===============================================================================================================================
Programa----------: AOMS023I
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao para validar a inclusao/alteracao dos dados do contrato onde nao sera possivel ser incluida uma mesma
					   rede que ja possua um contrato ativo, um mesmo cliente e loja ou um mesmo cliente, que possua contrato ativo
===============================================================================================================================
Parametros--------: cNumContrato - Numero do contrato
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS023I(cgrupVenda,cCliente,cLojaCli) 

Local lRet			:= .T.
Local cQuery		:= ""
Local cQueryAdic	:= ""
Local cMsgCliente	:= ""  

//=================================================================
// Remove os filtros e atualiza o ACols antes das valida��es.
//=================================================================
AOMS023M( 'LIMPARFILTRO' ) 

//Valida altera��o para contrato bloqueado
If copcaoMenu =="A" .and. M->ZAZ_MSBLQL == '1'

	lRet:= AOMS023U( M->&(cCmpCod1), "B" )
	
Endif

//Se for escolhida uma opcao diferente de aprovacao, alterar ou incluir valida os dados inclusos
If (cOpcaoMenu == "I" .OR. cOpcaoMenu == "A") .and. lret

	If !Empty(cgrupVenda)
	
		cMsgCliente:= "Rede"	
		cQueryAdic += " AND ZAZ_GRPVEN = '" + cgrupVenda + "'
			
	ElseIf (!Empty(cCliente)).And. (!Empty(cLojaCli))   
			
		cMsgCliente:= "Cliente e/ou Loja"	    
		cQueryAdic += " AND ZAZ_CLIENT = '" + cCliente + "'
		cQueryAdic += " AND ZAZ_LOJA = '" + cLojaCli + "'
			
	Elseif !Empty(cCliente)    
					
   		cMsgCliente:="Cliente"
		cQueryAdic += " AND ZAZ_CLIENT = '" + cCliente + "'
		cQueryAdic += " AND ZAZ_LOJA = '  '"
	EndIf           
	
	If cOpcaoMenu == "A"
		cQueryAdic += "AND ZAZ_COD <> '" + M->ZAZ_COD + "'" //Para nao pegar o mesmo codigo que esta ativo no momento da alteracao
	EndIf
	 
	If !Empty(cQueryAdic)  
		 
		cQuery := "SELECT ZAZ_COD" 
		cQuery += " FROM " + RetSqlName("ZAZ")
		cQuery += " WHERE D_E_L_E_T_  <> '*'  AND ZAZ_FILIAL = '" + xFILIAL("ZAZ") + "'"
		cQuery += " AND ZAZ_MSBLQL = '2'"
		cQuery += cQueryAdic
		
		If Select("TMP15") > 0
			TMP15->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP15",.T.,.T.)
		
		dbSelectArea("TMP15")
		TMP15->(dbGoTop()) 
		
		If !Empty(TMP15->ZAZ_COD) 
		
			u_itmsg("J� foi lan�ado anteriormente o contrato: " + TMP15->ZAZ_COD + " para a(o) " + cMsgCliente + " informada(o).","INFORMACAO",;
						" Por este motivo n�o ser� poss�vel efetuar a inclus�o/altera��o deste contrato, favor alterar a(o) " + cMsgCliente + ;
						" , ou alterar o contrato citado anteriormente.",1)
			lRet:= .F.      
		
		EndIf
		
		//===================================
		// Deleta os arquivos temporarios. 
		//===================================
		TMP15->(dbCloseArea())
	
	EndIf      

EndIf
                                                                      
Return lRet               
            
/*
===============================================================================================================================
Programa----------: AOMS023O
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao utilizada para validar os campos obrigatorios do contrato de desconto.  
===============================================================================================================================
Parametros--------: 	Nenhum
===============================================================================================================================
Retorno-----------: .T. pode incluir ou alterar os dados do contrato e .F. nao eh possivel    
===============================================================================================================================
*/ 

Static Function AOMS023O()                         

Local cCampos	:= ""
Local lRet		:= .T.
	
If Empty(M->ZAZ_GRPVEN) .And. Empty(M->ZAZ_CLIENTE)
   	cCampos+="O preenchimento de um dos campos: Rede ou cliente � obrigat�rio, favor preencher um destes campos" + Chr(10)+Chr(13)
EndIf                                                                                                                
	                                           
If Empty(M->ZAZ_DTFIM)
	cCampos+="Data Final" + Chr(10)+Chr(13)
EndIf
	
If Empty(M->ZAZ_DTINI)
	cCampos+="Data Inicial" + Chr(10)+Chr(13)
EndIf                          
	
If !Empty(cCampos)
	u_itmsg("Favor preencher o(s) seguinte(s) campo(s) obrigat�rio(s):" + Chr(10)+Chr(13) + Chr(10)+Chr(13) + cCampos,"INFORMACAO","Preenchimento dos campos citados acima.",1)    
	lRet:=.F.	
EndIf                   
		      
Return lRet                        

/*
===============================================================================================================================
Programa----------: AOMS023P
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao utilizada para permitir que o campo ZB0_DESCPA somente seja editavel quando for realizada a aprovacao 
						do contrato e o tipo de abatimento da linha do contrato seja parcial.
===============================================================================================================================
Parametros--------: 	Nenhum
===============================================================================================================================
Retorno-----------: .T. pode editar o campo	
===============================================================================================================================
*/ 

User Function AOMS023P()
      
Local lRet := .F.

If !INCLUI .And. !ALTERA .And. aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ABATIM"})] == 'P'
	lRet := .T.
EndIf

Return lRet                     

/*
===============================================================================================================================
Programa----------: AOMS023Z
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao utilizada para permitir que no momento da aprovacao de um determindado contrato seja possivel inserir 
						em todas as linhas do contrato o tipo de abatimento escolhido, desta forma agiliza-se o cadastro	
===============================================================================================================================
Parametros--------: 	Nenhum
===============================================================================================================================
Retorno-----------: .T. pode editar o campo	
===============================================================================================================================
*/        
Static Function AOMS023Z()
                 
Local  oDlg
Local  oButton1
Local  oButton2
Local  oCombo    
Local  oSay1
Local  oSay2
Local  nCombo := Space(10) //'INTEGRAL'
      
//Se a opcao escolhida for diferente da aprovacao no menu nao sera possivel executar esta rotina
If cOpcaoMenu <> 'P'  
	u_itmsg("A op��o de Abatimento somente podera ser utilizada pela Aprova��o do contrato.","INFORMACAO","Favor acessar o menu de aprova��o antes de escolher esta o��o.",1)
    Return
EndIf

DEFINE MSDIALOG oDlg TITLE "INSER��O DE ABATIMENTO" FROM 000, 000  TO 200, 450 COLORS 0, 16777215 PIXEL

	@ 009, 008 SAY oSay1 PROMPT "SELECIONE O TIPO DE ABAIMENTO DESEJADO PARA OS ITENS DO CONTRATO" SIZE 209, 009 OF oDlg COLORS 0, 16777215 PIXEL
   @ 041, 064 MSCOMBOBOX oCombo VAR nCombo ITEMS {"INTEGRAL","PARCIAL","NAO POSSUI",Space(10)} SIZE 133, 010 OF oDlg COLORS 0, 16777215 PIXEL
   @ 044, 025 SAY oSay2 PROMPT "Abatimento:" SIZE 034, 007 OF oDlg COLORS 0, 16777215 PIXEL
   @ 077, 065 BUTTON oButton1 PROMPT "Ok" SIZE 040, 012 OF oDlg ACTION (If(U_AOMS023W(nCombo),AOMS023K(nCombo,oDlg),)) PIXEL
   @ 077, 122 BUTTON oButton2 PROMPT "Cancelar" SIZE 040, 012 OF oDlg ACTION oDlg:End() PIXEL
    
ACTIVATE MSDIALOG oDlg CENTERED

Return                

/*
===============================================================================================================================
Programa----------: AOMS023W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 30/12/2021
===============================================================================================================================
Descri��o---------: Validar a sele��o do Tipo de abatimento.
===============================================================================================================================
Parametros--------: nCombo = Op��o selecionada no combobox.
===============================================================================================================================
Retorno-----------: _lRet  = .T. = Validado.
                             .F. = N�o validado.
===============================================================================================================================
*/        
User Function AOMS023W(nCombo)
Local _lRet := .T.

Begin Sequence
   If Empty(nCombo)
      U_ItMsg("Tipo de Abatimento n�o selecionado.","Aten��o","Informe um tipo de abatimento.",1)
      _lRet := .F. 
   EndIf 

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS023K
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Registra dados do tipo de desconto
===============================================================================================================================
Parametros--------: 	Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/        
Static Function AOMS023K(nCombo,oDlg) 

Local nAbatime := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ABATIM"}) 
Local nDescPar := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_DESCPA"})
Local nCont		:= 0
Local cAbatimen:= ""

If nCombo == 'INTEGRAL'          
	cAbatimen:='I'
ElseIf nCombo == 'PARCIAL'
	cAbatimen:='P'
Else 
   cAbatimen:='N'
EndIf		  
             
For nCont:= 1  to Len(aCols)

	aCols[nCont,nAbatime]:= cAbatimen        
	
	If cAbatimen == 'I' .Or. cAbatimen == 'N'
		aCols[nCont,nDescPar]:= 0
	EndIf

Next nCont                                                                   

oDlg:End()

Return

/*
===============================================================================================================================
Programa----------: AOMS023H
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Visualiza hist�rico do contrato
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/        

Static function AOMS023H()

Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

Local _alog := {}
Local _abuttons := { { "Visualiza"	, {|| U_AOMS023R( _alog, oLbxAux:nAt ) }						, "Visualiza dados da vers�o"	, "Visualiza"	} } 
Local _cDadosAlt

_cQuery := " SELECT Z17_DATA,Z17_HORA,Z17_USUAR,Z17_STATUS,Z17_DTAPRO,Z17_HRAPRO,Z17_MATAPR,Z17_VERSAO, "
_cQuery += " Z17_COD, Z17_GRPVEN, Z17_CLIENT, Z17_LOJA, Z17_NOME, Z17_DTINI, Z17_DTFIM, Z17_MSBLQL, Z17_ABATIM, Z17.R_E_C_N_O_ AS NRRECNO FROM "
_cQuery += RETSQLNAME('Z17') +" Z17 WHERE D_E_L_E_T_ <> '*' AND Z17_FILIAL = '" + ZAZ->ZAZ_FILIAL +  "' AND  Z17_COD = '" + ZAZ->ZAZ_COD + "'"
_cQuery += " ORDER BY Z17_DATA, Z17_HORA "

DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery ) , _cAlias , .F. , .T. )

TCSetField( _cAlias, "Z17_DATA", "D", 8 )
TCSetField( _cAlias, "Z17_DTAPRO", "D", 8 )
TCSetField( _cAlias, "Z17_DTINI", "D", 8 )
TCSetField( _cAlias, "Z17_DTFIM", "D", 8 )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )

if  (_cAlias)->( Eof() )

	u_itmsg("N�o h� hist�rico para esse contrato!","Aten��o",,1)
	
Else

aCores := {	{ "ZAZ_DTFIM<DDATABASE .And. ZAZ_MSBLQL == '2' "	, 'BR_PRETO'	},;	//Encerrado( Preto )
			{ "ZAZ_MSBLQL == '2' .And. ZAZ_STATUS == 'N' "		, 'BR_AMARELO'	},; //Ativo( Amarelo )
			{ "ZAZ_STATUS == 'S' .And. ZAZ_MSBLQL =='2' "		, 'ENABLE'		},; //Aprovado pelo financeiro( VERDE )
			{ "ZAZ_MSBLQL == '1'"								, 'DISABLE'		} } //Bloqueado( Vermelho )


	Do while .not. (_cAlias)->( Eof() )
	   Z17->(DbGoTo((_cAlias)->NRRECNO))
	   
	   _cDadosAlt := Z17->Z17_DSCALT
	   
	   // 1) Bloqueado
	   If (_cAlias)->Z17_MSBLQL == '1'
	      _cdtapro := stod("")
		  _cstatus := "BLOQUEADO"
		  _chorapro := " "
		  _caprov := "  "   
		  
	   // 2) Encerrado
	   ElseIf (_cAlias)->Z17_DTFIM<Date() .And. (_cAlias)->Z17_MSBLQL == '2' 
	      _cdtapro := stod("")
		  _cstatus := "ENCERRADO"
		  _chorapro := " "
		  _caprov := "  "   
	         
	   // 3) Alterado
	   ElseIf (_cAlias)->Z17_MSBLQL == '2' .And. (_cAlias)->Z17_STATUS == 'N' 
	      _cdtapro := stod("")
		  _cstatus := "ALTERADO"
		  _chorapro := " "
		  _caprov := "  "   
	         
	   // 4) Aprovado
	   ElseIf (_cAlias)->Z17_STATUS == 'S' .And. (_cAlias)->Z17_MSBLQL =='2'
          _cdtapro := dtoc((_cAlias)->Z17_DTAPRO)
		  _cstatus := "APROVADO"
		  _chorapro := (_cAlias)->Z17_HRAPRO
		  _caprov := posicione("SRA",1,(_cAlias)->Z17_MATAPR,"RA_NOME")  
	   EndIf
	   
		If (_cAlias)->Z17_MSBLQL == '1'
		
			_cbloq := "BLOQUEADO"
			
		Else
		
			_cbloq := "ATIVO"
		
		Endif
		
		_cusuar := posicione("SRA",1,(_cAlias)->Z17_USUAR,"RA_NOME")
		
        aadd(_alog,{(_cAlias)->Z17_VERSAO,dtoc((_cAlias)->Z17_DATA),(_cAlias)->Z17_HORA,_cusuar  ,_cstatus  ,_cDadosAlt            })
	
		(_cAlias)->( Dbskip() )
	
	Enddo

    _ccab :=   {"Vers�o"             ,"Data"                         ,"Hora"             ,"Usu�rio","Status"  ,"Altera��es Ocorridas"}
    
	U_ITListBox( 'Hist�rico de altera��es do contrato' ,  _ccab ,_aLog,.T.         ,1       ,'Hist�rico de altera��es do contrato',.F.        ,         ,         ,     ,        ,      _abuttons)
	
Endif


return

/*
===============================================================================================================================
Programa----------: AOMS023R
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 05/04/2017
===============================================================================================================================
Descri��o---------: Visualiza vers�o do contrato
===============================================================================================================================
Parametros--------: _alog - dados da itlist
				    _ni - linha selecionada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/        

User function AOMS023R( _alog, _ni)

Local _cQuery	:= ''
Local _cAlias2	:= GetNextAlias()
Local _aitens := {}
Local _cDadosAlt
Local _aTitulos
Local _cAbatimento, _cBaseST

_cQuery := " SELECT Z18_VERSAO,Z18_DATA,Z18_HORA,Z18_USUAR,Z18_COD,Z18_SB1COD,Z18_DCRSB1,Z18_DESCTO,Z18_CONTR,Z18_CLIENT,Z18_LOJA,Z18_NOME,Z18_ABATIM, "
_cQuery += " Z18_DESCPA,Z18_EST,Z18_STBAS, Z18.R_E_C_N_O_ AS NRRECNO FROM "
_cQuery += RETSQLNAME('Z18') +" Z18 WHERE D_E_L_E_T_ <> '*' AND Z18_FILIAL = '" + ZAZ->ZAZ_FILIAL +  "' AND  Z18_COD = '" + ZAZ->ZAZ_COD + "' AND Z18_VERSAO = '" + _alog[_ni][1] + "'""
DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery ) , _cAlias2 , .F. , .T. )

TcSetField(_cAlias2,"Z18_DATA","D",8)

DBSelectArea(_cAlias2)
(_cAlias2)->( DBGoTop() )

if  (_cAlias2)->( Eof() )

	u_itmsg("N�o h� itens para essa vers�o!","Aten��o",,1)
	
Else

	Do while .not. (_cAlias2)->( Eof() )
	   
	    Z18->(DbGoTo((_cAlias2)->NRRECNO))
	   
	    _cDadosAlt := Z18->Z18_DSCALT
                                                                                                                                                                                                                                                                                                                  
        _cAbatimento := ""
        _cBaseST     := ""
        
        // Abatimento (Z18_ABATIM)
        If (_cAlias2)->Z18_ABATIM == "I"
           _cAbatimento := "Integral" 
        ElseIf (_cAlias2)->Z18_ABATIM == "P"
           _cAbatimento := "Parcial"
        ElseIf (_cAlias2)->Z18_ABATIM == "N"
           _cAbatimento := "Nao possui"
        Else
           _cAbatimento := (_cAlias2)->Z18_ABATIM
        EndIf       
         
        // Base ST (Z18_STBAS)
        If (_cAlias2)->Z18_STBAS == "S"
           _cBaseST := "Sim"
        ElseIf (_cAlias2)->Z18_STBAS == "N"
           _cBaseST := "Nao"
        Else
           _cBaseST := (_cAlias2)->Z18_STBAS
        EndIf
        
   		Aadd(_aitens,{(_cAlias2)->Z18_VERSAO,(_cAlias2)->Z18_SB1COD,(_cAlias2)->Z18_DCRSB1,(_cAlias2)->Z18_DESCTO,(_cAlias2)->Z18_CLIENT,(_cAlias2)->Z18_LOJA,(_cAlias2)->Z18_NOME, _cAbatimento ,(_cAlias2)->Z18_DESCPA,(_cAlias2)->Z18_EST,_cBaseST, _cDadosAlt })

		(_cAlias2)->( Dbskip() )
		
	Enddo
	
	(_cAlias2)->(Dbgotop())

    _aTitulos := {"Vers�o" , "Produto", "Descri��o" , "Desconto" , "Cliente" ,"Loja", "Nome Cliente" ,"Abatimento" ,"Desc Parcial" ,"Estado" ,"Base ST" ,"Altera��es Ocorridas"}    		
    U_ITListBox( 'Vers�o ' + (_cAlias2)->Z18_VERSAO + ' do contrato '+ (_cAlias2)->Z18_COD  ,;
	  			_aTitulos,;
	  			_aitens,.T.         ,1  )
	
Endif

Return

/*
===============================================================================================================================
Programa----------: AOMS023V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 30/01/2018
===============================================================================================================================
Descri��o---------: Verifica se houve alguma altera��o nos dados da tela de manuten��o de contratos.
===============================================================================================================================
Parametros--------: _cZ17Alterados = Armazena as altera��es eralizadas na capa da rotina de manuten��o de contratos.
                    _cZ18Alterados = Armazena as linhas e os dados alterados nos itens da tela de manuten��o de contratos.
===============================================================================================================================
Retorno-----------: .T. = Houve altera��es.
                    .F. = N�o houve altera��es.
===============================================================================================================================
*/        
User function AOMS023V(_cZ17Alterados,_aZ18Alterados)
Local _lRet := .T.
Local _nI, _nJ
Local _nTotRegs
Local _aOrd := SaveOrd({"SX3"})
Local _cZ18Alterados
Local _nPosItem := Ascan(aHeader,{|x| AllTrim(x[2]) == "ZB0_ITEM" })
Local _cCampoNr1, _cCampoNr2
Local _cNomeCampo
Local _cTipo, _cContext, _cUsado, _cTitulo, _nTamanho, _nDecimal 
Local _aBkpAHeader := aClone(aHeader)

Begin Sequence
   //==========================================================================
   // Verifica se os campos de cabe�alho foram alterados.
   //==========================================================================
   _nTotRegs := ZAZ->(FCount())
   _cZ17Alterados := ""
   
   //                          1                    2               3              4               5                6             7        8              9                 10  
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   For _nI := 1 To _nTotRegs
       _cNomeCampo := ZAZ->(FieldName(_nI)) 
       _nJ         := Ascan(aHeaderZAZ, {|x| AllTrim(x[2]) == AllTrim(_cNomeCampo)})
       
       If _nJ == 0
          Loop
       EndIf
       
       _cTipo      := aHeaderZAZ[_nJ,8]
       _cContext   := aHeaderZAZ[_nJ,10]
       _cUsado     := aHeaderZAZ[_nJ,7]
       _cTitulo    := aHeaderZAZ[_nJ,1]
       _nTamanho   := aHeaderZAZ[_nJ,4]
       _nDecimal   := aHeaderZAZ[_nJ,5]
       
       If ! X3USO(_cUsado) .Or. _cContext == "V" 
          Loop
       EndIf
        
       If &("ZAZ->"+ZAZ->(FieldName(_nI))) <> &("M->"+_cNomeCampo)
          If _cTipo == "C" 
             _cZ17Alterados += " Campo '"+AllTrim(_cTitulo)+"' ("+AllTrim(_cNomeCampo)+") alterado de: '" + &("ZAZ->"+_cNomeCampo) +"' para: '" + &("M->"+_cNomeCampo) + "'; " 
          ElseIf  _cTipo == "D" 
             _cZ17Alterados += " Campo '"+AllTrim(_cTitulo)+"' ("+AllTrim(_cNomeCampo)+") alterado de: '" + DToc(&("ZAZ->"+_cNomeCampo)) +"' para: '" + DToc(&("M->"+_cNomeCampo)) + "'; "    
          ElseIf _cTipo == "N" 
             _cCampoNr1 := Str( &("ZAZ->"+_cNomeCampo) , _nTamanho, _nDecimal)
             _cCampoNr2 := Str( &("M->"+_cNomeCampo)   , _nTamanho, _nDecimal) 
             _cZ17Alterados += " Campo '"+AllTrim(_cTitulo)+"' ("+AllTrim(_cNomeCampo)+") alterado de: '" + AllTrim(_cCampoNr1) +"' para: '" + AllTrim(_cCampoNr2) + "'; " 
          ElseIf _cTipo == "M" 
             _cZ17Alterados += " Campo '"+AllTrim(_cTitulo)+"' ("+AllTrim(_cNomeCampo)+") alterado de: '" + &("ZAZ->"+ _cNomeCampo) + "' para: '" + &("M->"+_cNomeCampo) + "'; " 
          EndIf
       EndIf
       
   Next 

   //                          1                    2               3              4               5                6             7        8              9                 10  
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //==========================================================================================
   // Verifica se houve altera��es nos campos de itens do contrato.
   //==========================================================================================
   _aZ18Alterados := {}
   ZB0->(DbSetOrder(1)) // ZB0_FILIAL+ZB0_COD+ZB0_ITEM                                                                                                                                     
   For _nI := 1 To Len(aCols)
          
       If ZB0->(DbSeek(xFilial("ZB0")+M->ZAZ_COD+aCols[_nI,_nPosItem]))
          _cZ18Alterados := ""
          For _nJ := 1 To Len(aHeader)
              _cNomeCampo := aHeader[_nJ,2]
              _cTipo      := aHeader[_nJ,8]
              _cContext   := aHeader[_nJ,10]
              _cUsado     := aHeader[_nJ,7]
              _cTitulo    := aHeader[_nJ,1]
              _nTamanho   := aHeader[_nJ,4]
              _nDecimal   := aHeader[_nJ,5]

              If ! AllTrim(_cNomeCampo) $ "ZB0_ALI_WT/ZB0_REC_WT/BM_GRUPO/B1_I_BIMIX" .And. &("ZB0->"+aHeader[_nJ,2]) <>  aCols[_nI,_nJ]  
                 If _cTipo == "C"
                    _cZ18Alterados += " Campo '"+AllTrim(aHeader[_nJ,1])+"' ("+AllTrim(aHeader[_nJ,2])+") alterado de: '" + &("ZB0->"+ZB0->(aHeader[_nJ,2])) +"' para: '" + aCols[_nI,_nJ] + "'; " 
                 ElseIf  _cTipo == "D"
                    _cZ18Alterados += " Campo '"+AllTrim(aHeader[_nJ,1])+"' ("+AllTrim(aHeader[_nJ,2])+") alterado de: '" + DToc(&("ZB0->"+ZB0->(aHeader[_nJ,2]))) +"' para: '" + DToc(aCols[_nI,_nJ] ) + "'; "    
                 ElseIf _cTipo == "N"
                    _cCampoNr1 := Str( &("ZB0->"+ZB0->(aHeader[_nJ,2])), _nTamanho, _nDecimal)
                    _cCampoNr2 := Str(aCols[_nI,_nJ], _nTamanho, _nDecimal)
                    _cZ18Alterados += " Campo '"+AllTrim(aHeader[_nJ,1])+"' ("+AllTrim(aHeader[_nJ,2])+") alterado de: '" + AllTrim(_cCampoNr1) +"' para: '" + AllTrim(_cCampoNr2) + "'; " 
                 ElseIf _cTipo == "M"
                    _cZ18Alterados += " Campo '"+AllTrim(aHeader[_nJ,1])+"' ("+AllTrim(aHeader[_nJ,2])+") alterado de: '" + &("ZB0->"+ZAZ->(aHeader[_nJ,2])) +"' para: '" + aCols[_nI,_nJ]  + "'; " 
                 EndIf
              EndIf
          Next
          
          If ! Empty(_cZ18Alterados)
             Aadd(_aZ18Alterados,{_nI,_cZ18Alterados})
          EndIf
       Else
          Aadd(_aZ18Alterados,{_nI,"Inclus�o de Item."})
       EndIf         
   Next

   If Empty(_cZ17Alterados) .And. Empty(_aZ18Alterados)
      _lRet := .F.
   EndIf

End Sequence

aHeader := aClone(_aBkpAHeader)

RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS023M
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2018
===============================================================================================================================
Descri��o---------: Tela de filtragem dos dados de comiss�o dos representantes.
===============================================================================================================================
Parametros--------: _cAcao = A��o de filtro a ser tomada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS023M(_cAcao)
Local _nProduto  := 0
Local _nCliente  := 0
Local _nLoja	  := 0
Local _nEstado	  := 0
Local _nContrato := 0
Local _nGrupo    := 0 
Local _nI
Local _aNewACols

_nProduto  := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_SB1COD"})
_nCliente  := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_CLIENT"})
_nLoja	  := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_LOJA"})
_nEstado	  := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_EST"})
_nContrato := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_CONTR"})
_nGrupo    := aScan(aHeader,{|x| AllTrim(x[2])=="BM_GRUPO"})
_nPosDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_DESCTO"})
_nGrpMix   := aScan(aHeader,{|x| AllTrim(x[2])=="B1_I_BIMIX"}) 

Begin Sequence

   If _cAcao == "FILTRAR"
      //_aBkpACols := AClone(aCols)
      
      _cCondFiltro := ""

      If _cFiltroExato == "S"
         If ! Empty(_cFiltroUF) .And.  Empty(_cFiltroPrd) .And. Empty(_cFiltroContrato) .And. Empty(_cFiltroCliente) .And. Empty(_cFiltroLoja) .And. Empty(_cGrupoPrd)    
            _cCondFiltro := " aCols[_nI,_nEstado] == '"+ _cFiltroUF + "' "
         Else
            If !Empty(_cFiltroUF)
               _cCondFiltro += " aCols[_nI,_nEstado] == '"+ _cFiltroUF + "' "
            EndIf
      
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nProduto] == '"+_cFiltroPrd+"' "
         
            _cCondFiltro += " .And. aCols[_nI,_nContrato] == '"+_cFiltroContrato+"' "
      
            _cCondFiltro += " .And. aCols[_nI,_nCliente] == '"+_cFiltroCliente+"' .And. aCols[_nI,_nLoja] == '"+_cFiltroLoja+"' "

            _cCondFiltro += " .And. aCols[_nI,_nGrupo] == '"+_cGrupoPrd+"' "

            _cCondFiltro += " .And. aCols[_nI,_nPosDesc] == "+AllTrim(Str(_nFiltPerc,6,2))+" "

            _cCondFiltro += " .And. aCols[_nI,_nGrpMix] == '" + _cGrpMix +"' "  

         EndIf      
      Else
         If Empty(_cFiltroUF) .And.  Empty(_cFiltroPrd) .And. Empty(_cFiltroContrato) .And. Empty(_cFiltroCliente) .And. Empty(_cFiltroLoja) .And. Empty(_cGrupoPrd) .And. _nFiltPerc == 0 .And. Empty(_cGrpMix)
            _cCondFiltro := " aCols[_nI,_nProduto] == '"+Space(15)+"' "
         EndIf

         If !Empty(_cFiltroUF)
            _cCondFiltro += " aCols[_nI,_nEstado] == '"+ _cFiltroUF + "' "
         EndIf
      
         If ! Empty(_cFiltroPrd)
             _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nProduto] == '"+_cFiltroPrd+"' "
         EndIf
      
         If ! Empty(_cFiltroContrato)
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nContrato] == '"+_cFiltroContrato+"' "
         EndIf
      
         If ! Empty(_cFiltroCliente) .And. Empty(_cFiltroLoja)
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nCliente] == '"+_cFiltroCliente+"' "
         EndIf

         If ! Empty(_cFiltroCliente) .And. ! Empty(_cFiltroLoja)
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nCliente] == '"+_cFiltroCliente+"' .And. aCols[_nI,_nLoja] == '"+_cFiltroLoja+"' "
         EndIf

         If ! Empty(_cGrupoPrd)    
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nGrupo] == '"+_cGrupoPrd+"' " 
         EndIf 

         If _nFiltPerc > 0 
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nPosDesc] == " + AllTrim(Str(_nFiltPerc,6,2)) + " " // " .And. aCols[_nI,_nPosDesc] == "+AllTrim(Str(_nFiltPerc,6,2))+" "
         EndIf 

         If ! Empty(_cGrpMix)
             _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " aCols[_nI,_nGrpMix] == '" + _cGrpMix + "' " 
         EndIf 

      EndIf
      
      _cCondFiltro := "{ | | " + _cCondFiltro + "} "
      
      _bCondFiltro := &_cCondFiltro
      
      _aNewACols := {}
      
      For _nI := 1 To Len(aCols)
          If Eval(_bCondFiltro)
             Aadd(_aNewACols, aCols[_nI])
          EndIf
      Next
      
      aCols := AClone(_aNewACols)
      _nLinFiltro := Len(aCols)
      
      If Len(aCols) == 0
         U_ITMSG("N�o foram encontrados dados que satisfa�am as condi��es de filtros que foram informados.","Aten��o", ,1) 
         aCols := AClone(_aBkpACols)
         _aBkpFiltro := AClone(_aBkpACols) 
         N := 1 // Posiciona N de ACols na primeira linha para n�o ocorrer "Array out of bounds", na filtragem e N for maior que o Acols. 
      Else
         //_aBkpFiltro := AClone(aCols)  
         N := 1 // Posiciona N de ACols na primeira linha para exibi��o dos dados.
      EndIf
      
      _lHaFiltro := .T. 

   Else//If _cAcao == "LIMPARFILTRO"
      //================================================================
      // Atualiza o aCols principal com as atualiza��es realizadas.
      //================================================================
      If ! Empty(_aBkpACols)
         If AOMS023S() // Faz o tratamento de inclus�es, altera��es e exclus�es com o filtro acionado.
            aCols := AClone(_aBkpACols)
            //_aBkpACols := {}  
            _nLinFiltro := 0
            _aBkpFiltro := AClone(aCols) 
         Else 
            If _lHaFiltro  
               aCols := AClone(_aBkpACols) 
            EndIf 
         EndIf
      EndIf
      
      _lHaFiltro := .F. 

   EndIf
   
   oGetDados:Refresh()
   
End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS023S
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/10/2018
===============================================================================================================================
Descri��o---------: Atualiar array acols com inclus�es, altera��es e exclus�es, quando a op��o de filtragem for utilizada.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet = .T. = Atualizou _aBkpACols
                            .F. = N�o atualizou _aBkpACols
===============================================================================================================================
*/
Static Function AOMS023S()
Local _nItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ITEM"})
Local _nCodContr := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_COD"})  
Local _nI  := 0, _cNrItem
Local _nJ, _nK
Local _lRet := .F.

Begin Sequence
   //=================================================================================== 
   // Trata inclus�o, Altera��o e Exclus�o de linhas do ACols com o filtro acionado.
   //===================================================================================
   If _nLinFiltro > 0
      //=======================================================
      // Trata linhas deletadas na tela de filtro.      
      //=======================================================
      For _nJ := 1 To Len(aCols) 
          If aCols[_nJ,nPosDel]    // aCols[N,nPosDel]  
             _cNrItem := aCols[_nJ,_nItem] // ZB0_ITEM
             For _nI := 1 To Len(_aBkpACols)
                 If _aBkpACols[_nI,_nItem] == _cNrItem
                    _aBkpACols[_nI,nPosDel] := .T.
                 EndIf             
             Next
          EndIf
      Next

      //=======================================================
      // Trata a inclus�o de linhas na tela de filtro.
      //=======================================================
      //If Len(aCols) > _nLinFiltro // Verifica Inclus�o de Linhas no ACols  
         For _nI := 1 To Len(aCols)  
             If ! aCols[_nI,nPosDel]  
                _nJ := AsCan(_aBkpACols, {|x| AllTrim(x[2]) == AllTrim(aCols[_nI,_nItem])})

                If aCols[_nI,_nCodContr] == "NOVO" .Or. _nJ == 0  // _nJ = 0 indica novo item.
                   aCols[_nI,_nCodContr] := M->ZAZ_COD
                
                   Aadd(_aBkpACols, aCols[_nI])
                EndIf
             EndIf 
         Next
      //EndIf
      
      //=======================================================
      // Trata linhas alteradas na tela de filtro.      
      //=======================================================
      For _nJ := 1 To Len(aCols)
          If ! aCols[_nJ,nPosDel] 
             _cNrItem := aCols[_nJ,_nItem] // ZB0_ITEM
             For _nI := 1 To Len(_aBkpACols)
                 If _aBkpACols[_nI,_nItem] == _cNrItem                    
                    For _nK := 1 To Len(aHeader) + 1
                        If _aBkpACols[_nI, _nK] <> aCols[_nJ,_nK]
                           _aBkpACols[_nI, _nK] := aCols[_nJ,_nK]
                        EndIf             
                    Next
                 EndIf             
             Next
          EndIf
      Next
      
      _lRet := .T.
      
   EndIf   

End Sequence

Return _lRet 

/*
===============================================================================================================================
Programa----------: AOMS023B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/12/2018
===============================================================================================================================
Descri��o---------: Retornar o pr�ximo c�digo de contrato dispon�vel.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS023B()
Local _cRetNum := "000001"
Local _cQry := ""
Local _nMaxCod 

Begin Sequence
   //ZAZ_FILIAL+ZAZ_COD
   
   _cQry := "SELECT MAX(ZAZ_COD) NRCOD"
   _cQry += " FROM " + RetSqlName("ZAZ") + " ZAZ" 
   _cQry += " WHERE D_E_L_E_T_ <> '*' "
   
   If Select("TRBZAZ") <> 0
	  TRBZAZ->(DbCloseArea())
   EndIf
   
   TCQUERY _cQry NEW ALIAS "TRBZAZ"	
   
   _nMaxCod := Val(TRBZAZ->NRCOD)
   
   _nMaxCod += 1
   
   _cRetNum := StrZero(_nMaxCod,6)
   
End Sequence

If Select("TRBZAZ") <> 0
   TRBZAZ->(DbCloseArea())
EndIf

Return _cRetNum

/*
===============================================================================================================================
Programa----------: AOMS023C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/12/2018
===============================================================================================================================
Descri��o---------: Retornar Retorna o numero do proximo item quando for inclus�o e o filtro estiver acionado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS023C()
Local _nItem	  := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ITEM"})
Local _nCodContr := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_COD"})  // ZB0_COD 
Local _nGrupo    := aScan(aHeader,{|x| AllTrim(x[2])=="BM_GRUPO"})
Local _nProduto   := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_SB1COD"})
Local _nI  := 0
Local _lRet := .T.
Local _cNrItem := ""
Local _cProduto := ""

Begin Sequence
   If _nLinFiltro > 0

      If N > _nLinFiltro .And. Empty(aCols[N,_nCodContr]) // Verifica Inclus�o de Linhas no ACols
  
         _cNrItem := _aBkpACols[1,_nItem]
         For _nI := 2 To Len(_aBkpACols)
             If _aBkpACols[_nI,_nItem] > _cNrItem
                _cNrItem := _aBkpACols[_nI,_nItem]
             EndIf
         Next
         
         For _nI := 1 To Len(aCols)
             If aCols[_nI,_nItem] > _cNrItem
                _cNrItem := aCols[_nI,_nItem]
             EndIf
         Next


         _cNrItem := Soma1(_cNrItem)
         
         aCols[N,_nItem]     := _cNrItem
         aCols[N,_nCodContr] := "NOVO" // M->ZAZ_COD
         //Aadd(_aBkpACols, aCols[N])
      EndIf
      
   EndIf

   //=========================================================================
   // Atualiza grupo de produtos, com base no c�digo de produto informado.
   //=========================================================================
   If N > 0 .And. (!Empty(aCols[N,_nProduto]) .Or. (Type("M->ZB0_SB1COD") <> "U" .And. !Empty(M->ZB0_SB1COD)))
      If ! Empty(aCols[N,_nProduto])
         _cProduto := aCols[N,_nProduto]
      Else
         _cProduto := M->ZB0_SB1COD
      EndIf 

      aCols[n,_nGrupo] := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_GRUPO")
   EndIf

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS023D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/12/2018
===============================================================================================================================
Descri��o---------: Organiza a numera��o dos itens inseridos no aCols atrav�s da tecla F3.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS023D()
Local _nItem	 := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_ITEM"})
Local _nCodContr := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_COD"})  // ZB0_COD   
Local _nNrItem  := 0, _nI
Local _nQtdItemF, _nItensAcols

Begin Sequence
   If _nLinFiltro > 0
      _nNrItem := Val(_aBkpACols[1,_nItem])
      For _nI := 2 To Len(_aBkpACols)
          If Val(_aBkpACols[_nI,_nItem]) > _nNrItem
             _nNrItem := Val(_aBkpACols[_nI,_nItem])
          EndIf
      Next
         
      _nNrItem += 1
      _nQtdItemF   := Len(_aBkpFiltro)
      _nItensAcols := Len(aCols)
      
      If _nItensAcols > _nQtdItemF
         For _nI := 1 To _nItensAcols
             If _nI > _nQtdItemF
                aCols[_nI, _nCodContr] := "NOVO"
                aCols[_nI, _nItem] :=  StrZero(_nNrItem,6)
                _nNrItem += 1
             EndIf 
         Next
      EndIf
      
      
   EndIf
End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS023X
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/02/2019
===============================================================================================================================
Descri��o---------: Validar a digita��o de dados no grid formado pelo ACols e outras valida��es.
===============================================================================================================================
Parametros--------: _cCampo = campo do aCols que chamou a valida��o.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Digita��o Ok.
                            .F. = Inconsist�ncia nos dados.
===============================================================================================================================
*/        
User function AOMS023X(_cCampo) 
Local _lRet := .T.
Local _aOrd := SaveOrd({"SA1"})
Local _nCliente	 
Local _nLoja	 
Local _cCodCli, _cLojaCli, _lAchouCli

Begin Sequence
   If _cCampo == "ZB0_CLIENT"
      _nCliente	 := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_CLIENT"})
      _nLoja	 := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_LOJA"})
      
      _cCodCli  := M->ZB0_CLIENT 
      _cLojaCli := aCols[N,_nLoja]
      
      If Empty(_cCodCli)
         Break
      EndIf
      
      SA1->(DbSetOrder(1))
      If ! Empty(_cLojaCli)
         If ! SA1->(DbSeek(xFilial("SA1")+_cCodCli+_cLojaCli))
            U_ITMSG("Cliente ["+_cCodCli+"], Loja ["+_cLojaCli+"], n�o localizado no cadastro de clientes.","Aten��o", ,1) 
            _lRet := .F.
            Break
         EndIf
      EndIf
      
      If ! SA1->(DbSeek(xFilial("SA1")+_cCodCli))
         U_ITMSG("Cliente ["+_cCodCli+"], n�o localizado no cadastro de clientes.","Aten��o", ,1) 
         _lRet := .F.
         Break
      EndIf
      
      _lAchouCli := .F.
      Do While ! SA1->(Eof()) .And. SA1->(A1_FILIAL+A1_COD) == xFilial("SA1")+_cCodCli
         If SA1->A1_MSBLQL == "2"
            _lAchouCli := .T.
            Exit
         EndIf
         SA1->(DbSkip())
      EndDo
      
      If ! _lAchouCli
         U_ITMSG("Cliente ["+_cCodCli+"], bloqueado no cadastro de clientes.","Aten��o", ,1) 
         _lRet := .F.
         Break
      EndIf

   ElseIf _cCampo ==  "COPIA_CONTRATO"  
      If ! U_AOMS023I(M->ZAZ_GRPVEN,M->ZAZ_CLIENT,M->ZAZ_LOJA)    
         _lRet := .F.
         Break
      EndIf
   
   ElseIf _cCampo == "PERCENTUAL_DESC_CONTRATUAL_LOTES"
       
       If ! U_ITMSG("Confirma o Preenchimento dos descontos para todos os itens na tela?","Aten��o" , , ,2, 2)
          _lRet := .F.
          Break
       EndIf 
      
      If ! _lHaFiltro .And. ! U_ITMSG("N�o existe nenhum filtro aplicado sobre os descontos contatuais da tela. Confirma a aplica��o dos descontos em lotes?","Aten��o" , , ,2, 2)
          _lRet := .F.
          Break 
      EndIf  
      
      If _nPerDesc == 0 .And. ! U_ITMSG("O percentual de desconto informado est� zerado. Confirma a aplica��o do desconto zerado para todos os itens filtrados na tela?","Aten��o" , , ,2, 2) 
         _lRet := .F.
          Break     
      EndIf 

   EndIf

End Sequence

RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS023F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 24/05/2019
===============================================================================================================================
Descri��o---------: Copia os descontos contratuais, do contrato posicionado, para um novo cliente ou Rede.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/        
User function AOMS023F() 
Local cTitulo		:= "C�pia de Descontos Contratuais"
Local nUsado		:= 0
Local nProc			:= 0
Local aInfo			:= {}
Local aPosObj		:= {}
Local aTela			:= {}
Local aGets			:= {}
Local oDlg1			:= Nil
Local _nI
Local _nCliente	   
Local lBotaoOk    := .F.
Local _bOk, _bCancel
Local lEdita      := .F.
Local _cCodContrato, _cZAZCodFil 

Private aHeader	:= {}											            // Campos dos Itens
Private aCols		:= {}											            // Conteudo dos campos dos Itens
Private aAux		:= {}											            // aCols auxiliar para gravacao dos dados
Private cAliasCab	:= "ZAZ"										            // Nome da Tabela do Cabecalho
Private cChaveCab	:= (cAliasCab)->(ZAZ_FILIAL+ZAZ_COD)			   // Chave de indice do cabecalho
Private cAliasItm	:= "ZB0"										            // Nome da Tabela de Itens
Private cCondicao	:= "(cAliasItm)->(ZB0_FILIAL+ZB0_COD)"			   // Condicao de comparacao ou relacionamento entre o cabecalho e item(Filial + Codigo)
Private cIndItem	:= "(cAliasItm)->(ZB0_FILIAL+ZB0_COD+ZB0_ITEM)"	// Indice do Item
Private cCmpItem	:= "ZB0_ITEM"									         // Nome do Campo de item
Private cUsuario	:= ""
Private _cZ17Alterados, _aZ18Alterados   
Private _lGravaDados := .F.
Private aHeaderZAZ	:= {}											         //Campos dos Itens
Private COPCAOMENU   := "I" // Inclus�o de um novo Contrato
Private NPOSDEL     

Begin Sequence
   //============================================================================
   //Montagem do aheader                                                        
   //=============================================================================
   FillGetDados(1,"ZAZ",1,,,{||.T.},,,,,,.T.)
   aHeaderZAZ	:= AClone(aHeader)

   aHeader := {}
   FillGetDados(1,"ZB0",1,,,{||.T.},,,,,,.T.)
   nUsado := Len(aHeader)
   
   _nCliente := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_CLIENT"})
   
   aHeader[_nCliente,6] := 'U_AOMS023X("ZB0_CLIENT")'  // Grava para o campo ZB0_CLIENT fun��o customizada de valida��o.
   NPOSDEL := Len(aHeader)+1

   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   aGets := {}
   aTela := {}

   cUsuario := U_UCFG001(1)

   DBSelectArea("ZZL")
   DBSetOrder(1)
   If DBSeek(xFilial("ZZL") + cUsuario )

	  If ZZL->ZZL_APRCON <> 'S'
	     U_ItMsg("Voce nao tem acesso ao sistema, favor contactatar o depto financeiro.","INFORMACAO",;
		         "O usuario pode estar sem matricula no cadastro de usuarios ou nao ter acesso ao sistema. Caso o problema persista favor contactar o administrador do sistema.",1)
	     Break 
	  EndIf

	  If ZZL->ZZL_CONTRA <> 'S'
	     U_ItMsg("Voce nao tem acesso ao sistema, favor contactatar o depto comercial.","INFORMACAO",;
			     "O usuario pode estar sem matricula no cadastro de usuarios ou nao ter acesso ao sistema. Caso o problema persista favor contactar o administrador do sistema.",1)
	     Break 
      EndIf
   Else
      U_ItMsg("Voce nao tem acesso ao sistema, favor contactatar o depto financeiro.",;
			  "O usuario pode estar sem matricula no cadastro de usuarios ou nao ter acesso ao sistema. Caso o problema persista favor contactar o administrador do sistema.",1)
      Break 
   EndIf

   //====================================================================================================
   // Carrega os campos do cabecalho como variaveis de Memoria( M->XX_XXX )
   //====================================================================================================
   RegToMemory( cAliasCab , .T. )
   For _nI := 1 To (cAliasCab)->(FCount())
       &("M->" + (cAliasCab)->(FieldName(_nI))) := &(cAliasCab + "->" + (cAliasCab)->(FieldName(_nI)))  
   Next
   
   _cZAZCodFil := ZAZ->ZAZ_FILIAL

   _cCodContrato := U_AOMS023B()
   M->ZAZ_COD    := _cCodContrato

   //====================================================================================================
	// Limpa o aCols e o aCols Auxiliar para prenchelos com os itens ja existentes na tabela
	//====================================================================================================
	aCols := {}
	aAux  := {}

	//====================================================================================================
	// Posiciona no primeiro registro da Tabela para montar o aCols com os itens
	//====================================================================================================
	dbSelectArea(cAliasItm)
	dbSetOrder(1)
	MsSeek(cChaveCab)
	Do While (cAliasItm)->(!Eof()) .And. &(cCondicao) == cChaveCab
		AAdd(aCols,Array(nUsado+1))
		For nProc := 1 to nUsado
		    If ! AllTrim(aHeader[nProc,2]) $ "ZB0_ALI_WT/ZB0_REC_WT/BM_GRUPO/B1_I_BIMIX"
			    aCols[Len(aCols),nProc]:= FieldGet(FieldPos(aHeader[nProc,2]))
			    If AllTrim(aHeader[nProc,2]) == cCmpItem
				    AAdd(aAux,{&cIndItem})
				 Endif
             If AllTrim(aHeader[nProc,2]) == "ZB0_COD"
                aCols[Len(aCols),nProc] := M->ZAZ_COD 
             EndIf      
			 EndIf
		Next nProc
		aCols[Len(aCols),nUsado+1]:= .F.
			
		(cAliasItm)->(dbSkip())
	EndDo
	
	//====================================================================================================
	// Se existe itens para mostrar, chama a tela com os dados a serem apresentados
	//====================================================================================================
	If Len(aCols) > 0
      _bOk     := {|| If(!U_AOMS023X("COPIA_CONTRATO"), lBotaoOk:=.F.,(lBotaoOk := .T., oDlg1:End()))}
      _bCancel := {|| (lBotaoOk:=.F.,oDlg1:End())}

	   //====================================================================================================
		// Define o tamanho da tela e faz tratamento para dimensionamento qdo usado resolucoes diferentes
		//====================================================================================================
		aSize := MsAdvSize()
	  	aObjects := {}
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 015, .T., .F. } )
		
		aInfo         := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
		aPosObj       := MsObjSize(aInfo,aObjects)
		
		//====================================================================================================
		// Ajuste Manual no tamanho da Tela
		//====================================================================================================
		aPosObj[1][3] -= 55.5 //Aumenta para cima  a Enchoice
		aPosObj[2][1] -= 55.0 //Aumenta para cima  a MsGetDados
		aPosObj[2][3] += 15.0 //Aumenta para baixo a MsGetDados
		
		_aPosGetD := AClone(aPosObj)

      INCLUI := .T.
      M->ZAZ_CLIENT := ""
      M->ZAZ_GRPVEN := ""
      M->ZAZ_DTAPRO := Ctod("")
      M->ZAZ_HRAPRO := ""
		
		//_aPosGetD[2,1] += 30  // Posiciona o objeto MSGETDADOS um pouco mais abaixo na tela.
		//aPosObj[1,3] -= 15  // Diminui o espa�o ocupado pelo objeto Enchoice na tela, em algumas linha.
		
		//====================================================================================================
		// Tela estilo Modelo 3 - Cabecalho e Itens
		//====================================================================================================
		DEFINE MSDIALOG oDlg1 TITLE cTitulo FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		    
		   EnChoice(cAliasCab,(cAliasCab)->(Recno()), 3 ,  ,   ,  ,  ,aPosObj[1],,3)
            
         //    oGetDados := MsGetDados():New(05            , 05           , 145          , 195          , 4    , "U_LINHAOK"   , "U_TUDOOK"     , "+A1_COD"    , .T. , {"A1_NOME"},   , .F., 200   , "U_FIELDOK", "U_SUPERDEL", , "U_DELOK", oDlg)
	      oGetDados := MsGetDados():New(_aPosGetD[2,1],_aPosGetD[2,2],_aPosGetD[2,3],_aPosGetD[2,4],  2 ,"Eval(bVldLin)","Eval(bVldTela)",("+"+cCmpItem),lEdita, ,1  ,  ,99999 , "U_AOMS023C" )
		    
	      // Foi declarado o numero maximo de linhas igual a 99999 pois o mesmo n�o havia sido declarado e o sistema reconhece como padr�o 99 o que estava impedindo
	      // o usuario de incluir mais produtos no com mais de 100 itens. 
	  		
         M->ZAZ_CLIENT := (cAliasCab)->ZAZ_CLIENT
         M->ZAZ_GRPVEN := (cAliasCab)->ZAZ_GRPVEN

                                   // (EnchoiceBar(oDlg  ,{||lOk:=.T.,oDlg:End()}                        ,{||oDlg:End()},  ,@aButtons))
	   ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1 , _bOk, _bCancel ))

	  //====================================================================================================
	  // Se o usuario confirmar no botao de Ok da tela
	  //====================================================================================================
	  If lBotaoOk
        Begin Transaction
	        //===================================================================================
		     // Grava capa dos descontos contratuais.
		     //===================================================================================
           ZAZ->(RecLock("ZAZ", .T.))
           ZAZ->ZAZ_FILIAL := _cZAZCodFil
              For _nI := 1 To Len(aHeaderZAZ)
                  If ZAZ->(FieldPos(aHeaderZAZ[_nI,2])) > 0
                     &("ZAZ->"+aHeaderZAZ[_nI,2]) := &("M->"+aHeaderZAZ[_nI,2])
                  EndIf
              Next
           ZAZ->ZAZ_MSBLQL := '2' 
           ZAZ->ZAZ_STATUS := 'N'   
           ZAZ->(MsUnLock()) 

	        //===================================================================================
		     // Grava os itens dos descontos contratuais.
		     //===================================================================================
		     For _nI := 1 To Len(aCols)
               If ! aCols[_nI,nPosDel]	// N�o Gravar item excluido.		      
                  ZB0->(RecLock("ZB0",.T.))
                  ZB0->ZB0_FILIAL := _cZAZCodFil
                  For nProc := 1 to Len(aHeader)
                      If ZB0->(FieldPos(aHeader[nProc,2])) > 0
                         &("ZB0->"+aHeader[nProc,2]) := aCols[_nI,nProc] 
		                EndIf
                  Next
                  ZB0->(MsUnLock())
               EndIf
           Next
        End Transaction
	  EndIf
  EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS023G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/04/2022
===============================================================================================================================
Descri��o---------: Preenche o percentual de descontos para todos os itens filtrados do grid.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/        
User function AOMS023G()
Local _aBotoes := Nil 
Local _nPosDesc 
Local _lBotaoOk := .F. 
Local _nI 

Private _nPerDesc := 0

Begin Sequence 
   
	DEFINE MSDIALOG _oDlgDesc TITLE "Preenchimento de Desconto Contratual em Lotes" FROM 0,0 TO 150, 600 OF oMainWnd Pixel 
		    
	   @ 40, 015 Say "% Desconto Contratual:"	Pixel Size 80,012  Of _oDlgDesc
      @ 40, 100 MSGet _nPerDesc Picture "@E 9,999.9999" Pixel Size 050,012 Of _oDlgDesc
	
   ACTIVATE MSDIALOG _oDlgDesc ON INIT EnchoiceBar(_oDlgDesc, {||If(U_AOMS023X("PERCENTUAL_DESC_CONTRATUAL_LOTES") , (_lBotaoOk := .T.,_oDlgDesc:End()), _lBotaoOk := .F.)}, {||_oDlgDesc:End()},,_aBotoes)
   
   If _lBotaoOk
      _nPosDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="ZB0_DESCTO"})
      
      For _nI := 1 To Len(aCols)

          aCols[_nI, _nPosDesc] := _nPerDesc

      Next 

   EndIf 

   

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS023J
Autor-------------: Julio de Paula Paz
Data da Criacao---: 21/09/2023
===============================================================================================================================
Descri��o---------: Permite exporta para o Excel os dados dos descontos contratuais.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/        
User function AOMS023J()
Local cCodContr   := ZAZ->ZAZ_COD
Local _nTotRegs   := 0          
Local _cQry 
Local _aDados := {}
Local _cGrpMix
Local _aItemMix  := {} //{"G1=Grupo 1","G2=Grupo 2","G3=Grupo 3","G9=Outros","G0=Indefinido","  "}
Local _nI, _cDescMix, _cGrupo, _aCabec  
Local _cAbatimen 

Begin Sequence 
   If !U_ITMSG("Confirma a exporta��o dos dados de desconto contratual pra Excel ?"," ",,3,2,3,,"CONFIRMA","CANCELA")
      Break 
   EndIf 

   _cQry := "SELECT"
   _cQry += " * "                                                  
   _cQry += "FROM "                              
   _cQry += RetSqlName("ZB0") + " ZB0 "         
   _cQry += "WHERE"               
   _cQry += " ZB0.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZB0_FILIAL = '" + xfilial("ZB0") + "'"          
   _cQry += " AND ZB0_COD = '" + cCodContr + "' "    
   _cQry += "ORDER BY ZB0_ITEM"

   If Select("TRBZB0") > 0 
 	   TRBZB0->(dbCloseArea())
   EndIf
    
   DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQry),'TRBZB0',.F.,.T.)   
   COUNT TO _nTotRegs
	
   If _nTotRegs == 0
      U_ItMsg("N�o h� dados para exportar para o Excel!","Aten��o",,1)
      Break 
   EndIf 

   _aItemMix  := {} 
   Aadd(_aItemMix,{"G1","Grupo 1"}) 
   Aadd(_aItemMix,{"G2","Grupo 2"}) 
   Aadd(_aItemMix,{"G3","Grupo 3"}) 
   Aadd(_aItemMix,{"G9","Outros"}) 
   Aadd(_aItemMix,{"G0","Indefinido"}) 
 
   TRBZB0->(DbGotop())     
	
   ProcRegua(_nTotRegs)
	
	Do While TRBZB0->(!Eof())  
	
		IncProc("Processando Contrato: " + TRBZB0->ZB0_COD)            

      _cDescPrd  := Posicione("SB1",1,xFilial("SB1") + TRBZB0->ZB0_SB1COD,"SB1->B1_I_DESCD")
      		
      _cCliRazSoc := ""
      _cNomeReduz := ""
      If ! Empty(TRBZB0->ZB0_CLIENT)  .And. ! Empty(TRBZB0->ZB0_LOJA)
	      _cCliRazSoc := Posicione("SA1",1,xFilial("SA1") + TRBZB0->ZB0_CLIENT + TRBZB0->ZB0_LOJA,"A1_NOME")
         _cNomeReduz := Posicione("SA1",1,xFilial("SA1") + TRBZB0->ZB0_CLIENT + TRBZB0->ZB0_LOJA,"A1_NREDUZ")
      ElseIf ! Empty(TRBZB0->ZB0_CLIENT) 
	      _cCliRazSoc := Posicione("SA1",1,xFilial("SA1") + TRBZB0->ZB0_CLIENT,"A1_NOME")
         _cNomeReduz := ""
      EndIf	

      _cGrpMix := Posicione("SB1",1,xFilial('SB1')+ TRBZB0->ZB0_SB1COD,"B1_I_BIMIX") 

      _cGrupo  := Posicione("SBM",1,xFilial('SBM')+ TRBZB0->ZB0_SB1COD,"BM_GRUPO")   

      _cDescMix := " "
      If ! Empty(_cGrpMix)
         _nI := Ascan(_aItemMix,{|x| x[1] == AllTrim(_cGrpMix) }) 
         If _nI > 0
            _cDescMix := _aItemMix[_nI,2]
         EndIf 
      EndIf 

      _cAbatimen := " "
      If ! Empty(TRBZB0->ZB0_ABATIM)
         If AllTrim(TRBZB0->ZB0_ABATIM) == "I"
            _cAbatimen := "INTEGRAL"
         ElseIf AllTrim(TRBZB0->ZB0_ABATIM) == "P"
            _cAbatimen := "PARCIAL"
         ElseIf AllTrim(TRBZB0->ZB0_ABATIM) == "N"
            _cAbatimen := "NAO POSSUI"
         EndIf 
      EndIf 

      Aadd(_aDados, {TRBZB0->ZB0_COD,;      // 1 = Contrato
                     TRBZB0->ZB0_ITEM,;     // 2 = Item
                     _cGrupo,;              // 3 = Grupo
                     TRBZB0->ZB0_SB1COD,;   // 4 = Produto
                     _cDescPrd,;            // 5 = Descri��o
                     TRBZB0->ZB0_DESCTO,;   // 6 = % Desconto
                     TRBZB0->ZB0_CONTR,;    // 7 = Contrato Italac
                     TRBZB0->ZB0_CLIENT,;   // 8 = Cliente
                     TRBZB0->ZB0_LOJA,;     // 9 = Loja
		     	          _cCliRazSoc,;         // 10 = Raz�o Social
                      _cNomeReduz,;         // 11 = Nome Fantasia
                      _cAbatimen,;          // TRBZB0->ZB0_ABATIM,;  // 12 = Abatimento 
                      TRBZB0->ZB0_DESCPA,;  // 13 = % Desconto Parcial
                      TRBZB0->ZB0_EST,;     // 14 = Estado
                      _cDescMix})           // 15 = Mix BI
        
      TRBZB0->(DbSkip())
   EndDo    

   _aCabec := {"Contrato",;
               "Item",;
               "Grupo",;
               "Produto",;
               "Descri��o",;
               "% Desconto",;
               "Contrato Italac",;
               "Cliente",;
               "Loja",;
               "Raz�o Social",;
               "Nome Fantasia",;
               "Abatimento",; 
               "% Desconto Parcial",;
               "Estado",;
               "Mix BI"}

   U_ITListBox("ACORDO COMERCIAL" , _aCabec , _aDados , .T. , 1 , "Exporta��o excel/arquivo")

End Sequence 

If Select("TRBZB0") > 0 
 	TRBZB0->(dbCloseArea())
EndIf

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS23VLD
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/09/2023
===============================================================================================================================
Descri��o---------: Valida o preenchimento de campos da tela de fitro.
===============================================================================================================================
Parametros--------: _cCampo = campo que chamou a valida��o
===============================================================================================================================
Retorno-----------: _lRet = .T./.F. 
===============================================================================================================================
*/

Static Function AOMS23VLD(_cCampo)
Local _lRet := .T.

Begin Sequence 

   If _cCampo == "PRODUTO"
      SB1->(DbSetOrder(1))
      If ! SB1->(MsSeek(xFilial("SB1")+_cFiltroPrd))
         U_ItMsg("O c�digo de produto informando n�o existe.","Aten��o!","Informe um c�d�go de produto v�lido.",1)
         _lRet := .F.
         Break
      EndIf          

   ElseIf _cCampo == "CLIENTE"
      SA1->(DbSetOrder(1))
      If ! SA1->(MsSeek(xFilial("SA1")+_cFiltroCliente))
         U_ItMsg("O c�digo de cliente informando n�o existe.","Aten��o!","Informe um c�d�go de cliente v�lido.",1)
         _lRet := .F.
         Break
      EndIf 

   ElseIf _cCampo == "CLIENTE_LOJA"
      SA1->(DbSetOrder(1))
      If ! SA1->(MsSeek(xFilial("SA1") + _cFiltroCliente + _cFiltroLoja))
         U_ItMsg("O c�digo de cliente e loja informandos n�o existe.","Aten��o!","Informe um c�d�go e loja de cliente v�lido.",1)
         _lRet := .F.
         Break
      EndIf 

   ElseIf _cCampo == "GRUPO_PRODUTO"
      SBM->(DbSetOrder(1))
      If ! SBM->(MsSeek(xFilial("SBM")+_cGrupoPrd))
         U_ItMsg("O grupo de produto informando n�o existe.","Aten��o!","Informe um grupo de produtos v�lido.",1)
         _lRet := .F.
         Break
      EndIf  

   EndIf

End Sequence 

Return _lRet


//======================================================================================================================//
/*		
TMPCONT->ZB0_ITEM
SubStr(AllTrim(TMPCONT->ZB0_SB1COD) + '-' + AllTrim(Posicione("SB1",1,xFilial("SB1") + TMPCONT->ZB0_SB1COD,"SB1->B1_I_DESCD"))
Transform(TMPCONT->ZB0_DESCTO,"@R 99.99") + "%"
SubStr(AllTrim(TMPCONT->ZB0_CONTR),1,12)
cCliLoja  := TMPCONT->ZB0_CLIENT + '/' + TMPCONT->ZB0_LOJA
		
If Len(AllTrim(TMPCONT->ZB0_LOJA)) > 1
	cCliRazSoc:= SubStr(AllTrim(Posicione("SA1",1,xFilial("SA1") + TMPCONT->ZB0_CLIENT + TMPCONT->ZB0_LOJA,"A1_NOME")),1,30) + '-'+ SubStr(AllTrim(Posicione("SA1",1,xFilial("SA1") + TMPCONT->ZB0_CLIENT + TMPCONT->ZB0_LOJA,"A1_NREDUZ")),1,18)  
Else 
	cCliRazSoc:= SubStr(AllTrim(Posicione("SA1",1,xFilial("SA1") + TMPCONT->ZB0_CLIENT,"A1_NOME")),1,30)
EndIf	
		
cCliRazSoc
TMPCONT->ZB0_EST
*/

/*
      Aadd(_aDados, {TRBZB0->ZB0_COD,;
                     TRBZB0->ZB0_ITEM,;
                     TRBZB0->ZB0_SB1COD,;
                     _cDescPrd,; //  := Posicione("SB1",1,xFilial("SB1") + TRBZB0->ZB0_SB1COD,"SB1->B1_I_DESCD")
                     _cDesconto,; // := TRBZB0->ZB0_DESCTO
                     TRBZB0->ZB0_CONTR,;
                     TRBZB0->ZB0_CLIENT,;
                     TRBZB0->ZB0_LOJA,;
		     	          _cCliRazSoc,; // := Posicione("SA1",1,xFilial("SA1") + TRBZB0->ZB0_CLIENT + TRBZB0->ZB0_LOJA,"A1_NOME")
                      _cNomeReduz,; // := Posicione("SA1",1,xFilial("SA1") + TRBZB0->ZB0_CLIENT + TRBZB0->ZB0_LOJA,"A1_NREDUZ")
                      TRBZB0->ZB0_EST})
*/
