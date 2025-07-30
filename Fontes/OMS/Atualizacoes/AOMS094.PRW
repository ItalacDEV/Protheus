/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich    | 09/10/2018 | Chamado 25790. Ajuste para não apresentar mensagens no AOMS109. 
Josué Danich    | 28/12/2018 | Chamado 27509. Ajuste de mensagem de retorno com código de viagem do pedido.
Lucas Borges  	 | 16/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
Alex Wallauer   | 14/10/2022 | Chamado 41508. Colocado FWIsInCallStack("U_MOMS066") Para não mostrar o resultado do RDC
==========================================================================================================================================================================
 Analista       - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
==========================================================================================================================================================================
Jerry           - Julio Paz    - 06/03/25 - 20/03/25 - 49880   - Aumentar o Time Out da rotina webservice de solicitação de retorno de pedidos de vendas do sistema RDC.
Jerry           - Igor Melgaço - 23/05/25 - 06/06/25 - 39201   - Ajuste na rotina de retorno de pedidos de vendas do sistema RDC.
Vanderlei Alves - Alex Wallauer- 09/06/25 - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP").
==========================================================================================================================================================================

*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "APWEBSRV.CH"
#Include 'Protheus.ch'  
#INCLUDE "TBICONN.CH"  

/*
===============================================================================================================================
Programa----------: AOMS094
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/03/2017
===============================================================================================================================
Descrição---------: Rotina de consulta da integração de dados Cancelamento de Pedidos.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS094()
Local _aCores := {}
Private aRotina := {}
Private cCadastro 

//Log de utilização
u_itlogacs()

Begin Sequence
   cCadastro := "Integração dos Dados Cancelamento de Pedido de Vendas Via Webservice: Italac <---> RDC"
   Aadd(aRotina,{"Pesquisar"  ,"AxPesqui"   ,0 ,1})
   Aadd(aRotina,{"Visualizar" ,"AxVisual"   ,0 ,2})
   Aadd(aRotina,{"Legenda"    ,"U_AOMS094L" ,0 ,3})
   
   Aadd(_aCores,{"ZFL_SITUAC == 'N'" ,"BR_VERDE" })
   Aadd(_aCores,{"ZFL_SITUAC == 'P'" ,"BR_VERMELHO" })
   Aadd(_aCores,{"ZFL_SITUAC == 'R'" ,"BR_AMARELO" })

   DbSelectArea("ZFL")
   ZFL->(DbSetOrder(1)) 
   ZFL->(DbGoTop())
   MBrowse(6,1,22,75,"ZFL", , , , , , _aCores)
   
End Sequence

Return Nil    

/*
===============================================================================================================================
Programa----------: AOMS094L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/03/2017
===============================================================================================================================
Descrição---------: Rotina de Exibição da Legenda do MBrowse.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS094L       
Local _aLegenda := {}

Begin Sequence
   Aadd(_aLegenda,{"BR_VERDE"    ,"Não Processado" })
   Aadd(_aLegenda,{"BR_AMARELO"  ,"Rejeitada" })
   Aadd(_aLegenda,{"BR_VERMELHO" ,"Processado" })

   BrwLegenda(cCadastro, "Legenda", _aLegenda)

End Sequence

Return Nil   

/*
===============================================================================================================================
Função------------: AOMS094E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/11/2016
===============================================================================================================================
Descrição---------: Gera os dados XML de cancelamento com base no Pedido de Venda selecionado e integra via webservice.
===============================================================================================================================
Parametros--------: oproc - objeto de barra de progresso
                    _lExibeTela - .T. = Exibe as mensagens na tela. / .F. = Exibe as mensagens no console.
===============================================================================================================================
Retorno-----------: True = integração bem sucedida / False = falha na integração.
===============================================================================================================================
*/  
User Function AOMS094E(oproc,_lExibeTela)             
Local _cDirXML := ""
Local _cLink   := ""
Local _cCabXML := ""
Local _cDetXML := ""
Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
Local _cRodXML := "" 
Local _aOrd := SaveOrd({"ZZM","SA2","ZFM"})
Local _cXML 
Local _cResult := ""
Local _cResposta, _cSituacao
Local _lRet := .F.
Local _nTentativas := U_ITGETMV( 'IT_TENT410' , 3 )
Local _nI := 0

Default oproc := nil, _lExibeTela := .T.


//Se estiver no webservice não executa
If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B")
	Return nil
Endif

Begin Sequence

   //================================================================================
   // Lê o diretório dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   IF valtype(oproc) = "O"

      	oproc:cCaption := ("Identificando diretório dos XML...")
   		ProcessMessages()
 
   ENDIF

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cCodEmpWS))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK01)
   Else         
      If _lExibeTela
         u_itmsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      //Else
         //U_ITCONOUT("[AOMS094] Empresa WebService para envio dos dados não localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If _lExibeTela
         u_itmsg("Diretório dos arquivos XML modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      //Else
         //U_ITCONOUT("[AOMS094E] Diretório dos arquivos XML modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
      EndIf
      
      Break                                     
   EndIf
      
   _cDirXML := Alltrim(_cDirXML)
   If Right(_cDirXML,1) <> "\"
      _cDirXML := _cDirXML + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo XML e os transforma em String.
   //================================================================================
   IF valtype(oproc) = "O"

      	oproc:cCaption := ("Lendo arquivo XML Modelo de Cabeçalho...")
   		ProcessMessages()
 
   ENDIF
    
   _cCabXML := U_AOMS084X(_cDirXML+"Cab_CancelaPedido.txt") 
   
   If Empty(_cCabXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo do cabeçalho de envio Pedido de Vendas. ","Atenção",,1)
      //Else
         //U_ITCONOUT("[AOMS094E] Erro na leitura do arquivo XML modelo do cabeçalho de envio Pedido de Vendas. ")
      EndIf
      Break
   EndIf

   IF valtype(oproc) = "O"

      	oproc:cCaption := ("Lendo arquivo XML Modelo de Detalhe A...")
   		ProcessMessages()
 
   ENDIF
   
   _cDetXML := U_AOMS084X(_cDirXML+"DET_CancelaPedido.txt")
   
   If Empty(_cDetXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo do detalhe A de envio Pedido de Vendas.","Atenção",,1)
      //Else
         //U_ITCONOUT("[AOMS094E] Erro na leitura do arquivo XML modelo do detalhe A de envio Pedido de Vendas.")
      EndIf
      Break
   EndIf            

   IF valtype(oproc) = "O"

      	oproc:cCaption := ("Lendo arquivo XML Modelo de Rodapé...")
   		ProcessMessages()
 
   ENDIF
   
   _cRodXML := U_AOMS084X(_cDirXML+"Rodape_CancelaPedido.txt")
   
   If Empty(_cRodXML)
      If _lExibeTela
         u_itmsg("Erro na leitura do arquivo XML modelo do rodapé de envio Pedido de Vendas.","Atenção",,1)
      //Else
         //U_ITCONOUT("[AOMS094E] Erro na leitura do arquivo XML modelo do rodapé de envio Pedido de Vendas.")
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
   IF valtype(oproc) = "O"

      	oproc:cCaption := ("Montando dados de envio...")
   		ProcessMessages()
 
   ENDIF
   
   oWSDL := tWSDLManager():New() // Cria o objeto da WSDL.
   oWsdl:nTimeout := 120         // Timeout de 120 segundos. Tempo padrão (Default) da classe: tWSDLManager() = 120 segundos. 
   oWsdl:lSSLInsecure := .T.     //   Acessa com certificado anônimo                                                                    
   
   //oWsdl:ParseURL( "http://10.3.0.201/wsitf18/Service.svc?wsdl") // Manda para dentro do Objeto qual é o link do WSDL de integração Webservice. Este link é o da RDC.  
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual é o link do WSDL de integração Webservice. Este link é o da RDC.  
   oWsdl:SetOperation( "CancelaPedido") // Define qual operação será realizada.
   
   _aresult := {}
   
   Begin Transaction     
      //-----------------------------------------------------------------------------------------
      // Realiza a integração dos pedidos de vendas (Envio de XML) via WebService.
      //-----------------------------------------------------------------------------------------
      //Monta XML
      _cXML := _cCabXML + &(_cDetXML) + _cRodXML  // Monta o XML de envio.
      
      For _nI := 1 To _nTentativas         

         // Envia para o servidor
         _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
               
         If _cOk 
            _cResult := oWsdl:GetParsedResponse() // Pega o resultado de envio já no formato em string.
         Else
            _cResult := oWsdl:cError
         EndIf   
               
         _cResposta := AllTrim(StrTran(_cResult,Chr(10)," "))
              
         
         _cResposta := Upper(_cResposta)
               
         // "Importado Com Sucesso"
         _cSituacao := "R"
         _lRet := .F.
         
         If ("IMPORTADO COM SUCESSO" $ _cResposta) 
            _cSituacao := "P"
            _lRet := .T.
         ElseIf ("PEDIDO NAO ENCONTRADO" $ _cResposta) .Or. ("PEDIDO NÃ£O ENCONTRADO" $ _cResposta)  
            _cSituacao := "P"
            _lRet := .T.
         EndIf
          	
         //Ajusta resposta de pedido em carga para incluir o número da viagem
         If " VINCULADO NA CARGA" $ _cResposta
            _cErro := _cResposta
         	DAI->(Dbsetorder(4))
         	If DAI->(dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
         
         		DAK->(Dbsetorder(1))
         		If DAK->(dbseek(DAI->DAI_FILIAL+DAI->DAI_COD))
         		
         			_cresposta := SUBSTR(ALLTRIM(_cresposta),1,LEN(ALLTRIM(_cresposta))-1) + " VIAGEM: "+ ALLTRIM(DAK->DAK_I_CARG) + " )"
         			
         		Endif
         	Endif
         
         Endif

         If ("IMPORTADO COM SUCESSO" $ _cResposta) .OR. ("PEDIDO NAO ENCONTRADO" $ _cResposta) .OR. ("VINCULADO NA CARGA" $ _cResposta)
            Exit
         EndIf
         
      Next       		    
      //================================================================================
      // Grava na tabela de muro um log da integração.
      //================================================================================                       
      ZFL->(RecLock("ZFL",.T.))
      ZFL->ZFL_FILIAL  := SC5->C5_FILIAL
      ZFL->ZFL_HORA    := Time() // Grava a hora de inclusão do registro na tabela de muro.
      ZFL->ZFL_DATA    := Date()
      ZFL->ZFL_CGC     := ZZM->ZZM_CGC
      ZFL->ZFL_NUM     := SC5->C5_NUM
      ZFL->ZFL_COD     := SA2->A2_COD
      ZFL->ZFL_LOJA    := SA2->A2_LOJA
      ZFL->ZFL_NOME     := SA2->A2_NOME
      ZFL->ZFL_EMISSA  := Date()
      ZFL->ZFL_SITUAC  := _cSituacao // iif(_cok, "P", "N")
      ZFL->ZFL_USUARI  := __CUSERID
      ZFL->ZFL_DATAAL  := Date()
      ZFL->ZFL_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integração na tabela ZFL,dizendo que deu certo ou não.
      ZFL->ZFL_XML     := _cXML
      ZFL->(MsUnlock()) 
                               
      //================================================================================
      // Integração de cancelamento de pedido realizado com sucesso. Disponibiliza
      // pedido para alteração e aprovação.
      //================================================================================                       
 
       If _cSituacao == "P"  
         SC5->(RecLock("SC5",.F.))
         SC5->C5_I_ENVRD := "R"  // Situação R = Integração de Pedido de Vendas Retornado para o Protheus, ou seja, cancelado no sistema RDC.    
         SC5->C5_I_DTRET := Date() // Data de retorno do pedido de vendas do RDC para o Protheus
         SC5->C5_I_HRRET := Time() // Hora de retorno do pedidod e vendas do RDC para o Protheus
         SC5->(MsUnlock())
      EndIf
        
      Aadd(_aresult,{SC5->C5_NUM,ZZM->ZZM_CGC,_cResposta }) // adicona em um array para fazer um item list, exibir os resultados.
      
      Sleep(100) //Espera para não travar a comunicação com o webservice da RDC
      
      If valtype(oproc) = "O"

         oProc:cCaption := (SC5->C5_NUM+" - "+ ZFQ->ZFQ_CNPJEM + " - "  + _cResposta)
         ProcessMessages()

      EndIf
       
   End Transaction
   
   _aCabecalho := {}
   Aadd(_aCabecalho,"PEDIDO" ) 
   Aadd(_aCabecalho,"CNPJ") 
   Aadd(_aCabecalho,"RETORNO") 
             
   _cTitulo := "Resultados da Integração"
 
   If !(FWIsInCallStack("U_AOMS108"))  .and. !(FWIsInCallStack("U_AOMS109"))   .and. !(FWIsInCallStack("U_MOMS066"))  //Não mostra mensagem se veio da exclusão multipla de PV ou central de logistica 
    
     If _cSituacao <> "P" 
        If _lExibeTela 
      	   u_itmsg("Não foi possível realizar o cancelamento de Pedidos de Vendas no Sistema RDC.","Atenção",,1)
      	//Else
      	   //U_ITCONOUT("Não foi possível realizar o cancelamento de Pedidos de Vendas no Sistema RDC.")
      	EndIf
      
      	If Len(_aResult) > 0 .And. _lExibeTela
      		U_ITListBox( _cTitulo , _aCabecalho , _aResult  ) // Exibe uma tela de resultado.
      	EndIf                 
      Else 
         If _lExibeTela
      	    u_itmsg("Cancelamento do pedido de vendas no sistema RDC realizado com sucesso.","Atenção",,2)
      	 //Else
      	    //U_ITCONOUT("Cancelamento do pedido de vendas no sistema RDC realizado com sucesso.")
      	 EndIf
      EndIf
    
   Endif
    
End Sequence

RestOrd(_aOrd)

Return _lRet   
