/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 22/12/2015 | Tratativa na cl�usula "ORDER BY" para remover a refer�ncia num�rica. Chamado 13062           
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 24/06/2019 | Ajustes de fontes para o novo servidor Totvs Lobo Guar�. Chamado 28886
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 14/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#Include 'ApWizard.Ch'
#Include 'FWMVCDEF.ch'

/*
===============================================================================================================================
Programa--------: AOMS066
Autor-----------: Alexandre Villar
Data da Criacao-: 15/09/2014
===============================================================================================================================
Descri��o-------: Rotina pra c�lculo da Meta de Comiss�o de Venda de Produtos por Vendedor
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS066()


Private cTitulo	:= 'Meta de Venda de Produtos por Vendedor'
Private aRotina	:= MenuDef()

//================================================================================
// Instancia a classe do Browse
//================================================================================
oBrowse := FWMBrowse():New()

//================================================================================
// Definicao da tabela do Browse
//================================================================================
oBrowse:SetAlias("ZC5")

//================================================================================
// Definicao do titulo do Browse
//================================================================================
oBrowse:SetDescription( 'Meta de Venda de Produtos por Vendedor' )
oBrowse:DisableDetails()

oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina de verifica��o do SX2 para n�o dar Erro no MVC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title 'Visualizar'	Action 'VIEWDEF.AOMS066'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'		Action 'U_AOMS66I'			OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'		Action 'VIEWDEF.AOMS066'	OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'		Action 'VIEWDEF.AOMS066'	OPERATION 5 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: AOMS66I
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina de inclus�o de novas estimativas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS66I()

Local _oWizard	:= Nil
Local _lGravaOK	:= .F.
Local _bFinish	:= {|| _lGravaOK := .T. }
Local _aRetPar	:= {}
Local _aParAux	:= {}
Local nI		:= 0

If !AOMS066VUS()
	Return()
EndIf

//================================================================================
// Desativa a Flag de C�pia quando n�o for Replica��o de Propostas
//================================================================================
_lOpcCopy := .F.

//================================================================================
// Montagem do Wizard
//================================================================================
DEFINE	WIZARD 	_oWizard TITLE "Italac"																							;
       	HEADER 	"M�dia de Vendas de Produtos"																					;
       	MESSAGE	"C�lculo das M�dias"				 																			;
       	TEXT 	"Esta rotina tem o objetivo de iniciar o processo de c�lculo das m�dias de vendas para os produtos"		+CRLF+	;
       			"que ser�o utilizadas para o processamento e cadastro de metas de vendas para os Vendedores."			+CRLF	;
       	NEXT	{||.T.} 																										;
       	FINISH 	{||.F.} 																										;
       	PANEL
	
	//================================================================================
	// Wizard 02: Tela de confirma��o
	//================================================================================
	CREATE	PANEL 	_oWizard												;
	        HEADER 	'Confirmar o processamento'								;
	        MESSAGE ''														;
	        BACK 	{|| .T. } 												;
	        FINISH 	{|| Eval( _bFinish ) } 									;
	        PANEL
	
	//================================================================================
	// Selecao da opcao de continuidade
	//================================================================================
	aAdd( _aParAux , { 3 , 'Selecione uma op��o para concluir'	, 1			, { 'Processamento autom�tico' , 'Inclus�o manual'} , 160 , ""	, .T. } )
	aAdd( _aParAux , { 1 , 'Data de Ref. [AAAAMM]'				, Space(6)	, '999999' , '.T.' , '' , '.T.' , 10							, .T. } )
	
	_aRetPar := {}
	
	For nI := 1 To Len( _aParAux )
		aAdd( _aRetPar , _aParAux[nI][3] )
	Next nI
	
	ParamBox( _aParAux , 'Par�metros' , @_aRetPar ,,, .T. ,,, _oWizard:GetPanel(2) )

_oWizard:Activate()

If	_lGravaOK

	Processa( {|| AOMS066PRC( _aRetPar ) } , 'Iniciando o processamento...' , 'Aguarde!' )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS066PRC
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina de processamento da op��o 'Incluir'
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS066PRC( _aRetPar )

Local _aTotVen	:= {}
Local _lExeAut	:= .T.
Local _lAtual	:= .F.
Local _lPriReg	:= .T.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _cPerFim	:= ''
Local _nTotReg	:= 0
Local _nAtuReg	:= 0
Local _nMesRef	:= GetMV( 'IT_QTMESVN' ,, 12 )
Local _cPeriod	:= _aRetPar[02]

If Empty( _cPeriod )
	_cPeriod := SubStr( DtoS( dDataBase ) , 1 , 6 )
EndIf

ProcRegua(0)
IncProc( 'Montando a estrutura...' )

_cPerIni := SubStr( DtoS( MonthSub( StoD( _cPeriod + '01' ) , _nMesRef ) ) , 1 , 6 )
_cPerFim := SubStr( DtoS( MonthSub( StoD( _cPeriod + '01' ) , 1 ) ) , 1 , 6 )

//================================================================================
// Valida se j� foi calculada a Estimativa de Produ��o para o per�odo
//================================================================================
_cQuery := " SELECT COUNT(*) AS QTDREG FROM "+ RetSqlName('ZC3') +" WHERE D_E_L_E_T_ = ' ' AND ZC3_PERIOD = '"+ _cPeriod +"' "
If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() ) .And. (_cAlias)->QTDREG > 0
	
	_cQuery := ''
	(_cAlias)->( DBCloseArea() )
	
Else

	(_cAlias)->( DBCloseArea() )
	u_itmsg( 'Para calcular a Meta dos Vendedores � necess�rio ter calculada a Estimativa de Produ��o para o per�odo informado. Verifique os dados e tente novamente.' ,  'Aten��o!' , 1 )
	Return()
	
EndIf

If _aRetPar[01] == 1

	_cQuery := " SELECT "
	_cQuery += "     SF2.F2_VEND1          AS VENDEDOR, "
	_cQuery += "     SA3.A3_NOME           AS NOME    , "
	_cQuery += "     SD2.D2_COD            AS PRODUTO , "
	_cQuery += "     SB1.B1_DESC           AS DESCRI  , "
	_cQuery += "     SUM( SD2.D2_QUANT )   AS QTDUM   , "
	_cQuery += "     SD2.D2_UM             AS UM      , "
	_cQuery += "     SUM( SD2.D2_QTSEGUM ) AS QTDSUM  , "
	_cQuery += "     SD2.D2_SEGUM          AS SUM     , "
	_cQuery += "     SUM( SD2.D2_TOTAL )   AS VALTOT  , "
	_cQuery += "     COUNT( DISTINCT SUBSTR( SD2.D2_EMISSAO , 1 , 6 ) ) AS QTDMES "
	_cQuery += " FROM "+ RetSqlName('SD2') +" SD2 "
	
	_cQuery += " INNER JOIN "+ RetSqlName('SF2') +" SF2 "
	_cQuery += " ON "
	_cQuery += "     SF2.F2_FILIAL  = SD2.D2_FILIAL "
	_cQuery += " AND SF2.F2_DOC     = SD2.D2_DOC "
	_cQuery += " AND SF2.F2_SERIE   = SD2.D2_SERIE "
	
	_cQuery += " INNER JOIN "+ RetSqlName('SA3') +" SA3 "
	_cQuery += " ON "
	_cQuery += "     SA3.A3_COD     = SF2.F2_VEND1 "
	
	_cQuery += " INNER JOIN "+ RetSqlName('SB1') +" SB1 "
	_cQuery += " ON "
	_cQuery += "     SB1.B1_COD     = SD2.D2_COD "
	
	_cQuery += " INNER JOIN "+ RetSqlName('ZAY') +" ZAY "
	_cQuery += " ON "
	_cQuery += "     ZAY.ZAY_CF     = SD2.D2_CF "
	
	_cQuery += " WHERE "
	_cQuery += "     SD2.D_E_L_E_T_ = ' ' "
	_cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
	_cQuery += " AND SA3.D_E_L_E_T_ = ' ' "
	_cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	_cQuery += " AND ZAY.D_E_L_E_T_ = ' ' "
	_cQuery += " AND SB1.B1_TIPO    = 'PA' "
	_cQuery += " AND SB1.B1_MSBLQL	<> '1' "
	_cQuery += " AND ZAY.ZAY_TPOPER = 'V' "
	_cQuery += " AND SUBSTR( SD2.D2_EMISSAO , 1 , 6 ) BETWEEN '"+ _cPerIni +"' AND '"+ _cPerFim +"' "
	
	_cQuery += " GROUP BY SF2.F2_VEND1 , SA3.A3_NOME , SD2.D2_COD , SB1.B1_DESC , SD2.D2_UM , SD2.D2_SEGUM "
	_cQuery += " ORDER BY SF2.F2_VEND1 , SD2.D2_COD "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	IncProc( 'Verificando os dados...' )
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	(_cAlias)->( DBEval( {|| _nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua( _nTotReg )
	
	Begin Transaction
	
	If _nTotReg > 0
		
		While (_cAlias)->( !Eof() )
			
			_nAtuReg++
			IncProc( 'Lendo registros...['+ StrZero( _nAtuReg , 9 ) +']' )
			
			DBSelectArea('ZC5')
			ZC5->( DBSetOrder(1) )
			IF ZC5->( DBSeek( xFilial('ZC5') + (_cAlias)->VENDEDOR + (_cAlias)->PRODUTO + _cPeriod ) )
				
				If !_lAtual
					
					If _lExeAut .And. _lPriReg
						
						If u_itmsg(  'J� existem dados para o per�odo informado, deseja atualizar os dados existentes?' , 'Aten��o!' , 2,2,2 ) 
							
							_lAtual := .T.
						
						Else
							
							u_itmsg(  'Opera��o cancelada pelo usu�rio!' , 'Aten��o!' , 1 )
							Exit
							
						EndIf
						
						_lExeAut := .F.
						
					EndIf
					
					_lPriReg := .F.
					
				EndIf
				
				If _lAtual

					ZC5->( RecLock( 'ZC5' , .F. ) )
					
					ZC5->ZC5_PERVEN	:= StrZero( (_cAlias)->QTDMES , 2 )
					ZC5->ZC5_QTDUM	:= Round( (_cAlias)->QTDUM / (_cAlias)->QTDMES , 2 )
					ZC5->ZC5_UM		:= (_cAlias)->UM
					ZC5->ZC5_QTD2UM	:= Round( (_cAlias)->QTDSUM / (_cAlias)->QTDMES , 2 )
					ZC5->ZC5_2UM	:= (_cAlias)->SUM
					ZC5->ZC5_VALVEN	:= Round( (_cAlias)->VALTOT / (_cAlias)->QTDMES , 2 )
					ZC5->ZC5_DATCAL	:= Date()
					
					ZC5->( MsUnLock() )

				EndIf
				
			Else
				
				ZC5->( RecLock( 'ZC5' , .T. ) )
				
				ZC5->ZC5_FILIAL	:= xFilial('ZC5')
				ZC5->ZC5_CODVEN	:= (_cAlias)->VENDEDOR
				ZC5->ZC5_CODPRO	:= (_cAlias)->PRODUTO
				ZC5->ZC5_PERVEN	:= StrZero( (_cAlias)->QTDMES , 2 )
				ZC5->ZC5_PERMET	:= _cPeriod
				ZC5->ZC5_QTDUM	:= Round( (_cAlias)->QTDUM / (_cAlias)->QTDMES , 2 )
				ZC5->ZC5_UM		:= (_cAlias)->UM
				ZC5->ZC5_QTD2UM	:= Round( (_cAlias)->QTDSUM / (_cAlias)->QTDMES , 2 )
				ZC5->ZC5_2UM	:= (_cAlias)->SUM
				ZC5->ZC5_VALVEN	:= Round( (_cAlias)->VALTOT / (_cAlias)->QTDMES , 2 )
				ZC5->ZC5_DATCAL	:= Date()
				
				ZC5->( MsUnLock() )
				
			EndIf
			
			aAdd( _aTotVen , {	_cPeriod												,; // Per�odo de Refer�ncia
								StrZero( _nMesRef , 2 )									,; // Meses de Refer�ncia
								(_cAlias)->PRODUTO										,; // C�digo do Produto
								Round( (_cAlias)->QTDUM / (_cAlias)->QTDMES , 2 )		,; // Quantidade na 1� UM
								Round( (_cAlias)->QTDSUM / (_cAlias)->QTDMES , 2 )		,; // Quantidade na 2� UM
								Round( (_cAlias)->VALTOT / (_cAlias)->QTDMES , 2 )		}) // Valor Total da Venda
			
			_lPriReg := .F.
			
		(_cAlias)->( DBSkip() )
		EndDo
		
		If !Empty( _aTotVen )
			
			Processa( {|| AOMS066GTV( _aTotVen ) }	, 'Registrando os Totalizadores...'	, 'Aguarde!' )
			Processa( {|| AOMS066GMT( _cPeriod ) }	, 'Registrando as Metas...'			, 'Aguarde!' )
			
		EndIf
		
	Else
		
		u_itmsg( 	'N�o foram encontrados hist�ricos de produ��o para gerar a estimativa automaticamente! '	,'Aten��o' ,;
							'Para a configura��o atual ser� necess�rio realizar o cadastro manualmente.'		, 1 )
	
	EndIf
    
	(_cAlias)->( DBCloseArea() )
    
	End Transaction

Else
	
	FWExecView( 'Inclus�o Manual' , 'AOMS066' , MODEL_OPERATION_INSERT ,, { || .T. } , { || .T. } )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Defini��o do Modelo de Dados da Rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

//================================================================================
// Cria a estrutura a ser usada no Modelo de Dados
//================================================================================
Local oStruZC5P	:= FWFormStruct( 1 , 'ZC5' , { |cCampo| AOMS066CPO( "P" , cCampo ) } /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZC5F	:= FWFormStruct( 1 , 'ZC5' , { |cCampo| AOMS066CPO( "F" , cCampo ) } /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	:= Nil

//================================================================================
// Cria o objeto do Modelo de Dados
//================================================================================
oModel := MPFormModel():New( 'AOMS066M' )

//================================================================================
// Configura o Modelo para exibi��o
//================================================================================
oModel:SetDescription( 'Meta de Vendas por Produto' )
oModel:AddFields( 'ZC5MASTER' ,, oStruZC5P )
oModel:AddGrid( 'ZC5DETAIL' , 'ZC5MASTER' , oStruZC5F )
oModel:SetPrimaryKey( { "ZC5_FILIAL" , "ZC5_CODVEN" , "ZC5_CODPRO" , "ZC5_PERMET" } )
oModel:SetRelation( "ZC5DETAIL" , { { 'ZC5_FILIAL' , "xFilial('ZC5')" } , { 'ZC5_CODVEN' , 'ZC5_CODVEN' } , { 'ZC5_PERMET' , 'ZC5_PERMET' } } , ZC5->( IndexKey( 1 ) ) )
oModel:GetModel( 'ZC5DETAIL' ):SetUniqueLine( { 'ZC5_CODPRO' } )

//================================================================================
// Adiciona a descricao do Componente do Modelo de Dados
//================================================================================
oModel:GetModel( 'ZC5MASTER' ):SetDescription( 'Vendedor' )
oModel:GetModel( 'ZC5DETAIL' ):SetDescription( 'Metas por Produto' )

//================================================================================
// Adiciona a valida��o inicial para as a��es do modelo
//================================================================================
oModel:SetVldActivate( { |oModel| AOMS066VUS() } )

Return( oModel )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Defini��o da View de Dados da Rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ViewDef()

Local oModel   	:= FWLoadModel( "AOMS066" )
Local oStruZC5P	:= FWFormStruct( 2 , "ZC5" , { |cCampo| AOMS066CPO( "P" , cCampo ) } )
Local oStruZC5F	:= FWFormStruct( 2 , "ZC5" , { |cCampo| AOMS066CPO( "F" , cCampo ) } )
Local oView		:= Nil

//================================================================================
// Cria o objeto de View
//================================================================================
oView := FWFormView():New()

//================================================================================
// Configura o Objeto da View para utiliza��o
//================================================================================
oView:SetModel( oModel )

oView:AddField( "VIEW_ZC5P" , oStruZC5P , "ZC5MASTER" )
oView:AddGrid(  "VIEW_ZC5F" , oStruZC5F , "ZC5DETAIL" )

oView:CreateHorizontalBox( 'BOX0101' , 20 , , , , )
oView:CreateHorizontalBox( 'BOX0102' , 80 , , , , )

oView:SetOwnerView( "VIEW_ZC5P" , "BOX0101" )
oView:SetOwnerView( "VIEW_ZC5F" , "BOX0102" )

Return(oView)

/*
===============================================================================================================================
Programa----------: AOMS066CPO
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Defini��o dos campos para os objetos do Modelo de Dados e da View
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS066CPO( cOrigem , cCampo )

Local lRet := AllTrim(cCampo) $ "ZC5_CODVEN,ZC5_NOMVEN,ZC5_PERMET"

If	cOrigem == "F"
	lRet := !lRet
EndIf

Return(lRet)

/*
===============================================================================================================================
Programa----------: AOMS66GQ
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina para convers�o das quantidades entre as unidades de medida
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS66GQ( _cCodPro , _nQtdUM )

Local _nRet	:= 1000

DBSelectArea('SB1')
SB1->( DBSetOrder(1) )
If SB1->( DBSeek( xFilial('SB1') + _cCodPro ) )
	
	If SB1->B1_TIPCONV == 'D'
		
		_nRet := Round( _nQtdUM / SB1->B1_CONV , 2 )
		
	Else
	    
		_nRet := Round( _nQtdUM * SB1->B1_CONV , 2 )
	
	EndIf
	
EndIf

Return( _nRet )

/*
===============================================================================================================================
Programa----------: AOMS066VUS
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina para valida��o de acesso do usu�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS066VUS()

Local _lRet		:= U_ITVLDUSR(6)
Local _aInfHlp	:= {}

If !_lRet
                      //|....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|
	aAdd( _aInfHlp	, { "Usu�rio sem acesso �s rotinas de "			, "defini��o de Metas de Vendas!"			, ""	} )
	aAdd( _aInfHlp	, { "Caso necess�rio, solicite a libera��o "	, "para a �rea de TI/ERP."					, ""	} )
	
	//===========================================================================
	//| Cadastra o Help e Exibe                                                 |
	//===========================================================================
	U_ITCADHLP( _aInfHlp , "ITACUSR" )
	
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS66CQ
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina de convers�o entre as unidades de medida
===============================================================================================================================
Parametros--------: _nOpc 
                    _cCodPro
				    _nQtdUm
===============================================================================================================================
Retorno-----------: _nRet 
===============================================================================================================================
*/

User Function AOMS66CQ( _nOpc , _cCodPro , _nQtdUm )

Local _nRet := 0

Return( _nRet )

/*
===============================================================================================================================
Programa----------: AOMS66VP
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina de valida��o para n�o permitir a inclus�o de per�odos duplicados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet = .T. = Valida��o Ok
                            .F. = N�o validado
===============================================================================================================================
*/

User Function AOMS66VP()

Local _oModel	:= FWModelActive()
Local _nOper	:= 0
Local _lRet		:= .T.

If ValType( _oModel ) == "O"
	_nOper := _oModel:GetOperation()
EndIf

If _nOper == MODEL_OPERATION_INSERT

	DBSelectArea('ZC5')
	ZC5->( DBSetOrder(2) )
	IF ZC5->( DBSeek( xFilial('ZC5') + _oModel:GetValue('ZC5MASTER','ZC5_CODVEN') + _oModel:GetValue('ZC5MASTER','ZC5_PERMET') ) )
		
		Help( ,, "AOMS066" ,, "J� existem registros configurados nesse per�odo para esse vendedor!" , 1 , 0 )
		_lRet := .F.
		
	EndIf

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS066GTV
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Rotina de grava��o dos totalizadores e c�lculo das metas
===============================================================================================================================
Parametros--------: _aTotVen
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS066GTV( _aTotVen )

Local _aResumo	:= {}
Local _cPeriod	:= ''
Local _nTotReg	:= 0
Local _nI		:= 0
Local _nPos		:= 0

If !Empty( _aTotVen )

	_aTotVen	:= aSort( _aTotVen , 3 )
	_nTotReg	:= Len( _aTotVen )
	_cPeriod	:= _aTotVen[01][01]
	
	ProcRegua( _nTotReg )
	
	For _nI := 1 To _nTotReg
		
		IncProc( 'Atualizando base: ['+ StrZero( _nI , 9 ) +'] de ['+ StrZero( _nTotReg , 9 ) +']' )
		
		If ( _nPos := aScan( _aResumo , {|x| x[02] == _aTotVen[_nI][03] } ) ) > 0
			
			_aResumo[_nPos][04] += _aTotVen[_nI][04] // Quantidade na 1� UM
			_aResumo[_nPos][05] += _aTotVen[_nI][05] // Quantidade na 2� UM
			_aResumo[_nPos][06] += _aTotVen[_nI][06] // Valor Total da Venda
			
		Else
			
			aAdd( _aResumo , {	_aTotVen[_nI][01] ,; // Per�odo de Refer�ncia
								_aTotVen[_nI][03] ,; // C�digo do Produto
								_aTotVen[_nI][02] ,; // Meses de Refer�ncia
								_aTotVen[_nI][04] ,; // Quantidade na 1� UM
								_aTotVen[_nI][05] ,; // Quantidade na 2� UM
								_aTotVen[_nI][06] }) // Valor Total da Venda
			
		EndIf
		
	Next _nI
	
	ProcRegua(0)
	IncProc( 'Gravando registros...' )
	
	For _nI := 1 To Len( _aResumo )
	
		DBSelectArea('ZC4')
		ZC4->( DBSetOrder(1) )
		IF ZC4->( DBSeek( xFilial('ZC4') + _aResumo[_nI][01] + _aResumo[_nI][02] ) )
			
			ZC4->( RecLock( 'ZC4' , .F. ) )
			
		Else
		
			ZC4->( RecLock( 'ZC4' , .T. ) )
			ZC4->ZC4_FILIAL := xFilial('ZC4')
			ZC4->ZC4_MESREF	:= _aResumo[_nI][01]
			ZC4->ZC4_CODPRO	:= _aResumo[_nI][02]
		
		EndIf
		
		ZC4->ZC4_QTDUM	:= _aResumo[_nI][04]
		ZC4->ZC4_VALTOT := _aResumo[_nI][06]
		ZC4->ZC4_DATA	:= DATE()
		ZC4->ZC4_PERMES	:= _aResumo[_nI][03]
	
	Next _nI
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS066GMT
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS066GMT( _cPeriod )

Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _nTotReg	:= 0

_cQuery := " SELECT "
_cQuery += "     ZC5.R_E_C_N_O_        AS REGZC5	, "
_cQuery += "     ZC5.ZC5_CODVEN        AS VENDEDOR	, "
_cQuery += "     ZC5.ZC5_CODPRO        AS PRODUTO	, "
_cQuery += "     ZC4.ZC4_QTDUM         AS QTD_ZC4	, "
_cQuery += "     ZC5.ZC5_QTDUM         AS QTD_ZC5	, "
_cQuery += "     ROUND( ( ZC5.ZC5_QTDUM / ZC4.ZC4_QTDUM ) * 100 , 4 ) AS REPR_TOTAL , "
_cQuery += "     SUM( ZC3.ZC3_QTDEST ) AS QTD_ZC3	, "
_cQuery += "     ROUND( ( ( SUM( ZC3.ZC3_QTDEST ) / ZC4.ZC4_QTDUM ) - 1 ) * 100 , 4 ) AS VARIACAO , "
_cQuery += "     ROUND( SUM( ZC3.ZC3_QTDEST ) * ( ZC5.ZC5_QTDUM / ZC4.ZC4_QTDUM ) ) AS META "
_cQuery += " FROM "+ RetSqlName('ZC5') +" ZC5 "

_cQuery += " INNER JOIN "+ RetSqlName('ZC4') +" ZC4 "
_cQuery += " ON "
_cQuery += "     ZC5.ZC5_CODPRO = ZC4.ZC4_CODPRO "
_cQuery += " AND ZC5.ZC5_PERMET = ZC4.ZC4_MESREF "

_cQuery += " INNER JOIN "+ RetSqlName('ZC3') +" ZC3 "
_cQuery += " ON "
_cQuery += "     ZC5.ZC5_CODPRO = ZC3.ZC3_CODPRO "
_cQuery += " AND ZC5.ZC5_PERMET = ZC3.ZC3_PERIOD "

_cQuery += " WHERE "
_cQuery += "     ZC5.D_E_L_E_T_ = ' ' "
_cQuery += " AND ZC4.D_E_L_E_T_ = ' ' "
_cQuery += " AND ZC3.D_E_L_E_T_ = ' ' "
_cQuery += " AND ZC5.ZC5_PERMET = '"+ _cPeriod +"' "

_cQuery += " GROUP BY ZC5.R_E_C_N_O_ , ZC5.ZC5_CODVEN , ZC5.ZC5_CODPRO , ZC4.ZC4_QTDUM , ZC5.ZC5_QTDUM "
_cQuery += " ORDER BY ZC5.R_E_C_N_O_ , ZC5.ZC5_CODVEN "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
(_cAlias)->( DBEval( {|| _nTotReg++ } ) )
(_cAlias)->( DBGoTop() )

ProcRegua( _nTotReg )
	
While (_cAlias)->( !Eof() )
	
	IncProc( 'Registrando as metas...' )
	
	DBSelectArea('ZC5')
	ZC5->( DBGoTo( (_cAlias)->REGZC5 ) )
	ZC5->( RecLock( 'ZC5' , .F. ) )
		
		ZC5->ZC5_REPTOT	:= (_cAlias)->REPR_TOTAL
		ZC5->ZC5_VARPRD	:= (_cAlias)->VARIACAO
		ZC5->ZC5_METAUM	:= (_cAlias)->META
		ZC5->ZC5_MET2UM := AOMS066SUM( ZC5->ZC5_CODPRO , ZC5->ZC5_METAUM )
		
	ZC5->( MsUnLock() )
	
(_cAlias)->( DBSkip() )
EndDo

Return()

/*
===============================================================================================================================
Programa----------: AOMS066SUM
Autor-------------: Alexandre Villar
Data da Criacao---: 15/09/2014
===============================================================================================================================
Descri��o---------: Converte as quantidades passadas por parametros com base no fator de convers�o do produto.
===============================================================================================================================
Parametros--------: _cCodPro  = Codigo do Produto
                    _nQtdUM   = Quantidade na primeira unidade de med�da.
===============================================================================================================================
Retorno-----------: _nRet = Quantidade convertida de acordo com o fator de convers�o.
===============================================================================================================================
*/

Static Function AOMS066SUM( _cCodPro , _nQtdUM )

Local _nRet	:= 0

DBSelectArea('SB1')
SB1->( DBSetOrder(1) )
If SB1->( DBSeek( xFilial('SB1') + _cCodPro ) )
	
	If SB1->B1_TIPCONV == 'D'
		
		_nRet := Round( _nQtdUM / SB1->B1_CONV , 2 )
	
	Else
	    
		_nRet := Round( _nQtdUM * SB1->B1_CONV , 2 )
	
	EndIf
	
EndIf

Return( _nRet )