/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |07/10/2024| Chamado 48764. Corrigido erro quando o XML ainda n�o foi recebido pelo TOTVS Colabora��o
Lucas Borges  |23/05/2025| Chamado 50754. Inclu�do tratamento para CT-e Simplificado
===============================================================================================================================
*/

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MCOM027
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 01/10/2024
Descri��o---------: Realiza a consulta do status do documento na SEFAZ
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM027

Local oDlgKey As Object
Local oBtnOut As Object
Local oBtnCon As Object
Local _cChaveNFe := Space(44) as Character

DEFINE MSDIALOG oDlgKey TITLE "Consulta chave" FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

@ 12,008 SAY "Informe a Chave de acesso do documento: " PIXEL OF oDlgKey
@ 20,008 MSGET _cChaveNFe PICTURE "99999999999999999999999999999999999999999999" SIZE 140,10 PIXEL OF oDlgKey

@ 46,035 BUTTON oBtnCon PROMPT "&Consultar" SIZE 38,11 PIXEL ACTION ConsNFeChave(_cChaveNFe)
@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()

ACTIVATE DIALOG oDlgKey CENTERED

Return

/*
===============================================================================================================================
Programa----------: ConsNFeChave
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 01/10/2024
Descri��o---------: Realiza a consulta do status do documento na SEFAZ
Parametros--------: C -> Chave a ser consultada
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ConsNFeChave(_cChaveNFe As Character)

Local cIdEnt   As Character
Local _cXML    As Character
Local cUrl		:= Padr( GetNewPar("MV_SPEDURL",""), 250 ) As Character
Local aSize    As Array
Local aObjects As Array
Local aListBox As Array
Local aInfo    As Array
Local aPosObj  As Array
Local oDlg     As Object
Local oListBox As Object
Local oBtn1    As Object
Local oBtn3    As Object
Local oBtn4    As Object
			
If Len(AllTrim(_cChaveNFe)) == 44
   If CTIsReady()
      cIdEnt		:= RetIdEnti()
      If !Empty(cIdEnt)
         aListBox := getListBox(cIdEnt, cUrl, _cChaveNFe,@_cXML)

         If !Empty(aListBox)
            aSize := MsAdvSize()
            aObjects := {}
            AAdd( aObjects, { 100, 100, .t., .t. } )
            AAdd( aObjects, { 100, 015, .t., .f. } )

            aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
            aPosObj := MsObjSize( aInfo, aObjects )

            DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

            @ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "","Finalidade","Emiss�o","Dt.Receb/Escrit.","Hr.Receb/Escrit.","Protocolo","Ret. Sefaz           ","Status/Recomenda��o           ";
              SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
            oListBox:SetArray( aListBox )
            oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ],aListBox[ oListBox:nAT,6 ],aListBox[ oListBox:nAT,7 ],aListBox[ oListBox:nAT,8 ] } }

            @ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT "OK"   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011
            @ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn3 PROMPT "Baixa XML"ACTION (getXml(_cChaveNFe,_cXML)) OF oDlg PIXEL SIZE 035,011
            @ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn4 PROMPT "Refresh" 	ACTION (aListBox := getListBox(cIdEnt, cUrl, _cChaveNFe,_cXML),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011
            @ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Imprimir" ACTION (U_MCOM023D(),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011

            ACTIVATE MSDIALOG oDlg
         EndIf
      Else
         FWAlertInfo("TSS n�o configurado ou servi�o indispon�vel","MCOM02701")
      EndIf
   Else
      FWAlertInfo("TSS n�o configurado ou servi�o indispon�vel","MCOM02702")
      Return
   EndIf
Else
   FWAlertInfo("A chave informada n�o possui 44 caracteres. Verifique!","MCOM02703")
EndIf
Return

/*
===============================================================================================================================
Programa----------: getListBox
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 01/10/2024
Descri��o---------: Retorna lista com os dados para serem apresentados na tela
Parametros--------: _cIdEnt -> C -> Entidade do TSS para processamento
                    _cUrl -> C -> Endere�o do Web Wervice no TSS
                    _cChaveNFe -> C -> Chave do documento a ser consultado
Retorno-----------: _aListBox -> A -> Array com a lista dos eventos do documento
===============================================================================================================================
*/
Static Function getListBox(_cIdEnt As Character,_cUrl As Character,_cChaveNFe As Character,_cXML As Character)

Local _aListBox   := {} As Array
Local _cDeneg     := "'110','301','205','302','303','304'" As Character
Local _oOk			:= LoadBitMap(GetResources(), "ENABLE") As Object
Local _oNo			:= LoadBitMap(GetResources(), "DISABLE") As Object
Local _cAlias     := GetNextAlias() As Character
Local _cFinalid   := '' As Character
Local _cDtEmissa  := '' As Character
Local _cError	   := ' ' As Character
Local _cWarning	:= ' ' As Character
Local _oXML       := Nil As Object
Local _oFullXML   := Nil As Object
Local oWS         := Nil As Object

oWs:= WsNFeSBra():New()
oWs:cUserToken   := "TOTVS"
oWs:cID_ENT      := _cIdEnt
oWs:_URL         := AllTrim(_cURL)+"/NFeSBRA.apw"
oWS:cCHVNFE       := _cChaveNFe

BeginSql alias _cAlias
   SELECT 'CKO' TIPO, (SELECT 'SIM' FROM %Table:SF1% WHERE D_E_L_E_T_ = ' ' AND F1_CHVNFE = CKO_CHVDOC AND F1_FILIAL = CKO_FILPRO) CLAS,
   CKO_DT_IMP DATA_INC, CKO_HR_IMP HORA_INC, 
   CASE WHEN CKO_I_ALTX = 'N' THEN CKO_XMLRET ELSE CKO_I_ORIG END CKO_XMLRET
   FROM %Table:CKOCOL%
   WHERE D_E_L_E_T_ = ' '
   AND CKO_CHVDOC = %exp:_cChaveNFe%
   UNION ALL
   SELECT 'SF1', '', TO_CHAR(CAST( I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE), 'YYYYMMDD'),
   TO_CHAR(CAST( I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE), 'HH24:MM:SS'),
   EMPTY_BLOB() CKO_XMLRET
   FROM %Table:SF1%
   WHERE D_E_L_E_T_ = ' '
   AND F1_CHVNFE  = %exp:_cChaveNFe%
   UNION ALL
   SELECT 'SPED050', '', '', '', XML_SIG
   FROM SPED050
   WHERE D_E_L_E_T_ = ' '
   AND DOC_CHV = %exp:_cChaveNFe%
EndSql

While (_cAlias)->(!Eof())
   _cAux:= ""
   If AllTrim((_cAlias)->TIPO) == 'CKO'
      _cAux := "XML recebido pela Italac - "+ IIf(Alltrim((_cAlias)->CLAS) == 'SIM',"Escriturado","N�o escriturado")
   ElseIf AllTrim((_cAlias)->TIPO) == 'SF1'
      _cAux := "Documento escriturado"
   EndIf

   If !(_cAlias)->TIPO == 'SPED050'
      aAdd(_aListBox,{IIf(AllTrim((_cAlias)->TIPO) == 'CKO' .And. Empty(AllTrim((_cAlias)->CLAS)),_oNo,_oOk),;
            '',;//Finalidade
            '',;//Emissao
            DtoC(SToD((_cAlias)->DATA_INC)),;//Dt Recebimento Ambiente Nacional
            (_cAlias)->HORA_INC,;//Hora Recebimento Ambiente Nacional
            '',;//Protocolo
            '',;//C�digo de retorno SEFAZ
            _cAux;//Status/Recomenda��o
            })
   EndIf
   If Empty(_cXML)
      _cXML := (_cAlias)->CKO_XMLRET
   EndIf
   (_cAlias)->(DbSkip())
EndDo
(_cAlias)->(dbCloseArea())

//Buscando status do documento
If oWS:CONSULTADTCHAVENFE()

   If !Empty(_cXML)
      If "ObsContxCampo" $ _cXML
         _cXML := StrTran(_cXML,"ObsContxCampo","ObsCont xCampo")
      Endif
         
      If "ReferenceURI" $ _cXML
         _cXML := StrTran(_cXML,"ReferenceURI","Reference URI") 
      Endif

      _cXML := SubStr( _cXML , At( '<' , _cXML ) )
      
      // Inicializa o objeto do XML
      _oFullXML := XmlParser( _cXML , "_" , @_cError , @_cWarning )
      
      If ValType( XmlChildEx( _oFullXML , "_NFEPROC" ) ) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
         If ValType( XmlChildEx( _oFullXML:_NFeProc , "_NFE" ) ) == "O"
               _oXML := _oFullXML:_NFeProc:_Nfe    
         Else
               _oXML := _oFullXML:_NFeProc:_NFeProc:_Nfe
         EndIf
      ElseIf ValType(XmlChildEx(_oFullXML,"_CTE")) == "O" //-- Nota de transporte
         _oXML := _oFullXML:_CTe
      ElseIf ValType(XmlChildEx(_oFullXML,"_CTESIMPPROC")) == "O"
         _oXML := _oFullXML:_CTeSimpProc:_CTeSimp
      ElseIf ValType(XmlChildEx(_oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
         If ValType(XmlChildEx(_oFullXML:_CTEPROC,"_ENVICTE")) == "O"
               _oXML := _oFullXML:_CTeProc:_ENVICTE:_Cte
         ElseIf ValType(XmlChildEx(_oFullXML:_CTEPROC,"_CTEOS")) == "O" //-- Nota de transporte CTEOS
               _oXML := _oFullXML:_CTeProc:_CTEOS
         Else
               _oXML := _oFullXML:_CTeProc:_Cte
         EndIf
      ElseIf ValType(XmlChildEx(_oFullXML,"_CTEOSPROC")) == "O" //-- Nota de transporte CTEOS
         _oXML := _oFullXML:_CTeOSProc:_CteOS
      EndIf

      If Substr(_cChaveNFe,21,2)=="55"
         _cFinalid := AllTrim(_oXML:_InfNfe:_Ide:_finNFe:Text)
         If ValType(XmlChildEx(_oXML:_InfNfe:_Ide,"_DEMI")) == "O"
            _cDtEmissa := DToC(StoD(StrTran(AllTrim(_oXML:_InfNfe:_Ide:_DEmi:Text),"-","")))
         ElseIf ValType(XmlChildEx(_oXML:_InfNfe:_Ide,"_DHEMI")) == "O"
            _cDtemissa := DToC(StoD(StrTran(Substr((_oXML:_InfNfe:_Ide:_DhEmi:Text),1,10),"-","")))
         EndIf
      ElseIf Substr(_cChaveNFe,21,2)$"57/67"
         _cFinalid := AllTrim(If(ValType(XmlChildEx(_oXML:_InfCte,"_IDE")) == "O",AllTrim(_oXML:_InfCte:_Ide:_tpCTe:Text),""))
         _cDtemissa := DToC(StoD(StrTran(AllTrim(_oXML:_InfCte:_Ide:_Dhemi:Text),"-","")))
      EndIf
   EndIf

   aAdd(_aListBox,{IIf(Empty(oWs:OWSCONSULTADTCHAVENFERESULT:cPROTOCOLO) .Or.  oWs:OWSCONSULTADTCHAVENFERESULT:cCODRETNFE $ _cDeneg,_oNo,_oOk),;
                  getDesc(IIf(Substr(_cChaveNFe,21,2)=="55",'NFE','CTE'),_cFinalid),;//Finalidade
                  _cDtEmissa,;//Emissao
                  DtoC(oWs:OWSCONSULTADTCHAVENFERESULT:dRECBTO),;//Dt Recebimento Ambiente Nacional
                  Substr(oWs:OWSCONSULTADTCHAVENFERESULT:cRECBTOTM,1,8),;//Hora Recebimento Ambiente Nacional
                  oWs:OWSCONSULTADTCHAVENFERESULT:cPROTOCOLO,;//Protocolo
                  getDesc('EVENTO',oWs:OWSCONSULTADTCHAVENFERESULT:cCODRETNFE),;//C�digo de retorno SEFAZ
                  oWs:OWSCONSULTADTCHAVENFERESULT:cMSGRETNFE;//Status/Recomenda��o
                  })
Else
   FWAlertError(IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),"MCOM02704")
EndIf

freeObj(oWs)
oWs := nil
_oXML := Nil
_oFullXML:= Nil
DelClassIntF()

BeginSql alias _cAlias
   SELECT STATUS, PROTOCOLO, TPEVENTO, CMOTEVEN, DATE_EVEN, TIME_EVEN
   FROM SPED150
   WHERE D_E_L_E_T_ = ' '
   AND NFE_CHV = %exp:_cChaveNFe%
EndSql

While (_cAlias)->(!Eof())
   aAdd(_aListBox,{IIf((_cAlias)->STATUS <> 6 .And. (_cAlias)->STATUS <> 7,_oNo,_oOk),;
                  '',;//Finalidade
                  '',;//Emissao
                   DToC(SToD((_cAlias)->DATE_EVEN)),;//DtoC(oWs:NFEMONITORLOTEEVENTORESULT:dRECBTO),;//Dt Recebimento Ambiente Nacional
                  (_cAlias)->TIME_EVEN,;//oWs:NFEMONITORLOTEEVENTORESULT:cRECBTOTM;//Hora Recebimento Ambiente Nacional
                  Alltrim(Str((_cAlias)->PROTOCOLO)),;//Protocolo
                  getDesc('EVENTO',Alltrim(Str((_cAlias)->TPEVENTO))),;//C�digo do evento
                  (_cAlias)->CMOTEVEN;//Status/Recomenda��o
               })

   (_cAlias)->(DbSkip())
EndDo
(_cAlias)->(dbCloseArea())

//ordena por data do evento
aSort(_aListBox,,,{|x,y| DtoS(cTod(x[4]))+x[5] < DtoS(cTod(y[4]))+y[5]})
Return _aListBox

/*
===============================================================================================================================
Programa----------: getDesc
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 01/10/2024
Descri��o---------: Retorna a descri��o
Parametros--------: _cTipo -> C -> Indica se � uma NF-e, NF-e ou um Evento
                    _cEvento -> C -> C�digo do evento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function getDesc(_cTipo As Character,_cEvento As Character)

Local _cDesc := '' As Character

If _cTipo == 'NFE'
   Do Case
      Case _cEvento == "1"
         _cDesc := "NF-e normal"
      Case _cEvento == "2"
         _cDesc := "NF-e complementar"
      Case _cEvento == "3"
         _cDesc := "NF-e de ajuste"
      Case _cEvento == "4"
         _cDesc := "Devolu��o de mercadoria"
      OtherWise
         _cDesc := "XML n�o recebido"
   End Case
ElseIf _cTipo == 'CTE'
   Do Case
      Case _cEvento == "0"
         _cDesc := "CT-e Normal"
      Case _cEvento == "1"
         _cDesc := "CT-e de Complemento de Valores"
      Case _cEvento == "2"
         _cDesc := "CT-e de Anula��o de Valores"
      Case _cEvento == "3"
         _cDesc := "CT-e Substituto"
      OtherWise
         _cDesc := "XML n�o recebido"
   End Case
Else
   Do Case
      Case _cEvento == "210200"
         _cDesc := "Confirma��o da Opera��o"
      Case _cEvento == "210210"
         _cDesc := "Ciencia da Opera��o"
      Case _cEvento == "210220"
         _cDesc := "Desconhecimento da Opera��o"						
      Case _cEvento == "210240"
         _cDesc := "Opera��o n�o Realizada"
      Case _cEvento == "610110"
         _cDesc := "Presta��o de servi�o em desacordo"
      Case _cEvento == "110110"
      _cDesc := "Carta de corre��o"
      Case _cEvento == "100"
         _cDesc := "Autoriza��o"
      Case _cEvento == "101"
         _cDesc := "Cancelamento"
      Case _cEvento == "102"
         _cDesc := "Inutiliza��o"
   End Case
EndIf
Return _cDesc

/*
===============================================================================================================================
Programa----------: getXML
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 01/10/2024
Descri��o---------: Realiza o download do arquivo XML na esta��o do usu�rio
Parametros--------: _cChaveNFe -> C -> Chave do documento a ser consultado
                    _cXML -> C -> Arquivo XML a ser gravado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function getXML(_cChaveNFe As Character,_cXML As Character)

Local _oFile := Nil As Object

Pergunte("MCOM027")
  
If !Empty(_cXML)
   _oFile:= FWFileWriter():New(AllTrim(MV_PAR01)+_cChaveNFe+".xml")
   _oFile:SetEncodeUTF8(.T.)
   If _oFile:Create()
      _oFile:Write(AllTrim(_cXML))
      _oFile:Close()
      If _oFile:Exists()
         FWAlertSuccess("Arquivo gerado com sucesso.","MCOM02706")
      Else
         FWAlertError("Erro na grava��o do arquivo XML. Erro: "+ _oFile:Error():Message,"MCOM02707")
      EndIf
    Else
      FWAlertError("Erro na cria��o do arquivo XML. Erro: "+ _oFile:Error():Message,"MCOM02708")
    EndIf
    FreeObj(_oFile)
Else
   FWAlertWarning("N�o foi poss�vel localizar o XML desse documento. Verifique se ele foi recebido pelo TOTVS colabora��o.","MCOM02709")
EndIf
Return
