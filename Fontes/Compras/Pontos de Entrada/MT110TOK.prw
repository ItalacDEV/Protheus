/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Alex Wallauer| 26/04/19 | Chamado 28685. Validação p/ não permitir fracionamento p/ PAs onde a 1a UM for UN.
 Josué Danich | 11/06/19 | Chamado 29593. Ajuste de cabecalho para passar em validador.
 Alex Wallauer| 14/08/19 | Chamado 29814. Validação p/ ver se  existe S.C.(S) em aberto dos produtos.
 Alex Wallauer| 16/12/19 | Chamado 31462. Novas Validaçoes para os campos custumizados.
 Alex Wallauer| 27/01/21 | Chamado 35424. Nova Validacao para o campo Aplicacao direta.
 Alex Wallauer| 17/03/21 | Chamado 35938. Ajuste na validacao da segunda unidade de medida.
 Igor Melgaço | 12/07/22 | Chamado 40620. Validação dos campos de projeto e Subinvestimento.
 Igor Melgaço | 13/07/22 | Chamado 40620. Correção de validação somente qdo a aplicação for investimento.
 Alex Wallauer| 21/10/22 | Chamado 41652. Permitir fracionar produtos <> "PA" quando o campo ZZL_PEFROU for = "S".
 Alex Wallauer| 29/11/22 | Chamado 41967. Retirada a obrigatoriedade de urgente para as SAs como aplicação direta "SIM".
================================================================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================
Andre       - Alex Wallauer - 18/10/24 - 17/01/25 - 48841   - Nova validação na SC, Avaliar o estoque do produto em todos os Armazens, Criado o Motivo da SC (C1_I_MOTSC).
Andre       - Alex Wallauer - 25/10/24 - 17/01/25 - 48841   - Tratamento para os novos Parametros (SX6) : IT_EXCODSC, IT_EXGRUSC e IT_EXTIPSC.
Andre       - Alex Wallauer - 13/01/25 - 17/01/25 - 48841   - Criação dos totais de SC e de totais de PVs na LISTA de logs.
Andre       - Alex Wallauer - 29/05/25 -          - 50512   - Replicação do motivo da primeira linha para as demais linhas dos produtos.
================================================================================================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MT110TOK
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 31/08/2015
Descrição---------: Ponto de Entrada no A110TudOk() do MATA110.PRX
Parametros--------: Nenhum
Retorno-----------: _lRet ( .T. - Valida e continua o processo / .F. - Invalida e interrompe o processo )
===============================================================================================================================
*/
User Function MT110TOK() As Logical
 Local _aArea      := GetArea()
 Local _aAreaSC1   := SC1->(GetArea())
 Local x           := 0 As Numeric
 Local nX          := 0 As Numeric
 Local _lRet       := .T. As Logical
 Local _lRet2      := .T. As Logical
 Local aMensagem   := {} As Array
 Local aProbl      := {} As Array
 Local aSoluc      := {} As Array
 Local _nPosCDINV  := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_I_CDINV"}) As Numeric
 Local _nPosDSINV  := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_I_DSINV"}) As Numeric
 Local _nPosSUBIN  := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_I_SUBIN"}) As Numeric
 Local _nPosSUIND  := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_I_SUIND"}) As Numeric
 Local _cUM_NO_Fracionada:= U_ITGetMV("IT_UMNOFRAC","PC,UN") As Character
 Local _lValidFrac1UM    := .T. As Logical
 Local _cGrupo     As Char
 Local _cITEXCODSC As Char
 Local _cITEXGRUSC As Char
 Local _cITEXTIPSC As Char
 Local _cProds   := "" As Char
 Private _cItens := "" As Char
 Private _aItens := {} As Array
 Private _aTotais:= {} As Array 
 Private _nTotSC := 0  As Numeric
 Private _nTotPC := 0  As Numeric

 If Empty(cCCust)
     aProbl := {}
    aAdd(aProbl, "O campo Centro de Custo tem seu preenchimento obrigatório.")

    aSoluc := {}
    aAdd(aSoluc, "Favor informar um Centro de Custo válido, ou acessar a consulta via [F3].")

    aMensagem := {"Centro de Custo Obrigatório", aProbl, aSoluc}

    U_ITMsHTML(aMensagem)

    _lRet := .F.
 EndIf
 cAprov:=cAprov
 If Empty(cAprov)

    aProbl := {}
    aAdd(aProbl, "O campo Código do Aprovador tem seu preenchimento obrigatório.")

    aSoluc := {}
    aAdd(aSoluc, "Favor informar um Código de Aprovador válido, ou acessar a consulta via [F3].")

    aMensagem := {"Código do Aprovador Obrigatório", aProbl, aSoluc}

    U_ITMsHTML(aMensagem)

    _lRet := .F.
 EndIf
 cUrgen:=cUrgen
 If Empty(cUrgen)
    aProbl := {}
    aAdd(aProbl, "O campo Urgente é obrigatório.")

    aSoluc := {}
    aAdd(aSoluc, "Favor informar se a solicitação é urgente ou não..")

    aMensagem := {"Campo Urgente Obrigatório", aProbl, aSoluc}

    U_ITMsHTML(aMensagem)

    _lRet := .F.
 EndIf

 If _lRet
    _lRet := U_VldInf("I")
 EndIf

 If _lRet

    ZZL->( DBSetOrder(3) )
    If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
       If ZZL->ZZL_PEFRPA == "S"  .OR. ZZL->ZZL_PEFROU == "S"
          _lValidFrac1UM:=.F.
       EndIf
    EndIf
    ZZL->( DBSetOrder(1) )

    _nproduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )  == "C1_PRODUTO"})
    _nqtd     := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )  == "C1_QUANT"  })
    _n2UM     := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )  == "C1_SEGUM"  })
    _nqtdsegu := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )  == "C1_QTSEGUM"})
    _nItem    := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )  == "C1_ITEM"   })
    _nPosUsod := aScan( aHeader , {|x| Upper( Alltrim( x[2] ) )  == "C1_I_USOD" })
    _nPosDTNE := aScan( aHeader , {|x| Upper( Alltrim( x[2] ) )  == "C1_DATPRF" })

    _cGrupo    := ALLTRIM(U_ITGETMV("IT_GRP2U", "0006"))
    _cITEXCODSC:= ALLTRIM(SuperGetMV("IT_EXCODSC",.F.,""))
    _cITEXGRUSC:= ALLTRIM(SuperGetMV("IT_EXGRUSC",.F.,""))
    _cITEXTIPSC:= ALLTRIM(SuperGetMV("IT_EXTIPSC",.F.,"SV"))
    _cProds   := ""
    _cItens   := ""
    _aItens   := {}

    For x := 1 to len(aCols)
        If aTail(aCols[x]) // Se Linha Deletada
           LOOP
        ENDIF

        _cProduto:= aCols[x][_nproduto]
        _nquant  := aCols[x][_nqtdsegu]	//M->C1_QTSEGUM
        _c2UM    := aCols[x][_n2UM]	    //M->C1_SEGUM
        _dDTNE   := aCols[x][_nPosDTNE]	//M->C1_DATPRF

        SB1->(dbSeek(xFilial("SB1") + AllTrim(_cProduto)))

         IF ASCAN(_aItens,_cProduto) = 0 .AND.;
            (EMPTY(_cITEXCODSC) .OR. !_cProduto     $ _cITEXCODSC) .AND.;
            (EMPTY(_cITEXGRUSC) .OR. !SB1->B1_GRUPO $ _cITEXGRUSC) .AND.;
            (EMPTY(_cITEXTIPSC) .OR. !SB1->B1_TIPO  $ _cITEXTIPSC)

            AADD(_aItens,_cProduto)
            _cItens  += _cProduto+";"

         ENDIF


        If (_nquant > 0  .OR. !EMPTY(_c2UM)) .and. SB1->B1_CONV == 0 .AND. !(SB1->B1_GRUPO $ _cGrupo)

            U_ITMSG("Produto " + _cProduto + " não tem fator de conversão cadastrado, impossível usar segunda medida!", "Atenção",,1)

            _lRet := .F.
            Exit
        EndIf

        If  SB1->B1_TIPO = "SV"
            If aCols[X][_nPosUsod] <> "N"
               U_ITMSG("Produto " + _cProduto + ' esta com tipo de serviço ("SV") portanto o campo Aplicação direta deve estar preenchido com "Nao"', "Atenção",,1)
               _lRet := .F.
               Exit
            EndIf
        EndIf

        If EMPTY(_dDTNE)
           U_ITMSG("Produto " + _cProduto + ' com data de necessidade não preenchida', "Atenção","Favor preencher a data de necessidade",1)
           _lRet := .F.
           Exit
        EndIf

        IF _lValidFrac1UM

            If  SB1->B1_UM $ _cUM_NO_Fracionada
                If aCols[x,_nqtd] <> Int(aCols[x,_nqtd])
                    _lRet2 := .F.
                    _cProds+="Item: " + aCols[x,_nItem]+" Prod.: " + AllTrim(aCols[x,_nproduto])+" - 1aUM: "+SB1->B1_UM+" - 2aUM: "+SB1->B1_SEGUM + CHR(13)+CHR(10)
                EndIf
            EndIf

            If  SB1->B1_SEGUM $ _cUM_NO_Fracionada
                If aCols[x,_nqtdsegu] <> Int(aCols[x,_nqtdsegu])
                    _lRet2 := .F.
                    _cProds+="Item: " + aCols[x,_nItem]+" Prod.: " + AllTrim(aCols[x,_nproduto])+" - 1aUM: "+SB1->B1_UM+" - 2aUM: "+SB1->B1_SEGUM + CHR(13)+CHR(10)
                EndIf
            EndIf

        EndIf

    Next x

    If _lValidFrac1UM .AND. !_lRet2
       U_ITMSG("Não é permitido fracionar a quantidade da 1a. ou 2a. UM de produto onde a UM for "+_cUM_NO_Fracionada+". Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                  "Validação Fracionado","Favor informar apenas quantidades inteiras onde a UM for "+_cUM_NO_Fracionada+".",1     ,       ,        ,         ,     ,     ,;
                  {|| Aviso("Validação Fracionado",_cProds,{"Fechar"}) } )
       _lRet:=.F.
    ENDIF

    If _lRet .AND. _lRet2
       aLog    :={}
       aLog2   :={}
       aMotivos:={}
       FWMSGRUN( ,{|oProc|  MTLista("SELECT",oProc) } , "Verificando Produtos, Aguarde..." )
       IF LEN(aLog) > 0 .OR. LEN(aLog2) > 0
          _lRet:=MTLista("LISTA")
        ENDIF
    ENDIF

 EndIf

 For nX := 1 to len(aCols)
     If cCInve <> aCols[nX][_nPosCDINV]
         aCols[nX,_nPosCDINV ] := cCInve
         aCols[nX,_nPosDsInv ] := cDsInv
         aCols[nX,_nPosSUBIN ] := Space(Len(cCInve))
         aCols[nX,_nPosSUIND ] := Space(Len(cDsInv))
     EndIf
 Next nX

 If cAplic == "I"
    For nX := 1 to len(aCols)
        If aCols[nX][Len(aHeader)+1]//DELETADOS
            LOOP
        ENDIF
        If Empty(Alltrim(aCols[nX,_nPosSUBIN]))
            ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
            IF ZZI->(DBSEEK(xFilial("ZZI")+cCInve+"2"))
                U_ITMSG('Campo de Subinvestimento não Preenchido!', "Atenção",'',1)
                _lRet := .F.
            EndIf
        Else
            ZZI->(DBSETORDER(1))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
            If ZZI->(DBSEEK(xFilial("ZZI")+aCols[nX,_nPosSUBIN ]))
                If ZZI->ZZI_INVPAI <> cCInve
                    U_ITMSG('Campo de Subinvestimento da linha '+Alltrim(Str(nX))+' não corresponde ao projeto!', "Atenção",'Mofifique o campo selecionando um os dos itens da consulta.',1)
                    _lRet := .F.
                Else
                    If ZZI->ZZI_TIPO == "2"
                        ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
                        If ZZI->(DBSEEK(xFilial("ZZI")+cCInve+"3"))
                            U_ITMSG('No Campo de Subinvestimento da linha '+Alltrim(Str(nX))+' é obrigatório um Investimento de nivel 3 !', "Atenção",'Mofifique o campo selecionando um Investimento de nivel 3 da consulta.',1)
                            _lRet := .F.
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    Next nX
 EndIf

 RestArea(_aArea)
 RestArea(_aAreaSC1)

Return(_lRet)

/*
===============================================================================================================================
Programa----------: MTLista
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 05/07/2019
Descrição---------: Seleciona e lista itens em aberto
Parametros--------: _cAcao As Character ,oProc As Object
Retorno-----------: As Logical
===============================================================================================================================*/
STATIC FUNCTION  MTLista(_cAcao As Character ,oProc As Object) As Logical
 LOCAL _cAlias     As Character
 LOCAL _cQuery     As Character
 LOCAL I           As Numeric
 LOCAL _nPosMotivo As Numeric
 LOCAL _nPosProdut As Numeric
 LOCAL nTamMOT     As Numeric
 LOCAL _nTot       As Numeric
 LOCAL _lOK        As Logical
 LOCAL cTit1       As Character
 LOCAL _aSize      As Array
 LOCAL _aInfo      As Array
 LOCAL aObjects    As Array
 LOCAL nSaldo      As Numeric
 LOCAL lTemSol     As Logical
 LOCAL aLogAux     As Array
 LOCAL aMotAux     As Array
 LOCAL _cTotReg    As Character
 LOCAL _nConta     As Numeric
 LOCAL _cObsSC     As Character
 LOCAL _cObsPC     As Character
 LOCAL aHeader1    As Array
 LOCAL aHeader2    As Array
 LOCAL aHeader3    As Array
 LOCAL oDlg2       As Numeric
 LOCAL oPnlTopTop  As Numeric
 LOCAL nLin01      As Numeric
 LOCAL nCol01      As Numeric
 Local aTotAux := {} As Array
 
 _nPosMotivo:= aScan(aHeader, {|x| AllTrim(x[2]) == "C1_I_MOTSC"})
 _nPosProdut:= aScan(aHeader, {|x| AllTrim(x[2]) == "C1_PRODUTO"})
 _aSize     := MsAdvSize()
 _aInfo     := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 3 , 3 }
 aObjects   := {}
 IF SC1->(FIELDPOS("C1_I_MOTSC")) > 0
    nTamMOT:=LEN(SC1->C1_I_MOTSC)
 ELSE
    nTamMOT:=100
 ENDIF

 IF _cAcao = "SELECT"

   _cAlias := GetNextAlias()
   _cItens := LEFT(_cItens,LEN(_cItens)-1)

   _cquery := " SELECT C1_EMISSAO, C1_SOLICIT, C1_NUM, C1_PRODUTO , C1_PEDIDO , C1_QUANT , 0 C7_QUANT , C1_ITEM , ' ' C7_ITEM  "
   _cquery += "        FROM " + RETSQLNAME("SC1") + " C1 "
   _cquery += "        WHERE C1_FILIAL= '"+cFilAnt+"' AND  C1_PEDIDO = ' ' AND D_E_L_E_T_ = ' ' AND C1_RESIDUO <> 'S' AND C1_QUANT > C1_QUJE AND C1_NUM <> '"+cA110Num+"' AND "
   _cquery += "              C1_PRODUTO IN "+FORMATIN(_cItens,";")
   _cquery += " UNION "
   _cquery += " SELECT C1_EMISSAO, C1_SOLICIT, C1_NUM, C1_PRODUTO , C1_PEDIDO , C1_QUANT , C7_QUANT  , C1_ITEM  , C7_ITEM "
   _cquery += "        FROM " + RETSQLNAME("SC1") + " C1 "
   _cquery += "        JOIN " + RETSQLNAME("SC7") + " C7 ON C1_FILIAL = C7_FILIAL AND C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC  "
   _cquery += "        WHERE  C1_FILIAL= '"+cFilAnt+"' AND  C1_PEDIDO <> ' ' AND  C1.D_E_L_E_T_ = ' ' AND C1_RESIDUO <> 'S' AND C7_RESIDUO <> 'S' AND  "
   _cquery += "               C7_ENCER = ' ' AND C7.D_E_L_E_T_ = ' ' AND C7_QUANT > C7_QUJE AND C1_PRODUTO IN "+FORMATIN(_cItens,";")
   _cquery += " ORDER BY C1_PRODUTO , C1_NUM , C1_ITEM  "

   MPSysOpenQuery( _cquery ,_cAlias )
   DBSelectArea(_cAlias)
   _nTot:=0
   COUNT TO _nTot

   _cTotReg:=ALLTRIM(STR( _nTot ))
   _nConta :=0
   _cObsSC :="[Tem SC em Aberto] "
   _cObsPC :="[Tem PC em Aberto] "
   _aTotais:={}//Declarada PRIVATE NA FUNÇÃO MT110TOK()
   _nTotSC :=0 //Declarada PRIVATE NA FUNÇÃO MT110TOK()
   _nTotPC :=0 //Declarada PRIVATE NA FUNÇÃO MT110TOK()

   (_cAlias)->(Dbgotop())

   DO WHILE !((_cAlias)->(EOF()))

      _nConta++
      IF oproc <> nil
          oproc:cCaption := "Lendo "+(_cAlias)->C1_PRODUTO+" - "+ ALLTRIM(STR(_nConta)) + " de " + _cTotReg
          ProcessMessages()
      ENDIF

      aLogAux:={}
      AADD(aLogAux,(_cAlias)->C1_NUM    )// 01
      AADD(aLogAux,(_cAlias)->C1_PRODUTO)// 02
      AADD(aLogAux,(_cAlias)->C1_ITEM   )// 03
      AADD(aLogAux,(_cAlias)->C1_EMISSAO)// 04
      AADD(aLogAux,(_cAlias)->C1_SOLICIT)// 05
      AADD(aLogAux,(_cAlias)->C1_QUANT  )// 06

      AADD(aLogAux,(_cAlias)->C1_PEDIDO )// 07
      AADD(aLogAux,(_cAlias)->C7_ITEM   )// 08
      AADD(aLogAux,(_cAlias)->C7_QUANT  )// 09
      AADD(aLogAux,.F.                  )// 10
      AADD(aLog,aLogAux)

      IF (_nPos:=ASCAN(aMotivos,{|C| C[1] == (_cAlias)->C1_PRODUTO })) = 0
         aMotAux:={}
         AADD(aMotAux,(_cAlias)->C1_PRODUTO )// 01
         AADD(aMotAux,""    )                // 02
         AADD(aMotAux,SPACE(nTamMOT))        // 03
         AADD(aMotAux,.F.  )                 // 04
         AADD(aMotivos,aMotAux)
         _nPos:=LEN(aMotivos)
      ENDIF
      IF _nPos > 0 .AND. aLogAux[6] > 0 .AND. !_cObsSC $ aMotivos[_nPos,2]
         aMotivos[_nPos,2]:= aMotivos[_nPos,2] + _cObsSC
      ENDIF
      IF _nPos > 0 .AND. aLogAux[9] > 0 .AND. !_cObsPC $ aMotivos[_nPos,2]
         aMotivos[_nPos,2]:= aMotivos[_nPos,2] + _cObsPC
      ENDIF

      _nTotSC:= ((_cAlias)->C1_QUANT-(_cAlias)->C7_QUANT)
      _nTotPC:= (_cAlias)->C7_QUANT
      IF (_nPos:=ASCAN(_aTotais,{|C| C[1] == (_cAlias)->C1_PRODUTO })) = 0

         aTotAux:={}
         AADD(aTotAux,(_cAlias)->C1_PRODUTO )// 01
         AADD(aTotAux,_nTotSC)               // 02
         AADD(aTotAux,_nTotPC)               // 03

         AADD(_aTotais,aTotAux)
      ELSE
         _aTotais[_nPos,2]+=_nTotSC 
         _aTotais[_nPos,3]+=_nTotPC 
      ENDIF

      (_cAlias)->(Dbskip())

   Enddo

   lTemSol:=LEN(aLog) > 0
   aLog2:={}
   _cObs:="[Tem saldo em estoque]"
   SB2->(dbSetOrder(1))
   SBZ->(DBSETORDER(1))
   FOR I := 1 TO LEN(_aItens)
      If SB2->(dbSeek(xFilial()+_aItens[I]))
          DO WHILE SB2->(!EOF()) .AND. xFilial("SB2")+_aItens[I] == SB2->B2_FILIAL+SB2->B2_COD

            nSaldo := SB2->(SaldoSB2())//AVALIAR O ESTOQUE DO PRODUTO EM TODOS OS ARMAZENS

            IF nSaldo > 0 .OR. lTemSol
			       SBZ->(DBSEEK(xFilial()+_aItens[I]))

                aLogAux:={}
                AADD(aLogAux,_aItens[I] )  //01
                AADD(aLogAux,SB2->B2_LOCAL)//02
                AADD(aLogAux,SBZ->BZ_EMIN) //03
                AADD(aLogAux,nSaldo)       //04
                AADD(aLogAux,.F.)          //05
                AADD(aLog2,aLogAux)

                IF nSaldo > 0
                   IF (_nPos:=ASCAN(aMotivos,{|C| C[1] == _aItens[I] })) = 0
                      aLogAux:={}
                      AADD(aLogAux,_aItens[I]    )//01
                      AADD(aLogAux,_cObs )        //02
                      AADD(aLogAux,SPACE(nTamMOT))//03
                      AADD(aLogAux,.F.)           //04
                      AADD(aMotivos,aLogAux)
                   ELSEIF _nPos > 0 .AND. !_cObs $ aMotivos[_nPos,2]
                      aMotivos[_nPos,2]:= aMotivos[_nPos,2] + _cObs
                   ENDIF
                ENDIF

               ENDIF
               SB2->(DBSKIP())
           ENDDO
      ENDIF
   Next I

 ELSEIF  _cAcao = "LISTA" .AND. (LEN(aLog) > 0 .OR. LEN(aLog2) > 0)

   IF LEN(aLog) = 0
      aLogAux:={}
      AADD(aLogAux,"" )// 01
      AADD(aLogAux,"" )// 02
      AADD(aLogAux,"" )// 03
      AADD(aLogAux,"" )// 04
      AADD(aLogAux,"" )// 05
      AADD(aLogAux,0  )// 06
      AADD(aLogAux,"" )// 07
      AADD(aLogAux,"" )// 08
      AADD(aLogAux,0  )// 09
      AADD(aLogAux,.F.)// 10
      AADD(aLog,aLogAux)
   Else//COLOCA OS TOTAIS NO FINAL DA LISTA
      FOR I := 1 TO LEN(_aTotais)
          aLogAux:={}
          AADD(aLogAux,"")           // 01
          AADD(aLogAux,_aTotais[I,1])// 02
          AADD(aLogAux,"")           // 03
          AADD(aLogAux,"")           // 04
          AADD(aLogAux,"Total SCs" ) // 05
          AADD(aLogAux,_aTotais[I,2])// 06
          AADD(aLogAux,"" )          // 07
          AADD(aLogAux,"Total PVs" ) // 08
          AADD(aLogAux,_aTotais[I,3])// 09
          AADD(aLogAux,.F.)// 10
          AADD(aLog,aLogAux)
      Next I
   ENDIF
   //-------------------------------------------|
   //Estrutura do aHeader do MsNewGetDados      |
   //-------------------------------------------|
   //aHeader[01] - X3_TITULO  | Título          |
   //aHeader[02] - X3_CAMPO   | Campo           |
   //aHeader[03] - X3_PICTURE | Picture         |
   //aHeader[04] - X3_TAMANHO | Tamanho         |
   //aHeader[05] - X3_DECIMAL | Decimal         |
   //aHeader[06] - X3_VALID   | Validação       |
   //aHeader[07] - X3_USADO   | Usado           |
   //aHeader[08] - X3_TIPO    | Tipo            |
   //aHeader[09] - X3_F3      | F3              |
   //aHeader[10] - X3_CONTEXT | Contexto (R,V)  |
   //aHeader[11] - X3_CBOX    | Combobox        |
   //aHeader[12] - X3_RELACAO | Inicial. Padrao |
   //aHeader[13] - X3_WHEN    | Habilita edicao |
   //aHeader[14] - X3_VISUAL  | Alteravel (A,V) |
   //aHeader[15] - X3_VLDUSER | Valid de User   |
   //aHeader[16] - X3_PICTVAR | Picture         |
   //aHeader[17] - X3_OBRIGAT | Obrigatorio     |

   aHeader1:={}
   ////aHeader,{X3_TITULO)     , X3_CAMPO   , PICT                  ,Tamanho             ,D,VAL,USADO,X3_TIPO,ARQUIVO,X3_CONTEXT,X3_CBOX,X3_RELACAO,X3_WHEN   ,X3_VISUAL ,X3_VLDUSER,X3_PICTVAR,X3_OBRIGAT
   AADD(aHeader1,{"SC"         ,"C1_NUM"    ,"@!"                   ,LEN(SC1->C1_NUM)    ,0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})// 01
   AADD(aHeader1,{"Produto"    ,"C1_PRODUTO","@!"                   ,LEN(SC1->C1_PRODUTO),0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})// 02
   AADD(aHeader1,{"Item SC"    ,"C1_ITEM"   ,"@!"                   ,LEN(SC1->C1_ITEM)   ,0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})// 03
   AADD(aHeader1,{"Dt emissao" ,"C1_EMISSAO","@D"                   ,08                  ,0,""  ,""  ,"D"    ,""     ,""        ,""     ,""        ,".F."})// 04
   AADD(aHeader1,{"Solicitante","C1_SOLICIT","@!"                   ,LEN(SC1->C1_SOLICIT),0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})// 05
   AADD(aHeader1,{"Qtde SC"    ,"C1_QUANT"  ,"@E 999,999,999.999"   ,13                  ,3,""  ,""  ,"N"    ,""     ,""        ,""     ,""        ,".F."})// 06
   AADD(aHeader1,{"Pedido"     ,"C1_PEDIDO" ,"@!"                   ,LEN(SC1->C1_PEDIDO ),0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})// 07
   AADD(aHeader1,{"Item PC"    ,"C7_ITEM"   ,"@!"                   ,LEN(SC7->C7_ITEM   ),0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})// 08
   AADD(aHeader1,{"Qtde PC"    ,"C7_QUANT"  ,"@E 999,999,999.999"   ,13                  ,3,""  ,""  ,"N"    ,""     ,""        ,""     ,""        ,".F."})// 09

   aHeader2:={}
   AADD(aHeader2,{"Produto"    ,"C1_PRODUTO","@!"                   ,LEN(SC1->C1_PRODUTO),0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
   AADD(aHeader2,{"Armazem"    ,"B2_LOCAL"  ,"@!"                   ,LEN(SB2->B2_LOCAL)  ,0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
   AADD(aHeader2,{"Estoque Min","B2_LOCAL"  ,"@E 99,999,999,999.999",15                  ,3,""  ,""  ,"N"    ,""     ,""        ,""     ,""        ,".F."})
   AADD(aHeader2,{"Saldo"      ,"C1_QUANT"  ,"@E 99,999,999,999.999",15                  ,3,""  ,""  ,"N"    ,""     ,""        ,""     ,""        ,".F."})

   cVal:="U_MT110TVal()"
   aHeader3:={}
   AADD(aHeader3,{"Produto"                 ,"C1_PRODUTO","@!"      ,LEN(SC1->C1_PRODUTO),0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
   AADD(aHeader3,{"Observação"              ,"OBS"       ,"@!"      ,100                 ,0,""  ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
   AADD(aHeader3,{"Digite o motivo p/ item" ,"MOTIVO"    ,"@!"      ,LEN(SC1->C1_I_MOTSC),0,cVal,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."})

   cTit1  :="LISTA DOS ITENS COM SOLICITACOES EM ABERTA OU COM SALDO EM ESTOQUE (MT110TOK)"
   _aSize := MsAdvSize()
   _aInfo := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 3 , 3 }
   // PEGA TAMANHOS DAS TELAS
   aObjects := {}
   AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
   AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )
   aPosObj  := MsObjSize( _aInfo , aObjects )

   aFoders1:={}
   AADD(aFoders1,"Solicitações / Pedidos")        //Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa
   AADD(aFoders1,"Saldo em Armazens")             //Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa
   AADD(aFoders1,"Motivo")

   _lOK  :=.F.
   nLin01:=05
   nLin02:=08
   nLin03:=25
   nCol01:=02

   _bOK:={|| aMotivos:=oBrwMOTI:aCols , IF( LEN(aMotivos) = 0 .OR. LEN(ALLTRIM(aMotivos[1,3])) > 10 , (_lOK:=.T. ,oDlg2:End() ), ;
             U_ITMSG("Preencha o campo motivo de cada produto na aba motivo.","ATENCAO","Com mais de 10 caracteres.",1) ) }

   U_ITMSG("Já existe SC(s) / PC(s) em aberto ou saldo em estoque para esse(s) produto(s).","ATENCAO",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
              "Caso queria incluir assim mesmo clique em CONFIRMA na proxima tela, caso contrário favor contatar o solicitante da S.C. em aberto para maiores detalhes.",1)

   DO WHILE .T.

      DEFINE MSDIALOG oDlg2 TITLE cTit1 OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]

      oPnlTopTop := TPanel():New( 1 , 0 , , oDlg2 , , , , , , 80 , 20 , .F. , .F. )

       @ nLin01, nCol01 BUTTON  "CONFIRMA"  SIZE 035, 14 OF oPnlTopTop ACTION (EVAL(_bOK)) PIXEL

       @ nLin01, nCol01+40 BUTTON  "VOLTAR"    SIZE 035, 14 OF oPnlTopTop ACTION (_lOK:=.F.,oDlg2:End()) PIXEL

       //FOLDER PRINCIPAL COM 3 PASTAS **************************************************************************
        _nColFolder:=aPosObj[2,4]
       _nLinFolder:=aPosObj[2,3]-10

       oTFolder01:= TFolder():New( nLin03,1,aFoders1,,oDlg2,,,,.T., , _nColFolder,_nLinFolder )

       oPastaSCPC:=oTFolder01:aDialogs[1]

       oBrwSCPC:=MT110TBrw(aHeader1,aLog,oPastaSCPC)

       oPastaESTO:=oTFolder01:aDialogs[2]

       oBrwESTO:=MT110TBrw(aHeader2,aLog2,oPastaESTO)

       oPastaMOTI:=oTFolder01:aDialogs[3]

       oBrwMOTI:=MT110TBrw(aHeader3,aMotivos,oPastaMOTI)

      ACTIVATE MSDIALOG oDlg2 ON INIT (oPnlTopTop:Align:= CONTROL_ALIGN_TOP      ,;
                                        oTFolder01:Align:= CONTROL_ALIGN_ALLCLIENT,;
                                          oBrwMOTI:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT,;
                                          oBrwESTO:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT,;
                                         oBrwSCPC:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT )
      _lLoop:=.F.
      IF _lOK
         aMotivos:=oBrwMOTI:aCols
         For I := 1 to LEN(aMotivos)
            IF LEN(ALLTRIM(aMotivos[I,3])) < 10
               U_ITMSG("Preencha o campo motivo do produto "+aMotivos[I,1]+" na aba motivo.","ATENCAO","Com mais de 10 caracteres.",1)
               _lLoop:=.T.
               EXIT
            ENDIF
            IF (_nPos:=ASCAN(aCols,{|C| C[_nPosProdut] == aMotivos[I,1] })) > 0 .AND. _nPosMotivo > 0
                  aCols[_nPos,_nPosMotivo ] := aMotivos[I,3]
            ENDIF
         Next I
      ENDIF
      IF _lLoop
         LOOP
      ENDIF
      EXIT
   ENDDO

 ENDIF

RETURN _lOK

/*
===============================================================================================================================
Programa--------: MT110TBrw
Autor-----------: Alex Wallauer
Data da Criacao-: 14/03/2024
Descrição-------: Cria os blowses
Parametros------: aHeaderP,_aColsP,oPasta
Retorno---------: oMsMGet
===============================================================================================================================*/
Static Function MT110TBrw(aHeaderP,_aColsP,oPasta) As Object
 LOCAL oMsMGet

 IF LEN(_aColsP) > 0
    nGDAction:= GD_UPDATE
 ELSE
    RETURN .F.
 ENDIF
                              //[ nTop]          , [ nLeft]   , [ nBottom] , [ nRight ] , [ nStyle],cLinhaOk,cTudoOk,cIniCpos, [ aAlter], [ nFreeze], [ nMax], [ cFieldOk], [ cSuperDel], [ cDelOk], [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize]
 oMsMGet := MsNewGetDados():New((aPosObj[2,1]+12),aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nGDAction ,        ,       ,        ,          ,           ,        ,            ,             ,          ,oPasta  ,aHeaderP        , _aColsP   ,)
 oMsMGet:SetEditLine(.F.)

RETURN oMsMGet


/*
===============================================================================================================================
Programa--------: MT110TVal
Autor-----------: Alex Wallauer
Data da Criacao-: 14/03/2024
Descrição-------: Valida a coluna Motivo
Parametros------: Nenhum 
Retorno---------: .T. se tudo ok, .F. se tiver algum erro
===============================================================================================================================*/
USER Function MT110TVal() As Logical

 Local aMotivos:=oBrwMOTI:aCols
 Local _nLin   :=oBrwMOTI:oBrowse:nat As Numeric
 Local _cSalvaMot As Character
 Local nX As Numeric

 IF LEN(aMotivos) = 0 .OR. LEN(ALLTRIM(M->MOTIVO)) > 10 
    IF _nLin = 1 .AND. U_ITMSG("Replicar esse motivo para as linhas abaixo? "+CRLF+" Os motivos abaixo preenchidos serão sobrescritos.","Atenção",,3,2,2)
       _cSalvaMot:=M->MOTIVO
       For nX := 2 to len(aMotivos)
           aMotivos[nX,3] := _cSalvaMot
       Next nX
       oBrwMOTI:aCols := aMotivos
       oBrwMOTI:oBrowse:Refresh()
    EndIF   
 Else
    U_ITMSG("Preenchimento do campo motivo INVALIDO!","ATENCAO","Preencha esse campo com mais de 10 caracteres.",1)
    Return .F. 
 Endif

Return .T.
