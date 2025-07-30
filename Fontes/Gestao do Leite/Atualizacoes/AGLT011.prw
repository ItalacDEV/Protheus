/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/01/2020 | Corrigido totalizador do conv�nio. Chamado 31761
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 06/02/2020 | Corrigido nome do objeto. Chamado 31941
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 20/10/2020 | Corrigida a exclus�o de t�tulos. Chamado 34436
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch' 
#Include "FWMVCDEF.ch"

/*
===============================================================================================================================
Programa----------: AGLT011
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para lan�amentos dos conv�nios de terceiros, c�pia do AGLT010 - Chamado 11132
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT011()

Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias('ZLI')
_oBrowse:SetDescription('Lan�amentos dos Conv�nios Terceiros')

_oBrowse:AddLegend( "ZLI_STATUS == 'A'" , 'GREEN'	, 'Conv�nio em aberto'	)
_oBrowse:AddLegend( "ZLI_STATUS == 'P'" , 'RED'		, 'Conv�nio pago'		)
_oBrowse:AddLegend( "ZLI_STATUS == 'S'" , 'BLUE'	, 'Conv�nio Suspenso'	)

_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
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

ADD OPTION _aRotina Title 'Visualizar'	Action 'VIEWDEF.AGLT011' OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'		Action 'VIEWDEF.AGLT011' OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'		Action 'VIEWDEF.AGLT011' OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'		Action 'VIEWDEF.AGLT011' OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Copiar'		Action 'VIEWDEF.AGLT011' OPERATION 9 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Monta o Modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oStruCAB	:= FWFormStruct( 1 , 'ZLI' , { |_cCampo| AGLT011CPO( _cCampo , 1 ) } )
Local _oStruITN	:= FWFormStruct( 1 , 'ZLI' , { |_cCampo| AGLT011CPO( _cCampo , 2 ) } )
Local _oModel	:= Nil
Local _aGatAux	:= {}

_aGatAux := FwStruTrigger( 'ZLI_EVENTO'	, 'ZLI_DESEVE'	, 'ZT1->ZT1_DESCRI'	, .T. , 'ZT1' , 1 , 'xFilial("ZT1")+M->ZLI_EVENTO'	)
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_EVENTO'	, 'ZLI_DESEVE'	, 'U_GL011RET( 4 , M->ZLI_EVENTO  )'	, .F.	)
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_CONVEN'	, 'ZLI_DESCRI'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLI_CONVEN+AllTrim(M->ZLI_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_CONVEN'	, 'ZLI_LJCONV'	, 'IIF( Empty(M->ZLI_LJCONV) , "0001" , M->ZLI_LJCONV )'	, .F. )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_LJCONV'	, 'ZLI_DESCRI'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLI_CONVEN+AllTrim(M->ZLI_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_CONVEN'	, 'ZLI_PERADM'	, 'SA2->A2_L_TXADM'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLI_CONVEN+AllTrim(M->ZLI_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_LJCONV'	, 'ZLI_PERADM'	, 'SA2->A2_L_TXADM'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLI_CONVEN+AllTrim(M->ZLI_LJCONV)' )
_oStruCAB:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_RETIRO'	, 'ZLI_RETIRO'	, 'U_GL011RET( 1 , M->ZLI_RETIRO )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_RETIRO'	, 'ZLI_RETILJ'	, 'U_GL011RET( 2 , M->ZLI_RETIRO , M->ZLI_RETILJ )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_RETIRO'	, 'ZLI_RETILJ'	, 'U_GL011RET( 3 , M->ZLI_RETIRO , M->ZLI_RETILJ )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_RETIRO'	, 'ZLI_DCRRET'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLI_RETIRO+AllTrim(M->ZLI_RETILJ)' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_RETILJ'	, 'ZLI_DCRRET'	, 'SA2->A2_NOME'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLI_RETIRO+AllTrim(M->ZLI_RETILJ)' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLI_VALOR'	, 'ZLI_VALOR'	, 'U_GL011LOK( M->ZLI_VALOR )' , .F. )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel := MPFormModel():New( 'AGLT011M' ,, {|| AGLT011TOK() } )

_oModel:SetDescription( 'Lan�amentos dos Conv�nios' )

_oModel:AddFields(	"ZLIMASTER" , /*cOwner*/  , _oStruCAB )
_oModel:AddGrid(	"ZLIDETAIL" , "ZLIMASTER" , _oStruITN , { | _oModel , _nLine , _cAction , _cField | AGLT011LOK( _nLine , _cAction , _cField ) } )

_oModel:SetRelation( "ZLIDETAIL" , {	{ 'ZLI_FILIAL'	, 'xFilial("ZLI")'	} ,;
										{ 'ZLI_COD'		, 'ZLI_COD'			} }, ZLI->( IndexKey( 1 ) ) )

_oModel:GetModel( 'ZLIDETAIL' ):SetUniqueLine( { 'ZLI_SEQ' } )

_oModel:GetModel( "ZLIMASTER" ):SetDescription( "Dados do Conv�nio"		)
_oModel:GetModel( "ZLIDETAIL" ):SetDescription( "Itens do Lan�amento"	)

_oModel:SetPrimaryKey( { 'ZLI_FILIAL' , 'ZLI_COD' , 'ZLI_SEQ' } )

_oModel:GetModel( 'ZLIMASTER' ):AFLDNOCOPY := {  'ZLI_DATA' , 'ZLI_VENCTO' }
_oModel:GetModel( 'ZLIDETAIL' ):AFLDNOCOPY := { 'ZLI_STATUS' }

//==================================
// Define valida��o inical do modelo
//==================================
_oModel:SetVldActivate( { |_oModel| AGLT011VLD( _oModel ) } )

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Define a View de dados para a rotina de cadastro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()

Local _oModel  	:= FWLoadModel( 'AGLT011' )
Local _oStruCAB	:= FWFormStruct( 2 , 'ZLI' , { |cCampo| AGLT011CPO( cCampo , 1 ) } )
Local _oStruITN	:= FWFormStruct( 2 , 'ZLI' , { |cCampo| AGLT011CPO( cCampo , 2 ) } )
Local _oView	:= Nil

//=========================================
// Configura��o para agrupamento dos campos
//=========================================
_oStruCAB:AddGroup( 'GRUPO01' , 'Conv�nio'						, '' , 2 )
_oStruCAB:AddGroup( 'GRUPO02' , 'Valores do Conv�nio'			, '' , 2 )

_oStruCAB:SetProperty( 'ZLI_COD'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_NATURE'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_EVENTO'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_DESEVE'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_CONVEN'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_LJCONV'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_DESCRI'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_DATA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruCAB:SetProperty( 'ZLI_VENCTO'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )

_oStruCAB:SetProperty( 'ZLI_VALTOT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLI_VLRABR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLI_ACRESC'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLI_PERADM'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruCAB:SetProperty( 'ZLI_VTXADM'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )

_oView := FWFormView():New()

_oView:SetModel( _oModel )
_oView:AddField( "VIEW_CAB"	, _oStruCAB	, "ZLIMASTER" )
_oView:AddGrid(  "VIEW_ITN"	, _oStruITN	, "ZLIDETAIL" )

_oView:CreateHorizontalBox( 'BOX0101' , 55 )
_oView:CreateHorizontalBox( 'BOX0102' , 45 )
_oView:SetOwnerView( "VIEW_CAB" , "BOX0101" )
_oView:SetOwnerView( "VIEW_ITN" , "BOX0102" )

_oView:AddIncrementField( 'VIEW_ITN' , 'ZLI_SEQ' )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT011CPO
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Define a organiza��o dos campos para exibi��o na tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT011CPO( _cCampo , _nOpc )

Local _lRet := Upper( AllTrim(_cCampo) ) $ 'ZLI_FILIAL/ZLI_COD/ZLI_EVENTO/ZLI_DESEVE/ZLI_CONVEN/ZLI_LJCONV/ZLI_DESCRI/ZLI_DATA/ZLI_VENCTO/ZLI_NATURE/ZLI_VALTOT/ZLI_VLRABR/ZLI_ACRESC/ZLI_PERADM/ZLI_VTXADM'

If _nOpc == 2
	_lRet := !_lRet
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: GL010LOK
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para Atualiza��o dos valores conforme preenchimento dos campos das linhas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function GL011LOK( _nValRet )

Local _oModel	:= FWModelActive()
Local _aSaveLines := FWSaveRows()
Local _oZLIDET	:= _oModel:GetModel( 'ZLIDETAIL' )
Local _nI		:= 0
Local _nValor	:= 0
Local _nValAbr	:= 0
Local _nValAdm	:= 0
Local _nValTot	:= 0
Local _nTxAdm	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_PERADM' )

For _nI := 1 To _oZLIDET:Length()
	
	_oZLIDET:GoLine( _nI )
	If !_oZLIDET:IsDeleted()
		_nValor		:= _oZLIDET:GetValue( 'ZLI_VALOR' )
		_nValTot	+= _nValor
			
		_oModel:SetValue( 'ZLIDETAIL' , 'ZLI_TXADM' , _nValor * ( _nTxAdm / 100 ) )
		_nValAdm	+= _oZLIDET:GetValue( 'ZLI_TXADM' )
			
		If _oZLIDET:GetValue( 'ZLI_STATUS' ) == 'A'
			_nValAbr += _nValor
		EndIf
	EndIf
Next _nI

_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VALTOT' , _nValTot )
_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VTXADM' , _nValAdm )
_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VLRABR' , _nValAbr )
FWRestRows( _aSaveLines )

Return( _nValRet )

/*
===============================================================================================================================
Programa----------: AGLT011LOK
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para valida��o das opera��es de altera��o/delete das linhas de lan�amentos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT011LOK( _nLine , _cAction , _cField )

Local _lRet		:= .T.
Local _oModel	:= FWModelActive()
Local _nValor	:= 0
Local _nValTX	:= 0
Local _nValTot	:= 0
Local _nValTXA	:= 0

If _oModel:GetValue( 'ZLIDETAIL' , 'ZLI_STATUS' ) == 'A'

	If Upper(AllTrim(_cAction)) $ 'DELETE/UNDELETE'
	
		_nValor		:= _oModel:GetValue( 'ZLIDETAIL' , 'ZLI_VALOR' )
		_nValTX		:= _oModel:GetValue( 'ZLIDETAIL' , 'ZLI_TXADM' )
		_nValTot	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_VALTOT' )
		_nValABR	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_VLRABR' )
		_nValTXA	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_VTXADM' )
	
		If Upper(AllTrim(_cAction)) == 'DELETE'
		
			_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VTXADM' , _nValTXA - _nValTX )
			_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VLRABR' , _nValABR - _nValor )
			_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VALTOT' , _nValTot - _nValor )
			
		Else
		
			_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VTXADM' , _nValTXA + _nValTX )
			_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VLRABR' , _nValABR + _nValor )
			_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_VALTOT' , _nValTot + _nValor )
			
		EndIf
	
	EndIf
	
Else
	_oModel:SetErrorMessage('ZLIDETAIL', 'ZLI_STATUS' , 'ZLIDETAIL' , 'ZLI_STATUS' , "AGLT01101", "N�o � poss�vel realizar a opera��o no registro atual!", "Somente registros 'Em Aberto' podem ser alterados, exclu�dos ou restaurados.")
	_lRet := .F.
EndIf
	
Return( _lRet )

/*
===============================================================================================================================
Programa----------: GL010RET
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina auxiliar para processamento dos gatilhos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function GL011RET( _nOpcao , _cRetiro , _cLoja )

Local _cRet		:= ''
Local _oModel	:= FWModelActive()

If _nOpcao == 1

	DBSelectArea('SA2')
	SA2->( DBSetOrder(1) )
	If SA2->( DBSeek( xFilial('SA2') + _cRetiro ) )
	
		_oModel:LoadValue( 'ZLIDETAIL' , 'ZLI_RETIRO' , SA2->A2_COD )
		_cRet := SA2->A2_COD
		
	Else
		_oModel:SetErrorMessage('ZLIDETAIL', 'ZLI_RETIRO' , 'ZLIDETAIL' , 'ZLI_RETIRO' , "AGLT01102", "O Produtor informado n�o � v�lido ou n�o foi encontrado no Sistema!", "Verifique os dados digitados e tente novamente.")
	    _oModel:LoadValue( 'ZLIDETAIL' , 'ZLI_RETIRO' , '' )
	EndIf

Elseif _nOpcao == 2
	
	DBSelectArea('SA2')
	SA2->( DBSetOrder(1) )
	If SA2->( DBSeek( xFilial('SA2') + _cRetiro + AllTrim( _cLoja ) ) )
	    
		_oModel:LoadValue( 'ZLIDETAIL' , 'ZLI_RETILJ' , SA2->A2_LOJA )
		_cRet := SA2->A2_LOJA
		
	Else
		_oModel:SetErrorMessage('ZLIDETAIL', 'ZLI_RETILJ' , 'ZLIDETAIL' , 'ZLI_RETILJ' , "AGLT01103", "O Produtor informado n�o � v�lido ou n�o foi encontrado no Sistema!", "Verifique os dados digitados e tente novamente.")
	    _oModel:LoadValue( 'ZLIDETAIL' , 'ZLI_RETILJ' , '' )
	EndIf 
	
Elseif _nOpcao == 3

	DBSelectArea('ZT1')
	ZT1->( DBSetOrder(1) )
	If ZT1->( DBSeek( xFilial('ZT1') + M->ZLI_EVENTO ) )
		_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_NATURE' , ZT1->ZT1_NATURE )
		_cRet := _cLoja
	EndIf

ElseIf _nOpcao == 4


  _cret := ZT1->ZT1_DESCRI  
  
	If Len(_omodel:AALLSUBMODELS[2]:ACOLS) > 0 .and. Len(alltrim(_omodel:AALLSUBMODELS[2]:ACOLS[1][2])) == 6
		_oModel:LoadValue( 'ZLIMASTER' , 'ZLI_NATURE' , ZT1->ZT1_NATURE )
	EndIf

EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa----------: AGLT011TOK
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para Valida��o Total do modelo de dados e grava��es auxiliares
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT011TOK()

Local _lRet		:= .T.
Local _aValid	:= {}
Local _aMovPer	:= {}
Local _oModel	:= FWModelActive()
Local _oGrid	:= _oModel:GetModel( 'ZLIDETAIL' )
Local _cCodigo	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_COD'    )
Local _cConven	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_CONVEN' )
Local _cLjConv	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_LJCONV' )
Local _nVlrTot	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_VALTOT' )
Local _nAcresc	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_ACRESC' )
Local _nTxAdm	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_VTXADM' )
Local _cCodPro	:= ''
Local _cLojPro	:= ''
Local _cNatAux	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_NATURE' ) //Natureza da NF
Local _cNatNDF	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_NATURE' ) //Natureza da NDF
Local _cPrefix	:= ''
Local _dEmissa	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_DATA'   )
Local _dVencto	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_VENCTO' )
Local _cEvento	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_EVENTO' )
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
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_CONVEN' , 'ZLIMASTER' , 'ZLI_CONVEN' , "AGLT01104", "O conv�nio informado est� bloqueado no cadastro de Fornecedores do Sistema!", "Verifique o cadastro do conv�nio ou os dados informados para confirmar.")
		_lRet := .F.
	EndIf
Else
	_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_CONVEN' , 'ZLIMASTER' , 'ZLI_CONVEN' , "AGLT01105", "O conv�nio informado n�o foi encontrado no cadastro de Fornecedores do Sistema!", "Verifique o cadastro do conv�nio ou os dados informados para confirmar.")
	_lRet := .F.
EndIf

If _lRet

	//============================================
	// Valida��o das datas de Emiss�o x Vencimento
	//============================================
	If _dEmissa > _dVencto
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_VENCTO' , 'ZLIMASTER' , 'ZLI_VENCTO' , "AGLT01106", "A data de vencimento do conv�nio n�o � v�lida!", "O vencimento deve ser maior ou igual � data de emiss�o do conv�nio.")
		_lRet := .F.
	EndIf
	
	//===========================================================
	// Valida��o do preenchimento de todos os campos obrigat�rios
	//===========================================================
	If _lRet .And. ( Empty(_cConven) .Or. Empty(_cLjConv) .Or. Empty( _dEmissa ) .Or. Empty( _dVencto ) .Or. Empty( _cEvento ))
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_CONVEN' , 'ZLIMASTER' , 'ZLI_CONVEN' , "AGLT01107", "Existem campos do conv�nio que n�o foram preenchidos!", "Verifique os dados e informe todos os campos obrigat�rios para confirmar.")
		_lRet := .F.
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
		
			_cCodPro	:= _oGrid:GetValue( 'ZLI_RETIRO' )
			_cLojPro	:= _oGrid:GetValue( 'ZLI_RETILJ' )
			_cNomPro	:= Posicione( 'SA2' , 1 , xFilial('SA2') + _cCodPro + _cLojPro , 'A2_NOME' )
			
			If Empty( _cCodPro ) .Or. Empty( _cLojPro ) .Or. Empty( _cNomPro )
				_oModel:SetErrorMessage('ZLIDETAIL', 'ZLI_RETIRO' , 'ZLIDETAIL' , 'ZLI_RETIRO' , "AGLT01108", "� obrigat�rio informar um produtor para todas os lan�amentos do Conv�nio!", "Verifique os lan�amentos e informe produtores v�lidos para todas as linhas.")
				_lRet := .F.
				Exit
			EndIf
			
			If SA2->A2_MSBLQL == '1'
				aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'O fornecedor encontra-se bloqueado no cadastro do Sistema' } )
			EndIf
			
			If _oGrid:GetValue( 'ZLI_VALOR' ) <= 0
				aAdd( _aValid , { _cCodPro+'/'+_cLojPro , _cNomPro , 'N�o foi informado um valor v�lido para o lan�amento do conv�nio' } )
			EndIf
			
		EndIf
			
	Next _nI

EndIf

If _lRet .And. !Empty( _aValid ) .And. _oModel:GetOperation() <> MODEL_OPERATION_DELETE
	
	U_ITListBox( 'N�o conformidades nos lan�amentos' , { 'C�digo' , 'Nome' , 'Avalia��o' } , _aValid , .F. , 1 , 'Verifique os lan�amentos abaixo:' ,, {50,100,200} )
	_oModel:SetErrorMessage('ZLIDETAIL', 'ZLI_RETIRO' , 'ZLIDETAIL' , 'ZLI_RETIRO' , "AGLT01109", "Existem lan�amentos que n�o passaram na valida��o!", "Verifique os dados do relat�rio exibido e corrija os lan�amentos com problema.")
	_lRet := .F.
	
EndIf

If _lRet .And. !Empty( _aMovPer ) .And. _oModel:GetOperation() <> MODEL_OPERATION_DELETE
	
	_lRet := U_ITListBox( 'Produtores sem movimenta��o no per�odo' , { 'C�digo' , 'Nome' , 'Avalia��o' } , _aMovPer , .F. , 1 , 'Verifique os lan�amentos abaixo:' ,, {50,100,200} )
	
	If !_lRet
		_oModel:SetErrorMessage('ZLIDETAIL', 'ZLI_RETIRO' , 'ZLIDETAIL' , 'ZLI_RETIRO' , "AGLT01110", "Foi cancelada a opera��o por conta de produtores sem movimenta��o no per�odo!", "Verifique os dados e caso necess�rio confirme mesmo com produtores sem movimenta��o para continuar.")
	EndIf
	
EndIf

//================================================================
// Se passar pelas valida��es processa as grava��es complementares
//================================================================
If _lRet
	
	_nOper		:= _oModel:GetOperation()
	_cNumTit	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_COD'    )
	_cNatNDF	:= _oModel:GetValue( 'ZLIMASTER' , 'ZLI_NATURE' )
	
	_cNatAux	:= POSICIONE( "ZT1" , 1 , XFILIAL("ZT1") + _cEvento , "ZT1_NATURE" ) ; IIF( Empty(_cNatAux) , _cNatAux := _cNatNDF , Nil )
	_cPrefix	:= ZT1->ZT1_PREFIX
	
	If _nOper == MODEL_OPERATION_INSERT
		
		If MsgYesNo("Deseja replicar e criar novas parcelas iguais a configura��o do conv�nio atual para meses posteriores?","AGLT01111" )
			
			_lParc := .F.
			
			_aParAux := AGLT011CPA( _dVencto )
			
			If Empty(_aParAux)
				_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_NATURE' , 'ZLIMASTER' , 'ZLI_NATURE' , "AGLT01112", "A gera��o de parcelas n�o foi realizada pelo usu�rio e ser� gerado apenas o registro do conv�nio!", "Caso necess�rio, revise os dados informados.")
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
	    ZT1->(Dbseek(ZLI->(ZLI_FILIAL+ZLI_EVENTO)))
		_lRet := AGLT011DE2( ZT1->ZT1_PREFIX , _cNumTit + '000' , '1 ' , 'NF ' , ZLI->ZLI_CONVEN , ZLI->ZLI_LJCONV , ZLI->ZLI_NATURE, _oModel )
		
		If _lRet
			If _nOper == MODEL_OPERATION_UPDATE
				MsgInfo("O Titulo da NF foi excluido e ser� gerado novamente com os novos valores!","AGLT01113")
			EndIf
		EndIf
	
	EndIf
	
	If _lRet
	
		//======================
		// Guarda posi��o do ZLI
		//======================
		_aareaZLI := getarea("ZLI")
		
		//=========================================================
		// Grava��o dos t�tulos de todos os lan�amentos do conv�nio
		//=========================================================
		For _nI := 1 To _nLinhas
		
			_oGrid:GoLine(_nI)
			
			_cSeq		:= _oGrid:GetValue( 'ZLI_SEQ'    )
			_cCodPrd	:= _oGrid:GetValue( 'ZLI_RETIRO' )
			_cLojPrd	:= _oGrid:GetValue( 'ZLI_RETILJ' )
			_nValor		:= _oGrid:GetValue( 'ZLI_VALOR'  )
			_cStatus	:= _oGrid:GetValue( 'ZLI_STATUS' )
			
			//===============================================
			// Posiciona ZLI para saber o que alterou na tela
			//===============================================
			ZLI->(Dbsetorder(1))
			ZLI->(Dbseek(xFilial("ZLI") + _cCodigo + _cSeq))
			
			//================================================
			// Tratativa para os lan�amentos deletados no Grid
			//================================================
			If _oGrid:IsDeleted() .And. _nOper == MODEL_OPERATION_UPDATE
				_lRet := AGLT011DE2( ZT1->ZT1_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLI->ZLI_RETIRO , ZLI->ZLI_RETILJ , ZLI->ZLI_NATURE, _oModel )
			Elseif  !(_oGrid:IsDeleted())
			
				//==========================================
				// Na Inclus�o gera os t�tulos no Financeiro
				//==========================================
				If _nOper == MODEL_OPERATION_INSERT 
					_lRet := AGLT011IE2( _cPrefix , _cNumTit + _cSeq , '1 ' , 'NDF' , _cCodPrd , _cLojPrd , _cNatNDF , _dEmissa , _dVencto , _nValor , 0 , 0 , _oModel )
				EndIf
				
				//=======================================================
				// Tratativa para os lan�amentos na opera��o de altera��o
				//=======================================================
				If _nOper == MODEL_OPERATION_UPDATE
					
					//========================================================
					// Se a linha for "Suspensa" deleta o t�tulo no Financeiro
					//========================================================
					If _oGrid:GetValue('ZLI_STATUS') == 'S'
					
						_lRet := AGLT011DE2( ZT1->ZT1_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLI->ZLI_RETIRO , ZLI->ZLI_RETILJ , ZLI->ZLI_NATURE, _oModel )
					
					//=================================================================================================
					// Se a linha for "Alterada" e o Status estiver Em Aberto dever� excluir e gerar o T�tulo novamente
					//=================================================================================================
					ElseIf _oGrid:GetValue('ZLI_STATUS') == 'A'
					
						If AGLT011DE2( ZT1->ZT1_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLI->ZLI_RETIRO , ZLI->ZLI_RETILJ , ZLI->ZLI_NATURE, _oModel )
						 	_lRet := AGLT011IE2( _cPrefix , _cNumTit + _cSeq , '1 ' , 'NDF' , _cCodPrd , _cLojPrd , _cNatNDF , _dEmissa , _dVencto , _nValor , 0 , 0 , _oModel )
						Else
							
							DBSelectArea('SE2')
							SE2->( DBSetOrder(1) )
							If SE2->( DBSeek( xFilial('SE2') + ZT1->ZT1_PREFIX + _cNumTit + _cSeq + '1 ' + 'NDF' + ZLI->(ZLI_RETIRO+ZLI_RETILJ) ) )
								_lRet := .F.
							Else
								_lRet := AGLT011IE2( _cPrefix , _cNumTit + _cSeq , '1 ' , 'NDF' , _cCodPrd , _cLojPrd , _cNatNDF , _dEmissa , _dVencto , _nValor , 0 , 0 , _oModel )
							EndIf
						EndIf
						
					EndIf
				
				EndIf
					
				//===============================================================================
				// Para a opera��o de exclus�o do conv�nio dever�o ser exclu�dos todos os t�tulos
				//===============================================================================
				If _nOper == MODEL_OPERATION_DELETE
					_lRet := AGLT011DE2( ZT1->ZT1_PREFIX , _cNumTit + _cSeq , '1 ' , 'NDF' , ZLI->ZLI_RETIRO , ZLI->ZLI_RETILJ , ZLI->ZLI_NATURE, _oModel )
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
		// Retorna posi��o e �ndice da ZLI
		//================================
		ZLI->(Restarea(_aareaZLI))
			
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
					_lRet := AGLT011IE2( _cPrefix , _cNumTit + '000' , '1 ' , 'NF ' , _cConven , _cLjConv , _cNatAux , _dEmissa , _dVencto , _nVlrTot , _nAcresc , _nTxAdm , _oModel )
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
			
				aAdd( _aDados , {	_oModel:GetValue( 'ZLIMASTER' , 'ZLI_NATURE'	) ,;
									_oModel:GetValue( 'ZLIDETAIL' , 'ZLI_SEQ'		) ,;
									_oModel:GetValue( 'ZLIDETAIL' , 'ZLI_RETIRO'	) ,;
									_oModel:GetValue( 'ZLIDETAIL' , 'ZLI_RETILJ'	) ,;
									_oModel:GetValue( 'ZLIDETAIL' , 'ZLI_VALOR'		) ,;
									_oModel:GetValue( 'ZLIDETAIL' , 'ZLI_TXADM'		) ,;
									_oModel:GetValue( 'ZLIDETAIL' , 'ZLI_STATUS'	) ,;
									_oModel:GetValue( 'ZLIDETAIL' , 'ZLI_OBSERV'	) })
			
			EndIf
			
		Next _nI
		
		For _nI := 1 To Len( _aParAux )
			
			_cCodZLI := GetSXENum( 'ZLI' , 'ZLI_COD' )
			
			If __lSX8
				ConfirmSX8()
			EndIf
			
			//==============================================================================================
			// Pega a data de emiss�o baseada no vencimento: deve ser o �ltimo dia do m�s anterior ao vencto
			//==============================================================================================
			_dEmissa := LastDay( MonthSub( _aParAux[_nI] , 1 ) )
			
			DBSelectArea('ZLI')
			
			For _nX := 1 To Len( _aDados )
				
				ZLI->( RecLock( 'ZLI' , .T. ) )
				
				ZLI->ZLI_FILIAL		:= xFilial('ZLI')
				ZLI->ZLI_COD		:= _cCodZLI
				ZLI->ZLI_NATURE		:= _aDados[_nX][01]
				ZLI->ZLI_EVENTO		:= _cEvento
				ZLI->ZLI_DATA		:= _dEmissa
				ZLI->ZLI_VENCTO		:= _aParAux[_nI]
				ZLI->ZLI_CONVEN		:= _cConven
				ZLI->ZLI_LJCONV		:= _cLjConv
				ZLI->ZLI_ACRESC		:= _nAcresc
				ZLI->ZLI_SEQ		:= _aDados[_nX][02]
				ZLI->ZLI_RETIRO		:= _aDados[_nX][03]
				ZLI->ZLI_RETILJ		:= _aDados[_nX][04]
				ZLI->ZLI_VALOR		:= _aDados[_nX][05]
				ZLI->ZLI_TXADM		:= _aDados[_nX][06]
				ZLI->ZLI_STATUS		:= _aDados[_nX][07]
				ZLI->ZLI_OBSERV		:= _aDados[_nX][08]
				
				ZLI->( MsUnLock() )
				
				//=====================================
				// Inclui nova NDF para a parcela atual
				//=====================================
				If !AGLT011IE2( _cPrefix , ZLI->( ZLI_COD + ZLI_SEQ ) , '1 ' , 'NDF' , ZLI->ZLI_RETIRO , ZLI->ZLI_RETILJ , ZLI->ZLI_NATURE , ZLI->ZLI_DATA , ZLI->ZLI_VENCTO , ZLI->ZLI_VALOR , 0 , 0 , _oModel )
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
			
				If !AGLT011IE2( _cPrefix , _cCodZLI + '000' , '1 ' , 'NF ' , _cConven , _cLjConv , _cNatAux , _dEmissa , _aParAux[_nI] , _nVlrTot , _nAcresc , _nTxAdm , _oModel )
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
_aAreaZLI := ZLI->(GetArea())
If _lRet .And. _oModel:GetOperation() == MODEL_OPERATION_UPDATE
	dbSelectArea("ZLI")
	dbSetOrder(1)
	If dbSeek(xFilial("ZLI") + _cCodigo)
		While !ZLI->(Eof()) .And. ZLI->ZLI_FILIAL == xFilial("ZLI") .And. ZLI->ZLI_COD == _cCodigo
			RecLock("ZLI", .F.)
				ZLI->ZLI_EVENTO	:= _cEvento
				ZLI->ZLI_CONVEN	:= _cConven
				ZLI->ZLI_LJCONV	:= _cLjConv
				ZLI->ZLI_VENCTO	:= _dVencto
				ZLI->ZLI_ACRESC	:= _nAcresc
			MsUnLock()
			ZLI->(dbSkip())
		End
	EndIf
EndIf
RestArea(_aAreaZLI)
Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT011DE2
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para exclus�o de T�tulos do Financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function AGLT011DE2( _cPrefix , _cNumTit , _cParcel , _cTipo , _cForn , _cLoja , _cNature, _oModel )

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
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_NATURE' , 'ZLIMASTER' , 'ZLI_NATURE' , "AGLT01114", "T�tulo sofreu baixas e n�o poder� ser exclu�do. T�tulo: " + _cPrefix + _cNumTit + _cParcel + _cTipo + _cForn + _cLoja, "Exclua a baixa antes de realizar a opera��o.")
	    _lOk := .F.
	Else
	
		_aAutSE2 := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
	                { "E2_NUM"     , SE2->E2_NUM     , NIL } }

		MSExecAuto( {|x,y,z| Fina050(x,y,z) } , _aAutSE2 ,, 5 )

		If lMsErroAuto
			MostraErro()
			_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_NATURE' , 'ZLIMASTER' , 'ZLI_NATURE' , "AGLT01115", "Falhou ao excluir o t�tulo do conv�nio no Financeiro!", "Informe a �rea de TI/ERP.")
			_lOk := .F.
		EndIf
		
    EndIf
Else                            

	If _cForn <> 'F00001'
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_NATURE' , 'ZLIMASTER' , 'ZLI_NATURE' , "AGLT01116", "N�o encontrou o t�tulo do conv�nio no  Financeiro!", "Informe a �rea de TI/ERP.")
		_lOk := .F.
	EndIf

EndIf

nModulo := _nModAux
cModulo := _cModAux

RestArea(aArea)

Return( _lOk )

/*
===============================================================================================================================
Programa----------: AGLT011IE2
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para inclus�o de T�tulos no Financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT011IE2( _cPrefix , _cNumTit , _cParcel , _cTipo , _cForn , _cLoja , _cNature , _dEmissa , _dVencto , _nValor , _nAcres , _nDesc , _oModel )

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
AAdd( _aAutSE2 , { "E2_HIST"	, "GLT CONVENIO DE TERCEIROS", nil } )
AAdd( _aAutSE2 , { "E2_DATALIB"	, _dEmissa		, nil } )	
AAdd( _aAutSE2 , { "E2_USUALIB"	, cUserName		, nil } )	
AAdd( _aAutSE2 , { "E2_ORIGEM"	, "AGLT011"		, nil } )

nModulo := 6
cModulo := "FIN"

MSExecAuto( {|x,y| Fina050(x,y) } , _aAutSE2 , 3 )

If lMsErroAuto
	MostraErro()
	_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_NATURE' , 'ZLIMASTER' , 'ZLI_NATURE' , "AGLT01117", "Falhou ao incluir o t�tulo do conv�nio no Financeiro!", "Informe a �rea de TI/ERP.")
	_lOk := .F.
Else
	DBSelectArea('SE2')
	SE2->( DBSetOrder(1) )
	If !SE2->( DBSeek( xFilial('SE2') + _aAutSE2[01][02] + _aAutSE2[02][02] + _aAutSE2[03][02] + _aAutSE2[04][02] + _aAutSE2[06][02] + _aAutSE2[07][02] ) )
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_NATURE' , 'ZLIMASTER' , 'ZLI_NATURE' , "AGLT01118", "Falhou ao incluir o t�tulo do conv�nio no Financeiro!", "Informe a �rea de TI/ERP.")
		_lOk := .F.
	EndIf

EndIf

nModulo := _nModAux
cModulo := _cModAux

Return( _lOk )

/*
===============================================================================================================================
Programa----------: AGLT011V
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para inicializa��o de valores para os campos virtuais da tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT011V( _nOpc )

Local _aArea	:= GetArea()
Local _cAlias	:= ''
Local _nValRet	:= 0

Default _nOpc	:= 0

If !Inclui .And. _nOpc > 0
	
	_cAlias	:= GetNextAlias()
	BeginSql alias _cAlias
	  SELECT SUM(ZLI.ZLI_VALOR) VALOR,
	         SUM(CASE
	               WHEN ZLI.ZLI_STATUS = 'A' THEN
	                ZLI.ZLI_VALOR
	               ELSE
	                0
	             END) VALABR,
	         ROUND(SUM(ZLI.ZLI_VALOR) * (SA2.A2_L_TXADM/100),2) VALADM,
	         SA2.A2_L_TXADM TXADM
	    FROM %table:ZLI% ZLI
	    JOIN %table:SA2% SA2
	      ON SA2.D_E_L_E_T_ = ' '
	     AND SA2.A2_COD = ZLI.ZLI_CONVEN
	     AND SA2.A2_LOJA = ZLI.ZLI_LJCONV
	   WHERE ZLI.D_E_L_E_T_ = ' '
	     AND ZLI_FILIAL = %exp:ZLI->ZLI_FILIAL%
	     AND ZLI_COD = %exp:ZLI->ZLI_COD%
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
Programa----------: AGLT011R
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Rotina para inicializa��o do campo nome do produtor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT011R()

Local _oModel	:= FWModelActive()
Local _cRet		:= ''

If !Inclui
	If ValType(_oModel) == "O"
		If _oModel:GetModel('ZLIDETAIL'):nLine > 0
			If !_oModel:GetOperation() == MODEL_OPERATION_UPDATE
				_cRet := AllTrim( Posicione('SA2',1,xFilial('SA2')+_oModel:GetValue('ZLIDETAIL','ZLI_RETIRO')+_oModel:GetValue('ZLIDETAIL','ZLI_RETILJ'),'A2_NOME') )
			EndIf
		Else
			_cRet := AllTrim( Posicione('SA2',1,xFilial('SA2')+ZLI->(ZLI_RETIRO+ZLI_RETILJ),'A2_NOME') )
		EndIf
	Else
		_cRet := AllTrim( Posicione('SA2',1,xFilial('SA2')+ZLI->(ZLI_RETIRO+ZLI_RETILJ),'A2_NOME') )
	EndIf
EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa----------: AGLT011CPA
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Monta a tela para digita��o das datas de parcelas adicionais para o conv�nio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT011CPA( _dVencto )

Local _lOk			:= .F.
Local _aRet			:= {}
Local _nI			:= 0
Local aButtons		:= {}
Local cLinOk		:= "AllwaysTrue"
Local cTudoOk		:= "AllwaysTrue"
Local cIniCpos		:= "ZLI_VENCTO"
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
AADD( aAlterGDa  , 'ZLI_VENCTO' )

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
Programa----------: AGLT011VLD
Autor-------------: Lucas Borges
Data da Criacao---: 21/03/2019
===============================================================================================================================
Descri��o---------: Valida��o inicial da DataBase do Sistema para n�o permitir manuten��o de dados em per�odos bloqueados pelo
------------------: par�metro Fiscal ou Financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT011VLD( _oModel )

Local _lRet		:= .T.

If _oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. _oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. _oModel:GetOperation() == MODEL_OPERATION_DELETE

	If dDataBase < GetMV('MV_DATAFIN')
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_DATA' , 'ZLIMASTER' , 'ZLI_DATA' , "AGLT01119", "A DataBase do Sistema n�o � v�lida de acordo com o par�metro Financeiro.", "Corrija a DataBase ou solicite libera��o para a Contabilidade.")
		_lRet := .F.
	EndIf
	
	If _lRet .And. dDataBase <> LastDay( dDataBase )
		_oModel:SetErrorMessage('ZLIMASTER', 'ZLI_DATA' , 'ZLIMASTER' , 'ZLI_DATA' , "AGLT01120", "A DataBase do Sistema n�o � v�lida pois n�o est� posicionada no �ltimo dia do m�s selecionado ("+DTOC(LastDay(dDataBase))+")", "Para realizar a manuten��o no conv�nio configure a DataBase no �ltimo dia do m�s que estiver sendo utilizado.")
		_lRet := .F.
	EndIf
	
EndIf

Return( _lRet )
