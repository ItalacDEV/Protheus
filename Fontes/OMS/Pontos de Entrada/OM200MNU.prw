/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor   |    Data    |                             Motivo
------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 18/01/2019 | Chamado 27764.  Revisão para servidor loboguara.
 Julio Paz     | 15/05/2019 | Chamado 29195.  Inclusão de validações para não permitir o estorno de cargas faturadas.
 Lucas Borges  | 11/10/2019 | Chamado 28346.  Removidos os Warning na compilação da release 12.1.25.
 Julio Paz     | 17/01/2020 | Chamado 31535.  Inclusão para as opções de menu, para integração com o sistema Krona.
 Julio Paz     | 16/09/2020 | Chamado 34159.  Correções nas formações de nomes dos campos para a tabela temporária TRBPED.
 Alex Wallauer | 01/06/2022 | Chamado 40254.  Inclusão para as opções de menu, para Check List Carregamento.
================================================================================================================================================================================================================================================
 Analista        - Programador    - Inicio    - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================================================================
 Vanderlei Alves  - Igor Melgaço  - 26/12/24 - 10/06/25 - 49427   - Inclusão do metodo de alteração de carga.
 Vanderlei Alves  - Julio Paz     - 14/03/25 - 10/06/25 - 50188   - Desenvolvimento de Rotina de Integração Webservice Protheus x TMS Multiembarcador Para Replicar Cargas Criadas no Protheus para o TMS Multiembarcador [OMS]
 Alex Wallauer    - Alex Wallauer - 31/03/25 - 10/06/25 - 49966   - CORREÇÃO DE ERROR.LOG: Alias already in use: TRBPED on FWOPENTEMP(CRIATRAB.PRG) 01/04/2025 19:02:17 line : 271
 Vanderlei Alves  - Alex Wallauer - 25/07/25 - 37/07/25 - 49894   - Retirado o botão "Ajuste Peso" pq não acerta o rateio do frete e pedágio no DAI.
================================================================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMAKE.ch"
#Include "Protheus.Ch"

/*
===============================================================================================================================
Programa----------: OM200MNU
Autor-------------: Wodson Reis
Data da Criacao---: 16/04/2010
===============================================================================================================================
Descrição---------: Ponto de Entrada para manipulacao das Opcoes do menu da rotina Montagem de Carga
===============================================================================================================================
Parametros--------: cTabAux := Código da Tabela no SX5
------------------: nTamAux := Tamanho da Chave para o Retorno
===============================================================================================================================
Retorno-----------: .T. - Compatibilidade com a utilização em F3
===============================================================================================================================
Usuario-----------: Alexandre Villar
===============================================================================================================================
*/

User Function OM200MNU()
//================================================================================
// Atribuicao dos novos valores do aRotina, para redefinicao do menu.
//================================================================================
aRotina := {{ OemtoAnsi( "Pesquisar" )                                 , 'PesqBrw'             , 0 , 1 , 0 , .F. },;
            { OemtoAnsi( "Montagem Carga" )                            , 'U_OM20MNUM'          , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Visualizar" )                                , 'U_OM20MNUV'          , 0 , 2 , 0 , NIL },;//foi Retirado esse botão pq não acerta o rateio do frete e pedagio
            { OemtoAnsi( "Liberacao" )                                 , 'Os200Liber'          , 0 , 0 , 0 , NIL },;//{"Ajuste Peso",'U_OM20MNUA',0,6,0,},;
            { OemtoAnsi( "Estorno Carga" )                             , 'U_OM20MNUE'          , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Efetiva Pre-Carga" )                         , 'U_OM20MNUP'          , 0 , 2 , 0 , NIL },;
            { OemtoAnsi( "Reenvio WF Carga")                           , 'U_OM200Email(.F.)'   , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Troca Lj Trasnp")                            , 'U_OM200TrLj(.F.)'    , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Integração Sistema Krona: Inclui / Altera")  , 'U_AOMS118()'         , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Pesquisa Status Viagem Carga Posicionada")   , 'U_AOMS118P()'        , 0 , 3 , 0 , NIL },; // { OemtoAnsi( "Localização Veiculo/Motorista")       , 'U_AOMS118L("V")'    , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Pesquisa Status Viagem por Digitação")       , 'U_AOMS118C()'        , 0 , 3 , 0 , NIL },; // { OemtoAnsi( "Mensagens da Integração Krona")       , 'U_AOMS118L("M")'    , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Entregas Sistema Krona")                     , 'U_AOMS118E()'        , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Cancelamento Viagens Integrada Krona")       , 'U_AOMS118A()'        , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Solicitação Liberação Viagens Krona")        , 'U_AOMS118B()'        , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Check List Carregamento")                    , 'U_ROMS070(.T.)'      , 0 , 3 , 0 , NIL },;
            { OemtoAnsi( "Legenda" )                                   , 'Os200Leg'	           , 0 , 3 , 0 , .F. } }

   AADD(aRotina,{ OemtoAnsi( "Alterar Numero de Carga TMS")                , 'U_AOMS140M()'        , 0 , 3 , 0 , NIL })
   AADD(aRotina,{ OemtoAnsi( "Reenvia Carga Posicionada para o TMS")       , 'U_AOMS152A(.F.,"P")' , 0 , 3 , 0 , NIL })
   AADD(aRotina,{ OemtoAnsi( "Reenvia Carga/Conjunto de Cargas para o TMS"), 'U_AOMS152A(.F.,"S")' , 0 , 3 , 0 , NIL })

   AADD(aRotina,{ OemtoAnsi( "Reenvia XMLs de Notas Fiscais para o TMS ")  , 'U_AOMS152E(.F.,.T.)' , 0 , 3 , 0 , NIL })
   AADD(aRotina,{ OemtoAnsi( "Reenvia Notas Fiscais para o TMS e Vincula a Pedidos"), 'U_AOMS152C(.F.,.T.)' , 0 , 3 , 0 , NIL })
   
   AADD(aRotina,{ OemtoAnsi( "Reenvia XMLs NFE p/ o TMS (Informando Carga/Cargas)") , 'U_AOMS152E(.F.,.F.)' , 0 , 3 , 0 , NIL })
   AADD(aRotina,{ OemtoAnsi( "Reenvia NFE p/ o TMS e Vincula a Pedidos  (Informando Carga/Cargas)"), 'U_AOMS152C(.F.,.F.)' , 0 , 3 , 0 , NIL })

   AADD(aRotina,{ OemtoAnsi( "Solicitação de Emissão de Notas Fiscais (Carga Posicionada) para o TMS")           , 'U_AOMS152H(.F.,"P")' , 0 , 3 , 0 , NIL })
   AADD(aRotina,{ OemtoAnsi( "Solicitação de Emissão de Notas Fiscais (Informando Carga/Cargas) para o TMS"), 'U_AOMS152H(.F.,"S")' , 0 , 3 , 0 , NIL })

   Aadd(aRotina,{OemtoAnsi("Solicitar Cancelamento da Carga no TMS")                ,"U_AOMS152W(.F.)", 0 , 3 , 0 , NIL })  
Return()

/*
===============================================================================================================================
Programa----------: OM20MNUA()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 15/10/2018
===============================================================================================================================
Descrição---------: Rotina de alteração dos pesos das cargas e dos pedidos de vendas vinculados a carga.
===============================================================================================================================
Parâmetros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function OM20MNUA()
Local _lOk := .F.
Local _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x RDC.
Local _cFilLogin   := AllTrim(SM0->M0_CODFIL)
Local _aStruct     := {}
Local _aCamposTrb  := {}
Local _nI
Local _oGetDB
Local _cTitulo
Local _oDlg
Local _aRotinaBackup := AClone(aRotina)
Local _nTamanho

Private aHeader := {}
Private _aPesoPed := {}

Private aRotina := { {"Pesquisar" ,"AxPesqui",0,1} ,;
                     {"Visualizar","AxVisual",0,2} ,;
                     {"Incluir"   ,"AxInclui",0,3} ,;
                     {"Alterar"   ,"AxAltera",0,4} ,;
                     {"Excluir"   ,"AxExclui",0,5} }

Begin Sequence
   U_ITLOGACS('OM20MNUA')
   // Valida se filial usa RDC, essa função só funciona sem o RDC
   If _cFilLogin $ _cFilHabilit
      U_ITMSG("Esta rotina não pode ser utilizada por filiais que possuem integração com o sistema RDC.","Atenção", ,1)
      Break
   EndIf

   // Valida se carga posicionada pode ter peso alterado. Verificar se já possui nota, caso afirmativo não permitir a emissão.
   DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
   DAI->(DbSeek(DAK->(DAK_FILIAL+DAK_COD)))
   Do While ! DAI->(Eof()) .And. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
      If ! Empty(DAI->DAI_NFISCA)
         U_ITMSG("Os pesos não poderão ser alterados, pois esta carga já possui nota fiscal emitida.","Atenção", ,1)
         Break
      EndIf

      DAI->(DbSkip())
   EndDo

   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
   SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
   //==========================================================================================================================//
   Aadd(_aCamposTrb, "DAI_FILIAL")
   Aadd(_aCamposTrb, "DAI_COD")
   Aadd(_aCamposTrb, "DAI_SEQCAR")
   Aadd(_aCamposTrb, "DAI_PEDIDO")
   Aadd(_aCamposTrb, "DAI_CLIENT")
   Aadd(_aCamposTrb, "DAI_LOJA")
   Aadd(_aCamposTrb, "C6_ITEM")
   Aadd(_aCamposTrb, "C6_PRODUTO")
   Aadd(_aCamposTrb, "B1_DESC")
   Aadd(_aCamposTrb, "C6_QTDVEN")
   Aadd(_aCamposTrb, "DAI_PESO")
   Aadd(_aCamposTrb, "B1_PESBRU")

   //==========================================================================
   // Monta aHeader e a estrutura da tabela temporária.
   //==========================================================================
   SX3->(DbSetOrder(2)) // X3_CAMPO
   DbSelectArea("SX3")

   For _nI := 1 To Len(_aCamposTrb)

       _nTamanho := getsx3cache(_aCamposTrb[_nI],"X3_TAMANHO")

       If AllTrim(_aCamposTrb[_nI]) == "B1_DESC"
          _nTamanho := 40
       EndIf

       Aadd(aHeader,{Trim(getsx3cache(_aCamposTrb[_nI],"X3_TITULO")),;
                            _aCamposTrb[_nI],;
                            getsx3cache(_aCamposTrb[_nI],"X3_PICTURE"),;
                            _nTamanho,;        // SX3->X3_TAMANHO
                            getsx3cache(_aCamposTrb[_nI],"X3_DECIMAL"),;
                            getsx3cache(_aCamposTrb[_nI],"X3_VALID"),;
                                         "",;
                               getsx3cache(_aCamposTrb[_nI],"X3_TIPO"),;
                                         "",;
                                         "" })
       Aadd(_aStruct, {_aCamposTrb[_nI],;
                       getsx3cache(_aCamposTrb[_nI],"X3_TIPO"),;
                       _nTamanho,; // SX3->X3_TAMANHO
                       getsx3cache(_aCamposTrb[_nI],"X3_DECIMAL")})
   Next

  //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBPESO") > 0
      TRBPESO->( DBCloseArea() )
   EndIf

   _otemp := FWTemporaryTable():New( "TRBPESO", _aStruct )

   _otemp:AddIndex( "TP", {"DAI_FILIAL","DAI_COD","DAI_SEQCAR","DAI_PEDIDO","C6_ITEM"} )

   _otemp:Create()

   //================================================================================
   // Carrega os dados na tabela temporária.
   //================================================================================
   If ! OM20MNUADADOS()
      U_ITMSG("Não foram encontrados nenhum produto do tipo queijo para alteração dos pesos.","Atenção", ,1)
      Break
   EndIf

   _cTitulo := "Alteração dos Pesos dos Itens de Pedidos da Carga"

   _bOk     := {|| _lOk := .T., _oDlg:End()}
   _bCancel := {|| _lOk := .F., _oDlg:End()}

   DEFINE MSDIALOG _oDlg TITLE _cTitulo FROM 00,00 TO 500,900 PIXEL // 600 // 500

      _oGetDB := MsGetDB():New(30, 05, 245, 450, 4,, "OM20MNUATOK",, .T., {"B1_PESBRU"}, 1, .F., , "TRBPESO", , , .T., _oDlg, .T.) // 05, 05, 145, 195

   ACTIVATE MSDIALOG _oDlg On Init (EnchoiceBar(_oDlg,_bOk,_bCancel)) CENTERED

   If _lOk
      U_ITLOGACS('OM20MNUAGRAVA')
      OM20MNUAGRAVA()
   EndIf

End Sequence

If _lOk
   U_ITMSG("Pesos da carga atualizados com sucesso!","Atenção", ,2)
Else
   U_ITMSG("Rotina de atualização dos pesos da carga cancelada.","Atenção", ,1)
EndIf

aRotina := AClone(_aRotinaBackup)

Return Nil


/*
===============================================================================================================================
Programa----------: OM20MNUEstorno()
Autor-------------: Alex Wallauer
Data da Criacao---: 01/08/2014
===============================================================================================================================
Descrição---------: Estorna Carga
===============================================================================================================================
Parâmetros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function OM20MNUEstorno(cAlias,nReg,nOpc,_lScheduller)//U_OM20MNUE
LOCAL _nI, C
PRIVATE _cCargas :=DAK->DAK_COD
PRIVATE _aPVs_DAI //:=U_OM200_Carrega()
PRIVATE _lUsuConfirmou:=.F.
PRIVATE _aFatPedCarga :={}//Quando esta estornando a carga gerada automatica na filial de faturamento
Private _lAutomatico := .F.

Begin Sequence

   If ! Empty(_lScheduller)
      _lAutomatico := _lScheduller
   EndIf

   // Valida se carga posicionada pode ser estornada. Verificar se já possui nota, caso afirmativo não permitir o estorno.
   DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
   DAI->(DbSeek(DAK->(DAK_FILIAL+DAK_COD)))
   Do While ! DAI->(Eof()) .And. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
      If ! Empty(DAI->DAI_NFISCA)
         If ! _lAutomatico
            U_ITMSG("A carga não pode ser estornada. Esta carga já possui nota fiscal emitida.","Atenção", ,1)
         Else
            U_ITCONOUT("A carga não pode ser estornada. Esta carga já possui nota fiscal emitida.")
         EndIf
         Break
      EndIf

      DAI->(DbSkip())
   EndDo

   U_OM20MNUF(cAlias,nReg,nOpc)

   IF _lUsuConfirmou
      DAI->( DBSetOrder(1) )
      If !DAI->( DBSeek( xFilial("DAI") + _cCargas ) )

         FOR C := 1 TO LEN(_aFatPedCarga)//volta a carga da Filial de Carregamento //Quando esta estornando a carga gerada automatica na filial de faturamento

             IF SC5->( DbSeek( _aFatPedCarga[C,2] ) ) //Posiciona no Pedido de Carregamento
                _aFatPedCarga[C,3]:=SC5->C5_I_CARGA   //Pega a Carga de Carregamento
             ELSE
                LOOP
             ENDIF
             SC5->( DBGOTO( _aFatPedCarga[C,1] ))//Posiciona no Pedido de Faturamento
             SC5->( RecLock('SC5',.F.) )
             SC5->C5_I_CARGA:=_aFatPedCarga[C,3]//Grava a Carga de Carregamento
             SC5->( MsUnlock() )

         NEXT

         IF LEN(_aFatPedCarga) = 0//Se for a carga de faturamento gerada automatica não envia e-mail solicitado pelo usuario
            If ! _lAutomatico
               U_OM200Email(.T.,_aPVs_DAI)
            Else
               U_OM200Email(.T.,_aPVs_DAI,.T.,.T.,.F.)
            EndIf
         ENDIF
      ENDIF

      For _nI := 1 To Len(_aPVs_DAI)
          If SC5->(DbSeek( xFilial("SC5")+_aPVs_DAI[_nI,1] ))
             U_ENVSITPV() //Envia situação do pedido de venda para o RDC

             //Limpa campos de pedido de pallet gerados
             Reclock("SC5",.F.)
             SC5->C5_I_PEDGE := " "
             SC5->C5_I_NPALE := " "
             SC5->(Msunlock())

          EndIf
      Next

   ENDIF

End Sequence

Return .T.

/*
===============================================================================================================================
Programa----------: OM20MNUVisualiza()
Autor-------------: Alex Wallauer
Data da Criacao---: 14/07/2016
===============================================================================================================================
Descrição---------: Visualiza Carga
===============================================================================================================================
*/
//*********************************************************//
USER Function OM20MNUVisualiza(cAlias,nReg,nOpc)//U_OM20MNUV
//*********************************************************//
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aButtons  := {}
Local aCpos	    := NIL//{"DAK_TRANSP","DAK_NOMTRA"}
Local aAcho     := NIL//{"DAK_COD",  "DAK_SEQCAR","DAK_ROTEIR","DAK_CAMINH","DAK_MOTORI","DAK_PESO",  "DAK_CAPVOL","DAK_PTOENT",;
                      //"DAK_VALOR","DAK_DATA",  "DAK_HORA",  "DAK_AJUDA1","DAK_AJUDA2","DAK_AJUDA3","DAK_FLGUNI","DAK_HRSTAR","DAK_TRANSP","DAK_NOMTRA"}
Local cSeek     := ""
Local cWhile    := ""
Local bCond     := {|| .T. } // Se bCond .T. executa bAction1, senao executa bAction2
Local bAction1  := {|| .T. } // Retornar .T. para considerar o registro e .F. para desconsiderar
Local bAction2  := {|| .F. } // Retornar .T. para considerar o registro e .F. para desconsiderar

Private cCadastro := "Visualizacao da Carga"
Private aTela[0][0],aGets[0]

AAdd( aButtons ,{ "PESQUISA" ,{ || GdSeek(oGetD,"Pesquisar") },"Pesquisar","Pesquisar" } ) //

//Cria variaveis M->????? da Enchoice
RegToMemory( "DAK", .F., .F. )

//Cria aHeader e aCols da GetDados
nUsado  := 0
aHeader := {}
aCols   := {}

DbSelectArea("DAI")
cSeek  := xFilial("DAI")+DAK->DAK_COD+DAK_SEQCAR
cWhile := "DAI_FILIAL+DAI_COD+DAI_SEQCAR"
FillGetDados(2,"DAI",1,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg1 TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
DbSelectArea("DAK")
EnChoice("DAK", nReg, nOpc, , , , aAcho,aPosObj[1], aCpos, 3, , , , , , .F.)

DbSelectArea("DAI")
oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Os200LOk","AllWaysTrue()", ,.T., Nil,,,Len(aCols))

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| oDlg1:End() },{|| oDlg1:End() },,aButtons)

RETURN .T.


/*
===============================================================================================================================
Programa----------: OM20MNUVisualiza()
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2016
===============================================================================================================================
Descrição---------: Efetiva Pre-Carga
===============================================================================================================================
*/
//*********************************************************//
USER Function OM20MNUPreCarga(cAlias,nReg,nOpc,_lScheduller)//U_OM20MNUPreCarga
//*********************************************************//
Local _cRet := ""
Private cCarga 	   := DAK->DAK_COD
Private _cMotorDAK := DAK->DAK_MOTORI
Private _cCaminDAK := DAK->DAK_CAMINH
Private _cArqTrb   := ""
Private _lAutomatico

If Empty(_lScheduller)
   _lAutomatico := .F.
Else
   _lAutomatico := _lScheduller
EndIf

IF DAK->DAK_I_PREC # "1"
   _cRet := 0
   If ! _lAutomatico
      u_itmsg("Não é Pre-Carga" ,"Atenção! (OM200MNU)", 'Opção disponivel só para Pre-Carga',1 )
   Else
      _cMsgEfetiva := " Não é précarga, opção disponível so para Pré Carga. "
   EndIf

   RETURN _cRet
ENDIF

If ! _lAutomatico
   Processa( {|| Os200CriaTrb() } ,, "Lendo Dados..." )
Else
   Os200CriaTrb()
EndIf

If ! _lAutomatico
   U_OM200Tela(.T.,.F.)
Else
   U_OM200Tela(.T.,.F.,.T.)
EndIf

If Select("TRBPED") > 0
   TRBPED->(Dbclosearea())
ENDIF

RETURN 0

/*
===============================================================================================================================
Programa----------: Os200CriaTrb()
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2016
===============================================================================================================================
Descrição---------: Função copiada do Padrão
===============================================================================================================================
*/
//*********************************************************//
Static Function Os200CriaTrb()
//*********************************************************//
Local cAlias    := ""
Local aRetPE    := {}
Local aCampos   := {}
Local cMarca    := GetMark()

If ! _lAutomatico
   ProcRegua(0)

   IncProc("Criando Arquivo de Trabalho...")
EndIf

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
AAdd( aCampos ,{"TRANSP"	  ,"C" ,6						,0}							)

aRetPE := ExecBlock("DL200TRB",.F.,.F.,aCampos)//Campos inseridos via parametro "IT_CMPCARG"
If ValType(aRetPE)=="A"
   aCampos := aRetPE
EndIf

If Select ("TRBPED") > 0

   dbselectarea("TRBPED")
   TRBPED->(Dbclosearea())

Endif

cAlias  := "TRBPED"

_otemp := FWTemporaryTable():New( cAlias, aCampos )

_otemp:AddIndex( "TP", {"PED_FILORI","PED_PEDIDO","PED_ITEM","PED_SEQLIB","PED_CODCLI","PED_LOJA"} )

_otemp:Create()

SC5->(DbSetOrder(1))
SC6->(DbSetOrder(1))
DAI->(DbSetOrder(1)) //--DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
DAI->(MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR))
DO While DAI->(!Eof()) .And. xFilial("DAI") == DAI->DAI_FILIAL .And.;
      DAK->DAK_COD    == DAI->DAI_COD .And.;
      DAK->DAK_SEQCAR == DAI->DAI_SEQCAR

   If ! _lAutomatico
      IncProc("Lendo Pedido: "+DAI->DAI_PEDIDO)
   EndIf

   SC5->( DbSeek( xFilial("SC5") + DAI->DAI_PEDIDO ) )
   _nTotValor:=0
   SC6->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
   DO While SC6->( !EOF() ) .AND. SC6->C6_FILIAL+SC6->C6_NUM == DAI->DAI_FILIAL+DAI->DAI_PEDIDO
      _nTotValor += SC6->C6_VALOR
      SC6->( DBSkip() )
   ENDDO

   TRBPED->(DBAPPEND())
   TRBPED->PED_MARCA  :=cMarca
   TRBPED->PED_GERA   :="S"
   TRBPED->PED_PEDIDO :=DAI->DAI_PEDIDO
   TRBPED->PED_I_OBPE :=SC5->C5_I_OBPED
   TRBPED->PED_I_AGEN :=SC5->C5_I_AGEND
   TRBPED->PED_CODCLI :=DAI->DAI_CLIENT
   TRBPED->PED_LOJA   :=DAI->DAI_LOJA
   TRBPED->PED_NOME   :=Alltrim( Posicione("SA1",1,xFilial("SA1")+DAI->DAI_CLIENT+DAI->DAI_LOJA,"A1_NREDUZ") )
   TRBPED->PED_PESO   :=DAI->DAI_PESO
   //--------------------------------------------//
   TRBPED->PED_I_REDP :=DAI->DAI_I_REDP  // c - 1
   TRBPED->PED_I_OPER :=DAI->DAI_I_OPER  // c - 1
   TRBPED->PED_I_OPLO :=DAI->DAI_I_OPLO  // C - 6
   TRBPED->PED_I_LOPL :=DAI->DAI_I_LOPL  // C - 4
   TRBPED->PED_I_TRED :=DAI->DAI_I_TRED  // c - 6
   TRBPED->PED_I_LTRE :=DAI->DAI_I_LTRE  // c - 4
   TRBPED->PED_I_TIPC :=DAI->DAI_I_TIPC  // C - 1
   TRBPED->PED_I_QTPA :=DAI->DAI_I_QTPA  // N - 6 - 0
   //--------------------------------------------//
   TRBPED->PED_VALOR  :=_nTotValor
   TRBPED->PED_RECDAI :=DAI->(RECNO())

   DAI->(DBSKIP())

ENDDO

Return

/*
===============================================================================================================================
Programa----------: OM200TrLj
Autor-------------: Josué Danich Prestes
Data da Criacao---: 14/06/2017
===============================================================================================================================
Descrição---------: Troca loja do transportador de carga já montada
===============================================================================================================================
*/
USER Function OM200TrLj()

Local _cloja := DAK->DAK_I_RELO
Local oDlg
Local _lcontinua  := .T.
Local _lexecuta := .T.

Begin Sequence

//Verifica se é pré carga
IF DAK->DAK_I_PREC == "1"

      u_itmsg("OM200MNU - Troca loja de transportador só disponível para carga efetivada!","Atenção",,1)
      _lcontinua := .F.
      Break

Endif


//Varre DAI e verifica se não está faturado e se todos são troca nota
Dbselectarea("DAI")
DAI->( Dbsetorder(1) )

If !(DAI->( DbSeek( DAK->DAK_FILIAL + DAK->DAK_COD) ))

   u_itmsg("OM200MNU - Itens da carga não localizados!","Atenção",,1)
   _lcontinua := .F.
   Break

Endif

DbSelectarea("SC5")
SC5->( Dbsetorder(1) )

Do while DAI->DAI_FILIAL == DAK->DAK_FILIAL .AND. DAI->DAI_COD == DAK->DAK_COD

    _ltem := .F.

    If SC5->( Dbseek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ))

      If !Empty(SC5->C5_NOTA)

          u_itmsg("OM200MNU - Carga já está faturada!","Atenção",,1)
          _lcontinua := .F.
          Break

       Endif


       If SC5->C5_I_TRCNF == "S"

          _ltem := .T.

       Endif

    Else

       u_itmsg("OM200MNU - Falha ao localizar pedido de vendas da carga!","Atenção",,1)
       _lcontinua := .F.
       Break

    Endif

    DAI->( Dbskip() )

Enddo

If !_ltem

      u_itmsg("OM200MNU - Carga não contém pedido que é troca nota!","Atenção",,1)
       _lcontinua := .F.
       Break

Endif

End Sequence

If _lcontinua

  //Define transportador
  DBSelectArea ("DA4")
  DA4->( DbSetOrder(1) )
  DA4->( DbSeek( xFilial("DA4") + DAK->DAK_MOTORI) )

  //Usa campo de loja opcional se estiver preenchido
  If !(Empty(DAK->DAK_I_LJTR))

     _cljtr := alltrim(DAK->DAK_I_LJTR)

  Else

     _cljtr := DA4->DA4_LOJA

  Endif


  DBSelectArea("SA2")
  SA2->( DBSetOrder(1) )
  SA2->( DBSeek( xFilial("SA2") + DA4->DA4_FORNEC ) )

  //Carrega nome do fornecedor e array com lojas possíveis
  _cnometr := ALLTRIM(SA2->A2_NREDUZ)
  _alojas := {}

  Do while DA4->DA4_FILIAL == SA2->A2_FILIAL .AND. DA4->DA4_FORNEC == SA2->A2_COD

   aadd(_alojas, SA2->A2_LOJA + " - " + alltrim(SA2->A2_NREDUZ) + " - " + alltrim(SA2->A2_MUN) + "-" + SA2->A2_EST )

   If  SA2->A2_LOJA ==  _cljtr

      _cloja := SA2->A2_LOJA + " - " + alltrim(SA2->A2_NREDUZ) + " - " + alltrim(SA2->A2_MUN) + "-" + SA2->A2_EST

   Endif

   SA2->(Dbskip())

  Enddo

  _lexecuta := .F.

  DEFINE MSDIALOG oDlg TITLE "Trocar loja do fornecedor: ";
             FROM 000,000 TO 140,600 OF oDlg PIXEL

   @ 004,004 TO 026,296 LABEL "Fornecedor :  " + DA4->DA4_FORNEC + "/" + DA4->DA4_LOJA  + " - " + _cnometr  + " :" OF oDlg PIXEL
   @ 015,008 COMBOBOX _cloja ITEMS _alojas SIZE 220,010 PIXEL OF oDlg


   @ 040,230 BUTTON "&Ok"					SIZE 030,014 PIXEL ACTION ( _lexecuta := .T. , oDlg:End() )
   @ 040,261 BUTTON "&Cancelar"			SIZE 030,014 PIXEL ACTION ( _lexecuta := .F. , oDlg:End() )

  ACTIVATE MSDIALOG oDlg CENTER

Endif

If _lexecuta .and. _lcontinua

   Reclock("DAK",.F.)
   DAK->DAK_I_LJTR := substr(alltrim(_cloja),1,4)
   DAK->(Msunlock())
   u_itmsg("OM200MNU - Loja gravada com sucesso!","Atenção",,1)

Else

   u_itmsg("OM200MNU - Operação cancelada!","Atenção",,1)

Endif

Return

/*
===============================================================================================================================
Programa----------: OM20MNUADADOS()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 15/10/2018
===============================================================================================================================
Descrição---------: Carrega os dados dos itens da carga que podem ter os pesos alterados e grava na tabela temporária TRBPESO.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function OM20MNUADADOS()
Local _aOrd := SaveOrd({"DAI","SB1","SC6"})
Local _nPesoTot
Local _lRet := .F.
Local _nI

Begin Sequence
   SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
   SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
   DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
   DAI->(DbSeek(DAK->(DAK_FILIAL+DAK_COD)))

   Do While ! DAI->(Eof()) .And. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
      SC6->(DbSeek(DAI->(DAI_FILIAL+DAI_PEDIDO)))
      Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == DAI->(DAI_FILIAL+DAI_PEDIDO)
         SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

         _nPesoTot := SB1->B1_PESBRU * SC6->C6_QTDVEN

         If SB1->B1_I_QQUEI == "S"
            TRBPESO->(RecLock("TRBPESO", .T.))
            TRBPESO->DAI_FILIAL := DAI->DAI_FILIAL
            TRBPESO->DAI_COD    := DAI->DAI_COD
            TRBPESO->DAI_SEQCAR := DAI->DAI_SEQCAR
            TRBPESO->DAI_PEDIDO := DAI->DAI_PEDIDO
            TRBPESO->DAI_CLIENT := DAI->DAI_CLIENT
            TRBPESO->DAI_LOJA   := DAI->DAI_LOJA
            TRBPESO->C6_ITEM    := SC6->C6_ITEM
            TRBPESO->C6_PRODUTO := SC6->C6_PRODUTO
            TRBPESO->B1_DESC    := SB1->B1_DESC
            TRBPESO->C6_QTDVEN  := SC6->C6_QTDVEN
            TRBPESO->DAI_PESO   := SB1->B1_PESBRU
            TRBPESO->B1_PESBRU  :=  _nPesoTot
            TRBPESO->(MsUnLock())

            _lRet := .T.
         Else
            //===================================================================================
            // _aPesoPed = Peso dos demais itens do pedido de vendas diferentes do tipo queijo.
            //===================================================================================
            _nI := Ascan(_aPesoPed, {|x| x[1] = DAI->DAI_FILIAL .And. x[2] = DAI->DAI_PEDIDO})
            If _nI == 0
               Aadd(_aPesoPed, {DAI->DAI_FILIAL, DAI->DAI_PEDIDO, _nPesoTot})
            Else
               _aPesoPed[_nI,3] += _nPesoTot
            EndIf
         EndIf

         SC6->(DbSkip())
      EndDo

      DAI->(DbSkip())
   EndDo

End Sequence

RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa----------: OM20MNUAGRAVA()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 15/10/2018
===============================================================================================================================
Descrição---------: Carrega os dados dos itens da carga que podem ter os pesos alterados e grava na tabela temporária TRBPESO.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function OM20MNUAGRAVA()

Local _nTotPesDAK, _nTotPes
Local _cCodPed, _cCodFil, _cCodCarga
Local _PesoPed
Local _nI	:= 0
Begin Sequence
   _nTotPesDAK := 0
   _nTotPes    := 0

   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
   DAI->(DbSetOrder(4)) // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR

   TRBPESO->(DbGoTop())

   _cCodPed   := TRBPESO->DAI_PEDIDO
   _cCodFil   := TRBPESO->DAI_FILIAL
   _cCodCarga := TRBPESO->DAI_COD

   Begin Transaction

      Do While ! TRBPESO->(Eof())
         If _cCodFil + _cCodPed   <> TRBPESO->DAI_FILIAL + TRBPESO->DAI_PEDIDO
            //===================================================================================
            // _aPesoPed = Peso dos demais itens do pedido de vendas diferentes do tipo queijo.
            //===================================================================================
            _nI := Ascan(_aPesoPed, {|x| x[1] = _cCodFil .And. x[2] = _cCodPed})
            If _nI > 0
               _PesoPed := _aPesoPed[_nI,3]
            Else
               _PesoPed := 0
            EndIf

            SC5->(DbSeek(_cCodFil + _cCodPed))
            SC5->(RecLock("SC5", .F. ))
            SC5->C5_PBRUTO :=  (_nTotPes + _PesoPed)
            SC5->C5_I_PESBR := (_nTotPes + _PesoPed)
            SC5->(MsUnLock())

            DAI->(DbSeek(_cCodFil + _cCodPed + _cCodCarga))
            DAI->(RecLock("DAI", .F. ))
            DAI->DAI_Peso :=  (_nTotPes + _PesoPed)
            DAI->(MsUnLock())

            _cCodPed   := TRBPESO->DAI_PEDIDO
            _cCodFil   := TRBPESO->DAI_FILIAL
            _nTotPes   := 0
         EndIf

         _nTotPesDAK += TRBPESO->B1_PESBRU
         _nTotPes    += TRBPESO->B1_PESBRU

         TRBPESO->(DbSkip())
      EndDo

      //===================================================================================
      // _aPesoPed = Peso dos demais itens do pedido de vendas diferentes do tipo queijo.
      //===================================================================================
      _nI := Ascan(_aPesoPed, {|x| x[1] = _cCodFil .And. x[2] = _cCodPed})
      If _nI > 0
         _PesoPed := _aPesoPed[_nI,3]
      Else
         _PesoPed := 0
      EndIf

      SC5->(DbSeek(_cCodFil + _cCodPed))
      SC5->(RecLock("SC5", .F. ))
      SC5->C5_PBRUTO := (_nTotPes + _PesoPed)
      SC5->C5_I_PESBR := (_nTotPes + _PesoPed)
      SC5->(MsUnLock())

      DAI->(DbSeek(_cCodFil + _cCodPed + _cCodCarga))
      DAI->(RecLock("DAI", .F. ))
      DAI->DAI_Peso := (_nTotPes + _PesoPed)
      DAI->(MsUnLock())

      _PesoPed := 0
      For _nI := 1 To Len(_aPesoPed)
          _PesoPed += _aPesoPed[_nI,3]
      Next

      DAK->(RecLock("DAK", .F. ))
      DAK->DAK_PESO := (_nTotPesDAK + _PesoPed)
      DAK->(MsUnLock())

   End Transaction

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: OM20MNUATOK()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 15/10/2018
===============================================================================================================================
Descrição---------: Valida a digitação do campo peso de todas as linhas do MSGETDB.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function OM20MNUATOK()
Local _lRet := .T.
Local _nRegAtu := TRBPESO->(Recno())

Begin Sequence
   TRBPESO->(DbGoTop())
   Do While ! TRBPESO->(Eof())
      If TRBPESO->B1_PESBRU <= 0
         U_ITMSG("Os pesos dos itens da carga devem ser maior que zero.","Atenção", ,1)
         _lRet := .F.
         Break
      EndIf

      TRBPESO->(DbSkip())
   EndDo

End Sequence

TRBPESO->(DbGoTo(_nRegAtu))

Return _lRet

/*
===============================================================================================================================
Programa----------: OM20MNUM()
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/12/2018
===============================================================================================================================
Descrição---------: Chama rotina de montagem de carga após validar numerador de DAK_COD
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function OM20MNUM()

//Garante que o DAK_COD está atualizado entre numerador e base de dados
_cdak := U_AOMS089(.F.,"DAK","DAK_COD",.T.)
RollbackSx8() //Faz rollback pois o padrão já vai fazer um getsxenum

If Select("TRBPED") > 0 //Para não dar erro: Alias already in use: TRBPED
     TRBPED->(Dbclosearea())
ENDIF

//Chama rotina padrão de montagem de carga
OsA200Mont()

Return

/*
===============================================================================================================================
Programa----------: OM20MNUF
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/05/2019
===============================================================================================================================
Descrição---------: Chama a função padrão de estorno de carga.
===============================================================================================================================
Parâmetros--------: cAlias = Alias da tabela.
                    nReg   = Recno posicionado da tabela.
                    nOpc   = Operação = 3=Inclusão/4=Alteração/5=Exclusão
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function OM20MNUF(cAlias,nReg,nOpc)
Local _lRet

Private M->DAK_VIAROT:=DAK->DAK_VIAROT//Private usada na função padrão Os200Estor()

Begin Sequence
   _aPVs_DAI := U_OM200_Carrega()

   Begin Transaction
      Os200Estor(cAlias,nReg,nOpc)//Função Padrão

      If !_lUsuConfirmou
         DisarmTransaction()
         _cMsgEstorno := " Falha ao realizar o estorno. "
      EndIf

   End Transaction

End Sequence

Return _lRet
