/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/09/2019 | Retirada chamada da fun��o itputx1. Chamado 28346 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================================================================
Programa----------: RGPE011
Autor-------------: Lucas Crevilari
Data da Criacao---: 07/07/2014
===============================================================================================================================
Descri��o---------: Relat�rio de benef�cios dos funcion�rios
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGPE011

Private nQtdFun		:= 0
Private nQtdDep		:= 0
Private nQtdVid		:= 0
Private oReport 
Private cFolMes 	:= GetMv( "MV_FOLMES",,Space(08) ) 

If TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf 

Return

/*
===============================================================================================================================
Programa----------: RGPE011
Autor-------------: Lucas Crevilari
Data da Criacao---: 07/07/2014
===============================================================================================================================
Descri��o---------: Relat�rio de benef�cios dos funcion�rios
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef()

Local oSection1
Local oSection2
Local oBreak    
Local oBreak2

oReport:= TReport():New("RGPE011","Relatorio do Calculo de Planos de Saude","RGPE011",{|oReport| ReportPrint(oReport) },"Relatorio de Beneficios")
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)                                                

//===========================================================================
//| Defini��o das Se��es do relatorio               |
//===========================================================================
oSection1 := TRSection():New(oReport, "Beneficios"	,{"SRA","RHK","RHR","RHP"})  
oSection2 := TRSection():New(oSection1, "Contadores"	,{"RHK"})  

//===========================================================================
//| Defini�ao das Celulas do relatorio - Section1
//===========================================================================

TRCell():New(oSection1,"FILIAL","SRA",	"Filial",,5)
TRCell():New(oSection1,"CCUSTO","SRA",	"C. Custo",,10)
TRCell():New(oSection1,"TIPO","SRA",	"Tipo",,13)
TRCell():New(oSection1,"MAT","SRA",		,,TamSX3("RA_MAT")[1]+1)
TRCell():New(oSection1,"NOME","SRA", 	,PesqPict("SRA","RA_NOME"),TamSX3("RA_NOME")[1]+1)
TRCell():New(oSection1,"TPLAN","RHP",	,,15)
TRCell():New(oSection1,"TPFORN","RHK",	,,15)
TRCell():New(oSection1,"CODFOR","RHK",	,,28)
TRCell():New(oSection1,"TPPLAN","RHK",	,,20)
TRCell():New(oSection1,"PLANO","RHK",	,,24)
TRCell():New(oSection1,"PERINI","RHK",	,,8)
TRCell():New(oSection1,"PERFIM","RHK",	,,8)
TRCell():New(oSection1,"VLRFUN","RHR",	,PesqPict("RHR","RHR_VLRFUN"),TamSX3("RHR_VLRFUN")[1]+1)
TRCell():New(oSection1,"VLREMP","RHR",	,PesqPict("RHR","RHR_VLRFUN"),TamSX3("RHR_VLREMP")[1]+1)
TRCell():New(oSection1,"VLRCOPAR","RHO","Vlr Co-Particip.",PesqPict("RHR","RHR_VLRFUN"),TamSX3("RHO_VLRFUN")[1]+1) 

TRCell():New(oSection2,"QTDFUN","RHK","Qtd Funcionarios",,4,/*lPixel*/)
TRCell():New(oSection2,"QTDDEP","RHK","Qtd Dependentes",,4,/*lPixel*/)
TRCell():New(oSection2,"QTDVID","RHK","Qtd Vidas",,4,/*lPixel*/)         

//===========================================================================
//| Defini�ao das quebras e soma das colunas                                |
//===========================================================================
                                                                                                                                
oBreak := TRBreak():New(oSection1,oSection1:Cell("CCUSTO"),,.F.) // "Quebra por Centro de Custo"
oBreak:bOnBreak:={||oReport:SkipLine(1),oReport:PrintText("T O T A L  C E N T R O  D E  C U S T O",,)}
TRFunction():New( oSection1:Cell("VLRFUN") , "TOTAL CCUSTO" , "SUM" , oBreak ,, PesqPict("RHR","RHR_VLRFUN") ,, .F. , .F. )     
TRFunction():New( oSection1:Cell("VLREMP") , "TOTAL CCUSTO" , "SUM" , oBreak ,, PesqPict("RHR","RHR_VLRFUN") ,, .F. , .F. ) 
TRFunction():New( oSection1:Cell("VLRCOPAR") , "TOTAL CCUSTO" , "SUM" , oBreak ,, PesqPict("RHR","RHR_VLRFUN") ,, .F. , .F. )      

oBreak2 := TRBreak():New(oSection1,oSection1:Cell("FILIAL"),,.F.) // "Quebra por filial"
oBreak2:bOnBreak:={||oReport:SkipLine(2),oReport:PrintText("T O T A L  F I L I A L",,)}
TRFunction():New( oSection1:Cell("VLRFUN") , "TOTAL FILIAL" , "SUM" , oBreak2 ,, PesqPict("RHR","RHR_VLRFUN") ,, .F. , .F. )     
TRFunction():New( oSection1:Cell("VLREMP") , "TOTAL FILIAL" , "SUM" , oBreak2 ,, PesqPict("RHR","RHR_VLRFUN") ,, .F. , .F. ) 
TRFunction():New( oSection1:Cell("VLRCOPAR") , "TOTAL FILIAL" , "SUM" , oBreak2 ,, PesqPict("RHR","RHR_VLRFUN") ,, .F. , .F. ) 

oSection1:SetTotalInLine(.F.)
oSection2:SetTotalInLine(.F.)

Return oReport

/*
===============================================================================================================================
Programa----------: RGPE011
Autor-------------: Lucas Crevilari
Data da Criacao---: 07/07/2014
===============================================================================================================================
Descri��o---------: Impressao do relatorio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)

//===========================================================================
//| Define Variaveis Locais (Programa)                   				    |
//===========================================================================

Local cArqRHP	 	:= ""
Local cQuery	 	:= ""
Local cOrder	 	:= ""
Local cIndKeyRHP	:= ""
Local cInicio  		:= ""
Local cFim     		:= ""
Local cFilSRACTT	:= FWJoinFilial( "SRA", "CTT" )
Local nIndexRHP		:= 0

Private cAliasQ		:= "SRA"
Private cFilialAnt 	:= "  "
Private cCcAnt     	:= Space(20)
Private cMatAnt    	:= space(08)
Private cTpOrigem	:= ""
Private cCodUsu		:= ""
Private cAntMat 	:= ""
Private lExeQry 	:= .F.

Private aCC			:= {}
Private aFil		:= {}
Private aEmp		:= {}
Private cAliasRHP 	:= "RHP"
Private cAliasMov 	:= "RHR"
Private cSvMov	 	:= "RHR"
Private _cAlias		:= "RHO"
Private lTotal		:= .F.        
Private cTipo  		:= ""
Private cMat		:= ""
Private _cNome		:= ""
Private cTpLan		:= ""                                              
Private cTpForn		:= ""
Private cForn		:= ""
Private cTpPlan		:= ""
Private cPlano		:= ""
Private cPerIni		:= ""
Private cPerFim		:= ""
Private cVlrFun		:= ""
Private cVlrEmp		:= ""
Private cVlrCop		:= ""
Private nQtdFun		:= 0
Private nQtdDep		:= 0
Private nQtdVid		:= 0 
Private _cCcusto 	:= ""   
Private lErro 		:= .F.
Private cDepen		:= ""

TRFunction():New(oSection1:Cell("VLRFUN"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("RHR","RHR_VLRFUN"),/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)  
TRFunction():New(oSection1:Cell("VLREMP"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("RHR","RHR_VLREMP"),/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection1:Cell("VLRCOPAR"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("RHO","RHO_VLRFUN"),/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

//===========================================================================
//| Carregando variaveis mv_par?? para Variaveis do Sistema.                |
//===========================================================================

dDataRef	:=	mv_par01	//	Data de Referencia
cAnoMes		:=	Substr(DTOS( dDataRef ), 1, 6)
cFilDe     	:= mv_par02 	// Filial De
cFilAte    	:= mv_par03		// Filial Ate
cMatDe     	:= mv_par04		// Matricula De
cMatAte    	:= mv_par05		// Matricula Ate
cCcDe      	:= mv_par06		// Centro de Custo De
cCcAte     	:= mv_par07		// Centro de Custo Ate
cTpPlano	:= mv_par08		// Tipo do plano 1- Medico, 2- Odontologico, 3- Ambos
cSituacao  	:= mv_par09		// Situacao do Funcionario
cDepen 		:= mv_par10 	// Gera somente de funcionarios com dependentes? 1- Sim, 2- Nao, 3-Ambos
lMovAberto 	:= .T.

If cAnoMes < cFolMes
	lMovAberto := .F.
EndIf


If !lMovAberto
	cAliasMov := "RHS"
	cSvMov 	  := "RHS"
	_cAlias	  := "RHP"
EndIf

#IFDEF TOP
	lExeQry		:= 	!ExeInAs400()
#ENDIF

DbSelectArea( "SRA" )
If !lExeQry
	//Cria indice temporario para buscar pela filial+mat+competencia
	DbSelectArea( cAliasRHP )
	DbSetOrder( 1 )
	cIndKeyRHP	:= "RHP_FILIAL+RHP_MAT+RHP_COMPPG+RHP_ORIGEM+RHP_CODIGO+RHP_TPLAN+RHP_TPFORN+RHP_CODFOR+RHP_PD"
	cArqRHP		:= CriaTrab( Nil, .F. )
	IndRegua( "RHP", cArqRHP, cIndKeyRHP, , , , .F. )
	nIndexRHP	:= RHP->( RetIndex( ) ) + 1
	DbSetOrder( nIndexRHP )
Else
	cAliasQ		:= "QSRA"
	cOrder	:= "1, 4, 2, 8, 9, 10"
	
	// Converter string em condicao de IN (Query)
	cSituacao  	:= fSqlIN( cSituacao, 1 )	// Situacao do Funcionario
	
	// Monta query de selecao da informacao
	cQuery	:= "SELECT DISTINCT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CC, SRA.RA_ADMISSA,  "
	cQuery	+= "CTT.CTT_CUSTO, CTT.CTT_DESC01 CTT_DESC01, MOV." + cAliasMov + "_ORIGEM ORIGEM, "
	If cAliasMov == "RHM" .or. cAliasMov == "RHK" .or. cAliasMov == "RHL"
		cQuery  += "MOV." + cAliasMov + "_CODIGO CODIGO, MOV." + cAliasMov + "_TPFORN TPFORN,MOV." + cAliasMov + "_PERINI PERINI,MOV." + cAliasMov + "_PERFIM PERFIM MOV.* "
	Else
		cQuery  += "MOV." + cAliasMov + "_CODIGO CODIGO, MOV." + cAliasMov + "_TPFORN TPFORN, MOV.* "
	Endif
	cQuery	+= "FROM "+RetSqlName(cAliasMov)+" MOV "
	cQuery  += "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery  += "ON MOV." + cAliasMov + "_FILIAL = SRA.RA_FILIAL "
	cQuery  += "AND MOV." + cAliasMov + "_MAT = SRA.RA_MAT "
	cQuery  += "LEFT JOIN " + RetSqlName("CTT") + " CTT "
	If ! Empty( xFilial( "CTT" ) )
		cQuery  += "ON " + %exp:cFilSRACTT% + " AND "
	Else
		cQuery	+= "ON "
	EndIf
	cQuery	+= "SRA.RA_CC = CTT.CTT_CUSTO "
	cQuery	+= "WHERE "
	cQuery	+= "SRA.RA_FILIAL BETWEEN '"	+ cFilDe	+"' AND '" + cFilAte	+ "' "
	If cTpPlano == 1 //Tipo: Medico
		cQuery += " AND MOV."+cAliasMov+"_TPPLAN = '3' "
		cQuery += " AND MOV."+cAliasMov+"_TPFORN = '1' "
	Elseif cTpPlano == 2 //Tipo: Odontologico
		cQuery += " AND MOV."+cAliasMov+"_TPPLAN = '1' "
		cQuery += " AND MOV."+cAliasMov+"_TPFORN = '2' "
	Elseif cTpPlano ==  3 //Tipo: Ambos
		cQuery += " AND MOV."+cAliasMov+"_TPPLAN IN('3','1')"
	Endif
	cQuery	+= " AND SRA.RA_MAT BETWEEN '"	+ cMatDe	+"' AND '" + cMatAte	+ "' "
	cQuery	+= " AND SRA.RA_CC BETWEEN '"	+ cCcDe		+"' AND '" + cCcAte		+ "' "
	cQuery	+= " AND SRA.RA_SITFOLH IN("		+ cSituacao	+") "
	cQuery	+= " AND MOV." + cAliasMov + "_COMPPG = '" + cAnoMes + "' "
	If !lMovAberto
		cQuery	+= "AND MOV." + "RHS_TPLAN = '1' "
	EndIf
	cQuery	+= " AND MOV.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND SRA.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND CTT.D_E_L_E_T_ = ' '  "
	cQuery	+= "ORDER BY " + cOrder
	cQuery	:= ChangeQuery( cQuery )
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQ, .F., .T.)
EndIf

dbSelectArea( cAliasQ )

cAntMat := ""

While !(cAliasQ)->(Eof()) .And. If( lExeQry, .T., &(cInicio) <= cFim )
	
	cCcDesc	:= "" // Ao ocorrer a troca de filiais, nao sera 'carregado' a descricao do centro de custo utilizado anteriormente.
	
	//===========================================================================
	//| Movimenta Regua Processamento                          				    |
	//===========================================================================
	
	If lEnd
		Exit
	EndIf
	
	If cAntMat <> ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_MAT
		cAntMat := ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_MAT
		cCodUsu		:= ""
		cTpOrigem	:= ""
		//Se a competencia selecionada ja estiver fechada
		If !lMovAberto .And. lExeQry
			// Monta query de selecao da informacao
			cQuery	:= " SELECT *"
			cQuery	+= " FROM "+RetSqlName(cAliasRHP)+" RHP "
			cQuery	+= " WHERE "
			cQuery	+= " RHP.RHP_FILIAL = '"	+ ( cAliasQ )->RA_FILIAL +"'"
			cQuery	+= " AND RHP.RHP_MAT = '"	+ ( cAliasQ )->RA_MAT + "' "
			cQuery	+= " AND RHP.RHP_COMPPG = '" + cAnoMes + "' "
			cQuery	+= " AND RHP.D_E_L_E_T_ = ' ' "
			
			cQuery	:= ChangeQuery( cQuery )
			
			If Select("RHP") > 0
				(cAliasRHP)->(dbclosearea())
			EndIf
			
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasRHP, .F., .T.)
			
			While !(cAliasRHP)->(Eof()) .And. If( lExeQry, .T., &(cInicio) <= cFim )
				SRA->(DbSeek( ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_MAT ))
				fImpFun(2)
				fTestaTotal(2)
			End Do
			(cAliasRHP)->(dbclosearea())
			dbSelectArea( cAliasQ )
		EndIf
		
	EndIf
	
	If !lExeQry
			
		//===========================================================================
		//| Consiste Parametrizacao do Intervalo de Impressao                       |
		//===========================================================================
		
		If ( ( cAliasQ )->RA_MAT < cMatDe )		.Or. ( ( cAliasQ )->RA_MAT > cMatAte ) 	.Or. ;
			( ( cAliasQ )->RA_CC < cCcDe )   	.Or. ( ( cAliasQ )->RA_CC > cCcAte )	.Or. ;
			!( ( cAliasQ )->RA_SITFOLH $ cSituacao )
			
			dbSelectArea( cAliasQ )
			fTestaTotal()
			Loop
		EndIf
		
		//Se a competencia selecionada ja estiver fechada
		If !lMovAberto
			DbSelectArea( cAliasRHP )
			DbSetOrder( nIndexRHP )
			DbSeek( ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_MAT + cAnoMes, .F. )
			
			While !Eof() .and. (cAliasRHP)->( &(cAliasRHP + "_FILIAL") + &(cAliasRHP + "_MAT") + &(cAliasRHP + "_COMPPG")) == ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_MAT + cAnoMes
				//===========================================================================
				//| Impressao do Funcionario                                                |
				//===========================================================================
								
				SRA->( DbSeek( ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_CC + ( cAliasQ )->RA_MAT ))
				lErro := .F.				
				fImpFun(2)
		        
		        If lErro == .F.
					oSection1:Init()
					oSection1:Cell("FILIAL"):SetValue((cAliasQ)->RA_FILIAL)
					oSection1:Cell("CCUSTO"):SetValue(_cCcusto)				
					oSection1:Cell("TIPO"):SetValue(cTipo)
					oSection1:Cell("MAT"):SetValue(cMat)
					oSection1:Cell("NOME"):SetValue(_cNome)
					oSection1:Cell("TPLAN"):SetValue(cTpLan)
					oSection1:Cell("TPFORN"):SetValue(cTpForn)
					oSection1:Cell("CODFOR"):SetValue(cForn)
					oSection1:Cell("TPPLAN"):SetValue(cTpPlan)
					oSection1:Cell("PLANO"):SetValue(cPlano)
					oSection1:Cell("PERINI"):SetValue(cPerIni)
					oSection1:Cell("PERFIM"):SetValue(cPerFim)
					oSection1:Cell("VLRFUN"):SetValue(VAL(ALLTRIM(cVlrFun)))
					oSection1:Cell("VLREMP"):SetValue(VAL(ALLTRIM(cVlrEmp)))
					oSection1:Cell("VLRCOPAR"):SetValue(VAL(ALLTRIM(cVlrCop)))
					oSection1:PrintLine()  
					oReport:IncMeter()
				Endif					
				fTestaTotal(2)
			EndDo
			cAliasMov := If(!lMovAberto, "RHS", "RHR")
		
		EndIf
		
		DbSelectArea( cAliasMov )
		DbSetOrder( 1 )
		DbSeek( ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_MAT + cAnoMes, .F. )
		If Eof()
			dbSelectArea( cAliasQ )
			fTestaTotal()
			Loop
		EndIf
		
		While !Eof() .and. (cAliasMov)->( &(cAliasMov + "_FILIAL") + &(cAliasMov + "_MAT") + &(cAliasMov + "_COMPPG")) == ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_MAT + cAnoMes
			
			//===========================================================================
			//| Impressao do Funcionario                                                |
			//===========================================================================
			
			SRA->( DbSeek( ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_CC + ( cAliasQ )->RA_MAT ))
			lErro := .F.				
			fImpFun()

	        If lErro == .F.
				oSection1:Init()
				oSection1:Cell("FILIAL"):SetValue((cAliasQ)->RA_FILIAL)
				oSection1:Cell("CCUSTO"):SetValue(_cCcusto)				
				oSection1:Cell("TIPO"):SetValue(cTipo)
				oSection1:Cell("MAT"):SetValue(cMat)
				oSection1:Cell("NOME"):SetValue(_cNome)
				oSection1:Cell("TPLAN"):SetValue(cTpLan)
				oSection1:Cell("TPFORN"):SetValue(cTpForn)
				oSection1:Cell("CODFOR"):SetValue(cForn)
				oSection1:Cell("TPPLAN"):SetValue(cTpPlan)
				oSection1:Cell("PLANO"):SetValue(cPlano)
				oSection1:Cell("PERINI"):SetValue(cPerIni)
				oSection1:Cell("PERFIM"):SetValue(cPerFim)
				oSection1:Cell("VLRFUN"):SetValue(VAL(ALLTRIM(cVlrFun)))
				oSection1:Cell("VLREMP"):SetValue(VAL(ALLTRIM(cVlrEmp)))
				oSection1:Cell("VLRCOPAR"):SetValue(VAL(ALLTRIM(cVlrCop)))
				oSection1:PrintLine()  
				oReport:IncMeter()
			Endif
			DbSelectArea( cAliasMov )
			DbSkip()
		EndDo       
		fTestaTotal()
	Else
		
		//===========================================================================
		//| Impressao do Funcionario                                                |
		//===========================================================================		
		
		SRA->( DbSeek( ( cAliasQ )->RA_FILIAL + ( cAliasQ )->RA_CC + ( cAliasQ )->RA_MAT ))
		lErro := .F.
		fImpFun()
		If lErro == .F.		
			oSection1:Init()
			oSection1:Cell("FILIAL"):SetValue((cAliasQ)->RA_FILIAL)
			oSection1:Cell("CCUSTO"):SetValue(_cCcusto)				
			oSection1:Cell("TIPO"):SetValue(cTipo)
			oSection1:Cell("MAT"):SetValue(cMat)
			oSection1:Cell("NOME"):SetValue(_cNome)
			oSection1:Cell("TPLAN"):SetValue(cTpLan)
			oSection1:Cell("TPFORN"):SetValue(cTpForn)
			oSection1:Cell("CODFOR"):SetValue(cForn)
			oSection1:Cell("TPPLAN"):SetValue(cTpPlan)
			oSection1:Cell("PLANO"):SetValue(cPlano)
			oSection1:Cell("PERINI"):SetValue(cPerIni)
			oSection1:Cell("PERFIM"):SetValue(cPerFim)
			oSection1:Cell("VLRFUN"):SetValue(VAL(ALLTRIM(cVlrFun)))
			oSection1:Cell("VLREMP"):SetValue(VAL(ALLTRIM(cVlrEmp)))
			oSection1:Cell("VLRCOPAR"):SetValue(VAL(ALLTRIM(cVlrCop)))
			oSection1:PrintLine()  
			oReport:IncMeter()
		Endif			      
		fTestaTotal()
	EndIf

EndDo
If !lExeQry
	lTotal:= .T.
	fTestaTotal()
Endif

//===========================================================================
//| Termino do Relatorio 													|
//===========================================================================

oSection1:Finish()                                                                                                     

If lExeQry
	(cAliasQ)->(dbclosearea())
Else
	If File(cArqRHP+OrdBagExt())
		fErase(cArqRHP+OrdBagExt())
	Endif
	RHP->( retIndex() )
EndIf

dbSelectArea("SRA")
dbSetOrder(1)

oSection2:Init()
oSection2:Cell("QTDDEP"):SetValue(nQtdDep)
oSection2:Cell("QTDVID"):SetValue(nQtdVid)
oSection2:Cell("QTDFUN"):SetValue(nQtdFun)
oSection2:PrintLine() 
                               
oSection2:Finish()

Return

/*
===============================================================================================================================
Programa----------: RGPE011
Autor-------------: Lucas Crevilari
Data da Criacao---: 07/07/2014
===============================================================================================================================
Descri��o---------: Impressao de funcionario
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fImpFun(nOpcao)

Local cAliasImp
Local cAtCodUsu
Local cNome		:= ""
Local cTab 		:= "S008"
Local nCol 		:= 13
Local nPosTab
Local lHasDep

Default nOpcao := 1

//Tipo			Matr/Seq Nome							Lancamento  		Tp Fornec		  Fornecedor 			   Tp Plano              Cod Plano  	   Vlr. Func		Vlr. Empresa    Co-Participacao
//1-Titular		xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxx  1-Co-participacao   1-Ass. Odontol.   xx-xxxxxxxxxxxxxxxxxxxx  x-Vlr Fixo por vida   xx-xxxxxxxxxxxxX  999,999,999.99   999,999,999.99   999,999,999.99
//2-Dependente
//3-Agregado


If cDepen == 1 //Sim- Somente com Dependentes
   	DbSelectArea( "RHL" )
	DbSetOrder( RetOrdem( "RHL", "RHL_FILIAL+RHL_MAT"))
	DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT)
	IF( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT <> RHL->RHL_FILIAL + RHL->RHL_MAT) .AND. (cAliasMov)->( &(cAliasMov + "_ORIGEM")) <> "2" 
		lErro := .T.
		Return Nil
	EndIf
	
ElseIf cDepen == 2 //N�o-Somente sem Dependentes
	DbSelectArea( "RHL" )
	DbSetOrder( RetOrdem( "RHL", "RHL_FILIAL+RHL_MAT"))
	DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT)
	IF( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT == RHL->RHL_FILIAL + RHL->RHL_MAT) .AND. (cAliasMov)->( &(cAliasMov + "_ORIGEM")) <> "2" 
	    lErro := .T.
		Return Nil
	EndIf
Endif  
	
If nOpcao == 1
	If lExeQry
		cAliasImp := cAliasQ
	Else
		cAliasImp := cAliasMov
	EndIf
	cAliasMov := cSvMov
Else
	cAliasImp := cAliasRHP
	cAliasMov := cAliasRHP
EndIf

// Impressao Centro de Custo
If lExeQry
	cCcDesc := (cAliasQ)->CTT_DESC01
Else
	cCcDesc := fDesc("CTT",(cAliasQ)->RA_CC,"CTT->CTT_DESC01",30)
EndIf

_cCcusto := ALLTRIM(cCcDesc)
aCC	:=	{} // Limpa o Array, para evitar que sejam somados Centro de Custo com o mesmo codigo, de outras filiais.

// Imprime o cabecalho inicial do primeiro registro a ser impresso.
If Empty(cMatAnt) .And. Empty(cFilialAnt) .And. Empty(cCcAnt)
//	fCabec(1,(cAliasQ)->RA_FILIAL) //-- Filial
	If lExeQry
		cCcDesc := (cAliasQ)->CTT_DESC01
	Else
		cCcDesc := fDesc("CTT",(cAliasQ)->RA_CC,"CTT->CTT_DESC01",30)
	EndIf
//	fCabec(2,(cAliasQ)->RA_CC,cCcDesc)	//-- Centro de custo
EndIf

cMatAnt	:= (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT

// Impressao do Tipo
cTpOrigem	:= (cAliasImp)->( &(cAliasMov + "_ORIGEM" ) )
cCodUsu		:= ""	// Ao trocar Origem limpa o Cod. Usuario para forcar impressao do 1o nome

If cTpOrigem == "1"
	cTipo := cTpOrigem + "-" + "Titular"
	nQtdFun++
ElseIf cTpOrigem == "2"
	cTipo := cTpOrigem + "-" + "Dependente"
	nQtdDep++
Else
	cTipo := cTpOrigem + "-" + "Agregado"
	nQtdDep++
EndIf	
nQtdVid++

// Impressao da matricula/Sequencia + Nome
If cTpOrigem == "1" //Titular
	cAtCodUsu := (cAliasQ)->RA_MAT
Else
	cAtCodUsu := (cAliasImp)->( &(cAliasMov + "_CODIGO" ) )
EndIf

If cCodUsu <> cAtCodUsu
	cCodUsu 	:= cAtCodUsu
	If cTpOrigem == "1" //Titular
		cNome := (cAliasQ)->RA_NOME
	ElseIf cTpOrigem == "2" //Dependente
		DbSelectArea( "SRB" )
		DbSetOrder( RetOrdem( "SRB", "RB_FILIAL+RB_MAT" ) )
		DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT, .F. )
		lHasDep := .F.
		While SRB->( !EOF() ) .and. SRB->RB_FILIAL + SRB->RB_MAT == (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT
			If SRB->RB_COD == cCodUsu
				lHasDep := .T.
				Exit
			EndIf
			SRB->( DbSkip() )
		EndDo
                cNome := SRB->RB_NOME
	Else
		DbSelectArea( "RHM" )
		DbSetOrder( RetOrdem( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO"))
		DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT + (cAliasImp)->(&(cAliasMov + "_TPFORN")) + (cAliasImp)->(&(cAliasMov + "_CODFOR")) + (cAliasImp)->(&(cAliasMov + "_CODIGO")), .F.)
		If !Eof()
			cNome := RHM->RHM_NOME
		EndIf
	EndIf
Endif
cMat := cCodUsu
_cNome := Alltrim(cNome)

// Impressao do Tipo de Lancamentos
If nOpcao == 1
	If (cAliasImp)->( &(cAliasMov + "_TPLAN")) == "1"
		cTpLan := (cAliasImp)->( &(cAliasMov + "_TPLAN")) + "-" + "Planos"
	ElseIf (cAliasImp)->( &(cAliasMov + "_TPLAN")) == "2"
		cTpLan := (cAliasImp)->( &(cAliasMov + "_TPLAN")) + "-" + "Co-Particip."
	Else
		cTpLan := (cAliasImp)->( &(cAliasMov + "_TPLAN")) + "-" + "Reembolso"
	EndIf
Else
	If (cAliasImp)->( &(cAliasMov + "_TPLAN")) == "1"
		cTpLan := "2-" + "Co-Particip."
	Else
		cTpLan := "3-" + "Reembolso"
	EndIf
EndIf

// Impressao do Tipo do Fornecedor
If (cAliasImp)->( &(cAliasMov + "_TPFORN")) == "1"
	cTpForn := (cAliasImp)->( &(cAliasMov + "_TPFORN")) + "-" + "Ass. Medica"
Else
	cTpForn := (cAliasImp)->( &(cAliasMov + "_TPFORN")) + "-" + "Ass. Odontol."
EndIf

// Impressao do Fornecedor
If (cAliasImp)->( &(cAliasMov + "_TPFORN")) == "1"
	If ( nPosTab := fPosTab( "S016", (cAliasImp)->( &(cAliasMov + "_CODFOR")),"=", 4, ,,,,,,, (cAliasQ)->RA_FILIAL ) ) > 0
		cForn := fTabela("S016",nPosTab,5,,(cAliasQ)->RA_FILIAL)
	Else
		cForn := " "
	EndIf
Else
	If ( nPosTab := fPosTab( "S017" , (cAliasImp)->( &(cAliasMov + "_CODFOR")),"=", 4, ,,,,,,, (cAliasQ)->RA_FILIAL ) ) > 0
		cForn := fTabela("S017",nPosTab,5,,(cAliasQ)->RA_FILIAL)
	Else
		cForn := " "
	EndIf
EndIf
cForn := (cAliasImp)->( &(cAliasMov + "_CODFOR")) + "-" + cForn

// Impressao do Tipo do Plano
If nOpcao == 1
	If (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "1"
		cTpPlan := (cAliasImp)->( &(cAliasMov + "_TPFORN")) + "-" + "Faixa Salarial"
	ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "2"
		cTpPlan := (cAliasImp)->( &(cAliasMov + "_TPFORN")) + "-" + "Faixa Etaria"
	ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "3"
		cTpPlan := (cAliasImp)->( &(cAliasMov + "_TPFORN")) + "-" + "Vlr Fixo por vida"
	Else
		cTpPlan := (cAliasImp)->( &(cAliasMov + "_TPFORN")) + "-" + "% Sobre salario"
	EndIf
Else
	cTpPlan := " -" + "% Sobre salario"
EndIf

// Impressao do Plano
If nOpcao == 1
	If (cAliasImp)->( &(cAliasMov + "_TPFORN")) == "1"
		If (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "1"
			cTab := "S008"
			nCol := 13
		ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "2"
			cTab := "S009"
			nCol := 13
		ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "3"
			cTab := "S028"
			nCol := 12
		ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "4"
			cTab := "S029"
			nCol := 15
		EndIf
	ElseIf (cAliasImp)->( &(cAliasMov + "_TPFORN")) == "2"
		If (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "1"
			cTab := "S013"
			nCol := 13
		ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "2"
			cTab := "S014"
			nCol := 13
		ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "3"
			cTab := "S030"
			nCol := 12
		ElseIf (cAliasImp)->( &(cAliasMov + "_TPPLAN")) == "4"
			cTab := "S031"
			nCol := 15
		EndIf
	EndIf
	
	If ( nPosTab := fPosTab( cTab, (cAliasImp)->( &(cAliasMov + "_CODFOR")),"=", nCol, (cAliasImp)->( &(cAliasMov + "_PLANO")),"=", 4, ,,,, (cAliasQ)->RA_FILIAL ) ) > 0
		cPlano := fTabela(cTab,nPosTab,5,,(cAliasQ)->RA_FILIAL)
	Else
		cPlano := " "
	EndIf
	
	cPlano := (cAliasImp)->( &(cAliasMov + "_PLANO")) + "-" + cPlano
Else
	cPlano := "  - "
EndIf

// Impressao do Periodo Inicial/Final
If cTpOrigem == "1" //Titular
	cAtCodUsu := (cAliasQ)->RA_MAT
Else
	cAtCodUsu := (cAliasImp)->( &(cAliasMov + "_CODIGO" ) )
EndIf
If cTpOrigem == "1" //Titular
	DbSelectArea( "RHK" )
	DbSetOrder( RetOrdem( "RHK", "RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR+RHK_CODIGO"))
	DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT + (cAliasImp)->(&(cAliasMov + "_TPFORN")) + (cAliasImp)->(&(cAliasMov + "_CODFOR")) + (cAliasImp)->(&(cAliasMov + "_CODIGO")), .F.)
	cPerIni := RHK->RHK_PERINI
	cPerFim := RHK->RHK_PERFIM
ElseIf cTpOrigem == "2" //Dependente
	DbSelectArea( "SRB" )
	DbSetOrder( RetOrdem( "SRB", "RB_FILIAL+RB_MAT" ) )
	DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT, .F. )
	lHasDep := .F.
	While SRB->( !EOF() ) .and. SRB->RB_FILIAL + SRB->RB_MAT == (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT
		If SRB->RB_COD == cCodUsu
			lHasDep := .T.
			Exit
		EndIf
		SRB->( DbSkip() )
	EndDo
	DbSelectArea( "RHL" )
	DbSetOrder( RetOrdem( "RHL", "RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR+RHL_CODIGO"))
	DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT + (cAliasImp)->(&(cAliasMov + "_TPFORN")) + (cAliasImp)->(&(cAliasMov + "_CODFOR")) + (cAliasImp)->(&(cAliasMov + "_CODIGO")), .F.)
	cPerIni := RHL->RHL_PERINI
	cPerFim := RHL->RHL_PERFIM
Else
	DbSelectArea( "RHM" )
	DbSetOrder( RetOrdem( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO"))
	DbSeek( (cAliasQ)->RA_FILIAL + (cAliasQ)->RA_MAT + (cAliasImp)->(&(cAliasMov + "_TPFORN")) + (cAliasImp)->(&(cAliasMov + "_CODFOR")) + (cAliasImp)->(&(cAliasMov + "_CODIGO")), .F.)
	If !Eof()
		cNome := RHM->RHM_NOME
		cPerIni := RHM->RHM_PERINI
		cPerFim := RHM->RHM_PERFIM
	EndIf
EndIf
cPerIni := SubStr(cPerIni,1,2)+"/"+SubStr(cPerIni,3,6)
cPerFim := SubStr(cPerFim,1,2)+"/"+SubStr(cPerFim,3,6)

//Impressao valores
cVlrFun := Str( (cAliasImp)->( &(cAliasMov + "_VLRFUN")) , 12,2) + Space(3) //Vlr Funcionario
cVlrEmp := Str( (cAliasImp)->( &(cAliasMov + "_VLREMP")) , 12,2) + Space(12) //Vlr Empresa

cQry := " SELECT "+_cAlias+"_VLRFUN FROM "+RetSqlName(_cAlias)+" "+_cAlias
cQry += " WHERE "+_cAlias+"_MAT = '"+(cAliasQ)->RA_MAT+"'"
cQry += " AND "+_cAlias+"_FILIAL = '"+(cAliasQ)->RA_FILIAL+"'"
cQry += " AND "+_cAlias+"_CODFOR = '"+(cAliasImp)->( &(cAliasMov + "_CODFOR"))+"'"
cQry += " AND "+_cAlias+"_COMPPG = '" + cAnoMes + "' "
cQry += " AND  "+_cAlias+".D_E_L_E_T_ = ' '"
TcQuery cQry New Alias "cQry"

If _cAlias == "RHP"
	cVlrCop := cQry->RHP_VLRFUN
Else
	cVlrCop := cQry->RHO_VLRFUN
Endif

cVlrCop := cValToChar(cVlrCop) //Vlr Co-Particip
cQry->(dbCloseArea())

//-- Acumula Centro de custo / filial / empresa / Co Participacao
If ( nPos := Ascan(aCC,{|x| x[1] == (cAliasQ)->RA_CC}) ) > 0
	aCC[nPos,2]		+= 1
	aCC[nPos,3]		+= (cAliasImp)->( &(cAliasMov + "_VLRFUN"))
	aCC[nPos,4]		+= (cAliasImp)->( &(cAliasMov + "_VLREMP"))
	aCC[nPos,5]		+= cVlrCop  
Else
	Aadd(aCC,{(cAliasQ)->RA_CC, 1, (cAliasImp)->( &(cAliasMov + "_VLRFUN")), (cAliasImp)->( &(cAliasMov + "_VLREMP")),cVlrCop})

EndIf

If ( nPos	:= Ascan(aFil,{|x| x[1] == (cAliasQ)->RA_FILIAL}) ) > 0
	aFil[nPos,2]	+= 1
	aFil[nPos,3]	+= (cAliasImp)->( &(cAliasMov + "_VLRFUN"))
	aFil[nPos,4]	+= (cAliasImp)->( &(cAliasMov + "_VLREMP"))
	aFil[nPos,5]	+= cVlrCop    
Else
	Aadd(aFil,{(cAliasQ)->RA_FILIAL, 1, (cAliasImp)->( &(cAliasMov + "_VLRFUN")), (cAliasImp)->( &(cAliasMov + "_VLREMP")),cVlrCop}) 
EndIf

If ( nPos	:= Ascan(aEmp,{|X| X[1] == cEmpAnt}) ) > 0
	aEmp[nPos,2]	+= 1
	aEmp[nPos,3]	+= (cAliasImp)->( &(cAliasMov + "_VLRFUN"))
	aEmp[nPos,4]	+= (cAliasImp)->( &(cAliasMov + "_VLREMP"))
	aEmp[nPos,5]	+= cVlrCop                
Else
	Aadd(aEmp,{cEmpAnt, 1, (cAliasImp)->( &(cAliasMov + "_VLRFUN")), (cAliasImp)->( &(cAliasMov + "_VLREMP")),cVlrCop})
EndIf 

Return

/*
===============================================================================================================================
Programa----------: RGPE011
Autor-------------: Lucas Crevilari
Data da Criacao---: 07/07/2014
===============================================================================================================================
Descri��o---------: Impressao do totalizador
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fTestaTotal(nOpcao)

Default nOpcao := 1

If nOpcao == 1
	dbSelectArea( cAliasQ )
Else
	dbSelectArea( cAliasRHP )
EndIf

cFilialAnt := (cAliasQ)->RA_FILIAL              // Iguala Variaveis
cCcAnt     := (cAliasQ)->RA_CC
dbSkip()

Return