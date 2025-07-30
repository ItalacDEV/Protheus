/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 29/12/2020 | Retirada leitura direta do sigapss. Chamado 35123
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/08/2023 | Relat�rio migrado para tReport. Chamado 44764
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 21/12/2023 | Corrigir totalizado do Sint�tico. Chamado 45922
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RFIS004
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 17/08/2023
===============================================================================================================================
Descri��o---------: Relat�rio Resumo Documentos Escriturados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RFIS004()

Local oReport
Pergunte("RFIS004",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 17/08/2023
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
Local _aOrdem   := {"Filial+AnoMes+Funcionario"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RFIS004","Relat�rio Resumo de Documentos Escriturados ","RFIS004",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Apura a quantidade de documentos escriturados por esp�cie e/ou funcion�rios")
oSection := TRSection():New(oReport,"Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)
oReport:SetLandscape()//Paisagem
oSection:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"F1_FILIAL","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"MES_ANO",/*Table*/,"M�s/Ano"/*cTitle*/,/*Picture*/,7/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"DT_INC",/*Table*/,"Inclus�o"/*cTitle*/,"@!"/*Picture*/,19/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"USR_NOME",/*Table*/,"Usu�rio"/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBac[k*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_DOC","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_SERIE","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_FORNECE","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_LOJA","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_DTDIGIT","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_EMISSAO","SF1"/*Table*/,"Esp�cie"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_ESPECIE","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"F1_VALBRUT","SF1"/*Table*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"QTD",/*Table*/,"Quant."/*cTitle*/,'@E 9,999,999,999,999'/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 17/08/2023
===============================================================================================================================
Descri��o---------: Processa impress�o do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro	:= "%"
Local _cCampos  := "%"
Local _cAlias	  := ""
Local _aSelFil	:= {}
Local _nOrdem	  := oReport:Section(1):GetOrder() 
Local _cFilial	:= ""
Local _cUser    := ""

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR01 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"SF1")
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

//================================================================================
//| Configura��o das quebras do relat�rio                                        |
//================================================================================
oQbrUser:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("USR_NOME") /*uBreak*/, {||"Total: " + _cUser } /*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.F./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell(IIf(MV_PAR04 == 2,"QTD","F1_ESPECIE"))/*oCell*/,/*cName*/,IIf(MV_PAR04 == 2,"SUM","COUNT")/*cFunction*/,oQbrUser/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("F1_VALBRUT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrUser/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

oQbrFilial	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("F1_FILIAL")/*uBreak*/, {||"Total da Filial: " + _cFilial + ' - '+ FWFilialName(cEmpAnt,_cFilial,1 )}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell(IIf(MV_PAR04 == 2,"QTD","F1_ESPECIE"))/*oCell*/,/*cName*/,IIf(MV_PAR04 == 2,"SUM","COUNT")/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("F1_VALBRUT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
If MV_PAR04 == 2
  oReport:Section(1):Cell("F1_DOC"):Disable()
  oReport:Section(1):Cell("F1_SERIE"):Disable()
  oReport:Section(1):Cell("F1_FORNECE"):Disable()
  oReport:Section(1):Cell("F1_LOJA"):Disable()
  oReport:Section(1):Cell("F1_DTDIGIT"):Disable()
  oReport:Section(1):Cell("F1_EMISSAO"):Disable()
Else
  oReport:Section(1):Cell("QTD"):Disable()
EndIf
//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
If MV_PAR04 == 2
  _cCampos += "SUM(F1_VALBRUT) F1_VALBRUT, COUNT(1) QTD" 
Else
  _cCampos += " F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_DTDIGIT, F1_EMISSAO, F1_VALBRUT, TO_CHAR(CAST( SF1.I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE),'DD/MM/YYYY HH:MM:SS') DT_INC "
EndIf
_cCampos += "%"

_cFiltro += " AND F1_FILIAL "+ GetRngFil( _aSelFil, "SF1", .T.,)
If MV_PAR04 == 2
  _cFiltro += " GROUP BY F1_FILIAL, F1_ESPECIE, USR_ID, USR_NOME, TO_CHAR(CAST( SF1.I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE), 'MM/YYYY') "
EndIf
_cFiltro += " %"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
  SELECT F1_FILIAL,
          TO_CHAR(CAST( SF1.I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE), 'MM/YYYY') MES_ANO,
          USR_ID, USR_NOME, F1_ESPECIE, %exp:_cCampos%
    FROM SF1010 SF1, SYS_USR U
    WHERE SF1.D_E_L_E_T_ = ' '
      AND U.D_E_L_E_T_ (+) = ' '
      AND U.USR_ID (+) = SUBSTR(F1_USERLGI, 11, 1) || SUBSTR(F1_USERLGI, 15, 1) || SUBSTR(F1_USERLGI, 02, 1)||
          SUBSTR(F1_USERLGI, 06, 1) || SUBSTR(F1_USERLGI, 10, 1) || SUBSTR(F1_USERLGI, 14, 1) 
      AND TO_CHAR(CAST( SF1.I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE), 'YYYYMMDD') BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR03%
      AND F1_STATUS = 'A'
      %exp:_cFiltro%
  ORDER BY F1_FILIAL,2 , USR_NOME,  F1_ESPECIE
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
oReport:SetMsgPrint("Imprimindo")
oReport:SetMeter(0)

While !oReport:Cancel() .And. (_cAlias)->(!EOF())
	oReport:Section(1):PrintLine()
	oReport:IncMeter()
	_cFilial := (_cAlias)->F1_FILIAL
	_cUser := (_cAlias)->USR_NOME
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(dbCloseArea())

Return
