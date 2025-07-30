/*
=====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
    Autor   |   Data   |                              Motivo                                                          
=====================================================================================================================================
Igor Melgaço| 22/02/22 | Chamado 34943. Ajustes para gravação dos campos B8_LOTECTL e B8_LOTEFOR.
Alex Walluer| 10/05/22 | Chamado 40070. Nova Validacao do lote para testar o fornecedor + loja.
Alex Walluer| 01/06/22 | Chamado 40319. Nova Validacao do lote + Seq + fornecedor + loja para testar.
Alex Walluer| 14/06/22 | Chamado 40319. Nova Validacao do lote + Seq + fornecedor para testar.
Alex Walluer| 20/06/22 | Chamado 40319. Nova Validacao do lote qundo maior que 11 caracteres.
Alex Walluer| 10/08/22 | Chamado 40573. Chamada da função U_REST20Etiq() para imprmimir a etiqueta.
Alex Walluer| 13/02/23 | Chamado 42970. Retirada a chamada da função U_REST20Etiq() para imprimir a etiqueta.
Alex Walluer| 26/07/24 | Chamado 47697. Ajuste na validação para não bloquear caso o campo DD_MOTIVO for igual a 'VV'. 
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre    - Alex Wallauer - 24/10/24 - 21/11/24 -  48952  - Novo tratamento para os produtos com rastro / lotes.
Andre    - Alex Wallauer - 22/22/24 - 22/11/24 -  49204  - Correção da validação do numero do lote para quando não #.
==============================================================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa----------: MT275TOK
Autor-------------: Igor Melgaço
Data da Criacao---: 20/05/2021
Descricao---------: PE na A275TudoOK() do Programa de Bloqueio de Lotes (MATA275.PRX) - Chamado: 34943
Caminho-----------: SIGAEST -> ATUALIZACOES -> MOVIMENTAOCES -> INTERNAS -> RASTREABILIDADE -> BLOQUEIO
Parametros--------: Nenhum
Retorno-----------: Logico validando o lançamento 
===============================================================================================================================
*/ 
User Function MT275TOK()
Local _aArea	:= GetArea()
Local _aAreaSDD	:= SDD->(GetArea())
Local _aAreaSB8 := SB8->(GetArea())
Local _aAreaSD1 := SD1->(GetArea())
Local _aAreaSD5 := SD5->(GetArea())
Local _lRet	    := .T.  
Local _cNF      := ""
Local _cSerie   := ""
Local _cPed     := ""
Local _cItem    := ""
Local _cCodFor  := ""
Local _cNomFor  := ""
Local _cMsgRes1 := "Caso o lote enviado pelo fornecedor seja maior do que 11 caracteres, entrar em contato com o TI."
Local _cMsgRes2 := "Verifique o processo de compra, laudo ou NF e altere o Lote do Fornecedor antes da confirmação:"
Local _cMsgPro3 := "O Lote do Fornecedor inputado já existe no cadastro!"
Local _cMsgPed  := ""
Local _cMsgTit  := "Atenção"
Local _aTamNF   := TamSx3("D1_DOC")
Local _aTamSer  := TamSx3("D1_SERIE")
Local _aTamFil  := TamSx3("D1_FILIAL")
Local _aTamPed  := TamSx3("C7_NUM")
Local _aTamItem := TamSx3("C7_ITEM")

If FWIsInCallStack("A275LIBE")

	IF "#" $ M->DD_LOTEFOR

		_cFilial  := Subs(SDD->DD_LOTEFOR,2,_aTamFil[1])
		_cPed     := Subs(SDD->DD_LOTEFOR,2+_aTamFil[1],_aTamPed[1])
		_cItem    := Subs(SDD->DD_LOTEFOR,2+_aTamFil[1]+_aTamPed[1],_aTamItem[1])
		
        //SDD->DD_OBSERVA contem SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
		_cCodFor  := ALLTRIM(Subs(SDD->DD_OBSERVA, LEN(SF1->F1_DOC + SF1->F1_SERIE)+1) )
		_cNomFor  := POSICIONE("SA2",1,xfilial("SA2") + _cCodFor ,"A2_NOME")
		_cNF      := Subs(SDD->DD_OBSERVA,1,_aTamNF[1])
		_cSerie   := Subs(SDD->DD_OBSERVA,1+_aTamNF[1],_aTamSer[1])

		_cMsgPed := CHR(13)+CHR(10) + CHR(13)+CHR(10) ;
		+  _cCodFor + " - " + _cNomFor + CHR(13)+CHR(10) ;
		+ "NF: " + _cNF + "   Serie: " + _cSerie + CHR(13)+CHR(10) ;
		+ "Lote: " + M->DD_LOTEFOR

		U_ITMSG("Não permitida confirmação pois o campo Lote do Fornecedor contem # que identifica que não foi preenchido pelo XML na entrada do documento do Fornecedor.", _cMsgTit, _cMsgRes2 + _cMsgPed,1)
		_lRet := .F.//************************* FALSO  *************************//
	
	ELSEIf Empty(Alltrim(M->DD_LOTEFOR)) .OR. ( "#" $ SDD->DD_LOTECTL .AND. LEN(Alltrim(M->DD_LOTEFOR)) > 11 )

		U_ITMSG("Obrigatório o preenchimento do campo Lote do Fornecedor com ate 11 caracteres.", _cMsgTit,_cMsgRes1,1)
		_lRet := .F. //************************* FALSO  *************************//

	Else
	    _cDD_LOTEFOR := M->DD_LOTEFOR 
		 
		_cCodFor  := ALLTRIM(Subs(SDD->DD_OBSERVA, LEN(SB8->B8_DOC + SB8->B8_SERIE)+1,6) )//DD_OBSERVA É = a SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
		
		IF "#" $ SDD->DD_LOTECTL//VERIFICA SE O QUE TAVA ANTES ERA COM #
		   
		   _cDD_LOTEFOR := ALLTRIM(M->DD_LOTEFOR)+_cCodFor//11 + 6 do cod do forn + uma letra = 18

		   SB8->(DbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID 
		   
		   If SB8->(DbSeek(xFilial("SB8")+SDD->DD_PRODUTO + SDD->DD_LOCAL + _cDD_LOTEFOR )) //+ SDD->DD_NUMLOTE
		      
			  _cCodigo:="A"
		      _cDD_LOTEFOR := ALLTRIM(M->DD_LOTEFOR)+_cCodigo+_cCodFor//11 + 6 do cod do forn + uma letra = 18

		      DO WHILE SB8->(!EOF()) .AND. SB8->(DbSeek(xFilial("SB8")+SDD->DD_PRODUTO + SDD->DD_LOCAL + _cDD_LOTEFOR )) //+ SDD->DD_NUMLOTE

			     IF _cCodigo <> "Z"
				    _cCodigo:=SOMA1(_cCodigo)
				 ELSE//SE FOR "Z"
			        EXIT//_cCodigo:="AA"
				 ENDIF
		         _cDD_LOTEFOR := ALLTRIM(M->DD_LOTEFOR)+_cCodigo+_cCodFor

		      ENDDO
		   ENDIF
		ENDIF        
		
		M->DD_LOTEFOR:=_cDD_LOTEFOR

		// VERIFICA SE LOTE DO FORNECEDOR INPUTADO JÁ EXISTE NO CADASTRO
		If M->DD_LOTEFOR <> SDD->DD_LOTEFOR

			SB8->(DbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID 
			If !(SDD->DD_MOTIVO = 'VV') .AND.;
			    SB8->(DbSeek(xFilial("SB8")+SDD->DD_PRODUTO + SDD->DD_LOCAL + M->DD_LOTEFOR)) .AND.;
			    _cCodFor <> SB8->B8_CLIFOR//+SB8->B8_LOJA + SDD->DD_NUMLOTE
			
				_cFilial  := Subs(SDD->DD_LOTEFOR,2,_aTamFil[1])
				_cNomFor  := POSICIONE("SA2",1,xfilial("SA2") + SB8->B8_CLIFOR+SB8->B8_LOJA,"A2_NOME")
				_cNF      := Subs(SDD->DD_OBSERVA,1,_aTamNF[1])
				_cSerie   := Subs(SDD->DD_OBSERVA,1+_aTamNF[1],_aTamSer[1])
				_cMsgPro3 += CHR(13)+CHR(10) + "Nota Fiscal: " + SB8->B8_DOC  + " Serie: " + SB8->B8_SERIE

				_cMsgPed := CHR(13)+CHR(10) ;
				+  _cCodFor + "  " + _cNomFor + CHR(13)+CHR(10) ;
				+ "NF: " + _cNF + "   Serie: " + _cSerie + CHR(13)+CHR(10);
				+ "Lote: " + M->DD_LOTEFOR
				
				U_ITMSG(_cMsgPro3,_cMsgTit, _cMsgRes2 + _cMsgPed,1) // _cMsgPro3 = "O Lote do Fornecedor inputado já existe no cadastro!"
				_lRet  := .F.//************************* FALSO  *************************//
			
		    EndIf
		
	    EndIf

        // ************************************************ QUALQUER VALIDACAO DEVE SER ACIMA DESSE IF ************************************************

		If _lRet

		   _cNF      := Subs(SDD->DD_OBSERVA,1,_aTamNF[1])
		   _cSerie   := Subs(SDD->DD_OBSERVA,1+_aTamNF[1],_aTamSer[1])
           _dDtvalid := CTOD("")

		   SB8->(DbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID
		   nRecno:=0
		   If SB8->(DbSeek(xFilial("SB8")+SDD->DD_PRODUTO + SDD->DD_LOCAL + SDD->DD_LOTECTL + SDD->DD_NUMLOTE))
              _dDtvalid := SB8->B8_DTVALID
		      SB8->(RECLOCK("SB8",.F.))
		      SB8->B8_LOTECTL := M->DD_LOTEFOR
		      SB8->B8_LOTEFOR := M->DD_LOTEFOR
		      SB8->(MSUNLOCK())
		      nRecno:=SB8->(RECNO())
		   EndIf

			// DD_OBSERVA = SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
			SD1->(DBSETORDER(17)) 
			             // SD1->D1_FILIAL + D1_DOC+D1_SDOC+D1_FORNECE+D1_LOJA       + SD1->D1_COD     + SD1->D1_LOTECTL + SD1->D1_NUMLOTE + DTOS(D1_DTVALID)
			If SD1->(DBSEEK(SDD->DD_FILIAL + Alltrim(SDD->DD_OBSERVA)                + SDD->DD_PRODUTO + SDD->DD_LOTECTL + SDD->DD_NUMLOTE ))
				Do While    SD1->D1_FILIAL + SD1->(D1_DOC+D1_SDOC+D1_FORNECE+D1_LOJA)+ SD1->D1_COD     + SD1->D1_LOTECTL + SD1->D1_NUMLOTE == ;
						    SDD->DD_FILIAL + Alltrim(SDD->DD_OBSERVA)                + SDD->DD_PRODUTO + SDD->DD_LOTECTL + SDD->DD_NUMLOTE  .AND. SD1->(!EOF())
				   IF SD1->D1_LOCAL == SDD->DD_LOCAL//O LOCAL NAO ESTA NO INDICE, MAS PODE SER DIFERENTE COMO O MESMO LOTE
			          SD1->(RECLOCK("SD1",.F.))
			          SD1->D1_LOTECTL := M->DD_LOTEFOR
			          SD1->D1_LOTEFOR := M->DD_LOTEFOR
			          SD1->(MSUNLOCK())
				   ENDIF
				   SD1->(Dbskip())
				EndDo
			EndIf

			SD5->(DbSetOrder(2)) 
			             // SD5->D5_FILIAL + SD5->D5_PRODUTO + SD5->D5_LOCAL + SD5->D5_LOTECTL + SD5->D5_NUMLOTE + D5_NUMSEQ
			If SD5->(DbSeek(xFilial("SD5") + SDD->DD_PRODUTO + SDD->DD_LOCAL + SDD->DD_LOTECTL + SDD->DD_NUMLOTE ))
				Do While SD5->D5_FILIAL + SD5->D5_PRODUTO + SD5->D5_LOCAL + SD5->D5_LOTECTL + SD5->D5_NUMLOTE == ;
						 SDD->DD_FILIAL + SDD->DD_PRODUTO + SDD->DD_LOCAL + SDD->DD_LOTECTL + SDD->DD_NUMLOTE .And. SD5->(!EOF())
					SD5->(RECLOCK("SD5",.F.))
					SD5->D5_LOTECTL := M->DD_LOTEFOR
					SD5->D5_LOTEFOR := M->DD_LOTEFOR
					SD5->(MSUNLOCK())
					SD5->(Dbskip())
				EndDo
			EndIf
			
			M->DD_LOTECTL := M->DD_LOTEFOR

		EndIf

	EndIf

EndIf

RestArea(_aArea)
RestArea(_aAreaSDD)
RestArea(_aAreaSB8)
RestArea(_aAreaSD1)
RestArea(_aAreaSD5)

Return (_lRet)
