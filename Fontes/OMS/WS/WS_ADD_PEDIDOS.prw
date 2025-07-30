/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor       |   Data   |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 09/01/20 | Chamado 31826. Tratamento para o armazem 70 e 72 e liberação do Pedido. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 15/04/20 | Chamado 31826. Tratamento para gravar o Pedido no Portal (SWZ). 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 21/05/20 | Chamado 33016. Ajustes na importacao de PV via TXT para validar o preço conta a tabela de Preço. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 02/10/20 | Chamado 33016. Gravacao do campo de percetual de leite magro. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 26/10/20 | Chamado 33016. Validação se o Pedido do DW já foi integrado no SWZ. 
-------------------------------------------------------------------------------------------------------------------------------
Jerry        | 04/11/20 | Chamado 34582. Validar novo campo de Tabela de Preço. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 11/11/20 | Chamado 33016. Alterações e tratamento das novas TAGs: FILCARREGAMENTO / TIPVEND . 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 03/11/20 | Chamado 33016. Correção da funcao GeraZWIDPED() . 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 11/12/20 | Chamado 33016. Alteraçao da gravação dos campos:  ZW_FECENT E ZW_I_AGEND . 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 18/12/20 | Chamado 33016. Nova validacao da comissao . 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 15/02/20 | Chamado 33016. Gravacao do campo ZW_TIMEEMI com FWTimeStamp( 4, DATE(), TIME() ). 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 15/03/20 | Chamado 33016. Correção da validacao da comissao . 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 11/06/21 | Chamado 36795. Correção na gravação da filial de carregamento no pedido de vendas.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 02/07/21 | Chamado 31826. Novos tratamentos para a filial de carregamento = "90I". 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço | 13/08/21 | Chamado 37416. Retirado validação da Filial DA0 e DA1. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 02/03/22 | Chamado 31826. Usar a Data de emissao que vem do WS: DATA_EMISSAO . 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 23/03/22 | Chamado 39557. Retirada da validacao de regras de comissao.  
-------------------------------------------------------------------------------------------------------------------------------
Jerry        | 12/05/22 | Chamado 40094. Adicionado Campo para Código de Evento (APAS). 
-------------------------------------------------------------------------------------------------------------------------------
Jerry        | 10/08/22 | Chamado 40977. Adicionado Campo para Código Cliente e Loja de Remessa para Op.Triangular. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 12/03/24 | Chamado 46578. Gravacao do campo ZW_TPFRETE com a TAG TIPO_FRETE.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 23/07/24 | Chamado 47894. Ajuste para grava o campo ZW_FILPRO=ZW_FILIAL quando o mesmo vem com Zero ou "ZZ".
================================================================================================================================================================================================
Analista      - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================
Jerry         - Alex Wallauer - 18/03/25 - 18/03/25 - 50230   - Correção do Ajuste para grava o campo ZW_FILPRO=ZW_FILIAL quando o mesmo vem com Zero ou "ZZ".
Jerry         - Julio Paz     - 08/04/25 - 11/04/25 - 49837   - Inclusão da nova Tag ITEMKITPORTAL e gravação nos campos ZW_KIT e C6_I_KIT.
Jerry         - Julio Paz     - 10/04/25 - 11/04/25 - 41527   - Inclusão da nova Tag RECEBE_SABADO e gravação nos campos ZW_I_RECSA no C5_I_RECSA.
Jerry         - Julio Paz     - 14/07/25 - 24/07/25 - 50433   - Realização de Ajustes nas Regras para Determinar o Armazém de Pedidos de Vendas do Portal - ZW_LOCAL.
================================================================================================================================================================================================

*/                                         
//====================================================================================================
// Definicoes de Includes da Rotina
//====================================================================================================
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"
/*
===============================================================================================================================
Programa----------: WS_ADD_PEDIDOS
Autor-------------: TOTVS
Data da Criacao---: n/a
===============================================================================================================================
Descrição---------: Integração de Pedidos de Vendas 
===============================================================================================================================
Parametros--------: XML
===============================================================================================================================
Retorno-----------: Grava o PV
===============================================================================================================================
*/
//===========================================================================================================================
// ENDEREÇO PARA TESTES http://10.55.0.130:4003/ws/WANW001.apw?WSDL 
//===========================================================================================================================
// Tags dos detalhes do pedido. Aliementará a tabela SC6

WSSTRUCT tAddPedidoDet

	WSDATA	ITEMDW		  as string          // numero
	WSDATA	ITEMPRODUTO	  as string          // produto_codigo
	WSDATA	ITEMQTDE	  as float           // quantidade_un_1
	WSDATA	ITEMQTDE2UM	  as float OPTIONAL  // quantidade_un_2
	WSDATA	ITEMPRCTAB	  as float OPTIONAL  // valor_unitario_tabela_preco
	WSDATA	ITEMVALDESC	  as float OPTIONAL  // valor_total_descontos
	WSDATA	ITEMPERDESC	  as float OPTIONAL  // percentual_total_descontos
	WSDATA	ITEMPRCVEN	  as float OPTIONAL  // valor_unitario_venda
	WSDATA	ITEMPERCOMS	  as float OPTIONAL  // comissao_porcentagem
	WSDATA	ITEMNUMPCOM	  as string OPTIONAL // ordem_compra
	WSDATA  ITEMKITPORTAL as string OPTIONAL // Código do Kit no Portal

ENDWSSTRUCT

//===========================================================================================================================
// Cabeçalho do pedido de vendas. Alimentará a tabela SC5

WSSTRUCT tAddPedidoCab

	WSDATA  EMPRESA         	AS string OPTIONAL// cnpj
	WSDATA  FILIAL          	AS string OPTIONAL// cnpj
	WSDATA  CNPJ				AS String

	WSDATA PEDIDODW		as string // codigo
	WSDATA COND_PGTO	as string // condicao_pagamento_codigo
	WSDATA TABELAPRECO	as string OPTIONAL // tabela_preco_codigo
	WSDATA TRANSPORT	as string OPTIONAL // transportadora_codigo
	WSDATA VENDEDOR	 	as string OPTIONAL // vendedor_codigo
	WSDATA TIPVEND      as string OPTIONAL // Tipo de Venda C5_I_TPVEN
	WSDATA TIPO_FRETE	as string // frete_codigo
	WSDATA DATA_ENTREGA	as date // data_entrega
	WSDATA DATA_EMISSAO	as date OPTIONAL // data_emissao
	WSDATA VALOR_FRETE	as float OPTIONAL // valor_total_frete
	WSDATA COMISSAO		as float OPTIONAL // porcentagem_total_comissao
	WSDATA MENS_NOTA	as string OPTIONAL // mensagem_nota_fiscal
	WSDATA MENS_PEDIDO	as string OPTIONAL // observacao_comercial
	WSDATA DESCONTO		as float OPTIONAL // percentual_total_descontos
	WSDATA STATUS		as string // status
	WSDATA OPERACAO		as string // operacao_codigo
	WSDATA ORDEM_COMPRA	as string OPTIONAL // ordem_compra

	WSDATA TOT_C_IMPOST		as float OPTIONAL // valor_total_com_impostos
	WSDATA TOT_S_IMPOST		as float OPTIONAL // valor_total_sem_impostos
	WSDATA VALOR_DESC		as float OPTIONAL // valor_total_descontos
	WSDATA TOTAL_IPI		as float OPTIONAL // valor_total_ipi
	WSDATA TOTAL_ICMS		as float OPTIONAL // valor_total_icms
	WSDATA TOTAL_ICMS_ST	as float OPTIONAL //valor_total_st
	WSDATA TOTAL_DESCONT	as float OPTIONAL // valor_total_sem_descontos
	WSDATA TOTAL_IMPOSTOS	as float OPTIONAL  // valor_total_impostos
	WSDATA PESO_TOTAL		as float OPTIONAL  // peso_total
	WSDATA MOTIV_REPROV		as string OPTIONAL  // motivo_reprovacao_codigo
	WSDATA QTDE_FATURADA	as float OPTIONAL // total_quantidade_un_1_faturada
	WSDATA QTDE_PEDIDO		as float OPTIONAL // total_quantidade_un_1
	WSDATA HORA_EMISSAO		as string OPTIONAL // hora_emissao
	WSDATA ALCADA			as string OPTIONAL // alcada
	WSDATA ORIGEM_PEDIDO	as string OPTIONAL // origem
	WSDATA TOTAL_COMISSAO	as float OPTIONAL // valor_total_comissao
	WSDATA REPRESENTANTE	as string OPTIONAL // pedido_representante
	WSDATA DATA_FATURAM		as date OPTIONAL // data_faturamento
	WSDATA CUBAGEM			as float OPTIONAL // total_metragem_cubica
	WSDATA PEDIDO_ORIGEM	as string OPTIONAL // pedido_origem
	WSDATA NRO_EDICOES		as string OPTIONAL // edicoes
	WSDATA CONTATO_PED		as string OPTIONAL // contato_codigo
	WSDATA USUARIO			as string OPTIONAL // usuario_codigo
	WSDATA PENDENCIA		as string OPTIONAL // aceita_pendencia
	WSDATA VAL_DEONERADO	as float OPTIONAL // valor_total_desoneracao_icms
	WSDATA PV_BONIFIC		as string OPTIONAL // pedido_bonificado_codigo  
	WSDATA EVENTO           as string OPTIONAL // Evento APAS   
	     
	//DW
	WSDATA TIPOENTREGA	 	as string OPTIONAL // Tipo de Entrega (Imediato / Agendado / Agendado Com MultA
	WSDATA HORAENTREGA	 	as string OPTIONAL // Hora de Entrega  
	WSDATA SENHA	    	as string OPTIONAL // Senha
    WSDATA TIPCA            as string OPTIONAL // Tipo de Carga C5_I_TIPCA
	WSDATA CHAPA			as float OPTIONAL  // Qtd de Chapa
	WSDATA CUSTOENTREGA		as float OPTIONAL  // Custo de Entrega 
	WSDATA INFOENTREGA      as string OPTIONAL // Informação de Entrega do Cliente
	WSDATA FILCARREGAMENTO  as string OPTIONAL // Filial  C5_I_FLFNC
 	WSDATA FAIXA            as string OPTIONAL // Faixa de Peso para Gravar no Item do Pedido
	WSDATA ZW_CLIREM        as string OPTIONAL // Cliente Remessa Quando Pedido Operação Triangular
	WSDATA ZW_LOJEN         as string OPTIONAL // Loja do Cliente Remessa Quando Pedido Operação Triangular	
	WSDATA RECEBE_SABADO    as string OPTIONAL // Cliente Recebe aos Sabados S=Sim e N=Não
 	
	// itens do pedido
	WSDATA zzItensDoPedido	AS Array Of tAddPedidoDet

ENDWSSTRUCT
 
//==============================================================================================================================
// serviço de atualização de Pedidos de Vendas

WSSERVICE WANW001 DESCRIPTION "Serviço de atualização dos pedidos de vendas"

	WSDATA EMPRESA         	AS string OPTIONAL// cnpj
	WSDATA FILIAL          	AS string OPTIONAL// cnpj
	WSDATA CNPJ				AS String
	WSDATA tAddPedido		AS tAddPedidoCab
	WSDATA NumeroDoPedido	AS String
	WSDATA WsStrDel			AS String 

	WSMETHOD AddPedido      DESCRIPTION "Modo de Inclusão do Pedido de Vendas"

ENDWSSERVICE

//=============================================================================================================================
//Metodo para Inclusao do Pedido de Venda.

WSMETHOD AddPedido WSRECEIVE EMPRESA, FILIAL, CNPJ, tAddPedido WSSEND NumeroDoPedido WSSERVICE WANW001

Local aArea			:= {}
Local aCabDw		:= {}
Local aItemDw		:= {}
Local lReturn  		:= .T.
Local aRetIte		:= {}
Local cEmprWan		:= Upper(Alltrim(::Empresa))
Local cFilWan		:= Upper(Alltrim(::Filial))
Local aRecnoSM0		:= {}
Local lEmpres		:= .F.

Private cNumpedDW := ::tAddPedido:PEDIDODW
Private cCnpj	  := UnMaskCNPJ( ::CNPJ ) 
Private _lPortal  := U_ITGETMV("IT_INPORTAL",.T.) 


WSConOut("[WS_ADD_PEDIDOS] "+Repl("-",150))
WSConOut("[WS_ADD_PEDIDOS] INICIO AddPedido WSRECEIVE NUMERO DW, FILIAL: " + cNumpedDW + " " + cFilWan ) 

Private lMsErroAuto		:= .F.	// Variavel que define que o help deve ser gravado no arquivo de log e que as informacoes estao vindo a partir da rotina automatica
Private lMsHelpAuto		:= .T.	// Forca a gravacao das informacoes de erro em array para manipulacao da gravacao ao inves de gravar direto no arquivo temporario
PRIVATE lAutoErrNoFile	:= .T.
PRIVATE _nSeq			:= 0
PRIVATE _cNumPed		:= ""
Private _cFilPedido   	:= ""

_cFilAtual:= cFilAnt // Filial que esta logado
cFilAnt	 := cFilWan  // Filial que o pedido do portal esta selecionado para efetivacao 

// tratamento para carregar a empresa diretamente no fonte
aRecnoSM0	:=	{cEmprWan,cFilWan} //Posição 1 referente ao codigo da empresa, posição 2 referente a filial caso não seja informado no aParam
If !empty(alltrim(aRecnoSM0[01])) .and. !empty(alltrim(aRecnoSM0[02]))
     Reset Environment
     RPCSetType(3)
     If FindFunction("WFPREPENV")
          WfPrepENV(aRecnoSM0[1],aRecnoSM0[2])
          lAuto	:=	.T.
     Else
          Prepare Environment Empresa aRecnoSM0[1] Filial aRecnoSM0[2]
     EndIf
     lEmpres := .T.                                         
EndIf

aArea	:= GetArea()

WSConOut("[WS_ADD_PEDIDOS] WebService Pedido de Venda Filial "   ) 
WSConOut("[WS_ADD_PEDIDOS] Inicio: " + Time() + " Data: " + DtoC(Date()))

// validações gerais do cabeçalho
aCabDw := WFADDCABDW(@::tAddPedido)            
if aCabDw[1]
	//WSConOut(oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " está apto a passar pela validação dos itens para gerar Pedido de Vendas"))
	aItemDw := WFADDITDW(@::tAddPedido,@::tAddPedido:zzItensDoPedido)
	if aItemDw[1]
		//WSConOut(oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " está apto a gerar Pedido de Vendas"))
		aRetIte := WSGRPED(@::tAddPedido, @::tAddPedido:zzItensDoPedido)
		if aRetIte[1]

            WSConOut("[WS_ADD_PEDIDOS] Retorno .T. - C5_I_PEDDW: "+cNumpedDW)
            IF _lPortal

			   ::NumeroDoPedido := ALLTRIM(aRetIte[2])//SZW->ZW_IDPED
			
			ELSE
			
			   // Envio o número do pedido para o DW
			   cQuery := " SELECT COUNT(C5_NUM) QUANT, C5_NUM, C5_I_PEDDW "
			   cQuery += " from " + retSqlName("SC5") + " SC5 "
			   cQuery += " WHERE SC5.D_E_L_E_T_ <> '*' "
			   cQuery += " and C5_I_PEDDW = '" + cNumpedDW + " ' "
			   //cQuery += " and C5_FILIAL = '" + xFilial("SC5") + "' "
			   cQuery += " group by C5_I_PEDDW,C5_NUM "
   
               //WSConOut("[WS_ADD_PEDIDOS] cQuery: "+cQuery)
   
			   TCQuery cQuery NEW ALIAS "WSPED1"
   
			   if WSPED1->QUANT > 0
			   	  DO WHILE WSPED1->(!EOF())
			   	  	 _cNumPed := alltrim(WSPED1->C5_NUM)
			   	  	 ::NumeroDoPedido := alltrim(_cNumPed)
			   	  	  WSPED1->(dbSkip())
			   	  ENDDO
			   ENDIF
			   WSPED1->(DBCLOSEAREA())

			ENDIF
		else
			if !empty(aRetIte[2])
				WSConOut("[WS_ADD_PEDIDOS] Retorno .F. - aRetIte[2]: "+aRetIte[2])
				SetSoapFault( "AddPedido" ,aRetIte[2])
			endif
			lReturn := .F.

		endif
		lValidaPed	:= .T.
	else
		if !empty(aItemDw[2])
			WSConOut("[WS_ADD_PEDIDOS] aItemDw[2]: "+aItemDw[2])
			SetSoapFault( "AddPedido" ,aItemDw[2])
		endif
		lReturn := .F.
	endif
else
	if !empty(aCabDw[2])
		WSConOut(aCabDw[2])
		SetSoapFault( "AddPedido" ,aCabDw[2])
	endif
	lReturn := .F.

endif

WSConOut("[WS_ADD_PEDIDOS] Fim: " + Time() + " Data: " + DtoC(Date()))

if lEmpres
	RpcClearEnv()
endif

RestArea(aArea)

WSConOut("[WS_ADD_PEDIDOS] "+Repl("-",150))

Return( lReturn )

//===========================================================================================================================
// geração do pedido de vendas propriamente dita

static function WSGRPED(oObjSC5, oObjSC6)

Local aArea 		:= GetArea()
//Local lRetPv		:= .T.
//Local lOrdenaIt		:= .F.
//Local cQuery 		:= ""
//Local aItem     	:= {}
//Local _cPendC5		:= getNextAlias()
Local cItemSeq	:= Replicate( "0" , GetSx3Cache( "C6_ITEM" , "X3_TAMANHO" ) )
Local nItem     := 0
Local nItens  	:= 0
//Local cRastro	:= " "
Local nLimite	:= 999 // supergetmv("MV_NUMITEN",.F.,150)
Local _aDevol	:= {}
local nItemPed	:= 0

Private cPedido 	:= ""
Private lRetItem  	:= .T.
Private _cDevol		:= ""
Private cOperC5 	:= alltrim(oObjSC5:Operacao)

Private aCab 		:= {}
Private aItem		:= {}
Private aItens		:= {}
Private _lPortal  := U_ITGETMV("IT_INPORTAL",.T.)  


nItens := Len(oObjSC6)

For nItem := 1 To nItens

	If !Empty(oObjSC6[nItem]:ITEMPRODUTO)

		cItemSeq := Soma1(cItemSeq)

		if oObjSC5:DESCONTO > 0
			_nPrcVen := oObjSC6[nItem]:ITEMPRCVEN
//			_nPrcVen := _nPrcVen * (1-(oObjSC5:DESCONTO / 100))
//			_nPrcVen := ROUND(_nPrcVen,tamSx3("C6_PRCVEN")[02])
		else
			_nPrcVen := oObjSC6[nItem]:ITEMPRCVEN
		endif
		//--> Campos fixos
		aAdd( aItem , { "C6_ITEM"  		, cItemSeq      							, NIL } )
		aAdd( aItem , { "C6_PRODUTO"	, oObjSC6[nItem]:ITEMPRODUTO				, NIL } )
		aAdd( aItem , { "C6_QTDVEN"  	, oObjSC6[nItem]:ITEMQTDE					, NIL } )
		aAdd( aItem , { "C6_UNSVEN" 	, oObjSC6[nItem]:ITEMQTDE2UM				, Nil } ) 
		aAdd( aItem , { "C6_PRCVEN"  	, _nPrcVen									, NIL } )
        IF _lPortal
		   aAdd( aItem , { "C6_PRUNIT"  	, ROUND(oObjSC6[nItem]:ITEMPRCTAB,2)	, NIL } )
        ENDIF
//		aAdd( aItem , { "C6_DESCONT"  	, oObjSC6[nItem]:ITEMPERDESC				, NIL } )
		aAdd( aItem , { "C6_NUMPCOM"  	, oObjSC5:ORDEM_COMPRA						, NIL } )
  		aAdd( aItem , { "C6_ITEMPC"  	, cItemSeq                                  , NIL } )
		aAdd( aItem , { "C6_ENTREG"  	, oObjSC5:DATA_ENTREGA						, NIL } )
		aAdd( aItem , { "C6_OPER"	  	, oObjSC5:OPERACAO							, NIL } ) 
		aAdd( aItem , { "C6_LOCAL"	  	, "70"          							, NIL } ) 	
		aAdd( aItem , { "C6_I_FXPES"  	, oObjSC5:FAIXA						        , NIL } )		
        aAdd( aItem , { "C6_I_KIT" 	    , oObjSC6[nItem]:ITEMKITPORTAL				, Nil } )  

		//

			If SC6->(FieldPos("C6_I_ITDW")) > 0
				IF VALTYPE(SC6->C6_I_ITDW) = "C"
					AADD( aItem , { "C6_I_ITDW",oObjSC6[nItem]:ITEMDW, NIL } )
				ELSEIF VALTYPE(SC6->C6_I_ITDW) = "N"
					AADD( aItem , { "C6_I_ITDW",VAL(ALLTRIM(oObjSC6[nItem]:ITEMDW)), NIL } )
				ENDIF
			EndIf

//		aItem := WsAutoOpc( @aItem , .T. )

		aAdd( aItens , aItem )
		aItem := {}
		nItemPed := nItemPed + 1
	EndIf

	// se o numeero do item lido + 1 for maior que o parametrizado, gero o cabeçalho do pedido de vendas
	if nItemPed + 1 > nLimite
		_nSeq := _nSeq + 1
		PutPvHead(oObjSC5,aItens)
		cItemSeq	:= Replicate( "0" , GetSx3Cache( "C6_ITEM" , "X3_TAMANHO" ) )
		nItemPed := 0
		aCab 	:= {}
		aItens 	:= {}
	endif

Next nItem

//pego o que sobrou para não ficar nada de fora
if len(aItens) > 0
	_nSeq := _nSeq + 1
	PutPvHead(oObjSC5,aItens)
endif

restarea(aArea)

aadd(_aDevol, lRetItem)
aadd(_aDevol, _cDevol)

Return ( _aDevol )

//============================================================================================================================
// geração do cabe?lho do pedido de vendas

Static Function PutPvHead(oObj,aItens)

Local cPedDw			:= alltrim(oObj:PEDIDODW)
//Local cPedido			:= "AUTOMATICO"  
Local cCodigoCliente 	:= posicione("SA1",03,xFilial("SA1") + cCnpj, "A1_COD")
Local cLojaCliente 		:= posicione("SA1",03,xFilial("SA1") + cCnpj, "A1_LOJA")
Local cTipoCliente 		:= posicione("SA1",03,xFilial("SA1") + cCnpj, "A1_TIPO")
Local _aProdutos:={}, P  , I
Local _cProdutos:=""
Local cArm  :=""
Local _aItem:={}
Local _nPosI:=0
Local _nPosQ:=0
Local _cFilAux:="" //, C
Local _cFilCarreg
Local _cTpPedVd, _nPosTpPv

if _nSeq > 1
	cPedDw := cPedDw + "-" + alltrim(str(_nSeq - 1))
endif
/*
dbselectarea("SC5")
SC5->(dbSetOrder(1))
While (.T.)
	cPedido := GETSXENUM("SC5","C5_NUM")
	If !SC5->(dbSeek(xFilial("SC5") + cPedido))
		SC5->(rollbackSx8())
		Exit
	Endif
	SC5->(ConfirmSX8())
Enddo   */

//_cFilCarreg := Space(2)
//If ! Empty(oObj:FILCARREGAMENTO)
   _cFilCarreg := oObj:FILCARREGAMENTO//LEFT(oObj:FILCARREGAMENTO,2)
//EndIf 

// zero o aCab
aCab 	:= {}                       
	aCab := {	{ "C5_FILIAL"	, oObj:FILIAL    			, Nil },;  //				{ "C5_NUM"		, cPedido	  	    		, NIL },;
				{ "C5_I_OPER" 	, oObj:OPERACAO				, Nil },;
				{ "C5_TIPO"   	, "N"	        			, Nil },;				
				{ "C5_CLIENTE"	, cCodigoCliente			, Nil },;
				{ "C5_LOJACLI"	, cLojaCliente	    		, Nil },;
				{ "C5_TIPOCLI"	, cTipoCliente 	    		, Nil },;
				{ "C5_VEND1"	, oObj:VENDEDOR				, Nil },;
				{ "C5_CLIENT"	, cCodigoCliente			, NIL },;
  				{ "C5_LOJAENT"	, cLojaCliente				, NIL },;//{ "C5_DESC1"	, oObj:DESCONTO				, NIL },;//
  				{ "C5_TRANSP"	, oObj:TRANSPORT			, NIL },;
  				{ "C5_CONDPAG"	, oObj:COND_PGTO			, NIL },;
  				{ "C5_I_TAB"	, oObj:TABELAPRECO			, NIL },;
  				{ "C5_I_PEDDW"	, alltrim(cPedDw)			, NIL },;
  				{ "C5_MENNOTA"	, alltrim(oObj:MENS_NOTA) 	, NIL },;
  				{ "C5_TPFRETE"	, oObj:TIPO_FRETE	  	  	, NIL },;
 				{ "C5_EMISSAO"  , oObj:DATA_EMISSAO			, NIL },;
 				{ "C5_I_DTENT"  , oObj:DATA_ENTREGA			, NIL },;
 				{ "C5_FECENT"   , oObj:DATA_ENTREGA			, NIL },;
 				{ "C5_I_OBPED"	, alltrim(oObj:MENS_PEDIDO)	, NIL },;
 				{ "C5_I_TRCNF"	, "N"                   	, NIL },;
 				{ "C5_I_AGEND"	, oObj:TIPOENTREGA          , NIL },;
 				{ "C5_I_HOREN"  , oObj:HORAENTREGA          , NIL },;
 				{ "C5_I_SENHA"  , oObj:SENHA                , NIL },;
 				{ "C5_I_TIPCA"  , oObj:TIPCA                , NIL },;//"1"  
 				{ "C5_I_HORP"   , oObj:INFOENTREGA          , NIL },;
 				{ "C5_I_CHAPA"  , ALLTRIM(oObj:CHAPA)       , NIL },;
 				{ "C5_I_TPVEN"  , ALLTRIM(oObj:TIPVEND)     , NIL },;//"F"  
 				{ "C5_I_PEDDW"  , oObj:PEDIDODW				, NIL },;	
 				{ "C5_I_FLFNC"  , _cFilCarreg               , NIL },;//FILIAL DE PRODUCAO / CARREGAMENTO	 // LEFT(oObj:FILCARREGAMENTO,2)
 				{ "C5_I_EVENT"  , oObj:EVENTO				, NIL },;	
 				{ "C5_I_CLIEN"  , oObj:ZW_CLIREM			, NIL },;					
 				{ "C5_I_LOJEN"  , oObj:ZW_LOJEN 			, NIL },;									
 				{ "C5_I_CUSDE"  , oObj:CUSTOENTREGA         , NIL },;
				{ "C5_I_RECSA"  , If(Empty(oObj:RECEBE_SABADO),"N",oObj:RECEBE_SABADO), NIL }}  
/*
IF _lPortal//SZW
   aCab2 := ACLONE(aCab)
   aCab2 := WsAutoOpc( @aCab2 )
    FOR C := 1 TO LEN(aCab2)
       WSConOut(ARRTOKSTR(aCab2[C],";"))
	NEXT
ELSE
   aCab := WsAutoOpc( @aCab )
    FOR C := 1 TO LEN(aCab)
       WSConOut(ARRTOKSTR(aCab[C],";"))
	NEXT
ENDIF*/

_nPosI:=ASCAN(aCab, {|I| I[1] == "C5_FILIAL"  } )
IF _nPosI <> 0
   _cFilAux:=aCab[_nPosI,2]
ENDIF
IF EMPTY(_cFilAux)
   _cFilAux:=xFilial("SC5")
ENDIF

_aProdutos:={}
_cProdutos:=""
//_cItensZAE:=""
//_cCodVend :=LEFT(oObj:VENDEDOR,LEN(ZAE->ZAE_VEND))

//ZAE->(DbSetOrder(4)) // ZAE_FILIAL+ZAE_VEND+ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA

FOR P := 1 TO LEN(aItens)
   _aItem:=aItens[P]//Linha
   _nPosI:=ASCAN(_aItem, {|I| I[1] == "C6_PRODUTO" } )
   _nPosQ:=ASCAN(_aItem, {|I| I[1] == "C6_QTDVEN"  } )
   AADD(_aProdutos,{_aItem[_nPosI,2],;//1
                    _aItem[_nPosQ,2],;//2
					0, ;//3
					0, ;//4
					""})//5
   _cProdutos+=_aItem[_nPosI,2]+";"
/*
   WSConOut("Seek no ZAE : "+_cCodVend+_aItem[_nPosI,2]) 
   IF !ZAE->(DbSeek(xFilial("ZAE")+_cCodVend+_aItem[_nPosI,2]))  .OR.;
                                          ZAE->ZAE_MSBLQL = '1'  .OR.;
										  !EMPTY(ZAE->ZAE_GRPVEN) .OR.;
										  !EMPTY(ZAE->ZAE_CLI   ) .OR.;
										  !EMPTY(ZAE->ZAE_LOJA  ) 
   	  _cItensZAE += "["+ALLTRIM(_aItem[_nPosI,2])+"] "
      WSConOut("Erro no ZAE : ZAE_MSBLQL ="+ZAE->ZAE_MSBLQL) 
   ENDIF*/

NEXT
/*
IF !EMPTY(_cItensZAE)
   _cDevol := "[WS_ADD_PEDIDOS] Produtos: "+_cItensZAE+" nao possui regra de comissao ou bloqueada."
   WSConOut(_cDevol)
   _lRet := lRetItem := .F.
   return()
ENDIF*/

IF !_lPortal

   _cProdutos:=LEFT(_cProdutos,LEN(_cProdutos)-1)
   
   WSConOut("[WS_ADD_PEDIDOS] INICIO Ver_Est_PV() "+_cProdutos+" LEN(_aItem) = "+STR(LEN(_aItem)))
      
   _lRet := Ver_Est_PV(_cFilAux,_aProdutos,@_cProdutos)//Verefica se tem estoque nos armazens indicados no parametro IT_WSPVARM
   
   IF !_lRet
   	  _cDevol := "[WS_ADD_PEDIDOS] Pedido com saldo insuficiente nos produtos: "+_cProdutos+ "."
   	  WSConOut(_cDevol)
   	  lRetItem := .F.
   	  return()
   ELSE
   	  FOR P := 1 TO LEN(aItens)
   	  	_aItem:=aItens[P]//Linha
  	    _nPosL:=ASCAN(_aItem, {|I| I[1] == "C6_LOCAL" } )
  	    _nPosI:=ASCAN(_aItem, {|I| I[1] == "C6_PRODUTO" } )
		_cProduto:=_aItem[_nPosI,2]
		cArm:=""
		IF (_nPosA:=ASCAN(_aProdutos,{|S| S[1]==_cProduto} ))
		   cArm:=_aProdutos[_nPosA,5]
   	  	   _aItem[_nPosL,2]:=cArm
		ENDIF	 
   	    WSConOut("[WS_ADD_PEDIDOS] Arm.: "+cArm+" sera ultilizado para o produto: "+_cProduto+ ".")
   	  NEXT   	
   ENDIF
ENDIF


// geração do pedido de vendas
IF LEN(aCab) > 0 .and. len(aItens) > 0
   //================================================================================
   // Definir o tipo de venda com base nas regras da tabela de preços.
   //================================================================================
   _cTpPedVd := DefTPPedVd(aItens, oObj:OPERACAO, ALLTRIM(oObj:TIPVEND), oObj:TABELAPRECO, _cFilAux)
   If AllTrim(oObj:TIPVEND) <> _cTpPedVd
      _nPosTpPv := AsCan(aCab, {|x| x[1] == "C5_I_TPVEN"})
	  aCab[_nPosTpPv,2] := _cTpPedVd  
   EndIf
   //================================================================================

	WSConOut ("[WS_ADD_PEDIDOS] Inicio da Montando PEDIDO. PV posicionado: " + SC5->C5_FILIAL+"-"+SC5->C5_NUM)

    _cAOMS074:=""//Pega as mensagens de erro do MT410TOK.prw  // ITALAC

	begintran()                                    

	IF _lPortal
       
	   WSConOut ("[WS_ADD_PEDIDOS] GRAVANDO PV VIA PORTAL [SZW]")
	   _cDevol:=GravaPortal(aCab,aItens,_cFilAux)//SZW->ZW_IDPED
    
	ELSE

	   WSConOut ("[WS_ADD_PEDIDOS] GRAVANDO PV VIA MSEXECAUTO [SC5]")
   
//	   MSExecAuto({|a,b,c,d| MATA410(a,b,c,d)}, aCabec,aItens, nOpcX,.F.)
	   MsExecAuto({|x,y,z,d| MATA410(x,y,z,d)} ,aCab  ,aItens, 3    ,.F.)

    ENDIF

	WSConOut ("[WS_ADD_PEDIDOS] Final da Montagem do PEDIDO. PV posicionado: " +  SC5->C5_FILIAL+"-"+SC5->C5_NUM)

	If lMsErroAuto

		aAutoErro := GETAUTOGRLOG()
		_cDevol := "[WS_ADD_PEDIDOS] Resultado - [ERRO]: " + alltrim(XCONVERRLOG(aAutoErro))
		WSConOut(_cDevol)
		IF !EMPTY(_cAOMS074)// ITALAC
		    WSConOut("[WS_ADD_PEDIDOS] _cAOMS074: "+ALLTRIM(_cAOMS074))
		   _cDevol += " [MT410TOK]: "+ALLTRIM(_cAOMS074)// ITALAC
		ENDIF// ITALAC
		lRetItem := .F.

	ELSEIF !_lPortal

	    WSConOut ("[WS_ADD_PEDIDOS] LIBERANDO o Pedido: " + SC5->C5_FILIAL+"-"+SC5->C5_NUM+"/ Pedido DW: " + alltrim(oObj:PEDIDODW))
		IF !Ver_Lib_PV(SC5->C5_FILIAL+SC5->C5_NUM)//LIBERA O PEDIDO SE INCLUIDO COM SUCESSO
			_cDevol := "[WS_ADD_PEDIDOS] Resultado - NAO foi possivel LIBERAR (SC9) o Pedido: "+SC5->C5_FILIAL+"-"+SC5->C5_NUM+"/ Pedido DW: " + alltrim(oObj:PEDIDODW)
			WSConOut(_cDevol)
			lRetItem := .F.
		    DisarmTransaction()			
		ELSE
	        WSConOut ("[WS_ADD_PEDIDOS] Resultado - LIBEROU o Pedido: "+SC5->C5_FILIAL+"-"+SC5->C5_NUM+"/ Pedido DW: " + alltrim(oObj:PEDIDODW))
			// Zero as variaeis temporarias
			cItemSeq	:= Replicate( "0" , GetSx3Cache( "C6_ITEM" , "X3_TAMANHO" ) )
			nItemPed := 0
			aCab 	:= {}
			aItens 	:= {}
	    ENDIF

	EndIF
	endtran()
else
	if len(aCab) == 0
		_cDevol := oemtoansi("[WS_ADD_PEDIDOS] Resultado - Pedido DW " + alltrim(oObj:PEDIDODW) + " - Problema no cabeçalho do pedido do cliente " + cCNPJ  + ".")
		lRetItem := .F.
	elseif len(aItens) == 0
		_cDevol :=  oemtoansi("[WS_ADD_PEDIDOS] Resultado - Pedido DW " + alltrim(oObj:PEDIDODW) + " - Problema nos itens do pedido do cliente " + cCNPJ  + ".")
		lRetItem := .F.
	endif
	WSConOut(_cDevol)
endif

return()
//============================================================================================================================
// Validações do cabeçalho de vendas
Static Function WFADDCABDW(oSC5Tmp)

Local lExiste 	:= .T.
Local cMsg		:= ""
Local cQuery 	:= ""
Local _cAliasDw	:= ""
//Local _aArea	:= ""
//Local cSA1Fil	:= xFilial( "SA1" )
Local _aRet		:= {}
Local  _lPortal  := U_ITGETMV("IT_INPORTAL",.T.) 

// pedido já existe no protheus?
_cAliasDw := getNextAlias()

IF _lPortal
   cQuery := " SELECT ZW_IDPED AS C5_NUM "
   cQuery += " FROM " + RETSQLTAB("SZW")
   cQuery += " WHERE SZW.D_E_L_E_T_ <> '*'
   cQuery += " and ZW_I_PEDDW LIKE '%" + cNumpedDW + "%' "
ELSE
   cQuery := " SELECT C5_NUM  "
   cQuery += " FROM " + RETSQLTAB("SC5")
   cQuery += " WHERE SC5.D_E_L_E_T_ <> '*'
   //cQuery += " and C5_FILIAL = '" + xFilial("SC5") + "' "
   cQuery += " and C5_I_PEDDW LIKE '%" + cNumpedDW + "%' "
ENDIF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),_cAliasDw,.T.,.T.)

if !EMPTY((_cAliasDw)->C5_NUM)
	lExiste := .F.
	cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " com Cliente do CNPJ " + cCnpj  + " Já integrado anteriormente, PV Protheus: "+(_cAliasDw)->C5_NUM)
endif
(_cAliasDw)->(dbcloseArea())            

// CNPJ existe no Protheus?
if lExiste
	IF Empty(cCnpj)
		lExiste := .F.
		cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " sem CNPJ / CPF informado!")
	else
		SA1->(dbSetOrder(03)) // A1_FILIAL+A1_CGC
		IF SA1->(!dbSeek(xfilial("SA1") + cCnpj))
			lExiste := .F.
			cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - Cliente do CNPJ " + cCnpj  + " não encontrado. Verificar cadastro de clientes.")
  		else
  			if SA1->(FieldPos("A1_MSBLQL")) > 0
				if SA1->A1_MSBLQL == "1"
                   SA1->(RECLOCK("SA1",.F.))
				   SA1->A1_MSBLQL:="2"
				   IF SA1->A1_VENCLC >= DATE()
				      SA1->A1_VENCLC :=(DATE()-1)
				   ENDIF 
				   SA1->(MSUNLOCK())
				//	lExiste := .F.
					WSConOut("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - Cliente do CNPJ " + cCnpj  + " está com cadastro BLOQUEADO. FOI DESBLOQUEADO")
				endif
			endif  
		endif
	EndIF
endif

// demais dados do cabeçalho do pedido de vendas é valido?
// Tipo de frete é válido?
if lExiste
	if (!oSC5Tmp:TIPO_FRETE $ "C#F#T#R#D#S") .or. empty(oSC5Tmp:TIPO_FRETE)
		lExiste := .F.
		cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - tipo de frete " + oSC5Tmp:TIPO_FRETE  + " é inválido..")
	endif
endif

// condição de pagamento existe e é válida?
if lExiste 
	if EMPTY(oSC5Tmp:COND_PGTO)
	   IF !_lPortal
		  lExiste := .F.
		  cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - condição de pagamento não informada.")
	   ENDIF
	else
		dbselectarea("SE4")
		dbsetorder(01)
		if !dbseek(xfilial("SE4") + padr(alltrim(oSC5Tmp:COND_PGTO),tamSx3("E4_CODIGO")[01]))
			lExiste := .F.
			cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - está com condição de pagamento inválida.")
		endif

	endif
endif

// Se informada, a tabela de preços existe?
if lExiste
	if !empty(oSC5Tmp:TABELAPRECO)
		dbselectarea("DA0")
		dbsetorder(01)
		if !dbseek(xfilial("DA0") + padr(alltrim(oSC5Tmp:TABELAPRECO),tamSx3("DA0_CODTAB")[01]))
			lExiste := .F.
			cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - está com tabela de preços inválida.")
		endif
	endif
endif

aadd(_aRet,lExiste)
aadd(_aRet,cMsg)

return(_aRet)
//============================================================================================================================
// Validações do item de vendas
Static Function WFADDITDW(oSC5Tmp,oSC6Tmp)

Local lExiste 	:= .T.
Local cMsg		:= ""
Local _aItPed	:= oSC6Tmp
Local nItens 	:= 0
Local nItem 	:= 0
Local _aRet		:= {}

nItens := Len(_aItPed)

For nItem := 1 To nItens

	if lExiste
		dbselectarea("SB1")
		dbsetorder(01)
		if dbseek(xFilial("SB1") + oSc6Tmp[nItem]:ITEMPRODUTO)
			// o produto está ativo no cadastro?
			if SB1->(FieldPos("B1_MSBLQL")) > 0
				If SB1->B1_MSBLQL == "1"
					lExiste := .F.
					cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - produto " + alltrim(oSc6Tmp[nItem]:ITEMPRODUTO)  + " está com cadastro BLOQUEADO.")
				EndIf
			endif
		endif
	endif

	if lExiste
		// a quantidade foi informada?
		if oSc6Tmp[nItem]:ITEMQTDE == 0
			lExiste := .F.
			cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - produto " + alltrim(oSc6Tmp[nItem]:ITEMPRODUTO)  + " está com quantidade zerada.")
		endif
	endif

	if lExiste
		//caso não exista tabela de preços ou o produto não esteja em uma tabela de preços, o preço unitário deve ser informado
		if empty(oSC5Tmp:TABELAPRECO)
			if oSc6Tmp[nItem]:ITEMPRCVEN == 0
				lExiste := .F.
				cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - produto " + alltrim(oSc6Tmp[nItem]:ITEMPRODUTO)  + " está sem preço.")
			endif
		else
			dbselectarea("DA1")
			dbsetorder(01)
			if !dbseek(xfilial("DA1") + padr(alltrim(oSC5Tmp:TABELAPRECO),tamSx3("DA1_CODTAB")[01])+ padr(alltrim(oSc6Tmp[nItem]:ITEMPRODUTO),tamSx3("DA1_CODPRO")[01]) )
				// se não encontrar o preço na tabela de preços, sou obrigado a ter o preço do produto
				if empty(oSC5Tmp:TABELAPRECO)
					if oSc6Tmp[nItem]:ITEMPRCVEN == 0
						lExiste := .F.
						cMsg := oemtoansi("[WS_ADD_PEDIDOS] Pedido DW " + cNumpedDW + " - produto " + alltrim(oSc6Tmp[nItem]:ITEMPRODUTO)  + " possui tabela de preços, mas não possui um preço.")
					endif
				endif
			endif
		endif
	endif
	// demais campos do item de vendas estão OK?

Next nItem

aadd(_aRet,lExiste)
aadd(_aRet,cMsg)

return(_aRet)

//===========================================================================================================================
// remove a mascara do CNPJ
Static Function UnMaskCNPJ( cCNPJ )

Local cCNPJClear := cCNPJ

BEGIN SEQUENCE

	IF Empty( cCNPJClear )

		BREAK
	EndIF

	cCNPJClear := StrTran( cCNPJClear , "." , "" )
	cCNPJClear := StrTran( cCNPJClear , "/" , "" )
	cCNPJClear := StrTran( cCNPJClear , "-" , "" )
	cCNPJClear := AllTrim( cCNPJClear )

END SEQUENCE

Return( cCNPJClear )

//===========================================================================================================================
// converte error log

Static Function xConverrLog(aAutoErro)

Local cRet := ""
Local _ni   := 1

FOR _ni := 1 to Len(aAutoErro)
	cRet += CRLF+AllTrim(aAutoErro[_ni])
NEXT _ni

RETURN cRet

//==========================================================================================================================
//Retorna data e Hora Atual Convertido em Caracter
/*
Static Function xDatAt()

Local cRet	:=	""
cRet	:=	CRLF+"("+DTOC(DATE())+" "+TIME()+")"

Return cRet*/


/*
===============================================================================================================================
Programa--------: Ver_Lib_PV(cChave)
Autor-----------: Alex Wallauer
Data da Criacao-: 09/01/2019
===============================================================================================================================
Descrição-------: Verefica se no SC9 esta tudo OK ou tenta liberar o Pedido
===============================================================================================================================
Parametros------: cChave: Filia + Pedido, 
==============================================================================================================================
Retorno---------: Lógico (.F.) Tá com erro (.T.) Tá tudo OK
===============================================================================================================================
*/
*====================================================================================================*
Static Function Ver_Lib_PV(cChave)
*====================================================================================================*
LOCAL _lOK:=.T.//Não Tem erro
LOCAL _nQtdLib:=0

SC6->( DbSetOrder(1) )//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
IF !SC6->( DBSeek( cChave ) )
	_lOK:=.F.//Tem erro
ENDIF

SC9->( DbSetOrder(1) )//
DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == cChave
	
	IF !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
		_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA ITEM DO PEDIDO
	ENDIF

	IF SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
       If SC9->C9_QTDLIB <> SC6->C6_QTDVEN  		        	 
		  _lOK:=.F.//Tem erro
		  EXIT 
       ElseIf !Empty(SC9->C9_BLEST)  	
		  _lOK:=.F.//Tem erro
		  EXIT 
	   ENDIF
	ELSE
	   _lOK:=.F.//Tem erro
	   EXIT 
	ENDIF
	SC6->( DBSkip() )
	
ENDDO

RETURN _lOK

/*
===============================================================================================================================
Programa--------: Ver_Est_PV
Autor-----------: Alex Wallauer
Data da Criacao-: 09/01/2019
===============================================================================================================================
Descrição-------: Verefica se tem estoque nos armazens indicados no parametro IT_WSPVARM
===============================================================================================================================
Parametros------: cFil,_aProdutos,_cProdutos
==============================================================================================================================
Retorno---------: RETURN _cArmA ou _cArmB ou ""
===============================================================================================================================
*/
*====================================================================================================*
Static Function Ver_Est_PV(cFil,_aProdutos,_cProdutos)
*====================================================================================================*
//LOCAL _lOKA:=.T.
//LOCAL _lOKB:=.T.
LOCAL _cQuery:=""  
Local _cAlias:= GetNextAlias()
Local _cArm  :=U_ITGETMV("IT_WSPVARM",'20;22')//'70;72'
Local _cArmA :=SUBSTR(_cArm,1,2)//'70'
Local _cArmB :=SUBSTR(_cArm,4,2)//'72'
Local nPos:=0

_cQuery += " SELECT DISTINCT B2_COD,"
_cQuery += "        NVL ((SELECT (B2_QATU - (B2_QEMP + B2_RESERVA + B2_QACLASS))"
_cQuery += "             FROM " + RetSqlName("SB2")+ " SB270"
_cQuery += "            WHERE     SB270.B2_FILIAL = SB2.B2_FILIAL"
_cQuery += "                  AND SB270.B2_COD = SB2.B2_COD"
_cQuery += "                  AND SB270.B2_LOCAL = '"+_cArmA+"' "
_cQuery += "                  AND SB270.D_E_L_E_T_ = ' '),0)  SALDO70,"
_cQuery += "       NVL ((SELECT (B2_QATU - (B2_QEMP + B2_RESERVA + B2_QACLASS))"
_cQuery += "             FROM " + RetSqlName("SB2")+ " SB272"
_cQuery += "            WHERE     SB272.B2_FILIAL = SB2.B2_FILIAL"
_cQuery += "                  AND SB272.B2_COD = SB2.B2_COD"
_cQuery += "                  AND SB272.B2_LOCAL = '"+_cArmB+"' "
_cQuery += "                  AND SB272.D_E_L_E_T_ = ' '),0)  SALDO72 "
_cQuery += "  FROM " + RetSqlName("SB2")+ " SB2 "
_cQuery += " WHERE     B2_FILIAL = '"+cFil+"' "
_cQuery += "       AND B2_COD IN "+FormatIn(_cProdutos,";")//('00020020301', '00020010301', '00010115901', '00030010601','10030000467')
_cQuery += "       AND B2_LOCAL IN " + FormatIn(ALLTRIM(_cArm),";")//('"+_cArmA+"', '"+_cArmB+"') "
_cQuery += "       AND SB2.D_E_L_E_T_ = ' ' "

//WSConOut("WS_ADD_PEDIDOS] "+_cQuery)
//_cFileNome:="\DATA\ITALAC\WS\WS_PV_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"
//MemoWrite(_cFileNome,_cQuery)

DBUSEAREA(.T., "TOPCONN", TCGenQry(,,_cQuery), _cAlias, .T., .F.)
DBSelectArea(_cAlias)

DO WHILE !EOF()
   IF (nPos:=ASCAN(_aProdutos, {|P| ALLTRIM(P[1]) == ALLTRIM((_cAlias)->B2_COD) } )) <> 0
      _aProdutos[nPos,3]:=(_cAlias)->SALDO70
      _aProdutos[nPos,4]:=(_cAlias)->SALDO72
   ENDIF
//	_cDevol := "[WS_ADD_PEDIDOS] "+(_cAlias)->B2_COD+": "+_cArmA+": "+STR( (_cAlias)->SALDO70 )+" / "+_cArmB+": "+STR( (_cAlias)->SALDO72 )
//	WSConOut(_cDevol)
   DBSKIP()
ENDDO

(_cAlias)->(dbCloseArea())

_cProdutos:=""

FOR nPos := 1 TO LEN(_aProdutos)
    IF _aProdutos[nPos,2] <= _aProdutos[nPos,3]//20,70
       _aProdutos[nPos,5]:=_cArmA
	   _cDevol := "[WS_ADD_PEDIDOS] "+_aProdutos[nPos,1]+": QTDE: "+STR( _aProdutos[nPos,2] )+" / ["+_cArmA+"]: "+STR( _aProdutos[nPos,3] )+" / "+_cArmB+": "+STR( _aProdutos[nPos,4] )
    ELSEIF _aProdutos[nPos,2] <= _aProdutos[nPos,4]//22,72
       _aProdutos[nPos,5]:=_cArmB
	   _cDevol := "[WS_ADD_PEDIDOS] "+_aProdutos[nPos,1]+": QTDE: "+STR( _aProdutos[nPos,2] )+" / "+_cArmA+": "+STR( _aProdutos[nPos,3] )+" / ["+_cArmB+"]: "+STR( _aProdutos[nPos,4] )
	ELSE
	   _cDevol := "[WS_ADD_PEDIDOS] "+_aProdutos[nPos,1]+": QTDE: "+STR( _aProdutos[nPos,2] )+" / "+_cArmA+": "+STR( _aProdutos[nPos,3] )+" / "+_cArmB+": "+STR( _aProdutos[nPos,4] )
       _cProdutos+=_aProdutos[nPos,1]+","
    ENDIF
	WSConOut(_cDevol)
NEXT

_cProdutos:=LEFT(_cProdutos,LEN(_cProdutos)-1)//ITENS SEM ARMAZEM

IF EMPTY(_cProdutos)// SE TODOS OS ITENS COM ARMAZEM
   RETURN .T.
ELSE// SE ALGUM ITEM SEM ARAMZEM
   RETURN .F.
ENDIF

*==========================================*
STATIC FUNCTION WSConOut(cMensagem)
*==========================================*
//LOCAL _cFileNome:="\DATA\ITALAC\WS\WS_PV_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"

U_ITConOut(cMensagem)

//MemoWrite(_cFileNome,cMensagem)

RETURN

/*
===============================================================================================================================
Programa----------: GravaPortal
Autor-------------: Alex Wallauer
Data da Criacao---: 03/04/2020
===============================================================================================================================
Descrição---------: Processamento de Importação de DADOS DO Sistema Blokers/Italac
===============================================================================================================================
Parametros--------: aCab,aItens
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function GravaPortal(aCab,aItens,_cFilAux)
LOCAL _nCpo
LOCAL cFili  :=_cFilAux//aCab[ASCAN(aCab,{|C| C[1] == "C5_FILIAL"  } ) , 2  ]
LOCAL cVend  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_VEND1"   } ) , 2  ]
LOCAL cPVDW  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_PEDDW" } ) , 2  ]
LOCAL cTaPr  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_TAB"  } ) , 2  ]
LOCAL cClie  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_CLIENTE" } ) , 2  ]
LOCAL cLoja  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_LOJACLI" } ) , 2  ]
LOCAL cCond  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_CONDPAG" } ) , 2  ]
LOCAL cOper  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_OPER"  } ) , 2  ]
LOCAL cMenNf :=aCab[ASCAN(aCab,{|C| C[1] == "C5_MENNOTA" } ) , 2  ]//<MENS_NOTA>
LOCAL cHora  :=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_HOREN" } ) , 2  ]//<HORAENTREGA>
LOCAL nQtdCha:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_CHAPA" } ) , 2  ]//<CHAPA>
LOCAL nCusDes:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_CUSDE" } ) , 2  ]//<CUSTOENTREGA>
LOCAL cSenha :=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_SENHA" } ) , 2  ]//<SENHA>
LOCAL cObs   :=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_OBPED" } ) , 2  ]//<MENS_PEDIDO>
LOCAL cFilPRO:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_FLFNC" } ) , 2  ]//FILIAL DE PRODUCAO/CARREGAMENTO
LOCAL cTpVevd:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_TPVEN" } ) , 2  ]//Tipo de Venda
LOCAL cTpCarg:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_TIPCA" } ) , 2  ]//Tipo de Carga
LOCAL cTpAgen:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_AGEND" } ) , 2  ]//Tipo de Agendamento
LOCAL dDtEmis:=aCab[ASCAN(aCab,{|C| C[1] == "C5_EMISSAO" } ) , 2  ]//Data de Emissao
LOCAL cEvento:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_EVENT" } ) , 2  ]//Evento
LOCAL cCliRem:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_CLIEN" } ) , 2  ]//Cliente Remessa 
LOCAL cLojRem:=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_LOJEN" } ) , 2  ]//Loja Cliente Remessa 
LOCAL cTpfret:=aCab[ASCAN(aCab,{|C| C[1] == "C5_TPFRETE" } ) , 2  ]//Tipo do frete
Local _cRecSabad :=aCab[ASCAN(aCab,{|C| C[1] == "C5_I_RECSA" } ) , 2  ]// Cliente Recebe aos Sabados

LOCAL _cCodSWZ:=GeraZWIDPED(cVend)
LOCAL _nPerLMagro:=0
LOCAL nQtdeM:=0
LOCAL nQtdeI:=0
LOCAL cFx := ""
Local _cKitPortal := ""

IF !EMPTY(cObs)
//    cObs:=cObs+" "+"Pedido Importado WS: "+cPVDW
ELSE
    cObs:="Pedido Importado WS: "+cPVDW
ENDIF

IF EMPTY(cFilPRO) .OR. ALLTRIM(cFilPRO) == "0" .OR. ALLTRIM(cFilPRO) == 'ZZ'
   cFilPRO:=cFili
ENDIF

IF EMPTY(cTpAgen)
   cTpAgen:="I"
ENDIF

ConOut("Data de Emissao: "+AllToChar(dDtEmis)+" / VALTYPE(dDtEmis) = "+VALTYPE(dDtEmis))

SB1->(DBSETORDER(1))
FOR _nCpo := 1 TO LEN(aItens)
	_aDados:=aItens[_nCpo]
    cProd:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_PRODUTO" } ) , 2  ]
    nQtde:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_QTDVEN"  } ) , 2  ]
	SB1->(DBSEEK(xFilial()+LEFT(cProd,11)))
    IF SB1->B1_I_TIPLT = "M"
	   nQtdeM+=nQtde
    ELSEIF SB1->B1_I_TIPLT = "I"
       nQtdeI+=nQtde
    ENDIF
 //   WSConOut("[WS_ADD_PEDIDOS] Produto.: "+cProd+", B1_I_TIPLT : "+SB1->B1_I_TIPLT + ", QTDE: "+AllToChar(nQtde))
NEXT   	
IF nQtdeM <> 0 //.AND. nQtdeI <> 0
   _nPerLMagro:=((nQtdeM / (nQtdeM+nQtdeI))*100)
   WSConOut("[WS_ADD_PEDIDOS] (nQtdeM ["+AllToChar(nQtdeM)+"]  / ( ["+AllToChar(nQtdeM)+"] + nQtdeI ["+AllToChar(nQtdeI)+"] ))*100 = _nPerLMagro ["+AllToChar(_nPerLMagro)+"]  ")
ENDIF

DA1->(DBSETORDER(1))
SA1->(DBSETORDER(1))
SA1->(DBSEEK(xFilial()+cClie+cLoja ))

IF EMPTY(cCond)
   cCond:=SA1->A1_COND
ENDIF
_cTimeStamp:=FWTimeStamp( 4, DATE(), TIME() )
_nItem:=0
FOR  _nCpo := 1 TO LEN(aItens)
	//CAPA
	SZW->(Reclock("SZW",.T.))
	SZW->ZW_FILIAL := cFili
	SZW->ZW_CODEMP := "010"
	SZW->ZW_IDPED  := _cCodSWZ//SUBSTR(cVend,3,4)+"-"+_cCodSWZ//cPVDW
	SZW->ZW_EMISSAO:= IF(VALTYPE(dDtEmis)="D" .AND. !EMPTY(dDtEmis),dDtEmis,DATE())
	SZW->ZW_TIMEEMI:= _cTimeStamp
	SZW->ZW_IDUSER := cVend
	SZW->ZW_VEND1  := cVend
	SZW->ZW_TABELA := cTaPr
	SZW->ZW_STATUS := "A"
	SZW->ZW_CLIENTE:= SA1->A1_COD
	SZW->ZW_LOJACLI:= SA1->A1_LOJA
	SZW->ZW_CLIENT := SZW->ZW_CLIENTE
	SZW->ZW_LOJAENT:= SZW->ZW_LOJACLI
	SZW->ZW_CONDPAG:= cCond
	SZW->ZW_TPFRETE:= cTpfret//"C"
	SZW->ZW_TIPO   := cOper//"01"
	SZW->ZW_TIPOCLI:= SA1->A1_TIPO//"R"
	SZW->ZW_TIPCAR := IF(ALLTRIM(cTpCarg)="1","1","2") //"2"//"1 - Paletizada" , "2 - Batida"
	SZW->ZW_MENNOTA:= cMenNf //<MENS_NOTA>
	SZW->ZW_HOREN  := cHora  //<HORAENTREGA>
	SZW->ZW_CHAPA  := nQtdCha//<CHAPA>
	SZW->ZW_CUSDES := nCusDes//<CUSTOENTREGA>
	SZW->ZW_SENHA  := cSenha //<SENHA>
	SZW->ZW_PEDIMPO:= cPVDW
	SZW->ZW_I_PEDDW:= cPVDW
	SZW->ZW_I_LMAGR:= _nPerLMagro 
    SZW->ZW_FILPRO := LEFT(cFilPRO,2)
	SZW->ZW_CLIREM := cCliRem
    SZW->ZW_LOJEN   := cLojRem

	If Empty(_cRecSabad) 
	   SZW->ZW_I_RECSA := "N"
	Else 
	   SZW->ZW_I_RECSA := _cRecSabad
	EndIf 

	//ITENS
	_aDados:=aItens[_nCpo]
    cProd:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_PRODUTO" } ) , 2  ]
    nQtde:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_QTDVEN"  } ) , 2  ]
    nQSeg:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_UNSVEN"  } ) , 2  ]
    nPrec:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_PRCVEN"  } ) , 2  ]
	nPrUN:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_PRUNIT"  } ) , 2  ]
//	cLoca:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_LOCAL"   } ) , 2  ]
	cItDW:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_I_ITDW"  } ) , 2  ]
	cPdCl:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_NUMPCOM" } ) , 2  ]//<ORDEM_COMPRA>
	dDEnt:=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_ENTREG"  } ) , 2  ]
	cFx         :=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_I_FXPES" } ) , 2  ]
	_cKitPortal :=_aDados[ASCAN(_aDados,{|C| C[1] == "C6_I_KIT" } ) , 2  ] 

	IF EMPTY(cFx)
	   cFx:="1"
	ENDIF 

    WSConOut("DATA DE ENTREGA: "+AllToChar(dDEnt))

	_nItem++
	SZW->ZW_PRODUTO:= LEFT(cProd,11)
	SB1->(DBSEEK(xFilial()+SZW->ZW_PRODUTO))
	DA1->(Dbseek(xFilial("DA1")+SZW->ZW_TABELA+SZW->ZW_PRODUTO))
	SZW->ZW_ITEM   := ALLTRIM(STR( _nItem , LEN(SZW->ZW_ITEM) ))
	SZW->ZW_UM     := SB1->B1_UM
	SZW->ZW_QTDVEN := nQtde
	SZW->ZW_PRCVEN := nPrec
	SZW->ZW_PRUNIT := nPrUN
	SZW->ZW_OBSCOM := cObs//<MENS_PEDIDO>
	SZW->ZW_HORAINC:= TIME()
	SZW->ZW_2UM    := SB1->B1_SEGUM
	SZW->ZW_I_PRNET:= SZW->ZW_PRCVEN
	SZW->ZW_I_AGEND:= cTpAgen//"I"
	SZW->ZW_PEDCLI := cPdCl//"NT"//<ORDEM_COMPRA>	
//  IF SZW->ZW_TIPO  = "01"
    IF UPPER(cTpVevd)  = "F"
	   SZW->ZW_TPVENDA := 'V'
	   SZW->ZW_I_PRMP := DA1->DA1_I_PMFR
	ELSE
	   SZW->ZW_TPVENDA := 'F'
	   SZW->ZW_I_PRMP := DA1->DA1_I_PMFE
	ENDIF
//  SZW->ZW_LOCAL  := cLoca
	IF SZW->(FIELDPOS( "ZW_I_ITDW" )) <>  0
	   SZW->ZW_I_ITDW:=cItDW
	ENDIF

//	IF cFilPRO = "90I"
//       SZW->ZW_LOCAL  := "36"
//	ELSE
//	   cArm:= POSICIONE("SBZ",1,SZW->ZW_FILPRO+SZW->ZW_PRODUTO,"BZ_LOCPAD")
//	   IF cArm $ "20/36"
//	      SZW->ZW_LOCAL  := "20"
//       ELSE
//	      SZW->ZW_LOCAL  := "22"
//	   ENDIF
//	ENDIF

   //======================================
   // Nova regra para obter o Armazém.  
   //======================================
   cArm:= POSICIONE("SBZ",1,SZW->ZW_FILPRO+SZW->ZW_PRODUTO,"BZ_LOCPAD") 
   SZW->ZW_LOCAL  := cArm
   //--------------------------------------

    IF SB1->B1_CONV > 0
       IF SB1->B1_TIPCONV = 'D'
          SZW->ZW_SEGQTD:=(SZW->ZW_QTDVEN/SB1->B1_CONV)
       ELSE
          SZW->ZW_SEGQTD:=(SZW->ZW_QTDVEN*SB1->B1_CONV)
       ENDIF
    ELSE
   	   SZW->ZW_SEGQTD:=nQSeg
   	ENDIF
	IF cTpAgen == "I"
	   IF !ZG5->(DBSEEK(xFilial()+SZW->ZW_FILPRO+SA1->A1_EST+SA1->A1_COD_MUN ))
	      IF !ZG5->(DBSEEK(xFilial()+SZW->ZW_FILPRO+SA1->A1_EST))
	         SZW->ZW_FECENT := (DATE()+1)
	      ELSE   
	         SZW->ZW_FECENT := DATE()+ZG5->ZG5_DIAS+1
	      ENDIF   
	   ELSE   
	      SZW->ZW_FECENT := DATE()+ZG5->ZG5_DIAS+1
	   ENDIF
	ELSE   
	   SZW->ZW_FECENT :=dDEnt
	ENDIF

/*
	IF cFilPRO = "90I" //TEMPORARIO ATE ARUMAR COMECAR A VIR OPERACAO 25
	   SZW->ZW_TIPO   := '25'
	   SZW->ZW_TABELA := "120"
	ENDIF
*/

	SZW->ZW_I_FXPES := VAL(cFx)   //Faixa de Peso da tabela de preço
	SZW->ZW_EVENTO  := cEvento
    SZW->ZW_KIT     := _cKitPortal 
	SZW->(Msunlock())

NEXT

RETURN SZW->ZW_IDPED


/*
===============================================================================================================================
Programa----------: GeraZWIDPED()
Autor-------------: Alex Wallauer
Data da Criacao---: 06/01/2020
===============================================================================================================================
Descrição---------: Gera oproximo ZW_IDPED
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function GeraZWIDPED(_cCodVen)
Local _cAlias:= GetNextAlias()

_cQuery:=" SELECT  NVL(MAX(ZW_IDPED),'0') AS CODIGO FROM "+ RetSqlName('SZW') +" SZW WHERE ZW_VEND1 = '"+_cCodVen+"' "

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )

(_cAlias)->( DBGoTop() )
If (_cAlias)->(!Eof()) .AND. (_cAlias)->CODIGO <> '0'
    nAt:=AT("-",(_cAlias)->CODIGO)
	_cRet := LEFT( (_cAlias)->CODIGO,nAt )
	_cRet := _cRet + Soma1( ALLTRIM(SUBSTR( (_cAlias)->CODIGO,nAt+1)) )
Else
	_cRet := ALLTRIM(STR(VAL(_cCodVen)))+"-00001"
EndIf

IF EMPTY(_cRet)//Para garantir não devolver branco
   _cRet := ALLTRIM(STR(VAL(_cCodVen)))+"-00001"
ENDIF

(_cAlias)->(DbCloseArea())
DbSelectArea("SZW")

Return _cRet

/*
===============================================================================================================================
Programa----------: DefTPPedVd
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/06/2021
===============================================================================================================================
Descrição---------: Define o tipo de pedido de vendas com base nas regras das tabelas de preços (F= Venda Fracionada, 
                    C=Venda Fechada).
===============================================================================================================================
Parametros--------: _aItensPv - Itens do pedido de vendas.
                    _cOperacao - Código da Operação.
					_cTpPvPortal - Tipo de pedido de vendas portal.
					_cTabPrcPortal - Código da tabela de Preços do Portal
===============================================================================================================================
Retorno-----------: _cTipoPV  - Tipo de pedido de vendas.
===============================================================================================================================
*/
Static Function DefTPPedVd(_aItensPv, _cOperacao, _cTpPvPortal, _cTabPrcPortal, _cFilialPV)
Local _cTipoPV := _cTpPvPortal
Local _nPosProd, _nPosQtd
Local _nI, _nPesTot

Begin Sequence 
   If AllTrim(_cOperacao) == "24"
      If Empty(_cFilialPV) .Or. Empty(_cTabPrcPortal)
         Break 
	  EndIf 

      DA0->(DbSetOrder(1))
	  SB1->(DbSetOrder(1))

      _nPosProd := AsCan(_aItensPv[1], {|x| x[1] == "C6_PRODUTO" } )
      _nPosQtd  := AsCan(_aItensPv[1], {|x| x[1] == "C6_QTDVEN"  } )
      _nPesTot  := 0

	  If DA0->(MsSeek(xfilial("DA0")+_cTabPrcPortal))
	     For _nI := 1 To Len(_aItensPv)
		     SB1->(MsSeek(xFilial("SB1")+_aItensPv[_nI,_nPosProd,2]))
             _nPesTot += (_aItensPv[_nI,_nPosQtd,2] * SB1->B1_PESBRU )
         Next 
	     		 
         If _nPesTot < DA0->DA0_I_PES1
            _cTipoPV := "F"  
		 Else 
		    _cTipoPV := "C" 
		 EndIf 

	  EndIf
   EndIf

End Sequence

Return _cTipoPV

