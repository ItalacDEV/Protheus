/* 
================================================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
================================================================================================================================================
       Autor   |    Data    |                                             Motivo                                           
================================================================================================================================================
 Lucas Borges  | 11/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
 Alex Wallauer | 31/10/2019 | Chamado 31025. PC criado no processo de troca NF deverá ter o preço unitário ajustado pela tab. de transferência.
 Lucas Borges  | 03/08/2020 | Chamado 33714. Ajustado bloqueio para faturamento com data retroativa.
 Julio Paz     | 16/09/2020 | Chamado 34159. Correções nas formações de nomes dos campos para a tabela temporária TRBPED. 
 Jerry         | 18/11/2020 | Chamado 34742. Ajuste na tratativa de Log de Inclusão de PV.
 Alex Wallauer | 12/04/2021 | Chamado 36078. Alterações nas validacoes de Estoque para funcao U_ITVLDEST().
 Alex Wallauer | 20/01/2022 | Chamado 38985. Correção de texto de mensagens escrito errado.
 Jerry         | 31/08/2022 | Chamado 41118. Correção da gravação campo C6_CLASCLI quando Oper. 20.
 Jerry         | 27/09/2022 | Chamado 41337. Alteração na gravação campo C6_CLASCLI quando Oper. 20.
 Alex Wallauer | 08/12/2022 | Chamado 41604. Novo tratamento para Pedidos de Operacao Triangular.
 Igor Melgaco  | 14/12/2022 | Chamado 41604. Correção de error.log.
 Alex Wallauer | 16/01/2024 | Chamado 46079. Gravacao dos campos novos do DAK: DAK_I_TRNF/DAK_I_FITN/DAK_I_INCC/DAK_I_INCF.
 Alex Wallauer | 28/03/2024 | Chamado 46905. Andre. Corrrecao de error.log de campo não existe SC9_FILIAL / SC9_PEDIDO.
 Julio Paz     | 11/04/2024 | Chamado 46905. Andre. Alterar as validações do itens de pedidos de vendas com rastreabilidade e controle de lotes.
 Alex Wallauer | 15/07/2024 | Chamado 47853. Jerry. Corrrecao error.log argument #1 error, expected L->C,GetMv on _GETMVCACHED(SUPERGETMV.PRW).
==================================================================================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração 
==================================================================================================================================================================================================================
Bremmer  - Alex Wallauer - 10/10/24 - 05/11/24 -  48795  - Tratamento para o novo parâmetro IT_NAGEND: TP Entrega = C5_I_AGEND $ P=Aguardando Agenda; R=Reagendar; N=Reagendar com Multa.
Bremmer  - Alex Wallauer - 08/11/24 - 08/11/24 -  49080  - Ajustes do Tratamento do parâmetro IT_NAGEND: TP Entrega = C5_I_AGEND $ P=Aguardando Agenda; R=Reagendar; N=Reagendar com Multa
Jerry    - Alex Wallauer - 14/01/25 - 20/03/25 -  48849  - Nova validacao para as TES dos itens de pedidos de vendas Triangular - Procure #VALIDAR.
==================================================================================================================================================================================================================
*/
 
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "rwmake.ch"
#include "TOTVS.CH"

STATIC _aStaC9Locais:={}

/*
===============================================================================================================================
Programa--------: M460MARK
Autor-----------: Fabiano Dias
Data da Criacao-: 30/06/2010
Descrição-------: P.E. na confirmação da tela de pedidos de vendas a serem faturados
Parametros------: Nenhum
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/
User Function M460MARK()

   Local _aArea	:= GetArea()
   Local _aAreaSC6	:= GetArea("SC6")
   Local _aAreaSC9	:= GetArea("SC9")
   Local _aAreaSF4	:= GetArea("SF4")
   Local _aAreaSB1	:= GetArea("SB1")
   Local _cMarcado	:= oMark:cmark	//Variavel utilizada para saber o valor que indica que um pedido foi selecionado
   Local _lInverte	:= PARAMIXB[2]
   Local _lRet		:= .T.			//Armazena se podera ser faturado ou nao os itens selecionados
   Local _lVldPes	:= U_ITGetMV( 'IT_VALPESF' , .F. )
   Local _ni := 1
   Local _apars := {},_in

   Private lNoShowDlg	:= .F.
   Private lManterMsg	:= .F.
   Private cMsgComple	:= ""
   Private _cfiltro     := ""

    //Guarda parametros atuais e refaz pergunte
   For _in = 1 to 60
      _cnome := "mv_par" + strzero(_in,2)
      aadd(_apars,&_cnome)
   Next _in

    //====================================================================================================
    // Funcao responsavel por validar se a DataBase e igual a data atual(Servidor) para nao permitir o
    // faturamento com data retroativa ou posterior a data atual.
    //====================================================================================================
   If Posicione("ZZL",3,xFilial("ZZL")+RetCodUsr(),"ZZL_ALDTEM") <> 'S' .And. dDataBase <> Date()
      MsgStop("A DataBase do sistema não é válida para o faturamento! A DataBase deve ser igual à data real do Servidor, não é permitido faturamento futuro ou retroativo.","M460MARK001")
      Return .F.
   EndIf

   If AllTrim( Upper( FunName() ) ) == 'MATA460B' //Faturamento por carga
      Pergunte("MT461B", .F.)
      _lInverte:=(MV_PAR02 = 1)// Trazer Carga Marcada   - Sim/Nao
   ENDIF

   If ThisInv() .OR. _lInverte
      u_itmsg('Não é permitido selecionar todas as cargas / pedidos ou trazer cargas / pedidos selecionados. ','Validação de processo',;
             'Utilize a seleção manual de cargas / pedidos',1)
      RETURN .F.
   ENDIF

    //====================================================================================================
    // Se o linverte está marcado prepara o filtro da sc9 de acordo com o browse aberto
    // Desse modo os registros que aparecem com campo ok em branco serão realmente os registros marcados
    //====================================================================================================
   If _linverte

      If AllTrim( Upper( FunName() ) ) == 'MATA460A' //Faturamento por pedido

         Pergunte("MT461A", .F.)
         //====================================================================================================
         //  Verifica as perguntas MT461A
         //====================================================================================================
         //====================================================================================================
         //  Variaveis utilizadas para parametros
         //  mv_par01     // Filtra j  emitidas     - Sim/Nao
         //  mv_par02     // Estorno da Liberacao   - Posic./Marcados
         //  mv_par03     // Cons. Param. Abaixo    - Sim/Nao
         //  mv_par04     // Trazer Ped. Marc       - Sim/Nao
         //  mv_par05     // De  Pedido
         //  mv_par06     // Ate Pedido
         //  mv_par07     // De  Cliente
         //  mv_par08     // Ate Cliente
         //  mv_par09     // De  Loja
         //  mv_par10     // Ate Loja
         //  mv_par11     // De  Liberacao
         //  mv_par12     // Ate Liberacao
         //  mv_par13     // Mostra Itens Previstos - Sim/Não
         //  mv_par14     // De  Entrega
         //  mv_par15     // Ate Entrega
         //====================================================================================================

         _cfiltro += " AND SC9.C9_FILIAL='"+xFilial("SC9")+"'"

         If ( MV_PAR01 == 1 )

            _cfiltro += " And C9_BLEST <> '10'"
            _cfiltro += " And C9_BLEST <> 'ZZ'"

         EndIf

         If ( MV_PAR03 == 1 )

            _cfiltro += " And C9_PEDIDO>='"+MV_PAR05+"'"
            _cfiltro += " And C9_PEDIDO<='"+MV_PAR06+"'"
            _cfiltro += " And C9_CLIENTE>='"+MV_PAR07+"'"
            _cfiltro += " And C9_CLIENTE<='"+MV_PAR08+"'"
            _cfiltro += " And C9_LOJA>='"+MV_PAR09+"'"
            _cfiltro += " And C9_LOJA<='"+MV_PAR10+"'"
            _cfiltro += " And C9_DATALIB>='"+Dtos(MV_PAR11)+"'"
            _cfiltro += " And C9_DATALIB<='"+Dtos(MV_PAR12)+"'"

            If ( SC9->(FieldPos('C9_TPOP')) > 0 )
               //Mostra itens previstos?
               If ( !Empty( MV_PAR13 ) ) .And. ( ValType(MV_PAR13) == 'N' )
                  If ( MV_PAR13 == 2 )
                     _cfiltro += " And C9_TPOP != '2'"
                  EndIf
               EndIf
            EndIf

            //Filtra por data de entrega
            If ( !Empty( MV_PAR14 ) ) .And. ( ValType(MV_PAR14) == 'D' )
               _cfiltro +=  "And C9_DATENT >= '" + DToS(MV_PAR14) + "'"
            EndIf
            If ( !Empty( MV_PAR15 ) ) .And. ( ValType(MV_PAR15) == 'D' )
               _cfiltro +=  "And C9_DATENT <= '" + DToS(MV_PAR15) + "'"
            EndIf

         EndIf

         _cfiltro += " AND SC9.C9_CARGA = ' '"

      ElseIf AllTrim( Upper( FunName() ) ) == 'MATA460B' //Faturamento por carga

         //====================================================================================================
         // Verifica as perguntas MT461B
         //====================================================================================================
         //====================================================================================================
         // Variaveis utilizadas para parametros
         // mv_par01     // Filtra j  emitidas     - Sim/Nao
         // mv_par02     // Trazer Carga Marcada   - Sim/Nao
         // mv_par03     // Carga Inicial
         // mv_par04     // Carga Final
         // mv_par05     // Caminhao Inicial
         // mv_par06     // Caminhao Final
         // mv_par07     // Dt de Liberacao Inicial
         // mv_par08     // Dt de Liberacao Final
         // mv_par09     // Fatura Pedidos c/Bloqueio WMS? Sim/Nao
         //====================================================================================================

         Pergunte("MT461B", .F.)

         _cfiltro += " AND (select MIN(c9_DATALIB) FROM "+ RetSqlName('SC9') +" SC9 WHERE SC9.D_E_L_E_T_ <> '*' AND C9_FILIAL = '" + xFilial("DAK")
         _cfiltro += "' AND C9_PEDIDO = DAI.DAI_PEDIDO)>='"+Dtos(MV_PAR07)+"'"

         _cfiltro += " AND (select MAX(c9_DATALIB) FROM "+ RetSqlName('SC9') +" SC9 WHERE SC9.D_E_L_E_T_ <> '*' AND C9_FILIAL = '" + xFilial("DAK")
         _cfiltro += "' AND C9_PEDIDO = DAI.DAI_PEDIDO)<='"+Dtos(MV_PAR08)+"'"

         _cfiltro += " AND DAK_FILIAL='"+xFilial("DAK")+"'"

         //Não traz pré carga
         _cfiltro += " AND DAK.DAK_I_PREC <> '1'"

         If (MV_PAR01 == 1)
            _cfiltro += " AND DAK_FEZNF<>'1'"
         EndIf

         If !(Empty(MV_PAR03) .And. Upper(MV_PAR04) == Replicate('Z', Len(MV_PAR04)))
            _cfiltro += " AND DAK.DAK_COD>='"+MV_PAR03+"'"
            _cfiltro += " AND DAK.DAK_COD<='"+MV_PAR04+"'"
         EndIf

         If !(Empty(MV_PAR05) .And. Upper(MV_PAR06) == Replicate('Z', Len(MV_PAR06)))
            _cfiltro += " AND DAK.DAK_CAMINH>='"+MV_PAR05+"'"
            _cfiltro += " AND DAK.DAK_CAMINH<='"+MV_PAR06+"'"
         EndIf

         _cfiltro += " AND DAK.DAK_DATA>='"+DToS(MV_PAR10)+"'"
         _cfiltro += " AND DAK.DAK_DATA<='"+Dtos(MV_PAR11)+"'"

      Endif

   Endif

    //****************************************************************************************************************************//
    //****************************************************************************************************************************//
    //****************************************************************************************************************************//
    // NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE PROCURE POR "COLOQUE AQUI" E INSIRA AS VALIDACOES LÁ POR FAVOR, NÃO COLOQUE NADA AQUI
    //****************************************************************************************************************************//
    //****************************************************************************************************************************//
    //****************************************************************************************************************************//

    //====================================================================================================
    // Funcao responsavel por validar no faturamento avulso de pedidos de venda se ficou algum item de um
    // determinado pedido de venda sem selecionar pois nao é permitido o faturamento parcial
    //====================================================================================================
   If _lRet
      FWMSGRUN( , {|| _lRet := IT_VLDPSEL( _cMarcado ) } , "Aguarde!", "Verificando itens de pedidos não selecionados..."  )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //====================================================================================================================================================
    // Função responsável para Criação da tabela Temporaria dos PV/Cargas marcados
    //====================================================================================================================================================
   PRIVATE _cAliasDAI :=GetNextAlias()
   PRIVATE _aDAKCargas:={}
   PRIVATE _aDAKPVs   :={}
   PRIVATE _cAliasSC9 :=GetNextAlias()
   PRIVATE _aC9Pedidos:={}
   PRIVATE _aC9PVItens:={}
   PRIVATE _aC9Locais :={}

   If _lRet

      FWMSGRUN( , {|| _lRet := IT_CriaTemp( _cMarcado , _lInverte ) }, "Aguarde!" , "Criação da tabela Temporaria dos Registros Marcados..."  )

   EndIf

    //====================================================================================================================================================
    // Função responsável PARA CONTROLAR DE ACESSO AO FATURAMENTO
    //====================================================================================================================================================
    //If _lRet
    //	FWMSGRUN( , {|| _lRet := U_IT_VLDAcesso( _aC9Locais ,"TRAVA") }, "Aguarde!" , "Verificando CONTROLE DE ACESSO AO FATURAMENTO..."  )
    //EndIf
    
    //====================================================================================================================================================
    // Função responsável por validar se está faturando pedido enviado ao rdc sem carga E validação de clientes bloquedos Chamado: 24154
    //====================================================================================================================================================
   If _lRet

      FWMSGRUN( , {|| _lRet := IT_VLDPRDC( _cMarcado ) }, "Aguarde!" , "Verificando PV enviados ao RDC e Clientes Bloqueados..."  )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf


    //====================================================================================================
    // Validação do Armazém do pedido de vendas com relação ao tipo de faturamento
    //====================================================================================================
   If _lRet
      FWMSGRUN( , {|| _lRet := IT_VLDARM(  _cMarcado ) }, "Aguarde!" , "Verificando se existem itens de pedidos com armazém incorreto..."   )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //====================================================================================================
    // Validação do Estoque em poder de terceiros em pedidos liberados
    //====================================================================================================
   If _lRet

      FWMSGRUN( , {|| _lRet := IT_VLDEST3( _cMarcado , _lInverte ) } , "Aguarde!" , "Verificando se existem itens com estoque em poder de terceiros..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //====================================================================================================
    // Validação de armazéns restritos para o usuário
    //====================================================================================================
   If _lRet

      FWMSGRUN( , {|| _lRet := IT_VLDLOC( _cMarcado , _lInverte ) }, "Aguarde!" , "Verificando se existem armazéns restritos para o usuário..."  )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //====================================================================================================
    // Validação do peso dos produtos em caso de Ativos e/ou Movimentação de Estoque
    //====================================================================================================
   If _lRet .And. _lVldPes

      FWMSGRUN( , {|| _lRet := IT_VLDPES( _cMarcado , _lInverte ) } , "Aguarde!" , "Verificando dados do cadastro de produtos..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //====================================================================================================
    // Validação de integridade da carga
    //====================================================================================================
   If _lRet

      FWMSGRUN( , {|| _lRet := IT_VLDCRG( _cMarcado , _lInverte ) } , "Aguarde!" , "Verificando integridade da carga..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf
    //================================================================================================================================================================
    // Validacoes para o Desconto PIS e COFINS Vendas Manaus. Chamado: 16998   
    //================================================================================================================================================================
   If _lRet .AND. cFilAnt = "91"

      FWMSGRUN( , {||  _lRet:=IT_VLDesc( _cMarcado , _lInverte ) } , "Aguarde!" , "Verificando Descontos PIS e COFINS Vendas Manaus..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //====================================================================================================
    // Validação de crédito dos pedidos de venda da carga
    //====================================================================================================
   If _lRet

      FWMSGRUN( , {|| _lRet := IT_VLDCRE( _cMarcado , _lInverte ) } , "Aguarde!" , "Verificando crédito dos pedidos selecionados..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //============================================================================================================================================================
    // Validação para não permitir fracionamento para PAs (produtos acabados) onde a primeira unidade de medida for UN
    //============================================================================================================================================================
   If _lRet

      FWMSGRUN( , {|| _lRet := ITVLDFR1UM( _cMarcado , _lInverte ) } , "Aguarde!" , "Verificando fracionamento dos Itens..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

   EndIf

    //================================================================================================================================================================
    // VALIDAÇAÕ DAS TES dos Pedidos de Operacao Triangular. Chamado 
    //================================================================================================================================================================
   If _lRet

      FWMSGRUN( , {||  _lRet:= U_IT_Gera_FatTri("#VALIDAR") } , "Aguarde!" , "Gerando Pedidos Triangular..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

      Pergunte("MT460A",.F.)//Restaura os MV_PAR?? do Padrão

   EndIf//SEMPRE DEIXAR ESSE PROCESSMENTO DE TROCA NOTA POR ULTIMO PQ TEM DisarmTransaction() caso o retorno seja .F. E GRAVAÇÕES

    //****************************************************************************************************************************//
    //****************************************************************************************************************************//
    //****************************************************************************************************************************//
    // NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE E SEM TELA "COLOQUE AQUI" ACIMA
    //****************************************************************************************************************************//
    //****************************************************************************************************************************//
    //****************************************************************************************************************************//
    
    //Garante que o C5_I_STATU do pedido de vendas é atualizado
   If _lRet
      Reclock("SC5",.F.)
      SC5->C5_I_STATU = "02"
      SC5->( MsUnlock() )
   Endif
    
   //================================================================================================================================================================
    // Processamento de Pedido de Pallet  - Chamado 27333
    //================================================================================================================================================================
    //ESSE PROCESSAMENTO NÃO TEM DisarmTransaction() só avisa que não deu certo. MAS SEMPRE DEIXAR ESSE PROCESSMENTO POR PENULTIMO
   If _lRet .AND. SC5->(FIELDPOS("C5_I_PVREF")) <> 0 .AND. SC5->(FIELDPOS("C5_I_QTPA")) <> 0


      FWMSGRUN( , {||  _lRet:=IT_Ger_Pallets(_cMarcado) } , "Aguarde!" , "Gerando PEDIDOS DE PALLETS..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

      Pergunte("MT460A",.F.)//Restaura os MV_PAR?? do Padrão

   EndIf//ESSE PROCESSAMENTO NÃO TEM DisarmTransaction() só avisa que não deu certo. MAS SEMPRE DEIXAR ESSE PROCESSMENTO POR PENULTIMO

    //================================================================================================================================================================
    // Processamento de Troca Nota  - Projeto de unificação de pedidos de troca nota - Chamado 16548      
    //================================================================================================================================================================
   If _lRet//SEMPRE DEIXAR ESSE PROCESSMENTO POR ULTIMO PQ TEM DisarmTransaction() caso o retorno seja .F. E GRAVAÇÕES

      FWMSGRUN( , {||  _lRet:=IT_Gera_Pedidos( _cMarcado ) } , "Aguarde!" , "Verificando Pedidos de Troca Nota..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

      Pergunte("MT460A",.F.)//Restaura os MV_PAR?? do Padrão

   EndIf//SEMPRE DEIXAR ESSE PROCESSMENTO DE TROCA NOTA POR ULTIMO PQ TEM DisarmTransaction() caso o retorno seja .F. E GRAVAÇÕES

    //================================================================================================================================================================
    // Processamento de Pedidos de Operacao Triangular. Chamado 
    // OBS: QUANDO TEM TROCA NÃO GERA A O PEDIDO 
    //================================================================================================================================================================
   If _lRet//SEMPRE DEIXAR ESSE PROCESSMENTO POR ULTIMO PQ TEM DisarmTransaction() caso o retorno seja .F. E GRAVAÇÕES

      FWMSGRUN( , {||  _lRet:= U_IT_Gera_FatTri("#GERAR") } , "Aguarde!" , "Gerando Pedidos Triangular..." )

      RestArea( _aArea )
      RestArea( _aAreaSC6 )
      RestArea( _aAreaSC9 )
      RestArea( _aAreaSF4 )
      RestArea( _aAreaSB1 )

      Pergunte("MT460A",.F.)//Restaura os MV_PAR?? do Padrão

   EndIf//SEMPRE DEIXAR ESSE PROCESSMENTO DE TROCA NOTA POR ULTIMO PQ TEM DisarmTransaction() caso o retorno seja .F. E GRAVAÇÕES

   //************************************************************  FIM DOS TRATAMENTOS ****************************************************************************

   If Select(_cAliasSC9) > 0
      (_cAliasSC9)->( DBCloseArea() )
   EndIf

   If Select(_cAliasDAI) > 0
      (_cAliasDAI)->( DBCloseArea() )
   EndIf

    //Restaura parametros iniciais
   For _in = 1 to 60
      _cnome := "mv_par" + strzero(_in,2)
      &_cnome := _apars[_ni]
   Next _in

Return ( _lRet )

/*
===============================================================================================================================
Programa--------: IT_VLDPSEL
Autor-----------: Fabiano Dias
Data da Criacao-: 08/08/2011
Descrição-------: Função responsável por validar no faturamento se ficou algum item do pedido de venda sem selecionar para não
----------------: permitir o faturamento parcial.
Parametros------: _cMarcado
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDPSEL( _cMarcado )

   Local _aArea	:= GetArea()
   Local _aPedProb	:= {}
   Local _cAlias	:= GetNextAlias()
   Local _cQuery	:= ''
   Local _lRet		:= .T.
   Local _lInverte	:= PARAMIXB[2]

    //====================================================================================================
    // Somente valida se a chamada for executada pela rotina de faturamento de pedidos avulsos
    //====================================================================================================
   If AllTrim( Upper( FunName() ) ) == 'MATA460A'

      _cQuery := " SELECT "
      _cQuery += "     SC9.C9_OK    ,"
      _cQuery += "     SC9.C9_PEDIDO "
      _cQuery += " FROM  "+ RetSqlName('SC9') +" SC9 "
      _cQuery += " WHERE "+ RetSqlCond('SC9')
      _cQuery += " AND SC9.C9_PEDIDO  IN ( SELECT DISTINCT SC92.C9_PEDIDO FROM "+ RetSqlName('SC9') +" SC92 "
      _cQuery += "                         WHERE SC92.D_E_L_E_T_ = ' ' AND SC92.C9_FILIAL = SC9.C9_FILIAL"
      If _linverte
         _cQuery += _cfiltro + " AND SC92.C9_OK <> '"+ _cMarcado +"' )"
      Else
         _cQuery += " AND SC92.C9_OK = '"+ _cMarcado +"' )"
      Endif
      _cQuery += " AND SC9.C9_NFISCAL = ' ' "
      _cQuery += " GROUP BY SC9.C9_OK, SC9.C9_PEDIDO " 
      _cQuery += " ORDER BY SC9.C9_PEDIDO, SC9.C9_OK "

      If select(_cAlias) > 0
         (_cAlias)->( DBCloseArea() )
      EndIf

      DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,_cQuery) , _cAlias , .F. , .T. )

      DBSelectArea(_cAlias)
      (_cAlias)->( DBGoTop() )
      While (_cAlias)->( !EOF() )

         //====================================================================================================
         // Pedidos selecionados para faturamento
         //====================================================================================================
         If ( _lInverte .And. AllTrim( (_cAlias)->C9_OK ) == AllTrim( _cMarcado ) ) .Or. ( !_lInverte .And. AllTrim( (_cAlias)->C9_OK ) <> AllTrim( _cMarcado ) )

            aAdd( _aPedProb , { (_cAlias)->C9_PEDIDO } )

         EndIf

         (_cAlias)->( DBSkip() )
      EndDo

      (_cAlias)->( DBCloseArea() )

   EndIf

    //====================================================================================================
    // Identifica pedidos selecionados parcialmente
    //====================================================================================================
   If !Empty(_aPedProb)

      _lRet := .F.

      U_ITMSG( 'Existem pedidos que não tiveram todos os itens selecionados e não é permitido processar o faturamento de pedidos parcialmente!' , 'Validação Pedidos',,1 )
      U_ITListBox( 'Relação de Pedidos que não podem ser faturados! (M460MARK)' , {'Num. Pedido'} , _aPedProb , .F. , 1 , 'Os pedidos abaixo não tiveram todos os itens selecionados: ' )

   EndIf

   RestArea( _aArea )

Return( _lRet )


/*
===============================================================================================================================
Programa--------: IT_VLDPRDC
Autor-----------: Josué Danich Prestes
Data da Criacao-: 02/08/2017
Descrição-------: Validação contra faturamento de pedido de vendas enviado ao RDC sem carga e validação de clientes bloqueados
Parametros------: _cMarcado
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDPRDC( _cMarcado )
    Local _aArea	 := GetArea()
    Local _aPedProb	 := {}
    Local _lRet		 := .T.
    Local P		     := 0
    Local _aCliBloq  := {}
    Local _cIT_NAGEND:= ALLTRIM(SuperGetMV("IT_NAGEND",.F., "P;R;N"))//P=Aguardando Agenda; R=Reagendar; N=Reagendar 
    Local _aTipoEntr := {}

    //====================================================================================================
    // Somente valida se a chamada for executada pela rotina de faturamento de pedidos avulsos
    //====================================================================================================
   If AllTrim( Upper( FunName() ) ) == 'MATA460A'//  ***************** POR PEDIDO *****************

      SA1->(Dbsetorder(1))
      SC5->(Dbsetorder(1))
      FOR P := 1 TO LEN(_aC9Pedidos)

         SC9->(DBGOTO( _aC9Pedidos[P,1] ) )
         SC5->(Dbseek( SC9->C9_FILIAL+SC9->C9_PEDIDO ))
         //====================================================================================================
         // Clientes Bloqueados
         //====================================================================================================
         SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE+SC5->C5_LOJACLI ) )
         IF SA1->A1_MSBLQL == '1'
            AADD( _aCliBloq , { DAI->DAI_COD , SC5->C5_NUM ,SC5->C5_CLIENTE+" "+SC5->C5_LOJACLI+" - "+SA1->A1_NOME,"CLIENTE BLOQUEADO" } )
         ENDIF
         //====================================================================================================
         // Pedidos enviados para o RDC
         //====================================================================================================
         If SC5->C5_I_ENVRD == "S"
            aAdd( _aPedProb , { SC9->C9_PEDIDO , "ENVIADO PARA O RDC" } )
         EndIf
         //====================================================================================================
         // Pedidos com tipo de entraga: P=Aguardando Agenda; R=Reagendar; N=Reagendar que não podem faturar
         //====================================================================================================
         If SC5->C5_TIPO = 'N' .AND. SC5->C5_I_AGEND $ _cIT_NAGEND //P=Aguardando Agenda; R=Reagendar; N=Reagendar 
            aAdd( _aTipoEntr , { SC9->C9_PEDIDO , "TIPO DE ENTREGA NÃO PERMITIDA: "+SC5->C5_I_AGEND } )
         EndIf

      NEXT p

   ELSE//  ***************** POR CARGA *****************

      SA1->(Dbsetorder(1))
      SC5->(Dbsetorder(1))
      FOR P := 1 TO LEN(_aDAKPVs)

         DAI->(DBGOTO( _aDAKPVs[P,1] ) )
         SC5->(DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO ) ) )
         //====================================================================================================
         // Clientes Bloqueados
         //====================================================================================================
         SA1->(DBSeek( xFilial("SA1") + SC5->C5_CLIENTE+SC5->C5_LOJACLI ) )
         IF SA1->A1_MSBLQL == '1'
            AADD( _aCliBloq , { DAI->DAI_COD , SC5->C5_NUM ,SC5->C5_CLIENTE+" "+SC5->C5_LOJACLI+" - "+SA1->A1_NOME,"CLIENTE BLOQUEADO" } )
         ENDIF

         //====================================================================================================
         // Pedidos com tipo de entraga: P=Aguardando Agenda; R=Reagendar; N=Reagendar que não podem faturar
         //====================================================================================================
         If SC5->C5_TIPO = 'N' .AND. SC5->C5_I_AGEND $ _cIT_NAGEND //P=Aguardando Agenda; R=Reagendar; N=Reagendar 
            aAdd( _aTipoEntr , { SC9->C9_PEDIDO , "TIPO DE ENTREGA NÃO PERMITIDO: "+SC5->C5_I_AGEND } )
         EndIf

      NEXT p

   EndIf

   If len(_aPedProb) > 0

      bBloco:={|| U_ITListBox( 'Relação de Pedidos que não podem ser faturados! (M460MARK)' , {'Num. Pedido','Problema'} , _aPedProb , .F. , 1 , 'Os pedidos abaixo já foram enviados ao RDC' ) }

      U_ITMSG('Existem pedidos que já foram enviados ao RDC e não podem ser faturados sem carga: VER Mais Detalhes',"Validação RDC",;
             'Realize  montagem da carga via RDC ou puxe o pedido de volta na tela de alteração de pedidos de vendas',1,,,,,,bBloco)

      _lRet := .F.
    ENDIF
   
   IF LEN(_aCliBloq) > 0

      bBloco:={|| U_ITListBox( 'Relação de Pedidos com Cliente Bloqueado! (M460MARK)' , {'Carga','Pedido',"Cliente",'Problema'} , _aCliBloq , .F. , 1 , 'Os Cliente(s) abaixo estão Bloqueado(s)' ) }

      U_ITMSG("Existe(m) Pedido(s) com Cliente Bloqueado","Atenção",'Entre em contato com os responsveis pelo Cadastro de Clientes.', 1,,,,,,bBloco)		

      _lRet := .F.
    ENDIF
   
   IF LEN(_aTipoEntr) > 0

      bBloco:={|| U_ITListBox( 'Relação de Pedidos que não podem ser faturados! (M460MARK)' , {'Num. Pedido','Problema'} , _aTipoEntr , .F. , 1 , 'Os pedidos abaixo estão com o tipo de entrega invalido.' ) }

      U_ITMSG("Existe(m) Pedido(s) com Tipo de Entrega igual a "+_cIT_NAGEND,"Atenção",'Só podem ser faturados Pedidos com tipo de entrega diferente de '+_cIT_NAGEND, 1,,,,,,bBloco)

      _lRet := .F.

   ENDIF

   RestArea( _aArea )

Return( _lRet )


/*
===============================================================================================================================
Programa--------: IT_VLDARM
Autor-----------: Talita
Data da Criacao-: 27/02/2013
Descrição-------: Validação dos pedidos se estão sendo gerados com o armazém de acordo com o IT_ARMCARG permitindo somente o
----------------: faturamento da notas que o armazém for diferente do parametro ou se possuir carga.
Parametros------: _cMarcado
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDARM( _cMarcado )

   Local _lRet		:= .T.
   Local _cLocal	:= AllTrim( GetMv( "IT_ARMCARG" ,, '' ) )
   Local _nCont	:= 0
   Local _aProd	:= {}
   Local P			:= 0

    //====================================================================================================
    // Valida apenas o faturamento avulso de pedidos
    //====================================================================================================
   If AllTrim( Upper( FunName() ) ) == 'MATA460A' .AND. !EMPTY(_cLocal)

      SC6->(DBSETORDER(1))
      FOR P := 1 TO LEN(_aC9Pedidos)//  ********** POR PEDIDO

         SC9->(DBGOTO( _aC9Pedidos[P,1] ) )
         If SC6->( DBSEEK( SC9->C9_FILIAL+SC9->C9_PEDIDO ))

            DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC9->C9_FILIAL+SC9->C9_PEDIDO

               _cTes := GetAdvFVal( "SF4" , "F4_ESTOQUE" , xFilial("SF4") + SC6->C6_TES , 1 , "" )

               If  alltrim(SC6->C6_LOCAL) $ _cLocal .And. _cTes = "S"

                  aAdd( _aProd , { SC6->C6_NUM , SC6->C6_ITEM , SC6->C6_PRODUTO , SC6->C6_LOCAL } )
                  _nCont++

               EndIf

               SC6->( DBSkip() )
            EndDo

         EndIf
      NEXT p

      If _nCont > 0
         _lRet = .F.
         U_ITMSG( 'Para o(s) armazém(s) '+ _cLocal +' somente serão faturados os pedidos que tiverem a montagem de carga realizada!' ,'Validação Armazéns',,1 )
         U_ITListBox( 'Pedidos/Itens que não podem ser faturados (M460MARK)' , {'Pedido','Item','Produto','Armazem'} , _aProd , .F. , 1 ,'Armazém(s): '+ _cLocal +'. Verifique os pedidos abaixo: ' )
      Else
         _lRet = .T.
      EndIf

   EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: IT_VLDEST3
Autor-----------: Alexandre Villar
Data da Criacao-: 26/06/2015
Descrição-------: Validação dos pedidos que estão sendo faturados para não permitir o faturamento se não tiver o saldo total do
----------------: pedido em estoque (para Filiais/Armazéns que utilizam estoque em poder de terceiros)
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDEST3( _cMarcado , _lInverte )

   Local _lRet		:= .T.
   Local _lErro	:= .F.
   Local _cFilEst3	:= AllTrim( U_ITGetMV( 'IT_EST3FIL' , ''   ) )
   Local P,_aProd:={}

    //====================================================================================================
    // Verificação do faturamento com base em Cargas
    //====================================================================================================
   If IsInCallStack("MATA460B")
      DbSelectArea("SC9")  
      DbSelectArea("SB2")
      DbSelectArea("SB6")

      If cFilAnt $ _cFilEst3

         _aProd := {}
         SC5->( DBSetOrder(1) )
         SC9->( DBSetOrder(1) )
         FOR P := 1 TO LEN(_aDAKPVs)

            DAI->(DBGOTO( _aDAKPVs[P,1] ) )

            If SC5->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO ) ) )

               If SC5->C5_I_TRCNF = 'S'             .AND.;//Pedidos de Troca Nota
                  SC5->C5_I_FILFT # SC5->C5_I_FLFNC .AND.;
                     !EMPTY(SC5->C5_I_FILFT)           .AND.;
                     !EMPTY(SC5->C5_I_PDFT)            .AND.;
                     SC5->C5_I_FILFT == cFilAnt  //Verifico a filial de faturamento pq pode ter pedidos de filiais de faturmento diferentes na mesma carga

                  LOOP

               ENDIF

            ENDIF

            If SC9->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO ) ) )

               //====================================================================================================
               // Valida o saldo efetivo em estoque para o faturamento
               //====================================================================================================
               _lRet := U_ITVLDEST( 1 , SC9->C9_FILIAL , SC9->C9_PEDIDO , SC9->C9_LOCAL , _aProd )

               If !_lRet
                  _lErro:=.T.
               EndIf


            Else

               _lRet := .F.

               aAdd( _aProd , { DAI->DAI_COD, DAI->DAI_PEDIDO , "" , "" , "" , "" , "", "Pedido Sem Liberação (SC9)" } )

            EndIf
            IF !_lRet
               _lErro:=.T.
            ENDIF

         NEXT p

         If len(_aProd) > 0 .AND. _lErro
            _lRet := .F.//Pq se o ultimo item tiver ok nao devolve falso
            U_ITListBox( 'Falha na verificação do estoque dos pedidos da Carga! (M460MARK)' , {'Carga','Pedido','Item','Produto','Local',"Quatidade","Saldo Estoque","Problema"} , _aProd , .T. , 1 , 'Verifique os Produtos abaixo: ' )
         ENDIF

      EndIf

    //====================================================================================================
    // Verificação do faturamento de pedidos avulsos
    //====================================================================================================
   Else

      If cFilAnt $ _cFilEst3

         SC6->(DBSETORDER(1))
         FOR P := 1 TO LEN(_aC9Pedidos)//Era por item mas foi para ser por pedido //  ********** POR PEDIDO

            SC9->(DBGOTO( _aC9Pedidos[P,1] ) )

            _lRet := U_ITVLDEST( 1 , SC9->C9_FILIAL , SC9->C9_PEDIDO )

            If !_lRet
               U_ITMSG( 'Não existe saldo em estoque para faturar todos os itens do pedido: '+SC9->C9_PEDIDO,"Validação do Estoque das Filiais: "+_cFilEst3,;
                  'A Filial '+SC9->C9_FILIAL +' do pedido considera estoque em poder de terceiros, verifique os saldos dos itens pois todos devem constar "em estoque" para o faturamento.' , 1 )
               Exit
            EndIf

         NEXT p

      EndIf

   EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: IT_VLDLOC
Autor-----------: Josué Danich Prestes
Data da Criacao-: 25/09/2015
Descrição-------: Validação dos armazéns usados pelo pedido contra cadastro usuário X filiais X armazéns
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDLOC( _cMarcado , _lInverte )

   Local _lRet	:= .T.
   Local _aRet 	:= {}
   Local _aprod  := {}
   Local P
   Local _cusua  := alltrim(RetCodUsr())


    //====================================================================================================
    // Verificação do faturamento com base em Cargas
    //====================================================================================================
   If IsInCallStack("MATA460B")

      SC9->( DBSetOrder(1) )
      FOR P := 1 TO LEN(_aDAKPVs)

         DAI->(DBGOTO( _aDAKPVs[P,1] ) )

         If SC9->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO  ) ) )
            //====================================================================================================
            // Valida o armazém contra a filial + usuário
            //====================================================================================================
            Do while SC9->( !EOF() ) .AND. SC9->C9_FILIAL == DAI->DAI_FILIAL .AND. SC9->C9_PEDIDO == DAI->DAI_PEDIDO
               //============================================
               //Valida armazémxprodutoxfilialxusuário
               //============================================
               _aRet := U_ACFG004E(_cusua, alltrim(xFilial("SC9")), alltrim(SC9->C9_LOCAL),alltrim(SC9->C9_PRODUTO))

               //se ainda está valido verifica se não teve erro
               If _lRet

                  _lRet:= _aRet[1]

               Endif

               // adiciona armazens com problema se ainda não estiver na mensagem
               if  !(Empty(_aRet[2]))

                  if ASCAN(_aprod, { |x| x[1] == alltrim(SC9->C9_PEDIDO) .and. x[2] == alltrim(SC9->C9_ITEM) .and. x[3] == alltrim(SC9->C9_PRODUTO) }) == 0

                     aadd(_aprod,{alltrim(SC9->C9_PEDIDO),alltrim(SC9->C9_ITEM),alltrim(SC9->C9_PRODUTO),_aRet[2]})

                  Endif

               Endif


               SC9->( Dbskip() )

            Enddo

         EndIf
      NEXT P
    //====================================================================================================
    // Verificação do faturamento de pedidos avulsos
    //====================================================================================================
   Else

      SC6->(DBSETORDER(1))
      FOR P := 1 TO LEN(_aC9PVItens)//  ********** POR ITEM

         SC9->(DBGOTO( _aC9PVItens[P,1] ) )
         //============================================
         //Valida armazém x produto x filial x usuário
         //============================================
         _aRet := U_ACFG004E(_cusua, ALLTRIM(SC9->C9_FILIAL), ALLTRIM(SC9->C9_LOCAL),ALLTRIM(SC9->C9_PRODUTO))

         //se ainda está valido verifica se não teve erro
         If _lRet
            _lRet:= _aRet[1]
         Endif

         // adiciona armazens com problema se ainda não estiver na mensagem
         IF  !(Empty(_aRet[2]))

            if ASCAN(_aprod, { |x| x[1] == alltrim(SC9->C9_PEDIDO) .and. x[2] == alltrim(SC9->C9_ITEM) .and. x[3] == alltrim(SC9->C9_PRODUTO) }) == 0

               AADD(_aprod,{alltrim(SC9->C9_PEDIDO),alltrim(SC9->C9_ITEM),alltrim(SC9->C9_PRODUTO),_aRet[2]})

            Endif

         Endif

      NEXT p

   EndIf

    //============================================
    //Mostra lista de armazéns com problema
    //============================================
   If !(_lRet) .and. len(_aprod) > 0

      U_ITMSG( 'Existem pedidos que usam armazéns restritos para o USUARIO X FILIAL.','Validação Usuário',,1)
      U_ITListBox( 'Pedidos/Itens que não podem ser faturados (M460MARK)' , {'Pedido','Item','Produto','Armazém'} , _aProd , .F. , 1 , 'Verifique os pedidos abaixo: ' )

   Endif

Return( _lRet )

/*
===============================================================================================================================
Programa--------: IT_VLDPES
Autor-----------: Alexandre Villar
Data da Criacao-: 12/02/2016
Descrição-------: Validação do peso dos produtos em caso de Ativos e/ou Movimentação de Estoque
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDPES( _cMarcado , _lInverte )

   Local _lRet		:= .T.
   Local P

    //====================================================================================================
    // Verificação do faturamento com base em Cargas
    //====================================================================================================
   If IsInCallStack("MATA460B")

      SC6->( DbSetOrder(1) )
      SC9->( DBSetOrder(1) )
      SF4->( DBSetOrder(1) )
      SB1->( DBSetOrder(1) )
      FOR P := 1 TO LEN(_aDAKPVs)

         DAI->(DBGOTO( _aDAKPVs[P,1] ) )

         If SC6->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO ) ) )

            DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == DAI->( DAI_FILIAL + DAI_PEDIDO )

               If SF4->( DBSeek( xFilial('SF4') + SC6->C6_TES ) )

                  //====================================================================================================
                  // Valida os produtos de acordo com a configuração de Ativo/Estoque x Peso
                  //====================================================================================================
                  If SF4->F4_ATUATF == 'S' .Or. SF4->F4_ESTOQUE == 'S'

                     If SB1->( DBSeek( xFilial('SB1') + SC6->C6_PRODUTO ) )

                        If ( SB1->B1_PESO == 0 ) .Or. ( SB1->B1_PESBRU == 0 )
                           //								|....:....|....:....|....:....|....:....|
                           U_ITMSG( 'O produto utilizado nos pedidos não tem informação de Peso (B1_PESO) ou Peso Bruto (B1_PESBRU).','ATENÇÃO',;
                              'Para a TES utilizada o produto deve ter as informações dos Pesos cadastradas. '+;
                              ' Carga: '+ DAI->DAI_FILIAL +' - '+ DAI->DAI_COD+;
                              ' / Pedido: '+ SC6->C6_NUM+' / Item: '+ SC6->C6_ITEM+' / Produto: '+ SC6->C6_PRODUTO, 1  )

                           _lRet := .F.
                           Exit

                        EndIf

                     EndIf

                  EndIf

               EndIf

               SC6->( DBSkip() )
            EndDo

         EndIf

         If !_lRet
            Exit
         EndIf

      NEXT P

    //====================================================================================================
    // Verificação do faturamento de pedidos avulsos
    //====================================================================================================
   Else

      SB1->( DBSetOrder(1) )
      SC6->( Dbsetorder(1) )
      SF4->( DBSetOrder(1) )
      FOR P := 1 TO LEN(_aC9Pedidos)//Era por item mas foi para ser por pedido//  ********** POR PEDIDO

         SC9->(DBGOTO( _aC9Pedidos[P,1] ) )

         If SC6->( DBSeek( SC9->( C9_FILIAL + C9_PEDIDO ) ) )

            DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC9->( C9_FILIAL + C9_PEDIDO )

               If SF4->( DBSeek( xFilial('SF4') + SC6->C6_TES ) )

                  If SF4->F4_ATUATF == 'S' .Or. SF4->F4_ESTOQUE == 'S'

                     If SB1->( DBSeek( xFilial('SB1') + SC6->C6_PRODUTO ) )

                        If ( SB1->B1_PESO == 0 ) .Or. ( SB1->B1_PESBRU == 0 )
                           //								|....:....|....:....|....:....|....:....|
                           U_ITMSG( 'O produto utilizado nos pedidos não tem informação de Peso (B1_PESO) ou Peso Bruto (B1_PESBRU).','ATENÇÃO',;
                              'Para a TES utilizada o produto deve ter as informações dos Pesos cadastradas. Pedido: '+SC6->C6_FILIAL +' - '+ SC6->C6_NUM+;
                              ' / Item: '+ SC6->C6_ITEM+' / Produto: '+ SC6->C6_PRODUTO, 1  )

                           _lRet := .F.
                           Exit

                        EndIf

                     EndIf

                  EndIf

               EndIf

               SC6->( DBSkip() )
            EndDo

         EndIf
         If !_lRet
            Exit
         EndIf
      NEXT P

   EndIf

Return( _lRet )


/*
===============================================================================================================================
Programa--------: IT_VLCRG
Autor-----------: Josué Danich prestes
Data da Criacao-: 20/09/2016
Descrição-------: Validação a integridade da carga contra sequencias duplicadas
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDCRG( _cMarcado , _lInverte )

 Local _lRet		:= .T.,P
 Local _aSC6     := SC6->(Getarea())
 Local _cCrtlRast := SuperGetMV("MV_RASTRO",.F., "N")
 
 Begin Sequence 
   //====================================================================================================
   // Verificação do faturamento com base em Cargas
   //====================================================================================================
   If IsInCallStack("MATA460B")
     SC9->( DBSetOrder(1) )
     SC6->( Dbsetorder(1) )

     FOR P := 1 TO LEN(_aDAKPVs)

        DAI->(DBGOTO( _aDAKPVs[P,1] ) )

         If AllTrim(_cCrtlRast) == "S" 
            _aResp := IT_VLITRAS( DAI->DAI_FILIAL, DAI->DAI_PEDIDO, DAI->DAI_COD, .T.)
            _lRet  :=  _aResp[1]

            If ! _lRet
                U_ITMSG(_aResp[2],"Processamento Pedidos",_aResp[3],1)
                Exit
            EndIf 
        Else    
           If SC9->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO ) ) )
              //====================================================================================================
              // Valida os produtos de acordo com a configuração de Ativo/Estoque x Peso
              //====================================================================================================
              DO While SC9->( C9_FILIAL + C9_PEDIDO ) == DAI->( DAI_FILIAL + DAI_PEDIDO ) .AND. SC9->(!EOF())

               If SC9->C9_SEQUEN != '01'

                  _cProblema:="O Pedido / Produto "+SC9->C9_FILIAL+" - "+SC9->C9_PEDIDO+" / "+ALLTRIM(SC9->C9_PRODUTO)+" apresentou falha de dados (SC9 Seq.: "+SC9->C9_SEQUEN+" ) "
                  _cSolucao :='Será necessário estornar a Carga: '+ SC9->C9_FILIAL +' - '+ DAI->DAI_COD+' e a liberação do Pedido, e criar a carga novamente'
                  U_ITMSG(_cProblema,"Processamento Pedidos",_cSolucao,1)

                 _lRet := .F.
                 Exit
               Endif

               If !SC6->(Dbseek( SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM )) .or. SC9->C9_PRODUTO != SC6->C6_PRODUTO .OR. SC9->C9_QTDLIB != SC6->C6_QTDVEN

                  _cProblema:="O Pedido / Produto "+SC9->C9_FILIAL+" - "+SC9->C9_PEDIDO+" / "+ALLTRIM(SC9->C9_PRODUTO)+" apresentou falha de dados (Divergênia C9/C6 ) "
                  _cSolucao :='Será necessário estornar a Carga: '+ SC9->C9_FILIAL +' - '+ DAI->DAI_COD+' e a liberação do Pedido, e criar a carga novamente'
                  U_ITMSG(_cProblema,"Processamento Pedidos",_cSolucao,1)

                 _lRet := .F.
                 Exit
               Endif

               SC9->( DBSkip() )
            EndDo
          Else
             _cProblema:="O Pedido "+DAI->DAI_FILIAL+" - "+DAI->DAI_PEDIDO +" apresentou falha de dados (Não localizou liberação) "
             _cSolucao :='Será necessário estornar a Carga: '+ SC9->C9_FILIAL +' - '+ DAI->DAI_COD+' e a liberação do Pedido, e criar a carga novamente'
             U_ITMSG(_cProblema,"Processamento Pedidos",_cSolucao,1)

             _lRet := .F.
             Exit
           EndIf

          If !_lRet
             Exit
          EndIf
       EndIf 
     NEXT P
   Else
     //===============================================
     // Faturamento por pedido de vendas
     //===============================================
      If AllTrim(_cCrtlRast) == "S"  
        _aResp := IT_VLITRAS(SC9-> C9_FILIAL,SC9->C9_PEDIDO, "", .F.)
       _lRet  :=  _aResp[1]

       If ! _lRet
            U_ITMSG(_aResp[2],"Processamento Pedidos",_aResp[3],1)
          Break 
        EndIf 
      Else    
       SC6->(Dbsetorder(1))
       If SC6->(Dbseek(SC9->( C9_FILIAL + C9_PEDIDO + C9_ITEM )))
          If SC9->C9_SEQUEN != '01'
            _cProblema:="O Pedido / Produto "+SC9->C9_FILIAL+" - "+SC9->C9_PEDIDO+" / "+ ALLTRIM(SC9->C9_ITEM) +" / "+ALLTRIM(SC9->C9_PRODUTO)+" apresentou falha de dados (SC9 Seq.: "+SC9->C9_SEQUEN+" ) "
            _cSolucao :='Será necessário estornar a liberação do Pedido, e liberar novamente'
            U_ITMSG(_cProblema,"Processamento Pedidos",_cSolucao,1)

            _lRet := .F.
         Endif

         If SC9->C9_PRODUTO != SC6->C6_PRODUTO .OR. SC9->C9_QTDLIB != SC6->C6_QTDVEN
            _cProblema:="O Pedido / Produto "+SC9->C9_FILIAL+" - "+SC9->C9_PEDIDO+" / "+ ALLTRIM(SC9->C9_ITEM)+" / "+ALLTRIM(SC9->C9_PRODUTO)+" apresentou falha de dados (Divergênia C9/C6 ) "
            _cSolucao :='Será necessário estornar  a liberação do Pedido, e liberar novamente'
            U_ITMSG(_cProblema,"Processamento Pedidos",_cSolucao,1)

            _lRet := .F.
         Endif
       Else
          _cProblema:="O Pedido "+SC9->C9_FILIAL+" - "+SC9->C9_PEDIDO +" apresentou falha de dados (Não localizou pedido) "
         _cSolucao :='Será necessário estornar a liberação do Pedido, e liberar novamente'
         U_ITMSG(_cProblema,"Processamento Pedidos",_cSolucao,1)

         _lRet := .F.
       EndIf
     EndIf
   EndIf	
 End Sequence 

 SC6->(Restarea(_aSC6))

Return( _lRet )


/*
===============================================================================================================================
Programa--------: IT_VLDesc()
Autor-----------: Alex Wallauer
Data da Criacao-: 21/09/2015
Descrição-------: Foi incluída novas validacoes para o Desconto PIS e COFINS Vendas Manaus. Chamado: 16998
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/

Static Function IT_VLDesc( _cMarcado , _lInverte )
   Local _lRet	    := .T.
   Local _aprod    := {}
   Local _aProdAux := {}
   Local _lMV_DESZFPC:=GetMv("MV_DESZFPC")
   Local P,A

    //====================================================================================================
    // Verificação do faturamento com base em Cargas
    //====================================================================================================
   If IsInCallStack("MATA460B")

      SC5->( DBSetOrder(1) )
      SC9->( DBSetOrder(1) )

      FOR P := 1 TO LEN(_aDAKPVs)

         DAI->(DBGOTO( _aDAKPVs[P,1] ) )

         If SC5->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO  ) ) ) .AND.;
               SC9->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO  ) ) )


            _cEstado   :=POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EST")
            _cMunicipio:=POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_COD_MUN")
            _aProdAux  := {}
            lCalc:=(POSICIONE("CC2",1,xFilial("CC2")+_cEstado+_cMunicipio,"CC2_I_CALC") = "1")

            _lITodosSim:=.T.
            _lITodosNao:=.T.
            Do while SC9->C9_FILIAL+SC9->C9_PEDIDO == DAI->DAI_FILIAL + DAI->DAI_PEDIDO .AND. SC9->( !EOF() )

               _lSim:=(POSICIONE("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,'B1_I_CALC') = "1")
               IF _lSim
                  _lITodosNao:=.F.
               ELSE
                  _lITodosSim:=.F.
               ENDIF

               AADD(_aProdAux,{DAI->DAI_COD,SC9->C9_PEDIDO,IF(lCalc,"Sim","Nao"),SC9->C9_ITEM,SC9->C9_PRODUTO,IF(_lSim,"Sim","Nao"),""})

               SC9->( Dbskip() )

            Enddo

            lITemDiferente:=.F.
            IF !_lITodosSim .AND. !_lITodosNao//Se os 2 tiver Falso é que tem item diferente
               lITemDiferente:=.T.
            ENDIF

            IF lCalc .AND. lITemDiferente //
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O pedido contém produtos com dois grupos de Desconto Suframa diferentes: ICMS e ICMS + PIS COFINS"
            ELSEIF (_lMV_DESZFPC .AND. !lCalc)
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O municipio do cliente pertence a uma área da Zona Franca de Manaus"
            ELSEIF (!_lMV_DESZFPC .AND. lCalc .and. _lITodosNao)
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O municipio do cliente pertence a uma área de livre comércio"
            ELSEIF (_lMV_DESZFPC .AND. lCalc .and. _lITodosSim)
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O(s) produto(s) informado(s) no pedido só podem ser comercializados com o desconto de ICMS Suframa"
            Endif

            IF !EMPTY(_aProdAux[1, LEN(_aProdAux[1]) ])
               FOR A := 1 TO LEN(_aProdAux)
                  AADD(_aprod,_aProdAux[A])
               NEXT A
            Endif

         EndIf

      NEXT P
    //====================================================================================================
    // Verificação do faturamento de pedidos avulsos
    //====================================================================================================
   Else
      _cPVControle:=""

      FOR P := 1 TO LEN(_aC9PVItens)//  ********** POR ITEM

         SC9->(DBGOTO( _aC9PVItens[P,1] ) )

         IF _cPVControle # SC9->( C9_FILIAL+C9_PEDIDO  )

            _cPVControle:=SC9->( C9_FILIAL+C9_PEDIDO  )

            SC5->( DBSeek( _cPVControle ) )
            _cEstado   :=POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EST")
            _cMunicipio:=POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_COD_MUN")
            _aProdAux  := {}
            lCalc      :=(POSICIONE("CC2",1,xFilial("CC2")+_cEstado+_cMunicipio,"CC2_I_CALC") = "1")
            _lITodosSim:=.T.
            _lITodosNao:=.T.

         ENDIF

         _lSim:=(POSICIONE("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,'B1_I_CALC') = "1")
         IF _lSim
            _lITodosNao:=.F.
         ELSE
            _lITodosSim:=.F.
         ENDIF
         AADD(_aProdAux,{"Sem Carga",SC9->C9_PEDIDO,IF(lCalc,"Sim","Nao"),SC9->C9_ITEM,SC9->C9_PRODUTO,IF(_lSim,"Sim","Nao"),""})

         IF P < LEN(_aC9PVItens)
            SC9->(DBGOTO( _aC9PVItens[(P+1),1] ) )
         ENDIF

         IF _cPVControle # SC9->( C9_FILIAL+C9_PEDIDO  ) .OR. P = LEN(_aC9PVItens)

            lITemDiferente:=.F.
            IF !_lITodosSim .AND. !_lITodosNao//Se os 2 tiver Falso é que tem item diferente
               lITemDiferente:=.T.
            ENDIF

            IF !lCalc .AND. lITemDiferente
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O pedido contém produtos com dois grupos de Desconto Suframa diferentes: ICMS e ICMS + PIS COFINS"
            ELSEIF (_lMV_DESZFPC .AND. !lCalc)
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O municipio do cliente pertence a uma área da Zona Franca de Manaus"
            ELSEIF (!_lMV_DESZFPC .AND. lCalc .and. _lITodosNao)
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O municipio do cliente pertence a uma área de livre comércio"
            ELSEIF (_lMV_DESZFPC .AND. lCalc .and. _lITodosSim)
               _aProdAux[1, LEN(_aProdAux[1]) ]:= "O(s) produto(s) informado(s) no pedido só podem ser comercializados com o desconto de ICMS Suframa"
            Endif

            IF !EMPTY(_aProdAux[1, LEN(_aProdAux[1]) ])
               FOR A := 1 TO LEN(_aProdAux)
                  AADD(_aprod,_aProdAux[A])
               NEXT A
            Endif

         Endif

      NEXT P

   EndIf

    //============================================
    //Mostra lista de problemas
    //============================================

   If len(_aprod) > 0

      _lRet:=.F.

      U_ITMSG( 'Existem pedidos com Problemas no desconto do PIS e COFINS ' ,'Validação fiscal',,1)

      U_ITListBox( 'Pedidos/Itens que não podem ser faturados (M460MARK)' , {"Carga",'Pedido',"Mun. Desc P/C ZF?",'Item','Produto','Desc P/C ZF?',"Problema"} , _aProd , .T. , 1 ,;
         "Conteudo do Parametro de desconto do PIS e COFINS Atual: "+IF(_lMV_DESZFPC,"Habilitado","Desabilitado") )

   Endif

Return( _lRet )

/*
===============================================================================================================================
Programa--------: IT_Gera_Pedidos
Autor-----------: Alex Wallauer
Data da Criacao-: 16/08/2016
Descrição-------: Unificação de pedidos de troca nota
Parametros------: _cMarcado - string usada para marcar
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
Static Function IT_Gera_Pedidos( _cMarcado )

   Local _lRet    :=.T.
   Local _lOK     :=.T.
   Local _lInverte:= PARAMIXB[2],P
   Local _lGeraLog:= GETMV("MV_GERLOGC",,.T.)

    //====================================================================================================
    // Verificação do faturamento com base em Cargas
    //====================================================================================================
   If IsInCallStack("MATA460B")

      _aPeds_Prod    :={}
      _aCargaAcerta  :={}
      _aFilFatTrocaNF:={}
      PRIVATE _aLog  :={}
      SC5->( DBSetOrder(1) )

      IF _lGeraLog
         IF LEN(_aDAKPVs) = 0 //(_cAlias)->( EOF() ) .AND. (_cAlias)->( BOF() )
            aAdd( _aLog , {.T.,"",IF(_lInverte,"Invertido","Não Invertido"),"SELECT não achou: ","","","","","","",""} )
         ELSE
            aAdd( _aLog , {.T.,"",IF(_lInverte,"Invertido","Não Invertido"),"SELECT achou: "    ,"","","","","","",""} )
         ENDIF
      ENDIF

      FOR P := 1 TO LEN(_aDAKPVs)

         DAK->(DBGOTO( _aDAKPVs[P,4] ) )
         DAI->(DBGOTO( _aDAKPVs[P,1] ) )

         If !SC5->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
            aAdd( _aLog , {.F.,DAK->DAK_FILIAL+" "+DAK->DAK_COD,DAI->DAI_FILIAL +" "+ DAI->DAI_PEDIDO,"Nao gerado","Não achou o Pedido","","","","","",""} )
            LOOP
         ENDIF

         _lCargaTemAlteracao:=.F.

         If SC5->C5_I_TRCNF = 'S' .AND. !EMPTY(SC5->C5_I_FILFT) .AND. !EMPTY(SC5->C5_I_FLFNC) .AND. SC5->C5_I_FILFT # SC5->C5_I_FLFNC .AND. EMPTY(SC5->C5_I_PDPR+SC5->C5_I_PDFT)//Pedidos de Troca Nota
            //                  Recno do DAK  , Recno do DAI
            AADD(_aPeds_Prod, { _aDAKPVs[P,4] , _aDAKPVs[P,1] , SC5->(RECNO()),;//3-Recno do Pedido de Origem de Troca Nota
            0             })//4-Recno do Pedido de Pallet de Troca Nota caso tenha e seja incluido *
            _lCargaTemAlteracao:=.T.
            //Recno do DAI
            aAdd( _aLog , {.T.,DAK->DAK_FILIAL+" "+DAK->DAK_COD,DAI->DAI_FILIAL+" "+DAI->DAI_PEDIDO,SC5->C5_I_TRCNF,"Gera Troca Nota"    ,STR(_aDAKPVs[P,1]),SC5->C5_I_CARGA,SC5->C5_I_FLFNC,SC5->C5_I_PDPR,SC5->C5_I_FILFT,SC5->C5_I_PDFT} )

         else
            //Recno do DAI
            aAdd( _aLog , {.F.,DAK->DAK_FILIAL+" "+DAK->DAK_COD,DAI->DAI_FILIAL+" "+DAI->DAI_PEDIDO,SC5->C5_I_TRCNF,"NÃO Gera Troca Nota",STR(_aDAKPVs[P,1]),SC5->C5_I_CARGA,SC5->C5_I_FLFNC,SC5->C5_I_PDPR,SC5->C5_I_FILFT,SC5->C5_I_PDFT} )

         EndIf

         IF _lCargaTemAlteracao
            IF ASCAN( _aCargaAcerta, DAK->DAK_COD ) = 0
               AADD( _aCargaAcerta, DAK->DAK_COD )//Lista de Cargas para acertar
               AADD( _aFilFatTrocaNF,{DAK->DAK_COD,SC5->C5_I_FILFT })
            ENDIF
         ENDIF

      NEXT P

      IF _lGeraLog
         U_ITGERARQ( 'Log de Geracao de Pedidos de Troca Nota (M460MARK)' , {" ",'Filial + Carga','Pedido Origem','C5_I_TRCNF','Movimentação','Rcno DAI','Carga SC5','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} , _aLog , "Geracao_Carga_" )
      ENDIF

      PRIVATE _lDeuErro:= .F.//Se der algum Erro
      PRIVATE _lComMSExecAuto:= .F.
      PRIVATE _cArm40:= AllTrim( U_ItGetMv("IT_ARMAZE40","40") )
      _aLog  := {}
      _lOK   := .T.

      IF LEN(_aPeds_Prod) > 0//.T.//Controle para dá DisarmTransaction() e executar o U_ITListBox() dentro BEGIN Transaction

         BEGIN Transaction

            IF LEN(_aPeds_Prod) > 0//.T.//Controle para dá DisarmTransaction() e executar o U_ITListBox() dentro BEGIN Transaction

               // Array que controla os Pedidos de Origem lincados com o Pedidos novos de Carregamento e Pallet
               aLink_POV_PON :={}//Link Pedido Velho Pedido Novo

               Processa( {|| GeraPedCarregamento(_aPeds_Prod)   } ,, "Gerando Pedidos de Carregamento..." )

               Processa( {|| GeraPedFaturamento(_aPeds_Prod) } ,, "Gerando Pedidos de Faturamento..." )

               Processa( {|| LiberaPedCarregamento(aLink_POV_PON)  } ,, "Liberando Pedidos de Carregamento Novos..." )

               IF !_lDeuErro
                  Processa( {|| AcertaCarga(_aCargaAcerta)  } ,, "Acertando Cargas..." )
               ENDIF

            ENDIF

            IF _lDeuErro
               DisarmTransaction()
            ENDIF

            IF LEN(_aLog) > 0 //.AND. _lDeuErro

               IF _lGeraLog
                  U_ITGERARQ( 'Log de Geracao de Pedidos de Troca Nota (M460MARK)' , {" ",'Carga','Pedido Origem','Pedido Gerado','Movimentação','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} , _aLog , "Geracao_Carga_Log_" )
               ENDIF
               _bCancel:=_bOK:=NIL
               IF _lDeuErro
                  _cProblema:="Ocorreram problemas na Geração de Pedidos de Troca Nota, para maiores detalhes veja a Coluna Movimentação."
                  _cSolucao :="Para fechar a tela de Log clique no Botão FECHAR. Todas as Movimentações não poderam ser salvas."
                  _bOK:={|| u_itmsg(_cProblema,'Validação Troca Nota',_cSolucao,1) , .F. }
               ELSE
                  _bCancel := {|oDlg| IF(u_itmsg("Confirma o Cancelamento? Todo o processamento gerado não será salvo!","Confirmação processamento",,1,2,2),(_lRet:=.F. , oDlg:End()),.F.) }
               ENDIF
               _lOK:=U_ITListBox( 'Log de Geracao de Pedidos de Troca Nota (M460MARK)' ,;
                  {" ",'Carga','Pedido Origem','Pedido Gerado','Movimentação','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'},_aLog,.T.,4,,,;
                  { 10,     35,             50,             50,           150,      150,       35,                   65,                   60,                  60,                  60},, _bOK,_bCancel )
            ENDIF

            IF !_lOK .AND. !_lDeuErro//pq se deu erro já fez DisarmTransaction() acima
               DisarmTransaction()
            ENDIF

         END Transaction

      ENDIF//.T.//Controle para dá DisarmTransaction() e executar o U_ITListBox() dentro BEGIN Transaction

      DBSELECTAREA("DAK")


   ELSE

      RETURN .T.

   EndIf

RETURN (_lOK .AND. !_lDeuErro)

/*
===============================================================================================================================
Programa--------: GeraPedCarregamento(_aPeds_Prod)
Autor-----------: Alex Wallauer
Data da Criacao-: 18/08/2016
Descrição-------: Gera de Pedidos de Carregamento Novo
Parametros------: Lista dos pedidos
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
Static Function GeraPedCarregamento(_aPeds_Prod)

   LOCAL _aCabPV,_aItemPV,_aItensPV
   LOCAL _cCliente,_cLoja,_cLocal
   LOCAL _cPedPallOrigem,_cPedCarrOrigem,_lPedPallat,nRecSM0
   LOCAL _nPos,_cTpOper,_Ped
   Local _cMensagem:= ""

   SC5->( DbSetOrder(1) )
   SC6->( DbSetOrder(1) )

   ProcRegua(LEN(_aPeds_Prod))

   FOR _Ped := 1 TO LEN(_aPeds_Prod)

      DAK->( DBGOTO( _aPeds_Prod[_Ped,1] ))
      DAI->( DBGOTO( _aPeds_Prod[_Ped,2] ))
      SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido Carregamento de Origem de Troca Nota

      IncProc("Lendo Pedido: "+DAI->DAI_PEDIDO)

      _aCabPV  :={}
      _aItemPV :={}
      _aItensPV:={}
      _cCliente:="Nao encontrado"
      _cLoja   :=""
      _cLocal  :=""//
      _cTpOper := "20"
      _dDtEnt	 := IF(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT)//Para nao travar a criacao do Pedido de Pallet

      _cPedCarrOrigem:=SC5->C5_NUM
      _cPedPallOrigem:=SC5->C5_I_NPALE
      _lPedPallat   :=(SC5->C5_I_PEDPA == "S" .AND. SC5->C5_I_PEDGE # "S")

      nRecSM0:=SM0->(RECNO())
      SM0->( dbSetOrder(1) )
      SM0->(dbSeek(cEmpAnt + SC5->C5_I_FILFT))
      SA1->( DbSetOrder(3) )//O ms execauto volta a ordem para 1
      IF SA1->(DBSEEK(xFilial("SA1")+SM0->M0_CGC))
         _cCliente:=SA1->A1_COD
         _cLoja   :=SA1->A1_LOJA
      ENDIF
      SM0->(DBGOTO(nRecSM0))

      SC6->( DbSetOrder(1) )
      SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
      _cLocal  := SC6->C6_LOCAL

      lMsErroAuto:=.F.

      IF _lComMSExecAuto
            /*
         //====================================================================================================
         // Monta o cabeçalho do pedido de Carregamento NOVO
         //====================================================================================================
         Aadd( _aCabPV, { "C5_TIPO"	    ,SC5->C5_TIPO    , Nil})//Tipo de pedido
         Aadd( _aCabPV, { "C5_I_OPER"	,_cTpOper        , Nil})//Tipo da operacao
         Aadd( _aCabPV, { "C5_FILIAL"	,SC5->C5_FILIAL  , Nil})//filial
         Aadd( _aCabPV, { "C5_CLIENTE"	,_cCliente       , NiL})//Codigo do cliente
         Aadd( _aCabPV, { "C5_LOJAENT"	,_cLoja			 , NiL})//Loja para entrada
         Aadd( _aCabPV, { "C5_LOJACLI"	,_cLoja          , NiL})//Loja do cliente
         Aadd( _aCabPV, { "C5_EMISSAO"	,date()          , NiL})//Data de emissao
         Aadd( _aCabPV, { "C5_CONDPAG"	,SC5->C5_CONDPAG , NiL})//Codigo da condicao de pagamanto*
         Aadd( _aCabPV, { "C5_TIPLIB"  	,SC5->C5_TIPLIB  , Nil})//Tipo de Liberacao
         Aadd( _aCabPV, { "C5_MOEDA"	    ,SC5->C5_MOEDA   , Nil})//Moeda
         Aadd( _aCabPV, { "C5_LIBEROK"	,SC5->C5_LIBEROK , NiL})//Liberacao Total
         Aadd( _aCabPV, { "C5_TIPOCLI"	,SC5->C5_TIPOCLI , NiL})//Tipo do Cliente
         Aadd( _aCabPV, { "C5_I_NPALE"	,SC5->C5_I_NPALE , NiL})//Numero que originou a pedido de palete
         Aadd( _aCabPV, { "C5_I_PEDPA"	,SC5->C5_I_PEDPA , NiL})//Pedido Refere a um pedido de Pallet
         Aadd( _aCabPV, { "C5_I_DTENT"	,_dDtEnt         , Nil})//Dt de Entrega
         Aadd( _aCabPV, { "C5_I_TRCNF"   ,"S"             , Nil})//Pedido de troca nota
         Aadd( _aCabPV, { "C5_I_FILFT"   ,SC5->C5_I_FILFT , Nil})//Filial de Faturamento
         Aadd( _aCabPV, { "C5_I_FLFNC"   ,SC5->C5_I_FLFNC , Nil})//Filial de Carregamento
         Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})
         Aadd( _aCabPV, { "C5_I_BLPRC"   ,SC5->C5_I_BLPRC , Nil})//

         //====================================================================================================
         // Monta o item do pedido de Carregamento NOVO
         //====================================================================================================

         DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

            _aItemPV:={}
            AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido - NAO TROCAR DE LIGAR
            AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
            AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
            AAdd( _aItemPV , { "C6_UNSVEN"  ,SC6->C6_UNSVEN  , Nil }) // Quantidade Vendida 2 un
            AAdd( _aItemPV , { "C6_QTDVEN"  ,SC6->C6_QTDVEN  , Nil }) // Quantidade Vendida
            AAdd( _aItemPV , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
            AAdd( _aItemPV , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
            AAdd( _aItemPV , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
            AAdd( _aItemPV , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
            AAdd( _aItemPV , { "C6_VALOR"   ,SC6->C6_VALOR   , Nil }) // valor total do item
            AAdd( _aItemPV , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
            AAdd( _aItemPV , { "C6_LOCAL"   ,SC6->C6_LOCAL   , Nil }) // Almoxarifado
            AAdd( _aItemPV , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
            AAdd( _aItemPV , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
            AAdd( _aItemPV , { "C6_I_VLIBP"	,SC6->C6_I_VLIBP , Nil }) // Preco Liberado
            AAdd( _aItemPV , { "C6_I_BLPRC"	,SC6->C6_I_BLPRC , Nil }) // Preco Liberado
            AAdd( _aItensPV ,_aItemPV )

            SC6->( DBSkip() )

         ENDDO
         //====================================================================================================
         // Geração do pedido de Carregamento NOVO
         //====================================================================================================
         MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 3 )
         */
      ELSE//_lComMSExecAuto

         _cMensagem:=M460CriaPV( _aPeds_Prod[_Ped,3] ,_cTpOper,_cCliente,_cLoja,_dDtEnt  )

      ENDIF//_lComMSExecAuto

      If lMsErroAuto

         If ( __lSx8 )
            RollBackSx8()
         EndIf

         IF EMPTY(_cMensagem)
            _cMensagem:=" ["+MostraErro()+"]"
         ENDIF

         SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido de Origem de Troca Nota
         _cMensagem:='Erro ao criar o Novo Pedido de Carregamento'+IF(_lPedPallat," de Pallet","")+_cMensagem

         _cCliente :=_cCliente+" / "+_cLoja+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NREDUZ") )
         // aAdd( _aLog , {" ",'Carga '    ,'Pedido O'     ,'Pedido G'  ,'Movimentacao'                          ,'Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
         aAdd( _aLog , {.F.,DAK->DAK_COD,DAI->DAI_PEDIDO,"Nao gerado",_cMensagem   ,_cCliente,_cLocal ,SC5->C5_I_FLFNC  ,SC5->C5_I_PDPR   ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

         _lDeuErro:=.T.//Se der algum Erro
         LOOP

      Else

         //====================================================================================================
         // Array que controla os Pedidos de Origem lincados com o Pedidos novos de Carregamento e Pallet
         //                    Pedido de Origem, Pedido Novo , Recno Ped Novo , Recno do DAI   , Recnos do SC9 dos Pedido de Origem
         AADD(aLink_POV_PON, { DAI->DAI_PEDIDO , SC5->C5_NUM , SC5->(RECNO()) , DAI->(RECNO()) , {}                                } )//Serve para linkar o pedido de Origem e pedido novo que geradores de pedido de Pallet
         //====================================================================================================

         //====================================================================================================
         // Grava campos de controle NO NOVO PEDIDO de Carregamento
         //====================================================================================================
         _nPos:=0
         SC5->( RecLock( 'SC5' , .F. ) )

         SC5->C5_I_PDFT := _cPedCarrOrigem// Pedido de Carregamento Original
         SC5->C5_I_PDPR := SC5->C5_NUM    // Novo Pedido de Carregamento (codigo do Pedido é o mesmo do que foi gerado)
         SC5->C5_I_CARGA:= DAK->DAK_COD   // Grava o numero da Carga Original para usar mais para frente
         IF (_nPos:=ASCAN(_aCabPV, {|C| C[1]=="C5_I_BLPRC" } )) # 0
            SC5->C5_I_BLPRC:= _aCabPV[ _nPos, 2 ]
         ENDIF
         IF (_nPos:=ASCAN(_aCabPV, {|C| C[1]=="C5_I_BLCRE" } )) # 0
            SC5->C5_I_BLCRE:= _aCabPV[ _nPos , 2 ]
         ENDIF

         IF _lPedPallat .AND. !EMPTY(_cPedPallOrigem) // Se o campo SC5->C5_I_PEDPA = "S" e SC5->C5_I_PEDGE # 'N' e Se nao é branco é pedido de pallet sendo lido
            IF (_nPos:=ASCAN(aLink_POV_PON,{ |L| L[1] == _cPedPallOrigem } )) # 0//Procura o Pedido de Origem que deu origem ao Pedido de Pallet vellho para substituir o novo pedido que referente a esse Pallet

               SC5->C5_I_NPALE := aLink_POV_PON[_nPos,2]//Código do Pedido novo inserido anteriormente
               SC5->C5_I_PEDPA := 'S'//É o Pedido de Pallet //Regrava Por Garantia
               SC5->C5_I_PEDGE := '' //Regrava Por Garantia

            ENDIF
         ENDIF



         SC5->( MsUnlock() )

         IF _lComMSExecAuto

            SC6->( Dbsetorder(1) )
            SC6->( Dbseek( SC5->C5_FILIAL + SC5->C5_NUM ) )
            //Grava liberações de preços nos itens do pedido de carregamento
            DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

               _nLin1:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_ITEM"  } )
               _nItem:=ASCAN(_aItensPV   , {|I| I[_nLin1,2]== SC6->C6_ITEM  } )
               _nLin2:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_I_BLPRC"  } )
               _nLin3:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_I_VLIBP"  } )

               SC6->( RecLock( 'SC6' , .F. ) )
               IF _nItem # 0 .AND. _nLin2 # 0
                  SC6->C6_I_BLPRC := _aItensPV[_nItem,_nLin2, 2 ]
               ENDIF
               IF _nItem # 0 .AND. _nLin3 # 0
                  SC6->C6_I_VLIBP := _aItensPV[_nItem,_nLin3, 2 ]
               ENDIF
               SC6->( MsUnlock() )
               SC6->( DbSkip())

            Enddo

         ENDIF//_lComMSExecAuto

         _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
         _cMensagem:='Gerou o Novo Pedido de Carregamento'+IF(_lPedPallat," de Pallet","")
         //aAdd( _aLog , {" ",'Carga '    ,'Pedido O'     ,'Pedido G'  ,'Movimentacao','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
         aAdd( _aLog , {.T.,DAK->DAK_COD,DAI->DAI_PEDIDO,SC5->C5_NUM ,_cMensagem    ,_cCliente,_cLocal  ,SC5->C5_I_FLFNC  ,SC5->C5_I_PDPR   ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

         //====================================================================================================
         // Grava o LOG de Inclusão do Pedidos de Carregamento Novo
         // Nao gravar LOG quando Troca Nota
           /*_aDadIni := {}				    
           aAdd( _aDadIni , { 'C5_FILIAL'	, SC5->C5_FILIAL	, ''		} )
          aAdd( _aDadIni , { 'C5_NUM'		, SC5->C5_NUM		, ''		} )
          aAdd( _aDadIni , { 'C5_CLIENTE'	, SC5->C5_CLIENTE	, ''		} )
          aAdd( _aDadIni , { 'C5_LOJACLI'	, SC5->C5_LOJACLI	, ''		} )
          aAdd( _aDadIni , { 'C5_EMISSAO'	, date()	, StoD('')	} )
          aAdd( _aDadIni , { 'C5_I_DTENT'	, SC5->C5_I_DTENT	, StoD('')	} )									    
          U_ITGrvLog( _aDadIni , 'SC5' , 1 , SC5->( C5_FILIAL + C5_NUM ) , 'I' , _cusua )*/
          // Grava o LOG de Inclusão de Pedidos para o Pedido de Pallet
          //====================================================================================================
    
          //====================================================================================================
          // Faz a amarração do pedido de carregamento novo com o pedido de Pallet novo
          If _lPedPallat .AND. !Empty( SC5->C5_I_NPALE )//Se o campo SC5->C5_I_PEDPA = "S" e Se nao é branco é pedido de pallet sendo lido
             
             _cPedPallet := SC5->C5_NUM//Código do Pedido de Pallet novo
             If _nPos # 0
                 SC5->( DBGOTO( aLink_POV_PON[_nPos,3] ))//Recno do Pedido novo para ataulizar com o Código do Pedido de Pallet novo
                SC5->( RecLock( 'SC5' , .F. ) )
                SC5->C5_I_NPALE := _cPedPallet//Código do Pedido de Pallet novo granvando no Pedido novo
                 SC5->C5_I_PEDPA := '' 
                SC5->C5_I_PEDGE := 'S' //É o Pedido Gerador de Pallet
                SC5->( MsUnlock() )
             EndIf
             
          EndIf
          // Faz a amarração do pedido de carregamento novo com o pedido de Pallet novo
          //====================================================================================================

       ENDIF 
   
 NEXT _Ped


RETURN .T.

/*
===============================================================================================================================
Programa--------: GeraPedFaturamento(_aPeds_Prod)
Autor-----------: Alex Wallauer
Data da Criacao-: 18/08/2016
Descrição-------: Gera de Pedidos de Faturamento
Parametros------: Lista dos pedidos 
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
*====================================================================================================*
Static Function GeraPedFaturamento(_aPeds_Prod)
  LOCAL _cLocal  :="",_Ped,_nLog,lErroSC9,_nRec
  LOCAL _aRec_SC6:={}
  LOCAL _aLogAux :={}
  LOCAL _aLog2Aux:={}
  LOCAL _cCliente:=_cMensagem:=_cPedidoNovo:=""
  LOCAL _aRec_SC9_POV:={}

  //ESTORNDO DE LIBERACAO DOS PEDIDOS ORIGNAL DE TROCA NOTA
  ///Antes de transferir faz uma alteracao em cada Pedido antigo para estornar a liberacao do pedido (apaga o sc9 e o estoque fica disponivel)
  SC6->( DbSetOrder(1) )
  SC9->( DbSetOrder(1) )
  ProcRegua(LEN(_aPeds_Prod))

 FOR _Ped := 1 TO LEN(_aPeds_Prod)

   DAK->( DBGOTO( _aPeds_Prod[_Ped,1] ))
   DAI->( DBGOTO( _aPeds_Prod[_Ped,2] ))
   SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido de Origem de Troca Nota

   IncProc("Lendo Pedido: "+SC5->C5_NUM)

   _lPedPallat:=(SC5->C5_I_PEDPA == "S" .AND. SC5->C5_I_PEDGE # "S")
   _cPedidoNovo:=""
   IF (_nPos:=ASCAN(aLink_POV_PON,{ |L| L[1] == SC5->C5_NUM } )) # 0//Procura o Pedido de Origem Para pegar o pedido novo, serve para os Pedidos de troca nota e Pedidos de Pallet
      _cPedidoNovo := aLink_POV_PON[_nPos,2]//Código do Pedido novo
   ENDIF

   //====================================================================================================
   // Limpa a carga do DAI para nao dar mensagem de erro customizada no estorno da liberacao
   //====================================================================================================
   DAI->(RECLOCK("DAI",.F.))
   DAI->DAI_PEDIDO := ""
   DAI->(MSUNLOCK())


   IF _lComMSExecAuto
            /*
         //====================================================================================================
         // Limpa a carga do SC9 para nao dar mensagem de erro padrao no estorno da liberacao
         //====================================================================================================
         SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
         DO While SC9->( !EOF() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == SC5->C5_FILIAL + SC5->C5_NUM

            SC9->( RecLock('SC9',.F.) )
            SC9->C9_CARGA:=""
            SC9->C9_SEQCAR:=""
            SC9->C9_SEQENT:=""
            SC9->( MsUnlock() )
            SC9->( DBSkip() )

         ENDDO

         //============================  Alteração do pedido de Carregamento para liberar o estoque ===============================================//
         _aCabPV  :={}
         _aItemPV :={}
         _aItensPV:={}
         _dDtEnt	 := IF(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT)//Para nao travar a criacao do Pedido de Pallet

         //====================================================================================================
         // Monta o cabeçalho do pedido
         //====================================================================================================
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
         Aadd( _aCabPV, { "C5_I_DTENT"	,_dDtEnt         , Nil})//Dt de Entrega
         Aadd( _aCabPV, { "C5_I_TRCNF"   ,SC5->C5_I_TRCNF , Nil})
         Aadd( _aCabPV, { "C5_I_BLPRC"   ,SC5->C5_I_BLPRC , Nil})
         Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})
         Aadd( _aCabPV, { "C5_I_FILFT"   ,SC5->C5_I_FILFT , Nil})
         Aadd( _aCabPV, { "C5_I_FLFNC"   ,SC5->C5_I_FLFNC , Nil})
         Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})

         //====================================================================================================
         // Monta o item do pedido
         //====================================================================================================
         SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

         _cLocal  :=SC6->C6_LOCAL
         _aRec_SC6:={}

         DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

            AADD(_aRec_SC6, SC6->( RECNO() ) )

            _aItemPV:={}

            AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
            AAdd( _aItemPV , { "C6_NUM"    	,SC6->C6_NUM	 , Nil })
            AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
            AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
            AAdd( _aItemPV , { "C6_UNSVEN"  ,SC6->C6_UNSVEN  , Nil }) // Quantidade Vendida 2 un
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
            AAdd( _aItemPV , { "C6_I_VLIBP"	,SC6->C6_I_VLIBP , Nil }) // Preco Liberado

            AAdd( _aItensPV ,_aItemPV )

            SC6->( DBSkip() )

         ENDDO
         //====================================================================================================
         // Alteração do pedido de Carregamento para liberar o estoque
         //====================================================================================================
         lMsErroAuto:=.F.

         MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 4 )

         SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido de Origem de Troca Nota
         _cCliente   :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )

         lErroSC9:=.F.
         SC9->( DbSetOrder(1) )
         If lMsErroAuto .OR. ( lErroSC9:=SC9->( DBSeek( SC5->C5_FILIAL+SC5->C5_NUM ) ))//Se liberou o estoque nao pode achar no SC9, portanto se char é um erro

            IF lErroSC9
               _cMensagem:="Erro ao Estornar a liberação do pedido de Faturamento"+IF(_lPedPallat," de Pallet","")+", ainda tem dados de liberacao (SC9)."
            ELSE
               _cMensagem:=" ["+MostraErro()+"]"
               _cMensagem:='Erro ao Estornar a liberação do pedido de Faturamento'+IF(_lPedPallat," de Pallet","")+_cMensagem
            ENDIF

            //  aAdd( _aLog , {" ",'Carga '    ,'Pedido O' ,'Pedido G'  ,'Movimentacao','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
            aAdd( _aLog , {.F.,DAK->DAK_COD,SC5->C5_NUM,_cPedidoNovo,_cMensagem    ,_cCliente,_cLocal  ,SC5->C5_I_FLFNC      ,_cPedidoNovo       ,SC5->C5_I_FILFT     ,SC5->C5_NUM} )

            _lDeuErro:=.T.//Se der algum Erro
            LOOP

         Else

            SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido Carregamento de Origem de Troca Nota
            SC5->( RecLock( 'SC5' , .F. ) )
            IF (_nPos:=ASCAN(_aCabPV, {|C| C[1]=="C5_I_BLPRC" } )) # 0
               SC5->C5_I_BLPRC:= _aCabPV[ _nPos, 2 ]
            ENDIF
            IF (_nPos:=ASCAN(_aCabPV, {|C| C[1]=="C5_I_BLCRE" } )) # 0
               SC5->C5_I_BLCRE:= _aCabPV[ _nPos , 2 ]
            ENDIF
            SC5->( MsUnlock() )

            SC6->( Dbsetorder(1) )
            SC6->( Dbseek( SC5->C5_FILIAL + SC5->C5_NUM ) )
            //Grava liberações de preços nos itens do pedido de carregamento
            DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

               _nLin1:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_ITEM"  } )
               _nItem:=ASCAN(_aItensPV   , {|I| I[_nLin1,2]== SC6->C6_ITEM  } )
               _nLin2:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_I_BLPRC"  } )
               _nLin3:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_I_VLIBP"  } )

               SC6->( RecLock( 'SC6' , .F. ) )
               IF _nItem # 0 .AND. _nLin2 # 0
                  SC6->C6_I_BLPRC := _aItensPV[_nItem,_nLin2, 2 ]
               ENDIF
               IF _nItem # 0 .AND. _nLin3 # 0
                  SC6->C6_I_VLIBP := _aItensPV[_nItem,_nLin3, 2 ]
               ENDIF
               SC6->( MsUnlock() )
               SC6->( DbSkip())

            Enddo

            _cMensagem:='Estornou a liberação do pedido de Faturamento'+IF(_lPedPallat," de Pallet","")

            //  aAdd( _aLog , {" ",'Carga '    ,'Pedido O' ,'Pedido G'  ,'Movimentacao','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
            aAdd( _aLog , {.T.,DAK->DAK_COD,SC5->C5_NUM,_cPedidoNovo,_cMensagem    ,_cCliente,_cLocal  ,SC5->C5_I_FLFNC      ,_cPedidoNovo         ,SC5->C5_I_FILFT     ,SC5->C5_NUM         } )

         Endif
         */
   ELSE//IF _lComMSExecAuto

         _aRec_SC6:={}
         SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
         DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

            AADD(_aRec_SC6, SC6->( RECNO() ) )
            SC6->( DBSkip() )

         ENDDO

         _aRec_SC9_POV:={}
         SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
         DO While SC9->( !EOF() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == SC5->C5_FILIAL + SC5->C5_NUM

            AADD(_aRec_SC9_POV, SC9->(RECNO()) )
            SC9->( DBSkip() )

         ENDDO

         IF (_nPos:=ASCAN(aLink_POV_PON,{ |L| L[1] == SC5->C5_NUM } )) # 0//Procura o Pedido de Origem
            aLink_POV_PON[_nPos,5]:=ACLONE(_aRec_SC9_POV)//Recnos do SC9 dos Pedido de Origem
         ENDIF

   ENDIF//IF _lComMSExecAuto
   //============================  Alteração do pedido de Carregamento para liberar o estoque ===============================================//
   //=========================================  TRANSFERINDO DE FILIAL ===================================================================//
   SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido Carregamento de Origem de Troca Nota
   SC5->( RecLock( 'SC5' , .F. ) )
   SC5->C5_FILIAL := SC5->C5_I_FILFT
   SC5->C5_I_PDFT := SC5->C5_NUM  // Pedido de Origem (codigo é o mesmo só que na filial de faturamento agora)
   SC5->C5_I_PDPR := _cPedidoNovo // Código do Pedido novo de Carregamento
   SC5->C5_I_CARGA:= DAK->DAK_COD // Grava o numero da Carga de Origem para usar mais para frente
   SC5->( MsUnlock() )

   FOR _nRec := 1 to LEN(_aRec_SC6)

         SC6->( DBGOTO( _aRec_SC6[_nRec] ))//Recno do Pedido de Origem de Troca Nota
         SC6->( RecLock( 'SC6' , .F. ) )
         SC6->C6_FILIAL := SC5->C5_I_FILFT
         SC6->C6_LOCAL  := _cArm40
         SC6->C6_TES    := ""
         SC6->C6_QTDEMP := 0//Zera pq foi tranferido sem estornar a liberação
         SC6->C6_QTDEMP2:= 0//Zera pq foi tranferido sem estornar a liberação
         SC6->( MsUnlock() )

   NEXT _nRec
   _cLocal   :=SC6->C6_LOCAL
   _cMensagem:='Transferencia do pedido de Faturamento'+IF(_lPedPallat," de Pallet","")
   _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )

   //  aAdd( _aLog    , {" ",'Carga '    ,'Pedido O' ,'Pedido G'  ,'Movimentacao','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
   aAdd( _aLogAux , {.T.,DAK->DAK_COD,SC5->C5_NUM,_cPedidoNovo,_cMensagem    ,_cCliente,_cLocal  ,SC5->C5_I_FLFNC      ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

   //====================================================================================================
   // Grava o LOG de traferencia do Pedidos Novo
   // Nao gravar LOG quando Troca Nota
   /*		
   _aDadIni := {}				    
   aAdd( _aDadIni , { 'C5_FILIAL'	, SC5->C5_FILIAL	, ''		} )
   aAdd( _aDadIni , { 'C5_NUM'		, SC5->C5_NUM		, ''		} )
   aAdd( _aDadIni , { 'C5_CLIENTE'	, SC5->C5_CLIENTE	, ''		} )
   aAdd( _aDadIni , { 'C5_LOJACLI'	, SC5->C5_LOJACLI	, ''		} )
   aAdd( _aDadIni , { 'C5_EMISSAO'	, SC5->C5_EMISSAO	, StoD('')	} )
   aAdd( _aDadIni , { 'C5_I_DTENT'	, SC5->C5_I_DTENT	, StoD('')	} )									    
   U_ITGrvLog( _aDadIni , 'SC5' , 1 , SC5->( C5_FILIAL + C5_NUM ) , 'T' , _cusua ) */
   // Grava o LOG de traferencia do Pedidos Novo
   //====================================================================================================
    //=====================================================================================================================================//
    //=========================================  TRANSFERINDO DE FILIAL ===================================================================//
    //=====================================================================================================================================//
    //================================ ALTERA A TES DO PEDIDO DEPOIS DE TRENFERIR =========================================================//
    SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido Transferido de Troca Nota 
    _cSalvaFil:=cFilAnt
   cFilAnt   :=SC5->C5_I_FILFT 
    _dDtEnt	  := IF(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT)//Para nao travar a criacao do Pedido de Pallet
    _nRecSM0  :=SM0->(RECNO())
    SM0->(DBSEEK("01"+cFilAnt))
    lMsErroAuto:=.F.
   SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
    _cLocal  := SC6->C6_LOCAL

    IF _lComMSExecAuto/*
   _aCabPV  :={}
   _aItemPV :={}
   _aItensPV:={}
    //====================================================================================================
   // Monta o cabeçalho do pedido
   //====================================================================================================
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
   Aadd( _aCabPV, { "C5_I_DTENT"	,_dDtEnt         , Nil})//Dt de Entrega
   Aadd( _aCabPV, { "C5_I_TRCNF"   ,SC5->C5_I_TRCNF , Nil})
   Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})
   Aadd( _aCabPV, { "C5_I_BLPRC"   ,SC5->C5_I_BLPRC , Nil})
   Aadd( _aCabPV, { "C5_I_FILFT"   ,SC5->C5_I_FILFT , Nil})
   Aadd( _aCabPV, { "C5_I_FLFNC"   ,SC5->C5_I_FLFNC , Nil})

   //====================================================================================================
   // Monta o item do pedido
   //====================================================================================================
   
   DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
      
      _aItemPV:={}
      AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
      AAdd( _aItemPV , { "C6_NUM"    	,SC6->C6_NUM	 , Nil })
      AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
      AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
      AAdd( _aItemPV , { "C6_UNSVEN"  ,SC6->C6_UNSVEN  , Nil }) // Quantidade Vendida 2 un
      AAdd( _aItemPV , { "C6_QTDVEN"  ,SC6->C6_QTDVEN  , Nil }) // Quantidade Vendida
      AAdd( _aItemPV , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
      AAdd( _aItemPV , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
      AAdd( _aItemPV , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
      AAdd( _aItemPV , { "C6_LOJA"   	,SC6->C6_LOJA	 , Nil })
      AAdd( _aItemPV , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
      AAdd( _aItemPV , { "C6_VALOR"   ,SC6->C6_VALOR   , Nil }) // valor total do item
      AAdd( _aItemPV , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
      AAdd( _aItemPV , { "C6_LOCAL"   ,SC6->C6_LOCAL   , Nil }) // Almoxarifado
      AAdd( _aItemPV , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
      AAdd( _aItemPV , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
      AAdd( _aItemPV , { "C6_PEDCLI" 	,SC6->C6_PEDCLI	 , Nil })
      AAdd( _aItemPV , { "C6_I_BLPRC"	,SC6->C6_I_BLPRC , Nil })
      AAdd( _aItemPV , { "C6_I_VLIBP"	,SC6->C6_I_VLIBP , Nil }) // Preco Liberado 

      AAdd( _aItensPV ,_aItemPV )
       
        SC6->( DBSkip() )
      
   ENDDO
   //====================================================================================================
   // Alteração da TES do pedido de Faturamento
   //====================================================================================================	

   MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 4 )
    */
    ELSE//IF _lComMSExecAuto

       _cMensagem:=M460AltPV( _aPeds_Prod[_Ped,3] )    

    ENDIF//IF _lComMSExecAuto

    SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido de Origem de Troca Nota 
   _cCliente   :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )

    lErroSC9:=.F.
    SC9->( DbSetOrder(1) )
    If lMsErroAuto .OR. ( lErroSC9:=SC9->( DBSeek( SC5->C5_FILIAL+SC5->C5_NUM ) ))//Se liberou o estoque nao pode achar no SC9, portanto se char é um erro
      
       IF lErroSC9
          _cMensagem:="Erro ao Alterar a TES do pedido de Faturamento"+IF(_lPedPallat," de Pallet","")+", ainda tem dados de liberacao (SC9). " 
       ELSE
          IF EMPTY(_cMensagem)
           _cMensagem:=" ["+MostraErro()+"]"
         ENDIF
        _cMensagem:='Erro ao Alterar a TES do pedido de Faturamento '+IF(_lPedPallat," de Pallet ","")+_cMensagem 
       ENDIF

       //dd( _aLog   , {" ",'Carga '    ,'Pedido O' ,'Pedido G'  ,'Movimentacao','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
      aAdd(_aLog2Aux, {.F.,DAK->DAK_COD,SC5->C5_NUM,_cPedidoNovo,_cMensagem    ,_cCliente,_cLocal  ,SC5->C5_I_FLFNC      ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

       cFilAnt:=_cSalvaFil
        SM0->(DBGOTO(_nRecSM0))
        
      _lDeuErro:=.T.//Se der algum Erro
      LOOP
      
   Else//lMsErroAuto

       IF _lComMSExecAuto
           /*
           SC5->( DBGOTO( _aPeds_Prod[_Ped,3] ))//Recno do Pedido Carregamento de Origem de Troca Nota 
           SC5->( RecLock( 'SC5' , .F. ) )
           IF (_nPos:=ASCAN(_aCabPV, {|C| C[1]=="C5_I_BLPRC" } )) # 0
              SC5->C5_I_BLPRC:= _aCabPV[ _nPos, 2 ]
           ENDIF
           IF (_nPos:=ASCAN(_aCabPV, {|C| C[1]=="C5_I_BLCRE" } )) # 0
              SC5->C5_I_BLCRE:= _aCabPV[ _nPos , 2 ]
           ENDIF
              SC5->( MsUnlock() )
           
           SC6->( Dbsetorder(1) )
           SC6->( Dbseek( SC5->C5_FILIAL + SC5->C5_NUM ) )
           //Grava liberações de preços nos itens do pedido de carregamento
           DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

               _nLin1:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_ITEM"  } ) 
               _nItem:=ASCAN(_aItensPV   , {|I| I[_nLin1,2]== SC6->C6_ITEM  } ) 
               _nLin2:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_I_BLPRC"  } ) 
               _nLin3:=ASCAN(_aItensPV[1], {|I| I[1]== "C6_I_VLIBP"  } ) 
           
              SC6->( RecLock( 'SC6' , .F. ) )
               IF _nItem # 0 .AND. _nLin2 # 0
                 SC6->C6_I_BLPRC := _aItensPV[_nItem,_nLin2, 2 ]
              ENDIF
               IF _nItem # 0 .AND. _nLin3 # 0
                  SC6->C6_I_VLIBP := _aItensPV[_nItem,_nLin3, 2 ]
              ENDIF
              SC6->( MsUnlock() )
              SC6->( DbSkip())
                 
           Enddo
            */
       ENDIF//_lComMSExecAuto

      _cMensagem:='Alterada a TES do pedido de Faturamento'+IF(_lPedPallat," de Pallet","")
      //dd( _aLog   , {" ",'Carga '    ,'Pedido O' ,'Pedido G'  ,'Movimentacao','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
       aAdd(_aLog2Aux, {.T.,DAK->DAK_COD,SC5->C5_NUM,_cPedidoNovo,_cMensagem    ,_cCliente,_cLocal  ,SC5->C5_I_FLFNC      ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

    Endif//lMsErroAuto

    cFilAnt:=_cSalvaFil
     SM0->(DBGOTO(_nRecSM0))

    //================================ ALTERA A TES DO PEDIDO DEPOIS DE TRENFERIR =========================================================//

 NEXT _Ped

 FOR _nLog := 1 TO LEN(_aLogAux)
     AADD( _aLog , _aLogAux[_nLog] )
 NEXT _nLog
 
 FOR _nLog := 1 TO LEN(_aLog2Aux)
     AADD( _aLog , _aLog2Aux[_nLog] )
 NEXT _nLog

RETURN .T.

/*
===============================================================================================================================
Programa--------: LiberaPedCarregamento(aLink_POV_PON)
Autor-----------: Alex Wallauer
Data da Criacao-: 18/08/2016
Descrição-------: Libera Pedidos de Carregamento Novos
Parametros------: Lista dos pedidos
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
*====================================================================================================*
Static Function LiberaPedCarregamento(aLink_POV_PON)
   LOCAL _Ped,_cLocal,_nQtdLib,_cCliente,_cPedOrigem,_cMensagem,_nC9
   LOCAL lErroSC9:=.F.

   SC6->( DbSetOrder(1) )
   SC9->( DbSetOrder(1) )

   ProcRegua(LEN(aLink_POV_PON))

   FOR _Ped := 1 TO LEN(aLink_POV_PON)

      SC5->( DBGOTO( aLink_POV_PON[_Ped,3] ))//Recno do Pedido Novo de Troca Nota
      DAI->( DBGOTO( aLink_POV_PON[_Ped,4] ))


      _lPedPallat:=(SC5->C5_I_PEDPA == "S" .AND. SC5->C5_I_PEDGE # "S")

      IncProc("Lendo Pedido: "+SC5->C5_NUM)

      IF _lComMSExecAuto
         //====================================================================================================
         // Liberacão de Pedido - reserva de estoque
         //====================================================================================================
         SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

         _cLocal    :=SC6->C6_LOCAL
         lMsErroAuto:=.F.

         DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

            IF !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
               _nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO
            ELSE
               _nQtdLib := SC9->C9_QTDLIB
            ENDIF

            IF _nQtdLib # SC6->C6_QTDVEN
               lMsErroAuto:=.T.
               EXIT
            ENDIF

            SC6->( DBSkip() )

         ENDDO

         _cCliente  :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
         _cPedOrigem:=aLink_POV_PON[_Ped,1]

         lBloqEstoque:=lBloqCredito:=lErroSC9:=.F.
         If lMsErroAuto .OR. ( lErroSC9:=Ver_SC9(SC5->C5_FILIAL+SC5->C5_NUM) )

            IF lErroSC9
               _cMensagem:='Erro ao liberar o Pedido Novo de Carregamento'+IF(_lPedPallat," de Pallet","")+", com Bloqueio de"+IF(lBloqEstoque," Estoque","")+IF(lBloqCredito," Credito","")+" - Item: "+SC9->C9_PRODUTO
            ELSE
               _cMensagem:='Erro ao liberar o Pedido Novo de Carregamento'+IF(_lPedPallat," de Pallet","")
            ENDIF

            // aAdd( _aLog , {" ",'Carga '    ,'Pedido O' ,'Pedido G'  ,'Movimentacao'                          ,'Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
            aAdd( _aLog , {.F.,DAI->DAI_COD,_cPedOrigem,SC5->C5_NUM ,_cMensagem   ,_cCliente,_cLocal ,SC5->C5_I_FLFNC  ,SC5->C5_I_PDPR   ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

            _lDeuErro:=.T.//Se der algum Erro
            LOOP

         Else

            _cMensagem:='Liberou Pedido Novo de Carregamento'+IF(_lPedPallat," de Pallet","")
            // aAdd( _aLog , {" ",'Carga '    ,'Pedido O' ,'Pedido G'  ,'Movimentacao','Cliente','Armazem','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
            aAdd( _aLog , {.T.,DAI->DAI_COD,_cPedOrigem,SC5->C5_NUM ,_cMensagem    ,_cCliente,_cLocal  ,SC5->C5_I_FLFNC  ,SC5->C5_I_PDPR   ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

         Endif

      ENDIF//IF _lComMSExecAuto
      //====================================================================================================
      // Colocando o novo pedido na carga
      //====================================================================================================
      SC5->( DBGOTO( aLink_POV_PON[_Ped,3] ))//Recno do Pedido Novo de Troca Nota
      DAI->( DBGOTO( aLink_POV_PON[_Ped,4] ))

      DAI->(RECLOCK("DAI",.F.))
      DAI->DAI_PEDIDO := SC5->C5_NUM
      DAI->DAI_CLIENT := SC5->C5_CLIENTE
      DAI->DAI_LOJA   := SC5->C5_LOJACLI
      DAI->DAI_PESO   := SC5->C5_I_PESBR
      DAI->(MSUNLOCK())

      IF _lComMSExecAuto
         //====================================================================================================
         // Colocando a carga no SC9 do novo pedido
         //====================================================================================================
         SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

         DO While SC9->( !EOF() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == SC5->C5_FILIAL + SC5->C5_NUM

            SC9->( RecLock('SC9',.F.) )
            SC9->C9_CARGA := DAI->DAI_COD
            SC9->C9_SEQCAR:= DAI->DAI_SEQCAR
            SC9->C9_SEQENT:= DAI->DAI_SEQUEN
            SC9->( MsUnlock() )
            SC9->( DBSkip() )

         ENDDO

      ELSE//IF _lComMSExecAuto

         _aRec_SC9_POV:=aLink_POV_PON[_Ped,5]//Recnos do SC9 dos Pedido de Origem

         FOR _nC9 := 1 TO LEN(_aRec_SC9_POV)

            SC9->( DBGOTO( _aRec_SC9_POV[_nC9] ) )
            SC9->( RecLock('SC9',.F.) )
            SC9->C9_PEDIDO := SC5->C5_NUM
            SC9->C9_CLIENTE:= SC5->C5_CLIENTE
            SC9->C9_LOJA   := SC5->C5_LOJACLI
            SC9->( MsUnlock() )

         NEXT _nC9

      ENDIF//IF _lComMSExecAuto

   NEXT _Ped

RETURN .T.

/*
===============================================================================================================================
Programa--------: AcertaCarga(_aCargaAcerta)
Autor-----------: Alex Wallauer
Data da Criacao-: 18/08/2016
Descrição-------: Acerta a Capa das Cargas
Parametros------: Lista das Cargas
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
   *====================================================================================================*
Static Function AcertaCarga(_aCargaAcerta)
   *====================================================================================================*
   LOCAL _nTotPeso :=0,_nCa
   LOCAL _nTotValor:=0

   ProcRegua(LEN(_aCargaAcerta))

   SC6->( DbSetOrder(1) )
   DAK->( DbSetOrder(1) )
   DAI->( DbSetOrder(1) )

   FOR _nCa := 1 TO LEN(_aCargaAcerta)

      IncProc("Acertando Carga: "+_aCargaAcerta[_nCa])

      IF DAK->(DBSEEK(xFilial()+_aCargaAcerta[_nCa])) .AND.;
           DAI->(DBSEEK(DAK->DAK_FILIAL+DAK->DAK_COD))

         _nTotPeso :=0
         _nTotValor:=0

         DO While DAI->( !EOF() ) .AND. DAI->DAI_FILIAL+DAI->DAI_COD == DAK->DAK_FILIAL+DAK->DAK_COD

            _nTotPeso += DAI->DAI_PESO

            SC6->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
            DO While SC6->( !EOF() ) .AND. SC6->C6_FILIAL+SC6->C6_NUM == DAI->DAI_FILIAL+DAI->DAI_PEDIDO
               _nTotValor += SC6->C6_VALOR
               SC6->( DBSkip() )
            ENDDO
            DAI->( DBSkip() )

         ENDDO

         DAK->(RECLOCK("DAK",.F.))
         DAK->DAK_PESO  := _nTotPeso
         DAK->DAK_VALOR := _nTotValor
         IF DAK->(FIELDPOS( "DAK_I_TRNF" )) > 0
            DAK->DAK_I_TRNF:= "C"                    //Preencher o campo com C (Tem troca nota e é filial de carregamento)
            DAK->DAK_I_FITN:= _aFilFatTrocaNF[_nCa,2]//Filial de faturamento do troca nota (C5_I_FILFT Filial para onde os pedidos de faturamento foram transferidos)
            DAK->DAK_I_INCC:= "N"                    //Preencher com N
            DAK->DAK_I_INCF:= "N"                    //Preencher com N
          ENDIF

         DAK->(MSUNLOCK())

      ENDIF
 
   NEXT _nCa

RETURN .T.


/*
===============================================================================================================================
Programa--------: Ver_SC9(cChave)
Autor-----------: Alex Wallauer
Data da Criacao-: 30/08/2016
Descrição-------: Verefica se no SC9 esta tudo OK
Parametros------: cChave: Filia + Pedido
Retorno---------: Lógico (.F.) Se tudo OK (.T.) Se deu erro
===============================================================================================================================
*/
   *====================================================================================================*
Static Function Ver_SC9(cChave)
   *====================================================================================================*
   LOCAL _lErroSC9:=.F.//Não Tem erro

   SC9->( DbSetOrder(1) )
   IF !SC9->( DBSeek( cChave ) )
      _lErroSC9:=.T.
   ENDIF

   DO While SC9->( !EOF() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == cChave

      IF (lBloqEstoque:=!EMPTY(SC9->C9_BLEST)) .OR. !EMPTY(SC9->C9_BLCRED)
         lBloqCredito:=!EMPTY(SC9->C9_BLCRED)
         _lErroSC9:=.T.//Tem erro
         EXIT
      ENDIF

      SC9->( DBSkip() )

   ENDDO

RETURN _lErroSC9
/*
===============================================================================================================================
Programa--------: M460CriaPV()
Autor-----------: Alex Wallauer
Data da Criacao-: 06/01/2017
Descrição-------: Cria PV sem execauto
Parametros------: nRecSC5,_cTpOper,_cCliente,_cLoja,_dDtEnt 
Retorno---------: Mensagem de erro
===============================================================================================================================
*/   
*====================================================================================================*
Static Function M460CriaPV( nRecSC5,_cTpOper,_cCliente,_cLoja,_dDtEnt )
 LOCAL nInc
 LOCAL nRecSalva:= 0
 Local cSeek    := ""
 Local bWhile,_nX
 Local aNoFields:= NIL
 Local _bValidTES:= AVSX3('C6_TES    ',7)
 Local _cFilTabTrans := U_ITGETMV( 'IT_FILTBTRF' , "40" ) //Filiais que vão buscar a tabela de tranferecia

 SC5->( DBGOTO( nRecSC5 ))//Recno do Pedido Origem
 cSeek := xFilial("SC6")+SC5->C5_NUM
 bWhile:= {|| SC6->C6_FILIAL+SC6->C6_NUM }

 For nInc := 1 To SC5->(FCount())
    M->&(SC5->(FieldName(nInc))) := SC5->(FieldGet(nInc))
 Next nInc

 aHeader:={}
 aCols:={}
 FillGetDados(4,"SC6",1,cSeek,bWhile,,aNoFields)

 //Variavel usada nas funcões chamadas do valid e gatilhos dos camapos abaixo
 l410Auto:=.T.
 aAutoCab:={}
 aGets:={}
 aTela:={}
 IF SC5->(FIELDPOS("C5_I_CLITN")) <> 0//Gravando no pedido de transferência, criado automaticamente pelo processo de troca de notas, dois campos para armazenar o código do cliente/loja do pedido de faturamento.
    M->C5_I_CLITN:=M->C5_CLIENTE
    M->C5_I_LOJTN:=M->C5_LOJACLI
 ENDIF
 //Variavel usada nas funcões chamadas do valid e gatilhos dos camapos abaixo
 M->C5_NUM    := SPACE(LEN(SC5->C5_NUM))//GetSXENum("SC5","C5_NUM","  \DATA\"+RETSQLNAME("SC5"),24)
 M->C5_I_DTENT:=_dDtEnt //Dt de Entrega
 M->C5_I_OPER :=_cTpOper //Tipo da operacao
 M->C5_CLIENTE:=_cCliente//Codigo do cliente
 M->C5_CLIENT :=_cCliente//Codigo do cliente
 M->C5_LOJAENT:=_cLoja  //Loja para entrada
 M->C5_LOJACLI:=_cLoja  //Loja do cliente
 M->C5_I_ENVRD:= "N"//Pedido de Faturamento de troca não será enviado para o RDC
 
 IF M->C5_I_OPER = "20"//Limpa os campo se o pedido for DA OPERACAO TRIANGULAR
    M->C5_I_OPTRI:=""
    M->C5_I_PVREM:=""
    M->C5_I_PVFAT:="" 
    M->C5_I_CLIEN:="" 
    M->C5_I_LOJEN:=""
 ENDIF
 
 __ReadVar := "M->C5_I_OPER"
 n := 1
 IF !VldUser('C5_I_OPER')
    lMsErroAuto:=.T.
    RETURN " [Tipo da operação invalida: "+_cTpOper+"]"
 ENDIF

 //_bValidSX3:=AVSX3("C5_CLIENTE",7)
 //IF !EVAL(_bValidSX3)
 __ReadVar := "M->C5_CLIENTE"
 IF !VldUser("C5_CLIENTE")
    lMsErroAuto:=.T.
    RETURN " [Cliente invalido: "+_cCliente+" "+_cLoja+"]"
 ENDIF
 
 If ExistTrigger("C5_CLIENTE")
    n := 1
    RunTrigger(1,Nil,Nil,,"C5_CLIENTE")
 Endif
 
 IF FindFunction("U_AOMS089")
    M->C5_NUM:=U_AOMS089(.F.)//Aqui nessa função já tem U_ITConout´s
 ELSE
    M->C5_NUM:=GetSXENum("SC5","C5_NUM","  \DATA\"+RETSQLNAME("SC5"),24)
 ENDIF
 SC5->( DbSetOrder(1) )
 IF SC5->(DBSEEK(xFilial("SC5")+M->C5_NUM))
    SC5->( DBGOTO( nRecSC5 ))//Recno do Pedido Origem
    lMsErroAuto:=.T.
    RETURN " [Sistema gerou um numero de PV que já existe: "+M->C5_NUM+"]"
 ENDIF   

 SC5->(RECLOCK("SC5",.T.))
 AvReplace("M", "SC5") 
 SC5->(MSUNLOCK())
 
 nRecSalva :=SC5->(RECNO())//Recno do Pedido NOVO
 _nPosItem :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_ITEM'   } )
 _nPosTES  :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_TES'    } )
 _nPosClas :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CLASFIS'} )
 _nPosLan  :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CODLAN' } )
 _nPosCF   :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CF'     } )
 _nPosProd :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == "C6_PRODUTO"} )
 _nPosPRCV :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == "C6_PRCVEN"} )
 _nPosPRUN :=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == "C6_PRUNIT"} )
 
 Z09->( dbsetorder(3) ) // Z09_FILIAL+Z09_FILORI+Z09_FILDES+Z09_CODOPE+Z09_CODPRO   
 //_cTeste:=""
 For _nX := 1 To Len( aCols )
   n:=_nX 
   M->C6_TES:=aCols[n,_nPosTES]
   __ReadVar :='M->C6_TES'
   IF !EVAL(_bValidTES)
      lMsErroAuto:=.T.
      RETURN " [Item / TES invalida: "+aCols[n,_nPosItem]+" / "+aCols[n,_nPosTES]+"]"
   ENDIF
   
   IF  M->C5_I_FILFT $ _cFilTabTrans .AND. M->C5_I_OPER = "20"

        If (Z09->(DBSEEK(xFilial("Z09")+M->C5_I_FLFNC+M->C5_I_FILFT+M->C5_I_OPER+aCols[n][_nPosProd] )) .OR.;
            Z09->(DBSEEK(xFilial("Z09")+SPACE(LEN(M->C5_I_FLFNC+M->C5_I_FILFT+M->C5_I_OPER))+aCols[n][_nPosProd] )) ) .AND.;
         (DATE() >= Z09->Z09_INIVIG .AND. DATE() <= Z09->Z09_FIMVIG)
         
            //_cTeste+="Item "+aCols[n,_nPosItem]+": Preco alterado DE "+ALLTRIM(STR(aCols[n,_nPosPRCV],15,5))+" P/ "+ALLTRIM(STR(Z09->Z09_PRECO,15,5))+" / Chave: "+Z09->(Z09_FILIAL+Z09_FILORI+Z09_FILDES+Z09_CODOPE+Z09_CODPRO)+CRLF
            
         M->C6_PRCVEN:=Z09->Z09_PRECO
         aCols[n,_nPosPRCV]:=M->C6_PRCVEN
         __ReadVar :="C6_PRCVEN"
         If ExistTrigger("C6_PRCVEN")
            RunTrigger(2,_nX,nil,,"C6_PRCVEN")
         EndIf
         
         M->C6_PRUNIT:=Z09->Z09_PRECO
         aCols[n,_nPosPRUN]:=M->C6_PRUNIT
      
      ELSE
            //_cTeste+=" [Item "+aCols[n,_nPosItem]+": Preco da tabela de tranferencia invalido / Chave: "+xFilial("Z09")+M->C5_I_FLFNC+M->C5_I_FILFT+M->C5_I_OPER+aCols[n][_nPosProd]+CRLF
         lMsErroAuto:=.T.
         RETURN " [Item "+aCols[n,_nPosItem]+": Preço da tabela de tranferencia invalido: "+DTOC(Z09->Z09_INIVIG)+" - "+DTOC(Z09->Z09_FIMVIG)+"]"
      ENDIF

   ENDIF
 NEXT _nX

 //_cTeste:=STRTRAN(_cTeste,".",",")
 //_cFileNome:="c:\smartclient\M460MARK_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"
 //MemoWrite(_cFileNome,_cTeste)
 
 SC5->( DBGOTO( nRecSC5 ))//Recno do Pedido Origem
 SC6->( DbSetOrder(1) )
 SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
 
 DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
      
   nRecSC6:=SC6->(RECNO())
   For nInc := 1 To SC6->(FCount())
       M->&(SC6->(FieldName(nInc))) := SC6->(FieldGet(nInc))
   Next nInc

   _nLinha       := ASCAN( aCols,{|x| x[_nPosItem] == SC6->C6_ITEM } )
   M->C6_NUM     := M->C5_NUM
   M->C6_CLI     := M->C5_CLIENTE
   M->C6_LOJA    := M->C5_LOJACLI
   M->C6_TES     := aCols[_nLinha,_nPosTES]
   M->C6_CODLAN  := aCols[_nLinha,_nPosLan]
   M->C6_CF		 := aCols[_nLinha,_nPosCF] 
   M->C6_PRCVEN  := aCols[_nLinha,_nPosPRCV]
   M->C6_PRUNIT	 := aCols[_nLinha,_nPosPRUN]
   M->C6_COMIS5  := 0
   M->C6_I_PDESC := 0
 
   M->C6_CLASFIS := Posicione("SB1",1,xFilial("SB1")+M->C6_PRODUTO,"B1_ORIGEM")+Posicione("SF4",1,M->C6_FILIAL+M->C6_TES,"F4_SITTRIB")

   //_cTeste+="Item SC6 "+SC6->C6_ITEM+": Preco alterado DE "+ALLTRIM(STR(SC6->C6_PRCVEN,15,5))+" P/ "+ALLTRIM(STR(M->C6_PRCVEN,15,5))+CRLF
   
   SC6->(RECLOCK("SC6",.T.))
   AvReplace("M","SC6") 
   SC6->(MSUNLOCK())
   SC6->( DBGOTO( nRecSC6 ))
   SC6->( DBSkip() )
      
 ENDDO

 Confirmsx8(.F.)

 SC5->( DBGOTO( nRecSalva ))//Recno do Pedido NOVO

RETURN ""
/*
===============================================================================================================================
Programa--------: M460AltPV()
Autor-----------: Alex Wallauer
Data da Criacao-: 06/01/2017
Descrição-------: Altera PV sem execauto
Parametros------: nRecSC5
Retorno---------: Mensagem de erro
===============================================================================================================================
*/
Static Function M460AltPV( nRecSC5 )

   Local _nX		:= 0
   Local cSeek     := ""
   Local bWhile    := NIL
   Local aNoFields := NIL
   Local _nPosProd := _nPosItem := _nPosTES := _nPosClas := _nPosLan := 0
   Local _bValidTES:= AVSX3('C6_TES    ',7)
   Local nInc		:= 0

   SC5->( DBGOTO( nRecSC5 ))//Recno do Pedido
   cSeek := xFilial("SC6")+SC5->C5_NUM
   bWhile:= {|| SC6->C6_FILIAL+SC6->C6_NUM }

   For nInc := 1 To SC5->(FCount())
      M->&(SC5->(FieldName(nInc))) := SC5->(FieldGet(nInc))
   Next nInc
   M->C5_LIBEROK := " "//Limpa a liberação pq não tem SC9
   M->C5_I_ENVRD := "N"//Pedido de Faturamento de troca não será enviado para o RDC
   aHeader:={}
   aCols:={}
   FillGetDados(4,"SC6",1,cSeek,bWhile,,aNoFields)

    //Variavel usada nas funcões chamadas do valid e gatilhos dos camapos abaixo
   l410Auto:=.T.
   aAutoCab:={}
   aGets:={}
   aTela:={}
    //Variavel usada nas funcões chamadas do valid e gatilhos dos camapos abaixo

   __ReadVar := "M->C5_I_OPER"
   n := 1
   IF !VldUser('C5_I_OPER')
      lMsErroAuto:=.T.
      RETURN " [Tipo da operação invalida: "+M->C5_I_OPER+"]"
   ENDIF


   SC5->(RECLOCK("SC5",.F.))
   AvReplace("M", "SC5")
   SC5->(MSUNLOCK())

   _nPosProd := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_PRODUTO'} )
   _nPosItem := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_ITEM'   } )
   _nPosTES  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_TES'    } )
   _nPosClas := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CLASFIS'} )
   _nPosLan  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CODLAN' } )
   _nPosLoc  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_LOCAL'  } )
   _nPosCF   := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CF'     } )
   __ReadVar := 'M->C6_TES'

   For _nX := 1 To Len( aCols )
      n:=_nX
      M->C6_TES:=aCols[n,_nPosTES]
      IF !EVAL(_bValidTES)
         lMsErroAuto:=.T.
         IF EMPTY(M->C6_TES)
            RETURN " [Não encontrou TES para o Produto / Armazem: "+AllTrim(aCols[n,_nPosProd])+" / "+aCols[n,_nPosLoc]+ " - Filial: " + SC5->C5_FILIAL + " - Operação: " + SC5->C5_I_OPER + " - Pedido: " + SC5->C5_NUM + " - Cliente: " + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + "]"
         ELSE
            RETURN " [Item / TES invalida: "+aCols[n,_nPosItem]+" / "+aCols[n,_nPosTES]+ " - Filial: " + SC5->C5_FILIAL + " - Operação: " + SC5->C5_I_OPER + " - Pedido: " + SC5->C5_NUM + " - Cliente: " + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + "]"
         ENDIF
      ENDIF
       If ExistTrigger('C6_TES    ')
          RunTrigger(2,_nX,nil,,'C6_TES    ')
       EndIf
   NEXT _nX

   SC6->( DbSetOrder(1) )
   SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

   DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

      nRecSC6:=SC6->(RECNO())
      For nInc := 1 To SC6->(FCount())
         M->&(SC6->(FieldName(nInc))) := SC6->(FieldGet(nInc))
      Next nInc

      IF (_nLinha:= ASCAN( aCols,{|x| x[_nPosItem] == SC6->C6_ITEM } )) <> 0
         M->C6_TES    := aCols[_nLinha,_nPosTES]
         M->C6_CLASFIS:= aCols[_nLinha,_nPosClas]
         M->C6_CODLAN := aCols[_nLinha,_nPosLan]
         M->C6_CF	   := aCols[_nLinha,_nPosCF]
      ENDIF

      M->C6_CC:=U_ACOM034G()

      SC6->(RECLOCK("SC6",.F.))
      AvReplace("M","SC6")
      SC6->(MSUNLOCK()) 
      //Atualiza SB2 se TES movimenta estoque
      //Pode ser desligado por parâmetro se der problemas de lock no processo real
      SF4->(Dbsetorder(1))
      If u_itgetmv("IT_ATUB2",.T.) .AND. SF4->( DBSeek( xFilial('SF4') + SC6->C6_TES ) ) .AND. SF4->F4_ESTOQUE == "S"

         SB2->(Dbsetorder(1))
         IF SB2->(Dbseek( SC6->C6_FILIAL + SC6->C6_PRODUTO + SC6->C6_LOCAL))

            Reclock("SB2",.F.)
            SB2->B2_QPEDVEN := SB2->B2_QPEDVEN + SC6->C6_QTDVEN
            SB2->B2_QPEDVE2 := SB2->B2_QPEDVE2 + SC6->C6_UNSVEN
            SB2->(Msunlock())

         Endif

      Endif

      SC6->( DBGOTO( nRecSC6 ))
      SC6->( DBSkip() )

   ENDDO

   SC5->( DBGOTO( nRecSC5 ))//Recno do Pedido

RETURN ""

/*
===============================================================================================================================
Programa--------: IT_VLDCRE
Autor-----------: Josué Danich prestes
Data da Criacao-: 26/05/2017
Descrição-------: Validação de crédito dos pedidos da carga
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T./.F.) - Define se o faturamento será processado
===============================================================================================================================
*/
Static Function IT_VLDCRE( _cMarcado , _lInverte )

   Local _aRetCre  := {}
   Local _lblq2    := .T.
   Local _alog     := {}  , P
   Local _cchep 	:= alltrim(GetMV("IT_CCHEP"))


    //====================================================================================================
    // Verificação do faturamento com base em Cargas
    //====================================================================================================
   If IsInCallStack("MATA460B")

      //Valida crédito do pedido
      SC5->(Dbsetorder(1))
      FOR P := 1 TO LEN(_aDAKPVs)

         DAI->(DBGOTO( _aDAKPVs[P,1] ) )

         If SC5->(Dbseek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))


            //Garante que peso vai estar preenchido
            If SC5->C5_I_PESBR == 0

               _npossc6 := SC6->(Recno())
               _aSC6 := SC6->(Getarea())
               SC6->(Dbsetorder(1))
               If SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

                  _npesbru := 0
                  Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM

                     SB1->(Dbsetorder(1))
                     If SB1->(DbSeek(xfilial("SB1")+SC6->C6_PRODUTO))
                        _npesbru += (SC6->C6_QTDVEN * SB1->B1_PESBRU)
                     Endif

                     SC6->(Dbskip())

                  Enddo

               Endif
               SC6->(Restarea(_aSC6))
               SC6->(Dbgoto(_npossc6))

               If _npesbru > 0

                  Reclock("SC5", .F.)
                  SC5->C5_I_PESBR := _npesbru
                  SC5->(Msunlock())

               Endif

            Endif


            If  SC5->C5_TIPO = 'N' .AND. Empty(SC5->C5_NOTA)  //Impede revalidação de crédito de pedidos já faturados em faturamento parcial de carga

               _nTotPV:=0
               _lValCredito:=.T.

               SC6->(Dbsetorder(1))
               SC6->(Dbgotop())
               SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

               Do while SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL


                  _nTotPV += SC6->C6_VALOR

                  If SC6->C6_PRODUTO == _cchep .OR. SC6->C6_CF $ '5910/6910/5911/6911'//NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
                     _lValCredito:=.F.
                     EXIT
                  ENDIF

                  If posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
                     _lValCredito:=.F.
                     EXIT
                  Endif

                  If posicione("ZAY",1,xfilial("ZAY")+ SC6->C6_CF ,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
                     _lValCredito:=.F.
                     EXIT
                  Endif

                  SC6->(DbSkip())

               Enddo

               IF _lValCredito

                  _aRetCre := U_ValidaCredito( _nTotPV , SC5->C5_CLIENTE , SC5->C5_LOJACLI , .T. , , , , SC5->C5_MOEDA,,SC5->C5_NUM)
                  _cBlqCred:=_aRetCre[1]
                  aadd(_alog,{SC5->C5_FILIAL,DAI->DAI_COD,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),_Aretcre[1]})

                  If _aRetCre[2] = "B"//Se bloqueou

                     _lBlq2:= .F.
                     SC5->(Reclock("SC5",.F.))
                     SC5->C5_I_DTAVA := DATE()
                     SC5->C5_I_HRAVA := TIME()
                     SC5->C5_I_USRAV := cusername
                     SC5->C5_I_MOTBL := _cBlqCred
                     If SC5->C5_I_BLCRE # "R"
                        SC5->C5_I_BLCRE:= "B"
                     Endif
                     SC5->(Msunlock())

                  EndIf

                  //Verifica e bloqueia se for bonificação sem liberação
                  If SC5->C5_I_BLOQ != "L" .and. SC5->C5_I_OPER = '10'

                     aadd(_alog,{SC5->C5_FILIAL,DAI->DAI_COD,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"Bonificação sem liberação de faturamento"})
                     _lBlq2:= .F.

                  Endif

                  //Verifica e bloqueia se tiver bloqueio de preço
                  If SC5->C5_I_BLPRC == "B" .OR. SC5->C5_I_BLPRC == "R"

                     aadd(_alog,{SC5->C5_FILIAL,DAI->DAI_COD,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"Pedido com bloqueio de preço"})
                     _lBlq2:= .F.

                  Endif


               Else

                  aadd(_alog,{SC5->C5_FILIAL,DAI->DAI_COD,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"Não precisa de análise de crédito"})

               ENDIF

               U_ENVSITPV(,.T.) //Envia interface de situação do pedido para o RDC

            ENDIF

         Endif

      NEXT P

      //Se falhou liberação de crédito apresenta tela de informações
      If !_lblq2
         U_ITListBox( 'Relação de Pedidos que não podem ser faturados! (M460MARK)' ,;
            {"Filial","Carga","Pedido","Cliente","Nome","Resultado da Analise"} , _aLog , .T. , 1 , 'Análise de crédito dos pedidos: ',,;
            { 20     ,     30,      30,       30,    150,                   200} )
      Endif

   ElseIF IsInCallStack("MATA460A") //Faturamento por pedido de vendas

      SC5->(Dbsetorder(1))
      SC6->(Dbsetorder(1))
      FOR P := 1 TO LEN(_aC9Pedidos)//  ********** POR PEDIDO

         SC9->(DBGOTO( _aC9Pedidos[P,1] ) )
         //Valida crédito do pedido

         If SC5->(Dbseek( SC9->C9_FILIAL+SC9->C9_PEDIDO ))


            //Garante que peso vai estar preenchido
            If SC5->C5_I_PESBR == 0

               _npossc6 := SC6->(Recno())
               _aSC6 := SC6->(Getarea())
               SC6->(Dbsetorder(1))
               If SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

                  _npesbru := 0
                  Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM

                     SB1->(Dbsetorder(1))
                     If SB1->(DbSeek(xfilial("SB1")+SC6->C6_PRODUTO))
                        _npesbru += (SC6->C6_QTDVEN * SB1->B1_PESBRU)
                     Endif

                     SC6->(Dbskip())

                  Enddo

               Endif
               SC6->(Dbgoto(_npossc6))
               SC6->(Restarea(_aSC6))

               If _npesbru > 0

                  Reclock("SC5", .F.)
                  SC5->C5_I_PESBR := _npesbru
                  SC5->(Msunlock())

               Endif

            Endif
         */

            If  SC5->C5_TIPO = 'N'

               _nTotPV:=0
               _lValCredito:=.T.

               SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

               Do while SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL


                  _nTotPV += SC6->C6_VALOR

                  If !empty(alltrim(SC9->C9_NFISCAL)) //Já está faturado
                     _lValCredito:=.F.
                     EXIT
                  ENDIF

                  If SC6->C6_PRODUTO == _cchep .OR. SC6->C6_CF $ '5910/6910/5911/6911'//NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
                     _lValCredito:=.F.
                     EXIT
                  ENDIF

                  If posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
                     _lValCredito:=.F.
                     EXIT
                  Endif

                  If posicione("ZAY",1,xfilial("ZAY")+ SC6->C6_CF ,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
                     _lValCredito:=.F.
                     EXIT
                  Endif

                  SC6->(DbSkip())

               Enddo

               IF _lValCredito

                  _aRetCre := U_ValidaCredito( _nTotPV , SC5->C5_CLIENTE , SC5->C5_LOJACLI , .T. , , , , SC5->C5_MOEDA,,SC5->C5_NUM)
                  _cBlqCred:=_aRetCre[1]

                  AADD(_alog,{SC5->C5_FILIAL,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),_Aretcre[1]})

                  Reclock("SC5",.F.)

                  If _aRetCre[2] = "B"//Se bloqueou

                     If SC5->C5_I_BLCRE == "R"

                        _lBlq2			:= .F.
                        SC5->C5_I_BLCRE	:= "R"
                        SC5->C5_I_DTAVA := DATE()
                        SC5->C5_I_HRAVA := TIME()
                        SC5->C5_I_USRAV := cusername
                        SC5->C5_I_MOTBL := _cBlqCred


                     Else

                        _lBlq2			:= .F.
                        SC5->C5_I_BLCRE	:= "B"
                        SC5->C5_I_DTAVA := DATE()
                        SC5->C5_I_HRAVA := TIME()
                        SC5->C5_I_USRAV := cusername
                        SC5->C5_I_MOTBL := _cBlqCred

                     Endif


                  EndIf

                  SC5->C5_I_MOTBL := _cBlqCred//Sempre grava a descrição
                  SC5->(Msunlock())

                  //Verifica e bloqueia se for bonificação sem liberação
                  If SC5->C5_I_BLOQ != "L" .and. SC5->C5_I_OPER = '10'

                     aadd(_alog,{SC5->C5_FILIAL,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"Bonificação sem liberação de faturamento"})
                     _lBlq2:= .F.

                  Endif

                  //Verifica e bloqueia se tiver bloqueio de preço
                  If SC5->C5_I_BLPRC == "B" .OR. SC5->C5_I_BLPRC == "R"

                     aadd(_alog,{SC5->C5_FILIAL,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"Pedido com bloqueio de preço"})
                     _lBlq2:= .F.

                  Endif


               Else

                  AADD(_alog,{SC5->C5_FILIAL,SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"Não precisa de análise de crédito"})

               ENDIF

               U_ENVSITPV(,.T.) //Envia interface de situação do pedido para o RDC

            ENDIF

         Endif

      NEXT P

      //Se falhou liberação de crédito apresenta tela de informações
      If !_lblq2
         U_ITListBox( 'Relação de Pedidos que não podem ser faturados! (M460MARK)' ,;
            {"Filial","Pedido","Cliente","Nome","Resultado da Analise"} , _aLog , .F. , 1 , 'Análise de crédito dos pedidos: ',,;
            { 20     ,      30,       30,    85,                   200} )
      Endif

   EndIf

Return( _lblq2)


/*
===============================================================================================================================
Programa--------: IT_CriaTemp(_cMarcado,_lInverte)
Autor-----------: Alex Wallauer
Data da Criacao-: 29/09/2017
Descrição-------: Função responsável para Criação da tabela Temporaria dos PV marcados
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
Static Function IT_CriaTemp(_cMarcado,_lInverte)

   LOCAL _cQuery:="" , _lRet := .T.
   LOCAL _cCEFATARM:= U_ItGetMv("IT_CEFATARM","")//36,50,52
   LOCAL _cCargas:=""

   _aStaC9Locais := {}//STATICA DO PROGRAMA

   If AllTrim( Upper( FunName() ) ) == 'MATA460A' //Faturamento por pedido
      _aC9Pedidos:={}
      _aC9PVItens:={}

      _cQuery := " SELECT R_E_C_N_O_ REC_SC9 , SC9.C9_PEDIDO "
      _cQuery += " FROM  "+ RetSqlName('SC9') +" SC9 "
      _cQuery += " WHERE "+ RetSqlCond('SC9')
      If _lInverte
         _cQuery += _cfiltro + " AND SC9.C9_OK <> '"+ AllTrim(_cMarcado) +"' "
      Else
         _cQuery += " AND SC9.C9_OK  = '"+ AllTrim(_cMarcado) +"' "
      EndIf
      _cQuery += " ORDER BY SC9.C9_FILIAL, SC9.C9_PEDIDO "

      If Select(_cAliasSC9) > 0
         (_cAliasSC9)->( DBCloseArea() )
      EndIf

      DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,_cQuery) , _cAliasSC9 , .F. , .T. )

      (_cAliasSC9)->( DBGoTop() )
      DO While (_cAliasSC9)->( !EOF() )

         IF ASCAN(_aC9Pedidos,{ |P| P[2] == (_cAliasSC9)->C9_PEDIDO} ) = 0
            AADD(_aC9Pedidos,{ (_cAliasSC9)->REC_SC9 , (_cAliasSC9)->C9_PEDIDO} )//  ********** POR PEDIDO
            _cCargas+=(_cAliasSC9)->C9_PEDIDO+","
         ENDIF

         AADD(_aC9PVItens,{ (_cAliasSC9)->REC_SC9 , (_cAliasSC9)->C9_PEDIDO} )//  ********** POR ITEM

         SC9->(DBGOTO((_cAliasSC9)->REC_SC9))
         IF ASCAN(_aC9Locais, {|P| P[1] == SC9->C9_PRODUTO .AND. P[2] == SC9->C9_LOCAL} )  <> 0//SE JÁ TIVER NA LISTA  NÃO PRECISA TESTAR NADA
            (_cAliasSC9)->( DBSKIP() )
            LOOP
         ENDIF
         IF !SC9->C9_LOCAL $ _cCEFATARM
            (_cAliasSC9)->( DBSKIP() )
            LOOP
         ENDIF
         If !SC6->(Dbseek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO ))//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
            (_cAliasSC9)->( DBSKIP() )
            LOOP
         ENDIF
         _cEst:=Upper( AllTrim( Posicione( "SF4" , 1 , xFilial("SF4") + SC6->C6_TES , "F4_ESTOQUE" ) ) )
         IF _cEst <> "S"
            (_cAliasSC9)->( DBSKIP() )
            LOOP
         ENDIF

         AADD(_aC9Locais, { SC9->C9_PRODUTO , SC9->C9_LOCAL ,""}  )//  ********** POR ITEM + ARMAZEM

         (_cAliasSC9)->( DBSKIP() )
      ENDDO

      _lRet :=  (LEN(_aC9PVItens) > 0)

   ELSE
      _aDAKCargas:={}
      _aDAKPVs:={}

      _cQuery := " SELECT DAK.R_E_C_N_O_ REC_DAK , DAI.R_E_C_N_O_ REC_DAI , DAI.DAI_COD, DAI.DAI_PEDIDO "
      _cQuery += " FROM  "+ RetSqlName('DAI') +" DAI , "+ RetSqlName('DAK') +" DAK "
      _cQuery += " WHERE "
      If _linverte
         _cQuery += " DAK_OK <> '"+_cMarcado+"' " + _cfiltro
      Else
         _cQuery += " DAK_OK = '"+_cMarcado+"'"
      Endif
      _cQuery += " AND DAK_FILIAL = '"+xFilial('DAK')+"'"
      _cQuery += " AND "+ RetSqlDel('DAI')+" AND "+ RetSqlDel('DAK')
      _cQuery += " AND DAK_FEZNF <> '1' "
      _cQuery += " AND DAI_FILIAL = DAK.DAK_FILIAL  "
      _cQuery += " AND DAI_NFISCA = ' ' " //Só valida itens que ainda não foram faturados
      _cQuery += " AND DAI.DAI_COD = DAK.DAK_COD "
      _cQuery += " AND DAI.DAI_SEQCAR = DAK.DAK_SEQCAR "
      _cQuery += " ORDER BY DAI.DAI_FILIAL, DAI.DAI_COD, DAI.DAI_PEDIDO "
      If Select(_cAliasDAI) > 0
         (_cAliasDAI)->( DBCloseArea() )
      EndIf
      DBUseArea( .T. , "TOPCONN" , TCGENQRY( ,, _cQuery ) , _cAliasDAI , .F. , .T. )

      (_cAliasDAI)->( DBGoTop() )
      DO While (_cAliasDAI)->( !EOF() )

         IF ASCAN(_aDAKCargas,{ |P| P[2] == (_cAliasDAI)->DAI_COD} ) = 0
            AADD(_aDAKCargas,{ (_cAliasDAI)->REC_DAI , (_cAliasDAI)->DAI_COD} )//  ********** POR CARGA
            _cCargas+=(_cAliasDAI)->DAI_COD+","
         ENDIF

         AADD(_aDAKPVs,{ (_cAliasDAI)->REC_DAI , (_cAliasDAI)->DAI_COD , (_cAliasDAI)->DAI_PEDIDO , (_cAliasDAI)->REC_DAK } )//  **********  POR PEDIDO
         DAI->(DBGOTO((_cAliasDAI)->REC_DAI))
         IF SC9->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO  ) ) )
            Do while SC9->C9_FILIAL+SC9->C9_PEDIDO == DAI->DAI_FILIAL+DAI->DAI_PEDIDO .AND. SC9->( !EOF() )

               AADD(_aC9PVItens,{ SC9->(RECNO()) , SC9->C9_PEDIDO } )//  ********** POR ITEM

               //IF ASCAN(_aC9Locais, SC9->C9_LOCAL) <> 0//SE JÁ TIVER NA LISTA  NÃO PRECISA TESTAR NADA
               IF ASCAN(_aC9Locais, {|P| P[1] == SC9->C9_PRODUTO .AND. P[2] == SC9->C9_LOCAL} )  <> 0//SE JÁ TIVER NA LISTA  NÃO PRECISA TESTAR NADA
                  SC9->( Dbskip() )
                  LOOP
               ENDIF
               IF !SC9->C9_LOCAL $ _cCEFATARM
                  SC9->( Dbskip() )
                  LOOP
               ENDIF
               If !SC6->(Dbseek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO ))//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
                  SC9->( Dbskip() )
                  LOOP
               ENDIF
               _cEst:=Upper( AllTrim( Posicione( "SF4" , 1 , xFilial("SF4") + SC6->C6_TES , "F4_ESTOQUE" ) ) )
               IF _cEst <> "S"
                  SC9->( Dbskip() )
                  LOOP
               ENDIF

               AADD(_aC9Locais, { SC9->C9_PRODUTO , SC9->C9_LOCAL , "" }  )//  ********** POR ITEM + ARMAZEM

               SC9->( Dbskip() )

            Enddo
         ENDIF

         (_cAliasDAI)->( DBSKIP() )
      ENDDO

      _lRet := (LEN(_aDAKPVs) > 0)

   ENDIF

   If !_lRet
      U_ITMSG("inconsistência nos dados das cargas selecionas",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
      "Validação da Selecao","Estorne as cargas e refaça novemente ou entre em contato com a area de TI",1 )

   ELSE
      IF LEN(_aC9Locais) > 0
         _aC9Locais[1,3]:= LEFT(_cCargas,(LEN(_cCargas)-1))
         _aStaC9Locais  := ACLONE(_aC9Locais)
      ENDIF
   ENDIF

RETURN _lRet


/*
===============================================================================================================================
Programa--------: IT_Ger_Pallets
Autor-----------: Alex Wallauer
Data da Criacao-: 14/01/2019
Descrição-------: Geração de Pedidos de pallets
Parametros------: _cMarcado
Retorno---------: Lógico  (.T.) Se tudo OK  (.F.) Se deu erro
===============================================================================================================================
*/
Static Function IT_Ger_Pallets(_cMarcado)

   Local _aArea     := GetArea()  , P  , L
   Local _aAreaSC5	 := GetArea("SC5")
   Local _aAreaSF2	 := GetArea("SF2")
   Local _aAreaDAI	 := GetArea("DAI")
   Local _TipoC     := "1"
   Local _lRet      := .T.
   Local _nRecPedido:= 0
   Local _cCodPedPallet:=""
   PRIVATE _aLogGerPal := {}
    //====================================================================================================
    // Somente EXECUTA se a chamada for executada pela rotina de faturamento de pedidos avulsos
    //====================================================================================================
   If IsInCallStack("MATA460A")

      SF2->(Dbsetorder(1))
      SA1->(Dbsetorder(1))
      SD1->(Dbsetorder(1))
      SC5->(Dbsetorder(1))
      DAI->(Dbsetorder(4))//DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR

      FOR P := 1 TO LEN(_aC9Pedidos)//  ********** POR PEDIDO

         SC9->(DBGOTO( _aC9Pedidos[P,1] ) )
         SC5->(Dbseek( SC9->C9_FILIAL+SC9->C9_PEDIDO ))

         IF SC5->C5_I_NFSED <> "S"
            LOOP
         ENDIF

         IF SC5->(FIELDPOS("C5_I_PVREF")) = 0 .OR. EMPTY(SC5->C5_I_PVREF)
            LOOP
         ENDIF

         SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE+SC5->C5_LOJACLI ) )
         _nRecPedido:=SC5->(RECNO())
         _cCodPedPallet:=SC5->C5_I_NPALE
         If !EMPTY(_cCodPedPallet) .AND. SC5->( DbSeek( xFilial("SC5") + _cCodPedPallet ) )//Se acho é pq já tem Pedido de Pallet vinculado
            AADD(_aLogGerPal,{SC9->C9_FILIAL,SC9->C9_PEDIDO,SC5->C5_I_NFREF+" "+SC5->C5_I_SERNF,"","",SA1->A1_COD+" "+SA1->A1_LOJA+"-"+Alltrim(SA1->A1_NREDUZ),"PV já tem Pedido de Pallet: "+_cCodPedPallet})
            LOOP
         ENDIF
         SC5->(DBGOTO( _nRecPedido ) )

         IF SC5->(FIELDPOS("C5_I_QTPA")) = 0 .OR. EMPTY(SC5->C5_I_QTPA)
            AADD(_aLogGerPal,{SC9->C9_FILIAL,SC9->C9_PEDIDO,SC5->C5_I_NFREF+" "+SC5->C5_I_SERNF,"","",SA1->A1_COD+" "+SA1->A1_LOJA+"-"+Alltrim(SA1->A1_NREDUZ),"PV não tem Quantidade de Pallet"})
            LOOP
         ENDIF

         _nTotValor:=0
         SC6->( DbSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
         DO While SC6->( !EOF() ) .AND. SC6->C6_FILIAL+SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM
            _nTotValor += SC6->C6_VALOR
            SC6->( DBSkip() )
         ENDDO

         IF Select("TRBPED") = 0
            Os200CriaTrb()//Cria "TRBPED"
         ENDIF

         TRBPED->(DBAPPEND())
         TRBPED->PED_MARCA  :="XX"
         TRBPED->PED_GERA   :="S"
         TRBPED->PED_PEDIDO :=SC9->C9_PEDIDO
         TRBPED->PED_I_OBPE :=SC5->C5_I_OBPED
         TRBPED->PED_I_AGEN :=SC5->C5_I_AGEND
         TRBPED->PED_CODCLI :=SC5->C5_CLIENTE
         TRBPED->PED_LOJA   :=SC5->C5_LOJACLI
         TRBPED->PED_NOME   :=Alltrim( SA1->A1_NREDUZ )
         TRBPED->PED_PESO   :=SC5->C5_I_PESBR
         TRBPED->PED_I_TIPC :=_TipoC//"1-Pallet Chep"
         TRBPED->PED_I_QTPA  :=SC5->C5_I_QTPA//DAI->DAI_I_QTPA
         TRBPED->PED_VALOR  :=_nTotValor
         TRBPED->PED_RECDAI :=SC5->(RECNO())

      NEXT P

      _lGerouOK:=.T.//Variavel preenchida dentro da função U_OM200Tela()
      If Select("TRBPED") > 0  .AND. TRBPED->(LASTREC()) > 0 //Se tem  algum PV marcado para gerar PALLET

         _aLogAux   :=ACLONE(_aLogGerPal)//Salva conteudo caso tenha
         _aLogGerPal:={}  //Limpa. Variavel preenchida dentro da função U_OM200Tela() caso tenha erro
            //     lEfetiva_Pre_Carga , _lPreCarga , _lScheduller , _lSoGeraPallet
         U_OM200Tela(     .T.           , .F.        , .T.          , .T.           )

         SC9->( DBSetOrder(1) )
         If LEN(_aLogGerPal) > 0//Se teve erro ou Gerou
            FOR L := 1 TO LEN(_aLogGerPal)


               _cMensagem:=_aLogGerPal[L,4]
               IF _aLogGerPal[L,1]//Se .T. Gerou o PP

                  _CPVPallet:=_aLogGerPal[L,3]

                  _cMensagem+=": "+ALLTRIM(_CPVPallet)//Numero do Pedido de Pallet

                  IF SC9->( DBSeek( xFilial("SC9") + _CPVPallet ) )
                     SC9->( RecLock( 'SC9' , .F. ) )
                     SC9->C9_OK := _cMarcado
                     SC9->( MsUnlock() )
                  ENDIF
               ENDIF

               SC5->(DBGOTO( _nRecPedido ) )
               SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE+SC5->C5_LOJACLI ) )
               SF2->(DBORDERNICKNAME("IT_I_PEDID"))
               SF2->(Dbseek(SC5->C5_FILIAL+SC5->C5_I_PVREF))


               AADD(_aLogAux,{SC5->C5_FILIAL,SC5->C5_NUM,SF2->F2_DOC+" "+SF2->F2_SERIE,SF2->F2_I_PEDID,SF2->F2_CARGA,SA1->A1_COD+" "+SA1->A1_LOJA+"-"+Alltrim(SA1->A1_NREDUZ),_cMensagem})//Atualiza com o erro
            NEXT L
         ENDIF

         _aLogGerPal:={}//Limpa
         _aLogGerPal:=ACLONE(_aLogAux)//Só Volta o conteudo anterior

      ENDIF

      If LEN(_aLogGerPal) > 0 //.AND. !_lGerouOK
         U_ITListBox( 'Resultado da Geração dos Pedidos do Pallet! (M460MARK)' ,;
            {"Filial","Pedido","NF Origem","PV Origem","Carga Ori","Cliente","Resultado"} , _aLogGerPal , .F. , 1 , 'Resultado da Geração de PP: ',,;
            {      15,      30,         30,         30,         30,      100,        100} )
         _lRet := .T.//Não gerar o Pedido de Pallet não impede de gerar a Nota
      ENDIF

      If Select("TRBPED") > 0
         TRBPED->(Dbclosearea())
      ENDIF

   EndIf

   RestArea(_aArea   )
   RestArea(_aAreaSC5)
   RestArea(_aAreaSF2)
   RestArea(_aAreaDAI)

Return( _lRet )

/*
===============================================================================================================================
Programa----------: Os200CriaTrb() // Copiado do rdmake OM200MNU.PRW
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2016
Descrição---------: Função copiada do Padrão
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
//****************************************************************************//
Static Function Os200CriaTrb()// Copiado do rdmake OM200MNU.PRW
   Local aRetPE    := {}
   Local aCampos   := {}

   AAdd( aCampos ,{"PED_MARCA"  ,"C" ,2 ,0} )
   AAdd( aCampos ,{"PED_GERA"   ,"C" ,1 ,0} )
   AAdd( aCampos ,{"PED_ROTA"   ,"C" ,6 ,0} )
   AAdd( aCampos ,{"PED_ZONA"   ,"C" ,6 ,0} )
   AAdd( aCampos ,{"PED_SETOR"  ,"C" ,6 ,0} )
   AAdd( aCampos ,{"PED_SEQROT" ,"C" ,6 ,0} )
   AAdd( aCampos ,{"PED_PEDIDO" ,"C" ,6 ,0} )
   AAdd( aCampos ,{"PED_ITEM"   ,"C" ,2 ,0} )
   AAdd( aCampos ,{"PED_SEQLIB" ,"C" ,2 ,0} )
   AAdd( aCampos ,{"PED_RECDAI" ,"N" ,10,0} )
   AAdd( aCampos ,{"PED_FILORI" ,"C" ,LEN(DAK->DAK_FILIAL)		,0}							)
   AAdd( aCampos ,{"PED_FILCLI" ,"C" ,LEN(DAK->DAK_FILIAL)		,0}							)
   AAdd( aCampos ,{"PED_CODCLI" ,"C" ,TamSx3("A1_COD")[1]		,TamSx3("A1_COD")[2]}		)
   AAdd( aCampos ,{"PED_LOJA"   ,"C" ,TamSx3("A1_LOJA")[1]	,TamSx3("A1_LOJA")[2]}		)
   AAdd( aCampos ,{"PED_NOME"   ,"C" ,30						,0}							)
   AAdd( aCampos ,{"PED_PESO"   ,"N" ,TamSx3("DAK_PESO")[1]	,TamSx3("DAK_PESO")[2]}		)
   AAdd( aCampos ,{"PED_CARGA"  ,"C" ,6						,0}							)
   AAdd( aCampos ,{"PED_SEQSET" ,"C" ,6						,0}							)
   AAdd( aCampos ,{"PED_SEQORI" ,"C" ,6						,0}							)
   AAdd( aCampos ,{"PED_VALOR"  ,"N" ,TamSx3("DAK_VALOR")[1]	,TamSx3("DAK_VALOR")[2]}	)
   AAdd( aCampos ,{"PED_VOLUM"  ,"N" ,TamSx3("DAK_CAPVOL")[1]	,TamSx3("DAK_CAPVOL")[2]}	)
   AAdd( aCampos ,{"PED_ENDPAD" ,"C" ,15						,0}							)
   AAdd( aCampos ,{"PED_BAIRRO" ,"C" ,30						,0}							)
   AAdd( aCampos ,{"PED_MUN"    ,"C" ,15						,0}							)
   AAdd( aCampos ,{"PED_EST"    ,"C" ,2						,0}							)
   AAdd( aCampos ,{"PED_CEP"    ,"C" ,TamSx3("A1_CEP")[1]		,TamSx3("A1_CEP")[2]}		)
   AAdd( aCampos ,{"PED_QTDLIB" ,"N" ,14						,2}							)
   AAdd( aCampos ,{"TRANSP"	 ,"C" ,6						,0}							)

   aRetPE := ExecBlock("DL200TRB",.F.,.F.,aCampos)//Campos inseridos via parametro "IT_CMPCARG"
   If ValType(aRetPE)=="A"
      aCampos := aRetPE
   EndIf

   IF Select("TRBPED") > 0
      TRBPED->(Dbclosearea())
   ENDIF

   _otemp := FWTemporaryTable():New( "TRBPED", aCampos )

   _otemp:AddIndex( "01", {"PED_FILORI","PED_PEDIDO","PED_ITEM","PED_SEQLIB","PED_CODCLI","PED_LOJA"} )

   _otemp:Create()

Return

/*
==================================================================================================================================
Programa--------: ITVLDFR1UM
Autor-----------: Alex Wallauer
Data da Criacao-: 09/04/2019
Descrição-------: Validação para não permitir fracionamento para PAs (produtos acabados) onde a primeira unidade de medida for UN
Parametros------: _cMarcado - configuração do padrão para definir quais pedidos serão validados
----------------: _lInverte - configuração do padrão quando for necessário inverter a validação de seleção
Retorno---------: Lógico (.T./.F.)
==================================================================================================================================*/
Static Function ITVLDFR1UM( _cMarcado , _lInverte )

 Local _lRet		:= .T.
 Local _lErro	:= .F.
 Local P  ,_aProd:={}
 Local _cPictQtde:=""
 Local _cUser    := RetCodUsr()
 ZZL->( DBSetOrder(3) )
 If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
    If ZZL->(FIELDPOS("ZZL_PEFRPA")) = 0 .OR. ZZL->ZZL_PEFRPA == "S"
       RETURN .T.
    EndIf
 EndIf
 _cPictQtde:=PesqPict("SC6","C6_QTDVEN")
 
 //====================================================================================================
 // Verificação do faturamento com base em Cargas
 //====================================================================================================
 If IsInCallStack("MATA460B")
   
   _aProd := {}
   SC6->( DBSetOrder(1) )
   FOR P := 1 TO LEN(_aDAKPVs)
      
      DAI->(DBGOTO( _aDAKPVs[P,1] ) )
      
      If SC6->( DBSeek( DAI->( DAI_FILIAL + DAI_PEDIDO ) ) )
         
         DO WHILE SC6->( !Eof() ) .And. SC6->( C6_FILIAL + C6_NUM ) == DAI->( DAI_FILIAL + DAI_PEDIDO )
            
            IF SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO )) .AND. SB1->B1_TIPO == "PA" .AND. SB1->B1_UM == "UN"
               
               If SC6->C6_QTDVEN <> Int(SC6->C6_QTDVEN)
                  AADD( _aProd , { DAI->DAI_COD, DAI->DAI_PEDIDO , SC6->C6_ITEM , SC6->C6_PRODUTO+"-"+SB1->B1_DESC , SB1->B1_UM , TRANS(SC6->C6_QTDVEN ,_cPictQtde),  "Quantidade da 1a UM Fracionada" } )
                  _lErro:=.T.
               ENDIF
               
            EndIf
            SC6->( DBSKIP() )
            
         ENDDO
         
      ENDIF
      
   NEXT P
   
   If len(_aProd) > 0 .AND. _lErro
      _lRet := .F.//Pq se o ultimo item tiver ok nao devolve falso
      U_ITListBox( 'Falha na verificação da Quantidade da 1a UM Fracionada dos pedidos da Carga! (M460MARK)' ,;
      {'Carga','Pedido','Item','Produto','UM',"Quatidade","Problema"} , _aProd , .F. , 1 , 'Verifique os Produtos abaixo: ' )
   ENDIF
   
 Else
   _cProds:=""
   SC6->(DBSETORDER(1))
   FOR P := 1 TO LEN(_aC9Pedidos)//Era por item mas foi para ser por pedido //  ********** POR PEDIDO
      
      SC9->(DBGOTO( _aC9Pedidos[P,1] ) )
      
      If SC6->( DBSeek( SC9->( C9_FILIAL + C9_PEDIDO ) ) )
         
         DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC9->( C9_FILIAL + C9_PEDIDO )
            
            IF SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO )) .AND. SB1->B1_TIPO == "PA" .AND. SB1->B1_UM == "UN"
               
               If SC6->C6_QTDVEN <> Int(SC6->C6_QTDVEN)
                  _cProds+="PV: "+SC6->C6_NUM+" Item: " + SC6->C6_ITEM+" Prod.: " + SC6->C6_PRODUTO+" - UM: "+SB1->B1_UM+ " - " + LEFT(SB1->B1_DESC,20) + CRLF
                  _lRet:=.F.
               ENDIF
               
            ENDIF
            SC6->( DBSkip() )
         EndDo
      EndIf
      
   NEXT P
   
   If !_lRet
      U_ITMSG("Não é permitido fracionar a quantidade da 1a. UM de produto onde a UM for UN. Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
              "Validação Fracionado","Favor informar apenas quantidades inteiras na Primeira Unidade de Medida."         ,1     ,       ,        ,         ,     ,     ,;
              {|| Aviso("Validação Fracionado",_cProds,{"Fechar"}) } )
   ENDIF
   
 EndIf

Return( _lRet )


/*
==================================================================================================================================
Programa--------: M460Lista
Autor-----------: Alex Wallauer
Data da Criacao-: 27/04/2021
Descrição-------: FUNCAO USADA NO P.E. M460NOTA.PRW
Parametros------: NENHUM
Retorno---------: Statica _aStaC9Locais 
==================================================================================================================================*/
USER FUNCTION M460Lista()
RETURN  _aStaC9Locais

/*
==================================================================================================================================
Programa--------: IT_VLDAcesso
Autor-----------: Alex Wallauer
Data da Criacao-: 13/04/2021
Descrição-------: CONTROLE DE ACESSO DE USUARIO POR FILIAL + LOCAL + PRODUTO
Parametros------: _aC9PVItens - recnos do SC9
----------------: _cTrava - trava / destrava
Retorno---------: Lógico (.T./.F.)
==================================================================================================================================*/
USER Function IT_VLDAcesso(aC9PVItens,_cTrava)
 LOCAL _lConcorr := .F.
 LOCAL _lRet     := .F.
 LOCAL _cLocal   := "" , P , T , M
 LOCAL _cUser    := ""
 LOCAL _cUsername:= ALLTRIM(CUSERNAME)
 LOCAL _cCEFATARM:= U_ItGetMv("IT_CEFATARM","")//36,50,52
 LOCAL _cItens:="FIL / LOCAL "+CRLF
 LOCAL aTravados:={}
 STATIC _aSalvaC9PVItens:={}//FIL+LOCAIS
 STATIC _aSalvaTravados:={}//RECNOS
 DEFAULT _lTrava := .T.
 IF EMPTY(_cCEFATARM) 
    Return .T.//NAO FAZ NADA
 ENDIF
 
 IF _cTrava == "DESTRAVA"

   FOR P := 1 TO LEN(_aSalvaTravados)//  ********** POR ITEM
        ZCE->(DBGOTO( _aSalvaTravados[P] ) )
          _cItens+=cFilAnt+"  / "+ZCE->ZCE_LOCAL+" / Destravou "+CRLF
       ZCE->(Reclock("ZCE",.F.))
        ZCE->ZCE_PROD  := ALLTRIM(ZCE->ZCE_USUSAR)+"/"+ALLTRIM(ZCE->ZCE_PROD)
       ZCE->ZCE_USUSAR:="" 
          ZCE->(Msunlock())//DESTRAVA
   NEXT P
    ZCE->(MsunlockAll())//DESTRAVA TODOS 
   //Sleep( 5000 ) //Aguarda 5 segundos

   bBloco:={||  AVISO("ATENCAO",_cItens,{"FECHAR"},3) }
   U_ITMSG("ITENS ***DESTRAVADOS*** CLIQUE NO BOTAO",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
          "P. E. M460NOTA","IT_CEFATARM = "+_cCEFATARM+CRLF+_cItens ,2,,,,,,bBloco)

   RETURN .T. //**************************** RETURN *************************************************

 ELSEIF _cTrava == "TRAVA_DE_NOVO"
   
   aC9PVItens:=aClone(_aSalvaC9PVItens)

 ENDIF

 IF !EMPTY(_cCEFATARM) //!EMPTY(_cCEFATFIL) .AND. !EMPTY(_cCEFATARM) .AND. cFilAnt $ _cCEFATFIL 
    DBSELECTAREA("ZCE")
    ZCE->(DBSetOrder(1))//ZCE_FILIAL+ZCE_LOCAL

   FOR P := 1 TO LEN(aC9PVItens)//  ********** POR ITEM

      _cItens+=cFilAnt+"  / "+aC9PVItens[P]

        If ZCE->(Dbseek(cFilAnt+aC9PVItens[P]))//SC9->C9_LOCAL+SC9->C9_PRODUTO ))
          
             If  !EMPTY(ZCE->ZCE_USUSAR) .AND. !_cUsername $ ZCE->ZCE_USUSAR
             
                 If !ZCE->(MsRLock(ZCE->(RECNO()))) 
               _lConcorr:= .T.
            ELSE
                 ZCE->(Msunlock())//destrava para não atrapalhar quem tá usando
               _aMonitor := GetUserInfoArray()
               FOR M := 1 TO LEN(_aMonitor)
                   IF UPPER(_cUsername) $ UPPER(_aMonitor[M,11]) .OR.;// IGNORA AS LINAHS DO USUARIO LOGADO
                     (!"MATA460B" $ UPPER(_aMonitor[M,11])     .AND.;// IGNORA OUTROS PROGRAMAS
                      !"MATA460A" $ UPPER(_aMonitor[M,11]))
                     LOOP
                  ENDIF
                       _cUserLocado:=UPPER(SUBSTR( ZCE->ZCE_USUSAR , 1 , AT("-",ZCE->ZCE_USUSAR)-1 ))
                   MSGSTOP(_aMonitor[M,11],"_cUserLocado: "+_cUserLocado)
                  IF _cUserLocado $ UPPER(_aMonitor[M,11]).AND.;
                      ("MATA460B" $ UPPER(_aMonitor[M,11]) .OR.;
                       "MATA460A" $ UPPER(_aMonitor[M,11]))
                      _lConcorr:= .T.
                    _cCEFATARM:="** PELO MONITOR ** ( "+_cCEFATARM+" )"
                    MSGSTOP("*** ACHOU *** "+_aMonitor[M,11],"_cUserLocado: "+_cUserLocado)
                    EXIT
                  ENDIF
                   NEXT M
            ENDIF
                
            IF _lConcorr
                   _cLocal  := ZCE->ZCE_LOCAL
                   _cUser   := ALLTRIM(ZCE->ZCE_USUSAR)
                   _cItens  += " / Locado por "+_cUser+CRLF
               EXIT          		
            ENDIF
            
             ENDIF          	
                
         ZCE->(Reclock("ZCE",.F.))
             ZCE->ZCE_THREAD := STRZERO(THREADID(),6)
         IF !EMPTY(ZCE->ZCE_USUSAR)
               ZCE->ZCE_PROD:=ALLTRIM(ZCE->ZCE_USUSAR)+"/"+ALLTRIM(ZCE->ZCE_PROD)
         ENDIF
             ZCE->ZCE_USUSAR := _cUsername+"-"+DTOC(DATE())+"-"+TIME()
             ZCE->(Msunlock())
             ZCE->(Reclock("ZCE",.F.))//TRAVA
            _cItens+="  / Travou "+CRLF
         AADD(aTravados, ZCE->(RECNO()) )
                
        Else
          
             ZCE->(Reclock("ZCE",.T.))
            ZCE->ZCE_FILIAL := cFilAnt    
            ZCE->ZCE_LOCAL  := aC9PVItens[P]//SC9->C9_LOCAL
             ZCE->ZCE_THREAD := STRZERO(THREADID(),6)
             ZCE->ZCE_USUSAR := _cUsername+"-"+DTOC(DATE())+"-"+TIME()
             ZCE->(Msunlock())
             ZCE->(Reclock("ZCE",.F.))//TRAVA
            _cItens+="  / Incluiu e Travou "+CRLF
         AADD(aTravados, ZCE->(RECNO()) )
             
        EndIf
    
   NEXT P
   //Sleep( 5000 ) //Aguarda 5 segundos

 ENDIF

 If _lConcorr

    FOR T := 1 TO LEN(aTravados)
        ZCE->(DbGOTO(aTravados[T]))
      ZCE->(Reclock("ZCE",.F.))
        ZCE->ZCE_PROD  := ALLTRIM(ZCE->ZCE_USUSAR)+"/"+ALLTRIM(ZCE->ZCE_PROD)
       ZCE->ZCE_USUSAR:="" 
          ZCE->(Msunlock())//DESTRAVA
          _cItens+=cFilAnt+"  / "+ZCE->ZCE_LOCAL+" / Destravou "+CRLF
    NEXT T
   ZCE->(MsunlockAll())//DESTRAVA TODOS 

   bBloco:={||  AVISO("ATENCAO",_cItens,{"FECHAR"},3) }

   U_ITMSG("Faturmento do Armazem [ "+_cLocal+" ] sendo feito pelo usuario [ " + _cUser + " ]",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
          "CONTROLE DE ACESSO [ "+_cCEFATARM+" ]","TENTE NOVAMENTE DAQUI A POUCO."+CRLF+_cItens,1,,,,,,bBloco)
   _lRet:= .F.
 ELSE
   _aSalvaTravados :=ACLONE(aTravados )// RECNOS
   _aSalvaC9PVItens:=ACLONE(aC9PVItens)// FIL+LOCAIS
   _lRet:= .T.
 ENDIF

 DBSELECTAREA("SC5")

Return( _lRet )

/*
==================================================================================================================================
Programa--------: IT_Gera_FatTri
Autor-----------: Alex Wallauer
Data da Criacao-: 07/12/2022
Descrição-------: Geracao do pedidos de Faturamento da Operacao Triangular
Parametros------: _cAcao - Acao a ser executada
Retorno---------: Lógico (.T./.F.)
==================================================================================================================================*/
USER Function IT_Gera_FatTri(_cAcao As Char) As Logical
 LOCAL P As Numeric, nInc As Numeric
 Local _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42")) As Char
 Local _cOperRemessa   := RIGHT(_cOperTriangular,2) As Char
 Local _aPeds_Prod:={} As Array
 Local _aLog:={} As Array
 
 //====================================================================================================
 // Verificação do faturamento com base em Cargas
 //====================================================================================================
 If IsInCallStack("MATA460B")
    SC5->(Dbsetorder(1))
    FOR P := 1 TO LEN(_aDAKPVs)
       DAI->(DBGOTO( _aDAKPVs[P,1] ) )
       If SC5->(Dbseek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))
          If SC5->C5_I_OPER = _cOperRemessa 
             AADD(_aPeds_Prod,  SC5->(RECNO()) )
          Endif
       Endif
    NEXT P
  
 ElseIF IsInCallStack("MATA460A") //Faturamento por pedido de vendas
    SC5->(Dbsetorder(1))
    SC6->(Dbsetorder(1))
    FOR P := 1 TO LEN(_aC9Pedidos)//  ********** POR PEDIDO
       SC9->(DBGOTO( _aC9Pedidos[P,1] ) )
       If SC5->(Dbseek( SC9->C9_FILIAL+SC9->C9_PEDIDO ))
          If SC5->C5_I_OPER = _cOperRemessa 
             AADD(_aPeds_Prod,  SC5->(RECNO()) )
          Endif
       Endif
    NEXT P
 
 EndIf

 PRIVATE _lDeuErro:= .F.//Se der algum Erro

 IF LEN(_aPeds_Prod) > 0
           
   BEGIN Transaction

            SA1->(dbSetOrder(1))
            SC6->(dbSetOrder(1))
           FOR P := 1 TO LEN(_aPeds_Prod)

               SC5->(DBGOTO( _aPeds_Prod[P] ) )
                
            IF _cAcao == "#VALIDAR"//Validar TES dos Pedidos de Faturamento 

               _cC5_I_CLI:=SC5->C5_I_CLIEN
                   _cC5_I_LOJ:=SC5->C5_I_LOJEN
                  SA1->(MsSeek(xFilial() + _cC5_I_CLI+_cC5_I_LOJ))
                 _cSuframa:=IF(!EMPTY(SA1->A1_SUFRAMA),"S","N")
                 _cCpoSN  :=IF(SA1->A1_SIMPNAC="1","S","N")
                 _cCpoCI  :=IF(SA1->A1_CONTRIB="2","N","S")
                 _cEstCli := SA1->A1_EST
               _cEstFil := SM0->M0_ESTCOB

                    SC6->(MsSeek(SC5->C5_FILIAL+SC5->C5_NUM))

                    Do While ! SC6->(Eof()) .And. SC6->C6_FILIAL+SC6->C6_NUM == SC5->C5_FILIAL+SC5->C5_NUM
                   
                  _cTES:= U_SelectTES(SC6->C6_PRODUTO,_cSuframa,_cEstCli,_cEstFil,_cC5_I_CLI,_cC5_I_LOJ,"05",SC6->C6_LOCAL,SC5->C5_TIPO)
                      
                   If EMPTY(_cTES)
                     _lDeuErro:=.T.
                       aAdd( _aLog ,{.F.,cFilant,;
                                   "05",;
                              _cC5_I_CLI+"/"+_cC5_I_LOJ+" - "+ALLTRIM(SA1->A1_NOME),;
                              _cEstFil+ " / " +_cEstCli,;
                              _cSuframa+" / "+_cCpoSN+" / "+_cCpoCI,;
                              SC6->C6_LOCAL,;
                              ALLTRIM(SC6->C6_PRODUTO)+" - "+Posicione("SB1",1,Xfilial("SB1")+SC6->C6_PRODUTO,"B1_DESC"),""})
                  Else
                       aAdd( _aLog ,{.T.,cFilant,;
                                   "05",;
                              _cC5_I_CLI+"/"+_cC5_I_LOJ+" - "+ALLTRIM(SA1->A1_NOME),;
                              _cEstFil+ " / " +_cEstCli,;
                              _cSuframa+" / "+_cCpoSN+" / "+_cCpoCI,;
                              SC6->C6_LOCAL,;
                              ALLTRIM(SC6->C6_PRODUTO)+" - "+Posicione("SB1",1,Xfilial("SB1")+SC6->C6_PRODUTO,"B1_DESC"),_cTES})
                   EndIf
                   
                        SC6->(DbSkip())
                    EndDo 

            ElseIF _cAcao == "#GERAR"//Gerar Pedido de Faturamento 

                For nInc := 1 To SC5->(FCount())
                      M->&(SC5->(FieldName(nInc))) := SC5->(FieldGet(nInc))
                Next nInc
   
                aHeader:= {}
                aCols  := {}   
                cSeek  := xFilial("SC6")+SC5->C5_NUM
                bWhile := {|| SC6->C6_FILIAL+SC6->C6_NUM }
                FillGetDados(4,"SC6",1,cSeek,bWhile,,NIL)

                 Processa( {|| _lDeuErro:=U_IT_OperTriangular(SC5->C5_NUM,.F.,.F.) } ,"Gerando Pedido de Faturamento...", "Gerando Pedido da Remessa: "+SC5->C5_NUM+"... " )
                
               IF _lDeuErro
                   DisarmTransaction()
                   EXIT
                ENDIF
             
            ENDIF
                
           NEXT P
      
   END Transaction

 ENDIF

 If LEN(_aLog) > 0 .AND. _lDeuErro//_aLog gravado na funcao AOM112VerTES()

   _cMen:="Foram encontrado(s) produto(s) sem regra de TES INTELIGENTE cadastrada para a filial de criação do pedido de Faturamento (05), "				+;
         "desta forma não sera possível prosseguir com a efetivação, favor informar ao responsável pela inclusão das regras de TES INTELIGENTE "	+;
         "do problema encontrado."
   
   U_Itmsg( _cMen, 'Atenção!',"Clique em OK para ver a lista dos produtos com problema de TES nas linhas em vermelho.", 1   )
   
   _aCab:={" ", 'Filial','Operação','Dados do Cliente','Est. Orig. / Dest.','Suframa/Simples/Contr.',"Armazem",'Produto', "TES"}

   U_ITListBox( 'Lista de pedidos com produtos sem TES Inteligente. (M460MARK)' ,;
               _aCab , _aLog , .T. , 2 ,)

 Endif

RETURN (!_lDeuErro)

/*
===============================================================================================================================
Programa--------: IT_VLITRAS
Autor-----------: Julio de Paula Paz
Data da Criacao-: 11/04/2024
Descrição-------: Validação de itens de pedidos de vendas com rastreabilidade.
Parametros------: _cFilial    = Filial do Pedido de Vendas.
                  _cNrPedido  = Numero do Pedido de Vendas.
              _cNrCarga   = Numero da Carga
              _lCarga     = .T. = Validação por Carga
                          = .F. = Validação por Pedido
Retorno---------: _aRet- Tudo certo nas validações ou não.
===============================================================================================================================
*/

Static Function IT_VLITRAS( _cFilial , _cNrPedido, _cNrCarga , _lCarga)
 Local _aRet := {.T., "Todas as quantides liberedas estão corretas.", "Prosseguir na emissão da nota."}
 Local _aItensRas := {}, _nI 
 Local _nTotQtdLb := 0 
 
 Begin Sequence
   
   SB1->(DbSetOrder(1))
   SC6->(DbSetOrder(1))
   SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED 

   SC6->(MsSeek(_cFilial + _cNrPedido))

   Do While ! SC6->(Eof()) .And. SC6->C6_FILIAL+SC6->C6_NUM == _cFilial + _cNrPedido
      SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
      If SB1->B1_RASTRO $ "L/S" 
         Aadd(_aItensRas,SC6->(Recno()))
     EndIf  

      SC6->(DbSkip())
   EndDo 

   If Len(_aItensRas) == 0 
      Break
   EndIf 

   
   For _nI := 1 To Len(_aItensRas)
      _nTotQtdLb := 0  

      SC6->(DbGoto(_aItensRas[_nI]))
       SC9->(MsSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
      Do While ! SC9->(Eof()) .And. SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM == SC9->C9_FILIAL+SC9->C9_PEDIDO + SC9->C9_ITEM
          
        _nTotQtdLb += SC9->C9_QTDLIB
       
          SC9->(DbSkip())
      EndDo 

       If _nTotQtdLb <> SC6->C6_QTDVEN
         If _lCarga
             _cProblema := "O Pedido / Produto "+SC6->C6_FILIAL + " - " + SC6->C6_NUM + " / "+ALLTRIM(SC6->C6_PRODUTO) + " apresentou falha de dados (Divergênia entre quantidade liberada e quantidade do item). "
            _cSolucao  := 'Será necessário estornar a Carga: ' + SC6->C6_FILIAL + ' - ' + _cNrCarga + ' e a liberação do Pedido, e criar a carga novamente.'
        Else 
             _cProblema := "O Pedido / Produto "+SC6->C6_FILIAL + " - " + SC6->C6_NUM + " / "+ALLTRIM(SC6->C6_PRODUTO) + " apresentou falha de dados (Divergênia entre quantidade liberada e quantidade do item). "
            _cSolucao  := 'Será necessário refazer a liberação do Pedido de Vendas.' 
        EndIf 
        _aRet := {.F., _cProblema, _cSolucao}
        Break 
      EndIf 

   Next _nI

 End Sequence


Return _aRet 

