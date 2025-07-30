/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa--------: RGLT069
Autor-----------: Lucas Borges Ferreira
Data da Criacao-: 03/11/2021
===============================================================================================================================
Descri��o-------: Relat�rio S�ntese das antecipa��es e empr�stimos. Chamado 38597
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function RGLT069

Local oReport
Pergunte("RGLT069",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 03/11/2021
===============================================================================================================================
Descri��o---------: Processa a montagem do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef()

Local oReport
Local oSection
Local oSecTotal
Local _aOrdem   := {"Por Filial+Setor"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT069","S�ntese das antecipa��es e empr�stimos","RGLT069",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Relat�rio S�ntese das antecipa��es e empr�stimos")
oSection := TRSection():New(oReport,"Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)
oReport:SetLandscape()//Paisagem
oSection:SetTotalInLine(.T.)//Imprime totalizador em linhas
oReport:nFontBody	:= 7 //Define o tamanho da fonte. N�o � poss�vel alterar apos a cria��o das sess�es
oReport:nLineHeight	:= 40 // Define a altura da linha.
//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"COL1",/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_FILIAL","ZL2","Fil"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_COD","ZL2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_DESCRI","ZL2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"P_Q_EMP",/*Table*/,"Qtd.Emprestimos"+CRLF+"Produtores"/*cTitle*/,"@E 9,999"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"P_T_EMP",/*Table*/,"Valor Emprestimos"+CRLF+"Produtores"/*cTitle*/,GetSx3Cache("ZLM_TOTAL","X3_PICTURE")/*Picture*/,GetSx3Cache("ZLM_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"P_Q_ANT",/*Table*/,"Qtd.Anetecipa��o"+CRLF+"Produtores"/*cTitle*/,"@E 9,999"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"P_T_ANT",/*Table*/,"Valor Anetecipa��o"+CRLF+"Produtores"/*cTitle*/,GetSx3Cache("ZLM_TOTAL","X3_PICTURE")/*Picture*/,GetSx3Cache("ZLM_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"T_Q_EMP",/*Table*/,"Qtd.Emprestimos"+CRLF+"Transportadores"/*cTitle*/,"@E 9,999"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"T_T_EMP",/*Table*/,"Valor Emprestimos"+CRLF+"Transportadores"/*cTitle*/,GetSx3Cache("ZLM_TOTAL","X3_PICTURE")/*Picture*/,GetSx3Cache("ZLM_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"T_Q_ANT",/*Table*/,"Qtd.Anetecipa��o"+CRLF+"Transportadores"/*cTitle*/,"@E 9,999"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"T_T_ANT",/*Table*/,"Valor Anetecipa��o"+CRLF+"Transportadores"/*cTitle*/,GetSx3Cache("ZLM_TOTAL","X3_PICTURE")/*Picture*/,GetSx3Cache("ZLM_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

oSecTotal := TRSection():New(oReport,"Totalizadores"	,/*uTable {}*/, /*aOrder*/, .F./*lLoadCells*/, .F./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)
TRCell():New(oSecTotal,"COL1",/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSecTotal,"ZLM_DTCRED",/*Table*/,"Cr�dito"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSecTotal,"QTD_EMP",/*Table*/,"Qtd.Emprestimos"/*cTitle*/,"@E 9,999"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSecTotal,"TOTAL_EMP",/*Table*/,"Valor Emprestimos"/*cTitle*/,GetSx3Cache("ZLM_TOTAL","X3_PICTURE")/*Picture*/,GetSx3Cache("ZLM_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSecTotal,"QTD_ANT",/*Table*/,"Qtd.Anetecipa��o"/*cTitle*/,"@E 9,999"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSecTotal,"TOTAL_ANT",/*Table*/,"Valor Anetecipa��o"/*cTitle*/,GetSx3Cache("ZLM_TOTAL","X3_PICTURE")/*Picture*/,GetSx3Cache("ZLM_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 03/11/2021
===============================================================================================================================
Descri��o---------: Processa a impress�o do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro	:= "%"
Local _cAlias	:= ""
Local _aSelFil	:= {}
Local _nOrdem	:= oReport:Section(1):GetOrder() //1-"Por Filial+Produtor",2-"Por Filial+Setor"
//Local _lPlanilha:= oReport:nDevice == 4
Local _nCountRec:= 0

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR01 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZLM")
	Endif
Else
	Aadd(_aSelFil,cFilAnt)
Endif

//=====================================================
// Adiciona a ordem escolhida ao titulo do relatorio
//=====================================================
oReport:SetTitle(oReport:Title() + " ("+AllTrim(_aOrdem[_nOrdem])+") ")

//==========================================================================
// Transforma parametros Range em expressao SQL                             	
//==========================================================================
MakeSqlExpr(oReport:uParam)

//================================================================================
// Configura��o das quebras do relat�rio
//================================================================================
oQbrFil		:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("COL1")/*uBreak*/, /*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.F./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell("P_Q_EMP")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("P_T_EMP")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("P_Q_ANT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("P_T_ANT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("T_Q_EMP")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("T_T_EMP")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("T_Q_ANT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("T_T_ANT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

oQbrTot		:= TRBreak():New( oReport:Section(2)/*oParent*/, oReport:Section(2):Cell("COL1")/*uBreak*/, /*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
TRFunction():New(oReport:Section(2):Cell("QTD_EMP")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrTot/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(2):Cell("TOTAL_EMP")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrTot/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(2):Cell("QTD_ANT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrTot/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(2):Cell("TOTAL_ANT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrTot/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
oReport:Section(1):Cell("COL1"):Disable()
oReport:Section(2):Cell("COL1"):Disable()

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
_cFiltro += " AND ZLM_FILIAL "+ GetRngFil( _aSelFil, "ZLM", .T.,)
//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR02) .Or. Empty(MV_PAR02) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro+=" AND ZLM_SETOR IN " + FormatIn(AllTrim(MV_PAR02),';')
EndIf
_cFiltro+=" AND ZLM_DATA BETWEEN '"+DToS(MV_PAR03)+"' AND '"+DToS(MV_PAR04)+"'"
_cFiltro+=" AND ZLM_VENCTO BETWEEN '"+DToS(MV_PAR05)+"' AND '"+DToS(MV_PAR06)+"'"
_cFiltro+=" AND ZLM_SA2COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'"
_cFiltro+=" AND ZLM_SA2LJ BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'"
_cFiltro+=" AND ZLM_STATUS NOT IN ('3','6')"
_cFiltro += " %"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
	SELECT BASE.ZLM_FILIAL, BASE.ZLM_SETOR, ZL2_DESCRI, NVL(PEMP.QTD_EMP,0) P_Q_EMP, NVL(PEMP.TOTAL_EMP,0) P_T_EMP , NVL(PANT.QTD_ANT,0) P_Q_ANT, NVL(PANT.TOTAL_ANT,0) P_T_ANT,
		NVL(TEMP.QTD_EMP,0) T_Q_EMP, NVL(TEMP.TOTAL_EMP,0) T_T_EMP , NVL(TANT.QTD_ANT,0) T_Q_ANT, NVL(TANT.TOTAL_ANT,0) T_T_ANT
	FROM (SELECT ZLM_FILIAL, ZLM_SETOR
			FROM %Table:ZLM% ZLM
			WHERE ZLM.D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLM_TIPO IN ('E', 'N')
			GROUP BY ZLM_FILIAL, ZLM_SETOR) BASE,
		(SELECT ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO, COUNT(1) QTD_EMP, SUM(ZLM_TOTAL) TOTAL_EMP
			FROM %Table:ZLM% ZLM
			WHERE ZLM.D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLM_TIPO = 'E'
			AND SUBSTR(ZLM_SA2COD,1,1) = 'P'
			GROUP BY ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO) PEMP,
		(SELECT ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO, COUNT(1) QTD_ANT, SUM(ZLM_TOTAL) TOTAL_ANT
			FROM %Table:ZLM% ZLM
			WHERE ZLM.D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLM_TIPO = 'N'
			AND SUBSTR(ZLM_SA2COD,1,1) = 'P'
			GROUP BY ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO) PANT,
		(SELECT ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO, COUNT(1) QTD_EMP, SUM(ZLM_TOTAL) TOTAL_EMP
			FROM %Table:ZLM% ZLM
			WHERE ZLM.D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLM_TIPO = 'E'
			AND SUBSTR(ZLM_SA2COD,1,1) <> 'P'
			GROUP BY ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO) TEMP,
		(SELECT ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO, COUNT(1) QTD_ANT, SUM(ZLM_TOTAL) TOTAL_ANT
			FROM %Table:ZLM% ZLM
			WHERE ZLM.D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLM_TIPO = 'N'
			AND SUBSTR(ZLM_SA2COD,1,1) <> 'P'
			GROUP BY ZLM_FILIAL, ZLM_SETOR, ZLM_TIPO) TANT, ZL2010 ZL2
	WHERE ZL2.D_E_L_E_T_ = ' '
	AND ZL2_FILIAL = BASE.ZLM_FILIAL
	AND ZL2_COD = BASE.ZLM_SETOR
	AND PEMP.ZLM_FILIAL (+) = BASE.ZLM_FILIAL
	AND PEMP.ZLM_SETOR (+) = BASE.ZLM_SETOR
	AND PANT.ZLM_FILIAL (+) = BASE.ZLM_FILIAL
	AND PANT.ZLM_SETOR (+) = BASE.ZLM_SETOR
	AND TEMP.ZLM_FILIAL (+) = BASE.ZLM_FILIAL
	AND TEMP.ZLM_SETOR (+) = BASE.ZLM_SETOR
	AND TANT.ZLM_FILIAL (+) = BASE.ZLM_FILIAL
	AND TANT.ZLM_SETOR (+) = BASE.ZLM_SETOR
	ORDER BY BASE.ZLM_FILIAL, BASE.ZLM_SETOR
EndSql
//==========================================================================
// Metodo EndQuery ( Classe TRSection )                                     
//                                                                          
// Prepara o relat�rio para executar o Embedded SQL.                        
//                                                                          
// ExpA1 : Array com os parametros do tipo Range                            
//                                                                          
//==========================================================================
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//=======================================================================
//Impressao do Relatorio
//=======================================================================
oReport:Section(1):Init()
Count To _nCountRec
(_cAlias)->( DbGotop() )
oReport:SetMsgPrint("Imprimindo")
oReport:SetMeter(_nCountRec)

While !oReport:Cancel() .And. (_cAlias)->(!EOF())
	oReport:Section(1):PrintLine()
	oReport:IncMeter()
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(dbCloseArea())

//==========================================================================
// Query do relat�rio da secao 2
//==========================================================================
oReport:Section(2):BeginQuery()	
_cAlias := GetNextAlias()

BeginSql alias _cAlias
	SELECT CASE WHEN EMP.ZLM_DTCRED IS NULL THEN ANT.ZLM_DTCRED ELSE EMP.ZLM_DTCRED END ZLM_DTCRED,
		QTD_EMP, TOTAL_EMP, QTD_ANT, TOTAL_ANT
	FROM (SELECT ZLM_TIPO, ZLM_DTCRED, COUNT(1) QTD_EMP, SUM(ZLM_TOTAL) TOTAL_EMP
			FROM %Table:ZLM% ZLM
			WHERE ZLM.D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLM_TIPO = 'E'
			GROUP BY ZLM_TIPO, ZLM_DTCRED) EMP
	FULL OUTER JOIN (SELECT ZLM_TIPO, ZLM_DTCRED, COUNT(1) QTD_ANT, SUM(ZLM_TOTAL) TOTAL_ANT
						FROM %Table:ZLM% ZLM
						WHERE ZLM.D_E_L_E_T_ = ' '
						%exp:_cFiltro%
						AND ZLM_TIPO = 'N'
						GROUP BY ZLM_TIPO, ZLM_DTCRED) ANT
		ON EMP.ZLM_DTCRED = ANT.ZLM_DTCRED
	ORDER BY 1
EndSql
//==========================================================================
// Metodo EndQuery ( Classe TRSection )                                     
//                                                                          
// Prepara o relat�rio para executar o Embedded SQL.                        
//                                                                          
// ExpA1 : Array com os parametros do tipo Range                            
//                                                                          
//==========================================================================
oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)

//=======================================================================
//Impressao do Relatorio
//=======================================================================
oReport:Section(2):Init()
oReport:SetMsgPrint("Imprimindo")

While !oReport:Cancel() .And. (_cAlias)->(!EOF())
	oReport:Section(2):PrintLine()
	oReport:IncMeter()
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(2):Finish()
(_cAlias)->(DBCloseArea())

Return
