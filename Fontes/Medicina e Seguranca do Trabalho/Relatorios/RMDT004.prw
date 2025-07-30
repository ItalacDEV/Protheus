/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 10/04/2018 | Alterar a rotina de manutenção de EPIs para imprimir corretamente o numero da SA  Chamado 23960.
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 11/06/2019 | Revisão para loboguara - Chamado 29593                                                                  
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.ch"
#DEFINE _nVERSAO 02 //Versao do fonte

/*
===============================================================================================================================
Programa----------: RMDT004
Autor-------------: TOTVS
Data da Criacao---: 20/09/2000
===============================================================================================================================
Descrição---------: Recibo de entrega do epi.  
===============================================================================================================================
Parametros--------: aDados - Array com os dados da entrega.
                    aRegs
                    aRegsTNF - Arry com os numeros dos Recnos dos registros da tabela TNF.
                    lDevEpi - Indica se é necessário a devolução.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RMDT004( aDados, aRegs , aRegsTNF , lDevEpi , aDev )
//---------------------------------------------------------------
// Armazena variaveis p/ devolucao (NGRIGHTCLICK)						  
//---------------------------------------------------------------
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)   
   
//---------------------------------------------------------------
// Define Variaveis                                             
//---------------------------------------------------------------
LOCAL wnrel   := "RMDT004"
LOCAL cDesc1  := "Relatorio de Comprovante de Entrega de EPI." // STR0001
LOCAL cDesc2  := "Conforme parametros o usuario pode selecionar os funcionarios, periodo desejado" // STR0002 
LOCAL cDesc3  := "e indicar se deseja imprimir apenas epi's nao impressos ou para todos."  // STR0003
LOCAL cString := "TNF"
LOCAL nFor
Default lDevEpi := .F.
Default aDev 	:= {} 

Private aOldACols := {}  
If Valtype(aRegs) == "A"
	aOldACols := aClone(aRegs)
Endif
 
PRIVATE aDad695
PRIVATE aRegs695
If Valtype(aDados) == "A"
	aDad695 := aClone(aDados)
Endif
If Valtype(aRegsTNF) == "A"
	aRegs695 := aClone(aRegsTNF)
Endif

PRIVATE nomeprog := "RMDT004"
PRIVATE tamanho  := "G"
PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 } // STR0004###STR0005
PRIVATE titulo
PRIVATE ntipo    := 0
PRIVATE nLastKey := 0
PRIVATE cPerg    := ""
PRIVATE cPerg2	 := "MDT805A" 
PRIVATE cabec1	  := " "
PRIVATE cabec2   := " "
PRIVATE nSizeSI3, nSizeSRJ
PRIVATE cFuncMat := " "
PRIVATE dDataEnt := " "
Private nDist    := 0
Private cAliasCC := "SI3"
Private cDescCC  := "SI3->I3_DESC"
Private cF3CC    := "SI3" 
Private cCodcc   := "I3_CUSTO"
Private nSizeCC
Private oTempTRB
Private cUsaInt1  := AllTrim(GetMv("MV_NGMDTES"))
Private lMdtGerSA := If( SuperGetMv("MV_NG2SA",.F.,"N") == "S", .T. , .F. ) //Indica se gera SA ao inves de requisitar do estoque
Private lGera_SA  := .T.
Private lDevol := lDevEpi 
Private aDevParc := aClone(aDev)

If !lDevol
	titulo   := "Comprovante de Entrega de EPI" // STR0006 
Else
	titulo   := "Comprovante de Devolução de EPI" // STR0087 
EndIf

If cUsaInt1 != "S" .or. !lMdtGerSA
	lGera_SA := .f.
Endif

nSizeCod := If((TAMSX3("B1_COD")[1]) < 1,2,(TAMSX3("B1_COD")[1]))
If nSizeCod > 15
	nDist   := (nSizeCod/2) + 2
Endif

nSizeSI3 := If((TAMSX3("I3_CUSTO" )[1]) < 1,9 ,(TAMSX3("I3_CUSTO" )[1]))
nSizeSRJ := If((TAMSX3("RJ_FUNCAO")[1]) < 1,4 ,(TAMSX3("RJ_FUNCAO")[1]))
nSizeCC  := If((TAMSX3("CTT_CUSTO")[1]) < 1,20,(TAMSX3("CTT_CUSTO")[1]))
Private nSizeFil:= FwSizeFilial()

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cAliasCC := "CTT"
	cDescCC  := "CTT->CTT_DESC01"
	cF3CC    := "CTT" 
	cCodcc    := "CTT_CUSTO"
	nSizeSI3 := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))	
Endif

Private cCliMdtPs  := ""
Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private lBioMDT    := SuperGetMv("MV_NG2BIOM",.F.,"2") == "1" 

cPerg:= If(!lSigaMdtPS,"MDT805    ","MDT805PS  ")
cCliMdtPs:= If(!lSigaMdtPS,Space(Len(SA1->A1_COD+SA1->A1_LOJA)),"Z")
/*--------------------------------------------------------------------
//PERGUNTAS PADRÃO                                                   |
| mv_par01              De Funcionario                               |
| mv_par02              Ate Funcionario                              |  
| mv_par03              De Data Entrega                              |  
| mv_par04              Ate Data Entrega                             |  
| mv_par05              So nao Impresos / Todos / Ultima retirada    |  
| mv_par06              Termo de Responsabilidade                    |  
| mv_par07              Duas vias                                    |  
| mv_par08              Ordenar por                                  |  
| mv_par09              De Centro de Custo                           |  
| mv_par10              Ate Centro de Custo                          |  
| mv_par11              Considerar funcionarios demitidos            |  
|                           1 - Sim                                  |  
|                           2 - Nao                                  |  
| mv_par12              Ordenar EPIs por:                            |  
|                            1 - Cod                                 |  
|                            2 - Nome                                |  
| mv_par13              De Data Admissao                             |  
| mv_par14              Ate Data Admissao                            |  
| mv_par15              De Filial                                    |  
| mv_par16              Ate Filial                                   | 
| mv_par17    		   Tipo de Relatório                            | 
|                             1 - Antalítico                         | 
|                             2 - Sintérico                          | 
| mv_par18    			 Considerar Ass. Lateral ?                   | 
|             				1 - Sim                                  | 
|      						2 - Não                                  |
|                                                                    |
//PERGUNTAS PRESTADOR DE SERVIÇO                                     |
| mv_par01              De Cliente ?                                 |
| mv_par02              Loja                                         |
| mv_par03              Até Cliente ?                                |
| mv_par04              Loja                                         |
| mv_par05              De Funcionario                               |
| mv_par06              Ate Funcionario                              |  
| mv_par07              De Data Entrega                              |  
| mv_par08              Ate Data Entrega                             |  
| mv_par09              So nao Impresos / Todos / Ultima retirada    |  
| mv_par10              Termo de Responsabilidade                    |  
| mv_par11              Duas vias                                    |  
| mv_par12              Ordenar por                                  |  
| mv_par13              De Centro de Custo                           |  
| mv_par14              Ate Centro de Custo                          |  
| mv_par1              Considerar funcionarios demitidos             |  
|                           1 - Sim                                  |  
|                           2 - Nao                                  |  
| mv_par16              Ordenar EPIs por:                            |  
|                            1 - Cod                                 |  
|                            2 - Nome                                |  
| mv_par17              De Data Admissao                             |  
| mv_par18              Ate Data Admissao                            |  
| mv_par19              De Filial                                    |  
| mv_par20              Ate Filial                                   | 
| mv_par21    		   Tipo de Relatório                            | 
|                             1 - Antalítico                         | 
|                             2 - Sintérico                          | 
| mv_par22    			 Considerar Ass. Lateral ?                   | 
|             				1 - Sim                                  | 
|      						2 - Não                                  |
---------------------------------------------------------------------*/

//|-----------------------------------------------------------------------|
//| Verifica as perguntas selecionadas                                    |
//|-----------------------------------------------------------------------|
If IsInCallStack("MDTA695") .OR. IsInCallStack("MDTA630") .OR. IsInCallStack("MDTA410")
	pergunte(cPerg2,.F.)
Else
	pergunte(cPerg,.F.)
EndIf
//---------------------------------------------------------------
// Envia controle para a funcao SETPRINT                        
//---------------------------------------------------------------
wnrel:="RMDT004"

If Valtype(aRegs695) == "A"
	wnrel := SetPrint(cString,wnrel,cPerg2,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	pergunte(cPerg,.F.)
ElseIf Valtype(aDad695) == "A"
	wnrel := SetPrint(cString,wnrel,cPerg2,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	//Adiciona os valores do novo grupo de perguntas no aDad695
	aAdd( aDad695 , { "Mv_Par06" , Mv_Par01 } )
	aAdd( aDad695 , { "Mv_Par07" , Mv_Par02 } )
	aAdd( aDad695 , { "Mv_Par12" , Mv_Par03 } )
	aAdd( aDad695 , { "Mv_Par18" , Mv_Par04 } )
	pergunte(cPerg,.F.)
	For nFor := 1 To Len(aDad695)
		&(aDad695[nFor,1]) := aDad695[nFor,2]
	Next nFor
	If lSigaMdtps
		cCliMdtPs := Mv_par01+Mv_par02
	Endif
Else
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
Endif

If nLastKey == 27
	Set Filter to
	//---------------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)             
	//---------------------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
	Return
Endif                                                                                                  

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	//---------------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)                          
	//---------------------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
	Return
Endif

RptStatus({|lEnd| RMDT004I(@lEnd,wnRel,titulo,tamanho)},titulo)

//---------------------------------------------------------------
// Devolve variaveis armazenadas (NGRIGHTCLICK)               
//---------------------------------------------------------------
NGRETURNPRM(aNGBEGINPRM)

Return NIL

/*
===============================================================================================================================
Programa----------: RMDT004I
Autor-------------: TOTVS
Data da Criacao---: 20/09/2000
===============================================================================================================================
Descrição---------: Chama o relatório.
  ===============================================================================================================================
Parametros--------:lEnd - Cancela a impressão. 
                   wnRel - Nome do programa.
                   titulo - Titulo do relatório. 
                   tamanho - Indica o tamanho do relatório. 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT004I(lEnd,wnRel,titulo,tamanho)
//---------------------------------------------------------------
// Define Variaveis                                             
//---------------------------------------------------------------
LOCAL cCC := ""
Local i
Local lImp := .F.

//---------------------------------------------------------------
// Variaveis locais exclusivas deste programa                   
//---------------------------------------------------------------
LOCAL nRegAtual := 0
Local nCont
Local nPOSCOD
Local nPOSNUM
Local nPOSDAT
Local nPOSHOR
Local lExistOld
Local aFiliais := {}

//---------------------------------------------------------------
// Contadores de linha e pagina                                 
//---------------------------------------------------------------
PRIVATE Li := 80 ,M_PAG := 1
PRIVATE lCPODtVenc := .t.

Private cTRB := GetNextAlias()
aDBF := {}
AADD(aDBF,{"FUNCI"  , "C", 06,0})
AADD(aDBF,{"NOME"   , "C", 40,0})
AADD(aDBF,{"RG"     , "C", 15,0})
AADD(aDBF,{"NASC"   , "D", 10,0})
AADD(aDBF,{"ADMIS"  , "D", 10,0})
AADD(aDBF,{"IDADE"  , "C", 03,0})
AADD(aDBF,{"CC"     , "C", nSizeSI3,0})
AADD(aDBF,{"DESCC"  , "C", 60,0})
AADD(aDBF,{"FUNCAO" , "C", nSizeSRJ,0})
AADD(aDBF,{"DESCFUN", "C", 20,0})
AADD(aDBF,{"CODEPI" , "C", nSizeCod,0})
AADD(aDBF,{"DESEPI" , "C", 80,0})
AADD(aDBF,{"DTENT"  , "D", 10,0})
AADD(aDBF,{"HRENT"  , "C", 05,0})
AADD(aDBF,{"QTDE"   , "N", 06,2})
AADD(aDBF,{"DEV"    , "C", 01,0})
AADD(aDBF,{"NUMCAP" , "C", 12,0})
AADD(aDBF,{"NUMCRI" , "C", 12,0})
AADD(aDBF,{"NUMCRF" , "C", 12,0})
AADD(aDBF,{"DTDEVO" , "D", 10,0})
AADD(aDBF,{"CATFUNC", "C", 01,0})
AADD(aDBF,{"NUMSA"  , "C", 06,0})
AADD(aDBF,{"ITEMSA" , "C", 02,0})
AADD(aDBF,{"BIOMET" , "N", 01,0})
AADD(aDBF,{"NRRECNO", "N", 10,0}) 

If lSigaMdtps
	AADD(aDBF,{"CLIENT"	, "C", nTa1,0})
	AADD(aDBF,{"LOJA"	, "C", nTa1L,0})
Else
	AADD(aDBF,{"FILIAL"	, "C", nSizeFil	,0})
	AADD(aDBF,{"NOMFIL"	, "C", 40		,0})
Endif

If Len(aOldACols) > 0
	nPOSCOD := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNF_CODEPI" }) // Codigo do Epi
	nPOSNUM := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNF_NUMCAP" }) // Num C. A.
	nPOSDAT := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNF_DTENTR" }) // Data da Entrega
	nPOSHOR := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNF_HRENTR" }) // Hora da Entrega
EndIf

If lSigaMdtps
	
	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	If mv_par16 == 1  //Cod EPI
		oTempTRB:AddIndex( "1", {"FUNCI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "2", {"NOME","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "3", {"CC","FUNCI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "4", {"DESCC","FUNCI","CODEPI","NUMCAP","DTENT"} )
	ElseIf mv_par16 == 2   //Nome EPI
		oTempTRB:AddIndex( "1", {"FUNCI","DESEPI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "2", {"NOME","DESEPI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "3", {"CC","FUNCI","DESEPI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "4", {"DESCC","FUNCI","DESEPI","CODEPI","NUMCAP","DTENT"} )
	Else	//Data EPI
		oTempTRB:AddIndex( "1", {"FUNCI","DTENT","HRENT","CODEPI","NUMCAP"} )
		oTempTRB:AddIndex( "2", {"FILIAL","NOME","DTENT","HRENT","CODEPI","NUMCAP"} )
		oTempTRB:AddIndex( "3", {"FILIAL","CC","FUNCI","DTENT","CODEPI","NUMCAP","HRENT"} )
		oTempTRB:AddIndex( "4", {"FILIAL","DESCC","FUNCI","DTENT","HRENT","CODEPI","NUMCAP"} )
	Endif
	oTempTRB:Create()
	
	//---------------------------------------------------------------
	// Verifica se deve comprimir ou nao                            
	//---------------------------------------------------------------
	nTipo  := IIF(aReturn[4]==1,15,18)
	     
	dbSelectArea("TNF")
	If mv_par09 == 3
		dbSetOrder(10) //TNF_FILIAL+TNF_CLIENT+TNF_LOJACL+TNF_MAT+DTOS(TNF_DTENTR)+TNF_HRENTR+TNF_CODEPI
	Else
		dbSetOrder(08) //TNF_FILIAL+TNF_CLIENT+TNF_LOJACL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR
	EndIf 
	dbSeek(xFilial("TNF")+MV_PAR01+MV_PAR02,.T.)

	lImpAuto := .F.
	If Valtype(aRegs695) == "A"
		lImpAuto := .T.
		SetRegua(Len(aRegs695))
		For i := 1 to Len(aRegs695)
			IncRegua()
			dbSelectArea("TNF")
			dbGoTo(aRegs695[i])
			If !Eof() .And. !Bof()
				cFuncMat := TNF->TNF_MAT
				RMDT004A()
			Endif
		Next i
	Else
		SetRegua(LastRec())
	Endif
	
	//---------------------------------------------------------------
	// Correr TNF para ler os  EPI's Entregues aos Funcionarios 
	//---------------------------------------------------------------
	
	While !Eof() .AND. !lImpAuto           	.AND.;
		TNF->TNF_FILIAL == xFIlial("TNF")  	.AND.;
		TNF->(TNF_CLIENT+TNF_LOJACL) >= mv_par01+mv_par02 .AND. TNF->(TNF_CLIENT+TNF_LOJACL) <= mv_par03+mv_par04
		
		IncRegua()
		
		If TNF->TNF_MAT < MV_PAR05 .OR. TNF->TNF_MAT > MV_PAR06
			dbSkip()
			Loop
		Endif
		
		DbSelectArea("SRA")
		DbSetOrder(01)
		DbSeek(xFilial("SRA")+TNF->TNF_MAT)
		DbSelectArea("TM0")
		DbSetOrder(03)
		DbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
		
		If mv_par11 == 2  //Nao considerar funcionarios demitidos
			If ( SRA->RA_SITFOLH == "D" ) .OR. ( !Empty( SRA->RA_DEMISSA ) )
				dbSelectArea("TNF")
				dbSkip()
				Loop
			Endif
		Endif
		
		//Data de Admissao
		If SRA->RA_ADMISSA < mv_par17 .OR. SRA->RA_ADMISSA > mv_par18
			dbSelectArea("TNF")
			dbSkip()
			Loop
		Endif
		
		cCC := SRA->RA_CC
		
		If ValType(mv_par13) == "C" .AND. ValType(mv_par14) == "C"
			If (cCC < mv_par13) .OR. (cCC > mv_par14)
				dbselectarea("TNF")
				DbSkip()
				Loop
			EndIf
		EndIf
		
		If TNF->TNF_DTENTR < MV_PAR07 .OR. TNF->TNF_DTENTR > MV_PAR08
			dbSelectArea("TNF")
			dbSkip()
			loop
		Endif
		
		If MV_PAR09 == 2 .AND. !EMPTY(TNF->TNF_DTRECI)
			dbSelectArea("TNF")
			dbSkip()
			loop
		EndIf
		
		lExistOld := .F.
		If Len(aOldACols) > 0
			For nCont := 1 To Len(aOldACols)
				If aOldACols[nCont][nPOSCOD] == TNF->TNF_CODEPI
					If aOldACols[nCont][nPOSNUM] == TNF->TNF_NUMCAP
						If aOldACols[nCont][nPOSDAT] == TNF->TNF_DTENTR
							If aOldACols[nCont][nPOSHOR] == TNF->TNF_HRENTR
								lExistOld := .T.
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			Next nCont
			
			If lExistOld
				dbSelectArea("TNF")
				dbSkip()
				Loop
			EndIf
		EndIf
		
		cFuncMat := TNF->TNF_MAT
		
		If mv_par09 == 3
			DbSelectArea("TNF")
			dDataEnt := TNF->TNF_DTENTR
			nRegAtual := RecNo()
			DbSkip()
			If cFuncMat <> TNF->TNF_MAT
				DbSkip(-1)
				While !Bof()							.AND.;
					TNF->TNF_FILIAL == xFIlial("TNF")  	.AND.;
					TNF->TNF_MAT	== cFuncMat        	.AND.;
					TNF->TNF_DTENTR == dDataEnt
					RMDT004A()
					DbSelectArea ("TNF")
					If !lBioMDT .Or. (lBioMDT .and. TM0->TM0_INDBIO != "1")
						Reclock("TNF",.f.)
						TNF->TNF_DTRECI := Date()
						MsUnlock("TNF")
					Endif
					DbSkip(-1)
				EndDo
				DbGoTo(nRegAtual)
				DbSkip()
			EndIf
			Loop
		Else
			RMDT004A()
			dbSelectArea("TNF")
			If !lBioMDT .Or. (lBioMDT .and. TM0->TM0_INDBIO != "1")
				Reclock("TNF",.f.)
				TNF->TNF_DTRECI := Date()
				MsUnlock("TNF")
			Endif
			dbSetOrder(03)
			DbSkip()      
		EndIf   

	EndDo
	
Else
	
	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	If mv_par12 == 1  //Cod EPI
		oTempTRB:AddIndex( "1", {"FILIAL","FUNCI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "2", {"FILIAL","NOME","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "3", {"FILIAL","CC","FUNCI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "4", {"FILIAL","DESCC","FUNCI","CODEPI","NUMCAP","DTENT"} )
	ElseIf mv_par12 == 2  //Nome EPI
		oTempTRB:AddIndex( "1", {"FUNCI","DESEPI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "2", {"FILIAL","NOME","DESEPI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "3", {"FILIAL","CC","FUNCI","CODEPI","NUMCAP","DTENT"} )
		oTempTRB:AddIndex( "4", {"FILIAL","DESCC","FUNCI","DESEPI","CODEPI","NUMCAP","DTENT"} )
	Else // Data EPI
		oTempTRB:AddIndex( "1", {"FUNCI","DTENT","HRENT","CODEPI","NUMCAP"} )
		oTempTRB:AddIndex( "2", {"FILIAL","NOME","DTENT","HRENT","CODEPI","NUMCAP"} )
		oTempTRB:AddIndex( "3", {"FILIAL","CC","FUNCI","DTENT","CODEPI","NUMCAP","HRENT"} )
		oTempTRB:AddIndex( "4", {"FILIAL","DESCC","FUNCI","DTENT","HRENT","CODEPI","NUMCAP"} )
	Endif
	oTempTRB:Create()
   
	lImpAuto := .F.   
	If Valtype(aRegs695) == "A"
		lImpAuto := .T.
		SetRegua(Len(aRegs695))
		For i := 1 to Len(aRegs695)      
			IncRegua()   
			dbSelectArea("TNF")
			dbGoTo(aRegs695[i])   
			If !Eof() .And. !Bof()
				cFuncMat := TNF->TNF_MAT
				RMDT004A(cFilAnt,Upper(Substr(SM0->M0_NOME, 1, 40)))
			Endif
		Next i
	Endif
	
	//---------------------------------------------------------------
	// Define Filiais a percorrer                                   
	//---------------------------------------------------------------
	If Valtype(aDad695) == "A"
		aFiliais := {{cFilAnt, Upper(Substr(SM0->M0_NOME, 1, 40)) }}
	Else
		aFiliais := MDTRETFIL("TNF", MV_PAR15, MV_PAR16)
	EndIf
	//---------------------------------------------------------------
	// Verifica se deve comprimir ou nao                            
	//---------------------------------------------------------------
	nTipo  := IIF(aReturn[4]==1,15,18)  
	
	For i:=1 to Len(aFiliais)
		If lImpAuto
			Loop    
		Endif
		dbSelectArea("TNF")
		If mv_par05 == 3
			dbSetOrder(05) //TNF_MAT + DTOS(TNF_DTENTR) + TNF_HRENTR + TNF_CODEPI
		Else
			dbSetOrder(03) //TNF_MAT + TNF_CODEPI + DTOS(TNF_DTENTR) + TNF_HRENTR
		EndIf
		dbSeek(xFilial("TNF",aFiliais[i,1])+MV_PAR01,.T.)
		
		SetRegua(LastRec())
		
		//---------------------------------------------------------------
		// Correr TNF para ler os  EPI's Entregues aos Funcionarios 
		//---------------------------------------------------------------
		While !Eof() .AND. TNF->TNF_FILIAL == xFilial("TNF",aFiliais[i,1]) .AND. TNF->TNF_MAT <= MV_PAR02
		
			IncRegua()
			
			DbSelectArea("SRA")
			DbSetOrder(01)
			DbSeek(xFilial("SRA",aFiliais[i,1])+TNF->TNF_MAT)
			DbSelectArea("TM0")
			DbSetOrder(03)
			DbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
			
			If mv_par11 == 2  //Nao considerar funcionarios demitidos
				If ( SRA->RA_SITFOLH == "D" ) .OR. ( !Empty( SRA->RA_DEMISSA ) )
					dbSelectArea("TNF")
					dbSkip()
					Loop
				Endif
			Endif
			
			//Data de Admissao
			If SRA->RA_ADMISSA < mv_par13 .OR. SRA->RA_ADMISSA > mv_par14
				dbSelectArea("TNF")
				dbSkip()
				Loop
			Endif
			
			cCC := SRA->RA_CC
			
			If ValType(mv_par09) == "C" .AND. ValType(mv_par10) == "C"
				If (cCC < mv_par09) .OR. (cCC > mv_par10)
					dbselectarea("TNF")
					DbSkip()
					Loop
				EndIf
			EndIf
			
			If TNF->TNF_DTENTR < MV_PAR03 .OR. TNF->TNF_DTENTR > MV_PAR04
				dbSelectArea("TNF")
				dbSkip()
				loop
			Endif
			
			If MV_PAR05 == 2 .AND. !EMPTY(TNF->TNF_DTRECI)
				dbSelectArea("TNF")
				dbSkip()
				loop
			EndIf
			
			lExistOld := .F.
			If Len(aOldACols) > 0
				For nCont := 1 To Len(aOldACols)
					If aOldACols[nCont][nPOSCOD] == TNF->TNF_CODEPI
						If aOldACols[nCont][nPOSNUM] == TNF->TNF_NUMCAP
							If aOldACols[nCont][nPOSDAT] == TNF->TNF_DTENTR
								If aOldACols[nCont][nPOSHOR] == TNF->TNF_HRENTR
									lExistOld := .T.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				Next nCont
				
				If lExistOld
                   dbSelectArea("TNF")
				   dbSkip()
				   Loop
				EndIf
			EndIf
			
			cFuncMat := TNF->TNF_MAT
			
			If mv_par05 == 3
				DbSelectArea("TNF")
				dDataEnt := TNF->TNF_DTENTR
				nRegAtual := RecNo()
				DbSkip()
				If cFuncMat <> TNF->TNF_MAT
					DbSkip(-1)
					While !Bof() .AND. TNF->TNF_FILIAL == xFIlial("TNF",aFiliais[i,1]) .AND.;
						TNF->TNF_MAT	== cFuncMat .AND. TNF->TNF_DTENTR == dDataEnt
						RMDT004A(aFiliais[i,1], aFiliais[i,2])
						DbSelectArea ("TNF")
						If !lBioMDT .Or. (lBioMDT .and. TM0->TM0_INDBIO != "1")
							Reclock("TNF",.f.)
							TNF->TNF_DTRECI := Date()
							MsUnlock("TNF")
						Endif
						DbSkip(-1)
					EndDo
					DbGoTo(nRegAtual)
					DbSkip()
				EndIf
				Loop
			Else
				RMDT004A(aFiliais[i,1], aFiliais[i,2])
				dbSelectArea("TNF")
				If !lBioMDT .Or. (lBioMDT .and. TM0->TM0_INDBIO != "1")
					Reclock("TNF",.f.)
					TNF->TNF_DTRECI := Date()
					MsUnlock("TNF")
				Endif
				dbSetOrder(03)
				DbSkip()
			EndIf

		End
	Next i	
Endif 
//Teste de parametros para saber o tipo de relatório a ser imprimido.
If lSigaMdtPS
	If mv_par19 == 1
		RMDT004T()
	Else
  		RMDT004O()
	Endif
Else 
	If mv_par17 == 1
		RMDT004T()
	Else
  		RMDT004O()
	Endif
Endif	

If (cTRB)->(RecCount()) > 0
	lImp := .T.
Endif

oTempTRB:Delete()

//---------------------------------------------------------------
// Devolve a condicao original do arquivo principal             
//---------------------------------------------------------------
RetIndex("TNF")
Set Filter To

If lImp
	Set device to Screen
	
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Else
	MsgStop("Não existem dados para montar o relatório.", "Atenção") // STR0079 ### STR0080
Endif

dbSelectArea("TNF")
dbSetOrder(1)

Return NIL

/*
===============================================================================================================================
Programa----------: RMDT004S
Autor-------------: TOTVS
Data da Criacao---: 20/09/2000
===============================================================================================================================
Descrição---------: Incrementa Linha e Controla Salto de Pagina  
  ===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT004S()
    Li++
    If Li > 58   
       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
    EndIf
Return

/*
Layout de Impressão:
====================

          1         2         3         4         5         6         7         8         9         0         1         2         3
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
-------------------------------------------------------------------------------------------------------------------------------------
|XXXXXXXXXXXXX                                      COMPROVANTE DE ENTREGA DE EPI'S                                                 |
|SIGA/RMDT004                                    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                Emissao: 99/99/99   hh:mm    |
-------------------------------------------------------------------------------------------------------------------------------------
|Funcionario.....: xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                         RG.: xxx.xxx.xxx			        		|
|Centro de Custo.: xxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx						 		                                    |
|Funcao..........: xxxx  -  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   					                                     		|
|Nascimento......: xx/xx/xx                                                               Admissao.: xx/xx/xx     Idade.: xx  		|
------------------------------------------------------------EPI's--------------------------------------------------------------------
|EPI              Nome do EPI                        Dt. Entr  Hora     Qtde  Dev. Dt. Devo  Num. CA 	                            |
|  Num. CRF      Num. CRI      Num. SA  Item SA                   													                |
|xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx  xx:xx  xxx,xx  xxx  xx/xx/xx  xxxxxxxxxxxx  Ass.: _________________  |
|  xxxxxxxxxxxx  xxxxxxxxxxxx  xxxxxx   xx                                                                                          |
|xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx  xx:xx  xxx,xx  xxx  xx/xx/xx  xxxxxxxxxxxx  Ass.: _________________  |
|xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx  xx:xx  xxx,xx  xxx  xx/xx/xx  xxxxxxxxxxxx  Ass.: _________________  |
|                                                                               													|
-------------------------------------------------------------------------------------------------------------------------------------
|       Data : ___/___/___                                                           							              	    |
|                                                                               													|
|       Assinatura: _______________________                                   Resp Empr: _______________________                    |
|                                                                               													|
-------------------------------------------------------------------------------------------------------------------------------------
*/             

/*
===============================================================================================================================
Programa----------: RMDT004T
Autor-------------: TOTVS
Data da Criacao---: 20/09/2000
===============================================================================================================================
Descrição---------: Impressão do Relatório.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT004T()
Local LinhaCorrente
Local lPrimvez := .t. 
Local _nRegAtu 

If lSigaMdtps
	
	DBSELECTAREA(cTRB)
	If mv_par12 == 1  //Matricula
		dbSetOrder(1)
	Elseif mv_par12 == 2  //Nome Funcionario
		dbSetOrder(2)
	Elseif mv_par12 == 3  //Cod. C. Custo
		dbSetOrder(3)
	Elseif mv_par12 == 4  //Nome C. Custo
		dbSetOrder(4)
	Endif
	
	Dbgotop()
	
	DO WHILE !EOF()
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+(cTRB)->CLIENT+(cTRB)->LOJA)
		
		CFUNC := (cTRB)->FUNCI
		nVolta := 0
		RMDT004S()
		@ Li,000 PSay " "+Replicate("_",219)
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 Psay "Empresa...:" + SubStr(SA1->A1_NOME,1,60) //  STR0027
		@ Li,127 Psay "CNPJ..:" + SA1->A1_CGC // STR0075
		@ Li,220 PSay "|"
		RMDT004S()
		
		@ Li,000 PSay "|"
		@ Li,001 Psay "Endereco..:" + SA1->A1_END // STR0028
		@ Li,127 Psay "Cidade..:" + SA1->A1_MUN // STR0029
		@ Li,162 Psay "Estado.." + ":" + SA1->A1_EST  // STR0030
		@ Li,221 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		
		RMDT004S()
		@ Li,000 PSay "|Funcionario.....:" // STR0010 
		@ Li,019 PSay CFUNC PICTURE "@!"
		@ Li,026 PSAY " - " + (cTRB)->NOME
		@ Li,127 PSay "RG.:" // STR0011
		@ Li,132 PSay (cTRB)->RG PICTURE "@!"
		@ Li,220 PSay "|"  
		
		RMDT004S()
		@ Li,000 PSay "|Centro de Custo.:" // STR0012 
		
		@ Li,019 PSay Alltrim((cTRB)->CC) +" - "+ Alltrim((cTRB)->DESCC)
		@ Li,127 PSay "Categoria Func.:" // STR0066
		
		cGrpCus := " SELECT "
		cGrpCus += " X5_CHAVE CHAVE,X5_DESCRI DESCRI "
		cGrpCus += " FROM "+ RetSqlName("SX5") +" X5 "
		cGrpCus += " WHERE "
		cGrpCus += "     D_E_L_E_T_ = ' ' "
		cGrpCus += " AND X5_TABELA  = '28' "
		cGrpCus += " AND X5_CHAVE >= '" + (cTRB)->CATFUNC + "'"
		cGrpCus += " AND X5_FILIAL  = '" + xFilial("SX5") + "'"	
		cGrpCus += " ORDER BY X5_CHAVE"

		If Select("TR5") > 0
			dbSelectArea("TR5")
			dbCloseArea()
		Endif

		TCQUERY cGrpCus New Alias "TR5"
		dbSelectArea("TR5")

		@ Li,144 PSay Substr(TR5->_DESCRI,1,30) PICTURE "@!"
		@ Li,220 PSay "|"

		If Select("TR5") >0
			dbSelectArea("TR5")
			dbCloseArea()
		Endif
		
		RMDT004S()
		@ Li,000 PSay "|Funcao..........:" // STR0013 
		@ Li,019 PSay Alltrim((cTRB)->FUNCAO) +" - "+ Alltrim((cTRB)->DESCFUN) PICTURE "@!"
		@ Li,220 PSay "|"
		
		RMDT004S()
		@ Li,000 PSay "|Nascimento......:" // STR0014 
		@ Li,019 PSay (cTRB)->NASC PICTURE "99/99/9999"
		@ Li,127 PSay "Admissao.:" // STR0015 
		@ Li,138 PSay (cTRB)->ADMIS PICTURE "99/99/9999"
		@ Li,157 PSay "Idade.:" // STR0016 
		@ Li,165 PSay (cTRB)->IDADE +" "+ "anos" // STR0039 
		@ Li,220 PSay "|"
		
		lLinha := .f.
		lFirst := .t.
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,001 PSay "EPI" // STR0017    
		@ Li,017+nDist PSay "Nome do EPI" // STR0018
		@ Li,139+nDist PSay "Dt. Entr" // STR0019    
		@ Li,151+nDist PSay "Hora" // STR0040    
		@ Li,158+nDist PSay "Qtde" // STR0025 
		@ Li,166+nDist PSay "Dev." // STR0020    
		@ Li,171+nDist PSay "Dt. Devo" // STR0042 
		@ Li,183+nDist PSay "Num C.A." // STR0026
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		DbSelectArea("TN3")
		@ Li,002 PSay "Num. CRF" // STR0033
		lLinha := .t.
		@ Li,016 PSay "Num. CRI" // STR0034
		lLinha := .t.
		If lGera_SA
			@ Li,031 PSay "Num. SA" // STR0082 
			@ Li,040 PSay "Item SA" // STR0083 
			lLinha := .t.
		EndIf
		DBSELECTAREA(cTRB)
		While !Eof() .AND. (cTRB)->FUNCI == CFUNC
			If lLinha .and. lFirst
				@ Li,220 Psay "|"
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			If !lFirst
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			lFirst := .f.
			@ Li,001 PSAY (cTRB)->CODEPI
			@ Li,017+nDist PSay substr(alltrim((cTRB)->DESEPI),1,80) PICTURE "@!"
			@ Li,139+nDist PSay (cTRB)->DTENT PICTURE "99/99/9999"
			@ Li,151+nDist PSay (cTRB)->HRENT PICTURE "99:99"
			@ Li,158+nDist PSay (cTRB)->QTDE  PICTURE "@E 999.99"
			IF (cTRB)->DEV = "1"
				@ LI,166+nDist PSAY "SIM" // STR0021 
			ELSE
				@ LI,166+nDist PSAY "NAO" // STR0022  
			ENDIF
			@ Li,171+nDist PSay (cTRB)->DTDEVO PICTURE "99/99/9999"
			If !Empty((cTRB)->NUMCAP)
				@ Li,183+nDist PSay Alltrim(SUBSTR((cTRB)->NUMCAP,1,12))
			EndIf 
			If lLinha
				@ Li,220 Psay "|" 
				RMDT004S()  
				@ Li,000 Psay "|"
			EndIf
		
			DbSelectArea("TN3")
			@ Li,002 PSay (cTRB)->NUMCRF
			@ Li,016 PSay (cTRB)->NUMCRI
			If lGera_SA
	           _nRegAtu := TNF->(Recno()) 	 
			   TNF->(DbGoTo((cTRB)->NRRECNO)) 
			   
				//@ Li,031 PSay (cTRB)->NUMSA  
				//@ Li,040 PSay (cTRB)->ITEMSA 
				
				@ Li,031 PSay TNF->TNF_NUMSA  
				@ Li,040 PSay TNF->TNF_ITEMSA 
				
				TNF->(DbGoTo(_nRegAtu)) 
			EndIf      
			
			If (cTRB)->BIOMET == 1 .Or. Valtype(aRegs695) == "A"
				If lDevol .And. (cTRB)->BIOMET == 2
					@ Li,195 PSay "Ass.: _________________" // STR0076 
				Else
					@ Li,199 PSay "Registro Biométrico" // STR0086 
				EndIf	
	   		Else
				If mv_par20 == 1
					@ Li,195 PSay "Ass.: _________________" // STR0076 
				EndIf
			EndIf
			
			@ Li,220 PSay "|"
			nVolta++
			DBSELECTAREA(cTRB)
			DBSKIP()
		ENDDO
		DBSKIP(-1)
		
		//termo
		dbSelectArea("TMZ")
		dbSetOrder(01)
		If dbSeek(xFilial("TMZ")+MV_PAR10)
			RMDT004S()
			@ Li,000 PSay "|"
			@ Li,001 PSay Replicate("_",219)
			@ Li,220 PSay "|"
			RMDT004S()
			@ Li,000 PSay "|"
			@ Li,098 PSay "TERMO DE RESPONSABILIDADE" // STR0041 
			@ Li,220 PSay "|"
			RMDT004S()
			@ Li,000 PSay "|"
			lPrimeiro := .T.
			
			nLinhasMemo := MLCOUNT(TMZ->TMZ_DESCRI,219)
			For LinhaCorrente := 1 to nLinhasMemo
				If lPrimeiro
					if !empty((MemoLine(TMZ->TMZ_DESCRI,56,LinhaCorrente)))
						@ Li,001 PSAY (MemoLine(TMZ->TMZ_DESCRI,219,LinhaCorrente))
						@ Li,220 PSay "|"
						lPrimeiro := .f.
					Else
						Exit
					Endif
				Else
					@ Li,000 PSay "|"
					@ Li,001 PSAY (MemoLine(TMZ->TMZ_DESCRI,219,LinhaCorrente))
					@ Li,220 PSay "|"
				EndIf
				RMDT004S()
			Next
			If !lPrimeiro
				@ Li,000 PSay "|"
			Endif
			@ Li,220 PSay "|"
		EndIf
		// fim do termo
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Data : ____/____/____" // STR0036 
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Assinatura: _______________________ " // STR0037 
		@ Li,127 PSay "Resp Empr: _______________________" // STR0088 
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		LI := 80
		If mv_par11 == 2 .and. lPrimvez
			DbSelectArea(cTRB)
			DbSkip(-(nVolta-1))
			lPrimvez := .f.
		Else
			DbSelectArea(cTRB)
			DbSkip()
			lPrimvez := .t.
		EndIf
		
	EndDo
	
Else
	
	DBSELECTAREA(cTRB)
	If mv_par08 == 1  //Matricula
		dbSetOrder(1)
	Elseif mv_par08 == 2  //Nome Funcionario
		dbSetOrder(2)
	Elseif mv_par08 == 3  //Cod. C. Custo
		dbSetOrder(3)
	Elseif mv_par08 == 4  //Nome C. Custo
		dbSetOrder(4)
	Endif
	
	Dbgotop()
	
	WHILE !EOF()
		
		CFUNC := (cTRB)->FUNCI
		nVolta := 0
		RMDT004S()
		@ Li,000 PSay " "+Replicate("_",219)
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 Psay "Empresa...:" + Substr(SM0->M0_NOMECOM,1,60) // STR0027
		@ Li,127 Psay "CNPJ..:" + SM0->M0_CGC // STR0075
		@ Li,220 PSay "|"
		If NGSX2MODO("TNF") != "C"
			RMDT004S()
			@ Li,000 PSay "|"
			@ Li,001 Psay "Filial....:" + AllTrim((cTRB)->FILIAL) + " - " + (cTRB)->NOMFIL // STR0081
			@ Li,220 PSay "|"
		Endif
		RMDT004S()
		
		@ Li,000 PSay "|"
		@ Li,001 Psay  "Endereco..:" + SM0->M0_ENDENT // STR0028
		@ Li,127 Psay  "Cidade..:" + SM0->M0_CIDCOB // STR0029
		@ Li,162 Psay  "Estado.." + ":" + SM0->M0_ESTCOB // STR0030
		@ Li,221 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		
		RMDT004S()
		@ Li,000 PSay "|Funcionario.....:" // STR0010 
		@ Li,019 PSay CFUNC PICTURE "@!"
		@ Li,026 PSAY " - " + (cTRB)->NOME
		@ Li,127 PSay "RG.:" // STR0011 
		@ Li,132 PSay (cTRB)->RG PICTURE "@!"
		@ Li,220 PSay "|"
		
		RMDT004S()
		@ Li,000 PSay "|Centro de Custo.:" // STR0012 
		
		@ Li,019 PSay Alltrim((cTRB)->CC) +" - "+ Alltrim((cTRB)->DESCC)
		@ Li,127 PSay "Categoria Func.:" // STR0066
		
			cGrpCus := " SELECT "
		cGrpCus += " X5_CHAVE CHAVE,X5_DESCRI DESCRI "
		cGrpCus += " FROM "+ RetSqlName("SX5") +" X5 "
		cGrpCus += " WHERE "
		cGrpCus += "     D_E_L_E_T_ = ' ' "
		cGrpCus += " AND X5_TABELA  = '28' "
		cGrpCus += " AND X5_CHAVE >= '" + (cTRB)->CATFUNC + "'"
		cGrpCus += " AND X5_FILIAL  = '" + xFilial("SX5") + "'"	
		cGrpCus += " ORDER BY X5_CHAVE"

		If Select("TR5") >0
			dbSelectArea("TR5")
			dbCloseArea()
		Endif

		TCQUERY cGrpCus New Alias "TR5"
		dbSelectArea("TR5")

		@ Li,144 PSay Substr(TR5->DESCRI,1,30) PICTURE "@!"
		@ Li,220 PSay "|"

		If Select("TR5") >0
			dbSelectArea("TR5")
			dbCloseArea()
		Endif
		
		RMDT004S()
		@ Li,000 PSay "|Funcao..........:" // STR0013 
		@ Li,019 PSay Alltrim((cTRB)->FUNCAO) +" - "+ Alltrim((cTRB)->DESCFUN) PICTURE "@!"
		@ Li,220 PSay "|"
		
		RMDT004S()
		@ Li,000 PSay "|Nascimento......:" // STR0014 
		@ Li,019 PSay (cTRB)->NASC PICTURE "99/99/9999"
		@ Li,127 PSay "Admissao.:" // STR0015 
		@ Li,138 PSay (cTRB)->ADMIS PICTURE "99/99/9999"
		@ Li,157 PSay "Idade.:" // STR0016 
		@ Li,165 PSay (cTRB)->IDADE +" "+ "anos" // STR0039
		@ Li,220 PSay "|"
		
		lLinha := .f.
		lFirst := .t.
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,001 PSay "EPI" // STR0017     
		@ Li,017+nDist PSay "Nome do EPI" // STR0018 
		@ Li,139+nDist PSay "Dt. Entr" // STR0019  
		@ Li,151+nDist PSay "Hora" // STR0040     
		@ Li,158+nDist PSay "Qtde" // STR0025 
		@ Li,166+nDist PSay "Dev." // STR0020     
		@ Li,171+nDist PSay "Dt. Devo" // STR0042
		@ Li,183+nDist PSay "Num C.A." // STR0026
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		DbSelectArea("TN3")
		@ Li,002 PSay "Num. CRF" // STR0033 
		lLinha := .t.
		@ Li,016 PSay "Num. CRI" // STR0034
		lLinha := .t.
		If lGera_SA
			@ Li,031 PSay "Num. SA" // STR0082 
			@ Li,040 PSay "Item SA" // STR0083 
			lLinha := .t.
		EndIf
		DBSELECTAREA(cTRB)
		While !Eof() .AND. (cTRB)->FUNCI == CFUNC
			If lLinha .and. lFirst
				@ Li,220 Psay "|"
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			If !lFirst
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			lFirst := .f.
			@ Li,001 PSAY (cTRB)->CODEPI
			@ Li,017+nDist PSay substr(alltrim((cTRB)->DESEPI),1,80) PICTURE "@!"
			@ Li,139+nDist PSay (cTRB)->DTENT PICTURE "99/99/9999"
			@ Li,151+nDist PSay (cTRB)->HRENT PICTURE "99:99"
			@ Li,158+nDist PSay (cTRB)->QTDE  PICTURE "@E 999.99"
			IF (cTRB)->DEV = "1"
				@ LI,166+nDist PSAY "SIM" // STR0021 
			ELSE
				@ LI,166+nDist PSAY "NAO" // STR0022  
			ENDIF
			@ Li,171+nDist PSay (cTRB)->DTDEVO PICTURE "99/99/9999"
			If !Empty((cTRB)->NUMCAP)
				@ Li,183+nDist PSay Alltrim(SUBSTR((cTRB)->NUMCAP,1,12))
			EndIf

			If lLinha
				@ Li,220 Psay "|" 
				RMDT004S()  
				@ Li,000 Psay "|"
			EndIf
							
			DbSelectArea("TN3")
			@ Li,002 PSay (cTRB)->NUMCRF
			@ Li,016 PSay (cTRB)->NUMCRI
			If lGera_SA
				//@ Li,031 PSay (cTRB)->NUMSA
				//@ Li,040 PSay (cTRB)->ITEMSA
				
				
			   _nRegAtu := TNF->(Recno()) 		 
			   TNF->(DbGoTo((cTRB)->NRRECNO )) 
			   
				//@ Li,031 PSay (cTRB)->NUMSA  
				//@ Li,040 PSay (cTRB)->ITEMSA 
				
				@ Li,031 PSay TNF->TNF_NUMSA  
				@ Li,040 PSay TNF->TNF_ITEMSA 
				
				TNF->(DbGoTo(_nRegAtu)) 
				
				
			EndIf 

			If (cTRB)->BIOMET == 1 .Or. Valtype(aRegs695) == "A"
				If lDevol .And. (cTRB)->BIOMET == 2
					@ Li,195 PSay "Ass.: _________________" // STR0076 
				Else
					@ Li,199 PSay "Registro Biométrico" // STR0086
				EndIf					
	   		Else
	   			If mv_par18 == 1
					@ Li,195 PSay "Ass.: _________________" // STR0076 
				EndIf	
			EndIf
				
			@ Li,220 PSay "|"
			nVolta++
			DBSELECTAREA(cTRB)
			DBSKIP()
		ENDDO
		DBSKIP(-1)
		
		//termo
		dbSelectArea("TMZ")
		dbSetOrder(01)
		If dbSeek(xFilial("TMZ")+MV_PAR06)
			RMDT004S()
			@ Li,000 PSay "|"
			@ Li,001 PSay Replicate("_",219)
			@ Li,220 PSay "|"
			RMDT004S()
			@ Li,000 PSay "|"
			@ Li,098 PSay "TERMO DE RESPONSABILIDADE" // STR0041 
			@ Li,220 PSay "|"
			RMDT004S()
			@ Li,000 PSay "|"
			lPrimeiro := .T.
			
			nLinhasMemo := MLCOUNT(TMZ->TMZ_DESCRI,219)
			For LinhaCorrente := 1 to nLinhasMemo
				If lPrimeiro
					if !empty((MemoLine(TMZ->TMZ_DESCRI,56,LinhaCorrente)))
						@ Li,001 PSAY (MemoLine(TMZ->TMZ_DESCRI,219,LinhaCorrente))
						@ Li,220 PSay "|"
						lPrimeiro := .f.
					Else
						Exit
					Endif
				Else
					@ Li,000 PSay "|"
					@ Li,001 PSAY (MemoLine(TMZ->TMZ_DESCRI,219,LinhaCorrente))
					@ Li,220 PSay "|"
				EndIf
				RMDT004S()
			Next
			If !lPrimeiro
				@ Li,000 PSay "|"
			Endif
			@ Li,220 PSay "|"
		EndIf
		// fim do termo
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Data : ____/____/____" // STR0036
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Assinatura: _______________________" // STR0037 
		@ Li,127 PSay "Resp Empr: _______________________" // STR0088 
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		LI := 80
		If mv_par07 == 2 .and. lPrimvez
			DbSelectArea(cTRB)
			DbSkip(-(nVolta-1))
			lPrimvez := .f.
		Else
			DbSelectArea(cTRB)
			DbSkip()
			lPrimvez := .t.
		EndIf
		
	End
Endif

Return

/*
===============================================================================================================================
Programa----------: RMDT004A
Autor-------------: TOTVS
Data da Criacao---: 20/09/2000
===============================================================================================================================
Descrição---------: Armazena informacoes de um recibo para impressao.
===============================================================================================================================
Parametros--------: cCodFil - Codigo da Filial 
                    cNomFil - Nome da Filial 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT004A(cCodFil, cNomFil)

Local nW := 0
Local _nQtdDevolv, _dDtDevolv, _aRetQtdDev

Default cCodFil := "", cNomFil := ""

If lSigaMdtps
	
	DBSELECTAREA("TN3")
	DBSETORDER(5)  //TN3_FILIAL+TN3_CLIENT+TN3_LOJACL+TN3_FORNEC+TN3_LOJA+TN3_CODEPI+TN3_NUMCAP
	DBSEEK(XFILIAL("TN3")+TNF->TNF_CLIENT+TNF->TNF_LOJACL+TNF->TNF_FORNEC+TNF->TNF_LOJA+TNF->TNF_CODEPI+TNF->TNF_NUMCAP)
	
	DbSelectArea("SRA")
	DbSetOrder(01)
	DbSeek(xFilial("SRA")+cFuncMat)
	
	dbSelectArea(cTRB)
	(cTRB)->(DbAppend())
	(cTRB)->FUNCI    := cFuncMat
	(cTRB)->NOME     := SubStr(SRA->RA_NOME,1,40)
	(cTRB)->RG       := SRA->RA_RG
	(cTRB)->CATFUNC  := SRA->RA_CATFUNC
	(cTRB)->NASC     := SRA->RA_NASC
	(cTRB)->ADMIS    := SRA->RA_ADMISSA
	(cTRB)->IDADE    := R555ID( ( cTRB )->NASC )
	(cTRB)->CC       := SRA->RA_CC
	(cTRB)->DESCC    := NgSeek(cAliasCC,(cTRB)->CC,1,cDescCC)
	(cTRB)->FUNCAO   := SRA->RA_CODFUNC
	(cTRB)->DESCFUN  := Alltrim (NgSeek("SRJ",(cTRB)->FUNCAO,1,"SRJ->RJ_DESC"))
	(cTRB)->CODEPI   := TNF->TNF_CODEPI
	(cTRB)->DESEPI   := NgSeek("SB1",TNF->TNF_CODEPI,1,"SB1->B1_DESC")
	(cTRB)->DTENT    := TNF->TNF_DTENTR
	(cTRB)->HRENT    := TNF->TNF_HRENTR
	(cTRB)->QTDE     := TNF->TNF_QTDENT 
	(cTRB)->DEV      := TNF->TNF_INDDEV
	(cTRB)->NUMCAP   := TNF->TNF_NUMCAP
	(cTRB)->NRRECNO  := TNF->(Recno()) 

	If lDevol	//Se for recibo de Devolução
		If TNF->TNF_DEVBIO == "1"
			(cTRB)->BIOMET   := 1
		Else
			(cTRB)->BIOMET   := 2
		EndIf	
	Else
		(cTRB)->BIOMET   := If(!Empty(TNF->TNF_DIGIT1),1,2)
	EndIf
	(cTRB)->NUMCRI := TN3->TN3_NUMCRI
	(cTRB)->NUMCRF := TN3->TN3_NUMCRF
	(cTRB)->DTDEVO := TNF->TNF_DTDEVO
	If lGera_SA
		(cTRB)->NUMSA  := TNF->TNF_NUMSA
		(cTRB)->ITEMSA := TNF->TNF_ITEMSA
	EndIf
	
	(cTRB)->CLIENT    := TNF->TNF_CLIENT
	(cTRB)->LOJA      := TNF->TNF_LOJACL
	
Else
	
	DBSELECTAREA("TN3")
	DBSETORDER(1)
	DBSEEK(XFILIAL("TN3",cCodFil)+TNF->TNF_FORNEC+TNF->TNF_LOJA+TNF->TNF_CODEPI+TNF->TNF_NUMCAP)
	
	DbSelectArea("SRA")
	DbSetOrder(01)
	DbSeek(xFilial("SRA",cCodFil)+cFuncMat)

	DbSelectArea(cAliasCC)
	DbSetOrder(01)
	DbSeek(xFilial(cAliasCC,cCodFil)+SRA->RA_CC)

	DbSelectArea("SRJ")
	DbSetOrder(01)
	DbSeek(xFilial("SRJ",cCodFil)+SRA->RA_CODFUNC)

	DbSelectArea("SB1")
	DbSetOrder(01)
	DbSeek(xFilial("SB1",cCodFil)+TNF->TNF_CODEPI)
				
	If Len(aDevParc) > 0 .And.; //Caso seja devolução parcial. 
	   aScan( aDevParc , { | x | x[ 1 ] == TNF->TNF_FILIAL .And.;
	   						 x[ 2 ] == TNF->TNF_CODEPI .And.;
	   					     x[ 3 ] == TNF->TNF_FORNEC .And.;
	   						 x[ 4 ] == TNF->TNF_LOJA .And.;
	   						 x[ 5 ] == TNF->TNF_NUMCAP .And.;
	   						 x[ 6 ] == TNF->TNF_MAT .And.;
	   						 x[ 7 ] == TNF->TNF_DTENTR .And.;
	   						 x[ 8 ] == TNF->TNF_HRENTR } )//Caso Epi estaja em uso, verifica a devolução Parcial.
	
		For nW := 1 To Len(aDevParc)
			If aDevParc[nW,1] == TNF->TNF_FILIAL .And. aDevParc[nW,2] == TNF->TNF_CODEPI .And.;
			   aDevParc[nW,3] == TNF->TNF_FORNEC .And. aDevParc[nW,4] == TNF->TNF_LOJA .And.;
			   aDevParc[nW,5] == TNF->TNF_NUMCAP .And. aDevParc[nW,6] == TNF->TNF_MAT .And.;
			   aDevParc[nW,7] == TNF->TNF_DTENTR .And. aDevParc[nW,8] == TNF->TNF_HRENTR
			   
			 	dbSelectArea(cTRB)
				(cTRB)->(DbAppend())
				(cTRB)->FUNCI    := cFuncMat
				(cTRB)->NOME     := SubStr(SRA->RA_NOME,1,40)
				(cTRB)->RG       := SRA->RA_RG
				(cTRB)->CATFUNC  := SRA->RA_CATFUNC
				(cTRB)->NASC     := SRA->RA_NASC
				(cTRB)->ADMIS    := SRA->RA_ADMISSA
				(cTRB)->IDADE    := R555ID( ( cTRB )->NASC )
				(cTRB)->CC       := SRA->RA_CC
				(cTRB)->DESCC    := AllTrim(&(cDescCC))
				(cTRB)->FUNCAO   := SRA->RA_CODFUNC
				(cTRB)->DESCFUN  := Alltrim(SRJ->RJ_DESC)
				(cTRB)->CODEPI   := TNF->TNF_CODEPI
				(cTRB)->DESEPI   := AllTrim(SB1->B1_DESC)
				(cTRB)->DTENT    := TNF->TNF_DTENTR
				(cTRB)->HRENT    := TNF->TNF_HRENTR
				(cTRB)->QTDE     := aDevParc[nW,11]//TNF->TNF_QTDENT
				(cTRB)->DEV      := "1"
				(cTRB)->DTDEVO   := aDevParc[nW,9]
				(cTRB)->NUMCAP   := TNF->TNF_NUMCAP
				(cTRB)->NRRECNO  := TNF->(Recno()) 
				
				If lDevol	//Se for recibo de Devolução
					If TNF->TNF_DEVBIO == "1"
						(cTRB)->BIOMET   := 1
					Else
						(cTRB)->BIOMET   := 2
					EndIf	
				Else
					(cTRB)->BIOMET   := If(!Empty(TNF->TNF_DIGIT1),1,2)
				EndIf
				(cTRB)->NUMCRI := TN3->TN3_NUMCRI
				(cTRB)->NUMCRF := TN3->TN3_NUMCRF
				If lGera_SA
					(cTRB)->NUMSA  := TNF->TNF_NUMSA
					(cTRB)->ITEMSA := TNF->TNF_ITEMSA
				EndIf
				(cTRB)->FILIAL    := xFilial("SRA",cCodFil)
				(cTRB)->NOMFIL    := cNomFil  
			EndIf
		Next nW 
	Else //Caso seja devolução total.
	
        _nQtdDevolv := 0
        
        If lDevol
           _aRetQtdDev := RMDT004Q()
           _nQtdDevolv := _aRetQtdDev[1] 
           _dDtDevolv  := _aRetQtdDev[2] 
        Else
           _nQtdDevolv := TNF->TNF_QTDENT 
           _dDtDevolv  := TNF->TNF_DTDEVO 
        EndIf	
	
		dbSelectArea(cTRB)
		(cTRB)->(DbAppend())
	    (cTRB)->FUNCI    := cFuncMat
	    (cTRB)->NOME     := SubStr(SRA->RA_NOME,1,40)
	    (cTRB)->RG       := SRA->RA_RG
	    (cTRB)->CATFUNC  := SRA->RA_CATFUNC
	    (cTRB)->NASC     := SRA->RA_NASC
	    (cTRB)->ADMIS    := SRA->RA_ADMISSA
	    (cTRB)->IDADE    := R555ID( ( cTRB )->NASC )
	    (cTRB)->CC       := SRA->RA_CC
	    (cTRB)->DESCC    := AllTrim(&(cDescCC))
	    (cTRB)->FUNCAO   := SRA->RA_CODFUNC
	    (cTRB)->DESCFUN  := Alltrim(SRJ->RJ_DESC)
	    (cTRB)->CODEPI   := TNF->TNF_CODEPI
	    (cTRB)->DESEPI   := AllTrim(SB1->B1_DESC)
	    (cTRB)->DTENT    := TNF->TNF_DTENTR
	    (cTRB)->HRENT    := TNF->TNF_HRENTR
	    (cTRB)->QTDE     := _nQtdDevolv  
	    (cTRB)->DEV      := TNF->TNF_INDDEV
	    (cTRB)->DTDEVO   := _dDtDevolv  
	    (cTRB)->NUMCAP   := TNF->TNF_NUMCAP
	    (cTRB)->NRRECNO  := TNF->(Recno()) 
	    
	    If lDevol	//Se for recibo de Devolução
		   If TNF->TNF_DEVBIO == "1"
			  (cTRB)->BIOMET   := 1
		   Else
			  (cTRB)->BIOMET   := 2
		   EndIf	
	    Else
	       (cTRB)->BIOMET   := If(!Empty(TNF->TNF_DIGIT1),1,2)
	    EndIf
	   (cTRB)->NUMCRI := TN3->TN3_NUMCRI
	   (cTRB)->NUMCRF := TN3->TN3_NUMCRF
	   If lGera_SA
	      (cTRB)->NUMSA  := TNF->TNF_NUMSA
	      (cTRB)->ITEMSA := TNF->TNF_ITEMSA
	   EndIf
	   (cTRB)->FILIAL    := xFilial("SRA",cCodFil)
	   (cTRB)->NOMFIL    := cNomFil
    EndIf
Endif

Return

/*
===============================================================================================================================
Programa----------: RMDT004O
Autor-------------: TOTVS
Data da Criacao---: 20/09/2000
===============================================================================================================================
Descrição---------: Impressao do relatorio sintérico.
===============================================================================================================================
Parametros--------: cCodFil - Codigo da Filial 
                    cNomFil - Nome da Filial 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT004O()
Local lPrimvez := .t.

If lSigaMdtps
	
	DBSELECTAREA(cTRB)
	If mv_par12 == 1  //Matricula
		dbSetOrder(1)
	Elseif mv_par12 == 2  //Nome Funcionario
		dbSetOrder(2)
	Elseif mv_par12 == 3  //Cod. C. Custo
		dbSetOrder(3)
	Elseif mv_par12 == 4  //Nome C. Custo
		dbSetOrder(4)
	Endif
	
	Dbgotop()
	
	DO WHILE !EOF()
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+(cTRB)->CLIENT+(cTRB)->LOJA)
		
		CFUNC := (cTRB)->FUNCI
		nVolta := 0
		RMDT004S()
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|Funcionario.....:" // STR0010 
		@ Li,019 PSay CFUNC PICTURE "@!"
		@ Li,026 PSAY " - " + (cTRB)->NOME
		@ Li,127 PSay "RG.:" // STR0011 
		@ Li,132 PSay (cTRB)->RG PICTURE "@!"
		@ Li,220 PSay "|"
		lLinha := .f.
		lFirst := .t.
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,001 PSay "EPI" // STR0017     
		@ Li,017+nDist PSay "Nome do EPI" // STR0018
		@ Li,160+nDist PSay "Qtde" // STR0025 
		@ Li,181+nDist PSay "Num C.A." // STR0026
		@ Li,220 Psay "|"
		DBSELECTAREA(cTRB)
		While !Eof() .AND. (cTRB)->FUNCI == CFUNC
			cCodNumEpi := (cTRB)->CODEPI
			cDescEpi := substr(alltrim((cTRB)->DESEPI),1,80)
			nQuant := 0
			cCodNumCap := (cTRB)->NUMCAP

			DBSELECTAREA(cTRB)
 			While !Eof() .AND. (cTRB)->FUNCI == CFUNC .And. (cTRB)->CODEPI + (cTRB)->NUMCAP == cCodNumEpi + cCodNumCap
 				nQuant += (cTRB)->QTDE
				DBSELECTAREA(cTRB)
				DBSKIP()
				nVolta++	 			
	 		Enddo
			If lLinha .and. lFirst
				@ Li,220 Psay "|"
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			If !lFirst
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			lFirst := .f.
			@ Li,001 PSAY cCodNumEpi
			@ Li,017+nDist PSay cDescEpi PICTURE "@!"
			@ Li,158+nDist PSay nQuant  PICTURE "@E 999.99"
			If !Empty(cCodNumCap)
				@ Li,181+nDist PSay cCodNumCap
			EndIf
			If lLinha
				@ Li,220 Psay "|"
				RMDT004S()
				@ Li,000 Psay "|"
			EndIf
			nVolta++
			DBSELECTAREA(cTRB)
			DBSKIP()
			@ Li,220 PSay "|"
		ENDDO
		DBSKIP(-1)
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Data : ____/____/____" // STR0036 
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Assinatura: _______________________" // STR0037
		@ Li,127 PSay "Resp Empr: _______________________" // STR0088 
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		LI := 80
		If mv_par11 == 2 .and. lPrimvez
			DbSelectArea(cTRB)
			DbSkip(-(nVolta-1))
			lPrimvez := .f.
		Else
			DbSelectArea(cTRB)
			DbSkip()
			lPrimvez := .t.
		EndIf
		
	EndDo
	
Else
	
	DBSELECTAREA(cTRB)
	If mv_par08 == 1  //Matricula
		dbSetOrder(1)
	Elseif mv_par08 == 2  //Nome Funcionario
		dbSetOrder(2)
	Elseif mv_par08 == 3  //Cod. C. Custo
		dbSetOrder(3)
	Elseif mv_par08 == 4  //Nome C. Custo
		dbSetOrder(4)
	Endif
	
	Dbgotop()
	
	WHILE !EOF()
		
		CFUNC := (cTRB)->FUNCI
		nVolta := 0
		RMDT004S()
		@ Li,000 PSay " "+Replicate("_",219)
		RMDT004S()
		@ Li,000 PSay "|Funcionario.....:" // STR0010 
		@ Li,019 PSay CFUNC PICTURE "@!"
		@ Li,026 PSAY " - " + (cTRB)->NOME
		@ Li,127 PSay "RG.:" // STR0011 
		@ Li,132 PSay (cTRB)->RG PICTURE "@!"
		@ Li,220 PSay "|"
		
		lLinha := .f.
		lFirst := .t.
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,001 PSay "EPI" // STR0017     
		@ Li,017+nDist PSay "Nome do EPI" // STR0018 
		@ Li,160+nDist PSay "Qtde" // STR0025  
		@ Li,181+nDist PSay "Num C.A." // STR0026
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		DBSELECTAREA(cTRB)
		While !Eof() .AND. (cTRB)->FUNCI == CFUNC
			cCodNumEpi := (cTRB)->CODEPI
			cDescEpi := substr(alltrim((cTRB)->DESEPI),1,80)
			nQuant := 0
			cCodNumCap := (cTRB)->NUMCAP

			DBSELECTAREA(cTRB)
 			While !Eof() .AND. (cTRB)->FUNCI == CFUNC .And. (cTRB)->CODEPI + (cTRB)->NUMCAP == cCodNumEpi + cCodNumCap
 				nQuant += (cTRB)->QTDE
				DBSELECTAREA(cTRB)
				DBSKIP()
				nVolta++	 			
	 		Enddo
	 		
			If lLinha .and. lFirst
				@ Li,220 Psay "|"
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			If !lFirst
				RMDT004S()
				@ Li,000 PSay "|"
			EndIf
			lFirst := .f.
			@ Li,001 PSAY cCodNumEpi
			@ Li,017+nDist PSay cDescEpi PICTURE "@!"
			@ Li,158+nDist PSay nQuant  PICTURE "@E 999.99"
			If !Empty(cCodNumCap)
				@ Li,181+nDist PSay cCodNumCap
			EndIf
			If lLinha
				@ Li,220 Psay "|"
				RMDT004S()
				@ Li,000 Psay "|"
			EndIf
			DBSELECTAREA(cTRB)
			@ Li,220 Psay "|"
		ENDDO
		DBSKIP(-1)
		
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Data : ____/____/____" // STR0036 
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,220 PSay "|"
		RMDT004S()
		@ Li,000 PSay "|       Assinatura: _______________________" // STR0037 
		@ Li,127 PSay "Resp Empr: _______________________" // STR0088 
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 Psay "|"
		@ Li,220 Psay "|"
		RMDT004S()
		@ Li,000 PSay "|"
		@ Li,001 PSay Replicate("_",219)
		@ Li,220 PSay "|"
		LI := 80
		If mv_par07 == 2 .and. lPrimvez
			DbSelectArea(cTRB)
			DbSkip(-(nVolta-1))
			lPrimvez := .f.
		Else
			DbSelectArea(cTRB)
			DbSkip()
			lPrimvez := .t.
		EndIf
		
	End
Endif

Return

/*
===============================================================================================================================
Programa----------: RMDT004Q
Autor-------------: Julio de Paula Paz
Data da Criacao---: 10/11/2017
===============================================================================================================================
Descrição---------: Lê as quantidades de devolução de EPI na tabela TLW para impressão no relatório.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT004Q()
Local _aRet := 0
Local _aOrd := SaveOrd({"TLW"})
Local _nRegAtu := TLW->(Recno())
Local _nQtdEntr, _nDtEntr

Begin Sequence
   _nQtdEntr := 0
   _nDtEntr  := CtoD("  /  /  ")
   
   TLW->(DbSetOrder(1)) // TLW_FILIAL+TLW_FORNEC+TLW_LOJA+TLW_CODEPI+TLW_NUMCAP+TLW_MAT+DTOS(TLW_DTENTR)+TLW_HRENTR+DTOS(TLW_DTDEVO)+TLW_HRDEVO  
   // TNF_FILIAL+TNF_FORNEC+TNF_LOJA+TNF_CODEPI+TNF_NUMCAP+TNF_MAT+DTOS(TNF_DTENTR)+TNF_HRENTR 
   TLW->(DbSeek(TNF->(TNF_FILIAL+TNF_FORNEC+TNF_LOJA+TNF_CODEPI+TNF_NUMCAP+TNF_MAT+DTos(TNF_DTENTR)+TNF_HRENTR)))
   
   Do While ! TLW->(Eof()) .And. TLW->(TLW_FILIAL+TLW_FORNEC+TLW_LOJA+TLW_CODEPI+TLW_NUMCAP+TLW_MAT+DTOS(TLW_DTENTR)+TLW_HRENTR) ==;
                                 TNF->(TNF_FILIAL+TNF_FORNEC+TNF_LOJA+TNF_CODEPI+TNF_NUMCAP+TNF_MAT+DTos(TNF_DTENTR)+TNF_HRENTR)
      _nQtdEntr := TLW->TLW_QTDEVO
      _nDtEntr  := TLW->TLW_DTDEVO
      
      TLW->(DbSkip())
   EndDo
   _aRet := {_nQtdEntr,_nDtEntr}

End Sequence

RestOrd(_aOrd)
TLW->(DbGoto(_nRegAtu))

Return _aRet