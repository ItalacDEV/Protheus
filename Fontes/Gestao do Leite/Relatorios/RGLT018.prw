/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 04/07/2019 |Relat�rio reescrito, aproveitando apenas a ideia base. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/07/2019 |Modificado para tratar registros duplicados que n�o deveriam ocorrer. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 25/07/2019 | Corrigida a barra de progresso. Help 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT018
Autor-------------: Abrahao P. Santos
Data da Criacao---: 23/01/2009
===============================================================================================================================
Descri��o---------: Relat�rio de Diverg�ncia entre Estoque (SD3) e Recep��o de Leite Pr�prio (ZLD)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT018()

Local oReport
Pergunte("RGLT018",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 04/07/2019
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
Local _aOrdem   := {"Por Filial"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT018","Diferen�a entre Movimento de Estoque e Recep��o Leite Pr�prio","RGLT018",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Cruza as informa��es entre as Recep��es de Leite Pr�prio e os Movimentos de Estoque, encontrando diverg�ncias.")
oSection := TRSection():New(oReport,"Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)

oSection:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"FILIAL",/*Table*/,"Fil"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLD_DTCOLE","ZLD","Data"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"TICKET",/*Table*/,"Ticket"/*cTitle*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_COD","ZL2","Setor"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_DESCRI","ZL2",/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"INEXISTENTE","ZLD","Inexistente em" ,/*Picture*/,9/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"QTD_RECEP","ZLD","Qtd. Repec��o" ,"@E 9,999,999"/*Picture*/,9/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"QTD_EST","ZLD","Qtd. Estoque" ,"@E 9,999,999"/*Picture*/,9/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"DIFERENCA","ZLD","Diferen�a" ,"@E 9,999,999"/*Picture*/,9/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 04/07/2019
===============================================================================================================================
Descri��o---------: Processa impress�o do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltroZLD	:= "%"
Local _cFiltroSD3	:= "%"
Local _cAlias		:= ""
Local _aSelFil		:= {}
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-Agrupa por filial 2-Agrupa tamb�m por Setor
Local _cFilial		:= ""
Local _nCountRec	:= 0

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR04 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZLD")
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
oQbrFilial	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("FILIAL")/*uBreak*/, {||"Total da Filial: " + _cFilial + ' - '+ FWFilialName(cEmpAnt,_cFilial,1 )}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell("TICKET")/*oCell*/,/*cName*/,"COUNT"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("QTD_RECEP")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("QTD_EST")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("DIFERENCA")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
_cFiltroZLD += " AND ZLD.ZLD_FILIAL "+ GetRngFil( _aSelFil, "ZLD", .T.,)
_cFiltroSD3 += " AND SD3.D3_FILIAL "+ GetRngFil( _aSelFil, "SD3", .T.,)

//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR03) .Or. Empty(MV_PAR03) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltroZLD += " AND ZLD.ZLD_SETOR IN "+ FormatIn( AllTrim(MV_PAR03) , ';' )
	_cFiltroSD3 += " AND SD3.D3_L_SETOR IN "+ FormatIn( AllTrim(MV_PAR03) , ';' )
EndIf
_cFiltroZLD += " AND ZLD.ZLD_DTCOLE BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"' %"
_cFiltroSD3 += " AND SD3.D3_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"' %"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
SELECT A.*, ZL2.ZL2_COD, ZL2.ZL2_DESCRI
  FROM %Table:ZL2% ZL2,
       (SELECT CASE WHEN L.ZLD_FILIAL IS NULL THEN E.D3_FILIAL ELSE L.ZLD_FILIAL END FILIAL,
               CASE WHEN L.ZLD_DTCOLE IS NULL THEN E.D3_EMISSAO ELSE L.ZLD_DTCOLE END ZLD_DTCOLE,
               CASE WHEN L.ZLD_TICKET IS NULL THEN E.D3_L_ORIG ELSE L.ZLD_TICKET END TICKET,
               CASE WHEN L.ZLD_SETOR IS NULL THEN E.D3_L_SETOR ELSE L.ZLD_SETOR END SETOR,
               CASE WHEN L.ZLD_SETOR IS NULL THEN 'Leite' WHEN E.D3_L_SETOR IS NULL THEN 'Estoque' ELSE ' ' END INEXISTENTE,
               L.ZLD_TOTBOM QTD_RECEP,
               E.D3_QUANT QTD_EST,
               ABS(NVL(L.ZLD_TOTBOM,0) - NVL(E.D3_QUANT,0)) DIFERENCA
          FROM (SELECT ZLD.ZLD_FILIAL, ZLD.ZLD_DTCOLE, ZLD.ZLD_TICKET, ZLD.ZLD_SETOR, ZLD.ZLD_TOTBOM
                  FROM %Table:ZLD% ZLD
                 WHERE ZLD.D_E_L_E_T_ = ' '
                   %exp:_cFiltroZLD%
                   AND ZLD.ZLD_TOTBOM > 0
                 GROUP BY ZLD.ZLD_FILIAL, ZLD.ZLD_DTCOLE, ZLD.ZLD_TICKET, ZLD.ZLD_SETOR, ZLD.ZLD_TOTBOM) L
          FULL OUTER JOIN (SELECT SD3.D3_FILIAL, SD3.D3_EMISSAO, SD3.D3_L_ORIG, SD3.D3_L_SETOR, SUM(SD3.D3_QUANT) D3_QUANT
                            FROM %Table:SD3% SD3
                           WHERE SD3.D_E_L_E_T_ = ' '
                             %exp:_cFiltroSD3%
                             AND SD3.D3_ESTORNO <> 'S'
                             AND SD3.D3_L_ORIG <> ' '
                           GROUP BY SD3.D3_FILIAL, SD3.D3_EMISSAO, SD3.D3_L_ORIG, SD3.D3_L_SETOR) E
            ON E.D3_FILIAL = L.ZLD_FILIAL
           AND E.D3_L_SETOR = L.ZLD_SETOR
           AND E.D3_L_ORIG = L.ZLD_TICKET
         WHERE (L.ZLD_TOTBOM <> E.D3_QUANT 
               OR L.ZLD_TOTBOM IS NULL OR
               E.D3_QUANT IS NULL)) A
 WHERE ZL2.D_E_L_E_T_ = ' '
   AND ZL2.ZL2_FILIAL = FILIAL
   AND ZL2.ZL2_COD = SETOR
 ORDER BY FILIAL, TICKET, ZLD_DTCOLE

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
	_cFilial := (_cAlias)->FILIAL
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(dbCloseArea())

Return