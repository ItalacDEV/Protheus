/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor   |    Data    |                                             Motivo
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz     | 30/04/2021 | Chamado 36404. Alterar rotina de envio pedidos para enviar 3 para unid.med. quilos e qtde pe�as.
 Julio Paz     | 15/07/2021 | Chamado 37169. Aumentar o Timeout de envio para o sistema RDC de 30 para 90 segundos.
 Alex Wallauer | 16/09/2021 | Chamado 37753. Alterado para ignorar tambem os armazens: '50' e '52' no envio do PV p/ o RDC .
 Julio Paz     | 09/09/2022 | Chamado 41046. Alterar fun��o utilizada para chamada via Scheduller para n�o consumir li�en�as.
 Alex Wallauer | 12/09/2023 | Chamado 45005. Envio de PV liberado estoque da filial que estiver habilitada para Libera��o.
 Julio Paz     | 06/10/2023 | Chamado 45229. Desenvolvimento do novo webservice OMS-Protheus x TMS-Multiembarcador.
 Alex Wallauer | 27/02/2024 | Chamado 46408. Jerry. Alteracao do tratamento das variaveis de usuarios publicas.
 Julio Paz     | 12/07/2024 | Chamado 47835. Jerry. Incluir a filial 31 na grava��o dos dados de envio para o sistema RDC.
 Igor Melga�o  | 20/08/2024 | Chamado 47835. Vanderlei. Incluir valida��o de reserva de estoque por parametro.
 ===========================================================================================================================================================================================================================================================
 Analista       - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o
============================================================================================================================================================================================================================================================
Vanderlei/Jerry - Julio Paz    - 06/10/23 - 03/01/25 - 45229   - Desenvolvimento do novo webservice OMS-Protheus x TMS-Multiembarcador.
Vanderlei Alves - Julio Paz    - 14/03/25 - 24/03/25 - 50188   - Desenvolvimento de Rotina de Integra��o Webservice Protheus x TMS Multiembarcador Para Replicar Cargas Criadas no Protheus para o TMS Multiembarcador [OMS]
Vanderlei Alves - Alex Wallauer- 19/03/25 - 24/03/25 - 50197   - Novo tratamento para cortes e desmembramentos de pedidos - IGNORAR: M->C5_I_BLSLD = "S"
Vanderlei Alves - Julio Paz    - 14/03/25 - 10/06/25 - 50188   - Incluir um filtro no envio de dados para o Sistema RDC, para n�o serem enviados pedidos de vendas gerados para a rotina de integra��o Troca Nota. Campo ZFQ_TPOPER Vazio.
Vanderlei Alves - Igor Melga�o - 06/06/25 - 10/06/25 - 45229   - Ajuste do par�metro p/determinar se a integra��o WebS.ser� TMS Multiembarcador ou RDC
Vanderlei Alves - Alex Wallauer- 09/06/25 - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP")
Vanderlei Alves - Alex Wallauer- 09/06/25 - 12/06/25 - 45229   - Corre��es na grava��o do campo filial de integra��o com o RDC, campo: ZFQ_FILRDC
===========================================================================================================================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "APWEBSRV.CH"
#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"

/*
===============================================================================================================================
Programa----------: AOMS084
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Rotina de integra��o e envio de dados dos Pedidos de Vendas via webservice para o sistema RDC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084()
Local _aCores  := {}
Local _afilial := {}  // {'01','20','23','40','90'}
Local _ni      := 1
Local _cFilProc := ""

Private aRotina := {}
Private cCadastro
Private _lScheduler:= ( Select("SM0") <= 0 ) // ( Select("SX3") <= 0 )

If _lScheduler
    //=============================================================================
    // Ativa a filial "01" apenas para leitura das filiais do par�metro.
    //=============================================================================
    u_itconout( '[AOMS084] - TOTAL DO PROCESSO INICIALIZADO '  )

    RpcClearEnv()
    RpcSetType(2)

    //===========================================================================================
    // Preparando o ambiente com a filial da carga recebida
    //===========================================================================================
    //PREPARE ENVIRONMENT EMPRESA '01' FILIAL "01" ; //USER 'Administrador' PASSWORD '' ;
    //           TABLES 'SC5','SC6',"ZFQ","ZFR","SA2","SA1",'ZP1' MODULO 'OMS'
    RpcSetEnv("01", "01",,,,, {'SC5','SC6',"ZFQ","ZFR","SA2","SA1",'ZP1'})

    Sleep( 5000 ) //Aguarda 5 segundos para subam as configura��es do ambiente.

    _cfilial := "01"

    _afilial := U_ITGETMV( 'IT_FILINTWS' , "'01';'20';'23';'40';'90';'93'") // Filiais habilitadas na integracao Webservice Italac x RDC.
    _afilial := U_ITTXTARRAY(_afilial ,";",99)
    _cfilial := _aFilial[1]

    //=============================================================================
    // Inicia processamento com base nas filiais do par�metro.
    //=============================================================================

    //===========================================================================================
    // Preparando o ambiente com a filial lida do par�metro
    //===========================================================================================
    RpcClearEnv()
    RpcSetType(2)

    //PREPARE ENVIRONMENT EMPRESA '01' FILIAL _cfilial ; //USER 'Administrador' PASSWORD '' ;
    //           TABLES 'SC5','SC6',"ZFQ","ZFR","SA2","SA1",'ZP1' MODULO 'OMS'
    RpcSetEnv("01", _cfilial,,,,, {'SC5','SC6',"ZFQ","ZFR","SA2","SA1",'ZP1'})

    Sleep( 5000 ) //Aguarda 5 segundos para subam as configura��es do ambiente.

    cFilAnt := _cfilial

   //cUSUARIO := SPACE(06)+"Administrador  "
   //cUsername:= "Schedule"
   //__CUSERID:= "SCHEDULE"

   Do while _ni < len(_afilial)

      u_itconout( '[AOMS084] - Iniciando schedule de pedidos para filial ' + cfilant )

      U_AOMS084I()

      u_itconout( '[AOMS084] -  Finalizado schedule de pedidos para filial ' + cfilant )

        _cFilProc := _cFilial

      _ni++

      _cfilial := _afilial[_ni]

      u_itconout( '[AOMS084] -  Abrindo o ambiente para filial '+ _cfilial + '...' )

      cfilant := _afilial[_ni]
      SM0->(Dbseek('01'+cfilant))

   Enddo

   //Executa �ltimo item
   If ! Empty(_cfilial)
      u_itconout( '[AOMS084] -  Iniciando schedule de pedidos para filial ' + cfilant )

      U_AOMS084I()
   EndIf

   If Empty(cfilant)
       cfilant:= _cFilProc
    EndIf

   u_itconout( '[AOMS084] -  Finalizado schedule de pedidos para filial ' + cfilant )

   u_itconout( '[AOMS084] - TOTAL DO PROCESSO FINALIZADO ' + cfilant )

ELSE

   //Grava Log de execu��o da rotina
   U_ITLOGACS()

   cCadastro := "Integra��o dos Dados dos Pedidos de Vendas Via Webservice: Italac <---> RDC"
   Aadd(aRotina,{"Pesquisar"                      ,"AxPesqui"   ,0,1})
   Aadd(aRotina,{"Visualizar"                     ,"U_AOMS084V" ,0,2})
   Aadd(aRotina,{"Integracao Webservice"          ,"U_AOMS084I" ,0,4})
   Aadd(aRotina,{"Legenda"                        ,"U_AOMS084L" ,0,6})
   Aadd(aRotina,{"Reprocessa pedidos"             ,"U_AOMS084Y" ,0,3})
   Aadd(aRotina,{"Reproc.Pedidos por Nota Fiscal" ,"U_AOMS084Z" ,0,3})

   Aadd(_aCores,{"ZFQ_SITUAC == 'N'" ,"BR_VERDE" })
   Aadd(_aCores,{"ZFQ_SITUAC == 'P'" ,"BR_VERMELHO" })
   Aadd(_aCores,{"ZFQ_SITUAC == 'R'" ,"BR_AMARELO" })
   Aadd(_aCores,{"ZFQ_SITUAC == 'A'" ,"BR_LARANJA" })
   Aadd(_aCores,{"ZFQ_SITUAC == 'L'" ,"BR_CINZA" })

   DbSelectArea("ZFQ")
   ZFQ->(DbSetOrder(1))
   ZFQ->(DbGoTop())
   MBrowse(6,1,22,75,"ZFQ", , , , , , _aCores)

ENDIF

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS084L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Rotina de Exibi��o da Legenda do MBrowse.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084L()
Local _aLegenda := {}

Begin Sequence
   Aadd(_aLegenda,{"BR_LARANJA"  ,"Aguardando Aprova��o" })
   Aadd(_aLegenda,{"BR_VERDE"    ,"N�o Processado" })
   Aadd(_aLegenda,{"BR_AMARELO"  ,"Rejeitada" })
   Aadd(_aLegenda,{"BR_VERMELHO" ,"Processado" })
   Aadd(_aLegenda,{"BR_CINZA"    ,"Liberado Manualmente" })

   BrwLegenda(cCadastro, "Legenda", _aLegenda)

End Sequence

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS084I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Rotina de integra��o e envio de dados dos Pedidos de Vendas via webservice para empresa RDC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084I()
Local _lRet := .F.
Local _aStrucZFQ
Local _aOrd := SaveOrd({"SX3","ZFQ"})
Local _aCmpZFQ := {}
Local _aButtons := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _lInverte := .F.
Local _oDlgInt, _nI

Private _oMarkZFQ, _cMarcaZFQ := GetMark()
Private aHeader := {} , aCols := {}

Begin Sequence
   //============================================================================
   //Montagem do aheader
   //=============================================================================
   aHeader := {}
   FillGetDados(1,"ZFQ",1,,,{||.T.},,,,,,.T.)

   //                          1                    2               3              4               5                6             7        8              9                 10
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})

   //================================================================================
   // Monta as colunas do MSSELECT para a tabela tempor�ria TRBZFQ
   //================================================================================
   Aadd( _aCmpZFQ , { "WK_OK"		,    , "Marca"                                          ,"@!"})

   For _nI := 1 To Len(aHeader)
       If AllTrim(aHeader[_nI,2])=="ZFQ_FILIAL" .OR. AllTrim(aHeader[_nI,2])=="ZFQ_DSCSIT"
          Loop
       EndIf
       Aadd( _aCmpZFQ , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
   Next

   //================================================================================
   // Cria as estruturas das tabelas tempor�rias
   //================================================================================
   _aStrucZFQ := {}
   Aadd(_aStrucZFQ,{"WK_OK"  , "C", 2 ,0})
   Aadd(_aStrucZFQ,{"WKRECNO", "N", 10,0})
   For _nI := 1 To Len(aHeader)
       Aadd(_aStrucZFQ,{aHeader[_nI,2], aHeader[_nI,8], aHeader[_nI,4] ,aHeader[_nI,5]})
   Next

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZFQ") > 0
      TRBZFQ->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZFQ criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZFQ",  _aStrucZFQ )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZFQ_DATA"} )
   _otemp:AddIndex( "02", {"ZFQ_PEDIDO","ZFQ_DATA"} )
   _otemp:Create()

   //================================================================================
   // Cria os indices da tabela tempor�ria.
   //================================================================================
   DBSelectArea("TRBZFQ")

   //================================================================================
   // Tratamento para Schedule
   //================================================================================
   IF _lScheduler

       u_itconout( '[AOMS084] -  - Atualizando pedidos retornados...' )

       _nTot := 0

       //===============================================================================================================
       //Atualiza pedidos retornados de data anterior para pedidos a serem enviados para o RDC
       //===============================================================================================================
       U_AOMS084K()
       //===============================================================================================================

       u_itconout( '[AOMS084] -  - Gravado no muro '+ ALLTRIM(Str( _nTot , 6 )) +' registros...' )

       u_itconout( '[AOMS084] -  - Lendo registros a serem integrados...' )
       _nTot := 0

       //===============================================================================================================
       //Lendo dados a serem integrados e monta TRBZFQ
       //===============================================================================================================
       U_AOMS084D()
       //===============================================================================================================

       If _nTot = 0

          u_itconout( '[AOMS084] -  - N�o foram encontrados pedidos para processar.' )

       ELSE

          u_itconout( '[AOMS084] -  - Enviando pedido para rdc '+ ALLTRIM(Str( _nTot , 6 )) +' registros...' )

          //===============================================================================================================
          //Envia Xml para rdc ou para o TMS
          //===============================================================================================================
          //_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC.
          //
          //Roda primeiro o TMS pra depois rodar o RDC
          U_AOMS084Q()
          U_AOMS084W()
          
          //If ! _lWsTms // Sistema RDC
          //   U_AOMS084W()
          //Else // Sistema TMS
          //   U_AOMS084Q()
          //EndIf
         
       ENDIF

       BREAK

   ENDIF

   //================================================================================
   // Carrega os dados da tabela ZFQ
   //================================================================================

   fwmsgrun(,{|oproc|  U_AOMS084D(oproc)},'Aguarde processamento...','Lendo dados a serem integrados...')

   TRBZFQ->(DbGoTop())

   If TRBZFQ->(Eof())

     u_itmsg("N�o foram localizados registros para integrar","Aten��o",,1)
     break

   Endif

   _bOk := {|| _lRet := .T., _oDlgInt:End()}
   _bCancel := {|| _lRet := .F., _oDlgInt:End()}

   AADD(_aButtons,{"",{|| U_AOMS084M("T") }              ,"Marc/Des" ,"Marca/Desmarca Todos"})
   AADD(_aButtons,{"",{|| U_AOMS084T(TRBZFQ->(Recno())) },"Pesquisar","Pesquisar"           })

  _cTitulo := "Integra��o de Pedidos de Vendas Via WebService"
   //================================================================================
   // Monta a tela de dados com MSSELECT.
   //================================================================================
   Define MsDialog _oDlgInt Title _cTitulo From 0,0 To 200,80 Of oMainWnd

      _oMarkZFQ := MsSelect():New("TRBZFQ","WK_OK","",_aCmpZFQ,@_lInverte, @_cMarcaZFQ,{_aSizeAut[7]+20, 5, _aSizeAut[4], _aSizeAut[3]})

      _oMarkZFQ:bAval := {|| U_AOMS084M("P")}
      _oDlgInt:lMaximized:=.T.

   Activate MsDialog _oDlgInt On Init (EnchoiceBar(_oDlgInt,_bOk,_bCancel,,_aButtons), _oMarkZFQ:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT , _oMarkZFQ:oBrowse:Refresh() )

   If _lRet

      fwmsgrun(, {|oproc| U_AOMS084Q(oproc) } , 'Aguarde!' , 'Integrando Dados do Pedido de Vendas...' )
      fwmsgrun(, {|oproc| U_AOMS084W(oproc) } , 'Aguarde!' , 'Integrando Dados do Pedido de Vendas...' )

      //_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC.
      //If ! _lWsTms // Sistema RDC
      //   fwmsgrun(, {|oproc| U_AOMS084W(oproc) } , 'Aguarde!' , 'Integrando Dados do Pedido de Vendas...' )
      //Else // Sistema TMS
      //   fwmsgrun(, {|oproc| U_AOMS084Q(oproc) } , 'Aguarde!' , 'Integrando Dados do Pedido de Vendas...' )
      //EndIf

   EndIf

End Sequence

//================================================================================
// Fecha e exclui as tabelas tempor�rias
//================================================================================
If Select("TRBZFQ") > 0
   TRBZFQ->(DbCloseArea())
EndIf

RestOrd(_aOrd)

Return Nil

/*
===============================================================================================================================
Fun��o----------: AOMS084M
Autor-----------: Julio de Paula Paz
Data da Criacao-: 25/10/2016
===============================================================================================================================
Descri��o-------: Fun��o para marcar e desmarcar todos Pedidos de Vendas que ser�o integrados via Webservice.
===============================================================================================================================
Parametros------: _cTipoMarca = "T" = Marca e desmarca todos os registros.
                  _cTipoMarca = "P" = Marca e desmarca apena o registro posisionado.
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS084M(_cTipoMarca)
Local _cSimboloMarca := Space(2)
Local _nRegAtu := TRBZFQ->(Recno())

Begin Sequence
   If Empty(TRBZFQ->WK_OK )
      _cSimboloMarca := _cMarcaZFQ
   Else
      _cSimboloMarca := Space(2)
   EndIf

   If _cTipoMarca == "P"
      TRBZFQ->(RecLock("TRBZFQ",.F.))
      TRBZFQ->WK_OK := _cSimboloMarca
      TRBZFQ->(MsUnlock())
   Else
      TRBZFQ->(DbGoTop())
      Do While ! TRBZFQ->(Eof())
         TRBZFQ->(RecLock("TRBZFQ",.F.))
         TRBZFQ->WK_OK := _cSimboloMarca
         TRBZFQ->(MsUnlock())

         TRBZFQ->(DbSkip())
      EndDo

   EndIf

End Sequence

TRBZFQ->(DbGoTo(_nRegAtu))
_oMarkZFQ:oBrowse:Refresh()

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS084W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Gera os dados XML com base nos Pedidos de Vendas selecionados e integra via webservice
                    para o sistema RDC.
===============================================================================================================================
Parametros--------: oproc - objeto da barra de progresso
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084W(oproc)
Local _cDirXML := ""
Local _cLink   := ""
Local _cCabXML := ""
Local _cItemXML := ""
Local _cDetA_XML := ""
Local _cDetB_XML := ""
Local _cRodXML := ""
Local _cDadosItens
Local _lItemSelect := .F.
Local _cEmpWebService := ""
Local _aOrd := SaveOrd({"ZFQ","ZFM","ZFR","SC9","SC5"})
Local _lReserva := U_ITGetMV( 'IT_GESTPVRE',.F. )

Local _cXML

Local _cResult := ""
Local _aRecnoItem, _nI
Local _lEnvXml
Local _cResposta, _cSituacao, _cReserva
Local lAchouSC5 := .F.

Default oproc := nil

Begin Sequence
   //================================================================================
   // Verifica se h� itens selecionados e l� o c�digo da empresa de WebService.
   //================================================================================
IF !_lScheduler

   IF valtype(oproc) = "O"

      oproc:cCaption := ("1/10 - Verificando itens selecionados...")
      ProcessMessages()

   ENDIF

   TRBZFQ->(DbGoTop())
   Do While ! TRBZFQ->(Eof())
      If ! Empty(TRBZFQ->WK_OK)
         _cEmpWebService := TRBZFQ->ZFQ_CODEMP
         _lItemSelect := .T.
         Exit
      EndIf

      TRBZFQ->(DbSkip())
   EndDo

   If ! _lItemSelect
      u_itmsg("Nenhum item foi selecionado para integra��o Webservice. N�o ser� poss�vel realizar a integra��o Italac <---> RDC.","Aten��o",,1)
      Break
   EndIf

ELSE

   TRBZFQ->(DbGoTop())//Todos est�o marcados
   _cEmpWebService := TRBZFQ->ZFQ_CODEMP

ENDIF

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   IF !_lScheduler

         IF valtype(oproc) = "O"

            oproc:cCaption := ("2/10 - Identificando diret�rio dos XML...")
            ProcessMessages()

         ENDIF

   ENDIF
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirXML := ZFM->ZFM_LOCXML
      _cLink   := AllTrim(ZFM->ZFM_LINK01)
   Else
      IF _lScheduler
         u_itconout( "[AOMS084] - Empresa WebService para envio dos dados n�o localizada.")
      ELSE
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      ENDIF
      Break


   EndIf

If Empty(_cDirXML) .Or. Empty(_cLink)
      IF _lScheduler
         u_itconout("[AOMS084] - Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
      ELSE
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      ENDIF
      Break
EndIf

_cDirXML := Alltrim(_cDirXML)
If Right(_cDirXML,1) <> "\"
      _cDirXML := _cDirXML + "\"
EndIf

//================================================================================
// L� os arquivos modelo XML e os transforma em String.
//================================================================================
IF !_lScheduler

         IF valtype(oproc) = "O"

            oproc:cCaption := ("3/10 - Lendo arquivo XML Modelo de Cabe�alho...")
            ProcessMessages()

         ENDIF

ENDIF
_cCabXML := U_AOMS084X(_cDirXML+"Cab_EnviaPedido.txt")
If Empty(_cCabXML)
      IF _lScheduler
         u_itconout("[AOMS084] - Erro na leitura do arquivo XML modelo do cabe�alhode envio Pedido de Vendas.")
      ELSE
         u_itmsg("Erro na leitura do arquivo XML modelo do cabe�alho de envio Pedido de Vendas. ","Aten��o",,1)
      ENDIF
      Break
EndIf

IF !_lScheduler

         IF valtype(oproc) = "O"

            oproc:cCaption := ("4/10 - Lendo arquivo XML Modelo de Detalhe A...")
            ProcessMessages()

         ENDIF

ENDIF

_cDetA_XML := U_AOMS084X(_cDirXML+"DET_A_EnviaPedido.txt")

If Empty(_cDetA_XML)
   IF _lScheduler
      u_itconout("[AOMS084] - Erro na leitura do arquivo XML modelo do detalhe A de envio Pedido de Vendas.")
   ELSE
      u_itmsg("Erro na leitura do arquivo XML modelo do detalhe A de envio Pedido de Vendas.","Aten��o",,1)
   ENDIF
      Break
EndIf

IF !_lScheduler

         IF valtype(oproc) = "O"

            oproc:cCaption := ("5/10 - Lendo arquivo XML Modelo de Detalhe B...")
            ProcessMessages()

         ENDIF

EndIf

_cDetB_XML := U_AOMS084X(_cDirXML+"DET_B_EnviaPedido.txt")

If Empty(_cDetB_XML)
      IF _lScheduler
         u_itconout("[AOMS084] - Erro na leitura do arquivo XML modelo do detalhe B de envio Pedido de Vendas..")
      ELSE
         u_itmsg("Erro na leitura do arquivo XML modelo do detalhe B de envio Pedido de Vendas.","Aten��o",,1)
      ENDIF
      Break

EndIf

IF !_lScheduler

         IF valtype(oproc) = "O"

            oproc:cCaption := ("6/10 - Lendo arquivo XML Modelo de Item de Pedido...")
            ProcessMessages()

         ENDIF

EndIf

_cItemXML := U_AOMS084X(_cDirXML+"Item_EnviaPedido.txt")

If Empty(_cItemXML)
      IF _lScheduler
         u_itconout("[AOMS084] - Erro na leitura do arquivo XML modelo dos itens de envio Pedido de Vendas.")
      ELSE
         u_itmsg("Erro na leitura do arquivo XML modelo dos itens de envio Pedido de Vendas.","Aten��o",,1)
      ENDIF
      Break

EndIf

IF !_lScheduler

         IF valtype(oproc) = "O"

            oproc:cCaption := ("7/10 - Lendo arquivo XML Modelo de Rodap�...")
            ProcessMessages()

         ENDIF

EndIf

_cRodXML := U_AOMS084X(_cDirXML+"Rodape_EnviaPedido.txt")
If Empty(_cRodXML)
      IF _lScheduler
         u_itconout("[AOMS084] - Erro na leitura do arquivo XML modelo do rodap� de envio Pedido de Vendas.")
      ELSE
         u_itmsg("Erro na leitura do arquivo XML modelo do rodap� de envio Pedido de Vendas.","Aten��o",,1)
      ENDIF
      Break
EndIf

//--------------------------------------------------------------------------------------------------
// Verifica se o pedido j� tem libera��o, n�o permite a integra��o via Webservice e muda a situa��o
// do registro na tabela de muro para "Liberado Manualmente".
//--------------------------------------------------------------------------------------------------
SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
ZFR->(DbSetOrder(5))
SC5->(DbSetOrder(1))

//=====================================================================================
// Verifica se existe algum item para envio de XML que n�o foi liberado manualmente.
//=====================================================================================
_lEnvXml := .F.

TRBZFQ->(DbGoTop())
Do While ! TRBZFQ->(Eof())
      If ! Empty(TRBZFQ->WK_OK) //.AND. TRBZFQ->ZFQ_PEDIDO == '500324'//RETIRAR
         _lEnvXml := .T.
         Exit
      EndIf

      TRBZFQ->(DbSkip())
EndDo
If ! _lEnvXml  // N�o h� dados para envio do XML.
      Break
EndIf

//================================================================================
// Concatena os Pedidos de Vendas selecionados e monta array de XML com os dados.
//================================================================================
IF !_lScheduler
   IF valtype(oproc) = "O"
      oproc:cCaption := ("8/10 - Montando dados de envio...")
      ProcessMessages()
   ENDIF
ENDIF

oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.

oWsdl:nTimeout := 90          // Timeout de 90 segundos
oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo

oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.
oWsdl:SetOperation( "EnviaPedido") // Define qual opera��o ser� realizada.

_aresult := {}

ZFR->(DbSetOrder(5))
SC9->(DbSetOrder(1))

IF valtype(oproc) = "O"

   oproc:cCaption := ("9/10 - Enviando dados para RDC...")
   ProcessMessages()

ENDIF


TRBZFQ->(DbGoTop())
Do While ! TRBZFQ->(Eof())

      If ! Empty(TRBZFQ->WK_OK) 
         ZFQ->(DbGoto(TRBZFQ->WKRECNO))
         If (SC5->(DbSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO))) 
            lAchouSC5 := .T. 
            If U_IT_TMS(SC5->C5_I_LOCEM)
               TRBZFQ->(DbSkip())
               LOOP
            EndIf
         ELse
            lAchouSC5 := .F. 
         EndIf

         Begin Transaction


            u_itconout( '[AOMS084] -  - Enviando pedido ' + ZFQ->ZFQ_PEDIDO + ' para rdc ...' )

            IF valtype(oproc) = "O"

               oproc:cCaption := ("10/10 - Enviando dados para RDC - Pedido " + ZFQ->ZFQ_PEDIDO + "..." )
               ProcessMessages()

            ENDIF


            If !lAchouSC5  //Se n�o achar o pedido de vendas marca como enviado e n�o transmite

               ZFQ->(RecLock("ZFQ",.F.))
               ZFQ->ZFQ_SITUAC  := "P"
               ZFQ->ZFQ_DATAAL  := Date()
               ZFQ->ZFQ_RETORN  := "Eliminado por exclus�o do pedido no SC5"
               ZFQ->ZFQ_DATAP := DATE()
               ZFQ->ZFQ_HORAP := TIME()
               ZFQ->(MsUnlock())
               u_itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' eliminado da muro por exclus�o ...' )

            Elseif !Empty(SC5->C5_NOTA) //Se pedido j� tem nota n�o envia mais para RDC

               ZFQ->(RecLock("ZFQ",.F.))
               ZFQ->ZFQ_SITUAC  := "P"
               ZFQ->ZFQ_DATAAL  := Date()
               ZFQ->ZFQ_RETORN  := "Eliminado por SC5 j� possuir nota emitida"
               ZFQ->ZFQ_DATAP := DATE()
               ZFQ->ZFQ_HORAP := TIME()
               ZFQ->(MsUnlock())
               u_itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' eliminado da muro por ter nota emitida ...' )

            Else

               //Verifica se consegue lockar o SC5
               If !(SC5->(Msrlock(SC5->(Recno()))))

                     //Se n�o conseguir lockar o SC5 desarma a transa��o e parte para o pr�ximo registro
                     Disarmtransaction()
                     TRBZFQ->(DbSkip())
                     u_itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' n�o enviado por lock na SC5 ...' )
               Else

                 //-----------------------------------------------------------------------------------------
                 // Atualiza a situa��o e reserva do pedido de vendas, antes de enviar para o sistema RDC.
                 //-----------------------------------------------------------------------------------------
                 _cReserva := ""
                 _cMotivo := ""
                 If ! SC9->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
                    _cReserva := "1" // N�o tem reserva de estoque = Verde => Sem Reserva
                    _cMotivo  := "N�o tem reserva de estoque = Verde => Sem Reserva"
                 Else
                  If U_Verest()
                     _cReserva := "2" // Conseguiu reservar estoque = Amarelo => Reservado
                  Else
                     _cReserva := "3" // N�o h� estoque dispon�vel  = Azul => Bloqueio de estoque
                     _cMotivo  :=  "N�o h� estoque dispon�vel  = Azul => Bloqueio de estoque"
                  EndIf

                 EndIf

                  If _cReserva <> "2" .AND. _lReserva
                     //Se n�o consegue reservar estque desarma a transa��o e parte para o pr�ximo registro
                     Disarmtransaction()
                     TRBZFQ->(DbSkip())
                     u_itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' n�o enviado. Motivo: '+_cMotivo )
                  EndIf

                 ZFQ->(RecLock("ZFQ",.F.))
                 ZFQ->ZFQ_RESERV := _cReserva
                 ZFQ->ZFQ_SITPED	:= U_STPEDIDO() // Status do Pedido, rotina no xfunoms
                 ZFQ->(MsUnlock())

                 //-----------------------------------------------------------------------------------------
                 // Realiza a integra��o dos pedidos de vendas (Envio de XML) via WebService.
                 //-----------------------------------------------------------------------------------------
                 ZFR->(DbSeek(ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)+"N"))

                 _aRecnoItem := {}
                 _cDadosItens := ""
                 Do While ! ZFR->(Eof()) .And. ZFR->(ZFR_FILIAL+ZFR_NUMPED+ZFR_SITUAC) = ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)+"N"
                  _cDadosItens += &(_cItemXML)
                  Aadd(_aRecnoItem,ZFR->(Recno()))

                  ZFR->(DbSkip())

                 EndDo

                //Monta XML
                _cXML := _cCabXML + &(_cDetA_XML)+ _cDadosItens + &(_cDetB_XML) + _cRodXML  // Monta o XML de envio.

                //Limpa & da string
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

                 // "Importado Com Sucesso"
                 _cSituacao := "P"


                 If ! _cOk
                  _cSituacao := "N"
                 ElseIf !("IMPORTADO COM SUCESSO" $ _cResposta .OR. "REGISTRO EXISTE" $ _cResposta)
                 _cSituacao := "N"

                EndIf

                //grava resultado // sempre como processado

                ZFQ->(RecLock("ZFQ",.F.))
                 ZFQ->ZFQ_SITUAC  := _cSituacao // iif(_cok, "P", "N")

                 ZFQ->ZFQ_DATAAL  := Date()
                 ZFQ->ZFQ_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFQ,dizendo que deu certo ou n�o.
                 ZFQ->ZFQ_XML     := _cXML
                 ZFQ->ZFQ_DATAP := DATE()
                 ZFQ->ZFQ_HORAP := TIME()
                 ZFQ->(MsUnlock())

                 _lfalha := .F.  //Verifica se tem falha de processamento no loop a seguir

                 For _nI := 1 To Len(_aRecnoItem)

                   ZFR->(DbGoTo(_aRecnoItem[_nI]))


                   ZFR->(RecLock("ZFR",.F.))
                   ZFR->ZFR_SITUAC  := _cSituacao // iif(_cok, "P", "N")
                   ZFR->ZFR_DATAAL  := Date()
                   ZFR->ZFR_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFQ,dizendo que deu certo ou n�o.
                   ZFR->(MsUnlock())

                 Next

                 If _cSituacao == "P"

                   SC5->(RecLock("SC5",.F.))
                   SC5->C5_I_ENVRD := "S"
                   SC5->(MsUnlock())
                   SC5->(Msunlockall())
                   u_itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' enviado para rdc ...' )

                 Else

                  SC5->(Msunlock())
                  SC5->(Msunlockall())
                  u_itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' falhou envio para rdc ...' )

                 EndIf

                 Aadd(_aresult,{ZFQ->ZFQ_PEDIDO,ZFQ->ZFQ_CNPJEM,ZFQ->ZFQ_RETORN}) // adicona em um array para fazer um item list, exibir os resultados.
                 Sleep(100) //Espera para n�o travar a comunica��o com o webservice da RDC

               EndIf
           Endif
         End Transaction
         SC5->(MSRUNLOCK(SC5->(Recno())))
      EndIf

      TRBZFQ->(DbSkip())

EndDo

_aCabecalho := {}
Aadd(_aCabecalho,"PEDIDO" )
Aadd(_aCabecalho,"CNPJ")
Aadd(_aCabecalho,"RETORNO")

_cTitulo := "Resultados da integra��o"

If len(_aresult) > 0 .AND. !_lScheduler

   u_ITListBox( _cTitulo , _aCabecalho , _aresult  ) // Exibe uma tela de resultado.

Endif



End Sequence

RestOrd(_aOrd)

Return Nil

/*
===============================================================================================================================
Fun��o-------------: AOMS084X
Aut2or-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: L� o arquivo XML modelo no diret�rio informado e retorna os dados no formato de String.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/
User Function AOMS084X(_cArq)
Local _cRet := ""
Local _nStatusArq
Local _cLine

Begin Sequence
   _nStatusArq := FT_FUse(Lower(_cArq))

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
Fun��o------------: AOMS084D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Grava em tabela tempor�ria os dados a serem integrados via webservice.
===============================================================================================================================
Parametros--------: oproc - objeto de barra de processamento
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
User Function AOMS084D(oproc)
Local _lRet := .F.,_nI
Local _nregs := 0
Local _npos := 1
Local _cFilAcesso:=AllTrim( U_ITGetMV( 'IT_GESTAOPV','XX' ) )
Local _cOpeAcesso:=AllTrim( U_ITGetMV( 'IT_GESTPVOP',"01;20;24;25;26;42") )
Local _aDadosZFQ := {}
Local _cIT_NAGEND := ALLTRIM(SuperGetMV("IT_NAGEND",.F., "P;R;N"))//P=Aguardando Agenda; R=Reagendar; N=Reagendar com Multa
//Local _lWsTms

Default oproc := nil

_cTipoOper  := U_ITGETMV( 'IT_TIPOOPER' , '01;10;17;20;41;')
_nTot:=0

Begin Sequence
   //================================================================================
   // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC.
   //================================================================================
   //_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.)

   IF !_lScheduler .and. valtype(oproc) = "O"
      oproc:cCaption := ("Lendo registros...")
      ProcessMessages()
   ENDIF


   //Carrega total de registros
   ZFQ->(Dbgotop())
   ZFQ->(DbSetOrder(2))  // ZFF_FILIAL+ZFF_SITUAC
   ZFQ->(DbSeek(xFilial("ZFQ")+"N"))

   Do While ! ZFQ->(Eof()) .And. ZFQ->(ZFQ_FILIAL+ZFQ_SITUAC) == xFilial("ZFQ")+"N"

     _nregs++
     ZFQ->(Dbskip())

   Enddo

   ZFQ->(Dbgotop())
   ZFQ->(DbSetOrder(2))  // ZFF_FILIAL+ZFF_SITUAC
   ZFQ->(DbSeek(xFilial("ZFQ")+"N"))

   Do While ! ZFQ->(Eof()) .And. ZFQ->(ZFQ_FILIAL+ZFQ_SITUAC) == xFilial("ZFQ")+"N"

      IF !_lScheduler .and. valtype(oproc) = "O"
         oproc:cCaption := ("Processando registro " + strzero(_npos,9) + " de " + strzero(_nregs,9) + "...")
         ProcessMessages()
      ENDIF
      _npos++
      
      _lLoop:=.F.
      If SC5->(Dbseek(ZFQ->ZFQ_FILIAL+U_ItKey(ZFQ->ZFQ_PEDIDO,"C5_NUM")))
         
         //========================================
         // Integra��o com o Sistema RDC ativa.
         // Fitra dados gerados para o TMS.
         //========================================
         If !u_IT_TMS(SC5->C5_I_LOCEM)  //! _lWsTms 
            If "TMS" $ ZFQ->ZFQ_FLUXO  // Indica dados gerados para o sistema TMS 
               ZFQ->(DbSkip())
               Loop
            EndIf 
         EndIf 
         //======================================= Fim Filtro de dados para o RDC <<< 

         
         // Pedidos com tipo de entraga: P=Aguardando Agenda; R=Reagendar; N=Reagendar que n�o pode enviar
         If SC5->C5_TIPO = 'N' .AND. SC5->C5_I_AGEND $  _cIT_NAGEND //P=Aguardando Agenda; R=Reagendar; N=Reagendar
            _lLoop:=.T.
         Endif
         
         //S� envia pedidos cuja o campo SC5->C5_I_BLSLD = 'N'
         If SC5->(FIELDPOS("C5_I_BLSLD")) > 0 .AND. SC5->C5_I_BLSLD = 'S'
            _lLoop:=.T.
         Endif

         IF !_lLoop .AND. SC5->C5_FILIAL $ _cFilAcesso .AND. SC5->C5_I_OPER $ _cOpeAcesso  .AND. SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
            Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->C5_FILIAL+SC5->C5_NUM
               IF !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))	.OR. !EMPTY(SC9->C9_BLEST) .OR. SC9->C9_QTDLIB <> SC6->C6_QTDVEN
                    _lLoop:=.T.
                   EXIT
               Endif
               SC6->(DbSkip())
            EndDo
         ENDIF

      ELSE
         _lLoop:=.T.
      ENDIF

      IF _lLoop
         ZFQ->(DbSkip())
         LOOP
      ENDIF


      TRBZFQ->(DBAPPEND())
      For _nI := 1 To ZFQ->(FCount())

          nPos:=TRBZFQ->(FieldPos(  ZFQ->( FieldName(_nI)) ))
          IF nPos # 0
              If valtype(ZFQ->( FieldGet(_nI))) == "C" .and. len(ZFQ->( FieldGet(_nI))) > 1000
                 TRBZFQ->(FieldPut(nPos,substr(ZFQ->( FieldGet(_nI) ),1,1000) ))
              Else
                 TRBZFQ->(FieldPut(nPos,ZFQ->( FieldGet(_nI) ) ))
              Endif
          ENDIF

      Next

      IF .T.

       //------------------------------------------------------------------------------------------------------
       // Filtro tempor�rio, ap�s defini��o definitiva tirar pergunta de escolha se filtra ou n�o. //
       //------------------------------------------------------------------------------------------------------

       SC5->(Dbsetorder(1))
       SC6->(Dbsetorder(1))
       SC9->(DBSETORDER(1))
       If SC5->(Dbseek(ZFQ->ZFQ_FILIAL+U_ITKEY(ZFQ->ZFQ_PEDIDO,"C5_NUM"))) .AND. SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

          If SC5->C5_I_ENVRD == 'S' //Se pedido j� est� marcado cAOMS084Domo enviado marca muro como enviado tamb�m

            Aadd(_aDadosZFQ,ZFQ->(Recno()))

          ElseIF SC5->C5_FILIAL == '40' .OR. (SC5->C5_FILIAL == '01') .OR. ( SC5->C5_FILIAL = '90' .AND. SC6->C6_LOCAL == '36') .Or. SC5->C5_FILIAL == '20' .Or. SC5->C5_FILIAL == '23' .Or. SC5->C5_FILIAL == '93'  .Or. SC5->C5_FILIAL == '10' .Or. SC5->C5_FILIAL == '31' // ( SC5->C5_FILIAL = '90' .AND. SC6->C6_LOCAL == '36')

             If EMPTY(SC5->C5_NOTA) //S� manda o que ainda n�o tem nota

                IF SC5->C5_TIPO == "N"  //S� manda pedido tipo normal

                   IF SC5->C5_I_ENVRD <> "S" .AND. SC5->C5_I_ENVRD <> "R" .AND. SC5->C5_I_ENVRD <> "V"//S� manda pedidos que est�o com status de n�o enviado

                     If SC5->C5_I_OPER $ _cTipoOper  //S� opera��es do par�metro IT_TIPOOPER

                         If !(SC5->C5_I_TRCNF == 'S' .AND. SC5->C5_I_PDPR == SC5->C5_NUM) //N�o envia pedido carregamento troca nota

                               //Analisa se tem item no armaz�m 40
                               SC6->(Dbsetorder(1))
                               If (SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM)))

                                  _ltem40 := .F.
                                  _ltemcarga := .F.
                                  SC9->(Dbsetorder(1))
                                  Do while SC5->C5_FILIAL == SC6->C6_FILIAL .and. SC5->C5_NUM == SC6->C6_NUM

                                     If SC6->C6_LOCAL == '40' .OR. SC6->C6_LOCAL == '42' .OR. SC6->C6_LOCAL == '50' .OR. SC6->C6_LOCAL == '52'

                                        _ltem40 := .T.

                                     Endif

                                     If SC9->(Dbseek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))

                                        If !Empty(SC9->C9_CARGA)

                                           _ltemcarga := .T.

                                        Endif

                                     Endif

                                     SC6->(Dbskip())

                                  Enddo


                                  If !(_ltem40) .AND. !(_ltemcarga)

                                     TRBZFQ->WK_OK := _cMarcaZFQ
                                     _nTot++

                                  Endif

                               Endif

                         Endif

                     Endif

                  Endif

                Endif

             Endif

          Endif

       Endif

      ENDIF

      If TRBZFQ->WK_OK != _cMarcaZFQ

         TRBZFQ->(DbDelete())

      Else

         TRBZFQ->WKRECNO := ZFQ->(Recno())

      Endif

      _lRet := .T.
      ZFQ->(DbSkip())
   EndDo

   For _nI := 1 To Len(_aDadosZFQ)
       ZFQ->(DbGoTo(_aDadosZFQ[_nI]))
       Reclock("ZFQ",.F.)
       ZFQ->ZFQ_SITUAC := 'P'
       ZFQ->ZFQ_DATAP := DATE()
       ZFQ->ZFQ_HORAP := TIME()
       ZFQ->(Msunlock())
   Next

   TRBZFQ->(DbGoTop())

End Sequence

Return _lRet

/*
===============================================================================================================================
Fun��o------------: AOMS084N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Com base em um endere�o passado como par�metro, retorna o numero deste endere�o.
===============================================================================================================================
Parametros--------: _cEndereco = Endere�o a ser lido e retornado o n�mero.
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/
User Function AOMS084N(_cEndereco)
Local _cRet := "000000"
Local _nPos
Local _nI
Local _cPartNumero
Local _lTipoNumerico

Begin Sequence
   If Empty(_cEndereco)
      Break
   EndIf

   _nPos := At(",",_cEndereco) // Retorna a posi��o da primeira virgula encontrada no endere�o

   If _nPos == 0 // Se n�o existir virgula no endere�o, n�o retorna nada.
      Break
   EndIf

   _cPartNumero := AllTrim(SubStr(_cEndereco,_nPos+1,Len(_cEndereco))) // Pega a parte do endere�o do numero em diante.

   _lTipoNumerico := .T.
   For _nI := 1 To Len(_cPartNumero) // Localiza a posi��o que termina o numero.
       If ! SubStr(_cPartNumero,_nI,1) $ "0123456789"
          _lTipoNumerico := .F.
          Exit
       EndIf

       If SubStr(_cPartNumero,_nI,1) $ " ,.-/\"
          _nPos := _nI - 1
          Exit
       Else
          _nPos := _nI
       EndIf
   Next

   If _lTipoNumerico
      _cRet := SubStr(_cPartNumero,1,_nPos)  // Retorna apenas o numero do endere�o.
   EndIf

End Sequence

If empty(alltrim(_cret))

  _cret := "00000"

 Endif

Return _cRet

/*
===============================================================================================================================
Fun��o------------: AOMS084P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Grava os dados dos Pedidos de Vendas nas tabelas de muro, atrav�s de ponto de entrada, ap�s a inclus�o
                    ou altera��o de um pedido de vendas.
===============================================================================================================================
Parametros--------: _cSituacao = situa��o do pedido de vendas na grava��o da tabela de muro.
                    oproc      = objeto da barra de progresso
                    _cChamada  = BROWSER = Browser do Pedido de Vendas.
                               = MANUTENCAO = Manuten��o do Pedido de Vendas.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084P(_cSituacao, oproc, _cChamada, _cSulfixo)
Local _aOrd := SaveOrd({"ZFQ","ZFR","SC6","SA2","SA1"})
Local _nRegSC6 := SC6->(Recno())
Local _nI
Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
Local _aFilial := FwLoadSM0()
Local _cCnpj
Local _aUF, _cUFCli
Local _aCalcItens
Local _lSeekSB5
Local _nQtd, _cUnidade, _nPesoUnit, _nPesoTot, _nPrecoVenda
Local _cTipoCA
Local _cForEmbM, _cLojaEmbM, _cFilRDC
Local _cEndereco, _cNumero, _cComplemento, _cIBGEFA, _cBairro
Local _nRegSA2
Local _nFatConvPa
Local _lTemSitN
Local _nQtdPecas := 0
//Local _lWsTms
Local _cIndIEExp,_cIndIEFor,_cIndIECli
Local _cPedCliente:= ""
Local _cIT_NAGEND := ALLTRIM(SuperGetMV("IT_NAGEND",.F., "P;R;N"))//P=Aguardando Agenda; R=Reagendar; N=Reagendar com Multa

Default oproc := nil, _cChamada := "BROWSER"

//Se estiver no webservice n�o executa
If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B")
   Return nil
Endif


Begin Sequence

   If ValType(_cSulfixo) == "U"
      _cSulfixo := ""
   EndIf

   //================================================================================
   // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC.
   //================================================================================
   //_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.)

   //============================================================================================
   // Esta condi��o bloqueia a grava��o na tabela de muro e envio ao RDC de pedidos de vendas do
   // tipo troca nota.
   //============================================================================================
   If SC5->C5_I_FILFT == SC5->C5_FILIAL  .AND. SC5->C5_I_PDFT == SC5->C5_NUM .AND. SC5->C5_I_TRCNF == 'S' .And. ! FWIsInCallStack("U_AOMS140I") .And. ! FWIsInCallStack("U_AOMS152A")
      If Type("ncont") == "N"
         ncont := ncont - 1
         _nNaoIntegra += 1
      EndIf

      Break
   EndIf

   //============================================================================================
   //Se o pedido j� tem nota emitida n�o faz mais inclus�es ou altera��es na tabela de muro
   //============================================================================================
   If !Empty(SC5->C5_NOTA) .And. ! FWIsInCallStack("U_AOMS140I") .And. ! FWIsInCallStack("U_AOMS152A")

      If Type("ncont") == "N"
         ncont := ncont - 1
         _nNaoIntegra += 1
      EndIf

        Break

   Endif

   //============================================================================================
   //S� envia pedidos cuja opera��o perten�a ao IT_TIPOOPER
   //============================================================================================
   _cTipoOper  := U_ITGETMV( 'IT_TIPOOPER' , '01;10;17;20;41;')
   If !(SC5->C5_I_OPER $ _cTipoOper)

      If Type("ncont") == "N"
         ncont := ncont - 1
         _nNaoIntegra += 1
      EndIf

        Break

   Endif

   //====================================================================================================
   // Pedidos com tipo de entraga: P=Aguardando Agenda; R=Reagendar; N=Reagendar que n�o pode enviar  
   //====================================================================================================
   If SC5->C5_TIPO = 'N' .AND. SC5->C5_I_AGEND $  _cIT_NAGEND .And. ! FWIsInCallStack("U_AOMS152A") //P=Aguardando Agenda; R=Reagendar; N=Reagendar
      If Type("ncont") == "N"
         ncont := ncont - 1
         _nNaoIntegra += 1
      EndIf
      Break
   Endif

   //============================================================================================
   //S� envia pedidos cuja o campo SC5->C5_I_BLSLD = 'N'
   //============================================================================================
   If SC5->(FIELDPOS("C5_I_BLSLD")) > 0 .AND. SC5->C5_I_BLSLD = 'S'
      If Type("ncont") == "N"
         ncont := ncont - 1
         _nNaoIntegra += 1
      EndIf
      Break
   Endif


   //================================================================================
   // Caso j� existe registro n�o processado apaga tudo
   //================================================================================

   cQuery	:= " SELECT ZFQ.r_e_c_n_o_ REG "
   cQuery	+= " FROM  "+ RetSqlName('ZFQ') + " ZFQ "
   If ! Empty(_cSulfixo) .And. _cSulfixo == "ESP"
      cQuery	+= " WHERE "+ RetSqlDel('ZFQ') + " AND ZFQ_PEDIDO = '" + SC5->C5_NUM + "_" + _cSulfixo + "' AND ZFQ_SITUAC = 'C' "
   ElseIf ! Empty(_cSulfixo)
      cQuery	+= " WHERE "+ RetSqlDel('ZFQ') + " AND ZFQ_PEDIDO = '" + SC5->C5_NUM + "_" + _cSulfixo + "' AND ZFQ_SITUAC = 'T' "
   Else
      cQuery	+= " WHERE "+ RetSqlDel('ZFQ') + " AND ZFQ_PEDIDO = '" + SC5->C5_NUM + "' AND ZFQ_SITUAC = 'N' "
   EndIf
   If Select("TRABT") <> 0
      TRABT->( DBCloseArea(  ) )
   EndIf

   MPSysOpenQuery( cQuery , "TRABT")
   DBSelectArea("TRABT")

   _lTemSitN := .F.

   Do While !(TRABT->(Eof()))

       ZFQ->(Dbgoto(TRABT->REG))

      If ! Empty(_cSulfixo) // Chamado da gera��o de carga Troca Nota Fiscal
         If ZFQ->ZFQ_SITUAC == "T" .Or. ZFQ->ZFQ_SITUAC == "C"
            _lTemSitN := .T.
             ZFQ->(RecLock("ZFQ",.F.))
            ZFQ->(DbDelete())
            ZFQ->(MsUnlock())
         EndIf
      Else  // Chamada da integra��o com o RDC
         If ZFQ->ZFQ_SITUAC == "N"
            _lTemSitN := .T.
            ZFQ->(RecLock("ZFQ",.F.))
            ZFQ->(DbDelete())
            ZFQ->(MsUnlock())
         EndIf
      EndIf

        TRABT->(DbSkip())

   EndDo

   //===========================================================================================================
   // Se a chamada da fun��o AOMS084P tiver sido feita da rotina de manuten��o de pedidos de vendas,
   // e n�o existir na tabela de muro pedidos de vendas com situa��o igual "N", n�o se deve gerar tabela de muro.
   //===========================================================================================================
   If ! Empty(_cChamada) .And. _cChamada == "MANUTENCAO"
      If ! _lTemSitN .And. SC5->C5_I_ENVRD <> "R" .And. ! Empty(SC5->C5_I_ENVRD)
         Break
      ElseIf SC5->C5_I_ENVRD == "R"
         SC5->(RecLock("SC5",.F.))
         SC5->C5_I_ENVRD := "N"
         SC5->(MsUnLock())
      EndIf
   EndIf

   cQuery	:= " SELECT ZFR.r_e_c_n_o_ REG "
   cQuery	+= " FROM  "+ RetSqlName('ZFR') + " ZFR "

   If ! Empty(_cSulfixo) .And. _cSulfixo == "ESP"
      cQuery	+= " WHERE "+ RetSqlDel('ZFR') + " AND ZFR_NUMPED = '" + SC5->C5_NUM + "_" +_cSulfixo + "' AND ZFR_SITUAC = 'C' "
   ElseIf ! Empty(_cSulfixo)
      cQuery	+= " WHERE "+ RetSqlDel('ZFR') + " AND ZFR_NUMPED = '" + SC5->C5_NUM + "_" +_cSulfixo + "' AND ZFR_SITUAC = 'T' "
   Else
      cQuery	+= " WHERE "+ RetSqlDel('ZFR') + " AND ZFR_NUMPED = '" + SC5->C5_NUM + "' AND ZFR_SITUAC = 'N' "
   EndIf

   If Select("TRABT") <> 0
      TRABT->( DBCloseArea(  ) )
   EndIf

   MPSysOpenQuery( cQuery , "TRABT")
   DBSelectArea("TRABT")

   Do While !(TRABT->(Eof()))

          ZFR->(Dbgoto(TRABT->REG))
          If ! Empty(_cSulfixo) // Chamado da gera��o de carga Troca Nota Fiscal
             If ZFR->ZFR_SITUAC == "T" .Or. ZFR->ZFR_SITUAC == "C"
                  ZFR->(RecLock("ZFR",.F.))
                 ZFR->(DbDelete())
                 ZFR->(MsUnlock())
             EndIf
          Else // Chamada da integra��o com o RDC.
             If ZFR->ZFR_SITUAC == "N"
                ZFR->(RecLock("ZFR",.F.))
                 ZFR->(DbDelete())
                 ZFR->(MsUnlock())
              EndIf
          EndIf

         TRABT->(DbSkip())

    EndDo

   //================================================================================
   // Monta array dos estados
   //================================================================================
   _aUF := {}
   aadd(_aUF,{"RO","11"})
   aadd(_aUF,{"AC","12"})
   aadd(_aUF,{"AM","13"})
   aadd(_aUF,{"RR","14"})
   aadd(_aUF,{"PA","15"})
   aadd(_aUF,{"AP","16"})
   aadd(_aUF,{"TO","17"})
   aadd(_aUF,{"MA","21"})
   aadd(_aUF,{"PI","22"})
   aadd(_aUF,{"CE","23"})
   aadd(_aUF,{"RN","24"})
   aadd(_aUF,{"PB","25"})
   aadd(_aUF,{"PE","26"})
   aadd(_aUF,{"AL","27"})
   aadd(_aUF,{"MG","31"})
   aadd(_aUF,{"ES","32"})
   aadd(_aUF,{"RJ","33"})
   aadd(_aUF,{"SP","35"})
   aadd(_aUF,{"PR","41"})
   aadd(_aUF,{"SC","42"})
   aadd(_aUF,{"RS","43"})
   aadd(_aUF,{"MS","50"})
   aadd(_aUF,{"MT","51"})
   aadd(_aUF,{"GO","52"})
   aadd(_aUF,{"DF","53"})
   aadd(_aUF,{"SE","28"})
   aadd(_aUF,{"BA","29"})
   aadd(_aUF,{"EX","99"})

   //---------------------------
   _cUFCli    := ""    // Estado do Cliente
   _cInscrCli := ""    // InscricaoEstadual
   _cNomeFCli := ""    // NomeFantasia
   _cRGIECl   := ""    // RGIE
   _cRazaoCli := ""    // RazaoSocial
   _cTipoPCli := ""    // TipoPessoa
   _cCEPCli   := ""    // CEP

   //========================================================
   // Obtem dados do Vendedor
   //========================================================
   _cCodVend  := SC5->C5_VEND1
   _cCPFVend  := ""    // CPF
   _cEmailVen := ""    // Email
   _cNomeVend := ""    // Nome
   _cRGVend   := ""    // RG
   _cTelVend  := ""    // Telefone

   SA3->(DbSetOrder(1))
   If SA3->(MsSeek(xFilial("SA3")+SC5->C5_VEND1))
      _cCPFVend  := AllTrim(SA3->A3_CGC)  // CPF
      _cEmailVen := AllTrim(SA3->A3_EMAIL)  // Email
      _cNomeVend := AllTrim(SA3->A3_NOME)  // Nome
      _cRGVend   := ""  // RG
      _cTelVend  := SA3->A3_DDDTEL+Alltrim(SA3->A3_TEL) // Telefone
   EndIf

   //========================================================
   // Obtem dados do Coordenador
   //========================================================
   _cCodCoord := SC5->C5_VEND2  // Cod. Coordenador
   _cCPFCoord := ""    // CPF
   _cEmailCoo := ""    // Email
   _cNomeCoor := ""    // Nome
   _cRGCoord  := ""    // RG
   _cTelCoord := ""    // Telefone

   SA3->(DbSetOrder(1))
   If SA3->(MsSeek(xFilial("SA3")+SC5->C5_VEND2))
      _cCPFCoord  := AllTrim(SA3->A3_CGC)    // CPF
      _cEmailCoo := AllTrim(SA3->A3_EMAIL)  // Email
      _cNomeCoor := AllTrim(SA3->A3_NOME)   // Nome
      _cRGCoord  := ""  // RG
      _cTelCoord := SA3->A3_DDDTEL+Alltrim(SA3->A3_TEL) // Telefone
   EndIf

   //========================================================
   // Obtem dados do Gerente.
   //========================================================
   _cCodGeren  := SC5->C5_VEND3  // Cod. Gerente
   _cCPFGeren  := ""    // CPF
   _cEmailGer  := ""    // Email
   _cNomeGeren := ""    // Nome
   _cRGGeren   := ""    // RG
   _cTelGeren  := ""    // Telefone

   SA3->(DbSetOrder(1))
   If SA3->(MsSeek(xFilial("SA3")+SC5->C5_VEND3))
      _cCPFGeren  := AllTrim(SA3->A3_CGC)  // CPF
      _cEmailGer := AllTrim(SA3->A3_EMAIL)  // Email
      _cNomeGeren := AllTrim(SA3->A3_NOME)  // Nome
      _cRGGeren   := ""  // RG
      _cTelGeren  := SA3->A3_DDDTEL+Alltrim(SA3->A3_TEL) // Telefone
   EndIf

   //================================================================================
   // Define o tipo de carga do pedido
   //================================================================================
   _cIndIECli := ""
   _cTipoCA := "2"
   SA1->(DbSetOrder(1))
   If SA1->(DbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
      If len(alltrim(SA1->A1_I_CCHEP)) == 10
         _cTipoCA := "1"  //chep
      Else
         _cTipoCA := "2" //estivada
      EndIf

      _cUFCli := SA1->A1_EST // Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_EST")

      _cInscrCli := AllTrim(SA1->A1_INSCR)                      // InscricaoEstadual
      _cNomeFCli := AllTrim(SA1->A1_NREDUZ)                     // NomeFantasia
      _cRGIECl   := AllTrim(SA1->A1_RG)                         // RGIE
      _cRazaoCli := AllTrim(SA1->A1_NOME)                       // RazaoSocial
      _cTipoPCli := If(SA1->A1_PESSOA=="P","Fisica","Juridica") // TipoPessoa
      _cCEPCli   := AllTrim(SA1->A1_CEP)                        // CEP

      /*
      A1_CONTRIB = 1 = Sim = Contribuinte ICMS
           = 2 = N�o = N�o Contribuinte ICMS
      A1_INSCR   = ISENTO = Inscri��o Estadual
      */

      If SA1->A1_CONTRIB == "1" .And. !Empty(SA1->A1_INSCR) .And. AllTrim(SA1->A1_INSCR) <> "ISENTO"
         _cIndIECli := "ContribuinteICMS"   // "1" //Contribuinte ICMS
      ElseIf SA2->A2_CONTRIB == "1"
         _cIndIECli := "ContribuinteIsento" // "2" // Contibuinte Isento de Incri��o no Cad Contrib.ICM
      Else
         _cIndIECli := "NaoContribuite"     // "9" //  N�o Contribuinte que pode ou n�o ter insci��o est.
      EndIf

   Endif

   _coper50 := AllTrim( U_ITGETMV( 'IT_CHEPCLIS' ) ) //Opera��o exclusiva para cliente Chep
   _coper51 := AllTrim( U_ITGETMV( 'IT_CHEPCLIN' ) ) //Opera��o exclusiva para cliente n�o Chep

   If SC5->C5_I_OPER == _coper50 .OR. SC5->C5_I_OPER == _coper51 //pedido de pallet deve ser enviado como estivado

     _cTipoCA := "2"

   Endif

   //================================================================================
   // Grava os dados do pedido de vendas para integra��o como WebService.
   //================================================================================
   _aCalcItens := U_AOMS084C(SC5->C5_FILIAL + SC5->C5_NUM)

   //_cUFCli := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_EST")

   If aScan(_aUF,{|x| x[1] == _cUFCli}) == 0

      _cUFCli := "EX"

   Endif


   _nI := Ascan(_aFilial,{|x| x[5] = SC5->C5_FILIAL})
   _cCnpj := _aFilial[_nI,18]
   SA2->(DbSetOrder(3))
   SA2->(DbSeek(xFilial("SA2")+_cCnpj))
   _cvend := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
   _coord := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_NOME")
   _coord := iif(empty(_coord),_cvend,_coord)
   _nRegSA2 := SA2->(Recno())

   _cCepForn  := AllTrim(SA2->A2_CEP)                                                   // CEP
   _cInscEst  := AllTrim(SA2->A2_INSCR)                                                 // InscricaoEstadual
   _cNFantFor := AllTrim(SA2->A2_NREDUZ)                                                // NomeFantasia
   _cRgiForn  := ""                                                                     // RGIE
   _cRazaoFor := AllTrim(SA2->A2_NOME)                                                  // RazaoSocial
   _cTipoPFor := If(SA2->A2_TIPO=="P","Fisica","Juridica")                              // TipoPessoa
   _cCondPag  := AllTrim(Posicione('SE4',1,xFilial('SE4')+SC5->C5_CONDPAG,'E4_DESCRI')) // Condi��o de Pagamento
   _cCodForn  := SA2->A2_COD                                                            // Codigo Fornecedor
   _cLojaForn := SA2->A2_LOJA                                                           // Loja do Fornecedor

   /*
   A2_CONTRIB = 1 = Sim = Contribuinte ICMS
           = 2 = N�o = N�o Contribuinte ICMS
   A2_INSCR   = ISENTO = Inscri��o Estadual
   */
   _cIndIEFor := ""
   If SA2->A2_CONTRIB == "1" .And. !Empty(SA2->A2_INSCR) .And. AllTrim(SA2->A2_INSCR) <> "ISENTO"
      _cIndIEFor := "ContribuinteICMS"   // "1" //Contribuinte ICMS
   ElseIf SA2->A2_CONTRIB == "1"
      _cIndIEFor := "ContribuinteIsento" // "2" // Contibuinte Isento de Incri��o no Cad Contrib.ICM
   Else
      _cIndIEFor := "NaoContribuite"     // "9" //  N�o Contribuinte que pode ou n�o ter insci��o est.
   EndIf

   //================================================================================
   // Os endere�os de clientes abaixo est�o com o nome da rua separada do numero,
   // e do complemento.
   //================================================================================
   _cEndereco    := SA2->A2_I_END
   _cNumero      := SA2->A2_I_NUM
   _cComplemento := SA2->A2_COMPLEM

   If Empty(_cEndereco)
      _cEndereco    := SA2->A2_END
      _cNumero      := U_AOMS084N(SA2->A2_END)
      _cComplemento := SA2->A2_COMPLEM
   EndIf

   ZFQ->(RecLock("ZFQ",.T.))  
   ZFQ->ZFQ_FILIAL := SC5->C5_FILIAL         // xFilial("ZFQ")   // Filial do Sistema
   ZFQ->ZFQ_DATA   := Date()    		         // Data de Emiss�o
   ZFQ->ZFQ_HORA   := Time()                 // Hora de inclus�o na tabela de muro.
   ZFQ->ZFQ_CNPJEM := _cCnpj	               // CNPJ do Embarcador

   If ! Empty(_cSulfixo)
      ZFQ->ZFQ_PEDIDO := SC5->C5_NUM + "_" + _cSulfixo // N�mero do Pedido
   Else
      ZFQ->ZFQ_PEDIDO := SC5->C5_NUM  // N�mero do Pedido
   EndIf

   ZFQ->ZFQ_STATUS := '1'
   ZFQ->ZFQ_PEDID2 := SC5->C5_I_PEVIN    	   // Pedido Original
   ZFQ->ZFQ_CNPJFA := _cCnpj                 // CNPJ da F�brica
   If ZFQ->(FIELDPOS("ZFQ_CODOPE")) > 0
      ZFQ->ZFQ_CODOPE := SC5->C5_I_OPER      // Codigo de Opera��o
   Endif
   ZFQ->ZFQ_BAIRRO := SA2->A2_BAIRRO         // Bairro
   ZFQ->ZFQ_ENDERE := _cEndereco    // SA2->A2_END              // Endere�o da F�brica
   ZFQ->ZFQ_NUMERO := _cNumero      // U_AOMS084N(SA2->A2_END)  // N�mero do Endere�o da F�brica
   ZFQ->ZFQ_COMEND := _cComplemento // "000"                    // Complemento do Endere�o
   ZFQ->ZFQ_IBGEFA := _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)

   ZFQ->ZFQ_CNPJDE := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_CGC") // CNPJ do Destinat�rio
   ZFQ->ZFQ_ENDENT := SC5->C5_I_END  	         // Endereco de Entrega
   ZFQ->ZFQ_CEPENT := SC5->C5_I_CEP  	         // CEP de Entrega
   ZFQ->ZFQ_BAIENT := SC5->C5_I_BAIRR	         // Bairro de entrega
   ZFQ->ZFQ_NUMENT := U_AOMS084N(SC5->C5_I_END) //SC5->C5_I_MUN  	       // N�mero de Entrega
   ZFQ->ZFQ_IBGENT := _aUF[aScan(_aUF,{|x| x[1] == _cUFCli})][02] + SC5->C5_I_CMUN 	// Municipio de Entrega  (C�digo IBGE)
   ZFQ->ZFQ_DTEMIS := SC5->C5_EMISSAO	         // Data Emiss�o
   ZFQ->ZFQ_DTPREV := SC5->C5_I_DTENT	         // Data de Previs�o de Entrega
   ZFQ->ZFQ_CAPROD := _aCalcItens[4]            //_cTipoCarga  // Caracteristica do Produto
    IF SC5->C5_I_AGEND $ "A/M"                  // Data de Entrega Agendada
      ZFQ->ZFQ_DTAGEN := SC5->C5_I_DTENT
   Else
      ZFQ->ZFQ_DTAGEN := Ctod("  /  /  ")	     // Data de Entrega Agendada
   Endif
   ZFQ->ZFQ_TIPEDI := AOMS084G()               //Define tipo de pedido, 1 normal, 2 pallet
   ZFQ->ZFQ_CNPJTR := ""	                   // CNPJ de Transfer�ncia
   ZFQ->ZFQ_ENDTRA := ""                       // Endereco de Transfer�ncia
   ZFQ->ZFQ_CEPTRA := ""                       // CEP de Transfer�ncia
   ZFQ->ZFQ_BAIRTR := ""                       // Bairro de Transfer�ncia
   ZFQ->ZFQ_NRTRAN := ""                       // N�mero de Transfer�ncia
   ZFQ->ZFQ_IBGETR := ""                       // Municipio de Transfer�ncia  (C�digo IBGE)
   ZFQ->ZFQ_REPRES := _cvend // SC5->C5_VEND1 // Representante
   ZFQ->ZFQ_COORDE := _coord // SC5->C5_VEND2 // Coordenador de Venda
   ZFQ->ZFQ_ASSIST := RETFIELD("SRA",1,SC5->C5_I_CDUSU,"SRA->RA_NOME") // SC5->C5_I_NOUSU	     // Assitente
   ZFQ->ZFQ_PESOPE := SC5->C5_I_PESBR	       // Peso Total do Pedido
   ZFQ->ZFQ_VLRPED := _aCalcItens[1]           // SOMAR C6_VALOR  	// Valor Total do Pedido

   If _cTipoCA == "2" // Enviar zeros no na qtd pallet capa e item. Trata-se de uma Carga Batida. N�o h� Pallets.
      ZFQ->ZFQ_QTDEPA := 0
   Else
      ZFQ->ZFQ_QTDEPA := _aCalcItens[2]           // SOMAR C6_I_QPALT	// Quantidade de Pallet�s
   EndIf

   ZFQ->ZFQ_VOLUME := Ceiling(_aCalcItens[3])  // SOMAT�RIA: C6_PRODUTO ==> b5_ecaltem X b5_ecprofe X b5_eclarge X C6_QTDVEN 	// Volume M� Total do Pedido // //   Ceiling - esta fun��o arredonda para cima em numeros inteiros, o valor passado como par�metro.
   ZFQ->ZFQ_DATAAL := Date()
   ZFQ->ZFQ_SITUAC := If(Empty(_cSituacao),"N",_cSituacao)
   ZFQ->ZFQ_CODEMP := _cCodEmpWS
   ZFQ->ZFQ_COCHEP := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_I_CCHEP") // CNPJ do Destinat�rio
   ZFQ->ZFQ_TIPOPA := _cTipoCA
   IF Type("__CUSERID") = "C" .AND. !EMPTY(__CUSERID)
      ZFQ->ZFQ_USUARI := __CUSERID
      ZFQ->ZFQ_USUALT := Posicione("ZZL",3,xFilial("ZZL")+__CUSERID,"ZZL_RDCUSR")
   ENDIF

   If ZFQ->(FIELDPOS("ZFQ_TPOPER")) > 0
      _cCanalVen := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_I_VBROK")
      If SC5->C5_I_OPER  == "20" .And. SC5->C5_I_TRCNF = 'N' // Transfer�ncia de Pedido de Vendas
         ZFQ->ZFQ_TPOPER := "TRANSF_UNID"
      ElseIf SC5->C5_I_TRCNF = 'S'
         ZFQ->ZFQ_TPOPER := "TROCA_NF"
      ElseIf !Empty(_cCanalVen) .And. _cCanalVen == "B"
         ZFQ->ZFQ_TPOPER := "BROKER"
      ElseIf SC5->C5_TPFRETE == "F" // FRETE = FOB  
         ZFQ->ZFQ_TPOPER := "FOB"
      Else // Venda Direta = Venda Normal
         ZFQ->ZFQ_TPOPER := "VD_DIR"
      EndIf
   EndIf

   //Ajuste  para frete Fob ser enviado como agenda F para o RDC
   If SC5->C5_I_OPER  == "20" .And. SC5->C5_I_TRCNF = 'N'
      ZFQ->ZFQ_TPAGEN	:=	"T"
   Else
      //c5_i_oper = '20' e c5_i_trcnf = 'N' tipo = 'T'
      If SC5->C5_TPFRETE == "F"
         ZFQ->ZFQ_TPAGEN := "F"
      Else
         ZFQ->ZFQ_TPAGEN	:=	SC5->C5_I_AGEND
      EndIf
   EndIf

   _cGrupoVen := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_GRPVEN")
   If ! Empty(_cGrupoVen)
      ZFQ->ZFQ_COREDE	:=	Posicione("ACY",1,xFilial("ACY")+_cGrupoVen,"ACY_DESCRI") // Ordem 1 - ACY_FILIAL+ACY_GRPVEN
   EndIf
   If ! Empty(SC5->C5_VEND3)
      ZFQ->ZFQ_GERENT	:= Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND3,"A3_NOME")
   EndIf
   ZFQ->ZFQ_SITPED	:=	U_STPEDIDO()             // Status do Pedido, rotina no xfunoms
   ZFQ->ZFQ_OBSCPA	:=	U_AOMS074X(SC5->C5_I_OBCOP)
   ZFQ->ZFQ_OBSPVE	:=	U_AOMS074X(SC5->C5_I_OBPED)
   ZFQ->ZFQ_OBSNFE	:=	U_AOMS074X(SC5->C5_MENNOTA)
   ZFQ->ZFQ_FILRDC   := Posicione("ZZM",1,xFilial("ZZM")+SC5->C5_FILIAL,"ZZM_FILRDC")

   //If AllTrim(ZFQ->ZFQ_FILRDC)  == "90"  // Solicita��o do Vanderlei 
   //   ZFQ->ZFQ_FILRDC :=  "9001"
   //EndIf 

   If u_IT_TMS(SC5->C5_I_LOCEM)  /*_lWsTms*/ .Or. !Empty(_cSulfixo) // Sistema TMS MultiEmbarcador
      ZFQ->ZFQ_FLUXO := "PROTHEUS ENVIA TMS"  
   Else // Sistema RDC
      ZFQ->ZFQ_FLUXO := "PROTHEUS ENVIA RDC"  
   EndIf 

   ZFQ->ZFQ_REGCAP := ZFQ->(Recno())
   ZFQ->ZFQ_DATAI := DATE()
   ZFQ->ZFQ_HORAI := TIME()

   If ZFQ->(FIELDPOS("ZFQ_CODVEN")) > 0
      //--------------------------------------------------
      ZFQ->ZFQ_CODVEN := _cCodVend  // Codigo Vendedor
      ZFQ->ZFQ_CPFVEN := _cCPFVend  // CPF
      ZFQ->ZFQ_MAILVE := _cEmailVen // Email
      ZFQ->ZFQ_TELVEN := _cTelVend  // Telefone
      //--------------------
      ZFQ->ZFQ_CODGER := _cCodGeren // Cod. Gerente
      ZFQ->ZFQ_CPFGER := _cCPFGeren // CPF
      ZFQ->ZFQ_MAILGE := _cEmailGer // Email
      ZFQ->ZFQ_TELGER := _cTelGeren // Telefone
      //--------------------
      ZFQ->ZFQ_CODCOO := _cCodCoord // Cod. Coordenador
      ZFQ->ZFQ_CPFCOO := _cCPFCoord // CPF
      ZFQ->ZFQ_MAILCO := _cEmailCoo // Email
      ZFQ->ZFQ_TELCOO := _cTelCoord // Telefone
      //--------------------
      ZFQ->ZFQ_RAZFOR := _cRazaoFor // Raz�o Social Fornecedor
      ZFQ->ZFQ_FANFOR := _cNFantFor // Nome Fantasia Fornecedor
      ZFQ->ZFQ_CEPFOR := _cCepForn  // CEP Fornecedor
      ZFQ->ZFQ_INSFOR := _cInscEst  // Inscri��o Estadual Fornecedor
      ZFQ->ZFQ_TIPPEF := _cTipoPFor // Tipo de Pessoa Fornecedor

      ZFQ->ZFQ_LOJFOR := _cLojaForn  // Loja do Fornecedor
      ZFQ->ZFQ_CODFOR := _cCodForn   // Codigo Fornecedor
      ZFQ->ZFQ_INDIEF := _cIndIEFor

      ZFQ->ZFQ_RAZCLI := _cRazaoCli // Raz�o Social Cliente
      ZFQ->ZFQ_FANCLI := _cNomeFCli // Nome Fantasia Cliente
      ZFQ->ZFQ_CEPCLI := _cCEPCli   // CEP Cliente
      ZFQ->ZFQ_INSCLI := _cInscrCli // Inscri��o Estadual Cliente
      ZFQ->ZFQ_TIPPEC := _cTipoPCli // Tipo Pessoa Cliente
      ZFQ->ZFQ_INDIEC := _cIndIECli

      _cCanalVen := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_I_VBROK")
      If SC5->C5_I_OPER  == "20" .And. SC5->C5_I_TRCNF = 'N' // Transfer�ncia de Pedido de Vendas
         ZFQ->ZFQ_TPOPER := "TRANSF_UNID"
      ElseIf SC5->C5_I_TRCNF = 'S'
         ZFQ->ZFQ_TPOPER := "TROCA_NF"
      ElseIf !Empty(_cCanalVen) .And. _cCanalVen == "B"
         ZFQ->ZFQ_TPOPER := "BROKER"
      ElseIf SC5->C5_TPFRETE == "F" // FRETE = FOB
         ZFQ->ZFQ_TPOPER := "FOB"
      Else // Venda Direta = Venda Normal
         ZFQ->ZFQ_TPOPER := "VD_DIR"
      EndIf

      //Ajuste  para frete Fob ser enviado como agenda F para o RDC
      If SC5->C5_I_OPER  == "20" .And. SC5->C5_I_TRCNF = 'N'         // Utilizar estas regras no tipo de opera��o.
         ZFQ->ZFQ_TPAGEN	:=	"T"
      Else
         //c5_i_oper = '20' e c5_i_trcnf = 'N' tipo = 'T'
         If SC5->C5_TPFRETE == "F"
            ZFQ->ZFQ_TPAGEN := "F"
         Else
            ZFQ->ZFQ_TPAGEN	:=	SC5->C5_I_AGEND
         EndIf
      EndIf
   EndIf

   ZFQ->(MsUnLock())

   _nQtd      := 0
   _cUnidade  := 0
   _nPesoUnit := 0
   _nPesoTot  := 0
   _nPrecoVenda := 0

   _cForEmbM  := ""
   _cLojaEmbM := ""
   _cFilRDC   := ""
   _cPedCliente := ""

   ZG9->(DbSetOrder(1)) // ZG9_FILIAL+ZG9_CODFIL+ZG9_ARMAZE
   SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
   SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
   SC6->(DbSetOrder(1))
   SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
   Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->C5_FILIAL+SC5->C5_NUM
      _lSeekSB5 := .F.
      If SB5->(DbSeek(xFilial("SB5")+SC6->C6_PRODUTO))
         _lSeekSB5 := .T.
      EndIf
      SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

      _nvolume := (SB5->B5_ECALTEM * SB5->B5_ECPROFE * SB5->B5_ECLARGE * SC6->C6_QTDVEN)
      _nvolume := iif(_nvolume>0,_nvolume,1)


      _ncubado := (posicione("SB1",1,xfilial("SB1")+SC6->C6_PRODUTO,"B1_PESBRU")*SC6->C6_QTDVEN)


      _ncubado := iif(_ncubado>0,_ncubado,1)

      _nqpalets := SC6->C6_I_QPALT

      _nqpalets := iif(_nqpalets>99,99,_nqpalets)

      _nPesoTot  := SB1->B1_PESBRU * SC6->C6_QTDVEN
      _nPrecoVenda := SC6->C6_PRCVEN

      _nFatConvPa := 0   // Fator de Convers�o de Pallets.
      _nQtdPecas := 0

      If SC6->C6_UNSVEN == 0 // N�o h� segunda unidade de medida
         _nQtd      := SC6->C6_QTDVEN
         _cUnidade  := "2" // Unidade de Medida // "1 - Caixa(2a. unidade) e 2 - Unidade (1a.unidade)"
         _nPesoUnit := SB1->B1_PESBRU
         _nPrecoVenda := SC6->C6_PRCVEN

         If SB1->B1_I_UMPAL == "1"
            _nFatConvPa := SB1->B1_I_CXPAL
         Else
            _nFatConvPa := 0
        EndIf

      Else

         If SB1->B1_I_UMPAL == "2"
            _nFatConvPa := SB1->B1_I_CXPAL
         Else
            If SB1->B1_I_UMPAL == "1"
               _nFatConvPa := SB1->B1_I_CXPAL
            Else
               _nFatConvPa := 0
           EndIf
         EndIf

         If SC6->C6_UM == "KG" .And. SB1->B1_I_PCCX <> 0
            _nQtdPecas := SC6->C6_UNSVEN
            _cUnidade  := "3"
            _nQtd      := SC6->C6_QTDVEN
         Else
            _nQtd      := SC6->C6_UNSVEN
            _cUnidade  := "1" // Unidade de Medida // "1 - Caixa(2a. unidade) , 2 - Unidade (1a.unidade) e 3 - Quilos"
         EndIf

         _nconv := iif(SB1->B1_CONV==0,1,SB1->B1_CONV)

         If SB1->B1_TIPCONV == "D" // TIPO DE CONVERSAO DIVIS�O
             _nPesoUnit := SB1->B1_PESBRU * _nconv
             _nPrecoVenda := SC6->C6_PRCVEN * _nconv
         Else
            _nPesoUnit := SB1->B1_PESBRU / _nconv
            _nPrecoVenda := SC6->C6_PRCVEN / _nconv
         EndIf
      EndIf

      ZFR->(RecLock("ZFR",.T.))
      ZFR->ZFR_FILIAL	:= SC6->C6_FILIAL           // Filial do Sistema
      ZFR->ZFR_DATA	    := Date()	                //	Data de Emiss�o
      ZFR->ZFR_HORA     := Time()                   //   Hora de inclus�o na tabela de muro.

      If ! Empty(_cSulfixo)
         ZFR->ZFR_NUMPED	:= SC6->C6_NUM + "_" + _cSulfixo  //	Numero Pedido de Vendas
      Else
         ZFR->ZFR_NUMPED	:= SC6->C6_NUM //	Numero Pedido de Vendas
      EndIf

      ZFR->ZFR_ITEM	   := SC6->C6_ITEM   	       //	Numero do Item
      ZFR->ZFR_CODIGO	:= AllTrim(SC6->C6_PRODUTO) + Right(_cCnpj,6)	//	C�digo do Produto
      ZFR->ZFR_QTDEPR	:= _nQtd                    // SC6->C6_QTDVEN 	       //	Quantidade do Produto
      ZFR->ZFR_QTDPEC   := _nQtdPecas               // Quantidade de pe�as  para UM = KG
      ZFR->ZFR_UNMED	   := _cUnidade                // If(SC6->C6_UM == "CX","1","2") // Unidade de Medida // "1 - Caixa e 2 - Unidade"
      ZFR->ZFR_NATOPE	:= AllTrim(SC6->C6_CF)	    //	Natureza de Opera��o
      ZFR->ZFR_PESOUN	:= _nPesoUnit               // SB1->B1_PESBRU	       //	Peso Unit�rio do Produto
      ZFR->ZFR_VOLUME	:= Ceiling(_nvolume)        //   Ceiling - esta fun��o arredonda para cima em numeros inteiros, o valor passado como par�metro.
      ZFR->ZFR_VLRPRO	:= _nPrecoVenda             //SC6->C6_PRCVEN 	       //	Valor Unit�rio do Produto

      If _cTipoCA == "2"                            // Enviar zeros no na qtd pallet capa e item. Trata-se de uma Carga Batida. N�o h� Pallets.
         ZFR->ZFR_QTDEPA := 0
      Else
         ZFR->ZFR_QTDEPA := _nqpalets               //	Quantidade de Pallet�s
      EndIf

      ZFR->ZFR_CUBADO	:= _ncubado
      ZFR->ZFR_PESOBR	:= _nPesoTot                // SB1->B1_PESBRU * SC6->C6_QTDVEN 	//	Peso Bruto
      ZFR->ZFR_USUARI	:= __CUSERID			       // Codigo do Usu�rio
      ZFR->ZFR_DATAAL	:= Date()			          // Data de Altera��o
      ZFR->ZFR_SITUAC	:= If(Empty(_cSituacao),"N",_cSituacao)//AWF-11/05/17 - Mudei para "N"		           // Situa��o do Registro = Aguardando Libera��o
      ZFR->ZFR_CODARM   := SC6->C6_LOCAL            // Codigo do Armazem.
      ZFR->ZFR_CODEMP	:= _cCodEmpWS			       // Codigo Empresa WebServer
      ZFR->ZFR_FLUXO    := "PROTHEUS ENVIA RDC"
      ZFR->ZFR_FATOPA   := _nFatConvPa              // Fator de conves�o de Pallets.
      ZFR->ZFR_REGCAP   := ZFQ->(Recno())

      If ZFR->(FIELDPOS("ZFR_DSCPRD")) > 0
         //-------------------
         ZFR->ZFR_DSCPRD:= SB1->B1_DESC
         ZFR->ZFR_GRPPRD:= SB1->B1_GRUPO
         ZFR->ZFR_DSCGRP:= AllTrim(Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))
         ZFR->ZFR_SEGUNI:= SC6->C6_SEGUM
         ZFR->ZFR_QTDSGU:= SC6->C6_UNSVEN
         ZFR->ZFR_QTDPAL:= SB1->B1_I_CXPAL
      EndIf

      ZFR->(MsUnLock())

      //==================================================================================
      // Este trecho verifica se h� endere�o de embarcador para este pedido de vendas.
      //==================================================================================

      If Empty(_cForEmbM)
         If ZG9->(DbSeek(xFilial("ZG9")+SC6->C6_FILIAL+SC6->C6_LOCAL))
            _cForEmbM  := ZG9->ZG9_CODFOR
            _cLojaEmbM := ZG9->ZG9_LOJFOR
            _cFilRDC   := ZG9->ZG9_FILRDC
         EndIf
      EndIf
      If Empty(_cPedCliente) .And. !Empty(Alltrim(SC6->C6_NUMPCOM))
         _cPedCliente := Alltrim(SC6->C6_NUMPCOM)
      EndIF


      SC6->(DbSkip())
   EndDo

   //==================================================================================
   // H� endere�o de embarcador para este item, ent�o, o endere�o da filial de origem
   // deve ser alterado para o endere�o do embarcador de mercadorias.
   //==================================================================================
   If !Empty(_cForEmbM) .And. !u_IT_TMS(SC5->C5_I_LOCEM) /*! _lWsTms*/ .And. Empty(_cSulfixo) // _lWsTms = .F. = TMS RDC
      //================================================================================
      // Os endere�os de clientes abaixo est�o com o nome da rua separada do numero,
      // e do complemento.
      //================================================================================
      _cEndereco    := ""
      _cNumero      := ""
      _cComplemento := ""
      _cIBGEFA      := ""
      _cBairro      := ""

      SA2->(DbSetOrder(1))
      If SA2->(DbSeek(xFilial("SA2")+_cForEmbM+_cLojaEmbM)) // Posiciona no embarcador das mercadorias
         _cEndereco    := SA2->A2_I_END
         _cNumero      := SA2->A2_I_NUM
         _cComplemento := SA2->A2_COMPLEM
         _cIBGEFA      := _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)
         _cBairro      := SA2->A2_BAIRRO

         If Empty(_cEndereco)
            _cEndereco    := SA2->A2_END
            _cNumero      := U_AOMS084N(SA2->A2_END)
            _cComplemento := SA2->A2_COMPLEM
            _cIBGEFA      := _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)
            _cBairro      := SA2->A2_BAIRRO
         EndIf
      EndIf

      ZFQ->(RecLock("ZFQ",.F.))
      ZFQ->ZFQ_BAIRRO := _cBairro       // SA2->A2_BAIRRO           // Bairro
      ZFQ->ZFQ_ENDERE := _cEndereco     // SA2->A2_END              // Endere�o da F�brica
      ZFQ->ZFQ_NUMERO := _cNumero       // U_AOMS084N(SA2->A2_END)  // N�mero do Endere�o da F�brica
      ZFQ->ZFQ_COMEND := _cComplemento  // "000"                    // Complemento do Endere�o
      ZFQ->ZFQ_IBGEFA := _cIBGEFA       // _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)
      If ! Empty(_cFilRDC)
         ZFQ->ZFQ_FILRDC := _cFilRDC
      EndIf

      //If AllTrim(ZFQ->ZFQ_FILRDC)  == "90"  // Solicita��o do Vanderlei 
      //   ZFQ->ZFQ_FILRDC :=  "9001"
      //EndIf 

      ZFQ->(MsUnLock())

   Else // _lWsTms = .T. = TMS MULTI EMBARCADOR DA MULTI SOFTWARE
      _cCNPJEX := "" // CNPJ do Expedidor
      _cCEPEXP := "" // Cep do Expedidor
      _cIBGEEX := "" // Municpio da Expedidor (C�digo IBGE)
      _cINSEXP := "" // Inscri��o Estadual Expedidor
      _cENDEXP := "" // Endere�o do Expedidor
      _cNUMEXP := "" // N�mero do Endere�o do Expedidor
      _cFANEXP := "" // Nome Fantasia Expedidor
      _cRAZEXP := "" // Raza��o Social Expedidor
      _cTIPPEX := "" // Tipo Pessoa Expedidor

      If ! Empty(_cForEmbM)
         SA2->(DbSetOrder(1))
         If SA2->(DbSeek(xFilial("SA2")+_cForEmbM+_cLojaEmbM)) // Posiciona no embarcador das mercadorias
            _cCNPJEX := SA2->A2_CGC     // CNPJ do Expedidor
            _cCEPEXP := SA2->A2_CEP     // Cep do Expedidor
            _cIBGEEX := _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)                                            // Municpio da Expedidor (C�digo IBGE)
            _cINSEXP := SA2->A2_INSCR   // Inscri��o Estadual Expedidor
            _cENDEXP := SA2->A2_I_END   // Endere�o do Expedidor
            _cNUMEXP := SA2->A2_I_NUM   // N�mero do Endere�o do Expedidor
            _cFANEXP := SA2->A2_NREDUZ  // Nome Fantasia Expedidor
            _cRAZEXP := SA2->A2_NOME    // Raza��o Social Expedidor
            _cTIPPEX := If(SA2->A2_TIPO=="P","Fisica","Juridica") // TipoPessoa

            If Empty(_cENDEXP)
               _cENDEXP := SA2->A2_END             // Endere�o do Expedidor
               _cNUMEXP := U_AOMS084N(SA2->A2_END) // N�mero do Endere�o do Expedidor
               _cIBGEEX      := _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)
            EndIf
            //--------------------------------------------
            /*
            A2_CONTRIB = 1 = Sim = Contribuinte ICMS
                       = 2 = N�o = N�o Contribuinte ICMS
            A2_INSCR   = ISENTO = Inscri��o Estadual
            */
            _cIndIEExp := ""
            If SA2->A2_CONTRIB == "1" .And. !Empty(SA2->A2_INSCR) .And. AllTrim(SA2->A2_INSCR) <> "ISENTO"
               _cIndIEExp := "ContribuinteICMS"    // "1" //Contribuinte ICMS
            ElseIf SA2->A2_CONTRIB == "1"
               _cIndIEExp := "ContribuinteIsento"  // "2" // Contibuinte Isento de Incri��o no Cad Contrib.ICM
            Else
               _cIndIEExp := "NaoContribuite"      // "9" //  N�o Contribuinte que pode ou n�o ter insci��o est.
            EndIf
//----------------------------------------------
            ZFQ->(RecLock("ZFQ",.F.))
            ZFQ->ZFQ_CNPJEX := _cCNPJEX  // CNPJ do Expedidor
            ZFQ->ZFQ_CEPEXP := _cCEPEXP  // Cep do Expedidor
            ZFQ->ZFQ_IBGEEX := _cIBGEEX  // Municpio da Expedidor (C�digo IBGE)
            ZFQ->ZFQ_INSEXP := _cINSEXP  // Inscri��o Estadual Expedidor
            ZFQ->ZFQ_ENDEXP := _cENDEXP  // Endere�o do Expedidor
            ZFQ->ZFQ_NUMEXP := _cNUMEXP  // N�mero do Endere�o do Expedidor
            ZFQ->ZFQ_FANEXP := _cFANEXP  // Nome Fantasia Expedidor
            ZFQ->ZFQ_RAZEXP := _cRAZEXP  // Raza��o Social Expedidor
            ZFQ->ZFQ_TIPPEX := _cTIPPEX  // Tipo Pessoa Expedidor
            //------------------------------
            ZFQ->ZFQ_INDIEE := _cIndIEExp
            //------------------------------
            If ! Empty(_cFilRDC)
               ZFQ->ZFQ_FILRDC := _cFilRDC
            EndIf

            //If AllTrim(ZFQ->ZFQ_FILRDC) == "90"  // Solicita��o do Vanderlei 
            //   ZFQ->ZFQ_FILRDC :=  "9001"
            //EndIf 

            ZFQ->(MsUnLock())
         EndIf
         SA2->(DbSetOrder(3))


      EndIf
   EndIf

   If ZFR->(FIELDPOS("ZFQ_NUMPCO")) > 0 .AND. !Empty(_cPedCliente)
      ZFQ->(RecLock("ZFQ",.F.))
      ZFQ->ZFQ_NUMPCO := _cPedCliente
      ZFQ->(MsUnLock())
   Endif
End Sequence

RestOrd(_aOrd)
SC6->(DbGoTo(_nRegSC6))

Return Nil


/*
===============================================================================================================================
Fun��o------------: AOMS084C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Efetua a leitura de todos os itens do pedido de vendas e efetua os seguintes c�lculos relacionados ao
                    pedido de vendas:
                    1) Somat�ria do campo:  C6_VALOR
                    2) Somat�ria do campo:  C6_I_QPALT
                    3) Somat�ria do volume: C6_PRODUTO ==> b5_ecaltem X b5_ecprofe X b5_eclarge X C6_QTDVEN

===============================================================================================================================
Parametros--------: _cCodPesq = Filial + numero do pedido de vendas
===============================================================================================================================
Retorno-----------: _aResult = Array com o resultado de todos os calaculos realizados pela fun��a.
                    _aResult[1] = Somat�ria do Valor Total do Item
                    _aResult[2] = Somat�ria da Quantidade de Pallet
                    _aResult[3] = Somat�ria do Volume
                    _aResult[4] = Tipo de Carga (Seca, Refrigerada ou N�o Definida)
===============================================================================================================================
*/
User Function AOMS084C(_cCodPesq)
Local _aRet := {}
Local _aOrd := SaveOrd({"SC6","SB5"})
Local _nSomaTot, _nSomaQPalet, _nSomaVolume
Local _lCargaRefrig, _cCarga
Local _cFilRDC := "", _cCodFil

Begin Sequence
   _nSomaTot     := 0
   _nSomaQPalet  := 0
   _nSomaVolume  := 0
   _cTipoCarga   := ""
   _lCargaRefrig := .F.
   _cCarga       := "1" // N�o definido

   _cCodFil := SubStr(_cCodPesq,1,2)

   //=============================================================
   // Obtem o c�digo da filial RDC
   //=============================================================
   _cFilRDC := Space(2)

   ZG9->(DbSetOrder(1)) // ZG9_FILIAL+ZG9_CODFIL+ZG9_ARMAZE
   SC6->(DbSetOrder(1))
   SC6->(DbSeek(_cCodPesq))
   Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == _cCodPesq

      If ZG9->(DbSeek(xFilial("ZG9")+SC6->C6_FILIAL+SC6->C6_LOCAL))
         _cFilRDC := ZG9->ZG9_FILRDC
         Exit
      EndIf

      SC6->(DbSkip())
   EndDo

   If Empty(_cFilRDC)
      _cFilRDC := Posicione("ZZM",1,xFilial("ZZM")+_cCodFil,"ZZM_FILRDC")
   EndIf

   //=============================================================
   // Obtem os valores dos itens de pedidos.
   //=============================================================

   SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
   SC6->(DbSetOrder(1))
   SC6->(DbSeek(_cCodPesq))
   Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == _cCodPesq
      _nSomaTot    += SC6->C6_VALOR
      _nSomaQPalet += SC6->C6_I_QPALT

      If SB5->(DbSeek(xFilial("SB5")+SC6->C6_PRODUTO))
         _nSomaVolume += (SB5->B5_ECALTEM * SB5->B5_ECPROFE * SB5->B5_ECLARGE * SC6->C6_QTDVEN)
      EndIf

      _cTipoCarga := Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_TIPCAR")

      If _cTipoCarga == "000001"
         If ! _lCargaRefrig
            If AllTrim(_cFilRDC) == "9001"  // CD-SP
               _cCarga := "5" // Carga Seca
            Else  // Demais filiais
               _cCarga := "1" // Carga Seca
            EndIf
         EndIf
      ElseIf _cTipoCarga == "000002"
         If AllTrim(_cFilRDC) == "9001"  // CD-SP
            _cCarga := "6"    // Carga Refrigerada
         Else  // Demais filiais
            _cCarga := "2"    // Carga Refrigerada
         EndIf
         _lCargaRefrig := .T.
      EndIf

      SC6->(DbSkip())
   EndDo

   If _nSomaQpalet > 99

     _nsomaQpalet := 99

   Elseif _nSomaQpalet < 1

     _nsomaqpalet := 1

   Endif

   _aRet := {_nSomaTot, _nSomaQPalet, iif(_nSomaVolume>0,_nSomaVolume,1), _cCarga}

End Sequence

RestOrd(_aOrd, .T.)

Return _aRet

/*
=================================================================================================================================
Programa--------: AOMS084V()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 26/10/2016
=================================================================================================================================
Descri��o-------: Exibe os dados do Pedido de Vendas posicionado na tela do MsBrowse.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS084V()
Local _aStrucZFR
Local _aCmpZFR := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _lInvZFR := .F.
Local _oDlgEnch, _nI
Local _nReg := 2 , _nOpcx := 2

Private _oMarkZFR, _cMarcaZFR := GetMark()
Private aHeader := {} , aCols := {}

Begin Sequence

//------------------------------------------------------------------------------------------------ <<<<<<<<<<
//============================================================================
   //Montagem do aheader
   //=============================================================================
   aHeader := {}
   FillGetDados(1,"ZFR",1,,,{||.T.},,,,,,.T.)

   //                          1                    2               3              4               5                6             7        8              9                 10
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})

   //================================================================================
   // Cria as estruturas das tabelas tempor�rias
   //================================================================================
   _aStrucZFR := {}
   //Aadd(_aStrucZFR,{"WKRECNO", "N", 10,0})
   For _nI := 1 To Len(aHeader)
       If AllTrim(aHeader[_nI,2])=="ZFR_FILIAL"
          Loop
       EndIf

       //                     Campo                 Titulo           Picture
       Aadd( _aCmpZFR , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )

       Aadd(_aStrucZFR,{aHeader[_nI,2], aHeader[_nI,8], aHeader[_nI,4] ,aHeader[_nI,5]})
   Next

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZFR") > 0
      TRBZFR->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZFR criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZFR",  _aStrucZFR )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZFR_ITEM"} )
   _otemp:Create()



//------------------------------------------------------------------------------------------------ <<<<<<<<<<
   //================================================================================
   // Carrega os dados da tabela ZFQ
   //================================================================================
   For _nI := 1 To ZFQ->(FCount())
       &("M->"+ZFQ->(FieldName(_nI))) :=  &("ZFQ->"+ZFQ->(FieldName(_nI)))
   Next

   //================================================================================
   // Carrega os dados da tabela ZFR
   //================================================================================
   ZFR->(DbSetOrder(5))  // ZFR_FILIAL+ZFR_NUMPED+ZFR_SITUAC
   ZFR->(DbSeek(ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)))
   Do While ! ZFR->(Eof()) .And. ZFR->(ZFR_FILIAL+ZFR_NUMPED) == ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)
      If ZFR->ZFR_REGCAP <> ZFQ->ZFQ_REGCAP
         ZFR->(DbSkip())
         Loop
      EndIf

      TRBZFR->(RecLock("TRBZFR",.T.))
      For _nI := 1 To TRBZFR->(FCount())
          If AllTrim(TRBZFR->(FieldName(_nI))) == "ZFR_ALI_WT"
             TRBZFR->ZFR_ALI_WT := "ZFR"
          ElseIf AllTrim(TRBZFR->(FieldName(_nI))) == "ZFR_REC_WT"
             TRBZFR->ZFR_REC_WT := ZFR->(Recno())
          Else
             &("TRBZFR->"+TRBZFR->(FieldName(_nI))) :=  &("ZFR->"+TRBZFR->(FieldName(_nI)))
          EndIf
      Next
      TRBZFR->(MsUnlock())

      ZFR->(DbSkip())
   EndDo
   TRBZFR->(DbGoTop())

   //================================================================================
   // Monta a tela Enchoice ZFQ  x MsSelect ZFR
   //================================================================================
   _aObjects := {}
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 }

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. )

   _bOk := {|| _oDlgEnch:End()}
   _bCancel := {|| _lRet := .F., _oDlgEnch:End()}

   _cTitulo := "Integra��o de Pedido de Vendas Via WebService - Visualiza��o"

   Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel

      EnChoice( "ZFQ" ,_nReg, _nOpcx, , , , , _aPosObj[1], , 3 )

      _oMarkZFR := MsSelect():New("TRBZFR","","",_aCmpZFR,@_lInvZFR, @_cMarcaZFR,{_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4]})

   Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel)

End Sequence

//================================================================================
// Fecha e exclui as tabelas tempor�rias
//================================================================================
If Select("TRBZFR") > 0
   TRBZFR->(DbCloseArea())
EndIf

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS084A()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 26/10/2016
=================================================================================================================================
Descri��o-------: Rotina de aprova��o de pedidos de vendas que poder�o ser integrados via webservice.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS084A()
Local _cTitulo
Local _bOk, _bCancel
Local _oDlgApr
Local _lRet := .T.
Local _nTamPedido := TAMSX3("C5_NUM")[1]

Private _dDtIni := Ctod("  /  /  "), _dDtFinal := Ctod("  /  /  ")
Private _cNrPedIni := Space(_nTamPedido)
Private _cNrPedFim := Space(_nTamPedido)

Begin Sequence
   //================================================================================
   // Tela de Aprova��o de Pedido de Vendas
   //================================================================================
   _cTitulo := "Aprova��o dos Pedidos de Vendas para Integra��o via WebService"
   _bOk := {|| If(U_AOMS084S("BOTAOOK"),(_lRet := .T., _oDlgApr:End()),)}
   _bCancel := {|| _lRet := .F., _oDlgApr:End()}

   Define MsDialog _oDlgApr Title _cTitulo From 9,0 To 22,55 Of oMainWnd

      @ 06,20 Say "Data Prev. Entrega Incial: " Of _oDlgApr Pixel
      @ 05,80 Get _dDtIni Size 30, 10 Of _oDlgApr Pixel

      @ 26,20 Say "Data Prev. Entrega Final: " Of _oDlgApr Pixel
      @ 25,80 Get _dDtFinal Size 30, 10 Of _oDlgApr Valid(U_AOMS084S("DATAFINAL")) Pixel

      @ 46,20 Say "Nr.Pedido Incial: " Of _oDlgApr Pixel
      @ 45,80 Get _cNrPedIni Size 30, 10 Of _oDlgApr Pixel

      @ 66,20 Say "Nr.Pedido Final: " Of _oDlgApr Pixel
      @ 65,80 Get _cNrPedFim Size 30, 10 Of _oDlgApr Valid(U_AOMS084S("NR_PEDIDO")) Pixel

   Activate MsDialog _oDlgApr On Init EnchoiceBar(_oDlgApr,_bOk,_bCancel) CENTERED

   //================================================================================
   // Altera a situa��o dos dados dos pedidos de vendas das tabelas de muro, de
   // "Aguardando Aprova��o" para "N�o Processados".
   //================================================================================
   If _lRet
       fwmsgrun(, {|oproc| U_AOMS084R(oproc) } , 'Aguarde!' , 'Alterando Registro para Situa��o "N�o Processados"...' )
   EndIf

End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS084S()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 31/10/2016
=================================================================================================================================
Descri��o-------: Valida a digita��o das Datas, na rotina de mudan�a da Situa��o do Pedido de Vendas de "Aguardando Aprova��o"
                  Para "N�o Processados".
=================================================================================================================================
Parametros------: _cChamada = Vari�vel ou bot�o que chamou a valida��o.
=================================================================================================================================
Retorno---------: .T. ou .F.
=================================================================================================================================
*/
User Function AOMS084S(_cChamada)
Local _lRet := .T.
Local _nI, _aUF := {}

Begin Sequence
   If _cChamada == "BOTAOOK"
      If Empty(_dDtIni) .Or. Empty(_dDtFinal)
         MsgStop("Informe um per�odo de datas.","Aten��o")
         _lRet := .F.
         Break
      EndIf

      If _dDtIni > _dDtFinal
         MsgStop("A data inicial n�o pode ser maior que a data final.","Aten��o")
         _lRet := .F.
         Break
      EndIf

      If _cNrPedIni > _cNrPedFim
         MsgStop("O numero de pedido de vendas inicial n�o pode ser maior que o numero de pdidos de vendas final.","Aten��o")
         _lRet := .F.
         Break
      EndIf
   EndIf

   If _cChamada == "DATAFINAL"
      If _dDtIni > _dDtFinal
         MsgStop("A data inicial n�o pode ser maior que a data final.","Aten��o")
         _lRet := .F.
         Break
      EndIf
   EndIf

   If _cChamada == "NR_PEDIDO"
      If _cNrPedIni > _cNrPedFim
         MsgStop("O numero de pedido de vendas inicial n�o pode ser maior que o numero de pdidos de vendas final.","Aten��o")
         _lRet := .F.
         Break
      EndIf
   EndIf

   If _cChamada == "UF_CLIENTE"
      If ! Empty(MV_PAR07)
         MV_PAR07 := Upper(MV_PAR07)
         Aadd(_aUF,"RO")
         Aadd(_aUF,"AC")
         Aadd(_aUF,"AM")
         Aadd(_aUF,"RR")
         Aadd(_aUF,"PA")
         Aadd(_aUF,"AP")
         Aadd(_aUF,"TO")
         Aadd(_aUF,"MA")
         Aadd(_aUF,"PI")
         Aadd(_aUF,"CE")
         Aadd(_aUF,"RN")
         Aadd(_aUF,"PB")
         Aadd(_aUF,"PE")
         Aadd(_aUF,"AL")
         Aadd(_aUF,"MG")
         Aadd(_aUF,"ES")
         Aadd(_aUF,"RJ")
         Aadd(_aUF,"SP")
         Aadd(_aUF,"PR")
         Aadd(_aUF,"SC")
         Aadd(_aUF,"RS")
         Aadd(_aUF,"MS")
         Aadd(_aUF,"MT")
         Aadd(_aUF,"GO")
         Aadd(_aUF,"DF")
         Aadd(_aUF,"SE")
         Aadd(_aUF,"BA")
         Aadd(_aUF,"EX")

         _nI := Ascan(_aUF,mv_par07)

         If _nI == 0
            MsgStop("Sigla de estado inv�lida. Informe uma sigla de estado v�lida.","Aten��o")
            _lRet := .F.
         EndIf
      EndIf
   EndIf

   If _cChamada == "PESO_FINAL"
      If ! Empty(mv_par08) .And. mv_par08 > mv_par09
         MsgStop("O peso inicial n�o pode ser maior que o peso final.","Aten��o")
         _lRet := .F.
      EndIf
   EndIf

End Sequence

Return _lRet

/*
=================================================================================================================================
Programa--------: AOMS084R()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 31/10/2016
=================================================================================================================================
Descri��o-------: Altera a situa��o dos dados dos pedidos de vendas das tabelas de muro, de "Aguardando Aprova��o"
                  para "N�o Processados".
=================================================================================================================================
Parametros------: oproc - objeto da barra de processamento
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS084R(oproc)
Local _cQry, _nTotRegs
Local _aOrd := SaveOrd({"ZFR","ZFQ"})
Local _aItensZFR, _nI
Default oproc := nil

Begin Sequence
   _cQry := " SELECT R_E_C_N_O_ AS NRRECNO FROM "+RetSqlName("ZFQ")+" ZFQ "
   _cQry += " WHERE ZFQ.D_E_L_E_T_ <> '*' AND ZFQ_SITUAC = 'A' "
   _cQry += " AND ZFQ_FILIAL = '" + xFilial("ZFQ") + "' "
   _cQry += " AND ZFQ_DTPREV >= '"+Dtos(_dDtIni)+"' AND ZFQ_DTPREV <= '"+Dtos(_dDtFinal)+"' "

   If ! Empty(_cNrPedIni)
      _cQry += " AND ZFQ_PEDIDO >= '"+_cNrPedIni+"' "
   EndIf

   If ! Empty(_cNrPedFim)
      _cQry += " AND ZFQ_PEDIDO <= '"+_cNrPedFim+"' "
   EndIf

   If Select("TRBZFQ") > 0
      TRBZFQ->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "TRBZFQ")
   DBSelectArea("TRBZFQ")

   Count To _nTotRegs

   If _nTotRegs == 0
      u_itmsg("Nenhum registro foi encontrado para o per�odo informado.","Aten��o",,1)
      Break
   EndIf

   TRBZFQ->(DbGoTop())

   ZFR->(DbSetOrder(5))

   Do While ! TRBZFQ->(Eof())
      ZFQ->(DbGoTo(TRBZFQ->NRRECNO))

      IF valtype(oproc) = "O"

           oproc:cCaption := ("Processando Pedido: "+ZFQ->ZFQ_PEDIDO)
           ProcessMessages()

        ENDIF

      ZFQ->(RecLock("ZFQ",.F.))
      ZFQ->ZFQ_SITUAC := "N"
      ZFQ->ZFQ_DATAP := DATE()
      ZFQ->ZFQ_HORAP := TIME()
      ZFQ->(MsUnlock())

      _aItensZFR := {}

      ZFR->(DbSeek(xFilial("ZFR")+ZFQ->ZFQ_PEDIDO+"A"))
      Do While ! ZFR->(Eof()) .And. ZFR->(ZFR_FILIAL+ZFR_NUMPED+ZFR_SITUAC) == ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO+"A" //xFilial("ZFR")+ZFQ->ZFQ_PEDIDO+"A"
         Aadd(_aItensZFR,ZFR->(Recno()))

         ZFR->(DbSkip())
      EndDo

      For _nI := 1 To Len(_aItensZFR)
          ZFR->(DbGoTo(_aItensZFR[_nI]))

          ZFR->(RecLock("ZFR",.F.))
          ZFR->ZFR_SITUAC := "N"
          ZFR->(MsUnlock())
      Next

      TRBZFQ->(DbSkip())
   EndDo

End Sequence

If Select("TRBZFQ") > 0
   TRBZFQ->(DbCloseArea())
EndIf

RestOrd(_aOrd,.T.) // Volta a ordem os indices das tabelas para ordem anterior e volta os ponteiros de registros das tabelas

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS084B()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 31/10/2016
=================================================================================================================================
Descri��o-------: Rotina de solicita��o de retorno do Pedido integrado para o Sistema RDC(Cancela Pedido).

=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS084B()
Local _cTexto := ""

Begin Sequence

   _cTexto := "Confirma a solicita��o de retorno do pedido de vendas ["+AllTrim(SC5->C5_NUM)+"], que foi integrado ao sistema TMS Multi Embarcador?"

   If ! u_itmsg(_cTexto,"Aten��o",,3,2,2)
      Break
   EndIf

   _cTexto := "Este pedido n�o se encontra integrado ao sistema TMS !"

   If SC5->C5_I_ENVRD <> "S"
      u_itmsg(_cTexto,"Aten��o",,1)
      Break
   EndIf

   //================================================================================
   // Realiza a integra��o do cancelamento do pedido de vendas selecionados e
   // atualiza tabelas de muro.
   //================================================================================
   If !u_IT_TMS(SC5->C5_I_LOCEM) 
      fwmsgrun(,{|oproc| U_AOMS094E(oproc)},'Aguarde processamento...','Integrando dados cancelamento Pedidos de Vendas...')
   Else
      fwmsgrun(,{|oproc| U_AOMS140E(oproc)},'Aguarde processamento...','Integrando dados cancelamento Pedidos de Vendas...')
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS084Y
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 05/12/2016
===============================================================================================================================
Descri��o---------: Reprocessa pedidos de vendas para envio ao RDC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084Y()

Local _nquant := 0

iF pergunte('AOMS084',.T.)

      cQueryi	:= " SELECT DISTINCT SC5.r_e_c_n_o_ reg "
      cQueryc	:= " SELECT count(*) quant "
      cQuery	:= " FROM  "+ RetSqlName('SC5') + " SC5 , "+ RetSqlName('SC6') + " SC6 "
      cQuery	+= " WHERE "+ RetSqlDel('SC5') + " AND " + RetSqlDel('SC6')
      cQuery	+= " AND SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM "
      cQuery	+= " AND SC5.C5_EMISSAO > '20170101' "
      cQuery	+= " AND SC5.C5_NOTA < '0000001' "
      cQuery	+= " AND SC5.C5_I_ENVRD <> 'S' AND  SC5.C5_I_ENVRD <> 'R'  AND  SC5.C5_I_ENVRD <> 'V' "
      cQuery	+= " AND NOT EXISTS (select sc9.c9_carga from "+ RetSqlName('SC9') + " sc9 where "+ RetSqlDel('SC9')
        cQuery	+= "                                                             and sc9.c9_pedido = sc5.c5_num
        cQuery	+= "                                                             and sc9.c9_filial = sc5.c5_filial AND SC9.C9_CARGA <> ' ')

        if !empty(mv_par02) .and. !empty(mv_par03)

           cQuery += " AND SC5.C5_I_DTENT BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"

        endif

        if !empty(alltrim(mv_par01))

           cQuery += " AND SC5.C5_FILIAL IN " + FormatIn(mv_par01,";")

      endif

      if !empty(mv_par04) .and. !empty(mv_par05)

           cQuery += " AND SC5.C5_NUM BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'"

        endif

        //Do Armazem
        If ! Empty(MV_PAR06)
           cQuery += " AND SC6.C6_LOCAL IN " + FormatIn(MV_PAR06,";")
        EndIf

        //UF Cliente
        If ! Empty(MV_PAR07)
           cQuery += " AND SC5.C5_I_EST = '"+MV_PAR07+"' "
        EndIf

        //Peso De
        If ! Empty(MV_PAR08)
           cQuery += " AND SC5.C5_I_PESBR >= " + AllTrim(Str(MV_PAR08,18,3))
        EndIf

        //Peso Ate
        If ! Empty(MV_PAR09)
           cQuery += " AND SC5.C5_I_PESBR <= " + AllTrim(Str(MV_PAR09,18,3))
        EndIf

      If Select("TRAB1") <> 0
         TRAB1->( DBCloseArea(  ) )
      EndIf

      MPSysOpenQuery( cQueryc + cQuery , "TRAB1")
      DBSelectArea("TRAB1")

      _nquant := TRAB1->QUANT

      If Select("TRAB1") <> 0
         TRAB1->( DBCloseArea(  ) )
      EndIf

      MPSysOpenQuery( cQueryi + cQuery , "TRAB1")
      DBSelectArea("TRAB1")

      IF _lScheduler

         //===============================================================================================================
         //Atualiza pedidos retornados de data anterior para pedidos a serem enviados para o RDC
         //===============================================================================================================

         u_itconout( '[AOMS084] -  - Importanto Pedidos Retornados...' )
         U_AOMS084K(@_nquant)
         u_itconout( '[AOMS084] -  - ' + strzero(_nquant,6) + ' pedidos processados...' )


         //===============================================================================================================

         //===============================================================================================================
         //Atualiza muro com pedidos selecionados
         //===============================================================================================================

         u_itconout( '[AOMS084] -  - Atualizando muro...' )
         U_AOMS084H(@_nquant)
         u_itconout( '[AOMS084] -  - ' + strzero(_nquant,6) + ' pedidos processados...' )

         //===============================================================================================================


      Else


         //===============================================================================================================
         //Atualiza pedidos retornados de data anterior para pedidos a serem enviados para o RDC
         //===============================================================================================================

         fwmsgrun(,{|oproc| U_AOMS084K(_nQuant,oproc)},'Aguarde processamento...','Atualizando Pedidos Retornados...')



         //===============================================================================================================

         //===============================================================================================================
         //Atualiza muro com pedidos selecionados
         //===============================================================================================================

         fwmsgrun(,{|oproc| U_AOMS084H(_nQuant,oproc)},'Aguarde processamento...',"Importando Pedidos..." )

         //===============================================================================================================

      Endif

Endif

IF !_lScheduler

   alert(strzero(_nquant,4) + " Pedidos importados com sucesso!")

Endif

Return

/*
===============================================================================================================================
Fun��o------------: AOMS084Z
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/12/2016
===============================================================================================================================
Descri��o---------: Reprocessa pedidos de vendas tendo como base as notas fiscais, para envio ao RDC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084Z()
Local _nQuant := 0
Local _cQueryI, _cQueryC, _cQuery

Begin Sequence

   If Pergunte('AOMS084',.T.)
      _cQueryI := " SELECT SC5.r_e_c_n_o_ reg "
     _cQueryC := " SELECT count(*) quant "
     _cQuery  := " FROM  "+ RetSqlName('SC5') + " SC5, " + RetSqlName('SF2') + " SF2 "
     _cQuery  += " WHERE "+ RetSqlDel('SC5') + " AND " + RetSqlDel('SF2')
     _cQuery  += " AND C5_FILIAL = F2_FILIAL AND C5_NUM = F2_I_PEDID "
     _cQuery  += " AND SC5.C5_I_ENVRD <> 'S' AND SC5.C5_I_ENVRD <> 'R'   AND SC5.C5_I_ENVRD <> 'V' "
     _cQuery  += " AND SC5.C5_NOTA <>  ' ' "

      If !Empty(mv_par02) .and. !Empty(mv_par03)

         _cQuery += " AND SF2.F2_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"

      EndIf

      If !Empty(alltrim(mv_par01))

         _cQuery += " AND SC5.C5_FILIAL IN " + FormatIn(mv_par01,";")

     EndIf

      If !Empty(mv_par04) .and. !Empty(mv_par05)

         _cQuery += " AND SC5.C5_NUM BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "'"

      EndIf

      If Select("TRAB1") <> 0
       TRAB1->( DBCloseArea() )
      EndIf

      MPSysOpenQuery( _cQueryC + _cQuery , "TRAB1")
      DBSelectArea("TRAB1")

      _nQuant := TRAB1->QUANT

     If Select("TRAB1") <> 0
        TRAB1->( DBCloseArea() )
      EndIf

      MPSysOpenQuery( _cQueryI + _cQuery , "TRAB1")
      DBSelectArea("TRAB1")//O MPSysOpenQuery() N�O DEIXA NA AREA NOVA

      fwmsgrun(,{|oproc| U_AOMS084K(_nQuant,oproc)},'Aguarde processamento...','Atualizando Pedidos Retornados...')

      fwmsgrun(,{|oproc| U_AOMS084H(_nQuant,oproc)},'Aguarde processamento...',"Importando Pedidos..." )

   EndIf

   u_itmsg("Total de " + StrZero(_nQuant,4) + " Pedidos importados com sucesso!","Processamento concluido",,2)

End Sequence

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS084k
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 05/12/2016
===============================================================================================================================
Descri��o---------: Grava Reprocessamento pedidos de vendas retornados para envio ao RDC
===============================================================================================================================
Parametros--------: nquant - quantidade de pedidos
               oproc - objeto de barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

user function AOMS084K(nquant,oproc)

Private ncont := 1, _nNaoIntegra := 0

Default nquant := 0

Default oproc := nil


_nTot:=0
_cTipoOper  := U_ITGETMV( 'IT_TIPOOPER' , '01;10;17;20;41;')
_cFilHabilit:= U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x RDC.

cQueryI  := " SELECT SC5.R_E_C_N_O_ REG "
cQuery	:= " FROM  "+ RetSqlName('SC5') + " SC5 "
cQuery	+= " WHERE "+ RetSqlDel('SC5')
cQuery	+= " AND SC5.C5_EMISSAO > '20170101' "
cQuery	+= " AND SC5.C5_NOTA < '0000001' "
cQuery   += " AND SC5.C5_I_ENVRD = 'R' "
cQuery   += " AND SC5.C5_I_DTRET < '" + DTOS(Date()) + "'"
cQuery   += " AND SC5.C5_FILIAL IN " + FormatIn(_cFilHabilit,";")
cQuery   += " AND SC5.C5_FILIAL IN " + FormatIn(_cFilHabilit,";")


If Select("TRABH") <> 0
   TRABH->( DBCloseArea(  ) )
EndIf

MPSysOpenQuery( cQueryI + cQuery , "TRABH")
DBSelectArea("TRABH")

Do while TRABH->( !Eof() )

   //posiciona sc5
   SC5->(Dbgoto(TRABH->REG))

   IF !_lScheduler

       IF valtype(oproc) = "O"

           oproc:cCaption := ("Gravando pedido " + strzero(ncont,4) + " de " + strzero(nquant,4))
           ProcessMessages()

        ENDIF

      ncont++

   Endif


   _nTot++

    If SC5->(MSRLOCK(SC5->(RECNO())))

       u_AOMS084P("N") //Grava tabela de muro

       Reclock("SC5",.F.)
       SC5->C5_I_HRRET := " "
       SC5->C5_I_DTRET := stod("")
       SC5->C5_I_ENVRD := "N"
       SC5->(Msunlock())
       SC5->(Msunlockall())

    Endif

    TRABH->(Dbskip())

Enddo


Return

/*
===============================================================================================================================
Fun��o------------: AOMS084H
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 05/12/2016
===============================================================================================================================
Descri��o---------: Grava Reprocessamento pedidos de vendas para envio ao RDC
===============================================================================================================================
Parametros--------: nquant - quantidade de pedidos
               oproc - objeto de barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084H(nquant,oproc)

Private ncont := 1, _nNaoIntegra := 0

Default nquant := 0

Default oproc := nil

_cDataA := DATE()
_cTimeA := TIME()

Do while TRAB1->( !Eof() )

   //posiciona sc5
   SC5->(Dbgoto(TRAB1->REG))

   IF !_lScheduler

      IF valtype(oproc) = "O"

           oproc:cCaption := ("Gravando pedido " + strzero(ncont,4) + " de " + strzero(nquant,4))
           ProcessMessages()

        ENDIF

      ncont++

   ENDIF

   u_AOMS084P("N") //Grava tabela de muro

   nquant++

   TRAB1->(Dbskip())

Enddo


Return

/*
===============================================================================================================================
Fun��o------------: AOMS084T
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/03/2017
===============================================================================================================================
Descri��o---------: Rotina de pesquisa de pedidos para integrados para o sistema RDC.
===============================================================================================================================
Parametros--------: _nRegAtu = Numero do registro do item posicionado.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084T(_nRegAtu)
Local _bOk, _bCancel
Local _oRadio, _nRadio := 1
Local _lRet := .F.

Private _oDlgPesq, _dDtEmiss, _cPedido, _oDtEmiss, _oPedido

Begin Sequence
   _bOk := {|| _lRet := .T., _oDlgPesq:End()}
   _bCancel := {|| _lRet := .F., _oDlgPesq:End()}

   _cTitulo := "Pesquisa da Integra��o do Pedidos de Vendas"
   _dDtEmiss := Ctod("  /  /  ")
   _cPedido  := Space(6)

   //================================================================================
   // Monta a tela de Pesquisa de Dados.
   //================================================================================
   Define MsDialog _oDlgPesq Title _cTitulo From 9,0 To 25,50 Of oMainWnd

      @ 03,08 Say " Ordem de Pesquisa " Pixel of _oDlgPesq
      @ 10,04 To 40,80 Pixel of _oDlgPesq
      @ 15,10 Radio _oRadio Var _nRadio Items "Por Data Emiss�o", "Por Pedido Vendas" Size 70,25 On Change U_AOMS084E(_nRadio) Pixel Of _oDlgPesq

      @ 50,10 Say "Data Emiss�o" Pixel of _oDlgPesq
      @ 50,70 Get _oDtEmiss  Var _dDtEmiss Picture "@d" Size 30,10 Pixel Of _oDlgPesq

      @ 70,10 Say "Nr.Pedido Vendas" Pixel of _oDlgPesq
      @ 70,70 Get _oPedido   Var _cPedido Picture "@!" Size 30,10 Pixel Of _oDlgPesq
      _oPedido:Disable()

      @ 90,040  Button "Pesquisar" Size 50,20  Of _oDlgPesq Pixel Action EVAL(_bOk)
      @ 90,105  Button "Sair"      Size 50,20  Of _oDlgPesq Pixel Action EVAL(_bCancel)

   Activate MsDialog _oDlgPesq CENTERED //On Init EnchoiceBar(_oDlgPesq,_bOk,_bCancel)

   If _lRet
      If _nRadio == 1
         If ! Empty(_dDtEmiss)
            TRBZFQ->(DbSetOrder(1))
            TRBZFQ->(DbSeek(DTos(_dDtEmiss)))
         Else
            MsgInfo("Para efetuar a pesquisa corretamente, preencha a data.","Aten��o")
         EndIf
      Else
         If ! Empty(_cPedido)
            TRBZFQ->(DbSetOrder(2))
            TRBZFQ->(DbSeek(_cPedido))
         Else
            MsgInfo("Para efetuar a pesquisa corretamente, preencha a data.","Aten��o")
         EndIf

      EndIf
   Else
      TRBZFQ->(DbGoTo(_nRegAtu))
   EndIf

   _oMarkZFQ:oBrowse:Refresh()

End Sequence

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS084E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/03/2017
===============================================================================================================================
Descri��o---------: Na mudan�a do bot�o de r�dio, habiita ou desabilita um determinado campo.
===============================================================================================================================
Parametros--------: _nRadio = Op��o de radio selecionada.
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function AOMS084E(_nRadio)

Begin Sequence
   If _nRadio == 1
      _oDtEmiss:Enable()
      _oPedido:Disable()
   Else
      _oDtEmiss:Disable()
      _oPedido:Enable()
   EndIf

   _oDlgPesq:Refresh()

End Sequence

Return .T.



/*
=================================================================================================================================
Programa--------: AOMS084F()
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 19/05/2017
=================================================================================================================================
Descri��o-------: Rotina de devolu��o de retorno do Pedido integrado para o Sistema RDC.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS084F()
Local _cTextoMsg

Begin Sequence

   _cTextoMsg := "Confirma a devolu��o do pedido de vendas ["+AllTrim(SC5->C5_NUM)+"], para o sistema TMS ?"

   If ! MsgYesNo(_cTextoMsg,"Aten��o")
      Break
   EndIf

   If SC5->C5_I_ENVRD = "S"
      _cTextoMsg := "Este pedido j� est� enviado ao sistema TMS !"

      MsgInfo(_cTextoMsg,"Aten��o")
      Break
   EndIf

   //================================================================================
   // Realiza a devolu��o do pedido de vendas selecionados e
   // atualiza tabelas de muro.
   //================================================================================

   Reclock("SC5",.F.)
   SC5->C5_I_ENVRD := "N"
   SC5->C5_I_DTRET := Stod("") // Data de retorno do pedido de vendas do RDC para o Protheus
   SC5->C5_I_HRRET := ""       // Hora de retorno do pedidod e vendas do RDC para o Protheus
   SC5->(MsUnlock())

   fwmsgrun(,{|oproc| U_AOMS084P(,oproc)},'Aguarde processamento...','Integrando dados devolu��o Pedidos de Vendas...' )

End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS084G()
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 16/08/2017
=================================================================================================================================
Descri��o-------: Identifica se � pedido s� com pallets ou n�o
=================================================================================================================================
Parametros------: Nenhum (Deve receber SC5 posicionada)
=================================================================================================================================
Retorno---------: _ctipo, "1" PARA PEDIDO NORMAL E "2" PARA PEDIDO DE PALLET
=================================================================================================================================
*/
Static Function AOMS084G()

Local _ctipo := "1"
Local _aarea := getarea("SC6")
Local _lachou := .T.

SC6->(Dbsetorder(1))

If  SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

  _lachou := .F.

  Do while SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM

    If posicione("SB1",1,xfilial("SB1")+SC6->C6_PRODUTO,"B1_TIPO") != "UN"

       _lachou := .T. //Marca se achar produto que n�o � pallet

    Endif

    SC6->(Dbskip())

  Enddo

Endif

SC6->(Restarea(_aarea))

If !_lachou //Se n�o achou produto que n�o � pallet marca o pedido como pedido de pallet

  _ctipo := "2"

Endif

Return _ctipo

/*
===============================================================================================================================
Programa----------: AOMS084Q
Autor-------------: Julio de Paula Paz
Data da Criacao---: 06/10/2023
===============================================================================================================================
Descri��o---------: Rotina de transmiss�o de dados webservice para o sistema TMS da Multi-Embarcador / Multsoftware.
                    Adiciona Pedido de Vendas e Carga no TMS (M�todo AdicionarCarga).
===============================================================================================================================
Parametros--------: oproc = Objeto de mensagens
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS084Q(oproc)
Local _cDirXML := ""
Local _cLink   := ""
Local _cCabXML := ""
Local _cItemXML := ""
Local _cDetA_1_XML := "", _cDetA_2_XML := "" //,_cDetA_3_XML := ""
Local _cDetC_XML := ""
Local _cRodXML := ""
Local _cDadosItens
Local _lItemSelect := .F.
Local _cEmpWebService := ""
Local _aOrd := SaveOrd({"ZFQ","ZFM","ZFR","SC9","SC5"})
Local _aUF := {}
Local _cDetA3Cab, _cDetA3Rod, _cDetA3GeF, _cDetA3GeJ, _cDetA3SuF, _cDetA3SuJ, _cDetA3VeF, _cDetA3VeJ
Local _cDetA3Ger, _cDetA3Sup, _cDetA3Ven

Local _cXML

Local _cResult := ""
Local _aRecnoItem, _nI
Local _lEnvXml
Local _cResposta, _cSituacao, _cReserva
Local _cForEmbM, _cLojaEmbM, _cFilRDC
Local _cIndIEExp,_cIndIEFor,_cIndIECli
Local lAchouSC5 := .F. 

Private _cToken
Private _cInscrCli // InscricaoEstadual
Private _cNomeFCli // NomeFantasia
Private _cRGIECl   // RGIE
Private _cRazaoCli // RazaoSocial
Private _cTipoPCli // TipoPessoa
Private _cCPFVend  // CPF
Private _cEmailVen // Email
Private _cNomeVend // Nome
Private _cRGVend   // RG
Private _cTelVend  // Telefone
Private _cGrupoProd // CodigoGrupoProduto
Private _cDescGrpP  // DescricaoGrupoProduto
Private _cDescProd  // DescricaoProduto
Private _cQtdPalEm  // QuantidadeCaixaPorPallet
Private _cQtdPorCx  // QuantidadePorCaixa
Private _cCepForn  // CEP
Private _cInscEst  // InscricaoEstadual
Private _cNFantFor // NomeFantasia
Private _cRgiForn   // RGIE
Private _cRazaoFor // RazaoSocial
Private _cTipoPFor // TipoPessoa
Private _cCondPag  // TipoPagamento

Default oproc := nil

Begin Sequence
   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================
   _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")

   //================================================================================
   // Verifica se h� itens selecionados e l� o c�digo da empresa de WebService.
   //================================================================================
   IF !_lScheduler
      IF valtype(oproc) = "O"
         oproc:cCaption := ("1/12 - Verificando itens selecionados...")
          ProcessMessages()
      ENDIF

      TRBZFQ->(DbGoTop())
      Do While ! TRBZFQ->(Eof())
         If ! Empty(TRBZFQ->WK_OK)
            //_cEmpWebService := TRBZFQ->ZFQ_CODEMP
            _lItemSelect := .T.
            Exit
         EndIf

         TRBZFQ->(DbSkip())
      EndDo

      If ! _lItemSelect
         u_itmsg("Nenhum item foi selecionado para integra��o Webservice. N�o ser� poss�vel realizar a integra��o Italac <---> MULTI-EMBARCADOR.","Aten��o",,1)
         Break
      EndIf
   Else
      TRBZFQ->(DbGoTop())//Todos est�o marcados
      //_cEmpWebService := TRBZFQ->ZFQ_CODEMP
   EndIf

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("2/12 - Identificando diret�rio dos XML...")
         ProcessMessages()
       EndIf
   EndIf

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirXML := ZFM->ZFM_LOCXML
      _cLink   := AllTrim(ZFM->ZFM_LINK01)
   Else
      IF _lScheduler
         u_itconout( "[AOMS084] - Empresa WebService para envio dos dados n�o localizada.")
      ELSE
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      ENDIF
      Break
   EndIf

   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lScheduler
         U_Itconout("[AOMS084] - Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
      Else
         U_Itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      EndIf
      Break
   EndIf

   _cDirXML := Alltrim(_cDirXML)
   If Right(_cDirXML,1) <> "\"
      _cDirXML := _cDirXML + "\"
   EndIf

   //================================================================================
   // L� os arquivos modelo XML e os transforma em String.
   //================================================================================
   If !_lScheduler
        If valtype(oproc) = "O"
           oproc:cCaption := ("3/12 - Lendo arquivo XML Modelo de Cabe�alho...")
           ProcessMessages()
      EndIf
   EndIf

   _cCabXML := U_AOMS084X(_cDirXML+"Cab_Pedido_TMS.txt")
   If Empty(_cCabXML)
      If _lScheduler
         U_Itconout("[AOMS084] - Erro na leitura do arquivo XML modelo do cabe�alhode envio Pedido de Vendas.")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo do cabe�alho de envio Pedido de Vendas. ","Aten��o",,1)
      EndIf
      Break
   EndIf
/*
   If !_lScheduler
        If Valtype(oproc) = "O"
           oproc:cCaption := ("3/8 - Lendo arquivo XML Modelo de Detalhe A...")
           ProcessMessages()
        EndIf
   EndIf

   _cDetA_XML := U_AOMS084X(_cDirXML+"Det_A_Pedido_TMS.TXT")
   If Empty(_cDetA_XML)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf
*/
  If !_lScheduler
        If Valtype(oproc) = "O"
           oproc:cCaption := ("4/12 - Lendo arquivo XML Modelo de Detalhe A_1...")
           ProcessMessages()
        EndIf
   EndIf

   _cDetA_1_XML := U_AOMS084X(_cDirXML+"Det_A_1_Pedido_TMS.TXT")
   If Empty(_cDetA_1_XML)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_1 de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
        If Valtype(oproc) = "O"
           oproc:cCaption := ("5/12 - Lendo arquivo XML Modelo de Detalhe A_2...")
           ProcessMessages()
        EndIf
   EndIf

   _cDetA_2_XML := U_AOMS084X(_cDirXML+"Det_A_2_EXPEDIDOR_Pedido_TMS.TXT")
   If Empty(_cDetA_2_XML)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_2_Expedidor de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
        If Valtype(oproc) = "O"
           oproc:cCaption := ("6/12 - Lendo arquivo XML Modelo de Detalhe A_3...")
           ProcessMessages()
        EndIf
   EndIf
//=================================================================================================================
/*  _cDetA_3_XML := U_AOMS084X(_cDirXML+"Det_A_3_Pedido_TMS.TXT")
   If Empty(_cDetA_3_XML)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf
*/
//=================================================================================================================
   _cDetA3Cab := U_AOMS084X(_cDirXML+"det_a_3_cab_pedido_tms.TXT")
   If Empty(_cDetA3Cab)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Cabe�alho de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf
//===========================
 _cDetA3Rod := U_AOMS084X(_cDirXML+"det_a_3_Rodape_pedido_tms.TXT")
   If Empty(_cDetA3Rod)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Rodap� de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf

//==================
 _cDetA3GeF := U_AOMS084X(_cDirXML+"det_a_3_FuncGerente_CPF_pedido_tms.TXT")
   If Empty(_cDetA3GeF)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Gerente CPF de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf

//===================
   _cDetA3GeJ := U_AOMS084X(_cDirXML+"det_a_3_FuncGerente_CNPJ_pedido_tms.TXT")
   If Empty(_cDetA3GeJ)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Gerente CNPJ de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf

//===================
   _cDetA3SuF := U_AOMS084X(_cDirXML+"det_a_3_FuncSupervisor_CPF_pedido_tms.TXT")
   If Empty(_cDetA3SuF)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Supervisor CPF de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf


//================
   _cDetA3SuJ := U_AOMS084X(_cDirXML+"det_a_3_FuncSupervisor_CNPJ_pedido_tms.TXT")
   If Empty(_cDetA3SuJ)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Supervisor CNPJ de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf

//================
   _cDetA3VeF := U_AOMS084X(_cDirXML+"det_a_3_FuncVendedor_CPF_pedido_tms.TXT")
   If Empty(_cDetA3VeF)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Vendedor CPF de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf

//================
   _cDetA3VeJ := U_AOMS084X(_cDirXML+"det_a_3_FuncVendedor_CNPJ_pedido_tms.TXT")
   If Empty(_cDetA3VeJ)
      U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe A_3 Vendedor CNPJ de envio Pedido de Vendas.","Aten��o",,1)
      Break
   EndIf

   If !_lScheduler
      If Valtype(oproc) = "O"
         oproc:cCaption := ("7/12 - Lendo arquivo XML Modelo de Item de Pedido...")
         ProcessMessages()
      EndIf
   EndIf
//=================================================================================================================

   _cItemXML := U_AOMS084X(_cDirXML+"Det_B_Itens_Pedido_TMS.TXT")
   If Empty(_cItemXML)
      If _lScheduler
         U_Itconout("[AOMS084] - Erro na leitura do arquivo XML modelo dos itens de envio Pedido de Vendas.")
      Else
         U_itmsg("Erro na leitura do arquivo XML modelo dos itens de envio Pedido de Vendas.","Aten��o",,1)
      EndIf
      Break
   EndIf

   If ! _lScheduler
        If valtype(oproc) = "O"
           oproc:cCaption := ("8/12 - Lendo arquivo XML Modelo de Detalhe B...")
         ProcessMessages()
       EndIf
   EndIf

   _cDetC_XML := U_AOMS084X(_cDirXML+"Det_C_Pedido_TMS.TXT")
   If Empty(_cDetC_XML)
      If _lScheduler
         U_Itconout("[AOMS084] - Erro na leitura do arquivo XML modelo do detalhe C de envio Pedido de Vendas..")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe C de envio Pedido de Vendas.","Aten��o",,1)
      EndIf
      Break
   EndIf

   If !_lScheduler
        If Valtype(oproc) = "O"
         oproc:cCaption := ("9/12 - Lendo arquivo XML Modelo de Rodap�...")
         ProcessMessages()
      EndIf
   EndIf

   _cRodXML := U_AOMS084X(_cDirXML+"Rodape_Pedido_TMS.txt")
   If Empty(_cRodXML)
      If _lScheduler
         u_itconout("[AOMS084] - Erro na leitura do arquivo XML modelo do rodap� de envio Pedido de Vendas.")
      Else
         u_itmsg("Erro na leitura do arquivo XML modelo do rodap� de envio Pedido de Vendas.","Aten��o",,1)
      EndIf
      Break
   EndIf

   //--------------------------------------------------------------------------------------------------
   // Verifica se o pedido j� tem libera��o, n�o permite a integra��o via Webservice e muda a situa��o
   // do registro na tabela de muro para "Liberado Manualmente".
   //--------------------------------------------------------------------------------------------------
   SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
   ZFR->(DbSetOrder(5))
   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
   SA1->(DbSetOrder(3)) // A1_FILIAL+A1_CGC
   SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
   SA3->(DbSetOrder(1)) // A3_FILIAL+A3_LOJA
   SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

   //=====================================================================================
   // Verifica se existe algum item para envio de XML que n�o foi liberado manualmente.
   //=====================================================================================
   _lEnvXml := .F.

   TRBZFQ->(DbGoTop())
   Do While ! TRBZFQ->(Eof())
      If ! Empty(TRBZFQ->WK_OK)
         _lEnvXml := .T.
         Exit
      EndIf

      TRBZFQ->(DbSkip())
   EndDo

   If ! _lEnvXml  // N�o h� dados para envio do XML.
      Break
   EndIf

   //================================================================================
   // Concatena os Pedidos de Vendas selecionados e monta array de XML com os dados.
   //================================================================================
   If !_lScheduler
        If Valtype(oproc) = "O"
           oproc:cCaption := ("10/12 - Montando dados de envio...")
           ProcessMessages()
      EndIf
   EndIf

   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.

   oWsdl:nTimeout := 90          // Timeout de 90 segundos
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo

   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da MULTI-EMBARCADOR.
   oWsdl:SetOperation( "AdicionarCarga") // Define qual opera��o ser� realizada.

   _aresult := {}

   ZFR->(DbSetOrder(5))
   SC9->(DbSetOrder(1))
   SA3->(DbSetOrder(1))
   SA2->(DbSetOrder(3))
   SA1->(DbSetOrder(3))
   SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
   ZG9->(DbSetOrder(1)) // ZG9_FILIAL+ZG9_CODFIL+ZG9_ARMAZE

   If Valtype(oproc) = "O"
      oproc:cCaption := ("11/12 - Enviando dados para MULTI-EMBARCADOR...")
      ProcessMessages()
   EndIf

   //================================================================================
   // Monta array dos estados
   //================================================================================
   _aUF := {}
   aadd(_aUF,{"RO","11"})
   aadd(_aUF,{"AC","12"})
   aadd(_aUF,{"AM","13"})
   aadd(_aUF,{"RR","14"})
   aadd(_aUF,{"PA","15"})
   aadd(_aUF,{"AP","16"})
   aadd(_aUF,{"TO","17"})
   aadd(_aUF,{"MA","21"})
   aadd(_aUF,{"PI","22"})
   aadd(_aUF,{"CE","23"})
   aadd(_aUF,{"RN","24"})
   aadd(_aUF,{"PB","25"})
   aadd(_aUF,{"PE","26"})
   aadd(_aUF,{"AL","27"})
   aadd(_aUF,{"MG","31"})
   aadd(_aUF,{"ES","32"})
   aadd(_aUF,{"RJ","33"})
   aadd(_aUF,{"SP","35"})
   aadd(_aUF,{"PR","41"})
   aadd(_aUF,{"SC","42"})
   aadd(_aUF,{"RS","43"})
   aadd(_aUF,{"MS","50"})
   aadd(_aUF,{"MT","51"})
   aadd(_aUF,{"GO","52"})
   aadd(_aUF,{"DF","53"})
   aadd(_aUF,{"SE","28"})
   aadd(_aUF,{"BA","29"})
   aadd(_aUF,{"EX","99"})

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   TRBZFQ->(DbGoTop())
   Do While ! TRBZFQ->(Eof())

      If ! Empty(TRBZFQ->WK_OK)
         ZFQ->(DbGoto(TRBZFQ->WKRECNO))
         If (SC5->(DbSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO))) 
            lAchouSC5 := .T. 
            If !U_IT_TMS(SC5->C5_I_LOCEM)
               TRBZFQ->(DbSkip())
               LOOP
            EndIf
         ELse
            lAchouSC5 := .F. 
         EndIf

         Begin Transaction

            U_Itconout( '[AOMS084] -  - Enviando pedido ' + ZFQ->ZFQ_PEDIDO + ' para multi-embarcador ...' )

            If Valtype(oproc) = "O"
               oproc:cCaption := ("12/12 - Enviando dados para MULTI-EMBARCADOR - Pedido " + ZFQ->ZFQ_PEDIDO + "..." )
               ProcessMessages()
            EndIf

            If !lAchouSC5 //Se n�o achar o pedido de vendas marca como enviado e n�o transmite
               ZFQ->(RecLock("ZFQ",.F.))
               ZFQ->ZFQ_SITUAC  := "P"
               ZFQ->ZFQ_DATAAL  := Date()
               ZFQ->ZFQ_RETORN  := "Eliminado por exclus�o do pedido no SC5"
               ZFQ->ZFQ_DATAP := DATE()
               ZFQ->ZFQ_HORAP := TIME()
               ZFQ->(MsUnlock())
               U_Itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' eliminado da muro por exclus�o ...' )
            ElseIf !Empty(SC5->C5_NOTA) //Se pedido j� tem nota n�o envia mais para MULTI-EMBARCADOR
               ZFQ->(RecLock("ZFQ",.F.))
               ZFQ->ZFQ_SITUAC  := "P"
               ZFQ->ZFQ_DATAAL  := Date()
               ZFQ->ZFQ_RETORN  := "Eliminado por SC5 j� possuir nota emitida"
               ZFQ->ZFQ_DATAP := DATE()
               ZFQ->ZFQ_HORAP := TIME()
               ZFQ->(MsUnlock())
               U_Itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' eliminado da muro por ter nota emitida ...' )
            Else
               //Verifica se consegue lockar o SC5
               If !(SC5->(Msrlock(SC5->(Recno()))))
                    //Se n�o conseguir lockar o SC5 desarma a transa��o e parte para o pr�ximo registro
                    Disarmtransaction()
                    TRBZFQ->(DbSkip())
                    u_itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' n�o enviado por lock na SC5 ...' )
               Else
                  //=======================================================================================
                  // Atualiza os Pedidos antigos da tabela ZFQ ante de transmitir dados no novo WebService
                  //=======================================================================================
                  If Empty(ZFQ->ZFQ_CODVEN) .Or. Empty(ZFQ->ZFQ_CODGER) .Or. Empty(ZFQ->ZFQ_CODCOO)
                     //========================================================
                     // Busca os dados dos Expedidor
                     //========================================================
                     _cForEmbM  := ""
                     _cLojaEmbM := ""
                     _cFilRDC   := ""

                     SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
                     Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->C5_FILIAL+SC5->C5_NUM
                        If Empty(_cForEmbM)
                           If ZG9->(DbSeek(xFilial("ZG9")+SC6->C6_FILIAL+SC6->C6_LOCAL))
                              _cForEmbM  := ZG9->ZG9_CODFOR
                              _cLojaEmbM := ZG9->ZG9_LOJFOR
                              _cFilRDC   := ZG9->ZG9_FILRDC
                              Exit
                           EndIf
                        EndIf

                        SC6->(DbSkip())

                     EndDo

                     _cCNPJEX := ""   // CNPJ do Expedidor
                     _cCEPEXP := ""   // Cep do Expedidor
                     _cIBGEEX := ""   // Municpio da Expedidor (C�digo IBGE)
                     _cINSEXP := ""   // Inscri��o Estadual Expedidor
                     _cENDEXP := ""   // Endere�o do Expedidor
                     _cNUMEXP := ""   // N�mero do Endere�o do Expedidor
                     _cFANEXP := ""   // Nome Fantasia Expedidor
                     _cRAZEXP := ""   // Raza��o Social Expedidor
                     _cTIPPEX := ""   // Tipo Pessoa Expedidor
                     _cIndIEExp := "" // Indicador Inscri��o Estadual Expedidor

                     If ! Empty(_cForEmbM)
                        SA2->(DbSetOrder(1))
                        If SA2->(DbSeek(xFilial("SA2")+_cForEmbM+_cLojaEmbM)) // Posiciona no embarcador das mercadorias
                           _cCNPJEX := SA2->A2_CGC     // CNPJ do Expedidor
                           _cCEPEXP := SA2->A2_CEP     // Cep do Expedidor
                           _cIBGEEX := _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)                                            // Municpio da Expedidor (C�digo IBGE)
                           _cINSEXP := SA2->A2_INSCR   // Inscri��o Estadual Expedidor
                           _cENDEXP := SA2->A2_I_END   // Endere�o do Expedidor
                           _cNUMEXP := SA2->A2_I_NUM   // N�mero do Endere�o do Expedidor
                           _cFANEXP := SA2->A2_NREDUZ  // Nome Fantasia Expedidor
                           _cRAZEXP := SA2->A2_NOME    // Raza��o Social Expedidor
                           _cTIPPEX := If(SA2->A2_TIPO=="P","Fisica","Juridica") // TipoPessoa

                           If Empty(_cENDEXP)
                              _cENDEXP := SA2->A2_END             // Endere�o do Expedidor
                              _cNUMEXP := U_AOMS084N(SA2->A2_END) // N�mero do Endere�o do Expedidor
                              _cIBGEEX := _aUF[aScan(_aUF,{|x| x[1] == SA2->A2_EST})][02] + SA2->A2_COD_MUN 	  // Municpio da F�brica (C�digo IBGE)
                           EndIf

                           If SA2->A2_CONTRIB == "1" .And. !Empty(SA2->A2_INSCR) .And. AllTrim(SA2->A2_INSCR) <> "ISENTO"
                              _cIndIEExp := "ContribuinteICMS" // "1" //Contribuinte ICMS
                           ElseIf SA2->A2_CONTRIB == "1"
                              _cIndIEExp := "ContribuinteIsento" // "2" // Contibuinte Isento de Incri��o no Cad Contrib.ICM
                           Else
                              _cIndIEExp := "NaoContribuite" // "9" //  N�o Contribuinte que pode ou n�o ter insci��o est.
                           EndIf

                        EndIf

                        SA2->(DbSetOrder(3))
                     EndIf

                     //========================================================
                     // Obtem dados do Vendedor
                     //========================================================
                     _cCodVend  := SC5->C5_VEND1
                     _cCPFVend  := ""    // CPF
                     _cEmailVen := ""    // Email
                     _cNomeVend := ""    // Nome
                     _cRGVend   := ""    // RG
                     _cTelVend  := ""    // Telefone

                     If SA3->(MsSeek(xFilial("SA3")+SC5->C5_VEND1))
                        _cCPFVend  := AllTrim(SA3->A3_CGC)  // CPF
                        _cEmailVen := AllTrim(SA3->A3_EMAIL)  // Email
                        _cNomeVend := AllTrim(SA3->A3_NOME)  // Nome
                        _cRGVend   := ""  // RG
                        _cTelVend  := SA3->A3_DDDTEL+Alltrim(SA3->A3_TEL) // Telefone
                     EndIf

                     //========================================================
                     // Obtem dados do Coordenador
                     //========================================================
                     _cCodCoord := SC5->C5_VEND2  // Cod. Coordenador
                     _cCPFCoord := ""    // CPF
                     _cEmailCoo := ""    // Email
                     _cNomeCoor := ""    // Nome
                     _cRGCoord  := ""    // RG
                     _cTelCoord := ""    // Telefone

                     If SA3->(MsSeek(xFilial("SA3")+SC5->C5_VEND2))
                        _cCPFCoord  := AllTrim(SA3->A3_CGC)    // CPF
                        _cEmailCoo := AllTrim(SA3->A3_EMAIL)  // Email
                        _cNomeCoor := AllTrim(SA3->A3_NOME)   // Nome
                        _cRGCoord  := ""  // RG
                        _cTelCoord := SA3->A3_DDDTEL+Alltrim(SA3->A3_TEL) // Telefone
                     EndIf

                     //========================================================
                     // Obtem dados do Gerente.
                     //========================================================
                     _cCodGeren  := SC5->C5_VEND3  // Cod. Gerente
                     _cCPFGeren  := ""    // CPF
                     _cEmailGer  := ""    // Email
                     _cNomeGeren := ""    // Nome
                     _cRGGeren   := ""    // RG
                     _cTelGeren  := ""    // Telefone

                     If SA3->(MsSeek(xFilial("SA3")+SC5->C5_VEND3))
                        _cCPFGeren  := AllTrim(SA3->A3_CGC)  // CPF
                        _cEmailGer := AllTrim(SA3->A3_EMAIL)  // Email
                        _cNomeGeren := AllTrim(SA3->A3_NOME)  // Nome
                        _cRGGeren   := ""  // RG
                        _cTelGeren  := SA3->A3_DDDTEL+Alltrim(SA3->A3_TEL) // Telefone
                     EndIf

                     //============================================================
                     // Obtem dados do Fornecedor
                     //============================================================
                     _cCepForn  := ""            // CEP
                     _cInscEst  := ""            // InscricaoEstadual
                     _cNFantFor := ""            // NomeFantasia
                     _cRgiForn  := ""            // RGIE
                     _cRazaoFor := ""            // RazaoSocial
                     _cTipoPFor := ""            // TipoPessoa
                     //_cCondPag  := AllTrim(Posicione('SE4',1,xFilial('SE4')+SC5->C5_CONDPAG,'E4_DESCRI'))
                     _cIndIEFor := ""            // Indicador Inscri��o Estadual Fornecedor

                     If SA2->(MsSeek(xFilial("SA2")+ZFQ->ZFQ_CNPJEM))
                        _cCepForn  := AllTrim(SA2->A2_CEP)                                                   // CEP
                        _cInscEst  := AllTrim(SA2->A2_INSCR)                                                 // InscricaoEstadual
                        _cNFantFor := AllTrim(SA2->A2_NREDUZ)                                                // NomeFantasia
                        _cRgiForn  := ""                                                                     // RGIE
                        _cRazaoFor := AllTrim(SA2->A2_NOME)                                                  // RazaoSocial
                        _cTipoPFor := If(SA2->A2_TIPO=="P","Fisica","Juridica")                              // TipoPessoa
                        //_cCondPag  := AllTrim(Posicione('SE4',1,xFilial('SE4')+SC5->C5_CONDPAG,'E4_DESCRI'))
                        _cCodForn  := SA2->A2_COD                                                            // Codigo Fornecedor
                        _cLojaForn := SA2->A2_LOJA                                                           // Loja do Fornecedor

                        If SA2->A2_CONTRIB == "1" .And. !Empty(SA2->A2_INSCR) .And. AllTrim(SA2->A2_INSCR) <> "ISENTO"
                           _cIndIEFor := "ContribuinteICMS"   // "1" //Contribuinte ICMS
                        ElseIf SA2->A2_CONTRIB == "1"
                           _cIndIEFor := "ContribuinteIsento" // "2" // Contibuinte Isento de Incri��o no Cad Contrib.ICM
                        Else
                           _cIndIEFor := "NaoContribuite"     // "9" //  N�o Contribuinte que pode ou n�o ter insci��o est.
                        EndIf

                     EndIf

                     //============================================================
                     // Obtem dados do Cliente
                     //============================================================
                     _cInscrCli := ""    // InscricaoEstadual
                     _cNomeFCli := ""    // NomeFantasia
                     _cRGIECl   := ""    // RGIE
                     _cRazaoCli := ""    // RazaoSocial
                     _cTipoPCli := ""    // TipoPessoa
                     _cCEPCli   := ""    // CEP

                     _cIndIECli := ""    // Indicador Inscri��o Estadual Cliente

                     If SA1->(MsSeek(xFilial("SA1")+ZFQ->ZFQ_CNPJDE))
                        _cInscrCli := AllTrim(SA1->A1_INSCR)                      // InscricaoEstadual
                        _cNomeFCli := AllTrim(SA1->A1_NREDUZ)                     // NomeFantasia
                        _cRGIECl   := AllTrim(SA1->A1_RG)                         // RGIE
                        _cRazaoCli := AllTrim(SA1->A1_NOME)                       // RazaoSocial
                        _cTipoPCli := If(SA1->A1_PESSOA=="P","Fisica","Juridica") // TipoPessoa
                        _cCEPCli   := AllTrim(SA1->A1_CEP)

                        If SA1->A1_CONTRIB == "1" .And. !Empty(SA1->A1_INSCR) .And. AllTrim(SA1->A1_INSCR) <> "ISENTO"
                           _cIndIECli := "ContribuinteICMS"   // "1" //Contribuinte ICMS
                        ElseIf SA2->A2_CONTRIB == "1"
                           _cIndIECli := "ContribuinteIsento" // "2" // Contibuinte Isento de Incri��o no Cad Contrib.ICM
                        Else
                           _cIndIECli := "NaoContribuite"     // "9" //  N�o Contribuinte que pode ou n�o ter insci��o est.
                        EndIf

                     EndIf

                     ZFQ->(RecLock("ZFQ",.F.))
                     ZFQ->ZFQ_CODVEN := _cCodVend  // Codigo Vendedor
                     ZFQ->ZFQ_CPFVEN := _cCPFVend  // CPF
                     ZFQ->ZFQ_MAILVE := _cEmailVen // Email
                     ZFQ->ZFQ_TELVEN := _cTelVend  // Telefone

                     ZFQ->ZFQ_CODGER := _cCodGeren // Cod. Gerente
                     ZFQ->ZFQ_CPFGER := _cCPFGeren // CPF
                     ZFQ->ZFQ_MAILGE := _cEmailGer // Email
                     ZFQ->ZFQ_TELGER := _cTelGeren // Telefone

                     ZFQ->ZFQ_CODCOO := _cCodCoord // Cod. Coordenador
                     ZFQ->ZFQ_CPFCOO := _cCPFCoord // CPF
                     ZFQ->ZFQ_MAILCO := _cEmailCoo // Email
                     ZFQ->ZFQ_TELCOO := _cTelCoord // Telefone

                     ZFQ->ZFQ_RAZFOR := _cRazaoFor // Raz�o Social Fornecedor
                     ZFQ->ZFQ_FANFOR := _cNFantFor // Nome Fantasia Fornecedor
                     ZFQ->ZFQ_CEPFOR := _cCepForn  // CEP Fornecedor
                     ZFQ->ZFQ_INSFOR := _cInscEst  // Inscri��o Estadual Fornecedor
                     ZFQ->ZFQ_TIPPEF := _cTipoPFor // Tipo de Pessoa Fornecedor
                     ZFQ->ZFQ_LOJFOR := _cLojaForn  // Loja do Fornecedor
                     ZFQ->ZFQ_CODFOR := _cCodForn   // Codigo Fornecedor
                     ZFQ->ZFQ_INDIEF := _cIndIEFor  // Indicador Inscri��o Estadual Fornecedor

                     ZFQ->ZFQ_RAZCLI := _cRazaoCli     // Raz�o Social Cliente
                     ZFQ->ZFQ_FANCLI := _cNomeFCli     // Nome Fantasia Cliente
                     ZFQ->ZFQ_CEPCLI := _cCEPCli       // CEP Cliente
                     ZFQ->ZFQ_INSCLI := _cInscrCli     // Inscri��o Estadual Cliente
                     ZFQ->ZFQ_TIPPEC := _cTipoPCli     // Tipo Pessoa Cliente
                     ZFQ->ZFQ_CODOPE := SC5->C5_I_OPER // Codigo de Opera��o
                     ZFQ->ZFQ_INDIEC := _cIndIECli     // Indicador Inscri��o Estadual Cliente

                     //=============================================================================
                     _cCanalVen := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_I_VBROK")

                     If ZFQ->(FIELDPOS("ZFQ_TPOPER")) > 0
                        If SC5->C5_I_OPER  == "20" .And. SC5->C5_I_TRCNF = 'N' // Transfer�ncia de Pedido de Vendas
                           ZFQ->ZFQ_TPOPER := "TRANSF_UNID"
                        ElseIf SC5->C5_I_TRCNF = 'S'
                           ZFQ->ZFQ_TPOPER := "TROCA_NF"
                        ElseIf !Empty(_cCanalVen) .And. _cCanalVen == "B"
                           ZFQ->ZFQ_TPOPER := "BROKER"
                        ElseIf SC5->C5_TPFRETE == "F" // FRETE = FOB
                           ZFQ->ZFQ_TPOPER := "FOB"
                        Else // Venda Direta = Venda Normal
                           ZFQ->ZFQ_TPOPER := "VD_DIR"
                        EndIf
                     EndIf
                     //=============================================================================

                     //Ajuste  para frete Fob ser enviado como agenda F para o RDC
                     If SC5->C5_I_OPER  == "20" .And. SC5->C5_I_TRCNF = 'N'
                        ZFQ->ZFQ_TPAGEN	:=	"T"
                     Else
                        //c5_i_oper = '20' e c5_i_trcnf = 'N' tipo = 'T'
                        If SC5->C5_TPFRETE == "F"
                           ZFQ->ZFQ_TPAGEN := "F"
                        Else
                           ZFQ->ZFQ_TPAGEN	:=	SC5->C5_I_AGEND
                        EndIf
                     EndIf

                     //---------------------------------
                     If ! Empty(_cForEmbM)
                        ZFQ->ZFQ_CNPJEX := _cCNPJEX   // CNPJ do Expedidor
                        ZFQ->ZFQ_CEPEXP := _cCEPEXP   // Cep do Expedidor
                        ZFQ->ZFQ_IBGEEX := _cIBGEEX   // Municpio da Expedidor (C�digo IBGE)
                        ZFQ->ZFQ_INSEXP := _cINSEXP   // Inscri��o Estadual Expedidor
                        ZFQ->ZFQ_ENDEXP := _cENDEXP   // Endere�o do Expedidor
                        ZFQ->ZFQ_NUMEXP := _cNUMEXP   // N�mero do Endere�o do Expedidor
                        ZFQ->ZFQ_FANEXP := _cFANEXP   // Nome Fantasia Expedidor
                        ZFQ->ZFQ_RAZEXP := _cRAZEXP   // Raza��o Social Expedidor
                        ZFQ->ZFQ_TIPPEX := _cTIPPEX   // Tipo Pessoa Expedidor
                        ZFQ->ZFQ_INDIEE := _cIndIEExp // Indicador Inscri��o Estadual Expedidor
                        //------------------------------
                        If ! Empty(_cFilRDC)
                           ZFQ->ZFQ_FILRDC := _cFilRDC
                        EndIf
                        
                        //If AllTrim(ZFQ->ZFQ_FILRDC)  == "90"  // Solicita��o do Vanderlei 
                        //   ZFQ->ZFQ_FILRDC :=  "9001"
                        //EndIf 

                     EndIf
                     //---------------------------------

                     ZFQ->(MsUnLock())
                  EndIf

                  //==============================================================
                  // Obtem dados do vendedor
                  //==============================================================
                  If SA3->(MsSeek(xFilial("SA3")+SC5->C5_VEND1))
                     _cCPFVend  := AllTrim(SA3->A3_CGC)  // CPF
                     _cEmailVen := AllTrim(SA3->A3_EMAIL)  // Email
                     _cNomeVend := AllTrim(SA3->A3_NOME)  // Nome
                     _cRGVend   := ""  // RG
                     _cTelVend  := "("+SA3->A3_DDDTEL+")"+Alltrim(SA3->A3_TEL) // Telefone
                  EndIf

                  //==============================================================
                  // Obtem dados do Cliente
                  //==============================================================
                  _cInscrCli := "" // InscricaoEstadual
                  _cNomeFCli := "" // NomeFantasia
                  _cRGIECl   := "" // RGIE
                  _cRazaoCli := "" // RazaoSocial
                  _cTipoPCli := "" // Tipo Pessoa

                  If SA1->(MsSeek(xFilial("SA1")+ZFQ->ZFQ_CNPJDE))
                     _cInscrCli := AllTrim(SA1->A1_INSCR)         // InscricaoEstadual
                     _cNomeFCli := AllTrim(SA1->A1_NREDUZ)        // NomeFantasia
                     _cRGIECl   := AllTrim(SA1->A1_RG)   // RGIE
                     _cRazaoCli := AllTrim(SA1->A1_NOME) // RazaoSocial
                     _cTipoPCli := If(SA1->A1_PESSOA=="P","Fisica","Juridica") // TipoPessoa
                  EndIf

                  //==============================================================
                  // Obtem dados do Fornecedor
                  //==============================================================
                  _cCepForn  := ""  // CEP
                  _cInscEst  := ""  // InscricaoEstadual
                  _cNFantFor := ""  // NomeFantasia
                  _cRgiForn  := ""  // RGIE
                  _cRazaoFor := ""  // RazaoSocial
                  _cTipoPFor := ""  // TipoPessoa
                  _cCondPag  := ""
                  _cCodForn  := ""
                  _cLojaForn := ""

                  If SA2->(MsSeek(xFilial("SA2")+ZFQ->ZFQ_CNPJEM))
                     _cCepForn  := AllTrim(SA2->A2_CEP)    // CEP
                     _cInscEst  := AllTrim(SA2->A2_INSCR)  // InscricaoEstadual
                     _cNFantFor := AllTrim(SA2->A2_NREDUZ) // NomeFantasia
                     _cRgiForn  := ""  // RGIE
                     _cRazaoFor := AllTrim(SA2->A2_NOME)  // RazaoSocial
                     _cTipoPFor := If(SA2->A2_TIPO=="P","Fisica","Juridica")  // TipoPessoa
                     _cCondPag  := AllTrim(Posicione('SE4',1,xFilial('SE4')+SC5->C5_CONDPAG,'E4_DESCRI'))
                     _cCodForn  := SA2->A2_COD            // Codigo Fornecedor
                     _cLojaForn := SA2->A2_LOJA           // Loja Fornecedor
                  EndIf
                  //-----------------------------------------------------------------------------------------
                  // Atualiza a situa��o e reserva do pedido de vendas, antes de enviar para o sistema MULTI-EMBARCADOR.
                  //-----------------------------------------------------------------------------------------
                  _cReserva := ""
                  If ! SC9->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
                     _cReserva := "1" // N�o tem reserva de estoque = Verde => Sem Reserva
                  Else
                     If U_Verest()
                        _cReserva := "2" // Conseguiu reservar estoque = Amarelo => Reservado
                     Else
                        _cReserva := "3" // N�o h� estoque dispon�vel  = Azul => Bloqueio de estoque
                     EndIf
                  EndIf

                  ZFQ->(RecLock("ZFQ",.F.))
                  ZFQ->ZFQ_RESERV := _cReserva
                  ZFQ->ZFQ_SITPED := U_STPEDIDO() // Status do Pedido, rotina no xfunoms
                  //ZFQ->ZFQ_DSCSIT := U_STPEDIDO(1) // Descricao Situacao Pedido
                  ZFQ->(MsUnlock())

                  //-----------------------------------------------------------------------------------------
                  // Realiza a integra��o dos pedidos de vendas (Envio de XML) via WebService.
                  //-----------------------------------------------------------------------------------------
                  ZFR->(DbSeek(ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)+"N"))

                  _aRecnoItem := {}
                  _cDadosItens := ""
                  Do While ! ZFR->(Eof()) .And. ZFR->(ZFR_FILIAL+ZFR_NUMPED+ZFR_SITUAC) = ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)+"N"

                     //============================================================
                     // Faz a atualiza��o dos itens para pedidos de vendas antigos
                     //============================================================
                     If Empty(ZFR->ZFR_GRPPRD)
                        ZFR->(RecLock("ZFR",.F.))
                        If SB1->(MsSeek(xFilial("SB1")+SubStr(ZFR->ZFR_CODIGO,1,11))) // C5_TPFRETE
                           ZFR->ZFR_DSCPRD   := SB1->B1_DESC
                           ZFR->ZFR_GRPPRD   := SB1->B1_GRUPO
                           ZFR->ZFR_DSCGRP   := AllTrim(Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))
                           ZFR->ZFR_QTDPAL   := SB1->B1_I_CXPAL
                        ENDIF

                        If SC6->(MsSeek(ZFR->ZFR_FILIAL+ZFR->ZFR_NUMPED+ZFR->ZFR_ITEM+SubStr(ZFR->ZFR_CODIGO,1,11))) //  C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
                           ZFR->ZFR_SEGUNI   := SC6->C6_SEGUM
                           ZFR->ZFR_QTDSGU   := SC6->C6_UNSVEN
                        EndIf
                        ZFR->(MsUnLock())
                     EndIF

                     _cDadosItens += &(_cItemXML)
                     Aadd(_aRecnoItem,ZFR->(Recno()))

                     ZFR->(DbSkip())
                  EndDo

                  //_cDetA3Cab, _cDetA3Rod, _cDetA3GeF, _cDetA3GeJ, _cDetA3SuF, _cDetA3SuJ, _cDetA3VeF, _cDetA3VeJ

                  If Len(AllTrim(ZFQ->ZFQ_CPFGER)) < 14 // Modelo de XML s� com o CPF do Gerente do Vendedor.
                     _cDetA3Ger := &(_cDetA3GeF)
                  Else                                  // Modelo de XML s� com o CNPJ do Gerente do Vendedor.
                     _cDetA3Ger := &(_cDetA3GeJ)
                  EndIf

                  If Len(AllTrim(ZFQ->ZFQ_CPFCOO)) < 14 // Modelo de XML s� com o CPF do Supervisor do Vendedor.
                     _cDetA3Sup := &(_cDetA3SuF)
                  Else                                  // Modelo de XML s� com o CNPJ do Supervisor do Vendedor.
                     _cDetA3Sup := &(_cDetA3SuJ)
                  EndIf

                  If Len(AllTrim(ZFQ->ZFQ_CPFVEN)) < 14  // Modelo de XML s� com o CPF do Vendedor.
                     _cDetA3Ven := &(_cDetA3VeF)
                  Else                                   // Modelo de XML s� com o CNPJ do Vendedor.
                     _cDetA3Ven := &(_cDetA3VeJ)
                  EndIf

                   //Monta XML
                   //_cXML := &(_cCabXML) + &(_cDetA_XML)+ _cDadosItens + &(_cDetC_XML) + _cRodXML  // Monta o XML de envio.
                  If ! Empty(ZFQ->ZFQ_CNPJEX) // Possui Expedidor preenchido. Inclui a Tag do Expedidor
                     //_cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_2_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML) + _cRodXML  // Monta o XML de envio.
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_2_XML) + &(_cDetA3Cab) + _cDetA3Ger + _cDetA3Sup + _cDetA3Ven + &(_cDetA3Rod) + _cDadosItens + &(_cDetC_XML) + _cRodXML  // Monta o XML de envio.
                  Else  // N�o possui Expedidor Preenchido. N�o Inclui a Tag Expedidor
                     //_cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML) + _cRodXML  // Monta o XML de envio.
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA3Cab) + _cDetA3Ger + _cDetA3Sup + _cDetA3Ven + &(_cDetA3Rod) + _cDadosItens + &(_cDetC_XML) + _cRodXML  // Monta o XML de envio.
                  EndIf

                   //Limpa & da string
                   _cXML := strtran(_cXML,"&"," ")

                  // Envia para o servidor
                  _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da MULTI-EMBARCADOR.

                  If _cOk
                     _cResult := oWsdl:GetParsedResponse() // Pega o resultado de envio j� no formato em string.
                  Else
                     _cResult := oWsdl:cError
                  EndIf

                  _cTextoPesq := Upper(_cResult)

                  _cCodMsg   := ""
                  _cTextoMsg := ""

                  If "CODIGOMENSAGEM" $ _cTextoPesq
                     _nI := At("CODIGOMENSAGEM",_cTextoPesq)
                     _cCodMsg := AllTrim(SubStr(_cResult,_nI, 20))

                     _nI := At(":",_cCodMsg)
                     _cCodMsg := AllTrim(SubStr(_cCodMsg,_nI+1, 3))
                  EndIf

                  If "MENSAGEM" $ _cTextoPesq
                     _nI := At("MENSAGEM",_cTextoPesq)       // Retorna a primeira ocorr�ncia da palavra MENSAGEM (CODIGOMENSAGEM:).
                     _nI := At("MENSAGEM",_cTextoPesq,_nI+5) // Retorna a segunda ocorr�ncia da palavra MENSAGEM (MENSAGEM:).

                     _nJ := At("OBJETO",_cTextoPesq)
                     _nNrPos := _nJ - (_nI + 2)
                     _cTextoMsg := AllTrim(SubStr(_cResult,_nI, _nNrPos))

                     If Upper(AllTrim(_cTextoMsg)) <> "MENSAGEM:" // Contem mensagem
                        _nI := At(":",_cTextoMsg)
                        _nJ := Len(_cTextoMsg)
                        _nNrPos := _nJ - (_nI + 1)

                        _cTextoMsg := AllTrim(SubStr(_cTextoMsg, _nI+1, _nNrPos))
                     Else
                        _cTextoMsg := "" // A TAG Mensagem est� vazia.
                     EndIf
                  EndIf

                  _cResposta := ""
                  _cSituacao := "P" // "Importado Com Sucesso"
                  _cCodRast  := ""
                  _cRespTxt  := StrTran(_cResult,Chr(13)+Chr(10),"")
                  _cRespTxt  := StrTran(_cResult,Chr(10),"")

                  If _cCodMsg == "200" // Integrado com Sucesso

                     //_nI := At("RASTREAMENTOPEDIDO",_cTextoPesq)
                     //_nJ := At("REMETENTE",_cTextoPesq)
                     //protocoloIntegracaoPedido
                     _nI := At("PROTOCOLOINTEGRACAOPEDIDO",_cTextoPesq)
                     _nJ := At("STATUS",_cTextoPesq)
                     _nNrPos := 1

                     _cCodRast := ""
                     If _nI > 0 .And. _nJ >0
                        _nNrPos := _nJ - _nI

                        _cRastreador := AllTrim(SubStr(_cResult,_nI, _nNrPos))

                        _cTextoPesq := Upper(_cRastreador)
                        _nJ := Len(AllTrim(_cTextoPesq))

                        //_nI := At("ENTREGA",_cTextoPesq)
                        _nI := At(":",_cTextoPesq)
                        _nNrPos := _nJ - (_nI + 1)
                        _cCodRast := AllTrim(SubStr(_cRastreador,_nI+1,_nNrPos))
                     EndIf

                     _cResposta := "Integrado com Sucesso - Nenhum problema encontrado, a requisi��o foi processada e retornou dados"

                  ElseIf _cCodMsg == "300" // Dados Inv�lidos
                     //_cSituacao := "R"
                     _cSituacao := "N"
                     _cResposta := "Dados Inv�lidos - " + AllTrim(_cRespTxt) // "Dados Inv�lidos - Algum dado da requisi��o n�o � v�lido, ou est� faltando"

                  ElseIf _cCodMsg == "400" // Falha Interna Web Service
                     _cSituacao := "N"
                     _cResposta := "Falha Interna Web Service - " + AllTrim(_cRespTxt) // "Falha Interna Web Service - Erro interno no processamento. Caso seja persistente, contatar o suporte da MultiSoftware"

                  ElseIf _cCodMsg == "500" // Duplicidade na Requisi��o
                     //_cSituacao := "P"
                     _cSituacao := "N"
                     _cResposta := "Duplicidade na Requisi��o - " + AllTrim(_cRespTxt)  // "Duplicidade na Requisi��o - A requisi��o j� foi feita, ou o registro j� foi inserido anteriormente"

                  Else
                     _cSituacao := "N"
                     _cResposta := AllTrim(StrTran(_cResult,Chr(10)," "))
                     _cResposta := Upper(_cResposta)
                  EndIf

                  If ! Empty(_cTextoMsg)
                     _cResposta := _cResposta + " " + _cTextoMsg
                  EndIf
/*
                  // "Importado Com Sucesso"
                  _cSituacao := "P"

                  If ! _cOk
                     _cSituacao := "N"
                  ElseIf !("IMPORTADO COM SUCESSO" $ _cResposta .OR. "REGISTRO EXISTE" $ _cResposta)
                      _cSituacao := "N"
                   EndIf
 */

                   //grava resultado // sempre como processado

                   ZFQ->(RecLock("ZFQ",.F.))
                  ZFQ->ZFQ_SITUAC  := _cSituacao // iif(_cok, "P", "N")

                  ZFQ->ZFQ_DATAAL  := Date()
                  ZFQ->ZFQ_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFQ,dizendo que deu certo ou n�o.
                  ZFQ->ZFQ_XML     := _cXML
                  ZFQ->ZFQ_XMLRET  := _cResult
                  ZFQ->ZFQ_RASTMS  := _cCodRast
                  ZFQ->ZFQ_DATAP   := DATE()
                  ZFQ->ZFQ_HORAP   := TIME()
                  ZFQ->(MsUnlock())

                  _lfalha := .F.  //Verifica se tem falha de processamento no loop a seguir

                  For _nI := 1 To Len(_aRecnoItem)
                      ZFR->(DbGoTo(_aRecnoItem[_nI]))

                      ZFR->(RecLock("ZFR",.F.))
                      ZFR->ZFR_SITUAC  := _cSituacao // iif(_cok, "P", "N")
                      ZFR->ZFR_DATAAL  := Date()
                      ZFR->ZFR_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFQ,dizendo que deu certo ou n�o.
                      ZFR->(MsUnlock())
                  Next

                  If _cSituacao == "P"
                     SC5->(RecLock("SC5",.F.))
                     SC5->C5_I_ENVRD := "S"
                     SC5->C5_I_CDTMS := _cCodRast //SC5->C5_RASTMS  := _cCodRast   // C�digo de rastreamento
                     SC5->(MsUnlock())
                     SC5->(Msunlockall())
                     U_Itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' enviado para multi-embarcador ...' )
                  Else
                     SC5->(Msunlock())
                     SC5->(Msunlockall())
                     U_Itconout( '[AOMS084] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' falhou envio para multi-embarcador ...' )
                  EndIf

                  Aadd(_aresult,{ZFQ->ZFQ_PEDIDO,ZFQ->ZFQ_CNPJEM,ZFQ->ZFQ_RETORN}) // adicona em um array para fazer um item list, exibir os resultados.
                  Sleep(100) //Espera para n�o travar a comunica��o com o webservice da MULTI-EMBARCADOR
               EndIf
            EndIf
         End Transaction
         SC5->(MSRUNLOCK(SC5->(Recno())))
      EndIf

      TRBZFQ->(DbSkip())
   EndDo

   _aCabecalho := {}
   Aadd(_aCabecalho,"PEDIDO" )
   Aadd(_aCabecalho,"CNPJ")
   Aadd(_aCabecalho,"RETORNO")

   _cTitulo := "Resultados da integra��o"

   If len(_aresult) > 0 .AND. !_lScheduler
      U_ITListBox( _cTitulo , _aCabecalho , _aresult  ) // Exibe uma tela de resultado.
     EndIf

End Sequence

RestOrd(_aOrd)

Return Nil


/*
ZFQ->ZFQ_TPAGEN	:=


<CanalEntrega>
<CodigoIntegracao>
C5_I_AGEND
A=AGENDADA;I=IMEDIATA;M=AGENDADA C/MULTA;P=AGUARD. AGENDA;R=REAGENDAR;N=REAGENDAR C/MULTA
</CanalEntrega>
</CodigoIntegracao>

*/
