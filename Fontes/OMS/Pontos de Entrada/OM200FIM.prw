/*
===========================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===========================================================================================================================================
      Autor  |    Data  |                                             Motivo
===========================================================================================================================================
Alex Wallauer| 17/01/24 | Chamado 46079. Gravacao dos campos novos do DAK: DAK_I_TRNF/DAK_I_FITN/DAK_I_INCC/DAK_I_INCF.
Julio Paz    | 21/02/24 | Chamado 45229. Desenvolvimentos Webservice TMS. Replicar conteúdo do campo C5_I_CDTMS para pedidos de Pallet.
Alex Wallauer| 28/02/24 | Chamado 46694. Jerry. Alteracao para não marcar e-mail enviado se o e-mail não for enviado.
Julio Paz    | 02/04/24 | Chamado 29917. Jerry. Ajustar geração carga p/gravar tipo frete do PV com "R", quando a frota veic = 1=propria
Alex Wallauer| 29/07/24 | Chamado 48024. Jerry. Retirado os IFs de testes para enviar e-mail para os sistema.
Alex Wallauer| 01/08/24 | Chamado 46599. Vanderlei. Nova validacao de Agrupamento de Pedidos.
===========================================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================================================================
Jerry         - Julio Paz    - 22/01/24 - 26/02/25 - 49300   - Ajustar a Rotina de Geração de Pedidos de Pallets na Geração da Carga para Deixar o Tipo de Frete do Pedido de Pallet Igual ao Tipo de Frete do Pedido das Mercadorias.
Vanderlei     - Alex Wallauer- 27/03/24 - 10/06/25 - 50188   - Gravacao do campo DAK->DAK_I_LEMB COM SC5->C5_I_LOCEM do 1o pedido da carga.
Vanderlei     - Alex Wallauer- 25/03/24 -          - 49894   - Novos rateios de peso bruto por itens de NF, Campo novo DAI_I_FROL.
================================================================================================================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "TOPCONN.ch"
#Include "PROTHEUS.ch"
#Include "RWMAKE.ch"
#Include "COLORS.ch"
#INCLUDE "Fileio.ch"

#Define DS_MODALFRAME	128
#Define TP_GERA_PALET   "1,3,5,6" //"1-Pallet Chep","3-Pallet PBR","4-Pallet Descartavel","5-Pallet Chep Retorno","6-Pallet PBR Retorno"
#Define OBS_PRE_CARGA   "PRE-CARGA - Dados do Transporte serão informados posteriormente. "
/*
===============================================================================================================================
Programa----------: OM200FIM
Autor-------------: Tiago Correa
Data da Criacao---: 25/01/2009
Descrição---------: Ponto de Entrada no momento da gravacao da Montagem de Carga.
Parametros--------: Padrão
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC _cTipo    := Space(1)
STATIC _cTpCarga := -1
STATIC _cAuto    := Space(LEN(ZZ2->ZZ2_AUTONO))
STATIC _cCond    := Space(LEN(ZZ2->ZZ2_COND))
STATIC _cObs     := Space(LEN(ZZ2->ZZ2_OBS))
STATIC _cObsCarga:= ""//Space(LEN(DAK->DAK_I_OBS)) // Para variavel usada em GET MEMO nao precisa inicia com space()
STATIC _nValor   := 0
STATIC _nPedagio := 0
STATIC _nFretOL2 := 0
STATIC _cProtoc  := Space(LEN(ZZ2->ZZ2_PAMCAR))
STATIC _nVlrPam  := 0
STATIC _cREDP    := Space(LEN(DAK->DAK_I_REDP))
STATIC _cRELO    := Space(LEN(DAK->DAK_I_RELO))
STATIC _cOPER    := Space(LEN(DAK->DAK_I_OPER))
STATIC _cOPLO    := Space(LEN(DAK->DAK_I_OPLO))
STATIC _aLog     := {}
STATIC _cPreCarga:= "2-Não"//DAK->DAK_I_PREC

User Function OM200FIM(lAcertaCarga)
 Local aArea := FwGetArea()
 Local _aDAI := FwGetArea("DAI")
 Local _aSC9 := FwGetArea("SC9")
 Local _cTpFroVei, _nRegSC5

 Private cCarga 	   := DAK->DAK_COD

 IF TYPE("_cMotorDAK") <> "C" .OR. EMPTY(_cMotorDAK)//Na efetivação da pre-carga vem em branco o DAK e mata o que foi digitado
    Private _cMotorDAK := DAK->DAK_MOTORI
 ENDIF
 IF TYPE("_cCaminDAK") <> "C" .OR. EMPTY(_cCaminDAK)//Na efetivação da pre-carga vem em branco o DAK e mata o que foi digitado
    Private _cCaminDAK := DAK->DAK_CAMINH
 ENDIF

 DEFAULT lAcertaCarga := .F.

 If !(type("_lAutomatico")) == "L"

     _lAutomatico := .F.

 Endif

 //===========================================================
 // Obtem o tipo de frota de veiculo da carga.
 //===========================================================
 _cTpFroVei :=  Posicione( 'DA3' , 1 , xFilial('DA3')+DAK->DAK_CAMINH , 'DA3_FROVEI' ) // 1=DA3_FILIAL+DA3_COD

 //================================================================================
 //| I N I C I O - Tratamento para gravacao dos dados do Frete.                   |
 //================================================================================

 If ! _lAutomatico
   FwMsgRun( , {|| Eval( {|| CalcFrete(lAcertaCarga) } )  },"Aguarde","Gravando dados customizados..."  )

   FwMsgRun( ,{|| OM200Email(.F.) } ,'Aguarde!','Enviando WF ...'  )

   IF LEN(_aLog) > 0
      _bCancel := {|| MSGSTOP("A montagem de Carga esta Concluida, clique no botão CONFIRMAR.","Atenção! (OM200FIM)") }
      _lRet:=U_ITListBox( 'Log de Geracao de Pedidos de Pallets - Carga: '+cCarga+" (OM200FIM)",;
                         {" ",'Pedido Origem','Pedido Gerado','Movimentacao','Cliente','Operacao','Armazem','Filial Carregamento','Filial Faturamento'} , _aLog , .T. , 4,,,;
                         { 10,             50,             50,           150,      150,        35,       35,                   60,                  60},,,_bCancel )
   EndIf
 Else
   CalcFrete(lAcertaCarga)

   OM200Email(.F.)
 EndIf

 _aLog:= {}

 //Código de segurança para garantir que todos os registros no SC9 de pedidos que estão na DAI estão com campos de carga gravados corretamente
 DAI->(Dbsetorder(1))
 SC9->(Dbsetorder(1))
 SC5->(DbSetOrder(1))

 If DAI->(Dbseek(DAK->DAK_FILIAL+DAK->DAK_COD))

   _nRegSC5 := SC5->(Recno())
   Do while DAI->DAI_FILIAL == DAK->DAK_FILIAL .AND. DAI->DAI_COD == DAK->DAK_COD

      //=================================================================================
      // Para frota de veículo própria, atualizar pedido vendas com tipo de frete = "R"
      //=================================================================================
      If ! Empty(_cTpFroVei) .And. _cTpFroVei == "1" // Frota própria
         If SC5->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))
            SC5->(RecLock("SC5",.F.))
            SC5->C5_TPFRETE := "R" // R=POR CONTA REMETENTE
            SC5->(MsUnLock())
         EndIf
      EndIf

      If SC9->(Dbseek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))

         Do while SC9->C9_FILIAL == DAI->DAI_FILIAL .AND. SC9->C9_PEDIDO == DAI->DAI_PEDIDO

            SC9->(Reclock("SC9",.F.))

            SC9->C9_CARGA  := DAI->DAI_COD
            SC9->C9_SEQCAR := DAI->DAI_SEQCAR
            SC9->C9_SEQENT := DAI->DAI_SEQUEN

            SC9->(Msunlock())

            SC9->(Dbskip())
         Enddo

      EndIf

      DAI->(Dbskip())

   Enddo

   SC5->(DbGoTo(_nRegSC5))

 Endif

 FwRestArea(aArea)
 DAI->(FwRestArea(_aDAI))
 SC9->(FwRestArea(_aSC9))

Return()

/*
===============================================================================================================================
Programa----------: TelaFrt ==> OM200Tela()
Autor-------------: Tiago Correa
Data da Criacao---: 25/01/2009
Descrição---------: Gravação dos dados do Frete.
Parametros--------: lEfetiva_Pre_Carga: Se chamou da ações relacionadas é .T. ,
                    _lPreCarga        : se respondeu sim na pergunta é .T.
                    _lScheduller      : .T. informa ser a rotina está sendo rodada via scheduler ou .F. se a rotina é manual.
                    _lSoGeraPallet    : .T. informa ser a rotina está sendo rodada só para gerar Pallet para PV Sedex
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function OM200Tela(lEfetiva_Pre_Carga , _lPreCarga , _lScheduller , _lSoGeraPallet)//Chamada do Rdmake OM200OK.PRW e OM200MNU.PRW
 Local _aArea  := FwGetArea()
 Local lRetorno:= .F.
 Local _nLinha := 15
 Local _nPula  := 15
 Local _nCol1  := 006
 Local _nCol2  := 090
 Local _nCol3  := _nCol2+90//75//155
 Local _nCol4  := _nCol3+50//205
 Local _nCol5  := _nCol2+40
 Local _nCol6  := 572//322
 Local _nCol7  := _nCol4+75
 Local _nCol8  := _nCol7+50
 Local _nTamMe := 370//265
 Local aCpoBrw := {}
 Private _nColOLFOL:=0

 DEFAULT lEfetiva_Pre_Carga:= .F.
 DEFAULT _lSoGeraPallet:= .F.

 Aadd(aCpoBrw,{"PED_PEDIDO",,"Pedido"})
 Aadd(aCpoBrw,{{|| IF(TRBPED->PED_I_REDP="1","Sim","Nao") },,"Redespacho?"})
 nColTR:=LEN(aCpoBrw)//Varialvel usada na funcao OM200Marca() para os 2 cliques da coluna
 Aadd(aCpoBrw,{"PED_I_TRED",,"Trans Red"})
 _nColTRGet:=LEN(aCpoBrw)//Varialvel usada na funcao OM200Marca() para os 2 cliques da coluna
 Aadd(aCpoBrw,{"PED_I_LTRE",,"Loja Red"})
 Aadd(aCpoBrw,{{|| IF(TRBPED->PED_I_OPER ="1","Sim","Nao") },,"Oper. Logistico?"})
 nColOL:=LEN(aCpoBrw)//Varialvel usada na funcao OM200Marca() para os 2 cliques da coluna
 Aadd(aCpoBrw,{"PED_I_OPLO",,"Trans Op Log"})
 _nColOLGet:=LEN(aCpoBrw)//Varialvel usada na funcao OM200Marca() para os 2 cliques da coluna
 Aadd(aCpoBrw,{"PED_I_LOPL",,"Loja Op Log"})
 IF DAK->(FIELDPOS("DAK_I_FROL")) > 0 .AND.  DAI->(FIELDPOS("DAI_I_FROL")) > 0
    Aadd(aCpoBrw,{"PED_I_FROL",,"Fret.2o Perc."  ,X3Picture("DAI_I_FROL")  })
    _nColOLFOL:=LEN(aCpoBrw)//Varialvel usada na funcao OM200Marca() para os 2 cliques da coluna
 EndIf
 Aadd(aCpoBrw,{ {|| IF(TRBPED->PED_I_TIPC="1","1-Pallet Chep",IF(TRBPED->PED_I_TIPC="2","2-Estivada",IF(TRBPED->PED_I_TIPC="3","3-Pallet PBR",IF(TRBPED->PED_I_TIPC="4","4-Pallet Descartavel",IF(TRBPED->PED_I_TIPC="5","5-Pallet Chep Retorno",IF(TRBPED->PED_I_TIPC="6","6-Pallet PBR Retorno","            "))))))  },,"Tipo da Carga?"} ) //TP_GERA_PALET
 nColTP:=LEN(aCpoBrw) //Varialvel usada na funcao OM200Marca() para os 2 cliques da coluna
 Aadd(aCpoBrw,{{|| TRBPED->PED_I_QTPA },,"Qtde Pallet","@E 999,999"})
 nColQT:=LEN(aCpoBrw) //Varialvel usada na funcao OM200Marca() para os 2 cliques da coluna
 Aadd(aCpoBrw,{"PED_I_OBPE",,"Observação do Pedido"})
 Aadd(aCpoBrw,{{|| IF(TRBPED->PED_I_AGEN="A","A-Agendada"  ,IF(TRBPED->PED_I_AGEN="I","I-Imediata",IF(TRBPED->PED_I_AGEN="S","S-Suspensa",IF(TRBPED->PED_I_AGEN="M","M-Agendada Multa","            ")))) },,"Tipo de Agenda"})
 Aadd(aCpoBrw,{"PED_CODCLI",,"Cliente"})
 Aadd(aCpoBrw,{"PED_LOJA"  ,,"Loja"})
 Aadd(aCpoBrw,{"PED_NOME"  ,,"Nome"})
 Aadd(aCpoBrw,{"PED_VALOR" ,,"Valor" ,"@E 9,999,999,999."+Replicate("9",TamSx3("DAK_VALOR")[2]) })
 Aadd(aCpoBrw,{"PED_PESO"  ,,"Peso"  ,"@E 9,999,999,999."+Replicate("9",TamSx3("DAK_PESO")[2])  })
 Aadd(aCpoBrw,{{|| IF(POSICIONE("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_I_TRCNF")="S","Sim","Não")  },,"Troca Nota"})
 Aadd(aCpoBrw,{{|| POSICIONE("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_I_PEDPA")  },,"Ped. de Pallet?"})
 Aadd(aCpoBrw,{{|| POSICIONE("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_I_PEDGE")  },,"Ped. Gerou Pallet?"})
 Aadd(aCpoBrw,{{|| POSICIONE("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_I_NPALE")  },,"Pedido Pallet"})
 Aadd(aCpoBrw,{{|| POSICIONE("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_I_OPER")   },,"Tipo Oper."})
 Aadd(aCpoBrw,{{|| IF(POSICIONE("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_I_OPTRI")="R","Remessa","Venda")  },,"Oper Triangular"})//"F=Ped. Venda;R=Ped. Remessa"
 Aadd(aCpoBrw,{{|| POSICIONE("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_I_PEVIN")   },,"PV Vinculado"})

 Private	_aTipoFrete:= { "Autonomo" , "PJ-Transportadora" , "IT-Veiculo Proprio" }
 Private _lAutVeic  := .F.
 Private oMarkFim
 Private _ocRedp
 Private _ocReLo
 Private _oOper
 Private _oOpLo
 Private _oFret2
 Private _lAutomatico
 Private _lVersao12 := .T.//(AllTrim(OAPP:CVERSION) = "12")
 Private _nAltCombo :=IF(_lVersao12,10,20)
 Private _cEstados  := " "//Variavel preenchida para o F3 dos operadores, NÃO RETIRE

 If Empty(_lScheduller)
   _lAutomatico := .F. // Rotina rodada manualmente

   PRIVATE _AITALAC_F3:={}
   _BSelectZ31:={|| "SELECT DISTINCT Z31_FORNEC, Z31_LOJA, Z31_NOMEFO, Z31_UF, A2_CGC FROM " + RETSQLNAME("Z31")+" Z31, " + RETSQLNAME("SA2") + " SA2  WHERE"+;
                    " Z31_UF  = '"+SC5->C5_I_EST+"' AND "+;
                    " Z31.D_E_L_E_T_ <> '*' AND SA2.D_E_L_E_T_ <> '*' AND Z31_FORNEC = A2_COD AND Z31_LOJA = A2_LOJA ORDER BY Z31_FORNEC, Z31_LOJA " }

   _BSelec2Z31:={|| "SELECT DISTINCT Z31_FORNEC, Z31_LOJA, Z31_NOMEFO, Z31_UF, A2_CGC FROM " + RETSQLNAME("Z31")+" Z31, " + RETSQLNAME("SA2") + " SA2  WHERE"+;
                    " Z31_UF   IN "+ FormatIn( _cEstados , ";" )+" AND "+;
                    " Z31.D_E_L_E_T_ <> '*' AND SA2.D_E_L_E_T_ <> '*' AND Z31_FORNEC = A2_COD AND Z31_LOJA = A2_LOJA ORDER BY Z31_FORNEC, Z31_LOJA " }

   //AD(_aItalac_F3,{"_CAMPO1" ,_cTabela    ,_nCpoChave                                , _nCpoDesc                                             ,_bCondTab, _cTitAux                     , _nTamChv                         , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
   AADD(_aItalac_F3,{"_cOpPed" ,_BSelectZ31 ,{|Tab| (Tab)->Z31_FORNEC+(Tab)->Z31_LOJA }, {|Tab| (Tab)->A2_CGC+" "+ALLTRIM((Tab)->Z31_NOMEFO) } ,         ,"Operadores com Transit Time" ,LEN(Z31->Z31_FORNEC+Z31->Z31_LOJA),          ,1        ,.F.        ,       , } )
   AADD(_aItalac_F3,{"_cF3REDP",_BSelec2Z31 ,{|Tab| (Tab)->Z31_FORNEC+(Tab)->Z31_LOJA }, {|Tab| (Tab)->A2_CGC+" "+ALLTRIM((Tab)->Z31_NOMEFO) } ,         ,"Operadores com Transit Time" ,LEN(Z31->Z31_FORNEC+Z31->Z31_LOJA),          ,1        ,.F.        ,       , } )
   AADD(_aItalac_F3,{"_cF3OPER",_BSelec2Z31 ,{|Tab| (Tab)->Z31_FORNEC+(Tab)->Z31_LOJA }, {|Tab| (Tab)->A2_CGC+" "+ALLTRIM((Tab)->Z31_NOMEFO) } ,         ,"Operadores com Transit Time" ,LEN(Z31->Z31_FORNEC+Z31->Z31_LOJA),          ,1        ,.F.        ,       , } )
 Else
    _lAutomatico := _lScheduller
 EndIf

 _cPreCarga := IF(_lPreCarga,"1-Sim","2-Não")//DAK->DAK_I_PREC
 //===========================
 //Gravo celular do motorista
 //===========================
 DA4->(dbSetOrder(1))
 IF !_lSoGeraPallet .AND. !EMPTY(_cMotorDAK) .AND. DA4->(dbSeek(xFilial("DA4")+_cMotorDAK))
    _cDDD := DA4->DA4_DDD
    _cCEL := DA4->DA4_TEL
 ELSE
    _cDDD := SPACE(LEN(DA4->DA4_DDD))
    _cCEL := SPACE(LEN(DA4->DA4_TEL))
 ENDIF
 _cTipo:=_aTipoFrete[1]
 IF !lEfetiva_Pre_Carga

   _bMarcaTRB:=oMark:bAval//Salva os 2 cliques da tela de selecao de Pedidos da Tela anterior para usar para marcar depois que incliir linhas no TRB EVAL(_bMarcaTRB)

   IF _lPreCarga
      _cTipo:=_aTipoFrete[2]//Forcei 2 na pre-carga por causa das mensagem no estorno da carga do ZZ2 (OS200ES2.PRW)
   ENDIF

 ELSEIF !_lSoGeraPallet

    _cObsCarga:=StrTran(ALLTRIM(UPPER(DAK->DAK_I_OBS)),ALLTRIM(UPPER(OBS_PRE_CARGA)),"")
    _nPedagio:=DAK->DAK_I_VRPE
    _cTipo := _aTipoFrete[VAL(DAK->DAK_I_TPFR)]
    _cREDP := DAK->DAK_I_REDP
    _cRELO := DAK->DAK_I_RELO
    _cOPER := DAK->DAK_I_OPER
    _cOPLO := DAK->DAK_I_OPLO
    _nValor:= DAK->DAK_I_FRET
    IF DAK->(FIELDPOS("DAK_I_FROL")) > 0
       _nFretOL2:=DAK->DAK_I_FROL
    Endif
    If _lAutomatico
       If !EMPTY(_cMotorDAK) .AND. DAK->DAK_I_TPFR = "1"
            SA2->(DBSETORDER(1))       //DA4 já esta posicionado acima
          IF SA2->( DBSeek( xFilial("SA2") + DA4->DA4_FORNEC+DA4->DA4_LOJA ) )
             _cAuto:=SA2->A2_I_AUT
             _cCond:=SA2->A2_COND
          ENDIF
       ENDIF
       //U_ITCONOUT("Tipo: "+_cTipo+", Motorista: "+_cMotorDAK+", Forn.: "+DA4->DA4_FORNEC+DA4->DA4_LOJA+", Cod. Aut./Cond.: "+_cAuto+"/"+_cCond) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
    EndIf

 ENDIF

 dbSelectArea("TRBPED")
 DbSetFilter({|| PED_MARCA # ' ' }, "PED_MARCA # ' '" )

 PRIVATE _lTemPalletRetorno:=.F.

 IF !_lSoGeraPallet
    OM200Pallets()//Inicia os tipos e quantidade dos Pallets e a variavel _lTemPalletRetorno
 ENDIF

 DO WHILE .T.

   If ! _lAutomatico // Rotina rodada manualmente
      _nLinha := 15
      _cF3REDP:= _cREDP//VariveL private para o F3 customizado funcionar.
      _cF3OPER:= _cOPER//VariveL private para o F3 customizado funcionar.

      DEFINE MSDIALOG oTelFrete TITLE "Controle de Frete (OM200FIM)" From 000,000 To 530,1185 Pixel


         @_nLinha,006    Say OemToAnsi( "Tipo de Frete:"	)
         @_nLinha,051 COMBOBOX	oTipo VAR _cTipo	SIZE 070,_nAltCombo COLOR CLR_BLACK ITEMS _aTipoFrete	OF oTelFrete PIXEL

         @_nLinha,_nCol3 Say "Pre - Carga ?"
         @_nLinha,_nCol4 COMBOBOX	_cPreCarga SIZE 040,_nAltCombo COLOR CLR_BLACK ITEMS {"1-Sim","2-Não"} OF oTelFrete PIXEL WHEN !_lPreCarga .AND. !lEfetiva_Pre_Carga

         @_nLinha,_nCol7 Say OemToAnsi( "Cod. Autonomo:"	)
         @_nLinha,_nCol8 Get _cAuto	F3 "SA2_08"	Picture "@!"              SIZE 060,021 Valid IIF(Vazio(_cAuto),.T.,VALIDAUT(_cAuto))
         _nLinha+=_nPula

         @_nLinha,006    Say OemToAnsi( "Valor do Frete:"	)
         @_nLinha,051    Get _nValor		    Picture "@E 999,999,999.99" SIZE 060,021 Valid VLDVLPAM( 1 , _nValor , _nVlrPam , _nPedagio)

         @_nLinha,_nCol3 Say "Valor do Pedagio:"
         @_nLinha,_nCol4 Get _nPedagio	    Picture "@E 999,999,999.99"    SIZE 060,021 Valid VLDVLPAM( 3 , _nValor , 0        , _nPedagio)


         @_nLinha,_nCol7 Say OemToAnsi( "Cond. Pagamento:"	)
         @_nLinha,_nCol8 Get _cCond	F3 "SE4"	Picture "@!" SIZE 060,021 Valid IIF(Vazio(_cCond),.T.,ExistCpo("SE4",_cCond))
         _nLinha+=_nPula

         @_nLinha,006    Say OemToAnsi( "Obs. Frete:"		)
         @_nLinha,051    Get _cObs				Picture "@!" SIZE _nTamMe,021
         _nLinha+=_nPula

         @_nLinha,006    Say OemToAnsi( "Obs. Carga:"		)
         @_nLinha,051    GET _cObsCarga MEMO HSCROLL      SIZE _nTamMe,33 PIXEL
         _nLinha+=_nPula+_nPula+10

         @_nLinha,006    Say OemToAnsi( "Prot. Pamcary:"	)
         @_nLinha,_nCol3 Say OemToAnsi( "Valor Pamcary:"	)
         @_nLinha,051    Get _cProtoc Picture "@!"                SIZE 060,021
         @_nLinha,_nCol4 Get _nVlrPam Picture "@E 999,999,999.99"	SIZE 060,021 Valid VLDVLPAM( 2 , _nValor , _nVlrPam )

         _nLinha+=_nPula

         @_nLinha,_nCol1 Say "Transportadora de Redespacho:"
         @_nLinha,_nCol2 msGet _ocredp var _cF3REDP SIZE 033,009 PIXEL OF oTelFrete F3 "F3ITLC"	Valid VLDSA2(_cF3REDP,"TR")                                 Picture "@!"
         @_nLinha,_nCol5 msGet _ocrelo var _cRELO   SIZE 009,009 PIXEL OF oTelFrete             Valid IIF(Vazio(_cF3REDP),.T.,VLDSA2(_cF3REDP+_cRELO,"TR")) Picture "@!"

         @_nLinha,_nCol3 Say "Veiculo:"
         @_nLinha,_nCol4 Get _cCaminDAK F3 "DA3"	Picture "@!" SIZE 060,021 Valid VLDVeiculo(.F.,"VEI") WHEN lEfetiva_Pre_Carga//Só via editar na efetivação pq quando não é precarga digita antes
         If _nColOLFOL > 0
            @_nLinha,_nCol7 Say "Total Frete 2o Percurso:"
            @_nLinha,(_nCol8+15) msGet _oFret2 var _nFretOL2 SIZE 065,009 PIXEL OF oTelFrete Picture X3Picture("DAI_I_FROL") WHEN .F.
         EndIf
         _nLinha+=_nPula

         @_nLinha,_nCol1 Say "Operador Logistico:"
         @_nLinha,_nCol2 msGet _ooper var _cF3OPER	SIZE 033,009 PIXEL OF oTelFrete F3 "F3ITLC"	Valid VLDSA2(_cF3OPER,"OL")                              Picture "@!"
         @_nLinha,_nCol5 msGet _ooplo var _cOPLO	SIZE 009,009 PIXEL OF oTelFrete          	Valid IIF(Vazio(_cF3OPER),.T.,VLDSA2(_cF3OPER+_cOPLO,"OL")) Picture "@!"

         @_nLinha,_nCol3 Say "Motorista:"
         @_nLinha,_nCol4 Get _cMotorDAK F3 "DA4"	Picture "@!" SIZE 060,021 Valid VLDVeiculo(.F.,"MOTO") WHEN lEfetiva_Pre_Carga//Só via editar na efetivação pq quando não é precarga digita antes

         @_nLinha,_nCol7 Say "DDD / Celular:"
         @_nLinha,_nCol8    msGet _cDDD SIZE 010,009 PIXEL OF oTelFrete Picture "99"			Valid NaoVazio(_cDDD) WHEN !EMPTY(_cMotorDAK)
         @_nLinha,_nCol8+15 msGet _cCEL SIZE 036,009 PIXEL OF oTelFrete Picture "999999999"	Valid NaoVazio(_cCEL) WHEN !EMPTY(_cMotorDAK)

         _nLinha+=15

         @_nLinha    ,_nCol1 Say "Clique 2 vezes na linha e coluna para: Alterar entre Sim e Não, Escolher o Rededespacho e o Operador Logistico , Escolher o Tipo da Carga e Digitar a Quantidade de Pallet e Valor do Frete 2o percurso abaixo:"
         _nLinha+=10

         dbSelectArea("TRBPED")
         dbGotop()
         oMarkFim:=MsSelect():New("TRBPED",,,aCpoBrw,.F.,,{_nLinha,_nCol1,(_nLinha+85),  _nCol6 })
         oMarkFim:bAval:= {|| OM200Marca(oMarkFim:oBrowse,lEfetiva_Pre_Carga,aCpoBrw) }
         oMarkFim:oBrowse:lhasMark    := .T.
         oMarkFim:oBrowse:lCanAllmark := .T.

         _nLinha+=90

         @005,003 To _nLinha,(_nCol6+3) Title OemToAnsi("Informações do Frete")

         _nLinha+=02
           @ _nLinha,(_nCol6-400) Button OemToAnsi("OK") Size 36,16 Action	(IIF(ValidaTela( _cTipo , _cAuto , _nValor , _cCond ,  , _cDDD , _cCEL ) .AND.;
                                                                                                         VLDSA2(_cF3REDP+_cRELO,"OKTR") .AND.;
                                                                                                         VLDSA2(_cF3OPER+_cOPLO,"OKOL") .AND.;
                                                                                                         VLDSA2(_cF3OPER+_cOPLO,"OKTD") .AND.;
                                                                                                         VLDSA2("","OKTELA") .AND. VLDVeiculo(.T.),;
                                                                                                         (oTelFrete:End(),lRetorno:=.T.),)	)

         @ _nLinha,(_nCol6-100) Button OemToAnsi("Ver Pedido") Size 36,16 Action	(U_IT_VisuPV(TRBPED->PED_PEDIDO))

         @ _nLinha,(_nCol6-250) Button "Cancela	" Size 36,16 Action	(oTelFrete:End(),lRetorno:=.F.)

      ACTIVATE MSDIALOG oTelFrete CENTERED

      _cREDP := _cF3REDP//Volta o valor para a Staticas
      _cOPER := _cF3OPER//Volta o valor para a Staticas

   Else // Rotina rodada via Scheduller

      lRetorno := .T.

   EndIf

   IF lRetorno
      //==========================================
      //Grava log de utilização da rotina
      //==========================================
      //U_ITLOGACS()

        _aPeds_Pallet:= {}
        _aLog        := {}
      SC5->( DBSetOrder(1) )
      TRBPED->( dbGotop() )
      DO While TRBPED->( !EOF() )

        If !SC5->( DbSeek( xFilial("SC5") + TRBPED->PED_PEDIDO ) )
            //U_ITCONOUT("Pedido:"+TRBPED->PED_PEDIDO+" não encontrado") // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
            TRBPED->( DBSkip() )
            LOOP
        ENDIF

        _nRecPedido:=SC5->(RECNO())
        _cCodPedPallet:=SC5->C5_I_NPALE

        If !EMPTY(_cCodPedPallet) .AND. SC5->( DbSeek( xFilial("SC5") + _cCodPedPallet ) )//Se acho é pq já tem Pedido de Pallet vinculado
            //U_ITCONOUT("Pedido:"+TRBPED->PED_PEDIDO+" com Pedido de Pallet: "+_cCodPedPallet) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
            TRBPED->( DBSkip() )
            LOOP
        ENDIF

          If TRBPED->PED_I_TIPC $ TP_GERA_PALET .AND. !EMPTY(TRBPED->PED_I_QTPA)
            //                   1-Recno do SC5 , 2-Recno do TRB
            AADD(_aPeds_Pallet, { _nRecPedido, TRBPED->(RECNO() ),0,;//3-Recno do Pedido Novo de Pallet
                                                            "Local",;//4-Local do Pedido do Pallet
                                                                  0,;//5-Recno do Item do Pedido Novo de Pallet
                                  TRBPED->PED_PEDIDO,_cCodPedPallet})//Numero dos Pedido para ajudar no DEBUG
        EndIf
        TRBPED->( DBSkip() )
      EndDo

      _lGerouOK := .T.//Private tratada dentro de todas as funções abaixo e usada em programas que chamam essa função U_OM200Tela()
      lAcertaCarga:=.F.

      IF LEN(_aPeds_Pallet) > 0

         BEGIN Transaction
               If ! _lAutomatico // Rotina rodada manualmente
                  FwMsgRun( ,{|oproc| _lGerouOK := GeraPedPallet(_aPeds_Pallet,,oproc) } ,"Aguarde", "Gerando Pedidos de Pallet..." )

                  FwMsgRun( ,{|oproc| LiberaPedPallCarga(_aPeds_Pallet,,oproc) } ,'Aguarde', "Liberando Pedidos de Pallet..." )

                  IF _lGerouOK
                     lAcertaCarga:=lEfetiva_Pre_Carga//Só acerta a Carga de se gerou Pallet na Efetivação da Pre-Carga
                     FwMsgRun( ,{|oproc| IncliPedPallCarga(_aPeds_Pallet,lEfetiva_Pre_Carga,,oproc) } ,'Aguarde', "Incluindo Pedidos de Pallets..." )
                  ENDIF
               Else // Rotina rodada via Scheduller
                  _lGerouOK := GeraPedPallet(_aPeds_Pallet,_lAutomatico)

                  LiberaPedPallCarga(_aPeds_Pallet,_lAutomatico)

                  IF _lGerouOK .AND. !_lSoGeraPallet
                     lAcertaCarga:=lEfetiva_Pre_Carga//Só acerta a Carga de se gerou Pallet na Efetivação da Pre-Carga
                     IncliPedPallCarga(_aPeds_Pallet,lEfetiva_Pre_Carga,_lAutomatico)
                    ENDIF
                  EndIf

               IF !_lGerouOK
                  DisarmTransaction()
               ENDIF

         END Transaction

      ENDIF

      If ! _lAutomatico // Rotina rodada manualmente
         If Len(_aLog) > 0 .AND. !_lGerouOK
            _cProblema:="Ocorreram problemas na Geração de Pedidos de Pallet, para maiores detalhes veja a Coluna Movimentação."
            _cSolucao :="Para fechar a tela de Log clique no Botão FECHAR. Todas as Movimentações não poderam ser salvas."
            _bOK:={|| U_ITMSG(_cProblema,"Atenção!",_cSolucao,1) , .F. }

            _lRet:=U_ITListBox( 'Log de Geracao de Pedidos de Pallets (OM200FIM)' ,;
                               {" ",'Pedido Origem','Pedido Gerado','Movimentação','Cliente','Operacao','Armazem','Filial Carregamento','Filial Faturamento'} , _aLog , .T. , 4,,,;
                               { 10,             50,             50,           150,      150,        35,       35,                   60,                  60},, _bOK  , )
            Loop
         EndIf
      Else

         _aLogGerPal:=ACLONE(_aLog)//Variavel usada no M460MARK.PRW

         If Len(_aLog) > 0 .AND. !_lGerouOK
            lRetorno := .F.
            Exit//Loop
         EndIf
      EndIf

      IF !_lSoGeraPallet
            //Gravo celular do motorista
            DA4->(dbSetOrder(1))
            If DA4->(dbSeek(xFilial("DA4")+_cMotorDAK))
                DA4->(RecLock("DA4", .F.))
                DA4->DA4_DDD:=_cDDD
                DA4->DA4_TEL:=_cCEL
                DA4->(MsUnLock())
            EndIf
            //Gravo celular do motorista

            IF _cPreCarga = "1"
                _cObsCarga:=OBS_PRE_CARGA+ALLTRIM(_cObsCarga)
            ENDIF

            IF lEfetiva_Pre_Carga
                U_OM200FIM(lAcertaCarga)//Grava os dados e envia o e-mail
            ENDIF

      ENDIF

   ELSEIF lEfetiva_Pre_Carga//Limpa os campos PQ na tela de efetivar pré-carga tem o botão cancela e o usuario pode ter preecnhidos todas as variaveis

      //Limpa os campos
      _cTipo     := Space(1)
      _cAuto     := Space(LEN(ZZ2->ZZ2_AUTONO))
      _cCond     := Space(LEN(ZZ2->ZZ2_COND))
      _cObs	     := Space(LEN(ZZ2->ZZ2_OBS))
      _cObsCarga := ""// - Para variavel usada em GET MEMO nao precisa inicia com space()
      _nValor    := 0
      _nPedagio  := 0
      _cProtoc   := Space(LEN(ZZ2->ZZ2_PAMCAR))
      _nVlrPam   := 0
      _cREDP     := Space(LEN(DAK->DAK_I_REDP))
      _cRELO     := Space(LEN(DAK->DAK_I_RELO))
      _cOPER     := Space(LEN(DAK->DAK_I_OPER))
      _cOPLO     := Space(LEN(DAK->DAK_I_OPLO))
      _cPreCarga := "2-Não"//DAK->DAK_I_PREC

   ENDIF//lRetorno

   EXIT

 ENDDO

 dbSelectArea("TRBPED")
 dbClearFilter()
 dbGotop()

 If ! _lAutomatico // Rotina rodada manualmente
    If !lEfetiva_Pre_Carga
       oMark:oBrowse:Refresh()
    EndIf
 EndIf

 FwRestArea(_aArea)

Return lRetorno
/*
===============================================================================================================================
Programa----------: ValidaTela
Autor-------------: Tiago Correa
Data da Criacao---: 25/01/2009
Descrição---------: Funcao para validar Tela de Preenchimento do Frete na Montagem da Carga.
Parametros--------: _cTipo,_cAuto,_nValor,_cCond
Retorno-----------: .T. = Validacao OK permitindo o andamento da rotina
------------------: .F. = Validacao Negada nao permitindo o andamento da rotina
===============================================================================================================================
*/

Static Function ValidaTela( _cTipo , _cAuto , _nValor , _cCond , _cTpCarga , _cDDD , _cCEL )
 Local _lRet	 := .T.
 Local _cCamposOb:= ""
 Local _cQuery	 := ""
 Local _oAliasDA4:= GetNextAlias()
 Local _cCodForn := ""
 Local _cAliasAut:= GetNextAlias()
 Local oButton1  := NIL
 Local oButton2  := NIL
 Local oSay1	 := NIL
 Local oSay2	 := NIL
 Local oSay3	 := NIL
 Local _oDlgMsg	 := NIL
 /*
 //================================================================================
 //***********   TRATAMENTO DA OPERCAO TRIANGULAR  ********************************
 //================================================================================
 _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de operações da operação trigular
 _cOperRemessa:= RIGHT(_cOperTriangular,2)
 _cOperFat:= LEFT(_cOperTriangular,2)
 _aLog:={}
 _cPVFnaoLiberados:=""

 SC5->( DbSetOrder(1) )
 SC6->( DbSetOrder(1) )
 SC9->( DbSetOrder(1) )

 TRBPED->( dbGotop() )
 DO While TRBPED->( !EOF() )

 //  ************* POSICIONA NO PV DE REMESSA  ******************************
    If !SC5->( DbSeek( xFilial("SC5") + TRBPED->PED_PEDIDO ) )
        TRBPED->( DBSkip() )
        LOOP
    ENDIF

    IF SC5->C5_I_OPTRI = "R"

       _nRecPVRemessa:=SC5->(RECNO())
       M->C5_I_PVREM :=TRBPED->PED_PEDIDO
       M->C5_I_CLIEN :=SC5->C5_CLIENTE
       M->C5_I_LOJEN :=SC5->C5_LOJACLI

       //  ************* POSICIONA NO PV DE FATURAMENTO  ******************************
       IF SC5->(DBSEEK(xFilial()+SC5->C5_I_PVFAT))
          _nRecPVFat:=SC5->(RECNO())
       ELSE
          aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa não encontrado","",0,0} )//OK
          TRBPED->( DBSkip() )
          LOOP
       ENDIF
       IF !SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
          aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa não possui itens","",0,0} )//OK
          TRBPED->( DBSkip() )
          LOOP
       ENDIF
       //Valida dados da capa do PV de Faturamento
       IF SC5->C5_I_OPTRI <> "F"
          aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa não marcado com F = PV Faturamento","",0,0} )//OK
       ENDIF
       IF SC5->C5_I_OPER <> _cOperFat
          aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa não é Tipo de Operação: "+_cOperFat,"",0,0} )//OK
       ENDIF
       IF M->C5_I_PVREM <> SC5->C5_I_PVREM
          aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa vinculado com outro PV: "+SC5->C5_I_PVREM,"",0,0} )//OK
       ENDIF
       IF M->C5_I_CLIEN <> SC5->C5_I_CLIEN
          aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa com outro Cliente de Remessa: "+SC5->C5_I_CLIEN,"",0,0} )//OK
       ENDIF
       IF M->C5_I_LOJEN <> SC5->C5_I_LOJEN
          aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa com outra Loja de Cliente de Remessa: "+SC5->C5_I_LOJEN,"",0,0} )//OK
       ENDIF

       _aItensPVAlt:={}
       DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
          AADD(_aItensPVAlt,{ SC6->C6_ITEM,.F.,SC6->C6_PRODUTO,SC6->C6_QTDVEN,SC6->C6_PRCVEN })
          SC6->( DBSkip() )
       ENDDO

        //  ************* POSICIONA NO PV DE REMESSA  ******************************
       SC5->(DBGOTO(_nRecPVRemessa))

       //Valida dados dos itens do PV de Faturamento x Remessa
       SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
       DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM

          IF (nPos:=ASCAN(_aItensPVAlt,{|I| I[1]==SC6->C6_ITEM} )) = 0
              aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_I_PVFAT+" inidcado no PV de Remessa não possui o item: "+SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_QTDVEN,SC6->C6_PRCVEN} )//OK
              SC6->( DBSkip() )
              LOOP
          ENDIF
          _aItensPVAlt[nPos,2]:=.T.
          IF _aItensPVAlt[nPos,3] <> SC6->C6_PRODUTO .OR.;
             _aItensPVAlt[nPos,4] <> SC6->C6_QTDVEN  .OR.;
             _aItensPVAlt[nPos,5] <> SC6->C6_PRCVEN
             aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_I_PVFAT+" inidcado no PV de Remessa esta com algum dado diferente [Cod./Qtde/Preço] no item: "+SC6->C6_ITEM,_aItensPVAlt[nPos,3],_aItensPVAlt[nPos,4],_aItensPVAlt[nPos,5]} )//OK
          ENDIF

          SC6->( DBSkip() )
       ENDDO

       FOR I := 1 TO LEN(_aItensPVAlt)
           IF !_aItensPVAlt[I,2]
              aAdd( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_I_PVFAT+" inidcado no PV de Remessa tem a mais o item: "+_aItensPVAlt[I,1],_aItensPVAlt[I,3],_aItensPVAlt[I,4],_aItensPVAlt[I,5]} )//OK
           ENDIF
       NEXT

        //  ************* POSICIONA NO PV DE FATURAMENTO  ******************************
       SC5->(DBGOTO(_nRecPVFat))
       IF !SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
          IF LEN(_aLog) > 0//Se tiver algum erro acrescenta esse AVISO
             AADD( _aLog , {TRBPED->PED_PEDIDO,"PV de Faturamento: "+SC5->C5_NUM+" inidcado no PV de Remessa NAO LIBERADO","",0,0} )//OK
          ELSE
             _cPVFnaoLiberados+=ALLTRIM(SC5->C5_NUM)+", "//Somente AVISO
          ENDIF
       ENDIF

    ENDIF
    TRBPED->( DBSkip() )
 EndDo
 TRBPED->( dbGotop() )
 If LEN(_aLog) > 0
    U_ITListBox( 'Lista de problemas do Pedido de Remessa (OM200FIM)' ,;
                {'PV Remessa','Incompatibilidade encontradas',"Cod. Prod.","Qtde","Preco"} , _aLog , .F. , 1 ,"Lista de problemas do Pedido de Remessa X Pedido de Faturemento: ",,;
                 {40         ,300                            ,45          ,25    ,25})
    Return( .F. )
 ENDIF

 IF !EMPTY(_cPVFnaoLiberados)//Somente AVISO por enquanto
    _cPVFnaoLiberados:=LEFT(_cPVFnaoLiberados,LEN(_cPVFnaoLiberados)-2)
    U_ITMSG("PV(s) de Faturamento: "+_cPVFnaoLiberados+" não Liberado(s)",;
            "Atenção",'É Recomendado que libere esse(s) pedido(s)',3)
 ENDIF
 //================================================================================
 //***********   TRATAMENTO DA OPERCAO TRIANGULAR  ********************************
 //================================================================================
 */
 IF _cPreCarga = "1"//DAK->DAK_I_PREC
    RETURN .T.
 ENDIF

 IIF( Empty(_cTipo) , _cCamposOb +=  "Tipo de Frete " , NIL )

 //================================================================================
 //| Verifica se o usuario nao fornececeu um veiculo na montagem da carga, neste  |
 //| caso somente podera ser escolhido o tipo de Frete veiculo proprio            |
 //================================================================================
 If Empty(_cCaminDAK) .And. Upper(_cTipo) <> "IT-VEICULO PROPRIO"

     U_ITMSG('É necessário informar um veículo para a montagem da Carga atual.',;
             "Validação Veiculo",'Caso não seja fornecido um veículo deve ser utilizado o Tipo de Frete como sendo:IT-VEICULO PROPRIO'+SubStr(_cCodForn,1,1),1)

     Return( .F. )

 EndIf

 If Empty( _cTipo ) .Or. !Empty( _cCamposOb )


     U_ITMSG('Existe(m) campo(s) obrigatório(s) que não foi(ram) preenchido(s)!'	,;
             "Validação Campos",'Verifique o preenchimento do(s) campo(s): ' + SubStr( _cCamposOb , 1 , Len(_cCamposOb) - 1 ),1)


     Return( .F. )

 EndIf

 If UPPER(_cTipo) == "AUTONOMO"

     If Empty(_cAuto) .or. Empty(_nValor) .or. Empty(_cCond)

         _lRet := .F.

         U_ITMSG('Existe(m) campo(s) obrigatório(s) que não foi(ram) preenchido(s)!'	,;
             "Validação Campos",'Verifique o preenchimento do(s) campo(s): ' + ' VALOR DO FRETE, COD. AUTONOMO, COND. PAGAMENTO',1)


     EndIf

 ElseIf UPPER(_cTipo) == "PJ-TRANSPORTADORA"

    If Empty(_nValor)

        _lRet := .F.

        u_itmsg('Existe(m) campo(s) obrigatório(s) que não foi(ram) preenchido(s)!'	,;
            "Validação Campos",'Verifique o preenchimento do(s) campo(s): ' + ' VALOR DO FRETE' ,1)

    EndIf

 ElseIf UPPER(_cTipo) == "IT-VEICULO PROPRIO"

    If !Empty(_nValor)

        _lRet := .F.

        u_itmsg('Falha no preenchimento dos campos do formulário atual! '	,;
            "Validação Campos",'O campo Valor do Frete deve permanecer em branco quando o transporte for definido como Veículo Próprio.' ,1)


    EndIf

 Else

    _lRet := .F.

    u_itmsg('Existe(m) campo(s) obrigatório(s) que não foi(ram) preenchido(s)!'	,;
            "Validação Campos",'Verifique o preenchimento do(s) campo(s): ' + ' TIPO DO FRETE' ,1)


 EndIf

 //================================================================================
 //| Validacoes para constatar se o veiculo(Transportadora) informado condiz com  |
 //| o tipo informado na tela de Frete                                            |
 //================================================================================
 If _lRet .And. ( Upper(_cTipo) == "AUTONOMO" .Or. Upper(_cTipo) == "PJ-TRANSPORTADORA" )

    //================================================================================
    //| CASO NAO ENCONTRE CARGA PARA ESTORNAR, VERIFICAR SE É DE AUTONOMO            |
    //================================================================================
    _cQuery := " SELECT "
    _cQuery += " 	DA4_FORNEC , "
    _cQuery += "	DA4_LOJA "
    _cQuery += " FROM " + RetSqlName("DA4")
    _cQuery += " WHERE "
    _cQuery += " 		D_E_L_E_T_	= ' ' "
    _cQuery += " AND	DA4_COD		= '"+ _cMotorDAK +"' "

    If !Empty( xFilial("DA4") )
       _cQuery += " AND	DA4_FILIAL	= '"+ XFILIAL("DA4") +"' "
    EndIf

    MPSysOpenQuery( _cQuery , _oAliasDA4)

    _cCodForn := (_oAliasDA4)->DA4_FORNEC

    (_oAliasDA4)->(DBCloseArea())

     If SubStr(_cCodForn,1,1) == 'A' .And. Upper(_cTipo) <> "AUTONOMO"

        _lRet := .F.


        u_itmsg('Foi informado um Tipo de Frete diferente do Fornecedor associado ao veículo na montagem da carga!'	,;
                "Validação Campos",'O tipo de Fornecedor escolhido é: '+ SubStr(_cCodForn,1,1)+"-Autonomo, portanto o tipo do Frete deve ser Autonomo." ,1)



    ElseIf (SubStr(_cCodForn,1,1) == 'T' .Or. SubStr(_cCodForn,1,1) == 'G') .And. Upper(_cTipo) <> "PJ-TRANSPORTADORA"

        _lRet := .F.

        u_itmsg('Foi informado um Tipo de Frete diferente do Fornecedor associado ao veículo na montagem da carga!'	,;
                 "Validação Campos",'O tipo de Fornecedor escolhido é: '+ SubStr(_cCodForn,1,1)+", portanto o tipo do Frete deve ser PJ-Transportadora."  ,1)

    EndIf

 EndIf

 //================================================================================
 //| Verifica se o autonomo ligado ao motorista informado no veiculo é o mesmo que|
 //| foi informado no frete                                                       |
 //================================================================================
 If _lRet .And. !_lAutVeic .And. Upper(_cTipo) == "AUTONOMO"

    _cQuery := " SELECT"
    _cQuery += " 	SA2.A2_I_AUT , "
    _cQuery += " 	SRA.RA_NOMECMP "
    _cQuery += " FROM "+ RetSqlName("DA4") +" DA4 "
    _cQuery += " JOIN "+ RetSqlName("SA2") +" SA2 ON SA2.A2_COD = DA4.DA4_FORNEC AND SA2.A2_LOJA = DA4.DA4_LOJA "
    _cQuery += " JOIN "+ RetSqlName("SRA") +" SRA ON SRA.RA_MAT = SA2.A2_I_AUT "
    _cQuery += " WHERE "
    _cQuery += " 		DA4.D_E_L_E_T_	= ' ' "
    _cQuery += " AND	SA2.D_E_L_E_T_	= ' ' "
    _cQuery += " AND	SRA.D_E_L_E_T_	= ' ' "
    _cQuery += " AND	DA4.DA4_COD		= '"+ _cMotorDAK +"' "

    MPSysOpenQuery( _cQuery , _cAliasAut)

    (_cAliasAut)->( DBGotop() )

    If (_cAliasAut)->( !Eof() )

        If (_cAliasAut)->A2_I_AUT != _cAuto

            DEFINE MSDIALOG _oDlgMsg TITLE "ATENCAO" FROM 000, 000  TO 170, 500 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

                _oDlgMsg:LESCCLOSE := .F.

                @059,028 BUTTON oButton1	PROMPT "Sim" ACTION Eval({|| _lRet		:= .F. , _oDlgMsg:End() 				} )				   SIZE 037, 015 OF _oDlgMsg PIXEL
                @059,185 BUTTON oButton2	PROMPT "Nao" ACTION Eval({|| _lAutVeic	:= .T. , _lRet := .T. , _oDlgMsg:End()	} )	   	   SIZE 037, 015 OF _oDlgMsg PIXEL
                @015,012 SAY oSay1			PROMPT "O veículo associado na montagem da carga esta associado ao autônomo:"					   SIZE 229, 007 OF _oDlgMsg PIXEL COLORS 0, 16777215
                @027,012 SAY oSay2			PROMPT (_cAliasAut)->A2_I_AUT + '-' + SubStr(AllTrim((_cAliasAut)->RA_NOMECMP),1,25)			SIZE 229, 007 OF _oDlgMsg PIXEL COLORS 0, 16777215
                @040,012 SAY oSay3			PROMPT "que difere do informado para geração do RPA. Deseja modificar o autônomo informado?"	SIZE 229, 007 OF _oDlgMsg PIXEL COLORS 0, 16777215

            ACTIVATE MSDIALOG _oDlgMsg CENTERED

        EndIf

    EndIf

    (_cAliasAut)->( DBCloseArea() )

 EndIf

 //================================================================================
 //| Valida se o cadastro do fornecedor contem o autonomo indicado                |
 //================================================================================
 If Upper(_cTipo) == "AUTONOMO" .And. _lRet

    DBSelectArea("SA2")
    SA2->( DBOrderNickName("IT_AUTONOM") )
    If !( SA2->( DBSeek( xFilial("SA2") + _cAuto ) ) )

        DBSelectArea("SA2")
        SA2->( DBOrderNickName("IT_AUTAVUL") )
        If !( SA2->( DBSeek( xFilial("SA2") + _cAuto ) ) )

            _lRet := .F.

            u_itmsg('Foi encontrado um problema no cadastro do Fornecedor associado ao veículo na Carga!' + CHR(10) + CHR(13) + ;
            'O autônomo selecionado não está amarrado à um cadastro de Fornecedor válido!' 	,;
            "Validação Campos",'Verificar os dados e tentar novamente.' ,1)


        EndIf

    EndIf

 EndIf
 SA2->(DBSETORDER(1))

 If _lRet .And. (Empty(_cDDD) .Or. Empty(_cCEL))
    _lRet := .F.

    U_ITMSG('É obrigatório o preenchimento dos campos DDD e/ou Celular.',;
            "Validação Campos",'Favor preencher os campos corretamente e tente salvar novamente o registro!' ,1)
 EndIf

Return( _lRet )
/*
===============================================================================================================================
Programa----------: CalcFrete
Autor-------------: Tiago Correa
Data da Criacao---: 25/01/2009
Descrição---------: Funcao para realizar o Calculo Geral do Recibo de Autonomos e gravar nas tabelas os dados do cálculo
Parametros--------: lAcertaCarga As Logical
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CalcFrete(lAcertaCarga As Logical)
 Local _cTipoFret:= "" As Char
 Local nSeqInc   := SuperGetMV("MV_OMSENTR",.F.,5) As numeric
 Local nInc      := 0 As numeric
 Local _cFilSB1  := xFilial("SB1") As Char
 Local _nTotPeso := 0 As numeric
 Local _nTotValor:= 0 As numeric
 
 Private _cRecibo	   := ""
 Private _nVlrIrrfPag:= 0
 Private _nTeto      := 0
 Private _nbaseSest  := 0
 Private _nVlrSest   := 0
 Private _nbaseinss  := 0
 Private _nVlrInss   := 0
 Private _nVlrIrrf   := 0
 Private _x08_Lim3   := NIL
 Private _x08_Lim3P  := NIL
 Private _x09_rend1  := NIL
 Private _x09_rend2  := NIL
 Private _x09_rend3  := NIL
 Private _x09_rend4  := NIL
 Private _x09_rend5  := NIL
 Private _x09_aliq2  := NIL
 Private _x09_aliq3  := NIL
 Private _x09_aliq4  := NIL
 Private _x09_aliq5  := NIL
 Private _x09_parc2  := NIL
 Private _x09_parc3  := NIL
 Private _x09_parc4  := NIL
 Private _x09_parc5  := NIL
 Private _x09_deddep := NIL
 Private _x09_limdep := NIL
 Private _x09_retmin := NIL

 If Upper( AllTrim( _cTipo ) ) == "AUTONOMO" .AND. _cPreCarga # "1"

    //================================================================================
    //| Grava o cabecalho do recibo                                                  |
    //================================================================================
    _cRecibo := CRIAVAR("ZZ2_RECIBO")

    If ( __lSX8 )
        ConfirmSX8()
    EndIf

    DBSelectArea("ZZ2")
    ZZ2->( RecLock("ZZ2" , .T. ) )

    ZZ2->ZZ2_FILIAL  := xFILIAL("ZZ2")
    ZZ2->ZZ2_RECIBO  := _cRecibo
    ZZ2->ZZ2_CARGA   := cCarga
    ZZ2->ZZ2_AUTONO  := _cAuto
    ZZ2->ZZ2_COND    := _cCond
    ZZ2->ZZ2_TOTAL   := _nValor
    ZZ2->ZZ2_SEST    := _nVlrSest
    ZZ2->ZZ2_INSS    := _nVlrInss
    ZZ2->ZZ2_IRRF    := _nVlrIrrf
    ZZ2->ZZ2_DATA    := dDataBase
    ZZ2->ZZ2_TIPAUT  := "1"
    ZZ2->ZZ2_OBS     := ALLTRIM(_cObs)
    ZZ2->ZZ2_PAMCAR  := ALLTRIM(_cProtoc)
    ZZ2->ZZ2_PAMVLR  := _nVlrPam
    ZZ2->ZZ2_ORIGEM  := "1"
    ZZ2->ZZ2_VRPEDA  := _nPedagio

    ZZ2->( MsUnlock() )

 EndIf

 _nTotPeso :=0
 _nTotValor:=0
 _nFretOL2 :=0//variavel Statica
 SC5->( DBSetOrder(1) )
 SC6->( DBSetOrder(1) )

 _aCliente:={}//Para contar os pontos de atendimento
 DAI->( DBSetOrder(4) )//DAI_FILIAL+DAI_PEDIDO+DAI->DAI_COD+DAI_SEQCAR
 dbSelectArea("TRBPED")
 DbSetFilter({|| TRBPED->PED_GERA = "S" }, "TRBPED->PED_GERA = 'S'" )
 dbGotop()
 nSequencia:=0
 _cFilFatTrocaNF:=""
 Do While !TRBPED->(Eof())

   If DAI->( DBSeek( xFILIAL("DAI")  + TRBPED->PED_PEDIDO + DAK->DAK_COD + DAK->DAK_SEQCAR  ) ) .AND.;
      SC5->( DbSeek( DAI->DAI_FILIAL + TRBPED->PED_PEDIDO ) )

      _nPesoBrut:=0
      SC6->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
      DO While SC6->( !EOF() ) .AND. SC6->C6_FILIAL+SC6->C6_NUM == DAI->DAI_FILIAL+DAI->DAI_PEDIDO

         //==================================================================================
         // SEMPRE ACERTA O PESO BRUTO DE ACORDO COM O DO CADASTRO DO SB1 PQ ENTRE O PEDIDO E A CARGA PODE TER HAVIDO ALTERACAO
         //==================================================================================
         IF POSICIONE( "SB1" , 1 , _cFilSB1 + SC6->C6_PRODUTO , "B1_I_PCCX" )  > 0  .AND.  SC6->C6_I_PTBRU > 0 //EXCETO SE FOR PESO VARIADO
            _nPesoItem := SC6->C6_I_PTBRU
         Else
            _nPesoItem := SB1->B1_PESBRU * SC6->C6_QTDVEN //Peso do Item
            SC6->(RecLock("SC6",.F.))
            SC6->C6_I_PTBRU:=_nPesoItem 
            SC6->(MsUnlock())
         EndIf
         _nPesoBrut += _nPesoItem

         IF lAcertaCarga
            _nTotValor += SC6->C6_VALOR
         Endif
         SC6->( DBSkip() )
      ENDDO

      SC5->(RecLock("SC5",.F.))
      SC5->C5_I_PESBR:= _nPesoBrut
      SC5->C5_PBRUTO := _nPesoBrut
      SC5->(MsUnlock())


      IF EMPTY(_cFilFatTrocaNF) .AND. SC5->C5_I_TRCNF = 'S' .AND. !EMPTY(SC5->C5_I_FILFT) .AND. !EMPTY(SC5->C5_I_FLFNC) .AND.;
                                           SC5->C5_I_FILFT # SC5->C5_I_FLFNC .AND. EMPTY(SC5->C5_I_PDPR+SC5->C5_I_PDFT)//Pedidos de Troca Nota
         _cFilFatTrocaNF:= SC5->C5_I_FILFT
      ENDIF

      DAI->( RecLock( "DAI" , .F. ) )
      DAI->DAI_I_REDP:=IF(EMPTY(TRBPED->PED_I_REDP),"2",TRBPED->PED_I_REDP)
      DAI->DAI_I_OPER:=IF(EMPTY(TRBPED->PED_I_OPER),"2",TRBPED->PED_I_OPER)
      DAI->DAI_I_OPLO:=IF(EMPTY(TRBPED->PED_I_OPLO),"",TRBPED->PED_I_OPLO)
      DAI->DAI_I_LOPL:=IF(EMPTY(TRBPED->PED_I_LOPL),"",TRBPED->PED_I_LOPL)
      DAI->DAI_I_TRED:=IF(EMPTY(TRBPED->PED_I_TRED),"",TRBPED->PED_I_TRED)
      DAI->DAI_I_LTRE:=IF(EMPTY(TRBPED->PED_I_LTRE),"",TRBPED->PED_I_LTRE)
      DAI->DAI_I_TIPC:=TRBPED->PED_I_TIPC
      DAI->DAI_I_QTPA:=TRBPED->PED_I_QTPA
      IF DAI->(FIELDPOS("DAI_I_FROL")) > 0 .and. (DAI->DAI_I_OPER = "1" .Or.  DAI->DAI_I_REDP = "1")
         DAI->DAI_I_FROL:=TRBPED->PED_I_FROL
      ENDIF
      DAI->DAI_PESO  :=SC5->C5_I_PESBR//#Regrava por segurança
      _nTotPeso+=DAI->DAI_PESO
      IF EMPTY(DAI->DAI_DTCHEG)//Para os Pedidos de Pallets que vem com esse campos vazios
         DAI->DAI_DTCHEG := DATE()
         DAI->DAI_TMSERV := '0000:00'
         DAI->DAI_CHEGAD := '08:00'
         DAI->DAI_DTSAID := DATE()
         DAI->DAI_DATA   := DATE()
         DAI->DAI_HORA   := TIME()
      ENDIF
      DAI->( MsUnlock() )

      nSequencia+= nSeqInc//Reconta a sequencia para continuar na inclusao de pedidos de pallet abaixo

      _cChave  := DAI->( DAI_CLIENT + DAI_LOJA )
      IF DAI->DAI_I_OPER="1" .AND. !EMPTY(DAI->DAI_I_OPLO)
         _cChave  := DAI->DAI_I_OPLO+DAI->DAI_I_LOPL
      EndIF
      IF DAI->DAI_I_REDP="1" .AND. !EMPTY(DAI->DAI_I_TRED)
         _cChave  := DAI->DAI_I_TRED+DAI->DAI_I_LTRE
      EndIF
      IF !EMPTY(_cChave) .AND. aScan(_aCliente,_cChave) = 0
         AAdd(_aCliente,_cChave)//Acerta a contagem de ponto de entrega do padrao ABAIXO
      ENDIF
      IF DAI->(FIELDPOS("DAI_I_FROL")) > 0 .and. (DAI->DAI_I_OPER = "1" .Or.  DAI->DAI_I_REDP = "1")
         _nFretOL2 += DAI->DAI_I_FROL//Soma o frete do 2 Percurso para gravar no DAK_I_FROL
      EndIF

   ELSEIF TRBPED->(FIELDPOS("PED_RECDAI")) > 0 .AND. TRBPED->PED_RECDAI > 0 // SÓ EFETIVAÇÃO DA PRE-CARGA

      // Inserindo Pedido de Pallets criados na efetivação da pre-carga
      DAI->(DBGOTO(TRBPED->PED_RECDAI))

      For nInc := 1 To DAI->(FCount())
          M->&(DAI->(FieldName(nInc))) := DAI->(FieldGet(nInc))
      Next

      nSequencia    += nSeqInc
      M->DAI_PEDIDO := TRBPED->PED_PEDIDO
      M->DAI_CLIENT := TRBPED->PED_CODCLI
      M->DAI_LOJA   := TRBPED->PED_LOJA
      M->DAI_PESO   := TRBPED->PED_PESO
      M->DAI_I_REDP := TRBPED->PED_I_REDP
      M->DAI_I_OPER := TRBPED->PED_I_OPER
      M->DAI_I_OPLO := TRBPED->PED_I_OPLO
      M->DAI_I_LOPL := TRBPED->PED_I_LOPL
      M->DAI_I_TRED := TRBPED->PED_I_TRED
      M->DAI_I_LTRE := TRBPED->PED_I_LTRE
      M->DAI_I_TIPC := TRBPED->PED_I_TIPC
      M->DAI_I_QTPA := TRBPED->PED_I_QTPA
      M->DAI_DTCHEG := DATE()
      M->DAI_TMSERV := '0000:00'
      M->DAI_CHEGAD := '08:00'
      M->DAI_DTSAID := DATE()
      M->DAI_DATA   := DATE()
      M->DAI_HORA   := TIME()
      M->DAI_SEQUEN := StrZero(nSequencia,6)
      IF TRBPED->(FIELDPOS("PED_I_FROL")) > 0
         M->DAI_I_FROL := TRBPED->PED_I_FROL
      ENDIF

      DAI->(RECLOCK("DAI",.T.))
      AvReplace("M", "DAI")
      DAI->(MSUNLOCK())
   ENDIF

   TRBPED->(DBSKIP())
 ENDDO

 TRBPED->(DBGOTOP())
 SC5->( DbSeek( xFILIAL("SC5") + TRBPED->PED_PEDIDO ) )//PARA GRAVAR O CAMPO DAK->DAK_I_LEMB COM SC5->C5_I_LOCEM

 DAI->( DBSetOrder(1) )//DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
 dbSelectArea("TRBPED")
 dbClearFilter()
 dbGotop()


 //================================================================================
 //| Armazena o tipo da carga                                                     |
 //================================================================================
 DBSelectArea("DAK")
 DAK->( DBSetOrder(1) ) //DAK_FILIAL+DAK_COD+DAK_SEQCAR
 If DAK->( DBSeek( xFILIAL("DAK") + cCarga ) )

    Do Case
        Case Upper(ALLTRIM(_cTipo)) == "PJ-TRANSPORTADORA" .OR. _cPreCarga = "1"//Forcei 2 na pre-carga por causa das mensagem no estorno da carga do ZZ2 (OS200ES2.PRW)
            _cTipoFret:= "2"
        Case Upper( ALLTRIM(_cTipo) ) == "AUTONOMO"
            _cTipoFret := "1"
        OtherWise
            _cTipoFret:= "3"
    EndCase

    DAK->( RecLock( "DAK" , .F. ) )
    DAK->DAK_I_TPFR := _cTipoFret
    DAK->DAK_I_REDP := _cREDP
    DAK->DAK_I_RELO := _cRELO
    DAK->DAK_I_OPER := _cOPER
    DAK->DAK_I_OPLO := _cOPLO
    DAK->DAK_I_OBS  := ALLTRIM(_cObsCarga)
    DAK->DAK_I_VRPE := _nPedagio
    IF DAK->(FIELDPOS("DAK_I_FROL")) > 0
       DAK->DAK_I_FROL := _nFretOL2
    Endif
    DAK->DAK_I_LEMB := SC5->C5_I_LOCEM // Local de Embarque
    IF LEN(_aCliente) > 0
       DAK->DAK_PTOENT:=LEN(_aCliente)//Acerta a contagem de ponto de entrega do padrao
    ENDIF
    DAK->DAK_I_PREC := _cPreCarga
    DAK->DAK_MOTORI := _cMotorDAK
    DAK->DAK_CAMINH := _cCaminDAK
    DAK->DAK_PESO   := _nTotPeso //Sempre acerta pq   - #Regrava por segurança
    IF lAcertaCarga
      DAK->DAK_VALOR := _nTotValor
    ENDIF
    IF DAK->(FIELDPOS( "DAK_I_TRNF" )) > 0
       IF !EMPTY(_cFilFatTrocaNF)
          DAK->DAK_I_TRNF:= "C"            //Preencher o campo com C (Tem troca nota e é filial de carregamento)
          DAK->DAK_I_FITN:= _cFilFatTrocaNF//Filial de faturamento do troca nota (C5_I_FILFT Filial para onde os pedidos de faturamento foram transferidos)
       ELSE
          DAK->DAK_I_TRNF:= "N"         //Preencher o campo com N
       ENDIF
       DAK->DAK_I_INCC:= "N"            //Preencher com N
       DAK->DAK_I_INCF:= "N"            //Preencher com N
    ENDIF

    DAK->( MsUnlock() )

 EndIf

 If  (_cPreCarga # "1" .AND. (UPPER( ALLTRIM(_cTipo) ) == "AUTONOMO" .OR. UPPER( ALLTRIM(_cTipo) ) == "PJ-TRANSPORTADORA") .And. _nValor > 0) ;
     .Or. _nPedagio > 0

     GravaFrete( _nValor , cCarga , _nPedagio  )

 EndIf

 // Limpa os campos para proxima carga
 _cTipo	 := Space(1)
 _cAuto	 := Space(LEN(ZZ2->ZZ2_AUTONO))
 _cCond	 := Space(LEN(ZZ2->ZZ2_COND))
 _cObs	 := Space(LEN(ZZ2->ZZ2_OBS))
 _cObsCarga:= ""//Para variavel usada em GET MEMO nao precisa inicia com space()
 _nValor	 := 0
 _nPedagio:= 0
 _cProtoc := Space(LEN(ZZ2->ZZ2_PAMCAR))
 _nVlrPam := 0
 _cREDP   := Space(LEN(DAK->DAK_I_REDP))
 _cRELO   := Space(LEN(DAK->DAK_I_RELO))
 _cOPER   := Space(LEN(DAK->DAK_I_OPER))
 _cOPLO   := Space(LEN(DAK->DAK_I_OPLO))
 _cPreCarga:= "2-Não"

Return .t.

/*
===============================================================================================================================
Programa----------: CargaRatVlrs
Autor-------------: Alex Wallauer
Data da Criacao---: 14/03/20225
Descrição---------: Refaz o Rateio do valor do PEDAGIO E FRETE 1o PERCURSO / Chamada do programa MOMS010.PRW
Parametros--------: _cCarga As Char
Retorno-----------: GravaFrete ( 0 , _cCarga , 0  )
===============================================================================================================================
*/
User Function CargaRatVlrs(_cCarga As Char)
Return GravaFrete( 0 , _cCarga , 0 )

/*
===============================================================================================================================
Programa----------: GravaFrete
Autor-------------: Tiago Correa
Data da Criacao---: 08/02/2009
Descrição---------: Funcao para gravação do rateiuo do Frete e do Pedagio por item da Carga
Parametros--------: _nDA_I_FRET , _cCarga , _nPedagio
Retorno-----------: .T. ou .F. / Se achou ou não o DAK
===============================================================================================================================
*/
Static Function GravaFrete( _nDA_I_FRET As Numeric , _cCarga as char , _nPedagio As Numeric ) As Logical
 Local _nPesoTot     := 0 AS Numeric
 Local _nPesoSoPallet:= 0 AS Numeric
 Local lAChouDAK     := .F. AS Logical
 Local nMaiorVlr     :=0 AS Numeric
 Local nMaiorRec     :=0 AS Numeric
 Local nVlrSomaPedag :=0 AS Numeric
 Local nVlrSomaFrete :=0 AS Numeric

 //================================================================================
 //| Gravacao dao Valor total da Carga                                            |
 //================================================================================
 DBSelectArea("DAK")
 DAK->( DBSetOrder(1) ) //DAK_FILIAL+DAK_COD+DAK_SEQCAR
 If (lAChouDAK:=DAK->( DBSeek( xFilial("DAK") + _cCarga ) )) .AND. _nDA_I_FRET > 0

    DAK->( RecLock( "DAK" , .F. ) )
    DAK->DAK_I_FRET := _nDA_I_FRET
    DAK->( MsUnlock() )

    //================================================================================
    //Recupera o peso total da carga sem considerar Produtos Unitizadores do PALLET
    //================================================================================
    _nPesoTot := U_CalPesCarg( _cCarga , 1 )

    //================================================================================
    //| Tratativa se somente foram encontrados produtos PALLET na montagem de carga  |
    //================================================================================
    If _nPesoTot == 0
        _nPesoSoPallet := DAK->DAK_PESO
    EndIf

 ElseIf lAChouDAK .AND. (_nDA_I_FRET = 0  .OR. _nPedagio = 0)//Para quando CHAMA do programa MOMS010.PRW

    _nDA_I_FRET := DAK->DAK_I_FRET
    _nPedagio   := DAK->DAK_I_VRPE

    IF (_nPesoTot := U_CalPesCarg( _cCarga , 1 )) = 0
        _nPesoSoPallet:= DAK->DAK_PESO
    EndIf

 EndIf

 IF !lAChouDAK
    Return .F.
 EndIf

 //================================================================================
 // Grava Valor Rateado por item da Carga desconsiderando Produtos Unitizadores
 //================================================================================
 DBSelectArea("DAI")
 DAI->( DBSetOrder(1) ) //DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
 If DAI->( DBSeek( xFILIAL("DAI") + _cCarga ) ) .AND. (_nDA_I_FRET > 0 .Or. _nPedagio > 0)

    DO While DAI->(!Eof()) .And. DAI->DAI_COD == _cCarga .And. DAI->DAI_FILIAL == xFILIAL("DAI")

        DAI->( RecLock( "DAI" , .F. ) )

        //================================================================================
        //| Caso a carga possua Produtos acabados mais pedidos de PALLET sera rateado o  |
        //| frete somente por Pedidos que nao sejam de PALLET                            |
        //================================================================================
        If _nPesoTot > 0

            If U_CalPesCarg(DAI->DAI_PEDIDO,2) > 0

                DAI->DAI_I_FRET:=	((_nDA_I_FRET  / _nPesoTot)	*	DAI->DAI_PESO)
                IF DAI->(FIELDPOS("DAI_I_VRPE")) > 0
                   DAI->DAI_I_VRPE:=	((_nPedagio / _nPesoTot)	*	DAI->DAI_PESO)
                Endif

            EndIf

        //================================================================================
        //| Caso a montagem de carga somene possua pedidos de PALLET                     |
        //================================================================================
        Else

            DAI->DAI_I_FRET:=	( ( _nDA_I_FRET / _nPesoSoPallet ) * DAI->DAI_PESO )
            IF DAI->(FIELDPOS("DAI_I_VRPE")) > 0
               DAI->DAI_I_VRPE:=	( ( _nPedagio   / _nPesoSoPallet ) * DAI->DAI_PESO )
            Endif

        EndIf

        IF DAI->DAI_PESO > nMaiorVlr
           nMaiorVlr:=DAI->DAI_PESO
           nMaiorRec:=DAI->(RecNo())
        ENDIF
        nVlrSomaFrete+=DAI->DAI_I_FRET
        IF DAI->(FIELDPOS("DAI_I_VRPE")) > 0
           nVlrSomaPedag+=DAI->DAI_I_VRPE
        ENDIF

        DAI->( MsUnlock() )

        DAI->( DBSkip() )

    EndDo

 EndIf

 //================================================================================
 // Acertos de diferenças de frete e pedagio
 //================================================================================
 If nMaiorRec > 0  .And. (nVlrSomaFrete <> _nDA_I_FRET .Or. nVlrSomaPedag <> _nPedagio)
    DAI->( Dbgoto(nMaiorRec))
    DAI->( RecLock( "DAI" , .F. ) )
    If nVlrSomaFrete <> _nDA_I_FRET
       DAI->DAI_I_FRET:= DAI->DAI_I_FRET + (_nDA_I_FRET - nVlrSomaFrete )
    EndIf
    IF DAI->(FIELDPOS("DAI_I_VRPE")) > 0 .AND. nVlrSomaPedag <> _nPedagio
       DAI->DAI_I_VRPE:= DAI->DAI_I_VRPE + (_nPedagio - nVlrSomaPedag )
    EndIf
    DAI->( MsUnlock() )
 EndIf

Return .T.
/*
===============================================================================================================================
Programa----------: CalPesCarg
Autor-------------: Fabiano Dias
Data da Criacao---: 20/05/2010
Descrição---------: Funcao que soma o peso total da carga desconsiderando Produtos Unitizadores do Pallet
Parametros--------: _cCodigo	- Código da Carga/Pedido
------------------: _nTipo		- 1 = Peso Total da Carga / 2 = Peso Total do Pedido  / 3 = Peso Total do Pedido sem filtro
Retorno-----------: _nPesoTot	- Peso total calculado
===============================================================================================================================
*/
User Function CalPesCarg( _cCodigo As Char  , _nTipo As Numeric ) As Numeric

 Local _oAliasPes:= GetNextAlias()
 Local _cQuery	 := ""
 Local _cGrpUnit := GetMV( "IT_GRPUNIT" ,, "0813" )
 Local _nPesoTot := 0
 Local _aArea	 := FwGetArea()

 _cQuery += " SELECT SUM(PESOTOTAL) PESTOTAL FROM ( SELECT "
 _cQuery += " CASE WHEN  SC6.C6_I_PTBRU > 0  "
 _cQuery += "      THEN  SC6.C6_I_PTBRU "
 _cQuery += "      ELSE  COALESCE( ( SB1.B1_PESBRU * SC6.C6_QTDVEN ) , 0 )  END PESOTOTAL  "
 _cQuery += " FROM " + RetSqlName("DAI") + " DAI "
 _cQuery += " JOIN " + RetSqlName("SC6") + " SC6 ON DAI.DAI_PEDIDO = SC6.C6_NUM AND DAI.DAI_FILIAL = SC6.C6_FILIAL "
 _cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
 _cQuery += " WHERE "
 _cQuery += " 		DAI.D_E_L_E_T_	= ' ' "
 _cQuery += " AND	SC6.D_E_L_E_T_	= ' ' "
 _cQuery += " AND	SB1.D_E_L_E_T_	= ' ' "
 If _nTipo <> 3
    _cQuery += " AND	SB1.B1_GRUPO	NOT IN "+ FormatIn( _cGrpUnit , ";" )  //EXCLUI GRUPOS UNITIZADORES
 Endif

 If !Empty( xFilial("DAI") )
    _cQuery += " AND	DAI.DAI_FILIAL	= '" + XFILIAL("DAI") + "' "
 EndIf

 If !Empty(xFilial("SC6"))
    _cQuery += " AND	SC6.C6_FILIAL	= '" + XFILIAL("SC6") + "' "
 EndIf

 If !Empty(xFilial("SB1"))
    _cQuery += " AND	SB1.B1_FILIAL	= '" + XFILIAL("SB1") + "' "
 EndIf

 If _nTipo = 1//Efetua o somatorio do peso total da Carga
    _cQuery += " AND	DAI.DAI_COD = '"+ _cCodigo +"' "
 ElseIf _nTipo = 2  .OR. _nTipo = 3//Efetua o somatorio do Peso do Pedido
    _cQuery += " AND	SC6.C6_NUM  = '" + _cCodigo + "'"
 EndIf

 _cQuery += " ) "//Fechamento DA SUB-QUERY

 MPSysOpenQuery( _cQuery , _oAliasPes)

 DBSelectArea(_oAliasPes)

 If (_oAliasPes)->(!Eof())
     _nPesoTot := (_oAliasPes)->PESTOTAL
 EndIf

 (_oAliasPes)->( DBCloseArea() )

 FwRestArea( _aArea )

Return( _nPesoTot )
/*
===============================================================================================================================
Programa----------: VALIDAUT
Autor-------------: Guilherme Diogo
Data da Criacao---: 30/10/2012
Descrição---------: Funcao para validar codigo do autonomo informado
Parametros--------: _cAuto	- Código do Autônomo
Retorno-----------: _lRet	- Verdadeiro se o autônomo for encontrado / Falso se não existir no cadastro de Fornecedores
===============================================================================================================================
*/
Static Function VALIDAUT(_cAuto)
 Local _cQrySA2	:= ""
 Local _cAliasSA2:= GetNextAlias()
 Local _lRet		:= .T.

 //================================================================================
 //| Query que verifica se codigo do autonomo informado existe na SA2             |
 //================================================================================
 _cQrySA2 := " SELECT SA2.A2_COD FROM "+ RetSqlName("SA2") +" SA2 "
 _cQrySA2 += " WHERE "
 _cQrySA2 += " 		D_E_L_E_T_		= ' ' "
 _cQrySA2 += " AND	(	A2_I_AUT	= '"+ALLTRIM(_cAuto)+"' "
 _cQrySA2 += " 		OR	A2_I_AUTAV	= '"+ALLTRIM(_cAuto)+"' ) "

 MPSysOpenQuery( _cQrySA2 , _cAliasSA2)

 If (_cAliasSA2)->( Eof() )
     u_itmsg('Código de Autônomo informado é inválido!'  ,;
             "Validação Campos",'Verificar o código informado!'	 ,1)
     _lRet := .F.
 EndIf

 (_cAliasSA2)->( DBCloseArea() )

Return(_lRet)

/*
===============================================================================================================================
Programa----------: VLDVLPAM
Autor-------------: Alexandre Villar
Data da Criacao---: 18/08/2014
Descrição---------: Funcao pra validar o valor Pamcary com relação ao valor do Frete
Parametros--------: Valores do Frete e Pamcary
Retorno-----------: _lRet - Verdadeiro se os valores informados estiverem consistentes
===============================================================================================================================
*/
Static Function VLDVLPAM( _nOpc , _nValor , _nVlrPam , _nPedagio )
 Local _lRet	:= .T.

 If ( _nOpc == 1 .And. _nVlrPam > 0 ) .Or. _nOpc == 2
     If _nValor > 0 .Or. _nVlrPam > 0
         _lRet := _nValor > _nVlrPam
         If !_lRet
             u_itmsg('Valor do Pamcary invalido'  ,;
             "Validação Pamcary","O valor do Frete deve ser maior que o valor Pamcary!"	 ,1)
         EndIf
     EndIf
 EndIf

 If (_nOpc == 1 .OR. _nOpc == 3) .And. _nPedagio > 0
     If _nValor < _nPedagio
         u_itmsg('Valor do Pedágio invalido'  ,;
             "Validação Frete","O valor do Frete deve ser maior/igual que o valor de Pedágio!"	 ,1)
        _lRet:=.F.
     EndIf
 EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: VLDVeiculo()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/12/2016
Descrição---------: Funcao pra validar o Veiculo
Parametros--------: lOK: logico ,cCpo: origem
Retorno-----------: _lRet - Verdadeiro se os valores informados estiverem consistentes
===============================================================================================================================
*/
Static Function VLDVeiculo(lOK,cCpo)
 IF cCpo == "VEI" .OR. lOK

    DA3->(DBSETORDER(1))
    IF EMPTY(_cCaminDAK)

        IF _cPreCarga # "1"
              u_itmsg('Código invalido'  ,"Validação Veiculo","Codigo do Veiculo não preenchido"	 ,1)
            RETURN .F.
        ENDIF

    ELSEIf !DA3->(DBSEEK(xFilial()+_cCaminDAK))

        u_itmsg('Código invalido'  ,"Validação Veiculo","Codigo: "+_cCaminDAK+" do Veiculo nao cadastrado"	 ,1)
        RETURN .F.

    ELSEIF !lOK

        _cMotorDAK:=DA3->DA3_MOTORI
        DA4->(dbSetOrder(1))
        DA4->(dbSeek(xFilial("DA4")+_cMotorDAK))
        _cDDD := DA4->DA4_DDD
        _cCEL := DA4->DA4_TEL

    ENDIF

 ENDIF

 IF cCpo == "MOTO" .OR. lOK

    DA4->(DBSETORDER(1))
    IF EMPTY(_cMotorDAK)

        IF _cPreCarga # "1"
           u_itmsg('Código invalido'  ,"Validação Motorista","Codigo do Motorista não preenchido"	 ,1)
           RETURN .F.
        ENDIF

    ELSEIf !DA4->(DBSEEK(xFilial()+_cMotorDAK))

        u_itmsg('Código invalido'  ,"Validação motorista","Codigo: "+_cMotorDAK+" do motorista nao cadastrado"	 ,1)
        RETURN .F.

    ELSE

      IF Upper(_cTipo) = "PJ-TRANSPORTADORA"
        IF !EMPTY(DA4->DA4_FORNEC)
             SA1->(DBSETORDER(3))
           IF SA2->( DBSeek( xFilial("SA2") + DA4->DA4_FORNEC+DA4->DA4_LOJA ) ) .AND. SA1->( DBSeek( xFilial("SA1") + SA2->A2_CGC ) )
              IF SA1->A1_MSBLQL == "1"

                 u_itmsg("Cliente / CNPJ: "+SA1->A1_COD+" / "+SA1->A1_LOJA+" / "+SA2->A2_CGC+" esta Bloqueado no cadastro de Clientes."  ,;
                 "Validação Cliente",;
                 "Selecione um motorista com um Fornecedor / Cliente válido, caso precise gerar pedidos de Pallet de Retorno"	 ,1)

                 RETURN (!_lTemPalletRetorno)
              ENDIF
           ELSE

               u_itmsg("Cliente / CNPJ: "+SA1->A1_COD+" / "+SA1->A1_LOJA+" / "+SA2->A2_CGC+" não encontrados no cadastro de Clientes."  ,;
                 "Validação Cliente",;
                 "Selecione um motorista com um Fornecedor / Cliente válido, caso precise gerar pedidos de Pallet de Retorno"	 ,1)

                RETURN (!_lTemPalletRetorno)
           ENDIF
        ELSE
           u_itmsg( "Fornecedor não preencchido no cadastro do motorista.","Validação Cliente",;
                                              "Selecione um motorista com um Fornecedor válido, caso precise gerar pedidos de Pallet de Retorno",1)
           RETURN (!_lTemPalletRetorno)
        ENDIF
      ENDIF

        IF !lOK
           _cDDD := DA4->DA4_DDD
           _cCEL := DA4->DA4_TEL
        ENDIF

    ENDIF

 ENDIF

RETURN .T.
/*
===============================================================================================================================
Programa----------: VLDSA2
Autor-------------: Alex Wallauer
Data da Criacao---: 14/06/2016
Descrição---------: Funcao pra validar o Transportadora de redespacho e Operador Logistico
Parametros--------: _cCodSA2: chave ,cChamada: origem
Retorno-----------: _lRet - Verdadeiro se os valores informados estiverem consistentes
===============================================================================================================================
*/
Static Function VLDSA2(_cCodSA2,cChamada)
 LOCAL lTemTRSim:=.F.
 LOCAL lTemOLSim:=.F.
 LOCAL lTemPal_0:=.F.,P,G
 LOCAL aPVsCarga:={}
 LOCAL aP2Vinculados:={}
 LOCAL aPVdeGrupos  :={}

 SA2->(DBSETORDER(1))

 IF cChamada # "OKTELA"

    IF cChamada == "COLTR" .OR. cChamada == "COLOP"//ARRUMO A VARIAVEIS DA TELA PQ O F3 devolve codigo+loja na _cOpPed
       IF LEN(ALLTRIM(_cOpPed)) > LEN(DAK->DAK_I_OPER)
          _cOpLja:=ALLTRIM(SUBSTR(_cOpPed, LEN(DAK->DAK_I_OPER)+1, 4 ))
       ENDIF
       _cOpPed:=LEFT(_cOpPed,LEN(DAK->DAK_I_OPER))
    ENDIF
    IF cChamada == "TR" //ARRUMO A VARIAVEIS DA TELA PQ O F3 devolve codigo+loja na _cF3REDP
       IF LEN(ALLTRIM(_cF3REDP)) > LEN(DAK->DAK_I_OPER)
          _cRELO:=ALLTRIM(SUBSTR(_cF3REDP, LEN(DAK->DAK_I_OPER)+1, 4 ))
       ENDIF
       _cF3REDP:=LEFT(_cF3REDP,LEN(DAK->DAK_I_OPER))
       _cREDP  :=_cF3REDP//Atualiza pq usa em outros lugares
    ENDIF
    IF cChamada == "OL"//ARRUMO A VARIAVEIS DA TELA PQ O F3 devolve codigo+loja na _cF3OPER
       IF LEN(ALLTRIM(_cF3OPER)) > LEN(DAK->DAK_I_OPER)
          _cOPLO:=ALLTRIM(SUBSTR(_cF3OPER, LEN(DAK->DAK_I_OPER)+1, 4 ))
       ENDIF
       _cF3OPER:=LEFT(_cF3OPER,LEN(DAK->DAK_I_OPER))
       _cOPER  :=_cF3OPER//Atualiza pq usa em outros lugares
    ENDIF

     IF EMPTY(_cCodSA2)

         IF cChamada == "TR"
             _cRELO := Space(LEN(DAK->DAK_I_RELO))
         ELSEIF cChamada == "OL"
             _cOPLO := Space(LEN(DAK->DAK_I_OPLO))
         ELSEIF cChamada == "COLTR" .OR. cChamada == "COLOL"
             u_itmsg( "Código não preenchido","Atenção", "Para limpar código clique na coluna para mudar para 'Não'",1)
             RETURN .F.
         ENDIF

     ELSEIf SA2->(DBSEEK(xFilial()+(_cCodSA2)))

         Z31->(DbSetOrder(1))
         If SA2->A2_I_CLASS # "T"  .OR. SA2->A2_MSBLQL # "2"

             u_itmsg( "Código invalido","Validação Transportador",'Código: '+_cCodSA2+' não é do tipo Transportador ('+SA2->A2_I_CLASSL+') ou esta bloqueado ('+SA2->A2_MSBLQL+")",1)
             RETURN .F.

         //ELSEIf !Z31->(Dbseek(xFilial()+ALLTRIM(_cCodSA2))) //Chamado 43489. desativado por enqunto

         //	u_itmsg("Operador: "+_cCodSA2+" não tem Transit Time cadastrado (Z31).","ALERTA: Transit Time de Operadores Logisticos.",;
         //	        "Pode gravar a carga, mas na geração da nota não vai conseguir calcular o Transit Time do Operador.",2)

         EndIf

     ELSE
         u_itmsg( "Código invalido","Validação Transportador", "Codigo: "+_cCodSA2+" do Transportador nao cadastrado",1)

         RETURN .F.

     EndIf

     IF cChamada == "COLTR" .OR. cChamada == "COLOP"
        RETURN .T.
     ENDIF

 EndIf

 dbSelectArea("TRBPED")
 dbGotop()

 lTemduplo := .F.
 _cPedssemTT:=""
 _cOLssemTT:=""

 Do While !TRBPED->(Eof())

    IF cChamada = "OKTR" .or. cChamada = "OKTD"
       IF TRBPED->PED_I_REDP = "1"
          lTemTRSim:=.T.
       ENDIF

       IF TRBPED->PED_I_REDP = "1" .and. TRBPED->PED_I_OPER  = "1"
          lTemduplo:=.T.
       ENDIF

    ELSEIF cChamada = "OKOL"
       IF TRBPED->PED_I_OPER  = "1"
          lTemOLSim:=.T.
       ENDIF

       IF TRBPED->PED_I_REDP = "1" .and. TRBPED->PED_I_OPER  = "1"
          lTemduplo:=.T.
       ENDIF

    ELSEIF cChamada = "OKTELA"

       IF TRBPED->PED_I_TIPC $ TP_GERA_PALET .AND. EMPTY(TRBPED->PED_I_QTPA)
          lTemPal_0:=.T.
          EXIT
       ENDIF

       If SC5->( DbSeek( xFilial("SC5") + TRBPED->PED_PEDIDO ) )
          AADD(aPVsCarga,SC5->C5_NUM)
          IF !EMPTY(SC5->C5_I_PEVIN)
             AADD(aP2Vinculados,{SC5->C5_NUM,SC5->C5_I_PEVIN})
          ENDIF
          IF SC5->(FIELDPOS("C5_I_AGRUP")) > 0  .AND. !EMPTY(SC5->C5_I_AGRUP) .AND. ASCAN(aPVdeGrupos,SC5->C5_I_AGRUP) = 0
             AADD(aPVdeGrupos,SC5->C5_I_AGRUP)
          ENDIF
       ENDIF

 //	  cCodCli := SC5->C5_CLIENTE
 //    cLojaCli:= SC5->C5_LOJACLI
 //	  IF !EMPTY(TRBPED->PED_I_OPLO)
 //	     cCodOL :=TRBPED->PED_I_OPLO
 //	     cLojaOP:=TRBPED->PED_I_LOPL
 //	  ELSE
 //	     cCodOL :=TRBPED->PED_I_TRED
 //	     cLojaOP:=TRBPED->PED_I_LTRE
 //	  ENDIF

 //	  If !EMPTY(cCodOL) .AND. !U_BuscaZ31(cCodOL,cLojaOP,cCodCli,cLojaCli) // Chamado 43489. desativado por enqunto
 //	     _cPedssemTT+="[ "+TRBPED->PED_PEDIDO+" ] "
 //		 IF !cCodOL+"-"+cLojaOP $ _cOLssemTT
 //		    _cOLssemTT +="[ "+cCodOL+"-"+cLojaOP+" ] "
 //		 ENDIF
 //	  EndIf

    ELSEIF cChamada = "TR"

       IF TRBPED->PED_I_REDP = "1" .and. TRBPED->PED_I_OPER  = "1"
          lTemduplo:=.T.
          EXIT
       ENDIF


    ELSEIF cChamada = "OL"

       IF TRBPED->PED_I_REDP = "1" .and. TRBPED->PED_I_OPER  = "1"
          lTemduplo:=.T.
          EXIT
       ENDIF

    ENDIF

    TRBPED->(DBSKIP())
 ENDDO

 TRBPED->(dbGotop())
 oMarkFim:oBrowse:Refresh()

 IF cChamada = "OKTR"
    IF !lTemTRSim .AND. !EMPTY(_cCodSA2)
           u_itmsg( "Nenhum Pedido com Redespacho","Atenção","Deve haver pelo menos 1 pedido marcado como SIM na coluna Redespacho",1)
          RETURN .F.
    ENDIF
 ENDIF

 IF cChamada = "OKOL"
    IF !lTemOLSim .AND. !EMPTY(_cCodSA2)
       u_itmsg( "Nenhum Pedido com Oper. Logistico","Atenção","Deve haver pelo menos 1 pedido marcado como SIM na coluna Oper. Logistico",1)
       RETURN .F.
    ENDIF
 ENDIF

 If cChamada == "OKTD"
    IF lTemduplo
       u_itmsg( "Pedido com Oper. Logistico e com Redespacho","Atenção","Não marcar um pedido como Redespacho e Operador logistico ao mesmo tempo",1)
         RETURN .F.
    Endif
 Endif

 IF cChamada = "OKTELA"
    IF lTemPal_0
       u_itmsg( "Pedido: "+TRBPED->PED_PEDIDO+" paletizado com quantidade zerada","Atenção","Preencha a quantidade do Pallet do Pedido",1)
       RETURN .F.
    ENDIF

    cFaltaPVinculado:=""
    cPVinculados:=""
    FOR P := 1 TO LEN(aP2Vinculados)
        IF ASCAN(aPVsCarga, aP2Vinculados[P,2]) = 0
           cFaltaPVinculado+=" PV "+aP2Vinculados[P,1]+" na carga sem o PV Vinculado "+aP2Vinculados[P,2]+CRLF
           cPVinculados+=aP2Vinculados[P,2]+", "
        ENDIF
    NEXT

    IF !EMPTY(cFaltaPVinculado)
       cPVinculados:=LEFT(cPVinculados,LEN(cPVinculados)-2)
       U_ITMSG(cFaltaPVinculado,"Atenção","Retire o vinculo em alteração de Pedido ou adicione os PV vinculados faltantes na Carga: "+cPVinculados,1)
       RETURN .F.
    ENDIF

    FOR P := 1 TO LEN(aPVdeGrupos)

       _cQuery:=" SELECT C5_NUM FROM "+ RETSQLNAME("SC5") + " WHERE C5_FILIAL = '"+ xFilial('SC5')+"' AND D_E_L_E_T_ = ' ' "
       _cQuery+=" AND C5_I_AGRUP = '"+aPVdeGrupos[P]+"' "

       _cAliasGru:= GetNextAlias()
       MPSysOpenQuery( _cQuery , _cAliasGru)
       aPedidosGru:={}
       DO WHILE (_cAliasGru)->(!EOF())
          AADD(aPedidosGru,(_cAliasGru)->C5_NUM)
          (_cAliasGru)->(DBSKIP())
       ENDDO
       (_cAliasGru)->(DBCLOSEAREA())

       cFaltadoGrupo:=""
       cPVdoGrupo   :=""

       FOR G := 1 TO LEN(aPedidosGru)
           IF ASCAN(aPVsCarga, aPedidosGru[G] ) = 0
              cFaltadoGrupo:=" Grupo "+aPVdeGrupos[P]+" de PVs na carga sem o(s) PV(s) do grupo: "
              cPVdoGrupo+=aPedidosGru[G]+", "
           ENDIF
       NEXT

       IF LEN(cFaltadoGrupo) > 0
          cPVdoGrupo:=LEFT(cPVdoGrupo,LEN(cPVdoGrupo)-2)
          U_ITMSG(cFaltadoGrupo+cPVdoGrupo,"Atenção","Adicione o(s) outro(s) pedido(s) do grupo: "+cPVdoGrupo,1)
            RETURN .F.
       ENDIF

    NEXT

  // If !EMPTY(_cPedssemTT)//Chamado 43489. desativado por enqunto
  // 	  U_ITMSG("Esses Pedidos : "+_cPedssemTTLO+" possuem Operador Logistico sem transit time cadastrado.","ALERTA: Transit Time de Operadores Logisticos.",;
  //            "Pode gravar a carga, mas na geração da nota não vai conseguir calcular o Transit Time do(s) Operadore(s): "+_cOLssemTT,3)
  // EndIf

 ENDIF

 TRBPED->(dbGotop())
 oMarkFim:oBrowse:Refresh()

Return .T.

/*
===============================================================================================================================
Programa----------: OM200Marca
Autor-------------: Alex Wallauer
Data da Criacao---: 15/06/2016
Descrição---------: Funcao para troca sim e na dos campos de Transportadora de redespacho e Operador Logistico
Parametros--------: objBrowse: objeto ,lEfetiva_Pre_Carga: lógico
Retorno-----------: Verdadeiro
===============================================================================================================================
*/
Static Function OM200Marca(objBrowse,lEfetiva_Pre_Carga,aCpoBrw)
 LOCAL _lOK    := .F.,_oDlg
 LOCAL _nQtdeP := 0
 LOCAL _bValid,_bValid2
 //LOCAL _nCol1  :=7
 //LOCAL _nCol2  :=9
 LOCAL _nColA  :=7
 LOCAL _nColB  :=_nColA+50
 LOCAL _nTam   :=40
 PRIVATE _cOpPed := SPACE(LEN(TRBPED->PED_I_TRED))//VariveL private para o F3 customizado funcionar.
 PRIVATE _cOpLja := SPACE(LEN(TRBPED->PED_I_LTRE))//VariveL private para o F3 customizado funcionar.

 SC5->( DbSeek( xFilial("SC5") + TRBPED->PED_PEDIDO ) )//Posiciona por causa do F3 usa o estado do Pedido, NÃO RETIRE.

 //COLUNA DO FRETE 2o PERCURSO
 IF _nColOLFOL > 0 .AND. objBrowse:COLPOS = _nColOLFOL .AND. (TRBPED->PED_I_OPER = "1" .Or.  TRBPED->PED_I_REDP = "1")
    _nGetValor:=TRBPED->PED_I_FROL
    IF U_IT_EditCell(@_nGetValor,objBrowse,"@E 99,999.99",_nColOLFOL,"",.F.,{|| Positivo() },/*aComboBox*/)
       _nFretOL2-=TRBPED->PED_I_FROL
       IF _nFretOL2 < 0
          _nFretOL2:=0
       EndIf
       TRBPED->PED_I_FROL:=_nGetValor
       _nFretOL2+=TRBPED->PED_I_FROL
       _oFret2:Refresh()
    EndIf
 Endif

 //Coluna de sim/nao para redespacho
 IF objBrowse:COLPOS = nColTR//2
    IF TRBPED->PED_I_REDP # "1" .AND. TRBPED->PED_I_OPER  # "1" .AND. !EMPTY(_cREDP)//Só mexe na coluna se tiver o codigo preenchido e OL com não
       TRBPED->PED_I_REDP :=  "1"
       TRBPED->PED_I_TRED := _cREDP
       TRBPED->PED_I_LTRE := _cRELO
    ELSE
       TRBPED->PED_I_REDP := "2"
       TRBPED->PED_I_TRED := ""
       TRBPED->PED_I_LTRE := ""
       IF TRBPED->PED_I_OPER  # "1" .AND. TRBPED->(FIELDPOS("PED_I_FROL")) > 0
          _nFretOL2-=TRBPED->PED_I_FROL
          TRBPED->PED_I_FROL := 0
          IF _nFretOL2 < 0
             _nFretOL2:=0
          EndIf
          _oFret2:Refresh()
       Endif
    ENDIF
 ENDIF

 //Coluna de codigo de redespacho
 IF objBrowse:COLPOS = _nColTRGet .AND. TRBPED->PED_I_OPER  # "1" //Só mexe na coluna se tiver o OL com não //3

    _bValid := {|| VLDSA2(_cOpPed,"COLTR") }
    _bValid2:= {|| VLDSA2(_cOpPed+_cOpLja,"COLTR") }

    IF !EMPTY(TRBPED->PED_I_TRED)

          _cOpPed :=	TRBPED->PED_I_TRED
          _cOpLja :=	TRBPED->PED_I_LTRE

    ELSEIF !EMPTY(_cREDP) //Se transportador redespacho padrao estiver preenchido já preenche consulta

          _cOpPed :=	_cREDP
          _cOpLja :=	_cRELO

    Endif

    DEFINE MSDIALOG _oDlg TITLE "Transp Redespacho para o pedido " + TRBPED->PED_PEDIDO FROM 000,000 TO 150,300 PIXEL

    @ 005, 007 SAY "Transp Redespacho:" PIXEL
    @ 017, 009 MSGET _cOpPed SIZE 40,11 OF _oDlg F3 "F3ITLC" VALID ( EVAL(_bValid) ) PIXEL
    @ 017, 060 MSGET _cOpLja SIZE 30,11 OF _oDlg PIXEL

    @ 050,020	BMPBUTTON TYPE 01 ACTION Eval({|| IF(EVAL(_bValid2),(_lok:=.T.,_oDlg:End()),)})
    @ 050,060	BMPBUTTON TYPE 02 ACTION Eval({|| _lok := .F. , _oDlg:End()} )

    Activate MSDialog _oDlg Centered

    If _lok

          TRBPED->PED_I_REDP  :=  "1"
          TRBPED->PED_I_TRED :=  _cOpPed
          TRBPED->PED_I_LTRE :=  _cOpLja

          IF EMPTY(_cREDP) //Se transportador redespacho padrao estiver vazio já preenche

             _cREDP := _cOpPed
             _cRELO := _cOpLja
             _ocredp:Refresh()
             _ocrelo:Refresh()

          Endif

    Endif

 Endif

 //Coluna de sim/nao para operador logistico
 IF objBrowse:COLPOS = nColOL//5

       IF TRBPED->PED_I_OPER  # "1" .AND. TRBPED->PED_I_REDP # "1" .AND. !EMPTY(_cOPER) //Só mexe na coluna se tiver o RD com não

          TRBPED->PED_I_OPER   :=  "1"
          TRBPED->PED_I_OPLO :=  _cOPER
          TRBPED->PED_I_LOPL :=  _cOPLO

       ELSE

          TRBPED->PED_I_OPER   :=  "2"
          TRBPED->PED_I_OPLO :=  ""
          TRBPED->PED_I_LOPL :=  ""
          IF TRBPED->PED_I_REDP  # "1" .AND. TRBPED->(FIELDPOS("PED_I_FROL")) > 0
             _nFretOL2-=TRBPED->PED_I_FROL
             TRBPED->PED_I_FROL := 0
             IF _nFretOL2 < 0
                _nFretOL2:=0
             EndIf
             _oFret2:Refresh()
          Endif

       ENDIF

 ENDIF

 //Coluna de codigo de operador logistico
 IF objBrowse:COLPOS = _nColOLGet .AND. TRBPED->PED_I_REDP # "1"//6

    _bValid := {|| VLDSA2(_cOpPed,"COLOP") }
    _bValid2:= {|| VLDSA2(_cOpPed+_cOpLja,"COLOP") }

    IF !EMPTY(TRBPED->PED_I_OPLO) //Se transportador redespacho padrao estiver preenchido já preenche consulta

          _cOpPed :=	TRBPED->PED_I_OPLO
          _cOpLja :=	TRBPED->PED_I_LOPL

     ELSEIF !EMPTY(_cOPER) //Se transportador redespacho padrao estiver preenchido já preenche consulta

          _cOpPed :=	_cOPER
          _cOpLja :=	_cOPLO

       Endif

    DEFINE MSDIALOG _oDlg TITLE "Operador Logistico para o pedido " + TRBPED->PED_PEDIDO FROM 000,000 TO 150,300 PIXEL

    @ 005, 007 SAY "Operador Logistico:" PIXEL
    @ 017, 009 MSGET _cOpPed SIZE 40,11 OF _oDlg F3 "F3ITLC" VALID ( EVAL(_bValid) ) PIXEL
    @ 017, 060 MSGET _cOpLja SIZE 30,11 OF _oDlg PIXEL

    @ 050,020  BMPBUTTON TYPE 01 ACTION Eval({|| IF(EVAL(_bValid2),(_lok:=.T.,_oDlg:End()),) } )
    @ 050,060  BMPBUTTON TYPE 02 ACTION Eval({|| _lok := .F. , _oDlg:End()				} )

    Activate MSDialog _oDlg Centered

    If _lok

          TRBPED->PED_I_OPER   :=  "1"
          TRBPED->PED_I_OPLO :=  _cOpPed
          TRBPED->PED_I_LOPL :=  _cOpLja

          IF EMPTY(_cOPER) //Se transportador redespacho padrao estiver vazio já preenche

             _cOPER := _cOpPed
             _cOPLO := _cOpLja
             _ooper:Refresh()
             _ooplo:Refresh()

          Endif

    Endif

 Endif

 IF lEfetiva_Pre_Carga// Só as colunas acimas podem ser alteradas
    RETURN .F.
 ENDIF

 IF objBrowse:COLPOS = nColTP//8
    _nQtdeP:= TRBPED->PED_I_QTPA
    _aTipoP:= { "1-Pallet Chep        ",;
                "2-Estivada           ",;
                "3-Pallet PBR         ",;
                "4-Pallet Descartavel ",;
                "5-Pallet Chep Retorno",;
                "6-Pallet PBR Retorno "}
    _cTipoP:= _aTipoP[VAL(TRBPED->PED_I_TIPC)]
    _lOK   := .F.

    _bValid:= {|| IF(!LEFT(_cTipoP,1) $ TP_GERA_PALET .OR. Positivo(_nQtdeP),_lOK:=.T.,.F.) }
    _nLinP := 05
    nAltura:=200

    DEFINE MSDIALOG _oDlg TITLE "Dados do Pallet" FROM 000,000 TO nAltura,260 PIXEL

    @ _nLinP+10, _nColA SAY "Tipo de Carga?" PIXEL
    @ _nLinP, _nColB MSCOMBOBOX	_cTipoP	SIZE 070,045 ITEMS _aTipoP OF _oDlg PIXEL
      _nLinP+=25
    @ _nLinP+10, _nColA SAY "Quantidade Pallet?" PIXEL
    @ _nLinP, _nColB MSGET _nQtdeP Picture "@E 999,999" SIZE _nTam,11 OF _oDlg VALID ( EVAL(_bValid) ) PIXEL WHEN IF(LEFT(_cTipoP,1) $ TP_GERA_PALET,.T.,(_nQtdeP:=0,.F.))
      _nLinP+=25
    @ _nLinP,020 BMPBUTTON TYPE 01 ACTION IF(EVAL(_bValid),(_lOK:=.T.,_oDlg:End()),)
    @ _nLinP,060 BMPBUTTON TYPE 02 ACTION Eval({|| _lOK := .F.       ,_oDlg:End()} )

    Activate MSDialog _oDlg Centered

    IF _lOK
       TRBPED->PED_I_TIPC := _cTipoP
       TRBPED->PED_I_QTPA := _nQtdeP
    ENDIF

 ENDIF

 IF objBrowse:COLPOS = nColQT .AND. TRBPED->PED_I_TIPC $ TP_GERA_PALET//9

    _nQtdeP:= TRBPED->PED_I_QTPA
    IF U_IT_EditCell(@_nQtdeP,objBrowse,X3Picture("DAI_I_QTPA"),nColQT,"",.F.,{|| Positivo() },/*aComboBox*/)
       TRBPED->PED_I_QTPA := _nQtdeP
    EndIf
    
    // Mantive caso os usarios queiram voltar a usar o dialogo de paletizacao
    //_lOK   := .F.
    //_bValid:= {|| IF(Positivo(_nQtdeP),(_lOK:=.T.,_oDlg:End()),.F.) }
    //DEFINE MSDIALOG _oDlg TITLE "Pallets" FROM 000,000 TO 080,120 PIXEL
    //@ 005, _nCol1 SAY "Quantidade Pallet:" PIXEL
    //@ 014, _nCol2 MSGET _nQtdeP Picture "@E 999,999" SIZE _nTam,11 OF _oDlg VALID ( EVAL(_bValid) ) PIXEL
    //@ 100,0110	BMPBUTTON TYPE 01 ACTION EVAL(_bValid)
    //Activate MSDialog _oDlg Centered
    //IF _lOK
    //   TRBPED->PED_I_QTPA := _nQtdeP
    //ENDIF

 ENDIF

RETURN .T.
/*
===============================================================================================================================
Programa--------: U_OM200Email
Autor-----------: Alex Walallauer
Data da Criacao-: 22/06/2065
Descrição-------: Monta e dispara o WF de comunicação da Montagem de Carga
Parametros------: _lEstorno.....: Se .T. foi chamdo do estorno
                  _aCarga.......: Lista de Pedidos da Carga
                  _cObsEmail....: Observacao no Corpo do Email
                  _lEnviaDireto.: Envia o e-mail direto sem perguntar
                  _lScheduller..: Sem tela
                  _lMarcaEnvio..: Marca o envio para o RDC
Retorno---------: .t.
===============================================================================================================================*/
//***************************************************************************// CUIDADO TESTAR A CHAMADA DE TODOS OS LUGARES
USER Function OM200Email(_lEstorno,_aCargas,_lEnviaDireto,_lScheduller,_lMarcaEnvio)
                                                          //1-Chamada das Acoes Relacionadas Reenvio WF da montagem da carga,
                                                          //2-No Estorno da Carga
                                                          //3-Na funcao MT103FIM()
 //***************************************************************************//
 Local _cEmail	 := ""
 Local _cObsEmail := ""// Para variavel usada em GET MEMO nao precisa inicia com space()
 Local oproc

 Private _lAutomatico

 DEFAULT _lEstorno:= .F.
 DEFAULT _lEnviaDireto:=.T.
 DEFAULT _lMarcaEnvio:=.T.

 If Empty(_lScheduller)
    _lAutomatico := .F.
 Else
    _lAutomatico := _lScheduller
 EndIf

 _cEmail:=BuscaEmail(_lAutomatico,"")//Só para verificar se tem algum emal para enviar

 If Empty( _cEmail )
    IF !_lEstorno .AND. LEN(_aLog) = 0
       If ! _lAutomatico
          u_itmsg( "Sem e-mail cadastrado!","Atenção",'Verifique o parametro "IT_WFCARGA" com a área de TI / ERP.',1)
       EndIf
    ENDIF
    RETURN .F.
 ENDIF

 If ! _lAutomatico
    IF _lEnviaDireto .AND. !OM200PegaObs(@_cObsEmail)
       RETURN .F.
    ENDIF

    FwMsgRun( ,{|oproc| OM200Email(_lEstorno,_aCargas,_cObsEmail,_lEnviaDireto,_lMarcaEnvio,oproc) } ,'Aguarde!' ,'Enviando WF ...'    )
 Else
    OM200Email(_lEstorno,_aCargas,_cObsEmail,_lEnviaDireto,_lMarcaEnvio)
 EndIf

RETURN .T.
/*
===============================================================================================================================
Programa--------: OM200Email
Autor-----------: Alex Walallauer
Data da Criacao-: 22/06/2065
Descrição-------: Monta e dispara o WF de comunicação da Montagem de Carga
Parametros------: _lEstorno.....: Se .T. foi chamdo do estorno
                  _aCarga.......: Lista de Pedidos da Carga
                  _cObsEmail....: Observacao no Corpo do Email
                  _lEnviaDireto.: Envia o e-mail direto sem perguntar
                  _lMarcaEnvio..: Marca o envio para o RDC
                  _oproc........: objeto da barra de processamento
Retorno---------:.t.
===============================================================================================================================*/
//***************************************************************************// CUIDADO TESTAR A CHAMADA DE TODOS OS LUGARES
STATIC Function OM200Email(_lEstorno,_aCargas,_cObsEmail,_lEnviaDireto,_lMarcaEnvio, oproc)//1-Chamada da funcao acima e
                                                                       //2-Na gravacao da Carga acima
 //***************************************************************************//
 Local _aConfig	  := U_ITCFGEML('')
 Local _cEmail	  := ""
 Local _cMsgEml	  := ''
 Local _cAssunto   := ''
 Local _cData      := DtoC( DATE() )
 Local _cNomeFilial:= ""
 Local _lGerouPDF  := .T.//Inicia com .T. pq o Estorno enviar e-mail sem Anexo
 Local _cTextoObs  := "",_nI
 Local _cMailUser  := ""
 Local _ntot := 0
 Local _npos := 1
 Local _cEnvPor, _cCodEnvPor, _cEmailEnvPor

 DEFAULT _lEnviaDireto:=.F.
 DEFAULT _lMarcaEnvio :=.T.//Essa funcao Static OM200Email() tb é chamada direto desse ponto de entrada
 Default oproc := nil

 If _lAutomatico .AND. _lMarcaEnvio .AND. ZFU->(FIELDPOS("ZFU_ENMAIL")) # 0
    //U_ITCONOUT("Marcou envio do E-MAIL da Carga: "+DAK->DAK_COD) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
    _lEnviaEmail := .T.
    RETURN .T.
 ENDIF

 _cEmail:=BuscaEmail(_lAutomatico,@_cMailUser)//Aqui busca mesmo todos os emails

 _cEnvPor := UsrFullName(__cUserID)

 If Empty( _cEmail )
   If ! _lAutomatico
      IF !_lEstorno
         u_itmsg("Sem e-mail cadastrado","Atenção",UPPER('Dados gravado com sucesso.'), 1 )
      ENDIF
   //ELSE
      //U_ITCONOUT("Sem e-mail cadastrado para filial: "+XFILIAL("ZP1")+" - IT_WFCARGA") // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
   EndIf
 Else
   If ! _lAutomatico
      ProcRegua(0)
   Else
      _lEnviaDireto := .T.
   EndIf

    If !_lEstorno .AND. (_cObsEmail = NIL .OR. EMPTY(_cObsEmail))
       _cTextoObs := AllTrim(DAK->DAK_I_OBS) + " " + AllTrim(DAK->DAK_I_OBS2)
       _cTextoObs := Upper(_cTextoObs)
       _cObsEmail := ALLTRIM(StrTran(_cTextoObs,Char(13)+Char(10)," "))
    ELSE
       _cObsEmail:=ALLTRIM(StrTran(_cObsEmail,Char(13)+Char(10)," "))
    ENDIF

    If _aCargas = NIL .OR. EMPTY(_aCargas)
       _aCargas:=U_OM200_Carrega()
    ENDIF

    IF _lEstorno
       _cCarga  := _cCargas//Vairavel PRIVATE do rdmake OM200MNU.PRW
       _cNomeFilial:= xFilial("DAK")+" - "+AllTrim( Posicione('SM0',1,cEmpAnt+xFilial("DAK"),'M0_FILIAL') )
       _cAssunto   := "ESTORNO de Carga: "+_cCarga+" / Filial: "+ _cNomeFilial +' - Notificação ['+ DtoC( Date() ) +']'
    ELSE
       _cCarga  := DAK->DAK_COD
       _cData   := DtoC( DAK->DAK_DATA)
       _cNomeFilial:= DAK->DAK_FILIAL+" - "+AllTrim( Posicione('SM0',1,cEmpAnt+DAK->DAK_FILIAL,'M0_FILIAL') )
       IF DAK->DAK_I_PREC = "1"
          _cAssunto   :="MONTAGEM de PRE-Carga: "+_cCarga+" / Filial: "+ _cNomeFilial +' - Notificação ['+ DtoC( Date() ) +']'
       ELSE
          _cAssunto   :="MONTAGEM de Carga: "+_cCarga+" / Filial: "+ _cNomeFilial +' - Notificação ['+ DtoC( Date() ) +']'
       ENDIF
    ENDIF

    If _lAutomatico
       If Empty(_cEnvPor)
          //=====================================================================================
          // Pega nome do usuÃ¡rio
          //=====================================================================================
          _cCodEnvPor := SubStr(Embaralha(DAK->DAK_USERGI,1),3,6) //Embaralha(DAK->DAK_USERGA, 1)
          //_cCodEnvPor := SubStr(_cCodEnvPor,7,6)
          _cEnvPor := UsrFullName(_cCodEnvPor)

          //=====================================================================================
          // Pega e-mail do usuÃ¡rio
          //=====================================================================================
          //PswOrder(1)
          //PswSeek(_cCodEnvPor,.T.)
          //_aUsuario  := PswRet()
          _cEmailEnvPor :=U_UCFG001(3,_cCodEnvPor) //Alltrim(_aUsuario[1,14])

          If !Empty(_cEmailEnvPor)
             _cEmail := AllTrim(_cEmail) + "; "+_cEmailEnvPor
          EndIf

       EndIf
    EndIf

    _cMsgEml := '<html>'
    _cMsgEml += '<head><title>Montagem de Carga</title></head>'
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
    _cMsgEml += '	     <td class="titulos"><center>'+_cAssunto+'</center></td>'
    _cMsgEml += '	 </tr>'
    _cMsgEml += '</table>'
    _cMsgEml += '<br>'
    _cMsgEml += '<table class="bordasimples" width="600">'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td align="center" colspan="2" class="grupos">Carga: <b>'+ _cCarga +'</b></td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Enviado por: </b></td>'
    _cMsgEml += '      <td class="itens" >'+ _cEnvPor +'</td>' // UsrFullName(__cUserID)
    _cMsgEml += '    </tr>'

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ _cNomeFilial +'</td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data Carga:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ _cData +'</td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Observações:</b></td>'
    _cMsgEml += '      <td class="itens" >#OBS#</td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '	<tr>'
    _cMsgEml += '		<td class="grupos" align="center" colspan="2"><b>Para maiores informações acesse o arquivo anexo.</b></td>'
    _cMsgEml += '	</tr>'
    _cMsgEml += '	<tr>'
    _cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta é uma mensagem automática. Por favor não a responda!</u></font></td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '</table>'

    If !Empty(_aCargas)
       If ! _lAutomatico
          _ntot := Len(_aCargas)+2
       EndIf

        _cMsgEml += '<br>'
        _cMsgEml += '<table class="bordasimples" width="800">'
        _cMsgEml += '    <tr>'
        _cMsgEml += '      <td align="center" colspan="4" class="grupos">Pedidos da Carga</b></td>'
        _cMsgEml += '    </tr>'
        _cMsgEml += '    <tr>'
        _cMsgEml += '      <td class="itens" align="center" width="12%"><b>Pedido</b></td>'
        _cMsgEml += '      <td class="itens" align="center" width="54%"><b>Local de Entrega</b></td>'
        _cMsgEml += '      <td class="itens" align="center" width="19%"><b>Peso</b></td>'
        _cMsgEml += '      <td class="itens" align="center" width="15%"><b>Tipo Carga</b></td>'
        _cMsgEml += '    </tr>'


        SC5->( DBSetOrder(1) )
        SA3->(dbSetOrder(1))

        For _nI := 1 To Len( _aCargas )
            If ! _lAutomatico

              IF valtype(oproc) = "O"

                      oproc:cCaption := ("Lendo Pedido: "+_aCargas[_nI][01] + " - " + strzero(_npos,6) + " de " + strzero(_ntot,6))
                      _npos++
                      ProcessMessages()

              ENDIF

            EndIf

            _cMsgEml += '    <tr>'
            _cMsgEml += '      <td class="itens" align="center" width="12%">'+ _aCargas[_nI][01] 	+'</td>'
            _cMsgEml += '      <td class="itens" align="left"   width="54%">'+ _aCargas[_nI][05] +'</td>'
            _cMsgEml += '      <td class="itens" align="right"  width="19%">'+ Transform( _aCargas[_nI][02] , "@E 9,999,999,999."+Replicate("9",TamSx3("DAK_PESO")[2]) )+' KG </td>'
            _cMsgEml += '      <td class="itens" align="center" width="15%">'+ _aCargas[_nI][06]+'</td>'
            _cMsgEml += '    </tr>'

        Next

        _cMsgEml += '</table>'

    EndIf

    _cMsgEml += '</center>'
    _cMsgEml += '<br>'
    _cMsgEml += '<br>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
    _cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [OM200FIM]</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '</body>'
    _cMsgEml += '</html>'
    _cEmlLog := ''

    // ENVIO DO EMAIL COM ANEXO Ex.: \SPOOL\Roms004_20160714_085326.pdf
    If ! _lAutomatico

       IF valtype(oproc) = "O"

            oproc:cCaption := ("WF para: "+_cEmail)
               ProcessMessages()

       ENDIF

    EndIf

    //Variaveis private usadas na funcao: ROMS004  \/\/\/\/\/
    MV_PAR01:=DAK->DAK_COD
    MV_PAR02:=DAK->DAK_COD
    MV_PAR03:= 3
    _cFileName:=""//O nome é preenchido na funcao ROMS004(.T.) - Ex.: %TEMP%\CARGA_MV_PAR01_20160714_085326.pdf
    //Variaveis private usadas na funcao: ROMS004 /\/\/\/\/\

    If !_lAutomatico .AND. !_lEstorno

        _lGerouPDF := U_ROMS004(.T., .T.) //Roda automático e mostra o relatório
        IF !_lGerouPDF
           _lEnvioOK:=.F.//USADO NO PROGRAMA AOMS101.PRW
        ENDIF

    ElseIF !_lEstorno

         //U_ITCONOUT("Tentando Gerar PDF para enviar por e-mail") // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
        _lGerouPDF := U_ROMS004(.T., .F.) //Roda automatico sem mostrar o relatório
        _ntamanho := 0
        _adatfile := {}
        _ni := 0

        //Verifica se gerou pdf com tamanho maior que zero, em caso de erro repete o relatório até três vezes
        Do while _ni <= 3 .and. _ntamanho = 0

             _ntamanho := 0
             _adatfile := {}
             If file(_cfilename)
                  _adatfile := directory(_cfilename)
                  _ntamanho := _adatfile[1][2]
             Endif
             If _ntamanho = 0
                U_MostraCalls()
                //U_ITCONOUT("Tentariva "+cvaltochar(_ni)+" Anexo: " + alltrim(_cfileName) + " de tamanho: " + ALLTRIM(transform(_ntamanho,"@E 9,999,999"))) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
                 ferase(_cfilename)
                 _lGerouPDF := U_ROMS004(.T., .F.) //Roda automatico sem mostrar o relatório
             Endif
             _ni++

        Enddo
        IF !_lGerouPDF
           _lEnvioOK:=.F.//USADO NO PROGRAMA AOMS101.PRW
        ENDIF

    Endif

    IF _lEnviaDireto .OR. OM200PegaObs(@_cObsEmail)

       If ! _lAutomatico
          IF VALTYPE(oproc) = "O"
             oproc:cCaption := ("Enviado para: "+_cEmail)
             ProcessMessages()
          ENDIF
       EndIf

       _cMsgEml:=STRTRAN(_cMsgEml,"#OBS#",_cObsEmail)
       IF _lGerouPDF    //Quando é estorno envia o e-mail sem anexo mesmo
        //U_ITENVMAIL(cFrom         ,cEmailTo ,cEmailCo  ,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
          U_ITENVMAIL( _aConfig[01] , _cEmail ,_cMailUser,         ,_cAssunto, _cMsgEml,_cFileName,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
          IF !"SUCESSO" $ UPPER(_cEmlLog)// SE NÃO ENVIO O EMAIL NÃO MARCA NO
             _lEnvioOK:=.F.//USADO NO PROGRAMA AOMS101.PRW
          ENDIF
       ENDIF

       IF !_lEstorno
          _ntamanho := 0
          _adatfile := {}

          If file(_cfilename)
             _adatfile := DIRECTORY(_cfilename)
             _ntamanho := _adatfile[1][2]
          Else
             _cfilename:= "Arquivo ("+_cfilename+") nao localizado no envio do email"
             _ntamanho := 0
          Endif
          //U_ITCONOUT("Anexo: " + alltrim(_cfileName) + " de tamanho: " + ALLTRIM(transform(_ntamanho,"@E 9,999,999"))) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
          IF _ntamanho <= 0
              U_MostraCalls()
          ENDIF

          If !_lGerouPDF
             _cEmlLog+=" (NÃO ENVIO O E-mail para: "+_cEmail+") (Com Copia: "+_cMailUser+") - Com anexo " + alltrim(_cfileName) + " de tamanho " + transform(_ntamanho,"@E 9,999,999")
          ELSEIf _lAutomatico
             _cEmlLog+=" (E-mail para: "+_cEmail+") (Com Copia: "+_cMailUser+") - Com anexo " + alltrim(_cfileName) + " de tamanho " + transform(_ntamanho,"@E 9,999,999")
          EndIf
       ENDIF

       IF !Empty( _cEmlLog ) //.AND. !_lEstorno
          If !_lAutomatico
             IF !_lEstorno
                   Aviso(UPPER('Dados gravado com sucesso. (OM200FIM)'),UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
                   CHR(13)+CHR(10)+" E-mail para: "+_cEmail +" - Com anexo " + alltrim(_cfileName) + " de tamanho " + transform(_ntamanho,"@E 9,999,999") +CHR(13)+CHR(10)+;
                   CHR(13)+CHR(10)+" Com Copia: "+_cMailUser+CHR(13)+CHR(10)+;
                   IF(_cFileName # nil,CHR(13)+CHR(10)+" Anexo: "+_cFileName,""),{"OK"} , 3 )
             ELSE
                   Aviso(UPPER('Dados gravado com sucesso. (OM200FIM)'),UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
                     CHR(13)+CHR(10)+" E-mail para: "+_cEmail +CHR(13)+CHR(10)+;
                     CHR(13)+CHR(10)+" Com Copia: "+_cMailUser+CHR(13)+CHR(10),{"OK"} , 3 )
             ENDIF
          //ELSE
             //U_ITCONOUT("_cEmlLog: "+_cEmlLog) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
             //U_ITCONOUT("E-mail para: " + _cEmail +" Com Copia: "+_cMailUser) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
             //U_ITCONOUT("Fim do envio do E-MAIL: "+_cAssunto) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
          EndIf
       EndIF

    ENDIF

    IF _cFileName # nil .AND. !EMPTY(_cFileName) .AND. FILE(_cFileName)
       IF FErase(_cFileName) = 0
          //U_ITCONOUT("Arquivo "+_cFileName+" apagado com sucesso") // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
       ENDIF
    ENDIF

    IF _cFileName # nil .AND. !EMPTY(_cFileName)
       _cFileRelName:=STRTRAN( UPPER(_cFileName), ".PDF", ".REL")
       IF FILE(_cFileRelName)
          IF FErase(_cFileRelName) = 0
             //U_ITCONOUT("Arquivo "+_cFileRelName+" apagado com sucesso") // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
          ENDIF
       ENDIF
    ENDIF

 EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: U_OM200_Carrega()
Autor-------------: Alex Wallauer
Data da Criacao---: 26/07/2016
Descrição---------: Leitura dos dados da Carga
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: _aCargas: array de pedidos
===============================================================================================================================*/
User Function OM200_Carrega(oproc)
 Local _aCargas:={}
 Local _cNomCli:=''
 Default oproc := nil

 SC5->( DbSetOrder(1) )
 DAI->( DBSetOrder(1) )

 If DAI->( DBSeek( xFilial("DAI") + DAK->DAK_COD ) )


    DO While DAI->( !EOF() ) .And. DAI->( DAI_FILIAL + DAI_COD ) == xFilial("DAI") + DAK->DAK_COD
       If ! _lAutomatico

         IF valtype(oproc) = "O"

                  oproc:cCaption := ("Lendo Pedido: "+DAI->DAI_PEDIDO)
                  _npos++
                  ProcessMessages()

         ENDIF

       EndIf

        IF !SC5->( DbSeek( xFilial("SC5") + DAI->DAI_PEDIDO ) )
            DAI->(DBSKIP())
            LOOP
        ENDIF
        _cNomCli:=''

        IF SC5->C5_TIPO $ "B/D"

            SA2->( DbSetOrder(1) )
            IF SA2->( DbSeek( xFilial("SA2") + DAI->( DAI_CLIENT + DAI_LOJA ) ) )
                _cNomCli := "FO: "+DAI->DAI_CLIENT+" - "+AllTrim(SA2->A2_NOME)
            EndIf

        Else

            SA1->( DbSetOrder(1) )
            IF SA1->( DbSeek( xFilial("SA1") + DAI->( DAI_CLIENT + DAI_LOJA ) ) )
                _cNomCli := "CL: "+DAI->DAI_CLIENT+" - "+AllTrim(SA1->A1_NOME)
            EndIf

        EndIF

        If !empty(DAI->DAI_I_OPLO)

            _coplog := DAI->DAI_I_OPLO
            _coploj := DAI->DAI_I_LOPL

        Else

            _coplog := DAK->DAK_I_OPER
            _coploj := DAK->DAK_I_OPLO

        Endif

        If !empty(DAI->DAI_I_TRED)

            _ctred := DAI->DAI_I_TRED
            _ctrlj := DAI->DAI_I_LTRE

        Else

            _ctred := DAK->DAK_I_REDP
            _ctrlj := DAK->DAK_I_RELO

        Endif


        IF DAI->DAI_I_OPER="1" .AND. !EMPTY(_coplog) .AND. SA2->( DBSeek( xFilial('SA2') + _coplog+_coploj ) )
            _cNomCli := "OP: "+_coplog+" - "+AllTrim(SA2->A2_NOME)
        EndIF

        IF DAI->DAI_I_REDP="1" .AND. !EMPTY(_ctred) .AND. SA2->( DBSeek( xFilial('SA2') + _ctred+_ctrlj ) )
            _cNomCli := "TR: "+_ctred+" - "+AllTrim(SA2->A2_NOME)
        EndIF

        _cTipoCarga:=IF(DAI->DAI_I_TIPC="1","Pallet Chep",;
                     IF(DAI->DAI_I_TIPC="2","Estivada",;
                     IF(DAI->DAI_I_TIPC="3","Pallet PBR",;
                     IF(DAI->DAI_I_TIPC="4","Plt Descartavel",;
                     IF(DAI->DAI_I_TIPC="5","Plt Chep Retorno",;
                     IF(DAI->DAI_I_TIPC="6","Plt PBR Retorno","            "))))))

        AADD(_aCargas,{DAI->DAI_PEDIDO,;//01
                       DAI->DAI_PESO,;  //02
                       DAI->(RECNO()),; //03 - Usado no Estono da Carga
                       ""            ,; //04
                       _cNomCli,;       //05
                       _cTipoCarga })   //06

        DAI->(DBSKIP())

    ENDDO

 ENDIF

RETURN _aCargas

/*
===============================================================================================================================
Programa----------: AcessaPV()
Autor-------------: Josué Danich
Data da Criacao---: 14/11/2016
Descrição---------: Visualiza Pedido
Parametros--------: cpedido - Numero do pedido
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function IT_VisuPV(cPedido As Char)
 Local aArea       := FwGetArea() As Array //Irei gravar a area atual
 Private Inclui    := .F. As Logical //defino que a inclusão é falsa
 Private Altera    := .T. As Logical //defino que a alteração é verdadeira
 Private nOpca     := 1   As Numeric //obrigatoriamente passo a variavel nOpca com o conteudo 1
 Private cCadastro := "Pedido de Vendas" As Char //obrigatoriamente preciso definir com private a variável cCadastro
 Private aRotina   := {} As Array //obrigatoriamente preciso definir a variavel aRotina como private

 DbSelectArea("SC5") //Abro a tabela SC5
 SC5->(dbSetOrder(1)) //Ordeno no índice 1
 SC5->(dbSeek(xFilial("SC5")+cPedido)) //Localizo o meu pedido
 If SC5->(!EOF()) //Se o pedido existe irei continuar
    SC5->(DbGoTo(Recno())) //Me posiciono no pedido
    FwMsgRun( ,{|| MatA410(Nil, Nil, Nil, Nil, "A410Visual")},'Aguarde!','Lendo dados do Pedido...')
 Endif
 SC5->(DbCloseArea()) //quando eu sair da tela de visualizar pedido, fecho o meu alias
 FwRestArea(aArea) //restauro a area anterior.

Return
/*
===============================================================================================================================
Programa----------: OM200Pallets()
Autor-------------: Alex Wallauer
Data da Criacao---: 17/08/2016
Descrição---------: Leitura dos dados dos Pallets
Parametros--------: Nenhum
Retorno-----------: .T.
===============================================================================================================================*/
Static Function OM200Pallets()
 LOCAL _cQuery1:=" SELECT SUM(C6_I_QPALT) NQTD FROM "+ RETSQLNAME("SC6") + " WHERE C6_FILIAL = '"+ xFilial('SC6')+"' AND D_E_L_E_T_ = ' ' "
 LOCAL _cQuery2:="",_cPallet,_TipoC
 Local _cAlias:=GetNextAlias()

_nFretOL2:=0//variavel Statica

 SA2->( DbSetOrder(1) )
 SA1->( DbSetOrder(1) )
 SC5->( DbSetOrder(1) )
 _cEstados:=""//Variavel preenchida para o F3 dos operadores, NÃO RETIRE
 TRBPED->(dbGotop())
 DO WHILE TRBPED->(!EOF())//o TRBPED já está filtrado só os pedidos marcados

    SC5->( DbSeek( xFilial("SC5") + TRBPED->PED_PEDIDO ) )
    IF !EMPTY(SC5->C5_I_EST) .AND. !SC5->C5_I_EST $ _cEstados
       _cEstados+=SC5->C5_I_EST+";"//Variavel preenchida para o F3 dos operadores, NÃO RETIRE
    ENDIF

    IF EMPTY(TRBPED->PED_I_TIPC)//Esse controle é pela primeira fez que entra na tela e o campo SC5->C5_I_TIPCA estava em branco

       _cPallet:="2"
       _TipoC  :=""

       If SA1->( DBSeek( xFilial("SA1") + TRBPED->(PED_CODCLI+PED_LOJA) ) )
          _TipoC := SA1->A1_I_CHEP
            IF !EMPTY(SA1->A1_I_PALET)
             _cPallet:= SA1->A1_I_PALET
             ENDIF
       EndIf


       IF EMPTY(_TipoC)
          _TipoC := "C"
       ENDIF

       TRBPED->PED_I_TIPC:= "2"

       IF !SC5->C5_TIPO $ "B/D"//Se NÃO for beneficiamento e Devolução
          IF _cPallet $ "S,1"
             IF _TipoC = "C"//Esse controle é pela a origem dos dados para deixar alterar o tipo de carga inclusive se o usuario já alterou, saiu e entrou na tela de novo
                TRBPED->PED_I_TIPC:= "1"
             ELSE
                TRBPED->PED_I_TIPC:= "3"
             ENDIF
          ELSE
             TRBPED->PED_I_TIPC:= "2"
          ENDIF
       EndIF

    ENDIF

    If TRBPED->PED_I_TIPC $ "5,6"//"5-Pallet Chep Retorno","6-Pallet PBR Retorno"
       _lTemPalletRetorno:=.T.
    ENDIF

    IF TRBPED->PED_I_TIPC $ TP_GERA_PALET .AND. EMPTY(TRBPED->PED_I_QTPA)//Esse controle é para nao sobrepor os dados que o usuario já alterou, saiu e entrou na tela de novo

       _cQuery2:=" AND C6_NUM = '"+ TRBPED->PED_PEDIDO+"' "

       MPSysOpenQuery( (_cQuery1+_cQuery2) , _cAlias)

       If (_cAlias)->( !Eof() )
           TRBPED->PED_I_QTPA := ROUND((_cAlias)->NQTD,0)
       EndIf

       (_cAlias)->( DBCloseArea() )

    ENDIF

    IF TRBPED->(FIELDPOS("PED_I_FROL")) > 0
       _nFretOL2+=TRBPED->PED_I_FROL
    ENDIF

    TRBPED->(DBSKIP())

 ENDDO

 dbSelectArea("TRBPED")

RETURN .T.

/*
===============================================================================================================================
Programa--------: GeraPedPallet(_aPeds_Pallet,_lAutomatico)
Autor-----------: Alex Wallauer
Data da Criacao-: 18/08/2016
Descrição-------: Gera Pedidos de Pallet
Parametros------: Lista de dos pedidos
                  _lAutomatico = .T. = Rotina rodada automaticamente / .F. = Rotina rodada manualmente. / oproc barra de processamento
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
Static Function GeraPedPallet(_aPeds_Pallet,_lAutomatico,oproc)
 LOCAL _cDesc  := "",_cPedPallet
 LOCAL _nPreco := _nTotVlrPal:=_nPallet:=0
 LOCAL _cUM	  := "",_Ped
 Local _ntot := 0
 Local _npos := 1
 Local _citls := AllTrim( U_ITGETMV( 'IT_CHEPITLS' ) )
 Local _citln := AllTrim( U_ITGETMV( 'IT_CHEPITLN' ) )
 Local _cclis := AllTrim( U_ITGETMV( 'IT_CHEPCLIS' ) )
 Local _cclin := AllTrim( U_ITGETMV( 'IT_CHEPCLIN' ) )
 Local _cchep := GetMV( "IT_CCHEP" )
 Local _cpbr :=  GetMV( "IT_PPBR" )
 Local _cPBRITLP := AllTrim( U_ITGETMV( 'IT_PBRITLP','51' ) )
 Local _cPBRCLIP := AllTrim( U_ITGETMV( 'IT_PBRCLIP','51' ) )
 Local _cTipoFrete

 Default oproc := nil

 If ! _lAutomatico
    _ntot := (LEN(_aPeds_Pallet))
 EndIf

 FOR _Ped := 1 TO LEN(_aPeds_Pallet)

    SA2->( DBSetOrder(1) )
    SBZ->( DBSetOrder(1) )
    SC5->( DBSetOrder(1) )
    SC6->( DBSetOrder(1) )
    DA4->( DBSetOrder(1) )

    SC5->( DBGOTO( _aPeds_Pallet[_Ped,1] ))
    TRBPED->( DBGOTO( _aPeds_Pallet[_Ped,2] ))

    If ! _lAutomatico

        IF valtype(oproc) = "O"

                  oproc:cCaption := ("Lendo Pedido: "+TRBPED->PED_PEDIDO + " - " + strzero(_npos,6) + " de " + strzero(_ntot,6))
                  _npos++
                  ProcessMessages()

        Endif

    EndIf

     //_cUPalet	:= TRBPED->PED_I_TIPC
    _nPallet    := TRBPED->PED_I_QTPA//Qtde do Pallet

    _cFilOrigem := SC5->C5_FILIAL
    _cPedOrigem := SC5->C5_NUM
    cTipoPV		:= SC5->C5_TIPO
    cCliente	:= SC5->C5_CLIENTE
    cLoja		:= SC5->C5_LOJACLI
    _cTipoFrete := SC5->C5_TPFRETE

    SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
    _cC6_PEDCLI := SC6->C6_PEDCLI
    _cC6_ITEMPC := SC6->C6_ITEMPC
    _cC6_NUMPCOM:= SC6->C6_NUMPCOM

    SA2->(Dbsetorder(1))
    /* CHAMADO 36754 - DESBILITADO POR ENQUANTO
    SA1->(Dbsetorder(3))
    IF cTipoPV = "B" .AND. SA2->( DBSeek( xFilial("SA2") + SC5->C5_CLIENTE+SC5->C5_LOJACLI ) ) .AND. SA1->( DBSeek( xFilial("SA1") + SA2->A2_CGC ) )
       cTipoPV	:= "N"
       cCliente	:= SA1->A1_COD
       cLoja	:= SA1->A1_LOJA
    ELSE
       _cMensagem:='Erro ao gerar o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")+", For. / CNPJ: "+SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI +" / "+SA2->A2_CGC+" não encontrados no cadastro de Clientes."
       aAdd( _aLog , {.F.,SC5->C5_NUM,"Nao gerado",_cMensagem  ,"",cTpOper ,_cLocal,SC5->C5_I_FLFNC,SC5->C5_I_FILFT} )
       _aPeds_Pallet[_Ped,3]:=0//Zero para ignorar no proximo processamento/funcao LiberaPedPallCarga(_aPeds_Pallet)
       _lGerouOK:=.F.
       U_ITCONOUT(_cMensagem)
       LOOP
    ENDIF*/
    _dDtEnt		:= IF(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT)//Para nao travar a criacao do Pedido de Pallet
    _cLocal     := Posicione('SC6',1,SC5->C5_FILIAL+SC5->C5_NUM,"C6_LOCAL")

    _aCabPV		:= {}
    _aItemPV	:= {}
    _TipoC		:= "C"//1-Pallet Chep
    cTpOper		:= ''
    lMsErroAuto	:= .F.
    nItem		:= 1
    _cDesc      := ""
    _nPreco     := 0
    _cUM	    := ""

    If TRBPED->PED_I_TIPC $ "3,6"//"3-Pallet PBR","6-Pallet PBR Retorno"
       _TipoC:="P"
    ENDIF

    If TRBPED->PED_I_TIPC $ "5,6"//"5-Pallet Chep Retorno","6-Pallet PBR Retorno"
       If _cPreCarga = "2" .AND. !EMPTY(_cMotorDAK) .AND. UPPER(_cTipo) == "PJ-TRANSPORTADORA"
          IF DA4->(dbSeek(xFilial("DA4")+_cMotorDAK)) .AND. !EMPTY(DA4->DA4_FORNEC)
                SA1->(DBSETORDER(3))
             IF SA2->( DBSeek( xFilial("SA2") + DA4->DA4_FORNEC+DA4->DA4_LOJA ) ) .AND. SA1->( DBSeek( xFilial("SA1") + SA2->A2_CGC ) )
                cCliente:= SA1->A1_COD
                cLoja	:= SA1->A1_LOJA
             ELSE
                _cMensagem:='Erro ao gerar o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")+", For. / CNPJ: "+DA4->DA4_FORNEC+" / "+DA4->DA4_LOJA+" / "+SA2->A2_CGC+" não encontrados no cadastro de Clientes."
                aAdd( _aLog , {.F.,SC5->C5_NUM,"Nao gerado",_cMensagem  ,"",cTpOper ,_cLocal,SC5->C5_I_FLFNC,SC5->C5_I_FILFT} )
                _aPeds_Pallet[_Ped,3]:=0//Zero para ignorar no proximo processamento/funcao LiberaPedPallCarga(_aPeds_Pallet)
                _lGerouOK:=.F.
                //U_ITCONOUT(_cMensagem) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
                LOOP
             ENDIF
          ELSE
             _cMensagem:='Erro ao gerar o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")+", Motorista: "+_cMotorDAK+" não encontrado ou não tem código de Fornecedor"
             aAdd( _aLog , {.F.,SC5->C5_NUM,"Nao gerado",_cMensagem  ,"",cTpOper ,_cLocal,SC5->C5_I_FLFNC,SC5->C5_I_FILFT} )
             _aPeds_Pallet[_Ped,3]:=0//Zero para ignorar no proximo processamento/funcao LiberaPedPallCarga(_aPeds_Pallet)
             _lGerouOK:=.F.
             //U_ITCONOUT(_cMensagem) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
             LOOP
          ENDIF
       ELSEIf _cPreCarga = "1" .OR. (EMPTY(_cMotorDAK) .AND. UPPER(_cTipo) == "PJ-TRANSPORTADORA")
          _cMensagem:='Não gerou o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")+", Será gerado ao Efetivar a Pre-Carga"
          aAdd( _aLog , {.T.,SC5->C5_NUM,"Nao gerado",_cMensagem  ,"",cTpOper ,_cLocal,SC5->C5_I_FLFNC,SC5->C5_I_FILFT} )
          _aPeds_Pallet[_Ped,3]:=0//Zero para ignorar no proximo processamento/funcao LiberaPedPallCarga(_aPeds_Pallet)
          //U_ITCONOUT(_cMensagem) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
          LOOP
       ENDIF
    ENDIF
    //====================================================================================================
    // Verifica se o Cliente esta com Pallet == Sim
    //====================================================================================================
    If .T.//Upper( _cUPalet ) $ '1,S' .And. M->C5_I_TIPCA <> "2" // Tipo de Carga (C5_TIPCA) => 1=Paletizada; 2=Batida

        //====================================================================================================
        // Verifica se o pedido atual já não está amarrado à um pedido de Pallet
        //====================================================================================================
        If .T.//Empty( SC5->C5_I_NPALE )


            //====================================================================================================
            // Verifica se houveram vendas com quantidade de Pallets
            //====================================================================================================
            If _nPallet > 0
                //====================================================================================================
                // Verifica o Tipo de Pallet e recupera o código do Produto referente
                //====================================================================================================
                If _TipoC == "C"
                    _cProduto := _cchep
                ElseIf _TipoC == "P"
                    _cProduto := _cpbr
                EndIf

                //====================================================================================================
                // Verifica se no cadastro do Cliente É CLIENTE CADASTRADO NA CHEP
                //====================================================================================================
                _clichep := "N"
                SA1->(Dbsetorder(1))
                If SA1->( DBSeek( xFilial("SA1") + ( cCliente + cLoja ) ) )

                    IF LEN(ALLTRIM(SA1->A1_I_CCHEP)) == 10
                        _clichep := "S"
                    ENDIF

                EndIf

                If _TipoC == "C" //Pallet Chep

                    If cCliente == '000001'

                        If _clichep == "S"
                            cTpOper	:= _citls
                        Else
                            cTpOper	:= _citln
                        EndIf

                    Else

                        If _clichep == "S"
                            cTpOper	:= _cclis
                        Else
                            cTpOper	:= _cclin
                        EndIf

                    EndIf

                Elseif _TipoC == "P" //Pallet PBR

                    If cCliente == '000001'

                        cTpOper	:= _cPBRITLP

                    Else

                        cTpOper	:= _cPBRCLIP

                    Endif

                Endif

                 //====================================================================================================
                 // Monta o cabeçalho do pedido de Pallet
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
                            { "C5_TPFRETE"	, _cTipoFrete		, Nil },; // Tipo de Frete
                            { "C5_I_DTENT"	, _dDtEnt			, Nil } } // Dt de Entrega

                //====================================================================================================
                // Quando Pedido de Pallet Retorno e for Troca Nota o Pedido deve ser gerado na Filial de Carregamento
                //====================================================================================================

                If TRBPED->PED_I_TIPC $ "1,3,4"
                    Aadd( _aCabPV, { "C5_I_TRCNF", IF(EMPTY(SC5->C5_I_TRCNF),"N",SC5->C5_I_TRCNF), Nil } )
                    Aadd( _aCabPV, { "C5_I_FILFT", SC5->C5_I_FILFT, Nil } )
                    Aadd( _aCabPV, { "C5_I_FLFNC", SC5->C5_I_FLFNC, Nil } )
                EndIf

                If SC5->(FIELDPOS( "C5_I_CDTMS" )) > 0
                   Aadd( _aCabPV, { "C5_I_CDTMS", SC5->C5_I_CDTMS, Nil } )
                EndIf

                //================================================================================
                // Localiza armazém do produto
                //================================================================================

                If !_cLocal $ AllTrim( U_ITGETMV( 'IT_LOCPPALL',"36,38,40,50" ) )

                  _cLocal := ""
                  If SBZ->( DBSeek( xFilial('SBZ') + _cProduto ) )
                     _cLocal := SBZ->BZ_LOCPAD
                  EndIf

                Endif

                //================================================================================
                // Localiza nome do produto, preço e UM
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
                // Geração do  pedido de Pallet
                MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItemPV , 3 )

                If lMsErroAuto

                    If ( __lSx8 )
                        RollBackSx8()
                    EndIf

                    If ! _lAutomatico
                       _cMensagem:="Erro: ["+ALLTRIM(MostraErro())+"]"
                    Else
                       _cMsgEfetiva := " Pedido_"+AllTrim(_cPedOrigem)+" - "+AllTrim(MostraErro("\system\", "Pedido_"+AllTrim(SC5->C5_NUM)+"_"+DTos(Date())+"_"+StrTran(Time(),":","-")+".log")) // Esta mensagem será retornada na integração com Webservice Italac x RDC.
                       _cMsgEfetiva := " Ocorreram problemas na Geração de Pedidos de Pallet: " + StrTran(_cMsgEfetiva,Chr(10)+Chr(13),"")
                    EndIf

                    If _lAutomatico
                       _cMsgEfetiva := IF(SC5->C5_I_TRCNF="S"," (Rotina Troca Nota Fiscal): ","")+_cMsgEfetiva
                       //U_ITCONOUT(_cMsgEfetiva) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
                    ELSE
                       SC5->( DBGOTO( _aPeds_Pallet[_Ped,1] ))
                       _cMensagem:='Erro ao gerar o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")+" ,"+_cMensagem
                       _cCliente:=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )

                        aAdd( _aLog , {.F.,SC5->C5_NUM,"Nao gerado",_cMensagem  ,_cCliente,cTpOper ,_cLocal  ,SC5->C5_I_FLFNC      ,SC5->C5_I_FILFT     } )
                    EndIf

                    _aPeds_Pallet[_Ped,3]:=0//Zero para ignorar no proximo processamento/funcao LiberaPedPallCarga(_aPeds_Pallet)
                    _lGerouOK:=.F.
                    LOOP //do FOR

                Else
                    //Regrava por garantia
                    SC5->( RecLock( 'SC5' , .F. ) )
                    SC5->C5_I_NPALE := _cPedOrigem
                    SC5->C5_I_PEDPA := 'S'//É o Pedido de Pallet
                    SC5->C5_I_PEDGE := ''
                    SC5->( MsUnlock() )
                    _cCliente:=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
                    _cMensagem:='Gerou o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")
                    //U_ITCONOUT(_cMensagem+": "+SC5->C5_NUM) // Comando removido conforme estabelecido no CheckList de Desenvolvimento.
                     aAdd( _aLog , {.T.,_cPedOrigem,SC5->C5_NUM,_cMensagem   ,_cCliente,cTpOper ,_cLocal  ,SC5->C5_I_FLFNC      ,SC5->C5_I_FILFT     } )

                    SC6->(DBSetOrder(1))
                    SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )//Posiciono por garantia
                    _aPeds_Pallet[_Ped,3]:=SC5->(RECNO())//3-Recno do Pedido Novo de Pallet
                    _aPeds_Pallet[_Ped,4]:=_cLocal       //4-Local do Pedido do Pallet
                    _aPeds_Pallet[_Ped,5]:=SC6->(RECNO())//5-Recno do Pedido Novo de Pallet

                    //====================================================================================================
                    // Faz a amarração do pedido de origem no pedido de Pallet
                    //====================================================================================================
                    _cPedPallet := SC5->C5_NUM
                    If SC5->( DBSeek( _cFilOrigem + _cPedOrigem ) )
                       SC5->( RecLock( 'SC5' , .F. ) )
                       SC5->C5_I_NPALE := _cPedPallet
                       SC5->C5_I_PEDPA := ''
                       SC5->C5_I_PEDGE := 'S' //É o Pedido Gerador de Pallet
                       SC5->( MsUnlock() )
                    EndIf
                EndIf

            EndIf

        //ELSE

            //U_ITCONOUT("Pedido:"+_cPedOrigem+" sem quantidade de Pallet")// Comando removido conforme estabelecido no CheckList de Desenvolvimento.

        EndIf

    EndIf

 NEXT

 SA1->(DBSETORDER(1))

RETURN _lGerouOK

/*
===============================================================================================================================
Programa--------: LiberaPedPallCarga(_aPeds_Pallet,_lAutomatico)
Autor-----------: Alex Wallauer
Data da Criacao-: 02/09/2016
Descrição-------: Libera Pedido de Pallet
Parametros------: Lista dos pedidos
                  _lautomatico - se está rodando em schedule ou não
                  oproc - objeto da barra de processamento
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
Static Function LiberaPedPallCarga(_aPeds_Pallet,_lAutomatico, oproc)
 LOCAL _cCliente,_Ped,_nQtdLib
 LOCAL lErroSC9:=.F.,lOK:=.T.
 Local _ntot := 0
 Local _npos := 1

 Default _lAutomatico := .F.
 Default oproc := nil

 If ! _lAutomatico
    _ntot := (LEN(_aPeds_Pallet))
 EndIf

 SC6->( DbSetOrder(1) )
 SC9->( DbSetOrder(1) )

 FOR _Ped := 1 TO LEN(_aPeds_Pallet)

    IF _aPeds_Pallet[_Ped,3] = 0//Nao gerou o Pedido Pallet novo
       LOOP
    ENDIF

    TRBPED->( DBGOTO( _aPeds_Pallet[_Ped,2] ))
    SC5->( DBGOTO( _aPeds_Pallet[_Ped,3] ))//Pedido Pallet novo

    If ! _lAutomatico

              IF valtype(oproc) = "O"

                  oproc:cCaption := ("Lendo Pedido: "+SC5->C5_NUM + " - " + strzero(_npos,6) + " de " + strzero(_ntot,6))
                  _npos++
                  ProcessMessages()

              ENDIF

     EndIf

    //====================================================================================================
    // Liberaoca de Pedido - reserva de estoque
    //====================================================================================================
    SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
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

    _cCliente:=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
    lBloqEstoque:=lBloqCredito:=lErroSC9:=.F.
    lOK:=.T.
    If lMsErroAuto .OR. ( lErroSC9:=Ver_SC9(SC5->C5_FILIAL+SC5->C5_NUM) )

       IF lErroSC9
          _cMensagem:='Liberou o Ped. Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF) ","")+", mas com Bloqueio de"+IF(lBloqEstoque," Estoque","")+IF(lBloqCredito," Credito","")
       ELSE
          _cMensagem:='Erro ao liberar o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")
       ENDIF

       _lGerouOK:=lOK:=.F.

    Else

       IF SC5->C5_LIBEROK # "S"
          SC5->(RECLOCK("SC5",.F.))
          SC5->C5_LIBEROK:="S"
          SC5->(MSUNLOCK())
       ENDIF

        _cMensagem:='Liberou Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")

    Endif

    //dd( _aLog , {" ",'Pedido O'        ,'Pedido G' ,'Movimentacao','Cliente',Operacao      ,'Armazem'            ,'Filial Carregamento','Filial Faturamento'} )
    aAdd( _aLog , {lOK,TRBPED->PED_PEDIDO,SC5->C5_NUM,_cMensagem    ,_cCliente,SC5->C5_I_OPER,_aPeds_Pallet[_Ped,4],SC5->C5_I_FLFNC      ,SC5->C5_I_FILFT     } )


 NEXT

RETURN .T.
/*
===============================================================================================================================
Programa--------: IncliPedPallCarga(_aPeds_Carga,lEfetiva_Pre_Carga,_lAutomatico)
Autor-----------: Alex Wallauer
Data da Criacao-: 18/08/2016
Descrição-------: Libera e Inclui Pedido de Pallet da Carga
Parametros------: Lista dos pedidos , Efetiva Pre-Carga: .T. ou .F. / oproc - objeto da barra de processamento
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================*/
Static Function IncliPedPallCarga(_aPeds_Pallet,lEfetiva_Pre_Carga,_lAutomatico,oproc)
 LOCAL _cCliente,_Ped,_nCpo
 Local _ntot := 0
 Local _npos := 1
 Default _lAutomatico := .F.
 Default oproc := nil

 If ! _lAutomatico
    _ntot := LEN(_aPeds_Pallet)
 EndIf

 FOR _Ped := 1 TO LEN(_aPeds_Pallet)

    IF _aPeds_Pallet[_Ped,3] = 0//Nao gerou o Pedido Pallet novo
       LOOP
    ENDIF

    TRBPED->( DBGOTO( _aPeds_Pallet[_Ped,2] ))
    SC5->( DBGOTO( _aPeds_Pallet[_Ped,3] ))//Pedido Pallet novo
    SC6->( DBGOTO( _aPeds_Pallet[_Ped,5] ))//Item Pedido Pallet novo

    If ! _lAutomatico

        IF valtype(oproc) = "O"

              oproc:cCaption := ("Lendo Pedido: "+SC5->C5_NUM + " - " + strzero(_npos,6) + " de " + strzero(_ntot,6))
              _npos++
               ProcessMessages()

        ENDIF


    EndIf

    _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
    _cMensagem:='Inclusao na Carga do Ped. Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")

    //dd( _aLog    , {" ",'Pedido O'        ,'Pedido G'  ,'Movimentacao','Cliente',Operacao      ,'Armazem'            ,'Filial Carregamento','Filial Faturamento'} )
    aAdd( _aLog    , {.T.,TRBPED->PED_PEDIDO,SC5->C5_NUM ,_cMensagem    ,_cCliente,SC5->C5_I_OPER,_aPeds_Pallet[_Ped,4],SC5->C5_I_FLFNC      ,SC5->C5_I_FILFT} )

    _aConteudos:={}
    FOR _nCpo := 1 TO TRBPED->( FCOUNT() )
        AADD(_aConteudos,TRBPED->( FIELDGET(_nCpo) ))
    NEXT
    TRBPED->( DBAPPEND() )
    FOR _nCpo := 1 TO LEN(_aConteudos)
        TRBPED->( FIELDPUT(_nCpo,_aConteudos[_nCpo]) )
    NEXT

    IF lEfetiva_Pre_Carga

       TRBPED->PED_PEDIDO:=SC5->C5_NUM
       TRBPED->PED_CODCLI:=SC5->C5_CLIENTE
       TRBPED->PED_LOJA  :=SC5->C5_LOJAENT
       TRBPED->PED_PESO  :=SC5->C5_I_PESBR
       TRBPED->PED_VALOR :=SC6->C6_VALOR
       TRBPED->PED_QTDLIB:=SC6->C6_QTDVEN

    ELSE

       TRBPED->PED_PEDIDO:=SC5->C5_NUM
       TRBPED->PED_MARCA :=""//Desmarca para marcar abaixo
       TRBPED->PED_PESO  :=SC5->C5_I_PESBR
       TRBPED->PED_VALOR :=SC6->C6_VALOR
       TRBPED->PED_VOLUM :=0//Volume vem zerado do Pedido Orginal
       TRBPED->PED_QTDLIB:=SC6->C6_QTDVEN
       IF TRBPED->(FIELDPOS("PED_I_FROL")) > 0
          TRBPED->PED_I_FROL:=0//Zera o campo de Frete do OL para não duplicar o valor do frete OL Total
       ENDIF

       EVAL(_bMarcaTRB)//Simula Excutar os 2 cliques do Browse de selecao de Pedidos para usar apos incliir linha no TRB nova

    ENDIF

 NEXT

RETURN .T.


/*
===============================================================================================================================
Programa--------: Ver_SC9(cChave)
Autor-----------: Alex Wallauer
Data da Criacao-: 30/08/2016
Descrição-------: Verefica se no SC9 esta tudo OK
Parametros------: cChave: Filia + Pedido
Retorno---------: Lógico (.F.) Se tudo OK (.T.) Se deu erro
==============================================================================================================================
*/
Static Function Ver_SC9(cChave)
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
Programa--------: OM200PegaObs(_cObsEmail)
Autor-----------: Alex Wallauer
Data da Criacao-: 20/09/2016
Descrição-------: Get da observacao do e-mail
Parametros------: _cObsEmail variavel da observação
Retorno---------: Lógico (.F.) Se OK (.T.) Se Cancelou
===============================================================================================================================*/
Static Function OM200PegaObs(_cObsEmail)
 Local oDlgEmail,_lOK:=.T.
 Local _nLinha := 15
 Local _nPula  := 15

 DEFINE MSDIALOG oDlgEmail TITLE "Observações no Corpo do E-mail do WF" From 000,000 To 165,600 Pixel

     @_nLinha,005 Say "Obs. E-mail:"
     @_nLinha,045 GET _cObsEmail MEMO HSCROLL SIZE 250,33 PIXEL
     _nLinha+=_nPula+_nPula+_nPula

     @ _nLinha,100 Button "OK"      Size 36,16 Action (IF(MSGYESNO('Confirma o envio do E-mail de WF de Carga ?',"WF de Carga"), (oDlgEmail:End(),_lOK:=.T.) , ))
     @ _nLinha,175 Button "Cancela" Size 36,16 Action (oDlgEmail:End(),_lOK:=.F.)

 ACTIVATE MSDIALOG oDlgEmail CENTERED

 IF !_lOK
    RETURN .F.
 ENDIF

RETURN .T.


/*
===============================================================================================================================
Programa--------: BuscaEmail(_lAutomatico,_cMailUser)
Autor-----------: Alex Wallauer
Data da Criacao-: 20/09/2016
Descrição-------: Trata emails
Parametros------: _lAutomatico: logico ,_cMailUser : email do usuario
Retorno---------: Emails
===============================================================================================================================*/
Static Function BuscaEmail(_lAutomatico,_cMailUser)
 Local _cEmail := ALLTRIM(U_ITGETMV("IT_WFCARGA",""))
 //=========================================================================================
 // Concatena o e-mail do usuário que criou a carga através da rotina de
 // integração RDC via webservice. A variável _cMailUsrCarga foi definida fonte AOMS074.PRW
 //=========================================================================================
 If _lAutomatico
    If Type("_cMailUsrCarga") == "C" .And. !Empty(_cMailUsrCarga)
       _cMailUser := AllTrim(_cMailUsrCarga)
    EndIf
 ELSE
    PswOrder(1)
    PswSeek(__CUSERID,.T.)
    aUsuario  :=PswRet()
    _cMailUser:=Alltrim(aUsuario[1,14])
 EndIf

 If Empty( _cEmail )//Se o paramentro estiver em branco envia para o usuario
    _cEmail:=_cMailUser
    _cMailUser:=""//Não envia copia
 ENDIF

RETURN _cEmail


/*
===============================================================================================================================
Programa--------: IT_EditCell
Autor-----------: Alex Wallauer
Data da Criacao-: 14/03/2015
Descrição-------: Edita o campo da celula do browse selecionado com um get ou combo box
Parametros------: _xGetValor ,oBrowse As object ,cPict as char ,nCol as numeric ,cF3 as char,lReadOnly as logical, bValid as block ,aItems as array do combo
Retorno---------: .T. se OK .F. se Cancelou
===============================================================================================================================*/
User Function IT_EditCell(_xGetValor ,oBrowse As object ,cPict as char ,nCol as numeric ,cF3 as char,lReadOnly as logical, bValid as block ,aItems as array ) As Logical
  Local oDlg      := Nil as object
  Local oRect     := tRect():New(0,0,0,0) as object
  Local oGet1     := Nil as object
  Local oBtn      := Nil as object
  Local nRow      := oBrowse:nAt as object
  Local cMacro    := "M->CELL"+StrZero(nRow,6) as character
  Local lCargo    := .F. as logical
  Local nLastKey  := 00 as numeric
  Local aDim      := {} as array

  DEFAULT cPict     := ''
  DEFAULT nCol      := oBrowse:nColPos
  DEFAULT lReadOnly := .F.
  DEFAULT bValid    := {|| .T.}

  oBrowse:GetCellRect(nCol,,oRect)   // a janela de edicao deve ficar)
  aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

  oDlg     := MSDialog():New(0,0,0,0,'Janela sem borda',,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,.T.)
  oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

  &(cMacro):= _xGetValor

  If ValType(aItems) == "A"
    oGet1       := TComboBox():New(0,0, {|u| If( PCount() > 0 , &(cMacro) := u , &(cMacro) ) } ,aItems,0,0,oDlg,,,,,,.T.,,,.F.,,.F.,,)
    oGet1:bValid:= { || lCargo := Eval(bValid) }
  Else                  // LIN ,[ nCol ], [ bSetGet ]                                         , [ oWnd ], [ nWidth ], [ nHeight ], [ cPict ], [ bValid ], [ nClrFore ], [ nClrBack ], [ oFont ], [ uParam12 ], [ uParam13 ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ bWhen ], [ uParam18 ], [ uParam19 ], [ bChange ], [ lReadOnly ], [ lPassword ], [ uParam23 ], [ cReadVar ], [ uParam25 ], [ uParam26 ], [ uParam27 ], [ lHasButton ], [ lNoButton ], [ uParam30 ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ], [ cPlaceHold ], [ lPicturePriority ]
    oGet1       := TGet():New(0,0       ,{|u| If( PCount() > 0 , &(cMacro) := u , &(cMacro)) },oDlg     ,0          ,0           ,cPict     ,           ,             ,             ,          ,             ,             ,.T.        ,             ,             ,          ,             ,             ,            ,              ,              ,             ,             ,             ,             ,             ,               ,)
    oGet1:bValid   := { || lCargo := Eval(bValid) }
    oGet1:cF3      := cF3
    oGet1:lReadOnly:= lReadOnly
    // oGet1:lNoButton := .F.
  EndIf
  oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) - 12, aDim[ 3 ] - aDim[ 1 ] + 4 )

  oBtn       := TButton():New( 0, 0, 'ud', oDlg, , 0, 0, , , .F., .T., .F., , .F., , , .F. )
  oBtn:bGotFocus  := {|| nLastKey := oDlg:nLastKey := VK_RETURN, oDlg:End(0)}
  oGet1:cReadVar  := cMacro

  oDlg:bInit     := { || oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1]) }
  oDlg:Activate(,,,)

  If lCargo
    _xGetValor:= &cMacro
    SetFocus(oBrowse:hWnd)
    //oBrowse:Refresh()
  EndIf

Return( nLastKey <> 0 )
