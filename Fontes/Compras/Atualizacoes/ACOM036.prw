/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/03/2023 | Chamado 43320. Novo gatilho para o campo data de faturamento (C7_I_DTFAT).
Alex Wallauer | 28/06/2024 | Chamado 47732. Andre. Novo WF de Tabela de Preços de Fornecedores.
Lucas Borges  | 24/09/2024 | Chamado 48465. Sanado problemas apresentados no Code Analysis
========================================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
========================================================================================================================================================================
Andre       - Alex Wallauer - 10/06/25 -          - 50990   - Gravacao do campo C7_PICM com AIB_I_PICM via gatilho.
========================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: ACOM036
Autor-------------: ALEX WALLAUER FERRREIRA
Data da Criacao---: 09/04/2018
Descrição---------: Função chamada do Gatilho 005 do C7_PRODUTO - Chamado: 24422
Parametros--------: _lGatilhoICMS = .T. qaundo chamado pelos gatilhos dos campos: C7_TOTAL/C7_QTSEGUM/C7_QUANT/C7_DESC/C7_VLDESC/C7_BASEIPI/C7_IPI/C7_BASEICM/C7_VALICM/C7_ICMCOMP/C7_ICMSRET
Retorno-----------: Se _lGatilhoICMS = .T. retona C7_PICM senão retorna C7_LOCAL
===============================================================================================================================
*/
STATIC _lAlterou:=.F.
User Function ACOM036(_lGatilhoICMS)
 Local _aOrd := SaveOrd({"SC1"})
 Local nPProduto  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
 Local nPosLocal  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_LOCAL"})
 Local nPosNumSC  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUMSC"})
 Local nPosItSC   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMSC"})
 Local nPosItDtFa := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_I_DTFAT"})
 Local nPosTabPre := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CODTAB"})
 Local nPosPreco  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
 Local nPosPICM   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PICM"})
 Local _lRefresh  := TYPE("bGDRefresh") == "B"
 DEFAULT _lGatilhoICMS := .F.
 
 IF !_lGatilhoICMS .AND. !EMPTY(aCols[N][nPosNumSC]) .And. !Empty(aCols[N][nPosItSC])
    SC1->(Dbsetorder(2))//C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM+C1_FORNECE+C1_LOJA
    If SC1->(MsSeek(Xfilial("SC1")+aCols[N][nPProduto]+aCols[N][nPosNumSC]+aCols[N][nPosItSC]))
       aCols[N][nPosLocal] := SC1->C1_LOCAL
    ENDIF
 ENDIF
 
 AIB->(dbSetOrder(1))//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_ITEM
 AIA->(dbSetOrder(1))//AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB
 aCols[N][nPosTabPre] := SPACE(LEN(AIB->AIB_CODTAB))
 
 If AIA->(DbSeek(xFilial("AIA")+CA120FORN+CA120LOJ))
 
    DO WHILE AIA->(!EOF()) .AND. xFilial("AIA")+CA120FORN+CA120LOJ == AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR)
 
       IF AIA->AIA_DATDE <= DATE() .AND.  AIA->AIA_DATATE >= DATE() .AND. AIA->AIA_I_SITW = "A"//DENTRO DA VIGENCIA E APROVADA
         IF AIB->(DbSeek(xFilial("AIB")+CA120FORN+CA120LOJ+AIA->AIA_CODTAB))
            DO WHILE AIB->(!EOF()) .AND. xFilial("AIB")+CA120FORN+CA120LOJ+AIA->AIA_CODTAB == AIB->(AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB->AIB_CODTAB)
                IF aCols[N][nPProduto ] == AIB->AIB_CODPRO .AND. AIB->AIB_MOEDA = nMoedaPed
                   aCols[N][nPosTabPre] := AIB->AIB_CODTAB
                   aCols[N][nPosPreco ] := AIB->AIB_PRCCOM
                   MaFisRef("IT_PRCUNI" ,"MT120",aCols[N][nPosPreco]) 
                   aCols[N][nPosPICM  ] := AIB->AIB_I_PICM
                   MaFisRef("IT_ALIQICM","MT120",aCols[N][nPosPICM ])
                   EXIT
                ENDIF
                AIB->(DBSKIP())
            ENDDO
            IF !EMPTY(aCols[N][nPosTabPre])
               IF !EMPTY(AIA->AIA_CONDPG) .AND. AIA->AIA_CONDPG <> cCondicao
                  cCondicao:= AIA->AIA_CONDPG// cCondicao VARIAVEL PRIVATE DA TELA PADRÃO DO PC
                  _lAlterou:=.T.
               ENDIF
               IF !EMPTY(AIA->AIA_I_TPFR) .AND. AIA->AIA_I_TPFR <> LEFT(cTpFrete,1)
                  cTpFrete :=RetTipoFrete(AIA->AIA_I_TPFR)
                  _lAlterou:=.T.
               ENDIF
               IF _lAlterou .AND. _lRefresh
                  Eval(bGDRefresh)
               ENDIF
               EXIT
            ENDIF
          ENDIF
       ENDIF
       AIA->(DBSKIP())
    ENDDO
 ENDIF
 
IF _lGatilhoICMS 
   Return aCols[N][nPosPICM] //******  retorna o valor do PICM para os gatilhos dos campos: C7_TOTAL/C7_QTSEGUM/C7_QUANT/C7_DESC/C7_VLDESC/C7_BASEIPI/C7_IPI/C7_BASEICM/C7_VALICM/C7_ICMCOMP/C7_ICMSRET
EndIf

 IF N > 1
    dData:=aCols[N-1,GdFieldPos("C7_I_DTFAT",aHeader)]
    aCols[N][nPosItDtFa] := dData
 ENDIF
 
 RestOrd(_aOrd)

Return aCols[N][nPosLocal]//******  retorna o Local para o gatilho C7_PRODUTO  *****

/*
===============================================================================================================================
Programa----------: ACOM36Cond
Autor-------------: ALEX WALLAUER FERRREIRA
Data da Criacao---: 28/06/2024
Descrição---------: Função usada no MT120OK.PRW: U_ACOM36Cond(.F.) U_ACOM36Cond(.T.)
Parametros--------: lAtualiza
Retorno-----------: _lAlterou
===============================================================================================================================
*/
User Function ACOM36Cond(lAtualiza)
 IF lAtualiza
    _lAlterou:=.F.
 ENDIF
RETURN _lAlterou
