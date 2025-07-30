/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
===============================================================================================================================
Andre         - Julio Paz    - 28/10/24 - 19/11/24 - 48915   - Rotina de integração WebService Italac x Evomilk
Andre         - Alex         - 21/11/24 - 26/12/24 - 48915   - Ajustes para a integração WebService Italac x Evomilk
Alex          - Julio Paz    - 26/12/24 - 26/12/24 - 49101   - Realização de ajustes nos filtros de dados e na instrução Count utilizando a função MPSysOpenQuery().
Lucas Borges  - Lucas Borges - 23/07/25 - 23/07/24 - 51340   - Ajustar função para validação de ambiente de teste
===============================================================================================================================
*/

// Definicoes de Includes e Defines da Rotina.
#include "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PARMTYPE.CH"
/*
===============================================================================================================================
Função-------------: MGLT032
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
Descrição----------: Rotina de integração WebService Italac x Evomilk. Chamado 48915.
Parametros---------: Nenhum
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032(_lSchedule)
Local _lEnvDadoP := .T.
Local _lEnvDadoC := .T.

//===================================================================
// O Webservice Evomilk irá substituir o App Cia do Leite.
// Possui as mesmas rotinas com modificações.
// Adaptar as rotinas comentadas para o novo Webservice,
// conforme o projeto for andando.
//===================================================================

Private _lHaDadosP := .F. // Indica se há dados dos produtores para Integração.
Private _lHaDadosC := .F. // Indica se há dados das coleta para Integração.
Private _nTotRegs  := 0
Private _aDadosTC  := {}   // Código e Loja de Produtores Titulares de Tanques coletivos já lidos do cadastro de produtores.
Private _cUnidVinc := SM0->M0_CGC // Unidade na qual os produtores e coletas estão vinculados.
Private _lJaTemAss := .F.
Private _cCodEvoMilk:="EVODEV"
Private _lEfetivaEnvio:=!SuperGetMV("IT_AMBTEST",.F.,.T.) .OR. FWGetRunSchedule()

Default _lSchedule := .F.

Begin Sequence

   //===================================================================
   // ATENÇÃO: O Webservice Evomilk irá substituir o App Cia do Leite.
   // Possui as mesmas rotinas com modificações.
   // Adaptar as rotinas comentadas para o novo Webservice,
   // conforme o projeto for andando.
   //===================================================================
   /*
   //=======================================================================
   // Envia Dados de Inclusões de Associação / Cooperativa
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o envio dos dados de inclusão das Associações / Cooperativas para o sistema da Evomilk?","Atenção" , , ,2, 2)
         _lEnvDadoS := .F.
      Else
         _lEnvDadoS := .T.
      EndIf
   Else
      U_ItConOut("[MGLT032] Enviando dados de inclusão das Associações / Cooperativas para o sistema da Evomilk")
   EndIf

   If ! _lSchedule
      If _lEnvDadoS
         ProcRegua(0)

         Processa( {|| U_MGLT03 2P(_lSchedule,"INCASS") } , 'Aguarde!' , 'Lendo dados das Associações / Cooperativa...' )
         If _lHaDadosP
            Processa( {|| U_MGLT 032K("M","INCASS")} , 'Aguarde!' , 'Enviando dados das Associações / Cooperativas...' )
         EndIf

         U_ItMsg("Envio dos dados das Associações / Cooperativas para o sistema Evomilk Concluido.","Atenção",,2)
      EndIf
   Else
      U_MGLT03 2P(_lSchedule,"INCASS")  // Faz a leitura dos dados.
      If _lHaDadosP
          U_MGLT 032K("S","INCASS")// Envia os dados dos Produtores via Integração WebService.
      EndIf

      U_ItConOut("[MGLT032] - Envio dos dados das Associações / Cooperativas para o sistema Evomilk Concluido.")
   EndIf

   //=======================================================================
   // Envia Dados de Alteração de Associação / Cooperativa
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o envio dos dados de alteração das Associações / Cooperativas para o sistema da Evomilk?","Atenção" , , ,2, 2)
         _lEnvDadoS := .F.
      Else
         _lEnvDadoS := .T.
      EndIf
   Else
      U_ItConOut("[MGLT032] Enviando dados de alterações das Associações / Cooperativas para o sistema da Evomilk")
   EndIf

   If ! _lSchedule
      If _lEnvDadoS
         ProcRegua(0)

         Processa( {|| U_MGLT03 2P(_lSchedule,"ALTASS") } , 'Aguarde!' , 'Lendo dados das Associações / Cooperativa...' )
         If _lHaDadosP
            Processa( {|| U_MGLT32UP("M","ALTASS")} , 'Aguarde!' , 'Enviando dados das Associações / Cooperativas...' )
         EndIf

         U_ItMsg("Envio dos dados das Associações / Cooperativas para o sistema Evomilk Concluido.","Atenção",,2)
      EndIf
   Else
      U_MGLT03 2P(_lSchedule,"ALTASS")  // Faz a leitura dos dados.
      If _lHaDadosP
          U_MGLT32UP("S","ALTASS") // Envia os dados dos Produtores via Integração WebService.
      EndIf

      U_ItConOut("[MGLT032] - Envio dos dados das Associações / Cooperativas para o sistema Evomilk Concluido.")
   EndIf
   */
   //=======================================================================
   // Envia Dados dos Produtores - INCLUSÃO DE PRODUTORES.
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o envio dos dados de INCLUSÃO dos produtores para o sistema da Evomilk?","Atenção" , , ,2, 2)
         _lEnvDadoP := .F.
      EndIf
   EndIf

   If ! _lSchedule
      If _lEnvDadoP

         _nTotRegs   := 0
         _cLidos     := ""
         _cLeuCapa   := ""
         _cLeuItens  := ""
         _nAceitos   := 0
         _nRejeitados:= 0

         Processa( {|| U_MGLT032P(_lSchedule,"I") } , 'Aguarde!' , 'Lendo dados dos Produtores...' )

         If _lHaDadosP  .AND. U_ITMSG("Confirma a quantidade do envio dos dados de INCLUSÃO dos produtores para o sistema da Evomilk?","Atenção" ,"Lidos: "+_cLidos+ " - Capa: "+_cLeuCapa+" - Detalhes "+_cLeuItens,3,2, 2)

            Processa( {|| U_MGLT032Q("M","I") } , 'Aguarde!' , 'Enviando dados dos Produtores...' ) //INCLUSÃO -  Envia os dados dos Produtores via Integração WebService. INCLUSÃO

            _cResultado:=" - Aceitos: "+ALLTRIM(STR(_nAceitos))+" - Rejeitados: "+ALLTRIM(STR(_nRejeitados))

            U_ItMsg("Envio dos dados dos Produtores para o sistema Evomilk CONCLUIDO.","Atenção","Lidos: "+_cLidos+ " - Capa: "+_cLeuCapa+" - Detalhes "+_cLeuItens+_cResultado,2)

         ElseIF !_lHaDadosP

            U_ItMsg("Não tem Produtores para processar.","Atenção",,1)

         EndIf

      EndIf
   Else
      U_MGLT032P(_lSchedule,"I")  // Faz a leitura dos dados.
      If _lHaDadosP
         U_MGLT032Q("S","I") //INCLUSÃO -  Envia os dados dos Produtores via Integração WebService. INCLUSÃO
      EndIf

   EndIf

   //=======================================================================
   // Envia Dados dos Produtores - ALTERAÇÃO DE PRODUTORES.
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o envio dos dados de ALTERAÇÃO dos produtores para o sistema da Evomilk?","Atenção" , , ,2, 2)
         _lEnvDadoP := .F.
      Else
         _lEnvDadoP := .T.
      EndIf
   EndIf

   If ! _lSchedule
      If _lEnvDadoP
         ProcRegua(0)

         _nTotRegs   := 0
         _cLidos     := ""
         _cLeuCapa   := ""
         _cLeuItens  := ""
         _nAceitos   := 0
         _nRejeitados:= 0

         Processa( {|| U_MGLT032P(_lSchedule,"A") } , 'Aguarde!' , 'Lendo dados dos Produtores...' )

         If _lHaDadosP .AND. U_ITMSG("Confirma a quantidade do envio dos dados de ALTERAÇÃO dos produtores para o sistema da Evomilk?","Atenção" ,"Lidos: "+_cLidos+ " - Capa: "+_cLeuCapa+" - Detalhes "+_cLeuItens,3,2, 2)

            Processa( {|| U_MGLT032Q("M","A") } , 'Aguarde!' , 'Enviando dados dos Produtores...' ) //ALTERAÇÃO - Envia os dados dos Produtores via Integração WebService.

            _cResultado:=" - Aceitos: "+ALLTRIM(STR(_nAceitos))+" - Rejeitados: "+ALLTRIM(STR(_nRejeitados))

            U_ItMsg("Envio dos dados dos Produtores para o sistema Evomilk CONCLUIDO.","Atenção","Lidos: "+_cLidos+ " - Capa: "+_cLeuCapa+" - Detalhes "+_cLeuItens+_cResultado,2)

         Elseif !_lHaDadosP

            U_ItMsg("Não tem Produtores para processar.","Atenção",,1)

         EndIf

      EndIf
   Else
      U_MGLT032P(_lSchedule,"A")  // Faz a leitura dos dados.
      If _lHaDadosP
         U_MGLT032Q("S","A") //ALTERAÇÃO -  Envia os dados dos Produtores via Integração WebService.
      EndIf

   EndIf

   //=======================================================================
   // ENVIA DADOS DOS VOLUMES COLETADOS.
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o envio dos dados das coletas de leite para o sistema da Evomilk?","Atenção" , , ,2, 2)
         _lEnvDadoC := .F.
      EndIf
   EndIf

   If ! _lSchedule
      If _lEnvDadoC
         ProcRegua(0)

         _nTotRegs   := 0
         _cLidos     := ""
         _cLeuVol    := ""
         _nAceitos   := 0
         _nRejeitados:= 0

         Processa( {|| U_MGLT032V(_lSchedule) } , 'Aguarde!' , 'Lendo dados das Coletas de Leite...' )
         If _lHaDadosC
            Processa( {|| U_MGLT032R("M") } , 'Aguarde!' , 'Enviando dados das Coletas de Leite...' ) // Envia os dados dos Produtores via Integração WebService.
         EndIf

         _cResultado:="Aceitos: "+ALLTRIM(STR(_nAceitos))+" - Rejeitados: "+ALLTRIM(STR(_nRejeitados))

         U_ItMsg("Envio dos dados dos Coletas de Leite para o sistema Evomilk CONCLUIDO.","Atenção","Lidos: "+_cLidos+ " - Volume: "+_cLeuVol+" - Detalhes: "+_cResultado,2)
         //U_ItMsg("Envio dos dados das Coletas de Leite para o sistema Evomilk Concluido.","Atenção",,2)
      EndIf
   Else
      U_MGLT032V(_lSchedule)  // Faz a leitura dos dados.
      If _lHaDadosC
         U_MGLT032R("S") // Envia os dados das Coletas via Integração WebService.
      EndIf

   EndIf

   //===================================================================
   // ATENÇÃO: O Webservice Evomilk irá substituir o App Cia do Leite.
   // Possui as mesmas rotinas com modificações.
   // Adaptar as rotinas comentadas para o novo Webservice,
   // conforme o projeto for andando.
   //===================================================================

/*
   //=======================================================================
   // Gera arquivo Texto com os Dados dos Produtores por filial ativos e
   // inativos para envio por e-mail.
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores Ativos e Inativos?","Atenção" , , ,2, 2)
         //Break
         _lEnvDadoI := .F.
      EndIf

      If _lEnvDadoI
         U_MGLT32TXT("PRODUTORES")
      EndIf
   EndIf

   //=======================================================================
   // Gera arquivo Texto com os Dados dos Produtores usuários de tanques
   // coletivos e familiares para envio por e-mail.
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores usuários de tanques coletivos e familiares, e seus vinculos com os titulares dos tanques?","Atenção" , , ,2, 2)
         _lEnvDadoT := .F.
      EndIf

      If _lEnvDadoT
         U_MGLT32CM()
      EndIf

   EndIf

   //==============================================================================
   // Gera arquivo Texto com os Dados dos Produtores com mais de uma
   // propriedade destacando que são produtores: NORMAIS, ASSOCIAÇÃO/COOPERATIVA.
   //==============================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores com mais de uma propriedade?","Atenção" , , ,2, 2)
         _lEnvDadoM := .F.
      EndIf

      If _lEnvDadoM
         U_MGLT32MP()
      EndIf

   EndIf

   //==============================================================================
   // Gera arquivo Texto com os Dados dos Produtores Rejeitados nas integrações
   //==============================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores rejeitados nas integrações?","Atenção" , , ,2, 2)
         _lEnvDadoR := .F.
      EndIf

      If _lEnvDadoR
         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Produtores Rejeitados"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Produtotes Rejeitados"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Produtores Rejeitados" , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32RJ(MV_PAR01,MV_PAR02) } , 'Aguarde!' , 'Gerando arquivo texto com Produtores rejeitados...' )

      EndIf

   EndIf

   //==============================================================================
   // Gera arquivo Texto com os Dados dos Produtores Aceitos nas integrações
   //==============================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores aceitos nas integrações?","Atenção" , , ,2, 2)
         _lEnvDadoA := .F.
      EndIf

      If _lEnvDadoA
         _aParAux := {}

         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Produtores Aceitos"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Produtores Aceitos"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Produtores Aceitos" , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32AC(MV_PAR01,MV_PAR02) } , 'Aguarde!' , 'Gerando arquivo texto com Produtores aceitos...' )

      EndIf

   EndIf

   //==============================================================================
   // Envia Produtores Titulares de Tanques Coletivos para o App Evomilk.
   //==============================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o Envio dos Dados dos Produtores Titulares de Tanques Coletivos?","Atenção" , , ,2, 2)
         _lEnvDadoU := .F.
      EndIf

      _lHaDadosP := .F.

      If _lEnvDadoU
          Processa( {|| U_MGLT0 32P(_lSchedule,"TIT_TC") } , 'Aguarde!' , 'Lendo Dados dos Produtores Titulares de Tanques Coletivos...' )   // Faz a leitura dos dados.
          If _lHaDadosP
             Processa( {||  U_MGLT 032Q("M","A","TIT_TC") } , 'Aguarde!' , 'Enviando Dados dos Produtores Titulares de Tanques Coletivos...' ) // Envia os dados dos Produtores Titulares de Tanques Coletivos via Integração WebService.
          EndIf

         U_ItMsg( "Envio dos dados dos Produtores Titulares de Tanques Coletivos para o sistema Evomilk CONCLUIDO." , "Atenção!",,1 )
      EndIf

   EndIf

   //==============================================================================
   // Envia Produtores Usuários de Tanques Coletivos para o App Evomilk.
   //==============================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o Envio dos Dados dos Produtores Usuários de Tanques Coletivos?","Atenção" , , ,2, 2)
         _lEnvDadoW := .F.
      EndIf

      _lHaDadosP := .F.

      If _lEnvDadoW
         Processa( {|| U_MGLT0 32P(_lSchedule,"USU_TC") } , 'Aguarde!' , 'Lendo Dados dos Produtores Usuários de Tanques Coletivos...' )   // Faz a leitura dos dados.
         If _lHaDadosP
            Processa( {|| U_MGLT 032Q("M","A","USU_TC") } , 'Aguarde!' , 'Enviando Dados dos Produtores Usuários de Tanques Coletivos...' ) // Envia os dados dos Produtores Titulares de Tanques Coletivos via Integração WebService.
         EndIf

         U_ItMsg( "Envio dos dados dos Produtores Usuários de Tanques Coletivos para o sistema Evomilk CONCLUIDO." , "Atenção!",,1 )
      EndIf

   EndIf

   //==============================================================================
   // Reenvia Produtores coformte listagem da Evomilk.
   //==============================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o Reenvio dos Dados dos Produtores conforme listagem, para o App Evomilk?","Atenção" , , ,2, 2)
         _lEnvDadoZ := .F.
      EndIf

      _lHaDadosP := .F.

      If _lEnvDadoZ
         Processa( {|| U_MGLT 032P(_lSchedule,"REENV_PROD") } , 'Aguarde!' , 'Lendo Dados dos Produtores para Reenvio a Evomilk...' )   // Faz a leitura dos dados.
         If _lHaDadosP
            Processa( {|| U_MGLT 032Q("M","A","REENV_PROD") } , 'Aguarde!' , 'Enviando Dados dos Produtores para Reenvio a Evomilk...' ) // Envia os dados dos Produtores Titulares de Tanques Coletivos via Integração WebService.
         EndIf

         U_ItMsg( "Reenvio dos dados dos Produtores para o sistema Evomilk concluido." , "Atenção!",,1 )
      EndIf

   EndIf

   //==============================================================================
   // Gera arquivo Texto com os Dados das Coletas Rejeitadas
   //==============================================================================
   If ! _lSchedule
      //If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Coletas das Associações rejeitados nas integrações?","Atenção" , , ,2, 2)
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Coletas rejeitadas nas integrações?","Atenção" , , ,2, 2)
         _lEnvDadoL := .F.
      EndIf

      If _lEnvDadoL

         _aParAux := {}
         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Coleta Rejeitada"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Coleta Rejeitada"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Coletas Rejeitadas " , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32CL("R") } , 'Aguarde!' , 'Gerando arquivo texto com as Coletas rejeitadas...' )

      EndIf
   EndIf

   //==============================================================================
   // Gera arquivo Texto com os Dados das Coletas Aceitas
   //==============================================================================
   If ! _lSchedule
      //If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Coletas das Associações rejeitados nas integrações?","Atenção" , , ,2, 2)
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Coletas Aceitas nas integrações?","Atenção" , , ,2, 2)
         _lEnvDadoY := .F.
      EndIf

      If _lEnvDadoY

         _aParAux := {}
         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Coleta Aceita"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Coleta Aceita"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Coletas Aceitas " , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32CL("A") } , 'Aguarde!' , 'Gerando arquivo texto com as Coletas aceitas...' )

      EndIf
   EndIf

   //=======================================================================
   // Reenvia Dados das Associação / Cooperativa
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o reenvio dos dados das Associações / Cooperativas para o sistema da Evomilk?","Atenção" , , ,2, 2)
         _lEnvDadoX := .F.
      Else
         _lEnvDadoX := .T.
      EndIf
    EndIf

   If ! _lSchedule
      If _lEnvDadoX
         ProcRegua(0)

         Processa( {|| U_MGLT 032P(_lSchedule,"REENVASS") } , 'Aguarde!' , 'Lendo dados das Associações / Cooperativa...' )
         If _lHaDadosP
            Processa( {|| U_MGLT 032K("S","REENVASS")} , 'Aguarde!' , 'Reenviando dados das Associações / Cooperativas...' )
         EndIf

         U_ItMsg("Reenvio dos dados das Associações / Cooperativas para o sistema Evomilk Concluido.","Atenção",,2)
      EndIf
   Else
      //====================================================================
      // Liga ou Desliga a integração Webservice via Scheduller
      //====================================================================
      _LigaDesRA := SUPERGETMV('IT_LIGREVA',.F.,  .F.)

      If _LigaDesRA // Liga / Desliga o reenvio de associação / cooperativa
         U_MGLT 032P(_lSchedule,"REENVASS")   // Lendo dados das Associações / Cooperativa.
         If _lHaDadosP
            U_MGLT 032K("S","REENVASS") // Reenviando dados das Associações / Cooperativas.
         EndIf

         U_ItConOut("[MGLT032] - Reenvio dos dados das Associações / Cooperativas para o sistema Evomilk Concluido.")

      EndIf

   EndIf

   //=======================================================================
   // Gera arquivo Texto com os Dados das Associações/Cooperativa e seus
   // associados/cooperado ativos e inativos para envio por e-mail.
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Associações/Cooperativas Ativas e Inativas?","Atenção" , , ,2, 2)
         _lEnvDadoB := .F.
      EndIf

      If _lEnvDadoB
         U_MGLT32TXT("ASSOCIACOES")
      EndIf
   EndIf

   //==============================================================================
   // Gera arquivo Texto com os Dados das Notas Fiscais/Demonstrativos rejeitados.
   //==============================================================================
   If ! _lSchedule

      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Notas Fiscais e Demonstrativos rejeitadas nas integrações?","Atenção" , , ,2, 2)
         _lEnvDadoN := .F.
      EndIf

      If _lEnvDadoN

         _aParAux := {}

         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Nota Fiscal/Demonstrativos Rejeitados"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Nota Fiscal/Demonstrativos Rejeitados"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Notas Fiscais/Demonstrativos Rejeitados " , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32NF("R") } , 'Aguarde!' , 'Gerando arquivo texto com as Notas Fiscais/Demonstrativos rejeitados...' )

      EndIf
   EndIf

   //==============================================================================
   // Gera arquivo Texto com os Dados das Notas Fiscais/Demonstrativos Aceitos
   //==============================================================================
   If ! _lSchedule

      If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Notas Fiscais e Demonstrativos aceitos nas integrações?","Atenção" , , ,2, 2)
         _lEnvDadoQ := .F.
      EndIf

      If _lEnvDadoQ

         _aParAux := {}

         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Nota Fiscal/Demonstrativos Aceitos"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Nota Fiscal/Demonstrativos Aceitos"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Notas Fiscais/Demonstrativos Aceitos " , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32NF("A") } , 'Aguarde!' , 'Gerando arquivo texto com as Notas Fiscais/Demonstrativos Aceitos...' )

      EndIf
   EndIf

   */

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032P
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de envio de dados dos produtores integração WebService para  Evomilk
===============================================================================================================================
Parametros---------: _lSchedule = .T. = Rotina chamada via Scheduller.
                                  = .F. = Rotina chamada via menu.
                     _cOpcao      = "I" = Roda a integração de Inclusão de produtores no App Evomilk.
                                  = "A" = Roda a integração de Alteração de produtores no App Evomilk.
                                  = "INCASS" = Inclusão de Produtores de Associação ou Cooperativa
                                  = "ALTASS" = Alteração de Produtores de Associação ou Cooperativa
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032P(_lSchedule,_cOpcao)// INCLUSAO E ALTERACAO
Local _aStruct := {}
Local _aStruct2 := {}
Local _aStruct3 := {}
Local _cCodForn
Local _cFilEnvio := xFilial("ZL3")
Local _lNovoGrupo := .T.

Default _lSchedule := .F.
Default _cOpcao := "I"

Begin Sequence

   If ! _lSchedule
      IncProc("Gerando dados dos Produtores para envio...")
   EndIf

   //==========================================================================
   // Cria Tabela Temporária para atualização do SA2
   //==========================================================================
   _aStruct3 := {}
   Aadd(_aStruct3,{"A2_COD"    ,"C",6  ,0})  // matricula_laticinio: TESTE_278363
   Aadd(_aStruct3,{"A2_LOJA"   ,"C",4  ,0})  // Loja_laticinio: TESTE_278363
   Aadd(_aStruct3,{"A2_L_FAZEN","C",60 ,0})  // Nome da Fazenda
   Aadd(_aStruct3,{"WK_RECNO"  ,"N",10 ,0})  // Nr Recno SA2

   If Select("TRBSA2") > 0
      TRBSA2->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCABA criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp := FWTemporaryTable():New( "TRBSA2",  _aStruct3 )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp:AddIndex( "01", {"A2_COD","A2_LOJA"} )
   _oTemp:Create()

   DBSelectArea("TRBSA2")

   //==========================================================================
   // Cria Tabela Temporária para armazenar dados do JSon
   //==========================================================================
   _aStruct := {}
   Aadd(_aStruct,{"A2_COD"    ,"C",6  ,0})  // matricula_laticinio:
   Aadd(_aStruct,{"A2_LOJA"   ,"C",4  ,0})  // Loja_laticinio:
   Aadd(_aStruct,{"A2_NOME"   ,"C",40 ,0})  // nome_razao_social
   Aadd(_aStruct,{"A2_CGC"    ,"C",14 ,0})  // cpf_cnpj: 349.812.172-34
   Aadd(_aStruct,{"A2_INSCR"  ,"C",18 ,0})  // inscricao_estadual:
   Aadd(_aStruct,{"A2_PFISICA","C",18 ,0})  // rg_ie: ABC320303
   Aadd(_aStruct,{"A2_DTNASC" ,"D",8  ,0})  // data_nascimento_fundacao: 1994-10-10
   Aadd(_aStruct,{"WK_OBSERV" ,"C",100,0})  // info_adicional: Observação / info adicional...
   Aadd(_aStruct,{"A2_ENDCOMP","C",50 ,0})  // complemento:
   Aadd(_aStruct,{"A2_END"    ,"C",90 ,0})  // endereco
   Aadd(_aStruct,{"WK_NUMERO" ,"C",20 ,0})  // numero
   Aadd(_aStruct,{"A2_BAIRRO" ,"C",50 ,0})  // bairro
   Aadd(_aStruct,{"A2_CEP"    ,"C",8  ,0})  // cep
   Aadd(_aStruct,{"WK_ID_UF"  ,"C",2  ,0})  // id_uf: 21
   Aadd(_aStruct,{"A2_COD_MUN","C",5  ,0})  // id_cidade: 73
   Aadd(_aStruct,{"A2_MUN"    ,"C",50 ,0})  // municipio
   Aadd(_aStruct,{"A2_EST"    ,"C",2  ,0})  // estado
   Aadd(_aStruct,{"A2_BANCO"  ,"C",3  ,0})  // codigo do banco
   Aadd(_aStruct,{"A2_AGENCIA","C",5  ,0})  // codigo da agencia
   Aadd(_aStruct,{"A2_NUMCON" ,"C",12 ,0})  // numero da conta
   Aadd(_aStruct,{"A2_EMAIL"  ,"C",100,0})  // email
   Aadd(_aStruct,{"A2_DDD"    ,"C",3,0})    // celular1: 95920298034
   Aadd(_aStruct,{"A2_TEL"    ,"C",50,0})   // celular1: 95920298034
   Aadd(_aStruct,{"A2_TEL2"   ,"C",50,0})   // celular2: null
   Aadd(_aStruct,{"A2_TEL3"   ,"C",50,0})   // telefone1: 5590038949
   Aadd(_aStruct,{"A2_TEL4"   ,"C",50,0})   // telefone2: null
   Aadd(_aStruct,{"A2_TEL1W"  ,"C",50,0})   // celular1_whatsapp: true
   Aadd(_aStruct,{"A2_TEL2W"  ,"C",50,0})   // celular2_whatsapp: false
//-----------------------------------------------------------------------------
   Aadd(_aStruct,{"WK_TIPOPRO","C",10 ,0})  // ASSOCIACAO/ASSOCIADO
   Aadd(_aStruct,{"A2_L_TPASS","C",1  ,0})  // Tipo Associação
//-----------------------------------------------------------------------------
   Aadd(_aStruct,{"WK_ORDEMP" ,"C",1 ,0})   // Ordenação Produtor para envio.
   Aadd(_aStruct,{"WK_RECNO"  ,"N",10 ,0})  // Nr Recno SA2
   Aadd(_aStruct,{"A2_L_ATIVO","C",10 ,0})  // situacao  // Ativo / Inativo

   If Select("TRBCAB") > 0
      TRBCAB->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCAB criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp := FWTemporaryTable():New( "TRBCAB",  _aStruct )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp:AddIndex( "01", {"A2_COD"} )
   _oTemp:AddIndex( "02", {"A2_CGC"} )
   _oTemp:AddIndex( "03", {"WK_ORDEMP","A2_COD","A2_LOJA"} )
   _oTemp:Create()

   DBSelectArea("TRBCAB")

   _aStruct2 := {}
   Aadd(_aStruct2,{"A2_COD"    ,"C",6  ,0})  // matricula_laticinio: TESTE_278363
   Aadd(_aStruct2,{"A2_LOJA"   ,"C",4  ,0})  // Loja_laticinio: TESTE_278363
   Aadd(_aStruct2,{"A2_CGC"    ,"C",14 ,0})  // cpf_cnpj: 349.812.172-34
   Aadd(_aStruct2,{"A2_L_FAZEN","C",40 ,0})  // nome_propriedade_rural: PROPRIEDADE TESTE 001
   Aadd(_aStruct2,{"A2_L_NIRF" ,"C",11 ,0})  // NIRF: ABC4658
   Aadd(_aStruct2,{"A2_L_TANQ" ,"C",6  ,0})  // id_tipo_tanque: 1
   Aadd(_aStruct2,{"A2_L_TANLJ","C",4  ,0})  // Loja Tanque
   Aadd(_aStruct2,{"A2_L_CAPTQ","N",11 ,0})  // capacidade_tanque: 720
   Aadd(_aStruct2,{"A2_L_LATIT","N",10 ,6})  // latitude_propriedade: -17.855250
   Aadd(_aStruct2,{"A2_L_LONGI","N",10 ,6})  // longitude_propriedade: -46.223278
   Aadd(_aStruct2,{"A2_L_MARTQ","C",20 ,0})  // Marca do Tanque
   Aadd(_aStruct2,{"A2_L_CLASS","C",01 ,0})  // id_tipo_tanque
//----------------------------------------------------------------------------------
   Aadd(_aStruct2,{"A2_L_LI_RO","C",06 ,0})  // Código_Linha_Rota
   Aadd(_aStruct2,{"ZL3_DESCRI","C",40 ,0})  // Descrição_Linha_Rota
//----------------------------------------------------------------------------------
   Aadd(_aStruct2,{"WK_AREA"   ,"N",12 ,6})  // area: 2000.15
   Aadd(_aStruct2,{"WK_RECRIA" ,"C",10 ,0})  // recria: 1
   Aadd(_aStruct2,{"WK_VACASEC","C",10 ,0})  // vaca_seca: 12
   Aadd(_aStruct2,{"WK_VACALAC","C",10 ,0})  // vaca_lactacao: 6
   Aadd(_aStruct2,{"WK_HORACOL","C",10 ,0})  // horario_coleta: 23:59
   Aadd(_aStruct2,{"WK_RACAPRO","C",50 ,0})  // raca_propriedade: Nome Raça predominante Teste
   Aadd(_aStruct2,{"A2_L_FREQU","C",10 ,0})  // frequencia_coleta: 17
   Aadd(_aStruct2,{"WK_PRDDIAR","N",10 ,2})  // fproducao_media_diaria: 7251.31
   Aadd(_aStruct2,{"WK_AREAUTI","N",10 ,2})  // area_utilizada_producao: 837.84
   //Aadd(_aStruct2,{"WK_CAPREFR","N",10 ,2})  // capacidade_refrigeracao: 307
   Aadd(_aStruct2,{"A2_L_CAPAC","C",01 ,0})  // capacidade_refrigeracao: 307
   Aadd(_aStruct2,{"A2_L_ATIVO","C",10 ,0})  // situacao  // Ativo / Inativo
   Aadd(_aStruct2,{"A2_L_SIGSI","C",11 ,0})  // SigSif
   Aadd(_aStruct2,{"A2_L_RESFR","C",1  ,0})  // id_tab_tanque_tipo_resfriamento
//---------------------------------------------------------------------------------
   Aadd(_aStruct2,{"A2_ENDCOMP","C",50 ,0})  // complemento: Complemento Teste
   Aadd(_aStruct2,{"A2_END"    ,"C",90 ,0})  // endereco: Rua Caminho Andante
   Aadd(_aStruct2,{"WK_NUMERO" ,"C",20 ,0})  // numero: 429 A
   Aadd(_aStruct2,{"A2_BAIRRO" ,"C",50 ,0})  // bairro: Bairro Teste
   Aadd(_aStruct2,{"A2_CEP"    ,"C",8  ,0})  // cep: 51462-745
   Aadd(_aStruct2,{"A2_COD_MUN","C",5  ,0})  // id_cidade: 73
   Aadd(_aStruct2,{"A2_MUN"    ,"C",50 ,0})  // municipio
   Aadd(_aStruct2,{"A2_EST"    ,"C",2  ,0})  // estado
   Aadd(_aStruct2,{"A2_EMAIL"  ,"C",100,0})  // email: TESTE_278363@email.com
   Aadd(_aStruct2,{"A2_DDD"    ,"C",3  ,0})  // celular1: 95920298034
   Aadd(_aStruct2,{"A2_TEL"    ,"C",50 ,0})  // celular1: 95920298034
   Aadd(_aStruct2,{"A2_L_NATRA","C",50 ,0})  // Nome Atravessador
   Aadd(_aStruct2,{"A2_L_TPASS","C",1 ,0})   // Tipo Associação
//---------------------------------------------------------------------------------
   Aadd(_aStruct2,{"WK_TIPOPRO","C",10 ,0})  // ASSOCIACAO/ASSOCIADO
//---------------------------------------------------------------------------------
   Aadd(_aStruct2,{"WK_ORDEMP" ,"C",1  ,0})  // Ordenação Produtor para envio.
   Aadd(_aStruct2,{"WK_RECNO"  ,"N",10 ,0})  // Nr Recno SA2
   Aadd(_aStruct2,{"WK_REGCAB" ,"N",10 ,0})  // Nr Recno TRBCAB

   If Select("TRBDET") > 0
      TRBDET->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBDET criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp2 := FWTemporaryTable():New( "TRBDET",  _aStruct2 )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp2:AddIndex( "01", {"A2_COD"})
   _oTemp2:AddIndex( "02", {"A2_COD","A2_LOJA"})
   _oTemp2:AddIndex( "03", {"A2_CGC"})
   _oTemp2:AddIndex( "04", {"WK_ORDEMP","A2_COD","A2_LOJA"} )
   _oTemp2:Create()

   DBSelectArea("TRBDET")

   //================================================================================
   // Opção de Envio de Usuários de Tanques Coletivos.
   //================================================================================
   If _cOpcao == "USU_TC"
      MGLT32USTC()
      Break
   EndIf

   //================================================================================
   // Reenvia Produtores para o App, conforme Listagem.
   //================================================================================
   If _cOpcao == "REENV_PROD"
      MGLT32RENV()
      Break
   EndIf

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   _cQry := " SELECT DISTINCT A2_COD, "  // matricula_laticinio: TESTE_278363
   _cQry += " A2_NOME, "                 // nome_razao_social  : PRODUTOR TESTE 3337
   _cQry += " A2_CGC, "                  // cpf_cnpj: 349.812.172-34
   _cQry += " A2_INSCR, "                // inscricao_estadual: 170642
   _cQry += " A2_PFISICA, "              // rg_ie: ABC320303
   _cQry += " A2_DTNASC, "               // data_nascimento_fundacao: 1994-10-10
   _cQry += " A2_ENDCOMP, "              // complemento: Complemento Teste
   _cQry += " A2_END, "                  // endereco: Rua Caminho Andante
   _cQry += " A2_BAIRRO, "               // bairro: Bairro Teste
   _cQry += " A2_CEP, "                  // cep: 51462-745
   _cQry += " A2_COD_MUN, "              // id_cidade: 73
   _cQry += " A2_MUN, "                  // municipio
   _cQry += " A2_EST, "                  // estado
   _cQry += " A2_EMAIL, "                // email: TESTE_278363@email.com
   _cQry += " A2_DDD, "                  // DDD
   _cQry += " A2_TEL, "                  // celular1: 95920298034
   _cQry += " A2_LOJA, "                 // Loja_laticinio: TESTE_278363
//---------------------------------------------------------------------------------------
   _cQry += " A2_BANCO, "                // codigo do banco
   _cQry += " A2_AGENCIA, "              // codigo da agencia
   _cQry += " A2_NUMCON, "               // numero da conta
//---------------------------------------------------------------------------------------
   _cQry += " A2_L_FAZEN, "              // nome_propriedade_rural: PROPRIEDADE TESTE 001
   _cQry += " A2_L_NIRF, "               // NIRF: ABC4658
   _cQry += " A2_L_TANQ, "               // id_tipo_tanque: 1
   _cQry += " A2_L_CAPTQ, "              // capacidade_tanque: 720
   _cQry += " A2_L_LATIT, "              // latitude_propriedade: -17.855250
   _cQry += " A2_L_LONGI, "              // longitude_propriedade: -46.223278
   _cQry += " A2_L_FREQU, "              // frequencia_coleta: 17
   _cQry += " A2_L_MARTQ, "              // Marca do Tanque
   _cQry += " A2_L_CAPAC, "              // capacidade_refrigeracao: 307
   _cQry += " A2_L_CLASS, "              // id_tipo_tanque
   _cQry += " A2_L_ATIVO, "              // ativo inativo
   _cQry += " A2_L_SIGSI, "              //
   _cQry += " A2_L_TANLJ, "              //
   _cQry += " A2_L_RESFR, "              //
   _cQry += " A2_L_NATRA, "              // Nome Atravessador
   _cQry += " A2_L_TPASS, "              // Tipo Associação
//----------------------------------------------------------------------------
   _cQry += " A2_L_LI_RO, "
   _cQry += " ZL3_DESCRI, "
//----------------------------------------------------------------------------
   _cQry += " SA2.R_E_C_N_O_ AS NRREG, "
//--------------------------------------------------------------------------------
   _cQry += " CASE "
   _cQry += "     WHEN A2_L_CLASS = 'C' THEN 'B' "
   _cQry += "     WHEN A2_L_CLASS = 'U' THEN 'C' "
   _cQry += "     WHEN A2_L_CLASS = 'F' THEN 'D' "
   _cQry += "     ELSE 'A' "
   _cQry += " END AS ORDEMP"

   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZL3_COD = A2_L_LI_RO "

   _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' " // Cada filial/Cnpj Italac possui um Usuário e Senha. Ler do cadastro empresas Webservice. Enviar apenas as filias 01, 04, 23. 01=Corumbaiba/GO, 04=Araguari/MG, 23=Tapejara/RS

   If _cOpcao == "I"          // Inclusão de Produtores
      _cQry += " AND (SA2.A2_L_ENVEV = ' ' OR  SA2.A2_L_ENVEV = 'S') "//AND (SA2.A2_L_NFPRO <> 'S' OR (SA2.A2_L_NFPRO = 'S' AND Length(Trim(SA2.A2_CGC))  < 14 ) ) " // Quando SA2.A2_L_NFPRO = 'S' é Associação/Cooperativa não enviar nesta opção.
   ElseIf _cOpcao == "A"      // Alteração de Produtores
      _cQry += " AND  SA2.A2_L_ENVEV = 'N' AND SA2.A2_L_ENVAT = 'S' " //AND (SA2.A2_L_NFPRO <> 'S' OR (SA2.A2_L_NFPRO = 'S' AND Length(Trim(SA2.A2_CGC))  < 14 ) ) "      // Quando SA2.A2_L_NFPRO = 'S' é Associação/Cooperativa não enviar nesta opção.
   ElseIf _cOpcao == "INCASS" // Inclusão de Associação / Cooperativa
      _cQry += " AND (SA2.A2_L_ENVEV = ' ' OR SA2.A2_L_ENVEV = 'S') AND SA2.A2_L_NFPRO = 'S' AND   Length(Trim(SA2.A2_CGC))  = 14 "  // Quando SA2.A2_L_NFPRO = 'S' é Associação/Cooperativa.
   ElseIf _cOpcao == "ALTASS" // Alteração de Associação / Cooperativa
      _cQry += " AND  SA2.A2_L_ENVEV = 'N' AND A2_L_ENVAT = 'S' AND SA2.A2_L_NFPRO = 'S' AND   Length(Trim(SA2.A2_CGC))  = 14 "       // Quando SA2.A2_L_NFPRO = 'S' é Associação/Cooperativa.
   ElseIf _cOpcao == "TIT_TC" // Alteração de Titular Tanques Coletivos
      _cQry += " AND  SA2.A2_L_CLASS = 'C' "
   ElseIf _cOpcao == "REENVASS" // Reenvio de Associação / Cooperativa
      _cQry += " AND  SA2.A2_L_NFPRO = 'S' AND   Length(Trim(SA2.A2_CGC))  = 14 "  // Quando SA2.A2_L_NFPRO = 'S' é Associação/Cooperativa.
   EndIf

   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "

   If _cOpcao == "I"  // Inclusão
      _cQry += " AND A2_L_ATIVO = 'S' "  // Não Enviar inativos.
   EndIf
   IF !_lEfetivaEnvio
      _cQry += " AND A2_L_ATIVO = 'N' "  // Enviar inativos PARA TESTES.
   ENDIF

   _cQry += " AND A2_COD <> '      ' " // Foi identificado no cadastro de fornecedores alguns registros sem o código preenchido.

   _cProdTeste:=""//para teste no debug
   IF !EMPTY(_cProdTeste)
      _cQry += " AND A2_COD in ("+_cProdTeste+") "
   Endif

   If (_cOpcao == "INCASS" .Or. _cOpcao == "ALTASS" .Or. _cOpcao == "REENVASS")
      If _cOpcao == "INCASS" .Or. _cOpcao == "REENVASS"
         _cQry += " AND A2_L_ATIVO <> 'N' "  // Não Enviar inativos na inclusão.
      EndIf

      _cQry += " ORDER BY A2_COD,A2_LOJA "
   Else
      _cQry += " ORDER BY ORDEMP, A2_COD,A2_LOJA "
   EndIf

   If Select("QRYSA2") > 0
      QRYSA2->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYSA2")
   DBSelectArea("QRYSA2")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
   Count To _nTotRegs

   If !_lSchedule
      ProcRegua(_nTotRegs)
   ENDIF
   _cTot:=ALLTRIM(STR(_nTotRegs))
   _cLidos:= _cTot
   nConta:=0

   _cCodForn := Space(6)

   QRYSA2->(DbGotop())

   Do While ! QRYSA2->(Eof())
      nConta++
      If !_lSchedule
         IncProc("Lendo Produtores: "+STRZERO(nConta,5) +" de "+ _cTot)
      ENDIF

      //=============================================================================
      // Quando um Produtor com CPF está cadastrado com Emite nota Propria igual a
      // Sim, o cadastro está errado. Filtrar este produtor.
      //=============================================================================
      If (_cOpcao == "INCASS" .Or. _cOpcao == "ALTASS" .Or. _cOpcao == "REENVASS")
         If Len(AllTrim(QRYSA2->A2_CGC)) < 14
            QRYSA2->(DbSkip())
            Loop
         EndIf
      EndIf

      //========================================================
      // Mudança de código de Associação / Cooperativa
      //========================================================
      If (_cOpcao == "INCASS" .Or. _cOpcao == "ALTASS" .Or. _cOpcao == "REENVASS")
         _lNovoGrupo := .F.
      EndIf

      //=============================================================================
      // Grava as tabelas temporárias para envio dos dados
      //=============================================================================
      If _cCodForn <> QRYSA2->A2_COD .And. _cOpcao <> "ALTASS"
         _cCodForn := QRYSA2->A2_COD

         TRBCAB->(DBAPPEND())
         TRBCAB->A2_COD     := QRYSA2->A2_COD            // id_tipo_tanque: 1
         TRBCAB->A2_LOJA    := QRYSA2->A2_LOJA
         TRBCAB->A2_NOME    := STRTRAN(QRYSA2->A2_NOME,'"'," ")  //C,40  // nome_razao_social  : PRODUTOR TESTE 3337
         TRBCAB->A2_CGC     := QRYSA2->A2_CGC            //C,14  // cpf_cnpj: 349.812.172-34
         TRBCAB->A2_INSCR   := QRYSA2->A2_INSCR          //C,18  // inscricao_estadual: 170642
         TRBCAB->A2_PFISICA := QRYSA2->A2_PFISICA        //C,18  // rg_ie: ABC320303
         TRBCAB->A2_DTNASC  := Stod(QRYSA2->A2_DTNASC)   //D,8   // data_nascimento_fundacao: 1994-10-10
         TRBCAB->WK_OBSERV  := ""                        //C,100 // info_adicional: Observação / info adicional...
         TRBCAB->A2_ENDCOMP := STRTRAN(QRYSA2->A2_ENDCOMP,'"'," ")        //C,50  // complemento: Complemento Teste
         TRBCAB->A2_END     := STRTRAN(QRYSA2->A2_END,'"'," ")            //C,90  // endereco: Rua Caminho Andante
         TRBCAB->WK_NUMERO  := ""                        //C,20  // numero: 429 A
         TRBCAB->A2_BAIRRO  := STRTRAN(QRYSA2->A2_BAIRRO,'"'," ")         //C,50  // bairro: Bairro Teste
         TRBCAB->A2_CEP     := QRYSA2->A2_CEP            //C,8   // cep: 51462-745
         TRBCAB->WK_ID_UF   := ""                        //C,2   // id_uf: 21
         TRBCAB->A2_COD_MUN := QRYSA2->A2_COD_MUN        //C,5   // id_cidade: 73
         TRBCAB->A2_MUN     := QRYSA2->A2_MUN            // municipio
         TRBCAB->A2_EST     := QRYSA2->A2_EST            // estado
         TRBCAB->A2_BANCO   := QRYSA2->A2_BANCO          // codigo do banco
         TRBCAB->A2_AGENCIA := QRYSA2->A2_AGENCIA        // codigo da agencia
         TRBCAB->A2_NUMCON  := QRYSA2->A2_NUMCON         // numero da conta
         TRBCAB->A2_EMAIL   := QRYSA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
         TRBCAB->A2_TEL     := AllTrim(QRYSA2->A2_DDD)+QRYSA2->A2_TEL //C,50  // celular1: 95920298034
         TRBCAB->A2_TEL2    := ""                        //C,50  // celular2: null
         TRBCAB->A2_TEL3    := ""                        //C,50  // telefone1: 5590038949
         TRBCAB->A2_TEL4    := ""                        //C,50  // telefone2: null
         TRBCAB->A2_TEL1W   := "False"                   //C,50  // celular1_whatsapp: true
         TRBCAB->A2_TEL2W   := "False"                   //C,50  // celular2_whatsapp: false
         TRBCAB->WK_RECNO   := QRYSA2->NRREG             //N,10 ,0 // Nr Recno SA2
         TRBCAB->WK_ORDEMP  := QRYSA2->ORDEMP            // Ordenação dos dados para envio
         TRBCAB->A2_L_ATIVO := If(QRYSA2->A2_L_ATIVO=="N","false","true") // _cSituacao
         TRBCAB->A2_L_TPASS := QRYSA2->A2_L_TPASS        // Tipo Associação


         _lJaTemAss := U_MGLT32WM(TRBCAB->A2_COD, TRBCAB->A2_LOJA, TRBCAB->A2_CGC) // Retorna se já tem Associação/Cooperativa cadastrada.

         //========================================================
         // Mudança de código de Associação / Cooperativa
         //========================================================
         If (_cOpcao == "INCASS" .Or. _cOpcao == "ALTASS" .Or. _cOpcao == "REENVASS")
            If _cOpcao == "INCASS"
               If ! _lJaTemAss // Se não existir nenhuma associação cadastrada é novo grupo, inclui uma Associação.
                  _lNovoGrupo := .T.
               Else  // Se não existir é um associado.
                  _lNovoGrupo := .F.
               EndIf
            Else
               _lNovoGrupo := .T.
            EndIf
         EndIf

      ElseIf _cOpcao == "ALTASS"

         TRBCAB->(DBAPPEND())
         TRBCAB->A2_COD     := QRYSA2->A2_COD            // id_tipo_tanque: 1
         TRBCAB->A2_LOJA    := QRYSA2->A2_LOJA
         TRBCAB->A2_NOME    := QRYSA2->A2_NOME           //C,40  // nome_razao_social  : PRODUTOR TESTE 3337
         TRBCAB->A2_CGC     := QRYSA2->A2_CGC            //C,14  // cpf_cnpj: 349.812.172-34
         TRBCAB->A2_INSCR   := QRYSA2->A2_INSCR          //C,18  // inscricao_estadual: 170642
         TRBCAB->A2_PFISICA := QRYSA2->A2_PFISICA        //C,18  // rg_ie: ABC320303
         TRBCAB->A2_DTNASC  := Stod(QRYSA2->A2_DTNASC)   //D,8   // data_nascimento_fundacao: 1994-10-10
         TRBCAB->WK_OBSERV  := ""                        //C,100 // info_adicional: Observação / info adicional...
         TRBCAB->A2_ENDCOMP := STRTRAN(QRYSA2->A2_ENDCOMP,'"'," ")        //C,50  // complemento: Complemento Teste
         TRBCAB->A2_END     := STRTRAN(QRYSA2->A2_END,'"'," ")            //C,90  // endereco: Rua Caminho Andante
         TRBCAB->WK_NUMERO  := ""                        //C,20  // numero: 429 A
         TRBCAB->A2_BAIRRO  := STRTRAN(QRYSA2->A2_BAIRRO,'"'," ")         //C,50  // bairro: Bairro Teste
         TRBCAB->A2_CEP     := QRYSA2->A2_CEP            //C,8   // cep: 51462-745
         TRBCAB->WK_ID_UF   := ""                        //C,2   // id_uf: 21
         TRBCAB->A2_COD_MUN := QRYSA2->A2_COD_MUN        //C,5   // id_cidade: 73
         TRBCAB->A2_MUN     := QRYSA2->A2_MUN            // municipio
         TRBCAB->A2_EST     := QRYSA2->A2_EST            // estado
         TRBCAB->A2_BANCO   := QRYSA2->A2_BANCO          // codigo do banco
         TRBCAB->A2_AGENCIA := QRYSA2->A2_AGENCIA        // codigo da agencia
         TRBCAB->A2_NUMCON  := QRYSA2->A2_NUMCON         // numero da conta
         TRBCAB->A2_EMAIL   := QRYSA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
         TRBCAB->A2_TEL     := AllTrim(QRYSA2->A2_DDD)+QRYSA2->A2_TEL //C,50  // celular1: 95920298034
         TRBCAB->A2_TEL2    := ""                        //C,50  // celular2: null
         TRBCAB->A2_TEL3    := ""                        //C,50  // telefone1: 5590038949
         TRBCAB->A2_TEL4    := ""                        //C,50  // telefone2: null
         TRBCAB->A2_TEL1W   := "False"                   //C,50  // celular1_whatsapp: true
         TRBCAB->A2_TEL2W   := "False"                   //C,50  // celular2_whatsapp: false
         TRBCAB->WK_RECNO   := QRYSA2->NRREG             //N,10 ,0 // Nr Recno SA2
         TRBCAB->WK_ORDEMP  := QRYSA2->ORDEMP            // Ordenação dos dados para envio
         TRBCAB->A2_L_ATIVO := If(QRYSA2->A2_L_ATIVO=="N","false","true") // _cSituacao
         TRBCAB->A2_L_TPASS := QRYSA2->A2_L_TPASS        // Tipo Associação

      EndIf

      TRBDET->(DbAppend())
      TRBDET->A2_COD     := QRYSA2->A2_COD  // QRYSA2->A2_L_TANQ      // QRYSA2->A2_COD         //C,6     // matricula_laticinio: TESTE_278363
      TRBDET->A2_LOJA    := QRYSA2->A2_LOJA // QRYSA2->A2_L_TANLJ     // QRYSA2->A2_LOJA        //C,4     // Loja_laticinio: TESTE_278363
      TRBDET->A2_CGC     := QRYSA2->A2_CGC         //C,14    // cpf_cnpj: 349.812.172-34
      TRBDET->A2_L_FAZEN := STRTRAN(QRYSA2->A2_L_FAZEN,'"'," ")     //C,40    // nome_propriedade_rural: PROPRIEDADE TESTE 001
      TRBDET->A2_L_NIRF  := QRYSA2->A2_L_NIRF      //C,11    // NIRF: ABC4658
      TRBDET->A2_L_TANQ  := QRYSA2->A2_L_TANQ      //C,10    // id_tipo_tanque: 1
      TRBDET->A2_L_CAPTQ := QRYSA2->A2_L_CAPTQ     //N,11    // capacidade_tanque: 720
      TRBDET->A2_L_LATIT := QRYSA2->A2_L_LATIT     //N,10 ,6 // latitude_propriedade: -17.855250
      TRBDET->A2_L_LONGI := QRYSA2->A2_L_LONGI     //N,10 ,6 // longitude_propriedade: -46.223278
      TRBDET->A2_L_MARTQ := QRYSA2->A2_L_MARTQ     //C,20    // id_tipo_tanque: // Marca do tanque
      TRBDET->A2_L_CLASS := QRYSA2->A2_L_CLASS     //C,01    // id_tipo_tanque:
      TRBDET->WK_AREA    := 0                      //N,12 ,6 // area: 2000.15
      TRBDET->WK_RECRIA  := ""                     //C,10    // recria: 1
      TRBDET->WK_VACASEC := ""                     //C,10    // vaca_seca: 12
      TRBDET->WK_VACALAC := ""                     //C,10    // vaca_lactacao: 6
      TRBDET->WK_HORACOL := ""                     //C,10    // horario_coleta: 23:59
      TRBDET->WK_RACAPRO := ""                     //C,50    // raca_propriedade: Nome Raça predominante Teste
      TRBDET->A2_L_FREQU := QRYSA2->A2_L_FREQU     //C,10    // frequencia_coleta: 17
      TRBDET->WK_PRDDIAR := 0                      //N,10 ,2 // fproducao_media_diaria: 7251.31
      TRBDET->WK_AREAUTI := 0                      //N,10 ,2 // area_utilizada_producao: 837.84
      TRBDET->A2_L_CAPAC := QRYSA2->A2_L_CAPAC     //N,10 ,2 // capacidade_refrigeracao: 307
      TRBDET->WK_RECNO   := QRYSA2->NRREG          //N,10 ,0 // Nr Recno SA2
      //-------------------------------------------------------
      TRBDET->A2_L_LI_RO := QRYSA2->A2_L_LI_RO     //        codigo_linha_laticinio
      TRBDET->ZL3_DESCRI := QRYSA2->ZL3_DESCRI     //        nome_linha
      TRBDET->A2_L_ATIVO := If(QRYSA2->A2_L_ATIVO="N","false","true") // _cSituacao
      TRBDET->A2_L_SIGSI := QRYSA2->A2_L_SIGSI     // _cSigSif
      TRBDET->A2_L_TANLJ := QRYSA2->A2_L_TANLJ     // Loja tanque
      TRBDET->A2_L_RESFR := QRYSA2->A2_L_RESFR     // _cTipoResf
      //-------------------------------------------------------
      TRBDET->A2_ENDCOMP := STRTRAN(QRYSA2->A2_ENDCOMP,'"'," ")        //C,50  // complemento: Complemento Teste
      TRBDET->A2_END     := STRTRAN(QRYSA2->A2_END,'"'," ")            //C,90  // endereco: Rua Caminho Andante
      TRBDET->WK_NUMERO  := ""                        //C,20  // numero: 429 A
      TRBDET->A2_BAIRRO  := STRTRAN(QRYSA2->A2_BAIRRO,'"'," ")         //C,50  // bairro: Bairro Teste
      TRBDET->A2_CEP     := QRYSA2->A2_CEP            //C,8   // cep: 51462-74
      TRBDET->A2_COD_MUN := QRYSA2->A2_COD_MUN        //C,5   // id_cidade: 73
      TRBDET->A2_MUN     := QRYSA2->A2_MUN            // municipio
      TRBDET->A2_EST     := QRYSA2->A2_EST            // estado
      TRBDET->A2_EMAIL   := QRYSA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
      TRBDET->A2_TEL     := AllTrim(QRYSA2->A2_DDD)+QRYSA2->A2_TEL //C,50  // celular1: 95920298034
      TRBDET->A2_L_NATRA := STRTRAN(QRYSA2->A2_L_NATRA,'"'," ")        //Nome Atravessador
      TRBDET->A2_L_TPASS := QRYSA2->A2_L_TPASS        // Tipo Associação
      TRBDET->WK_REGCAB  := TRBCAB->(Recno())         // Recno do TRBCAB para alterações.

      //========================================================
      // Mudança de código de Associação / Cooperativa
      //========================================================
      If (_cOpcao == "INCASS" .Or. _cOpcao == "ALTASS" .Or. _cOpcao == "REENVASS")
         If _lNovoGrupo
            _lNovoGrupo := .F.
            TRBDET->WK_TIPOPRO := "ASSOCIACAO"
         Else
            TRBDET->WK_TIPOPRO := "ASSOCIADO"
         EndIf
      EndIf

      TRBDET->WK_ORDEMP  := QRYSA2->ORDEMP         // Ordenação dos dados para envio

      _lHaDadosP := .T.

      If _cOpcao == "TIT_TC" // Alteração de Titular Tanques Coletivos
         Aadd(_aDadosTC, {QRYSA2->A2_COD , QRYSA2->A2_LOJA})
      EndIf

      QRYSA2->(DbSkip())

   EndDo

   _cLeuCapa   := ALLTRIM(STR(TRBCAB->(LastRec())))
   _cLeuItens  := ALLTRIM(STR(TRBDET->(LastRec())))

   //==================================================================
   // Grava os demais produtores titulares de tanques coletivos.
   //==================================================================
   If _cOpcao == "TIT_TC" // Alteração de Titular Tanques Coletivos
      MGLT32TITC(_cFilEnvio)
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032Q
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Envio de dados dos Produtores Rurais via WebService Italac para Sistema Evomilk - INCLUSÃO / ALTERAÇÃO
===============================================================================================================================
Parametros--------: _cChamada = "M" = Rotina Chamada via menu.
                                "S" = Rotina Chamada via Scheduller
                    _cOpcao   = "I" = Roda a integração de Inclusão de produtores no App Evomilk.
                              = "A" = Roda a integração de Alteração de produtores no App Evomilk.
                    _cRotina  = Rotina que está rodando a função de envio dos dados de produtores.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032Q(_cChamada,_cOpcao,_cRotina)
Local _oRetJSon   As object
Local _aHeadOut   As array
Local _aListPAtv  As array
Local _aRecnoSA2  As array
Local _nI         As Numeric
Local _nX         As Numeric
Local _nTotRegEnv As Numeric
Local _cJSonProd  As Character
Local _cJSonGrp   As Character
Local _cItens     As Character
Local _cHoraIni   As Character
Local _cHoraFin   As Character
Local _cMinutos   As Character
Local _nMinutos   As Character
Local _cRetorno   As Character
Local _cKey       As Character
Local _aProdEnv   As Character
Local _cClasParc  As Character
Local _cAuxHTTP   As Character
Local _cCabProdu  As Character
Local _cDadosBCA  As Character
Local _cDadosBCB  As Character
Local _cDadosEmA  As Character
Local _cDadosEmB  As Character
Local _cDadosTlA  As Character
Local _cDadosTlB  As Character
Local _cPropried  As Character
Local _cDadosEdA  As Character
Local _cDadosEdB  As Character
Local _cRodaPe    As Character
Local _cJsonBco   As Character
Local _cJsonEml   As Character
Local _cJsonTel   As Character
Local _cJsonProp  As Character
Local _cJsonEnde  As Character
Local _CJSONENV   As Character
Local _cTenantid  As Character
Local _cEmpWebService As Character
Local _lTemTelef As Logical
Local _lTemEmail As Logical

_cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
_cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")
_nTotRegEnv:= 1

Private _cIdProdut := ""
Private _cMatLatic := ""   //            matricula_laticinio
Private _cRazaoSoc := ""   //            nome_razao_social
Private _cCpf_Cnpj := ""   //            cpf_cnpj
Private _cInscrEst := ""   //            inscricao_estadual
Private _cRg_IE    := ""   //            rg_ie
Private _cDtNascF  := ""   //            data_nascimento_fundacao
Private _cDtHrEnv  := ""   //            data_hora
Private _cDataSit  := ""   //            data_situacao
Private _cObserv   := ""   //            info_adicional
Private _cComplem  := ""   //            complemento
Private _cEndereco := ""   //            endereco
Private _cNrEnd    := ""   //            numero
Private _cBairro   := ""   //            bairro
Private _cCep      := ""   //            cep
Private _cIdUF     := ""   //            id_uf
Private _cIDCidade := ""   //            id_cidade
Private _cCodBanco := ""   //            Codigo do Banco
Private _cCodAgenc := ""   //            Codigo da Agencia
Private _cNumConta := ""   //            Numero da Conta
Private _cEMail    := ""   //            email
Private _cCelular  := ""   //            celular1
Private _cCelula2  := ""   //            celular2
Private _cTelefon1 := ""   //            telefone1
Private _cTelefon2 := ""   //            telefone2
Private _cWhatsAp1 := ""   //            celular1_whatsapp
Private _cWhatsAp2 := ""   //            celular2_whatsapp

            // Detalhe
Private _cNomeProp  := ""  //           nome_propriedade_rural
Private _cNIRF      := ""  //           NIRF
Private _cTipoTanq  := ""  //           id_tipo_tanque
Private _cCapacTnq  := ""  //           capacidade_tanque
Private _cLatitude  := ""  //           latitude_propriedade
Private _cLongitud  := ""  //           longitude_propriedade
Private _cArea      := ""  //           area
Private _cRecria    := ""  //           recria
Private _cVacaSeca  := ""  //           vaca_seca
Private _cVacaLacta := ""  //           vaca_lactacao
Private _cHoraCole  := ""  //           horario_coleta
Private _cRacaProp  := ""  //           raca_propriedade
Private _cFreqCol   := ""  //           frequencia_coleta
Private _cProdDia   := ""  //           producao_media_diaria
Private _cAreaUti   := ""  //           area_utilizada_producao
Private _cCapacRef  := ""  //           capacidade_refrigeracao
Private _cCodPropr  := ""  //           codigo_propriedade_laticinio
Private _cCodLinha  := ""  //           codigo_linha_laticinio
Private _cDescLin   := ""  //           nome_linha

Private _cSituacao  := ""
Private _cCidade    := ""
Private _cUF        := ""
Private _cCod_Ibge  := ""
Private _cSigSif   := ""
Private _cCodPropL := ""
Private _cCodigotq := ""
Private _cTipoResf := ""
Private _cMarcaTanq:= ""
Private _cCPFCnpjP := ""
Private _cMatParce := ""

Private _cTitTanq  := ""    // cpf_cnpj
Private _cMatrLat  := ""    // matricula_laticinio
Private _cTelPrinc := "SIM" // telefone_principal
Private _cEMailPri := "SIM" // email_principal
Private _cSitTnq   := ""    // situacao
Private _CSITPROP  := ""    // Situação Proprietario
Private _CCLASPROP := ""    // Classificação Proprietári do Tanque
Private _CNOMETNQ  := ""    // Nome do Tanque
Private _cNomBanco := ""    // Nome do Banco
Private _cTitConta := ""
Private _cInfoAdic := ""
Private _CDataCad  := ""
Private _cHoraCad  := ""

Private _cComplemD := ""   //            complemento
Private _cEnderecD := ""   //            endereco
Private _cNrEndD   := ""   //            numero
Private _cBairroD  := ""   //            bairro
Private _cCepD     := ""   //            cep
Private _cIdUFD    := ""   //            id_uf
Private _cIDCidadD := ""   //            id_cidade
Private _cEMailD   := ""   //            email 2
Private _cTelefonD := ""   //            Telefone demais propriedades
Private _cVincLat  := ""
Private _cProduTit := "true"
Private _cContaPri := "true"

Default _cChamada := "M"
Default _cOpcao   := "I"
Default _cRotina  := "PADRAO" // "TIT_TC"

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _LinkCerto := AllTrim(ZFM->ZFM_HOMEPG)
      If _cOpcao == "I"
         _cLinkWS  := AllTrim(ZFM->ZFM_LINK02)  // Link de envio de INCLUSÃO de Produtores.
      Else
         _cLinkWS  := AllTrim(ZFM->ZFM_LINK04)  // Link de envio de ALTERAÇÃO de Produtores.
      EndIf
      IF !EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   If Empty(_cDirJSon)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   _cCabProdu := U_MGLT032X(_cDirJSon+"Cabec_Evomilk_Produtores.json")
   If Empty(_cCabProdu)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho Produtores na integração Italac x Evomilk.","Atenção",,1)
      EndIf

      Break
   EndIf

   //_cDadosBCA := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Bancarios_A_Produtores.json")

   _cDadosBCA := ', "dadosbancarios":'

   If Empty(_cDadosBCA)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Dados Bancarios_A na integração Italac x Evomilk.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDadosBCB := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Bancarios_B_Produtores.json")
   If Empty(_cDadosBCB)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo "+_cDirJSon+"Det_Evomilk_Dados_Bancarios_B_Produtores.json","Atenção",,1)
      EndIf

      Break
   EndIf

   //_cDadosEmA := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Emails_A_Produtores.json")

   _cDadosEmA := ' , "emails": '

   If Empty(_cDadosEmA)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo "+_cDirJSon+"Det_Evomilk_Dados_Emails_A_Produtores.json","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDadosEmB := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Emails_B_Produtores.json")
   If Empty(_cDadosEmB)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Endereços de Email_B na integração Italac x Evomilk.","Atenção",,1)
      EndIf

      Break
   EndIf

   //_cDadosTlA := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Telefones_A_Produtores.json")
   _cDadosTlA := ', "telefones": '

   If Empty(_cDadosTlA)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo "+_cDirJSon+"Det_Evomilk_Dados_Telefones_A_Produtores.json","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDadosTlB := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Telefones_B_Produtores.json")
   If Empty(_cDadosTlB)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Numeros de Telefone_B na integração Italac x Evomilk.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cPropried := U_MGLT032X(_cDirJSon+"Det_Evomilk_Propriedades_Produtores.json")
   If Empty(_cPropried)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo "+_cDirJSon+"Det_Evomilk_Propriedades_Produtores.json","Atenção",,1)
      EndIf

      Break
   EndIf

   //_cDadosEdA := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Enderecos_A_Produtores.json")
   _cDadosEdA := ',    "enderecos": ['
   If Empty(_cDadosEdA)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo "+_cDirJSon+"Det_Evomilk_Dados_Enderecos_A_Produtores.json","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDadosEdB := U_MGLT032X(_cDirJSon+"Det_Evomilk_Dados_Enderecos_B_Produtores.json")
   If Empty(_cDadosEdB)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo "+_cDirJSon+"Det_Evomilk_Dados_Enderecos_B_Produtores.json","Atenção",,1)
      EndIf

      Break
   EndIf

   //_cRodaPe := U_MGLT032X(_cDirJSon+"Rodape_Evomilk_Produtores.json")
   _cRodaPe := "    ]	  }]"
   If Empty(_cRodaPe)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo "+_cDirJSon+"Rodape_Evomilk_Produtores.json","Atenção",,1)
      EndIf
      Break
   EndIf

   _aListPAtv:={}
   //=================================================================
   // Obtem a planilha do App Evomilk com os produtores Ativos.
   //=================================================================
   If _cRotina == "TIT_TC" .Or. _cRotina == "USU_TC"
      _aListPAtv := MGLT032TXT(_cDirJSon+"Lista_Produtores_Ativos_CIA_LEITE_PRODUTOR.txt")
      If Empty(_aListPAtv)
         If _cChamada == "M" // Chamada via menu.
            U_ItMsg("Erro na leitura da Lista de Produtores Ativos na Evomilk.","Atenção",,1)
         EndIf

         Break
      EndIf
   EndIf

   //========================================================
   // Obtem o Token de acesso ao App Evomilk.
   //========================================================

   _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

   If Empty(_cKey)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   //===========================================================
   // Define o CNPJ da unidade para a tag vinculado_ao_laticinio
   //===========================================================
   _cVincLat  := _cUnidVinc // Unidade na qual os produtores e coletas estão vinculados // SM0->M0_CGC

   _cHoraIni := Time() // Horario Inicial de Processamento

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

   _cJSonProd := "["
   _cJSonGrp := ""
   _nI := 1

   If _cRotina == "TIT_TC" .Or. _cRotina == "USU_TC"
      U_MGLT032G("","","",.T., .F.,"TIT_TC",xFilial("ZL3")) // Abre arquivo // Grava Arquivo Texto com os retornos de erro/rejeições.
   EndIf

   _aProdEnv := {}

   TRBCAB->(DbSetOrder(3)) // {"WK_ORDEMP","A2_COD","A2_LOJA"}
   TRBDET->(DbSetOrder(1))

   If _cChamada == "M" // Chamada via menu.
      ProcRegua(_nTotRegs)
   Endif
   _cTot:=ALLTRIM(STR(_nTotRegs))
   nConta:=0
   TRBCAB->(DbGoTop())
   _nIntervalo:=15

   Do While ! TRBCAB->(Eof())

      //=================================================================
      // Deve seer enviado apenas os produtores ativos da Evomilk.
      // Existentes no arquivo enviados pela Evomilk.
      //=================================================================
      If _cRotina == "TIT_TC".Or. _cRotina == "USU_TC"
         _nI := Ascan(_aListPAtv,{|x| x[1] == TRBCAB->A2_COD .And. x[2] == TRBCAB->A2_LOJA})
         If _nI == 0
            TRBCAB->(DbSkip())
            Loop
         EndIf
      EndIf

      //====================================================================
      // Calcula o tempo decorrido para obtenção de um novo Token
      //====================================================================
      _cHoraFin := Time()
      _cMinutos := ElapTime (_cHoraIni , _cHoraFin)
      _nMinutos := Val(SubStr(_cMinutos,4,2))
      If _nMinutos > _nIntervalo //  minutos

         _cKeyOld:=Alltrim(_cKey)

         _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

         If Empty(_cKey)
            IF _nIntervalo = 10// já adiou uma vez não adia mais
               If _cChamada == "M" // Chamada via menu.
                  U_ItMsg("Erro ao na obtenção do Token.","Atenção","Rotina de Integração de Produtores cancelada.",1)
               EndIf
               Break
            ENDIF
            _nIntervalo:=10
            _cKey:=Alltrim(_cKeyOld)
         EndIf

         _aHeadOut := {}
         Aadd(_aHeadOut,'Accept: application/json')
         Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
         Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

         _cHoraIni := Time()

      EndIf

      _lTemBanco := .F.
      _lTemTelef := .F.
      _lTemEmail := .F.

      //====================================================================
      // Efetua a leitura dos dados para montagem do JSON.
      //====================================================================
      _cItens := ""
      _cIdProdut := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA//      codigo_usuario
      _cMatLatic := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA//      matricula_laticinio
      _cRazaoSoc := TRBCAB->A2_NOME             //            nome_razao_social
      _cCpf_Cnpj := TRBCAB->A2_CGC              //            cpf_cnpj
      _cInscrEst := TRBCAB->A2_INSCR            //            inscricao_estadual
      _cRg_IE    := TRBCAB->A2_PFISICA          //            rg_ie
      _cDtNascF  := StrZero(Year(TRBCAB->A2_DTNASC),4)+"-"+StrZero(Month(TRBCAB->A2_DTNASC),2)+"-"+StrZero(Day(TRBCAB->A2_DTNASC),2)   //            data_nascimento_fundacao
      _cDtHrEnv  := StrZero(Year(Date()),4)+"-"+StrZero(Month(Date()),2)+"-"+StrZero(Day(Date()),2) + "T" + Time() + "Z"
      _cDataSit  := StrZero(Year(Date()),4)+"-"+StrZero(Month(Date()),2)+"-"+StrZero(Day(Date()),2)
      _cObserv   := ""                          //            info_adicional
      _cComplem  := TRBCAB->A2_ENDCOMP          //            complemento
      _cEndereco := TRBCAB->A2_END              //            endereco
      _cNrEnd    := ""                          //            numero
      _cBairro   := TRBCAB->A2_BAIRRO           //            bairro
      _cCep      := TRBCAB->A2_CEP              //            cep
      _cIdUF     := ""                          //            id_uf
      _cIDCidade := ""                          //            id_cidade
      _cCidade   := AllTrim(TRBCAB->A2_MUN)     //            municipio
      _cUF       := AllTrim(TRBCAB->A2_EST)     //            estado
      _cCod_Ibge := TRBCAB->A2_COD_MUN          //            codigo_ibge"

      _cCodBanco := AllTrim(TRBCAB->A2_BANCO)   //            Codigo do Banco
      _cCodAgenc := AllTrim(TRBCAB->A2_AGENCIA) //            Codigo da Agencia
      _cNumConta := AllTrim(TRBCAB->A2_NUMCON)  //            Numero da Conta
      _cNomBanco := AllTrim(POSICIONE('SA6',1,xFilial('SA6')+_cCodBanco,'A6_NOME'))
      _cTitConta := TRBCAB->A2_NOME
      _cInfoAdic := ""

      _cEMail    := TRBCAB->A2_EMAIL            //            email
      _cCelular  := ""                          //            celular1
      _cCelula2  := ""                          //            celular2
      _cTelefon1 := TRBCAB->A2_TEL              //            telefone1

      If ! Empty(_cTelefon1)
         _lTemTelef := .T.
      EndIf

      If ! Empty(_cEMail)
         _lTemEmail := .T.
      EndIf

      If !Empty(_cTelefon1)
         _cTelefon1 := '"' +AllTrim(_cTelefon1)  + '"'
      EndIf

      _cTelefon2 := ""                          //            telefone2
      _cWhatsAp1 := "SIM"                       //            celular1_whatsapp
      _cWhatsAp1 := "false"                     //            celular2_whatsapp

      //=======================================================================================
      // Este trecho trata os varios e-mails de um campo e envia um a um em campos diferentes.
      //=======================================================================================
      _cEMail := AllTrim(StrTran(_cEMail,",",";"))
      _aCabMail  := U_ITTXTARRAY(_cEMail,";",10)

      _cJsonProp := ""  //  _cPropried
      _cJsonBco  := ""  //  _cDadosBCB
      _cJsonTel  := ""  //  _cDadosTlB
      _cJsonEml  := ""  //  _cDadosEmB
      _cJsonEnde := ""  //  _cDadosEdB

      _aRecnoSA2 := {}

      TRBDET->(MsSeek(TRBCAB->A2_COD))

      Do While ! TRBDET->(Eof()) .And. TRBCAB->A2_COD == TRBDET->A2_COD

         nConta++
         If _cChamada == "M" // Chamada via menu.
            IncProc(_cHoraIni+"-Enviando Produtores: "+STRZERO(nConta,5) +" de "+ _cTot)
         EndIf


         //=================================================================
         // Deve ser enviado apenas os produtores ativos da Evomilk.
         // Existentes no arquivo enviados pela Evomilk.
         // Na integração de Produtores Titulares de Tanques Coletivos.
         //=================================================================
         If _cRotina == "TIT_TC" .Or. _cRotina == "USU_TC"
            _nI := Ascan(_aListPAtv,{|x| x[1] == TRBDET->A2_COD .And. x[2] == TRBDET->A2_LOJA})
            If _nI == 0
               TRBDET->(DbSkip())
               Loop
            EndIf
         EndIf

         _cCodPropr  := ""                                    //           codigo_propriedade_laticinio
         _cNomeProp  := TRBDET->A2_L_FAZEN                    //           nome_propriedade_rural
         _cNIRF      := TRBDET->A2_L_NIRF                     //           NIRF

         _cCodPropL  := TRBDET->A2_COD+"-"+TRBDET->A2_LOJA
         _cMatLatic  := TRBDET->A2_COD+"-"+TRBDET->A2_LOJA    // TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA//            matricula_laticinio

         _cTipoTanq  := "INDIVIDUAL"
         _CCLASPROP  := "PRODUTOR INDIVIDUAL"

         _cMatrLat   := ""
         _cTitTanq   := ""
         _cMatParce  := ""
         _cCPFCnpjP  := ""

         If TRBDET->A2_L_CLASS == "C"
            _cTipoTanq  := "COLETIVO"
            _CCLASPROP  := "TITULAR DE TANQUE COMUNITARIO"
         ElseIf TRBDET->A2_L_CLASS == "U"
            _CCLASPROP  := "USUARIO DE TANQUE COMUNITARIO"
            _cTipoTanq  := "COLETIVO"
            _cMatrLat   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
            _cTitTanq   := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque

            _cClasParc  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_L_CLASS') // Classificação do Titular do Tanque
            If AllTrim(_cClasParc) == "F"
               _cCPFCnpjP  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
               _cMatParce  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
            EndIf

         ElseIf TRBDET->A2_L_CLASS == "F"
             _cTipoTanq  := "FAMILIAR" //"INDIVIDUAL"
             _CCLASPROP  := "TITULAR DE TANQUE COMUNITARIO" // "PRODUTOR INDIVIDUAL"
             //_cCPFCnpjP  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
             //_cMatParce  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         EndIf

         If ! Empty(_cCPFCnpjP) .And. AllTrim(_cCPFCnpjP) == AllTrim(_cCpf_Cnpj)
            _cCPFCnpjP := ""
            _cMatParce := ""
         EndIf

         _CNOMETNQ   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ //        Nome do Tanque
         _cCapacTnq  := AllTrim(Str(TRBDET->A2_L_CAPTQ,11))   //           capacidade_tanque
         _cLatitude  := AllTrim(Str(TRBDET->A2_L_LATIT,18,6)) //           latitude_propriedade
         _cLongitud  := AllTrim(Str(TRBDET->A2_L_LONGI,18,6)) //           longitude_propriedade
         _cArea      := ""                                    //           area
         _cRecria    := ""                                    //           recria
         _cVacaSeca  := ""                                    //           vaca_seca
         _cVacaLacta := ""                                    //           vaca_lactacao
         _cHoraCole  := ""                                    //           horario_coleta
         _cRacaProp  := ""                                    //           raca_propriedade

         If TRBDET->A2_L_FREQU == "1"
            _cFreqCol   := "48"                               //           frequencia_coleta
         Else
            _cFreqCol   := "24"
         EndIf

         _cProdDia   := ""                                    //           producao_media_diaria
         _cAreaUti   := ""                                    //           area_utilizada_producao
         _cCapacRef  := ""                                    //           capacidade_refrigeracao
         //Cap. Resfri.	Capacidade Resfriamento	0=Nenhuma	2=Duas Ordenhas	4=Quatro Ordenhas

         If TRBDET->A2_L_CAPAC == "0"
            //_cCapacRef  := AllTrim(Str(TRBDET->A2_L_CAPTQ,10,6))
            _cCapacRef  := "Nenhuma"
         ElseIf TRBDET->A2_L_CAPAC == "2"
            _cCapacRef  := "Duas Ordenhas"
         ElseIf TRBDET->A2_L_CAPAC == "4"
            _cCapacRef  := "Quatro Ordenhas"
         EndIf

         If Empty(_cCapacRef)
            _cCapacRef := "nenhuma"
         EndIf

         _cSituacao  := TRBDET->A2_L_ATIVO
         _cSitTnq    := TRBDET->A2_L_ATIVO
         _CSITPROP   := TRBDET->A2_L_ATIVO
         _cSigSif    := TRBDET->A2_L_SIGSI
         _cCodigotq  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         _cTipoResf  := If(TRBDET->A2_L_RESFR == "E","EXPANSAO","IMERSAO")
         _cMarcaTanq := TRBDET->A2_L_MARTQ
         _cCodLinha  := TRBDET->A2_L_LI_RO   //           codigo_linha_laticinio
         _cDescLin   := TRBDET->ZL3_DESCRI   //           nome_linha
//-----------------------------------------------------------------------------
         _cComplemD  := TRBDET->A2_ENDCOMP          //            complemento
         _cEnderecD  := TRBDET->A2_END              //            endereco
         _cNrEndD    := ""                          //            numero
         _cBairroD   := TRBDET->A2_BAIRRO           //            bairro
         _cCepD      := TRBDET->A2_CEP              //            cep
         _cIDCidadD  := ""                          //            id_cidade

         _cCodIbgeD  := TRBDET->A2_COD_MUN          //           codigo_ibge"
         _cEMailD    := TRBDET->A2_EMAIL            //            email
         _cTelefonD  := TRBDET->A2_TEL
         _cCidade    := AllTrim(TRBDET->A2_MUN)     //            municipio
         _cUF        := AllTrim(TRBDET->A2_EST)     //            estado
         _cCod_Ibge  := TRBDET->A2_COD_MUN          //            codigo_ibge"

         If ! Empty(_cTelefonD)
            _lTemTelef := .T.
            _cTelefon1 := _cTelefonD
         EndIf

         If !Empty(_cEMailD)
            _lTemEmail := .T.
            _cEMail := _cEMailD
         EndIf

         IF !Empty(_cCodBanco) .AND. !Empty(_cCodAgenc) .AND. !Empty(_cNumConta)//SE NÃO TEM NÃO ENVIA
            _cJsonBco  += If(!Empty(_cJsonBco),",","")  + &(_cDadosBCB)
            _lTemBanco:=.T.
         ENDIF
         If ! Empty(_cEMailD)//SE NÃO TEM NÃO ENVIA
            _cJsonEml  += If(!Empty(_cJsonEml),",","")  + &(_cDadosEmB)
         ENDIF
         IF ! Empty(_cTelefonD)//SE NÃO TEM NÃO ENVIA
             _cJsonTel  += If(!Empty(_cJsonTel),",","")  + &(_cDadosTlB)
         ENDIF
         _cJsonProp += If(!Empty(_cJsonProp),",","") + &(_cPropried)
         _cJsonEnde += If(!Empty(_cJsonEnde),",","") + &(_cDadosEdB)

         //===========================================================
         // Guarda os fornecedores do JSon para atualização do SA2
         //===========================================================
         Aadd(_aRecnoSA2, TRBDET->WK_RECNO)

         TRBDET->(DbSkip())
      EndDo

      _CDataCad  := Dtoc(Date())
      _cHoraCad  := Time()

      //_cJSonEnv:= &(_cCabProdu) + _cPropried + _cDadosBCA + _cDadosBCB + _cDadosTlA + _cDadosTlB + _cDadosEmA + _cDadosEmB + _cDadosEdA + _cDadosEdB + _cRodaPe
      _cJSonEnv  := &(_cCabProdu) + _cJsonProp +" ] "

      If _lTemBanco // Tem BANCO
         _cJSonEnv += _cDadosBCA + "[" + _cJsonBco + "]"
      ELSE
         _cJSonEnv += _cDadosBCA + "null"
      ENDIF

      If _lTemTelef // Tem TELEFONTE
         _cJSonEnv += _cDadosTlA + "[" + _cJsonTel + "]"
      ELSE
         _cJSonEnv += _cDadosTlA + "null"
      ENDIF

      If _lTemEmail  // Tem E-MAIL
         _cJSonEnv += _cDadosEmA + "[" + _cJsonEml + "]"
      Else
         _cJSonEnv += _cDadosEmA + "null"
      EndIf

      _cJSonEnv += _cDadosEdA + _cJsonEnde + _cRodaPe

      If _nI >= _nTotRegEnv

         _nStart 		:= 0
         _nRetry 		:= 0
         _cJSonRet 	:= Nil
         _nTimOut	 	:= 120
         _cRetorno   := ""
         _cRetHttp    := ''

         //=======================================================================
         // Envio do JSon
         //=======================================================================
                             //HttpPost( < cUrl >, [ cGetParms ], [ cPostParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderGet ] )
         _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonEnv              , _nTimOut    , _aHeadOut   , @_cJSonRet ) )

         If ! Empty(_cRetHttp)
            _cRetHttp := DecodeUtf8(_cRetHttp)
            _cRetHttp := StrTran( _cRetHttp, "\n", "" )
            FWJSonDeserialize(_cRetHttp,@_oRetJSon)
         EndIf

         _cResult := ""  // status": "success",

         _cAuxHTTP := Upper(_cRetHttp)

         If (!Empty(_cAuxHTTP) .And. !("INTERNAL SERVER ERROR" $ _cAuxHTTP)) .And. "STATUS" $ _cAuxHTTP
            If ! Empty(_oRetJSon)
               _cResult := _oRetJSon:status
            EndIf
         EndIf

         _cRetorno := Upper(_cRetHttp)

         If AllTrim(_cResult) == "success" //_lResult // Integração realizada com sucesso
            //U_MGLT032Y(_aProdEnv) // Grava na tabela temporária os registros integrados com sucesso para depois ataualizar flag de envio da SA2.
            //============================================================
            // Grava dados dos Produtores Enviados e aceitos.
            //============================================================
            ZBH->(RecLock("ZBH",.T.))
            ZBH->ZBH_FILIAL := xFilial("ZBH")            // Filial do Sistema
            ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6)    // Codigo do Produtor
            ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4)    // Loja do Produtor
            ZBH->ZBH_NOMPRO := _cRazaoSoc                // Nome do Produtor
            ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBH->ZBH_JSONEN := _cJSonEnv                 // JSON enviado
            ZBH->ZBH_DTREJ  := Date()                    // Data da Rejeição
            ZBH->ZBH_HRREJ  := Time()                    // Hora da Rejeição
            ZBH->ZBH_DTENV	 := Date()                    // Data de Envio
            ZBH->ZBH_HRENV	 := Time()                    // Hora de Envio
            ZBH->ZBH_STATUS := "A"                       // Status da Integraç
            ZBH->ZBH_WEBINT := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
			   ZBH->(MsUnLock())
            _nAceitos++
            //====================================================================
            // Marca produtor como já enviado para o sistema Evomilk.
            //====================================================================
            IF _lEfetivaEnvio  // INCLUSÃO E ALTERAÇÃO DE PRODUTORES SUCESSO
               For _nX := 1 To Len(_aRecnoSA2)
                   SA2->(DbGoto(_aRecnoSA2[_nX]))
                   SA2->(RecLock("SA2", .F.))
                   If _cOpcao == "I"  // Inclusão
                      SA2->A2_L_ENVEV := "N"
                      If Empty(SA2->A2_L_ITCOL)
                         SA2->A2_L_ITCOL := "S"
                      EndIf
                   Else // Alteração
                      SA2->A2_L_ENVAT := "N"
                   EndIf
                   SA2->(MsUnLock())
               Next _nX
            EndIf

            _aRecnoSA2 := {}

         else
            //============================================================
            // Grava dados dos Produtores enviados e rejeitados.
            //============================================================
            ZBH->(RecLock("ZBH",.T.))
            ZBH->ZBH_FILIAL := xFilial("ZBH")            // Filial do Sistema
            ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6)    // Codigo do Produtor
            ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4)    // Loja do Produtor
            ZBH->ZBH_NOMPRO := _cRazaoSoc                // Nome do Produtor
            ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBH->ZBH_JSONEN := _cJSonEnv                // JSON enviado
            ZBH->ZBH_DTREJ  := Date()                    // Data da Rejeição
            ZBH->ZBH_HRREJ  := Time()                    // Hora da Rejeição
            ZBH->ZBH_DTENV	 := Date()                    // Data de Envio
            ZBH->ZBH_HRENV	 := Time()                    // Hora de Envio
            ZBH->ZBH_STATUS := "R"                       // Status da Integração
            ZBH->ZBH_WEBINT := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
			   ZBH->(MsUnLock())
            _nRejeitados++

            If _cRotina == "TIT_TC" .Or. _cRotina == "USU_TC"// Rotina de Envio de Titulares e Usuários de Tanques Coletivos.
               U_MGLT032G(_cJSonEnv,AllTrim(_cRetHttp),_cMatLatic+"-"+_cRazaoSoc,.F., .F.,"TIT_TC",xFilial("ZL3")) // Grava Arquivo Texto com os retornos de erro/rejeições.
            EndIf

            If ! Empty(_cRetorno) .And. "EXISTE UM PRODUTOR CADASTRADO" $ _cRetorno
               //====================================================================
               // Marca produtor como já enviado para o sistema Evomilk.
               //====================================================================
               IF _lEfetivaEnvio  // ALTERAÇÃO DE PRODUTORES REJEITADO
                  For _nX := 1 To Len(_aRecnoSA2)
                      SA2->(DbGoto(_aRecnoSA2[_nX]))
                      SA2->(RecLock("SA2", .F.))
                      SA2->A2_L_ENVEV := "N"
                      If Empty(SA2->A2_L_ITCOL)
                         SA2->A2_L_ITCOL := "S"
                      EndIf
                      SA2->(MsUnLock())
                  Next _nX
               ENDIF

               _aRecnoSA2 := {}
            EndIf

         EndIf

         _aProdEnv := {}
         _cJSonEnv := ""
         _nI := 0

      EndIf

      _nI += 1

      TRBCAB->(DbSkip())

   EndDo

   If ! Empty(_cJSonEnv)
      //_cJSonProd += _cJSonGrp + "]"

      _nStart 		:= 0
      _nRetry 		:= 0
      _cJSonRet 	:= Nil
      _nTimOut	 	:= 120
      _cRetorno   := ""

      _cRetHttp    := ''

      //=======================================================================
      // Remoção de caracteres especiais do JSon antes do envio
      //=======================================================================
      //_cJSonAux := StrTran(_cJSonProd,"\/","/-/")
      //_aExcecao := {{"\","-"}, {char(9)," "}} // Char(9) = Tecla Tab.
      //_cJSonAux := U_ITSUBCHR(_cJSonAux, _aExcecao)
      //_cJSonAux := StrTran(_cJSonAux,"/-/","\/")
      //_cJSonProd := _cJSonAux

      //=======================================================================
      // Envio do JSon
      //=======================================================================
      _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonEnv , _nTimOut , _aHeadOut , @_cJSonRet ) )

      If ! Empty(_cRetHttp)
         _cRetHttp := DecodeUtf8(_cRetHttp)

         _cRetHttp := StrTran( _cRetHttp, "\n", "" )
         FWJSonDeserialize(_cRetHttp,@_oRetJSon)
      EndIf

      //_lResult := .F.
      _cResult := ""
      _cAuxHTTP := Upper(_cRetHttp)

      If ! Empty(_oRetJSon) .And. "STATUS" $ _cAuxHTTP
         _cResult := _oRetJSon:status
      EndIf

      _cRetorno := Upper(_cRetHttp)

      If AllTrim(_cResult) == "success" //_lResult // Integração realizada com sucesso
         //U_MGLT032Y(_aProdEnv) // Grava na tabela temporária os registros integrados com sucesso para depois ataualizar flag de envio da SA2.
         //=================================================================
         // Grava Dados dos Produtores Enviados e aceitos para histórico
         //=================================================================
         ZBH->(RecLock("ZBH",.T.))
         ZBH->ZBH_FILIAL := xFilial("ZBH")         // Filial do Sistema
         ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6) // Codigo do Produtor
         ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4) // Loja do Produtor
         ZBH->ZBH_NOMPRO := _cRazaoSoc             // Nome do Produtor
         ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)     // Motivo da Rejeição
         ZBH->ZBH_JSONEN := _cJSonEnv              // JSON enviado
         //ZBH->ZBH_DTREJ  := Date()               // Data da Rejeição
         //ZBH->ZBH_HRREJ  := Time()               // Hora da Rejeição
         ZBH->ZBH_DTENV	    := Date()              // Data de Envio
         ZBH->ZBH_HRENV	    := Time()              // Hora de Envio
         ZBH->ZBH_STATUS	 := "A"                 // Status da Integração
         ZBH->ZBH_WEBINT    := "E"                 // Indica que a integração está sendo realizada com o App Evomilk		ZBH->(MsUnLock())
         ZBH->(MsUnLock())
         _nAceitos++
         //====================================================================
         // Marca produtor como já enviado para o sistema Evomilk.
         //====================================================================
         IF _lEfetivaEnvio  // INCLUSÃO E ALTERAÇÃO DE PRODUTORES SUCESSO
            For _nX := 1 To Len(_aRecnoSA2)
                SA2->(DbGoto(_aRecnoSA2[_nX]))
                SA2->(RecLock("SA2", .F.))
                If _cOpcao == "I"  // Inclusão
                   SA2->A2_L_ENVEV := "N"
                   If Empty(SA2->A2_L_ITCOL)
                      SA2->A2_L_ITCOL := "S"
                   EndIf
                Else // Alteração
                   SA2->A2_L_ENVAT := "N"
                EndIf
                SA2->(MsUnLock())
            Next _nX
         ENDIF

         _aRecnoSA2 := {}

      else
         //============================================================
         // Grava dados de envio rejeitados para histórico.
         //============================================================
         ZBH->(RecLock("ZBH",.T.))
         ZBH->ZBH_FILIAL := xFilial("ZBH")          // Filial do Sistema
         ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6)    // Codigo do Produtor
         ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4)  // Loja do Produtor
         ZBH->ZBH_NOMPRO := _cRazaoSoc                // Nome do Produtor
         ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)        // Motivo da Rejeição
         ZBH->ZBH_JSONEN := _cJSonEnv               // JSON enviado
         ZBH->ZBH_DTREJ  := Date()                    // Data da Rejeição
         ZBH->ZBH_HRREJ  := Time()                    // Hora da Rejeição
         ZBH->ZBH_DTENV	 := Date()                    // Data de Envio
         ZBH->ZBH_HRENV	 := Time()                    // Hora de Envio
         ZBH->ZBH_STATUS := "R"                       // Status da Integração
         ZBH->ZBH_WEBINT := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
		   ZBH->(MsUnLock())
         _nRejeitados++

         If _cRotina == "TIT_TC" .Or. _cRotina == "USU_TC" // Rotina de Envio de Titulares e Usuários de Tanques Coletivos.
            U_MGLT032G(_cJSonEnv,AllTrim(_cRetHttp),_cMatLatic+"-"+_cRazaoSoc,.F., .F.,"TIT_TC",xFilial("ZL3")) // Grava Arquivo Texto com os retornos de erro/rejeições.
         EndIf

         If ! Empty(_cRetorno) .And. "EXISTE UM PRODUTOR CADASTRADO" $ _cRetorno
            //====================================================================
            // Marca produtor como já enviado para o sistema Evomilk.
            //====================================================================
            IF _lEfetivaEnvio // ALTERAÇÃO DE PRODUTORES REJEITADOS
               For _nX := 1 To Len(_aRecnoSA2)
                   SA2->(DbGoto(_aRecnoSA2[_nX]))
                   SA2->(RecLock("SA2", .F.))
                   SA2->A2_L_ENVEV := "N"
                   If Empty(SA2->A2_L_ITCOL)
                      SA2->A2_L_ITCOL := "S"
                   EndIf
                   SA2->(MsUnLock())
               Next _nX
            ENDIF

            _aRecnoSA2 := {}
         EndIf

      EndIf
   EndIf

   If _cRotina == "TIT_TC" .Or. _cRotina == "USU_TC" // Rotina de Envio de Titulares de Tanques Coletivos.
      U_MGLT032G("","","",.F., .T.,"TIT_TC",xFilial("ZL3")) // Fecha arquivo // Grava Arquivo Texto com os retornos de erro/rejeições.
   EndIf

   //=================================================================
   // Atualiza tabela SA2 aterando o flag dos produtores integrados.
   //=================================================================
   IF _lEfetivaEnvio // INCLUSÃO E ALTERAÇÃO DE PRODUTORES
      TRBSA2->(DbGoTop())
      Do while ! TRBSA2->(Eof())
         SA2->(DbGoto(TRBSA2->WK_RECNO))
         SA2->(RecLock("SA2", .F.))
         If _cOpcao == "I"  // Inclusão
            SA2->A2_L_ENVEV := "N"
            If Empty(SA2->A2_L_ITCOL)
               SA2->A2_L_ITCOL := "S"
            EndIf
         Else // Alteração
            SA2->A2_L_ENVAT := "N"
         EndIf
         SA2->(MsUnLock())
         TRBSA2->(DbSkip())
      EndDo
   ENDIF

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032V
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de envio de dados dos Volumes de Leite Coletados.
===============================================================================================================================
Parametros---------: _lSchedule = .T. = Rotina chamada via scheduller
                                    .F. = Rotina chamada via menu.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032V(_lSchedule)
Local _aStruct   := {}
Local _cDtColIni := SUPERGETMV('IT_DTCOLEV',.F.,  "01/10/2024")
Local _oTemp3, _oTemp5
Local _cFilEnvC := xFilial("ZL3")

Default _lSchedule := .F.

Begin Sequence

   If ! _lSchedule
      IncProc("Gerando dados das Coletas de Leita para envio...")
   EndIf

   //==========================================================================
   // Cria Tabela Temporária para atualização da ZLJ
   //==========================================================================
   _aStruct := {}
   Aadd(_aStruct,{"ZLJ_VIAGEM","C",10 ,0})  // numero_identificador: "309700845-3097009404"
   Aadd(_aStruct,{"ZLJ_NUMERO","C",10 ,0})  // numero_identificador: "309700845-3097009404"
   Aadd(_aStruct,{"WK_RECNO"  ,"N",10 ,0})  // Nr Recno ZLJ

   If Select("TRBZLJ") > 0
      TRBZLJ->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCAB criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp5 := FWTemporaryTable():New( "TRBZLJ",  _aStruct )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp5:AddIndex( "01", {"ZLJ_VIAGEM","ZLJ_NUMERO"} )
   _oTemp5:Create()

   DBSelectArea("TRBZLJ")

   //==========================================================================
   // Cria Tabela Temporária para armazenar dados do JSon
   //==========================================================================
   _aStruct := {}
   Aadd(_aStruct,{"ZLJ_VIAGEM","C",10 ,0})  // numero_identificador: "309700845-3097009404"
   Aadd(_aStruct,{"ZLJ_NUMERO","C",10 ,0})  // numero_identificador: "309700845-3097009404"
   Aadd(_aStruct,{"ZLJ_CODPAT","C",6  ,0})  // matricula_produtor //A2_COD
   Aadd(_aStruct,{"ZLJ_LOJPAT","C",4  ,0})  // matricula_produtor //A2_LOJA
   Aadd(_aStruct,{"ZLJ_VOLUME","N",14 ,0})  // volume_litros
   Aadd(_aStruct,{"ZLJ_DTIVIA","D",8  ,0})  // data_coleta
   Aadd(_aStruct,{"ZLJ_HRINI" ,"C",8  ,0})  // hora_coleta   //Aadd(_aStruct,{"WK_HORACOL","C",8  ,0})  // hora_coleta
   Aadd(_aStruct,{"WK_OBSERV" ,"C",100,0})  // observações
   Aadd(_aStruct,{"WK_RECNO"  ,"N",10 ,0})  // Recno da Tabela ZLJ

   If Select("TRBCOL") > 0
      TRBCOL->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCAB criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp3 := FWTemporaryTable():New( "TRBCOL",  _aStruct )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp3:AddIndex( "01", {"ZLJ_CODPAT","ZLJ_LOJPAT"})

   _oTemp3:Create()

   DBSelectArea("TRBCOL")

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   _nTotRegs := 0

   If ! _lSchedule
      _cQry := " SELECT COUNT(ZLJ_VOLUME) AS TOTREGS, SUM(ZLJ_VOLUME) AS TOT_VOLMES "
      _cQry += " FROM " + RetSqlName("ZLJ") + " ZLJ, " + RetSqlName("SA2") + " SA2 "
      _cQry += " WHERE ZLJ.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
      IF ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
         _cQry += " AND (ZLJ.ZLJ_ENVEVO = ' ' OR ZLJ.ZLJ_ENVEVO = 'S') "
      ENDIF
      IF _lEfetivaEnvio
         _cQry += " AND ZLJ_DTIVIA >= '"+ Dtos(Ctod(_cDtColIni)) + "' "
      ELSE
         _cQry += " AND ZLJ_DTIVIA >= '20241001' "
         _cQry += " AND ZLJ_DTIVIA <= '20241031' "
      ENDIF
      _cQry += " AND ZLJ_CODPAT = A2_COD AND ZLJ_LOJPAT = A2_LOJA "
      _cQry += " AND SA2.A2_L_ITCOL = 'S' "//FOI ENVIADO PARA A Evomilk
      //_cQry += " AND A2_L_ATIVO <> 'N' "   // Solicitação da Evomilk em 21/07/2022. Enviar também os produtores de leite inativos.
      _cQry += " AND ZLJ_FILIAL = '" + _cFilEnvC + "' "
      _cQry += " AND ZLJ_STATUS = 'E' "
      _cQry += " ORDER BY ZLJ_CODPAT,ZLJ_LOJPAT "

      If Select("QRYZLJ") > 0
         QRYZLJ->(DbCloseArea())
      EndIf

      MPSysOpenQuery( _cQry , "QRYZLJ")

      _nTotRegs := QRYZLJ->TOTREGS
      _nTotVol  := QRYZLJ->TOT_VOLMES
   EndIf

   If Select("QRYZLJ") > 0
      QRYZLJ->(DbCloseArea())
   EndIf

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   //_dDtColIni := Date() - 540 // 18 ultimos meses de coleta.
   _cQry := " SELECT "
   _cQry += " ZLJ_VIAGEM, "              // numero_identificador: "309700845-3097009404"
   _cQry += " ZLJ_NUMERO, "              // numero_identificador: "309700845-3097009404"
   _cQry += " ZLJ_CODPAT, "              // matricula_produtor //A2_COD
   _cQry += " ZLJ_LOJPAT, "              // matricula_produtor //A2_LOJA
   _cQry += " ZLJ_VOLUME, "              // volume_litros
   _cQry += " ZLJ_DTIVIA, "              // data_coleta
   _cQry += " ZLJ_HRINI , "              // HORARIO INICIAL COLETA // ZLJ_HRFIM = HORARIO FINAL COLETA
   _cQry += " ZLJ.R_E_C_N_O_ AS NRREG "
   _cQry += " FROM " + RetSqlName("ZLJ") + " ZLJ, " + RetSqlName("SA2") + " SA2 "
   _cQry += " WHERE ZLJ.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
   IF ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
      _cQry += " AND (ZLJ.ZLJ_ENVEVO = ' ' OR ZLJ.ZLJ_ENVEVO = 'S') "
   ENDIF
   IF _lEfetivaEnvio
      _cQry += " AND ZLJ_DTIVIA >= '"+ Dtos(Ctod(_cDtColIni)) + "' "
   ELSE
      _cQry += " AND ZLJ_DTIVIA >= '20241001' "
      _cQry += " AND ZLJ_DTIVIA <= '20241031' "
   ENDIF
   _cQry += " AND ZLJ_CODPAT = A2_COD AND ZLJ_LOJPAT = A2_LOJA "
   _cQry += " AND SA2.A2_L_ITCOL = 'S' "
   _cQry += " AND ZLJ_FILIAL = '" + _cFilEnvC + "' "
   _cQry += " AND ZLJ_STATUS = 'E' "

   _cQry += " ORDER BY ZLJ_CODPAT,ZLJ_LOJPAT "

   If Select("QRYZLJ") > 0
      QRYZLJ->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYZLJ")

   QRYZLJ->(DbGotop())

   If ! _lSchedule
      ProcRegua(_nTotRegs)
   EndIf
   _cTot:=ALLTRIM(STR(_nTotRegs))
   _cLeuVol:=ALLTRIM(TRANS(_nTotVol,"@E 999,9999,999,999,999,999"))
   nConta:=0

   Do While ! QRYZLJ->(Eof())

      nConta++
      If ! _lSchedule
         IncProc("Lendo Coletas: "+STRZERO(nConta,6) +" de "+ _cTot+", Vol.: "+_cLeuVol)
      EndIf

      TRBCOL->(DbAppend())
      TRBCOL->ZLJ_VIAGEM := QRYZLJ->ZLJ_VIAGEM         // C 10  // numero_identificador: "309700845-3097009404"
      TRBCOL->ZLJ_NUMERO := QRYZLJ->ZLJ_NUMERO         // C 10  // numero_identificador: "309700845-3097009404"
      TRBCOL->ZLJ_CODPAT := QRYZLJ->ZLJ_CODPAT         // C 6   // matricula_produtor //A2_COD
      TRBCOL->ZLJ_LOJPAT := QRYZLJ->ZLJ_LOJPAT         // C 4   // matricula_produtor //A2_LOJA
      TRBCOL->ZLJ_VOLUME := QRYZLJ->ZLJ_VOLUME         // N 14  // volume_litros
      TRBCOL->ZLJ_DTIVIA := Stod(QRYZLJ->ZLJ_DTIVIA)   // D 8   // data_coleta
      TRBCOL->ZLJ_HRINI  := QRYZLJ->ZLJ_HRINI          // C 8   // hora_coleta
      TRBCOL->WK_OBSERV  := ""                         // C 100 // observações
      TRBCOL->WK_RECNO   := QRYZLJ->NRREG              // N 10  // Recno da Tabela ZLJ

      _lHaDadosC := .T.

      QRYZLJ->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032R
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Envio de dados das coletas via WebService Italac para Sistema Evomilk
===============================================================================================================================
Parametros--------: _cChamada = "M" = Rotina Chamada via menu.
                                "S" = Rotina Chamada via Scheduller
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032R(_cChamada)
Local _cColetaL := ""
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cJSonEnv
Local _nStart
Local _nRetry
Local _cJSonRet
Local _nTimOut
Local _cRetHttp
Local _cJSonColeta, _cJSonGrp
Local _cHoraIni, _cHoraFin, _cMinutos, _nMinutos
Local _nTotRegEnv := 1 // 100  // Total de registros para envio.
Local _nI , _oRetJSon, _cResult
Local _aColetaEnv
Local _cDataCol
Local _nRecno := 0
Local _LinkCerto := ""
Local _cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")

Private _cNrIdent
Private _cNrMatr
Private _cVolume
Private _cDtColeta
Private _cHoraCol
Private _cObserv
Private _cNomeCoop, _cTipoCoop

Private _OFWRITER // Para gravação de arquivos texto, para envio para Evomilk para conferência.

Default _cChamada := "M"

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _cLinkWS  := AllTrim(ZFM->ZFM_LINK03) // LINK DE ENVIO DA COLETA DO LEITE.
      _LinkCerto := AllTrim(ZFM->ZFM_HOMEPG)
      IF !EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   If Empty(_cDirJSon)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON e os transforma em String.
   //================================================================================
   _cColetaL := U_MGLT032X(_cDirJSon+"Coleta_de_Leite_Evomilk.json")

   If Empty(_cColetaL)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo Coleta de Leite integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

   If Empty(_cKey)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Coleta de Leite Produtores cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   _cHoraIni := Time() // Horario Inicial de Processamento

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')
   _nTotRegs:=TRBCOL->(LastRec())
   If _cChamada == "M"
      ProcRegua(_nTotRegs)
   EndIf

   _cJSonColeta := "["
   _cJSonGrp    := ""
   _nI := 1

   _aColetaEnv := {}
   _cTot:=ALLTRIM(STR(_nTotRegs))
   _cLidos:= _cTot
   nConta:=0

   TRBCOL->(DbGoTop())
   Do While ! TRBCOL->(Eof())

      nConta++
      If _cChamada == "M"
         IncProc("Transmitindo Coletas: "+STRZERO(nConta,6) +" de "+ _cTot)
      EndIf

      //====================================================================
      // Calcula o tempo decorrido para obtenção de um novo Token
      //====================================================================
      _cHoraFin := Time()
      _cMinutos := ElapTime (_cHoraIni , _cHoraFin)
      _nMinutos := Val(SubStr(_cMinutos,4,2))
      If _nMinutos > 5 // 28 // minutos
         _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

         If Empty(_cKey)
            If _cChamada == "M" // Chamada via menu.
               U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Coleta de Leite Produtores cancelada.","Atenção",,1)
            EndIf

            Break
         EndIf

         _aHeadOut := {}
         Aadd(_aHeadOut,'Accept: application/json')
         Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
         Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

         _cHoraIni := Time()

      EndIf

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================
      _cNrIdent  := TRBCOL->ZLJ_VIAGEM+TRBCOL->ZLJ_NUMERO            // C 6   // numero_identificador: "309700845-3097009404"
      _cNrMatr   := TRBCOL->ZLJ_CODPAT + "-" + TRBCOL->ZLJ_LOJPAT    // C 6   // matricula_produtor //A2_COD
      _cVolume   := AllTrim(Str(TRBCOL->ZLJ_VOLUME,14))         // N 14  // volume_litros
      _cDtColeta := StrZero(Year(TRBCOL->ZLJ_DTIVIA),4) + "-" + StrZero(Month(TRBCOL->ZLJ_DTIVIA),2) + "-" + StrZero(Day(TRBCOL->ZLJ_DTIVIA),2)      // D 8   // data_coleta
      _cHoraCol  := TRBCOL->ZLJ_HRINI                           // WK_HORACOL                          // C 8   // hora_coleta
      _cObserv   := TRBCOL->WK_OBSERV                           // C 100 // observações
      _nRecno    := TRBCOL->WK_RECNO

      _cNomeCoop := ""
      _cTipoCoop := ""

      _cJSonEnv := &(_cColetaL)

      _cJSonGrp += If(!Empty(_cJSonGrp),",","") + _cJSonEnv

      If _nI >= _nTotRegEnv

         _cJSonColeta += _cJSonGrp + "]"

         _nStart 		:= 0
         _nRetry 		:= 0
         _cJSonRet 	:= Nil
         _nTimOut	 	:= 120

         _cRetHttp    := ''

         _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonColeta , _nTimOut , _aHeadOut , @_cJSonRet ) )

         If ! Empty(_cRetHttp)
            _cRetHttp := DecodeUtf8(_cRetHttp)

            _cRetHttp := StrTran( _cRetHttp, "\n", "" )
            FWJSonDeserialize(_cRetHttp,@_oRetJSon)
         EndIf

         _cAuxHTTP := Upper(_cRetHttp)

         _cResult := "error"
         If ! Empty(_oRetJSon) .And."STATUS" $ _cAuxHTTP// "status" $ _cRetHttp

            _cResult := _oRetJSon:status
         EndIf

         If _cResult == "success" // Integração realizada com sucesso
            //U_MGLT032W(_aColetaEnv) // Grava na tabela temporária os registros integrados com sucesso para depois ataualizar flag de envio da SA2.

            //=======================================================================
            // Grava dados das coletas enviadas e aceitas para histórico.
            //=======================================================================
            _cDataCol  := StrTran(_cDtColeta,"-","")

            _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

            ZBI->(RecLock("ZBI",.T.))
            ZBI->ZBI_FILIAL  := xFilial("ZBI")            // Filial do Sistema
            ZBI->ZBI_TICKET  := _cNrIdent                 // Ticket
            ZBI->ZBI_DTCOLE  := StoD(_cDataCol)           // Data Coleta
            ZBI->ZBI_CODPRO  := SubStr(_cNrMatr,1,6)      // Codigo do Produtor
            ZBI->ZBI_LOJPRO  := SubStr(_cNrMatr,8,4)      // Loja do Produtor

            If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
               _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

               ZBI->ZBI_NOMPRO := _cNomeCoop
            Else
               ZBI->ZBI_NOMPRO :=  POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
            EndIf

            ZBI->ZBI_MOTIVO  :=  AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBI->ZBI_JSONEN  :=  _cJSonColeta              // Json de Envio
            ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
            ZBI->ZBI_HRENV	  :=  Time()                    // Hora de Envio
            ZBI->ZBI_STATUS  :=  "A"                       // Status da Integração
            ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
            ZBI->(MsUnLock())
            _nAceitos++

            //==============================================================
            // Atualiza a tabela ZLJ
            //==============================================================
            If _lEfetivaEnvio .AND. _nRecno > 0 .AND. ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
               ZLJ->(DbGoto(_nRecno))
               ZLJ->(RecLock("ZLJ", .F.))
               ZLJ->ZLJ_ENVEVO := "N"
               ZLJ->(MsUnLock())
               _nRecno := 0
            EndIf
         else
            _cDataCol := StrTran(_cDtColeta,"-","")

            _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

            //=======================================================================
            // Grava dados das coletas enviadas e rejeitadas para histórico.
            //=======================================================================
            ZBI->(RecLock("ZBI",.T.))
            ZBI->ZBI_FILIAL  := xFilial("ZBI")             // Filial do Sistema
            ZBI->ZBI_TICKET  := _cNrIdent                  // Ticket
            ZBI->ZBI_DTCOLE  := StoD(_cDataCol)            // Data Coleta
            ZBI->ZBI_CODPRO  :=  SubStr(_cNrMatr,1,6)      // Codigo do Produtor
            ZBI->ZBI_LOJPRO  :=  SubStr(_cNrMatr,8,4)      // Loja do Produtor

            If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
               _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

               ZBI->ZBI_NOMPRO := _cNomeCoop
            Else
               ZBI->ZBI_NOMPRO :=  POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
            EndIf

            ZBI->ZBI_MOTIVO  :=  AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBI->ZBI_DTREJ   :=  Date()                    // Data da Rejeição
            ZBI->ZBI_HRREJ   :=  Time()                    // Hora da Rejeição
            ZBI->ZBI_JSONEN  :=  _cJSonColeta              // Json de Envio
            ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
            ZBI->ZBI_HRENV   :=  Time()                    // Hora de Envio
            ZBI->ZBI_STATUS  :=  "R"                       // Status da Integração
            ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
            ZBI->(MsUnLock())
            _nRejeitados++

         EndIf

         _aColetaEnv := {}
         _cJSonColeta := "["
         _cJSonGrp := ""
         _nI := 0

      EndIf

      _nI += 1

      TRBCOL->(DbSkip())
   EndDo

   If ! Empty(_cJSonGrp)
      _cJSonColeta += _cJSonGrp + "]"
      _nStart 	   := 0
      _nRetry 	   := 0
      _cJSonRet    := Nil
      _nTimOut	   := 120
      _cRetHttp    := ''
      _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonColeta , _nTimOut , _aHeadOut , @_cJSonRet ) )

      If ! Empty(_cRetHttp)
         _cRetHttp := DecodeUtf8(_cRetHttp)

         _cRetHttp := StrTran( _cRetHttp, "\n", "" )
         FWJSonDeserialize(_cRetHttp,@_oRetJSon)
      EndIf

       _cAuxHTTP := Upper(_cRetHttp)

      _lResult := .F.
      If ! Empty(_oRetJSon) .And. "STATUS" $ _cAuxHTTP // "status" $ _cRetHttp
         _lResult := _oRetJSon:status
      EndIf

      If _lResult // Integração realizada COM SUCESSO
         //U_MGLT032W(_aColetaEnv) // Grava na tabela temporária os registros integrados com sucesso para depois ataualizar flag de envio da SA2.

         _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

         //=======================================================================
         // Grava dados das coletas enviadas e aceitas para histórico.
         //=======================================================================
         ZBI->(RecLock("ZBI",.T.))
         ZBI->ZBI_FILIAL  := xFilial("ZBI")             // Filial do Sistema
         ZBI->ZBI_TICKET  := _cNrIdent                  // Ticket
         ZBI->ZBI_DTCOLE  := StoD(_cDataCol)            // Data Coleta
         ZBI->ZBI_CODPRO  := SubStr(_cNrMatr,1,6)       // Codigo do Produtor
         ZBI->ZBI_LOJPRO  := SubStr(_cNrMatr,1,4)       // Loja do Produtor

         If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
            _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

            ZBI->ZBI_NOMPRO := _cNomeCoop
         Else
            ZBI->ZBI_NOMPRO  := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
         EndIf

         ZBI->ZBI_MOTIVO  := AllTrim(_cRetHttp)         // Motivo da Rejeição
         ZBI->ZBI_JSONEN  := _cJSonColeta               // Json de Envio
         ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
         ZBI->ZBI_HRENV	  :=  Time()                    // Hora de Envio
         ZBI->ZBI_STATUS  :=  "A"                       // Status da Integração
         ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
         ZBI->(MsUnLock())

         //==============================================================
         // Atualiza a tabela ZLJ
         //==============================================================
         IF _lEfetivaEnvio .AND. _nRecno > 0 .AND. ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0 // ENVIO DA COLETA
            ZLJ->(DbGoto(_nRecno))
            ZLJ->(RecLock("ZLJ", .F.))
            ZLJ->ZLJ_ENVEVO := "N"
            ZLJ->(MsUnLock())
            _nRecno := 0
         EndIf
      else
         _cDataCol := StrTran(_cDtColeta,"-","")

         _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

         //=======================================================================
         // Grava dados das coletas enviadas e rejeitadas para histórico.
         //=======================================================================
         ZBI->(RecLock("ZBI",.T.))
         ZBI->ZBI_FILIAL  := xFilial("ZBI")             // Filial do Sistema
         ZBI->ZBI_TICKET  := _cNrIdent                  // Ticket
         ZBI->ZBI_DTCOLE  := StoD(_cDataCol)            // Data Coleta
         ZBI->ZBI_CODPRO  := SubStr(_cNrMatr,1,6)       // Codigo do Produtor
         ZBI->ZBI_LOJPRO  := SubStr(_cNrMatr,1,4)       // Loja do Produtor

         If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
            _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

            ZBI->ZBI_NOMPRO := _cNomeCoop
         Else
            ZBI->ZBI_NOMPRO  := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
         EndIf

         ZBI->ZBI_MOTIVO  := AllTrim(_cRetHttp)         // Motivo da Rejeição
         ZBI->ZBI_DTREJ   := Date()                     // Data da Rejeição
         ZBI->ZBI_HRREJ   := Time()                     // Hora da Rejeição
         ZBI->ZBI_JSONEN  := _cJSonColeta               // Json de Envio
         ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
         ZBI->ZBI_HRENV	  :=  Time()                    // Hora de Envio
         ZBI->ZBI_STATUS  :=  "R"                       // Status da Integração
         ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
         ZBI->(MsUnLock())

      EndIf

   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032T
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Efetua o Login no WebService da Evomilk e obtem o Token de acesso.
                     O Período estimado de validade deste Token é de 30 min.
===============================================================================================================================
Parametros---------: _cChamada = "M" = Menu
                                 "S" = Scheduller
===============================================================================================================================
Retorno------------: _cRet = Vazio ou o Token de acesso.
===============================================================================================================================
*/
User Function MGLT032T(_cChamada)
Local _cRet := ""
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cDirJSon, _cLinkWS
Local _cUsuario, _cSenha
Local _aHeadOut := {}
Local _cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")

Default _cChamada := "M"

Begin Sequence

   _cUsuario := ""
   _cSenha   := ""

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _cLinkWS  := AllTrim(ZFM->ZFM_LINK01)   // LINK DE LOGIN E OBTENÇÃO DO TOKEN
      _cUsuario := AllTrim(ZFM->ZFM_USRNOM)
      _cSenha   := AllTrim(ZFM->ZFM_SENHA)
      IF !EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   _nStart 		:= 0
   _nRetry 		:= 0
   _cJSonRet 	:= Nil
   _nTimOut	 	:= 120

   _aHeadOut := {}
   Aadd(_aHeadOut,'Content-Type: application/json')
   //Aadd(_aHeadOut,'Authorization: Basic '+Encode64("api.italac:api.italac.2021"))
   Aadd(_aHeadOut,'Authorization: Basic '+Encode64(_cUsuario + ":" + _cSenha))
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

   _cLinkWS := AllTrim(_cLinkWS)

   _cGetParms := ""

   //_cRetHttp := AllTrim(HttpGet( _cLinkWS, _cGetParms, _nTimOut, _aHeadOut, @_cJSonRet))
   //=======================================================================
   // Envio do JSon
   //=======================================================================
   _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , '{}' , _nTimOut , _aHeadOut , @_cJSonRet ) )

   _oRetJSon := Nil
   _cKey := ""
   _oTokenJSon := Nil

   If ! Empty(_cRetHttp)
      _cRetHttp := StrTran( _cRetHttp, "\n", "" )
      FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
   EndIf

   If ! Empty(_oRetJSon)
      _cKey := _oRetJSon:token
   Else
      Break
   EndIf

   _cRet := _cKey

End Sequence

Return _cRet

/*
===============================================================================================================================
Função-------------: MGLT032X
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição---------: Lê o arquivo JSON modelo no diretório informado e retorna os dados no formato de String.
===============================================================================================================================
Parametros--------: _cArq = diretório + nome do arquivo a ser lido.
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/
User Function MGLT032X(_cArq)
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
Função-------------: MGLT032TXT
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição---------: Lê o arquivo texto no diretório informado e retorna os dados no formato de String.
===============================================================================================================================
Parametros--------: _cArq = diretório + nome do arquivo a ser lido.
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/
Static Function MGLT032TXT(_cArq)
Local _aRet := {}
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
      _cLine := FT_FReadLn()

      _cline :=  AllTrim(_cLine) + ";" + CRLF

      _aDados := U_ITTXTARRAY(_cline,";",3)

      Aadd(_aRet,Aclone(_aDados))

      FT_FSKIP()
   End

   // Fecha o Arquivo
   FT_FUSE()

End Sequence

Return _aRet

/*
===============================================================================================================================
Função-------------: MGLT032Z
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição---------: Verifica se o Produtor possui mais de uma Propridade Rural.
===============================================================================================================================
Parametros--------: _cCodigo  = Código do Produtor/Fornecedor
                    _lSoAtivo = .T. = Só retorna se há produtores ativos para o código informado.
                                .F. = Retorna se há produtores com mais de uma propriedade.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Possui mais de uma Propriedade Rural. Ou existe propriedade ativa.
                            .F. = Possui apenas uma Propriedade Rural. Ou não existe propriedade ativa.
===============================================================================================================================
*/
User Function MGLT032Z(_cCodigo, _lSoAtivo)
Local _lRet := .F.
Local _cQry, _nTotRegs:= 1

Default _lSoAtivo := .F. // Por default retorna se o produtor possui mais de uma propriedade.

Begin Sequence
   _cQry := " SELECT COUNT(*) TOTREGS"
   _cQry += " FROM " + RetSqlName("SA2") + " SA2 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND A2_L_ATIVO <> 'N' "
   _cQry += " AND A2_COD = '" +_cCodigo + "' "
   _cQry += " ORDER BY A2_COD,A2_LOJA "

   If Select("QRY2SA2") > 0
      QRY2SA2->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRY2SA2")

   _nTotRegs := 1 // indica que o produtor deve possuir mais de uma propriedade.

   If _lSoAtivo
      _nTotRegs := 0 // indica que deve existir pelo menos uma propriedade ativa.
   EndIf

   If QRY2SA2->TOTREGS > _nTotRegs
      _lRet := .T. // Possui mais de uma propriedade rural / ou existe propriedade ativa
   Else
      _lRet := .F. // Possui apenas uma propriedade rural
   EndIf

End Sequence

If Select("QRY2SA2") > 0
   QRY2SA2->(DbCloseArea())
EndIf

Return _lRet

/*
===============================================================================================================================
Função-------------: MGLT032Y
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição---------: Grava na tabela temporária os Produtores que foram integrados com sucesso para o sistema Cia Leite.
===============================================================================================================================
Parametros--------: _aDados = Array com os dados dos fornecedores.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT032Y(_aDados)
Local _nI

Begin Sequence

   For _nI := 1 To Len(_aDados)
       TRBSA2->(DbAppend())
       TRBSA2->A2_COD     := _aDados[_nI,1]
       TRBSA2->A2_LOJA    := _aDados[_nI,2]
       TRBSA2->A2_L_FAZEN := _aDados[_nI,3]
       TRBSA2->WK_RECNO   := _aDados[_nI,4]
   Next

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032W
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição---------: Grava na tabela temporária de Coleta de Leite que foram integrados com sucesso para o sistema Cia Leite.
===============================================================================================================================
Parametros--------: _aDados = Array com os dados das coletas de leite.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================

User Function MGLT032W(_aDados)
Local _nI

Begin Sequence

   For _nI := 1 To Len(_aDados)
       TRBZLD->(DbAppend())
       TRBZLD->ZLD_TICKET := _aDados[_nI,1]
       TRBZLD->WK_RECNO   := _aDados[_nI,2]
   Next

End Sequence


Return Nil */

/*
===============================================================================================================================
Função-------------: MGLT032E
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Recebimento de dados dos Produtores Rurais via WebService da Evomilk
===============================================================================================================================
Parametros--------: _cChamada = "M" = Rotina Chamada via menu.
                                "S" = Rotina Chamada via Scheduller
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================

User Function MGLT032E(_cChamada)
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
//Local _oRetJSon, _lResult  // , _nI
Local _cDirJSon, _cLinkWS
Local _oDados
Local _nR, _nX
Local _lResult

Local _aPropdado := {}
Local _aProdDado := {}
Local _cTextoAux := ""
Local _cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")

//Local _cArqTeste := 'JSon_Teste_Produtor.txt'

//======================================================================
// Inicializa as variáveis Principal
//======================================================================
Private _cIdProdutor := "" // "id_produtor"
Private _cMatrLatic  := "" // "matricula_laticinio"
Private _cRazao      := "" // "nome_razao_social"
Private _cCnpj       := "" // "cpf_cnpj"
Private _cIncrEst    := "" // "inscricao_estadual"
Private _cRgIe       := "" // "rg_ie"
Private _dDtNasc     := "" // "data_nascimento_fundacao"
Private _cInfoAdic   := "" // "info_adicional"
Private _cSituacao   := "" // "situacao"  // tag nova

//======================================================================
// Inicializa as variáveis Endereço
//======================================================================
Private _cComplemento := "" // "complemento"
Private _cEndereco    := "" // "endereco"
Private _cNumero      := "" // "numero"
Private _cBairro      := "" // "bairro"
Private _cCep         := "" // "cep"
Private _cIdUf        := "" // "id_uf"
Private _cIdCidade    := "" // "id_cidade"
Private _cCodCidUf    := "" // "cidade_uf"    // tag nova
Private _cCodIbge     := "" // "codigo_ibge"  // tag nova

//======================================================================
// Inicializa as variáveis Contato
//======================================================================
Private _cEmail := "" // "email"
Private _cFone1 := "" // "telefone1"

//=========================================================================
// Inicialização de Variáveis Propriedades
//=========================================================================
Private _cNomeProp   := "" // "nome_propriedade_rural"
Private _cNirf       := "" // "NIRF"
Private _codPropLt   := "" // "codigo_propriedade_laticinio"
Private _cTipoTanq   := "" // "tipo_tanque"
Private _cCapacTanq  := "" // "capacidade_tanque"
Private _nLatitude   := 0  // "latitude_propriedade"
Private _nLongitude  := 0  // "longitude_propriedade"
Private _cArea       := "" // "area"
Private _cRecria     := "" // "recria"
Private _cVacaSeca   := "" // "vaca_seca"
Private _cVacaLact   := "" // "vaca_lactacao"
Private _cHrColeta   := "" // "horario_coleta"
Private _cRacaProp   := "" // "raca_propriedade"
Private _cFreqColeta := "" // "frequencia_coleta"
Private _nProdMedDia := 0  // "producao_media_diaria"
Private _nAreaUtProd := 0  // "area_utilizada_producao"
Private _nCapacRefr  := 0  // "capacidade_refrigeracao"

//=========================================================================
// Nova Tags
//=========================================================================
Private _cTitTanq  := "" // cpf_cnpj
Private _cMatrLat  := "" // matricula_laticinio
Private _cTelefon1 := "" // numero
Private _cTelPrinc := "" // telefone_principal
Private _cWhatsAp1 := "" // is_whatsapp
Private _cEMailPri := "" // email_principal
Private _cCodLinha := "" // codigo_linha_laticinio
Private _cDescLin  := "" // nome_linha
Private _cHoraCole := "" // horario_coleta
Private _cSitTnq   := "" // situacao

//=========================================================================
// Inicialização de Variáveis Outros
//=========================================================================
Private _cDataCad := ""  // "data_cadastro"
Private _cHoraCad := ""  // "hora_cadastro"

Default _cChamada := "M"

Begin Sequence

   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _cLinkWS  := AllTrim(ZFM->ZFM_LINK07)  // Link de envio de Produtores.
      IF !EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

   If Empty(_cKey)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid)  // Aadd(_aHeadOut,'TENANTID: LATITATE1')

   _nStart 		:= 0
   _nRetry 		:= 0
   _cJSonRet 	:= Nil
   _nTimOut	 	:= 120
   _cGetParms  := ""
   _cRetHttp   := ''
   _OJSonRet   := ""
   _ORETJSON   := ""

   _cRetHttp := AllTrim(HttpGet( _cLinkWS, _cGetParms, _nTimOut, _aHeadOut, @_cJSonRet))

   _cTextoAux := ""

   If ! Empty(_cRetHttp)
      _cTextoAux := DecodeUTF8(_cRetHttp, "cp1252")
   EndIf

   If ! Empty(_cTextoAux)
      _aExcecao := {{"\","-"},{char(9)," "}}  // Char(9) = Tecla Tab.
      _cTextoAux := U_ITSUBCHR(_cTextoAux, _aExcecao)
   EndIf

   If ! Empty(_cTextoAux)
      _cTextoAux := StrTran(_cTextoAux,"-/","\/")
      _cRetHttp := _cTextoAux
   EndIf

   _oJson := JsonObject():new()

   _cRet := _oJson:FromJson(_cRetHttp)

   If ! ValType(_cRet) == "U"
      _cMsgErro := "[FALSO] Erro ao popular o JSon de retorno da Evomilk. Problemas no JSon de retorno."
      Break
   EndIf

   _aNames := _oJson:GetNames()

   _lResult := _oJson:GetJsonObject("status")

   If ! _lResult
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Não foi possível obter o retorno dos dados dos Produtores.","Atenção",,1)
      EndIf
      Break
   EndIf

   _oDados := _oJson:GetJsonObject("data")

   For _nR := 1 To Len(_oDados)

       _aPropdado := {}
       _aProdDado := {}

       _oItDados := _oDados[_nR]

       _cDetJson := _oItDados:toJson()  // Retorna o JSon de _oItDados no formato Texto.

       _oPropried := _oItDados:GetJsonObject("propriedades")

       _oProdutor := _oItDados:GetJsonObject("produtor")

       If ValType(_oProdutor) <> "J"
          Loop
       EndIf
//-----------------------------------------------------------------
       _aProdutor := _oProdutor:GetNames()

       //===================================================================
       // Inicializa variáveis.
       //===================================================================
       _cRazao      := ""    // "nome_razao_social"
       _cCnpj       := ""    // "cpf_cnpj"
       _cIncrEst    := ""    // "inscricao_estadual"
       _cRgIe       := ""    // "rg_ie"
       _dDtNasc     := ""    // "data_nascimento_fundacao"
       _cInfoAdic   := ""    // "info_adicional"
       _cSituacao   := ""    // "situacao"
       _cNrTel      := ""    // "telefones" // "numero"
       _cCWhats     := ""    // "whatsapp"
       _cCompl      := ""    // -- "endereco"  // "complemento"
       _cEnd        := ""    // "endereco"
       _cNum        := ""    // "numero"
       _cBair       := ""    // "bairro"
       _cCep        := ""    // "cep"
       _CidUf       := ""    // "cidade_uf"
       _cEmail      := ""    // -- Emails // "email"
       _cNomeBco    := ""    // -- Banco // "nome_banco"
       _cBanco      := ""    // "banco"
       _cAgencia    := ""    // "agencia"
       _cConta      := ""    // "conta"
       _cTipoCont   := ""    // "tipo"
       _cTitular    := ""    // "nome_titular_conta"
       _cInfoAdic   := ""    // "informacao_adicional"
       _cContaPri   := ""    // "conta_principal"
       _cCpfParca   := ""    // -- "produtor_parceiro_de" // "cpf_cnpj"
       _cMatriLat   := ""    // "matricula_laticinio"
       //===============================================================
       _cClassProd  := ""    // "classificacao_produtor"
       _cRacaProp   := ""    // "raca_propriedade"
       _nAreaUtProd := ""    // "area_utilizada_producao"
       _cFreqColeta := ""    // "frequencia_coleta"
       _nLatitude   := ""    // "latitude_propriedade"
       _nLongitude  := ""    // "longitude_propriedade"
       _cArea       := ""    // "area"
       _cRecria     := ""    // "recria"
       _cVacaSeca   := ""    // "vaca_seca"
       _cNomeProp   := ""    // "nome_propriedade_rural"
       _cMatrProp   := ""    // "matricula_laticinio"
       _cSituacao   := ""    // "situacao"
       _cNirf       := ""    // "NIRF"
       _cSigsif     :=  ""   // "sigsif"
       _cVacaLact   := ""    // "vaca_lactacao"
       _cHrColeta   := ""    // "horario_coleta"
       _cRacaProp   := ""    // "raca_propriedade"
       _cFreqColeta := ""    // "frequencia_coleta"
       _nProdMedDia := ""    // "producao_media_diaria"
       _nAreaUtProd := ""    // "area_utilizada_producao"
       _nCapacRefr  := ""    // "capacidade_refrigeracao"
       _cTCpfcnpj   := ""    // "titular_tanque_comunitario"  // "cpf_cnpj"
       _cTMatLati   := ""    // "matricula_laticinio"
       _cComplEnd   := ""    // "endereco" // "complemento"
       _cEnderEnd   := ""    // "endereco"
       _cNrEndEnd   := ""    // "numero"
       _cBairrEnd   := ""    // "bairro"
       _cCEPEnd     := ""    // "cep"
       _cCidUfEnd   := ""    // "cidade_uf"
       _cNrTelPro   := ""    // "telefones" // "numero"
       _cWhatsPro   := ""    // "whatsapp"
       _cEmailPro   := ""    // "emails" // "email"
       _cNomeLin    := ""    // "linha" // "nome_linha"
       _cCodLin     := ""    // "codigo_linha_laticinio"
       _cTipoTanq   := ""    // "tanques" // "tipo_tanque"
       _cCapacTanq  := ""    // "capacidade_tanque"
       _cNomeTanq   := ""    // "nome_tanque"
       _cCodTanq    := ""    // "codigo_tanque"
       _cTipResfr   := ""    // "tanque_tipo_resfriamento"
       _cMarcaTnq   := ""    // "marca"
       _nCapacid    := ""    // "capacidade_resfriamento"
       _cSitTnq     := ""    // "situacao"
       _cDtFabric   := ""    // "dt_fabricacao"
       //==================================================================

       _nI := Ascan(_aProdutor, "nome_razao_social" )
       If _nI > 0
          _cRazao := _oProdutor[_aProdutor[_nI]]
       EndIf

       _nI := Ascan(_aProdutor, "cpf_cnpj" )
       If _nI > 0
          _cCnpj := _oProdutor[_aProdutor[_nI]]
       EndIf

       _nI := Ascan(_aProdutor, "inscricao_estadual" )
       If _nI > 0
          _cIncrEst := _oProdutor[_aProdutor[_nI]]
       EndIf

       _nI := Ascan(_aProdutor, "rg_ie" )
       If _nI > 0
          _cRgIe := _oProdutor[_aProdutor[_nI]]
       EndIf

       _nI := Ascan(_aProdutor, "data_nascimento_fundacao" )
       If _nI > 0
          _dDtNasc := _oProdutor[_aProdutor[_nI]]
       EndIf

       _nI := Ascan(_aProdutor, "info_adicional" )
       If _nI > 0
          _cInfoAdic := _oProdutor[_aProdutor[_nI]]
       EndIf

       _nI := Ascan(_aProdutor, "situacao" )
       If _nI > 0
          _cSituacao := _oProdutor[_aProdutor[_nI]]
       EndIf
       //-------------------------------------------------------
       _oTelefones := _oProdutor:GetJsonObject("telefones")
//       _nI := Ascan(_oProdutor, "telefones")
//       If _nI > 0
//          _oTelefones := _oProdutor[_nI]
//       EndIf
//       _aTelefones := _oTelefones:GetNames()

       //-------------------------------------------------------
       If Len(_oTelefones) > 0
          // _nI := Ascan(_aProdutor, "telefones" )
          _aTelefones := _oTelefones[1] //_oProdutor[_aProdutor[_nI]]
          _aNameTel   := _aTelefones:GetNames()

         _nI := Ascan(_aNameTel, "numero" )
         If _nI > 0
            _cNrTel := _aTelefones[_aNameTel[_nI]]
         EndIf

         _nI := Ascan(_aNameTel, "whatsapp" )
         If _nI > 0
            _cCWhats := _aTelefones[_aNameTel[_nI]]
         EndIf
      EndIf
      //-------------------------------------------------------
      _oEndereco := _oProdutor:GetJsonObject("endereco")
      _aEndereco := _oEndereco
      _aNomeEnd   := _aEndereco:GetNames()

      _nI := Ascan(_aNomeEnd, "complemento" )
      If _nI > 0
         _cCompl := _aEndereco[_aNomeEnd[_nI]]
      EndIf

      _nI := Ascan(_aNomeEnd, "endereco" )
      If _nI > 0
         _cEnd := _aEndereco[_aNomeEnd[_nI]]
      EndIf

      _nI := Ascan(_aNomeEnd, "numero" )
      If _nI > 0
         _cNum := _aEndereco[_aNomeEnd[_nI]]
      EndIf

      _nI := Ascan(_aNomeEnd, "bairro" )
      If _nI > 0
         _cBair := _aEndereco[_aNomeEnd[_nI]]
      EndIf

      _nI := Ascan(_aNomeEnd, "cep" )

      If _nI > 0
         _cCep := _aEndereco[_aNomeEnd[_nI]]
      EndIf

      _nI := Ascan(_aNomeEnd, "cidade_uf" )
      If _nI > 0
         _cCidUf := _aEndereco[_aNomeEnd[_nI]]
      EndIf

      //------------------------------------------------------------
      _oEmails := _oProdutor:GetJsonObject("emails")
      If Len(_oEmails) > 0
         //_nI := Ascan(_aProdutor, "emails" )
         _aEmails   := _oEmails[1] // _oProdutor[_aProdutor[_nI]]
         _aNomeMail := _aEmails:GetNames()

        _nI := Ascan(_aNomeMail, {|x| x== "email"} )
        If _nI > 0
           _cEmail := _aEmails[_aNomeMail[_nI]]
        EndIf

     EndIf

     //------------------------------------------------------------
     _oDadosBco := _oProdutor:GetJsonObject("dados_bancarios")
     If Len(_oDadosBco) > 0
        //_nI := Ascan(_aProdutor, "dados_bancarios" )
        _aDadosBco := _oDadosBco[1] // _oDados[_aDados[_nI]]
        _aNomeDBco := _aDadosBco:GetNames()

        _nI := Ascan(_aNomeDBco, "nome_banco" )
        If _nI > 0
           _cNomeBco := _aDadosBco[_aNomeDBco[_nI]]
        EndIf

        _nI := Ascan(_aNomeDBco, "banco" )
        If _nI > 0
           _cBanco := _aDadosBco[_aNomeDBco[_nI]]
        EndIf

        _nI := Ascan(_aNomeDBco, "agencia" )
        If _nI > 0
           _cAgencia := _aDadosBco[_aNomeDBco[_nI]]
        EndIf

        _nI := Ascan(_aNomeDBco, "conta" )
        If _nI > 0
           _cConta := _aDadosBco[_aNomeDBco[_nI]]
        EndIf

        _nI := Ascan(_aNomeDBco, "tipo" )
        If _nI > 0
           _cTipoCont := _aDadosBco[_aNomeDBco[_nI]]
        EndIf

        _nI := Ascan(_aNomeDBco, "nome_titular_conta" )

        If _nI > 0
           _cTitular := _aDadosBco[_aNomeDBco[_nI]]
        EndIf

        _nI := Ascan(_aNomeDBco, "informacao_adicional" )
        If _nI > 0
           _cInfoAdic := _aDadosBco[_aNomeDBco[_nI]]
        EndIf

        _nI := Ascan(_aNomeDBco, "conta_principal" )
        If _nI > 0
           _cContaPri := _aDadosBco[_aNomeDBco[_nI]]
        EndIf
     EndIf
     //------------------------------------------------------------
     _oParcaDe := _oProdutor:GetJsonObject("produtor_parceiro_de")
     If Len(_oParcaDe) > 0
        //_nI := Ascan(_aDados, "produtor_parceiro_de" )
        _aParcaDe := _oParcaDe[1] // _oProdutor[_aDados[_nI]]
        _aNomeParca := _aParcaDe:GetNames()

        _nI := Ascan(_aNomeParca, "cpf_cnpj" )
        If _nI > 0
           _cCpfParca := _aParcaDe[_aNomeParca[_nI]]
        EndIf

        _nI := Ascan(_aNomeParca, "matricula_laticinio" )
        If _nI > 0
           _cMatriLat := _aParcaDe[_aNomeParca[_nI]]
        EndIf

     EndIf

     //================================================================================================
     // DADOS DOS PRODUTORES
     //================================================================================================
     Aadd(_aProdDado, {_cRazao,;    // "nome_razao_social"                      // 1
                        _cCnpj,;     // "cpf_cnpj"                              // 2
                         _cIncrEst,;  // "inscricao_estadual"                   // 3
                        _cRgIe,;     // "rg_ie"                                 // 4
                        _dDtNasc,;   // "data_nascimento_fundacao"              // 5
                        _cInfoAdic,; // "info_adicional"                        // 6
                        _cSituacao,; // "situacao"                              // 7
                        _cNrTel,;    // "telefones" // "numero"                 // 8
                        _cCWhats ,;  // "whatsapp"                              // 9
                        _cCompl,;    // -- "endereco"  // "complemento"         // 10
                        _cEnd,;      // "endereco"                              // 11
                        _cNum,;      // "numero"                                // 12
                        _cBair,;     // "bairro"                                // 13
                        _cCep,;      // "cep"                                   // 14
                        _cCidUf,;    // "cidade_uf"                             // 15
                        _cEmail,;    // -- Emails // "email"                    // 16
                        _cNomeBco,;  // -- Banco // "nome_banco"                // 17
                        _cBanco,;    // "banco"                                 // 18
                        _cAgencia,;  // "agencia"                               // 19
                        _cConta,;    // "conta"                                 // 20
                        _cTipoCont,; // "tipo"                                  // 21
                        _cTitular ,; // "nome_titular_conta"                    // 22
                        _cInfoAdic,; // "informacao_adicional"                  // 23
                        _cContaPri,; // "conta_principal"                       // 24
                        _cCpfParca,; // -- "produtor_parceiro_de" // "cpf_cnpj" // 25
                        _cMatriLat}) // "matricula_laticinio"                   // 26

     //------------------------------------------------------------
     //_oPropried := _oJson:GetJsonObject("propriedades")
     //_oPropried := _oItDados:GetJsonObject("propriedades")  <<<<
     //_nI := Ascan(_aDados, "propriedades" )
     //_aPropriedades := _oDados[_aDados[_nI]]

     For _nX := 1 To Len(_oPropried)

         _aPropriedades := _oPropried[_nX]

         _aItemProp := _aPropriedades //[_nX]

         _aNameItProp := _aItemProp:GetNames()

         _nI := Ascan(_aNameItProp, "classificacao_produtor" )
         If _nI > 0
            _cClassProd := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "raca_propriedade")
         If _nI > 0
            _cRacaProp := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "area_utilizada_producao")
         If _nI > 0
            _nAreaUtProd := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "frequencia_coleta")
         If _nI > 0
            _cFreqColeta := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "latitude_propriedade")
         If _nI > 0
            _nLatitude := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "longitude_propriedade")
         If _nI > 0
            _nLongitude := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "area")
         If _nI > 0
            _cArea := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "recria")
         If _nI > 0
            _cRecria := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "vaca_seca")
         If _nI > 0
            _cVacaSeca := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "nome_propriedade_rural")
         If _nI > 0
            _cNomeProp := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "matricula_laticinio")
         If _nI > 0
            _cMatrProp := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "situacao")
         If _nI > 0
            _cSituacao := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "nirf")  // "NIRF"
         If _nI > 0
            _cNirf := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "sigsif")
         If _nI > 0
            _cSigsif := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "vaca_lactacao")
         If _nI > 0
            _cVacaLact := _aItemProp[_aNameItProp[_nI]]
         EndIf
//--------------------------------------------------------//
         _nI := Ascan(_aNameItProp, "horario_coleta")
         If _nI > 0
            _cHrColeta := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "raca_propriedade")
         If _nI > 0
            _cRacaProp := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "frequencia_coleta")
         If _nI > 0
            _cFreqColeta := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "producao_media_diaria")
         If _nI > 0
            _nProdMedDia := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "area_utilizada_producao")
         If _nI > 0
            _nAreaUtProd  := _aItemProp[_aNameItProp[_nI]]
         EndIf

         _nI := Ascan(_aNameItProp, "capacidade_refrigeracao")
         If _nI > 0
            _nCapacRefr:= _aItemProp[_aNameItProp[_nI]]
         EndIf

//----------------------------------------------------
         _nI := Ascan(_aNameItProp, "titular_tanque_comunitario")
         If _nI > 0
            _aTitTnqCo := _aItemProp[_aNameItProp[_nI]]
            If ValType(_aTitTnqCo) == "J"
               _aNameTTnq := _aTitTnqCo:GetNames()

               _nI := Ascan(_aNameTTnq, "cpf_cnpj" )
               If _nI > 0
                  _cTCpfcnpj := _aTitTnqCo[_aNameTTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTTnq, "matricula_laticinio" )
               If _nI > 0
                  _cTMatLati := _aTitTnqCo[_aNameTTnq[_nI]]
               EndIf
            EndIf
         EndIf

//----------------------------------------------------
         _nI := Ascan(_aNameItProp, "endereco")
         If _nI > 0
            _aEndProp  := _aItemProp[_aNameItProp[_nI]]
            _aNameEndP := _aEndProp:GetNames()

            _nI := Ascan(_aNameEndP, "complemento" )
            If _nI > 0
               _cComplEnd := _aEndProp[_aNameEndP[_nI]]
            EndIf

            _nI := Ascan(_aNameEndP, "endereco" )
            If _nI > 0
               _cEnderEnd := _aEndProp[_aNameEndP[_nI]]
            EndIf

            _nI := Ascan(_aNameEndP, "numero" )
            If _nI > 0
               _cNrEndEnd := _aEndProp[_aNameEndP[_nI]]
            EndIf

            _nI := Ascan(_aNameEndP, "bairro" )
            If _nI > 0
               _cBairrEnd := _aEndProp[_aNameEndP[_nI]]
            EndIf

            _nI := Ascan(_aNameEndP, "cep" )
            If _nI > 0
               _cCEPEnd := _aEndProp[_aNameEndP[_nI]]
            EndIf

            _nI := Ascan(_aNameEndP, "cidade_uf" )
            If _nI > 0
               _cCidUfEnd := _aEndProp[_aNameEndP[_nI]]
            EndIf
         EndIf
//-----------------------------------------------------------
         _nI := Ascan(_aNameItProp, "telefones")
         If _nI > 0
            _oTelProp  := _aItemProp[_aNameItProp[_nI]]
            If Len(_oTelProp) > 0
               _aTelProp := _oTelProp[1]
               _aNameTelP := _aTelProp:GetNames()

               _nI := Ascan(_aNameTelP, "numero" )
               If _nI > 0
                  _cNrTelPro := _aTelProp[_aNameTelP[_nI]]
               EndIf
               _nI := Ascan(_aNameTelP, "whatsapp" )
               If _nI > 0
                  _cWhatsPro := _aTelProp[_aNameTelP[_nI]]
               EndIf
            EndIf
         EndIf

//----------------------------------------------------------
         _nI := Ascan(_aNameItProp, "emails")
         If _nI > 0
            _oEmailPro  := _aItemProp[_aNameItProp[_nI]]
            If Len(_oEmailPro) > 0
               _aEmailPro := _oEmailPro[1]
               _aNameEmai := _aEmailPro:GetNames()

               _nI := Ascan(_aNameEmai, {|x| x== "email"} )
               _cEmailPro := _aEmailPro[_aNameEmai[_nI]]
            EndIf
         EndIf
//----------------------------------------------------------
         _nI := Ascan(_aNameItProp, "linha" )
         If _nI > 0
            _oLinha := _aItemProp[_aNameItProp[_nI]]
            If Len(_oLinha) > 0
               _aLinha := _oLinha[1]
               _aNameLin := _aLinha:GetNames()

               _nI := Ascan(_aNameLin, "nome_linha" )
               If _nI > 0
                  _cNomeLin := _aLinha[_aNameLin[_nI]]
               EndIf
               _nI := Ascan(_aNameLin, "codigo_linha_laticinio" )
               If _nI > 0
                  _cCodLin  := _aLinha[_aNameLin[_nI]]
               EndIf
            EndIf
         EndIf
//----------------------------------------------------------
         _nI := Ascan(_aNameItProp, "tanques")
         If _nI > 0
            _oTnqProp  := _aItemProp[_aNameItProp[_nI]]

            If Len(_oTnqProp) > 0
               _aTnqProp := _oTnqProp[1]
               _aNameTnq  := _aTnqProp:GetNames()

               _nI := Ascan(_aNameTnq, "tipo_tanque" )
               If _nI > 0
                  _cTipoTanq := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "capacidade_tanque" )
               If _nI > 0
                  _cCapacTanq := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "nome_tanque" )
               If _nI > 0
                  _cNomeTanq := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "codigo_tanque" )
               If _nI > 0
                  _cCodTanq := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "tanque_tipo_resfriamento" )
               If _nI > 0
                  _cTipResfr := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "marca" )
               If _nI > 0
                  _cMarcaTnq := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "capacidade_resfriamento" )
               If _nI > 0
                  _nCapacRefr := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "situacao" )
               If _nI > 0
                  _cSitTnq := _aTnqProp[_aNameTnq[_nI]]
               EndIf

               _nI := Ascan(_aNameTnq, "dt_fabricacao" )
               If _nI > 0
                  _cDtFabric := _aTnqProp[_aNameTnq[_nI]]
               EndIf
            EndIf
         EndIf

         //====================================================================
         // DADOS DAS PROPRIEDADES
         //====================================================================
         Aadd(_aPropdado, {_cClassProd,; // "classificacao_produtor"       // 1
                            _cRacaProp,;   // "raca_propriedade"           // 2
                            _nAreaUtProd,; // "area_utilizada_producao"    // 3
                            _cFreqColeta,; // "frequencia_coleta"          // 4
                            _nLatitude,;   // "latitude_propriedade"       // 5
                            _nLongitude,;  // "longitude_propriedade"      // 6
                            _cArea,;       // "area"                       // 7
                            _cRecria,;     // "recria"                     // 8
                            _cVacaSeca,;   // "vaca_seca"                  // 9
                            _cNomeProp,;   // "nome_propriedade_rural"     // 10
                            _cMatrProp,;   // "matricula_laticinio"        // 11
                            _cSituacao,;   // "situacao"                   // 12
                            _cNirf,;       // "NIRF"                       // 13
                            _cSigsif,;     // "sigsif"                     // 14
                            _cVacaLact,;   // "vaca_lactacao"              // 15
                            _cHrColeta,;   // "horario_coleta"             // 16
                            _cRacaProp,;   // "raca_propriedade"           // 17
                            _cFreqColeta,; // "frequencia_coleta"          // 18
                            _nProdMedDia,; // "producao_media_diaria"      // 19
                            _nAreaUtProd,; // "area_utilizada_producao"    // 20
                            _nCapacRefr,;  // "capacidade_refrigeracao"    // 21
                            _cTCpfcnpj,;   //"titular_tanque_comunitario"  // "cpf_cnpj" // 22
                            _cTMatLati,;   // "matricula_laticinio"        // 23
                            _cComplEnd,;   // "endereco" // "complemento"  // 24
                            _cEnderEnd,;   // "endereco"                   // 25
                            _cNrEndEnd,;   // "numero"                     // 26
                            _cBairrEnd,;   // "bairro"                     // 27
                            _cCEPEnd,;     // "cep"                        // 28
                            _cCidUfEnd,;   // "cidade_uf"                  // 29
                            _cNrTelPro,;   // "telefones" // "numero"      // 30
                            _cWhatsPro,;   // "whatsapp"                   // 31
                            _cEmailPro,;   // "emails" // "email"          // 32
                            _cNomeLin,;    // "linha" // "nome_linha"      // 33
                            _cCodLin,;     // "codigo_linha_laticinio"     // 34
                            _cTipoTanq,;   // "tanques" // "tipo_tanque"   // 35
                            _cCapacTanq,;  // "capacidade_tanque"          // 36
                            _cNomeTanq,;   // "nome_tanque"                // 37
                            _cCodTanq,;    // "codigo_tanque"              // 38
                            _cTipResfr,;   // "tanque_tipo_resfriamento"   // 39
                            _cMarcaTnq,;   // "marca"                      // 40
                            _nCapacRefr,;  // "capacidade_resfriamento"    // 41
                            _cSitTnq,;     // "situacao"                   // 42
                            _cDtFabric})   // "dt_fabricacao"              // 43

     Next

/*
     //=========================================================
     // Grava os dados do JSon no Array _aDadosProp.?
     //=========================================================
     Aadd(_aDadosProp, { _cNomeProp,;   // "nome_propriedade_rural"
                         _cNirf,;       // "NIRF"
                         _codPropLt,;   // "codigo_propriedade_laticinio"
                         _cTipoTanq,;   // "tipo_tanque"
                         _cCapacTanq,;  // "capacidade_tanque"
                         _nLatitude,;   // "latitude_propriedade"
                         _nLongitude,;  // "longitude_propriedade"
                         _cArea,;       // "area"
                         _cRecria,;     // "recria"
                         _cVacaSeca,;   // "vaca_seca"
                         _cVacaLact,;   // "vaca_lactacao"
                         _cHrColeta,;   // "horario_coleta"
                         _cRacaProp,;   // "raca_propriedade"
                         _cFreqColeta,; // "frequencia_coleta"
                         _nProdMedDia,; // "producao_media_diaria"
                         _nAreaUtProd,; // "area_utilizada_producao"
                         _nCapacRefr})  // "capacidade_refrigeracao"
*/

/*
      //=========================================================
      // Grava os dados do JSon no Array _aDadosProp.
      //=========================================================
      //Aadd(_aDadosProp, { _cNomeProp,;   // "nome_propriedade_rural"
      //                    _cNirf,;       // "NIRF"
      //                    _codPropLt,;   // "codigo_propriedade_laticinio"
      //                    _cTipoTanq,;   // "tipo_tanque"
      //                    _cCapacTanq,;  // "capacidade_tanque"
      //                    _nLatitude,;   // "latitude_propriedade"
      //                    _nLongitude,;  // "longitude_propriedade"
      //                    _cArea,;       // "area"
      //                    _cRecria,;     // "recria"
      //                    _cVacaSeca,;   // "vaca_seca"
      //                    _cVacaLact,;   // "vaca_lactacao"
      //                    _cHrColeta,;   // "horario_coleta"
      //                    _cRacaProp,;   // "raca_propriedade"
      //                    _cFreqColeta,; // "frequencia_coleta"
      //                    _nProdMedDia,; // "producao_media_diaria"
      //                    _nAreaUtProd,; // "area_utilizada_producao"
      //                    _nCapacRefr})  // "capacidade_refrigeracao"

// Dados do Produtor    = _aProdDado
// Dados da Propriedade = _aPropdado
      //U_MGLT032F(_aDadosProp, _cRetHttp)
      U_MGLT032F(_aProdDado, _aPropdado, _cDetJson)

   Next



End Sequence

Return Nil */

/*
===============================================================================================================================
Função-------------: MGLT032F
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Grava os dados do JSon nas tabelas Cad.Aprovação Atualiza Produtores ZBG.
                     Para atualização do cadastro de produtores rurais.
===============================================================================================================================
Parametros---------: _aProdutor == Dados do produtor principal
                     _aPropried == Dados das propriedades
                     _cJsonRec  == JSon utilizado na leitura dos dados
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================

User Function MGLT032F(_aProdutor, _aPropried, _cJsonRec)
Local _nI , _nY
Local _cCod, _cLoja
Local _cCnpjProd, _cCepProd
Local _cLongitude, _cLatitude
Local _cQry , _cFilZL3, _cCondLinha
Local _cUF, _cMunicip
Local _lNovoProd

Begin Sequence

   //SA2->(DbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA

   For _nY := 1 To Len(_aPropried)
//--------------------------------------------------------------------------------------
/*
//================================================================================================
     // DADOS DOS PRODUTORES
     //================================================================================================
     Aadd(_aProdDado, {_cRazao,;    // "nome_razao_social"                      // 1
                        _cCnpj,;     // "cpf_cnpj"                              // 2
                         _cIncrEst,;  // "inscricao_estadual"                   // 3
                        _cRgIe,;     // "rg_ie"                                 // 4
                        _dDtNasc,;   // "data_nascimento_fundacao"              // 5
                        _cInfoAdic,; // "info_adicional"                        // 6
                        _cSituacao,; // "situacao"                              // 7
                        _cNrTel,;    // "telefones" // "numero"                 // 8
                        _cCWhats ,;  // "whatsapp"                              // 9
                        _cCompl,;    // -- "endereco"  // "complemento"         // 10
                        _cEnd,;      // "endereco"                              // 11
                        _cNum,;      // "numero"                                // 12
                        _cBair,;     // "bairro"                                // 13
                        _cCep,;      // "cep"                                   // 14
                        _cCidUf,;    // "cidade_uf"                             // 15
                        _cEmail,;    // -- Emails // "email"                    // 16
                        _cNomeBco,;  // -- Banco // "nome_banco"                // 17
                        _cBanco,;    // "banco"                                 // 18
                        _cAgencia,;  // "agencia"                               // 19
                        _cConta,;    // "conta"                                 // 20
                        _cTipoCont,; // "tipo"                                  // 21
                        _cTitular ,; // "nome_titular_conta"                    // 22
                        _cInfoAdic,; // "informacao_adicional"                  // 23
                        _cContaPri,; // "conta_principal"                       // 24
                        _cCpfParca,; // -- "produtor_parceiro_de" // "cpf_cnpj" // 25
                        _cMatriLat}) // "matricula_laticinio"                   // 26
*/

/*
       //====================================================================
         // DADOS DAS PROPRIEDADES
         //====================================================================
         Aadd(_aPropdado, {_cClassProd,;   // "classificacao_produtor"     // 1
                            _cRacaProp,;   // "raca_propriedade"           // 2
                            _nAreaUtProd,; // "area_utilizada_producao"    // 3
                            _cFreqColeta,; // "frequencia_coleta"          // 4
                            _nLatitude,;   // "latitude_propriedade"       // 5
                            _nLongitude,;  // "longitude_propriedade"      // 6
                            _cArea,;       // "area"                       // 7
                            _cRecria,;     // "recria"                     // 8
                            _cVacaSeca,;   // "vaca_seca"                  // 9
                            _cNomeProp,;   // "nome_propriedade_rural"     // 10
                            _cMatrProp,;   // "matricula_laticinio"        // 11
                            _cSituacao,;   // "situacao"                   // 12
                            _cNirf,;       // "NIRF"                       // 13
                            _cSigsif,;     // "sigsif"                     // 14
                            _cVacaLact,;   // "vaca_lactacao"              // 15
                            _cHrColeta,;   // "horario_coleta"             // 16
                            _cRacaProp,;   // "raca_propriedade"           // 17
                            _cFreqColeta,; // "frequencia_coleta"          // 18
                            _nProdMedDia,; // "producao_media_diaria"      // 19
                            _nAreaUtProd,; // "area_utilizada_producao"    // 20
                            _nCapacRefr,;  // "capacidade_refrigeracao"    // 21
                            _cTCpfcnpj,;   // "titular_tanque_comunitario" // "cpf_cnpj" // 22
                            _cTMatLati,;   // "matricula_laticinio"        // 23
                            _cComplEnd,;   // "endereco" // "complemento"  // 24
                            _cEnderEnd,;   // "endereco"                   // 25
                            _cNrEndEnd,;   // "numero"                     // 26
                            _cBairrEnd,;   // "bairro"                     // 27
                            _cCEPEnd,;     // "cep"                        // 28
                            _cCidUfEnd,;   // "cidade_uf"                  // 29
                            _cNrTelPro,;   // "telefones" // "numero"      // 30
                            _cWhatsPro,;   // "whatsapp"                   // 31
                            _cEmailPro,;   // "emails" // "email"          // 32
                            _cNomeLin,;    // "linha" // "nome_linha"      // 33
                            _cCodLin,;     // "codigo_linha_laticinio"     // 34
                            _cTipoTanq,;   // "tanques" // "tipo_tanque"   // 35
                            _cCapacTanq,;  // "capacidade_tanque"          // 36
                            _cNomeTanq,;   // "nome_tanque"                // 37
                            _cCodTanq,;    // "codigo_tanque"              // 38
                            _cTipResfr,;   // "tanque_tipo_resfriamento"   // 39
                            _cMarcaTnq,;   // "marca"                      // 40
                            _nCapacRefr,;  // "capacidade_resfriamento"    // 41
                            _cSitTnq,;     // "situacao"                   // 42
                            _cDtFabric})   // "dt_fabricacao"              // 43
*/
/*
      //========================================================================
      _cCondLinha := ""
      If ! Empty(_aPropried[_nY, 34]) // Código da Linha Laticinio
         _cCondLinha := AllTrim(_aPropried[_nY, 34])
      EndIf

      _cFilZL3 := "01"

      If ! Empty(_cCondLinha)
         _cQry := " SELECT ZL3_FILIAL "       // numero_identificador: "06019"
         _cQry += " FROM " + RetSqlName("ZL3") + " ZL3 "
         _cQry += " WHERE ZL3.D_E_L_E_T_ = ' ' "
         _cQry += " AND ZL3_COD = '" + _cCondLinha + "' "
         _cQry += " ORDER BY ZL3_FILIAL "

         If Select("QRYZL3") > 0
            QRYZL3->(DbCloseArea())
         EndIf

         MPSysOpenQuery( _cQry , "QRYZL3")


         If ! QRYZL3->(Eof()) .And. ! QRYZL3->(Bof())
            _cFilZL3 := QRYZL3->ZL3_FILIAL
         EndIf

         If Select("QRYZL3") > 0
            QRYZL3->(DbCloseArea())
         EndIf
      EndIf

      If Empty(_cFilZL3)
         _cFilZL3 := "01"
      EndIf

      //==================================================================

      _cMatrLatic := "" // Matricula da Propriedade
      _cCod  := ""
      _cLoja := ""

      If ! Empty(_aPropried[_nY, 11])
         _cMatrLatic := _aPropried[_nY, 11]  // Matricula da Propriedade

          _nI    := AT( "-", _cMatrLatic )
          _cCod  := SubStr(_cMatrLatic,1,6)
          If _nI > 0
             _cLoja := SubStr(_cMatrLatic,_nI+1,4)
          Else
            _cLoja := SubStr(_cMatrLatic,7,4)
         EndIf
      EndIf

      _cCnpj := ""
      _cCnpjProd := ""

      If ! Empty(_aProdutor[1,2])
         _cCnpj := _aProdutor[1,2] // CPF_CNPJ Produtor

         _cCnpjProd := AllTrim(StrTran( _cCnpj, ".", "" ))
         _cCnpjProd := AllTrim(StrTran( _cCnpjProd, "-", "" ))
         _cCnpjProd := AllTrim(StrTran( _cCnpjProd , "/", "" ))
      EndIf

       _cCep     := ""
       _cCepProd := ""

       If ! Empty(_aPropried[_nY, 28])
          _cCep      := _aPropried[_nY, 28] // CEP da Propriedade

          _cCepProd  := AllTrim(StrTran( _cCep, "-", "" ))
          _cCepProd  := AllTrim(StrTran( _cCepProd, ".", "" ))
          //=============================================================
       EndIf

      //=================================================================
      // Verifica se o Produto já está cadastrado no Protheus
      //=================================================================
      _lNovoProd := .F.
      If ! Empty(_cCod)
         SA2->(DbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
         If ! SA2->(MsSeek(xFilial("SA2")+U_ITKEY(_cCod, "A2_COD")+U_ITKEY(_cLoja, "A2_LOJA")))
            If ! Empty(_cCnpjProd)
               SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
               If ! SA2->(MsSeek(xFilial("SA2")+U_ITKEY(_cCnpjProd, "A2_CGC")))
                  _lNovoProd := .T.
               EndIf
            Else
               _lNovoProd := .T.
            EndIf
         EndIf
      ElseIf ! Empty(_cCnpjProd)
         SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
         If ! SA2->(MsSeek(xFilial("SA2")+U_ITKEY(_cCnpjProd, "A2_CGC")))
            _lNovoProd := .T.
         EndIf
      EndIf

       ZBG->(RecLock("ZBG",.T.))
       ZBG->ZBG_FILIAL := _cFilZL3 // xFilial("ZBG")

       ZBG->ZBG_IDPROD := _cMatrLatic // Matricula da Propriedade

       If _lNovoProd // Empty(_cCod)
          ZBG->ZBG_TIPREG := "N"
       Else
          ZBG->ZBG_TIPREG := "A"
       EndIf

       If ! Empty(_cCod)
          ZBG->ZBG_COD	 := _cCod   // Cod.Produt	  A2_COD
       EndIf

       If ! Empty(_cLoja)
          ZBG->ZBG_LOJA  := _cLoja  // Loja Produt	  A2_LOJA
       EndIf

       If ! Empty(_cCnpjProd)
          If Len(_cCnpjProd) < 14
             ZBG->ZBG_TIPO := "F"    // Tipo do Forn  A2_TIPO   	F=Fisico;J=Jurídico
          Else
             ZBG->ZBG_TIPO := "J"
          EndIf
       EndIf

       If ! Empty(_cCnpjProd)
          ZBG->ZBG_CNPJ   := _cCnpjProd  // A2_CGC
       EndIf

       _cRazao := ""

       If ! Empty(_aProdutor[1,1])
          _cRazao := _aProdutor[1,1] // Razão Social
       EndIf

       If ! Empty(_cRazao)
          ZBG->ZBG_NOME   := _cRazao  // Razão Social  A2_NOME
       EndIf

       If ! Empty(_cRazao)
          ZBG->ZBG_NREDUZ := SubStr(_cRazao,1,20)   // Nom.Fantasia  A2_NREDUZ
       EndIf

       ZBG->ZBG_EST := ""	    // Estado	      A2_EST

       _cUF      := ""
       _cMunicip := ""

       If ! Empty(_aPropried[_nY, 29])
          _nI    := AT( "/", _aPropried[_nY, 29] )  // CIDADE\/UF
          If _nI > 0
             _cUF := SubStr(_aPropried[_nY, 29],_nI+1,2)
             ZBG->ZBG_EST := _cUF // Estado	      A2_EST
          EndIf
       EndIf

       ZBG->ZBG_MUN := ""   	 // Municipio	  A2_MUN
       If ! Empty(_aPropried[_nY, 29])
          _nI    := AT( "/", _aPropried[_nY, 29] )  // CIDADE\/UF
          If _nI > 0
             _cMunicip := SubStr(_aPropried[_nY, 29],1,_nI-1)
             ZBG->ZBG_MUN := _cMunicip // Municipio	  A2_MUN
          EndIf
       EndIf

       _cIdCidade := U_ITKEY(_cUF, "CC2_EST") + U_ITKEY(_cMunicip,"CC2_MUN")

       // CC2_FILIAL+CC2_EST+CC2_MUN - 4

       If ! Empty(_cIdCidade)
          _cIdCidade := POSICIONE('CC2',4,xFilial('CC2')+_cIdCidade,'CC2_CODMUN')
          If ! Empty(_cIdCidade)
             ZBG->ZBG_CODMUN := _cIdCidade	 // Cod.Municip	  A2_COD_MUN
          EndIf
       EndIf

       If ! Empty(_cCepProd)
          ZBG->ZBG_CEP	  := _cCepProd  // CEP	          A2_CEP
       EndIf

       _cEndereco := ""
       _cNumero   := ""

       If ! Empty(_aPropried[_nY, 25])
          _cEndereco := _aPropried[_nY, 25]
       EndIf

       If ! Empty(_aPropried[_nY, 26])
          _cNumero   := _aPropried[_nY, 26]
       EndIf

       If ! Empty(_cEndereco)
          ZBG->ZBG_END	  := AllTrim(_cEndereco) + " " + Alltrim(_cNumero)   // Endereço      A2_END
       EndIf

       _cBairro := ""

       If ! Empty(_aPropried[_nY, 27])
          _cBairro := _aPropried[_nY, 27]
       EndIf

       If ! Empty(_cBairro)
          ZBG->ZBG_BAIRRO := _cBairro  // Bairro        A2_BAIRRO
       EndIf

       _cFone1 := ""

       If ! Empty(_aPropried[_nY, 30])
          _cFone1 := _aPropried[_nY, 30]
       EndIf

       //ZBG->ZBG_DDD       // DDD	          A2_DDD
       If ! Empty(_cFone1)
          ZBG->ZBG_TEL	  := _cFone1 // Telefone	 A2_TEL
       EndIf

       _cEmail := ""

       If ! Empty(_aPropried[_nY, 32])
          _cEmail := _aPropried[_nY, 32]
       EndIf

       If ! Empty(_cEmail)
          ZBG->ZBG_EMAIL  := _cEmail // E-mail    A2_EMAIL
       EndIf

       If ! Empty(_cCondLinha)
          ZBG->ZBG_LI_RO := _cCondLinha    // Linha/Rota    A2_L_LI_RO
       EndIf

       //ZBG->ZBG_TP_LR     // Tipo          A2_L_TP_LR
       If ! Empty(_aPropried[_nY, 38])
          ZBG->ZBG_TANQ  := SubStr(_aPropried[_nY, 38],1,6)   // Cod.Tanque	  A2_L_TANQ
       EndIf

       If ! Empty(_aPropried[_nY, 38])
          ZBG->ZBG_TANLJ := SubStr(_aPropried[_nY, 38],8,4)   // Loja Tanque   A2_L_TANLJ
       EndIf

       If ! Empty(_aPropried[_nY, 14])
          ZBG->ZBG_SIGSI := _aPropried[_nY, 14] // SIGSIF        A2_L_SIGSI
       EndIf

       If ! Empty(_aPropried[_nY, 13])
          ZBG->ZBG_NIRF := _aPropried[_nY, 13]  // Nr.ITR/NIRF   A2_L_NIRF   //  _cNirf,;       // "NIRF"                          // 2
       EndIf

       If Upper(_aPropried[_nY, 42]) == 'INATIVO'
          ZBG->ZBG_ATIVO := "N"          // Ativo         A2_L_ATIVO
       Else
          ZBG->ZBG_ATIVO := "S"          // Ativo         A2_L_ATIVO
       EndIf

       If ! Empty(_aPropried[_nY,36])
          If AllTrim(Upper(_aPropried[_nY,36])) == "INDIVIDUAL"
             ZBG->ZBG_CLASS := "I"    // Classif.	  A2_L_CLASS    _cTipoTanq,;   // "tipo_tanque"                   // 4  INDIVIDUAL
          ElseIf AllTrim(Upper(_aPropried[_nY,36])) == "COLETIVO"
             ZBG->ZBG_CLASS := "C"    // Classif.	  A2_L_CLASS    _cTipoTanq,;   // "tipo_tanque"                   // 4  INDIVIDUAL
          EndIf
       EndIf

       If ! Empty(_aPropried[_nY,40])
          ZBG->ZBG_MARTQ := _aPropried[_nY,40] // Marca do TQ   A2_L_MARTQ
       EndIf

       If ! Empty(_aPropried[_nY,39])
          ZBG->ZBG_RESFR := _aPropried[_nY,39]  // Resfriamento  A2_L_RESFR
       EndIf

       If ! Empty(_aPropried[_nY,41])
          If "DUAS" $ Upper(_aPropried[_nY,41])
             ZBG->ZBG_CAPAC := "2"
          ElseIf "QUATRO" $ Upper(_aPropried[_nY,41]) // Cap. Resfri.  A2_L_CAPAC
             ZBG->ZBG_CAPAC := "4"
          Else
             ZBG->ZBG_CAPAC := "0"
          EndIf
       EndIf

       If ! Empty(_aPropried[_nY,36])
          ZBG->ZBG_CAPTQ := Val(AllTrim(_aPropried[_nY,36]))  // Cap. Tanque   A2_L_CAPTQ  // _cCapacTanq,;  // "capacidade_tanque"             // 5
       EndIf

       //ZBG->ZBG_TIPOR     // Tipo Ordenha  A2_L_TIPOR
       //ZBG->ZBG_NROOR     // Nro Ordenhas  A2_L_NROOR

       If ! Empty(_aPropried[_nY,10])
          ZBG->ZBG_FAZEN :=  _aPropried[_nY,10]           // Fazenda       A2_L_FAZEN // _aDadosProp[1] // _cNomeProp // "nome_propriedade_rural" // 1
       Else
          If ! Empty(_cRazao)
             ZBG->ZBG_FAZEN :=  _cRazao  // A2_L_FAZEN
          EndIf
       EndIf

       //ZBG->ZBG_TPPAG     // Tipo Pagto    A2_L_TPPAG
       //ZBG->ZBG_ANTIG     // Cod. Antigo   A2_L_ANTIG
       //ZBG->ZBG_FUNDE     // FUNDEPEC	  A2_L_FUNDE
       //ZBG->ZBG_CTRC      // Emite CTe     A2_L_CTRC
       //ZBG->ZBG_TXRES     // Taxa Resfr.   A2_L_TXRES
       //ZBG->ZBG_TPTXF     // Tipo de Taxa  A2_L_TPTXF
       //ZBG->ZBG_TPFRT     // Tipo Des.Frt  A2_L_TPFRT
       //ZBG->ZBG_TXFRT     // Desc.Frete    A2_L_TXFRT
       //ZBG->ZBG_DTDES     // Dt.Desativ.   A2_L_DTDES

       If ! Empty(_aPropried[_nY,18])   // error log nesta validação
          ZBG->ZBG_FREQU := If(_aPropried[_nY,18]==24,"2","1") // Freq. Coleta  A2_L_FREQU // _cFreqColeta,; // "frequencia_coleta"             // 14
       EndIf

       If ! Empty(_aPropried[_nY,6])
          _cLongitude := AllTrim(StrTran(_aPropried[_nY,6], ",", "." ))
          ZBG->ZBG_LONGI := Val(_cLongitude) // Longitude     A2_L_LONGI  // _nLongitude,;  // "longitude_propriedade"   // 7
       EndIf

       If ! Empty(_aPropried[_nY,5])
          _cLatitude  := AllTrim(StrTran(_aPropried[_nY,5], ",", "." ))
          ZBG->ZBG_LATIT := Val(_cLatitude) // Latitude      A2_L_LATIT  // _nLatitude,;   // "latitude_propriedade"    // 6
       EndIf

       //ZBG->ZBG_TXCOM     // Tx Compensac  A2_L_TXCOM
       //ZBG->ZBG_FORTX     // Forn.Tx.Asso  A2_L_FORTX
       //ZBG->ZBG_LOJTX     // Lj.Tx.Assoc.  A2_L_LOJTX
       //ZBG->ZBG_TXASS     // Vlr.Tx.Assoc  A2_L_TXASS
       //ZBG->ZBG_KMLE      // KM Leite Ter  A2_L_KMLE
       //ZBG->ZBG_TIPPR     // Tp produtor   A2_L_TIPPR
       //ZBG->ZBG_ATRCO     // Cod.Atravess  A2_L_ATRCO
       //ZBG->ZBG_ATRLO     // Loja Atraves  A2_L_ATRLO
       //ZBG->ZBG_CUSTF     // Aj Custo Fix  A2_L_CUSTF
       //ZBG->ZBG_CUSTV     // Aj Custo Ltr  A2_L_CUSTV
       //ZBG->ZBG_NOMELT    // Nome Leite    A2_L_NOME
       //ZBG->ZBG_NFPRO     // Emite NFe Pr  A2_L_NFPRO
       //---------------------------------------------//
       _dDtNasc := Ctod("  /  /  ")
/*
       If ! Empty(_aProdutor[1,5])
          _dDtNasc := _aProdutor[1,5]
          _dDtNasc := AllTrim(StrTran( _dDtNasc, "-", "" ))
          _dDtNasc := Stod(_dDtNasc)
       EndIf

       If ! Empty(_dDtNasc)
          ZBG->ZBG_DTNASC := _dDtNasc       	// Dt.Nasc.Fund  A2_L_DTNAS
       EndIf
*/
/*
       _cIncrEst := ""
       If ! Empty(_aProdutor[1,3])
          _cIncrEst := _aProdutor[1,3]
       EndIf

       If ! Empty(_cIncrEst)
          ZBG->ZBG_INSEST := _cIncrEst      	// Ins.Estadual  A2_INSCR
       EndIf

       _cRgIe  := ""

       If ! Empty(_aProdutor[1,4])
          _cRgIe  := _aProdutor[1,4]
       EndIf

       If ! Empty(_cRgIe)
          ZBG->ZBG_RG_IE  := _cRgIe           // RG/Ced.Estr  A2_PFISICA
       EndIf

       _cInfoAdic := ""

       If ! Empty(_aProdutor[1,6])
          _cInfoAdic := _aProdutor[1,6]
       EndIf
/*
       If ! Empty(_cInfoAdic)
          ZBG->ZBG_OBSERV := _cInfoAdic       // Observ.Leite  A2_L_OBSER
       EndIf
*/
      /*
       _cDataCad := AllTrim(StrTran( _cDataCad , "-", "" ))
       If ! Empty(_cDataCad)
          ZBG->ZBG_DTCAD  := Stod(_cDataCad)  // Dt.Cad.CiaLt
       EndIf

       If ! Empty(_cHoraCad)
          ZBG->ZBG_HRCAD  := _cHoraCad        // Hr.Cad.CiaLt
       EndIf
       */
/*
       If ! Empty(_aProdutor[1,18])  // Banco
          ZBG->ZBG_BANCO := _aProdutor[1,18]  // Banco  A2_BANCO
       EndIf

       If ! Empty(_aProdutor[1,19])  // Agencia
          ZBG->ZBG_AGENCI := _aProdutor[1,19]  // Agencia A2_AGENCIA
       EndIf

       If ! Empty(_aProdutor[1,20])  // Nr. Conta
          ZBG->ZBG_NUMCON := _aProdutor[1,20]  // Nr. Conta  A2_NUMCON
       EndIf

       ZBG->ZBG_JSONRC := _cJsonRec
       ZBG->ZBG_DATA   := Date()
       ZBG->ZBG_HORA   := Time()
       ZBG->ZBG_STATUS := 'P'

       //========================================================================
       // Grava os dados do cadastro de produtores na table ZBG para comparação
       // de dados entre o Protheus e a Evomilk.
       //========================================================================
       If ! Empty(_cCod) .And. SA2->(MsSeek(xFilial("SA2")+U_ITKEY(_cCod,"A2_COD")+U_ITKEY(_cLoja,"A2_LOJA")))
          ZBG->ZBG_ITIPO     := SA2->A2_TIPO     // Tipo do Forn  P.Fisica / P.Juridica
          ZBG->ZBG_ICNPJ     := SA2->A2_CGC      // CNPJ / CPF
          ZBG->ZBG_INOME     := SA2->A2_NOME	    // Razão Social
          ZBG->ZBG_IEST      := SA2->A2_EST      // Estado
          ZBG->ZBG_IMUN      := SA2->A2_MUN      // Municipio
          ZBG->ZBG_ICODMU    := SA2->A2_COD_MUN  // Cod.Municip
          ZBG->ZBG_ICEP	     := SA2->A2_CEP      // CEP
          ZBG->ZBG_IEND	     := SA2->A2_END      // Endereço
          ZBG->ZBG_IBAIRR    := SA2->A2_BAIRRO   // Bairro
          ZBG->ZBG_ITEL	     := SA2->A2_TEL      // Telefone
          ZBG->ZBG_IEMAIL    := SA2->A2_EMAIL    // E-mail
          ZBG->ZBG_ILI_RO    := SA2->A2_L_LI_RO  // Linha/Rota
          ZBG->ZBG_ITANQ     := SA2->A2_L_TANQ   // Cod.Tanque
          ZBG->ZBG_ITANLJ    := SA2->A2_L_TANLJ  // Loja Tanque
          ZBG->ZBG_ISIGSI    := SA2->A2_L_SIGSI  // SIGSIF
          ZBG->ZBG_INIRF     := SA2->A2_L_NIRF   // Nr.ITR/NIRF
          ZBG->ZBG_IATIVO    := SA2->A2_L_ATIVO  // Ativo
          ZBG->ZBG_ICLASS    := SA2->A2_L_CLASS  // Classif.
          ZBG->ZBG_IMARTQ    := SA2->A2_L_MARTQ  // Marca do TQ
          ZBG->ZBG_IRESFR    := SA2->A2_L_RESFR  // Resfriamento
          ZBG->ZBG_ICAPAC    := SA2->A2_L_CAPAC  // Cap. Resfri.
          ZBG->ZBG_ICAPTQ    := SA2->A2_L_CAPTQ  // Cap. Tanque
          ZBG->ZBG_IFAZEN    := SA2->A2_L_FAZEN  // Fazenda
          ZBG->ZBG_IFREQU    := SA2->A2_L_FREQU  // Freq. Coleta
          ZBG->ZBG_ILONGI    := SA2->A2_L_LONGI  // Longitude
          ZBG->ZBG_ILATIT    := SA2->A2_L_LATIT  // Latitude
          ZBG->ZBG_IINSES    := SA2->A2_INSCR    // Ins.Estadual
          ZBG->ZBG_IRG_IE    := SA2->A2_PFISICA  // RG/Ced.Estr
          ZBG->ZBG_IBANCO    := SA2->A2_BANCO    // Banco
          ZBG->ZBG_IAGENC    := SA2->A2_AGENCIA  // Agencia
          ZBG->ZBG_INUMCO    := SA2->A2_NUMCON   // Nr. Conta
       EndIf

       ZBG->(MsUnLock())
   Next

End Sequence

Return Nil
*/
/*
===============================================================================================================================
Função-------------: MGLT032S
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina para rodar em Scheduller e para fazer automaticamente as integrações de envio de dados para o
                     App Evomilk
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032S()
Local _cFilIntWS, _aFilIntWS
Local _nI
Local _LigaDesWS

Begin Sequence

   //=============================================================================
   // Ativa a filial "01" apenas para leitura das filiais do parâmetro.
   //=============================================================================
   RESET ENVIRONMENT
   RpcSetType(2) // 3

   //=============================================================================
   // Inicia processamento com base nas filiais do parâmetro.
   //=============================================================================

   //===========================================================================================
   // Preparando o ambiente com a filial 01
   //===========================================================================================
   //PREPARE ENVIRONMENT EMPRESA '01' FILIAL "01" ; //USER 'Administrador' PASSWORD '' ;
   //            TABLES "SA2","ZLD",'ZBG', "ZBH", "ZBI", "ZZM" MODULO 'OMS'
   RpcSetEnv("01", "01",,,,, {"SA2","ZLJ","ZLD",'ZBG', "ZBH", "ZBI", "ZZM"})

   Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

   //====================================================================
   // Liga ou Desliga a integração Webservice via Scheduller
   //====================================================================
   _LigaDesWS := SUPERGETMV('IT_LIGAWSE',.F.,  .T.)
   If ! _LigaDesWS
      Break
   EndIf

   //====================================================================
   // Inicia a Integração Webservice via Scheduller.
   //====================================================================
   _cFilIntWS := SUPERGETMV('IT_FILITEV',.F.,  "01;")

   _aFilIntWS := {}

   ZZM->(DbGoTop())

   Do While ! ZZM->(Eof())
      If ZZM->ZZM_CODIGO $ _cFilIntWS
         Aadd(_aFilIntWS,ZZM->ZZM_CODIGO)
      EndIf

      ZZM->(DbSkip())
   EndDo

   //===================================================================================================
   // Para cada empresa cadastrada no parâmetro IT_FILITCL, inicializa o ambiente, simulando o usuário
   // fazendo login na filial a ser processada.
   //===================================================================================================
   For _nI := 1 To Len(_aFilIntWS)

       _cfilial := _aFilIntWS[_nI]

       //=============================================================================
       // Ativa a filial contida em _aFilIntWS
       //=============================================================================
       RESET ENVIRONMENT
       RpcSetType(2) // 3

       //=============================================================================
       // Inicia processamento com base nas filiais do parâmetro.
       //=============================================================================

       //===========================================================================================
       // Preparando o ambiente com a filial 01
       //===========================================================================================
       //PREPARE ENVIRONMENT EMPRESA '01' FILIAL _cfilial ; //USER 'Administrador' PASSWORD '' ;
       //        TABLES "SA2","ZLD",'ZBG', "ZBH", "ZBI", "ZZM", "SM0" MODULO 'OMS'
       RpcSetEnv("01", _cfilial ,,,,, {"SA2","ZLJ","ZLD",'ZBG', "ZBH", "ZBI", "ZZM"})

       Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

       cFilAnt := _cfilial

	    cUSUARIO := SPACE(06)+"Administrador  " // Quando o ambiente é iniciado. O Protheus já está criando estas variáveis com usuário.
	    cUsername:= "Schedule" // Quando o ambiente é iniciado. O Protheus já está criando estas variáveis com usuário.

       //===================================================================================================
       // Rotina de integração de envio dos dados de Produtores, Coleta de Leite e Recebimento dos dados
       // dos Produtores do App Evomilk
       //===================================================================================================

       U_MGLT032(.T.)  // .T. = Indica que a rotina foi chamada via Scheduller.

       //===================================================================================================
       // Rotina de integração de recebimento dos dados de Produtores dos Produtores do App Companhia
       // do Leite.
       //===================================================================================================

       //U_MGLT032E("S") // "S" = Indica que a rotina foi chamada via Scheduller. // Em desenvolvimento.

   Next

 End Sequence

 Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032H
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Processamento dos Recebimentos dos Dados dos Produteres do App Evomilk via Menu.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================

User Function MGLT032H()

Begin Sequence

   //===================================================================================================
   // Rotina de integração de recebimento dos dados de Produtores dos Produtores do App Companhia
   // do Leite.
   //===================================================================================================
   If ! U_ITMSG("Confirma o recebimento dos dados dos produtores do sistema da Evomilk?","Atenção" , , ,2, 2)
      Break
   EndIf

   ProcRegua(0)

   Processa( {|| U_MGLT032E("M") } , 'Aguarde!' , 'Processando Recebimento dos dados dos Produtores...' )

   U_ItMsg("Recebimento dos dados dos Produtores do sistema Evomilk Concluido.","Atenção",,2)

End Sequence

Return Nil */

/*
===============================================================================================================================
Função-------------: MGLT032O
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina alternativa de envio dos dados das coletas para o App Evomilk.
                     Esta rotina utiliza um parâmetro de data inicial de leitura diferente e possibilita a rotina de Scheduller
                     funcionar.
===============================================================================================================================
Parametros---------: _lSchedule = Indica se a rotina foi chamada via Scheduller ou não.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032O(_lSchedule)

Private _lHaDadosD := .F.
Private _nTotRegs  := 0

Default _lSchedule := .F.

Begin Sequence

   //=======================================================================
   // Envia Dados dos Volumes coletados.
   //=======================================================================
   If ! _lSchedule
      If ! U_ITMSG("Confirma o envio dos dados das coletas de leite para o sistema da Evomilk?","Atenção" , , ,2, 2)
         Break
      EndIf
   EndIf

   If ! _lSchedule
      ProcRegua(0)

      Processa( {|| U_MGLT032M(_lSchedule) } , 'Aguarde!' , 'Lendo dados das Coletas de Leite...' )
      If _lHaDadosD
         Processa( {|| U_MGLT032N("M") } , 'Aguarde!' , 'Enviando dados das Coletas de Leite...' ) // Envia os dados dos Produtores via Integração WebService.
      EndIf

      U_ItMsg("Envio dos dados das Coletas de Leite para o sistema Evomilk Concluido.","Atenção",,2)

   Else
      U_MGLT032M(_lSchedule)  // Faz a leitura dos dados.
      If _lHaDadosD
         U_MGLT032N("S") // Envia os dados das Coletas via Integração WebService.
      EndIf

   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032M
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina alternativa de leitura e envio de dados dos Volumes de Leite Coletados.
                     Esta rotina utiliza outro parâmetro de data inicial possibilitando enviar os dados juntamente com a
                     rotina de Scheduller funcionando.
===============================================================================================================================
Parametros---------: _lSchedule = .T. = Rotina chamada via scheduller
                                    .F. = Rotina chamada via menu.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032M(_lSchedule)
Local _aStruct   := {}
Local _cDtColIni := SUPERGETMV('IT_DTCOL02',.F.,"01/10/2024")
Local _oTemp3
Local _cFilEnvC := xFilial("ZL3")

Default _lSchedule := .F.

Begin Sequence

   If ! _lSchedule
      IncProc("Gerando dados das Coletas de Leita para envio...")
   EndIf

   //==========================================================================
   // Cria Tabela Temporária para armazenar dados do JSon
   //==========================================================================
   _aStruct := {}
   Aadd(_aStruct,{"ZLJ_VIAGEM","C",10 ,0})  // numero_identificador: "06019"
   Aadd(_aStruct,{"ZLJ_CODPAT","C",6  ,0})  // matricula_produtor //A2_COD
   Aadd(_aStruct,{"ZLJ_LOJPAT","C",4  ,0})  // matricula_produtor //A2_LOJA
   Aadd(_aStruct,{"ZLJ_VOLUME","N",14 ,0})  // volume_litros
   Aadd(_aStruct,{"ZLJ_DTIVIA","D",8  ,0})  // data_coleta
   Aadd(_aStruct,{"ZLJ_HRINI" ,"C",8  ,0})  // hora_coleta   //Aadd(_aStruct,{"WK_HORACOL","C",8  ,0})  // hora_coleta
   Aadd(_aStruct,{"WK_OBSERV" ,"C",100,0})  // observações
   Aadd(_aStruct,{"WK_RECNO"  ,"N",10 ,0})  // Recno da Tabela ZLJ

   If Select("TRBCL2") > 0
      TRBCL2->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCAB criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp3 := FWTemporaryTable():New( "TRBCL2",  _aStruct )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp3:AddIndex( "01", {"ZLJ_CODPAT","ZLJ_LOJPAT"})

   _oTemp3:Create()

   DBSelectArea("TRBCL2")

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   _nTotRegs := 0

   If ! _lSchedule
      _cQry := " SELECT COUNT(*) AS TOTREGS "       // numero_identificador: "06019"
      _cQry += " FROM " + RetSqlName("ZLJ") + " ZLJ, " + RetSqlName("SA2") + " SA2 "
      _cQry += " WHERE ZLJ.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
      IF ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
         _cQry += " AND (ZLJ.ZLJ_ENVEVO = ' ' OR ZLJ.ZLJ_ENVEVO = 'S')  "
      ENDIF
      _cQry += " AND ZLJ_DTIVIA >= '"+ Dtos(Ctod(_cDtColIni)) + "' "
      _cQry += " AND ZLJ_CODPAT = A2_COD AND ZLJ_LOJPAT = A2_LOJA "
      _cQry += " AND SA2.A2_L_ITCOL = 'S' "
      _cQry += " AND ZLJ_FILIAL = '" + _cFilEnvC + "' "
      _cQry += " ORDER BY ZLJ_CODPAT,ZLJ_LOJPAT "

      If Select("QRY2ZLJ") > 0
         QRY2ZLJ->(DbCloseArea())
      EndIf

      MPSysOpenQuery( _cQry , "QRY2ZLJ")

      _nTotRegs := QRY2ZLJ->TOTREGS
   EndIf

   If Select("QRY2ZLJ") > 0
      QRY2ZLJ->(DbCloseArea())
   EndIf

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   //_dDtColIni := Date() - 540 // 18 ultimos meses de coleta.
   _cQry := " SELECT ZLJ_VIAGEM, "       // numero_identificador: "06019"
   _cQry += " ZLJ_CODPAT, "              // matricula_produtor //A2_COD
   _cQry += " ZLJ_LOJPAT, "              // matricula_produtor //A2_LOJA
   _cQry += " ZLJ_VOLUME, "              // volume_litros
   _cQry += " ZLJ_DTIVIA, "              // data_coleta
   _cQry += " ZLJ_HRINI, "               // HORARIO INICIAL COLETA // ZLJ_HRFIM = HORARIO FINAL COLETA
   _cQry += " ZLJ.R_E_C_N_O_ AS NRREG "
   _cQry += " FROM " + RetSqlName("ZLJ") + " ZLJ, " + RetSqlName("SA2") + " SA2 "
   _cQry += " WHERE ZLJ.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
   IF ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
      _cQry += " AND (ZLJ.ZLJ_ENVEVO = ' ' OR ZLJ.ZLJ_ENVEVO = 'S')  "
   ENDIF
   _cQry += " AND ZLJ_DTIVIA >= '"+ Dtos(Ctod(_cDtColIni)) + "' "
   _cQry += " AND ZLJ_CODPAT = A2_COD AND ZLJ_LOJPAT = A2_LOJA "
   _cQry += " AND SA2.A2_L_ITCOL = 'S' "
   _cQry += " AND ZLJ_FILIAL = '" + _cFilEnvC + "' "
   _cQry += " ORDER BY ZLJ_CODPAT,ZLJ_LOJPAT "

   If Select("QRY2ZLJ") > 0
      QRY2ZLJ->(DbCloseArea())
   EndIf


   MPSysOpenQuery( _cQry , "QRY2ZLJ")

   QRY2ZLJ->(DbGotop())

   If ! _lSchedule
      ProcRegua(_nTotRegs)
   EndIf
   _cTot:=ALLTRIM(STR(_nTotRegs))
   nConta:=0

   Do While ! QRY2ZLJ->(Eof())

      nConta++
      If ! _lSchedule
         IncProc("Lendo Coletas: "+STRZERO(nConta,6) +" de "+ _cTot)
      EndIf

      TRBCL2->(DbAppend())
      TRBCL2->ZLJ_VIAGEM := QRY2ZLJ->ZLJ_VIAGEM         // C 6   // numero_identificador: "06019"
      TRBCL2->ZLJ_CODPAT := QRY2ZLJ->ZLJ_CODPAT         // C 6   // matricula_produtor //A2_COD
      TRBCL2->ZLJ_LOJPAT := QRY2ZLJ->ZLJ_LOJPAT         // C 4   // matricula_produtor //A2_LOJA
      TRBCL2->ZLJ_VOLUME := QRY2ZLJ->ZLJ_VOLUME         // N 14  // volume_litros
      TRBCL2->ZLJ_DTIVIA := Stod(QRY2ZLJ->ZLJ_DTIVIA)   // D 8   // data_coleta
      TRBCL2->ZLJ_HRINI  := QRY2ZLJ->ZLJ_HRINI          // C 8   // hora_coleta
      TRBCL2->WK_OBSERV  := ""                         // C 100 // observações
      TRBCL2->WK_RECNO   := QRY2ZLJ->NRREG              // N 10  // Recno da Tabela ZLJ

      _lHaDadosD := .T.

      QRY2ZLJ->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032N
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Envio de dados das coletas via WebService Italac para Sistema Evomilk
                     Rotina alternativa que utilizar outro parâmetro de período inicial, possibilitando utilizar a rotina
                     juntamente com a rotina do Scheduller.
===============================================================================================================================
Parametros--------: _cChamada = "M" = Rotina Chamada via menu.
                                "S" = Rotina Chamada via Scheduller
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032N(_cChamada)
Local _cColetaL := ""
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cJSonEnv
Local _nStart
Local _nRetry
Local _cJSonRet
Local _nTimOut
Local _cRetHttp
Local _cJSonColeta, _cJSonGrp
Local _cHoraIni, _cHoraFin, _cMinutos, _nMinutos
Local _nTotRegEnv := 1 // 100  // Total de registros para envio.
Local _nI , _oRetJSon, _lResult
Local _aColetaEnv
Local _cDataCol
Local _nRecno := 0
Local _cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")

Private _cNrIdent
Private _cNrMatr
Private _cVolume
Private _cDtColeta
Private _cHoraCol
Private _cObserv

Default _cChamada := "M"

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _cLinkWS  := AllTrim(ZFM->ZFM_LINK03) // Link de envio da coleta do leite.
      IF !EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   If Empty(_cDirJSon)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON e os transforma em String.
   //================================================================================
   _cColetaL := U_MGLT032X(_cDirJSon+"Coleta_de_Leite.txt")

   If Empty(_cColetaL)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo Coleta de Leite integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

   If Empty(_cKey)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Coleta de Leite Produtores cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   _cHoraIni := Time() // Horario Inicial de Processamento

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

   If _cChamada == "M"
      ProcRegua(_nTotRegs)
   EndIf
   _cTot:=ALLTRIM(STR(_nTotRegs))
   nConta:=0

   _cJSonColeta := "["
   _cJSonGrp    := ""
   _nI := 1

   _aColetaEnv := {}

   TRBCL2->(DbGoTop())
   Do While ! TRBCL2->(Eof())

      If _cChamada == "M"
         nConta++
         IncProc("Transmitindo Coletas: "+STRZERO(nConta,6) +" de "+ _cTot)
      EndIf

      //====================================================================
      // Calcula o tempo decorrido para obtenção de um novo Token
      //====================================================================
      _cHoraFin := Time()
      _cMinutos := ElapTime (_cHoraIni , _cHoraFin)
      _nMinutos := Val(SubStr(_cMinutos,4,2))
      If _nMinutos > 5 // 28 // minutos
         _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

         If Empty(_cKey)
            If _cChamada == "M" // Chamada via menu.
               U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Coleta de Leite Produtores cancelada.","Atenção",,1)
            EndIf

            Break
         EndIf

         _aHeadOut := {}
         Aadd(_aHeadOut,'Accept: application/json')
         Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
         Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

         _cHoraIni := Time()

      EndIf

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================
      _cNrIdent  := TRBCL2->ZLJ_VIAGEM                        // C 6   // numero_identificador: "06019"
      _cNrMatr   := TRBCL2->ZLJ_CODPAT + "-" + TRBCL2->ZLJ_LOJPAT    // C 6   // matricula_produtor //A2_COD
      _cVolume   := AllTrim(Str(TRBCL2->ZLJ_VOLUME,14))         // N 14  // volume_litros
      _cDtColeta := StrZero(Year(TRBCL2->ZLJ_DTIVIA),4) + "-" + StrZero(Month(TRBCL2->ZLJ_DTIVIA),2) + "-" + StrZero(Day(TRBCL2->ZLJ_DTIVIA),2)      // D 8   // data_coleta
      _cHoraCol  := TRBCL2->ZLJ_HRINI                           // WK_HORACOL                          // C 8   // hora_coleta
      _cObserv   := TRBCL2->WK_OBSERV                           // C 100 // observações
      _nRecno    := TRBCL2->WK_RECNO

      _cJSonEnv := &(_cColetaL)

      _cJSonGrp += If(!Empty(_cJSonGrp),",","") + _cJSonEnv

      If _nI >= _nTotRegEnv

         _cJSonColeta += _cJSonGrp + "]"

         _nStart 		:= 0
         _nRetry 		:= 0
         _cJSonRet 	:= Nil
         _nTimOut	 	:= 120

         _cRetHttp    := ''

         _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonColeta , _nTimOut , _aHeadOut , @_cJSonRet ) )

         If ! Empty(_cRetHttp)
            _cRetHttp := StrTran( _cRetHttp, "\n", "" )
            FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
         EndIf

         If ! Empty(_oRetJSon)
            _lResult := _oRetJSon:resultado
         EndIf

         If _lResult // Integração realizada com sucesso

            //=======================================================================
            // Grava dados das coletas enviadas e aceitas para histórico.
            //=======================================================================
            _cDataCol := StrTran(_cDtColeta,"-","")

            _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

            ZBI->(RecLock("ZBI",.T.))
            ZBI->ZBI_FILIAL  := xFilial("ZBI")             // Filial do Sistema
            ZBI->ZBI_TICKET  := _cNrIdent                  // Ticket
            ZBI->ZBI_DTCOLE  := StoD(_cDataCol)            // Data Coleta
            ZBI->ZBI_CODPRO  :=  SubStr(_cNrMatr,1,6)      // Codigo do Produtor
            ZBI->ZBI_LOJPRO  :=  SubStr(_cNrMatr,8,4)      // Loja do Produtor

            If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
               _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

               ZBI->ZBI_NOMPRO := _cNomeCoop
            Else
               ZBI->ZBI_NOMPRO  :=  POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
            EndIf

            ZBI->ZBI_MOTIVO  :=  AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBI->ZBI_JSONEN  :=  _cJSonColeta              // Json de Envio
            ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
            ZBI->ZBI_HRENV	  :=  Time()                    // Hora de Envio
            ZBI->ZBI_STATUS  :=  "A"                       // Status da Integração
            ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
            ZBI->(MsUnLock())

            //==============================================================
            // Atualiza a tabela ZLJ
            //==============================================================
            If _lEfetivaEnvio .AND. _nRecno > 0 .AND. ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0 // ENVIO DA COLETA
               ZLJ->(DbGoto(_nRecno))
               ZLJ->(RecLock("ZLJ", .F.))
               ZLJ->ZLJ_ENVEVO := "N"
               ZLJ->(MsUnLock())
               _nRecno := 0
            EndIf
         else
            _cDataCol := StrTran(_cDtColeta,"-","")

            _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

            //=======================================================================
            // Grava dados das coletas enviadas e rejeitadas para histórico.
            //=======================================================================
            ZBI->(RecLock("ZBI",.T.))
            ZBI->ZBI_FILIAL  := xFilial("ZBI")             // Filial do Sistema
            ZBI->ZBI_TICKET  := _cNrIdent                  // Ticket
            ZBI->ZBI_DTCOLE  := StoD(_cDataCol)            // Data Coleta
            ZBI->ZBI_CODPRO  :=  SubStr(_cNrMatr,1,6)      // Codigo do Produtor
            ZBI->ZBI_LOJPRO  :=  SubStr(_cNrMatr,8,4)      // Loja do Produtor

            If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
               _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

               ZBI->ZBI_NOMPRO := _cNomeCoop
            Else
               ZBI->ZBI_NOMPRO  :=  POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
            EndIf

            ZBI->ZBI_MOTIVO  :=  AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBI->ZBI_DTREJ   :=  Date()                    // Data da Rejeição
            ZBI->ZBI_HRREJ   :=  Time()                    // Hora da Rejeição
            ZBI->ZBI_JSONEN  :=  _cJSonColeta              // Json de Envio
            ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
            ZBI->ZBI_HRENV	  :=  Time()                    // Hora de Envio
            ZBI->ZBI_STATUS  :=  "R"                       // Status da Integração
            ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
            ZBI->(MsUnLock())

         EndIf

         _aColetaEnv := {}
         _cJSonColeta := "["
         _cJSonGrp := ""
         _nI := 0

      EndIf

      _nI += 1

      TRBCL2->(DbSkip())
   EndDo

   If ! Empty(_cJSonGrp)
      _cJSonColeta += _cJSonGrp + "]"
      _nStart 		:= 0
      _nRetry 		:= 0
      _cJSonRet 	:= Nil
      _nTimOut	 	:= 120

      _cRetHttp    := ''

      _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonColeta , _nTimOut , _aHeadOut , @_cJSonRet ) )

      If ! Empty(_cRetHttp)
         _cRetHttp := StrTran( _cRetHttp, "\n", "" )
         FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
      EndIf

      If ! Empty(_oRetJSon)
         _lResult := _oRetJSon:resultado
      EndIf

      If _lResult // Integração realizada com sucesso

         _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

         //=======================================================================
         // Grava dados das coletas enviadas e aceitas para histórico.
         //=======================================================================
         ZBI->(RecLock("ZBI",.T.))
         ZBI->ZBI_FILIAL  := xFilial("ZBI")             // Filial do Sistema
         ZBI->ZBI_TICKET  := _cNrIdent                  // Ticket
         ZBI->ZBI_DTCOLE  := StoD(_cDataCol)            // Data Coleta
         ZBI->ZBI_CODPRO  := SubStr(_cNrMatr,1,6)       // Codigo do Produtor
         ZBI->ZBI_LOJPRO  := SubStr(_cNrMatr,1,4)       // Loja do Produtor

         If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
            _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

            ZBI->ZBI_NOMPRO := _cNomeCoop
         Else
            ZBI->ZBI_NOMPRO  := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
         EndIf

         ZBI->ZBI_MOTIVO  := AllTrim(_cRetHttp)         // Motivo da Rejeição
         ZBI->ZBI_JSONEN  := _cJSonColeta               // Json de Envio
         ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
         ZBI->ZBI_HRENV	  :=  Time()                    // Hora de Envio
         ZBI->ZBI_STATUS  :=  "A"                       // Status da Integração
         ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
         ZBI->(MsUnLock())

         //==============================================================
         // Atualiza a tabela ZLJ
         //==============================================================
         If _lEfetivaEnvio .AND. _nRecno > 0 .AND. ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
            ZLJ->(DbGoto(_nRecno))
            ZLJ->(RecLock("ZLJ", .F.))
            ZLJ->ZLJ_ENVEVO := "N"
            ZLJ->(MsUnLock())
            _nRecno := 0
         EndIf
      else
         _cDataCol := StrTran(_cDtColeta,"-","")

         _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

         //=======================================================================
         // Grava dados das coletas enviadas e rejeitadas para histórico.
         //=======================================================================
         ZBI->(RecLock("ZBI",.T.))
         ZBI->ZBI_FILIAL  := xFilial("ZBI")             // Filial do Sistema
         ZBI->ZBI_TICKET  := _cNrIdent                  // Ticket
         ZBI->ZBI_DTCOLE  := StoD(_cDataCol)            // Data Coleta
         ZBI->ZBI_CODPRO  := SubStr(_cNrMatr,1,6)       // Codigo do Produtor
         ZBI->ZBI_LOJPRO  := SubStr(_cNrMatr,1,4)       // Loja do Produtor

         If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
            _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

            ZBI->ZBI_NOMPRO := _cNomeCoop
         Else
            ZBI->ZBI_NOMPRO  := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
         EndIf

         ZBI->ZBI_MOTIVO  := AllTrim(_cRetHttp)         // Motivo da Rejeição
         ZBI->ZBI_DTREJ   := Date()                     // Data da Rejeição
         ZBI->ZBI_HRREJ   := Time()                     // Hora da Rejeição
         ZBI->ZBI_JSONEN  := _cJSonColeta               // Json de Envio
         ZBI->ZBI_DTENV	  :=  Date()                    // Data de Envio
         ZBI->ZBI_HRENV	  :=  Time()                    // Hora de Envio
         ZBI->ZBI_STATUS  :=  "R"                       // Status da Integração
         ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
         ZBI->(MsUnLock())

      EndIf
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032J
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo TXT com as coletas de Jaru, para importação de dados da Evomilk no período de:
                     01/01/2021 a 31/12/2021.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032J()
Local _nI
Local _ddata := Ctod("01/01/2021")

Private _nTotRegs := 0

Begin Sequence
   //==========================================================================
   // Gera arquivo TXT com os Dados dos Volumes coletados exclusivo par Jaru.
   //==========================================================================

   For _nI := 1 To  365
       If ! U_ITMSG("Confirma a geração do arquivo TxT com os dados das coletas de Jaru para envio a Evomilk? Periodo: "+Dtoc(_ddata),"Atenção" , , ,2, 2)
          Break
       EndIf

       ProcRegua(0)

       Processa( {|| U_MGLT032A(_ddata) } , 'Aguarde!' , 'Lendo dados das Coletas de Leite...' )

       Processa( {|| U_MGLT032B(Dtoc(_ddata)) } , 'Aguarde!' , 'Gravando Arquivo Texto das Coletas de Leite...' )

       _ddata := _ddata + 1

       U_ItMsg("Geração de arquivo TXT com os dados das Coletas de Leite de Jaru Concluido.","Atenção",,2)
   Next

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032A
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Faz a leitura dos dados das coletas de leite de Jaru para geração de arquivo Texto.
                     Para envio para Evomilk.
===============================================================================================================================
Parametros---------: _dDataMin = Data minima de leitura.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032A(_dDataMin)
Local _aStruct   := {}

Begin Sequence

   IncProc("Gerando dados das Coletas de Leita para geração de Txt de Jaru...")

   //==========================================================================
   // Cria Tabela Temporária para armazenar dados do JSon
   //==========================================================================
   _aStruct := {}
   Aadd(_aStruct,{"ZLJ_VIAGEM","C",10 ,0})  // numero_identificador: "06019"
   Aadd(_aStruct,{"ZLJ_CODPAT","C",6  ,0})  // matricula_produtor //A2_COD
   Aadd(_aStruct,{"ZLJ_LOJPAT","C",4  ,0})  // matricula_produtor //A2_LOJA
   Aadd(_aStruct,{"ZLJ_VOLUME","N",14 ,0})  // volume_litros
   Aadd(_aStruct,{"ZLJ_DTIVIA","D",8  ,0})  // data_coleta
   Aadd(_aStruct,{"ZLJ_HRINI" ,"C",8  ,0})  // hora_coleta   //Aadd(_aStruct,{"WK_HORACOL","C",8  ,0})  // hora_coleta
   Aadd(_aStruct,{"WK_OBSERV" ,"C",100,0})  // observações
   Aadd(_aStruct,{"WK_RECNO"  ,"N",10 ,0})  // Recno da Tabela ZLJ

   If Select("TRBCOLT") > 0
      TRBCOLT->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCAB criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp3 := FWTemporaryTable():New( "TRBCOLT",  _aStruct )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp3:AddIndex( "01", {"ZLJ_CODPAT","ZLJ_LOJPAT"})

   _oTemp3:Create()

   DBSelectArea("TRBCOLT")

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   _nTotRegs := 0

   _cQry := " SELECT COUNT(*) AS TOTREGS "       // numero_identificador: "06019"
   _cQry += " FROM " + RetSqlName("ZLJ") + " ZLJ, " + RetSqlName("SA2") + " SA2 "
   _cQry += " WHERE ZLJ.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
   IF ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
      _cQry += " AND (ZLJ.ZLJ_ENVEVO = ' ' OR ZLJ.ZLJ_ENVEVO = 'S')  "
   ENDIF
   _cQry += " AND ZLJ_DTIVIA < '20220101' "
   _cQry += " AND ZLJ_DTIVIA = '"+ Dtos(_dDataMin) + "' "
   _cQry += " AND ZLJ_CODPAT = A2_COD AND ZLJ_LOJPAT = A2_LOJA "
   _cQry += " AND SA2.A2_L_ITCOL = 'S' "
   _cQry += " AND ZLJ_FILIAL = '10' "
   _cQry += " ORDER BY ZLJ_CODPAT,ZLJ_LOJPAT "

   If Select("QRYZLJT") > 0
      QRYZLJT->(DbCloseArea())
   EndIf


   MPSysOpenQuery( _cQry , "QRYZLJT")

   _nTotRegs := QRYZLJT->TOTREGS

   If Select("QRYZLJT") > 0
      QRYZLJT->(DbCloseArea())
   EndIf

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   _cQry := " SELECT ZLJ_VIAGEM, "       // numero_identificador: "06019"
   _cQry += " ZLJ_CODPAT, "              // matricula_produtor //A2_COD
   _cQry += " ZLJ_LOJPAT, "              // matricula_produtor //A2_LOJA
   _cQry += " ZLJ_VOLUME, "              // volume_litros
   _cQry += " ZLJ_DTIVIA, "              // data_coleta
   _cQry += " ZLJ_HRINI, "               // HORARIO INICIAL COLETA // ZLJ_HRFIM = HORARIO FINAL COLETA
   _cQry += " ZLJ.R_E_C_N_O_ AS NRREG "
   _cQry += " FROM " + RetSqlName("ZLJ") + " ZLJ, " + RetSqlName("SA2") + " SA2 "
   _cQry += " WHERE ZLJ.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
   IF ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
      _cQry += " AND (ZLJ.ZLJ_ENVEVO = ' ' OR ZLJ.ZLJ_ENVEVO = 'S')
   ENDIF
   _cQry += " AND ZLJ_DTIVIA >= '"+ Dtos(Ctod(_cDtColIni)) + "' "
   _cQry += " AND ZLJ_DTIVIA = '"+ Dtos(_dDataMin) + "' "
   _cQry += " AND ZLJ_CODPAT = A2_COD AND ZLJ_LOJPAT = A2_LOJA "
   _cQry += " AND SA2.A2_L_ITCOL = 'S' "
   _cQry += " AND ZLJ_FILIAL = '10' "
   _cQry += " ORDER BY ZLJ_CODPAT,ZLJ_LOJPAT "

   If Select("QRYZLJT") > 0
      QRYZLJT->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYZLJT")

   QRYZLJT->(DbGotop())

   ProcRegua(_nTotRegs)
   _cTot:=ALLTRIM(STR(_nTotRegs))
   nConta:=0

   Do While ! QRYZLJT->(Eof())
      nConta++
      IncProc("Lendo Coletas: "+STRZERO(nConta,6) +" de "+ _cTot)

      TRBCOLT->(DbAppend())
      TRBCOLT->ZLJ_VIAGEM := QRYZLJT->ZLJ_VIAGEM         // C 6   // numero_identificador: "06019"
      TRBCOLT->ZLJ_CODPAT := QRYZLJT->ZLJ_CODPAT         // C 6   // matricula_produtor //A2_COD
      TRBCOLT->ZLJ_LOJPAT := QRYZLJT->ZLJ_LOJPAT         // C 4   // matricula_produtor //A2_LOJA
      TRBCOLT->ZLJ_VOLUME := QRYZLJT->ZLJ_VOLUME         // N 14  // volume_litros
      TRBCOLT->ZLJ_DTIVIA := Stod(QRYZLJT->ZLJ_DTIVIA)   // D 8   // data_coleta
      TRBCOLT->ZLJ_HRINI  := QRYZLJT->ZLJ_HRINI          // C 8   // hora_coleta
      TRBCOLT->WK_OBSERV  := ""                         // C 100 // observações
      TRBCOLT->WK_RECNO   := QRYZLJT->NRREG              // N 10  // Recno da Tabela ZLJ

      _lHaDadosC := .T.

      QRYZLJT->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032B
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de geração de arquivo TxT para envio a Evomilk. Exclusivo da filial Jaru.
                     No periodo de 01/01/2021 a 31/12/2021.
===============================================================================================================================
Parametros--------:  _dDataTXT = Data de geração do TXT.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032B(_dDataTXT)
Local _cColetaL := ""
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cJSonEnv
Local _cJSonColeta, _cJSonGrp
Local _nRecno := 0

Private _cNrIdent
Private _cNrMatr
Private _cVolume
Private _cDtColeta
Private _cHoraCol
Private _cObserv

_cDirTXT:=_cNomeArq:=""

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _cLinkWS  := AllTrim(ZFM->ZFM_LINK03) // Link de envio da coleta do leite.
   Else
      U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      Break
   EndIf

   If Empty(_cDirJSon)
      U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON e os transforma em String.
   //================================================================================
   _cColetaL := U_MGLT032X(_cDirJSon+"Coleta_de_Leite.txt")

   If Empty(_cColetaL)
      U_ItMsg("Erro na leitura do arquivo modelo JSON modelo Coleta de Leite integração Italac x Evomilk","Atenção",,1)
      Break
   EndIf

   ProcRegua(_nTotRegs)

   _cDirTXT := "\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
   _cNomeArq:= "Coleta_Leite_Jaru_" + Dtos(Ctod(_dDataTXT)) + ".Txt"

   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados de coleta de Jaru, para envio a Evomilk.","Atenção",,1)
      Break
   EndIf

   _oFWriter:Write("[" + CRLF)

   _cJSonColeta := "["
   _cJSonGrp    := ""

   TRBCOLT->(DbGoTop())
   Do While ! TRBCOLT->(Eof())

      IncProc("Gerando arquivo texto [" + _dDataTXT + "]...")

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================
      _cNrIdent  := TRBCOLT->ZLJ_VIAGEM                        // C 6   // numero_identificador: "06019"
      _cNrMatr   := TRBCOLT->ZLJ_CODPAT+"-"+TRBCOLT->ZLJ_LOJPAT    // C 6   // matricula_produtor //A2_COD
      _cVolume   := AllTrim(Str(TRBCOLT->ZLJ_VOLUME,14))         // N 14  // volume_litros
      _cDtColeta := StrZero(Year(TRBCOLT->ZLJ_DTIVIA),4) + "-" + StrZero(Month(TRBCOLT->ZLJ_DTIVIA),2) + "-" + StrZero(Day(TRBCOLT->ZLJ_DTIVIA),2)      // D 8   // data_coleta
      _cHoraCol  := TRBCOLT->ZLJ_HRINI                           // WK_HORACOL                          // C 8   // hora_coleta
      _cObserv   := TRBCOLT->WK_OBSERV                           // C 100 // observações
      _nRecno    := TRBCOLT->WK_RECNO

      _cJSonEnv := &(_cColetaL) + CRLF   // Incluir aqui comando para gravação da linha do aquivo texto.

      _oFWriter:Write(_cJSonEnv)

      _cTipoCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_TPASS') // Tipo de Associação // Associado/Cooperado

      ZBI->(RecLock("ZBI",.T.))
      ZBI->ZBI_FILIAL  := xFilial("ZBI")                   // Filial do Sistema
      ZBI->ZBI_TICKET  := _cNrIdent                        // Ticket
      ZBI->ZBI_DTCOLE  := TRBCOLT->ZLJ_DTIVIA              //StoD(_cDataCol)                  // Data Coleta
      ZBI->ZBI_CODPRO  :=  SubStr(_cNrMatr,1,6)            // Codigo do Produtor
      ZBI->ZBI_LOJPRO  :=  SubStr(_cNrMatr,8,4)            // Loja do Produtor

      If !Empty(_cTipoCoop) .And. _cTipoCoop == "C"
         _cNomeCoop := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_L_NATRA') // Nome Atravessador

         ZBI->ZBI_NOMPRO := _cNomeCoop
      Else
         ZBI->ZBI_NOMPRO  := POSICIONE('SA2',1,xFilial('SA2')+SubStr(_cNrMatr,1,6)+SubStr(_cNrMatr,8,4),'A2_NOME') // Nome do Produtor?
      EndIf

      ZBI->ZBI_MOTIVO  :=  "Enviado via Arquivo Texto"     // Motivo da Rejeição
      ZBI->ZBI_JSONEN  :=  _cJSonEnv                       // Json de Envio
      ZBI->ZBI_DTENV	  :=  Date()                          // Data de Envio
      ZBI->ZBI_HRENV	  :=  Time()                          // Hora de Envio
      ZBI->ZBI_STATUS  :=  "A"                             // Status da Integração
      ZBI->ZBI_WEBINT  :=  "E"                       // Indica que a integração está sendo realizada com o App Evomilk
      ZBI->(MsUnLock())

      //==============================================================
      // Atualiza a tabela ZLJ
      //==============================================================
      If _nRecno > 0 .AND. ZLJ->(FIELDPOS("ZLJ_ENVEVO")) > 0
         ZLJ->(DbGoto(_nRecno))
         ZLJ->(RecLock("ZLJ", .F.))
         ZLJ->ZLJ_ENVEVO := "N"
         ZLJ->(MsUnLock())
         _nRecno := 0
      EndIf

      TRBCOLT->(DbSkip())
   EndDo

   _oFWriter:Write("]")

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence
Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032I
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo Texto com informações dos produtores usuários de tanques coletivos e produtores familiares, e
                     seus vinculos com os produtores principais.
                     A geração dos dados é por filial.
===============================================================================================================================
Parametros--------:  _cFilEnvio = Filial de geração dos dados
                     _cNomeFil  = Nome da Filial de Envio
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032I(_cFilEnvio,_cNomeFil)
Local _cQry := ""
Local _cLinha, _cClassif
Local _lLinhaUm
Local _cFazenda

Default _cFilEnvio := xFilial("ZL3")
Default _cNomeFil := ""

_cDirTXT  := GetTempPath()//"\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
_cNomeArq := "Listagem_com_Vinculação_Produtor_Usuario_TC_Familiar_e_Produtor_Principal_Filial_"

Begin Sequence

   _cQry := " SELECT DISTINCT A2_COD, "  // matricula_laticinio: TESTE_278363
   _cQry += " A2_LOJA, "                 // Loja_laticinio: TESTE_278363
   _cQry += " A2_NOME, "                 // nome_razao_social  : PRODUTOR TESTE 3337
   _cQry += " A2_CGC, "                  // cpf_cnpj: 349.812.172-34
   _cQry += " A2_L_FAZEN, "              // nome_propriedade_rural: PROPRIEDADE TESTE 001
   _cQry += " A2_L_NIRF, "               // NIRF: ABC4658
   _cQry += " A2_L_SIGSI, "              //
   _cQry += " A2_L_TANQ, "               // id_tipo_tanque: 1
   _cQry += " A2_L_TANLJ, "              //
   _cQry += " A2_L_CLASS, "
   _cQry += " SA2.R_E_C_N_O_ AS RECNOSA2, "
   _cQry += " (SELECT DISTINCT A2_CGC FROM " + RetSqlName("SA2") + " SA2B "
   _cQry += "  WHERE SA2B.D_E_L_E_T_ = ' ' AND SA2B.A2_COD = SA2.A2_L_TANQ AND SA2B.A2_LOJA = SA2.A2_L_TANLJ) AS CPFCNPJ "
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZL3_COD = A2_L_LI_RO "
   _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' " // Cada filial/Cnpj Italac possui um Usuário e Senha. Ler do cadastro empresas Webservice. Enviar apenas as filias 01, 04, 23. 01=Corumbaiba/GO, 04=Araguari/MG, 23=Tapejara/RS
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_L_ATIVO <> 'N' "
   _cQry += " AND A2_COD <> '      ' "
   _cQry += " AND (A2_L_CLASS = 'U' OR A2_L_CLASS = 'F') "
   _cQry += " ORDER BY A2_COD,A2_LOJA "

   If Select("QRYSA2") > 0
         QRYSA2->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYSA2")

   _cCodForn := Space(6)

   QRYSA2->(DbGotop())

   ProcRegua(0)

   _cDirTXT := GetTempPath()//"\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
   _cNomeArq:= _cNomeArq +_cFilEnvio + "_" + Lower(_cNomeFil) + ".Txt"

   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados Produtores usuários tanque coletivos e familiares e seu vinculos com o produtor principal.","Atenção",,1)
      Break
   EndIf

   _oFWriter:Write("[" + CRLF)

   _lLinhaUm := .T.

   Do While ! QRYSA2->(Eof())
      IncProc("Gravando arquivo texto...")

      If Empty(QRYSA2->A2_COD) // Foi identificado no cadastro de fornecedores alguns registros sem o código preenchido.
         QRYSA2->(DbSkip())
         Loop
      EndIf

      _cClassif := ""
      If QRYSA2->A2_L_CLASS == "U"
         _cClassif := "USUARIO TANQUE COLETIVO"
      Elseif QRYSA2->A2_L_CLASS == "F"
         _cClassif := "FAMILIAR"
      EndIf

      _cFazenda := AllTrim(STRTRAN(QRYSA2->A2_L_FAZEN,'"'," "))
      If _cFazenda == "--"
         _cFazenda := "SEM NOME"
      EndIf

      _cLinha := If(!_lLinhaUm,"," + CRLF ,"")
      _cLinha += '{ "matricula_laticinio" : "' + AllTrim(QRYSA2->A2_COD) + '",'
      _cLinha += ' "Loja_laticinio" : "' + AllTrim(QRYSA2->A2_LOJA) + '",'
      _cLinha += ' "nome_razao_social" : "' + AllTrim(QRYSA2-> A2_NOME)+ '",'
      _cLinha += ' "cpf_cnpj" : "' + AllTrim(QRYSA2->A2_CGC)+ '",'
      _cLinha += ' "nome_propriedade_rural" : "' + _cFazenda + '",'    // AllTrim(QRYSA2->A2_L_FAZEN)
      _cLinha += ' "classificacao_laticinio" : "' + AllTrim(_cClassif)+ '",'
      _cLinha += ' "nirf" : "' + AllTrim(QRYSA2->A2_L_NIRF) + '",'
      _cLinha += ' "sigsif" : "' + AllTrim(QRYSA2->A2_L_SIGSI)+ '",'
      _cLinha += ' "matricula_produtor_principal" : "' + AllTrim(QRYSA2->A2_L_TANQ)+ '",'
      _cLinha += ' "loja_produtor_principal" : "' + AllTrim(QRYSA2->A2_L_TANLJ)+ '",'
      _cLinha += ' "cpf_cnpj_produtor_principal" : "' + AllTrim(QRYSA2->CPFCNPJ) + '"} '

      _oFWriter:Write(_cLinha)

      QRYSA2->(DbSkip())

      _lLinhaUm := .F.

   EndDo

   _oFWriter:Write("]")

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032L
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Função Principal que Gera arquivo Texto com informações dos produtores usuários de tanques coletivos e
                     produtores familiares, e seus vinculos com os produtores principais.
                     A geração dos dados é por filial.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032L()
Local _nI
Local _aFilProc := {}

Begin Sequence

   If ! U_ITMSG("Confirma a geração do arquivo TxT com os vinculos Produtores usuários tanques coletivos/familiares e os produtores principais?","Atenção" , , ,2, 2)
      Break
   EndIf

   Aadd(_aFilProc, {"01","Corumbaiba"})    // CORUMBAIBA	   01
   Aadd(_aFilProc, {"04","Araguari"})      // ARAGUARI	   04
   Aadd(_aFilProc, {"23","Tapejara"})      // TAPEJARA	   23
   Aadd(_aFilProc, {"40","Tres Coracoes"}) // TRÊS CORAÇÕES 40
   Aadd(_aFilProc, {"24","Crissiumal"})    // CRISSIUMAL    24
   Aadd(_aFilProc, {"25","Girua"})         // GIRUÁ         25
   Aadd(_aFilProc, {"09","Ipora"})         // IPORÁ	      09
   Aadd(_aFilProc, {"02","Itapaci"})       // ITAPACI	      02
   Aadd(_aFilProc, {"10","Jaru"})          // JARU		      10
   Aadd(_aFilProc, {"11","Nova Mamore"})   // NOVA MAMORE	11
   Aadd(_aFilProc, {"20","Passo Fundo"})       // PASSO FUNDO	20
   Aadd(_aFilProc, {"06","Pontalina"})         // PONTALINA		06
   Aadd(_aFilProc, {"0B","Quirinopolis"})      // QUIRINÓPOLIS	0B
   Aadd(_aFilProc, {"93","Parana_Cascavel"})   // PARANA_CASCAVEL 93
//   Aadd(_aFilProc, {"0A","Unidade Rio Verde"}) // UNIDADE RIO VERDE		0A

   For _nI := 1 To Len(_aFilProc)
       Processa( {|| U_MGLT032I(_aFilProc[_nI,1],_aFilProc[_nI,2]) } , 'Aguarde!' , 'Gravando arquivo TXT...' )
   Next

   U_ItMsg("Termino da gravação do arquivo TXT.", "Atenção" ,,1)

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32TXT
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo TXT com os dados dos Produtores. Faz a leitura dos dados por filial.
===============================================================================================================================
Parametros---------: _cTipoArq = Tipo de arquivo texto: PRODUTORES ou ASSOCIACOES
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32TXT(_cTipoArq)
Local _cQry
Local _aFilSA2 := {}
Local _nI, _cFilEnvio

Private _nTotRegs := 0

Default _cTipoArq := "PRODUTORES"

Begin Sequence
   //==========================================================================
   // Gera arquivo TXT com os Dados dos Volumes coletados exclusivo par Jaru.
   //==========================================================================
   //If ! U_ITMSG("Confirma a geração do arquivo TxT com os dados dos Produtores?" ,"Atenção" , , ,2, 2)
   //   Break
   //EndIf

   Aadd(_aFilSA2, { "01","CORUMBAIBA"})
   Aadd(_aFilSA2, { "04","ARAGUARI"})
   Aadd(_aFilSA2, { "23","TAPEJARA"})
   Aadd(_aFilSA2, { "40","TRES CORACOES"})
   Aadd(_aFilSA2, { "24","CRISSIUMAL"})
   Aadd(_aFilSA2, { "25","GIRUA"})
   Aadd(_aFilSA2, { "09","IPORA"})
   Aadd(_aFilSA2, { "02","ITAPACI"})
   Aadd(_aFilSA2, { "10","JARU"})
   Aadd(_aFilSA2, { "11","NOVA MAMORE"})
   Aadd(_aFilSA2, { "20","PASSO FUNDO"})
   Aadd(_aFilSA2, { "06","PONTALINA"})
   Aadd(_aFilSA2, { "0B","QUIRINOPOLIS"})
   Aadd(_aFilSA2, { "93","PARANA_CASCAVEL"})
   Aadd(_aFilSA2, { "31","CONCEICAO_DO_ARAGUAIA"})
   Aadd(_aFilSA2, { "32","COUTO_DE_MAGALHAES"})


   For _nI := 1 To Len(_aFilSA2)
       //================================================================================
       // Monta select de leitura de dados do cadastro de Produtores rurais.
       //================================================================================
       _cFilEnvio := _aFilSA2[_nI,1]

       _cQry := " SELECT DISTINCT A2_COD, "
       _cQry += " A2_LOJA, "
       _cQry += " A2_CGC, "
       _cQry += " A2_NOME, "
       _cQry += " A2_L_ATIVO, "
       _cQry += " A2_DTNASC,  "
       _cQry += " A2_L_LI_RO, "
       _cQry += " ZL3_DESCRI, "
       _cQry += " A2_EMAIL, "
       _cQry += " A2_L_TPASS, "
       _cQry += " A2_L_NATRA, "
       _cQry += " SA2.R_E_C_N_O_ AS NRREG "  // capacidade_refrigeracao: 307
       _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
       _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
       _cQry += " AND ZL3_COD = A2_L_LI_RO "
       _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' " // Cada filial/Cnpj Italac possui um Usuário e Senha. Ler do cadastro empresas Webservice. Enviar apenas as filias 01, 04, 23. 01=Corumbaiba/GO, 04=Araguari/MG, 23=Tapejara/RS
       _cQry += " AND A2_I_CLASS = 'P' "
       _cQry += " AND A2_MSBLQL = '2' "
       _cQry += " AND A2_COD <> '      ' "
//------------------------------------------------------------------------
       If _cTipoArq == "ASSOCIACOES"
          _cQry += " AND SA2.A2_L_NFPRO = 'S' "  // Quando SA2.A2_L_NFPRO = 'S' é Associação/Cooperativa/Associado/Cooperado
       EndIf
//------------------------------------------------------------------------
       _cQry += " ORDER BY A2_COD,A2_LOJA "

       If Select("QRYSA2") > 0
          QRYSA2->(DbCloseArea())
       EndIf

       MPSysOpenQuery( _cQry , "QRYSA2")

       TCSetField('QRYSA2',"A2_DTNASC","D",8,0)

       QRYSA2->(DbGotop())

       DBSelectArea("QRYSA2")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA

       Count to _nTotRegs

       QRYSA2->(DbGotop())

       Processa( {|| U_MGLT32GRV(_aFilSA2[_nI,2],_nTotRegs, _cTipoArq) } , 'Aguarde!' , 'Gravando Arquivo Texto dos Produtores...' )

   Next

   U_ItMsg("Geração de arquivo TXT com os dados Produtores Concluido.","Atenção",,2)

End Sequence

If Select("QRYSA2") > 0
   QRYSA2->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32GRV
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de geração de arquivo TxT dos Produtores envio a Evomilk.
===============================================================================================================================
Parametros--------:  _cNomeFil = Nome da filial
                     _nTotRegs = numero total de registros
                     _cTipoArq = Tipo de aquivo (ASSOCIACAO/COOPERATIVA/ASSOCIADO/COOPERADO/PRODUTOR NORMAL)
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32GRV(_cNomeFil,_nTotRegs,_cTipoArq)
Local _cDados, _cTipoEstb

Begin Sequence

   ProcRegua(_nTotRegs)

   _cDirTXT := GetTempPath() // "\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
   _cNomeArq:= "Produtores_de_" + AllTrim(_cNomeFil) +"_"+AllTrim(_cTipoArq)+ "_" + Dtos(Date()) + ".Txt"

   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados de coleta de Jaru, para envio a Evomilk.","Atenção",,1)
      Break
   EndIf

   _oFWriter:Write("UNIDADE;MATRICULA;CPF;NOME;DT_NASC_PROPRIEDADE;LINHA_ROTA;NOME_LINHA_ROTA;TIPO_ESTABELECIMENTO;STATUS;E_MAIL;" + CRLF)

   QRYSA2->(DbGoTop())

   Do While ! QRYSA2->(Eof())

      IncProc("Gerando arquivo texto: "+ AllTrim(_cNomeFil) + "...")

      //=============================================================================
      // Verifica se o Produtor possui mais de uma propriedade e envia apenas os
      // que possuirem apenas uma propriedade.
      //=============================================================================
//      If U_MGLT032Z(QRYSA2->A2_COD)
//         QRYSA2->(DbSkip())
//         Loop
//      EndIf

      _cTipoEstb := "-----"
      If QRYSA2->A2_L_TPASS == "A"
         _cTipoEstb := "ASSOCIAÇÃO/COOPERATIVA"
      ElseIf QRYSA2->A2_L_TPASS == "C"
         _cTipoEstb := "ASSOCIADO/COOPERADO"
      EndIf

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================
      _cDados := AllTrim(_cNomeFil)+";"
      _cDados += QRYSA2->A2_COD + "-" + QRYSA2->A2_LOJA+";"
      _cDados += AllTrim(QRYSA2->A2_CGC) +";"

      If _cTipoArq == "ASSOCIACOES"
         If ! Empty(QRYSA2->A2_L_NATRA)
            _cDados += AllTrim(QRYSA2->A2_L_NATRA) + ";"
         Else
            _cDados += AllTrim(QRYSA2->A2_NOME) + ";"
         EndIf
      Else
         _cDados += AllTrim(QRYSA2->A2_NOME) + ";"
      EndIf

      _cDados += StrZero(Year(QRYSA2->A2_DTNASC),4)+"-"+StrZero(Month(QRYSA2->A2_DTNASC),2)+"-"+StrZero(Day(QRYSA2->A2_DTNASC),2)+";"
      _cDados += AllTrim(QRYSA2->A2_L_LI_RO) + ";"
      _cDados += AllTrim(QRYSA2->ZL3_DESCRI) + ";"
      _cDados += _cTipoEstb + ";"
      If AllTrim(QRYSA2->A2_L_ATIVO) == "N"
         _cDados += "INATIVO;"
      Else
         _cDados += "ATIVO;"
      EndIf

      _cDados += AllTrim(QRYSA2->A2_EMAIL)+";"

      _cDados += CRLF

      _oFWriter:Write(_cDados)

      QRYSA2->(DbSkip())
   EndDo

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032G
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Grava os retornos de erros dos Produtores em arquivo texto.
===============================================================================================================================
Parametros--------:  _cJsongrv  = Arquivo JSon de envio
                     _cRetInteg = Retorno da Integração
                     _cDadosProd = Dados do Produtor Rejeitado
                     _lAbreArq   = .T./.F. = Abre arquivo ?
                     _lFechaArq  = .T./.F. = Fecha arquivo ?
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032G(_cJsongrv,_cRetInteg,_cDadosProd,_lAbreArq, _lFechaArq,_cRotina,_cUnidade)
Local _aUnidades := {}, _nI, _cNomeUnid

Default _cJsongrv   := ""
Default _cRetInteg  := ""
Default _cDadosProd := ""
Default _lAbreArq  := .F.
Default _lFechaArq := .F.
Default _cRotina := "PADRAO"

_cDirTXT  := GetTempPath() //"\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
_cNomeArq := "Listagem_com_Retorno_de_Erros_na_Integração"

Begin Sequence
   If _cRotina == "TIT_TC" // Rotina de Envio de Titulares de Tanques Coletivos.
      Aadd(_aUnidades, { "01","CORUMBAIBA"})
      Aadd(_aUnidades, { "04","ARAGUARI"})
      Aadd(_aUnidades, { "23","TAPEJARA"})
      Aadd(_aUnidades, { "40","TRES CORACOES"})
      Aadd(_aUnidades, { "24","CRISSIUMAL"})
      Aadd(_aUnidades, { "25","GIRUA"})
      Aadd(_aUnidades, { "09","IPORA"})
      Aadd(_aUnidades, { "02","ITAPACI"})
      Aadd(_aUnidades, { "10","JARU"})
      Aadd(_aUnidades, { "11","NOVA MAMORE"})
      Aadd(_aUnidades, { "20","PASSO FUNDO"})
      Aadd(_aUnidades, { "06","PONTALINA"})
      Aadd(_aUnidades, { "0B","QUIRINOPOLIS"})
      Aadd(_aUnidades, { "93","PARANA_CASCAVEL"})
      Aadd(_aUnidades, { "31","CONCEICAO_DO_ARAGUAI"})
      Aadd(_aUnidades, { "32","COUTO_DE_MAGALHAES"})

      _cNomeUnid := ""
      _nI := AsCan(_aUnidades,{|x| x[1]==_cUnidade})
      If _nI > 0
         _cNomeUnid := _aUnidades[_nI,2]
      EndIf
      _cNomeArq := "Listagem_Titulares_Tanques_Coletivos_Rejeitados_" + _cNomeUnid
   EndIf

   If _lAbreArq
      _cDirTXT := GetTempPath() //"\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
      _cNomeArq:= _cNomeArq + ".Txt"

      _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

      If ! _oFWriter:Create()
         U_ItMsg("Erro na criação do arquivo texto para gravação dos dados Produtores usuários tanque coletivos e familiares e seu vinculos com o produtor principal.","Atenção",,1)
         Break
      EndIf
    EndIf

   If ! Empty(_cDadosProd)
      _oFWriter:Write(_cDadosProd + CRLF)
      _oFWriter:Write("-----------------------------------------------------------------------" + CRLF)
      _oFWriter:Write(_cRetInteg + CRLF)
      _oFWriter:Write("-----------------------------------------------------------------------" + CRLF)
      _oFWriter:Write(_cJsongrv + CRLF)
      _oFWriter:Write(">>>>====================================================================================================<<<<" + CRLF)
   EndIf

   If _lFechaArq
      //Encerra o arquivo
      _oFWriter:Close()
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032C
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de envio de atualização dos produtores via integração WebService para Evomilk
===============================================================================================================================
Parametros---------: _lSchedule = .T./.F. = Indica se a rotina foi ou não chamada via Scheduller.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032C(_lSchedule)
Local _aStruct := {}
Local _aStruct2 := {}
Local _aStruct3 := {}
Local _cCodForn
Local _cFilEnvio := xFilial("ZL3")
Default _lSchedule := .F.

Begin Sequence

   If ! _lSchedule
      IncProc("Gerando dados de Atualização dos Produtores para envio...")
   EndIf

   //==========================================================================
   // Cria Tabela Temporária para atualização do SA2
   //==========================================================================
   _aStruct3 := {}
   Aadd(_aStruct3,{"A2_COD"    ,"C",6  ,0})  // matricula_laticinio: TESTE_278363
   Aadd(_aStruct3,{"A2_LOJA"   ,"C",4  ,0})  // Loja_laticinio: TESTE_278363
   Aadd(_aStruct3,{"A2_L_FAZEN","C",60 ,0})  // Nome da Fazenda
   Aadd(_aStruct3,{"WK_RECNO"  ,"N",10 ,0})  // Nr Recno SA2

   If Select("TRBSA2A") > 0
      TRBSA2A->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCAB criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp := FWTemporaryTable():New( "TRBSA2A",  _aStruct3 )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp:AddIndex( "01", {"A2_COD","A2_LOJA"} )
   _oTemp:Create()

   DBSelectArea("TRBSA2A")

   //==========================================================================
   // Cria Tabela Temporária para armazenar dados do JSon
   //==========================================================================
   _aStruct := {}
   Aadd(_aStruct,{"A2_COD"    ,"C",6  ,0})  // matricula_laticinio: TESTE_278363
   Aadd(_aStruct,{"A2_LOJA"   ,"C",4  ,0})  // Loja_laticinio: TESTE_278363
   Aadd(_aStruct,{"A2_NOME"   ,"C",40 ,0})  // nome_razao_social  : PRODUTOR TESTE 3337
   Aadd(_aStruct,{"A2_CGC"    ,"C",14 ,0})  // cpf_cnpj: 349.812.172-34
   Aadd(_aStruct,{"A2_INSCR"  ,"C",18 ,0})  // inscricao_estadual: 170642
   Aadd(_aStruct,{"A2_PFISICA","C",18 ,0})  // rg_ie: ABC320303
   Aadd(_aStruct,{"A2_PRICOM" ,"D",8  ,0})  // data_nascimento_fundacao: 1994-10-10
   Aadd(_aStruct,{"WK_OBSERV" ,"C",100,0})  // info_adicional: Observação / info adicional...
   Aadd(_aStruct,{"A2_ENDCOMP","C",50 ,0})  // complemento: Complemento Teste
   Aadd(_aStruct,{"A2_END"    ,"C",90 ,0})  // endereco: Rua Caminho Andante
   Aadd(_aStruct,{"WK_NUMERO" ,"C",20 ,0})  // numero: 429 A
   Aadd(_aStruct,{"A2_BAIRRO" ,"C",50 ,0})  // bairro: Bairro Teste
   Aadd(_aStruct,{"A2_CEP"    ,"C",8  ,0})  // cep: 51462-745
   Aadd(_aStruct,{"WK_ID_UF"  ,"C",2  ,0})  // id_uf: 21
   Aadd(_aStruct,{"A2_COD_MUN","C",5  ,0})  // id_cidade: 73
   Aadd(_aStruct,{"A2_MUN"    ,"C",50 ,0})  // municipio
   Aadd(_aStruct,{"A2_EST"    ,"C",2  ,0})  // estado
   Aadd(_aStruct,{"A2_BANCO"  ,"C",3  ,0})  // codigo do banco
   Aadd(_aStruct,{"A2_AGENCIA","C",5  ,0})  // codigo da agencia
   Aadd(_aStruct,{"A2_NUMCON" ,"C",12 ,0})  // numero da conta
   Aadd(_aStruct,{"A2_EMAIL"  ,"C",100,0})  // email: TESTE_278363@email.com
   Aadd(_aStruct,{"A2_DDD"    ,"C",3,0})    // celular1: 95920298034
   Aadd(_aStruct,{"A2_TEL"    ,"C",50,0})   // celular1: 95920298034
   Aadd(_aStruct,{"A2_TEL2"   ,"C",50,0})   // celular2: null
   Aadd(_aStruct,{"A2_TEL3"   ,"C",50,0})   // telefone1: 5590038949
   Aadd(_aStruct,{"A2_TEL4"   ,"C",50,0})   // telefone2: null
   Aadd(_aStruct,{"A2_TEL1W"  ,"C",50,0})   // celular1_whatsapp: true
   Aadd(_aStruct,{"A2_TEL2W"  ,"C",50,0})   // celular2_whatsapp: false
   Aadd(_aStruct,{"WK_ORDEMP" ,"C",1 ,0})   // Ordenação Produtor para envio.
   Aadd(_aStruct,{"WK_RECNO"  ,"N",10 ,0})  // Nr Recno SA2
   Aadd(_aStruct,{"A2_L_ATIVO","C",10 ,0})  // situacao  // Ativo / Inativo

   If Select("TRBCABA") > 0
      TRBCABA->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBCABA criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp := FWTemporaryTable():New( "TRBCABA",  _aStruct )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp:AddIndex( "01", {"A2_COD"} )
   _oTemp:AddIndex( "02", {"A2_CGC"} )
   _oTemp:AddIndex( "03", {"WK_ORDEMP","A2_COD","A2_LOJA"} )
   _oTemp:Create()

   DBSelectArea("TRBCABA")

   _aStruct2 := {}
   Aadd(_aStruct2,{"A2_COD"    ,"C",6  ,0})  // matricula_laticinio: TESTE_278363
   Aadd(_aStruct2,{"A2_LOJA"   ,"C",4  ,0})  // Loja_laticinio: TESTE_278363
   Aadd(_aStruct2,{"A2_CGC"    ,"C",14 ,0})  // cpf_cnpj: 349.812.172-34
   Aadd(_aStruct2,{"A2_L_FAZEN","C",40 ,0})  // nome_propriedade_rural: PROPRIEDADE TESTE 001
   Aadd(_aStruct2,{"A2_L_NIRF" ,"C",11 ,0})  // NIRF: ABC4658
   Aadd(_aStruct2,{"A2_L_TANQ" ,"C",6  ,0})  // id_tipo_tanque: 1
   Aadd(_aStruct2,{"A2_L_TANLJ","C",4  ,0})  // Loja Tanque
   Aadd(_aStruct2,{"A2_L_CAPTQ","N",11 ,0})  // capacidade_tanque: 720
   Aadd(_aStruct2,{"A2_L_LATIT","N",10 ,6})  // latitude_propriedade: -17.855250
   Aadd(_aStruct2,{"A2_L_LONGI","N",10 ,6})  // longitude_propriedade: -46.223278
   Aadd(_aStruct2,{"A2_L_MARTQ","C",20 ,0})  // Marca do Tanque
   Aadd(_aStruct2,{"A2_L_CLASS","C",01 ,0})  // id_tipo_tanque
//----------------------------------------------------------------------------------
   Aadd(_aStruct2,{"A2_L_LI_RO","C",06 ,0})  // Código_Linha_Rota
   Aadd(_aStruct2,{"ZL3_DESCRI","C",40 ,0})  // Descrição_Linha_Rota
//----------------------------------------------------------------------------------
   Aadd(_aStruct2,{"WK_AREA"   ,"N",12 ,6})  // area: 2000.15
   Aadd(_aStruct2,{"WK_RECRIA" ,"C",10 ,0})  // recria: 1
   Aadd(_aStruct2,{"WK_VACASEC","C",10 ,0})  // vaca_seca: 12
   Aadd(_aStruct2,{"WK_VACALAC","C",10 ,0})  // vaca_lactacao: 6
   Aadd(_aStruct2,{"WK_HORACOL","C",10 ,0})  // horario_coleta: 23:59
   Aadd(_aStruct2,{"WK_RACAPRO","C",50 ,0})  // raca_propriedade: Nome Raça predominante Teste
   Aadd(_aStruct2,{"A2_L_FREQU","C",10 ,0})  // frequencia_coleta: 17
   Aadd(_aStruct2,{"WK_PRDDIAR","N",10 ,2})  // fproducao_media_diaria: 7251.31
   Aadd(_aStruct2,{"WK_AREAUTI","N",10 ,2})  // area_utilizada_producao: 837.84
   //Aadd(_aStruct2,{"WK_CAPREFR","N",10 ,2})  // capacidade_refrigeracao: 307
   Aadd(_aStruct2,{"A2_L_CAPAC","C",01 ,0})  // capacidade_refrigeracao: 307
   Aadd(_aStruct2,{"A2_L_ATIVO","C",10 ,0})  // situacao  // Ativo / Inativo
   Aadd(_aStruct2,{"A2_L_SIGSI","C",11 ,0})  // SigSif
   Aadd(_aStruct2,{"A2_L_RESFR","C",1  ,0})  // id_tab_tanque_tipo_resfriamento
//---------------------------------------------------------------------------------
   Aadd(_aStruct2,{"A2_ENDCOMP","C",50 ,0})  // complemento: Complemento Teste
   Aadd(_aStruct2,{"A2_END"    ,"C",90 ,0})  // endereco: Rua Caminho Andante
   Aadd(_aStruct2,{"WK_NUMERO" ,"C",20 ,0})  // numero: 429 A
   Aadd(_aStruct2,{"A2_BAIRRO" ,"C",50 ,0})  // bairro: Bairro Teste
   Aadd(_aStruct2,{"A2_CEP"    ,"C",8  ,0})  // cep: 51462-745
   Aadd(_aStruct2,{"A2_COD_MUN","C",5  ,0})  // id_cidade: 73
   Aadd(_aStruct2,{"A2_MUN"    ,"C",50 ,0})  // municipio
   Aadd(_aStruct2,{"A2_EST"    ,"C",2  ,0})  // estado
   Aadd(_aStruct2,{"A2_EMAIL"  ,"C",100,0})  // email: TESTE_278363@email.com
   Aadd(_aStruct2,{"A2_DDD"    ,"C",3  ,0})  // celular1: 95920298034
   Aadd(_aStruct2,{"A2_TEL"    ,"C",50 ,0})  // celular1: 95920298034
//---------------------------------------------------------------------------------
   Aadd(_aStruct2,{"WK_ORDEMP" ,"C",1  ,0})  // Ordenação Produtor para envio.
   Aadd(_aStruct2,{"WK_RECNO"  ,"N",10 ,0})  // Nr Recno SA2

   If Select("TRBDETA") > 0
      TRBDETA->(DbCloseArea())
   EndIf

   //================================================================================
   // Abre o arquivo TRBDETA criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp2 := FWTemporaryTable():New( "TRBDETA",  _aStruct2 )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp2:AddIndex( "01", {"A2_COD"})
   _oTemp2:AddIndex( "02", {"A2_COD","A2_LOJA"})
   _oTemp2:AddIndex( "03", {"A2_CGC"})
   _oTemp2:AddIndex( "04", {"WK_ORDEMP","A2_COD","A2_LOJA"} )
   _oTemp2:Create()

   DBSelectArea("TRBDETA")

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   _cQry := " SELECT DISTINCT A2_COD, "  // matricula_laticinio: TESTE_278363
   _cQry += " A2_NOME, "                 // nome_razao_social  : PRODUTOR TESTE 3337
   _cQry += " A2_CGC, "                  // cpf_cnpj: 349.812.172-34
   _cQry += " A2_INSCR, "                // inscricao_estadual: 170642
   _cQry += " A2_PFISICA, "              // rg_ie: ABC320303
   _cQry += " A2_PRICOM, "               // data_nascimento_fundacao: 1994-10-10
   _cQry += " A2_ENDCOMP, "              // complemento: Complemento Teste
   _cQry += " A2_END, "                  // endereco: Rua Caminho Andante
   _cQry += " A2_BAIRRO, "               // bairro: Bairro Teste
   _cQry += " A2_CEP, "                  // cep: 51462-745
   _cQry += " A2_COD_MUN, "              // id_cidade: 73
   _cQry += " A2_MUN, "                  // municipio
   _cQry += " A2_EST, "                  // estado
   _cQry += " A2_EMAIL, "                // email: TESTE_278363@email.com
   _cQry += " A2_DDD, "                  // DDD
   _cQry += " A2_TEL, "                  // celular1: 95920298034
   _cQry += " A2_LOJA, "                 // Loja_laticinio: TESTE_278363
//---------------------------------------------------------------------------------------
   _cQry += " A2_BANCO, "                // codigo do banco
   _cQry += " A2_AGENCIA, "              // codigo da agencia
   _cQry += " A2_NUMCON, "               // numero da conta
//---------------------------------------------------------------------------------------
   _cQry += " A2_L_FAZEN, "              // nome_propriedade_rural: PROPRIEDADE TESTE 001
   _cQry += " A2_L_NIRF, "               // NIRF: ABC4658
   _cQry += " A2_L_TANQ, "               // id_tipo_tanque: 1
   _cQry += " A2_L_CAPTQ, "              // capacidade_tanque: 720
   _cQry += " A2_L_LATIT, "              // latitude_propriedade: -17.855250
   _cQry += " A2_L_LONGI, "              // longitude_propriedade: -46.223278
   _cQry += " A2_L_FREQU, "              // frequencia_coleta: 17
   _cQry += " A2_L_MARTQ, "              // Marca do Tanque
   _cQry += " A2_L_CAPAC, "              // capacidade_refrigeracao: 307
   _cQry += " A2_L_CLASS, "              // id_tipo_tanque
   _cQry += " A2_L_ATIVO, "              // ativo inativo
   _cQry += " A2_L_SIGSI, "              //
   _cQry += " A2_L_TANLJ, "              //
   _cQry += " A2_L_RESFR, "              //
//----------------------------------------------------------------------------
   _cQry += " A2_L_LI_RO, "              //
   _cQry += " ZL3_DESCRI, "              //
//----------------------------------------------------------------------------
   _cQry += " SA2.R_E_C_N_O_ AS NRREG, "  // capacidade_refrigeracao: 307
//--------------------------------------------------------------------------------
   _cQry += " CASE "
   _cQry += "     WHEN A2_L_CLASS = 'C' THEN 'B' "
   _cQry += "     WHEN A2_L_CLASS = 'U' THEN 'C' "
   _cQry += "     WHEN A2_L_CLASS = 'F' THEN 'D' "
   _cQry += "     ELSE 'A' "
   _cQry += " END AS ORDEMP"
//--------------------------------------------------------------------------------
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZL3_COD = A2_L_LI_RO "
   _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' " // Cada filial/Cnpj Italac possui um Usuário e Senha. Ler do cadastro empresas Webservice. Enviar apenas as filias 01, 04, 23. 01=Corumbaiba/GO, 04=Araguari/MG, 23=Tapejara/RS
   _cQry += " AND SA2.A2_L_ENVEV = 'N' "  // Indica que já existe registro deste produtor no cadastro de Fornecedores.
   _cQry += " AND SA2.A2_L_ENVAT = 'S' "  // Indica alteração no produtor e deve ser enviado novamente para Evomilk.
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   //_cQry += " AND A2_L_ATIVO <> 'N' "   // Solicitação da Evomilk em 21/07/2022. Enviar também os produtores de leite inativos.
   _cQry += " AND A2_COD <> '      ' "
   _cQry += " ORDER BY ORDEMP, A2_COD,A2_LOJA "

   If Select("QRYSA2A") > 0
      QRYSA2A->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYSA2A")

   _cCodForn := Space(6)

   QRYSA2A->(DbGotop())

   Do While ! QRYSA2A->(Eof())

      If Empty(QRYSA2A->A2_COD) // Foi identificado no cadastro de fornecedores alguns registros sem o código preenchido.
         QRYSA2A->(DbSkip())
         Loop
      EndIf

      //=============================================================================
      // Verifica se o Produtor possui mais de uma propriedade e envia apenas os
      // que possuirem apenas uma propriedade.
      // Esta é uma soliciatação feita em reunião dia 23/01/2022. É temporário.
      //=============================================================================
/*      If U_MGLT032Z(QRYSA2A->A2_COD)
         QRYSA2A->(DbSkip())
         Loop
      EndIf
*/
      //=============================================================================
      // Grava as tabelas temporárias para envio dos dados
      //=============================================================================
      If _cCodForn <> QRYSA2A->A2_COD
         _cCodForn := QRYSA2A->A2_COD

         TRBCABA->(DBAPPEND())
         TRBCABA->A2_COD     := QRYSA2A->A2_COD            // id_tipo_tanque: 1
         TRBCABA->A2_LOJA    := QRYSA2A->A2_LOJA
         TRBCABA->A2_NOME    := QRYSA2A->A2_NOME           //C,40  // nome_razao_social  : PRODUTOR TESTE 3337
         TRBCABA->A2_CGC     := QRYSA2A->A2_CGC            //C,14  // cpf_cnpj: 349.812.172-34
         TRBCABA->A2_INSCR   := QRYSA2A->A2_INSCR          //C,18  // inscricao_estadual: 170642
         TRBCABA->A2_PFISICA := QRYSA2A->A2_PFISICA        //C,18  // rg_ie: ABC320303
         TRBCABA->A2_PRICOM  := Stod(QRYSA2A->A2_PRICOM)   //D,8   // data_nascimento_fundacao: 1994-10-10
         TRBCABA->WK_OBSERV  := ""                        //C,100 // info_adicional: Observação / info adicional...
         TRBCABA->A2_ENDCOMP := QRYSA2A->A2_ENDCOMP        //C,50  // complemento: Complemento Teste
         TRBCABA->A2_END     := QRYSA2A->A2_END            //C,90  // endereco: Rua Caminho Andante
         TRBCABA->WK_NUMERO  := ""                        //C,20  // numero: 429 A
         TRBCABA->A2_BAIRRO  := QRYSA2A->A2_BAIRRO         //C,50  // bairro: Bairro Teste
         TRBCABA->A2_CEP     := QRYSA2A->A2_CEP            //C,8   // cep: 51462-745
         TRBCABA->WK_ID_UF   := ""                        //C,2   // id_uf: 21
         TRBCABA->A2_COD_MUN := QRYSA2A->A2_COD_MUN        //C,5   // id_cidade: 73
         TRBCABA->A2_MUN     := QRYSA2A->A2_MUN            // municipio
         TRBCABA->A2_EST     := QRYSA2A->A2_EST            // estado
         TRBCABA->A2_BANCO   := QRYSA2A->A2_BANCO          // codigo do banco
         TRBCABA->A2_AGENCIA := QRYSA2A->A2_AGENCIA        // codigo da agencia
         TRBCABA->A2_NUMCON  := QRYSA2A->A2_NUMCON         // numero da conta
         TRBCABA->A2_EMAIL   := QRYSA2A->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
         TRBCABA->A2_TEL     := AllTrim(QRYSA2A->A2_DDD)+QRYSA2A->A2_TEL //C,50  // celular1: 95920298034
         TRBCABA->A2_TEL2    := ""                        //C,50  // celular2: null
         TRBCABA->A2_TEL3    := ""                        //C,50  // telefone1: 5590038949
         TRBCABA->A2_TEL4    := ""                        //C,50  // telefone2: null
         TRBCABA->A2_TEL1W   := "False"                   //C,50  // celular1_whatsapp: true
         TRBCABA->A2_TEL2W   := "False"                   //C,50  // celular2_whatsapp: false
         TRBCABA->WK_RECNO   := QRYSA2A->NRREG             //N,10 ,0 // Nr Recno SA2
         TRBCABA->WK_ORDEMP  := QRYSA2A->ORDEMP            // Ordenação dos dados para envio
      EndIf

      TRBDETA->(DbAppend())
      TRBDETA->A2_COD     := QRYSA2A->A2_COD  // QRYSA2A->A2_L_TANQ      // QRYSA2A->A2_COD         //C,6     // matricula_laticinio: TESTE_278363
      TRBDETA->A2_LOJA    := QRYSA2A->A2_LOJA // QRYSA2A->A2_L_TANLJ     // QRYSA2A->A2_LOJA        //C,4     // Loja_laticinio: TESTE_278363
      TRBDETA->A2_CGC     := QRYSA2A->A2_CGC         //C,14    // cpf_cnpj: 349.812.172-34
      TRBDETA->A2_L_FAZEN := QRYSA2A->A2_L_FAZEN     //C,40    // nome_propriedade_rural: PROPRIEDADE TESTE 001
      TRBDETA->A2_L_NIRF  := QRYSA2A->A2_L_NIRF      //C,11    // NIRF: ABC4658
      TRBDETA->A2_L_TANQ  := QRYSA2A->A2_L_TANQ      //C,10    // id_tipo_tanque: 1
      TRBDETA->A2_L_CAPTQ := QRYSA2A->A2_L_CAPTQ     //N,11    // capacidade_tanque: 720
      TRBDETA->A2_L_LATIT := QRYSA2A->A2_L_LATIT     //N,10 ,6 // latitude_propriedade: -17.855250
      TRBDETA->A2_L_LONGI := QRYSA2A->A2_L_LONGI     //N,10 ,6 // longitude_propriedade: -46.223278
      TRBDETA->A2_L_MARTQ := QRYSA2A->A2_L_MARTQ     //C,20    // id_tipo_tanque: // Marca do tanque
      TRBDETA->A2_L_CLASS := QRYSA2A->A2_L_CLASS     //C,01    // id_tipo_tanque:
      TRBDETA->WK_AREA    := 0                      //N,12 ,6 // area: 2000.15
      TRBDETA->WK_RECRIA  := ""                     //C,10    // recria: 1
      TRBDETA->WK_VACASEC := ""                     //C,10    // vaca_seca: 12
      TRBDETA->WK_VACALAC := ""                     //C,10    // vaca_lactacao: 6
      TRBDETA->WK_HORACOL := ""                     //C,10    // horario_coleta: 23:59
      TRBDETA->WK_RACAPRO := ""                     //C,50    // raca_propriedade: Nome Raça predominante Teste
      TRBDETA->A2_L_FREQU := QRYSA2A->A2_L_FREQU     //C,10    // frequencia_coleta: 17
      TRBDETA->WK_PRDDIAR := 0                      //N,10 ,2 // fproducao_media_diaria: 7251.31
      TRBDETA->WK_AREAUTI := 0                      //N,10 ,2 // area_utilizada_producao: 837.84
      TRBDETA->A2_L_CAPAC := QRYSA2A->A2_L_CAPAC     //N,10 ,2 // capacidade_refrigeracao: 307
      TRBDETA->WK_RECNO   := QRYSA2A->NRREG          //N,10 ,0 // Nr Recno SA2
      //-------------------------------------------------------
      TRBDETA->A2_L_LI_RO := QRYSA2A->A2_L_LI_RO     //        codigo_linha_laticinio
      TRBDETA->ZL3_DESCRI := QRYSA2A->ZL3_DESCRI     //        nome_linha
      TRBDETA->A2_L_ATIVO := If(QRYSA2A->A2_L_ATIVO=="N","false","true") // _cSituacao
      TRBDETA->A2_L_SIGSI := QRYSA2A->A2_L_SIGSI     // _cSigSif
      TRBDETA->A2_L_TANLJ := QRYSA2A->A2_L_TANLJ     // Loja tanque
      TRBDETA->A2_L_RESFR := QRYSA2A->A2_L_RESFR     // _cTipoResf
//--------------------------------------------------------------------------------------------------
      TRBDETA->A2_ENDCOMP := QRYSA2A->A2_ENDCOMP     // complemento: Complemento Teste
      TRBDETA->A2_END     := QRYSA2A->A2_END         // endereco: Rua Caminho Andante
      TRBDETA->WK_NUMERO  := ""                      // numero: 429 A
      TRBDETA->A2_BAIRRO  := QRYSA2A->A2_BAIRRO      // bairro: Bairro Teste
      TRBDETA->A2_CEP     := QRYSA2A->A2_CEP         // cep: 51462-745
      TRBDETA->A2_COD_MUN := QRYSA2A->A2_COD_MUN     // id_cidade: 73
      TRBDETA->A2_MUN     := QRYSA2A->A2_MUN         // municipio
      TRBDETA->A2_EST     := QRYSA2A->A2_EST         // estado
      TRBDETA->A2_EMAIL   := QRYSA2A->A2_EMAIL       // email: TESTE_278363@email.com
      TRBDETA->A2_TEL     := AllTrim(QRYSA2A->A2_DDD)+QRYSA2A->A2_TEL // celular1: 95920298034
//--------------------------------------------------------------------------------------------------
      TRBDETA->WK_ORDEMP  := QRYSA2A->ORDEMP         // Ordenação dos dados para envio

      _lHaDadosP := .T.

      QRYSA2A->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032D
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Envio de Atualização dos dados dos Produtores Rurais via WebService Italac
                     para Sistema Evomilk (Essa rotina lê os dados das tabelas temporárias e transmite).
===============================================================================================================================
Parametros--------: _cChamada = "M" = Rotina Chamada via menu.
                                "S" = Rotina Chamada via Scheduller
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032D(_cChamada)
Local _cCabec, _cDetalhe, _cRodaPe
Local _cItens //, _cEnvio
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cJSonProd, _cJSonGrp
Local _cHoraIni, _cHoraFin, _cMinutos, _nMinutos
Local _nTotRegEnv := 1 // 100  // Total de registros para envio.
Local _nI , _oRetJSon, _lResult
Local _aProdEnv
Local _aHeadOut := {}
Local _aRecnoSA2, _cRetorno, _nX
Local _cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")

        // Cabeçalho
Private _cIdProdut := ""
Private _cMatLatic := ""   //            matricula_laticinio
Private _cRazaoSoc := ""   //            nome_razao_social
Private _cCpf_Cnpj := ""   //            cpf_cnpj
Private _cInscrEst := ""   //            inscricao_estadual
Private _cRg_IE    := ""   //            rg_ie
Private _cDtNascF  := ""   //            data_nascimento_fundacao
Private _cObserv   := ""   //            info_adicional
Private _cComplem  := ""   //            complemento
Private _cEndereco := ""   //            endereco
Private _cNrEnd    := ""   //            numero
Private _cBairro   := ""   //            bairro
Private _cCep      := ""   //            cep
Private _cIdUF     := ""   //            id_uf
Private _cIDCidade := ""   //            id_cidade
//--------------------------------------------------------------------//
Private _cComplemD := ""   //            complemento
Private _cEnderecD := ""   //            endereco
Private _cNrEndD   := ""   //            numero
Private _cBairroD  := ""   //            bairro
Private _cCepD     := ""   //            cep
Private _cIdUFD    := ""   //            id_uf
Private _cIDCidadD := ""   //            id_cidade

//--------------------------------------------------------------------//
Private _cCodBanco := ""   //            Codigo do Banco
Private _cCodAgenc := ""   //            Codigo da Agencia
Private _cNumConta := ""   //            Numero da Conta
//--------------------------------------------------------------------//
Private _cEMail    := ""   //            email
Private _cEMailD   := ""   //            email 2
Private _cCelular  := ""   //            celular1
Private _cCelula2  := ""   //            celular2
Private _cTelefon1 := ""   //            telefone1
Private _cTelefon2 := ""   //            telefone2
Private _cWhatsAp1 := ""   //            celular1_whatsapp
Private _cWhatsAp2 := ""   //            celular2_whatsapp
Private _cTelefonD := ""   //            Telefone demais propriedades
            // Detalhe
Private _cNomeProp  := ""  //           nome_propriedade_rural
Private _cNIRF      := ""  //           NIRF
Private _cTipoTanq  := ""  //           id_tipo_tanque
Private _cCapacTnq  := ""  //           capacidade_tanque
Private _cLatitude  := ""  //           latitude_propriedade
Private _cLongitud  := ""  //           longitude_propriedade
Private _cArea      := ""  //           area
Private _cRecria    := ""  //           recria
Private _cVacaSeca  := ""  //           vaca_seca
Private _cVacaLacta := ""  //           vaca_lactacao
Private _cHoraCole  := ""  //           horario_coleta
Private _cRacaProp  := ""  //           raca_propriedade
Private _cFreqCol   := ""  //           frequencia_coleta
Private _cProdDia   := ""  //           producao_media_diaria
Private _cAreaUti   := ""  //           area_utilizada_producao
Private _cCapacRef  := ""  //           capacidade_refrigeracao
Private _cCodPropr  := ""  //           codigo_propriedade_laticinio
Private _cCodLinha  := ""  //           codigo_linha_laticinio
Private _cDescLin   := ""  //           nome_linha

//-------------------------------------------------------------------//
Private _cSituacao  := ""
Private _cCidade    := ""
Private _cUF        := ""
Private _cCod_Ibge  := ""
Private _cCodIbgeD  := ""
Private _cSigSif    := ""
Private _cCodPropL  := ""
Private _cCodigotq  := ""
Private _cTipoResf  := ""
Private _cMarcaTanq := ""

Private _cCPFCnpjP := ""
Private _cMatParce := ""


//=========================================================================
// Nova Tags
//=========================================================================
Private _cTitTanq  := ""    // cpf_cnpj
Private _cMatrLat  := ""    // matricula_laticinio
Private _cTelPrinc := "SIM" // telefone_principal
Private _cEMailPri := "SIM" // email_principal
Private _cSitTnq   := ""  // situacao
Private _CSITPROP  := ""  // Situação Proprietario
Private _CCLASPROP := ""  // Classificação Proprietári do Tanque
Private _CNOMETNQ  := ""  // Nome do Tanque
Private _cNomBanco := ""  // Nome do Banco
Private _cTitConta := ""
Private _cInfoAdic := ""
Private _CDataCad  := ""
Private _cHoraCad  := ""
Private _cProduTit := "true"
Private _cContaPri := "true"

Default _cChamada := "M"

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _cLinkWS  := AllTrim(ZFM->ZFM_LINK04) // Link de envio de atualização de Produtores.
      IF !!EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   If Empty(_cDirJSon)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON e os transforma em String.
   //================================================================================
   _cCabec := U_MGLT032X(_cDirJSon+"Cabec_CIA_LEITE_PRODUTOR.txt")
   If Empty(_cCabec)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDetalhe := U_MGLT032X(_cDirJSon+"Detalhe_CIA_LEITE_PRODUTOR.txt")

   If Empty(_cDetalhe)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON detalhe/Propriedades produtor rural.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cRodape := U_MGLT032X(_cDirJSon+"Rodape_CIA_LEITE_PRODUTOR.txt")
   If Empty(_cRodape)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Rodape Produtor Rural Integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

   If Empty(_cKey)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   _cHoraIni := Time() // Horario Inicial de Processamento

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

   _cJSonProd := "["
   _cJSonGrp := ""
   _nI := 1

   _aProdEnv := {}

   TRBCABA->(DbSetOrder(3)) // {"WK_ORDEMP","A2_COD","A2_LOJA"}
   TRBDETA->(DbSetOrder(1))

   TRBCABA->(DbGoTop())
   Do While ! TRBCABA->(Eof())
      //====================================================================
      // Calcula o tempo decorrido para obtenção de um novo Token
      //====================================================================
      _cHoraFin := Time()
      _cMinutos := ElapTime (_cHoraIni , _cHoraFin)
      _nMinutos := Val(SubStr(_cMinutos,4,2))
      If _nMinutos > 5 // 28 //  minutos
         _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

         If Empty(_cKey)
            If _cChamada == "M" // Chamada via menu.
               U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores cancelada.","Atenção",,1)
            EndIf

            Break
         EndIf

         _aHeadOut := {}
         Aadd(_aHeadOut,'Accept: application/json')
         Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
         Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

         _cHoraIni := Time()

      EndIf

      //====================================================================
      // Efetua a leitura dos dados para montagem do JSON.
      //====================================================================
      _cItens := ""
      _cIdProdut := TRBCABA->A2_COD+"-"+TRBCABA->A2_LOJA
      _cMatLatic := "" // TRBCABA->A2_COD+"-"+TRBCABA->A2_LOJA//            matricula_laticinio
      _cRazaoSoc := TRBCABA->A2_NOME             //            nome_razao_social
      _cCpf_Cnpj := TRBCABA->A2_CGC              //            cpf_cnpj
      _cInscrEst := TRBCABA->A2_INSCR            //            inscricao_estadual
      _cRg_IE    := TRBCABA->A2_PFISICA          //            rg_ie
      _cDtNascF  := StrZero(Year(TRBCABA->A2_PRICOM),4)+"-"+StrZero(Month(TRBCABA->A2_PRICOM),2)+"-"+StrZero(Day(TRBCABA->A2_PRICOM),2)   //            data_nascimento_fundacao
      _cObserv   := ""                          //            info_adicional
      _cComplem  := TRBCABA->A2_ENDCOMP          //            complemento
      _cEndereco := TRBCABA->A2_END              //            endereco
      _cNrEnd    := ""                          //            numero
      _cBairro   := TRBCABA->A2_BAIRRO           //            bairro
      _cCep      := TRBCABA->A2_CEP              //            cep
      _cIdUF     := ""                          //            id_uf
      _cIDCidade := ""                          //            id_cidade
      _cCidade   := AllTrim(TRBCABA->A2_MUN)    //            municipio
      _cUF       := AllTrim(TRBCABA->A2_EST)    //            estado
      _cCod_Ibge := TRBCABA->A2_COD_MUN         //            codigo_ibge"
//---------------------------------------------------------------------------------------------------
      _cCodBanco := AllTrim(TRBCABA->A2_BANCO)            //            Codigo do Banco
      _cCodAgenc := AllTrim(TRBCABA->A2_AGENCIA)          //            Codigo da Agencia
      _cNumConta := AllTrim(TRBCABA->A2_NUMCON)           //            Numero da Conta
      _cNomBanco := AllTrim(POSICIONE('SA6',1,xFilial('SA6')+_cCodBanco,'A6_NOME'))
      _cTitConta := TRBCABA->A2_NOME
      _cInfoAdic := ""
//---------------------------------------------------------------------------------------------------
      _cEMail    := TRBCABA->A2_EMAIL            //            email
      _cCelular  := ""                          //            celular1
      _cCelula2  := ""                          //            celular2
      _cTelefon1 := TRBCABA->A2_TEL              //            telefone1

      If Empty(_cTelefon1)
         _cTelefon1 := "null"
      Else
         _cTelefon1 := '"' +AllTrim(_cTelefon1)  + '"'
      EndIf

      _cTelefon2 := ""                          //            telefone2
      _cWhatsAp1 := "SIM"                       //            celular1_whatsapp
      _cWhatsAp1 := "false"                     //            celular2_whatsapp

      _aRecnoSA2 := {}
      //Aadd(_aRecnoSA2, TRBCABA->WK_RECNO)

      TRBDETA->(MsSeek(TRBCABA->A2_COD))

      Do While ! TRBDETA->(Eof()) .And. TRBCABA->A2_COD == TRBDETA->A2_COD
         _cCodPropr  := ""                                    //           codigo_propriedade_laticinio
         _cNomeProp  := TRBDETA->A2_L_FAZEN                    //           nome_propriedade_rural
         _cNIRF      := TRBDETA->A2_L_NIRF                     //           NIRF
         //_cTipoTanq  := ""                                  //           id_tipo_tanque  // A2_L_TANQ // tipo_tanque // A2_L_MARTQ

         _cCodPropL  := TRBDETA->A2_COD+"-"+TRBDETA->A2_LOJA
         _cMatLatic  := TRBDETA->A2_COD+"-"+TRBDETA->A2_LOJA    // TRBCABA->A2_COD+"-"+TRBCABA->A2_LOJA//            matricula_laticinio

         _cTipoTanq  := "INDIVIDUAL"
         _CCLASPROP  := "PRODUTOR INDIVIDUAL"

         _cMatrLat   := ""
         _cTitTanq   := ""
         _cMatParce  := ""
         _cCPFCnpjP  := ""

         If TRBDETA->A2_L_CLASS == "C"
            _cTipoTanq  := "COLETIVO"
            _CCLASPROP  := "TITULAR DE TANQUE COMUNITARIO"
         ElseIf TRBDETA->A2_L_CLASS == "U"
            _CCLASPROP  := "USUARIO DE TANQUE COMUNITARIO"
            _cTipoTanq  := "COLETIVO"
            _cMatrLat   := TRBDETA->A2_L_TANQ+"-"+TRBDETA->A2_L_TANLJ
            _cTitTanq   := POSICIONE('SA2',1,xFilial('SA2')+TRBDETA->A2_L_TANQ+TRBDETA->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
         ElseIf TRBDETA->A2_L_CLASS == "F"
             //_cTipoTanq  := "INDIVIDUAL"
             //_CCLASPROP  := "PRODUTOR INDIVIDUAL"
             _cTipoTanq  := "FAMILIAR" //"INDIVIDUAL"
             _CCLASPROP  := "USUARIO DE TANQUE COMUNITARIO" // "PRODUTOR INDIVIDUAL"
             _cCPFCnpjP  := POSICIONE('SA2',1,xFilial('SA2')+TRBDETA->A2_L_TANQ+TRBDETA->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
             _cMatParce  := TRBDETA->A2_L_TANQ+"-"+TRBDETA->A2_L_TANLJ
         EndIf

         If ! Empty(_cCPFCnpjP) .And. AllTrim(_cCPFCnpjP) == AllTrim(_cCpf_Cnpj)
            _cCPFCnpjP := ""
            _cMatParce := ""
         EndIf

         _CNOMETNQ   := TRBDETA->A2_L_TANQ+"-"+TRBDETA->A2_L_TANLJ //        Nome do Tanque
         _cCapacTnq  := AllTrim(Str(TRBDETA->A2_L_CAPTQ,11))   //           capacidade_tanque
         _cLatitude  := AllTrim(Str(TRBDETA->A2_L_LATIT,18,6)) //           latitude_propriedade
         _cLongitud  := AllTrim(Str(TRBDETA->A2_L_LONGI,18,6)) //           longitude_propriedade
         _cArea      := ""                                    //           area
         _cRecria    := ""                                    //           recria
         _cVacaSeca  := ""                                    //           vaca_seca
         _cVacaLacta := ""                                    //           vaca_lactacao
         _cHoraCole  := ""                                    //           horario_coleta
         _cRacaProp  := ""                                    //           raca_propriedade
         //_cFreqCol   := TRBDETA->A2_L_FREQU                  //           frequencia_coleta

         If TRBDETA->A2_L_FREQU == "1"
            _cFreqCol   := "48"                               //           frequencia_coleta
         Else
            _cFreqCol   := "24"
         EndIf

         _cProdDia   := ""                                    //           producao_media_diaria
         _cAreaUti   := ""                                    //           area_utilizada_producao
         _cCapacRef  := ""                                    //           capacidade_refrigeracao
         //Cap. Resfri.	Capacidade Resfriamento	0=Nenhuma	2=Duas Ordenhas	4=Quatro Ordenhas

         If TRBDETA->A2_L_CAPAC == "0"
            //_cCapacRef  := AllTrim(Str(TRBDETA->A2_L_CAPTQ,10,6))
            _cCapacRef  := "Nenhuma"
         ElseIf TRBDETA->A2_L_CAPAC == "2"
            _cCapacRef  := "Duas Ordenhas"
         ElseIf TRBDETA->A2_L_CAPAC == "4"
            _cCapacRef  := "Quatro Ordenhas"
         EndIf

         If Empty(_cCapacRef)
            _cCapacRef := "nenhuma"
         EndIf

         _cSituacao  := TRBDETA->A2_L_ATIVO
         _cSitTnq    := TRBDETA->A2_L_ATIVO
         _CSITPROP   := TRBDETA->A2_L_ATIVO
         _cSigSif    := TRBDETA->A2_L_SIGSI
         _cCodigotq  := TRBDETA->A2_L_TANQ+"-"+TRBDETA->A2_L_TANLJ
         _cTipoResf  := If(TRBDETA->A2_L_RESFR == "E","EXPANSAO","IMERSAO")
         _cMarcaTanq := TRBDETA->A2_L_MARTQ
         _cCodLinha  := TRBDETA->A2_L_LI_RO   //           codigo_linha_laticinio
         _cDescLin   := TRBDETA->ZL3_DESCRI   //           nome_linha
//---------------------------------------------------------------------------------
         _cComplemD  := TRBDETA->A2_ENDCOMP          //            complemento
         _cEnderecD  := TRBDETA->A2_END              //            endereco
         _cNrEndD    := ""                          //            numero
         _cBairroD   := TRBDETA->A2_BAIRRO           //            bairro
         _cCepD      := TRBDETA->A2_CEP              //            cep
         _cIDCidadD  := ""                          //            id_cidade
         _cCidUFD    := AllTrim(TRBDETA->A2_MUN) + "\/" + AllTrim(TRBDETA->A2_EST)             // municipio  // estado
         _cCodIbgeD  := TRBDETA->A2_COD_MUN          //           codigo_ibge"
         _cEMailD    := TRBDETA->A2_EMAIL            //            email
         _cTelefonD  := TRBDETA->A2_TEL
//---------------------------------------------------------------------------------
         _cItens += If(!Empty(_cItens),",","") + &(_cDetalhe)

         //===========================================================
         // Guarda os fornecedores do JSon para atualização do SA2
         //===========================================================
         //Aadd(_aProdEnv, {TRBDETA->A2_COD, TRBDETA->A2_LOJA, TRBDETA->A2_L_FAZEN, TRBDETA->WK_RECNO})
         Aadd(_aRecnoSA2, TRBDETA->WK_RECNO)

         TRBDETA->(DbSkip())
      EndDo

      _CDataCad  := Dtoc(Date())
      _cHoraCad  := Time()

      _cJSonEnv := &(_cCabec) + _cItens + _cRodape
      _cJSonGrp += If(!Empty(_cJSonGrp),",","") + _cJSonEnv

      If _nI >= _nTotRegEnv

         _cJSonProd += _cJSonGrp + "]"
         _nStart 		:= 0
         _nRetry 		:= 0
         _cJSonRet 	:= Nil
         _nTimOut	 	:= 120
         _cRetorno   := ""
         _cRetHttp    := ''

         _cRetHttp := AllTrim( HTTPQuote(_cLinkWS ,"PUT", , _cJSonProd , _nTimOut, _aHeadOut, @_cJSonRet ) )

         If ! Empty(_cRetHttp)
            _cRetHttp := StrTran( _cRetHttp, "\n", "" )
            FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
         EndIf

         If ! Empty(_oRetJSon)
            _lResult := _oRetJSon:resultado
         EndIf

         _cRetorno := Upper(_cRetHttp)

         If _lResult // Integração realizada com sucesso
            //U_MGLT032Y(_aProdEnv) // Grava na tabela temporária os registros integrados com sucesso para depois ataualizar flag de envio da SA2.
            //============================================================
            // Grava dados dos Produtores Enviados e aceitos.
            //============================================================
            ZBH->(RecLock("ZBH",.T.))
            ZBH->ZBH_FILIAL := xFilial("ZBH")            // Filial do Sistema
            ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6)    // Codigo do Produtor
            ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4)    // Loja do Produtor
            ZBH->ZBH_NOMPRO := _cRazaoSoc                // Nome do Produtor
            ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBH->ZBH_JSONEN := _cJSonProd                // JSON enviado
            ZBH->ZBH_DTREJ  := Date()                    // Data da Rejeição
            ZBH->ZBH_HRREJ  := Time()                    // Hora da Rejeição
            ZBH->ZBH_DTENV	 := Date()                    // Data de Envio
            ZBH->ZBH_HRENV	 := Time()                    // Hora de Envio
            ZBH->ZBH_STATUS := "A"                       // Status da Integração
            ZBH->ZBH_WEBINT := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
			   ZBH->(MsUnLock())

            //====================================================================
            // Marca produtor como já enviado para o sistema Evomilk.
            //====================================================================
            if _lEfetivaEnvio
               For _nX := 1 To Len(_aRecnoSA2)
                   SA2->(DbGoto(_aRecnoSA2[_nX]))
                   SA2->(RecLock("SA2", .F.))
                   SA2->A2_L_ENVAT := "N"
                   SA2->(MsUnLock())
               Next _nX
            ENDIF

            _aRecnoSA2 := {}

         else
            //============================================================
            // Grava dados dos Produtores enviados e rejeitados.
            //============================================================
            ZBH->(RecLock("ZBH",.T.))
            ZBH->ZBH_FILIAL := xFilial("ZBH")            // Filial do Sistema
            ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6)    // Codigo do Produtor
            ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4)    // Loja do Produtor
            ZBH->ZBH_NOMPRO := _cRazaoSoc                // Nome do Produtor
            ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)        // Motivo da Rejeição
            ZBH->ZBH_JSONEN := _cJSonProd                // JSON enviado
            ZBH->ZBH_DTREJ  := Date()                    // Data da Rejeição
            ZBH->ZBH_HRREJ  := Time()                    // Hora da Rejeição
            ZBH->ZBH_DTENV	 := Date()                    // Data de Envio
            ZBH->ZBH_HRENV	 := Time()                    // Hora de Envio
            ZBH->ZBH_STATUS := "R"                       // Status da Integração
            ZBH->ZBH_WEBINT := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
			   ZBH->(MsUnLock())

            If ! Empty(_cRetorno) .And. "EXISTE UM PRODUTOR CADASTRADO" $ _cRetorno
               //====================================================================
               // Marca produtor como já enviado para o sistema Evomilk.
               //====================================================================
               if _lEfetivaEnvio
                  For _nX := 1 To Len(_aRecnoSA2)
                      SA2->(DbGoto(_aRecnoSA2[_nX]))
                      SA2->(RecLock("SA2", .F.))
                      SA2->A2_L_ENVAT := "N"
                      SA2->(MsUnLock())
                  Next _nX
               ENDIF
               _aRecnoSA2 := {}
            EndIf

         EndIf

         _aProdEnv := {}
         _cJSonProd := "["
         _cJSonGrp := ""
         _nI := 0

      EndIf

      _nI += 1

      TRBCABA->(DbSkip())
   EndDo

   If ! Empty(_cJSonGrp)
      _cJSonProd += _cJSonGrp + "]"

      _nStart 		:= 0
      _nRetry 		:= 0
      _cJSonRet 	:= Nil
      _nTimOut	 	:= 120
      _cRetorno   := ""

      _cRetHttp    := ''

      _cRetHttp := AllTrim( HTTPQuote(_cLinkWS ,"PUT", , _cJSonProd , _nTimOut, _aHeadOut, @_cJSonRet ) )

      If ! Empty(_cRetHttp)
         _cRetHttp := StrTran( _cRetHttp, "\n", "" )
         FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
      EndIf

      If ! Empty(_oRetJSon)
         _lResult := _oRetJSon:resultado
      EndIf

      _cRetorno := Upper(_cRetHttp)

      If _lResult // Integração realizada com sucesso
         //U_MGLT032Y(_aProdEnv) // Grava na tabela temporária os registros integrados com sucesso para depois ataualizar flag de envio da SA2.
         //=================================================================
         // Grava Dados dos Produtores Enviados e aceitos para histórico
         //=================================================================
         ZBH->(RecLock("ZBH",.T.))
         ZBH->ZBH_FILIAL := xFilial("ZBH")         // Filial do Sistema
         ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6) // Codigo do Produtor
         ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4) // Loja do Produtor
         ZBH->ZBH_NOMPRO := _cRazaoSoc             // Nome do Produtor
         ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)     // Motivo da Rejeição
         ZBH->ZBH_JSONEN := _cJSonProd             // JSON enviado
         //ZBH->ZBH_DTREJ  := Date()                 // Data da Rejeição
         //ZBH->ZBH_HRREJ  := Time()                 // Hora da Rejeição
         ZBH->ZBH_DTENV	    := Date()              // Data de Envio
         ZBH->ZBH_HRENV	    := Time()              // Hora de Envio
         ZBH->ZBH_STATUS	 := "A"                 // Status da Integração
         ZBH->ZBH_WEBINT    := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
			ZBH->(MsUnLock())

         //====================================================================
         // Marca produtor como já enviado para o sistema Evomilk.
         //====================================================================
         if _lEfetivaEnvio
            For _nX := 1 To Len(_aRecnoSA2)
                SA2->(DbGoto(_aRecnoSA2[_nX]))
                SA2->(RecLock("SA2", .F.))
                SA2->A2_L_ENVAT := "N"
                SA2->(MsUnLock())
            Next _nX
         ENDIF

         _aRecnoSA2 := {}

      else
         //============================================================
         // Grava dados de envio rejeitados para histórico.
         //============================================================
         ZBH->(RecLock("ZBH",.T.))
         ZBH->ZBH_FILIAL := xFilial("ZBH")          // Filial do Sistema
         ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6)    // Codigo do Produtor
         ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4)  // Loja do Produtor
         ZBH->ZBH_NOMPRO := _cRazaoSoc                // Nome do Produtor
         ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)        // Motivo da Rejeição
         ZBH->ZBH_JSONEN := _cJSonProd                // JSON enviado
         ZBH->ZBH_DTREJ  := Date()                    // Data da Rejeição
         ZBH->ZBH_HRREJ  := Time()                    // Hora da Rejeição
         ZBH->ZBH_DTENV	 := Date()                    // Data de Envio
         ZBH->ZBH_HRENV	 := Time()                    // Hora de Envio
         ZBH->ZBH_STATUS := "R"                       // Status da Integração
         ZBH->ZBH_WEBINT := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
			ZBH->(MsUnLock())

         If ! Empty(_cRetorno) .And. "EXISTE UM PRODUTOR CADASTRADO" $ _cRetorno
            //====================================================================
            // Marca produtor como já enviado para o sistema Evomilk.
            //====================================================================
            if _lEfetivaEnvio
               For _nX := 1 To Len(_aRecnoSA2)
                   SA2->(DbGoto(_aRecnoSA2[_nX]))
                   SA2->(RecLock("SA2", .F.))
                   SA2->A2_L_ENVAT := "N"
                   SA2->(MsUnLock())
               Next
            ENDIF

            _aRecnoSA2 := {}
         EndIf

      EndIf
   EndIf

   //=================================================================
   // Atualiza tabela SA2 aterando o flag dos produtores integrados.
   //=================================================================

   if _lEfetivaEnvio
      TRBSA2->(DbGoTop())
      Do while ! TRBSA2->(Eof())
         SA2->(DbGoto(TRBSA2->WK_RECNO))
         SA2->(RecLock("SA2", .F.))
         SA2->A2_L_ENVAT := "N"
         SA2->(MsUnLock())
         TRBSA2->(DbSkip())
      EndDo
   ENDIF
End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032U
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de leitura de arquivo Texto com produtores para alterar flag, para integrá-los novamente.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032U()
Local _aDados
Local _nStatusArq
Local _cLine, _cCodFor, _cLojaFor // , _cFilUnid
Local _nI

Begin Sequence

   If ! U_ITMSG("Confirma a atualização do cadastro de Produtores para Reenvio a Evomilk? " ,"Atenção" , , ,2, 2)
      Break
   EndIf

   _cDirTXT := "\data\Italac\CiaLeite\"//GetTempPath()
   _cNomeArq:= "Produtores_Cia_do_Leite.Txt"

   _cArq := _cDirTXT +_cNomeArq
   _nStatusArq := FT_FUse(_cArq)

   // Se houver erro de abertura abandona processamento
   If _nStatusArq = -1
      Break
   Endif

   // Posiciona na primeria linha
   FT_FGoTop()

   _aDados := {}

   While !FT_FEOF()
      _cLine  := FT_FReadLn()

      //_cFilUnid := SubStr(_cLine,1,2)
      _cCodFor  := SubStr(_cLine,1,6)
      _cLojaFor := SubStr(_cLine,08,4)

      //Aadd(_aDados,{_cFilUnid,_cCodFor,_cLojaFor})
      Aadd(_aDados,{_cCodFor,_cLojaFor})

      FT_FSKIP()
   End

   // Fecha o Arquivo
   FT_FUSE()

   For _nI := 1 To Len(_aDados)
       If SA2->(MsSeek(xFilial("SA2")+_aDados[_nI,1]+_aDados[_nI,2]))
          SA2->(RecLock("SA2", .F.))
          SA2->A2_L_ENVEV := " "
          SA2->A2_L_ITCOL := " "
          SA2->(MsUnLock())
       EndIf
   Next

End Sequence

U_ItMsg("Fim da atulização do cadastro de produtores para reenvio a Evomilk.","Atenção",,1)

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32TC
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo Texto com informações dos produtores usuários de tanques coletivos e produtores familiares, e
                     seus vinculos com os produtores principais.
                     A geração dos dados é por filial.
===============================================================================================================================
Parametros--------:  _cFilEnvio = Filial de geração dos dados
                     _cNomeFil  = Nome da Filial de Envio
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32TC(_cFilEnvio,_cNomeFil)
Local _cQry := ""
Local _cLinha, _cClassif
Local _lLinhaUm
Local _cFazenda

Default _cFilEnvio := xFilial("ZL3")
Default _cNomeFil := ""

_cDirTXT  := GetTempPath() //"\DATA\JULIO\"
_cNomeArq := "Listagem_com_Vinculação_Produtor_Usuario_TC_Familiar_e_Produtor_Principal_Filial_"

Begin Sequence

   _cQry := " SELECT DISTINCT A2_COD, "  // matricula_laticinio: TESTE_278363
   _cQry += " A2_LOJA, "                 // Loja_laticinio: TESTE_278363
   _cQry += " A2_NOME, "                 // nome_razao_social  : PRODUTOR TESTE 3337
   _cQry += " A2_CGC, "                  // cpf_cnpj: 349.812.172-34
   _cQry += " A2_L_FAZEN, "              // nome_propriedade_rural: PROPRIEDADE TESTE 001
   _cQry += " A2_L_NIRF, "               // NIRF: ABC4658
   _cQry += " A2_L_SIGSI, "              //
   _cQry += " A2_L_TANQ, "               // id_tipo_tanque: 1
   _cQry += " A2_L_TANLJ, "              //
   _cQry += " A2_L_CLASS, "
   _cQry += " SA2.R_E_C_N_O_ AS RECNOSA2, "
   _cQry += " (SELECT DISTINCT A2_CGC FROM " + RetSqlName("SA2") + " SA2B "
   _cQry += "  WHERE SA2B.D_E_L_E_T_ = ' ' AND SA2B.A2_COD = SA2.A2_L_TANQ AND SA2B.A2_LOJA = SA2.A2_L_TANLJ) AS CPFCNPJ "
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZL3_COD = A2_L_LI_RO "
   _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' " // Cada filial/Cnpj Italac possui um Usuário e Senha. Ler do cadastro empresas Webservice. Enviar apenas as filias 01, 04, 23. 01=Corumbaiba/GO, 04=Araguari/MG, 23=Tapejara/RS
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_L_ATIVO <> 'N' "
   _cQry += " AND A2_COD <> '      ' "
   _cQry += " AND (A2_L_CLASS = 'U' OR A2_L_CLASS = 'F') "
   _cQry += " ORDER BY A2_COD,A2_LOJA "

   If Select("QRYSA2") > 0
         QRYSA2->(DbCloseArea())
   EndIf


   MPSysOpenQuery( _cQry , "QRYSA2")

   _cCodForn := Space(6)

   QRYSA2->(DbGotop())

   ProcRegua(0)

   _cDirTXT := GetTempPath() //"\DATA\JULIO\"
   _cNomeArq:= _cNomeArq +_cFilEnvio + "_" + Lower(_cNomeFil) + ".Txt"

   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados Produtores usuários tanque coletivos e familiares e seu vinculos com o produtor principal.","Atenção",,1)
      Break
   EndIf

   _oFWriter:Write("[" + CRLF)

   _lLinhaUm := .T.

   Do While ! QRYSA2->(Eof())
      IncProc("Gravando arquivo texto...")

      If Empty(QRYSA2->A2_COD) // Foi identificado no cadastro de fornecedores alguns registros sem o código preenchido.
         QRYSA2->(DbSkip())
         Loop
      EndIf

      _cClassif := ""
      If QRYSA2->A2_L_CLASS == "U"
         _cClassif := "USUARIO TANQUE COLETIVO"
      Elseif QRYSA2->A2_L_CLASS == "F"
         _cClassif := "FAMILIAR"
      EndIf

      _cFazenda := AllTrim(STRTRAN(QRYSA2->A2_L_FAZEN,'"'," "))
      If _cFazenda == "--"
         _cFazenda := "SEM NOME"
      EndIf

      _cLinha := If(!_lLinhaUm,"," + CRLF ,"")
      _cLinha += '{ "matricula_laticinio" : "' + AllTrim(QRYSA2->A2_COD) + '",'
      _cLinha += ' "Loja_laticinio" : "' + AllTrim(QRYSA2->A2_LOJA) + '",'
      _cLinha += ' "nome_razao_social" : "' + AllTrim(QRYSA2-> A2_NOME)+ '",'
      _cLinha += ' "cpf_cnpj" : "' + AllTrim(QRYSA2->A2_CGC)+ '",'
      _cLinha += ' "nome_propriedade_rural" : "' + _cFazenda + '",'    // AllTrim(QRYSA2->A2_L_FAZEN)
      _cLinha += ' "classificacao_laticinio" : "' + AllTrim(_cClassif)+ '",'
      _cLinha += ' "nirf" : "' + AllTrim(QRYSA2->A2_L_NIRF) + '",'
      _cLinha += ' "sigsif" : "' + AllTrim(QRYSA2->A2_L_SIGSI)+ '",'
      _cLinha += ' "matricula_produtor_principal" : "' + AllTrim(QRYSA2->A2_L_TANQ)+ '",'
      _cLinha += ' "loja_produtor_principal" : "' + AllTrim(QRYSA2->A2_L_TANLJ)+ '",'
      _cLinha += ' "cpf_cnpj_produtor_principal" : "' + AllTrim(QRYSA2->CPFCNPJ) + '"} '

      _oFWriter:Write(_cLinha)

      QRYSA2->(DbSkip())

      _lLinhaUm := .F.

   EndDo

   _oFWriter:Write("]")

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32CM
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Função Principal que Gera arquivo Texto com informações dos produtores usuários de tanques coletivos e
                     produtores familiares, e seus vinculos com os produtores principais.
                     A geração dos dados é por filial.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32CM()
Local _nI
Local _aFilProc := {}

Begin Sequence

   //If ! U_ITMSG("Confirma a geração do arquivo TxT com os vinculos Produtores usuários tanques coletivos/familiares e os produtores principais?","Atenção" , , ,2, 2)
   //   Break
   //EndIf

   Aadd(_aFilProc, {"01","Corumbaiba"})        // CORUMBAIBA	   01
   Aadd(_aFilProc, {"04","Araguari"})          // ARAGUARI	   04
   Aadd(_aFilProc, {"23","Tapejara"})          // TAPEJARA	   23
   Aadd(_aFilProc, {"40","Tres Coracoes"})     // TRÊS CORAÇÕES 40
   Aadd(_aFilProc, {"24","Crissiumal"})        // CRISSIUMAL    24
   Aadd(_aFilProc, {"25","Girua"})             // GIRUÁ         25
   Aadd(_aFilProc, {"09","Ipora"})             // IPORÁ	      09
   Aadd(_aFilProc, {"02","Itapaci"})           // ITAPACI	      02
   Aadd(_aFilProc, {"10","Jaru"})              // JARU		      10
   Aadd(_aFilProc, {"11","Nova Mamore"})       // NOVA MAMORE	11
   Aadd(_aFilProc, {"20","Passo Fundo"})       // PASSO FUNDO	20
   Aadd(_aFilProc, {"06","Pontalina"})         // PONTALINA		06
   Aadd(_aFilProc, {"0B","Quirinopolis"})      // QUIRINÓPOLIS	0B
   Aadd(_aFilProc, {"93","Parana_Cascavel"})   // PARANA_CASCAVEL 93
//   Aadd(_aFilProc, {"0A","Unidade Rio Verde"}) // UNIDADE RIO VERDE		0A

   For _nI := 1 To Len(_aFilProc)
       Processa( {|| U_MGLT32TC(_aFilProc[_nI,1],_aFilProc[_nI,2]) } , 'Aguarde!' , 'Gravando arquivo TXT...' )
   Next

   U_ItMsg("Termino da gravação do arquivo TXT.", "Atenção" ,,1)

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32MP
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo TXT com os dados dos Produtores com mais de uma propriedade. Faz a leitura dos dados
                     por filial.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32MP()
Local _cQry
Local _aFilSA2 := {}
//Local _nI, _cFilEnvio

Private _nTotRegs := 0

Begin Sequence
   //==========================================================================
   // Gera arquivo TXT com os Dados dos Volumes coletados exclusivo par Jaru.
   //==========================================================================
   Aadd(_aFilSA2, { "01","CORUMBAIBA"})
   Aadd(_aFilSA2, { "04","ARAGUARI"})
   Aadd(_aFilSA2, { "23","TAPEJARA"})
   Aadd(_aFilSA2, { "40","TRES CORACOES"})
   Aadd(_aFilSA2, { "24","CRISSIUMAL"})
   Aadd(_aFilSA2, { "25","GIRUA"})
   Aadd(_aFilSA2, { "09","IPORA"})
   Aadd(_aFilSA2, { "02","ITAPACI"})
   Aadd(_aFilSA2, { "10","JARU"})
   Aadd(_aFilSA2, { "11","NOVA MAMORE"})
   Aadd(_aFilSA2, { "20","PASSO FUNDO"})
   Aadd(_aFilSA2, { "06","PONTALINA"})
   Aadd(_aFilSA2, { "0B","QUIRINOPOLIS"})
   Aadd(_aFilSA2, { "93","Parana_Cascavel"})
   Aadd(_aFilSA2, { "31","CONCEICAO_DO_ARAGUAIA"})
   Aadd(_aFilSA2, { "32","COUTO_DE_MAGALHAES"})

   //('01','04','23','40','24','25','09','02','10','11','20','06','0B')

// _cFilEnvio := _aFilSA2[_nI,1]


//   For _nI := 1 To Len(_aFilSA2)
       //================================================================================
       // Monta select de leitura de dados do cadastro de Produtores rurais.
       //================================================================================
//       _cFilEnvio := _aFilSA2[_nI,1]

       _cQry := " SELECT DISTINCT A2_COD, "
       _cQry += " A2_LOJA, "
       _cQry += " ZL3_FILIAL, "
       _cQry += " A2_CGC, "
       _cQry += " A2_NOME, "
       _cQry += " A2_L_ATIVO, "
       _cQry += " A2_DTNASC,  "
       _cQry += " A2_L_LI_RO, "
       _cQry += " ZL3_DESCRI, "
       _cQry += " A2_L_NFPRO, "
       _cQry += " A2_L_NATRA, "
       _cQry += " SA2.R_E_C_N_O_ AS NRREG "  // capacidade_refrigeracao: 307
       _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
       _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
       _cQry += " AND ZL3_COD = A2_L_LI_RO "
       //_cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' " // Cada filial/Cnpj Italac possui um Usuário e Senha. Ler do cadastro empresas Webservice. Enviar apenas as filias 01, 04, 23. 01=Corumbaiba/GO, 04=Araguari/MG, 23=Tapejara/RS
       _cQry += " AND ZL3_FILIAL IN ('01','04','23','40','24','25','09','02','10','11','20','06','0B','93') "
       _cQry += " AND A2_I_CLASS = 'P' "
       _cQry += " AND A2_MSBLQL = '2' "
       _cQry += " AND A2_COD <> '      ' "
       _cQry += " ORDER BY A2_COD,A2_LOJA "

       If Select("QRYSA2") > 0
          QRYSA2->(DbCloseArea())
       EndIf


       MPSysOpenQuery( _cQry , "QRYSA2")

       TCSetField('QRYSA2',"A2_DTNASC","D",8,0)

       QRYSA2->(DbGotop())

       DBSelectArea("QRYSA2")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
       Count to _nTotRegs

       QRYSA2->(DbGotop())

       Processa( {|| U_MGLT32MI(_aFilSA2,_nTotRegs) } , 'Aguarde!' , 'Gravando Arquivo Texto dos Produtores...' )

   //Next

   U_ItMsg("Geração de arquivo TXT com os dados Produtores com mais de uma propriedade concluido.","Atenção",,2)

End Sequence

If Select("QRYSA2") > 0
   QRYSA2->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32MI
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de geração de arquivo TxT dos Produtores com mais de uma propriedade para envio a Evomilk.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32MI(_aFilSA2,_nTotRegs)
Local _cDados
Local _nI, _nJ

Begin Sequence

   ProcRegua(_nTotRegs)

   _cDirTXT := GetTempPath() // "\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
   //_cNomeArq:= "Produtores_Mais_de_uma_propriedade_" + AllTrim(_cNomeFil) + "_" + Dtos(Date()) + ".Txt"
   _cNomeArq:= "Produtores_Mais_de_uma_propriedade_" + Dtos(Date()) + ".Txt"

   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados dos produtores com mais de uma propriedade.","Atenção",,1)
      Break
   EndIf

   _oFWriter:Write("UNIDADE;MATRICULA;CPF;NOME;DT_NASC_PROPRIEDADE;LINHA_ROTA;NOME_LINHA_ROTA;TIPO_DE_PROPRIEDADE;NOME_COOPERADO;STATUS;" + CRLF)

   QRYSA2->(DbGoTop())

   _nJ := 1

   Do While ! QRYSA2->(Eof())

      //IncProc("Gerando arquivo texto: "+ AllTrim(QRYSA2->A2_COD + "-" + QRYSA2->A2_LOJA) + "...")
      IncProc("Gerando arquivo texto: "+ StrZero(_nJ,6) + " de " + StrZero(_nTotRegs,6) + "...")
      _nJ += 1

      //=============================================================================
      // Verifica se o Produtor possui mais de uma propriedade e envia apenas os
      // que possuirem mais de uma propriedade.
      //=============================================================================
      If ! U_MGLT032Z(QRYSA2->A2_COD)
         QRYSA2->(DbSkip())
         Loop
      EndIf

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================
      _nI := AsCan(_aFilSA2,{|x| x[1] == QRYSA2->ZL3_FILIAL})
      _cDados := _aFilSA2[_nI,2] + ";" // AllTrim(_cNomeFil)+";"
      _cDados += QRYSA2->A2_COD + "-" + QRYSA2->A2_LOJA+";"
      _cDados += AllTrim(QRYSA2->A2_CGC) +";"
      _cDados += AllTrim(QRYSA2->A2_NOME) + ";"
      _cDados += StrZero(Year(QRYSA2->A2_DTNASC),4)+"-"+StrZero(Month(QRYSA2->A2_DTNASC),2)+"-"+StrZero(Day(QRYSA2->A2_DTNASC),2)+";"
      _cDados += AllTrim(QRYSA2->A2_L_LI_RO) + ";"
      _cDados += AllTrim(QRYSA2->ZL3_DESCRI) + ";"

      If QRYSA2->A2_L_NFPRO == 'S' .And. !Empty(QRYSA2->A2_L_NATRA)
         _cDados += "ASSOCIAÇÃO/COOPPERATIVA;"
         _cDados += Alltrim(QRYSA2->A2_L_NATRA)+";"
      Else
         _cDados += "NORMAL;"
         _cDados += Alltrim(QRYSA2->A2_NOME)+";"
      EndIf

      If QRYSA2->A2_L_ATIVO == "N"
         _cDados += "INATIVO;"
      Else
         _cDados += "ATIVO;"
      EndIf

      _cDados += CRLF

      _oFWriter:Write(_cDados)

      QRYSA2->(DbSkip())
   EndDo

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32RJ
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera Listagem de Produteres rejeitados na integração.
===============================================================================================================================
Parametros--------:  _dDataRj = Data de Rejeição para geração do arquivo
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32RJ(_dDataRj,_dDtFimRej)
Local _nI, _nJ
Local _cQry
Local _oFWriter
Local _aFilProc := {}
Local _cLinha, _cJsonRet, _cJsonEnv
Local _cEnvCiaL, _cIntCol, _cEnvAlt

Begin Sequence

   ProcRegua(15)

   Aadd(_aFilProc, {"01","Corumbaiba"})      // CORUMBAIBA	   01
   //Aadd(_aFilProc, {"04","Araguari"})        // ARAGUARI	   04
   //Aadd(_aFilProc, {"23","Tapejara"})        // TAPEJARA	   23
   //Aadd(_aFilProc, {"40","Tres Coracoes"})   // TRÊS CORAÇÕES 40
   //Aadd(_aFilProc, {"24","Crissiumal"})      // CRISSIUMAL    24
   //Aadd(_aFilProc, {"25","Girua"})           // GIRUÁ         25
   //Aadd(_aFilProc, {"09","Ipora"})           // IPORÁ	      09
   //Aadd(_aFilProc, {"02","Itapaci"})         // ITAPACI	      02
   //Aadd(_aFilProc, {"10","Jaru"})            // JARU		      10
   //Aadd(_aFilProc, {"11","Nova Mamore"})     // NOVA MAMORE	11
   //Aadd(_aFilProc, {"20","Passo Fundo"})     // PASSO FUNDO	20
   //Aadd(_aFilProc, {"06","Pontalina"})       // PONTALINA		06
   //Aadd(_aFilProc, {"0B","Quirinopolis"})    // QUIRINÓPOLIS	0B
   //Aadd(_aFilProc, {"93","Parana_Cascavel"}) // PARANA_CASCAVEL 93
   //Aadd(_aFilProc, {"31","Conceicao_do_Araguaia"}) // CONCEICAO_DO_ARAGUAI 31
   //Aadd(_aFilProc, {"32","Couto_de_Magalhaes"})    // COUTO DE MAGALHAES 32

   For _nI := 1 To Len(_aFilProc)

       IncProc("Gerando arquivo texto da Unidade: " + AllTrim(_aFilProc[_nI,2]))

       _cDirTXT := GetTempPath()
       //_cNomeArq:= "Produtores_Rejeitados_na_Integracao_Unidade_" + _aFilProc[_nI,2] + "_Data_" + Dtos(_dDataRj) + ".Txt"
       _cNomeArq:= "Produtores_Rejeitados_na_Integracao_Unidade_" + _aFilProc[_nI,2] + "_Data_" + Dtos(_dDataRj) + ".csv"

       _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

       If ! _oFWriter:Create()
          U_ItMsg("Erro na criação do arquivo texto para gravação dos dados dos produtores rejeitados na integração.","Atenção",,1)
          Break
       EndIf

       _cQry := " SELECT DISTINCT ZBH.R_E_C_N_O_ AS NRREG, A2_L_ENVEV, A2_L_ENVAT, A2_L_ITCOL "
       _cQry += " FROM " + RetSqlName("ZBH") + " ZBH, " + RetSqlName("SA2") + " SA2 "
       _cQry += " WHERE ZBH.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
       _cQry += " AND ZBH.ZBH_FILIAL = '"+ _aFilProc[_nI,1] + "' "

       IF TYPE("_cFiltroSQL") = "C" .AND. !EMPTY(_cFiltroSQL)
          _cQry += _cFiltroSQL
       ENDIF

       If ! Empty(_dDataRj)
          _cQry += " AND ZBH.ZBH_DTENV  >= '" + Dtos(_dDataRj) + "' "
       EndIf

       If ! Empty(_dDtFimRej)
          _cQry += " AND ZBH.ZBH_DTENV  <= '" + Dtos(_dDtFimRej) + "' "
       EndIf

       _cQry += " AND ZBH.ZBH_STATUS = 'R' "
       _cQry += " AND ZBH.ZBH_CODPRO = SA2.A2_COD "
       _cQry += " AND ZBH.ZBH_LOJPRO = SA2.A2_LOJA "

       If Select("QRYZBH") > 0
          QRYZBH->(DbCloseArea())
       EndIf

       MPSysOpenQuery( _cQry , "QRYZBH")

       DBSelectArea("QRYZBH")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
       Count To _nTotRegs

       QRYZBH->(DbGoTop())

       ProcRegua(_nTotRegs)

       _oFWriter:Write("CODIGO PRODUTOR;LOJA;NOME;ENVIA_CIA_LEITE;INTEGRA_COLETA;ENVIA_ALTERACAO_CIA_LEITE;JSON RETORNO;JSON ENVIO" + CRLF)//

       _nJ := 1
       Do While ! QRYZBH->(Eof())
          IncProc("Gerando arquivo texto: "+ StrZero(_nJ,6) + " de " + StrZero(_nTotRegs,6) + "...")
          _nJ += 1

          ZBH->(DbGoto(QRYZBH->NRREG))

          _cJsonRet := StrTran(ZBH->ZBH_MOTIVO,CRLF,"")
          _cJsonRet := StrTran(_cJsonRet,chr(10),"")
          //_cJsonRet := StrTran(_cJsonRet," ","")

          _cJsonEnv := StrTran(ZBH->ZBH_JSONEN,CRLF,"")
          _cJsonEnv := StrTran(_cJsonEnv,chr(10),"")
          //_cJsonEnv := StrTran(_cJsonEnv," ","")

          _cEnvCiaL := " "
          _cIntCol  := " "
          _cEnvAlt  := " "

          If QRYZBH->A2_L_ENVEV == "S"
             _cEnvCiaL := "SIM"
          ElseIf QRYZBH->A2_L_ENVEV == "N"
             _cEnvCiaL := "NAO"
          EndIf

          If QRYZBH->A2_L_ITCOL == "S"
             _cIntCol  := "SIM"
          ElseIf QRYZBH->A2_L_ITCOL == "N"
             _cIntCol  := "NAO"
          EndIf

          If QRYZBH->A2_L_ENVAT == "S"
             _cEnvAlt  := "SIM"
          ElseIf QRYZBH->A2_L_ENVAT == "N"
             _cEnvAlt  := "NAO"
          EndIf

          IF (_cPosJ:=AT('"message_error": [',_cJsonRet)) > 0
             _cJsonRet:=SubStr(_cJsonRet,AT('"message_error": [',_cJsonRet)+17)
             IF (_cPosJ:=AT(']',_cJsonRet)) > 0
                _cJsonRet:=SubStr(_cJsonRet,1,_cPosJ)
             EndIf
          ENDIF

          _cLinha   := ZBH->ZBH_CODPRO+ ";" + ZBH->ZBH_LOJPRO + ";" + AllTrim(ZBH->ZBH_NOMPRO) + ";" + _cEnvCiaL + ";" + _cIntCol + ";" + _cEnvAlt + ";" + _cJsonRet + ";" + _cJsonEnv + CRLF + CRLF
          _oFWriter:Write(_cLinha)

          QRYZBH->(DbSkip())

       EndDo

       //Encerra o arquivo
       _oFWriter:Close()

   Next

End Sequence

If Select("QRYZBH") > 0
   QRYZBH->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32AC
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera Listagem de Produteres rejeitados na integração.
===============================================================================================================================
Parametros--------:  _dDataAc = Data de Aceitação para geração do arquivo
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32AC(_dDataAc, _dDtFimAce)
Local _nI, _nJ
Local _cQry
Local _oFWriter
Local _aFilProc := {}
Local _cLinha, _cJsonRet, _cJsonEnv
Local _cEnvCiaL, _cIntCol, _cEnvAlt

Begin Sequence

   ProcRegua(15)

   Aadd(_aFilProc, {"01","Corumbaiba"})      // CORUMBAIBA	   01
   //Aadd(_aFilProc, {"04","Araguari"})        // ARAGUARI	   04
   //Aadd(_aFilProc, {"23","Tapejara"})        // TAPEJARA	   23
   //Aadd(_aFilProc, {"40","Tres Coracoes"})   // TRÊS CORAÇÕES 40
   //Aadd(_aFilProc, {"24","Crissiumal"})      // CRISSIUMAL    24
   //Aadd(_aFilProc, {"25","Girua"})           // GIRUÁ         25
   //Aadd(_aFilProc, {"09","Ipora"})           // IPORÁ	      09
   //Aadd(_aFilProc, {"02","Itapaci"})         // ITAPACI	      02
   //Aadd(_aFilProc, {"10","Jaru"})            // JARU		      10
   //Aadd(_aFilProc, {"11","Nova Mamore"})     // NOVA MAMORE	11
   //Aadd(_aFilProc, {"20","Passo Fundo"})     // PASSO FUNDO	20
   //Aadd(_aFilProc, {"06","Pontalina"})       // PONTALINA		06
   //Aadd(_aFilProc, {"0B","Quirinopolis"})    // QUIRINÓPOLIS	0B
   //Aadd(_aFilProc, {"93","Parana_Cascavel"}) // PARANA_CASCAVEL 93
   //Aadd(_aFilProc, {"31","Conceicao_do_Araguaia"}) // CONCEICAO_DO_ARAGUAI 31
   //Aadd(_aFilProc, {"32","Couto_de_Magalhaes"})  // COUTO DE MAGALHAES 32

   For _nI := 1 To Len(_aFilProc)

       IncProc("Gerando arquivo texto da Unidade: " + AllTrim(_aFilProc[_nI,2]))

       _cDirTXT := GetTempPath()
       //_cNomeArq:= "Produtores_Aceitos_na_Integracao_Unidade_" + _aFilProc[_nI,2] + "_Data_" + Dtos(_dDataAc) + ".Txt"
       _cNomeArq:= "Produtores_Aceitos_na_Integracao_Unidade_" + _aFilProc[_nI,2] + "_Data_" + Dtos(_dDataAc) + ".csv"

       _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

       If ! _oFWriter:Create()
          U_ItMsg("Erro na criação do arquivo texto para gravação dos dados dos produtores aceitos na integração.","Atenção",,1)
          Break
       EndIf

       _cQry := " SELECT DISTINCT ZBH.R_E_C_N_O_ AS NRREG, A2_L_ENVEV, A2_L_ENVAT, A2_L_ITCOL "
       _cQry += " FROM " + RetSqlName("ZBH") + " ZBH, " + RetSqlName("SA2") + " SA2 "
       _cQry += " WHERE ZBH.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' ' "
       _cQry += " AND ZBH.ZBH_FILIAL = '"+ _aFilProc[_nI,1] + "' "

       IF TYPE("_cFiltroSQL") = "C" .AND. !EMPTY(_cFiltroSQL)
          _cQry += _cFiltroSQL
       ENDIF

       If ! Empty(_dDataAc)
          _cQry += " AND ZBH.ZBH_DTENV  >= '" + Dtos(_dDataAc) + "' "
       EndIf

       If ! Empty(_dDtFimAce)
          _cQry += " AND ZBH.ZBH_DTENV  <= '" + Dtos(_dDtFimAce) + "' "
       EndIf

       _cQry += " AND ZBH.ZBH_STATUS = 'A' "
       _cQry += " AND ZBH.ZBH_CODPRO = SA2.A2_COD "
       _cQry += " AND ZBH.ZBH_LOJPRO = SA2.A2_LOJA "

       If Select("QRYZBH") > 0
          QRYZBH->(DbCloseArea())
       EndIf

       MPSysOpenQuery( _cQry , "QRYZBH")

       DBSelectArea("QRYZBH")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
       Count To _nTotRegs

       QRYZBH->(DbGoTop())

       ProcRegua(_nTotRegs)

       _oFWriter:Write("CODIGO PRODUTOR;LOJA;NOME;ENVIA_CIA_LEITE;INTEGRA_COLETA;ENVIA_ALTERACAO_CIA_LEITE;JSON RETORNO;JSON ENVIO" + CRLF)

       _nJ := 1
       Do While ! QRYZBH->(Eof())
          IncProc("Gerando arquivo texto: "+ StrZero(_nJ,6) + " de " + StrZero(_nTotRegs,6) + "...")
          _nJ += 1

          ZBH->(DbGoto(QRYZBH->NRREG))

          _cJsonRet := StrTran(ZBH->ZBH_MOTIVO,CRLF," ")
          _cJsonRet := StrTran(_cJsonRet,chr(10)," ")
          //_cJsonRet := StrTran(_cJsonRet,";",",")

          _cJsonEnv := StrTran(ZBH->ZBH_JSONEN,CRLF," ")
          _cJsonEnv := StrTran(_cJsonEnv,chr(10),"")
          //_cJsonEnv := StrTran(_cJsonEnv,";",",")

          _cEnvCiaL := " "
          _cIntCol  := " "
          _cEnvAlt  := " "

          If QRYZBH->A2_L_ENVEV == "S"
             _cEnvCiaL := "SIM"
          ElseIf QRYZBH->A2_L_ENVEV == "N"
             _cEnvCiaL := "NAO"
          EndIf

          If QRYZBH->A2_L_ITCOL == "S"
             _cIntCol  := "SIM"
          ElseIf QRYZBH->A2_L_ITCOL == "N"
             _cIntCol  := "NAO"
          EndIf

          If QRYZBH->A2_L_ENVAT == "S"
             _cEnvAlt  := "SIM"
          ElseIf QRYZBH->A2_L_ENVAT == "N"
             _cEnvAlt  := "NAO"
          EndIf

          _cLinha   := ZBH->ZBH_CODPRO+ ";" + ZBH->ZBH_LOJPRO + ";" + AllTrim(ZBH->ZBH_NOMPRO) + ";" + _cEnvCiaL + ";" + _cIntCol + ";" + _cEnvAlt + ";" + _cJsonRet+";" + _cJsonEnv + CRLF
          _oFWriter:Write(_cLinha)

          QRYZBH->(DbSkip())

       EndDo

       //Encerra o arquivo
       _oFWriter:Close()

   Next

End Sequence

If Select("QRYZBH") > 0
   QRYZBH->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT032K
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Envio de dados dos Produtores Rurais de Associação ou Cooperativas via WebService
                     Italac para Sistema Evomilk
===============================================================================================================================
Parametros--------: _cChamada = "M" = Rotina Chamada via menu.
                                "S" = Rotina Chamada via Scheduller
                    _cOpcao   = "INCASS" = Roda a integração de Inclusão de produtores Associação/Cooperativa no App Cia leite.

===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT032K(_cChamada,_cOpcao)
Local _cRodaPe // , _cCabec, _cDetalhe, _cAssociac
Local _cItens //, _cEnvio
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cJSonProd, _cJSonGrp
Local _cHoraIni, _cHoraFin, _cMinutos, _nMinutos
//Local _nTotRegEnv := 1 // 100  // Total de registros para envio.
//Local _nI , _oRetJSon, _lResult := .F.
Local _aProdEnv
Local _aHeadOut := {}
//Local _aRecnoSA2, _cRetorno, _nX
Local _cClasParc
Local _cLinkAss
Local _cLinkSoc
Local _nI
Local _aCabMail, _cCabMail, _cCabJson, _nY
Local _aDetMail, _cDetMail, _cDetJson
Local _cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")

//------------------------------------------------------------------------------------------//
            // Cabeçalho
Private _cIdProdut := ""
Private _cMatLatic := ""   //            matricula_laticinio
Private _cRazaoSoc := ""   //            nome_razao_social
Private _cCpf_Cnpj := ""   //            cpf_cnpj
Private _cInscrEst := ""   //            inscricao_estadual
Private _cRg_IE    := ""   //            rg_ie
Private _cDtNascF  := ""   //            data_nascimento_fundacao
Private _cObserv   := ""   //            info_adicional
Private _cComplem  := ""   //            complemento
Private _cEndereco := ""   //            endereco
Private _cNrEnd    := ""   //            numero
Private _cBairro   := ""   //            bairro
Private _cCep      := ""   //            cep
Private _cIdUF     := ""   //            id_uf
Private _cIDCidade := ""   //            id_cidade
//--------------------------------------------------------------------//
Private _cCodBanco := ""   //            Codigo do Banco
Private _cCodAgenc := ""   //            Codigo da Agencia
Private _cNumConta := ""   //            Numero da Conta
//--------------------------------------------------------------------//
Private _cEMail    := ""   //            email
Private _cCelular  := ""   //            celular1
Private _cCelula2  := ""   //            celular2
Private _cTelefon1 := ""   //            telefone1
Private _cTelefon2 := ""   //            telefone2
Private _cWhatsAp1 := ""   //            celular1_whatsapp
Private _cWhatsAp2 := ""   //            celular2_whatsapp

            // Detalhe
Private _cNomeProp  := ""  //           nome_propriedade_rural
Private _cNIRF      := ""  //           NIRF
Private _cTipoTanq  := ""  //           id_tipo_tanque
Private _cCapacTnq  := ""  //           capacidade_tanque
Private _cLatitude  := ""  //           latitude_propriedade
Private _cLongitud  := ""  //           longitude_propriedade
Private _cArea      := ""  //           area
Private _cRecria    := ""  //           recria
Private _cVacaSeca  := ""  //           vaca_seca
Private _cVacaLacta := ""  //           vaca_lactacao
Private _cHoraCole  := ""  //           horario_coleta
Private _cRacaProp  := ""  //           raca_propriedade
Private _cFreqCol   := ""  //           frequencia_coleta
Private _cProdDia   := ""  //           producao_media_diaria
Private _cAreaUti   := ""  //           area_utilizada_producao
Private _cCapacRef  := ""  //           capacidade_refrigeracao
Private _cCodPropr  := ""  //           codigo_propriedade_laticinio
Private _cCodLinha  := ""  //           codigo_linha_laticinio
Private _cDescLin   := ""  //           nome_linha

//-------------------------------------------------------------------//
Private _cSituacao  := ""
Private _cCidade    := ""
Private _cUF        := ""
Private _cCod_Ibge  := ""
Private _cSigSif   := ""
Private _cCodPropL := ""
Private _cCodigotq := ""
Private _cTipoResf := ""
Private _cMarcaTanq:= ""

Private _cCPFCnpjP := ""
Private _cMatParce := ""

//=========================================================================
// Nova Tags
//=========================================================================
Private _cTitTanq  := ""    // cpf_cnpj
Private _cMatrLat  := ""    // matricula_laticinio
Private _cTelPrinc := "SIM" // telefone_principal
Private _cEMailPri := "SIM" // email_principal
Private _cSitTnq   := ""    // situacao
Private _CSITPROP  := ""    // Situação Proprietario
Private _CCLASPROP := ""    // Classificação Proprietári do Tanque
Private _CNOMETNQ  := ""    // Nome do Tanque
Private _cNomBanco := ""    // Nome do Banco
Private _cTitConta := ""
Private _cInfoAdic := ""
Private _CDataCad  := ""
Private _cHoraCad  := ""
//---------------------------------------------------------
Private _cComplemD := ""   //            complemento
Private _cEnderecD := ""   //            endereco
Private _cNrEndD   := ""   //            numero
Private _cBairroD  := ""   //            bairro
Private _cCepD     := ""   //            cep
Private _cIdUFD    := ""   //            id_uf
Private _cIDCidadD := ""   //            id_cidade
Private _cEMailD   := ""   //            email 2
Private _cTelefonD := ""   //            Telefone demais propriedades
//---------------------------------------------------------
Private _oFWRITER
//---------------------------------------------------------
Private _cVincLat           // Código do Laticinio Associação/Cooperativa ao qual o Cooperado pertence.
//---------------------------------------------------------
Private _cTipoLat   := "ASSOCIACAO"
Private _aRecnoSA2  := {}

//Private _cNomeResp  := ""
//Private _cTelResp   := ""
//Private _cEmailRes  := ""
//Private _cNomeRpol  := ""
//Private _cTelRpol   := ""
//Private _cEmailRpol := ""

Private _cNomRespL := ""
Private _cTelRespL := ""
Private _cEmaRespL := ""

Private _cNomRespP := ""
Private _cTelRespP := ""
Private _cEmaRespP := ""

//---------------------------------------------------------

Default _cChamada := "M"
Default _cOpcao   := "I"

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _LinkCerto := AllTrim(ZFM->ZFM_HOMEPG)
      If _cOpcao == "INCASS"
         _cLinkAss := AllTrim(ZFM->ZFM_LINK05)  // Link de envio de inclusão de Associação / Cooperativa
         _cLinkSoc := AllTrim(ZFM->ZFM_LINK06)  // Link de envio de inclusão de Associados / Cooperados
      Else
         _cLinkAss := AllTrim(ZFM->ZFM_LINK05)  // Link de envio de alteração de Associação / Cooperativas
         _cLinkSoc := AllTrim(ZFM->ZFM_LINK06)  // Link de envio de alteração de Associados / Cooperados
      EndIf
      IF !EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   If Empty(_cDirJSon)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON Associação/Cooperativa e os transforma em String.
   //================================================================================

   _cAssoc_A := U_MGLT032X(_cDirJSon+"ASSOCIACAO_COOPERATIVA_CIA_LEITE_PRODUTOR_A.txt")
   If Empty(_cAssoc_A)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (A) associação/cooperativa integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cAssoc_B:= U_MGLT032X(_cDirJSon+"ASSOCIACAO_COOPERATIVA_CIA_LEITE_PRODUTOR_B.txt")
   If Empty(_cAssoc_B)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (B) associação/cooperativa integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cAssoc_C := U_MGLT032X(_cDirJSon+"ASSOCIACAO_COOPERATIVA_CIA_LEITE_PRODUTOR_C.txt")
   If Empty(_cAssoc_C)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (C) associação/cooperativa integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON Associado/Cooperado e os transforma em String.
   //================================================================================
   _cCabec_A := U_MGLT032X(_cDirJSon+"Cabec_CIA_LEITE_PRODUTOR_ASSOCIADO_A.txt")
   If Empty(_cCabec_A)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (A) associado/cooperado integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cCabec_B := U_MGLT032X(_cDirJSon+"Cabec_CIA_LEITE_PRODUTOR_ASSOCIADO_B.txt")
   If Empty(_cCabec_B)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (B) associado/cooperado integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cCabec_C := U_MGLT032X(_cDirJSon+"Cabec_CIA_LEITE_PRODUTOR_ASSOCIADO_C.txt")
   If Empty(_cCabec_C)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (C) associado/cooperado integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDetalheA := U_MGLT032X(_cDirJSon+"Detalhe_CIA_LEITE_PRODUTOR_ASSOCIADO_A.txt")

   If Empty(_cDetalheA)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON detalhe (A) Propriedades produtor rural associado/cooperado.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDetalheB := U_MGLT032X(_cDirJSon+"Detalhe_CIA_LEITE_PRODUTOR_ASSOCIADO_B.txt")

   If Empty(_cDetalheB)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON detalhe (B) Propriedades produtor rural associado/cooperado.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDetalheC := U_MGLT032X(_cDirJSon+"Detalhe_CIA_LEITE_PRODUTOR_ASSOCIADO_C.txt")

   If Empty(_cDetalheC)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON detalhe (C) Propriedades produtor rural associado/cooperado.","Atenção",,1)
      EndIf

      Break
   EndIf

//----------------------------------------------------------------------------//
   _cRodape := U_MGLT032X(_cDirJSon+"Rodape_CIA_LEITE_PRODUTOR_ASSOCIADO.txt")
   If Empty(_cRodape)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Rodape Produtor Rural associado/cooperado Integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   //==========================================================
   // Obtem o Token de Integração com a Evomilk
   //==========================================================
   _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

   If Empty(_cKey)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores Associação/Cooperativa cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   _cHoraIni := Time() // Horario Inicial de Processamento

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

//-----------------------------------------------------------------
   //_cLinkWS := 'https://app-cdl-int-hml.azurewebsites.net/public/v1/produtores/'
//-----------------------------------------------------------------

   _cJSonProd := "["
   _cJSonGrp := ""
   _nI := 1

   //U_MGLT032G("","","",.T., .F.) // Abre arquivo // Grava Arquivo Texto com os retornos de erro/rejeições.

   _aProdEnv := {}

   TRBCAB->(DbSetOrder(3)) // {"WK_ORDEMP","A2_COD","A2_LOJA"}
   TRBDET->(DbSetOrder(1))

   TRBCAB->(DbGoTop())
   Do While ! TRBCAB->(Eof())
      //====================================================================
      // Calcula o tempo decorrido para obtenção de um novo Token
      //====================================================================
      _cHoraFin := Time()
      _cMinutos := ElapTime (_cHoraIni , _cHoraFin)
      _nMinutos := Val(SubStr(_cMinutos,4,2))
      If _nMinutos > 5 // 28 //  minutos
         _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

         If Empty(_cKey)
            If _cChamada == "M" // Chamada via menu.
               U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores Associação/Cooperativa cancelada.","Atenção",,1)
            EndIf

            Break
         EndIf

         _aHeadOut := {}
         Aadd(_aHeadOut,'Accept: application/json')
         Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
         Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

         _cHoraIni := Time()

      EndIf

      //====================================================================
      // Efetua a leitura dos dados para montagem do JSON.
      //====================================================================
      _cItens := ""
      _cIdProdut := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA
      _cMatLatic := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA          //            matricula_laticinio
      _cRazaoSoc := TRBCAB->A2_NOME                             //            nome_razao_social
      _cCpf_Cnpj := TRBCAB->A2_CGC                              //            cpf_cnpj
      _cInscrEst := TRBCAB->A2_INSCR                            //            inscricao_estadual
      _cRg_IE    := TRBCAB->A2_PFISICA                          //            rg_ie
      _cDtNascF  := StrZero(Year(TRBCAB->A2_DTNASC),4)+"-"+StrZero(Month(TRBCAB->A2_DTNASC),2)+"-"+StrZero(Day(TRBCAB->A2_DTNASC),2)   //            data_nascimento_fundacao
      _cObserv   := ""                                          //            info_adicional
      _cComplem  := TRBCAB->A2_ENDCOMP                          //            complemento
      _cEndereco := TRBCAB->A2_END                              //            endereco
      _cNrEnd    := ""                                          //            numero
      _cBairro   := TRBCAB->A2_BAIRRO                           //            bairro
      _cCep      := TRBCAB->A2_CEP                              //            cep
      _cIdUF     := ""                                          //            id_uf
      _cIDCidade := ""                                          //            id_cidade
      _cCidade   := AllTrim(TRBCAB->A2_MUN)                     //            municipio
      _cUF       := AllTrim(TRBCAB->A2_EST)                     //            estado
      _cCod_Ibge := TRBCAB->A2_COD_MUN                          //            codigo_ibge"
//---------------------------------------------------------------------------------------------------
      _cCodBanco := AllTrim(TRBCAB->A2_BANCO)                   //            Codigo do Banco
      _cCodAgenc := AllTrim(TRBCAB->A2_AGENCIA)                 //            Codigo da Agencia
      _cNumConta := AllTrim(TRBCAB->A2_NUMCON)                  //            Numero da Conta
      _cNomBanco := AllTrim(POSICIONE('SA6',1,xFilial('SA6')+_cCodBanco,'A6_NOME'))
      _cTitConta := TRBCAB->A2_NOME
      _cInfoAdic := ""
//---------------------------------------------------------------------------------------------------
      _cEMail    := TRBCAB->A2_EMAIL            //            email
      _cCelular  := ""                          //            celular1
      _cCelula2  := ""                          //            celular2
      _cTelefon1 := TRBCAB->A2_TEL              //            telefone1

      If Empty(_cTelefon1)
         _cTelefon1 := "null"
      Else
         _cTelefon1 := '"' +AllTrim(_cTelefon1)  + '"'
      EndIf

      _cTelefon2 := ""                          //            telefone2
      //_cWhatsAp1 := "SIM"                       //            celular1_whatsapp
      _cWhatsAp1 := "NAO"                     //            celular2_whatsapp

      //_cVincLat  := "" // TRBCAB->A2_CGC              // Código da Associação/Cooperativa ao qual o cooperado pertence.
      //===========================================================
      // Define o CNPJ da unidade para a tag vinculado_ao_laticinio
      //===========================================================
      _cVincLat  := _cUnidVinc // Unidade na qual os produtores e coletas estão vinculados // SM0->M0_CGC
      //-----------------------------------------------------------

      _cNomRespL := TRBCAB->A2_NOME
      _cTelRespL := TRBCAB->A2_TEL
      _cEmaRespL := TRBCAB->A2_EMAIL
      _cTipoLat  := "ASSOCIACAO"
      _cSituacao := TRBCAB->A2_L_ATIVO
      _aRecnoSA2  := {}  // Array com os dados para atualização do cadastro de produtores como já enviados.

      //=======================================================================================
      // Este trecho trata os varios e-mails de um campo e envia um a um em campos diferentes.
      //=======================================================================================
      _cEMail := AllTrim(StrTran(_cEMail,",",";"))
      _aCabMail  := U_ITTXTARRAY(_cEMail,";",10)

      _cCabMail := ""
      _cCabJson := ""
      _cEMailPri := "SIM"

      If Len(_aCabMail) > 0
         For _nY := 1 To Len(_aCabMail)
             _cEMail   := StrTran(_aCabMail[_nY],";","")
             _cCabJson := &(_cAssoc_B)
             _cCabMail += If(!Empty(_cCabMail),",","") + _cCabJson
             _cEMailPri := "NAO"
         Next
      Else
         _cCabJson := &(_cAssoc_B)
         _cCabMail += If(!Empty(_cCabMail),",","") + _cCabJson
      EndIf

      //=================================================================
      // Integra para a Evomilk o JSon da Associação / Cooperativa
      //=================================================================
      _cJSonEnv := &(_cAssoc_A) + _cCabMail + &(_cAssoc_C)
      //_cJSonGrp += If(!Empty(_cJSonGrp),",","") + _cJSonEnv

      If _cOpcao == "REENVASS"
         If ! MGLT32ENVA(_cJSonEnv, _cLinkAss ,_aHeadOut , TRBCAB->WK_RECNO,"A")
            TRBCAB->(DbSkip()) // Não foi possível incluir o primeiro registro. A Associação / cooperativa.
            Loop // Portanto, os associados/cooperados também não poderão ser incluidos. Deve-se seguir a sequencia.
         EndIf

      ElseIf ! _lJaTemAss
         If ! MGLT32ENVA(_cJSonEnv, _cLinkAss ,_aHeadOut , TRBCAB->WK_RECNO,"A")
            TRBCAB->(DbSkip()) // Não foi possível incluir o primeiro registro. A Associação / cooperativa.
            Loop // Portanto, os associados/cooperados também não poderão ser incluidos. Deve-se seguir a sequencia.
         EndIf

      EndIf

      //=================================================================
      // Integra para a Evomilk os JSon dos Associcados / Cooperados
      //=================================================================
      _cVincLat  := TRBCAB->A2_CGC     // Código da Associação/Cooperativa ao qual o cooperado pertence.
      _cTipoLat   := "ASSOCIACAO"

      TRBDET->(MsSeek(TRBCAB->A2_COD))

      Do While ! TRBDET->(Eof()) .And. TRBCAB->A2_COD == TRBDET->A2_COD

         If AllTrim(TRBDET->WK_TIPOPRO) == "ASSOCIACAO"
            TRBDET->(DbSkip())
            Loop
         EndIf

         //=======================================================================================
         // Este trecho trata os varios e-mails de um campo e envia um a um em campos diferentes.
         //=======================================================================================
         _cEMail := AllTrim(StrTran(_cEMail,",",";"))
         _aCabMail  := U_ITTXTARRAY(_cEMail,";",10)

         _cCabMail := ""
         _cCabJson := ""
         _cEMailPri := "SIM"

         If Len(_aCabMail) > 0
            For _nY := 1 To Len(_aCabMail)
                _cEMail   := StrTran(_aCabMail[_nY],";","")
                _cCabJson := &(_cCabec_B)
                _cCabMail += If(!Empty(_cCabMail),",","") + _cCabJson
                _cEMailPri := "NAO"
            Next
         Else
            _cCabJson := &(_cCabec_B)
            _cCabMail += If(!Empty(_cCabMail),",","") + _cCabJson
         EndIf
//--------------------------------------------------

         _cCodPropr  := ""                                    //           codigo_propriedade_laticinio
         _cNomeProp  := TRBDET->A2_L_FAZEN                    //           nome_propriedade_rural
         _cNIRF      := TRBDET->A2_L_NIRF                     //           NIRF
         //_cTipoTanq  := ""                                  //           id_tipo_tanque  // A2_L_TANQ // tipo_tanque // A2_L_MARTQ

         _cCodPropL  := TRBDET->A2_COD+"-"+TRBDET->A2_LOJA
         _cMatLatic  := TRBDET->A2_COD+"-"+TRBDET->A2_LOJA    // TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA//            matricula_laticinio

         _cTipoTanq  := "INDIVIDUAL"
         _CCLASPROP  := "PRODUTOR INDIVIDUAL"

         _cMatrLat   := ""
         _cTitTanq   := ""
         //_cMatrLat   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         //_cTitTanq   := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // // CPF_CNPJ do Titular do Tanque
         _cMatParce  := ""
         _cCPFCnpjP  := ""
         _cCidade    := AllTrim(TRBDET->A2_MUN)   // municipio
         _cUF        := AllTrim(TRBDET->A2_EST)   // estado

         If TRBDET->A2_L_CLASS == "C"
            _cTipoTanq  := "COLETIVO"
            _CCLASPROP  := "TITULAR DE TANQUE COMUNITARIO"
         ElseIf TRBDET->A2_L_CLASS == "U"
            _CCLASPROP  := "USUARIO DE TANQUE COMUNITARIO"
            _cTipoTanq  := "COLETIVO"
            //_cMatrLat   := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // // CPF_CNPJ do Titular do Tanque
            //_cTitTanq   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
            _cMatrLat   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
            _cTitTanq   := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
//----------------------------------------------------------
            _cClasParc  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_L_CLASS') // Classificação do Titular do Tanque
            If AllTrim(_cClasParc) == "F"
               _cCPFCnpjP  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
               _cMatParce  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
            EndIf
//----------------------------------------------------------
         ElseIf TRBDET->A2_L_CLASS == "F"
             _cTipoTanq  := "FAMILIAR" //"INDIVIDUAL"
             _CCLASPROP  := "TITULAR DE TANQUE COMUNITARIO" // "PRODUTOR INDIVIDUAL"
             //_cCPFCnpjP  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
             //_cMatParce  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         EndIf

         If ! Empty(_cCPFCnpjP) .And. AllTrim(_cCPFCnpjP) == AllTrim(_cCpf_Cnpj)
            _cCPFCnpjP := ""
            _cMatParce := ""
         EndIf

         _CNOMETNQ   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ //        Nome do Tanque
         _cCapacTnq  := AllTrim(Str(TRBDET->A2_L_CAPTQ,11))   //           capacidade_tanque
         _cLatitude  := AllTrim(Str(TRBDET->A2_L_LATIT,18,6)) //           latitude_propriedade
         _cLongitud  := AllTrim(Str(TRBDET->A2_L_LONGI,18,6)) //           longitude_propriedade
         _cArea      := ""                                    //           area
         _cRecria    := ""                                    //           recria
         _cVacaSeca  := ""                                    //           vaca_seca
         _cVacaLacta := ""                                    //           vaca_lactacao
         _cHoraCole  := ""                                    //           horario_coleta
         _cRacaProp  := ""                                    //           raca_propriedade
         //_cFreqCol   := TRBDET->A2_L_FREQU                  //           frequencia_coleta

         If TRBDET->A2_L_FREQU == "1"
            _cFreqCol   := "48"                               //           frequencia_coleta
         Else
            _cFreqCol   := "24"
         EndIf

         _cProdDia   := ""                                    //           producao_media_diaria
         _cAreaUti   := ""                                    //           area_utilizada_producao
         _cCapacRef  := ""                                    //           capacidade_refrigeracao
         //Cap. Resfri.	Capacidade Resfriamento	0=Nenhuma	2=Duas Ordenhas	4=Quatro Ordenhas

         If TRBDET->A2_L_CAPAC == "0"
            _cCapacRef  := "Nenhuma"
         ElseIf TRBDET->A2_L_CAPAC == "2"
            _cCapacRef  := "Duas Ordenhas"
         ElseIf TRBDET->A2_L_CAPAC == "4"
            _cCapacRef  := "Quatro Ordenhas"
         EndIf

         If Empty(_cCapacRef)
            _cCapacRef := "nenhuma"
         EndIf

         _cSituacao  := TRBDET->A2_L_ATIVO
         _cSitTnq    := TRBDET->A2_L_ATIVO
         _CSITPROP   := TRBDET->A2_L_ATIVO
         _cSigSif    := TRBDET->A2_L_SIGSI
         _cCodigotq  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         _cTipoResf  := If(TRBDET->A2_L_RESFR == "E","EXPANSAO","IMERSAO")
         _cMarcaTanq := TRBDET->A2_L_MARTQ
         _cCodLinha  := TRBDET->A2_L_LI_RO   //           codigo_linha_laticinio
         _cDescLin   := TRBDET->ZL3_DESCRI   //           nome_linha

         _cComplemD  := TRBDET->A2_ENDCOMP          //            complemento
         _cEnderecD  := TRBDET->A2_END              //            endereco
         _cNrEndD    := ""                          //            numero
         _cBairroD   := TRBDET->A2_BAIRRO           //            bairro
         _cCepD      := TRBDET->A2_CEP              //            cep
         _cIDCidadD  := ""                          //            id_cidade
         _cCidUFD    := AllTrim(TRBDET->A2_MUN) + "\/" + AllTrim(TRBDET->A2_EST)             // municipio  // estado
         _cCodIbgeD  := TRBDET->A2_COD_MUN          //           codigo_ibge"
         _cEMailD    := TRBDET->A2_EMAIL            //            email
         _cTelefonD  := TRBDET->A2_TEL

         //----------------------------------
         _cRazaoSoc := TRBDET->A2_L_NATRA
         _cCpf_Cnpj := ""
         _cInscrEst := ""
         _cRg_IE    := ""
         _cDtNascF  := ""
         _cObserv   := ""
         _cComplem  := ""
         _cEndereco := ""
         _cNrEnd    := ""
         _cBairro   := ""
         _cCep      := ""
         //----------------------------------
         _cComplemD := ""
         _cEnderecD := ""
         _cNrEndD   := ""
         _cBairroD  := ""
         _cCepD     := ""
         //----------------------------------

         //_cItens += If(!Empty(_cItens),",","") + &(_cDetalhe)

         //=======================================================================================
         // Este trecho trata os varios e-mails de um campo e envia um a um em campos diferentes.
         //=======================================================================================
         _cEMailD    := AllTrim(StrTran(_cEMailD,",",";"))
         _aDetMail   := U_ITTXTARRAY(_cEMailD,";",10)

         _cDetMail := ""
         _cDetJson := ""

         If Len(_aDetMail) > 0
            For _nY := 1 To Len(_aDetMail)
                _cEMailD  := StrTran(_aDetMail[_nY],";","")
                _cDetJson := &(_cDetalheB)
                _cDetMail += If(!Empty(_cDetMail),",","") + _cDetJson
            Next
         Else
            _cDetJson := &(_cDetalheB)
            _cDetMail += If(!Empty(_cDetMail),",","") + _cDetJson
         EndIf
//-----------------------------------------------------------------------------
         _cItens += If(!Empty(_cItens),",","") + &(_cDetalheA) + _cDetMail + &(_cDetalheC)
//----------------------------------------------------------------
         _CDataCad  := Dtoc(Date())
         _cHoraCad  := Time()

         _cJSonEnv := &(_cCabec_A) + _cCabMail + &(_cCabec_C) + _cItens + _cRodape

         MGLT32ENVA(_cJSonEnv, _cLinkSoc ,_aHeadOut , TRBDET->WK_RECNO, "C")

         _cItens := ""

         TRBDET->(DbSkip())

      EndDo

      //=====================================================================
      // Atualiza cadastro de produtores como já enviados para Evomilk.
      //=====================================================================
      If Len(_aRecnoSA2) > 0 // 1 // Significa que foi integrado com sucesso uma Associação / Cooperativa com sucesso.

         For _nI := 1 To Len(_aRecnoSA2)
             //SA2->(DbGoto(_aRecnoSA2[_nI,1]))
             //SA2->(RecLock("SA2", .F.))
             //SA2->A2_L_ENVEV := "N"
             //If Empty(SA2->A2_L_ITCOL)
             //   SA2->A2_L_ITCOL := "S"
             //EndIf
             //SA2->A2_L_ENVAT := "N"
             //SA2->A2_L_TPASS := _aRecnoSA2[_nI,2]
             //SA2->(MsUnLock())
         Next

      EndIf

      TRBCAB->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32ENVA
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Integração dos de Associação / Cooperativas Italac para Sistema Evomilk
===============================================================================================================================
Parametros--------: _cJSonEnv = JSon de Envio.
                    _cLinkEnv = Link de envio dos dados.
                    _aHeadEnv = Header de envio dos dados.
                    _aRegSA2  = Recnos do casdastro de Produtores para marcar como já enviados.
                    _cTipoAss = A = Associação/Cooperativa
                                C = Associado/cooperado
===============================================================================================================================
Retorno------------: _lRet = .T. = Enviados com sucesso.
                           = .F. = Falha no envio.
===============================================================================================================================
*/
Static Function MGLT32ENVA(_cJSonEnv, _cLinkEnv ,_aHeadEnv , _nRegSA2,_cTipoAss)
Local _lRet := .T.
Local _cJSonAux := "", _aExcecao := {}

Begin Sequence

   If ! Empty(_cJSonEnv)

      _nStart 		:= 0
      _nRetry 		:= 0
      _cJSonRet 	:= Nil
      _nTimOut	 	:= 120
      _cRetorno   := ""

      _cRetHttp    := ''
      _oRetJSon    := ''

      //=======================================================================
      // Remoção de caracteres especiais do JSon antes do envio
      //=======================================================================
      _cJSonAux := StrTran(_cJSonEnv,"\/","/-/")
      _aExcecao := {{"\","-"},{char(9)," "}}  // Char(9) = Tecla Tab.
      _cJSonAux := U_ITSUBCHR(_cJSonAux, _aExcecao)
      _cJSonAux := StrTran(_cJSonAux,"/-/","\/")
      _cJSonEnv := _cJSonAux

      //=======================================================================
      // Envio do JSon
      //=======================================================================
      _cRetHttp := AllTrim( HttpPost( _cLinkEnv , '' , _cJSonEnv , _nTimOut , _aHeadEnv , @_cJSonRet ) )

      If ! Empty(_cRetHttp)
         _cRetHttp := StrTran( _cRetHttp, "\n", "" )
         FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
      EndIf

      _cAuxHTTP := Upper(_cRetHttp)

      _lResult := .F.

      If ! Empty(_oRetJSon) .And. "STATUS" $ Upper(_cAuxHTTP)
         _lResult := _oRetJSon:status
      EndIf

      _cRetorno := Upper(_cRetHttp)

      If _lResult // Integração realizada com sucesso
         //U_MGLT032Y(_aProdEnv) // Grava na tabela temporária os registros integrados com sucesso para depois ataualizar flag de envio da SA2.
         //=================================================================
         // Grava Dados dos Produtores Enviados e aceitos para histórico
         //=================================================================
         ZBH->(RecLock("ZBH",.T.))
         ZBH->ZBH_FILIAL := xFilial("ZBH")         // Filial do Sistema
         ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6) // Codigo do Produtor
         ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4) // Loja do Produtor
         ZBH->ZBH_NOMPRO := _cRazaoSoc             // Nome do Produtor
         ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)     // Motivo da Rejeição
         ZBH->ZBH_JSONEN := _cJSonEnv              // JSON enviado
         ZBH->ZBH_DTENV	    := Date()              // Data de Envio
         ZBH->ZBH_HRENV	    := Time()              // Hora de Envio
         ZBH->ZBH_STATUS	 := "A"                 // Status da Integração
         ZBH->ZBH_WEBINT    := "E"                 // Indica que a integração está sendo realizada com o App Evomilk
			ZBH->(MsUnLock())

         //====================================================================
         // Marca produtor como já enviado para o sistema Evomilk.
         //====================================================================
         Aadd(_aRecnoSA2, {_nRegSA2,_cTipoAss})

      Else
         _lRet := .F.

         //============================================================
         // Grava dados de envio rejeitados para histórico.
         //============================================================
         ZBH->(RecLock("ZBH",.T.))
         ZBH->ZBH_FILIAL := xFilial("ZBH")          // Filial do Sistema
         ZBH->ZBH_CODPRO := SubStr(_cMatLatic,1,6)    // Codigo do Produtor
         ZBH->ZBH_LOJPRO := SubStr(_cMatLatic,8,4)  // Loja do Produtor
         ZBH->ZBH_NOMPRO := _cRazaoSoc                // Nome do Produtor
         ZBH->ZBH_MOTIVO := AllTrim(_cRetHttp)        // Motivo da Rejeição
         ZBH->ZBH_JSONEN := _cJSonEnv                // JSON enviado
         ZBH->ZBH_DTREJ  := Date()                    // Data da Rejeição
         ZBH->ZBH_HRREJ  := Time()                    // Hora da Rejeição
         ZBH->ZBH_DTENV	 := Date()                    // Data de Envio
         ZBH->ZBH_HRENV	 := Time()                    // Hora de Envio
         ZBH->ZBH_STATUS := "R"                       // Status da Integração
         ZBH->ZBH_WEBINT := "E"                       // Indica que a integração está sendo realizada com o App Evomilk
			ZBH->(MsUnLock())

      EndIf
   EndIf

   //U_MGLT032G("","","",.F., .T.) // Fecha arquivo // Grava Arquivo Texto com os retornos de erro/rejeições.

End Sequence

Return _lRet

/*
===============================================================================================================================
Função-------------: MGLT32TITC
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de leitura dos dados dos produtores proprietários de tanques coletivos.
===============================================================================================================================
Parametros---------: Filial de envio
===============================================================================================================================
Retorno------------: Nil
===============================================================================================================================
*/
Static Function MGLT32TITC(_cFilEnvio)
Local _cDescRota := ""

Begin Sequence

   _cQry := " SELECT DISTINCT A2_COD, "  // matricula_laticinio: TESTE_278363
   _cQry += " A2_LOJA, "                 // Loja_laticinio: TESTE_278363
   _cQry += " A2_NOME, "                 // nome_razao_social  : PRODUTOR TESTE 3337
   //----------------------------------------------------------------------------------
   _cQry += " A2_L_TANQ,  "              // Codigo Tanque
   _cQry += " A2_L_TANLJ, "              // Loja Tanque
   _cQry += " A2_L_LI_RO, "              // codigo_linha_laticinio
   _cQry += " ZL3_FILIAL, "              // Filial da Rota
   //_cQry += " SA2.R_E_C_N_O_ AS NRREG "
   //----------------------------------------------------------------------------------
   _cQry += " A2_L_LI_RO, "
   _cQry += " ZL3_DESCRI  "
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZL3_COD = A2_L_LI_RO "
   _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' "
   //_cQry += " AND ZL3_FILIAL IN ('01','04','23','40','24','25','09','02','10','11','20','06','0B','93') "
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_COD <> '      ' "
   _cQry += " AND (A2_L_CLASS = 'U' OR A2_L_CLASS = 'F') "
   _cQry += " ORDER BY A2_COD,A2_LOJA "

   If Select("QRYSA2") > 0
         QRYSA2->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYSA2")

   _cCodForn := Space(6)

   QRYSA2->(DbGotop())

   //ZL3->(DbSetOrder(1)) // 1=ZL3_FILIAL+ZL3_COD+ZL3_TIPO
   SA2->(DbSetOrder(1)) // 1=A2_FILIAL+A2_COD+A2_LOJA

   Do While ! QRYSA2->(Eof())

      If Empty(QRYSA2->A2_COD) // Foi identificado no cadastro de fornecedores alguns registros sem o código preenchido.
         QRYSA2->(DbSkip())
         Loop
      EndIf

      //=============================================================================
      // Verifica se O proprietário já foi lido na rotina anterior.
      //=============================================================================
      _nI := AsCan(_aDadosTC, {|x| x[1] == QRYSA2->A2_L_TANQ .And. x[2] == QRYSA2->A2_L_TANLJ})
      If _nI > 0
         QRYSA2->(DbSkip())
         Loop
      EndIf

      //=============================================================================
      // Posiciona a tabela SA2 no titular do tanque comunitário.
      //=============================================================================
      //QRYSA2->A2_L_TANQ , QRYSA2->A2_L_TANLJ
      If ! SA2->(MsSeek(xFilial("SA2") + QRYSA2->A2_L_TANQ + QRYSA2->A2_L_TANLJ))
         QRYSA2->(DbSkip())
         Loop
      EndIf

      _cDescRota := ""
      If ZL3->(MsSeek(QRYSA2->ZL3_FILIAL + QRYSA2->A2_L_LI_RO))
         _cDescRota :=  ZL3->ZL3_DESCRI
      EndIf

      //=============================================================================
      // Grava as tabelas temporárias para envio dos dados
      //=============================================================================
      If _cCodForn <> SA2->A2_COD
         _cCodForn := SA2->A2_COD

         TRBCAB->(DBAPPEND())
         TRBCAB->A2_COD     := SA2->A2_COD            // id_tipo_tanque: 1
         TRBCAB->A2_LOJA    := SA2->A2_LOJA
         TRBCAB->A2_NOME    := SA2->A2_NOME           //C,40  // nome_razao_social  : PRODUTOR TESTE 3337
         TRBCAB->A2_CGC     := SA2->A2_CGC            //C,14  // cpf_cnpj: 349.812.172-34
         TRBCAB->A2_INSCR   := SA2->A2_INSCR          //C,18  // inscricao_estadual: 170642
         TRBCAB->A2_PFISICA := SA2->A2_PFISICA        //C,18  // rg_ie: ABC320303
         TRBCAB->A2_DTNASC  := SA2->A2_DTNASC   //D,8   // data_nascimento_fundacao: 1994-10-10
         TRBCAB->WK_OBSERV  := ""                        //C,100 // info_adicional: Observação / info adicional...
         TRBCAB->A2_ENDCOMP := SA2->A2_ENDCOMP        //C,50  // complemento: Complemento Teste
         TRBCAB->A2_END     := SA2->A2_END            //C,90  // endereco: Rua Caminho Andante
         TRBCAB->WK_NUMERO  := ""                        //C,20  // numero: 429 A
         TRBCAB->A2_BAIRRO  := SA2->A2_BAIRRO         //C,50  // bairro: Bairro Teste
         TRBCAB->A2_CEP     := SA2->A2_CEP            //C,8   // cep: 51462-745
         TRBCAB->WK_ID_UF   := ""                        //C,2   // id_uf: 21
         TRBCAB->A2_COD_MUN := SA2->A2_COD_MUN        //C,5   // id_cidade: 73
         TRBCAB->A2_MUN     := SA2->A2_MUN            // municipio
         TRBCAB->A2_EST     := SA2->A2_EST            // estado
         TRBCAB->A2_BANCO   := SA2->A2_BANCO          // codigo do banco
         TRBCAB->A2_AGENCIA := SA2->A2_AGENCIA        // codigo da agencia
         TRBCAB->A2_NUMCON  := SA2->A2_NUMCON         // numero da conta
         TRBCAB->A2_EMAIL   := SA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
         TRBCAB->A2_TEL     := AllTrim(SA2->A2_DDD)+SA2->A2_TEL //C,50  // celular1: 95920298034
         TRBCAB->A2_TEL2    := ""                        //C,50  // celular2: null
         TRBCAB->A2_TEL3    := ""                        //C,50  // telefone1: 5590038949
         TRBCAB->A2_TEL4    := ""                        //C,50  // telefone2: null
         TRBCAB->A2_TEL1W   := "False"                   //C,50  // celular1_whatsapp: true
         TRBCAB->A2_TEL2W   := "False"                   //C,50  // celular2_whatsapp: false
         TRBCAB->WK_RECNO   := SA2->(Recno())            //N,10 ,0 // Nr Recno SA2
         TRBCAB->WK_ORDEMP  := "C"   //QRYSA2->ORDEMP    // Ordenação dos dados para envio
         TRBCAB->(MsUnlock())

      EndIf

      TRBDET->(DbAppend())
      TRBDET->A2_COD     := SA2->A2_COD  // SA2->A2_L_TANQ      // SA2->A2_COD         //C,6     // matricula_laticinio: TESTE_278363
      TRBDET->A2_LOJA    := SA2->A2_LOJA // SA2->A2_L_TANLJ     // SA2->A2_LOJA        //C,4     // Loja_laticinio: TESTE_278363
      TRBDET->A2_CGC     := SA2->A2_CGC         //C,14    // cpf_cnpj: 349.812.172-34
      TRBDET->A2_L_FAZEN := SA2->A2_L_FAZEN     //C,40    // nome_propriedade_rural: PROPRIEDADE TESTE 001
      TRBDET->A2_L_NIRF  := SA2->A2_L_NIRF      //C,11    // NIRF: ABC4658
      TRBDET->A2_L_TANQ  := SA2->A2_L_TANQ      //C,10    // id_tipo_tanque: 1
      TRBDET->A2_L_CAPTQ := SA2->A2_L_CAPTQ     //N,11    // capacidade_tanque: 720
      TRBDET->A2_L_LATIT := SA2->A2_L_LATIT     //N,10 ,6 // latitude_propriedade: -17.855250
      TRBDET->A2_L_LONGI := SA2->A2_L_LONGI     //N,10 ,6 // longitude_propriedade: -46.223278
      TRBDET->A2_L_MARTQ := SA2->A2_L_MARTQ     //C,20    // id_tipo_tanque: // Marca do tanque
      TRBDET->A2_L_CLASS := SA2->A2_L_CLASS     //C,01    // id_tipo_tanque:
      TRBDET->WK_AREA    := 0                      //N,12 ,6 // area: 2000.15
      TRBDET->WK_RECRIA  := ""                     //C,10    // recria: 1
      TRBDET->WK_VACASEC := ""                     //C,10    // vaca_seca: 12
      TRBDET->WK_VACALAC := ""                     //C,10    // vaca_lactacao: 6
      TRBDET->WK_HORACOL := ""                     //C,10    // horario_coleta: 23:59
      TRBDET->WK_RACAPRO := ""                     //C,50    // raca_propriedade: Nome Raça predominante Teste
      TRBDET->A2_L_FREQU := SA2->A2_L_FREQU     //C,10    // frequencia_coleta: 17
      TRBDET->WK_PRDDIAR := 0                      //N,10 ,2 // fproducao_media_diaria: 7251.31
      TRBDET->WK_AREAUTI := 0                      //N,10 ,2 // area_utilizada_producao: 837.84
      TRBDET->A2_L_CAPAC := SA2->A2_L_CAPAC        //N,10 ,2 // capacidade_refrigeracao: 307
      TRBDET->WK_RECNO   := SA2->(Recno())             //N,10 ,0 // Nr Recno SA2
      TRBDET->WK_ORDEMP  := "C"   //QRYSA2->ORDEMP    // Ordenação dos dados para envio
      //-------------------------------------------------------
      TRBDET->A2_L_LI_RO := SA2->A2_L_LI_RO        //        codigo_linha_laticinio
      TRBDET->ZL3_DESCRI := _cDescRota             // QRYSA2->ZL3_DESCRI     //        nome_linha
      TRBDET->A2_L_ATIVO := If(SA2->A2_L_ATIVO=="N","false","true") // _cSituacao
      TRBDET->A2_L_SIGSI := SA2->A2_L_SIGSI        // _cSigSif
      TRBDET->A2_L_TANLJ := SA2->A2_L_TANLJ        // Loja tanque
      TRBDET->A2_L_RESFR := SA2->A2_L_RESFR        // _cTipoResf
      //-------------------------------------------------------
      TRBDET->A2_ENDCOMP := SA2->A2_ENDCOMP        //C,50  // complemento: Complemento Teste
      TRBDET->A2_END     := SA2->A2_END            //C,90  // endereco: Rua Caminho Andante
      TRBDET->WK_NUMERO  := ""                        //C,20  // numero: 429 A
      TRBDET->A2_BAIRRO  := SA2->A2_BAIRRO         //C,50  // bairro: Bairro Teste
      TRBDET->A2_CEP     := SA2->A2_CEP            //C,8   // cep: 51462-74
      TRBDET->A2_COD_MUN := SA2->A2_COD_MUN        //C,5   // id_cidade: 73
      TRBDET->A2_MUN     := SA2->A2_MUN            // municipio
      TRBDET->A2_EST     := SA2->A2_EST            // estado
      TRBDET->A2_EMAIL   := SA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
      TRBDET->A2_TEL     := AllTrim(SA2->A2_DDD)+SA2->A2_TEL //C,50  // celular1: 95920298034

      TRBDET->(MsUnlock())

      _lHaDadosP := .T.

      Aadd(_aDadosTC, {QRYSA2->A2_L_TANQ , QRYSA2->A2_L_TANLJ})

      QRYSA2->(DbSkip())

   EndDo

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32USTC
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de leitura dos dados dos produtores Usuários de tanques coletivos.
===============================================================================================================================
Parametros---------: Filial de envio
===============================================================================================================================
Retorno------------: Nil
===============================================================================================================================
*/
Static Function MGLT32USTC()
Local _cDescRota := ""
Local _cFilEnvio := xFilial("ZL3")
Local _cTextoMsg := ""
Local _cTextoUsu := ""
Local _cTextoTit := ""

Private _oFWRITER2

Begin Sequence

   _cQry := " SELECT DISTINCT A2_COD, "  // matricula_laticinio: TESTE_278363
   _cQry += " A2_LOJA, "                 // Loja_laticinio: TESTE_278363
   _cQry += " A2_NOME, "                 // nome_razao_social  : PRODUTOR TESTE 3337
   //----------------------------------------------------------------------------------
   _cQry += " A2_L_TANQ,  "              // Codigo Tanque
   _cQry += " A2_L_TANLJ, "              // Loja Tanque
   _cQry += " A2_L_LI_RO, "              // codigo_linha_laticinio
   _cQry += " ZL3_FILIAL, "              // Filial da Rota
   _cQry += " SA2.R_E_C_N_O_ AS NRREG, "
   //----------------------------------------------------------------------------------
   _cQry += " A2_L_LI_RO, "
   _cQry += " ZL3_DESCRI, "
   _cQry += " A2_L_ATIVO, "
   _cQry += " A2_CGC      "
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZL3_COD = A2_L_LI_RO "
   _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' "
   //_cQry += " AND ZL3_FILIAL IN ('01','04','23','40','24','25','09','02','10','11','20','06','0B','93') "
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_COD <> '      ' "
   _cQry += " AND (A2_L_CLASS = 'U' OR A2_L_CLASS = 'F') "
   _cQry += " ORDER BY A2_COD,A2_LOJA "

   If Select("QRYSA2") > 0
         QRYSA2->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYSA2")

   _cCodForn := Space(6)

   QRYSA2->(DbGotop())


   MGLT32INCP("","", .T. , .F.,_cFilEnvio)

   //ZL3->(DbSetOrder(1)) // 1=ZL3_FILIAL+ZL3_COD+ZL3_TIPO
   SA2->(DbSetOrder(1)) // 1=A2_FILIAL+A2_COD+A2_LOJA

   Do While ! QRYSA2->(Eof())

      If Empty(QRYSA2->A2_COD) // Foi identificado no cadastro de fornecedores alguns registros sem o código preenchido.
         QRYSA2->(DbSkip())
         Loop
      EndIf

      _cTextoUsu := QRYSA2->A2_COD     + ";"    // Codigo_Usuario_Tanque
      _cTextoUsu += QRYSA2->A2_LOJA    + ";"    // Loja_Usuario_Tanque
      _cTextoUsu += QRYSA2->A2_NOME    + ";"    // Nome_Usuario_Tanque
      _cTextoUsu += QRYSA2->A2_CGC     + ";"    // CPF_CNPJ_Usuario_Tanque
      _cTextoUsu += QRYSA2->A2_L_LI_RO + ";"    // Linha_Rota_Usuario_Tanque
      _cTextoUsu += QRYSA2->ZL3_DESCRI + ";"    // Descricao_Linha_Rota_Usuario_Tanque
      _cTextoUsu += If(QRYSA2->A2_L_ATIVO == "S","ATIVO","INATIVO") + ";" //Status_Usuario_Tanque

      //=============================================================================
      // Posiciona a tabela SA2 no titular do tanque comunitário.
      //=============================================================================
      If ! SA2->(MsSeek(xFilial("SA2") + QRYSA2->A2_L_TANQ + QRYSA2->A2_L_TANLJ))
         QRYSA2->(DbSkip())
         Loop
      EndIf

      If SA2->A2_L_CLASS <> 'C'
         _cTextoMsg := "Titular de Tanques Coletivos classificado como: "

         If SA2->A2_L_CLASS == "I"
            _cTextoMsg += "I=Individual"
         ElseIf SA2->A2_L_CLASS == "I"
            _cTextoMsg += "U=Usuário TC"
         ElseIf SA2->A2_L_CLASS == "I"
            _cTextoMsg += "N=Nenhum"
         ElseIf SA2->A2_L_CLASS == "I"
            _cTextoMsg += "F=Familiar"
         Else
            _cTextoMsg += "Vazio"
         EndIf

         _cTextoTit := SA2->A2_COD + ";"      // Codigo_Titular_Tanque
         _cTextoTit += SA2->A2_LOJA + ";"     // Loja_Titular_Tanque
         _cTextoTit += SA2->A2_NOME + ";"     // Nome_Titular_tanque
         _cTextoTit += SA2->A2_CGC + ";"      // CPF_CNPJ_Titular_Tanque
         _cTextoTit += SA2->A2_L_LI_RO + ";"  // Linha_Rota_Titular_Tanque
         _cTextoTit += If(SA2->A2_L_ATIVO == "S","ATIVO","INATIVO") + ";" //Status_Titular_Tanque

         MGLT32INCP(_cTextoTit + _cTextoUsu, _cTextoMsg, .F. , .F.,_cFilEnvio)

         QRYSA2->(DbSkip())
         Loop
      EndIf

      //=============================================================================
      // Posiciona a tabela SA2 no usuário do tanque comunitário.
      //=============================================================================
      SA2->(DbGoto(QRYSA2->NRREG))

      //=============================================================================
      // Obtem o nome da rota/linha.
      //=============================================================================
      _cDescRota := ""
      If ZL3->(MsSeek(QRYSA2->ZL3_FILIAL + QRYSA2->A2_L_LI_RO))
         _cDescRota :=  ZL3->ZL3_DESCRI
      EndIf

      //=============================================================================
      // Grava as tabelas temporárias para envio dos dados
      //=============================================================================
      If _cCodForn <> SA2->A2_COD
         _cCodForn := SA2->A2_COD

         TRBCAB->(DBAPPEND())
         TRBCAB->A2_COD     := SA2->A2_COD            // id_tipo_tanque: 1
         TRBCAB->A2_LOJA    := SA2->A2_LOJA
         TRBCAB->A2_NOME    := SA2->A2_NOME           //C,40  // nome_razao_social  : PRODUTOR TESTE 3337
         TRBCAB->A2_CGC     := SA2->A2_CGC            //C,14  // cpf_cnpj: 349.812.172-34
         TRBCAB->A2_INSCR   := SA2->A2_INSCR          //C,18  // inscricao_estadual: 170642
         TRBCAB->A2_PFISICA := SA2->A2_PFISICA        //C,18  // rg_ie: ABC320303
         TRBCAB->A2_DTNASC  := SA2->A2_DTNASC   //D,8   // data_nascimento_fundacao: 1994-10-10
         TRBCAB->WK_OBSERV  := ""                        //C,100 // info_adicional: Observação / info adicional...
         TRBCAB->A2_ENDCOMP := SA2->A2_ENDCOMP        //C,50  // complemento: Complemento Teste
         TRBCAB->A2_END     := SA2->A2_END            //C,90  // endereco: Rua Caminho Andante
         TRBCAB->WK_NUMERO  := ""                        //C,20  // numero: 429 A
         TRBCAB->A2_BAIRRO  := SA2->A2_BAIRRO         //C,50  // bairro: Bairro Teste
         TRBCAB->A2_CEP     := SA2->A2_CEP            //C,8   // cep: 51462-745
         TRBCAB->WK_ID_UF   := ""                        //C,2   // id_uf: 21
         TRBCAB->A2_COD_MUN := SA2->A2_COD_MUN        //C,5   // id_cidade: 73
         TRBCAB->A2_MUN     := SA2->A2_MUN            // municipio
         TRBCAB->A2_EST     := SA2->A2_EST            // estado
         TRBCAB->A2_BANCO   := SA2->A2_BANCO          // codigo do banco
         TRBCAB->A2_AGENCIA := SA2->A2_AGENCIA        // codigo da agencia
         TRBCAB->A2_NUMCON  := SA2->A2_NUMCON         // numero da conta
         TRBCAB->A2_EMAIL   := SA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
         TRBCAB->A2_TEL     := AllTrim(SA2->A2_DDD)+SA2->A2_TEL //C,50  // celular1: 95920298034
         TRBCAB->A2_TEL2    := ""                        //C,50  // celular2: null
         TRBCAB->A2_TEL3    := ""                        //C,50  // telefone1: 5590038949
         TRBCAB->A2_TEL4    := ""                        //C,50  // telefone2: null
         TRBCAB->A2_TEL1W   := "False"                   //C,50  // celular1_whatsapp: true
         TRBCAB->A2_TEL2W   := "False"                   //C,50  // celular2_whatsapp: false
         TRBCAB->WK_RECNO   := SA2->(Recno())            //N,10 ,0 // Nr Recno SA2
         TRBCAB->WK_ORDEMP  := "C"   //QRYSA2->ORDEMP    // Ordenação dos dados para envio
         TRBCAB->(MsUnlock())

      EndIf

      TRBDET->(DbAppend())
      TRBDET->A2_COD     := SA2->A2_COD  // SA2->A2_L_TANQ      // SA2->A2_COD         //C,6     // matricula_laticinio: TESTE_278363
      TRBDET->A2_LOJA    := SA2->A2_LOJA // SA2->A2_L_TANLJ     // SA2->A2_LOJA        //C,4     // Loja_laticinio: TESTE_278363
      TRBDET->A2_CGC     := SA2->A2_CGC         //C,14    // cpf_cnpj: 349.812.172-34
      TRBDET->A2_L_FAZEN := SA2->A2_L_FAZEN     //C,40    // nome_propriedade_rural: PROPRIEDADE TESTE 001
      TRBDET->A2_L_NIRF  := SA2->A2_L_NIRF      //C,11    // NIRF: ABC4658
      TRBDET->A2_L_TANQ  := SA2->A2_L_TANQ      //C,10    // id_tipo_tanque: 1
      TRBDET->A2_L_CAPTQ := SA2->A2_L_CAPTQ     //N,11    // capacidade_tanque: 720
      TRBDET->A2_L_LATIT := SA2->A2_L_LATIT     //N,10 ,6 // latitude_propriedade: -17.855250
      TRBDET->A2_L_LONGI := SA2->A2_L_LONGI     //N,10 ,6 // longitude_propriedade: -46.223278
      TRBDET->A2_L_MARTQ := SA2->A2_L_MARTQ     //C,20    // id_tipo_tanque: // Marca do tanque
      TRBDET->A2_L_CLASS := SA2->A2_L_CLASS     //C,01    // id_tipo_tanque:
      TRBDET->WK_AREA    := 0                      //N,12 ,6 // area: 2000.15
      TRBDET->WK_RECRIA  := ""                     //C,10    // recria: 1
      TRBDET->WK_VACASEC := ""                     //C,10    // vaca_seca: 12
      TRBDET->WK_VACALAC := ""                     //C,10    // vaca_lactacao: 6
      TRBDET->WK_HORACOL := ""                     //C,10    // horario_coleta: 23:59
      TRBDET->WK_RACAPRO := ""                     //C,50    // raca_propriedade: Nome Raça predominante Teste
      TRBDET->A2_L_FREQU := SA2->A2_L_FREQU     //C,10    // frequencia_coleta: 17
      TRBDET->WK_PRDDIAR := 0                      //N,10 ,2 // fproducao_media_diaria: 7251.31
      TRBDET->WK_AREAUTI := 0                      //N,10 ,2 // area_utilizada_producao: 837.84
      TRBDET->A2_L_CAPAC := SA2->A2_L_CAPAC        //N,10 ,2 // capacidade_refrigeracao: 307
      TRBDET->WK_RECNO   := SA2->(Recno())             //N,10 ,0 // Nr Recno SA2
      TRBDET->WK_ORDEMP  := "C"   //QRYSA2->ORDEMP    // Ordenação dos dados para envio
      //-------------------------------------------------------
      TRBDET->A2_L_LI_RO := SA2->A2_L_LI_RO        //        codigo_linha_laticinio
      TRBDET->ZL3_DESCRI := _cDescRota             // QRYSA2->ZL3_DESCRI     //        nome_linha
      TRBDET->A2_L_ATIVO := If(SA2->A2_L_ATIVO=="N","INATIVO","ATIVO") // _cSituacao
      TRBDET->A2_L_SIGSI := SA2->A2_L_SIGSI        // _cSigSif
      TRBDET->A2_L_TANLJ := SA2->A2_L_TANLJ        // Loja tanque
      TRBDET->A2_L_RESFR := SA2->A2_L_RESFR        // _cTipoResf
      //-------------------------------------------------------
      TRBDET->A2_ENDCOMP := SA2->A2_ENDCOMP        //C,50  // complemento: Complemento Teste
      TRBDET->A2_END     := SA2->A2_END            //C,90  // endereco: Rua Caminho Andante
      TRBDET->WK_NUMERO  := ""                        //C,20  // numero: 429 A
      TRBDET->A2_BAIRRO  := SA2->A2_BAIRRO         //C,50  // bairro: Bairro Teste
      TRBDET->A2_CEP     := SA2->A2_CEP            //C,8   // cep: 51462-74
      TRBDET->A2_COD_MUN := SA2->A2_COD_MUN        //C,5   // id_cidade: 73
      TRBDET->A2_MUN     := SA2->A2_MUN            // municipio
      TRBDET->A2_EST     := SA2->A2_EST            // estado
      TRBDET->A2_EMAIL   := SA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
      TRBDET->A2_TEL     := AllTrim(SA2->A2_DDD)+SA2->A2_TEL //C,50  // celular1: 95920298034

      TRBDET->(MsUnlock())

      _lHaDadosP := .T.

      //Aadd(_aDadosTC, {QRYSA2->A2_L_TANQ , QRYSA2->A2_L_TANLJ})

      QRYSA2->(DbSkip())

   EndDo

   MGLT32INCP("","", .F. , .T.,_cFilEnvio)

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32INCP
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Grava arquivo texto com inconsistencias de dados.
===============================================================================================================================
Parametros--------:  _cDadosProd = Dados do Produtor com Inconsistencia
                     _cDescIncon = Descrição da Inconsistencia
                     _lAbreArq   = .T./.F. = Abre arquivo ?
                     _lFechaArq  = .T./.F. = Fecha arquivo ?
                     _cUnidade   = Unidade de envio dos dados.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
Static Function MGLT32INCP(_cDadosProd,_cDescIncon,_lAbreArq, _lFechaArq,_cUnidade)
Local _aUnidades := {}, _nI, _cNomeUnid

Default _cJsongrv   := ""
Default _cRetInteg  := ""
Default _cDadosProd := ""
Default _lAbreArq  := .F.
Default _lFechaArq := .F.
Default _cRotina := "PADRAO"

_cDirTXT  := GetTempPath() //"\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
_cNomeArq := "Listagem_com_Inconsistencia_na_Integração"

Begin Sequence
   //If _cRotina == "USU_TC" // Rotina de Envio de Titulares de Tanques Coletivos.
   If _lAbreArq
      Aadd(_aUnidades, { "01","CORUMBAIBA"})
      Aadd(_aUnidades, { "04","ARAGUARI"})
      Aadd(_aUnidades, { "23","TAPEJARA"})
      Aadd(_aUnidades, { "40","TRES CORACOES"})
      Aadd(_aUnidades, { "24","CRISSIUMAL"})
      Aadd(_aUnidades, { "25","GIRUA"})
      Aadd(_aUnidades, { "09","IPORA"})
      Aadd(_aUnidades, { "02","ITAPACI"})
      Aadd(_aUnidades, { "10","JARU"})
      Aadd(_aUnidades, { "11","NOVA MAMORE"})
      Aadd(_aUnidades, { "20","PASSO FUNDO"})
      Aadd(_aUnidades, { "06","PONTALINA"})
      Aadd(_aUnidades, { "0B","QUIRINOPOLIS"})
      Aadd(_aUnidades, { "93","PARANA_CASCAVEL"})
      Aadd(_aUnidades, { "31","CONCEICAO_DO_ARAGUAIA"})
      Aadd(_aUnidades, { "32","COUTO_DE_MAGALHAES"})

      _cNomeUnid := ""
      _nI := AsCan(_aUnidades,{|x| x[1]==_cUnidade})
      If _nI > 0
         _cNomeUnid := _aUnidades[_nI,2]
      EndIf
      _cNomeArq := "Listagem_com_Inconsistencia_na_Integração_" + _cNomeUnid
   EndIf

   If _lAbreArq
      _cDirTXT := GetTempPath() //"\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
      _cNomeArq:= _cNomeArq + ".Txt"

      _oFWriter2 := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

      If ! _oFWriter2:Create()
         U_ItMsg("Erro na criação do arquivo texto para gravação das inconsistencia de dados.","Atenção",,1)
         Break
      EndIf

      _oFWriter2:Write("Codigo_Titular_Tanque;Loja_Titular_Tanque;Nome_Titular_tanque;CPF_CNPJ_Titular_Tanque;Linha_Rota_Titular_Tanque;Status_Titular_Tanque;Codigo_Usuario_Tanque;Loja_Usuario_Tanque;Nome_Usuario_Tanque;CPF_CNPJ_Usuario_Tanque;Linha_Rota_Usuario_Tanque;Descricao_Linha_Rota_Usuario_Tanque;Status_Usuario_Tanque;Mensagem_de_Inconsistencia"+ CRLF)

    EndIf

   If ! Empty(_cDadosProd)
      _oFWriter2:Write(_cDadosProd + _cDescIncon + CRLF)
   EndIf

   If _lFechaArq
      //Encerra o arquivo
      _oFWriter2:Close()
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32RENV
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de leitura dos dados dos produtores com base em Listagem para Reenvio a Evomilk.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
Static Function MGLT32RENV()
Local _cFilEnvio  := xFilial("ZL3")
Local _aListReenv := {}
Local _cDirJSon
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cCodForn
Local _nTotRegs, _nI, _nJ

Begin Sequence
   //================================================================================
   // Posiciona a empresa Webservice e obtem o diretório do arquivo de produtores
   // para reenvio a Evomilk.
   //================================================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
   Else
      U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      Break
   EndIf

   //============================================================================
   // Obtem a planilha do App Evomilk com os produtores a serem reenviados.
   //============================================================================
   _aListReenv := MGLT032TXT(_cDirJSon+"Lista_Produtores_Reenvio_CIA_LEITE.txt")
   If Empty(_aListReenv)
      U_ItMsg("Erro na leitura da Lista de Produtores de Reenvio para Evomilk.","Atenção",,1)

      Break
   EndIf

   //================================================================================
   // Monta select de leitura de dados do cadastro de Produtores rurais.
   //================================================================================
   _cQry := " SELECT DISTINCT A2_COD, "  // matricula_laticinio: TESTE_278363
   _cQry += " A2_NOME, "                 // nome_razao_social  : PRODUTOR TESTE 3337
   _cQry += " A2_CGC, "                  // cpf_cnpj: 349.812.172-34
   _cQry += " A2_INSCR, "                // inscricao_estadual: 170642
   _cQry += " A2_PFISICA, "              // rg_ie: ABC320303
   _cQry += " A2_DTNASC, "               // data_nascimento_fundacao: 1994-10-10
   _cQry += " A2_ENDCOMP, "              // complemento: Complemento Teste
   _cQry += " A2_END, "                  // endereco: Rua Caminho Andante
   _cQry += " A2_BAIRRO, "               // bairro: Bairro Teste
   _cQry += " A2_CEP, "                  // cep: 51462-745
   _cQry += " A2_COD_MUN, "              // id_cidade: 73
   _cQry += " A2_MUN, "                  // municipio
   _cQry += " A2_EST, "                  // estado
   _cQry += " A2_EMAIL, "                // email: TESTE_278363@email.com
   _cQry += " A2_DDD, "                  // DDD
   _cQry += " A2_TEL, "                  // celular1: 95920298034
   _cQry += " A2_LOJA, "                 // Loja_laticinio: TESTE_278363
//---------------------------------------------------------------------------------------
   _cQry += " A2_BANCO, "                // codigo do banco
   _cQry += " A2_AGENCIA, "              // codigo da agencia
   _cQry += " A2_NUMCON, "               // numero da conta
//---------------------------------------------------------------------------------------
   _cQry += " A2_L_FAZEN, "              // nome_propriedade_rural: PROPRIEDADE TESTE 001
   _cQry += " A2_L_NIRF, "               // NIRF: ABC4658
   _cQry += " A2_L_TANQ, "               // id_tipo_tanque: 1
   _cQry += " A2_L_CAPTQ, "              // capacidade_tanque: 720
   _cQry += " A2_L_LATIT, "              // latitude_propriedade: -17.855250
   _cQry += " A2_L_LONGI, "              // longitude_propriedade: -46.223278
   _cQry += " A2_L_FREQU, "              // frequencia_coleta: 17
   _cQry += " A2_L_MARTQ, "              // Marca do Tanque
   _cQry += " A2_L_CAPAC, "              // capacidade_refrigeracao: 307
   _cQry += " A2_L_CLASS, "              // id_tipo_tanque
   _cQry += " A2_L_ATIVO, "              // ativo inativo
   _cQry += " A2_L_SIGSI, "              //
   _cQry += " A2_L_TANLJ, "              //
   _cQry += " A2_L_RESFR, "              //
//----------------------------------------------------------------------------
   _cQry += " A2_L_LI_RO, "              //
   _cQry += " ZL3_DESCRI, "              //
//----------------------------------------------------------------------------
   _cQry += " SA2.R_E_C_N_O_ AS NRREG, "  // capacidade_refrigeracao: 307

//--------------------------------------------------------------------------------
   _cQry += " CASE "
   _cQry += "     WHEN A2_L_CLASS = 'C' THEN 'B' "
   _cQry += "     WHEN A2_L_CLASS = 'U' THEN 'C' "
   _cQry += "     WHEN A2_L_CLASS = 'F' THEN 'D' "
   _cQry += "     ELSE 'A' "
   _cQry += " END AS ORDEMP"
//--------------------------------------------------------------------------------
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZL3") + " ZL3 "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZL3.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZL3_COD = A2_L_LI_RO "
   _cQry += " AND ZL3_FILIAL = '" + _cFilEnvio + "' " // Cada filial/Cnpj Italac possui um Usuário e Senha. Ler do cadastro empresas Webservice. Enviar apenas as filias 01, 04, 23. 01=Corumbaiba/GO, 04=Araguari/MG, 23=Tapejara/RS
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "

   _cQry += " AND A2_COD <> '      ' "

   _cQry += " ORDER BY ORDEMP, A2_COD,A2_LOJA "


   If Select("QRYSA2") > 0
      QRYSA2->(DbCloseArea())
   EndIf

   MPSysOpenQuery( _cQry , "QRYSA2")

   DBSelectArea("QRYSA2")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
   Count to _nTotRegs

   _cCodForn := Space(6)

   ProcRegua(_nTotRegs)

   QRYSA2->(DbGotop())

   SA2->(DbSetOrder(1)) // 1=A2_FILIAL+A2_COD+A2_LOJA

   _nJ := 0

   Do While ! QRYSA2->(Eof())

      _nJ += 1

      IncProc("Processando registros: " + AllTrim(Str(_nJ,10)) + " de " + AllTrim(Str(_nTotRegs,10)))

      If Empty(QRYSA2->A2_COD) // Foi identificado no cadastro de fornecedores alguns registros sem o código preenchido.
         QRYSA2->(DbSkip())
         Loop
      EndIf

      //=================================================================
      // Deve seer enviado apenas os produtores existentes no arquivo da
      // Evomilk.
      //=================================================================
      _nI := Ascan(_aListReenv,{|x| x[1] == QRYSA2->A2_COD .And. x[2] == QRYSA2->A2_LOJA})
      If _nI == 0
         QRYSA2->(DbSkip())
         Loop
      EndIf

      //=============================================================================
      // Posiciona na Tabela SA2
      //=============================================================================
      SA2->(DbGoTo(QRYSA2->NRREG))

      //=============================================================================
      // Grava as tabelas temporárias para envio dos dados
      //=============================================================================
      If _cCodForn <> SA2->A2_COD
         _cCodForn := SA2->A2_COD

         TRBCAB->(DBAPPEND())
         TRBCAB->A2_COD     := SA2->A2_COD            // id_tipo_tanque: 1
         TRBCAB->A2_LOJA    := SA2->A2_LOJA
         TRBCAB->A2_NOME    := SA2->A2_NOME           //C,40  // nome_razao_social  : PRODUTOR TESTE 3337
         TRBCAB->A2_CGC     := SA2->A2_CGC            //C,14  // cpf_cnpj: 349.812.172-34
         TRBCAB->A2_INSCR   := SA2->A2_INSCR          //C,18  // inscricao_estadual: 170642
         TRBCAB->A2_PFISICA := SA2->A2_PFISICA        //C,18  // rg_ie: ABC320303
         TRBCAB->A2_DTNASC  := SA2->A2_DTNASC   //D,8   // data_nascimento_fundacao: 1994-10-10
         TRBCAB->WK_OBSERV  := ""                        //C,100 // info_adicional: Observação / info adicional...
         TRBCAB->A2_ENDCOMP := SA2->A2_ENDCOMP        //C,50  // complemento: Complemento Teste
         TRBCAB->A2_END     := SA2->A2_END            //C,90  // endereco: Rua Caminho Andante
         TRBCAB->WK_NUMERO  := ""                        //C,20  // numero: 429 A
         TRBCAB->A2_BAIRRO  := SA2->A2_BAIRRO         //C,50  // bairro: Bairro Teste
         TRBCAB->A2_CEP     := SA2->A2_CEP            //C,8   // cep: 51462-745
         TRBCAB->WK_ID_UF   := ""                        //C,2   // id_uf: 21
         TRBCAB->A2_COD_MUN := SA2->A2_COD_MUN        //C,5   // id_cidade: 73
         TRBCAB->A2_MUN     := SA2->A2_MUN            // municipio
         TRBCAB->A2_EST     := SA2->A2_EST            // estado
         TRBCAB->A2_BANCO   := SA2->A2_BANCO          // codigo do banco
         TRBCAB->A2_AGENCIA := SA2->A2_AGENCIA        // codigo da agencia
         TRBCAB->A2_NUMCON  := SA2->A2_NUMCON         // numero da conta
         TRBCAB->A2_EMAIL   := SA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
         TRBCAB->A2_TEL     := AllTrim(SA2->A2_DDD)+SA2->A2_TEL //C,50  // celular1: 95920298034
         TRBCAB->A2_TEL2    := ""                        //C,50  // celular2: null
         TRBCAB->A2_TEL3    := ""                        //C,50  // telefone1: 5590038949
         TRBCAB->A2_TEL4    := ""                        //C,50  // telefone2: null
         TRBCAB->A2_TEL1W   := "False"                   //C,50  // celular1_whatsapp: true
         TRBCAB->A2_TEL2W   := "False"                   //C,50  // celular2_whatsapp: false
         TRBCAB->WK_RECNO   := SA2->(Recno())            //N,10 ,0 // Nr Recno SA2
         TRBCAB->WK_ORDEMP  := "C"   //QRYSA2->ORDEMP    // Ordenação dos dados para envio
         TRBCAB->(MsUnlock())

      EndIf

      TRBDET->(DbAppend())
      TRBDET->A2_COD     := SA2->A2_COD  // SA2->A2_L_TANQ      // SA2->A2_COD         //C,6     // matricula_laticinio: TESTE_278363
      TRBDET->A2_LOJA    := SA2->A2_LOJA // SA2->A2_L_TANLJ     // SA2->A2_LOJA        //C,4     // Loja_laticinio: TESTE_278363
      TRBDET->A2_CGC     := SA2->A2_CGC         //C,14    // cpf_cnpj: 349.812.172-34
      TRBDET->A2_L_FAZEN := SA2->A2_L_FAZEN     //C,40    // nome_propriedade_rural: PROPRIEDADE TESTE 001
      TRBDET->A2_L_NIRF  := SA2->A2_L_NIRF      //C,11    // NIRF: ABC4658
      TRBDET->A2_L_TANQ  := SA2->A2_L_TANQ      //C,10    // id_tipo_tanque: 1
      TRBDET->A2_L_CAPTQ := SA2->A2_L_CAPTQ     //N,11    // capacidade_tanque: 720
      TRBDET->A2_L_LATIT := SA2->A2_L_LATIT     //N,10 ,6 // latitude_propriedade: -17.855250
      TRBDET->A2_L_LONGI := SA2->A2_L_LONGI     //N,10 ,6 // longitude_propriedade: -46.223278
      TRBDET->A2_L_MARTQ := SA2->A2_L_MARTQ     //C,20    // id_tipo_tanque: // Marca do tanque
      TRBDET->A2_L_CLASS := SA2->A2_L_CLASS     //C,01    // id_tipo_tanque:
      TRBDET->WK_AREA    := 0                      //N,12 ,6 // area: 2000.15
      TRBDET->WK_RECRIA  := ""                     //C,10    // recria: 1
      TRBDET->WK_VACASEC := ""                     //C,10    // vaca_seca: 12
      TRBDET->WK_VACALAC := ""                     //C,10    // vaca_lactacao: 6
      TRBDET->WK_HORACOL := ""                     //C,10    // horario_coleta: 23:59
      TRBDET->WK_RACAPRO := ""                     //C,50    // raca_propriedade: Nome Raça predominante Teste
      TRBDET->A2_L_FREQU := SA2->A2_L_FREQU     //C,10    // frequencia_coleta: 17
      TRBDET->WK_PRDDIAR := 0                      //N,10 ,2 // fproducao_media_diaria: 7251.31
      TRBDET->WK_AREAUTI := 0                      //N,10 ,2 // area_utilizada_producao: 837.84
      TRBDET->A2_L_CAPAC := SA2->A2_L_CAPAC        //N,10 ,2 // capacidade_refrigeracao: 307
      TRBDET->WK_RECNO   := SA2->(Recno())             //N,10 ,0 // Nr Recno SA2
      TRBDET->WK_ORDEMP  := "C"   //QRYSA2->ORDEMP    // Ordenação dos dados para envio
      //-------------------------------------------------------
      TRBDET->A2_L_LI_RO := SA2->A2_L_LI_RO        //        codigo_linha_laticinio
      TRBDET->ZL3_DESCRI := QRYSA2->ZL3_DESCRI     //        nome_linha
      TRBDET->A2_L_ATIVO := If(SA2->A2_L_ATIVO=="N","false","true") // _cSituacao
      TRBDET->A2_L_SIGSI := SA2->A2_L_SIGSI        // _cSigSif
      TRBDET->A2_L_TANLJ := SA2->A2_L_TANLJ        // Loja tanque
      TRBDET->A2_L_RESFR := SA2->A2_L_RESFR        // _cTipoResf
      //-------------------------------------------------------
      TRBDET->A2_ENDCOMP := SA2->A2_ENDCOMP        //C,50  // complemento: Complemento Teste
      TRBDET->A2_END     := SA2->A2_END            //C,90  // endereco: Rua Caminho Andante
      TRBDET->WK_NUMERO  := ""                        //C,20  // numero: 429 A
      TRBDET->A2_BAIRRO  := SA2->A2_BAIRRO         //C,50  // bairro: Bairro Teste
      TRBDET->A2_CEP     := SA2->A2_CEP            //C,8   // cep: 51462-74
      TRBDET->A2_COD_MUN := SA2->A2_COD_MUN        //C,5   // id_cidade: 73
      TRBDET->A2_MUN     := SA2->A2_MUN            // municipio
      TRBDET->A2_EST     := SA2->A2_EST            // estado
      TRBDET->A2_EMAIL   := SA2->A2_EMAIL          //C,100 // email: TESTE_278363@email.com
      TRBDET->A2_TEL     := AllTrim(SA2->A2_DDD)+SA2->A2_TEL //C,50  // celular1: 95920298034

      TRBDET->(MsUnlock())

      _lHaDadosP := .T.

      QRYSA2->(DbSkip())

   EndDo

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32UP
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Envio de dados das Alterações Produtores Rurais de Associação ou Cooperativas via WebService.
                     Italac para Sistema Evomilk
===============================================================================================================================
Parametros--------: _cChamada = "M" = Rotina Chamada via menu.
                                "S" = Rotina Chamada via Scheduller
                    _cOpcao   = "INCASS" = Roda a integração de Inclusão de produtores Associação/Cooperativa no App Cia leite.

===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================

User Function MGLT32UP(_cChamada,_cOpcao)
Local _cRodaPe // _cCabec, _cDetalhe, _cAssociac
Local _cItens //, _cEnvio
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cJSonProd, _cJSonGrp
Local _cHoraIni, _cHoraFin, _cMinutos, _nMinutos
//Local _nTotRegEnv := 1 // 100  // Total de registros para envio.
//Local _nI , _oRetJSon, _lResult := .F.
Local _aProdEnv
Local _aHeadOut := {}
//Local _aRecnoSA2, _cRetorno, _nX
Local _cClasParc
Local _cLinkAss
Local _cLinkSoc
Local _nI
Local _aCabMail, _cCabMail, _cCabJson, _nY
Local _aDetMail, _cDetMail, _cDetJson
Local _cTenantid := SUPERGETMV('IT_TENAIDE',.F., "LATITATE1")

//------------------------------------------------------------------------------------------//
            // Cabeçalho
Private _cIdProdut := ""
Private _cMatLatic := ""   //            matricula_laticinio
Private _cRazaoSoc := ""   //            nome_razao_social
Private _cCpf_Cnpj := ""   //            cpf_cnpj
Private _cInscrEst := ""   //            inscricao_estadual
Private _cRg_IE    := ""   //            rg_ie
Private _cDtNascF  := ""   //            data_nascimento_fundacao
Private _cObserv   := ""   //            info_adicional
Private _cComplem  := ""   //            complemento
Private _cEndereco := ""   //            endereco
Private _cNrEnd    := ""   //            numero
Private _cBairro   := ""   //            bairro
Private _cCep      := ""   //            cep
Private _cIdUF     := ""   //            id_uf
Private _cIDCidade := ""   //            id_cidade
//--------------------------------------------------------------------//
Private _cCodBanco := ""   //            Codigo do Banco
Private _cCodAgenc := ""   //            Codigo da Agencia
Private _cNumConta := ""   //            Numero da Conta
//--------------------------------------------------------------------//
Private _cEMail    := ""   //            email
Private _cCelular  := ""   //            celular1
Private _cCelula2  := ""   //            celular2
Private _cTelefon1 := ""   //            telefone1
Private _cTelefon2 := ""   //            telefone2
Private _cWhatsAp1 := ""   //            celular1_whatsapp
Private _cWhatsAp2 := ""   //            celular2_whatsapp

            // Detalhe
Private _cNomeProp  := ""  //           nome_propriedade_rural
Private _cNIRF      := ""  //           NIRF
Private _cTipoTanq  := ""  //           id_tipo_tanque
Private _cCapacTnq  := ""  //           capacidade_tanque
Private _cLatitude  := ""  //           latitude_propriedade
Private _cLongitud  := ""  //           longitude_propriedade
Private _cArea      := ""  //           area
Private _cRecria    := ""  //           recria
Private _cVacaSeca  := ""  //           vaca_seca
Private _cVacaLacta := ""  //           vaca_lactacao
Private _cHoraCole  := ""  //           horario_coleta
Private _cRacaProp  := ""  //           raca_propriedade
Private _cFreqCol   := ""  //           frequencia_coleta
Private _cProdDia   := ""  //           producao_media_diaria
Private _cAreaUti   := ""  //           area_utilizada_producao
Private _cCapacRef  := ""  //           capacidade_refrigeracao
Private _cCodPropr  := ""  //           codigo_propriedade_laticinio
Private _cCodLinha  := ""  //           codigo_linha_laticinio
Private _cDescLin   := ""  //           nome_linha

//-------------------------------------------------------------------//
Private _cSituacao  := ""
Private _cCidade    := ""
Private _cUF        := ""
Private _cCod_Ibge  := ""
Private _cSigSif   := ""
Private _cCodPropL := ""
Private _cCodigotq := ""
Private _cTipoResf := ""
Private _cMarcaTanq:= ""

Private _cCPFCnpjP := ""
Private _cMatParce := ""

//=========================================================================
// Nova Tags
//=========================================================================
Private _cTitTanq  := ""    // cpf_cnpj
Private _cMatrLat  := ""    // matricula_laticinio
Private _cTelPrinc := "SIM" // telefone_principal
Private _cEMailPri := "SIM" // email_principal
Private _cSitTnq   := ""    // situacao
Private _CSITPROP  := ""    // Situação Proprietario
Private _CCLASPROP := ""    // Classificação Proprietári do Tanque
Private _CNOMETNQ  := ""    // Nome do Tanque
Private _cNomBanco := ""    // Nome do Banco
Private _cTitConta := ""
Private _cInfoAdic := ""
Private _CDataCad  := ""
Private _cHoraCad  := ""
//---------------------------------------------------------
Private _cComplemD := ""   //            complemento
Private _cEnderecD := ""   //            endereco
Private _cNrEndD   := ""   //            numero
Private _cBairroD  := ""   //            bairro
Private _cCepD     := ""   //            cep
Private _cIdUFD    := ""   //            id_uf
Private _cIDCidadD := ""   //            id_cidade
Private _cEMailD   := ""   //            email 2
Private _cTelefonD := ""   //            Telefone demais propriedades
//---------------------------------------------------------
Private _oFWRITER
//---------------------------------------------------------
Private _cVincLat           // Código do Laticinio Associação/Cooperativa ao qual o Cooperado pertence.
//---------------------------------------------------------
Private _cTipoLat   := "ASSOCIACAO"
Private _aRecnoSA2  := {}

Private _cNomRespL := ""
Private _cTelRespL := ""
Private _cEmaRespL := ""

Private _cNomRespP := ""
Private _cTelRespP := ""
Private _cEmaRespP := ""


//---------------------------------------------------------

Default _cChamada := "M"
Default _cOpcao   := "I"

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _LinkCerto := AllTrim(ZFM->ZFM_HOMEPG)
      If _cOpcao == "INCASS"
         _cLinkAss := AllTrim(ZFM->ZFM_LINK05)  // Link de envio de inclusão de Associação / Cooperativa
         _cLinkSoc := AllTrim(ZFM->ZFM_LINK06)  // Link de envio de inclusão de Associados / Cooperados
      Else
         _cLinkAss := AllTrim(ZFM->ZFM_LINK05)  // Link de envio de alteração de Associação / Cooperativas
         _cLinkSoc := AllTrim(ZFM->ZFM_LINK06)  // Link de envio de alteração de Associados / Cooperados
      EndIf
      IF !EMPTY(AllTrim(ZFM->ZFM_LINK10))
         _cTenantid:= AllTrim(ZFM->ZFM_LINK10)
      ENDIF
   Else
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   If Empty(_cDirJSon)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON Associação/Cooperativa e os transforma em String.
   //================================================================================
   _cAssoc_A := U_MGLT032X(_cDirJSon+"ASSOCIACAO_COOPERATIVA_CIA_LEITE_PRODUTOR_A.txt")
   If Empty(_cAssoc_A)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (A) associação/cooperativa integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cAssoc_B:= U_MGLT032X(_cDirJSon+"ASSOCIACAO_COOPERATIVA_CIA_LEITE_PRODUTOR_B.txt")
   If Empty(_cAssoc_B)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (B) associação/cooperativa integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cAssoc_C := U_MGLT032X(_cDirJSon+"ASSOCIACAO_COOPERATIVA_CIA_LEITE_PRODUTOR_C.txt")
   If Empty(_cAssoc_C)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (C) associação/cooperativa integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf


   //================================================================================
   // Lê os arquivos modelo JSON Associado/Cooperado e os transforma em String.
   //================================================================================
   _cCabec_A := U_MGLT032X(_cDirJSon+"Cabec_CIA_LEITE_PRODUTOR_ASSOCIADO_A.txt")
   If Empty(_cCabec_A)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (A) associado/cooperado integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cCabec_B := U_MGLT032X(_cDirJSon+"Cabec_CIA_LEITE_PRODUTOR_ASSOCIADO_B.txt")
   If Empty(_cCabec_B)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (B) associado/cooperado integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cCabec_C := U_MGLT032X(_cDirJSon+"Cabec_CIA_LEITE_PRODUTOR_ASSOCIADO_C.txt")
   If Empty(_cCabec_C)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON modelo do cabeçalho (C) associado/cooperado integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDetalheA := U_MGLT032X(_cDirJSon+"Detalhe_CIA_LEITE_PRODUTOR_ASSOCIADO_A.txt")

   If Empty(_cDetalheA)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON detalhe (A) Propriedades produtor rural associado/cooperado.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDetalheB := U_MGLT032X(_cDirJSon+"Detalhe_CIA_LEITE_PRODUTOR_ASSOCIADO_B.txt")

   If Empty(_cDetalheB)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON detalhe (B) Propriedades produtor rural associado/cooperado.","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDetalheC := U_MGLT032X(_cDirJSon+"Detalhe_CIA_LEITE_PRODUTOR_ASSOCIADO_C.txt")

   If Empty(_cDetalheC)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON detalhe (C) Propriedades produtor rural associado/cooperado.","Atenção",,1)
      EndIf

      Break
   EndIf

   //========================================================================================
   _cRodape := U_MGLT032X(_cDirJSon+"Rodape_CIA_LEITE_PRODUTOR_ASSOCIADO.txt")
   If Empty(_cRodape)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Rodape Produtor Rural associado/cooperado Integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   //==========================================================
   // Obtem o Token de Integração com a Evomilk
   //==========================================================
   _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

   If Empty(_cKey)
      If _cChamada == "M" // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores Associação/Cooperativa cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   _cHoraIni := Time() // Horario Inicial de Processamento

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

   _cJSonProd := "["
   _cJSonGrp := ""
   _nI := 1

   //U_MGLT032G("","","",.T., .F.) // Abre arquivo // Grava Arquivo Texto com os retornos de erro/rejeições.

   _aProdEnv := {}

   TRBCAB->(DbSetOrder(3)) // {"WK_ORDEMP","A2_COD","A2_LOJA"}
   TRBDET->(DbSetOrder(1))

   TRBDET->(DbGoTop())
   Do While ! TRBDET->(Eof())

      TRBCAB->(DbGoto(TRBDET->WK_REGCAB))

      //====================================================================
      // Calcula o tempo decorrido para obtenção de um novo Token
      //====================================================================
      _cHoraFin := Time()
      _cMinutos := ElapTime (_cHoraIni , _cHoraFin)
      _nMinutos := Val(SubStr(_cMinutos,4,2))
      If _nMinutos > 5 // 28 //  minutos
         _cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.

         If Empty(_cKey)
            If _cChamada == "M" // Chamada via menu.
               U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Produtores Associação/Cooperativa cancelada.","Atenção",,1)
            EndIf

            Break
         EndIf

         _aHeadOut := {}
         Aadd(_aHeadOut,'Accept: application/json')
         Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
         Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

         _cHoraIni := Time()

      EndIf

      //====================================================================
      // Efetua a leitura dos dados para montagem do JSON.
      //====================================================================
      _cItens := ""
      _cIdProdut := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA
      _cMatLatic := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA          //            matricula_laticinio
      _cRazaoSoc := TRBCAB->A2_NOME                             //            nome_razao_social
      _cCpf_Cnpj := TRBCAB->A2_CGC                              //            cpf_cnpj
      _cInscrEst := TRBCAB->A2_INSCR                            //            inscricao_estadual
      _cRg_IE    := TRBCAB->A2_PFISICA                          //            rg_ie
      _cDtNascF  := StrZero(Year(TRBCAB->A2_DTNASC),4)+"-"+StrZero(Month(TRBCAB->A2_DTNASC),2)+"-"+StrZero(Day(TRBCAB->A2_DTNASC),2)   //            data_nascimento_fundacao
      _cObserv   := ""                                          //            info_adicional
      _cComplem  := TRBCAB->A2_ENDCOMP                          //            complemento
      _cEndereco := TRBCAB->A2_END                              //            endereco
      _cNrEnd    := ""                                          //            numero
      _cBairro   := TRBCAB->A2_BAIRRO                           //            bairro
      _cCep      := TRBCAB->A2_CEP                              //            cep
      _cIdUF     := ""                                          //            id_uf
      _cIDCidade := ""                                          //            id_cidade
      _cCidade   := AllTrim(TRBCAB->A2_MUN)                     //            municipio
      _cUF       := AllTrim(TRBCAB->A2_EST)                     //            estado
      _cCod_Ibge := TRBCAB->A2_COD_MUN                          //            codigo_ibge"
//---------------------------------------------------------------------------------------------------
      _cCodBanco := AllTrim(TRBCAB->A2_BANCO)                   //            Codigo do Banco
      _cCodAgenc := AllTrim(TRBCAB->A2_AGENCIA)                 //            Codigo da Agencia
      _cNumConta := AllTrim(TRBCAB->A2_NUMCON)                  //            Numero da Conta
      _cNomBanco := AllTrim(POSICIONE('SA6',1,xFilial('SA6')+_cCodBanco,'A6_NOME'))
      _cTitConta := TRBCAB->A2_NOME
      _cInfoAdic := ""
//---------------------------------------------------------------------------------------------------
      _cEMail    := TRBCAB->A2_EMAIL            //            email
      _cCelular  := ""                          //            celular1
      _cCelula2  := ""                          //            celular2
      _cTelefon1 := TRBCAB->A2_TEL              //            telefone1

      If Empty(_cTelefon1)
         _cTelefon1 := "null"
      Else
         _cTelefon1 := '"' +AllTrim(_cTelefon1)  + '"'
      EndIf

      _cTelefon2 := ""                          //            telefone2
      //_cWhatsAp1 := "SIM"                       //            celular1_whatsapp
      _cWhatsAp1 := "NAO"                     //            celular2_whatsapp

      //_cVincLat  := "" // TRBCAB->A2_CGC              // Código da Associação/Cooperativa ao qual o cooperado pertence.
      //===========================================================
      // Define o CNPJ da unidade para a tag vinculado_ao_laticinio
      //===========================================================
      _cVincLat  := _cUnidVinc // Unidade na qual os produtores e coletas estão vinculados // SM0->M0_CGC
      //-----------------------------------------------------------

      _cNomRespL := TRBCAB->A2_NOME
      _cTelRespL := TRBCAB->A2_TEL
      _cEmaRespL := TRBCAB->A2_EMAIL
      _cTipoLat  := "ASSOCIACAO"
      _cSituacao := TRBCAB->A2_L_ATIVO
      _aRecnoSA2  := {}  // Array com os dados para atualização do cadastro de produtores como já enviados.

      //=======================================================================================
      // Este trecho trata os varios e-mails de um campo e envia um a um em campos diferentes.
      //=======================================================================================
      _cEMail := AllTrim(StrTran(_cEMail,",",";"))
      _aCabMail  := U_ITTXTARRAY(_cEMail,";",10)

      _cCabMail := ""
      _cCabJson := ""
      _cEMailPri := "SIM"

      If Len(_aCabMail) > 0
         For _nY := 1 To Len(_aCabMail)
             _cEMail   := StrTran(_aCabMail[_nY],";","")
             _cCabJson := &(_cAssoc_B)
             _cCabMail += If(!Empty(_cCabMail),",","") + _cCabJson
             _cEMailPri := "NAO"
         Next
      Else
         _cCabJson := &(_cAssoc_B)
         _cCabMail += If(!Empty(_cCabMail),",","") + _cCabJson
      EndIf

      //==========================================================================================

      If TRBCAB->A2_L_TPASS == "A" // Associação
         //=================================================================
         // Integra para a Evomilk o JSon da Associação / Cooperativa
         //=================================================================
         //_cJSonEnv := &(_cAssociac)
         _cJSonEnv := &(_cAssoc_A) + _cCabMail + &(_cAssoc_C)

         MGLT32ENVA(_cJSonEnv, _cLinkAss ,_aHeadOut , TRBCAB->WK_RECNO,"A")

         TRBDET->(DbSkip()) // Não foi possível incluir o primeiro registro. A Associação / cooperativa.
         Loop // Portanto, os associados/cooperados também não poderão ser incluidos. Deve-se seguir a sequencia.
      EndIf

      //=================================================================
      // Integra para a Evomilk os JSon dos Associcados / Cooperados
      //=================================================================
      _cVincLat  := TRBCAB->A2_CGC     // Código da Associação/Cooperativa ao qual o cooperado pertence.
      _cTipoLat   := "ASSOCIACAO"

      If TRBDET->A2_L_TPASS == "A" // Associação
         TRBDET->(DbSkip())
         Loop
      EndIf

      _cCodPropr  := ""                                    //           codigo_propriedade_laticinio
      _cNomeProp  := TRBDET->A2_L_FAZEN                    //           nome_propriedade_rural
      _cNIRF      := TRBDET->A2_L_NIRF                     //           NIRF
      //_cTipoTanq  := ""                                  //           id_tipo_tanque  // A2_L_TANQ // tipo_tanque // A2_L_MARTQ

      _cCodPropL  := TRBDET->A2_COD+"-"+TRBDET->A2_LOJA
      _cMatLatic  := TRBDET->A2_COD+"-"+TRBDET->A2_LOJA    // TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA//            matricula_laticinio

      _cTipoTanq  := "INDIVIDUAL"
      _CCLASPROP  := "PRODUTOR INDIVIDUAL"

      _cMatrLat   := ""
      _cTitTanq   := ""
      //_cMatrLat   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
      //_cTitTanq   := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // // CPF_CNPJ do Titular do Tanque
      _cMatParce  := ""
      _cCPFCnpjP  := ""
      _cCidade    := AllTrim(TRBDET->A2_MUN)      // municipio
      _cUF        := + AllTrim(TRBDET->A2_EST)    // estado

      If TRBDET->A2_L_CLASS == "C"
         _cTipoTanq  := "COLETIVO"
         _CCLASPROP  := "TITULAR DE TANQUE COMUNITARIO"
      ElseIf TRBDET->A2_L_CLASS == "U"
         _CCLASPROP  := "USUARIO DE TANQUE COMUNITARIO"
         _cTipoTanq  := "COLETIVO"
         //_cMatrLat   := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // // CPF_CNPJ do Titular do Tanque
         //_cTitTanq   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         _cMatrLat   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         _cTitTanq   := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
//----------------------------------------------------------
         _cClasParc  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_L_CLASS') // Classificação do Titular do Tanque
         If AllTrim(_cClasParc) == "F"
            _cCPFCnpjP  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
            _cMatParce  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
         EndIf
//----------------------------------------------------------
      ElseIf TRBDET->A2_L_CLASS == "F"
         _cTipoTanq  := "FAMILIAR" //"INDIVIDUAL"
         _CCLASPROP  := "TITULAR DE TANQUE COMUNITARIO" // "PRODUTOR INDIVIDUAL"
         //_cCPFCnpjP  := POSICIONE('SA2',1,xFilial('SA2')+TRBDET->A2_L_TANQ+TRBDET->A2_L_TANLJ,'A2_CGC') // CPF_CNPJ do Titular do Tanque
         //_cMatParce  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
      EndIf

      If ! Empty(_cCPFCnpjP) .And. AllTrim(_cCPFCnpjP) == AllTrim(_cCpf_Cnpj)
         _cCPFCnpjP := ""
         _cMatParce := ""
      EndIf

      _CNOMETNQ   := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ //        Nome do Tanque
      _cCapacTnq  := AllTrim(Str(TRBDET->A2_L_CAPTQ,11))   //           capacidade_tanque
      _cLatitude  := AllTrim(Str(TRBDET->A2_L_LATIT,18,6)) //           latitude_propriedade
      _cLongitud  := AllTrim(Str(TRBDET->A2_L_LONGI,18,6)) //           longitude_propriedade
      _cArea      := ""                                    //           area
      _cRecria    := ""                                    //           recria
      _cVacaSeca  := ""                                    //           vaca_seca
      _cVacaLacta := ""                                    //           vaca_lactacao
      _cHoraCole  := ""                                    //           horario_coleta
      _cRacaProp  := ""                                    //           raca_propriedade
      //_cFreqCol   := TRBDET->A2_L_FREQU                  //           frequencia_coleta

      If TRBDET->A2_L_FREQU == "1"
         _cFreqCol   := "48"                               //           frequencia_coleta
      Else
         _cFreqCol   := "24"
      EndIf

      _cProdDia   := ""                                    //           producao_media_diaria
      _cAreaUti   := ""                                    //           area_utilizada_producao
      _cCapacRef  := ""                                    //           capacidade_refrigeracao
      //Cap. Resfri.	Capacidade Resfriamento	0=Nenhuma	2=Duas Ordenhas	4=Quatro Ordenhas

      If TRBDET->A2_L_CAPAC == "0"
         _cCapacRef  := "Nenhuma"
      ElseIf TRBDET->A2_L_CAPAC == "2"
         _cCapacRef  := "Duas Ordenhas"
      ElseIf TRBDET->A2_L_CAPAC == "4"
         _cCapacRef  := "Quatro Ordenhas"
      EndIf

      If Empty(_cCapacRef)
         _cCapacRef := "nenhuma"
      EndIf

      _cSituacao  := TRBDET->A2_L_ATIVO
      _cSitTnq    := TRBDET->A2_L_ATIVO
      _CSITPROP   := TRBDET->A2_L_ATIVO
      _cSigSif    := TRBDET->A2_L_SIGSI
      _cCodigotq  := TRBDET->A2_L_TANQ+"-"+TRBDET->A2_L_TANLJ
      _cTipoResf  := If(TRBDET->A2_L_RESFR == "E","EXPANSAO","IMERSAO")
      _cMarcaTanq := TRBDET->A2_L_MARTQ
      _cCodLinha  := TRBDET->A2_L_LI_RO   //           codigo_linha_laticinio
      _cDescLin   := TRBDET->ZL3_DESCRI   //           nome_linha

      _cComplemD  := TRBDET->A2_ENDCOMP          //            complemento
      _cEnderecD  := TRBDET->A2_END              //            endereco
      _cNrEndD    := ""                          //            numero
      _cBairroD   := TRBDET->A2_BAIRRO           //            bairro
      _cCepD      := TRBDET->A2_CEP              //            cep
      _cIDCidadD  := ""                          //            id_cidade
      _cCidUFD    := AllTrim(TRBDET->A2_MUN) + "\/" + AllTrim(TRBDET->A2_EST)             // municipio  // estado
      _cCodIbgeD  := TRBDET->A2_COD_MUN          //           codigo_ibge"
      _cEMailD    := TRBDET->A2_EMAIL            //            email
      _cTelefonD  := TRBDET->A2_TEL

      //----------------------------------
      _cRazaoSoc := TRBDET->A2_L_NATRA
      _cCpf_Cnpj := ""
      _cInscrEst := ""
      _cRg_IE    := ""
      _cDtNascF  := ""
      _cObserv   := ""
      _cComplem  := ""
      _cEndereco := ""
      _cNrEnd    := ""
      _cBairro   := ""
      _cCep      := ""
      //----------------------------------
      _cComplemD := ""
      _cEnderecD := ""
      _cNrEndD   := ""
      _cBairroD  := ""
      _cCepD     := ""

      //=======================================================================================
      // Este trecho trata os varios e-mails de um campo e envia um a um em campos diferentes.
      //=======================================================================================
      _cEMailD    := AllTrim(StrTran(_cEMailD,",",";"))
      _aDetMail   := U_ITTXTARRAY(_cEMailD,";",10)

      _cDetMail := ""
      _cDetJson := ""

      If Len(_aDetMail) > 0
         For _nY := 1 To Len(_aDetMail)
             _cEMailD  := StrTran(_aDetMail[_nY],";","")
             _cDetJson := &(_cDetalheB)
             _cDetMail += If(!Empty(_cDetMail),",","") + _cDetJson
         Next
      Else
         _cDetJson := &(_cDetalheB)
         _cDetMail += If(!Empty(_cDetMail),",","") + _cDetJson
      EndIf

      _cItens += If(!Empty(_cItens),",","") + &(_cDetalheA) + _cDetMail + &(_cDetalheC)

      //_cItens += If(!Empty(_cItens),",","") + &(_cDetalhe)

      _CDataCad  := Dtoc(Date())
      _cHoraCad  := Time()

      //_cJSonEnv := &(_cCabec) + _cItens + _cRodape
      _cJSonEnv := &(_cCabec_A) + _cCabMail + &(_cCabec_C) + _cItens + _cRodape

      MGLT32ENVA(_cJSonEnv, _cLinkSoc ,_aHeadOut , TRBDET->WK_RECNO, "C")

      _cItens := ""

      TRBDET->(DbSkip())

   EndDo

   //=====================================================================
   // Atualiza cadastro de produtores como já enviados para Evomilk.
   //=====================================================================
   If Len(_aRecnoSA2) > 0 // 1 // Significa que foi integrado com sucesso uma Associação / Cooperativa com sucesso.

      For _nI := 1 To Len(_aRecnoSA2)
          //SA2->(DbGoto(_aRecnoSA2[_nI,1]))
          //SA2->(RecLock("SA2", .F.))
          //SA2->A2_L_ENVEV := "N"
          //If Empty(SA2->A2_L_ITCOL)
          //   SA2->A2_L_ITCOL := "S"
          //EndIf
          //SA2->A2_L_ENVAT := "N"
          //SA2->A2_L_TPASS := _aRecnoSA2[_nI,2]
          //SA2->(MsUnLock())
      Next

   EndIf

End Sequence

Return Nil*/

/*
===============================================================================================================================
Função-------------: MGLT32CL
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo TXT com os dados das Coletas Integradas Aceitas ou Rejeitadas, por filial.
===============================================================================================================================
Parametros---------: _cSituacao = Status da Coleta "A" = Aceita / "R" = Rejeitadas
===============================================================================================================================
Retorno------------: Nenhum
==============================================================================================================================

User Function MGLT32CL(_cSituacao)
Local _cQry
Local _aFilSA2 := {}

Private _nTotRegs := 0

Default _cSituacao := "R"

Begin Sequence
   //==========================================================================
   // Gera arquivo TXT com os Dados dos Volumes coletados
   //==========================================================================
   Aadd(_aFilSA2, { "01","CORUMBAIBA"})
   Aadd(_aFilSA2, { "04","ARAGUARI"})
   Aadd(_aFilSA2, { "23","TAPEJARA"})
   Aadd(_aFilSA2, { "40","TRES_CORACOES"})
   Aadd(_aFilSA2, { "24","CRISSIUMAL"})
   Aadd(_aFilSA2, { "25","GIRUA"})
   Aadd(_aFilSA2, { "09","IPORA"})
   Aadd(_aFilSA2, { "02","ITAPACI"})
   Aadd(_aFilSA2, { "10","JARU"})
   Aadd(_aFilSA2, { "11","NOVA_MAMORE"})
   Aadd(_aFilSA2, { "20","PASSO_FUNDO"})
   Aadd(_aFilSA2, { "06","PONTALINA"})
   Aadd(_aFilSA2, { "0B","QUIRINOPOLIS"})
   Aadd(_aFilSA2, { "93","PARANA_CASCAVEL"})
   Aadd(_aFilSA2, { "31","CONCEICAO_DO_ARAGUAIA"})
   Aadd(_aFilSA2, { "32","COUTO_DE_MAGALHAES"})

   _cQry := " SELECT ZBI_FILIAL, ZBI_CODPRO, ZBI_LOJPRO, ZBI.R_E_C_N_O_ REGZBI , SA2.R_E_C_N_O_ REGSA2 "
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZBI") + " ZBI "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZBI.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZBI_CODPRO = A2_COD AND ZBI_LOJPRO = A2_LOJA "
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_COD <> '      ' "
   _cQry += " AND ZBI_STATUS = '"+ _cSituacao + "' "
   _cQry += " AND A2_L_ENVEV = 'N' "
   //_cQry += " AND A2_L_TPASS <> ' ' "
   //_cQry += " AND A2_L_NFPRO = 'S' "
   // MV_PAR01 //  ZBI_DTENV

   If ! Empty(MV_PAR01)
      _cQry += " AND ZBI_DTENV >= '"+Dtos(MV_PAR01)+"' "
   EndIf

   If ! Empty(MV_PAR02)
      _cQry += " AND ZBI_DTENV <= '"+Dtos(MV_PAR02)+"' "
   EndIf

   _cQry += " ORDER BY ZBI_FILIAL, ZBI_CODPRO, ZBI_LOJPRO "

    If Select("QRYZBI") > 0
       QRYZBI->(DbCloseArea())
    EndIf

    MPSysOpenQuery( _cQry , "QRYZBI")

    QRYZBI->(DbGotop())

    DBSelectArea("QRYZBI")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
    Count to _nTotRegs

    QRYZBI->(DbGotop())

    Processa( {|| U_MGLT32IC(_aFilSA2,_nTotRegs,_cSituacao) } , 'Aguarde!' , 'Gravando Arquivo Texto das Coletas...' )

    U_ItMsg("Geração de arquivo TXT com os dados das Coletas concluido.","Atenção",,2)

End Sequence

If Select("QRYZBI") > 0
   QRYZBI->(DbCloseArea())
EndIf

Return Nil  */

/*
===============================================================================================================================
Função-------------: MGLT32IC
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de geração de arquivo TxT das Coletas das Associações Rejeitadas.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================

User Function MGLT32IC(_aFilSA2,_nTotRegs,_cSituacao)
Local _cDados
Local _nJ //  _nI,
Local _cRetApp

Default _cSituacao := "R"

Begin Sequence

   ProcRegua(_nTotRegs)

   _cDirTXT := AllTrim(GetTempPath()) // "\data\Italac\CiaLeite\"//GetTempPath() //"\DATA\JULIO\"
   If _cSituacao == "R"
      _cNomeArq:= "Dados_das_Coletas_Rejeitadas_nas_Integracoes" + Dtos(Date()) + ".Txt"
   Else
      _cNomeArq:= "Dados_das_Coletas_Aceitas_nas_Integracoes" + Dtos(Date()) + ".Txt"
   EndIf

   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados das coletaas Integradas.","Atenção",,1)
      Break
   EndIf

   _oFWriter:Write("UNIDADE;MATRICULA;CPF;NOME;RETORNO_APP;JSON_ENVIO;" + CRLF)

   QRYZBI->(DbGoTop())

   _nJ := 1

   _oFWriter:Write("[")

   Do While ! QRYZBI->(Eof())

      IncProc("Gerando arquivo texto: "+ StrZero(_nJ,6) + " de " + StrZero(_nTotRegs,6) + "...")
      _nJ += 1

      SA2->(DbGoto(QRYZBI->REGSA2))
      ZBI->(DbGoto(QRYZBI->REGZBI))

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================
      _nI := AsCan(_aFilSA2,{|x| x[1] == QRYZBI->ZBI_FILIAL})
      _cDados := _aFilSA2[_nI,2] + ";"
      _cDados += SA2->A2_COD + "-" + SA2->A2_LOJA+";"
      _cDados += AllTrim(SA2->A2_CGC) +";"
      _cDados += AllTrim(SA2->A2_L_NATRA) + ";"
      _cRetApp := StrTran(ZBI->ZBI_MOTIVO,Char(10)," ")
      _cDados += AllTrim(_cRetApp) + ";"
      _cDados += AllTrim(ZBI->ZBI_JSONEN)
      //_cDados := AllTrim(ZBI->ZBI_JSONEN)
      _cDados += CRLF

      _oFWriter:Write(_cDados)

      QRYZBI->(DbSkip())
   EndDo

   _oFWriter:Write("]")

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence

Return Nil */

/*
===============================================================================================================================
Função-------------: MGLT32OM
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Roda as rotinas selecionadas pelo usuário no menu do fonte AGLT054.
===============================================================================================================================
Parametros---------: _cOpcaoM = Opção de menu a ser rodada.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32OM(_cOpcaoM)

Local _aParaux   := {}
Local _aParRet   := {}
Local _cTxtMsg   := ""
Local _cCodUser  := ""

Private _lHaDadosP := .F. // Indica se há dados dos produtores para Integração.
Private _nTotRegs  := 0
Private _cUnidVinc := SM0->M0_CGC // Unidade na qual os produtores e coletas estão vinculados.
Private _lJaTemAss := .F.
Private _lEfetivaEnvio:=!SuperGetMV("IT_AMBTEST",.F.,.T.) .OR. FWGetRunSchedule()

Begin Sequence

   If _cOpcaoM == "A"     // 'Gera Arq.Txt Produtores Ativos/Inativos'                  // 'U_MGLT32OM("A")' OPERATION 2 ACCESS 0
      _cTxtMsg   := 'Gera Arq.Txt Produtores Ativos/Inativos'
   ElseIf _cOpcaoM =="B"  // 'Gera Arq.Txt Produtores Usuarios Tanques Col.'            // 'U_MGLT32OM("B")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "'Gera Arq.Txt Produtores Usuarios Tanques Col.'"
   ElseIf _cOpcaoM == "C" // 'Gera Arq.Txt Produtores Mais de Uma Propriedade'          // 'U_MGLT32OM("C")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "Gera Arq.Txt Produtores Mais de Uma Propriedade"
   ElseIf _cOpcaoM == "D" //'Gera Arq.Txt Produtores Rejeitados nas Integrações'        // 'U_MGLT32OM("D")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "Gera Arq.Txt Produtores Rejeitados nas Integrações'"
   ElseIf _cOpcaoM == "E" // 'Gera Arq.Txt Produtores Aceitos nas Integrações'          // 'U_MGLT32OM("E")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "Gera Arq.Txt Produtores Aceitos nas Integrações"
   ElseIf _cOpcaoM == "F" // 'Gera Arq.Txt Coletas Rejeitadas nas Integrações'          // 'U_MGLT32OM("F")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "Gera Arq.Txt Coletas Rejeitadas nas Integrações"
   ElseIf _cOpcaoM == "G" // 'Gera Arq.Txt Coletas Aceitas nas Integrações'             // 'U_MGLT32OM("G")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "Gera Arq.Txt Coletas Aceitas nas Integrações"
   ElseIf _cOpcaoM == "H" // 'Gera Arq.Txt Associações/Cooperativas Ativas e Inativas'  // 'U_MGLT32OM("H")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "Gera Arq.Txt Associações/Cooperativas Ativas e Inativas"
   ElseIf _cOpcaoM ==  "I"// 'Reenvia Dados das Associações/Cooperativas'               // 'U_MGLT32OM("I")' OPERATION 2 ACCESS 0
      _cTxtMsg   := "Reenvia Dados das Associações/Cooperativas"
   ElseIf _cOpcaoM ==  "J"
      _cTxtMsg   := "Gera Arq.Txt Notas Fiscais/Demonstrativos Rejeitados"
   ElseIf _cOpcaoM ==  "K"
      _cTxtMsg   := "Gera Arq.Txt Notas Fiscais/Demonstrativos Aceitos"

   EndIf

   If Type("__CUSERID") = "C" .And. ! Empty(__CUSERID)
      _cCodUser := __cUserId
   Else
      _cCodUser := Space(6)
   EndIf

   If Empty(_cCodUser)
      _cCodUser := RetCodUsr()
   EndIf

   //==========================================================
   // Grava código de Usuário para verificar erros na validação
   // Situações que os usuários estão liberados, mas não tem
   // acesso.
   //==========================================================
   ZZL->( DBSetOrder(3) )
   If ZZL->( DBSeek( xFilial("ZZL") + U_ItKey(_cCodUser,"ZZL_CODUSU")) ) // RetCodUsr()

      lSemAcesso:=!(ZZL->ZZL_GETXTL == "S") .And. _cOpcaoM $ "A/B/C/D/E/F/G/H"
      If lSemAcesso
          U_ItMsg( "Usuário sem acesso para rodar a opção de menu: [" + _cTxtMsg + "]" , "Atenção!","Para ter acesso a esta opção é necessário solicitar ao TI liberação, no cadastro de Gestão de Usuários Italac. ",1 )
          ZZL->( DBSetOrder(1) )
	       Break
      EndIf

      lSemAcesso:=!(ZZL->ZZL_ENVPRL == "S") .And. _cOpcaoM = "I"
      If lSemAcesso
         U_ItMsg( "Usuário sem acesso para rodar a opção de menu: [" + _cTxtMsg + "]" , "Atenção!","Para ter acesso a esta opção é necessário solicitar ao TI liberação, no cadastro de Gestão de Usuários Italac. ",1 )
         ZZL->( DBSetOrder(1) )
	      Break
      EndIf
   Else
      ZZL->( DBSetOrder(1) )
      U_ItMsg( "Usuário sem acesso para rodar a opção de menu: [" + _cTxtMsg + "]" , "Atenção!","Para ter acesso a esta opção é necessário solicitar ao TI liberação, no cadastro de Gestão de Usuários Italac. ",1 )
	   Break
   EndIf

   ZZL->( DBSetOrder(1) )
   _cDirTXT :=""
   _cNomeArq:=""
   If _cOpcaoM == "A"
      //=======================================================================
      // Gera arquivo Texto com os Dados dos Produtores por filial ativos e
      // inativos para envio por e-mail.
      //=======================================================================

       If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores Ativos e Inativos?","Atenção" , , ,2, 2)
         Break
      EndIf

       Processa( {|| U_MGLT32TXT("PRODUTORES") } , 'Aguarde!' , 'Gerando arquivo texto com Produtores Ativos e Inativos...' )

   ElseIf _cOpcaoM == "B"
          //=======================================================================
          // Gera arquivo Texto com os Dados dos Produtores usuários de tanques
          // coletivos e familiares para envio por e-mail.
          //=======================================================================
          If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores usuários de tanques coletivos e familiares, e seus vinculos com os titulares dos tanques?","Atenção" , , ,2, 2)
             Break
          EndIf

          Processa( {|| U_MGLT32CM()} , 'Aguarde!' , 'Gerando arquivo texto com Produtores Usuarios Tanques Coletivos/Familiares...' )

   ElseIf _cOpcaoM == "C"
          //==============================================================================
          // Gera arquivo Texto com os Dados dos Produtores com mais de uma
          // propriedade destacando que são produtores: NORMAIS, ASSOCIAÇÃO/COOPERATIVA.
          //==============================================================================
          If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores com mais de uma propriedade?","Atenção" , , ,2, 2)
             Break
          EndIf

          Processa( {|| U_MGLT32MP() } , 'Aguarde!' , 'Gerando arquivo texto com Produtores com mais de uma propriedade...' )

   ElseIf _cOpcaoM == "D"
          //==============================================================================
          // Gera arquivo Texto com os Dados dos Produtores Rejeitados nas integrações
          //==============================================================================
          If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores rejeitados nas integrações?","Atenção" , , ,2, 2)
             Break
          EndIf
          MV_PAR01 := Ctod("  /  /  ")
          MV_PAR02 := Ctod("  /  /  ")

          Aadd( _aParAux , { 1 , "De Dt Produtores Rejeitados"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
          Aadd( _aParAux , { 1 , "Ate Dt Produtotes Rejeitados"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

          Aadd(_aParRet,"MV_PAR01")
          Aadd(_aParRet,"MV_PAR02")

          IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Produtores Rejeitados" , @_aParRet )
	          U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	          Break
	       EndIf

          Processa( {|| U_MGLT32RJ(MV_PAR01,MV_PAR02) } , 'Aguarde!' , 'Gerando arquivo texto com Produtores rejeitados...' )

   ElseIf _cOpcaoM == "E"
          //==============================================================================
          // Gera arquivo Texto com os Dados dos Produtores Aceitos nas integrações
          //==============================================================================
          If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados dos Produtores aceitos nas integrações?","Atenção" , , ,2, 2)
             Break
          EndIf

          _aParAux := {}
          MV_PAR01 := Ctod("  /  /  ")
          MV_PAR02 := Ctod("  /  /  ")

          Aadd( _aParAux , { 1 , "De Dt Produtores Aceitos"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
          Aadd( _aParAux , { 1 , "Ate Dt Produtores Aceitos"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

          Aadd(_aParRet,"MV_PAR01")
          Aadd(_aParRet,"MV_PAR02")

          IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Produtores Aceitos" , @_aParRet )
	          U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	          Break
	       EndIf

          Processa( {|| U_MGLT32AC(MV_PAR01,MV_PAR02) } , 'Aguarde!' , 'Gerando arquivo texto com Produtores aceitos...' )

   ElseIf _cOpcaoM == "F"
          //==============================================================================
          // Gera arquivo Texto com os Dados das Coletas Rejeitadas
          //==============================================================================
          If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Coletas rejeitadas nas integrações?","Atenção" , , ,2, 2)
             Break
          EndIf

          _aParAux := {}

          MV_PAR01 := Ctod("  /  /  ")
          MV_PAR02 := Ctod("  /  /  ")

          Aadd( _aParAux , { 1 , "De Dt Coleta Rejeitada "  , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
          Aadd( _aParAux , { 1 , "Ate Dt Coleta Rejeitada " , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

          Aadd(_aParRet,"MV_PAR01")
          Aadd(_aParRet,"MV_PAR02")

          IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Coletas Rejeitadas " , @_aParRet )
	          U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	          Break
	       EndIf

          Processa( {|| U_MGLT32CL("R") } , 'Aguarde!' , 'Gerando arquivo texto com as Coletas rejeitadas...' )

   ElseIf _cOpcaoM == "G"
          //==============================================================================
          // Gera arquivo Texto com os Dados das Coletas Aceitas
          //==============================================================================
          If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Coletas Aceitas nas integrações?","Atenção" , , ,2, 2)
             Break
          EndIf

          _aParAux := {}

          MV_PAR01 := Ctod("  /  /  ")
          MV_PAR02 := Ctod("  /  /  ")

          Aadd( _aParAux , { 1 , "De Dt Aceite Coleta"  , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
          Aadd( _aParAux , { 1 , "Ate Dt Aceite Coleta" , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

          Aadd(_aParRet,"MV_PAR01")
          Aadd(_aParRet,"MV_PAR02")

          IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Coletas Aceitas " , @_aParRet )
	          U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	          Break
	       EndIf

          Processa( {|| U_MGLT32CL("A") } , 'Aguarde!' , 'Gerando arquivo texto com as Coletas aceitas...' )

   ElseIf _cOpcaoM == "H"
          //=======================================================================
          // Gera arquivo Texto com os Dados das Associações/Cooperativa e seus
          // associados/cooperado ativos e inativos para envio por e-mail.
          //=======================================================================
          If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Associações/Cooperativas Ativas e Inativas?","Atenção" , , ,2, 2)
             Break
          EndIf

          Processa( {|| U_MGLT32TXT("ASSOCIACOES")  } , 'Aguarde!' , 'Gerando arquivo texto Associações/Cooperativas Ativas e Inativas...' )

    ElseIf _cOpcaoM == "I"
          //=======================================================================
          // Reenvia Dados das Associação / Cooperativa
          //=======================================================================
          If ! U_ITMSG("Confirma o reenvio dos dados das Associações / Cooperativas para o sistema da Evomilk?","Atenção" , , ,2, 2)
             Break
          EndIf

         Processa( {|| U_MGLT032P(.F.,"REENVASS") } , 'Aguarde!' , 'Lendo dados das Associações / Cooperativa...' )

         If _lHaDadosP
            Processa( {|| U_MGLT032K("S","REENVASS")} , 'Aguarde!' , 'Reenviando dados das Associações / Cooperativas...' )
         EndIf

         U_ItMsg("Reenvio dos dados das Associações / Cooperativas para o sistema Evomilk Concluido.","Atenção",,2)

    ElseIf _cOpcaoM == "J"
        //==============================================================================
        // Gera arquivo Texto com os Dados das Notas Fiscais/Demonstrativos rejeitados.
        //==============================================================================
         If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Notas Fiscais e Demonstrativos rejeitadas nas integrações?","Atenção" , , ,2, 2)
            _lEnvDadoL := .F.
         EndIf

         _aParAux := {}

         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Nota Fiscal/Demonstrativos Rejeitados"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Nota Fiscal/Demonstrativos Rejeitados"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Notas Fiscais/Demonstrativos Rejeitados " , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32NF("R") } , 'Aguarde!' , 'Gerando arquivo texto com as Notas Fiscais/Demonstrativos rejeitados...' )

    ElseIf _cOpcaoM == "K"

         If ! U_ITMSG("Confirma a Geração de Arquivo Texto com os dados das Notas Fiscais e Demonstrativos aceitos nas integrações?","Atenção" , , ,2, 2)
            _lEnvDadoL := .F.
         EndIf

         _aParAux := {}

         MV_PAR01 := Ctod("  /  /  ")
         MV_PAR02 := Ctod("  /  /  ")

         Aadd( _aParAux , { 1 , "De Dt Nota Fiscal/Demonstrativos Aceitos"   , MV_PAR01, "@D", ""	, ""	  , ""          ,050      , .T. } )
         Aadd( _aParAux , { 1 , "Ate Dt Nota Fiscal/Demonstrativos Aceitos"  , MV_PAR02, "@D", ""	, ""	  , ""          ,050      , .T. } )

         Aadd(_aParRet,"MV_PAR01")
         Aadd(_aParRet,"MV_PAR02")

         IF !ParamBox( _aParAux , "Geração de Arquivo Texto - Notas Fiscais/Demonstrativos Aceitos " , @_aParRet )
	         U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	         Break
	      EndIf

         Processa( {|| U_MGLT32NF("A") } , 'Aguarde!' , 'Gerando arquivo texto com as Notas Fiscais/Demonstrativos Aceitos...' )

      EndIf

   If _cOpcaoM $ "A/B/C/D/E/F/G/H/J/K"
      U_ItMsg( "Arquivos gravados no diretório temporário do usuário. Na pasta: " + _cDirTXT +" "+ _cNomeArq  , "Atenção!","Para acessar esta pasta, digite o comando: %TEMP% no campo de pesquisa da barra de tarefa do Windows.",2 )
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32WM
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Faz as verificações de qual Associação/Cooperativa já foi enviada para o App Evomilk.
===============================================================================================================================
Parametros---------: _cCod = Código do Produtor.
                     _cLoja = Loja do Produtor.
                     _cCnpj = Cnpj do produtor.
===============================================================================================================================
Retorno------------: _lRet := .T. = Achou Cooperativa / .F. = Não Achou Cooperativa
===============================================================================================================================
*/
User Function MGLT32WM(_cCod, _cLolja, _cCnpj)

Local _lRet := .F.

Begin Sequence
   If ! Empty(_cCod)
      SA2->(DbSetOrder(1))
      SA2->(MsSeek(xFilial("SA2")+U_ITKEY(_cCod, "A2_COD")))

      Do While ! SA2->(Eof()) .And. SA2->A2_FILIAL + SA2->A2_COD == xFilial("SA2")+U_ITKEY(_cCod, "A2_COD")
         If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
            .And. SA2->A2_MSBLQL <> '1'.And. SA2->A2_L_TPASS == "A"

            _lRet := .T.
            Exit
         ElseIf ! Empty(_cLolja)
            If _cLolja == "0001"
               _lRet := .F.
               Exit
            EndIf

            //=============================================================
            // As primeiras lojas ativas são as associações.
            // As demais lojas são os Associados.
            // Faz uma verificação se as primeiras lojas ativas
            // foram enviadas.
            //=============================================================
            If _cLolja > "0001" .And. SA2->A2_LOJA == "0002"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1' // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            ElseIf _cLolja > "0002" .And. SA2->A2_LOJA == "0003"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1' // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            ElseIf _cLolja > "0003" .And. SA2->A2_LOJA == "0004"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1' // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            ElseIf _cLolja > "0004" .And. SA2->A2_LOJA == "0005"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1' // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            ElseIf _cLolja > "0005" .And. SA2->A2_LOJA == "0006"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1' // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            ElseIf _cLolja > "0006" .And. SA2->A2_LOJA == "0007"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1' // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            ElseIf _cLolja > "0007" .And. SA2->A2_LOJA == "0008"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1'  // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            ElseIf _cLolja > "0008" .And. SA2->A2_LOJA == "0009"

               If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
                  .And. SA2->A2_MSBLQL <> '1' // .And. SA2->A2_L_TPASS == "A"

                  _lRet := .T.
                  Exit
               EndIf

            EndIf

         EndIf

         SA2->(DbSkip())
      EndDo

   ElseIf ! Empty(_cCnpj)
      SA2->(DbSetOrder(3))

      SA2->(MsSeek(xFilial("SA2")+U_ITKEY( _cCnpj, "A2_CGC")))

      Do While ! SA2->(Eof()) .And. SA2->A2_FILIAL + SA2->A2_CGC == xFilial("SA2")+U_ITKEY(_cCod, "A2_CGC")
         If SA2->A2_L_ENVEV == "N" .And. SA2->A2_L_NFPRO == 'S' .And. SA2->A2_L_ATIVO <> 'N';
            .And. SA2->A2_MSBLQL <> '1'.And. SA2->A2_L_TPASS == "A"

            _lRet := .T.
            Exit

         EndIf

         SA2->(DbSkip())
      EndDo

   EndIf

End Sequence

Return _lRet

/*
===============================================================================================================================
Função-------------: MGLT32XM
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo TXT com os dados das Coletas Integradas Aceitas ou Rejeitadas, por filial.
===============================================================================================================================
Parametros---------: _cSituacao = Status da Coleta "A" = Aceita / "R" = Rejeitadas
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32XM()
Local _cQry

Private _nTotRegs := 0

Begin Sequence

   _cQry := " SELECT F1_DOC, "
   _cQry += " SPED50.R_E_C_N_O_ NRECNO, "
   _cQry += "     SF1.R_E_C_N_O_ NRECSF1, "
   _cQry += "     SPED54.R_E_C_N_O_ NREC54, "
   _cQry += "     SF1.F1_FORNECE, "
   _cQry += "     SF1.F1_LOJA, SA2.A2_NOME, SA2.A2_CGC "
   _cQry += " FROM "+RETSQLNAME("SF1") +" SF1 "
   _cQry += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA AND SA2.A2_I_CLASS = 'P' "
   _cQry += " INNER JOIN SYS_COMPANY SM0 ON M0_CODIGO = '01' AND M0_CODFIL = F1_FILIAL     AND SM0.D_E_L_E_T_ = ' ' "
   _cQry += " INNER JOIN SPED001 SPED01 ON SPED01.CNPJ = SM0.M0_CGC AND SPED01.IE = SM0.M0_INSC     AND SPED01.D_E_L_E_T_ = ' ' "
   _cQry += " INNER JOIN SPED050 SPED50 ON  SPED50.ID_ENT = SPED01.ID_ENT     AND SPED50.NFE_ID = (F1_SERIE || F1_DOC)     AND SPED50.STATUS = '6'     AND SPED50.D_E_L_E_T_ = ' ' "
   _cQry += " INNER JOIN SPED054 SPED54 ON SPED54.ID_ENT = SPED01.ID_ENT "
   _cQry += " AND SPED54.NFE_ID = (F1_SERIE || F1_DOC) "
   _cQry += "     AND SPED54.CSTAT_SEFR = '100' "
   _cQry += "     AND SPED54.D_E_L_E_T_ = ' ' "
   _cQry += " WHERE "
   _cQry += " F1_EMISSAO='20240229' AND SF1.D_E_L_E_T_ =' ' AND F1_FILIAL='10' "
   _cQry += " AND F1_ESPECIE = 'SPED' "
   _cQry += " AND F1_CHVNFE <> ' ' "
   _cQry += " AND ROWNUM <= 20 " "

    If Select("QRYXML") > 0
       QRYXML->(DbCloseArea())
    EndIf

    MPSysOpenQuery( _cQry , "QRYXML")

    QRYXML->(DbGotop())

    DBSelectArea("QRYXML")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
    Count to _nTotRegs

    QRYXML->(DbGotop())

    Processa( {|| U_MGL32XMT(_nTotRegs,"XML") } , 'Aguarde!' , 'Gravando Arquivo Texto das XML NFE Produtores...' )

    Processa( {|| U_MGL32XMT(_nTotRegs,"PROT") } , 'Aguarde!' , 'Gravando Arquivo Texto das XML NFE Produtores...' )

    U_ItMsg("Geração de arquivo TXT com os dados das Notas dos Produtores concluido.","Atenção",,2)

End Sequence

If Select("QRYXML") > 0
   QRYXML->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGL32XMT
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de geração de arquivo TxT das Coletas das Associações Rejeitadas.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32XMT(_nTotRegs,_cOpc)
Local _cDados
Local _nJ

_cDirTXT:=_cNomeArq:=""

Begin Sequence

   ProcRegua(_nTotRegs)

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

   _cDirTXT := GetTempPath()

   If _cOpc == "XML"
      _cNomeArq:= "XML_das_Notas_Fiscais_de_Entrada_" + Dtos(Date()) + ".Txt"
   Else
      _cNomeArq:= "PROTOCOLO_das_Notas_Fiscais_de_Entrada_" + Dtos(Date()) + ".Txt"
   EndIf


   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados das coletaas Integradas.","Atenção",,1)
      Break
   EndIf

   _oFWriter:Write("PRODUTOR;LOJA;CPF_CNPJ;NOME;XML_NFE;XML_PROTOCOLO;" + CRLF)

   QRYXML->(DbGoTop())

   _nJ := 1

   //_oFWriter:Write("[")

   Do While ! QRYXML->(Eof())

      IncProc("Gerando arquivo texto: "+ StrZero(_nJ,6) + " de " + StrZero(_nTotRegs,6) + "...")
      _nJ += 1

      SPED050->(DbGoTo(QRYXML->NRECNO))

      SPED054->(DbGoTo(QRYXML->NREC54))

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================

      _cDados :=  QRYXML->F1_FORNECE + "; "+ QRYXML->F1_LOJA+ "; " + QRYXML->A2_CGC + "; "+  QRYXML->A2_NOME + "; "

      If _cOpc == "XML"
         _cDados +=  SPED050->XML_SIG + "; "
      Else
         _cDados += SPED054->XML_PROT + ";"
      EndIf

      _cDados += CRLF

      _oFWriter:Write(_cDados)

      QRYXML->(DbSkip())
   EndDo

   //_oFWriter:Write("]")

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence

If Select("SPED050") > 0
   SPED050->( DBCloseArea() )
EndIf

If Select("SPED054") > 0
   SPED054->( DBCloseArea() )
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGL32NFS
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina Scheduller de integração de notas fiscais e extrato para o App Evomilk.
===============================================================================================================================
Parametros--------:  _cOpcNFE = "L" = Ler e gravar dados das notas (Gerar PDF Danfe e Demonstrativos).
                              = "T" = Transmitir dados para o App Evomilk
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32NFS(_cOpcNFE)
Local _nI , _nJ
Local _nTotRegNF
Local _nNrProcNF
Local _nTotalInt

Begin Sequence

   //=============================================================================
   // Ativa a filial "01" apenas para leitura das filiais do parâmetro.
   //=============================================================================
   RESET ENVIRONMENT
   RpcSetType(2)

   //===========================================================================================
   // Preparando o ambiente com a filial 01
   //===========================================================================================
   RpcSetEnv("01", "01",,,,, {"SA2","ZLJ","ZLD",'ZBG', "ZBH", "ZBI", "ZZM"})

   Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

   _nTotRegNF :=  U_MGL32CNF()

   _nNrProcNF :=  SUPERGETMV('IT_NRNFPVZ',.F.,  40 )  // Numero total de notas fiscais a serem processadas por Vez.

   If _nTotRegNF <= _nNrProcNF
      _nTotalInt := 1
   ElseIf _nTotRegNF <= (_nNrProcNF * 2)
      _nTotalInt := 2
   Else
      _nTotalInt :=  Int(_nTotRegNF / _nNrProcNF) + 1
   EndIf

   //====================================================================
   // Inicia a Integração Webservice via Scheduller.
   //====================================================================
   _cFilIntWS := SUPERGETMV('IT_FILITCL',.F.,  "01;04;23;")

   _aFilIntWS := {}

   ZZM->(DbGoTop())

   Do While ! ZZM->(Eof())
      If ZZM->ZZM_CODIGO $ _cFilIntWS
         Aadd(_aFilIntWS,ZZM->ZZM_CODIGO)
      EndIf

      ZZM->(DbSkip())
   EndDo

For _nJ := 1 To _nTotalInt

   //===================================================================================================
   // Para cada empresa cadastrada no parâmetro IT_FILITCL, inicializa o ambiente, simulando o usuário
   // fazendo login na filial a ser processada.
   //===================================================================================================
   For _nI := 1 To Len(_aFilIntWS)

       _cfilial := _aFilIntWS[_nI]

       //=============================================================================
       // Ativa a filial contida em _aFilIntWS
       //=============================================================================
       RESET ENVIRONMENT
       RpcSetType(2)

       //=============================================================================
       // Inicia processamento com base nas filiais do parâmetro.
       //=============================================================================

       //===========================================================================================
       // Preparando o ambiente com a filial 01
       //===========================================================================================
       RpcSetEnv("01", _cfilial ,,,,, {"SA2","ZLJ","ZLD",'ZBG', "ZBH", "ZBI", "ZZM"})

       Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

       cFilAnt := _cfilial

	    cUSUARIO := SPACE(06)+"Administrador  " // Quando o ambiente é iniciado. O Protheus já está criando estas variáveis com usuário.
	    cUsername:= "Schedule" // Quando o ambiente é iniciado. O Protheus já está criando estas variáveis com usuário.


       //===================================================================================================
       // Rotina de integração de PDF de Notas Fiscais em Encode64()
       //===================================================================================================

       //===============================================================================================
       // Liga ou Desliga a geração de dados para integração Webservice via Scheduller de Notas Fiscais
       //===============================================================================================
       _LigaDesGD := SUPERGETMV('IT_LIGDEGD',.F.,  .T.)  //  _LigaDesGD := SUPERGETMV('IT_LIGDEGD',.F.,  .F.)

       //======================================================================
       // Rotina de gravação das tabelas de muro ZBM e ZBN para envio das
       // Notas Fiscais e Demonstrativos para o App Evomilk.
       //======================================================================
       If _cOpcNFE == "L" .And. _LigaDesGD

          U_MGL32NFE(.T.)  // .T. = Indica que a rotina foi chamada via Scheduller.
       EndIf


      //===============================================================================================
      // Liga ou Desliga o envio de dados para integração Webservice via Scheduller de Notas Fiscais
      //===============================================================================================
      _LigaDesEN := SUPERGETMV('IT_LIGDEEN',.F.,  .F.)

       //======================================================================
       // Rotina de transmissão dos dados gravados nas tabela ZBM e ZBN para
       // o App Evomilk.
       //======================================================================

       If _cOpcNFE == "T" .And. _LigaDesEN

          U_MGL32EVN(.T.) // Envia os dados gravados na tabela ZBM para o App Evomilk.
       EndIf

   Next

Next

End Sequence

Return Nil


/*
===============================================================================================================================
Função-------------: MGL32NFE
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de integração de notas fiscais para o App Evomilk. Rotina de gravação dos dados das tabelas
                     de muro ZBM e ZBN para envio dos dados das Notas Fiscais e Demonstrativos para o App Evomilk.
===============================================================================================================================
Parametros--------:  _lSchedule = .T./.F. = Rotina chamada via Scheduller ou menu.
                     _cTipoInt  = "N" = Nota fiscal
                                = "E" = Extrato
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32NFE(_lSchedule, _cTipoInt)
Local _cDir := "\temp\italapp\"
//Local _cDirDanfe := SuperGetMV('MV_RELT',,"\SPOOL\")
Local _cCnpjAssoc := ""
Local _cCnpjProd  := ""
Local _cEmiteNfP  := ""
Local _nNrDiasNFE := 0
Local _nNrProcNF :=  SUPERGETMV('IT_NRNFPVZ',.F.,  40 )  // Numero total de notas fiscais a serem processadas por Vez.

Private _cPdfExtra
Private _aDadosSpd := {}
Private _cFilSF1 := ""

Begin Sequence

   If ! File("\temp\italapp\")
      MakeDir("\temp\italapp\")
   EndIf

   _nNrDiasNFE := SUPERGETMV('IT_NRDIANF',.F.,  730) // 2 ANOS // _nNrDiasNFE := SUPERGETMV('IT_NRDIANF',.F.,  30) // Numero de dias para considerar a leituras das notas fiscais de produtores.

   //===================================================================================================
   // Abre o arquivo de Sped para leitura dos XML e Envio para o RDC.
   //===================================================================================================
   If Select("SPED050") > 0
      SPED050->( DBCloseArea() )
   EndIf

   USE SPED050 ALIAS SPED050 SHARED NEW VIA "TOPCONN"

   _cAnoMes := Str(Year(Date() - _nNrDiasNFE),4) + StrZero(Month(Date() - _nNrDiasNFE),2)

   _cQry := " SELECT F1_DOC, "
   _cQry += " SPED50.R_E_C_N_O_ NRECNO, "
   _cQry += "     SF1.R_E_C_N_O_ REGSF1, "
   _cQry += "     SF1.F1_FORNECE, "
   _cQry += "     SF1.F1_LOJA, SA2.A2_NOME, SA2.A2_CGC, SA2.R_E_C_N_O_ REGSA2 "
   _cQry += " FROM "+RETSQLNAME("SF1") +" SF1 "
   _cQry += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA AND SA2.A2_I_CLASS = 'P' "
   _cQry += " INNER JOIN SYS_COMPANY SM0 ON M0_CODIGO = '01' AND M0_CODFIL = F1_FILIAL     AND SM0.D_E_L_E_T_ = ' ' "
   _cQry += " INNER JOIN SPED001 SPED01 ON SPED01.CNPJ = SM0.M0_CGC AND SPED01.IE = SM0.M0_INSC     AND SPED01.D_E_L_E_T_ = ' ' "
   _cQry += " INNER JOIN SPED050 SPED50 ON  SPED50.ID_ENT = SPED01.ID_ENT     AND SPED50.NFE_ID = (F1_SERIE || F1_DOC)     AND SPED50.STATUS = '6'     AND SPED50.D_E_L_E_T_ = ' ' "
   _cQry += " WHERE "
   _cQry += " SF1.D_E_L_E_T_ =' ' "
   _cQry += " AND F1_ESPECIE = 'SPED' "
   _cQry += " AND F1_CHVNFE <> ' ' "
   _cQry += " AND SUBSTR(F1_EMISSAO,1,6) = '"+ _cAnoMes + "' "
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_L_ATIVO <> 'N' "
   _cQry += " AND SA2.A2_L_ENVEV = 'N' "
   _cQry += " AND F1_FORMUL = 'S' "
   _cQry += " AND (F1_I_SITUA = ' ' OR F1_I_SITUA = 'N') "
   _cQry += " AND F1_FILIAL = '" + xFilial("SF1") + "' "
   _cQry += " AND F1_SERIE = '3' " // Serie 3 = Notas fiscais de produtores de leite.

   If Select("QRYSF1") > 0
      QRYSF1->(DbCloseArea())
   EndIf


   MPSysOpenQuery( _cQry , "QRYSF1")

   IMP_PDF := 6
   cIdEnt := RetIdEnti(.F.)

   SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
   ZBM->(DbSetOrder(5)) // ZBM_FILIAL+ZBM_CHVNFE+ZBM_STATNF+Dtos(ZBM_DTENVN)
   ZBN->(DbSetOrder(5)) // ZBN_FILIAL+ZBN_CHVNFE+ZBN_STATNF+Dtos(ZBN_DTENVN)

   _nJ := 1

   Do While ! QRYSF1->(Eof())

      SF1->(DbGoto(QRYSF1->REGSF1))

      SA2->(DbGoto(QRYSF1->REGSA2))

      SPED050->(DbGoTo(QRYSF1->NRECNO))

      _aDadosSpd := { SPED050->NFE_PROT,;      // 1
                      SPED050->XML_SIG,;       // 2
                      SPED050->NFE_ID,;        // 3
                      SPED050->XML_DPEC,;      // 4
                      SPED050->REG_DPEC,;      // 5
                      SPED050->TIME_NFE,;      // 6
                      SPED050->DATE_NFE,;      // 7
                      "",;                     // 8
                      Str(SPED050->STATUS,1),; // 9
                      "",;                     // 10
                      ""}                      // 11

      //===============================================================
      // Gera o Danfe do Produtor em PDF
      //===============================================================
      _aDevice := {}
      Aadd(_aDevice,"DISCO") // 1
      Aadd(_aDevice,"SPOOL") // 2
      Aadd(_aDevice,"EMAIL") // 3
      Aadd(_aDevice,"EXCEL") // 4
      Aadd(_aDevice,"HTML" ) // 5
      Aadd(_aDevice,"PDF"  ) // 6

      //INICIALSX1("NFSIGW","01",1,SF1->F1_DOC)           // MV_PAR01 := SF1->F1_DOC
	   //INICIALSX1("NFSIGW","02",1,SF1->F1_DOC)           // MV_PAR02 := SF1->F1_DOC
	   //INICIALSX1("NFSIGW","03",1,SF1->F1_SERIE)         // MV_PAR03 := SF1->F1_SERIE
	   //INICIALSX1("NFSIGW","04",2,1)                     // MV_PAR04 := 1	// [Operacao] NF de Entrada
	   //INICIALSX1("NFSIGW","05",2,2)                     // MV_PAR05 := 2	// [Frente e Verso] Sim
	   //INICIALSX1("NFSIGW","06",2,2)                     // MV_PAR06 := 2	// [DANFE simplificado] Sim
      //INICIALSX1("NFSIGW","07",1,Dtoc(SF1->F1_EMISSAO)) // MV_PAR07 := SF1->F1_EMISSAO
      //INICIALSX1("NFSIGW","08",1,Dtoc(SF1->F1_EMISSAO)) // MV_PAR08 := SF1->F1_EMISSAO
      //INICIALSX1("NFSIGW","09",1," ")                   // MV_PAR09
      //INICIALSX1("NFSIGW","10",1," ")                   // MV_PAR10
      //INICIALSX1("NFSIGW","11",1,SF1->F1_FORNECE)       // MV_PAR11 := SF1->F1_FORNECE
      //INICIALSX1("NFSIGW","12",1,SF1->F1_FORNECE)       // MV_PAR12 := SF1->F1_FORNECE
      //INICIALSX1("NFSIGW","13",1,SF1->F1_LOJA)          // MV_PAR13 := SF1->F1_LOJA
      //INICIALSX1("NFSIGW","14",1,SF1->F1_LOJA)          // MV_PAR14 := SF1->F1_LOJA
      //INICIALSX1("NFSIGW","15",1,SF1->F1_L_SETOR)       // MV_PAR15 := SF1->F1_L_SETOR
      //INICIALSX1("NFSIGW","16",1,SF1->F1_L_LINHA)       // MV_PAR16 := SF1->F1_L_LINHA

      cFilePrint := "DANFE_PRODUTOR_"+SF1->F1_FORNECE+"_LOJA_"+SF1->F1_LOJA+"_NF_"+AllTrim(SF1->F1_DOC)+"_"+AllTrim(SF1->F1_SERIE)+Dtos(MSDate())+".pdf"
      cFilePrint := Lower(cFilePrint)

      nLocal       	 := 2 //"LOCAL" //If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
      nOrientation 	 := 1 // If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
      cDevice     	 := "PDF" // If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
      nPrintType      := aScan(_aDevice,{|x| x == cDevice })
      lAdjustToLegacy := .F.

      //=======================================================
      // Verifica se existe nota fiscal para geração do PDF
      //=======================================================
      /*
      If ! U_RGLT076H()
         QRYSF1->(DbSkip())
         Loop
      EndIf
      */
      //=======================================================
            //  FWMSPrinter():New('teste'            ,6          ,.F.                ,                        ,.T.              ,            ,                ,            ,,.F.)
            //  FWMsPrinter():New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer]       , [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
      oDanfe := FWMSPrinter():New(cFilePrint         , IMP_PDF   , lAdjustToLegacy   , _cDir /*cPathInServer*/, .T.             ,            ,                ,            ,           ,             ,        , .F. )

		oDanfe:SetViewPDF(.F.)
		oDanfe:lInJob := .T.

      nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN

      oSetup := FWPrintSetup():New(nFlags, "DANFE")
      oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
      oSetup:SetPropert(PD_ORIENTATION , nOrientation)
      oSetup:SetPropert(PD_DESTINATION , nLocal)
      oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
      oSetup:SetPropert(PD_PAPERSIZE   , 2)

                    // 1      2       3        4      5         6          7          8        9
      //  RGLT076(cIdEnt , cVal1   , cVal2    , oDanfe, oSetup, cFilePrint	, lIsLoja	, nTipo ,_cDir)

            //U_PrtNfeSef(cIdEnt ,/*cVal1*/,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint ,/*lIsLoja*/, /*nTipo*/, .T. )  // RGLT076
      U_RGLT076(cIdEnt ,/*cVal1*/,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint ,/*lIsLoja*/, /*nTipo*/, _cDir )

      If Type("oDanfe") == "O"
         FreeObj(oDanfe)
      EndIf
      oDanfe := Nil

      If Type("oSetup") == "O"
         FreeObj(oSetup)
      EndIf
      oSetup := Nil

      If ! File(_cDir+cFilePrint)  // Não foi possível gerar o PDF do Danfe.
         QRYSF1->(DbSkip())
         Loop
      EndIf

      //===========================================================================
      // Gera o Demonstrativo/Extrato do Produtor.
      //===========================================================================
      _cPdfExtra := "Demonstrativo_Produtor_" + AllTrim(SF1->F1_FORNECE) +"_Loja_"+AllTrim(SF1->F1_LOJA) + "_" + Dtos(MSDate()) + ".pdf"
      _cPdfExtra := Lower(_cPdfExtra)

      //RGLT075(_lSchedule,_cGrupoMix,_cProdutor,_cLojaProd, _cFilProd,_dEmisNf,_cDirDest,_cNomeArq)
      U_RGLT075(.T.,,SF1->F1_FORNECE,SF1->F1_LOJA, SF1->F1_FILIAL,SF1->F1_EMISSAO,_cDir,_cPdfExtra)

      If ! File(_cDir+_cPdfExtra)  // Não foi possível gerar o PDF do Danfe.
         QRYSF1->(DbSkip())
         Loop
      EndIf

      //====================================================================
      // Converte o PDF da Nota Fiscal e Demonstrativo em Encode64
      //====================================================================
      _cEcod64Nf := Encode64( ,_cDir + cFilePrint)

      _cEcod64Ex := Encode64( ,_cDir + _cPdfExtra)

      If Empty(_cEcod64Nf)
         Sleep(1000)
         _cEcod64Nf := Encode64( ,_cDir + cFilePrint)
      EndIf

      If Empty(_cEcod64Ex)
         Sleep(1000)
         _cEcod64Ex := Encode64( ,_cDir + _cPdfExtra)
      EndIf

      //============================================================================
      // Se já existir a nota fiscal na tabela ZBM. Exclui para incluir novamente.
      //============================================================================
      If ZBM->(MsSeek(SF1->F1_FILIAL+SF1->F1_CHVNFE+"N"))
         ZBM->(RecLock("ZBM",.F.))
         ZBM->(DbDelete())
         ZBM->(MsUnLock())
      EndIf

      //============================================================================
      // Se já existir a nota fiscal na tabela ZBN. Exclui para incluir novamente.
      //============================================================================
      If ZBN->(MsSeek(SF1->F1_FILIAL+SF1->F1_CHVNFE+"N"))
         Do While ! ZBN->(Eof()) .And. ZBN->ZBN_FILIAL+ZBN->ZBN_CHVNFE+ZBN->ZBN_STATNF == SF1->F1_FILIAL+SF1->F1_CHVNFE+"N"
            ZBN->(RecLock("ZBN",.F.))
            ZBN->(DbDelete())
            ZBN->(MsUnLock())

            ZBN->(DbSkip())
         EndDo

      EndIf

      //====================================================================
      // Faz a inclusão da nota fiscal para integrar para o App Cia Leite.
      //====================================================================
      _cCnpjAssoc := ""
      _cCnpjProd  := ""

      _cEmiteNfP  := POSICIONE('SA2',1,xFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA,'A2_L_NFPRO')
      If _cEmiteNfP == "S"
         _cCnpjAssoc := POSICIONE('SA2',1,xFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA,'A2_CGC')
      Else
         _cCnpjProd := POSICIONE('SA2',1,xFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA,'A2_CGC')
      EndIf

      Begin Transaction

         ZBM->(RecLock("ZBM",.T.))
         ZBM->ZBM_FILIAL := SF1->F1_FILIAL                                                            // Filial do Sistema
         ZBM->ZBM_NRNFE  := SF1->F1_DOC		                                                         // Numero da Nota Fiscal
         ZBM->ZBM_SERNFE := SF1->F1_SERIE		                                                         // Serie da Nota Fiscal
         ZBM->ZBM_CHVNFE := SF1->F1_CHVNFE 	                                                         // Chave da Nota Fiscal
         ZBM->ZBM_DTEMIS := SF1->F1_EMISSAO	                                                         // Data Emissão NFE
         ZBM->ZBM_CODPRO := SF1->F1_FORNECE	                                                         // Codigo do Produtor
         ZBM->ZBM_LOJPRO := SF1->F1_LOJA		                                                         // Loja do Produtor
         ZBM->ZBM_NOMPRO := POSICIONE('SA2',1,xFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA,'A2_NOME')	// Nome do Produtor
         ZBM->ZBM_PDFNFE := _cEcod64Nf		                                                            // Pdf NFE em ENCODE 64
         ZBM->ZBM_PDFEXT := _cEcod64Ex		                                                            // Pdf Extrato NFE ENCODE 64
         ZBM->ZBM_CNPJLV := _cCnpjAssoc                                                               // CNPJ Laticinio Vinculado //POSICIONE('SA2',1,xFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA,'A2_CGC')
         ZBM->ZBM_CNPJPR := _cCnpjProd                                                                // CNPJ Produtor
         ZBM->ZBM_VALNFE := SF1->F1_VALBRUT		                                                      // Valor Total Nota Fiscal
         //ZBM->ZBM_QTDLIT := _nQtdLit                                                                  // Quantidade de Litros
         //ZBM->ZBM_VALLIT := _nValLit		                                                            // Valor do Litro
         ZBM->ZBM_AMREFE := StrZero(Year(SF1->F1_EMISSAO),4)+"-"+StrZero(Month(SF1->F1_EMISSAO),2)		//	Ano e Mês de Referencia
         ZBM->ZBM_STATNF := "N"		                                                                  // Status da Integração Nfe // N = Não processado / P=Processado / I = Integrado.
         ZBM->ZBM_XMLNFE := Encode64(SPED050->XML_SIG)                                                // XML da NFE em Encode64
         ZBM->ZBM_REGCAP := ZBM->(Recno())
         ZBM->ZBM_NARQDA := cFilePrint
         ZBM->ZBM_NARQEX := _cPdfExtra
         ZBM->ZBM_DIRARQ := _cDir

         ZBM->(MsUnLock())

         //====================================================================
         // Obtem os dados de item da nota de entrada.
         //====================================================================
         // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
         _nQtdLit := 0
         _nValLit := 0

         SD1->(DbSetOrder(1))
         SD1->(MSSEEK(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
         Do While ! SD1->(Eof()) .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
                                    SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA

            _nQtdLit := _nQtdLit + SD1->D1_QUANT

            ZBN->(RecLock("ZBN",.T.))
            ZBN->ZBN_FILIAL := SF1->F1_FILIAL                                             // Filial do Sistema
            ZBN->ZBN_NRNFE  := SF1->F1_DOC		                                          // Numero da Nota Fiscal
            ZBN->ZBN_SERNFE := SF1->F1_SERIE		                                          // Serie da Nota Fiscal
            ZBN->ZBN_CHVNFE := SF1->F1_CHVNFE 	                                          // Chave da Nota Fiscal
            ZBN->ZBN_DTEMIS := SF1->F1_EMISSAO	                                          // Data Emissão NFE
            ZBN->ZBN_CODPRO := SF1->F1_FORNECE	                                          // Codigo do Produtor
            ZBN->ZBN_LOJPRO := SF1->F1_LOJA		                                          // Loja do Produtor
            ZBN->ZBN_CODPRD := AllTrim(SD1->D1_COD)                                       // Código do Produto

            _cDescPrd := POSICIONE('SB1',1,xFilial('SB1')+SD1->D1_COD,'B1_DESC')

            _cDescPrd := AllTrim(_cDescPrd)

            _cDescPrd := StrTran(_cDescPrd, " ", "_" )

            ZBN->ZBN_DESPRD := _cDescPrd // POSICIONE('SB1',1,xFilial('SB1')+SD1->D1_COD,'B1_DESC')		// Descrição do Produto
            ZBN->ZBN_NCM	 := POSICIONE('SB1',1,xFilial('SB1')+SD1->D1_COD,'B1_POSIPI')  // NCM Produto	NCM do Produto
            ZBN->ZBN_UNID	 := SD1->D1_UM                                                 // Unidade de Medida
            ZBN->ZBN_QTDE	 := SD1->D1_QUANT                                              // Quantidade
            ZBN->ZBN_VALUNI := SD1->D1_VUNIT 	                                          // Valor Unitário
            ZBN->ZBN_VALTOT := SD1->D1_TOTAL	                                             //	Valor Total do Item
            ZBN->ZBN_CST	 := SD1->D1_CLASFIS                                            // Classificação Situação Tributária
            ZBN->ZBN_CF     := SD1->D1_CF	                                                // Codigo Fiscal
            ZBN->ZBN_BASICM := SD1->D1_BASEICM	                                          // Base de Calculo ICMS
            ZBN->ZBN_PERICM := SD1->D1_PICM	                                             // Aliquota ICMS
            ZBN->ZBN_VALICM := SD1->D1_VALICM                                             //	Valor ICMS
            ZBN->ZBN_BASIPI := SD1->D1_BASEIPI                                            //	Base de Calculo IPI
            ZBN->ZBN_PERIPI := SD1->D1_IPI	                                             // Aliquota IPI
            ZBN->ZBN_VALIPI := SD1->D1_VALIPI                                             // Valor IPI
            ZBN->ZBN_DTENVN := Date()	                                                   // Data de Envio Nfe
            ZBN->ZBN_HRENVN := Time()                                                     // Hora de Envio Nfe
            ZBN->ZBN_STATNF := "N"	                                                      // Status de Envio Nfe
            ZBN->ZBN_REGCAP := ZBM->(Recno())                                             // Recno para vincular tabela de capa com tabela de item.
            ZBN->ZBN_ITEM   := SD1->D1_ITEM                                               // Item da nota fiscal
            ZBN->(MsUnlock())

            SD1->(DbSkip())
         EndDo

         ZBM->(RecLock("ZBM",.F.))
         ZBM->ZBM_VALNFE := SF1->F1_VALBRUT		                                                      // Valor Total Nota Fiscal
         ZBM->ZBM_QTDLIT := _nQtdLit                                                                  // Quantidade de Litros
         ZBM->ZBM_VALLIT := (SF1->F1_VALBRUT	/ _nQtdLit)	                                             // Valor do Litro capa = Valor total nota / soma quantidades => Definido pela Evomilk.
         ZBM->(MsUnLock())

         If ! Empty(ZBM->ZBM_PDFNFE) .And. ! Empty(ZBM->ZBM_PDFEXT)
            //==============================================================
            // Atualiza a tabela SF1
            //==============================================================
            SF1->(RecLock("SF1", .F.))
            SF1->F1_I_SITUA := "P"	  // Situação Integração Cia Leite
            SF1->F1_I_DTENV := Date() // Data de Enviao para Evomilk
            SF1->F1_I_HRENV := Time() // Hora de Envio para Evomilk
            SF1->(MsUnLock())
         EndIf

      End Transaction

      If Type("_cEcod64Nf") == "O"
         FreeObj(_cEcod64Nf)
      EndIf
	   _cEcod64Nf := Nil

      If Type("_cEcod64Ex") == "O"
         FreeObj(_cEcod64Ex)
      EndIf
	   _cEcod64Ex := Nil

      //=========================================================================
      // Exclui o PDF da Danfe e do Demonstrativo, após a gravação da tabela ZBM.
      //=========================================================================

      If File(_cDir + cFilePrint) // Exclui o PDF do Danfe
         FErase(_cDir + cFilePrint)
      EndIf

      If File(_cDir + _cPdfExtra) // Exclui o PDF do Demonstrativo
         FErase(_cDir + _cPdfExtra)
      EndIf

      QRYSF1->(DbSkip())

      _nJ += 1
      If _nJ > _nNrProcNF
         Exit
      EndIf

   EndDo

   //====================================================================
   // Faz a regravação dos PDFs da notas e demonstrativos.
   //====================================================================
   //U_MGL32PDF(_lSchedule)

End Sequence

If Select("SPED050") > 0
   SPED050->( DBCloseArea() )
EndIf

Return Nil


/*
===============================================================================================================================
Função-------------: MGL32EVN(_lSchedule)
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Envio de dados das Notas Fiscais via WebService Italac para Sistema Evomilk
===============================================================================================================================
Parametros--------:  _lSchedule = .T. = Rotina rodada em modo automático. .F. = Rotina rotada através de menu.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32EVN(_lSchedule)
Local _cEmpWebService := SUPERGETMV('IT_CODWSEV',.F.,_cCodEvoMilk)
Local _cJSonEnv
Local _nStart
Local _nRetry
Local _cJSonRet
Local _nTimOut
Local _cRetHttp
Local _cJSonNFE, _cJSonGrp
Local _cHoraIni, _cHoraFin, _cMinutos, _nMinutos
Local _nTotRegEnv := 1 // 100  // Total de registros para envio.
Local _nI , _oRetJSon, _lResult

Private _cEcod64Ex
Private _cEcod64Nf

Default _lSchedule := .F.

Begin Sequence
   //===============================================================
   // Obtem os dados do servidor Webservice.
   //===============================================================
   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirJSon := AllTrim(ZFM->ZFM_LOCXML)
      _cLinkWS  := AllTrim(ZFM->ZFM_LINK07) // Link de envio das Notas Fiscais.
      _LinkCerto := AllTrim(ZFM->ZFM_HOMEPG)
   Else
      If ! _lSchedule // Chamada via menu.
         U_ItMsg("Empresa WebService para envio dos dados não localizada.","Atenção",,1)
      EndIf

      Break
   EndIf

   If Empty(_cDirJSon)
      If ! _lSchedule // Chamada via menu.
         U_ItMsg("Diretório dos arquivos JSON modelos ou o Link de envio de dados não informado para a empresa: "+AllTrim(ZFM->ZFM_NOME)+".","Atenção",,1)
      EndIf

      Break
   EndIf

   _cDirJSon := Alltrim(_cDirJSon)
   If Right(_cDirJSon,1) <> "\"
      _cDirJSon := _cDirJSon + "\"
   EndIf

   //================================================================================
   // Lê os arquivos modelo JSON e os transforma em String.
   //================================================================================
   _cCapaNFE := U_MGLT032X(_cDirJSon + "Capa_Notas_Fiscais_e_Demonstrativos_PRODUTOR.txt")

   If Empty(_cCapaNFE)
      If ! _lSchedule // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Capa do PDF de Notas Fiscais e Demonstrativos de Produtores na integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cItemNFE := U_MGLT032X(_cDirJSon + "Item_Notas_Fiscais_e_Demonstrativos_PRODUTOR.txt")

   If Empty(_cItemNFE)
      If ! _lSchedule // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Itens do PDF de Notas Fiscais e Demonstrativos de Produtores na integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   _cRodaPeNF := U_MGLT032X(_cDirJSon + "Rodape_Notas_Fiscais_e_Demonstrativos_PRODUTOR.txt")

   If Empty(_cRodaPeNF)
      If ! _lSchedule // Chamada via menu.
         U_ItMsg("Erro na leitura do arquivo modelo JSON Rodape do PDF de Notas Fiscais e Demonstrativos de Produtores na integração Italac x Evomilk","Atenção",,1)
      EndIf

      Break
   EndIf

   If _lSchedule
      _cKey := U_MGLT032T("S") // Obtem o Token de acesso. S=Schedule
   Else
      _cKey := U_MGLT032T("M") // Obtem o Token de acesso. M=menu
   EndIf

   If Empty(_cKey)
      If ! _lSchedule // Chamada via menu.
         U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Pdfs de Notas fiscais e Demonstrativos de Produtores cancelada.","Atenção",,1)
      EndIf

      Break

   EndIf

   ZBN->(DbSetOrder(5))

   _cHoraIni := Time() // Horario Inicial de Processamento

   _aHeadOut := {}

   Aadd(_aHeadOut,'Accept: application/json')
   Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
   Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

   If ! _lSchedule
      ProcRegua(_nTotRegs)
   EndIf

   _cJSonNFE := "["
   _cJSonGrp    := ""
   _nI := 1

   //====================================================
   // Efetua a leitura de dados para integração.
   //====================================================
   U_MGL32LEN(_lSchedule)

   //====================================================
   // Inicia o envio dos dados.
   //====================================================
   QRYZBM->(DbGoTop())
   Do While ! QRYZBM->(Eof())

      If ! _lSchedule
         IncProc("Transmitindo os dados das coletas...")
      EndIf

      //====================================================================
      // Calcula o tempo decorrido para obtenção de um novo Token
      //====================================================================
      _cHoraFin := Time()
      _cMinutos := ElapTime (_cHoraIni , _cHoraFin)
      _nMinutos := Val(SubStr(_cMinutos,4,2))
      If _nMinutos > 5 // 28 // minutos
         //_cKey := U_MGLT032T(_cChamada) // Obtem o Token de acesso.
         If _lSchedule
            _cKey := U_MGLT032T("S") // Obtem o Token de acesso. S=Schedule
         Else
            _cKey := U_MGLT032T("M") // Obtem o Token de acesso. M=menu
         EndIf

         If Empty(_cKey)
            If ! _lSchedule  // Chamada via menu.
               U_ItMsg("Erro ao na obtenção do Token. Rotina de Integração de Coleta de Leite Produtores cancelada.","Atenção",,1)
            EndIf

            Break
         EndIf

         _aHeadOut := {}
         Aadd(_aHeadOut,'Accept: application/json')
         Aadd(_aHeadOut,'Authorization: Bearer ' + Alltrim(_cKey) )
         Aadd(_aHeadOut,'TENANTID: ' + _cTenantid) // Aadd(_aHeadOut,'TENANTID: LATITATE1')

         _cHoraIni := Time()

      EndIf

      //===================================================================
      // Posiciona os registros das tabelas ZBM E SF1.
      //===================================================================
      ZBM->(DbGoTo(QRYZBM->REGZBM))
      SF1->(DbGoTo(QRYZBM->REGSF1))

      //===================================================================
      // Lê os dados de item para montagem do JSon de itens.
      //===================================================================
      _aRecnoZBN := {}
      _cJSonItem := ""

      ZBN->(MsSeek(ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE+"N"))
      Do While ! ZBN->(Eof()) .And. ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE+"N" == ZBN->ZBN_FILIAL+ZBN->ZBN_CHVNFE+ZBN->ZBN_STATNF
         Aadd(_aRecnoZBN, ZBN->(Recno()) )

         _cJSonItem := _cJSonItem + If(!Empty(_cJSonItem),",","") + &(_cItemNFE)

         ZBN->(DbSkip())
      EndDo


      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================
      _cJSonEnv := &(_cCapaNFE) + _cJSonItem + &(_cRodaPeNF)

      _cJSonGrp += If(!Empty(_cJSonGrp),",","") + _cJSonEnv

      If _nI >= _nTotRegEnv

         _cJSonNFE += _cJSonGrp + "]"

        _cJSonNFE := DecodeUTF8(_cJSonNFE, "cp1252")

         _nStart 		:= 0
         _nRetry 		:= 0
         _cJSonRet 	:= Nil
         _nTimOut	 	:= 120

         _cRetHttp    := ''

         _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonNFE , _nTimOut , _aHeadOut , @_cJSonRet ) )

         If ! Empty(_cRetHttp)
            _cRetHttp := StrTran( _cRetHttp, "\n", "" )
            FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
         EndIf

         _cAuxHTTP := Upper(_cRetHttp)

         _lResult := .F.
         If ! Empty(_oRetJSon) .And."STATUS" $ _cAuxHTTP
            _lResult := _oRetJSon:status
         EndIf

         If _lResult // Integração realizada com sucesso
            //=======================================================================
            // Grava dados das Notas Fiscais e Demonstrativos para histórico.
            //=======================================================================
            ZBM->(RecLock("ZBM",.F.))
            ZBM->ZBM_RETNFE :=  AllTrim(_cRetHttp)    // Retorno da Integração
            ZBM->ZBM_JSONNF := _cJSonNFE              // Json de Envio
            ZBM->ZBM_DTENVN := Date()                 // Data de Envio
            ZBM->ZBM_HRENVN := Time()                 // Hora de Envio
            ZBM->ZBM_STATNF := "P"                    // Status Processado
            ZBM->ZBM_STATUS := "A"                    // Status da Integração
            ZBM->(MsUnLock())

            ZBN->(MsSeek(ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE))
            Do While ! ZBN->(Eof()) .And. ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE == ZBN->ZBN_FILIAL+ZBN->ZBN_CHVNFE
               If ZBM->ZBM_REGCAP == ZBN->ZBN_REGCAP
                  ZBN->(RecLock("ZBN",.F.))
                  ZBN->ZBN_STATUS := "A"              // Status da Integração
                  ZBN->ZBN_STATNF := "P"
                  ZBN->(MsUnLock())
               EndIf

               ZBN->(DbSkip())
            EndDo

            // Comentar este trecho.
            //==============================================================
            // Atualiza a tabela SF1
            //==============================================================
            /*
            SF1->(RecLock("SF1", .F.))
            SF1->F1_I_SITUA := "P"	  // Situação Integração Cia Leite
            SF1->F1_I_DTENV := Date() // Data de Enviao para Evomilk
            SF1->F1_I_HRENV := Time() // Hora de Envio para Evomilk
            SF1->(MsUnLock())
            */
         Else
            //=======================================================================
            // Grava dados das Notas Fiscais e Demonstrativos para histórico.
            //=======================================================================
            ZBM->(RecLock("ZBM",.F.))
            ZBM->ZBM_RETNFE :=  AllTrim(_cRetHttp)    // Retorno da Integração
            ZBM->ZBM_JSONNF := _cJSonNFE              // Json de Envio
            ZBM->ZBM_DTENVN := Date()                 // Data de Envio
            ZBM->ZBM_HRENVN := Time()                 // Hora de Envio
            ZBM->ZBM_STATNF := "N"                    // Status Processado // ZBM->ZBM_STATNF := "P"                    // Status Processado
            ZBM->ZBM_STATUS := "R"                    // Status da Integração
            ZBM->(MsUnLock())

            ZBN->(MsSeek(ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE))
            Do While ! ZBN->(Eof()) .And. ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE == ZBN->ZBN_FILIAL+ZBN->ZBN_CHVNFE
               If ZBM->ZBM_REGCAP == ZBN->ZBN_REGCAP
                  ZBN->(RecLock("ZBN",.F.))
                  ZBN->ZBN_STATUS := "R"   // Status da Integração
                  ZBN->ZBN_STATNF := "N"   // ZBN->ZBN_STATNF := "P"
                  ZBN->(MsUnLock())
               EndIf

               ZBN->(DbSkip())
            EndDo

         EndIf

         _cJSonNFE := "["
         _cJSonGrp := ""
         _nI := 0

      EndIf

      _nI += 1

      QRYZBM->(DbSkip())
   EndDo

   If ! Empty(_cJSonGrp)
      _cJSonNFE += _cJSonGrp + "]"

      _cJSonNFE := DecodeUTF8(_cJSonNFE, "cp1252")

      _nStart 		:= 0
      _nRetry 		:= 0
      _cJSonRet 	:= Nil
      _nTimOut	 	:= 120

      _cRetHttp    := ''

      _cRetHttp := AllTrim( HttpPost( _cLinkWS , '' , _cJSonNFE , _nTimOut , _aHeadOut , @_cJSonRet ) )

      If ! Empty(_cRetHttp)
         _cRetHttp := StrTran( _cRetHttp, "\n", "" )
         FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)
      EndIf

       _cAuxHTTP := Upper(_cRetHttp)

      _lResult := .F.
      If ! Empty(_oRetJSon) .And. "STATUS" $ _cAuxHTTP // "status" $ _cRetHttp
         _lResult := _oRetJSon:status
      EndIf

      If _lResult // Integração realizada com sucesso
         //=======================================================================
         // Grava dados das Notas Fiscais e Demonstrativos para histórico.
         //=======================================================================
         ZBM->(RecLock("ZBM",.F.))
         ZBM->ZBM_RETNFE :=  AllTrim(_cRetHttp)    // Retorno da Integração
         ZBM->ZBM_JSONNF := _cJSonNFE              // Json de Envio
         ZBM->ZBM_DTENVN := Date()                 // Data de Envio
         ZBM->ZBM_HRENVN := Time()                 // Hora de Envio
         ZBM->ZBM_STATNF := "P"                    // Status Processado
         ZBM->ZBM_STATUS := "A"                    // Status da Integração
         ZBM->(MsUnLock())

         ZBN->(MsSeek(ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE))
         Do While ! ZBN->(Eof()) .And. ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE == ZBN->ZBN_FILIAL+ZBN->ZBN_CHVNFE
            If ZBM->ZBM_REGCAP == ZBN->ZBN_REGCAP
               ZBN->(RecLock("ZBN",.F.))
               ZBN->ZBN_STATUS := "A"              // Status da Integração
               ZBN->ZBN_STATNF := "P"
               ZBN->(MsUnLock())
            EndIf

            ZBN->(DbSkip())
         EndDo

         //==============================================================
         // Atualiza a tabela SF1
         //==============================================================
         /*
         SF1->(RecLock("SF1", .F.))
         SF1->F1_I_SITUA := "P"	  // Situação Integração Cia Leite
         SF1->F1_I_DTENV := Date() // Data de Enviao para Evomilk
         SF1->F1_I_HRENV := Time() // Hora de Envio para Evomilk
         SF1->(MsUnLock())
         */
      Else
         //=======================================================================
         // Grava dados das Notas Fiscais e Demonstrativos para histórico.
         //=======================================================================
         ZBM->(RecLock("ZBM",.F.))
         ZBM->ZBM_RETNFE :=  AllTrim(_cRetHttp)    // Retorno da Integração
         ZBM->ZBM_JSONNF := _cJSonNFE              // Json de Envio
         ZBM->ZBM_DTENVN := Date()                 // Data de Envio
         ZBM->ZBM_HRENVN := Time()                 // Hora de Envio
         ZBM->ZBM_STATNF := "N"                    // Status Processado // ZBM->ZBM_STATNF := "P"                    // Status Processado
         ZBM->ZBM_STATUS := "R"                    // Status da Integração //
         ZBM->(MsUnLock())

         ZBN->(MsSeek(ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE))
         Do While ! ZBN->(Eof()) .And. ZBM->ZBM_FILIAL+ZBM->ZBM_CHVNFE == ZBN->ZBN_FILIAL+ZBN->ZBN_CHVNFE
            If ZBM->ZBM_REGCAP == ZBN->ZBN_REGCAP
               ZBN->(RecLock("ZBN",.F.))
               ZBN->ZBN_STATUS := "R"              // Status da Integração
               ZBN->ZBN_STATNF := "N" // ZBN->ZBN_STATNF := "P"
               ZBN->(MsUnLock())
            EndIf

            ZBN->(DbSkip())
         EndDo

      EndIf

   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGL32LEN(_lSchedule)
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de Leitura de dados das Notas Fiscais para envio via WebService Italac para
                     Sistema Evomilk
===============================================================================================================================
Parametros--------:  _lSchedule = .T. = Rotina rodada em modo automático. .F. = Rotina rotada através de menu.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32LEN(_lSchedule)
Local _cQry := ""

Begin Sequence

   _cQry := " SELECT ZBM.R_E_C_N_O_ REGZBM, SF1.R_E_C_N_O_  REGSF1 "       // numero_identificador: "06019"
   _cQry += " FROM " + RetSqlName("SF1") + " SF1, " + RetSqlName("ZBM") + " ZBM "
   _cQry += " WHERE SF1.D_E_L_E_T_ = ' ' AND ZBM.D_E_L_E_T_ = ' ' "
   _cQry += " AND F1_FILIAL = ZBM_FILIAL "
   _cQry += " AND F1_FORNECE = ZBM_CODPRO "
   _cQry += " AND F1_LOJA    = ZBM_LOJPRO "
   _cQry += " AND F1_ESPECIE = 'SPED' "
   _cQry += " AND ZBM_STATNF = 'N' "

   If Select("QRYZBM") > 0
      QRYZBM->(DbCloseArea())
   EndIf


   MPSysOpenQuery( _cQry , "QRYZBM")

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32NF
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Gera arquivo TXT com os dados das Coletas Integradas Aceitas ou Rejeitadas, por filial.
===============================================================================================================================
Parametros---------: _cSituacao = Status da Coleta "A" = Aceita / "R" = Rejeitadas
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32NF(_cSituacao)
Local _cQry
Local _aFilSA2 := {}

Private _nTotRegs := 0

Default _cSituacao := "R"

Begin Sequence
   //==========================================================================
   // Gera arquivo TXT com os Dados dos Volumes coletados
   //==========================================================================
   Aadd(_aFilSA2, { "01","CORUMBAIBA"})
   Aadd(_aFilSA2, { "04","ARAGUARI"})
   Aadd(_aFilSA2, { "23","TAPEJARA"})
   Aadd(_aFilSA2, { "40","TRES_CORACOES"})
   Aadd(_aFilSA2, { "24","CRISSIUMAL"})
   Aadd(_aFilSA2, { "25","GIRUA"})
   Aadd(_aFilSA2, { "09","IPORA"})
   Aadd(_aFilSA2, { "02","ITAPACI"})
   Aadd(_aFilSA2, { "10","JARU"})
   Aadd(_aFilSA2, { "11","NOVA_MAMORE"})
   Aadd(_aFilSA2, { "20","PASSO_FUNDO"})
   Aadd(_aFilSA2, { "06","PONTALINA"})
   Aadd(_aFilSA2, { "0B","QUIRINOPOLIS"})
   Aadd(_aFilSA2, { "93","PARANA_CASCAVEL"})
   Aadd(_aFilSA2, { "31","CONCEICAO_DO_ARAGUAIA"})
   Aadd(_aFilSA2, { "32","COUTO_DE_MAGALHAES"})

   _cQry := " SELECT ZBM_FILIAL,ZBM_NRNFE,ZBM_SERNFE,ZBM_CHVNFE,ZBM_DTEMIS,ZBM_CODPRO,ZBM_LOJPRO,ZBM_NOMPRO, ZBM.R_E_C_N_O_ REGZBM
   _cQry += " FROM " + RetSqlName("SA2") + " SA2, " + RetSqlName("ZBM") + " ZBM "
   _cQry += " WHERE SA2.D_E_L_E_T_ = ' ' AND ZBM.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZBM_CODPRO = A2_COD AND ZBM_LOJPRO = A2_LOJA "
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_COD <> '      ' "
   _cQry += " AND ZBM_STATUS = '"+ _cSituacao + "' "
   _cQry += " AND A2_L_ENVEV = 'N' "

   If ! Empty(MV_PAR01)
      _cQry += " AND ZBM_DTENVN >= '"+Dtos(MV_PAR01)+"' "
   EndIf

   If ! Empty(MV_PAR02)
      _cQry += " AND ZBM_DTENVN <= '"+Dtos(MV_PAR02)+"' "
   EndIf

   _cQry += " ORDER BY ZBM_FILIAL, ZBM_CODPRO, ZBM_LOJPRO "

    If Select("QRYZBM") > 0
       QRYZBM->(DbCloseArea())
    EndIf

    MPSysOpenQuery( _cQry , "QRYZBM")

    TCSetField('QRYZBM',"ZBM_DTEMIS","D",8,0)

    DBSelectArea("QRYZBM")//O MPSysOpenQuery() NÃO DEIXA NA AREA NOVA
    Count to _nTotRegs

    QRYZBM->(DbGotop())

    Processa( {|| U_MGLT32TF(_aFilSA2,_nTotRegs,_cSituacao) } , 'Aguarde!' , 'Gravando Arquivo Texto das Notas Fiscais/Demonstrativos...' )

    U_ItMsg("Geração de arquivo TXT com os dados das Notas Fiscais/Demonstrativos concluido.","Atenção",,2)

End Sequence

If Select("QRYZBM") > 0
   QRYZBM->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGLT32TF
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Rotina de geração de arquivo TxT das Notas fiscais/Demonstrativos.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGLT32TF(_aFilSA2,_nTotRegs,_cSituacao)
Local _cDados
Local _nJ

Default _cSituacao := "R"

_cDirTXT:=_cNomeArq:=""

Begin Sequence

   ProcRegua(_nTotRegs)

   _cDirTXT := GetTempPath()
   If _cSituacao == "R"
      _cNomeArq:= "Dados_das_Notas_Fiscais_Demonstrativos_Rejeitadas_nas_Integrações" + Dtos(Date()) + ".Txt"
   Else
      _cNomeArq:= "Dados_das_Notas_Fiscais_Demonstrativos_Aceitas_nas_Integrações" + Dtos(Date()) + ".Txt"
   EndIf

   _oFWriter := FWFileWriter():New(_cDirTXT + _cNomeArq , .T.)

   If ! _oFWriter:Create()
      U_ItMsg("Erro na criação do arquivo texto para gravação dos dados das notas fiscais/demonstrativos Integradas.","Atenção",,1)
      Break
   EndIf

   //_oFWriter:Write("UNIDADE;MATRICULA;CPF;NOME;RETORNO_APP;JSON_ENVIO;" + CRLF)
   _oFWriter:Write("UNIDADE;NOTA_FISCAL;SERIE;CHAVE_NOTA_FISCAL;EMISSÃO_NF;CODIGO_PRODUTOR;LOJA_PRODUTOR;NOME_PRODTOR;MSG_RETORNO_APP;DADOS_DE_ENVIO;"+ CRLF)

   QRYZBM->(DbGoTop())

   _nJ := 1

   _oFWriter:Write("")

   Do While ! QRYZBM->(Eof())

      IncProc("Gerando arquivo texto: "+ StrZero(_nJ,6) + " de " + StrZero(_nTotRegs,6) + "...")
      _nJ += 1

      ZBM->(DbGoto(QRYZBM->REGZBM))

      //====================================================================
      // Efetua a leitura dos dados e montagem do JSon.
      //====================================================================

      _cDados := QRYZBM->ZBM_FILIAL + ";"
      _cDados += QRYZBM->ZBM_NRNFE  +";"
      _cDados += QRYZBM->ZBM_SERNFE +";"
      _cDados += QRYZBM->ZBM_CHVNFE +";"
      _cDados += Dtoc(QRYZBM->ZBM_DTEMIS)+";"
      _cDados += QRYZBM->ZBM_CODPRO+";"
      _cDados += QRYZBM->ZBM_LOJPRO+";"
      _cDados += QRYZBM->ZBM_NOMPRO+";"
      _cDados += AllTrim(ZBM->ZBM_RETNFE)+";"
      _cDados += AllTrim(ZBM->ZBM_JSONNF)
      _cDados += CRLF

      _oFWriter:Write(_cDados)

      QRYZBM->(DbSkip())
   EndDo

   _oFWriter:Write("")

   //Encerra o arquivo
   _oFWriter:Close()

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGL32PDF(_lSchedule)
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Faz a regravação dos PDFs das Notas Fiscais e Demonstrativos em Encode64,
                     quando a rotina principal não consegue gravar.
===============================================================================================================================
Parametros--------:  _lSchedule = .T. = Rotina rodada em modo automático. .F. = Rotina rotada através de menu.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32PDF(_lSchedule)
Local _cQry := ""

Begin Sequence

   _cQry := " SELECT ZBM.R_E_C_N_O_ REGZBM "       // numero_identificador: "06019"
   _cQry += " FROM "  + RetSqlName("ZBM") + " ZBM "
   _cQry += " WHERE ZBM.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZBM_STATNF = 'N' "

   If Select("ZBMPDF") > 0
      ZBMPDF->(DbCloseArea())
   EndIf


   MPSysOpenQuery( _cQry , "ZBMPDF")

   Do While ! ZBMPDF->(Eof())
      ZBM->(DbGoTo(ZBMPDF->REGZBM))

      If Empty(ZBM->ZBM_PDFNFE )
         _cDir       := AllTrim(ZBM->ZBM_DIRARQ)
         _cFilePrint := AllTrim(ZBM->ZBM_NARQDA)

         _cEcod64Nf := Encode64( ,_cDir + _cFilePrint)

         ZBM->(RecLock("ZBM",.F.))
         ZBM->ZBM_PDFNFE := _cEcod64Nf	// Pdf NFE em ENCODE 64
         ZBM->(MsUnlock())

         If Type("_cEcod64Nf") == "O"
            FreeObj(_cEcod64Nf)
         EndIf

	      _cEcod64Nf := Nil
      EndIf

      If Empty(ZBM->ZBM_PDFEXT)
         _cDir      := AllTrim(ZBM->ZBM_DIRARQ)
         _cPdfExtra := AllTrim(ZBM->ZBM_NARQEX )

         _cEcod64Ex := Encode64( ,_cDir + _cPdfExtra)

         ZBM->(RecLock("ZBM",.F.))
         ZBM->ZBM_PDFEXT := _cEcod64Ex	 // Pdf Extrato NFE ENCODE 64
         ZBM->(MsUnlock())

         If Type("_cEcod64Ex") == "O"
            FreeObj(_cEcod64Ex)
         EndIf
	      _cEcod64Ex := Nil
      EndIf

      ZBMPDF->(DbSkip())

   EndDo

End Sequence

If Select("ZBMPDF") > 0
   ZBMPDF->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Função-------------: MGL32LNF
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Chama a rotina de integração de notas fiscais, para leitura de dados, geração de PDF de Danfe
                     e PDF de Demonstrativos, e gravação das tabelas de ZBM e ZBN para envio ao app Evomilk.
                     Rotina rodada em modo Scheduller.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32LNF()

Begin Sequence

   //===================================================================
   // Chama a rotina de leitura e gravação de dados das notas fiscais
   // para envio ao App Evomilk.
   // Esta função é para programação do Scheduler.
   //===================================================================
   U_MGL32NFS("L")

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGL32TNF
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Chama a rotina de integração de notas fiscais, de leitura das tabelas gravadas ZBM e ZBN, rodada em
                     modo Scheduller, e transmite via Webservice para o App Evomilk.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function MGL32TNF()

Begin Sequence

   //===================================================================
   // Chama a rotina de leitura das tabelas ZBM e ZBN e transmite a
   // nota fiscal via webservice para envio ao App Evomilk.
   // Esta função é para programação do Scheduler.
   //===================================================================
   U_MGL32NFS("T")

End Sequence

Return Nil

/*
===============================================================================================================================
Função-------------: MGL32CNF()
Autor--------------: Julio de Paula Paz
Data da Criacao----: 28/10/2024
===============================================================================================================================
Descrição----------: Faz a contagem das notas fiscais disponíveis para integração.
===============================================================================================================================
Parametros--------:  Nenhum
===============================================================================================================================
Retorno------------: _nTotalNF = Total de notas fiscias disponíveis para integração
===============================================================================================================================
*/
User Function MGL32CNF()
Local _nTotalNF := 0
Local _nNrDiasNFE
Local _cQry

Begin Sequence

   _nNrDiasNFE := SUPERGETMV('IT_NRDIANF',.F.,  730) // _nNrDiasNFE := SUPERGETMV('IT_NRDIANF',.F.,  30) // Numero de dias para considerar a leituras das notas fiscais de produtores.

   _cAnoMes := Str(Year(Date() - _nNrDiasNFE),4) + StrZero(Month(Date() - _nNrDiasNFE),2)

   _cQry := " SELECT Count(*) NTOTNOTAS "
   _cQry += " FROM "+RETSQLNAME("SF1") +" SF1 "
   _cQry += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA AND SA2.A2_I_CLASS = 'P' "
   _cQry += " INNER JOIN SYS_COMPANY SM0 ON M0_CODIGO = '01' AND M0_CODFIL = F1_FILIAL     AND SM0.D_E_L_E_T_ = ' ' "
   _cQry += " INNER JOIN SPED001 SPED01 ON SPED01.CNPJ = SM0.M0_CGC AND SPED01.IE = SM0.M0_INSC     AND SPED01.D_E_L_E_T_ = ' ' "
   _cQry += " INNER JOIN SPED050 SPED50 ON  SPED50.ID_ENT = SPED01.ID_ENT     AND SPED50.NFE_ID = (F1_SERIE || F1_DOC)     AND SPED50.STATUS = '6'     AND SPED50.D_E_L_E_T_ = ' ' "
   _cQry += " WHERE "
   _cQry += " SF1.D_E_L_E_T_ =' ' "
   _cQry += " AND F1_ESPECIE = 'SPED' "
   _cQry += " AND F1_CHVNFE <> ' ' "
   _cQry += " AND SUBSTR(F1_EMISSAO,1,6) = '"+ _cAnoMes + "' "
   _cQry += " AND A2_I_CLASS = 'P' "
   _cQry += " AND A2_MSBLQL = '2' "
   _cQry += " AND A2_L_ATIVO <> 'N' "
   _cQry += " AND SA2.A2_L_ENVEV = 'N' "
   _cQry += " AND F1_FORMUL = 'S' "
   _cQry += " AND (F1_I_SITUA = ' ' OR F1_I_SITUA = 'N') "
   _cQry += " AND F1_FILIAL = '" + xFilial("SF1") + "' "
   _cQry += " AND F1_SERIE = '3' " // Serie 3 = Notas fiscais de produtores de leite.

   If Select("QRYTOTNF") > 0
      QRYTOTNF->(DbCloseArea())
   EndIf


   MPSysOpenQuery( _cQry , "QRYTOTNF")

   _nTotalNF := QRYTOTNF->NTOTNOTAS

End Sequence

If Select("QRYTOTNF") > 0
   QRYTOTNF->(DbCloseArea())
EndIf

Return _nTotalNF

