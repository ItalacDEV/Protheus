/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre V. | 22/12/2015 | Tratativa na cl�usula "ORDER BY" para remover a refer�ncia num�rica. Chamado 13062
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
------------------------------------------------------------------------------------------------------------------------------
Jonathan      | 09/10/2020 | Remo��o de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================
#Include "Protheus.Ch"

#Define TITULO "Consulta Fornecedores - Log de Altera��es"

/*
===============================================================================================================================
Programa----------: CCOM001
Autor-------------: Alexandre Villar
Data da Criacao---: 17/07/2014
===============================================================================================================================
Descri��o---------: Consulta Hist�rico de Altera��es do Cadastro de Fornecedores - Chamado 7772
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CCOM001()

Local cCodFor		:= Space( TamSX3("A2_COD")[01] )
Local aParRet		:= { cCodFor }
Local aParamBox 	:= {}

Private cCadastro	:= "Consulta: Log de Altera��es - Fornecedores"

//================================================================================
//| Verifica se a rotina foi chamada do menu ou do Cadastro de Fornecedores      |
//================================================================================
If FunName() <> "CCOM001"
	
	CCOM001HIS( SA2->( A2_COD + A2_LOJA ) )
	
Else

	aAdd( aParamBox	, { 1 , "Selecione o Fornecedor" , cCodFor , "@!" , "" , "SA2" , "" , 50 , .T. } )
	
	If ParamBox( aParamBox , "Informar os dados para a Consulta:" , @aParRet , {|| CCOM001VLD( SA2->A2_COD ) } ,, .T. , , , , , .F. , .F. )
		
		If aParRet[01] != SA2->A2_COD
		
			DBSelectArea("SA2")
			SA2->(DBSetOrder(1))
			If !SA2->( DBSeek( xFilial("SA2") + aParRet[01] ) )
				Aviso( 'Aten��o!' , "O c�digo de Fornecedor informado n�o foi encontrado." , TITULO , 0 )
				Return()
			EndIf
			
		EndIf
		
		CCOM001HIS( SA2->A2_COD )
	
	EndIf

EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: CCOM001VLD
Autor-------------: Alexandre Villar
Data da Criacao---: 17/07/2014
===============================================================================================================================
Descri��o---------: Valida��o do Cliente selecionado/informado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CCOM001VLD( cChvFor )

Local lRet := .F.

//================================================================================
//| Verifica se o Cliente informado/selecionado existe no Cadastro (SA2)         |
//================================================================================
DBSelectArea("SA2")
SA2->( DBSetOrder(1) )
If SA2->( MSSeek( xFilial("SA2") + cChvFor ) )
	lRet := .T.
Else
	MessageBox( "O Fornecedor informado ["+ cChvFor +"] n�o � v�lido." , TITULO , 0 )
	lRet := .F.
EndIf

Return(lRet)

/*
===============================================================================================================================
Programa----------: CCOM001HIS
Autor-------------: Alexandre Villar
Data da Criacao---: 17/07/2014
===============================================================================================================================
Descri��o---------: Monta a tela detalhada do Hist�rico de Altera��es do Cadastro do Cliente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CCOM001HIS( cCodFor )

Local oDlg			:= Nil
Local oLbxTOP		:= Nil
Local oLbxDET		:= Nil
Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= MsAdvSize()
Local bMontaTOP		:= { || Processa({|lEnd| CCOM001LOG( @oLbxTOP , cCodFor ) }) }
Local bMontaDET		:= { || CCOM001DET( @oLbxDET , oLbxTOP:aArray[oLbxTOP:nAt][05] , oLbxTOP:aArray[oLbxTOP:nAt][02] ) }

Local oBar			:= Nil
Local aBtn 	    	:= Array(02)
Local oBold			:= Nil
Local oScrPanel		:= Nil



Local aCabLbxTOP	:= { "Loja", "Campo" , "Descri��o" , "�ltima Alt." } // 04

Local aCabLbxDET	:= { "Data"				,; // 01
                         "Hora"				,; // 02
                         "Usu�rio"			,; // 03
                         "Nome Usr."		,; // 04
                         "Cont. Orig."		,; // 05
                         "Cont. Alt."		 } // 06

Private	nDvPosAnt	:= 0
Private	cCadastro	:= "["+ cCodFor +"] - " + TITULO

Default cCodFor		:= ""

If Empty(cCodFor)
	Return()
EndIf

//================================================================================
//| Posiciona no Cadastro do Cliente                                             |
//================================================================================
DBSelectArea("SA2")
SA2->(DBSetOrder(1))
If !SA2->( DBSeek( xFilial("SA2") + cCodFor ) )
	MessageBox( "O cliente ["+ cCodFor +"] n�o foi encontrado." , TITULO , 0 )
	Return()
EndIf

//================================================================================
//| Verifica se existe hist�rico de altera��es                                   |
//================================================================================
DBSelectArea("Z07")
Z07->( DBSetOrder(1) )
IF !Z07->( DBSeek( xFilial("Z07") + "SA2 1" + SA2->( A2_FILIAL + A2_COD + A2_LOJA ) ) )
	MessageBox( "O cliente ["+ cCodFor +"] n�o possui hist�rico de altera��es." , TITULO , 0 )
	Return()
EndIF

aAdd( aObjects, { 100 , 025 , .T. , .F. , .T. } )
aAdd( aObjects, { 100 , 070 , .T. , .F. } )
aAdd( aObjects, { 100 , 100 , .T. , .T. } )

aInfo   := { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 2 }
aPosObj := MsObjSize( aInfo , aObjects )

DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd Pixel

	aPosObj[01][01] += 12
	aPosObj[02][01] += 10
	aPosObj[02][03] += 10
	aPosObj[03][01] += 10
	aPosObj[03][03] += 10
	
	//================================================================================
	//| Imprime o c�digo e o nome do Cliente                                         |
	//================================================================================
	@ aPosObj[01][01],aPosObj[01][02] MSPANEL oScrPanel PROMPT "" SIZE aPosObj[01][03],aPosObj[01][04] OF oDlg LOWERED
	
	@ 004 , 004 SAY "C�digo:" 		SIZE 025,07 OF oScrPanel PIXEL
	@ 012 , 004 SAY SA2->A2_COD  	SIZE 060,09 OF oScrPanel PIXEL FONT oBold COLOR CLR_BLUE
	
	@ 004 , 030 SAY "Nome:" 		SIZE 025,07 OF oScrPanel PIXEL
	@ 012 , 030 SAY SA2->A2_NOME 	SIZE 165,09 OF oScrPanel PIXEL FONT oBold COLOR CLR_BLUE
	
	//================================================================================
	//| Monta o resumo das altera��es do cadastro                                    |
	//================================================================================
	@aPosObj[02][01],aPosObj[02][02] To aPosObj[02][03],aPosObj[02][04] LABEL "Campos Alterados" COLOR CLR_HBLUE OF oDlg PIXEL
	
	@aPosObj[02][01]+7,aPosObj[02][02]+4 	Listbox oLbxTOP Fields	;
											HEADER 	""		 		;
											On DbLCLICK ( Nil )		;
											Size aPosObj[02][04]-10,( aPosObj[02][03] - aPosObj[02][01] ) - 10 Of oDlg Pixel
	
	oLbxTOP:AHeaders	:= aClone(aCabLbxTOP)
	oLbxTOP:bChange		:= { || Eval(bMontaDET) }
	
	Eval(bMontaTOP)
	
	//================================================================================
	//| Monta os detalhes das altera��es do cadastro                                 |
	//================================================================================
	@aPosObj[03][01],aPosObj[03][02] To aPosObj[03][03],aPosObj[03][04] LABEL "Hist�rico dos Campos" COLOR CLR_HBLUE OF oDlg PIXEL
	
	@aPosObj[03][01]+7,aPosObj[03][02]+4 	Listbox oLbxDET Fields;
											HEADER 	""		 		;
											On DbLCLICK ( Nil )		;
											Size aPosObj[03][04]-10,( aPosObj[03][03] - aPosObj[03][01] ) - 10 Of oDlg Pixel
					
	oLbxDET:AHeaders := aClone(aCabLbxDET)
	
	Eval(bMontaDET)
	
	//================================================================================
	//| Monta a barra de bot�es da tela                                              |
	//================================================================================
	DEFINE BUTTONBAR oBar SIZE 25,25 3D OF oDlg
	
	DEFINE BUTTON aBtn[01] RESOURCE PmsBExcel()[1] OF oBar GROUP ACTION DlgToExcel({{"ARRAY","",oLbxPM7:AHeaders,oLbxPM7:aArray}})	TOOLTIP "Exportar para Planilha..."
	aBtn[01]:cTitle := ""
	
	DEFINE BUTTON aBtn[02] RESOURCE "FINAL" 		OF oBar GROUP ACTION oDlg:End() 													TOOLTIP "Sair da Tela..."
	aBtn[02]:cTitle := ""
	
	oDlg:lMaximized := .T.
	
ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*
===============================================================================================================================
Programa----------: CCOM001LOG
Autor-------------: Alexandre Villar
Data da Criacao---: 17/07/2014
===============================================================================================================================
Descri��o---------: Monta estrutura do Log de Altera��es do Cliente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CCOM001LOG( oLbxAux , cCodFor )

Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()
Local _aLbxAux	:= {}
Local _nTotReg	:= 0
Local _nCont	:= 0

//================================================================================
//| Consulta para buscar o resumo das altera��es do cadastro                     |
//================================================================================
_cQuery := " SELECT "
_cQuery += "	SA2.A2_LOJA			AS LOJA,	"
_cQuery += " 	Z07.Z07_CAMPO 		AS CAMPO,	"
_cQuery += " 	MAX( Z07.Z07_DATA )	AS DT_ULT,	"
_cQuery += "	SA2.R_E_C_N_O_		AS REGSA2	"
_cQuery += " FROM "+ RetSqlName("SA2") +" SA2	"
_cQuery += " INNER JOIN "+ RetSqlName("Z07") +" Z07 "
_cQuery += " ON "
_cQuery += " 		SA2.A2_FILIAL || SA2.A2_COD || SA2.A2_LOJA = Z07.Z07_CHAVE "
_cQuery += " WHERE "
_cQuery += " 		SA2.D_E_L_E_T_  = ' ' "
_cQuery += " AND	Z07.D_E_L_E_T_  = ' ' "
_cQuery += " AND	Z07.Z07_ALIAS	= 'SA2' "
IF Len(cCodFor) == TamSX3("A2_COD")[01]
_cQuery += " AND	SA2.A2_COD      = '"+ cCodFor +"' "
Else
_cQuery += " AND	SA2.A2_COD || SA2.A2_LOJA = '"+ cCodFor +"' "
EndIf
_cQuery += " GROUP BY SA2.A2_LOJA, Z07.Z07_CAMPO, SA2.R_E_C_N_O_ "
_cQuery += " ORDER BY SA2.A2_LOJA , Z07.Z07_CAMPO "

_cQuery	:= ChangeQuery(_cQuery)
DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .F. , .T. )

TcSetField( _cAlias , "Z07.Z07_DATA" , "D" , 8 , 0 )

DBSelectArea(_cAlias)
(_cAlias)->(DBGoTop())

(_cAlias)->( dbEval( { || _nTotReg++ } ) )

ProcRegua(_nTotReg)

(_cAlias)->( DBGoTop() )

//================================================================================
//| Grava os dados do Resumo                                                     |
//================================================================================
While (_cAlias)->(!Eof())
	
	aAdd( _aLbxAux , {	(_cAlias)->LOJA								   		,; // 01
						(_cAlias)->CAMPO							   		,; // 02
						Posicione("SX3",2,(_cAlias)->CAMPO,"X3_DESCRIC")	,; // 03
                       	(_cAlias)->DT_ULT									,; // 04
                       	(_cAlias)->REGSA2					   				}) // 05

_nCont++
IncProc("Montando estrutura "+StrZero(_nCont,6)+" de "+StrZero(_nTotReg,6)  )
(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

//================================================================================
//| Monta o objeto do ListBox                                                    |
//================================================================================
If	Len(_aLbxAux) > 0 .And. ValType(oLbxAux) == "O"
                     
	oLbxAux:SetArray(_aLbxAux)
	oLbxAux:bLine:={||{	_aLbxAux[oLbxAux:nAt][01]	,; // 01
						_aLbxAux[oLbxAux:nAt][02]	,; // 02
						_aLbxAux[oLbxAux:nAt][03]	,; // 03
						_aLbxAux[oLbxAux:nAt][04]	,; // 04
						_aLbxAux[oLbxAux:nAt][05]	}} // 05
	
	oLbxAux:Refresh()

EndIf

Return()

/*
===============================================================================================================================
Programa----------: CCOM001DET
Autor-------------: Alexandre Villar
Data da Criacao---: 17/07/2014
===============================================================================================================================
Descri��o---------: Monta estrutura de Detalhes do Log de Altera��es do Campo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CCOM001DET( oLbxAux , nRegSA2 , cCampo )

Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()
Local _aLbxAux	:= {}
Local _nTotReg	:= 0
Local _nCont	:= 0
Local _bUserN := {|x| UsrFullName(x)}

//================================================================================
//| Consulta para buscar os detalhes das altera��es dos campos                   |
//================================================================================
_cQuery := " SELECT "
_cQuery += " 	Z07.Z07_DATA	AS DT_ALT	, "
_cQuery += " 	Z07.Z07_HORA	AS HORA		, "
_cQuery += " 	Z07.Z07_CODUSU	AS CODUSU	, "
_cQuery += " 	Z07.Z07_CONORG	AS CONT_ORG	, "
_cQuery += " 	Z07.Z07_CONALT	AS CONT_ALT	  "
_cQuery += " FROM "+ RetSqlName("SA2") +" SA2 "
_cQuery += " INNER JOIN "+ RetSqlName("Z07") +" Z07 "
_cQuery += " ON "
_cQuery += " 	SA2.A2_FILIAL || SA2.A2_COD || SA2.A2_LOJA = Z07.Z07_CHAVE "
_cQuery += " WHERE "
_cQuery += " 	SA2.D_E_L_E_T_  = ' ' "
_cQuery += " AND	Z07.D_E_L_E_T_  = ' ' "
_cQuery += " AND	Z07.Z07_ALIAS	= 'SA2' "
_cQuery += " AND	Z07.Z07_CAMPO	= '"+ cCampo +"' "
_cQuery += " AND	SA2.R_E_C_N_O_	= '"+ CValToChar(nRegSA2) +"' "
_cQuery += " ORDER BY Z07.Z07_DATA , Z07.Z07_HORA , Z07.Z07_CODUSU , Z07.Z07_CONORG "

_cQuery	:= ChangeQuery(_cQuery)

DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .F. , .T. )

TcSetField( _cAlias , "Z07.Z07_DATA" , "D" , 8 , 0 )

DBSelectArea(_cAlias)
(_cAlias)->(DBGoTop()) 

(_cAlias)->( DBEval( { || _nTotReg++ } ) )

ProcRegua(_nTotReg) // Regua

(_cAlias)->(DBGoTop())                                                                                   

//================================================================================
//| Grava o resultado dos detalhes das altera��es dos campos                     |
//================================================================================
While (_cAlias)->(!Eof())

		aAdd( _aLbxAux , {			(_cAlias)->DT_ALT		,; // 01
                         			(_cAlias)->HORA			,; // 02
                         			(_cAlias)->CODUSU		,; // 03
  AllTrim( Capital( Eval(_bUserN,	(_cAlias)->CODUSU ) ) )	,; // 04
						AllTrim(	(_cAlias)->CONT_ORG )	,; // 05
						AllTrim(	(_cAlias)->CONT_ALT )	}) // 06

_nCont++
IncProc("Montando estrutura "+StrZero(_nCont,6)+" de "+StrZero(_nTotReg,6)  )
(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

//================================================================================
//| Monta o objeto do ListBox com os dados dos detalhes                          |
//================================================================================
If	Len(_aLbxAux) > 0 .And. ValType(oLbxAux) == "O"
                     
	oLbxAux:SetArray(_aLbxAux)
	oLbxAux:bLine:={||{	_aLbxAux[oLbxAux:nAt][01]	,; // 01
						_aLbxAux[oLbxAux:nAt][02]	,; // 02
						_aLbxAux[oLbxAux:nAt][03]	,; // 03
						_aLbxAux[oLbxAux:nAt][04]	,; // 04
						_aLbxAux[oLbxAux:nAt][05]	,; // 05
						_aLbxAux[oLbxAux:nAt][06]	}} // 06

	oLbxAux:Refresh()

EndIf

Return()
