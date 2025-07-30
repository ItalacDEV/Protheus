/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 24/06/2019 | Revis�o de fontes. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 29/08/2019 | Corre��o da barra de progresso. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/11/2019 | Ajuste nos campos de hora. Chamado 31136
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT058
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 11/08/2015
===============================================================================================================================
Descri��o---------: Relat�rio de tempo de ve�culos na f�brica
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT058()

Local oReport
Pergunte("RGLT058",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/04/2019
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
Local _aOrdem   := {"Por Produto"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT058","Leite de terceiros - Tempo de ve�culos na f�brica","RGLT058",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Lista o tempo de permanencia na f�brica para o Leite de Terceiros, acordo com os par�metros informados")
oSection := TRSection():New(oReport,"Rela��o Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/,.T./*lTotalInLine*/)
oReport:SetLandscape()//Paisagem
oSection:lForceLineStyle:= .T.
oSection:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"ZZX_FILIAL","ZZX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZZX_CODPRD","ZZX","Prod."/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"X5_DESCRI",/*Tabela*/,"Desc. Prod"/*cTitle*/,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLX_CODIGO","ZLX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLX_STATUS","ZLX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_NREDUZ_T",/*Tabela*/,"Transportadora"/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLX_PLACA","ZLX","Placa"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZZV_FXCAPA","ZZV","Cap."/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_NREDUZ_F",/*Tabela*/,"Fornecedor"/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLX_NRONF","ZLX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ENTRADA",/*Tabela*/,"Entrada"/*cTitle*/,/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"SAIDA",/*Tabela*/,"Sa�da"/*cTitle*/,/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"PERMANENCIA",/*Tabela*/,"Tempo na F�b."/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"MEDPERM",/*Tabela*/,"M�dia perma."/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{||bBlock}*/,"RIGHT"/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/04/2019
===============================================================================================================================
Descri��o---------: Relacao de movimentos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro		:= "%"
Local _cOrder		:= "%"
Local _cAlias		:= ""
Local _aSelFil		:= {}
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-Agrupa por filial 2-Agrupa tamb�m por Setor
Local _cFilial		:= ""
Local _cProd		:= ""
Local _nCountRec	:= 0

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR01 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZLX")
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
// Difine C�lulas que n�o ser�o impressas
//==========================================================================
oReport:Section(1):Cell("ENTRADA"):SetBlock({||DTOC((_cAlias)->ZLX_DATAEN)+ ' - ' + (_cAlias)->ZLX_HRENTR})
//Necess�rio incluir os : porque o g�nio que criou a rotina n�o conseguiu seguir um padr�o. Tratar no futuro.
oReport:Section(1):Cell("SAIDA"):SetBlock({||DTOC((_cAlias)->ZLX_DTSAID)+ ' - ' + (_cAlias)->ZLX_HRSAID})
oReport:Section(1):Cell("MEDPERM"):SetBlock({||(_cAlias)->PERMANENCIA})

//================================================================================
//| Configura��o das quebras do relat�rio                                        |
//================================================================================
oQbrPrd	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZZX_CODPRD")/*uBreak*/, {||"Total do Produto: " + _cProd +;
 Space(120) + "Total Perman�ncia"+Space(5)+"M�dia Perman�ncia"}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)

oTotQtd:= TRFunction():New(oReport:Section(1):Cell("ZZX_FILIAL")/*oCell*/,"QTD"/*cName*/,"COUNT"/*cFunction*/,oQbrPrd/*oBreak*/,"Viagens"/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
oTotH:= TRFunction():New(oReport:Section(1):Cell("PERMANENCIA")/*oCell*/,"TOTAL"/*cName*/,"TIMESUM"/*cFunction*/,oQbrPrd/*oBreak*/,"Total de Perman�ncia"/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("MEDPERM")/*oCell*/,"MEDIA"/*cName*/,"ONPRINT"/*cFunction*/,oQbrPrd/*oBreak*/,"Media de Perman�ncia"/*cTitle*/,/*cPicture*/,{||;
StrZero(Int(Min2Hrs(Hrs2Min(oTotH:GetValue())/oTotQtd:GetValue())),4) + ":" + StrZero(Round(((Min2Hrs(Hrs2Min(oTotH:GetValue())/oTotQtd:GetValue())) - Int(Min2Hrs(Hrs2Min(oTotH:GetValue())/oTotQtd:GetValue()))) * 100,0),2);
}/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

oQbrFilial	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZZX_FILIAL")/*uBreak*/, {||"Total da Filial: " + _cFilial + ' - '+ FWFilialName(cEmpAnt,_cFilial,1 )+;
 Space(135) + "Total Perman�ncia"+Space(5)+"M�dia Perman�ncia"}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
oTotFQtd:=TRFunction():New(oReport:Section(1):Cell("ZZX_FILIAL")/*oCell*/,"QTD"/*cName*/,"COUNT"/*cFunction*/,oQbrFilial/*oBreak*/,"Viagens"/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
oTotFH:= TRFunction():New(oReport:Section(1):Cell("PERMANENCIA")/*oCell*/,"TOTAL"/*cName*/,"TIMESUM"/*cFunction*/,oQbrFilial/*oBreak*/,"Total de Perman�ncia"/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("MEDPERM")/*oCell*/,"MEDIA"/*cName*/,"ONPRINT"/*cFunction*/,oQbrFilial/*oBreak*/,"Media de Perman�ncia"/*cTitle*/,/*cPicture*/,{||;
StrZero(Int(Min2Hrs(Hrs2Min(oTotFH:GetValue())/oTotFQtd:GetValue())),4) + ":" + StrZero(Round(((Min2Hrs(Hrs2Min(oTotFH:GetValue())/oTotFQtd:GetValue())) - Int(Min2Hrs(Hrs2Min(oTotFH:GetValue())/oTotFQtd:GetValue()))) * 100,0),2);
}/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
_cFiltro += " AND ZLX_FILIAL "+ GetRngFil( _aSelFil, "ZLX", .T.,)

//Verifica se foi fornecido o filtro de C�digo do produto
If !Empty(MV_PAR19)
	_cFiltro += " AND ZZX.ZZX_CODPRD IN " + FormatIn(MV_PAR19,";")
EndIf

//Verifica se foi fornecido o filtro de Placa
If !Empty(MV_PAR21)
	_cFiltro += " AND ZLX.ZLX_PLACA IN " + FormatIn(MV_PAR21,";")
EndIf

//Verifica se foi fornecido o filtro de Faixa de Capacidade
If !Empty(MV_PAR10)
	_cFiltro += " AND ZZV.ZZV_FXCAPA IN " + FormatIn(MV_PAR10,";")
EndIf

//Verifica se foi fornecido o filtro de Status
If !Empty(MV_PAR17)
	_cFiltro += " AND ZLX.ZLX_STATUS IN " + FormatIn(MV_PAR17,";")
EndIf

If !Empty(MV_PAR20) .And. MV_PAR20 < 4 
	_cFiltro += " AND ZLX.ZLX_TIPOLT = "
	If MV_PAR20 == 1 
		_cFiltro += " 'F' "
	ElseIf MV_PAR20 == 2
		_cFiltro += " 'T' "
	ElseIf MV_PAR20 == 3
		_cFiltro += " 'P' "
	EndIf
EndIf

If MV_PAR18 == 1      // Ordem de data/hora entrada
	_cOrder += " ZLX.ZLX_DATAEN, ZLX.ZLX_HRENTR"
ElseIf MV_PAR18 == 2 // Maior tempo na f�brica
	_cOrder += " PERMANENCIA DESC"
ElseIf MV_PAR18 == 3 // Menor tempo na f�brica
	_cOrder += " PERMANENCIA"
EndIf

_cFiltro += "%"
_cOrder += "%"
//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
	SELECT ZZX.ZZX_FILIAL, ZZX.ZZX_CODPRD, SX5.X5_DESCRI DESCRI, ZLX.ZLX_CODIGO, ZLX.ZLX_STATUS, SA2T.A2_NREDUZ A2_NREDUZ_T, ZLX.ZLX_PLACA, ZZV.ZZV_FXCAPA,
	       SA2F.A2_NREDUZ A2_NREDUZ_F, ZLX.ZLX_NRONF, ZLX.ZLX_DATAEN, ZLX.ZLX_HRENTR, ZLX.ZLX_DTSAID,
	       ZLX.ZLX_HRSAID, LPAD(TRUNC((TO_DATE(ZLX.ZLX_DTSAID || ZLX.ZLX_HRSAID,'YYYYMMDDhh24:mi') -
	       TO_DATE(ZLX.ZLX_DATAEN || ZLX.ZLX_HRENTR,'YYYYMMDDhh24:mi')) * 24),4,'0') || ':' ||
	       LPAD(ROUND(MOD((TO_DATE(ZLX.ZLX_DTSAID || ZLX.ZLX_HRSAID,'YYYYMMDDhh24:mi') - TO_DATE(ZLX.ZLX_DATAEN || ZLX.ZLX_HRENTR,
	       'YYYYMMDDhh24:mi')) * 24,1) * 60,2),2,'0') PERMANENCIA
	  FROM %table:ZLX% ZLX, %table:SA2% SA2T, %table:SA2% SA2F, %table:ZZX% ZZX, %table:ZZV% ZZV, %table:SX5% SX5
	 WHERE ZLX.D_E_L_E_T_ = ' '
	   AND SA2T.D_E_L_E_T_ = ' '
	   AND SA2F.D_E_L_E_T_ = ' '
	   AND ZZX.D_E_L_E_T_ = ' '
	   AND ZZV.D_E_L_E_T_ = ' '
	   AND SX5.D_E_L_E_T_ = ' '
	   AND ZLX.ZLX_FILIAL = ZZV.ZZV_FILIAL
	   AND ZZV.ZZV_FILIAL = ZZX.ZZX_FILIAL
	   AND ZLX.ZLX_FORNEC = SA2F.A2_COD
	   AND ZLX.ZLX_LJFORN = SA2F.A2_LOJA
	   AND ZLX.ZLX_TRANSP = SA2T.A2_COD
	   AND ZLX.ZLX_LJTRAN = SA2T.A2_LOJA
	   AND ZZX.ZZX_CODIGO = ZLX.ZLX_CODANA
	   AND ZZX.ZZX_PLACA = ZZV.ZZV_PLACA
	   AND ZZV.ZZV_TRANSP = ZLX.ZLX_TRANSP
	   AND ZZV.ZZV_LJTRAN = ZLX.ZLX_LJTRAN
	   AND SX5.X5_TABELA = 'Z7'
	   AND ZZX.ZZX_CODPRD = SX5.X5_CHAVE
   	   %exp:_cFiltro%
	   AND ZLX.ZLX_DTENTR BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR12%
	   AND ZLX.ZLX_DATAEN BETWEEN %exp:MV_PAR13% AND %exp:MV_PAR14%
	   AND ZLX.ZLX_DTSAID BETWEEN %exp:MV_PAR15% AND %exp:MV_PAR16%
	   AND ZLX.ZLX_FORNEC BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR04%
	   AND ZLX.ZLX_LJFORN BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR05%
	   AND ZLX.ZLX_TRANSP BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR08%
	   AND ZLX.ZLX_LJTRAN BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR09%
	 ORDER BY ZZX.ZZX_CODPRD, %exp:_cOrder%
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
//Inibindo celulas, utilizadas apenas para totalizadores
//=======================================================================
oReport:Section(1):Cell("MEDPERM"):Hide()
oReport:Section(1):Cell("MEDPERM"):HideHeader()

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
  	_cFilial := (_cAlias)->ZZX_FILIAL
	_cProd := (_cAlias)->ZZX_CODPRD + ' - ' + (_cAlias)->DESCRI
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(dbCloseArea())

Return