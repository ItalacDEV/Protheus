/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 22/12/2015 | Tratativa na cl�usula "ORDER BY" para remover a refer�ncia num�rica. Chamado 13062
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/09/2019 | Revis�o do fonte. Chamado 28346 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#Include "Protheus.Ch"

#Define TITULO "Lotes de Processamento"

/*
===============================================================================================================================
Programa----------: CGPE001
Autor-------------: Alexandre Villar
Data da Criacao---: 21/02/2014
===============================================================================================================================
Descri��o---------: Rotina de Consulta de Lotes de Processamento - Integra��o Funcion�rios x PLS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CGPE001

Local cExpFil		:= " TRIM(Z00_ROTINA) = 'MGPE009' "

Private cCadastro 	:= OemToAnsi(TITULO)
Private aRotina 	:= fMenuDef()

//===========================================================================
//| Endereca a funcao de BROWSE.                                            |
//===========================================================================
DBSelectArea("Z00" )
Z00->( DBSetOrder(1) )
Z00->( MBrowse( ,,,, "Z00" ,,,,,, U_CGPE001L() ,,,,,,,, cExpFil ) )

Return(.T.)

/*
===============================================================================================================================
Programa----------: CGPE001M
Autor-------------: Alexandre Villar
Data da Criacao---: 21/02/2014
===============================================================================================================================
Descri��o---------: Monta a tela de consulta de �tens do Lote
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CGPE001M

Local oDlg			:= Nil
Local oLbxDados		:= Nil
Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= MsAdvSize()
Local cTotReg		:= ""
Local bMntDados		:= {|| Processa({|lEnd| CGPE001SEL( @oLbxDados , Z00->Z00_LOTE , @cTotReg) }) } 
Local oBar			:= Nil
Local aBtn 	    	:= Array(05)

//===========================================================================
//| Cabe�alho dos �tens do Lote.                                            |
//===========================================================================
Local aCabecLbx		:= {	"Lote"				,; //01
							"Chave"				,; //02
							"Tipo"				,; //03
							"Nome"				,; //04
							"Dt.Adm./Nasc."		,; //05
							"Data Proc."		,; //06
							"Hora Proc."		,; //07
							"Tp. Forn."			,; //08
							"C�d. Forn."		,; //09
							"Tp. Plano"			,; //10
							"C�d. Plano"		,; //11
							"Status Lote"		 } //12

Private	cCadastro	:= "Consulta do Lote ["+Z00->Z00_LOTE+"] - " + TITULO

aAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],000 to aSize[6],aSize[5] Of oMainWnd Pixel

	//===========================================================================
	//| ListBox dos �tens do Lote.                                              |
	//===========================================================================
	@aPosObj[01][01]+18,aPosObj[01][02]+4 	Listbox oLbxDados Fields;
											HEADER 	""		 		;
											On DbLCLICK ( Nil )		;
											Size aPosObj[01][04]-10,( aPosObj[01][03] - aPosObj[01][01] ) - 10 Of oDlg Pixel

	oLbxDados:AHeaders		:= aClone(aCabecLbx)
	oLbxDados:BHEADERCLICK	:= { |oObj,nCol| U_ITOrdLbx( oObj , nCol , oLbxDados ) }
	
	Eval(bMntDados)
    
	@aPosObj[01][01]+10,aPosObj[01][02] To aPosObj[01][03]+10,aPosObj[01][04] LABEL "Registros Processados no Lote ["+ cTotReg +"]" COLOR CLR_HBLUE OF oDlg PIXEL

	//===========================================================================
	//| Bot�es da Barra Superior.                                               |
	//===========================================================================
	DEFINE BUTTONBAR oBar SIZE 25,25 3D OF oDlg

	DEFINE BUTTON aBtn[01] RESOURCE PmsBExcel()[1] OF oBar GROUP ACTION DlgToExcel({{"ARRAY","",oLbxDados:AHeaders,oLbxDados:aArray}})	TOOLTIP "Exportar Para Planilha..."
	aBtn[01]:cTitle := ""
	
	DEFINE BUTTON aBtn[03] RESOURCE "FINAL" 		OF oBar GROUP ACTION oDlg:End() 														TOOLTIP "Sair da Tela..."
	aBtn[03]:cTitle := ""
	
	oDlg:lMaximized := .T.
	
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*
===============================================================================================================================
Programa----------: CGPE001SEL
Autor-------------: Alexandre Villar
Data da Criacao---: 21/02/2014
===============================================================================================================================
Descri��o---------: Recupera os dados dos �tens do Lote para exibi��o na Tela.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CGPE001SEL( oLbxAux , cNumLote , cTotReg )

Local aLbxAux		:= {}
Local cAlias		:= GetNextAlias()
Local nTotReg   	:= 0
Local nCont			:= 0

//===========================================================================
//| Monta o SQL da Consulta.                                                |
//===========================================================================
BeginSql alias cAlias
	SELECT Z01.Z01_LOTE LOTE, Z01.Z01_CHAVE CHAVE,
	       CASE WHEN Z01.Z01_TIPO = '1' THEN 'TITULAR' ELSE 'DEPENDENTE' END TIPO,
	       CASE WHEN Z01.Z01_TIPO = '1' THEN SRA.RA_NOME ELSE SRB.RB_NOME END NOME,
	       CASE WHEN Z01.Z01_TIPO = '1' THEN SRA.RA_ADMISSA ELSE SRB.RB_DTNASC END DT_AUX,
	       Z01.Z01_DTPRO DT_PRO, Z01.Z01_HRPRO HR_PRO, Z01.Z01_TPFORN TP_FORN,
	       Z01.Z01_CODFOR COD_FOR, Z01.Z01_TPPLAN TP_PLAN, Z01.Z01_PLANO PLANO, Z01.Z01_STATUS STS_AUX
	  FROM %Table:Z01% Z01
	  LEFT OUTER JOIN %Table:SRA% SRA
	    ON SRA.RA_FILIAL || SRA.RA_MAT = SUBSTR(Z01.Z01_CHAVE, 1, 8)
	   AND SRA.D_E_L_E_T_ = ' '
	  LEFT OUTER JOIN %Table:SRB% SRB
	    ON SRB.RB_FILIAL || SRB.RB_MAT || SRB.RB_COD = Z01.Z01_CHAVE
	   AND SRB.D_E_L_E_T_ = ' '
	 WHERE Z01.D_E_L_E_T_ = ' '
	   AND Z01.Z01_LOTE = %exp:cNumLote%
	 ORDER BY Z01.Z01_CHAVE
EndSql
//===========================================================================
//| Prepara o Ambiente tempor�rio.                                          |
//===========================================================================
(cAlias)->( dbEval( { || nTotReg++ } ) )

ProcRegua(nTotReg)
cTotReg := StrZero( nTotReg , 6 )

(cAlias)->(DBGoTop())                                                                                   

//===========================================================================
//| Grava os dados para exibi��o no ListBox.                                |
//===========================================================================
While !(cAlias)->(Eof())

	aAdd( aLbxAux , {	(cAlias)->LOTE								,; //01
						(cAlias)->CHAVE								,; //02
						(cAlias)->TIPO								,; //03
						(cAlias)->NOME								,; //04
				StoD(	(cAlias)->DT_AUX )							,; //05
				StoD(	(cAlias)->DT_PRO )							,; //06
						(cAlias)->HR_PRO							,; //07
			U_ITRetBox(	(cAlias)->TP_FORN , "RHK_TPFORN" )			,; //08
						(cAlias)->COD_FOR							,; //09
			U_ITRetBox(	(cAlias)->TP_PLAN , "RHK_TPPLAN" )			,; //10
						(cAlias)->PLANO								,; //11
			U_ITRetBox(	(cAlias)->STS_AUX , "Z01_STATUS" )			}) //12

	nCont++
	IncProc("Montando estrutura "+StrZero(nCont,6)+" de "+StrZero(nTotReg,6)  )
	
	(cAlias)->(DBSkip())
EndDo

(cAlias)->(DBCloseArea())

If	Len(aLbxAux) > 0 .And. ValType(oLbxAux) == "O"
                     
	oLbxAux:SetArray(aLbxAux)
	oLbxAux:bLine := {||	{			aLbxAux[oLbxAux:nAt][01]	,; // 01 
										aLbxAux[oLbxAux:nAt][02]	,; // 02
										aLbxAux[oLbxAux:nAt][03]	,; // 03
										aLbxAux[oLbxAux:nAt][04]	,; // 04
										aLbxAux[oLbxAux:nAt][05]	,; // 05
										aLbxAux[oLbxAux:nAt][06]	,; // 06
										aLbxAux[oLbxAux:nAt][07] 	,; // 07
										aLbxAux[oLbxAux:nAt][08] 	,; // 08
										aLbxAux[oLbxAux:nAt][09] 	,; // 09
										aLbxAux[oLbxAux:nAt][10] 	,; // 10
										aLbxAux[oLbxAux:nAt][11] 	,; // 11
										aLbxAux[oLbxAux:nAt][12] 	}} // 12

	oLbxAux:Refresh()

EndIf

Return

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 21/02/2014
===============================================================================================================================
Descri��o---------: Defini��o do Menu da Rotina Principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fMenuDef()

Private aRotina := { 	{ "Pesquisar"	,"AxPesqui"		,0,1}		,;
						{ "Visualizar"	,"AxVisual"		,0,2}		,;
						{ "Consultar"	,"U_CGPE001M"	,0,4}		,; 
						{ "Legenda"		,"U_CGPE001L"	,0,0}	 	}

Return(aRotina)

/*
===============================================================================================================================
Programa----------: CGPE001L
Autor-------------: Alexandre Villar
Data da Criacao---: 21/02/2014
===============================================================================================================================
Descri��o---------: Defini��o da Legenda da tela principal
===============================================================================================================================
Parametros--------: nReg
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CGPE001L( nReg )

Local uRetorno	:= .T.
Local aLegenda  := 	{ 	{ "BR_VERDE"  	, "Funcion�rios"	} ,;
                        { "BR_AMARELO"	, "Dependentes"		}  }


//===========================================================================
//| Controle para verificar se define ou exibe a configura��o da Legenda    |
//===========================================================================
If	nReg == Nil

	uRetorno := {}
	
	Aadd( uRetorno , { 'Z00->Z00_OPERAC == "001" '	, aLegenda[1][1] } )
	Aadd( uRetorno , { 'Z00->Z00_OPERAC == "002" '	, aLegenda[2][1] } )

Else
	BrwLegenda( cCadastro , "Legenda" , aLegenda )
EndIf

Return( uRetorno )