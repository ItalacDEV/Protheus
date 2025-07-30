/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  | 19/06/2024 | Chamado 47127. Ajuste para n�o gravar o campo A1_MSBLQL.
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
===============================================================================================================================
*/

#Include "Protheus.Ch"
#Include "FWMVCDef.Ch"

#Define		TITULO	"Avalia��o de Clientes com Bloqueio de Desconto de Contrato"

/*
===============================================================================================================================
Programa----------: AOMS130
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Rotina de An�lise do Cadastro de Clientes Bloqueados por Desconto Contratual. Chamado 30177.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS130()

Local _aInfHelp	:= {}

//===========================================================================
//| Define formato de data para exibi��o nas telas da rotina                |
//===========================================================================
SET DATE FORMAT TO "DD/MM/YYYY"

//===========================================================================
//| Verifica o acesso do usu�rio atual                                      |
//===========================================================================
If U_ITVLDUSR(3)

	Processa( {|| AOMS130INI() } , "Processando..." , "Iniciando o processamento..." )
	
Else

	aAdd( _aInfHelp	, { "Usu�rio sem acesso � rotina de Bloqueio"	, " de Clientes Inativos."	, ""	} )
	aAdd( _aInfHelp	, { "Verifique com a �rea de TI/ERP."			, ""						, ""	} )
	
	U_ITCADHLP( _aInfHelp , "OMS130" )
	lRet := .F.

EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS130INI
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Rotina de montagem da tela de processamento
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS130INI()

Local _aCpos		:= AOMS130CPS()
Local _aFields		:= {}
Local _cQuery		:= ""
Local _cAliasQry	:= GetNextAlias()

Private _oMarkBRW	:= Nil
Private cAliasAux	:= GetNextAlias()
Private _nTotReg	:= 0
Private cDtIni		:= ""
Private _aRegMrk	:= {}

Begin Sequence 

   _cQuery := " SELECT "
   _cQuery += "     SA1.A1_COD				AS CLIENTE,"   
   _cQuery += "     SA1.A1_LOJA			    AS LOJA   ,"
   _cQuery += "     SA1.A1_NOME		    	AS NOME   ,"
   _cQuery += "     SA1.A1_GRPVEN			AS REDE   ,"
   _cQuery += "	    SA1.A1_CGC				AS CGC    ,"
   _cQuery += "	    SA1.A1_I_DTCAD			AS DAT_CAD,"
   _cQuery += "     SA1.A1_PESSOA			AS TIP_PES,"
   _cQuery += "     SA1.A1_I_BLQDC          AS BLOQDESC,"
   _cQuery += "     SA1.A1_MSBLQL           AS BLOQUI,"
   _cQuery += "	    SA1.R_E_C_N_O_			AS REGSA1 "
   _cQuery += " FROM  "+ RetSqlName("SA1") +" SA1 "
   _cQuery += " WHERE "
   _cQuery += "     SA1.D_E_L_E_T_  = ' ' AND A1_I_BLQDC = '1' "

   _cQuery += " ORDER BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_GRPVEN, SA1.A1_CGC "

   If Select(_cAliasQry) > 0
	  (_cAliasQry)->( DBCloseArea() )
   EndIf

   ProcRegua(0)
   IncProc( "Lendo registros..." )
   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasQry , .T. , .F. )

   DBSelectArea(_cAliasQry)
   (_cAliasQry)->( DBGoTop() )
   COUNT TO _nTotReg

   If _nTotReg <= 0
	  (_cAliasQry)->( DBCloseArea() )
	  U_Itmsg(  "N�o foram encontrados Clientes bloqueados por desconto contratual!" ,"Aten��o!" ,,1 )
	  Break
   EndIf

   If Select(cAliasAux) > 0
	  (cAliasAux)->(Dbclosearea())
   EndIf

   _otemp := FWTemporaryTable():New( cAliasAux, _aCpos )
   
   _otemp:AddIndex( "01", {"CLIENTE","LOJA"} )
   _otemp:AddIndex( "02", {"NOME"} )

   _otemp:Create()

   DBSelectArea( cAliasAux )
   ProcRegua(_nTotReg)

   (_cAliasQry)->( DBGoTop() )
   Do While (_cAliasQry)->( !Eof() )

      (cAliasAux)->( RecLock( cAliasAux , .T. ) )
      (cAliasAux)->CLIENTE	 := (_cAliasQry)->CLIENTE
      (cAliasAux)->LOJA		 := (_cAliasQry)->LOJA
      (cAliasAux)->NOME 	 := Upper( AllTrim( (_cAliasQry)->NOME ) )
      (cAliasAux)->REDE		 := Capital( AllTrim( Posicione( "ACY" , 1 , xFilial("ACY") + (_cAliasQry)->REDE , "ACY_DESCRI" ) ) )
      (cAliasAux)->CODREDE  := (_cAliasQry)->REDE
      (cAliasAux)->CGC		 := AOMS130CGC( (_cAliasQry)->CGC )
      (cAliasAux)->DAT_CAD	 := StoD( (_cAliasQry)->DAT_CAD )
      (cAliasAux)->REGSA1	 := (_cAliasQry)->REGSA1
      (cAliasAux)->BLOQDESC := (_cAliasQry)->BLOQDESC
      (cAliasAux)->BLOQUI   := (_cAliasQry)->BLOQUI
      (cAliasAux)->( MSUnLock() )
		
      (_cAliasQry)->( DBSkip() )
		
   EndDo

   (_cAliasQry)->( DBCloseArea() )

   aAdd( _aFields , { "Cliente"			         , {|| (cAliasAux)->CLIENTE }  		                     , "C" , "@!" , 0 , TamSX3("A1_COD")[01]		, 0 } )
   aAdd( _aFields , { "Loja"				         , {|| (cAliasAux)->LOJA }			                        , "C" , "@!" , 0 , TamSX3("A1_LOJA")[01]	, 0 } )
   aAdd( _aFields , { "Nome"				         , {|| (cAliasAux)->NOME }			                        , "C" , "@!" , 0 , TamSX3("A1_NOME")[01]-20	, 0 } )
   aAdd( _aFields , { "Rede"			            , {|| (cAliasAux)->CODREDE }			                     , "C" , "@!" , 0 , TamSX3("ACY_DESCRI")[01]	, 0 } )
   aAdd( _aFields , { "Nome Rede"		         , {|| (cAliasAux)->REDE }			                        , "C" , "@!" , 0 , TamSX3("ACY_DESCRI")[01]	, 0 } )
   aAdd( _aFields , { "CPF/CNPJ"			         , {|| (cAliasAux)->CGC }  			                        , "C" , "@!" , 0 , TamSX3("A1_CGC")[01]		, 0 } )
   aAdd( _aFields , { "Dt. Cadastro"		      , {|| DtoC((cAliasAux)->DAT_CAD) }	                     , "C" , "@!" , 0 , 10						, 0 } )
   aAdd( _aFields , { "Cliente Bloquedo"	      , {|| If((cAliasAux)->BLOQUI=="1"  ,"Sim","N�o") }       , "C" , "@!" , 0 , 10	, 0 } )
   aAdd( _aFields , { "Bloqueio Desc.Contratual", {|| If((cAliasAux)->BLOQDESC=="1","Sim","N�o") }       , "C" , "@!" , 0 , 10	, 0 } )

   _oMarkBRW := FWMarkBrowse():New()		   												// Inicializa o Browse

   _oMarkBRW:SetAlias( cAliasAux )			   												// Define Alias que ser� a Base do Browse
   _oMarkBRW:SetDescription( "Avalia��o de Clientes com Bloqueio de Desconto de Contrato" )	// Define o titulo do browse de marcacao
   //_oMarkBRW:SetFieldMark( "MARCA" )														// Define o campo que sera utilizado para a marca��o
   _oMarkBRW:SetMenuDef( 'AOMS130' )														// For�a a utiliza��o do menu da rotina atual
   //_oMarkBRW:SetAllMark( {|| _oMarkBRW:AllMark() , AOMS130MRK(.T.) } )						// A��o do Clique no Header da Coluna de Marca��o
   //_oMarkBRW:SetAfterMark( {|| AOMS130MRK(.F.) } )											// A��o na marca��o/desmarca��o do registro
   _oMarkBRW:SetFields( _aFields )													 		// Campos para exibi��o
   _oMarkBRW:AddButton( "Avaliar" , {|| Processa( {|| U_AOMS130V() } , "Avaliando Cliente Bloqueado..." , "Aguarde!" ) } ,, 4 )
   
   _oMarkBRW:AddLegend({|| (cAliasAux)->BLOQDESC == "1"}, "BR_VERMELHO", "Bloqueado por Desconto Contratual")
   _oMarkBRW:AddLegend({|| (cAliasAux)->BLOQDESC <> "1"}, "BR_VERDE"   , "Desbloqueado")

   _oMarkBRW:DisableConfig()

   _oMarkBRW:Activate()																		// Ativacao da classe

End Sequence 

If Select(cAliasAux) > 0
   (cAliasAux)->(Dbclosearea())
EndIf

Return Nil 

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Rotina de constru��o do menu
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina Title 'Pesquisar'  Action 'U_AOMS130S()'   OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Visualizar' Action 'U_AOMS130R( (cAliasAux)->REGSA1 )' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Legenda'    Action 'U_AOMS130LEG()' OPERATION 2 ACCESS 0

Return( aRotina )

/*
===============================================================================================================================
Programa----------: AOMS130CNS
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Rotina de consulta do cadastro completo do Cliente
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS130R( nRegSA1 )

Private cCadastro := "Cadastro do Cliente"

DBSelectArea("SA1")
SA1->( DBGoTo(nRegSA1) )
AxVisual( "SA1" , nRegSA1 , 2 )

Return()

/*
===============================================================================================================================
Programa----------: AOMS130CPS
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Define a cria��o de campos para exibi��o da an�lise
Parametros--------: Nenhum
Retorno-----------: aRet - Campos que ser�o criados e exibidos na tela
===============================================================================================================================
*/
Static Function AOMS130CPS( _nTotReg )

Local _aCpos := {}

aAdd( _aCpos , { "MARCA"		, "C" , 1							   , 0 } )
AAdd( _aCpos , { "CLIENTE"		, "C" , TamSX3("A1_COD")[01]		, 0 } )
AAdd( _aCpos , { "LOJA"			, "C" , TamSX3("A1_LOJA")[01]		, 0 } )
AAdd( _aCpos , { "NOME"			, "C" , TamSX3("A1_NOME")[01]		, 0 } )
AAdd( _aCpos , { "REDE"			, "C" , TamSX3("ACY_DESCRI")[01]	, 0 } )
AAdd( _aCpos , { "CODREDE"		, "C" , TamSX3("A1_GRPVEN")[01]	, 0 } )
AAdd( _aCpos , { "CGC"			, "C" , 18							   , 0 } )
AAdd( _aCpos , { "DAT_CAD"		, "D" , 8						    	, 0 } )
AAdd( _aCpos , { "REGSA1"		, "N" , 9							   , 0 } )
AAdd( _aCpos , { "BLOQDESC"	    , "C" , 1							, 0 } )
AAdd( _aCpos , { "BLOQUI"	    , "C" , 1						    	, 0 } )
//AAdd( _aCpos , { "ULT_FAT"		, "D" , 8							, 0 } )
//AAdd( _aCpos , { "DT_REAV"		, "D" , 8							, 0 } )	// Data da Reavalia��o

Return( _aCpos )

/*
===============================================================================================================================
Programa----------: AOMS130CGC
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Formata��o da M�scara para CPF/CNPJ
Parametros--------: Nenhum
Retorno-----------: aRet - Campos que ser�o criados e exibidos na tela
===============================================================================================================================
*/
Static Function AOMS130CGC( cCGCAux )

Local cRet	:= ""
Local cAux	:= AllTrim( cCGCAux )

IF Len( cAux ) > 11

	cAux := PadL( cAux , 14 , "0" )
	cRet := Transform( cAux , "@R! NN.NNN.NNN/NNNN-99" )
	
Else

	cAux := PadL( cAux , 11 , "0" )
	cRet := Transform( cAux , "@R 999.999.999-99" )
	
EndIF

Return( cRet )

/*
===============================================================================================================================
Programa----------: AOMS130MRK
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Rotina que controla a marca��o dos registros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS130MRK( _lSetAll )

Local _nPosAux := 0

If _lSetAll
	
	If _oMarkBRW:IsMark()
		
		_aRegMrk := {}
		
		(cAliasAux)->( DBGoTop() )
		While (cAliasAux)->( !Eof() )
		
			aAdd( _aRegMrk , { (cAliasAux)->REGSA1 } )
		
		(cAliasAux)->( DBSkip() )
		EndDo
		
		(cAliasAux)->( DBGoTop() )
		
	Else
		_aRegMrk := {}
	EndIf
	
Else
	
	If _oMarkBRW:IsMark()
		
		If aScan( _aRegMrk , {|x| x[1] == (cAliasAux)->REGSA1 } ) == 0
			aAdd( _aRegMrk , { (cAliasAux)->REGSA1 } )
		EndIf
		
	Else
		
		If ( _nPosAux := aScan( _aRegMrk , {|x| x[1] == (cAliasAux)->REGSA1 } ) ) <> 0
		
			aDel( _aRegMrk , _nPosAux )
			aSize( _aRegMrk , Len( _aRegMrk ) -1 )
			
		EndIf
		
	EndIf
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS130V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Rotina de Avalia��o do Cliente.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS130V( nRegSA1 )
Local _nRegAtu := (cAliasAux)->(Recno())
Local _cBloqDesc, _aBloqDesc := {"1=Sim","2=N�o"}
Local _oGrupo, _cGrupo := Space(6)
Local _cTitulo := "Avalia��o Cliente: " + (cAliasAux)->CLIENTE + "-" + (cAliasAux)->LOJA + "-" + (cAliasAux)->NOME 
Local _nOpca	:= 0

Private _oDscGrupo, _cDscGrupo

Begin Sequence 
      
   _cBloqDesc := (cAliasAux)->BLOQDESC //_aBloqDesc[1]
   _cGrupo    := (cAliasAux)->CODREDE 
   _cDscGrupo := (cAliasAux)->REDE 

   DEFINE MSDIALOG _oDlgP TITLE _cTitulo FROM 0,0 TO 259,697 PIXEL // 178,181 TO 259,697 PIXEL

      @ 010,005 Say "Bloq.Desc.Contratual" Size 100,009 OF _oDlgP PIXEL COLOR CLR_BLUE
      @ 010,060 ComboBox _cBloqDesc	Items _aBloqDesc Size 50,010 OF _oDlgP PIXEL

      @ 025,005 Say "Rede"	Size 100,009 OF _oDlgP PIXEL COLOR CLR_BLUE
	   @ 025,060 MsGet _oGrupo	Var _cGrupo	Size 50,009 F3 "ACY" VALID(U_AOMS130W(_cGrupo)) OF _oDlgP PIXEL COLOR CLR_BLACK Picture "@!"

      @ 040,005 Say "Nome Rede"	Size 100,009 OF _oDlgP PIXEL COLOR CLR_BLUE
	   @ 040,060 MsGet _oDscGrupo	Var _cDscGrupo	Size 90,009 OF _oDlgP PIXEL COLOR CLR_BLACK Picture "@!" WHEN .F.
	
	  DEFINE SBUTTON FROM 070,60 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlgP:End() ) OF _oDlgP
	  DEFINE SBUTTON FROM 070,120 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlgP:End() ) OF _oDlgP

   ACTIVATE MSDIALOG _oDlgP CENTERED

   If _nOpca == 1
      If ! U_ItMsg("Confirma a Atualiza��o do Cadastro de Clientes?", "Aten��o", "",2,2,2) 
         Break
      EndIf 
     
      (cAliasAux)->(RecLock(cAliasAux,.F.))
      (cAliasAux)->REDE		 := _cDscGrupo
      (cAliasAux)->CODREDE  := _cGrupo
      (cAliasAux)->BLOQUI   := _cBloqDesc  //If(_cBloqDesc == _aBloqDesc[1],"1","2") 
      (cAliasAux)->( MSUnLock() )

      SA1->(DbGoTo((cAliasAux)->REGSA1))

      SA1->(RecLock("SA1", .F.))
      SA1->A1_I_BLQDC := _cBloqDesc  //If(_cBloqDesc == _aBloqDesc[1],"1","2") //_cBloqDesc
      SA1->A1_GRPVEN  := _cGrupo
      SA1->A1_I_NGRPC := _cDscGrupo
      SA1->(MsUnLock())

      _oMarkBRW:Refresh()
   EndIf 

End Sequence 

(cAliasAux)->(DbGoTo(_nRegAtu))

Return()

/*
===============================================================================================================================
Programa----------: AOMS130W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/12/2021
Descri��o---------: Valida a digita��o da rede na tela de avalia��o de clientes.
Parametros--------: _cCodRede = C�digo da rede
Retorno-----------: _lRet = .T. = Valido
                            .F. = C�digo inexistente.
===============================================================================================================================
*/
User Function AOMS130W(_cCodRede)
Local _lRet := .T.

Begin Sequence 
   
   If ! ExistCpo("ACY",_cCodRede)
      _lRet := .F.
   Else 
      _cDscGrupo := Posicione( "ACY" , 1 , xFilial("ACY") + _cCodRede , "ACY_DESCRI" )  
      _oDscGrupo:Refresh() 
   EndIf 

End Sequence 

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS130LEG()
Autor-------------: Julio de Paula Paz
Data--------------: 23/12/2021
Descri��o---------: Fun��o utilizada para exibir a legenda
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS130LEG()
aLegenda :=	{	{"BR_VERMELHO"	, "Bloqueado por Desconto Contratual"	},;
				{"BR_VERDE"	, "Desbloqueado"	}}

BrwLegenda("Rotina de Avalia��o de Clientes.","Legenda",aLegenda)

return

/*
===============================================================================================================================
Programa----------: AOMS130S
Autor-------------: Julio de Paula Paz
Data--------------: 23/12/2021
Descri��o---------: Permite pesquisar um cliente na tela.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS130S()

Local _oGet1	  := Nil 
Local _oDlgP	  := Nil 
Local _cGet1	  := Space(60)
Local _nOpca	  := 0
Local _cComboBx1  := "Codigo e Loja"
Local _aComboBx1  := {"Codigo e Loja","Nome"}
Local _nRegAtu    := (cAliasAux)->(Recno())

Begin Sequence 

   DEFINE MSDIALOG _oDlgP TITLE "Pesquisar Cliente" FROM 178,181 TO 259,697 PIXEL

      @ 004,003 ComboBox	_cComboBx1	Items _aComboBx1 Size 213,010 OF _oDlgP PIXEL
	  @ 020,003 MsGet		_oGet1	Var _cGet1		Size 212,009 OF _oDlgP PIXEL COLOR CLR_BLACK Picture "@!"
	
	  DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlgP:End() ) OF _oDlgP
	  DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlgP:End() ) OF _oDlgP

   ACTIVATE MSDIALOG _oDlgP CENTERED

   If _nOpca == 1
      If ALLTRIM(_cComboBx1) == ALLTRIM(_aComboBx1[1])
         (cAliasAux)->(DbSetOrder(1))
      Else
         (cAliasAux)->(DbSetOrder(2))        
      EndIf 
   
      If ! (cAliasAux)->(MsSeek(RTrim(_cGet1)))
         U_ITMSG("Registro n�o encontrado.","Aten��o",,1)
         (cAliasAux)->(DbSetOrder(1))
         (cAliasAux)->(DbGoTo(_nRegAtu))
      Else 
         (cAliasAux)->(DbSetOrder(1))
         _oMarkBRW:Refresh()
      EndIf 
   EndIf

End Sequence

Return Nil
