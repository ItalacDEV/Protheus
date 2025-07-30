/*
======================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
======================================================================================================================================
     Autor     |    Data    |                                             Motivo
--------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 29/12/2016 | Ajustes da Unificação - Pre-Carga - Chamado 18245
 Julio Paz     | 23/01/2017 | Inclusão da rotina de integração de cancelamento de carga Italac x RDC via Webservice. Chamado: 16681.
 Lucas Borges  | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
 Alex Wallauer | 01/02/2021 | Remoção de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
======================================================================================================================================

==================================================================================================================================================================================================================
Analista        - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==================================================================================================================================================================================================================
Vanderlei Alves - Igor Melgaço  - 10/01/24 - 26/06/25 -  49552 - Ajustes para nova regra de cancelamento de carga no TMS Multiembarcador
==================================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
===============================================================================================================================
Programa----------: OMSA200P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/09/2015
Descrição---------: Ponto de entrada que valida o estorno de montagem de carga - Chamado 12082
Parametros--------: Nenhum
Retorno-----------: .T. - Permite seleção .F. - Não permite a seleção
===============================================================================================================================
*/
User Function OMSA200P()

 Local _aArea	:=GetArea()            //Salva area geral
 Local _lRet		:= .T.
 Local _cmens	:= ""
 Local _aret		:= {}
 Local _cCodUsr	:= ALLTRIM(RetCodUsr())
 
 If Type("_lAutomatico") == "U"
    Private _lAutomatico := .F.
 EndIf
 
 If _lAutomatico
    _lUsuConfirmou := .T.
 EndIf
 
 //Posiciona carga
 dbselectarea("DAI")
 DAI->( dbsetorder(1) )
 
 If DAI->( dbseek( xfilial("DAI")+ alltrim(paramixb[1])+ alltrim(paramixb[2])))
 
     If POSICIONE("SC5",1,xFilial("SC5") + alltrim(DAI->DAI_PEDIDO),"SC5->C5_TIPO") == 'N'
 
         DbSelectArea("SC6")
         DbSetOrder(1)
 
         If DbSeek(xFilial("SC6")+alltrim(DAI->DAI_PEDIDO))
 
             Do while alltrim(DAI->DAI_PEDIDO) == alltrim(SC6->C6_NUM)
 
                 //============================================
                 //Valida armazémxprodutoxfilialxusuário
                 //============================================
                 _aRet := U_ACFG004E(_cCodUsr, alltrim(xFilial("SC6")), alltrim(SC6->C6_LOCAL),alltrim(SC6->C6_PRODUTO), .F.)
 
                 //se ainda está valido verifica se não teve erro
                 If _lRet
 
                       _lRet:= _aRet[1]
 
                 Endif
 
                 // adiciona armazens com problema se ainda não estiver na mensagem
                 if empty(_cmens)
 
                     _cmens += _aRet[2]
 
                 elseif !(_aRet[2]$_cmens) .and. !(Empty(_aRet[2]))
 
                     _cmens += ", " + _aRet[2]
 
                 Endif
 
 
                 SC6->( Dbskip() )
 
             Enddo
 
             //============================================
             //Mostra lista de armazéns com problema
             //============================================
             If !(_lRet)
                If ! _lAutomatico
                   MessageBox( 'Usuário sem acesso ao(s) armazém(éns) abaixo nessa filial: ' + CRLF + _cmens + CRLF + CRLF+;
                               'Caso necessário solicite a manutenção à um usuário com acesso ou, se necessário, solicite o acesso à área de TI/ERP.' , 'Atenção! (OMSA200P)' , 48 )
                Else
                   _cMsgEstorno := 'Usuário sem acesso ao(s) armazém(éns) abaixo nessa filial: ' + _cmens
 
                EndIf
             Endif
 
         Endif
 
     Endif
 
 Else
 
     If ! _lAutomatico
        //Se não localizaou o registro na DAI existe problema na base de dados
        MessageBox( 'Problema ao localizar dados da carga!'+CRLF+;
                    'Solicite suporte à área de TI/ERP.' , 'Atenção! (OMSA200P)' , 48 )
     Else
        _cMsgEstorno := 'Problema ao localizar dados da carga! '
     EndIf
 
     _lRet:= .F.
 
 Endif
 // O Envio do e-mail foi para dentro da funcao U_OM20MNUE no ponto de entrada OM200MNU.prw ==> U_OM200Email(.T.,_aPVs_DAI)//AWF - 14/07/2016
 
 IF _lRet
    If ! _lAutomatico
       Processa( {|| _lRet:=OMS200DelPV() } )
    Else
       _lRet := OMS200DelPV()
    EndIf
 EndIf
 
 If _lRet .AND. DAK->DAK_I_TMS == 'M' .AND. DAK->DAK_ACECAR == "2" .AND. DAK->DAK_ACEFIN == "2"
    _lRet := U_ITMa521Mbrow("DAK")
 EndIf

 Restarea(_aArea) //-- Restaura a posição da tabela corrente

 If _lRet .And. _lAutomatico
    Os200ProcEst(DAK->DAK_COD)
    _lRet := .F.
 EndIf
 
 Restarea(_aArea) //-- Restaura a posição da tabela corrente

Return IF(_lret,NIL,.F.)//nao pode retornar um valor logico se for .T. pq ele mata a validacao padrao se for .F.

/*
===============================================================================================================================
Programa--------: OMS200DelPV()
Autor-----------: Alex Wallauer
Data da Criacao-: 11/08/2016
Descrição-------: Apaga os pedidos de pallet gerados na montagem de carga
Retorno---------: Lógico (.T.) Se apagou / (.F.) Se nao apagou
===============================================================================================================================
*/
STATIC FUNCTION OMS200DelPV(_lOMSA200P As Logical) As Logical

LOCAL _aPeds_Pallet := {} As Array
LOCAL _cPVs := "" As Char
LOCAL C As Numeric
LOCAL _lOK := .T. As Logical

SC5->(DBSetOrder(1))

If ! _lAutomatico
   ProcRegua(LEN(_aPVs_DAI))
EndIf

_aFatPedCarga:={}//private do rdmake OM200MNU.PRW

FOR C := 1 TO LEN(_aPVs_DAI)
    DAI->( DBGOTO( _aPVs_DAI[C,3] ))

    If ! _lAutomatico
       IncProc("Lendo Pedido: "+DAI->DAI_PEDIDO)
    EndIf

    IF !SC5->( DbSeek( xFilial("SC5") + _aPVs_DAI[C,1] ) )
       LOOP
    ENDIF
    If !EMPTY(DAI->DAI_I_QTPA)//DAI->DAI_I_TIPC $ "1,3,4" .AND. - AWF 29/12/2016 - Retirei o tipo pq se entrar novos tipos não precisa alterar mais aqui
       IF EMPTY(SC5->C5_I_PDFT)//Se tiver preenchido é pq já gerou a Nota do pedido de carregamento e esta tentando estornar a carga do fatura/mento dai nao entra aqui
          IF SC5->C5_I_PEDPA = 'S' .AND. SC5->C5_I_PEDGE # 'S' .AND. !EMPTY(SC5->C5_I_NPALE)//Se é Pedido de Pallet (Tem Dupla) e se não é o Pedido gerador de Pallet que esta na carga
                      //Recno do Pedido de Pallet , Pedido que gerou o Pallet ,DAI  ,Pedido de Pallet
             AADD(_aPeds_Pallet, { SC5->(RECNO()) , SC5->C5_I_NPALE , DAI->(RECNO()) , _aPVs_DAI[C,1] })
          ENDIF
       ENDIF
    ENDIF
    IF !EMPTY(SC5->C5_I_PDFT)//Quando esta estornando a carga gerada automatica na filial de faturamento
       AADD(_aFatPedCarga,{SC5->(RECNO()),SC5->C5_I_FLFNC+SC5->C5_I_PDPR,"",SC5->C5_I_CARGA})//Guarda o Pedido da Carga Gerada para voltar o antigo
    ENDIF
NEXT

//BEGIN Transaction // foi para a chamada do programa no rdmake OM200MNU.PRW

   _lOK:=.T.
   _cPVs:=""
   If ! _lAutomatico
      ProcRegua(LEN(_aPeds_Pallet))
   EndIf

   FOR C := 1 TO LEN(_aPeds_Pallet)

       IF !OMS200Apaga(_aPeds_Pallet[C,1],_aPeds_Pallet[C,2],_aPeds_Pallet[C,3])
          SC5->( DBGOTO( _aPeds_Pallet[C,1] ))
          _cPVs+=SC5->C5_NUM+", "
          _lOK:=.F.
       ENDIF

   NEXT

   IF !_lOK

      DisarmTransaction()
      _lUsuConfirmou:=.F.//Variavel PRIVATE usada no rdmake OM200MNU.PRW para saber se o usuario confirmou o estorno
      _cPVs:=LEFT(_cPVs,LEN(_cPVs)-2)

      If ! _lAutomatico
         MessageBox( "Nao foi possivel excluir o(s) Pedido(s) de Pallet: "+_cPVs+CRLF+;
                     "Verifique o(s) Pedido(s) de Pallet conforme Mensage(ns) de erro(s) apresentada(s)"+CRLF+;
                     "Depois tente estornar essa Carga novamente." , 'Atenção! (OMSA200P)' , 48 )
      Else
         _cMsgEstorno := "Nao foi possivel excluir o(s) Pedido(s) de Pallet: "+_cPVs+"."+;
                         " Verifique o(s) Pedido(s) de Pallet conforme Mensage(ns) de erro(s) apresentada(s),"+;
                         " depois tente estornar essa Carga novamente."
      EndIf
   ENDIF

//END Transaction // foi para a chamada do programa no rdmake OM200MNU.PRW

RETURN _lOK

/*
===============================================================================================================================
Programa--------: OMS200Apaga(_nRecPedPallet,_cPedGerou,_nRecDAI)
Autor-----------: Alex Wallauer
Data da Criacao-: 11/08/2016
Descrição-------: _nRecPedPallet: Recno do Pedido de Pallet
                  _cPedGerou: Pedido que gerou o Pallet
                  _nRecDAI: recno do DAI
Retorno---------: Lógico (.T.) Se apagou / (.F.) Se nao apagou
===============================================================================================================================
*/
STATIC FUNCTION OMS200Apaga(_nRecPedPallet As Numeric, _cPedGerou As Char, _nRecDAI As Numeric) As Logical

LOCAL _aCabPV  := {} As Array
LOCAL _aItemPV := {} As Array
LOCAL _aItensPV:= {} As Array
Local _cPedidoP As Char

IF _nRecPedPallet # 0
   SC5->( DBGOTO( _nRecPedPallet ))
ELSE
   RETURN .F.
ENDIF

If ! _lAutomatico
   IncProc("Lendo Pedido: "+SC5->C5_NUM)
EndIf

//====================================================================================================
// Limpa a carga do DAI para nao dar mensagem de erro customizada no estorno da liberacao
DAI->( DBGOTO( _nRecDAI ))
DAI->(RECLOCK("DAI",.F.))
DAI->(DBDELETE())
DAI->(MSUNLOCK())
//====================================================================================================

//====================================================================================================
// Limpa a carga do SC9 para nao dar mensagem de erro padrao no estorno do Pedido de Pallet
SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
DO While SC9->( !EOF() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == SC5->C5_FILIAL + SC5->C5_NUM

   SC9->( RecLock('SC9',.F.) )
   SC9->C9_CARGA:=""
   SC9->C9_SEQCAR:=""
   SC9->C9_SEQENT:=""
   SC9->( MsUnlock() )
   SC9->( DBSkip() )

ENDDO
//====================================================================================================

_aCabPV  :={}
_aItemPV :={}
_aItensPV:={}
_dDtEnt	 := IF(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT)//Para nao travar a alteracao do Pedido de Pallet

//====================================================================================================
// Monta o cabeçalho do pedido
Aadd( _aCabPV, { "C5_FILIAL"	,SC5->C5_FILIAL  , Nil})//filial
Aadd( _aCabPV, { "C5_NUM"    	,SC5->C5_NUM	 , Nil})
Aadd( _aCabPV, { "C5_TIPO"	    ,SC5->C5_TIPO    , Nil})//Tipo de pedido
Aadd( _aCabPV, { "C5_I_OPER"	,SC5->C5_I_OPER  , Nil})//Tipo da operacao
Aadd( _aCabPV, { "C5_CLIENTE"	,SC5->C5_CLIENTE , NiL})//Codigo do cliente
Aadd( _aCabPV, { "C5_CLIENT" 	,SC5->C5_CLIENT	 , Nil})
Aadd( _aCabPV, { "C5_LOJAENT"	,SC5->C5_LOJAENT , NiL})//Loja para entrada
Aadd( _aCabPV, { "C5_LOJACLI"	,SC5->C5_LOJACLI , NiL})//Loja do cliente
Aadd( _aCabPV, { "C5_EMISSAO"	,SC5->C5_EMISSAO , NiL})//Data de emissao
Aadd( _aCabPV, { "C5_TRANSP" 	,SC5->C5_TRANSP	 , Nil})
Aadd( _aCabPV, { "C5_CONDPAG"	,SC5->C5_CONDPAG , NiL})//Codigo da condicao de pagamanto*
Aadd( _aCabPV, { "C5_VEND1"  	,SC5->C5_VEND1	 , Nil})
Aadd( _aCabPV, { "C5_MOEDA"	    ,SC5->C5_MOEDA   , Nil})//Moeda
Aadd( _aCabPV, { "C5_MENPAD" 	,SC5->C5_MENPAD	 , Nil})
Aadd( _aCabPV, { "C5_LIBEROK"	,SC5->C5_LIBEROK , NiL})//Liberacao Total
Aadd( _aCabPV, { "C5_TIPLIB"  	,SC5->C5_TIPLIB  , Nil})//Tipo de Liberacao
Aadd( _aCabPV, { "C5_TIPOCLI"	,SC5->C5_TIPOCLI , NiL})//Tipo do Cliente
Aadd( _aCabPV, { "C5_I_NPALE"	,SC5->C5_I_NPALE , NiL})//Numero que originou a pedido de palete
Aadd( _aCabPV, { "C5_I_PEDPA"	,SC5->C5_I_PEDPA , NiL})//Pedido Refere a um pedido de Pallet
Aadd( _aCabPV, { "C5_I_DTENT"	,_dDtEnt         , Nil})//Dt de Entrega foi alterado para data do dia
Aadd( _aCabPV, { "C5_I_TRCNF"   ,SC5->C5_I_TRCNF , Nil})
Aadd( _aCabPV, { "C5_I_BLPRC"   ,SC5->C5_I_BLPRC , Nil})
Aadd( _aCabPV, { "C5_I_FILFT"   ,SC5->C5_I_FILFT , Nil})
Aadd( _aCabPV, { "C5_I_FLFNC"   ,SC5->C5_I_FLFNC , Nil})
//====================================================================================================

//====================================================================================================
// Monta o item do pedido
SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

    _aItemPV:={}

    AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
    AAdd( _aItemPV , { "C6_NUM"    	,SC6->C6_NUM	 , Nil })
    AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
    AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
    AAdd( _aItemPV , { "C6_QTDVEN"  ,SC6->C6_QTDVEN  , Nil }) // Quantidade Vendida
    AAdd( _aItemPV , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
    AAdd( _aItemPV , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
    AAdd( _aItemPV , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
    AAdd( _aItemPV , { "C6_LOJA"   	,SC6->C6_LOJA	 , Nil })
    AAdd( _aItemPV , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
    AAdd( _aItemPV , { "C6_VALOR"   ,SC6->C6_VALOR   , Nil }) // valor total do item
    AAdd( _aItemPV , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
    AAdd( _aItemPV , { "C6_TES"    	,SC6->C6_TES	 , Nil })
    AAdd( _aItemPV , { "C6_LOCAL"   ,SC6->C6_LOCAL   , Nil }) // Almoxarifado
    AAdd( _aItemPV , { "C6_CF"     	,SC6->C6_CF		 , Nil })
    AAdd( _aItemPV , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
    AAdd( _aItemPV , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
    AAdd( _aItemPV , { "C6_PEDCLI" 	,SC6->C6_PEDCLI	 , Nil })
    AAdd( _aItemPV , { "C6_I_BLPRC"	,SC6->C6_I_BLPRC , Nil })

    AAdd( _aItensPV ,_aItemPV )

    SC6->( DBSkip() )

ENDDO
//====================================================================================================

//====================================================================================================
// Alteração do pedido de Pallet para consegui estornar
lMsErroAuto:=.F.

MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 4 )

lErroSC9:=.F.
SC9->( DbSetOrder(1) )

_cPedidoP := AllTrim(SC5->C5_NUM)

If lMsErroAuto .OR. ( lErroSC9:=SC9->( DBSeek( SC5->C5_FILIAL+SC5->C5_NUM ) ))//Se liberou o estoque nao pode achar no SC9, portanto se char é um erro

    IF lErroSC9
        If ! _lAutomatico
           MessageBox("Erro ao Estornar a liberação do pedido de Pallet, ainda tem dados de liberacao (SC9)." , 'Atenção! (OMSA200P)' , 48 )
        Else
           _cMsgEstorno := "Erro ao Estornar a liberação do pedido de Pallet, ainda tem dados de liberacao (SC9)."
        EndIf
    ELSE
       If ! _lAutomatico
          MostraErro()
       Else
          _cMsgEstorno := MostraErro("\system\", "Estorno_Pedido_Pallet_"+_cPedidoP+"_"+DToc(Date())+"_"+Time()+".log")
       EndIf
    ENDIF

    RETURN .F.

ENDIF
//====================================================================================================

//====================================================================================================
// Estorno do pedido de Pallet
MSEXECAUTO({|x,y,z| MATA410(x,y,z)}, _aCabPV , _aItensPV ,5)

IF lMSERROAUTO
   If ! _lAutomatico
      MOSTRAERRO()
   Else
      _cMsgEstorno := MostraErro("\system\", "Estorno_Pedido_Pallet_"+_cPedidoP+"_"+DToc(Date())+"_"+Time()+".log")
   EndIf

   RETURN .F.

ELSE

   // LIMPA O NUMERO DO PEDIDO DE PALLET do Pedido que gerou o Pedido de Pallet
   SC5->(DBSetOrder(1))
   IF SC5->( DbSeek( xFilial("SC5") + _cPedGerou ) )//Pedido que gerou o Pallet
      SC5->(RECLOCK("SC5",.F.))
      SC5->C5_I_NPALE := ""
      SC5->C5_I_PEDPA := ""
      SC5->C5_I_PEDGE := ""
      SC5->(MSUNLOCK())
   ENDIF

ENDIF
//====================================================================================================

RETURN .T.
