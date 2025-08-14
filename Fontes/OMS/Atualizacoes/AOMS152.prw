/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=================================================================================================================================================================================================
Analista         - Programador       - Inicio     - Envio    - Chamado - Motivo da Altera��o
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Vanderlei Alves  - Julio Paz         - 14/03/25   - 10/06/25 - 50188   - Desenvolvimento de Rotina de Integra��o Webservice Protheus x TMS Multiembarcador Para Replicar Cargas Criadas no Protheus para o TMS Multiembarcador [OMS]
Vanderlei Alves  - Julio Paz         - 14/03/25   - 10/06/25 - 45229   - Webservice de Integra��o Protheus x TMS Multiembarcador.
Vanderlei Alves  - Julio Paz         - 12/06/25   - 13/06/25 - 45229   - Ajustes no novo webservice de integra��o Altera��o na Situa��o Comercial do Pedido de Vendas.
Lucas Borges     - Lucas Borges      - 01/08/25   - 01/08/25 - 51453   - Substituir fun��o EncodeUtf8 por FWHttpEncode
=================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#Include "FWMVCDef.Ch"

STATIC _lScheduler :=.F.

/*
===============================================================================================================================
Programa----------: AOMS152A()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/03/2025
===============================================================================================================================
Descri��o---------: Rotina de integra��o de Cargas Via Webservice para o sistema TMS Multiembarcador.
===============================================================================================================================
Parametros--------: _lSchedule = .T. = modo agendado.
                                 .F. = modo manual/menu.
                    _cOpcao    = "P" = Carga posicionada.
                               = "S" = Selecionar Cargas.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152A(_lSchedule,_cOpcao)
Local _nTotRegs := 0
Local _aParAux:= {}
Local _aParRet:= {}
Local _bQryFiltr
Local _aCargas 
Local _cCarga 
Local _cDAK_Cod 
Local _nI 
Local _dDataFilt := Date() - 730 // Data do dia, menos 2 anos.  

Begin Sequence 

   If ValType(_lSchedule) == "U"
      _lSchedule := .F.
   EndIf 
/*
   _lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F. ) 

   If ! _lWsTms
      If ! _lSchedule
         U_ItMsg("Esta rotina n�o est� habilitada para rodar nesta filial.","Aten��o",,1) 
      EndIf 

      Break 
   EndIf 
*/
//   If _lWsTms
      If ! _lSchedule
         If ! U_ITMSG("Confirma o reenvio da(s) Carga(s) para o Sistema TMS ?","Aten��o" , , ,2, 2)
            Break 
         EndIf
      EndIf  
//   EndIf 
   _cDAK_Cod := ""
   
   If _cOpcao == "P"
      //================================================================================
      // Grava os dados das tabelas ZFQ e ZFR para a carga posicionada.
      //================================================================================
      If _lSchedule
         AOMS152DAI()   // Grava os dados das tabelas ZFQ e ZFR para a carga posicionada.
      Else 
         Processa( {|| AOMS152DAI() } , 'Aguarde!' , 'Gravando Dados para Reenvio da Carga...' )
      EndIf 
      _cDAK_Cod := DAK->DAK_COD

   Else 
      //=================================================================================================
      // Grava os dados das tabelas ZFQ e ZFR para as cargas informadas pelo usu�rio na tela de filtro.
      //=================================================================================================
      If _lSchedule
         Break 
      EndIf 

      _bQryFiltr := {|| "SELECT DISTINCT DAK_COD, A1_NOME FROM "+ RETSQLNAME("DAK") + " DAK, "+ RETSQLNAME("DAI") + " DAI, "+RETSQLNAME("SA1") + " SA1 " +"WHERE DAK.D_E_L_E_T_ = ' '  AND DAI.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = '" + xFilial("DAK") + "' AND DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD AND DAI_CLIENT = A1_COD AND DAI_LOJA = A1_LOJA AND DAK.DAK_DATA >= '"+ Dtos(_dDataFilt) +"' ORDER BY DAK_COD DESC "}     
      _aItalac_F3 := {}
      Aadd(_aItalac_F3,{"MV_PAR01",_bQryFiltr,{|Tab| (Tab)->DAK_COD },{|Tab| (Tab)->A1_NOME }  ,/*_bCondSA1*/ ,"Cargas",,,,.F.        ,       , } )
     
      Aadd( _aParAux , { 1 , "Cargas"       		, MV_PAR01, "@!"    , ""  , "F3ITLC"  , "" , 100 , .F. } )
     
      If !ParamBox( _aParAux , "Selecione o filtro" , @_aParRet,  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
         Break 
      EndIf 
      _aCargas := StrTokArr2( MV_PAR01, ";", .T. )
      For _nI := 1 To Len(_aCargas)
          _cCarga := _aCargas[_nI]
          //==========================================================
          // Posiciona a carga para a grava��o das tabela ZFQ e ZFR.  
          //==========================================================
          DAK->(DbSetOrder(1))
          If DAK->(MsSeek(xFilial("DAK")+U_ItKey(_cCarga,"DAK_COD")))
             Processa( {|| AOMS152DAI() } , 'Aguarde!' , 'Gravando Dados para Reenvio da Carga...' )
             _cDAK_Cod += If(!Empty(_cDAK_Cod),";","") + DAK->DAK_COD
          EndIf 
      Next 
   EndIf 

   _cQry2 := " SELECT ZFQ.R_E_C_N_O_ ZFQ_RECNO,ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT " 
   _cQry2 += " FROM "+ RETSQLNAME("ZFQ") + " ZFQ "
   _cQry2 += " WHERE ZFQ.D_E_L_E_T_ <> '*' "
   _cQry2 += " AND ZFQ_SITUAC = 'C' "  
   _cQry2 += " AND ZFQ_NCARGA IN " + FormatIn(_cDAK_Cod,";")

   _cQry2 += " ORDER BY ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT "
   
   If Select("QRYZFQ") > 0
      QRYZFQ->( DBCloseArea() )
   EndIf

   MPSysOpenQuery( _cQry2 , "QRYZFQ") 

   DbSelectArea("QRYZFQ")

   Count To _nTotRegs 

   QRYZFQ->(DbGotop())
   
   If ! _lSchedule
      ProcRegua(_nTotRegs)
   EndIf 

   //====================================================================
   // Inicia Transmiss�o dos Dados Troca Nota para o TMS Multiembarcador
   //====================================================================
   If _lSchedule
      U_AOMS152B()
   Else 
      Processa( {|| U_AOMS152B() } , 'Aguarde!' , 'Reenviando a Carga para o Sistema TMS...' )
   EndIf 

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS152B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 06/10/2023
===============================================================================================================================
Descri��o---------: Rotina de transmiss�o de dados webservice da carga para o sistema TMS da Multi-Embarcador / Multsoftware.
===============================================================================================================================
Parametros--------: oproc = Objeto de mensagens
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152B(oproc)
Local _cDirXML := ""
Local _cLink   := ""
Local _cCabXML := ""
Local _cItemXML := ""
Local _cDetA_1_XML := ""
Local _cDetA_2_XML := ""
Local _cDetA_3_XML := ""
Local _cDetC_XML   := ""
Local _cRodXML := "" 
Local _cDadosItens
Local _cEmpWebService := ""
Local _aOrd := SaveOrd({"ZFQ","ZFM","ZFR","SC9","SC5"})
Local _aUF := {}
Local _cXML 
Local _cSitEnv
Local _cResult := ""
Local _aRecnoItem
Local _nI
Local _aRet := {.F.,"","","",""}

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
   _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000006")

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
         u_itconout( "[AOMS140] - Empresa WebService para envio dos dados n�o localizada.")
      ELSE
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      ENDIF
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lScheduler
         U_Itconout("[AOMS140] - Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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

   _cCabXML := U_AOMS140X(_cDirXML+"Cab_Pedido_TMS.txt") 
   If Empty(_cCabXML)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo do cabe�alhode envio Pedido de Vendas.")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo do cabe�alho de envio Pedido de Vendas. ","Aten��o",,1)
      EndIf
      Break
   EndIf

   If !_lScheduler
  		If Valtype(oproc) = "O"
  			oproc:cCaption := ("4/12 - Lendo arquivo XML Modelo de Detalhe A_1...")
  			ProcessMessages()
  		EndIf 
   EndIf 

   //_cDetA_1_XML := U_AOMS140X(_cDirXML+"det_a_1_pedido_troca_nf_tms.TXT") // "Det_A_1_Pedido_TMS.TXT")
   _cDetA_1_XML := U_AOMS140X(_cDirXML+"det_a_1_pedido_reenvio_troca_nf_tms.txt") 
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

   _cDetA_2_XML := U_AOMS140X(_cDirXML+"Det_A_2_EXPEDIDOR_Pedido_TMS.TXT")
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

   _cDetA_3_XML := U_AOMS140X(_cDirXML+"det_a_3_pedido_troca_nf_tms.TXT")
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

   _cItemXML := U_AOMS140X(_cDirXML+"Det_B_Itens_Pedido_TMS.TXT")
   If Empty(_cItemXML)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo dos itens de envio Pedido de Vendas.")
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
       
   //_cDetC_XML := U_AOMS140X(_cDirXML+"det_c_pedido_troca_nf_tms.TXT")
   _cDetC_XML := U_AOMS140X(_cDirXML+"det_c_pedido_reenvio_troca_nf_tms.txt")
   
   If Empty(_cDetC_XML)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo do detalhe C de envio Pedido de Vendas..")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe C de envio Pedido de Vendas.","Aten��o",,1)
      EndIf 
      Break
   EndIf            

   _cDetC2_XML := U_AOMS140X(_cDirXML+"det_c_2_pedido_troca_nf_placas_tms.TXT")
   
   If Empty(_cDetC2_XML)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo do detalhe C 2 de envio Pedido de Vendas..")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe C 2 de envio Pedido de Vendas.","Aten��o",,1)
      EndIf 
      Break
   EndIf       

   _cDetC3_XML := U_AOMS140X(_cDirXML+"det_c_3_pedido_troca_nf_placas_tms.TXT")
   
   If Empty(_cDetC3_XML)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo do detalhe C 3 de envio Pedido de Vendas..")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe C 3 de envio Pedido de Vendas.","Aten��o",,1)
      EndIf 
      Break
   EndIf   

   _cDetC4_XML := U_AOMS140X(_cDirXML+"det_c_4_pedido_troca_nf_placas_tms.TXT")
   
   If Empty(_cDetC4_XML)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo do detalhe C 4 de envio Pedido de Vendas..")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo do detalhe C 4 de envio Pedido de Vendas.","Aten��o",,1)
      EndIf 
      Break
   EndIf   
   
   If !_lScheduler
  		If Valtype(oproc) = "O"
   		oproc:cCaption := ("9/12 - Lendo arquivo XML Modelo de Rodap�...")
   		ProcessMessages()
   	EndIf 
   EndIf  
          
   _cRodXML := U_AOMS140X(_cDirXML+"rodape_pedido_troca_nf_tms.txt")
   If Empty(_cRodXML)
      If _lScheduler
         u_itconout("[AOMS140] - Erro na leitura do arquivo XML modelo do rodap� de envio Pedido de Vendas.")
      Else
         u_itmsg("Erro na leitura do arquivo XML modelo do rodap� de envio Pedido de Vendas.","Aten��o",,1)
      EndIf 
      Break
   EndIf

   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
   SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

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
   
   //_aPedFat := {}
   //_aRatFat := {}
   _aPVCargas := {}

   ZFQ->(DbSetOrder(3)) // ZFQ_FILIAL+ZFQ_PEDIDO+ZFQ_SITUAC+DTOS(ZFQ_DATA)  

   QRYZFQ->(DbGoTop())                                                                   
   Do While ! QRYZFQ->(Eof())

      ZFQ->(DbGoto(QRYZFQ->ZFQ_RECNO))
      DAK->(DbSetOrder(1)) //DAK->(DbSetOrder(1)) // DAK->(DbSetOrder(7))
      
      If ! DAK->(MsSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_NCARGA)) // ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_CARTMS
         QRYZFQ->(DbSkip())
         Loop 
      EndIf 

      //==================================================================
      // Inicia a montagem dos dados e transmiss�o do XML.
      //==================================================================

      Begin Transaction  
         	
         U_Itconout( '[AOMS140] -  - Enviando pedido ' + ZFQ->ZFQ_PEDIDO + ' para multi-embarcador ...' )
         	
         If Valtype(oproc) = "O"
         	oproc:cCaption := ("12/12 - Enviando dados para MULTI-EMBARCADOR - Pedido " + ZFQ->ZFQ_PEDIDO + "..." )
         	ProcessMessages()
   		EndIf          	
         	
         If !(SC5->(DbSeek(ZFQ->ZFQ_FILIAL+U_ItKey(ZFQ->ZFQ_PEDIDO,"C5_NUM")))) //Se n�o achar o pedido de vendas marca como enviado e n�o transmite
            ZFQ->(RecLock("ZFQ",.F.))
            ZFQ->ZFQ_SITUAC  := "P"
            ZFQ->ZFQ_DATAAL  := Date()
            ZFQ->ZFQ_RETORN  := "Eliminado por exclus�o do pedido no SC5"
            ZFQ->ZFQ_DATAP   := DATE()
            ZFQ->ZFQ_HORAP   := TIME()
            ZFQ->(MsUnlock())
            U_Itconout( '[AOMS140] -  - Pedido ' + ZFQ->ZFQ_PEDIDO + ' eliminado da muro por exclus�o ...' )
         Else  
            //-----------------------------------------------------------------------------------------
            // Realiza a integra��o dos pedidos de vendas (Envio de XML) via WebService.
            //-----------------------------------------------------------------------------------------
            _cSitEnv := "C"
            ZFR->(DbSetOrder(5))  // Alguma rotina est� alterando a situa��o da ZFQ, de "T" para "N".
            If ! ZFR->(DbSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO+_cSitEnv)) 
               _cSitEnv := "N"
               ZFR->(DbSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO+_cSitEnv)) 
            EndIf 

            _aRecnoItem := {}
            _cDadosItens := ""
            Do While ! ZFR->(Eof()) .And. ZFR->(ZFR_FILIAL+ZFR_NUMPED+ZFR_SITUAC) = ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)+_cSitEnv  
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
                  EndIf 
                        
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

            If ! Empty(_cDadosItens) 
              	//Monta XML
 		         If ! Empty(ZFQ->ZFQ_CNPJEX) // Possui Expedidor preenchido. Inclui a Tag do Expedidor             
            
                  If ZFQ->ZFQ_TIPVEI == "1" // Carreta
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_2_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML) + &(_cDetC2_XML) + _cRodXML  // Monta o XML de envio.
                  ElseIf ZFQ->ZFQ_TIPVEI == "3" // Bi-Trem
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_2_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML) + &(_cDetC3_XML) + _cRodXML  // Monta o XML de envio.
                  ElseIf ZFQ->ZFQ_TIPVEI == "5" // Rodo-Trem
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_2_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML) + &(_cDetC4_XML) + _cRodXML  // Monta o XML de envio.
                  Else // Caminh�o e Utilit�rio
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_2_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML) + _cRodXML  // Monta o XML de envio.
                  EndIf

               Else  // N�o possui Expedidor Preenchido. N�o Inclui a Tag Expedidor
                  If ZFQ->ZFQ_TIPVEI == "1" // Carreta
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML)+ &(_cDetC2_XML) + _cRodXML  // Monta o XML de envio.
                  ElseIf ZFQ->ZFQ_TIPVEI == "3" // Bi-Trem
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML)+ &(_cDetC3_XML) + _cRodXML  // Monta o XML de envio.
                  ElseIf ZFQ->ZFQ_TIPVEI == "5" // Rodo-Trem
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML)+ &(_cDetC4_XML) + _cRodXML  // Monta o XML de envio.
                  Else // Caminh�o e Utilit�rio
                     _cXML := &(_cCabXML) + &(_cDetA_1_XML) + &(_cDetA_3_XML) + _cDadosItens + &(_cDetC_XML) + _cRodXML  // Monta o XML de envio.  
                  EndIf 
               EndIf 
 		    
 		         // Limpa & da string
 		         _cXML := strtran(_cXML,"&"," ")

		         // Envia para o servidor
               _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da MULTI-EMBARCADOR.  
            
               If _cOk 
                  _cResult  := oWsdl:GetSoapResponse()
               Else
                  _cResult := oWsdl:cError
               EndIf   
                  
               _cTextoPesq := Upper(_cResult)

               _cCodMsg   := ""
               _cTextoMsg := ""
               _cProtIntP := ""
               _cProtIntC := ""

               _cError   := ""
               _cWarning := ""

               If "CODIGOMENSAGEM" $ _cTextoPesq
                  _oXml     := XmlParser(_cResult, "_", @_cError, @_cWarning ) 
                  _cCodMsg  := _oXml:_S_ENVELOPE:_S_BODY:_ADICIONARCARGARESPONSE:_ADICIONARCARGARESULT:_A_CODIGOMENSAGEM:TEXT
               EndIf

               If "MENSAGEM" $ _cTextoPesq
                  _cTextoMsg := _oXml:_S_ENVELOPE:_S_BODY:_ADICIONARCARGARESPONSE:_ADICIONARCARGARESULT:_A_MENSAGEM:TEXT // _A_CODIGOMENSAGEM:TEXT
               EndIf

               If "PROTOCOLOINTEGRACAOCARGA" $ _cTextoPesq // "PROTOCOLOINTEGRACAOPEDIDO" $ _cTextoPesq
                  _cProtIntC := _oXml:_S_ENVELOPE:_S_BODY:_ADICIONARCARGARESPONSE:_ADICIONARCARGARESULT:_A_OBJETO:_B_PROTOCOLOINTEGRACAOCARGA:TEXT // _B_PROTOCOLOINTEGRACAOPEDIDO:TEXT
               EndIf 

               If "PROTOCOLOINTEGRACAOPEDIDO" $ _cTextoPesq // "PROTOCOLOINTEGRACAOPEDIDO" $ _cTextoPesq
                  _cProtIntP := _oXml:_S_ENVELOPE:_S_BODY:_ADICIONARCARGARESPONSE:_ADICIONARCARGARESULT:_A_OBJETO:_B_PROTOCOLOINTEGRACAOPEDIDO:TEXT // _B_PROTOCOLOINTEGRACAOPEDIDO:TEXT
               EndIf

               _cResposta := ""
               _cSituacao := "P" // "Importado Com Sucesso"
               _cCodRast  := ""
               _cRespTxt  := StrTran(_cResult,Chr(13)+Chr(10),"")
               _cRespTxt  := StrTran(_cResult,Chr(10),"")
               
               If _cCodMsg == "200" // Integrado com Sucesso 
                  _cResposta := "Integrado com Sucesso - Nenhum problema encontrado, a requisi��o foi processada e retornou dados." + "-" + AllTrim(_cTextoMsg)

               ElseIf _cCodMsg == "300" // Dados Inv�lidos                     
                  _cSituacao := "R" // "N"
                  _cResposta := "Dados Inv�lidos - " + _cCodMsg + "-" + AllTrim(_cTextoMsg) // + "-" + AllTrim(_cRespTxt) // "Dados Inv�lidos - Algum dado da requisi��o n�o � v�lido, ou est� faltando"

               ElseIf _cCodMsg == "400" // Falha Interna Web Service
                  _cSituacao := "R" // "N"
                  _cResposta := "Falha Interna Web Service - " + _cCodMsg + "-" +AllTrim(_cTextoMsg) //+ "-"  + AllTrim(_cRespTxt) // "Falha Interna Web Service - Erro interno no processamento. Caso seja persistente, contatar o suporte da MultiSoftware"

               ElseIf _cCodMsg == "500" // Duplicidade na Requisi��o
                  _cSituacao := "R" // "N"
                  _cResposta := "Duplicidade na Requisi��o - " + _cCodMsg + "-" + AllTrim(_cTextoMsg)// + "-"  + AllTrim(_cRespTxt)  // "Duplicidade na Requisi��o - A requisi��o j� foi feita, ou o registro j� foi inserido anteriormente"
                     
               Else
                  _cSituacao := "R" // "N"
                  _cResposta := AllTrim(_cTextoMsg) + "-" + AllTrim(StrTran(_cResult,Chr(10)," "))
                  _cResposta := Upper(_cResposta)
               EndIf 

               If ! Empty(_cTextoMsg)
                  _cResposta := _cResposta 
               EndIf 

               //=====================================================================================
               // Para n�o rodar a rotina de fechamento de carga, grava Array _aPVCargas 
               // se algum pedido da carga n�o for integrado com sucesso. 
               //=====================================================================================
               _nI := AsCan(_aPVCargas,{|x| x[1] == DAK->DAK_COD})
               If _nI == 0
                  If _cCodMsg <> "200" 
                     Aadd(_aPVCargas,{DAK->DAK_COD, .F., DAK->(Recno())})
                  Else 
                     Aadd(_aPVCargas,{DAK->DAK_COD, .T., DAK->(Recno())})
                  EndIf 
               Else 
                  If _cCodMsg <> "200" 
                     _aPVCargas[_nI,2] := .F.
                  EndIf  
               EndIf 

               //==================================================
               // Atualiza a tabela ZFQ com os dados da Transmiss�o
               //==================================================
 		         ZFQ->(RecLock("ZFQ",.F.))
               ZFQ->ZFQ_SITUAC  := _cSituacao 

               ZFQ->ZFQ_DATAAL  := Date()
               ZFQ->ZFQ_RETORN  := _cResposta  // grava o resultado da integra��o na tabela ZFQ,dizendo que deu certo ou n�o.
               ZFQ->ZFQ_XML     := _cXML
               ZFQ->ZFQ_XMLRET  := _cResult
               ZFQ->ZFQ_RASTMS  := _cProtIntP // _cCodRast // Nr Protocolo Pedido

               ZFQ->ZFQ_DATAP   := DATE()
               ZFQ->ZFQ_HORAP   := TIME()
               ZFQ->(MsUnlock())
           
               For _nI := 1 To Len(_aRecnoItem)
                   ZFR->(DbGoTo(_aRecnoItem[_nI]))
               
                   ZFR->(RecLock("ZFR",.F.))
                   ZFR->ZFR_SITUAC  := _cSituacao // iif(_cok, "P", "N")
                   ZFR->ZFR_DATAAL  := Date()
                   ZFR->ZFR_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFQ,dizendo que deu certo ou n�o.
                   ZFR->(MsUnlock()) 
               Next       
               
               If ! Empty(_cProtIntC) // Protocolo de Integra��o da Carga. 
                  DAK->(RecLock("DAK",.F.))
                  DAK->DAK_I_PTMS := AllTrim(_cProtIntC) //
                  DAK->(MsUnLock())
               EndIf 

               //=======================================================
               // Atualiza o Pedido de Vendas (SC5)
               //=======================================================
               If ! Empty(_cProtIntP) // Protocolo de Integra��o do Pedido.
                  SC5->(RecLock("SC5",.F.))
                  SC5->C5_I_CDTMS := AllTrim(_cProtIntP) 
                  SC5->(MsUnLock())
               EndIf 
               
               Aadd(_aresult,{ZFQ->ZFQ_PEDIDO,DAK->DAK_COD,ZFQ->ZFQ_CNPJEM,"[Retorno Reenvio da Carga] : " + AllTrim(ZFQ->ZFQ_RETORN)}) // adicona em um array para fazer um item list, exibir os resultados.
               Sleep(100) //Espera para n�o travar a comunica��o com o webservice da MULTI-EMBARCADOR
            EndIf

         EndIf 
         
      End Transaction

      QRYZFQ->(DbSkip())
   EndDo 
   
   //===========================================================================
   // Roda a rotina webservice de fechamento da carga.
   //===========================================================================
   For _nI := 1 To Len(_aPVCargas)
       If _aPVCargas[_nI,2] // Carga e pedidos de vendas integrados com sucesso.
          DAK->(DbGoto(_aPVCargas[_nI,3]))         
          _aRet := U_AOMS140F()  // Chama a rotina de integra��o Webservice de finaliza��o da carga.
          If _aRet[1]  // Solicita��o de Fechamento de Carga realizado com sucesso. 
             Aadd(_aresult,{"Carga: >>>",DAK->DAK_COD,"","[Retorno Fechamento da Carga ap�s reenvio] : Sucesso - " + _aRet[2] + "-" + _aRet[3]}) // adicona em um array para fazer um item list, exibir os resultados.
/*
             //==============================================================================
             // Ap�s Fechar a Carga, Roda a Rotina de solicita��o de emiss�o de nota fiscal
             //______________________________________________________________________________
             // _aRet :=  {1=True/False, // sucesso na integra��o / falha na integra��o
             //            2=Codigo da Mensagem de Retorno,
             //            3=C�digo e Mensagem de Retorno, 
             //            4=Xml de Retorno, 
             //            5=Xml de Envio}
             //==============================================================================
             _aRet := U_AOMS140P() // Chama a rotina de integra��o Webservice de solicita��o de emiss�o de nota fiscal.

             If _aRet[1]  // Solicita��o de Fechamento de Carga realizado com sucesso.
                Aadd(_aresult,{"Carga: >>>",DAK->DAK_COD,"","[Retorno Mudan�a Reeenvio Solicita��o de emiss�o de nota fiscal] : Sucesso - " + _aRet[2] + "-" + _aRet[3]}) // adicona em um array para fazer um item list, exibir os resultados.
             Else 
                Aadd(_aresult,{"Carga: >>>",DAK->DAK_COD,"","[Retorno Mudan�a Reeenvio Solicita��o de emiss�o de nota fiscal] : Erro - "    + _aRet[2] + "-" + _aRet[3]}) // adicona em um array para fazer um item list, exibir os resultados.
             EndIf 
*/
          Else // Mensagem de erro no Reenvio.
             Aadd(_aresult,{"Carga: >>>",ZFQ->ZFQ_NCARGA,"","[Retorno Fechamento da Carga ap�s Reenvio] : Erro - " + _aRet[2] + "-" + _aRet[3]})    // adicona em um array para fazer um item list, exibir os resultados.
          EndIf 
       EndIf 
   Next  

   _aCabecalho := {}
   Aadd(_aCabecalho,"PEDIDO" ) 
   Aadd(_aCabecalho,"CARGA" ) 
   Aadd(_aCabecalho,"CNPJ") 
   Aadd(_aCabecalho,"RETORNO") 
             
   _cTitulo := "Resultados da integra��o"
      
   If len(_aresult) > 0 .AND. !_lScheduler
      U_ITListBox( _cTitulo , _aCabecalho , _aresult  ) // Exibe uma tela de resultado.
      _aresult := {}
  	EndIf
    
End Sequence

RestOrd(_aOrd)

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS152DAI()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/03/2025
===============================================================================================================================
Descri��o---------: Grava as tabelas ZFQ e ZFR de acordo com os pedidos de vendas da carga.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function AOMS152DAI()
Local _nSequenPV := 0
Local _aEspecie := {}

Begin Sequence 
   Aadd(_aEspecie,{"CA   ","10"}) // Conh.Aereo
   Aadd(_aEspecie,{"CTA  ","09"}) // Conh.Transp.Aquaviario
   Aadd(_aEspecie,{"CTF  ","11"}) // Conh.Transp.Ferroviario
   Aadd(_aEspecie,{"CTR  ","08"}) // Conh.Transp.Rodoviario
   Aadd(_aEspecie,{"NFST ","07"}) // NF Servico de Transporte
   Aadd(_aEspecie,{"CTM  ","26"}) // Conh.Transp.Multimodal
   Aadd(_aEspecie,{"CTE  ","57"}) // Conhecimento de Transporte Eletronico
   Aadd(_aEspecie,{"CTEOS","67"}) // Conhecimento de Transporte Eletr�nico para Outros Servi�os - CT-e OS
   Aadd(_aEspecie,{"NFPS ","  "}) // NF Prestacao de Servico
   Aadd(_aEspecie,{"NFS  ","  "}) // NF Servico
   Aadd(_aEspecie,{"RPS  ","  "}) // Recibo Provisorio de Servicos - Nota Fiscal Eletronica de Sao Paulo
   Aadd(_aEspecie,{"NFSC ","21"}) // NF Servico de Comunicacao
   Aadd(_aEspecie,{"NTST ","22"}) // NF Servico de Telecomunicacoes
   Aadd(_aEspecie,{"NFCF ","02"}) // NF de venda a Consumidor Final
   Aadd(_aEspecie,{"CF   ","02"}) // Cupom Fiscal gerado pelo SIGALOJA
   Aadd(_aEspecie,{"ECF  ","02"}) // Cupom Fiscal gerado pelo SIGALOJA
   Aadd(_aEspecie,{"RMD  ","18"}) // Resumo Movimento Diario
   Aadd(_aEspecie,{"NFCEE","06"}) // Conta de Energia Eletrica
   Aadd(_aEspecie,{"NFFA ","29"}) // Nota fiscal de fornecimento de agua
   Aadd(_aEspecie,{"NFCFG","28"}) // Nota fiscal/conta de fornecimento de gas
   Aadd(_aEspecie,{"NFE  ","01"}) // NF Entrada
   Aadd(_aEspecie,{"NFA  ","1B"}) // Nota Fiscal Avulsa
   Aadd(_aEspecie,{"NFP  ","04"}) // NF de Produtor
   Aadd(_aEspecie,{"SPED ","55"}) // Nota fiscal eletronica do SEFAZ.
   Aadd(_aEspecie,{"NFCE ","65"}) // Nota fiscal Eletronica ao Consumidor Final
   Aadd(_aEspecie,{"SATCE","59"}) // CUPOM FISCAL ELETR�NICO � SAT

   DAI->(MsSeek(DAK->DAK_FILIAL+DAK->DAK_COD))
   Do While ! DAI->(Eof()) .And. DAI->DAI_FILIAL+DAI->DAI_COD == DAK->DAK_FILIAL+DAK->DAK_COD
      SC5->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))

      If SC5->C5_I_PEDPA == "S"
         DAI->(DbSkip())
         Loop 
      EndIf 

      SF2->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_NFISCA+DAI->DAI_SERIE+DAI->DAI_CLIENT+DAI->DAI_LOJA ))
      DA3->(MsSeek(xFilial("DA3")+DAK->DAK_CAMINH))
      DA4->(MsSeek(xFilial("DA4")+DAK->DAK_MOTORI))
      
      //====================================================
      // Grava ZFQ e ZRF
      //====================================================
      If _lSchedule
         U_AOMS084P("C",,"SCHEDULLER","ESP") 
      Else 
         U_AOMS084P("C",,"BROWSER","ESP")
      EndIf 

      //=======================================================
      // Grava as demais inform��es da ZFQ para tipo Troca NF
      //=======================================================
      ZFQ->(RecLock("ZFQ",.F.))
      
      ZFQ->ZFQ_SITPED := U_STPEDIDO()  // Status do Pedido/Situa��o do Pedido, rotina no xfunoms.  

      ZFQ->ZFQ_CNPJTP := Posicione('SA2',1,xFilial('SA2')+DA4->DA4_FORNEC+DA4->DA4_LOJA,'A2_CGC')
      
      ZFQ->ZFQ_VALFRE := DAK->DAK_I_FRET // N	16	2	Valor do Frete	Valor do Frete
      //ZFQ->ZFQ_NCARGA := DAK->DAK_I_CARG // DAK->DAK_COD     // Numero da Carga.
      
      If DA3->DA3_I_TPVC == "2" .Or. DA3->DA3_I_TPVC == "4"  // 2=CAMINHAO / 4=UTILITARIO
         ZFQ->ZFQ_PLACA	 := DA3->DA3_PLACA  // Placa Veiculo	Placa Principal do Veiculo
      ElseIf DA3->DA3_I_TPVC == "1" // 1=CARRETA  
         ZFQ->ZFQ_PLACA	 := DA3->DA3_I_PLCV  // Placa Veiculo	Placa Principal do Veiculo
         ZFQ->ZFQ_PLACA1 := DA3->DA3_PLACA 	// Placa Reboq.1	Placa do Reboque 1 
      ElseIf DA3->DA3_I_TPVC == "3"
         ZFQ->ZFQ_PLACA	 := DA3->DA3_I_PLCV  // Placa Veiculo	Placa Principal do Veiculo
         ZFQ->ZFQ_PLACA1 := DA3->DA3_PLACA 	// Placa Reboq.1	Placa do Reboque 1
         ZFQ->ZFQ_PLACA2 := DA3->DA3_I_PLVG	// Placa Reboq.2	Placa do Reboque 2
      ElseIf DA3->DA3_I_TPVC == "5" 
         ZFQ->ZFQ_PLACA	 := DA3->DA3_I_PLCV  //	Placa Veiculo	Placa Principal do Veiculo
         ZFQ->ZFQ_PLACA1 := DA3->DA3_PLACA 	// Placa Reboq.1	Placa do Reboque 1
         ZFQ->ZFQ_PLACA2 := DA3->DA3_I_PLVG	// Placa Reboq.2	Placa do Reboque 2
         ZFQ->ZFQ_PLACA3 := DA3->DA3_I_PLV3	// Placa Reboq.3	Placa do Reboque 3
      EndIf 

      ZFQ->ZFQ_TIPVEI := DA3->DA3_I_TPVC     
      ZFQ->ZFQ_CODMDV := DAK->DAK_I_CODV     //	Cod.Mod.Veic	Codigo do Modelo Veicular
      ZFQ->ZFQ_CPFMOT := DA4->DA4_CGC	      //	CPF Motorist	CPF do Motorista
      ZFQ->ZFQ_NOMEMT := DA4->DA4_NOME    	//	Nome Motoris	Nome do Motorista
      ZFQ->ZFQ_CHVNFE := SF2->F2_CHVNFE   	//	Chave NFE	Chave da Nota Fiscal
      ZFQ->ZFQ_EMISNF := SF2->F2_EMISSAO	   //	Data Emi.NFE	Data de Emiss�o da Nota Fiscal
      
      _nI := AsCan(_aEspecie,{|x| x[1] == U_ItKey(SF2->F2_ESPECIE,"F2_ESPECIE")})

      If _nI > 0
         ZFQ->ZFQ_MODNFE := _aEspecie[_nI,2]	//C	5	0	Modelo NFE	Modelo de Nota Fiscal
      EndIf 

      ZFQ->ZFQ_NUMNFE := SF2->F2_DOC       // Numero NFE	Numero da Nota Fiscal
      ZFQ->ZFQ_SERINF := SF2->F2_SERIE     // Serie da NFE	Serie da Nota Fiscal
      ZFQ->ZFQ_VALFAT := SF2->F2_VALBRUT   // F2_VALFAT    // Valor Fatura	Valor da Fatura
      ZFQ->ZFQ_VOLNFE := SF2->F2_VOLUME1   // Volume Tot	Volume Total
      ZFQ->ZFQ_PESLIQ := SF2->F2_PLIQUI 	 // Peso Liquido	Peso Liquido
      ZFQ->ZFQ_PESBRU := SF2->F2_PBRUTO 	 // Peso Bruto	Peso Bruto
      
      ZFQ->ZFQ_NCARGA := DAK->DAK_COD 
      ZFQ->ZFQ_CARTMS := DAK->DAK_COD // DAK->DAK_I_CARG  // _cNrCarTMS 
      ZFQ->ZFQ_CNPJFP := "12815827000132" // Manter os CNPJs fixos. Solicita��o do Vanderlei.
      ZFQ->ZFQ_CNPJRP := "01257995000133" // Manter os CNPJS fixos. Solicita��o do Vanderlei.
      ZFQ->ZFQ_NRCVPE := DAK->DAK_I_VPED
      ZFQ->ZFQ_VALVPE := DAK->DAK_I_VRPE
      
      If DAK->DAK_I_LEMB == 'SP50' .And.  DAK->DAK_TRANSP $  "T03055/T02609" // Solicita��o do Vanderlei.  
         ZFQ->ZFQ_TPOPER := "VD_D_CONTR"
      EndIf 
      //==============================================
      // Grava o valor do frete rateado.
      //==============================================
      ZFQ->ZFQ_VALFRE := 0 // DAI->DAI_I_FRET  // Solicita��o do Vanderlei n�o enviar o valor do Frete.
      
      ZFQ->ZFQ_SITUAC := "C" // Este tipo de situa��o indica integra��o exclusiva para cargas do tipo troca nota fiscal.

      ZFQ->ZFQ_SEQENT := StrZero(_nSequenPV,6)

      ZFQ->(MsUnLock())

      _nSequenPV += 1

      //=================================================================
      // H� alguama rotina que altera ZFR->ZFR_SITUAC := "T" para "N".
      // Este trecho for�a a atualiza��o para "T".
      //=================================================================
      ZFR->(DbSetOrder(5)) // ZFR_FILIAL+ZFR_NUMPED+ZFR_SITUAC  
      ZFR->(MsSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO+"N"))
      Do While ! ZFR->(Eof()) .And. ZFR->ZFR_FILIAL+ZFR->ZFR_NUMPED+ZFR->ZFR_SITUAC == ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO+"N"
         ZFR->(RecLock("ZFR",.F.))
         ZFR->ZFR_SITUAC := "C"
         ZFR->(MsUnlock())

         ZFR->(DbSkip())
      EndDo  

      DAI->(DbSkip())
   EndDo 
   
End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS152F() // AOMS144F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/03/2025
===============================================================================================================================
Descri��o---------: Rotina de transmiss�o dos XMLs das notas fiscais Italac x TMS Multiembarcador.
                    Rotina adaptada para transmitir os XMLs para Cargas Posicionadas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function AOMS152F() // AOMS144F()
Local _cQry          := ""
Local _cAliasTMP     := "TRBAOMS152F" // AOMS144F"
Local _cAlias        := "ZFK"
//----------------------------------------------//
Local _cTimeIni      := Time()
Local _nI            := 0
Local _nRegAtu       := 0
Local _nTotRegs      := 0
Local _nEnviados     := 0
//----------------------------------------------//
Local _aDados        := {}
Local _aSizes        := {}
Local _aCabec        := {}
Local _aAlias        := {}
Local _aCampos       := {}
Local _aLinha        := {}
Local _aPosCpo       := {}
//----------------------------------------------//
Local _cToken        := ""
Local _cLink         := ""
Local _cXML          := ""
Local _cCodEmpWS     := U_ITGETMV( 'IT_EMPTMSM' , "000005")
//----------------------------------------------//
Local _aLog          := {}
Local _aCabecLog        := {"Processado","Filial","Pedido","Chave NFe","Retorno", "Recno ZFK"}
Local _cTextoFim     := ""
//----------------------------------------------//
Local _lOk           := .F.
Local _cResult       := ""
//----------------------------------------------//
Local _cFilHabilit      := U_ITGETMV( 'IT_FILINTWS' , '' ) 
Local _cProtocolo    := ""
Local _nPosi         := 0
Local _nPosf         := 0
Local _cXML_Nfe      := ""

Local _nRecnoZFK     := 0
Local oWsdl

Begin Sequence 
   
   If !_lScheduler .AND. ! U_ItMsg("Confirma envio de arquivos XML das NFe >> Italac <---> TMS Multi-Embarcador?","Inicio de processamento",,4,2,2) 
      Break
   EndIf

   _aAlias := AOMS152MA(_cAlias,_cAliasTMP, .T.,.T.,.T.)

   _aCabec  := _aAlias[1]
   _aPosCpo := _aAlias[2]
   _aSizes  := _aAlias[3]
   _aCampos := _aAlias[4]

   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================
   _cQry := " SELECT ZFK.*, ZFK.R_E_C_N_O_ R_E_C_N_O_ "
   _cQry += " FROM "+RetSqlName("ZFK")+" ZFK "
   _cQry += " WHERE ZFK.D_E_L_E_T_ <> '*' "
   _cQry += "   AND ZFK_TIPOI = '2' "
   _cQry += "   AND (ZFK_SITUAC = 'N' OR  ZFK_SITUAC = 'R') "
   _cQry += "   AND ZFK_FILIAL IN "+FormatIn(ALLTRIM(_cFilHabilit),";")

   _cQry := ChangeQuery(_cQry)          

   If Select(_cAliasTMP) > 0
      (_cAliasTMP)->( DBCloseArea() )
   EndIf

   //DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAliasTMP , .T., .F. )                            
   MPSysOpenQuery( _cQry , _cAliasTMP)
   
   DBSelectArea(_cAliasTMP)                                                                                  
   COUNT TO _nTotRegs

   IF !_lScheduler
      ProcRegua(_nTotRegs)
   EndIf

   _cTotal := ALLTRIM(STR(_nTotRegs))

   If _nTotRegs > 0

      DBSelectArea(_cAliasTMP)                       
      (_cAliasTMP)->(DbGoTop())

      Do While !(_cAliasTMP)->(Eof()) 

         _nRegAtu++

         If !_lScheduler 
            IncProc("Lendo dados de Carga - Registro : " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
         EndIf

         _aLinha := {}
         For _nI := 1 To Len(_aCampos)
            Aadd(_aLinha, &(_aCampos[_nI]))
         Next

         Aadd(_aDados,_aLinha)

         (_cAliasTMP)->(Dbskip())
         
      EndDo
      
      If _lScheduler
      
         _lReturn := .T.
      
      Else
      
         _cTitulo := "Cargas que foram geradas a partir de integra��o com o TMS Multiembarcador "
         _cMsgTop := _cTitulo

         If Len(_aDados) > 0
                     //ITListBox( _cTitAux , _aHeader    , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda ,_lHasOk,_bHeadClk,_aSX1)
            _lReturn := U_ITListBox( _cTitulo , _aCabec     , _aDados   , .T.      , 2      , _cMsgTop ,          , _aSizes ,         ,     ,        ,          ,       ,         ,          ,           ,          ,       ,         ,     )
         Else
            U_ItMsg(">> Carregamento conclu�do << "+Chr(10)+;
            "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+"Sem dados para integra��o",;
            "Aten��o!!!",,3)
            Break
         EndIf
      EndIf

      If _lReturn

         //=====================================================================
         // Obtem o token de acesso ao sistema multi embarcador.
         //=====================================================================
         _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

         IF !_lScheduler 
            ProcRegua(Len(_aDados))
         EndIf

         _cTotal := ALLTRIM(STR(Len(_aDados)))

         For _nI := 1 To Len(_aDados)
            
            If _lScheduler   
               U_ItConout("[AOMS152F] Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)  
            Else
               IncProc("Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)   
            EndIf

            If _aDados[_nI][1] .OR. _lScheduler

               Begin Sequence

                  _nRecnoZFK := _aDados[_nI][aScan(_aPosCpo,{|x|x="R_E_C_N_O_"})]

                  ZFK->(DbGoTo(_nRecnoZFK))   

                  ZFM->(DbSetOrder(1))
                  If ZFM->(DbSeek(ZFK->ZFK_FILIAL+_cCodEmpWS))
                     //_cDirXML := ZFM->ZFM_LOCXML 
                     _cLink   := AllTrim(ZFM->ZFM_LINK02)
                  Else    
                     _cMsg := "Empresa WebService para envio dos dados n�o localizada. Tabela ZFM."     
                     If !_lScheduler
                        u_itmsg(_cMsg,"Aten��o",,1)
                     Else
                        U_ITCONOUT("[AOMS152F] "+_cMsg)
                     EndIf
                     _lOk := .F.
                     Break   
                  EndIf                        

                  If Empty(_cLink)
                     _cMsg := "O Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+"."
                     If !_lScheduler
                        U_ItMsg(_cMsg,"Aten��o",,1)
                     Else
                        U_ItConout("[AOMS152F] "+_cMsg)
                     EndIf
                     _lOk := .F.
                     Break                                     
                  EndIf

                  DbSelectArea("SF2")
                  DbSetOrder(21)
                  If DbSeek(ZFK->ZFK_CHVNFE)

                     If ! _lScheduler
                        IncProc("Integrando a Chave NFe: "+ZFK->ZFK_CHVNFE)                    
                     Else
                        u_itconout("[AOMS152F] Integrando a Chave NFe: "+ZFK->ZFK_CHVNFE) 
                     EndIf  
                     
                     _cXML_Nfe := ZFK->ZFK_XML 

                     _cXml := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
                     _cXml += '   <soapenv:Header>'
                     _cXml += '      <Token xmlns="Token">'+Eval({|| FWHttpEncode(AllTrim(_cToken))})+'</Token>'
                     _cXml += '   </soapenv:Header>'
                     _cXml += '   <soapenv:Body>'
                     _cXml += '      <tem:EnviarArquivoXMLNFe>'
                     _cXml += '<tem:arquivo>'+Eval({|| Encode64(AllTrim(_cXML_Nfe))})+'</tem:arquivo>'
                     _cXml += '      </tem:EnviarArquivoXMLNFe>'
                     _cXml += '   </soapenv:Body>'
                     _cXml += '</soapenv:Envelope>'

                     _nIniCarre := 1   // Inicio da leitura das cargas pendentes no TMS.
                     _nLimCarre := 100 // N�mero M�ximo de Registros Lidos.

                     oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
                     oWsdl:nTimeout := 10          // Timeout de 10 segundos 
                     oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    

                     oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
                     oWsdl:SetOperation( "EnviarArquivoXMLNFe") // Define qual opera��o ser� realizada.

                     // Envia para o servidor
                     _lOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
                        
                     If _lOk 
                        _cResult := oWsdl:GetSoapResponse()

                        _nPosi := AT("<a:Objeto>", _cResult)
                        _nPosf := AT("</a:Objeto>", _cResult)	
                        
                        If _nPosi == 0
                           _cProtocolo := ""
                        Else
                           _cProtocolo := substr(_cresult,_nposi+Len("<a:Objeto>"),_nposf-_nposi-Len("<a:Objeto>"))
                        Endif
                        
                        _cResult := "Integra��o Processada"
                     Else
                        _cResult := oWsdl:cError
                        _cProtocolo := ""
                     EndIf   

                     If _lOk 
                        SF2->(RecLock("SF2",.F.))
                           //SF2->F2_I_SITUA := 'P'    
                           SF2->F2_I_DTENV := Date()
                           SF2->F2_I_HRENV := Time()
                           SF2->F2_I_PRTMS := _cProtocolo      //Protocolo TMS
                        SF2->(MsUnLock())
                        _nEnviados++
                     EndIf 

                     ZFK->(RecLock("ZFK",.F.))
                        ZFK->ZFK_DATA   := Date()  
                        ZFK->ZFK_HORA   := Time()
                        ZFK->ZFK_SITUAC := Iif(_lOk,"P","R")
                        ZFK->ZFK_CODEMP := _cCodEmpWS
                        ZFK->ZFK_RETORN := _cResult
                        ZFK->ZFK_PRTMS  := _cProtocolo
                        If _lOk
                           ZFK->ZFK_XML    := _cXML
                        EndIf
                     ZFK->(MsUnLock())

                     _cMsg := _cResult

                  Else
                     _lOk  := .F.
                     _cMsg := "N�o encontrado a Nota da Chave "+ ZFK->ZFK_CHVNFE +" gravada na ZFK referente ao Recno "+Alltrim(Str(_nRecnoZFK))
                     If _lScheduler   
                        U_ItConout("[AOMS152F] "+_cMsg)  
                     Else
                        IncProc(_cMsg)   
                     EndIf
                  EndIf   
                     
               End Sequence

               AADD(_aLog,{_lOk, ZFK->ZFK_FILIAL,ZFK->ZFK_PEDIDO,ZFK->ZFK_CHVNFE,_cMsg,ZFK->(Recno())})
               Sleep(100) //Espera para n�o travar a comunica��o com o webservice da TMS

            Endif
               
            FreeObj(oWsdl)

         Next

      Endif

      _cTextoFim := "Arquivos XML NFe enviados pelo m�todo EnviarArquivoXMLNFe: "+STR(_nEnviados)+Chr(10)

      If _lScheduler
         U_ItConout("[AOMS152F] >> Processamento conclu�do << Italac <---> TMS Multi-Embarcador "+_cTextoFim)
      Else
         U_ItMsg(">> Processamento conclu�do << "+Chr(10)+;
               "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+_cTextoFim+Chr(10),;
               "Fim de processamento",,2)
         
         If Len(_aLog) > 0

            U_ITListBox( 'Log de Processamento da Integra��o',;
            _aCabecLog, _aLog , .T. , 1 ,;
            "Abaixo segue a rela��o de processamento do m�todo EnviarArquivoXMLNFe" )

         EndIf
      EndIf

   Else
      If _lScheduler
         ConOut("[AOMS152F] - N�o foram encontrados dados para integra��o." )
      Else
         //U_ITMSG("N�o foram encontrados dados para integra��o.","Aten��o",,3)
         U_ItMsg(">> Processamento conclu�do << "+Chr(10)+;
         "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+"Sem dados para integra��o",;
         "Aten��o",,3)
      EndIf
   EndIf

End Sequence

If Select(_cAliasTMP) > 0
   (_cAliasTMP)->( DBCloseArea() )
EndIf

Return Nil


/*
===================================================================================================================================
Programa----------: AOMS152G() // AOMS144G
Autor-------------: Julio de Paula Paz 
Data da Criacao---: 28/03/2025
===================================================================================================================================
Descri��o---------: Rotina Rotina de Reenvio de XML das Notas Fiscais, para cargas posicionadas, Italac <---> TMS Multi-Embarcador.
                    Replica da fun��o AOMS144G, adaptada para enviar XMLs das Notas Fiscais para cargas posicionadas.
===================================================================================================================================
Parametros--------: Nenhum
===================================================================================================================================
Retorno-----------: Nenhum
===================================================================================================================================
*/  
Static Function AOMS152G() // AOMS144G()
Local _cQry        := ""
Local _cTimeIni    := Time()
Local _cAlias      := "SF2"
Local _cAliasTMP   := "TRBAOMS152G" // AOMS144G"
Local _aAlias      := {}
Local _nRegAtu     := 0
Local _nTotRegs    := 0
Local _aCabec      := {}
Local _aPosCpo     := {}
Local _aSizes      := {}
Local _aCampos     := {}
Local _aLinha      := {}
Local _aDados      := {}
Local _lReturn     := .F.
Local _lOk         := .T.
Local _cMsg        := ""
Local _aLog        := {}
Local _aCabecLog   := {"Processado","Filial","Pedido","Chave NFe","Retorno", "Recno SF2"}

Local _dDataIntTMS := U_ItGetMv("IT_DTINTRDC",Ctod("25/10/2016"))

Local _cXmlNfe     := ""
Local _cProtNfe    := ""
Local _cXmlEnv     := ""
Local _cPart1Xml   := ""
Local _cPart2Xml   := ""
Local _nI          := 0
Local _nIni        := 0
Local _nFim        := 0
Local _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x TMS Multi-Embarcador

Local _cTextoFim   := ""
Local _nEnviados   := 0

Local _nRecnoSF2   := 0
Local _nRecno54    := 0
Local _nRecno50    := 0

Begin Sequence 
   
   If !_lScheduler .AND. ! U_ItMsg("Confirma a carga de registros para Enviar Arquivos XML NFe >> Italac <---> TMS Multi-Embarcador?","Inicio de processamento",,4,2,2) 
      Break
   EndIf

   _aAlias := AOMS152MA(_cAlias,_cAliasTMP, .T.,.T.,.T.)

   _aCabec  := _aAlias[1]
   _aPosCpo := _aAlias[2]
   _aSizes  := _aAlias[3]
   _aCampos := _aAlias[4]

   Aadd(_aCabec,"Recno SF2")
   Aadd(_aPosCpo,"NRECSF2")
   Aadd(_aSizes,10)
   Aadd(_aCampos,"NRECSF2")

   Aadd(_aCabec,"Recno 50")
   Aadd(_aPosCpo,"NREC50")
   Aadd(_aSizes,10)
   Aadd(_aCampos,"NREC50")

   Aadd(_aCabec,"Recno 54")
   Aadd(_aPosCpo,"NREC54")
   Aadd(_aSizes,10)
   Aadd(_aCampos,"NREC54")

   Aadd(_aCabec,"Recno DAK")
   Aadd(_aPosCpo,"NRECDAK")
   Aadd(_aSizes,10)
   Aadd(_aCampos,"NRECDAK")

   IF !_lScheduler
      ProcRegua(0)
      IncProc("Lendo dados da SPED50/SF2...")
   EndIf
   
   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================
   _cQry := " SELECT SF2.* ,SPED50.R_E_C_N_O_ NREC50, SF2.R_E_C_N_O_ NRECSF2, SPED54.R_E_C_N_O_ NREC54, DAK.R_E_C_N_O_ NRECDAK "
   _cQry += " FROM "+RetSqlName("SF2")+" SF2, SPED050 SPED50, SPED054 SPED54, "+RetSqlName("DAK")+" DAK "
   _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' "
   _cQry += "   AND SPED50.D_E_L_E_T_ <> '*' "
   _cQry += "   AND SPED54.D_E_L_E_T_ <> '*' "
   _cQry += "   AND DAK.D_E_L_E_T_ <> '*' "
   //_cQry += "   AND F2_I_SITUA = ' ' "
   _cQry += "   AND DOC_CHV = F2_CHVNFE "
   _cQry += "   AND NFE_CHV = F2_CHVNFE "
   _cQry += "   AND F2_ESPECIE = 'SPED' "
   _cQry += "   AND F2_EMISSAO >= '" + DTos(_dDataIntTMS) + "' "
   _cQry += "   AND F2_CHVNFE <> ' ' "
   _cQry += "   AND SPED50.STATUS = '6' "
   _cQry += "   AND SPED54.CSTAT_SEFR = '100' "     
   _cQry += "   AND DAK_FILIAL = F2_FILIAL "
   _cQry += "   AND DAK_COD = F2_CARGA "
   _cQry += "   AND F2_CARGA = '" + DAK->DAK_COD + "' "
   //_cQry += "   AND DAK_I_RECR <> ' ' " 
   _cQry += "   AND F2_FILIAL IN "+FormatIn(ALLTRIM(_cFilHabilit),";")
   _cQry += "   AND NOT EXISTS ( SELECT 'X' FROM "+RetSqlName("ZFK")+ " ZFK WHERE ZFK.D_E_L_E_T_ <> '*' AND ZFK.ZFK_TIPOI = '2' AND ZFK.ZFK_CHVNFE = SF2.F2_CHVNFE)"
   
   _cQry := ChangeQuery(_cQry)         

   If Select(_cAliasTMP) > 0
      (_cAliasTMP)->( DBCloseArea() )
   EndIf

   //DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAliasTMP , .T., .F. )   
   MPSysOpenQuery( _cQry , _cAliasTMP)                         
   
   DBSelectArea(_cAliasTMP)                                                                               
   COUNT TO _nTotRegs

   IF !_lScheduler 
      ProcRegua(_nTotRegs)
   EndIf

   _cTotal := ALLTRIM(STR(_nTotRegs))
                          
      DBSelectArea(_cAliasTMP)
      (_cAliasTMP)->(DBGoTop())
   
   If _nTotRegs > 0
      Do While !(_cAliasTMP)->(Eof()) 

         _nRegAtu++

         If !_lScheduler 
            IncProc("Lendo dados de Carga - Registro : " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
         EndIf

         _aLinha := {}
         For _nI := 1 To Len(_aCampos)
            Aadd(_aLinha, &(_aCampos[_nI]))
         Next

         Aadd(_aDados,_aLinha)

         (_cAliasTMP)->(Dbskip())
         
      EndDo

      If _lScheduler
      
         _lReturn := .T.
      
      Else
      
         _cTitulo := "Cargas que foram geradas a partir de integra��o com o TMS Multiembarcador "
         _cMsgTop := _cTitulo

         If Len(_aDados) > 0
                     //ITListBox( _cTitAux , _aHeader    , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda ,_lHasOk,_bHeadClk,_aSX1)
            _lReturn := U_ITListBox( _cTitulo , _aCabec     , _aDados   , .T.      , 2      , _cMsgTop ,          , _aSizes ,         ,     ,        ,          ,       ,         ,          ,           ,          ,       ,         ,     )
         Else
            U_ItMsg(">> Carregamento conclu�do << "+Chr(10)+;
            "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+"Sem dados para integra��o",;
            "Aten��o!!!",,3)
            Break
         EndIf

      EndIf

      If _lReturn
         
         //===================================================================================================
         // Abre o arquivo de Sped para leitura dos XML e Envio para o RDC.
         //===================================================================================================
         If Select("SPED050") > 0
            SPED050->( DBCloseArea() )
         EndIf     
         
         USE SPED050 ALIAS SPED050 SHARED NEW VIA "TOPCONN" 
         
         If Select("SPED054") > 0
            SPED054->( DBCloseArea() )
         EndIf     
         
         USE SPED054 ALIAS SPED054 SHARED NEW VIA "TOPCONN" 
         
         SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM                                                                                                                                                

         For _nI := 1 To Len(_aDados)

            If _lScheduler   
               U_ItConout("[AOMS152G] Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)  
            Else
               IncProc("Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)   
            EndIf

            If _aDados[_nI][1] .OR. _lScheduler

               _nRecnoSF2 := _aDados[_nI][aScan(_aPosCpo,{|x|x="NRECSF2"})]
               _nRecno54  := _aDados[_nI][aScan(_aPosCpo,{|x|x="NREC54"})]
               _nRecno50  := _aDados[_nI][aScan(_aPosCpo,{|x|x="NREC50"})]
               _nRecnoDAK  := _aDados[_nI][aScan(_aPosCpo,{|x|x="NRECDAK"})]
               
               _cMsg := ""
               _lOk  := .T.

               SF2->(DbGoTo(_nRecnoSF2)) //Com a SF2 devidamente posicionada
               DAK->(DbGoTo(_nRecnoDAK))

               AOMS152VN(@_lOk,@_cMsg)

               If _lOk
                  
                  _nEnviados++ 

                  If _lScheduler
                     U_ItConout("[AOMS152G] Gravando Tabela Muro ZFK o arquivo XML: " +SPED050->DOC_CHV)
                  EndIf

                  SPED054->(DbGoTo(_nRecno54))
                  SPED050->(DbGoTo(_nRecno50))

                  _lSC5_PEDPA   := .F.

                  If !Empty(Alltrim(SF2->F2_I_PEDID ))
                     DBSelectArea("SC5")
                     SC5->( DBSetOrder(1) )
                     If SC5->( DBSeek( SF2->F2_FILIAL + SF2->F2_I_PEDID ) )
                        _lSC5_PEDPA   := (SC5->C5_I_PEDPA == "S")
                        _cSC5_I_CDTMS := SC5->C5_I_CDTMS
                     Else
                        _lSC5_PEDPA   := .F.
                        _cSC5_I_CDTMS := ""
                     EndIf
                  EndIf

                  //===================================================================================================
                  // Monta XML para envio ao TMS
                  //===================================================================================================   
                                 
                  _cXmlNfe := SPED050->XML_SIG
            
                  _cProtNfe := SPED054->XML_PROT
                                                         
            
                  _nIni := AT( "<infNFe", _cXmlNfe ) 
                  _nFim := AT( "</NFe>", _cXmlNfe ) 
                  _cPart1Xml := SubStr(_cXmlNfe,_nIni,_nFim - _nIni)
                                                            
                  _nIni := AT( "<protNFe", _cProtNfe ) 
                  _nFim := AT( "</protNFe>", _cProtNfe ) 
                  _cPart2Xml := SubStr(_cProtNfe,_nIni,_nFim + 11)
            
                  _cXmlEnv := '<?xml version="1.0" encoding="UTF-8"?> <nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10"> <NFe>  '
                  _cXmlEnv := _cXmlEnv + _cPart1Xml + "</NFe>" + _cPart2Xml + '   </nfeProc> '
                  
                  _cXML_Nfe := _cXmlEnv

                  ZFK->(RecLock("ZFK",.T.))
                     ZFK->ZFK_FILIAL := SF2->F2_FILIAL
                     ZFK->ZFK_CARGA  := DAK->DAK_COD
                     ZFK->ZFK_CARTMS := DAK->DAK_I_RECR 
                     ZFK->ZFK_PRTPED := _cSC5_I_CDTMS
                     ZFK->ZFK_DATA   := Date()  
                     ZFK->ZFK_HORA   := Time()
                     ZFK->ZFK_TIPOI  := "2"
                     ZFK->ZFK_CHVNFE := SF2->F2_CHVNFE
                     ZFK->ZFK_PEDPAL := Iif(_lSC5_PEDPA ,"S","N") 
                     ZFK->ZFK_NRPPAL := Iif(_lSC5_PEDPA ,SF2->F2_I_PEDID ,"")    
                     ZFK->ZFK_CGC    := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_CGC") 
                     ZFK->ZFK_PEDIDO := SC5->C5_NUM
                     ZFK->ZFK_COD	 := SF2->F2_CLIENTE    // C�digo Cliente    // SA2->A2_COD  - Fornecedor    // O correto �: A1_COD
                     ZFK->ZFK_LOJA   := SF2->F2_LOJA       // Loja Cliente      // SA2->A2_LOJA - Fornecedor    //              A1_LOJA
                     ZFK->ZFK_NOME   := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")   // Nome Cliente      // SA2->A2_NOME - Fornecedor   //              A1_NOME
                     ZFK->ZFK_USUARI := __cUserId
                     ZFK->ZFK_SITUAC := "N" 
                     ZFK->ZFK_XML    := _cXML_Nfe
                  ZFK->(MsUnLock())

                  _cMsg := "Carregado para Integra��o"
/*
               Else
               
                  SF2->(RecLock("SF2",.F.))
                     SF2->F2_I_SITUA := 'N'    
                     SF2->F2_I_DTENV := Date()
                     SF2->F2_I_HRENV := Time()
                  SF2->(MsUnLock())
*/                     
               EndIf
               
               AADD(_aLog,{_lOk, SF2->F2_FILIAL,SC5->C5_NUM,SF2->F2_CHVNFE,_cMsg,SF2->(Recno())})

            EndIf

         Next _nI

         _cTextoFim := "Notas Fiscais carregadas para Enviar Arquivo XML NFe : "+STR(_nEnviados)+Chr(10)

         U_ItConout("[AOMS152G] >> Carregamento conclu�do << Italac <---> TMS Multi-Embarcador "+_cTextoFim)
         
         If !_lScheduler
            U_ItMsg(">> Carregamento conclu�do << "+Chr(10)+;
                  "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+_cTextoFim+Chr(10),;
                  "Fim de Carregamento",,2)
            
            If Len(_aLog) > 0

               U_ITListBox( 'Log de Processamento do carregamento de registros para Enviar Arquivos XML NFe',;
               _aCabecLog, _aLog , .T. , 1 ,;
               "Abaixo segue a rela��o de Carregamento" )

            EndIf
         EndIf
      EndIf
   Else
      If _lScheduler
         ConOut("[AOMS152G] - N�o foram encontrados dados para integra��o." )
      Else
         //U_ITMSG("N�o foram encontrados dados para integra��o.","Aten��o",,3)
         U_ItMsg(">> Processamento conclu�do << "+Chr(10)+;
         "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+"Sem dados para integra��o",;
         "Aten��o",,3)
      EndIf
   EndIf

End Sequence

 //================================================================================
// Fecha as tabelas tempor�rias
//================================================================================                    
If Select(_cAliasTMP) > 0
   (_cAliasTMP)->( DBCloseArea() )
EndIf

If Select("SPED050") > 0
   SPED050->( DBCloseArea() )
EndIf     

If Select("SPED054") > 0
   SPED054->( DBCloseArea() )
EndIf  

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS152I() // AOMS144I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/03/2025
===============================================================================================================================
Descri��o---------: Faz a transmiss�o das notas fiscais Protheus x TMS Multiembarcador.
                    Replica da fun��o AOMS144I adaptada para transmitir as notas fiscais para cargas posicionadas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152I() // AOMS144I()
Local _cQry             := ""
Local _aOrd             := SaveOrd({"SX3","ZFK"})
Local _cAlias           := "ZFK"
Local _cAliasTMP        := "TRBZFK"
//----------------------------------------------//
Local _cTimeIni         := Time()
Local _nI               := 0
Local _nRegAtu          := 0
Local _nTotRegs         := 0
Local _nEnviados        := 0
//----------------------------------------------//
Local _aDados           := {}
Local _aSizes           := {}
Local _aCabec           := {}
Local _aAlias           := {}
Local _aCampos          := {}
Local _aLinha           := {}
Local _aPosCpo          := {}
//----------------------------------------------//
Local _cToken           := ""
Local _cLink            := ""
Local _cXML             := ""
Local _cCodEmpWS   := U_ITGETMV( 'IT_EMPTMSM' , "000005")
//----------------------------------------------//
Local _aLog          := {}
Local _aCabecLog        := {"Processado","Filial","Chave NFe","Pedido","CNPJ","Retorno", "Recno ZFK"}
Local _cTextoFim     := ""
//----------------------------------------------//
Local _lOk              := .F.
Local _cResult          := ""
//----------------------------------------------//
Local _cFilHabilit      := U_ITGETMV( 'IT_FILINTWS' , '' ) 
Local _cResposta        := ""
Local cReplace          := ""
Local cErros            := ""
Local cAvisos           := ""

Local _nRecnoZFK        := 0
Local oWSDL
//Local _aCargaLibSNFe     := {}

Begin Sequence

   If !_lScheduler .AND. ! U_ItMsg("Confirma integra��o de Notas Fiscais >> Italac <---> TMS Multi-Embarcador?","Inicio de processamento",,4,2,2) 
      Break
   EndIf

   _aAlias := AOMS152MA(_cAlias,_cAliasTMP, .T.,.T.,.T.)

   _aCabec  := _aAlias[1]
   _aPosCpo := _aAlias[2]
   _aSizes  := _aAlias[3]
   _aCampos := _aAlias[4]

   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================
   _cQry := " SELECT ZFK.*,  ZFK.R_E_C_N_O_ R_E_C_N_O_ "
   _cQry += " FROM "+RetSqlName("ZFK")+" ZFK "
   _cQry += " WHERE ZFK.D_E_L_E_T_ <> '*' "
   _cQry += "   AND ZFK_TIPOI = '4' "
   _cQry += "   AND (ZFK_SITUAC = 'N' OR  ZFK_SITUAC = 'R') "
   _cQry += "   AND ZFK_FILIAL IN "+FormatIn(ALLTRIM(_cFilHabilit),";")

   _cQry := ChangeQuery(_cQry)          

   If Select(_cAliasTMP) > 0
      (_cAliasTMP)->( DbCloseArea() )
   EndIf

   //DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAliasTMP , .T., .F. )  
   MPSysOpenQuery( _cQry , _cAliasTMP)                         

   DBSelectArea(_cAliasTMP)
   Count to _nTotRegs

   IF !_lScheduler 
      ProcRegua(_nTotRegs)
   EndIf
   
   _cTotal := ALLTRIM(STR(_nTotRegs))

   If _nTotRegs > 0

      DBSelectArea(_cAliasTMP)
      (_cAliasTMP)->(DBGoTop())

      Do While (_cAliasTMP)->(!EOF())

         _nRegAtu++

         If !_lScheduler 
            IncProc("Lendo dados de Carga - Registro : " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
         EndIf

         _aLinha := {}
         For _nI := 1 To Len(_aCampos)
            Aadd(_aLinha, &(_aCampos[_nI]))
         Next

         Aadd(_aDados,_aLinha)

         (_cAliasTMP)->(Dbskip())

      EndDo

      If _lScheduler
      
         _lReturn := .T.
      
      Else
      
         _cTitulo := "Cargas que foram geradas a partir de integra��o com o TMS Multiembarcador "
         _cMsgTop := _cTitulo

         If Len(_aDados) > 0
                        //ITListBox( _cTitAux , _aHeader    , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda ,_lHasOk,_bHeadClk,_aSX1)
            _lReturn := U_ITListBox( _cTitulo , _aCabec     , _aDados   , .T.      , 2      , _cMsgTop ,          , _aSizes ,         ,     ,        ,          ,       ,         ,          ,           ,          ,       ,         ,     )
         Else
            U_ItMsg(">> Processamento conclu�do << "+Chr(10)+;
            "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+"Sem dados para integra��o",;
            "Aten��o!!!",,3)
            Break
         EndIf            
      EndIf

      If _lReturn

         //=====================================================================
         // Obtem o token de acesso ao sistema multi embarcador.
         //=====================================================================
         _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

         IF !_lScheduler 
            ProcRegua(Len(_aDados))
         EndIf

         _cTotal := ALLTRIM(STR(Len(_aDados)))

         For _nI := 1 To Len(_aDados)

            If _lScheduler   
               U_ItConout("[AOMS152I] Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)  
            Else
               IncProc("Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)   
            EndIf

            If _aDados[_nI][1] .OR. _lScheduler

               Begin Sequence
               
                  _nRecnoZFK := _aDados[_nI][aScan(_aPosCpo,{|x|x="R_E_C_N_O_"})]

                  ZFK->(DbGoto(_nRecnoZFK))
                  
                  //_cCodEmpWS := ZFK->ZFK_CODEMP   

                  ZFM->(DbSetOrder(1))
                  If ZFM->(DbSeek(ZFK->ZFK_FILIAL+_cCodEmpWS))
                     //_cDirXML := ZFM->ZFM_LOCXML 
                     _cLink   := AllTrim(ZFM->ZFM_LINK02)
                     //_cLink := "https://italac.multihomo.com.br/SGT.WebService/NFe.svc?wsdl"
                  Else  
                     _cMsg := "Empresa WebService para envio dos dados n�o localizada."          
                     If ! _lScheduler
                        MsgInfo(_cMsg,"Aten��o")
                     Else
                        u_itconout("[AOMS152I] "+_cMsg)
                     EndIf
                     _lOk := .F.
                     Break   
                  EndIf                        

                  If Empty(_cLink)
                     _cMsg := "O Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+"."
                     If !_lScheduler
                        U_ItMsg(_cMsg,"Aten��o",,1)
                     Else
                        U_ItConout("[AOMS152I] "+_cMsg)
                     EndIf
                     _lOk := .F.
                     Break                                     
                  EndIf

                  DBSelectArea("DAK")
                  DBSetOrder(1)
                  If DbSeek(ZFK->ZFK_FILIAL+ZFK->ZFK_CARGA)

                     If ! _lScheduler
                        IncProc("Integrando Carga: "+DAK->DAK_COD)                    
                     Else
                        u_itconout("[AOMS152I] Integrando Carga: "+DAK->DAK_COD) 
                     EndIf  

                     //_cProtIntC := Alltrim(DAK->DAK_I_RECR)  //'446' 
                     _cProtIntC := Alltrim(DAK->DAK_I_PTMS)    //'446' 

                     If ZFK->ZFK_PEDPAL  == "S"             //  Grava dados informando que � um pedido de pallet.
                        _cProtIntP := Posicione("SC5",1,DAK->DAK_FILIAL+ZFK->ZFK_NRPPAL,"C5_I_CDTMS")  
                     Else
                        _cProtIntP := Alltrim(ZFK->ZFK_PRTPED)    // '2335'
                     EndIf 
                     _cTokenNF  := Alltrim(ZFK->ZFK_PRTMS)     //'74998224-5997-4343-9621-7cf0c2cd4b61'

                     _cXml := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:dom="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.WebService.Carga" xmlns:dom1="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.Embarcador.Pessoas" xmlns:dom2="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.Embarcador.Localidade" xmlns:dom3="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor" xmlns:dom4="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.Embarcador.Carga" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:dom5="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.WebService" xmlns:dom6="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.Embarcador.NFe">'
                     _cXml += '  <soapenv:Header>'
                     _cXml += '		<Token xmlns="Token">'+_cToken+'</Token>'
                     _cXml += '	</soapenv:Header>'
                     _cXml += '   <soapenv:Body>'
                     _cXml += '      <tem:IntegrarNotasFiscais>'
                     _cXml += '         <tem:protocolo>'
                     _cXml += '            <dom:protocoloIntegracaoCarga>'+_cProtIntC+'</dom:protocoloIntegracaoCarga>'
                     _cXml += '            <dom:protocoloIntegracaoPedido>'+_cProtIntP+'</dom:protocoloIntegracaoPedido>'
                     _cXml += '         </tem:protocolo>'
                     _cXml += '         <tem:TokensXMLNotasFiscais>'
                     _cXml += '            <dom6:TokenNF>'
                     _cXml += '               <dom6:Token>'+_cTokenNF+'</dom6:Token>'
                     _cXml += '            </dom6:TokenNF>'
                     _cXml += '         </tem:TokensXMLNotasFiscais>'
                     _cXml += '      </tem:IntegrarNotasFiscais>'
                     _cXml += '   </soapenv:Body>'
                     _cXml += '</soapenv:Envelope>'

                     oWsdl := tWSDLManager():New() // Cria o objeto da WSDL.  
                     oWsdl:nTimeout := 60          // Timeout de xx segundos                                                               
                     oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                               
                     
                     oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da TMS.   
                     oWsdl:SetOperation( "IntegrarNotasFiscais") // Define qual opera��o ser� realizada.   

                     // Envia para o servidor
                     _lOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da TMS.     
                     
                     If _lOk 

                        _cResult := oWsdl:GetParsedResponse() // Pega o resultado de envio j� no formato em string.  
                        oResult := XmlParser(oWsdl:GetSoapResponse(), cReplace, @cErros, @cAvisos)

                        /*
                        _nPosi := AT("<a:Objeto>", _cResult)             
                        _nPosf := AT("</a:Objeto>", _cResult)	
                        
                        If _nPosi == 0
                           _cProtocolo := ""
                        Else
                           _cProtocolo := substr(_cresult,_nposi+Len("<a:Objeto>"),_nposf-_nposi-Len("<a:Objeto>"))
                        Endif 
                        */
                        If oResult:_S_ENVELOPE:_S_BODY:_INTEGRARNOTASFISCAISRESPONSE:_INTEGRARNOTASFISCAISRESULT:_A_STATUS:TEXT == "false"
                           _lOk := .F.
                        Else
                           _cResult := "Integra��o Processada"
                        EndIf

                     Else 

                        _cResult := oWsdl:cError 
                        _cProtocolo := ""
                     
                     EndIf   

                     _cResposta := AllTrim(StrTran(_cResult,Chr(10)," "))
                     _cResposta := Upper(_cResposta)
                     
                     //grava resultado // sempre como processado
                     ZFK->(RecLock("ZFK",.F.))
                        ZFK->ZFK_SITUAC  := Iif(_lOk, "P", "N")
                        ZFK->ZFK_USUARI  := __CUSERID
                        ZFK->ZFK_DATAAL  := Date()
                        ZFK->ZFK_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFK,dizendo que deu certo ou n�o.
                        ZFK->ZFK_XML     := _cXML
                     ZFK->(MsUnlock()) 

                     If _lOk
                        /*
                        DBSelectArea("DAI")
                        DAI->( DBSetOrder(1) ) //DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
                       
                        If DAI->( DBSeek( DAK->(DAK_FILIAL+DAK_COD) ) )
                           Do While DAI->(!Eof()) .And. DAI->DAI_COD == DAK->DAK_COD .And. DAI->DAI_FILIAL == DAK->DAK_FILIAL
                              DBSelectArea("SF2")
                              SF2->( DBSetOrder(1) )
                              If SF2->( DBSeek( DAI->DAI_FILIAL + DAI->DAI_NFISCA + DAI->DAI_SERIE ) )
                                 RecLock("SF2",.F.)
                                    SF2->F2_I_SITUA := "V"
                                    //SF2->F2_I_PRTMS := _cProtocolo
                                 SF2->(MSUNLOCK())
                              EndIf
                              
                              DAI->(DbSkip())
                           EndDo
                        EndIf
                        
                        If aScan(_aCargaLibSNFe,{|x|x = DAK->(Recno())}) = 0
                           AADD(_aCargaLibSNFe,DAK->(Recno()))
                        EndIf   
                        */
                     EndIf
                        
                  Else
                     _cResposta := "N�o encontrada a carga '"+ZFK->ZFK_CARGA+"' para efetuar a integra��o"
                     _lOk := .F.
                  EndIf   
               End Sequence

               Aadd(_aLog,{_lOk,ZFK->ZFK_FILIAL,ZFK->ZFK_CHVNFE,ZFK->ZFK_PEDIDO,ZFK->ZFK_CGC,_cResposta,ZFK->(Recno())}) // adicona em um array para fazer um item list, exibir os resultados.
               Sleep(100) //Espera para n�o travar a comunica��o com o webservice da TMS

            EndIf

            FreeObj(oWsdl)
         
         Next

         //Inicia a Gera��o de Registros do Tipo de Integra��o (ZFK_TIPOI) = 5 
         /*If Len(_aCargaLibSNFe) > 0
            For _nI := 1 to Len(_aCargaLibSNFe)
               DAK->(DbGoTo(_aCargaLibSNFe[_nI]))
               If AOMS144U()
                  RecLock("ZFK",.T.)
                     ZFK->ZFK_FILIAL  := DAK->DAK_FILIAL    //	Filial do Sistema
                     ZFK->ZFK_CARGA   := DAK->DAK_COD
                     ZFK->ZFK_CARTMS  := DAK->DAK_I_RECR
                     ZFK->ZFK_HORA    := Time()             // Hora de inclus�o do registro na tabela de muro.
                     ZFK->ZFK_DATA    := Date()	            //	Data de Emiss�o
                     ZFK->ZFK_USUARI  := __CUSERID	         //	Codigo do Usu�rio
                     ZFK->ZFK_DATAAL  := Date()	            //	Data de Altera��o
                     ZFK->ZFK_SITUAC  := "N"                //	Situa��o do Registro
                     ZFK->ZFK_TIPOI   := "5"
                     ZFK->ZFK_CODEMP  := _cCodEmpWS         //	Codigo Empresa WebServer 
                     
                  ZFK->(MSUNLOCK())     
               EndIf
            Next

            AOMS144K()
            
         EndIf*/

      EndIf

      _cTextoFim := "Notas Fiscais integradas pelo metodo IntegrarNotasFiscais : "+STR(_nEnviados)+Chr(10)
      
      U_ItConout("[AOMS152F] >> Processamento conclu�do << Italac <---> TMS Multi-Embarcador "+_cTextoFim)
      
      If !_lScheduler
         U_ItMsg(">> Processamento conclu�do << "+Chr(10)+;
               "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+_cTextoFim+Chr(10),;
               "Fim de processamento",,2)
         
         If Len(_aLog) > 0

            U_ITListBox( 'Log de Processamento da Integra��o',;
            _aCabecLog, _aLog , .T. , 1 ,;
            "Abaixo segue a rela��o de processamento do m�todo IntegrarNotasFiscais" )

         EndIf
      EndIf
   Else
      If _lScheduler
         ConOut("[AOMS152I] - N�o foram encontrados dados para integra��o." )
      Else
         //U_ITMSG("N�o foram encontrados dados para integra��o.","Aten��o",,3, , , .T.)
         U_ItMsg(">> Processamento conclu�do << "+Chr(10)+;
         "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+"Sem dados para integra��o",;
         "Aten��o",,3)
      EndIf
   EndIf

End Sequence

If Select(_cAliasTMP) > 0
   (_cAliasTMP)->( DBCloseArea() )
Endif

RestOrd(_aOrd)

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS152P() // AOMS144G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/03/2025
===============================================================================================================================
Descri��o---------: Rotina de integra��o de dados das notas fiscais Protheus x TMS Multiembarcador.
                    Replica da fun��o AOMS144G adaptada para enviar os dados das cargas posicionadas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS152P() // AOMS144G()
Local _cQuery      := ""
Local _cTimeIni    := Time()
Local _cAlias      := "DAK"
Local _cAliasTMP   := "TRBAOMS152P" // AOMS144G"
Local _aAlias      := {}
Local _nRegAtu     := 0
Local _nTotRegs    := 0
Local _aCabec      := {}
Local _aPosCpo     := {}
Local _aSizes      := {}
Local _aCampos     := {}
Local _aLinha      := {}
Local _aDados      := {}
Local _lReturn     := .F.
Local _lOk         := .T.
Local _cMsg        := ""
Local _aLog        := {}
Local _aCabecLog   := {"Processado","Filial","Pedido","Chave NFe","Retorno", "Recno SF2"}

Local _cTextoFim   := ""
Local _nEnviados   := 0

Local _dDataIntTMS := U_ItGetMv("IT_DTINTTMS",Ctod("01/01/2024"))

Local _nI          := 0
Local _cTitulo     := ""
Local _cMsgTop     := ""
Local _cCodEmpWS   := U_ITGETMV( 'IT_EMPTMSM' , "000005")
Local _lSC5_PEDPA  := .F.
//Local _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) 
//Local _cPedProdu

Begin Sequence

   If !_lScheduler .AND. ! U_ItMsg("Confirma carga de registros para integra��o de Notas Fiscais >> Italac <---> TMS Multi-Embarcador?","Inicio de processamento",,4,2,2) 
      Break
   EndIf

   _aAlias := AOMS152MA(_cAlias,_cAliasTMP, .T.,.T.)

   _aCabec  := _aAlias[1]
   _aPosCpo := _aAlias[2]
   _aSizes  := _aAlias[3]
   _aCampos := _aAlias[4]

   _cQuery := "SELECT * "
   _cQuery += "FROM "+RetSqlName("DAK")+" DAK "
   _cQuery += " WHERE DAK_FILIAL ='" +DAK->DAK_FILIAL + "' "  
   _cQuery += " AND DAK_DATA >= '" + DTos(_dDataIntTMS) + "' "
   _cQuery += " AND DAK.D_E_L_E_T_ = ' ' "
   _cQuery += " AND DAK.DAK_COD = '" + DAK->DAK_COD + "' " 
   _cQuery += " AND NVL ( "
   _cQuery += "             (SELECT COUNT (1) "
   _cQuery += "              FROM "+RetSqlName("DAI")+" DAI "
   _cQuery += "              WHERE DAI_FILIAL = DAK_FILIAL "
   _cQuery += "                AND DAI_COD = DAK_COD "
   _cQuery += "                AND DAI.D_E_L_E_T_ = ' '),0) = NVL ( "
   _cQuery += "                                                      (SELECT COUNT (1) "
   _cQuery += "                                                       FROM "+RetSqlName("DAI")+" DAI, "
   _cQuery += "                                                            "+RetSqlName("SF2")+" SF2 "
   _cQuery += "                                                       WHERE DAI_FILIAL = DAK.DAK_FILIAL "
   _cQuery += "                                                         AND DAI_COD = DAK.DAK_COD "
   _cQuery += "                                                         AND DAI.D_E_L_E_T_ = ' ' "
   _cQuery += "                                                         AND F2_FILIAL = DAI_FILIAL "
   _cQuery += "                                                         AND F2_DOC = DAI_NFISCA "
   _cQuery += "                                                         AND F2_SERIE = DAI_SERIE "
   _cQuery += "                                                         AND SF2.D_E_L_E_T_ = ' '),0) "
   _cQuery += "   AND EXISTS "
   _cQuery += "              (SELECT 'X' "
   _cQuery += "                 FROM "+RetSqlName("DAI")+" DAI, "+RetSqlName("SF2")+" SF2 "
   _cQuery += "                WHERE     DAI_FILIAL = DAK.DAK_FILIAL "
   _cQuery += "                      AND DAI_COD = DAK.DAK_COD "
   _cQuery += "                      AND DAI.D_E_L_E_T_ = ' ' "
   _cQuery += "                      AND F2_FILIAL = DAI_FILIAL "
   _cQuery += "                      AND F2_DOC = DAI_NFISCA "
   _cQuery += "                      AND F2_SERIE = DAI_SERIE "
   _cQuery += "                      AND SF2.D_E_L_E_T_ = ' ' )"

   _cQuery := ChangeQuery(_cQuery)

   If Select(_cAliasTMP) > 0
      dbSelectArea(_cAliasTMP)
      dbCloseArea()
   EndIf

   //dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),_cAliasTMP,.F.,.T.)
   MPSysOpenQuery( _cQuery , _cAliasTMP)                         

   DBSelectArea(_cAliasTMP)
   Count to _nTotRegs

   IF !_lScheduler 
      ProcRegua(_nTotRegs)
   EndIf

   _cTotal := ALLTRIM(STR(_nTotRegs))

   If _nTotRegs > 0

      DBSelectArea(_cAliasTMP)
      (_cAliasTMP)->(DBGoTop())
      Do While (_cAliasTMP)->(!EOF())
         
         _nRegAtu++

         If !_lScheduler 
            IncProc("Lendo dados de Carga - Registro : " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
         EndIf

         _aLinha := {}
         For _nI := 1 To Len(_aCampos)
            Aadd(_aLinha, &(_aCampos[_nI]))
         Next

         Aadd(_aDados,_aLinha)

         (_cAliasTMP)->(Dbskip())

      EndDo

      If _lScheduler
      
         _lReturn := .T.
      
      Else
      
         _cTitulo := "Cargas que foram geradas a partir de integra��o com o TMS Multiembarcador "
         _cMsgTop := _cTitulo

                     //ITListBox( _cTitAux , _aHeader    , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda ,_lHasOk,_bHeadClk,_aSX1)
         _lReturn := U_ITListBox( _cTitulo , _aCabec     , _aDados   , .T.      , 2      , _cMsgTop ,          , _aSizes ,         ,     ,        ,          ,       ,         ,          ,           ,          ,       ,         ,     )
      
      EndIf

      If _lReturn
         
         For _nI := 1 To Len(_aDados) 

            If _lScheduler   
               U_ItConout("[AOMS152P] Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)  
            Else
               IncProc("Registros Lidos: "+ALLTRIM(STR(_nI))+" de "+_cTotal)   
            EndIf

            If _aDados[_nI][1] .OR. _lScheduler
               
               _cFilial := _aDados[_nI][aScan(_aPosCpo,{|x|x="DAK_FILIAL"})]
               _cCarga := _aDados[_nI][aScan(_aPosCpo,{|x|x="DAK_COD"})]

               DBSelectArea("DAI")
               DAI->( DBSetOrder(1) ) //DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
               If DAI->( DBSeek( _cFilial + _cCarga ) )
                  Do While DAI->(!Eof()) .And. DAI->DAI_COD == _cCarga .And. DAI->DAI_FILIAL == _cFilial

                     DBSelectArea("SF2")
                     SF2->( DBSetOrder(1) )
                     If SF2->( DBSeek( DAI->DAI_FILIAL + DAI->DAI_NFISCA + DAI->DAI_SERIE ) )

                        _nEnviados++ 
                        
                        If !_lScheduler 
                           IncProc("Gerando dados da Carga: " + _cCarga)  
                        Else
                           ConOut("[AOMS152P] - Gerando dados da Carga: " + _cCarga )
                        EndIf

                        _lSC5_PEDPA := .F.
      
                        If !Empty(Alltrim(SF2->F2_I_PEDID ))
                           DBSelectArea("SC5")
                           SC5->( DBSetOrder(1) )
                           If SC5->( DBSeek( SF2->F2_FILIAL + SF2->F2_I_PEDID ) )
                              _lSC5_PEDPA   := (SC5->C5_I_PEDPA == "S")
                              _cSC5_I_CDTMS := SC5->C5_I_CDTMS
                           Else
                              _lSC5_PEDPA   := .F.
                              _cSC5_I_CDTMS := ""
                           EndIf
                        EndIf

                        Begin Transaction

                           If !_lScheduler 
                              IncProc("Carregando Carga: " + DAK->DAK_COD)  
                           Else
                              ConOut("[AOMS152P] - Carregando Carga: " + DAK->DAK_COD )
                           EndIf

                           RecLock("ZFK",.T.)
                              ZFK->ZFK_FILIAL  := _aDados[_nI][aScan(_aPosCpo,{|x|x="DAK_FILIAL"})]     //	Filial do Sistema
                              ZFK->ZFK_CARGA   := _aDados[_nI][aScan(_aPosCpo,{|x|x="DAK_COD"})]
                              ZFK->ZFK_DATA    := _aDados[_nI][aScan(_aPosCpo,{|x|x="DAK_DATA"})]
                              //ZFK->ZFK_CARTMS  := _aDados[_nI][aScan(_aPosCpo,{|x|x="DAK_I_RECR"})]
                              ZFK->ZFK_CARTMS  := _aDados[_nI][aScan(_aPosCpo,{|x|x="DAK_I_PTMS"})]
                              ZFK->ZFK_PRTPED  := _cSC5_I_CDTMS
                              ZFK->ZFK_HORA    := Time()             // Hora de inclus�o do registro na tabela de muro.
                              ZFK->ZFK_DATA    := Date()	            //	Data de Emiss�o
                              ZFK->ZFK_CGC     := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_CGC")             //	CNPJ FORNECEDOR
                              ZFK->ZFK_CHVNFE  := SF2->F2_CHVNFE     //	Chave da NFe SEFAZ
                              ZFK->ZFK_PEDIDO  := SF2->F2_I_PEDID           //	Numero do Pedido(Na Italac h� um pedido por nota) // SF2->F2_I_PEDID
                              ZFK->ZFK_COD	  := SF2->F2_CLIENTE    // C�digo Cliente    // SA2->A2_COD  - Fornecedor    // O correto �: A1_COD
                              ZFK->ZFK_LOJA    := SF2->F2_LOJA       // Loja Cliente      // SA2->A2_LOJA - Fornecedor    //              A1_LOJA
                              ZFK->ZFK_NOME    := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")   // Nome Cliente      // SA2->A2_NOME - Fornecedor   //              A1_NOME
                              ZFK->ZFK_PRTMS   := SF2->F2_I_PRTMS
                              ZFK->ZFK_USUARI  := __CUSERID	         //	Codigo do Usu�rio
                              ZFK->ZFK_DATAAL  := Date()	            //	Data de Altera��o
                              ZFK->ZFK_SITUAC  := "N"                //	Situa��o do Registro
                              
                              If _lSC5_PEDPA                //  "S" = � um pedido de pallet.
                                 ZFK->ZFK_PEDPAL  := "S"             //  Grava dados informando que � um pedido de pallet.
                                 ZFK->ZFK_NRPPAL  := SC5->C5_I_NPALE //  Grava o numero do pedido de Pallet.
                              Else
                                 ZFK->ZFK_PEDPAL  := "N"             //  N�o � um pedido de Pallet.
                              EndIf

                              ZFK->ZFK_TIPOI   := "4"
                              ZFK->ZFK_CODEMP  := _cCodEmpWS         //	Codigo Empresa WebServer 
                           ZFK->(MSUNLOCK())
/*
                           RecLock("SF2",.F.)
                              SF2->F2_I_SITUA := "I"
                           SF2->(MSUNLOCK())
*/
                        End Transaction

                        _cMsg := "Carregado para Integra��o"

                     Else
                        _lOk := .F.
                        _cMsg := "Nota Fiscal n�o encontrada! Filial " + DAI->DAI_FILIAL + " Nota " + DAI->DAI_NFISCA + " Serie " + DAI->DAI_SERIE 
                     EndIf

                     AADD(_aLog,{_lOk, SF2->F2_FILIAL,SF2->F2_I_PEDID,SF2->F2_CHVNFE,_cMsg,SF2->(Recno())})

                     DAI->(DBSkip())
                  EndDo
               Else
                  _lOk := .F.
                  _cMsg := "Carga n�o encontrada! Filial " + _cFilial + " Carga " + _cCarga
                  
                  AADD(_aLog,{_lOk, SF2->F2_FILIAL,SF2->F2_I_PEDID,SF2->F2_CHVNFE,_cMsg,SF2->(Recno())})
               EndIf
               
            EndIf
         
         Next

         _cTextoFim := "Registros carregados para Integra��o de Notas Fiscais: "+STR(_nEnviados)+Chr(10)

         U_ItConout("[AOMS152P] >> Carregamento conclu�do << Italac <---> TMS Multi-Embarcador "+_cTextoFim)
         
         If !_lScheduler
            U_ItMsg(">> Carregamento conclu�do << "+Chr(10)+;
                  "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+_cTextoFim+Chr(10),;
                  "Fim de Carregamento",,2)
            
            If Len(_aLog) > 0

               U_ITListBox( 'Log de Processamento do carregamento de registros para Integra��o de Notas Fiscais',;
               _aCabecLog, _aLog , .T. , 1 ,;
               "Abaixo segue a rela��o de Carregamento" )

            EndIf
         EndIf

      EndIf
   Else
      If _lScheduler
         ConOut("[AOMS152] - N�o foram encontrados dados para integra��o." )
      Else
         //U_ITMSG("N�o foram encontrados dados para integra��o.","Aten��o",,3)
         U_ItMsg(">> Processamento conclu�do << "+Chr(10)+;
         "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+"Sem dados para integra��o",;
         "Aten��o",,3)
      EndIf
   EndIf

End Sequence

If Select(_cAliasTMP) > 0
   (_cAliasTMP)->( DBCloseArea() )
EndIf

Return _lReturn

/*
===============================================================================================================================
Programa----------: AOMS152E / AOMS144E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/03/2025
===============================================================================================================================
Descri��o---------: Rotina de Envio dos XMLs das notas fiscais para o sistema TMS Mulit-Embarcador.
                    Replica da fun��o AOMS144E, adaptada para enviar os XMLs para Carga Posicionada. 
===============================================================================================================================
Parametros--------: _lScheduler = .T. = Rotina chamada via agendamento/Scheduller.
                                  .F. = Rotina chamada via menu.
                    _lCargaPos  = .T. = Carga Posicionada.
                                  .F. = Carga ou Cargas informadas pelo usu�rio.               
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152E(_lScheduler, _lCargaPos) // AOMS144E()
Local _nI
//Local _lWsTms
Local _aParAux:= {}
Local _aParRet:= {}
Local _bQryFiltr
Local _aCargas 
Local _cCarga 
Local _dDataFilt := Date() - 730 // Data do dia, menos 2 anos.  

Begin Sequence 
   If ValType(_lScheduler) == "U"
      _lScheduler := .F.
   EndIf

   If ValType(_lCargaPos) == "U"
      _lCargaPos := .T.
   EndIf

   If _lScheduler 
      //=====================================================================
      // Limpa o ambiente, liberando a licen�a e fechando as conex�es
      //=====================================================================
      RpcClearEnv() 
      RpcSetType(2)
      
      //================================================================================
      // Prepara ambiente abrindo tabelas e incializando variaveis.
      //================================================================================   
      //PREPARE ENVIRONMENT EMPRESA '01' FILIAL "01"; 
      //        TABLES "CKO","ZG0","SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6","ZP1";
      //        MODULO 'OMS'
      RpcSetEnv("01", "01",,,,, {"CKO","ZG0","SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6","ZP1"})

      cFilAnt := "01"  
     
      //_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F. ) 

      //If _lWsTms // AOMS144VA()  // retorna se a integra��o com o TMS est� hbilitada para a Filial.
         AOMS152G() // AOMS152G() // AOMS144G() // L� os dados das notas fiscais para envio para o TMS
         AOMS152F() // AOMS144F() // Faz o envio dos XML das notas fiscais para o TMS
      //EndIf
      
      //============================================================
      //Limpa o ambiente, liberando a licen�a e fechando as conexoes
      //============================================================
      RpcClearEnv() 

   Else
      //_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F. ) 

      //If _lWsTms // AOMS144VA()

         If _lCargaPos
            Processa( {|| AOMS152G(),AOMS152F()},"Hora Ini: "+Time()+", Aguarde...") // Processa( {|| AOMS152G() // AOMS144G(),AOMS152F() // AOMS144F()},"Hora Ini: "+Time()+", Aguarde...")
         Else 
            _bQryFiltr := {|| "SELECT DISTINCT DAK_COD, A1_NOME FROM "+ RETSQLNAME("DAK") + " DAK, "+ RETSQLNAME("DAI") + " DAI, "+RETSQLNAME("SA1") + " SA1 " +"WHERE DAK.D_E_L_E_T_ = ' '  AND DAI.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = '" + xFilial("DAK") + "' AND DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD AND DAI_CLIENT = A1_COD AND DAI_LOJA = A1_LOJA AND DAK.DAK_DATA >= '"+ Dtos(_dDataFilt) +"' ORDER BY DAK_COD DESC "}     
            _aItalac_F3 := {}
            Aadd(_aItalac_F3,{"MV_PAR01",_bQryFiltr,{|Tab| (Tab)->DAK_COD },{|Tab| (Tab)->A1_NOME }  ,/*_bCondSA1*/ ,"Cargas",,,,.F.        ,       , } )
     
            Aadd( _aParAux , { 1 , "Cargas"       		, MV_PAR01, "@!"    , ""  , "F3ITLC"  , "" , 100 , .F. } )
     
            If !ParamBox( _aParAux , "Selecione o filtro" , @_aParRet,  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
               Break 
            EndIf 
            
            _aCargas := StrTokArr2( MV_PAR01, ";", .T. )
            For _nI := 1 To Len(_aCargas)
                _cCarga := _aCargas[_nI]
                //==========================================================
                // Posiciona a carga para a grava��o das tabela ZFQ e ZFR.  
                //==========================================================
                DAK->(DbSetOrder(1))
                If DAK->(MsSeek(xFilial("DAK")+U_ItKey(_cCarga,"DAK_COD")))
                   Processa( {|| AOMS152G(),AOMS152F()},"Hora Ini: "+Time()+", Aguarde...") // Processa( {|| AOMS152G() // AOMS144G(),AOMS152F() // AOMS144F()},"Hora Ini: "+Time()+", Aguarde...")
                EndIf 
            Next 
         EndIf    
      //EndIf
   EndIf

End Sequece 

Return Nil 

/*
===============================================================================================================================
Programa--------: AOMS152C // AOMS144C
Autor-----------: Julio de Paula Paz
Data da Criacao-: 28/03/2025
===============================================================================================================================
Descri��o-------: Rotina de Integra��o das Notas Fiscais Italac x TMS Multiembarcador.
                  Replica da fun��o AOMS144C, adaptada para enviar as notas fiscais para cargas posicionadas. 
===============================================================================================================================
Parametros------: _lScheduler = .T. = Rotina chamada via agendamento/Scheduller.
                                .F. = Rotina chamada via menu.
                  _lCargaPos  = .T. = Carga Posicionada.
                                .F. = Carga ou Cargas informadas pelo usu�rio.               
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS152C(_lScheduler, _lCargaPos) // AOMS144C()
Local _nI
Local _lWsTms
Local _aParAux:= {}
Local _aParRet:= {}
Local _bQryFiltr
Local _aCargas 
Local _cCarga 
Local _dDataFilt := Date() - 730 // Data do dia, menos 2 anos.  

Begin Sequence 
   
   If ValType(_lSchedule) == "U"
      _lSchedule := .F.
   EndIf

   If ValType(_lCargaPos) == "U"
      _lCargaPos := .T.
   EndIf

	If _lScheduler

		U_ItConout("[AOMS152] - Abrindo o ambiente..." )
		
		RpcSetType(3) //Nao consome licensas
		RpcSetEnv( "01" , "01" ,,,"OMS", "SCHEDULE_INT_CARGAS_TMS" , {'DAK','DAI','SF2','ZFK','SA1','SA2'} )
		Sleep( 5000 ) //Aguarda 5 segundos para subam as configura��es do ambiente.

      cFilAnt := "01"   
      
      //_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F. ) 

      //If _lWsTms // AOMS144VA()
         U_AOMS152P() // AOMS144G() // L� as cargas para envio das notas fiscais.
         U_AOMS152I() // AOMS144I() // Envia as notas fiscais com base nas cargas lidas.
      //EndIf

      //============================================================
      //Limpa o ambiente, liberando a licen�a e fechando as conexoes
      //============================================================
      RpcClearEnv() 

	Else
      
      _lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F. ) 
 
      //If _lWsTms
      
         If _lCargaPos
            Processa( {|| U_AOMS152P() ,U_AOMS152I() } , 'Aguarde!' , 'Processando Cargas...' ) // AOMS144G(),U_AOMS152I() // AOMS144I() } , 'Aguarde!' , 'Processando Cargas...' )
         Else 
            _bQryFiltr := {|| "SELECT DISTINCT DAK_COD, A1_NOME FROM "+ RETSQLNAME("DAK") + " DAK, "+ RETSQLNAME("DAI") + " DAI, "+RETSQLNAME("SA1") + " SA1 " +"WHERE DAK.D_E_L_E_T_ = ' '  AND DAI.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = '" + xFilial("DAK") + "' AND DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD AND DAI_CLIENT = A1_COD AND DAI_LOJA = A1_LOJA AND DAK.DAK_DATA >= '"+ Dtos(_dDataFilt) +"' ORDER BY DAK_COD DESC "}     
            _aItalac_F3 := {}
            Aadd(_aItalac_F3,{"MV_PAR01",_bQryFiltr,{|Tab| (Tab)->DAK_COD },{|Tab| (Tab)->A1_NOME }  ,/*_bCondSA1*/ ,"Cargas",,,,.F.        ,       , } )
     
            Aadd( _aParAux , { 1 , "Cargas"       		, MV_PAR01, "@!"    , ""  , "F3ITLC"  , "" , 100 , .F. } )
     
            If !ParamBox( _aParAux , "Selecione o filtro" , @_aParRet,  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
               Break 
            EndIf 
            
            _aCargas := StrTokArr2( MV_PAR01, ";", .T. )
            For _nI := 1 To Len(_aCargas)
                _cCarga := _aCargas[_nI]
                //==========================================================
                // Posiciona a carga para a grava��o das tabela ZFQ e ZFR.  
                //==========================================================
                DAK->(DbSetOrder(1))
                If DAK->(MsSeek(xFilial("DAK")+U_ItKey(_cCarga,"DAK_COD")))
                   Processa( {|| U_AOMS152P() ,U_AOMS152I() } , 'Aguarde!' , 'Processando Cargas...' ) // AOMS144G(),U_AOMS152I() // AOMS144I() } , 'Aguarde!' , 'Processando Cargas...' )
                EndIf 
            Next 
         EndIf    
      //EndIf     
	EndIf

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS152MA
Autor-------------: Igor Melga�o
Data da Criacao---: 15/02/2024
===============================================================================================================================
Descri��o---------: Valida dados da SF2, SC5 e DAK
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS152MA(_cAlias,_cAliasTmp,_lMark,_lFilial,_lRecno)
Local _aCabec := {}
Local _aPosCpo := {}
Local _aSizes := {}
Local _aCampos := {}
Local _nI := 0
Local _cAliasCMP := ""

Default  _lMark := .F.
Default  _lFilial := .F.
Default  _lRecno := .F.

Private aCols := {}
Private aHeader := {}

If _lMark
   Aadd(_aCabec,"")
   Aadd(_aPosCpo,"MARK")
   Aadd(_aSizes,10)
   Aadd(_aCampos,'.F.')
EndIf

If _lFilial
   If (_cAlias)->(FieldPos(_cAlias+"_FILIAL")) > 0
      _cAliasCMP := _cAlias
   Else
      _cAliasCMP := Subs(_cAlias,2,2)
   EndIf

   Aadd(_aCabec,"Filial")
   Aadd(_aPosCpo,_cAliasCMP+"_FILIAL")
   Aadd(_aSizes,10)
   Aadd(_aCampos,_cAliasCMP+"_FILIAL")
EndIf

aHeader := {}
FillGetDados(1,_cAlias,1,,,{||.T.},,,,,,.T.)

For _nI := 1 To Len(aHeader)

   If X3USO(GetSx3Cache(aHeader[_nI,2],"X3_USADO")) .AND. cNivel >= GetSx3Cache(aHeader[_nI,2],"X3_NIVEL") .AND. !(GetSx3Cache(aHeader[_nI,2],"X3_TIPO") = "M") .AND. GetSx3Cache(aHeader[_nI,2],"X3_BROWSE") == "S"

      If AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_CONTEXT"))  == "V"
         Aadd(_aCampos,StrTran(AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_INIBRW")),"DAK->",_cAliasTmp+"->"))
      Else
         If AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_TIPO")) == "D"
            Aadd(_aCampos,"STOD("+Alltrim(GetSx3Cache(aHeader[_nI,2],"X3_CAMPO"))+")")
         Else
            Aadd(_aCampos,Alltrim(GetSx3Cache(aHeader[_nI,2],"X3_CAMPO")))
         EndIf
      EndIf
      
      Aadd(_aPosCpo,AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_CAMPO")))
      Aadd(_aCabec ,AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_TITULO")))
      Aadd(_aSizes ,GetSx3Cache(aHeader[_nI,2],"X3_TAMANHO")* 3)
   EndIf
Next

If _lRecno
   Aadd(_aCabec,"Recno")
   Aadd(_aPosCpo,"R_E_C_N_O_")
   Aadd(_aSizes,10)
   Aadd(_aCampos,"R_E_C_N_O_")
EndIf

Return {_aCabec,_aPosCpo,_aSizes,_aCampos,}

/*
===============================================================================================================================
Programa----------: AOMS152VN // AOMS144VN
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/03/2025
===============================================================================================================================
Descri��o---------: Valida dados da SF2, SC5 e DAK antes da Integra��o.
                    Esta fun��o � r�plica da fun��o AOMS144VN adaptada para rotina de reenvio de cargas para o TMS.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS152VN(_lOk,_cMsg) // AOMS144VN(_lOk,_cMsg)
Local _cFilHabilit   := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x TMS Multi-Embarcador
Local _cListaFiliais := ""

_cListaFiliais := AllTrim(_cFilHabilit)                             
_cListaFiliais := StrTran(_cListaFiliais,";","','")    

//Com a SF2 devidamente posicionada
DAK->(dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))
SC5->(DbSeek(SF2->F2_FILIAL+SF2->F2_I_PEDID))

Begin Sequence

   If !(SF2->F2_FILIAL $ _cListaFiliais) // Ignora todas as filiais das notas fiscais que n�o est�o no par�metro e as filiais dos pedidos de origem da troca de nota que n�o est�o no par�metro.
      If Empty(SC5->C5_I_FLFNC) .Or. ! (SC5->C5_I_FLFNC $ _cListaFiliais) 
         _lOk := .F.
         _cMsg := "A Filial "+SC5->C5_I_FLFNC+" do pedido de venda "+SC5->C5_NUM+ " n�o est� no par�metro de filiais v�lidas para integra��o com o TMS"
         Break
      EndIf 
   EndIf
   
   If Empty(SC5->C5_I_FLFNC) // � um pedido de vendas normal. N�o � um pedido de troca nota.
      // Validar a exist�ncia de cargas apenas para Pedidos de Vendas Normais.      
      If Empty(DAK->DAK_I_CARG)
         _lOk := .F.
         _cMsg := "O pedido de venda "+SC5->C5_NUM+ " pedido de vendas normal. N�o � um pedido de troca nota e n�o existe cargas para ele."
         Break
      EndIf
   EndIf
   
   If Alltrim(SC5->C5_TIPO) <> "N" // Diferente de um pedido normal.
      _lOk := .F.
      _cMsg := "O pedido de venda "+SC5->C5_NUM+ " possui tipo (C5_TIPO) diferente de normal "
      Break
   EndIf
   
   If SC5->C5_I_TRCNF != "S" .AND. EMPTY(DAK->DAK_I_CARG)  //Se n�o � troca nota e carga n�o foi montada pelo RDC 
      _lOk := .F.
      _cMsg := "Se n�o � troca nota e carga n�o foi montada pelo TMS "
      Break
   EndIf
   
   If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDPR .AND. EMPTY(DAK->DAK_I_CARG)  //Se � troca nota, pedido de carregamento e carga n�o foi montada pelo RDC 
      _lOk := .F.
      _cMsg := "Se � troca nota, pedido de carregamento e carga n�o foi montada pelo TMS"
      Break
   EndIf
   
   If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDFT   //Se � troca nota, pedido de faturamento

      _nSC5 := SC5->(Recno())
      _nSF2 := SF2->(Recno())
      _nDAK := DAK->(Recno())
      
      _lOk := .F.
      
      If SC5->(dbseek(SC5->C5_I_FLFNC+SC5->C5_I_PDPR))
      
         If SF2->(dbseek(SC5->C5_FILIAL+SC5->C5_NOTA))
         
            If DAK->(dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))
            
               If !Empty(DAK->DAK_I_CARG) //Se achou a carga de carregamento e foi gerada pelo rdc deixa enviar o xml
               
                  _lOk := .T.
                  
               Endif
               
            Endif
            
         Endif
         
         SC5->(Dbgoto(_nSC5))
         SF2->(Dbgoto(_nSF2))
         DAK->(Dbgoto(_nDAK))

         If !_lOk
            Break
         Endif
      Endif
   Endif

End Sequence

Return Nil 

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*
===============================================================================================================================
Programa----------: AOMS152R()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/05/2025
===============================================================================================================================
Descri��o---------: Rotina de integra��o de Solicita��o de Emiss�o de nota fiscais.
===============================================================================================================================
Parametros--------: _lSchedule = .T. = modo agendado.
                                 .F. = modo manual/menu.
                    _cOpcao    = "P" = Carga posicionada.
                               = "S" = Selecionar Cargas.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152R(_lSchedule,_cOpcao)
Local _nTotRegs := 0
Local _aParAux:= {}
Local _aParRet:= {}
Local _bQryFiltr
Local _aCargas 
Local _cCarga 
Local _cDAK_Cod 
Local _nI 
Local _dDataFilt := Date() - 730 // Data do dia, menos 2 anos.  

Begin Sequence 

   If ValType(_lSchedule) == "U"
      _lSchedule := .F.
   EndIf 

   If ! _lSchedule
      If ! U_ITMSG("Confirma o reenvio da(s) Carga(s) para o Sistema TMS ?","Aten��o" , , ,2, 2)
         Break 
      EndIf
   EndIf  

   _cDAK_Cod := ""
   
   If _cOpcao == "P"
      //================================================================================
      // Grava os dados das tabelas ZFQ e ZFR para a carga posicionada.
      //================================================================================
      If _lSchedule
         AOMS152DAI()   // Grava os dados das tabelas ZFQ e ZFR para a carga posicionada.
      Else 
         Processa( {|| AOMS152DAI() } , 'Aguarde!' , 'Gravando Dados para Reenvio da Carga...' )
      EndIf 
      _cDAK_Cod := DAK->DAK_COD

   Else 
      //=================================================================================================
      // Grava os dados das tabelas ZFQ e ZFR para as cargas informadas pelo usu�rio na tela de filtro.
      //=================================================================================================
      If _lSchedule
         Break 
      EndIf 

      _bQryFiltr := {|| "SELECT DISTINCT DAK_COD, A1_NOME FROM "+ RETSQLNAME("DAK") + " DAK, "+ RETSQLNAME("DAI") + " DAI, "+RETSQLNAME("SA1") + " SA1 " +"WHERE DAK.D_E_L_E_T_ = ' '  AND DAI.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = '" + xFilial("DAK") + "' AND DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD AND DAI_CLIENT = A1_COD AND DAI_LOJA = A1_LOJA AND DAK.DAK_DATA >= '"+ Dtos(_dDataFilt) +"' ORDER BY DAK_COD DESC "}     
      _aItalac_F3 := {}
      Aadd(_aItalac_F3,{"MV_PAR01",_bQryFiltr,{|Tab| (Tab)->DAK_COD },{|Tab| (Tab)->A1_NOME }  ,/*_bCondSA1*/ ,"Cargas",,,,.F.        ,       , } )
     
      Aadd( _aParAux , { 1 , "Cargas"       		, MV_PAR01, "@!"    , ""  , "F3ITLC"  , "" , 100 , .F. } )
     
      If !ParamBox( _aParAux , "Selecione o filtro" , @_aParRet,  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
         Break 
      EndIf 
      _aCargas := StrTokArr2( MV_PAR01, ";", .T. )
      For _nI := 1 To Len(_aCargas)
          _cCarga := _aCargas[_nI]
          //==========================================================
          // Posiciona a carga para a grava��o das tabela ZFQ e ZFR.  
          //==========================================================
          DAK->(DbSetOrder(1))
          If DAK->(MsSeek(xFilial("DAK")+U_ItKey(_cCarga,"DAK_COD")))
             Processa( {|| AOMS152DAI() } , 'Aguarde!' , 'Gravando Dados para Reenvio da Carga...' )
             _cDAK_Cod += If(!Empty(_cDAK_Cod),";","") + DAK->DAK_COD
          EndIf 
      Next 
   EndIf 

   _cQry2 := " SELECT ZFQ.R_E_C_N_O_ ZFQ_RECNO,ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT " 
   _cQry2 += " FROM "+ RETSQLNAME("ZFQ") + " ZFQ "
   _cQry2 += " WHERE ZFQ.D_E_L_E_T_ <> '*' "
   _cQry2 += " AND ZFQ_SITUAC = 'C' "  
   _cQry2 += " AND ZFQ_NCARGA IN " + FormatIn(_cDAK_Cod,";")

   _cQry2 += " ORDER BY ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT "
   
   If Select("QRYZFQ") > 0
      QRYZFQ->( DBCloseArea() )
   EndIf

   MPSysOpenQuery( _cQry2 , "QRYZFQ") 

   DbSelectArea("QRYZFQ")

   Count To _nTotRegs 

   QRYZFQ->(DbGotop())
   
   If ! _lSchedule
      ProcRegua(_nTotRegs)
   EndIf 

   //====================================================================
   // Inicia Transmiss�o dos Dados Troca Nota para o TMS Multiembarcador
   //====================================================================
   If _lSchedule
      U_AOMS152B()
   Else 
      Processa( {|| U_AOMS152B() } , 'Aguarde!' , 'Reenviando a Carga para o Sistema TMS...' )
   EndIf 

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS152H()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/05/2025
===============================================================================================================================
Descri��o---------: Rotina de integra��o de Solicita��o de Emiss�o de Notas Fiscais para o sistema TMS Multiembarcador.
===============================================================================================================================
Parametros--------: _lSchedule = .T. = modo agendado.
                                 .F. = modo manual/menu.
                    _cOpcao    = "P" = Carga posicionada.
                               = "S" = Selecionar Cargas.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152H(_lSchedule,_cOpcao)
Local _aParAux:= {}
Local _aParRet:= {}
Local _bQryFiltr
Local _aCargas 
Local _cCarga 
Local _cDAK_Cod 
Local _nI 
Local _dDataFilt := Date() - 730 // Data do dia, menos 2 anos.  
Local _aRet := {.F.,"","","",""}
Local _aresult := {}
Local _aCabecalho := {}
Local _cTitulo

Begin Sequence 

   If ValType(_lSchedule) == "U"
      _lSchedule := .F.
   EndIf 

   If ! _lSchedule
      If ! U_ITMSG("Confirma a Integra��o de Solicita��o de Emiss�o de Notas Fiscais para o Sistema TMS ?","Aten��o" , , ,2, 2)
         Break 
      EndIf
   EndIf  

   _cDAK_Cod := ""
   
   If _cOpcao == "P"
      //===================================================================================
      // Roda a Rotina de solicita��o de emiss�o de nota fiscal para a carga posicionada.
      //___________________________________________________________________________________
      // _aRet :=  {1=True/False, // sucesso na integra��o / falha na integra��o
      //            2=Codigo da Mensagem de Retorno,
      //            3=C�digo e Mensagem de Retorno, 
      //            4=Xml de Retorno, 
      //            5=Xml de Envio}
      //===================================================================================
      If _lSchedule
         U_AOMS140P() // Chama a rotina de integra��o Webservice de solicita��o de emiss�o de nota fiscal.
      Else 
         //==============================================================================
         // Ap�s Fechar a Carga, Roda a Rotina de solicita��o de emiss�o de nota fiscal
         //______________________________________________________________________________
         // _aRet :=  {1=True/False, // sucesso na integra��o / falha na integra��o
         //            2=Codigo da Mensagem de Retorno,
         //            3=C�digo e Mensagem de Retorno, 
         //            4=Xml de Retorno, 
         //            5=Xml de Envio}
         //==============================================================================
         Processa( {|| _aRet := U_AOMS140P()} , 'Aguarde!' , 'Integrando Solicita��o Emiss�o de Notas Fiscais TMS...' ) // Chama a rotina de integra��o Webservice de solicita��o de emiss�o de nota fiscal.

         If _aRet[1]  // Solicita��o de Fechamento de Carga realizado com sucesso.
            Aadd(_aresult,{"Carga: >>>",DAK->DAK_COD,"","[Retorno Solicita��o de emiss�o de nota fiscal] : Sucesso - " + _aRet[2] + "-" + _aRet[3]}) // adicona em um array para fazer um item list, exibir os resultados.
         Else 
            Aadd(_aresult,{"Carga: >>>",DAK->DAK_COD,"","[Retorno Solicita��o de emiss�o de nota fiscal] : Erro - "    + _aRet[2] + "-" + _aRet[3]}) // adicona em um array para fazer um item list, exibir os resultados.
         EndIf 
      EndIf 
   Else 
      //=================================================================================================
      // Grava os dados das tabelas ZFQ e ZFR para as cargas informadas pelo usu�rio na tela de filtro.
      //=================================================================================================
      If _lSchedule
         Break 
      EndIf 

      _bQryFiltr := {|| "SELECT DISTINCT DAK_COD, A1_NOME FROM "+ RETSQLNAME("DAK") + " DAK, "+ RETSQLNAME("DAI") + " DAI, "+RETSQLNAME("SA1") + " SA1 " +"WHERE DAK.D_E_L_E_T_ = ' '  AND DAI.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = '" + xFilial("DAK") + "' AND DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD AND DAI_CLIENT = A1_COD AND DAI_LOJA = A1_LOJA AND DAK.DAK_DATA >= '"+ Dtos(_dDataFilt) +"' ORDER BY DAK_COD DESC "}     
      _aItalac_F3 := {}
      Aadd(_aItalac_F3,{"MV_PAR01",_bQryFiltr,{|Tab| (Tab)->DAK_COD },{|Tab| (Tab)->A1_NOME }  ,/*_bCondSA1*/ ,"Cargas",,,,.F.        ,       , } )
     
      Aadd( _aParAux , { 1 , "Cargas"       		, MV_PAR01, "@!"    , ""  , "F3ITLC"  , "" , 100 , .F. } )
     
      If !ParamBox( _aParAux , "Selecione o filtro" , @_aParRet,  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
         Break 
      EndIf 
      _aCargas := StrTokArr2( MV_PAR01, ";", .T. )
      For _nI := 1 To Len(_aCargas)
          _cCarga := _aCargas[_nI]

          DAK->(DbSetOrder(1))
          If DAK->(MsSeek(xFilial("DAK")+U_ItKey(_cCarga,"DAK_COD")))
             //==============================================================================
             // Ap�s Fechar a Carga, Roda a Rotina de solicita��o de emiss�o de nota fiscal
             //______________________________________________________________________________
             // _aRet :=  {1=True/False, // sucesso na integra��o / falha na integra��o
             //            2=Codigo da Mensagem de Retorno,
             //            3=C�digo e Mensagem de Retorno, 
             //            4=Xml de Retorno, 
             //            5=Xml de Envio}
             //==============================================================================
             Processa( {|| _aRet := U_AOMS140P()} , 'Aguarde!' , 'Integrando Solicita��o Emiss�o de Notas Fiscais TMS...' ) // Chama a rotina de integra��o Webservice de solicita��o de emiss�o de nota fiscal.

             If _aRet[1]  // Solicita��o de Fechamento de Carga realizado com sucesso.
                Aadd(_aresult,{"Carga: >>>",DAK->DAK_COD,"","[Retorno Solicita��o de emiss�o de nota fiscal] : Sucesso - " + _aRet[2] + "-" + _aRet[3]}) // adicona em um array para fazer um item list, exibir os resultados.
             Else 
                Aadd(_aresult,{"Carga: >>>",DAK->DAK_COD,"","[Retorno Solicita��o de emiss�o de nota fiscal] : Erro - "    + _aRet[2] + "-" + _aRet[3]}) // adicona em um array para fazer um item list, exibir os resultados.
             EndIf 
          EndIf 
      Next 
   EndIf 

   _aCabecalho := {}
   Aadd(_aCabecalho,"PEDIDO" ) 
   Aadd(_aCabecalho,"CARGA" ) 
   Aadd(_aCabecalho,"CNPJ") 
   Aadd(_aCabecalho,"RETORNO") 
             
   _cTitulo := "Resultados da integra��o"
      
   If len(_aresult) > 0 .AND. !_lSchedule
      U_ITListBox( _cTitulo , _aCabecalho , _aresult  ) // Exibe uma tela de resultado.
      _aresult := {}
  	EndIf

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS152W()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 30/05/2025
===============================================================================================================================
Descri��o---------: Rotina de integra��o para Solicitar Cancelamento Da Carga para o sistema TMS Multiembarcador.
===============================================================================================================================
Parametros--------: Nenhum 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152W()
Local _aParaux   := {}
Local _aParRet   := {}
//----------------------------
Local oWsdl
Local _cXML           := ""
Local _cLink          := ""
Local _cToken         := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")
Local _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
Local _lReturn        := .F.
Local cReplace:= ""
Local cErros:= ""
Local cAvisos := ""

Begin Sequence 

   If ! _lSchedule
      If ! U_ITMSG("Confirma a Integra��o de Solicita��o de Cancelamento de Carga para o Sistema TMS ?","Aten��o" , , ,2, 2)
         Break 
      EndIf
   EndIf  

   MV_PAR01 := Space(20)
       
   Aadd( _aParAux , { 1 , "Numero Protocolo Integra��o de Carga"   , MV_PAR01, "@!", ""	, ""	  , ""          ,050      , .T. } )
         
   Aadd(_aParRet,"MV_PAR01")
         
   If !ParamBox( _aParAux , "Integra uma Solicita��o de Cancelamento de Cargas para o Sistema TMS" , @_aParRet )
	   U_ItMsg( "Opera��o cancelada pelo usu�rio!" , "Aten��o!",,1 )
	   Break 
	EndIf

   If Empty(MV_PAR01)
      U_ItMsg( "Protocolo de integra��o de cargas n�o preenchido." , "Aten��o!",,1 )
	   Break 
   EndIf 

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
		_cLink   := AllTrim(ZFM->ZFM_LINK01) //Cargas
   Else            
      MsgInfo("Empresa WebService para envio dos dados n�o localizada.","Aten��o")
   EndIf

   If Empty(_cLink)
      U_ItMsg( "Link de integra��o de cargas n�o preenchido." , "Aten��o!",,1 )
	   Break 
   EndIf 
      
   oWsdl := tWSDLManager():New() // Cria o objeto da WSDL.  
   oWsdl:nTimeout := 60          // Timeout de xx segundos                                                               
   oWsdl:lSSLInsecure := .T.     //   Acessa com certificado an�nimo                                                               
   
   oWsdl:ParseURL( _cLink)       // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da TMS.   

   oWsdl:SetOperation( "SolicitarCancelamentoDaCarga") // Define qual opera��o ser� realizada.   
 
	_cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
	_cXML += '<soapenv:Header>'
	_cXML += '    <Token xmlns="Token">'+_cToken+'</Token>'
	_cXML += '</soapenv:Header>'
	_cXML += '   <soapenv:Body>'
	_cXML += '      <tem:SolicitarCancelamentoDaCarga>'
	_cXML += '         <tem:protocoloIntegracaoCarga>'+AllTrim(MV_PAR01)+'</tem:protocoloIntegracaoCarga>'
	_cXML += '      </tem:SolicitarCancelamentoDaCarga>'
	_cXML += '   </soapenv:Body>'
	_cXML += '</soapenv:Envelope>'

	// Envia para o servidor
	_lOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da TMS.     

   _lReturn := .T.

   _cMensagem := " "

	If _lOk 
		_cResult := oWsdl:GetParsedResponse() // Pega o resultado de envio j� no formato em string.  
		oResult  := XmlParser(oWsdl:GetSoapResponse(), cReplace, @cErros, @cAvisos)
		_cMensagem := _cResult

		If oResult:_S_ENVELOPE:_S_BODY:_SolicitarCancelamentoDaCargaRESPONSE:_SolicitarCancelamentoDaCargaRESULT:_A_STATUS:TEXT == "false"
			_lReturn   := .F.
			//_cMensagem := oResult:_S_ENVELOPE:_S_BODY:_SolicitarCancelamentoDaCargaRESPONSE:_SolicitarCancelamentoDaCargaRESULT:_A_MENSAGEM:TEXT
		EndIf
	Else 
		_lReturn := .F.
		_cMensagem  := oWsdl:cError 
	EndIf   
   
   If _lReturn
      U_ItMsg( "Solicita��o de Cancelamento de Carga realizada com sucesso para o Sistema TMS Multiembarcador: " + AllTrim(_cMensagem) , "Aten��o!",,2 )
   Else 
      U_ItMsg( "Falha na Solicita��o de Cancelamento de Carga para o Sistema TMS Multiembarcador: " + AllTrim(_cMensagem) , "Aten��o!",,1 )
   EndIf 

End Sequence 

U_ItMsg( "Termino da rotina de solicita��o de cancelamento de cargas para o sistema TMS Multiembarcador." , "Aten��o!",,2 )

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS152Y()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/06/2025
===============================================================================================================================
Descri��o---------: Webservice de integra��o de situa��o de pedidos de vendas para o sistema TMS Multiembarcador.
===============================================================================================================================
Parametros--------: Nenhum 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152Y()
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
//----------------------------------------------------------  // JPP TESTE
        // Incluir chamada para o TMS Aqui. 

        //================================================================================
        // Se o Webservice de integra��o dom o TMS Multiembarcador estiver ativo
        // para este local de embarque,  roda a rotina de integra��o Webservice
        // de envio de situa��o de Pedidos de vendas para o sistema TMS Multiembarcador. 
        //================================================================================
        If ! U_IT_TMS(SC5->C5_I_LOCEM) 

        EndIf  
//----------------------------------------------------------
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

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS152J()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/06/2025
===============================================================================================================================
Descri��o---------: Rotina que retorna o Status do Estoque do Pedido de Vendas.
                    Considera estar posicionado no pedido de vendas, tabela SC5.
===============================================================================================================================
Parametros--------: Nenhum 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS152J()
Local _aRet := {"01","Sem Reserva"}
Local _lBloqEst  := .F.
Local _lLiberado := .T.

//======================================
// Codigo Integra��o | Descri��o       |
//--------------------------------------
//  01               | Sem Reserva     |
//  02               | Liberado        |
//  03               | Bloqueado       |
//--------------------------------------

Begin Sequence 
   
   SC9->(DbSetorder(1))
   SC6->(DbSetOrder(1))
   SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
   
	Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->C5_FILIAL+SC5->C5_NUM

		If !(SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) 
         _lLiberado := .F.
      ElseIf !Empty(SC9->C9_BLEST)  // verifica estoque se n�o tem libera��o v�lida ainda
         _lBloqEst  := .T.
      EndIf 

		SC6->(Dbskip())
   EndDo
   
   If _lBloqEst
      _aRet := {"03","Bloqueado"}
   ElseIf _lLiberado 
      _aRet := {"02","Liberado"}
   EndIf 

End Sequence 

Return _aRet
