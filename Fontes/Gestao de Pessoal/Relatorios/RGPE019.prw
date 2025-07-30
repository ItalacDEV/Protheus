/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
      Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz      | 25/06/2021 | Alterar o relatorio para exibir m�s/Ano na coluna de valores do periodo atual. Chamado 36794
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz      | 25/06/2021 | Corrigir rel.p/exibir lan�amentos periodo anterior que n�o existem no periodo atual.Chamado 36794 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer  | 12/07/2021 | Corrigido novamente rel.p/exibir lan�amentos anterior que n�o existem no atual. Chamado 37238 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

#DEFINE REFER  1
#DEFINE NVALOR 2
#DEFINE NPD    3
#DEFINE DESC   4
#DEFINE PIPE   5
#DEFINE INSS   6
#DEFINE FGTS   7
#DEFINE IR     8
#DEFINE VALORB 1
#DEFINE PDB    2
#DEFINE DESCB  3
#DEFINE REFERB 4

Static lPrinOn := .F.
Static cDAnt   := ""
Static aOrdemP
Static aOrdemD
Static aOrdemB
Static cWhereSRC := "%%"
Static cWhereSRD := "%%"

/*
===============================================================================================================================
Programa--------: RGPE019
Autor-----------: Jonathan Torioni
Data da Criacao-: 03/09/2020
===============================================================================================================================
Descri��o-------: Resumo Comparativo da Folha de Pagamento por Competencia
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
USER FUNCTION RGPE019()
	Local aPerAberto	:= {}
	Local aPerFechado	:= {}
	Local cMes			:= ""
	Local cAno			:= ""

	Private nomeprog	:= "RGPE019"
	Private aReturn 	:= { "Zebrado", 1,"Administrativo", 2, 2, 1,"",1 }
	Private aLinha  	:= {}
	Private nLastKey 	:= 0
	Private cPerg   	:= "GPER670"

	Private Titulo	:= "IMPRESSAO DO RESUMO POR COMPETENCIA"	//"IMPRESSAO DO RESUMO POR COMPETENCIA"
	Private CONTFL  := 1
	Private LI      := 0
	Private wCabec0 := 1
	Private wCabec1 := ""
	Private wCabec2 := ""
	Private cCabec
	Private cTipCC
	Private	cRefOco
	Private nTamanho:= "M"
	Private nOrdem
	Private aInfo   := {}
	Private dDataRef
	Private nTpContr

	Private cProcesso	:= "" // Armazena o processo selecionado na Pergunte GPR040 (MV_PAR01).
	Private cRoteiro	:= "" // Armazena o Roteiro selecionado na Pergunte GPR040 (MV_PAR02).
	Private cPeriodo	:= "" // Armazena o Periodo selecionado na Pergunte GPR040 (MV_PAR03).
	Private Semana		:= ""
	Private lSalta   	:= .F.
	Private cSinAna  	:= "A"
	Private lImpNiv  	:= .F.
	Private lUnicNV  	:= .F.
	Private lImpTot  	:= .T.
	Private cDeptoDe    := " "
	Private cDeptoAte   := "ZZZZZZZZZZ"
	Private lImpDepto   := .F.
	Private lSaltaDepto := .F.
	Private dDtPerIni	:= Ctod("  /  /  ")
	Private dDtPerFim	:= Ctod("  /  /  ")
	Private lImpBase   := .T.
	Private cListProc  := ""
	Private cListRot   := ""
	Private lMODFOL    := IF( GetMv("MV_MODFOL") == "2" , .T. , .F. )
	Private lDifLiq		:= .F.
	Private lItemClVl 	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "1*3"	// Determina se utiliza Item Contabil e Classe de Valores
	Private lFechado
	Private cEncInss	:= SuperGetMv( "MV_ENCINSS", .F., "S" )
	
	Private cFilDe   
	Private cFilAte  
	Private cCcDe    
	Private cCcAte   
	Private cMatDe   
	Private cMatAte 
	Private cNomDe   
	Private cNomAte   
	Private cSit     
	Private cCat     
	Private lImpFil   
	Private lImpEmp   

	Private aComp := {}
	Private cMescom := ""
	Private cAnocom := ""
	Private _cMesAtu := ""
	Private _cAnoAtu := ""
	
	
	If cPaisLoc == "BRA"
		Private lPaisagem	:= .F.
		Private cProcAbe	:= ""
		Private cProcFec	:= ""
		Private cPrcAbeSQL	:= ""
		Private cPrcFecSQL	:= ""
	EndIf
	
	/*
	==================================================================
	� Variaveis utilizadas para parametros                         �
	� mv_par01        //  Processo						           �
	� mv_par02        //  Filial  De                               �
	� mv_par03        //  Filial  Ate                              �
	� mv_par04        //  Centro de Custo De                       �
	� mv_par05        //  Centro de Custo Ate                      �
	� mv_par06        //  Matricula De                             �
	� mv_par07        //  Matricula Ate                            �
	� mv_par08        //  Nome De                                  �
	� mv_par09        //  Nome Ate                                 �
	� mv_par10        //  Situacao                                 �
	� mv_par11        //  Categoria                                �
	� mv_par12        //  Imprime Total Filial                     �
	� mv_par13        //  Imprime Total Empresa                    �
	� mv_par14        //  Imprime Referencia ou Ocorrencias        �
	� mv_par15	      //  Tp Contrato                              �
	==================================================================
	*/
	pergunte("RGPE019",.T.)
	
	GetPergunte(@cMes,@cAno,@aPerAberto,@aPerFechado)
	
	lSalta   := .F.
	cSinAna  := "S"
	lImpNiv  := .F.
	lUnicNV  := .F.
	lImpTot  := .T.
	cTipCC   := "1"
	
	R019REL(.T.)


Return

/*
===============================================================================================================================
Programa--------: GetPergunte
Autor-----------: Jonathan Torioni
Data da Criacao-: 03/09/2020
===============================================================================================================================
Descri��o-------: Carrega os dados dos perguntes para as vari�veis.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function GetPergunte(cMes,cAno,aPerAberto,aPerFechado)
Local aRotAut		:= {}
Local nRot
Local nX
Local nCount
Local nY
Local nPer

cMescom := MesExtenso(Val(Substr(MV_PAR19,1,2)))
cAnocom := Substr(mv_par19,3,4)
	
cMes	:= Substr(mv_par01,1,2)
cAno	:= Substr(mv_par01,3,4)

_cMesAtu := MesExtenso(Val(cMes))
_cAnoAtu := cAno

	/*
	================================================================
	| Carregar os periodos abertos (aPerAberto) e/ou os periodos   |
	| fechados (aPerFechado), de acordo com uma determinada compe- |
	| tencia.                 									   |
	================================================================
	*/
	fRetPerComp( cMes, cAno, Nil, Nil, Nil, @aPerAberto, @aPerFechado)

	/*
	================================================================
	| Gerar periodos de Autonomos, caso existam lancamentos nos    |
	| periodos da competencia.                                     |
	================================================================
	*/
	SRY->( DbGoTop() )
	While SRY->( !Eof() )
		If SRY->RY_TIPO == "9"
			aAdd( aRotAut, SRY->RY_CALCULO )
		EndIf
		SRY->( DbSkip() )
	EndDo

	nRot := Len(aRotAut)
	For nX := 1 To nRot
		nPer := Len(aPerAberto)
		For nY := 1 To nPer
			If (aPerAberto[nY,08] == aRotAut[nX] .Or. Empty(AllTrim(aPerAberto[nY,08]))) .And. Empty(AllTrim(aPerAberto[nY,02]))
				aPerAberto[nY,02] := "**"
			EndIf
		Next nY
		nPer := Len(aPerFechado)
		For nY := 1 To nPer
			If (aPerFechado[nY,08] == aRotAut[nX] .Or. Empty(AllTrim(aPerFechado[nY,08]))) .And. Empty(AllTrim(aPerFechado[nY,02]))
				aPerFechado[nY,02] := "**"
			EndIf
		Next nY
	Next nX

	//--Montagem das Datas
	dDtPerIni := CTOD("01/" + cMes + "/" + cAno)
	dDtPerFim := LastDate( dDtPerIni )
	dDataRef  := dDtPerIni
	cFilDe    := MV_PAR02
	cFilAte   := MV_PAR03
	cCcDe     := MV_PAR04
	cCcAte    := MV_PAR05
	cMatDe    := MV_PAR06
	cMatAte   := MV_PAR07
	cNomDe    := MV_PAR08
	cNomAte   := MV_PAR09
	cSit      := MV_PAR10
	cCat      := MV_PAR11
	lImpFil   := If( MV_PAR12 == 1 , .T. , .F. )
	lImpEmp   := If( MV_PAR13 == 1 , .T. , .F. )
	cRefOco   := MV_PAR14
	nTpContr  := MV_PAR15
	lImpBase  := MV_PAR16 == 1

	cperiodo := substr(mv_par01,3,4) + substr(mv_par01,1,2)
	//semana := '01'
	
	IF lMODFOL .OR. cPaisLoc == "BRA"
		cRoteiro  := MV_PAR17 // Roteiro.
		cProcesso := MV_PAR18 // Processo

		//====================================
		// Genera una lista de Procesos      |
		//====================================
		If !Empty(cProcesso)
			If AT(";",cProcesso) > 0
				cProcesso := StrTran(cProcesso,";")
			EndIf
			For nCount := 1 To Len(cProcesso) Step TAMSX3('RCJ_CODIGO')[1]
				if empty( SubStr( cProcesso , nCount , TAMSX3('RCJ_CODIGO')[1] ) )
					exit
				endif
				cListProc += "'" + SubStr( cProcesso , nCount , TAMSX3('RCJ_CODIGO')[1] ) + "',"
			Next
			cListProc := Substr( cListProc , 1 , len( cListProc ) - 1 )
		Else
			Help(,,"Aten��o",, "Nenhum processo selecionado. Verifique os par�metros!",1,0 ) // Aten��o // Nenhum processo selecionado. Verifique os par�metros!
			Return 
		Endif 

		//===========================================
		// Genera una lista de procedimientos       |
		//===========================================
		For nCount := 1 To Len(cRoteiro) Step TAMSX3('RY_CALCULO')[1]
			if empty( SubStr( cRoteiro , nCount , TAMSX3('RY_CALCULO')[1] ) )
				exit
			endif
			cListRot += "'" + SubStr( cRoteiro , nCount , TAMSX3('RY_CALCULO')[1] )+ "',"
		Next
		cListRot := Substr( cListRot , 1 , len( cListRot ) - 1 )
	EndIf

Return
/*
===============================================================================================================================
Programa--------: R019REL
Autor-----------: Jonathan Torioni
Data da Criacao-: 03/09/2020
===============================================================================================================================
Descri��o-------: Resumo Comparativo da Folha de Pagamento por Competencia
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function R019REL(lRGPE019)
Local	oReport
Local	aArea 			:= GetArea()

DEFAULT lRGPE019		:= .F.

Private aFilB			:= {}
Private aGPSVal			:= {}
Private cCodFunc		:= ""
Private cDescFunc		:= ""
Private cPerg			:= "RGPE019"
Private dDataRef		:= CtoD("  /  /  ")
Private cMesAnoRef		:= CtoD("  /  /  ")
Private cAnoMesRef		:= CtoD("  /  /  ")
Private cDtPerFim		:= ""
Private dDtPerIni		:= Ctod("  /  /  ")
Private dDtPerFim		:= Ctod("  /  /  ")
Private dDtPago			:= Ctod("  /  /  ")
Private cTitulo			:= "IMPRESS�O DO REUSUMO COMPARATIVO POR COMPET�NCIA "
Private cMascCus  		:= GetMv("MV_MASCCUS")
Private cCalcInf  		:= GetMv("MV_CALCINF")
Private cQuebFun  		:= GetMv("MV_QUEBFUN",,"S") //quando for igual a nao, imprime funcionario sem quebrar pagina
Private cIRefSem  		:= GetMv("MV_IREFSEM",,"S")
Private lAglutPd  		:= (GetMv("MV_AGLUTPD",,"1") == "1" ) // 1-Aglutina verbas   2-Nao Aglutina
Private lDifLiq			:= .F.
Private lSumaVerba		:= .F.
Private nOrdSra			:= 1
Private cMod1			:= ""
Private aLanB			:= {}
Private aLanP			:= {}
Private aLanD   		:= {}
Private aNomeFunc		:= {}
Private aDifLiquidos	:= {}
Private cPDLiq			:= fGetCodFol("0047")
Private oSectDifLiq
Private cDepto			:= ""  //UTILIZADO P/ INFORMAÇÃO HISTORICA
Private cDescDepto		:= ""
Private cCentroC		:= ""
Private cDescCC			:= ""
Private cSitFunc		:= ""
Private nTotFunc		:= 0
Private nOrdRemov 		:= 0 // QUANTIDADE DE ORDENS NAO EXISTENTES E QUE IMPACTA NA VARIAVEL NORDEM
Private nPosRemov 		:= 0 // POSICAO PARA CONTROLAR O QUE FOI REMOVIDO
Private lDepSf			:= IIf(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.)
Private lRaDtRec		:= IIf(SRA->(FieldPos("RA_DTREC"))>0,.T.,.F.)
Private lRaFecrei		:= IIf(SRA->(FieldPos("RA_FECREI"))>0,.T.,.F.)
Private lRaSalDia		:= IIf(SRA->(FieldPos("RA_SALDIA"))>0,.T.,.F.)
Private lRaSalInt		:= IIf(SRA->(FieldPos("RA_SALINT"))>0,.T.,.F.)
Private aOrd			:={}
Private aSitQtds        := {0,0,0,0,0}//Afastado / ferias / transferido / demitido / normal
Private aTotSitQtds     := {0,0,0,0,0}//Afastado / ferias / transferido / demitido / normal
Private cSitAliasQry    := GetNextAlias()
Private aSintSits       := {}
Private aSintTot        := {}
Private aSintUN     	:= {}
Private aSintEM   	    := {}
Private aSintCC   	    := {}
Private aSintEmp        := {0,0,0,0,0}
Private lDicInter		:= FindFunction("fChkInterm") .And. fChkInterm()
Private cDesToma        := "" //Descrição do tomador de serviços.
Private cCEI            := "" // CEI/CNPJ tomador de serviços.

Aadd(aOrd, OemToAnsi("Matr�cula")+"+"+OemToAnsi("Lan�amentos"))
nPosRemov := Len(aOrd)

Private cProcesso		:= ""
Private cPeriodo		:= ""
Private cPagamento		:= ""
Private cRoteiro		:= ""
Private cRot			:= ""
Private cAliasFun		:= ""
Private cAliasQry		:= ""
Private cAliasFunTT		:= ""
Private nOrdem			:= 1
Private nAnaSin   		:= 0
Private nTpContr		:= 0
Private aInfo			:= Array(26)
Private cCodFilial		:= "##"
Private lCorpManage		:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
Private lSint			:= .F. // variável que informa se foi selecionado tipo sintético

If lCorpManage
	Private lUniNeg    := !Empty(FWSM0Layout(cEmpAnt, 2)) // Verifica se possui tratamento para unidade de Negocios
	Private lEmpFil    := !Empty(FWSM0Layout(cEmpAnt, 1)) // Verifica se possui tratamento para Empresa
	Private cLayoutGC  := FWSM0Layout(cEmpAnt)
	Private nStartEmp  := At("E",cLayoutGC)
	Private nStartUnN  := At("U",cLayoutGC)
	Private nEmpLength := Len(FWSM0Layout(cEmpAnt, 1))
	Private nUnNLength := Len(FWSM0Layout(cEmpAnt, 2))
EndIf

Pergunte(cPerg,.F.)

cRot := MV_PAR02
cRefOco		:= MV_PAR14

cAliasQry	:= GetNextAlias()
cAliasFun	:= GetNextAlias()
cAliasFunTT	:= GetNextAlias()

oReport := ReportDef(lRGPE019)

// Não imprimir Total Geral
oReport:bTotalcanprint := {|| .F. }

oReport:PrintDialog()

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf
If Select(cAliasFun) > 0
	(cAliasFun)->(DbCloseArea())
EndIf
If Select(cAliasFunTT) > 0
	(cAliasFunTT)->(DbCloseArea())
EndIf

RestArea(aArea)

Return

/*
===============================================================================================================================
Programa--------: ReportDef
Autor-----------: Jonathan Torioni
Data da Criacao-: 04/09/2020
===============================================================================================================================
Descri��o-------: Realiza a montagem do relat�rio
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef(lRGPE019)
Local oReport
Local oSecMat
Local oSecLan
Local cDesc1	:= OemToAnsi("Folha de Pagamento") + OemToAnsi("Imprime a Folha de pagamento, de acordo com os parametros solicitados pelo usu�rio.")
Local nSize := 14
Local aTipoOn := {.F.,.T.,.F.}


//CRIACAO DOS COMPONENTES DE IMPRESSAO
DEFINE REPORT oReport NAME "RGPE019" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R019Imp(oReport,lRGPE019) } DESCRIPTION cDesc1

	nAnaSin := 2
	cRefOco		:= MV_PAR14

	oReport:SetTotalInLine(.F.)	// PARA TOTALIZAR EM LINHAS

	oReport:nFontBody	:= 8 
	oReport:SetDynamic()
		
		DEFINE SECTION oSecMat OF oReport TITLE OemToAnsi("Filial / Funcion�rio") TABLES "SRA","SQB","CTT","RCO","RGC" ORDERS aOrd	//"Filial / Funcionário"

		DEFINE CELL NAME "ESPACO"     OF oSecMat TITLE "" BLOCK {||" "}		//Recurso alternativo para que a section do funcionário náo saia colada a collection.
		DEFINE CELL NAME "RA_FILIAL"  OF oSecMat ALIAS "SRA"

		DEFINE CELL NAME "RA_MAT"     OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"    OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "CODFUNC"	  OF oSecMat TITLE FSubst("Fun��o") SIZE 5 BLOCK {||cCodFunc}			//"Função"
		DEFINE CELL NAME "DESCFUNC"   OF oSecMat TITLE FSubst("Descri��o") SIZE 20 BLOCK {||Substr(cDescFunc,1,20)}

		DEFINE CELL NAME "RA_CC"	  OF oSecMat TITLE  SIZE 9 BLOCK {|| cCentroC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,,.T.,.F.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,,.T.,.F.) )} //busca informação historicas
		DEFINE CELL NAME "CTT_DESC01" OF oSecMat TITLE FSubst("Descri��o") SIZE 60 BLOCK {|| cDescCC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,2,.T.,.F.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,2,.T.,.F.) )}
		DEFINE CELL NAME "RA_DEPTO"	  OF oSecMat TITLE OemToAnsi("Depto.") SIZE 9 BLOCK {|| cDepto := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,,.T.) )}
		DEFINE CELL NAME "QB_DESCRIC" OF oSecMat TITLE FSubst("Descri��o")SIZE 20 BLOCK {|| cDescDepto := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,2,.T.) ) }

		DEFINE CELL NAME "RA_ADMISSA" OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_ADMISSA) }

		
		DEFINE CELL NAME "RA_CATFUNC" OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CATFUNC  }
		If cPaisLoc != "COS"
			If cPaisLoc <>"COL"
				DEFINE CELL NAME "RA_DEPIR"   OF oSecMat ALIAS "SRA" BLOCK {|| SUBSTR(GPRETSR9( "SRA", LastDay(dDataRef), "RA_DEPIR" ),1,4) }
			EndIF

			DEFINE CELL NAME "RA_HRSMES"  OF oSecMat ALIAS "SRA"
		Endif

		DEFINE CELL NAME "PERCADT"    OF oSecMat TITLE OemToAnsi("Perc.Adto.: ")	SIZE 3 		//"Perc.Adto.: "
		DEFINE CELL NAME "RA_CIC"     OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_CURP"    OF oSecMat ALIAS "SRA"

		IF cPaisLoc <> "COL"
			DEFINE CELL NAME "RA_RG"      OF oSecMat ALIAS "SRA"
		EndIf

		DEFINE CELL NAME "RA_TSIMSS"  OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RCO_NREPAT" OF oSecMat ALIAS "RCO"

		If lRaDtrec
			DEFINE CELL NAME "RA_DTREC"   OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_DTREC) }
		Endif

		If lRaFecrei
			DEFINE CELL NAME "RA_FECREI"  OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_FECREI) }
		Endif

		If lRaSalDia
			DEFINE CELL NAME "RA_SALDIA"  OF oSecMat TITLE  SIZE 13 BLOCK {||cSaldia := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerFim,4), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDtPerFim,4))}
		Endif

		If lRaSalInt
			DEFINE CELL NAME "RA_SALINT"  OF oSecMat TITLE  SIZE 13 BLOCK {||cSaldii :=	IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerFim,5), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDtPerFim,5))}
		EndIf

		DEFINE CELL NAME "ESPACO2"    OF oSecMat TITLE "" BLOCK {||" "}		//Recurso alternativo para saltar linha.
		DEFINE CELL NAME "PROVDESC"   OF oSecMat TITLE "" SIZE 125

		oSecMat:SetLineStyle()
		oSecMat:SetCols(3)
		oSecMat:SetTotalInLine(.F.)
		oSecMat:Cell("ESPACO"    ):SetCellBreak(.T.)
		oSecMat:Cell("RA_NOME"   ):SetCellBreak(.T.)


		oSecMat:Cell("DESCFUNC"  ):SetCellBreak(.T.)
		oSecMat:Cell("CTT_DESC01"):SetCellBreak(.T.)
		oSecMat:Cell("QB_DESCRIC"):SetCellBreak(.T.)

		oSecMat:Cell("ESPACO2"   ):SetCellBreak(.T.)


		If cPaisLoc != "COS"
			oSecMat:Cell("RA_CIC"    ):Disable()
			oSecMat:Cell("RCO_NREPAT"):Disable()

			IF cPaisLoc == "COL"
				oSecMat:Cell("PERRET" ):SetCellBreak(.T.)
			ELSE
				oSecMat:Cell("RA_RG"     ):Disable()
				oSecMat:Cell("RA_HRSMES" ):SetCellBreak(.T.)
			ENDIF
		Else
			oSecMat:Cell("RCO_POLRT"):SetCellBreak(.T.)
		Endif

		oSecMat:Cell("RA_CURP"   ):Disable()
		oSecMat:Cell("RA_TSIMSS" ):Disable()

		If lRaDtRec
			oSecMat:Cell("RA_DTREC"  ):Disable()
		Endif

		If lRaFecrei
			oSecMat:Cell("RA_FECREI" ):Disable()
		Endif

		If lRaSaldia
			oSecMat:Cell("RA_SALDIA" ):Disable()
		Endif

		If lRaSalint
			oSecMat:Cell("RA_SALINT" ):Disable()
		Endif


		
		oSecMat:Disable()
		oSecMat:SetCharSeparator(" ")
		oSecMat:SetDynamicKey(OemToAnsi("Matr�cula"))	//"Matrícula"
		oSecMat:SetNoFilter({"SQB","RCO","RGC"})
		TRPosition():New(oSecMat,"SRA",nOrdSra,{|| If (nAnaSin == 1, (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT, (cAliasQry)->RA_FILIAL )},.T.)

	//SECTION 02
	DEFINE SECTION oSecLan OF oReport TITLE OemToAnsi("Verbas do Funcion�rio") TABLES "SRC", "SRD", "SRV", "SRA" ORDERS aOrd

		DEFINE CELL NAME "RA_MAT" OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "PDP"    OF oSecLan TITLE OemToAnsi("Cod.") SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCP"  OF oSecLan TITLE FSubst("Descri��o") SIZE 14 PICTURE "@!" 		//"Descrição"
		DEFINE CELL NAME "REFERP" OF oSecLan TITLE iif(lRGPE019 .And. cRefOco == 2 ,"OCOR.",OemToAnsi("Ref.")) SIZE 08 					//"Ref." #"OCOR."
		DEFINE CELL NAME "VALORP" OF oSecLan TITLE OemToAnsi("Valor de " + _cMesAtu + "/"+_cAnoAtu) SIZE nSize				//"Valor"    
		DEFINE CELL NAME "VALORPCOM" OF oSecLan ALIAS "" TITLE OemToAnsi("Valor" + " de " + cMesCom + "/" + cAnoCom) SIZE nSize	//"Valor"
		DEFINE CELL NAME "PERCENTUALP" OF oSecLan ALIAS "" TITLE OemToAnsi("Diferen�a %") SIZE nSize PICTURE "@E 999.999"	//Percentual 

		DEFINE CELL NAME "INSSP"	OF oSecLan TITLE 'IN' SIZE 2
		DEFINE CELL NAME "FGTSP"	OF oSecLan TITLE 'FG' SIZE 2
		DEFINE CELL NAME "IRP"	OF oSecLan TITLE 'IR' SIZE 2

		DEFINE CELL NAME "PIPEP"  OF oSecLan TITLE "|"        BLOCK {||"|"}

		DEFINE CELL NAME "PDD"    OF oSecLan TITLE OemToAnsi("Cod.") SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCD"  OF oSecLan TITLE FSubst("Descri��o") SIZE 14 PICTURE "@!" 		//"Descrição"
		DEFINE CELL NAME "REFERD" OF oSecLan TITLE  iif(lRGPE019 .And. cRefOco == 2 ,"OCOR.",OemToAnsi("Ref.")) SIZE 08 					//"Ref."
		DEFINE CELL NAME "VALORD" OF oSecLan TITLE OemToAnsi("Valor de " + _cMesAtu + "/"+_cAnoAtu) SIZE nSize				//"Valor"    
		DEFINE CELL NAME "VALORDCOM" OF oSecLan ALIAS "" TITLE OemToAnsi("Valor" + " de " + cMesCom + "/" + cAnoCom) SIZE nSize		//"Valor"
		DEFINE CELL NAME "PERCENTUALD" OF oSecLan ALIAS "" TITLE OemToAnsi("Diferen�a %") SIZE nSize PICTURE "@E 999.999"	//Percentual 

		DEFINE CELL NAME "INSSD"	OF oSecLan TITLE 'IN' SIZE 2
		DEFINE CELL NAME "FGTSD"	OF oSecLan TITLE 'FG' SIZE 2
		DEFINE CELL NAME "IRD"  	OF oSecLan TITLE 'IR' SIZE 2

		DEFINE CELL NAME "PIPED"  OF oSecLan TITLE "|"        BLOCK {||"|"}

		DEFINE CELL NAME "PDB"    OF oSecLan TITLE OemToAnsi("Cod.") SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCB"  OF oSecLan TITLE FSubst("Descri��o") SIZE 15 PICTURE "@!" 		//"Descrição"

		aEval({'P', 'D'},{|x|oSecLan:Cell("INSS" + x):Disable(),oSecLan:Cell("FGTS" + x):Disable(),oSecLan:Cell("IR" + x):Disable()})

		DEFINE CELL NAME "VALORB" OF oSecLan TITLE OemToAnsi("Valor de " + _cMesAtu + "/"+_cAnoAtu) SIZE nSize 				//"Valor"   
		DEFINE CELL NAME "VALORBCOM" OF oSecLan ALIAS "" TITLE OemToAnsi("Valor" + " de " + cMesCom + "/" + cAnoCom) SIZE nSize				//"Valor"
		DEFINE CELL NAME "PERCENTUALB" OF oSecLan ALIAS "SRC" TITLE OemToAnsi("Diferen�a %") SIZE nSize PICTURE "@E 999.999"	//Percentual 

		oSecLan:SetName("LANCAMENTO")
		oSecLan:Cell("RA_MAT"):Disable()
		oSecLan:Cell("REFERP"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORP"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORP"):lAutoSize := .F.
		oSecLan:Cell("REFERD"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORD"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORB"):SetHeaderAlign("RIGHT")
		oSecLan:SetTotalInLine(.F.)
 		oSecLan:Disable()
		oSecLan:SetDynamicKey(OemToAnsi("Lan�amentos"))	//"Lançamentos"

	oReport:SetDevice(4) // Planilha
	oReport:SetTpPlanilha(aTipoOn)
	oReport:SetLandscape()
Return(oReport)

/*
===============================================================================================================================
Programa--------: R019Imp
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
===============================================================================================================================
Descri��o-------: Funcao usada para verificar e retornar dados do relat�rio
===============================================================================================================================
Parametros------: oReport
				  lRGPE019
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function R019Imp(oReport,lRGPE019)
Local oSectLanc		:= oReport:Section(2)
Local oSectFunc
Local oSectCttc
Local oSectDept

Local cMes			:= ""
Local cAno			:= ""
Local cNumPg		:= Space(2)
Local nReg			:= 0

Local bLancamentos	:= {|oSelf|fImprimeLanca(oSelf)}
Local bLancSint		:= {|oSelf|fImprSint(oSelf,lRGPE019)}
Local bBlock			:= {}

Local cUltSem		:= ""
Local cAcessaSRA  	:=   ChkRH( "R019REL" , "SRA" , "2" )
Local cSFiltrSQL      := fSFiltrSQL(cAcessaSRA)

Local uRatDes
Local lGper040		:= (FunName() == "GPER040")
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})

Private lOfusca		:= Len(aFldRel) > 0
Private aVerbas		:= {}
Private aVerbasRet	:= {}
Private aVerbasSin	:= {}
Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private nHrsMes		:= 0
Private nSalario	:= 0
Private cCpoQuebra	:= ""
Private c2CpoQbr	:= ""
Private cFilAux 	:= "##"
Private lRatDes 	:= .F.
Private lPerAberto	:= .T.
Private cCpoDelim		:= ""
Private cCpoDelimC	:= ""
Private cCpoDelimD	:= ""
Private cTpcQuery		:= ""
Private cSitQuery		:= ""
Private cGroupED		:= "%%"
Private cCpoAlsD		:= ""
Private cCatQuery		:= ""
Private cExtraD		:= "%%"
Private cGroupEC		:= "%%"
Private cExtraC		:= "%%"
Private cCpoAdView	:= ""
Private cCpoView		:= ""
Private cFiltro		:= ""
Private cFiltroC 		:= ""
Private cFiltroD 		:= ""
Private cCpoAlsC		:= ""
Private cJoinC		:= ""
Private cJoinD		:= ""
Private cJoinAux		:= ""
Private cCpoAls		:= ""
Private cCpoViewG		:= ""
Private cCCpoQuebra	:= ""
Private cDCpoQuebra	:= ""
Private cJoinView		:= ""
Private _cPerCompar := ""

uRatDes 	 	:= GetMvRH( "MV_RAT0973", .F., .F. )

// Parametro era logico e mudou para caracter indevidamente no P12
If ValType( uRatDes ) == "L"
	lRatDes := uRatDes
ElseIf ValType( uRatDes ) == "C"
	uRatDes := GetMvRH( "MV_RAT0973", .F., ".F." )
	lRatDes	:= ( uRatDes == ".T." )
EndIf

nOrdSra 	:= RetOrdem("RA_FILIAL+RA_MAT")

nOrdem		:= oReport:GetOrder()

If (nOrdRemov > 0) .And. (nOrdem >= nPosRemov)
	nOrdem := nOrdem + nOrdRemov
EndIf

cCpoView	:= "%RAFILIAL RA_FILIAL"
cCpoViewG	:= "%RAFILIAL"
cCpoAls	:= "%RA_FILIAL RAFILIAL"

oSectFunc 	:= oReport:Section(1)

oSectFunc:SetName("FUNCIONARIO")
oSectFunc:SetLineCondition( { || Eval(bBlock) } )

cProcesso	:= cListProc
cRoteiro	:= cListRot
cPeriodo	:= substr(mv_par01,3,4) + substr(mv_par01,1,2)
cPagamento	:= "99"
cSituacao	:= mv_par10
cCategoria	:= mv_par11
nTpContr 	:= mv_par15      //Tipo Contrato:  1=Indeterminado; 2=Determinado; 3=Ambos
lBrkCc		:= .F. 			 //Salta Pag. quebra C.Custo: 1=Sim; 2=Nao
lBrkDp		:= .F. 			 //Salta Pag. quebra Depto:   1=Sim; 2=Nao
lImpFil  	:= mv_par12 == 1 //Imprime totais por Filial: 1=Sim; 2=Nao
lImpEmp  	:= mv_par13 == 1 //Imprime totais por Empr.:  1=Sim; 2=Nao
lImpUni		:= lImpEmp       //Imprime totais por Unidade de Negocio: se imprime totais por empresa=Sim; senao = Nao
nTipCC   	:= 1    		 //Tipo Impressao C.Custo: 1=Codigo; 2=Descricao; 3=Ambos
nTipDp		:= 1     		 //Tipo Impressao Depto: 1=Codigo; 2=Descricao; 3=Ambos
lBrkPagFil	:= .F.			 //Salta Pag. quebra Filial 1=Sim; 2=Nao:
lImpBase	:= mv_par16 == 1
cRefOco		:= MV_PAR14
_cPerCompar := substr(mv_par19,3,4) + substr(mv_par19,1,2)  

oSectLanc:Cell("REFERD" ):SetTitle( iif(lRGPE019 .And. cRefOco == 2 ,"OCOR.",OemToAnsi("Ref.")))
oSectLanc:Cell("REFERP" ):SetTitle( iif(lRGPE019 .And. cRefOco == 2 ,"OCOR.",OemToAnsi("Ref.")))

oReport:SetTitle(AllTrim(cTitulo))

lSint := (nAnaSin == 2)


bBlock := {|| .T. }
oSectLanc:SetParentRecno()
oSectLanc:SetNoSkip()

lDifLiq	:= .F.
lSumaVerba	:= lAglutPd


If (!lSint)	//Analítico
	oSectFunc:Cell("PROVDESC"):Enable()
	If lImpBase
		oSectFunc:Cell("PROVDESC"  ):SetBlock({||OemToAnsi("       P R O V E N T O S                             D E S C O N T O S                             B A S E S")})
			//"        P R O V E N T O S                              D E S C O N T O S                              B A S E S"
	Else
		oSectLanc:Cell("PDB"    ):SetTitle("")
		oSectLanc:Cell("DESCB"  ):SetTitle("")
		oSectLanc:Cell("VALORB" ):SetTitle("")

		oSectLanc:Cell("PDB"     ):Hide()
		oSectLanc:Cell("DESCB"   ):Hide()
		oSectLanc:Cell("VALORB"  ):Hide()
		oSectFunc:Cell("PROVDESC"):SetBlock({||OemToAnsi("        P R O V E N T O S                              D E S C O N T O S ")})
			//"        P R O V E N T O S                              D E S C O N T O S "
	EndIf
Endif

cNumPg := If (cPagamento == "99" , "" , cPagamento)

dDtPerFim := LastDate( CTOD("01/" + cMes + "/" + cAno) )
cMes	:= Substr(mv_par01,1,2)
cAno	:= Substr(mv_par01,3,4)

If nAnaSin == 2 .and. cPagamento == "99" //Obtem a última semana do período atual
	cUltSem := fLastSem( cProcesso, cRoteiro, cPeriodo ) //Obtem a última semana do período
EndIf

cDtPerFim := DtoS(dDtPerFim)

//--MONTAGEM DO DDATAREF SOBRE O PERIODO
dDataRef	:=CTOD("01/" + cMes + "/" + cAno)
cMesAnoRef	:= StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
cAnoMesRef	:= Right(cMesAnoRef,4) + Left(cMesAnoRef,2)

If cPagamento # "99"
	cTitulo += AllTrim(GR040RetPer( cPagamento, cPeriodo ))
Else
	cTitulo += " / "+Upper(MesExtenso(Month(dDataRef)))+OemToAnsi(" de ")+STR(YEAR(dDataRef),4) 	//" DE "
EndIf

If nAnaSin	== 1 	//Analitico
	If !lSint
		cTitulo += " - " + OemToAnsi("Anal�tico")	//Analítico
	Else
		cTitulo += " - " + OemToAnsi("Sint�tico")	//Sintetico
	Endif

	If nOrdem == 1
		cTitulo += " - " + OemToAnsi("Matr�cula")	//Matrícula
	ElseIf nOrdem == 2
		cTitulo += " - " + OemToAnsi("Nome")	//Nome
	EndIf
	oSectFunc:Cell("RA_FILIAL" ):Disable()
	oSectFunc:OnPrintLine(bLancamentos)
	oSectLanc:OnPrintLine(bLancamentos)

	If cPaisLoc <> "COL"
		oSectFunc:Cell("RA_CATFUNC"):SetBlock({||fRetSR7(dDataRef, dDataRef, .T.)})
	EndIf

	oSectFunc:Cell("PERCADT"   ):SetBlock({||StrZero((cAliasFun)->RA_PERCADT,3)})

Else	//Sintético
	oSectFunc:OnPrintLine(bLancSint)
	oSectLanc:OnPrintLine(bLancSint)
	oSectFunc:Cell("ESPACO"	   ):Disable()
	oSectFunc:Cell("RA_MAT"    ):Disable()
	oSectFunc:Cell("RA_NOME"   ):Disable()
	oSectFunc:Cell("CODFUNC"   ):Disable()
	oSectFunc:Cell("DESCFUNC"  ):Disable()
	oSectFunc:Cell("RA_ADMISSA"):Disable()
	oSectFunc:Cell("RA_CATFUNC"):Disable()
	oSectFunc:Cell("RA_CC"    ):Disable()
	oSectFunc:Cell("CTT_DESC01"    ):Disable()
	oSectFunc:Cell("PERCADT"    ):Disable()
	oSectFunc:Cell("RA_DEPTO"    ):Disable()
	oSectFunc:Cell("QB_DESCRIC"    ):Disable()
	oSectFunc:Cell("PERCADT"    ):Disable()
	oSectFunc:Cell("RA_ADMISSA"    ):Disable()
	oSectFunc:Cell("RA_CATFUNC"    ):Disable()
	oSectFunc:Cell("RA_DEPIR"    ):Disable()
	oSectFunc:Cell("RA_HRSMES"    ):Disable()
	oSectFunc:Cell("RA_HRSMES"    ):Disable()
	oSectFunc:Cell("PERCADT"    ):Disable()
	oSectFunc:Cell("RA_CIC"    ):Disable()
	oSectFunc:Cell("RA_CURP"    ):Disable()
	oSectFunc:Cell("RA_RG"    ):Disable()
	oSectFunc:Cell("RA_TSIMSS"    ):Disable()
	oSectFunc:Cell("RCO_NREPAT"    ):Disable()
	oSectFunc:Cell("ESPACO2"    ):Disable()
	oSectFunc:Cell("PROVDESC"    ):Disable()
	
	
EndIf

//QUEBRA FILIAL
//DEFINE BREAK oBreakFil OF oReport WHEN  oSectFunc:Cell("RA_FILIAL") TITLE OemToAnsi("Valor") //"Total da Filial "
//DEFINE BREAK oa2BreakEFil OF oReport WHEN  oSectFunc:Cell("RA_FILIAL")

//DEFINE BREAK oa4BreakFil OF oReport   WHEN  {||  Iif( (nAnaSin == 1 .And. !lSint), oSectFunc:Cell("RA_FILIAL"):GetText(),oSectFunc:Cell("RA_FILIAL"):GetText())  + oSectFunc:Cell("RA_FILIAL"):GetText() }
//DEFINE BREAK oBreakEmp OF oReport WHEN  { || "" }
//DEFINE BREAK oa3BreakEmp OF oReport WHEN  { || "" }

cSitQuery	:= ""
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += ","
	Endif
Next nReg

cCatQuery	:= ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += ","
	Endif
Next nReg

If nTpContr == 3 .AND. !lDicInter
	cTpcQuery	:= "'1', '2', ' ' "
elseIf nTpContr == 4 .AND. lDicInter
	cTpcQuery	:= "'1', '2', '3' ,' ' "
Else
	cTpcQuery	:= "'" + cValToChar(nTpContr) + "'"
EndIf

//ALTERA O TITULO DO RELATORIO
oReport:SetTitle(cTitulo)

cFiltro += fAjustFil(.T.) //Retorna no filtro somente as filiais que o usuário tem acesso
cFiltro	+= " AND RA_MAT BETWEEN '" + MV_PAR06 + "' and '" + MV_PAR07 + "'  "
cFiltro	+= " AND RA_NOME BETWEEN '" + MV_PAR08 + "' and '" + MV_PAR09 + "'  "
cFiltro	+= " AND RA_CC BETWEEN '" + MV_PAR04 + "' and '" + MV_PAR05 + "'  "

cSitQuery	:= "%" + cSitQuery + "%"
cCatQuery	:= "%" + cCatQuery + "%"
cTpcQuery	:= "%" + cTpcQuery + "%"


//SUPER FILTRO
If !Empty(cSFiltrSQL) .AND. cSFiltrSQL != ".T."
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += cSFiltrSQL
EndIf
cUserFiltro := ""
cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "SRA",.T.)), oSectFunc:GetUserExp( "SRA",.T.) , "")
cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "CTT",.T.)), oSectFunc:GetUserExp( "CTT",.T.) , "")
If nOrdem == 3 .Or.  nOrdem == 4 .Or.  nOrdem == 5 .Or.  nOrdem == 6
	cUserFiltro += IIF (!EMPTY(oSectCttc:GetUserExp( "CTT",.T.)), oSectCttc:GetUserExp( "CTT",.T.) , "")
EndIf
cFiltro += Iif(!Empty(cUserFiltro)," AND " + cUserFiltro ,"")

If !Empty(cFiltro)
	cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+StrTran( cFiltro, "RA_CC", "RC_CC" ),StrTran( cFiltro, "RA_CC", "RC_CC" ))
	cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+StrTran( cFiltro, "RA_CC", "RD_CC" ),StrTran( cFiltro, "RA_CC", "RD_CC" ))
	cFiltro		:= Iif(!Empty(cFiltro ),cFiltro,"")
EndIf

SRA->( dbCloseArea() ) //FECHA O SRA PARA USO DA QUERY

//SINTETICO
cCpoDelim	:= "%RA_FILIAL"
cCpoDelimC	:= Iif(!Empty(cCCpoQuebra),							;
					cCpoDelim+","+AllTrim(cCCpoQuebra)+"%",		;
					Iif(!Empty(cCpoQuebra ),					;
						cCpoDelim+","+AllTrim(cCpoQuebra)+"%",	;
						cCpoDelim+"%"							;
						)										;
					)

cCpoDelimD	:= Iif(!Empty(cDCpoQuebra),							;
					cCpoDelim+","+AllTrim(cDCpoQuebra)+"%",		;
					Iif(!Empty(cCpoQuebra ),					;
						cCpoDelim+","+AllTrim(cCpoQuebra)+"%",	;
						cCpoDelim+"%"							;
						)										;
					)

cCpoDelim	+= Iif(!Empty(cCpoQuebra ),","+AllTrim(cCpoQuebra)+"%","%")
cCpoView	+= "%"
cCpoViewG	+= "%"
cCpoAls	+= "%"

cFiltro	:= Iif(Empty(cFiltro ),"%%","% AND "+cFiltro +"%")
cCpoAlsC	:= Iif(Empty(cCpoAlsC),cCpoAls,cCpoAlsC+"%")
cCpoAlsD	:= Iif(Empty(cCpoAlsD),cCpoAls,cCpoAlsD+"%")

cJoinC		:= "% AND SRA.RA_MAT = SRC.RC_MAT " +;
			" INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR019join("CTT", "SRC") + " AND CTT.CTT_CUSTO = SRC.RC_CC %"
cJoinD		:= "% AND SRA.RA_MAT = SRD.RD_MAT" +;
			" INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR019join("CTT", "SRD") + " AND CTT.CTT_CUSTO = SRD.RD_CC %"

Sx2ChkModo( "CTT", NIL, .F., @cMod1, NIL )

If !empty(cListProc)
	cWhereSRC := "% SRC.RC_PROCES IN  (" + cListProc + ") AND "
	cWhereSRD := "% SRD.RD_PROCES IN  (" + cListProc + ") AND "
EndIf
If !empty(cListRot)
	If Empty(cListProc)
		cWhereSRC := "%"
		cWhereSRD := "%"
	EndIf
	cWhereSRC += " SRC.RC_ROTEIR IN  (" + cListRot + ") AND "
	cWhereSRD += " SRD.RD_ROTEIR IN  (" + cListRot + ") AND "
EndIf


If cPagamento == "99".and. cUltSem > "01"
	cWhereSRC	+= " ( SRC.RC_PD <> '" + fGetCodFol("106") + "' OR SRC.RC_SEMANA = '01' ) AND "
	cWhereSRC	+= " ( SRC.RC_PD <> '" + fGetCodFol("015") + "' OR SRC.RC_SEMANA = '" + cUltSem + "' ) AND "
	cWhereSRD	+= " ( SRD.RD_PD <> '" + fGetCodFol("106") + "' OR SRD.RD_SEMANA = '01' ) AND "
	cWhereSRD	+= " ( SRD.RD_PD <> '" + fGetCodFol("015") + "' OR SRD.RD_SEMANA = '" + cUltSem + "' ) AND "
EndIf

If cPagamento # '99'
	cWhereSRC += " SRC.RC_SEMANA = '"+ cPagamento + "' AND "
	cWhereSRD += " SRD.RD_SEMANA = '"+ cPagamento + "' AND "
Else
	cWhereSRC += " SRC.RC_SEMANA <> '"+ cPagamento + "' AND "
	cWhereSRD += " SRD.RD_SEMANA <> '"+ cPagamento + "' AND "
EndIf

If lGper040
	cWhereSRD += " SRD.RD_EMPRESA = '  ' AND "
Else
	cWhereSRD += " (SRD.RD_EMPRESA = '" + Upper(cEmpAnt) + "' OR SRD.RD_EMPRESA = '  ' ) AND "
EndIf

cWhereSRC += "%"
cWhereSRD += "%"

cJoinView	:= "%%"
cCpoAdView	:= "%%"
cExtraC		:= "%%"
cExtraD		:= "%%"
cGroupEC	:= "%%"
cGroupED	:= "%%"

cJoinAux := "% " + FWJoinFilial("SRV", "SRC") + StrTran(cJoinView,"%","") + " %"
cJoinAux := StrTran(cJoinAux,"SRV.RV_FILIAL","RV_FILIAL")
cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

ApuraSit(cCpoDelim, cCpoViewG, cGroupED, cJoinAux, cFiltro, cPagamento, cRoteiro, cPeriodo, cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD, cExtraD , cGroupEC, cJoinC, cJoinD, ;
		cCpoAlsC, cExtraC,  cCpoView , cCpoAdView ,lRGPE019)

BEGIN REPORT QUERY oSectFunc
	//BEGIN QUERY cAliasQry
	BeginSql alias cAliasQry

		SELECT	tView.SALARIO, tView.PD, tView.QTDSEM,    tView.HORAS,  tView.VALOR,     tView.PROCES,
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoView%, tView.OCORR
		FROM
		(
			SELECT 	SUM(SRA.RA_SALARIO) SALARIO, SRC.RC_PD PD, SUM(SRC.RC_QTDSEM) QTDSEM, SUM(SRC.RC_HORAS) HORAS,
					SUM(SRC.RC_VALOR) VALOR,     SRC.RC_PROCES PROCES, SRC.RC_PERIODO PERIODO,
					SRC.RC_ROTEIR ROTEIR,        SRC.RC_FILIAL FILIAL	%exp:cExtraC%,
					SRA.%exp:cCpoAlsC%,
					count(SRC.rC_PD) OCORR
			FROM  %table:SRA% SRA
			INNER JOIN %table:SRC% SRC
			ON 		SRA.RA_FILIAL = SRC.RC_FILIAL %exp:cJoinC%
			WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
					SRC.RC_PERIODO = %exp:Upper(cPeriodo)%   AND 
					%exp:cWhereSRC%
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRC.%notDel%
			GROUP BY RC_QTDSEM, RC_PROCES, RC_PERIODO, RC_ROTEIR, %exp:cCpoDelimC%, RC_PD, RC_FILIAL %exp:cGroupEC%

			UNION ALL

			SELECT SUM(SRA.RA_SALARIO) SALARIO, SRD.RD_PD PD,SUM(SRD.RD_QTDSEM) QTDSEM,         SUM(SRD.RD_HORAS) HORAS,
					SUM(SRD.RD_VALOR) VALOR,     SRD.RD_PROCES PROCES, SRD.RD_PERIODO PERIODO,
					SRD.RD_ROTEIR ROTEIR,        SRD.RD_FILIAL FILIAL	%exp:cExtraD%,
					SRA.%exp:cCpoAlsD%,
					count(SRD.rD_PD) OCORR
			FROM  %table:SRA% SRA
			INNER JOIN %table:SRD% SRD
			ON 		SRA.RA_FILIAL = SRD.RD_FILIAL %exp:cJoinD%
			WHERE 	SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
					( ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA <= %exp:cDtPerFim% AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) ) OR
						( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA > %exp:cDtPerFim% AND ' ' IN (%exp:Upper(cSitQuery)%) ) OR
						( SRA.RA_SITFOLH <> 'D' AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) ) ) AND
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
					SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND 
					%exp:cWhereSRD%
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRD.%notDel%
			GROUP BY RD_PROCES, RD_PERIODO, RD_ROTEIR, RD_QTDSEM, %exp:cCpoDelimD%, RD_PD, RD_FILIAL %exp:cGroupED%

		) tView
		INNER JOIN	%table:SRV% SRVA
		ON			SRVA.RV_COD = tView.PD AND %exp:cJoinAux% AND SRVA.%notDel%
		GROUP BY tView.SALARIO, tView.PD,tView.QTDSEM, tView.HORAS,  tView.VALOR,     tView.PROCES,
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoViewG%, tView.OCORR
		ORDER BY %exp:cCpoDelim%, PD
	EndSql

//END cAliasQry
END REPORT QUERY oSectFunc
oSectLanc:SetParentQuery()
oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL == cParam},{||(cAliasQry)->RA_FILIAL})
cAliasFun	:= cAliasQry

//Carrega o aComp com os valores do periodo de compra��o
RGPE19COM()

//SELECIONA TABELA DE FUNCIONARIOS
dbSelectArea("SM0")
dbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

//DEFINE O TOTAL DA REGUA DA TELA DE PROCESSAMENTO DO RELATORIO
oReport:SetMeter(LastRec())

//oReport:OnPageBreak({||fGR019Header(oReport)}) //IMPRESSAO DO CABECALHO

//ALTERA O TITULO DO RELATORIO
oReport:SetTitle(cTitulo)

If nOrdem == 1 .Or. nOrdem == 2
	oSectFunc:Print()
ElseIf nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6
	If nAnaSin	== 1	//Analítico
		oSectCttc:Print()
	Else				//Sintético
		oSectFunc:Print()
	EndIf
ElseIf nOrdem == 7 .Or. nOrdem == 8
	If nAnaSin	== 1	//Analítico
		oSectDept:Print()
	Else				//Sintético
		oSectFunc:Print()
	EndIf
EndIf

If nAnaSin == 1 .AND. (oReport:nMeter > 0) //Apenas imprimir linha quando há dados no reltório.
	oReport:ThinLine()
	oReport:SkipLine()
EndIf

Return

/*
===============================================================================================================================
Programa--------: fImprimeLanca
Autor-----------: Jonathan Torioni
Data da Criacao-: 09/09/2020
===============================================================================================================================
Descri��o-------: Imprime os lancamentos da Folha de Pagamento
===============================================================================================================================
Parametros------: oSelf
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function fImprimeLanca(oSelf)
Local aArea		:= GetArea()
Local cPDB		:= ""	//Horas / Dias / Valores
Local nMax		:= 0	//Controle maximo de verbas por tipo
Local nMaxP		:= 0
Local nMaxD		:= 0
Local nMaxB		:= 0
Local nCta		:= 0
Local nCtaB		:= 0
Local lImprLine
Local lImpAux	:= .F.
Local aTemp		:= {}
Local nDescTam	:= 15
Local nTamCC	:=	TamSX3("RA_CC")[1]
Local aOrd		:= {}
Local lCCMov	:= ( nOrdem == 5 .Or. nOrdem == 6 )

If oSelf:cName == "LANCAMENTO"
	oSelf:oReport:SkipLine()
	If oSelf:lVisible == .T.
		oSelf:oReport:FatLine()
	ElseIf lSint
		nTotFunc++
	Endif
	lPrinOn	:= .T.
ElseIf oSelf:cName == "LANCAMENTO"
	If lPrinOn
		nDescTam := oSelf:Cell("DESCD" ):GetSize()

		//Impreme verba de desoneração
		If cFilAux <>  (cAliasFun)->RA_FILIAL .AND. cPaisLoc == "BRA"
			fTotIdFat((cAliasFun)->RA_FILIAL)
			If cRoteiro <> fGetCalcRot('5')
				fGPSVal((cAliasFun)->RA_FILIAL,cPeriodo,@aGPSVal,AllTrim(STR(nTpContr)))
			EndIf
			cFilAux :=  (cAliasFun)->RA_FILIAL
		EndIf

		oSelf:SetLineStyle(.F.)
		aLanP		:= {}
		aLanD		:= {}
		aLanB		:= {}
		aNomeFunc	:= {}

		While (cAliasQry)->(!Eof()) .And. (cAliasQry)->(FILIAL+MAT) == (cAliasFun)->(RA_FILIAL+RA_MAT) .And. ( !lCCMov .Or. (cAliasQry)->CCUSTO == (cAliasFun)->CTT_CUSTO )
			cPDB:=(cAliasQry)->RV_TIPOCOD
			if(Empty(aNomeFunc)) /*Apenas no primeiro registro*/
				aNomeFunc := (cAliasQry)->({RA_FILIAL,RA_MAT,RA_NOME})
			endIf

			Do Case/* aTemp guarda uma referência ao vetor que deve ser alterado.*/
				Case (cPDB == "1")
					aTemp := aLanP //Proventos
				Case (cPDB == "2")
					aTemp := aLanD //Descontos
				Case (cPDB $ "3/4" .And. (cAliasQry)->RV_IMPRIPD != "2")
					aTemp := aLanB //Bases
				OtherWise
					aTemp := Nil
			EndCase

			if(aTemp != Nil)
				If lSumaVerba .And. (nPos := aScan(aTemp,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aTemp[nPos,3] += If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S",(cAliasQry)->QTDSEM,(cAliasQry)->HORAS)
					aTemp[nPos,4] += (cAliasQry)->VALOR
				else
					(cAliasQry)->(aAdd(aTemp,{PD, Left(RV_DESC,nDescTam), iIf(QTDSEM > 0 .And. cIRefSem == "S", QTDSEM, HORAS), VALOR, SEQ, RV_IMPRIPD,INSS,FGTS,IR}))
				EndIf
			endIf

			(cAliasQry)->(DbSkip())
		EndDo

		nMaxP	:= Len(aLanP)
		nMaxD 	:= Len(aLanD)
		nMaxB 	:= Len(aLanB)
		nMax	:= MAX(MAX(nMaxP,nMaxD),nMaxB)

		aSort(aLanB,,,{ |x,y| x[6]+x[1] < y[6]+y[1]})
		lPrinOn := .F.
		nCtaB := 1
		oSelf:Init()

		For nCta :=1 to nMax
			lImprLine := .F.

			ConfCells(oSelf,nCta,'P',@lImprLine,aLanP)
			ConfCells(oSelf,nCta,'D',@lImprLine,aLanD)
			aOrd := GetCells(oSelf,"B")

			If nCta > nMaxB .OR. nCtaB > nMaxB
				oSelf:Cell(aOrd[VALORB]):SetPicture("")
				oSelf:Cell(aOrd[PDB]   ):SetValue("")	//"Cod."
				oSelf:Cell(aOrd[DESCB] ):SetValue("")	//"Descrição"
				oSelf:Cell(aOrd[VALORB]):SetValue("")	//"Valor"
				lImprLine := lImprLine .OR. .F.
			Else
				If nCta > nMaxB
					oSelf:Cell(aOrd[VALORB]):Hide()
					oSelf:Cell(aOrd[PDB]   ):Hide()
					oSelf:Cell(aOrd[DESCB] ):Hide()
					lImprLine := lImprLine .OR. .F.

					oSelf:Cell(aOrd[VALORB]):SetPicture("")
					oSelf:Cell(aOrd[PDB]   ):SetValue("")	//"Cod."
					oSelf:Cell(aOrd[DESCB] ):SetValue("")	//"Descrição"
					oSelf:Cell(aOrd[VALORB]):SetValue("")	//"Valor"
				Else
					If !lImpBase
						oSelf:Cell(aOrd[VALORB]):Hide()
						oSelf:Cell(aOrd[PDB]   ):Hide()
						oSelf:Cell(aOrd[DESCB] ):Hide()
						lImprLine := lImprLine .OR. .F.
					Else
						oSelf:Cell(aOrd[VALORB]):Show()
						oSelf:Cell(aOrd[PDB]   ):Show()
						oSelf:Cell(aOrd[DESCB] ):Show()
						lImprLine := .T.
					EndIf
					oSelf:Cell(aOrd[VALORB]):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell(aOrd[PDB]   ):SetValue(aLanB[nCta,1])	//"Cod."
					oSelf:Cell(aOrd[DESCB] ):SetValue(aLanB[nCta,2])	//"Descrição"
					oSelf:Cell(aOrd[VALORB]):SetValue(aLanB[nCta,4])	//"Valor"
				EndIf
			EndIf

			If nCta <= nMax
				If lImprLine
					oSelf:PrintLine()
				Endif
			EndIf

		Next nCta

		If lImpBase .and. lImpFil
		 	lImprLine := .F.
			If Len(aFilB) > 0
				//Imprime o total da verba 973 no primeiro funcionário, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)

					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()

					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
					oSelf:Cell("REFERP"):SetValue("")	//"Ref."
					oSelf:Cell("VALORP"):SetValue("")	//"Valor"

					oSelf:Cell("REFERD"):Hide()
					oSelf:Cell("VALORD"):Hide()
					oSelf:Cell("PDD"   ):Hide()
					oSelf:Cell("DESCD" ):Hide()
					oSelf:Cell("PIPED"):Hide()

					oSelf:Cell("REFERD"):SetPicture("")
					oSelf:Cell("VALORD"):SetPicture("")
					oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor"

					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide()
					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"Descrição"
					oSelf:Cell("VALORB"):SetValue(aFilB[nCta,3])	//"Valor"
					aFilB := {}
					lImprLine := .T.
				Next nCta
			EndIf
			//Imprime os totais de complemento da GPS
			If Len(aGPSVal) > 0
				lImpAux := .F.
				For nCta := 1 to Len(aGPSVal)
					If Substr(aGPSVAL[nCta,1],1,nTamCC) == (cAliasFun)->RA_CC .or. Empty(aGPSVAL[nCta,1])
						If lImprLine .or. lImpAux
							oSelf:PrintLine()
							lImprLine := .F.
						EndIf
						oSelf:Cell("REFERP"):Hide()
						oSelf:Cell("VALORP"):Hide()
						oSelf:Cell("PDP"   ):Hide()
						oSelf:Cell("DESCP" ):Hide()
						oSelf:Cell("PIPEP"):Hide()

						oSelf:Cell("REFERP"):SetPicture("")
						oSelf:Cell("VALORP"):SetPicture("")
						oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
						oSelf:Cell("REFERP"):SetValue("")	//"Ref."
						oSelf:Cell("VALORP"):SetValue("")	//"Valor"

						oSelf:Cell("REFERD"):Hide()
						oSelf:Cell("VALORD"):Hide()
						oSelf:Cell("PDD"   ):Hide()
						oSelf:Cell("DESCD" ):Hide()
						oSelf:Cell("PIPED"):Hide()

						oSelf:Cell("REFERD"):SetPicture("")
						oSelf:Cell("VALORD"):SetPicture("")
						oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor"

						//Não deve ser exibido para o funcionário, apenas no totalizador
						oSelf:Cell("VALORB"):Hide()
						oSelf:Cell("PDB"   ):Hide()
						oSelf:Cell("DESCB" ):Hide()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"Descrição"
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						lImpAux := .T.
						aGPSVal[nCta,5] := 0 //Zera para não ser duplicado no totalizador
					Endif
				Next nCta
			EndIf
		EndIf

		oSelf:Finish()
	EndIf
EndIf

RestArea(aArea)

Return .T.
/*
===============================================================================================================================
Programa--------: ConfCells
Autor-----------: Jonathan Torioni
Data da Criacao-: 09/09/2020
===============================================================================================================================
Descri��o-------: Confere a impress�o das celulas
===============================================================================================================================
Parametros------: oSection,nPos,cPostfix,lImprLine,aValues
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ConfCells(oSection,nPos,cPostfix,lImprLine,aValues)
	Local aReg := {}
	Local nI := 0
	Local aOrd	:= {}

	If cPostfix == "P"
		aOrd := GetCells(oSection,"P")
	ElseIf cPostfix == "D"
		aOrd := GetCells(oSection,"D")
	EndIf

	If nPos > Len(aValues)
		oSection:Cell(aOrd[REFER]):SetPicture("")
		oSection:Cell(aOrd[NVALOR]):SetPicture("")
		for nI:= 1 to Len(aOrd)
			oSection:Cell(aOrd[ni]):Hide()
			oSection:Cell(aOrd[ni]):SetValue("")
		next nI
		lImprLine := lImprLine .OR. .F.
	Else
		aReg := aValues[nPos]

		for nI:= 1 to Len(aOrd)
			oSection:Cell(aOrd[ni]):Show() //Exibe todas as celulas
		next nI

		oSection:Cell(aOrd[REFER]):SetPicture("@E 999,999.99")
		oSection:Cell(aOrd[NVALOR]):SetPicture("@E 99,999,999,999.99")
		oSection:Cell(aOrd[NPD]):SetValue(aReg[1])	//"Cod."
		oSection:Cell(aOrd[DESC]):SetValue(aReg[2])	//"Descrição"
		oSection:Cell(aOrd[REFER] ):SetValue(aReg[3])	//"Ref."
		oSection:Cell(aOrd[NVALOR]):SetValue(aReg[4])	//"Valor"
		oSection:Cell(aOrd[INSS]):SetValue(aReg[7])
		oSection:Cell(aOrd[FGTS]):SetValue(aReg[8])
		oSection:Cell(aOrd[IR]):SetValue(aReg[9])
		lImprLine := .T.
	EndIf
Return nil

Static Function GetCells(oSection,cPostfix)
	Local aCells := {'REFER','VALOR','PD','DESC','PIPE','INSS','FGTS','IR'}
	Local aCellsB := {'VALORB','PDB','DESCB'}
	Local aReg := {}
	Local nI := 0

	If cPostfix == "P"
		If Empty(aOrdemP)
			For nI:= 1 to Len(aCells)
				aadd(aReg,oSection:Cell(aCells[nI] + cPostfix):GetOrder())
			Next nI
			aOrdemP := aReg
		Else
			aReg := aOrdemP
		EndIf
	EndIf

	If cPostfix == "D"
		If Empty(aOrdemD)
			For nI:= 1 to Len(aCells)
				aadd(aReg,oSection:Cell(aCells[nI] + cPostfix):GetOrder())
			Next nI
			aOrdemD := aReg
		Else
			aReg := aOrdemD
		EndIf
	EndIf

	If cPostfix == "B"
		If Empty(aOrdemB)
			For nI:= 1 to Len(aCellsB)
				aadd(aReg,oSection:Cell(aCellsB[nI]):GetOrder())
			Next nI
			aOrdemB := aReg
		Else
			aReg := aOrdemB
		EndIf
	EndIf
Return aReg
/*
===============================================================================================================================
Programa--------: fImprSint
Autor-----------: Jonathan Torioni
Data da Criacao-: 09/09/2020
===============================================================================================================================
Descri��o-------: Imprime os lancamentos da Folha de Pagamento Sintetica
===============================================================================================================================
Parametros------: oSelf,lRGPE019
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function fImprSint(oSelf,lRGPE019)
Local aArea		:= GetArea()
Local cPDB		:= ""	//Horas / Dias / Valores
Local nMax		:= 0	//Controle maximo de verbas por tipo
Local nMaxP 	:= 0
Local nMaxD 	:= 0
Local nMaxB 	:= 0
Local nCta		:= 0
Local lImprLine
Local lImpAux	:= .F.
Local aLanP		:= {}
Local aLanD 	:= {}
Local aLanB 	:= {}
Local cCpoQbr	:= (cAliasQry)->(&(cCpoQuebra))
Local nTamCC	:=	TamSX3("RA_CC")[1]
Local nPerc 	:= 0
Local _aLidosP:= {}, _aLidosB:= {}, _aLidosD:= {}, _nI, _nJ, _nX, _nK, _nY
Local _aComplP:= {},_aComplB:= {}, _aComplD:= {}, _nLinCompB, _nLinCompD 

cDAnt := (cAliasQry)->FILIAL + IIf(Empty(cCpoQbr), "", cCpoQbr)

lcabecalho := .T.

If oSelf:cName != "LANCAMENTO"
	oSelf:oReport:SkipLine()
	//oSelf:oReport:ThinLine()//FatLine()
	lPrinOn	:= .T.
Else

	If lPrinOn

		//Imprime verba de desoneração
		If cFilAux <> (cAliasQry)->RA_FILIAL .AND. cPaisLoc == "BRA"
			fTotIdFat((cAliasQry)->RA_FILIAL)
			If cRoteiro <> fGetCalcRot('5')
				fGPSVal((cAliasQry)->RA_FILIAL,cPeriodo,@aGPSVal,AllTrim(STR(nTpContr)))
			EndIf
			cFilAux := (cAliasQry)->RA_FILIAL
		EndIf

		oSelf:lVisible := .T.
		oSelf:SetLineStyle(.F.)
		aLanP	:= {}
		aLanD  	:= {}
		aLanB 	:= {}

		While (cAliasQry)->(!Eof()) .And. ;
			cDAnt == (cAliasQry)->FILIAL + IIf(Empty((cAliasQry)->(&(cCpoQuebra))), "", (cAliasQry)->(&(cCpoQuebra)))

			cPDB:=(cAliasQry)->RV_TIPOCOD
			If cPDB == "1"
				If lSumaVerba .And. (nPos := aScan(aLanP,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aLanP[nPos,3] += If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S",(cAliasQry)->QTDSEM,(cAliasQry)->HORAS)
					aLanP[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanP,{						 ;
							(cAliasQry)->PD			,;
							(cAliasQry)->RV_DESC	,;
							iif(cIRefSem == 'S' .And. (cAliasQry)->QTDSEM > 0, (cAliasQry)->QTDSEM, iif( !lRGPE019 .Or. (lRGPE019 .and. cRefOco == 1), (cAliasQry)->HORAS, (cAliasQry)->OCORR ))		,;
							(cAliasQry)->VALOR		,;
							cFilAux})
					Aadd(_aLidosP,{"1",(cAliasQry)->PD})
				EndIf
			ElseIf cPDB == "2"
				If lSumaVerba .And. (nPos := aScan(aLanD,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aLanD[nPos,3] += If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S",(cAliasQry)->QTDSEM,(cAliasQry)->HORAS)
					aLanD[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanD,{						 ;
							(cAliasQry)->PD			,;
							(cAliasQry)->RV_DESC	,;
							iif(cIRefSem == 'S' .And. (cAliasQry)->QTDSEM > 0, (cAliasQry)->QTDSEM, iif( !lRGPE019 .Or. (lRGPE019 .and. cRefOco == 1), (cAliasQry)->HORAS, (cAliasQry)->OCORR ))		,;
							(cAliasQry)->VALOR		,;
							cFilAux})
							
							Aadd(_aLidosD,{"2",(cAliasQry)->PD})
				EndIf
			ElseIf cPDB $ "3/4" .And. (cAliasQry)->RV_IMPRIPD != "2"
				If lSumaVerba .And. (nPos := aScan(aLanB,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aLanB[nPos,3] += If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S",(cAliasQry)->QTDSEM,(cAliasQry)->HORAS)
					aLanB[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanB,{						 ;
							(cAliasQry)->PD 		,;
							(cAliasQry)->RV_DESC	,;
							iif(cIRefSem == 'S' .And. (cAliasQry)->QTDSEM > 0, (cAliasQry)->QTDSEM, iif( !lRGPE019 .Or. (lRGPE019 .and. cRefOco == 1), (cAliasQry)->HORAS, (cAliasQry)->OCORR ))		,;
							(cAliasQry)->VALOR		,;
							cFilAux})
																												
					Aadd(_aLidosB,{cPDB,(cAliasQry)->PD})
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

        _aComplP := U_RGPE019C(_aLidosP, aComp, "P")
		_aComplD := U_RGPE019C(_aLidosD, aComp, "D")
        _aComplB := U_RGPE019C(_aLidosB, aComp, "B")

//COLOCAR ARRAYS DE ITENS A MAIS DO OUTRO MES NA MESMA ARRAY DE IMPRESSAO PARA ORDERNAR
        FOR nCta := 1 TO LEN(_aComplP)
	        AADD(aLanP,{_aComplP[nCta,2] ,"*"+_aComplP[nCta,11] ,_aComplP[nCta,3], 0 ,_aComplP[nCta,9] })
		Next
        FOR nCta := 1 TO LEN(_aComplD)
	        AADD(aLanD,{_aComplD[nCta,2] ,"*"+_aComplD[nCta,11] ,_aComplD[nCta,3], 0 ,_aComplD[nCta,9] })
		Next
        FOR nCta := 1 TO LEN(_aComplB)
		    AADD(aLanB,{_aComplB[nCta,2] ,"*"+_aComplB[nCta,11] , 0 , 0 ,_aComplB[nCta,9] })
		Next
		ASORT(aLanP,,, { | x,y | x[1] < y[1] })
		ASORT(aLanD,,, { | x,y | x[1] < y[1] })
		ASORT(aLanB,,, { | x,y | x[1] < y[1] })
//COLOCAR ARRAYS DE ITENS A MAIS DO OUTRO MES NA MESMA ARRAY DE IMPRESSAO PARA ORDERNAR

//LIMPA AS ARRAYS PARA N�O ENTRAR NOS TRATAMENTOS DE IMPRESSAO DELAS ABAIXO QUE FOI DESCONTINUADO
        _aComplP:={}
		_aComplB:={}
		_aComplD:={}

		_nLinCompB := Len(_aComplB)
        _nLinCompD := Len(_aComplD)
		If _nLinCompB > 0
		   _nI := 1
		Else 
           _nI := 0
		EndIf
		If _nLinCompD > 0
		   _nJ := 1
		Else
		   _nJ := 0
		Endif

		_nX := MAX(_nLinCompB,_nLinCompD)
//------------------------------------------------------------------
		nMaxP	:= Len(aLanP)
		nMaxD 	:= Len(aLanD)
		nMaxB 	:= Len(aLanB)
		nMax	:= MAX(MAX(nMaxP,nMaxD),nMaxB)
		lPrinOn := .F.

		oSelf:Init()

		oSelf:Cell("REFERP"):Show()
		oSelf:Cell("VALORP"):Show()
		oSelf:Cell("PDP"   ):Show()
		oSelf:Cell("DESCP" ):Show()
		oSelf:Cell("PIPEP"):Show()

		oSelf:Cell("REFERD"):Show()
		oSelf:Cell("VALORD"):Show()
		oSelf:Cell("PDD"   ):Show()
		oSelf:Cell("DESCD" ):Show()
		oSelf:Cell("PIPED"):Show()

		oSelf:Cell("VALORB"):Show()
		oSelf:Cell("PDB"   ):Show()
		oSelf:Cell("DESCB" ):Show()

		For nCta :=1 to nMax
			If nCta > nMaxP

				oSelf:Cell("REFERP"):SetPicture("")
				oSelf:Cell("VALORP"):SetPicture("")
				oSelf:Cell("PERCENTUALP"):SetPicture("")
				oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
				oSelf:Cell("REFERP"):SetValue("")	//"Ref."
				oSelf:Cell("VALORP"):SetValue("")	//"Valor"
				oSelf:Cell("VALORPCOM"):SetValue("")	//"Valor"
				oSelf:Cell("PERCENTUALP"):SetValue("")	//"Valor"

		    Else
				nPerc :=  IIF(aLanP[nCta,4] == 0 .OR. RGPE19RET(aLanP[nCta,5], aLanP[nCta,1]) == 0, 100, ((aLanP[nCta,4]/RGPE19RET(aLanP[nCta,5], aLanP[nCta,1]))-1)*100)
				oSelf:Cell("REFERP"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORP"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PERCENTUALP"):SetPicture("@E 999.999")
				oSelf:Cell("PDP"   ):SetValue(aLanP[nCta,1])	//"Cod."
				oSelf:Cell("DESCP" ):SetValue(aLanP[nCta,2])	//"Descrição"
				oSelf:Cell("REFERP"):SetValue(aLanP[nCta,3])	//"Ref."
				oSelf:Cell("VALORP"):SetValue(aLanP[nCta,4])	//"Valor"
				oSelf:Cell("VALORPCOM"):SetValue(RGPE19RET(aLanP[nCta,5], aLanP[nCta,1]))	//"Valor"
				oSelf:Cell("PERCENTUALP"):SetValue(nPerc)
			EndIf
			If nCta > nMaxD
//-----------------------------------------------------------------impimir resto d aqui
                If _nJ > 0 .And. _nJ <= _nLinCompD 
				   oSelf:Cell("REFERD"):SetPicture("@E 999,999.99")
				   oSelf:Cell("VALORD"):SetPicture("@E 99,999,999,999.99")
				   oSelf:Cell("PERCENTUALD"):SetPicture("@E 999.999")
				   oSelf:Cell("PDD"   ):SetValue(_aComplD[_nJ,2])	//"Cod."
				   oSelf:Cell("DESCD" ):SetValue(_aComplD[_nJ,11])	//"Descrição"
				   oSelf:Cell("REFERD"):SetValue(_aComplD[_nJ,3])	//"Ref."
				   oSelf:Cell("VALORD"):SetValue(0)	//"Valor"
				   oSelf:Cell("VALORDCOM"):SetValue(_aComplD[_nJ,5])	//"Valor"
				   oSelf:Cell("PERCENTUALD"):SetValue(0)
                   _nJ += 1
		        Else 
				   oSelf:Cell("REFERD"):SetPicture("")
				   oSelf:Cell("VALORD"):SetPicture("")
   				   oSelf:Cell("PERCENTUALD"):SetPicture("")
				   oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
				   oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
				   oSelf:Cell("REFERD"):SetValue("")	//"Ref."
				   oSelf:Cell("VALORD"):SetValue("")	//"Valor"
				   oSelf:Cell("VALORDCOM"):SetValue("")	//"Valor"
				   oSelf:Cell("PERCENTUALD"):SetValue("")
				EndIf 
			Else
				nPerc :=  IIF(aLanD[nCta,4] == 0 .OR. RGPE19RET(aLanD[nCta,5], aLanD[nCta,1]) == 0, 100, ((aLanD[nCta,4]/RGPE19RET(aLanD[nCta,5], aLanD[nCta,1]))-1)*100)
				oSelf:Cell("REFERD"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORD"):SetPicture("@E 99,999,999,999.99")
			    oSelf:Cell("PERCENTUALD"):SetPicture("@E 999.999")
				oSelf:Cell("PDD"   ):SetValue(aLanD[nCta,1])	//"Cod."
				oSelf:Cell("DESCD" ):SetValue(aLanD[nCta,2])	//"Descrição"
				oSelf:Cell("REFERD"):SetValue(aLanD[nCta,3])	//"Ref."
				oSelf:Cell("VALORD"):SetValue(aLanD[nCta,4])	//"Valor"
				oSelf:Cell("VALORDCOM"):SetValue(RGPE19RET(aLanD[nCta,5], aLanD[nCta,1]))	//"Valor"
				oSelf:Cell("PERCENTUALD"):SetValue(nPerc)
			EndIf
			If nCta > nMaxB
//------------------------------ impimir resto b aqui.			
               If _nI > 0 .And. _nI <= _nLinCompB
                  oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
			      oSelf:Cell("VALORBCOM"):SetPicture("@E 99,999,999,999.99")
  				  oSelf:Cell("PERCENTUALB"):SetPicture("@E 999.999")
				  oSelf:Cell("PDB"   ):SetValue(_aComplB[_nI,2])	//"Cod."
				  oSelf:Cell("DESCB" ):SetValue(_aComplB[_nI,11])	//"Descrição"
				  oSelf:Cell("VALORB"):SetValue(0)	//"Valor"
				  oSelf:Cell("VALORBCOM"):SetValue(_aComplB[_nI,5])	//"Valor"
				  oSelf:Cell("PERCENTUALB"):SetValue(0)
                  _nI += 1
		       Else 
			      oSelf:Cell("VALORB"):SetPicture("")
			      oSelf:Cell("VALORBCOM"):SetPicture("")
				  oSelf:Cell("PERCENTUALB"):SetPicture("")
				  oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
				  oSelf:Cell("DESCB" ):SetValue("")	//"Descrição"
				  oSelf:Cell("VALORB"):SetValue("")	//"Valor"
				  oSelf:Cell("VALORBCOM"):SetValue("")	//"Valor"
				  oSelf:Cell("PERCENTUALB"):SetValue("")
			   EndIf 
			Else
			 	If !lImpBase
					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("VALORBCOM"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide()
				EndIf
				nPerc :=  IIF(aLanB[nCta,4] == 0 .OR. RGPE19RET(aLanB[nCta,5], aLanB[nCta,1]) == 0, 100, ((aLanB[nCta,4]/RGPE19RET(aLanB[nCta,5], aLanB[nCta,1]))-1)*100)
				oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("VALORBCOM"):SetPicture("@E 99,999,999,999.99")
			    oSelf:Cell("PERCENTUALB"):SetPicture("@E 999.999")
				oSelf:Cell("PDB"   ):SetValue(aLanB[nCta,1])	//"Cod."
				oSelf:Cell("DESCB" ):SetValue(aLanB[nCta,2])	//"Descrição"
				oSelf:Cell("VALORB"):SetValue(aLanB[nCta,4])	//"Valor"
				oSelf:Cell("VALORBCOM"):SetValue(RGPE19RET(aLanB[nCta,5], aLanB[nCta,1]))	//"Valor"
				oSelf:Cell("PERCENTUALB"):SetValue(nPerc)
			EndIf
			If nCta <= nMax
				oSelf:PrintLine()
			EndIf
		Next nCta
	   
	    //oSelf:oReport:SkipLine()

        If _nX > 0 .AND. (_nX <= _nI .Or. _nX <= _nJ )
		   _nK := Min(_nI, _nJ)
		   For _nY := _nK To _nX
               If _nJ > 0 .And. _nJ <= _nLinCompD 
				   oSelf:Cell("REFERD"):SetPicture("@E 999,999.99")
				   oSelf:Cell("VALORD"):SetPicture("@E 99,999,999,999.99")
				   oSelf:Cell("PERCENTUALD"):SetPicture("@E 999.999")
				   oSelf:Cell("PDD"   ):SetValue(_aComplD[_nJ,2])	//"Cod."
				   oSelf:Cell("DESCD" ):SetValue(_aComplD[_nJ,11])	//"Descrição"
				   oSelf:Cell("REFERD"):SetValue(_aComplD[_nJ,3])	//"Ref."
				   oSelf:Cell("VALORD"):SetValue(0)	//"Valor"
				   oSelf:Cell("VALORDCOM"):SetValue(_aComplD[_nJ,5])	//"Valor"
				   oSelf:Cell("PERCENTUALD"):SetValue(0)
                   _nJ += 1
			   Else 
                   oSelf:Cell("REFERD"):SetPicture("")
				   oSelf:Cell("VALORD"):SetPicture("")
				   oSelf:Cell("PERCENTUALD"):SetPicture("")
				   oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
				   oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
				   oSelf:Cell("REFERD"):SetValue("")	//"Ref."
				   oSelf:Cell("VALORD"):SetValue("")	//"Valor"
				   oSelf:Cell("VALORDCOM"):SetValue("")	//"Valor"
				   oSelf:Cell("PERCENTUALD"):SetValue("")
               EndIf

               If _nI > 0 .And. _nI <= _nLinCompB
                  oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
			      oSelf:Cell("VALORBCOM"):SetPicture("@E 99,999,999,999.99")
				  oSelf:Cell("PERCENTUALB"):SetPicture("@E 999.999")
				  oSelf:Cell("PDB"   ):SetValue(_aComplB[_nI,2])	//"Cod."
				  oSelf:Cell("DESCB" ):SetValue(_aComplB[_nI,11])	//"Descrição"
				  oSelf:Cell("VALORB"):SetValue(0)	//"Valor"
				  oSelf:Cell("VALORBCOM"):SetValue(_aComplB[_nI,5])	//"Valor"
				  oSelf:Cell("PERCENTUALB"):SetValue(0)
                  _nI += 1
			   Else 
			      oSelf:Cell("VALORB"):SetPicture("")
			      oSelf:Cell("VALORBCOM"):SetPicture("")
				  oSelf:Cell("PERCENTUALB"):SetPicture("")
				  oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
				  oSelf:Cell("DESCB" ):SetValue("")	//"Descrição"
				  oSelf:Cell("VALORB"):SetValue("")	//"Valor"
				  oSelf:Cell("VALORBCOM"):SetValue("")	//"Valor"
				  oSelf:Cell("PERCENTUALB"):SetValue("")
               EndIf 

			   oSelf:PrintLine()

           Next 
        EndIf 

	   // oSelf:oReport:SkipLine()

		If lImpBase .and. lImpFil
			If Len(aFilB) > 0
				//Imprime o total da verba 973 no primeiro funcionário, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)

					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()

					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
					oSelf:Cell("REFERP"):SetValue("")	//"Ref."
					oSelf:Cell("VALORP"):SetValue("")	//"Valor"

					oSelf:Cell("REFERD"):Hide()
					oSelf:Cell("VALORD"):Hide()
					oSelf:Cell("PDD"   ):Hide()
					oSelf:Cell("DESCD" ):Hide()
					oSelf:Cell("PIPED"):Hide()

					oSelf:Cell("REFERD"):SetPicture("")
					oSelf:Cell("VALORD"):SetPicture("")
					oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor"

					If nOrdem == 1 .or. nOrdem == 2
						oSelf:Cell("VALORB"):Show()
						oSelf:Cell("PDB"   ):Show()
						oSelf:Cell("DESCB" ):Show()
					Else
						oSelf:Cell("VALORB"):Hide()
						oSelf:Cell("PDB"   ):Hide()
						oSelf:Cell("DESCB" ):Hide()
					EndIf

					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"Descrição"
					oSelf:Cell("VALORB"):SetValue(aFilB[nCta,3])	//"Valor"
					aFilB := {}
					lImprLine := .T.
				Next nCta
			EndIf
			//Imprime os totais de complemento da GPS
			If Len(aGPSVal) > 0
				lImpAux := .F.
				For nCta := 1 to Len(aGPSVal)
					If ( nOrdem >= 3 .And. nOrdem <= 6 )
						If Substr(aGPSVAL[nCta,1],1,nTamCC) == cCpoQbr .or. Empty(aGPSVAL[nCta,1])
							If lImprLine .or. lImpAux
								oSelf:PrintLine()
								lImprLine := .F.
							EndIf
							oSelf:Cell("REFERP"):Hide()
							oSelf:Cell("VALORP"):Hide()
							oSelf:Cell("PDP"   ):Hide()
							oSelf:Cell("DESCP" ):Hide()
							oSelf:Cell("PIPEP"):Hide()

							oSelf:Cell("REFERP"):SetPicture("")
							oSelf:Cell("VALORP"):SetPicture("")
							oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
							oSelf:Cell("REFERP"):SetValue("")	//"Ref."
							oSelf:Cell("VALORP"):SetValue("")	//"Valor"

							oSelf:Cell("REFERD"):Hide()
							oSelf:Cell("VALORD"):Hide()
							oSelf:Cell("PDD"   ):Hide()
							oSelf:Cell("DESCD" ):Hide()
							oSelf:Cell("PIPED"):Hide()

							oSelf:Cell("REFERD"):SetPicture("")
							oSelf:Cell("VALORD"):SetPicture("")
							oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
							oSelf:Cell("REFERD"):SetValue("")	//"Ref."
							oSelf:Cell("VALORD"):SetValue("")	//"Valor"

							oSelf:Cell("VALORB"):Show()
							oSelf:Cell("PDB"   ):Show()
							oSelf:Cell("DESCB" ):Show()
							oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
							oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
							oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"Descrição"
							oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
							lImpAux := .T.
						EndIf
					Else
						If lImprLine .or. lImpAux
							oSelf:PrintLine()
							lImprLine := .F.
						EndIf
						oSelf:Cell("REFERP"):Hide()
						oSelf:Cell("VALORP"):Hide()
						oSelf:Cell("PDP"   ):Hide()
						oSelf:Cell("DESCP" ):Hide()
						oSelf:Cell("PIPEP"):Hide()

						oSelf:Cell("REFERP"):SetPicture("")
						oSelf:Cell("VALORP"):SetPicture("")
						oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
						oSelf:Cell("REFERP"):SetValue("")	//"Ref."
						oSelf:Cell("VALORP"):SetValue("")	//"Valor"

						oSelf:Cell("REFERD"):Hide()
						oSelf:Cell("VALORD"):Hide()
						oSelf:Cell("PDD"   ):Hide()
						oSelf:Cell("DESCD" ):Hide()
						oSelf:Cell("PIPED"):Hide()

						oSelf:Cell("REFERD"):SetPicture("")
						oSelf:Cell("VALORD"):SetPicture("")
						oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor"

						oSelf:Cell("VALORB"):Show()
						oSelf:Cell("PDB"   ):Show()
						oSelf:Cell("DESCB" ):Show()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(fDesc("SRV", aGPSVal[nCta,2], "RV_DESC"))	//"Descrição"
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						lImpAux := .T.
					EndIf
				Next nCta
			EndIf
		EndIf

//PARA N�O DUPLICAR UMA LINHA PRENCHIDA
          oSelf:Cell("VALORP"):SetPicture("@!")
          oSelf:Cell("VALORPCOM"):SetPicture("@!")
          oSelf:Cell("PERCENTUALP"):SetPicture("@!")
		  oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
		  oSelf:Cell("DESCP" ):SetValue("")	//"Descrição"
		  oSelf:Cell("REFERP"):SetValue("")	//"Ref."
		  oSelf:Cell("VALORP"):SetValue("")	//"Valor"
		  oSelf:Cell("VALORPCOM"):SetValue("")	//"Valor"
		  oSelf:Cell("PERCENTUALP"):SetValue("")  
		  
          oSelf:Cell("VALORD"):SetPicture("@!")
          oSelf:Cell("VALORDCOM"):SetPicture("@!")
          oSelf:Cell("PERCENTUALD"):SetPicture("@!")
		  oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
		  oSelf:Cell("DESCD" ):SetValue("")	//"Descrição"
		  oSelf:Cell("REFERD"):SetValue("")	//"Ref."
		  oSelf:Cell("VALORD"):SetValue("")	//"Valor"
		  oSelf:Cell("VALORDCOM"):SetValue("")	//"Valor"
		  oSelf:Cell("PERCENTUALD"):SetValue("")

          oSelf:Cell("VALORB"):SetPicture("@!")
          oSelf:Cell("VALORBCOM"):SetPicture("@!")
          oSelf:Cell("PERCENTUALB"):SetPicture("@!")
		  oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
		  oSelf:Cell("DESCB" ):SetValue("")	//"Descrição"
		  oSelf:Cell("VALORB"):SetValue("")	//"Valor"
		  oSelf:Cell("VALORBCOM"):SetValue("")	//"Valor"
		  oSelf:Cell("PERCENTUALB"):SetValue("")
          oSelf:PrintLine()
//PARA N�O DUPLICAR UMA LINHA PRENCHIDA

		oSelf:Finish()
	Else

		If nAnaSin == 1
			oSelf:lVisible := .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*
===============================================================================================================================
Programa----------: fGR019join
Autor-------------: Jonathan Torioni
Data da Criacao---: 09/09/2020
===============================================================================================================================
Descri��o---------: O tratamento a seguir deve-se ao problema do embedded SQL
===============================================================================================================================
Parametros--------: cTabela1 - Obrigatorio - Variável com Primeira tabela do "inner join"   
					cTabela2 - Obrigatorio - Variável com Segunda  tabela do "inner join"   
					cEmbedded - Variável indica se retorno deverá conter "%   %"
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function fGR019join(cTabela1, cTabela2,cEmbedded)
Local cFiltJoin := ""
Default cEmbedded := ""

cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded

If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
EndIf

Return (cFiltJoin)

/*
===============================================================================================================================
Programa----------: fGR019Header
Autor-------------: Jonathan Torioni
Data da Criacao---: 09/09/2020
===============================================================================================================================
Descri��o---------: Realiza a quebra de linha do relat�rio
===============================================================================================================================
Parametros--------: oReport
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function fGR019Header(oReport)
	oReport:SkipLine()
	oReport:PrintText(" ")
	oReport:SkipLine()
Return

/*
===============================================================================================================================
Programa----------: fTotIdFat
Autor-------------: Jonathan Torioni
Data da Criacao---: 09/09/2020
===============================================================================================================================
Descri��o---------: Totaliza os registros ref. verba id 973 no relatio folha
===============================================================================================================================
Parametros--------: oReport
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fTotIdFat(cFilAux)

Local aArea			:= GetArea()
Local aTabS033		:= {}
Local cRecFatEmp	:= ""
Local cVb973		:= ""
Local cCodEmpDes	:= ""
Local lGera			:= .F.
Local lRecDesTot	:= .F.
Local nCont		    := 0
Local nFatFol		:= 0
Local nEmpFatTot	:= 0
Local nEmpFatDes	:= 0
Local nEmpFatFol	:= 0
Local nPos			:= 0
Local nProp			:= 0
Local nTpc			:= 0
Local nTotCont		:= 0
Local cMesAnoOne	:= If (Type("P_FDESFOL") # "U", P_FDESFOL, "")

Private aInssEmp[24][2]

aFilB := {}

If lRatDes
	Return
EndIf

If Funname() == "R019REL" .And. !Empty(cMesAnoOne)
	//Se for chamado pelo GPER040 e a empresa não for mais desonerada não gera no relatório o ID 0973
	If MV_PAR03 > cMesAnoOne
		Return(Nil)
	Endif
Endif

If !fInssEmp(cFilAux,@aInssEmp,,cPeriodo)
	Return
EndIf

//Verifica se a empresa efetua recolhimento da contribuicao patronal s/ o faturamento
For nTpc := 1 To Len( aInssEmp[27] )
	cRecFatEmp	:= aInssEmp[27, nTpc]//X14_RECFAT
	If cRecFatEmp $ "S*M*C"
		Exit
	EndIf
Next nTpc

cCodEmpDes	:= FwCodEmp()

//Chama fCarrTab para carregar tabela auxiliar S033
fRetTab( @aTabS033, "S033", , , StoD(cPeriodo+"01"), , .T., cFilAux, .T. )

For nCont := 1 To Len(aTabS033)
	If lCorpManage .And. lEmpFil .And. cCodEmpDes != SubStr( aTabS033[nCont, 2], nStartEmp, nEmpLength )
		Loop
	EndIf
	//Apura a receita bruta total da empresa
	nEmpFatTot += aTabS033[nCont, 7]
	If aTabS033[nCont, 6] == "1"
		//Apura a receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
		nEmpFatDes += aTabS033[nCont, 7]
	Else
		//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
		nEmpFatFol += aTabS033[nCont, 7]
	EndIf
Next nCont

//Verifica se a receita desonerada da empresa e' superior a 95% do total
lRecDesTot := ( nEmpFatDes / nEmpFatTot >= 0.95 )
/*
====================================================================
³Somente havera recolhimento sobre o Faturamento se o total nao³
³desonerado da empresa for MENOR que 95% do total geral        ³
====================================================================*/
lGera := ( cRecFatEmp == "M" .And. ( nEmpFatFol / nEmpFatTot ) < 0.95 )

If lGera .Or. cRecFatEmp $ "S*C"

	//Se a empresa efetua a contribucao s; o faturamento ou misto, verifica se existe o ID 973
	If cRecFatEmp $ "S*M*C"
		cVb973 := fGetCodFol("973")//INSS Empresa s/ Faturamento
        //Verifica se a receita desonerada da empresa e' superior a 95% do total
		If !Empty(cVb973)
			If cRecFatEmp != "S" .And. lRecDesTot
				For nCont := 1 To Len(aTabS033)
					If cFilAux + "1" == aTabS033[nCont, 2] + aTabS033[nCont, 6]
						//Apura o total da contribuicao previdenciaria da filial processada sobre as atividades desonerdas
						nTotCont += aTabS033[nCont, 9]
					ElseIf cFilAux + "2" == aTabS033[nCont, 2] + aTabS033[nCont, 6] .And. aTabS033[nCont, 10] > 0
						//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
						nFatFol += aTabS033[nCont, 7]
					EndIf
				Next nCont
			    //Se a receita bruta da atividade desonerada for maior do que 95% do total devera ser
			    //considerado a receita bruta da atividade nao desonerada.Sera aplicado a proporcionalidade
			    //das aliquotas das atividades desoneradas conforme correspondencia do percentual da receita
			    //desonerada em relacao ao total desonerado
			    //Ex: Cod de atividade X possui receita bruta de 45.000 com aliquota de 1%. A receita bruta
			    //    total de atividade desonerada e' igual a 98.000 e ha 2.000 de atividade nao desonerada.
			    //	  Sera feito a regra de 3 para saber quanto da receita bruta da atividade corresponde
			    //    ao total desonerado. Percentual = 45.000 * 100 / 98.000 = 45,91%. O percentual sera
			    //    aplicado sobre os 2.000 da receita nao desonerada. Sobre o valorencontrado sera
			    //	  aplicado a aliquota correspondente ao codigo da atividade. Esse valor sera somado ao
			    //    que a empresa ja recolhe de contribuicao sobre a atividade desonerada.
				For nCont := 1 To Len(aTabS033)
					If lCorpManage .And. lEmpFil .And. cCodEmpDes != SubStr( aTabS033[nCont, 2], nStartEmp, nEmpLength )
						Loop
					EndIf
					If aTabS033[nCont, 6] == "1"
						//Apura a receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
						nBasDes := aTabS033[nCont, 7]

						nProp := ( nBasDes / nEmpFatTot )
						nTotCont += ( nProp * nFatFol ) * ( aTabS033[nCont, 8] / 100 )
					EndIf
				Next nCont
			Else
				//Apura o total da contribuicao previdenciaria da filial processada sobre as atividades desoneradas
				For nCont := 1 To Len(aTabS033)
					If cFilAux + "1" == aTabS033[nCont, 2] + aTabS033[nCont, 6]
						nTotCont += aTabS033[nCont, 9]
					EndIf
				Next nCont
			EndIf
		EndIf
	EndIf

	//Se houve faturamento no periodo e existe a verba com Id 973 cadastrada,
	//adiciona os valores no array de totalizacao
	If nTotCont > 0 .And. !Empty( cVb973 )
		If ( nPos := aScan( aFilB,{|X| x[1] == cVb973 } ) ) == 0
			aAdd( aFilB, { cVb973, fDesc("SRV", cVb973, "RV_DESC"), nTotCont} )
		Else
			aFilB[nPos, 3] += nTotCont
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return(Nil)


/*/{Protheus.doc} fAjustFil
Filtra pelas filiais que o usuário tem acesso.
@Type Function
@author Gabriel Almeida
@since 13/09/2016
@version 2.0
@return cRet, string com as filiais que o usuário possui acesso.
/*/

/*
===============================================================================================================================
Programa----------: fAjustFil
Autor-------------: Jonathan Torioni
Data da Criacao---: 09/09/2020
===============================================================================================================================
Descri��o---------: Filtra pelas filiais que o usuário tem acesso.
===============================================================================================================================
Parametros--------: lRGPE019
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fAjustFil(lRGPE019)

	Local cRet      := " RA_FILIAL IN( "
	Local cFiltFil  := "%" + AllTrim(MV_PAR05) + "%"
	Local cAliasQry := GetNextAlias()
	Local cFilPerm  := fValidFil()

	If lRGPE019
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel% AND
			RA_FILIAL BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
		EndSql
	ElseIf cFiltFil <> "%%"
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel% AND
			%Exp:cFiltFil%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel%
		EndSql
	EndIf

	DbSelectArea(cAliasQry)
	(cAliasQry)->( DbGoTop() )

	While !( (cAliasQry)->( EOF() ) )
		If (cAliasQry)->FILIAL $ cFilPerm
			cRet += " '" + (cAliasQry)->FILIAL + "', "
		EndIf
		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->( DbCloseArea() )

	cRet += " '' )"

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FSubst        ³ Autor ³ Cristina Ogura   ³ Data ³ 17/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que substitui os caracteres especiais por espacos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSubst()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*
===============================================================================================================================
Programa----------: FSubst
Autor-------------: Jonathan Torioni
Data da Criacao---: 09/09/2020
===============================================================================================================================
Descri��o---------: Funcao que substitui os caracteres especiais por espacos/
===============================================================================================================================
Parametros--------: cTexto
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function FSubst(cTexto)
Local aAcentos:={}
Local aAcSubst:={}
Local cImpCar := Space(01)
Local cImpLin :=""
Local cAux 	  :=""
Local cAux1	  :=""
Local nTamTxt := Len(cTexto)
Local j
Local nPos

//=========================================================================================
// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho  |
// maximo possivel para visualizacao dos mesmos.                                          |
// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).     |
//=========================================================================================
aAcentos :=	{;
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252),".";
			}

aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u"," ";
			}

For j:=1 To Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)

	//==============================================
	//  Nao pode sair com 2 espacos em branco.     |
	//==============================================
	cAux	:=Space(01)
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar
Next j

//=============================================
// Volta o texto no tamanho original         |
//=============================================
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return(cImpLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ApuraSit        ³ Autor ³ Oswaldo L.   ³ Data ³ 07/10/17   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Identifica situacao dos funcionarios - SINTETICO          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*
===============================================================================================================================
Programa----------: ApuraSit
Autor-------------: Jonathan Torioni
Data da Criacao---: 09/09/2020
===============================================================================================================================
Descri��o---------: Identifica situacao dos funcionarios
===============================================================================================================================
Parametros--------: Sit(cCpoDelim, cCpoViewG, cGroupED,  cJoinAux,  cFiltro,   cPagamento, cRoteiro, 
    cPeriodo,  cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD,   cExtraD , 
    cGroupEC,  cJoinC,    cJoinD,    cCpoAlsC,  cExtraC,   cCpoView ,  cCpoAdView, ,lRGPE019
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ApuraSit(cCpoDelim, cCpoViewG, cGroupED,  cJoinAux,  cFiltro,   cPagamento, cRoteiro, ;
                         cPeriodo,  cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD,   cExtraD , ;
                         cGroupEC,  cJoinC,    cJoinD,    cCpoAlsC,  cExtraC,   cCpoView ,  cCpoAdView ,lRGPE019)
Local aSitFunc 	:= {}
Local nInd     	:= 0
Local nInd2    	:= 0
Local nInd3    	:= 0
Local nInd4    	:= 0
Local cWhere1	:= "%%"
Local cWhere2	:= "%%"
Local lSit106	:= ExistBlock("SitFol106")

DEFAULT lRGPE019 := .F.

BeginSql alias cSitAliasQry

	SELECT	tView.FILIAL, tView.MAT, tView.CC

	FROM
	(
		SELECT 	SRA.RA_FILIAL FILIAL, SRA.RA_MAT MAT , SRA.RA_CC CC

		FROM  %table:SRA% SRA
		INNER JOIN %table:SRC% SRC
		ON 		SRA.RA_MAT    = SRC.RC_MAT AND
			SRA.RA_FILIAL = SRC.RC_FILIAL %exp:cJoinC%
		WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
				SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND
				%exp:cWhereSRC%
				SRA.%notDel% %exp:Upper(cFiltro)% AND SRC.%notDel%
				%exp:cWhere1%

		GROUP BY SRA.RA_FILIAL, SRA.RA_MAT  , SRA.RA_CC

		UNION ALL

		SELECT SRA.RA_FILIAL FILIAL, SRA.RA_MAT MAT , SRA.RA_CC CC

		FROM  %table:SRA% SRA
			INNER JOIN %table:SRD% SRD
	ON 		SRA.RA_MAT    = SRD.RD_MAT AND
			SRA.RA_FILIAL = SRD.RD_FILIAL %exp:cJoinD%
		WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
				SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND
				%exp:cWhereSRD%
				SRA.%notDel% %exp:Upper(cFiltro)% AND SRD.%notDel%
				%exp:cWhere2%

		GROUP BY SRA.RA_FILIAL, SRA.RA_MAT , SRA.RA_CC

	) tView

	GROUP BY tView.FILIAL, tView.MAT, tView.CC
EndSql

aSintTot  := {}
aSintEM   := {}
aSintUN   := {}
aSintCC   := {}
aSintSits := {}
aSintEmp  := {0,0,0,0,0}

While (cSitAliasQry)->(!Eof())

	If aScan(aSintSits, {|x| x[1] == (cSitAliasQry)->(FILIAL) .And. x[2] == (cSitAliasQry)->(MAT) }) == 0

		AAdd ( aSintSits, {(cSitAliasQry)->(FILIAL),(cSitAliasQry)->(MAT)} )

		If aScan(aSintTot, {|x| x[1] == AllTrim((cSitAliasQry)->(FILIAL))  }) == 0
			AAdd ( aSintTot , {Alltrim((cSitAliasQry)->(FILIAL)),0,0,0,0,0}  )
		EndIf

		If lCorpManage
			If aScan(aSintUN, {|x| x[1] == substr((cSitAliasQry)->(FILIAL), nStartUnN, nUnNLength)   }) == 0
				AAdd ( aSintUN , {substr((cSitAliasQry)->(FILIAL), nStartUnN, nUnNLength),0,0,0,0,0}  )
			EndIf

			If aScan(aSintEM,  {|x| x[1] == substr((cSitAliasQry)->(FILIAL),  nStartEmp, nEmpLength)   }) == 0
				AAdd ( aSintEM , {substr((cSitAliasQry)->(FILIAL),  nStartEmp, nEmpLength),0,0,0,0,0}  )
			EndIf
		EndIf

		If aScan(aSintCC,  {|x| x[1] == (cSitAliasQry)->(FILIAL) +(cSitAliasQry)->(CC)  }) == 0
			AAdd ( aSintCC , {(cSitAliasQry)->(FILIAL) +(cSitAliasQry)->(CC),0,0,0,0,0}  )
		EndIf
	EndIf

	aSitFunc := RetSituacao( (cSitAliasQry)->(FILIAL), (cSitAliasQry)->(MAT), .F., dDtPerFim ,,,, dDtPerIni  )

	If lSit106
		// Ponto de entrada para alterar a situação do funcionário
		SRA->(dbSeek((cSitAliasQry)->(FILIAL) + (cSitAliasQry)->(MAT)))
		aSitFunc := ExecBlock("SitFol106", .F., .F., {aSitFunc, dDtPerIni, dDtPerFim })
	EndIf

	If Len(aSitFunc) > 0
		nInd := aScan(aSintTot, {|x| x[1] == AllTrim((cSitAliasQry)->(FILIAL))  })

		If lCorpManage
			nInd2 := aScan(aSintUN, {|x| x[1] == substr((cSitAliasQry)->(FILIAL), nStartUnN, nUnNLength)  })
			nInd3 := aScan(aSintEM, {|x| x[1] == substr((cSitAliasQry)->(FILIAL),  nStartEmp, nEmpLength)  })
		EndIf

		nInd4 := aScan(aSintCC, {|x| x[1] == (cSitAliasQry)->(FILIAL) +(cSitAliasQry)->(CC)  })

		Do Case
			Case aSitFunc[1] == "A"
				aSintTot[nInd][2] += 1
				aSintEmp[1]       += 1
				If lCorpManage
					aSintUN[nInd2][2] += 1
					aSintEM[nInd3][2] += 1
				EndIf
				aSintCC[nInd4][2] += 1
			Case aSitFunc[1] == "F"
				aSintTot[nInd][3] += 1
				aSintEmp[2]       += 1
				If lCorpManage
					aSintUN[nInd2][3] += 1
					aSintEM[nInd3][3] += 1
				EndIf
				aSintCC[nInd4][3] += 1
			Case aSitFunc[1] == "T"
				aSintTot[nInd][4] += 1
				aSintEmp[3]       += 1
				If lCorpManage
					aSintUN[nInd2][4] += 1
					aSintEM[nInd3][4] += 1
				EndIf
				aSintCC[nInd4][4] += 1
			Case aSitFunc[1] == "D" .and. aSitFunc[4] <= dDtPerFim
				aSintTot[nInd][5] += 1
				aSintEmp[4]       += 1
				If lCorpManage
					aSintUN[nInd2][5] += 1
					aSintEM[nInd3][5] += 1
				EndIf
				aSintCC[nInd4][5] += 1
			OtherWise
				aSintTot[nInd][6] += 1
				aSintEmp[5]       += 1
				If lCorpManage
					aSintUN[nInd2][6] += 1
					aSintEM[nInd3][6] += 1
				EndIf
				aSintCC[nInd4][6] += 1
		EndCase
	EndIf

	(cSitAliasQry)->(DbSkip())
EndDo

(cSitAliasQry)->(DBCloseArea())

return

/*
===============================================================================================================================
Programa----------: fLastSem
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 08/09/200
===============================================================================================================================
Descri��o---------: Retorna a ultima semana de determinado per�odo
===============================================================================================================================
Parametros--------: cProcesso, 
					cRoteiro, 
					cPeriodo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fLastSem( cProcesso, cRoteiro, cPeriodo )
Local cRet := ""

RCH->(DbSetOrder(4)) //RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG

If RCH->(DbSeek(xFilial("RCH") + cProcesso + cRoteiro + cPeriodo))
	While RCH->( !Eof() .and. RCH_PROCES + RCH_ROTEIR + RCH_PER == cProcesso + cRoteiro + cPeriodo )
		cRet := RCH->RCH_NUMPAG
		RCH->(DbSkip())
	EndDo
EndIf

Return cRet

/*
===============================================================================================================================
Programa----------: RGPE19COM
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 08/09/200
===============================================================================================================================
Descri��o---------: Busca segundo per�odo para compara��o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGPE19COM()

	Local cAlicom := GetNextAlias()
	Local cPercom := substr(mv_par19,3,4) + substr(mv_par19,1,2)

	BeginSql alias cAlicom

		SELECT	tView.SALARIO, tView.PD, tView.QTDSEM,    tView.HORAS,  tView.VALOR,     tView.PROCES,
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoView%, tView.OCORR
		FROM
		(
			SELECT 	SUM(SRA.RA_SALARIO) SALARIO, SRC.RC_PD PD, SUM(SRC.RC_QTDSEM) QTDSEM, SUM(SRC.RC_HORAS) HORAS,
					SUM(SRC.RC_VALOR) VALOR,     SRC.RC_PROCES PROCES, SRC.RC_PERIODO PERIODO,
					SRC.RC_ROTEIR ROTEIR,        SRC.RC_FILIAL FILIAL	%exp:cExtraC%,
					SRA.%exp:cCpoAlsC%,
					count(SRC.rC_PD) OCORR
			FROM  %table:SRA% SRA
			INNER JOIN %table:SRC% SRC
			ON 		SRA.RA_FILIAL = SRC.RC_FILIAL %exp:cJoinC%
			WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
					SRC.RC_PERIODO =   %exp:Upper(cPercom)%   AND
					%exp:cWhereSRC%
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRC.%notDel%
			GROUP BY RC_QTDSEM, RC_PROCES, RC_PERIODO, RC_ROTEIR, %exp:cCpoDelimC%, RC_PD, RC_FILIAL %exp:cGroupEC%

			UNION ALL

			SELECT SUM(SRA.RA_SALARIO) SALARIO, SRD.RD_PD PD,SUM(SRD.RD_QTDSEM) QTDSEM,         SUM(SRD.RD_HORAS) HORAS,
					SUM(SRD.RD_VALOR) VALOR,     SRD.RD_PROCES PROCES, SRD.RD_PERIODO PERIODO,
					SRD.RD_ROTEIR ROTEIR,        SRD.RD_FILIAL FILIAL	%exp:cExtraD%,
					SRA.%exp:cCpoAlsD%,
					count(SRD.rD_PD) OCORR
			FROM  %table:SRA% SRA
			INNER JOIN %table:SRD% SRD
			ON 		SRA.RA_FILIAL = SRD.RD_FILIAL %exp:cJoinD%
			WHERE 	SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
					( ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA <= %exp:cDtPerFim% AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) ) OR
						( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA > %exp:cDtPerFim% AND ' ' IN (%exp:Upper(cSitQuery)%) ) OR
						( SRA.RA_SITFOLH <> 'D' AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) ) ) AND
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
					SRD.RD_PERIODO =   %exp:Upper(cPercom)%   AND
					%exp:cWhereSRD%
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRD.%notDel%
			GROUP BY RD_PROCES, RD_PERIODO, RD_ROTEIR, RD_QTDSEM, %exp:cCpoDelimD%, RD_PD, RD_FILIAL %exp:cGroupED%
		) tView
		INNER JOIN	%table:SRV% SRVA
		ON			SRVA.RV_COD = tView.PD AND %exp:cJoinAux% AND SRVA.%notDel%
		GROUP BY tView.SALARIO, tView.PD,tView.QTDSEM, tView.HORAS,  tView.VALOR,     tView.PROCES,
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoViewG%, tView.OCORR
		ORDER BY %exp:cCpoDelim%, PD
	EndSql
	//aComp
	IF !EMPTY(cAlicom)

		WHILE (cAlicom)->(!EOF())

			Aadd(aComp, {(cAlicom)->SALARIO,;    // 1
						 (cAlicom)->PD,;         // 2
						 (cAlicom)->QTDSEM,;     // 3
						 (cAlicom)->HORAS,;      // 4
						 (cAlicom)->VALOR,;      // 5
						 (cAlicom)->PROCES,;     // 6
						 (cAlicom)->PERIODO,;    // 7
						 (cAlicom)->ROTEIR,;     // 8
						 (cAlicom)->FILIAL,;     // 9
						 (cAlicom)->RV_TIPOCOD,; // 10 * _cGrupo
						 (cAlicom)->RV_DESC,;    // 11
						 (cAlicom)->RV_IMPRIPD}) // 12  *  <> "2"
			(cAlicom)->(DbSkip())
		ENDDO
	ENDIF
RETURN

/*
===============================================================================================================================
Programa----------: RGPE19RET
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 08/09/200
===============================================================================================================================
Descri��o---------: Retorna o valor do per�odo de compara��o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function RGPE19RET(cFilcom, cCodCom)
	Local nPoscom := 0
	Local nRet := 0

	IF (nPoscom:= aScan(aComp, {|x| x[9] == cFilcom .AND. x[2] == cCodcom})) != 0
		nRet := aComp[nPoscom][5] 
	ELSE
		RETURN 0
	ENDIF

RETURN nRet

/*
===============================================================================================================================
Programa----------: RGPE019C
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 08/09/200
===============================================================================================================================
Descri��o---------: Retorna um array com dados que n�o foram impressos no relat�rio por n�o existirem no per�odo atual,
                    mas existem no per�odo anterior.
===============================================================================================================================
Parametros--------: _aLidos = dados que j� ser�o impressos no relat�rio.
                    _aDados = Array com os dados do per�odo anterior.
					_cTipo  = O tipo de array que ser� tratado.
===============================================================================================================================
Retorno-----------: _aRet   = array com os dados que ainda n�o foram impressos.
===============================================================================================================================
*/
User Function RGPE019C(_aLidos,_aDados, _cTipo)
Local _aRet := {}
Local _nI, _nX//, _nY 
Local _cCod, _cGrupo

Begin Sequence
   For _nI := 1 To Len(_aDados)
       _cCod   := _aDados[_nI,2]
	   _cGrupo := _aDados[_nI,10] 

       If _cTipo == "P" .And. _aDados[_nI,12] <> "2" .And. _cGrupo = "1"
          _nX := Ascan(_aLidos,({|x| x[1] == _cGrupo .And. x[2] == _cCod }))
		  If _nX == 0 
             Aadd(_aRet,_aDados[_nI])
		  EndIf 

	   ElseIf _cTipo == "D" .And. _aDados[_nI,12] <> "2" .And. _cGrupo == "2"
          _nX := Ascan(_aLidos,({|x| x[1] == _cGrupo .And. x[2] == _cCod }))
		  If _nX == 0
             Aadd(_aRet,_aDados[_nI])
		  EndIf 
	   
	   ElseIf _cTipo == "B" .And. _aDados[_nI,12] <> "2" .And. _cGrupo $ "3/4"
          _nX := Ascan(_aLidos,({|x| x[1] == _cGrupo .And. x[2] == _cCod }))
		  If _nX == 0 
             Aadd(_aRet,_aDados[_nI])
		  EndIf 

	   EndIf

   Next

End Sequence 

Return _aRet 
