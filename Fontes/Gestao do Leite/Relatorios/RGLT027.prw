/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 13/08/2020 | Migra��o para tReport. Chamado 33667
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 01/09/2020 | Limitada as colunas impressas. Chamado 33998
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 12/12/2021 | Ajustes necess�rios pela reformula��o da tela do MIX. Chamado 38596
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT027
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 30/07/2020
===============================================================================================================================
Descri��o---------: Relat�rio Composi��o de Pre�os do Mix - Chamado 33479 - Executado � partir do Mix (AGLT020)
===============================================================================================================================
Parametros--------: _cTabela -> Tabela tempor�ria gerada no Mix
					_aStruct -> Estrutura dos campos que ser�o impressos
					_cTitulo -> T�tulo do relat�rio de acordo com a tela do Mix posicionada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT027(_cTabela, _aStruct,_cTitulo)

Local _aArea := GetArea()
Local oReport

//Inferface de Impress�o
oReport := ReportDef(_cTabela, _aStruct,_cTitulo)
oReport:PrintDialog()
RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 30/07/2020
===============================================================================================================================
Descri��o---------: Processa a montagem do relat�rio
===============================================================================================================================
Parametros--------: _cTabela -> Tabela tempor�ria gerada no Mix
					_aStruct -> Estrutura dos campos que ser�o impressos
					_cTitulo -> T�tulo do relat�rio de acordo com a tela do Mix posicionada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef(_cTabela, _aStruct,_cTitulo)

Local oReport
Local oSection
Local _aOrdem   := {}
Local _nX		:= 0

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT027",_cTitulo,"RGLT027",;
{|oReport| ReportPrint(oReport,_aOrdem,_cTabela, _aStruct,_cTitulo)},"Imprime a tela atual do Mix visualizado.")
oSection := TRSection():New(oReport,"Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)
oReport:SetLandscape()//Paisagem
oReport:lParamPage := .F.//Desabilita impress�o de p�gina de par�metros
//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
For _nX:=1 To Len(_aStruct)//Nome do campo,Tipo,Tamanho,Decimal,Picture,T�tulo,Largura da coluna
  TRCell():New(oSection,_aStruct[_nX][1],_cTabela/*Table*/,_aStruct[_nX][6]/*cTitle*/,_aStruct[_nX][5]/*Picture*/,_aStruct[_nX][3]/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,IIf(_aStruct[_nX][2]=='N',"RIGHT","LEFT")/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Next _nX

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 30/07/2020
===============================================================================================================================
Descri��o---------: Processa a impress�o do relat�rio
===============================================================================================================================
Parametros--------: _cTabela -> Tabela tempor�ria gerada no Mix
					_aStruct -> Estrutura dos campos que ser�o impressos
					_cTitulo -> T�tulo do relat�rio de acordo com a tela do Mix posicionada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem,_cTabela, _aStruct,_cTitulo)

Local _cAlias	:= ""
Local _nCountRec:= 0
Local _cTab		:= '%'+_cTabela+'%'
Local _nX		:= 0

//==========================================================================
// Transforma parametros Range em expressao SQL                             	
//==========================================================================
MakeSqlExpr(oReport:uParam)

//==========================================================================
// Difine C�lulas que n�o ser�o impressas
//==========================================================================
If oReport:nDevice == 1 .Or. oReport:nDevice == 2 //limito em 20 colunas a serem impressas em disco e direto na impressora
	For _nX:= 19 To Len(_aStruct)
	   	oReport:Section(1):Cell(_aStruct[_nX][1]):Disable()
	Next _nX
EndIf
//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
	SELECT * FROM %exp:_cTab%
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

Return
