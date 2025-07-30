/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 22/01/2019 | Corrigida passsagem da Esp�cie. Chamado 31801
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 07/07/2023 | Inclu�do controle dos documentos marcados e �rea de trabalho. Chamado 44403
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/04/2024 | Criado tratamento para quando n�o � retornado o status do documento. Chamado 46806
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: MCOM005
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 24/03/2017
===============================================================================================================================
Descri��o---------: Rotina para excluir e reprocessar os documentos no COMXCOL
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. - Executou opera��o - .F. Opera��o abortada pelo usu�rio
===============================================================================================================================
*/
User Function MCOM005

//Private aRegMark  := {} Vari�vel declara no COMXCOL. Ao exlcuir uma nota, excluir ela da vari�vel para que n�o seja processada idenvidamente mesmo estando deletada
Local _nProcOpc := 1
Local _cAlias	:= GetNextAlias()
Local _cAlias150:= ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt   	:= ""
Local cChaveNFe := ""
Local _cCodRet	:= ""
Local _cAmbiente:= 0
Local _nPos		:= 0

_nProcOpc := Aviso("Aten��o", "Confirma a exclus�o dos documentos marcados?"+ CRLF +;
"Caso o documento esteja cancelado na SEFAZ ou possua Evento de Opera��o N�o Realizada/Desconhecimento, ser� realizada exclus�o definitiva. Os demais ser�o reprocessados.";
, { "N�o", "Sim"}, 2)

If _nProcOpc == 2

	If CTIsReady()
	  	//Obtem o codigo da entidade 
		oWS := WsSPEDAdm():New()
		oWS:cUSERTOKEN := "TOTVS"
		oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
		oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
		oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
		oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
		oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
		oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
		oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
		oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
		oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
		oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
		oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
		oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
		oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
		oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
		oWS:oWSEMPRESA:cCEP_CP     := Nil
		oWS:oWSEMPRESA:cCP         := Nil
		oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
		oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
		oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
		oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
		oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
		oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
		oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cINDSITESP  := ""
		oWS:oWSEMPRESA:cID_MATRIZ  := ""
		oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
		oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
		
		If oWS:ADMEMPRESAS()
			cIdEnt  := oWs:cADMEMPRESASRESULT
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
			Return
		EndIf
			
		oWS:= WsNFeSBra():New()
		oWS:cUserToken   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		ows:cCHVNFE		 := cChaveNFe
		oWS:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
	Else
		Aviso("SPED","Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!",{"OK"},3)
		Return
	EndIf
		
	//Traz documentos marcados
	BeginSQL Alias _cAlias
		SELECT SDS.DS_FILIAL, SDS.DS_DOC, SDS.DS_SERIE, SDS.DS_FORNEC, SDS.DS_LOJA, SDS.DS_ARQUIVO, SDS.DS_ESPECI
		FROM %Table:SDS% SDS
		WHERE SDS.DS_OK = %Exp:cMarca% AND SDS.DS_STATUS != 'P' AND SDS.%NotDel%
	EndSQL

	SDT->(dbSetOrder(3))
	SDS->(dbSetorder(1))

	While !(_cAlias)->(EOF())
		
		oWS:cCHVNFE := SUBSTR((_cAlias)->DS_ARQUIVO,4,44)
		If oWS:ConsultaChaveNFE()

			//-- Deleta itens do documento 
			If SDT->(dbSeek((_cAlias)->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
				While !SDT->(EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == (_cAlias)->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE) 
					RecLock("SDT",.F.)
					SDT->(dbDelete())
					SDT->(MsUnLock())		
					SDT->(dbSkip())
				End
			EndIf
		
			//-- Deleta cabecalho do documento
			If SDS->(dbSeek((_cAlias)->(DS_FILIAL+DS_DOC+DS_SERIE+DS_FORNEC+DS_LOJA)))
				_nPos := aScan(aRegMark,SDS->(RECNO()))
				If _nPos > 0
					aDel(aRegMark,_nPos)
					aSize(aRegMark,Len(aRegMark)-1)
				Endif
				RecLock("SDS",.F.)
				SDS->(dbDelete())
				SDS->(MsUnLock())	
			EndIf		
            
			//====================================
			//101 -> Cancelada
			//102 -> Inutilizada
			//155 -> Cancelada fora do prazo
			//205 -> Denegada
			//301 -> Denegada emitente
			//302 -> Denegada destinat�rio
			//303 -> Denegada Destinat�rio n�o habilitado a operar na UF
			//====================================
			_cCodRet	:= AllTrim(oWS:oWSCONSULTACHAVENFERESULT:cCODRETNFE)
			_cAmbiente	:= oWS:oWSCONSULTACHAVENFERESULT:nAMBIENTE

			DbSelectArea("CKO")
			CKO->(dbSetorder(1))
			If CKO->(DbSeek((_cAlias)->DS_ARQUIVO))
				If _cCodRet $ '101/155'
					RecLock("CKO",.F.)
					CKO->CKO_FLAG := '9'
					If AllTrim((_cAlias)->DS_ESPECI)=='SPED'
						CKO->CKO_CODERR := 'COM040'
					ElseIf AllTrim((_cAlias)->DS_ESPECI)=='CTE'
						CKO->CKO_CODERR := 'COM036'
					ElseIf AllTrim((_cAlias)->DS_ESPECI)=='CTEOS'
						CKO->CKO_CODERR := 'COM045'
					EndIf
					CKO->(MsUnLock())
				ElseIf _cCodRet $ '102/205/301/302/303'
					RecLock("CKO",.F.)
					CKO->CKO_FLAG := '9'
					If AllTrim((_cAlias)->DS_ESPECI)=='SPED'
						CKO->CKO_CODERR := 'COM041'
					ElseIf AllTrim((_cAlias)->DS_ESPECI)=='CTE'
						CKO->CKO_CODERR := 'COM037'
					ElseIf AllTrim((_cAlias)->DS_ESPECI)=='CTEOS'
						CKO->CKO_CODERR := 'COM046'
					EndIf
					CKO->(MsUnLock())
				ElseIf AllTrim((_cAlias)->DS_ESPECI) == 'SPED'
					//============================================================================
					//Verifica se NF-e recebeu alguma manifesta��o informando que a oper�a��o n�o 
					//foi realizada (3) ou que � desconhecida (2). Nesses status n�o � necess�rio
					//reprocessar o documeto.
					//============================================================================
					DbSelectArea("C00")
					C00->(dbSetorder(1))
					If C00->(dbSeek((_cAlias)->(DS_FILIAL+SUBSTR(DS_ARQUIVO,4,44)))) .And. C00->C00_CODEVE=="3  "
						If C00->C00_STATUS $ "2/3"
							RecLock("CKO",.F.)
							CKO->CKO_FLAG := '9'
							CKO->CKO_CODERR := IIf(C00->C00_STATUS=='2','MCOM01','MCOM02')
							CKO->(MsUnLock())
						Else
							RecLock("CKO",.F.)
							CKO->CKO_FLAG := '0'
							CKO->(MsUnLock())
						EndIf
					Else
						RecLock("CKO",.F.)
						CKO->CKO_FLAG := '0'
						CKO->(MsUnLock())
	               	EndIf
	               	C00->(DBCloseArea())
	     		ElseIf AllTrim((_cAlias)->DS_ESPECI) == 'CTE' .And. !Empty(_cCodRet)
					//============================================================================
					//Verifica se CT-e foi recusado pelo evento 610110 - Presta��o de Servi�o 
					//em Desacordo
					//============================================================================
					_cAlias150	:= GetNextAlias()
					
					BeginSQL Alias _cAlias150
				      SELECT 1 ACHOU
				      	FROM SPED150
				      WHERE SPED150.D_E_L_E_T_ = ' '
				         AND SPED150.NFE_CHV = %exp:SUBSTR((_cAlias)->DS_ARQUIVO,4,44)%
				         AND SPED150.ID_ENT = %exp:cIdEnt%
				         AND SPED150.TPEVENTO = '610110'
				         AND SPED150.AMBIENTE = %exp:_cAmbiente%
				      	 AND SPED150.STATUS = 6
					EndSQL
					
					If (_cAlias150)->ACHOU == 1
						RecLock("CKO",.F.)
						CKO->CKO_FLAG := '9'
						CKO->CKO_CODERR := 'MCOM03'
						CKO->(MsUnLock())
					Else
						RecLock("CKO",.F.)
						CKO->CKO_FLAG := '0'
						CKO->(MsUnLock())
					EndIf
					(_cAlias150)->(dbCloseArea())
	     		Else
					If Empty(_cCodRet)
						MsgAlert("N�o foi poss�vel realizar a consulta da chave "+SUBSTR((_cAlias)->DS_ARQUIVO,4,44)+" corretamente. O documento ser� colocado novamente na fila de processamento. Acione a TI.","MCOM00501")
					EndIf
					RecLock("CKO",.F.)
					CKO->CKO_FLAG := '0'
					CKO->(MsUnLock())
	         	EndIf
	 		EndIf
	 		//============================================================================
			//Se o documento for cancelado n�o se deve realizar nenhum tipo de manifesta��o
			//Excluir registro para evitar manifesta��o indevida.
			//============================================================================
			DbSelectArea("C00")
			C00->(dbSetorder(1))
			If AllTrim((_cAlias)->DS_ESPECI) == 'SPED' .And. _cCodRet $ '101/155' .And. C00->(dbSeek((_cAlias)->(DS_FILIAL+SUBSTR(DS_ARQUIVO,4,44)))) ;
				.And. C00->C00_STATUS == '0' .And. C00->C00_CODEVE == '1  '
				RecLock("C00",.F.)
				C00->C00_SITDOC := '3'
				C00->(dbDelete())
				C00->(MsUnLock())
			EndIf
			C00->(DBCloseArea())
		Else	
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		EndIf
		(_cAlias)->(dbSkip())
	End

	(_cAlias)->(dbCloseArea())
	SDS->(dbGoTop())

EndIf

Return
