/*
======================================================================================================================================
                         ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
======================================================================================================================================
    Autor      |   Data   |                              Motivo                                                          
--------------------------------------------------------------------------------------------------------------------------------------
Vanderlei Alves| 15/03/18 | Chamado 24127. Alterada e ajustada a query de integração das notas fiscais para o sistema RDC. 
--------------------------------------------------------------------------------------------------------------------------------------
Julio Paz      | 19/03/18 | Chamado 24173. Correção de error.log. Inclusão da tabela ZP1 na lista do Prepare Environment.
--------------------------------------------------------------------------------------------------------------------------------------
Lucas Borges   | 11/10/19 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.. 
--------------------------------------------------------------------------------------------------------------------------------------
Julio Paz      | 09/09/22 | Chamado 41046. Alterar função utilizada para chamada via Scheduller para não consumir liçenças. 
--------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer  | 19/10/23 | Chamado 45353. Vanderlei. Alterar o SELECT principal para otimização da consulta.
--------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer  | 31/07/24 | Chamado 48042. Retirar o IF (ALLTRIM(GETENVSERVER()) == "PRODUCAO") do programas usados no Schedule.
--------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer  | 13/08/24 | Chamado 48152. Jerry. Acrescentado o envio XML da NFe Vendas p/ o RDC das Nf SEDEX e tb as Nf que não tem OC geradas no RDC.
--------------------------------------------------------------------------------------------------------------------------------------
Lucas Borges   | 23/07/25 | Chamado 51340. Ajustar função para validação de ambiente de teste
======================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"  
#INCLUDE "TBICONN.CH"  

/*
===============================================================================================================================
Programa----------: MOMS033
Autor-------------: Julio de Paula Paz
Data da Criacao---: 21/10/2016
===============================================================================================================================
Descrição---------: Rotina de integração de Notas Fiscais, Italac <---> RDC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
STATIC _lScheduller :=.F.
User Function MOMS033()

If _lScheduller 
   MOMS033G("TIPO P")
   MOMS033G("TIPO O")
ELSE
   Processa( {|| MOMS033G("TIPO P")},"Processando TIPO P Hora Ini: "+Time()+", Aguarde...")
   Processa( {|| MOMS033G("TIPO O")},"Processando TIPO O Hora Ini: "+Time()+", Aguarde...")
ENDIF
RETURN .F.
/*
===============================================================================================================================
Programa----------: MOMS033G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 21/10/2016
===============================================================================================================================
Descrição---------: Rotina de integração de Notas Fiscais, Italac <---> RDC.
===============================================================================================================================
Parametros--------: _cTipo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function MOMS033G(_cTipo)
Local _cQry
Local _dDataIntRDC := U_ItGetMv("IT_DTINTRDC",Ctod("01/01/2022"))
Local _cDirXML := U_ITGetMv("IT_DIRXMLRD","\\wfteste.italac.com.br\TOTVS\Homologacao\Protheus_data\data\Italac\RDC\RW17")
Local _cNomeArq, _nHandle
Local _nTotRegs:=0
Local _cXmlNfe, _cProtNfe
Local _cXmlEnv, _cPart1Xml, _cPart2Xml, _nI, _nF       
Local _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x RDC.  
Local _cListaFiliais
Local _cTimeIni:=Time()

If !_lScheduller .AND. ! u_itmsg("Confirma a integração de Notas Fiscais, Italac <---> RDC.?","Inicio de processamento "+_cTipo,,2,2,2) 
   return .f.
EndIf

Begin Sequence 
   _cListaFiliais := AllTrim(_cFilHabilit)                             
   _cListaFiliais := StrTran(_cListaFiliais,";","','")                                                                                                      

   IF !_lScheduller
      ProcRegua(0)
      IncProc("Lendo dados da SPED50/SF2...")
      IncProc("Lendo dados da SPED50/SF2...")   
   EndIf
   
   //===================================================================================================
   // Montagem de query com os numeros de registros das notas fiscais a serem enviadas para o RDC.
   //===================================================================================================
IF _cTipo == "TIPO P"

   _cQry := " SELECT SPED50.R_E_C_N_O_ NRECNO,  "
   _cQry += " SF2.R_E_C_N_O_ NRECSF2,  "
   _cQry += " SPED54.R_E_C_N_O_ NREC54,  "
   _cQry += " DAK.R_E_C_N_O_ NRECDAK  "
   _cQry += " FROM "+RetSqlName("SF2")+" SF2,  "
   _cQry += " SPED001 SPED01,  "
   _cQry += " SPED050 SPED50,  "
   _cQry += " SPED054 SPED54,  "
   _cQry += RetSqlName("DAK")+" DAK,  "
   _cQry += " SYS_COMPANY SM0  "
   IF SuperGetMV("IT_AMBTEST",.F.,.T.)
      _cQry += " WHERE F2_EMISSAO >= '" + DTOS(DATE()-120) + "' "//PARA TESTES
      _cQry += " AND F2_I_SITUA <> ' '  " //PARA TESTES
      _cDirXML := "\data\Italac\RDC\RW17\"//PARA TESTES
   ELSE//PARA TESTES
      _cQry += " WHERE F2_EMISSAO >= '" + DTos(_dDataIntRDC) + "' "
      _cQry += " AND F2_I_SITUA = ' '  "
   ENDIF
   _cQry += " AND F2_ESPECIE = 'SPED'  "
   _cQry += " AND F2_CARGA  <>' '  "
   _cQry += " AND F2_CHVNFE <> ' '  "
   _cQry += " AND SF2.D_E_L_E_T_ = ' '  "
   _cQry += " AND DAK_FILIAL = F2_FILIAL  "
   _cQry += " AND DAK_COD = F2_CARGA  "
   _cQry += " AND DAK.D_E_L_E_T_ = ' '  "
   _cQry += " AND M0_CODIGO = '01'  "
   _cQry += " AND M0_CODFIL = F2_FILIAL  "
   _cQry += " AND SM0.D_E_L_E_T_ = ' '  "
   _cQry += " AND SPED01.CNPJ = SM0.M0_CGC  "
   _cQry += " AND SPED01.IE = SM0.M0_INSC  "
   _cQry += " AND SPED01.D_E_L_E_T_ = ' '  "
   _cQry += " AND SPED50.ID_ENT = SPED01.ID_ENT  "
   _cQry += " AND SPED50.NFE_ID = (F2_SERIE||F2_DOC)  "
   _cQry += " AND SPED50.STATUS = '6'  "
   _cQry += " AND SPED50.D_E_L_E_T_ = ' '  "
   _cQry += " AND SPED54.ID_ENT = SPED01.ID_ENT  "
   _cQry += " AND SPED54.NFE_ID = (F2_SERIE||F2_DOC)  "
   _cQry += " AND SPED54.CSTAT_SEFR = '100'  "
   _cQry += " AND SPED54.D_E_L_E_T_ = ' '  "

ELSEIF _cTipo == "TIPO O"

   _cListaFiliais := StrTran(_cListaFiliais,"'","")

   _cQry := " SELECT SPED50.R_E_C_N_O_ NRECNO,  "
   _cQry += " SF2.R_E_C_N_O_ NRECSF2, "
   _cQry += " SPED54.R_E_C_N_O_ NREC54 "
   _cQry += " FROM "+RetSqlName("SF2")+" SF2, "
   _cQry += " SPED001 SPED01, "
   _cQry += " SPED050 SPED50, "
   _cQry += " SPED054 SPED54, "
   _cQry += RetSqlName("SC5")+" SC5,
   _cQry += " SYS_COMPANY SM0  "
   IF SuperGetMV("IT_AMBTEST",.F.,.T.)
      _cQry += " WHERE F2_EMISSAO >= '" + DTOS(DATE()-180) + "' "//PARA TESTES
      _cDirXML := "\data\Italac\RDC\RW17\"//PARA TESTES
   ELSE
      _cQry += " WHERE F2_EMISSAO >= '20240601' "
   ENDIF
   _cQry += " AND F2_FILIAL IN "+FormatIn(ALLTRIM(_cListaFiliais),",")
   _cQry += " AND F2_TIPO = 'N' "
   _cQry += " AND F2_I_SITUA NOT IN ('I','P','O')  "
   _cQry += " AND F2_ESPECIE = 'SPED'  "
   _cQry += " AND SC5.C5_TPFRETE <> 'F' "
   _cQry += " AND F2_CHVNFE <> ' '  "
   _cQry += " AND SF2.D_E_L_E_T_ = ' '  "
   _cQry += " AND M0_CODIGO = '01'  "
   _cQry += " AND M0_CODFIL = F2_FILIAL  "
   _cQry += " AND SM0.D_E_L_E_T_ = ' '  "
   _cQry += " AND SPED01.CNPJ = SM0.M0_CGC  "
   _cQry += " AND SPED01.IE = SM0.M0_INSC  "
   _cQry += " AND SPED01.D_E_L_E_T_ = ' '  "
   _cQry += " AND SPED50.ID_ENT = SPED01.ID_ENT  "
   _cQry += " AND SPED50.NFE_ID = (F2_SERIE||F2_DOC)  "
   _cQry += " AND SPED50.STATUS = '6'  "
   _cQry += " AND SPED50.D_E_L_E_T_ = ' '  "
   _cQry += " AND SPED54.ID_ENT = SPED01.ID_ENT  "
   _cQry += " AND SPED54.NFE_ID = (F2_SERIE||F2_DOC)  "
   _cQry += " AND SPED54.CSTAT_SEFR = '100'  "
   _cQry += " AND SPED54.D_E_L_E_T_ = ' '  "
   _cQry += " AND SC5.C5_FILIAL = SF2.F2_FILIAL "
   _cQry += " AND SC5.C5_NUM = SF2.F2_I_PEDID "
   _cQry += " AND ((SC5.C5_I_TRCNF = 'S' AND SC5.C5_I_PDFT = SC5.C5_NUM) OR SC5.C5_I_TRCNF = 'N') "
   _cQry += " AND SC5.C5_I_OPER IN ('01','12','15','24','25','26','31','42') "
   _cQry += " AND SC5.D_E_L_E_T_ = ' ' "
   _cQry += " AND NOT EXISTS (SELECT 'Y' FROM "+RetSqlName("DAK")+" DAK "
   _cQry += "                        WHERE D_E_L_E_T_ <> '*' AND DAK_FILIAL = SF2.F2_FILIAL AND "
   _cQry += "                                                       DAK_COD = SF2.F2_CARGA  AND DAK_I_CARG <> ' ') "

ENDIF
   
   If Select("TRBSPED") > 0
      TRBSPED->( DBCloseArea() )
   EndIf

   DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSPED" , .T., .F. )                            
                                                                                  
   COUNT TO _nTotRegs
   IF !_lScheduller
      ProcRegua(_nTotRegs)
      _cTotal:=ALLTRIM(STR(_nTotRegs))
   EndIf
                          
   TRBSPED->(DbGoTop())
   
   u_itconout("MOMS033: Geracao de arquivos XML de NFE no diretório: "+_cDirXML )
   u_itconout("MOMS033: AMBIENTE: "+ALLTRIM(GETENVSERVER())+" Data: "+Dtoc(Date())+" Hora: "+Time())
   u_itconout("MOMS033: Total de registros a serem processados: "+Str(_nTotRegs,8))
   
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

      IF !_lScheduller
         _nConta++
         IncProc("Registros Lidos: "+ALLTRIM(STR(_nConta))+" de "+_cTotal)   
      EndIf

      SF2->(DbGoTo(TRBSPED->NRECSF2))
      SC5->(DbSeek(SF2->F2_FILIAL+SF2->F2_I_PEDID))

      _lok := .T.
      
      Begin Sequence

      IF _cTipo == "TIPO P"  //************************************************************************************************
         
         DAK->(dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))

         If Alltrim(SC5->C5_TIPO) <> "N" // Diferente de um pedido normal.
            _lok := .F.
            Break
         EndIf

         If !(SF2->F2_FILIAL $ _cListaFiliais) // Ignora todas as filiais das notas fiscais que não estão no parâmetro e as filiais dos pedidos de origem da troca de nota que não estão no parâmetro.
            If Empty(SC5->C5_I_FLFNC) .Or. ! (SC5->C5_I_FLFNC $ _cListaFiliais) 
               _lok := .F.
               Break
            EndIf 
         EndIf
         
         If Empty(SC5->C5_I_FLFNC) // É um pedido de vendas normal. Não é um pedido de troca nota.
            // Validar a existência de cargas apenas para Pedidos de Vendas Normais.      
            If Empty(DAK->DAK_I_CARG)
               _lok := .F.
               Break
            EndIf
         EndIf
   
         If SC5->C5_I_TRCNF != "S" .AND. EMPTY(DAK->DAK_I_CARG)  //Se não é troca nota e carga não foi montada pelo RDC 
               _lok := .F.
               Break
         EndIf

         If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDPR .AND. EMPTY(DAK->DAK_I_CARG)  //Se é troca nota, pedido de carregamento e carga não foi montada pelo RDC 
            _lok := .F.
            Break
         EndIf

         If SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDFT   //Se é troca nota, pedido de faturamento
         
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

      //ELSEIF _cTipo == "TIPO P"  //************************************************************************************************

        //TODOS OS IFs FORAM PARA QUERY 

      ENDIF
      
      SPED050->(DbGoTo(TRBSPED->NRECNO))
      
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
         
     
        	//===================================================================================================
        	// Grava XML em Diretório para o RDC
        	//===================================================================================================   
        	_nHandle := FCreate(_cDirXML + _cNomeArq)
         IF _nHandle <= 0
            u_itconout("MOMS033: Não foi possivel criar o arquivo XML de NFE: "+_cDirXML+ _cNomeArq )
            TRBSPED->(DbSkip())
            LOOP
         ELSE
        	   FWrite(_nHandle,_cXmlEnv)
        	   FClose(_nHandle)
            u_itconout("MOMS033: Gravado o arquivo XML de NFE: "+_cDirXML+ _cNomeArq )
         ENDIF
      
        	SF2->(RecLock("SF2",.F.))
         IF _cTipo == "TIPO P"
        	   SF2->F2_I_SITUA := 'P'    
         ELSEIF _cTipo == "TIPO O"
        	   SF2->F2_I_SITUA := 'O'    
         ENDIF
        	SF2->F2_I_DTENV := Date()
        	SF2->F2_I_HRENV := Time()
        	SF2->(MsUnLock())
         _nEnviados++

      Else
      
      	SF2->(RecLock("SF2",.F.))
        	SF2->F2_I_SITUA := 'N'    
        	SF2->F2_I_DTENV := Date()
        	SF2->F2_I_HRENV := Time()
        	SF2->(MsUnLock())
      		
      Endif
            
      TRBSPED->(DbSkip())
      
   EndDo

   _cTextoFim:="Notas Fiscais enviadas: "+ALLTRIM(STR(_nEnviados))+Chr(10)
   u_itconout("MOMS033: Termino da Integração de Notas Fiscais, Italac ---> RDC "+_cTextoFim)
   u_itconout("MOMS033: AMBIENTE: "+ALLTRIM(GETENVSERVER())+" Data: "+Dtoc(Date())+" Hora Inicial: "+_cTimeIni+" Hora Final: "+Time())
   If !_lScheduller
      u_itmsg(">> Processamento concluído << "+Chr(10)+;
              "Hora Inicial: "+_cTimeIni+" / Hora Final: "+TIME()+Chr(10)+_cTextoFim,;
              "Fim de processamento "+_cTipo,,2)
   EndIf
   
End Sequence

//================================================================================
// Fecha as tabelas temporárias
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

//Log de utilização
//U_ITLOGACS()

Return Nil

/*
===============================================================================================================================
Programa----------: MOMS033S
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/03/2017
===============================================================================================================================
Descrição---------: Rotina para rodar a integração de Notas Fiscais, Italac <---> RDC, em Scheduller.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function MOMS033S()

Begin Sequence
   //=====================================================================
   // Limpa o ambiente, liberando a licença e fechando as conexões
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
   
   _lScheduller :=.T.
   
   U_MOMS033() 
   
End Sequence

Return
