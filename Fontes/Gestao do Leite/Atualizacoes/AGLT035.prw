/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/04/2021 | Bloqueada a op��o Desvincular para plataformas. Chamado 36267
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 22/07/2022 | Tratamento para Extrato Seco Total (EST). Chamado 40778
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/04/2023 | Corrigida valida��o de exclus�o. Chamado 43593
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"

/*
===============================================================================================================================
Programa----------: AGLT035
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina para processamento da Recep��o do Leite de Terceiros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035()

Local _oBrowse		:= Nil
Private _aRecnosZLD := {}
Private _nTotVolume := 0
Private _cSalvaForn := ""

//====================================================================================================
// Configura e inicializa a Classe do Browse
//====================================================================================================
_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( "ZLX" )
_oBrowse:SetMenuDef( 'AGLT035' )
_oBrowse:SetDescription( "Recep��o de Leite de Terceiros" )
_oBrowse:DisableDetails()

_oBrowse:AddLegend( "ZLX_STATUS == '1' "	, "GREEN"	, "Pendente"		)
_oBrowse:AddLegend( "ZLX_STATUS == '2' "	, "YELLOW"	, "Classificada"	)
_oBrowse:AddLegend( "ZLX_STATUS == '3' "	, "RED"		, "Fechada"			)

_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina para configura��o do menu na tela inicial
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local _aRet	:= {}

ADD OPTION _aRet Title 'Visualizar'		Action 'VIEWDEF.AGLT035'	OPERATION 2 ACCESS 0
ADD OPTION _aRet Title 'Incluir'   		Action 'VIEWDEF.AGLT035'	OPERATION 3 ACCESS 0
ADD OPTION _aRet Title 'Alterar'   		Action 'VIEWDEF.AGLT035'	OPERATION 4 ACCESS 0
ADD OPTION _aRet Title 'Desvincular'	Action 'U_AGLT035D()'		OPERATION 4 ACCESS 0
ADD OPTION _aRet Title 'Classificar'	Action 'U_AGLT035X(1)'		OPERATION 4 ACCESS 0
ADD OPTION _aRet Title 'Estornar Clas.'	Action 'U_AGLT035X(2)'		OPERATION 4 ACCESS 0
ADD OPTION _aRet Title 'Excluir'   		Action 'VIEWDEF.AGLT035'	OPERATION 5 ACCESS 0

Return( _aRet )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina para constru��o do modelo de dados das telas de processamento
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oStruZLX	:= FWFormStruct( 1 , 'ZLX' )
Local _oModel	:= NIL
Local _aGatAux	:= {}

//====================================================================================================
// Monta a configura��o de Gatilhos // FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic )
//====================================================================================================
_aGatAux := FwStruTrigger( 'ZLX_PRODLT' , 'ZLX_DESCPR'	, 'SB1->B1_DESC'	, .T. , 'SB1' , 1 , 'xFilial("SB1")+M->ZLX_PRODLT'					  		)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_FORNEC' , 'ZLX_NOMFOR'	, 'SA2->A2_NREDUZ'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->(ZLX_FORNEC)'						)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_FORNEC' , 'ZLX_LJFORN'	, 'SA2->A2_LOJA'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->ZLX_FORNEC+AllTrim(M->ZLX_LJFORN)'	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_LJFORN' , 'ZLX_NOMFOR'	, 'SA2->A2_NREDUZ'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->(ZLX_FORNEC+ZLX_LJFORN)'				)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_LJTRAN' , 'ZLX_NOMTRA'	, 'SA2->A2_NREDUZ'	, .T. , 'SA2' , 1 , 'xFilial("SA2")+M->(ZLX_TRANSP+ZLX_LJTRAN)'				)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_TEORAN'	, 'U_AGLT035A(M->ZLX_CODANA,1)' , .F.		  														)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_TEOEST'	, 'U_AGLT035A(M->ZLX_CODANA,2)' , .F.		  														)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )
              											
_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_DATAEN'	, 'ZZX->ZZX_DATA'	, .T. , 'ZZX' , 1 , 'xFilial("ZZX")+M->ZLX_CODANA'							)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_HRENTR'	, 'ZZX->ZZX_HORA' , .F. )
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_PLACA'	, 'ZZX->ZZX_PLACA' , .F. )
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_TRANSP'	, 'ZZX->ZZX_TRANSP' , .F. )
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_LJTRAN'	, 'ZZX->ZZX_LJTRAN' , .F. )
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_VLRCOM'	, 'U_AGLT035C(2,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CODANA'	, 'ZLX_VLRKM'	, 'U_AGLT035C(3,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PLACA'	, 'ZLX_VLRFRT'	, 'U_AGLT035C(1,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F. )
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PLACA'	, 'ZLX_ICMSFR'	, 'U_AGLT035E(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT,M->ZLX_PEDAGI)' , .F. )
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

//// 'ZLX_PESOCA'
_aGatAux := FwStruTrigger( 'ZLX_PESOCA'	, 'ZLX_PESOLI'	, 'M->( ZLX_PESOCA - ZLX_PESOVA )' , .F.							 					)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PESOCA'	, 'ZLX_VOLREC'	, 'Round( M->ZLX_PESOLI / Posicione("ZZX",1,xFilial("ZZX")+M->ZLX_CODANA,"ZZX_DENSID") , 0 )' , .F.	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PESOCA'	, 'ZLX_DIFVOL'	, 'M->( ZLX_VOLREC - ZLX_VOLNF )' , .F.													)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PESOCA'	, 'ZLX_BALCAP'	, 'M->ZLX_VOLREC - VAL(Posicione("ZZV",2,xFilial("ZZV")+M->(ZLX_TRANSP+ZLX_LJTRAN+ZLX_PLACA),"ZZV_CAPACI"))' , .F.	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )
////'ZLX_PESOCA'

////'ZLX_MEDVAZ'
_aGatAux := FwStruTrigger( 'ZLX_PESOLI'	, 'ZLX_MEDVAZ'	, 'IF(M->ZLX_PESOLI=0,M->ZLX_MEDVAZ,0)' , .F.	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_MEDVAZ'	, 'ZLX_VOLREC'	, 'M->ZLX_MEDVAZ' , .F.	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_MEDVAZ'	, 'ZLX_DIFVOL'	, 'M->( ZLX_VOLREC - ZLX_VOLNF )' , .F.													)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_MEDVAZ'	, 'ZLX_BALCAP'	, 'M->ZLX_VOLREC - VAL(Posicione("ZZV",2,xFilial("ZZV")+M->(ZLX_TRANSP+ZLX_LJTRAN+ZLX_PLACA),"ZZV_CAPACI"))' , .F.	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

////'ZLX_MEDVAZ'
_aGatAux := FwStruTrigger( 'ZLX_PESOVA'	, 'ZLX_PESOLI'	, 'M->( ZLX_PESOCA - ZLX_PESOVA )' , .F.							 					)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PESOVA'	, 'ZLX_VOLREC'	, 'Round( M->ZLX_PESOLI / Posicione("ZZX",1,xFilial("ZZX")+M->ZLX_CODANA,"ZZX_DENSID") , 0 )' , .F.	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PESOVA'	, 'ZLX_DIFVOL'	, 'M->( ZLX_VOLREC - ZLX_VOLNF )' , .F.													)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PESOVA'	, 'ZLX_BALCAP'	, 'M->ZLX_VOLREC - VAL(Posicione("ZZV",2,xFilial("ZZV")+M->(ZLX_TRANSP+ZLX_LJTRAN+ZLX_PLACA),"ZZV_CAPACI"))' , .F.	)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PGFRT'	, 'ZLX_PEDAGI'	, '0' , .F.																				)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PGFRT'	, 'ZLX_ADCFRT'	, '0' , .F.																				)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PGFRT'	, 'ZLX_VLRFRT'	, 'U_AGLT035C(1,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PGFRT'	, 'ZLX_VLRCOM'	, 'U_AGLT035C(2,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PGFRT'	, 'ZLX_VLRKM'	, 'U_AGLT035C(3,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PGFRT'	, 'ZLX_ICMSFR'	, 'U_AGLT035E(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,0,0)' , .F.						)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PGFRT'	, 'ZLX_TVLFRT'	, 'U_AGLT035T(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT,M->ZLX_PEDAGI)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_ADCFRT'	, 'ZLX_VLRFRT'	, 'U_AGLT035C(1,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_ADCFRT'	, 'ZLX_ICMSFR'	, 'U_AGLT035E(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT,M->ZLX_PEDAGI)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_ADCFRT'	, 'ZLX_TVLFRT'	, 'U_AGLT035T(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT,M->ZLX_PEDAGI)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PEDAGI'	, 'ZLX_ICMSFR'	, 'U_AGLT035E(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT,M->ZLX_PEDAGI)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PEDAGI'	, 'ZLX_TVLFRT'	, 'U_AGLT035T(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT,M->ZLX_PEDAGI)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_VLRFRT'	, 'ZLX_TVLFRT'	, 'U_AGLT035T(M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT,M->ZLX_PEDAGI)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_VLRFRT'	, 'ZLX_VLRCOM'	, 'U_AGLT035C(2,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_VLRFRT'	, 'ZLX_VLRKM'	, 'U_AGLT035C(3,M->ZLX_PLACA,M->ZLX_FORNEC,M->ZLX_LJFORN,M->ZLX_TRANSP,M->ZLX_LJTRAN,M->ZLX_ADCFRT)' , .F.			)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_PRODLT'	, 'ZLX_DESCPR'	, 'Posicione("SB1",1,xFilial("SB1")+M->ZLX_PRODLT,"B1_DESC")' , .F.						)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_VOLNF'	, 'ZLX_DIFVOL'	, 'M->( ZLX_VOLREC - ZLX_VOLNF )' , .F.													)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZLX_CTE'	, 'ZLX_CTE'		, 'U_ITZERESQ( M->ZLX_CTE , "ZLX_CTE" , "ZLXMASTER" )' , .F.							)
_oStruZLX:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oStruZLX:SetProperty( 'ZLX_VOLNF'   , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "Empty(M->ZLX_NRONF) .AND. Empty(FwFldGet('ZLX_LISTA'))" ) )
_oStruZLX:SetProperty( 'ZLX_FORNEC'  , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "Empty(M->ZLX_NRONF) .AND. Empty(FwFldGet('ZLX_LISTA'))" ) )
_oStruZLX:SetProperty( 'ZLX_LJFORN'  , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "Empty(M->ZLX_NRONF) .AND. Empty(FwFldGet('ZLX_LISTA'))" ) )

_oStruZLX:SetProperty( 'ZLX_VOLNF'   , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'U_AGLT035V(4)' ) )

//====================================================================================================
// Inicializa o Modelo de Dados
//====================================================================================================
_oModel := MpFormModel():New( 'AGLT035Z' ,/*bPre*/, {|_oModel| VALIDCOMIT(_oModel)} /*bPost*/, Nil /*bCommit*/, /*bCancel*/  )

_oModel:AddFields( 'ZLXMASTER' ,, _oStruZLX )
_oModel:SetPrimaryKey( { 'ZLX_FILIAL' , 'ZLX_CODIGO' } )
_oModel:SetDescription( 'Recep��o Leite de Terceiros' )

_oModel:SetVldActivate( { |oModel| AGLT035VLD( _oModel ) } )

Return( _oModel )

/*
===============================================================================================================================
Programa----------: AGLT035
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina para constru��o da View para exibi��o dos componentes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()

Local _oStruZLX	:= FWFormStruct( 2 , 'ZLX' )
Local _oModel	:= FwLoadModel( 'AGLT035' )
Local _oView	:= FwFormView():New()

//-- Agrupamento dos Campos --//
_oStruZLX:AddGroup( 'GRUPO01' , 'Dados da Recep��o'				, '' , 2 )
_oStruZLX:AddGroup( 'GRUPO02' , 'Dados da An�lise'				, '' , 2 )
_oStruZLX:AddGroup( 'GRUPO03' , 'Dados do Recebimento/Frete'	, '' , 2 )
_oStruZLX:AddGroup( 'GRUPO04' , 'Dados do Estoque'          	, '' , 2 )

//-- Definicao dos Campos para o Grupo 01 --//
_oStruZLX:SetProperty( 'ZLX_CODIGO'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_TIPOLT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_PRODLT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_DESCPR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_FORNEC'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_LJFORN'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_NOMFOR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_DTENTR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )
_oStruZLX:SetProperty( 'ZLX_STATUS'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )

//-- Definicao dos Campos para o Grupo 02 --//
_oStruZLX:SetProperty( 'ZLX_CODANA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_TEORAN'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_TEOEST'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_DATAEN'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_HRENTR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_PLACA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_TRANSP'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_LJTRAN'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_NOMTRA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_DTSAID'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_HRSAID'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_NRONF'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_SERINF'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_ESPECI'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_VLRNF'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
_oStruZLX:SetProperty( 'ZLX_ICMSNF'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )

//-- Definicao dos Campos para o Grupo 03 --//
_oStruZLX:SetProperty( 'ZLX_PGFRT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_PRCPRE'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_DIFPRC'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_PRCNF'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_VOLNF'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_PESOCA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_PESOVA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_PESOLI'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_VOLREC'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_DIFVOL'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_BALCAP'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_CTE'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_CTESER'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_PEDAGI'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_ADCFRT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_VLRFRT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_ICMSFR'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_TVLFRT'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_OBS'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
_oStruZLX:SetProperty( 'ZLX_MEDVAZ'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )

//-- Definicao dos Campos para o Grupo 04 --//
_oStruZLX:SetProperty( "ZLX_TICKET"	, MVC_VIEW_GROUP_NUMBER , 'GRUPO04' )//Ticket/Viagem
_oStruZLX:SetProperty( "ZLX_SETOR"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO04' )//Setor        
_oStruZLX:SetProperty( "ZLX_DTESTO"	, MVC_VIEW_GROUP_NUMBER , 'GRUPO04' )//Dt Entr Estoq
_oStruZLX:SetProperty( "ZLX_ORIGEM"	, MVC_VIEW_GROUP_NUMBER , 'GRUPO04' )//Origem Gerada
_oStruZLX:SetProperty( 'ZLX_LISTA'	, MVC_VIEW_GROUP_NUMBER , 'GRUPO04' )

_oView:SetModel( _oModel )
_oView:AddField( 'ZLXVIEW' , _oStruZLX , 'ZLXMASTER')

_oView:CreateHorizontalBox( 'BOX001' , 100 )
_oView:SetOwnerView( 'ZLXVIEW' , 'BOX001' )
_oView:EnableTitleView('ZLXVIEW' , 'Recep��o de Leite de Terceiros' )

_oView:AddUserButton( 'Vincular Tickets' , 'Tickets' , {|oView| AGLT35Tickets(oView) } )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT035A
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para retornar a m�dia de Gordura/Extrato Seco Total das an�lises do Leite de Terceiros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035A( _cAnalise, _nTipo)

Local _nRet		:= 0
Local _nQuant	:= 0
Local _nValor	:= 0

DBSelectArea("ZAP")
ZAP->( DBSetOrder(1) )
If ZAP->( DBSeek( xFilial("ZAP") + _cAnalise ) )

    While !ZAP->( EOF() ) .AND. ZAP->ZAP_CODIGO == _cAnalise
    
       _nQuant++
       _nValor += IIf(_nTipo == 1, ZAP->ZAP_GORD, ZAP->ZAP_EST)
       
    ZAP->( DBSkip() )
    EndDo
    
    _nRet := Round( _nValor/_nQuant , 2 )
    
EndIF

Return( _nRet )

/*
===============================================================================================================================
Programa----------: AGLT035C
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para retornar o valor do frete pela configura��o na tabela de frete
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035C( _nOpc , _cVeic , _cFornec , _cLojaF , _cTransp , _cLojaT , _nValAdc )

Local _oModel 		:= FWModelActive()
Local _lCobFrt		:= ( _oModel:GetValue( 'ZLXMASTER' , 'ZLX_PGFRT' ) == "S" )
Local _cCapc 		:= "" 
Local _nFrete		:= 0

Default _nValAdc	:= 0

If _lCobFrt

	DBSelectArea("ZZV")
	ZZV->( DBSetOrder(1) )
	If ZZV->( DBSeek( xFilial("ZZV") + _cVeic + _cTransp + _cLojaT ) )
		_cCapc := ZZV->ZZV_FXCAPA
		DBSelectArea("ZZT")     
		ZZT->( DBSetOrder(1) )
		If ZZT->( DBSeek( xFilial("ZZT") + _cTransp + _cLojaT + _cCapc ) )
			DBSelectArea("ZZU")
			ZZU->( DBSetOrder(1) )
			If ZZU->( DBSeek( xFilial("ZZU") + _cTransp + _cLojaT + PadR( _cCapc , TamSX3('ZZU_CAPACI')[01] ) + _cFornec + _cLojaF ) )
				If _nOpc == 1
					If ZZU->ZZU_VLRKM <> 0
						_nFrete := Round( ( ZZU->ZZU_VLRKM * ZZU->ZZU_KMFORN ) , 2 )
					ElseIf ZZU->ZZU_VLRCOM <> 0
						_nFrete := ZZU->ZZU_VLRCOM
					EndIf
				ElseIf _nOpc == 2
					_nFrete := ZZU->ZZU_VLRCOM
                    _oModel:LoadValue( 'ZLXMASTER' , 'ZLX_VLRCOM' , _nFrete)
				ElseIf _nOpc == 3
					_nFrete := ZZU->ZZU_VLRKM
                    _oModel:LoadValue( 'ZLXMASTER' , 'ZLX_VLRKM' , _nFrete)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If _nOpc == 1
	_nFrete += _nValAdc
    _oModel:LoadValue( 'ZLXMASTER' , 'ZLX_VLRFRT' , _nFrete )
EndIf

Return( _nFrete )
              
/*
===============================================================================================================================
Programa----------: AGLT035E
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para retornar o valor de ICMS referente ao Frete
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035E( _cVeic , _cFornec , _cLojaF , _cTransp , _cLojaT , _nValAdc , _nValPed )

Local _oModel 		:= FWModelActive()
Local _lCobFrt		:= ( _oModel:GetValue( 'ZLXMASTER' , 'ZLX_PGFRT' ) == "S" )
Local _lIcmPed		:= .F.
Local _cCapc		:= ""
Local _nFrete		:= 0
Local _nAlqICM		:= 0
Local _nAux			:= 0
Local _nTtFrt		:= 0

If _lCobFrt
	DBSelectArea("ZZV")
	ZZV->( DBSetOrder(1) )
	If ZZV->( DBSeek( xFilial("ZZV") + _cVeic + _cTransp + _cLojaT ) )
		_cCapc := ZZV->ZZV_FXCAPA
		DBSelectArea("ZZT")
		ZZT->( DBSetOrder(1) )
		If ZZT->( DBSeek( xFilial("ZZT") + _cTransp + _cLojaT + _cCapc ) )
			DBSelectArea("ZZU")
			ZZU->( DBSetOrder(1) )
			IF ZZU->( DBSeek( xFilial("ZZU") + _cTransp + _cLojaT + PadR( _cCapc , TamSX3('ZZU_CAPACI')[01] ) + _cFornec + _cLojaF ) )
				If ZZU->ZZU_VLRKM <> 0
					_nFrete := Round( ( ZZU->ZZU_VLRKM * ZZU->ZZU_KMFORN ) , 2 )
				ElseIf ZZU->ZZU_VLRCOM <> 0
					_nFrete := ZZU->ZZU_VLRCOM
				EndIf
				_nAlqICM	:= ZZU->ZZU_VLICMS
				_lIcmPed	:= ZZU->ZZU_ICMPED == 'S'
			EndIf
		EndIf
	EndIf
EndIf

_nFrete += _nValAdc + IIF( _lIcmPed , _nValPed , 0 )

If _nFrete > 0 

	_nAux			:= ( 100 - _nAlqICM ) / 100
	_nTtFrt			:= _nFrete / _nAux
	_nAlqICM		:= _nTtFrt - _nFrete
	
	M->ZLX_TVLFRT	:= _nTtFrt

EndIf

Return( _nAlqICM )

/*
===============================================================================================================================
Programa----------: AGLT035T
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para retornar o valor total do Frete
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035T( _cVeic , _cFornec , _cLojaF , _cTransp , _cLojaT , _nValAdc , _nValPed )

Local _oModel 		:= FWModelActive()
Local _lCobFrt		:= ( _oModel:GetValue( 'ZLXMASTER' , 'ZLX_PGFRT' ) == "S" )
Local _cCapc		:= ""
Local _nFrete		:= 0
Local _nAlqICM		:= 0
Local _nAux			:= 0
Local _nTtFrt		:= 0
Local _lIcmPed		:= .F.

Default _nValAdc	:= 0

If _lCobFrt
	DBSelectArea("ZZV")
	ZZV->( DBSetOrder(1) )
	If ZZV->( DBSeek( xFilial("ZZV") + _cVeic + _cTransp + _cLojaT ) )
		_cCapc := ZZV->ZZV_FXCAPA
		DBSelectArea("ZZT")
		ZZT->( DBSetOrder(1) )
		If ZZT->( DBSeek( xFilial("ZZT") + _cTransp + _cLojaT + _cCapc ) )
			DBSelectArea("ZZU")
			ZZU->( DBSetOrder(1) )
			IF ZZU->( DBSeek( xFilial("ZZU") + _cTransp + _cLojaT + PadR( _cCapc , TamSX3('ZZU_CAPACI')[01] ) + _cFornec + _cLojaF ) )
				If ZZU->ZZU_VLRKM <> 0
					_nFrete := Round( ( ZZU->ZZU_VLRKM * ZZU->ZZU_KMFORN ) , 2 )
				ElseIf ZZU->ZZU_VLRCOM <> 0
					_nFrete := ZZU->ZZU_VLRCOM
				EndIf
				_nAlqICM := ZZU->ZZU_VLICMS
				_lIcmPed := ( ZZU->ZZU_ICMPED == 'S' )
			EndIf
		EndIf
	EndIf
EndIf

_nFrete += _nValAdc + IIF( _lIcmPed , _nValPed , 0 )

If _nFrete > 0

	_nAux	:= ( 100 - _nAlqICM ) / 100
	_nTtFrt	:= ( _nFrete / _nAux ) + IIF( _lIcmPed , 0 , _nValPed )

EndIf

Return( _nTtFrt )

/*
===============================================================================================================================
Programa----------: AGLT035G
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para retornar o c�digo do CTE com Zeros � Esquerda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035G()

Local _aArea	:= GetArea()
LOCAL _cCte		:= ''

_cCte := STRZERO( Val( M->ZLX_CTE ) , 9 )

RestArea( _aArea )

Return( _cCte )

/*
===============================================================================================================================
Programa----------: AGLT035H
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para validar o cadastro da An�lise do Leite de Terceiros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035H()

Local _aArea	:= GetArea()
Local _lRet		:= .F.
Local _cAlias	:= GetNextAlias()

BeginSql alias _cAlias
SELECT ZZX_CODIGO
  FROM %table:ZZX%
 WHERE D_E_L_E_T_ = ' '
   AND ZZX_FILIAL = %xFilial:ZZX%
   AND ZZX_FORNEC = %exp:M->ZLX_FORNEC%
   AND ZZX_LJFORN = %exp:M->ZLX_LJFORN%
   AND ZZX_CODIGO = %exp:M->ZLX_CODANA%
   AND NOT EXISTS (SELECT ZLX.ZLX_CODIGO
          FROM %table:ZLX% ZLX
         WHERE ZLX.D_E_L_E_T_ = ' '
                 AND ZLX_FILIAL = ZZX_FILIAL
                 AND ZLX.ZLX_CODANA = ZZX_CODIGO)
 ORDER BY ZZX_CODIGO
EndSql

If (_cAlias)->( !Eof() ) .And. (_cAlias)->ZZX_CODIGO == M->ZLX_CODANA
   	_lRet := .T.
EndIf

(_cAlias)->( DBCloseArea() )

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT035F
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para validar os dados de Datas e Horas de Entrada x Sa�da
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035F()

Local _lRet		:= .T.
Local _nHorEnt	:= 0
Local _nHorSai	:= 0

If !Empty(M->ZLX_DTSAID) .and. !Empty(M->ZLX_DATAEN)
	If M->ZLX_DTSAID == M->ZLX_DATAEN
		_nHorEnt := ( Val( SubStr( M->ZLX_HRENTR , 1 , 2 ) ) * 60 ) + Val( SubStr( M->ZLX_HRENTR , 4 , 2 ) )
		_nHorSai := ( Val( SubStr( M->ZLX_HRSAID , 1 , 2 ) ) * 60 ) + Val( SubStr( M->ZLX_HRSAID , 4 , 2 ) )
		If _nHorEnt > _nHorSai
			Help(NIL, NIL, "AGLT03503", NIL, "Hora de sa�da � inv�lida com rela��o � entrada!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para entrada e sa�da na mesma data o hor�rio de sa�da deve ser maior que o de entrada."})
			_lRet := .F.
		EndIf
	EndIf
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: VALIDCOMIT
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para validar os dados na confirma��o da tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VALIDCOMIT(oModel)

Local _nOper		:= oModel:GetOperation() //O valor 3 quando e uma inclusao
                                             //O valor 4 quando e uma alteracao
                                             //O valor 5 quando e uma exclusao.
Local _oModel		:= oModel:GetModel()
Local _lRet			:= .T.
Local _lFecha		:= ( _oModel:GetValue( 'ZLXMASTER' , 'ZLX_STATUS' ) == '3' )
Local _cCodFor		:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_FORNEC'	)
Local _cLojFor		:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_LJFORN'	)
Local _cCodAna		:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_CODANA'	)
Local _aArea		:= GetArea()
Private _cCodigo	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_CODIGO'	)

DBSelectArea('SA2')
SA2->( DBSetOrder(1) )
If SA2->( DBSeek( xFilial('SA2') + _cCodFor + _cLojFor ) )
	If SA2->A2_MSBLQL == '1'
		Help(NIL, NIL, "AGLT03504", NIL, "O Fornecedor informado encontra-se Bloqueado ou Inativo no cadastro do Sistema!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do Fornecedor no Sistema ou os dados informados."})
		_lRet := .F.
	Else
		_lRet := .T.
	EndIf
EndIf

If _lRet
	If _lFecha
		Help(NIL, NIL, "AGLT03505", NIL, "N�o ser� poss�vel confirmar a opera��o atual!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Essa Recep��o de Leite encontra-se com status de Fechamento Realizado."})
		Return( .F. )
	EndIf

	If _nOper == 3 .or. _nOper == 4
		If !Empty(_oModel:GetValue('ZLXMASTER','ZLX_LISTA')) .AND. _nTotVolume # 0 .AND. (_oModel:GetValue('ZLXMASTER','ZLX_VOLNF') # _nTotVolume .OR. (_cCodFor+_cLojFor) # _cSalvaForn)
			Help(NIL, NIL, "AGLT03506", NIL, "O Campo Volume NF n�o pode ser modifiado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Retire os vinculos com os Tickets para modifica-lo."})
       EndIf

	   	ZZX->( DBSetOrder(1) )
		If ZZX->( DBSeek( xFilial("ZZX") + _cCodAna ) )

			If ZZX->ZZX_FORNEC == _cCodFor .And. ZZX->ZZX_LJFORN == _cLojFor
				RecLock("ZZX",.F.)
		       	ZZX->ZZX_ANAUSE := .T.
		 	    ZZX->(MsUnLock())
				ZZX->(DBCommit())
			Else
				Help(NIL, NIL, "AGLT03507", NIL, "N�o ser� poss�vel confirmar a opera��o atual!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"A an�lise de qualidade informada est� registrada para outro Fornecedor."})
				Return( .F. )
			EndIf
	    EndIf
	    
	    If _nOper == 4
			DBSelectArea("ZLX")
	   		ZLX->( DBSetOrder(1) )
			If ZLX->( DBSeek( xFilial("ZLX") + _cCodigo ) )
				If ZZX->( DBSeek( xFilial("ZZX") + ZLX->ZLX_CODANA ) ) .And. ZLX->ZLX_CODANA <> _cCodAna
					RecLock("ZZX",.F.)
					ZZX->ZZX_ANAUSE := .F.
			 	    ZZX->( MsUnLock() )
					ZZX->( DBCommit() )
			    EndIf
			EndIf
	    EndIf
	
	ElseIf _nOper == 5
	    DBSelectArea("ZLX")
	   	ZLX->( DBSetOrder(1))
		If ZLX->( DBSeek( xFilial("ZLX") + _cCodigo ) )
			DBSelectArea("ZZX")
	   		ZZX->( DBSetOrder(1) )
			If ZZX->( DBSeek( xFilial("ZZX") + ZLX->ZLX_CODANA ) )
				RecLock("ZZX",.F.)
			    ZZX->ZZX_ANAUSE := .F.
			    ZZX->( MsUnLock() )
				ZZX->( DBCommit() )
		    EndIf
		EndIf
	EndIf
EndIf

RestArea(_aArea)

Return( _lRet )

/*
===============================================================================================================================
Programa----------: F3ZZXLT
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar que monta a tela de consulta dos resultados de An�lises de Leite de terceiros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function F3ZZXLT()

Local _oModel	:= FWModelActive()
Local _oBrwAux	:= Nil
Local _lRet		:= .F.

Local _cTitulo  := 'Consulta - An�lises de Leite de Terceiros'
Local _cFornec	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_FORNEC' )
Local _cLjForn	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_LJFORN' )
Local _cCodPrd	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_PRODLT' )
Local _cTipo	:= ''
Local _bView	:= {|| FWExecView( "An�lise - ["+ ZZX->ZZX_CODIGO +"]" , "AGLT029" , MODEL_OPERATION_VIEW ,, {||.T.} , {||.T.} ) }

Local _bInc 	:= {|| FWExecView( "Inclus�o"                            , "AGLT029" , 3 ,, {||.T.} , {||.T.} ),U_F3QRYZZX(_cFornec, _cLjForn, _cTipo, _cCodPrd),U_AGLT035N() } // 3 - Inser��o
Local _bAlt	    := {|| FWExecView( "Altera��o - ["+ ZZX->ZZX_CODIGO +"]" , "AGLT029" , 4 ,, {||.T.} , {||.T.} ),U_F3QRYZZX(_cFornec, _cLjForn, _cTipo, _cCodPrd),U_AGLT035N() } // 4 - Atualiza��o
Local _bExc     := {|| FWExecView( "Exclus�o  - ["+ ZZX->ZZX_CODIGO +"]" , "AGLT029" , 5 ,, {||.T.} , {||.T.} ),U_F3QRYZZX(_cFornec, _cLjForn, _cTipo, _cCodPrd),U_AGLT035N() } // 5 - Exclus�o

Private _aDados   := {{"","","","","","","","","","","",""}}, _oLbx := Nil

U_F3QRYZZX(_cFornec, _cLjForn, _cTipo, _cCodPrd)

DBSelectArea('ZZX')
ZZX->( DBSetOrder(1) )

//====================================================================================================
// Monta a tela para usuario visualizar consulta
//====================================================================================================
DEFINE MSDIALOG _oBrwAux TITLE _cTitulo FROM 000,000 TO 340,600 PIXEL
	
@ 002,002	LISTBOX		_oLbx		;
			FIELDS		HEADER 'C�digo','Data','Hora','Fornecedor','Loja','Nome Fantasia','Placa','Transportadora','Loja','Nome Fantasia','Densidade' ;
			SIZE		300,155		;
			OF 			_oBrwAux	;
			PIXEL ON 	DBLCLICK( ZZX->( DBGoTo( _aDados[_oLbx:nAt,12] ) ) , _lRet := .T. , _oBrwAux:End() )

_oLbx:SetArray( _aDados )
_oLbx:bLine := {|| {	_aDados[_oLbx:nAt][01] ,;
						_aDados[_oLbx:nAt][02] ,;
						_aDados[_oLbx:nAt][03] ,;
						_aDados[_oLbx:nAt][04] ,;
						_aDados[_oLbx:nAt][05] ,;
						_aDados[_oLbx:nAt][06] ,;
						_aDados[_oLbx:nAt][07] ,;
						_aDados[_oLbx:nAt][08] ,;
						_aDados[_oLbx:nAt][09] ,;
						_aDados[_oLbx:nAt][10] ,;
						_aDados[_oLbx:nAt][11] ,;
						_aDados[_oLbx:nAt][12] }}

@158,110 BUTTON _oButton PROMPT "Visualizar"	SIZE 029,010 PIXEL OF _oBrwAux ACTION ( ZZX->( DBGoTo( _aDados[_oLbx:nAt,12] ) ) , EVal( _bView )					)
@158,140 BUTTON _oButton PROMPT "Incluir"	    SIZE 029,010 PIXEL OF _oBrwAux ACTION ( ZZX->( DBGoTo( _aDados[_oLbx:nAt,12] ) ) , EVal( _bInc )					)
@158,170 BUTTON _oButton PROMPT "Alterar"	    SIZE 029,010 PIXEL OF _oBrwAux ACTION ( ZZX->( DBGoTo( _aDados[_oLbx:nAt,12] ) ) , EVal( _bAlt )					)
@158,200 BUTTON _oButton PROMPT "Excluir"	    SIZE 029,010 PIXEL OF _oBrwAux ACTION ( ZZX->( DBGoTo( _aDados[_oLbx:nAt,12] ) ) , EVal( _bExc )					)  
@158,230 BUTTON _oButton PROMPT "Confirmar"		SIZE 029,010 PIXEL OF _oBrwAux ACTION ( ZZX->( DBGoTo( _aDados[_oLbx:nAt,12] ) ) , _lRet := .T. , _oBrwAux:End()	)  // @158,240
@158,260 BUTTON _oButton PROMPT "Cancelar"		SIZE 029,010 PIXEL OF _oBrwAux ACTION ( _lRet := .F. , _oBrwAux:End()												)  // @158,270
	
ACTIVATE MSDIALOG _oBrwAux CENTER

Return(_lRet)

/*
===============================================================================================================================
Programa----------: AGLT035P
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para retornar o c�digo do CTE com Zeros � Esquerda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035P( _cCodPrd , _nVlMin )

Local _lRet		:= .T.
Local _cValMin	:= ''
Local _cValMax	:= ''

DBSelectArea('ZA7')
ZA7->( DBSetOrder(1) )
If ZA7->( DBSeek( xFilial('ZA7') + AllTrim(_cCodPrd) ) )
	If ZA7->ZA7_GORMIN > _nVlMin .Or. _nVlMin > ZA7->ZA7_GORMAX
		_cValMin := AllTrim( Transform( ZA7->ZA7_GORMIN , PesqPict( 'ZA7' , 'ZA7_GORMIN' ) ) )
		_cValMax := AllTrim( Transform( ZA7->ZA7_GORMAX , PesqPict( 'ZA7' , 'ZA7_GORMAX' ) ) )
		Help(NIL, NIL, "AGLT03508", NIL, "O valor cadastrado para o Campo Gordura Mini est� fora do range permitido pelo  cadastro do produto na Gest�o do Leite!",;
			 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os dados informados ou o cadastro de regras. Val.M�nimo("+ _cValMin +") Val.M�ximo("+ _cValMax +") "})
		_lRet := .F.
	EndIf
Else
	If _nVlMin > 0
		Help(NIL, NIL, "AGLT03509", NIL, "N�o foi encontrado o cadastro do Produto na configura��o de Produtos da Recep��o de Leite de Terceiros!",;
			 1, 0, NIL, NIL, NIL, NIL, NIL, {"Caso o produto n�o seja relacionado � Recep��o de Leite o Campo Gordura Mini n�o deve ser preenchido."})
		_lRet := .F.
	EndIf
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT035D
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para desvincular uma recep��o da An�lise de Qualidade
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035D()

Local _aArea	:= GetArea()

If ZLX->ZLX_STATUS == '3'
	MsgStop('N�o � permitido desvincular uma An�lise de uma Recep��o que esteja com o Status de "Fechamento Conclu�do"!',"AGLT03510")
ElseIf ZLX->ZLX_TIPOLT == 'P'
	MsgStop('N�o � permitido desvincular uma An�lise de uma Recep��o do tipo Plataforma',"AGLT03539")	
Else
	If Aviso("AGLT03511","Essa op��o ir� desvincular a An�lise de Qualidade da recep��o de Leite de Terceiros. Deseja confirmar o processamento?" , {"Sim","N�o"} , 2 ) == 1
		
		Begin Transaction
		
		DBSelectArea('ZZX')
		ZZX->( DBSetOrder(1) )
		If ZZX->( DBSeek( xFilial('ZZX') + ZLX->ZLX_CODANA ) )
			RecLock( 'ZZX' , .F. )
			ZZX->ZZX_ANAUSE := .F.
			ZZX->( MsUnLock() )
			
			RecLock( 'ZLX' , .F. )
			ZLX->ZLX_CODANA := ''
			ZLX->ZLX_STATUS	:= '1'
			ZLX->ZLX_TEORAN	:= 0
			ZLX->ZLX_TEOEST	:= 0
			ZLX->ZLX_DATAEN	:= STOD('')
			ZLX->ZLX_HRENTR	:= ''
			ZLX->ZLX_PLACA	:= ''
			ZLX->ZLX_VLRFRT	:= 0
			ZLX->ZLX_TVLFRT := 0
			ZLX->ZLX_TRANSP	:= ''
			ZLX->ZLX_LJTRAN	:= ''
			ZLX->ZLX_ICMSFR	:= 0
			ZLX->( MsUnLock() )
		Else
			MsgStop("N�o ser� poss�vel desvincular a An�lise pois a mesma n�o foi encontrada! Verifique os dados das An�lises para tentar novamente.","AGLT03512")
		EndIf
		
		End Transaction
		
	EndIf

EndIf

RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: AGLT035I
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina auxiliar para verificar o c�lculo e a aplica��o do ICMS ao valor do ped�gio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035I( _nOpcao , _nValOrg , _nValAdc , _nValPed , _cCodTra , _cLojTra , _cCodFor , _cLojFor , _cPlaca )

Local _nRet		:= 0
Local _cICMPED	:= Posicione('ZZU',2,xFilial('ZZU')+_cCodTra+_cLojTra+_cCodFor+_cLojFor,'ZZU_ICMPED') // Order 2 = ZZU_FILIAL+ZZU_TRANSP+ZZU_LJTRAN+ZZU_FORNEC+ZZU_LJFORN

If _nOpcao == 1 .And. (  Empty(_cICMPED) .Or.  _cICMPED <> "S" )
	_nRet += _nValPed
EndIf

_nRet += U_AGLT035C( _cPlaca , _cCodFor , _cLojFor , _cCodTra , _cLojTra , _nValAdc )

Return( _nRet )

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 08/12/2014
===============================================================================================================================
Descri��o---------: Rotina para montar o menu da tela principal com as funcionalidades da rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT035VLD( _oModel )

Local _lRet		:= .T.
Local _nX		:= 0
Local _nOper	:= _oModel:GetOperation()//O valor 3 quando e uma inclusao;O valor 4 quando e uma alteracao; O valor 5 quando e uma exclusao.
LOCAL _oAux     := _oModel:GetModel('ZLXMASTER')
LOCAL _oStruct  := _oAux:GetStruct()      
LOCAL _aFields  := {"ZLX_FORNEC","ZLX_LJFORN","ZLX_DTENTR","ZLX_CODANA","ZLX_DTSAID","ZLX_HRSAID","ZLX_VOLNF","ZLX_PESOCA","ZLX_PESOVA",;
                    "ZLX_CTE"   ,"ZLX_CTESER","ZLX_PEDAGI","ZLX_MEDVAZ"	}

If _nOper <> MODEL_OPERATION_INSERT .And. _nOper <> 1

	If !Empty(ZLX->ZLX_STATUS) .AND. ZLX->ZLX_STATUS <> '1'
		Help(NIL, NIL, "AGLT03513", NIL, "O registro atual encontra-se bloqueado!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para realizar essa opera��o � necess�rio estornar o Fechamento e/ou a Classifica��o."})
		_lRet := .F.
	ElseIf !Empty(ZLX->ZLX_ORIGEM) .AND. _nOper = 5 .AND. ZLX->ZLX_ORIGEM <> '1'//n�o pode exluir linhas com origem 2 3 
		Help(NIL, NIL, "AGLT03514", NIL, "A Recep��o n�o pode ser excluida.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"S� pode ser excluido pela origem que gerou 2 ou 3 : "+ZLX->ZLX_ORIGEM})
		_lRet := .F.
	ElseIf Empty(ZLX->ZLX_ORIGEM) .AND. _nOper = 5  .AND. !Empty(ZLX->ZLX_CODANA)//n�o pode exluir se tiver an�lise vinculada
		Help(NIL, NIL, "AGLT03540", NIL, "A Recep��o n�o pode ser excluida.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para excluir a recep��o, retire a an�lise vinculada."})
		_lRet := .F.
	ElseIf !Empty(ZLX->ZLX_ORIGEM) .AND. _nOper = 4 .AND. ZLX->ZLX_ORIGEM $ '2,3'//Pode alterar somente OBS , Paga Frete , Acr�scimos ou Desconto
       //Setores Prim�rios
	   For _nX := 1 To Len(_aFields)
           _oStruct:SetProperty( _aFields[_nX], MODEL_FIELD_WHEN, {||.F.} )
	   Next _nX
	ElseIf !Empty(ZLX->ZLX_LISTA) .AND. _nOper = 4 
       //Setores Secund�rios
       _nTotVolume:=ZLX->ZLX_VOLNF
       _cSalvaForn:=ZLX->ZLX_FORNEC+ZLX->ZLX_LJFORN
	EndIf
Else
	For _nX := 1 To Len(_aFields)
		If !Empty(GetSX3Cache(_aFields[_nX],"X3_WHEN"))
			_oStruct:SetProperty( _aFields[_nX], MODEL_FIELD_WHEN, &("{||"+AllTrim(GetSX3Cache(_aFields[_nX],"X3_WHEN"))+"}") )
		Else
			_oStruct:SetProperty( _aFields[_nX], MODEL_FIELD_WHEN, {|| .T. } )
		EndIf
	Next _nX
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT035X
Autor-------------: Alexandre Villar
Data da Criacao---: 08/12/2014
===============================================================================================================================
Descri��o---------: Rotina para classifica��o das recep��es
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035X( _nOpca )

Local _aCampos	:= {}
Local _aRecep	:= {}
Local _cPerg	:= 'AGLT035X'
Local _cAlias	:= ''
Local _nRegOk	:= 0
Local _nI		:= 0
Local _nSel		:= 0
Local _cCodUsr	:= RetCodUsr()

If _nOpca == 2

	If ZLX->ZLX_STATUS == '2'
	
		RecLock( 'ZLX' , .F. )
		
		ZLX->ZLX_STATUS := '1'
		ZLX->ZLX_USRCLS	:= _cCodUsr
		ZLX->ZLX_DTCLAS	:= DATE()
		ZLX->ZLX_HRCLAS	:= TIME()
		
		ZLX->( MsUnLock() )
		Help(NIL, NIL, "AGLT03515", NIL, "Estorno da classifica��o realizado com sucesso!", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	Else
		
	    If Pergunte( _cPerg )
	    
	    	_cAlias := GetNextAlias()
			BeginSql alias _cAlias
				SELECT ZLX_CODIGO, ZLX_TIPOLT, ZLX_PRODLT, ZLX_FORNEC, ZLX_LJFORN, R_E_C_N_O_ REGZLX
				FROM  %Table:ZLX% ZLX
				WHERE D_E_L_E_T_ =' '
				AND ZLX_FILIAL = %xFilial:ZLX%
				AND ZLX.ZLX_STATUS = '2'
				AND ZLX.ZLX_CODIGO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
				ORDER BY ZLX.ZLX_CODIGO
			EndSql			

			While (_cAlias)->( !Eof() )
			
				aAdd( _aRecep , {	.T.																								  		,;
								(_cAlias)->ZLX_CODIGO																				  		,;
								(_cAlias)->ZLX_TIPOLT																				  		,;
								(_cAlias)->ZLX_PRODLT																				  		,;
								AllTrim( Posicione( 'SB1' , 1 , xFilial('SB1') + (_cAlias)->ZLX_PRODLT					, 'B1_DESC' ) )		,;
								(_cAlias)->ZLX_FORNEC																						,;
								(_cAlias)->ZLX_LJFORN																						,;
								AllTrim( Posicione( 'SA2' , 1 , xFilial('SA2') + (_cAlias)->(ZLX_FORNECE + ZLX_LJFORN )	, 'A2_NREDUZ' ) )	,;
								(_cAlias)->REGZLX																							})
			
			(_cAlias)->( DBSkip() )
			EndDo
			
			(_cAlias)->( DBCloseArea() )
			
			If Empty( _aRecep )
				Help(NIL, NIL, "AGLT03516", NIL, "N�o foram encontradas recep��es classificadas com os par�metros informados!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os dados e tente novamente."})
			Else
				If U_ITLISTBOX( 'Recep��es para estornar:' , {'[  ]','C�digo','Tipo','Produto','Descri��o','C�d. Fornecedor','Loja Fornecedor','Nome'} , @_aRecep , .T. , 2 , 'Verifique e selecione as recep��es para estornar:' )
					
					_nSel := 0
					
					For _nI := 1 To Len( _aRecep )
						
						If _aRecep[_nI][01]
							_nSel++
							_lOk := .T.
							
							DBSelectArea('ZLX')
							ZLX->( DBGoTo( _aRecep[_nI][09] ) )
							RecLock( 'ZLX' , .F. )
								ZLX->ZLX_STATUS := '1'
								ZLX->ZLX_USRCLS	:= _cCodUsr
								ZLX->ZLX_DTCLAS	:= DATE()
								ZLX->ZLX_HRCLAS	:= TIME()
							ZLX->( MsUnLock() )
						
						EndIf
					
					Next _nI
					
					If _nSel > 0
						Help(NIL, NIL, "AGLT03517", NIL, cValToChar(_nSel) +" recep��es estornadas com sucesso!", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					Else
						Help(NIL, NIL, "AGLT03518", NIL, "As recep��es n�o foram estornadas pois n�o foi selecionado nenhum registro para processamento.", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
ElseIf _nOpca == 1
	
    Pergunte( _cPerg , .F. )
    MV_PAR01 := ZLX->ZLX_CODIGO
    MV_PAR02 := ZLX->ZLX_CODIGO
    
    If Pergunte( _cPerg )
    
    	_cAlias := GetNextAlias()
		BeginSql alias _cAlias		
			SELECT ZLX_CODIGO, ZLX_TIPOLT, ZLX_PRODLT, ZLX_FORNEC, ZLX_LJFORN, R_E_C_N_O_ REGZLX
			FROM  %Table:ZLX%
			WHERE D_E_L_E_T_ = ' '
			AND ZLX_FILIAL = %xFilial:ZLX%
			AND ZLX_STATUS = '1'
			AND ZLX_CODIGO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
			ORDER BY ZLX_CODIGO
		EndSql		

		While (_cAlias)->( !Eof() )
		
			aAdd( _aRecep , {	.T.																										,;
							(_cAlias)->ZLX_CODIGO																						,;
							(_cAlias)->ZLX_TIPOLT																						,;
							(_cAlias)->ZLX_PRODLT																						,;
							AllTrim( Posicione( 'SB1' , 1 , xFilial('SB1') + (_cAlias)->ZLX_PRODLT					, 'B1_DESC' ) )		,;
							(_cAlias)->ZLX_FORNEC																						,;
							(_cAlias)->ZLX_LJFORN																						,;
							AllTrim( Posicione( 'SA2' , 1 , xFilial('SA2') + (_cAlias)->(ZLX_FORNECE + ZLX_LJFORN )	, 'A2_NREDUZ' ) )	,;
							(_cAlias)->REGZLX																					  		})
		
		(_cAlias)->( DBSkip() )
		EndDo
		
		(_cAlias)->( DBCloseArea() )
		
		If Empty( _aRecep )
			Help(NIL, NIL, "AGLT03518", NIL, "N�o foram encontradas recep��es com os par�metros informados!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os dados e tente novamente."})
		Else
			
			If U_ITLISTBOX( 'Recep��es para classificar:' , {'[  ]','C�digo','Tipo','Produto','Descri��o','C�d. Fornecedor','Loja Fornecedor','Nome'} , @_aRecep , .T. , 2 , 'Verifique e selecione as recep��es para classificar:' )
				
				_nRegOk := 0
				
				For _nI := 1 To Len( _aRecep )
					
					If _aRecep[_nI][01]
						
						_nSel++
						_lOk := .T.
						
						DBSelectArea('ZLX')
						ZLX->( DBGoTo( _aRecep[_nI][09] ) )
						If Empty(ZLX->ZLX_CODANA)
							aAdd( _aCampos , { ZLX->ZLX_CODIGO , 'C�d. An�lise'		, 'N�o foi informado o c�digo da An�lise de Qualidade da Recep��o'	} )
							_lOk := .F.
						EndIf
						
						If Empty(ZLX->ZLX_DTSAID)
							aAdd( _aCampos , { ZLX->ZLX_CODIGO , 'Data Sa�da'		, 'N�o foi informada a data de sa�da do Transportador'				} )
							_lOk := .F.
						EndIf
						
						If Empty(ZLX->ZLX_HRSAID)
							aAdd( _aCampos , { ZLX->ZLX_CODIGO , 'Hora Sa�da'		, 'N�o foi informada a hora de sa�da do Transportador'				} )
							_lOk := .F.
						EndIf
						
						If Empty(ZLX->ZLX_VOLREC)
							aAdd( _aCampos , { ZLX->ZLX_CODIGO , 'Volume Recebido'	, 'N�o foi informado o Volume Recebido'	} )
							_lOk := .F.
						EndIf
						
						If Empty(ZLX->ZLX_VOLNF)
							aAdd( _aCampos , { ZLX->ZLX_CODIGO , 'Volume NF'		, 'N�o foi informado o Volume da NF'								} )
							_lOk := .F.
						EndIf
						
						If ZLX->ZLX_PGFRT == "S" .And. ZLX->ZLX_TIPOLT <> "P" .And. ( Empty(ZLX->ZLX_CTE) .Or. Empty(ZLX->ZLX_CTESER) )
							aAdd( _aCampos , { ZLX->ZLX_CODIGO , 'N�mero CTE'		, 'N�mero + S�rie do CTE'						} )
							_lOk := .F.
						EndIf
						
						If _lOk
							
							RecLock( 'ZLX' , .F. )
							
							ZLX->ZLX_STATUS := '2'
							ZLX->ZLX_USRCLS	:= _cCodUsr
							ZLX->ZLX_DTCLAS	:= DATE()
							ZLX->ZLX_HRCLAS	:= TIME()
							
							ZLX->( MsUnLock() )
							
							_nRegOk++
						
						EndIf
					
					EndIf
				
				Next _nI
				
				If _nRegOk > 0
					If Empty(_aCampos)
						Help(NIL, NIL, "AGLT03520", NIL, "Recep��es classificadas com sucesso!", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					Else
						Help(NIL, NIL, "AGLT03521", NIL, "Existem recep��es que n�o foram classificadas", 1, 0, NIL, NIL, NIL, NIL, NIL, {"� necess�rio que todos os campos obrigat�rios tenham sido informados!"})
						U_ITLISTBOX( 'Campos obrigat�rios n�o preenchidos:' , { ' Recep��o ' , ' Nome do Campo ' , ' Descri��o ' } , _aCampos,.F.,1,'Verifique o preenchimento dos campos abaixo:')
					EndIf
				Else
					
					If _nSel == 0
						Help(NIL, NIL, "AGLT03522", NIL, "As recep��es n�o foram classificadas! N�o foi selecionado nenhum registro para processamento.", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
					Else
						If Empty(_aCampos)
							Help(NIL, NIL, "AGLT03523", NIL, "As recep��es n�o foram classificadas!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os dados e tente novamente!"})
						Else
							Help(NIL, NIL, "AGLT03524", NIL, "As recep��es n�o foram classificadas!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"� necess�rio que todos os campos obrigat�rios tenham sido informados!"})
							U_ITLISTBOX( 'Campos obrigat�rios n�o preenchidos:' , { ' Recep��o ' , ' Nome do Campo ' , ' Descri��o ' } , _aCampos,.F.,1,'Verifique o preenchimento dos campos abaixo:')
						EndIf
					EndIf
					
				EndIf
			
			EndIf
			
		EndIf
	
	EndIf

Else
	Help(NIL, NIL, "AGLT03525", NIL, "N�o � poss�vel realizar essa opera��o no registro selecionado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o registro atual e tente novamente."})
EndIf

Return()

/*
===============================================================================================================================
Programa--------: AGLT035C
Autor-----------: Alexandre Villar
Data da Criacao-: 08/12/2014
===============================================================================================================================
Descri��o-------: Rotina para valida��o da amarra��o CTE/NF
===============================================================================================================================
Parametros------: _cCTE		- N�mero do CTE
----------------: _cCTESer	- S�rie do CTE
----------------: _cTransp	- C�digo do Transportador
----------------: _cLjTran	- Loja do Transportador
----------------: _cNF		- N�mero da NF
----------------: _cNFSer		- S�rie da NF
----------------: _cFornec	- Fornecedor da NF
----------------: _cLjForn	- Loja do Fornecedor da NF
===============================================================================================================================
Retorno---------: _lRet		- Valida se a amarra��o est� correta
===============================================================================================================================
*/
User Function ALGT035C( _cCodRec , _cCTE , _cCTESer )

Local _lRet			:= .T.
Local _cAlias		:= GetNextAlias()

Default _cCodRec	:= ''
Default _cCTE		:= ''
Default _cCTESer	:= ''

If !Empty(_cCodRec) .And. !Empty(_cCTE) .And. !Empty(_cCTESer)
	
	_cCTE := StrZero( Val(_cCTE) , TamSX3("ZLX_CTE")[01] )
	BeginSql alias _cAlias	
		SELECT ZLX_CODIGO
		FROM  %Table:ZLX%
		WHERE D_E_L_E_T_ = ' '
		AND ZLX_FILIAL = %xFilial:ZLX%
		AND ZLX_CODIGO <> %exp:_cCodRec%
		AND ZLX_CTE    =  %exp:_cCTE%
		AND ZLX_CTESER =  %exp:_cCTESer%
	EndSql
	//====================================================================================================
	// Valida apenas se o CTE j� foi utilizado em outra recep��o.
	//====================================================================================================
	If (_cAlias)->( !Eof() ) .And. !Empty( (_cAlias)->ZLX_CODIGO )
		Help(NIL, NIL, "AGLT03526", NIL, "O CTE + S�rie informado j� foi lan�ado em outra recep��o de leite de terceiros! Recep��o: ["+ (_cAlias)->ZLX_CODIGO +"]", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o CTE informado!"})		
		_lRet := .F.
	EndIf
	
	(_cAlias)->( DBCloseArea() )

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT035V
Autor-------------: Alexandre Villar
Data da Criacao---: 19/11/2014
===============================================================================================================================
Descri��o---------: Rotina para valida��o do c�digo de Fornecedor digitado na tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035V( _nCampo )

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _oModel	:= FWModelActive()
Local _cCodFor	:= ''
Local _cLojFor	:= ''

If _nCampo = 3
	_nZLX_MEDVAZ:=_oModel:GetValue( 'ZLXMASTER' , 'ZLX_MEDVAZ' )
	_nZLX_PESOLI:=_oModel:GetValue( 'ZLXMASTER' , 'ZLX_PESOLI' )
	If _nZLX_PESOLI # 0 .AND. _nZLX_MEDVAZ # 0 
		Help(NIL, NIL, "AGLT03527", NIL, "Medidor de Vaz�o n�o pode ser preenchido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Zere o campo de Peso Liquido para poder usa-lo."})
		Return .F.
	EndIf
	Return .T.
ElseIf _nCampo = 4
	M->ZLX_VOLNF:=_oModel:GetValue('ZLXMASTER','ZLX_VOLNF')
	If !Empty(_oModel:GetValue('ZLXMASTER','ZLX_LISTA')) .AND. _nTotVolume <> 0 .AND. (M->ZLX_VOLNF <> _nTotVolume)
		Help(NIL, NIL, "AGLT03528", NIL, "O Campo Volume NF n�o pode ser modifiado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Retire os vinculos com os Tickets para modifica-lo."})
		_oModel:LoadValue( 'ZLXMASTER' , 'ZLX_VOLNF' , _nTotVolume)
		M->ZLX_VOLNF:=_nTotVolume
		Return .F.
	EndIf
	Return .T.
ElseIf _nCampo = 1
	_cCodFor	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_FORNEC' )
	_cLojFor	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_LJFORN' )
	M->ZLX_LISTA:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_LISTA'  )
	If !Empty(M->ZLX_LISTA) .AND. !Empty(_cSalvaForn) .AND. _cCodFor+_cLojFor # _cSalvaForn
		Help(NIL, NIL, "AGLT03529", NIL, "O Fornecedor n�o pode ser modifiado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Retire os vinculos com os Tickets para modifica-lo."})
	    Return .F.
	EndIf
ElseIf _nCampo = 2
	_cCodFor	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_TRANSP' )
	_cLojFor	:= _oModel:GetValue( 'ZLXMASTER' , 'ZLX_LJTRAN' )
EndIf

DBSelectArea('SA2')
SA2->( DBSetOrder(1) )
If SA2->( DBSeek( xFilial('SA2') + _cCodFor + AllTrim( _cLojFor ) ) )
	_lRet := .T.
Else
	Help(NIL, NIL, "AGLT03530", NIL, "O Fornecedor digitado n�o foi encontrado no cadastro de Fornecedores do Sistema!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do Fornecedor no Sistema ou os dados informados."})
	_lRet := .F.
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: F3QRYZZX
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/02/2018
===============================================================================================================================
Descri��o---------: Roda a query de dados para a cosulta espec�fica F3ZZXLT.
===============================================================================================================================
Parametros--------: _cFornec = Codigo do fornecedor
                    _cLjForn = Loja do fornecedor
                    _cTipo   = Tipo de produto
                    _cCodPrd = C�digo do produto.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function F3QRYZZX(_cFornec, _cLjForn, _cTipo, _cCodPrd)
Local _cAlias	:= GetNextAlias()
Local _cFiltro	:=""
Begin Sequence
   _aDados := {}
   
	BeginSql alias _cAlias
		SELECT DISTINCT ZA7_TIPPRD
		FROM %table:ZA7%
		WHERE D_E_L_E_T_ =' '
		AND ZA7_FILIAL = %xFilial:ZA7%
		AND ZA7_CODPRD = %exp:_cCodPrd%
	EndSql

   While (_cAlias)->( !Eof() )
	  _cTipo += (_cAlias)->ZA7_TIPPRD +';'
      (_cAlias)->( DBSkip() )
   EndDo

   (_cAlias)->( DBCloseArea() )

   If !Empty(_cTipo)
	  _cTipo := SubStr( _cTipo , 1 , Len(_cTipo) - 1 )
   EndIf
	_cFiltro:= "% AND ZZX.ZZX_CODPRD IN " +FormatIn(_cTipo, ';')+ " %"
	_cAlias	:= GetNextAlias()
	BeginSql alias _cAlias
		SELECT ZZX.ZZX_CODIGO, ZZX.ZZX_DATA, ZZX.ZZX_HORA, ZZX.ZZX_FORNEC, ZZX.ZZX_LJFORN, A2F.A2_NREDUZ FORNECE,
		       ZZX.ZZX_PLACA, ZZX.ZZX_TRANSP, ZZX.ZZX_LJTRAN, A2T.A2_NREDUZ TRANSPO, ZZX.ZZX_DENSID, ZZX.R_E_C_N_O_ REGZZX
		  FROM %Table:ZZX% ZZX, %Table:SA2% A2F, %Table:SA2% A2T
		 WHERE ZZX.D_E_L_E_T_ = ' '
		   AND A2F.D_E_L_E_T_ = ' '
		   AND A2T.D_E_L_E_T_ = ' '
		   AND ZZX.ZZX_FILIAL = %xFilial:ZZX%
		   AND A2F.A2_COD = ZZX.ZZX_FORNEC
		   AND A2F.A2_LOJA = ZZX.ZZX_LJFORN
		   AND A2T.A2_COD = ZZX.ZZX_TRANSP
		   AND A2T.A2_LOJA = ZZX.ZZX_LJTRAN
		   AND ZZX.ZZX_FORNEC = %exp:_cFornec%
		   AND ZZX.ZZX_LJFORN = %exp:_cLjForn%
		   AND NOT EXISTS (SELECT ZLX.ZLX_CODIGO
		          FROM %Table:ZLX% ZLX
		         WHERE ZLX.D_E_L_E_T_ = ' '
		           AND ZZX.ZZX_FILIAL = ZLX.ZLX_FILIAL
		           AND ZLX.ZLX_CODANA = ZZX.ZZX_CODIGO)
		   %exp:_cFiltro%
		 ORDER BY ZZX_CODIGO
    EndSql
    
	While (_cAlias)->( !Eof() )

		aAdd( _aDados , {	(_cAlias)->ZZX_CODIGO	,;
						DtoC( StoD(	(_cAlias)->ZZX_DATA ) )	,;
   				 		(_cAlias)->ZZX_HORA		,;
   				 		(_cAlias)->ZZX_FORNEC	,;
   				 		(_cAlias)->ZZX_LJFORN	,;
   				 		(_cAlias)->FORNECE		,;
   				 		(_cAlias)->ZZX_PLACA	,;
   				 		(_cAlias)->ZZX_TRANSP	,;
   				 		(_cAlias)->ZZX_LJTRAN	,;
   				 		(_cAlias)->TRANSPO		,;
   				 		(_cAlias)->ZZX_DENSID	,;
   				 		(_cAlias)->REGZZX		})

      (_cAlias)->( DBSkip() )
   EndDo

   (_cAlias)->( DBCloseArea() )

End Sequence

If Empty(_aDados)
   _aDados   := {{"","","","","","","","","","","",1}}
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AGLT035N()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/02/2018
===============================================================================================================================
Descri��o---------: Atualizar a tela da cosulta espec�fica F3ZZXLT.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT035N()

Begin Sequence
   _oLbx:SetArray( _aDados )
   _oLbx:bLine := {|| { _aDados[_oLbx:nAt][01] ,;
			            _aDados[_oLbx:nAt][02] ,;
			            _aDados[_oLbx:nAt][03] ,;
			            _aDados[_oLbx:nAt][04] ,;
        	            _aDados[_oLbx:nAt][05] ,;
			            _aDados[_oLbx:nAt][06] ,;
			            _aDados[_oLbx:nAt][07] ,;
			            _aDados[_oLbx:nAt][08] ,;
	                    _aDados[_oLbx:nAt][09] ,;
			            _aDados[_oLbx:nAt][10] ,;
			            _aDados[_oLbx:nAt][11] ,;
			            _aDados[_oLbx:nAt][12] }}
   _oLbx:GoTop()			            
   _oLbx:Refresh() 

End Sequence

Return

/*
===============================================================================================================================
Programa----------: AGLT35Tickets(oView)
Autor-------------: Alex Wallauer
Data da Criacao---: 15/02/2018
===============================================================================================================================
Descri��o---------: Monta Tela para consulta dos Tickets
===============================================================================================================================
Parametros--------: oView
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
/*/  

Static Function AGLT35Tickets(oView)

Local _nX			:= 0
Local _cAlias		:= GetNextAlias()
Local _oModel		:= FWModelActive()
Local _nOper		:= _oModel:GetOperation()
Local _cPit			:= PesqPict("ZLD","ZLD_TOTBOM")
Local _cFiltro		:= "%"
Local _cSetor		:= ""
Private nTam      	:= LEN(ZLD->ZLD_TICKET+ZLD->ZLD_SETOR)
Private nMaxSelect	:= 0
Private aCat      	:= {}
Private MvPar     	:= ""
Private cTitulo   	:= ""
Private MvParDef  	:= ""

If M->ZLX_ORIGEM $ "2,3"
	Help(NIL, NIL, "AGLT03531", NIL, "Essa Recep��o de Leite N�O tem origem na Recepcao Leite Terceiros MANUAL (1)", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	Return(.F.)
EndIf

If Empty(M->ZLX_FORNEC)
	Help(NIL, NIL, "AGLT03532", NIL, "Preencha o Forncedor + Loja", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	Return(.F.)
EndIf

If !Empty(M->ZLX_LISTA) .AND. !Empty(_cSalvaForn) .AND. M->ZLX_FORNEC+M->ZLX_LJFORN # _cSalvaForn
	Help(NIL, NIL, "AGLT03533", NIL, "O Fornecedor n�o pode ser modifiado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Retire os vinculos com os Tickets para modifica-lo"})
EndIf

BeginSql alias _cAlias
	SELECT ZL2_COD , ZL2_CRIRT
	FROM %table:ZL2%
	WHERE D_E_L_E_T_ =' '
	AND ZL2_FILIAL = %xFilial:ZL2%
	AND ZL2_CRIRT = '2' 
	AND ZL2_PLAFOR = %exp:M->ZLX_FORNEC%
	AND ZL2_PLALOJ = %exp:M->ZLX_LJFORN%
EndSql

Do While (_cAlias)->(!EOF())
   _cSetor+="'"+(_cAlias)->ZL2_COD+"',"
   (_cAlias)->(DBSkip())
EndDo
(_cAlias)->(DBCloseArea())

If Empty( _cSetor ) 
	Help(NIL, NIL, "AGLT03534", NIL, "O(s) setor(es)  do Forncedor "+M->ZLX_FORNEC+" / "+M->ZLX_LJFORN+" n�o � secundario ou o Fornecedor n�o esta vinculado a nenhum setor.";
		, 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
   DBSelectArea("ZLX")
   Return .F.
EndIf

PRIVATE _cViagens:= ""

Do While  !_nOper  = MODEL_OPERATION_VIEW .AND. !_nOper = MODEL_OPERATION_DELETE

   _lOK     := .F.
   _nLinha  := 05
   _nPula   := 15
   _nCol1   := 05
   _nCol2   := _nCol1+100

   DEFINE MSDIALOG _oDlg TITLE "Tickets / Viagens"  FROM 000,000 TO 170,330 PIXEL
   
	@ _nLinha,_nCol1 SAY "    DIGITE OS TICKETS SEPERADOS POR VIRGULA:" PIXEL
	_nLinha+=_nPula

	@ _nLinha,_nCol1 GET _cViagens MEMO SIZE 150,040 PIXEL OF _oDlg 
	_nLinha+=_nPula
	_nLinha+=_nPula
	_nLinha+=_nPula

    @_nLinha,_nCol1 Button "CONTINUAR" Size 50,15 Action (_lOK:=.T.,Close(_oDlg)) OF _oDlg PIXEL
    @_nLinha,_nCol2 Button "VOLTAR"    Size 50,15 Action (_lOK:=.F.,Close(_oDlg)) OF _oDlg PIXEL
					
   Activate MSDialog _oDlg Centered

   If !_lOK
      Return .F.
   EndIf

   _cViagens:= ALLTRIM(_cViagens)
   If Len(_cViagens) >= Len(ZLD->ZLD_TICKET)
      _cViagens:= StrTran(_cViagens,Chr(10),"")
      _cViagens:= StrTran(_cViagens,Chr(13),"")
      _cViagens:= StrTran(_cViagens," ","")
      _cViagens:= StrTran(_cViagens,"/",",")
      _cViagens:= StrTran(_cViagens,";",",")
      _cViagens:= Upper(_cViagens)
   Else
      _cViagens:=""
   EndIf
   Exit

EndDo

_cSetor:=Left(_cSetor,Len(_cSetor)-1)
	    
_cAlias:=GetNextAlias()
            
//Tratamento para carregar variaveis da lista de opcoes
nMaxSelect:= 0
cTitulo   := "Chave - Ticket / Viagem - Dt coleta - Dt Lanc - Setor - Volume "

If Len(_cSetor) > 10
   _cFiltro += "AND ZLD_SETOR IN ("+_cSetor+") "
Else
   _cFiltro += "AND ZLD_SETOR = "+_cSetor
EndIf

If _nOper  = MODEL_OPERATION_VIEW .OR. _nOper = MODEL_OPERATION_DELETE
   _cQuery += "  AND ZLD_CODZLX = '"+M->ZLX_CODIGO+"'  "
ElseIf Empty(_cViagens)
   _cFiltro += "  AND ((ZLD_CODZLX = ' ' AND ZLD_DTCOLE > '"+DTOS((DDataBase-40))+"') OR ZLD_CODZLX = '"+M->ZLX_CODIGO+"')  "
Else
   _cFiltro += "  AND ZLD_TICKET IN "+FormatIn(_cViagens,",")
EndIf

If _nOper  = MODEL_OPERATION_VIEW .OR. _nOper = MODEL_OPERATION_DELETE
   _cFiltro += "  ORDER BY  ZLD_TICKET , ZLD_SETOR "
Else
   _cFiltro += "  ORDER BY  ZLD_DTCOLE DESC, ZLD_DTLANC DESC , ZLD_SETOR , ZLD_TICKET "
EndIf
_cFiltro += " %"
BeginSql alias _cAlias
	SELECT DISTINCT ZLD_FILIAL, ZLD_TICKET, ZLD_DTCOLE, ZLD_DTLANC, ZLD_SETOR, ZLD_TOTBOM
	FROM %Table:ZLD% ZLD
	WHERE D_E_L_E_T_ = ' '
	AND ZLD_FILIAL = %xFilial:ZLD%
	AND ZLD_STATUS <> 'F'
	AND ZLD_TOTBOM <> 0
	%exp:_cFiltro%
EndSql

nTamPict := 6

Do While (_cAlias)->(!Eof())

	MvParDef += (_cAlias)->ZLD_TICKET+(_cAlias)->ZLD_SETOR

    If Len(AllTrim( Trans((_cAlias)->ZLD_TOTBOM,_cPit))) > nTamPict
       nTamPict:=Len(AllTrim( Trans((_cAlias)->ZLD_TOTBOM,_cPit)))
    EndIf

	AADD(aCat, PadL(AllTrim((_cAlias)->ZLD_TICKET),Len(ZLD->ZLD_TICKET),"0")+" - "+DToC(SToD((_cAlias)->ZLD_DTCOLE))+" - "+;
	           DToC(SToD((_cAlias)->ZLD_DTLANC))+" - "+(_cAlias)->ZLD_SETOR+": "+Right( Trans((_cAlias)->ZLD_TOTBOM,_cPit),nTamPict) )
	           
    If (!Empty(M->ZLX_LISTA) .AND. (_cAlias)->ZLD_TICKET $ M->ZLX_LISTA) .OR. !Empty(_cViagens) .OR. _nOper = MODEL_OPERATION_VIEW .OR. _nOper = MODEL_OPERATION_DELETE
        MvPar+= (_cAlias)->ZLD_TICKET+(_cAlias)->ZLD_SETOR
    EndIf
   
   nMaxSelect++
   (_cAlias)->(dbSkip())
   
EndDo
(_cAlias)->( DBCloseArea() )

If nMaxSelect = 0
	If _nOper = MODEL_OPERATION_VIEW .OR. _nOper = MODEL_OPERATION_DELETE
	   Help(NIL, NIL, "AGLT03535", NIL, "N�o achou tickets anexo para essa recep��o: "+M->ZLX_CODIGO, 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	Else
	   Help(NIL, NIL, "AGLT03536", NIL, "N�o achou tickets em aberto para esse Setor(es): "+_cSetor, 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	EndIf
	DbSelectArea("ZLX")
	Return .F.
EndIf

nMaxSelect:= 10

//====================================================================
//Trativa abaixo para no caso de uma alteracao do campo trazer todos
//os dados que foram selecionados anteriormente.                    
//====================================================================
If Empty(M->ZLX_LISTA)
   MvPar := M->ZLX_LISTA
EndIf
//=============================================================
//Somente altera o conteudo caso o usuario clique no botao ok
//=============================================================
//Executa funcao que monta tela de opcoes
If F_Opcoes(@MvPar		,; //01 -> Variavel de Retorno
			cTitulo		,; //02 -> Titulo da Coluna com as opcoes
			aCat		,; //03 -> Opcoes de Escolha (Array de Opcoes)
			MvParDef	,; //04 -> String de Opcoes para Retorno
            NIL         ,; //Nao Utilizado
            NIL         ,; //Nao Utilizado
			.F.			,; //07 -> Se a Selecao sera de apenas 1 Elemento por vez
			nTam		,; //08 -> Tamanho da Chave
			nMaxSelect	,; //09 -> Quantidade m�xima de registros selecionados ao mesmo tempo
            .T.         ,; //Inclui Botoes para Selecao de Multiplos Itens
            .F.         ,; //Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
            NIL         ,; //Qual o Campo para a Montagem do aOpcoes
            .F.         ,; //Nao Permite a Ordenacao
            .F.         ,; //Nao Permite a Pesquisa    
            .F.         ,; //Forca o Retorno Como Array
            NIL         ); //Consulta F3    
            .AND. !_nOper  = MODEL_OPERATION_VIEW .AND. !_nOper = MODEL_OPERATION_DELETE


	ZLJ->( DbSetorder(3) )//ZLJ_FILIAL+ZLJ_VIAGEM+ZLJ_SETOR+ZLJ_TIPPRO+ZLJ_LINROT
	ZLD->( DbSetorder(5) )//ZLD_FILIAL+ZLD_TICKET+ZLD_SETOR

	M->ZLX_LISTA:= ""
	_nTotVolume := 0
	_aRecnosZLD := {}
	For _nX:= 1 To Len(MvPar) Step nTam
		If !(SubStr(MvPar,_nX,1) $ " |*")
		    _cChave:=Substr(MvPar,_nX,nTam)
		    _cData:=""
		    If ZLJ->( DbSeek( xFilial() + _cChave ) )
		       _cData:=DToC(ZLJ->ZLJ_DTCRIA)
		    EndIf
		    If ZLD->( DbSeek( xFilial("ZLD")+_cChave ) )
		       Do While ZLD->(!Eof()) .AND. xFilial("ZLD")+_cChave == ZLD->ZLD_FILIAL+ZLD->ZLD_TICKET+ZLD->ZLD_SETOR .AND. ZLD->ZLD_TOTBOM = 0
		          ZLD->(DBSkip())
		       EndDo
		       If ZLD->ZLD_TOTBOM <> 0
		          _cData:=If(Empty(_cData),DTOC(ZLD->ZLD_DTCOLE),_cData)
		          _cTexto:=ZLD->ZLD_TICKET+" - "+ZLD->ZLD_SETOR+" - "+_cData+ " - Vol.: "+ Right(Trans(ZLD->ZLD_TOTBOM,_cPit),nTamPict)
		          _nTotVolume+=ZLD->ZLD_TOTBOM
		          AADD(_aRecnosZLD, { ZLD->ZLD_TICKET , ZLD->ZLD_SETOR , ZLD->(RECNO()) } )
		       Else
		          _cTexto:="Sem Volume "+_cChave
		       EndIf
		    Else
		       _cTexto:="N�o achou "+_cChave
		    EndIf
			M->ZLX_LISTA  += _cTexto + CHR(13)+CHR(10)
		EndIf
	Next _nX
	ZLJ->( DbSetorder(1) )
	ZLD->( DbSetorder(1) )
    _oModel:LoadValue( 'ZLXMASTER' , 'ZLX_VOLNF' , _nTotVolume)
    _oModel:LoadValue( 'ZLXMASTER' , 'ZLX_LISTA' , M->ZLX_LISTA )
    _oModel:LoadValue( 'ZLXMASTER' , 'ZLX_DIFVOL', M->ZLX_VOLREC - _nTotVolume)
    _oModel:LoadValue( 'ZLXMASTER' , 'ZLX_BALCAP', M->ZLX_VOLREC - VAL(Posicione("ZZV",2,xFilial("ZZV")+M->(ZLX_TRANSP+ZLX_LJTRAN+ZLX_PLACA),"ZZV_CAPACI"))	)
    _cSalvaForn := M->ZLX_FORNEC+M->ZLX_LJFORN
    _oModel:LMODIFY:=.T.
    _oModel:Activate()
	If _nTotVolume <> 0
	    Help(NIL, NIL, "AGLT03537", NIL, "Tickets / Viagens Selecionadas: " + M->ZLX_LISTA + "Total dos Volumes : "+RIGHT(TRANS(_nTotVolume,_cPit),nTamPict), 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	Else
		_cSalvaForn := ""
	    Help(NIL, NIL, "AGLT03538", NIL, "Foram desmacardos todos os Tickets.", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
	EndIf
EndIf     

DBSelectArea("ZLX")

Return(.T.)

/*
===============================================================================================================================
Programa----------: AGLT035Z()
Autor-------------: Alex Wallauer
Data da Criacao---: 15/02/2018
===============================================================================================================================
Descri��o---------: Monta Tela para consulta dos Tickets
===============================================================================================================================
Parametros--------: oView
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function AGLT035Z()

Local _aParam	:= PARAMIXB
Local _xRet		:= .T.
Local _oObj		:= ''
Local _oModel	:= Nil
Local _cIdPonto	:= ''

If _aParam <> NIL

	_oObj	  := _aParam[01]
	_cIdPonto := _aParam[02]
	_oModel   := FWModelActive()
	_nOper	  := _oObj:GetOperation()

	If _cIdPonto == 'MODELPOS'	.And. ( _nOper == MODEL_OPERATION_INSERT .Or. _nOper == MODEL_OPERATION_UPDATE .OR. _nOper == MODEL_OPERATION_DELETE )

	   Private _cCodigo  := _oModel:GetValue( 'ZLXMASTER' , 'ZLX_CODIGO'	)
	   
       FWMSGRUN(,{|oProc| AGLT35Grv(oProc,_nOper) },"Aguarde! Aguarde! Aguarde! Aguarde! ","Processando Tickets vinculados..." )
	
	ElseIf _cIdPonto ==  'MODELVLDACTIVE'
       _aRecnosZLD := {}
	EndIf
EndIf

Return( _xRet )

/*
===============================================================================================================================
Programa----------: AGLT035Z()
Autor-------------: Alex Wallauer
Data da Criacao---: 15/02/2018
===============================================================================================================================
Descri��o---------: Monta Tela para consulta dos Tickets
===============================================================================================================================
Parametros--------: oView
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/  
Static Function AGLT35Grv(oProc,_nOper)

Local _nX		:= 0
Local _nRecno	:= 0
Local _aOrd		:= SaveOrd({"ZLD"})
Local _cFilZLD	:= xFilial("ZLD")

Begin Transaction

If (_nOper = MODEL_OPERATION_UPDATE .AND. Len(_aRecnosZLD) > 0) .OR. _nOper == MODEL_OPERATION_DELETE//Se clicou no botao e salvou vai ter recnos
	oproc:cCaption := ("Limpando Tickets vinculados...")
	ProcessMessages()
	ZLD->( DbSetorder(8) )// ZLD_FILIAL+ZLD_CODZLX
	If ZLD->(DbSeek( _cFilZLD + _cCodigo) )
		Do While ZLD->(!Eof()) .AND. ZLD->ZLD_FILIAL+ZLD->ZLD_CODZLX == _cFilZLD+_cCodigo
			If !Empty(ZLD->ZLD_CODZLX)
				oproc:cCaption := ("Limpando Ticket / Setor: "+ZLD->ZLD_TICKET+" / "+ZLD->ZLD_SETOR)
				ProcessMessages()
				ZLD->(DBSkip())
				_nRecno:=ZLD->(RECNO())
				ZLD->(DBSkip(-1))
				ZLD->(RECLOCK("ZLD",.F.))
				ZLD->ZLD_CODZLX = ""
				ZLD->(MSUNLOCK())
				ZLD->(DBGoTo(_nRecno))
			Else
				ZLD->(DBSkip())
			EndIf
		EndDo
	EndIf
EndIf

If _nOper <> MODEL_OPERATION_DELETE .AND. Len(_aRecnosZLD) > 0//Se clicou no botao e salvou vai ter recnos
    ZLD->( DbSetOrder(5) )// ZLD_FILIAL+ZLD_TICKET+ZLD_SETOR
    _cMostraViagem:=""
	For _nX := 1 To Len(_aRecnosZLD)
		
		_cChave:=_aRecnosZLD[_nX,1]+_aRecnosZLD[_nX,2]//ZLD_TICKET + ZLD_SETOR
        oproc:cCaption := ("Vinculando Ticket / Setor: "+_aRecnosZLD[_nX,1]+" / "+_aRecnosZLD[_nX,2])
        ProcessMessages()
		
		If ZLD->( Dbseek( _cFilZLD+_cChave ) )//ZLD_TICKET + ZLD_SETOR
			_cMostraViagem+="["+ZLD->ZLD_TICKET+"-"+ZLD->ZLD_SETOR+"], "
			Do While ZLD->(!Eof()) .AND. _cFilZLD+_cChave == ZLD->ZLD_FILIAL+ZLD->ZLD_TICKET+ZLD->ZLD_SETOR
			   If ZLD->ZLD_TOTBOM # 0
				  ZLD->(RECLOCK("ZLD",.F.))
				  ZLD->ZLD_CODZLX = _cCodigo
				  ZLD->(MSUNLOCK())
			   EndIf
				ZLD->(DBSkip())
			EndDo
		EndIf
	Next _nX

	If _nOper = MODEL_OPERATION_INSERT .OR. _cCodigo # ZLX->ZLX_CODIGO
	    Help(NIL, NIL, "AGLT03538", NIL, "Recep��o Gravada ["+_cCodigo+"] nos Tickets anexados: "+_cMostraViagem+;
	    "Recep��o Posicionada: "+ZLX->ZLX_CODIGO+" / Tipo Manuten��o: "+ALLTRIM(STR(_nOper)), 1, 0, NIL, NIL, NIL, NIL, NIL, {"Caso n�o seja o numero da Recep��o que voce entrou para Atualizar entre em contado com a area de TI"})
	EndIf
	
EndIf

End Transaction
_aRecnosZLD := {}//Zera para n�o levar os recnos para outra recep��o
RestOrd(_aOrd,.T.)

Return .T.
