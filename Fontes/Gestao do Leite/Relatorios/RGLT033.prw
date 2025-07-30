/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 30/03/2025 | Chamado 50280. Modificado c�lculo para Extrato Seco Total (EST)
Lucas Borges  | 10/04/2025 | Chamado 50420. Inclu�da a coluna de estado
Lucas Borges  | 25/04/2025 | Chamado 50532. Inclu�do filtro de CFOP
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT033
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 29/07/2022
Descri��o---------: S�ntese de Recep��es - Leite de Terceiros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT033()

Local oReport
Pergunte("RGLT033",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 29/07/2022
Descri��o---------: Defini��o do Componente
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local _nEspaco	:= 5
Local _aOrdem   := {"Filial+Produto"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT033","S�ntese de Recep��es","RGLT033",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Apresenta informa��es referente recep��es do Leite de Terceiros")
oSection1 := TRSection():New(oReport,"Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)
oReport:SetLandscape()//Paisagem
oSection1:SetTotalInLine(.F.)
oReport:SetLineHeight(60)
oReport:nFontBody := 9
oReport:cFontBody := 'Tahoma'

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection1,"ZZX_FILIAL","ZZX","Filial"/*cTitle*/,/*Picture*/,GetSX3Cache("ZZX_FILIAL","X3_TAMANHO")+_nEspaco/*Tamanho*/,/*lPixel*/,/*Block*/,"CENTER"/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZZX_CODPRD","ZZX",/*cTitle*/,/*Picture*/,GetSX3Cache("ZZX_CODPRD","X3_TAMANHO")+_nEspaco/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"DESCRI",/*Table*/,"Produto"/*cTitle*/,/*Picture*/,18+_nEspaco/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_TIPOLT",/*Table*/,"Proced�ncia"/*cTitle*/,/*Picture*/,17+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_FORNEC","ZLX"/*Table*/,"Forn."/*cTitle*/,/*Picture*/,6+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_LJFORN","ZLX"/*Table*/,"Loja"/*cTitle*/,/*Picture*/,4+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"A2_EST",/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"A2_NREDUZ",/*Table*/,"Fornecedor"/*cTitle*/,/*Picture*/,35+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_VOLREC","ZLX"/*Table*/,"Qtd."+CRLF+"Recebida (L)"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"VL_A_PAGAR",/*Table*/,"Vlr � Pagar"/*cTitle*/,'@E 999,999,999.99'/*Picture*/,14+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_VOLNF","ZLX"/*Table*/,"Qtd."+CRLF+"Faturada (L)"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_VLRNF","ZLX"/*Tabela*/,"Vlr."+CRLF+"Faturado"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_DIFVOL","ZLX"/*Tabela*/,"Diferen�a"+CRLF+"Balan�a (L)"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZAP_GORD","ZAP"/*Table*/,"% M�n."+CRLF+" MG"/*cTitle*/,/*Picture*/,GetSX3Cache("ZAP_GORD","X3_TAMANHO")+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"QTD_MG_KG",/*Table*/,"Qtd."+CRLF+"MG (KG)"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZAP_EST","ZAP"/*Table*/,"% M�n."+CRLF+"EST"/*cTitle*/,/*Picture*/,GetSX3Cache("ZAP_EST","X3_TAMANHO")+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"QTD_EST_KG",/*Table*/,"Qtd."+CRLF+"EST (KG)"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

oSection2 := TRSection():New(oReport,"S�ntese por Proced�ncia"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)
oSection2:SetTotalInLine(.F.)
oSection2:SetBorder(5,4,,.F.)

TRCell():New(oSection2,"ZZX_FILIAL","ZZX","Filial"/*cTitle*/,/*Picture*/,GetSX3Cache("ZZX_FILIAL","X3_TAMANHO")+_nEspaco/*Tamanho*/,/*lPixel*/,/*Block*/,"CENTER"/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZZX_CODPRD","ZZX",/*cTitle*/,/*Picture*/,/*GetSX3Cache("ZZX_CODPRO","X3_TAMANHO")+_nEspaco*//*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"DESCRI",/*Table*/,"Produto"/*cTitle*/,/*Picture*/,18+_nEspaco/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZLX_TIPOLT",/*Table*/,"Proced�ncia"/*cTitle*/,/*Picture*/,15+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZLX_VOLREC","ZLX"/*Table*/,"Qtd. Recebida"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"VL_A_PAGAR",/*Table*/,"Vlr � Pagar"/*cTitle*/,'@E 999,999,999.99'/*Picture*/,14+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZLX_VOLNF","ZLX"/*Table*/,"Qtd."+CRLF+"Faturada"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZLX_VLRNF","ZLX"/*Tabela*/,"Vlr."+CRLF+"Faturado"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZLX_DIFVOL","ZLX"/*Tabela*/,"Diferen�a"+CRLF+"Balan�a"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZAP_GORD","ZAP"/*Table*/,"% M�n."+CRLF+" MG"/*cTitle*/,/*Picture*/,GetSX3Cache("ZAP_GORD","X3_TAMANHO")+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"QTD_MG_KG",/*Table*/,"Qtd."+CRLF+" MG (KG)"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZAP_EST","ZAP"/*Table*/,"% M�n."+CRLF+"EST"/*cTitle*/,/*Picture*/,GetSX3Cache("ZAP_EST","X3_TAMANHO")+_nEspaco/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"QTD_EST_KG",/*Table*/,"Qtd."+CRLF+"EST (KG)"/*cTitle*/,'@E 999,999,999'/*Picture*/,11+_nEspaco/*Tamanho*/,/*lPixHel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 29/07/2022
Descri��o---------: Processa impress�o do relat�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro	:= "%"
Local _cFilDeb  := "% %"
Local _cFilSD1  := "% %"
Local _cAlias	  := ""
Local _aSelFil	:= {}
Local _nOrdem	  := oReport:Section(1):GetOrder() 
Local _lPlanilha:= oReport:nDevice == 4
Local _cFilial	:= ""
Local _cProduto := ""
Local _cProceden := ""
Local _cCampos  := ""
Local _aQuebras := {'oQbrProc','oQbrProd'}
Local _cOrder   := ""
Local _nX       := 0

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR10 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZZX")
	Endif
Else
	Aadd(_aSelFil,cFilAnt)
Endif

//=====================================================
// Adiciona a ordem escolhida ao titulo do relatorio  |
//=====================================================
oReport:SetTitle(oReport:Title() + " ("+AllTrim(_aOrdem[_nOrdem])+") ")

//==========================================================================
// Transforma parametros Range em expressao SQL                             	
//==========================================================================
MakeSqlExpr(oReport:uParam)

//==========================================================================
// Transforma parametros Range em expressao SQL                             	
//==========================================================================
MakeSqlExpr(oReport:uParam)

//================================================================================
//| Configura��o das quebras do relat�rio                                        |
//================================================================================

oQbrProc:= TRBreak():New( oReport:Section(1)/*oParent*/, {||oReport:Section(1):Cell("ZZX_CODPRD"):uPrint+oReport:Section(1):Cell("ZLX_TIPOLT"):uPrint} /*uBreak*/, {||"Total: " + _cProceden } /*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.F./*lPageBreak*/)
oQbrProd:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZZX_CODPRD") /*uBreak*/, {||"Total: " + _cProduto } /*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.F./*lPageBreak*/)
For _nX := 1 to Len(_aQuebras)
  TRFunction():New(oReport:Section(1):Cell("ZLX_VOLREC")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("VL_A_PAGAR")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("ZLX_VOLNF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("ZLX_VLRNF")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("ZLX_DIFVOL")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("ZAP_GORD")/*oCell*/,/*cName*/,"AVERAGE"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("QTD_MG_KG")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("ZAP_EST")/*oCell*/,/*cName*/,"AVERAGE"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
  TRFunction():New(oReport:Section(1):Cell("QTD_EST_KG")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,&(_aQuebras[_nX])/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
Next _nX
//Coloca totais em negrito
For _nX := 1 To Len(oReport:Section(1):aBreak[1]:aFunction)
      oReport:Section(1):aBreak[1]:aFunction[_nX]:lBold := .T.//Quebra 1
      oReport:Section(1):aBreak[2]:aFunction[_nX]:lBold := .T.//Quebra 2
Next _nX

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
If !_lPlanilha
	oReport:Section(1):Cell("ZZX_CODPRD"):Disable()
  oReport:Section(2):Cell("ZZX_CODPRD"):Disable()
  oReport:Section(1):Cell("ZLX_TIPOLT"):Disable()
  oReport:Section(1):Cell("A2_EST"):Disable()
EndIf

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
_cFiltro += " AND ZZX.ZZX_FILIAL "+ GetRngFil( _aSelFil, "ZZX", .T.,)
If !Empty(MV_PAR04)
	_cFiltro += " AND ZZX.ZZX_CODPRD IN "+ FormatIn( MV_PAR04 , ';' )
EndIf

If MV_PAR03 == 1 
	_cFiltro += " AND ZLX.ZLX_TIPOLT = 'F' "
ElseIf MV_PAR03 == 2 
	_cFiltro += " AND ZLX.ZLX_TIPOLT = 'T' "
ElseIf MV_PAR03 == 3 
 _cFiltro += " AND ZLX.ZLX_TIPOLT = 'P' "
EndIf
_cFiltro += " %"

If MV_PAR09==1
  _cFilDeb := "% (SE2.E2_ORIGEM IN ('AGLT011', 'AGLT016') AND SE2.E2_TIPO = 'NDF') OR %"
EndIf

If !Empty(MV_PAR13)
  _cFilSD1 := "% AND D1_CF NOT IN "+FormatIn(AllTrim(MV_PAR13),"/")+" %"
EndIf

_cCampos := "%, ZLX.ZLX_FORNEC, ZLX.ZLX_LJFORN, SA2.A2_NREDUZ, SA2.A2_EST %"
_cOrder :=  "% ZZX.ZZX_CODPRD, ORD_PRC, ZZX.ZZX_FILIAL, ZLX.ZLX_FORNEC, ZLX.ZLX_LJFORN, SA2.A2_NREDUZ %"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()
_cAlias := GetNextAlias()

RGLT033Q(_cAlias, _cFiltro, _cFilDeb, _cCampos, _cOrder, _cFilSD1)

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

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
oReport:SetMsgPrint("Imprimindo")
oReport:SetMeter(0)

//-- Rodape
oReport:SetPageFooter(3, {|| oReport:PrintText(Replicate(" ",35)+Replicate("_",30)+Replicate(" ",30)+Replicate("_",30)+Replicate(" ",30)+Replicate("_",30)),;
oReport:PrintText(Replicate(" ",50)+"Depto. Leite"+Replicate(" ",60)+"Depto. Suprimento"+Replicate(" ",60)+"Depto. Financeiro" ) },.F.)

While !oReport:Cancel() .And. (_cAlias)->(!EOF())
	oReport:Section(1):PrintLine()
	oReport:IncMeter()
	_cFilial := (_cAlias)->ZZX_FILIAL
	_cProduto := (_cAlias)->ZZX_CODPRD+' - '+AllTrim((_cAlias)->DESCRI)
  _cProceden := AllTrim(_cProduto)+' - '+oReport:Section(1):Cell("ZLX_TIPOLT"):GetCBox()
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(dbCloseArea())

//==========================================================================
// Query do relat�rio da secao 2
//==========================================================================
oReport:Section(2):BeginQuery()
_cAlias := GetNextAlias()
_cCampos := "% %"
_cOrder :=  "% ZZX.ZZX_FILIAL, ZZX.ZZX_CODPRD, ORD_PRC %"

RGLT033Q(_cAlias, _cFiltro, _cFilDeb, _cCampos, _cOrder, _cFilSD1)

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

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
//Impressao do Relatorio - Totalizadores
//=======================================================================
//Encerra a p�gina para os totalizadores ficarem em uma p�gina separada
oReport:EndPage(.T.)
oReport:SetStartPage(.T.)

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

/*
===============================================================================================================================
Programa----------: RGLT033Q
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 29/07/2022
Descri��o---------: Processa query do relat�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT033Q (_cAlias, _cFiltro, _cFilDeb, _cCampos, _cOrder, _cFilSD1)

BeginSql alias _cAlias
SELECT ZZX.ZZX_FILIAL, ZZX.ZZX_CODPRD, SX5.X5_DESCRI DESCRI, ZLX.ZLX_TIPOLT,
       CASE
         WHEN ZLX.ZLX_TIPOLT = 'P' THEN '1'
         WHEN ZLX.ZLX_TIPOLT = 'F' THEN '2'
         WHEN ZLX.ZLX_TIPOLT = 'T' THEN '3'
       END ORD_PRC
       %exp:_cCampos%, SUM(ZLX.ZLX_VOLREC) ZLX_VOLREC,
       NVL(ROUND(
       CASE
            WHEN ZZX.ZZX_CODPRD = '004' THEN 0
            WHEN C7_L_EXEST > 0 THEN ROUND(SUM((ZLX.ZLX_VOLREC * COALESCE(ROUND(ZAP.ZAP_EST, 2), 0) / 100)) * C7_L_EXEST,2) /*QTD_EST_KG*/
            ELSE SUM(ZLX.ZLX_VOLREC * ENT.C7_PRECO)
        END  +     
       SUM((((NVL(ROUND(ZAP_GORD,2),0) - ENT.C7_L_PMGB) * ZLX.ZLX_VOLREC) / 100) *
       CASE
            WHEN NVL(ROUND(ZAP_GORD, 2),0) > ENT.C7_L_PMGB AND
                  NVL(ROUND(ZAP_GORD, 2),0) <= ENT.C7_L_PMGB2 THEN
              ENT.C7_L_EXEMG
            WHEN NVL(ROUND(ZAP_GORD, 2),0) > ENT.C7_L_PMGB2 THEN
              ENT.C7_L_EXEM2
            ELSE
              0
          END),2),0) + NVL(AVG(FIN.E2_VALOR),0) - NVL(FUNRURAL,0) 
          - (CASE WHEN SUM(F2D_VALOR) > 0 OR SUM(D1_VALFUND) > 0 THEN ROUND(SUM(ZLX.ZLX_VOLREC)*0.000841,2) ELSE 0 END) 
          VL_A_PAGAR,
       SUM(ZLX.ZLX_VOLNF) ZLX_VOLNF,
       SUM(ZLX.ZLX_VLRNF) ZLX_VLRNF,
       SUM(ZLX.ZLX_DIFVOL) ZLX_DIFVOL,
       ROUND(AVG(NVL(ROUND(ZAP.ZAP_GORD,2),0)),2) ZAP_GORD,
       ROUND(AVG(NVL(ROUND(ZAP.ZAP_EST,2),0)),2) ZAP_EST,
       ROUND(SUM((ZLX.ZLX_VOLREC * NVL(ROUND(ZAP.ZAP_GORD,2),0) / 100)),2) QTD_MG_KG,
       ROUND(SUM((ZLX.ZLX_VOLREC * NVL(ROUND(ZAP.ZAP_EST,2),0) / 100)),2) QTD_EST_KG
  FROM %Table:ZLX% ZLX, %Table:ZZX% ZZX, %Table:SA2% SA2, %Table:SX5% SX5,
  (SELECT ZAP.ZAP_FILIAL, ZAP.ZAP_CODIGO, AVG(ZAP.ZAP_GORD) ZAP_GORD, AVG(ZAP.ZAP_EST) ZAP_EST FROM %Table:ZAP% ZAP WHERE ZAP.D_E_L_E_T_ = ' '
          GROUP BY ZAP.ZAP_FILIAL, ZAP.ZAP_CODIGO) ZAP,
  (SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, C7_PRECO, C7_L_PMGB, C7_L_PMGB2, C7_L_EXEST, C7_L_PMEST, C7_L_EXEMG, C7_L_EXEM2, NVL(F2D_VALOR,0) F2D_VALOR, D1_VALFUND,
               (SELECT SUM(D.D1_VLSENAR+D.D1_VALFUN+D.D1_VALINS)
               + NVL(SUM((SELECT SUM(X.D1_VLSENAR+X.D1_VALFUN+X.D1_VALINS) FROM %Table:SD1% X
               WHERE X.D_E_L_E_T_ = ' '
               AND X.D1_FILIAL = D.D1_FILIAL
               AND X.D1_NFORI = D.D1_DOC
               AND X.D1_SERIORI = D.D1_SERIE
               AND X.D1_FORNECE = D.D1_FORNECE
               AND X.D1_LOJA = D.D1_LOJA
               AND X.D1_COD = D.D1_COD
               /*AND X.D1_ITEMORI = D.D1_ITEM*/
               )),0) 
               - NVL(SUM((SELECT SUM(X.D2_VLSENAR+X.D2_VALFUN+X.D2_VALINS) FROM %Table:SD2% X
               WHERE X.D_E_L_E_T_ = ' '
               AND X.D2_FILIAL = D.D1_FILIAL
               AND X.D2_NFORI = D.D1_DOC
               AND X.D2_SERIORI = D.D1_SERIE
               AND X.D2_CLIENTE = D.D1_FORNECE
               AND X.D2_LOJA = D.D1_LOJA
               AND X.D2_COD = D.D1_COD
               /*AND X.D2_ITEMORI = D.D1_ITEM*/
               AND NOT EXISTS (SELECT 1 FROM %Table:SD1% SD11
                                        WHERE SD11.D_E_L_E_T_ = ' '
                                        AND X.D2_FILIAL = SD11.D1_FILIAL
                                        AND X.D2_CLIENTE = SD11.D1_FORNECE
                                        AND X.D2_LOJA = SD11.D1_LOJA
                                        AND X.D2_DOC = SD11.D1_NFORI
                                        AND X.D2_SERIE = SD11.D1_SERIORI
                                        AND X.D2_COD = SD11.D1_COD
                                        AND X.D2_QUANT = SD11.D1_QUANT)
               )),0)
                  FROM %Table:SF1% F, %Table:SD1% D
                 WHERE F.D_E_L_E_T_ = ' '
                   AND D.D_E_L_E_T_ = ' '
                   AND F.F1_FILIAL = D.D1_FILIAL
                   AND F.F1_DOC = D.D1_DOC
                   AND F.F1_SERIE = D.D1_SERIE
                   AND F.F1_FORNECE = D.D1_FORNECE
                   AND F.F1_LOJA = D.D1_LOJA
                   AND SD1.D1_FILIAL = F.F1_FILIAL
                   AND SD1.D1_FORNECE = F.F1_FORNECE
                   AND SD1.D1_LOJA = F.F1_LOJA
                   AND SD1.D1_COD = D.D1_COD
                   AND F.F1_FORMUL <> 'S'
                   AND F.F1_STATUS = 'A'
                   AND D.D1_NFORI = ' '
                   %exp:_cFilSD1%
                   AND F.F1_DTDIGIT BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%) FUNRURAL
  FROM %Table:SD1% SD1, %Table:SF1% SF1, %Table:SC7% SC7,
                  (SELECT F2D_IDREL, F2D_VALOR FROM %Table:F2D% F2D, %Table:F2B% F2B
                    WHERE F2D.D_E_L_E_T_ = ' '
                    AND F2B.D_E_L_E_T_ = ' '
                    AND F2D_TABELA = 'SD1'
                    AND F2D_IDCAD = F2B_ID
                    AND F2B_TRIB = 'FUNDES') B
       WHERE SD1.D_E_L_E_T_ = ' '
       AND SF1.D_E_L_E_T_ = ' '
       AND SC7.D_E_L_E_T_ = ' '
       AND SD1.D1_FILIAL = SF1.F1_FILIAL
       AND SF1.F1_FORNECE = SD1.D1_FORNECE
       AND SF1.F1_LOJA = SD1.D1_LOJA
       AND SF1.F1_DOC = SD1.D1_DOC
       AND SD1.D1_IDTRIB = B.F2D_IDREL (+)
       AND SF1.F1_STATUS = 'A'
       AND SD1.D1_FILIAL = SC7.C7_FILIAL
       AND SD1.D1_PEDIDO = SC7.C7_NUM
       AND SD1.D1_ITEMPC = SC7.C7_ITEM
       AND SD1.D1_FORMUL <> 'S'
       %exp:_cFilSD1%
       GROUP BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, C7_PRECO, C7_L_PMGB, C7_L_PMGB2, C7_L_EXEST, C7_L_PMEST, C7_L_EXEMG, C7_L_EXEM2, D1_VALFUND, F2D_VALOR) ENT,
  (SELECT SE2.E2_FILIAL, SE2.E2_FORNECE, SE2.E2_LOJA, 
       SUM(CASE WHEN SE2.E2_ORIGEM = 'AGLT022' THEN SE2.E2_VALOR+SE2.E2_ACRESC-SE2.E2_DECRESC ELSE (SE2.E2_VALOR+SE2.E2_ACRESC-SE2.E2_DECRESC)*-1 END) E2_VALOR FROM %Table:SE2% SE2
       WHERE SE2.D_E_L_E_T_ = ' '
       AND SE2.E2_VENCTO BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR12%
       AND (%exp:_cFilDeb%
           (SE2.E2_ORIGEM = 'AGLT022' AND SE2.E2_TIPO = 'NF'))
     GROUP BY SE2.E2_FILIAL, SE2.E2_FORNECE, SE2.E2_LOJA) FIN
 WHERE ZLX.D_E_L_E_T_ = ' '
   AND ZZX.D_E_L_E_T_ = ' '
   AND SA2.D_E_L_E_T_ = ' '
   AND SX5.D_E_L_E_T_ = ' '
   AND ZZX_CODPRD = SX5.X5_CHAVE
   AND SX5.X5_TABELA = 'Z7'
   AND ZZX.ZZX_CODIGO = ZLX.ZLX_CODANA
   AND ZLX.ZLX_FILIAL = ZZX.ZZX_FILIAL
   AND ZLX.ZLX_FILIAL = ZAP.ZAP_FILIAL (+)
   AND ZLX.ZLX_CODANA = ZAP.ZAP_CODIGO (+)
   AND ZLX.ZLX_FILIAL = ENT.D1_FILIAL (+)
   AND ZLX.ZLX_NRONF  = ENT.D1_DOC (+)
   AND ZLX.ZLX_SERINF = ENT.D1_SERIE (+)
   AND ZLX.ZLX_FORNEC = ENT.D1_FORNECE (+)
   AND ZLX.ZLX_LJFORN = ENT.D1_LOJA (+)
   AND ZLX.ZLX_FORNEC = FIN.E2_FORNECE(+)
   AND ZLX.ZLX_LJFORN = FIN.E2_LOJA(+)
   AND ZLX.ZLX_FILIAL = FIN.E2_FILIAL(+)
   %exp:_cFiltro%
   AND ZLX.ZLX_FORNEC = SA2.A2_COD
   AND ZLX.ZLX_LJFORN = SA2.A2_LOJA
   AND ZZX.ZZX_CODIGO = ZLX.ZLX_CODANA
   AND ZLX.ZLX_DTENTR BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
   AND ZZX.ZZX_FORNEC BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
   AND ZZX.ZZX_LJFORN BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR08%
 GROUP BY ZZX.ZZX_FILIAL, ZZX.ZZX_CODPRD, SX5.X5_DESCRI, ZLX.ZLX_TIPOLT, FUNRURAL, C7_L_EXEST %exp:_cCampos%
  ORDER BY %exp:_cOrder%
EndSql

Return
