/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 20/07/2015 | Atualiza��o da rotina para melhoria de controles de grava��o e altera��o. Chamado 11001
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#Include "DBTree.Ch"

/*
===============================================================================================================================
Programa----------: ACFG002
Autor-------------: Alexandre Villar
Data da Criacao---: 25/06/2015
===============================================================================================================================
Descri��o---------: Rotina para manuten��o do cadastro de par�metros das rotinas espec�ficas - Chamado 10618
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACFG002()

Local _aCoors 		:= FWGetDialogSize(oMainWnd)
Local _aSize     	:= MsAdvSize(.F.)
Local _aObjects		:= {}
Local _oFontTr		:= TFont():New( "Arial" ,, 14 )//, 08 )
Local _oLbxAux		:= Nil
Local _bChange		:= {|| ACFG002MLB( _oTree:GetCargo() , @_oLbxAux ) }
Local _lAcesso		:= .F.

Private _cCarSeek	:= ''
Private _oDlg		:= Nil
Private _oBar		:= Nil
Private _oTree		:= Nil
Private _oPanel		:= Nil
Private _aChaves	:= {}
Private _aParam		:= {}
Private _aBar		:= {}

_lAcesso := U_ITVACESS( 'ZZL' , 3 , 'ZZL_MNTPAR' , "S" )

If !_lAcesso

//									|....:....|....:....|....:....|....:....|
	ShowHelpDlg( 'Aten��o!' ,	{	'Usu�rio sem acesso � rotina de manuten��o '	,;
									'dos par�metros Italac!'						} , 2 ,;
								{	'Caso necess�rio solicite a manuten��o � '		,;
									'um usu�rio com acesso ou, se necess�rio, '		,;
									'solicite o acesso � �rea de TI/ERP.'			} , 3  )
	
	Return()
	
EndIf

//====================================================================================================
// Monta area onde serao incluidos os paineis
//====================================================================================================
aAdd( _aObjects , { 020 , 100 , .T. , .T. } )
aAdd( _aObjects , { 080 , 100 , .T. , .T. } )
_aInfo   := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 2 , 2 }
_aPosObj := MsObjSize( _aInfo , _aObjects , .T. , .T. )

Define MsDialog _oDlg Title 'Manuten��o dos Par�metros Espec�ficos - Italac' From _aCoors[1],_aCoors[2] To _aCoors[3],_aCoors[4] Pixel

	//====================================================================================================
	// Monta a barra de bot�es da tela
	//====================================================================================================
	_oBar := TBar():New( _oDlg , 25 , 45 , .T. ,,,, .F. )
	
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'FINAL_OCEAN' 		,,,, {|| _oDlg:End()								} , _oBar , 'Sair da Tela'		,, .F. , .F. ) )
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'AVG_IADD'			,,,, {|| ACFG002AMN(1)								} , _oBar , 'Incluir Rotina'	,, .F. , .F. ) )
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'AVG_IPROC'			,,,, {|| ACFG002AMN(2)								} , _oBar , 'Alterar Rotina'	,, .F. , .F. ) )
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'ADICIONAR_001_OCEAN'	,,,, {|| ACFG002APR(1,_oLbxAux) , Eval( _bChange )	} , _oBar , 'Incluir Par�metro'	,, .F. , .F. ) )
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'ALTERA_OCEAN'		,,,, {|| ACFG002APR(2,_oLbxAux) , Eval( _bChange )	} , _oBar , 'Alterar Par�metro'	,, .F. , .F. ) )
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'BMPDEL_OCEAN'		,,,, {|| ACFG002APR(3,_oLbxAux) , Eval( _bChange )	} , _oBar , 'Excluir Par�metro'	,, .F. , .F. ) )
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'TK_FIND_OCEAN'		,,,, {|| ACFG002PES() , Eval( _bChange )			} , _oBar , 'Pesquisar'			,, .F. , .F. ) )
	aAdd( _aBar , TBtnBmp2():New(00,00,45,22, 'PMSPRINT_OCEAN'		,,,, {|| ACFG002REL()								} , _oBar , 'Relat�rio'			,, .F. , .F. ) )
	
	//====================================================================================================
	// Cria o objeto do menu e constr�i a estrutura
	//====================================================================================================
	_oTree := DBTree():New( _aPosObj[01][01]+12 , _aPosObj[01][02] , _aPosObj[01][03] , _aPosObj[01][04] , _oDlg , _bChange ,, .T. , .F. , _oFontTr )
	
	ACFG002MTD()
	
	//====================================================================================================
	// Constr�i o painel para exibi��o dos dados dos par�metros
	//====================================================================================================
	_oPanel  := TPanel():Create( _oDlg , _aPosObj[02][01]+12 , _aPosObj[02][02] ,, _oFontTr , .T. ,,,, _aPosObj[02][04] - _aPosObj[01][04] , _aPosObj[02][03] - 12 , .T. , .T. )
	_aPosPan := FWGetDialogSize( _oPanel )
	
	@_aPosPan[01]+002,_aPosPan[02]+002 	Listbox _oLbxAux Fields	;
										HEADER 	""		 		;
										On DbLCLICK ( Nil )		;
										Size _aPosObj[02][04] - _aPosObj[01][04] - 2 , _aPosObj[02][03] - 14 Of _oPanel Pixel
	
	ACFG002MLB( '0001' , @_oLbxAux )

Activate MsDialog _oDlg CENTERED

Return()

/*
===============================================================================================================================
Programa----------: ACFG002PAR
Autor-------------: Alexandre Villar
Data da Criacao---: 25/06/2015
===============================================================================================================================
Descri��o---------: Rotina que faz a leitura dos par�metros j� cadastrados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aPar - Array contendo a estrutura dos par�metros
===============================================================================================================================
*/
Static Function ACFG002PAR()

Local _aPar		:= {}
Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()

//====================================================================================================
// Monta a consulta de dados dos par�metros e monta estrutura
//====================================================================================================
_cQuery := " SELECT * "
_cQuery += " FROM  "+ RetSqlName('ZP1') +" ZP1 "
_cQuery += " WHERE "+ RetSqlCond('ZP1')
_cQuery += " ORDER BY ZP1.ZP1_MODULO, ZP1.ZP1_GRUPO, ZP1.ZP1_ROTINA "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
While (_cAlias)->( !Eof() ) .And. !Empty( (_cAlias)->ZP1_MODULO )
	
	aAdd( _aPar , {	(_cAlias)->ZP1_MODULO										,;
					U_ITNOMAMB( (_cAlias)->ZP1_MODULO )							,;
					ALLTRIM( X3Combo( "ZP1_GRUPO" , (_cAlias)->ZP1_GRUPO ) )	,;
					(_cAlias)->ZP1_ROTINA										,;
					AllTrim( (_cAlias)->ZP1_DESROT )							,;
					(_cAlias)->ZP1_FILPAR										,;
					(_cAlias)->ZP1_PARAM										,;
					(_cAlias)->ZP1_DESCRI										,;
					ALLTRIM( X3Combo( "ZP1_TIPO" , (_cAlias)->ZP1_TIPO ) )		,;
					(_cAlias)->ZP1_CONTEU										,;
					''															,;
					(_cAlias)->R_E_C_N_O_										})
	
(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

Return( _aPar )

/*
===============================================================================================================================
Programa--------: ACFG002V
Autor-----------: Alexandre Villar
Data da Criacao-: 25/06/2015
===============================================================================================================================
Descri��o-------: Rotina para validar o preenchimento de campos na inclus�o/altera��o
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ACFG002V( _cFilPar , _cParam )

Local _lRet		:= .T.
Local _cQuery	:= ''
Local _cALias	:= ''

If !Empty(_cFilPar) .And. Empty( Posicione( 'SM0' , 1 , cEmpAnt + _cFilPar , 'M0_FILIAL' ) )
	_lRet := .F.
	MsgInfo( 'A Filial do par�metro informada n�o � v�lida no Sistema! Verifique os dados digitados.' , 'Aten��o!' )
EndIf

If _lRet .And. !Empty( _cParam )

	_cALias := GetNextAlias()
	
	//====================================================================================================
	// Valida se o par�metro j� foi cadastrado anteriormente
	//====================================================================================================
	_cQuery := " SELECT * FROM "+ RetSqlName('ZP1') +" ZP1 WHERE "+ RetSqlCond('ZP1') +" AND ZP1.ZP1_FILPAR = '"+ AllTrim( _cFilPar ) +"' AND ZP1.ZP1_PARAM = '"+ AllTrim( _cParam ) +"' "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	IF (_cAlias)->( !Eof() )
		
		_lRet := .F.
		MessageBox( 'O par�metro informado j� foi cadastrado anteriormente: '							+CRLF+CRLF	+;
					' M�dulo: ' + (_cAlias)->ZP1_MODULO +' - '+ U_ITNOMAMB( (_cAlias)->ZP1_MODULO )		+CRLF		+;
					' Grupo:  ' + ALLTRIM( X3Combo( "ZP1_GRUPO" , (_cAlias)->ZP1_GRUPO ) )				+CRLF		+;
					' Rotina: ' + AllTrim( (_cAlias)->ZP1_ROTINA )										+CRLF+CRLF	+;
					'--Caso necess�rio verifique o par�metro j� cadastrado!'							, 'Aten��o'	, 48 )
		
	EndIf
	
	(_cAlias)->( DBCloseArea() )

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: ACFG002G
Autor-----------: Alexandre Villar
Data da Criacao-: 25/06/2015
===============================================================================================================================
Descri��o-------: Rotina para gatilhos de campos
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ACFG002G( _nOpc )

Local _aArea	:= GetArea()
Local _cRet		:= ''
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

Default _nOpc	:= 0

Do Case

	Case _nOpc == 1
		
		_cQuery := " SELECT ZP1.ZP1_DESROT FROM "+ RETSQLNAME('ZP1') +" ZP1 WHERE "+ RETSQLCOND('ZP1') +" AND ZP1.ZP1_ROTINA = '"+ AllTrim( &( ReadVar() ) ) +"' "
		
		If Select(_cAlias) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )
		
		DBSelectArea(_cAlias)
		(_cAlias)->( DBGoTop() )
		If (_cAlias)->( !Eof() )
			_cRet := AllTrim( (_cAlias)->ZP1_DESROT )
		EndIf
		
		(_cAlias)->( DBCloseArea() )
		
	Case _nOpc == 2
		
		DBSelectArea('SM0')
		SM0->( DBSetOrder(1) )
		If SM0->( DBSeek( cEmpAnt + AllTrim( &( ReadVar() ) ) ) )
			_cRet := AllTrim( SM0->M0_FILIAL )
		EndIf
		
EndCase

RestArea( _aArea )

Return( _cRet )

/*
===============================================================================================================================
Programa--------: ACFG002PES
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para pesquisa de Rotinas/Par�metros
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002PES()

Local _aParRet		:= { Space(10) , Space(30) }
Local _aParAux	 	:= {}
Local _nI			:= 1

Private cCadastro	:= "Consulta: Rotinas/Par�metros de configura��o"

aAdd( _aParAux , { 2 , "Pesquisar por"		, Space(10) , {'Rotina','Par�metro'} , 50 , "" , .F. } )
aAdd( _aParAux , { 1 , "Chave a pesquisar"	, Space(30)         , "@!" , "" , "" , "" , 50 , .T. } )

If ParamBox( _aParAux , "Informar os dados para a Consulta:" , @_aParRet , {|| .T. } ,, .T. , , , , , .F. , .F. )
	
	For _nI := 1 To Len( _aParam )
	
		If IIF( ValType(_aParRet[01]) == 'N' , ( _aParRet[01] == 1 ) , ( Upper(AllTrim(_aParRet[01])) == 'ROTINA' ) )
			
			If AllTrim( _aParRet[02] ) $ _aParam[_nI][04]
				_cCarSeek := _aParam[_nI][11]
				Exit
			EndIf
			
		Else
			
			If AllTrim( _aParRet[02] ) $ _aParam[_nI][07] .Or. AllTrim( _aParRet[02] ) $ _aParam[_nI][08]
				_cCarSeek := _aParam[_nI][11]
				Exit
			EndIf
			
		EndIf
	
	Next _nI
	
EndIf

If !Empty( _cCarSeek )

	If !_oTree:TreeSeek( _cCarSeek )
		Aviso( 'Aten��o!' , 'Registro n�o encontrado com os dados informados!' , {'Fechar'} )
	EndIf
	
EndIf

Return()

/*
===============================================================================================================================
Programa--------: ACFG002MTD
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para montagem da estrutura de dados do menu
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002MTD( _cCargo )

Local _cCarMod		:= ''
Local _cCarGrp		:= ''
Local _cModulo		:= ''
Local _cGrupo		:= ''
Local _cRotina		:= ''
Local _nI			:= 0
Local _nCargo		:= 0

Default _cCargo		:= '0001'

//====================================================================================================
// Consulta os dados de par�metros cadastrados
//====================================================================================================
_aParam		:= ACFG002PAR()
_aChaves	:= {}

_oTree:Reset()

For _nI := 1 To Len( _aParam )
	
	//====================================================================================================
	// Cria o menu dos M�dulos
	//====================================================================================================
	If _cModulo <> _aParam[_nI][01]
		
		If _nI > 1
			_oTree:EndTree() //Fecha M�dulo
		EndIf
		
		_cModulo := _aParam[_nI][01]
		
		_nCargo++
		_cCarMod := StrZero( _nCargo , 4 )
		_oTree:AddItem( _cCarMod , _cCarMod ,,,,, 1 )
		_oTree:TreeSeek( _cCarMod )
		_oTree:ChangePrompt( _aParam[_nI][01] +" - "+ _aParam[_nI][02] , _cCarMod )
		
		aAdd( _aChaves , { 1 , _cCarMod , _aParam[_nI][01] , , , _aParam[_nI][12] } )
		
	EndIf
	
	//====================================================================================================
	// Cria o menu dos Grupos
	//====================================================================================================
	If !Empty( _aParam[_nI][03] )
	
		_cGrupo := _aParam[_nI][03]
		
		_nCargo++
		_cCarGrp := StrZero( _nCargo , 4 )
		_oTree:AddItem( _cCarGrp , _cCarGrp ,,,,, 2 )
		_oTree:TreeSeek( _cCarGrp )
		_oTree:ChangePrompt( _cGrupo , _cCarGrp )
	 	
	 	aAdd( _aChaves , { 2 , _cCarGrp , _aParam[_nI][01] , _aParam[_nI][03] , , _aParam[_nI][12] } )
	 	
	EndIf
	
	//====================================================================================================
	// Cria o menu das Rotinas
	//====================================================================================================
	While _nI <= Len( _aParam ) .And. _cModulo == _aParam[_nI][01] .And. _cGrupo == _aParam[_nI][03]
	
		If _cRotina <> _aParam[_nI][04]
		
			_cRotina := _aParam[_nI][04]
			
			_nCargo++ 
			_cCarRot := StrZero( _nCargo , 4 )
			_oTree:AddItem( _cCarRot , _cCarRot ,,,,, 2 )
			_oTree:ChangePrompt( _cRotina , _cCarRot )
			_aParam[_nI][11] := StrZero( _nCargo , 4 )
			
			aAdd( _aChaves , { 3 , _cCarRot , _aParam[_nI][01] , _aParam[_nI][03] , _aParam[_nI][04] , _aParam[_nI][12] } )
			
		Else
			
			_aParam[_nI][11] := StrZero( _nCargo , 4 )
			
		EndIf
	
	_nI++
	EndDo
	
	_nI--						//Retorna para o �ltimo item inclu�do
	_oTree:TreeSeek( _cCarMod ) //Retorna o posicionamento para o m�dulo
	
Next _nI

_oTree:TreeSeek( _cCargo )

Return()

/*
===============================================================================================================================
Programa--------: ACFG002DDM
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para montagem dos dados dos par�metros do Grid
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002DDM( _cCargo )

Local _aRet		:= {}
Local _nPos		:= 0
Local _nI		:= 0

//====================================================================================================
// Define a chave de pesquisa e retorna os dados de acordo com o menu selecionado
//====================================================================================================
//aAdd( _aChaves , { 1 , _cCarMod , _aParam[_nI][01] ,                  ,                  , _aParam[_nI][12] } )
//aAdd( _aChaves , { 2 , _cCarGrp , _aParam[_nI][01] , _aParam[_nI][03] ,                  , _aParam[_nI][12] } )
//aAdd( _aChaves , { 3 , _cCarRot , _aParam[_nI][01] , _aParam[_nI][03] , _aParam[_nI][04] , _aParam[_nI][12] } )
//====================================================================================================
If ( _nPos := aScan( _aChaves , {|x| x[02] == _cCargo } ) ) > 0
	
	If _aChaves[_nPos][01] == 1
	
		For _nI := 1 To Len( _aParam )
			
			If _aParam[_nI][01] == _aChaves[_nPos][03] .And. !Empty( _aParam[_nI][07] )
				aAdd( _aRet , _aParam[_nI] )
			EndIf
			
		Next _nI
	
	ElseIf _aChaves[_nPos][01] == 2
		
		For _nI := 1 To Len( _aParam )
		
			If _aParam[_nI][01] + _aParam[_nI][03] == _aChaves[_nPos][03] + _aChaves[_nPos][04] .And. !Empty( _aParam[_nI][07] )
				aAdd( _aRet , _aParam[_nI] )
			EndIf
			
		Next _nI
		
	ElseIf _aChaves[_nPos][01] == 3
		
		For _nI := 1 To Len( _aParam )
		
			If _aParam[_nI][01] + _aParam[_nI][03] + _aParam[_nI][04] == _aChaves[_nPos][03] + _aChaves[_nPos][04] + _aChaves[_nPos][05] .And. !Empty( _aParam[_nI][07] )
				aAdd( _aRet , _aParam[_nI] )
			EndIf
		
		Next _nI
		
	EndIf

EndIf

Return( _aRet )

/*
===============================================================================================================================
Programa--------: ACFG002MLB
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para montagem dos dados dos par�metros no ListBox
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002MLB( _cCargo , _oLbxAux )

Local _aDados  := ACFG002DDM( _cCargo )
Local _aHdrAux := { 'Fil.Par.' , 'Par�metro' , 'Descri��o' , 'Tipo' , 'Conte�do' }

_oLbxAux:aHeaders := aClone( _aHdrAux )
_oLbxAux:SetArray( _aDados )
_oLbxAux:bLine := {|| {	_aDados[_oLbxAux:nAt][06]	,;
						_aDados[_oLbxAux:nAt][07]	,;
						_aDados[_oLbxAux:nAt][08]	,;
						_aDados[_oLbxAux:nAt][09]	,;
						_aDados[_oLbxAux:nAt][10]	,;
						_aDados[_oLbxAux:nAt][12]	}}

_oLbxAux:Refresh()

Return()

/*
===============================================================================================================================
Programa--------: ACFG002MLB
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para manuten��o dos cadastros do menu
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002AMN( _nOpca )

Local _aArea		:= GetArea()
Local _oDlgInc		:= Nil
Local _oModulo		:= Nil
Local _oGrupo 		:= Nil
Local _oRotina		:= Nil
Local _oDesRot		:= Nil
Local _cGrupo 		:= Space( TamSX3('ZP1_GRUPO')[01]  )
Local _cRotina		:= Space( TamSX3('ZP1_ROTINA')[01] )
Local _cDesRot		:= Space( TamSX3('ZP1_DESROT')[01] )
Local _cCargo		:= _oTree:GetCargo()
Local _nPosAux		:= 0
Local _nRegZP1		:= 0

Private _cModulo	:= Space( TamSX3('ZP1_MODULO')[01] )

If _nOpca == 2
	
	If ( _nPosAux := aScan( _aChaves , {|x| x[02] == _cCargo } ) ) > 0
	    
	    If Empty( _aChaves[_nPosAux][05] )
	    	
			MsgInfo( 'Somente no n�vel de "Rotinas" s�o permitidas altera��es! Selecione uma rotina e tente novamente.' , 'Aten��o!' )
			Return()
	    	
	    Else
	    	
	    	_nRegZP1 := _aChaves[_nPosAux][06]
	    	
			DBSelectArea('ZP1')
			ZP1->( DBGoTo( _nRegZP1 ) )
			
			_cModulo	:= ZP1->ZP1_MODULO
			_cGrupo		:= ZP1->ZP1_GRUPO
			_cRotina	:= ZP1->ZP1_ROTINA
			_cDesRot	:= ZP1->ZP1_DESROT
		
		EndIf
	
	Else
		
		MsgInfo( 'Falha na inicializa��o da rotina de manuten��o dos menus.' , 'Aten��o!' )
		Return()
	
	EndIf

EndIf

//====================================================================================================
// Tela para escolha do produto.
//====================================================================================================
DEFINE MSDIALOG _oDlgInc TITLE "Inclus�o de Rotinas"	FROM 0,0 TO 190,470 PIXEL

	@ 010,008 Say "M�dulo:"									PIXEL OF _oDlgInc Size 018,009 COLOR CLR_BLACK
	@ 017,008 MSGet _oModulo Var _cModulo F3 "SELAMB"		PIXEL OF _oDlgInc Size 010,009 COLOR CLR_BLACK WHEN ( _nOpca == 1 )
	
	@ 010,080 Say "Nome do Grupo:"							PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 017,080 MSCOMBOBOX _oGrupo VAR _cGrupo				PIXEL OF _oDlgInc SIZE 100,009 COLORS 0,16777215 ITEMS StrTokArr( AllTrim(Posicione('SX3',2,'ZP1_GRUPO','X3_CBOX')) , ';' ) WHEN ( _nOpca == 1 )
	
	@ 030,008 Say "Rotina:"									PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 037,008 MsGet _oRotina Var _cRotina 					PIXEL OF _oDlgInc Size 150,009 COLOR CLR_BLACK
	
	@ 050,008 Say "Descri��o da Rotina:"					PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 057,008 MsGet _oDesRot Var _cDesRot 					PIXEL OF _oDlgInc Size 200,009 COLOR CLR_BLACK
	
	@ 078,158 Button "Cancelar"	Size 035,012 PIXEL OF _oDlgInc Action( _oDlgInc:End() )
	@ 078,195 Button "Ok"		Size 035,012 PIXEL OF _oDlgInc Action( MsgRun( "Gravando o menu..."	, "Aguarde!" , {|| IIF( ACFG002GMN(_nOpca,_nRegZP1,_cCargo,_cModulo,_cGrupo,_cRotina,_cDesRot) , _oDlgInc:End() , Nil ) } ) )

ACTIVATE MSDIALOG _oDlgInc CENTERED

RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa--------: ACFG002GMN
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para grava��o das configura��es de menus
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002GMN( _nOpca , _nRegZP1 , _cCargo , _cModulo , _cGrupo , _cRotina , _cDesRot )

Local _lRet		:= .F.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

Default _cCargo	:= '0001'

If Empty( _cModulo ) .Or. Empty( _cGrupo ) .Or. Empty( _cRotina ) .Or. Empty( _cDesRot )
	
	MsgInfo( 'N�o foram preenchidos todos os campos!' , 'Aten��o!' )
	
Else
	
	If _nOpca == 1
	
		_cQuery := " SELECT "
		_cQuery += "     ZP1_MODULO AS MODULO, "
		_cQuery += "     ZP1_GRUPO  AS GRUPO , "
		_cQuery += "     ZP1_ROTINA AS ROTINA, "
		_cQuery += "     ZP1_DESROT AS DESROT  "
		_cQuery += " FROM  "+ RetSqlName('ZP1') +" ZP1 "
		_cQuery += " WHERE "+ RetSqlCond('ZP1')
		_cQuery += " AND ZP1.ZP1_ROTINA = '"+ AllTrim( _cRotina ) +"' "
		
		If Select(_cAlias) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
		
		DBSelectArea(_cAlias)
		(_cAlias)->( DBGoTop() )
		If (_cAlias)->( !Eof() )
			
			_lRet := .F.
			
			MessageBox(	'A rotina informada j� encontra-se cadastrada: '							+CRLF+CRLF	+;
						'-> M�dulo: '+ (_cAlias)->MODULO +' - '+ U_ITNOMAMB( (_cAlias)->MODULO )	+CRLF		+;
						'-> Grupo : '+ (_cAlias)->GRUPO												+CRLF		+;
						'-> Rotina: '+ (_cAlias)->ROTINA											+CRLF		+;
						'-> Desc. : '+ (_cAlias)->DESROT									, 'Aten��o!' , 48	 )
		
		Else
			
			_lRet := .T.
			
			DBSelectArea('ZP1')
			RecLock( 'ZP1' , .T. )
			
			ZP1->ZP1_FILIAL		:= xFilial('ZP1')
			ZP1->ZP1_MODULO		:= _cModulo
			ZP1->ZP1_GRUPO		:= _cGrupo
			ZP1->ZP1_ROTINA		:= _cRotina
			ZP1->ZP1_DESROT		:= _cDesRot
			
			ZP1->( MsUnLock() )
		
		EndIf
		
		_cCargo	:= '0001'
	
	Else
		
		_lRet := .T.
		
		DBSelectArea('ZP1')
		ZP1->( DBGoTo( _nRegZP1 ) )
		
		_cQuery := " SELECT ZP1.R_E_C_N_O_ AS REGZP1 "
		_cQuery += " FROM  "+ RetSqlName('ZP1') +" ZP1 "
		_cQuery += " WHERE "+ RetSqlCond('ZP1')
		_cQuery += " AND ZP1.ZP1_ROTINA = '"+ ZP1->ZP1_ROTINA +"' "
		
		If Select(_cAlias) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
		
		DBSelectArea(_cAlias)
		(_cAlias)->( DBGoTop() )
		While (_cAlias)->( !Eof() )
		
			DBSelectArea('ZP1')
			ZP1->( DBGoTo( (_cAlias)->REGZP1 ) )
			RecLock( 'ZP1' , .F. )
			
			ZP1->ZP1_ROTINA		:= _cRotina
			ZP1->ZP1_DESROT		:= _cDesRot
			
			ZP1->( MsUnLock() )
		
		(_cAlias)->( DBSkip() )
		EndDo
		
	EndIf
	
EndIf

If _lRet
	ACFG002MTD( _cCargo )
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: ACFG002APR
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para manuten��o do cadastro de par�metros
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002APR( _nOpca , _oLbxAux )

Local _aArea		:= GetArea()
Local _oDlgInc		:= Nil
Local _oModulo		:= Nil
Local _oGrupo 		:= Nil
Local _oRotina		:= Nil
Local _oDesRot		:= Nil
Local _oFilPar		:= Nil
Local _oParam		:= Nil
Local _oTipo		:= Nil
Local _oDesPar		:= Nil
Local _oConteu		:= Nil
Local _cGrupo 		:= ''
Local _cRotina		:= ''
Local _cDesRot		:= ''
Local _cFilPar		:= ''
Local _cParam		:= ''
Local _cTipo		:= ''
Local _cDesPar		:= ''
Local _cConteu		:= ''
Local _cCargo		:= _oTree:GetCargo()
Local _nPosCrg		:= 0
Local _nPosChv		:= 0
Local _nRegZP1		:= 0

Private _cModulo	:= Space( TamSX3('ZP1_MODULO')[01] )

If Empty(_cCargo) .Or. Empty(_aChaves)
	Aviso( 'Aten��o!' , 'Falha na inicializa��o da fun��o de manuten��o, selecione uma Rotina ou Par�metro e tente novamente.' , {'Voltar'} )
	Return()
EndIf

If ( _nPosCrg := aScan( _aChaves , {|x| x[02] == _cCargo } ) ) <= 0
	Aviso( 'Aten��o!' , 'N�o foi poss�vel identificar o ponto de manuten��o do cadastro, selecione uma Rotina ou Par�metro e tente novamente.' , {'Voltar'} )
	Return()
EndIf

_nPosChv := _oLbxAux:nAt

If Len(_oLbxAux:aArray) >= _nPosChv

	_cModulo	:= _oLbxAux:aArray[_nPosChv][01]
	_cGrupo		:= _oLbxAux:aArray[_nPosChv][03]
	_cRotina	:= _oLbxAux:aArray[_nPosChv][04]
	_cDesRot	:= _oLbxAux:aArray[_nPosChv][05]
	
	If _nOpca > 1
	
		_cFilPar	:= _oLbxAux:aArray[_nPosChv][06]
		_cParam		:= _oLbxAux:aArray[_nPosChv][07]
		_cDesPar	:= _oLbxAux:aArray[_nPosChv][08]
		_cTipo		:= SubStr( _oLbxAux:aArray[_nPosChv][09] , 1 , 1 )
		_cConteu	:= _oLbxAux:aArray[_nPosChv][10]
		_nRegZP1	:= _oLbxAux:aArray[_nPosChv][12]
	
	EndIf

ElseIf _nOpca > 1
	
	Aviso( 'Aten��o!' , 'Para essa opera��o � necess�rio selecionar um Par�metro, verifique os dados selecionados e tente novamente.' , {'Voltar'} )
	Return()

Else
	
	_cModulo	:= _aChaves[_nPosCrg][03]
	_cGrupo		:= _aChaves[_nPosCrg][04]
	_cRotina	:= _aChaves[_nPosCrg][05]
	
	If Empty(_cGrupo) .Or. Empty(_cRotina)
	
		Aviso( 'Aten��o!' , 'Para essa opera��o � necess�rio selecionar uma Rotina ou Par�metro, verifique os dados selecionados e tente novamente.' , {'Voltar'} )
		Return()
		
	Else
		_cDesRot := AllTrim( Posicione( 'ZP1' , 1 , xFilial('ZP1') + _cModulo + _cRotina , "ZP1_DESROT" ) )
	EndIf

EndIf

If Empty(_cFilPar)
_cFilPar	:= Space( TamSX3('ZP1_FILPAR')[01] )
EndIf

If Empty(_cParam)
_cParam		:= Space( TamSX3('ZP1_PARAM' )[01] )
EndIf

If Empty(_cDesPar)
_cDesPar	:= Space( TamSX3('ZP1_DESCRI')[01] )
EndIf

If Empty(_cTipo)
_cTipo		:= Space( TamSX3('ZP1_TIPO'  )[01] )
EndIf

If Empty(_cConteu)
_cConteu	:= Space( TamSX3('ZP1_CONTEU')[01] )
EndIf

//====================================================================================================
// Tela para escolha do produto.
//====================================================================================================
DEFINE MSDIALOG _oDlgInc TITLE "Manuten��o de Par�metros - "+ IIF( _nOpca == 1 , 'Incluir' , IIf( _nOpca == 2 , 'Alterar' , 'Excluir' ) ) FROM 0,0 TO 300,470 PIXEL

	@ 005,005 To 069,232 LABEL ''				PIXEL OF _oDlgInc
	
	@ 008,010 Say "M�dulo:"						PIXEL OF _oDlgInc Size 018,009 COLOR CLR_BLACK
	@ 015,010 MSGet _oModulo Var _cModulo		PIXEL OF _oDlgInc Size 010,009 COLOR CLR_BLACK WHEN .F.
	
	@ 008,080 Say "Nome do Grupo:"				PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 015,080 MSGet _oGrupo VAR _cGrupo			PIXEL OF _oDlgInc SIZE 100,009 COLOR CLR_BLACK WHEN .F.
	
	@ 028,010 Say "Rotina:"						PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 035,010 MsGet _oRotina Var _cRotina 		PIXEL OF _oDlgInc Size 150,009 COLOR CLR_BLACK WHEN .F.
	
	@ 048,010 Say "Descri��o da Rotina:"		PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 055,010 MsGet _oDesRot Var _cDesRot 		PIXEL OF _oDlgInc Size 200,009 COLOR CLR_BLACK WHEN .F.
	
	//====================================================================================================
	// Inclui os campos para manuten��o do cadastro de par�metros
	//====================================================================================================
	@ 070,010 Say "Fil.Par.:"							PIXEL OF _oDlgInc Size 030,009 COLOR CLR_BLACK
	@ 077,010 MSGet _oFilPar Var _cFilPar F3 'SM0'		PIXEL OF _oDlgInc Size 010,009 COLOR CLR_BLACK WHEN ( _nOpca < 3 )
	
	@ 070,080 Say "Par�metro:"							PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 077,080 MSGet _oParam VAR _cParam					PIXEL OF _oDlgInc SIZE 100,009 COLOR CLR_BLACK WHEN ( _nOpca < 3 )
	
	@ 090,010 Say "Descri��o:"							PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 097,010 MsGet _oDesPar Var _cDesPar 				PIXEL OF _oDlgInc Size 150,009 COLOR CLR_BLACK WHEN ( _nOpca < 3 )
	
	@ 110,010 Say "Tipo:"								PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 117,010 MSCOMBOBOX _oTipo VAR _cTipo				PIXEL OF _oDlgInc Size 040,009 COLORS 0,16777215 ITEMS StrTokArr( AllTrim(Posicione('SX3',2,'ZP1_TIPO','X3_CBOX')) , ';' ) WHEN ( _nOpca < 3 )
	
	@ 110,050 Say "Conte�do:"							PIXEL OF _oDlgInc Size 026,009 COLOR CLR_BLACK
	@ 117,050 MsGet _oConteu Var _cConteu 				PIXEL OF _oDlgInc Size 150,009 COLOR CLR_BLACK WHEN ( _nOpca < 3 )
	
	@ 135,158 Button "Cancelar"	Size 035,012 PIXEL OF _oDlgInc Action( _oDlgInc:End() )
	@ 135,195 Button "Ok"		Size 035,012 PIXEL OF _oDlgInc Action( MsgRun("Processando...","Aguarde!",{|| IIF( ACFG002GPR(_nOpca,_cCargo,_nRegZP1,_cModulo,_cGrupo,_cRotina,_cDesRot,_cFilPar,_cParam,_cDesPar,_cTipo,_cConteu) , _oDlgInc:End() , Nil ) } ) )

ACTIVATE MSDIALOG _oDlgInc CENTERED

RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa--------: ACFG002GPR
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para grava��o dos dados de par�metros
===============================================================================================================================
Parametros------: _nOpca   - C�digo da op��o de opera��o (Incluir/Alterar/Excluir)
----------------: _cCargo  - C�digo de posicionamento no menu
----------------: _nRegZP1 - Recno do registro atual na tabela de par�metros (ZP1)
----------------: _cModulo - C�digo do m�dulo
----------------: _cGrupo  - Grupo do m�dulo
----------------: _cRotina - Rotina do Grupo
----------------: _cDesRot - Descri��o da rotina
----------------: _cFilPar - Filial do Par�metro
----------------: _cParam  - ID do Par�metro
----------------: _cDesPar - Descri��o do Par�metro
----------------: _cTipo   - Tipo de dado do par�metro (Caracter/Data/Num�rico/L�gico)
----------------: _cConteu - Conte�do do par�metro
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002GPR( _nOpca , _cCargo , _nRegZP1 , _cModulo , _cGrupo , _cRotina , _cDesRot , _cFilPar , _cParam , _cDesPar , _cTipo , _cConteu )

Local _lRet		:= .T.
Local _cQuery	:= ''
Local _cAlias	:= ''

DBSelectArea('ZP1')
ZP1->( DBSetOrder(1) )
If ZP1->( DBSeek( xFilial('ZP1') + _cModulo + _cRotina + _cFilPar + _cParam ) )
	
	If _nOpca == 1
		
		MsgInfo( 'O par�metro informado j� encontra-se cadastrado no sistema!' , 'Aten��o!' )
		_lRet := .F.
		
	ElseIf _nOpca == 2
		
		If _nRegZP1 <> ZP1->( Recno() )
			
			MessageBox( 'A configura��o atual do par�metro j� existe no Sistema, verifique a "Filial do Par�metro" e os dados informados.' , 'Aten��o' , 48 )
			_lRet := .F.
			
		Else
			
			If !Empty(_cFilPar) .And. Empty( Posicione( 'SM0' , 1 , cEmpAnt + _cFilPar , 'M0_FILIAL' ) )
				_lRet := .F.
				MsgInfo( 'A Filial do par�metro informada n�o � v�lida no Sistema! Verifique os dados digitados.' , 'Aten��o!' )
			EndIf
			
			If _lRet
			
				RecLock( 'ZP1' , .F. )
				ZP1->ZP1_FILPAR		:= _cFilPar
				ZP1->ZP1_PARAM		:= _cParam
				ZP1->ZP1_DESCRI		:= _cDesPar
				ZP1->ZP1_TIPO		:= _cTipo
				ZP1->ZP1_CONTEU		:= _cConteu
				ZP1->( MsUnLock() )
			
			EndIf
		
		EndIf
		
	Else
	
		RecLock( 'ZP1' , .F. )
		ZP1->( DBDelete() )
		ZP1->( MsUnLock() )
		
	EndIf
	
Else
	
	If !Empty(_cFilPar) .And. Empty( Posicione( 'SM0' , 1 , cEmpAnt + _cFilPar , 'M0_FILIAL' ) )
		_lRet := .F.
		MsgInfo( 'A Filial do par�metro informada n�o � v�lida no Sistema! Verifique os dados digitados.' , 'Aten��o!' )
	EndIf
	
	If _lRet .And. _nOpca == 1
		
		ZP1->( DBSetOrder(2) )
		If ZP1->( DBSeek( xFilial('ZP1') + _cFilPar + _cParam ) )
			
			MessageBox(	'O par�metro informado j� foi cadastrado em outra configura��o de Rotina: '		+CRLF+CRLF+;
						'- M�dulo: '+ ZP1->ZP1_MODULO + U_ITNOMAMB( ZP1->ZP1_MODULO )	  				+CRLF+;
						'- Grupo : '+ ALLTRIM( X3Combo( "ZP1_GRUPO" , ZP1->ZP1_GRUPO ) )				+CRLF+;
						'- Rotina: '+ ZP1->ZP1_ROTINA									  				+CRLF+;
						'- Descr.: '+ AllTrim( ZP1->ZP1_DESROT )										+CRLF+CRLF+;
						'Verifique a configura��o existente...'									, 'Aten��o!' , 48 )
			_lRet := .F.
			
		Else
			
			_cQuery := " SELECT "
			_cQuery += "     ZP1.R_E_C_N_O_ AS REGZP1 "
			_cQuery += " FROM  "+ RetSqlName('ZP1') +" ZP1 "
			_cQuery += " WHERE "+ RetSqlCond('ZP1')
			_cQuery += " AND ZP1.ZP1_PARAM = '"+ AllTrim( _cParam ) +"' "
			
			_cAlias	:= GetNextAlias()
			
			If Select(_cAlias) > 0
				(_cAlias)->( DBCloseArea() )
			EndIf
			
			DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )
			
			DBSelectArea(_cAlias)
			(_cAlias)->( DBGoTop() )
			If (_cAlias)->( !Eof() )
				
				DBSelectArea('ZP1')
				ZP1->( DBGoTo( (_cAlias)->REGZP1 ) )
				
				If	AllTrim( _cModulo )					<> AllTrim( ZP1->ZP1_MODULO )			.Or.;
					Upper( SubStr( _cGrupo , 1 , 1 ) )	<> Upper( AllTrim( ZP1->ZP1_GRUPO  ) )	.Or.;
					Upper( AllTrim( _cRotina ) )		<> Upper( AllTrim( ZP1->ZP1_ROTINA ) )
				
					MessageBox(	'O par�metro informado j� foi cadastrado em outra configura��o de Rotina: '	+CRLF+CRLF+;
								'- M�dulo: '+ ZP1->ZP1_MODULO +' - '+ U_ITNOMAMB( ZP1->ZP1_MODULO )			+CRLF+;
								'- Grupo : '+ ALLTRIM( X3Combo( "ZP1_GRUPO" , ZP1->ZP1_GRUPO ) )			+CRLF+;
								'- Rotina: '+ ZP1->ZP1_ROTINA									  			+CRLF+;
								'- Descr.: '+ AllTrim( ZP1->ZP1_DESROT )									+CRLF+CRLF+;
								'Verifique a configura��o existente...'										, 'Aten��o!' , 48 )
					_lRet := .F.
				
				EndIf
				
			EndIf
			
			(_cAlias)->( DBCloseArea() )
			
			If _lRet
			
				DBSelectArea('ZP1')
				ZP1->( DBSetOrder(1) )
				If ZP1->( DBSeek( xFilial('ZP1') + _cModulo + _cRotina ) )
				
					If Empty( ZP1->ZP1_FILPAR ) .And. Empty( ZP1->ZP1_PARAM ) .And. Empty( ZP1->ZP1_DESCRI ) .And. Empty( ZP1->ZP1_TIPO ) .And. Empty( ZP1->ZP1_CONTEU )
					
						RecLock( 'ZP1' , .F. )
						
					Else
					
						RecLock( 'ZP1' , .T. )
						
						ZP1->ZP1_FILIAL		:= xFilial('ZP1')
						ZP1->ZP1_MODULO		:= _cModulo
						ZP1->ZP1_GRUPO		:= _cGrupo
						ZP1->ZP1_ROTINA		:= _cRotina
						ZP1->ZP1_DESROT		:= _cDesRot
						
					EndIf
					
						ZP1->ZP1_FILPAR		:= _cFilPar
						ZP1->ZP1_PARAM		:= _cParam
						ZP1->ZP1_DESCRI		:= _cDesPar
						ZP1->ZP1_TIPO		:= _cTipo
						ZP1->ZP1_CONTEU		:= _cConteu
					
					ZP1->( MsUnLock() )
				
				EndIf
			
			EndIf
			
		EndIF
	
	ElseIf _lRet .And. _nOpca == 2
		
		_cQuery := " SELECT * "
		_cQuery += " FROM  "+ RetSqlName('ZP1') +" ZP1 "
		_cQuery += " WHERE "+ RetSqlCond('ZP1')
		_cQuery += " AND ZP1.ZP1_PARAM = '"+ AllTrim( _cParam ) +"' "
		
		_cAlias	:= GetNextAlias()
		
		If Select(_cAlias) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )
		
		DBSelectArea(_cAlias)
		(_cAlias)->( DBGoTop() )
		While (_cAlias)->( !Eof() )
			
			If	AllTrim( _cModulo )					<> AllTrim( (_cAlias)->ZP1_MODULO )		 		.Or.;
				Upper( SubStr( _cGrupo , 1 , 1 ) )	<> Upper( AllTrim( (_cAlias)->ZP1_GRUPO  ) )	.Or.;
				Upper( AllTrim( _cRotina ) )		<> Upper( AllTrim( (_cAlias)->ZP1_ROTINA ) )
				
				_lRet := .F.
				Exit
				
			EndIf
			
		(_cAlias)->( DBSkip() )
		EndDo
		
		(_cAlias)->( DBCloseArea() )
		
		If _lRet
			
			ZP1->( DBGoTo( _nRegZP1 ) )
			RecLock( 'ZP1' , .F. )
			ZP1->ZP1_FILPAR		:= _cFilPar
			ZP1->ZP1_PARAM		:= _cParam
			ZP1->ZP1_DESCRI		:= _cDesPar
			ZP1->ZP1_TIPO		:= _cTipo
			ZP1->ZP1_CONTEU		:= _cConteu
			ZP1->( MsUnLock() )
			
		Else
			
			MessageBox(	'Foram encontradas inconsist�ncias no cadastro de par�metros! Verifique com a �rea de TI/ERP.' , 'Aten��o!' , 48 )
			_lRet := .F.
			
		EndIf
		
	ElseIf _lRet
	
		MsgInfo( 'Falha ao processar a opera��o! Verifique os dados informados e tente novamente!' , 'Aten��o!' )
		_lRet := .F.
	
	EndIf
	
EndIF

If _lRet
	ACFG002MTD( _cCargo )
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: ACFG002REL
Autor-----------: Alexandre Villar
Data da Criacao-: 02/07/2015
===============================================================================================================================
Descri��o-------: Rotina para montar a rela��o de dados dos par�metros para confer�ncia/exporta��o
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ACFG002REL()

Local _cPerg	:= 'ACFG002'
Local _cQuery	:= ''
Local _cAlias	:= ''
Local _aRelat	:= {}
Local _aSizes	:= {100,50,080,200,20,50,150,25,100}


If Pergunte( _cPerg )
	
	_cAlias := GetNextAlias()
	
	_cQuery := " SELECT * "
	_cQuery += " FROM  "+ RetSqlName('ZP1') +" ZP1 "
	_cQuery += " WHERE "+ RetSqlCond('ZP1')
	_cQuery += " AND ZP1.ZP1_MODULO BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "
	If !Empty(MV_PAR03)
	_cQuery += " AND ZP1.ZP1_GRUPO  IN "+ FormatIn( AllTrim( MV_PAR03 )  , ';' )
	EndIf
	If !Empty(MV_PAR04)
	_cQuery += IIF( Empty(MV_PAR05)," AND "," AND ( " ) +" ( ZP1.ZP1_ROTINA LIKE '%"+ AllTrim( MV_PAR04 ) +"%' OR ZP1.ZP1_DESROT LIKE '%"+ AllTrim( MV_PAR04 ) +"%' ) "
	EndIf
	If !Empty(MV_PAR05)
	_cQuery += IIF( Empty(MV_PAR04)," AND "," OR ") +" ( ZP1.ZP1_PARAM  LIKE '%"+ AllTrim( MV_PAR05 ) +"%' OR ZP1.ZP1_DESCRI LIKE '%"+ AllTrim( MV_PAR05 ) +"%' ) "+ IIF( Empty(MV_PAR04) , "" , " ) " )
	EndIf
	_cQuery += " ORDER BY ZP1.ZP1_FILIAL, ZP1.ZP1_MODULO, ZP1.ZP1_GRUPO, ZP1.ZP1_ROTINA "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	While (_cAlias)->( !Eof() )
		
		aAdd( _aRelat , {	(_cAlias)->ZP1_MODULO +' - '+ U_ITNOMAMB( (_cAlias)->ZP1_MODULO )	,;
							ALLTRIM( X3Combo( "ZP1_GRUPO" , (_cAlias)->ZP1_GRUPO ) )			,;
							(_cAlias)->ZP1_ROTINA												,;
							AllTrim( (_cAlias)->ZP1_DESROT )									,;
							(_cAlias)->ZP1_FILPAR												,;
							AllTrim( (_cAlias)->ZP1_PARAM )										,;
							AllTrim( (_cAlias)->ZP1_DESCRI )									,;
							ALLTRIM( X3Combo( "ZP1_TIPO" , (_cAlias)->ZP1_TIPO ) )				,;
							AllTrim( (_cAlias)->ZP1_CONTEU )									})
		
	(_cAlias)->( DBSkip() )
	EndDo
	
	(_cAlias)->( DBCloseArea() )
	
	If !Empty( _aRelat )
		U_ITLISTBOX( 'Relat�rio da rela��o de par�metros - Italac' , {'M�dulo','Grupo','Rotina','Desc.Rot.','Fil.Par.','Par�metro','Descri��o','Tipo','Conte�do'} , _aRelat , .T. , 1 ,,, _aSizes )
	EndIf
	
Else

	MsgInfo( 'Opera��o cancelada pelo usu�rio!' , 'Aten��o!' )
	
EndIf

Return()