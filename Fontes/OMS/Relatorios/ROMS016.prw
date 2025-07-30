/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 04/04/2019 | Recria��o de p�gina de par�metros - Chamado 28783      
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 28/05/2019 | Ajuste de p�gina de parametros - Chamado 29387
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  	  | 17/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: ROMS016
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Imprime os dados das notas fiscais de saida e dos movimentos internos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS016()

Private _cPerg			:= "ROMS016"

Private _oFont10		:= TFont():New( "Courier New"	,, 08 ,, .F. ,,,, .F. , .F. )
Private _oFont12		:= TFont():New( "Courier New"	,, 10 ,, .F. ,,,, .F. , .F. )
Private _oFont14		:= TFont():New( "Courier New"	,, 12 ,, .F. ,,,, .F. , .F. )
Private _oFont14b		:= TFont():New( "Courier New"	,, 12 ,, .T. ,,,, .F. , .F. )
Private _oFont16b		:= TFont():New( "Helvetica"		,, 14 ,, .T. ,,,, .F. , .F. )

Private _oPrint			:= Nil
Private _oBrush      	:= TBrush():New( ,CLR_LIGHTGRAY)

Private _nPagina     	:= 1
Private _nLinha      	:= 0100
Private _nLinIn			:= 0100
Private _nColInic    	:= 0030
Private _nColFinal   	:= 3360
Private _nqbrPagina  	:= 2200
Private _nLinInBox		:= 0
Private _nSaltoLinha 	:= 50

If Pergunte( _cPerg )
    
	_oPrint:= TMSPrinter():New("RELATORIO MOVIMENTACAO")
	_oPrint:SetPaperSize(9)		// Seta para papel A4
	
	//================================================================================
	// Relat�rio Analitico
	//================================================================================
	If MV_PAR01 == 2
	
		_oPrint:SetLandscape()	// Paisagem
		_nqbrPagina  := 2200
	
	//================================================================================
	// Relat�rio Sint�tico
	//================================================================================	
	Else
	
		_oPrint:SetPortrait()	// Retrato
		_nqbrPagina  := 3300
		
	EndIf
	
	Processa( {|| ROMS016EXE() } )
	
	_oPrint:EndPage()	// Finaliza a Pagina.
	_oPrint:Preview()	// Visualiza antes de Imprimir.

Else

	u_itmsg(  'Processamento cancelado pelo usu�rio!' , 'Aten��o!' ,, 1 )
	Return()

EndIf

Return()

/*
===============================================================================================================================
Programa----------: ROMS016CAB
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Imprime os dados do cabe�alho do relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS016CAB( _lImpAux )

Local _cRaizServer	:= If(issrvunix(), "/", "\")
Local _nColuna		:= 0
Local _cTitulo		:= "RELAT�RIO DE MOVIMENTA��O DE "+ IIF(MV_PAR12 == 1,"SA�DA","ENTRADA") + IIF(MV_PAR01 == 1," - SINT�TICO"," - ANAL�TICO") +" - Per�odo de: "+ DtoC(MV_PAR04) +" At� "+ DtoC(MV_PAR05)

If MV_PAR01 == 1
	_nColuna := 2360
Else
	_nColuna := _nColFinal
EndIf

_nLinha := 0100

_oPrint:SayBitmap( _nLinha , _nColInic , _cRaizServer + "system/lgrl01.bmp" , 250 , 100 )

_oPrint:Say( _nLinha		, _nColInic + (_nColuna - 660) , "P�GINA: "+ Str(_nPagina,4)			, _oFont12 )
_oPrint:Say( _nLinha + 50	, _nColInic + (_nColuna - 660) , "DATA DE EMISS�O: "+ DtoC(DATE())	, _oFont12 )

If _lImpAux
	_oPrint:Say( _nLinha - 50		, _nColInic + (_nColuna - 660) , "FONTE: ROMS016"														, _oFont12 )
	_oPrint:Say( _nLinha + 100	, _nColInic + (_nColuna - 660) , "EMPRESA: "+ AllTrim(SM0->M0_NOME) + '/' + AllTrim(SM0->M0_FILIAL)	, _oFont12 )
EndIf

_nLinha += ( _nSaltoLinha * 3 )

_oPrint:Say( _nLinha , _nColuna / 2 , _cTitulo , _oFont16b , _nColuna ,,, 2 )

_nLinha += ( _nSaltoLinha * 2 )

_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColuna )

Return()

/*
===============================================================================================================================
Programa----------: ROMS016PRD
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Imprime os dados do cabe�alho de produtos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS016PRD( cCodProdut , cDesProdut )

_nLinha += ( _nSaltoLinha * 3 )

_oPrint:FillRect( { (_nLinha+3) , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - 1270 } , _oBrush )

_oPrint:Box( _nLinha , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - 1270 )

_oPrint:Say( _nLinha , _nColInic + 25	, "Produto:"							, _oFont14b )
_oPrint:Say( _nLinha , _nColInic + 230	, AllTrim(cCodProdut) +'-'+ cDesProdut	, _oFont14b )

_nLinha += ( _nSaltoLinha * 3 )

Return()

/*
===============================================================================================================================
Programa----------: ROMS016SAI
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Imprime os dados do cabe�alho de Movimenta��o Interna
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS016SAI( Tipo , cGrupo , cSegUM )

Local _cTitulo		:= ""
Local _cContrTama	:= 0 //Controla o posicionamento das colunas de acordo com o relatorio analitico ou sintetico
Local _lQueijoPC	:= .F.
Local cTipoMov		:= ""
Local cCliForn		:= ""

//====================================================================================================
// Verifica se o produto � do grupo de produto queijo e se tem a segunda unidade de medidade PC(peca)
//====================================================================================================
If cGrupo == '0006' .And. cSegUM == 'PC' .And. tipo == 1
	_lQueijoPC := .T.
EndIf

//====================================================================================================
// Verifica o tipo do relatorio - Saida
//====================================================================================================
If MV_PAR12 == 1

	cTipoMov := "SAIDA"
	cCliForn := "Cliente"
	
//====================================================================================================
// Verifica o tipo do relatorio - Entrada
//====================================================================================================
Else

	cTipoMov := "ENTRADA"
	cCliForn := "Fornecedor"
	
EndIf

//====================================================================================================
// Relatorio Analitico
//====================================================================================================
If MV_PAR01 == 2

	_cContrTama := 0
	
//====================================================================================================
// Relatorio Sintetico
//====================================================================================================
Else

	_cContrTama := 1270
	
EndIf

If tipo == 1
	_cTitulo := cTipoMov +" POR - NF"
else
	_cTitulo := cTipoMov +" POR - MOVIMENTOS INTERNOS"
EndIf

_oPrint:FillRect( { (_nLinha+3) , _nColInic + 1200 , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama } , _oBrush )

_oPrint:Box( _nLinha , _nColInic + 1200 , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama )

_oPrint:Say( _nLinha , ( ( ( _nColFinal - _cContrTama ) - _nColInic + 1200 ) / 2 ) , _cTitulo , _oFont14b , _nColFinal - _cContrTama ,,, 2 )

_nLinha		+= _nSaltoLinha
_nLinInBox	:= _nLinha

_oPrint:FillRect( { (_nLinha+3) , _nColInic + 1 , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama } , _oBrush )

_oPrint:Say( _nLinha , _nColInic + 25 , "Data" , _oFont14b )

//====================================================================================================
// Relatorio Analitico
//====================================================================================================
If Tipo == 1

	If MV_PAR01 == 2
	
		//====================================================================================================
		// Relatorio de Entradas
		//====================================================================================================
		If MV_PAR12 == 2
		
			_oPrint:Say( _nLinha , _nColInic + 230			, "Tipo"		, _oFont14b )
			_oPrint:Say( _nLinha , _nColInic + 230 + 245	, "Documento"	, _oFont14b )
			_oPrint:Say( _nLinha , _nColInic + 515 + 285	, cCliForn		, _oFont14b )
		
		//====================================================================================================
		// Relatorio de Saidas
		//====================================================================================================
		Else
		
			_oPrint:Say( _nLinha , _nColInic + 230 , "Documento"	, _oFont14b )
			_oPrint:Say( _nLinha , _nColInic + 555 , cCliForn		, _oFont14b )
			
		EndIf
		
	EndIf
	
	_oPrint:Say( _nLinha , ( _nColInic + 2700 ) - _cContrTama + 20 , "Prc.Unit." , _oFont14b )
	
Else

	If MV_PAR01 == 2
		_oPrint:Say( _nLinha , _nColInic + 230 , "Tipo de Movimento" , _oFont14b )
	EndIf
	
	_oPrint:Say( _nLinha , ( _nColInic + 2670 ) - (_cContrTama + 10) , "Custo M�dio" , _oFont14b )
	
EndIf

_oPrint:Say( _nLinha , (_nColInic + 1500) - _cContrTama			, "Qtde.1a.U.M."	, _oFont14b )
_oPrint:Say( _nLinha , (_nColInic + 1815) - _cContrTama			, "1a.U.M"			, _oFont14b )
_oPrint:Say( _nLinha , (_nColInic + 2100) - _cContrTama	   		, "Qtde.2a.U.M."	, _oFont14b )

If _lQueijoPC

	_oPrint:Say( _nLinha , ( _nColInic + 2415 ) - _cContrTama		, "2a"			, _oFont14b )
	_oPrint:Say( _nLinha , ( _nColInic + 2465 ) - _cContrTama + 05	, "Media PC"	, _oFont14b )
	
else

	_oPrint:Say( _nLinha , ( _nColInic + 2415 ) - _cContrTama	, "2a.U.M"		, _oFont14b )
	
EndIf

_oPrint:Say( _nLinha , ( _nColInic + 3060 ) - (_cContrTama + 15), "Valor Total"	, _oFont14b )

Return()

/*
===============================================================================================================================
Programa----------: ROMS016PRT
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Controla o processamento da impress�o dos dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ROMS016PRT( tipo , cdada , cdocumento , _cCliente , nqtde1um , cum1 , nqtde2um , cum2 , nprcUnit , nvlrTotal , cdesMovInt , produto , tpNotaEnt )

Local _cContrTama	:= 0
Local _lQueijoPC		:= .F.

//====================================================================================================
// Verifica se o produto � do grupo de produto queijo e se tem a segunda unidade de medidade PC(peca)
//====================================================================================================
If SubStr( produto , 1 , 4 ) == '0006' .And. cum2 == 'PC' .And. tipo == 1
	_lQueijoPC := .T.
EndIf

//====================================================================================================
// Relatorio Analitico/Sint�tico
//====================================================================================================
If MV_PAR01 == 2
	_cContrTama	:= 0
Else
	_cContrTama	:= 1270
EndIf

_oPrint:Say( _nLinha , ( _nColInic + 10 ) , DtoC( Stod(cdada) ) , _oFont14 )

If tipo == 1

	If MV_PAR01 == 2
		
		//====================================================================================================
		// Relatorio de Entradas
		//====================================================================================================
		If MV_PAR12 == 2
		
			_oPrint:Say( _nLinha , _nColInic + 230			, tpNotaEnt			, _oFont10 )
			_oPrint:Say( _nLinha , _nColInic + 230 + 245	, cdocumento		, _oFont14 )
			_oPrint:Say( _nLinha+15 , _nColInic + 505 + 295	, AllTrim(_cCliente)	, _oFont10 )
			
		//====================================================================================================
		// Relatorio de Saidas
		//====================================================================================================
		Else
		
			_oPrint:Say( _nLinha , _nColInic + 230			, cdocumento		, _oFont14 )
			_oPrint:Say( _nLinha , _nColInic + 540			, AllTrim(_cCliente)	, _oFont14 )
			
		EndIf
		
	EndIf
	
Else

	If MV_PAR01 == 2
	
		_oPrint:Say( _nLinha , _nColInic + 230 , cdesMovInt , _oFont14 )
	
	EndIf
		
EndIf

_oPrint:Say( _nLinha , ( _nColInic + 1440 ) - _cContrTama + 40, Transform( nqtde1um , "@R 999999999.99" )				, _oFont14 )
_oPrint:Say( _nLinha , ( _nColInic + 1815 ) - _cContrTama		, cum1													, _oFont14 )
_oPrint:Say( _nLinha , ( _nColInic + 2035 ) - _cContrTama + 40, Transform( nqtde2um , "@R 999999999.99" )				, _oFont14 )
_oPrint:Say( _nLinha , ( _nColInic + 2415 ) - _cContrTama		, cum2									  				, _oFont14 )

//====================================================================================================
// Verifica se sera necessaria a impressao da coluna media PC(peca)
//====================================================================================================
If _lQueijoPC
_oPrint:Say( _nLinha , ( _nColInic + 2460 ) - (_cContrTama + 30), Transform( nqtde1um / nqtde2um , "@R 999,999.99" )	, _oFont14 )
EndIf

_oPrint:Say( _nLinha , ( _nColInic + 2610 ) - _cContrTama	, Transform( nprcUnit , "@R 999,999,999.9999" )				, _oFont14 )
_oPrint:Say( _nLinha , ( _nColInic + 2985 ) - _cContrTama	, Transform( nvlrTotal , "@R 999,999,999.99" )				, _oFont14 )

Return()

/*
===============================================================================================================================
Programa----------: ROMS016EXE
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Executa o processamento do Relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS016EXE()

Local _nCountRec	:= 0
Local _aProdutos	:= {}
Local _nPosProd		:= 0

Local _nCtqt1		:= 0
Local _nCtqt2		:= 0
Local _nCprcve		:= 0
Local _nCTotal		:= 0

Local _cFiltSai		:= ""
Local _cFiltEnt		:= ""
Local _cFiltInt		:= ""
Local _cContrTama	:= 0

Local _cUTipo		:= ""
Local _cUGrProd		:= ""
Local _cUSegUM		:= ""

Local _cQuery		:= ""

//====================================================================================================
// Relatorio Anal�tico/Sint�tico
//====================================================================================================
If MV_PAR01 == 2
	_cContrTama := 0
Else
	_cContrTama := 1270
EndIf

//====================================================================================================
// Filtros de Filial
//====================================================================================================
If !Empty(MV_PAR02)
	
	If !Empty( xFilial("SD2") )
		_cFiltSai += " AND D2.D2_FILIAL IN "+ FormatIn( mv_par02 , ";" )
	EndIf
	
	If !Empty(xFilial("SF4"))
		_cFiltSai += " AND F4.F4_FILIAL IN "+ FormatIn( mv_par02 , ";" )
		_cFiltEnt += " AND F4.F4_FILIAL IN "+ FormatIn( mv_par02 , ";" )
	EndIf
	
	If !Empty(xFilial("SA1"))
		_cFiltSai += " AND A1.A1_FILIAL IN "+ FormatIn( mv_par02 , ";" )
	EndIf
	
	If !Empty(xFilial("SB1"))
	
		_cFiltSai += " AND B1.B1_FILIAL IN "+ FormatIn( mv_par02 , ";" )
		_cFiltEnt += " AND B1.B1_FILIAL IN "+ FormatIn( mv_par02 , ";" )
		_cFiltInt += " AND B1.B1_FILIAL IN "+ FormatIn( mv_par02 , ";" )
		
	EndIf
	
	If !Empty( xFilial("SD3") )
		_cFiltInt += " AND D3.D3_FILIAL IN "+ FormatIn( mv_par02 , ";" )
	EndIf
	
	If !Empty( xFilial("SD1") )
		_cFiltEnt += " AND D1.D1_FILIAL IN "+ FormatIn( mv_par02 , ";" )
	EndIf
	
EndIf

//====================================================================================================
// Filtros de Armaz�m
//====================================================================================================
If !Empty( MV_PAR03 )
	
	_cFiltSai += " AND D2.d2_local = '"+ MV_PAR03 +"' "
	_cFiltEnt += " AND D1.d1_local = '"+ MV_PAR03 +"' "
	_cFiltInt += " AND D3.d3_local = '"+ MV_PAR03 +"' "
	
EndIf

//====================================================================================================
// Filtro Do Periodo ate o periodo
//====================================================================================================
If !Empty( MV_PAR04 ) .And. !Empty( MV_PAR05 )
	
	_cFiltSai += " AND D2.D2_EMISSAO BETWEEN '"+ DtoS( mv_par04 ) +"' AND '"+ DtoS( mv_par05 ) +"' "
	_cFiltEnt += " AND D1.D1_DTDIGIT BETWEEN '"+ DtoS( mv_par04 ) +"' AND '"+ DtoS( mv_par05 ) +"' "
	_cFiltInt += " AND D3.D3_EMISSAO BETWEEN '"+ DtoS( mv_par04 ) +"' AND '"+ DtoS( mv_par05 ) +"' "
	
EndIf

//====================================================================================================
// Filtro De produto Ate o produto
//====================================================================================================
If !Empty(MV_PAR06) .And. !Empty(MV_PAR07)
	
	_cFiltSai += " AND B1.B1_COD BETWEEN '"+ mv_par06 +"' AND '"+ mv_par07 +"' "
	_cFiltEnt += " AND B1.B1_COD BETWEEN '"+ mv_par06 +"' AND '"+ mv_par07 +"' "
	_cFiltInt += " AND B1.B1_COD BETWEEN '"+ mv_par06 +"' AND '"+ mv_par07 +"' "
	
EndIf

//====================================================================================================
// Filtro de Grupo de Produtos
//====================================================================================================
If !Empty(mv_par08)

	_cFiltSai += " AND B1.B1_GRUPO IN "+ FormatIn( mv_par08 , ";" )
	_cFiltEnt += " AND B1.B1_GRUPO IN "+ FormatIn( mv_par08 , ";" )
	_cFiltInt += " AND B1.B1_GRUPO IN "+ FormatIn( mv_par08 , ";" )
	
EndIf

//====================================================================================================
// Filtro de Produto Nivel 2
//====================================================================================================
If !Empty(mv_par09)

	_cFiltSai += " AND B1.B1_I_NIV2 IN "+ FormatIn( mv_par09 , ";" )
	_cFiltEnt += " AND B1.B1_I_NIV2 IN "+ FormatIn( mv_par09 , ";" )
	_cFiltInt += " AND B1.B1_I_NIV2 IN "+ FormatIn( mv_par09 , ";" )

EndIf

//====================================================================================================
// Filtro de Produto Nivel 3
//====================================================================================================
If !Empty(mv_par10)

	_cFiltSai += " AND B1.B1_I_NIV3 IN "+ FormatIn( mv_par10 , ";" )
	_cFiltEnt += " AND B1.B1_I_NIV3 IN "+ FormatIn( mv_par10 , ";" )
	_cFiltInt += " AND B1.B1_I_NIV3 IN "+ FormatIn( mv_par10 , ";" )
	
EndIf

//====================================================================================================
// Filtra Produto Nivel 4
//====================================================================================================
If !Empty(mv_par11)

	_cFiltSai += " AND B1.B1_I_NIV4 IN "+ FormatIn( mv_par11 , ";" )
	_cFiltEnt += " AND B1.B1_I_NIV4 IN "+ FormatIn( mv_par11 , ";" )
	_cFiltInt += " AND B1.B1_I_NIV4 IN "+ FormatIn( mv_par11 , ";" )
	
EndIf

//====================================================================================================
// Filtra Sub Grupo de Produto
//====================================================================================================
If !Empty(mv_par14)

	_cFiltSai += " AND B1.B1_I_SUBGR IN "+ FormatIn( mv_par14 , ";" )
	_cFiltEnt += " AND B1.B1_I_SUBGR IN "+ FormatIn( mv_par14 , ";" )
	_cFiltInt += " AND B1.B1_I_SUBGR IN "+ FormatIn( mv_par14 , ";" )

EndIf

//====================================================================================================
// Relatorio de Saida
//====================================================================================================
If MV_PAR12 == 1
	
	_cQuery := "SELECT"
	
	//====================================================================================================
	// Analitico
	//====================================================================================================
	If MV_PAR01 == 2
	
		_cQuery += " 	D2.D2_COD	 		PRODUTO		,"
		_cQuery += " 	D2.D2_EMISSAO		EMISSAO		,"
		_cQuery += " 	D2.D2_DOC	 		DOCUMENTO	,"
		_cQuery += " 	D2.D2_SERIE	 		SERIE		,"
		_cQuery += " 	D2.D2_CLIENTE		CLIENTE		,"
		_cQuery += " 	D2.D2_LOJA			LOJA		,"
		_cQuery += "		CASE"
		_cQuery += " 		WHEN F2.F2_TIPO IN ('D','B') "
		_cQuery += " 			THEN ( SELECT A2.A2_NREDUZ FROM SA2010 A2 WHERE A2.A2_FILIAL = '" + xFilial("SA2") +"'" 
		_cQuery += "          AND A2.D_E_L_E_T_ = ' ' AND D2.D2_CLIENTE = A2.A2_COD AND D2.D2_LOJA = A2.A2_LOJA ) "
		_cQuery += "				ELSE ( SELECT A1.A1_NREDUZ FROM SA1010 A1 WHERE A1.A1_FILIAL = '" + xFilial("SA1") + "'" "
		_cQuery += "                     AND A1.D_E_L_E_T_ = ' ' AND D2.D2_CLIENTE = A1.A1_COD AND D2.D2_LOJA = A1.A1_LOJA ) "
		_cQuery += "		END				NOMFANTASIA	,"
		_cQuery += " 	D2.D2_UM   			UM			,"
		_cQuery += " 	D2.D2_SEGUM			SEGUM		,"
		_cQuery += " 	SUM(D2.D2_QUANT)	QUANT		,"
		_cQuery += " 	SUM(D2.D2_QTSEGUM)	QTSEGUM		,"
		_cQuery += " 	DECODE( SUM(D2.D2_QUANT) , 0 , 0 , SUM(D2.D2_TOTAL) / SUM(D2.D2_QUANT) ) PRCVEN,"
		_cQuery += " 	SUM(D2.D2_TOTAL)	TOTAL		," 
		_cQuery += " 	TO_CHAR(NULL)		TM			,"
		_cQuery += " 	'A'					TIPO		,"
		_cQuery += " 	B1.B1_I_DESCD		DESCPROD	,"
		_cQuery += " 	'SAIDA POR NF' 	DESCMOVINT	,"
		_cQuery += " 	TO_CHAR(NULL)		TPNOTAENT	 "
		
	//====================================================================================================
	// Sintetico
	//====================================================================================================
	Else
	
		_cQuery += " 	D2.D2_COD			PRODUTO		,"
		_cQuery += " 	D2.D2_EMISSAO		EMISSAO		,"
		_cQuery += " 	D2.D2_UM 			UM			,"
		_cQuery += " 	D2.D2_SEGUM			SEGUM		,"
		_cQuery += " 	SUM(D2.D2_QUANT)	QUANT		,"
		_cQuery += " 	SUM(D2.D2_QTSEGUM)	QTSEGUM		,"
		_cQuery += " 	DECODE( SUM(D2.D2_QUANT) , 0 , 0 , SUM(D2.D2_TOTAL) / SUM(D2.D2_QUANT) ) PRCVEN," //Alterado por Erich Buttner dia 19/06/13 - Corrigir a Query para verificar a quantidade se esta zero e inserir o valor default 1//_cQuery += " Sum(D2.d2_quant) quant,Sum(D2.d2_qtsegum) qtsegum,Sum(d2.d2_total) / Sum(D2.d2_quant) prcven,"
		_cQuery += " 	SUM(D2.D2_TOTAL)	TOTAL		,"
		_cQuery += "		'A'					TIPO	,"
		_cQuery += " 	B1.B1_I_DESCD		DESCPROD	 "
			
	EndIf
	
	_cQuery += " FROM "+ RetSqlName("SD2") +" D2 "
	_cQuery += " JOIN   (SELECT F2.F2_FILIAL, F2.F2_DOC, F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_TIPO FROM "
	_cQuery += RetSqlName("SF2") +" F2 WHERE F2.D_E_L_E_T_ = ' ') F2 ON F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC = D2.D2_DOC AND F2.F2_CLIENTE = D2.D2_CLIENTE AND F2.F2_LOJA = D2.D2_LOJA "
	_cQuery += " JOIN   (SELECT F4.F4_FILIAL,F4.F4_CODIGO,F4.F4_ESTOQUE FROM "
	_cQuery += RetSqlName("SF4") +" F4 WHERE F4.D_E_L_E_T_ = ' ') F4 ON D2.D2_FILIAL = F4.F4_FILIAL AND D2.D2_TES = F4.F4_CODIGO "
	_cQuery += " JOIN   (SELECT B1.B1_FILIAL,B1.B1_COD,B1.B1_I_DESCD,B1.B1_GRUPO,B1.B1_I_SUBGR,B1.B1_I_NIV4,B1.B1_I_NIV3,B1.B1_I_NIV2 FROM "
	_cQuery += RetSqlName("SB1") +" B1  WHERE B1.D_E_L_E_T_ = ' ')  B1 ON B1.B1_FILIAL = '" + xfilial("SB1") + "' AND D2.D2_COD    = B1.B1_COD "
	_cQuery += " WHERE "
	_cQuery += "     D2.D_E_L_E_T_ = ' ' "
	_cQuery += " AND F4.F4_ESTOQUE = 'S' "
	_cQuery += _cFiltSai
	
	//====================================================================================================
	// Analitico
	//====================================================================================================
	If MV_PAR01 == 2
	
		_cQuery += " GROUP BY D2.D2_COD,D2.D2_EMISSAO,D2.D2_DOC,D2.D2_SERIE,D2.D2_CLIENTE,D2.D2_LOJA,D2.D2_UM,D2.D2_SEGUM,B1.B1_I_DESCD,F2.F2_TIPO "
	
	//====================================================================================================
	// Sintetico
	//====================================================================================================
	Else
	
		_cQuery += " GROUP BY D2.D2_COD,D2.D2_EMISSAO,D2.D2_UM,D2.D2_SEGUM,B1.B1_I_DESCD "
		
	EndIf
	
	//====================================================================================================
	// Somente se o usuario desejar visualiar as movimentacoes internas
	//====================================================================================================
	If MV_PAR13 == 1
		
		_cQuery += " UNION ALL "
		
		_cQuery += " SELECT"
		
		//====================================================================================================
		// Analitico
		//====================================================================================================
		If MV_PAR01 == 2
		
			_cQuery += " 	D3.D3_COD			PRODUTO 	,"
			_cQuery += " 	D3.D3_EMISSAO		EMISSAO		,"
			_cQuery += " 	TO_CHAR(NULL)		DOCUMENTO	,"
			_cQuery += " 	TO_CHAR(NULL)		SERIE		,"
			_cQuery += " 	TO_CHAR(NULL) 		CLIENTE		,"
			_cQuery += " 	TO_CHAR(NULL)		LOJA		,"
			_cQuery += " 	TO_CHAR(NULL)		NOMFANTASIA	,"
			_cQuery += " 	D3.D3_UM			UM			,"
			_cQuery += " 	D3.D3_SEGUM			SEGUM		,"
			_cQuery += " 	SUM(D3.D3_QUANT)	QUANT		,"
			_cQuery += " 	SUM(D3.D3_QTSEGUM)	QTSEGUM		,"
			_cQuery += " 	DECODE( SUM(D3.D3_QUANT) , 0 , 0 , ( SUM(D3.D3_CUSTO1) / SUM(D3.D3_QUANT) ) ) PRCVEN," //Alterado por Erich Buttner dia 19/06/13 - Corrigir a Query para verificar a quantidade se esta zero e inserir o valor default 1//_cQuery += " Sum(d3.d3_quant) quant,Sum(d3.d3_qtsegum) qtsegum,(Sum(d3.d3_custo1) / Sum(d3.d3_quant)) prcven"
			_cQuery += " 	SUM(D3.D3_CUSTO1)	TOTAL		,"
			_cQuery += " 	D3.D3_TM			TM			,"
			_cQuery += " 	'B'					TIPO		," 
			_cQuery += " 	B1.B1_I_DESCD		DESCPROD	,"
			_cQuery += " 	CASE"
			_cQuery += " 		WHEN D3_TM = '803' THEN 'Consumo Interno'		"
			_cQuery += " 		WHEN D3_TM = '804' THEN 'Faltas/Descarte'		"
			_cQuery += " 		WHEN D3_TM = '999' THEN 'Transf.Armazem Perda'	"
			_cQuery += " 		ELSE 'Outras Saidas' "
			_cQuery += " 	END					DESCMOVINT	,"
			_cQuery += " 	TO_CHAR(NULL)		TPNOTAENT	 "
	
		
		//====================================================================================================
		// Sintetico
		//====================================================================================================
		Else
		
			_cQuery += " 	D3.D3_COD			PRODUTO		,"
			_cQuery += " 	D3.D3_EMISSAO		EMISSAO		,"
			_cQuery += " 	D3.D3_UM			UM			,"
			_cQuery += " 	D3.D3_SEGUM			SEGUM		,"
			_cQuery += " 	SUM(D3.D3_QUANT)	QUANT		,"
			_cQuery += " 	SUM(D3.D3_QTSEGUM)	QTSEGUM		,"
			_cQuery += " 	DECODE( SUM(D3.D3_QUANT) , 0 , 0 , ( SUM(D3.D3_CUSTO1) / SUM(D3.D3_QUANT) ) ) PRCVEN," //Alterado por Erich Buttner dia 19/06/13 - Corrigir a Query para verificar a quantidade se esta zero e inserir o valor default 1//_cQuery += " Sum(d3.d3_quant) quant,Sum(d3.d3_qtsegum) qtsegum,(Sum(d3.d3_custo1) / Sum(d3.d3_quant)) prcven"
			_cQuery += " 	SUM(D3.D3_CUSTO1)	TOTAL		,"
			_cQuery += " 	'B'					TIPO		,"
			_cQuery += " 	B1.B1_I_DESCD		DESCPROD	 "
				
	
			
		EndIf
		
		_cQuery += " FROM "+ RetSqlName("SD3") + " D3 "
		_cQuery += " JOIN   (SELECT B1.B1_FILIAL,B1.B1_COD,B1.B1_I_DESCD,B1.B1_GRUPO,B1.B1_I_SUBGR,B1.B1_I_NIV4,B1.B1_I_NIV3,B1.B1_I_NIV2 FROM "
		_cQuery += RetSqlName("SB1") +" B1  WHERE B1.D_E_L_E_T_ = ' ')  B1 ON B1.B1_FILIAL = '" + xfilial("SB1") + "' AND D3.D3_COD = B1.B1_COD "
		_cQuery 	+= " WHERE "
		_cQuery += "     D3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND D3.D3_TM      > '500' "
		_cQuery += " AND D3_ESTORNO    <> 'S' "
		_cQuery += _cFiltInt
		
		//====================================================================================================
		// Analitco
		//====================================================================================================
		If MV_PAR01 == 2
		
			_cQuery += " GROUP BY d3.d3_cod,d3.d3_emissao,d3.d3_tm,d3.d3_um,D3.d3_segum,b1.b1_i_descd "
		
		//====================================================================================================
		// Sintetico
		//====================================================================================================
		Else
		
			_cQuery += " GROUP BY d3.d3_cod,d3.d3_emissao,d3.d3_um,D3.d3_segum,b1.b1_i_descd "
			
		EndIf
		
	EndIf
	
	//====================================================================================================
	// Analitico
	//====================================================================================================
	If MV_PAR01 == 2
	
		_cQuery += " ORDER BY PRODUTO , TIPO , EMISSAO , DOCUMENTO , TM "
	
	//====================================================================================================
	// Sintetico
	//====================================================================================================
	Else
	
		_cQuery += " ORDER BY PRODUTO , SEGUM , EMISSAO "
		
	EndIf

//====================================================================================================
// Relatorio de Entrada
//====================================================================================================
Else
	
	_cQuery := " SELECT "
	
	//====================================================================================================
	// Analitico
	//====================================================================================================
	If MV_PAR01 == 2
	
		_cQuery += " 	D1.D1_COD			PRODUTO		,"
		_cQuery += " 	D1.D1_DTDIGIT		EMISSAO		,"
		_cQuery += " 	D1.D1_DOC			DOCUMENTO	,"
		_cQuery += " 	D1.D1_SERIE			SERIE		,"
		_cQuery += " 	D1.D1_FORNECE		CLIENTE		,"
		_cQuery += " 	D1.D1_LOJA			LOJA		,"
		_cQuery += "		CASE "
		_cQuery += " 		WHEN D1.D1_TIPO <> 'D' "
		_cQuery += " 			THEN ( SELECT A2.A2_NREDUZ FROM SA2010 A2 WHERE A2.D_E_L_E_T_ = ' ' AND D1.D1_FORNECE = A2.A2_COD AND D1.D1_LOJA = A2.A2_LOJA ) "
		_cQuery += " 			ELSE ( SELECT A1.A1_NREDUZ FROM SA1010 A1 WHERE A1.D_E_L_E_T_ = ' ' AND D1.D1_FORNECE = A1.A1_COD AND D1.D1_LOJA = A1.A1_LOJA ) "
		_cQuery += "		END					NOMFANTASIA	,"
		_cQuery += " 	D1.D1_UM			UM			,"
		_cQuery += " 	D1.D1_SEGUM			SEGUM		,"
		_cQuery += " 	SUM(D1.D1_QUANT)	QUANT		,"
		_cQuery += " 	SUM(D1.D1_QTSEGUM)	QTSEGUM		,"
		_cQuery += " 	CASE "
		_cQuery += " 		WHEN SUM(D1.D1_QUANT) > 0 "
		_cQuery += " 			THEN DECODE( SUM(D1.D1_QUANT) , 0 , 0 , SUM(D1.D1_TOTAL) / SUM(D1.D1_QUANT) ) "
		_cQuery += " 			ELSE 0 "
		_cQuery += " 	END					PRCVEN		," //Alterado por Erich Buttner dia 19/06/13 - Corrigir a Query para verificar a quantidade se esta zero e inserir o valor default 1//_cQuery += " CASE WHEN Sum(D1.d1_quant) > 0 THEN Sum(D1.d1_total) / Sum(D1.d1_quant) ELSE 0 END prcven,"
		_cQuery += " 	SUM(D1.D1_TOTAL)	TOTAL		,"
		_cQuery += " 	TO_CHAR(NULL)		TM			,"
		_cQuery += " 	'A'					TIPO		,"
		_cQuery += " 	B1.B1_I_DESCD		DESCPROD	,"
		_cQuery += " 	CASE "
		_cQuery += " 		WHEN D1.D1_TIPO = 'N' And D1.D1_FORNECE = 'F00001' "
		_cQuery += " 			THEN 'Transferencia'
		_cQuery += " 		WHEN D1.D1_TIPO = 'N' And D1.D1_FORNECE <> 'F00001' "
		_cQuery += " 			THEN 'Outras Entradas'
		_cQuery += " 		WHEN D1.D1_TIPO = 'D' "
		_cQuery += " 			THEN 'Devolucao' "
		_cQuery += " 			ELSE 'Outras Entradas' "
		_cQuery += " 	END					DESCMOVINT	, "
		_cQuery += " 	CASE "
		_cQuery += " 		WHEN D1.D1_TIPO = 'N' And D1.D1_FORNECE = 'F00001' "
		_cQuery += " 			THEN 'Transferencia'
		_cQuery += " 		WHEN D1.D1_TIPO = 'N' And D1.D1_FORNECE <> 'F00001' "
		_cQuery += " 			THEN 'Outras Entradas'
		_cQuery += " 		WHEN D1.D1_TIPO = 'D' "
		_cQuery += " 			THEN 'Devolucao' "
		_cQuery += " 			ELSE 'Outras Entradas' "
		_cQuery += " 	END					TPNOTAENT	 "
		
	//====================================================================================================
	// Sintetico
	//====================================================================================================
	Else
	
		_cQuery += " 	D1.D1_COD			PRODUTO		,"
		_cQuery += " 	D1.D1_DTDIGIT		EMISSAO		,"
		_cQuery += " 	D1.D1_UM			UM			,"
		_cQuery += " 	D1.D1_SEGUM			SEGUM		,"
		_cQuery += " 	Sum(D1.D1_QUANT)	QUANT		,"
		_cQuery += " 	Sum(D1.D1_QTSEGUM)	QTSEGUM		,"
		_cQuery += " 	CASE "
		_cQuery += " 		WHEN SUM(D1.D1_QUANT) > 0 "
		_cQuery += " 			THEN DECODE( SUM(D1.D1_QUANT) , 0 , 0 , SUM(D1.D1_TOTAL) / SUM(D1.D1_QUANT) ) "
		_cQuery += " 			ELSE 0 "
		_cQuery += " 	END					PRCVEN		," //Alterado por Erich Buttner dia 19/06/13 - Corrigir a Query para verificar a quantidade se esta zero e inserir o valor default 1 //_cQuery += " CASE WHEN Sum(D1.d1_quant) > 0 THEN Sum(D1.d1_total) / Sum(D1.d1_quant) ELSE 0 END prcven,"
		_cQuery += " 	SUM(D1.D1_TOTAL)	TOTAL		,"
		_cQuery += " 	'A'					TIPO		,"
		_cQuery += " 	B1.B1_I_DESCD		DESCPROD	 "
		
	EndIf
		
	_cQuery += " FROM "+ RetSqlName("SD1") +" D1 "
	_cQuery += " JOIN "+ RetSqlName("SF4") +" F4 ON D1.D1_FILIAL = F4.F4_FILIAL AND D1.D1_TES = F4.F4_CODIGO "
	_cQuery += " JOIN   (SELECT B1.B1_FILIAL,B1.B1_COD,B1.B1_I_DESCD,B1.B1_GRUPO,B1.B1_I_SUBGR,B1.B1_I_NIV4,B1.B1_I_NIV3,B1.B1_I_NIV2 FROM "
	_cQuery += RetSqlName("SB1") +" B1  WHERE B1.D_E_L_E_T_ = ' ')  B1 ON B1.B1_FILIAL = '" + xfilial("SB1") + "' AND D1.D1_COD = B1.B1_COD "
	_cQuery += " WHERE "
	_cQuery += "     D1.D_E_L_E_T_ = ' ' "
	_cQuery += " AND F4.D_E_L_E_T_ = ' ' "
	_cQuery += " AND F4.F4_ESTOQUE = 'S' "
	_cQuery += _cFiltEnt
	
	//====================================================================================================
	// Analitico
	//====================================================================================================
	If MV_PAR01 == 2
		_cQuery += " GROUP BY D1.D1_COD, D1.D1_DTDIGIT, D1.D1_DOC, D1.D1_SERIE, D1.D1_FORNECE, D1.D1_LOJA, D1.D1_UM, D1.D1_SEGUM, B1.B1_I_DESCD, D1.D1_TIPO "
	
	//====================================================================================================
	// Sintetico
	//====================================================================================================
	Else
		_cQuery += " GROUP BY D1.D1_COD, D1.D1_DTDIGIT, D1.D1_UM, D1.D1_SEGUM, B1.B1_I_DESCD "
	EndIf
	
	//====================================================================================================
	// Somente se o usuario desejar visualiar as movimentacoes internas
	//====================================================================================================
	If MV_PAR13 == 1
		
		_cQuery += " UNION ALL "
		
		_cQuery += " SELECT "
		
		//====================================================================================================
		// Analitico
		//====================================================================================================
		If MV_PAR01 == 2
		
			_cQuery += " 	D3.D3_COD			PRODUTO		,"
			_cQuery += " 	D3.D3_EMISSAO		EMISSAO		,"
			_cQuery += " 	TO_CHAR(NULL)		DOCUMENTO	,"
			_cQuery += " 	TO_CHAR(NULL)		SERIE		,"
			_cQuery += " 	TO_CHAR(NULL)		CLIENTE		,"
			_cQuery += " 	TO_CHAR(NULL)		LOJA		,"
			_cQuery += " 	TO_CHAR(NULL)		NOMFANTASIA	,"
			_cQuery += " 	D3.D3_UM			UM			,"
			_cQuery += " 	D3.D3_SEGUM			SEGUM		,"
			_cQuery += " 	SUM(D3.D3_QUANT)	QUANT		,"
			_cQuery += " 	SUM(D3.D3_QTSEGUM)	QTSEGUM		,"
			_cQuery += " 	DECODE( SUM(D3.D3_QUANT) , 0 , 0 , ( SUM(D3.D3_CUSTO1) / SUM(D3.D3_QUANT) ) ) PRCVEN," //Alterado por Erich Buttner dia 19/06/13 - Corrigir a Query para verificar a quantidade se esta zero e inserir o valor default 1 //_cQuery += " Sum(d3.d3_quant) quant,Sum(d3.d3_qtsegum) qtsegum,(Sum(d3.d3_custo1) / Sum(d3.d3_quant)) prcven"
			_cQuery += " 	SUM( D3.D3_CUSTO1)	TOTAL		,"
			_cQuery += " 	D3.D3_TM			TM			,"
			_cQuery += " 	'B'					TIPO		,"
			_cQuery += " 	B1.B1_I_DESCD		DESCPROD	,"
			_cQuery += "		CASE"
			_cQuery += " 		WHEN D3_TM IN ('001','003','004') "
			_cQuery += " 			THEN ' Producao' " //Alterado por Lucas Crevilari - 27/08/14. Chamado 7189. _cQuery += " WHEN d3_tm = '001' THEN 'Producao'"
			_cQuery += " 		WHEN D3_TM = '499' "
			_cQuery += " 			THEN 'Entrada Transf.Perda' "
			_cQuery += " 			ELSE 'Outras Entradas' "
			_cQuery += "		END					DESCMOVINT	,"
			_cQuery += " 	TO_CHAR(NULL)		TPNOTAENT	 "
		
		//====================================================================================================
		// Sintetico
		//====================================================================================================
		Else
		
			_cQuery += " 	D3.D3_COD			PRODUTO		,"
			_cQuery += " 	D3.D3_EMISSAO		EMISSAO		,"
			_cQuery += " 	D3.D3_UM			UM			,"
			_cQuery += " 	D3.D3_SEGUM			SEGUM		,"
			_cQuery += " 	SUM(D3.D3_QUANT)	QUANT		,"
			_cQuery += " 	SUM(D3.D3_QTSEGUM)	QTSEGUM		,"
			_cQuery += " 	DECODE( SUM(D3.D3_QUANT) , 0 , 0 , ( SUM(D3.D3_CUSTO1) / SUM(D3.D3_QUANT) ) ) PRCVEN ,"//Alterado por Erich Buttner dia 19/06/13 - Corrigir a Query para verificar a quantidade se esta zero e inserir o valor default 1 //_cQuery += " Sum(d3.d3_quant) quant,Sum(d3.d3_qtsegum) qtsegum,(Sum(d3.d3_custo1) / Sum(d3.d3_quant)) prcven"
			_cQuery += " 	Sum(D3.D3_CUSTO1)	TOTAL		,"
			_cQuery += " 	'B'					TIPO		,"
			_cQuery += " 	B1.B1_I_DESCD		DESCPROD	 "
			
		EndIf
		
		_cQuery += " FROM "+ RetSqlName("SD3") +" D3 "
		_cQuery += " JOIN   (SELECT B1.B1_FILIAL,B1.B1_COD,B1.B1_I_DESCD,B1.B1_GRUPO,B1.B1_I_SUBGR,B1.B1_I_NIV4,B1.B1_I_NIV3,B1.B1_I_NIV2 FROM "
		_cQuery += RetSqlName("SB1") +" B1  WHERE B1.D_E_L_E_T_ = ' ')  B1 ON B1.B1_FILIAL = '" + xfilial("SB1") + "' AND D3.D3_COD = B1.B1_COD "
		_cQuery += " WHERE "
		_cQuery += "     D3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND D3.D3_TM      < '500' "
		_cQuery += " AND D3_ESTORNO    <> 'S' "
		_cQuery += _cFiltInt
		
		//====================================================================================================
		// Analitco
		//====================================================================================================
		If MV_PAR01 == 2
			_cQuery += " GROUP BY D3.D3_COD, D3.D3_EMISSAO, D3.D3_TM, D3.D3_UM, D3.D3_SEGUM, B1.B1_I_DESCD "
		
		//====================================================================================================
		// Sintetico
		//====================================================================================================
		Else
			_cQuery += " GROUP BY D3.D3_COD, D3.D3_EMISSAO, D3.D3_UM, D3.D3_SEGUM, B1.B1_I_DESCD "
			
		EndIf
		
	EndIf
	
	//====================================================================================================
	// Analitico
	//====================================================================================================
	If MV_PAR01 == 2
		_cQuery += " ORDER BY PRODUTO , TIPO , EMISSAO , TPNOTAENT , DOCUMENTO "
	
	//====================================================================================================
	// Sintetico
	//====================================================================================================
	Else
		_cQuery += " ORDER BY PRODUTO , SEGUM , EMISSAO "
		
	EndIf
	
EndIf

If Select( "TMPMOVIM" ) > 0
	DBSelectArea("TMPMOVIM") ; DBCloseArea()
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry(,, _cQuery ) , 'TMPMOVIM' , .F. , .T. )
COUNT TO _nCountRec

DBSelectArea("TMPMOVIM")
TMPMOVIM->( DBGotop() )

ProcRegua(_nCountRec)

//====================================================================================================
// Imprime cabecalho 
//====================================================================================================
ROMS016CAB(.T.)

//Imprime p�gina de par�metros
ROMS016P(_oprint)

//====================================================================================================
// Imprime cabecalho 
//====================================================================================================
ROMS016CAB(.T.)

If _nCountRec > 0
	
	ROMS016CAB(.F.)
	
	While TMPMOVIM->( !Eof() )
		
		IncProc( "Processando o produto: " + TMPMOVIM->PRODUTO )
		
		_nPosProd := aScan( _aProdutos , {|x| x[1] == AllTrim( TMPMOVIM->PRODUTO ) } )
		
		//====================================================================================================
		// Ja existe um lancamento para este produto
		//====================================================================================================
		If _nPosProd > 0
			
			//====================================================================================================
			// Movimentacao das saidas
			//====================================================================================================
			If alltrim(TMPMOVIM->TIPO) == 'A'
				
				//====================================================================================================
				// Imprime o registro corrente da movimentacao das saidas
				//====================================================================================================
				_nLinha += _nSaltoLinha
				
				_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
				
				If MV_PAR01 == 2
					ROMS016PRT(1,TMPMOVIM->EMISSAO,AllTrim(TMPMOVIM->DOCUMENTO) +'-'+ AllTrim(TMPMOVIM->SERIE),TMPMOVIM->CLIENTE +'/'+ TMPMOVIM->LOJA +' '+ SubStr(TMPMOVIM->NOMFANTASIA,1,24),TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,TMPMOVIM->DESCMOVINT,TMPMOVIM->PRODUTO,TMPMOVIM->TPNOTAENT)
				Else
					ROMS016PRT(1,TMPMOVIM->EMISSAO,'','',TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,'',TMPMOVIM->PRODUTO,'')
				EndIf
				
				//====================================================================================================
				// Totalizadores
				//====================================================================================================
				_nCtqt1  += TMPMOVIM->QUANT
				_nCtqt2  += TMPMOVIM->QTSEGUM
				_nCprcve  += TMPMOVIM->PRCVEN
				_nCTotal  += TMPMOVIM->TOTAL
			
			//====================================================================================================
			// Movimentacao interna
			//====================================================================================================
			Else
				
				If _cUTipo == 'A' .And. MV_PAR13 == 1
					
					//====================================================================================================
					// Imprime totalizador das saidas antes de comecar a movimentacao interna
					//====================================================================================================
					_nLinha += _nSaltoLinha
					
					_oPrint:FillRect( { (_nLinha+3) , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama } , _oBrush )
					
					_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
					
					ROMS016ITT( _nCtqt1 , _nCtqt2 , _nCprcve , _nCTotal , 'A' , _cUGrProd , _cUSegUM )
					
					ROMS016TOT( 'A' , _cUGrProd , _cUSegUM )
					
					_oPrint:Box( _nLinInBox , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama )
					
					ROMS016BOX( 'A' , _cUGrProd , _cUSegUM )
					
					_nLinha += ( _nSaltoLinha * 3 )
					
					//====================================================================================================
					// Imprime cabecalho da movimentacao interna
					//====================================================================================================
					ROMS016QBR()
					
					ROMS016SAI( 2 , '' , '' )
					
					//====================================================================================================
					// Imprime registro corrente da movimentacao interna
					//====================================================================================================
					_nLinha += _nSaltoLinha
					
					_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
					
					If MV_PAR01 == 2
						ROMS016PRT(2,TMPMOVIM->EMISSAO,AllTrim(TMPMOVIM->DOCUMENTO) + '-' + AllTrim(TMPMOVIM->SERIE),TMPMOVIM->CLIENTE + '/' + TMPMOVIM->LOJA + ' ' + SubStr(TMPMOVIM->NOMFANTASIA,1,24),TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,TMPMOVIM->DESCMOVINT,TMPMOVIM->PRODUTO,TMPMOVIM->TPNOTAENT)
					Else
						ROMS016PRT(2,TMPMOVIM->EMISSAO,'','',TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,'',TMPMOVIM->PRODUTO,'')
					EndIf
					
					//====================================================================================================
					// Totalizadores
					//====================================================================================================
					_nCtqt1		:= TMPMOVIM->QUANT
					_nCtqt2		:= TMPMOVIM->QTSEGUM
					_nCprcve	:= TMPMOVIM->PRCVEN
					_nCTotal	:= TMPMOVIM->TOTAL
					
				Else
					
					//====================================================================================================
					// Imprime registro corrente da movimentacao interna
					//====================================================================================================
					_nLinha += _nSaltoLinha
					
					_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
					
					If MV_PAR01 == 2
						ROMS016PRT(2,TMPMOVIM->EMISSAO,AllTrim(TMPMOVIM->DOCUMENTO) + '-' + AllTrim(TMPMOVIM->SERIE),TMPMOVIM->CLIENTE + '/' + TMPMOVIM->LOJA + ' ' + SubStr(TMPMOVIM->NOMFANTASIA,1,24),TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,TMPMOVIM->DESCMOVINT,TMPMOVIM->PRODUTO,TMPMOVIM->TPNOTAENT)
					Else
						ROMS016PRT(2,TMPMOVIM->EMISSAO,'','',TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,'',TMPMOVIM->PRODUTO,'')
					EndIf
					
					//====================================================================================================
					// Totalizadores
					//====================================================================================================
					_nCtqt1  += TMPMOVIM->QUANT
					_nCtqt2  += TMPMOVIM->QTSEGUM
					_nCprcve  += TMPMOVIM->PRCVEN
					_nCTotal  += TMPMOVIM->TOTAL
					
				EndIf
				
			EndIf
		
		//====================================================================================================
		// Produto ainda nao lancado
		//====================================================================================================
		Else
			
			aAdd( _aProdutos , { AllTrim( TMPMOVIM->PRODUTO ) } )
			
			If Len(_aProdutos) > 1
				
				//====================================================================================================
				// Imprime totalizador das saidas antes de comecar a movimentacao interna
				//====================================================================================================
				_nLinha += _nSaltoLinha
				
				_oPrint:FillRect( { (_nLinha+3) , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama } , _oBrush )
				
				_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
				
				ROMS016BOX( _cUTipo , _cUGrProd , _cUSegUM )
				
				ROMS016ITT( _nCtqt1 , _nCtqt2 , _nCprcve , _nCTotal , _cUTipo , _cUGrProd , _cUSegUM )
				
				ROMS016TOT( _cUTipo , _cUGrProd , _cUSegUM )
				
				_oPrint:Box( _nLinInBox , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama )
				
				//====================================================================================================
				// Quebra de pagina a cada novo produto do relatorio
				//====================================================================================================
				_nLinha := _nqbrPagina + 1
				ROMS016QBR()
				
			EndIf
			
			//====================================================================================================
			// Totalizadores
			//====================================================================================================
			_nCtqt1  := TMPMOVIM->QUANT
			_nCtqt2  := TMPMOVIM->QTSEGUM
			_nCprcve  := TMPMOVIM->PRCVEN
			_nCTotal  := TMPMOVIM->TOTAL
			
			//====================================================================================================
			// Imprime descricao do produto
			//====================================================================================================
			ROMS016QBR()
			
				
			ROMS016PRD( TMPMOVIM->PRODUTO , TMPMOVIM->DESCPROD )
			                         
			//====================================================================================================
			// Movimentacao das saidas
			//====================================================================================================
			If alltrim(TMPMOVIM->TIPO) == 'A'
				
				//====================================================================================================
				// Imprime cabecalho dos itens do relatorio: data,documento,valor total, etc...
				//====================================================================================================
				ROMS016QBR()
				
				//====================================================================================================
				// Sao passados parametros indicando que se trata de um movimentacao de saida, o grupo do produto e a
				// segunda unidade de medida para verificar se sera necessaria a impressao da coluna media PC
				//====================================================================================================
				ROMS016SAI( 1 , SubStr( TMPMOVIM->PRODUTO , 1 , 4 ) , TMPMOVIM->SEGUM )
				
				//====================================================================================================
				// Imprime o registro corrente
				//====================================================================================================
				_nLinha += _nSaltoLinha
				
				_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
				
				If MV_PAR01 == 2
					ROMS016PRT(1,TMPMOVIM->EMISSAO,AllTrim(TMPMOVIM->DOCUMENTO) + '-' + AllTrim(TMPMOVIM->SERIE),TMPMOVIM->CLIENTE + '/' + TMPMOVIM->LOJA + '-' + SubStr(TMPMOVIM->NOMFANTASIA,1,24),TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,TMPMOVIM->DESCMOVINT,TMPMOVIM->PRODUTO,TMPMOVIM->TPNOTAENT)
				Else
					ROMS016PRT(1,TMPMOVIM->EMISSAO,'','',TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,'',TMPMOVIM->PRODUTO,'')
				EndIf
			
			//====================================================================================================
			// Movimentacao interna
			//====================================================================================================
			Else
				
				//====================================================================================================
				// Imprime cabecalho dos itens do relatorio: data,documento,valor total, etc...
				//====================================================================================================
				ROMS016QBR()
				ROMS016SAI( 2 , '' , '' )
				
				//====================================================================================================
				// Imprime o registro corrente
				//====================================================================================================
				_nLinha += _nSaltoLinha
				
				_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
				
				If MV_PAR01 == 2
					ROMS016PRT(2,TMPMOVIM->EMISSAO,AllTrim(TMPMOVIM->DOCUMENTO) + '-' + AllTrim(TMPMOVIM->SERIE),TMPMOVIM->CLIENTE + '/' + TMPMOVIM->LOJA + ' ' + SubStr(TMPMOVIM->NOMFANTASIA,1,24),TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,TMPMOVIM->DESCMOVINT,TMPMOVIM->PRODUTO,TMPMOVIM->TPNOTAENT)
				Else
					ROMS016PRT(2,TMPMOVIM->EMISSAO,'','',TMPMOVIM->QUANT,TMPMOVIM->UM,TMPMOVIM->QTSEGUM,TMPMOVIM->SEGUM,TMPMOVIM->PRCVEN,TMPMOVIM->TOTAL,'',TMPMOVIM->PRODUTO,'')
				EndIf
				
			EndIf
			
		EndIf
		
		//====================================================================================================
		// Armazena o ultimo tipo das movimentacoes
		//====================================================================================================
		_cUTipo	:= alltrim(TMPMOVIM->TIPO)					// Armazena o ultimo tipo que entrou A - Mov. De Saidas B - Mov. Internas
		_cUGrProd	:= SubStr(TMPMOVIM->PRODUTO , 1 , 4 )	// Armazena o ultimo grupo de produto que entrou, para visualizar ou nao a coluna media PC para os produtos do tipo queijo
		_cUSegUM	:= TMPMOVIM->SEGUM						// Armazena a ultima segunda unidade de produto que entrou para que auxilie o grupo de produto para visualizar ou nao a coluna media PC
		
		TMPMOVIM->( DBSkip() )
		
		If TMPMOVIM->(!Eof())
		
			//====================================================================================================
			// Quebra de pagina
			//====================================================================================================
			ROMS016PAG( _cUTipo , _cUGrProd , _cUSegUM )
			
		EndIf
		
	EndDo
	
	//====================================================================================================
	// Finaliza o ultimo produto
	//====================================================================================================
	_nLinha += _nSaltoLinha
	
	_oPrint:FillRect( { (_nLinha+3) , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama } , _oBrush )
	
	_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
	
	ROMS016BOX( _cUTipo , _cUGrProd , _cUSegUM )
	
	ROMS016ITT( _nCtqt1 , _nCtqt2 , _nCprcve , _nCTotal , _cUTipo , _cUGrProd , _cUSegUM )
	
	ROMS016TOT( _cUTipo , _cUGrProd , _cUSegUM )
	
	_oPrint:Box( _nLinInBox , _nColInic , _nLinha + _nSaltoLinha , _nColFinal - _cContrTama )
	
EndIf

DBSelectArea("TMPMOVIM") ; DBCloseArea()

Return()

/*
===============================================================================================================================
Programa----------: ROMS016BOX
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Imprime as divisorias das colunas dos conteudos dos relatorios
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ROMS016BOX( cTipo , cGrupo , cSegUm )

Local _cContrTama	:= 0
Local _nEspacamen	:= 0
Local _lQueijoPC	:= .F.

If cGrupo == '0006' .And. cSegUm == 'PC' .And. cTipo == 'A'
	_lQueijoPC := .T.
EndIf

//====================================================================================================
// Relatorio Analitico
//====================================================================================================
If MV_PAR01 == 2
	_cContrTama	:= 0
	_nEspacamen	:= 0
Else
	_cContrTama	:= 1270
	_nEspacamen	:= 50
EndIf

If MV_PAR01 == 2

	//====================================================================================================
	// Relatorio de Saidas
	//====================================================================================================
	If MV_PAR12 == 1
	
		_oPrint:Line( _nLinInBox , 0255 , _nLinha , 0255 ) //DATA
		
		//====================================================================================================
		// Somente sera impresso para as notas fiscais de saida
		//====================================================================================================
		If cTipo == 'A'
			_oPrint:Line( _nLinInBox , 0570 , _nLinha , 0570 ) //DOCUMENTO
		EndiF
		
	//====================================================================================================
	// Relatorio de Entradas
	//====================================================================================================
	Else
	
		_oPrint:Line( _nLinInBox , 0255 , _nLinha , 0255 ) //DATA
		
		//====================================================================================================
		// Somente sera impresso para as notas fiscais de saida
		//====================================================================================================
		If cTipo == 'A'
			_oPrint:Line( _nLinInBox , 0215 + 285 , _nLinha , 0215 + 285 ) //TIPO
			_oPrint:Line( _nLinInBox , 0540 + 285 , _nLinha , 0540 + 285 ) //DOCUMENTO
		EndiF
		
	EndIf
	
EndIf

_oPrint:Line( _nLinInBox , 1480 - _cContrTama + _nEspacamen	, _nLinha , 1480 - _cContrTama + _nEspacamen	) //CLIENTE
_oPrint:Line( _nLinInBox , 1835 - _cContrTama				, _nLinha , 1835 - _cContrTama					) //QTDE 1 U.M.
_oPrint:Line( _nLinInBox , 2030 - _cContrTama				, _nLinha , 2030 - _cContrTama					) //1 U.M.
_oPrint:Line( _nLinInBox , 2435 - _cContrTama				, _nLinha , 2435 - _cContrTama					) //QTDE 2 U.M.

If _lQueijoPC
	_oPrint:Line( _nLinInBox , 2490 - _cContrTama , _nLinha , 2490 - _cContrTama ) //1
	_oPrint:Line( _nLinInBox , 2720 - _cContrTama , _nLinha , 2720 - _cContrTama ) //PRECO UNIT.
else
	_oPrint:Line( _nLinInBox , 2610 - _cContrTama , _nLinha , 2610 - _cContrTama ) //PRECO UNIT.
EndIf

_oPrint:Line( _nLinInBox , 2980 - _cContrTama , _nLinha , 2980 - _cContrTama )//VLR TOTAL

Return()

/*
===============================================================================================================================
Programa----------: ROMS016TOT
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Imprime as divisorias dos totalizadores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ROMS016TOT( cTipo , cGrupo , cSegUm )

Local _cContrTama	:= 0
Local _nEspacamen	:= 0
Local _lQueijoPC		:= .F.

If cGrupo == '0006' .And. cSegUm == 'PC' .And. cTipo == 'A'
	_lQueijoPC := .T.
EndIf

//====================================================================================================
// Relatorio Analitico
//====================================================================================================
If MV_PAR01 == 2
	_cContrTama	:= 0
	_nEspacamen	:= 0
Else
	_cContrTama	:= 1270
	_nEspacamen	:= 50
EndIf


_oPrint:Line( _nLinha , 1480 - _cContrTama + _nEspacamen	, _nLinha + _nSaltoLinha , 1480 - _cContrTama + _nEspacamen	) //CLIENTE
_oPrint:Line( _nLinha , 1835 - _cContrTama					, _nLinha + _nSaltoLinha , 1835 - _cContrTama				) //QTDE 1 U.M.
_oPrint:Line( _nLinha , 2030 - _cContrTama					, _nLinha + _nSaltoLinha , 2030 - _cContrTama				) //1 U.M.
_oPrint:Line( _nLinha , 2435 - _cContrTama					, _nLinha + _nSaltoLinha , 2435 - _cContrTama				) //QTDE 2 U.M.

If _lQueijoPC
	_oPrint:Line( _nLinha , 2490 - _cContrTama , _nLinha + _nSaltoLinha , 2490 - _cContrTama ) //1
	_oPrint:Line( _nLinha , 2720 - _cContrTama , _nLinha + _nSaltoLinha , 2720 - _cContrTama ) //PRECO UNIT.
Else
	_oPrint:Line( _nLinha , 2610 - _cContrTama , _nLinha + _nSaltoLinha , 2610 - _cContrTama ) //PRECO UNIT.
EndIf

_oPrint:Line( _nLinha , 2980 - _cContrTama , _nLinha + _nSaltoLinha , 2980 - _cContrTama )//VLR TOTAL

Return()

/*
===============================================================================================================================
Programa----------: ROMS016PAG
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Processa a quebra de p�gina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS016PAG( cTipo , cGrupo , cSegUm )

Local _cContrTama	:= 0

//====================================================================================================
// Relatorio Analitico
//====================================================================================================
If MV_PAR01 == 2
	_cContrTama	:= 0
Else
	_cContrTama	:= 1270
EndIf

//====================================================================================================
// Quebra de pagina
//====================================================================================================
If _nLinha > _nqbrPagina
	
	_oPrint:Line( _nLinha , _nColInic , _nLinha , _nColFinal - _cContrTama )
	
	_nLinha += _nSaltoLinha
	
	_oPrint:Box( _nLinInBox , _nColInic , _nLinha , _nColFinal - _cContrTama )
	
	ROMS016BOX( cTipo , cGrupo , cSegUm )
	
	_oPrint:EndPage()	// Finaliza a Pagina.
	_oPrint:StartPage()	// Inicia uma nova Pagina
	
	_nPagina++
	
	ROMS016CAB(.F.)		// Chama cabecalho
	
	_nLinha += ( _nSaltoLinha * 3 )
	
	//====================================================================================================
	// Movimentacao das saidas
	//====================================================================================================
	If alltrim(cTipo) == 'A'
		ROMS016SAI( 1 , cGrupo , cSegUm )
	
	//====================================================================================================
	//Movimentacao interna
	//====================================================================================================
	ElseIf alltrim(cTipo) == 'B'
		ROMS016SAI( 2 , '' , '' )
	
	EndIf
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ROMS016QBR
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Processa a quebra de p�gina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS016QBR()

//====================================================================================================
// Quebra de pagina
//====================================================================================================
If _nLinha > _nqbrPagina
	
	_oPrint:EndPage()	// Finaliza a Pagina.
	_oPrint:StartPage()	// Inicia uma nova Pagina
	
	_nPagina++
	
	ROMS016CAB(.F.)		// Chama cabecalho
	
	_nLinha += ( _nSaltoLinha * 3 )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ROMS016ITT
Autor-------------: Fabiano Dias Silva
Data da Criacao---: 08/03/2010
===============================================================================================================================
Descri��o---------: Imprime os dados dos totalizadores do relatorio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS016ITT( nqtde1um , nqtde2um , nprcUnit , nvlrTotal , cTipo , cGrupo , cSegUm )

Local _cContrTama	:= 0
Local _lQueijoPC		:= .F.

If cGrupo == '0006' .And. cSegUm == 'PC' .And. cTipo == 'A'
	_lQueijoPC := .T.
EndIf

//====================================================================================================
// Relatorio Analitico
//====================================================================================================
If MV_PAR01 == 2
	_cContrTama	:= 0
Else
	_cContrTama	:= 1270
EndIf

_oPrint:Say( _nLinha , _nColInic + 25						, "TOTAIS"													, _oFont14b )
_oPrint:Say( _nLinha , _nColInic + 1440 - _cContrTama + 40	, Transform( nqtde1um , "@R 999999999.99" )					, _oFont14b )
_oPrint:Say( _nLinha , _nColInic + 2035 - _cContrTama + 40	, Transform( nqtde2um , "@R 999999999.99" )					, _oFont14b )
_oPrint:Say( _nLinha , _nColInic + 2580 - _cContrTama		, Transform( nvlrTotal / nqtde1um , "@R 9,999,999.9999" )	, _oFont14b )
_oPrint:Say( _nLinha , _nColInic + 2985 - _cContrTama		, Transform( nvlrTotal , "@R 999,999,999.99" )				, _oFont14b )

If _lQueijoPC
	_oPrint:Say( _nLinha , (_nColInic + 2460) - (_cContrTama + 30) , Transform( nqtde1um / nqtde2um , "@R 999,999.99" )		, _oFont14b )
EndIf

Return()

/*
===============================================================================================================================
Programa--------: ROMS016P
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
===============================================================================================================================
Descri��o-------: Funcao que imprime a pagina de parametros do relat�rio
===============================================================================================================================
Parametros------: oprint - objeto da impress�o
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS016P(oPrint)      

Local nAux     := 1   

_nLinha+= 080                                    
oPrint:Line(_nLinha,_nColInic,_nLinha,_nColFinal)
_nLinha+= 60

If MV_PAR01 == 1
	_cmvpar01 := "Sint�tico"
Elseif MV_PAR01 == 2
	_cmvpar01 := "Anal�tico"
Else
	_cmvpar01 := "  "
Endif

If MV_PAR12 == 1
	_cmvpar12 := "Saida"
Elseif MV_PAR12 == 2
	_cmvpar12 := "Entrada"
Else
	_cmvpar12 := "  "
Endif

If MV_PAR13 == 1
	_cmvpar13 := "Sim"
Elseif MV_PAR13 == 2
	_cmvpar13 := "N�o"
Else
	_cmvpar13 := "  "
Endif

_aDadosParam := {}
Aadd(_aDadosParam,{"01","Tipo Relatorio",_cmvpar01})
Aadd(_aDadosParam,{"02","Filiais",mv_par02})
Aadd(_aDadosParam,{"03","Armazem",mv_par03})
Aadd(_aDadosParam,{"04","Do Periodo",dtoc(mv_par04)})
Aadd(_aDadosParam,{"05","Ate Periodo",dtoc(mv_par05)})
Aadd(_aDadosParam,{"06","De Produto",mv_par06})
Aadd(_aDadosParam,{"07","Ate Produto",mv_par07})
Aadd(_aDadosParam,{"08","Grupo Produto",mv_par08})
Aadd(_aDadosParam,{"09","Produto Nivel 2 ",mv_par09})
Aadd(_aDadosParam,{"10","Produto Nivel 3",mv_par10})
Aadd(_aDadosParam,{"11","Produto Nivel 4",mv_par11})
Aadd(_aDadosParam,{"12","Informacoes de",_cmvpar12})
Aadd(_aDadosParam,{"13","Impr.Mov.Internas",_cmvpar13})
Aadd(_aDadosParam,{"14","Sub Grupo Produto ?",mv_par14})


For nAux := 1 To Len(_aDadosParam)
    oPrint:Say (_nLinha,_nColInic + 10    ,"Pergunta " + AllTrim(_aDadosParam[nAux,1]) + ' : ' + AllTrim(_aDadosParam[nAux,2]),_oFont14b)    
    oPrint:Say (_nLinha,_nColInic + 1001  ,_aDadosParam[nAux,3]                                                               ,_oFont14) 
	_nlinha += 60   
Next
	  
_nLinha += 60
	
oPrint:Line(_nLinha,_nColInic,_nLinha,_nColFinal)
oPrint:EndPage()     // Finaliza a p�gina

Return()