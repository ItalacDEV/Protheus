/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 21/07/2021 | Tratamento para produtores familiares (A2_L_CLASS=L). Chamado 37147
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 20/09/2021 | Criado filtro para produtores familiares. Chamado 37789
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 24/05/2022 | Corrigido v�nculo da ZL3/ZL2 para casos onde o setor da linha for alterado. Chamado 40203
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT062
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 29/05/2014
===============================================================================================================================
Descri��o---------: Relat�rio de confer�ncia do volume e quantidade de produtores por munic�pio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT062()

Local oReport
Pergunte("RGLT062",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Erich Buttner
Data da Criacao---: 27/03/2013
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
Local _aOrdem   := {"Por Filial","Por Setor","Por Dia"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT062","Movimenta��o de Leite por Munic�pio","RGLT062",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Totaliza movimenta��o de Leite por Munic�pio")
oSection := TRSection():New(oReport,"Movimentos Por Munic�pio"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)

oSection:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"ZL3_FILIAL","ZL3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_COD","ZL2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_DESCRI","ZL2",/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLD_DTCOLE","ZLD","Data"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL3_COD","ZL3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL3_DESCRI","ZL3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_EST","SA2","Est"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_COD_MUN","SA2","Cod.M"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"CC2_MUN","CC2_MUN",/*cTitle*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"QTD_PRD",/*Tabela*/,"Nr. Produt.", "@E 9,999,999,999" ,12,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"VOLUME",/*Tabela*/,"Volume" ,"@E 9,999,999,999" ,12,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Erich Buttner
Data da Criacao---: 27/03/2013
===============================================================================================================================
Descri��o---------: Relacao Rota/Linha
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro		:= "%"
Local _cCampo		:= "%"
Local _cCampo2		:= "%"
Local _cTabela		:= " "
Local _cGroup		:= "%"
Local _cGroup2		:= "%"
Local _cOrder		:= "%"
Local _cAlias		:= ""
Local _cAux			:= IIf( MV_PAR06 == 1 , "ZLD" , "ZLW" )//1-Produtor 2-Cooperativa
Local _aSelFil		:= {}
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-Agrupa por filial 2-Agrupa tamb�m por Setor
Local _cFilial		:= ""
Local _cData		:= ""
Local _cSetor		:= ""
Local _nCountRec	:= 0

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR08 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,_cAux)
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
If _nOrdem == 2 //Quebra por Setor
	oQbrSetor	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZL2_COD") /*uBreak*/, {||"Total do Setor: " + _cSetor} /*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.F./*lPageBreak*/)

	If MV_PAR04 == 1//1-Sint�tico 2-Anal�tico
		TRFunction():New(oReport:Section(1):Cell("QTD_PRD")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSetor/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	EndIf
	TRFunction():New(oReport:Section(1):Cell("VOLUME")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrSetor/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
ElseIf _nOrdem == 3 //Quebra por Dia
	oQbrDia	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZLD_DTCOLE") /*uBreak*/, {||"Total do Dia: " + _cData}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.F./*lPageBreak*/)

	If MV_PAR04 == 1//1-Sint�tico 2-Anal�tico
		TRFunction():New(oReport:Section(1):Cell("QTD_PRD")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrDia/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
	EndIf
	TRFunction():New(oReport:Section(1):Cell("VOLUME")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrDia/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
EndIf

oQbrFilial	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZL3_FILIAL")/*uBreak*/, {||"Total da Filial: " + _cFilial + ' - '+ FWFilialName(cEmpAnt,_cFilial,1 )}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
If MV_PAR04 == 1//1-Sint�tico 2-Anal�tico
	TRFunction():New(oReport:Section(1):Cell("QTD_PRD")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
EndIf
TRFunction():New(oReport:Section(1):Cell("VOLUME")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
If !(_nOrdem == 3 .Or. MV_PAR04 == 2)//Quebra por dia ou anal�tico
	oReport:Section(1):Cell("ZLD_DTCOLE"):Disable()
EndIf
If MV_PAR04 == 1 //1-Sint�tico 2-Anal�tico
	oReport:Section(1):Cell("ZL3_COD"):Disable()
	oReport:Section(1):Cell("ZL3_DESCRI"):Disable()
EndIf
If MV_PAR04 == 1 .And. _nOrdem <> 2//1-Sint�tico 2-Anal�tico e ordem diferente de Setor
	oReport:Section(1):Cell("ZL2_COD"):Disable()
	oReport:Section(1):Cell("ZL2_DESCRI"):Disable()
EndIf

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
_cTabela := "%" + RetSqlName(_cAux) +" "+ _cAux + " %"
_cFiltro += " AND "+ _cAux +".D_E_L_E_T_ = ' '"
_cFiltro += " AND "+ _cAux +"_LINROT = ZL3.ZL3_COD"
_cFiltro += " AND "+ _cAux +"_SETOR = ZL2.ZL2_COD"
_cFiltro += " AND "+ _cAux +"_FILIAL = ZL3.ZL3_FILIAL"
_cFiltro += " AND "+ _cAux +"_FILIAL "+ GetRngFil( _aSelFil, _cAux, .T.,)
_cFiltro += " AND D3_L_ORIG (+)= "+ _cAux +"_TICKET"
If MV_PAR09 == 1
	_cFiltro += " AND "+ _cAux +"_DTCOLE BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"' "
Else 
	_cFiltro += " AND (CASE WHEN D3_EMISSAO IS NULL THEN "+ _cAux +"_DTCOLE ELSE D3_EMISSAO END) BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"' "
EndIf
//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR01) .Or. Empty(MV_PAR01) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND ZL2.ZL2_COD IN "+ FormatIn( AllTrim(MV_PAR01) , ';' )
EndIf
_cFiltro += " AND "+ _cAux +"_RETIRO = SA2.A2_COD"
_cFiltro += " AND "+ _cAux +"_RETILJ = SA2.A2_LOJA"

//Verifica se foi fornecido o filtro de linha
If !Empty(MV_PAR07)
	_cFiltro += " AND ZL3_COD IN " + FormatIn(MV_PAR07,";")
EndIf

//Considera somente leite Refrigerado
If MV_PAR05 == 1
	_cFiltro += " AND (SA2.A2_L_CLASS <> 'N')"
//Considera somente leite quente
ElseIf MV_PAR05 == 2
	_cFiltro += " AND (SA2.A2_L_CLASS = 'N')"
EndIf
//Totaliza o volume apenas no dono do taque
If MV_PAR10 == 2
	_cGroup2+= ", A2_COD, A2_LOJA "
Else
	_cGroup2+= ", A2_L_TANQ, A2_L_TANLJ "
EndIf
If _nOrdem == 2 .Or. MV_PAR04 == 2 //Quebra por setor ou anal�tico
	_cCampo += " , ZL2_COD, ZL2_DESCRI"
	_cCampo2 += " , ZL2_COD, ZL2_DESCRI"
	_cGroup += " , ZL2_COD, ZL2_DESCRI "
	_cGroup2 += " , ZL2_COD, ZL2_DESCRI "
	_cOrder += " ZL2_COD, "
EndIf
         
If _nOrdem == 3 .Or. MV_PAR04 == 2 //Quebra por data ou anal�tico
	_cCampo += " , ZLD_DTCOLE "
	If MV_PAR09 == 1
		_cGroup2 += " , "+ _cAux +"_DTCOLE "
		_cCampo2 += " , "+ _cAux +"_DTCOLE ZLD_DTCOLE"
	Else
		_cCampo2 += " , CASE WHEN D3_EMISSAO IS NULL THEN "+ _cAux +"_DTCOLE ELSE D3_EMISSAO END ZLD_DTCOLE"
		_cGroup2 += " , CASE WHEN D3_EMISSAO IS NULL THEN "+ _cAux +"_DTCOLE ELSE D3_EMISSAO END "
	EndIf
	_cGroup += " , ZLD_DTCOLE "
	
	_cOrder += "ZLD_DTCOLE,"
EndIf

If MV_PAR04 == 2//1-Sint�tico 2-Anal�tico
	_cCampo += " , ZL3_COD, ZL3_DESCRI "
	_cCampo2 += " , ZL3_COD, ZL3_DESCRI "
	_cGroup += " , ZL3_COD, ZL3_DESCRI "
	_cGroup2 += " , ZL3_COD, ZL3_DESCRI "
	_cOrder += " ZL3_COD,"
EndIf

_cCampo2 += ", SUM("+ _cAux +"_QTDBOM) VOLUME "

_cCampo += "%"
_cCampo2 += "%"
_cFiltro += "%"
_cGroup += "%"
_cGroup2 += "%"
_cOrder += "%"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
	SELECT ZL3_FILIAL, A2_EST, A2_COD_MUN, CC2_MUN, SUM(VOLUME) VOLUME, COUNT(1) QTD_PRD %exp:_cCampo%
		 FROM (SELECT ZL3_FILIAL, A2_EST, A2_COD_MUN, CC2_MUN, 1 QTD_PRD %exp:_cCampo2%
		FROM %table:SA2% SA2, %table:ZL3% ZL3, %table:ZL2% ZL2, %table:CC2% CC2, %table:SD3% SD3, %exp:_cTabela%
		WHERE SA2.D_E_L_E_T_ = ' '
		AND CC2.D_E_L_E_T_ = ' '
		AND ZL3.D_E_L_E_T_ = ' '
		AND ZL2.D_E_L_E_T_ = ' '
		AND SD3.D_E_L_E_T_ (+) = ' '
		AND SA2.A2_EST = CC2.CC2_EST
		AND SA2.A2_COD_MUN = CC2.CC2_CODMUN
		AND ZL3.ZL3_FILIAL = ZL2.ZL2_FILIAL
		AND D3_FILIAL (+) = ZL2_FILIAL
		AND D3_ESTORNO (+) = ' '
		AND SA2.A2_FILIAL = %xFilial:SA2%
		AND CC2.CC2_FILIAL = %xFilial:CC2%
		%exp:_cFiltro%
		GROUP BY ZL3_FILIAL, A2_EST,A2_COD_MUN,CC2_MUN %exp:_cGroup2%)
	GROUP BY ZL3_FILIAL, A2_EST,A2_COD_MUN,CC2_MUN %exp:_cGroup%
	ORDER BY ZL3_FILIAL, %exp:_cOrder% A2_EST,A2_COD_MUN
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
	_cFilial := (_cAlias)->ZL3_FILIAL
	If _nOrdem == 3 .Or. MV_PAR04 == 2 //Quebra por data ou anal�tico
		_cData	:= DtoC((_cAlias)->ZLD_DTCOLE)
	EndIf
	If _nOrdem == 2 .Or. MV_PAR04 == 2 //Quebra por setor ou anal�tico
		_cSetor	:= (_cAlias)->ZL2_COD + ' - ' + (_cAlias)->ZL2_DESCRI
	EndIf
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(dbCloseArea())

Return
