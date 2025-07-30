/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer     | 02/08/2017 | Chamado 20782 - Ajustes para vers�o 12.
Julio Paz         | 27/11/2018 | Chamado 27001 - Ajustar o fonte para funcionar no novo servidor Totvs Lobo Guar�. 
Lucas Borges      | 15/10/2019 | Chamado 28346 - Removidos os Warning na compila��o da release 12.1.25. 
==============================================================================================================================

===============================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado  - Motivo da Altera��o
===============================================================================================================================
Antonio Ramos    - Igor Melga�o      - 30/09/2024 -            - 48661    - Erro na emissao de RPA da unidade de Girua.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

#DEFINE _ENTER CHR(13)+CHR(10) 

/*
===============================================================================================================================
Programa--------: AOMS042
Autor-----------: Fabiano Dias
Data da Criacao-: 22/12/2010
===============================================================================================================================
Descri��o-------: Inclus�o e gera��o de RPA Avulso
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS042()

Private aObjects	:= {}
Private aPosObj		:= {}

Private aSize		:= MsAdvSize()
Private aInfo		:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 3 }
Private aRotina		:= {	{ OemToAnsi( "Pesquisar"	) , "AxPesqui"				, 0 , 1 } ,;
							{ OemToAnsi( "Visualizar"	) , 'U_AOMS042R( 2 )'		, 0 , 2 } ,;
        	    			{ OemToAnsi( "Incluir"		) , 'U_AOMS042R( 3 )'		, 0 , 3 } ,;
    	     	   			{ OemToAnsi( "Excluir"		) , 'U_AOMS042R( 4 )'		, 0 , 4 } ,;
	               			{ OemToAnsi( "Imprimir" 	) , 'U_ROMS024(1,"","","")'	, 0 , 4 }  }

Private cCadastro	:= OemToAnsi("RPA AVULSO")
Private cTitulo		:= "RPA - Avulso"

Private iTab1		:= "ZZA"


//================================================================================
//| Guarda as dimens�es da tela                                                  |
//================================================================================
AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )

aPosObj := MsObjSize( aInfo , aObjects )

//================================================================================
//| Endereca a funcao de BROWSE                                                  |
//================================================================================
DBSelectArea(iTab1)
(iTab1)->( DBSetOrder(1) )
MBrowse( ,,,, iTab1 )

Return()

/*
===============================================================================================================================
Programa----------: AOMS042R
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Monta tela com os dados do RPA Avulso
===============================================================================================================================
Parametros--------: nOpc: opcao
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS042R( nOpc )

Local bCampo			:= {|nCPO| Field(nCPO) }
Local vCampos			:= {} // campos de visuzaliacao
Local aButtons			:= {}
Local _cOpcao			:= ""
Local _cTpOper			:= ""
Local _cExcluir			:= ""
Local nReg				:= 0
Local _nI				:= 0
Local _nOpc				:= 0
Local cAliasEnchoice	:= iTab1
Local cAliasGetd    	:= "ZZB"
Local cAlias        	:= "ZZB"
Local cLinOk        	:= "AllwaysTrue()"
Local cTudOk        	:= "AllwaysTrue()"
Local cFieldOk      	:= "",nCntFor,v
Local aHeaderZZA
Local _nPosALIWT, _nPosRECWT

Private oDlg			:= ""
Private _cMatrUsr		:= U_UCFG001(1)
Private xVarAux	 		:= Nil

Private AHEADER	 		:= {}
Private ACOLS	 		:= {}
Private aGets	 		:= {}
Private aTela	 		:= {}

Begin Sequence
   //Log de utiliza��o
   U_ITLOGACS()

   //DBSelectArea("ZZL")
   ZZL->( DBSetOrder(1) )
   If ZZL->( DBSeek( xFilial("ZZL") + _cMatrUsr ) )
      _cTpOper	:= ZZL->ZZL_TPOPER
      _cExcluir	:= ZZL->ZZL_EXRPA
   EndIf

   //Verifica se o usuario tem acesso ao RPA Avulso na inclusao ou exclusao
   If ( nOpc == 3 .Or. nOpc == 4 ) .And. Empty( _cTpOper )

	  xmaghelpfis(	"Usu�rio sem acesso!"																				,;
					"O usu�rio corrente n�o possui acesso para realizar a opera��o solicitada na rotina de RPA Avulso."	,;
					"Verificar a necessidade e informar a �rea de TI/ERP."												 )
	  Break

   EndIf

   //Quando for realizar a exclusao Verifica se o usuario tem acesso para realizar a exclusao
   If nOpc == 4 .And. _cExcluir <> 'S'

	  xmaghelpfis(	"Usu�rio sem acesso!"																				,;
					"O usu�rio corrente n�o possui acesso para realizar a exclus�o de um RPA Avulso em seu cadastro."	,;
					"A exclus�o s� poder� ser efetuada por respons�vel cont�bil."										 )
	
	  Break
   
   EndIf

   If nOpc == 3 // Incluir

	  nOpcE	:= 3
	  nOpcG	:= 3
	  _cOpcao	:= "Inser��o"

   ElseIf nOpc == 2 // Visualizar

	  nOpcE	:= 2
	  nOpcG	:= 2
	  _cOpcao	:= "Visualiza��o"

   Else // Excluir

	  nOpcE	:= 4
	  nOpcG	:= 4
	  _cOpcao	:= "Exclus�o"

   EndIf

   //================================================================================
   //| Cria variaveis M->????? da Enchoice                                          |
   //================================================================================
   FillGetDados(1,"ZZA",1,,,{||.T.},,,,,,.T.)
   aHeaderZZA	:= AClone(aHeader)

   aHeader := {}
   FillGetDados(1,"ZZB",1,,,{||.T.},,,,,,.T.)
   nUsado := Len(aHeader)

   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})

   aCpoEnchoice := {}

   For _nI := 1 To Len(aHeaderZZA)
       If AllTrim(aHeaderZZA[_nI,2]) $ "ZZA_ALI_WT/ZZA_REC_WT"
          Loop
       EndIf
       
       If X3USO( aHeaderZZA[_nI,7] ) 
		  Aadd( aCpoEnchoice , aHeaderZZA[_nI,2] )
	   EndIf
	
	   xVarAux	:= "M->"+ aHeaderZZA[_nI,2]
	   &xVarAux	:= CriaVar( aHeaderZZA[_nI,2] )
   Next

   If nOpc <> 3 // se nao for inclusao preenche os campos do cabecalho

	  DBSelectArea(iTab1)
	
	  For nCntFor := 1 TO FCount()
		  M->&( EVAL( bCampo , nCntFor ) ) := FieldGet( nCntFor )
	  Next
	
	  For v := 1 To Len( vCampos ) // CAMPOS DE VISUALIZACAO
		  xVarAux	:= "M->"+ vCampos[v,1]
		  &xVarAux	:= &( vCampos[v,2] )
	  next v
	
   EndIf

   //Incluir
   If nOpc == 3

      M->ZZA_USUARI := U_UCFG001(1) 
      M->ZZA_DESUSR := Posicione( "SRA" , 1 , M->ZZA_USUARI , "SRA->RA_NOME" )
     
      //Se o tipo da operacao que o usuario for realizar na inclusao for diferente de todos
      //o progrma ja seta o tipo de acordo com o acesso pre-definido em seu cadastro
      If _cTpOper <> 'T'
     
     	 M->ZZA_TPFORN:= _cTpOper 
     
      EndIf  
     
   ElseIf nOpc == 4

	  //Os RPA's gerados pela rotina do Leite somente poderao ser excluidos por ela
	  If M->ZZA_ORIGEM <> '1'
	
		 xmaghelpfis(	"Informa��o" , "O RPA: " + M->ZZA_CODRPA + " foi gerado pela rotina de Fechamento do Frete."	,;
						"Sendo assim somente podera ser excluido pela rotina de Cancelamento do frete"					 )
     	
   		 Break 
	
	  EndIf

   EndIf

//================================================================================
//| Cria aHeader e aCols da GetDados                                             |
//================================================================================
   For _nI := 1 To Len(aHeader)
       If AllTrim(aHeader[_nI,2]) $ "ZZB_ALI_WT/ZZB_REC_WT"
          Loop
       EndIf
       
	   xVarAux	:= "M->"+ aHeader[_nI,2]
	   &xVarAux	:= CriaVar( aHeader[_nI,2] )
   Next

   _nPosALIWT := Ascan(aHeader,{|x| x[2] == "ZZB_ALI_WT"})
   _nPosRECWT := Ascan(aHeader,{|x| x[2] == "ZZB_REC_WT"})

   DBSelectArea(iTab1)

   //================================================================================
   //| Preenche o aCols da GetDados                                                 |
   //================================================================================
   If nOpc == 3 // Incluir

	  aCols				:= { Array( nUsado + 1) }
	  aCols[01][nUsado+1]	:= .F.
	
	  For _nI := 1 to nUsado
	
	      If _nI ==_nPosALIWT .Or. _nI == _nPosRECWT 
	          Loop
	      EndIf
	      
		  aCols[01][_nI]	:= CriaVar( aHeader[_nI][02] )
		
	  Next _nI
	
	  aCols[01][01] := "001"
	
   Else

      aCols	:= {}
	
	  DBSelectArea("ZZB")
	  ZZB->( DBSetOrder(1) )
	  IF ZZB->( DBSeek( ZZA->ZZA_FILIAL + ZZA->ZZA_CODRPA ) )
	
		 While ZZB->(!Eof()) .And. ZZB->( ZZB_FILIAL + ZZB_CODRPA ) == xFilial("ZZB") + M->ZZA_CODRPA
		
			aAdd( aCols , Array( nUsado + 1 ) )
			
			For _nI := 1 To nUsado 
			    If _nI ==_nPosALIWT .Or. _nI == _nPosRECWT 
	               Loop
	            EndIf
			
				aCols[Len(aCols)][_ni] := IIf( aHeader[_ni][10] # "V" , FieldGet( FieldPos( aHeader[_ni][02] ) ) , CriaVar( aHeader[_ni][02] ) )
				
			Next _nI
			
			aCols[Len(aCols)][nUsado+1] := .F.
			
		    ZZB->( DBSkip() )
		 EndDo
		
	  Else
	
		 aCols				:= { Array( nUsado + 1 ) }
		 aCols[01][nUsado+1]	:= .F.
		
		 For _nI := 1 To nUsado
		     If _nI ==_nPosALIWT .Or. _nI == _nPosRECWT 
	            Loop
	         EndIf
	            
			 aCols[1,_ni] := CriaVar( aHeader[_ni][02] )
			
		 Next _nI
		
		 aCols[1,1] := "001"
		
	  EndIf 
	
   Endif

   //================================================================================
   //| Monta a tela para exibi��o                                                   |
   //================================================================================
   If Len(aHeader) > 0

	  cAliasEnchoice	:= iTab1
	  cAliasGetd    	:= "ZZB"
	  cAlias        	:= "ZZB"
      cLinOk        	:= "AllwaysTrue()"
      cTudOk        	:= "AllwaysTrue()"
      cFieldOk      	:= ""

	  aSize    := MsAdvSize()
	  aObjects := {}
	  AAdd( aObjects, { 100, 100, .T., .T. } )
	  AAdd( aObjects, { 100, 100, .T., .T. } )
	
	  aInfo   := { aSize[ 1 ],aSize[ 2 ],aSize[ 3 ],aSize[ 4 ],03,03 }
	  aPosObj := MsObjSize( aInfo, aObjects )
	
	  DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
		 EnChoice( cAliasEnchoice , nReg , nOpcE ,,,, aCpoEnchoice , aPosObj[1] ,, 3 ,,,,,, .F. )
		
		 oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"+ZZB_ITEM",.T.,,,,)
		
		 oGetDados:LACTIVE := .F.
		
	  ACTIVATE MSDIALOG oDlg CENTERED ON INIT ;
	           EnchoiceBar( oDlg , {|| IIf( Obrigatorio(aGets,aTela) .And. AOMS042V(nOpcE) , LjMsgRun( "Gerando a "+ _cOpcao +" do RPA..." , "Aguarde!" , {|| CursorWait() , _nOpc := 1 , AOMS042G() , CursorArrow() } ) , _nOpc := 0 ) , IIF( _nOpc == 1 , oDlg:End() , Nil ) } , {|| _nOpc := 0 , oDlg:End() , RollBackSX8() } ,, aButtons )

   EndIf

End Sequence

Return()

/*
===============================================================================================================================
Programa----------: AOMS042V
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Valida��o dos dados preenchidos
===============================================================================================================================
Parametros--------: iopc: opcao
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS042V( iopc )

Local _lret		:= .T.

Begin Sequence
   //================================================================================
   //| Verifica se esta sendo efetuada uma inclusao                                 |
   //================================================================================
   If iopc == 3
	
	  //================================================================================
	  //| Valida se o autonomo esta demitido no cadastro de autonomos na SRA           |
	  //================================================================================
	  _lRet := vldAuton( M->ZZA_CODAUT )
	
	  //================================================================================
	  //| Verifica se ja efetuou o calculo dos impostos antes de gerar a inclusao      |
	  //================================================================================
	  If _lRet .And. ( Len(aCols) == 1 .And. aCols[1,3] == 0 ) .Or. ( Len(aCols) < 1 )
          
		 xmaghelpfis(	"Aten��o!"																				,;
						"Favor calcular os impostos do RPA antes de confirmar a sua inclus�o."					,;
						"A op��o de c�lculo de impostos esta situada no cabe�alho da tela no bot�o IMPOSTOS."	 )
		
		 _lret := .F.
		
	  EndIf

	  //================================================================================
	  //| Tratamento efetuado para quando o usuario nao  fornece  nenhum  conteudo  no |
	  //| Memo mais sim dar enter, ele considera isto como conteudo.                   |
	  //================================================================================
	  If _lRet .And. Empty( STRTRAN( M->ZZA_OBSERV , CHR(13)+CHR(10) , " " ) )
	
		 xmaghelpfis(	"Aten��o!"																					,;
						"Favor fornecer um conte�do no campo observa��o para que esta rotina possa ser efetivada."	,;
						"Favor preencher o campo observa��o."														 )
		
		 _lret := .F.
	
	  EndIf
	
	  //================================================================================
	  //| Checa se existe amarracao do autonomo no cadastro do Fornecedor              |
	  //================================================================================
	  DBSelectArea("SA2")
	  SA2->( DBOrderNickName( "IT_AUTONOM" ) )
	  If !SA2->( DBSeek( xFilial("SA2") + M->ZZA_CODAUT ) ) .And. _lRet
		 DbSelectArea("SA2")
		 SA2->( DBOrderNickName( "IT_AUTAVUL" ) )
		 If !SA2->( DBSeek( xFilial("SA2") + M->ZZA_CODAUT ) ) .And. _lRet
			xmaghelpfis(	"Aten��o"																																,;
							"O Autonomo indicado para a gera��o do RPA nao esta com o relacionamento no cadastro do Fornecedor."									,;
							"Favor verificar no cadastro do Fornecedor se o autonomo indicado possui cadastro, e se esta relacionado no cadastro de fornecedor. "	 )
			_lRet:= .F.
		 EndIf
	  EndIf
	  If _lRet
		 //================================================================================
		 //| Valida a natureza informada pelo usu�rio                                     |
		 //================================================================================
		 DBSelectArea("SED")
		 SED->( DBSetOrder(1) )
		 If SED->( DBSeek( xFilial("SED") + ZZA_NATURE ) )
			If SED->ED_CALCINS == 'S' .Or. SED->ED_CALCIRF == 'S' .Or. SED->ED_CALCSES == 'S'
			   xmaghelpfis(	"Informa��o"																,;
							"N�o foi informada uma natureza v�lida!"									,;
							"A natureza para gera��o do RPA n�o pode calcular INSS,IRRF e SEST/SENAT."	 )
			   _lRet:= .F.
			EndIf
		 EndIf
	  EndIf
      //================================================================================
	  //| Valida o tipo do Fornecedor fornecido pelo usu�rio                           |
	  //================================================================================
	  If _lRet
		 _lRet := vldIncRPA()
	  EndIf
	
      //================================================================================
      //| Validacao para exclus�o de um RPA                                            |
      //================================================================================
      Elseif iopc == 4
         _lRet := vldExcRPA()
	     If !_lRet
		    //================================================================================
		    //| Verifica se o usuario tem permissao para executar o Estorno sem validar      | - 31/07/14 - Alexandre Villar
		    //================================================================================
		    DbSelectArea("ZZL")
		    ZZL->( DbSetOrder(3) )
		    If ZZL->( DbSeek( xFILIAL("ZZL") + RetCodUsr() ) )
			   If ZZL->ZZL_ECARGA == "S"
				  If Aviso( 'Aten��o!' , 'O estorno do documento atual n�o passou pela valida��o de impostos, deseja prosseguir com o estorno mesmo assim?' , {'Estornar','Cancelar'} ) == 1
					 _lRet := .T.
				  EndIf
			   EndIf
		    EndIf
	     EndIf
      EndIf

End Sequence      

Return( _lret )

/*
===============================================================================================================================
Programa----------: AOMS042G
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Grava dados do cabecalho e itens do RPA AVULSO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS042G()

Local ax           := "",x,i
Local _lRet        := .T.

Local _cCodRPAAv   := ""

Private _cCodRecib := ""

Begin Sequence
   //================================================================================
   //| Quando n�o for consulta                                                      |
   //================================================================================
   If nOpcG # 2

	  Begin Transaction
	     //================================================================================
	     //| Gera o codigo do novo RPA                                                    |
	     //================================================================================
	     If Inclui
		    DBSelectArea("ZZ2")
		    //================================================================================
		    //| Grava o codigo do novo RPA a ser gerado                                      |
		    //================================================================================
		    M->ZZA_RPA := CriaVar( "ZZ2_RECIBO" )
		    ConfirmSX8()
		
		    If ( __lSX8 )
			   ConfirmSX8()
		    EndIf
		
		    _cCodRecib	:= M->ZZA_RPA
		    _cCodRPAAv	:= M->ZZA_CODRPA //Codigo do RPA Avulso
		
		    //================================================================================
		    //| Efetua a inclusao na tabela ZZ2 - Responsavel pelo RPA de todas as Filiais   |
		    //================================================================================
		    AOMS042IZ2()
		
		    _lRet := AOMS042IE2()
		
		    //================================================================================
		    //| Disarma a transacao em caso de erro na inclusao do titulo RPA no financeiro  |
		    //================================================================================
		    If !_lRet
			   DisarmTransaction()
			   Break
		    EndIf
	
	        //================================================================================
	        //| Trata exclusao dos titulos na SE2 e da tabela ZZ2                            |
	        //================================================================================
	     Else
		    _lRet := ExcluiSE2()
		
		    //================================================================================
		    //| Disarma a transacao em caso de erro na inclusao do titulo RPA no financeiro  |
		    //================================================================================
		    If !_lRet
			   DisarmTransaction()
			   Break
		    EndIf
		
		    //================================================================================
		    //| Deleta registro na tabela ZZ2                                                |
		    //================================================================================
		    DBSelectArea("ZZ2")
		    ZZ2->( DBSetOrder(1) )
		    If ZZ2->( DBSeek( xFilial("ZZ2") + M->ZZA_RPA ) )
			   ZZ2->( RecLock( "ZZ2" , .F. ) )
			   ZZ2->( DBDelete() )
			   ZZ2->( MsUnlock() )
			   WriteSx2("ZZ2")
		    Else
			   xmaghelpfis(	"Aten��o!" 																															,;
							"N�o foi localizado o registro do RPA na tabela ZZ2."																				,;
		  					"Favor comunicar o departamento de inform�tica do problema ocorrido, diante disso n�o ser� poss�vel realizar a exclus�o do RPA "	 )
			   Break
		    EndIf
	     EndIf

         DBSelectArea("ZZA")
	     ZZA->( DBSetOrder(1) )
	     wProcura := ZZA->( DBSeek( xFilial("ZZA") + M->ZZA_CODRPA ) )
		 If Inclui
		    ZZA->( RecLock( "ZZA" , If( wProcura , .F. , .T. ) ) )
			ZZA->ZZA_FILIAL  := xFilial("ZZA")
			ZZA->ZZA_ORIGEM  := "1"

			For x := 1 To Len( aCpoEnchoice )
				xVarAux	:= "M->"   + aCpoEnchoice[x]
				ax		:= "ZZA->" + aCpoEnchoice[x]
				If Posicione( "SX3" , 2 , aCpoEnchoice[x] , "X3_CONTEXT" ) <> "V"
				   &ax	:= &xVarAux
				EndIf
			Next x
		    ZZA->( MsUnlock() )
		    
		    If Inclui
			   ConfirmSx8()
		    EndIf
	     Else
		    ZZA->( RecLock( "ZZA" , .F. ) )
		    ZZA->( DBDelete() )
		    ZZA->( MsUnlock() )
		    WriteSx2("ZZA")
	     EndIf
	     
	     //================================================================================
	     //| Deleta todos os itens                                                        |
	     //================================================================================
	     DBSelectArea("ZZB")
	     ZZB->( DBSetOrder(1) )
	     ZZB->( DBGoTop() )
	
	     wProcura := ZZB->( DBSeek( xFilial("ZZB") + M->ZZA_CODRPA ) )
	
	     While ( ZZB->(!EOF()) .And. ( XFILIAL("ZZB") + ZZB->ZZB_CODRPA == xFilial("ZZB") + M->ZZA_CODRPA ) )
		    ZZB->( RecLock("ZZB",.F.,.T.) )
		    ZZB->( DBDelete() )
		    ZZB->( MsUnlock() )
		
		    WriteSx2("ZZB")
		
	        ZZB->( DBSkip() )
	     EndDo
	
	     //================================================================================	
	     //| Grava os itens                                                               |
	     //================================================================================
	     For i := 1 To Len( aCols )
		     DBSelectArea("ZZB")
		     ZZB->( DBSetOrder(1) )
		     ZZB->( DBGoTop() )
		
		     wProcura := ZZB->( DBSeek( xFilial("ZZB") + M->ZZA_CODRPA + aCols[i][01] ) )
		
		     If Inclui //.or. Altera
		
			    If aCols[i,len(aCols[i])] .And. wProcura // exclusao
			
				   RecLock("ZZB",.F.,.T.)
				   dbdelete()
				   ZZB->(MsUnlock())
				   WriteSx2("ZZB")
				
			    Else
			
				   If !aCols[i,len(aCols[i])]  
				
					  ZZB->( RecLock( "ZZB" , IIf( wProcura , .F. , .T. ) ) )
					
					  ZZB->ZZB_FILIAL   := XFILIAL("ZZB")
					  ZZB->ZZB_CODRPA   := M->ZZA_CODRPA
					  ZZB->ZZB_ITEM     := aCols[i][01]
					  ZZB->ZZB_VENCTO   := aCols[i][02]
					  ZZB->ZZB_VALOR    := aCols[i][03]
					
					  ZZB->( MsUnlock() )
					
					  If Inclui
						 ConfirmSx8()
					  EndIf
					
				   EndIf
				
			    EndIf
			
		     Else
		
			    If wProcura  // opcao exclusao do menu
			
				   // deletando ZLB
				   ZZB->( RecLock( "ZZB" , .F. ) )
				   ZZB->( DBDelete() )
				   ZZB->( MsUnlock() )
				
				   WriteSx2("ZZB")
			    EndIf
			
		     EndIf
	      Next i
	
	      //================================================================================
	      //| Finaliza a transacao                                                         |
	      //================================================================================
	  End Transaction
   EndIf

   //================================================================================
   //| Fecha a janela                                                               |
   //================================================================================
   oDlg:End()

   //================================================================================
   //| Caso tenha incluido um novo RPA avulso e nao tenha ocorrido erro             |
   //================================================================================
   If Inclui .And. _lRet
	  U_ROMS024( 0 , _cCodRecib , _cCodRecib , "" )
   EndIF

End Sequuence.

Return( .T. )

/*
===============================================================================================================================
Programa----------: AOMS042IZ2
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Grava dados do RPA avulso na tabela de RPA para futuros calculos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS042IZ2()     
Local _aArea:= GetArea()

Begin Sequence 
   DBSelectArea("ZZ2")
   ZZ2->( RecLock( "ZZ2" , .T. ) )
   ZZ2->ZZ2_FILIAL	:= xFilial("ZZ2")
   ZZ2->ZZ2_RECIBO	:= _cCodRecib
   ZZ2->ZZ2_CARGA 	:= ""
   ZZ2->ZZ2_AUTONO	:= M->ZZA_CODAUT
   ZZ2->ZZ2_COND  	:= M->ZZA_CONPAG
   ZZ2->ZZ2_TOTAL 	:= M->ZZA_VLRBRT
   ZZ2->ZZ2_SEST  	:= M->ZZA_SEST
   ZZ2->ZZ2_INSS  	:= M->ZZA_INSS
   ZZ2->ZZ2_IRRF	:= M->ZZA_IRRF
   ZZ2->ZZ2_DATA  	:= dDataBase
   ZZ2->ZZ2_TIPAUT	:= "1"
   ZZ2->ZZ2_OBS	:= ""
   ZZ2->ZZ2_PAMCAR	:= ""
   ZZ2->ZZ2_PAMVLR := 0
   ZZ2->ZZ2_ORIGEM := "2"
   ZZ2->ZZ2_VRPEDA := M->ZZA_VRPEDA//AWF 17/10/2016
   ZZ2->( MsUnlock() )
   RestArea(_aArea)

End Sequence

Return()

/*
===============================================================================================================================
Programa----------: AOMS042PAR
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Grava dados do RPA avulso na tabela de RPA para futuros calculos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS042PAR()
Local _aParcelas	:= {}
Local _nI			:= 0

Begin Sequence
   //================================================================================
   //| Preenche os itens                                                            |
   //================================================================================
   aCols := {}
   
   aHeader := {}   
   FillGetDados(1,"ZZB",1,,,{||.T.},,,,,,.T.)
   nUsado := Len(aHeader)

   //================================================================================
   //| 1 - Valor total a ser parcelado                                              |
   //| 2 - C�digo da condi��o de pagamento                                          |
   //| 3 - Valor do IPI, para que obrigue o pagamento do IPI na 1� parcela          |
   //| 4 - Data inicial para considerar a geracao do vencimento                     |
   //================================================================================
   _aParcelas := Condicao( M->ZZA_VLRBRT , M->ZZA_CONPAG ,, M->ZZA_DTEMIS )

   For _nI := 1 To Len( _aParcelas )
       If _nI == 1  
          aCols[_nI,1] := StrZero( _nI , 03 )
          aCols[_nI,2] := _aParcelas[_nI][01]
          aCols[_nI,3] := _aParcelas[_nI][02]
          aCols[_nI,6] := .F. 
          
       Else
	      aAdd( aCols , { StrZero( _nI , 03 ) , _aParcelas[_nI][01] , _aParcelas[_nI][02], , , .F. } )
	   EndIf
   Next _nI

   oGetDados:ForceRefresh()
   oGetDados:Refresh()

End Sequence

Return()

/*
===============================================================================================================================
Programa----------: AOMS042IE2
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Efetua a insercao na tabela SE2 dos titulos a pagar referente ao RPA.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS042IE2()

Local _aArea		:= GetArea()
Local _nDesconto	:= 0
Local _cRecibo		:= ""
Local _cCodAuton	:= ""
Local _cANaturez	:= M->ZZA_NATURE
Local _cNomeFor		:= ""
Local _cCodFor		:= ""
Local _cLojaFor		:= ""
Local _cIRRFPri		:= ""
Local _nValSE2		:= 0
Local aVetor		:= {}

Local _nIRRF		:= 0
Local _nVLRETIR		:= GETMV( 'MV_VLRETIR' ,, 0 )
Local _aParc		:= {}

Local _cNatIRRF		:= StrTran( GetMv("MV_IRF",,"") , '"' , '' )
Local _cFornIRRF	:= PADR( GetMv("MV_UNIAO") , 6 )
Local _cVctoIRRF	:= GetMv( "MV_VENCIRF" ,, "" )
Local _dVctoIRRF	:= StoD("")
Local _cParcela		:= "01"
Local _cChave		:= " "
Local _nI			:= 0
Local _lRet			:= .T.

Local nModAnt		:= nModulo
Local cModAnt		:= cModulo

Private lMsErroAuto	:= .F.

Begin Sequence	
   DbSelectArea("ZZ2")
   ZZ2->( DBSetOrder(1))  // ZZ2_FILIAL+ZZ2_RECIBO
   If ZZ2->( DBSeek( xFilial("ZZ2") + _cCodRecib ) )
	  _cIRRFPri	:= ZZ2->ZZ2_IRRFPR
	  _nValFret	:= ZZ2->ZZ2_TOTAL
	  _cRecibo	:= ZZ2->ZZ2_RECIBO
	  _nIRRF		:= ZZ2->ZZ2_IRRF
	  _cCodAuton	:= ZZ2->ZZ2_AUTONO
	  _nDesconto	:= ZZ2->( ZZ2_PAMVLR + ZZ2_SEST + ZZ2_INSS ) + IIF( _lGravVl , ZZ2->ZZ2_IRRF , 0 )  //HEDER - Modificado para considerar o valor do IR qdo limite minimo ja tiver sido atingido
	
	  If _cIRRFPri == "S" .And. _nIRRF > _nVLRETIR
	
		 _aParc := Condicao( ZZ2->ZZ2_TOTAL , ZZ2->ZZ2_COND ,, dDataBase )
		
	  ElseIf	_cIRRFPri <> "S"
	
		 _aParc := Condicao( ZZ2->ZZ2_TOTAL , ZZ2->ZZ2_COND ,, dDataBase )
		
	  ElseIf 	_cIRRFPri == "S" .and. _nIRRF < _nVLRETIR
	
		 _aParc := Condicao( ZZ2->ZZ2_TOTAL , ZZ2->ZZ2_COND ,, dDataBase )
		
	  EndIf
	
	  If Len(_aParc) == 0
	
		 xMagHelpFis(	"ERRO"																																,;
						"Ocorreu um erro na gera��o do financeiro do titulo RPA, favor contactar o departamento de inform�tica informando de tal problema."	,;
						"Problema no controle de condi��o de pagamento da tabela ZZ2."																		 )
		
		 _lRet := .F.
		
		 Break
	  EndIf
	
	  //================================================================================
	  //| Pesquisa primeiramente os dados do Fornecedor na amarracao que o pessoal da  |
	  //| Logistica utiliza caso nao encontre pesquisa na amarracao de autonomo avulso |
	  //| criada                                                                       |
	  //================================================================================
	  DBSelectArea("SA2")
	  SA2->( DBOrderNickName( "IT_AUTONOM" ) )
	  If !SA2->( DBSeek( xFilial("SA2") + _cCodAuton ) )
	
		 DBSelectArea("SA2")
		 SA2->( DBOrderNickName( "IT_AUTAVUL" ) )
		 If SA2->( DBSeek( xFilial("SA2") + _cCodAuton ) )
		
			_cCodFor	:=	ALLTRIM( SA2->A2_COD )
			_cLojaFor 	:= 	SA2->A2_LOJA
			_cNomeFor 	:= 	SA2->A2_NOME
		
		 EndIf
	  Else
		 _cCodFor	:=	ALLTRIM( SA2->A2_COD )
		 _cLojaFor 	:= 	SA2->A2_LOJA
		 _cNomeFor 	:= 	SA2->A2_NOME
	  EndIf
	
	  //================================================================================
	  //| Gravando titulo no financeiro ref. ao valor do frete                         |
	  //================================================================================
	  If Len(_aParc) > 1
	
		 DBSelectArea("SE2")
		 SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		 If !SE2->( DbSeek( xFilial("SE2") + "AUT" + ZZ2->ZZ2_RECIBO + "01" + "RPA" ) )
		
			For _nI := 1 to Len( _aParc )
			
				lMsErroAuto := .F.
				
				If _nI == 1
				
				   aVetor := {	{ "E2_PREFIXO"	, "AUT"							, Nil } ,;
								{ "E2_NUM"		, _cRecibo						, Nil } ,;
								{ "E2_PARCELA"	, STRZERO( _nI , 2 )			, Nil } ,;
								{ "E2_TIPO"		, "RPA"							, Nil } ,;
								{ "E2_NATUREZ"	, _cANaturez					, Nil } ,;
								{ "E2_FORNECE"	, _cCodFor						, Nil } ,;
								{ "E2_LOJA"		, _cLojaFor						, Nil } ,;
								{ "E2_EMISSAO"	, dDataBase						, Nil } ,;
								{ "E2_VENCTO"	, _aParc[_nI][01]				, Nil } ,;
								{ "E2_VENCREA"	, DataValida( _aParc[_nI][01] )	, Nil } ,;
								{ "E2_VALOR"	, _aParc[_nI][02]	 			, Nil } ,;
								{ "E2_ORIGEM"	, "AOMS042"			 			, Nil }  }
				Else
				   //================================================================================
				   //| Se for ultima parcela desconta valor do seguro e impostos                    | //Modificacao feita por Jeane
				   //================================================================================
				   aVetor := {	{ "E2_PREFIXO"	, "AUT"																							, Nil } ,;
								{ "E2_NUM"		, _cRecibo																						, Nil } ,;
								{ "E2_PARCELA"	, STRZERO( _nI , 2 )																			, Nil } ,;
								{ "E2_TIPO"		, "RPA"																							, Nil } ,;
								{ "E2_NATUREZ"	, _cANaturez																					, Nil } ,;
								{ "E2_FORNECE"	, _cCodFor																						, Nil } ,;
								{ "E2_LOJA"		, _cLojaFor				   																		, Nil } ,;
								{ "E2_EMISSAO"	, dDataBase				   																		, Nil } ,;
								{ "E2_VENCTO"	, _aParc[_nI][01]		   	 																	, Nil } ,;
								{ "E2_VENCREA"	, DataValida( _aParc[_nI][01])																	, Nil } ,;
								{ "E2_VALOR"	, IIf( Len(_aParc) == _nI , _aParc[_nI][02] - _nDesconto + ZZ2->ZZ2_IRRF , _aParc[_nI][02] )	, Nil } ,;
								{ "E2_IRRF"		, 0.00																							, Nil } ,; //Deve passar zerado para o ExecAuto e corrigir depois [Chamado-7155]
								{ "E2_VRETIRF"	, IIf( Len(_aParc) == _nI , ZZ2->ZZ2_IRRF , 0 )						  							, Nil } ,;
								{ "E2_PARCIR"	, IIf( Len(_aParc) == _nI .and. ZZ2->ZZ2_IRRF > 0 , _cParcela , "  " )							, Nil } ,;
								{ "E2_ORIGEM"	, "AOMS042"															  							, Nil }  }
				EndIf
				
				//================================================================================
				//| Altera o modulo para Financeiro, senao o SigaAuto nao executa.               |
				//================================================================================
				nModulo := 6
				cModulo := "FIN"
				
				DBSelectArea("SE2")
				MSExecAuto( {|x,y,z| Fina050( x , y , z ) } , aVetor ,, 3 )
				
				//================================================================================
				// Inicio Altera��o - Talita - 19/12/2013 - Incluida validacao para que seja 
				// gravado o valor correto do titulo para os casos de IRF maior que 0 e menor que 
				// 10 conforme chamado: 4841
				//================================================================================
				// Altera��o da tratativa para que seja atualizado o valor do IR que n�o pode ser
				// enviado pelo ExecAuto - [Chamado-7155]
				//================================================================================
				If Len(_aParc) == _nI .And. ZZ2->ZZ2_IRRF > 0.00
				
					DbSelectArea("SE2")
					SE2->( DbSetOrder(1) )//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					If SE2->( DbSeek( xFilial("SE2") + "AUT" + _cRecibo + STRZERO( _nI , 2 ) ) )
					
						SE2->( Reclock("SE2", .F.) )
							_nValSE2		:= SE2->E2_VALOR
							SE2->E2_VALOR	:= _nValSE2 - ZZ2->ZZ2_IRRF
							SE2->E2_SALDO	:= _nValSE2 - ZZ2->ZZ2_IRRF
							SE2->E2_VLCRUZ	:= _nValSE2 - ZZ2->ZZ2_IRRF
							SE2->E2_IRRF	:= ZZ2->ZZ2_IRRF
						SE2->( MsUnlock() )
					
					EndIf
				
				EndIf  //Fim da altera��o
				
				//================================================================================
				//| Restaura o modulo em uso.                                                    |
				//================================================================================
				nModulo := nModAnt
				cModulo := cModAnt
				
				If lMsErroAuto
					Mostraerro()
					_lRet:= .F.
				EndIf
				
			Next _nI
		    //================================================================================
		    //| Titulo ja existente no financeiro                                            |
		    //================================================================================
		 Else
			xmaghelpfis(	"Informa��o"																																	,;
							"Nao foi poss�vel realizar a inclus�o no financeiro do t�tulo referente ao RPA."																,;
							"Favor comunicar o departamento de inform�tica do problema ocorrido, dados do t�tulo: PREFIXO - AUT, TIPO - RPA, NUMERO - " + ZZ2->ZZ2_RECIBO	 )
			_lRet := .F.
		 EndIf
	  Else
		 DBSelectArea("SE2")
		 SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		 If !SE2->( DbSeek( xFilial("SE2") + "AUT" + ZZ2->ZZ2_RECIBO + "  " + "RPA" ) )
			//================================================================================
			//| Parcela unica: desconta valor do seguro e impostos                           | //Modificacao feita por Jeane
			//================================================================================
			For _nI := 1 To Len(_aParc)
				lMsErroAuto	:= .F.
				aVetor		:= {	{ "E2_PREFIXO"	, "AUT"				   							, Nil },;
									{ "E2_NUM"		, _cRecibo                 						, Nil },;
									{ "E2_PARCELA"	, "  "		    		   						, Nil },;
									{ "E2_TIPO"		, "RPA"                  						, Nil },;
									{ "E2_NATUREZ"	, _cANaturez               						, Nil },;
									{ "E2_FORNECE"	, _cCodFor              		   				, Nil },;
									{ "E2_LOJA"		, _cLojaFor         		       				, Nil },;
									{ "E2_EMISSAO"	, dDataBase        		    					, Nil },;
									{ "E2_VENCTO"	, _aParc[_nI,1]           						, Nil },;
									{ "E2_VENCREA"	, DataValida(_aParc[_nI,1])			 			, Nil },;
									{ "E2_VALOR"	, _aParc[_nI,2] - _nDesconto				  	, Nil },;
									{ "E2_IRRF"		, 0.00											, Nil },; //Deve passar zerado para o ExecAuto e corrigir depois [Chamado-7155]
									{ "E2_VRETIRF"	, ZZ2->ZZ2_IRRF									, Nil },;
									{ "E2_PARCIR"	, IIF( ZZ2->ZZ2_IRRF > 0 , _cParcela , "  " )	, Nil },;
									{ "E2_ORIGEM"	, "AOMS042"             						, Nil } }
				//================================================================================
				//| Altera o modulo para Financeiro, senao o SigaAuto nao executa.               |
				//================================================================================
				nModulo := 6
				cModulo := "FIN"     
				
				MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,3)
				
				If lMsErroAuto
				
					Mostraerro()
					_lRet := .F.
					
				EndIf
				
				//================================================================================
				//| Restaura o modulo em uso.                                                    |
				//================================================================================
				nModulo := nModAnt
				cModulo := cModAnt
				
				//================================================================================
				// Inicio Altera��o - Talita - 19/12/2013 - Incluida validacao para que seja 
				// gravado o valor correto do titulo para os casos de IRF maior que 0 e menor que 
				// 10 conforme chamado: 4841
				//================================================================================
				// Altera��o da tratativa para que seja atualizado o valor do IR que n�o pode ser
				// enviado pelo ExecAuto - [Chamado-7155]
				//================================================================================
				If Len(_aParc) == _nI .And. ZZ2->ZZ2_IRRF > 0.00
				   DbSelectArea("SE2")
				   DbSetOrder (1)//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				   DbSeek( xFilial("SE2") + "AUT" + _cRecibo + "  " )
				   Reclock ("SE2", .F.)
						SE2->E2_VALOR	:= ZZ2->ZZ2_TOTAL - ZZ2->ZZ2_SEST - ZZ2->ZZ2_INSS - ZZ2->ZZ2_IRRF - ZZ2->ZZ2_PAMVLR
						SE2->E2_SALDO	:= ZZ2->ZZ2_TOTAL - ZZ2->ZZ2_SEST - ZZ2->ZZ2_INSS - ZZ2->ZZ2_IRRF - ZZ2->ZZ2_PAMVLR
						SE2->E2_VLCRUZ	:= ZZ2->ZZ2_TOTAL - ZZ2->ZZ2_SEST - ZZ2->ZZ2_INSS - ZZ2->ZZ2_IRRF - ZZ2->ZZ2_PAMVLR
						SE2->E2_IRRF	:= ZZ2->ZZ2_IRRF
				   MsUnlock() 
				EndIf
			Next _nI
		 Else
			xmaghelpfis(	"Aten��o!"																																		,;
							"Nao foi poss�vel realizar a inclus�o no financeiro do t�tulo referente ao RPA."																,;
							"Favor comunicar o departamento de inform�tica do problema ocorrido, dados do t�tulo: PREFIXO - AUT, TIPO - RPA, NUMERO - " + ZZ2->ZZ2_RECIBO	 )
			_lRet:= .F.
		 EndIf
	  EndIf
	  //================================================================================
	  //| Gera titulo TX p/ IRRF                                                       |
	  //================================================================================
	  If ZZ2->ZZ2_IRRF > 0
       If _cVctoIRRF == "V"
         _dVctoIRRF := CtoD( "20/"+ StrZero( Month( _aParc[Len(_aParc)][01] ) , 2 ) +"/"+ StrZero( Year(_aParc[Len(_aParc)][01]) , 4 ) )
       Else
         _dVctoIRRF := MonthSum( CtoD( "20/"+ StrZero( Month(dDatabase) , 2 ) +"/"+ Strzero( Year(dDatabase) , 4 ) ) , 1 )
       EndIf
		 
       DBSelectArea("SA2")
		 SA2->( DBSetOrder(1) ) // A2_FILIAL+A2_AUTONOM
		 SA2->( DBSeek( xFilial("SA2") + _cFornIRRF ) )
		 _cChave := "AUT" + _cRecibo + IIF( len(_aParc) > 1 , StrZero( Len(_aParc) , 2 ) , "  " ) + "RPA" + _cCodFor + _cLojaFor
 		 
 		 DbSelectArea("SE2")
		 SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		 If !SE2->( DBSeek( xFilial("SE2") + "AUT" + ZZ2->ZZ2_RECIBO + _cParcela + "TX " + SubStr(_cFornIRRF,1,6) ) )
			lMsErroAuto	:= .F.
			aVetor		:= {	{ "E2_PREFIXO"	, "AUT"						, Nil },;
								{ "E2_NUM"		, _cRecibo					, Nil },;			
								{ "E2_PARCELA"	, _cParcela					, Nil },;
								{ "E2_TIPO"		, "TX "						, Nil },;
								{ "E2_NATUREZ"	, _cNatIRRF					, Nil },;
								{ "E2_FORNECE"	, substr(_cFornIRRF,1,6)	, Nil },;
								{ "E2_LOJA"		, "00  "					, Nil },;
								{ "E2_EMISSAO"	, dDataBase					, Nil },;
								{ "E2_VENCTO"	, _dVctoIRRF				, Nil },;
								{ "E2_VENCREA"	, DataValida(_dVctoIRRF)	, Nil },;
								{ "E2_VALOR"	, ZZ2->ZZ2_IRRF				, Nil },;
								{ "E2_TITPAI"	, _cChave					, Nil },;
								{ "E2_ORIGEM"	, "AOMS042"					, Nil } }
   			//================================================================================
			//| Altera o modulo para Financeiro, senao o SigaAuto nao executa.               |
			//================================================================================
			nModulo := 6
			cModulo := "FIN" 
			
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,3)
			
			If lMsErroAuto
				Mostraerro()
				_lRet:= .F.
			Endif
			
			//================================================================================
			//| Restaura o modulo em uso.                                                    |
			//================================================================================
			nModulo := nModAnt
			cModulo := cModAnt
		 EndIf
	  EndIf
      //================================================================================
      //| Nao encontrado registro na tabela ZZ2                                        |
      //================================================================================
   Else
	  xmaghelpfis(	"Aten��o!"																,;
		            "Nao foi encontrado o registro da inser��o do RPA na tabela ZZ2."		,;
                    "Favor comunicar o departamento de inform�tica do problema ocorrido."	 )
	  _lRet := .F.
   EndIf

End Sequence

RestArea(_aArea)

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ExcluiSE2
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Rotina para gerar a exclusao dos dados do RPA no financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ExcluiSE2()

Local _lRet			:= .T.
Local nModAnt		:= nModulo
Local cModAnt		:= cModulo

Private lMsErroAuto	:= .F.

Begin Sequence
   //================================================================================
   //| Posicionando no t�tulo                                                       |
   //================================================================================
   DbSelectArea("SE2")
   SE2->( DBOrderNickName("IT_RPA") ) //E2_FILIAL+E2_PREFIXO+E2_TIPO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA
   If SE2->( DBSeek( xFilial("SE2") + "AUT" + "RPA" + M->ZZA_RPA ) )
	  While SE2->( !EOF() ) .And. SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM ) == xFilial("SE2") + "AUT" + M->ZZA_RPA .And. AllTrim(SE2->E2_ORIGEM) == "AOMS042"
	
		 If SE2->E2_TIPO == "RPA"
		
			lMsErroAuto := .F.
			
			DBSelectArea("SA2")
			SA2->( DBSetOrder(1) )
			SA2->( DBSeek( xFilial("SA2") + SE2->( E2_FORNECE + E2_LOJA ) ) )
			
			aVetor := {	{ "E2_PREFIXO"	, SE2->E2_PREFIXO	, Nil },;
						{ "E2_NUM"		, SE2->E2_NUM		, Nil },;
						{ "E2_PARCELA"	, SE2->E2_PARCELA	, Nil },;
						{ "E2_TIPO"		, SE2->E2_TIPO		, Nil },;
						{ "E2_NATUREZ"	, SE2->E2_NATUREZ	, Nil },;
						{ "E2_ORIGEM"	, "AOMS042"      	, Nil } }
			
			//================================================================================
			//| Altera o modulo para Financeiro, senao o SigaAuto nao executa.               |
			//================================================================================
			nModulo := 6
			cModulo := "FIN"
			
			MSExecAuto( {|x,y,z| Fina050(x,y,z)} , aVetor ,, 5 ) //Exclusao
			
			If lMsErroAuto
				Mostraerro()
				_lRet:= .F.
				Exit
			Endif
			
			//================================================================================
			//| Restaura o modulo em uso.                                                    |
			//================================================================================
			nModulo := nModAnt
			cModulo := cModAnt
		 EndIf
	     
	     SE2->( DBSkip() )
	  EndDo
   Else
	  xmaghelpfis(	"ERRO"																									,;
					"N�o foi(ram) encontrado(s) t�tulo(s) no financeiro referente ao RPA: " + M->ZZA_RPA					,;
					"Diante disso n�o ser� poss�vel realizar a exclus�o, favor contactar o departamento de inform�tica."	 )
	
	  _lRet := .F.
   EndIf

End Sequence

Return( _lRet )

/*
===============================================================================================================================
Programa----------: RetCodRPA
Autor-------------: Fabiano Dias
Data da Criacao---: 22/12/2010
===============================================================================================================================
Descri��o---------: Funcao utilizada para retornar o codigo do RPA.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RetCodRPA()

Local _cQuery   := ""
Local _cAliasZZA:= GetNextAlias()  
Local _cCodRPA  := ""

Begin Sequence     
   _cQuery := " SELECT "
   _cQuery += " COALESCE( MAX( ZZA_CODRPA ) , '0' ) CODIGO "
   _cQuery += " FROM " + RetSqlName("ZZA") + " "
   _cQuery += " WHERE" 
   _cQuery += " 		D_E_L_E_T_	= ' '
   _cQuery += " AND	ZZA_FILIAL	= '" + xFilial("ZZA") + "' "

   If Select(_cAliasZZA) > 0
	  (_cAliasZZA)->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasZZA , .T. , .F. )

   DBSelectArea(_cAliasZZA)
   (_cAliasZZA)->( DBGotop() )

   If AllTrim( (_cAliasZZA)->CODIGO ) == '0'
	  _cCodRPA := '000001'
   Else  
	  _cCodRPA := StrZero( Val( Soma1( (_cAliasZZA)->CODIGO) ) , 6 )
   EndIf

   While !MayIUseCode( "ZZA_CODRPA"+ xFilial("ZZA") + _cCodRPA )	//verifica se esta na memoria, sendo usado
	  _cCodRPA := StrZero( Val( Soma1(_cCodRPA) ) , 6 )			// busca o proximo numero disponivel
   EndDo

   (_cAliasZZA)->( DBCloseArea() )

End Sequence

Return( _cCodRPA )

/*
===============================================================================================================================
Programa----------: calcImpRPA
Autor-------------: Tiago Correa Castro
Data da Criacao---: 25/01/2009
===============================================================================================================================
Descri��o---------: Chamada da fun��o de C�lculo dos Impostos do RPA
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function calcImpRPA()
Local _cCampo	:= UPPER(ALLTRIM(ReadVar()))
Local _aResAux	:= {}
Local _aDadImp	:= {	M->ZZA_CODAUT	,; //01 -- C�digo do Aut�nomo
						(M->ZZA_VLRBRT-M->ZZA_VRPEDA),; //02 -- Valor Bruto
						M->ZZA_CONPAG	,; //03 -- Condi��o de Pagamento
						M->ZZA_TPFORN	,; //04 -- Tipo de Fornecedor
						1				 } //05 -- Identificador de chamada
Local _lRet := .T.

Begin Sequence
   If "ZZA_VRPEDA" $ _cCampo .OR. "ZZA_VLRBRT" $ _cCampo
      IF M->ZZA_VLRBRT < M->ZZA_VRPEDA
	     Aviso( 'Aten��o!' , 'O valor bruto deve ser maior/igual que o valor de Ped�gio!' , {'Voltar'} )
         _lRet := .F.
         Break
      EndIf
   EndIf

   LjMsgRun( 'Verificando c�lculo dos impostos...' , 'Aguarde!' , {|| CursorWait() , _aResAux := U_ITCALIMP( _aDadImp ) , CursorArrow() } )

   If !Empty( _aResAux )
	  M->ZZA_SEST		:= _aResAux[01]
	  M->ZZA_INSS		:= _aResAux[02]
	  M->ZZA_IRRF		:= _aResAux[03]
	  If ValType(_aResAux[04]) = "N"
	     M->ZZA_VLRLIQ:= (_aResAux[04]+M->ZZA_VRPEDA)
	  EndIf
	  //================================================================================
	  //| Funcao que gera as parcelas de acordo com descontos e condi��o de pagamento  |
	  //================================================================================
	  AOMS042PAR()
   EndIf

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: vldExcRPA
Autor-------------: Fabiano Dias
Data da Criacao---: 05/11/2010
===============================================================================================================================
Descri��o---------: Funcao utilizada para validar a exclusao de um RPA.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function vldExcRPA()

Local _aInfHlp	:= {}
Local _aRegSF2	:= {}
Local _aRegPos	:= {}
Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()
Local _lRet		:= .T.
Local _nI		:= 0

Begin Sequence
   DBSelectArea("ZZ2")		// Posicionando no cabecalho do recibo
   ZZ2->( DBSetORder(1) )	// ZZ2_FILIAL+ZZ2_RECIBO
   If ZZ2->( DBSeek( xFilial("ZZ2") + M->ZZA_RPA ) )
	  cReg := alltrim( str( ZZ2->(Recno()) ) )
   EndIf

   _cCodAut	:= ZZ2->ZZ2_AUTONO
   _cNumRPA	:= ZZ2->ZZ2_RECIBO
   _cRegZZ2	:= cValToChar( ZZ2->( Recno() ) )
   _cRegSE2	:= U_ITSE2REG()
   _cDtRef		:= SubStr( DtoS( ZZ2->ZZ2_DATA ) , 1 , 6 )

   If ZZ2->ZZ2_INSS > 0 .Or. ZZ2->ZZ2_IRRF > 0
	  //================================================================================
	  //| Verifica caso o RPA atual tenha imposto se existem registros posteriores     |
	  //================================================================================
	  _cQuery += " SELECT DISTINCT ZZ2.R_E_C_N_O_ AS REGZZ2 "
	  _cQuery += " FROM "+ RetSqlName('ZZ2') +" ZZ2 "
	  _cQuery += " INNER JOIN "+ RetSqlName('SE2') +" SE2 ON "
	  _cQuery += " 		SE2.E2_FILIAL				= ZZ2.ZZ2_FILIAL "
	  _cQuery += " AND	SE2.E2_NUM					= ZZ2.ZZ2_RECIBO "
	  _cQuery += " AND	SE2.E2_NUM					<> '"+ _cNumRPA	+"' "
	  _cQuery += " AND	SE2.E2_PREFIXO				= 'AUT' "
	  _cQuery += " AND	SE2.E2_ORIGEM				IN ( 'AOMS042' , 'MGLT011' , 'GERAZZ3' ) "
	  _cQuery += " AND	SE2.R_E_C_N_O_				> '"+ _cRegSE2	+"' "
	  _cQuery += " AND	SUBSTR(SE2.E2_EMISSAO,1,6)	= '"+ _cDtRef	+"' "
	  _cQuery += " AND	SE2.D_E_L_E_T_				= ' ' "
	  _cQuery += " WHERE "
	  _cQuery += " 		ZZ2.ZZ2_AUTONO				= '"+ _cCodAut	+"' "
	  _cQuery += " AND	ZZ2.D_E_L_E_T_				= ' ' "
   Else
      //================================================================================
	  //| Verifica RPA com impostos no mesmo per�odo ap�s o atual sem impostos         |
	  //================================================================================
	  _cQuery += " SELECT DISTINCT ZZ2.R_E_C_N_O_ AS REGZZ2 "
	  _cQuery += " FROM "+ RetSqlName('ZZ2') +" ZZ2 "
	  _cQuery += " INNER JOIN "+ RetSqlName('SE2') +" SE2 ON "
	  _cQuery += " 		SE2.E2_FILIAL				= ZZ2.ZZ2_FILIAL "
	  _cQuery += " AND	SE2.E2_NUM					= ZZ2.ZZ2_RECIBO "
	  _cQuery += " AND	SE2.E2_NUM					<> '"+ _cNumRPA	+"' "
	  _cQuery += " AND	SE2.E2_PREFIXO				= 'AUT' "
	  _cQuery += " AND	SE2.E2_ORIGEM				IN ( 'AOMS042' , 'MGLT011' , 'GERAZZ3' ) "
	  _cQuery += " AND	SE2.R_E_C_N_O_				> '"+ _cRegSE2	+"' "
	  _cQuery += " AND	SUBSTR(SE2.E2_EMISSAO,1,6)	= '"+ _cDtRef	+"' "
	  _cQuery += " AND	SE2.D_E_L_E_T_				= ' ' "
	  _cQuery += " WHERE "
	  _cQuery += " 		ZZ2.ZZ2_AUTONO				= '"+ _cCodAut	+"' "
	  _cQuery += " AND (	ZZ2.ZZ2_INSS				> 0 "
	  _cQuery += "     OR	ZZ2.ZZ2_IRRF				> 0 ) "
	  _cQuery += " AND	ZZ2.D_E_L_E_T_				= ' ' "
   EndIf

   If Select(_cAlias) > 0
	  (_cAlias)->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

   DBSelectArea(_cAlias)
   (_cAlias)->( DBGoTop() )
   While (_cAlias)->( !Eof() )
	  DBSelectArea('ZZ2')
	  ZZ2->( DBGoTo( (_cAlias)->REGZZ2 ) )
	
	  _aRegSF2 := {}
	
	  If !Empty( ZZ2->ZZ2_CARGA )
		 _aRegSF2 := AOMS042SF2()
	  EndIf
	
	  If !Empty( _aRegSF2 )
		 For _nI := 1 To Len( _aRegSF2 )
			 DBSelectArea('SF2')
		 	 SF2->( DBGoTo( _aRegSF2[_nI] ) )
			
			 aAdd( _aRegPos , {	'Carga'							,; //Tipo
								SF2->F2_FILIAL					,; //Filial
								SF2->F2_CARGA					,; //N�mero da Carga
								SF2->F2_DOC +'/'+ SF2->F2_SERIE	,; //N�mero do RPA/Nota
								SF2->F2_EMISSAO					,; //Data de Emiss�o
								SF2->F2_VALBRUT					,; //Valor Total
								_aRegSF2[_nI]					}) //Recno
		 Next _nI
	  Else
		 aAdd( _aRegPos , {	'RPA Avulso'		,; //Tipo
							ZZ2->ZZ2_FILIAL		,; //Filial
							''					,; //N�mero da Carga
							ZZ2->ZZ2_RECIBO		,; //N�mero do RPA/Nota
							ZZ2->ZZ2_DATA		,; //Data de Emiss�o
							ZZ2->ZZ2_TOTAL		,; //Valor Total
							ZZ2->( Recno() )	}) //Recno
	  EndIf
      
      (_cAlias)->( DBSkip() )
   EndDo

   (_cAlias)->( DBCloseArea() )

   If !Empty( _aRegPos )
	  _lRet		:= .F.
	  _aRegPos	:= AOMS042ORD( _aRegPos )
	
	  //                  |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|
	  aAdd( _aInfHlp	, { "N�o � permitido estornar RPA's que foram"	, "considerados nos c�lculos de impostos e ", "que possuem movimenta��o posterior."		} )
	  aAdd( _aInfHlp	, { "Verifique os dados do RPA a estornar!"		, ""										, ""										} )
	
	  //===========================================================================
	  //| Cadastra o Help e Exibe                                                 |
	  //===========================================================================
	  U_ITCADHLP( _aInfHlp , "AOMS421" )
	
	  //===========================================================================
	  //| Exibe a lista de registros posteriores para confer�ncia                 |
	  //===========================================================================
	  _aCabec		:= { 'Tipo' , 'Filial' , 'Carga' , 'Documento' , 'Emiss�o' , 'Valor Total' }
	  _cMsgAux	:= '['+ StrZero( Len( _aRegPos ) , 3 ) +'] lan�amentos posteriores.
	  U_ITListBox( 'Lan�amentos posteriores encontrados:' , _aCabec , _aRegPos , .T. , 1 , _cMsgAux )
   EndIf

End Sequence

Return( _lRet )

/*
===============================================================================================================================
Programa----------: vldIncRPA
Autor-------------: Fabiano Dias
Data da Criacao---: 05/11/2010
===============================================================================================================================
Descri��o---------: Funcao para informar se ja foi lan�ado um RPA para o autonomo corrente com um tipo de fornecedor diferente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function vldIncRPA()

Local _cQuery  := ""
Local _cAlias  := GetNextAlias()  
Local nCountRec:= 0     
Local _lRet    := .T. 
Local _cTipForn:= IIF(M->ZZA_TPFORN == "F","Fretista","Outros")

Begin Sequence
   _cQuery := "SELECT"  
   _cQuery += " ZZA_CODRPA "
   _cQuery += "FROM " + RetSqlName("ZZA") + " ZZA "  
   _cQuery += "WHERE"  
   _cQuery += " ZZA.D_E_L_E_T_= ' '"
   _cQuery += " AND ZZA.ZZA_FILIAL = '"  + xFilial("ZZA") + "'"
   _cQuery += " AND ZZA.ZZA_CODAUT = '"  + M->ZZA_CODAUT  + "'" 
   _cQuery += " AND ZZA.ZZA_TPFORN <> '" + M->ZZA_TPFORN  + "'"          
   _cQuery += " AND SUBSTR(ZZA.ZZA_DTEMIS,1,6) = '" + SubStr(DtoS(M->ZZA_DTEMIS),1,6) + "'"		                                                   
	
   dbUseArea( .T., "TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
   COUNT TO nCountRec //Contabiliza o numero de registros encontrados pela query   
	
   If nCountRec > 0        
      xmaghelpfis("INFORMA��O","J� existe lan�amento(s) de RPA para o Autonomo: " + M->ZZA_CODAUT +;
		          " com o tipo do fornecedor diferente de: " + _cTipForn +; 
				  " dentro do mesmo m�s do RPA: " + M->ZZA_CODRPA + " a de se ressaltar que a forma de c�lculo � diferenciada de acordo com o tipo do Fornecedor.",;
		          "Favor verificar se o tipo do fornecedor foi fornecido corretamente.")   
		                    
      If MsgYesNo("Deseja alterar o tipo do Fornecedor ?","ATENCAO")
		 _lRet    := .F.
	  EndIf		                    
   EndIf    
	
   dbSelectArea(_cAlias) 
   dbCloseArea()

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: vldAuton
Autor-------------: Fabiano Dias
Data da Criacao---: 10/03/2011
===============================================================================================================================
Descri��o---------: Validacao para constatar se o autonomo indicado na geracao do RPA nao se encontra com a situacao demitido
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function vldAuton(_cCodAuton)
                   
Local _cAlias := GetNextAlias()
Local _cFiltro:= "%"  
Local _lRet   := .T.   

Begin Sequence
   _cFiltro += " AND RA_MAT = '" + _cCodAuton + "'" 
   _cFiltro += "%"

   BeginSql alias _cAlias
	  SELECT
	      RA_MAT
	  FROM
	      %table:SRA%
	  WHERE
	      D_E_L_E_T_ = ' '
	      AND RA_FILIAL = '01'
	      AND RA_SITFOLH = 'D'
	      %exp:_cFiltro%
   EndSql         

   dbSelectArea(_cAlias)
   (_cAlias)->(dbGotop())

   If (_cAlias)->(!Eof()) 

	  _lRet:= .F. 
	
	  xmaghelpfis("INFORMA��O",;
				  "O Autonomo: " + _cCodAuton + " encontra-se com a situa��o demitido em seu cadastro de autonomo.",;	
	              "Favor verificar se o c�digo do autonomo foi fornecido corretamente, ou cheque junto ao departamento pessoal a situa��o do autonomo.")   
   EndIf     

   dbSelectArea(_cAlias)
   (_cAlias)->(dbCloseArea())

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS042SF2
Autor-------------: Alexandre Villar
Data da Criacao---: 06/08/2014
===============================================================================================================================
Descri��o---------: Recupera os c�digos da SF2 de acordo com a ZZ2 posicionada caso seja montagem de Carga
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS042SF2()

Local _aRet		:= {}
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

Begin Sequence
   If !Empty( ZZ2->ZZ2_CARGA )
	  _cQuery := " SELECT SF2.R_E_C_N_O_ AS REGSF2 "
	  _cQuery += " FROM "+ RetSqlName('SF2') +" SF2 "
	  _cQuery += " WHERE "
	  _cQuery += " 		SF2.F2_FILIAL	= '"+ ZZ2->ZZ2_FILIAL	+"' "
	  _cQuery += " AND	SF2.F2_CARGA	= '"+ ZZ2->ZZ2_CARGA	+"' "
	  _cQuery += " AND	SF2.D_E_L_E_T_	= ' ' "
	
	  If Select(_cAlias) > 0
		 (_cAlias)->( DBCloseArea() )
	  EndIf
	
	  DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
	
	  DBSelectArea(_cAlias)
	  (_cAlias)->( DBGoTop() )
	
	  While (_cAlias)->( !Eof() )
		
		 aAdd( _aRet , (_cAlias)->REGSF2 )
		
	     (_cAlias)->( DBSkip() )
	  EndDo
	
   EndIf

End Sequence

Return( _aRet )

/*
===============================================================================================================================
Programa----------: AOMS042ORD
Autor-------------: Alexandre Villar
Data da Criacao---: 07/08/2014
===============================================================================================================================
Descri��o---------: Ordena os registros de acordo com o Recno da SE2 gerados para o RPA
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS042ORD( _aRegPos )

Local _aArea	:= GetArea()
Local _aAux		:= {}
Local _aRet		:= {}
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ''

Local _nI		:= 0

Begin Sequence
   For _nI := 1 To Len( _aRegPos )
	   _cQuery := " SELECT MAX(SE2.R_E_C_N_O_) AS REGSE2 "
	   _cQuery += " FROM "+ RetSqlName('SE2') +" SE2 "
	   _cQuery += " WHERE "
	
	   If Empty( _aRegPos[_nI][03] )
		
		  DBSelectArea('ZZ2')
		  ZZ2->( DBGoTo( _aRegPos[_nI][07] ) )
		
	   Else
		
		  DBSelectArea('SF2')
		  SF2->( DBGoTo( _aRegPos[_nI][07] ) )
		
		  DBSelectArea('ZZ2')
		  ZZ2->( DBSetOrder(2) )
		  If !ZZ2->( DBSeek( SF2->( F2_FILIAL + F2_CARGA ) ) )
			 Loop
		  EndIf
		
	   EndIf
	
	   _cQuery += " 		SE2.E2_FILIAL				= '"+ ZZ2->ZZ2_FILIAL +"' "
	   _cQuery += " AND	SE2.E2_NUM					= '"+ ZZ2->ZZ2_RECIBO +"' "
	   _cQuery += " AND	SE2.E2_PREFIXO				= 'AUT' "
	   _cQuery += " AND	SE2.E2_ORIGEM				IN ( 'AOMS042' , 'MGLT011' , 'GERAZZ3' ) "
	   _cQuery += " AND	SUBSTR(SE2.E2_EMISSAO,1,6)	= '"+ SubStr( DtoS(ZZ2->ZZ2_DATA) , 1 , 6 ) +"' "
	   _cQuery += " AND	SE2.D_E_L_E_T_				= ' ' "
	
	   If Select(_cAlias) > 0
		  (_cAlias)->( DBCloseArea() )
	   EndIf
	
	   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
	
	   DBSelectArea(_cAlias)
	   (_cAlias)->( DBGoTop() )
	   If (_cAlias)->(!Eof())
		
		  aAdd( _aAux , {	(_cAlias)->REGSE2	,;
						    _aRegPos[_nI][01]	,;
						    _aRegPos[_nI][02]	,;
					     	_aRegPos[_nI][03]	,;
					    	_aRegPos[_nI][04]	,;
			    			_aRegPos[_nI][05]	,;
		    				_aRegPos[_nI][06]	})
		
	   EndIf
   Next _nI

   If !Empty(_aAux)

	  _aAux := aSort( _aAux ,,, {|x, y| x[1] < y[1] } )
	
	  For _nI := 1 To Len(_aAux)
		
		  aAdd( _aRet , {	_aAux[_nI][02]	,;
			    			_aAux[_nI][03]	,;
				    		_aAux[_nI][04]	,;
					    	_aAux[_nI][05]	,;
				    		_aAux[_nI][06]	,;
				    		_aAux[_nI][07]	})
	  Next _nI
	
   EndIf

End Sequence

RestArea( _aArea )

Return( _aRet )
