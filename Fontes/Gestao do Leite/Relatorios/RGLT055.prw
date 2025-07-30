/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/05/2019 | Revis�o de fontes. Help 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 27/09/2019 | Revis�o de fontes. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 12/12/2021 | Migra��o do relat�rio para tReport. Chamado 38597
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT055
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 03/11/2021
===============================================================================================================================
Descri��o---------: Relatorio utilizado para realizar a impressao dos eventos efetuando um comparativo entre um mix anterior
					e um mix comparativo informados pelos usuarios.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT055

Local oReport
Pergunte("RGLT055",.F.)
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
Local _aOrdem   := {"Por Filial+Fornecedor","Por Filial+Setor+Fornecedor","Por Filial+Linha+Fornecedor"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT055","Relat�rio Comparativo de Eventos do Mix","RGLT055",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Relat�rio Comparativo de Eventos do Mix")
oSection := TRSection():New(oReport,"Dados"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/,.T./*lTotalInLine*/)
oReport:SetLandscape()//Paisagem
oSection:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"ZLF_FILIAL","ZLF","Fil"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_COD","ZL2","Setor"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_DESCRI","ZL2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL3_COD","ZL3","Linha"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL3_DESCRI","ZL3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_COD","SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_LOJA","SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_NOME","SA2",/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL8_COD","ZL8","Evento"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL8_DESCRI","ZL8",/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"LTR_OLD",/*cAlias*/,"Valor"+CRLF+"Unit Old"/*cTitle*/,GetSX3Cache("ZLF_VLRLTR","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLF_VLRLTR","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"LTR_NEW",/*cAlias*/,"Valor"+CRLF+"Unit New"/*cTitle*/,GetSX3Cache("ZLF_VLRLTR","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLF_VLRLTR","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"LTR_DIF",/*cAlias*/,"Valor"+CRLF+"Unit Dif"/*cTitle*/,GetSX3Cache("ZLF_VLRLTR","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLF_VLRLTR","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"TOTAL_OLD",/*cAlias*/,"Valor"+CRLF+"Total Old"/*cTitle*/,GetSX3Cache("ZLF_TOTAL","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLF_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"TOTAL_NEW",/*cAlias*/,"Valor"+CRLF+"Total New"/*cTitle*/,GetSX3Cache("ZLF_TOTAL","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLF_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"TOTAL_DIF",/*cAlias*/,"Valor"+CRLF+"Total Dif"/*cTitle*/,GetSX3Cache("ZLF_TOTAL","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLF_TOTAL","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"VOL_OLD",/*cAlias*/,"Volume"+CRLF+"Old"/*cTitle*/,GetSX3Cache("ZLD_QTDBOM","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLD_QTDBOM","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"VOL_NEW",/*cAlias*/,"Volume"+CRLF+"New"/*cTitle*/,GetSX3Cache("ZLD_QTDBOM","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLD_QTDBOM","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"VOL_DIF",/*cAlias*/,"Volume"+CRLF+"Dif"/*cTitle*/,GetSX3Cache("ZLD_QTDBOM","X3_PICTURE")/*Picture*/,GetSX3Cache("ZLD_QTDBOM","X3_TAMANHO")/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

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

Local _cFiltro		:= "%"
Local _cHaving		:= "%"
Local _cOrder		:= "%"
Local _cAlias		:= ""
Local _aSelFil		:= {}
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-"Por Filial+Fornecedor",2-"Por Filial+Setor+Fornecedor",3-"Por Filial+Linha+Fornecedor"
Local _cFilial		:= ""
Local _lPlanilha 	:= oReport:nDevice == 4
Local _nCountRec	:= 0
Local _cSetor		:= ""
Local _cLinha		:= ""

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR08 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZLF")
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
If _nOrdem <> 1  //Quebra por Setor ou Linha
	If _nOrdem == 2
		oQbrSet	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZL2_COD") /*uBreak*/, {||"Setor: " + _cSetor}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
	ElseIf _nOrdem == 3
		oQbrSet	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZL3_COD") /*uBreak*/, {||"Linha: " + _cLinha}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
	EndIf
	TRFunction():New(oReport:Section(1):Cell("LTR_DIF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSet/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	TRFunction():New(oReport:Section(1):Cell("TOTAL_OLD")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSet/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	TRFunction():New(oReport:Section(1):Cell("TOTAL_NEW")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSet/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	TRFunction():New(oReport:Section(1):Cell("TOTAL_DIF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSet/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	TRFunction():New(oReport:Section(1):Cell("VOL_OLD")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSet/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	TRFunction():New(oReport:Section(1):Cell("VOL_NEW")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSet/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	TRFunction():New(oReport:Section(1):Cell("VOL_DIF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSet/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
EndIf

oQbrFil		:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZLF_FILIAL") /*uBreak*/, {||"Total da Filial: " + _cFilial + ' - '+ FWFilialName(cEmpAnt,_cFilial,1 )}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell("LTR_DIF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("TOTAL_OLD")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("TOTAL_NEW")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("TOTAL_DIF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("VOL_OLD")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("VOL_NEW")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("VOL_DIF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFil/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
oReport:Section(1):Cell("LTR_OLD"):SetTitle("Valor Unit"+CRLF+MV_PAR01)
oReport:Section(1):Cell("LTR_NEW"):SetTitle("Valor Unit"+CRLF+MV_PAR02)
oReport:Section(1):Cell("TOTAL_OLD"):SetTitle("Valor Total"+CRLF+MV_PAR01)
oReport:Section(1):Cell("TOTAL_NEW"):SetTitle("Valor Total"+CRLF+MV_PAR02)
oReport:Section(1):Cell("VOL_OLD"):SetTitle("Volume"+CRLF+MV_PAR01)
oReport:Section(1):Cell("VOL_NEW"):SetTitle("Volume"+CRLF+MV_PAR02)

If !_lPlanilha
	oReport:Section(1):Cell("ZL3_DESCRI"):Disable()
	oReport:Section(1):Cell("TOTAL_OLD"):Disable()
	oReport:Section(1):Cell("TOTAL_DIF"):Disable()
	oReport:Section(1):Cell("TOTAL_NEW"):Disable()
EndIf

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
_cFiltro += " AND ZLF_FILIAL "+ GetRngFil( _aSelFil, "ZLF", .T.,)

//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR03) .Or. Empty(MV_PAR03) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND ZLF_SETOR IN "+ FormatIn( AllTrim(MV_PAR03) , ';' )
EndIf

//Verifica se foi fornecido o filtro de linha
If !Empty(MV_PAR11)
	_cFiltro += " AND ZLF_LINROT IN " + FormatIn(MV_PAR11,";")
EndIf

//Verifica se foi fornecido o filtro de evento
If !Empty(MV_PAR09)
	_cFiltro += " AND ZLF_EVENTO IN " + FormatIn(MV_PAR09,";")
EndIf

//Verifica se foi fornecido o filtro de evento
If MV_PAR10 == 2 
	_cHaving += " HAVING NVL(M2.VALOR_LTR,0)- NVL(M1.VALOR_LTR,0) <> 0"
ElseIf MV_PAR10 == 3
	_cHaving += " HAVING NVL(M2.VALOR_LTR,0)- NVL(M1.VALOR_LTR,0) > 0"
ElseIf MV_PAR10 == 4
	_cHaving += " HAVING NVL(M2.VALOR_LTR,0)- NVL(M1.VALOR_LTR,0) < 0"
EndIf

If _nOrdem == 2
	_cOrder	+= " ZL2_COD, ZL3_COD, "
ElseIf _nOrdem == 3
	_cOrder	+= " ZL3_COD, "
EndIf

_cFiltro += "%"
_cHaving += "%"
_cOrder += "%"
//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
	SELECT PRD.ZLF_FILIAL, ZL2_COD, ZL2_DESCRI, ZL3_COD, ZL3_DESCRI, A2_COD, A2_LOJA, A2_NOME, PRD.ZLF_EVENTO, ZL8_DESCRI,
		NVL(M1.VALOR_LTR, 0) LTR_OLD, NVL(M2.VALOR_LTR, 0) LTR_NEW, NVL(M2.VALOR_LTR, 0) - NVL(M1.VALOR_LTR, 0) LTR_DIF,
		NVL(M1.VALOR_TOTAL, 0) TOTAL_OLD, NVL(M2.VALOR_TOTAL, 0) VALOR_TOTAL_000118, NVL(M2.VALOR_TOTAL, 0) - NVL(M1.VALOR_TOTAL, 0) DIF_VLR_TOT,
		NVL(M1.VOLUME, 0) VOL_OLD, NVL(M2.VOLUME, 0) VOL_NEW, NVL(M2.VOLUME, 0) - NVL(M1.VOLUME, 0) VOL_DIF
	FROM (SELECT ZLF_FILIAL, ZLF_A2COD, ZLF_A2LOJA, ZLF_SETOR, ZLF_LINROT, ZLF_EVENTO
			FROM %Table:ZLF%
			WHERE D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLF_CODZLE IN (%exp:MV_PAR01%,%exp:MV_PAR02%)
			AND ZLF_A2COD BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR06%
			AND ZLF_A2LOJA BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
			GROUP BY ZLF_FILIAL, ZLF_A2COD, ZLF_A2LOJA, ZLF_SETOR, ZLF_LINROT, ZLF_EVENTO) PRD,
		(SELECT ZLF_FILIAL, ZLF_CODZLE, ZLF_A2COD, ZLF_A2LOJA, ZLF_SETOR, ZLF_LINROT, ZLF_EVENTO, SUM(ZLF_VLRLTR) VALOR_LTR, SUM(ZLF_TOTAL) VALOR_TOTAL,
				NVL((SELECT SUM(ZLD_QTDBOM)
						FROM %Table:ZLD% ZLD
						WHERE ZLD.D_E_L_E_T_ = ' '
						AND ZLD.ZLD_FILIAL = ZLF_FILIAL
						AND ZLD.ZLD_DTCOLE BETWEEN ZLF_DTINI AND ZLF_DTFIM
						AND ZLD.ZLD_STATUS = 'F'
						AND ZLD.ZLD_RETIRO = ZLF_A2COD
						AND ZLD.ZLD_RETILJ = ZLF_A2LOJA
						AND ZLD.ZLD_SETOR = ZLF_SETOR
						AND ZLD.ZLD_LINROT = ZLF_LINROT), 0) VOLUME
			FROM %Table:ZLF%
			WHERE D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLF_CODZLE = %exp:MV_PAR01%
			AND ZLF_A2COD BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR06%
			AND ZLF_A2LOJA BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
			GROUP BY ZLF_FILIAL, ZLF_CODZLE, ZLF_DTINI, ZLF_DTFIM, ZLF_A2COD, ZLF_A2LOJA, ZLF_SETOR, ZLF_LINROT, ZLF_EVENTO) M1,
		(SELECT ZLF_FILIAL, ZLF_CODZLE, ZLF_A2COD, ZLF_A2LOJA, ZLF_SETOR, ZLF_LINROT, ZLF_EVENTO, SUM(ZLF_VLRLTR) VALOR_LTR, SUM(ZLF_TOTAL) VALOR_TOTAL,
				NVL((SELECT SUM(ZLD_QTDBOM)
						FROM %Table:ZLD% ZLD
						WHERE ZLD.D_E_L_E_T_ = ' '
						AND ZLD.ZLD_FILIAL = ZLF_FILIAL
						AND ZLD.ZLD_DTCOLE BETWEEN ZLF_DTINI AND ZLF_DTFIM
						AND ZLD.ZLD_STATUS = 'F'
						AND ZLD.ZLD_RETIRO = ZLF_A2COD
						AND ZLD.ZLD_RETILJ = ZLF_A2LOJA
						AND ZLD.ZLD_SETOR = ZLF_SETOR
						AND ZLD.ZLD_LINROT = ZLF_LINROT), 0) VOLUME
			FROM %Table:ZLF%
			WHERE D_E_L_E_T_ = ' '
			%exp:_cFiltro%
			AND ZLF_CODZLE = %exp:MV_PAR02%
			AND ZLF_A2COD BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR06%
			AND ZLF_A2LOJA BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
			GROUP BY ZLF_FILIAL, ZLF_CODZLE,  ZLF_DTINI, ZLF_DTFIM, ZLF_A2COD, ZLF_A2LOJA, ZLF_SETOR, ZLF_LINROT, ZLF_EVENTO) M2,
		%Table:ZL8% ZL8, %Table:ZL2% ZL2, %Table:ZL3% ZL3, %Table:SA2% SA2
	WHERE ZL8.D_E_L_E_T_ = ' '
	AND ZL2.D_E_L_E_T_ = ' '
	AND ZL3.D_E_L_E_T_ = ' '
	AND SA2.D_E_L_E_T_ = ' '
	AND PRD.ZLF_FILIAL = ZL8_FILIAL
	AND PRD.ZLF_EVENTO = ZL8_COD
	AND PRD.ZLF_FILIAL = ZL2_FILIAL
	AND PRD.ZLF_SETOR = ZL2_COD
	AND PRD.ZLF_FILIAL = ZL3_FILIAL
	AND PRD.ZLF_LINROT = ZL3_COD
	AND PRD.ZLF_A2COD = A2_COD
	AND PRD.ZLF_A2LOJA = A2_LOJA
	AND M1.ZLF_FILIAL(+) = PRD.ZLF_FILIAL
	AND M1.ZLF_A2COD(+) = PRD.ZLF_A2COD
	AND M1.ZLF_A2LOJA(+) = PRD.ZLF_A2LOJA
	AND M1.ZLF_SETOR(+) = PRD.ZLF_SETOR
	AND M1.ZLF_LINROT(+) = PRD.ZLF_LINROT
	AND M1.ZLF_EVENTO(+) = PRD.ZLF_EVENTO
	AND M2.ZLF_FILIAL(+) = PRD.ZLF_FILIAL
	AND M2.ZLF_A2COD(+) = PRD.ZLF_A2COD
	AND M2.ZLF_A2LOJA(+) = PRD.ZLF_A2LOJA
	AND M2.ZLF_SETOR(+) = PRD.ZLF_SETOR
	AND M2.ZLF_LINROT(+) = PRD.ZLF_LINROT
	AND M2.ZLF_EVENTO(+) = PRD.ZLF_EVENTO
	GROUP BY PRD.ZLF_FILIAL, ZL2_COD, ZL2_DESCRI, ZL3_COD, ZL3_DESCRI, A2_COD, A2_LOJA, A2_NOME, PRD.ZLF_EVENTO, ZL8_DESCRI, 
			M1.VALOR_LTR, M2.VALOR_LTR, M1.VALOR_TOTAL, M2.VALOR_TOTAL, M1.VOLUME, M2.VOLUME
	%exp:_cHaving%
	ORDER BY PRD.ZLF_FILIAL, %exp:_cOrder% A2_COD, A2_LOJA, PRD.ZLF_EVENTO
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
	_cFilial := (_cAlias)->ZLF_FILIAL
	_cSetor	:= (_cAlias)->ZL2_COD+" - "+(_cAlias)->ZL2_DESCRI
	_cLinha	:= (_cAlias)->ZL3_COD+" - "+(_cAlias)->ZL3_DESCRI
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(DBCloseArea())

Return
