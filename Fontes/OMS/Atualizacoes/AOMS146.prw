/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===========================================================================================================================================================================================================================================================
 Analista       - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o
============================================================================================================================================================================================================================================================
Vanderlei       - Julio Paz    - 01/08/24 - 10/06/25 - 45229   - Desenvolvimento do novo webservice OMS-Protheus x TMS-Multiembarcador.
============================================================================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#Include "FWMVCDef.Ch"

/*
===============================================================================================================================
Fun��o------------: AOMS146A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de Envio de Notas Fiscais e Vincula��o de Pedidos de Vendas com Notas Fiscais para Pedidos de 
                    Vendas do Tipo Troca Nota Fiscal. Chamado 46163.
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Rotina chamada Via Scheduller.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS146A(_lScheduller)    
Local _cFilHabil := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x TMS Multi-Embarcador
Local _cQry        := ""
Local _dDtAtvTms := Ctod(U_ITGETMV( 'IT_DTATIVTMS' , '01/10/2023'))
Local _nRegAtu := 0
Local _nTotRegs
Local _lSC5_PEDPA   := .F.
Local _cSC5_I_CDTMS := ""

Begin Sequence 
 
   If !_lScheduller .AND. ! U_ItMsg("Confirma a grava��o de dados de XML das notas fiscais dos pedidos de vendas troca nota, para envio para o TMS MultiEmbarcador? ","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146A] - Inicio grava��o dos dados de XML das notas fiscais dos pedidos de vendas troca nota, para envio para o TMS MultiEmbarcador.")      
   EndIf
   
   //=================================================================
   // Query para gerar registros na tabela ZFK com ZFK_TIPOI = '7' 
   //=================================================================
   _cQry := " SELECT DISTINCT DAK.DAK_FILIAL, " 
   _cQry += " DAK.DAK_COD, " 
   _cQry += " DAI.DAI_NFISCA, " 
   _cQry += " ZFQ_CARTMS, " 
   _cQry += " ZFQ_PEDIDO, " 
   _cQry += " ZFQ_RASTMS, " 
   _cQry += " SPED50.R_E_C_N_O_     NREC50, " 
   _cQry += " SF2.R_E_C_N_O_        NRECSF2, " 
   _cQry += " SPED54.R_E_C_N_O_     NREC54, " 
   _cQry += " DAK.R_E_C_N_O_        NRECDAK " 
   _cQry += " FROM "+RetSqlName("DAK") + " DAK, "
   _cQry +=          RetSqlName("DAI") + " DAI, "
   _cQry +=          RetSqlName("ZFQ") + " ZFQ, " 
   _cQry +=          RetSqlName("SF2") + " SF2, "
   _cQry +=         " SPED050 SPED50, " 
   _cQry +=         " SPED054 SPED54 " 
   _cQry += " WHERE  DAK.DAK_FILIAL IN " + FormatIn(_cFilHabil,";") // Filiais do par�metro IT_WEBSTMS
   _cQry += " AND DAK.DAK_DATA >= '" + Dtos(_dDtAtvTms) +"' "
   _cQry += " AND DAK.DAK_I_TRNF IN ('C', 'F') "
   _cQry += " AND DAK.D_E_L_E_T_ = ' '  "
   _cQry += " AND DAI.DAI_FILIAL = DAK.DAK_FILIAL " 
   _cQry += " AND DAI.DAI_COD = DAK.DAK_COD "

   //_cQry += " AND DAI.DAI_COD = '244855' " // JPP TESTE
   //_cQry += " AND DAI.DAI_FILIAL = '01' "  // JPP TESTE

   _cQry += " AND DAI.D_E_L_E_T_ = ' ' "
   _cQry += " AND SF2.F2_FILIAL = DAI.DAI_FILIAL "
   _cQry += " AND SF2.F2_DOC = DAI.DAI_NFISCA "
   _cQry += " AND SF2.F2_SERIE = DAI.DAI_SERIE "
   _cQry += " AND SF2.D_E_L_E_T_ = ' ' "
   _cQry += " AND DOC_CHV = F2_CHVNFE "
   _cQry += " AND NFE_CHV = F2_CHVNFE "
   _cQry += " AND SPED50.STATUS = '6' "
   _cQry += " AND SPED54.CSTAT_SEFR = '100' "
   _cQry += " AND SPED50.D_E_L_E_T_ = ' ' "
   _cQry += " AND SPED54.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZFQ.ZFQ_FILIAL = DAK.DAK_FILIAL "
   _cQry += " AND ZFQ.ZFQ_NCARGA = DAK.DAK_COD "
   _cQry += " AND ZFQ.ZFQ_NUMNFE = DAI.DAI_NFISCA "
   _cQry += " AND ZFQ.ZFQ_SERINF = DAI.DAI_SERIE "
   _cQry += " AND ZFQ.ZFQ_SITUAC = 'P' "
   _cQry += " AND ZFQ.D_E_L_E_T_ = ' ' "
   _cQry += " AND NVL ( "
   _cQry += " (SELECT COUNT (1) "
   _cQry += " FROM " + RETSQLNAME("DAI") + " DAIC "
   _cQry += " WHERE DAIC.DAI_FILIAL = DAK.DAK_FILIAL "
   _cQry += " AND DAIC.DAI_COD = DAK.DAK_COD "
   _cQry += " AND DAIC.D_E_L_E_T_ = ' '), "
   _cQry += " 0) = "
   _cQry += " NVL ( "
   _cQry += " (SELECT COUNT (1) "
   _cQry += " FROM " + RETSQLNAME("DAI") + " DAIC, "
   _cQry += RETSQLNAME("SF2") + " SF2B, "
   _cQry += " SPED050 SPED50, "
   _cQry += " SPED054 SPED54 "
   _cQry += " WHERE DAIC.DAI_FILIAL = DAK.DAK_FILIAL "
   _cQry += " AND DAIC.DAI_COD = DAK.DAK_COD "
   _cQry += " AND DAIC.D_E_L_E_T_ = ' ' "
   _cQry += " AND SF2B.F2_FILIAL = DAIC.DAI_FILIAL "
   _cQry += " AND SF2B.F2_DOC = DAIC.DAI_NFISCA "
   _cQry += " AND SF2B.F2_SERIE = DAIC.DAI_SERIE "
   _cQry += " AND SF2B.F2_I_PRTMS <> ' ' "
   _cQry += " AND SF2B.D_E_L_E_T_ = ' ' "
   _cQry += " AND DOC_CHV = F2_CHVNFE "
   _cQry += " AND NFE_CHV = SF2B.F2_CHVNFE "
   _cQry += " AND SPED50.STATUS = '6' "
   _cQry += " AND SPED54.CSTAT_SEFR = '100' "
   _cQry += " AND SPED50.D_E_L_E_T_ = ' ' "
   _cQry += " AND SPED54.D_E_L_E_T_ = ' '), "
   _cQry += " 0) "
   _cQry += " AND EXISTS "
   _cQry += " (SELECT 'x' "
   _cQry += " FROM " + RETSQLNAME("ZFQ") + " ZFQF "
   _cQry += " WHERE ZFQF.ZFQ_FILIAL = DAK.DAK_FILIAL "
   _cQry += " AND ZFQF.ZFQ_NCARGA = DAK.DAK_COD "
   _cQry += " AND ZFQF.ZFQ_SITUAC = 'E' "
   _cQry += " AND ZFQF.D_E_L_E_T_ = ' ') "
   _cQry += " AND NOT EXISTS "
   _cQry += " (SELECT 'X' "
   _cQry += " FROM " + RETSQLNAME("ZFK") + " ZFK "
   _cQry += " WHERE ZFK.ZFK_FILIAL = DAI.DAI_FILIAL "
   _cQry += " AND ZFK.ZFK_PEDIDO = DAI.DAI_PEDIDO "
   _cQry += " AND ZFK.ZFK_TIPOI = '7' "
   //_cQry += " AND ZFK.ZFK_SITUAC = 'P' "   // JPP TESTE - Trecho comentado por solicita��o do Vanderlei.
   _cQry += " AND ZFK.D_E_L_E_T_ = ' ') "
   _cQry += " ORDER BY ZFQ_CARTMS, ZFQ_RASTMS "

   _cQry := ChangeQuery(_cQry)         

   If Select("NFETNF") > 0
      NFETNF->( DBCloseArea() )
   EndIf

   DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "NFETNF" , .T., .F. )                            
   
   DBSelectArea("NFETNF")                                                                               
   COUNT TO _nTotRegs

   IF !_lScheduller 
      ProcRegua(_nTotRegs)
   EndIf

   NFETNF->(DBGoTop())
   
   If _nTotRegs == 0
      Break 
   EndIf 
   
   //===================================================================================================
   // Abre o arquivo de Sped para leitura dos XML e Envio para o TMS MultiEmbarcador.
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

   _nRegAtu := 0

   Do While ! NFETNF->(Eof()) 

      _nRegAtu++

      If !_lScheduller 
         IncProc("Lendo dados Notas Fiscais-Pedidos V.Troca Nota: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
      Else 
         U_ITCONOUT("[AOMS146A] - Lendo dados Notas Fiscais-Pedidos V.Troca Nota: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))
      EndIf

      SF2->(DbGoTo(NFETNF->NRECSF2)) 
      DAK->(DbGoTo(NFETNF->NRECDAK))
      SPED054->(DbGoTo(NFETNF->NREC54))
      SPED050->(DbGoTo(NFETNF->NREC50))

      If SC5->( DBSeek( SF2->F2_FILIAL + SF2->F2_I_PEDID ) )
         _lSC5_PEDPA   := (SC5->C5_I_PEDPA == "S")
         _cSC5_I_CDTMS := SC5->C5_I_CDTMS
      Else
         _lSC5_PEDPA   := .F.
         _cSC5_I_CDTMS := ""
      EndIf

      If Empty(_cSC5_I_CDTMS) // Pedido de Vendas n�o integrado para o TMS MultiEmbarcador.
         NFETNF->(DbSkip())
         Loop
      EndIf 

      //===================================================================================================
      // Monta XML para envio ao TMS MultiEmbarcador.
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
      ZFK->ZFK_CARTMS := DAK->DAK_I_PTMS // DAK->DAK_I_RECR 
      ZFK->ZFK_PRTPED := NFETNF->ZFQ_RASTMS //_cSC5_I_CDTMS 
      ZFK->ZFK_DATA   := Date()  
      ZFK->ZFK_HORA   := Time()
      ZFK->ZFK_TIPOI  := "7"
      ZFK->ZFK_CHVNFE := SF2->F2_CHVNFE
      ZFK->ZFK_PEDPAL := Iif(_lSC5_PEDPA ,"S","N") 
      ZFK->ZFK_NRPPAL := Iif(_lSC5_PEDPA ,SF2->F2_I_PEDID ,"")    
      ZFK->ZFK_CGC    := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_CGC") 
      ZFK->ZFK_PEDIDO := NFETNF->ZFQ_PEDIDO // SC5->C5_NUM 
      ZFK->ZFK_COD	  := SF2->F2_CLIENTE    
      ZFK->ZFK_LOJA   := SF2->F2_LOJA       
      ZFK->ZFK_NOME   := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME") 
      ZFK->ZFK_USUARI := __cUserId
      ZFK->ZFK_SITUAC := "N" 
      ZFK->ZFK_XML    := _cXML_Nfe
      ZFK->(MsUnLock())

      NFETNF->(DbSkip())
   EndDo

End Sequence

If !_lScheduller 
   U_ItMsg("Termino da grava��o dos dados das notas fiscais Pedidos de Vendas Troca NF - Protheus x TMS MultiEmbarcador.","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146A] - Termino da grava��o dos dados das notas fiscais Pedidos de Vendas Troca NF - Protheus x TMS MultiEmbarcador.")
EndIf

If Select("NFETNF") > 0
   NFETNF->( DBCloseArea() )
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
Fun��o------------: AOMS146B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de transmiss�o de dados de Notas Fiscais e Vincula��o de Pedidos de Vendas com Notas Fiscais para 
                    Pedidos de Vendas do Tipo Troca Nota Fiscal. Chamado 46163.
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Rotina chamada Via Scheduller.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS146B(_lScheduller) 
Local _cQry      := ""
Local _cFilHabil := U_ITGETMV( 'IT_FILINTWS' , '' ) 
Local _cCanPXML
Local _cDirXML
Local _cLink
Local _cCodEmpWS
Local _cXML
Local _lOk           := .F.
Local _cResult       := ""
Local _cProtocolo    := ""
//Local _nPosi         := 0
//Local _nPosf         := 0
//Local _cXML_Nfe      := ""
Local oWsdl

Private _cToken

Begin Sequence 
   
   If !_lScheduller .AND. ! U_ItMsg("Confirma envio de arquivos XML das Notas Fiscais para Pedidos de Vendas Troca Nota Fiscal, para o Sistema TMS MultiEmbarcador?","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146B] Inicio do envio de arquivos XML das Notas Fiscais para Pedidos de Vendas Troca Nota Fiscal, para o Sistema TMS MultiEmbarcador.")   
   EndIf

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   
   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK02)  // Link de envio dos dados da nota fiscal.
   Else         
      If ! _lScheduller
         U_ItMsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146B] Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146B] Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   _cCanPXML := U_AOMS146X(_cDirXML+"enviararquivoxmlnfe_tms.txt") 
   
   If Empty(_cCanPXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo de Envio de Arquivo XML NFE, para pedidos de vendas Troca Nota Fiscal. ","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146B] Erro na leitura do arquivo XML modelo de Envio de Arquivo XML NFE, para pedidos de vendas Troca Nota Fiscal. ")
      EndIf
      Break
   EndIf
 
   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================
   _cQry := " SELECT ZFK.R_E_C_N_O_ NRREG "
   _cQry += " FROM "+RetSqlName("ZFK")+" ZFK "
   _cQry += " WHERE ZFK.D_E_L_E_T_ <> '*' "
   _cQry += "   AND ZFK_TIPOI = '7' "
   _cQry += "   AND (ZFK_SITUAC = 'N' OR  ZFK_SITUAC = 'R') "
   _cQry += "   AND ZFK_FILIAL IN "+FormatIn(ALLTRIM(_cFilHabil),";")

   _cQry := ChangeQuery(_cQry)          

   If Select("ZFKTNF") > 0
      ZFKTNF->( DBCloseArea() )
   EndIf

   DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "ZFKTNF" , .T., .F. )                            
   
   DBSelectArea("ZFKTNF")                                                                                  
   COUNT TO _nTotRegs

   IF !_lScheduller
      ProcRegua(_nTotRegs)
   EndIf

   If _nTotRegs == 0
      Break 
   EndIf 

   ZFKTNF->(DbGoTop())
   
   _nRegAtu := 0

   Do While !ZFKTNF->(Eof()) 

      _nRegAtu++

      If !_lScheduller 
         IncProc("Enviando dados das Notas Fiscais-Pedidos Troca Nota para Envio ao TMS: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
      Else 
         U_ITCONOUT("[AOMS146B] - Enviando dados das Notas Fiscais-Pedidos Troca Nota para Envio ao TMS: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))
      EndIf

      ZFK->(DbGoto(ZFKTNF->NRREG))

      _cXML_Nfe := ZFK->ZFK_XML // Vari�vel do modelo XML

      _cXMLEnv := &(_cCanPXML)

      _nIniCarre := 1   // Inicio da leitura das cargas pendentes no TMS.
      _nLimCarre := 100 // N�mero M�ximo de Registros Lidos.

      oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
      oWsdl:nTimeout := 10          // Timeout de 10 segundos 
      oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    

      oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
      oWsdl:SetOperation( "EnviarArquivoXMLNFe") // Define qual opera��o ser� realizada.

      // Envia para o servidor
      _lOk := oWsdl:SendSoapMsg(_cXMLEnv) // Este comando pega o XML e envia para o servidor da TMS MultiEmbarcador.  

      _cProtocolo := ""
      _cStatus    := ""         

      If _lOk 
         _cResult := oWsdl:GetSoapResponse()

         cError   := ""
         cWarning := ""

         _oXml := XmlParser(_cResult, "_", @cError, @cWarning )

         _cProtocolo := _oxml:_s_Envelope:_s_Body:_EnviarArquivoXMLNFeResponse:_EnviarArquivoXMLNFeResult:_a_Objeto:text

         //_cStatus := _oxml:_s_Envelope:_s_Body:_EnviarArquivoXMLNFeResponse:_EnviarArquivoXMLNFeResult:_a_status:text
      Else
         _cResult := oWsdl:cError
         _cProtocolo := ""
      EndIf   

      If _lOk  .And. ! Empty(_cProtocolo)
         SF2->(RecLock("SF2",.F.))
         //SF2->F2_I_SITUA := 'P'    
         SF2->F2_I_DTENV := Date()
         SF2->F2_I_HRENV := Time()
         SF2->F2_I_PRTMS := _cProtocolo      //Protocolo TMS
         SF2->(MsUnLock())
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

      If ValType(oWSDL) == "O"
         FreeObj(oWsdl)
      EndIf 
      oWsdl := Nil
      
      ZFKTNF->(DbSkip())
   EndDo

End Sequence

If !_lScheduller 
   U_ItMsg("Termino do envio das Notas Fiscais-Pedidos Troca Nota para Envio ao TMS - Protheus x TMS MultiEmbarcador. ","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146B] - Termino do envio das Notas Fiscais-Pedidos Troca Nota para Envio ao TMS - Protheus x TMS MultiEmbarcador.  ")
EndIf

If Select("ZFKTNF") > 0
   ZFKTNF->( DBCloseArea() )
EndIf

Return Nil

/*
===============================================================================================================================
Fun��o-------------: AOMS146X
Aut2or-------------: Julio de Paula Paz
Data da Criacao----: 01/08/2024
===============================================================================================================================
Descri��o---------: L� o arquivo XML modelo no diret�rio informado e retorna os dados no formato de String.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/  
User Function AOMS146X(_cArq)
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
Fun��o------------: AOMS146C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de Grava��o dos Dados de Vincula��o de Notas Fiscais com Pedidos de Vendas, para pedidos de 
                    Vendas Troca Nota Fiscal.
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Rotina chamada Via Scheduller.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS146C(_lScheduller )
Local _cQry
Local _nTotRegs 

Begin Sequence

   If !_lScheduller .AND. ! U_ItMsg("Confirma a Grava��o dos Dados de Vincula��o de Pedidos de Vendas com Notas Fiscais, para Pedidos de Vendas Troca Nota Fiscal integrados para o TMS MultiEmbarcador?","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146C] - Inicio grava��o dos dados de Vincula��o Pedido Vendas com NFE - Protheus x TMS MultiEmbarcador. ")      
   EndIf

   _cQry := " SELECT ZFK.R_E_C_N_O_ NRREG "  
   _cQry += " FROM " + RETSQLNAME("ZFK") + " ZFK "
   _cQry += " WHERE     ZFK_TIPOI = '7' "
   _cQry += " AND ZFK.D_E_L_E_T_ = ' ' "
   _cQry += " AND NVL ( "
   _cQry += " (SELECT COUNT (1) "
   _cQry += " FROM " + RETSQLNAME("DAI")  + " DAI "
   _cQry += " WHERE DAI.DAI_FILIAL = ZFK.ZFK_FILIAL "
   _cQry += " AND DAI.DAI_COD = ZFK.ZFK_CARGA "
   _cQry += " AND DAI.D_E_L_E_T_ = ' '), "
   _cQry += " 0) = "
   _cQry += " NVL ( "
   _cQry += " (SELECT COUNT (1) "
   _cQry += " FROM " + RETSQLNAME("ZFK") + " ZFKB "
   _cQry += " WHERE ZFKB.ZFK_FILIAL = ZFK.ZFK_FILIAL "
   _cQry += " AND ZFKB.ZFK_CARGA = ZFK.ZFK_CARGA "
   _cQry += " AND ZFKB.ZFK_TIPOI = '7' "
   _cQry += " AND ZFKB.ZFK_SITUAC = 'P' "
   _cQry += " AND ZFKB.D_E_L_E_T_ = ' '), "
   _cQry += " 0) "
   _cQry += " AND NOT EXISTS "
   _cQry += " (SELECT 'X' "
   _cQry += " FROM " + RETSQLNAME("ZFK") + " ZFKT "
   _cQry += " WHERE ZFKT.ZFK_FILIAL = ZFK.ZFK_FILIAL "
   _cQry += " AND ZFKT.ZFK_PEDIDO = ZFK.ZFK_PEDIDO "
   _cQry += " AND ZFKT.ZFK_TIPOI = '8' "
   _cQry += " AND ZFKT.ZFK_SITUAC = 'P' "
   _cQry += " AND ZFKT.D_E_L_E_T_ = ' ') "
   _cQry += " ORDER BY ZFK.ZFK_CARGA, ZFK.ZFK_PEDIDO "

   _cQry := ChangeQuery(_cQry)

   If Select("ZFKVPV") > 0
      ZFKVPV->( DBCloseArea() )
   EndIf

   DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"ZFKVPV",.F.,.T.)

   DBSelectArea("ZFKVPV")
   Count to _nTotRegs

   IF !_lScheduller 
      ProcRegua(_nTotRegs)
   EndIf

   If _nTotRegs == 0
      Break 
   EndIf 

   ZFKVPV->(DBGoTop())
   
   _nRegAtu := 0

   Do While ZFKVPV->(!EOF())
      _nRegAtu++

      If !_lScheduller 
         IncProc("Gravando dados de Vincula��o Pedido Vendas com NFE: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))  
      Else 
         U_ITCONOUT("[AOMS146C] Gravando dados de Vincula��o Pedido Vendas com NFE: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))
      EndIf
      
      ZFK->(DbGoTo(ZFKVPV->NRREG))

      M->ZFK_FILIAL := ZFK->ZFK_FILIAL
      M->ZFK_CARGA  := ZFK->ZFK_CARGA 
      M->ZFK_CARTMS := ZFK->ZFK_CARTMS
      M->ZFK_PRTPED := ZFK->ZFK_PRTPED
      M->ZFK_DATA   := ZFK->ZFK_DATA  // Gravar Data Atual
      M->ZFK_HORA   := ZFK->ZFK_HORA  
      M->ZFK_TIPOI  := ZFK->ZFK_TIPOI // = "8"
      M->ZFK_CHVNFE := ZFK->ZFK_CHVNFE
      M->ZFK_PEDPAL := ZFK->ZFK_PEDPAL
      M->ZFK_NRPPAL := ZFK->ZFK_NRPPAL
      M->ZFK_CGC    := ZFK->ZFK_CGC   
      M->ZFK_PEDIDO := ZFK->ZFK_PEDIDO
      M->ZFK_COD	  := ZFK->ZFK_COD
      M->ZFK_LOJA   := ZFK->ZFK_LOJA  
      M->ZFK_NOME   := ZFK->ZFK_NOME  
      M->ZFK_USUARI := ZFK->ZFK_USUARI
      M->ZFK_SITUAC := "N" // ZFK->ZFK_SITUAC
      M->ZFK_XML    := ZFK->ZFK_XML   
      M->ZFK_PRTMS  := ZFK->ZFK_PRTMS   

      //===========================================
      ZFK->(RecLock("ZFK",.T.))   
      ZFK->ZFK_FILIAL := M->ZFK_FILIAL 
      ZFK->ZFK_CARGA  := M->ZFK_CARGA   
      ZFK->ZFK_CARTMS := M->ZFK_CARTMS  
      ZFK->ZFK_PRTPED := M->ZFK_PRTPED
      ZFK->ZFK_DATA   := Date() 
      ZFK->ZFK_HORA   := Time() 
      ZFK->ZFK_TIPOI  := "8"
      ZFK->ZFK_CHVNFE := M->ZFK_CHVNFE
      ZFK->ZFK_PEDPAL := M->ZFK_PEDPAL  
      ZFK->ZFK_NRPPAL := M->ZFK_NRPPAL 
      ZFK->ZFK_CGC    := M->ZFK_CGC        
      ZFK->ZFK_PEDIDO := M->ZFK_PEDIDO  
      ZFK->ZFK_COD    := M->ZFK_COD	   
      ZFK->ZFK_LOJA   := M->ZFK_LOJA      
      ZFK->ZFK_NOME   := M->ZFK_NOME     
      ZFK->ZFK_USUARI := __CUSERID // Codigo do Usu�rio
      ZFK->ZFK_DATAAL := Date()
      ZFK->ZFK_PRTMS  := M->ZFK_PRTMS
      ZFK->ZFK_SITUAC := "N"  
      //ZFK->ZFK_XML    := M->ZFK_XML
      ZFK->(MsUnLock()) 

      ZFKVPV->(DbSkip())
   EndDo

End Sequence

If !_lScheduller
   U_ItMsg("Termino da grava��o dos dados de Vincula��o Pedido Vendas com NFE - Protheus x TMS MultiEmbarcador. ","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146C] - Termino da grava��o dos dados de Vincula��o Pedido Vendas com NFE - Protheus x TMS MultiEmbarcador. ")      
EndIf 

If Select("ZFKVPV") > 0
   ZFKVPV->( DBCloseArea() )
EndIf

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS146D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de transmiss�o de dados de Vincula��o de Notas Fiscais com Pedidos de Vendas Troca NF.
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Rotina chamada Via Scheduller.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS146D(_lScheduller) 
Local _cQry      := ""
Local _cFilHabil := U_ITGETMV( 'IT_FILINTWS' , '' ) 
Local _cDirXML
Local _cLink
Local _cCodEmpWS
Local _lOk           := .F.
Local _cResult       := ""
Local oWsdl

Private _cToken

Begin Sequence 
   
   If !_lScheduller .AND. ! U_ItMsg("Confirma envio de dados de vincula��o de pedidos de vendas Troca NF com Notas Fiscais, para o Sistema TMS MultiEmbarcador?","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146D] Inicio do envio de dados de vincula��o de pedidos de vendas Troca NF com Notas Fiscais, para o Sistema TMS MultiEmbarcador")   
   EndIf

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   
   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK02)  // Link de envio dos dados da nota fiscal.
   Else         
      If ! _lScheduller
         U_ItMsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146D] Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146D] Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   //_cVincPVXML := U_AOMS146X(_cDirXML+"Vincular_Pedidos_Vendas_Troca_NF_com_Notas_Fiscais_TMS.txt") 
   _cVincPVXML := U_AOMS146X(_cDirXML+"Vincular_Pedidos_Vendas_Troca_NF_com_Notas_Fiscais_TMS.txt") 
   
   If Empty(_cVincPVXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo de Envio de dados de vincula��o de Pedidos de Vendas Troca NF com as Notas Fiscais - Protheus x TMS MultiEmbarcador.  ","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146D] Erro na leitura do arquivo XML modelo de Envio de dados de vincula��o de Pedidos de Vendas Troca NF com as Notas Fiscais - Protheus x TMS MultiEmbarcador.  ")
      EndIf
      Break
   EndIf
 
   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================
   _cQry := " SELECT ZFK.R_E_C_N_O_ NRREG "
   _cQry += " FROM "+RetSqlName("ZFK")+" ZFK "
   _cQry += " WHERE ZFK.D_E_L_E_T_ <> '*' "
   _cQry += "   AND ZFK_TIPOI = '8' "
   _cQry += "   AND (ZFK_SITUAC = 'N' OR  ZFK_SITUAC = 'R') "
   _cQry += "   AND ZFK_FILIAL IN "+FormatIn(ALLTRIM(_cFilHabil),";")

   _cQry := ChangeQuery(_cQry)          

   If Select("ZFKVTNF") > 0
      ZFKVTNF->( DBCloseArea() )
   EndIf

   DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "ZFKVTNF" , .T., .F. )                            
   
   DBSelectArea("ZFKVTNF")                                                                                  
   COUNT TO _nTotRegs

   IF !_lScheduller
      ProcRegua(_nTotRegs)
   EndIf

   If _nTotRegs == 0
      Break 
   EndIf 

   ZFKVTNF->(DbGoTop())
   
   _nRegAtu := 0

   _aEnvioTMS := {} // Controle de Cargas Enviadas para o TMS
   _aCargaLid := {} // Controle de cargas lidas.

   Do While !ZFKVTNF->(Eof()) 

      _nRegAtu++

      If !_lScheduller 
         IncProc("Enviando dados de vincula��o de Pedidos de Vendas Troca NF com as Notas Fiscais: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
      Else 
         U_ITCONOUT("[AOMS146D] - Enviando dados de vincula��o de Pedidos de Vendas Troca NF com as Notas Fiscais: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))
      EndIf

      ZFK->(DbGoto(ZFKVTNF->NRREG))

      _cXMLEnv := &(_cVincPVXML)

      _nIniCarre := 1   // Inicio da leitura das cargas pendentes no TMS.
      _nLimCarre := 100 // N�mero M�ximo de Registros Lidos.

      oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
      oWsdl:nTimeout := 10          // Timeout de 10 segundos 
      oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    

      oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
      oWsdl:SetOperation( "IntegrarNotasFiscais") // Define qual opera��o ser� realizada.

      // Envia para o servidor
      _lOk := oWsdl:SendSoapMsg(_cXMLEnv) // Este comando pega o XML e envia para o servidor da TMS MultiEmbarcador.  

      _cEnvioOK := "S"
      _cCodMsg  := "400" 
      _cMsg     := ""
      If _lOk 
         _cResult := oWsdl:GetSoapResponse()

         cError   := ""
         cWarning := ""

         _oXml := XmlParser(_cResult, "_", @cError, @cWarning )
         _cCodMsg  := _oxml:_s_Envelope:_s_Body:_IntegrarNotasFiscaisResponse:_IntegrarNotasFiscaisResult:_a_CodigoMensagem:text
         _cMsg     := _oxml:_s_Envelope:_s_Body:_IntegrarNotasFiscaisResponse:_IntegrarNotasFiscaisResult:_a_Mensagem:text
        
         If _cCodMsg <> "200"
            _cEnvioOK := "N"
         EndIf 
      Else
         _cResult := oWsdl:cError
         _cEnvioOK := "N"
      EndIf   
      
      ZFK->(RecLock("ZFK",.F.))
      ZFK->ZFK_DATA   := Date()  
      ZFK->ZFK_HORA   := Time()
      ZFK->ZFK_CODEMP := _cCodEmpWS
      ZFK->ZFK_RETORN := "Retorno: " + _cCodMsg + "-" + _cMsg + " - Retorno WebService: " + AllTrim(_cResult) 
      ZFK->ZFK_XML    := _cXMLEnv
      If _cEnvioOK == "N"
         ZFK->ZFK_SITUAC := "R"
      Else 
         ZFK->ZFK_SITUAC := "P"
      EndIf 

      ZFK->(MsUnLock())

      If ValType(oWSDL) == "O"
         FreeObj(oWsdl)
      EndIf 
      oWsdl := Nil
      
      ZFKVTNF->(DbSkip())
   EndDo

End Sequence

If !_lScheduller 
   U_ItMsg("Termino do envio de dados de Vincula��o de Pedidos de Vendas Troca NF com as Notas Fiscais - Protheus x TMS MultiEmbarcador.","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146D] - Termino do envio de dados de Vincula��o de Pedidos de Vendas Troca NF com as Notas Fiscais - Protheus x TMS MultiEmbarcador. ")
EndIf

If Select("ZFKVTNF") > 0
   ZFKVTNF->( DBCloseArea() )
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS146E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina Scheduller para leitura, grava��o e Transmiss�o  dos dados de notas fiscais para 
                    Pedidos de Vendas Troca Nota Fiscal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS146E()

Begin Sequence

   //=====================================================================
   // Limpa o ambiente, liberando a licen�a e fechando as conex�es
   //=====================================================================
   RpcClearEnv() 
   RpcSetType(2)
      
   //================================================================================
   // Prepara ambiente abrindo tabelas e incializando variaveis.
   //================================================================================   
   RpcSetEnv("01", "01",,,,, {"ZFK","SA2","SF2","DAK","DAI","SC5","SC6","ZP1"})

   cFilAnt := "01"

   //================================================================================
   // Grava os dados das notas fiscais para pedidos de vendas Troca nota fiscal.
   //================================================================================    
   U_AOMS146A(.T.) 
   
   //================================================================================
   // Envia para o TMS MultiEmbarcador os dados das notas fiscais para 
   // Pedidos de Vendas Troca Nota Fiscal.
   //================================================================================    
   U_AOMS146B(.T.)

End Sequence

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS146F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina Scheduller para leitura, grava��o e Transmiss�o  dos dados de vincula��o de notas fiscais  
                    com Pedidos de Vendas Troca Nota Fiscal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS146F()

Begin Sequence

   //=====================================================================
   // Limpa o ambiente, liberando a licen�a e fechando as conex�es
   //=====================================================================
   RpcClearEnv() 
   RpcSetType(2)
      
   //================================================================================
   // Prepara ambiente abrindo tabelas e incializando variaveis.
   //================================================================================   
   RpcSetEnv("01", "01",,,,, {"ZFK","SA2","SF2","DAK","DAI","SC5","SC6","ZP1"})

   cFilAnt := "01"

   //================================================================================
   // Grava os dados de vincula��o de Pedidos de Vendas Troca Nota fiscal 
   // com as notas fiscais.
   //================================================================================    
   U_AOMS146C(.T.)  
   
   //================================================================================
   // Envia para o TMS MultiEmbarcador os dados de vincula��o das notas fiscais  
   // com os Pedidos de Vendas Troca Nota Fiscal.
   //================================================================================    
   U_AOMS146D(.T.)

End Sequence

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS146G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de solicita��o de mudan�a da carga para pedidos do tipo Troca Nota Fiscal 
                    para pr�xima fase no TMS (LiberarEmissaoSemNFe).
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Determina se a rotina est� sendo rodada em modo autom�tico/Scheduller ou manual.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS146G(_lScheduller)
Local _cQry
Local _nTotRegs 
Local _aRet 
//Local _aCargas, _nI  //  JPP TESTE
Local _cFilHabil := U_ITGETMV( 'IT_FILINTWS' , '' ) 

Begin Sequence

   If !_lScheduller .AND. ! U_ItMsg("Deseja rodar a rotina de mudan�a de pedidos de vendas do tipo Troca Nota Fiscal para a pr�xima fase?","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146G] - Inicio da rotina de mudan�a de pedidos de vendas do tipo Troca Nota Fiscal para a pr�xima fase - Protheus x TMS MultiEmbarcador. ")      
   EndIf

   _cQry := " SELECT ZFK.R_E_C_N_O_ NRREG "
   _cQry += " FROM "+RetSqlName("ZFK")+" ZFK "
   _cQry += " WHERE ZFK.D_E_L_E_T_ <> '*' "
   _cQry += "   AND ZFK_TIPOI = 'A' "  // ZFK_TIPOI = '9' "
   _cQry += "   AND (ZFK_SITUAC = 'N' OR  ZFK_SITUAC = 'R') "
   _cQry += "   AND ZFK_FILIAL IN "+FormatIn(ALLTRIM(_cFilHabil),";")
   _cQry := ChangeQuery(_cQry)

   If Select("ZFKPROF") > 0
      ZFKPROF->( DBCloseArea() )
   EndIf

   DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"ZFKPROF",.F.,.T.)

   DBSelectArea("ZFKPROF")
   Count to _nTotRegs

   IF !_lScheduller 
      ProcRegua(_nTotRegs)
   EndIf

   If _nTotRegs == 0
      Break 
   EndIf 

   ZFKPROF->(DBGoTop())

   DAK->(DbSetOrder(1)) 

   _nRegAtu := 0
   _aCargas := {}

   Do While ZFKPROF->(!EOF())
      _nRegAtu++

      If !_lScheduller 
         IncProc("Integrando Solicita��o de Mudan�a de PV Troca NF para Pr�xima Fase: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))  
      Else 
         U_ITCONOUT("[AOMS146C] Integrando Solicita��o de Mudan�a de PV Troca NF para Pr�xima Fase: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))
      EndIf

      ZFK->(DbGoto(ZFKPROF->NRREG))
      
      /*  // JPP TESTE
      _nI := Ascan(_aCargas, {|x| x[1] == ZFK->ZFK_FILIAL .And. x[2] == ZFK->ZFK_CARGA})
      
      If _nI > 0
         If ! _aCargas[_nI,3] // Integra��o da Carga Rejeitada.
            ZFKPROF->(DbSkip())
            Loop
         Else 
            ZFK->(RecLock("ZFK",.F.))
            ZFK->ZFK_SITUAC := "P"
            ZFK->ZFK_RETORN := _aCargas[_nI,5]
            ZFK->(MsUnLock())   
            
            ZFKPROF->(DbSkip())
            Loop
         EndIf 
      EndIf 
      */

      If ! DAK->(MsSeek(ZFK->ZFK_FILIAL+ZFK->ZFK_CARGA)) 
         ZFKPROF->(DbSkip())
         Loop 
      EndIf
      
      //==============================================================================
      // _aRet :=  {1=True/False, // sucesso na integra��o / falha na integra��o
      //            2=Codigo da Mensagem de Retorno,
      //            3=C�digo e Mensagem de Retorno, 
      //            4=Xml de Retorno, 
      //            5=Xml de Envio}
      //==============================================================================
      _aRet := U_AOMS140D() // Chama a rotina de integra��o Webservice de mudan��o da carga para pr�xima fase. 

                                                  //  T/F    , Cod.MSG, MSG 
      //Aadd(_aCargas, {ZFK->ZFK_FILIAL,ZFK->ZFK_CARGA,_aRet[1],_aRet[2],_aRet[3]}) // JPP TESTE
      
      If _aRet[1] 
         ZFK->(RecLock("ZFK",.F.))
         ZFK->ZFK_SITUAC := "P"
         ZFK->ZFK_RETORN := _aRet[3] // Mensagem de REtorno
         ZFK->ZFK_XML    := _aRet[5] // XML de envio
         ZFK->(MsUnLock())   
      Else 
         ZFK->(RecLock("ZFK",.F.))
         ZFK->ZFK_RETORN := _aRet[3] // Mensagem de REtorno
         ZFK->ZFK_XML    := _aRet[5] // XML de envio
         ZFK->(MsUnLock())   
      EndIf 
      
      ZFKPROF->(DbSkip())
   EndDo

End Sequence

If !_lScheduller
   U_ItMsg("Termino da Integra��o de Solicita��o de Mudan�a de Pedidos de Vendas Troca Nota Fiscal para pr�xima fase. ","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146G] - Termino da Integra��o de Solicita��o de Mudan�a de Pedidos de Vendas Troca Nota Fiscal para pr�xima fase. ")      
EndIf  

If Select("ZFKPROF") > 0
   ZFKPROF->( DBCloseArea() )
EndIf

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS146H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina Scheduller para Solicita��o de mudan�a da carga para a pr�xima fase (encerramento). 
                    Para pedidos de vendas do tipo troca nota fiscal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS146H()

Begin Sequence

   //=====================================================================
   // Limpa o ambiente, liberando a licen�a e fechando as conex�es
   //=====================================================================
   RpcClearEnv() 
   RpcSetType(2)
      
   //================================================================================
   // Prepara ambiente abrindo tabelas e incializando variaveis.
   //================================================================================   
   RpcSetEnv("01", "01",,,,, {"ZFK","SA2","SF2","DAK","DAI","SC5","SC6","ZP1"})

   cFilAnt := "01"
 
   //================================================================================
   // Grava��o dos dados para solicita��o de mudan�a da carga para a pr�xima fase.
   // Para pedidos de vendas do tipo Troca Nota Fiscal.
   //================================================================================
   U_AOMS146L(.T.) 

   //================================================================================
   // Envia para o TMS MultiEmbarcador uma solicita��o de mudan��o da carga para 
   // a pr�xima fase(Encerramento), para pedidos de vendas do tipo troca nota fiscal. 
   //================================================================================    
   U_AOMS146G(.T.)

End Sequence

Return Nil 

/*
===============================================================================================================================
Fun��o------------: AOMS146I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de Grava��o dos Dados de integra��o do Vale Ped�gio, para pedidos de vendas  
                    do tipo troca nota fiscal para o TMS MultiEmbarcador.
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Rotina chamada Via Scheduller.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS146I(_lScheduller )
Local _cQry
Local _nTotRegs 

Begin Sequence

   If !_lScheduller .AND. ! U_ItMsg("Confirma a Grava��o dos Dados de integra��o do Vale Ped�gio, para Pedidos de Vendas do Tipo Troca Nota Fiscal, para o TMS MultiEmbarcador?","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146I] - Iniciando a Grava��o dos Dados para a integra��o do Vale Ped�gio, para Pedidos de Vendas do Tipo Troca Nota Fiscal, Para o TMS MultiEmbarcador. ")      
   EndIf

   _cQry := "SELECT DISTINCT ZFK_FILIAL, "
   _cQry += "  ZFK_TIPOI, "
   _cQry += "  ZFK_CARGA, "
   _cQry += "  ZFK_CARTMS "
   //_cQry += "  ZFK.R_E_C_N_O_ NRREG  // Utilizar �ndice orderm 3
   _cQry += "  FROM " + RETSQLNAME("ZFK") + " ZFK "
   _cQry += "  WHERE  ZFK_TIPOI = '8' "
   _cQry += "  AND ZFK_SITUAC = 'P' "
   _cQry += "  AND ZFK.D_E_L_E_T_ = ' ' "
//=============================================================
   //_cQry += "  AND ZFK.ZFK_CARGA  = '244870' "    // '244855' " // JPP TESTE
   //_cQry += "  AND ZFK.ZFK_FILIAL = '01' "        // JPP TESTE
//=============================================================
   _cQry += "  AND NOT EXISTS "
   _cQry += "  (SELECT 'X' "
   _cQry += "  FROM " + RETSQLNAME("ZFK") + " ZFKB "
   _cQry += "  WHERE ZFKB.ZFK_FILIAL = ZFK.ZFK_FILIAL "
   _cQry += "  AND ZFKB.ZFK_TIPOI = ZFK.ZFK_TIPOI "
   _cQry += "  AND ZFKB.ZFK_CARGA = ZFK.ZFK_CARGA "
   _cQry += "  AND ZFKB.ZFK_CARTMS = ZFK.ZFK_CARTMS "
   _cQry += "  AND ZFKB.ZFK_SITUAC <> 'P' "
   _cQry += "  AND ZFKB.D_E_L_E_T_ = ' ') "
   _cQry += "  AND NOT EXISTS "
   _cQry += "  (SELECT 'X' "
   _cQry += "  FROM " + RETSQLNAME("ZFK") + " ZFKC "
   _cQry += "  WHERE ZFKC.ZFK_FILIAL = ZFK.ZFK_FILIAL "
   _cQry += "  AND ZFKC.ZFK_CARGA = ZFK.ZFK_CARGA "
   _cQry += "  AND ZFKC.ZFK_CARTMS = ZFK.ZFK_CARTMS "
   _cQry += "  AND ZFKC.ZFK_TIPOI = '9' "
   _cQry += "  AND ZFKC.D_E_L_E_T_ = ' ') "
 
   _cQry := ChangeQuery(_cQry)

   If Select("ZFKVAL") > 0
      ZFKVAL->( DBCloseArea() )
   EndIf

   DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"ZFKVAL",.F.,.T.)

   DBSelectArea("ZFKVAL")
   Count to _nTotRegs

   IF !_lScheduller 
      ProcRegua(_nTotRegs)
   EndIf

   If _nTotRegs == 0
      Break 
   EndIf 

   DAK->(DbSetOrder(1))
   ZFK->(DbSetOrder(3))

   ZFKVAL->(DBGoTop())
   
   _nRegAtu := 0

   Do While ZFKVAL->(!EOF())
      _nRegAtu++

      If !_lScheduller 
         IncProc("Gravando dados de Gera��o do Vale Ped�gio para Pedidos de Vendas do Tipo Troca Nota Fiscal: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))  
      Else 
         U_ITCONOUT("[AOMS146I] Gravando dados de Gera��o do Vale Ped�gio para Pedidos de Vendas do Tipo Troca Nota Fiscal: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))
      EndIf
     
      //ZFK->(DbGoTo(ZFKVAL->NRREG))
      If ZFK->(MsSeek(ZFKVAL->ZFK_FILIAL+ZFKVAL->ZFK_CARGA+ZFKVAL->ZFK_TIPOI+"P"))  // ZFK_FILIAL+ZFK_CARGA+ZFK_TIPOI+ZFK_SITUAC
         M->ZFK_FILIAL := ZFK->ZFK_FILIAL
         M->ZFK_CARGA  := ZFK->ZFK_CARGA 
         M->ZFK_CARTMS := ZFK->ZFK_CARTMS
         M->ZFK_PRTPED := ZFK->ZFK_PRTPED
         M->ZFK_DATA   := ZFK->ZFK_DATA  // Gravar Data Atual
         M->ZFK_HORA   := ZFK->ZFK_HORA  
         M->ZFK_TIPOI  := ZFK->ZFK_TIPOI // = "8"
         M->ZFK_CHVNFE := ZFK->ZFK_CHVNFE
         M->ZFK_PEDPAL := ZFK->ZFK_PEDPAL
         M->ZFK_NRPPAL := ZFK->ZFK_NRPPAL
         M->ZFK_CGC    := ZFK->ZFK_CGC   
         M->ZFK_PEDIDO := ZFK->ZFK_PEDIDO
         M->ZFK_COD	  := ZFK->ZFK_COD
         M->ZFK_LOJA   := ZFK->ZFK_LOJA  
         M->ZFK_NOME   := ZFK->ZFK_NOME  
         M->ZFK_USUARI := ZFK->ZFK_USUARI
         M->ZFK_SITUAC := "N" // ZFK->ZFK_SITUAC
         M->ZFK_XML    := ZFK->ZFK_XML   
         M->ZFK_PRTMS  := ZFK->ZFK_PRTMS   

         DAK->(MsSeek(ZFK->ZFK_FILIAL+ZFK->ZFK_CARGA))

         //===========================================
         ZFK->(RecLock("ZFK",.T.))   
         ZFK->ZFK_FILIAL := M->ZFK_FILIAL 
         ZFK->ZFK_CARGA  := M->ZFK_CARGA   
         ZFK->ZFK_CARTMS := M->ZFK_CARTMS  
         ZFK->ZFK_PRTPED := M->ZFK_PRTPED
         ZFK->ZFK_DATA   := Date() 
         ZFK->ZFK_HORA   := Time() 
         ZFK->ZFK_TIPOI  := "9"
         ZFK->ZFK_CHVNFE := M->ZFK_CHVNFE
         ZFK->ZFK_PEDPAL := M->ZFK_PEDPAL  
         ZFK->ZFK_NRPPAL := M->ZFK_NRPPAL 
         //ZFK->ZFK_CGC    := M->ZFK_CGC        
         ZFK->ZFK_PEDIDO := M->ZFK_PEDIDO  
         ZFK->ZFK_COD    := M->ZFK_COD	   
         ZFK->ZFK_LOJA   := M->ZFK_LOJA      
         ZFK->ZFK_NOME   := M->ZFK_NOME     
         ZFK->ZFK_USUARI := __CUSERID // Codigo do Usu�rio
         ZFK->ZFK_DATAAL := Date()
         ZFK->ZFK_PRTMS  := M->ZFK_PRTMS
      
         If AllTrim(Upper(DAK->DAK_I_INVP)) ==  "PAMCARD" // 'Pamcard' = , se for 'Repom' = 65697260000103, sen�o branco
            ZFK->ZFK_CGC := "12815827000132" 
         ElseIf AllTrim(Upper(DAK->DAK_I_INVP)) ==  "REPOM" // DAK->DAK_I_INVP // Integradora do Vale Ped�gio 
            ZFK->ZFK_CGC := "65697260000103"
         EndIf 

         ZFK->ZFK_NRVALP := DAK->DAK_I_VPED // Numero do Vale Ped�gio
         ZFK->ZFK_VLVALP := DAK->DAK_I_VRVP // = Valor Rateado do Ped�gio // DAK_I_VALP = Valor do Vale Ped�gio 
         ZFK->ZFK_SITUAC := "N"  
         ZFK->(MsUnLock()) 
      EndIf 

      ZFKVAL->(DbSkip())
   EndDo

End Sequence

If !_lScheduller
   U_ItMsg("Termino da grava��o dos dados de Gera��o do Vale Ped�gio para Pedidos de Vendas do Tipo Troca Nota Fiscal.","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146I] - Termino da grava��o dos dados de Gera��o do Vale Ped�gio para Pedidos de Vendas do Tipo Troca Nota Fiscal.")      
EndIf 

If Select("ZFKVAL") > 0
   ZFKVAL->( DBCloseArea() )
EndIf

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS146J
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o/transmiss�o de dados de vale ped�gio, para pedidos de vendas do tipo troca nota fiscal
                    para o TMS Multiembarcador.
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Rotina chamada Via Scheduller.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS146J(_lScheduller) 
Local _cQry      := ""
Local _cFilHabil := U_ITGETMV( 'IT_FILINTWS' , '' ) 
Local _cDirXML
Local _cLink
Local _cCodEmpWS
Local _lOk           := .F.
Local _cResult       := ""
Local oWsdl

Private _cToken

Begin Sequence 
   
   If !_lScheduller .AND. ! U_ItMsg("Confirma envio de dados de integra��o vale ped�gio, para pedidos de vendas do tipo troca nota fiscal, para o Sistema TMS MultiEmbarcador ?","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146J] Inicio do envio de dados de integra��o vale ped�gio, para de vendas do tipo Troca Notas Fiscais, para o Sistema TMS MultiEmbarcador.")   
   EndIf

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   
   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK06)  // Link de integra��o vele ped�gio.
   Else         
      If ! _lScheduller
         U_ItMsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146J] Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146J] Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   _cValePXML := U_AOMS146X(_cDirXML+"Integrar_Vale_Pedagio_TMS.txt") 

   //_cValePXML := U_AOMS146X("C:\Julio\Chamados\46163\Integrar_Vale_Ped�gio_TMS.txt") 
   
   If Empty(_cValePXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo de Integra��o Vale Ped�gio, com o TMS MultiEmbarcador.  ","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS146J] Erro na leitura do arquivo XML modelo de Integra��o Vale Ped�gio, com o TMS MultiEmbarcador.  ")
      EndIf
      Break
   EndIf
 
   //===================================================================================================
   // Montagem de query com os numeros de registros de integra��o Vale Ped�gio com o TMS Multiembardador
   //===================================================================================================
   _cQry := " SELECT ZFK.R_E_C_N_O_ NRREG "
   _cQry += " FROM "+RetSqlName("ZFK")+" ZFK "
   _cQry += " WHERE ZFK.D_E_L_E_T_ <> '*' "
   _cQry += "   AND ZFK_TIPOI = '9' "
   _cQry += "   AND (ZFK_SITUAC = 'N' OR  ZFK_SITUAC = 'R') "
   _cQry += "   AND ZFK_FILIAL IN "+FormatIn(ALLTRIM(_cFilHabil),";")

   _cQry := ChangeQuery(_cQry)          

   If Select("ZFKINTVL") > 0
      ZFKINTVL->( DBCloseArea() )
   EndIf

   DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "ZFKINTVL" , .T., .F. )                            
   
   DBSelectArea("ZFKINTVL")                                                                                  
   COUNT TO _nTotRegs

   IF !_lScheduller
      ProcRegua(_nTotRegs)
   EndIf

   If _nTotRegs == 0
      Break 
   EndIf 

   ZFKINTVL->(DbGoTop())
   
   _nRegAtu := 0

   _aEnvioTMS := {} // Controle de Cargas Enviadas para o TMS
   _aCargaLid := {} // Controle de cargas lidas.

   Do While !ZFKINTVL->(Eof()) 

      _nRegAtu++

      If !_lScheduller 
         IncProc("Enviando dados de integra��o vale ped�gio para Pedidos de Vendas Troca Fiscais: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))  
      Else 
         U_ITCONOUT("[AOMS146J] - Enviando dados de integra��o vale ped�gio para Pedidos de Vendas Troca Fiscais: " + Alltrim(Str(_nRegAtu)) + " de " + Alltrim(Str(_nTotRegs)))
      EndIf

      ZFK->(DbGoto(ZFKINTVL->NRREG))

      _cXMLEnv := &(_cValePXML)

      _nIniCarre := 1   // Inicio da leitura das cargas pendentes no TMS.
      _nLimCarre := 100 // N�mero M�ximo de Registros Lidos.

      oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
      oWsdl:nTimeout := 10          // Timeout de 10 segundos 
      oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    

      oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
      oWsdl:SetOperation("IntegrarValePedagio") // Define qual opera��o ser� realizada. // "IntegrarValePedagio"
                          
      // Envia para o servidor
      _lOk := oWsdl:SendSoapMsg(_cXMLEnv) // Este comando pega o XML e envia para o servidor da TMS MultiEmbarcador.  

      _cEnvioOK := "S"
      _cCodMsg  := "400" 
      _cMsg     := ""
      If _lOk 
         _cResult := oWsdl:GetSoapResponse()

         cError   := ""
         cWarning := ""

         _oXml := XmlParser(_cResult, "_", @cError, @cWarning )
         _cCodMsg  := _oxml:_s_Envelope:_s_Body:_IntegrarValePedagioResponse:_IntegrarValePedagioResult:_a_CodigoMensagem:text
         _cMsg     := _oxml:_s_Envelope:_s_Body:_IntegrarValePedagioResponse:_IntegrarValePedagioResult:_a_Mensagem:text
        
         If _cCodMsg <> "200"
            _cEnvioOK := "N"
         EndIf 
      Else
         _cResult := oWsdl:cError
         _cEnvioOK := "N"
      EndIf   
      
      ZFK->(RecLock("ZFK",.F.))
      ZFK->ZFK_DATA   := Date()  
      ZFK->ZFK_HORA   := Time()
      ZFK->ZFK_CODEMP := _cCodEmpWS
      ZFK->ZFK_RETORN := "Retorno: " + _cCodMsg + "-" + _cMsg + " - Retorno WebService: " + AllTrim(_cResult) 
      ZFK->ZFK_XML    := _cXMLEnv
      If _cEnvioOK == "N"
         ZFK->ZFK_SITUAC := "R"
      Else 
         ZFK->ZFK_SITUAC := "P"
      EndIf 

      ZFK->(MsUnLock())

      If ValType(oWSDL) == "O"
         FreeObj(oWsdl)
      EndIf 
      oWsdl := Nil
      
      ZFKINTVL->(DbSkip())
   EndDo

End Sequence

If !_lScheduller 
   U_ItMsg("Termino do envio da integra��o vale ped�gio para pedidos de vendas tipo troca nota fiscal, para o TMS Multi Embarcador.","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146J] - Termino do envio da integra��o vale ped�gio para pedidos de vendas tipo troca nota fiscal, para o TMS Multi Embarcador.")
EndIf

If Select("ZFKINTVL") > 0
   ZFKINTVL->( DBCloseArea() )
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS146K
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/08/2024
===============================================================================================================================
Descri��o---------: Rotina Scheduller para grava��o dos dados de gera��o de Vale Ped�gio e realizar a integra��o Webservice
                    com TMS MultiEmbarcador para a gera��o do Vale Ped�gio. 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS146K()

Begin Sequence

   //=====================================================================
   // Limpa o ambiente, liberando a licen�a e fechando as conex�es
   //=====================================================================
   RpcClearEnv() 
   RpcSetType(2)
      
   //================================================================================
   // Prepara ambiente abrindo tabelas e incializando variaveis.
   //================================================================================   
   RpcSetEnv("01", "01",,,,, {"ZFK","SA2","SF2","DAK","DAI","SC5","SC6","ZP1"})

   cFilAnt := "01"
 
   //================================================================================
   // Inicia a rotina de grava��o de dados para integra��o do vale ped�gio com o
   // TMS-Multiembarcador.
   //================================================================================    
   U_AOMS146I(.T.) 

   //================================================================================
   // Inicia a rotina de integra��o / Transmiss�o dos dados do vale ped�gio com o
   // TMS-Multiembarcador.
   //================================================================================    
   U_AOMS146J(.T.)

End Sequence

Return Nil 

/*
===============================================================================================================================
Fun��o------------: AOMS146L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/08/2024
===============================================================================================================================
Descri��o---------: Rotina de Grava��o dos Dados de mudan�a de carga para pr�xima fase, para pedidos de vendas  
                    do tipo troca nota fiscal para o TMS MultiEmbarcador.
===============================================================================================================================
Parametros--------: _lScheduller = .T./.F. = Rotina chamada Via Scheduller.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS146L(_lScheduller )
Local _cQry
Local _nTotRegs 

Begin Sequence

   If !_lScheduller .AND. ! U_ItMsg("Confirma a Grava��o dos Dados de solicita��o de mudan�a de carga para pr�xma fase, para Pedidos de Vendas do Tipo Troca Nota Fiscal, para o TMS MultiEmbarcador?","Aten��o",,4,2,2) 
      Break
   Else 
      U_ITCONOUT("[AOMS146L] - Iniciando a Grava��o dos Dados de solicita��o de mudan�a de carga para pr�xima fase, para Pedidos de Vendas do Tipo Troca Nota Fiscal, Para o TMS MultiEmbarcador. ")      
   EndIf

   _cQry := "SELECT ZFK_FILIAL, "
   _cQry += "  ZFK_TIPOI, "
   _cQry += "  ZFK_CARGA, "
   _cQry += "  ZFK_CARTMS, "
   _cQry += "  ZFK.R_E_C_N_O_ NRREG "
   _cQry += "  FROM " + RETSQLNAME("ZFK") + " ZFK "
   _cQry += "  WHERE  ZFK_TIPOI = '9' " // ZFK_TIPOI = '8' "
   _cQry += "  AND ZFK_SITUAC = 'P' "
   _cQry += "  AND ZFK.D_E_L_E_T_ = ' ' "
   _cQry += "  AND NOT EXISTS "
   _cQry += "  (SELECT 'X' "
   _cQry += "  FROM " + RETSQLNAME("ZFK") + " ZFKB "
   _cQry += "  WHERE ZFKB.ZFK_FILIAL = ZFK.ZFK_FILIAL "
   _cQry += "  AND ZFKB.ZFK_TIPOI = ZFK.ZFK_TIPOI "
   _cQry += "  AND ZFKB.ZFK_CARGA = ZFK.ZFK_CARGA "
   _cQry += "  AND ZFKB.ZFK_CARTMS = ZFK.ZFK_CARTMS "
   _cQry += "  AND ZFKB.ZFK_SITUAC <> 'P' "
   _cQry += "  AND ZFKB.D_E_L_E_T_ = ' ') "
   _cQry += "  AND NOT EXISTS "
   _cQry += "  (SELECT 'X' "
   _cQry += "  FROM " + RETSQLNAME("ZFK") + " ZFKC "
   _cQry += "  WHERE ZFKC.ZFK_FILIAL = ZFK.ZFK_FILIAL "
   _cQry += "  AND ZFKC.ZFK_CARGA = ZFK.ZFK_CARGA "
   _cQry += "  AND ZFKC.ZFK_CARTMS = ZFK.ZFK_CARTMS "
   _cQry += "  AND ZFKC.ZFK_TIPOI = 'A' "
   _cQry += "  AND ZFKC.D_E_L_E_T_ = ' ') "
 
   _cQry := ChangeQuery(_cQry)

   If Select("ZFKVAL") > 0
      ZFKVAL->( DBCloseArea() )
   EndIf

   DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"ZFKVAL",.F.,.T.)

   DBSelectArea("ZFKVAL")
   Count to _nTotRegs

   IF !_lScheduller 
      ProcRegua(_nTotRegs)
   EndIf

   If _nTotRegs == 0
      Break 
   EndIf 

   ZFKVAL->(DBGoTop())
   
   _nRegAtu := 0

   Do While ZFKVAL->(!EOF())
      _nRegAtu++

      If !_lScheduller 
         IncProc("Gravando dados de solicita��o de mudan�a de carga para a pr�xima fase para Pedidos de Vendas do Tipo Troca Nota Fiscal: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))  
      Else 
         U_ITCONOUT("[AOMS146L] Gravando dados de solicita��o de mudan�a de carga para a pr�xima fase para Pedidos de Vendas do Tipo Troca Nota Fiscal: " + Alltrim(Str(_nRegAtu,10)) + " de " + Alltrim(Str(_nTotRegs,10)))
      EndIf
      
      ZFK->(DbGoTo(ZFKVAL->NRREG))

      M->ZFK_FILIAL := ZFK->ZFK_FILIAL
      M->ZFK_CARGA  := ZFK->ZFK_CARGA 
      M->ZFK_CARTMS := ZFK->ZFK_CARTMS
      M->ZFK_PRTPED := ZFK->ZFK_PRTPED
      M->ZFK_DATA   := ZFK->ZFK_DATA  // Gravar Data Atual
      M->ZFK_HORA   := ZFK->ZFK_HORA  
      M->ZFK_TIPOI  := ZFK->ZFK_TIPOI // = "8"
      M->ZFK_CHVNFE := ZFK->ZFK_CHVNFE
      M->ZFK_PEDPAL := ZFK->ZFK_PEDPAL
      M->ZFK_NRPPAL := ZFK->ZFK_NRPPAL
      M->ZFK_CGC    := ZFK->ZFK_CGC   
      M->ZFK_PEDIDO := ZFK->ZFK_PEDIDO
      M->ZFK_COD	  := ZFK->ZFK_COD
      M->ZFK_LOJA   := ZFK->ZFK_LOJA  
      M->ZFK_NOME   := ZFK->ZFK_NOME  
      M->ZFK_USUARI := ZFK->ZFK_USUARI
      M->ZFK_SITUAC := "N" // ZFK->ZFK_SITUAC
      M->ZFK_XML    := ZFK->ZFK_XML   
      M->ZFK_PRTMS  := ZFK->ZFK_PRTMS   
      M->ZFK_INTVPD := ZFK->ZFK_INTVPD
      M->ZFK_NRVALP := ZFK->ZFK_NRVALP 
      M->ZFK_VLVALP := ZFK->ZFK_VLVALP

      //===========================================
      ZFK->(RecLock("ZFK",.T.))   
      ZFK->ZFK_FILIAL := M->ZFK_FILIAL 
      ZFK->ZFK_CARGA  := M->ZFK_CARGA   
      ZFK->ZFK_CARTMS := M->ZFK_CARTMS  
      ZFK->ZFK_PRTPED := M->ZFK_PRTPED
      ZFK->ZFK_DATA   := Date() 
      ZFK->ZFK_HORA   := Time() 
      ZFK->ZFK_TIPOI  := "A"
      ZFK->ZFK_CHVNFE := M->ZFK_CHVNFE
      ZFK->ZFK_PEDPAL := M->ZFK_PEDPAL  
      ZFK->ZFK_NRPPAL := M->ZFK_NRPPAL 
      ZFK->ZFK_CGC    := M->ZFK_CGC        
      ZFK->ZFK_PEDIDO := M->ZFK_PEDIDO  
      ZFK->ZFK_COD    := M->ZFK_COD	   
      ZFK->ZFK_LOJA   := M->ZFK_LOJA      
      ZFK->ZFK_NOME   := M->ZFK_NOME     
      ZFK->ZFK_USUARI := __CUSERID // Codigo do Usu�rio
      ZFK->ZFK_DATAAL := Date()
      ZFK->ZFK_PRTMS  := M->ZFK_PRTMS
      ZFK->ZFK_SITUAC := "N"  
      ZFK->(MsUnLock()) 

      ZFKVAL->(DbSkip())
   EndDo

End Sequence

If !_lScheduller
   U_ItMsg("Termino da grava��o dos dados de solicita��o de mudan�a da carga para a proxima fase, para Pedidos de Vendas do Tipo Troca Nota Fiscal.","Aten��o",,2)
Else 
   U_ITCONOUT("[AOMS146L] - Termino da grava��o dos dados de solicita��o de mudan�a da carga para a pr�xima fase, para Pedidos de Vendas do Tipo Troca Nota Fiscal.")      
EndIf 

If Select("ZFKVAL") > 0
   ZFKVAL->( DBCloseArea() )
EndIf

Return Nil



