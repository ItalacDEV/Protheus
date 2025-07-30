/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 22/12/2015 | Tratativa na cl�usula "ORDER BY" para remover a refer�ncia num�rica. Chamado 13062
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira | 17/06/2019 | Revis�o de fontes. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira | 12/12/2021 | Migra��o para tReport. Chamado 38597
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT009
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 18/02/2015
===============================================================================================================================
Descri��o---------: Relat�rio de An�lise da entrega de leite de Produtores x Pagamento a ser realizado no per�odo - Inativo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT009

Local oReport
Pergunte("RGLT009",.F.)
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
Descri��o---------: Defini��o do Componente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef()

Local oReport
Local oSection
Local _aOrdem   := {"Por Filial+Fornecedor"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT009","Relat�rio Pagamento de Produtores x Entregas - Inativos","RGLT009",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Relat�rio Pagamento de Produtores x Entregas - Inativos")
oSection := TRSection():New(oReport,"Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/,.T./*lTotalInLine*/)
oReport:SetLandscape()//Paisagem
oSection:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"E2_FILIAL","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_FORNECE","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_LOJA","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_NOME","SA2",/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"Z08_TERMO","Z08",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_PREFIXO","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_NUM","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_TIPO","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_PARCELA","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_VENCREA","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"E2_VALOR","SE2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 03/11/2021
===============================================================================================================================
Descri��o---------: Processa impress�o do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro		:= '%'
Local _cAlias		:= ""
Local _aSelFil		:= {}
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-"Por Filial+Fornecedor"
Local _cFilial		:= ""
//Local _lPlanilha 	:= oReport:nDevice == 4
Local _nCountRec	:= 0

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR01 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"SE2")
	Endif
Else
	Aadd(_aSelFil,cFilAnt)
EndIf

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
oQbrFil		:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("E2_FILIAL") /*uBreak*/, {||"Total da Filial: " + _cFilial + ' - '+ FWFilialName(cEmpAnt,_cFilial,1 )}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell("E2_FORNECE")/*oCell*/,/*cName*/,"COUNT"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("E2_VALOR")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
If MV_PAR07 == 1
	_cFiltro += " AND SE2.E2_BAIXA BETWEEN '"+ DtoS(FirstDate(MV_PAR06))+"' AND '"+ DtoS(LastDate(MV_PAR06)) +"' "
Else
	_cFiltro += " AND SE2.E2_BAIXA   = ' ' "
	_cFiltro += " AND SE2.E2_SALDO + SE2.E2_SDACRES - SE2.E2_SDDECRE > 0 "
	_cFiltro += " AND SE2.E2_VENCREA BETWEEN '"+ DtoS(FirstDate(MV_PAR06))+"' AND '"+ DtoS(LastDate(MV_PAR06)) +"' "
EndIf

_cFiltro += " AND Z08.Z08_FILIAL "+ GetRngFil( _aSelFil, "Z08", .T.,) + " %"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
		SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, A2_NOME, Z08_TERMO,
	        E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_VENCREA, E2_VALOR
	   FROM %Table:Z08% Z08, %Table:SE2% SE2, %Table:SA2% SA2
	  WHERE Z08.D_E_L_E_T_ = ' '
	    AND SE2.D_E_L_E_T_ = ' '
	    AND SA2.D_E_L_E_T_ = ' '
	    AND SA2.A2_FILIAL = ' '
	    AND SA2.A2_COD BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR04%
	    AND SA2.A2_LOJA BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR05%
	    AND SA2.A2_COD = SE2.E2_FORNECE
	    AND SA2.A2_LOJA = SE2.E2_LOJA
	    AND Z08.Z08_FILIAL = SE2.E2_FILIAL
	    AND Z08.Z08_PREFIX = SE2.E2_PREFIXO
	    AND Z08.Z08_NUM = SE2.E2_NUM
	    AND Z08.Z08_TIPO = SE2.E2_TIPO
	    AND Z08.Z08_CODFOR = SE2.E2_FORNECE
	    AND Z08.Z08_LOJFOR = SE2.E2_LOJA
	    %exp:_cFiltro%
	    AND NOT EXISTS (SELECT 1 FROM %Table:ZLD% ZLD
	          WHERE ZLD.D_E_L_E_T_ = ' '
	            AND ZLD.ZLD_FILIAL = Z08.Z08_FILIAL
	            AND ZLD.ZLD_DTCOLE BETWEEN %exp:FirstDate(MonthSub(MV_PAR06,1))% AND %exp:LastDate(MonthSub(MV_PAR06,1))%
	            AND E2_FORNECE = CASE WHEN E2_FORNECE LIKE 'P%' THEN ZLD_RETIRO ELSE ZLD_FRETIS END
	            AND E2_LOJA = CASE WHEN E2_FORNECE LIKE 'P%' THEN ZLD_RETILJ ELSE ZLD_RETILJ END)
	  GROUP BY E2_FILIAL, E2_FORNECE, E2_LOJA, A2_NOME, Z08_TERMO, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_VENCREA, E2_VALOR
	  ORDER BY E2_FILIAL, E2_FORNECE, E2_LOJA, Z08_TERMO, E2_PARCELA
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
	_cFilial := (_cAlias)->E2_FILIAL
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(DBCloseArea())

Return
