/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista      - Programador  - Inicio  - Envio   - Chamado - Motivo da Altera��o                                               Motivo                                           
=============================================================================================================================== 
               
=============================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch" 
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH" 

Static _cFilOrigem, _cPedOrigem, _cPedPallet

/*
===============================================================================================================================
Fun��o-------------: AOMS147
Autor--------------: Julio de Paula Paz
Data da Criacao----: 29/08/2024 
===============================================================================================================================
Descri��o----------: Rotina de gera��o de pedidos de Pallets de Devolu��o.
                     Rotina utilizada para pedidos de vendas que possuem itens nos armaz�ns 40 e 42, que n�o h� gera��o de
                     Cargas. Chamado 33879.
===============================================================================================================================
Parametros---------: _lScheduller = .T. = Rotina chamada via Scheduller.
                                    .F. = Rotina chamada via menu.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function AOMS147(_lScheduller)
Local _nRegSC5    := SC5->(Recno())
Local _nRegSC6    := SC6->(Recno())
Local _cOperCli   := U_ITGETMV( 'IT_OPERCLPA' , '50')
Local _cOperTran  := U_ITGETMV( 'IT_OPERTRPA' , '51')
Local _cArmazens  := U_ITGETMV( 'IT_ARMPALCH' , '40;42;')
//Local _cOperGPA   := U_ITGETMV( 'IT_OPERGEPA' , '01;')
Local _nPallet    := 0
Local _cProduto   := GetMV( "IT_CCHEP" )
Local _nTotVlrPal := 0
Local _cDesc      := ""
Local _nPreco     := 0
Local _cUM	      := ""
Local _dDtEnt     := Ctod("  /  /  ")

Begin Sequence  

   If ValType(_lScheduller) == Nil 
      _lScheduller := .F.
   EndIf 

   _cFilOrigem  := SC5->C5_FILIAL
   _cPedOrigem  := SC5->C5_NUM 
   cTipoPV		:= SC5->C5_TIPO
   cCliente	    := SC5->C5_CLIENTE
   cLoja		:= SC5->C5_LOJACLI
   _dDtEnt		:= IF(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT)//Para nao travar a criacao do Pedido de Pallet
   
   SC6->(DbSetOrder(1))
   SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
   Do While ! SC6->(Eof()) .And. SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
      
	  If SC6->C6_LOCAL $ _cArmazens
         _nPallet     := _nPallet + SC6->C6_I_QPALT       
		 _cC6_PEDCLI  := SC6->C6_PEDCLI 
         _cC6_ITEMPC  := SC6->C6_ITEMPC 
         _cC6_NUMPCOM := SC6->C6_NUMPCOM
		 _cLocal      := SC6->C6_LOCAL
	  EndIf 

      SC6->(DbSkip())
   EndDo 
     
   SA1->(DbSetOrder(1))
   SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
   If SA1->A1_I_CHEP = "C" .AND. SA1->A1_I_CCHEP <> " "
      cTpOper := _cOperCli   // "50"  
	  M->C5_I_OPER := _cOperCli   // "50"  
   Else 
      cTpOper := _cOperTran  // "51"
	  M->C5_I_OPER := _cOperTran  // "51"
	  cCliente	:= SC5->C5_I_TRAPA  //SC5->C5_CLIENTE 
      cLoja		:= SC5->C5_I_LTRAP  //SC5->C5_LOJACLI
   EndIf  

   _aCabPV		:= {}
   _aItemPV	:= {}
   _TipoC		:= "C"//1-Pallet Chep
   //cTpOper		:= ''
   lMsErroAuto	:= .F.
   nItem		:= 1
   _cDesc      := ""
   _nPreco     := 0
   _cUM	    := ""

   //====================================================================================================
   // Monta o cabe�alho do pedido de Pallet
   //====================================================================================================
   _aCabPV :={	{ "C5_TIPO"		, cTipoPV			, Nil },; // Tipo de pedido				
				{ "C5_I_OPER"	, cTpOper			, Nil },; // Tipo da operacao
				{ "C5_FILIAL"	, _cFilOrigem   	, Nil },; // filial
				{ "C5_CLIENTE"	, cCliente			, Nil },; // Codigo do cliente
				{ "C5_LOJAENT"	, cLoja				, Nil },; // Loja para entrada
				{ "C5_LOJACLI"	, cLoja				, Nil },; // Loja do cliente
				{ "C5_EMISSAO"	, date()			, Nil },; // Data de emissao
				{ "C5_CONDPAG"	, '001'				, Nil },; // Codigo da condicao de pagamanto*
				{ "C5_TIPLIB"	, "1"				, Nil },; // Tipo de Liberacao
	    		{ "C5_MOEDA"	, 1					, Nil },; // Moeda
		    	{ "C5_LIBEROK"	, " "				, Nil },; // Liberacao Total
			    { "C5_TIPOCLI"	, "F"				, Nil },; // Tipo do Cliente
				{ "C5_I_NPALE"	, _cPedOrigem		, Nil },; // Numero que originou a pedido de palete
				{ "C5_I_PEDPA"	, "S"				, Nil },; // Pedido Refere a um pedido de Pallet
				{ "C5_I_GPADV"	, "N"				, Nil },; // Indica que n�o � para gerar pedido de Pallet, pois este j� � um pedido de Pallet.
				{ "C5_I_DTENT"	, _dDtEnt			, Nil } } // Dt de Entrega

				Aadd( _aCabPV, { "C5_I_TRCNF", IF(EMPTY(SC5->C5_I_TRCNF),"N",SC5->C5_I_TRCNF), Nil } )
			    Aadd( _aCabPV, { "C5_I_FILFT", SC5->C5_I_FILFT, Nil } )
			    Aadd( _aCabPV, { "C5_I_FLFNC", SC5->C5_I_FLFNC, Nil } )
                
				If SC5->(FIELDPOS( "C5_I_CDTMS" )) > 0  
				   Aadd( _aCabPV, { "C5_I_CDTMS", SC5->C5_I_CDTMS, Nil } )	
				EndIf 

   //================================================================================
   // Localiza nome do produto, pre�o e UM
   //================================================================================
	SB1->(DBSetOrder(1))
	If SB1->(DBSeek(xFilial("SB1")+_cProduto))				
	   _cDesc := ALLTRIM(SB1->B1_DESC)
	   _nPreco:= SB1->B1_PRV1
	   _cUM	  := SB1->B1_UM
	EndIf
				
	_nTotVlrPal   := _nPallet * _nPreco
				
	//====================================================================================================
	// Monta o item do pedido de Pallet
	//====================================================================================================
	AAdd( _aItemPV , {	{ "C6_ITEM"		, StrZero( nItem , 2 )	, Nil },; // Numero do Item no Pedido
						{ "C6_FILIAL"	, _cFilOrigem			, Nil },;
						{ "C6_PRODUTO"	, _cProduto				, Nil },; // Codigo do Produto
						{ "C6_QTDVEN"	, _nPallet				, Nil },; // Quantidade Vendida
						{ "C6_PRCVEN"	, _nPreco				, Nil },; // Preco Unitario Liquido
						{ "C6_PRUNIT"	, _nPreco				, Nil },; // Preco Unitario Liquido
						{ "C6_ENTREG"	, _dDtEnt				, Nil },; // Data da Entrega
						{ "C6_SUGENTR"	, _dDtEnt				, Nil },; // Data da Entrega
						{ "C6_VALOR"	, _nTotVlrPal			, Nil },; // valor total do item
						{ "C6_UM"		, _cUM					, Nil },; // Unidade de Medida Primar.
						{ "C6_LOCAL"	, _cLocal				, Nil },; // Almoxarifado
						{ "C6_DESCRI"	, _cDesc				, Nil },; // Descricao
						{ "C6_QTDLIB"	, 0						, Nil },; // Quantidade Liberada
	                    { "C6_PEDCLI" 	, _cC6_PEDCLI           , Nil },;
	                    { "C6_ITEMPC"   , _cC6_ITEMPC           , Nil },;
	                    { "C6_NUMPCOM"  , _cC6_NUMPCOM          , Nil }})
				
   //====================================================================================================
   // Gera��o do  pedido de Pallet
   //====================================================================================================
   MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItemPV , 3 )
				
   If lMsErroAuto
      If ! _lScheduller
         MostraErro()
      EndIf 

      If ( __lSx8 )
	     RollBackSx8()
	  EndIf
   Else
      //Regrava por garantia
	  SC5->( RecLock( 'SC5' , .F. ) )
	  SC5->C5_I_NPALE := _cPedOrigem
	  SC5->C5_I_PEDPA := 'S'//� o Pedido de Pallet
      SC5->C5_I_PEDGE := ''
      SC5->( MsUnlock() )
	  //U_ITCONOUT(_cMensagem+": "+SC5->C5_NUM)
	  //====================================================================================================
	  // Faz a amarra��o do pedido de origem no pedido de Pallet
	  //====================================================================================================
	  _cPedPallet := SC5->C5_NUM
	  If SC5->( DBSeek( _cFilOrigem + _cPedOrigem ) )
	     SC5->( RecLock( 'SC5' , .F. ) )
		 SC5->C5_I_NPALE := _cPedPallet
		 SC5->C5_I_PEDPA := ''  
		 SC5->C5_I_PEDGE := 'S' //� o Pedido Gerador de Pallet
		 SC5->( MsUnlock() )
	  EndIf					
   EndIf

End Sequence 

SC5->(DbGoto(_nRegSC5))
SC6->(DbGoto(_nRegSC6))

Return Nil 
