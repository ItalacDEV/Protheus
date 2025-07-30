/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o      | 22/01/2024 | Chamado: 46064 - Integra��o de Notas Canceladas com o TMS
Igor Melga�o      | 30/07/2024 | Chamado: 47204 - Ajustes para transf. de pedido.
Julio Paz         | 31/07/2024 | Chamado: 46122 - Alt.Rot.int.Vale Pedagio p/Salvar Val.Vale Pedagio e XML Retorno na Tab.DAK 
=========================================================================================================================================================================================================================
Analista         - Programador       - Inicio     - Envio    - Chamado - Motivo da Altera��o
=========================================================================================================================================================================================================================
Vanderlei Alves  -  Igor Melga�o     - 26/12/2024 - 10/06/25 - 49427   - Inclus�o do metodo de altera��o de carga.
Vanderlei Alves  -  Igor Melga�o     - 17/01/2025 - 10/06/25 - 49551   - Ajustes para Inclus�o do DAK_I_TMS. 
Vanderlei Alves  -  Julio Paz        - 31/03/2025 - 10/06/25 - 50188   - Ajustes na fun��o AOMS144M. Validar se a filial est� habilitada a rodar a fun��o e inclus�o de tratamentos para rotina em Scheduller.
Vanderlei Alves  -  Alex Wallauer    - 09/06/2025 - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP")
Vanderlei Alves  -  Julio Paz        - 12/06/2025 - 13/06/25 - 45229   - Ajustes no novo webservice de integra��o Altera��o na Situa��o Comercial do Pedido de Vendas.
Vanderlei Alves  -  Igor Melgaco     - 26/06/2025 - 26/06/25 - 45229   - Correcao de url.
=========================================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#Include "FWMVCDef.Ch"

STATIC _lScheduler :=.F.

/*
===============================================================================================================================
Fun��o------------: AOMS140E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2023
===============================================================================================================================
Descri��o---------: Gera os dados XML de cancelamento com base no Pedido de Venda selecionado e integra via webservice.
===============================================================================================================================
Parametros--------: oproc - objeto de barra de progresso
                    _lExibeTela - .T. = Exibe as mensagens na tela. / .F. = Exibe as mensagens no console.
===============================================================================================================================
Retorno-----------: True = integra��o bem sucedida / False = falha na integra��o.
===============================================================================================================================
*/
User Function AOMS140E(oproc,_lExibeTela)             
Local _cDirXML := ""
Local _cLink   := ""
Local _cCanPXML := ""
Local _cCodEmpWS 
Local _aOrd := SaveOrd({"ZZM","SA2","ZFM"})
Local _cXML 
Local _cResult := ""
Local _cResposta, _cSituacao
Local _lRet := .F.
Local _cCodMsg := ""
Local _cMsg := ""

//Default oproc := NIL
//Default _lExibeTela := .T.

//Se estiver no webservice n�o executa
If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B")
	Return nil
Endif

Begin Sequence
   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   
   If ValType(_lExibeTela) == "U"
      _lExibeTela := .T.
   EndIf 

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Identificando diret�rio dos XML...")
  		ProcessMessages()
   EndIf

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK01)
   Else         
      If _lExibeTela
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140] Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Lendo arquivo XML Modelo de Cabe�alho...")
  		ProcessMessages()
   EndIf 
    
   _cCanPXML := U_AOMS140X(_cDirXML+"Solicitacao_Cancelamento_Pedidos_TMS.txt") 
   
   If Empty(_cCanPXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo de Solicita��o de Cancelamento de Pedido de Vendas. ","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Erro na leitura do arquivo XML modelo de Solicita��o de Cancelamento de Pedido de Vendas. ")
      EndIf
      Break
   EndIf
   
   ZZM->(DbSetOrder(1))
   SA2->(DbSetOrder(3)) 
   ZZM->(DbSeek(xFilial("ZZM")+SC5->C5_FILIAL))
   SA2->(DbSeek(xFilial("SA2")+ZZM->ZZM_CGC))   
   
   //================================================================================
   // Concatena os Pedidos de Vendas selecionados e monta array de XML com os dados.
   //================================================================================                       
   IF ValType(oproc) = "O"
     	oproc:cCaption := ("Montando dados de envio...")
  		ProcessMessages()
   ENDIF
   
   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
   oWsdl:nTimeout := 10          // Timeout de 10 segundos 
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    
   
   //oWsdl:ParseURL( "http://10.3.0.201/wsitf18/Service.svc?wsdl") // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
   oWsdl:SetOperation( "SolicitarCancelamentoDoPedido") // Define qual opera��o ser� realizada.
   
   _aresult := {}
   
   Begin Transaction     
      //===============================================================================
      // Realiza a integra��o dos pedidos de vendas (Envio de XML) via WebService.
      //===============================================================================
         
 	   // Monta XML
 	   _cXML := &(_cCanPXML)  // Monta o XML de envio.

	   // Envia para o servidor
      _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            
      If _cOk 
         _cResult := oWsdl:GetParsedResponse() // Pega o resultado de envio j� no formato em string.
      Else
         _cResult := oWsdl:cError
      EndIf   
            
      //_cResposta := AllTrim(StrTran(_cResult,Chr(10)," "))
      
      //_cResposta := Upper(_cResposta)
//--------------------------------------------------------------
      _cTextoPesq := Upper(_cResult)
      _cCodMsg := ""
      _cTextoMsg := ""

      If "CODIGOMENSAGEM" $ _cTextoPesq
         _nI := At("CODIGOMENSAGEM",_cTextoPesq)
         _cCodMsg := AllTrim(SubStr(_cResult,_nI, 20))

         _nI := At(":",_cCodMsg)
         _cCodMsg := AllTrim(SubStr(_cCodMsg,_nI+1, 3))
      EndIf
//--------------------------------------------------------------
      If "MENSAGEM" $ _cTextoPesq
         _nI := At("MENSAGEM",_cTextoPesq)       // Retorna a primeira ocorr�ncia da palavra MENSAGEM (CODIGOMENSAGEM:).
         _nI := At("MENSAGEM",_cTextoPesq,_nI+5) // Retorna a segunda ocorr�ncia da palavra MENSAGEM (MENSAGEM:).

         _nJ := At("OBJETO",_cTextoPesq)
         _nNrPos := _nJ - (_nI + 1)
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
//--------------------------------------------------------------

      _cResposta := ""
      _cSituacao := "P" // "Importado Com Sucesso"
      _cCodRast  := ""

      If _cCodMsg == "200" // Integrado com Sucesso 
                           
         _nI := At("PROTOCOLOINTEGRACAOPEDIDO",_cTextoPesq)
         _nJ := At("STATUS",_cTextoPesq)
         _nNrPos := 1

         _cCodRast := "" 
         If _nI > 0 .And. _nJ >0 
            _nNrPos := _nJ - _nI 

            _cRastreador := AllTrim(SubStr(_cResult,_nI, _nNrPos))
                     
            _cTextoPesq := Upper(_cRastreador)
            _nJ := Len(AllTrim(_cTextoPesq))

            _nI := At(":",_cTextoPesq)
            _nNrPos := _nJ - (_nI + 1) 
            _cCodRast := AllTrim(SubStr(_cRastreador,_nI+1,_nNrPos))
         EndIf

         _cResposta := "Integrado com Sucesso - Nenhum problema encontrado, a requisi��o foi processada e retornou dados. "
         _lRet := .T.
         
      ElseIf _cCodMsg == "300" // Dados Inv�lidos
         _lRet := .F.
         _cSituacao := "N"
         _cResposta := "Dados Inv�lidos - Algum dado da requisi��o n�o � v�lido, ou est� faltando. "

      ElseIf _cCodMsg == "400" // Falha Interna Web Service
         _lRet := .F.
         _cSituacao := "N"
         _cResposta := "Falha Interna Web Service - Erro interno no processamento. Caso seja persistente, contatar o suporte da MultiSoftware. "

      ElseIf _cCodMsg == "500" // Duplicidade na Requisi��o
         _lRet := .T.
         _cSituacao := "P"
         _cResposta := "Duplicidade na Requisi��o - A requisi��o j� foi feita, ou o registro j� foi inserido anteriormente. "
      Else
         _lRet := .F.
         _cSituacao := "N"
         _cResposta := AllTrim(StrTran(_cResult,Chr(10)," "))
         _cResposta := Upper(_cResposta)
      EndIf 
      
      If ! Empty(_cTextoMsg)
         _cResposta := _cResposta + _cTextoMsg
      EndIf 

//--------------------------------------------------------------
/*            
      // "Importado Com Sucesso"
      _cSituacao := "R"
      _lRet := .F.

      If ("IMPORTADO COM SUCESSO" $ _cResposta) 
         _cSituacao := "P"
         _lRet := .T.
      ElseIf ("PEDIDO NAO ENCONTRADO" $ _cResposta) .Or. ("PEDIDO NãO ENCONTRADO" $ _cResposta)  
         _cSituacao := "P"
         _lRet := .T.
      EndIf
       	
      //Ajusta resposta de pedido em carga para incluir o n�mero da viagem
      If " VINCULADO NA CARGA" $ _cResposta
      
      	DAI->(Dbsetorder(4))
      	If DAI->(dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
      
      		DAK->(Dbsetorder(1))
      		If DAK->(dbseek(DAI->DAI_FILIAL+DAI->DAI_COD))
      		
      			_cresposta := SUBSTR(ALLTRIM(_cresposta),1,LEN(ALLTRIM(_cresposta))-1) + " VIAGEM: "+ ALLTRIM(DAK->DAK_I_CARG) + " )"
      			
      		Endif
      	Endif
      
      Endif
*/

 	   //================================================================================
      // Grava na tabela de muro um log da integra��o.
      //================================================================================                       
      ZFL->(RecLock("ZFL",.T.))
      ZFL->ZFL_FILIAL  := SC5->C5_FILIAL
      ZFL->ZFL_HORA    := Time() // Grava a hora de inclus�o do registro na tabela de muro.
      ZFL->ZFL_DATA    := Date()
      ZFL->ZFL_CGC     := ZZM->ZZM_CGC
      ZFL->ZFL_NUM     := SC5->C5_NUM
      ZFL->ZFL_COD     := SA2->A2_COD
      ZFL->ZFL_LOJA    := SA2->A2_LOJA
      ZFL->ZFL_NOME    := SA2->A2_NOME
      ZFL->ZFL_EMISSA  := Date()
      ZFL->ZFL_SITUAC  := _cSituacao // iif(_cok, "P", "N")
      ZFL->ZFL_USUARI  := __CUSERID
      ZFL->ZFL_DATAAL  := Date()
      ZFL->ZFL_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFL,dizendo que deu certo ou n�o.
      ZFL->ZFL_XML     := _cXML
      ZFL->(MsUnlock()) 
                               
      //================================================================================
      // Integra��o de cancelamento de pedido realizado com sucesso. Disponibiliza
      // pedido para altera��o e aprova��o.
      //================================================================================                       
      If _cSituacao == "P" .Or. _cSituacao == "R"   
         SC5->(RecLock("SC5",.F.))
         SC5->C5_I_ENVRD := "N"  // Situa��o N = Integra��o de Pedido de Vendas Retornado para o Protheus, ou seja, cancelado no sistema RDC.    
         SC5->C5_I_DTRET := Date() // Data de retorno do pedido de vendas do RDC para o Protheus
         SC5->C5_I_HRRET := Time() // Hora de retorno do pedidod e vendas do RDC para o Protheus
         SC5->C5_I_CDTMS := ""     // C5_RASTMS  := ""
         SC5->(MsUnlock())
      EndIf
        
      Aadd(_aresult,{SC5->C5_NUM,ZZM->ZZM_CGC,_cResposta }) // adicona em um array para fazer um item list, exibir os resultados.
      
      Sleep(100) //Espera para n�o travar a comunica��o com o webservice da RDC
      
      If Valtype(oproc) = "O"
     	   oproc:cCaption := (SC5->C5_NUM+" - "+ ZFQ->ZFQ_CNPJEM + " - "  + _cResposta)
   		ProcessMessages()
    	EndIf 
       
   End Transaction
   
   _aCabecalho := {}
   Aadd(_aCabecalho,"PEDIDO" ) 
   Aadd(_aCabecalho,"CNPJ") 
   Aadd(_aCabecalho,"RETORNO") 
             
   _cTitulo := "Resultados da Integra��o"
 
   If !(FWIsInCallStack("U_AOMS108"))  .and. !(FWIsInCallStack("U_AOMS109"))   .and. !(FWIsInCallStack("U_MOMS066"))  //N�o mostra mensagem se veio da exclus�o multipla de PV ou central de logistica 
    
     If _cSituacao <> "P" 
        If _lExibeTela 
      	   u_itmsg("N�o foi poss�vel realizar o cancelamento de Pedidos de Vendas no Sistema TMS MUlti-Embarcador.","Aten��o",,1)
      	Else
      	   U_ITCONOUT("N�o foi poss�vel realizar o cancelamento de Pedidos de Vendas no Sistema TMS MUlti-Embarcador.")
      	EndIf
      
      	If Len(_aResult) > 0 .And. _lExibeTela
      		U_ITListBox( _cTitulo , _aCabecalho , _aResult  ) // Exibe uma tela de resultado.
      	EndIf                 
      Else 
         If _cCodMsg == "500"
            _cMsg := _cResposta
         Else
            _cMsg := "Cancelamento do pedido de vendas no sistema TMS MUlti-Embarcador realizado com sucesso."
         EndIf

         If _lExibeTela
      	    u_itmsg(_cMsg,"Aten��o",,2)
      	 Else
      	    U_ITCONOUT(_cMsg)
      	 EndIf
      EndIf
    
   Endif
    
End Sequence

RestOrd(_aOrd)

Return _lRet   

/*
===============================================================================================================================
Fun��o-------------: AOMS140X
Aut2or-------------: Julio de Paula Paz
Data da Criacao----: 26/10/2023
===============================================================================================================================
Descri��o---------: L� o arquivo XML modelo no diret�rio informado e retorna os dados no formato de String.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/  
User Function AOMS140X(_cArq)
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
Fun��o-------------: AOMS140Y
Autor--------------: Julio de Paula Paz
Data da Criacao----: 26/10/2023
===============================================================================================================================
Descri��o----------: Rotina de Solicita��o de Cancelamento de Pedidos de Vendas no Multi-Embarcador.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140Y()
Local _aCpos := {}

Private _oMarkBRW

Begin Sequence

   aAdd( _aCpos , { "MARCA"		, "C" , 2							   , 0 } )
   AAdd( _aCpos , { "WK_FILIAL"	, "C" , 2                   		, 0 } )
   AAdd( _aCpos , { "WK_PEDIDO"	, "C" , TamSX3("C5_NUM")[01]		, 0 } )
   AAdd( _aCpos , { "WK_CLIENTE"	, "C" , TamSX3("C5_CLIENTE")[01]	, 0 } )
   AAdd( _aCpos , { "WK_LOJACLI"	, "C" , TamSX3("C5_LOJACLI")[01]	, 0 } )
   AAdd( _aCpos , { "WK_NOMECLI"	, "C" , TamSX3("C5_I_NOME")[01]	, 0 } )
   AAdd( _aCpos , { "WK_UFCLI"	, "C" , TamSX3("C5_I_EST")[01]	, 0 } )
   AAdd( _aCpos , { "WK_CODINT"	, "C" , TamSX3("C5_I_CDTMS")[01]	, 0 } ) // C5_RASTMS
   AAdd( _aCpos , { "WK_RECNO"	, "N" , 10                       , 0 } )

   If Select("TRBSC5") > 0
	   TRBSC5->( DBCloseArea() )
   EndIf

   _otemp := FWTemporaryTable():New("TRBSC5", _aCpos )
   
   _otemp:AddIndex( "01", {"WK_FILIAL","WK_PEDIDO"} )
   _otemp:AddIndex( "02", {"WK_PEDIDO"} )

   _otemp:Create()

   _cQry := "SELECT C5_FILIAL, C5_NUM , C5_CLIENTE , C5_LOJACLI, C5_I_NOME,  C5_I_EST, SC5.R_E_C_N_O_ NRREG, C5_I_CDTMS " //C5_RASTMS "
   _cQry += " FROM  "+ RetSqlName("SC5") +" SC5 "
   _cQry += " WHERE "
   _cQry += "     SC5.D_E_L_E_T_  = ' ' "
   _cQry += " AND C5_I_CDTMS <> ' ' "  // C5_RASTMS
   _cQry += " ORDER BY C5_FILIAL, C5_NUM "

   If Select("QRYSC5") > 0
	   QRYSC5->( DBCloseArea() )
   EndIf

   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYSC5" , .T. , .F. )
   MPSysOpenQuery( _cQry , "QRYSC5")
   DBSelectArea("QRYSC5")

   QRYSC5->(DbGoTop())

   Do While ! QRYSC5->(Eof())
      TRBSC5->( RecLock( "TRBSC5" , .T. ) )
      TRBSC5->WK_FILIAL  := QRYSC5->C5_FILIAL 
      TRBSC5->WK_PEDIDO  := QRYSC5->C5_NUM
      TRBSC5->WK_CLIENTE := QRYSC5->C5_CLIENTE
      TRBSC5->WK_LOJACLI := QRYSC5->C5_LOJACLI
      TRBSC5->WK_NOMECLI := QRYSC5->C5_I_NOME
      TRBSC5->WK_UFCLI   := QRYSC5->C5_I_EST
      TRBSC5->WK_CODINT  := QRYSC5->C5_I_CDTMS // QRYSC5->C5_RASTMS
      TRBSC5->WK_RECNO   := QRYSC5->NRREG
      TRBSC5->( MSUnLock() )

      QRYSC5->(DbSkip())
   EndDo 

//----------------------------------
   _aFields := {}
   aAdd( _aFields , { ""			         , {|| TRBSC5->MARCA }      , "C" , ""   , 0 , 2		                   , 0 } )
   aAdd( _aFields , { "Filial"			   , {|| TRBSC5->WK_FILIAL }  , "C" , "@!" , 0 , 2		                   , 0 } )
   aAdd( _aFields , { "Pedido"				, {|| TRBSC5->WK_PEDIDO }	, "C" , "@!" , 0 , TamSX3("C5_NUM")[01]	 , 0 } )
   aAdd( _aFields , { "Cliente"				, {|| TRBSC5->WK_CLIENTE }	, "C" , "@!" , 0 , TamSX3("C5_CLIENTE")[01], 0 } )
   aAdd( _aFields , { "Loja"			      , {|| TRBSC5->WK_LOJACLI }	, "C" , "@!" , 0 , TamSX3("C5_LOJACLI")[01], 0 } )
   aAdd( _aFields , { "Nome "		         , {|| TRBSC5->WK_NOMECLI }	, "C" , "@!" , 0 , TamSX3("C5_I_NOME")[01] , 0 } )
   aAdd( _aFields , { "Estado"			   , {|| TRBSC5->WK_UFCLI}  	, "C" , "@!" , 0 , TamSX3("C5_I_EST")[01]	 , 0 } )
   aAdd( _aFields , { "C�digo Integra��o"	, {|| TRBSC5->WK_CODINT}	, "C" , "@!" , 0 , 10						    , 0 } )

   _oMarkBRW := FWMarkBrowse():New()		   												// Inicializa o Browse

   _oMarkBRW:SetAlias( "TRBSC5" )			   												// Define Alias que ser� a Base do Browse
   _oMarkBRW:SetDescription( "Solicita��o de Cancelamento em Lote de Pedidos de Vendas Integrados para Muilt-Embarcador" )	// Define o titulo do browse de marcacao
   _oMarkBRW:SetFieldMark( "MARCA" )														// Define o campo que sera utilizado para a marca��o
   _oMarkBRW:SetMenuDef( 'AOMS140' )														// For�a a utiliza��o do menu da rotina atual
   //_oMarkBRW:SetAllMark( {|| _oMarkBRW:AllMark() , AOMS140MRK(.T.) } )						// A��o do Clique no Header da Coluna de Marca��o
   //_oMarkBRW:SetAfterMark( {|| AOMS140MRK(.F.) } )											// A��o na marca��o/desmarca��o do registro
   _oMarkBRW:SetFields( _aFields )													 		// Campos para exibi��o
   //_oMarkBRW:AddButton( "Avaliar" , {|| Processa( {|| U_AOMS140V() } , "Avaliando Cliente Bloqueado..." , "Aguarde!" ) } ,, 4 )
   
   //_oMarkBRW:AddLegend({|| (cAliasAux)->BLOQDESC == "1"}, "BR_VERMELHO", "Bloqueado por Desconto Contratual")
   //_oMarkBRW:AddLegend({|| (cAliasAux)->BLOQDESC <> "1"}, "BR_VERDE"   , "Desbloqueado")

   //_oMarkBRW:DisableConfig()

   _oMarkBRW:Activate()																		// Ativacao da classe
 
End Sequence 

If Select("TRBSC5") > 0
	TRBSC5->( DBCloseArea() )
EndIf

 If Select("QRYSC5") > 0
	 QRYSC5->( DBCloseArea() )
 EndIf

Return Nil 

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/10/2023
===============================================================================================================================
Descri��o---------: Rotina de constru��o do menu
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina Title 'Pesquisar'  Action 'U_AOMS140S()'  OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Processar Canc.PV TMS'  Action 'U_AOMS140T()'  OPERATION 2 ACCESS 0
//ADD OPTION aRotina Title 'Visualizar' Action 'U_AOMS140R( TRBSC5->WK_RECNO )' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Teste Leitura Cargas Pendentes TMS'  Action 'U_AOMS140C()'  OPERATION 2 ACCESS 0

Return( aRotina )

/*
===============================================================================================================================
Programa----------: AOMS140S
Autor-------------: Julio de Paula Paz
Data--------------: 23/12/2021
===============================================================================================================================
Descri��o---------: Permite pesquisar um cliente na tela.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS140S()

Local _oGet1	  := Nil 
Local _oDlgP	  := Nil 
Local _cGet1	  := Space(60)
Local _nOpca	  := 0
Local _cComboBx1  := "Filial e Pedido"
Local _aComboBx1  := {"Filial e Pedido","Pedido"}
Local _nRegAtu    :=    TRBSC5->(Recno())

Begin Sequence 

   DEFINE MSDIALOG _oDlgP TITLE "Pesquisar Pedido de Vendas" FROM 178,181 TO 259,697 PIXEL

      @ 004,003 ComboBox	_cComboBx1	Items _aComboBx1 Size 213,010 OF _oDlgP PIXEL
	  @ 020,003 MsGet		_oGet1	Var _cGet1		Size 212,009 OF _oDlgP PIXEL COLOR CLR_BLACK Picture "@!"
	
	  DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlgP:End() ) OF _oDlgP
	  DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlgP:End() ) OF _oDlgP

   ACTIVATE MSDIALOG _oDlgP CENTERED

   If _nOpca == 1
      If ALLTRIM(_cComboBx1) == ALLTRIM(_aComboBx1[1])
         TRBSC5->(DbSetOrder(1))
      Else
         TRBSC5->(DbSetOrder(2))        
      EndIf 
   
      If ! TRBSC5->(MsSeek(RTrim(_cGet1)))
         U_ITMSG("Registro n�o encontrado.","Aten��o",,1)
         TRBSC5->(DbSetOrder(1))
         TRBSC5->(DbGoTo(_nRegAtu))
      Else
         _nRegSC5 := TRBSC5->(Recno())
         //TRBSC5->(DbSetOrder(1))
         TRBSC5->(DbGoto(_nRegSC5))
         _oMarkBRW:oBrowse:Refresh()
      EndIf 
   EndIf

End Sequence

Return .T. 

/*
===============================================================================================================================
Programa----------: AOMS140R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/10/2023
===============================================================================================================================
Descri��o---------: Rotina de consulta do cadastro completo do Cliente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS140R( nRegSC5 )

Private cCadastro := "Pedidos de Vendas"

DBSelectArea("SC5")
SC5->( DBGoTo(nRegSC5) )
AxVisual( "SC5" , nRegSC5 , 2 )

Return()


/*
===============================================================================================================================
Programa----------: AOMS140T
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/10/2023
===============================================================================================================================
Descri��o---------: Rotina de processamento dos pedidos de vendas marcados para cancelamento.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS140T()
//Local cMarca := _oMarkBRW:Mark()

Begin Sequence 
   TRBSC5->(DbGotop())

   Do While ! TRBSC5->(Eof())
      //If _oMarkBRW:IsMark(cMarca)
      If ! Empty(TRBSC5->MARCA)
         SC5->(DbGoto(TRBSC5->WK_RECNO))
         U_AOMS140E( , .F. )
      EndIf 

      TRBSC5->(DbSkip())
   EndDo

End Sequence 

Return Nil 

//===============================================

// Metodo:
// BuscarCargaPorCodigosIntegracao() - Utiliza o Numero da carga. Traz todas as informa��es da Carga 
//                                    e os pedidos de vendas que integram a carga.

// Metodo: indicado pelo Vanderlei.
// BuscarCarregamentosPendentesIntegra�ao() - Retorna todas as cargas pendentes de integra��o. Retorna os protocolos de todos
                                         //   os pedidos que fazem parte da carga, mas n�o traz o numero da Carga.

// Metodo: 
// ConsultarCargaPedido() - Ao informar o Protocolo, est� retornando numero da carga errada.
// Protocolo Pedido de Vendas:
// 2139
// Retorno no Webservice, mensagem com erro.

/*
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
   <s:Body>
      <ConsultarCargaPedidoResponse xmlns="http://tempuri.org/">
         <ConsultarCargaPedidoResult xmlns:a="http://schemas.datacontract.org/2004/07/SGT.WebService" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <a:CodigoMensagem>200</a:CodigoMensagem>
            <a:DataRetorno>10/11/2023 15:21:29</a:DataRetorno>
            <a:Mensagem>Pedido protocolo 2139 est� alocado a carga 150</a:Mensagem>
            <a:Objeto>true</a:Objeto>
            <a:Status>true</a:Status>
         </ConsultarCargaPedidoResult>
      </ConsultarCargaPedidoResponse>
   </s:Body>
</s:Envelope>

//===========================================//

BuscarResumoCargaPorCodigosIntegracao()

---------------------------------------
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:dom="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.WebService.Carga">
   <soapenv:Header>
    <Token xmlns="Token">a78e0523d3794843855e8d95c2bff8d4</Token>
    </soapenv:Header>
   <soapenv:Body>
      <tem:BuscarResumoCargaPorCodigosIntegracao>
         <!--Optional:-->
         <tem:codigosIntegracao>
            <!--Optional:-->
            <dom:CodigoIntegracaoFilial>01</dom:CodigoIntegracaoFilial>
            <!--Optional:-->
            <dom:NumeroCarga></dom:NumeroCarga>
            <!--Optional:-->
            <dom:NumeroPedidoEmbarcador>ACWY90</dom:NumeroPedidoEmbarcador>
         </tem:codigosIntegracao>
      </tem:BuscarResumoCargaPorCodigosIntegracao>
   </soapenv:Body>
</soapenv:Envelope>

---------------------------------------

<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
   <s:Body>
      <BuscarResumoCargaPorCodigosIntegracaoResponse xmlns="http://tempuri.org/">
         <BuscarResumoCargaPorCodigosIntegracaoResult xmlns:a="http://schemas.datacontract.org/2004/07/SGT.WebService" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <a:CodigoMensagem>0</a:CodigoMensagem>
            <a:DataRetorno>13/11/2023 12:03:07</a:DataRetorno>
            <a:Mensagem i:nil="true"/>
            <a:Objeto xmlns:b="http://schemas.datacontract.org/2004/07/Dominio.ObjetosDeValor.WebService.Carga.Resumo">
               <b:NumeroCarga>152</b:NumeroCarga>
               <b:Pedidos>
                  <b:Pedido>
                     <b:CTe/>
                     <b:NFSe/>
                     <b:NumeroPedidoEmbarcador>ACWY90</b:NumeroPedidoEmbarcador>
                     <b:Protocolo>2157</b:Protocolo>
                  </b:Pedido>
               </b:Pedidos>
               <b:Protocolo>176</b:Protocolo>
               <b:Situacao>Nova Carga</b:Situacao>
            </a:Objeto>
            <a:Status>true</a:Status>
         </BuscarResumoCargaPorCodigosIntegracaoResult>
      </BuscarResumoCargaPorCodigosIntegracaoResponse>
   </s:Body>
</s:Envelope>
*/

/*
===============================================================================================================================
Programa----------: AOMS140C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/11/2023
===============================================================================================================================
Descri��o---------: Rotina de processamento de leitura das cargas pendentes de integra��o no TMS MULTI-EMBARCADOR,
                    Para a cria��o dessas cargas no Protheus.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS140C(oproc,_lExibeTela)

Local _cDirXML := ""
Local _cLink   := ""
Local _cCargPXML := ""
Local _cCodEmpWS 
Local _cXML 
Local _cResult := ""
Local _cCodMsg := ""
Local _nI

Private _nIniCarre, _nLimCarre

Begin Sequence
   If Empty(oproc)
      oproc := NIL
   EndIf 

   If Empty(_lExibeTela)
      _lExibeTela := .T.
   EndIf 

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   
   If ValType(_lExibeTela) == "U"
      _lExibeTela := .T.
   EndIf 

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Identificando diret�rio dos XML...")
  		ProcessMessages()
   EndIf

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK01)
   Else         
      If _lExibeTela
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140] Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Lendo arquivo XML Modelo de Carga Pendentes Integra��o...")
  		ProcessMessages()
   EndIf 
    
   _cCargPXML := U_AOMS140X(_cDirXML+"BuscarCarregamentosPendentesIntegracao_TMS.txt") 
   
   If Empty(_cCargPXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo de Cargas Pendentes de Integra��o. ","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Erro na leitura do arquivo XML modelo de Cargas Pendentes de Integra��o. ")
      EndIf
      Break
   EndIf
   
//   ZZM->(DbSetOrder(1))
//   SA2->(DbSetOrder(3)) 
//   ZZM->(DbSeek(xFilial("ZZM")+SC5->C5_FILIAL))
//   SA2->(DbSeek(xFilial("SA2")+ZZM->ZZM_CGC))   
   
   //================================================================================
   // Concatena os Pedidos de Vendas selecionados e monta array de XML com os dados.
   //================================================================================                       
   IF ValType(oproc) = "O"
     	oproc:cCaption := ("Montando dados de envio...")
  		ProcessMessages()
   ENDIF

   _nIniCarre := 1   // Inicio da leitura das cargas pendentes no TMS.
   _nLimCarre := 100 // N�mero M�ximo de Registros Lidos.
   
   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
   oWsdl:nTimeout := 10          // Timeout de 10 segundos 
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    
   
   //oWsdl:ParseURL( "http://10.3.0.201/wsitf18/Service.svc?wsdl") // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
   oWsdl:SetOperation( "BuscarCarregamentosPendentesIntegracao") // Define qual opera��o ser� realizada.
   
   _aresult := {}
   
   //Begin Transaction     
      //===============================================================================
      // Realiza a integra��o dos pedidos de vendas (Envio de XML) via WebService.
      //===============================================================================
         
 	   // Monta XML
 	   _cXML := &(_cCargPXML)  // Monta o XML de envio.

	   // Envia para o servidor
      _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            
      If _cOk 
         //_cResult  := oWsdl:GetParsedResponse() // Pega o resultado de envio j� no formato em string.
         //_cResult2 := oWsdl:GetSoapMsg()
         _cResult3 := oWsdl:GetSoapResponse()
      Else
         _cResult := oWsdl:cError
      EndIf   
            
      //_cResposta := Upper(_cResposta)
      _nPosIni := 0
      _nPosFin := 0
      _cXmlCarre := ""

      _nPosIni := At(":Itens",_cResult3)
      _nPosFin := At("<a:NumeroTotalDeRegistro>",_cResult3)
      _cXmlCarre := SubStr(_cResult3, _nPosIni - 2,(_nPosFin - _nPosIni)+2)

      _cError   := ""
      _cWarning := ""

      _oXml_a    := XmlParser(_cXmlCarre, "_", @_cError, @_cWarning ) 
      _oXmlCar_a := XmlChildEx(_oXml_a:_A_ITENS,"_B_CARREGAMENTO")

      For _nI := 1 To Len(_oXmlCar_a)
          
          _oXmlCar_C := _oXmlCar_a[_nI]:_B_PROTOCOLOCARREGAMENTO:TEXT
/*
          SC5->(DbSetOrder(33)) // indice X / C5_FILIAL + C5_I_CDTMS

          Pesquisar por _oXmlCar_C

          Achando o pedido na SC5

          Utilizar o m�todo: BuscarResumoCargaPorCodigosIntegracao()

          Neste m�todo devemos informar o C�digo da Filial e o numero do Pedido de Venda. O m�todo retorna o Numero da Carga.

          Com o N�mero da Carga, utiliar o m�todo: BuscarCargaPorCodigosIntegracao()

          Este m�todo traz todas as informa��es da carga e todas as informa��es dos Pedidos de Vendas que fazem parte da carga.

          Com os dados da Carga, utilizar o fonte AOMS074, metodo U_INCLUIC para incluir a carga no Protheus.
*/

      Next 


      _cError   := ""
      _cWarning := ""

      _oXml      := XmlParser(_cResult3, "_", @_cError, @_cWarning ) 
      _oXmlCarre := XmlChildEx(_oXml:_OBJETO,"_ITENS")

//--------------------------------------------------------------
      _cTextoPesq := Upper(_cResult)
      _cCodMsg := ""
      _cTextoMsg := ""

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS140N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/11/2023
===============================================================================================================================
Descri��o---------: Rotina de Envio do XML da nota fiscal para o sistema TMS Mulit-Embarcador.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140N(lCancel)
    
If _lScheduler 
   If lCancel
      AOMS140Z()
   Else
      AOMS140G()
   EndIf
Else
   If lCancel
      Processa( {|oProc| AOMS140Z(oProc,.T.)},"Hora Ini: "+Time()+", Aguarde...")
   Else
      Processa( {|oProc| AOMS140G(oProc,.T.)},"Hora Ini: "+Time()+", Aguarde...")
   EndIf
EndIf

Return .F.
/*
===============================================================================================================================
Programa----------: AOMS140G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/11/2023
===============================================================================================================================
Descri��o---------: Rotina de leitura dos dados e envio do XML para o sistema TMS Multi-Embarcador.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function AOMS140G(oproc,_lExibeTela)
Local _cQry
Local _dDataIntRDC := U_ItGetMv("IT_DTINTRDC",Ctod("25/10/2016"))
//Local _cDirXML := "\DATA\JULIO\"  // U_ITGetMv("IT_DIRXMLRD","\\10.7.0.57\totvs\Desenv\Protheus_data\data\RDC\RW17") 
//Local _cNomeArq, _nHandle
Local _nTotRegs:=0
Local _cXmlNfe, _cProtNfe
Local _cXmlEnv, _cPart1Xml, _cPart2Xml, _nI, _nF       
Local _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x TMS Multi-Embarcador
Local _cListaFiliais
Local _cTimeIni:=Time()
//----------------------------------------------//
Local _cDirXML := ""
Local _cLink   := ""
Local _cModXML := ""
Local _cCodEmpWS 
Local _cXML 
Local _cResult := ""
//Local _cResposta, _cSituacao
//Local _lRet := .F.
//Local _cCodMsg := ""

Private _cToken

Begin Sequence 
   
   If !_lScheduler .AND. ! U_ItMsg("Confirma a integra��o de Notas Fiscais, Italac <---> TMS Multi-Embarcador?","Inicio de processamento",,2,2,2) 
      Break
   EndIf
//=================================================
   If Empty(oproc)
      oproc := NIL
   EndIf 

   If Empty(_lExibeTela)
      _lExibeTela := .T.
   EndIf 

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   
   If ValType(_lExibeTela) == "U"
      _lExibeTela := .T.
   EndIf 

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Identificando diret�rio dos XML...")
  		ProcessMessages()
   EndIf

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK02)
   Else         
      If _lExibeTela
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140] Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Lendo arquivo XML Modelo de Envio do XML da Nota Fiscal...")
  		ProcessMessages()
   EndIf 
    
   _cModXML := U_AOMS140X(_cDirXML+"EnviarArquivoXMLNFe_TMS.txt") 
   
   If Empty(_cModXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo de envio do modelo do XML da Nota Fiscal. ","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Erro na leitura do arquivo XML modelo de envio do modelo do XML da Nota Fiscal. ")
      EndIf
      Break
   EndIf

   _cListaFiliais := AllTrim(_cFilHabilit)                             
   _cListaFiliais := StrTran(_cListaFiliais,";","','")                                                                                                      

   IF !_lScheduler
      ProcRegua(0)
      IncProc("Lendo dados da SPED50/SF2...")
   EndIf
   
   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================
      _cQry := " SELECT SPED50.R_E_C_N_O_ NRECNO, SF2.R_E_C_N_O_ NRECSF2, SPED54.R_E_C_N_O_ NREC54, DAK.R_E_C_N_O_ NRECDAK "
      _cQry += " FROM "+RetSqlName("SF2")+" SF2, SPED050 SPED50, SPED054 SPED54, "+RetSqlName("DAK")+" DAK "
      _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' "
      _cQry += "   AND SPED50.D_E_L_E_T_ <> '*' "
      _cQry += "   AND SPED54.D_E_L_E_T_ <> '*' "
      _cQry += "   AND DAK.D_E_L_E_T_ <> '*' "
      _cQry += "   AND F2_I_SITUA = ' ' "
      _cQry += "   AND DOC_CHV = F2_CHVNFE "
      _cQry += "   AND NFE_CHV = F2_CHVNFE "
      _cQry += "   AND F2_ESPECIE = 'SPED' "
      _cQry += "   AND F2_EMISSAO >= '" + DTos(_dDataIntRDC) + "' "
      _cQry += "   AND F2_CHVNFE <> ' ' "
      _cQry += "   AND SPED50.STATUS = '6' "
      _cQry += "   AND SPED54.CSTAT_SEFR = '100' "     
      _cQry += "   AND DAK_FILIAL = F2_FILIAL "
      _cQry += "   AND DAK_COD = F2_CARGA "
      _cQry += "   AND DAK_I_CARG <> ' ' " 
   

   _cQry := ChangeQuery(_cQry)         

   If Select("TRBSPED") > 0
      TRBSPED->( DBCloseArea() )
   EndIf

   //DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSPED" , .T., .F. ) 
   MPSysOpenQuery( _cQry , "TRBSPED")
   DBSelectArea("TRBSPED")                           
                                                                                  
   COUNT TO _nTotRegs
   IF !_lScheduler
      ProcRegua(_nTotRegs)
      _cTotal:=ALLTRIM(STR(_nTotRegs))
   EndIf
                          
   TRBSPED->(DbGoTop())
   
   u_itconout("Programa AOMS140, gravando arquivo XML de nota fiscal eletr�nica em diret�rio do Protheus.")
   u_itconout("Data: "+Dtoc(Date())+" Hora: "+Time())
   u_itconout("Total de arquivos XML a serem gravados em diret�rio: "+Str(_nTotRegs,8))
   
   //===================================================================================================
   // Abre o arquivo de Sped para leitura dos XML e Envio para o TMS MUlti-Embarcador
   //===================================================================================================
   If Select("SPED050") > 0
      SPED050->( DBCloseArea() )
   EndIf     
   
   USE SPED050 ALIAS SPED050 SHARED NEW VIA "TOPCONN" 
   
   If Select("SPED054") > 0
      SPED054->( DBCloseArea() )
   EndIf     
   
   USE SPED054 ALIAS SPED054 SHARED NEW VIA "TOPCONN" 
   
   //===================================================================================================
   // Inicia a leitura do arquivo de Sped para leitura dos XML e Envio para o TMS MUlti-Embarcador.
   //===================================================================================================   
   _cDirXML := AllTrim(_cDirXML)
   If Right(_cDirXML,1) <> "\"
      _cDirXML := _cDirXML + "\"
   EndIf   
   
   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM                                                                                                                                                
   _nConta:=0
   _nEnviados:=0
   Do While !TRBSPED->(Eof()) 

      IF !_lScheduler
         _nConta++
         IncProc("Registros Lidos: "+ALLTRIM(STR(_nConta))+" de "+_cTotal)   
      EndIf

      SF2->(DbGoTo(TRBSPED->NRECSF2))
      DAK->(dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))
      SC5->(DbSeek(SF2->F2_FILIAL+SF2->F2_I_PEDID))
      
      _lok := .T.
      
      Begin Sequence
      
      If !(SF2->F2_FILIAL $ _cListaFiliais) // Ignora todas as filiais das notas fiscais que n�o est�o no par�metro e as filiais dos pedidos de origem da troca de nota que n�o est�o no par�metro.
         If Empty(SC5->C5_I_FLFNC) .Or. ! (SC5->C5_I_FLFNC $ _cListaFiliais) 
            _lok := .F.
            Break
         EndIf 
      EndIf
      
      If Empty(SC5->C5_I_FLFNC) // � um pedido de vendas normal. N�o � um pedido de troca nota.
         // Validar a exist�ncia de cargas apenas para Pedidos de Vendas Normais.      
         If Empty(DAK->DAK_I_CARG)
            _lok := .F.
            Break
         EndIf
      EndIf
      
      If Alltrim(SC5->C5_TIPO) <> "N" // Diferente de um pedido normal.
            _lok := .F.
            Break
      EndIf
      
      If SC5->C5_I_TRCNF != "S" .AND. EMPTY(DAK->DAK_I_CARG)  //Se n�o � troca nota e carga n�o foi montada pelo RDC 
            _lok := .F.
            Break
      EndIf
      
      If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDPR .AND. EMPTY(DAK->DAK_I_CARG)  //Se � troca nota, pedido de carregamento e carga n�o foi montada pelo RDC 
            _lok := .F.
            Break
      EndIf
      
      If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDFT   //Se � troca nota, pedido de faturamento
      
      		_nSC5 := SC5->(Recno())
      		_nSF2 := SF2->(Recno())
      		_nDAK := DAK->(Recno())
      		
      		_lok := .F.
      		
      		If SC5->(dbseek(SC5->C5_I_FLFNC+SC5->C5_I_PDPR))
      		
      			If SF2->(dbseek(SC5->C5_FILIAL+SC5->C5_NOTA))
      			
      				If DAK->(dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))
      				
      					If !Empty(DAK->DAK_I_CARG) //Se achou a carga de carregamento e foi gerada pelo rdc deixa enviar o xml
      					
      						_lok := .T.
      						
      					Endif
      					
      				Endif
      				
      			Endif
      			
      		Endif
      		
    		SC5->(Dbgoto(_nSC5))
      		SF2->(Dbgoto(_nSF2))
      		DAK->(Dbgoto(_nDAK))
      		
      		
      		If !_lok
      		
      			Break
      			
      		Endif
        
      EndIf

      SPED050->(DbGoTo(TRBSPED->NRECNO))
      
      u_itconout("Gravando o arquivo XML: " +SPED050->DOC_CHV)
           
      End Sequence
      
      If _lok
      
        	SPED054->(DbGoTo(TRBSPED->NREC54))

        	_cNomeArq := AllTrim(SPED050->DOC_CHV) + ".XML"                                                      
      
        	//===================================================================================================
        	// Monta XML para envio ao RDC
        	//===================================================================================================   
                         
        	_cXmlNfe := SPED050->XML_SIG
     
        	_cProtNfe := SPED054->XML_PROT
                                                
     
        	_nI := AT( "<infNFe", _cXmlNfe ) 
        	_nF := AT( "</NFe>", _cXmlNfe ) 
        	_cPart1Xml := SubStr(_cXmlNfe,_nI,_nF - _nI)
                                                   
        	_nI := AT( "<protNFe", _cProtNfe ) 
        	_nF := AT( "</protNFe>", _cProtNfe ) 
        	_cPart2Xml := SubStr(_cProtNfe,_nI,_nF + 11)
     
        	_cXmlEnv := '<?xml version="1.0" encoding="UTF-8"?> <nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10"> <NFe>  '
        	_cXmlEnv := _cXmlEnv + _cPart1Xml + "</NFe>" + _cPart2Xml + '   </nfeProc> '
         
         //_cXmlEnv_2 := Encode64(_cXmlEnv)  
         _cXML_Nfe := _cXmlEnv

         If ValType(oproc) = "O"
     	      oproc:cCaption := ("Montando dados de envio...")
  		      ProcessMessages()
         EndIf

         _nIniCarre := 1   // Inicio da leitura das cargas pendentes no TMS.
         _nLimCarre := 100 // N�mero M�ximo de Registros Lidos.
   
         oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
         oWsdl:nTimeout := 10          // Timeout de 10 segundos 
         oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    
   
         //oWsdl:ParseURL( "http://10.3.0.201/wsitf18/Service.svc?wsdl") // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
         oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
         oWsdl:SetOperation( "EnviarArquivoXMLNFe") // Define qual opera��o ser� realizada.
   
         //===============================================================================
         // Realiza a integra��o dos pedidos de vendas (Envio de XML) via WebService.
         //===============================================================================
         
 	      // Monta XML
 	      _cXML := &(_cModXML)  // Monta o XML de envio.

	      // Envia para o servidor
         _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            
         If _cOk 
            _cResult := oWsdl:GetSoapResponse()

            _nPosi := AT("<a:Objeto>", _cResult)             
            _nPosf := AT("</a:Objeto>", _cResult)	
            
            If _nPosi == 0
               _cProtocolo := ""
            Else
               _cProtocolo := substr(_cresult,_nposi+Len("<a:Objeto>"),_nposf-_nposi-Len("<a:Objeto>"))
            Endif
            
         Else
            _cResult := oWsdl:cError
            _cProtocolo := ""
         EndIf   

         If _cOk 
        	   SF2->(RecLock("SF2",.F.))
        	   SF2->F2_I_SITUA := 'P'    
        	   SF2->F2_I_DTENV := Date()
        	   SF2->F2_I_HRENV := Time()
            SF2->F2_I_PRTMS := _cProtocolo      //Protocolo TMS
           	SF2->(MsUnLock())
            _nEnviados++
         EndIf 

         ZFK->(RecLock("ZFK",.T.))
         ZFK->ZFK_FILIAL := SF2->F2_FILIAL
         ZFK->ZFK_DATA   := Date()  
         ZFK->ZFK_HORA   := Time()
         ZFK->ZFK_TIPOI  := "2"
         ZFK->ZFK_CHVNFE := SF2->F2_CHVNFE
         ZFK->ZFK_PEDPAL := Iif(SC5->C5_I_PEDPA == "S","S","N")  
         ZFK->ZFK_CGC    := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_CGC") 
         ZFK->ZFK_PEDIDO := SC5->C5_NUM
         ZFK->ZFK_COD	 := SF2->F2_CLIENTE    // C�digo Cliente    // SA2->A2_COD  - Fornecedor    // O correto �: A1_COD
         ZFK->ZFK_LOJA   := SF2->F2_LOJA       // Loja Cliente      // SA2->A2_LOJA - Fornecedor    //              A1_LOJA
         ZFK->ZFK_NOME   := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")   // Nome Cliente      // SA2->A2_NOME - Fornecedor   //              A1_NOME
         ZFK->ZFK_USUARI := __cUserId
         ZFK->ZFK_SITUAC := Iif(_cOk,"S","N")
         ZFK->ZFK_RETORN := _cResult
         ZFK->ZFK_CODEMP := _cCodEmpWS
         ZFK->ZFK_XML    := _cXML_Nfe
         ZFK->ZFK_PRTMS  := _cProtocolo

         ZFK->(MsUnLock())

      Else
      
      	SF2->(RecLock("SF2",.F.))
        	SF2->F2_I_SITUA := 'N'    
        	SF2->F2_I_DTENV := Date()
        	SF2->F2_I_HRENV := Time()
        	SF2->(MsUnLock())
      		
      Endif
            
      TRBSPED->(DbSkip())
      
   EndDo

   _cTextoFim:="Notas Fiscais enviadas: "+STR(_nEnviados)+Chr(10)
   u_itconout("Termino da Integra��o de Notas Fiscais, Italac <---> TMS Multi-Embarcador "+_cTextoFim)
   If !_lScheduler
      u_itmsg(">> Processamento conclu�do << "+Chr(10)+;
              "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+_cTextoFim,;
              "Fim de processamento",,2)
   EndIf
   
End Sequence

//================================================================================
// Fecha as tabelas tempor�rias
//================================================================================                    
If Select("TRBSPED") > 0
   TRBSPED->( DBCloseArea() )
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
Programa----------: AOMS140A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/11/2023
===============================================================================================================================
Descri��o---------: Rotina para rodar a integra��o de envio das Notas Fiscais em Scheduller.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140A(lCancel)

Default lCancel := .F.

_lScheduler := FWGetRunSchedule() .OR. SELECT("SX3") <= 0

Begin Sequence

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
      
      U_AOMS140N(lCancel) 
   Else
      U_AOMS140N(lCancel)
   EndIf

End Sequence

Return



/*
===============================================================================================================================
Programa----------: AOMS140G
Autor-------------: Igor Fricks
Data da Criacao---: 23/01/2024
===============================================================================================================================
Descri��o---------: Rotina de Informar Cancelamento para o sistema TMS Multi-Embarcador.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function AOMS140Z(oproc,_lExibeTela)
Local _cQry
Local _nTotRegs:=0
Local _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x TMS Multi-Embarcador
Local _cListaFiliais
Local _cTimeIni:=Time()
//----------------------------------------------//
Local _cDirXML := ""
Local _cLink   := ""
Local _cModXML := ""
Local _cCodEmpWS 
Local _cXML 
Local _cResult := ""
Local _nPosi := 0
Local _nPosf := 0
Local _cProtocolo := ""

Private _cToken

Begin Sequence 
   
   If !_lScheduler .AND. ! U_ItMsg("Confirma a integra��o de Notas Fiscais, Italac <---> TMS Multi-Embarcador?","Inicio de processamento",,2,2,2) 
      Break
   EndIf

   If Empty(oproc)
      oproc := NIL
   EndIf 

   If Empty(_lExibeTela)
      _lExibeTela := .T.
   EndIf 

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   
   If ValType(_lExibeTela) == "U"
      _lExibeTela := .T.
   EndIf 

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Identificando diret�rio dos XML...")
  		ProcessMessages()
   EndIf

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK02)
   Else         
      If _lExibeTela
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140] Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   If valtype(oproc) = "O"
     	oproc:cCaption := ("Lendo arquivo XML Modelo de Envio do XML da Nota Fiscal...")
  		ProcessMessages()
   EndIf 
    
   _cModXML := U_AOMS140X(_cDirXML+"EnviarArquivoXMLNFe_TMS.txt") 
   
   If Empty(_cModXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo de envio do modelo do XML da Nota Fiscal. ","Aten��o",,1)
      Else
         U_ITCONOUT("[AOMS140E] Erro na leitura do arquivo XML modelo de envio do modelo do XML da Nota Fiscal. ")
      EndIf
      Break
   EndIf

   //=================================================
   _cListaFiliais := AllTrim(_cFilHabilit)                             
   _cListaFiliais := StrTran(_cListaFiliais,";","','")                                                                                                      

   IF !_lScheduler
      ProcRegua(0)
      IncProc("Lendo dados da SPED50/SF2...")
   EndIf
   
   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================

   _cQry := " SELECT SF2.R_E_C_N_O_ NRECSF2, F2_FILIAL, F2_DOC, F2_SERIE, SPED054.R_E_C_N_O_ NREC54 "
   _cQry += " FROM SPED054, SPED001, SYS_COMPANY SM0, "+RetSqlName("SF2")+" SF2 "
   _cQry += " WHERE DTREC_SEFR >= TO_CHAR(SYSDATE -360,'YYYYMMDD') "
   _cQry += " WHERE DTREC_SEFR >= TO_CHAR(SYSDATE -5,'YYYYMMDD') "
   _cQry += "   AND CSTAT_SEFR = '101' "
   _cQry += "   AND SPED054.D_E_L_E_T_ = ' ' "
   _cQry += "   AND SPED001.D_E_L_E_T_ = ' ' "
   _cQry += "   AND SM0.D_E_L_E_T_ = ' ' "
   _cQry += "   AND SPED001.IE = SM0.M0_INSC "
   _cQry += "   AND SPED001.ID_ENT = SPED054.ID_ENT "
   _cQry += "   AND SM0.M0_CGC = SPED001.CNPJ "
   _cQry += "   AND F2_FILIAL = M0_CODFIL "
   _cQry += "   AND F2_SERIE = SUBSTR (NFE_ID, 1, 3) "
   _cQry += "   AND F2_DOC = SUBSTR (NFE_ID, 4, 9) "
   _cQry += "   AND F2_I_SITUA = 'P' "

   _cQry := ChangeQuery(_cQry)         

   If Select("TRBSPED") > 0
      TRBSPED->( DBCloseArea() )
   EndIf

   //DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSPED" , .T., .F. )    
   MPSysOpenQuery( _cQry , "TRBSPED")
   DBSelectArea("TRBSPED")                        
                                                                                  
   COUNT TO _nTotRegs
   IF !_lScheduler
      ProcRegua(_nTotRegs)
      _cTotal:=ALLTRIM(STR(_nTotRegs))
   EndIf
                          
   TRBSPED->(DbGoTop())
   
   u_itconout("Programa AOMS140, gravando arquivo XML de nota fiscal eletr�nica em diret�rio do Protheus.")
   u_itconout("Data: "+Dtoc(Date())+" Hora: "+Time())
   u_itconout("Total de arquivos XML a serem gravados em diret�rio: "+Str(_nTotRegs,8))
   
   //===================================================================================================
   // Abre o arquivo de Sped para leitura dos XML e Envio para o RDC.
   //===================================================================================================
   If Select("SPED001") > 0
      SPED001->( DBCloseArea() )
   EndIf     
   
   USE SPED001 ALIAS SPED001 SHARED NEW VIA "TOPCONN" 
   
   If Select("SPED054") > 0
      SPED054->( DBCloseArea() )
   EndIf     
   
   USE SPED054 ALIAS SPED054 SHARED NEW VIA "TOPCONN" 
   
   //===================================================================================================
   // Inicia a leitura do arquivo de Sped para leitura dos XML e Envio para o RDC.
   //===================================================================================================   
   _cDirXML := AllTrim(_cDirXML)
   If Right(_cDirXML,1) <> "\"
      _cDirXML := _cDirXML + "\"
   EndIf   
   
   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM                                                                                                                                                
   _nConta:=0
   _nEnviados:=0
   Do While !TRBSPED->(Eof()) 

      IF !_lScheduler
         _nConta++
         IncProc("Registros Lidos: "+ALLTRIM(STR(_nConta))+" de "+_cTotal)   
      EndIf

      SF2->(DbGoTo(TRBSPED->NRECSF2))
      DAK->(dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))
      SC5->(DbSeek(SF2->F2_FILIAL+SF2->F2_I_PEDID))
      
      _lok := .T.
      
      Begin Sequence
      
      If !(SF2->F2_FILIAL $ _cListaFiliais) // Ignora todas as filiais das notas fiscais que n�o est�o no par�metro e as filiais dos pedidos de origem da troca de nota que n�o est�o no par�metro.
         If Empty(SC5->C5_I_FLFNC) .Or. ! (SC5->C5_I_FLFNC $ _cListaFiliais) 
            _lok := .F.
            Break
         EndIf 
      EndIf
      
      If Empty(SC5->C5_I_FLFNC) // � um pedido de vendas normal. N�o � um pedido de troca nota.
         // Validar a exist�ncia de cargas apenas para Pedidos de Vendas Normais.      
         If Empty(DAK->DAK_I_CARG)
            _lok := .F.
            Break
         EndIf
      EndIf
      
      If Alltrim(SC5->C5_TIPO) <> "N" // Diferente de um pedido normal.
            _lok := .F.
            Break
      EndIf
      
      If SC5->C5_I_TRCNF != "S" .AND. EMPTY(DAK->DAK_I_CARG)  //Se n�o � troca nota e carga n�o foi montada pelo RDC 
            _lok := .F.
            Break
      EndIf
      
      If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDPR .AND. EMPTY(DAK->DAK_I_CARG)  //Se � troca nota, pedido de carregamento e carga n�o foi montada pelo RDC 
            _lok := .F.
            Break
      EndIf
      
      If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDFT   //Se � troca nota, pedido de faturamento
      
      		_nSC5 := SC5->(Recno())
      		_nSF2 := SF2->(Recno())
      		_nDAK := DAK->(Recno())
      		
      		_lok := .F.
      		
      		If SC5->(dbseek(SC5->C5_I_FLFNC+SC5->C5_I_PDPR))
      		
      			If SF2->(dbseek(SC5->C5_FILIAL+SC5->C5_NOTA))
      			
      				If DAK->(dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))
      				
      					If !Empty(DAK->DAK_I_CARG) //Se achou a carga de carregamento e foi gerada pelo rdc deixa enviar o xml
      					
      						_lok := .T.
      						
      					Endif
      					
      				Endif
      				
      			Endif
      			
      		Endif
      		
    		   SC5->(Dbgoto(_nSC5))
      		SF2->(Dbgoto(_nSF2))
      		DAK->(Dbgoto(_nDAK))
      		
      		
      		If !_lok
      		
      			Break
      			
      		Endif
        
      EndIf

      End Sequence
      
      If _lok
      
        	SPED054->(DbGoTo(TRBSPED->NREC54))

         _cProtNfe := SPED054->XML_PROT

        	_nposi := AT( "<nProt>", _cProtNfe ) 
        	_nposf := AT( "</nProt>", _cProtNfe ) 

         _cProtocolo := substr(_cProtNfe,_nposi+Len("<nProt>"),_nposf-_nposi-Len("<nProt>"))

         _cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
         _cXML += '<soapenv:Header>'
         _cXML += '<Token xmlns="Token">'+EncodeUTF8(AllTrim(_cToken))+'</Token>'
         _cXML += '</soapenv:Header>'
         _cXML += '<soapenv:Body>'
         _cXML += '<tem:InformarCancelamentoNotaFiscal>'
         _cXML += '<tem:protocoloNFe>'+ EncodeUTF8(AllTrim(_cProtocolo)) +'</tem:protocoloNFe>'
         _cXML += '</tem:InformarCancelamentoNotaFiscal>'
         _cXML += '</soapenv:Body>'
         _cXML += '</soapenv:Envelope>'

         If ValType(oproc) = "O"
     	      oproc:cCaption := ("Montando dados de envio...")
  		      ProcessMessages()
         EndIf
         
         _nIniCarre := 1   // Inicio da leitura das cargas pendentes no TMS.
         _nLimCarre := 100 // N�mero M�ximo de Registros Lidos.
   
         oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
         oWsdl:nTimeout := 10          // Timeout de 10 segundos 
         oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                                    
   
         //oWsdl:ParseURL( "http://10.3.0.201/wsitf18/Service.svc?wsdl") // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
         oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
         oWsdl:SetOperation( "InformarCancelamentoNotaFiscal") // Define qual opera��o ser� realizada.
   
         _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            
         If _cOk 
            _cResult := oWsdl:GetSoapResponse()

            _nPosi := AT("<a:Objeto>", _cResult)             
            _nPosf := AT("</a:Objeto>", _cResult)	
            
            If _nPosi == 0
               _cProtocolo := ""
            Else
               _cProtocolo := substr(_cresult,_nposi+Len("<a:Objeto>"),_nposf-_nposi-Len("<a:Objeto>"))
            Endif

         Else
            _cResult := oWsdl:cError
            _cProtocolo := ""
         EndIf   

         If _cOk 
        	   SF2->(RecLock("SF2",.F.))
        	   SF2->F2_I_SITUA := 'P'    
        	   SF2->F2_I_DTENV := Date()
        	   SF2->F2_I_HRENV := Time()
           	SF2->(MsUnLock())
            _nEnviados++
         EndIf 

         ZFK->(RecLock("ZFK",.T.))
         ZFK->ZFK_FILIAL := SF2->F2_FILIAL
         ZFK->ZFK_DATA   := Date()  
         ZFK->ZFK_HORA   := Time()
         ZFK->ZFK_TIPOI  := "3"
         ZFK->ZFK_CHVNFE := SF2->F2_CHVNFE
         ZFK->ZFK_PEDPAL := Iif(SC5->C5_I_PEDPA == "S","S","N")  
         ZFK->ZFK_CGC    := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_CGC") 
         ZFK->ZFK_PEDIDO := SC5->C5_NUM
         ZFK->ZFK_COD	 := SF2->F2_CLIENTE    // C�digo Cliente    // SA2->A2_COD  - Fornecedor    // O correto �: A1_COD
         ZFK->ZFK_LOJA   := SF2->F2_LOJA       // Loja Cliente      // SA2->A2_LOJA - Fornecedor    //              A1_LOJA
         ZFK->ZFK_NOME   := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")   // Nome Cliente      // SA2->A2_NOME - Fornecedor   //              A1_NOME
         ZFK->ZFK_USUARI := __cUserId
         ZFK->ZFK_SITUAC := Iif(_cOk,"S","N")
         ZFK->ZFK_RETORN := _cResult
         ZFK->ZFK_CODEMP := _cCodEmpWS
         //ZFK->ZFK_XML    := _cXML_Nfe
         ZFK->ZFK_PRTMS  := _cProtocolo

         ZFK->(MsUnLock())

      Else
      
      	SF2->(RecLock("SF2",.F.))
        	SF2->F2_I_SITUA := 'N'    
        	SF2->F2_I_DTENV := Date()
        	SF2->F2_I_HRENV := Time()
        	SF2->(MsUnLock())
      		
      Endif
            
      TRBSPED->(DbSkip())
      
   EndDo

   _cTextoFim:="Notas Fiscais enviadas: "+STR(_nEnviados)+Chr(10)
   u_itconout("Termino da Integra��o de Notas Fiscais, Italac <---> TMS Multi-Embarcador "+_cTextoFim)
   If !_lScheduler
      u_itmsg(">> Processamento conclu�do << "+Chr(10)+;
              "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+_cTextoFim,;
              "Fim de processamento",,2)
   EndIf
   
End Sequence

//================================================================================
// Fecha as tabelas tempor�rias
//================================================================================                    
If Select("TRBSPED") > 0
   TRBSPED->( DBCloseArea() )
EndIf

If Select("SPED001") > 0
   SPED001->( DBCloseArea() )
EndIf     

If Select("SPED054") > 0
   SPED054->( DBCloseArea() )
EndIf     

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS140L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/01/2024
===============================================================================================================================
Descri��o---------: Rotina de monitoramento da efetiva��o da compra do vale ped�gio.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140L(_lScheduler)
Local _cQry 
Local _cFilHabil := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x TMS Multi-Embarcador
Local _dDtAtvTms := Ctod(U_ITGETMV( 'IT_DTATIVTMS' , '01/10/2023'))
Local _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
Local _cToken
Local _cNrValeP  := ""     
Local _nValValeP := 0 

Private _aRatFrete := {}
Private _aRatFat   := {}
Private _cMsgTroNf := ""
Private _aCargaEnv := {}

Begin Sequence
   //=======================================================================  
   // Roda rotina para obten��o dos percentuais de rateio.
   //======================================================================= 
   _cQry := " SELECT DAK_I_RECR, DAK.R_E_C_N_O_ DAK_NRREG "
   _cQry += "   FROM "+RetSqlName("DAK")+" DAK "
   _cQry += " WHERE DAK_FILIAL IN " + FormatIn(_cFilHabil,";") // ('01') (filiais do par�metro IT_WEBSTMS)
   _cQry += " AND DAK_DATA >= '"+ Dtos(_dDtAtvTms) + "' " // 20240101' (Data de implanta��o do Multiembarcador
   _cQry += "        AND DAK_I_RECR <> ' ' "
   _cQry += "        AND DAK_I_VPED = ' ' "
   _cQry += "        AND DAK.D_E_L_E_T_ = ' ' "
   _cQry += "        AND EXISTS "
   _cQry += "                (SELECT 'X' " 
   _cQry += "                   FROM "+RetSqlName("ZFK")+" ZFK "
   _cQry += "                  WHERE     ZFK_FILIAL = DAK_FILIAL "
   _cQry += "                        AND ZFK_CARGA = DAK_COD "
   _cQry += "                        AND ZFK_TIPOI = '6' "
   _cQry += "                        AND ZFK_SITUAC = 'P' "
   _cQry += "                        AND ZFK.D_E_L_E_T_ = ' ') "

   _cQry := ChangeQuery(_cQry)                         
   
   If Select("TRBDAK") > 0
      TRBDAK->( DBCloseArea() )
   EndIf

   //DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBDAK" , .T., .F. )
   MPSysOpenQuery( _cQry , "TRBDAK")
   DBSelectArea("TRBDAK")      

   Count To _nTotRegs 

   TRBDAK->(DbGotop())

   Do While ! TRBDAK->(Eof()) 

      DAK->(DbGoTo(TRBDAK->DAK_NRREG))

      // A rotina j� calculou o percentual de rateio do vale ped�gio para esta carga.     
      If ! Empty(DAK->DAK_I_PR1T) 
         TRBDAK->(DbSkip())
         Loop 
      EndIf 

      _cFilial := ""
      _cCarga  := ""
      _cTipo   := ""
      
      If DAK->DAK_I_TRNF == 'C' 
         _cFilial := DAK->DAK_FILIAL 
         _cCarga  := DAK->DAK_COD
      Else 
         _cFilial := DAK->DAK_I_FITN
         _cCarga  := DAK->DAK_I_CATN
      EndIf 

      If Empty(_cCarga)  // N�o � um pedido de vendas do tipo troca nota. 
         _cFilial := DAK->DAK_FILIAL 
         _cCarga  := DAK->DAK_COD    
      EndIf

      _cTipo := DAK->DAK_I_TRNF 

      If _cTipo == "C" .Or. _cTipo == "F"   
         If _lSchedule 
            U_ItConOut("[AOMS140L] - Obtem percentual de rateio da carga e grava ZFQ/ZFR para integrar Carga Tipo Troca Nota Fiscal...")
         
            U_AOMS140I(_lSchedule, _cFilial, _cCarga, DAK->DAK_I_FITN, DAK->DAK_I_CATN, _cTipo, DAK->(Recno()),_nTotRegs)
         Else 
            Processa( {|| U_AOMS140I(_lSchedule, _cFilial, _cCarga, DAK->DAK_I_FITN, DAK->DAK_I_CATN, _cTipo, DAK->(Recno()),_nTotRegs)} , "Integrando Carga Tipo Troca Nota Fiscal..." , "Aguarde!" )
         EndIf  
      EndIf 

      TRBDAK->(DbSkip())
   EndDo 

   //=======================================================================
   // Rotina de monitoramento da efetiva��o da compra do vale ped�gio.
   //=======================================================================
   TRBDAK->(DbGotop())

   //=======================================================================
   // Obtem Link Webservice e diret�rio dos XML.
   //=======================================================================
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
   _cValePXML := U_AOMS140X(_cDirXML+"buscar_detalhes_vale_pedagio_tms.txt") 
   If Empty(_cValePXML)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo de Solicita��o Buscar Detalhes Vale Pedagio.")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo de Solicita��o Buscar Detalhes Vale Pedagio. ","Aten��o",,1)
      EndIf
      Break
   EndIf
   
   //================================================================
   // Configura��es iniciais do Webservice de Integra��o.
   //================================================================
   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.  

   oWsdl:nTimeout := 90          // Timeout de 90 segundos                                                               
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                            
   
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da MULTI-EMBARCADOR.  
   oWsdl:SetOperation( "BuscarDetalhesValePedagio") // Define qual opera��o ser� realizada.

   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================
   // Inicia a leitura dos dados.
   //================================================================
   Do While ! TRBDAK->(Eof())
      
      //==========================================================================
      // N�o integrar registro sem percentual de rateio de frete.
      // Isso pode gerar inconsistencia de dados.
      //==========================================================================
      DAK->(DbGoTo(TRBDAK->DAK_NRREG))

      If Empty(DAK->DAK_I_PR1T) .And. (DAK->DAK_I_TRNF == "C" .Or. DAK->DAK_I_TRNF == "F")   
         TRBDAK->(DbSkip()) 
         Loop
      EndIf 

      //==========================================================================
      // Atribui a vari�vel do Modelo de XML o c�digo da pr� carga da Tabela DAK
      //==========================================================================
      _cProCarga := TRBDAK->DAK_I_RECR 

      _cXML := &(_cValePXML)

      // Envia para o servidor
      _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da MULTI-EMBARCADOR.  

      _cNrValeP  := ""     
      _nValValeP := 0 
      _cInteVP := ""

      If _cOk 
         _cResult := oWsdl:GetSoapResponse() 

         _cError := ""
         _cWarning := ""

         _oXml      := XmlParser(_cResult, "_", @_cError, @_cWarning ) 
         _cNrValeP  := _oXml:_S_ENVELOPE:_S_BODY:_BuscarDetalhesValePedagioResponse:_BuscarDetalhesValePedagioResult:_A_OBJETO:_A_ITENS:_B_VALEPEDAGIO:_b_NumeroValePedagio:TEXT
         _nValValeP := _oXml:_S_ENVELOPE:_S_BODY:_BuscarDetalhesValePedagioResponse:_BuscarDetalhesValePedagioResult:_A_OBJETO:_A_ITENS:_B_VALEPEDAGIO:_b_ValorTotalValePedagio:TEXT
         _cInteVP   := _oXml:_S_ENVELOPE:_S_BODY:_BuscarDetalhesValePedagioResponse:_BuscarDetalhesValePedagioResult:_A_OBJETO:_A_ITENS:_B_VALEPEDAGIO:_b_TipoIntegradora:TEXT
      Else
         _cResult := oWsdl:cError
      EndIf  

      If ! Empty(_cNrValeP)
         _nValVCalc := 0
         If ValType(_nValValeP) == "U" 
            _nValValeP := 0 
         ElseIf ValType(_nValValeP) == "C"  
            _nValValeP := Val(AllTrim(_nValValeP))
         EndIf 

         DAK->(RecLock("DAK",.F.))   
         DAK->DAK_I_VPED  := _cNrValeP  // Numero do Vale Ped�gio
         DAK->DAK_I_VRPE  := _nValValeP // Valor do Vale Ped�gio  DAK_I_VALP
         DAK->DAK_I_RETV  := _cResult   // Retorno da Integra��o Vale Ped�gio

         DAK->DAK_I_INVP  :=  _cInteVP // Integradora do Vale Ped�gio   
         If (DAK->DAK_I_TRNF == "C" .Or. DAK->DAK_I_TRNF == "F")   
            _nValVCalc       := (_nValValeP * DAK->DAK_I_PR1T) / 100 // Valor do rateio do vale ped�gio 
            DAK->DAK_I_VRVP  := _nValVCalc // Valor do rateio do vale ped�gio 
         Else 
            DAK->DAK_I_PR1T  := 100 
            DAK->DAK_I_VRVP  := _nValValeP
         EndIf 

         DAK->(MsUnlock())
         //===================================================================================
         // Replicar a grava��o dos campos DAK_I_VPED na carga de faturamento e carregamento.
         //===================================================================================
         If (DAK->DAK_I_TRNF == "C" .Or. DAK->DAK_I_TRNF == "F")   
            AOMS140TNF(DAK->DAK_I_FITN, DAK->DAK_I_CATN,_cNrValeP, _nValValeP, _nValVCalc , _cInteVP)
         EndIf 
      Else 
         DAK->(RecLock("DAK",.F.))   
         DAK->DAK_I_RETV := _cResult   // Retorno da Integra��o Vale Ped�gio
         DAK->(MsUnlock())
      EndIf 

      TRBDAK->(DbSkip())
   EndDo

End Sequence 

If ! Empty(_cMsgTroNf)
   If ! _lScheduler 
      U_Itmsg(_cMsgTroNf,"Aten��o",,1)
   Else
      U_ItConOut("[AOMS140L] - " + _cMsgTroNf )
   EndIf 
EndIf

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS140W()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/01/2024
===============================================================================================================================
Descri��o---------: Fun��o de chamada em Scheduller da Rotina de monitoramento da efetiva��o da compra do vale ped�gio.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140W()

Begin Sequence

   //=====================================================================
   // Limpa o ambiente, liberando a licen�a e fechando as conex�es
   //=====================================================================
   RpcClearEnv() 
   RpcSetType(2)
      
   //================================================================================
   // Prepara ambiente abrindo tabelas e incializando variaveis.
   //================================================================================   
   RpcSetEnv("01", "01",,,,, {"DAK","DAI","SA2","SA1","ZP1","SC5","SC5","ZFM"})

   cFilAnt := "01"
      
   U_AOMS140L(.T.) 

   RpcClearEnv() 

End Sequence


Return Nil

/*
===============================================================================================================================
Programa----------: AOMS140H()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/01/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o de Pedidos de Vendas com Troca nota fiscal.
===============================================================================================================================
Parametros--------: _lSchedule = .T. = modo agendado.
                                 .F. = modo manual/menu.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140H(_lSchedule)
Local _nTotRegs := 0

Private _aRatFrete := {}
Private _aRatFat   := {}
Private _cMsgTroNf := ""
Private _aCargaEnv := {}

Begin Sequence 

   If ValType(_lSchedule) == "U"
      _lSchedule := .F.
   EndIf 

   //_cQry := " SELECT DECODE (DAK_I_TRNF, 'C', DAK_FILIAL, DAK_I_FITN) FILIAL, " 
   //_cQry += " DECODE (DAK_I_TRNF, 'C', DAK_COD, DAK_I_CATN) CARGA, "            
   _cQry := " SELECT  DAK_FILIAL FILIAL, " 
   _cQry += " DAK_COD CARGA, "            
   _cQry += " DAK_I_TRNF TIPO, "
   _cQry += " DAK_I_FITN, "
   _cQry += " DAK_I_CATN, "
   _cQry += " DAK_I_CARG, "
   _cQry += " DAK.R_E_C_N_O_ DAK_RECNO " 
   _cQry += " FROM "+ RETSQLNAME("DAK") + " DAK "
   _cQry += " WHERE DAK_DATA >= '20230101' "
   _cQry += " AND DAK_I_TRNF IN ('C', 'F') "
   _cQry += " AND DAK_I_CATN <> ' ' "
   _cQry += " AND DAK_I_RECR <> ' ' "
   _cQry += " AND DAK.D_E_L_E_T_ = ' ' "
   _cQry += " AND EXISTS "
   _cQry += " (SELECT 'x' "
   _cQry += " FROM " + RETSQLNAME("DAK") + " DAKF "
   _cQry += " WHERE DAKF.DAK_FILIAL = DAK.DAK_I_FITN "
   _cQry += " AND DAKF.DAK_COD = DAK.DAK_I_CATN "
   _cQry += " AND DAKF.D_E_L_E_T_ = ' ') "
   _cQry += " AND NVL ( "
   _cQry += " (SELECT COUNT (1) "
   _cQry += " FROM " + RETSQLNAME("DAI") + " DAI " 
   _cQry += " WHERE DAI_FILIAL = DAK_FILIAL "
   _cQry += " AND DAI_COD = DAK_COD "
   _cQry += " AND DAI.D_E_L_E_T_ = ' '), "
   _cQry += " 0) = "
   _cQry += " NVL ( "
   _cQry += " (SELECT COUNT (1) "
   _cQry += " FROM " + RETSQLNAME("DAI") + " DAIG, " + RETSQLNAME("SF2") + " SF2 "
   _cQry += " WHERE DAI_FILIAL = DAK_FILIAL "
   _cQry += " AND DAI_COD = DAK_COD "
   _cQry += " AND DAIG.D_E_L_E_T_ = ' ' "
   _cQry += " AND F2_FILIAL = DAIG.DAI_FILIAL "
   _cQry += " AND F2_DOC = DAIG.DAI_NFISCA "
   _cQry += " AND F2_SERIE = DAIG.DAI_SERIE "
   _cQry += " AND F2_I_PRTMS <> ' ' "
   _cQry += " AND SF2.D_E_L_E_T_ = ' '), "
   _cQry += " 0) "

   _cQry += " AND EXISTS "
   _cQry += " (SELECT 'X' "
   _cQry += " FROM " + RETSQLNAME("ZFK") + " ZFK "
   _cQry += " WHERE ZFK_FILIAL = DECODE (DAK_I_TRNF, 'C', DAK_FILIAL, DAK_I_FITN) "
   _cQry += " AND ZFK_CARGA = DECODE (DAK_I_TRNF, 'C', DAK_COD, DAK_I_CATN) "
   _cQry += " AND ZFK_TIPOI = '6' "
   _cQry += " AND ZFK_SITUAC = 'P' "
   _cQry += " AND ZFK.D_E_L_E_T_ = ' ') "

   _cQry += " AND NOT EXISTS "
   _cQry += " (SELECT 'x' "
   _cQry += " FROM " + RETSQLNAME("ZFQ") + " ZFQ "
   _cQry += " WHERE     ZFQ_FILIAL = DAK_FILIAL "
   _cQry += " AND ZFQ_NCARGA = DAK_COD "
   _cQry += " AND ZFQ_SITUAC IN ('F','E') "
   _cQry += " AND ZFQ.D_E_L_E_T_ = ' ') "

   //_cQry += " ORDER BY FILIAL, CARGA, TIPO " 
   _cQry += " ORDER BY TIPO, FILIAL, CARGA "   
   
   If Select("QRYTRNF") > 0
	   QRYTRNF->( DBCloseArea() )
   EndIf

   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYTRNF" , .T. , .F. )
   MPSysOpenQuery( _cQry , "QRYTRNF")
   DBSelectArea("QRYTRNF") 

   Count To _nTotRegs 

   QRYTRNF->(DbGotop())

   Do While ! QRYTRNF->(Eof())

      DAK->(DbGoTo(QRYTRNF->DAK_RECNO))

      // A rotina j� calculou o percentual de rateio do vale ped�gio para esta carga.     
      If ! Empty(DAK->DAK_I_PR1T) 
         QRYTRNF->(DbSkip())
         Loop 
      EndIf 

      _lRet := .T.
      _cMsgTroNf := ""

      If _lSchedule 
         U_ItConOut("[AOMS140] - Integrando Carga Tipo Troca Nota Fiscal...")
         
         U_AOMS140I(_lSchedule, QRYTRNF->FILIAL, QRYTRNF->CARGA, QRYTRNF->DAK_I_FITN, QRYTRNF->DAK_I_CATN, QRYTRNF->TIPO, QRYTRNF->DAK_RECNO,_nTotRegs)
      Else 
         Processa( {|| U_AOMS140I(_lSchedule, QRYTRNF->FILIAL, QRYTRNF->CARGA, QRYTRNF->DAK_I_FITN, QRYTRNF->DAK_I_CATN, QRYTRNF->TIPO, QRYTRNF->DAK_RECNO,_nTotRegs)} , "Integrando Carga Tipo Troca Nota Fiscal..." , "Aguarde!" )
      EndIf 

      QRYTRNF->(DbSkip())
   EndDo

   If Select("QRYTRNF") > 0
	   QRYTRNF->( DBCloseArea() )
   EndIf

   _cQry2 := " SELECT ZFQ.R_E_C_N_O_ ZFQ_RECNO,ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT " 
   _cQry2 += " FROM "+ RETSQLNAME("ZFQ") + " ZFQ "
   _cQry2 += " WHERE ZFQ.D_E_L_E_T_ <> '*' "
   _cQry2 += " AND ZFQ_OPETNF <> ' ' "
   _cQry2 += " AND ZFQ_SITUAC = 'T' "  

   _cQry2 += " ORDER BY ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT "
   
   If Select("QRYZFQ") > 0
	   QRYZFQ->( DBCloseArea() )
   EndIf

   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry2) , "QRYZFQ" , .T. , .F. )
   MPSysOpenQuery( _cQry2 , "QRYZFQ")
   DBSelectArea("QRYZFQ") 

   Count To _nTotRegs 

   QRYZFQ->(DbGotop())

   ProcRegua(_nTotRegs)

   //====================================================================
   // Inicia Transmiss�o dos Dados Troca Nota para o TMS Multiembarcador
   //====================================================================
   U_AOMS140Q()
   
End Sequence 

If ! Empty(_cMsgTroNf)  
   If ! _lSchedule 
      U_Itmsg(_cMsgTroNf,"Aten��o",,1)
   Else
      U_ItConOut("[AOMS140H] - " + _cMsgTroNf )
   EndIf 
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS140I()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/01/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o de Pedidos de Vendas com Troca nota fiscal.
===============================================================================================================================
Parametros--------: _lSchedule = .T. = modo agendado.
                                 .F. = modo manual/menu.
                    _cFilCarga = Filial da Carga
                    _cCodCarga = Codigo da Carga
                    _cFilTNF   = Filial Troca NF
                    _cCarTNF   = Carga Troca NF
                    _cTipCarga = Tipo da Carga
                    _nRecnoDAK = Recno da DAK2
                    _nTotRegs  = Total de Registros a serem processados 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140I(_lSchedule,_cFilCarga,_cCodCarga,_cFilTNF,_cCarTNF,_cTipCarga,_nRecnoDAK,_nTotRegs)
//Local _aEspecie := {}
//Local _nI 
//Local _nSequenPV := 1
Local _lRet := .T. 

Private _aEspecie := {}

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

   DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
   SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
   SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
   DA3->(DbSetOrder(1)) // DA3_FILIAL+DA3_COD  // Veiculo
   DA4->(DbSetOrder(1)) // DA4_FILIAL+DA4_COD  // Motorista
   SA4->(DbSetOrder(1)) // A4_FILIAL+A4_COD  // Transportadoras

   //===============================================================================
   // Posiciona na Carga da Qruery - DAK
   //===============================================================================
   DAK->(DbGoTo(_nRecnoDAK))

   //===============================================================================
   // Obt�m a taxa de rateio.
   //===============================================================================
   _aRespRate := {.T.,0} // Incializa a vari�vel de resposta do rateio.

   _aRespRate := U_AOMS140U() // ZFQ->ZFQ_FILIAL, ZFQ->ZFQ_NCARGA

   _nValFrCar := 0
   _nValFrFat := 0

   //==============================================================================
   // Se a taxa de rateio for zero ou n�o for encotrada. Ignora a carga atual.
   //==============================================================================
   If ! _aRespRate[1] // Erro na gera��o do Rateio do frete da Carga. N�o faz a integra��o da carga.
      _cMsgTroNf += "N�o achou percentual de rateio. Filial/Carga: "+DAK->DAK_FILIAL+"-"+DAK->DAK_COD+". Tipo Carga: "+AllTrim(_cTipCarga)+". "
      _lRet := .F.
      Break 
   EndIf 

   //========================================================================================
   // Faz o rateio de frete para a carga posicioinada.
   //========================================================================================    
   _nValFrCar := DAK->DAK_I_FRET * (_aRespRate[2]/100)
            
   DAK->(RecLock("DAK",.F.))
   DAK->DAK_I_VRFR := Round(_nValFrCar,2)
   DAK->DAK_I_PR1T := _aRespRate[2] // _aRatFat[_nI,3]  // percentual frete carregamento.
   DAK->(MsUnLock())

   //========================================================================================
   // Faz o rateio de frete para a tabela de pedidos (DAI) e grava as tabelas de muro
   // ZFQ e ZFR.
   //========================================================================================
   _cMsgRet := AOMS140DAI(_cTipCarga) 
   If ! Empty(_cMsgRet)
      _cMsgTroNf += _cMsgRet
   EndIf 

   //========================================================================================
   // Chama a rotina para Replicar rateio de frete para a carga vinculada.
   //========================================================================================
   //                     Filial Carga   , Carga Vinculada,Frete Total    , Frete Rateado  ,Percentual Frete
   _cMsgRet := AOMS140FRE(DAK->DAK_I_FITN, DAK->DAK_I_CATN,DAK->DAK_I_FRET, DAK->DAK_I_VRFR,DAK->DAK_I_PR1T,_cTipCarga )
   If ! Empty(_cMsgRet)
      _cMsgTroNf += _cMsgRet
   EndIf 

End Sequence  

Return _lRet 

/*
===============================================================================================================================
Programa----------: AOMS140Q
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
User Function AOMS140Q(oproc)
Local _cDirXML := ""
Local _cLink   := ""
Local _cCabXML := ""
Local _cItemXML := ""
Local _cDetA_1_XML := "", _cDetA_2_XML := "",_cDetA_3_XML := ""
Local _cDetC_XML := ""
Local _cRodXML := "" 
Local _cDadosItens
Local _cEmpWebService := ""
Local _aOrd := SaveOrd({"ZFQ","ZFM","ZFR","SC9","SC5"})
Local _aUF := {}
Local _cXML 
Local _cSitEnv
//Local _aRet := {.F.,"",""}

Local _cResult := ""
Local _aRecnoItem, _nI, _nJ 

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

   _cDetA_1_XML := U_AOMS140X(_cDirXML+"det_a_1_pedido_troca_nf_tms.TXT") // "Det_A_1_Pedido_TMS.TXT")
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
       
   _cDetC_XML := U_AOMS140X(_cDirXML+"det_c_pedido_troca_nf_tms.TXT")
   
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
   
   _aPedFat := {}
   _aRatFat := {}

   ZFQ->(DbSetOrder(3)) // ZFQ_FILIAL+ZFQ_PEDIDO+ZFQ_SITUAC+DTOS(ZFQ_DATA)  

   QRYZFQ->(DbGoTop())                                                                   
   Do While ! QRYZFQ->(Eof())

      ZFQ->(DbGoto(QRYZFQ->ZFQ_RECNO))
      DAK->(DbSetOrder(1)) //DAK->(DbSetOrder(1)) // DAK->(DbSetOrder(7))
      
      If ! DAK->(MsSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_NCARGA)) // ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_CARTMS
         QRYZFQ->(DbSkip())
         Loop 
      EndIf 

      //========================================================================
      // O array _aCargaEnv � utilizado para controlar se todos envios da carga 
      // foram transmitidos com sucesso, ou se houve alguma rejei��o.
      // Se n�o houver rejei��o, as integra��es de finaliza��o da carga e 
      // mudan�a da carga para a proxima fase s�o acionadas.
      //========================================================================
      _nJ := Ascan(_aCargaEnv,{|x| x[1] == ZFQ->ZFQ_FILIAL .And. x[2] = ZFQ->ZFQ_NCARGA})

      If _nJ == 0
         Aadd(_aCargaEnv, {ZFQ->ZFQ_FILIAL,ZFQ->ZFQ_NCARGA, .T.})
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
            _cSitEnv := "T"
            ZFR->(DbSetOrder(5))  // Alguma rotina est� alterando a situa��o da ZFQ, de "T" para "N".
            If ! ZFR->(DbSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO+_cSitEnv)) 
               _cSitEnv := "N"
               ZFR->(DbSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_PEDIDO+_cSitEnv)) 
            EndIf 

            _aRecnoItem := {}
            _cDadosItens := ""
            Do While ! ZFR->(Eof()) .And. ZFR->(ZFR_FILIAL+ZFR_NUMPED+ZFR_SITUAC) = ZFQ->(ZFQ_FILIAL+ZFQ_PEDIDO)+_cSitEnv  // Ajustar para L
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
                  _cSituacao := "T" // "N"
                  _cResposta := "Dados Inv�lidos - " + _cCodMsg + "-" + AllTrim(_cTextoMsg) // + "-" + AllTrim(_cRespTxt) // "Dados Inv�lidos - Algum dado da requisi��o n�o � v�lido, ou est� faltando"

               ElseIf _cCodMsg == "400" // Falha Interna Web Service
                  _cSituacao := "T" // "N"
                  _cResposta := "Falha Interna Web Service - " + _cCodMsg + "-" +AllTrim(_cTextoMsg) //+ "-"  + AllTrim(_cRespTxt) // "Falha Interna Web Service - Erro interno no processamento. Caso seja persistente, contatar o suporte da MultiSoftware"

               ElseIf _cCodMsg == "500" // Duplicidade na Requisi��o
                  _cSituacao := "T" // "N"
                  _cResposta := "Duplicidade na Requisi��o - " + _cCodMsg + "-" + AllTrim(_cTextoMsg)// + "-"  + AllTrim(_cRespTxt)  // "Duplicidade na Requisi��o - A requisi��o j� foi feita, ou o registro j� foi inserido anteriormente"
                     
               Else
                  _cSituacao := "T" // "N"
                  _cResposta := AllTrim(_cTextoMsg) + "-" + AllTrim(StrTran(_cResult,Chr(10)," "))
                  _cResposta := Upper(_cResposta)
               EndIf 

               If ! Empty(_cTextoMsg)
                  _cResposta := _cResposta // + " " + _cTextoMsg
               EndIf 

               //==================================================
               // Atualiza o Status da Transmiss�o.
               //==================================================
               If _cCodMsg <> "200" // Pelo menos um pedido da carga foi rejeitado.
                  _nJ := Ascan(_aCargaEnv,{|x| x[1] == ZFQ->ZFQ_FILIAL .And. x[2] = ZFQ->ZFQ_NCARGA})
                  If _nJ > 0
                     _aCargaEnv[_nJ,3] := .F. 
                  Else 
                     Aadd(_aCargaEnv, {ZFQ->ZFQ_FILIAL,ZFQ->ZFQ_NCARGA, .F.})
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
            	            
               _lfalha := .F.  //Verifica se tem falha de processamento no loop a seguir
            
               For _nI := 1 To Len(_aRecnoItem)
                   ZFR->(DbGoTo(_aRecnoItem[_nI]))
               
                   ZFR->(RecLock("ZFR",.F.))
                   ZFR->ZFR_SITUAC  := _cSituacao // iif(_cok, "P", "N")
                   ZFR->ZFR_DATAAL  := Date()
                   ZFR->ZFR_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFQ,dizendo que deu certo ou n�o.
                   ZFR->(MsUnlock()) 
               Next       
               
               If ! Empty(_cProtIntC) //Empty(_cProtIntP) //.And. AllTrim(_cProtIntP) <> "0" // .And. Val(AllTrim(_cProtIntP)) <> 0 
                  DAK->(RecLock("DAK",.F.))
                  DAK->DAK_I_PTMS := AllTrim(_cProtIntC) 
                  DAK->(MsUnLock())
               EndIf 
                           
               Aadd(_aresult,{ZFQ->ZFQ_PEDIDO,ZFQ->ZFQ_CNPJEM,ZFQ->ZFQ_RETORN}) // adicona em um array para fazer um item list, exibir os resultados.
               Sleep(100) //Espera para n�o travar a comunica��o com o webservice da MULTI-EMBARCADOR
            EndIf

         EndIf 
         
      End Transaction

      //==================================================
      // Verifica se � o ultimo pedido de vendas da carga,
      // se todos os pedidos de vendas da carga foram 
      // enviados com sucesso e inicia a itegra��o de
      // finaliza��o da carga e mudan�a da carga para a
      // pr�xima fase.
      //==================================================
      If _cCodMsg == "200" .And. ZFQ->ZFQ_ULTREG == "S" 
         _nJ := Ascan(_aCargaEnv,{|x| x[1] == ZFQ->ZFQ_FILIAL .And. x[2] = ZFQ->ZFQ_NCARGA})
         If _nJ > 0
            If _aCargaEnv[_nJ,3] // Ultimo pedido de vendas da Carga e todas as transmiss�es foram realizadas com sucesso. 
               //================================================================================
               // Carga Troca Nota integrada com sucesso. 
               // Inclui um registro na tabela ZFQ para rodar a rotina de integra��o de 
               // Fechamento de Carga.
               //================================================================================
               For _nI := 1 To ZFQ->(FCount())
                   &("M->"+ZFQ->(FieldName(_nI))) :=  &("ZFQ->"+ZFQ->(FieldName(_nI)))
               Next
               
               ZFQ->(RecLock("ZFQ",.T.))
               For _nI := 1 To ZFQ->(FCount())
                   &("ZFQ->"+ZFQ->(FieldName(_nI))) :=  &("M->"+ZFQ->(FieldName(_nI)))
               Next
               ZFQ->ZFQ_SITUAC := "F"
               ZFQ->(MsUnlock())
            EndIf 
            
         EndIf
      EndIf  

      QRYZFQ->(DbSkip())
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
===============================================================================================================================
Programa----------: AOMS140U
Autor-------------: Julio de Paula Paz
Data da Criacao---:08/02/2024
===============================================================================================================================
Descri��o---------: Rotina de rateio de frete para a integra��o de cargas troca nota com o sistema TMS da Multi-Embarcador / 
                    Multsoftware.
===============================================================================================================================
Parametros--------: _cFilCarga = Filial da Carga
                    _cNrCarga  = Numero da Carga
===============================================================================================================================
Retorno-----------: _lRet = .T. = Percentual localizado  
                            .F. = Percentual n�o localizado
===============================================================================================================================
*/  
User Function AOMS140U()
Local _aRet := {}
Local _nPercRat := 0 

Begin Sequence
  
   ZRF->(DbSetOrder(1))  // ZRF_FILIAL+ZRF_UFCAR+ZRF_MUNCAR+ZRF_UFDEST+ZRF_MESODE+ZRF_MICRDE+ZRF_MUNDES // COMPARTILHADA
   ZEL->(DbSetOrder(1))  // ZEL_FILIAL+ZEL_CODIGO         // COMPARTILHADA
   CC2->(DbSetOrder(1))  // CC2_FILIAL+CC2_EST+CC2_CODMUN // COMPARTILHADA // CC2 utilizando como chave os campos DAK_I_UFDE e DAK_I_CIDE

   If ! CC2->(MsSeek(xFilial("CC2")+DAK->DAK_I_UFDE+DAK->DAK_I_CIDE))  // J� est� posicionada na DAK.
      _aRet := {.F.,0}
      Break
   EndIf

   If ! ZEL->(MsSeek(xFilial("ZEL")+DAK->DAK_I_LEMB))
      _aRet := {.F.,0}
      Break
   EndIf
                    //FILIAL         + UF CARR                  + MUN CAR                   + ESTADO D        + MESO_REGIAO D             + MICRO_REGIAL D           + MUNICIPIO D
ZRF->(DbSetOrder(1))//ZRF_FILIAL     + ZRF_UFCAR                + ZRF_MUNCAR                + ZRF_UFDEST      + ZRF_MESODE                + ZRF_MICRDE               + ZRF_MICRDE
//ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + ZEL->ZEL_CODMUN           + DAK->DAK_I_UFDE + U_ITKEY(" ","ZRF_MESODE") + U_ITKEY(" ","ZRF_MICRO") + DAK->DAK_I_CIDE))
IF     ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + ZEL->ZEL_CODMUN           + DAK->DAK_I_UFDE + CC2->CC2_I_MESO          + CC2->CC2_I_MICR      + DAK->DAK_I_CIDE))
       _nPercRat :=  ZRF->ZRF_PERC1T          
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + ZEL->ZEL_CODMUN           + DAK->DAK_I_UFDE + CC2->CC2_I_MESO           + CC2->CC2_I_MICR          +U_ITKEY(" ","ZRF_MUNDES")))
       _nPercRat :=  ZRF->ZRF_PERC1T          
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + ZEL->ZEL_CODMUN           + DAK->DAK_I_UFDE + CC2->CC2_I_MESO           + U_ITKEY(" ","ZRF_MICRO") +U_ITKEY(" ","ZRF_MUNDES")))
         _nPercRat :=  ZRF->ZRF_PERC1T          
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + ZEL->ZEL_CODMUN           + DAK->DAK_I_UFDE + U_ITKEY(" ","ZRF_MESODE") + U_ITKEY(" ","ZRF_MICRO") +U_ITKEY(" ","ZRF_MUNDES")))
         _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + CC2->CC2_I_MESO            + CC2->CC2_I_MICR         + DAK->DAK_I_CIDE))
       _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + CC2->CC2_I_MESO           + CC2->CC2_I_MICR          +U_ITKEY(" ","ZRF_MUNDES")))
       _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + CC2->CC2_I_MESO           + U_ITKEY(" ","ZRF_MICRO") +U_ITKEY(" ","ZRF_MUNDES")))
         _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + ZEL->ZEL_UF              + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + U_ITKEY(" ","ZRF_MESODE") + U_ITKEY(" ","ZRF_MICRO") +U_ITKEY(" ","ZRF_MUNDES")))
         _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + U_ITKEY(" ","ZRF_UFCAR") + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + CC2->CC2_I_MESO            + CC2->CC2_I_MICR          + DAK->DAK_I_CIDE))
       _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + U_ITKEY(" ","ZRF_UFCAR") + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + CC2->CC2_I_MESO           + CC2->CC2_I_MICR          +U_ITKEY(" ","ZRF_MUNDES")))
       _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + U_ITKEY(" ","ZRF_UFCAR") + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + CC2->CC2_I_MESO           + U_ITKEY(" ","ZRF_MICRO") +U_ITKEY(" ","ZRF_MUNDES")))
       _nPercRat :=  ZRF->ZRF_PERC1T
ELSEIf ZRF->(MsSeek(xFilial("ZRF")   + U_ITKEY(" ","ZRF_UFCAR") + U_ITKEY(" ","ZRF_MUNCAR") + DAK->DAK_I_UFDE + U_ITKEY(" ","ZRF_MESODE") + U_ITKEY(" ","ZRF_MICRO") +U_ITKEY(" ","ZRF_MUNDES")))
       _nPercRat :=  ZRF->ZRF_PERC1T
ENDIF
        
End Sequence

If _nPercRat == 0
   _aRet := {.F.,0}
Else 
   _aRet := {.T.,_nPercRat}
EndIf 

If Select("QRYZRF") > 0
	QRYZRF->( DBCloseArea() )
EndIf

Return _aRet

/*
===============================================================================================================================
Programa----------: AOMS140F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/02/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o Webservice de fechamento da carga.
                    Considera a carga j� est� posicionada no registro da DAK.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140F(_lScheduler)
Local _aRet := {.F.,"","","",""}

Begin Sequence 

   If ValType(_lScheduler) == "U"
      _lScheduler := .F.
   EndIf 

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   _cDirXML := ""
   _cLink   := ""

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
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
      _aRet := {.F.,"","[AOMS140] - Empresa WebService para envio dos dados n�o localizada.",""}
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lScheduler
         U_Itconout("[AOMS140] - Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
      Else
         U_Itmsg("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o",,1)
      EndIf
      _aRet := {.F.,"","[AOMS140] - Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".",""}
      Break                                     
   EndIf
      
   _cDirXML := Alltrim(_cDirXML)
   If Right(_cDirXML,1) <> "\"
      _cDirXML := _cDirXML + "\"
   EndIf

   //================================================================================
   // L� os arquivos modelo XML e os transforma em String.
   //================================================================================
   _cFechaCar := U_AOMS140X(_cDirXML+"FecharCarga_troca_nf_tms.txt") 
   If Empty(_cFechaCar)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo de fechamento de carga.")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo de fechamento de carga. ","Aten��o",,1)
      EndIf
      _aRet := {.F.,"","[AOMS140] - Erro na leitura do arquivo XML modelo de fechamento de carga.",""}

      Break
   EndIf

   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.

   oWsdl:nTimeout := 90          // Timeout de 90 segundos                                                               
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                            
   
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da MULTI-EMBARCADOR.  
   oWsdl:SetOperation( "FecharCarga") // Define qual opera��o ser� realizada.
   
   _cXML := &(_cFechaCar)
 		    
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
      //_cCodMsg  := _oXml:_S_ENVELOPE:_S_BODY:_ADICIONARCARGARESPONSE:_ADICIONARCARGARESULT:_A_CODIGOMENSAGEM:TEXT
      _cCodMsg  := _oXml:_S_ENVELOPE:_S_BODY:_FECHARCARGARESPONSE:_FECHARCARGARESULT:_A_CODIGOMENSAGEM:TEXT
   EndIf

   If "MENSAGEM" $ _cTextoPesq
      _cTextoMsg := _oXml:_S_ENVELOPE:_S_BODY:_FECHARCARGARESPONSE:_FECHARCARGARESULT:_A_MENSAGEM:TEXT // _A_CODIGOMENSAGEM:TEXT
   EndIf

   _cResposta := ""
   _cSituacao := "P" // "Importado Com Sucesso"
   _cCodRast  := ""
   _cRespTxt  := StrTran(_cResult,Chr(13)+Chr(10),"")
   _cRespTxt  := StrTran(_cResult,Chr(10),"")

   If _cCodMsg == "200" // Integrado com Sucesso 
      _cResposta := "Integrado com Sucesso - Nenhum problema encontrado, a requisi��o foi processada e retornou dados." + "-" + AllTrim(_cTextoMsg)
      _aRet := {.T.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "300" // Dados Inv�lidos                     
      _cSituacao := "T" 
      _cResposta := "Dados Inv�lidos - " + _cCodMsg + "-" + AllTrim(_cTextoMsg) // + "-" + AllTrim(_cRespTxt) // "Dados Inv�lidos - Algum dado da requisi��o n�o � v�lido, ou est� faltando"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "400" // Falha Interna Web Service
      _cSituacao := "T" 
      _cResposta := "Falha Interna Web Service - " + _cCodMsg + "-" +AllTrim(_cTextoMsg) //+ "-"  + AllTrim(_cRespTxt) // "Falha Interna Web Service - Erro interno no processamento. Caso seja persistente, contatar o suporte da MultiSoftware"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "500" // Duplicidade na Requisi��o
      _cSituacao := "T" 
      _cResposta := "Duplicidade na Requisi��o - " + _cCodMsg + "-" + AllTrim(_cTextoMsg)// + "-"  + AllTrim(_cRespTxt)  // "Duplicidade na Requisi��o - A requisi��o j� foi feita, ou o registro j� foi inserido anteriormente"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   Else
      _cSituacao := "T" 
      _cResposta := AllTrim(_cTextoMsg) + "-" + AllTrim(StrTran(_cResult,Chr(10)," "))
      _cResposta := Upper(_cResposta)
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   EndIf 

End Sequence 

Return _aRet

/*
===============================================================================================================================
Programa----------: AOMS140D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/02/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o Webservice de mudan�a da carga para a pr�xima fase.
                    Considera a carga j� est� posicionada no registro da DAK.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140D(_lScheduler)
Local _aRet := {.F.,"","","",""}

Begin Sequence 

   If ValType(_lScheduler) == "U"
      _lScheduler := .F.
   EndIf 

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   _cDirXML := ""
   _cLink   := ""

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
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
   _cFechaCar := U_AOMS140X(_cDirXML+"LiberarEmissaoSemNFe_troca_nf_tms.txt") 
   If Empty(_cFechaCar)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo de Liberar Emiss�o Sem NFE.")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo Liberar Emiss�o Sem NFE. ","Aten��o",,1)
      EndIf
      Break
   EndIf

   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.

   oWsdl:nTimeout := 90          // Timeout de 90 segundos                                                               
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                            
   
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da MULTI-EMBARCADOR.  
   oWsdl:SetOperation( "LiberarEmissaoSemNFe") // Define qual opera��o ser� realizada.
   
   _cXML := &(_cFechaCar)
 		    
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
      //_cCodMsg  := _oXml:_S_ENVELOPE:_S_BODY:_FECHARCARGARESPONSE:_FECHARCARGARESULT:_A_CODIGOMENSAGEM:TEXT
      _cCodMsg  := _oXml:_S_ENVELOPE:_S_BODY:_LIBERAREMISSAOSEMNFERESPONSE:_LIBERAREMISSAOSEMNFERESULT:_A_CODIGOMENSAGEM:TEXT
   EndIf

   If "MENSAGEM" $ _cTextoPesq
      _cTextoMsg := _oXml:_S_ENVELOPE:_S_BODY:_LIBERAREMISSAOSEMNFERESPONSE:_LIBERAREMISSAOSEMNFERESULT:_A_MENSAGEM:TEXT // _A_CODIGOMENSAGEM:TEXT
   EndIf

   _cResposta := ""
   _cSituacao := "P" // "Importado Com Sucesso"
   _cCodRast  := ""
   _cRespTxt  := StrTran(_cResult,Chr(13)+Chr(10),"")
   _cRespTxt  := StrTran(_cResult,Chr(10),"")

   If _cCodMsg == "200" // Integrado com Sucesso 
      _cResposta := "Integrado com Sucesso - Nenhum problema encontrado, a requisi��o foi processada e retornou dados." + "-" + AllTrim(_cTextoMsg)
      _aRet := {.T.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "300" // Dados Inv�lidos                     
      _cSituacao := "T" 
      _cResposta := "Dados Inv�lidos - " + _cCodMsg + "-" + AllTrim(_cTextoMsg) // + "-" + AllTrim(_cRespTxt) // "Dados Inv�lidos - Algum dado da requisi��o n�o � v�lido, ou est� faltando"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "400" // Falha Interna Web Service
      _cSituacao := "T" 
      _cResposta := "Falha Interna Web Service - " + _cCodMsg + "-" +AllTrim(_cTextoMsg) //+ "-"  + AllTrim(_cRespTxt) // "Falha Interna Web Service - Erro interno no processamento. Caso seja persistente, contatar o suporte da MultiSoftware"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "500" // Duplicidade na Requisi��o
      _cSituacao := "T" 
      _cResposta := "Duplicidade na Requisi��o - " + _cCodMsg + "-" + AllTrim(_cTextoMsg)// + "-"  + AllTrim(_cRespTxt)  // "Duplicidade na Requisi��o - A requisi��o j� foi feita, ou o registro j� foi inserido anteriormente"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   Else
      _cSituacao := "T" 
      _cResposta := AllTrim(_cTextoMsg) + "-" + AllTrim(StrTran(_cResult,Chr(10)," "))
      _cResposta := Upper(_cResposta)
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   EndIf 

End Sequence 

Return _aRet

/*
===============================================================================================================================
Programa----------: AOMS140J
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/02/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o Webservice de Carga Troca Nota Fiscal, que roda a rotina de solicita��o de fechamento
                    de carga.
===============================================================================================================================
Parametros--------: Nenhum.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Percentual localizado  
                            .F. = Percentual n�o localizado
===============================================================================================================================
*/  
User Function AOMS140J()  
Local _aRet := {.F.,"","","",""}
Local _cQry := ""
Local _nTotRegs, _nI

Begin Sequence 

   If Select("QRYFECH") > 0
	   QRYFECH->( DBCloseArea() )
   EndIf

   _cQry := " SELECT ZFQ.R_E_C_N_O_ ZFQ_RECNO,ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT " 
   _cQry += " FROM "+ RETSQLNAME("ZFQ") + " ZFQ "
   _cQry += " WHERE ZFQ.D_E_L_E_T_ <> '*' "
   _cQry += " AND ZFQ_OPETNF <> ' ' "
   _cQry += " AND ZFQ_SITUAC = 'F' "  
   _cQry += " ORDER BY ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT "
   
   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYFECH" , .T. , .F. )
   MPSysOpenQuery( _cQry , "QRYFECH")
   DBSelectArea("QRYFECH") 

   Count To _nTotRegs 

   QRYFECH->(DbGotop())

   ProcRegua(_nTotRegs)
   Do While ! QRYFECH->(Eof())

      ZFQ->(DbGoto(QRYFECH->ZFQ_RECNO))
      DAK->(DbSetOrder(1)) 
      
      If ! DAK->(MsSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_NCARGA)) 
         QRYFECH->(DbSkip())
         Loop 
      EndIf 
      
      //==============================================================================
      // _aRet :=  {1=True/False, // sucesso na integra��o / falha na integra��o
      //            2=Codigo da Mensagem de Retorno,
      //            3=C�digo e Mensagem de Retorno, 
      //            4=Xml de Retorno, 
      //            5=Xml de Envio}
      //==============================================================================

      _aRet := U_AOMS140F()  // Chama a rotina de integra��o Webservice de finaliza��o da carga.
      If _aRet[1]  // Solicita��o de Fechamento de Carga realizado com sucesso. 
         ZFQ->(RecLock("ZFQ",.F.))
         ZFQ->ZFQ_SITUAC := "P" 
         ZFQ->ZFQ_DATAAL := Date()
         ZFQ->ZFQ_RETORN := _aRet[2] + "-" + _aRet[3]
         ZFQ->ZFQ_XML    := _aRet[5] //_aRet[4]  
         ZFQ->ZFQ_DATAP  := DATE()
         ZFQ->ZFQ_HORAP  := TIME()
         ZFQ->(MsUnlock())

         //================================================================================
         // Solicita��o de Fechamento de Carga integrada com sucesso. 
         // Inclui um registro na tabela ZFQ para rodar a rotina de integra��o de 
         // Liberar Emissao Sem NFe.
         //================================================================================
         For _nI := 1 To ZFQ->(FCount())
             &("M->"+ZFQ->(FieldName(_nI))) :=  &("ZFQ->"+ZFQ->(FieldName(_nI)))
         Next
               
         ZFQ->(RecLock("ZFQ",.T.))
         For _nI := 1 To ZFQ->(FCount())
             &("ZFQ->"+ZFQ->(FieldName(_nI))) :=  &("M->"+ZFQ->(FieldName(_nI)))
         Next

         ZFQ->ZFQ_DATAAL := Date()
         ZFQ->ZFQ_RETORN := _aRet[2] + "-" + _aRet[3]
         ZFQ->ZFQ_XML    := _aRet[5] 
         ZFQ->ZFQ_DATAP  := DATE()
         ZFQ->ZFQ_HORAP  := TIME()
         ZFQ->ZFQ_SITUAC := "E"
         ZFQ->(MsUnlock())

      Else 
         ZFQ->(RecLock("ZFQ",.F.))
         ZFQ->ZFQ_DATAAL := Date()
         ZFQ->ZFQ_RETORN := _aRet[2] + "-" + _aRet[3]
         ZFQ->ZFQ_XML    := _aRet[5] //_aRet[4] 
         ZFQ->ZFQ_DATAP  := DATE()
         ZFQ->ZFQ_HORAP  := TIME()
         ZFQ->(MsUnlock())
      EndIf 

      QRYFECH->(DbSkip())
   EndDo 

End Sequence 

If Select("QRYFECH") > 0
   QRYFECH->( DBCloseArea() )
EndIf

Return _aRet 

/*
===============================================================================================================================
Programa----------: AOMS140B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/02/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o Webservice de Carga Troca Nota Fiscal, que roda a rotina de solicita��o de mudan�a 
                    da carga para pr�xima fase (LiberarEmissaoSemNFe).
===============================================================================================================================
Parametros--------: Nenhum.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Percentual localizado  
                            .F. = Percentual n�o localizado
===============================================================================================================================
*/  
User Function AOMS140B()
Local _aRet := {.F.,"","","",""}
Local _cQry := ""
Local _nTotRegs 

Begin Sequence 

   If Select("QRYPROF") > 0
	   QRYPROF->( DBCloseArea() )
   EndIf

   _cQry := " SELECT ZFQ.R_E_C_N_O_ ZFQ_RECNO,ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT " 
   _cQry += " FROM "+ RETSQLNAME("ZFQ") + " ZFQ "
   _cQry += " WHERE ZFQ.D_E_L_E_T_ <> '*' "
   _cQry += " AND ZFQ_OPETNF <> ' ' "
   _cQry += " AND ZFQ_SITUAC = 'E' "  
   _cQry += " ORDER BY ZFQ_FILIAL, ZFQ_NCARGA, ZFQ_SEQENT "
   
   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYPROF" , .T. , .F. )
   MPSysOpenQuery( _cQry , "QRYPROF")
   DBSelectArea("QRYPROF") 

   Count To _nTotRegs 

   QRYPROF->(DbGotop())

   ProcRegua(_nTotRegs)
   Do While ! QRYPROF->(Eof())

      ZFQ->(DbGoto(QRYPROF->ZFQ_RECNO))
      DAK->(DbSetOrder(1)) 
      
      If ! DAK->(MsSeek(ZFQ->ZFQ_FILIAL+ZFQ->ZFQ_NCARGA)) 
         QRYFECH->(DbSkip())
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

      If _aRet[1]  // Solicita��o de Fechamento de Carga realizado com sucesso.
         ZFQ->(RecLock("ZFQ",.F.))
         ZFQ->ZFQ_SITUAC := "P"
         ZFQ->ZFQ_DATAAL := Date()
         ZFQ->ZFQ_RETORN := _aRet[2] + "-" + _aRet[3]
         ZFQ->ZFQ_XML    := _aRet[5] //_aRet[4] 
         ZFQ->ZFQ_DATAP  := DATE()
         ZFQ->ZFQ_HORAP  := TIME()
         ZFQ->(MsUnlock())

      Else 
         ZFQ->(RecLock("ZFQ",.F.))
         ZFQ->ZFQ_DATAAL := Date()
         ZFQ->ZFQ_RETORN := _aRet[2] + "-" + _aRet[3]
         ZFQ->ZFQ_XML    := _aRet[5] //_aRet[4] 
         ZFQ->ZFQ_DATAP  := DATE()
         ZFQ->ZFQ_HORAP  := TIME()
         ZFQ->(MsUnlock())
      EndIf 

      QRYPROF->(DbSkip())
   EndDo 

End Sequence 

If Select("QRYPROF") > 0
   QRYPROF->( DBCloseArea() )
EndIf

Return _aRet 

/*
===============================================================================================================================
Fun��o------------: AOMS140O
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/03/2024
===============================================================================================================================
Descri��o---------: Rotina de integra��o WebService de envio da situa��o do pedido de vendas para o TMS-MultiEmbarcador.
                    Chamado da antiga fun��o de envio para o RDC, a fun��o U_ENVSITPV().
                    Considera estar posicionado no pedido de vendas. SC5.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140O()
Local _cDirXML := ""
Local _cLink   := ""
Local _cJSonEnv := ""
Local _cSitPed := ""
Local _cDescSitPV
Local _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
Local _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")
Local _cDadosEnv, _lStatus
Local _aSitEst 
Local _cSitEst 
Local _cDescSitE 
Local _aDescSitP := {}
Local _nI 

Begin Sequence
   
   If Empty(SC5->C5_I_CDTMS) // Este pedido de vendas n�o existe no TMS-MultiEmbarcador.
      Break 
   EndIf 

	If Select("ZFM") == 0 // Se a tabela ZFM n�o estiver aberta, abre a tabela ZFM.
		ChkFile("ZFM")
	EndIf
   Aadd(_aDescSitP, {"01","Aberto"}) 
   Aadd(_aDescSitP, {"02","Pedido encerrado"}) 
   Aadd(_aDescSitP, {"03","Pedido liberado"}) 
   Aadd(_aDescSitP, {"04","Bloqueio de estoque"}) 
   Aadd(_aDescSitP, {"05","Bloqueio comercial"}) 
   Aadd(_aDescSitP, {"06","Bloqueio bonifica��o"}) 
   Aadd(_aDescSitP, {"07","Bonifica��o rejeitada"}) 
   Aadd(_aDescSitP, {"08","Bloqueio pre�o"}) 
   Aadd(_aDescSitP, {"09","Pre�o rejeitado"}) 
   Aadd(_aDescSitP, {"10","Bloqueio de cr�dito"}) 
   Aadd(_aDescSitP, {"11","Cr�dito rejeitado"}) 
   Aadd(_aDescSitP, {"12","Troca NF Aberto (CAR)"}) 
   Aadd(_aDescSitP, {"13","Troca NF Liberado (CAR)"}) 
   Aadd(_aDescSitP, {"14","Troca NF Aberto (FAT)"}) 
   Aadd(_aDescSitP, {"15","Troca NF Liberado (FAT)"}) 
   
	_cSitPed    := U_STPEDIDO()  // Obtem a situa��o do Pedido de Vendas
   _nI := Ascan(_aDescSitP,{|x| x[1] == _cSitPed})

   If _nI == 0
      _cDescSitPV := U_STPEDIDO(1) // Obtem a Descri��o da situa��o do Pedido de Vendas
   Else 
      _cDescSitPV := _aDescSitP[_nI,2]
   EndIf 

   // Atualiza a situa��o no Pedido de Vendas.
   SC5->(RecLock("SC5",.F.))
	SC5->C5_I_STATU := _cSitPed // U_STPEDIDO() //Fun��o de an�lise do pedido de vendas no xfunoms
	SC5->(MsUnlock())

   _aSitEst   := U_AOMS152J()
   _cSitEst   := _aSitEst[1]
   _cDescSitE := _aSitEst[2]

	//================================================================================
	// L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
	//================================================================================
	ZFM->(DbSetOrder(1))
	If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
		_cDirXML := ZFM->ZFM_LOCXML
		_cLink   := AllTrim(ZFM->ZFM_LINK05)
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
	_cJSonEnv := U_AOMS140X(_cDirXML+"Alterar_Situacao_Comercial_Pedido_TMS.json") 

	If Empty(_cJSonEnv)
		Break
	EndIf

   
   _nTimOut   := 120
   _aHeadOut  := {}
   _cJSonRet  := Nil   
   _oRetJSon  := Nil 

   Aadd(_aHeadOut,"Content-Type: application/json") 
   Aadd(_aHeadOut,"Authorization: Bearer Token") 
   Aadd(_aHeadOut,"Token: " + AllTrim(_cToken)) 

   _cDadosEnv := &(_cJSonEnv)

   _cRetHttp := AllTrim( HttpPost( _cLink , '' , _cDadosEnv , _nTimOut , _aHeadOut , @_cJSonRet ) ) 
   _oRetJSon := Nil 

   If Empty(_cJSonRet) .Or. ! "200 OK" $ Upper(_cJSonRet)
      U_ItConOut("Falha na integra��o. N�o foi poss�vel alterar situa��o do pedido de vendas no TMS. Protocolo do Pedido: " + SC5->C5_I_CDTMS)
      _cResposta := "Falha na integra��o. N�o foi poss�vel alterar situa��o do pedido de vendas no TMS. Protocolo do Pedido: " + SC5->C5_I_CDTMS
      _cSituacao := "N"
   EndIf 

   If ! Empty(_cRetHttp)
      _oJSonSitP := JsonObject():new()
          
      _cRet := _oJSonSitP:FromJson(_cRetHttp)

      If _cRet <> NIL
         U_ItConOut("N�o foi poss�vel ler o JSon retornado de altrera��o de situa��o do pedido de vendas no TMS. Protocolo do Pedido: " + SC5->C5_I_CDTMS)
         _cResposta := "N�o foi poss�vel ler o JSon retornado de altrera��o de situa��o do pedido de vendas no TMS. Protocolo do Pedido: " + SC5->C5_I_CDTMS
         _cSituacao := "N"
		EndIf 
   EndIf

   _cSituacao := "P"
   If _cRet == NIL
      _aNonesPV := _oJSonSitP:GetNames() 
      _lStatus := _oJSonSitP["status"]
      _cResposta := "Codigo: " + StrZero(_oJSonSitP["codigoMensagem"],3) + " - Mensagem: " + _oJSonSitP["mensagem"]
      If ! _lStatus  
		   _cSituacao := "N"
	   EndIf
   Else 
      _cSituacao := "N"
      _cResposta := "N�o foi poss�vel ler o JSon retornado de altrera��o de situa��o do pedido de vendas no TMS. Protocolo do Pedido: " + SC5->C5_I_CDTMS
   EndIf 

	// grava resultado da integra��o na tabela de muro.
	ZGA->(RecLock("ZGA",.T.))
	ZGA->ZGA_DTENT   := SC5->C5_I_DTENT
	ZGA->ZGA_SITUAC  := _cSituacao
	ZGA->ZGA_NUM     := SC5->C5_NUM
	ZGA->ZGA_USUARI  := __CUSERID
	ZGA->ZGA_DATAAL  := Date()
	ZGA->ZGA_HORASA  := TIME()
	ZGA->ZGA_STATUS  := _cSitPed
	ZGA->ZGA_RETORN  := _cResposta 
	ZGA->ZGA_XML     := _cDadosEnv 
	ZGA->(MsUnlock())

End Sequence

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS140TNF()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/08/2024
===============================================================================================================================
Descri��o---------: Fun��o para Replicar a grava��o dos campos DAK_I_VPED e outros campos na carga 
                    de faturamento ou de carregamento.
                    - Se estiver na carga de Faturamento, replica para a carga de carregamento.
                    - Se estiver na carga de Carregamento, replica para a carga de faturamento.
===============================================================================================================================
Parametros--------: _cFilCarga = Filial da carga vinculada.
                    _cCarga    = C�digo da carga vinculada.
                    _cNrValP   = Numero do Vale Ped�gio.
                    _nValValeP = Valor do Vale Ped�gio.
                    _nValVCalc = Valor calculado do Vale Ped�gio.
                    _cIntValeP = Integradora Vale Ped�gio.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function AOMS140TNF(_cFilCarga,_cCarga, _cNrValP,_nValValeP,_nValVCalc,_cIntValeP)
Local _cQry 
Local _nRegAtu := DAK->(Recno())

Begin Sequence 

   If Select("QRYDAK") > 0
	   QRYDAK->( DBCloseArea() )
   EndIf

   _cQry := " SELECT DAK.R_E_C_N_O_ RECNO " 
   _cQry += " FROM "+ RETSQLNAME("DAK") + " DAK "
   _cQry += " WHERE DAK.D_E_L_E_T_ <> '*' "
   _cQry += " AND DAK_FILIAL = '" + _cFilCarga + "' "
   _cQry += " AND DAK_COD = '" + _cCarga    + "' "
   
   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYDAK" , .T. , .F. )
   MPSysOpenQuery( _cQry , "QRYDAK")
   DBSelectArea("QRYDAK") 

   If QRYDAK->(Eof()) .Or. QRYDAK->(Bof())
      Break
   EndIf 

   DAK->(DbGoTo(QRYDAK->RECNO))

   DAK->(RecLock("DAK",.F.))   
   DAK->DAK_I_VPED   := _cNrValP  // Numero do Vale Ped�gio
   //DAK->DAK_I_VRPE  := _nValValeP // Valor do Vale Ped�gio  DAK_I_VALP
   DAK->DAK_I_INVP   := _cIntValeP
   DAK->DAK_I_VRVP   := (_nValValeP - _nValVCalc) // Valor do rateio do vale ped�gio 
   DAK->(MsUnlock())

End Sequence 

If Select("QRYDAK") > 0
   QRYDAK->( DBCloseArea() )
EndIf

DAK->(DbGoTo(_nRegAtu))

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS140FRE()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 29/08/2024
===============================================================================================================================
Descri��o---------: Fun��o para Replicar a grava��o dos campos rateio de frete.
                    - Se estiver na carga de Faturamento, replica para a carga de carregamento.
                    - Se estiver na carga de Carregamento, replica para a carga de faturamento.
===============================================================================================================================
Parametros--------: _cFilCarga = Filial da carga vinculada.
                    _cCarga    = C�digo da carga vinculada.
                    _cNrValP   = Numero do Vale Ped�gio.
                    _nValValeP = Valor do Vale Ped�gio.
                    _nValVCalc = Valor calculado do Vale Ped�gio.
                    _cIntValeP = Integradora Vale Ped�gio.
                    _cTipCarga = Tipo da Carga
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
//                     Filial Carga   , Carga Vinculada,Frete Total    , Frete Rateado  ,Percentual Frete
//   _cMsgRet := AOMS140FRE(DAK->DAK_I_FITN, DAK->DAK_I_CATN,DAK->DAK_I_FRET, DAK->DAK_I_VRFR,DAK->DAK_I_PR1T )
Static Function AOMS140FRE(_cFilCarga,_cCarga, _nValTFret, _nValFRateo,_nPercFret,_cTipCarga)
Local _cQry 
Local _nRegAtu := DAK->(Recno())

Begin Sequence 

   If Select("QRYFRE") > 0
	   QRYFRE->( DBCloseArea() )
   EndIf

   _cQry := " SELECT DAK.R_E_C_N_O_ RECNO " 
   _cQry += " FROM "+ RETSQLNAME("DAK") + " DAK "
   _cQry += " WHERE DAK.D_E_L_E_T_ <> '*' "
   _cQry += " AND DAK_FILIAL = '" + _cFilCarga + "' "
   _cQry += " AND DAK_COD = '" + _cCarga    + "' "
   
   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYFRE" , .T. , .F. )
   MPSysOpenQuery( _cQry , "QRYFRE")
   DBSelectArea("QRYFRE")

   If QRYFRE->(Eof()) .Or. QRYFRE->(Bof())
      Break
   EndIf 

   DAK->(DbGoTo(QRYFRE->RECNO))

   DAK->(RecLock("DAK",.F.))   
   //DAK->DAK_I_FRET := _nValTFret // N�o replicar este campo.
   DAK->DAK_I_VRFR := (_nValTFret - _nValFRateo)
   DAK->DAK_I_PR1T := 100 - _nPercFret
   DAK->(MsUnlock())
   
   //========================================================================================
   // Faz o rateio de frete para a tabela de pedidos (DAI) e grava as tabelas de muro
   // ZFQ e ZFR.
   //========================================================================================
   If _cTipCarga == "C"
      _cRet := AOMS140DAI("F") 
   Else 
      _cRet := AOMS140DAI("C") 
   EndIf 
  
End Sequence 

If Select("QRYFRE") > 0
   QRYFRE->( DBCloseArea() )
EndIf

DAK->(DbGoTo(_nRegAtu))

Return _cRet 

/*
===============================================================================================================================
Programa----------: AOMS140DAI()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 29/08/2024
===============================================================================================================================
Descri��o---------: Faz o Rateio de frete para os pedidos de vendas na tabela DAI e Grava as tabelas de muro ZFQ e ZFR,
                    Para a carga posicionada.
===============================================================================================================================
Parametros--------: _cTipCarga ==  Tipo da carga C=Carregamento / F=Faturamento.
===============================================================================================================================
Retorno-----------: _lRet = .T./.F. 
===============================================================================================================================
*/  
Static Function AOMS140DAI(_cTipCarga)
Local _cRet := ""
Local _nPesoTot  := 0
Local _nPesoTAux := 0
Local _nUltimRec := 0
Local _nTotPedid := 0  
Local _nValFrete := 0
Local _nSequenPV := 0

Begin Sequence 
   //========================================================================================
   // Calcula os Pesos dos Pedidos de Vendas Desconsiderendo os pesos e produtos dos Pallets
   //========================================================================================
	_nPesoTot := U_CalPesCarg( DAK->DAK_COD , 1 )
	
	If _nPesoTot == 0 
		_nPesoTAux := DAK->DAK_PESO
	EndIf 

   //===============================================================================
   // Verifica quantos Pedidos de Vendas existem na DAI e Grava o Ultimo Registro.
   //===============================================================================
   _nUltimRec := 0
   _nTotPedid := 0  
   _nValFrete := 0

   DAI->(MsSeek(DAK->DAK_FILIAL+DAK->DAK_COD))
   Do While ! DAI->(Eof()) .And. DAI->DAI_FILIAL+DAI->DAI_COD == DAK->DAK_FILIAL+DAK->DAK_COD
      SC5->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))

      If SC5->C5_I_PEDPA == "S"
         DAI->(DbSkip())
         Loop 
      EndIf 

      _nUltimRec := DAI->(Recno())
      _nTotPedid += 1  

      _nFretDAI:=0
		
	   If _nPesoTot > 0    
	      If U_CalPesCarg(DAI->DAI_PEDIDO,2) > 0
				//_nFretDAI	:=	((DAI->DAI_I_FRET /	_nPesoTot)	*	DAI->DAI_PESO)	   
            _nFretDAI	:=	((DAK->DAK_I_VRFR /	_nPesoTot)	*	DAI->DAI_PESO)	   
               
			EndIf
		Else
			//_nFretDAI	:=	( ( DAI->DAI_I_FRET / _nPesoTAux ) * DAI->DAI_PESO )
         _nFretDAI	:=	( ( DAK->DAK_I_VRFR/ _nPesoTAux ) * DAI->DAI_PESO )
     
		EndIf

	   If _nFretDAI > 0
	      DAI->( RecLock( "DAI" , .F. ) )
		   DAI->DAI_I_FRET := _nFretDAI
		   DAI->( MsUnlock() )
		EndIf

      _nValFrete += Round(_nFretDAI,2)

      DAI->(DbSkip())
   EndDo 

   If _nTotPedid == 0 // N�o localizou registros na DAI.
      //_cMsgTroNf += "N�o achou pedidos de na DAI. Filial/Carga: "+DAK->DAK_FILIAL+"-"+DAK->DAK_COD+". Tipo Carga: "+AllTrim(_cTipCarga)+". "
      _cRet := "N�o achou pedidos de na DAI. Filial/Carga: "+DAK->DAK_FILIAL+"-"+DAK->DAK_COD+". Tipo Carga: "+AllTrim(_cTipCarga)+". "
      Break 
   EndIf 

   //===============================================================================================================
   // Calcula o valor do Frete para cada pedido de vendas e acrescenta no ultimo registro a diferen�a dos valores.
   // Diferen�a maior que zero, somamos na ultima parcel. Diferen�a menor que zero, subtraimos na ultima parcela.
   //===============================================================================================================
   //_nValFrete := Round(DAK->DAK_I_VRFR / _nTotPedid,2) 
   _nDiferenc := DAK->DAK_I_VRFR - Round(_nValFrete,2)  // (_nValFrete * _nTotPedid)
   _nValFrUlt := _nValFrete  + _nDiferenc  

   //==================================================
   // Gera a ZFQ para cada pedido de vendas.
   //==================================================
   _nSequenPV := 1

   DAI->(MsSeek(DAK->DAK_FILIAL+DAK->DAK_COD))
   Do While ! DAI->(Eof()) .And. DAI->DAI_FILIAL+DAI->DAI_COD == DAK->DAK_FILIAL+DAK->DAK_COD
      SC5->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))
      SF2->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_NFISCA+DAI->DAI_SERIE+DAI->DAI_CLIENT+DAI->DAI_LOJA ))
      DA3->(MsSeek(xFilial("DA3")+DAK->DAK_CAMINH))
      DA4->(MsSeek(xFilial("DA4")+DAK->DAK_MOTORI))
      //SA4->(MsSeek(xFilial("SA4")+DAK->DAK_TRANSP))
      
      //====================================================
      // Grava ZFQ e ZRF
      //====================================================
      If _lSchedule
         If _cTipCarga == "C"
            U_AOMS084P("T",,"SCHEDULLER","CAR")
         Else 
            U_AOMS084P("T",,"SCHEDULLER","FAT")
         EndIf 
      Else 
         If _cTipCarga == "C"
            U_AOMS084P("T",,"BROWSER","CAR")
         Else 
            U_AOMS084P("T",,"BROWSER","FAT")
         EndIf 
      EndIf 

      //=======================================================
      // Grava as demais inform��es da ZFQ para tipo Troca NF
      //=======================================================
      ZFQ->(RecLock("ZFQ",.F.))
      
      ZFQ->ZFQ_SITPED := U_STPEDIDO()  // Status do Pedido/Situa��o do Pedido, rotina no xfunoms.  
      //ZFQ->ZFQ_DSCSIT := U_STPEDIDO(1) // Descricao Situacao Pedido

      ZFQ->ZFQ_CNPJTP := Posicione('SA2',1,xFilial('SA2')+DA4->DA4_FORNEC+DA4->DA4_LOJA,'A2_CGC') // SA4->A4_CGC      //C	14	0	CNPJ Tranport	CNPJ Transportadora Emitente
      
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
      
      If _cTipCarga == "C"
         ZFQ->ZFQ_OPETNF := "TNFC"	                // Operac.TNF	Opera��o Troca Nota Fiscal
         ZFQ->ZFQ_TPOPER := "TNFC"	
         _cNrCarTMS := DAK->DAK_I_CARG 
      Else 
         ZFQ->ZFQ_OPETNF := "TNFF"
         ZFQ->ZFQ_TPOPER := "TNFF"

         _nRegDAK := DAK->(Recno())
         _cPesquisa := DAK->DAK_I_FITN+DAK->DAK_I_CATN
         _cNrCarTMS := Posicione("DAK",1,_cPesquisa,"DAK_I_CARG") 

         DAK->(DbGoto(_nRegDAK))
      EndIf 
      
      //ZFQ->ZFQ_NCARGA := _cNrCarTMS
      ZFQ->ZFQ_NCARGA := DAK->DAK_COD 
      ZFQ->ZFQ_CARTMS := _cNrCarTMS
      ZFQ->ZFQ_CNPJFP := "12815827000132" // Manter os CNPJs fixos. Solicita��o do Vanderlei.
      ZFQ->ZFQ_CNPJRP := "01257995000133" // Manter os CNPJS fixos. Solicita��o do Vanderlei.
      ZFQ->ZFQ_NRCVPE := DAK->DAK_I_VPED
      ZFQ->ZFQ_VALVPE := DAK->DAK_I_VRPE
      
      //==============================================
      // Grava o valor do frete rateado.
      //==============================================
      If _nUltimRec == DAI->(Recno()) // Ultimo registro da DAI / Ultimo registro da ZFQ 
         ZFQ->ZFQ_VALFRE := DAI->DAI_I_FRET + _nDiferenc // _nValFrete
      Else
         ZFQ->ZFQ_VALFRE := DAI->DAI_I_FRET 
      EndIf 
      
      ZFQ->ZFQ_SITUAC := "T" // Este tipo de situa��o indica integra��o exclusiva para cargas do tipo troca nota fiscal.

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
         ZFR->ZFR_SITUAC := "T"
         ZFR->(MsUnlock())

         ZFR->(DbSkip())
      EndDo  

      DAI->(DbSkip())
   EndDo 
   
   ZFQ->(RecLock("ZFQ",.F.))
   ZFQ->ZFQ_ULTREG := "S"
   ZFQ->(MsUnLock())

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Fun��o-------------: AOMS140M
Aut2or-------------: Igor Melga�o
Data da Criacao----: 26/12/2024
===============================================================================================================================
Descri��o----------: Processa os registros integrados para altera��o do numero de carga
===============================================================================================================================
Parametros---------: _lScheduller
===============================================================================================================================
Retorno------------:   
===============================================================================================================================
*/  
User Function AOMS140M(_lScheduller As Logical) 
Local _cTitulo As Character
Local _aCabecalho As Array
Local _aResult As Array
Local _lStatus As Logical
Local _cResposta As Character
Local _cTime As Character

Private _aResp As Array

Begin Sequence 

   _cTitulo := ""
   _aCabecalho := {}
   _aResult := {}
   _aResp := {}
   _lStatus := .F.
   _cTime := Time()

   If Empty(AllTrim(DAK->DAK_I_RECR))
      _cResposta := "Registro n�o integrado com o TMS para altera��o de carga."
   Else
      If _lScheduller
         _aResp := U_AOMS140K(_lScheduller)
      Else 
         FWMSGRUN( , {|_lScheduller| _aResp := U_AOMS140K(_lScheduller)}, "Aguarde! Inicio: "+ _cTime , 'Alterando carga no TMS...' )     
      EndIf 
      _lStatus   := _aResp[1]
      _cResposta := _aResp[2]
   EndIf
   
   Aadd(_aResult,{!_lStatus,DAK->DAK_COD,DAK->DAK_SEQCAR, _cResposta}) 

   If ! _lScheduller

      Aadd(_aCabecalho,"Processado?" ) 
      Aadd(_aCabecalho,"C�digo Carga" ) 
      Aadd(_aCabecalho,"Seq. da Carga") 
      Aadd(_aCabecalho,"RETORNO") 
             
      _cTitulo := "Resultados da integra��o"
      
      If Len(_aResult) > 0
   		U_ITListBox( _cTitulo , _aCabecalho , _aResult   , .F.      , 4      ,  ,          ,         ,         ,     ,        ,          ,       ,         ,          ,           , {|C,L|U_AOMS083U(C,L)}        , .F.   ,         ,     )
      EndIf 

   EndIf 

End Sequence 

Return

/*
===============================================================================================================================
Fun��o-------------: AOMS140K
Aut2or-------------: Igor Melga�o
Data da Criacao----: 26/12/2024
===============================================================================================================================
Descri��o----------: Altera��o do numero de carga
===============================================================================================================================
Parametros---------: _lScheduller
===============================================================================================================================
Retorno------------: {_lStatus,cResult}   
===============================================================================================================================
*/  
User Function AOMS140K(_lScheduller As Logical) As Array          
Local oRest As Object   
Local nStatus As Numeric
Local cError As Character
Local cResult As Character
Local cRegistro As Character
Local _aOrd As Array
Local _cResposta As Character
Local _cSituacao As Character
Local _aHeader As Array
Local _cUrl As Character
Local _cParms As Character
Local _cToken As Character
Local _cCodEmpWS As Character

Default _lScheduller := .F.

oRest      := Nil
nStatus    := 0
cError     := ""
cResult    := ""
cRegistro  := ""
_aOrd      := SaveOrd({"ZFJ","ZFM"})
_cResposta := ""
_cSituacao := ""
_aHeader   := {}
_cUrl      := ""
_cParms    := "/Cargas/AlterarNumeroCarga"
_cToken    := Alltrim(U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4"))
_cCodEmpWS := ""

Begin Sequence
   
   _cCodEmpWS := U_ITGETMV( 'IT_EMPTMSM' , "000005")

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cUrl := AllTrim(ZFM->ZFM_LINK07)
   Else         
      If _lExibeTela
         u_itmsg("Empresa WebService para envio dos dados n�o localizada.","Aten��o",,1)
      EndIf
      
      Break   
   EndIf     

   //================================================================================
   // Verifica se h� itens selecionados e l� o c�digo da empresa de WebService.
   //================================================================================                    
   If !_lScheduller
      ProcRegua(8)     
      IncProc("Verificando itens selecionados...")      
   EndIf
         
   Begin Transaction
         
      _cBodyJson := '{'
      _cBodyJson += '"protocoloCarga": "'+EncodeUTF8(AllTrim(DAK->DAK_I_RECR))+'",'
      _cBodyJson += '"numeroCarga": "'+EncodeUTF8(AllTrim(DAK->DAK_COD))+'" '
      _cBodyJson += '}'

      _aHeader :={}

      oRest := FWRest():New(_cUrl)
      oRest:SetPath(_cParms)

      //Cabe�alho de requisi��o
      Aadd(_aHeader , "Content-Type: application/json")
      aAdd(_aHeader , "Authorization: Bearer Token" ) 
      Aadd(_aHeader , "Token: "+_cToken)
      

      oRest:SetPostParams(_cBodyJson)
      oRest:SetChkStatus(.F.)

      If oRest:Post(_aHeader)
         cError := ""
         nStatus := HTTPGetStatus(@cError)

         If nStatus >= 200 .And. nStatus <= 299
            If Empty(oRest:getResult())
               cResult := "Falha de comunica��o no retorno da requisi��o com o com o sistema TMS Emabarcador!" + CRLF + "Status " + Alltrim(Str(nStatus))
               _lStatus := .F.
               If !_lScheduller
                  U_ItMsg(cResult,"Aten��o",,1)
               EndIf
            Else
               cResult := oRest:getResult()                

               oJson := JsonObject():new()

               cRegistro := oJson:fromJson(cResult)

               If oJson:GetJsonText("status")  == "false" //"N�o foi encontrado uma carga para o protocolo informado"
                  _lStatus := .F.
               Else
                  _lStatus := .T.
               EndIf
               
               FreeObj(oJson)   
            EndIf
         Else

            cResult := oRest:getResult() 

            oJson := JsonObject():new()

            cRegistro := oJson:fromJson(cResult)

            cRegistro := oJson:GetJsonText("erros") 

            If cRegistro <> "null"
               FWJsonDeserialize(cRegistro,@oErro)
               cMsg := oErro[1]:MENSAGEM
            Else
               cMsg := cError
            EndIf

            cResult := "Falha na integra��o com o sistema TMS Emabarcador!" + CRLF + "Erro:" + cError  + CRLF + "Mensagem" + CRLF + cMsg // LimpaString(oErro[1]:MENSAGEM),"")

            FreeObj(oJson) 

            _cResposta := cResult
            _lStatus := .F.

         EndIf
      Else
         cResult := oRest:getResult() 

         If ValType(cResult) == "U"
            cResult := ""
         EndIf
         
         cResult := "Falha de comunica��o com o sistema TMS Emabarcador!" + CRLF + oRest:getLastError() + CRLF + cResult
         
         _cResposta := cResult
         _cSituacao := "N"
         _lStatus := .F.

      EndIf

   End Transaction
   
   FreeObj(oJson) 

End Sequence

RestOrd(_aOrd)

Return {_lStatus,cResult}   

/*
===============================================================================================================================
Programa----------: AOMS140P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/05/2025
===============================================================================================================================
Descri��o---------: Rotina de integra��o Webservice de solicita��o de emiss�o de notas fiscais.
                    Considera a carga j� est� posicionada no registro da DAK.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS140P(_lScheduler)
Local _aRet := {.F.,"","","",""}

Begin Sequence 

   If ValType(_lScheduler) == "U"
      _lScheduler := .F.
   EndIf 

   //=====================================================================
   // Obtem o token de acesso ao sistema multi embarcador.
   //=====================================================================
   _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

   //================================================================================
   // Retorna Codigo Empresa WebService TMS-MULTI EMBARCADOR.
   //================================================================================                    
   _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   _cDirXML := ""
   _cLink   := ""

   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK02)
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
   _cFechaCar := U_AOMS140X(_cDirXML+"solicitarnotasfiscais.txt") 
   If Empty(_cFechaCar)
      If _lScheduler
         U_Itconout("[AOMS140] - Erro na leitura do arquivo XML modelo de Solicitar Emiss�o de NFE.")
      Else
         U_Itmsg("Erro na leitura do arquivo XML modelo Solicitar Emiss�o de NFE. ","Aten��o",,1)
      EndIf
      Break
   EndIf

   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.

   oWsdl:nTimeout := 90          // Timeout de 90 segundos                                                               
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                            
   
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da MULTI-EMBARCADOR.  
   oWsdl:SetOperation( "SolicitarNotasFiscais") // Define qual opera��o ser� realizada.
   
   _cXML := &(_cFechaCar)
 		    
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
      _cCodMsg  := _oXml:_S_ENVELOPE:_S_BODY:_SOLICITARNOTASFISCAISRESPONSE:_SOLICITARNOTASFISCAISRESULT:_A_CODIGOMENSAGEM:TEXT
   EndIf

   If "MENSAGEM" $ _cTextoPesq
      _cTextoMsg := _oXml:_S_ENVELOPE:_S_BODY:_SOLICITARNOTASFISCAISRESPONSE:_SOLICITARNOTASFISCAISRESULT:_A_MENSAGEM:TEXT
   EndIf

   _cResposta := ""
   _cSituacao := "P" // "Importado Com Sucesso"
   _cCodRast  := ""
   _cRespTxt  := StrTran(_cResult,Chr(13)+Chr(10),"")
   _cRespTxt  := StrTran(_cResult,Chr(10),"")

   If _cCodMsg == "200" // Integrado com Sucesso 
      _cResposta := "Integrado com Sucesso - Nenhum problema encontrado, a requisi��o foi processada e retornou dados." + "-" + AllTrim(_cTextoMsg)
      _aRet := {.T.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "300" // Dados Inv�lidos                     
      _cSituacao := "T" 
      _cResposta := "Dados Inv�lidos - " + _cCodMsg + "-" + AllTrim(_cTextoMsg) // + "-" + AllTrim(_cRespTxt) // "Dados Inv�lidos - Algum dado da requisi��o n�o � v�lido, ou est� faltando"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "400" // Falha Interna Web Service
      _cSituacao := "T" 
      _cResposta := "Falha Interna Web Service - " + _cCodMsg + "-" +AllTrim(_cTextoMsg) //+ "-"  + AllTrim(_cRespTxt) // "Falha Interna Web Service - Erro interno no processamento. Caso seja persistente, contatar o suporte da MultiSoftware"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   ElseIf _cCodMsg == "500" // Duplicidade na Requisi��o
      _cSituacao := "T" 
      _cResposta := "Duplicidade na Requisi��o - " + _cCodMsg + "-" + AllTrim(_cTextoMsg)// + "-"  + AllTrim(_cRespTxt)  // "Duplicidade na Requisi��o - A requisi��o j� foi feita, ou o registro j� foi inserido anteriormente"
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   Else
      _cSituacao := "T" 
      _cResposta := AllTrim(_cTextoMsg) + "-" + AllTrim(StrTran(_cResult,Chr(10)," "))
      _cResposta := Upper(_cResposta)
      _aRet := {.F.,_cCodMsg,_cResposta,_cRespTxt,_cXML}
   EndIf 

End Sequence 

Return _aRet


