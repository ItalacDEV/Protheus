/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25
Julio Paz     | 02/10/2023 | Chamado 44502. Ajustar rotina para fixar valor de limite de cr�dito para clientes inativados
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
===============================================================================================================================
*/

#Include "Protheus.Ch"
#Include "FWMVCDef.Ch"

#Define		TITULO	"An�lise de Clientes Bloqueados"

/*
===============================================================================================================================
Programa----------: MOMS026
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descri��o---------: Rotina de An�lise do Cadastro de Clientes Inativos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS026()

Local _aInfHelp	:= {}

//===========================================================================
//| Define formato de data para exibi��o nas telas da rotina                |
//===========================================================================
SET DATE FORMAT TO "DD/MM/YYYY"

//===========================================================================
//| Verifica o acesso do usu�rio atual                                      |
//===========================================================================
If U_ITVLDUSR(3)

	Processa( {|| MOMS026INI() } , "Processando..." , "Iniciando o processamento..." )
	
Else

	aAdd( _aInfHelp	, { "Usu�rio sem acesso � rotina de Bloqueio"	, " de Clientes Inativos."	, ""	} )
	aAdd( _aInfHelp	, { "Verifique com a �rea de TI/ERP."			, ""						, ""	} )
	
	U_ITCADHLP( _aInfHelp , "OMS26U" )
	lRet := .F.

EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS026INI
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descri��o---------: Rotina de montagem da tela de processamento
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS026INI()

Local _aParAux		:= {}
Local _aParRet		:= {}
Local _aDados		:= {}
Local _aCpos		:= MOMS026CPS()
Local _aFields		:= {}
Local _cQuery		:= ""
Local cTpPes		:= ''
Local _cCGC			:= ''
Local _cAliasQry	:= GetNextAlias()
Local _nAtuReg		:= 0
Local _nI			:= 0
Local nI			:= 0
Local _lInc			:= .F.
Local _lDtCad		:= .F.
Local _lDtRea		:= .F.

Private oMarkBRW	:= Nil
Private cAliasAux	:= GetNextAlias()
Private _nTotReg	:= 0
Private cDtIni		:= ""
Private _aRegMrk	:= {}

aAdd( _aParAux , { 1 , "Inativo desde"		, Ctod( Space(8) )	, "@!"		, ""				, ""					, "" , 050	, .F. } ) //| 01 |
aAdd( _aParAux , { 1 , "N�o listar redes"	, Space(150)		, "@!"		, ""				, "ACYLST"				, "" , 050	, .F. } ) //| 02 |
aAdd( _aParAux , { 3 , "Tipo de Cliente"	, 1					, { "Pessoa Jur�dica" , "Pessoa F�sica" , "Todos" }		, 50 , ""	, .F. } ) //| 03 |
aAdd( _aParAux , { 3 , "Cliente/Rede"		, 1					, { "Sem Rede" , "Com Rede" , "Todos" }					, 50 , ""	, .F. } ) //| 04 |

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next nI

IF !ParamBox( _aParAux , "Parametriza��o do Relat�rio:" , @_aParRet )

	u_itmsg(  "Opera��o cancelada pelo usu�rio!" , "Aten��o!" , , 1 )
	Return()
	
EndIf

cDtIni	:= DtoS( MV_PAR01 )
cTpPes	:= IIF( MV_PAR03 == 1 , "J" , IIF( MV_PAR03 == 2 , "F" , "" ) )
_credes := alltrim(MV_PAR02)

_cQuery := " SELECT "
_cQuery += "     SA1.A1_COD				AS CLIENTE,"
_cQuery += "     SA1.A1_LOJA			AS LOJA   ,"
_cQuery += "     SA1.A1_NOME			AS NOME   ,"
_cQuery += "     SA1.A1_GRPVEN			AS REDE   ,"
_cQuery += "	 SA1.A1_CGC				AS CGC    ,"
_cQuery += "	 SA1.A1_I_DTCAD			AS DAT_CAD,"
_cQuery += "     SA1.A1_PESSOA			AS TIP_PES,"
_cQuery += "     MAX( SF2.F2_EMISSAO )	AS ULT_FAT,"
_cQuery += "	 SA1.R_E_C_N_O_			AS REGSA1, "
_cQuery += "	 SA1.A1_I_DTREA			AS DT_REAV "	// Data da Reavalia��o
_cQuery += " FROM  "+ RetSqlName("SA1") +" SA1 "
_cQuery += " LEFT JOIN "+ RetSqlName('SF2') +" SF2 ON SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND SF2.D_E_L_E_T_ = ' ' "
_cQuery += " WHERE "
_cQuery += "     SA1.D_E_L_E_T_  = ' ' "
_cQuery += " AND SA1.A1_COD      > '000001' "
_cQuery += " AND SA1.A1_MSBLQL   <> '1' "

_cQuery += IIf(!Empty(cTpPes) , " AND SA1.A1_PESSOA = '"+ cTpPes +"' ","")								//Filtro de pessoa juridica/fisica

If MV_PAR04 == 2 //Para op��o com rede filtra redes e n�o traz os sem rede

	_cQuery += " AND ( SA1.A1_GRPVEN <> '999999' AND SA1.A1_GRPVEN > '000000' ) " 						//Filtro de sem redes
	_cQuery += IIf( !Empty( _credes ) , " AND SA1.A1_GRPVEN NOT IN "+ FORMATIN( _credes , ";" ) , "" ) 	//Filtro de rede de cliente
	
Elseif MV_PAR04 == 1 //Para op��o sem rede filtra todos que tenham alguma rede v�lida

	_cQuery += " AND ( SA1.A1_GRPVEN = '999999' OR SA1.A1_GRPVEN < '000000' ) " 						//filtro de clientes com rede
	_cQuery += IIf( !Empty( _credes ) , " AND SA1.A1_GRPVEN NOT IN "+ FORMATIN( _credes , ";" ) , "" )	//Filtro de rede de cliente
	
Elseif MV_PAR04 == 3 //Para op��o todos s� faz o filtro de redes

	_cQuery += IIf( !Empty( _credes ) , " AND SA1.A1_GRPVEN NOT IN "+ FORMATIN( _credes , ";" ) , "" ) 	//Filtro de rede de cliente
	
Endif

_cQuery += " GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_GRPVEN, SA1.A1_CGC, SA1.A1_I_DTCAD, SA1.A1_PESSOA, SA1.R_E_C_N_O_, SA1.A1_I_DTREA "

_cQuery += " ORDER BY 1,2 "

If Select(_cAliasQry) > 0
	(_cAliasQry)->( DBCloseArea() )
EndIf

ProcRegua(0)
IncProc( "Lendo registros..." )
DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasQry , .T. , .F. )

DBSelectArea(_cAliasQry)
(_cAliasQry)->( DBGoTop() )
COUNT TO _nTotReg

If _nTotReg <= 0

	(_cAliasQry)->( DBCloseArea() )
	u_itmsg(  "N�o foram encontrados Clientes Inativos no per�odo de acordo com os par�metros informados!" ,"Aten��o!" ,,1 )
	Return()
	
EndIf

If select(cAliasAux) > 0
	(cAliasAux)->(Dbclosearea())
Endif

_otemp := FWTemporaryTable():New( cAliasAux, _aCpos )

_otemp:Create()

DBSelectArea( cAliasAux )
ProcRegua(_nTotReg)

(_cAliasQry)->( DBGoTop() )
While (_cAliasQry)->( !Eof() )

	_lDtRea := .F.

	If (_cAliasQry)->TIP_PES == 'J'
	
		_cCGC	:= SubStr( (_cAliasQry)->CGC , 1 , 8 )
		_lInc	:= .T.
		_lDtCad	:= .F.
		_aDados	:= {}
		
		While (_cAliasQry)->(!Eof()) .And. _cCGC == SubStr( (_cAliasQry)->CGC , 1 , 8 )
			
			_nAtuReg++
			IncProc( "Analisando registros... ["+ StrZero( _nAtuReg , 6 ) +"]" )
			
			aAdd( _aDados , {	(_cAliasQry)->CLIENTE						,;
								(_cAliasQry)->LOJA							,;
								Capital( AllTrim( (_cAliasQry)->NOME ) )	,;
								Capital( AllTrim( Posicione( "ACY" , 1 , xFilial("ACY") + (_cAliasQry)->REDE , "ACY_DESCRI" ) ) )	,;
								MOMS026CGC( (_cAliasQry)->CGC )				,;
								StoD( (_cAliasQry)->DAT_CAD )				,;
								StoD( (_cAliasQry)->ULT_FAT )				,;
								StoD( (_cAliasQry)->DT_REAV )				,;	// Data da Reavalia��o
								(_cAliasQry)->REGSA1						})
			
			If StoD( (_cAliasQry)->DAT_CAD ) < MV_PAR01
				_lDtCad	:= .T.
			EndIf
			
			If StoD( (_cAliasQry)->ULT_FAT ) > MV_PAR01
				_lInc	:= .F.
			EndIf
			// Faz valida��o da data de reavalia��o
			If !Empty( (_cAliasQry)->DT_REAV )
				If StoD( (_cAliasQry)->DT_REAV ) > MV_PAR01
					_lDtRea := .T.
				EndIf
			EndIf

		(_cAliasQry)->( DBSkip() )
		EndDo
		
		If _lInc .And. _lDtCad .And. !_lDtRea
			
			For _nI := 1 To Len( _aDados )
				
				(cAliasAux)->( RecLock( cAliasAux , .T. ) )
				
				(cAliasAux)->CLIENTE	:= _aDados[_nI][01]
				(cAliasAux)->LOJA		:= _aDados[_nI][02]
				(cAliasAux)->NOME 		:= _aDados[_nI][03]
				(cAliasAux)->REDE		:= _aDados[_nI][04]
				(cAliasAux)->CGC		:= _aDados[_nI][05]
				(cAliasAux)->DAT_CAD	:= _aDados[_nI][06]
				(cAliasAux)->ULT_FAT	:= _aDados[_nI][07]
				(cAliasAux)->DT_REAV	:= _aDados[_nI][08]		// Data da Reavalia��o
				(cAliasAux)->REGSA1		:= _aDados[_nI][09]
				
				(cAliasAux)->( MSUnLock() )
				
			Next _nI
			
		EndIf
	
	Else
		
		_nAtuReg++
		IncProc( "Analisando... ["+ StrZero( _nAtuReg , 6 ) +"] de ["+ StrZero( _nTotReg , 6 ) +"]" )

		// Faz valida��o da data de reavalia��o
		If !Empty( (_cAliasQry)->DT_REAV )
			If StoD( (_cAliasQry)->DT_REAV ) > MV_PAR01
				_lDtRea := .T.
			EndIf
		EndIf

		If StoD( (_cAliasQry)->ULT_FAT ) < MV_PAR01 .AND. StoD( (_cAliasQry)->DAT_CAD ) < MV_PAR01 .And. ! _lDtRea // _DtRea
			
			(cAliasAux)->( RecLock( cAliasAux , .T. ) )
			
			(cAliasAux)->CLIENTE	:= (_cAliasQry)->CLIENTE
			(cAliasAux)->LOJA		:= (_cAliasQry)->LOJA
			(cAliasAux)->NOME 		:= Capital( AllTrim( (_cAliasQry)->NOME ) )
			(cAliasAux)->REDE		:= Capital( AllTrim( Posicione( "ACY" , 1 , xFilial("ACY") + (_cAliasQry)->REDE , "ACY_DESCRI" ) ) )
			(cAliasAux)->CGC		:= MOMS026CGC( (_cAliasQry)->CGC )
			(cAliasAux)->DAT_CAD	:= StoD( (_cAliasQry)->DAT_CAD )
			(cAliasAux)->ULT_FAT	:= StoD( (_cAliasQry)->ULT_FAT )
			(cAliasAux)->DT_REAV	:= StoD( (_cAliasQry)->DT_REAV )	// Data da Reavalia��o
			(cAliasAux)->REGSA1		:= (_cAliasQry)->REGSA1
			
			(cAliasAux)->( MSUnLock() )
		
		EndIf
		
		(_cAliasQry)->( DBSkip() )
		
	EndIf
	
EndDo

(_cAliasQry)->( DBCloseArea() )

aAdd( _aFields , { "Cliente"			, {|| (cAliasAux)->CLIENTE }  		, "C" , "@!" , 0 , TamSX3("A1_COD")[01]		, 0 } )
aAdd( _aFields , { "Loja"				, {|| (cAliasAux)->LOJA }			, "C" , "@!" , 0 , TamSX3("A1_LOJA")[01]	, 0 } )
aAdd( _aFields , { "Nome"				, {|| (cAliasAux)->NOME }			, "C" , "@!" , 0 , TamSX3("A1_NOME")[01]-20	, 0 } )
aAdd( _aFields , { "Rede"				, {|| (cAliasAux)->REDE }			, "C" , "@!" , 0 , TamSX3("ACY_DESCRI")[01]	, 0 } )
aAdd( _aFields , { "CPF/CNPJ"			, {|| (cAliasAux)->CGC }  			, "C" , "@!" , 0 , TamSX3("A1_CGC")[01]		, 0 } )
aAdd( _aFields , { "Dt. Cadastro"		, {|| DtoC((cAliasAux)->DAT_CAD) }	, "C" , "@!" , 0 , 10						, 0 } )
aAdd( _aFields , { "Ult. Compra"		, {|| DtoC((cAliasAux)->ULT_FAT) }	, "C" , "@!" , 0 , 10						, 0 } )
aAdd( _aFields , { "Dt. Reavalia��o"	, {|| DtoC((cAliasAux)->DT_REAV) }	, "C" , "@!" , 0 , 10						, 0 } )	// Data da Reavalia��o

oMarkBRW := FWMarkBrowse():New()		   												// Inicializa o Browse

oMarkBRW:SetAlias( cAliasAux )			   												// Define Alias que ser� a Base do Browse
oMarkBRW:SetDescription( "Clientes Inativos a partir de: "+ DtoC( StoD( cDtIni ) ) +" (Clientes sem faturamento ap�s a data)" )	// Define o titulo do browse de marcacao
oMarkBRW:SetFieldMark( "MARCA" )														// Define o campo que sera utilizado para a marca��o
oMarkBRW:SetMenuDef( 'MOMS026' )														// For�a a utiliza��o do menu da rotina atual
oMarkBRW:SetAllMark( {|| oMarkBRW:AllMark() , MOMS026MRK(.T.) } )						// A��o do Clique no Header da Coluna de Marca��o
oMarkBRW:SetAfterMark( {|| MOMS026MRK(.F.) } )											// A��o na marca��o/desmarca��o do registro
oMarkBRW:SetFields( _aFields )													 		// Campos para exibi��o
oMarkBRW:AddButton( "Confirmar" , {|| Processa( {|| U_MOMS026B() } , "Bloqueando Clientes..." , "Aguarde!" ) } ,, 4 )
oMarkBRW:DisableConfig()

oMarkBRW:Activate()																		// Ativacao da classe

(cAliasAux)->( DBCloseArea() )

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descri��o---------: Rotina de constru��o do menu
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina Title 'Consultar' Action 'U_MOMS026R( (cAliasAux)->REGSA1 )' OPERATION 2 ACCESS 0

Return( aRotina )

/*
===============================================================================================================================
Programa----------: MOMS026CNS
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descri��o---------: Rotina de consulta do cadastro completo do Cliente
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS026R( nRegSA1 )

Private cCadastro := "Cadastro do Cliente"

DBSelectArea("SA1")
SA1->( DBGoTo(nRegSA1) )
AxVisual( "SA1" , nRegSA1 , 2 )

Return()

/*
===============================================================================================================================
Programa----------: MOMS026CPS
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descri��o---------: Define a cria��o de campos para exibi��o da an�lise
Parametros--------: Nenhum
Retorno-----------: aRet - Campos que ser�o criados e exibidos na tela
===============================================================================================================================
*/
Static Function MOMS026CPS( _nTotReg )

Local _aCpos := {}

aAdd( _aCpos , { "MARCA"		, "C" , 1							, 0 } )
AAdd( _aCpos , { "CLIENTE"		, "C" , TamSX3("A1_COD")[01]		, 0 } )
AAdd( _aCpos , { "LOJA"			, "C" , TamSX3("A1_LOJA")[01]		, 0 } )
AAdd( _aCpos , { "NOME"			, "C" , TamSX3("A1_NOME")[01]		, 0 } )
AAdd( _aCpos , { "REDE"			, "C" , TamSX3("ACY_DESCRI")[01]	, 0 } )
AAdd( _aCpos , { "CGC"			, "C" , 18							, 0 } )
AAdd( _aCpos , { "DAT_CAD"		, "D" , 8							, 0 } )
AAdd( _aCpos , { "ULT_FAT"		, "D" , 8							, 0 } )
AAdd( _aCpos , { "DT_REAV"		, "D" , 8							, 0 } )	// Data da Reavalia��o
AAdd( _aCpos , { "REGSA1"		, "N" , 9							, 0 } )

Return( _aCpos )

/*
===============================================================================================================================
Programa----------: MOMS026B
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descri��o---------: Processa o Bloqueio dos Clientes Selecionados
Parametros--------: Nenhum
Retorno-----------: aRet - Campos que ser�o criados e exibidos na tela
===============================================================================================================================
*/
User Function MOMS026B()

Local _nI		:= 0
Local _nTotReg	:= Len(_aRegMrk)
Local _cCodUsr	:= RetCodUsr()
Local _cNumLote	:= ""
Local _cMsgBlq	:= ""
Local _nValCbLq := U_ITGETMV( 'IT_VALCBLQ',20.00 ) // Valor de limite de cr�dito de bloqueio.

_cMsgBlq := "Bloqueio Autom�tico: "+ CRLF
_cMsgBlq += "Cliente inativo entre "+ DtoC( StoD( cDtIni ) ) +" e "+ DtoC( Date() ) +"]"+ CRLF
_cMsgBlq += "Usu�rio: "+ Capital( AllTrim( UsrFullName(_cCodUsr) ) ) +" / "+ DtoC( Date() ) +" "+ Time()

ProcRegua( _nTotReg )

Begin Transaction

_cNumLote := U_ITInLote( "Z00" , "001" )

If _nTotReg > 0

	For _nI := 1 To _nTotReg
		
		IncProc( "Processando... ["+ StrZero( _nI , 6 ) +"] de ["+ StrZero( _nTotReg , 6 ) +"]" )
		
		DBSelectArea("SA1")
		SA1->( DBGoTo( _aRegMrk[_nI][01] ) )
		
		SA1->( RecLock( "SA1" , .F. ) )
        SA1->A1_MSBLQL	:= "1"
        SA1->A1_I_ACRED	:= _cMsgBlq
        SA1->A1_LC      := _nValCbLq // Valor de limite de cr�dito de bloqueio.
		SA1->( MsUnLock() )
	
		//===========================================================================
		//| Grava o Item processado no Lote                                         |
		//===========================================================================
		U_ITGrLote( "Z03" , _cNumLote , { { SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA , StoD( cDtIni ) , Date() , "1" } } , "1" )
		
		If SA1->A1_PESSOA == 'J'
			
			_cQuery := " UPDATE "+ RetSqlName('SA1') +" SA1 "
			_cQuery += " SET SA1.A1_MSBLQL = '1', " 
			_cQuery += "     SA1.A1_LC = " + AllTrim(Str(_nValCbLq,16,2)) + " "
			_cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' AND SA1.A1_PESSOA = 'J' AND SUBSTR( SA1.A1_CGC , 1 , 8 ) = '"+ SubStr( SA1->A1_CGC , 1 , 8 ) +"' "
			
			If TCSqlExec( _cQuery ) < 0
			    //								|....:....|....:....|....:....|....:....|
				ShowHelpDlg( 'Aten��o!' ,	{	'Falhou ao processar o bloqueio de todas '			,;
												' as Lojas do Cliente sem movimenta��o!'			}, 2 ,;
											{	'Verifique o cadastro do Cliente: '+ SA1->A1_COD	,;
												' Loja: '+ SA1->A1_LOJA +' e demais lojas.'			}, 2  )
				
			EndIf
			
		EndIf
			
	Next _nI
	
	U_ITFnLote( "Z00" , _cNumLote )
	
	u_itmsg(  '['+ cValToChar( Len( _aRegMrk ) ) +'] clientes processados com sucesso!' , 'Conclu�do!' ,,2 )
	
Else
	
	//===========================================================================
	//| Exclui o Lote que n�o teve registros processados.                       |
	//===========================================================================
	DBSelectArea("Z00")
	IF Z00->( DBSeek( xFilial("Z00") + _cNumLote ) )
		
		Z00->( RecLock( "Z00" , .F. ) )
		Z00->( DBDelete() )
		Z00->( MsUnlock() )
		
	EndIF
	
	u_itmsg(  'N�o foram selecionados registros para processar!' , 'Aten��o!' ,,1 )
	
EndIf

End Transaction

CloseBrowse()

Return()

/*
===============================================================================================================================
Programa----------: MOMS026CGC
Autor-------------: Alexandre Villar
Data da Criacao---: 02/06/2014
Descri��o---------: Formata��o da M�scara para CPF/CNPJ
Parametros--------: Nenhum
Retorno-----------: aRet - Campos que ser�o criados e exibidos na tela
===============================================================================================================================
*/
Static Function MOMS026CGC( cCGCAux )

Local cRet	:= ""
Local cAux	:= AllTrim( cCGCAux )

IF Len( cAux ) > 11

	cAux := PadL( cAux , 14 , "0" )
	cRet := Transform( cAux , "@R! NN.NNN.NNN/NNNN-99" )
	
Else

	cAux := PadL( cAux , 11 , "0" )
	cRet := Transform( cAux , "@R 999.999.999-99" )
	
EndIF

Return( cRet )

/*
===============================================================================================================================
Programa----------: MOMS026C
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 21/10/2015
Descri��o---------: Rotina para montar consulta de redes de cliente
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS026C()

Local _cRet		:= ''
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _cTitAux	:= 'Redes de clientes'
Local _aDados	:= {}
Local _nI		:= 0

_cQuery := " SELECT ACY_GRPVEN, 
_cQuery += " ACY_DESCRI FROM "
_cQuery += RETSQLNAME('ACY') +" ACY 
_cQuery += " WHERE " + RETSQLCOND('ACY') 
_cQuery += " AND ACY.ACY_FILIAL = '" + xFilial("SF5") + "'"
_cQuery += " ORDER BY ACY.ACY_GRPVEN"

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .F. , .T. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )

//carrega documentos v�lidos na matriz
While (_cAlias)->( !Eof() )

	aAdd( _aDados , { .F. , (_cAlias)->ACY_GRPVEN, (_cAlias)->ACY_DESCRI  } )
	
	(_cAlias)->( DBSkip() )
	
EndDo

(_cAlias)->( DBCloseArea() )

//Se tiver documentos v�lidos cria a consulta
If len(_aDados) > 0

	If U_ITListBox( _cTitAux , { '__' , 'C�digo', 'Descri��o' } , @_aDados , .F. , 2 , 'Selecione as redes para n�o listar: ' )
		
		For _nI := 1 To Len( _aDados )
		
			If _aDados[_nI][01]
	
				_cRet += AllTrim( _aDados[_nI][02] ) +';'
	
			EndIf
			
			If len(_cret) > 70
		
				alert("M�ximo de redes a selecionar ultrapassado, selecione 10 ou menos redes")
			
				_cRet := ""
				
				_nI := Len( _aDados ) + 1
				
			Endif		
	
		Next _nI
	
		&( ReadVar() ) := SubStr( _cRet , 1 , Len(_cRet) - 1 )
		
	Endif

//se n�o tiver redes cadastradas alerta e sai
Else
	
	u_itmsg("N�o h� redes cadastradas!","Aten��o",,1)
	
Endif

Return( .T. )

/*
===============================================================================================================================
Programa----------: MOMS026MRK
Autor-------------: Alexandre Villar
Data da Criacao---: 01/03/2016
Descri��o---------: Rotina que controla a marca��o dos registros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS026MRK( _lSetAll )

Local _nPosAux := 0

If _lSetAll
	
	If oMarkBRW:IsMark()
		
		_aRegMrk := {}
		
		(cAliasAux)->( DBGoTop() )
		While (cAliasAux)->( !Eof() )
		
			aAdd( _aRegMrk , { (cAliasAux)->REGSA1 } )
		
		(cAliasAux)->( DBSkip() )
		EndDo
		
		(cAliasAux)->( DBGoTop() )
		
	Else
		_aRegMrk := {}
	EndIf
	
Else
	
	If oMarkBRW:IsMark()
		
		If aScan( _aRegMrk , {|x| x[1] == (cAliasAux)->REGSA1 } ) == 0
			aAdd( _aRegMrk , { (cAliasAux)->REGSA1 } )
		EndIf
		
	Else
		
		If ( _nPosAux := aScan( _aRegMrk , {|x| x[1] == (cAliasAux)->REGSA1 } ) ) <> 0
		
			aDel( _aRegMrk , _nPosAux )
			aSize( _aRegMrk , Len( _aRegMrk ) -1 )
			
		EndIf
		
	EndIf
	
EndIf

Return()
