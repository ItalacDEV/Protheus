/*
=====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
 Autor         |    Data    |                              Motivo
-------------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 28/12/2018 | Chamado 27459. Ajuste segurança contra preço e quantidade zeradas.  
-------------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges  | 11/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges  | 13/01/2020 | Chamado 31724. Incluído parâmetro aProcRef. 
 ------------------------------------------------------------------------------------------------------------------------------------
 Jonathan	   | 19/03/2020 | Chamado 32309. tirado os espaços em branco no campo de e-mail. 
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 14/03/2022 | Chamado 39457. Nova mensagem acrescentada na NF de remessa. 
-------------------------------------------------------------------------------------------------------------------------------------
 Igor Melgaço  | 15/03/2022 | Chamado 38184. Alteração de Msg do Cliente. 
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 14/03/2022 | Chamado 39457. Alteracao da logica mensagem acrescentada na NF de remessa. 
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 23/02/2023 | Chamado 43076. Busca da Assistente no Cadastro de Assistente Adm Comercial responsável.
-------------------------------------------------------------------------------------------------------------------------------------
 Jerry         | 23/03/2023 | Chamado 43370. Retirado Mensagem da Nota os dados da Assistente Adm Comercial responsável.
-------------------------------------------------------------------------------------------------------------------------------------
 Jerry         | 16/06/2023 | Chamado 44059. Imprimir dados do Pedido Broker. 
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 15/08/2023 | Chamado 44277. Quando NFE de SAIDA   for de um Vend. Tipo Broker, enviar XML/PDF p/ o e-mail dele.
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 08/11/2023 | Chamado 44905. Quando NFE de ENTRADA for de um Vend. Tipo Broker, enviar XML/PDF p/ o e-mail dele.
-----------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 08/02/2024 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log. 
-----------------------------------------------------------------------------------------------------------------------------------
Lucas Borges   | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
=====================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/* 
===============================================================================================================================
Programa--------: PE01NFESEFAZ
Autor-----------: Erich Buttner
Data da Criacao-: 19/02/2013
===============================================================================================================================
Descrição-------: Ponto de Entrada executado na Transmissão da Nota Fiscal Eletronica (XML)
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: aRetorno[01] - aProd (Produto)
----------------: aRetorno[02] - cMensCli (Mensagem da nota)
----------------: aRetorno[03] - cMensFis (Mensagem Padrão)
----------------: aRetorno[04] - aDest (Destinatario)
----------------: aRetorno[05] - aNota (Numero da Nota Fiscal)
----------------: aRetorno[06] - aInfoItem (Informação Item do Pedido)
----------------: aRetorno[07] - aDupl (Existe Duplicata)
----------------: aRetorno[08] - aTransp (Informações Transportadora)
----------------: aRetorno[09] - aEntrega (Informações da Entrega)
----------------: aRetorno[10] - aRetirada (Informações da retirada)
----------------: aRetorno[11] - aVeiculo (Informações do Veiculo)
----------------: aRetorno[12] - aReboque (Informações do Reboque)
----------------: aRetorno[13] - aNfVincRur (Informações da NFP Vinculada)
----------------: aRetorno[14] - aEspVol (Informações da Especie e Volume)
----------------: aRetorno[15] - aNfVinc (Informações da NF-e Vinculada)
----------------: aRetorno[16] - aDetPag (Informações do grupo Forma de Pagamento)
----------------: aRetorno[17] - aObsCont (Informações do grupo Informações do Contribuinte)
----------------: aRetorno[18] - aProcRef (Informações do grupo Processo Referenciado)
----------------: aRetorno[19] - aMed  (Medicamentos)
----------------: aRetorno[20] - aLote (Rastreabilidade de produto: para permitir a rastreabilidade de qualquer produto sujeito a regulações sanitárias)
===============================================================================================================================
*/
User Function PE01NFESEFAZ()
 
Local aProd		:= PARAMIXB[01]
Local cMensCli	:= PARAMIXB[02]
Local cMensFis	:= PARAMIXB[03]
Local aDest		:= PARAMIXB[04]
Local aNota   	:= PARAMIXB[05]
Local aInfoItem	:= PARAMIXB[06]
Local aDupl		:= PARAMIXB[07]
Local aTransp	:= PARAMIXB[08]
Local aEntrega	:= PARAMIXB[09]
Local aRetirada	:= PARAMIXB[10]
Local aVeiculo	:= PARAMIXB[11]
Local aReboque	:= PARAMIXB[12]
Local aNfVincRur:= PARAMIXB[13]
Local aEspVol	:= PARAMIXB[14]
Local aNfVinc	:= PARAMIXB[15]
Local aDetPag	:= PARAMIXB[16]
Local aObsCont	:= PARAMIXB[17]
Local aProcRef	:= PARAMIXB[18]
//Local aMed    := PARAMIXB[19] // Se precisar Habilitar aqui
//Local aLote   := PARAMIXB[20] // Se precisar Habilitar aqui
Local aRetorno	:= {}
Local _nI		:= 0
Local _lAchou	:= .F.
Local _aArea

//Tipo da NF 
//[0] Entrada
//[1] Saida  
//*******************************
If aNota[4] == '1' //SAIDA
//*******************************
    _cTeste:=""
	_lBloker:=.F.
	If FunName() == "SPEDCTE" .Or. AModNot(SF2->F2_ESPECIE)=="57"
	   //NÃO TEM E-MAIL
	   _nPosEmail:=0
	ElseIf FunName() == "SPEDNFSE"
	   //AADD(ADEST,SA1->A1_EMAIL)// POSICAO 12
	   _nPosEmail:=12
	ELSE
       //AADD(ADEST,SA2->A2_EMAIL)// POSICAO 16
	   _nPosEmail:=16
	ENDIF

	IF _nPosEmail> 0 .AND. LEN(ADEST) > 0 .AND. LEN(ADEST) >= _nPosEmail
	      _cMailSA3:=ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_I_MAIL2"))
	      _lBloker:= (SA3->A3_I_VBROK = 'B')
	   IF !EMPTY(_cMailSA3) .AND. _lBloker
	      IF EMPTY(ADEST[_nPosEmail])
	         ADEST[_nPosEmail] := _cMailSA3
	      ELSE
	         ADEST[_nPosEmail] := ALLTRIM(ADEST[_nPosEmail])+";"+_cMailSA3
	      ENDIF
	   ENDIF
	ENDIF

	If !Empty( SF2->F2_CARGA )

		//====================================================================================================
		// Posiciona na Carga
		//====================================================================================================
		DBSelectArea("DAK")
		DAK->( DBSetOrder(1) )
		If DAK->( DBSeek( xFilial("DAK") + SF2->F2_CARGA ) )

			//====================================================================================================
			// Posiciona no Motorista
			//====================================================================================================
			DBSelectArea("DA4")
			DA4->( DBSetOrder(1) )
			If DA4->( DBSeek( xFilial("DA4") + DAK->( DAK_MOTORI + DAK_CAMINH ) ) )

				If Left( DA4_FORNEC , 1 ) == "A" // Autonomo

					aTransp := {}
					aAdd( aTransp , AllTrim( DA4->DA4_CGC )	)
					aAdd( aTransp , DA4->DA4_NOME			)
					aAdd( aTransp , ""						)
					aAdd( aTransp , DA4->DA4_END			)
					aAdd( aTransp , DA4->DA4_MUN			)
					aAdd( aTransp , Upper( DA4->DA4_EST )	)

					//====================================================================================================
					// O e-mail a ser considerado na transportadora deve ser o do cadastro do fornecedor - SA2
					//====================================================================================================
					DBSelectArea("SA2")
					SA2->( DBSetOrder(1) )
					If SA2->( DBSeek( xFilial("SA2") + SF2->( F2_I_CTRA + F2_I_LTRA ) ) )
						aAdd( aTransp , StrTran(SA2->A2_EMAIL," ", ""))
					Else
						aAdd( aTransp , ""				)
					EndIf

				Else

					DBSelectArea("SA2")
					SA2->( DBSetOrder(1) )
					If SA2->( DBSeek( xFilial("SA2") + SF2->( F2_I_CTRA + F2_I_LTRA ) ) )

						aTransp :={}
						aAdd( aTransp , AllTrim( SA2->A2_CGC )	)
						aAdd( aTransp , SA2->A2_NOME			)
						aAdd( aTransp , SA2->A2_INSCR			)
						aAdd( aTransp , SA2->A2_END				)
						aAdd( aTransp , SA2->A2_MUN				)
						aAdd( aTransp , Upper( SA2->A2_EST )	)
						aAdd( aTransp , StrTran(SA2->A2_EMAIL," ", "")	)

					EndIf

				EndIf

			EndIf

			//====================================================================================================
			// Se tem operador logistico carga adiciona o email do operador logistico para receber o danfe/xml
			//====================================================================================================
			DAI->(Dbsetorder(3))
			If DAI->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))

				Do while SF2->F2_FILIAL == DAI->DAI_FILIAL .AND. SF2->F2_DOC == DAI->DAI_NFISCA .AND. SF2->F2_SERIE == DAI->DAI_SERIE

					_acnpjs := {}

					If !EMPTY(DAI->DAI_I_OPLO)

						DBSelectArea("SA2")
						SA2->( DBSetOrder(1) )
						If SA2->( DBSeek( xFilial("SA2") + DAI->DAI_I_OPLO + DAI->DAI_I_LOPL ) ) .AND. !EMPTY(StrTran(SA2->A2_EMAIL," ", ""))  

							If ascan(_acnpjs,SA2->A2_CGC) == 0

								aTransp[7] := aTransp[7] + ";" + StrTran(SA2->A2_EMAIL," ", "")
								aAdd(_acnpjs,SA2->A2_CGC)

							Endif

						Endif

					Endif

					DAI->(Dbskip())

				Enddo

			Endif

			//====================================================================================================
			// Se tem redespacho carga adiciona o email do redespacho para receber o danfe/xml
			//====================================================================================================
			DAI->(Dbsetorder(3))
			If DAI->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))

				Do while SF2->F2_FILIAL == DAI->DAI_FILIAL .AND. SF2->F2_DOC == DAI->DAI_NFISCA .AND. SF2->F2_SERIE == DAI->DAI_SERIE

					_acnpjs := {}

					If !EMPTY(DAI->DAI_I_TRED)

						DBSelectArea("SA2")
						SA2->( DBSetOrder(1) )
						If SA2->( DBSeek( xFilial("SA2") + DAI->DAI_I_TRED + DAI->DAI_I_LTRE ) ) .AND. !EMPTY(StrTran(SA2->A2_EMAIL," ", ""))  

							If ascan(_acnpjs,SA2->A2_CGC) == 0

								aTransp[7] := aTransp[7] + ";" + StrTran(SA2->A2_EMAIL," ", "")
								aAdd(_acnpjs,SA2->A2_CGC)

							Endif

						Endif

					Endif

					DAI->(Dbskip())

				Enddo

			Endif


			//====================================================================================================
			// Posiciona no Veiculo
			//====================================================================================================
			DBSelectArea("DA3")
			DA3->( DBSetOrder(1) )
			If DA3->( DBSeek( xFilial("DA3") + DAK->DAK_CAMINH ) )

				aAdd( aVeiculo , DA3->DA3_PLACA		)
				aAdd( aVeiculo , DA3->DA3_ESTPLA	)
				aAdd( aVeiculo , ""					)

			EndIf

		EndIf

	//====================================================================================================
	// Caso nao possua carga montada
	//====================================================================================================
	Else

		//====================================================================================================
		// Posiciona no Motorista
		//====================================================================================================
		DBSelectArea( "DA4" )
		DA4->( DBSetOrder(1) )
		If DA4->( DBSeek( xFilial("DA4") + SF2->( F2_I_MOTOR + F2_I_VEICU ) ) )

			If Left( DA4_FORNEC , 1 ) == "A" // Autonomo

				aTransp := {}
				aAdd( aTransp , AllTrim( DA4->DA4_CGC )	)
				aAdd( aTransp , DA4->DA4_NOME			)
				aAdd( aTransp , ""						)
				aAdd( aTransp , DA4->DA4_END			)
				aAdd( aTransp , DA4->DA4_MUN			)
				aAdd( aTransp , Upper( DA4->DA4_EST )	)

				//====================================================================================================
				// O e-mail a ser considerado na transportadora deve ser o do cadastro do fornecedor - SA2
				//====================================================================================================
				DBSelectArea("SA2")
				SA2->( DBSetOrder(1) )
				If SA2->( DBSeek( xFilial("SA2") + SF2->( F2_I_CTRA + F2_I_LTRA ) ) )
					aAdd( aTransp , StrTran(SA2->A2_EMAIL," ", "")	)
				Else
					aAdd( aTransp , ""				)
				EndIf

			Else

				DBSelectArea("SA2")
				SA2->( DBSetOrder(1) )
				If SA2->( DBSeek( xFilial("SA2") + SF2->( F2_I_CTRA + F2_I_LTRA ) ) )

					aTransp := {}
					aAdd( aTransp , AllTrim( SA2->A2_CGC )	)
					aAdd( aTransp , SA2->A2_NOME			)
					aAdd( aTransp , SA2->A2_INSCR			)
					aAdd( aTransp , SA2->A2_END				)
					aAdd( aTransp , SA2->A2_MUN				)
					aAdd( aTransp , Upper( SA2->A2_EST )	)
					aAdd( aTransp , StrTran(SA2->A2_EMAIL," ", "")	)

				EndIf

			EndIf

		EndIf

		//====================================================================================================
		// Posiciona no Veiculo
		//====================================================================================================
		DBSelectArea("DA3")
		DA3->( DBSetOrder(1) )
		If DA3->( DBSeek( xFilial("DA3") + SF2->F2_I_VEICU ) )

			aAdd( aVeiculo , DA3->DA3_PLACA		)
			aAdd( aVeiculo , DA3->DA3_ESTPLA	)
			aAdd( aVeiculo , ""					)

		EndIf

	EndIf
    
	cMensCli := ALLTRIM(SF2->F2_I_MENSA)+" "+ALLTRIM(SF2->F2_I_MENOT)//soma o Novo campo da meansagem do Tratamento da Operação Triangular
	
    IF !EMPTY(SF2->F2_I_NTRIA)  //SF2 JÁ ESTA POSICIONADO 
       If Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_I_OBRAD") = "S"
           _nMenRemessa:=ALLTRIM(SF2->F2_I_NTRIA)//" CONFORME NOTA DE VENDA DO ADQUIRENTE ORIGINARIO "+SF2->F2_I_NTRIA+" SERIE "+SF2->F2_I_STRIA+" EMITIDA DIA "+DTOC(SF2->F2_I_DTRIA)
		   cMensCli+=_nMenRemessa
		ENDIF
	ENDIF
	
	cMensFis += Chr(13) + Chr(10) +" "+ SF2->F2_I_MENFI

	
	//====================================================================================================
	// Adiciona placa do veículo nas informações adicionais pois na versão 4.00 a informação não pode 
	// constar nos campos próprios
	//====================================================================================================
	cMensCli += IIf( Len(aVeiculo)>0 , "Placa do Veiculo: "+ Substr(aVeiculo[1],1,3)+"-"+Substr(aVeiculo[1],4,4)+"/"+aVeiculo[2]+" " , "" )

	//====================================================================================================
	// Apresentar nas msgs adicionais de qual pedido de venda se refere a NFe
	//====================================================================================================
	cMensCli += IIf( !Empty( ALLTRIM( SF2->F2_CARGA ) ) , "Carga: "+ ALLTRIM( SF2->F2_CARGA ) +" " , "" )

	If At( "Pedido Interno: "+ AllTrim( SD2->D2_PEDIDO ) , cMensCli ) > 0
		cMensCli += ""
	Else
		cMensCli += " Pedido Interno: "+ AllTrim( SD2->D2_PEDIDO )
	EndIf

	DBSelectArea("SC6")
	SC6->( DBSetOrder(1) )
	SC6->( DBSeek( xFilial("SC6") + SD2->D2_PEDIDO ) )

	cPedCli := ""

	While SC6->( !EoF() ) .And. SD2->D2_PEDIDO == SC6->C6_NUM .AND. xFilial("SC6") = SD2->D2_FILIAL

		cPedCli += IIf( AllTrim(SC6->C6_PEDCLI) $ cPedCli .Or. Empty( SC6->C6_PEDCLI ) , "" , AllTrim(SC6->C6_PEDCLI) +" , " )

	    SC6->( DBSkip() )
	EndDo

	If !Empty( AllTrim(cPedCli) )

		If At( "Pedido Cliente: "+ AllTrim(cPedCli) , cMensCli ) > 0
			cMensCli += ""
		Else
			cMensCli += " Pedido Cliente: "+ AllTrim(cPedCli)
		EndIf

	EndIf

    SC5->(DBSETORDER(1))
    SC5->(DBSeek(xFilial("SC5")+SD2->D2_PEDIDO))

	//Analisa data de entrega para imprimir a data ou entrega imediata
	ctipEnt		:= SC5->C5_I_AGEND//GetAdvFVal( "SC5" , "C5_I_ AGEND" , xFilial("SC5") + SD2->D2_PEDIDO , 1 , "" )
	dDtEnt		:= SC5->C5_I_DTENT//GetAdvFVal( "SC5" , "C5_I_ DTENT" , xFilial("SC5") + SD2->D2_PEDIDO , 1 , "" )

	If ctipEnt $ 'I/O' .AND. dDtEnt <= date()

		cMensCli	+= " Data de Entrega: ENTREGA IMEDIATA "
	
	ElseIf ctipEnt $ 'I/O' .AND. dDtEnt > date()

		cMensCli	+= " Data de Entrega: " + DtoC(dDtEnt)

	ElseIf !ctipEnt $ 'I/O'

		cMensCli	+= " Data de Entrega: " + DtoC(dDtEnt)

	Endif
 
	//Carrega mensagem de hora de entrega
	chorent		:= SC5->C5_I_HORP //GetAdvFVal( "SC5" , "C5_I_HORP" , xFilial("SC5") + SD2->D2_PEDIDO , 1 , "" )
	If !empty(chorent)	
		cMensCli += " Cliente recebe: " + chorent		
	Endif
		
	If !Empty( AllTrim(SC5->C5_I_PEDDW ) )

		cMensCli += " Pedido Broker: "+ AllTrim(SC5->C5_I_PEDDW )

	EndIf
	
	For _nI := 1 To Len( aProd )
		aProd[_nI][4] := GETADVFVAL( "SB1" , "B1_DESC" , xFilial("SB1") + aProd[_nI][2] , 1 , '' )
	Next _nI

	//==============================================================================================================
	// Se parâmetro IT_ARRPRC for igual a S para a filial atual, não existir desconto para o item por desconto
	// comercial ou de impostos, então irá garantir que o preço x quantidade é igual ao valor total do item
	//==============================================================================================================

	If  alltrim(U_ITGETMV( "IT_ARRPRC" , "N")) == "S"

		_nI := 1
		_aArea := SD2->(GetArea())
		_lAchou := .F.

		Do while _nI <=  len(aProd)

			DBSelectArea("SD2")
			SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->( Dbgotop())

			_lAchou :=  SD2->( DBSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA + aProd[_nI][02] + aInfoItem[_nI][04] ) )

			If _lAchou .and. SD2->D2_DESCZFP == 0 .AND. SD2->D2_DESCZFR == 0 .AND. SD2->D2_DESCZFC == 0 .AND. SD2->D2_DESCON == 0 .AND. SF2->F2_DESCONT == 0

			   aProd[_nI][16] := SD2->D2_PRCVEN
			   
			   If SD2->D2_PRCVEN > 0 .and. aProd[_nI][12] > 0
			   
			   		aProd[_nI][10] := ROUND(aProd[_nI][12] * SD2->D2_PRCVEN,2)
			   		
			   Endif

			Endif

			_nI++

		Enddo

		SD2->( RestArea(_aArea) )

	Endif

//Tipo da NF 
//[0] Entrada
//[1] Saida  
//*******************************
//ELSEIf aNota[4] == '0' //ENTRADA
//*******************************
Else // NOTA DE ENTRADA

    _cTeste:=""
	_lTemBloker:=.F.
	If FunName() == "SPEDCTE" .Or. AModNot(SF1->F1_ESPECIE)=="57"
	   //NÃO TEM E-MAIL
	   _nPosEmail:=0
	   _cTeste:='Entrou no If FunName() == "SPEDCTE" .Or. AModNot(SF1->F1_ESPECIE)=="57" '+CHR(13)+CHR(10)
	ELSE
       //AADD(ADEST,SA2->A2_EMAIL)// POSICAO 16
	   _nPosEmail:=16
	   _cTeste:='Entrou no ELSE / POSICAO 16 '+CHR(13)+CHR(10)
	ENDIF
    IF SF1->F1_TIPO = "D" .AND. SF1->F1_FORMUL = "S" .AND. ;
	   _nPosEmail> 0 .AND. LEN(ADEST) > 0 .AND. LEN(ADEST) >= _nPosEmail  

	   _cTeste  +='ENTROU no SF1->F1_TIPO = "D" .AND. SF1->F1_FORMUL = "S" .AND. LEN(ADEST) > 0 .AND. LEN(ADEST) >= _nPosEmail "'+CHR(13)+CHR(10)

	   SD1->(DBSETORDER(1))
	   SF2->(DBSETORDER(1))
	   _cMailSA3:=""
	   IF SD1->(DBSEEK(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)) 
	      aSD1:={}
		  DO WHILE  SD1->(!EOF()) .AND. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA = ;
		                                SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
		  
		     IF SF2->(DBSEEK(SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI) ))
	            _cMailSA3+=ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_I_MAIL2"))+";"
		   	    IF (SA3->A3_I_VBROK = 'B')
		   	       _lTemBloker:=.T.
		   	    ENDIF
                _cTeste  +='_cMailSA3 = '+_cMailSA3+CHR(13)+CHR(10)
                _cTeste  +='SA3->A3_I_VBROK = '+SA3->A3_I_VBROK+CHR(13)+CHR(10)
			 ELSE	   
	            _cTeste  +='NAÕ ACHOU D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA: '+SD1->D1_FILIAL+"-"+SD1->D1_NFORI+"-"+SD1->D1_SERIORI+"-"+SD1->D1_FORNECE+"-"+SD1->D1_LOJA+CHR(13)+CHR(10)		     
			 ENDIF
			 EXIT 
             //SD1->(DBSKIP()) 
		  ENDDO

	   ELSE
	      _cTeste  +='NAÕ ACHOU SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA: '+SF1->F1_FILIAL+"-"+SF1->F1_DOC+"-"+SF1->F1_SERIE+"-"+SF1->F1_FORNECE+"-"+SF1->F1_LOJA+CHR(13)+CHR(10)
	   ENDIF
	   _cTeste  +='ADEST[_nPosEmail] ANTES: '+ADEST[_nPosEmail]+CHR(13)+CHR(10)
	   IF !EMPTY(_cMailSA3) .AND. _lTemBloker
	      IF EMPTY(ADEST[_nPosEmail])
	         ADEST[_nPosEmail] := _cMailSA3
	      ELSE
	         ADEST[_nPosEmail] := ALLTRIM(ADEST[_nPosEmail])+";"+_cMailSA3
	      ENDIF
	   ENDIF
      _cTeste+='ADEST[_nPosEmail] DEPOIS: '+ADEST[_nPosEmail]+CHR(13)+CHR(10)
	ELSE
	  _cTeste+='NÃO ENTROU no SF1->F1_TIPO = "'+SF1->F1_TIPO+'"  .AND. SF1->F1_FORMUL = "'+SF1->F1_FORMUL+'" '+CHR(13)+CHR(10)
	  _cTeste+=' E  LEN(ADEST) > 0 .AND. LEN(ADEST) >= _nPosEmail "'+CHR(13)+CHR(10)
	ENDIF

    If _lTemBloker .OR. SuperGetMV("IT_AMBTEST",.F.,.T.)
	   _cTeste+='AMBIENTE: '+ALLTRIM(GETENVSERVER())+CHR(13)+CHR(10)
	   IF TYPE("__cUserID") = "C"
	      _cTeste+='USUARIO: '+UsrFullName(__cUserID)+CHR(13)+CHR(10)
	   ENDIF
       _cFileNome:="\temp\pe01nfesefaz_"+ALLTRIM(SF1->F1_FILIAL)+"_"+ALLTRIM(SF1->F1_DOC)+"_"+ALLTRIM(SF1->F1_SERIE)+"_"+ALLTRIM(+SF1->F1_FORNECE)+"_"+ALLTRIM(SF1->F1_LOJA)+".TXT"
       MemoWrite(_cFileNome,_cTeste)
	ENDIF

	cMensCli	:= SF1->F1_I_MENSA
	cMensFis	+= Chr(13) + Chr(10) +" "+ SF1->F1_I_MENFI

	If !Empty( SF1->F1_L_LINHA )

		DBSelectArea("ZL3")
		ZL3->( DBSetOrder(1) )
		If ZL3->( DBSeek( xFilial("ZL3") + SF1->F1_L_LINHA ) )

			DBSelectArea("SA2")
			SA2->( DBSetOrder(1) )
			If SA2->( DBSeek( xFilial("SA2") + ZL3->( ZL3_FRETIS + ZL3_FRETLJ ) ) )

				aTransp := {}
				aAdd( aTransp , AllTrim( SA2->A2_CGC )	)
				aAdd( aTransp , SA2->A2_NOME			)
				aAdd( aTransp , SA2->A2_INSCR			)
				aAdd( aTransp , SA2->A2_END				)
				aAdd( aTransp , SA2->A2_MUN				)
				aAdd( aTransp , Upper( SA2->A2_EST )	)
				aAdd( aTransp , StrTran(SA2->A2_EMAIL," ", "")	)

			EndIf

		EndIf

	Else

		//====================================================================================================
		// Posiciona no Motorista
		//====================================================================================================
		DBSelectArea("DA4")
		DA4->( DBSetOrder(1) )
		If DA4->( DBSeek( xFilial("DA4") + SF1->( F1_I_MOTOR + F1_I_VEICU ) ) )

			If Left( DA4_FORNEC , 1 ) == "A" // Autonomo

				aTransp := {}
				aAdd( aTransp , AllTrim( DA4->DA4_CGC )	)
				aAdd( aTransp , DA4->DA4_NOME			)
				aAdd( aTransp , ""						)
				aAdd( aTransp , DA4->DA4_END			)
				aAdd( aTransp , DA4->DA4_MUN			)
				aAdd( aTransp , Upper( DA4->DA4_EST )	)

				//====================================================================================================
				// O e-mail a ser considerado na transportadora deve ser o do cadastro do fornecedor - SA2
				//====================================================================================================
				DBSelectArea("SA2")
				SA2->( DBSetOrder(1) )
				If SA2->( DBSeek( xFilial("SA2") + DA4->( DA4_FORNEC + DA4_LOJA ) ) )
					aAdd( aTransp , StrTran(SA2->A2_EMAIL," ", "")	)
				Else
					aAdd( aTransp , ""				)
				EndIf

			Else

				DBSelectArea("SA2")
				SA2->( DBSetOrder(1) )
				If SA2->( DBSeek( xFilial("SA2") + DA4->( DA4_FORNEC + DA4_LOJA ) ) )

					aTransp := {}
					aAdd( aTransp , AllTrim( SA2->A2_CGC )	)
					aAdd( aTransp , SA2->A2_NOME			)
					aAdd( aTransp , SA2->A2_INSCR			)
					aAdd( aTransp , SA2->A2_END				)
					aAdd( aTransp , SA2->A2_MUN				)
					aAdd( aTransp , Upper( SA2->A2_EST )	)
					aAdd( aTransp , StrTran(SA2->A2_EMAIL," ", "")	)

				EndIf

			EndIf

		EndIf

		//====================================================================================================
		// Posiciona no Veiculo
		//====================================================================================================
		DBSelectArea("DA3")
		DA3->( DBSetOrder(1) )
		If DA3->( DBSeek( xFilial("DA3") + SF1->F1_I_VEICU ) )

			aAdd( aVeiculo , DA3->DA3_PLACA		)
			aAdd( aVeiculo , DA3->DA3_ESTPLA	)
			aAdd( aVeiculo , ""					)

		EndIf

	EndIf

	//====================================================================================================
	// Adiciona placa do veículo nas informações adicionais pois na versão 4.00 a informação não pode 
	// constar nos campos próprios
	//====================================================================================================
	cMensCli += IIf( Len(aVeiculo)>0 , "Placa do Veiculo: "+ Substr(aVeiculo[1],1,3)+"-"+Substr(aVeiculo[1],4,4)+"/"+aVeiculo[2]+" " , "" )

EndIf

cMensFis := StrTran( cMensFis , CHAR(10) , ";" )
cMensFis := StrTran( cMensFis , CHAR(13) , ";" )
cMensCli := StrTran( cMensCli , CHAR(10) , ";" )
cMensCli := StrTran( cMensCli , CHAR(13) , ";" )

aAdd( aRetorno , aProd		)
aAdd( aRetorno , cMensCli	)
aAdd( aRetorno , cMensFis	)
aAdd( aRetorno , aDest		)
aAdd( aRetorno , aNota		)
aAdd( aRetorno , aInfoItem	)
aAdd( aRetorno , aDupl		)
aAdd( aRetorno , aTransp	)
aAdd( aRetorno , aEntrega	)
aAdd( aRetorno , aRetirada	)
aAdd( aRetorno , aVeiculo	)
aAdd( aRetorno , aReboque	)
aAdd( aRetorno , aNfVincRur	)
aAdd( aRetorno , aEspVol	)
aAdd( aRetorno , aNfVinc	)
aAdd( aRetorno , aDetPag	)
aAdd( aRetorno , aObsCont	)
aAdd( aRetorno , aProcRef	)

Return( aRetorno )
