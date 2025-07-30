/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------        
Igor Melgaco      | 10/11/2023 | Chamado 45530 - Ajustes para inclusão e exclusão de funcionário do relogio 
Igor Melgaco      | 10/11/2023 | Chamado 45530 - Ajustes de passagem de parametro qdo executado pelo cadastro do funcionario.
Igor Melgaco      | 10/11/2023 | Chamado 45836 - Ajustes para melhoria de performance na deleção no relogio.
Igor Melgaco      | 10/11/2023 | Chamado 45897 - Ajustes para atualização do Nome Social.
Lucas Borges      | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Lucas              Igor Melgaço      - 09/06/2025 - 09/06/2025 - 50985   - Ajuste para não execução da rotina em ambiente de DESENV/HOMOLO/SIMULA e TMS
=========================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

Static _cAlias2  := GetNextAlias()
Static _cAlias3  := GetNextAlias()
Static _cAlias   := GetNextAlias()
Static _cSession := ""
Static lGP010    := .F.
Static aLog      := {}
Static aLogERR   := {}

/*
===============================================================================================================================
Programa----------: MGPE026
Autor-------------: Igor Melgaço
Data da Criacao---: 11/10/2023
===============================================================================================================================
Descrição---------: Rotina de atualização de equipamentos de ponto via API CONTROLID - Chamado 44951 
===============================================================================================================================
Parametros--------: nOper => 1 - Inclusão / 2 - Alteração / 3 - Exlusão
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE026(nOper)

Local _oSelf     := Nil
Local _aParRet   := {}
Local _aParAux   := {}
Local _bOK       := {||.T.  }
Local _nTamFun   := 0
Local _nI        := 0
Local _lSchedule := FWGetRunSchedule() .OR. SELECT("SX3") <= 0

Default nOper := 0

aLog      := {}
aLogERR   := {}

If _lSchedule //Cria ambiente se for schedule

   MV_PAR01 := ""
   MV_PAR02 := "000000"
   MV_PAR03 := "ZZZZZZ"

	RPCSetType(3)
	RpcSetEnv( "01" , "01" ,,,"GPE", "SCHEDULE_ATUA" , {'SRA','SP0'} )
	Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

   If !SuperGetMV("IT_AMBTEST",.F.,.T.)
      MGPE026INT(_oSelf)
   EndIf
Else
   _nTamFun   := TamSX3("RA_MAT")[1]

   MV_PAR01 := Space(99)
   MV_PAR02 := Space(_nTamFun)
   MV_PAR03 := Space(_nTamFun)

   lGP010   := FwIsInCallStack("U_GP010AGRV") //Inclusão, Alteração ou Exclusão de Funcionario

   If lGP010
      If !SuperGetMV("IT_AMBTEST",.F.,.T.)
         MV_PAR01 := Space(99)
         MV_PAR02 := SRA->RA_MAT
         MV_PAR03 := SRA->RA_MAT
         
         FWMSGRUN( ,{|_oSelf|  MGPE026INT(_oSelf,nOper)  } , "Hora Inicial: "+Time()+" Processando integração Control ID...  " )
      Endif
   Else
      If !SuperGetMV("IT_AMBTEST",.F.,.T.)
         AADD( _aParAux , { 1 , "Equipamentos:   "	, MV_PAR01, ""	   , ""	, "LS2SP0"  , "" , 99         , .F. } )
         AADD( _aParAux , { 1 , "Funcionario de: " , MV_PAR02, ""	   , ""	, "SRA"		, "" , _nTamFun   , .F. } )
         AADD( _aParAux , { 1 , "Funcionario até:"	, MV_PAR03, ""	   , ""	, "SRA"		, "" , _nTamFun   , .F. } )

         For _nI := 1 To Len( _aParAux )
            aAdd( _aParRet , _aParAux[_nI][03] )
         Next _nI

         If ParamBox( _aParAux , " Integração de Dados com o sistema ControlID " , @_aParRet, _bOK )
               FWMSGRUN( ,{|_oSelf|  MGPE026INT(_oSelf)  } , "Hora Inicial: "+Time()+" Processando integração Control ID... " )
         Endif
      Else
         U_Itmsg("Rotina não executada nos ambientes DESENV/HOMOLO/SIMULA/TMS!","Atenção",,1)
      EndIf      
   Endif

Endif

Return

/*
===============================================================================================================================
Programa----------: MGPE026INT
Autor-------------: Igor Melgaço
Data da Criacao---: 21/12/2016
===============================================================================================================================
Descrição---------: Atualiza equipamentos de ponto
===============================================================================================================================
Parametros--------: _oSelf - objeto da tela
					     nOper - Operação 1 - inclusão / 2 - Alteração / 3 - Exclusão
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE026INT(_oSelf,nOper)
   Local _nConta   := 0
   Local _nProce   := 0
   Local aHeader   := {}
   Local cMsg      := ""
   Local cParms    := ""
   Local cBodyJson := ""
   Local cResult   := ""
   Local cUrl      := ""
   Local aCab      := {"Proc.","Filial","Url / Relógio","Param","Operação","Matricula","Nome","Json","Resultado da API"}
   Local _lContinua:= .T.
   Local _cTitAux  := ""
   Local _cMsgTop  := ""
   Local _cLinha    := ""
   Local _nI        := 0
   Local _cDir      := ""
   Local _cFileNome := ""
   Local lOk        := .F.

   Default _oSelf := Nil
   Default nOper  := 0

   U_ITLOGACS('MGPE026')
   
   cQuery := " SELECT P0_RELOGIO,P0_FILIAL,P0_I_IP, P0_I_CTRID, P0_I_TIPO, P0_TPREP " 
   cQuery += " FROM " + retsqlname("SP0") + " SP0  "
   cQuery += " WHERE SP0.D_E_L_E_T_ <> '*' "
   cQuery += " AND (SP0.P0_I_CTRID ='W' OR SP0.P0_I_CTRID ='A') " 

   If _oSelf <> Nil  //Se estiver rodando manualmente só roda para filial atual 
      cQuery  += " AND SP0.P0_FILIAL = '" + cfilant + "'"
   Endif

   If !Empty(Alltrim(MV_PAR01))
      cQuery += " AND SP0.P0_RELOGIO IN " + FormatIn( MV_PAR01 , ";" )
   Endif
   
   If Select(_cAlias) > 0
      (_cAlias)->( DBCloseArea() )
   EndIf

   MPSysOpenQuery( cQuery , _cAlias)

   If (_cAlias)->(Eof())

      If _oSelf <> Nil
         If !lGP010
            U_Itmsg("Não foram encontrados relógios Control ID na seleção de relógios!","Atenção",,1)
         Endif
      Else
         U_ItConout("Não foram encontrados relógios Control ID na seleção de relógios!")
      Endif

   Else
      //===================================================================
      //Loop principal de equipamentos
      //===================================================================
      Count to _nConta      
      (_cAlias)->(DBGoTop())
      Do While .not. (_cAlias)->(Eof())  //.and. (AllTrim((_cAlias)->P0_I_IP) == "10.1.0.125" .OR. AllTrim((_cAlias)->P0_I_IP) == "10.3.0.30")
         
         _nProce++

         If _oSelf <> Nil
            If lGP010
               cMsg := "Relogio: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP: " + Alltrim((_cAlias)->P0_I_IP) + " Efetuando Login - Inicio: " + Time()
            Else
               cMsg := "Equip. " + Alltrim(Str(_nProce)) + " de " + Alltrim(Str(_nConta)) +  " Filial: " + (_cAlias)->P0_FILIAL + " Relogio: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP: " + Alltrim((_cAlias)->P0_I_IP) + " Efet. Login Inicio: " + Time()
            EndIf
            _oSelf:cCaption:=(cMsg)
            ProcessMessages() 
         Else
            U_ItConout("Equip. " + Alltrim(Str(_nProce)) + " de "+ Alltrim(Str(_nConta)) +  " Filial: " + (_cAlias)->P0_FILIAL + " Relogio: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP: " + Alltrim((_cAlias)->P0_I_IP) + " Efet. Login Inicio: " + Time())
         EndIf

         //Prepara dados para conexão com o Relogio
         l671 := !((_cAlias)->P0_TPREP == "1" .OR. Empty(Alltrim((_cAlias)->P0_TPREP)))
         cUrl   := "https://"+ALLTRIM((_cAlias)->P0_I_IP)
         cParms := '/login.fcgi'

         aHeader := {}
         Aadd(aHeader, "Content-Type: application/json")

         cBodyJson :=  '{'
         cBodyJson +=  '"login": "admin",'
         cBodyJson +=  '"password": "admin"'
         cBodyJson +=  '}'

         cResult := "" 
         
         //Tenta conexão com o relogio
         If U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,5)

            _cSession := cResult

            If lGP010
               cMsg := "Atualizando Relogio: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP " + Alltrim((_cAlias)->P0_I_IP) + " Login: " + Time()
            Else
               cMsg := "Atu. Equip. " + Alltrim(Str(_nProce)) + " de " + Alltrim(Str(_nConta)) + " Filial: " + (_cAlias)->P0_FILIAL + " Rel.: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP " + Alltrim((_cAlias)->P0_I_IP) + " Login: " + Time()
            EndIf
            
            If _oSelf <> Nil
               _oSelf:cCaption:=(cMsg)
               ProcessMessages() 
            Else
               U_ItConout(cMsg)
            EndIf
            
            If !lGP010
               //===================================================================
               //Loop funcionários demitidos para zerar cracha
               //===================================================================
               
               cQuery := " SELECT RA_I_CRACH, RA_PIS, RA_NOMECMP, RA_NSOCIAL, RA_MAT, RA_CRACHA, RA_NOME, RA_CIC,RA_I_CIAD, R_E_C_N_O_ RECN   " 
               cQuery += " FROM "+ retsqlname("SRA") + " SRA "
               cQuery += " WHERE SRA.D_E_L_E_T_ <> '*' "
               cQuery += " AND SRA.RA_FILIAL = '" + ALLTRIM((_cAlias)->P0_FILIAL) +  "'" 

               cQuery += " AND (SRA.RA_SITFOLH = 'D' OR SRA.RA_DEMISSA <> ' ' ) "
               cQuery += " AND ( SRA.RA_CATFUNC = 'M' OR SRA.RA_CATFUNC = 'E' ) "
               cQuery += " AND RA_I_ZERS NOT LIKE '%" + ALLTRIM((_cAlias)->P0_RELOGIO) + "%'"
               cQuery += " AND (SRA.RA_I_CRACH > ' ' OR SRA.RA_I_ZERS > ' ' OR SRA.RA_CRACHA > ' ')"
               
               If !Empty(ALLTRIM(MV_PAR02+MV_PAR03))
                  cQuery += " AND SRA.RA_MAT >= '" + ALLTRIM(MV_PAR02) +  "' "
                  cQuery += " AND SRA.RA_MAT <= '" + ALLTRIM(MV_PAR03) + "' "
               EndIf

               If Select(_cAlias2) > 0
                  (_cAlias2)->( DBCloseArea() )
               EndIf

               cQuery += " ORDER BY SRA.RA_MAT  "

               MPSysOpenQuery( cQuery , _cAlias2)

               nConta := 0
               nTotal := 0

               DBSelectArea(_cAlias2) 
               COUNT TO nTotal 
               (_cAlias2)->(DBGoTop())
               Do While !((_cAlias2)->(Eof()))

                  nConta++
                  
                  cMsg := ("Eq. " + Alltrim(Str(_nProce)) + " de " + Alltrim(Str(_nConta)) + " Fil: " + (_cAlias)->P0_FILIAL + " IP " + Alltrim((_cAlias)->P0_I_IP) + " Reg. "+Alltrim(Str(nConta))+" de "+Alltrim(Str(nTotal))+" Exc. " + (_cAlias2)->RA_MAT + " " + Subs((_cAlias2)->RA_NOME,1,10) )
                  
                  If _oSelf <> Nil
                     _oSelf:cCaption:=(cMsg)
                     ProcessMessages() 
                  Else                        
                     U_ItConout(cMsg)
                  Endif
                  
                  lOk := MGPE026SINC(cUrl,aHeader,_cAlias,_cAlias2,l671,3)

                  //=======================================================================
                  //Grava campo RA_I_ZERS
                  //=======================================================================

                  If lOk
                     SRA->(Dbgoto((_cAlias2)->RECN))
                     SRA->(Reclock("SRA",.F.))
                     If !(ALLTRIM((_cAlias)->P0_RELOGIO) $ SRA->RA_I_ZERS) 
                        SRA->RA_I_ZERS := ALLTRIM(SRA->RA_I_ZERS) + "|" + ALLTRIM((_cAlias)->P0_RELOGIO)
                     Endif
                     SRA->RA_I_CRACH := "  "
                     SRA->RA_CRACHA := "   "
                     SRA->(Msunlock())
                  Else
                     SRA->(Dbgoto((_cAlias2)->RECN))
                     If ALLTRIM((_cAlias)->P0_RELOGIO) $ SRA->RA_I_ZERS 
                        SRA->(Reclock("SRA",.F.))
                        SRA->RA_I_ZERS := StrTran(ALLTRIM(SRA->RA_I_ZERS) ,"|" + ALLTRIM((_cAlias)->P0_RELOGIO),"")
                        SRA->(Msunlock())
                     EndIf
                  EndIf
                  
                  (_cAlias2)->(Dbskip())
               Enddo 

               (_cAlias2)->( DBCloseArea() )
         
         
            EndIf
            
            If !lGP010
               //===================================================================
               //Loop funcionários ativos
               //===================================================================
               cQuery := " SELECT RA_I_CRACH, RA_PIS, RA_NOMECMP, RA_NSOCIAL, RA_MAT, RA_CRACHA, RA_NOME,RA_CIC, RA_I_CIAD, R_E_C_N_O_ RECN " 
               cQuery += " FROM " + retsqlname("SRA") + " SRA "
               cQuery += " WHERE SRA.D_E_L_E_T_ <> '*' "
               cQuery += " AND SRA.RA_FILIAL = '" + ALLTRIM((_cAlias)->P0_FILIAL) +  "'" 
               cQuery += " AND SRA.RA_SITFOLH <> 'D' " //AND SRA.RA_DEMISSA = ' '
               cQuery += " AND ( SRA.RA_CATFUNC = 'M' OR SRA.RA_CATFUNC = 'E' ) "
               
               If !Empty(ALLTRIM(MV_PAR02+MV_PAR03))
                  cQuery += " AND SRA.RA_MAT >= '" + ALLTRIM(MV_PAR02) +  "' "
                  cQuery += " AND SRA.RA_MAT <= '" + ALLTRIM(MV_PAR03) + "' "
               EndIf

               cQuery += " ORDER BY SRA.RA_MAT  "

               If Select(_cAlias2) > 0
                  (_cAlias2)->( DBCloseArea() )
               EndIf

               MPSysOpenQuery( cQuery , _cAlias2)

               nConta := 0
               nTotal := 0

               DBSelectArea(_cAlias2) 

               COUNT TO nTotal 
               (_cAlias2)->(DBGoTop())
               Do While !((_cAlias2)->(Eof())) 

                  nConta++

                  cMsg := ("Eq. " + Alltrim(Str(_nProce)) + " de " + Alltrim(Str(_nConta)) + " Fil: " + (_cAlias)->P0_FILIAL + " IP " + Alltrim((_cAlias)->P0_I_IP) + " Reg. "+Alltrim(Str(nConta))+" de "+Alltrim(Str(nTotal))+" Atual. " + (_cAlias2)->RA_MAT + " " + Subs((_cAlias2)->RA_NOME,1,10) )
                                    
                  If _oSelf <> Nil
                     _oSelf:cCaption:=(cMsg)
                     ProcessMessages() 
                  Else                        
                     U_ItConout(cMsg)
                  Endif
                  
                  lOk := MGPE026SINC(cUrl,aHeader,_cAlias,_cAlias2,l671,1)

                  //=======================================================================
                  //Grava campo RA_I_ZERS
                  //=======================================================================
                  If lOk
                     SRA->(Dbgoto((_cAlias2)->RECN))
                  
                     If ALLTRIM((_cAlias)->P0_RELOGIO) $ SRA->RA_I_ZERS
                        cZerRel := StrTran(SRA->RA_I_ZERS,"|"+ALLTRIM((_cAlias)->P0_RELOGIO),"")
                        If Alltrim(SRA->RA_I_ZERS) <> Alltrim(cZerRel)
                           SRA->(Reclock("SRA",.F.))
                           SRA->RA_I_ZERS := cZerRel
                           SRA->(Msunlock())
                        EndIf
                     EndIf
                  EndIf

                  (_cAlias2)->(Dbskip())

               Enddo

               (_cAlias2)->( DBCloseArea() )
               
            Else

               If SRA->RA_CATFUNC = 'M' .OR. SRA->RA_CATFUNC = 'E' 
                  MGPE026SINC(cUrl,aHeader,_cAlias,"SRA",l671,nOper)
               Endif

            Endif
            
         Else //Falha na conexão com o relogio

            If lGP010
               cMsg := "Relogio: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP: " + Alltrim((_cAlias)->P0_I_IP) + " Login Não Efetuado: " + Time()
            Else
               cMsg := "Equip. " + strzero(_nProce,3) + " de " + strzero(_nConta,3) +  " Filial: " + (_cAlias)->P0_FILIAL + " Relogio: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP: " + Alltrim((_cAlias)->P0_I_IP) + " Login Não Efetuado: " + Time()
            EndIf

            If _oSelf <> Nil
               _oSelf:cCaption:=(cMsg)
               ProcessMessages() 

               AAdd(aLog,{.F.,(_cAlias)->P0_FILIAL ,cUrl,cParms,"Conexão","","",STRTRAN(cBodyJson,"admin","*****"),cResult})
               AAdd(aLogERR,{.F.,(_cAlias)->P0_FILIAL ,cUrl,cParms,"Conexão","","",STRTRAN(cBodyJson,"admin","*****"),cResult})
            Else
               U_ItConout(cMsg)           
            EndIf
         EndIf

         (_cAlias)->(Dbskip())

      Enddo

      _cTitAux := "Log de processamento de integrações Control ID"
      
      If _oSelf <> Nil
         If lGP010  .AND. Len(aLogERR) > 0
            _lContinua := .T.
         ElseIf !lGP010 .AND. Len(aLog) > 0
            _lContinua := .T.
         Else
            _lContinua := .F.            
         EndIf

         _cMsgTop := Iif(lGP010,"Verifique as falhas de gravações nos relogios de acordo com o Log:","Log de processamento")
         
         If _lContinua
            //ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda                      ,_lHasOk,_bHeadClk,_aSX1)
            U_ITListBox( _cTitAux , aCab     , aLog   , .F.      , 2      , _cMsgTop ,          ,         ,         ,     ,        ,          ,       ,         ,          ,           , {|C,L|U_MGPE026L(C,L)}        , .F.   ,         ,     )
         EndIf

      Else

         _cLinha := ARRTOKSTR(aCab,";")+CRLF

         FOR _nI := 1 TO LEN(aLog)
            _cLinha += ARRTOKSTR(aLog[_nI],";")+CRLF
         NEXT
         
         _cLinha    := STRTRAN(_cLinha,".",",")
         _cDir      := "\data\Italac\MGPE026\"
         _cFileNome := _cDir + "MGPE026_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".CSV"
         
         MemoWrite(_cFileNome,_cLinha)

      EndIf
      
   EndIf
   
Return

/*
===============================================================================================================================
Programa----------: MGPE026RES
Autor-------------: Igor Melgaço
Data da Criacao---: 11/10/2023
===============================================================================================================================
Descrição---------: Efetua comunicação com o Relogio
===============================================================================================================================
Parametros--------: cUrl,cParms,aHeader,cBodyJson,cResult,nTipo
===============================================================================================================================
Retorno-----------: _lRet => .T./.F.
===============================================================================================================================
*/
User Function MGPE026RES(cUrl,cParms,aHeader,cBodyJson,cResult,nTipo)
	Local _lRet 		:= .F.
	Local cRegistro 	:= ""
	Local cError 		:= ""
	Local nStatus 		:= 0
	Local oJson
	Local oErro
	Local oRest 

   Default nTipo := 1
  
	oRest := FWRest():New(Alltrim(cUrl))
	oRest:SetPath(cParms)

	oRest:SetPostParams(cBodyJson)
	oRest:SetChkStatus(.F.)

	If oRest:Post(aHeader)

		cError := ""
		nStatus := HTTPGetStatus(@cError)

		If nStatus >= 200 .And. nStatus <= 299
			If Empty(oRest:getResult())
	
				cResult := "Falha de comunicação no retorno da requisição com sistema Control ID" + CRLF + "Status " + Alltrim(Str(nStatus))
	
				U_ItConout(cResult)
	
				_lRet  := .F.
	
			Else

				cResult := oRest:getResult()

            If nTipo <> 6

               oJson := JsonObject():new()
      
               cRegistro := oJson:fromJson(cResult)
            
               If ValType(cRegistro) == "U"

                  U_ItConout("JsonObject populado com sucesso")
                  
                  If nTipo = 5
                     cResult := oJson["session"]
                     _lRet  := .T.
                     U_ItConout("session: " + cResult)
                  ElseIf nTipo = 4 //Consulta de Usuário
                     If Len(oJson["users"]) > 0
                        _lRet  := .T.
                     Else
                        _lRet  := .F.
                     EndIf
                  ElseIf nTipo = 6 //Baixar AFD
                     _lRet  := .T.
                  Else
                     cResult := "Status: Usuario "+Iif(nTipo=1,"incluido","alterado")+Chr(13)+Chr(10)+"Response:" + cResult
                     _lRet  := .T.
                  EndIf

               Else

                  cResult := "Falha ao popular JsonObject. Erro: " + cRegistro

                  U_ItConout(cResult)

                  _lRet  := .F.

               EndIf 
            EndIf
			EndIf
		Else

			cResult := oRest:getResult() 

			oJson := JsonObject():new()

			cRegistro := oJson:fromJson(cResult)

			If ValType(cRegistro) == "U"
				U_ItConout("JsonObject populado com sucesso")
			Else
				U_ItConout("Falha ao popular JsonObject. Erro: " + cRegistro)
			EndIf

			If FWJsonDeserialize(cRegistro,@oErro)
				cMensagem := CRLF + "Mensagem: " + AnsiToOEM(oErro:error)
			Else
				If FWJsonDeserialize(cResult,@oErro)
					cMensagem := CRLF + "Mensagem: " + AnsiToOEM(oErro:error)
				Else
					cMensagem := ""
				EndIf
			EndIf
         
			cResult := "Erro:" + oRest:getLastError() + cMensagem
			
			U_ItConout(cResult)

			_lRet  := .F.

		EndIf
	Else

		cResult := oRest:getResult() 

		If ValType(cResult) == "U"
			cResult := ""
		EndIf

		cResult := "Falha de comunicação com sistema Control ID!" + CRLF + oRest:getLastError() + CRLF + cResult

		_lRet  := .F.

	EndIf

	FreeObj(oJson)
	FreeObj(oErro)
	FreeObj(oRest)

Return _lRet

/*
===============================================================================================================================
Programa----------: MGPE026JSO
Autor-------------: Igor Melgaço
Data da Criacao---: 11/10/2023
===============================================================================================================================
Descrição---------: Monta o Body da Requisição 
===============================================================================================================================
Parametros--------: nOper,l671,cTipo,cCtrID,cAlias
===============================================================================================================================
Retorno-----------: cBodyJson
===============================================================================================================================
*/
Static Function MGPE026JSO(nOper,l671,cTipo,cCtrID,cAlias)
Local cBodyJson    := ""
Local _cNome       := Alltrim(Iif(!EMPTY((cAlias)->RA_NSOCIAL),(cAlias)->RA_NSOCIAL,(cAlias)->RA_NOME))
Local _cCPF        := Alltrim(Str(Val((cAlias)->RA_CIC)))
Local _cPis        := Alltrim(Str(Val((cAlias)->RA_PIS)))
Local _cBarra      := Alltrim((cAlias)->RA_CRACHA)
Local _cRfid       := MGPE026CRA((cAlias)->RA_I_CRACH,cCtrID,cTipo )
Local _cAdmin      := Iif(Alltrim((cAlias)->RA_I_CIAD) == "S",'true','false')

cBodyJson := '{'

If nOper = 1 .OR. nOper = 2

   cBodyJson += '   "users":['
   cBodyJson += '      {'
   
   If l671
      cBodyJson += '         "cpf": ' + _cCPF
   Else   
      cBodyJson += '         "pis": ' + _cPis
   EndIf

   cBodyJson += '         , "name": "' + _cNome +'" '
   cBodyJson += '         , "bars": "' + _cBarra +'" '
   //cBodyJson += '         , "code": ' + Alltrim(Str(Val((_cAlias2)->RA_MAT)))
   cBodyJson += '         , "code": 0' 
   cBodyJson += '         , "password": "909890" '
   cBodyJson += '         , "rfid": ' + _cRfid
   
   
   cBodyJson += '         , "admin": ' + _cAdmin
   
   If nOper = 2
      cBodyJson += '         , "remove_templates": false'
   EndIf
   
   cBodyJson += '      }'
   cBodyJson += '   ]'

ElseIf nOper = 3
   
   If l671
      cBodyJson += '"users": [' + _cCPF + ']'
   Else
      cBodyJson += '"users": [' + _cPis + ']'
   EndIf      

ElseIf nOper = 4

   If l671
      cBodyJson += '"users_cpf": [' + _cCPF + ']'
   Else
      cBodyJson += '"users_pis": [' + _cPis + ']'
   EndIf   

EndIf

cBodyJson += '}'

Return cBodyJson

/*
===============================================================================================================================
Programa----------: MGPE026CRA
Autor-------------: Igor Melgaço
Data da Criacao---: 12/10/2023
===============================================================================================================================
Descrição---------: Monta o numero de cracha 
===============================================================================================================================
Parametros--------: cCracha,cCtrId,cTipo
===============================================================================================================================
Retorno-----------: cRet
===============================================================================================================================
*/
Static Function MGPE026CRA(cCracha,cCtrId,cTipo)
Local cRet := ""
Local nPripar := 0
Local nSegpar := 0

   If .not. empty(Alltrim(cCracha))
      
      nSegpar := val(substr(Alltrim(cCracha),5,5))
      
      If Alltrim(cCtrId) == 'A' .OR. ( Alltrim(cCtrId) == 'W' .AND.  Alltrim(cTipo) == "R" )
         nPripar := val(substr(Alltrim(cCracha),1,3)) * 65536  //codificação para o rep 1818 e rep web
      Else
         nPripar := val(substr(Alltrim(cCracha),1,3)) * 65536 * 2  //codificação para a catraca  web
      Endif

      cRet := Alltrim(str(nPripar+nSegpar))
      
   Else

      cRet := "0"
   
   Endif

Return cRet


/*
===============================================================================================================================
Programa----------: MGPE026L
Autor-------------: Igor Melgaço
Data da Criacao---: 12/10/2023
===============================================================================================================================
Descrição---------: Monta Legenda
===============================================================================================================================
Parametros--------: _aCol,_nLinha
===============================================================================================================================
Retorno-----------: cRet
===============================================================================================================================
*/
USER Function MGPE026L(_aCol,_nLinha)
	Local oVerm := LoadBitmap( , "BR_VERMELHO")// VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO
	Local oVerd := LoadBitmap( , "BR_VERDE"   )// VERDE ESTOQUE TUDO OK .T.

	IF _aCol[_nLinha,1]
		RETURN oVerd
	ELSE
		RETURN oVerm
	ENDIF

RETURN oVerm


/*
===============================================================================================================================
Programa----------: MGPE026VA
Autor-------------: Igor Melgaço
Data da Criacao---: 18/10/2023
===============================================================================================================================
Descrição---------: Valida se altera o Funcionario
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lRet   
===============================================================================================================================
*/
Static Function MGPE026VA(oJsonFunc,l671,cTipo,cCtrID,cAlias)
	Local _cNome    := Alltrim(Iif(!EMPTY((cAlias)->RA_NSOCIAL),(cAlias)->RA_NSOCIAL,(cAlias)->RA_NOME) )
	Local _cCPF     := Alltrim((cAlias)->RA_CIC)
   Local _cPis     := Alltrim((cAlias)->RA_PIS)
   Local _cRfid    := MGPE026CRA((cAlias)->RA_I_CRACH,cCtrID,cTipo )
   Local _cBars    := Alltrim((cAlias)->RA_CRACHA)
   Local lContinua := .F.

   If AttIsMemberOf(oJsonFunc:users[1], "name") .AND. oJsonFunc:users[1]:name <> _cNome
      lContinua := .T.
   ElseIf AttIsMemberOf(oJsonFunc:users[1], "rfid") .AND. oJsonFunc:users[1]:rfid <> Val(_cRfid)
      lContinua := .T.
   ElseIf AttIsMemberOf(oJsonFunc:users[1], "bars") .AND. oJsonFunc:users[1]:bars <> _cBars
      lContinua := .T.
   Else
      If l671
         If AttIsMemberOf(oJsonFunc:users[1], "cpf") .AND. oJsonFunc:users[1]:cpf <> Val(_cCPF)
            lContinua := .T.
         EndIf
      Else
         If AttIsMemberOf(oJsonFunc:users[1], "pis") .AND. oJsonFunc:users[1]:pis <> Val(_cPis)
            lContinua := .T.
         EndIf
      EndIf
   EndIf

Return lContinua

/*
===============================================================================================================================
Programa----------: MGPE026SINC
Autor-------------: Igor Melgaço
Data da Criacao---: 18/10/2023
===============================================================================================================================
Descrição---------: Valida se altera o Funcionario
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lRet   
===============================================================================================================================
*/
Static Function MGPE026SINC(cUrl,aHeader,cAlias,cAlias2,l671,nOper)
Local cBodyJson   := ""
Local cResult     := ""
Local cParms      := ""
Local lAchou      := .F. 
Local lOk         := .F. 
Local _lGravaLog  := .F.
Local _lContinua  := .F.
Local oJsonFunc
Local nTentaivas := 0

//Consulta dados do usuario
cParms    := "/load_users.fcgi?session="+_cSession+Iif(l671,'&mode=671','')
cBodyJson := MGPE026JSO(4,l671,(cAlias)->P0_I_TIPO,(cAlias)->P0_I_CTRID,Iif(lGP010,"SRA",cAlias2))
lAchou    := U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,4)

If !lAchou .AND. "Erro:401 Unauthorized" $ cResult
   Do While !lAchou .AND. "Erro:401 Unauthorized" $ cResult .AND. nTentaivas < 3
      
      nTentaivas++

      cUrl   := "https://"+ALLTRIM((_cAlias)->P0_I_IP)
      cParms := '/login.fcgi'

      cBodyJson :=  '{'
      cBodyJson +=  '"login": "admin",'
      cBodyJson +=  '"password": "admin"'
      cBodyJson +=  '}'

      cResult := "" 
      
      //Tenta conexão com o relogio
      If U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,5)
         _cSession := cResult

         cParms    := "/load_users.fcgi?session="+_cSession+Iif(l671,'&mode=671','')
         cBodyJson := MGPE026JSO(4,l671,(cAlias)->P0_I_TIPO,(cAlias)->P0_I_CTRID,Iif(lGP010,"SRA",cAlias2))
         lAchou    := U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,4)
      EndIf

   EndDo
EndIf


If lAchou
   _lGravaLog := .T.
   If nOper <> 3
      nOper := 2
      oJson := JsonObject():new()

      If FWJsonDeserialize(cResult,@oJsonFunc)
         If Len(oJsonFunc:users) > 1 // Verifico se retornou mais de 1 Funcionario
            cResult    := "A Consulta retornou mais de um funcionario com a matricula " + cResult
            _lContinua := .F.
            _lGravaLog := .T.
            lOk := .F.
         Else
            If MGPE026VA(oJsonFunc,l671,(cAlias)->P0_I_TIPO,(cAlias)->P0_I_CTRID,Iif(lGP010,"SRA",cAlias2))//Verifica se Altera ou Não
               _lContinua := .T.
               _lGravaLog := .T.
            Else
               _lContinua := .F.
               _lGravaLog := .F.
            EndIf
         EndIf
      Else
         cResult := "Falha ao popular JsonObject." + cResult
         _lContinua := .F.
         _lGravaLog := .T.
         lOk := .F.
      EndIf

      FreeObj(oJsonFunc)
   Else
      _lContinua := .T.
      _lGravaLog := .T.
   EndIf
Else
   If nOper = 3
      lOk        := .T.
      _lContinua := .F.
      _lGravaLog := .F.
   Else
      nOper := 1
      _lContinua := .T.
      _lGravaLog := .T.
   EndIf
EndIf

If _lContinua 
   //Altera ou Inclui dados do usuario
   cParms    := Iif(lAchou,Iif(nOper=3,'/remove_users.fcgi?session=','/update_users.fcgi?session='),'/add_users.fcgi?session=')+_cSession+Iif(l671,'&mode=671','')
   cBodyJson := MGPE026JSO(nOper,l671,(cAlias)->P0_I_TIPO,(cAlias)->P0_I_CTRID,cAlias2)
   lOk       := U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,nOper)

   If !lOk .AND. "Erro:401 Unauthorized" $ cResult
      nTentaivas := 0
      Do While !lAchou .AND. "Erro:401 Unauthorized" $ cResult .AND. nTentaivas < 3
         
         nTentaivas++

         cUrl   := "https://"+ALLTRIM((_cAlias)->P0_I_IP)
         cParms := '/login.fcgi'

         cBodyJson :=  '{'
         cBodyJson +=  '"login": "admin",'
         cBodyJson +=  '"password": "admin"'
         cBodyJson +=  '}'

         cResult := "" 
         
         //Tenta conexão com o relogio
         If U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,5)
            _cSession := cResult

            //Altera ou Inclui dados do usuario
            cParms    := Iif(lAchou,Iif(nOper=3,'/remove_users.fcgi?session=','/update_users.fcgi?session='),'/add_users.fcgi?session=')+_cSession+Iif(l671,'&mode=671','')
            cBodyJson := MGPE026JSO(nOper,l671,(cAlias)->P0_I_TIPO,(cAlias)->P0_I_CTRID,cAlias2)
            lOk       := U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,nOper)
         EndIf

      EndDo
   EndIf
EndIf

If _lGravaLog
   //Gera Log da Operação
   AAdd(aLog,{lOk,(cAlias)->P0_FILIAL,cUrl,cParms,Iif(lAchou,Iif(nOper=3,"Exclusão","Alteração"),"Inclusão"),(cAlias2)->RA_MAT,(cAlias2)->RA_NOME,cBodyJson,cResult})
   
   If !lOk
      AAdd(aLogERR,{lOk,(cAlias)->P0_FILIAL,cUrl,cParms,Iif(lAchou,Iif(nOper=3,"Exclusão","Alteração"),"Inclusão"),(cAlias2)->RA_MAT,(cAlias2)->RA_NOME,cBodyJson,cResult})
   Endif
EndIf

Return lOk
