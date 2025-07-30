/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 20/10/2017 | Chamado 22114. Separação do envio de EMAIL da Carga e do Status do PV no Schedule - 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 02/07/2019 | Chamado 29759. Alterar a rotina de envio de e-mail para ler dados das tabela ZFU e ZGY.  
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 16/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 28/02/2024 | Chamado 46694. Jerry. Alteracao para não marcar e-mail enviado se o e-mail não for enviado.
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'  
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"

/*
=========================================================================================================================================================
Programa----------: AOMS101
Autor-------------: Alex Wallauer
Data da Criacao---: 30/05/2017
=========================================================================================================================================================
Descrição---------: Rotina para Ler os dados das do muro das cargas e enviar e-mail de cargas e Status do PV para o RDC - Chamado 20224
=========================================================================================================================================================
Parametros--------: Nenhum
=========================================================================================================================================================
*/  
User Function AOMS101(_cLEnvio)//U_AOMS101
Local _aCores     := {}
Local _cQry 
Local _aCmp
Local _aStrucTrb
Local _cDtInicial //:= U_ItGetMv("IT_ENVEML",Ctod("01/01/2019"))  

Private aRotina   := {}
Private _nConta   := 0
Private _nConSta  := 0
Private _nTotRegs := 0

DEFAULT _cLEnvio := {"E"}//-Email ou "S"=Status ou "T"-Tela
PRIVATE _cEnvio:=_cLEnvio[1]

Begin Sequence
   //==========================================================================
   // Determina se existe tabelas abertas e é processamento em tela,
   // caso contrário é processamento em Scheduller.
   //==========================================================================
   _lScheduler := ( Select("SM0") <= 0 )

   //==========================================================================
   // Se for processamento Scheduller abre os ambientes
   //==========================================================================
   If _lScheduler
      SET DATE FORMAT TO "DD/MM/YYYY"
      U_ITCONOUT("Abrindo Ambientes para Envio de Email das Cargas e Status do PV")
      RPCSetType(3)
      RpcSetEnv( "01" , "01" ,,,"ESP2", "SCHEDULE_WF_SOLICITACAO" , {'DAK','DAI','ZFU', 'ZGY'} )
      Sleep( 3000 ) // Aguarda 5 segundos para subam as configurações do ambiente.
   EndIf

   _cDtInicial := U_ItGetMv("IT_ENVEML",Ctod("01/01/2019"))  
    
   //================================================================================
   // Lista os dados da tabela ZFU (Cargas)  e ZGY (Situação de Pedido de Venmdas)
   //================================================================================
   _cQry := "SELECT ZFU_FILIAL, ZFU_DATA, ZFU_HORA, ZFU_CODIGO, ZFU_NCARGA, ZFU_ENMAIL, ' ' AS ZGY_ENSTUS,"
   _cQry += " ZFU_RDCUSR, ZFU_SITUAC, ZFU_RETORN, ZFU.R_E_C_N_O_ ZFU_REC, 0 AS ZGY_REC "
   _cQry += " FROM "+ RetSqlName("ZFU") +" ZFU "
   _cQry += " WHERE ZFU.D_E_L_E_T_ <> '*' "
   _cQry += " AND ZFU.ZFU_DATA >= '" + Dtos(_cDtInicial) + "' "
   _cQry += " AND ZFU.ZFU_ENMAIL = 'S' "
   _cQry += " UNION"
   _cQry += " SELECT ZGY_FILIAL AS ZFU_FILIAL, ZGY_DATA AS ZFU_DATA , ZGY_HORA  AS ZFU_HORA, ZGY_CODIGO AS ZFU_CODIGO,"
   _cQry += " ZGY_NCARGA AS ZFU_NCARGA, ' ' AS ZFU_ENMAIL, ZGY_ENSTUS , ' ' AS  ZFU_RDCUSR, ZGY_SITUAC AS ZFU_SITUAC, ZGY_RETORN AS ZFU_RETORN,"
   _cQry += " 0 AS ZFU_REC, ZGY.R_E_C_N_O_ AS ZGY_REC "
   _cQry += " FROM "+ RetSqlName("ZGY") +" ZGY "
   _cQry += " WHERE ZGY.D_E_L_E_T_ <> '*' "
   _cQry += " AND ZGY.ZGY_DATA >= '" + Dtos(_cDtInicial) + "' "
   _cQry += " AND ZGY.ZGY_ENSTUS = 'S' "
   _cQry += " ORDER BY ZFU_FILIAL, ZFU_DATA, ZFU_ENMAIL, ZGY_ENSTUS "
   
   If Select("QRYTRB") > 0
      QRYTRB->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYTRB" , .T. , .F. )
   DBSELECTAREA("QRYTRB")
   
   //TCSetField( < cAlias >, < cField >, < cType >, [ nSize ], [ nPrecision ] )
   TCSetField( "QRYTRB", "ZFU_DATA", "D", 8 )

   DbSelectArea("QRYTRB")
   Count To _nTotRegs

   //================================================================================
   // Define a estrutura da tabela TRB.
   //================================================================================
   _aStrucTrb := {}
   Aadd(_aStrucTrb,{ "ZFU_FILIAL" ,"C", 2  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_DATA"   ,"D", 8  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_HORA"   ,"C", 8  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_CODIGO" ,"C", 9  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_NCARGA" ,"C", 6  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_ENMAIL" ,"C", 1  , 0, "" })
   Aadd(_aStrucTrb,{ "ZGY_ENSTUS" ,"C", 1  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_RDCUSR" ,"C", 6  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_SITUAC" ,"C", 1  , 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_RETORN" ,"C", 400, 0, "" })
   Aadd(_aStrucTrb,{ "ZFU_REC"    ,"N", 10 , 0, "" })
   Aadd(_aStrucTrb,{ "ZGY_REC"    ,"N", 10 , 0, "" })

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRB") > 0
      TRB->( DBCloseArea() )
   EndIf
   
   //================================================================================
   // Abre o arquivo TRBZAE criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRB",  _aStrucTrb )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZFU_FILIAL", "ZFU_DATA"} )
   _otemp:AddIndex( "02", {"ZFU_FILIAL", "ZFU_ENMAIL"} )
   _otemp:AddIndex( "03", {"ZFU_FILIAL", "ZGY_ENSTUS"} )
   _otemp:AddIndex( "04", {"ZFU_ENMAIL"} )
   _otemp:AddIndex( "05", {"ZGY_ENSTUS"} )
   _otemp:Create()

   Processa( {|| U_AOMS101Q(_nTotRegs) } ,, "Carregando Dados Carga/Situacao PV..." )

   DbSelectArea("TRB")
   TRB->(DbSetOrder(1)) 
   TRB->(DbGoTop())

   //================================================================================   
   // Processamento em tela 
   //================================================================================
   IF !_lScheduler
      _cEnvio := "T"
      cCadastro := "LISTA DAS CARGAS QUE NAO ENVIARAM E-MAIL"

      Aadd(aRotina,{"Pesquisar" ,"AxPesqui"   ,0,1})
      Aadd(aRotina,{"Visualizar","U_AOMS085V" ,0,2})   
      Aadd(aRotina,{"Envia Email Atual","U_AOMS101A(.F.)" ,0,6})
      Aadd(aRotina,{"Envia Email Todos","U_AOMS101A(.T.)" ,0,6})

      Aadd(_aCores,{"ZFU_ENMAIL == 'S' .OR. ZGY_ENSTUS == 'S'" ,"BR_VERDE" })
      Aadd(_aCores,{"(ZFU_ENMAIL == 'N' .AND. ZGY_ENSTUS == ' ') .Or. (ZFU_ENMAIL == ' ' .AND. ZGY_ENSTUS == 'N') " ,"BR_VERMELHO" })

      //Aadd(_aCmp, {"Titulo", {|| Alias->campo}, "Tipo", Tamanho, Decimal, ""})
       _aCmp := {}
      Aadd(_aCmp,{ "Filial"                  , {|| TRB->ZFU_FILIAL} ,"C", 2  , 0, "" })
      Aadd(_aCmp,{ "Emissão"                 , {|| TRB->ZFU_DATA}   ,"D", 8  , 0, "" })
      Aadd(_aCmp,{ "Hora"                    , {|| TRB->ZFU_HORA}   ,"C", 8  , 0, "" })
      Aadd(_aCmp,{ "Carga RDC/Ped.Vend"      , {|| TRB->ZFU_CODIGO} ,"C", 9  , 0, "" })
      Aadd(_aCmp,{ "Carga Protheus/Ped.Vend" , {|| TRB->ZFU_NCARGA} ,"C", 6  , 0, "" })
      Aadd(_aCmp,{ "Envia Email"             , {|| TRB->ZFU_ENMAIL} ,"C", 1  , 0, "" })
      Aadd(_aCmp,{ "Envia Status PV"         , {|| TRB->ZGY_ENSTUS} ,"C", 1  , 0, "" })
      Aadd(_aCmp,{ "Usuario RDC"             , {|| TRB->ZFU_RDCUSR} ,"C", 6  , 0, "" })
      Aadd(_aCmp,{ "Situação"                , {|| TRB->ZFU_SITUAC} ,"C", 1  , 0, "" })
      Aadd(_aCmp,{ "Retorno"                 , {|| TRB->ZFU_RETORN} ,"C", 250, 0, "" })
      Aadd(_aCmp,{ "Recno Carga"             , {|| TRB->ZFU_REC}    ,"N", 10 , 0, "" })
      Aadd(_aCmp,{ "Recno Status PV"         , {|| TRB->ZGY_REC}    ,"N", 10 , 0, "" })

      // mBrowse(,,,,cAli>,<aFixe, <cCpo>, <nPar>, <cCorFun>, <nClickDef>, <aColors>, <cTopFun>, <cBotFun>, <nPar14>, <bInitBloc>, <lNoMnuFilter>, <lSeeAll>, <lChgAll>, <cExprFilTop>, <nInterval>, <uPar22>, <uPar23> )
      mBrowse(,,,,"TRB",_aCmp ,       ,       ,          ,            , _aCores)
   ELSE
      //================================================================================   
      // Processamento em Sheduller 
      //================================================================================  
      U_AOMS101A(.T.)
  
   ENDIF   


End Sequence

//====================================================================================
// Fecha as tabelas temporárias, caso estejam abertas.
//====================================================================================
If Select("QRYTRB") > 0
   QRYTRB->( DBCloseArea() )
EndIf

If Select("TRB") > 0
   TRB->( DBCloseArea() )
EndIf


Return Nil    


/*
===============================================================================================================================
Função------------: AOMS101A
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição-------: Função para rodar a rotina de integração de forma agendada (Scheduller).
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum                  
===============================================================================================================================
*/
USER Function AOMS101A(_lTodos)

Begin Sequence
   //================================================================================
   // Processamento em Tela
   //================================================================================
   If !_lScheduler
      cObs:=""

      Processa( {|| cObs:=U_AOMS101E(_lTodos) } )

	   U_ITMSG(cObs,;
			   "Envios Concluidos",;
			   "As Cargas não encontradas foram marcadas para não enviar mais.",2)
      Break 
   ENDIF

   //================================================================================
   // Processamento em Scheduller: Lê os dados e envia e-mail
   //================================================================================
   U_ITCONOUT("ENVIANDO ["+_cEnvio+"] - Envio de Email e Status do PV")
   cObs:=U_AOMS101E(_lTodos)

   U_ITCONOUT("CONCLUIDO ["+_cEnvio+"] - Envio de Email e Status do PV")

End Sequence

Return .T.

/*
===============================================================================================================================
Função------------: AOMS101E
Autor-------------: Alex Wallauer
Data da Criacao---: 30/05/2017
===============================================================================================================================
Descrição-------: Função para enviar e-mail
===============================================================================================================================
Parametros------: _lTodos = .T. = Envia e-mail para todos os registros da tabela temporária TRB.
                          = .F. = Envia e-mail para o registro posicionado na tabela TRB.
===============================================================================================================================
Retorno---------: Nenhum                  
=============================================================================================================================== 
*/
User Function AOMS101E( _lTodos )

LOCAL _cFilOld:= cFilAnt
LOCAL _cCarga := ""
LOCAL _cAlias
PRIVATE _lEnvioOK:=.T.//ALTERADO NA FUNCTION OM200EMAIL() DO OM200FIM.PRW


Begin Sequence

   If ! _lScheduler
      ProcRegua(0)
      IncProc("Lendo dados...")
      IncProc("Lendo dados...")
   Else
      cUsuario := SPACE(06)+"Administrador  "
      cUsername:= "Schedure"
   EndIf

   If !_lScheduler
      ProcRegua(_nTotRegs)
   ELSE
      U_ITCONOUT(ALLTRIM(STR(_nTotRegs,10))+' Registros encontrados. SELECT: ')
   ENDIF

   DAK->(DBSETORDER(1))
   SC5->(DbSetOrder(1) )
   DAI->(DBSetOrder(1) )

   cObs:=""
   _nConta:=0
   _nConSta:=0
   _aPVsEmail :={}
   _aPVsStatus:={}

   If _lTodos
      TRB->(DBGOTOP())
   EndIf

   DO WHILE TRB->(!EOF())  
      If TRB->ZFU_REC > 0
         _lPV := .F.
         ZFU->(DBGOTO(TRB->ZFU_REC ))
      Else
         _lPV := .T.
         ZGY->(DBGOTO(TRB->ZGY_REC ))
      EndIf

      If !_lScheduler
         If ! _lPV
            IncProc("Lendo Filial/Carga: "+ZFU->ZFU_FILIAL+"-"+ZFU->ZFU_CODIGO )
         Else
            IncProc("Lendo Filial/Ped.Venda: "+ZGY->ZGY_FILIAL+"-"+ZGY->ZGY_CODIGO )
         EndIf
      ENDIF
   
      If ! _lPV
         cFilAnt :=ZFU->ZFU_FILIAL
         _cCarga :=ALLTRIM(ZFU->ZFU_NCARGA)  
      Else
         cFilAnt :=ZGY->ZGY_FILIAL
         _cCarga :=ALLTRIM(ZGY->ZGY_NCARGA) 
      EndIf
   
      _cObsAux:=""

      _lEnvioOK:=.T.//ALTERADO NA FUNCTION OM200EMAIL() DO OM200FIM.PRW
      DAK->(DBSETORDER(1))//No envio do email muda a ordem
      IF ! _lPV .AND. (EMPTY(_cCarga) .OR. !DAK->(DBSEEK(cFilAnt+_cCarga)))
         _cObsAux:="[DAK] Carga não Encontrada: [Filial "+ZFU->ZFU_FILIAL+"] [RDC: "+ALLTRIM(ZFU->ZFU_CODIGO)+"] [Protheus: "+_cCarga+"]"
      ELSE
         //===============================================================
         //             ENVIO DE EMAIL (Carga) 
         //===============================================================
         _lEnvioOK:=.T.//ALTERADO NA FUNCTION OM200EMAIL() DO OM200FIM.PRW
         IF _cEnvio $ "E,T" .AND. !_lPV .AND. ZFU->ZFU_ENMAIL = "S" .AND. ASCAN(_aPVsEmail,cFilAnt+_cCarga) = 0
            _cMailUsrCarga:=Posicione("ZZL",5,xfilial("ZZL")+AllTrim(ZFU->ZFU_RDCUSR),"ZZL_EMAIL") // E-mail do usuário que criou a carga utilizado na rotina de envio de e-mail da carga.
            _cEmlLog:=""
            __cUserID := SubStr( Embaralha( DAK->DAK_USERGI, 1 ), 3, 6 )
            U_OM200Email(.F.,Nil,.T.,.T.,.F.)//_lEstorno,_aCargas,_lEnviaDireto,_lScheduller,_lMarcaEnvio
            _nConta++
            _cObsAux:="[DAK] "+ALLTRIM(STR(_nConta,10))+" E-mail(s) Enviado(s), Carga: [Filial "+ZFU->ZFU_FILIAL+"] [RDC: "+ALLTRIM(ZFU->ZFU_CODIGO)+"] [Protheus: "+_cCarga+"]"
            IF !EMPTY(_cEmlLog)
               _cObsAux+=" [Log: "+ALLTRIM(_cEmlLog)+"]"
            ENDIF
            AADD(_aPVsEmail,cFilAnt+_cCarga)
         ENDIF

         //===============================================================
         //             ENVIO DE Status Pedido de Vendas 
         //===============================================================
         If ZGY->ZGY_ENSTUS = "S" .AND. ASCAN(_aPVsStatus,cFilAnt+_cCarga) = 0
         
            If ! Empty(_cObsAux)
               _cObsAux+=CHR(13)+CHR(10)
            EndIf

            IF _cEnvio $ "S,T" .AND. _lPV
               //********  ENVIO DOS STATUS DOS PEDIDOS 
               SC5->(DbSetOrder(1) )
               If SC5->( DbSeek( cFilAnt+_cCarga ) )
                  U_ENVSITPV(,.F.)  //Envia situação do pedido de venda para o RDC
                  _nConSta++
                  //U_GrvMonitor()//Monitor pedido de vendas
                  _cObsAux+="[SC5] "+ALLTRIM(STR(_nConSta,10))+" Envio(s) de Status efetuado(s), Pedido: [Filial "+cFilAnt+"] [PV: "+_cCarga+"] "
               ELSE
                  _cObsAux+="[SC5] Pedido não Encontrado: [Filial "+cFilAnt+"] [PV: "+_cCarga+"] "
               ENDIF 
        
            ELSEIF _cEnvio $ "E,T"
               //********  ENVIO DOS STATUS DOS PEDIDOS DA CARGA QUANDO ENVIA O EMAIL
               DAI->(DBSetOrder(1) )
               If DAI->( DBSeek( DAK->DAK_FILIAL + DAK->DAK_COD ) )
                  _cObsAux+="[DAI] Carga para Envio de Status de PV: [Filial "+ZGY->ZGY_FILIAL+"] [RDC: "+ALLTRIM(ZGY->ZGY_CODIGO)+"] [Protheus: "+_cCarga+"]"
	               DO While DAI->( !EOF() ) .And. DAI->DAI_FILIAL + DAI->DAI_COD == DAK->DAK_FILIAL + DAK->DAK_COD
                     SC5->(DbSetOrder(1) )
                     If SC5->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
                        U_ENVSITPV(,.F.)  //Envia situação do pedido de venda para o RDC
                        _nConSta++
                        //U_GrvMonitor()//Monitor pedido de vendas
                        _cObsAux+=CHR(13)+CHR(10)+"[DAI] "+ALLTRIM(STR(_nConSta,10))+" Envio(s) de Status efetuado(s), PV: [Filial "+DAI->DAI_FILIAL+"] [PV: "+DAI->DAI_PEDIDO+"] "
                     ELSE
                        _cObsAux+=CHR(13)+CHR(10)+"[DAI] Pedido não Encontrado: [Filial "+DAI->DAI_FILIAL+"] [PV: "+DAI->DAI_PEDIDO+"] "
                     ENDIF 
                     DAI->( DBSKIP() )
                  ENDDO
               ELSE
                  _cObsAux+="[DAI] Carga não Encontrada: [Filial "+ZGY->ZGY_FILIAL+"] [RDC: "+ALLTRIM(ZGY->ZGY_CODIGO)+"] [Protheus: "+_cCarga+"]"
               ENDIF

            ENDIF
            AADD(_aPVsStatus,cFilAnt+_cCarga)
         ENDIF
      ENDIF
     
      If ! _lPV
         IF _lEnvioOK
            ZFU->(DBGOTO(TRB->ZFU_REC ))
            ZFU->(RECLOCK("ZFU",.F.))
            If _cEnvio $ "E,T"
               ZFU->ZFU_ENMAIL:="N" // DesMarcou para enviar E-MAIL
            EndIf
            ZFU->(MsUnLock())
   
            TRB->(RecLock("TRB",.F.))
            TRB->ZFU_ENMAIL := "N"
            TRB->(MsUnLock())
         ENDIF
      Else
         ZGY->(DBGOTO(TRB->ZGY_REC ))
         ZGY->(RECLOCK("ZGY",.F.))
         ZGY->ZGY_ENSTUS := "N" // DesMarcou para enviar Status
         ZGY->(MsUnLock())

         TRB->(RecLock("TRB",.F.))
         TRB->ZGY_ENSTUS := "N"
         TRB->(MsUnLock())
      EndIf

      IF !EMPTY(_cObsAux)
         cObs+=_cObsAux+CHR(13)+CHR(10)
         _cObsAux:=STRTRAN(_cObsAux,CHR(13)+CHR(10)," ")
         U_ITCONOUT(_cObsAux)
      ENDIF
      
      //===================================================================
      // Se o usuário opnou pelo registro posicionado finaliza o looping.
      //===================================================================
      If ! _lTodos 
         Exit 
      EndIf

      TRB->(DBSKIP())
   EndDo 

   cFilAnt:=_cFilOld

   _cAlias:="[SC5] "
   IF _cEnvio $ "E,T"
      cObs+="[DAK] "+ALLTRIM(STR(_nConta,10))+' Email(s) enviado(s)'+CHR(13)+CHR(10)
      U_ITCONOUT("[DAK] "+ALLTRIM(STR(_nConta,10))+' Email(s) enviado(s)')
      IF _cEnvio = "T"
         _cAlias+="[DAI] "
      ELSE
         _cAlias:="[DAI] "
      ENDIF
   ENDIF

   cObs+=_cAlias+ALLTRIM(STR(_nConSta,10))+' Status enviados'
   U_ITCONOUT(_cAlias+ALLTRIM(STR(_nConSta,10))+' Status enviados')

End Sequence

Return cObs

/*
===============================================================================================================================
Função------------: AOMS093Q
Autor-------------: Julio de Paula Paz
Data da Criacao---: 02/07/2019
===============================================================================================================================
Descrição-------: Lê os dados da query e grava na tabela temporária TRB
===============================================================================================================================
Parametros------: _nTotRegs = Total de registros a serem processados
===============================================================================================================================
Retorno---------: Nenhum                  
===============================================================================================================================
*/
User Function AOMS101Q(_ntotRegs)
Local _nI := 0

Begin Sequence
   ProcRegua(_ntotRegs)

   QRYTRB->(DbGoTop())

   Do While ! QRYTRB->(Eof())
      _nI += 1
      IncProc("Carregando Dados: "+ StrZero(_nI,10)+ "/" + StrZero(_ntotRegs,10))

      TRB->(RecLock("TRB", .T.))
      TRB->ZFU_FILIAL := QRYTRB->ZFU_FILIAL
      TRB->ZFU_DATA   := QRYTRB->ZFU_DATA 
      TRB->ZFU_HORA   := QRYTRB->ZFU_HORA
      TRB->ZFU_CODIGO := QRYTRB->ZFU_CODIGO
      TRB->ZFU_NCARGA := QRYTRB->ZFU_NCARGA
      TRB->ZFU_ENMAIL := QRYTRB->ZFU_ENMAIL
      TRB->ZGY_ENSTUS := QRYTRB->ZGY_ENSTUS
      TRB->ZFU_RDCUSR := QRYTRB->ZFU_RDCUSR
      TRB->ZFU_SITUAC := QRYTRB->ZFU_SITUAC
      TRB->ZFU_RETORN := QRYTRB->ZFU_RETORN
      TRB->ZFU_REC    := QRYTRB->ZFU_REC
      TRB->ZGY_REC    := QRYTRB->ZGY_REC
      TRB->(MsUnlock()) 

      QRYTRB->(DbSkip())
   EndDo

End Sequence

Return Nil
