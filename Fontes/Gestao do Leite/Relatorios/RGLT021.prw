/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------:-----------------------------------------------------------------------------------------------
 Erich Buttner	  | 29/01/2019 | Migra��o para tReport e inclu�da sele��o de v�rios setores. Chamado 27636
-------------------------------:-----------------------------------------------------------------------------------------------
 Lucas B. Ferreira| 04/02/2019 | Retirados campos desnecess�rios. Chamado 27636
-------------------------------------------------------------------------------------------------------------------------------
 Lucas B. Ferreira| 26/07/2019 | Corrigida a barra de progresso. Help 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT021
Autor-------------: Renato de Morcerf
Data da Criacao---: 27/01/2009
===============================================================================================================================
Descri��o---------: Rela��o Rota/Linha
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT021

Local oReport
Pergunte("RGLT021",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Erich Buttner
Data da Criacao---: 26/03/2013
===============================================================================================================================
Descri��o---------: Defini��o do Componente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef

Local oReport
Local oSection1
Local _aOrdem   := {"Por Linha"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT021","Relat�rio Rela��o Rota/Linha","RGLT021",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Imprime a rela��o das Rotas/Linhas")

oSection := TRSection():New(oReport,""	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)
oSection:SetTotalInLine(.F.)
//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"cPeriodo",/*Tabela*/,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

oSection1 := TRSection():New(oSection,""	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,""/*uTotalText*/)
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,"cPeriodo",/*Tabela*/,"Periodo: "/*cTitle*/,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"LINROT",/*Tabela*/,"Linha/Rota: "/*cTitle*/,/*Picture*/,60/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZL3_KM","ZL3","KM: "/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZL3_VLRFRT",/*Tabela*/,"Tarifa: "/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZL3_FRMPG","ZL3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

oSection2 := TRSection():New(oSection,""	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,""/*uTotalText*/)
oSection2:SetTotalInLine(.F.)
TRCell():New(oSection2,"cTransp",/*Tabela*/,"Transportadora: "/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

oSection3 := TRSection():New(oSection,""	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,""/*uTotalText*/)
oSection3:SetTotalInLine(.F.)
TRCell():New(oSection3,"CODIGO",/*Tabela*/,"Codigo"/*cTitle*/,/*Picture*/,11/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"NOMEPROD",/*Tabela*/,"Produtor"/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"VOLUME",/*Tabela*/,"Volume"/*cTitle*/,"@E 999,999,999"/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"nMedDia",/*Tabela*/,"Media/Dia"/*cTitle*/,"@E 9,999,999"/*Picture*/,09/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"A2_L_FAZEN","SA2"/*Tabela*/,"Fazenda"/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"CC2_MUN","CC2"/*Tabela*/,"Municipio"/*cTitle*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"nKMRodado",/*Tabela*/,"KM Rodado"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"nDensidade",/*Tabela*/,"Densidade"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection3,"nCusFret",/*Tabela*/,"Custo Frete"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

TRFunction():New(oSection3:Cell("NOMEPROD")/*oCell*/,/*cName*/,"COUNT"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oSection3:Cell("VOLUME")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oSection3:Cell("nMedDia")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oSection3:Cell("nKMRodado")/*oCell*/,/*cName*/,""/*cFunction*/,/*oBreak*/,"KM Rodado"/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oSection3:Cell("nDensidade")/*oCell*/,/*cName*/,""/*cFunction*/,/*oBreak*/,"Densidade"/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oSection3:Cell("nCusFret")/*oCell*/,/*cName*/,""/*cFunction*/,/*oBreak*/,"Custo Frete"/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Erich Buttner
Data da Criacao---: 26/03/2013
===============================================================================================================================
Descri��o---------: Processa dados do relat�rio
===============================================================================================================================
Parametros--------: oReport, _aOrdem
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cAlias 		:= GetNextAlias()
Local _cFiltro  	:= "%"
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-Agrupa por filial 2-Agrupa tamb�m por Setor
Local _nMedDia		:= 0
Local _nCusFret		:= 0
Local _nKMRodado	:= 0
Local _nDensidade	:= 0
Local _nCountRec	:= 0
Local _cUltLin		:= ""
//=====================================================
// Adiciona a ordem escolhida ao titulo do relatorio  |
//=====================================================
oReport:SetTitle(oReport:Title() + " ("+AllTrim(_aOrdem[_nOrdem])+") ")

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
oReport:Section(1):Section(3):Cell("nMedDia"):SetBlock({||_nMedDia})
oReport:Section(1):Section(3):Cell("nCusFret"):SetBlock({||_nCusFret})
oReport:Section(1):Section(3):Cell("nDensidade"):SetBlock({||_nDensidade})
oReport:Section(1):Section(3):Cell("nKMRodado"):SetBlock({||_nKMRodado})

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR01) .Or. Empty(MV_PAR01) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND ZLD_SETOR IN "+ FormatIn( AllTrim(MV_PAR01) , ';' )
EndIf
_cFiltro+= "%"

//==========================================================================
// Query do relat�rio da secao 3
//==========================================================================
oReport:Section(1):Section(3):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
	SELECT ZLD_FILIAL, ZLD_SETOR, ZLD_LINROT, ZLD_LINROT||'-'||ZL3_DESCRI LINROT, ZLD_RETIRO||'-'||ZLD_RETILJ CODIGO, SUM(ZLD_QTDBOM) VOLUME, ZL3_KM, ZL3_VLRFRT, ZL3_FRMPG,
		ZL3_FRETIS, ZL3_FRETLJ, SA2F.A2_NOME NOMEFRET, SA2P.A2_NOME NOMEPROD, SA2P.A2_L_FAZEN, CC2_MUN
	  FROM %Table:ZLD% ZLD, %Table:ZL3% ZL3, %Table:SA2% SA2F, %Table:SA2% SA2P, %Table:CC2% CC2
	 WHERE ZLD.D_E_L_E_T_ = ' '
	 AND ZL3.D_E_L_E_T_ = ' '
	 AND SA2F.D_E_L_E_T_ (+) = ' '
	 AND SA2P.D_E_L_E_T_ (+) = ' '
	 AND CC2.D_E_L_E_T_ (+) = ' '
	 %Exp:_cFiltro%
	 AND ZLD_FILIAL = %xFilial:ZLD% 
	 AND ZLD_FILIAL = ZL3_FILIAL
	 AND ZLD_LINROT = ZL3_COD
	 AND ZLD.ZLD_RETIRO = SA2P.A2_COD (+)
	 AND ZLD.ZLD_RETILJ = SA2P.A2_LOJA (+)
	 AND ZL3.ZL3_FRETIS = SA2F.A2_COD (+)
	 AND ZL3.ZL3_FRETLJ = SA2F.A2_LOJA (+)
	 AND SA2P.A2_EST = CC2_EST (+)
	 AND SA2P.A2_COD_MUN = CC2_CODMUN (+)
	 AND ZLD_DTCOLE BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
	 AND ZLD_LINROT BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR03%
	 GROUP BY ZLD_FILIAL, ZLD_SETOR, ZLD_LINROT, ZLD_RETIRO, ZLD_RETILJ, ZL3_DESCRI, ZL3_KM, ZL3_VLRFRT, ZL3_FRMPG,
	 		ZL3_FRETIS, ZL3_FRETLJ, SA2F.A2_NOME, SA2P.A2_NOME, SA2P.A2_L_FAZEN, CC2_MUN
	 ORDER BY ZLD_FILIAL, ZLD_SETOR, ZLD_LINROT, ZLD_RETIRO, ZLD_RETILJ
EndSql
//==========================================================================
// Metodo EndQuery ( Classe TRSection )                                     
//                                                                          
// Prepara o relat�rio para executar o Embedded SQL.                        
//                                                                          
// ExpA1 : Array com os parametros do tipo Range                            
//                                                                          
//==========================================================================
oReport:Section(1):Section(3):EndQuery(/*Array com os parametros do tipo Range*/)

//==========================================================================
// Trata as c�lulas a serem exibidas pela primeira vez
//==========================================================================
oReport:Section(1):Section(1):Cell("cPeriodo"):SetValue(SUBSTR(DTOS(MV_PAR04),7,2)+"/"+SUBSTR(DTOS(MV_PAR04),5,2)+"/"+SUBSTR(DTOS(MV_PAR04),1,4)+" � "+SUBSTR(DTOS(MV_PAR05),7,2)+"/"+SUBSTR(DTOS(MV_PAR05),5,2)+"/"+SUBSTR(DTOS(MV_PAR05),1,4))
oReport:Section(1):Section(1):Cell("LINROT"):SetValue((_cAlias)->LINROT)
oReport:Section(1):Section(1):Cell("ZL3_KM"):SetValue((_cAlias)->ZL3_KM)
oReport:Section(1):Section(1):Cell("ZL3_VLRFRT"):SetValue((_cAlias)->ZL3_VLRFRT)
oReport:Section(1):Section(1):Cell("ZL3_FRMPG"):SetValue(IF((_cAlias)->ZL3_FRMPG == "L","Por Litro",IF((_cAlias)->ZL3_FRMPG == "K","Por Km",IF((_cAlias)->ZL3_FRMPG == "F","Mensal",IF((_cAlias)->ZL3_FRMPG == "V","Viagem","")))))
oReport:Section(1):Section(2):Cell("cTransp"):SetValue((_cAlias)->ZL3_FRETIS+" "+(_cAlias)->ZL3_FRETLJ+" - "+(_cAlias)->NOMEFRET)

//===========================
//Impressao do Relatorio
//===========================
oReport:Section(1):Section(1):Init()
oReport:Section(1):Section(1):PrintLine()
oReport:Section(1):Section(1):Finish()

oReport:Section(1):Section(2):Init()
oReport:Section(1):Section(2):PrintLine()
oReport:Section(1):Section(2):Finish()

oReport:Section(1):Section(3):Init()

nInc	:= reccount()
oReport:SetMeter(nInc)

_cUltLin := ""

//=======================================================================
//Impressao do Relatorio
//=======================================================================
Count To _nCountRec
(_cAlias)->( DbGotop() )
oReport:SetMsgPrint("Imprimindo")
oReport:SetMeter(_nCountRec)

While !oReport:Cancel() .And. (_cAlias)->(!EOF())
	_nMedDia := (_cAlias)->VOLUME/((MV_PAR05-MV_PAR04)+1)
	_cUltLin := (_cAlias)->ZLD_LINROT
	_nKMRodado := u_getkm((_cAlias)->ZLD_FILIAL,(_cAlias)->ZLD_SETOR,(_cAlias)->ZLD_LINROT,,,MV_PAR04,MV_PAR05)
	
	oReport:Section(1):Section(3):PrintLine()
	oReport:IncMeter()
	(_cAlias)->(DbSkip())
	
	If _cUltLin <> (_cAlias)->ZLD_LINROT .And. (_cAlias)->(!EOF())        
		_nDensidade := (_cAlias)->VOLUME/_nKMRodado
		_nCusFret   := (_cAlias)->ZL3_VLRFRT*_nKMRodado/(_cAlias)->VOLUME

		oReport:Section(1):Section(3):Finish()
		oReport:Section(1):Section(3):Init()
		
		oReport:EndPage(.T.)
		oReport:StartPage(.T.)
		//Sess�o 01		
		oReport:Section(1):Init()
		oReport:Section(1):Section(1):Init()
		oReport:Section(1):Section(1):Cell("LINROT"):SetValue((_cAlias)->LINROT)
		oReport:Section(1):Section(1):Cell("ZL3_KM"):SetValue((_cAlias)->ZL3_KM)
		oReport:Section(1):Section(1):Cell("ZL3_VLRFRT"):SetValue((_cAlias)->ZL3_VLRFRT)
		oReport:Section(1):Section(1):Cell("ZL3_FRMPG"):SetValue(IF((_cAlias)->ZL3_FRMPG == "L","Por Litro",IF((_cAlias)->ZL3_FRMPG == "K","Por Km",IF((_cAlias)->ZL3_FRMPG == "F","Mensal",IF((_cAlias)->ZL3_FRMPG == "V","Viagem","")))))
		oReport:Section(1):Section(1):PrintLine()
		oReport:Section(1):Section(1):Finish()
		//Sess�o 02
		oReport:Section(1):Section(2):Init()
		oReport:Section(1):Section(2):Cell("cTransp"):SetValue((_cAlias)->ZL3_FRETIS+" "+(_cAlias)->ZL3_FRETLJ+" "+(_cAlias)->NOMEFRET)
		oReport:Section(1):Section(2):PrintLine()
		oReport:Section(1):Section(2):Finish()
	
	EndIf
	
EndDo

oReport:Section(1):Section(1):Finish()
oReport:Section(1):Section(1):Init()

oReport:Section(1):Section(2):Finish()
oReport:Section(1):Section(2):Init()

(_cAlias)->(DBCloseArea())

Return