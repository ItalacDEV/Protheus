/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/01/2020 | Corrigido totalizador do conv�nio. Chamado 31761
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 20/10/2020 | Corrigida a exclus�o de t�tulos. Chamado 34436
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 24/05/2022 | Criada fun��o para polular o grid de acordo com evento gerado no Mix. Chamado 40201
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch' 
#Include "FWMVCDEF.ch"

/*
===============================================================================================================================
Programa----------: AGLT010
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para lan�amentos dos conv�nios - Chamado 9296
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT010()

Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias('ZLL')
_oBrowse:SetDescription('Lan�amentos dos Conv�nios')

_oBrowse:AddLegend( "ZLL_STATUS == 'A'" , 'GREEN'	, 'Conv�nio em aberto'	)
_oBrowse:AddLegend( "ZLL_STATUS == 'P'" , 'RED'		, 'Conv�nio pago'		)
_oBrowse:AddLegend( "ZLL_STATUS == 'S'" , 'BLUE'	, 'Conv�nio Suspenso'	)

_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Retorna o menu funcional para a rotina principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title 'Visualizar'	Action 'VIEWDEF.AGLT010' OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'		Action 'VIEWDEF.AGLT010' OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'		Action 'VIEWDEF.AGLT010' OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'		Action 'VIEWDEF.AGLT010' OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Copiar'		Action 'VIEWDEF.AGLT010' OPERATION 9 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Monta o Modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oStruCAB	:= FWFormStruct( 1 , 'ZLL' , { |_cCampo| AGLT010CPO( _cCampo , 1 ) } )
Local _oStruITN	:= FWFormStruct( 1 , 'ZLL' , { |_cCampo| AGLT010CPO( _cCampo , 2 ) } )
Local _oModel	:= Nil
Local _aGatAux	:= {}

_aGatAux := FwStruTrigger( 'ZLL_SETOR'	, 'ZLL_COD'		, 'M->ZLL_COD'	, .F. )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_SETOR'	, 'ZLL_VENCTO'	, 'StoD( SubStr( DtoS( MonthSum( Date() , 1 ) ) , 1 , 6 ) + StrZero( SuperGetMV("LT_VENCONV",.F.,20), 2 ) )' , .F. )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_SETOR'	, 'ZLL_DESSET'	, 'ZL2->ZL2_DESCRI'	, .T. , 'ZL2' , 1 , 'xFilial("ZL2")+M->ZLL_SETOR'	)
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_EVENTO'	, 'ZLL_DESEVE'	, 'ZL8->ZL8_DESCRI'	, .T. , 'ZL8' , 1 , 'xFilial("ZL8")+M->ZLL_EVENTO'	)
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_EVENTO'	, 'ZLL_DESEVE'	, 'U_GL010RET( 4 , M->ZLL_EVENTO  )'	, .F.	)
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_CONVEN'	, 'ZLL_DESCRI'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLL_CONVEN+AllTrim(M->ZLL_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_CONVEN'	, 'ZLL_LJCONV'	, 'IIF( Empty(M->ZLL_LJCONV) , "0001" , M->ZLL_LJCONV )'	, .F. )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_LJCONV'	, 'ZLL_DESCRI'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLL_CONVEN+AllTrim(M->ZLL_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_CONVEN'	, 'ZLL_PERADM'	, 'SA2->A2_L_TXADM'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLL_CONVEN+AllTrim(M->ZLL_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_LJCONV'	, 'ZLL_PERADM'	, 'SA2->A2_L_TXADM'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLL_CONVEN+AllTrim(M->ZLL_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_RETIRO'	, 'ZLL_RETIRO'	, 'U_GL010RET( 1 , M->ZLL_RETIRO )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_RETIRO'	, 'ZLL_RETILJ'	, 'U_GL010RET( 2 , M->ZLL_RETIRO , M->ZLL_RETILJ )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_RETIRO'	, 'ZLL_RETILJ'	, 'U_GL010RET( 3 , M->ZLL_RETIRO , M->ZLL_RETILJ )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_RETIRO'	, 'ZLL_DCRRET'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLL_RETIRO+AllTrim(M->ZLL_RETILJ)' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_RETILJ'	, 'ZLL_DCRRET'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLL_RETIRO+AllTrim(M->ZLL_RETILJ)' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLL_VALOR'	, 'ZLL_VALOR'	, 'U_GL010LOK( M->ZLL_VALOR )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel := MPFormModel():New( 'AGLT010M' ,, {|| AGLT010TOK() } )

_oModel:SetDescription( 'Lan�amentos dos Conv�nios' )

_oModel:AddFields(	"ZLLMASTER" , /*cOwner*/  , _oStruCAB )
_oModel:AddGrid(	"ZLLDETAIL" , "ZLLMASTER" , _oStruITN , { | _oModel , _nLine , _cAction , _cField | AGLT010LOK( _nLine , _cAction , _cField ) } )

_oModel:SetRelation( "ZLLDETAIL" , {	{ 'ZLL_FILIAL'	, 'xFilial("ZLL")'	} ,;
										{ 'ZLL_COD'		, 'ZLL_COD'			} }, ZLL->( IndexKey( 1 ) ) )

_oModel:GetModel( 'ZLLDETAIL' ):SetUniqueLine( { 'ZLL_SEQ' } )

_oModel:GetModel( "ZLLMASTER" ):SetDescription( "Dados do Conv�nio"		)
_oModel:GetModel( "ZLLDETAIL" ):SetDescription( "Itens do Lan�amento"	)

_oModel:SetPrimaryKey( { 'ZLL_FILIAL' , 'ZLL_COD' , 'ZLL_SEQ' } )

_oModel:GetModel( 'ZLLMASTER' ):AFLDNOCOPY := { 'ZLL_SETOR' , 'ZLL_DESSET' , 'ZLL_DATA' , 'ZLL_VENCTO' }
_oModel:GetModel( 'ZLLDETAIL' ):AFLDNOCOPY := { 'ZLL_STATUS' }

//==================================
// Define valida��o inical do modelo
//==================================
_oModel:SetVldActivate( { |_oModel| AGLT010VLD( _oModel ) } )

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Define a View de dados para a rotina de cadastro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()

Local _oModel  	:= FWLoadModel( 'AGLT010' )
Local _oStruCAB	:= FWFormStruct( 2 , 'ZLL' , { |cCampo| AGLT010CPO( cCampo , 1 ) } )
Local _oStruITN	:= FWFormStruct( 2 , 'ZLL' , { |cCampo| AGLT010CPO( cCampo , 2 ) } )
Local _oView	:= Nil

//=========================================
// Configura��o para agrupamento dos campos
//=========================================
_oStruCAB:AddGroup( 'GRUPO01' , 'Conv�nio'						, '' , 2 )
_oStruCAB:AddGroup( 'GRUPO02' , 'Valores do Conv�nio'			, '' , 2 )

_oStruCAB:SetProperty( 'ZLL_COD'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_SETOR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_DESSET'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_NATURE'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_EVENTO'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_DESEVE'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_CONVEN'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_LJCONV'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_DESCRI'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_DATA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLL_VENCTO'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )

_oStruCAB:SetProperty( 'ZLL_VALTOT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLL_VLRABR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLL_ACRESC'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLL_PERADM'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLL_VTXADM'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )

_oView := FWFormView():New()

_oView:SetModel( _oModel )
_oView:AddField( "VIEW_CAB"	, _oStruCAB	, "ZLLMASTER" )
_oView:AddGrid(  "VIEW_ITN"	, _oStruITN	, "ZLLDETAIL" )

_oView:CreateHorizontalBox( 'BOX0101' , 55 )
_oView:CreateHorizontalBox( 'BOX0102' , 45 )
_oView:SetOwnerView( "VIEW_CAB" , "BOX0101" )
_oView:SetOwnerView( "VIEW_ITN" , "BOX0102" )

_oView:AddIncrementField( 'VIEW_ITN' , 'ZLL_SEQ' )

_oView:addUserButton('Vinc. Prod.', 'CONTAINER', {|| AGLT010P() } )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT010CPO
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Define a organiza��o dos campos para exibi��o na tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT010CPO( _cCampo , _nOpc )

Local _lRet := Upper( AllTrim(_cCampo) ) $ 'ZLL_FILIAL/ZLL_COD/ZLL_SETOR/ZLL_DESSET/ZLL_EVENTO/ZLL_DESEVE/ZLL_CONVEN/ZLL_LJCONV/ZLL_DESCRI/ZLL_DATA/ZLL_VENCTO/ZLL_NATURE/ZLL_VALTOT/ZLL_VLRABR/ZLL_ACRESC/ZLL_PERADM/ZLL_VTXADM'

If _nOpc == 2
	_lRet := !_lRet
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: GL010LOK
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para Atualiza��o dos valores conforme preenchimento dos campos das linhas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function GL010LOK( _nValRet )

Local _oModel	:= FWModelActive()
Local _aSaveLines := FWSaveRows()
Local _oZLLDET	:= _oModel:GetModel( 'ZLLDETAIL' )
Local _nI		:= 0
Local _nValor	:= 0
Local _nValAbr	:= 0
Local _nValAdm	:= 0
Local _nValTot	:= 0
Local _nTxAdm	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_PERADM' )

For _nI := 1 To _oZLLDET:Length()
	
	_oZLLDET:GoLine( _nI )
	If !_oZLLDET:IsDeleted()
		_nValor		:= _oZLLDET:GetValue( 'ZLL_VALOR' )
		_nValTot	+= _nValor
			
		_oModel:SetValue( 'ZLLDETAIL' , 'ZLL_TXADM' , _nValor * ( _nTxAdm / 100 ) )
		_nValAdm	+= _oZLLDET:GetValue( 'ZLL_TXADM' )
			
		If _oZLLDET:GetValue( 'ZLL_STATUS' ) == 'A'
			_nValAbr += _nValor
		EndIf
	EndIf	
Next _nI

_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VALTOT' , _nValTot )
_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VTXADM' , _nValAdm )
_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VLRABR' , _nValAbr )
FWRestRows( _aSaveLines )

Return( _nValRet )

/*
===============================================================================================================================
Programa----------: AGLT010LOK
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para valida��o das opera��es de altera��o/delete das linhas de lan�amentos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT010LOK(_nLine , _cAction , _cField )

Local _lRet		:= .T.
Local _oModel	:= FWModelActive()
Local _nValor	:= 0
Local _nValTX	:= 0
Local _nValTot	:= 0
Local _nValTXA	:= 0

If _oModel:GetValue( 'ZLLDETAIL' , 'ZLL_STATUS' ) == 'A'

	If Upper(AllTrim(_cAction)) $ 'DELETE/UNDELETE'
	
		_nValor		:= _oModel:GetValue( 'ZLLDETAIL' , 'ZLL_VALOR' )
		_nValTX		:= _oModel:GetValue( 'ZLLDETAIL' , 'ZLL_TXADM' )
		_nValTot	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_VALTOT' )
		_nValABR	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_VLRABR' )
		_nValTXA	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_VTXADM' )
	
		If Upper(AllTrim(_cAction)) == 'DELETE'
		
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VTXADM' , _nValTXA - _nValTX )
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VLRABR' , _nValABR - _nValor )
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VALTOT' , _nValTot - _nValor )
			
		Else
		
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VTXADM' , _nValTXA + _nValTX )
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VLRABR' , _nValABR + _nValor )
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_VALTOT' , _nValTot + _nValor )
			
		EndIf
	
	EndIf
	
Else
	_oModel:SetErrorMessage('ZLLDETAIL', 'ZLL_STATUS' , 'ZLLDETAIL' , 'ZLL_STATUS' , "AGLT01001", "N�o � poss�vel realizar a opera��o no registro atual!", "Somente registros 'Em Aberto' podem ser alterados, exclu�dos ou restaurados.")
	_lRet := .F.
EndIf
	
Return( _lRet )

/*
===============================================================================================================================
Programa----------: GL010RET
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina auxiliar para processamento dos gatilhos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function GL010RET( _nOpcao , _cRetiro , _cLoja )

Local _cRet		:= ''
Local _oModel	:= FWModelActive()

If _nOpcao == 1

	If Val( AllTrim( _cRetiro ) ) > 0 .And. Len( AllTrim( _cRetiro ) ) < 6
		_cRetiro := 'P' + PadL( AllTrim( _cRetiro ) , 5 , '0' )
	EndIf

	DBSelectArea('SA2')
	SA2->( DBSetOrder(1) )
	If SA2->( DBSeek( xFilial('SA2') + _cRetiro ) )
	
		_oModel:LoadValue( 'ZLLDETAIL' , 'ZLL_RETIRO' , SA2->A2_COD )
		_cRet := SA2->A2_COD
		
	Else
		_oModel:SetErrorMessage('ZLLDETAIL', 'ZLL_RETIRO' , 'ZLLDETAIL' , 'ZLL_RETIRO' , "AGLT01002", "O Produtor informado n�o � v�lido ou n�o foi encontrado no Sistema!", "Verifique os dados digitados e tente novamente.")
	    _oModel:LoadValue( 'ZLLDETAIL' , 'ZLL_RETIRO' , '' )
	EndIf

Elseif _nOpcao == 2
	
	DBSelectArea('SA2')
	SA2->( DBSetOrder(1) )
	If SA2->( DBSeek( xFilial('SA2') + _cRetiro + AllTrim( _cLoja ) ) )
	    
		_oModel:LoadValue( 'ZLLDETAIL' , 'ZLL_RETILJ' , SA2->A2_LOJA )
		_cRet := SA2->A2_LOJA
		
	Else
		_oModel:SetErrorMessage('ZLLDETAIL', 'ZLL_RETILJ' , 'ZLLDETAIL' , 'ZLL_RETILJ' , "AGLT01003", "O Produtor informado n�o � v�lido ou n�o foi encontrado no Sistema!", "Verifique os dados digitados e tente novamente.")
	    _oModel:LoadValue( 'ZLLDETAIL' , 'ZLL_RETILJ' , '' )
	EndIf 
	
Elseif _nOpcao == 3


	DBSelectArea('ZL8')
	ZL8->( DBSetOrder(1) )
	If ZL8->( DBSeek( xFilial('ZL8') + M->ZLL_EVENTO ) )
	    
		If SUBSTR(_cRetiro,1,1) = 'G' //Natureza para fretista
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_NATURE' , ZL8->ZL8_NATFRT )
			_cRet := _cLoja
		Else
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_NATURE' , ZL8->ZL8_NATPRD )
			_cRet := _cLoja
		EndIf
		
	EndIf

ElseIf _nOpcao == 4


  _cret := ZL8->ZL8_DESCRI  
  
  If Len(_omodel:AALLSUBMODELS[2]:ACOLS) > 0 .and. Len(alltrim(_omodel:AALLSUBMODELS[2]:ACOLS[1][2])) == 6

  		If Substr(alltrim(_omodel:AALLSUBMODELS[2]:ACOLS[1][2]),1,1) = 'G' //Natureza para fretista
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_NATURE' , ZL8->ZL8_NATFRT )
		Else
			_oModel:LoadValue( 'ZLLMASTER' , 'ZLL_NATURE' , ZL8->ZL8_NATPRD )
		EndIf

	EndIf

EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa----------: AGLT010TOK
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para Valida��o Total do modelo de dados e grava��es auxiliares
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT010TOK()

Local _lRet		:= .T.
Local _aValid	:= {}
Local _aMovPer	:= {}
Local _oModel	:= FWModelActive()
Local _oGrid	:= _oModel:GetModel( 'ZLLDETAIL' )
Local _cCodigo	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_COD'    )
Local _cConven	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_CONVEN' )
Local _cLjConv	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_LJCONV' )
Local _nVlrTot	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_VALTOT' )
Local _nAcresc	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_ACRESC' )
Local _nTxAdm	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_VTXADM' )
Local _cLinha	:= ''
Local _cSetor	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_SETOR'  )
Local _cCodPro	:= ''
Local _cLojPro	:= ''
Local _cNatAux	:= ''
Local _cPrefix	:= ''
Local _dEmissa	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_DATA'   )
Local _dVencto	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_VENCTO' )
Local _cEvento	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_EVENTO' )
Local _dDatIni	:= StoD( SubStr( DtoS( MonthSub( _dVencto , 1 ) ) , 1 , 6 ) + '01' )
Local _dDatFim	:= LastDay( MonthSub( _dVencto , 1 ) )
Local _nLinhas	:= 0
Local _nI, _nX	:= 0
Local _cSeq		:= ''
Local _nValor	:= 0
Local _cStatus	:= ''

Local _lParc	:= .F.
Local _aParAux	:= {}
Local _aDados	:= {}

//=============================================
// Valida��o do conv�nio no cadastro do Sistema
//=============================================
DBSelectArea("SA2")
SA2->( DBSetOrder(1) )
If SA2->( DBSeek(xFilial("SA2") + _cConven + _cLjConv ) )
	
	If SA2->A2_MSBLQL == '1'
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_CONVEN' , 'ZLLMASTER' , 'ZLL_CONVEN' , "AGLT01004", "O conv�nio informado est� bloqueado no cadastro de Fornecedores do Sistema!", "Verifique o cadastro do conv�nio ou os dados informados para confirmar.")
		_lRet := .F.
	EndIf
	
	If _lRet .And. SA2->A2_L_ATIVO == 'N'
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_CONVEN' , 'ZLLMASTER' , 'ZLL_CONVEN' , "AGLT01005", "O conv�nio informado est� inativo no cadastro de Fornecedores do Sistema!", "Verifique o cadastro do conv�nio ou os dados informados para confirmar.")
		_lRet := .F.
	EndIf

Else
	_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_CONVEN' , 'ZLLMASTER' , 'ZLL_CONVEN' , "AGLT01006", "O conv�nio informado n�o foi encontrado no cadastro de Fornecedores do Sistema!", "Verifique o cadastro do conv�nio ou os dados informados para confirmar.")
	_lRet := .F.
EndIf

//==========================================================
// Valida��o do cadastro de Setor na Filial de processamento
//==========================================================
If _lRet
	
	DBSelectArea('ZL2')
	ZL2->( DBSetOrder(1) )
	_lRet := ZL2->( DBSeek( xFilial('ZL2') + _cSetor ) )
	ZL2->(DbCloseArea())
	
	If !_lRet
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_SETOR' , 'ZLLMASTER' , 'ZLL_SETOR' , "AGLT01007", "O Setor informado n�o � v�lido para a Filial atual do Sistema!", "Verifique o cadastro do Setor ou informe um Setor v�lido para confirmar.")
	EndIf

EndIf

If _lRet

	//============================================
	// Valida��o das datas de Emiss�o x Vencimento
	//============================================
	If _dEmissa > _dVencto
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_VENCTO' , 'ZLLMASTER' , 'ZLL_VENCTO' , "AGLT01008", "A data de vencimento do conv�nio n�o � v�lida!", "O vencimento deve ser maior ou igual � data de emiss�o do conv�nio.")
		_lRet := .F.
	EndIf
	
	//===========================================================
	// Valida��o do preenchimento de todos os campos obrigat�rios
	//===========================================================
	If _lRet .And. ( Empty(_cSetor) .Or. Empty(_cConven) .Or. Empty(_cLjConv) .Or. Empty( _dEmissa ) .Or. Empty( _dVencto ) .Or. Empty( _cEvento ) )
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_SETOR' , 'ZLLMASTER' , 'ZLL_SETOR' , "AGLT01009", "Existem campos do conv�nio que n�o foram preenchidos!", "Verifique os dados e informe todos os campos obrigat�rios para confirmar.")
		_lRet := .F.
	EndIf
	
	If _lRet
		
		//==========================================
		// Valida��o do Evento informado no Conv�nio
		//==========================================
		DBSelectArea("ZL8")
		ZL8->( DBSetorder(1) )
		If ZL8->( DBSeek( xfilial("ZL8") + _cEvento ) )
			
			If _oModel:GetValue( 'ZLLMASTER' , 'ZLL_CONVEN' ) == ZL8->ZL8_FORCON .And. _oModel:GetValue( 'ZLLMASTER' , 'ZLL_LJCONV' ) == ZL8->ZL8_LOJCON
				If Empty(ZL8->ZL8_NATPRD) .OR. Empty(ZL8->ZL8_NATFRT)
					_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_EVENTO' , 'ZLLMASTER' , 'ZLL_EVENTO' , "AGLT01010", "O evento informado n�o possui naturezas cadastradas!", "Verifique o cadastro do evento e informe um evento v�lido para o conv�nio.")
					_lRet := .F.
				EndIf
		
				If ZL8->ZL8_MSBLQL == '1' .and. _lRet
					_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_EVENTO' , 'ZLLMASTER' , 'ZLL_EVENTO' , "AGLT01011", "O evento informado encontra-se bloqueado no cadastro do Sistema!", "Verifique o cadastro do evento e informe um evento v�lido para o conv�nio.")
					_lRet := .F.
				Else
					If ZL8->ZL8_TPEVEN <> "F" .OR. Empty( ZL8->ZL8_PREFIX ) .OR. ZL8->ZL8_DEBCRE <> "D"
						_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_EVENTO' , 'ZLLMASTER' , 'ZLL_EVENTO' , "AGLT01012", "O evento informado � inv�lido para o lan�amento de Conv�nios!", "O evento deve ser Financeiro, de D�bito e possuir Prefixo.")
						_lRet := .F.
					EndIf
				EndIf
			Else
				_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_EVENTO' , 'ZLLMASTER' , 'ZLL_EVENTO' , "AGLT01036", "Evento vinculado n�o pertence ao forncedor informado.")
				_lRet := .F.
			EndIf
		Else
			_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_EVENTO' , 'ZLLMASTER' , 'ZLL_EVENTO' , "AGLT01013", "O evento informado n�o foi encontrado no cadastro do Sistema!", "Verifique o c�digo informado.")
			_lRet := .F.
		EndIf

	EndIf
	
EndIf

If _lRet
	
	_nLinhas := _oGrid:Length()
	
	//========================================================
	// Valida��o das linhas do Grid de lan�amentos do conv�nio
	//========================================================
	For _nI := 1 To _nLinhas
		
		_oGrid:GoLine(_nI)
		
		//==========================================
		// Valida��o apenas nas linhas n�o deletadas
		//==========================================
		If !( _oGrid:IsDeleted() )
		
			_cCodPro	:= _oGrid:GetValue( 'ZLL_RETIRO' )
			_cLojPro	:= _oGrid:GetValue( 'ZLL_RETILJ' )
			_cNomPro	:= Posicione( 'SA2' , 1 , xFilial('SA2') + _cCodPro + _cLojPro , 'A2_NOME' )
			_cLinha		:= SA2->A2_L_LI_RO
			
			If Empty( _cCodPro ) .Or. Empty( _cLojPro ) .Or. Empty( _cNomPro )
				_oModel:SetErrorMessage('ZLLDETAIL', 'ZLL_RETIRO' , 'ZLLDETAIL' , 'ZLL_RETIRO' , "AGLT01014", "� obrigat�rio informar um produtor para todas os lan�amentos do Conv�nio!", "Verifique os lan�amentos e informe produtores v�lidos para todas as linhas.")
				_lRet := .F.
				Exit
			EndIf
			
			If SA2->A2_MSBLQL == '1'
				aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'O fornecedor encontra-se bloqueado no cadastro do Sistema' } )
			EndIf
			
			If SA2->A2_L_ATIVO == 'N'
				aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'O fornecedor encontra-se inativo no cadastro do Sistema' } )
			EndIf

			If _oGrid:GetValue( 'ZLL_VALOR' ) <= 0
				aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'N�o foi informado um valor v�lido para o lan�amento do conv�nio' } )
			EndIf
			
			If Left( _cCodPro , 1 ) == 'P'
			
				If Empty(_cLinha)
					aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'O fornecedor � um Produtor e n�o possui uma Linha/Rota no cadastro do Sistema' } )
				EndIf
				
				DBSelectArea('ZL3')
				ZL3->( DBSetOrder(1) )
				If ZL3->( DBSeek( xFilial('ZL3') + _cLinha ) )
				
					If ZL3->ZL3_SETOR <> _cSetor
						aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'O Setor do Produtor � diferente do informado para o conv�nio' } )
					EndIf
					
				Else
					aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'A Linha/Rota do Produtor no cadastro do Sistema � inv�lida' } )
				EndIf
				
				IF U_VolLeite( xfilial("ZLL") , _dDatIni , _dDatFim , _cSetor ,, _cCodPro , _cLojPro , "" ) <= 0
					aAdd( _aMovPer , { _cCodPro+'/'+_cLojPro , _cNomPro , 'O produtor n�o possui movimenta��o de Leite no per�odo' } )
				EndIf
				
			Else
			
				If U_VolFret( xfilial("ZLL") , _cSetor ,, _cCodPro , _cLojPro , _dDatIni , _dDatFim , 1 ) <= 0
					aAdd( _aMovPer , { _cCodPro+'/'+_cLojPro , _cNomPro , 'O Fretista n�o possui movimenta��o de Leite no per�odo' } )
				EndIf
			
			EndIf
			
		EndIf
			
	Next _nI

EndIf

If _lRet .And. !Empty( _aValid ) .And. _oModel:GetOperation() <> MODEL_OPERATION_DELETE
	
	U_ITListBox( 'N�o conformidades nos lan�amentos' , { 'C�digo' , 'Nome' , 'Avalia��o' } , _aValid , .F. , 1 , 'Verifique os lan�amentos abaixo:' ,, {50,100,200} )
	_oModel:SetErrorMessage('ZLLDETAIL', 'ZLL_RETIRO' , 'ZLLDETAIL' , 'ZLL_RETIRO' , "AGLT01015", "Existem lan�amentos que n�o passaram na valida��o!", "Verifique os dados do relat�rio exibido e corrija os lan�amentos com problema.")
	_lRet := .F.
	
EndIf

If _lRet .And. !Empty( _aMovPer ) .And. _oModel:GetOperation() <> MODEL_OPERATION_DELETE
	
	_lRet := U_ITListBox( 'Produtores sem movimenta��o no per�odo' , { 'C�digo' , 'Nome' , 'Avalia��o' } , _aMovPer , .F. , 1 , 'Verifique os lan�amentos abaixo:' ,, {50,100,200} )
	
	If !_lRet
		_oModel:SetErrorMessage('ZLLDETAIL', 'ZLL_RETIRO' , 'ZLLDETAIL' , 'ZLL_RETIRO' , "AGLT01016", "Foi cancelada a opera��o por conta de produtores sem movimenta��o no per�odo!", "Verifique os dados e caso necess�rio confirme mesmo com produtores sem movimenta��o para continuar.")
	EndIf
	
EndIf

//================================================================
// Se passar pelas valida��es processa as grava��es complementares
//================================================================
If _lRet
	
	_nOper		:= _oModel:GetOperation()
	_cNumTit	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_COD'    )
	_cNatNDF	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_NATURE' )
	
	_cNatAux	:= POSICIONE( "ZL8" , 1 , XFILIAL("ZL8") + _cEvento , "ZL8_NATPRD" ) ; IIF( Empty(_cNatAux) , _cNatAux := _cNatNDF , Nil )
	_cPrefix	:= ZL8->ZL8_PREFIX
	
	If _nOper == MODEL_OPERATION_INSERT
		
		If MsgYesNo("Deseja replicar e criar novas parcelas iguais a configura��o do conv�nio atual para meses posteriores?","AGLT01017" )
			
			_lParc := .F.
			
			_aParAux := AGLT010CPA( _dVencto )
			
			If Empty(_aParAux)
				_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_NATURE' , 'ZLLMASTER' , 'ZLL_NATURE' , "AGLT01018", "A gera��o de parcelas n�o foi realizada pelo usu�rio e ser� gerado apenas o registro do conv�nio!", "Caso necess�rio, revise os dados informados.")
			Else
				_lParc := .T.
			EndIf
		
		EndIf
		
	EndIf
	
	_lsai := .F.
	Begin Sequence
	Begin Transaction
	
	//==============================================================
	// Se for Altera��o ou Exclus�o exclui o t�tulo Financeiro da NF
	//==============================================================
	If _nOper == MODEL_OPERATION_UPDATE .Or. _nOper == MODEL_OPERATION_DELETE
		//Fa�o a exclus�o com base no dados gravados na tabela e n�o nos novos
	    ZL8->(Dbseek(ZLL->(ZLL_FILIAL+ZLL_EVENTO)))
	    _lRet := AGLT010DE2( ZL8->ZL8_PREFIX , _cNumTit + '000' , '1 ' , 'NF ' , ZLL->ZLL_CONVEN , ZLL->ZLL_LJCONV , ZLL->ZLL_NATURE, _oModel )
		
		If _lRet
			If _nOper == MODEL_OPERATION_UPDATE
				MsgInfo("O Titulo da NF foi excluido e ser� gerado novamente com os novos valores!","AGLT01019")
			EndIf
		EndIf
	
	EndIf
	
	If _lRet
	
		//======================
		// Guarda posi��o do ZLL
		//======================
		_aareaZLL := getarea("ZLL")
		
		//=========================================================
		// Grava��o dos t�tulos de todos os lan�amentos do conv�nio
		//=========================================================
		For _nI := 1 To _nLinhas
		
			_oGrid:GoLine(_nI)
			
			_cSeq		:= _oGrid:GetValue( 'ZLL_SEQ'    )
			_cCodPrd	:= _oGrid:GetValue( 'ZLL_RETIRO' )
			_cLojPrd	:= _oGrid:GetValue( 'ZLL_RETILJ' )
			_nValor		:= _oGrid:GetValue( 'ZLL_VALOR'  )
			_cStatus	:= _oGrid:GetValue( 'ZLL_STATUS' )
			
			//===============================================
			// Posiciona ZLL para saber o que alterou na tela
			//===============================================
			ZLL->(Dbsetorder(1))
			ZLL->(Dbseek(xFilial("ZLL") + _cCodigo + _cSeq))
			
			//================================================
			// Tratativa para os lan�amentos deletados no Grid
			//================================================
			If _oGrid:IsDeleted() .And. _nOper == MODEL_OPERATION_UPDATE
				_lRet := AGLT010DE2( ZL8->ZL8_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLL->ZLL_RETIRO , ZLL->ZLL_RETILJ , ZLL->ZLL_NATURE, _oModel )
			Elseif  !(_oGrid:IsDeleted())
			
				//==========================================
				// Na Inclus�o gera os t�tulos no Financeiro
				//==========================================
				If _nOper == MODEL_OPERATION_INSERT 
					_lRet := AGLT010IE2( _cPrefix , _cNumTit + _cSeq , '1 ' , 'NDF' , _cCodPrd , _cLojPrd , _cNatNDF , _dEmissa , _dVencto , _nValor , 0 , 0 , _cSetor, _oModel )
				EndIf
				
				//=======================================================
				// Tratativa para os lan�amentos na opera��o de altera��o
				//=======================================================
				If _nOper == MODEL_OPERATION_UPDATE
					
					//========================================================
					// Se a linha for "Suspensa" deleta o t�tulo no Financeiro
					//========================================================
					If _oGrid:GetValue('ZLL_STATUS') == 'S'
					
						_lRet := AGLT010DE2( ZL8->ZL8_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLL->ZLL_RETIRO , ZLL->ZLL_RETILJ , ZLL->ZLL_NATURE, _oModel )
					
					//=================================================================================================
					// Se a linha for "Alterada" e o Status estiver Em Aberto dever� excluir e gerar o T�tulo novamente
					//=================================================================================================
					ElseIf _oGrid:GetValue('ZLL_STATUS') == 'A'
					
						If AGLT010DE2( ZL8->ZL8_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLL->ZLL_RETIRO , ZLL->ZLL_RETILJ , ZLL->ZLL_NATURE, _oModel )
						 	_lRet := AGLT010IE2( _cPrefix , _cNumTit + _cSeq , '1 ' , 'NDF' , _cCodPrd , _cLojPrd , _cNatNDF , _dEmissa , _dVencto , _nValor , 0 , 0 , _cSetor, _oModel )
						Else
							
							DBSelectArea('SE2')
							SE2->( DBSetOrder(1) )
							If SE2->( DBSeek( xFilial('SE2') + ZL8->ZL8_PREFIX + _cNumTit + _cSeq + '1 ' + 'NDF' + ZLL->(ZLL_RETIRO+ZLL_RETILJ) ) )
								_lRet := .F.
							Else
								_lRet := AGLT010IE2( _cPrefix , _cNumTit + _cSeq , '1 ' , 'NDF' , _cCodPrd , _cLojPrd , _cNatNDF , _dEmissa , _dVencto , _nValor , 0 , 0 , _cSetor, _oModel )
							EndIf
						EndIf
						
					EndIf
				
				EndIf
					
				//===============================================================================
				// Para a opera��o de exclus�o do conv�nio dever�o ser exclu�dos todos os t�tulos
				//===============================================================================
				If _nOper == MODEL_OPERATION_DELETE
					_lRet := AGLT010DE2( ZL8->ZL8_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLL->ZLL_RETIRO , ZLL->ZLL_RETILJ , ZLL->ZLL_NATURE, _oModel )
				EndIf
				
			EndIf
			
			//============================================================
			// Aborta caso encontre algum problema durante o processamento
			//============================================================
			If !_lRet
				DisarmTransaction()
				_lsai := .T.
				Break
			EndIf
		
		Next nx
		
		//================================
		// Retorna posi��o e �ndice da ZLL
		//================================
		ZLL->(Restarea(_aareaZLL))
			
		If _lRet
			
			//==================================================================================
			// Para a inclus�o ou altera��o dever� ser inclu�do o T�tulo para a NF no Financeiro
			//==================================================================================
			If _nOper == MODEL_OPERATION_INSERT .Or. _nOper == MODEL_OPERATION_UPDATE
				
				//==================================================================================================
				// Adicionado por Fabiano Dias da Silva no dia 29/04/10, solicitacao feita por Monis ao Tiago Correa
				// para que quando a Loja conveniada for a F00001 nao sera gerado o titulo de NF somente as NDF dos 
				// produtores os valores das NDF serao abatidos de suas movimentacoes Financeiras na ITALAC
				//==================================================================================================
				If _cConven <> 'F00001'
					_lRet := AGLT010IE2( _cPrefix , _cNumTit + '000' , '1 ' , 'NF ' , _cConven , _cLjConv , _cNatAux , _dEmissa , _dVencto , _nVlrTot , _nAcresc , _nTxAdm , _cSetor, _oModel )
				EndIf
			
			EndIf
			
			If !_lRet
				DisarmTransaction()
				_lsai := .T.
				Break
			EndIf
			
		Else
			DisarmTransaction()
			_lsai := .T.
			Break
		EndIf
	
	EndIf
	
	If _lRet .And. _nOper == MODEL_OPERATION_INSERT .And. !Empty( _aParAux )
		
		For _nI := 1 To _nLinhas
			
			_oGrid:GoLine(_nI)
			
			If !_oGrid:IsDeleted()
			
				aAdd( _aDados , {	_oModel:GetValue( 'ZLLMASTER' , 'ZLL_NATURE'	) ,;
									_oModel:GetValue( 'ZLLDETAIL' , 'ZLL_SEQ'		) ,;
									_oModel:GetValue( 'ZLLDETAIL' , 'ZLL_RETIRO'	) ,;
									_oModel:GetValue( 'ZLLDETAIL' , 'ZLL_RETILJ'	) ,;
									_oModel:GetValue( 'ZLLDETAIL' , 'ZLL_VALOR'		) ,;
									_oModel:GetValue( 'ZLLDETAIL' , 'ZLL_TXADM'		) ,;
									_oModel:GetValue( 'ZLLDETAIL' , 'ZLL_STATUS'	) ,;
									_oModel:GetValue( 'ZLLDETAIL' , 'ZLL_OBSERV'	) })
			
			EndIf
			
		Next _nI
		
		For _nI := 1 To Len( _aParAux )
			
			_cCodZLL := GetSXENum( 'ZLL' , 'ZLL_COD' )
			
			If __lSX8
				ConfirmSX8()
			EndIf
			
			//==============================================================================================
			// Pega a data de emiss�o baseada no vencimento: deve ser o �ltimo dia do m�s anterior ao vencto
			//==============================================================================================
			_dEmissa := LastDay( MonthSub( _aParAux[_nI] , 1 ) )
			
			DBSelectArea('ZLL')
			
			For _nX := 1 To Len( _aDados )
				
				ZLL->( RecLock( 'ZLL' , .T. ) )
				
				ZLL->ZLL_FILIAL		:= xFilial('ZLL')
				ZLL->ZLL_COD		:= _cCodZLL
				ZLL->ZLL_SETOR		:= _cSetor
				ZLL->ZLL_NATURE		:= _aDados[_nX][01]
				ZLL->ZLL_EVENTO		:= _cEvento
				ZLL->ZLL_DATA		:= _dEmissa
				ZLL->ZLL_VENCTO		:= _aParAux[_nI]
				ZLL->ZLL_CONVEN		:= _cConven
				ZLL->ZLL_LJCONV		:= _cLjConv
				ZLL->ZLL_ACRESC		:= _nAcresc
				ZLL->ZLL_SEQ		:= _aDados[_nX][02]
				ZLL->ZLL_RETIRO		:= _aDados[_nX][03]
				ZLL->ZLL_RETILJ		:= _aDados[_nX][04]
				ZLL->ZLL_VALOR		:= _aDados[_nX][05]
				ZLL->ZLL_TXADM		:= _aDados[_nX][06]
				ZLL->ZLL_STATUS		:= _aDados[_nX][07]
				ZLL->ZLL_OBSERV		:= _aDados[_nX][08]
				
				ZLL->( MsUnLock() )
				
				//=====================================
				// Inclui nova NDF para a parcela atual
				//=====================================
				If !AGLT010IE2( _cPrefix , ZLL->( ZLL_COD + ZLL_SEQ ) , '1 ' , 'NDF' , ZLL->ZLL_RETIRO , ZLL->ZLL_RETILJ , ZLL->ZLL_NATURE , ZLL->ZLL_DATA , ZLL->ZLL_VENCTO , ZLL->ZLL_VALOR , 0 , 0 , _cSetor, _oModel )
					DisarmTransaction()
					_lret := .F.
					_lsai := .T.
					Break
				EndIf
				
			Next
			
			//====================================
			// Inclui nova NF para a parcela atual
			//====================================
			//==================================================================================================
			// Adicionado por Fabiano Dias da Silva no dia 29/04/10, solicitacao feita por Monis ao Tiago Correa
			// para que quando a Loja conveniada for a F00001 nao sera gerado o titulo de NF somente as NDF dos
			// produtores os valores das NDF serao abatidos de suas movimentacoes Financeiras na ITALAC
			//==================================================================================================
			If _cConven <> 'F00001'
			
				If !AGLT010IE2( _cPrefix , _cCodZLL + '000' , '1 ' , 'NF ' , _cConven , _cLjConv , _cNatAux , _dEmissa , _aParAux[_nI] , _nVlrTot , _nAcresc , _nTxAdm , _cSetor, _oModel )
					DisarmTransaction()
					_lret := .F.
					_lsai := .T.
					Break
				EndIf
				
			EndIf
			
		Next _nI
		
	EndIf
	
	End Transaction
	
	End Sequence
	
	If _lsai
	
		Return(_lret)
		
	EndIf

EndIf

//===========================================================================================
// Para corrigir um problema do MVC em salvar telas modelo 2, posiciono no primeiro registro,
// e regravo todas as informa��es do cabe�alho em todas as linhas
//===========================================================================================
_aAreaZLL := ZLL->(GetArea())
If _lRet .And. _oModel:GetOperation() == MODEL_OPERATION_UPDATE
	dbSelectArea("ZLL")
	dbSetOrder(1)
	If dbSeek(xFilial("ZLL") + _cCodigo)
		While !ZLL->(Eof()) .And. ZLL->ZLL_FILIAL == xFilial("ZLL") .And. ZLL->ZLL_COD == _cCodigo
			RecLock("ZLL", .F.)
				ZLL->ZLL_SETOR	:= _cSetor
				ZLL->ZLL_EVENTO	:= _cEvento
				ZLL->ZLL_CONVEN	:= _cConven
				ZLL->ZLL_LJCONV	:= _cLjConv
				ZLL->ZLL_VENCTO	:= _dVencto
				ZLL->ZLL_ACRESC	:= _nAcresc
			MsUnLock()
			ZLL->(dbSkip())
		End
	EndIf
EndIf
RestArea(_aAreaZLL)
Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT010DE2
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para exclus�o de T�tulos do Financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function AGLT010DE2( _cPrefix , _cNumTit , _cParcel , _cTipo , _cForn , _cLoja , _cNature, _oModel )

Local aArea := GetArea()
Local _aAutSE2	:= {}
Local _lOk		:= .T.
Local _nModAux	:= nModulo
Local _cModAux	:= cModulo

Private lMsErroAuto := .F.

nModulo := 6
cModulo := "FIN"

DBSelectArea("SE2")
SE2->( DBSetOrder(1) )
If SE2->( DBSeek( xFilial("SE2") + _cPrefix + _cNumTit + _cParcel + _cTipo + _cForn + _cLoja ) )
	If !Empty(SE2->E2_BAIXA)
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_NATURE' , 'ZLLMASTER' , 'ZLL_NATURE' , "AGLT01020", "T�tulo sofreu baixas e n�o poder� ser exclu�do. T�tulo: " + _cPrefix + _cNumTit + _cParcel + _cTipo + _cForn + _cLoja, "Exclua a baixa antes de realizar a opera��o.")
	    _lOk := .F.
	Else
	
		_aAutSE2 := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
	                { "E2_NUM"     , SE2->E2_NUM     , NIL } }

		MSExecAuto( {|x,y,z| Fina050(x,y,z) } , _aAutSE2 ,, 5 )

		If lMsErroAuto
			MostraErro()
			_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_NATURE' , 'ZLLMASTER' , 'ZLL_NATURE' , "AGLT01021", "Falhou ao excluir o t�tulo do conv�nio no Financeiro!", "Informe a �rea de TI/ERP.")
			_lOk := .F.
		EndIf
		
    EndIf
Else                            

	If _cForn <> 'F00001'
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_NATURE' , 'ZLLMASTER' , 'ZLL_NATURE' , "AGLT01022", "N�o encontrou o t�tulo do conv�nio no  Financeiro!", "Informe a �rea de TI/ERP.")
		_lOk := .F.
	EndIf

EndIf

nModulo := _nModAux
cModulo := _cModAux

RestArea(aArea)

Return( _lOk )

/*
===============================================================================================================================
Programa----------: AGLT010IE2
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para inclus�o de T�tulos no Financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT010IE2( _cPrefix , _cNumTit , _cParcel , _cTipo , _cForn , _cLoja , _cNature , _dEmissa , _dVencto , _nValor , _nAcres , _nDesc , _cSetor, _oModel )

Local _aAutSE2	:= {}
Local _lOk		:= .T.
Local _nModAux	:= nModulo
Local _cModAux	:= cModulo

Private lMsErroAuto := .F.

AAdd( _aAutSE2 , { "E2_PREFIXO"	, _cPrefix		, Nil } )
AAdd( _aAutSE2 , { "E2_NUM"		, _cNumTit		, nil } )
AAdd( _aAutSE2 , { "E2_PARCELA"	, _cParcel		, nil } )
AAdd( _aAutSE2 , { "E2_TIPO"	, _cTipo		, nil } )
AAdd( _aAutSE2 , { "E2_NATUREZ"	, _cNature		, nil } )
AAdd( _aAutSE2 , { "E2_FORNECE"	, _cForn		, nil } )
AAdd( _aAutSE2 , { "E2_LOJA"	, _cLoja		, nil } )
AAdd( _aAutSE2 , { "E2_EMISSAO"	, _dEmissa		, nil } )
AAdd( _aAutSE2 , { "E2_EMIS1"	, _dEmissa		, nil } )
AAdd( _aAutSE2 , { "E2_VENCTO"	, DataValida(_dVencto), nil } )
AAdd( _aAutSE2 , { "E2_VALOR"	, _nValor		, nil } )
AAdd( _aAutSE2 , { "E2_ACRESC"	, _nAcres		, nil } )
AAdd( _aAutSE2 , { "E2_DECRESC"	, _nDesc		, nil } )
AAdd( _aAutSE2 , { "E2_HIST"	, "GLT-CONVENIO", nil } )
AAdd( _aAutSE2 , { "E2_DATALIB"	, _dEmissa		, nil } )	
AAdd( _aAutSE2 , { "E2_USUALIB"	, cUserName		, nil } )	
AAdd( _aAutSE2 , { "E2_ORIGEM"	, "AGLT010"		, nil } )
AAdd( _aAutSE2 , { "E2_L_SETOR"	, _cSetor		, nil } )

nModulo := 6
cModulo := "FIN"

MSExecAuto( {|x,y| Fina050(x,y) } , _aAutSE2 , 3 )

If lMsErroAuto
	MostraErro()
	_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_NATURE' , 'ZLLMASTER' , 'ZLL_NATURE' , "AGLT01023", "Falhou ao incluir o t�tulo do conv�nio no Financeiro!", "Informe a �rea de TI/ERP.")
	_lOk := .F.
Else
	DBSelectArea('SE2')
	SE2->( DBSetOrder(1) )
	If !SE2->( DBSeek( xFilial('SE2') + _aAutSE2[01][02] + _aAutSE2[02][02] + _aAutSE2[03][02] + _aAutSE2[04][02] + _aAutSE2[06][02] + _aAutSE2[07][02] ) )
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_NATURE' , 'ZLLMASTER' , 'ZLL_NATURE' , "AGLT01024", "Falhou ao incluir o t�tulo do conv�nio no Financeiro!", "Informe a �rea de TI/ERP.")
		_lOk := .F.
	EndIf

EndIf

nModulo := _nModAux
cModulo := _cModAux

Return( _lOk )

/*
===============================================================================================================================
Programa----------: AGLT010V
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para inicializa��o de valores para os campos virtuais da tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT010V( _nOpc )

Local _aArea	:= GetArea()
Local _cAlias	:= ''
Local _nValRet	:= 0

Default _nOpc	:= 0

If !Inclui .And. _nOpc > 0
	
	_cAlias	:= GetNextAlias()
	BeginSql alias _cAlias
	  SELECT SUM(ZLL.ZLL_VALOR) VALOR,
	         SUM(CASE
	               WHEN ZLL.ZLL_STATUS = 'A' THEN
	                ZLL.ZLL_VALOR
	               ELSE
	                0
	             END) VALABR,
	         ROUND(SUM(ZLL.ZLL_VALOR) * (SA2.A2_L_TXADM/100),2) VALADM,
	         SA2.A2_L_TXADM TXADM
	    FROM %table:ZLL% ZLL
	    JOIN %table:SA2% SA2
	      ON SA2.D_E_L_E_T_ = ' '
	     AND SA2.A2_COD = ZLL.ZLL_CONVEN
	     AND SA2.A2_LOJA = ZLL.ZLL_LJCONV
	   WHERE ZLL.D_E_L_E_T_ = ' '
	     AND ZLL_FILIAL = %exp:ZLL->ZLL_FILIAL%
	     AND ZLL_COD = %exp:ZLL->ZLL_COD%
	   GROUP BY SA2.A2_L_TXADM
	EndSql

	If (_cAlias)->( !Eof() )
		Do Case
			Case _nOpc == 1
				_nValRet := (_cAlias)->VALOR
			Case _nOpc == 2
				_nValRet := (_cAlias)->VALABR
			Case _nOpc == 3
				_nValRet := (_cAlias)->TXADM
			Case _nOpc == 4
				_nValRet := (_cAlias)->VALADM
		EndCase
	EndIf

	(_cAlias)->(DbCloseArea())
EndIf

RestArea( _aArea )

Return( _nValRet )

/*
===============================================================================================================================
Programa----------: AGLT010R
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Rotina para inicializa��o do campo nome do produtor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT010R()

Local _oModel	:= FWModelActive()
Local _cRet		:= ''

If !Inclui
	If ValType(_oModel) == "O"
		If _oModel:GetModel('ZLLDETAIL'):nLine > 0
			If !_oModel:GetOperation() == MODEL_OPERATION_UPDATE
				_cRet := AllTrim( Posicione('SA2',1,xFilial('SA2')+_oModel:GetValue('ZLLDETAIL','ZLL_RETIRO')+_oModel:GetValue('ZLLDETAIL','ZLL_RETILJ'),'A2_NOME') )
			EndIf
		Else
			_cRet := AllTrim( Posicione('SA2',1,xFilial('SA2')+ZLL->(ZLL_RETIRO+ZLL_RETILJ),'A2_NOME') )
		EndIf
	Else
		_cRet := AllTrim( Posicione('SA2',1,xFilial('SA2')+ZLL->(ZLL_RETIRO+ZLL_RETILJ),'A2_NOME') )
	EndIf
EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa----------: AGLT010CPA
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Monta a tela para digita��o das datas de parcelas adicionais para o conv�nio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT010CPA( _dVencto )

Local _lOk			:= .F.
Local _aRet			:= {}
Local _nI			:= 0
Local aButtons		:= {}
Local cLinOk		:= "AllwaysTrue"
Local cTudoOk		:= "AllwaysTrue"
Local cIniCpos		:= "ZLL_VENCTO"
Local nFreeze		:= 000
Local nMax			:= 999
Local cFieldOk		:= "AllwaysTrue"
Local cSuperDel		:= ""
Local cDelOk		:= "AllwaysFalse"
Local aHeader		:= {}
Local aCols			:= {}
Local aAlterGDa		:= {}

Private _oDlg		:= NIL
Private _oGetD		:= NIL

// Busca a estrutura de campos para montagem da GetDados
AADD( aAlterGDa  , 'ZLL_VENCTO' )

// Monta a estrutura do cabe�alho
AADD( aHeader , { trim(getsx3cache(aAlterGDa[1],"X3_TITULO") ),;
							getsx3cache(aAlterGDa[1],"X3_CAMPO")		,;
							getsx3cache(aAlterGDa[1],"X3_PICTURE")		,;
							getsx3cache(aAlterGDa[1],"X3_TAMANHO")		,;
							getsx3cache(aAlterGDa[1],"X3_DECIMAL")		,;
							"AllwaysTrue()"									,;
							getsx3cache(aAlterGDa[1],"X3_USADO")		,;
							getsx3cache(aAlterGDa[1],"X3_TIPO")			,;
							getsx3cache(aAlterGDa[1],"X3_ARQUIVO")		,;
							getsx3cache(aAlterGDa[1],"X3_CONTEXT")	})
aCols := { Array( 2 ) }
aCols[ 1 ][ 2 ] := .F.
aCols[ 1 ][ 1 ] := StoD('')

_oDlg := MSDIALOG():New( 000 , 000 , 400 , 300 , 'Parcelamento de conv�nio:' ,,,,,,,,, .T. )

// Constr�i a tela e exibe
_oGetD			:= MsNewGetDados():New(035,001,188,152,3,cLinOk,cTudoOk,cIniCpos,aAlterGDa,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,_oDLG,aHeader,aCols)
_oGetD:bLinhaOk	:= {|| IIF( _oGetD:aCols[_oGetD:nAt][01] < _dVencto , ( Aviso('Aten��o!','A data das parcelas devem ser maiores que o primeiro vencimento do conv�nio ('+DTOC(_dVencto)+")",{'Voltar'}) , .F. ) , .T. ) }

_oDlg:bInit := {|| EnchoiceBar(_oDlg, {|| _lOk := .T. , _oDlg:End() } , {|| _lOk := .F. , _oDlg:End() } ,, aButtons ) , _oGetD:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT }
_oDlg:lCentered := .T.
_oDlg:Activate()

If _lOk
	
	For _nI := 1 To Len( _oGetD:aCols )
		If !_oGetD:aCols[_nI][02] .And. !Empty( _oGetD:aCols[_nI][01] ) .And. aScan( _aRet , {|x| x == _oGetD:aCols[_nI][01] } ) == 0
			aAdd( _aRet , _oGetD:aCols[_nI][01] )
		EndIf
	Next _nI
	
EndIf

Return( _aRet )

/*
===============================================================================================================================
Programa----------: AGLT010VLD
Autor-------------: Alexandre Villar
Data da Criacao---: 13/03/2015
===============================================================================================================================
Descri��o---------: Valida��o inicial da DataBase do Sistema para n�o permitir manuten��o de dados em per�odos bloqueados pelo
------------------: par�metro Fiscal ou Financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT010VLD( _oModel )

Local _lRet		:= .T.

If _oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. _oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. _oModel:GetOperation() == MODEL_OPERATION_DELETE

	If dDataBase < GetMV('MV_DATAFIN')
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_DATA' , 'ZLLMASTER' , 'ZLL_DATA' , "AGLT01034", "A DataBase do Sistema n�o � v�lida de acordo com o par�metro Financeiro.", "Corrija a DataBase ou solicite libera��o para a Contabilidade.")
		//_lRet := .F.//lucas
	EndIf
	
	If _lRet .And. dDataBase <> LastDay( dDataBase )
		_oModel:SetErrorMessage('ZLLMASTER', 'ZLL_DATA' , 'ZLLMASTER' , 'ZLL_DATA' , "AGLT01035", "A DataBase do Sistema n�o � v�lida pois n�o est� posicionada no �ltimo dia do m�s selecionado ("+DTOC(LastDay(dDataBase))+")", "Para realizar a manuten��o no conv�nio configure a DataBase no �ltimo dia do m�s que estiver sendo utilizado.")
		//_lRet := .F.//lucas
	EndIf
	
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT010P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/05/2022
===============================================================================================================================
Descri��o---------: Carrega os produtores que tiveram o evento informado no grid para gera��o do Conv�nio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT010P()

Local _oModel	:= FWModelActive()
Local _oView	:= FWViewActive()
Local _oGrid	:= _oModel:GetModel('ZLLDETAIL')
Local _cAlias	:= GetNextAlias()
Local _lRet		:= .F.
Local _nI		:= 0
Local _cEvento	:= Space(GetSX3Cache("ZLL_EVENTO","X3_TAMANHO"))
Local _cDescri	:= Space(GetSX3Cache("ZL8_DESCRI","X3_TAMANHO"))
Local _cSetor	:= _oModel:GetValue( 'ZLLMASTER' , 'ZLL_SETOR'  )
Local _nTamGrid	:= 0
Local _nProc	:= 0
Local oDlgKey, oBtnOut, oBtnCon

If Empty(_cSetor)
	MsgAlert("O campo "+AllTrim(GetSX3Cache("ZLL_SETOR","X3_TITULO"))+" n�o foi preenchido.","AGLT01025" )	
ElseIf _oModel:GetOperation() == MODEL_OPERATION_INSERT
	DEFINE MSDIALOG oDlgKey TITLE "Evento Mix" FROM 0,0 TO 150,450 PIXEL OF GetWndDefault()

	@ 12,008 SAY "Informe o c�digo do evendo gerado no Mix. Ser� buscado os produtores do Setor que " PIXEL OF oDlgKey
	@ 25,008 SAY "tiveram o evento calculado no MIX. " PIXEL OF oDlgKey
	@ 40,008 MSGET _cEvento SIZE 50,10 PIXEL OF oDlgKey VALID {||IIf(ExistCpo("ZL8",_cEvento), _cDescri:= Posicione('ZL8',1,xFilial('ZL8')+_cEvento,'ZL8_DESCRI'),.F.)} Pixel F3 "ZL8_01"
	@ 40,060 MSGET _cDescri SIZE 160,10 PIXEL OF oDlgKey WHEN .F.

	@ 60,060 BUTTON oBtnCon PROMPT "&Confirma" SIZE 38,11 PIXEL ACTION (IIf(!Empty(_cEvento),_lRet := .T.,;
			MsgStop("Evento n�o informado.","AGLT01026" )) , oDlgKey:End())
	@ 60,100 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()

	ACTIVATE DIALOG oDlgKey CENTERED

	If _lRet
		BeginSql alias _cAlias
			SELECT ZLF_A2COD, ZLF_A2LOJA, SUM(ZLF_TOTAL) ZLF_TOTAL
			FROM %Table:ZLF%
			WHERE D_E_L_E_T_ = ' '
			AND ZLF_FILIAL = %xFilial:ZLF%
			AND ZLF_SETOR = %Exp:_cSetor%
			AND ZLF_DTFIM = %Exp:dDataBase%
			AND ZLF_EVENTO = %Exp:_cEvento%
			GROUP BY ZLF_A2COD, ZLF_A2LOJA
			ORDER BY ZLF_A2COD, ZLF_A2LOJA
		EndSql

		_nTamGrid := _oGrid:Length()
		//Apaga grid atual
		For _nI := 1 To _oGrid:Length()
			_oGrid:GoLine( _nI )
			If !_oGrid:IsDeleted()
				_oGrid:DeleteLine()
			EndIf
		Next _nI

		Do While (_cAlias)->(!EOF())
			_nProc ++
			If _nProc <= _nTamGrid
				_oGrid:GoLine(_nProc)
				If _oGrid:IsDeleted()
					_oGrid:UnDeleteLine()
				EndIf
				_oView:Refresh()
			Else
				_nTamGrid := _oGrid:AddLine()
				_oView:Refresh()
				_oGrid:GoLine(_nProc)
			EndIf
			_oModel:SetValue( 'ZLLDETAIL','ZLL_RETIRO',(_cAlias)->ZLF_A2COD)
			_oModel:SetValue( 'ZLLDETAIL','ZLL_RETILJ',(_cAlias)->ZLF_A2LOJA)
			_oModel:SetValue( 'ZLLDETAIL','ZLL_VALOR',(_cAlias)->ZLF_TOTAL)
			_oView:Refresh()
			(_cAlias)->(DBSkip())
		EndDo
		(_cAlias)->(DBCloseArea())
	EndIf
Else
	MsgAlert("Fun��o dispon�vel apenas na Inclus�o.","AGLT01027" )
EndIf
Return
