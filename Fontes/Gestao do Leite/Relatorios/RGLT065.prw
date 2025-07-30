/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 30/08/2019 | Corre��o da barra de progresso. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 27/09/2019 | Revis�o de fontes. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 06/12/2019 | Inclus�o do c�digo do produto. Chamado 31392
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa--------: RGLT065
Autor-----------: Alex Wallauer
Data da Criacao-: 12/03/2018
===============================================================================================================================
Descri��o-------: Resumo de Viagens 2� Percurso - Chamado 22209
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function RGLT065()

Local oReport
Pergunte("RGLT065",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Alex Wallauer
Data da Criacao---: 12/03/2018
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
Local oSection1
Local _aOrdem   := {"Por data"}

oReport := TReport():New("RGLT065","Resumo  de Viagens 2� percurso","RGLT065",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Resumo  de Viagens 2� percurso")
oSection1 := TRSection():New(oReport,"Resumo Viagens 2� Percurso"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Totais Gerais"/*uTotalText*/)
oSection1:SetTotalInLine(.F.)
oReport:SetLandscape()//Paisagem

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection1,"ZLX_DTENTR","ZLX","Data"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"FORNECE",/*cAlias*/,"Proced�ncia"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"TRANSP",/*cAlias*/,"Transportadora"/*cTitle*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_PLACA","ZLX","Placa"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"PRODUTO",/*cAlias*/,"Produto"/*cTitle*/,/*Picture*/,25/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZZV_CAPACI","ZLX","Capacidade"/*cTitle*/,"@E 9,999,999,999.99"/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_VOLREC","ZLX","Volume"/*cTitle*/,"@E 9,999,999,999.99"/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"KMPADRAO",/*cAlias*/,"Km Padr�o"/*cTitle*/,"@E 9,999,999,999"/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"TARIFAKM",/*cAlias*/,"Tarifa Km"/*cTitle*/,"@E 9,999,999,999.99"/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"TARIFAFIXA",/*cAlias*/,"Tarifa Fixa"/*cTitle*/,"@E 9,999,999,999.99"/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_VLRFRT","ZLX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_ICMSFR","ZLX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"ZLX_PEDAGI","ZLX",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"TOTALFRETE",/*cAlias*/,"Total Frete"/*cTitle*/,"@E 9,999,999,999.99"/*Picture*/,16/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,"CUSTOLITRO",/*cAlias*/,"Custo/Litro"/*cTitle*/,"@E 9,999,999,999.9999"/*Picture*/,18/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

oSection2 := TRSection():New(oReport,"S�ntese dos Ve�culos Por Proced�ncia"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,/*uTotalText*/)
oSection2:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection2,"FORNECE",/*cAlias*/,"Proced�ncia"/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"TRANSP",/*cAlias*/,"Transportadora"/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"TOTAIS",/*cAlias*/,""/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"ZZV_FXCAPA",/*cAlias*/,"Capacidade"/*cTitle*/,/*Picture*/,40/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"QUANTIDADE",/*cAlias*/,"Quantidade"/*cTitle*/,"@E 999,999"/*Picture*/,07/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection2,"CUSTOLITRO",/*cAlias*/,"Custo/Litro"/*cTitle*/,"@E 999,999.9999"/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return(oReport)

/*
===============================================================================================================================
Programa--------: RGLT002SEL
Autor-----------: Alex Wallauer
Data da Criacao-: 12/03/2018
===============================================================================================================================
Descri��o-------: Fun��o para consulta e prepara��o dos dados do relat�rio
===============================================================================================================================
Parametros------: oReport = Objeto do relat�rio.
===============================================================================================================================
Retorno---------: _aRet - Dados do relat�rio
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro		:= "%"
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-Agrupa por filial 2-Agrupa tamb�m por Setor
Local _cAlias		:= ""
Local _nCountRec	:= 0
Local _nI			:= 0

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
TRFunction():New(oReport:Section(1):Cell("ZZV_CAPACI")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
_oTotCap:=TRFunction():New(oReport:Section(1):Cell("ZLX_VOLREC")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("KMPADRAO")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("TARIFAKM")/*oCell*/,/*cName*/,"AVERAGE"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,{|| oReport:Section(1):Cell("TARIFAKM"):GetValue() <> 0 }/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("TARIFAFIXA")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("ZLX_VLRFRT")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
_oTotIcm:=TRFunction():New(oReport:Section(1):Cell("ZLX_ICMSFR")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("ZLX_PEDAGI")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
_oTotFrt:=TRFunction():New(oReport:Section(1):Cell("TOTALFRETE")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("CUSTOLITRO")/*oCell*/,/*cName*/,"ONPRINT"/*cFunction*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| (_oTotFrt:GetValue()-_oTotIcm:GetValue())/_oTotCap:GetValue() }/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
//          TRFunction():New( oReport:Section(1):Cell( "TARIFAKM"    ) , NIL , "AVERAGE" ,/*oBreak*/,    ,'@E 9999,999,999.99',NIL,.T.,.F.,.F.,/*oParent*/,{|| oReport:Section(1):Cell("TARIFAKM"):GetValue() <> 0 })/*bCondition*/ //,lDisable,bCanPrint )//

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
If MV_PAR03 < 4
	_cFiltro += " AND ZLX.ZLX_TIPOLT = '"+ IIF( MV_PAR03 == 1 , 'F' , IIF( MV_PAR03 == 2 , 'T' , 'P' ) ) +"' "
EndIf
If !Empty( MV_PAR04 )
	_cFiltro += " AND ZZX.ZZX_CODPRD IN "+ FormatIn( AllTrim(MV_PAR04) , ';' )
EndIf
If !Empty( MV_PAR13 )
	_cFiltro += " AND ZLX.ZLX_PLACA  IN "+ FormatIn( AllTrim( MV_PAR13 ) , ';' )
EndIf
If !Empty( MV_PAR14 )
	_cFiltro += " AND ZZV.ZZV_FXCAPA IN "+ FormatIn( AllTrim( MV_PAR14 ) , ';' )
EndIf
If !Empty( MV_PAR19 )
	_cFiltro += " AND ZLX.ZLX_STATUS IN "+ FormatIn( AllTrim( MV_PAR19 ) , ';' )
EndIf
_cFiltro += "%"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
	SELECT ZLX.ZLX_DTENTR, ZLX.ZLX_FORNEC, ZLX.ZLX_LJFORN, ZLX.ZLX_TRANSP, ZLX.ZLX_LJTRAN, ZLX.ZLX_VLRFRT, ZZX.ZZX_CODPRD ||'-'||SX5.X5_DESCRI PRODUTO,
	       ZLX.ZLX_ICMSFR, ZLX.ZLX_PEDAGI, ZLX.ZLX_TVLFRT TOTALFRETE, ZLX.ZLX_NRONF, ZLX.ZLX_PLACA, ZLX.ZLX_VOLREC, ZZV.ZZV_FXCAPA, ZZV.ZZV_CAPACI
	  FROM %Table:ZLX% ZLX, %Table:ZZX% ZZX, %Table:ZZV% ZZV, %Table:SX5% SX5
	 WHERE ZLX.D_E_L_E_T_ = ' '
	   AND ZZX.D_E_L_E_T_ = ' '
	   AND ZZV.D_E_L_E_T_ = ' '
	   AND SX5.D_E_L_E_T_ = ' '
	   AND ZLX.ZLX_FILIAL = %xFilial:ZLX%
	   AND ZZX.ZZX_FILIAL = %xFilial:ZZX%
	   AND ZZV.ZZV_FILIAL = %xFilial:ZZV%
	   AND SX5.X5_FILIAL = %xFilial:SX5%
	   AND ZLX.ZLX_FILIAL = ZZX.ZZX_FILIAL
	   AND ZZX.ZZX_FILIAL = ZZV.ZZV_FILIAL
	   AND ZZX.ZZX_CODIGO = ZLX.ZLX_CODANA
	   AND ZZX.ZZX_PLACA = ZZV.ZZV_PLACA
	   AND ZZX.ZZX_TRANSP = ZZV.ZZV_TRANSP
	   AND ZZX.ZZX_LJTRAN = ZZV.ZZV_LJTRAN
   	   AND SX5.X5_CHAVE = ZZX.ZZX_CODPRD
	   AND SX5.X5_TABELA = 'Z7'
	   %exp:_cFiltro%
	   AND ZLX.ZLX_DTENTR BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
	   AND ZLX.ZLX_FORNEC BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
	   AND ZLX.ZLX_LJFORN BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR08%
	   AND ZLX.ZLX_TRANSP BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR11%
	   AND ZLX.ZLX_LJTRAN BETWEEN %exp:MV_PAR10% AND %exp:MV_PAR12%
	   AND ZLX.ZLX_NRONF BETWEEN %exp:MV_PAR15% AND %exp:MV_PAR16%
	   AND ZLX.ZLX_CODIGO BETWEEN %exp:MV_PAR17% AND %exp:MV_PAR18%
	 ORDER BY ZLX.ZLX_DTENTR, ZLX.ZLX_FORNEC, ZLX.ZLX_TRANSP
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
ZZT->( DBSetOrder(1) )
ZZU->( DBSetOrder(1) )
nTam:=TamSX3('ZZU_CAPACI')[01] 
_aSintese:={}

While !oReport:Cancel() .And. (_cAlias)->(!EOF())
   oReport:IncMeter()   
   
   oReport:Section(1):Cell("ZZV_CAPACI"):SetValue(VAL((_cAlias)->ZZV_CAPACI))
   oReport:Section(1):Cell("FORNECE"):SetValue(Posicione("SA2",1,xFilial("SA2")+(_cAlias)->ZLX_FORNEC + (_cAlias)->ZLX_LJFORN ,"A2_NREDUZ"))
   oReport:Section(1):Cell("TRANSP" ):SetValue(Posicione("SA2",1,xFilial("SA2")+(_cAlias)->ZLX_TRANSP + (_cAlias)->ZLX_LJTRAN ,"A2_NREDUZ"))
   oReport:Section(1):Cell("CUSTOLITRO"):SetValue( ( ((_cAlias)->TOTALFRETE-(_cAlias)->ZLX_ICMSFR) / (_cAlias)->ZLX_VOLREC ))

   IF ZZT->( DBSeek( xFilial("ZZT") + (_cAlias)->ZLX_TRANSP + (_cAlias)->ZLX_LJTRAN + (_cAlias)->ZZV_FXCAPA ) )
		
	  IF ZZU->( DBSeek( xFilial("ZZU") + (_cAlias)->ZLX_TRANSP + (_cAlias)->ZLX_LJTRAN + PadR( (_cAlias)->ZZV_FXCAPA , nTam ) + (_cAlias)->ZLX_FORNEC + (_cAlias)->ZLX_LJFORN ) )

         oReport:Section(1):Cell("KMPADRAO"  ):SetValue(ZZU->ZZU_KMFORN)
         oReport:Section(1):Cell("TARIFAKM"  ):SetValue(ZZU->ZZU_VLRKM)
         oReport:Section(1):Cell("TARIFAFIXA"):SetValue(ZZU->ZZU_VLRCOM)

      ENDIF	

   ENDIF	

   _cChave:=oReport:Section(1):Cell("FORNECE"):GetValue()+oReport:Section(1):Cell("TRANSP" ):GetValue()+(_cAlias)->ZZV_FXCAPA
   IF (_nI:= ASCAN(_aSintese,{|S| S[1]+S[2]+S[3] == _cChave } )) = 0

      AADD(_aSintese,{oReport:Section(1):Cell("FORNECE"):GetValue(),;//PROCEDENCIA    1
                      oReport:Section(1):Cell("TRANSP" ):GetValue(),;//TRANSPORTADORA 2
                      (_cAlias)->ZZV_FXCAPA, ;//CAPCIDADE  3
                      1,;                     //QUANTIDADE 4
                      ((_cAlias)->TOTALFRETE-(_cAlias)->ZLX_ICMSFR), ;//para calcular Custo/Litro 5
                      (_cAlias)->ZLX_VOLREC  ;//para calcular Custo/Litro 6
                       })
   ELSE

      _aSintese[_nI,4]++
      _aSintese[_nI,5]+=( (_cAlias)->TOTALFRETE-(_cAlias)->ZLX_ICMSFR )
      _aSintese[_nI,6]+=(_cAlias)->ZLX_VOLREC

   ENDIF

    oReport:Section(1):Printline()
      
   (_cAlias)->( DBSkip() )
   
EndDo

oReport:Section(1):Finish()

//Impressao S�ntese dos Ve�culos Por Proced�ncia
oReport:EndPage()
oReport:SetTitle("S�ntese dos Ve�culos Por Proced�ncia") //"V A R I A C A O   DE   U S O   E   C O N S U M O"
oReport:SetMeter(Len(_aSintese))
oReport:Section(2):Init()

_aSintese := aSort(_aSintese,,, { | x,y | x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })

_cTitTotPr:="XXXXXXXXXXXXXXXX"

_cQbgForn :=""
_nQtdForn :=0
_nCuFForn :=0
_nCuLForn :=0

_cQbgTrans:=""
_nQtdTrans:=0
_nCuFTrans:=0
_nCuLTrans:=0

_nConTrans:=0

For _nI:=1 To Len(_aSintese)

	oReport:IncMeter()
	IF EMPTY(_cQbgTrans)
	   _cQbgTrans:=_aSintese[_nI,1]+_aSintese[_nI,2]
       _cQbgForn :=_aSintese[_nI,1]
	ENDIF

    Quebras(oReport,_nI,1)//Imprimi o total das quebras

    _nQtdTrans+=_aSintese[_nI,4]
    _nCuFTrans+=_aSintese[_nI,5]
    _nCuLTrans+=_aSintese[_nI,6]

    _nQtdForn +=_aSintese[_nI,4]
    _nCuFForn +=_aSintese[_nI,5]
    _nCuLForn +=_aSintese[_nI,6]
    
    IF !(_cTitTotPr == _aSintese[_nI,1])
	   oReport:Section(2):Cell("FORNECE"):SetValue(_aSintese[_nI,1])
       _cTitTotPr:=_aSintese[_nI,1]
	ELSE
	   oReport:Section(2):Cell("FORNECE"):SetValue("")
	ENDIF
    oReport:Section(2):Cell("TOTAIS"    ):SetValue("")
	oReport:Section(2):Cell("TRANSP"    ):SetValue(_aSintese[_nI,2])
	oReport:Section(2):Cell("ZZV_FXCAPA"):SetValue(_aSintese[_nI,3])
	oReport:Section(2):Cell("QUANTIDADE"):SetValue(_aSintese[_nI,4])
	oReport:Section(2):Cell("CUSTOLITRO"):SetValue( (_aSintese[_nI,5]/_aSintese[_nI,6]) )
  	oReport:Section(2):PrintLine()
   _nConTrans++
   
Next

_cQbgForn :="FINAL"
_cQbgTrans:="FINAL"

If Len(_aSintese) > 0
	Quebras(oReport,(_nI-1),0)//Imprimi o total das quebras
EndIf

oReport:Section(2):Finish()

(_cAlias)->( DBCloseArea() )

Return

/*
===============================================================================================================================
Programa--------: AjustaSX1
Autor-----------: Alex Wallauer
Data da Criacao-: 30/07/2018
===============================================================================================================================
Descri��o-------: Rotina para ajustar o grupo de perguntas no SX1
===============================================================================================================================
Parametros------: oReport,_nI, L
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function Quebras(oReport,_nI,L)

//Quebra do transportador
If !(_cQbgTrans == _aSintese[_nI,1]+_aSintese[_nI,2])
	
	If  _nConTrans > 1
		oReport:Section(2):Cell("FORNECE"   ):SetValue("")
		oReport:Section(2):Cell("TRANSP"    ):SetValue("")
		oReport:Section(2):Cell("TOTAIS"    ):SetValue("Total "+_aSintese[(_nI-L),2])
		oReport:Section(2):Cell("ZZV_FXCAPA"):SetValue("")
		oReport:Section(2):Cell("QUANTIDADE"):SetValue(_nQtdTrans)
		oReport:Section(2):Cell("CUSTOLITRO"):SetValue(_nCuFTrans/_nCuLTrans)
		oReport:Section(2):PrintLine()
	EndIf
	
	_cQbgTrans:=_aSintese[_nI,1]+_aSintese[_nI,2]
	_nQtdTrans:=0
	_nCuFTrans:=0
	_nCuLTrans:=0
	_nConTrans:=0
EndIf

//Quebra do Fornecedor (Proced�ncia)
If !(_cQbgForn == _aSintese[_nI,1])
	
	oReport:Section(2):Cell("FORNECE"   ):SetValue("Total "+_aSintese[(_nI-L),1])
	oReport:Section(2):Cell("TOTAIS"    ):SetValue("")
	oReport:Section(2):Cell("TRANSP"    ):SetValue("")
	oReport:Section(2):Cell("ZZV_FXCAPA"):SetValue("")
	oReport:Section(2):Cell("QUANTIDADE"):SetValue(_nQtdForn)
	oReport:Section(2):Cell("CUSTOLITRO"):SetValue(_nCuFForn/_nCuLForn)
	oReport:Section(2):PrintLine()
	oReport:FatLine() //Impressao de Linha Simples
	
	_cQbgForn :=_aSintese[_nI,1]
	_nQtdForn :=0
	_nCuFForn :=0
	_nCuLForn :=0
	
EndIf

Return