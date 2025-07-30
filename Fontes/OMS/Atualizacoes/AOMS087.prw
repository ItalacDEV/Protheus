/*
===============================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor  |    Data    |                              Motivo                                                         
-------------------------------------------------------------------------------------------------------------------------------          
Julio Paz     | 19/03/2018 | Chamado 24173 - Inclus�o da tabela ZP1. Prepare Environment da fun��o AOMS087A().                   
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 22/03/2019 | Chamado 28557 - Padroniza��o de fontes para funcionar com o novo servidor Totvs Loboguar�. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/10/2019 | Chamado 28346 - Removidos os Warning na compila��o da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/03/2021 | Chamado 36002 - Aumentar o timeout do webservice de integra��o para mais segundos. 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 11/02/2022 | Chamado 39185 - Corrigir a rotina que roda em Scheduller para enviar todas as filiais. 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 09/09/2022 | Chamado 41046 - Alterar fun��o utilizada para chamada via Scheduller para n�o consumir li�en�as. 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaco  | 19/01/2024 | Chamado 46112 - Grava��o do Campo ZFK_TIPOI.
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaco  | 24/01/2024 | Chamado 46112 - Tratamento para execu��o apenas dos registros do RDC ZFK_TIPOI = 1
=============================================================================================================================== 
Analista         - Programador       - Inicio     - Envio    - Chamado - Motivo da Altera��o
---------------------------------------------------------------------------------------------------------------------------------------------------------
Vanderlei Alves  - Julio Paz         - 14/03/25   - 28/03/25 - 45229   - Atualizando o chamado 46112 em produ��o, para dar andamento ao chamado 45229.
=========================================================================================================================================================

*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"  

/*
===============================================================================================================================
Programa----------: AOMS087
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/12/2016
===============================================================================================================================
Descri��o---------: Rotina de integra��o e envio de dados de vincula��o Nota Fiscal Eletr�nica com Pedidos de Vendas 
                    via webservice para o sistema RDC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS087()
Local _aCores := {}
Private aRotina := {}
Private cCadastro 


//Grava Log de execu��o da rotina
U_ITLOGACS()

Begin Sequence
   cCadastro := "Integra��o dos Dados de Vincula��o NFE com Pedidos de Vendas Via Webservice: Italac <---> RDC"
   Aadd(aRotina,{"Pesquisar"              ,"AxPesqui"   ,0,1})
   Aadd(aRotina,{"Visualizar"             ,"AxVisual"   ,0,2})
   Aadd(aRotina,{"Integracao Webservice"  ,"U_AOMS087I" ,0,4})   
   Aadd(aRotina,{"Carga de Dados NFE/Ped.","U_AOMS087S" ,0,3}) 
   Aadd(aRotina,{"Legenda"                ,"U_AOMS087L" ,0,6})
   
   Aadd(_aCores,{"ZFK_SITUAC == 'N'" ,"BR_VERDE" })
   Aadd(_aCores,{"ZFK_SITUAC == 'P'" ,"BR_VERMELHO" })
   Aadd(_aCores,{"ZFK_SITUAC == 'R'" ,"BR_AMARELO" })

   DbSelectArea("ZFK")
   ZFK->(DbSetOrder(1)) 
   ZFK->(DbGoTop())
   MBrowse(6,1,22,75,"ZFK", , , , , , _aCores)
   
End Sequence

Return Nil    

/*
===============================================================================================================================
Fun��o------------: AOMS087L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/12/2016
===============================================================================================================================
Descri��o---------: Rotina de Exibi��o da Legenda do MBrowse.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS087L()       
Local _aLegenda := {}

Begin Sequence

   Aadd(_aLegenda,{"BR_VERDE"    ,"N�o Processado" })
   Aadd(_aLegenda,{"BR_AMARELO"  ,"Rejeitada" })
   Aadd(_aLegenda,{"BR_VERMELHO" ,"Processado" })

   BrwLegenda(cCadastro, "Legenda", _aLegenda)

End Sequence

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS087I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/12/2016
===============================================================================================================================
Descri��o---------: Rotina de integra��o e envio de dados dos Pedidos de Vendas via webservice para empresa RDC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS087I()
Local _lRet := .F.
Local _aStrucZFK
Local _aOrd := SaveOrd({"SX3","ZFK"})
Local _aCmpZFK := {}
Local _aButtons := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _lInverte := .F.
Local _oDlgInt, _nI
Local _otemp

Private _oMarkZFK, _cMarcaZFK := GetMark() 
Private _cArqZFK
Private aHeader := {} , aCols := {}

Begin Sequence
   //================================================================================
   // Cria as estruturas das tabelas tempor�rias
   //================================================================================
   _aStrucZFK := ZFK->(DbStruct())
   Aadd(_aStrucZFK,{"WK_OK"  , "C", 2 ,0})
   Aadd(_aStrucZFK,{"WKRECNO", "N", 10,0})
   
   //================================================================================
   // Abre o arquivo TRBZFQ criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZFK",  _aStrucZFK)
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZFK_DATA"} )
   _otemp:Create()   
   
   DBSelectArea("TRBZFK")
  
   //============================================================================
   // Montagem do aheader                                                        
   //=============================================================================
   FillGetDados(1,"ZFK",1,,,{||.T.},,,,,,.T.)
   
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //================================================================================
   // Monta as colunas do MSSELECT para a tabela tempor�ria TRBZFQ 
   //================================================================================
   Aadd( _aCmpZFK , { "WK_OK"		,    , "Marca"                                          ,"@!"})
   
   For _nI := 1 To Len(aHeader)
       If !X3USO( aHeader[_nI,7] ) .Or. aHeader[_nI,10] == 'V' .Or. (AllTrim(aHeader[_nI,2]) $ "ZFK_ALI_WT/ZFK_REC_WT")
          Loop
       EndIf
       Aadd( _aCmpZFK , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
   Next 

   //================================================================================
   // Carrega os dados da tabela ZFK
   //================================================================================
   Processa( {|| U_AOMS087D()(  ) } , 'Aguarde!' , 'Lendo dados a serem integrados...' )

   _bOk := {|| _lRet := .T., _oDlgInt:End()}
   _bCancel := {|| _lRet := .F., _oDlgInt:End()}
   AADD(_aButtons,{"",{|| U_AOMS087M("T") },"Marc/Des" ,"Marca/Desmarca Todos"})
                                          
   _cTitulo := cCadastro
   
   //================================================================================
   // Monta a tela de dados com MSSELECT.
   //================================================================================      
   Define MsDialog _oDlgInt Title _cTitulo From 9,0 To 200,80 //Of oMainWnd 
      
      _oMarkZFK := MsSelect():New("TRBZFK","WK_OK","",_aCmpZFK,@_lInverte, @_cMarcaZFK,{_aSizeAut[7]+20, 5, _aSizeAut[4], _aSizeAut[3]})
      _oMarkZFK:bAval := {|| U_AOMS087M("P")}
      _oDlgInt:lMaximized:=.T.
      
   Activate MsDialog _oDlgInt On Init (EnchoiceBar(_oDlgInt,_bOk,_bCancel,,_aButtons), _oMarkZFK:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT , _oMarkZFK:oBrowse:Refresh() )
   
   If _lRet
      Processa( {|| U_AOMS087W(  ) } , 'Aguarde!' , 'Integrando Dados do Pedido de Venadas...' )
   EndIf

End Sequence

//================================================================================
// Fecha e exclui as tabelas tempor�rias
//================================================================================                    
If Select("TRBZFK") > 0
   TRBZFK->(DbCloseArea())
EndIf

RestOrd(_aOrd)

Return Nil

/*
===============================================================================================================================
Fun��o----------: AOMS087M
Autor-----------: Julio de Paula Paz
Data da Criacao-: 07/12/2016
===============================================================================================================================
Descri��o-------: Fun��o para marcar e desmarcar todos Pedidos de Vendas que ser�o integrados via Webservice.
===============================================================================================================================
Parametros------: _cTipoMarca = "T" = Marca e desmarca todos os registros.
                  _cTipoMarca = "P" = Marca e desmarca apena o registro posisionado.                                           
===============================================================================================================================
Retorno---------: Nenhum                  
===============================================================================================================================
*/
User Function AOMS087M(_cTipoMarca)
Local _cSimboloMarca := Space(2)
Local _nRegAtu := TRBZFK->(Recno()) 

Begin Sequence          
   If Empty(TRBZFK->WK_OK )
      _cSimboloMarca := _cMarcaZFK
   Else
      _cSimboloMarca := Space(2)
   EndIf   
      
   If _cTipoMarca == "P"
      TRBZFK->(RecLock("TRBZFK",.F.))
      TRBZFK->WK_OK := _cSimboloMarca 
      TRBZFK->(MsUnlock())
   Else
      TRBZFK->(DbGoTop())
      Do While ! TRBZFK->(Eof())
         TRBZFK->(RecLock("TRBZFK",.F.))
         TRBZFK->WK_OK := _cSimboloMarca 
         TRBZFK->(MsUnlock()) 
         
         TRBZFK->(DbSkip())
      EndDo
   
   EndIf
           
End Sequence

TRBZFK->(DbGoTo(_nRegAtu)) 
_oMarkZFK:oBrowse:Refresh()

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS087W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/12/2016
===============================================================================================================================
Descri��o---------: Gera os dados XML com base nos Pedidos de Vendas selecionados e integra via webservice.
===============================================================================================================================
Parametros--------: _lScheduler = .T. indica rotina em Scheduler; .F. indica rotina manual
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS087W(_lScheduler)             
Local _cDirXML := ""
Local _cLink   := ""
Local _cCabXML := ""
Local _cRodXML := "" 
Local _lItemSelect := .F.
Local _aOrd := SaveOrd({"ZFK","ZFM","SC9"})
Local _cXML 
Local _cResult := ""
Local _cResposta, _cSituacao
Local _cEmpWebService := U_ITGETMV( 'IT_EMPWEBSE' , '000001' ) 

Default _lScheduler := .F.

Begin Sequence
   //================================================================================
   // Verifica se h� itens selecionados e l� o c�digo da empresa de WebService.
   //================================================================================                    
   If ! _lScheduler
      ProcRegua(8)
      IncProc("Verificando itens selecionados...")
   Else
      u_itconout("Verificando itens selecionados para integra��o Vinc.NFE x Pedidos de Vendas.")
   EndIf                    
   
   TRBZFK->(DbGoTop())                                                                   
   Do While ! TRBZFK->(Eof())
      If ! Empty(TRBZFK->WK_OK)   
         _cEmpWebService := TRBZFK->ZFK_CODEMP                         
         _lItemSelect := .T. 
         Exit
      EndIf                 
      
      TRBZFK->(DbSkip())
   EndDo 
     
   If ! _lItemSelect 
      If ! _lScheduler
         MsgInfo("Nenhum item foi selecionado para integra��o Webservice. N�o ser� poss�vel realizar a integra��o Italac <---> RDC.","Aten��o")
      Else
         u_itconout("Nenhum item foi selecionado para integra��o Webservice. N�o ser� poss�vel realizar a integra��o Italac <---> RDC.")
      EndIf                                                                                                                         
      
      Break   
   EndIf              
   
   //================================================================================
   // L� o diret�rio dos arquivos XML modelos e o link de envio dos dados.
   //================================================================================
   If ! _lScheduler
      IncProc("Identificando diret�rio dos XML...")                    
   Else
      u_itconout("Identificando diret�rio dos XML...") 
   EndIf                                           
   
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirXML := ZFM->ZFM_LOCXML 
      _cLink   := AllTrim(ZFM->ZFM_LINK01)
   Else            
      If ! _lScheduler
         MsgInfo("Empresa WebService para envio dos dados n�o localizada.","Aten��o")
      Else
         u_itconout("Empresa WebService para envio dos dados n�o localizada.")
      EndIf
      
      Break   
   EndIf                        
   
   If Empty(_cDirXML) .Or. Empty(_cLink)
      If ! _lScheduler
         MsgInfo("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Aten��o")
      Else
         u_itconout("Diret�rio dos arquivos XML modelos ou o Link de envio de dados n�o informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".")
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
   If ! _lScheduler
      IncProc("Lendo arquivo XML Modelo de Cabe�alho...")                      
   Else
      u_itconout("Lendo arquivo XML Modelo de Cabe�alho...")
   EndIf                                                
   
   _cCabXML := U_AOMS087X(_cDirXML+"Cab_VinculaNfePedido.txt") 
   If Empty(_cCabXML)
      If ! _lScheduler
         MsgInfo("Erro na leitura do arquivo XML modelo do cabe�alho de envio vincula��o NFE com Pedido de Vendas. ","Aten��o")
      Else
         u_itconout("Erro na leitura do arquivo XML modelo do cabe�alho de envio vincula��o NFE com Pedido de Vendas. ")
      EndIf
      
      Break
   EndIf
   
   If ! _lScheduler
      IncProc("Lendo arquivo XML Modelo de Detalhe ...")
   Else
      u_itconout("Lendo arquivo XML Modelo de Detalhe ...")
   EndIf                                               
   
   _cDet_XML := U_AOMS087X(_cDirXML+"Det_VinculaNfePedido.txt")
   If Empty(_cDet_XML)
      If ! _lScheduler
         MsgInfo("Erro na leitura do arquivo XML modelo do detalhe de envio vincula��o NFE com Pedido de Vendas.","Aten��o")
      Else
         u_itconout("Erro na leitura do arquivo XML modelo do detalhe de envio vincula��o NFE com Pedido de Vendas.")
      EndIf
      
      Break
   EndIf            
   
   If ! _lScheduler  
      IncProc("Lendo arquivo XML Modelo de Rodap�...")
   Else
      u_itconout("Lendo arquivo XML Modelo de Rodap�...")
   EndIf                                             
   
   _cRodXML := U_AOMS087X(_cDirXML+"Rodape_VinculaNfePedido.txt")
   If Empty(_cRodXML)
      If ! _lScheduler
         MsgInfo("Erro na leitura do arquivo XML modelo do rodap� de envio vincula��o NFE com Pedido de Vendas.","Aten��o")
      Else
         u_itconout("Erro na leitura do arquivo XML modelo do rodap� de envio vincula��o NFE com Pedido de Vendas.")
      EndIf    
      
      Break
   EndIf
   
   //================================================================================
   // Ativa a classe de envio de dados.
   //================================================================================     
   If ! _lScheduler                  
      IncProc("Montando dados de envio...")
   Else
      u_itconout("Montando dados de envio...")
   EndIf

   oWsdl := tWSDLManager():New() // Cria o objeto da WSDL.  
   oWsdl:nTimeout := 60          // Timeout de xx segundos                                                               
   oWsdl:lSSLInsecure := .T. //   Acessa com certificado an�nimo                                                               
   
   //oWsdl:ParseURL( "http://10.3.0.201/wsitf18/Service.svc?wsdl") // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.  
   oWsdl:ParseURL( _cLink) // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. Este link � o da RDC.   
   oWsdl:SetOperation( "VinculaNfePedido") // Define qual opera��o ser� realizada.   
   
   _aresult := {}
   
   TRBZFK->(DbGoTop())                                                                   
   Do While ! TRBZFK->(Eof())
          
      If ! Empty(TRBZFK->WK_OK)   
         ZFK->(DbGoto(TRBZFK->WKRECNO))

            Begin Transaction

               //-----------------------------------------------------------------------------------------
               // Realiza a integra��o dos pedidos de vendas (Envio de XML) via WebService.
               //-----------------------------------------------------------------------------------------
                        
               //Monta XML
               _cXML := _cCabXML + &(_cDet_XML) + _cRodXML  // Monta o XML de envio.
               
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
               ElseIf !("IMPORTADO COM SUCESSO" $ _cResposta)       	
                  _cSituacao := "N"
               EndIf

               //grava resultado // sempre como processado
               ZFK->(RecLock("ZFK",.F.))
               ZFK->ZFK_SITUAC  := _cSituacao // iif(_cok, "P", "N")
               ZFK->ZFK_USUARI  := __CUSERID
               ZFK->ZFK_DATAAL  := Date()
               ZFK->ZFK_RETORN  := _cResposta // AllTrim(strtran(_cResult,Chr(10)," ")) // grava o resultado da integra��o na tabela ZFK,dizendo que deu certo ou n�o.
               ZFK->ZFK_XML     := _cXML
               
               ZFK->(MsUnlock()) 
                     
               Aadd(_aresult,{ZFK->ZFK_PEDIDO,ZFK->ZFK_CGC,ZFK->ZFK_RETORN}) // adicona em um array para fazer um item list, exibir os resultados.
               Sleep(100) //Espera para n�o travar a comunica��o com o webservice da RDC
               
               If ! _lScheduler  
                  IncProc(ZFK->ZFK_CGC+ " - "  + ZFK->ZFK_RETORN)
               Else
                  u_itconout(ZFK->ZFK_CGC+ " - "  + ZFK->ZFK_RETORN)
               EndIf
                  
            End Transaction
         
      EndIf       
                
      TRBZFK->(DbSkip())
         
   EndDo 
   
   If ! _lScheduler  
      _aCabecalho := {}
      Aadd(_aCabecalho,"PEDIDO") 
      Aadd(_aCabecalho,"CNPJ") 
      Aadd(_aCabecalho,"RETORNO") 
             
      _cTitulo := "Resultados da integra��o"
      
      If len(_aresult) > 0
      
  	     u_ITListBox( _cTitulo , _aCabecalho , _aresult  ) // Exibe uma tela de resultado.
  	  
  	  Endif
   Else
      u_itconout(_cResult)
   EndIf   
    
End Sequence

RestOrd(_aOrd)

Return Nil   

/*
===============================================================================================================================
Fun��o-------------: AOMS087X
Aut2or-------------: Julio de Paula Paz
Data da Criacao---: 07/12/2016
===============================================================================================================================
Descri��o---------: L� o arquivo XML modelo no diret�rio informado e retorna os dados no formato de String.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS087X(_cArq)
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
=================================================================================================================================
Programa--------: AOMS087S()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 07/12/2016
=================================================================================================================================
Descri��o-------: Chama a rotina de leitura de dados das notas fiscais enviadas para o sistema RDC, permitindo a exibi��o 
                  da regua de processo.
================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS087S()

Begin Sequence
   
   Processa( {|| U_AOMS087R(.F.) } , 'Aguarde!' , 'Lendo dados dos Livros Fiscais...' )

End Sequence

Return Nil
                     
/*
=================================================================================================================================
Programa--------: AOMS087R()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 07/12/2016
=================================================================================================================================
Descri��o-------: L� os dados da tabela de SF2(Notas fiscais de Sa�da) que j� foram processados e gravaram os XMLs de notas 
                  fiscais em diret�rio para envio ao RDC, identifica o pedido de vendas vinculado a NFE e grava os dados na 
                  tabela de muro ZFK para integra��o da vincula��o da NFE com o Pedido de Vendas e envio ao RDC.
=================================================================================================================================
Parametros------: _lScheduler = .T. indica rotina em scheduler, .F. indica rotina manual.
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS087R(_lScheduler)
Local _cQry, _nTotRegs
Local _aOrd := SaveOrd({"SA2","SF2","SC5"})
Local _aFilial := FwLoadSM0()
Local _nI, _cCnpj
Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )  
Local _cPedido
Local _cFilial, _nRegAtu
Local _cPedOrig 

Default _lScheduler := .F.

If ! _lScheduler                  
   ProcRegua(0)
   IncProc("Lendo dados...") 
   IncProc("Lendo dados...") 
EndIf

Begin Sequence 
   u_itconout("Lendo dados da tabela Notas Fiscais de Sa�da SF2 para integra��o RDC.")
   
   _cQry := " SELECT R_E_C_N_O_ AS NRRECNO FROM "+RetSqlName("SF2")+" SF2 "
   _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' AND F2_I_SITUA = 'P' " 
                                                              
   If Select("TRBSF2") > 0
      TRBZF2->(DbCloseArea())
   EndIf                     
             
   DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQry), "TRBSF2", .T., .F.)
   
   Count To _nTotRegs
   
   If _nTotRegs == 0 
      If _lScheduler
         u_itconout("Nenhum registro de notas fiscais foi encontrado para integra��o RDC.")
      Else
         MsgInfo("Nenhum registro de notas fiscais foi encontrado para integra��o RDC.","Aten��o")
      EndIf
      
      Break
   EndIf
   
   If ! _lScheduler                  
      ProcRegua(_nTotRegs)
   EndIf
   
   SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
   SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO  
   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM                                                                                                
   
   TRBSF2->(DbGoTop()) 
       
   Do While ! TRBSF2->(Eof())                 
       
      SF2->(DbGoTo(TRBSF2->NRRECNO))
      
      If _lScheduler
         u_itconout("Processando Filial/Nota Fiscal: "+SF2->F2_FILIAL+"/"+AllTrim(SF2->F2_DOC)+"-"+SF2->F2_SERIE)
      Else
         IncProc("Processando Filial/Nota Fiscal: "+SF2->F2_FILIAL+"/"+AllTrim(SF2->F2_DOC)+"-"+SF2->F2_SERIE) 
      EndIf

      _nI := Ascan(_aFilial,{|x| x[5] = SF2->F2_FILIAL})   
      _cCnpj := _aFilial[_nI,18]
      SA2->(DbSetOrder(3)) 
      SA2->(DbSeek(xFilial("SA2")+_cCnpj))
      
      _cPedido := SF2->F2_I_PEDID
      If SC5->(DbSeek(SF2->F2_FILIAL+_cPedido)) 
      
      	//============================================================
      	//Determina cnpj da filial de carregamento para troca nota
      	//============================================================
      	
         If SC5->C5_I_TRCNF == "S"
            _nI := Ascan(_aFilial,{|x| x[5] = SC5->C5_I_FLFNC})   
            _cCnpj := _aFilial[_nI,18]
         EndIf
       	
         If SC5->C5_I_PEDPA == "S"
            If SC5->C5_I_TRCNF == "S" .And. SC5->C5_I_OPER == "20" .And. SC5->C5_FILIAL <> SC5->C5_I_FILFT 
               //========================================================================================
               // Pega o numero do pedido e filial do pedido que originou o pedido de pallet.
               //========================================================================================
               _cPedOrig := SC5->C5_I_NPALE
               _cFilial := SC5->C5_FILIAL
               _nRegAtu := SC5->(Recno())
               //========================================================================================
               // Posiciona no pedido que originou o pedido de pallet, e pega o cnpj e o numero do pedido
               // que deu origem ao pedido de carregamento.
               //========================================================================================
               If SC5->(DbSeek(_cFilial+_cPedOrig))
                  _cPedido := SC5->C5_I_PDFT
               EndIf 
               SC5->(DbGoTo(_nRegAtu))
            Else
               _cPedido := SC5->C5_I_NPALE
            EndIf
         Else   
            If SC5->C5_I_TRCNF == "S" .And. SC5->C5_I_OPER == "20" .And. SC5->C5_FILIAL <> SC5->C5_I_FILFT 
               _cPedido := SC5->C5_I_PDFT
            EndIf
         EndIf                                      
      EndIf

      ZFK->(RecLock("ZFK",.T.))
      ZFK->ZFK_FILIAL  := SF2->F2_FILIAL     //	Filial do Sistema
      ZFK->ZFK_HORA    := Time()             // Hora de inclus�o do registro na tabela de muro.
      ZFK->ZFK_DATA    := Date()	         //	Data de Emiss�o
      ZFK->ZFK_CGC     := _cCnpj             //	CNPJ FORNECEDOR
      ZFK->ZFK_CHVNFE  := SF2->F2_CHVNFE     //	Chave da NFe SEFAZ
      ZFK->ZFK_PEDIDO  := _cPedido           //	Numero do Pedido(Na Italac h� um pedido por nota) // SF2->F2_I_PEDID
      ZFK->ZFK_COD     := SF2->F2_CLIENTE    // C�digo Cliente    // SA2->A2_COD  - Fornecedor    // O correto �: A1_COD
      ZFK->ZFK_LOJA    := SF2->F2_LOJA       // Loja Cliente      // SA2->A2_LOJA - Fornecedor    //              A1_LOJA
      ZFK->ZFK_NOME    := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")   // Nome Cliente      // SA2->A2_NOME - Fornecedor   //              A1_NOME
      ZFK->ZFK_USUARI  := __CUSERID	         //	Codigo do Usu�rio
      ZFK->ZFK_DATAAL  := Date()	         //	Data de Altera��o
      ZFK->ZFK_SITUAC  := "N"                //	Situa��o do Registro
      If SC5->C5_I_PEDPA == "S"              //  "S" = � um pedido de pallet.
         ZFK->ZFK_PEDPAL  := "S"             //  Grava dados informando que � um pedido de pallet.
         ZFK->ZFK_NRPPAL  := SF2->F2_I_PEDID //  Grava o numero do pedido de Pallet.
      Else
         ZFK->ZFK_PEDPAL  := "N"             //  N�o � um pedido de Pallet.
      EndIf
      ZFK->ZFK_CODEMP  := _cCodEmpWS         //	Codigo Empresa WebServer 
      ZFK->ZFK_TIPOI   := "1"
      ZFK->(MsUnlock())
      
            
      SF2->(RecLock("SF2",.F.))
      SF2->F2_I_SITUA := "I"  // Enviado para Integra��o
      SF2->(MsUnlock())
   
      TRBSF2->(DbSkip())
   EndDo
   
End Sequence

If Select("TRBSF2") > 0
   TRBSF2->(DbCloseArea())
EndIf   

RestOrd(_aOrd,.T.) // Volta a ordem os indices das tabelas para ordem anterior e volta os ponteiros de registros das tabelas

Return Nil           

/*
===============================================================================================================================
Fun��o------------: AOMS084D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2016
===============================================================================================================================
Descri��o---------: Grava em tabela tempor�ria os dados a serem integrados via webservice.
===============================================================================================================================
Parametros--------: _lScheduler = .T. rotina em scheduler; .F. rotina manual.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS087D(_lScheduler)
Local _lRet := .F.
Local cFilZFK:=xFilial("ZFK")
Local _nI

Default _lScheduler := .F.

Begin Sequence
   
   If ! _lScheduler
      //===================================================
      // Processamento da rotina chamada em tela.
      //===================================================
      ProcRegua(0)
      ZFK->(DbSetOrder(2))  // ZFF_FILIAL+ZFF_SITUAC
      ZFK->(DbSeek(cFilZFK+"N"))
      Do While ! ZFK->(Eof()) .And. ZFK->(ZFK_FILIAL+ZFK_SITUAC) == cFilZFK+"N"
         
         If ZFK->ZFK_TIPOI = "1"
            IncProc("Lendo PC: "+ZFK->ZFK_PEDIDO)
            
            TRBZFK->(DBAPPEND())
            For _nI := 1 To ZFK->(FCount())                  
               nPos:=TRBZFK->(FieldPos( ZFK->( FieldName(_nI)) ))
               IF nPos # 0
                  TRBZFK->(FieldPut(nPos,  ZFK->( FieldGet(_nI) ) )) 
               ENDIF
            Next            
            
            TRBZFK->WKRECNO := ZFK->(Recno())

            _lRet := .T.
         EndIf

         ZFK->(DbSkip())
      EndDo

   Else 
      //===================================================
      // Processamento da rotina chamada via Scheduller. 
      //===================================================
      ZFK->(DbSetOrder(2))  // ZFF_FILIAL+ZFF_SITUAC

      ZZM->(DbGoTop())
      Do While ! ZZM->(Eof())
            
         ZFK->(DbSeek(ZZM->ZZM_CODIGO+"N"))
         Do While ! ZFK->(Eof()) .And. ZFK->(ZFK_FILIAL+ZFK_SITUAC) == ZZM->ZZM_CODIGO+"N"
            If ZFK->ZFK_TIPOI = "1"
               TRBZFK->(DBAPPEND())
               For _nI := 1 To ZFK->(FCount())                  
                  nPos:=TRBZFK->(FieldPos( ZFK->( FieldName(_nI)) ))
                  IF nPos # 0
                     TRBZFK->(FieldPut(nPos,  ZFK->( FieldGet(_nI) ) )) 
                  ENDIF
               Next            
               TRBZFK->WK_OK   := _cMarcaZFK
               TRBZFK->WKRECNO := ZFK->(Recno())
         
               _lRet := .T.
            EndIf
            ZFK->(DbSkip())
         EndDo
         
         ZZM->(DbSkip())
      
      EndDo
      
   EndIf 

   TRBZFK->(DbGoTop())

End Sequence

Return _lRet

/*
===============================================================================================================================
Fun��o----------: AOMS087A
Autor-----------: Julio de Paula Paz
Data da Criacao-: 07/12/2016
===============================================================================================================================
Descri��o-------: Fun��o para rodar a rotina de integra��o Vincula��o NFE com Pedido de Vendas de forma agendada (Scheduller).
==============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum                  
===============================================================================================================================
*/
User Function AOMS087A()             
Local _aOrd 
Local _otemp

Private _cArqZFK
Private _cMarcaZFK 
Private aHeader := {} , aCols := {}

Begin Sequence
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

   //================================================================================
   _aOrd := SaveOrd({"SX3","ZFK"})
   _cMarcaZFK := GetMark()

   //================================================================================
   // Cria as estruturas das tabelas tempor�rias
   //================================================================================
   _aStrucZFK := ZFK->(DbStruct())
   Aadd(_aStrucZFK,{"WK_OK"  , "C", 2 ,0})
   Aadd(_aStrucZFK,{"WKRECNO", "N", 10,0})
   
   //================================================================================
   // Abre o arquivo TRBZFQ criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZFK",  _aStrucZFK)
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZFK_DATA"} )
   _otemp:Create()   
   
   DBSelectArea("TRBZFK")
       
   //================================================================================
   // L� os dados da tabela Notas Fiscais de Sa�da SF2 e grava na tabela de muro ZFK.
   //================================================================================
   U_AOMS087R(.T.)

   //================================================================================
   // Grava os dados das tabelas de muro em tabela tempor�ria para serem processados
   // via scheduller.
   //================================================================================
   U_AOMS087D(.T.)

   //================================================================================
   // Gera os dados dos XML e integra via webservices.
   //================================================================================ 
   U_AOMS087W(.T.)             

End Sequence

//================================================================================
// Fecha e exclui as tabelas tempor�rias
//================================================================================                    
If Select("TRBZFK") > 0
   TRBZFK->(DbCloseArea())
EndIf

RestOrd(_aOrd)

Return Nil
