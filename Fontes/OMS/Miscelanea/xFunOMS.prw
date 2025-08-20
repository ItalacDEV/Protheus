/* 
=======================================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=======================================================================================================================================
      Autor  |    Data  |                                             Motivo                                            
=======================================================================================================================================
Julio Paz    | 14/04/23 | Chamado 43525. Ajustar a fun��o Nfoplog() para considerar campos operador log�stico/Redespacho da carga.
Alex Wallauer| 23/05/23 | Chamado 43893. Campos do Troca Nota agora ser�o replicados do Pedido 42 para o Pedido 05. 
Lucas Borges | 02/06/23 | Chamado 44023. Inclu�da regra para estado do PR na fun��o OMSMSGNF.
Alex Wallauer| 08/08/23 | Chamado 44658. Ajuste na fun��o OMSVLDENT() mais 2 parametros @_lAchouZG5 @_cRegra.
Alex Wallauer| 22/08/23 | Chamado 44799. Alteracao da fun��o U_ITMSG() para a fun��o U_MT_ITMSG(). 
Julio Paz    | 28/08/23 | Chamado 44715. Ajutar rotinas de integra��o CISP para utilizarem apenas links MAXXI.
Alex Wallauer| 23/10/23 | Chamado 45295. Ajuste na fun��o OMSVLDENT() para gravar as mensagens de erro na variavel _cObs.
Alex Wallauer| 21/11/23 | Chamado 45625. Ajuste na fun��o ITCODCLI() para n�o trazer codigo errado na alteracao do SA1 via EXECAUTO.
Alex Wallauer| 11/12/23 | Chamado 45802. Teste se a TAG _ocisp:cliente:observacoes existe.
Antonio Neves| 13/12/23 | Chamado 45863. Valida��o se existe a tag da receita federal
Julio Paz    | 07/03/24 | Chamado 45229. Desenvolvimento do Webservice TMS Embarcador, alterar situa��o Pedido de Vendas.
Julio Paz    | 24/05/24 | Chamado 46888. Ajustar a valida��o data de entrega do pedido de vendas para exibir mensagem uma unica vez.
Alex Wallauer| 19/06/24 | Chamado 47415. Jerry. Ajuste da valida��o de cond. de pagto. para buscar 1o no ZGO_CONDPA depois no A1_COND.
Alex Wallauer| 21/06/24 | Chamado 47204. Jerry. Ajuste na OMSVLDENT() para trocar as fun��es U_ITMSG para U_MT_ITMSG.
Jerry        | 26/06/24 | Chamado 47655. Jerry. Ajuste na OMSVLDENT para n�o validar Data de Entrega quando PV for Desmembrado.
Julio Paz    | 17/07/24 | Chamado 47896 - Verificar e Corrigir Error Log ao Acessar a Rotina de Consulta de Cr�dito CISP [OMS]
Igor Melga�o | 01/07/24 | Chamado 47184. Jerry. Ajustes para grava��o do campo C6_I_PRMIN
Lucas Borges | 23/07/25 | Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
==============================================================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================================================
Vanderlei   - Alex Wallauer - 14/08/24 - 18/09/24 - 48138   - Tratamento do Local de Embarque (ZG5_LOCEMB) no cadastro de Transit Time.
Jerry       - Alex Wallauer - 03/02/25 - 03/02/25 - 49795   - Chamar os �ndices customizados da tabela SC5 com DBOrderNickName().
Jerry       - Alex Wallauer - 27/11/24 - 20/03/25 - 37652   - Novo parametro "_lValSC5" na fun��o OMSVLDENT() para validar de qq tabela s� passando os parametros.
Jerry       - Alex Wallauer - 06/01/25 - 20/03/25 - 44092   - Novo Tratamento para Tabela de Pre�os no Pedido de Vendas. Fun��o U_ITTABPRC ().
Jerry       - Julio Paz     - 11/03/25 - 20/03/25 - 48837   - Inclus�o de valida��o para clientes com condi��o de pagamento especial. Ajustes na fun��o que retorna a condi��o de pagamento.
Jerry       - Alex Wallauer - 24/03/25 - 24/03/25 - 48837   - Inclus�o de valida��o para clientes com condi��o de pagamento especial. Ajustes na fun��o que retorna a condi��o de pagamento.
Jerry       - Alex Wallauer - 27/03/25 - 01/04/25 - 50330   - Ajustes na fun��o que retorna a condi��o de pagamento.
Jerry       - Alex Wallauer - 13/05/25 - 10/06/25 - 44092   - Troca do campo ZGQ_UF pelo ZGQ_UFPEDV e exclusao do ZGQ_UF. Fun��o U_ITTABPRC ().
Andre       - Alex Wallauer - 27/05/25 - 10/06/25 - 50460   - Cria��o da fun��o da ITConv(cProd,nQuant,nUM_Ori,nUM_Dest).
Vanderlei   - Alex Wallauer - 06/06/25 - 10/06/25 - 45229   - Retirada do par�metro p/determinar se a integra��o WebS. ser� TMS Multiembarcador ou RDC para chamar a U_IT_TMS(_cLocEmb).
Vanderlei   - Alex Wallauer - 06/06/25 - 10/06/25 - 45229   - Criacao da fun��o U_IT_TMS(_cLocEmb) p/determinar se a integra��o WebS.ser� TMS Multiembarcador ou RDC.
Vanderlei   - Alex Wallauer - 09/06/25 - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP").
Andre       - Igor Melga�o  - 11/06/25 - 11/07/25 - 50716   - Ajustes para busca de pre�o do produto na tabela Z09, para pedidos de transfer�ncia entre filiais
Andre       - Alex Wallauer - 25/06/25 - 11/07/25 - 50460   - Corre��o da fun��o da ITConv(cProd,nQuant,nUM_Ori,nUM_Dest) na 3a UM.
Jerry       - Alex Wallauer - 05/08/25 -          - 44092   - Novas regras de pesquisa na Fun��o BuscaTabPreco ().
==============================================================================================================================================================================================
*/
 
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"

/*
===============================================================================================================================
Programa----------: XFUNOMS
Autor-------------: Fabiano Dias
Data da Criacao---: 30/03/2011
===============================================================================================================================
Descri��o---------: Rotinas gen�ricas para utiliza��o nos desenvolvimentos do m�dulo OMS
===============================================================================================================================
*/

/*
===============================================================================================================================
Programa----------: C_IRRF_INSS
Autor-------------: Fabiano Dias
Data da Criacao---: 30/03/2011
===============================================================================================================================
Descri��o---------: Fun��o que realizar os calculos de INSS e IRRF dos relatorios de conferencia da comisao da baixa do titulo.
===============================================================================================================================
Par�metros--------: _cTipo    tipo do imposto
                     _nValor   base de c�lculo
===============================================================================================================================
Retorno-----------: _aImpostos - valor do inss, valor do irrf
===============================================================================================================================
*/
User Function C_IRRF_INSS( _cTipo , _nvalor )

    Local _nPorcIRRF        := GetMv("IT_PORIRRF")
    Local _aImpostos        := {}

    Private _cRecibo
    Private _nVlrIrrfPag	:= 	0
    Private _nTeto			:=	0
    Private _nbaseSest		:=	0
    Private _nVlrSest 		:=	0
    Private _nbaseinss		:=	0
    Private _nvlrinss 		:=	0
    Private _nVlrIrrf 		:= 	0
    Private _x08_Lim3
    Private _x08_Lim3P
    Private _x09_rend1
    Private _x09_rend2
    Private _x09_rend3
    Private _x09_rend4
    Private _x09_rend5
    Private _x09_aliq2
    Private _x09_aliq3
    Private _x09_aliq4
    Private _x09_aliq5
    Private _x09_parc2
    Private _x09_parc3
    Private _x09_parc4
    Private _x09_parc5
    Private _x09_deddep
    Private _x09_limdep
    Private _x09_retmin

/*
//==============================================================
//Calculos dos impostos de acordo com o cadastro do vendedor.
//==============================================================
*/
    If _cTipo <> '3' .And. _nvalor > 0 .And. Len(AllTrim(_cTipo)) > 0

    /*
    //=========================================
    //Gera deducao somente do imposto de IRRF
    //=========================================
    */
        If _cTipo == '1'

            _nVlrIrrf := _nvalor * (_nPorcIRRF / 100)

        /*
        //==========================================
        //Valor minimo a ser cobrado sobre o IRRF.
        //==========================================
        */
            If _nVlrIrrf < 10
                _nVlrIrrf:=0
            EndIf

            aAdd(_aImpostos,{_nVlrInss,_nVlrIrrf})

        Else

            // calculo INSS
            U_ValINSS()

            _nTeto:= NoRound(_x08_Lim3 * _x08_Lim3P / 100,2)

            _nCorrentVlrINSS := _nvalor * GETMV('IT_VLRINSS') / 100

            If _nCorrentVlrINSS < _nteto
                _nvlrinss :=_nvalor * GETMV('IT_VLRINSS') / 100
            Else
                _nvlrinss :=_nteto
            EndIf

            //--------------------------------------------------CALCULO DO IRRF-----------------------------------------------//
            // Busca dados das aliquotas nas tabelas de IRRF
            _nBaseIrrf		:= 0
            u_ValIRRF()

            _nbaseirrf		:= (_nvalor)
            _nbaseirrf		-= (_nvlrinss) // deduz INSS
            _nVlrIrrfPag	:= 0

            If _nBaseIrrf > _x09_rend1 .And. _nBaseIrrf <= _x09_rend2
                _nVlrIrrf:=_nbaseirrf * _x09_aliq2 / 100
                _nvlrIrrf-=_x09_parc2
            ElseIf _nBaseIrrf > _x09_rend2 .And. _nBaseIrrf <= _x09_rend3
                _nVlrIrrf:=_nbaseirrf * _x09_aliq3 / 100
                _nvlrIrrf-=_x09_parc3
            ElseIf _nBaseIrrf > _x09_rend3 .And. _nBaseIrrf <= _x09_rend4
                _nVlrIrrf:=_nbaseirrf * _x09_aliq4 / 100
                _nvlrIrrf-=_x09_parc4
            ElseIf _nBaseIrrf > _x09_rend4 .And. _nBaseIrrf <= _x09_rend5
                _nVlrIrrf:=_nbaseirrf * _x09_aliq5 / 100
                _nvlrIrrf-=_x09_parc5
            Else
                _nVlrIrrf:=0
            EndIf

            If _nVlrIrrf < GETMV('MV_VLRETIR')
                _nVlrIrrf:=0
            EndIf

            _nVlrIrrf  := IIF(_nVlrIrrf < 0,0,_nVlrIrrf)
            _nVlrInss  := IIF(_nVlrInss < 0,0,_nVlrInss)

            aAdd(_aImpostos,{_nVlrInss,_nVlrIrrf})

        EndIf

    /*
    //===============================================================
    //Nao calcula impostos para a comissao de acordo com o cadastro
    //do vendedor.                                                 
    //===============================================================
    */
    Else

        aAdd(_aImpostos,{0,0})

    EndIf

Return _aImpostos

/*
===============================================================================================================================
Programa----------: VerCliSuf
Autor-------------: Guilherme Diogo
Data da Criacao---: 22/10/2012 
===============================================================================================================================
Descri��o---------: Verifica se o cliente e SUFRAMA e exibe mensagem no pedido de venda. 
===============================================================================================================================
Par�metros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function VERCLISUf()

    Local cEmpCorr := cEmpAnt
    Local cEmpSuf  := ""
    Local cTitulo  := "Cliente SUFRAMA"
    Local cTexto   := "O cliente selecionado � um cliente SUFRAMA."
    Local _aArea   := GetArea()

    SM0->(dbSeek(cEmpCorr+cFilAnt))

    cEmpSuf := ALLTRIM(SM0->M0_INS_SUF)

    SA1->(dbSetOrder(1))
    If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))

        cCliSuf := ALLTRIM(SA1->A1_SUFRAMA)

        If cEmpSuf <> "" .AND. cCliSuf <> ""

            u_itmsg(cTexto, cTitulo,,3)

        EndIf

    EndIf

    RestArea(_aArea)

Return (M->C5_CLIENTE)

/*
===============================================================================================================================
Programa----------: NomeAut
Autor-------------: Guilherme Diogo
Data da Criacao---: 31/10/2012 
===============================================================================================================================
Descri��o---------: Retorna o nome do autonomo 
===============================================================================================================================
Par�metros--------: _cCodAuton - Codigo do Autonomo   
===============================================================================================================================
Retorno-----------: _cnome - Nome do Autonomo
===============================================================================================================================
*/

User Function NomeAut(_cCodAuton)

    Local _cAlias := GetNextAlias()
    Local _cFiltro:= "%"
    Local _cNome  :=""
    Local _aArea  := GetArea()

    _cFiltro += " AND (A2_I_AUT = '" + _cCodAuton + "' OR A2_I_AUTAV = '" + _cCodAuton + "')"
    _cFiltro += "%"

    BeginSql alias _cAlias
    SELECT
    A2_NOME NOME
    FROM
    %table:SA2%
    WHERE
    D_E_L_E_T_ = ' '
    %exp:_cFiltro%
    EndSql

    (_cAlias)->(dbGotop())

    _cNome := (_cAlias)->NOME

    (_cAlias)->(dbCloseArea())

    RestArea(_aArea)

Return (_cNome)

/*
===============================================================================================================================
Programa----------: ITConv
Autor-------------: Alex Wallauer
Data da Criacao---: 27/05/25 
Descri��o---------: Fun��o para convers�o entre unidades de medida
Par�metros--------: cProd - c�digo do produto da quantidade
                    nQuant - quantidade a converter
                    nUM_Ori  - unidade de Origem   
                    nUM_Dest - unidade de Destino 
Retorno-----------: nQtdUM quantidade convertida
===============================================================================================================================
*/
User Function ITConv(cProd,nQuant,nUM_Ori,nUM_Dest)
 Return U_CNUM(cProd,nQuant,nUM_Ori,nUM_Dest)
User Function CNUM(cProd,nQuant,nUM_Ori,nUM_Dest)
 Local nQtdUM  := 0
 Local nFator  := Posicione("SB1",1,Xfilial("SB1")+cProd,"B1_CONV")
//*************************************************
 If nUM_Ori = 1 // Convers�o da PRIMEIRA UM para 1 e 2...
    
    Default nUM_Dest := 2
 
    If nFator = 0
        If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
            nFator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
        Endif
    Else
        nFator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
    Endif

    IF nUM_Dest = 2// Convers�o da Primeira UM para a Segunda UM
       nQtdUM:= nQuant * nFator
    
    ElseIF nUM_Dest = 3// Convers�o da Primeira UM para a Terceira UM
        If SB1->B1_I_QQUEI == 'S' .AND. SB1->B1_SEGUM = 'PC' .AND. SB1->B1_I_3UM = 'CX'
           nQtdUM := nQuant * nFator         // Calcula a quantidade na Segunda UM
           nQtdUM := nQtdUM / SB1->B1_I_QT3UM// Convers�o da SEGUNDA UM para a Terceira UM
        Else
           nQtdUM := nQuant / SB1->B1_I_QT3UM// Convers�o da PRIMEIRA UM para a Terceira UM
        EndIf
    
    Endif
 
 //**************************************************
 ElseIf nUM_Ori = 2// Convers�o da SEGUNDA UM para...
    
    Default nUM_Dest := 1

    If nFator == 0
        If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
            nFator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
        Endif
    Else
        nFator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_CONV,SB1->B1_CONV)
    Endif

    nQtdUM:= nQuant * nFator// Convers�o da Segunda UM para a Primeira UM

    IF nUM_Dest = 3// Convers�o da Segunda UM para a Terceira UM
        If SB1->B1_I_QQUEI == 'S' .AND. SB1->B1_SEGUM = 'PC' .AND. SB1->B1_I_3UM = 'CX'
           nQtdUM:= nQuant / SB1->B1_I_QT3UM// Convers�o da SEGUNDA UM para a Terceira UM
        Else
           nQtdUM:= nQtdUM / SB1->B1_I_QT3UM// Convers�o da PRIMEIRA UM para a Terceira UM
        EndIf
    EndIf
 
 //***************************************************
 ElseIf nUM_Ori = 3// Convers�o da TERCEIRA UM para 1 ou 2...
   
    IF nUM_Dest = 1//CONVERS�O DA TERCEIRA UM PARA A PRIMEIRA UM PARA PC
       nQtdUM:= nQuant * SB1->B1_I_QT3UM// Convers�o da TERCEIRA UM PARA A PRIMEIRA U.M. SEM SER PC ou SEGUNDA se for PC
       If SB1->B1_I_QQUEI == 'S' .AND. SB1->B1_SEGUM = 'PC' .AND. SB1->B1_I_3UM = 'CX'
          If nFator == 0
              If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                  nFator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
              Endif
          Else
              nFator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_CONV,SB1->B1_CONV)
          Endif
          nQtdUM:= nQtdUM * nFator// SENDO PC, Temos a Convers�o da Segunda UM para a Primeira UM
       Endif
    
    ElseIF nUM_Dest = 2//CONVERS�O DA TERCEIRA UM PARA A SEGUNDA U.M.
      If SB1->B1_I_QQUEI == 'S' .AND. SB1->B1_SEGUM = 'PC' .AND. SB1->B1_I_3UM = 'CX'//SE FOR PC esse resultado j� � a 2 U.M.
         nQtdUM:= nQuant * SB1->B1_I_QT3UM// Convers�o da Terceira UM para a Segunda U.M. sendo PC
      Else
         nQtdUM:= nQuant * SB1->B1_I_QT3UM// Convers�o da TERCEIRA UM PARA A PRIMEIRA U.M. SEM SER PC
         If nFator = 0
            If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
               nFator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
            Endif
         Else
            nFator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
         Endif
         nQtdUM:= nQtdUM * nFator // Convers�o da Primeira UM para a Segunda UM
       EndIf
    EndIf

 EndIf

Return nQtdUM

/*
===============================================================================================================================
Programa----------: VER2UM
Autor-------------: Guilherme Diogo
Data da Criacao---: 31/10/2012 
===============================================================================================================================
Descri��o---------: Teste se produto tem segunda unidade cadastrada
===============================================================================================================================
Par�metros--------: cProd - c�digo do produto 
===============================================================================================================================
Retorno-----------: lret - .T. se tiver segunda unidade cadastrada
===============================================================================================================================
*/

User Function VER2UM(cProd)

    lRet := .T.
    nFator   := GetAdvFVal("SB1","B1_CONV",xFilial("SB1")+cProd,1,"")

    If nFator == 0

        lRet := .F.

    EndIf

Return lRet

/*
===============================================================================================================================
Programa----------: RETBLQ
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 04/05/2016
===============================================================================================================================
Descri��o---------: Funcao para retornar valor de campo de bloqueio de pre�o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cret - Valor do campo de bloqueio
===============================================================================================================================
/*/
User Function RETBLQ() As Char

 If aCols[n][Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_I_BLPRC"	} )]  == "L"
     Return "L"
 Else
     Return " "
 Endif

Return " "

/*
===============================================================================================================================
Programa----------: BLQPRC
Autor-------------: Tiago Correa Castro
Data da Criacao---: 25/01/2009 
===============================================================================================================================
Descri��o---------: Funcao para validar pre�o de venda
===============================================================================================================================
Parametros--------: _cProd     - C�digo do produto
                    _nPrcVen   - Pre�o praticado
                    _cFil      - Filial faturando
                    _lShow     - Mostra mensagem de faixa de pre�os	
                    _cTab      - Tabela de pre�os
                    _lTrans    - Chamando de fora da tela de pedido de vendas
                    _lUsaNovo  - N�O USA MAIS //Obriga uso de novo esquema de tabelas de pre�os
                    _nFatorPrc - N�O USA MAIS //Fator aplicado InterEstadual
                    _lVldLinha - N�O USA MAIS
                    _cGrupoP   - Grupo de produto
                    _cUFPedV   - UF do Cliente do Pedido 
                    _lRetPrc   - N�O � MAIS UTILIZADO - Grava os campos C6_PRCVEN / C6_I_FXPES no aCols
                    _cTpVenda  - Tipo de Venda F-Carga Fechada / V-Carga Fracionada (Varejo)
                    _lSimplNac - Cliente Optante do Simples nacional
                    _nPesoBrut - Peso Bruto do Pedido de Vendas
                    _nFaixa    - Faixa de Pre�o
===============================================================================================================================
Retorno-----------: _aRet - Array { T-Pre�o Fora/F-Pre�o Ok, Faixa, Msg }
===============================================================================================================================
/*/
User Function BLQPRC(_cProd     As Char   ,;
                     _nPrcVen   As Numeric,;
                     _cFil      As Char   ,;
                     _lShow     As Logical,; 
                     _cTab      As Char   ,; 
                     _lTrans    As Logical,; 
                     _lUsaNovo  As Logical,; //N�O USA MAIS 
                     _nFatorPrc As Numeric,; //N�O USA MAIS 
                     _lVldLinha As Logical,; //N�O USA MAIS 
                     _cGrupoP   As Char   ,; 
                     _cUFPedV   As Char   ,; 
                     _lRetPrc   As Logical,; //N�O � MAIS UTILIZADO 
                     _cTpVenda  As Char   ,; 
                     _lSimplNac As Logical,; 
                     _nPesoBrut As Numeric,;
                     _nFaixa    As Numeric)
    
 Local _lRet          := .F.         As Logical
 Local _nprcori       := 0           As Numeric
 Local _cTES          := ""          As Char
 Local _cCF           := ""          As Char
 Local _lB1TipoPA     := .F.         As Logical
 Local _lF4DuplicS    := .F.         As Logical
 Local _lZAYTpOprV    := .F.         As Logical
 Local _lAchou        := .F.         As Logical
 Local _aFiliais      := FWLoadSM0() As Array
 Local _cCnpj         := ""          As Char
 Local _nPrecoIt      := 0           As Numeric
 Local _cFilFat       := ""          As Char
 Local _cFilOrig      := ""          As Char
 Local _cUFFat        := ""          As Char
 Local _nI            := 0           As Numeric
 Local _cDescTBPrc    := ""          As Char
 Local _nPosPrc       := 0           As Numeric
 Local _lPortal       := .F.         As Logical
 Local _lWF           := .F.         As Logical
 Local _nPrcMin       := 0           As Numeric
 Local _nPercSimp     := 0           As Numeric
 Local _nPrecoMax     := 0           As Numeric
 Local _cRetMsg       := ""          As Char
 Local _aRet          := {}          As Array
 Local _lRegraNova    := .F.         As Logical
 Local _nFatComercial := 1           As Numeric


 IF TYPE("M->C5_I_EST") = "C"
    Default _cProd 	   := aCols[n][Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_PRODUTO"	} )]
    Default _nPrcVen   := M->C6_PRCVEN
    Default _cTab      := M->C5_I_TAB
    Default _cUFPedV   := M->C5_I_EST
    Default _cTpVenda  := M->C5_I_TPVEN //F-> Carga Fechada / V-> Carga Varejo
    Default _cFil 	   := xFilial("SC5")
 ELSEIF FWIsInCallStack("U_AOMS115") .OR. FWIsInCallStack("U_AOMS112") .OR. FWIsInCallStack("U_AOMS050")
    Default _cProd 	   := SZW->ZW_PRODUTO
    Default _nPrcVen   := SZW->ZW_PRCVEN
    Default _cTab      := SZW->ZW_TABELA
    Default _cUFPedV   := SA1->A1_EST
    Default _cTpVenda  := SZW->ZW_TPVENDA// F-> Carga Fechada / V-> Carga Varejo
    Default _cFil 	   := SZW->ZW_FILIAL
 ELSE
    Default _cProd 	   := SC6->C6_PRODUTO
    Default _nPrcVen   := SC6->C6_PRCVEN
    Default _cTab      := SC5->C5_I_TAB
    Default _cUFPedV   := SC5->C5_I_EST
    Default _cTpVenda  := SC5->C5_I_TPVEN // F-> Carga Fechada / V-> Carga Varejo
    Default _cFil 	   := xFilial("SC5")
 ENDIF	
 Default _lShow     := .F.
 Default _lTrans    := .T. 
 Default _cGrupoP   := ""
 Default _lRetPrc   := .F.
 Default _lSimplNac := .F.
 Default _nPesoBrut :=0
 Default _nFaixa    :=0

 _lRegraNova:= SuperGetMV("IT_AMBTEST",.F.,.T.)
 _lRegraNova:= SuperGetMV("MV_ITMDREG",, _lRegraNova ) //O PARAMETRO DEVE SER CRIADO LOGICO
 _lRegraNova:= _lRegraNova .AND. ZGQ->(FIELDPOS("ZGQ_LOCEMB")) > 0 .AND. ZGQ->(FIELDPOS("ZGQ_SEGCLI")) 

 Begin Sequence

        _nPrecoIt := 0
        If FWIsInCallStack("U_AOMS032")  //N�o valida Pre�o na Transfer�ncia
            _lRet 	 := .F.
            Break
        Endif
        If FWIsInCallStack("U_AOMS112") .OR. FWIsInCallStack("U_AOMS015")
            _lPortal := .T.
        End
        If FWIsInCallStack("U_MOMS050") .OR. FWIsInCallStack("U_MOMS050R")
            _lWF := .T.
            _lPortal := .T.
        End
        If   FWIsInCallStack("U_AOMS109")
            _lShow := .F. //N�o apresenta mensagens
        Endif

        If _ltrans .And. !_lPortal .And. !_lWF//Se est� na tela de pedido de vendas puxa os dados da ahead e faz teste de libera��o de pre�os
            _nprcori 	 := aCols[n][Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_I_VLIBP"} )]
            _cTES    	 := aCols[n][Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_TES"	 } )]
            _cCF     	 := aCols[n][Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_CF"	 } )]
            //Se tem libera��o v�lida n�o faz valida��o de pre�o
            If M->C5_I_BLPRC = "L"  .And.  _nprcori == _nPrcVen
                _lRet 	 := .F.
                Break
            Endif

        Endif

        _lB1TipoPA := (Posicione( "SB1" , 1 , xFilial("SB1") + _cProd, "B1_TIPO"   ) = "PA")// JA DEIXA O SB1 PROCICIONADO
        _lF4DuplicS:= (_lPortal .OR. (Posicione( "SF4" , 1 , xFilial("SF4") + _cTES , "F4_DUPLIC" ) = "S" ))
        _lZAYTpOprV:= (_lPortal .OR. (Posicione( "ZAY" , 1 , xFilial("ZAY") + _cCF  , "ZAY_TPOPER") = "V" ))
        _cDescTBPrc:= ""
        _nPrcVen   := Round(_nPrcVen, 2)
        // Busca o grupo de produtos, caso a vari�vel _cGrupoP esteja vazia.
        If Empty(_cGrupoP)
           _cGrupoP := SB1->B1_GRUPO
        EndIf

        DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO
        _lAchou :=DA1->(DbSeek(xfilial("DA1")+_ctab+_cProd))
        
        //******************************************************************************************//
        //******************************************************************************************//
        If _lRegraNova .And. _lAchou //NOVA VALIDACAO POR CARGA FECHADA / CARGA FRACIONADA
        //******************************************************************************************//
        //******************************************************************************************//
           
           DA0->(Dbsetorder(1))
           DA0->(Dbseek(xFilial("DA0")+DA1->DA1_CODTAB))
           _cDescTBPrc:= AllTrim(DA1->DA1_CODTAB) + " - " + AllTrim(DA0->DA0_DESCRI)
           _nPrecoMax := DA1->DA1_PRCMAX

            //========================================================================
            // Obtem a filial de faturamento.
            //========================================================================
            If FWIsInCallStack("MATA410")
                _cFilFat  := M->C5_I_FILFT
                If Empty(_cFilFat)
                    _cFilFat := M->C5_FILIAL
                    If Empty(_cFilFat) .And. Inclui
                        _cFilFat := xFilial("SC5")
                    EndIf
                EndIf
            Else
                _cFilFat := _cFil
            EndIf

            _cUFFat:= Posicione("ZZM",1,xFilial("ZZM")+_cFilFat,"ZZM_EST")
            If AllTrim(_cUFFat) == AllTrim(_cUFPedV) // UF Fat = UF CLIENTE
               _nFatComercial := 1
            Else// UF Fat <> UF CLIENTE
               _cRegraFatC:=""
               _nFatComercial := BuscaFatComercial(_cFilFat, _cUFPedV, _cProd, _cGrupoP, @_cRegraFatC) // Carrega fator de convers�o para calculo do maior pre�os de vendas.
            EndIf

           If _cTpVenda  = "F" //F-> Carga Fechada
              _nPrecoIt := (DA1->DA1_I_PRF1 / _nFatComercial)
              _nPrcMin  := (DA1->DA1_I_PMF1 / _nFatComercial)
           ElseIf _cTpVenda  = "V" //V-> Carga Varejo / Fracionada
              _nPrecoIt := (DA1->DA1_I_PRF2 / _nFatComercial)
              _nPrcMin  := (DA1->DA1_I_PMF2 / _nFatComercial)
           Endif

            If _lSimplNac
                _nPercSimp := 1 + (DA1->DA1_I_SIMP / 100)
                _nPrecoIt := NoRound((_nPrecoIt * _nPercSimp),2)
            EndIf 

            If _nPrcVen < _nPrecoIt
                If FWIsInCallStack("MATA410") .and. !l410Auto  //n�o exibe mensagem do gatilho na efetiva��o de pedidos
                    If _lshow 
                        U_ItMsg("O pre�o informado est� MENOR que o Pre�o da Tabela: " + _cDescTBPrc + ;
                                " | Produto: " + ALLTRIM(_cProd) +;
                                " | Pre�o informado: " + AllTrim(Transform(_nPrcVen, '@E 9,999.9999')) +;
                                " | Pre�o da Tabela: " + AllTrim(Transform(_nPrecoIt, '@E 999,999,999.9999')),,;
                                "Pre�o Minimo: " + AllTrim(Transform(_nPrcMin, '@E 999,999,999.9999'))+CRLF+;
                                "Pre�o M�ximo: " + AllTrim(Transform(_nPrecoMax, '@E 9,999.9999')),3)
                    Else 
                       _cRetMsg :="Produto: " + ALLTRIM(_cProd)+" - O pre�o informado est� MENOR que o Pre�o da Tabela: " + AllTrim(Transform(_nPrecoIt , '@E 999,999,999.9999'))+CRLF+;
                                  "Pre�o informado: "  + AllTrim(Transform(_nPrcVen  , '@E 9,999.9999'))+" | Pre�o Minimo: "+ AllTrim(Transform(_nPrcMin  , '@E 9,999.9999')) + " | Pre�o M�ximo: "+ AllTrim(Transform(_nPrecoMax, '@E 9,999.9999')) + CRLF + CRLF
                       IF !FWIsInCallStack("U_MT410TOK")
                          _cRetMsg := "Tabela de Pre�o: "+ _cDescTBPrc+CRLF+_cRetMsg 
                       EndIf            
                    EndIf
                EndIf
                _lRet := .T.
            EndIf 
  
            If !_lRet .And. _nPrcVen > _nPrecoMax
                If FWIsInCallStack("MATA410") .and. !l410Auto  //n�o exibe mensagem do gatilho na efetiva��o de pedidos
                    If _lshow 
                       U_ItMsg("O pre�o informado est� MAIOR que o Pre�o M�ximo da Tabela: " + _cDescTBPrc + ;
                               " | Produto: " + AllTrim(_cProd) + ;
                               " | Pre�o informado: " + AllTrim(Transform(_nPrcVen, '@E 9,999.9999'))+;
                               " | Pre�o M�ximo: " + AllTrim(Transform(_nPrecoMax, '@E 999,999,999.9999')),,;
                               "Pre�o Minimo: "   + AllTrim(Transform(_nPrcMin, '@E 999,999,999.9999'))+CRLF+;
                               "Pre�o da Tabela: "+ AllTrim(Transform(_nPrecoIt, '@E 9,999.9999')),3)
                    else
                       _cRetMsg := "Produto: " + ALLTRIM(_cProd)+" - O pre�o informado est� MAIOR que o Pre�o M�ximo da Tabela: " + AllTrim(Transform(_nPrecoMax , '@E 999,999,999.9999'))+CRLF+;
                                   "Pre�o informado: "  + AllTrim(Transform(_nPrcVen  , '@E 9,999.9999'))+" | Pre�o Minimo: "+ AllTrim(Transform(_nPrcMin  , '@E 9,999.9999')) + " | Pre�o da Tabela: "+ AllTrim(Transform(_nPrecoIt, '@E 9,999.9999')) + CRLF + CRLF
                    Endif
                EndIf
                _lRet := .T.
            EndIf

        //******************************************************************************************************************//
        //**********  CALCULO ANTERIOR POR FAIXA E PESO ********************************************************************//
        ElseIf _lAchou .And. U_ItGetMv("IT_TABPRG",.F.)  //DEFINE SE TABELAS DE PRE�OS PERSONALZIADAS EST�O LIGADAS OU N�O
        //******************************************************************************************************************//
        //******************************************************************************************************************//

            DA0->(Dbsetorder(1))
            DA0->(Dbseek(xFilial("DA0")+DA1->DA1_CODTAB))
            _cDescTBPrc := AllTrim(DA1->DA1_CODTAB) + "-" + AllTrim(DA0->DA0_DESCRI)


            IF _nFaixa >= 1 .AND. _nFaixa <= 3
                If  _nFaixa = 3 
                    _nPrecoIt := DA1->DA1_I_PRF3
                    _nPrcMin  := DA1->DA1_I_PMF3
                ElseIf  _nFaixa == 2 
                    _nPrecoIt := DA1->DA1_I_PRF2
                    _nPrcMin  := DA1->DA1_I_PMF2
                ElseIf  _nFaixa = 1 
                    _nPrecoIt := DA1->DA1_I_PRF1
                    _nPrcMin  := DA1->DA1_I_PMF1
                EndIf
            ELSE
                If ((_nPesoBrut >=  DA0->DA0_I_PES3 .AND. _nPesoBrut <  DA0->DA0_I_PES2  ) )
                    _nPrecoIt := DA1->DA1_I_PRF3
                    _nPrcMin  := DA1->DA1_I_PMF3
                    _nFaixa   := 3
                ElseIf ((_nPesoBrut >=  DA0->DA0_I_PES2 .AND.  _nPesoBrut <  DA0->DA0_I_PES1) )
                    _nPrecoIt := DA1->DA1_I_PRF2
                    _nPrcMin  := DA1->DA1_I_PMF2
                    _nFaixa   := 2
                Else
                    _nPrecoIt := DA1->DA1_I_PRF1
                    _nPrcMin  := DA1->DA1_I_PMF1
                    _nFaixa   := 1
                EndIf
            EndIf

            _nPrecoMax := DA1->DA1_PRCMAX

            //========================================================================
            // Obtem a filial de faturamento.
            //========================================================================
            If FWIsInCallStack("MATA410")
                _cFilFat  := M->C5_I_FILFT
                If Empty(_cFilFat)
                    _cFilFat := M->C5_FILIAL
                    If Empty(_cFilFat) .And. Inclui
                        _cFilFat := xFilial("SC5")
                    EndIf
                EndIf
            Else
                _cFilFat := _cFil
            EndIf

            //========================================================================
            // Obtem a UF de faturamento.
            //========================================================================
            _nI       := AsCan(_aFiliais, {|x| x[5] == _cFilFat})
            _cCnpj    := _aFiliais[_nI,18]      // C5_FILIAL
            _cUFFat   := Posicione( "SA2" , 3 , xFilial("SA2") + _cCNPJ , "A2_EST" )
            _cFilOrig := cFilAnt

            //========================================================================
            // Se a vari�vel _cUFPedV est� vazia, deve ser igual UF de faturamento.
            //========================================================================
            If Empty(_cUFPedV)
                _cUFPedV := _cUFFat
            EndIf

            //========================================================================
            // Com base na filial, obtem o fator a ser aplicado sobre os valores de
            // venda. Quando o estado de faturamento for diferente do cliente,
            // aplica o percentual sobre o valores de vendas definidos para o produto.
            //========================================================================
            cFilAnt     := _cFilFat // M->C5_I_FILFT// C5_FILIAL

            _nFatComercial := U_ItGetMv("IT_FATMINPR",1) // Carrega fator de convers�o para calculo do maior pre�os de vendas.

            cFilAnt     := _cFilOrig

            If AllTrim(_cUFFat) == AllTrim(_cUFPedV) // UF Fat <> UF CLIENTE
                _nFatComercial := 1
            EndIf

            //========================================================================
            // Compara o valor digitado com os valores de vendas obtidos e com o
            // valor do plano de neg�cio, e com o valor m�ximo do produto, para
            // verifica��o de bloqueio de pre�o.
            //========================================================================

            // Pre�o plano de neg�cios. VER SE TEM VALOR  NO DA1_I_PTBN // Pre�o m�ximo.    // SE TEM VALOR NO DA1_PRCMAX.

            If _lSimplNac
                _nPercSimp := 1 + (DA1->DA1_I_SIMP / 100)
                _nPrecoIt := NoRound((_nPrecoIt * _nPercSimp),2)
            EndIf 
 
            If _nPrcVen <  _nPrecoIt

                If FWIsInCallStack("MATA410").and. !l410Auto  //n�o exibe mensagem do gatilho na efetiva��o de pedidos
                    If _lshow 
                        U_ItMsg("4 - O pre�o informado est� menor que o Pre�o da Tabela: " + _cDescTBPrc + ;
                            " | Produto: " + _cProd +;
                            " | Pre�o da Tabela: " + AllTrim(Transform(_nPrecoIt, '@E 999,999,999.9999')) +;
                            " | Pre�o Minimo: " + AllTrim(Transform(_nPrcMin, '@E 999,999,999.9999')) , "Valida��o de pre�o pela Faixa " + alltrim(str(_nFaixa) + " Peso Pedido " + AllTrim(Transform(_nPesoBrut, '@E 9,999.9999'))  +CRLF) ,,3)     // COLOCAR AS MENSAGENS SEPARADAS. SEPARAR O IFS.
                    Else 
                        _cRetMsg := "4 - O pre�o informado est� menor que o Pre�o da Tabela: " + _cDescTBPrc + " | Produto: " + _cProd + " | Pre�o: " + AllTrim(Transform(_nPrecoIt, '@E 9,999.9999')) + " | Pre�o Minimo: " + AllTrim(Transform(_nPrcMin, '@E 9,999.9999')) + " Valida��o de pre�o pela Faixa " + alltrim(str(_nFaixa)) + " Peso Pedido " + AllTrim(Transform(_nPesoBrut, '@E 999,999,999.9999')) +CRLF 
                    EndIf
                EndIf
                _lRet := .T.
            EndIf 
  
            If !_lRet .And. _nPrcVen > _nPrecoMax
                If FWIsInCallStack("MATA410") .and. !l410Auto  //n�o exibe mensagem do gatilho na efetiva��o de pedidos
                    If _lshow 
                    U_ItMsg("O pre�o informado est� maior que o Pre�o M�ximo: " +  AllTrim(Transform(_nPrecoMax, '@E 999,999,999.9999')) + _cDescTBPrc + ;
                        " | Produto: " + _cProd + ;
                        " | Pre�o da Tabela: " + AllTrim(Transform(_nPrecoIt, '@E 999,999,999.9999')) +;
                        " | Pre�o Minimo: " + AllTrim(Transform(_nPrcMin, '@E 999,999,999.9999')) , "Valida��o de pre�o pela Faixa " + alltrim(str(_nFaixa) + " Peso Pedido " + AllTrim(Transform(_nPesoBrut, '@E 999,999,999.9999'))  +CRLF) ,,3)     // COLOCAR AS MENSAGENS SEPARADAS. SEPARAR O IFS.						
                    else
                        _cRetMsg := "5 - O pre�o informado est� maior que o Pre�o M�ximo: " +  AllTrim(Transform(_nPrecoMax, '@E 9,999.9999')) + _cDescTBPrc + " | Produto: " + _cProd + " | Pre�o: " + AllTrim(Transform(_nPrecoIt, '@E 999,999,999.9999')) + " | Pre�o Minimo: " + AllTrim(Transform(_nPrcMin, '@E 9,999.9999')) + " Valida��o de pre�o pela Faixa " + alltrim(str(_nFaixa)) + " Peso Pedido " + AllTrim(Transform(_nPesoBrut, '@E 999,999,999.9999')) + CRLF
                    Endif
                EndIf
                _lRet := .T.
            EndIf

        ElseIf _lB1TipoPA .AND. (( _lF4DuplicS .AND. _lZAYTpOprV ) .OR. _lPortal .OR. FWIsInCallStack("U_ALTERAP"))

            If _lshow .and. FWIsInCallStack("MATA410") .and. !l410Auto  //n�o exibe mensagem do gatilho na efetiva��o de pedidos

                u_itmsg("O produto "+ alltrim(_cProd) + " n�o tem cadastro de pre�os na tabela de pre�os " + _cDescTBPrc + ".", "Valida��o de pre�o",,3)

            Endif

            _lRet := .T.

        EndIf 

        //====================================================
        //| Atualiza o campo C6_I_VLIBP com o Pre�o Digitado |
        //====================================================

        If !(_lRet) .and. !(_ltrans) .And. FWIsInCallStack("MATA410")

            aCols[n][Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_I_VLIBP" })] := _nPrcVen

        EndIf

        If _lRetPrc .And. !(_ltrans) .And. FWIsInCallStack("MATA410")
            _nPosPrc := Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_PRCVEN"	} )
            If _nPrecoIt > 0
                aCols[n][_nPosPrc] := _nPrecoIt
            EndIf

            aCols[n][Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_I_FXPES" })] := _nFaixa
        EndIf

 End Sequence

    //        1       2        3         4           5          6            7
 _aRet := {_lRet, _nFaixa, _cRetMsg , _nPrecoIt , _nPrcMin ,_nPrecoMax, _cDescTBPrc}

Return _aRet

/*
===============================================================================================================================
Programa----------: BuscaFatComercial
Autor-------------: Alex Wallauer
Data da Criacao---: 07/01/2025
Descri��o---------: Busca do Fator Comercial por Produto ou Grupo x Filial de Faturamento e UF do Cliente
Parametros--------: _cFilFat.......: Filial de Faturamento
                    _cUF...........: UF do Cliente
                    _cProd.........: C�digo do Produto
                    _cGrupo........: Grupo do Produto
                    @_cRegraFatC...: Regra da Busca encontrada
Retorno-----------: _nFatComercial.: Fator Comercial
===============================================================================================================================
*/  
Static Function BuscaFatComercial(_cFilFat As Char, _cUF As Char, _cProd As Char, _cGrupo As Char, _cRegraFatC As Char) As Numeric
 LOCAL _aRegras   := {} As Array
 LOCAL _aOrdBusca := {} As Array , A As Numeric
 LOCAL _cB_Prod   := SPACE(LEN(ZAF->ZAF_PROD )) As Char
 LOCAL _cB_Grupo  := SPACE(LEN(ZAF->ZAF_GRUPO)) As Char
 LOCAL _nFatComercial := 1 As Numeric
 Default _cProd := _cB_Prod
 Default _cGrupo:= _cB_Grupo
 
 AADD(_aOrdBusca, _cProd + _cB_Grupo )// ORDEM 01
 AADD(_aRegras, "Regra por produto: "+_cFilFat +" "+_cUF +" "+ _cProd)
 
 AADD(_aOrdBusca, _cB_Prod + _cGrupo )// ORDEM 02
 AADD(_aRegras, "Regra por Grupo: "+_cFilFat +" "+_cUF +" "+ _cGrupo)
 
 ZAF->(DBSETORDER(1))
 FOR A := 1 TO LEN(_aOrdBusca)

    ZAF->(Dbseek(xfilial()+_cFilFat+_cUF+_aOrdBusca[A]))
     
     Do While .not. ZAF->(Eof()) .AND. ZAF->(ZAF_FILIAL+ZAF_FILFAT+ZAF_UF) == xfilial("ZAF")+_cFilFat+_cUF ;
                                .AND. ZAF->(ZAF_PROD+ZAF_GRUPO)           == _aOrdBusca[A]

        If ZAF->ZAF_MSBLQL = "1"  //Registro Bloqueado
            ZAF->(Dbskip())
            Loop
         Endif
         
         _cRegraFatC:= _aRegras[A]
         _nFatComercial:= ZAF->ZAF_FATOR
                 
         EXIT
 
     Enddo

 NEXT A
 
RETURN _nFatComercial

/*
===============================================================================================================================
Programa...: PEDPORT
Autor......: Erich Buttner
Data.......: 15/07/2013
===============================================================================================================================
Descricao..: Verifica se o pedido veio do portal e n�o permite altera��o de algumas informa��es    
===============================================================================================================================
Parametros.: _cpedportal - id do pedido do portal
===============================================================================================================================
Retorno....: Nenhum
===============================================================================================================================
*/
User Function PEDPORT(_cPedPortal)

    Local _nPosProduto := 0
    Local _lret := .T.

    _nPosProduto	:=  ascan(aHeader,{|x| alltrim(x[2])=="C6_PRODUTO"})

    If Empty(AllTrim(_cPedPortal))

        _lRet := .T.

    Else

        If Empty(AllTrim(aCols [n,_nPosProduto]))

            u_itmsg('Pedido de Venda vindo do Portal, n�o � Permitido Incluir Item','Aten��o!','Caso necess�rio solicite a manuten��o = um usu�rio com acesso ou, se necess�rio, solicite o acesso � �rea de TI/ERP.',1)
            _lRet := .F.

        Else

            If !(U_ITVACESS( 'ZZL' , 3 , 'ZZL_PEDPOR' , "S" ))

                u_itmsg('Pedido de Venda vindo do Portal, n�o � Permitido Altera��o desta informa��o por esse usu�rio','Aten��o!','Caso necess�rio solicite a manuten��o = um usu�rio com acesso ou, se necess�rio, solicite o acesso � �rea de TI/ERP.',1)

                _lRet := .F.

            Endif

        EndIf

    EndIf

Return _lRet

/*
===============================================================================================================================
Programa...: BLQMOTO
Autor......: Erich Buttner
Data.......: 31/07/2013
===============================================================================================================================
Descricao..: Verifica se o usuario tem permiss�o para bloquear motorista   
===============================================================================================================================
Parametros.: Nenhum
===============================================================================================================================
Retorno....: Nenhum
===============================================================================================================================
*/

User Function BLQMOTO()

    lRet := .F.
    cUser	:=  U_UCFG001(1)
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial("ZZL")+cUser))
        If ZZL->ZZL_BLQMOT == 'S'
            lRet := .T.
        EndIf
    EndIf

Return lRet

/*
===============================================================================================================================
Programa----------: ITCALIMP
Autor-------------: Alexandre Villar
Data da Criacao---: 24/07/2014
===============================================================================================================================
Descri��o---------: Funcao utilizada para calcular os impostos do RPA.
===============================================================================================================================
Parametros--------: _adadAux - array com dados do rpa
===============================================================================================================================
Retorno-----------: _aRet[01]	:= IIF(	_nVlrSest < 0	, 0			, _nVlrSest	)		//M->ZZA_SEST
                    _aRet[02]	:= IIF(	_nVlrInss < 0	, 0			, _nVlrInss	)		//M->ZZA_INSS
                    _aRet[03]	:= IIF( _lGravVl		, _nVlrIrrf	, 0			)		//M->ZZA_IRRF
                    _aRet[04]	:= _aDadAux[02] - ( _nVlrSest + _nVlrInss + _aRet[03] )	//M->ZZA_VLRLIQ
===============================================================================================================================
*/

User Function ITCALIMP( _aDadAux )

    //_aDadAux
    //01 - M->ZZA_CODAUT
    //02 - M->ZZA_VLRBRT
    //03 - M->ZZA_CONPAG
    //04 - M->ZZA_TPFORN

    Local _aRet				:= Array( 04 )
    Local nBaseIR			:= GETMV( 'IT_BSIRRF' ,, 0 )
    Local _nVlrDep          := 0
    Local _cAliaINSS        := GetNextAlias()
    Local _cAliaIRRF		:= GetNextAlias()
    Local _cAliaReci        := GetNextAlias()
    Local _cFilCorr         := ""
    Local _nValAcm			:= 0

    Private _cRecibo		:= ""
    Private _nVlrIrrfPag	:= 0
    Private _nTeto			:= 0
    Private _nbaseSest		:= 0
    Private _nVlrSest 		:= 0
    Private _nbaseinss		:= 0
    Private _nvlrinss 		:= 0
    Private _nVlrIrrf 		:= 0
    Private _x08_Lim3		:= Nil
    Private _x08_Lim3P		:= Nil
    Private _x09_rend1		:= Nil
    Private _x09_rend2		:= Nil
    Private _x09_rend3		:= Nil
    Private _x09_rend4		:= Nil
    Private _x09_rend5		:= Nil
    Private _x09_aliq2		:= Nil
    Private _x09_aliq3		:= Nil
    Private _x09_aliq4		:= Nil
    Private _x09_aliq5		:= Nil
    Private _x09_parc2		:= Nil
    Private _x09_parc3		:= Nil
    Private _x09_parc4		:= Nil
    Private _x09_parc5		:= Nil
    Private _x09_deddep		:= Nil
    Private _x09_limdep		:= Nil
    Private _x09_retmin		:= Nil

    Public	_lGravVl 		:= .F.

    If ( _aDadAux[02] > 0 ) .And. !Empty( _aDadAux[03] ) .And. !Empty( _aDadAux[04] ) .And. !Empty( _aDadAux[01] )

        //================================================================================
        //| Caso o Fornecedor seja Fretista calcula SEST/SENAT                           |
        //================================================================================
        If _aDadAux[04] == 'F'

            _nbaseSest	:=	_aDadAux[02]	* GETMV( 'IT_BSSEST'	,, 0 ) / 100
            _nVlrSest 	:=	_nBaseSest 		* GETMV( 'IT_VLRSEST'	,, 0 ) / 100

        EndIf

        //================================CALCULO DO INSS=================================
        //| Calcula e Verifica se total de INSS do mes nao ultrapassou o teto            |
        //================================================================================
        U_ValINSS()

        _nTeto	:= NoRound( _x08_Lim3 * _x08_Lim3P / 100 , 2 )

        _cQuery := " SELECT "
        _cQuery += " 	SUM(INSS) AS INSS "
        _cQuery += " FROM ( "

        _cQuery += " 	SELECT "
        _cQuery += " 		ZZ2_AUTONO		AS COD	, "
        _cQuery += " 		SUM(ZZ2_INSS)	AS INSS	  "
        _cQuery += " 	FROM "+ RetSqlName("ZZ2") +" ZZ2 "
        _cQuery += " 	WHERE "
        _cQuery += " 		ZZ2.D_E_L_E_T_				= ' ' "
        _cQuery += " 	AND	ZZ2_AUTONO    				= '"+ _aDadAux[01] +"' "
        _cQuery += " 	AND	EXISTS ( "
        _cQuery += " 					SELECT DAI.R_E_C_N_O_ AS REGDAI "
        _cQuery += "				 	FROM "+ RetSqlName("DAI") +" DAI "
        _cQuery += " 					INNER JOIN "+ RetSqlName("SF2") +" SF2 "
        _cQuery += " 					ON	SF2.F2_FILIAL				= DAI.DAI_FILIAL "
        _cQuery += " 					AND	SF2.F2_DOC					= DAI.DAI_NFISCA "
        _cQuery += " 					AND SF2.F2_SERIE				= DAI.DAI_SERIE "
        _cQuery += " 					AND SUBSTR(SF2.F2_EMISSAO,5,2)	= '"+ StrZero( Month(dDataBase)	, 2 ) +"' "
        _cQuery += " 					AND SUBSTR(SF2.F2_EMISSAO,1,4)	= '"+ StrZero( YEAR(dDataBase)	, 4 ) +"' "
        _cQuery += " 					AND SF2.D_E_L_E_T_				= ' ' "
        _cQuery += " 					WHERE "
        _cQuery += " 						DAI.DAI_FILIAL      = ZZ2.ZZ2_FILIAL "
        _cQuery += " 					AND DAI.DAI_COD         = ZZ2.ZZ2_CARGA "
        _cQuery += " 					AND DAI.D_E_L_E_T_      = ' ' "
        _cQuery += " 				) "
        _cQuery += " 	GROUP BY ZZ2_AUTONO "

        _cQuery += " 	UNION ALL "

        _cQuery += " 	SELECT "
        _cQuery += " 		ZZ2_AUTONO		AS COD	, "
        _cQuery += " 		SUM(ZZ2_INSS)	AS INSS	  "
        _cQuery += " 	FROM "+ RetSqlName("ZZ2") +" ZZ2 "

        _cQuery += " 	WHERE "
        _cQuery += " 		ZZ2.D_E_L_E_T_				= ' ' "
        _cQuery += " 	AND	ZZ2.ZZ2_CARGA  				= ' ' "
        _cQuery += " 	AND	ZZ2_AUTONO    				= '"+ _aDadAux[01] +"' "
        _cQuery += " 	AND SUBSTR(ZZ2.ZZ2_DATA,5,2)	= '"+ StrZero( Month(dDataBase)	, 2 ) +"' "
        _cQuery += " 	AND SUBSTR(ZZ2.ZZ2_DATA,1,4)	= '"+ StrZero( YEAR(dDataBase)	, 4 ) +"' "

        _cQuery += " 	GROUP BY ZZ2_AUTONO "

        _cQuery += " 	ORDER BY INSS ) "

        MPSysOpenQuery( _cQuery , _cAliaINSS)

        (_cAliaINSS)->( DBGoTop() )
        If (_cAliaINSS)->( !Eof() )

            //================================================================================
            //| Tipo do Fornecedor igual a Fretista                                          |
            //================================================================================
            If _aDadAux[04] == 'F'

                _nCorrentVlrINSS := ( _aDadAux[02] * GETMV( 'IT_BSINSS' ,, 0 ) / 100 ) * GETMV('IT_VLRINSS') / 100

                If (_cAliaINSS)->INSS + _nCorrentVlrINSS < _nteto

                    _nbaseinss	:= _aDadAux[02]	* GETMV( 'IT_BSINSS'	,, 0 ) / 100
                    _nvlrinss	:= _nbaseinss	* GETMV( 'IT_VLRINSS'	,, 0 ) / 100

                Else

                    If (_cAliaINSS)->INSS + _nCorrentVlrINSS - _nteto > 0

                        _nbaseinss	:= _aDadAux[02] * GETMV( 'IT_BSINSS' ,, 0 ) / 100
                        _nvlrinss	:= _nteto - (_cAliaINSS)->INSS

                    EndIf

                EndIf

                //================================================================================
                //| Outros                                                                       |
                //================================================================================
            Else

                _nCorrentVlrINSS := _aDadAux[02] * GETMV( 'IT_VLRINSS' ,, 0 ) / 100

                If (_cAliaINSS)->INSS + _nCorrentVlrINSS < _nteto

                    _nvlrinss := _aDadAux[02] * GETMV( 'IT_VLRINSS' ,, 0 ) / 100

                Else

                    If (_cAliaINSS)->INSS + _nCorrentVlrINSS - _nteto > 0

                        _nvlrinss :=_nteto - (_cAliaINSS)->INSS

                    EndIf

                EndIf

            EndIf

        EndIf

        (_cAliaINSS)->( DBCloseArea() )

        //================================CALCULO DO IRRF=================================
        //| Busca dados das aliquotas nas tabelas de IRRF                                |
        //================================================================================
        _nBaseIrrf	:= 0
        u_ValIRRF()

        //================================================================================
        //| Adicionado por Guilherme 15/10/2012 para tratar filial autonomo              |
        //================================================================================
        _cFilCorr	:= cFilAnt
        cFilAnt		:= "01"

        SRA->( DBSeek( xFILIAL("SRA") + _aDadAux[01] ) )
        _nVlrDep	:= ValidDep( xFILIAL("SRA") , _aDadAux[01] ) * _x09_deddep  // calculo do valor a deduzir por dependente
        cFilAnt		:= _cFilCorr

        //================================================================================
        //| Recupera os valores j� calculados anteriormente para o mesmo per�odo         |
        //================================================================================
        _cQuery := " SELECT "
        _cQuery += " 	SUM(SEST)	AS SEST	, "
        _cQuery += " 	SUM(INSS)	AS INSS	, "
        _cQuery += " 	SUM(TOTAL)	AS TOTAL, "
        _cQuery += " 	SUM(IRRF)	AS IRRF	, "
        _cQuery += " 	COUNT(INSS)	AS CONT	, "
        _cQuery += " 	SUM(PEDAG)	AS PEDAG  "

        _cQuery += " FROM ( "

        _cQuery += " 	SELECT "
        _cQuery += " 		ZZ2_AUTONO		AS COD	, "
        _cQuery += " 		SUM(ZZ2_SEST)	AS SEST	, "
        _cQuery += " 		SUM(ZZ2_INSS)	AS INSS	, "
        _cQuery += " 		SUM(ZZ2_TOTAL)	AS TOTAL, "
        _cQuery += " 		SUM(ZZ2_IRRF)	AS IRRF	, "
        _cQuery += " 		COUNT(ZZ2_INSS)	AS CONT , "
        _cQuery += " 		SUM(ZZ2_VRPEDA)	AS PEDAG  "
        _cQuery += " 	FROM "+ RetSqlName("ZZ2") +" ZZ2 "
        _cQuery += " 	WHERE "
        _cQuery += " 		ZZ2.D_E_L_E_T_				= ' ' "
        _cQuery += " 	AND	ZZ2_AUTONO    				= '"+ _aDadAux[01] +"' "
        _cQuery += " 	AND	EXISTS ( "
        _cQuery += " 					SELECT DAI.R_E_C_N_O_ AS REGDAI "
        _cQuery += "				 	FROM "+ RetSqlName("DAI") +" DAI "
        _cQuery += " 					INNER JOIN "+ RetSqlName("SF2") +" SF2 "
        _cQuery += " 					ON	SF2.F2_FILIAL				= DAI.DAI_FILIAL "
        _cQuery += " 					AND	SF2.F2_DOC					= DAI.DAI_NFISCA "
        _cQuery += " 					AND SF2.F2_SERIE				= DAI.DAI_SERIE "
        _cQuery += " 					AND SUBSTR(SF2.F2_EMISSAO,5,2)	= '"+ StrZero( Month(dDataBase)	, 2 ) +"' "
        _cQuery += " 					AND SUBSTR(SF2.F2_EMISSAO,1,4)	= '"+ StrZero( YEAR(dDataBase)	, 4 ) +"' "
        _cQuery += " 					AND SF2.D_E_L_E_T_				= ' ' "
        _cQuery += " 					WHERE "
        _cQuery += " 						DAI.DAI_FILIAL      = ZZ2.ZZ2_FILIAL "
        _cQuery += " 					AND DAI.DAI_COD         = ZZ2.ZZ2_CARGA "
        _cQuery += " 					AND DAI.D_E_L_E_T_      = ' ' "
        _cQuery += " 				) "
        _cQuery += " 	GROUP BY ZZ2_AUTONO "

        _cQuery += " 	UNION ALL "

        _cQuery += " 	SELECT "
        _cQuery += " 		ZZ2_AUTONO		AS COD	, "
        _cQuery += " 		SUM(ZZ2_SEST)	AS SEST	, "
        _cQuery += " 		SUM(ZZ2_INSS)	AS INSS	, "
        _cQuery += " 		SUM(ZZ2_TOTAL)	AS TOTAL, "
        _cQuery += " 		SUM(ZZ2_IRRF)	AS IRRF	, "
        _cQuery += " 		COUNT(ZZ2_INSS)	AS CONT	, "
        _cQuery += " 		SUM(ZZ2_VRPEDA)	AS PEDAG  "
        _cQuery += " 	FROM "+ RetSqlName("ZZ2") +" ZZ2 "

        _cQuery += " 	WHERE "
        _cQuery += " 		ZZ2.D_E_L_E_T_				= ' ' "
        _cQuery += " 	AND	ZZ2.ZZ2_CARGA  				= ' ' "
        _cQuery += " 	AND	ZZ2_AUTONO    				= '"+ _aDadAux[01] +"' "
        _cQuery += " 	AND SUBSTR(ZZ2.ZZ2_DATA,5,2)	= '"+ StrZero( Month(dDataBase)	, 2 ) +"' "
        _cQuery += " 	AND SUBSTR(ZZ2.ZZ2_DATA,1,4)	= '"+ StrZero( YEAR(dDataBase)	, 4 ) +"' "

        _cQuery += " 	GROUP BY ZZ2_AUTONO "

        _cQuery += " 	ORDER BY COD ) "

        MPSysOpenQuery( _cQuery , _cAliaIRRF)

        (_cAliaIRRF)->( DBGoTop() )

        //================================================================================
        //| Valida o valor bruto de acordo com o identificador da chamada                |
        //================================================================================
        If _aDadAux[05] == 1
            _nValAcm := ((_cAliaIRRF)->TOTAL - (_cAliaIRRF)->PEDAG) + _aDadAux[02]
        ElseIf _aDadAux[05] == 2
            _nValAcm := ((_cAliaIRRF)->TOTAL - (_cAliaIRRF)->PEDAG)
        Else
            _nValAcm := 0
        EndIf

        //================================================================================
        //| Tipo do Fornecedor igual a Fretista                                          |
        //================================================================================
        If _aDadAux[04] == 'F'

            If (_cAliaIRRF)->( !Eof() ) .And. (_cAliaIRRF)->CONT > 0

                _nbaseirrf 		:= 	( _nValAcm * nBaseIR ) / 100
                _nbaseirrf 		-= 	_nVlrDep //deduz por dependente
                _nbaseirrf 		-= 	( (_cAliaIRRF)->INSS + _nvlrinss + _nVlrSest + (_cAliaIRRF)->SEST ) // deduz INSS
                _nVlrIrrfPag 	:=	(_cAliaIRRF)->IRRF

            Else

                _nbaseirrf		:= ( _aDadAux[02] * nBaseIR ) / 100
                _nbaseirrf		-= (_nVlrDep)   // deduz por dependente
                _nbaseirrf		-= (_nvlrinss+_nVlrSest) // deduz INSS
                _nVlrIrrfPag	:= 0

            EndIf

            //================================================================================
            //| Outros                                                                       |
            //================================================================================
        Else

            If !Eof() .And. (_cAliaIRRF)->CONT > 0

                _nbaseirrf 		:= 	( _nValAcm )
                _nbaseirrf 		-= 	(_nVlrDep) //deduz por dependente
                _nbaseirrf 		-= 	( (_cAliaIRRF)->INSS + _nvlrinss ) //deduz INSS
                _nVlrIrrfPag 	:=	(_cAliaIRRF)->IRRF

            Else

                _nbaseirrf		:= ( _aDadAux[02]	)
                _nbaseirrf		-= ( _nVlrDep		) //deduz por dependente
                _nbaseirrf		-= ( _nvlrinss		) //deduz INSS
                _nVlrIrrfPag	:= 0

            EndIf

        EndIf

        (_cAliaIRRF)->( DBCloseArea() )

        _cQuery	:=	""

        If		_nBaseIrrf	> _x09_rend1	.And. _nBaseIrrf	<= _x09_rend2

            _nVlrIrrf := ( _nbaseirrf * _x09_aliq2 ) / 100
            _nvlrIrrf -= _x09_parc2

        ElseIf	_nBaseIrrf	> _x09_rend2	.And. _nBaseIrrf	<= _x09_rend3

            _nVlrIrrf := ( _nbaseirrf * _x09_aliq3 ) / 100
            _nvlrIrrf -= _x09_parc3

        ElseIf	_nBaseIrrf	> _x09_rend3	.And. _nBaseIrrf	<= _x09_rend4

            _nVlrIrrf := ( _nbaseirrf * _x09_aliq4 ) / 100
            _nvlrIrrf -= _x09_parc4

        ElseIf	_nBaseIrrf	> _x09_rend4	.And. _nBaseIrrf	<= _x09_rend5

            _nVlrIrrf := ( _nbaseirrf * _x09_aliq5 ) / 100
            _nvlrIrrf -= _x09_parc5

        Else

            _nVlrIrrf := 0

        EndIf

        If _nVlrIrrf > 0

            _cQuery := " SELECT COUNT(ZZ2_RECIBO) AS CONTADOR "
            _cQuery += " FROM "+RetSqlName("ZZ2")
            _cQuery += " WHERE "
            _cQuery += " 	SubStr(ZZ2_DATA,5,2)	= "+ StrZero(Month(dDataBase),2)	+" AND "
            _cQuery += " 	SubStr(ZZ2_DATA,1,4)	= "+ StrZero(YEAR(dDataBase),4)		+" AND "
            _cQuery += " 	ZZ2_AUTONO		   		= '"+ _aDadAux[01]					+"' AND "
            _cQuery += " 	D_E_L_E_T_		   		= ' ' AND "
            _cQuery += " 	ZZ2_IRRF > 0 "

            MPSysOpenQuery( _cQuery , _cAliaReci)

            (_cAliaReci)->( DBGoTop() )

            If (_cAliaReci)->CONTADOR == 0 //e o primeiro recibo

                If _nVlrIrrf < GETMV( 'MV_VLRETIR' ,, 0 ) //se o 1Recibo for menor que 10 nao deve gravar valor

                    _lGravVl	:= .F.

                ElseIf _nVlrIrrf >= GETMV( 'MV_VLRETIR' ,, 0 )

                    _lGravVl	:= .T.
                    _nVlrIrrf	-= _nVlrIrrfPag

                EndIf

                //================================================================================
                //| Se n�o for o primeiro recibo, gravar subtraindo os valores j� retidos        |
                //================================================================================
            ElseIf (_cAliaReci)->CONTADOR > 0

                If ( _nVlrIrrf + _nVlrIrrfPag ) < GETMV( 'MV_VLRETIR' ,, 0 ) //se soma do imoposta maior que limite minimo

                    _lGravVl := .F.

                ElseIf ( _nVlrIrrf + _nVlrIrrfPag ) >= GETMV( 'MV_VLRETIR' ,, 0 )

                    _lGravVl := .T.

                    If		_nVlrIrrf >= _nVlrIrrfPag //Se valor a reter for maior ou igual ao somatorio dos retidos

                        _nVlrIrrf -= _nVlrIrrfPag

                    ElseIf	_nVlrIrrf < _nVlrIrrfPag//Se for menor, fica com o valor calculado mesmo.

                        _nVlrIrrf := _nVlrIrrf

                    EndIf

                EndIf

            EndIf

            (_cAliaReci)->( DBCloseArea() )

        EndIf

        _nVlrIrrf	:= IIF( _nVlrIrrf < 0	, 0			, _nVlrIrrf	)
        _aRet[01]	:= IIF(	_nVlrSest < 0	, 0			, _nVlrSest	)		//M->ZZA_SEST
        _aRet[02]	:= IIF(	_nVlrInss < 0	, 0			, _nVlrInss	)		//M->ZZA_INSS
        _aRet[03]	:= IIF( _lGravVl		, _nVlrIrrf	, 0			)		//M->ZZA_IRRF
        _aRet[04]	:= _aDadAux[02] - ( _nVlrSest + _nVlrInss + _aRet[03] )	//M->ZZA_VLRLIQ

    EndIf

Return( _aRet )

/*
===============================================================================================================================
Programa----------: ITVLDSRA
Autor-------------: Alexandre Villar
Data da Criacao---: 01/08/2014
===============================================================================================================================
Descri��o---------: Funcao que valida o c�digo da Matr�cula do Aut�nomo
===============================================================================================================================
Parametros--------: _ccodAut - C�digo do autonomo
===============================================================================================================================
Retorno-----------: _lret - matricula v�lida ou n�o
===============================================================================================================================
*/

User Function ITVLDSRA( _cCodAut )

    Local _lRet		:= .T.
    Local _cQuery	:= ""
    Local _cAlias	:= GetNextAlias()

    _cQuery := " SELECT "
    _cQuery += " 	RA_MAT		,"
    _cQuery += " 	RA_NOMECMP	,"
    _cQuery += " 	RA_CIC		 "
    _cQuery += " FROM "+ RetSqlName("SRA") +" SRA "
    _cQuery += " WHERE "
    _cQuery += " 		D_E_L_E_T_	= ' ' "
    _cQuery += " AND	RA_MAT		= '"+ _cCodAut +"' "
    _cQuery += " AND	RA_FILIAL	= '01' "
    _cQuery += " AND	RA_CATFUNC	= 'A' "

    MPSysOpenQuery( _cQuery , _cAlias)

    (_cAlias)->( DBGoTop() )

    If (_cAlias)->(Eof()) .Or. Empty( (_cAlias)->RA_MAT )
        _lRet := .F.
    EndIf

    (_cAlias)->( DBCloseArea() )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ValidDep
Autor-------------: Tiago Correa Castro
Data da Criacao---: 25/01/2009
===============================================================================================================================
Descri��o---------: Funcao para verificar dependentes do Autonomo.
===============================================================================================================================
Parametros--------: Filial - Filial do autonomo
                    Matric - c�digo do autonomo
===============================================================================================================================
Retorno-----------: nRet -  Numero de dependente.
===============================================================================================================================
*/

Static Function ValidDep( Filial , Matric )

    Local _nRet		:= 0

    SRA->( DBSetOrder(1) ) //RA_FILIAL+RA_MAT
    SRA->( DBSeek( Filial + Matric ) )

    SRB->( DBSetOrder(1) ) //RB_FILIAL+RB_MAT
    If SRB->( DBSeek( Filial + Matric ) )

        While SRB->( !Eof() ) .And. SRB->RB_FILIAL + SRB->RB_MAT == Filial + Matric

            If SRB->RB_TIPIR == "1"
                _nRet++
            ElseIf SRB->RB_TIPIR == "2" .And. ( dDataBase - SRB->RB_DTNASC ) / 360 <= 21
                _nRet++
            ElseIf SRB->RB_TIPIR == "3" .And. ( dDataBase - SRB->RB_DTNASC ) / 360 <= 24
                _nRet++
            EndIf

            SRB->( DBSkip() )
        EndDo

        If _nRet < Val(SRA->RA_DEPIR)
            _nRet := _nRet + ( Val(SRA->RA_DEPIR) - _nRet )
        EndIf

    EndIf

Return(_nRet)

/*
===============================================================================================================================
Programa----------: ValINSS
Autor-------------: Tiago Correa Castro
Data da Criacao---: 25/01/2009
===============================================================================================================================
Descri��o---------: Funcao para validar tabela de calculo de INSS para recolhimento do Autonomo.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function ValINSS()

    Local _cMesAtual:= SubStr(dtos(Date()),1,4)+SubStr(dtos(Date()),5,2)
    Local _cDtIni   :=_cMesAtual
    Local _cDtfim   :=_cMesAtual
    Local _lPassou  := .F.
    Local _nValRCC, _nMaxVal

    _x08_Lim3 := 0//Zera pra n�o far erro.log
    _x08_Lim3P:= 0//Zera pra n�o far erro.log
    _nMaxVal := 0

    _NI := 0
    RCC->( DBSetOrder(1) )
    If RCC->( DBSeek( xFILIAL("RCC") + "S001" ))

        Do while RCC->RCC_FILIAL == xFILIAL("RCC") .and. RCC->RCC_CODIGO == "S001"

            _cDtIni:=SUBSTR(RCC->RCC_CONTEU,1,6)//Novo conteudo RCC->RCC_CONTEU = 201801201812     1693.72  8.000  8.000
            _cDtfim:=SUBSTR(RCC->RCC_CONTEU,7,6)//Novo conteudo RCC->RCC_CONTEU = 201801201812     1693.72  8.000  8.000

            If _cMesAtual >= _cDtIni .AND. _cMesAtual <= _cDtfim

                _NI++
                _nValRCC := Val(AllTrim(SubStr(RCC->RCC_CONTEU,13,12)))
                If _nValRCC > _nMaxVal
                    _nMaxVal	:= _nValRCC
                    _x08_Lim3 := Val( SubStr( RCC->RCC_CONTEU , 13 , 12  ) ) // Sl.Contr Ate
                    _x08_Lim3P := Val( SubStr( RCC->RCC_CONTEU , 25 , 7 ) ) // % Desc. INSS
                    _lPassou:=.T.
                EndIf

            Endif

            RCC->(Dbskip())

        Enddo

    EndIf

    IF !_lPassou

        U_ITMSG("Tabela (S001) de INSS (RCC) n�o cadastrada para o Mes / Ano: "+SubStr( dtos( Date() ) , 5 , 2 ) +" / "+ SubStr( dtos(Date()),1,4 ),;
            'Aten��o!',;
            "Favor entrar em contato com o RH para atualiza��o dos parametros da Folha.",1)

    ENDIF

Return()

/*
===============================================================================================================================
Programa----------: ValIRRF
Autor-------------: Tiago Correa Castro
Data da Criacao---: 25/01/2009
===============================================================================================================================
Descri��o---------: Funcao para validar tabela de calculo de IRFF para recolhimento do Autonomo.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function ValIRRF()

    Local _lPassou  := .F.
    Local _cMesAtual:= SubStr(dtos(Date()),1,4)+SubStr(dtos(Date()),5,2)
    Local _cDtIni   :=_cMesAtual
    Local _cDtfim   :=_cMesAtual

    _lAchou := .F.
    RCC->( DBSetOrder(1) )
    If RCC->( DBSeek( xFILIAL("RCC") + "S002" ))

        Do while RCC->RCC_FILIAL == xFILIAL("RCC") .and. RCC->RCC_CODIGO == "S002"

            _cDtIni:=SUBSTR(RCC->RCC_CONTEU,1,6)//Novo conteudo RCC->RCC_CONTEU = 201801201812     1903.98     2826.65  7.50    142.80000     3751.05 15.00    354.80000     4664.68 22.50    636.13000999999999.99 27.50    869.36000      189.5999       10.01
            _cDtfim:=SUBSTR(RCC->RCC_CONTEU,7,6)//Novo conteudo RCC->RCC_CONTEU = 201801201812     1903.98     2826.65  7.50    142.80000     3751.05 15.00    354.80000     4664.68 22.50    636.13000999999999.99 27.50    869.36000      189.5999       10.01

            If _cMesAtual >= _cDtIni .AND. _cMesAtual <= _cDtfim

                _X09_REND1 := Val( SubStr( RCC->RCC_CONTEU , 013 , 12  ) ) // ISENCAO
                _X09_REND2 := Val( SubStr( RCC->RCC_CONTEU , 025 , 12  ) ) // REND1
                _X09_REND3 := Val( SubStr( RCC->RCC_CONTEU , 056 , 12  ) ) // REND2
                _X09_REND4 := Val( SubStr( RCC->RCC_CONTEU , 087 , 12  ) ) // REND3
                _X09_REND5 := Val( SubStr( RCC->RCC_CONTEU , 118 , 12  ) ) // REND4
                _X09_ALIQ2 := Val( SubStr( RCC->RCC_CONTEU , 037 , 06  ) ) // ALIQ1
                _X09_ALIQ3 := Val( SubStr( RCC->RCC_CONTEU , 068 , 06  ) ) // ALIQ2
                _X09_ALIQ4 := Val( SubStr( RCC->RCC_CONTEU , 099 , 06  ) ) // ALIQ3
                _X09_ALIQ5 := Val( SubStr( RCC->RCC_CONTEU , 130 , 06  ) ) // ALIQ4
                _X09_PARC2 := Val( SubStr( RCC->RCC_CONTEU , 043 , 13  ) ) // DED1
                _X09_PARC3 := Val( SubStr( RCC->RCC_CONTEU , 074 , 13  ) ) // DED2
                _X09_PARC4 := Val( SubStr( RCC->RCC_CONTEU , 105 , 13  ) ) // DED3
                _X09_PARC5 := Val( SubStr( RCC->RCC_CONTEU , 136 , 13  ) ) // DED4
                _X09_DEDDEP := Val( SubStr( RCC->RCC_CONTEU ,149 , 12  ) ) // DEDDEP
                _X09_LIMDEP := Val( SubStr( RCC->RCC_CONTEU ,161 , 02  ) ) // LIMDEP
                _lpassou := .T.

            Endif


            RCC->(Dbskip())

        Enddo

    EndIf

    IF !_lPassou

        U_ITMSG("Tabela (S002) de Imposto de Renda (RCC) n�o cadastrada para o Mes / Ano: "+SubStr( dtos( Date() ) , 5 , 2 ) +" / "+ SubStr( dtos(Date()),1,4 ),;
            'Aten��o!',;
            "Favor entrar em contato com o RH para atualiza��o dos parametros da Folha.",1)

    ENDIF

Return()

/*
===============================================================================================================================
Programa----------: ITCODCLI
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descri��o---------: Retorna o pr�ximo c�digo sequencial para o cadastro de Clientes
===============================================================================================================================
Parametros--------: _pcTipo 	- Tipo de Pessoa (A1_PESSOA)
------------------: _pcCGC		- CPF/CNPJ do CLiente que est� sendo cadastrado (A1_CGC)
===============================================================================================================================
Retorno-----------: _cRetorno	- Retorna o novo c�digo do Cliente para a inclus�o (A1_COD)
===============================================================================================================================
*/ 

User Function ITCODCLI()

    Local _aArea    := GetArea()
    Local _cAlias	:= GetNextAlias()
    Local _cQuery   := ""
    local _cRetorno := ""
    Local _cCodigo  := ""
    Local _pcTipo	:= M->A1_PESSOA
    Local _pcCGC	:= M->A1_CGC

    //===============================================================================================
    // N�o gera o c�digo caso a rotina seja chamada pela fun��o SPEDMDFE
    //===============================================================================================
    IF FunName() == "SPEDMDFE"
        Return( _cCodigo )
    EndIF

    IF FWIsInCallStack('U_GP010ValPE') .AND. !Inclui
       RETURN M->A1_COD
    ENDIF

//===============================================================================================
// Monta a consulta do cadastro atual de Clientes
//===============================================================================================
    _cQuery := " SELECT MAX( SA1.A1_COD ) AS CODIGO"
    _cQuery += " FROM " + RetSqlName("SA1") +" SA1 "
    _cQuery += " WHERE "
    _cQuery += " 		SA1.D_E_L_E_T_	= ' ' "
    _cQuery += " AND	SA1.A1_FILIAL	= '"+ xFilial("SA1") +"' "

//===============================================================================================
// Verifica pelo CPF ou CNPJ de acordo com o tipo de cadastro
//===============================================================================================
    IF Alltrim(_pcTipo) == "J"
        _cQuery += " AND	SUBSTR( SA1.A1_CGC , 1 , 8 ) = '" + SubStr( _pcCGC , 1 , 8 ) + "' "
        _cQuery += " AND	SA1.A1_PESSOA = 'J' "
    Else
        _cQuery += " AND	SA1.A1_CGC  = '" + Alltrim( _pcCGC ) + "' "
    EndIF

    MPSysOpenQuery(_cQuery,_cAlias)

    (_cAlias)->( DBGotop() )
    IF (_cAlias)->( !Eof() )
        _cCodigo := (_cAlias)->CODIGO
    EndIF

    (_cAlias)->( DBCloseArea() )

//===============================================================================================
// Se o cliente n�o existir no cadastro gera um novo sequencial.
//===============================================================================================
    If Empty( _cCodigo )

        SA1->( DBSetOrder(1) )
        SA1->( DBGoBottom( ) )
        IF SA1->( !Eof() )

            _cCodigo := Soma1( SA1->A1_COD , TamSX3("A1_COD")[01] )

            //===========================================================================
            //| Se o c�digo estiver reservado na mem�ria pega o pr�ximo                 |
            //===========================================================================
            While !MayIUseCode( "A1_COD" + xFilial("SA1") + _cCodigo )
                _cCodigo := Soma1( _cCodigo , TamSX3("A1_COD")[01] )
            EndDo

        Else

            _cCodigo := StrZero( 1 , TamSX3("A1_COD")[01] )

        EndIF

    EndIf

    _cRetorno := _cCodigo

    RestArea( _aArea )

Return( _cRetorno )

/*
===============================================================================================================================
Programa----------: ITLOJCLI
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descri��o---------: Retorna o c�digo da Loja para o cadastro de Clientes
===============================================================================================================================
Parametros--------: _pcTipo 	- Tipo de Pessoa (A1_PESSOA)
------------------: _pcCGC		- CPF/CNPJ do CLiente que est� sendo cadastrado (A1_CGC)
===============================================================================================================================
Retorno-----------: _cRetorno	- Retorna o novo c�digo do Cliente para a inclus�o (A1_COD)
===============================================================================================================================
*/

User Function ITLOJCLI()

    Local _aArea		:= GetArea()
    Local _cCod			:= ""
    Local _cCNPJ		:= ""
    Local _cRetorno		:= ""

//====================================================================================================
// N�o gera o c�digo caso a rotina seja chamada pela fun��o SPEDMDFE
//====================================================================================================
    IF FunName() == "SPEDMDFE"
        Return( _cRetorno )
    EndIF

//====================================================================================================
// Se n�o for Inclus�o retorna o c�digo da loja atual
//====================================================================================================
    If !INCLUI
        Return( SA1->A1_LOJA )
    EndIF

    _cCNPJ := M->A1_CGC

    If Len( Alltrim( _cCNPJ ) ) > 11

        _cRetorno := SubStr( _cCNPJ , 9 , 4 )

        //====================================================================================================
        // VERIFICAR SE O CNPJ DO CLIENTE ESTA CADASTRADO EM ALGUMA LOJA
        //====================================================================================================
        _cCod := Posicione( "SA1" , 3 , xFilial("SA1") + _cCNPJ , "A1_COD" )

        IF !Empty(_cCod)

            _cRetorno := ITRETLOJA( _cCod , 1 )

        EndIF

    Else

        _cRetorno := ITRETLOJA( _cCNPJ , 2 )

    EndIf

//====================================================================================================
// Verifica se esta na memoria, sendo usado
//====================================================================================================
    If !MayIUseCode( "A1_LOJA"+ xFilial("SA1") + _cCod + _cRetorno )

        MSGSTOP( "C�digo: "+ _cCod + " / Loja: " + _cRetorno + " j� est� sendo utilizado. Contacte o administrador do sistema." )
        Return("")

    EndIf

//====================================================================================================
//Se � grupo de lojas preenche automatico o campo de grupo de lojas
//====================================================================================================
    If val(_cRetorno) > 1

        If POSICIONE('SA1',1,xFilial('SA1')+M->A1_COD,'A1_GRPVEN') != '999999'

            M->A1_GRPVEN := POSICIONE('SA1',1,xFilial('SA1')+M->A1_COD,'A1_GRPVEN')

        Endif

    Endif

    RestArea( _aArea )

Return( _cRetorno )

/*
===============================================================================================================================
Programa----------: ITRETLOJA
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descri��o---------: Retorna o c�digo da Loja para o cadastro de Clientes
===============================================================================================================================
Parametros--------: _cAux - Tipo de Pessoa (A1_PESSOA)
------------------: _nOpc - Define se busca por CPF ou CNPJ
===============================================================================================================================
Retorno-----------: _cRetorno	- Retorna o novo c�digo do Cliente para a inclus�o (A1_COD)
===============================================================================================================================
*/

Static Function ITRETLOJA( _cAux , _nOpc )

    Local cQuery	:= ""
    Local cRet		:= ""
    Local cAlias	:= GetNextAlias()

    cQuery := " SELECT "
    cQuery += "	MAX( SA1.A1_LOJA ) AS LOJA "
    cQuery += " FROM "+ RetSqlName("SA1") +" SA1 "
    cQuery += " WHERE "
    cQuery += " 	SA1.D_E_L_E_T_	= ' ' "
    If _nOpc == 1
        cQuery += " AND	SA1.A1_COD      = '" + Alltrim( _cAux ) +"' "
    Else
        cQuery += " AND	SA1.A1_CGC      = '" + Alltrim( _cAux ) +"' "
    EndIF

    MPSysOpenQuery(cQuery,cAlias)

    (cAlias)->( DBGotop() )
    IF (cAlias)->( !Eof() )
        cRet := Soma1( (cAlias)->LOJA )
    EndIF

    (cAlias)->( DBCloseArea() )

Return( cRet )


/*
===============================================================================================================================
Programa----------: ITVLPRTR
Autor-------------: Xavier
Data da Criacao---: 30/03/2015
===============================================================================================================================
Descri��o---------: Valida��o do pre�o unitario em referencia a tabela de pre�o de transferencias
===============================================================================================================================
Parametros--------: cOper = codigo da opera��o  
                     cProd = Codigo do produto 
                     nPrc = Preco unitario
                     _nopc =  1 � processamento normal,  2 � processamento que retorna o c�digo do produto com problema
                             3 � quando � chamado do validador
===============================================================================================================================
Retorno-----------: lRet - Retorna validando o pre�o em fun��o do % desvio
===============================================================================================================================
*/

User Function ITVLPRTR(_cOper As Character, _cProd As Character, _nPrc As Numeric,_nOpc As Numeric) As Logical

    Local _npreco := 0 As Numeric
    Local _aArea     := getarea() As Array
    Local _cfildest  := "" As Character
    Local _cfilmed   := "" As Character
    Local _ndiamed   := 15 As Numeric
    Local _nfatortra := 1.0476 As Numerics
    Local _dinicial  := stod('20010101') As DAte
    Local _dfinal    := stod('20010101') As Date
    Local _cmens     := "" As Character
    Local _cSvFilAnt := cFilAnt As Character //Salva a Filial Anterior 
    Local _nmargetra := 0 As Numeric
    Local _lRet      := .T. As Logical 
    Local _nVLMin    := 0 As Numeric
    Local _nVLMax    := 0 As Numeric
    Local _cAliasZ09 := "" As Character
    Local _cQry      := "" As Character

    Default _nopc    := 1


    //Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetiva��ao Automatica)
    If FWIsInCallStack("U_AOMS112") .or. FWIsInCallStack("U_MOMS050") .or. FWIsInCallStack("U_AOMS058X")
        Return .T.
    EndIf

    //Se for troca nota n�o valida pre�o de transfer�ncia
    If M->C5_I_TRCNF = "S"

        //opc 1 � processamento normal, opc 2 � processamento que retorna o c�digo do produto com problema
        //opc 3 � quando � chamado do validador

        if _nopc == 1 .or. _nopc == 3

            return .T.

        else

            return " "

        endif


    Endif

    _cfildest  := alltrim(posicione("SA1",1,xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"SA1->A1_I_FILOR")) //filial destino do cliente selecionado
    _nfatortra := 0 //fator a ser aplicado a m�dia de pre�o

    //Verifica se � valida��o de opera��o de movimenta��o de estoque 
    If _coper $ U_ITGETMV("IT_OPMEDIO", '20|22')

        _cAliasZ09 := GetNextAlias()

        _cQry := "SELECT Z09_PRECO, Z09_DESVIO, Z09.R_E_C_N_O_ AS RECNO"
        _cQry += "	FROM " + RetSqlName("Z09")+" Z09 "
        _cQry += "	WHERE Z09_CODOPE = '"+_cOper+"' "
        _cQry += "	  AND Z09_CODPRO = '"+_cProd+"' "
        _cQry += "	  AND Z09_INIVIG <= '"+DTOS(Date())+"' "  
        _cQry += "	  AND Z09_FIMVIG >= '"+DTOS(Date())+"' "
        _cQry += "	  AND ( Z09_FILORI = ' ' OR Z09_FILORI = '"+cfilant+"' ) "
        _cQry += "	  AND ( Z09_FILDES = ' ' OR  Z09_FILDES = '"+_cfildest+"' ) " 
        _cQry += "	  AND Z09.D_E_L_E_T_ = ' ' "
        _cQry += "	ORDER BY Z09_FILORI DESC, Z09_FILDES DESC "

        _cQry := ChangeQuery(_cQry)

        MPSysOpenQuery( _cQry,_cAliasZ09 )

        If (_cAliasZ09)->( !EOF() ) //Se achou prepara para valida��o

            _npreco := (_cAliasZ09)->Z09_PRECO
            _nmargetra := (_cAliasZ09)->Z09_DESVIO/100

        Else //Se n�o achou tabela de pre�o na regra retorna automaticamente que � pre�o v�lido

            //opc 1 � processamento normal, opc 2 � processamento que retorna o c�digo do produto com problema
            //opc 3 � quando � chamado do validador

            if _nopc == 1 .or. _nopc == 3

                return .T.

            else

                return " "

            endif
            
        Endif
        
        (_cAliasZ09)->( DBCloseArea() ) //Fecha a �rea da consulta
    
    Else

        _cfilmed   := U_ITGETMV("IT_FILMEDT","") //filiais que usam m�dia de pre�o
        _ndiamed   := U_ITGETMV("IT_DIASTRA",15)  //dias corridos para fazer a m�dia de pre�o

        //Se n�o � transfer�ncia e estoque em filial sem m�dia de pre�o segue valia��o normal de tabela de pre�o de transfer�ncia

        //verifica se � transferencia, se n�o for retorna .T. direto
        Z09->( dbsetorder(2) )

        If !((posicione("SB1",1,xfilial("SB1")+alltrim(_cProd),"B1_TIPO") == 'PA' ;
                .OR. posicione("SB1",1,xfilial("SB1")+alltrim(_cProd),"B1_GRUPO") == '0813') .AND. ;
                Z09->(DbSeek(XFilial("Z09")+_cOper)) )

            //opc 1 � processamento normal, opc 2 � processamento que retorna o c�digo do produto com problema
            //opc 3 � quando � chamado do validador

            if _nopc == 1 .or. _nopc == 3

                return .T.

            else

                return " "

            endif

        Endif

        //verifica se cliente tem campo filial origem v�lido
        SA1->( dbsetorder(1) )

        if SA1->( dbseek(xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) )

            if !(alltrim(SA1->A1_I_FILOR) >= '01' .and. alltrim(SA1->A1_I_FILOR) <= 'ZZ')


                //opc 1 � processamento normal, opc 2 � processamento que retorna o c�digo do produto com problema
                //opc 3 � quando � chamado do validador

                if _nopc == 3

                    u_itmsg("Cliente n�o � filial v�lida para receber transfer�ncia","Valida��o","Favor solicitar apoio ao Departamento Fiscal/Comercial.",1)

                endif

                if _nopc == 1 .or. _nopc == 3

                    Return .F.

                else

                    return " "

                Endif

            Endif

        Endif


        //muda para filial destino para pegar o par�metro
        cFilAnt := _cfildest

        _nfatortra := U_ITGETMV("IT_FATORTRA",1.0476) //fator a ser aplicado a m�dia de pre�o

        //volta a filial local
        cFilAnt := _cSvFilAnt

        //Se filial destino pertence ao IT_FILMEDTRA usa m�dia de pre�o
        if alltrim(_cfildest) $ _cfilmed

            //carrega margem disponivel para a opera��o
            Z09->( dbsetorder(1) )

            if Z09->( dbseek(xfilial("Z09")+_cOper) )

                _nmargetra := (Z09->Z09_DESVIO/100) //margem de varia��o permitida

            Else

                _nmargetra := 0

            Endif


            //calcula faixa de an�lise de m�dia de vendas
            //ultimo dia de venda desde que n�o seja o dia atual (que n�o est� completo) menos a quantidade de dias do IT_DIASTRA
            _adatas := U_AOMS002C(_cfildest,_cprod,_ndiamed)
            _dinicial := _adatas[1]
            _dfinal   := _adatas[2]

            //calcula m�dia de preco de vendas
            _npreco := U_AOMS002M(_dinicial,_dfinal,_cfildest,_cprod,_nfatortra)

            if _npreco == 0

                //se n�o achar vendas do produto na filial destino avisa e usa tabela de pre�os de transfer�ncia
                _cmens := "tabela"

            endif

        else

            //marca flag para executa c�lculo por tabela de pre�o de transfer�ncia
            _cmens     := "tabela"

        endif

        if len(_cmens) > 1 .and. _lret

            //carrega pre�o da tabela de precos de transferencia para a opera��o do pedido de vendas
            _lRet := .F.
            _atabelas := U_AOMS002P(_cprod,xfilial("SC5"),_cfildest,_cOper)
            _npreco := _atabelas[1]
            _nmargetra := _atabelas[2]

            If _npreco > 0

                _lRet := .T.

            Endif

            //se n�o achou pre�o na tabela avisa e trava o processo
            if .not. _lret

                //opc 1 � processamento normal, opc 2 � processamento que retorna o c�digo do produto com problema
                //opc 3 � quando � chamado do validador

                if _nopc == 1 .or. _nopc == 3

                    if _nopc == 3

                        //N�o tem tabela de pre�o de transfer�ncia para o produto
                        u_itmsg("Para o tipo de opera��o "+_coper+" o produto "+_cprod+" n�o est� cadastrado na Tabela de Pre�o de Transfer�ncia.",;
                            "Valida��o", "Favor solicitar apoio ao Departamento Fiscal.",1)

                    endif

                    return _lret

                else

                    return _cprod

                endif

            Endif

        Endif

    Endif


    if _npreco > 0  .AND. _nPrc > 0

        //se achou pre�o acima de zero faz a valida��o
        _lret := .T.

        //define pre�o m�ximo e m�nimo
        _nVLMin := _npreco - ( _npreco * _nmargetra)
        _nVLMax := _npreco + ( _npreco * _nmargetra)

        If _nPrc < _nVLMin .Or. _nPrc > _nVLMax


            if _nopc == 1 .or. _nopc == 3

                u_itmsg("Produto: " + _cProd + " fora da regra de pre�o de transferencias.",;
                    "Valida��o", "Mantenha o pre�o dentro de uma margem de " + alltrim(str(_nmargetra*100)) + "% do pre�o sugerido.",1)

            Endif

            _lRet := .F.

        EndIf

    EndIf

    restarea(_aArea)

    //opc 1 � processamento normal, opc 2 � processamento que retorna o c�digo do produto com problema
    if _nopc == 2 .and. .not. _lret

        return _cProd

    endif

Return ( _lRet )

/*
===============================================================================================================================
Programa----------: OMSMSGNF
Autor-------------: Alexandre Villar
Data da Criacao---: 22/05/2015
===============================================================================================================================
Descri��o---------: Configura mensagem auxiliar da NF
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet - (.T./.F.) de acordo com as valida��es
===============================================================================================================================
*/

User Function OMSMSGNF()

    Local _aArea	:= GetArea()
    Local _lRet     := .F.

    If !Empty(SF2->F2_CARGA) .And. SF2->F2_I_FRET > 0
        SA2->( DBSetOrder(1) )
        If SA2->( DBSeek( xFilial('SA2') + SF2->( F2_I_CTRA + F2_I_LTRA ) ) )
            // Tratativa para Transportadora ou Autonomo do RS
            If SA2->A2_I_CLASS $ 'T/A' .And. SM0->M0_ESTENT == 'RS'
                // Verifica se o estado do transportador � diferente da filial que estiver faturando
                _lRet := ( SA2->A2_EST <> SM0->M0_ESTENT .And. SF2->F2_EST <> SM0->M0_ESTENT )
                // Tratativa para Transportadora de GO
            ElseIf SA2->A2_I_CLASS == 'T' .And. SM0->M0_ESTENT == 'GO'
                // Sempre que ele for credenciado (IN 1298), n�o gera mensagem. Mensagem para: 1-transportador fora do estado
                //e cliente dentro do estado. 2-Cliente de fora do estado, independente do transportador
                _lRet := (SA2->A2_I_I1298 <> 'S' .And. SA2->A2_I_I1298 <> 'L') .And. ((SF2->F2_EST==SM0->M0_ESTENT .And. SA2->A2_EST <> SM0->M0_ESTENT) .Or. (SF2->F2_EST<>SM0->M0_ESTENT))
                // Tratativa para Transportadora demais estados
            ElseIf SA2->A2_I_CLASS == 'T' .And. !SM0->M0_ESTENT $ 'RS/GO'
                //Cliente e transportador Fora do estado
                If SM0->M0_ESTENT $ 'PR'
                    _lRet := ( SF2->F2_EST <> SM0->M0_ESTENT) .And. ( SA2->A2_EST <> SM0->M0_ESTENT)
                Else// Trasportador de fora do estado
                    _lRet := ( SA2->A2_EST <> SM0->M0_ESTENT)
                EndIf
                // Tratativa para Autonomo
            ElseIf SA2->A2_I_CLASS == 'A' .And. SM0->M0_ESTENT <> 'RS'
                _lRet := SF2->F2_EST <> SM0->M0_ESTENT
            EndIf
        EndIf
    EndIf

    RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ITVLDEST
Autor-------------: Alexandre Villar
Data da Criacao---: 19/06/2015
===============================================================================================================================
Descri��o---------: Verifica estoque dispon�vel considerando estoque em poder de terceiros
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: _ntipo - 1 estoque local, 2 estoque de terceiros
                    _cfilped - filial do pedido
                    _ccodped - c�digo do pedido
                    _clocal - local do estoque					
===============================================================================================================================
Retorno-----------: _lRet - (.T./.F.) se tem saldo para liberar o pedido
===============================================================================================================================
*/

User Function ITVLDEST( _nTipo , _cFilPed , _cCodPed , _cLocal  , _aProd )

    Local _lRet		:= .F.,I
    Local _lErro    := .F.
    Local _cQuery	:= ''
    Local _cAlias	:= GetNextAlias()
    Local _aItens	:= {}
    Local _aSaldo   := {}
    Local _nPos     := 0,_cPictQtde
    Local _cCodLib  := ALLTRIM( U_ITGetMV( 'IT_EST3LIB' , '  ' ) )
    Local _cValSald := ALLTRIM( U_ITGetMV( 'IT_VALSALD' , '1'  ) )

    Default _cLocal	:= ''
    Default _nTipo	:= 0
    Default _aProd	:= {}

    If _cFilPed + _cCodPed <> SC5->C5_FILIAL + SC5->C5_NUM
        SC5->( DBSetOrder(1) )
        SC5->( DBSeek( _cFilPed + _cCodPed ) )
    ENDIF
    SC6->( DBSetOrder(1) )
    If SC6->( DBSeek( _cFilPed + _cCodPed ) )

        DO While SC6->( !Eof() ) .And. SC6->( C6_FILIAL + C6_NUM ) == _cFilPed + _cCodPed

            _cTes := Upper( AllTrim( Posicione( "SF4" , 1 , xFilial("SF4") + SC6->C6_TES , "F4_ESTOQUE" ) ) )

            If _cTes == "S" .AND. !(SC5->C5_FILIAL = "40" .AND. SC5->C5_I_OPER $ "06/10/31/41" .AND. SC6->C6_LOCAL $ "50/52")

                SC9->( DBSetOrder(1) )
                If SC9->( DBSeek( SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM  ) )

//******************************************  _nTipo = 1  ***************************************************************************
                    If _nTipo = 1
                        _lRet:= .T.
                        IF (_nPos:=ASCAN(_aItens,{|I| I[1]+I[2] == SC9->C9_PRODUTO+SC9->C9_LOCAL })) = 0
                            AADD(_aItens,{SC9->C9_PRODUTO,SC9->C9_LOCAL,SC9->C9_QTDLIB, SC9->(RECNO()) ,SC9->C9_FILIAL , SC9->C9_BLEST })
                        ELSE
                            IF !(AllTrim( SC9->C9_BLEST ) == AllTrim( _cCodLib ))//Coloco o errado para validar l� em baixo
                                _aItens[_nPos,6]:=SC9->C9_BLEST
                            ENDIF
                            _aItens[_nPos,3]+=SC9->C9_QTDLIB
                        ENDIF
                        SC6->( DBSkip() )
                        LOOP
                    ENDIF
//******************************************  _nTipo = 1  ***************************************************************************

                    _cQuery := " SELECT "
                    _cQuery += "     SB2.B2_QATU AS SALDO , "
                    _cQuery += "     SB2.B2_QATU - SB2.B2_RESERVA AS SALDO_R , "
                    _cQuery += "     SB2.B2_QATU - SB2.B2_RESERVA + SB2.B2_QNPT AS SALDO_3 "
                    _cQuery += " FROM  "+ RetSqlName('SB2') +" SB2 "
                    _cQuery += " WHERE "
                    _cQuery += "     SB2.B2_FILIAL  = '"+ SC9->C9_FILIAL  +"' "
                    _cQuery += " AND SB2.B2_COD     = '"+ SC9->C9_PRODUTO +"' "
                    _cQuery += " AND SB2.B2_LOCAL   = '"+ SC9->C9_LOCAL   +"' "
                    _cQuery += " AND SB2.D_E_L_E_T_ = ' ' "

                    MPSysOpenQuery(_cQuery,_cAlias)

                    (_cAlias)->( DBGoTop() )
                    If (_cAlias)->( !Eof() )

                        //====================================================================================================
                        // Verifica o saldo em estoque, desconta a reserva e soma o estoque em poder de terceiros
                        //====================================================================================================
                        If SC9->C9_LOCAL $ _cLocal

                            _lRet := ( (_cAlias)->SALDO_3 >= SC9->C9_QTDLIB )

                            //====================================================================================================
                            // Verifica o saldo em estoque e desconta a reserva
                            //====================================================================================================
                        Else
                            _lRet := ( (_cAlias)->SALDO_R >= SC9->C9_QTDLIB )
                        EndIf

                    Else

                        _lRet := .F.

                    EndIf

                    //Valida com calcest
                    If _lRet

                        aSaldos := CalcEst( SC9->C9_PRODUTO , SC9->C9_LOCAL , date() + 1 ) //obt�m o saldo final em estoque na data informada
                        _nQatu  := aSaldos[01]//SB2->B2_QATU

                        If _nQatu < SC9->C9_QTDLIB

                            u_itmsg("O produto " + SC9->C9_PRODUTO + " no armaz�m " + SC9->C9_LOCAL + " possui diverg�ncia de saldo na SB2",;
                                "Aten��o","Entre em contato com o departamento de Custos",1)

                            _lRet := .F.

                        Endif

                    Endif

                    (_cAlias)->( DBCloseArea() )

                EndIf

            Else

                _lRet := .T.

            EndIf

            If !_lRet
                Exit
            EndIf

            SC6->( DBSkip() )

        EndDo

    EndIf

    IF _nTipo = 1 .AND. _lRet
        _cPictQtde:=PesqPict("SC9","C9_QTDLIB")
        SB2->(DBSETORDER(1))
        FOR I := 1 TO LEN(_aItens)
            _lAADD:=.T.
            IF AllTrim( _aItens[I,6] ) == AllTrim( _cCodLib )
                IF _cValSald = "2"
                    SB2->( DBSEEK(_aItens[I,5]+_aItens[I,1]+_aItens[I,2]) )
                    _nSaldo:=SB2->B2_QATU//_aSaldo[1]//SaldoSB2()// (SB2->B2_QATU - SB2->B2_RESERVA)
                ELsE//IF _cValSald = "1" qq cosia diferente de 2
                    _aSaldo:=CalcEst( _aItens[I,1] , _aItens[I,2] , dDataBase+1 )
                    _nSaldo:=_aSaldo[1]
                ENDIF
                _lErro:= _aItens[I,3] > _nSaldo
                IF _lErro
                    _lRet :=.F.
                ENDIF
            ELSE
                _lRet := .F.
            ENDIF
            If _lErro
                SC9->(DBGOTO(_aItens[I,4]))
                AADD( _aProd , { SC9->C9_CARGA, SC9->C9_PEDIDO , SC9->C9_ITEM , SC9->C9_PRODUTO , SC9->C9_LOCAL , TRANS(_aItens[I,3],_cPictQtde) , TRANS(_nSaldo,_cPictQtde) ,;
                    "Problema no Estoque: N�o existe saldo em estoque para faturar, Verifique os Pedidos Liberados. (C9_BLEST = '"+SC9->C9_BLEST+"')" } )
            EndIf
        NEXT I
    ENDIF

Return( _lRet )

/*
===============================================================================================================================
Programa--------: ITCFOPS
Autor-----------: Jeovane
Data da Criacao-: 29/06/2014
===============================================================================================================================
Descri��o-------: Funcao usada para buscar CFOPs de acordo com o tipo de operacao
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: _cTpOper - Tipo de Opera��o
===============================================================================================================================
Retorno---------: _cRet    - CFOPS selecionados
===============================================================================================================================
*/

User Function ITCFOPS( _cTpOper )

    Local _cRet		:= ""
    Local _aArea	:= GetArea()

    ZAY->( DBSetOrder(3) ) // ZAY_FILIAL + ZAY_TPOPER + ZAY_CF
    ZAY->( DBSeek( xFilial("ZAY" ) ) )
    While ZAY->( !Eof() ) .And. ZAY->ZAY_FILIAL == xFilial("ZAY")

        If ZAY->ZAY_TPOPER $ _cTpOper
            _cRet += AllTrim( ZAY->ZAY_CF ) + ";"
        EndIf

        ZAY->( DBSkip() )
    EndDo

    RestArea( _aArea )

Return( _cRet )

/*
===============================================================================================================================
Programa--------: ITCFOPS
Autor-----------: Jeovane
Data da Criacao-: 29/06/2014
===============================================================================================================================
Descri��o-------: Funcao usada para selecionar CFOPs de acordo com o tipo de operacao
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: _cTpOper - Tipo de Opera��o
===============================================================================================================================
Retorno---------: _cRet    - CFOPS selecionados
===============================================================================================================================
*/

User Function LstTpCF()

    Local i			:= 0
    Local cCombo	:= " "

    Private nTam		:= 0
    Private nMaxSelect	:= 0
    Private aCat		:= {}
    Private MvRet		:= Alltrim( ReadVar() )
    Private MvPar		:= ""
    Private cTitulo		:= ""
    Private MvParDef	:= ""
    Private cConte		:= {}
    Private nCont		:= 0

    #IFDEF WINDOWS
        oWnd := GetWndDefault()
    #ENDIF

    SX3->( DBSetOrder(2) )
    If SX3->( DBSeek( "ZAY_TPOPER" ) )
        cCombo := X3Cbox()
    EndIf

//"V=VENDA;T=TRANSFERENCIA;B=BONIFICACAO;R=REMESSA;O=OUTROS"

//A funcao STRTOKARR() tem o objetivo de retornar um array, de acordo com os dados passados como parametro para a funcao
    aOpcoes := STRTOKARR( cCombo , ';' )

//Tratamento para carregar variaveis da lista de opcoes
    nTam		:= 1
    nMaxSelect	:= 5
    cTitulo		:= "CFOP X Tipo de Operacao"

    For i := 1 To Len( aOpcoes )

        MvParDef += SubStr( aOpcoes[i] , 1 , 1 )

        aAdd( aCat , SubStr( aOpcoes[i] , 3 , Len( aOpcoes[i] ) - 2 ) )

    Next i

//Adiciona Opcao Todos
    MvParDef += "A"
    aAdd( aCat , "TODOS" )

    MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
    &MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )

//Executa funcao que monta tela de opcoes
    F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

//Tratamento para separar retorno com barra ";"
    &MvRet := ""

    For i := 1 To Len( MvPar ) Step 1

        If !( SubStr( MvPar , i , 1 ) $ " |*" )
            &MvRet += SubStr( MvPar , i , 1 ) +";"
        EndIf

    Next i

//Trata para tirar o ultimo caracter
    &MvRet := SubStr( &MvRet , 1 , Len(&MvRet) - 1 )

// o usuario selecionar a op��o de todos ele retornar todas as cfops cadastradas. 
    cConte := StrTokArr( &MvRet , ";" )

    For i := 1 To Len( cConte )

        If cConte[i] == 'A'
            nCont++
        EndIf

    Next i

    If nCont > 0
        &MvRet := "V;T;B;R;O"
    EndIf

Return( .T. )

/*
===============================================================================================================================
Programa----------: vldPedBon
Autor-------------: Fabiano Dias
Data da Criacao---: 01/08/2011
===============================================================================================================================
Descri��o---------: Funcao utilizada para verificar atraves da CFOP se o pedido de venda corrente � do tipo bonificacao, pois
------------------: este dever� entrar no sistema com o status bloqueado caso tenha valor acima de R$ 500,00
===============================================================================================================================
Parametros--------: aCols - Dados dos �tens do pedido de venda
===============================================================================================================================
Retorno-----------: L�gico - Define se o registro dever� ser bloqueado
===============================================================================================================================
*/

User Function vldPedBon( aCols )

    Local _lRet		:= .F.
    Local _x		:= 1

    Local _cCFOP	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_CF"	} )
    Local _nValor	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_VALOR"	} )

    Local _nSomator	:= 0

    For _x := 1 To Len(aCols)

        //================================================================================
        // Se a linha nao estiver deletada
        //================================================================================
        If !aCols[_x][Len(aCols[_x])]

            //=================================================================
            //|Efetua o somatorio dos itens para constatar se o pedido possui |
            //|um  valor acima de 500 reais, pois somente sera bloqueado os   |
            //|pedidos com valor acima de 500 reais.                          |
            //=================================================================
            _nSomator += aCols[_x][_nValor]

            //==========================================================
            //|Caso encontre uma das duas CFOP citadas abaixo o pedido |
            //|de venda corrente sera considerado do tipo bonificacao. |
            //================================================================================
            If AllTrim(aCols[_x][_cCFOP]) $ '5910/6910/5911/6911'
                _lRet  := .T.
            EndIf

        EndIf

    Next _x

    If !( _lRet .And. ( _nSomator > GetMV( "IT_VLRBON" ,, 500 ) ) )
        _lRet := .F.
    EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: vldContrato
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao utilizada nos seguintes pontos de entrada: MSD2460/SF2460I para verificar se os dados do pedido na     
                    hora de seu faturamento podem ser armazenados na SD2,SF2 e SE1, isto porque eu posso inserir um pedido que    
                    tenha produtos oom desconto e fatura-lo em outro dia, so que no momento em que ele for faturado ele pode estar  
                    com a data de vigencia vencida, ou bloqueado, ou devido a alguma alteracao do depto comercial ele voltou a nao
                    estar mais aprovado, necessitando de uma nova aprovacao.	
===============================================================================================================================
Parametros--------:	cNumContr - c�digo a ser localizado no ZAZ_COD
===============================================================================================================================
Retorno-----------: .T. se armazenara as informacoes do pedido com relacao a desconto na SD2,SF2 e SE1, ou .F. se nao podera	 
===============================================================================================================================
*/ 

User Function vldContrato(cNumContr)

    Local aArea := GetArea()
    Local lRet  := .F.
    Local cQuery:= ""

    //1 - Armazena se o tipo do contrato esta com a data de vigencia em vigor, se esta aprovado ou se esta bloqueado, caso 
    //alguma das condicoes seja contraditoria ele retornara falso
    //2 - Armazena o tipo do contrato 
    Local aRetor:={.F.,""}

    If (!Empty(cNumContr)) .And. (Len(AllTrim(cNumContr)) > 5)

        cQuery := "SELECT ZAZ_MSBLQL,ZAZ_DTFIM,ZAZ_STATUS,ZAZ_ABATIM"
        cQuery += " FROM " + RetSqlName("ZAZ")
        cQuery += " WHERE D_E_L_E_T_ = ' '  AND ZAZ_FILIAL = '" + xFILIAL("ZAZ") + "'"
        cQuery += " AND ZAZ_COD = '" + cNumContr + "' "

        MPSysOpenQuery(cQuery,"TMP17")

        TMP17->(dbGoTop())

        If TMP17->ZAZ_MSBLQL == '1'//Verifica se o contrato esta bloqueado
            lRet  := .F.
        elseif TMP17->ZAZ_STATUS == 'N'//Verifica se o contrato ainda nao foi aprovado pelo financeiro
            lRet  := .F.
        ElseIf TMP17->ZAZ_DTFIM < DtoS(date()) //Se o contrato estiver com a data de vigencia vencida de acordo com a data do servidor onde esta inslado o protheus
            lRet  := .F.
        Else
            lRet  := .T.//Permite o faturamento
        EndIf

        aRetor[1]:= lRet
        aRetor[2]:= TMP17->ZAZ_ABATIM

        TMP17->(dbCloseArea())

        RestArea(aArea)

    EndIf

Return aRetor

/*
===============================================================================================================================
Programa----------: veriContrato
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao para verificar se existe contrato de desconto contratual para o cliente ou sua rede.	
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: 	cCodclient - c�digo do cliente
                        cLojacli - loja do cliente
                        cCodProdut - c�digo do produto
===============================================================================================================================
Retorno-----------: Array - aRetorno com as seguintes posicoes e valores           												
                               1 - Armazena o valor do desconto																			
                            2 - Se o contrato esta aprovado																				
                            3 - Se contrato esta com a data de vigencia valida															
                            4 - Numero do contrato	
===============================================================================================================================
*/            

User Function veriContrato(cCodclient,cLojacli,cCodProdut)

    Local cQuery    := ""
    Local nVlrDesc  := 0  //Armazena o valor de desconto integral
    Local nVlrDesPa := 0  //Armazena o valor de desconto parcial
    Local cAbatiment:= "" //Tipo do Abatimento
    //Array que armazenara os seguintes valores nas seguinte posicoes
    //1 - se possui contrato
    //2 - numero do contrato
    //3 - o estado do cliente(MG,SP,RO)
    //4 - se o contrato esta aprovada
    //5 - se o contrato esta com a data de vigencia valida       
    //6 - Numero do contrato
    Local aDados    := {.F.,"","",.T.,.T.}
    //1 - Armazena o valor do desconto integral
    //2 - Se o contrato esta aprovado
    //3 - Se contrato esta com a data de vigencia valida
    //4 - Numero do contrato                   
    //5 - Armazena o valor do desconto parcial 
    //6 - Tipo do abatimento
    Local aRetorno  := {0,.T.,.T.,"",0,""}
    Local aGetArea  := GetArea()
    Local aAreaTMP10:= {}
    Local lcontrato := .F.//Armazena se encontrou contrato na primeira checagem que eh por cliente + loja, caso nao encontre procura somente por cliente
    Local nreg      := 0

    cQuery := "SELECT ZAZ_COD,ZAZ_LOJA,ZAZ_STATUS,ZAZ_DTFIM"
    cQuery += " FROM " + RetSqlName("ZAZ")
    cQuery += " WHERE D_E_L_E_T_  = ' '  AND ZAZ_FILIAL = '" + xFILIAL("ZAZ") + "'"
    cQuery += " AND ZAZ_CLIENT = '" + cCodclient + "'"
    cQuery += " AND ZAZ_MSBLQL = '2'"

    MPSysOpenQuery(cQuery,"TMP10")
    dbSelectArea("TMP10")//N�O TIRAR
    Count to nreg
    //Contabiliza o numero de registros encontrados pela query

    TMP10->(dbGoTop())

    //Se encontrar um contrato nao bloqueado para um cliente sem considerar a loja, caso ela tenha sido especificada no contrato

    If nreg > 0

        While TMP10->(!Eof())

            If !Empty(TMP10->ZAZ_LOJA)
                //Verifica se a loja informada no contrato e a mesma loja informada no pedido
                If TMP10->ZAZ_LOJA == cLojacli

                    //Possui contrato especifico para este cliente e loja
                    lcontrato:=.T.

                    aAreaTMP10:= TMP10->(GetArea())
                    aDescontos:= u_VerItensC(TMP10->ZAZ_COD,cCodProdut,'C',cCodclient,cLojacli,'')
                    nVlrDesc  := aDescontos[1] //Desconto Integral
                    nVlrDesPa := aDescontos[2] //Desconto Parcial
                    cAbatiment:= aDescontos[3] //Tipo do Abatimento
                    restArea(aAreaTMP10)

                    //Possui contrato para o produto especificado
                    If nVlrDesc > 0

                        //verifica se o contrato encontra-se vigente
                        If TMP10->ZAZ_DTFIM >= DtoS(date())
                            //Se o contrato estiver ativo
                            IF TMP10->ZAZ_STATUS == 'S'

                                aRetorno[4]:=TMP10->ZAZ_COD//Numero do contrato
                                lcontrato:=.T.
                                exit
                            else
                                //Contrato nao aprovado
                                aRetorno[2]:=.F.
                                aRetorno[4]:=TMP10->ZAZ_COD
                                lcontrato:=.T.
                                exit
                            EndIf
                        Else
                            //Data do contrato vigente nao esta ativa
                            aRetorno[3]:=.F.
                            aRetorno[4]:=TMP10->ZAZ_COD
                            lcontrato:=.T.
                            exit
                        EndIf

                    EndIf
                EndIf
            EndIf

            TMP10->(dbSkip())
        EndDo

        //Quando nao encontrar um contrato que tenha cliente + loja, ele vai buscar um mais generico somente por cliente
        If !lcontrato

            TMP10->(dbGoTop())

            While TMP10->(!Eof())

                If Empty(TMP10->ZAZ_LOJA)

                    aAreaTMP10:= TMP10->(GetArea())
                    aDescontos:= u_VerItensC(TMP10->ZAZ_COD,cCodProdut,'C',cCodclient,cLojacli,'')
                    nVlrDesc  := aDescontos[1] //Desconto Integral
                    nVlrDesPa := aDescontos[2] //Desconto Parcial
                    cAbatiment:= aDescontos[3] //Tipo do Abatimento
                    restArea(aAreaTMP10)

                    //possui contrato para o cliente sem loja especificada no contrato
                    lcontrato:=.T.

                    //Possui contrato para o produto especificado
                    If nVlrDesc > 0
                        //verifica se o contrato encontra-se vigente
                        If TMP10->ZAZ_DTFIM >= DtoS(date())
                            //Se o contrato estiver ativo
                            IF TMP10->ZAZ_STATUS == 'S'

                                aRetorno[4]:=TMP10->ZAZ_COD
                                lcontrato:=.T.
                                exit
                            else
                                //Contrato nao aprovado
                                aRetorno[2]:=.F.
                                aRetorno[4]:=TMP10->ZAZ_COD
                                lcontrato:=.T.
                                exit
                            EndIf
                        Else
                            //Data do contrato vigente nao esta ativa
                            aRetorno[3]:=.F.
                            aRetorno[4]:=TMP10->ZAZ_COD
                            lcontrato:=.T.
                            exit
                        EndIf

                    EndIf
                EndIf

                TMP10->(dbSkip())
            EndDo
        EndIf
    EndIf

    If  !lcontrato
        //Se o cliente informado no pedido de vendas nao possuir um contrato(ou que este esteja bloqueado)procura pela rede
        aDados:= u_VerContRede(cCodclient,cLojacli)
        aRetorno[4]:= aDados[2]//Armazena numero do contrato

        If aDados[1]

            aDescontos:= u_VerItensC(aDados[2],cCodProdut,'R',cCodclient,cLojacli,aDados[3])
            nVlrDesc  := aDescontos[1] //Desconto Integral
            nVlrDesPa := aDescontos[2] //Desconto Parcial
            cAbatiment:= aDescontos[3] //Tipo do Abatimento
            //Se encontrou um contrato para o produto especificado
            If nVlrDesc > 0

                aRetorno[2]:= aDados[4]//Se o contrato esta aprovado
                aRetorno[3]:= aDados[5]//Se o contrato esta com a data de vigencia em vigor

                If !aRetorno[2]
                    nVlrDesc := 0
                    nVlrDesPa:= 0
                EndIf

                If !aRetorno[3]
                    nVlrDesc := 0
                    nVlrDesPa:= 0
                EndIf

            EndIf

        EndIf

    EndIf

    //===================================
    // Deleta os arquivos temporarios. 
    //===================================
    TMP10->(dbCloseArea())

    aRetorno[1]:= nVlrDesc   //Armazena o valor do desconto integral
    aRetorno[5]:= nVlrDesPa  //Armazena o valor de desconto parcial
    aRetorno[6]:= cAbatiment //Tipo do Abatimento

    RestArea(aGetArea)

Return aRetorno

/*
===============================================================================================================================
Programa----------: VerContRede
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Funcao utilizada para verificar se existe contrato de desconto para a rede do cliente especificado no pedido
                       de vendas, esta funcao eh utilizada depois de constatar que nao existe contrato para o cliente.    
===============================================================================================================================
Parametros--------: 	cCodclient - c�digo do cliente
                        cLojacli - loja do cliente
===============================================================================================================================
Retorno-----------: Array - aDados com as seguintes posicoes e valores           												
                        1 - se possui contrato																						
                        2 - numero do contrato																						
                        3 - o estado do cliente(MG,SP,RO)																			
                        4 - se o contrato esta aprovada																				
                        5 - se o contrato esta com a data de vigencia valida    
===============================================================================================================================
*/      

User Function VerContRede(cCodclient,cLojacli)

    Local cQuery    := ""
    Local cRede	    := ""
    Local aDados    :={.F.,"","",.T.,.T.}
    Local cEst		:=""
    Local aGetArea :=GetArea()

    cQuery := "SELECT A1_GRPVEN,A1_EST"
    cQuery += " FROM " + RetSqlName("SA1")
    cQuery += " WHERE D_E_L_E_T_  = ' '  AND A1_FILIAL = '" + xFILIAL("SA1") + "'"
    cQuery += " AND A1_COD = '" + cCodclient + "'"
    cQuery += " AND A1_LOJA = '" + cLojacli + "'"
    cQuery += " AND A1_GRPVEN IS NOT NULL"

    MPSysOpenQuery(cQuery,"TMP11")
    TMP11->(dbGoTop())

    //Caso o cliente tenha um grupo de vendas(Rede) especificado no seu cadastro
    If !Empty(TMP11->A1_GRPVEN)

        //Armazena grupo de vendas e estado para liberar TMP11
        cRede:=TMP11->A1_GRPVEN
        cEst :=TMP11->A1_EST
        //===================================
        // Deleta os arquivos temporarios.
        //===================================

        //Pesquisa na tabela de desconto contratual se existe contrato para a rede do cliente especificado no pedido de vendas
        cQuery := "SELECT ZAZ_COD,ZAZ_DTFIM,ZAZ_STATUS"
        cQuery += " FROM " + RetSqlName("ZAZ")
        cQuery += " WHERE D_E_L_E_T_  = ' '  AND ZAZ_FILIAL = '" + xFILIAL("ZAZ") + "'"
        cQuery += " AND ZAZ_GRPVEN = '" + cRede + "'"
        cQuery += " AND ZAZ_MSBLQL = '2'"//Caso ele nao esteja bloqueado

        MPSysOpenQuery(cQuery,"TMP12")
        TMP12->(dbGoTop())

        //Se encontrar um contrato para um cliente sem considerar a loja, caso ela tenha sido especificada no contrato
        If !Empty(TMP12->ZAZ_COD)
            //Se o contrato estiver com a data de vigencia em vigor
            If TMP12->ZAZ_DTFIM >= DtoS(date())
                //Se o contrato estiver ativo
                IF TMP12->ZAZ_STATUS == 'S'

                    aDados[1]:=.T.
                    aDados[2]:=TMP12->ZAZ_COD
                    aDados[3]:=cEst

                Else

                    aDados[1]:=.T.
                    aDados[4]:=.F. //Contrato nao aprovado
                    aDados[2]:=TMP12->ZAZ_COD
                EndIf

            else

                aDados[1]:=.T.
                aDados[5]:=.F. //Contrato nao esta com a data vigente valida
                aDados[2]:=TMP12->ZAZ_COD
            EndIf

        EndIf

        TMP12->(dbCloseArea())

    EndIf

       TMP11->(dbCloseArea())

    RestArea(aGetArea)

Return aDados

/*
===============================================================================================================================
Programa----------: verItensC
Autor-------------: Renato de Morcerf
Data da Criacao---: 02/09/2008
===============================================================================================================================
Descri��o---------: Procura o valor do desconto para determinado produto especificado no pedido de venda, de acordo com os dados
                       fornecidos no contrato de desconto contratual.    
===============================================================================================================================
Parametros--------: 	codContrato - codigo do contrato
                        cCodProduto - c�digo do produto
                        ctipoPesqu - tipo de pesquisa
                        cCodclient - c�digo do cliente
                        cLojacli - loja do cliente
                        cEst - estado do cliente
===============================================================================================================================
Retorno-----------: % de desconto de acordo com o valor informado no contrato de desconto contratual    
===============================================================================================================================
*/ 

User Function verItensC(codContrato,cCodProduto,ctipoPesqu,cCodclient,cLojacli,cEst)

    Local cQuery    := ""
    Local nVlrDesc  := 0  //Desconto Integral
    Local nVlrDesPa := 0  //Desconto Parcial
    Local cAbatiment:= "" //Armazena o tipo do Abatimento
    Local lControle :=.F.
    Local aGetArea  := GetArea()
    //1 - Armazena o desconto integral
    //2 - Armazena o desconto parcial
    //3 - Tipo do Abatimento
    Local aDescontos:= {0,0,""}

    //Caso tenha sido informado o cliente no cabecalho do cadastro do desconto contratual
    //nao sera necessario efetuar algumas consideracoes para encontrar o valor do desconto fornecido para 
    //os produtos informados nos itens do contrato
    If ctipoPesqu == 'C'

        cQuery := "SELECT ZB0_DESCTO,ZB0_DESCPA,ZB0_ABATIM"
        cQuery += " FROM " + RetSqlName("ZB0")
        cQuery += " WHERE D_E_L_E_T_  = ' '  AND ZB0_FILIAL = '" + xFILIAL("ZB0") + "'"
        cQuery += " AND ZB0_COD = '" + codContrato + "'"
        cQuery += " AND ZB0_SB1COD = '" + cCodProduto + "'"

        MPSysOpenQuery(cQuery,"TMP13")
        TMP13->(dbGoTop())

        //Caso o cliente tenha um grupo de vendas(Rede) especifico no seu cadastro
        If !Empty(TMP13->ZB0_DESCTO)

            nVlrDesc  := TMP13->ZB0_DESCTO
            nVlrDesPa := TMP13->ZB0_DESCPA
            cAbatiment:= TMP13->ZB0_ABATIM

        EndIf

        TMP13->(dbCloseArea())

        //Quando informado a rede no cabecalho do cadastro do desconto contratual, deve-se checar se
        //foi informado o campo cliente nos itens do contrato, caso tenha sido informado verificar a loja e o estado
        //ou informado o campo estado sozinho para uma determinada rede para depois disso pegar o valor do desconto de acordo com o produto
    Else

        cQuery := "SELECT ZB0_CLIENT,ZB0_LOJA,ZB0_EST,ZB0_DESCTO,ZB0_DESCPA,ZB0_ABATIM,ZB0_COD"
        cQuery += " FROM " + RetSqlName("ZB0")
        cQuery += " WHERE D_E_L_E_T_  = ' ' AND ZB0_FILIAL = '" + xFILIAL("ZB0") + "'"
        cQuery += " AND ZB0_COD = '" + codContrato + "'"
        cQuery += " AND ZB0_SB1COD = '" + cCodProduto + "'"

        MPSysOpenQuery(cQuery,"TMP14")
        TMP14->(dbGoTop())

        //Caso o cliente tenha no contrato um desconto para o produto especificado
        If !Empty(TMP14->ZB0_COD)

            //Procura um cliente + loja + estado
            While TMP14->(!Eof())

                If (TMP14->ZB0_CLIENT == cCodclient) .And. (TMP14->ZB0_LOJA == cLojacli) .And. (TMP14->ZB0_EST == cEst)
                    nVlrDesc  := TMP14->ZB0_DESCTO
                    nVlrDesPa := TMP14->ZB0_DESCPA
                    cAbatiment:= TMP14->ZB0_ABATIM
                    lControle:=.T.
                    exit
                EndIf
                TMP14->(dbSkip())
            EndDo

            TMP14->(dbGoTop())

            if !lControle
                //Procura um cliente + loja
                While TMP14->(!Eof())

                    If (TMP14->ZB0_CLIENT == cCodclient) .And. (TMP14->ZB0_LOJA == cLojacli) .And. Empty(TMP14->ZB0_EST)
                        nVlrDesc  := TMP14->ZB0_DESCTO
                        nVlrDesPa := TMP14->ZB0_DESCPA
                        cAbatiment:= TMP14->ZB0_ABATIM
                        lControle:=.T.
                        exit
                    EndIf

                    TMP14->(dbSkip())
                EndDo
            EndIf

            TMP14->(dbGoTop())

            if !lControle
                //Procura um cliente
                While TMP14->(!Eof())

                    If (TMP14->ZB0_CLIENT == cCodclient) .And. Empty(TMP14->ZB0_LOJA) .And. Empty(TMP14->ZB0_EST)
                        nVlrDesc  := TMP14->ZB0_DESCTO
                        nVlrDesPa := TMP14->ZB0_DESCPA
                        cAbatiment:= TMP14->ZB0_ABATIM
                        lControle:=.T.
                        exit
                    EndIf
                    TMP14->(dbSkip())
                EndDo
            EndIf

            //Procura somente por estado
            TMP14->(dbGoTop())

            if !lControle
                //Procura um estado
                While TMP14->(!Eof())

                    If (TMP14->ZB0_EST == cEst) .And. Empty(TMP14->ZB0_CLIENT) .And. Empty(TMP14->ZB0_LOJA)
                        nVlrDesc  := TMP14->ZB0_DESCTO
                        nVlrDesPa := TMP14->ZB0_DESCPA
                        cAbatiment:= TMP14->ZB0_ABATIM
                        lControle:=.T.
                        exit
                    EndIf

                    TMP14->(dbSkip())
                EndDo
            EndIf

            TMP14->(dbGoTop())

            //So existe um registro caso nao se encontre dados nos filtros, pois a SQL ja filtro por produto
            If !lControle
                While TMP14->(!Eof())
                    If Empty(TMP14->ZB0_EST) .And. Empty(TMP14->ZB0_CLIENT) .And. Empty(TMP14->ZB0_LOJA)
                        nVlrDesc  := TMP14->ZB0_DESCTO
                        nVlrDesPa := TMP14->ZB0_DESCPA
                        cAbatiment:= TMP14->ZB0_ABATIM
                        lControle:=.T.
                        exit
                    EndIf
                    TMP14->(dbSkip())
                EndDo
            EndIf
        EndIf

        TMP14->(dbCloseArea())

    EndIf

    aDescontos[1]:= nVlrDesc   //Desconto integral
    aDescontos[2]:= nVlrDesPa  //Desconto parcial
    aDescontos[3]:= cAbatiment //Tipo do abatimento

    RestArea(aGetArea)

Return aDescontos

/*
===============================================================================================================================
Programa--------: Veriprog
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 12/05/2016
===============================================================================================================================
Descri��o-------: Verifica e ajusta programa��es de entrega na exclus�o do pedido
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: lret - continua com exclus�o do pedido ou n�o
===============================================================================================================================
*/

User Function Veriprog( )

    Local lret := .T.
    Local _cfilial2 	:= ""
    Local _ccodigo2 	:= ""
    Local _cstatus2 	:= ""
    Local _cfilial 	:= ""
    Local _ccodigo 	:= ""
    Local _cstatus 	:= ""
    Local _cusrlo  	:= ""
    Local _cusrco  	:= ""
    Local _nzf7		:= 0
    Local _nzf8		:= 0
    Local _nzf9		:= 0
    Local _cemail		:= ""
    Local _nprogs 	:= 0
    Local _aAreaSC5  	:= SC5->( Getarea() )
    Local _aAreaZF7  	:= ZF7->( Getarea() )
    Local _aAreaZF8  	:= ZF8->( Getarea() )
    Local _aAreaZF9  	:= ZF9->( Getarea() )
    Local _cAlias		:= ""


    Private _cfil1 		:= ""
    Private _cped1 		:= ""
    Private _cfil2 		:= ""
    Private _cped2 		:= ""

    _cQuery := " SELECT "
    _cQuery +=     " ZF8.ZF8_FILIAL AS FILIAL,"
    _cQuery +=     " ZF8.ZF8_CODPRG AS CODPRG,"
    _cQuery +=     " ZF8.ZF8_ITEM   AS ITEM,"
    _cQuery +=     " ZF7.ZF7_STATUS AS STSZF7, "
    _cQuery +=     " ZF7.ZF7_USRLOG AS USRLOG,"
    _cQuery +=     " ZF7.R_E_C_N_O_ AS ZF7RECNO,"
    _cQuery +=     " ZF8.R_E_C_N_O_ AS ZF8RECNO,"
    _cQuery +=     " ZF7.ZF7_USRPRG AS USRPRG"
    _cQuery += " FROM "+ RetSqlName('ZF8') +" ZF8, "+ RetSqlName('ZF7') +" ZF7 "
    _cQuery += " WHERE "
    _cQuery +=     " ZF8.D_E_L_E_T_ = ' ' "
    _cQuery += " AND ZF7.D_E_L_E_T_ = ' ' "
    _cQuery += " AND ZF8.ZF8_FILIAL = ZF7.ZF7_FILIAL "
    _cQuery += " AND ZF8.ZF8_CODPRG = ZF7.ZF7_CODIGO "
    _cQuery += " AND ZF7.ZF7_STATUS <> '6' "
    _cQuery += " AND ZF8.ZF8_FILPED = '"+ SC5->C5_FILIAL +"' "
    _cQuery += " AND ZF8.ZF8_NUMPED = '"+ SC5->C5_NUM    +"' "

    _cAlias := GetNextAlias()

    MPSysOpenQuery(_cQuery,_cAlias)
    (_cAlias)->( DBGoTop() )


    //Se achou como pedido prim�rio de uma programa��o de entrega procura se tem um outro pedido atrelado como troca nota
    If !((_cAlias)->( Eof() ))

        _cQuery := " SELECT "
        _cQuery +=     " ZF9.ZF9_FILIAL AS FILIAL,"
        _cQuery +=     " ZF9.ZF9_CODPRG AS CODPRG,"
        _cQuery +=     " ZF7.ZF7_STATUS AS STSZF7, "
        _cQuery +=     " ZF7.ZF7_USRLOG AS USRLOG,"
        _cQuery +=     " ZF7.R_E_C_N_O_ AS ZF7RECNO,"
        _cQuery +=     " ZF9.R_E_C_N_O_ AS ZF9RECNO,"
        _cQuery +=     " ZF7.ZF7_USRPRG AS USRPRG"
        _cQuery += " FROM "+ RetSqlName('ZF9') +" ZF9, "+ RetSqlName('ZF7') +" ZF7 "
        _cQuery += " WHERE "
        _cQuery +=     " ZF9.D_E_L_E_T_ = ' ' "
        _cQuery += " AND ZF7.D_E_L_E_T_ = ' ' "
        _cQuery += " AND ZF9.ZF9_FILIAL = ZF7.ZF7_FILIAL "
        _cQuery += " AND ZF9.ZF9_CODPRG = ZF7.ZF7_CODIGO "
        _cQuery += " AND ZF7.ZF7_STATUS <> '6' "
        _cQuery += " AND ZF9.ZF9_FILIAL = '"+ (_cAlias)->FILIAL 	+"' "
        _cQuery += " AND ZF9.ZF9_CODPRG = '"+ (_cAlias)->CODPRG    	+"' "
        _cQuery += " AND ZF9.ZF9_ITNPED = '"+ (_cAlias)->ITEM    	+"' "

        _cAlias2 := GetNextAlias()

        MPSysOpenQuery(_cQuery,_cAlias2)
        (_cAlias2)->( DBGoTop() )

//Se n�o achou como pedido prim�rio fecha a query e procura como pedido de troca nota em uma programa��o
    Else

        _cQuery := " SELECT "
        _cQuery +=     " ZF9.ZF9_FILIAL AS FILIAL,"
        _cQuery +=     " ZF9.ZF9_CODPRG AS CODPRG,"
        _cQuery +=     " ZF9.ZF9_ITNPED AS ITNPED,"
        _cQuery +=     " ZF7.ZF7_STATUS AS STSZF7, "
        _cQuery +=     " ZF7.ZF7_USRLOG AS USRLOG,"
        _cQuery +=     " ZF7.R_E_C_N_O_ AS ZF7RECNO,"
        _cQuery +=     " ZF9.R_E_C_N_O_ AS ZF9RECNO,"
        _cQuery +=     " ZF7.ZF7_USRPRG AS USRPRG"
        _cQuery += " FROM "+ RetSqlName('ZF9') +" ZF9, "+ RetSqlName('ZF7') +" ZF7 "
        _cQuery += " WHERE "
        _cQuery +=     " ZF9.D_E_L_E_T_ = ' ' "
        _cQuery += " AND ZF7.D_E_L_E_T_ = ' ' "
        _cQuery += " AND ZF9.ZF9_FILIAL = ZF7.ZF7_FILIAL "
        _cQuery += " AND ZF9.ZF9_CODPRG = ZF7.ZF7_CODIGO "
        _cQuery += " AND ZF7.ZF7_STATUS <> '6' "
        _cQuery += " AND ZF9.ZF9_FILIAL = '"+ SC5->C5_FILIAL +"' "
        _cQuery += " AND ZF9.ZF9_PEDIDO = '"+ SC5->C5_NUM    +"' "

        _cAlias2 := GetNextAlias()

        MPSysOpenQuery(_cQuery,_cAlias2)
        (_cAlias2)->( DBGoTop() )

        //Se achou como pedido de nota fiscal de troca procura o pedido principal em programa��o
        If !((_cAlias2)->( Eof() ))

            _cQuery := " SELECT "
            _cQuery +=     " ZF8.ZF8_FILIAL AS FILIAL,"
            _cQuery +=     " ZF8.ZF8_CODPRG AS CODPRG,"
            _cQuery +=     " ZF8.ZF8_ITEM   AS ITEM,"
            _cQuery +=     " ZF7.ZF7_STATUS AS STSZF7, "
            _cQuery +=     " ZF7.ZF7_USRLOG AS USRLOG,"
            _cQuery +=     " ZF7.R_E_C_N_O_ AS ZF7RECNO,"
            _cQuery +=     " ZF8.R_E_C_N_O_ AS ZF8RECNO,"
            _cQuery +=     " ZF7.ZF7_USRPRG AS USRPRG"
            _cQuery += " FROM "+ RetSqlName('ZF8') +" ZF8, "+ RetSqlName('ZF7') +" ZF7 "
            _cQuery += " WHERE "
            _cQuery +=     " ZF8.D_E_L_E_T_ = ' ' "
            _cQuery += " AND ZF7.D_E_L_E_T_ = ' ' "
            _cQuery += " AND ZF8.ZF8_FILIAL = ZF7.ZF7_FILIAL "
            _cQuery += " AND ZF8.ZF8_CODPRG = ZF7.ZF7_CODIGO "
            _cQuery += " AND ZF7.ZF7_STATUS <> '6' "
            _cQuery += " AND ZF8.ZF8_FILIAL = '"+ (_cAlias2)->FILIAL 	+"' "
            _cQuery += " AND ZF8.ZF8_CODPRG = '"+ (_cAlias2)->CODPRG    	+"' "
            _cQuery += " AND ZF8.ZF8_ITEM = '" + (_cAlias2)->ITNPED    	+"' "

            _cAlias := GetNextAlias()

            MPSysOpenQuery(_cQuery,_cAlias)
            (_cAlias)->( DBGoTop() )

        Endif

    Endif

//Guarda dados de pedido na programa��o e na programa��o de troca nota

    If ((_cAlias)->( !Eof() ) .And. !Empty( (_cAlias)->STSZF7 ))

        lret := .F.
        _nprogs++
        _cfilial := (_cAlias)->FILIAL
        _ccodigo := (_cAlias)->CODPRG
        _cstatus := (_cAlias)->STSZF7
        _cusrlo  := (_cAlias)->USRLOG
        _cusrco  := (_cAlias)->USRPRG
        _nzf7	  := (_cAlias)->ZF7RECNO
        _nzf8	  := (_cAlias)->ZF8RECNO

    EndIf

    If ((_cAlias2)->( !Eof() ) .And. !Empty( (_cAlias2)->STSZF7 ))

        lret := .F.
        _nprogs++
        _cfilial2 := (_cAlias2)->FILIAL
        _ccodigo2 := (_cAlias2)->CODPRG
        _cstatus2 := (_cAlias2)->STSZF7
        _cusrlo  := (_cAlias2)->USRLOG
        _cusrco  := (_cAlias2)->USRPRG
        _nzf7	  := (_cAlias2)->ZF7RECNO
        _nzf9	  := (_cAlias2)->ZF9RECNO

    EndIf

//Fecha queries
    (_cAlias2)->( DBClosearea() )
    (_cAlias)->( DBClosearea() )

//posiciona tabelas de programa��o de logpitica
    ZF7->( Dbgoto(_nzf7) )
    ZF8->( Dbgoto(_nzf8) )
    ZF9->( Dbgoto(_nzf9) )

//Guarda dados de pedidos da zf8 e zf9 para poderem ser usados mesmo depois de apagar as programa��es
    _cfil1 := ZF8->ZF8_FILPED
    _cped1 := ZF8->ZF8_NUMPED
    _cfil2 := ZF9->ZF9_FILIAL
    _cped2 := ZF9->ZF9_PEDIDO


//Puxa dados de usu�rios que receber�o emails
    ZZL->( DBSetOrder(3) )

    If ZZL->( DBSeek( xFilial('ZZL') + _cusrlo ) )

        _cEmail := AllTrim( ZZL->ZZL_EMAIL )

    EndIf

    ZZL->( DBSetOrder(3) )

    If ZZL->( DBSeek( xFilial('ZZL') + _cusrco ) )

        IF !Empty(_cEmail)

            _cEmail += ','

        Endif

        _cEmail += AllTrim( ZZL->ZZL_EMAIL )

        If !lret

            If _nprogs == 1

                _lresp := .F.

                _lresp := u_itmsg('O pedido selecionado est� amarrado � uma programa��o de entrega da Log�stica ! '	+ Chr(13) + Chr(10)  + Chr(13) + Chr(10)  +;
                    'A programa��o ser� ajustada de acordo com esta exclus�o e um email de alerta ser� enviado para ' + _cemail ,;
                    'Valida��o de programa��o de entrega',;
                    'Deseja continuar ajustando a programa��o?'+ Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                    '['+ _cfilial +'/'+ _ccodigo +']  - Pedido  ' + _cfil1 + '/' + _cped1 + '- Status: '+ U_ITRETBOX( _cstatus , 'ZF7_STATUS' ),3,2,2)

                If _lresp

                    lret := .T.

                    If u_remprog() //Remove programa��o e retorna true se bem sucedido

                        u_mailprog(_cemail, 1) //Envia email de remo��o de pedido da programa��o para respons�veis

                        lret := .T.

                    Else

                        u_itmsg('N�o foi poss�vel realizar ajustes na programa��o, exclus�o n�o ser� realizada!',,,1)


                    Endif

                Endif

            Else

                _lresp := .F.

                _lresp := u_itmsg('O pedido selecionado est� amarrado � programa��es de entrega e troca nota da Log�stica ! '	+ Chr(13) + Chr(10)  + Chr(13) + Chr(10)  +;
                    'As programa��es ser� ajustada de acordo com esta exclus�o e um email de alerta ser� enviado para ' + _cemail ,;
                    'Valida��o de programa��o de entrega',;
                    'Deseja continuar ajustando as programa��es?'+ Chr(13) + Chr(10) + ;
                    '['+ _cfilial +'/'+ _ccodigo +']  - Pedido  ' + _cfil1 + '/' + _cped1 + '- Status: '+ U_ITRETBOX( _cstatus , 'ZF7_STATUS' ) + Chr(13) + Chr(10) +;
                    '['+ _cfilial2 +'/'+ _ccodigo2 +']  - Pedido  ' + _cfil2 + '/' + _cped2 + '- Status: '+ U_ITRETBOX( _cstatus2 , 'ZF7_STATUS' )  ,3,2,2)

                If _lresp

                    If u_remprog() //Remove programa��o e retorna true se bem sucedido

                        u_mailprog(_cemail, 2) //Envia email de remo��o de pedido da programa��o para respons�veis

                        lret := .T.

                    Else

                        u_itmsg( 'N�o foi poss�vel realizar ajustes nas programa��es, exclus�o n�o ser� realizada!', 'Aten��o!',,1)

                    Endif


                Endif

            Endif

        EndIf

    Endif


    SC5->( Restarea(_aAreaSC5) )
    ZF7->( Restarea(_aAreaZF7) )
    ZF8->( Restarea(_aAreaZF8) )
    ZF9->( Restarea(_aAreaZF9) )


Return lret

/*
===============================================================================================================================
Programa--------: mailprog
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 12/05/2016
===============================================================================================================================
Descri��o-------: Monta e dispara o WF de cancelamento de programa��o de entrega
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: _cEmail - email para enviar WF
                    _ntipo - se � programa��o de entrega ( 1 ) ou de entrega com troca nota ( 2 )
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function mailprog( _cEmail, _ntipo   )

    Local _aConfig		:= U_ITCFGEML('')
    Local _cMsgEml		:= ''
    Local _cStsAux		:= ''

    _cMsgEml := '<html>'
    _cMsgEml += '<head><title>Programa��o de Entrega</title></head>'
    _cMsgEml += '<body>'
    _cMsgEml += '<style type="text/css"><!--'
    _cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
    _cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
    _cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
    _cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
    _cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
    _cMsgEml += '--></style>'
    _cMsgEml += '<center>'
    _cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
    _cMsgEml += '<table class="bordasimples" width="600">'
    _cMsgEml += '    <tr>'


    _cMsgEml += '	 </tr>'
    _cMsgEml += '</table>'
    _cMsgEml += '<br>'
    _cMsgEml += '<table class="bordasimples" width="600">'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td align="center" colspan="2" class="grupos">Id. da Programa��o: <b>'+ ZF7->ZF7_FILIAL +'/'+ ZF7->ZF7_CODIGO +'</b></td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ AllTrim( Posicione('SM0',1,cEmpAnt+ZF7->ZF7_FILIAL,'M0_FILIAL') ) +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Coordenador:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ AllTrim( Posicione('SA3',1,xFilial('SA3')+ZF7->ZF7_CODSUP,'A3_NOME') ) +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Tipo de Carga:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ U_ITRETBOX( ZF7->ZF7_TIPCAR , 'ZF7_TIPCAR' ) +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data Aprov.:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ DtoC( ZF7->ZF7_DATA ) +' - '+ SubStr( ZF7->ZF7_HORA , 1 , 5 ) +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Prazo:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ U_ITRETBOX( ZF7->ZF7_PRAZO , 'ZF7_PRAZO' ) +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Obs. Program.:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ AllTrim( ZF7->ZF7_OBS ) +'</td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Motivo da remo��o:</b></td>'
    _cMsgEml += '      <td class="itens" > Exclus�o do pedido </td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '	<tr>'
    _cMsgEml += '		<td class="grupos" align="center" colspan="2"><b>Para maiores informa��es acesse o sistema e visualize a programa��o.</b></td>'
    _cMsgEml += '	</tr>'
    _cMsgEml += '	<tr>'
    _cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta � uma mensagem autom�tica. Por favor n�o a responda!</u></font></td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '</table>'

    _cMsgEml += '<br>'
    _cMsgEml += '<table class="bordasimples" width="800">'
    _cMsgEml += '    <tr>'

    _cMsgEml += '      <td align="center" colspan="3" class="grupos">Pedido removidos da Programa��o por exclus�o</b></td>'

    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'


    _cMsgEml += '      <td class="itens" align="center" width="20%"><b>Pedidos:</b></td>'
    _cMsgEml += '      <td class="itens" align="center" width="20%"><b>Peso:</b></td>'
    _cMsgEml += '      <td class="itens" align="center" width="60%"><b>Cliente:</b></td>'

    _cMsgEml += '    </tr>'

    //Posiciona SC5
    SC5->( DbSetorder(1) )
    SC5->( DbSeek( _cfil1 + _cped1 ))

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="20%">'+ SC5->C5_FILIAL +'-'+ SC5->C5_NUM			+'</td>'
    _cMsgEml += '      <td class="itens" align="right"  width="20%">'+ AllTrim( Transform( SC5->C5_I_PESBR , '@E 999,999,999.9999' ) )			+'</td>'
    _cMsgEml += '      <td class="itens" align="left"   width="60%">'+ SC5->C5_CLIENTE +'/'+ SC5->C5_LOJACLI +' - '+ PadR( SC5->C5_I_NOME , 60 )	+'</td>'
    _cMsgEml += '    </tr>'

    If _ntipo == 2

        //Posiciona SC5
        SC5->( DbSeek( _cfil2 + _cped2 ))


        _cMsgEml += '    <tr>'
        _cMsgEml += '      <td class="itens" align="center" width="20%">'+ SC5->C5_FILIAL +'-'+ SC5->C5_NUM			+'</td>'
        _cMsgEml += '      <td class="itens" align="right"  width="20%">'+ AllTrim( Transform( SC5->C5_I_PESBR , '@E 999,999,999.9999' ) )			+'</td>'
        _cMsgEml += '      <td class="itens" align="left"   width="60%">'+ SC5->C5_CLIENTE +'/'+ SC5->C5_LOJACLI +' - '+ PadR( SC5->C5_I_NOME , 60 )	+'</td>'
        _cMsgEml += '    </tr>'

    Endif


    _cMsgEml += '</table>'

    _cMsgEml += '</center>'
    _cMsgEml += '</body>'
    _cMsgEml += '</html>'

    _cEmlLog := ''

    _cStsAux := 'Remo��o de Pedidos por exclus�o'

    U_ITENVMAIL( _aConfig[01] , _cEmail ,,, 'Programa��o de entregas - Exclus�o de Pedido ['+ DtoC( Date() ) +']' , _cMsgEml ,, _aConfig[01] , _aConfig[02] , _aConfig[03] , _aConfig[04] , _aConfig[05] , _aConfig[06] , _aConfig[07] , @_cEmlLog )

Return()

/*
================================================================================================================================
Programa--------: Remprog
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 12/05/2016
===============================================================================================================================
Descri��o-------: Remove programa��o de entrega de pedido excluido
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: lret - sempre true
===============================================================================================================================

*/
User Function Remprog()

    Local _lret  		:= .F.
    Local _npeds 		:= 0
    Local _cAlias 	:= ""

//Analisa se existe mais de um pedido na programa��o de entrega
    _cQuery := " SELECT "
    _cQuery +=     " COUNT(ZF8_FILIAL) AS TOTI"
    _cQuery += " FROM "+ RetSqlName('ZF8') +" ZF8 "
    _cQuery += " WHERE "
    _cQuery +=     " ZF8.D_E_L_E_T_ = ' ' "
    _cQuery += " AND ZF8.ZF8_FILIAL = '" + ZF7->ZF7_FILIAL + "'"
    _cQuery += " AND ZF8.ZF8_CODPRG = '" + ZF7->ZF7_CODIGO + "'"

    _cAlias := GetNextAlias()

    MPSysOpenQuery(_cQuery,_cAlias)
    (_cAlias)->( DBGoTop() )

    _npeds := (_cAlias)->TOTI

    (_cAlias)->( DbClosearea() )

    BEGIN TRANSACTION

        If _npeds == 1

            //Se � o �nico pedido da programa��o mant�m o registro e muda a programa��o para cancelada
            ZF7->( Reclock("ZF7", .F.) )

            ZF7->ZF7_STATUS := '6'

            ZF7->( Msunlock() )

        Else

            //Se tem mais de um pedido na programa��o faz a exclus�o do pedido e do pedido de troca nota da programa��o
            ZF8->( Reclock("ZF8", .F.))

            ZF8->( Dbdelete() )

            ZF8->( Msunlock() )

            //Se tem pedido para troca de nota tamb�m exclui a programa��o

            If !( ZF9->( Eof() ) )

                ZF9->( Reclock("ZF9", .F.))

                ZF9->( Dbdelete() )

                ZF9->( Msunlock() )

            Endif

        Endif

    END TRANSACTION

    _lret := .T.

Return _lret

/*
===============================================================================================================================
Programa----------: OMSMSGN2
Autor-------------: Vanderson Azevedo
Data da Criacao---: 09/11/2016
===============================================================================================================================
Descricao---------: Valida mensagem fiscal para credenciados da IN1298 de Goias
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet - (.T./.F.) de acordo com as valida??es
===============================================================================================================================
Usuario-----------: Rotina reescrita a partir do fonte MOMS008
===============================================================================================================================
*/

User Function OMSMSGN2()

    Local _aArea	:= GetArea()
    Local _lRet     := .F.

    If !Empty(SF2->F2_CARGA) .And. SF2->F2_I_FRET > 0

        SA2->( DBSetOrder(1) )
        If SA2->( DBSeek( xFilial('SA2') + SF2->( F2_I_CTRA + F2_I_LTRA ) ) )

            //====================================================================================================
            // Verifica se e transportadora ou Autonomo
            //====================================================================================================
            If SA2->A2_I_CLASS == 'T' .And. SM0->M0_ESTENT == 'GO' .And. SA2->A2_I_I1298 == 'S'

                //====================================================================================================
                // Verifica se � uma opera��o para fora do estado
                //====================================================================================================
                _lRet := ( SA2->A2_I_I1298 == 'S' .And. SF2->F2_EST <> SM0->M0_ESTENT )
            EndIf

        EndIf

    EndIf

    RestArea( _aArea )

Return( _lRet )

/*
================================================================================================================================
Programa--------: omsvldent
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 05/04/2017
===============================================================================================================================
Descri��o-------: Fun��o para valida��o da data de entrega de um pedido de vendas
===============================================================================================================================
Parametros------: _ddtent     - Data de entrega � validar
                  _cClient    - Cliente
                  _cLoja      - Loja
                  _cfilft     - Filial de Faturamento
                  _cpedido    - numero do pedido
                  _nret       - Retorna valida��o de data de entrega ou dias de transit tima
                  _lshow      - mostra mensagem
                  _cFilCarreg - Filial de origem do pedido de vendas
                  _cOperPedV  - Opera��o do Pedido de Vendas
                  _cTipoVenda - Tipo de Venda (Fechada ou Fracionada) 
                  _lAchouZG5  - Para passar como refererencia @_lAchouZG5
                  _cRegra     - Para passar como refererencia @_cRegra
                  _cLocalEmb  - Local de Embarque para usar na nova busca
                  _lValSC5    - Se .t. (DEFAULT) valida e busca dados no SC5 sen�o para usar em um programa novo alem do que j� tem
===============================================================================================================================
Retorno---------: _lRet - .T. data de entrega v�lida, .F. caso contr�rio.
===============================================================================================================================
*/
User Function OMSVLDENT(_ddent,_cClient,_cLoja,_cfilft,_cpedido,_nret,_lshow,_cFilCarreg,_cOperPedV,_cTipoVenda,_lAchouZG5,_cRegra,_cLocalEmb,_lValSC5)

    Local _lret      := .T.
    Local _aSC5      := SC5->(getarea())
    Local _aSZW      := SZW->(getarea())
    Local _aSA1      := SA1->(getarea())
    Local _aSB1      := SB1->(getarea())
    Local _lAchou    := .F.
    Local _lerro     := .F.
    Local npositem	 := aScan( aHeader, { |x| Alltrim(x[2])== "C6_ITEM" } )
    Local nposprod   := aScan( aHeader, { |x| Alltrim(x[2])== "C6_PRODUTO" } )
    Local nposloc    := aScan( aHeader, { |x| Alltrim(x[2])== "C6_LOCAL" } )
    Local _ndias     := 0
    Local _coper     := u_ITGETMV("IT_ENTOPER","01")
    Local _cret      := "N"
    Local _xret      := ""
    Local _cLocal    := ""
    Local _cMesoReg  := ""
    Local _cMicroReg := ""
    Local _cCodMunic := ""
    Local _cEstado   := ""
    Local _lBusca_2  := .F.
    Local _cOperItap := U_ITGETMV("IT_OPERITA","25") //Opera��o Itapetininga
    Local _cArmaItap := U_ITGETMV("IT_ARMAITA","36") //Armazem para Opera��o Itapetininga
    Local _cLocalOp  := ""
    Local _dDtDias   := STOD("")
    Local _nTamaCol  := 0
    Local _lMata410  := FWIsInCallStack("MATA410")
    Local _lAOMS112  := .F.
    Local _lAOMS116  := FWIsInCallStack("U_AOMS116")
    Local _lAOMS109  := FWIsInCallStack("U_AOMS109")
    Local _lAOMS032  := FWIsInCallStack("U_AOMS032")
    Local _laoms074  := .F.
    Local _lAOMS099  := (FWIsInCallStack("U_AOMS099"))
    Local _cTpVen    := ""
    Local _nDiasTrTi := 0
    Local _nRegSA1
    Local _nDiasFech := 0
    Local _nDiasVar  := 0

    Default _nret      := 0
    Default _lshow     := .T.
    Default _cFilCarreg:= ""
    Default _cOperPedV := ""
    Default _lAchouZG5 := .F.
    Default _cRegra    := ""
    Default _lValSC5   := .T.

    _acolsori  := acols
    _nRegSA1   := SA1->(Recno()) 
    _aCabVldent:= {"Item","Estado","Municipio","Armaz�m","Transit Time","Data Digitada","Dt Ent Min","Obs","Produto","Descri��o"}//PRIVATE PARA SER INICIADA NO PROGRAMA QUE CHAMA
    _aIteVldent:= {}//PRIVATE PARA SER INICIADA NO PROGRAMA QUE CHAMA

    //Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetiva��ao Automatica)
    If FWIsInCallStack("U_AOMS112") .or. FWIsInCallStack("U_MOMS050")
        _lAoms112 := .T.
    Endif
    //Se veio do webservice j� retorna .T.
    If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B")
        _laoms074 := .T.
    Endif 

    Begin Sequence

        //=====================================================================
        //Se � an�lise de efetiva��o de pedido pula direto para a an�lise
        //=====================================================================
        if _lAOMS112 .and. !_lMata410

            npositem	:= 1 //'aScan( aHeader, { |x| Alltrim(x[2])== "C6_ITEM" } )'
            nposprod	:= 2 //aScan( aHeader, { |x| Alltrim(x[2])== "C6_PRODUTO" } )
            nposloc	    := 3 //aScan( aHeader, { |x| Alltrim(x[2])== "C6_LOCAL" } )

            //Monta acols
            _nposori := SZW->(Recno())
            acols := {}
            SZW->(Dbsetorder(1))
            SZW->(Dbseek(_cfilft+_cpedido))

            _cLocalOp := Iif(SZW->ZW_TIPO $ _cOperItap,_cArmaItap,"")
            _cTpVen   := _cTipoVenda

            Do while SZW->ZW_FILIAL == _cfilft .AND. SZW->ZW_IDPED == _cpedido

                aadd(acols,{SZW->ZW_ITEM,SZW->ZW_PRODUTO,SZW->ZW_LOCAL})

                SZW->(Dbskip())

            Enddo 

            SZW->(Dbgoto(_nposori))  

        ElseIF !_lAOMS116 .AND. !_lAOMS099.AND.  !_laoms074 .AND. !_lAOMS032 .AND. _lValSC5

            //======================================================================
            //Localiza pedido
            //======================================================================
            //SC5->(Dbsetorder(14))//falta criar NICKNAME PARA USAR DBOrderNickName()
            SC5->(DbOrderNickName("IT_NUM"))//C5_NUM - OERDEM P - 25
            If !SC5->(Dbseek(_cpedido))
 
                //Verifica se � inclus�o
                If _lMata410 .and. inclui 

                    //======================================================================
                    //Valida se tipo de pedido e opera��o deve ter data de entrega validada
                    //Se n�o precisa validar retorna true ou zero dias de transit time
                    //======================================================================

                    If !(M->C5_TIPO == "N") .OR. !(M->C5_I_OPER $ _coper) 

                        If _nret == 0 

                            //Valida se data � menor que data atual
                            If empty(_ddent) .OR. _ddent < date()

                                _cObs:="Data de Entrega do Pedido inferior a data atual.."
                                If _lshow
                                    U_MT_ITMSG("Data de Entrega do Pedido inferior a data atual!","Aten��o - Pedido " + _cpedido ,"Digite uma Data de Entrega superior a data atual.",1)
                                Endif

                                _cRet := "S"
                                _xret := .F.
                                Break

                            Else

                                _cRet := "S"
                                _xret := .T.
                                Break

                            Endif

                        Else

                            _cRet := "S"
                            _xret := 0
                            Break

                        Endif

                    Endif

                Else

                    //Se n�o achou pedido retorna .F. ou -1
                    _cObs:="Pedido n�o localizado para validar data de entrega!"
                    If _lshow
                        U_MT_ITMSG("Pedido n�o localizado para validar data de entrega!")
                    Endif

                    If _nret == 0

                        _cRet := "S"
                        _xret := .F.
                        Break

                    Else

                        _cRet := "S"
                        _xret := -1
                        Break

                    Endif

                Endif

            Else

                //======================================================================
                //Valida se tipo de pedido e opera��o deve ter data de entrega validada
                //Se n�o precisa validar retorna true ou zero dias de transit time
                //======================================================================

                If (!(SC5->C5_TIPO == "N") .OR. !(SC5->C5_I_OPER $ _coper)) .and. !(SC5->C5_I_AGEND $ "AM" .AND. _lAOMS032)
                    _cRegra:=" N�o busca dias para C5_TIPO ["+SC5->C5_TIPO+"] <> N ou C5_I_OPER ["+SC5->C5_I_OPER+"] <> "+_coper//+" e C5_I_AGEND ["+SC5->C5_I_AGEND+"] <> 'AM'
                    If _nret == 0

                        //Valida se data � menor que data atual
                        If empty(_ddent) .OR. _ddent < date()

                            _cObs:="Data de Entrega do Pedido inferior a data atual."
                            If _lshow
                                U_MT_ITMSG("Data de Entrega do Pedido inferior a data atual!","Aten��o - Pedido " + _cpedido ,"Digite uma Data de Entrega superior a data atual.",1)
                            endif

                            _cRet := "S"
                            _xret := .F.
                            Break

                        Else

                            _cRet  := "S"
                            _xret  := .T.
                            Break

                        Endif

                    Else

                        _cRet := "S"
                        _xret := 0
                        Break

                    Endif

                Elseif (SC5->C5_I_AGEND $ "AM" .AND. _lAOMS032)

                    If _nret > 0

                        _lret := 0

                    Else

                        _lret := .T.

                    Endif

                    Return _lret

                Endif


            Endif

            If Type("M->C5_I_OPER") == "C" .And. _lMata410 .And. !_lAOMS032
                _cLocalOp := Iif(M->C5_I_OPER $ _cOperItap,_cArmaItap,"")
                _cTpVen   := M->C5_I_TPVEN
            Else
                _cLocalOp := Iif(SC5->C5_I_OPER $ _cOperItap,_cArmaItap,"")
                _cTpVen   := SC5->C5_I_TPVEN
            EndIf

            //================================================================
            //Valida se data foi preenchida e � maior que a data atual
            //===============================================================
            If (Empty(_ddent) .Or. _ddent < Date()) .and. _nret == 0

                _cprod := '112233'

                _cObs:="Data de Entrega do Pedido inferior a data atual!"
                if _lshow
                    U_MT_ITMSG("Data de Entrega do Pedido inferior a data atual!","Aten��o - Pedido " + _cpedido ,"Digite uma Data de Entrega superior a data atual.",1)
                Endif
                _cRegra:="2-Data de Entrega do Pedido inferior a data atual!"
                _lret := .F.

            Endif

        ElseIF _lAOMS116

            _cLocalOp := Iif("20" $ _cOperItap,_cArmaItap,"")
            _cTpVen   := "F"

        Endif

        //========================================================================
        // Posiciona no cadastro de Clientes.
        //========================================================================
        SA1->(dbSetOrder(1))
        SA1->(MSSeek(xFilial("SA1") + _cClient + _cLoja))

        //===============================================================================
        // REGRAS ANTIGAS DE TRANSIT TIME.
        // Mantida at� que todos os fontes que chamam a fun��o sejam alterados.
        //===============================================================================
        If _lret .And. Empty(_cOperPedV)
            //=================================================================
            // Procura regras de transit time v�lidas
            //=================================================================
            If empty(_cfilft)

                _cfilft := xfilial("SC5")

            Endif

            _ncols := 1
            _nTamaCol := Iif(Empty(_cLocalOp),len(acols),1)

            Do While _ncols <= _nTamaCol

                _cLocal    := Iif(Empty(_cLocalOp),Alltrim(aCols[_nCols][nPosloc]),_cLocalOp)
                _cMesoReg  := "" // Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MESO")
                _cMicroReg := "" //Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MICR")
                _cCodMunic := SA1->A1_COD_MUN
                _cEstado   := SA1->A1_EST
                _lBusca_2  := .F.
                _lAchou    := .F.
                _cRegra    := ""

                If !Empty(_cLocal)

                    ZG5->(DbSetOrder(3))
                    If ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado+_cMesoReg+_cMicroReg+_cCodMunic))
                        _lAchou   := .T.
                        _lBusca_2 := .F.
                        _cRegra   := "Regra Armazem/Estado/Mesorregiao/Microrregiao/Municipio"
                    ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado+_cMesoReg+_cMicroReg))
                        _lAchou   := .T.
                        _lBusca_2 := .F.
                        _cRegra   := "Regra Armazem/Estado/Mesorregiao/Microrregiao"
                    ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado+_cMesoReg))
                        _lAchou   := .T.
                        _lBusca_2 := .F.
                        _cRegra   := "Regra Armazem/Estado/Mesorregiao"
                    ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado))
                        _lAchou   := .T.
                        _lBusca_2 := .F.
                        _cRegra   := "Regra Armazem/Estado"
                    Else
                        _lBusca_2 := .T.
                    EndIf
                    _lAchouZG5 := _lAchou
                Else

                    _lBusca_2 := .T.

                EndIf

                If _lBusca_2

                    ZG5->(DbSetOrder(2))
                    If ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado+_cMesoReg+_cMicroReg+_cCodMunic))
                        _lAchou := .T.
                        _cRegra := "Regra Estado/Mesorregiao/Microrregiao/Municipio"
                    ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado+_cMesoReg+_cMicroReg))
                        _lAchou := .T.
                        _cRegra := "Regra Estado/Mesorregiao/Microrregiao"
                    ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado+_cMesoReg))
                        _lAchou := .T.
                        _cRegra := "Regra Estado/Mesorregiao"
                    ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado))
                        _lAchou := .T.
                        _cRegra := "Regra Estado"
                    Else
                        _lAchou := .F.
                    EndIf
                    _lAchouZG5 := _lAchou
                EndIf

                If _lAchou

                    _nDiasTrTi := Iif(_cTpVen == "F", ZG5->ZG5_DIAS , Iif(ZG5->ZG5_FRDIAS >0,ZG5->ZG5_FRDIAS,ZG5->ZG5_DIAS))
                    _dDtDias   := Date() + _nDiasTrTi + 1

                    If _ddent >= _dDtDias
                        _cObs := _cRegra
                    Else
                        _cObs := "Data de Entrega n�o Permitida !! Somente Data Maior ou Igual a " + dtoc(_dDtDias)
                        _lerro := .T.
                    Endif

                    If _nDiasTrTi > _ndias
                        _ndias := _nDiasTrTi
                    Endif

                Else
                    _nDiasTrTi := 0
                    _ndias   := -1
                    _cObs    := "Cidade do Cliente n�o � atendida pela Filial"
                    _dDtDias := STOD("")
                    _lErro   := .T.

                Endif

                aadd(_aIteVldent, { aCols[_nCols][nPositem],;
                    SA1->A1_EST,;
                    SA1->A1_COD_MUN + " - " + SA1->A1_MUN ,;
                    aCols[_nCols][nPosloc],;
                    _nDiasTrTi,;
                    _ddent,;
                    _dDtDias,;
                    _cObs,;
                    aCols[_nCols][nPosprod],;
                    POSICIONE("SB1",1,xfilial("SB1")+aCols[_nCols][nPosprod],"B1_DESC")	})

                _nCols++

            Enddo


            //================================================================
            //Apresenta itlist se n�o achou regra de transit time
            //===============================================================
            If _lerro .and. _nret == 0

                //05/02/2018 - AWF - AGORA � PARA BLOQUEAR NA transfer�ncia
                If .F. //FWIsInCallStack( 'U_AOMS032' ) //Se for transfer�ncia apresenta mensagem diferenciada e n�o bloqueia

                    //If n == 1  //S� apresenta mensagem quando passa na primeira linha mas valida todas as linhas na rotina acima

                    //	U_MT_ITMSG("Data de entrega inv�lida com regras de transit time!","Aten��o - Pedido " + _cpedido ,"Verifique na pr�xima tela as regras e confirme ou cancele a transfer�ncia",1)

                    //	_lret := .F. //Se fechar a janela pelo X cancela transa��o
                    //	_lret :=  U_ITListBox( 'Resultados das regras de transit time para o pedido' ,  _aCabVldent ,_aIteVldent,.T.,1)


                    //Endif

                Else

                    _cObs:="Data de entrega inv�lida com regras de transit time!"
                    If _lshow

                        IF FWIsInCallStack( 'U_AOMS032' ) .OR. FWIsInCallStack("MSEXECAUTO")
                           U_MT_ITMSG("Data de entrega inv�lida com regras de transit time!","Aten��o - Pedido " + _cpedido ,"Ajuste a data de entrega ou cadastro de transit time.",1)
                        ELSE
                           U_MT_ITMSG("Data de entrega inv�lida com regras de transit time!","Aten��o - Pedido " + _cpedido ,"Ajuste a data de entrega ou cadastro de transit time de acordo com a pr�xima tela",1)
                           U_ITListBox( 'Resultados das regras de transit time para o pedido' , _aCabVldent ,_aIteVldent,.T.,1)
                        ENDIF

                    Endif

                    _lret := .F.

                Endif


            Endif

        Else
            //=================================================================
            // NOVAS REGRAS DE TRANSIT TIME.
            // Para entrar neste trecho os novos par�metros da fun��o devem
            // estar preenchidos.
            //=================================================================
            If _lret
                _cMesoReg  := Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MESO")
                _cMicroReg := Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MICR")
                _cCodMunic := SA1->A1_COD_MUN
                _cEstado   := SA1->A1_EST
                _lAchouZG5 := .F.
                _nDiasFech := 0
                _nDiasVar  := 0

                If Empty(_cFilCarreg)
                    _cFilCarreg := xFilial("SC5")
                EndIf
                
                IF _cLocalEmb = NIL//SEM PASSAR O LOCAL DE EMBARQUE
                    
                    //  FILIAL+FILIAL ORIGEM+ESTADO+OPERACAO+MUNICIPIO+MESO REGIAO+MICRO REGIAL
                    ZG5->(DbSetOrder(4)) // ZG5_FILIAL+ZG5_FILORI+ZG5_UF+ZG5_OPER+ZG5_CODMUN+ZG5_MESO+ZG5_MICRO
                    If ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+_cOperPedV+SA1->A1_COD_MUN+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
                        //1)	Primeira Busca (Estado + Opera��o + Munic�pio)
                        If ZG5->ZG5_FILORI = _cFilCarreg .And. ZG5->ZG5_UF = SA1->A1_EST .And. ZG5->ZG5_OPER = _cOperPedV
                            _lAchouZG5 := .T.
                            _cRegra := "Regra Filial/Estado/Operacao/Municipio:"+_cFilCarreg+SA1->A1_EST+_cOperPedV+SA1->A1_COD_MUN+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")
                        ENDIF
                    ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+_cMicroReg))
                        //2)	Se n�o encontrou na regra anterior (Estado + Opera��o + Mesorregi�o + Microrregi�o)
                        _lAchouZG5 := .T.
                        _cRegra := "Regra Filial/Estado/Operacao/Mesorregiao/Microrregiao:"+xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+_cMicroReg
    
                    ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+U_ITKEY(" ","ZG5_MICRO")))
                        //3)	Se n�o encontrou na regra anterior (Estado + Opera��o + Mesorregi�o)
                        _lAchouZG5 := .T.
                        _cRegra := "Regra Filial/Estado/Operacao/Mesorregiao:"+xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+U_ITKEY(" ","ZG5_MICRO")
    
                    ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
                        //4)	Se n�o encontrou na regra anterior (Estado + Opera��o)
                        _lAchouZG5 := .T.
                        _cRegra := "Regra Filial/Estado/Operacao:"+xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")
    
                    ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+SA1->A1_COD_MUN+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
                        //5)	Se n�o encontrou na regra anterior (Estado +Munic�pio)
                        _lAchouZG5 := .T.
                        _cRegra := "Regra Filial/Estado/Municipio:"+xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+SA1->A1_COD_MUN+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")
    
                    ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+_cMicroReg))
                        //6)	Se n�o encontrou na regra anterior (Estado + Mesorregi�o + Microrregi�o)
                        _lAchouZG5 := .T.
                        _cRegra := "Regra Filial/Estado/Mesorregiao/Microrregiao:"+xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+_cMicroReg
    
                    ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+U_ITKEY(" ","ZG5_MICRO")))
                        //7)	Se n�o encontrou na regra anterior (Estado + Mesorregi�o)
                        _lAchouZG5 := .T.
                        _cRegra := "Regra Filial/Estado/Mesorregiao:"+xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+U_ITKEY(" ","ZG5_MICRO")
    
                    ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
                        //8)	Se n�o encontrou na regra anterior (Estado)
                        _lAchouZG5 := .T.
                        _cRegra := "Regra Filial/Estado:"+xFilial("ZG5")+_cFilCarreg+SA1->A1_EST+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")
                    ELSE
                        _cRegra := "N�o achou Filial/Estado/Operacao/Municipio/Mesorregiao/Microrregiao:"+_cFilCarreg+"/"+SA1->A1_EST+"/"+_cOperPedV+"/"+SA1->A1_COD_MUN+"/"+_cMesoReg+"/"+_cMicroReg
                    EndIf
                
                ELSEIF !EMPTY(_cLocalEmb) //PASSANDO O LOCAL DE EMBARQUE
                
                 // FILIAL + LOCAL DE EMBARQUE + ESTADO + MUNICIPIO + MESO_REGIAO + MICRO_REGIAO
                     ZG5->(DbSetOrder(5)) // ZG5_FILIAL+ZG5_LOCEMB+ZG5_UF+ZG5_CODMUN+ZG5_MESO+ZG5_MICRO
                     If ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+SA1->A1_EST+SA1->A1_COD_MUN+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
                         _cRegra:= "1) Buscou por (Local de embarque + Estado + Munic�pio)"
                         _lAchouZG5 := .T.
                     ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+SA1->A1_EST+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+_cMicroReg))
                         _cRegra:= "2) Buscou por (Local de embarque + Estado + Mesorregi�o + Microrregi�o)"
                         _lAchouZG5 := .T.
                     ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+SA1->A1_EST+U_ITKEY(" ","ZG5_CODMUN")+_cMesoReg+U_ITKEY(" ","ZG5_MICRO")))
                         _cRegra:= "3) Buscou por (Local de embarque + Estado + Mesorregi�o)"
                         _lAchouZG5 := .T.
                     ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+SA1->A1_EST+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
                         _cRegra:= "4) Buscou por (Local de embarque + Estado )"
                         _lAchouZG5 := .T.
                    ELSE
                        _cRegra := "N�o achou Local de Embarque/Estado/Municipio/Mesorregiao/Microrregiao:"+_cLocalEmb+"/"+SA1->A1_EST+"/"+SA1->A1_COD_MUN+"/"+_cMesoReg+"/"+_cMicroReg
                     EndIf
                
                ENDIF
                _lret      := _lAchouZG5
                _ndias     := 0

                If _lAchouZG5
                    _nDiasFech := ZG5->ZG5_DIAS
                    _nDiasVar  := ZG5->ZG5_FRDIAS

                    If _cTipoVenda == "F" // Quando Carga Fechada
                        _ndias := _nDiasFech + 1
                    Else // _cTipoVenda == "V" Quando Carga Fracionada (Varejo)
                        _ndias := _nDiasVar  + 1
                    EndIf
 
                EndIf
 
                If _nret == 0 .AND. !_lAOMS099 .AND.  !_laoms074 .AND. !_lAOMS032
                   _cObs:=_cRegra
                    If Empty(_ddent) .OR. Dtos(_ddent) <= Dtos(Date()) .Or. Dtos((_ddent + _ndias)) <= Dtos(Date())
                        _cObs:="Data de Entrega do Pedido inferior ou igual a data atual!"
                        If _lshow
                            U_MT_ITMSG(_cObs,"Aten��o - Pedido " + _cpedido ,"Digite uma Data de Entrega superior a data atual.",1)
                        EndIf
                        _lret := .F.   
                        Break          
                    EndIf

                    If ! _lAchouZG5
                        _cObs:="Transit Time n�o localizado!"
                        If _lshow
                            U_MT_ITMSG(_cObs,"Aten��o - Pedido " + _cpedido ,"Cadastre um Transit Time para este pedido de vendas.",1)
                        EndIf
                    Else
                        If Dtos(_ddent) < Dtos((Date() + _ndias))

                            _cObs:="Data de Entrega do Pedido inferior ao Transit Time do Pedido de Vendas!"
                            If _lshow
                                U_MT_ITMSG(_cObs,"Aten��o - Pedido " + _cpedido ,"Digite uma Data de Entrega superior ao Transit Time do Pedido de Vendas.",1)
                            EndIf
                            _lret := .F. 
                            Break        
                        EndIf
                    EndIf


                EndIf
            EndIf
        EndIf

    End Sequence

    SA1->(DbGoTo(_nRegSA1))

    If _nret > 0

        _lret := _ndias

    Else

        If !_lret .and. _lAOMS109

            _lret := .T.

        Endif

    Endif

    Restarea(_aSC5)
    Restarea(_aSZW)
    Restarea(_aSA1)
    Restarea(_aSB1)

    acols := _acolsori

Return _lret

/*
================================================================================================================================
Programa--------: retlgilga
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 09/05/2017
===============================================================================================================================
Descri��o-------: Fun��o para retornar string a ser gravado nos campos usrlgi/uarlga
===============================================================================================================================
Parametros------: _cid - id do usu�rio
===============================================================================================================================
Retorno---------: _cstring -> string a ser gravado nos campos usrlgi/uarlga
===============================================================================================================================
*/
User Function retlgilga(_cid)

    Local _cstring := ""
    Local _npos := SC5->(Recno())
    Local _aAreaAnt := GETAREA("SC5")


//Detecta string sendo gravado no dia para pegar padr�o de data
    SC5->(DbOrderNickName("IT_NUM"))//C5_NUM - OERDEM P - 25
    SC5->(DBGoBottom())

    _cstring := SC5->C5_USERLGI

    SC5->(Dbgoto(_npos))

    _cstring := substr(_cstring,1,10) + substr(_cid,1,1) + substr(_cstring,12,len(_cstring))
    _cstring := substr(_cstring,1,14) + substr(_cid,2,1) + substr(_cstring,16,len(_cstring))
    _cstring := substr(_cstring,1,1) + substr(_cid,3,1) + substr(_cstring,3,len(_cstring))
    _cstring := substr(_cstring,1,5) + substr(_cid,4,1) + substr(_cstring,7,len(_cstring))
    _cstring := substr(_cstring,1,9) + substr(_cid,5,1) + substr(_cstring,11,len(_cstring))
    _cstring := substr(_cstring,1,13) + substr(_cid,6,1) + substr(_cstring,15,len(_cstring))

    RESTAREA(_aAreaAnt)

Return _cstring

/*
===============================================================================================================================
Fun��o-------------: STPEDIDO
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 24/05/2017
===============================================================================================================================
Descri��o---------: Retorna status do pedido
===============================================================================================================================
Parametros--------: _ntipo - 0 Retorna status por c�digo a ser decomposto
                             1 Retorna status em texto leg�vel por humanos
===============================================================================================================================
Retorno-----------: _cstatus
                    1 - Pedido de Venda em Aberto
                    2 - Pedido de Venda Encerrado 
                    3 - Pedido de Venda Liberado
                    4 - Pedido de Venda com Bloqueio de Estoque
                    5 - Pedido de Venda com Bloqueio de Verba
                    6 - Pedido de Venda com Bloqueio de Bonifica��o
                    7 - Pedido de Venda com Bonifica��o Rejeitada
                    8 - Pedido de Venda com Bloqueio de Pre�o
                    9 - Pedido de Venda com Pre�o Rejeitado 
                    10 - Pedido de Venda com Bloqueio de Cr�dito
                    11 - Pedido de Venda com Cr�dito Rejeitado
                    12 - Pedido Carregamento Troca Nota Aberto
                    13 - Pedido Carregamento Troca Nota Liberado
                    14 - Pedido Faturamento Troca Nota Aberto
                    15 - Pedido Faturamento Troca Nota Liberado
                    
===============================================================================================================================
*/  
User Function STPEDIDO(_ntipo)

    Local _nstatus := 1
    Local _cstatus := ""
    Local _lbloq := .T.
    Default _ntipo := 0

    If (SC5->C5_I_BLOQ == ' ' .OR. SC5->C5_I_BLOQ == 'L')

        If ( SC5->C5_I_BLPRC == ' ' .Or. SC5->C5_I_BLPRC == 'L' .Or. SC5->C5_I_BLPRC == 'C')

            If (SC5->C5_I_BLCRE == ' ' .Or. SC5->C5_I_BLCRE == 'L' .Or. SC5->C5_I_BLCRE == 'C')

                _lbloq := .F. //Pedido n�o tem bloqueio de cr�dito/pre�o/bonificacao

            Endif

        Endif

    Endif


    Begin Sequence

        If !EMPTY(SC5->C5_NOTA)

            _nstatus := 02
            _cstatus := "Pedido de Venda Encerrado"
            Break

        Endif

        If SC5->C5_I_TRCNF = 'S' .AND. SC5->C5_I_PDFT = SC5->C5_NUM .AND. !Empty(SC5->C5_LIBEROK) .AND. !_lbloq

            If !(u_verest()) //Fun��o que verifica se tem SC9 com bloqueio de estoque, � priorit�rio em cima da legenda de troca nota

                _nstatus := 04
                _cstatus := "Pedido de Venda com Bloqueio de Estoque"
                Break

            Endif

            _nstatus := 15
            _cstatus := "Pedido Faturamento Troca Nota Liberado"
            Break

        Endif

        If SC5->C5_I_TRCNF = 'S' .AND. SC5->C5_I_PDFT = SC5->C5_NUM .AND. Empty(SC5->C5_LIBEROK) .AND. !_lbloq

            _nstatus := 14
            _cstatus := "Pedido Faturamento Troca Nota"
            Break

        Endif

        If SC5->C5_I_TRCNF = 'S' .AND. Empty(SC5->C5_I_PDFT) .AND. !Empty(SC5->C5_LIBEROK) .AND. !_lbloq

            If !(u_verest()) //Fun��o que verifica se tem SC9 com bloqueio de estoque, � priorit�rio em cima da legenda de troca nota

                _nstatus := 04
                _cstatus := "Pedido de Venda com Bloqueio de Estoque"
                Break

            Endif

            _nstatus := 13
            _cstatus := "Pedido Carregamento Troca Nota Liberado"
            Break

        Endif

        If SC5->C5_I_TRCNF = 'S' .AND. Empty(SC5->C5_I_PDFT) .AND. Empty(SC5->C5_LIBEROK) .AND. !_lbloq

            _nstatus := 12
            _cstatus := "Pedido Carregamento Troca Nota"
            Break

        Endif

        If SC5->C5_I_BLCRE == 'R'

            _nstatus := 11
            _cstatus := "Pedido de Venda com Cr�dito Rejeitado"
            Break

        Endif

        If SC5->C5_I_BLCRE == 'B'

            _nstatus := 10
            _cstatus := "Pedido de Venda com Bloqueio de Cr�dito"
            Break

        Endif

        If SC5->C5_I_BLPRC == 'R'

            _nstatus := 09
            _cstatus := "Pedido de Venda com Pre�o Rejeitado"
            Break

        Endif

        If SC5->C5_I_BLPRC == 'B'

            _nstatus := 08
            _cstatus := "Pedido de Venda com Bloqueio de Pre�o"
            Break

        Endif

        If SC5->C5_I_BLOQ == 'R'

            _nstatus := 07
            _cstatus := "Pedido de Venda com Bonifica��o Rejeitada"
            Break

        Endif

        If SC5->C5_I_BLOQ == 'B'

            _nstatus := 06
            _cstatus := "Pedido de Venda com Bloqueio de Bonifica��o"
            Break

        Endif

        If .F. ///N�O USADO

            _nstatus := 05
            _cstatus := "Pedido de Venda com Bloqueio de Verba"
            Break

        Endif

        If !Empty(SC5->C5_LIBEROK) .and. !(u_verest()) //Fun��o que verifica se tem SC9 com bloqueio de estoque

            _nstatus := 04
            _cstatus := "Pedido de Venda com Bloqueio de Estoque"
            Break

        Endif


        If  !Empty(SC5->C5_LIBEROK) .AND. !_lbloq

            _nstatus := 03
            _cstatus := "Pedido de Venda Liberado"
            Break

        Endif


        If _nstatus == 01

            _cstatus := "Pedido de Venda em Aberto"
            Break

        Endif


    End Sequence

    If _ntipo == 0

        _cstatus := strzero(_nstatus,2)

    Endif


Return _cstatus

/*
===============================================================================================================================
Fun��o------------: ENVSITPV
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 26/05/2016
===============================================================================================================================
Descri��o---------: Gera os dados XML com base nos Pedidos de Vendas selecionados e integra via webservice.
===============================================================================================================================
Parametros--------: _item - dados do pedido a ser bloqueado
===============================================================================================================================
Retorno-----------: Sempre .T.
===============================================================================================================================
*/  
User Function ENVSITPV(_item,_lMarcaEnv)
    Local _cDirXML := ""
    Local _cLink   := ""
    Local _cCabXML := ""
    Local _cRodXML := ""
    Local _cEmpWebService := ""
    Local _aOrd
    Local _cXML
    Local _cResult := ""
    Local _cResposta, _cSituacao
    Local _nRegSC5
    Local _cSitPed := ""
    //Local _lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC.

    Default _lMarcaEnv:=.T.
    Default _item := {"  ", SC5->C5_FILIAL,SC5->C5_NUM} //Se n�o mandar par�metro analisa pedido posicionado

    Begin Sequence

        If Select("ZFM") == 0 // Se a tabela ZFM n�o estiver aberta, abre a tabela ZFM.
            ChkFile("ZFM")
        EndIf

        If Select("SC5") == 0 // Se a tabela SC5 n�o estiver aberta, abre a tabela SC5.
            ChkFile("SC5")
        EndIf

        _nRegSC5 := SC5->(Recno())

        _aOrd := SaveOrd({"ZFM","SC5"}) // Salva no Array _aOrd a ordem dos �ndices das tabelas posicionadas e a posi��o atual do ponterio de registro.

        SC5->(Dbsetorder(1))
        If !(SC5->(Dbseek(_item[2]+_item[3]))) //Se n�o achar o pedido de vendas sai da rotina de imediato
            Break
        Endif

        _cSitPed := U_STPEDIDO()

        If SC5->C5_I_ENVRD = "S"
           //========================================================================
           // Se a filial atual estiver habilitada a utilizar o TMS MultiEmbarcador,
           // Chama a rotina nova de Envio de Situa��o do Pedido de Vendas.
           //========================================================================
           If U_IT_TMS(SC5->C5_I_LOCEM)//_lWsTms 
              U_AOMS140O() // Nova Rotina de Envio da Situa��o do Pedido de Vendas para o TMS MultiEmbarcador.    
              Break 
           EndIf 

           //========================================================================
           // Chama a rotina antiga, do RDC, de envio da Situa��o do Pedido de Vendas
           //========================================================================
              IF _lMarcaEnv
                U_GRVCAPAC(SC5->C5_FILIAL,NIL,SC5->C5_NUM,"[ ENVSITPV - MARCAENV - "+ALLTRIM(FUNNAME())+" ] [ Sit.: "+_cSitPed+" ]")
                Break
            ENDIF

            //================================================================================
            // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
            //================================================================================
            ZFM->(DbSetOrder(1))
            If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
                _cDirXML := ZFM->ZFM_LOCXML
                _cLink   := AllTrim(ZFM->ZFM_LINK01)
            Else
                Break
            EndIf

            If Empty(_cDirXML) .Or. Empty(_cLink)
                Break
            EndIf

            _cDirXML := Alltrim(_cDirXML)
            If Right(_cDirXML,1) <> "\"
                _cDirXML := _cDirXML + "\"
            EndIf

            //================================================================================
            // L� os arquivos modelo XML e os transforma em String.
            //================================================================================
            _cCabXML := LEXMLS(_cDirXML+"Cab_BloqPedido.txt")
            If Empty(_cCabXML)
                Break
            EndIf

            oWsdl := tWSDLManager():New() // Cria o objeto da WSDL.
            oWsdl:nTimeout := 30          // Timeout de 10 segundos
            oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo

            oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.
            oWsdl:SetOperation("AlteraSituacaoPedido") // Define qual opera��o ser� realizada.

            Begin Transaction
                //-----------------------------------------------------------------------------------------
                // Realiza a integra��o dos bloqueios e pedidos de vendas (Envio de XML) via WebService.
                //-----------------------------------------------------------------------------------------

                SC5->(Dbseek(_item[2]+_item[3])) //Posiciona pedido para montar xml

                _cDetXML := LEXMLS(_cDirXML+"DET_BloqPedido.txt")

                _cRodXML := LEXMLS(_cDirXML+"Rodape_BloqPedido.txt")

                //Monta XML
                _cXML := _cCabXML + &(_cDetXML) + _cRodXML  // Monta o XML de envio.

                // Limpa & da string
                _cXML := strtran(_cXML,"&"," ")

                // Envia para o servidor

                _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.

                If _cOk
                    _cResult := oWsdl:GetParsedResponse() // Pega o resultado de envio j� no formato em string.
                Else
                    _cResult := oWsdl:cError
                EndIf

                _cResposta := AllTrim(StrTran(_cResult,Chr(10)," "))
                _cResposta := Upper(_cResposta)

                oWsdl:GetSoapResponse() //finaliza soap

                // "Importado Com Sucesso"
                _cSituacao := "P"

                If ! _cOk
                    _cSituacao := "N"
                ElseIf !("IMPORTADO COM SUCESSO" $ _cResposta)
                    _cSituacao := "N"
                EndIf

                // grava resultado // sempre como processado
                ZGA->(RecLock("ZGA",.T.))
                ZGA->ZGA_DTENT   := SC5->C5_I_DTENT
                ZGA->ZGA_SITUAC  := _cSituacao
                ZGA->ZGA_NUM     := SC5->C5_NUM
                ZGA->ZGA_USUARI  := __CUSERID
                ZGA->ZGA_DATAAL  := Date()
                ZGA->ZGA_HORASA  := TIME()
                ZGA->ZGA_STATUS  := _cSitPed
                ZGA->ZGA_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela dizendo que deu certo ou n�o.
                ZGA->ZGA_XML     := _cXML
                ZGA->(MsUnlock())

            End Transaction

            IF "AN EXCEPTION  OCCURRED AT 1:0 WSDLPARSER EXCEPTION" $ UPPER(ZGA->ZGA_RETORN) .OR.;
                    "AN EXCEPTION  OCCURRED AT 0:0 WSDLPARSER EXCEPTION" $ UPPER(ZGA->ZGA_RETORN)
                U_GRVCAPAC(SC5->C5_FILIAL,NIL,SC5->C5_NUM,"[ ENVSITPV - ERRO - "+ALLTRIM(FUNNAME())+" ]")
            ENDIF


            IF TYPE("oWsdl") = "O"
                oWsdl:=Nil
                //Limpa o Objeto: Conforme orientado pelo Framework
                DelClassIntf()//Exclui todas classes de interface da thread.
            ENDIF

        ENDIF

        SC5->(RecLock("SC5",.F.))
        SC5->C5_I_STATU := U_STPEDIDO() //Fun��o de an�lise do pedido de vendas no xfunoms
        SC5->(MsUnlock())

    End Sequence
 
    RestOrd(_aOrd)

    SC5->(DbGoTo(_nRegSC5))

Return .T.

/*
===============================================================================================================================
Fun��o-------------: LEXMLS
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: L� o arquivo XML modelo no diret�rio informado e retorna os dados no formato de String.
===============================================================================================================================
Parametros--------: _cArq - arquivo xml de formato
===============================================================================================================================
Retorno-----------: _cret - conte�do do arquivo
===============================================================================================================================
*/  
Static Function LEXMLS(_cArq)
    Local _cRet := ""
    Local _nStatusArq
    Local _cLine

    Begin Sequence
        _nStatusArq := FT_FUse(_cArq)

        // Se houver erro de abertura abandona processamento
        If _nStatusArq = -1
            Break
        Endif

        // Posiciona na primeria linha
        FT_FGoTop()


        While !FT_FEOF()
            _cLine  := FT_FReadLn()

            _cRet +=  _cLine

            FT_FSKIP()
        End

        // Fecha o Arquivo
        FT_FUSE()

    End Sequence

Return _cRet

/*
===============================================================================================================================
Fun��o-------------: VEREST
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Verifica se pedido tem SC9 com bloqueio de estoque
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lret - Falso se tiver bloqueio de estoque
===============================================================================================================================
*/  
User Function verest()

    Local _lret := .T.
    Local _aSC9   := GetArea("SC9")
    Local _aSC6   := GetArea("SC6")


    SC6->(Dbsetorder(1))
    SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

    Do while SC5->C5_FILIAL+SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM

        SC9->(Dbsetorder(1))

        If SC9->(Dbseek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))

            If SC9->C9_BLEST == '02'

                _lret := .F.

            Endif

        Else  //Se n�o achar sc9 � falha de libera��o de estoque

            _lret := .F.

        Endif

        SC6->(Dbskip())

    Enddo

    Restarea(_aSC9)
    Restarea(_aSC6)

Return _lret


/*
===============================================================================================================================
Programa--------: GrvMonitor()
Autor-----------: Alex Wallauer
Data da Criacao-: 28/04/2017
===============================================================================================================================
Descri��o-------: Grava o ZY3 para o Monitor pedido de vendas
===============================================================================================================================
Parametros------: _cFilial - filial do PV 
                  _cNum    - numero do PV
                  _cJUSCOD - codigo da justificativa
                  _cCOMENT - comentario
                  _cLENCMON- 'S' encerra o monitoramento 'I' inicia
                  _dDTNECE - data da necessidade de faturamento
                  _dDTFAT  - data de entrega 
                  _dDTFOLD - data de entrega ante de alterar
                  _cObserv    - Observa��o estoque.
                  _cVinculoTb - C�digo de Vinculo entre as Tabelas ZY3 e ZY8
                  _dDtSugAgen - Data sugerida de agendamento.
==============================================================================================================================
Retorno---------: L�gico (.T.) Se tudo OK 
===============================================================================================================================
OBSERVA��O------: N�O INICIAR ACOLS E AHEADER NESSA FUN�AO PQ TEM LUGRARES QUE ELES J� EXISTEM e n�o s�o o que precisamos 
===============================================================================================================================
*/

USER Function GrvMonitor(_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE,_dDTFAT,_dDTFOLD, _cObserv, _cVinculoTb, _dDtSugAgen,_lRestArea)

    LOCAL _cSequen  := "0000"
    LOCAL _aAreaSC5 := SC5->(GetArea())
    LOCAL _aAreaZY3 := ZY3->(GetArea())
    LOCAL _cENCMON  := "I"
    DEFAULT _cFilial:= SC5->C5_FILIAL
    DEFAULT _cNum   := SC5->C5_NUM
    DEFAULT _dDtPrevEst := Ctod("  /  /  ")
    DEFAULT _cObserv    := ""
    DEFAULT _cVinculoTb := ""
    DEFAULT _dDtSugAgen := Ctod("  /  /  ")
    DEFAULT _lRestArea  := .T.

    ZY3->(Dbsetorder(2))
    If ZY3->(Dbseek(_cnum))

        Do while ZY3->( !EOF() ) .AND. ZY3->ZY3_NUMPV == _cnum

            IF !EMPTY(_cLENCMON)//Se n�o for branco tem que gravar em todas as linhas sen�o segue a logica de grava a linha nova com o ultimo conteudo
                ZY3->(RecLock("ZY3",.F.))
                ZY3->ZY3_ENCMON := _cLENCMON
                ZY3->(MsUnLock())
            ENDIF
            IF ZY3->ZY3_SEQUEN > _cSequen
                _cSequen := ZY3->ZY3_SEQUEN
                _cENCMON := ZY3->ZY3_ENCMON
            ENDIF
            ZY3->(Dbskip())

        Enddo

    ELSEIF !EMPTY(_cLENCMON)

        _cENCMON := _cLENCMON

    Endif

//Valida se existe campo de c�digo de usu�rio para n�o dar errolog em schedule e webservice
    If type("__cUserID") == "U"
        _cUsertmp:= "000000"
        _cNome   := "WEBSERVICE"
    Else
        _cUsertmp:= __cUserID
        _cNome   := AllTrim(UsrFullName(__cUserID))
    Endif

    ZY3->(RECLOCK("ZY3",.T.))
    ZY3->ZY3_NUMPV  := _cNum
    ZY3->ZY3_FILFT  := _cFilial
    ZY3->ZY3_SEQUEN := SOMA1(_cSequen)
    ZY3->ZY3_DTMONI := DATE()
    ZY3->ZY3_HRMONI := TIME()
    ZY3->ZY3_CODUSR := _cUsertmp
    ZY3->ZY3_NOMUSR := _cNome
    ZY3->ZY3_ORIGEM := FUNNAME()
//Parametros
    ZY3->ZY3_DTNECE := _dDTNECE//SC5->C5_I_DTENT - (U_OMSVLDENT(SC5->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,_cFilial,_cNum,1))
    ZY3->ZY3_DTFOLD := _dDTFOLD
    ZY3->ZY3_DTFAT  := _dDTFAT //SC5->C5_I_DTENT
    ZY3->ZY3_JUSCOD := _cJUSCOD
    ZY3->ZY3_COMENT := _cCOMENT
    ZY3->ZY3_ENCMON := _cENCMON
//---------------------------
    ZY3->ZY3_OBSERV := _cObserv
    ZY3->ZY3_VNCZY8 := _cVinculoTb
    ZY3->ZY3_DTSUAG := _dDtSugAgen
//---------------------------
//Parametros
    ZY3->(MsUnLock())
    IF _lRestArea
       RestArea(_aAreaSC5)
       RestArea(_aAreaZY3)
    ENDIF

RETURN .T.

/*
===============================================================================================================================
Fun��o------------: GRVCAPAC
Autor-------------: Alex Wallauer
Data da Criacao---: 06/06/2017
===============================================================================================================================
Descri��o---------: Fun��o para gravar o ZFU. Grava os dados de capa da carga.
===============================================================================================================================
Parametros--------: _cFilial,_cCodEmpWS : Variaveis iniciadas Locais
===============================================================================================================================
Retorno-----------: Recno do ZFU
===============================================================================================================================
*/
USER Function GRVCAPAC(_cFilial,_cCodEmpWS,_cPV,_cOrigem)//Chamada do XFUNOMS.PRW tb
    LOCAL _nRec:=0
    DEFAULT _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
    DEFAULT _cOrigem:="[U_INCLUIC]"

    // Grava log de comuinica��o
    Begin Transaction

        IF _cPV = NIL
            ZFU->(RecLock("ZFU",.T.))
            ZFU->ZFU_FILIAL  := _cFilial          // Filial do Sistema
            ZFU->ZFU_CODEMP  := _cCodEmpWS	     // Codigo Empresa WebServer
            ZFU->ZFU_DATA    := Date()            // Data de Emiss�o
            ZFU->ZFU_HORA    := Time()            // Hora de inclus�o na tabela de muro
            ZFU->ZFU_USUARI  := __CUSERID         // Codigo do Usu�rio
            ZFU->ZFU_DATAAL  := Date()            // Data de Altera��o
            ZFU->ZFU_SITUAC  := "P"               // Situa��o do Registro
            ZFU->ZFU_ENSTUS  := "S"               // Marcou para enviar Status
            ZFU->ZFU_CNPJEM  := U_CARGA:CNPJEM    // CNPJ do Embarcador
            ZFU->ZFU_CODIGO  := U_CARGA:CODIGO    // Codigo da Carga no RDC
            ZFU->ZFU_I_FRDC  := U_CARGA:CODFIL    // Codigo da Filial RDC
            ZFU->ZFU_PLACAC  := U_CARGA:PLACA1    // Placa do caminh�o
            ZFU->ZFU_PLACA2  := U_CARGA:PLACA2    // Placa do Veiculo 2
            ZFU->ZFU_PLACA3  := U_CARGA:PLACA3    // Placa do Veiculo 3
            ZFU->ZFU_PLACA4  := U_CARGA:PLACA4    // Placa do Veiculo 4
            ZFU->ZFU_CPFMOT  := U_CARGA:CPFM	     // CPF do motorista
            ZFU->ZFU_PESOBR  := U_CARGA:PESOB     // Peso bruto
            ZFU->ZFU_PESOLQ  := U_CARGA:PESOL     // Peso liquido
            ZFU->ZFU_VALCAR  := U_CARGA:VALOR     // Valor
            ZFU->ZFU_DTEMIS  := CTod(U_CARGA:DATAE)// Data de emiss�o da Carga
            ZFU->ZFU_DTCARR  := CTod(U_CARGA:DATAC)// Data de carregamento
            ZFU->ZFU_CNPJTR  := U_CARGA:CNPJTRA	  // CNPJ da Transportadora
            ZFU->ZFU_TIPO    := U_CARGA:TIPO	      // Tipo do veiculo
            ZFU->ZFU_FRETE   := U_CARGA:FRETE              // Valor do Frete
            ZFU->ZFU_VLRPDG  := U_CARGA:PEDAGIO            // Valor do Pedagio
            ZFU->ZFU_RDCUSR  := AllTrim(Str(U_CARGA:USUCAD,6)) // Codigo do Usu�rio da Altera��o
            ZFU->ZFU_OBS1    := U_CARGA:OBSERV1            // Observa��o 1
            ZFU->ZFU_OBS2    := U_CARGA:OBSERV2            // Observa��o 2
            ZFU->ZFU_PRECAR  := U_CARGA:PRECARGA           // Precarga? S/N
            ZFU->ZFU_REGCAP  := StrZero(ZFU->(Recno()),10) // Numero Registro Tab.Capa
            ZFU->ZFU_RETORN  := "Iniciou Grava��o da Carga do RDC "+_cOrigem// Retorno Integracao Italac-RDC
            ZFU->ZFU_CODIGO  := U_CARGA:CODIGO             // Codigo da Carga no RDC
            ZFU->ZFU_RECRDC  := AllTrim(Str(U_CARGA:RECNUM,10)) // Grava o Recno RDC na Tabela de muro.
            If DAK->(DbSeek(_cFilial+ALLTRIM(U_CARGA:CODIGO))) // DbSeek(_cFilial+U_CARGA:CODIGO)
                ZFU->ZFU_NCARGA:=DAK->DAK_COD
            ENDIF
            ZFU->(MsUnLock())
            _nRec := ZFU->(Recno())
        ELSE
            ZGY->(RecLock("ZGY",.T.))
            ZGY->ZGY_FILIAL  := _cFilial          // Filial do Sistema
            ZGY->ZGY_CODEMP  := _cCodEmpWS	     // Codigo Empresa WebServer
            ZGY->ZGY_DATA    := Date()            // Data de Emiss�o
            ZGY->ZGY_HORA    := Time()            // Hora de inclus�o na tabela de muro
            ZGY->ZGY_USUARI  := __CUSERID         // Codigo do Usu�rio
            ZGY->ZGY_DATAAL  := Date()            // Data de Altera��o
            ZGY->ZGY_SITUAC  := "P"               // Situa��o do Registro
            ZGY->ZGY_ENSTUS  := "S"               // Marcou para enviar Status
            ZGY->ZGY_CODIGO  := _cPV
            ZGY->ZGY_NCARGA  := _cPV
            ZGY->ZGY_RETORN  := "ENVIO DO STATUS DO PEDIDO DO RDC "+_cOrigem
            ZGY->(MsUnLock())
            _nRec:=ZGY->(Recno())
        ENDIF

    End Transaction

RETURN _nRec


/*
===============================================================================================================================
Programa--------: IT_Oper_Triangular()
Autor-----------: Alex Wallauer
Data da Criacao-: 21/08/2017
===============================================================================================================================
Descri��o-------: Gera��o do Pedido de Remessa em cima do Pedido de Venda e altera��o de compartibilidade dos 2
==============================================================================================================================
Parametros------: _cPedido: Numero do Pedido da filial atual  
                  _lExclui: Replica a exclus�o
===============================================================================================================================
Retorno---------: .T. ou .F.
===============================================================================================================================*/
USER function IT_OperTriangular(_cPedido,_lExclui,_lComTela)//U_IT_OperTriangular()

Local _aArea:=GetArea()
Local _aAreaSC5:=SC5->( Getarea() )
Local _aAreaSC6:=SC6->( Getarea() )
Local _nRecOrigem:=0
Local _lGerouOK:=.T.
DEFAULT _lComTela:=FWIsInCallStack("MDIEXECUTE") .OR. FWIsInCallStack("SIGAADV")

IF EMPTY(M->C5_I_OPTRI) .OR. EMPTY(_cPedido)//Se esse campo C5_I_OPTRI em branco PV normal
   RestArea(_aAreaSC5)
   RETURN .T.
ENDIF

SC5->(DBSETORDER(1))
IF _cPedido # SC5->C5_NUM
   IF !SC5->(DBSEEK(xFilial()+_cPedido))
      //If _lComTela 
         U_MT_ITMSG("Pedido n�o encontrado: "+_cPedido,"Aten��o!","Entrar em contato com a area de TI e dar print dessa mensagem.",1) 
      //EndIf
      RestArea(_aAreaSC5)
      RETURN .F.
   ENDIF
ENDIF

PRIVATE _aLog:={}
_nRecOrigem  := SC5->(RECNO())

//INCLUSAO  ******************************************************************************
//If M->C5_I_OPTRI = "F" .AND. (EMPTY(M->C5_I_PVREM) .OR. !SC5->(DBSEEK(xFilial()+M->C5_I_PVREM))) //Gera o PV de Remessa
If M->C5_I_OPTRI = "R" .AND. !_lExclui .AND. (EMPTY(M->C5_I_PVFAT) .OR. !SC5->(DBSEEK(xFilial()+M->C5_I_PVFAT))) //Gera o PV de Faturamento

   SC5->(DBGOTO(_nRecOrigem))//Volta o POSICIONAMENTO do pedido de origem
   //BEGIN Transaction

         IF !_lComTela
            _lGerouOK := ManutPed("GERA",.F.,@_lComTela)
         ELSE
            //Processa( {|| _lGerouOK := ManutPed("GERA",.F.) } ,, "Gerando Pedido de Remessa..." )
            Processa( {|| _lGerouOK := ManutPed("GERA",.F.,_lComTela) } ,, "Gerando Pedido de Faturamento..." )
         ENDIF

         IF !_lGerouOK
            lRet:=.F. 
            //DisarmTransaction()
            //_cProblema:="Ocorreram problemas na Gera��o de Pedidos de Remessa, para maiores detalhes veja a Coluna Movimenta��o."
            //_cSolucao :="Para fechar a tela de Log clique no Bot�o FECHAR para voltar a tela do Pedido."
            _cProblema:="Ocorreram problemas na Gera��o de Pedidos de Faturamento, para maiores detalhes veja a Coluna Movimenta��o."
            _cSolucao :="Para fechar a tela de Log clique no Bot�o FECHAR para voltar a tela do Pedido."
         ENDIF

   //END Transaction

   IF _lGerouOK 
        If SuperGetMV("IT_AMBTEST",.F.,.T.)
              //U_ITMSG("Pedido de Remessa Gerado :"+M->C5_I_PVREM,"Aten��o!",,2)
            U_MT_ITMSG("Pedido de Faturamento Gerado :"+M->C5_I_PVFAT,"Aten��o!",,2)
        ENDIF
   
   //ELSE

      //DisarmTransaction()//Volta as altera��es do pedido original
   
   ENDIF     

//ALTERACAO / EXCLUSAO *****************************************************************************************************************************
ELSEIf SC5->(DBSEEK(xFilial()+M->C5_I_PVFAT)) .AND.;
       (SC5->C5_I_OPTRI = "R" .AND. !EMPTY( SC5->C5_I_PVFAT ) .OR.; //Replica as altera��es do PV de Remessa no PV de Faturamento
        SC5->C5_I_OPTRI = "F" .AND. !EMPTY( SC5->C5_I_PVREM ))      //Replica as altera��es do PV de Faturamento no PV de Remessa no 
   SC5->(DBGOTO(_nRecOrigem))//Volta o POSICIONAMENTO do pedido de origem
   //BEGIN Transaction

         IF !_lComTela
            _lGerouOK := ManutPed("REPLICA",_lExclui,@_lComTela)
         ELSE
            Processa( {|| _lGerouOK := ManutPed("REPLICA",_lExclui,_lComTela) } ,, IF(_lExclui,"Excluindo","Alterando")+" Pedido Triangular..." )
         ENDIF

         IF !_lGerouOK
            lRet:=.F. 
            //DisarmTransaction()
            _cProblema:="Ocorreram problemas na Exclus�o do Pedido de Faturamento da Opera��o Triangular, para maiores detalhes veja a Coluna Movimenta��o."
            _cSolucao :="Para fechar a tela de Log clique no Bot�o FECHAR."
         ENDIF

   //END Transaction

   //IF !_lGerouOK

      //DisarmTransaction()//Volta as altera��es do pedido original
   
   //ENDIF     

Endif

If Len(_aLog) > 0 .AND. (!_lGerouOK .OR. _lComTela)

   _bOK:={|| u_itmsg(_cProblema,"Aten��o!",_cSolucao,1) , .F. }

   _bCancel := NIL
   
   _cMsgTop:="Para maiores detalhes clique em 'OUTRAS A��ES' e escolha 'EXPORTA��O PARA EXCEL' de sua preferencia e veja a coluna movimenta��o por completa na planilha gerada'."

   U_ITListBox( 'Log de Geracao de Pedidos de Opera��o Triangular (XFUNOMS - Linha '+ strzero(procline(1),6)+")" ,;
                {" ",'Pedido Fat.','Pedido Remessa','Movimenta��o','Cliente','Operacao'} , _aLog , .T. , 4,_cMsgTop,,;
                { 10,           50,             50,           150,      150,        35,},, _bOK,_bCancel)

ENDIF     

RestArea(_aArea)
RestArea(_aAreaSC5)
RestArea(_aAreaSC6)

RETURN !_lGerouOK

/*
===============================================================================================================================
Programa--------: ManutPed()
Autor-----------: Alex Wallauer
Data da Criacao-: 22/08/2017
===============================================================================================================================
Descri��o-------: Gera��o do PV de Remessa em cima do PV de Venda e altera��o de compartibilidade das duas
===============================================================================================================================
Parametros------: _cAcao: "GERA" Gera pedido de Remessa "REPLICA" Replica a a��o de um PV 
                  _lExclui: Replica a exclus�o
                  _lComTela: Se vai mostrar a tela de log
===============================================================================================================================
Retorno---------: .T. ou .F.
===============================================================================================================================*/
STATIC function ManutPed(_cAcao AS CHAR, _lExclui AS LOGICAL, _lComTela AS LOGICAL) As Logical

 LOCAL _cCliente AS CHAR, _cLoja AS CHAR, I AS NUMERIC
 LOCAL _cPedOrigem AS CHAR
 LOCAL _cTpOper AS CHAR, _aItensPV AS ARRAY
 LOCAL _lDeuErro        := .F. AS LOGICAL
 LOCAL _cOperTriangular := ALLTRIM(U_ITGETMV("IT_OPERTRI", "05,42")) AS CHAR // Tipos de opera��es da opera��o trigular
 LOCAL _cOperFat        := LEFT(_cOperTriangular, 2) AS CHAR 
 LOCAL _cOperRemessa    := RIGHT(_cOperTriangular, 2) AS CHAR 
 LOCAL _nRecOrigem      := SC5->(RECNO()) AS NUMERIC 
 LOCAL _cMostraErro     := "" AS CHAR
 LOCAL _cMensagem       := "" AS CHAR
 
 SC5->( DbSetOrder(1) )
 SC6->( DbSetOrder(1) )
 
 IF _cAcao = "GERA" //INCLUI
    
    _cPedOrigem  := M->C5_NUM
    M->C5_CLIENTE:= M->C5_CLIENT :=M->C5_I_CLIEN//Cliente do PV Adquirente no 42 e Principal no 05
    M->C5_LOJACLI:= M->C5_LOJAENT:=M->C5_I_LOJEN//Cliente do PV Adquirente no 42 e Principal no 05
    
    If !FWIsInCallStack("U_AOMS032") 
       //M->C5_VEND1  := U_AOMS006()//Gatilho do M->C5_CLIENTE Carrega esses campos: M->C5_VEND2,M->C5_VEND3
    Else
       M->C5_VEND1   := _cCodVend1  
       M->C5_VEND2   := _cCodVend2 
       M->C5_VEND3   := _cCodVend3  
       M->C5_VEND4   := _cCodVend4  
       M->C5_VEND5   := _cCodVend5  
       M->C5_I_V1NOM := _cNomVend1  
       M->C5_I_V2NOM := _cNomVend2  
       M->C5_I_V3NOM := _cNomVend3  
    EndIf 
    
    M->C5_I_EST  := U_AOMS017()//Gatilho do M->C5_CLIENT Carrega esses campos: M->C5_I_NOME,M->C5_I_FANTA,M->C5_I_CMUN,M->C5_I_MUN,M->C5_I_CEP,M->C5_I_END,M->C5_I_BAIRR,M->C5_I_DDD,M->C5_I_TEL,M->C5_I_GRPVE,M->C5_I_NOMRD,M->C5_I_V1NOM,M->C5_I_V2NOM,,M->C5_I_V3NOM,M->C5_I_HORP,M->C5_I_AGEND,M->C5_I_TIPCA,M->C5_I_CHPCL

    //====================================================================================================
    // Monta o cabe�alho do pedido NOVO
    //====================================================================================================
    _aCabPV  :={}//PRIVATE
    Aadd( _aCabPV, { "C5_FILIAL"	,xFilial("SC5"), Nil})//Filial
    Aadd( _aCabPV, { "C5_TIPO"	    ,M->C5_TIPO    , Nil})//Tipo de pedido
    Aadd( _aCabPV, { "C5_I_OPER"	,_cOperFat     , Nil})//Tipo da operacao
    //Aadd( _aCabPV, { "C5_I_OPER"	,_cOperRemessa , Nil})//Tipo da operacao
    Aadd( _aCabPV, { "C5_CLIENTE"	,M->C5_CLIENTE , NiL})//Codigo do cliente
    Aadd( _aCabPV, { "C5_LOJACLI"	,M->C5_LOJACLI , NiL})//Loja do cliente
    Aadd( _aCabPV, { "C5_CLIENT"    ,M->C5_CLIENTE , Nil})//Codigo do cliente entrega
    Aadd( _aCabPV, { "C5_LOJAENT"	,M->C5_LOJACLI , NiL})//Loja para entrada
    Aadd( _aCabPV, { "C5_I_AGEND"   ,M->C5_I_AGEND , Nil})//Tipo de Entrega
    Aadd( _aCabPV, { "C5_VEND1"     ,M->C5_VEND1   , Nil})//Vendedor
    Aadd( _aCabPV, { "C5_I_EST"     ,M->C5_I_EST   , Nil})//Estado

    Aadd( _aCabPV, { "C5_I_HOREN"   ,M->C5_I_HOREN, Nil})   
    Aadd( _aCabPV, { "C5_I_CDUSU"   ,M->C5_I_CDUSU, Nil})   

    Aadd( _aCabPV, { "C5_I_TIPCA"   ,M->C5_I_TIPCA   , Nil})//Tipo de Carga
    Aadd( _aCabPV, { "C5_I_AGEND"   ,M->C5_I_AGEND   , Nil})//Tipo de Agendamento
    Aadd( _aCabPV, { "C5_I_CHAPA"   ,M->C5_I_CHAPA   , Nil})//Qtd de Chapa
    Aadd( _aCabPV, { "C5_I_CUSDE"   ,M->C5_I_CUSDE   , Nil})//Custo Descarga
    Aadd( _aCabPV, { "C5_I_HORDE"   ,M->C5_I_HORDE   , Nil})//Hora Descarga
    Aadd( _aCabPV, { "C5_I_TPVEN"   ,M->C5_I_TPVEN   , Nil})//Tipo de Venda
    Aadd( _aCabPV, { "C5_I_TAB"     ,M->C5_I_TAB     , Nil})//Tabela de Pre�o
    Aadd( _aCabPV, { "C5_TPFRETE"   ,M->C5_TPFRETE   , Nil})//Tp Frete
    Aadd( _aCabPV, { "C5_DESCONT"   ,M->C5_DESCONT   , Nil})//Desconto	
        
    
    //If FWIsInCallStack("U_AOMS032") 
       Aadd( _aCabPV, { "C5_VEND2"     ,M->C5_VEND2     , Nil})// Codigo Coordenador 
       Aadd( _aCabPV, { "C5_VEND3"     ,M->C5_VEND3     , Nil})// Codigo Gerente
       Aadd( _aCabPV, { "C5_VEND4"     ,M->C5_VEND4     , Nil})// Codigo Supervisor
       Aadd( _aCabPV, { "C5_VEND5"     ,M->C5_VEND5     , Nil})// Codigo Gerente Nacional
       Aadd( _aCabPV, { "C5_I_V1NOM"   ,M->C5_I_V1NOM   , Nil})// Nome Representante
       Aadd( _aCabPV, { "C5_I_V2NOM"   ,M->C5_I_V2NOM   , Nil})// Nome Coordenador
       Aadd( _aCabPV, { "C5_I_V3NOM"   ,M->C5_I_V3NOM   , Nil})// Nome Gerente
       //Aadd( _aCabPV, { "C5_I_V4NOM"   ,M->C5_I_V4NOM   , Nil})// Nome supervisor
       //Aadd( _aCabPV, { "C5_I_V5NOM"   ,M->C5_I_V5NOM   , Nil})// Nome Gerente Nacional
    //EndIf

    DadosPed("SC5")
    
    //====================================================================================================
    // Monta o item do pedido NOVO
    //====================================================================================================
    _aItemPV :={}//PRIVATE
    _aItensPV:={}//LOCAL

    SC6->( DbSetOrder(1) )
    SC6->( DBSeek( SC5->C5_FILIAL + _cPedOrigem ) )
    DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + _cPedOrigem
        
       //IF _lComTela
       //   IncProc("Lendo Item: "+SC6->C6_ITEM)
       //ENDIF

       _aItemPV:={}		

        AAdd( _aItemPV,{ "C6_FILIAL" ,SC6->C6_FILIAL  , Nil }) // FILIAL

        DadosPed("SC6","SC6")

        AAdd( _aItensPV ,_aItemPV )

        SC6->( DBSkip() )
        
    ENDDO
    //====================================================================================================
    // Gera��o do pedido NOVO
    //====================================================================================================	
    lMsErroAuto:=.F.
      _cAOMS074 := "ManutPed()/XFUNOMS" // Vari�vel de controle para indicar a origem da chamada de fun��es.
    _cAOMS074Vld := ""

      //FWMSGRUN( , {||  MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 3 ) }, "AGUARDE...", "GERANDO O PEDIDO DE REMESSA PARA O PEDIDO DO VENDA... ") 
    FWMSGRUN( , {||  MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 3 ) }, "AGUARDE...", "GERANDO O PEDIDO DE FATURAMENTO PARA O PEDIDO DO VENDA... ") 
    
    If lMsErroAuto .OR. SC5->(EOF())
        
       If ( __lSx8 ) 
          RollBackSx8()
       EndIf 
       _cMensagem:=""
       IF !EMPTY(_cAOMS074Vld)
          _cMensagem:="Valida��o Italac (_cAOMS074Vld): "+ALLTRIM(_cAOMS074Vld)+CRLF
       ENDIF
       _cMostraErro:=""
       IF _lComTela
          _cMostraErro:=" ["+ALLTRIM(MostraErro())+"] "
       ELSE
          _cMostraErro:=" ["+ALLTRIM(MostraErro("/data/italac/controle/","manutped_mostraerro_"+ALLTRIM(_cPedOrigem)+".log"))+"] "
       ENDIF
       IF !EMPTY(_cMostraErro)
          _cMostraErro:=StrTran(_cMostraErro,CRLF," ",1,1)
          _cMensagem+="Valida��o Padr�o (MostraErro()): "
          _cMensagem+=_cMostraErro
       endif

       _cMensagem+=IF(SC5->(EOF()),"[SC5 em EOF()]","")
       _cMensagem:='Erro ao criar o Pedido de Faturamento: '+_cMensagem
        _cCliente:=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
       //dd( _aLog    , {" ",'Pedido Venda','Pedido Remessa','Movimenta��o','Cliente','Operacao'    } )
       aAdd( _aLog    , {.F.,M->C5_NUM     ,""              ,_cMensagem    ,_cCliente,M->C5_I_OPER} )
        
       _lDeuErro:=.T.//Se der algum Erro

    Else

       _lDeuErro:=.F.//Se der algum Erro

        //====================================================================================================
        // Grava campos de controle no pedido de Faturamento
        SC5->( RecLock( 'SC5' , .F. ) )
        SC5->C5_I_PVREM:= _cPedOrigem// Pedido de Venda Original
        SC5->C5_I_OPTRI:= "F"        // Marca o PV de Faturamento
        //SC5->C5_I_PVREM:= _cPedOrigem// Pedido de Venda Original
        //SC5->C5_I_OPTRI:= "R"        // Marca o PV de Remessa
           SC5->( MsUnlock() )
        //====================================================================================================
        _cMemAux:=""
        IF SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
            DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

                IF !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
                    _nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO
                ELSE
                    _nQtdLib := SC9->C9_QTDLIB
                ENDIF

                IF _nQtdLib # SC6->C6_QTDVEN
                   _lComTela:=.T.
                   _cMemAux:=", mas N�o liberou o Pedido, Item: [ "+SC6->C6_FILIAL+" "+SC6->C6_NUM+" "+SC6->C6_ITEM+"] "
                    EXIT
                ENDIF

                SC6->( DBSkip() )

            ENDDO
        ENDIF

        //====================================================================================================
        // Grava o LOG de Inclus�o do Pedidos de Remessa Novo
        _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
        _cMensagem:='Gerou o Pedido de Remessa'+_cMemAux
        //_cMensagem:='Gerou o Pedido de Faturamento'
        //dd( _aLog , {" ",'Pedido Venda'      ,'Pedido Remessa','Movimenta��o','Cliente','Operacao'    } )
        //dd( _aLog , {" ",'Pedido Venda'      ,'Pedido Faturamento','Movimenta��o','Cliente','Operacao'    } )
        aAdd( _aLog , {.T.,_cPedOrigem         ,SC5->C5_NUM         ,_cMensagem    ,_cCliente,SC5->C5_I_OPER} )
        //====================================================================================================

        //====================================================================================================
        // Grava campos de controle no pedido de Remessa
        IF SC5->(DBSEEK(xFilial()+_cPedOrigem))
           SC5->( RecLock( 'SC5' , .F. ) )
           SC5->C5_I_PVFAT:=M->C5_I_PVFAT:= _aLog[1,3]// Pedido de Remessa
           SC5->C5_I_OPTRI:=M->C5_I_OPTRI:= "R"       // Marca o PV  Remessa
           //SC5->C5_I_PVREM:=M->C5_I_PVREM:= _aLog[1,3]// Pedido de Remessa 
           //SC5->C5_I_OPTRI:=M->C5_I_OPTRI:= "R"       // Marca o PV Remessa
              SC5->( MsUnlock() )
           ENDIF
        //====================================================================================================

    ENDIF
 //**********************************************************************************************************************************************************	
 ELSEIF _cAcao = "REPLICA"//ALTERA E EXCLUI

    //IF _lComTela
    //   IncProc("Alterando Pedido Triangular...")
    //ENDIF

    lMsErroAuto:=.F.
    _cPedOrigem:=SC5->C5_NUM
    _cCliente  :=""
    _cLoja     :=""

    IF SC5->C5_I_OPTRI = "F" // Estou no PV de Venda/Faturamento e vou alterar o de Remessa
       _cPedAltera:=SC5->C5_I_PVREM
       _cTpOper   :=_cOperRemessa
       //Vou alterar o campo de cliente princiapal do pedido de remessa
       _cCliente  :=SC5->C5_I_CLIEN//Cliente do PV de Remessa principal
       _cLoja     :=SC5->C5_I_LOJEN//Cliente do PV de Remessa principal
       _cClient   :=""
       _cLojaEnt  :=""
       IF SC5->(DBSEEK(xFilial()+_cPedAltera))//Quando chega nesse ponto o pedido de Origem j� foi gravado
          IF (_cCliente+_cLoja == SC5->C5_CLIENTE+SC5->C5_LOJACLI)//Se n�o mudou o cliente de remessa puxar os dados dos campos do gatilho
             M->C5_VEND1  :=SC5->C5_VEND1
          ELSE
             M->C5_VEND1  :=""
          ENDIF
       ENDIF
    ELSEIF SC5->C5_I_OPTRI = "R" // Estou de PV de Remessa e vou alterar o de Venda/Faturamento
       _cPedAltera:=SC5->C5_I_PVFAT
       _cTpOper   :=_cOperFat
       //Altera somente o campo de cliente entrega do pedido de Venda/Faturamento
       _cClient   :=SC5->C5_CLIENTE//Cliente do PV de Remessa custumizado
       _cLojaEnt  :=SC5->C5_LOJACLI//Cliente do PV de Remessa custumizado
       IF SC5->(DBSEEK(xFilial()+_cPedAltera))//Quando chega nesse ponto o pedido de Origem j� foi gravado
          _cCliente    := SC5->C5_CLIENTE
          _cLoja       := SC5->C5_LOJACLI
          M->C5_VEND1  := SC5->C5_VEND1
       ENDIF
    ENDIF

    SC5->( DBGOTO( _nRecOrigem ))//volta Recno do Pedido do pedido atual

    //IF _lExclui .AND. _cPedAltera == SC5->C5_I_PVFAT//Codigo de seguran�a para nunca deletar o PV de Venda/Faturamento
    IF _lExclui .AND. _cPedAltera == SC5->C5_I_PVREM//Codigo de seguran�a para nunca deletar o PV de Remessa
       RETURN .F.//Para n�o limpar os campos
    ENDIF

    _aCabPV  :={}//PRIVATE
    Aadd( _aCabPV, { "C5_FILIAL"	,SC5->C5_FILIAL, Nil})//filial
    Aadd( _aCabPV, { "C5_NUM"       ,_cPedAltera   , Nil})//PEDIDO QUE SER� ALTERADO
    Aadd( _aCabPV, { "C5_TIPO"	    ,SC5->C5_TIPO  , Nil})//Tipo de pedido
      Aadd( _aCabPV, { "C5_I_OPER"	,_cTpOper      , Nil})//Tipo da operacao
    Aadd( _aCabPV, { "C5_CLIENTE"   ,_cCliente     , NiL})//Codigo do cliente
    Aadd( _aCabPV, { "C5_LOJACLI"   ,_cLoja        , NiL})//Loja do cliente
    Aadd( _aCabPV, { "C5_CLIENT"    ,_cCliente     , Nil})//Codigo do cliente entrega padr�o
    Aadd( _aCabPV, { "C5_LOJAENT"   ,_cLoja        , NiL})//Loja para entrada padr�o
    Aadd( _aCabPV, { "C5_I_CLIEN"   ,_cClient      , Nil})//Codigo do cliente da Remessa custumizado
    Aadd( _aCabPV, { "C5_I_LOJEN"	,_cLojaEnt     , NiL})//Loja para entrada da Remessa custumizado

    Aadd( _aCabPV, { "C5_I_TIPCA"     ,SC5->C5_I_TIPCA   , Nil})//Tipo de Carga
    Aadd( _aCabPV, { "C5_I_AGEND"     ,SC5->C5_I_AGEND   , Nil})//Tipo de Agendamento
    Aadd( _aCabPV, { "C5_I_CHAPA"     ,SC5->C5_I_CHAPA   , Nil})//Qtd de Chapa
    Aadd( _aCabPV, { "C5_I_CUSDE"     ,SC5->C5_I_CUSDE   , Nil})//Custo Descarga
    Aadd( _aCabPV, { "C5_I_HORDE"     ,SC5->C5_I_HORDE   , Nil})//Hora Descarga
    Aadd( _aCabPV, { "C5_I_TPVEN"     ,SC5->C5_I_TPVEN   , Nil})//Tipo de Venda
    Aadd( _aCabPV, { "C5_I_TAB"       ,SC5->C5_I_TAB     , Nil})//Tabela de Pre�o		
    Aadd( _aCabPV, { "C5_TPFRETE"     ,SC5->C5_TPFRETE   , Nil})//Tp Frete
    Aadd( _aCabPV, { "C5_DESCONT"     ,SC5->C5_DESCONT   , Nil})//Desconto	

    IF !EMPTY(M->C5_VEND1)
       Aadd( _aCabPV, { "C5_VEND1"  ,M->C5_VEND1   , Nil})//Vendedor
    ENDIF
    Aadd( _aCabPV, { "C5_I_AGEND"   ,M->C5_I_AGEND , Nil})//Tipo de Entrega
    DadosPed("SC5")

    SC6->( DBSeek( SC5->C5_FILIAL + _cPedAltera ) )
    _aItensPVAlt:={}
    DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + _cPedAltera
        
       AADD(_aItensPVAlt,{ SC6->C6_ITEM,.F.,SC6->(RECNO()) })
       SC6->( DBSkip() )
        
    ENDDO

    //====================================================================================================
    // Monta o item do pedido
    //====================================================================================================
    _aItemPV :={}
    _aItensPV:={}
    SC6->( DbSetOrder(1) )
    SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )//Pedido alterado
    DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
        
       //IF _lComTela
       //   IncProc("Lendo Item: "+SC6->C6_ITEM)
       //ENDIF

       IF (nPos:=ASCAN(_aItensPVAlt,{|I| I[1]==SC6->C6_ITEM} )) = 0
          _lExisteItem :=.F.//Inclus�o
       ELSE
          _lExisteItem:=.T.//Alterado
          _aItensPVAlt[nPos,2]:=.T.
       ENDIF

       _aItemPV:={}		
       If _lExisteItem//N�o adiciona se for uma inclus�o
          AAdd( _aItemPV, { "LINPOS", "C6_ITEM", SC6->C6_ITEM } )//Esse item � adicionado para localizar a linha na Execauto quando a linha � alterada ou exclu�da
       EndIf
    
       AAdd( _aItemPV, { "AUTDELETA" , "N"            , nil })//Indica se a linha est� sendo exclu�da ou n�o
       AAdd( _aItemPV, { "C6_FILIAL" ,SC6->C6_FILIAL  , Nil })// FILIAL
       AAdd( _aItemPV, { "C6_NUM"    ,SC6->C6_NUM     , Nil })// Num. Pedido

       DadosPed("SC6","SC6")//COLOCA NA _aItemPV os outros campos

       AAdd( _aItensPV ,_aItemPV )

       SC6->( DBSkip() )
        
    ENDDO

    FOR I := 1 TO LEN(_aItensPVAlt)

       IF !_aItensPVAlt[I,2]
          SC6->(DBGOTO(_aItensPVAlt[I,3]))
          _aItemPV:={}		
          AAdd( _aItemPV, { "LINPOS"    ,"C6_ITEM"       , SC6->C6_ITEM } )//Esse item � adicionado para localizar a linha na Execauto quando a linha � alterada ou exclu�da
          AAdd( _aItemPV, { "AUTDELETA" ,"S"             , Nil })//Indica se a linha est� sendo exclu�da ou n�o
          AAdd( _aItemPV, { "C6_FILIAL" ,SC6->C6_FILIAL  , Nil })// FILIAL
          AAdd( _aItemPV, { "C6_NUM"    ,SC6->C6_NUM     , Nil })// Num. Pedido
          AAdd( _aItensPV ,_aItemPV )
       ENDIF   

    NEXT I

    //====================================================================================================
    // REPLICA O PEDIDO OU EXCLUI
    //====================================================================================================	
    SC9->( DBSetOrder(1) )
    _cMensagem:=""
    IF _lExclui .AND. SC9->( DBSeek( SC5->C5_FILIAL + _cPedAltera  ) )//SE TIVER SC9 ESTORNA A LIBERACAO

        SC6->(Dbsetorder(1))
        SC6->(DbSeek(SC5->C5_FILIAL+_cPedAltera))
        
        //Se tiver libera��o v�lida para todos os itens desfaz libera��o
        Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->C5_FILIAL+_cPedAltera
            SC9->(Dbsetorder(1))
            If (SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM)))
                SC9->(_lRet:=A460Estorna()) // estorna a libera��o
                IF !_lRet
                    _cMensagem+="Pedido + Item: "+SC6->C6_NUM+" + "+SC6->C6_ITEM+" teve problemas na libera��o "
                    lMsErroAuto:=.T.
                ENDIF
            EndIf
            SC6->(Dbskip())
        Enddo
        
        SC9->(Dbsetorder(1))
        If !SC9->(DbSeek(SC5->C5_FILIAL+_cPedAltera))
           SC5->(Reclock("SC5",.F.))
           SC5->C5_LIBEROK := "  "
           SC5->C5_I_STATU := "01"
           SC5->(Msunlock())
        ELSE
             _cMensagem+="Pedido: "+SC6->C6_NUM+" teve problemas na libera��o (Ainda tem SC9) "
           lMsErroAuto:=.T.
        ENDIF

    ENDIF

    If !lMsErroAuto

        If _lComTela
              FWMSGRUN( , {||  MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , IF(_lExclui,5,4) ) }, "AGUARDE...",IF(_lExclui,"EXCLUINDO","ALTERANDO")+" O PEDIDO DE FATURAMENTO DA O.T. ... ")   	
        else
            MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , IF(_lExclui,5,4) ) 
        ENDIF
    
    ENDIF

    _cCliente :=_cCliente+" / "+_cLoja+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NREDUZ") )

    If lMsErroAuto
        
       If ( __lSx8 )
          RollBackSx8()
       EndIf 
       IF EMPTY(_cMensagem)
          _cMensagem:=" ["+MostraErro()+"]"
       ENDIF

       SC5->( DBGOTO( _nRecOrigem ))//Recno do Pedido de Origem 
       IF _lExclui
          _cMensagem:='Erro ao excluir o Pedido '+_cPedAltera+': '+_cMensagem
       ELSE   
          _cMensagem:='Erro ao alterar o Pedido '+_cPedAltera+': '+_cMensagem
       ENDIF
       //dd( _aLog    , {" ",'Pedido Faturamento','Pedido Remessa','Movimenta��o','Cliente','Operacao'    } )
       aAdd( _aLog    , {.F.,SC5->C5_I_PVFAT     ,SC5->C5_I_PVREM ,_cMensagem    ,_cCliente,SC5->C5_I_OPER} )
        
       _lDeuErro:=.T.//Se der algum Erro

    Else

       IF _lExclui

          SC5->( DBGOTO( _nRecOrigem ))//Recno do Pedido de Origem 
          SC5->( RecLock( 'SC5' , .F. ) )
          SC5->C5_I_PVFAT:=SPACE(LEN(SC5->C5_I_PVFAT))
             SC5->( MsUnlock() )
   
          _lDeuErro:=.F.//Se der algum Erro

          _cMensagem:='Foi Excluido o Pedido de Faturamento da Operacao Triangular: '+_cPedAltera
       ELSE   

            //====================================================================================================
            _cMemAux:=""
            IF SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
                DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
    
                    IF !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
                        _nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO
                    ELSE
                        _nQtdLib := SC9->C9_QTDLIB
                    ENDIF
    
                    IF _nQtdLib # SC6->C6_QTDVEN
                       _lComTela:=.T.
                       _cMemAux:=", mas N�o liberou o Pedido, Item: [ "+SC6->C6_FILIAL+" "+SC6->C6_NUM+" "+SC6->C6_ITEM+"] "
                        EXIT
                    ENDIF
    
                    SC6->( DBSkip() )
    
                ENDDO
            ENDIF

            _cMensagem:='Foi alterado o Pedido de Faturamento da Operacao Triangular: '+_cPedAltera+_cMemAux

       ENDIF
        //dd( _aLog , {" ",'Pedido Faturamento','Pedido Remessa','Movimenta��o','Cliente','Operacao'    } )
        aAdd( _aLog , {.T.,SC5->C5_NUM         ,SC5->C5_I_PVREM ,_cMensagem    ,_cCliente,SC5->C5_I_OPER} )

        If !FWIsInCallStack("U_AOMS109") .And. _lComTela
        
            U_ITMSG(_cMensagem,"Aten��o!",,2)
            
        Endif

    ENDIF

 ENDIF

RETURN !_lDeuErro
 
/*
===============================================================================================================================
Programa--------: DadosPed()
Autor-----------: Alex Wallauer
Data da Criacao-: 22/08/2017
===============================================================================================================================
Descri��o-------: Carregamentos das arrays das tebelas SC5 e SC6
===============================================================================================================================
Parametros------: _cTabela: SC5 ou SC6 
                  _cAlias: Alias dos itens
===============================================================================================================================
Retorno---------: .T.
===============================================================================================================================*/
STATIC function DadosPed(_cTabela,_cAlias)

IF _cTabela = "SC5"
   Aadd( _aCabPV, { "C5_EMISSAO"    ,M->C5_EMISSAO, NiL}) //Data de emissao
   Aadd( _aCabPV, { "C5_TRANSP"     ,M->C5_TRANSP , Nil}) 
   Aadd( _aCabPV, { "C5_CONDPAG"    ,M->C5_CONDPAG, NiL}) //Codigo da condicao de pagamanto*
   Aadd( _aCabPV, { "C5_MOEDA"	    ,M->C5_MOEDA  , Nil}) //Moeda
   Aadd( _aCabPV, { "C5_MENPAD"     ,M->C5_MENPAD , Nil}) 
   Aadd( _aCabPV, { "C5_LIBEROK"    ,M->C5_LIBEROK, NiL}) //Liberacao Total
   Aadd( _aCabPV, { "C5_TIPLIB"     ,M->C5_TIPLIB , Nil}) //Tipo de Liberacao
   Aadd( _aCabPV, { "C5_TIPOCLI"    ,M->C5_TIPOCLI, NiL}) //Tipo do Cliente
   Aadd( _aCabPV, { "C5_I_NPALE"    ,M->C5_I_NPALE, NiL}) //Numero que originou a pedido de palete
   Aadd( _aCabPV, { "C5_I_PEDPA"    ,M->C5_I_PEDPA, NiL}) //Pedido Refere a um pedido de Pallet
   Aadd( _aCabPV, { "C5_I_DTENT"    ,M->C5_I_DTENT, Nil}) //Dt de Entrega // M->C5_I_DTENT
 //Aadd( _aCabPV, { "C5_I_TRCNF"    ,"N", Nil}) //Sempre "n�o",  pq o de faturamento nunca � troca NF , s� o de remessa pode ser

    Aadd( _aCabPV, { "C5_I_TRCNF" ,M->C5_I_TRCNF , NIL})//Campos do Troca Nota agora ser�o  replicados do Pedido 42 para o Pedido 05, Chamado 43893
    Aadd( _aCabPV, { "C5_I_FLFNC" ,M->C5_I_FLFNC , NIL})//Campos do Troca Nota agora ser�o  replicados do Pedido 42 para o Pedido 05, Chamado 43893
    Aadd( _aCabPV, { "C5_I_FILFT" ,M->C5_I_FILFT , NIL})//Campos do Troca Nota agora ser�o  replicados do Pedido 42 para o Pedido 05, Chamado 43893
    Aadd( _aCabPV, { "C5_I_PDFT"  ,M->C5_I_PDFT  , NIL})//Campos do Troca Nota agora ser�o  replicados do Pedido 42 para o Pedido 05, Chamado 43893
    Aadd( _aCabPV, { "C5_I_PDPR"  ,M->C5_I_PDPR  , NIL})//Campos do Troca Nota agora ser�o  replicados do Pedido 42 para o Pedido 05, Chamado 43893
    Aadd( _aCabPV, { "C5_I_LOCEM" ,M->C5_I_LOCEM , NIL})//Campos do Troca Nota agora ser�o  replicados do Pedido 42 para o Pedido 05, Chamado 43893
   
   Aadd( _aCabPV, { "C5_I_OBCOP" 	,M->C5_I_OBCOP, Nil})
   Aadd( _aCabPV, { "C5_I_OBPED" 	,M->C5_I_OBPED, Nil})
   Aadd( _aCabPV, { "C5_I_BLPRC"    ,M->C5_I_BLPRC, Nil})
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,M->C5_I_BLCRE, Nil})
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,M->C5_I_BLCRE, Nil})
   Aadd( _aCabPV, { "C5_I_SENHA"    ,M->C5_I_SENHA, Nil})
   Aadd( _aCabPV, { "C5_I_HOREN"    ,M->C5_I_HOREN, Nil})   
   Aadd( _aCabPV, { "C5_I_TIPCA"    ,M->C5_I_TIPCA, Nil})
   Aadd( _aCabPV, { "C5_I_CDUSU"    ,M->C5_I_CDUSU, Nil})   
   Aadd( _aCabPV, { "C5_MENNOTA"    ,M->C5_MENNOTA, Nil})
   Aadd( _aCabPV, { "C5_MENPAD"     ,M->C5_MENPAD , Nil})
 //Aadd( _aCabPV, { "C5_I_PODES"    ,M->C5_NUM    , Nil})
   Aadd( _aCabPV, { "C5_I_PODES"    ,""           , Nil})//Limpar esse campos sempre, Chamado 43893
   Aadd( _aCabPV, { "C5_I_BLPRC"    ,M->C5_I_BLPRC, Nil}) 
   Aadd( _aCabPV, { "C5_I_DTLIB"    ,M->C5_I_DTLIB, Nil})
   Aadd( _aCabPV, { "C5_I_IDPED"    ,M->C5_I_IDPED, Nil})
   Aadd( _aCabPV, { "C5_ORIGEM "    ,M->C5_ORIGEM , Nil})
   Aadd( _aCabPV, { "C5_I_DTAIM"    ,M->C5_I_DTAIM, Nil})
   Aadd( _aCabPV, { "C5_I_HORAI"    ,M->C5_I_HORAI, Nil})
   Aadd( _aCabPV, { "C5_I_DATAA"    ,M->C5_I_DATAA, Nil})
   Aadd( _aCabPV, { "C5_I_HORAA"    ,M->C5_I_HORAA, Nil})
   Aadd( _aCabPV, { "C5_I_DTLIP"    ,M->C5_I_DTLIP, Nil})
   Aadd( _aCabPV, { "C5_I_MLIBP"    ,M->C5_I_MLIBP, Nil})
   Aadd( _aCabPV, { "C5_I_DTAVA"    ,M->C5_I_DTAVA, Nil})
   Aadd( _aCabPV, { "C5_I_HRAVA"    ,M->C5_I_HRAVA, Nil})
   Aadd( _aCabPV, { "C5_I_USRAV"    ,M->C5_I_USRAV, Nil})
   Aadd( _aCabPV, { "C5_I_LIBCA"    ,M->C5_I_LIBCA, Nil})
   Aadd( _aCabPV, { "C5_I_LIBCT"    ,M->C5_I_LIBCT, Nil})
   Aadd( _aCabPV, { "C5_I_LIBL "    ,M->C5_I_LIBL , Nil})
   Aadd( _aCabPV, { "C5_I_LIBCV"    ,M->C5_I_LIBCV, Nil}) //49 valor liberado de cr�dito
   Aadd( _aCabPV, { "C5_I_LIBCD"    ,M->C5_I_LIBCD, Nil})
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,M->C5_I_BLCRE, Nil})
   Aadd( _aCabPV, { "C5_I_MOTBL"    ,M->C5_I_MOTBL, Nil})
   Aadd( _aCabPV, { "C5_I_DTLIC"    ,M->C5_I_DTLIC, Nil})
   Aadd( _aCabPV, { "C5_I_PLIBP"    ,M->C5_I_PLIBP, Nil})
   Aadd( _aCabPV, { "C5_I_ULIBP"    ,M->C5_I_ULIBP, Nil}) 
   Aadd( _aCabPV, { "C5_I_VLIBP"    ,M->C5_I_VLIBP, Nil})//56 valor liberado de pre�o
   Aadd( _aCabPV, { "C5_I_MOTLP"    ,M->C5_I_MOTLP, Nil})
   Aadd( _aCabPV, { "C5_I_MOTLB"    ,M->C5_I_MOTLB, Nil})
   Aadd( _aCabPV, { "C5_I_QLIBP"    ,M->C5_I_QLIBP, Nil}) //59 TOTAL liberado de pre�o
   Aadd( _aCabPV, { "C5_I_VLIBB"    ,M->C5_I_VLIBB, Nil})//60 valor liberado de bonifica��o
   Aadd( _aCabPV, { "C5_I_QLIBB"    ,M->C5_I_QLIBB, Nil})
   Aadd( _aCabPV, { "C5_I_CLILP"    ,M->C5_I_CLILP, Nil})
   Aadd( _aCabPV, { "C5_I_CLILB"    ,M->C5_I_CLILB, Nil})
   Aadd( _aCabPV, { "C5_I_LLIBB"    ,M->C5_I_LLIBB, Nil})
   Aadd( _aCabPV, { "C5_I_ULIBB"    ,M->C5_I_ULIBB, Nil})
   Aadd( _aCabPV, { "C5_I_LLIBP"    ,M->C5_I_LLIBP, Nil})
   Aadd( _aCabPV, { "C5_I_HLIBP"    ,M->C5_I_HLIBP, Nil})
   Aadd( _aCabPV, { "C5_I_FILOR"    ,M->C5_I_FILOR, Nil})
   Aadd( _aCabPV, { "C5_I_PEDOR"    ,M->C5_I_PEDOR, Nil})
   Aadd( _aCabPV, { "C5_I_DTRAN"    ,M->C5_I_DTRAN, Nil})
   Aadd( _aCabPV, { "C5_I_UTRAN"    ,M->C5_I_UTRAN, Nil})
   Aadd( _aCabPV, { "C5_I_MTRAN"    ,M->C5_I_MTRAN, Nil})
// Aadd( _aCabPV, { "C5_I_HORP "    ,M->C5_I_HORP , Nil})//N�o enviar pq o gatilho do cliente preenche
// Aadd( _aCabPV, { "C5_I_CHPCL"    ,M->C5_I_CHPCL, Nil})//N�o enviar pq o gatilho do cliente preenche
   Aadd( _aCabPV, { "C5_I_DOCA "    ,M->C5_I_DOCA , Nil})
   Aadd( _aCabPV, { "C5_I_FLFNC"    ,M->C5_I_FLFNC, Nil})
   Aadd( _aCabPV, { "C5_I_OBSAV"    ,M->C5_I_OBSAV, Nil})
   Aadd( _aCabPV, { "C5_I_FILFT"    ,M->C5_I_FILFT, Nil})
// Aadd( _aCabPV, { "C5_I_PDFT "    ,M->C5_I_PDFT , Nil})//Sempre "branco",  pq o de faturamento nunca � troca NF , s� o de remessa pode ser
// Aadd( _aCabPV, { "C5_I_PDPR "    ,M->C5_I_PDPR , Nil})//Sempre "branco",  pq o de faturamento nunca � troca NF , s� o de remessa pode ser
   Aadd( _aCabPV, { "C5_I_TAB "    ,M->C5_I_TAB , Nil}) 

ELSEIF _cTabela = "SC6"
    
    AAdd( _aItemPV , { "C6_ITEM"    ,(_cAlias)->C6_ITEM    , Nil}) // Numero do Item no Pedido
    AAdd( _aItemPV , { "C6_PRODUTO" ,(_cAlias)->C6_PRODUTO , Nil}) // Codigo do Produto
    AAdd( _aItemPV , { "C6_UNSVEN"  ,(_cAlias)->C6_UNSVEN  , Nil}) // Quantidade Vendida 2 un
    AAdd( _aItemPV , { "C6_QTDVEN"  ,(_cAlias)->C6_QTDVEN  , Nil}) // Quantidade Vendida
    AAdd( _aItemPV , { "C6_PRCVEN"  ,(_cAlias)->C6_PRCVEN  , Nil}) // Preco Unitario Liquido
    AAdd( _aItemPV , { "C6_PRUNIT"  ,(_cAlias)->C6_PRUNIT  , Nil}) // Preco Unitario Liquido
    AAdd( _aItemPV , { "C6_ENTREG"  ,(_cAlias)->C6_ENTREG  , Nil}) // Data da Entrega
    AAdd( _aItemPV , { "C6_LOJA"    ,(_cAlias)->C6_LOJA	   , Nil})
    AAdd( _aItemPV , { "C6_SUGENTR" ,(_cAlias)->C6_SUGENTR , Nil}) // Data da Entrega
    AAdd( _aItemPV , { "C6_VALOR"   ,(_cAlias)->C6_VALOR   , Nil}) // valor total do item // (_cAlias)->C6_VALOR
    AAdd( _aItemPV , { "C6_UM"      ,(_cAlias)->C6_UM      , Nil}) // Unidade de Medida Primar.
//	AAdd( _aItemPV , { "C6_TES"     ,(_cAlias)->C6_TES     , Nil})
    AAdd( _aItemPV , { "C6_LOCAL"   ,(_cAlias)->C6_LOCAL   , Nil}) // Almoxarifado
//	AAdd( _aItemPV , { "C6_CF"      ,(_cAlias)->C6_CF	   , Nil})
    AAdd( _aItemPV , { "C6_DESCRI"  ,(_cAlias)->C6_DESCRI  , Nil}) // Descricao
    AAdd( _aItemPV , { "C6_QTDLIB"  ,(_cAlias)->C6_QTDLIB  , Nil}) // Quantidade Liberada
    AAdd( _aItemPV , { "C6_PEDCLI"  ,(_cAlias)->C6_PEDCLI  , Nil})
    AAdd( _aItemPV , { "C6_I_BLPRC" ,(_cAlias)->C6_I_BLPRC , Nil})
    AAdd( _aItemPV , { "C6_I_QPALT" ,(_cAlias)->C6_I_QPALT , Nil}) // Quantidade de Pallets
    Aadd( _aItemPV,  { "C6_I_USER " ,(_cAlias)->C6_I_USER  , Nil})
    Aadd( _aItemPV,  { "C6_I_LIBPC" ,(_cAlias)->C6_I_LIBPC , Nil})
    Aadd( _aItemPV,  { "C6_I_DLIBP" ,(_cAlias)->C6_I_DLIBP , Nil})
    Aadd( _aItemPV,  { "C6_I_PLIBP" ,(_cAlias)->C6_I_PLIBP , Nil})
    Aadd( _aItemPV,  { "C6_I_ULIBP" ,(_cAlias)->C6_I_ULIBP , Nil})
    Aadd( _aItemPV,  { "C6_I_VLIBP" ,(_cAlias)->C6_I_VLIBP , Nil})
    Aadd( _aItemPV,  { "C6_I_MOTLP" ,(_cAlias)->C6_I_MOTLP , Nil})
    Aadd( _aItemPV,  { "C6_I_QTLIP" ,(_cAlias)->C6_I_QTLIP , Nil})
    Aadd( _aItemPV,  { "C6_I_CLILP" ,(_cAlias)->C6_I_CLILP , Nil})
    Aadd( _aItemPV,  { "C6_I_CLILB" ,(_cAlias)->C6_I_CLILB , Nil})
    Aadd( _aItemPV,  { "C6_I_VLIBB" ,(_cAlias)->C6_I_VLIBB , Nil})
    Aadd( _aItemPV,  { "C6_I_QLIBB" ,(_cAlias)->C6_I_QLIBB , Nil})
    Aadd( _aItemPV,  { "C6_I_LLIBP" ,(_cAlias)->C6_I_LLIBP , Nil})
    Aadd( _aItemPV,  { "C6_I_LLIBB" ,(_cAlias)->C6_I_LLIBB , Nil})
    Aadd( _aItemPV,  { "C6_I_MOTLB" ,(_cAlias)->C6_I_MOTLB , Nil})
    Aadd( _aItemPV,  { "C6_I_PLIBB" ,(_cAlias)->C6_I_PLIBB , Nil})
    Aadd( _aItemPV,  { "C6_I_DLIBB" ,(_cAlias)->C6_I_DLIBB , Nil})
    Aadd( _aItemPV,  { "C6_I_VLTAB" ,(_cAlias)->C6_I_VLTAB , Nil})
    Aadd( _aItemPV,  { "C6_I_PRMIN" ,(_cAlias)->C6_I_PRMIN , Nil})
ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa--------: IT_conpg()
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 26/03/2018
Descri��o-------: Retorna condi��o de pagamento personalizada
Parametros------: _cCliente - c�digo do cliente
                  _cLoja - loja do cliente
                  _cproduto - produto
                  _lTemCP_Especial - Se tem condi��o especial
Retorno---------: _cCondEspecial - c�digo da condi��o de pagamento
===============================================================================================================================*/
User Function IT_conpg(_cCliente,_cLoja,_cproduto,_lTemCP_Especial)

 Local _cCondEspecial := " "
 Default _cCliente    := M->C5_CLIENT
 Default _cLoja       := M->C5_LOJAENT
 Default _cproduto    := " "
 
 _lTemCP_Especial:= .F.
 
 //Posiciona cliente
 SA1->(dbSetOrder(1))
 If !( SA1->(dbSeek(xFilial("SA1")+_cCliente+_cLoja)))
    Return _cCondEspecial
 Endif

 If Empty(_cproduto) .And. Empty(M->C5_CONDPAG)
    _cCondEspecial := alltrim(SA1->A1_COND) 
 EndIf 

 //Por cliente +  loja
 ZGO->(Dbsetorder(2)) //ZGO_CLIENT+ZGO_LOJA
 
 If ZGO->(Dbseek(_cCliente+_cLoja))
         
    //Fase um - Procura condi��o com filial vazia e produto vazio
    Do while ZGO->ZGO_CLIENT == _cCliente .AND. ZGO->ZGO_LOJA == _cLoja
        If EMPTY(ZGO->ZGO_PRODUT) .and. EMPTY(ZGO->ZGO_FILCD)  
            _cCondEspecial := ZGO->ZGO_CONDPA
        Endif
        ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(_cCliente+_cLoja))
    
    //Fase dois - Procura condi��o com filial igual cfilant e produto vazio
    Do while ZGO->ZGO_CLIENT == _cCliente .AND. ZGO->ZGO_LOJA == _cLoja
        If EMPTY(ZGO->ZGO_PRODUT) .and. ALLTRIM(ZGO->ZGO_FILCD) == ALLTRIM(cfilant) 
            _cCondEspecial := ZGO->ZGO_CONDPA
        Endif
        ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(_cCliente+_cLoja))
    
    //Fase tr�s - Procura condi��o com filial vazia e produto preenchido
    Do while ZGO->ZGO_CLIENT == _cCliente .AND. ZGO->ZGO_LOJA == _cLoja
       If !EMPTY(ZGO->ZGO_PRODUT) .and. alltrim(ZGO->ZGO_PRODUT) == alltrim(_cproduto) .and. EMPTY(ZGO->ZGO_FILCD)  
            _lTemCP_Especial := .T.
           _cCondEspecial := ZGO->ZGO_CONDPA
       Endif
       ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(_cCliente+_cLoja))
    
    //Fase quatro - procura condi��o com filial igual cfilant e produto igual ao primeiro produto do acols
    Do while ZGO->ZGO_CLIENT == _cCliente .AND. ZGO->ZGO_LOJA == _cLoja
       If !EMPTY(ZGO->ZGO_PRODUT) .and. alltrim(ZGO->ZGO_PRODUT) == alltrim(_cproduto) .and. alltrim(ZGO->ZGO_FILCD) == alltrim(cfilant)  
            _lTemCP_Especial := .T.
           _cCondEspecial := ZGO->ZGO_CONDPA
       Endif
       ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(_cCliente+_cLoja))

 Endif		
 
 ZGO->(Dbsetorder(5)) //ZGO_REDE
 //===============================================================================
 //Por rede
 //===============================================================================
 If ZGO->(Dbseek(SA1->A1_GRPVEN))
    //Fase um - Procura condi��o com filial vazia e produto vazio
    Do while ZGO->ZGO_REDE == SA1->A1_GRPVEN
        If EMPTY(ZGO->ZGO_PRODUT) .and. EMPTY(ZGO->ZGO_FILCD)  
            _cCondEspecial := ZGO->ZGO_CONDPA 
        Endif
        ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(SA1->A1_GRPVEN))			
    
    //Fase dois - Procura condi��o com filial igual cfilant e produto vazio
    Do while ZGO->ZGO_REDE == SA1->A1_GRPVEN    
        If EMPTY(ZGO->ZGO_PRODUT) .and. ALLTRIM(ZGO->ZGO_FILCD) == ALLTRIM(cfilant) 
            _cCondEspecial := ZGO->ZGO_CONDPA      
        Endif
        ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(SA1->A1_GRPVEN))			
    
    //Fase tr�s - Procura condi��o com filial vazia e produto preenchido
    Do while ZGO->ZGO_REDE == SA1->A1_GRPVEN
        If !EMPTY(ZGO->ZGO_PRODUT) .and. alltrim(ZGO->ZGO_PRODUT) == alltrim(_cproduto) .and. EMPTY(ZGO->ZGO_FILCD)  
            _lTemCP_Especial := .T.
            _cCondEspecial := ZGO->ZGO_CONDPA
        Endif
        ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(SA1->A1_GRPVEN))			
    
    //Fase quatro - procura condi��o com filial igual cfilant e produto igual ao primeiro produto do acols
    Do while ZGO->ZGO_REDE == SA1->A1_GRPVEN
        If !EMPTY(ZGO->ZGO_PRODUT) .and. alltrim(ZGO->ZGO_PRODUT) == alltrim(_cproduto) .and. alltrim(ZGO->ZGO_FILCD) == alltrim(cfilant)  
            _cCondEspecial := ZGO->ZGO_CONDPA           
            _lTemCP_Especial := .T.
        Endif
        ZGO->(Dbskip())
    Enddo
    ZGO->(Dbseek(SA1->A1_GRPVEN))
 Endif

 if EMPTY(_cCondEspecial)
    _cCondEspecial :=  M->C5_CONDPAG
 ENDIF

Return _cCondEspecial


/*
===============================================================================================================================
Programa--------: IT_conpv()
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 26/03/2018
Descri��o-------: Retorna condi��o de pagamento personalizada para o pedido de vendas aberto
Parametros------: apenas o lret de retorno da valida��o mas precisa estar com pedido aberto no mata410
Retorno---------: _cCondPagOK - c�digo da condi��o de pagamento
===============================================================================================================================*/
User function IT_conpv(lret as logical) as char

Local _cCPag   := "" As Char
Local _cCondPagOK := u_IT_conpg(alltrim(M->C5_CLIENT),alltrim(M->C5_LOJAENT)) As Char//Busca a condi��o de pagamento do cliente (pode especial sem produto) ou do SC5
Local nx := 0 As Numeric
Local _nPosPro := ascan(aHeader,{|x| alltrim(x[2])=="C6_PRODUTO"}) As Numeric
Local _nPosDesc:= ascan(aHeader,{|x| alltrim(x[2])=="C6_DESCRI" }) As Numeric
Local _lTemCP_Especial := .F. As Logical
Local _cCPSemProd := _cCondPagOK As Char
Default lret   := .T. 

For nx:=1 to len(aCols)

    if !aTail(aCols[nx])  // Se Linha Nao Deletada
 
       _cCPag :=  u_IT_conpg(alltrim(M->C5_CLIENT),alltrim(M->C5_LOJAENT),acols[nx][_npospro],@_lTemCP_Especial)
       If nx = 1 .AND. !Empty(_cCPag) .AND. Empty(_cCPSemProd)//Se n�o tiver a condi��o do cliente e do SC5 , a CP do 1o item que vale de comparacao com os outros
          _cCPSemProd := _cCPag
       EndIF
       If !Empty(_cCPag) .AND. _lTemCP_Especial
           _cCondPagOK := _cCPag
       Endif
       If _cCPSemProd <> _cCondPagOK  //Se a condi��o do produto � diferente da encontrada em outros produtos do pedido
          U_MT_ITMSG("O produto " + ALLTRIM(acols[nx][_npospro])+" - "+ALLTRIM(acols[nx][_nPosDesc])+" tem a regra de condi��o de pagamento " +  _cCondPagOK + " em diverg�ncia com a condi��o " + _cCPSemProd + " j� definida nos demais produtos ou pedido!",;
                     "Aten��o","Elabore um pedido de vendas separado para outra condi��o de pagamento",1)
          lRet := .F.
          exit
        Endif
 
    Endif

Next nx

Return _cCondPagOK

/*
===============================================================================================================================
Programa--------: U_ITTABPRC
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 26/03/2018
Descri��o-------: Retorna tabela de pre�os para o pedido de vendas #PRECODEVENDAS

Parametros------: _cFilCarreg- Filial de embarque
                  _cFilFatura- Filial de faturamento
                  _cGeren    - Gerente da venda
                  _cCoord    - Coordenador da venda
                  _cVend     - Vendedor do pedido
                  _cCliente  - Cliente do pedido
                  _cLojacli  - Loja do cliente do pedido	
                  _lUsaNovo  - Sempre usa novo cadastro de tabela de pre�os - N�O USA MAIS
                  _cTab      - Nome da tabela
                  _cSuper    - Codigo do supervisor
                  _cRede     - Codigo da rede
                  _cGrupoPrd - Codigo do grupo de produtos - N�O USA MAIS
                  _cTipoOper - Codigo do tipo de opera��o
                  _cLocalEmb - Codigo do Local de Embarque
                  _cCliAdqu  - Cliente Adquirente do pedido
                  _cLojadqu  - Loja do cliente Adquirente do pedido	

Retorno---------: _aret - array com c�digo a tabela de pre�os e recno de origem da regra 
===============================================================================================================================*/
User function ITTabPrc(_cFilCarreg As Char,;
                       _cFilFatura As Char,;
                        _cGeren As Char,;
                        _cCoord As Char,;
                        _cVend As Char,;
                        _cCliente As Char,;
                        _cLojaCli As Char,;
                        _lUsaNovo As Logical,;
                        _cTab As Char,;
                        _cSuper As Char,;
                        _cRede As Char,;
                        _cGrupoPrd As Char,;
                        _cTipoOper As Char,;
                        _cLocalEmb As Char,;
                        _cCliAdqu As Char,;
                        _cLojadqu As Char) As Array
 Local _cTabDireta As Char
 Local _nRecno As Numeric
 Local _cRegra As Char
 Local _cFilori As Char
 Local _nI As Numeric
 Local _cRegra1 := " " As Char
 Local _cRegra2 As Char
 Local _cRegra3 As Char
 Local _cRegra4 As Char
 Local _cRegra5 As Char
 Local _cRegra6 As Char
 Local _cRegra7 As Char
 Local _cTabPre1 As Char
 Local _cTabPre2 As Char
 Local _cTabPre3 As Char
 Local _cTabPre4 As Char
 Local _cTabPre5 As Char
 Local _cTabPre6 As Char
 Local _cTabPre7 As Char
 Local _nRecno1 As Numeric
 Local _nRecno2 As Numeric
 Local _nRecno3 As Numeric
 Local _nRecno4 As Numeric
 Local _nRecno5 As Numeric
 Local _nRecno6 As Numeric
 Local _nRecno7 As Numeric
 Local _nFatMinPrc As Numeric
 Local _cGrupoP :="" As Char
 Local _cGrupoP1 As Char
 Local _cGrupoP2 As Char
 Local _cGrupoP3 As Char
 Local _cGrupoP4 As Char
 Local _cGrupoP5 As Char
 Local _cGrupoP6 As Char
 Local _cGrupoP7 As Char
 Local _cUFPedV :="" As Char
 Local _cUFPedV1 As Char
 Local _cUFPedV2 As Char
 Local _cUFPedV3 As Char
 Local _cUFPedV4 As Char
 Local _cUFPedV5 As Char
 Local _cUFPedV6 As Char
 Local _cUFPedV7 As Char
 Local _cSegCli  As Char
 Local _cUF      As Char
 Local _cOperTriangular As Char
 Local _cOperRemessa    As Char
 Local _cOperFat        As Char
 Local _lRegraNova      As Logical //Mudan�a na politica de Pre�o de Vendas 01/2025
 Local _aCposBusca      As Array
 Local _aDadosZGQ       As Array
  
 _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de opera��es da opera��o trigular
 _cOperFat       := LEFT(_cOperTriangular,2)
 _cOperRemessa   := RIGHT(_cOperTriangular,2)
 _lRegraNova     := SuperGetMV("IT_AMBTEST",.F.,.T.)
 _lRegraNova     := SuperGetMV("MV_ITMDREG",, _lRegraNova ) //O PARAMETRO DEVE SER CRIADO LOGICO
 _lRegraNova     := _lRegraNova .AND. ZGQ->(FIELDPOS("ZGQ_LOCEMB")) > 0 .AND. ZGQ->(FIELDPOS("ZGQ_SEGCLI")) > 0
 _cTabDireta     := "   " //Origem do Cliente ou da Opera��o
 _nRecno         := 0
 _cRegra         := "N�o Encontrou Tabela"
 _cfilori        := cfilant
 
 //CARREGA DEFAULTS POIS QUANDO EST�O COM O PEDIDO DE VENDAS ABERTO CHAMA A FUN��O SEM PAR�METROS
 IF TYPE("M->C5_I_OPER") = "C"
    Default _cTipoOper := M->C5_I_OPER 
    Default _cTab      := M->C5_I_TAB 
    Default _cRede     := M->C5_I_GRPVE
    Default _cFilCarreg:= M->C5_FILGCT
    Default _cFilFatura:= M->C5_I_FILFT
    Default _cSuper    := M->C5_VEND4
    Default _cGeren    := M->C5_VEND3
    Default _cCoord    := M->C5_VEND2
    Default _cVend     := M->C5_VEND1
    Default _cCliente  := M->C5_CLIENTE
    Default _cLojacli  := M->C5_LOJACLI
    Default _cLocalEmb := M->C5_I_LOCEM
    Default _cCliAdqu  := M->C5_I_CLIEN
    Default _cLojadqu  := M->C5_I_LOJEN
 ELSE
    Default _cTipoOper := SC5->C5_I_OPER 
    Default _cTab      := SC5->C5_I_TAB 
    Default _cRede     := SC5->C5_I_GRPVE
    Default _cFilCarreg:= SC5->C5_FILGCT
    Default _cFilFatura:= SC5->C5_I_FILFT
    Default _cSuper    := SC5->C5_VEND4
    Default _cGeren    := SC5->C5_VEND3
    Default _cCoord    := SC5->C5_VEND2
    Default _cVend     := SC5->C5_VEND1
    Default _cCliente  := SC5->C5_CLIENTE
    Default _cLojacli  := SC5->C5_LOJACLI
    Default _cLocalEmb := SC5->C5_I_LOCEM
    Default _cCliAdqu  := SC5->C5_I_CLIEN
    Default _cLojadqu  := SC5->C5_I_LOJEN
 ENDIF
 
 Begin Sequence
 
 //Carrega dados de filial, filial de faturamento e carregamento se n�o foram informados
 IF TYPE("M->C5_NUM") = "C"
     If M->C5_NUM == SC5->C5_NUM
         _cfilial := SC5->C5_FILIAL //Se ja est�o gravando o pedido sempre considera o C5_FILIAL para opera��es multifiliais
     Else
         _cfilial := cfilant //Se n�o inclus�o considera a filial atual
     Endif
 ELSE
     _cfilial := _cFilFatura //Se n�o tem a variavel de memoria n�o tem como saber se chama com SC5 ou SZW
 Endif
 
 If empty(_cFilCarreg)
     _cFilCarreg := _cfilial
 Endif
 
 If empty(_cFilFatura)
     _cFilFatura := _cfilial 
 Endif 
 
 //Muda filial para filial de faturamento para carregar par�metros corretamente
 cfilant := _cFilFatura// AGORA J� ESTA NA FILIAL DE FATURAMENTO
 
 //**************************
 //     PRIMEIRA BUSCA
 //*************************
 _cTabDireta := Posicione("ZB4",1,xFilial("ZB4")+_cTipoOper,"ZB4_TABPRC")
 
 If Empty(_cTabDireta) .OR. !(DA0->(Dbseek(xfilial("DA0")+_cTabDireta))) .OR. DA0->DA0_ATIVO = '2' .OR. DA0->DA0_DATDE > DATE() .OR. DA0->DA0_DATATE < DATE()//Tabela inativa
    _cTabDireta:= "   "
 Else
    _cRegra1   := "Regra por Opera��o " + _cTipoOper
 EndIf
 
 //**************************
 //      SEGUNDA BUSCA
 //**************************
 //***** NOVA REGARA DE BUSCA DA OPERACO IANGULAR ************************************************************************************//
 IF _lRegraNova .AND. _cTipoOper $ _cOperTriangular .AND. Empty(_cTabDireta)
    //=================================**************************************************************************************************//
    
    If _cOperFat = _cTipoOper//05 - Faturamento
       _cCliAdqu  := _cCliente
       _cLojadqu  := _cLojacli
    EndIf//se for 42 - Remessa n�o precisa mudar o adquirente

    ZGQ->(Dbsetorder(4))//ZGQ_FILIAL+ZGQ_FILFAT+ZGQ_LOCEMB+ZGQ_CLIENT+ZGQ_LOJA
    ZGQ->(Dbseek(xfilial()+_cFilFatura+_cLocalEmb+_cCliAdqu+_cLojadqu))
     
    Do While .not. ZGQ->(Eof()) .AND. xfilial("ZGQ")+_cFilFatura+_cLocalEmb+_cCliAdqu+_cLojadqu == ZGQ->(ZGQ_FILIAL+ZGQ_FILFAT+ZGQ_LOCEMB+ZGQ_CLIENT+ZGQ_LOJA)

       If ZGQ->ZGQ_ATIVA = "N"  
         
          ZGQ->(Dbskip())
          Loop
       
       ElseIf !Empty(ZGQ->ZGQ_SEGCLI+; // Seguimento do Cliente (A1_I_GRCLI)
                     ZGQ->ZGQ_REDE  +; // Rede do Cliente
                     ZGQ->ZGQ_GEREN +; // Gerente do vendedor (A3_GEREN)
                     ZGQ->ZGQ_UFPEDV+; // UF do Cliente -A1_EST
                     ZGQ->ZGQ_COORDE+; // Coordenador do vendedor (A3_SUPER)
                     ZGQ->ZGQ_SUPERV+; // Supervisor do vendedor  (A3_I_SUPE)
                     ZGQ->ZGQ_VENDED ) // C�digo do Vendedor Informado 
         
             ZGQ->(Dbskip())
             Loop

         Elseif !(DA0->(Dbseek(xfilial("DA0")+ZGQ->ZGQ_TABPRE)))
             
             ZGQ->(Dbskip())
             Loop
             
         Elseif DA0->DA0_ATIVO == '2' //Tabela inativa
             
             ZGQ->(Dbskip())
             Loop
             
         Elseif DA0->DA0_DATDE > DATE() .OR. DA0->DA0_DATATE < DATE()
             
             ZGQ->(Dbskip())
             Loop
             
         Endif
         
         _cRegra1   := "Regra por Adquirente da Opera��o Triangular " +_cCliAdqu + "-" + _cLojadqu + "("+_cFilFatura+_cLocalEmb+")"
         _cTabDireta:= ZGQ->ZGQ_TABPRE
         _nRecno    := ZGQ->(Recno())
         _cGrupoP   := ZGQ->ZGQ_GRUPOP
         _cUFPedV   := ZGQ->ZGQ_UFPEDV
                 
         EXIT
 
    Enddo
 
    IF EMPTY(_cTabDireta)
       //      //   1   2   3   4   5     6
       _aret  := {"   ",0,"   ",0,"   ","   "}
       cfilant:= _cfilori
       Return _aRet
    EndIf

 EndIF

 //**************************
 //     TERCEIRA BUSCA    //
 //**************************
 If Empty(_cTabDireta)
     _cTabDireta := Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLojaCli,"A1_TABELA")  
    If ZGQ->ZGQ_ATIVA = "N" .OR. !(DA0->(Dbseek(xfilial("DA0")+_cTabDireta))) .OR. DA0->DA0_ATIVO = '2' .OR. DA0->DA0_DATDE > DATE() .OR. DA0->DA0_DATATE < DATE()//Tabela inativa
       _cTabDireta:= ""
    Else
       _cRegra1   := "Regra por Cliente " +_cCliente + "-" + _cLojaCli
    EndIf
 ENDIF 
  
 //***** NOVA REGRA DE BUSCA DO ZGQ ***************************************************************************************************//
 If _lRegraNova .And. Empty(Alltrim(_cTabDireta)) //LOCALIZAR A TABELA DE PRE�O UTILIZANDO O CADASTRO DE REGRAS DE TABELA DE PRE�O
    //********************************************************************************************************************************//
    //***********************//
    //     QUARTA BUSCA      //
    //***********************//
    _cSegCli:=Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLojaCli,"A1_I_GRCLI")//SEGUIMENTO DO CLIENTE
    _cUF:=SA1->A1_EST//Estado DO CLIENTE

    _aCposBusca:={_cFilFatura,_cLocalEmb,_cCliente,_cLojaCli,_cSegCli,_cRede,_cGeren,_cUF,_cCoord,_cSuper,_cVend}

    _ctab:=BuscaTabPreco(_aCposBusca,@_cRegra, @_nRecno, @_cGrupoP, @_cUFPedV)//QUARTA BUSCA

    //***** REGRA ANTERIOR DE BUSCA DO ZGQ ******************************************************************************************************//
 ElseIf ( ( U_ItGetMv("IT_TABPRG",.F.)) .And. Empty(Alltrim(_cTabDireta)) )  // Carrega tabela de regras se o parametro de regras estiver ativo
    //*******************************************************************************************************************************************//
    _aDadosZGQ := {}
    _cGrupoP := ""
    _cUFPedV := ""
 
     // Carrega array _aDadosZGQ com as regras de tabela de pre�os ativas.
     DA0->(Dbsetorder(1))
     ZGQ->(Dbsetorder(1))
     ZGQ->(Dbgotop())
     
     Do while .not. ZGQ->(Eof()) 
         
         //Valida validade da tabela da regra posicionada, se for inv�lida pula a an�lise
         
         _cfilda0 := iif(empty(ZGQ->ZGQ_FILFAT),ZGQ->ZGQ_FILEMB,ZGQ->ZGQ_FILFAT)
         
         If !(DA0->(Dbseek(xfilial("DA0")+ZGQ->ZGQ_TABPRE)))
             
             ZGQ->(Dbskip())
             Loop
             
         Elseif DA0->DA0_ATIVO == '2' //Tabela inativa
             
             ZGQ->(Dbskip())
             Loop
             
         Elseif DA0->DA0_DATDE > DATE() .OR. DA0->DA0_DATATE < DATE()
             
             ZGQ->(Dbskip())
             Loop
             
         Endif
         
         If Alltrim(_cFilCarreg) == Alltrim(ZGQ->ZGQ_FILFAT)
           Aadd(_aDadosZGQ, {ZGQ->ZGQ_FILEMB,; // - Filial de Embarque     - 01
                             ZGQ->ZGQ_TABPRE,; // - Tabela de Preco        - 02
                             ZGQ->ZGQ_FILFAT,; // - Filial de Faturamento  - 03
                             ZGQ->ZGQ_GEREN ,; // - Gerente                - 04
                             ZGQ->ZGQ_COORDE,; // - Coordenador            - 05
                             ZGQ->ZGQ_SUPERV,; // - Supervisor             - 06
                             ZGQ->ZGQ_VENDED,; // - Vendedor               - 07
                             ZGQ->ZGQ_REDE  ,; // - Rede                   - 08
                             ZGQ->ZGQ_CLIENT,; // - Cliente                - 09
                             ZGQ->ZGQ_LOJA,;   // - Loja                   - 10
                             ZGQ->(Recno()),;  // - Recno do Registro      - 11
                             ZGQ->ZGQ_GRUPOP,; // - Grupo do Produto       - 12
                             ZGQ->ZGQ_UFPEDV}) // - UF do Pedido de Vendas - 13
         EndIf

         ZGQ->(Dbskip())
 
     Enddo
     
     _cRegra1 := ""
     _cRegra2 := ""
     _cRegra3 := ""
     _cRegra4 := ""
     _cRegra5 := ""
     _cRegra6 := ""
     _cRegra7 := ""
     
     _cTabPre1 := ""
     _cTabPre2 := ""
     _cTabPre3 := ""
     _cTabPre4 := ""
     _cTabPre5 := ""
     _cTabPre6 := ""
     _cTabPre7 := ""
     
     _cGrupoP1 := ""
     _cGrupoP2 := ""
     _cGrupoP3 := ""
     _cGrupoP4 := ""
     _cGrupoP5 := ""
     _cGrupoP6 := ""
     _cGrupoP7 := ""
     
     _cUFPedV1 := ""
     _cUFPedV2 := ""
     _cUFPedV3 := ""
     _cUFPedV4 := ""
     _cUFPedV5 := ""
     _cUFPedV6 := ""
     _cUFPedV7 := ""
     
     //==========================================================================================
     // Com base nos parâmetros passados para a fun��o ITTABPRC, determina a regras da tabela de
     // pre�o.
     //------------------------------------------------------------------------------------------
     // Neste trecho n�oo considera o grupo de produtos.
     //==========================================================================================
     For _nI := 1 To Len(_aDadosZGQ)
        //======================================================================================
        // _cRegra := "Regra de Filial de Faturamento " + _cFilFatura   // 1
        //======================================================================================
        If (!Empty(_cFilFatura)      .And. _aDadosZGQ[_nI,3] == _cFilFatura) .And.;// - Filial de Faturamento  - 3
             Empty(_aDadosZGQ[_nI,4]) .And. ;                                       // - Gerente                - 4
             Empty(_aDadosZGQ[_nI,5]) .And. ;                                       // - Coordenador            - 5
             Empty(_aDadosZGQ[_nI,6]) .And. ;                                       // - Supervisor             - 6
             Empty(_aDadosZGQ[_nI,7]) .And. ;                                       // - Vendedor               - 7
             Empty(_aDadosZGQ[_nI,8]) .And. ;                                       // - Rede                   - 8
             Empty(_aDadosZGQ[_nI,9]) .And. ;                                       // - Cliente                - 9
             Empty(_aDadosZGQ[_nI,10])                                              // - Loja                   - 10
             
             _cRegra1  := "Regra de Filial de Faturamento " + _cFilFatura
             _cTabPre1 := _aDadosZGQ[_nI,2]                                         // - Tabela de Preço        - 2
             _nRecno1  := _aDadosZGQ[_nI,11]                                        // - Recno do Registro      - 11
             _cGrupoP1 := _aDadosZGQ[_nI,12]                                        // - Grupo de Produtos      - 12
             _cUFPedV1 := _aDadosZGQ[_nI,13]                                        // - UF do Pedido de Vendas - 13
             
        EndIf
         
         //========================================================================================
         // _cRegra := "Regra de Filial de Faturamento " + _cFilFatura + " e gerente " + _cGeren // 2
         //========================================================================================
         If (!Empty(_cFilFatura)      .And. _aDadosZGQ[_nI,3] == _cFilFatura) .And. ;  // - Filial de Faturamento  - 3
             (!Empty(_cGeren)         .And. _aDadosZGQ[_nI,4] == _cGeren)  .And. ;  // - Gerente                - 4
             Empty(_aDadosZGQ[_nI,5]) .And. ;                                       // - Coordenador            - 5
             Empty(_aDadosZGQ[_nI,6]) .And. ;                                       // - Supervisor             - 6
             Empty(_aDadosZGQ[_nI,7]) .And. ;                                       // - Vendedor               - 7
             Empty(_aDadosZGQ[_nI,8]) .And. ;                                       // - Rede                   - 8
             Empty(_aDadosZGQ[_nI,9]) .And. ;                                       // - Cliente                - 9
             Empty(_aDadosZGQ[_nI,10])                                              // - Loja                   - 10
             
             _cRegra2  := "Regra de Filial de Faturamento " + _cFilFatura + " e gerente " + _cGeren // 2
             _cTabPre2 := _aDadosZGQ[_nI,2]                                         // - Tabela de Preço        - 2
             _nRecno2  := _aDadosZGQ[_nI,11]                                        // - Recno do Registro      - 11
             _cGrupoP2 := _aDadosZGQ[_nI,12]                                        // - Grupo de Produtos      - 12
             _cUFPedV2 := _aDadosZGQ[_nI,13]                                        // - UF do Pedido de Vendas - 13
         EndIf
         
         //=====================================================================================================================
         // _cRegra := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + " e coordenador " + _cCoord // 3
         //=====================================================================================================================
         If (!Empty(_cFilFatura)      .And. _aDadosZGQ[_nI,3] == _cFilFatura) .And. ;  // - Filial de Faturamento  - 3
             (!Empty(_cGeren)         .And. _aDadosZGQ[_nI,4] == _cGeren)  .And. ;  // - Gerente                - 4
             (!Empty(_cCoord)         .And. _aDadosZGQ[_nI,5] == _cCoord)  .And. ;  // - Coordenador            - 5
             Empty(_aDadosZGQ[_nI,6]) .And. ;                                       // - Supervisor             - 6
             Empty(_aDadosZGQ[_nI,7]) .And. ;                                       // - Vendedor               - 7
             Empty(_aDadosZGQ[_nI,8]) .And. ;                                       // - Rede                   - 8
             Empty(_aDadosZGQ[_nI,9]) .And. ;                                       // - Cliente                - 9
             Empty(_aDadosZGQ[_nI,10])                                              // - Loja                   - 10
             
             _cRegra3  := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + " e coordenador " + _cCoord // 3
             _cTabPre3 := _aDadosZGQ[_nI,2]                                         // - Tabela de Preço        - 2
             _nRecno3  := _aDadosZGQ[_nI,11]                                        // - Recno do Registro      - 11
             _cGrupoP3 := _aDadosZGQ[_nI,12]                                        // - Grupo de Produtos      - 12
             _cUFPedV3 := _aDadosZGQ[_nI,13]                                        // - UF do Pedido de Vendas - 13
         EndIf
         
         //====================================================================================================================================================================
         // _cRegra := "Regra de Filial de Filial de faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + " e supervisor " + ZGQ->ZGQ_SUPERV // 4
         //====================================================================================================================================================================
         If (!Empty(_cFilFatura)      .And. _aDadosZGQ[_nI,3] == _cFilFatura) .And. ; // - Filial de Faturamento  - 3
             (!Empty(_cGeren)         .And. _aDadosZGQ[_nI,4] == _cGeren)  .And. ;    // - Gerente                - 4
             (!Empty(_cCoord)         .And. _aDadosZGQ[_nI,5] == _cCoord)  .And. ;    // - Coordenador            - 5
             (!Empty(_cSuper)         .And. _aDadosZGQ[_nI,6] == _cSuper)  .And. ;    // - Supervisor             - 6
             Empty(_aDadosZGQ[_nI,7])        .And. ;                                  // - Vendedor               - 7
             Empty(_aDadosZGQ[_nI,8])        .And. ;                                  // - Rede                   - 8
             Empty(_aDadosZGQ[_nI,9])        .And. ;                                  // - Cliente                - 9
             Empty(_aDadosZGQ[_nI,10])                                                // - Loja                   - 10
             
             _cRegra4  := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + " e supervisor " + _cSuper
             _cTabPre4 := _aDadosZGQ[_nI,2]                                           // - Tabela de Preço        - 2
             _nRecno4  := _aDadosZGQ[_nI,11]                                          // - Recno do Registro      - 11
             _cGrupoP4 := _aDadosZGQ[_nI,12]                                          // - Grupo de Produtos      - 12
             _cUFPedV4 := _aDadosZGQ[_nI,13]                                          // - UF do Pedido de Vendas - 13
         EndIf
         
         //=================================================================================================================================================================================
         // _cRegra := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + ", supervisor " + ZGQ->ZGQ_SUPERV + " e vendedor " + _cVend //5
         //=================================================================================================================================================================================
         If (!Empty(_cFilFatura)      .And. _aDadosZGQ[_nI,3] == _cFilFatura) .And. ;       // - Filial de Faturamento  - 3
             (!Empty(_cGeren)         .And. _aDadosZGQ[_nI,4] == _cGeren)  .And. ;          // - Gerente                - 4
             (!Empty(_cCoord)         .And. _aDadosZGQ[_nI,5] == _cCoord)  .And. ;          // - Coordenador            - 5
             (_aDadosZGQ[_nI,6] == _cSuper)   .And. ;                                       // - Supervisor             - 6
             (!Empty(_cVend)                  .And. _aDadosZGQ[_nI,7] == _cVend)   .And. ;  // - Vendedor               - 7
             Empty(_aDadosZGQ[_nI,8])         .And. ;                                       // - Rede                   - 8
             Empty(_aDadosZGQ[_nI,9])         .And. ;                                       // - Cliente                - 9
             Empty(_aDadosZGQ[_nI,10])                                                      // - Loja                   - 10
             
             _cRegra5  := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + ", supervisor " +_cSuper + " e vendedor " + _cVend //5
             _cTabPre5 := _aDadosZGQ[_nI,2]                                                 // - Tabela de Preço        - 2
             _nRecno5  := _aDadosZGQ[_nI,11]                                                // - Recno do Registro      - 11
             _cGrupoP5 := _aDadosZGQ[_nI,12]                                                // - Grupo de Produtos      - 12
             _cUFPedV5 := _aDadosZGQ[_nI,13]                                                // - UF do Pedido de Vendas - 13
         EndIf
         
         //==============================================================================================================================================================================================
         // _cRegra := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + ", supervisor " + _cSuper + ", vendedor " + _cVend + " e rede " + _cRede // 6
         //==============================================================================================================================================================================================
         If (!Empty(_cFilFatura)      .And. _aDadosZGQ[_nI,3] == _cFilFatura) .And. ;      // - Filial de Faturamento  - 3
             (!Empty(_cGeren)         .And. _aDadosZGQ[_nI,4] == _cGeren)  .And. ;         // - Gerente                - 4
             Empty(_aDadosZGQ[_nI,5]) .And. ;                                              // - Coordenador            - 5
             Empty(_aDadosZGQ[_nI,6]) .And. ;                                              // - Supervisor             - 6
             Empty(_aDadosZGQ[_nI,7]) .And. ;                                              // - Vendedor               - 7
             (!Empty(_cRede)          .And. _aDadosZGQ[_nI,8] == _cRede)   .And. ;         // - Rede                   - 8
             Empty(_aDadosZGQ[_nI,9]) .And. ;                                              // - Cliente                - 9
             Empty(_aDadosZGQ[_nI,10])                                                     // - Loja                   - 10
             
             _cRegra6  := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + ", supervisor " + _cSuper + ", vendedor " + _cVend + " e rede " + _cRede // 6
             _cTabPre6 := _aDadosZGQ[_nI,2]                                                // - Tabela de Preço        - 2
             _nRecno6  := _aDadosZGQ[_nI,11]                                               // - Recno do Registro      - 11
             _cGrupoP6 := _aDadosZGQ[_nI,12]                                               // - Grupo de Produtos      - 12
             _cUFPedV6 := _aDadosZGQ[_nI,13]                                               // - UF do Pedido de Vendas - 13
         EndIf
 
         //==========================================================================================================================================================================================================================================================
         // _cRegra := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + ", supervisor " + ZGQ->ZGQ_SUPERV + ", vendedor " + _cVend + ", rede " + ZGQ->ZGQ_REDE + " e cliente " + _cCliente + "/" + _cLojaCli // 7
         //==========================================================================================================================================================================================================================================================
         If (!Empty(_cFilFatura) .And. _aDadosZGQ[_nI,3] == _cFilFatura)  .And. ;            // - Filial de Faturamento  - 3
             (!Empty(_cGeren)    .And. _aDadosZGQ[_nI,4] == _cGeren)   .And. ;               // - Gerente                - 4
             (!Empty(_cCoord)    .And. _aDadosZGQ[_nI,5] == _cCoord)   .And. ;               // - Coordenador            - 5
             (_aDadosZGQ[_nI,6] == _cSuper)   .And. ;                                        // - Supervisor             - 6
             (!Empty(_cVend)                  .And. _aDadosZGQ[_nI,7] == _cVend)    .And. ;  // - Vendedor               - 7
             (!Empty(_cRede)                  .And. _aDadosZGQ[_nI,8] == _cRede)    .And. ;  // - Rede                   - 8
             (!Empty(_cCliente)               .And. _aDadosZGQ[_nI,9] == _cCliente) .And. ;  // - Cliente                - 9
             (!Empty(_cLojaCli)               .And. _aDadosZGQ[_nI,10] == _cLojaCli)         // - Loja                   - 10
             
             _cRegra7  := "Regra de Filial de Faturamento " + _cFilFatura + ", gerente " + _cGeren + ", coordenador " + _cCoord + ", supervisor " + _cSuper + ", vendedor " + _cVend + ", rede " + _cRede + " e cliente " + _cCliente + "/" + _cLojaCli // 7
             _cTabPre7 := _aDadosZGQ[_nI,2]                                                  // - Tabela de Preço        - 2
             _nRecno7  := _aDadosZGQ[_nI,11]                                                 // - Recno do Registro      - 11
             _cGrupoP7 := _aDadosZGQ[_nI,12]                                                 // - Grupo de Produtos      - 12
             _cUFPedV7 := _aDadosZGQ[_nI,13]                                                 // - UF do Pedido de Vendas - 13
         EndIf
     Next _nI
       
     If ! Empty(_cTabPre7)
         _ctab    := _cTabPre7
         _nRecno  := _nRecno7
         _cRegra  := "7-" + _cRegra7
         _cGrupoP := _cGrupoP7
         _cUFPedV := _cUFPedV7
     ElseIf ! Empty(_cTabPre6)
         _ctab    := _cTabPre6
         _nRecno  := _nRecno6
         _cRegra  := "6-" + _cRegra6
         _cGrupoP := _cGrupoP6
         _cUFPedV := _cUFPedV6
     ElseIf ! Empty(_cTabPre5)
         _ctab    := _cTabPre5
         _nRecno  := _nRecno5
         _cRegra  := "5-" + _cRegra5
         _cGrupoP := _cGrupoP5
         _cUFPedV := _cUFPedV5
     ElseIf ! Empty(_cTabPre4)
         _ctab    := _cTabPre4
         _nRecno  := _nRecno4
         _cRegra  := "4-" + _cRegra4
         _cGrupoP := _cGrupoP4
         _cUFPedV := _cUFPedV4
     ElseIf ! Empty(_cTabPre3)
         _ctab    := _cTabPre3
         _nRecno  := _nRecno3
         _cRegra  :="3-" +  _cRegra3
         _cGrupoP := _cGrupoP3
         _cUFPedV := _cUFPedV3
     ElseIf ! Empty(_cTabPre2)
         _ctab    := _cTabPre2
         _nRecno  := _nRecno2
         _cRegra  := "2-" + _cRegra2
         _cGrupoP := _cGrupoP2
         _cUFPedV := _cUFPedV2
     ElseIf ! Empty(_cTabPre1)
         _ctab    := _cTabPre1
         _nRecno  := _nRecno1
         _cRegra  := "1-" + _cRegra1
         _cGrupoP := _cGrupoP1
         _cUFPedV := _cUFPedV1
     EndIf
 Else
    _ctab  :=Alltrim(_cTabDireta)
    _cRegra:=Alltrim(_cRegra1)
 EndIf 
 
 End Sequence
 
 If _lRegraNova 
     _cRegraFatC:=""
    _nFatMinPrc := BuscaFatComercial(_cFilFatura, _cUFPedV, , _cGrupoP, @_cRegraFatC) // Carrega fator de convers�o para calculo do maior pre�os de vendas.U_ItGetMv("IT_FATMINPR",1) // CARREGA FATOR DE CONVERSAO PARA CALCULO DO MAIOR PRECOS DE VENDAS.
 Else 
    _nFatMinPrc := U_ItGetMv("IT_FATMINPR",1) // CARREGA FATOR DE CONVERSAO PARA CALCULO DO MAIOR PRECOS DE VENDAS.
 Endif
 
 //     //   1       2        3         4           5          6
 _aret := {_ctab, _nRecno, _cRegra, _nFatMinPrc, _cGrupoP, _cUFPedV}
 
 cfilant := _cfilori

Return _aRet

/*
===============================================================================================================================
Programa----------: BuscaTabPreco
Autor-------------: Alex Wallauer
Data da Criacao---: 07/01/2025
Descri��o---------: Nova Busca de Tabela de pre�o
Parametros--------: _aCposBusca.: Array com os dados da busca: {_cFilFat,_cLocEmb,_cClient,_cLoja,_cSegCli,_cRede,_cGeren,_cUF,_cCoorde,_cSuperv,_cVended}
                    @_cRegra....: Grava a Regra usada
                    @_nRecno....: Grava o Recno usado
                    @_cGrupoP...: Grava o Grupo usado
                    @_cUFPedV...: Grava a UF usada
Retorno-----------: _cTabDireta.: Tabela de Pre�o
===============================================================================================================================
*/  
Static Function BuscaTabPreco(_aCposBusca As Array, _cRegra As Char, _nRecno  As Char, _cGrupoP As Char, _cUFPedV As Char)
 LOCAL _aRegras   := {} As Array
 LOCAL _aOrdBusca := {} As Array , A As Numeric
 LOCAL _cB_Client := SPACE(LEN(ZGQ->ZGQ_CLIENT )) As Char
 LOCAL _cB_Loja   := SPACE(LEN(ZGQ->ZGQ_LOJA   )) As Char
 LOCAL _cB_SegCli := SPACE(LEN(ZGQ->ZGQ_SEGCLI )) As Char
 LOCAL _cB_Rede   := SPACE(LEN(ZGQ->ZGQ_REDE   )) As Char
 LOCAL _cB_Geren  := SPACE(LEN(ZGQ->ZGQ_GEREN  )) As Char
 LOCAL _cB_UF     := SPACE(LEN(ZGQ->ZGQ_UFPEDV )) As Char
 LOCAL _cB_Coorde := SPACE(LEN(ZGQ->ZGQ_COORDE )) As Char
 LOCAL _cB_Superv := SPACE(LEN(ZGQ->ZGQ_SUPERV )) As Char
 LOCAL _cB_Vended := SPACE(LEN(ZGQ->ZGQ_VENDED )) As Char
 LOCAL _cFilFat   := _aCposBusca[01]              As Char
 LOCAL _cLocEmb   := _aCposBusca[02]              As Char
 LOCAL _cClient   := _aCposBusca[03]              As Char
 LOCAL _cLoja     := _aCposBusca[04]              As Char
 LOCAL _cSegCli   := _aCposBusca[05]              As Char
 LOCAL _cRede     := _aCposBusca[06]              As Char
 LOCAL _cGeren    := _aCposBusca[07]              As Char
 LOCAL _cUF       := _aCposBusca[08]              As Char
 LOCAL _cCoorde   := _aCposBusca[09]              As Char
 LOCAL _cSuperv   := _aCposBusca[10]              As Char
 LOCAL _cVended   := _aCposBusca[11]              As Char
 LOCAL _cTabDireta:= "   " As Char
 
 // 01 - C�digo do Cliente  + C�digo da Loja do Cliente 
 // INDICE:     ,ZGQ_CLIENT  +ZGQ_LOJA  +ZGQ_SEGCLI  +ZGQ_REDE  +ZGQ_GEREN  +ZGQ_UFPEDV  +ZGQ_COORDE +ZGQ_SUPERV  + ZGQ_VENDED
 AADD(_aOrdBusca, _cClient   + _cLoja   + _cB_SegCli + _cB_Rede + _cB_Geren + _cB_UF +_cB_Coorde + _cB_Superv + _cB_Vended )// REGRA 01
 AADD(_aRegras, "Regra por Cliente + Loja: " + _cClient + " + " + _cLoja)
 
 // 02 - C�digo da Rede do Cliente (A1_GRPVEN) + Gerente do vendedor (A3_GEREN) + Estado do Cliente (A1_EST)
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cB_SegCli + _cRede + _cGeren + _cUF   +_cB_Coorde + _cB_Superv + _cB_Vended )// REGRA 02
 AADD(_aRegras, "Regra por Gerente + Rede +  Estado: " +_cRede+" + " +_cGeren+" + "+ _cUF)
 
 // 03 - C�digo da Rede do Cliente (A1_GRPVEN) + Gerente do vendedor (A3_GEREN)
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cB_SegCli + _cRede   + _cGeren   + _cB_UF +_cB_Coorde + _cB_Superv + _cB_Vended )// REGRA 03
 AADD(_aRegras, "Regra por Gerente + Rede: " + _cRede+" + " +_cGeren)
  
 // 04 - Estado do Cliente (A1_EST) 
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cB_SegCli + _cB_Rede + _cB_Geren + _cUF   +_cB_Coorde + _cB_Superv + _cB_Vended )// REGRA 04
 AADD(_aRegras, "Regra por Estado do Cliente: " + _cUF)
 
 // 05 - Segmento do cliente (A1_I_GRCLI) + Estado do Cliente (A1_EST)
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cSegCli + _cB_Rede + _cB_Geren + _cUF   +_cB_Coorde + _cB_Superv + _cB_Vended )// REGRA 05
 AADD(_aRegras, "Regra por Segmento + Estado: " + _cSegCli+" + "+ _cUF)
 
 // 06 - Gerente do vendedor (A3_GEREN) + Coordenador do vendedor (A3_SUPER) + Supervisor do vendedor (A3_I_SUPE) 
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cSegCli + _cB_Rede + _cB_Geren   + _cB_UF +_cB_Coorde + _cB_Superv + _cB_Vended )// REGRA 06
 AADD(_aRegras, "Regra por Segmento: " + _cSegCli)
 
 // 07 - Gerente do vendedor (A3_GEREN) + Coordenador do vendedor (A3_SUPER) + Supervisor do vendedor (A3_I_SUPE) + C�digo do Vendedor 
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cB_SegCli + _cB_Rede + _cGeren   + _cB_UF +_cCoorde + _cSuperv + _cVended)// REGRA 07
 AADD(_aRegras, "Regra por Gerente + Coordenador + Supervisor + Vendedor: " + _cGeren+" + "  +_cCoorde+" + "   + _cSuperv+" + " + _cVended)
 
 // 08 - Gerente do vendedor (A3_GEREN) + Coordenador do vendedor (A3_SUPER) + Supervisor do vendedor (A3_I_SUPE) + C�digo do Vendedor 
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cB_SegCli + _cB_Rede + _cGeren   + _cB_UF +_cCoorde + _cSuperv + _cB_Vended)// REGRA 08
 AADD(_aRegras, "Regra por Gerente + Coordenador + Supervisor: " + _cGeren+" + "  +_cCoorde+" + "+ _cSuperv)
 
 // 09 - Gerente do vendedor (A3_GEREN) + Coordenador do vendedor (A3_SUPER) 
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cB_SegCli + _cB_Rede + _cGeren   + _cB_UF +_cCoorde   + _cB_Superv + _cB_Vended )// REGRA 09
 AADD(_aRegras, "Regra por Gerente + Coordenador: " + _cGeren+" + "  +_cCoorde)

 // 10 - Gerente do vendedor (A3_GEREN)
 AADD(_aOrdBusca, _cB_Client + _cB_Loja + _cB_SegCli + _cB_Rede + _cGeren + _cB_UF +_cB_Coorde + _cB_Superv + _cB_Vended )// REGRA 10
 AADD(_aRegras,	"Regra por Gerente do Vendedor " + _cGeren)
 
 ZGQ->(DBSETORDER(4))//ZGQ_FILIAL+ZGQ_FILFAT+ZGQ_LOCEMB+ZGQ_CLIENT+ZGQ_LOJA+ZGQ_SEGCLI+ZGQ_REDE+ZGQ_GEREN+ZGQ_UFPEDV+ZGQ_COORDE+ZGQ_SUPERV+ZGQ_VENDED
 FOR A := 1 TO LEN(_aOrdBusca)
 
     ZGQ->(Dbseek(xfilial()+_cFilFat+_cLocEmb+_aOrdBusca[A]))
      
      Do While .not. ZGQ->(Eof()) .AND. xfilial("ZGQ")+_cFilFat+_cLocEmb == ZGQ->(ZGQ_FILIAL+ZGQ_FILFAT+ZGQ_LOCEMB);
                                 .AND. _aOrdBusca[A] == ZGQ->(ZGQ_CLIENT+ZGQ_LOJA+ZGQ_SEGCLI+ZGQ_REDE+ZGQ_GEREN+ZGQ_UFPEDV+ZGQ_COORDE+ZGQ_SUPERV+ZGQ_VENDED)
 
         If ZGQ->ZGQ_ATIVA = "N"  //Tabela inativa
          
              ZGQ->(Dbskip())
              Loop
 
          Elseif !(DA0->(Dbseek(xfilial("DA0")+ZGQ->ZGQ_TABPRE)))
              
              ZGQ->(Dbskip())
              Loop
              
          Elseif DA0->DA0_ATIVO = '2' //Tabela inativa
              
              ZGQ->(Dbskip())
              Loop
              
          Elseif DA0->DA0_DATDE > DATE() .OR. DA0->DA0_DATATE < DATE()
              
              ZGQ->(Dbskip())
              Loop
              
          Endif
          
          _cRegra    := _aRegras[A]+ " ("+_cFilFat+_cLocEmb+")" 
          _cTabDireta:= ZGQ->ZGQ_TABPRE
          _nRecno    := ZGQ->(Recno())
          _cGrupoP   := ZGQ->ZGQ_GRUPOP
          _cUFPedV   := ZGQ->ZGQ_UFPEDV
                  
          EXIT
  
      Enddo
 
 NEXT A
 
 ZGQ->(DBSETORDER(1))

RETURN _cTabDireta

/*
================================================================================================================================
Programa--------: IvldDA1
Autor-----------: Darcio Ribeiro Sp�rl
Data da Criacao-: 05/07/2016
===============================================================================================================================
Descri��o-------: Fun��o para valida��o dos itens da tabela de pre�o
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _lRet - .T. deixa completar a altera��o, .F. caso contr�rio.
===============================================================================================================================
*/
User Function IvldDA1()
    Local _aArea		:= GetArea()
    Local _lRet			:= .T.
    Local _cQuery		:= ""
    Local _cQryDA1		:= ""
    Local _cQryPRO		:= ""
    Local _nTotReg		:= Len(aCols)
    Local _oModel		:= FWModelActive()
    Local _oModelDA0	:= _oModel:GetModel( 'DA0MASTER' )
    Local _nPosTab		:= aScan(_oModelDA0:ADATAMODEL[1], {|x| AllTrim(x[1]) == "DA0_CODTAB"})
    Local _nPosIte		:= aScan(aHeader, {|x| AllTrim(x[2]) == "DA1_ITEM"})
    Local _nPosPro		:= aScan(aHeader, {|x| AllTrim(x[2]) == "DA1_CODPRO"})

//==============================================
// Verifica se a tabela est� com filtro aplicado
//==============================================
    _cQuery := "SELECT COUNT(*) DA1_TOTREG "
    _cQuery += "FROM " + RetSqlName("DA1") + " "
    _cQuery += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
    _cQuery += "  AND DA1_CODTAB = '" + _oModelDA0:ADATAMODEL[1][_nPosTab][2] + "' "
    _cQuery += "  AND D_E_L_E_T_ = ' ' "

    MPSysOpenQuery(_cQuery,"TRBDA1")
    TRBDA1->(dbGoTop())

    If _nTotReg < TRBDA1->DA1_TOTREG

        Help( ,, 'Aten��o! XFUNOMS - IvldDA1',, "N�o � permitida altera��o na tabela de pre�o filtrada.",1,0,, ,,, , {"Favor tirar o filtro da tabela"} )

        _lRet := .F.
    Else
        //=============================================
        // verifica se o item existe na tabela de pre�o
        //=============================================
        _cQryDA1 := "SELECT COUNT(DA1_CODTAB) DA1_TOTTAB "
        _cQryDA1 += "FROM " + RetSqlName("DA1") + " "
        _cQryDA1 += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
        _cQryDA1 += "  AND DA1_CODTAB = '" + _oModelDA0:ADATAMODEL[1][_nPosTab][2] + "' "
        _cQryDA1 += "  AND DA1_ITEM = '" + aCols[n][_nPosIte] + "' "
        _cQryDA1 += "  AND D_E_L_E_T_ = ' ' "

        MPSysOpenQuery(_cQryDA1,"TRBDAA")
        TRBDAA->(dbGoTop())

        If TRBDAA->DA1_TOTTAB > 0

            Help( ,, 'Aten��o! XFUNOMS - IvldDA1',, "N�o � permitida altera��o do item.",1,0,, ,,, , {"Favor inclua um item novo."} )

            _lRet := .F.

        Else
            //================================================
            // Verifica se o produto existe na tabela de pre�o
            //================================================
            _cQryPRO := "SELECT COUNT(DA1_CODPRO) DA1_TOTPRO "
            _cQryPRO += "FROM " + RetSqlName("DA1") + " "
            _cQryPRO += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
            _cQryPRO += "  AND DA1_CODTAB = '" + _oModelDA0:ADATAMODEL[1][_nPosTab][2] + "' "
            _cQryPRO += "  AND DA1_CODPRO = '" + aCols[n][_nPosPro] + "' "
            _cQryPRO += "  AND D_E_L_E_T_ = ' ' "

            MPSysOpenQuery(_cQryPRO,"TRBPRO")
            TRBPRO->(dbGoTop())

            If TRBPRO->DA1_TOTPRO > 0

                Help( ,, 'Aten��o! XFUNOMS - IvldDA1',, "O produto informado j� existe nesta tabela de pre�o.",1,0,, ,,, , {"Favor inclua um item novo."} )

                _lRet := .F.

            EndIf

            TRBPRO->(dbCloseArea())
        EndIf

        TRBDAA->(dbCloseArea())

    EndIf

    TRBDA1->(dbCloseArea())

    RestArea(_aArea)
Return(_lRet)

/*
================================================================================================================================
Programa--------: Nfoplog
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 24/04/2018
===============================================================================================================================
Descri��o-------: Detecta se nota vai por operador logistico e operador de redespacho.
===============================================================================================================================
Parametros------: _cfilial - filial da nota
                  _cnota - numero da nota
                  _serie - serie da nota
===============================================================================================================================
Retorno---------: _lRet - se a nota vai por operador logistico ou n�o
===============================================================================================================================
*/
User Function Nfoplog(_cfilial,_cnota,_cserie)

Local _lret := .F.

DAI->(Dbsetorder(3))

If DAI->(Dbseek(_cfilial+_cnota+_cserie))

    If DAI->DAI_I_OPER == '1' .Or. DAI->DAI_I_REDP == '1' // Considerar operador logistico e operador de redespacho.

       _lret := .T.

       IF !EMPTY(DAI->DAI_I_OPLO)
          _cCodOL :=DAI->DAI_I_OPLO
          _cLojaOP:=DAI->DAI_I_LOPL
       ELSE
          _cCodOL :=DAI->DAI_I_TRED
          _cLojaOP:=DAI->DAI_I_LTRE
       ENDIF

    Endif

Endif

Return _lret

/*
===============================================================================================================================
Programa----------: TelCred
Autor-------------: Josu� Danich
Data da Criacao---: 13/08/2018
===============================================================================================================================
Descri��o---------: Tela de an�lise de cr�dito do prospect
===============================================================================================================================
Parametros--------: _nmodo - 1 Chamado da tela de prospect
                             2 Chamado de telas com cliente j� cadastrado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function TelCred(_nmodo)

    Local oFecha
    Local oFolder1
    Local oGet1
    Local oGet10
    Local oGet11
    Local oGet12
    Local oGet13
    Local oGet14
    Local oGet15
    Local oGet16
    Local oGet17
    Local oGet18
    Local oGet2
    Local oGet3
    Local oGet4
    Local oGet5
    Local oGet6
    Local oGet7
    Local oGet8
    Local oGet9
    Local oGroup1
    Local oGroup2
    Local oGroup3
    Local oGroup4
    Local oGroup6
    Local oSay1
    Local oSay10
    Local oSay11
    Local oSay12
    Local oSay13
    Local oSay14
    Local oSay15
    Local oSay16
    Local oSay17
    Local oSay18
    Local oSay2
    Local oSay21
    Local oSay22
    Local oSay24
    Local oSay25
    Local oSay26
    Local oSay27
    Local oSay28
    Local oSay3
    Local oSay4
    Local oSay44
    Local oSay5
    Local oSay6
    Local oSay7
    Local oSay8
    Local oSay9
    Local oWBrowse1
    Local oWBrowse2
    Local oWBrowse3

    Private aWBrowse1 := {}
    Private aWBrowse2 := {}
    Private aWBrowse3 := {}
    Private _ccnpj := ""
    Private _cnome := ""
    Private _crazao := ""
    Private _cdata := ""
    Private _cender := ""
    Private _cbairro := ""
    Private _ccidade := ""
    Private _ctelefone := ""
    Private _cdata2 := ""
    Private _cassoc := ""
    Private _cObs := ""
    Private _ccnae := ""
    Private _csitrec := ""
    Private _cdtrec := ""
    Private _cdtcrec := ""
    Private _cinsc := ""
    Private _csitst := ""
    Private _cdtst := ""
    Private _cdtcst := ""
    Private _csimples := ""
    Private _cdtsimp := ""
    Private _cdtcsimp :=  ""
    Private	_ccheques
    Private _cprotes
    Private _cdcheques:= ""
    Private cdebatu
    Private cvenc5
    Private cvenc15
    Private cvenc30
    Private ctotlim
    Private cmaior
    Private cVendas
    Private _cUfCli


    Private _llret
    Static oDlg

    If _nmodo == 1  //Chamado da tela de prospect

        _crazao  := SZX->ZX_NOME     //_cnome := SZX->ZX_NOME  
        _cnome   := SZX->ZX_NREDUZ 
        _ccnpj   := SZX->ZX_CGC
        _cpessoa := SZX->ZX_PESSOA
        _cinscr  := SZX->ZX_INSCR
        _cUfCli  := SZX->ZX_EST

    Else //Chamado de telas com cadastro de cliente j� efetuado

        _crazao  := SA1->A1_NOME     //_cnome := SA1->A1_NOME 
        _cnome   := SA1->A1_NREDUZ 
        _ccnpj   := SA1->A1_CGC
        _cpessoa := SA1->A1_PESSOA
        _cinscr  := SA1->A1_INSCR
        _cUfCli  := SA1->A1_EST

    Endif

//Faz consulta na Cisp
    fwmsgrun(,{|| _llret := u_ConCisp(_cnome,_ccnpj,_cpessoa,_cinscr, _cUfCli)},"Aguarde...","Consultando Cisp...")

/* Remover valida��o UF diferentes. Solicita��o Agnaldo.
    If right(_cinsc,2) != right(_ccidade,2)
 
        _cinsc := "UF da Inscri��o divergente!"
        _csitst := "Divergente"

    Endif
*/

//Apresenta resultado
    If _llret

        DEFINE MSDIALOG oDlg TITLE "An�lise de Cr�dito - " + alltrim(_cnome)  FROM 000, 000  TO 500, 1000 COLORS 0, 16777215 PIXEL

        @ 008, 007 FOLDER oFolder1 SIZE 483, 196 OF oDlg ITEMS "Resumo","Ratings","Positivas","Restri��es" COLORS 0, 16777215 PIXEL


        //Folder Resumo
        @ 002, 004 GROUP oGroup1 TO 169, 286 OF oFolder1:aDialogs[1] COLOR 0, 16777215 PIXEL
        @ 011, 006 SAY oSay1 PROMPT "CNPJ" SIZE 065, 006 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 024, 006 SAY oSay2 PROMPT "Raz�o social" SIZE 065, 009 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 036, 006 SAY oSay44 PROMPT "Nome Fantasia" SIZE 059, 012 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 049, 006 SAY oSay5 PROMPT "Data Funda��o" SIZE 101, 017 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 061, 006 SAY oSay6 PROMPT "Endere�o" SIZE 089, 014 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 074, 006 SAY oSay7 PROMPT "Bairro" SIZE 101, 015 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 086, 006 SAY oSay8 PROMPT "Cidade" SIZE 115, 017 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 099, 006 SAY oSay11 PROMPT "Telefone" SIZE 129, 017 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 111, 006 SAY oSay12 PROMPT "Data Cadastramento" SIZE 130, 013 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 124, 006 SAY oSay13 PROMPT "Ass Cadastrante" SIZE 132, 015 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 136, 006 SAY oSay14 PROMPT "Observa��es" SIZE 126, 014 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 001, 291 GROUP oGroup2 TO 066, 470 PROMPT "Receita Federal  " OF oFolder1:aDialogs[1] COLOR 0, 16777215 PIXEL
        @ 070, 291 GROUP oGroup3 TO 126, 470 PROMPT "Sintegra   " OF oFolder1:aDialogs[1] COLOR 0, 16777215 PIXEL
        @ 134, 291 GROUP oGroup4 TO 170, 470 PROMPT "Simples Nacional   " OF oFolder1:aDialogs[1] COLOR 0, 16777215 PIXEL
        @ 011, 077 MSGET oGet1 VAR _ccnpj WHEN .F. SIZE 060, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 024, 077 MSGET oGet2 VAR _crazao WHEN .F. SIZE 150, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 036, 077 MSGET oGet3 VAR _cnome WHEN .F. SIZE 150, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 049, 077 MSGET oGet4 VAR _cdata WHEN .F. SIZE 060, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 061, 077 MSGET oGet5 VAR _cender WHEN .F. SIZE 150, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 074, 077 MSGET oGet6 VAR _cbairro WHEN .F. SIZE 150, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 086, 077 MSGET oGet7 VAR _ccidade WHEN .F. SIZE 150, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 099, 077 MSGET oGet8 VAR _ctelefone WHEN .F. SIZE 060, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 111, 077 MSGET oGet9 VAR _cdata2 WHEN .F. SIZE 060, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 124, 077 MSGET oGet10 VAR _cassoc WHEN .F. SIZE 060, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 136, 077 MSGET oGet11 VAR _cObs WHEN .F. SIZE 200, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL

        @ 146, 296 SAY oSay3 PROMPT _csimples SIZE 166, 009 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 157, 296 SAY oSay4 PROMPT iif(empty(_cdtsimp)," ","DATA SIMPLES: ") + _cdtsimp +  " - DATA CONS. " + _cdtcsimp SIZE 167, 009 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 085, 296 SAY oSay9 PROMPT "INSC ESTADUAL " + _cinsc  SIZE 168, 008 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 098, 296 SAY oSay10 PROMPT _csitst + "  - DATA " +  _cdtst SIZE 140, 009 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 111, 296 SAY oSay15 PROMPT "CONSULTA EM " + _cdtcst SIZE 097, 008 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 032, 296 SAY oSay16 PROMPT _csitrec + " - DATA " + _cdtrec SIZE 164, 009 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 048, 296 SAY oSay17 PROMPT "CONSULTA EM " + _cdtcrec SIZE 076, 008 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
        @ 016, 296 SAY oSay18 PROMPT "CNAE " + _ccnae SIZE 112, 010 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL

        //Folder Ratings

        oazul  	:= LoadBitmap(GetResources(),'br_azul')
        overde 	:= LoadBitmap(GetResources(),'br_verde')
        overme 	:= LoadBitmap(GetResources(),'br_vermelho')
        oamare 	:= LoadBitmap(GetResources(),'br_amarelo')

        oWBrowse1 := TCBrowse():New(014 , 008,452, 146,,,,oFolder1:aDialogs[2],,,,,{||},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)

        oWBrowse1:SetArray(aWBrowse1)

        oWBrowse1:AddColumn(TCColumn():New("",{|| IIF(aWBrowse1[oWBrowse1:nAt,1]=="A",oazul,;
            IIF(aWBrowse1[oWBrowse1:nAt,1]=="B",overde,;
            IIF(aWBrowse1[oWBrowse1:nAt,1]=="C",oamare,overme))) }          ,,,,"CENTER",    ,.T.,.F.,,,,.F.,))

        oWBrowse1:AddColumn(TCColumn():New("M�s/Ano"    			, {|| aWBrowse1[oWBrowse1:nAt,2]},,,,"CENTER", 60 ,.F.,.F.,,,,.F., ) )
        oWBrowse1:AddColumn(TCColumn():New("Classifica��o"   	, {|| aWBrowse1[oWBrowse1:nAt,3]},,,,"CENTER", 60 ,.F.,.F.,,,,.F., ) )
        oWBrowse1:AddColumn(TCColumn():New("Pontualidade"    	, {|| aWBrowse1[oWBrowse1:nAt,4]},,,,"CENTER", 60 ,.F.,.F.,,,,.F., ) )
        oWBrowse1:AddColumn(TCColumn():New("Relacionamento"  	, {|| aWBrowse1[oWBrowse1:nAt,5]},,,,"CENTER", 60,.F.,.F.,,,,.F., ) )
        oWBrowse1:AddColumn(TCColumn():New("Restritivas"     	, {|| aWBrowse1[oWBrowse1:nAt,6]},,,,"CENTER", 60,.F.,.F.,,,,.F., ) )
        oWBrowse1:AddColumn(TCColumn():New("Cr�dito na Pra�a"    , {|| aWBrowse1[oWBrowse1:nAt,7]},,,,"CENTER", 60,.F.,.F.,,,,.F., ) )
        oWBrowse1:AddColumn(TCColumn():New("Densidade Comercial" , {|| aWBrowse1[oWBrowse1:nAt,8]},,,,"CENTER", 60,.F.,.F.,,,,.F., ) )

        // Folder Positivas
        @ 006, 005 LISTBOX oWBrowse2 Fields HEADER "Segmento","Data Info","Associada","Fone","Cliente desde","Ult Compra","Dt Maior Ac.","Maior Acumulo","Debito Atual","Vencido 5+","Vencido 15+","Vencido 30+","Prazo m�dio","Media Atrasos","Media Vencidos","Limite Cr�dito","Tp limite Cr�dito" SIZE 454, 160 OF oFolder1:aDialogs[3] PIXEL ColSizes 50,50
        oWBrowse2:SetArray(aWBrowse2)
        oWBrowse2:bLine := {|| {;
            aWBrowse2[oWBrowse2:nAt,1],;
            aWBrowse2[oWBrowse2:nAt,2],;
            aWBrowse2[oWBrowse2:nAt,3],;
            aWBrowse2[oWBrowse2:nAt,4],;
            aWBrowse2[oWBrowse2:nAt,5],;
            aWBrowse2[oWBrowse2:nAt,6],;
            aWBrowse2[oWBrowse2:nAt,7],;
            aWBrowse2[oWBrowse2:nAt,8],;
            aWBrowse2[oWBrowse2:nAt,9],;
            aWBrowse2[oWBrowse2:nAt,10],;
            aWBrowse2[oWBrowse2:nAt,11],;
            aWBrowse2[oWBrowse2:nAt,12],;
            aWBrowse2[oWBrowse2:nAt,13],;
            aWBrowse2[oWBrowse2:nAt,14],;
            aWBrowse2[oWBrowse2:nAt,15],;
            aWBrowse2[oWBrowse2:nAt,16],;
            aWBrowse2[oWBrowse2:nAt,17];
            }}


        //Folder Restri��es
        @ 009, 008 LISTBOX oWBrowse3 Fields HEADER "Associada","Data","1a Restricao","2a Restricao" SIZE 327, 164 OF oFolder1:aDialogs[4] PIXEL ColSizes 50,50
        oWBrowse3:SetArray(aWBrowse3)
        oWBrowse3:bLine := {|| {;
            aWBrowse3[oWBrowse3:nAt,1],;
            aWBrowse3[oWBrowse3:nAt,2],;
            aWBrowse3[oWBrowse3:nAt,3],;
            aWBrowse3[oWBrowse3:nAt,4];
            }}

        @ 009, 345 GROUP oGroup6 TO 175, 474 PROMPT "Resumo Financeiro " OF oFolder1:aDialogs[4] COLOR 0, 16777215 PIXEL

        @ 029, 350 SAY oSay21 PROMPT "D�bito Atual" SIZE 034, 007 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 039, 350 SAY oSay22 PROMPT "Vencido 5+" SIZE 035, 007 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 054, 350 SAY oSay24 PROMPT "Vencido 15+" SIZE 035, 007 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 066, 350 SAY oSay25 PROMPT "Vencido 30+" SIZE 035, 007 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 077, 350 SAY oSay26 PROMPT "Total Limite Cr�dito" SIZE 035, 007 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 090, 350 SAY oSay27 PROMPT "Maior acumulo" SIZE 040, 007 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 102, 350 SAY oSay28 PROMPT "Vendas ult 24 meses" SIZE 035, 007 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 025, 393 MSGET oGet12 VAR cdebatu WHEN .F. SIZE 052, 010 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 038, 393 MSGET oGet13 VAR cvenc5 WHEN .F. SIZE 052, 010 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 050, 393 MSGET oGet14 VAR cvenc15 WHEN .F. SIZE 052, 010 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 062, 393 MSGET oGet15 VAR cvenc30 WHEN .F. SIZE 052, 010 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 075, 393 MSGET oGet16 VAR ctotlim WHEN .F. SIZE 052, 010 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 086, 393 MSGET oGet17 VAR cmaior WHEN .F. SIZE 052, 010 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL
        @ 098, 393 MSGET oGet18 VAR cVendas WHEN .F. SIZE 052, 010 OF oFolder1:aDialogs[4] COLORS 0, 16777215 PIXEL

        @ 220, 427 BUTTON oFecha PROMPT "Fechar" SIZE 053, 014 OF oDlg ACTION (oDlg:End()) PIXEL

        ACTIVATE MSDIALOG oDlg CENTERED

    Endif

Return

/*
===============================================================================================================================
Programa----------: ConCisp
Autor-------------: Josu� Danich
Data da Criacao---: 13/08/2018
===============================================================================================================================
Descri��o---------: Consulta analitca Cisp
===============================================================================================================================
Parametros--------: _cnome - raz�o social do cliente
                    _ccnpj - cnpj do cliente
                    _cpessoa - tipo de pessoa juridica/fisica do cliente
                    _cinscr - inscri��o estadual do cliente
                    _cUfCli - Estado do Cliente
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function ConCisp(_cnome,_ccnpj,_cpessoa,_cinscr,_cUfCli)

    Local cUrlcisp    := "https://servicos.cisp.com.br/v1/avaliacao-analitica/raiz/" + substr(alltrim(_ccnpj),1,8)
    Local aHeadOut        := {}
    Local cHdcisp     := ""
    Local cCorcisp    := ""
    Local _ocisp
    Local _osprotesto
    Local _acisp      := {}
    Local _lret           := .T.
    Local _cpasswd        := u_itgetmv("IT_PWCISP","!t@lac95_01#")
    Local _cuser		  := u_itgetmv("IT_USCISP","ws09501")
    Local _nnj				:= 0
    //Local _nis			:= 0
    Local _nnk				:= 0
    Local _nni				:= 0
    Local _lLinkPrd      := U_ItGetMv("IT_LKCISPP", .T.) 
//S� atualiza pessoas juridicas
    If (_cpessoa == "F")
   
       If Type("_NATUA") == "U"
          _natua := 2
       EndIf 
       
       If _natua == 2
          u_itmsg("N�o atualiza pessoa f�sica via Cisp","Aten��o",,1)
       Endif

        Return

    Endif

//Define usu�rio e password
    aAdd( aHeadOut , "Authorization: Basic "+Encode64(_cuser + ":" + _cpasswd ) )


    //Faz chamada ao webservice do cisp
    CHdcisp  := ""
    cCorcisp := HttpGet(cUrlcisp,"",NIL,aHeadOut,@cHdcisp)
    _ocisp   := nil
    _acisp := strtokarr(cHdcisp,chr(10))

    //Verifica e formata resposta do cisp
    If substr(cHdcisp,1,15) == "HTTP/1.1 200 OK" .and. FWJsonDeserialize(cCorcisp,@_ocisp)

        _ccnpj :=  _ccnpj
        _crazao := _ocisp:cliente:razaosocial
        _cnome := _ocisp:cliente:nomefantasia
        _cdata := _ocisp:cliente:datafundacao
        _cdata := if(type("_cdata")="C",substr(_cdata,9,2)+"/"+substr(_cdata,6,2)+"/"+substr(_cdata,1,4)," ")
        _cender := _ocisp:cliente:endereco
        _cbairro := _ocisp:cliente:bairro
        _ccidade := _ocisp:cliente:cidade + " - " + _ocisp:cliente:uf
        _ctelefone := _ocisp:cliente:telefone
        _cdata2 := _ocisp:cliente:datacadastramento
        _cdata2 := if(type("_cdata2")="C",substr(_cdata2,9,2)+"/"+substr(_cdata2,6,2)+"/"+substr(_cdata2,1,4)," ")
        _cassoc := _ocisp:cliente:associadacadastrante
        _cObs   := If(AttIsMemberOf(_ocisp:cliente, "observacoes"),_ocisp:cliente:observacoes,"")

        if "cnae" $ cCorcisp  //Teste para ver se veio informa��es da receita
        If AttIsMemberOf(_ocisp, "receitaFederal") .and. VALTYPE(_ocisp:RECEITAFEDERAL) == "O"  .and. AttIsMemberOf(_ocisp:receitaFederal, "cnae")
            _ccnae := _ocisp:receitaFederal:cnae
            _csitrec := _ocisp:receitaFederal:situacaoCadastral
            _cdtrec := _ocisp:receitaFederal:dataSituacaoCadastral
            _cdtrec := iif(type("_cdtrec")="C",substr(_cdtrec,9,2)+"/"+substr(_cdtrec,6,2)+"/"+substr(_cdtrec,1,4)," ")
            _cdtcrec := _ocisp:receitaFederal:dataConsulta
            _cdtcrec := iif(type("_cdtcrec")="C",substr(_cdtcrec,9,2)+"/"+substr(_cdtcrec,6,2)+"/"+substr(_cdtcrec,1,4)," ")
        
        Else

            _ccnae := "N/C"
            _csitrec := "N/C"
            _cdtrec := "N/C"
            _cdtrec := "N/C"
            _cdtcrec := "N/C"
            _cdtcrec := "N/C"

        Endif
        EndIf

        _lAchou := .F.
        _npos := 0

        For _nnj := 1 to len(_ocisp:sintegras)

            if alltrim(_ocisp:sintegras[_nnj]:inscricaoEstadual) == alltrim(_cinscr)
                _lAchou := .T.
                _npos := _nnj
            Endif

        Next _nnj

        If _npos > 0

            _cinsc := _ocisp:sintegras[1]:inscricaoEstadual + " - " + _ocisp:sintegras[1]:uf
            _csitst := _ocisp:sintegras[1]:situacaoCadastral
            _cdtst := _ocisp:sintegras[1]:dataSituacaoCadastral
            _cdtst := iif(type("_cdtst")="C",substr(_cdtst,9,2)+"/"+substr(_cdtst,6,2)+"/"+substr(_cdtst,1,4)," ")
            _cdtcst := _ocisp:sintegras[1]:dataConsulta
            _cdtcst := iif(type("_cdtcst")="C",substr(_cdtcst,9,2)+"/"+substr(_cdtcst,6,2)+"/"+substr(_cdtcst,1,4)," ")

        Else


            _cinsc := "N/C"
            _csitst := "N/C"
            _cdtst := "N/C"
            _cdtst := "N/C"
            _cdtcst := "N/C"
            _cdtcst := "N/C"

            //Faz consulta especifica de sintegra com o cnpj completo

            //cUrlsintegrae := "https://servicos.cisp.com.br/v1/sintegra/" + alltrim(_ccnpj)  
            cHDSintegrae  := ""

            If _lLinkPrd
               cUrlsintegrae := "https://api.maxxi.cisp.com.br/public-bases/v1/sintegra/cnpj/"+ Alltrim(_ccnpj)+"/uf/"+AllTrim(_cUfCli)+"?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/sintegra/" + alltrim(M->ZX_CGC)  
            Else 
               cUrlsintegrae := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/sintegra/cnpj/"+ Alltrim(_ccnpj)+"/uf/"+AllTrim(_cUfCli)+"?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/sintegra/" + alltrim(M->ZX_CGC)
            EndIf 
             
            aHeadOut := {} 
            aAdd( aHeadOut , "accept:application/json")

            //Faz chamada ao webservice do Sintegra
            cCorSintegrae := HttpGet(cUrlsintegrae,"",NIL,aHeadOut,@cHdSintegrae)
            _osintegrae   := ""

            cCorSintegrae := DecodeUTF8(cCorSintegrae, "cp1252")  

            _oJson := JsonObject():new()

            _cRet := _oJson:FromJson(cCorSintegrae)

            If (substr(cHdSintegrae,1,12) == "HTTP/1.1 200" .and. ValType(_cRet) == "U") //.and. FWJsonDeserialize(cCorSintegrae,@_osintegrae) .and. len(_osintegrae) > 0)

               _aNames := _oJson:GetNames()

               _osintegra := _oJson:GetJsonObject("company")

               If ValType(_osintegra) == "A" .Or. ValType(_osintegra) == "J" 
                  _osintegra := _osintegra[1]
               EndIf 

               _nI := Ascan(_aNames, "updateDate" )
               If _nI > 0
                  _cDtAlter := _oJson[_aNames[_nI]]
               EndIf 

               _oDoctos := _osintegra:GetJsonObject("documents")  // _oJson:GetJsonObject("document")
               _oDoctos := _oDoctos[1]

               _aNameDocs := _oDoctos:GetNames()

               _nI := Ascan(_aNameDocs ,"type" )
               _cTipoDocs := ""

               If _nI > 0
                  _cTipoDocs := _oDoctos[_aNameDocs[_nI]]	  
               EndIf 

               _nI := Ascan(_aNameDocs ,"value" )
               _cNrDocs := ""

               If _nI > 0
                  _cNrDocs := _oDoctos[_aNameDocs[_nI]]	
                  _cNrDocs := StrTran(_cNrDocs,".","")  
               EndIf 

               _oRegSit := _osintegra:GetJsonObject("register")
               _aNameReg  := _oRegSit:GetNames()

               _nI := Ascan(_aNameReg, "status" )

               If _nI > 0
                  _cSituacRg := _oRegSit[_aNameReg[_nI]]
               EndIf  

               _cDtAltRec := ""

               _nI := Ascan(_aNameReg, "date" )
               If _nI > 0
                  _cDtAltRec := _oRegSit[_aNameReg[_nI]]
                  If !Empty(_cDtAltRec)
                     _cDtAltRec := StrTran(_cDtAltRec,"-","")
                  Else
                     _cDtAltRec := "       " 
                  EndIf 
               EndIf 

//-------------------------------------------------------------------------------------------//
/*
               //Verifica e formata resposta do Sintegra
               //If (substr(cHdSintegrae,1,15) == "HTTP/1.1 200 OK" .and. ValType(_cRet) == "U") //.and. FWJsonDeserialize(cCorSintegrae,@_osintegrae) .and. len(_osintegrae) > 0)

                //Analisa resposta do sintegra e pega consulta habilitada igual � IE atual ou se n�o tiver pega �ltima consulta habilitada
                _csintegra := _osintegrae[1]
                _dmaior := stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
                _csitmaior := alltrim(_CSINTEGRA:situacaoCadastral)
                _nia := 0


                If alltrim(_cinscr) == iif("inscricaoEstadual" $ cCorSintegrae,alltrim(_CSINTEGRA:inscricaoEstadual),"ISENTO") .and.;
                        (_csitmaior == "HABILITADO" .OR. _csitmaior == "HABILITADA" .OR. _csitmaior == "ATIVO" .OR. _csitmaior == "ATIVA" .OR. _csitmaior == "ATIVO - HABILITADO"  .OR. _csitmaior == "HABILITADO - ATIVO")

                    _lAchou := .T.
                    _cinsc := iif("inscricaoEstadual" $ cCorSintegrae,alltrim(_CSINTEGRA:inscricaoEstadual),"ISENTO")

                Else

                    _lAchou := .F.

                    For _nis := 1 to len(_osintegrae)

                        _ctemps := _osintegrae[_nis]
                        _dtemps := stod(substr(alltrim(_ctemps:dataConsulta),1,4)+substr(alltrim(_ctemps:dataConsulta),6,2)+substr(alltrim(_ctemps:dataConsulta),9,2))
                        _csittemp := alltrim(_ctemps:situacaoCadastral)


                        If alltrim(_cinscr) == alltrim(_ctemps:inscricaoEstadual)

                            if (_csittemp == "HABILITADO" .OR. _csittemp == "HABILITADA" .OR. _csittemp == "ATIVO" .OR. _csittemp == "ATIVA" .OR. _csittemp == "ATIVO - HABILITADO"  .OR. _csittemp == "HABILITADO - ATIVO")

                                _lAchou := .T.
                                _nia := _nis
                                _csintegra := _osintegrae[_nis]
                                _dmaior := stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
                                _csitmaior := alltrim(_CSINTEGRA:situacaoCadastral)
                                _cinsc := iif("inscricaoEstadual" $ cCorSintegrae,alltrim(_CSINTEGRA:inscricaoEstadual),"ISENTO")

                            Endif

                        Endif

                    Next _nis

                Endif


                //Se n�o achou inscri��o estadual igual a atual e habilitada procura a �ltima habilitada
                If !(_lAchou)

                    _dmaior := stod("20010101")

                    For _nis := 1 to len(_osintegrae)

                        _ctemps := _osintegra[_nis]
                        _dtemps := stod(substr(alltrim(_ctemps:dataConsulta),1,4)+substr(alltrim(_ctemps:dataConsulta),6,2)+substr(alltrim(_ctemps:dataConsulta),9,2))
                        _csittemp := alltrim(_ctemps:situacaoCadastral)


                        If _dtemps > _dmaior

                            if !(_csitmaior == "HABILITADO" .OR. _csitmaior == "HABILITADA" .OR. _csitmaior == "ATIVO" .OR. _csitmaior == "ATIVA" .OR. _csitmaior == "ATIVO - HABILITADO"  .OR. _csitmaior == "HABILITADO - ATIVO")

                                _csintegra := _osintegrae[_nis]
                                _dmaior := stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
                                _csitmaior := alltrim(_CSINTEGRA:situacaoCadastral)
                                _cinsc := iif("inscricaoEstadual" $ cCorSintegrae,alltrim(_CSINTEGRA:inscricaoEstadual),"ISENTO")

                            Else

                                If (_csittemp == "HABILITADO" .OR. _csittemp == "HABILITADA" .OR. _csittemp == "ATIVO" .OR. _csittemp == "ATIVA" .OR. _csittemp == "ATIVO - HABILITADO"  .OR. _csittemp == "HABILITADO - ATIVO")

                                    _csintegra := _osintegrae[_nis]
                                    _dmaior := stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
                                    _csitmaior := alltrim(_CSINTEGRA:situacaoCadastral)
                                    _cinsc := iif("inscricaoEstadual" $ cCorSintegrae,alltrim(_CSINTEGRA:inscricaoEstadual),"ISENTO")

                                Endif

                            Endif


                        Elseif _dtemps == _dmaior

                            if !(_csitmaior == "HABILITADO" .OR. _csitmaior == "HABILITADA" .OR. _csitmaior == "ATIVO" .OR. _csitmaior == "ATIVA" .OR. _csitmaior == "ATIVO - HABILITADO"  .OR. _csitmaior == "HABILITADO - ATIVO")

                                If (_csittemp == "HABILITADO" .OR. _csittemp == "HABILITADA" .OR. _csittemp == "ATIVO" .OR. _csittemp == "ATIVA"  .OR. _csittemp == "ATIVO - HABILITADO"  .OR. _csittemp == "HABILITADO - ATIVO")

                                    _csintegra := _osintegrae[_nis]
                                    _dmaior := stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
                                    _csitmaior := alltrim(_CSINTEGRA:situacaoCadastral)
                                    _cinsc := iif("inscricaoEstadual" $ cCorSintegrae,alltrim(_CSINTEGRA:inscricaoEstadual),"ISENTO")

                                Endif

                            Endif

                        Endif

                    Next _nis

                Endif
*/

               _cinsc  := If(Empty(_cNrDocs),"ISENTO",_cNrDocs)
               _csitst := Upper(_cSituacRg)
               _cdtst  := Dtoc(Stod(_cDtAltRec))
               _cdtcst := Dtoc(Date())

            Else

                _cinsc := "N/C"
                _csitst := "N/C"
                _cdtst := "N/C"
                _cdtcst := "N/C"

            Endif
/*
            If _cinsc != "N/C"

                _csitst := _csitmaior
                _cdtst := dtoc(_dmaior)
                _cdtcst := dtoc(date())

            Endif
*/
        Endif

        If _cinsc == "N/C"

            _cender := "N/C - Falhou consulta sintegra na Cisp"
            _cbairro := "N/C"
            _ccidade := "N/C"
            _ctelefone := "N/C"

        Endif

        if "descricaoOptante" $ cCorcisp  //Teste para ver se veio informa��es de Simples

            _csimples := _ocisp:simplesNacional:descricaoOptante
            _cdtsimp  := _ocisp:simplesNacional:dataSimples
            _cdtsimp  := iif(type("_cdtsimp")="C",substr(_cdtsimp,9,2)+"/"+substr(_cdtsimp,6,2)+"/"+substr(_cdtsimp,1,4)," ")
            _cdtcsimp :=  _ocisp:simplesNacional:dataConsulta
            _cdtcsimp := iif(type("_cdtcsimp")="C",substr(_cdtcsimp,9,2)+"/"+substr(_cdtcsimp,6,2)+"/"+substr(_cdtcsimp,1,4)," ")

        Else

            _csimples := "N/C"
            _cdtsimp := "N/C"
            _cdtsimp := "N/C"
            _cdtcsimp :=  "N/C"
            _cdtcsimp := "N/C"

        Endif

        For _nnj := 1 to len(_ocisp:ratings)

            Aadd(aWBrowse1,{_ocisp:ratings[_nnj]:classificacao,;															//01 Status
            _ocisp:ratings[_nnj]:data,;																//02 Mes ano
            decodeutf8(substr(_ocisp:ratings[_nnj]:descricaoClassificacao,11,20)),; 											//03 Classificacao
            decodeutf8(substr(_ocisp:ratings[_nnj]:quesitos:descricaoNotaPontualidadeNivelAtraso,11,20)),;  					//04 "Pontualidade"
            decodeutf8(substr(_ocisp:ratings[_nnj]:quesitos:descricaoNotaRelacionamentoMercado,11,20)),;  					//05 "Relacionamento"
            decodeutf8(substr(_ocisp:ratings[_nnj]:quesitos:descricaoNotaOcorrenciasRestritivas,11,20)),;  					//06 "Restritivas"
            decodeutf8(substr(_ocisp:ratings[_nnj]:quesitos:descricaoNotaCreditoPraca,11,20)),;  								//07 "Cr�dito na Pra�a"
            decodeutf8(substr(_ocisp:ratings[_nnj]:quesitos:descricaoNotaDensidadeComercial,11,20))})  						//08 "Densidade Comercial"

        Next _nnj

        If len(aWBrowse1) == 0

            Aadd(aWBrowse1,{"1","N/C","N/C","N/C","N/C","N/C","N/C","N/C"})

        Endif

        For _nnk := 1 to len(_ocisp:positivaSegmentos)

            _csegmento := alltrim(_ocisp:positivaSegmentos[_nnk]:descricaoSegmento)

            For _nnj := 1 to len(_ocisp:positivaSegmentos[_nnk]:positivas)

                Aadd(aWBrowse2,{decodeutf8(_csegmento),;//01 "Segmento"
                _ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:dataInformacao,;//02 "Data Info"
                decodeutf8(_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:razaoSocial),;//03 "Associada",;
                    substr(_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:fone,7,50),;//04 "Fone",;
                    _ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:dataClienteDesde,;//05"Cliente desde",;
                    _ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:dataUltimaCompra,;//06"Ult Compra",;
                    _ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:dataMaiorAcumulo,;//07"Dt Maior Ac.",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:valorMaiorAcumulo),"@E 999,999,999.99"),;//08"Maior Acumulo",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:valorDebitoAtual),"@E 999,999,999.99"),;//09"Debito Atual",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:valorDebitoVencidoMais05Dias),"@E 999,999,999.99"),;//10"Vencido 5+",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:valorDebitoVencidoMais15Dias),"@E 999,999,999.99"),;//11"Vencido 15+",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:valorDebitoVencidoMais30Dias),"@E 999,999,999.99"),;//12"Vencido 30+",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:prazoMedioDeVendas),"@E 999,999,999.99"),;//13"Prazo m�dio",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:valorMediaPonderadaAtrasoPagamentos),"@E 999,999,999.99"),;//14"Media Atrasos",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:mediaPonderadaTitulosVencidosMais05Dias),"@E 999,999,999.99"),;//15"Media Vencidos",;
                    transform((_ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:valorLimiteCredito),"@E 999,999,999.99"),;//16"Limite Cr�dito",;
                    _ocisp:positivaSegmentos[_nnk]:positivas[_nnj]:descricaoLimiteCredito})//17"Tp limite Cr�dito"

            Next _nnj

        Next _nnk

        If len(aWBrowse2) == 0

            Aadd(aWBrowse2,{"N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C","N/C"})

        Endif


        For _nnk := 1 to len(_ocisp:restritivas)

            Aadd(aWBrowse3,{_ocisp:restritivas[_nnk]:razaoSocial,;
                _ocisp:restritivas[_nnk]:datainformacao,;
                decodeutf8(_ocisp:restritivas[_nnk]:descricaoprimeirarestritiva),;
                decodeutf8(_ocisp:restritivas[_nnk]:descricaosegundarestritiva)})

        Next _nnk

        For _nnk := 1 to len(_ocisp:alertas)

            Aadd(aWBrowse3,{decodeutf8(_ocisp:alertas[_nnk]:razaoSocial),_ocisp:alertas[_nnk]:dataAtualizacao,decodeutf8(_ocisp:alertas[_nnk]:descricaoAlerta)," "})

        Next _nnk

        _ccheques := strzero(_ocisp:chequeSemfundo:totalDevolucoes,2)
        _cdcheques:= "N/C"

        for _nni := 1 to len(_ocisp:chequeSemfundo:cheques)

            if _nni == 1

                _cdcheques := _ocisp:chequeSemfundo:cheques[_nni]:dataocorrencia

            Else

                _cdcheques += ", " + _ocisp:chequeSemfundo:cheques[_nni]:dataocorrencia

            Endif

        Next _nni

        _ndebatu := _ocisp:informacaoSuporte
        If type("_ndebatu") == "O"

            cdebatu := transform( _ocisp:informacaoSuporte:valorTotalDebitoAtual ,"@E 999,999,999.99")
            cvenc5 := transform( _ocisp:informacaoSuporte:valorTotalDebitoVencidoMais05Dias ,"@E 999,999,999.99")
            cvenc15 := transform( _ocisp:informacaoSuporte:valorTotalDebitoVencidoMais15Dias ,"@E 999,999,999.99")
            cvenc30 := transform( _ocisp:informacaoSuporte:valorTotalDebitoVencidoMais30Dias ,"@E 999,999,999.99")
            ctotlim := transform( _ocisp:informacaoSuporte:valorTotalLimiteCredito ,"@E 999,999,999.99")
            cmaior  := transform( _ocisp:informacaoSuporte:valorTotalMaiorAcumulo ,"@E 999,999,999.99")
            cVendas := transform( _ocisp:informacaoSuporte:quantidadeAssociadasVendasUltimos2Meses ,"@E 999,999,999")

        Else

            cdebatu := transform( 0 ,"@E 999,999,999.99")
            cvenc5  := transform( 0 ,"@E 999,999,999.99")
            cvenc15 := transform( 0 ,"@E 999,999,999.99")
            cvenc30 := transform( 0 ,"@E 999,999,999.99")
            ctotlim := transform( 0 ,"@E 999,999,999.99")
            cmaior  := transform( 0 ,"@E 999,999,999.99")
            cVendas := transform( 0 ,"@E 999,999,999")

        Endif

        //L� protestos
        _cprotes := "ERRO NA CONSULTA"

        //Faz chamada ao webservice de pesquisa de protesto
        cUrlprotesto := "https://servicos.cisp.com.br/v1/consulta-protesto/" + alltrim(_ccnpj)
        cHdprotesto := ""
        cCorProtesto            := HttpGet(cUrlprotesto,"",NIL,aHeadOut,@cHdprotesto)

        //Verifica e formata resposta do Sintegra
        If substr(cHdprotesto,1,15) == "HTTP/1.1 200 OK" .and. FWJsonDeserialize(cCorprotesto,@_osprotesto)
            If ! ("NADA CONSTA" $ Upper(_osprotesto:situacao))
                _cprotes := _osprotesto:situacao + " - " +  strzero(_osprotesto:qtdTitulos,3) + " protestos"
            Else
                _cprotes := _osprotesto:situacao + " - 000 protestos"
            EndIf
        Endif

        //Se achou protestos adiciona na tela de alerta
        If "NADA CONSTA" $ Upper(_cprotes) // "NADA CONSTA - 000 protestos"

            Aadd(aWBrowse3,{"PROTESTOS","Cons. em " + DTOC(DATE()),_CPROTES," "})

        Endif

        //Se achou cheques devolvidos  adiciona na tela de alerta
        If _ccheques != '00'

            Aadd(aWBrowse3,{"CHEQUES DEVOLVIDOS","Cons. em " +  DTOC(DATE()),_ccheques," "})

        Endif


        If len(aWBrowse3) == 0

            Aadd(aWBrowse3,{"N/C","N/C","N/C","N/C"})

        Endif

    Else

        u_itmsg("Falha de consulta na cisp!","Aten��o",,1)

        _lret := .F.

    Endif

Return _lret

/*=============================================================================================================================
Programa----------: ITPARCS()
Autor-------------: Josu� Danich
Data da Criacao---: 04/04/2019
===============================================================================================================================
Descri��o---------: Retorno de quantidade de parcelas da condi��o de pagamento
===============================================================================================================================
Parametros--------: _ccond - c�digo da condi��o de pagamento
===============================================================================================================================
Retorno-----------: _nparcs - n�mero de parcelas
===============================================================================================================================*/
User Function IT_PARCS(_ccond As Char)  As Numeric
 Local _nparcs  := 0 As Numeric
 Local _aret:= condicao(1000,_ccond,0,date())  As Array 
 
  _nparcs := len(_aret)

Return _nparcs

/*=============================================================================================================================
Programa----------: ITTPARC()
Autor-------------: Josu� Danich
Data da Criacao---: 04/04/2019
===============================================================================================================================
Descri��o---------: Atualiza E4_I_PARCS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function ITTPARCS()

 Local _aret := {}
 
 If !u_itmsg("Atualizar E4_I_PARCS de todos os registros?","Aten��o",,2,2,2)
 
     u_itmsg("Processo cancelado","Aten��o",,1)
     Return
 
 Endif
 
 SE4->(Dbgotop())
 
 Do while SE4->(!Eof())
 
     _nposi := SE4->(Recno())
     _aret := condicao(1000,SE4->E4_CODIGO,0,date())
     SE4->(Dbgoto(_nposi))
     Reclock("SE4",.F.)
     SE4->E4_I_PARCS := LEN(_aret)
     SE4->(Msunlock())
 
     SE4->(Dbskip())
 
 Enddo

Return 


/*=============================================================================================================================
Programa----------: ITENTIMED()
Autor-------------: Jonathan Torioni
Data da Criacao---: 31/07/2020
===============================================================================================================================
Descri��o---------: Fun��o utilizada no gatilho do campo C5_I_AGEND
===============================================================================================================================
Parametros--------: _dData
                    _cCliente
                    _cLjCli
                    _cFilFt
                    _cNumPv
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function ITENTIMED(_dData,_cCliente,_cLjCli, _cFilFt,_cNumPv)
    Local _dRet
    Local _dNec

    //Primeiro calculo a data da necessidade para conseguir validar a data de entrega
    //Data da necessidade s� sera calculada antecipadamente se a entrega for imediata

    _dNec := DataValida(_dData+1, .T.)
    _dRet := DataValida(_dNec + U_OMSVLDENT(_dData,_cCliente,_cLjCLi,_cFilFt,_cNumPv,1,.F.),.T.)

RETURN _dRet

/*=============================================================================================================================
Programa----------: OMSDTENG()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/09/20211
===============================================================================================================================
Descri��o---------: Fun��o que chama a fun��o  U_OMSVLDENT(), para ser utilizada em gatilhos, devido o excesso de par�metros
                    da fun��o  U_OMSVLDENT() n�o caber no campo de regras do dicion�rio de gatilhos.
===============================================================================================================================
Parametros--------: _dData       = data a ser utilizada pela fun��o  U_OMSVLDENT().
                    _lVarMemoria = .T. = Alias de vari�vel de mem�ria.
                                   .F. = Alias de tabela de dados.
                    _lValida     = .T. = Valida transit time apenas.
                                 = .F. = Retorn o numero de dias do transit time.
===============================================================================================================================
Retorno-----------: _xRet   = .T./.F. = quando a fun��o  U_OMSVLDENT() for uma valida��o.
                            = Numero de dias = quando a fun��o  U_OMSVLDENT() for de c�lculo de transit time.
===============================================================================================================================
*/
User Function OMSDTENG(_dData,_lVarMemoria,_lValida)
    Local _cFilCarreg := ""
    Local _nAcao

    Default _dData := Date()
    Default _lVarMemoria := .T.
    Default _lValida := .F.

    Begin Sequence

        If _lVarMemoria
            _cFilCarreg := xFilial("SC5")
            If ! Empty(M->C5_I_FLFNC)
                _cFilCarreg := M->C5_I_FLFNC
            EndIf
        Else
            _cFilCarreg := SC5->C5_FILIAL
            If ! Empty(SC5->C5_I_FLFNC)
                _cFilCarreg := SC5->C5_I_FLFNC
            EndIf
        EndIf

        If _lValida
            _nAcao := 0
        Else
            _nAcao := 1
        EndIf

        If _lVarMemoria
            _xRet := U_OMSVLDENT(M->C5_I_DTENT,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_I_FILFT,M->C5_NUM,_nAcao,.F.,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN)
        Else
            _xRet := U_OMSVLDENT(SC5->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_I_FILFT,SC5->C5_NUM,_nAcao,.F.,_cFilCarreg,SC5->C5_I_OPER,SC5->C5_I_TPVEN)
        EndIf

    End Sequence

Return _xRet

/*
===============================================================================================================================
Programa----------: ArredMax
Autor-------------: Abrahao P. Santos
Data da Criacao---: 18/12/2008
===============================================================================================================================
Descri��o---------: Arredonda um valor para o maior numero inteiro, por exemplo: 10,02 para 11 ou 10,99 para 11. 
===============================================================================================================================
Parametros--------: nvalor - n�mero  ser arrendodado
===============================================================================================================================
Retorno-----------: nvalor - valor arredondado
===============================================================================================================================
*/
User Function ARREDMAX(nValor)

    If Int(nValor) < nValor
        nValor := Round(nValor+0.5,0)
    EndIf

Return(nValor)

/*
===============================================================================================================================
Programa----------: U_IT_TMS()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 06/06/2025
Descri��o---------: Retorna se o Local de Embraque usa TMS ou n�o .
Parametros--------: _cLocEmb = Codigo do locae de Embarque
Retorno-----------: .T. = Local de embarque � TMS - MultiEmbarcador
                    .F. = Local de embarque � TMS - RDC
===============================================================================================================================
*/
User Function IT_TMS(_cLocEmb)
 Local lRet := .F.//RDC
 Static _cWsTms := "XXXX"
 
 IF _cWsTms ="XXXX"
    _cWsTms := SuperGetMV( 'IT_LOEMTMS',.F.,"")
 Endif

 IF !EMPTY(_cWsTms) .AND. UPPER(_cLocEmb) $ UPPER(_cWsTms)
    lRet:= .T.//MultiEmbarcador
 EndIf

Return lRet
