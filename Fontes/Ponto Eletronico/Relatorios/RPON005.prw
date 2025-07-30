/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |26/09/2024| Chamado 48646. Corrigida a chamada da fun��o de mensagem. 
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
Lucas Borges  |27/06/2025| Chamado 50617. Revis�es diversas visando padronizar os fontes
===============================================================================================================================
*/

#Include 'Protheus.ch'

#Define TITULO	"Ponto Eletr�nico - Marca��es Manuais de Ponto"

/*
===============================================================================================================================
Programa----------: RPON005
Autor-------------: Alexandre Villar
Data da Criacao---: 24/03/2014
Descri��o---------: Relat�rio de An�lise da Marca��o de Pontos - Jornada x Intervalo
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON005

Local _aRet			:= {} As Array
Local _aParamBox	:= {} As Array
Local _nTamCat		:= Len(FWGetSX5('28')) As Numeric
Local _nTamSit		:= Len(FWGetSX5('31')) As Numeric
Local _nTamSet		:= ( 16 * TamSX3("ZAK_COD")[01] ) As Numeric

SET DATE FORMAT TO "DD/MM/YYYY"

//============================================================================
//| Monta as perguntas para o processamento                                  |
//============================================================================

aAdd( _aParamBox , { 1 , "Filiais ?"			, Space(99)				, "" , "U_RPON005P(1)"	, "SM0001"	, "" , 100 , .F. } )
aAdd( _aParamBox , { 1 , "Data Inicial ?"	, Ctod(Space(8))				, "" , ""				, ""		, "" , 050 , .F. } )
aAdd( _aParamBox , { 1 , "Data Final ?"		, Ctod(Space(8))				, "" , ""				, ""		, "" , 050 , .F. } )
aAdd( _aParamBox , { 1 , "Matr�cula De ?"	, Space( TamSX3("RA_MAT")[01] )	, "" , ""				, "SRA"		, "" , 050 , .F. } )
aAdd( _aParamBox , { 1 , "Matr�cula At� ?"	, Space( TamSX3("RA_MAT")[01] )	, "" , ""				, "SRA"		, "" , 050 , .F. } )
aAdd( _aParamBox , { 1 , "Categorias ?"		, Space(_nTamCat)				, "" , "U_RPON005P(2)"	, "SX5L28"	, "" , 100 , .F. } )
aAdd( _aParamBox , { 1 , "Situa��es ?"		, Space(_nTamSit)				, "" , "U_RPON005P(3)"	, "SX5L31"	, "" , 050 , .F. } )
aAdd( _aParamBox , { 3 , "Sa�da ?"			, 1 , {"Planilha","Relat�rio"}	, 50 , "" , .F. } )
aAdd( _aParamBox , { 1 , "Setores ?"			, Space(_nTamSet)				, "" , "" 				, "ZAK001"	, "" , 100 , .F. } )

If ParamBox( _aParamBox , "Parametriza��o do Relat�rio:" , @_aRet )
	MV_PAR06 := U_ITSEPDEL( MV_PAR06 , 1 , ";" , "*" )
	MV_PAR07 := U_ITSEPDEL( MV_PAR07 , 1 , ";" , "*" )
	Processa( {|| _aDados := RPON005SEL() } , "Aguarde!" , "Verificando as marca��es..." , .T. )
Else
	FWAlertInfo("Processamento cancelado pelo usu�rio!","RPON00501")
EndIf

Return

/*
===============================================================================================================================
Programa----------: RPON005SEL
Autor-------------: Alexandre Villar
Data da Criacao---: 24/03/2014
Descri��o---------: Carrega dados para o relat�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RPON005SEL()

//   				  01     02     03     04     05     06     07     08     09     10     11     12     13
Local _aColPos	:= { 0050 , 0210 , 0750 , 0940 , 1100 , 1195 , 1280 , 1360 , 1465 , 1795 , 1975 , 2130 , 2275 } As Array
Local _aColAjs	:= { 0010 , 0000 , 0000 , 0000 , 0000 , 0010 , 0010 , 0015 , 0000 , 0000 , 0000 , 0015 , 0000 } As Array
Local _aCabec	:= { "Matr�cula" , "Funcion�rio" , "Dt. Apont." , "Dt. Marca" , "Hora" , "Ord." , "Ap." , "Turno" , "Per�odo Aponta" , "Usu�rio" , "Data Inc." , "Hora Inc." , "Motivo" } As Array
Local _aCabecx	:= { "Filial", "Setor", "Matr�cula" , "Funcion�rio" , "Dt. Apont." , "Dt. Marca" , "Hora" , "Ord." , "Ap." , "Turno" , "Per�odo Aponta" , "Usu�rio" , "Data Inc." , "Hora Inc." , "Motivo" } As Array
Local _aDados	:= {} As Array
Local _aFiliais	:= StrToKArr( AllTrim( MV_PAR01 ) , ";" ) As Array
Local _cAlias	:= '' As Character
Local _cQuery	:= "" As Character
Local _dDtAux	:= StoD("") As Character
Local _nTotReg	:= 0 As Numeric
Local _nAtuReg	:= 0 As Numeric
Local _nOpcao	:= 0 As Numeric
Local _nI		:= 0 As Numeric

IF Empty(_aFiliais)
	FWAlertInfo("N�o foram informadas Filiais v�lidas para o processamento!","RPON00502")
	Return()
EndIf

For _nI := 1 To Len(_aFiliais)
	_cAlias	:= GetNextAlias()
	BeginSQL alias _cAlias
		SELECT MAX( PO_DATAFIM ) AS DTFECHA
		FROM %Table:SPO
		WHERE PO_FILIAL = %exp:_aFiliais[_nI]%
		AND D_E_L_E_T_	= ' '
	EndSQL
	
	_dDtAux := SToD((_cAlias)->DTFECHA)
	(_cAlias)->(DBCloseArea())

	If MV_PAR02 < _dDtAux .And. _dDtAux <= MV_PAR03
		_nOpcao := 1
	ElseIf MV_PAR03 < _dDtAux
		_nOpcao := 2
	ElseIf MV_PAR02 > _dDtAux
		_nOpcao := 3
	EndIf
	
	IF _nOpcao == 1 .Or. _nOpcao == 2
		_cAlias	:= GetNextAlias()
		_cQuery += " SELECT "
		_cQuery += "     SPG.PG_FILIAL   AS FILIAL, "
		_cQuery += "     SRA.RA_I_SETOR  AS SETOR, "
		_cQuery += "     SPG.PG_MAT      AS MAT, "
		_cQuery += "     SRA.RA_NOME     AS NOME, "
		_cQuery += "     SPG.PG_DATAAPO  AS DATA_APO, "
		_cQuery += "     SPG.PG_DATA     AS DATA_REG, "
		_cQuery += "     TO_CHAR(TO_DATE(TO_CHAR(SPG.PG_HORA, '00.00'),'hh24:mi'),'hh24:mi') AS HORA, "
		_cQuery += "     SPG.PG_ORDEM    AS ORDEM, "
		_cQuery += "     SPG.PG_APONTA   AS APONTADA, "
		_cQuery += "     SPG.PG_TURNO    AS TURNO, "
		_cQuery += "     SPG.PG_PAPONTA  AS PER_APONTA, "
		_cQuery += "     SPG.PG_USUARIO  AS USUARIO, "
		_cQuery += "     SPG.PG_DATAALT  AS DATA_INC, "
		_cQuery += "     SPG.PG_HORAALT  AS HORA_INC, "
		_cQuery += "     SPG.PG_MOTIVRG  AS MOTIVO "
		_cQuery += " FROM "+ RetSqlName("SPG") +" SPG "
		_cQuery += " INNER JOIN "+ RetSqlName("SRA") +" SRA ON "
		_cQuery += "     SRA.RA_FILIAL   = SPG.PG_FILIAL "
		_cQuery += " AND SRA.RA_MAT      = SPG.PG_MAT "
		_cQuery += " WHERE SPG.D_E_L_E_T_  = ' ' "
		_cQuery += " AND SRA.D_E_L_E_T_  = ' ' "
		
		IF !Empty( MV_PAR09 )
			_cQuery += " AND	SRA.RA_I_SETOR	IN "+ FormatIn( AllTrim( MV_PAR09 ) , ";" )
		EndIF
	
		_cQuery += " AND SPG.PG_TIPOREG  = 'I' "
		_cQuery += " AND SPG.PG_FILIAL   = '"+ _aFiliais[_nI] +"' "
		_cQuery += " AND SPG.PG_MAT      BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
	
		IF _nOpcao == 1
			_cQuery += " AND SPG.PG_DATAAPO	BETWEEN '"+ DTOS( MV_PAR02 ) +"' AND '"+ DTOS( _dDtAux ) +"' "
		ElseIF _nOpcao == 2
			_cQuery += " AND SPG.PG_DATAAPO	BETWEEN '"+ DTOS( MV_PAR02 ) +"' AND '"+ DTOS( MV_PAR03 ) +"' "
		EndIF
		
		_cQuery += " AND SRA.RA_CATFUNC	IN "+ FormatIn( RTrim( MV_PAR06 ) , ";" )
		_cQuery += " AND SRA.RA_SITFOLH  IN "+ FormatIn( RTrim( MV_PAR07 ) , ";" )
	EndIF
	
	IF _nOpcao == 1
		_cQuery += " UNION ALL "
	EndIF
	
	IF _nOpcao == 1 .Or. _nOpcao == 3
	
		_cQuery += " SELECT "
		_cQuery += "     SP8.P8_FILIAL   AS FILIAL, "
		_cQuery += "     SRA.RA_I_SETOR  AS SETOR, "
		_cQuery += "     SP8.P8_MAT      AS MAT, "
		_cQuery += "     SRA.RA_NOME     AS NOME, "
		_cQuery += "     SP8.P8_DATAAPO  AS DATA_APO, "
		_cQuery += "     SP8.P8_DATA     AS DATA_REG, "
		_cQuery += "     TO_CHAR(TO_DATE(TO_CHAR(SP8.P8_HORA, '00.00'),'hh24:mi'),'hh24:mi') AS HORA, "
		_cQuery += "     SP8.P8_ORDEM    AS ORDEM, "
		_cQuery += "     SP8.P8_APONTA   AS APONTADA, "
		_cQuery += "     SP8.P8_TURNO    AS TURNO, "
		_cQuery += "     SP8.P8_PAPONTA  AS PER_APONTA, "
		_cQuery += "     SP8.P8_USUARIO  AS USUARIO, "
		_cQuery += "     SP8.P8_DATAALT  AS DATA_INC, "
		_cQuery += "     SP8.P8_HORAALT  AS HORA_INC, "
		_cQuery += "     SP8.P8_MOTIVRG  AS MOTIVO "
		_cQuery += " FROM "+ RetSqlName("SP8") +" SP8 "
		_cQuery += " INNER JOIN "+ RetSqlName("SRA") +" SRA ON "
		_cQuery += "     SRA.RA_FILIAL   = SP8.P8_FILIAL "
		_cQuery += " AND SRA.RA_MAT      = SP8.P8_MAT "
		_cQuery += " WHERE SP8.D_E_L_E_T_  = ' ' "
		_cQuery += " AND SRA.D_E_L_E_T_  = ' ' "
	
		IF !Empty( MV_PAR09 )
			_cQuery += " AND	SRA.RA_I_SETOR	IN "+ FormatIn( AllTrim( MV_PAR09 ) , ";" )
		EndIF
	
		_cQuery += " AND SP8.P8_TIPOREG  = 'I' "
		_cQuery += " AND SP8.P8_FILIAL   = '"+ _aFiliais[_nI] +"' "
		_cQuery += " AND SP8.P8_MAT      BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
		
		IF _nOpcao == 1
			_cQuery += " AND SP8.P8_DATAAPO	> '"+ DTOS( _dDtAux ) +"' "
			_cQuery += " AND SP8.P8_DATAAPO	<= '"+ DTOS( MV_PAR03 ) +"' "
		ElseIF _nOpcao == 3
			_cQuery += " AND SP8.P8_DATAAPO	BETWEEN '"+ DTOS( MV_PAR02 ) +"' AND '"+ DTOS( MV_PAR03 ) +"' "
		EndIF
		_cQuery += " AND SRA.RA_CATFUNC	IN "+ FormatIn( RTrim( MV_PAR06 ) , ";" )
		_cQuery += " AND SRA.RA_SITFOLH	IN "+ FormatIn( RTrim( MV_PAR07 ) , ";" )
	EndIF
	
	_cQuery += " ORDER BY FILIAL, SETOR, MAT, DATA_APO, DATA_REG, HORA "
	_cQuery := ChangeQuery(_cQuery)
	MPSysOpenQuery(_cQuery,_cAlias)
	
	_nAtuReg := 0
	_nTotReg	:= 0
	
	(_cAlias)->( DBGoTop() )
	(_cAlias)->( DBEval( {|| _nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua(_nTotReg)
	
	While (_cAlias)->(!Eof())
		
		_nAtuReg++
		IncProc( "Processando... ["+ StrZero( _nAtuReg , 9 ) +"] de ["+ StrZero( _nTotReg , 9 ) +"]." )
		
		aAdd( _aDados , {	(_cAlias)->FILIAL		,;
							(_cAlias)->SETOR			,;
							(_cAlias)->MAT			,;
							(_cAlias)->NOME			,;
							DTOC( STOD(	(_cAlias)->DATA_APO ) )	,;
							DTOC( STOD(	(_cAlias)->DATA_REG ) )	,;
							(_cAlias)->HORA			,;
							(_cAlias)->ORDEM			,;
							(_cAlias)->APONTADA		,;
							(_cAlias)->TURNO			,;
							DTOC( STOD(	SUBSTR( (_cAlias)->PER_APONTA , 1 , 8 ) ) ) +" - "+ DTOC( STOD( SUBSTR( (_cAlias)->PER_APONTA , 9 , 8 ) ) ) ,;
							UsrRetName(	(_cAlias)->USUARIO )		,;
							DTOC( STOD(	(_cAlias)->DATA_INC ) )	,;
							SUBSTR( (_cAlias)->HORA_INC , 1 , 2 ) +":"+ SUBSTR( (_cAlias)->HORA_INC , 3 , 2 ) ,;
							(_cAlias)->MOTIVO		})
		
		(_cAlias)->( DBSkip() )
	EndDo
	(_cAlias)->(DBCloseArea)
Next _nI

If Empty(_aDados)
	FWAlertInfo("N�o foram encontrados registros para exibir! Verifique os par�metros e tente novamente.","RPON00503")
	Return
Else
	If MV_PAR08 == 1
		U_ITListBox( TITULO , _aCabecx , _aDados , .T. )
	Else
		LjMsgRun( "Imprimindo os dados..." , "Aguarde!" , {|| RPON005PRT( _aCabec , _aColPos , _aColAjs , _aDados ) } )
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa----------: RPON005PRT
Autor-------------: Alexandre Villar
Data da Criacao---: 28/04/2014
Descri��o---------: Chamada de Impressao de Relat�rio dos dados de marca��o de Ponto manual
Parametros--------: _aCabec	- Cabe�alho do Relat�rio
------------------: _aColPos	- Posicionamento das Colunas
------------------: _aColAjs	- Ajuste de posicionamento dos conte�dos
------------------: _aDados	- Dados do Relat�rio
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RPON005PRT(_aCabec As Array,_aColPos As Array,_aColAjs As Array,_aDados As Array)

Local _aDadTot	:= {} As Array
Local _aColTot	:= { 0050 , 1600 , 2000 } As Array
Local _nLinha	:= 300 As Numeric
Local _nTotCol	:= Len(_aCabec) As Numeric
Local _nTotMat	:= 0 As Numeric
Local _cTotMat	:= "" As Character
Local _nI		:= 0 As Numeric
Local _nX		:= 0 As Numeric
Local _nCont	:= 0 As Numeric
Local _nContot	:= 0 As Numeric
Local _nConFun	:= 0 As Numeric
Local _nLimPag	:= 2300 As Numeric
Local _cFilAux	:= "" As Character
Local _lIniPag	:= .T. As Logical
Local _oPrint		:= Nil As Object
Local _oFont01	:= TFont():New( "Arial" , 9 , 14 ,.F.,.T.,,.T.,,.T.,.F.) As Object
Local _oFont02	:= TFont():New( "Arial" , 9 , 08 ,.F.,.T.,,.T.,,.T.,.F.) As Object
Local _oFont03	:= TFont():New( "Arial" , 9 , 08 ,.F.,.F.,,.T.,,.T.,.F.) As Object

If Empty(_aDados)
	FWAlertInfo("N�o foram e_nContradas marca��es manuais para impress�o do relat�rio! Verifique os par�metros e tente novamente.","RPON00504")
	Return
EndIf

_oPrint := TMSPrinter():New( TITULO )
_oPrint:Setup()
_oPrint:SetLandscape()
_oPrint:SetPaperSize(9)

For _nI := 1 To Len(_aDados)

	_cFilAux := _aDados[_nI][01] + _aDados[_nI][02]
	
	While _nI <= Len(_aDados) .And. _cFilAux == _aDados[_nI][01] + _aDados[_nI][02]
		_nCont++
		_nContot++
		If _nLinha > _nLimPag
			_nLinha	:= 300
			_lIniPag	:= .T.
			_oPrint:EndPage()
		EndIf
		
		If _lIniPag
			_oPrint:StartPage()
			_lIniPag	:= .F.
			_nLinha	:= 280
			
			//Insere logo no cabecalho
		
			If File( "LGRL01.BMP" )
				_oPrint:SayBitmap( 070 , _aColPos[01] , "LGRL01.BMP" , 300 , 130 ) // Imagem tem que estar abaixo do RootPath
			EndIf
			
			_oPrint:Say( 080 , 1000 , TITULO +" ( "+ DtoC(Date()) +" - "+ Time() +")" , _oFont01 )   //Nome
			_oPrint:Say( 140 , 0500 , "[Filtros] Per�odo: "+ DTOC( MV_PAR02 ) +" - "+ DTOC( MV_PAR03 ) +" | Filiais: "+ AllTrim( MV_PAR01 ) +" | Categorias: "+ AllTrim( MV_PAR06 ) +" | Sit. Folha: "+ AllTrim( MV_PAR07 ) , _oFont02 )
			_oPrint:Say( 180 , 0500 , "[Filial/Setor] "+ _aDados[_nI][01] +"/"+ _aDados[_nI][02] +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+_aDados[_nI][01],"ZZM_DESCRI") ) +" / "+ AllTrim( Posicione("ZAK",1,xFilial("ZAK")+_aDados[_nI][02],"ZAK_DESCRI") ) , _oFont02 )
			_oPrint:Line( 260 , 0 , 260 , 5000 )
			
			_nLinha 	+= 050

			For _nX := 1 To _nTotCol
				_oPrint:Say( _nLinha , _aColPos[_nX] , _aCabec[_nX] , _oFont02 )
			Next _nX
			_nLinha += 050
		EndIf
		
		For _nX := 1 To _nTotCol
			_oPrint:Say( _nLinha , _aColPos[_nX] + _aColAjs[_nX] , _aDados[_nI][_nX+2] , _oFont03 )
		Next _nX
		
		If _cTotMat <> _aDados[_nI][03]
			_cTotMat := _aDados[_nI][03]
			_nTotMat++
			_nConFun++
		EndIF
		
		_nLinha += 030
		
		If _nLinha > _nLimPag
			_nLinha	:= 300
			_lIniPag	:= .T.
			_oPrint:EndPage()
		EndIf
		
	_nI++
	EndDo
	_nI--
	
	If _nLinha > _nLimPag
		_nLinha	:= 300
		_lIniPag	:= .T.
		_oPrint:EndPage()
	EndIf
	
	If _lIniPag
		_oPrint:StartPage()
		_lIniPag	:= .F.
		_nLinha	:= 300
		
		//Insere logo no cabecalho
		If File( "LGRL01.BMP" )
			_oPrint:SayBitmap( 070 , _aColPos[01] , "LGRL01.BMP" , 300 , 130 ) // Imagem tem que estar abaixo do RootPath
		EndIf
		
		_oPrint:Say( 080 , 1000 , TITULO +" ( "+ DtoC(Date()) +" - "+ Time() +")" , _oFont01 )
		_oPrint:Say( 140 , 0500 , "[Filtros] Per�odo: "+ DTOC( MV_PAR02 ) +" - "+ DTOC( MV_PAR03 ) +" | Filiais: "+ AllTrim( MV_PAR01 ) +" | Categorias: "+ AllTrim( MV_PAR06 ) +" | Sit. Folha: "+ AllTrim( MV_PAR07 ) , _oFont02 )
		_oPrint:Say( 180 , 0500 , "[Filial/Setor] "+ _aDados[_nI][01] +"/"+ _aDados[_nI][02] +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+_aDados[_nI][01],"ZZM_DESCRI") ) +" / "+ AllTrim( Posicione("ZAK",1,xFilial("ZAK")+_aDados[_nI][02],"ZAK_DESCRI") ) , _oFont02 )
		_oPrint:Line( 260 , 0 , 260 , 5000 )
	EndIf

	_oPrint:Line( _nLinha + 020 , 0 , _nLinha + 020 , 5000 )
	_oPrint:Line( _nLinha + 021 , 0 , _nLinha + 021 , 5000 )
	_oPrint:Line( _nLinha + 022 , 0 , _nLinha + 022 , 5000 )	
	_nLinha += 030
	_oPrint:Say( _nLinha , _aColPos[01] , "Total de marca��es manuais do Setor: "+ AllTrim( Transform( _nCont , "@E 999,999,999,999" ) ) + Space(20) +"Total de funcion�rios do Setor com marca��es manuais: "+ AllTrim( Transform( _nTotMat , "@E 999,999,999,999" ) ) , _oFont02 )
	_nLinha += 030
	_oPrint:Line( _nLinha + 020 , 0 , _nLinha + 020 , 5000 )
	_oPrint:Line( _nLinha + 021 , 0 , _nLinha + 021 , 5000 )
	_oPrint:Line( _nLinha + 022 , 0 , _nLinha + 022 , 5000 )
	
	aAdd( _aDadTot , {	"Filial/Setor: "+	_aDados[_nI][01] +"/"+ _aDados[_nI][02] +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+_aDados[_nI][01],"ZZM_DESCRI") ) +" / "+ AllTrim( Posicione("ZAK",1,xFilial("ZAK")+_aDados[_nI][02],"ZAK_DESCRI") ) ,;
						"Marca��es: "+		StrZero( _nCont		, 9 )	,;
						"Funcion�rios: "+	StrZero( _nTotMat	, 9 )	})
	
	If _nLinha > _nLimPag
		_nLinha	:= 300
		_lIniPag	:= .T.
		_oPrint:EndPage()
	EndIf
	
	_nCont	:= 0
	_nTotMat	:= 0
	
	IF _nI < Len(_aDados)
		_nLinha += 3000
	EndIF
Next _nI

_oPrint:EndPage()
_oPrint:StartPage()
	
_nLinha	:= 300

//Insere logo no cabecalho
If File( "LGRL01.BMP" )
	_oPrint:SayBitmap( 070 , _aColPos[01] , "LGRL01.BMP" , 300 , 130 ) // Imagem tem que estar abaixo do RootPath
EndIf

_oPrint:Say( 080 , 1000 , TITULO +" ( "+ DtoC(Date()) +" - "+ Time() +")" , _oFont01 )   //Nome
_oPrint:Say( 140 , 0500 , "[Filtros] Per�odo: "+ DTOC( MV_PAR02 ) +" - "+ DTOC( MV_PAR03 ) +" | Filiais: "+ AllTrim( MV_PAR01 ) +" | Categorias: "+ AllTrim( MV_PAR06 ) +" | Sit. Folha: "+ AllTrim( MV_PAR07 ) , _oFont02 )
_oPrint:Say( 180 , 0500 , "[Resumo geral do Relat�rio] Todos os Setores"  , _oFont02 )
_oPrint:Line( 260 , 0 , 260 , 5000 )

For _nI := 1 To Len( _aDadTot )
	If _nLinha > _nLimPag
		_nLinha	:= 300
		_lIniPag	:= .T.
		_oPrint:EndPage()
	EndIf
	
	If _lIniPag
		_oPrint:StartPage()
		_lIniPag	:= .F.
		_nLinha	:= 300
		
		//Insere logo no cabecalho
		If File( "LGRL01.BMP" )
			_oPrint:SayBitmap( 070 , _aColPos[01] , "LGRL01.BMP" , 300 , 130 ) // Imagem tem que estar abaixo do RootPath
		EndIf
		
		_oPrint:Say( 080 , 1000 , TITULO +" ( "+ DtoC(Date()) +" - "+ Time() +")" , _oFont01 )
		_oPrint:Say( 140 , 0500 , "[Filtros] Per�odo: "+ DTOC( MV_PAR02 ) +" - "+ DTOC( MV_PAR03 ) +" | Filiais: "+ AllTrim( MV_PAR01 ) +" | Categorias: "+ AllTrim( MV_PAR06 ) +" | Sit. Folha: "+ AllTrim( MV_PAR07 ) , _oFont02 )
		_oPrint:Say( 180 , 0500 , "[Resumo geral do Relat�rio] Todos os Setores"  , _oFont02 )
		_oPrint:Line( 260 , 0 , 260 , 5000 )
	EndIf
	
	For _nX := 1 To Len( _aColTot )
		_oPrint:Say( _nLinha , _aColTot[_nX] , _aDadTot[_nI][_nX] , _oFont03 )
	Next _nX

	_nLinha += 030
Next _nI

If _nLinha > _nLimPag
	_nLinha	:= 300
	_lIniPag	:= .T.
	_oPrint:EndPage()
EndIf

_nLinha += 050

If _lIniPag
	_oPrint:StartPage()
	_lIniPag	:= .F.
	_nLinha	:= 300
	
	//Insere logo no cabecalho
	If File( "LGRL01.BMP" )
		_oPrint:SayBitmap( 070 , _aColPos[01] , "LGRL01.BMP" , 300 , 130 ) // Imagem tem que estar abaixo do RootPath
	EndIf
	
	_oPrint:Say( 080 , 1000 , TITULO +" ( "+ DtoC(Date()) +" - "+ Time() +")" , _oFont01 )
	_oPrint:Say( 140 , 0500 , "[Filtros] Per�odo: "+ DTOC( MV_PAR02 ) +" - "+ DTOC( MV_PAR03 ) +" | Filiais: "+ AllTrim( MV_PAR01 ) +" | Categorias: "+ AllTrim( MV_PAR06 ) +" | Sit. Folha: "+ AllTrim( MV_PAR07 ) , _oFont02 )
	_oPrint:Say( 180 , 0500 , "[Resumo geral do Relat�rio] Todos os Setores"  , _oFont02 )
	_oPrint:Line( 260 , 0 , 260 , 5000 )
EndIf

_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++ ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 007

_oPrint:Say( _nLinha	, _aColPos[01]		, "[Totais do Relat�rio] "									, _oFont01 )
_oPrint:Say( _nLinha	, _aColTot[02]+030	, AllTrim( Transform( _nContot , "@E 999,999,999,999" ) )	, _oFont01 )
_oPrint:Say( _nLinha	, _aColTot[03]+050	, AllTrim( Transform( _nConFun , "@E 999,999,999,999" ) )	, _oFont01 )

_nLinha += 060

_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++ ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++

_oPrint:Preview()

Return

/*
===============================================================================================================================
Programa----------: RPON005P
Autor-------------: Alexandre Villar
Data da Criacao---: 21/02/2014
Descri��o---------: Rotina de valida��o dos par�metros durante o preenchimento.
Parametros--------: _nOpc	: Op��o de Valida��o
Retorno-----------: _lRet	: Define se o conte�do passou pela valida��o
===============================================================================================================================
*/
User Function RPON005P(_nOpc As Numeric)

Local _lRet			:= .T. As Logical//Se retornar .F. nao deixa sair do campo
Local _cNomeVar		:= ReadVar() As Character
Local _xVarAux		:= &(_cNomeVar) As Variant
Local _aArea		:= FWGetArea() As Array
Local _cEmpAux		:= cEmpAnt As Character
Local _aAcesso		:= FWEmpLoad(.F.) As Array
Local _aDadAux		:= {} As Array
Local _nI			:= 0 As Numeric
Local _nX			:= 0 As Numeric

Do Case
	Case _nOpc == 1// "Filiais Consideradas ?"
		//-- Verifica se o campo esta vazio --//
		If Empty(_xVarAux)
			FWAlertInfo("� obrigat�rio informar o filtro de Filiais, clique em 'selecionar todas' para utilizar todas as Filiais.","RPON00505")
			_lRet := .F.
		//-- Verifica se o campo foi preenchido com conteudo valido --//
		Else
			_aDadAux := U_ITLinDel( AllTrim(_xVarAux) , ";" )
			
			For _nI := 1 To Len(_aDadAux)
				_lRet := .F.
				For _nX := 1 To Len(_aAcesso)
					If _aDadAux[_nI] == _aAcesso[_nX][03]
						_lRet := .T.
					EndIf
				Next _nX
				
				If !_lRet
					FWAlertInfo("O usu�rio n�o tem acesso �s 'Filiais' informadas! Verifique os dados digitados.","RPON00506")
					Exit
				EndIf
				
				_lRet := .F.
				
				DBSelectArea("SM0")
				SM0->( DBGoTop() )

				While SM0->(!Eof())
					If SM0->M0_CODIGO == _cEmpAux .And. ALLTRIM(SM0->M0_CODFIL) == _aDadAux[_nI]
						_lRet := .T.
						Exit
					EndIf
					SM0->( DBSkip() )
				EndDo
				
				If !_lRet
					FWAlertInfo("As 'Filiais' informadas n�o s�o v�lidas! Verifique os dados digitados.","RPON00507")
					Exit
				EndIf
			Next _nI
		EndIf

	Case _nOpc == 2 //"Categorias a Imp. ?"
		If Empty(_xVarAux)
			FWAlertInfo("� obrigat�rio informar o filtro de Categorias Funcionais, clique em 'selecionar todas' para utilizar todas as Categorias.","RPON00708")
			_lRet := .F.
		Else
			_aDadAux := U_ITLinDel( AllTrim(_xVarAux) ,, 1 )
			For _nI := 1 To Len(_aDadAux)
				If _aDadAux[_nI] == "*"
					_nI++
					Loop
				EndIf
				
				DBSelectArea("SX5")
				SX5->( DBSetOrder(1) )
				SX5->( DBGoTop() )
	
				If !SX5->( DBSeek( xFilial("SX5") + "28" + _aDadAux[_nI] ) )
					FWAlertInfo("As 'Categorias Funcionais' informadas n�o s�o v�lidas! Verifique os dados digitados.","RPON00508")
					_lRet := .F.
					Exit
				EndIf
			Next _nI
		EndIf
	
	Case _nOpc == 3 //"Situa��es ?"
		If EMPTY(_xVarAux)
			&(_cNomeVar) := " "
		Else
			_aDadAux := U_ITLinDel( _xVarAux ,, 1 )
			For _nI := 1 To Len(_aDadAux)
				If _aDadAux[_nI] == "*"
					Loop
				Else
					_lRet := .F.
					
					DBSelectArea("SX5")
					SX5->( DBSetOrder(1) )
					SX5->( DBGoTop() )
					SX5->( DBSeek( xFilial("SX5") + "31" ) )
					
					While SX5->(!EOF()) .And. SX5->( X5_FILIAL + X5_TABELA ) == xFilial("SX5") + "31"
						//Posiciona por query para n�o conflitar com sonarcube
						_nrec := SX5->(Recno())
						_cAlias := GetNextAlias()
						BeginSQL alias _cAlias
							SELECT X5_CHAVE CHAVE
							FROM %Table:SX5%
							WHERE D_E_L_E_T_ = ' '
							AND   R_E_C_N_O_ = %exp:_nrec%
						EndSQL

						_cchave := (_cAlias)->CHAVE

						(_cAlias)->(DBCloseArea())

						If AllTrim( _aDadAux[_nI] ) == AllTrim( _cchave )
							_lRet := .T.
							Exit
						EndIf
						SX5->( DBSkip() )
					EndDo
				EndIf
				
				IF !_lRet
					FWAlertInfo("As 'Situa��es na Folha' informadas n�o s�o v�lidas! Verifique os dados digitados.","RPON00509")
					Exit
				EndIF
			Next _nI
		EndIf
EndCase

FWRestArea(_aArea)

Return(_lRet)
