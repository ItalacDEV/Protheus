/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor           |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------- 
Igor Melga�o     | 09/01/2023 | Chamado 42331. Ajustes para exclus�o dos campos Z30_RBANCO,Z30_RAGENC e Z30_RCONTA.
Igor Melga�o     | 10/01/2023 | Chamado 42331. Ajustes para o metodo de consulta nota.
Igor Melga�o     | 11/01/2023 | Chamado 42331. Corre��o de regra de rateio e exclus�o de compensa��o.
Igor Melga�o     | 20/01/2023 | Chamado 42331. Ajustes para devolu��o de adiantamento, retornar status 500 qdo ocorrer erro e
                                               busca na tabela Z26 sem o C�digo do Fornecedor para evitar registros em 
											   duplicidade com o mesmo numero de relat�rio qdo n�o � validado o fornecedor.
Igor Melga�o     | 06/02/2023 | Chamado 42331. Ajuste para somar centros de custo dentro da natureza.
Igor Melga�o     | 10/02/2023 | Chamado 42331. Ajustes para Renomear as fun��es.
Igor Melga�o     | 11/07/2023 | Chamado 44438. Ajustes para validar a inclus�o do Fornecedor.
Igor Melga�o     | 11/07/2023 | Chamado 44701. Ajustes para validar a inclus�o do Fornecedor.
Igor Melga�o     | 08/09/2023 | Chamado 44974. Ajuste para retirada dos caracteres especiais do campo historico.
Igor Melga�o     | 15/09/2023 | Chamado 45040. Tratamento para data de vencimento de acordo com a filial do titulo.
Igor Melga�o     | 26/09/2023 | Chamado 45040. Troca de data de vencimento para 14 e 29.
Igor Melga�o     | 29/09/2023 | Chamado 45195. Corre��o de tratamento de data de vencimento para 14 e 29.
Igor Melga�o     | 09/10/2023 | Chamado 45271. Ajustes para data de vencimento em dia util anterior se cair no Sabado, Domingo ou Feriado.
Igor Melga�o     | 08/12/2023 | Chamado 45694. Ajustes para configura��o da n�o integra��o do t�tulo no financeiro e integra��o por lote.
===============================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Altera��o
---------------------------------------------------------------------------------------------------------------------------------------------------------
Vanderlei Alves  - Igor Melga�o      - 05/02/2025 - 05/02/2025 - 49839   - Ajustes para corre��o na inclus�o do CVI
Vanderlei Alves  - Igor Melga�o      - 06/02/2025 - 06/02/2025 - 49839   - Tratamento para leitura do percentual de rateio
Ant�nio Ramos    - Igor Melga�o      - 19/02/2025 - 19/02/2025 - 49839   - Ajuste na compensa��o do AVI
Ant�nio Ramos    - Igor Melga�o      - 21/02/2025 - 21/02/2025 - 49839   - Ajustes na compensa��o e envio de workflow
Ant�nio Ramos    - Igor Melga�o      - 26/02/2025 - 26/02/2025 - 50028   - Ajustes para leitura do Valor excedido
====================================================================================================================================================
*/
#Include "ApWebSrv.ch"
#Include 'ApWebex.ch'
#Include "Totvs.Ch"
#Include "RESTFUL.Ch"
#Include "FWMVCDef.Ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH" 
#include 'Fileio.ch'  
#INCLUDE "TBICODE.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "COLORS.CH"

#DEFINE cEnt Chr(10)+ Chr(13)

Static _nRecnoZ26 := 0
Static _nRecnoZ29 := 0


/*
===============================================================================================================================
Programa----------: MFIN021
Autor-------------: Igor Melga�o
Data da Criacao---: 21/11/2022
===============================================================================================================================
Descri��o---------: Rotinas de Integra��o REST Paytrack. Chamado: 42331 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/ 

//*************
// POST
//*************
WsRestFul PostTitulo Description "Metodo Responsavel por gravar dados do T�tulo na temporaria"

	WsData cCgcEmp	As Char

	WsMethod Post Description "Gravar dados do T�tulo na tabela temporaria" WsSyntax "/PostTitulo"

End WsRestFul

WsMethod Post WsReceive cCgcEmp WsService PostTitulo
	Local cBody     := ::GetContent() As Char
	Local _cJson    := "" As Char
	Local _lRetorno := .F. As Logical

	If DecodeUtf8(cBody) <> Nil
		cBody := DecodeUtf8(cBody)
	EndIf

	_lRetorno := U_MFIN021I(cBody,,.T.,@_cJson,"I")
	
	If !_lRetorno
		//SetRestFault(400,'Ops')
		::setStatus(500) 
	EndIf

	::SetResponse( _cJson )

Return(.T.)

/*
===============================================================================================================================
Programa----------: MFIN021I
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Realiza de Integra��o
===============================================================================================================================
Parametros--------: cBody
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
User Function MFIN021I(cBody As Char,_cErro As Char,_lRest As Logical,_cJson As Char,_cOper As Char) As Logical
	Local lContinua     := .T. As Logical
	Local _nI           := 0 As Numeric
	Local _nZ           := 0 As Numeric
	Local _nY           := 0 As Numeric
	Local _nW           := 0 As Numeric
	Local _cIDInte      := "" As Char
	Local aVetSE2       := {} As Array
	Local _aAuxSEV      := {} As Array
	Local _aRatSEV      := {} As Array
	Local _aAuxSEZ      := {} As Array
	Local _aRatSEZ      := {} As Array
	Local _FilialHab    := .F. As Logical
	Local _cFilialJso   := "" As Char
	Local _cPrefixo     := "" As Char
	Local _cNumero      := "" As Char
	Local _cParcela     := "" As Char
	Local _cFornec 		:= "" As Char
	Local _cLoja   		:= "" As Char
	Local _cNomFor 		:= "" As Char
	Local _nValor       := 0 As Numeric
	Local _cContCont    := "" As Char	
	Local _cHist        := "" As Char
	Local _cNatureza    := "" As Char	
	Local _cCentCus     := "" As Char
	Local _dDate        := CTOD("") As Date	
	Local _dVencto      := CTOD("") As Date
	Local _cTime        := "" As Char
	Local _aAuxZ26      := {} As Array
	Local _aAuxZ27      := {} As Array
	Local _aAuxZ28      := {} As Array
	Local _aAuxZ29      := {} As Array
	Local _aVetZ27      := {} As Array
	Local _aVetZ28      := {} As Array
	Local _aParam       := {} As Array
	Local _cPNat        := "" As Char
	Local _cPContaCtb   := "" As Char
	Local _cPCentro     := "" As Char
	Local _cPHistorico  := "" As Char
	Local _cSEV_Nat     := "" As Char
	Local _cCentro  	:= "" As Char
	Local _cPreOri      := "" As Char

	//Vari�veis usadas na Compensacao
	Local lRet      	:= .F. As Logical
	Local aPA_NDF   	:= {} As Array
	Local aContabil 	:= {} As Array
	Local aNF       	:= {} As Array
	Local bBlock    	:= Nil As Block
	Local aEstorno  	:= {} As Array
	Local nSldComp  	:= 0 As Numeric
	Local nTaxaPA   	:= 0 As Numeric
	Local nTaxaNF   	:= 0 As Numeric
	Local nHdl      	:= 0 As Numeric
	Local nOperacao 	:= 0 As Numeric
	Local aRecSE5   	:= {} As Array
	Local aNDFDados		:= {} As Array
	Local lHelp     	:= .T. As Logical

	Local _nRecnoZ29 	:= 0 As Numeric
	Local _cChave 		:= "" As Char
	Local _cBanco 		:= "" As Char
	Local _cAgencia 	:= "" As Char
	Local _cConta 		:= "" As Char
	Local _nValorRat 	:= 0 As Numeric

	Local _nVrRatCC 	:= 0 As Numeric
	Local _nPerRatCC 	:= 0 As Numeric
	Local _nPerRat   	:= 0 As Numeric
	Local _nRecnoAVI 	:= 0 As Numeric
	Local _nRecnoCVI 	:= 0 As Numeric
	
	Local _nValorCVI 	:= 0 As Numeric
	Local _nValorDev 	:= 0 As Numeric
	Local _cNatDevol 	:= U_ITGetMV("IT_PNATDEV","341006") As Char
	Local _cFilVencto   := U_ITGetMV("IT_PTFILVE","92") As Char
	//Local _aBaixa    	:= {}
	Local _nRatSEZ      := 0 As Numeric
	Local _cCentroRat   := "" As Char
	Local _lPNaorateia  := .F. As Logical
	Local _lPNaoIntFin  := .F. As Logical
	Local _lAFIN036     := FWIsInCallStack("U_AFIN031G") As Logical
	Local _cEmaiFin	    := "" As Char
	Local _cPEmailWork  := "" As Char
	Local _aSizes       := {} As Array
	Local _aCab         := {} As Array
	Local _aDados 	    := {} As Array
	Local _nValExc      := 0 As Numeric
	Local _nTotExc      := 0 As Numeric
	Local _cCPFCNPJ     := ""

	Default _cErro  	:= "" 
	Default _lRest  	:= .T. 
	Default _cJson  	:= "" 
	Default _cOper  	:= "I" 

	Private oJsoAux   	:= Nil As Object
	Private lMsErroAuto := .F. As Logical

	If _cOper == "I" .OR. _cOper == "R" 
		FWJsonDeserialize(cBody, @oJsoAux)

		If _cOper == "R"
			_cFilialJso := xFilial("Z29")
		Else
			_cFilialJso := oJsoAux:FILIAL
		EndIf
		
		If _lRest
			RpcClearEnv()
			RpcSetEnv("01",_cFilialJso)
		EndIf

		_FilialHab    := GetMv("MV_MULNATP",.F.)

		For _ni := 1 to len(oJsoAux:TITULOS)

			_cIDInte   := MFIN021GNU()
			_cPrefixo  := oJsoAux:TITULOS[_ni]:PREFIXO
			_cNumero   := oJsoAux:TITULOS[_ni]:NUMERO
			_cParcela  := Space(2)
			_cTipo     := Subs(oJsoAux:TITULOS[_ni]:TIPO + space(3),1,3)
			_nValor    := oJsoAux:TITULOS[_ni]:VALOR
			_cCPFCNPJ  := oJsoAux:TITULOS[_ni]:CGC
			_cContCont := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni], "CONTACONTABIL"),oJsoAux:TITULOS[_ni]:CONTACONTABIL,"")
			_cHist     := U_ITSUBCHR(Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni], "HISTORICO"),oJsoAux:TITULOS[_ni]:HISTORICO,"")	)
			_cNatureza := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni], "NATUREZA"),oJsoAux:TITULOS[_ni]:NATUREZA,"")	
			_cCentCus  := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni], "CENTROCUSTO"),oJsoAux:TITULOS[_ni]:CENTROCUSTO,"")
			_cMultiNat := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni], "MULTINAT"),oJsoAux:TITULOS[_ni]:MULTINAT,"1")
			_dDate     := Date()
			_cTime     := Time()
			_cPreOri   := "" //Iif(_cPrefixo == "CVI" .OR. (_cPrefixo <> "AVI" .AND. _cPrefixo <> "RVI" .AND. Alltrim(_cTipo) == 'NF') , "AVI","   ")			
			_aParam    := MFIN021GP(_cFilialJso,_cPrefixo)
			
			If _lAFIN036
				_dVencto := MV_PAR01
			Else
				_dVencto   := Iif(_cFilialJso $ _cFilVencto,U_MFIN021VEN(_dDate),STOD(oJsoAux:TITULOS[_ni]:VENCIMENTO))
			EndIf
			
			If _cPrefixo == "CVI" 
				_cPreOri := "AVI"
			EndIf

			lContinua := .F.

			//Valida Fornecedor
			DbSelectArea("SA2")
			DbSetOrder(3)
			If Dbseek(xFilial("SA2")+_cCPFCNPJ)
				Do While oJsoAux:TITULOS[_ni]:CGC == ALLTRIM(SA2->A2_CGC) .AND. SA2->(!EOF())
					If SA2->A2_MSBLQL <> '1' .AND. SA2->A2_I_CLASS $ "FVJ"
						
						If SA2->A2_I_CLASS == "J"
							_cFornec := SA2->A2_COD
							_cLoja   := SA2->A2_LOJA
							_cNomFor := SA2->A2_NREDUZ

							lContinua := .T.
							Exit
						ElseIf SA2->A2_I_CLASS == "V"
							_cFornec := SA2->A2_COD
							_cLoja   := SA2->A2_LOJA
							_cNomFor := SA2->A2_NREDUZ

							lContinua := .T.
						ElseIf SA2->A2_I_CLASS == "F" .AND. Empty(Alltrim(_cFornec)) 
							_cFornec := SA2->A2_COD
							_cLoja   := SA2->A2_LOJA
							_cNomFor := SA2->A2_NREDUZ

							lContinua := .T.
						EndIf
					EndIf
					SA2->(Dbskip())
				EndDo
				If !lContinua
					_cErro += " Para o Lan�amento numero "+oJsoAux:TITULOS[_ni]:NUMERO+" o Fornecedor "+oJsoAux:TITULOS[_ni]:CGC+" n�o esta ativo ou n�o � Classificado como F - Fornecedor, V - Vendedor ou J - Funcion�rio."
				EndIf
			Else
				//Valida Fornecedor
				DbSelectArea("SA2")
				DbSetOrder(17) //A2_FILIAL+A2_I_CPF
				If Dbseek(xFilial("SA2")+_cCPFCNPJ)
					Do While oJsoAux:TITULOS[_ni]:CGC == ALLTRIM(SA2->A2_I_CPF) .AND. SA2->(!EOF())
						If SA2->A2_MSBLQL <> '1' .AND. SA2->A2_I_CLASS $ "FVJ"
							If SA2->A2_I_CLASS == "J"
								_cFornec := SA2->A2_COD
								_cLoja   := SA2->A2_LOJA
								_cNomFor := SA2->A2_NREDUZ

								lContinua := .T.
								Exit
							ElseIf SA2->A2_I_CLASS == "V"
								_cFornec := SA2->A2_COD
								_cLoja   := SA2->A2_LOJA
								_cNomFor := SA2->A2_NREDUZ

								lContinua := .T.
							ElseIf SA2->A2_I_CLASS == "F" .AND. Empty(Alltrim(_cFornec)) 
								_cFornec := SA2->A2_COD
								_cLoja   := SA2->A2_LOJA
								_cNomFor := SA2->A2_NREDUZ

								lContinua := .T.
							EndIf
						EndIf

						SA2->(Dbskip())
					EndDo
					If !lContinua
						_cErro += " Para o Lan�amento numero "+oJsoAux:TITULOS[_ni]:NUMERO+" o Fornecedor "+oJsoAux:TITULOS[_ni]:CGC+" n�o esta ativo ou n�o � Classificado como F - Fornecedor, V - Vendedor ou J - Funcion�rio."
					EndIf
				Else
					lContinua := .F.
					_cErro += " Para o Lan�amento numero "+oJsoAux:TITULOS[_ni]:NUMERO+" o Fornecedor n�o foi encontrado."
				EndIf
			EndIf
			If lContinua
				If Len(_aParam) > 0
					_cBanco      := _aParam[1]
					_cAgencia    := _aParam[2]
					_cConta      := _aParam[3]
					_cPNat       := _aParam[4]
					_cPContaCtb  := _aParam[5]
					_cPCentro    := _aParam[6]
					_cPHistorico := _aParam[7]
					_cPEmailWork := _aParam[8]
					_lPNaoRateia := _aParam[9] 
					_lPNaoIntFin := _aParam[10] 
					_cEmaiFin	 := _aParam[11]
				Else
					_cBanco      := ""
					_cAgencia    := ""
					_cConta      := ""
					_cPNat       := ""
					_cPContaCtb  := ""
					_cPCentro    := ""
					_cPHistorico := ""
					_cPEmailWork := ""
					_lPNaoRateia := .F.
					_lPNaoIntFin := .F.
					_cEmaiFin	 := ""

					lContinua := .F.
					_cErro += " Parametros nao inclu�dos para filial "+_cFilialJso+"."
				EndIf

				If !Empty(Alltrim(_cPNat))
					_cNatureza := _cPNat
				EndIf

				If !Empty(Alltrim(_cPContaCtb))
					_cContCont := _cPContaCtb
				EndIf

				If !Empty(Alltrim(_cPCentro))
					_cCentCus := _cPCentro
				EndIf

				If !Empty(Alltrim(_cPHistorico))
					_cHist := _cPHistorico
				EndIf
			EndIf
			
			If _lAFIN036
				_lPNaoIntFin := .F.
			EndIf

			//Monta array de Dados da tabela Z26
			aAdd(_aAuxZ26, {"Z26_IDINTE", _cIDInte								, Nil})
			aAdd(_aAuxZ26, {"Z26_FILIAL", _cFilialJso							, Nil})
			aAdd(_aAuxZ26, {"Z26_NUM"	, _cNumero								, Nil})
			aAdd(_aAuxZ26, {"Z26_PREFIX", _cPrefixo							, Nil})
			aAdd(_aAuxZ26, {"Z26_TIPO"	, _cTipo									, Nil})
			aAdd(_aAuxZ26, {"Z26_EMISSA", STOD(oJsoAux:TITULOS[_ni]:EMISSAO)	, Nil})
			aAdd(_aAuxZ26, {"Z26_VENCTO", _dVencto	, Nil})
			aAdd(_aAuxZ26, {"Z26_CGC"	, oJsoAux:TITULOS[_ni]:CGC			, Nil})
			aAdd(_aAuxZ26, {"Z26_FORNEC", _cFornec								, Nil})
			aAdd(_aAuxZ26, {"Z26_LOJA"  , _cLoja								, Nil})
			aAdd(_aAuxZ26, {"Z26_NOMFOR", _cNomFor								, Nil})			
			aAdd(_aAuxZ26, {"Z26_VALOR"	, _nValor							, Nil})
			aAdd(_aAuxZ26, {"Z26_PAYLOA", cBody									, Nil})
			aAdd(_aAuxZ26, {"Z26_DATA"	, _dDate									, Nil})
			aAdd(_aAuxZ26, {"Z26_HORA"	, _cTime									, Nil})
			aAdd(_aAuxZ26, {"Z26_NATURE", _cNatureza							, Nil})
			aAdd(_aAuxZ26, {"Z26_CENTCU", _cCentCus							, Nil})
			aAdd(_aAuxZ26, {"Z26_CONTAC", _cContCont							, Nil})
			aAdd(_aAuxZ26, {"Z26_MULTIN", _cMultiNat							, Nil})
			aAdd(_aAuxZ26, {"Z26_ORIGEM", Iif(_lRest,"P","T")				, Nil})
			aAdd(_aAuxZ26, {"Z26_STATUS", "N"									, Nil})
			aAdd(_aAuxZ26, {"Z26_PREORI", _cPreOri								, Nil})

			_aVetZ27 := {}
			_aVetZ28 := {}
			_aRatSEV := {}
			
			If oJsoAux:TITULOS[_ni]:MULTINAT == "1" .AND. !_lPNaorateia

				For _nZ := 1 to Len(oJsoAux:TITULOS[_ni]:RATNAT)
					
					_nValorRat := 0
					_nPerRat   := 0
					_nValExc   := 0
					_aAuxSEV   := {}
					_aAuxZ27   := {}

					_cSEV_Nat  := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ], "NATUREZA"),oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:NATUREZA,"")
					_nValorRat := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ], "VALORRAT"),oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:VALORRAT,0)
					//_nValorRat := Iif(_nValorRat = 0,0,_nValorRat/1000)
					_nPerRat   := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ], "PERRAT"), oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:PERRAT,0)
					_nPerRat   := Iif(_nPerRat = 0,0,_nPerRat/1000)
					_cRatCC    := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ], "RATCC"),oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:RATCC,"")
					_nValExc   := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ], "VALEXC"),oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:VALEXC,0)
					_nTotExc   += _nValExc

					aAdd(_aAuxZ27, {"Z27_IDINTE", _cIDINTE		, Nil})
					aAdd(_aAuxZ27, {"Z27_FILIAL", _cFilialJso	, Nil})
					aAdd(_aAuxZ27, {"Z27_NUM"	, _cNumero		, Nil})
					aAdd(_aAuxZ27, {"Z27_PREFIX", _cPrefixo		, Nil})
					aAdd(_aAuxZ27, {"Z27_TIPO"	, _cTipo		, Nil})
					aAdd(_aAuxZ27, {"Z27_NATURE", _cSEV_Nat		, Nil})
					aAdd(_aAuxZ27, {"Z27_VALORR", _nValorRat	, Nil})
					aAdd(_aAuxZ27, {"Z27_PERRAT", _nPerRat		, Nil})
					aAdd(_aAuxZ27, {"Z27_RATCC" , _cRatCC		, Nil})
					aAdd(_aAuxZ27, {"Z27_VALEXC", _nValExc		, Nil})

					If _cPrefixo == "CVI" .AND. _cSEV_Nat $ _cNatDevol
						_nValorDev += _nValorRat
					Else
						_nValorCVI += _nValorRat
						aadd(_aAuxSEV, {"EV_NATUREZ", _cSEV_Nat		, Nil})
						aadd(_aAuxSEV, {"EV_VALOR" 	, _nValorRat 	, Nil})//valor do rateio na natureza
						aadd(_aAuxSEV, {"EV_PERC" 	, _nPerRat		, Nil})//percentual do rateio na natureza				
						aadd(_aAuxSEV, {"EV_RATEICC", _cRatCC		, Nil})//indicando que h� rateio por centro de custo
					EndIf

					_aRatSEZ := {}
					_aAuxSEZ := {}

					If _cRatCC == "1"
						_cCentroRat := ""
						For _nY := 1 to len(oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:ARATCC)

							_aAuxSEZ := {}
							_aAuxZ28 := {}

							_cCentro   := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:ARATCC[_nY], "CC"),oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:ARATCC[_nY]:CC,"")	
							_nPerRatCC := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:ARATCC[_nY], "PERRAT"),oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:ARATCC[_nY]:PERRAT,0)
							_nPerRatCC := Iif(Valtype(_nPerRatCC)=="N",_nPerRatCC,0)
							_nPerRatCC := Iif(_nPerRatCC = 0,0,_nPerRatCC/1000)
							_nVrRatCC  := Iif(AttIsMemberOf(oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:ARATCC[_nY], "VALORRAT"),oJsoAux:TITULOS[_ni]:RATNAT[_nZ]:ARATCC[_nY]:VALORRAT,0)
							//_nVrRatCC := Iif(_nVrRatCC = 0,0,_nVrRatCC/1000)

							aAdd(_aAuxZ28, {"Z28_IDINTE", _cIDINTE										, Nil})
							aAdd(_aAuxZ28, {"Z28_FILIAL", _cFilialJso									, Nil})
							aAdd(_aAuxZ28, {"Z28_NUM"	, _cNumero										, Nil})
							aAdd(_aAuxZ28, {"Z28_PREFIX", _cPrefixo										, Nil})
							aAdd(_aAuxZ28, {"Z28_TIPO"	, _cTipo										, Nil})
							aAdd(_aAuxZ28, {"Z28_NATURE", Iif(Empty(Alltrim(_cPNat)),_cSEV_Nat,_cPNat)	, Nil})
							aAdd(_aAuxZ28, {"Z28_CC"	, _cCentro										, Nil})
							aAdd(_aAuxZ28, {"Z28_PERRAT", _nPerRatCC									, Nil})
							aAdd(_aAuxZ28, {"Z28_VALORR", _nVrRatCC										, Nil})
							
							If !(_cPrefixo == "CVI" .AND. _cSEV_Nat $ _cNatDevol)
								If _cCentro $ _cCentroRat
									If Len(_aRatSEZ) > 0
										For _nRatSEZ := 1 To Len(_aRatSEZ)
											If _aRatSEZ[_nRatSEZ][2][2] == _cCentro
												_aRatSEZ[_nRatSEZ][4][2] += _nVrRatCC
												_aRatSEZ[_nRatSEZ][3][2] := _aRatSEZ[_nRatSEZ][4][2] * 100 / _nValorRat
												Exit
											EndIf
										Next
									EndIf
								Else
									aadd(_aAuxSEZ ,{"EZ_CONTA"	, _cContCont , Nil})//conta cont�bil na natureza                
									aadd(_aAuxSEZ, {"EZ_CCUSTO" , _cCentro   , Nil})	//centro de custo na natureza                
									aadd(_aAuxSEZ, {"EZ_PERC"	, _nPerRatCC , Nil})
									aadd(_aAuxSEZ, {"EZ_VALOR"	, _nVrRatCC	 , Nil})
								EndIf
								_cCentroRat += Iif(Empty(Alltrim(_cCentroRat)),"",";") + _cCentro
							EndIf
							
							aadd(_aVetZ28,_aAuxZ28)

							If Len(_aAuxSEZ) > 0
								aadd(_aRatSEZ,_aAuxSEZ)
							EndIf
						Next

						If Len(_aRatSEZ) > 0
							aadd(_aAuxSEV,{"AUTRATEICC" , _aRatSEZ, Nil })
							aAdd(_aRatSEV,_aAuxSEV)
						EndIf

					EndIf

					aadd(_aVetZ27,_aAuxZ27)

					If Len(_aAuxSEV) > 0 
						//aAdd(_aRatSEV,_aAuxSEV)
					EndIf
					
				Next


			EndIf
			
			If _nTotExc > 0
				lContinua := .F.
				//Valida Funcion�rio
				DbSelectArea("SRA")
				DbSetOrder(20)
				If Dbseek(_cCPFCNPJ)
					Do While SRA->RA_CIC == _cCPFCNPJ .And. SRA->(!EOF())
						If SRA->RA_DEMISSA == ' '
							lContinua := .T.
							Exit
						EndIf
						SRA->(Dbskip())
					EndDo

					If lContinua
						_cCCusto := SRA->RA_CC
						_cMatric := SRA->RA_MAT
					Else
						_cErro += " N�o encontrado o cadastro do funcion�rio " +_cNomFor+" CPF:"+_cCPFCNPJ
					EndIf
				Else
					_cErro += " N�o encontrado o cadastro do funcion�rio " +_cNomFor+" CPF:"+_cCPFCNPJ
				EndIf
			EndIf

			//Grava Tabelas Z26,Z27 e Z28
			MFIN021GPL(_aAuxZ26,_aVetZ27,_aVetZ28)

			//Valida Filial habilitada para Rateio
			If lContinua
				If _cMultiNat == "2" .And. !_FilialHab
					lContinua := .F.
					_cErro    += " Para o Lan�amento numero "+oJsoAux:TITULOS[_ni]:NUMERO+" a Filial n�o esta habilitada para Rateio por Natureza. Par�metro MV_MULNATP."
				Else
					lContinua := .T.
				EndIf
			EndIf

			//Valida Prefixo
			If lContinua .AND. !(_cPrefixo == "CVI" .OR. _cPrefixo == "RVI" .OR. _cPrefixo == "AVI")
				lContinua := .F.
				_cErro += " Prefixo "+_cPrefixo+" invalido para inclusao."
			EndIf

			//Monta array de Dados da tabela Z29
			aAdd(_aAuxZ29, {"Z29_FILIAL"  , _cFilialJso								, Nil})
			aAdd(_aAuxZ29, {"Z29_PREFIX"  , _cPrefixo        						, Nil})
			aAdd(_aAuxZ29, {"Z29_NUM"	  , _cNumero								, Nil})
			aAdd(_aAuxZ29, {"Z29_PARCEL"  , _cParcela								, Nil})
			aAdd(_aAuxZ29, {"Z29_TIPO"	  , _cTipo									, Nil})
			aAdd(_aAuxZ29, {"Z29_CGC"	  , oJsoAux:TITULOS[_ni]:CGC				, Nil})
			aAdd(_aAuxZ29, {"Z29_FORNEC"  , _cFornec								, Nil})
			aAdd(_aAuxZ29, {"Z29_LOJA"    , _cLoja									, Nil})
			aAdd(_aAuxZ29, {"Z29_NOMFOR"  , _cNomFor								, Nil})
			aAdd(_aAuxZ29, {"Z29_EMISSA"  , STOD(oJsoAux:TITULOS[_ni]:EMISSAO)		, Nil})
			aAdd(_aAuxZ29, {"Z29_VENCTO"  , _dVencto                     			, Nil})
			aAdd(_aAuxZ29, {"Z29_VALOR"   , _nValor   								, Nil})
			aAdd(_aAuxZ29, {"Z29_CONTAD"  , _cContCont                        		, Nil})
			aAdd(_aAuxZ29, {"Z29_HISTOR"  , _cHist                        			, Nil})
			aAdd(_aAuxZ29, {"Z29_MULTIN"  , _cMultiNat								, Nil})
			aAdd(_aAuxZ29, {"Z29_NATURE"  , _cNatureza								, Nil})
			aAdd(_aAuxZ29, {"Z29_IDINTE"  , _cIDInte								, Nil})
			aAdd(_aAuxZ29, {"Z29_STATUS"  , "N"										, Nil})
			aAdd(_aAuxZ29, {"Z29_VALEXC"  , _nTotExc  								, Nil})

			If lContinua .AND. !_lPNaoIntFin

				If _cPrefixo == "CVI"
					If _nValorDev > 0
						_nValor := _nValorCVI
					EndIf
				EndIf

				//Monta array de Dados da tabela SE2
				aAdd(aVetSE2, {"E2_FILIAL"	, _cFilialJso							, Nil})
				aAdd(aVetSE2, {"E2_NUM"		, _cNumero								, Nil})
				aAdd(aVetSE2, {"E2_PREFIXO"	, _cPrefixo        						, Nil})
				aAdd(aVetSE2, {"E2_PARCELA"	, _cParcela								, Nil})
				aAdd(aVetSE2, {"E2_TIPO"	, _cTipo								, Nil})
				aAdd(aVetSE2, {"E2_FORNECE" , _cFornec								, Nil})
				aAdd(aVetSE2, {"E2_LOJA"    , _cLoja								, Nil})
				aAdd(aVetSE2, {"E2_NOMFOR"  , _cNomFor								, Nil})
				aAdd(aVetSE2, {"E2_EMISSAO" , STOD(oJsoAux:TITULOS[_ni]:EMISSAO)	, Nil})
				aAdd(aVetSE2, {"E2_VENCTO"  , _dVencto	, Nil})
				aAdd(aVetSE2, {"E2_VENCREA" , _dVencto	, Nil})
				aAdd(aVetSE2, {"E2_VALOR"   , _nValor   							, Nil})
				aAdd(aVetSE2, {"E2_CONTAD"  , _cContCont                        	, Nil})
				aAdd(aVetSE2, {"E2_HIST"    , _cHist                        		, Nil})
				aAdd(aVetSE2, {"E2_MOEDA"   , 1      								, Nil})
				aAdd(aVetSE2, {"E2_MULTNAT" , _cMultiNat							, Nil})
				aAdd(aVetSE2, {"E2_ORIGEM"  , "MFIN021"								, Nil})
				aAdd(aVetSE2, {"E2_NATUREZ" , _cNatureza							, Nil})
				aAdd(aVetSE2, {"E2_CCUSTO"  , _cCentCus								, Nil})

				If oJsoAux:TITULOS[_ni]:PREFIXO == "AVI"
					aAdd(aVetSE2, {"AUTBANCO"   , _cBanco								, Nil})
					aAdd(aVetSE2, {"AUTAGENCIA" , _cAgencia								, Nil})
					aAdd(aVetSE2, {"AUTCONTA"   , _cConta        						, Nil})
				EndIf

				If _nValorDEV > 0
					For _nW := 1 To Len(_aRatSEV)
						_aRatSEV[_nW][3][2]:= _aRatSEV[_nW][3][2] * 100 / _nValor 
					Next
				EndIf
 
				If !_lPNaorateia
					If Len(_aRatSEV) > 0
						aAdd(aVetSE2,{"AUTRATEEV", _aRatSEV, Nil})
					EndIf
				EndIf

				If _cPrefixo == "CVI"
					Begin Transaction
						DbSelectArea("SE2")
						DbSetOrder(1)
						If Dbseek(_cFilialJso+"AVI"+_cNumero+_cParcela+"PA "+_cFornec+_cLoja)
							If (_nValor + _nValorDEV) >= SE2->E2_SALDO
								
								If _nValor < SE2->E2_SALDO  
									nSldComp := _nValor
								ElseIf _nValor > SE2->E2_SALDO  
									nSldComp := SE2->E2_SALDO
								Else
									nSldComp := 0
								EndIf
								
								Aadd(aPA_NDF, SE2->(Recno()))
								
								lMsErroAuto := .F.

								MFIN021SE2(aVetSE2,@_cErro,.F.,_aAuxZ29)
								
								If lMsErroAuto
									lContinua := .F.
									DisarmTransaction()
								Else
									_nRecnoCVI    := SE2->(Recno())

									aAdd(aNF, _nRecnoCVI)

									Pergunte("AFI340", .F.)
									lContabiliza := MV_PAR11 == 1
									lAglutina 	 := MV_PAR08 == 1
									lDigita 	 := MV_PAR09 == 1
									aContabil    := {lContabiliza,lAglutina,lDigita}

									lRet := FinCmpAut(aNF, aPA_NDF, aContabil, bBlock, aEstorno, nSldComp, dDatabase, nTaxaPA ,nTaxaNF, nHdl, nOperacao, aRecSE5, aNDFDados, lHelp)

									If !lRet
										lContinua := .F.
										_cErro += "Ocorreu um erro no processo de compensacao"
										DisarmTransaction()
									Else
										lContinua := .T.
									EndIf
								EndIf

							Else
								lContinua := .F.
								_cErro += "Valor da Compensacao menor que o Saldo do Adiantamento."
							EndIf
						Else
							lContinua := .F.
							_cErro += "Registro de Compensacao sem Adiantamento."
						EndIf
						
						/*
						//Inicia o Processo de Devolucao do AVI se Houver
						If lContinua .AND. _nValorDEV > 0 
							
							//Monta array de Dados da tabela SE2
							_aBaixa := {}
							
							aAdd(_aBaixa, {"E2_FILIAL"	, _cFilialJso							, Nil})
							aAdd(_aBaixa, {"E2_NUM"		, _cNumero								, Nil})
							aAdd(_aBaixa, {"E2_PREFIXO"	, "AVI"        						    , Nil})
							aAdd(_aBaixa, {"E2_PARCELA"	, _cParcela								, Nil})
							aAdd(_aBaixa, {"E2_TIPO"	, "PA "								    , Nil})
							aAdd(_aBaixa, {"E2_FORNECE" , _cFornec								, Nil})
							aAdd(_aBaixa, {"E2_LOJA"    , _cLoja								, Nil})
							
							AADD(_aBaixa, {"AUTMOTBX" 		, "NOR" 	, Nil})
							AADD(_aBaixa, {"AUTBANCO" 		, _cBanco 	, Nil})
							AADD(_aBaixa, {"AUTAGENCIA" 	, _cAgencia , Nil})
							AADD(_aBaixa, {"AUTCONTA" 		, _cConta 	, Nil})
							AADD(_aBaixa, {"AUTDTBAIXA" 	, dDataBase , Nil})
							AADD(_aBaixa, {"AUTDTCREDITO"	, dDataBase , Nil})
							AADD(_aBaixa, {"AUTHIST" 		, "Baixa resultante de devolucao via Paytrack" , Nil})
							AADD(_aBaixa, {"AUTVLRPG" 		, _nValorDev , Nil})
							
							lMsErroAuto := .F.

							//ACESSAPERG("FIN080", .F.)
							Pergunte("FIN080", .F.)
										
							MSEXECAUTO({|x,y| FINA080(x,y)}, _aBaixa, 3)

							If lMsErroAuto
								lContinua := .F.
								//MOSTRAERRO()
								_cErro += "Falha na Baixa de Devolucao do Titulo " + _cNumero
								_cErro += " MSExecAuto: [ "+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MFIN021.LOG")+" ]"
								DisarmTransaction()
							EndIf
						EndIf
						*/
						If lContinua
							MFIN021ST(lContinua,_cOper) //Atualiza Status Z26 e Z29
						EndIf
						
					End Transaction
				Else
					lContinua := MFIN021SE2(aVetSE2,@_cErro,.T.,_aAuxZ29)
					MFIN021ST(lContinua,_cOper)
				EndIf
			
			Else

				MFIN021Z29(_aAuxZ29,@_cErro,.T.)
				If !_lPNaoIntFin
					MFIN021ST(lContinua,_cOper)
				EndIf

			EndIf

			If lContinua
				_cJson += Iif(Empty(Alltrim(_cJson)),"", ",")+"{"
				_cJson += '"retorno":"200",'
				_cJson += '"mensagem":"dados incluidos com sucesso"'
				_cJson += "}"
			Else
				_cJson += Iif(Empty(Alltrim(_cJson)),"", ",")+"{"
				_cJson += '"retorno":"500",'
				_cJson += '"mensagem":"Falha da inclusao dos dados.",'
				_cJson += '"erro":"'+_cErro+'"'
				_cJson += "}"
			EndIf 

			Z26->(DbGoTo(_nRecnoZ26))
			Z26->(RecLock("Z26",.F.))
			Z26->Z26_RETORN := _cJson
			Z26->(MsUnlock())


			Aadd(_aSizes,"05")
			Aadd(_aCab,"Filial")
			Aadd(_aDados,_cFilialJso)

			Aadd(_aSizes,"10")
			Aadd(_aCab,"Prefixo")
			Aadd(_aDados,_cPrefixo)

			Aadd(_aSizes,"10")
			Aadd(_aCab,"Titulo")
			Aadd(_aDados,_cNumero)

			Aadd(_aSizes,"10")
			Aadd(_aCab,"Emiss�o")
			Aadd(_aDados,DTOC(STOD(oJsoAux:TITULOS[_ni]:EMISSAO)))

			Aadd(_aSizes,"10")
			Aadd(_aCab,"Fornecedor")
			Aadd(_aDados,_cFornec + " - " + _cLoja)

			Aadd(_aSizes,"20")
			Aadd(_aCab,"Nome Fornecedor")
			Aadd(_aDados,_cNomFor)

			Aadd(_aSizes,"10")
			Aadd(_aCab,"Vencimento")
			Aadd(_aDados,DTOC(STOD(oJsoAux:TITULOS[_ni]:VENCIMENTO)))

			Aadd(_aSizes,Iif(_nValorDEV > 0,"13","25"))
			Aadd(_aCab,"Valor")
			Aadd(_aDados,ALLTRIM(Transform( _nValor ,"@E 999,999,999,999,999.99")))

			If _nValorDEV > 0 
				Aadd(_aSizes,"12")
				Aadd(_aCab,"Valor de Devolu��o")
				Aadd(_aDados,ALLTRIM(Transform( _nValorDEV ,"@E 999,999,999,999,999.99")))
			EndIf

			If lContinua .And. !Empty(Alltrim(_cPEmailWork))
				MFIN021E(_cPEmailWork,_aDados,_aCab,_aSizes,_cOper)
			EndIf

			If ( _cPrefixo == "CVI" .OR. _cPrefixo == "AVI" ) .AND. !Empty(Alltrim(_cEmaiFin))
				MFIN021E(_cEmaiFin,_aDados,_aCab,_aSizes,_cOper)
			EndIf
		Next
	ElseIf _cOper == "E" .OR. _cOper == "X" //_cOper == "E" => Opera��o de Exclus�o da Tabela 29 e _cOper == "X" e
		If !_lRest

			lContinua := .F.

			If _cOper == "E"

				If Z29->Z29_STATUS $ "I;R" 
					DbSelectArea("Z26")
					DbSetOrder(1)
					If DBSeek(Z29->Z29_IDINTE)
						lContinua := .T.
						_nRecnoZ29 := Z29->(Recno())
						_cChave    := Z29->Z29_FILIAL+Z29->Z29_PREFIX+Z29->Z29_NUM+Z29->Z29_PARCEL+Z29->Z29_TIPO+Z29->Z29_FORNEC+Z29->Z29_LOJA
					Else
						_cErro := "N�o encontrado registro de integra��o."
						lContinua := .F.
					EndIf
				Else
					_cErro := "Com este status n�o ser� permitida a sua exclus�o."
					lContinua := .F.
				EndIf

			ElseIf _cOper == "X"
				If !Z26->Z26_EXCLUI .AND. (Z26->Z26_STATUS == 'I' .OR. Z26->Z26_STATUS == 'R')
					lContinua := .T.
					_cChave    := Z26->Z26_FILIAL+Z26->Z26_PREFIX+Z26->Z26_NUM+Z26->Z26_PARCEL+Z26->Z26_TIPO+Z26->Z26_FORNEC+Z26->Z26_LOJA
				Else
					If Z26_EXCLUI
						_cErro := "Registro j� excluido anteriormente!."
					Else
						_cErro := "Com este status n�o ser� permitida a sua exclus�o."
					EndIf
					lContinua := .F.
				EndIf
			EndIf

			If lContinua 
				_nRecnoZ26 := Z26->(Recno())

				DbSelectArea("SE2")
				DbSetOrder(1)
				If DBSeek(_cChave)

					aAdd(aVetSE2, {"E2_FILIAL"  ,SE2->E2_FILIAL         , Nil})
					aAdd(aVetSE2, {"E2_PREFIXO" ,SE2->E2_PREFIXO        , Nil})
					aAdd(aVetSE2, {"E2_NUM"	    ,SE2->E2_NUM     	    , Nil})
					aAdd(aVetSE2, {"E2_TIPO"	,SE2->E2_TIPO    	    , Nil})
					aAdd(aVetSE2, {"E2_FORNECE" ,SE2->E2_FORNECE       	, Nil})
					aAdd(aVetSE2, {"E2_LOJA"	,SE2->E2_LOJA           , Nil})
					aAdd(aVetSE2, {"E2_ORIGEM"  ,SE2->E2_ORIGEM       	, Nil}) 
					aAdd(aVetSE2, {"E2_NATUREZ" ,SE2->E2_NATUREZ       	, Nil}) 

					//====================================================================================================
					// Altera o modulo para Financeiro, senao o SigaAuto nao executa.
					//====================================================================================================
					nModulo := 6
					cModulo := "FIN"
											
					Begin Transaction
						
						lMsErroAuto := .F.
						MSExecAuto({|x,y,z| FINA050(x,y,z)}, aVetSE2,,5)  //Exclus�o

						If lMsErroAuto
							lContinua := .F. 
							//MostraErro()
							_cErro += "MSExecAuto: [ "+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MFIN021.LOG")+" ]"
							DisarmTransaction()
						Else
							lContinua := .T.

							DbSelectArea("Z26")
							Z26->(DBGoTo(_nRecnoZ26))
							If RecLock("Z26", .F.)
								Z26->Z26_EXCLUI := .T.
								Z26->(MsUnlock())
							Else
								lContinua := .F. 
								_cErro += "Registro "+Alltrim(Str(_nRecnoZ26))+ " Locado"
								DisarmTransaction()
							EndIf

							_cIDInte   := MFIN021GNU()
							
							_dDate     := Date()
							_cTime     := Time()
							
							//Monta array de Dados da tabela Z26
							aAdd(_aAuxZ26, {"Z26_IDINTE", _cIDInte				, Nil})
							aAdd(_aAuxZ26, {"Z26_FILIAL", Z26->Z26_FILIAL       , Nil})
							aAdd(_aAuxZ26, {"Z26_NUM"	, Z26->Z26_NUM			, Nil})
							aAdd(_aAuxZ26, {"Z26_PREFIX", Z26->Z26_PREFIX		, Nil})
							aAdd(_aAuxZ26, {"Z26_TIPO"	, Z26->Z26_TIPO			, Nil})
							aAdd(_aAuxZ26, {"Z26_EMISSA", Z26->Z26_EMISSAO		, Nil})
							aAdd(_aAuxZ26, {"Z26_VENCTO", Z26->Z26_VENCTO      	, Nil})
							aAdd(_aAuxZ26, {"Z26_VALOR"	, Z26->Z26_VALOR		, Nil})
							aAdd(_aAuxZ26, {"Z26_CGC"	, Z26->Z26_CGC			, Nil})
							aAdd(_aAuxZ26, {"Z26_FORNEC", Z26->Z26_FORNEC		, Nil})
							aAdd(_aAuxZ26, {"Z26_LOJA"  , Z26->Z26_LOJA			, Nil})
							aAdd(_aAuxZ26, {"Z26_NOMFOR", Z26->Z26_NOMFOR		, Nil})	
							aAdd(_aAuxZ26, {"Z26_DATA"	, _dDate				, Nil})
							aAdd(_aAuxZ26, {"Z26_HORA"	, _cTime				, Nil})
							aAdd(_aAuxZ26, {"Z26_NATURE", Z26->Z26_NATURE		, Nil})
							aAdd(_aAuxZ26, {"Z26_MULTIN", Z26->Z26_MULTIN       , Nil})
							aAdd(_aAuxZ26, {"Z26_ORIGEM", "T" /* Totvs Protheus */   , Nil})
							aAdd(_aAuxZ26, {"Z26_STATUS", "E" /* Exclus�o */    , Nil})
							aAdd(_aAuxZ26, {"Z26_PROCES", .T.           		, Nil})
							aAdd(_aAuxZ26, {"Z26_PREORI", Z26->Z26_PREFIX		, Nil})
							aAdd(_aAuxZ26, {"Z26_IDORIG", Z26->Z26_IDINTE		, Nil})
							aAdd(_aAuxZ26, {"Z26_PAYLOA", Z26->Z26_PAYLOA		, Nil})

							MFIN021GPL(_aAuxZ26)

							If _cOper == "E"
								DbSelectArea("Z29")
								Z29->(DBGoTo(_nRecnoZ29))
								RecLock("Z29", .F.)
								Z29->Z29_IDINTE := _cIDInte
								Z29->Z29_STATUS := "E"
								Z29->(MsUnlock())
							EndIf

						EndIf

					End Transaction
				Else
					lContinua := .F.
					_cErro += " Titulo n�o encontrado no Contas a Pagar para exclus�o!"
				EndIf
			Else
				_cErro += " N�o encontrado registro de payload para exclus�o na tabela Z26!"
			EndIf
		EndIf
	ElseIf _cOper == "Z"  //Tratamento para Exclus�o da Compensa��o
			
			_nRecnoZ26 := Z26->(Recno())
			_cChave    := Z26->Z26_FILIAL+Z26->Z26_PREFIX+Z26->Z26_NUM+Z26->Z26_PARCEL+Z26->Z26_TIPO+Z26->Z26_FORNEC+Z26->Z26_LOJA

			DbSelectArea("SE2")
			DbSetOrder(1)
			If DBSeek(_cChave)
				_nRecnoCVI    := SE2->(Recno())
			EndIf

			_nRecnoZ29 := Z29->(Recno())
			_cChave    := Z29->Z29_FILIAL+Z29->Z29_PREFIX+Z29->Z29_NUM+Z29->Z29_PARCEL+Z29->Z29_TIPO+Z29->Z29_FORNEC+Z29->Z29_LOJA
			_cPreOri   := Z29->Z29_PREFIX

			DbSelectArea("SE2")
			DbSetOrder(1)
			If DBSeek(_cChave)
				_nRecnoAVI    := SE2->(Recno())
			EndIf

			//====================================================================================================
			// Altera o modulo para Financeiro, senao o SigaAuto nao executa.
			//====================================================================================================
			nModulo := 6
			cModulo := "FIN"
			//====================================================================================================

			nOperacao := 3 //Exclusao
									
			Begin Transaction

				Aadd(aPA_NDF, _nRecnoAVI)
				aAdd(aNF, _nRecnoCVI)

				Pergunte("AFI340", .F.)
				lContabiliza := MV_PAR11 == 1
				lAglutina 	 := MV_PAR08 == 1
				lDigita 	 := MV_PAR09 == 1
				aContabil    := {lContabiliza,lAglutina,lDigita}

				lRet := FinCmpAut(aNF, aPA_NDF, aContabil, bBlock, {{_nRecnoAVI}}/*aEstorno*/, nSldComp, dDatabase, nTaxaPA ,nTaxaNF, nHdl, nOperacao, aRecSE5, aNDFDados, lHelp)

				If !lRet
					lContinua := .F.
					_cErro += "Ocorreu um erro no processo de exclus�o da compensa��o"
					DisarmTransaction()
				Else
					lContinua := .T.
					//MFIN021ST(lContinua,_cOper) //Atualiza Status Z26 e Z29
				EndIf
			
				If lContinua

					_cIDInte   := MFIN021GNU()
					
					_dDate     := Date()
					_cTime     := Time()
					
					//Monta array de Dados da tabela Z26
					aAdd(_aAuxZ26, {"Z26_IDINTE", _cIDInte								, Nil})
					aAdd(_aAuxZ26, {"Z26_FILIAL", Z26->Z26_FILIAL   					, Nil})
					aAdd(_aAuxZ26, {"Z26_NUM"	, Z26->Z26_NUM							, Nil})
					aAdd(_aAuxZ26, {"Z26_PREFIX", Z26->Z26_PREFIX						, Nil})
					aAdd(_aAuxZ26, {"Z26_TIPO"	, Z26->Z26_TIPO							, Nil})
					aAdd(_aAuxZ26, {"Z26_EMISSA", Z26->Z26_EMISSAO                  	, Nil})
					aAdd(_aAuxZ26, {"Z26_VENCTO", Z26->Z26_VENCTO                   	, Nil})
					aAdd(_aAuxZ26, {"Z26_VALOR"	, Z26->Z26_VALOR					    , Nil})
					aAdd(_aAuxZ26, {"Z26_CGC"	, Z26->Z26_CGC				            , Nil})
					aAdd(_aAuxZ26, {"Z26_FORNEC", Z26->Z26_FORNEC						, Nil})
					aAdd(_aAuxZ26, {"Z26_LOJA"  , Z26->Z26_LOJA							, Nil})
					aAdd(_aAuxZ26, {"Z26_NOMFOR", Z26->Z26_NOMFOR						, Nil})	
					aAdd(_aAuxZ26, {"Z26_DATA"	, _dDate								, Nil})
					aAdd(_aAuxZ26, {"Z26_HORA"	, _cTime								, Nil})
					aAdd(_aAuxZ26, {"Z26_NATURE", Z26->Z26_NATURE						, Nil})
					aAdd(_aAuxZ26, {"Z26_MULTIN", Z26->Z26_MULTIN		                , Nil})
					aAdd(_aAuxZ26, {"Z26_ORIGEM", "T"           		                , Nil})
					aAdd(_aAuxZ26, {"Z26_STATUS", "E"           		                , Nil})
					aAdd(_aAuxZ26, {"Z26_PROCES", .T.           		                , Nil})
					aAdd(_aAuxZ26, {"Z26_PREORI", _cPreOri								, Nil})

					MFIN021GPL(_aAuxZ26)

				EndIf

			End Transaction
			

	EndIf

Return(lContinua)

/*
===============================================================================================================================
Programa----------: MFIN021E
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Envia de Email de integra��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
Static Function MFIN021E(_cEmail As Char,_aDados As Array,_aCab As Array,_aSizes As Array,_cOper As Char) As Logical
	Local _cMsgEml   := "" As Char
	Local _cTit      := "INTEGRA��O DE PAGAMENTOS PAYTRACK" As Char
	Local _cTit2     := "Foi "+Iif(_cOper == "E","exclu�do",Iif(_cOper == "R","reintegrado","inclu�do"))+" no Protheus o "+Iif(_aDados[2]="AVI","Adiantamento",Iif(_aDados[2]="CVI","Compensa��o","Reembolso"))+" de Viagem abaixo" As Char
	Local _cGetAssun := Iif(_cOper == "E","Exclus�o",Iif(_cOper == "R","Reintegra��o","Inclus�o"))+" de "+Iif(_aDados[2]="AVI","Adiantamento",Iif(_aDados[2]="CVI","Compensa��o","Reembolso"))+" de Viagem via Paytrack" As Char
	Local _aConfig   := {} As Array
	Local _cTo 	     := "" As Char
	Local _cCC 	     := "" As Char
	Local _cGetAnx   := "" As Char
	Local _cCCO      := "" As Char
	Local _cGetLista := "" As Char
	Local _cEmlLog   := "" As Char
	Local _lReturn   := .F. As Logical
	Local _ni        := 0 As Numeric

	//Logo Italac
	_cMsgEml := '<html>'
	_cMsgEml += '<head><title>'+_cTit+'</title></head>'
	_cMsgEml += '<body>'
	_cMsgEml += '<style type="text/css"><!--'
	_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
	_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
	_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
	_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:10px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
	_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:10px; V-align:middle; margin-right: 13px; margin-left: 15px; background-color: #FFFFFF; }'
	_cMsgEml += '--></style>'
	_cMsgEml += '<center>'
	_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
	_cMsgEml += '<br>'

	//Celula Azul para T�tulo
	_cMsgEml += '<table class="bordasimples" width="800">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '	     <td class="titulos"><center>'+_cTit2+'</center></td>'
	_cMsgEml += '	 </tr>'
	_cMsgEml += '</table>'
	_cMsgEml += '<br>'

	//Tabela de Dados
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1000">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '		<td align="left" colspan="'+ALLTRIM(STR(LEN(_aSizes)))+'" class="grupos"><b>'+_cGetAssun+'</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'

	For _ni := 1 To Len(_aCab)
		_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[_ni]+'%"><b>'+_aCab[_ni]+'</b></td>'
	Next
	_cMsgEml += '    </tr>'
	_cMsgEml += '    #LISTA#'
	_cMsgEml += '</table>'

	_cGetLista := ""
	
	_cGetLista += '    <tr>'
	For _ni := 1 To Len(_aCab)
		_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[_ni]+'%">'+_aDados[_ni]+'</td>'
	Next
	_cGetLista += '    </tr>'			

	_cMsgEml := STRTRAN(_cMsgEml,"#LISTA#",_cGetLista)

	//Rodap�
	_cMsgEml += '</center>'
	_cMsgEml += '<br>'
	_cMsgEml += '<br>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
	_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [MFIN021]</td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '</body>'
	_cMsgEml += '</html>'

	
	_aConfig := U_ITCFGEML('')
	_cTo 	 := Alltrim(_cEmail)
	_cCC 	 := ""
	_cGetAnx := ""
	_cCCO    := ""
	
	_lReturn := U_ITENVMAIL( ""  , _cTo    , _cCC, _cCCO, _cGetAssun, _cMsgEml  , _cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
	
Return(_lReturn)

/*
===============================================================================================================================
Programa----------: MFIN021GPL
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Grava��o das informa��es de Integrac�o (Tabela Z26,Z27 e Z28)
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
Static Function MFIN021GPL(_aAuxZ26 As Array,_aVetZ27 As Array,_aVetZ28 As Array) As Logical
	Local _ni := 0 As Numeric
	Local _nz := 0 As Numeric
	Local _lContinua := .F. As Logical

	Default _aAuxZ26 := {}
	Default _aVetZ27 := {} 
	Default _aVetZ28 := {} 

	//Begin Transaction
		
		Z26->(RecLock("Z26",.T.))
		For _ni := 1 To Len(_aAuxZ26)
			Z26->&(_aAuxZ26[_ni,1]) := _aAuxZ26[_ni,2]
		Next
		Z26->(MsUnLock())

		_nRecnoZ26 := Z26->(Recno())

		For _nz := 1 To Len(_aVetZ27)
			_aAuxZ27 := aClone(_aVetZ27[_nz])
			Z27->(RecLock("Z27",.T.))
			For _ni := 1 To Len(_aAuxZ27)
				Z27->&(_aAuxZ27[_ni,1]) := _aAuxZ27[_ni,2]
			Next
			Z27->(MsUnLock())
		Next

		For _nz := 1 To Len(_aVetZ28)
			_aAuxZ28 := aClone(_aVetZ28[_nz])
			Z28->(RecLock("Z28",.T.))
			For _ni := 1 To Len(_aAuxZ28)
				Z28->&(_aAuxZ28[_ni,1]) := _aAuxZ28[_ni,2]
			Next
			Z28->(MsUnLock())
		Next

		_lContinua := .T.

	//End Transaction

Return

/*
===============================================================================================================================
Programa----------: MFIN021Z29
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Grava��o do registro de Integrac�o (Tabela Z29)
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
Static Function MFIN021Z29(_aAuxZ29 As Array,_cErro As Char,_lBeginTra As Logical) As Logical
	Local _ni := 0 As Numeric
	Local _nPos := 0 As Numeric
	Local _cFilial := "" As Char
	Local _cPrefixo := "" As Char
	Local _cNumero := "" As Char
	Local _cParcela := "" As Char
	Local _cTipo := "" As Char
	Local _cCodFor := "" As Char
	Local _cLoja := "" As Char
	Local _lContinua := .F. As Logical
	Local _lInclui := .F. As Logical

	If !(Len(_aAuxZ29) > 0)
		Return .F.
	EndIf

	If (_nPos := ASCAN(_aAuxZ29,{|A|A[1]=="Z29_FILIAL"})) <> 0
		_cFilial := _aAuxZ29[_nPos,2]
	Else
		Return .F.
	EndIf

	If (_nPos := ASCAN(_aAuxZ29,{|A|A[1]=="Z29_PREFIX"})) <> 0
		_cPrefixo := _aAuxZ29[_nPos,2]
	Else
		Return .F.
	EndIf

	If (_nPos := ASCAN(_aAuxZ29,{|A|A[1]=="Z29_NUM"})) <> 0
		_cNumero := _aAuxZ29[_nPos,2]
	Else
		Return .F.
	EndIf

	If (_nPos := ASCAN(_aAuxZ29,{|A|A[1]=="Z29_PARCEL"})) <> 0
		_cParcela := _aAuxZ29[_nPos,2]
	Else
		Return .F.
	EndIf

	If (_nPos := ASCAN(_aAuxZ29,{|A|A[1]=="Z29_TIPO"})) <> 0
		_cTipo := _aAuxZ29[_nPos,2]
	Else
		Return .F.
	EndIf

	If (_nPos := ASCAN(_aAuxZ29,{|A|A[1]=="Z29_FORNEC"})) <> 0
		_cCodFor := _aAuxZ29[_nPos,2]
	Else
		Return .F.
	EndIf

	If (_nPos := ASCAN(_aAuxZ29,{|A|A[1]=="Z29_LOJA"})) <> 0
		_cLoja := _aAuxZ29[_nPos,2]
	Else
		Return .F.
	EndIf

	If _cPrefixo <> "CVI"
		DbSelectArea("Z29")
		DbSetOrder(1)
		If Dbseek(_cFilial+_cPrefixo+_cNumero+_cParcela+_cTipo)
			If Z29->Z29_STATUS <> "N" .AND. Z29->Z29_STATUS <> "E"
				_lContinua := .F.
				_cErro += "Registro ja incluido anteriormente"
			Else
				_lContinua := .T.
			EndIf
			_lInclui := .F.
		Else
			_lContinua := .T.
			_lInclui := .T.
		EndIf

		If _lContinua
			If _lBeginTra
				Begin Transaction
					Z29->(RecLock("Z29",_lInclui))
					For _ni := 1 To Len(_aAuxZ29)
						Z29->&(_aAuxZ29[_ni,1]) := _aAuxZ29[_ni,2]
					Next
					Z29->(MsUnLock())
				End Transaction
			Else
				Z29->(RecLock("Z29",_lInclui))
				For _ni := 1 To Len(_aAuxZ29)
					Z29->&(_aAuxZ29[_ni,1]) := _aAuxZ29[_ni,2]
				Next
				Z29->(MsUnLock())
			EndIf
			_nRecnoZ29 := Z29->(Recno())
		EndIf
	Else
		_lContinua := .T.
		_nRecnoZ29 := 0
	EndIf

Return _lContinua

/*
===============================================================================================================================
Programa----------: MFIN021SE2
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Inclus�o de Titulo no Contas a Pagar
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lContinua  
===============================================================================================================================
*/ 
Static Function MFIN021SE2(aVetSE2 As Array,_cErro As Char,_lBeginTra As Logical,_aAuxZ29 As Array) As Logical
	Local _lContinua := .T. As Logical

	Default _lBeginTra := .T.

	_lContinua := MFIN021Z29(_aAuxZ29,@_cErro,_lBeginTra)

	If _lContinua
		If _lBeginTra
			Begin Transaction
				
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| FINA050(x,y,z)}, aVetSE2,,3)  // Inclus�o

				If lMsErroAuto
					_cErro += "MSExecAuto: [ "+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MFIN021.LOG")+" ]"
					_lContinua := .F.
					DisarmTransaction()
				Else
					_lContinua := .T.
				EndIf

			End Transaction
		Else
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| FINA050(x,y,z)}, aVetSE2,,3)

			If lMsErroAuto
				_cErro += "MSExecAuto: [ "+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MFIN021.LOG")+" ]"
				_lContinua := .F.
			Else
				_lContinua := .T.
			EndIf
		EndIf
	EndIf

Return _lContinua

/*
===============================================================================================================================
Programa----------: MFIN021ST
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Inclus�o de Titulo no Contas a Pagar
===============================================================================================================================
Parametros--------: _lContinua,_cOper
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/ 
Static Function MFIN021ST(_lContinua,_cOper)

	//Begin Transaction
		If _nRecnoZ26 <> 0 
			If _nRecnoZ26 <> Z26->(Recno())
				Z26->(DbGoTo(_nRecnoZ26))
			EndIf
			If _nRecnoZ26 = Z26->(Recno())
				Z26->(RecLock("Z26",.F.))
				Z26->Z26_PROCES := _lContinua
				Z26->Z26_STATUS := Iif(_cOper== "I",Iif(_lContinua,"I","N"),_cOper)
				Z26->(MsUnlock())
			EndIf 
		EndIf
		If _lContinua
			If _nRecnoZ29 <> 0
				If _nRecnoZ29 <> Z29->(Recno())
					Z29->(DbGoTo(_nRecnoZ29))
				EndIf
				If _nRecnoZ29 = Z29->(Recno())
					Z29->(DbGoTo(_nRecnoZ29))
					Z29->(RecLock("Z29",.F.))
					Z29->Z29_STATUS := Iif(_cOper $ "I;R;E",Iif(_lContinua,_cOper,Iif(Z29->Z29_STATUS $ "I;R;E",Z29->Z29_STATUS,"N")),_cOper)
					Z29->(MsUnlock())
				EndIf
			EndIf
		EndIf
	//End Transaction

Return 

/*
===============================================================================================================================
Programa----------: MFIN021GP
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Retorna os Parametros da Filial
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _aDados  
===============================================================================================================================
*/
Static Function MFIN021GP(_cFilial As Char,_cPrefixo As Char) As Array
	Local _aDados := {} As Array
	DbSelectArea("Z30")
	DbSetOrder(1)
	If DBSeek(_cFilial)
		If _cPrefixo == "RVI"
			Aadd(_aDados, "")
			Aadd(_aDados, "")
			Aadd(_aDados, "")
			Aadd(_aDados, Z30->Z30_RNAT)
			Aadd(_aDados, Z30->Z30_RCCON)
			Aadd(_aDados, Z30->Z30_RCCUS)
			Aadd(_aDados, Z30->Z30_RHIST)
			Aadd(_aDados, Z30->Z30_EMAILW)
			Aadd(_aDados, Z30->Z30_NRATCC)
			Aadd(_aDados, Z30->Z30_NINTFI)
			Aadd(_aDados, Z30->Z30_EMAILF)
		ElseIf _cPrefixo == "AVI" .OR. _cPrefixo == "CVI"
			Aadd(_aDados, Z30->Z30_ABANCO)
			Aadd(_aDados, Z30->Z30_AAGENC)
			Aadd(_aDados, Z30->Z30_ACONTA)
			Aadd(_aDados, Z30->Z30_ANAT)
			Aadd(_aDados, Z30->Z30_ACCON)
			Aadd(_aDados, Z30->Z30_ACCUS)
			Aadd(_aDados, Z30->Z30_AHIST)
			Aadd(_aDados, Z30->Z30_EMAILW)
			Aadd(_aDados, Z30->Z30_NRATCC)
			Aadd(_aDados, Z30->Z30_NINTFI)
			Aadd(_aDados, Z30->Z30_EMAILF)
		Else
			Aadd(_aDados, "" )
			Aadd(_aDados, "" )
			Aadd(_aDados, "" )
			Aadd(_aDados, "" )
			Aadd(_aDados, "" )
			Aadd(_aDados, "" )
			Aadd(_aDados, "" )
			Aadd(_aDados, "" )
			Aadd(_aDados, .F. )
			Aadd(_aDados, .F. )
			Aadd(_aDados, "" )
		EndIf
	EndIf
Return _aDados

/*
===============================================================================================================================
Programa----------: MFIN021GNU
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Retorna proximo numero de integra��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cRetorno   
===============================================================================================================================
*/
Static Function MFIN021GNU() As Char
	Local _cRetorno := "" As Char
	Local _cQuery   := "" As Char

	//////////////////////////////////////////////////////
	//Resgata ID de integra��o
	//////////////////////////////////////////////////////		
	_cQuery := " SELECT MAX(Z26_IDINTE) AS ID "
	_cQuery += " FROM " + RetSqlName("Z26")
	_cQuery += " WHERE D_E_L_E_T_ <> '*'"

	TcQuery _cQuery New Alias "QRY"

	DbSelectArea("QRY")
	DbGoTop()

	_cRetorno := StrZero(Val(Right(Alltrim(QRY->ID),10))+1,10)

	Do While !MayIUseCode( "Z26_IDINTE"+xFilial("Z26")+_cRetorno)  //verifica se esta na memoria, sendo usado
		_cRetorno := Soma1(_cRetorno)						 // busca o proximo numero disponivel
	EndDo

	DbSelectArea("QRY")
	DbCloseArea()

Return _cRetorno

//*************
// GET 
//*************
WsRestFul GetConsultaNF Description "Metodo Respons�vel por Verificar e existencia de uma NF"

	WsData cCgcEmp	As Char

	WsMethod Get Description "Verifica a existencia de uma NF " WsSyntax "/GetConsultaNF"

End WsRestFul

WsMethod Get WsReceive cCgcEmp WsService GetConsultaNF

	Local cBody     	:= ::GetContent() As Char
	Local lContinua     := .F. As Logical
	Local _cFilialJso   := "" As Char
	Local _cNotaFiscal  := "" As Char
	Local _cSerie       := "" As Char
	Local _cTipo        := "" As Char
	Local _cFornec      := "" As Char
	Local _cLoja        := "" As Char
	Local _cCNPJ        := "" As Char
	Local _cJson        := "" As Char
	Local _cMsg         := "" As Char
	Local _nOrderSF1    := 0 As Numeric
	Local _cChaveSF1    := "" As Char

	Private oJsoAux   	:= Nil

	If DecodeUtf8(cBody) <> Nil
		cBody := DecodeUtf8(cBody)
	EndIf
	
	FWJsonDeserialize(cBody, @oJsoAux)

	_cFilialJso  := oJsoAux:FILIAL

	RpcClearEnv()
	RpcSetEnv("01",_cFilialJso)

	_cNotaFiscal := oJsoAux:NUMERO_NF
	_cSerie 	 := oJsoAux:SERIE_NF
	_cCNPJ       := oJsoAux:CNPJ_NF
	_cTipo       := "NF "

	DbSelectArea("SA2")
	DbSetOrder(3)
	If Dbseek(xFilial("SA2")+_cCNPJ)
		_cFornec := SA2->A2_COD
		_cLoja   := SA2->A2_LOJA
		lContinua := .T.
	Else
		lContinua := .F.
		_cMsg := " CNPJ n�o encontrado"
	EndIf

	If lContinua

		If AttIsMemberOf(oJsoAux, "SERIE")
			_cSerie := oJsoAux:SERIE
			_nOrderSF1 := 1 //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
			_cChaveSF1 := _cFilialJso+_cNotaFiscal+_cSerie+_cFornec+_cLoja+_cTipo
		Else
			_cSerie := Space(Len(SF1->F1_SERIE))
			_nOrderSF1 := 12 //F1_FILIAL + F1_DOC + F1_FORNECE + F1_LOJA + F1_TIPO
			_cChaveSF1 := _cFilialJso+_cNotaFiscal+_cFornec+_cLoja+_cTipo
		EndIf

		DbSelectArea("SF1")
		SF1->(DBSetOrder(_nOrderSF1))
		If Dbseek(_cChaveSF1)
			lContinua := .T.
		Else
			lContinua := .F.
			_cMsg := " Nota n�o encontrada"
		EndIf

	EndIf
	
	_cJson := "{" 
	_cJson += '"retorno":' + Iif(lContinua,'"200"','"400"')
	_cJson += '"mensagem":' + IIf(lContinua,'"encontrou"','"n�o encontrou '+_cMsg+'"')
	_cJson += "}"

	If !lContinua
		::setStatus(500)
	EndIf 

	::SetResponse( _cJson )

Return(.T.)



//*************
// GET 
//*************
WsRestFul GetControleFinanceiro Description "Metodo Respons�vel por Verificar a situa��o de um Titulo"

	WsData cCgcEmp	As Char

	WsMethod Get Description "Verifica a situa��o de um Titulo " WsSyntax "/GetControleFinanceiro"

End WsRestFul

WsMethod Get WsReceive cCgcEmp WsService GetControleFinanceiro

	Local cBody     	:= ::GetContent() As Char
	Local lContinua     := .F. As Logical
	Local _cFilial      := "" As Char
	Local _cPrefixo     := "" As Char
	Local _cID          := "" As Char
	Local _cTipo        := "" As Char
	Local _cDtEmiss     := "" As Char
	Local _cDtVencto    := "" As Char
	Local _cDtVencRe    := "" As Char
	Local _cDtBaixa     := "" As Char
	Local _cVrLiq       := "" As Char
	Local _cVrSaldo     := "" As Char
	Local _cStatus      := "" As Char
	Local _cFornec      := "" As Char
	Local _cLoja        := "" As Char
	Local _cCNPJ        := "" As Char

	Local _cJson        := "" As Char
	Private oJsoAux   	:= Nil As Object

	If DecodeUtf8(cBody) <> Nil
		cBody := DecodeUtf8(cBody)
	EndIf
	
	FWJsonDeserialize(cBody, @oJsoAux)

	_cFilial     := oJsoAux:FILIAL

	RpcClearEnv()
	RpcSetEnv("01",_cFilial)

	_cID         := oJsoAux:ID
	_cCNPJ       := oJsoAux:CNPJ
	_cTipo       := Iif(AttIsMemberOf(oJsoAux, "TIPO"),oJsoAux:TIPO,"RC ")
	_cPrefixo    := Iif(_cTipo="PA","AVI",Iif(_cTipo="RC ","RVI",""))

	DbSelectArea("SA2")
	DbSetOrder(3)
	If Dbseek(xFilial("SA2")+_cCNPJ)
		_cFornec := SA2->A2_COD
		_cLoja   := SA2->A2_LOJA
		lContinua := .T.
	Else
		lContinua := .F.
		_cMsg := " CNPJ n�o encontrado"
	EndIf

	If lContinua
		DbSelectArea("SE2")
		SE2->(DBSetOrder(1))
		If Dbseek(_cFilial+_cPrefixo+_cID+_cTipo+_cFornec+_cLoja)
			_cDtEmiss  := DTOC(SE2->E2_EMISSAO)
			_cDtVencto := DTOC(SE2->E2_VENCTO)
			_cDtVencRe := DTOC(SE2->E2_VENCREA)
			_cDtBaixa  := DTOC(SE2->E2_BAIXA)
			_cTipo     := SE2->E2_TIPO
			_cVrLiq    := Alltrim(Transform(SE2->E2_VALOR-SE2->E2_SALDO,"@E 999.999,999,999.99"))
			_cVrSaldo  := Alltrim(Transform(SE2->E2_SALDO,"@E 999.999,999,999.99"))

			If SE2->E2_SALDO <= SE2->E2_VALOR .AND. SE2->E2_SALDO > 0
				_cStatus := "BAIXADO PARCIAL"
			ElseIf SE2->E2_SALDO = SE2->E2_VALOR .AND. SE2->E2_SALDO > 0
				_cStatus := "EM ABERTO"
			ElseIf SE2->E2_SALDO <= 0
				_cStatus := "BAIXADO"
			EndIf
			lContinua := .T.
		Else
			lContinua := .F.
			_cMsg := " T�tulo n�o encontrado"
		EndIf
	EndIf

	If lContinua
		_cJson := "{" 
		_cJson += '"retorno":"200",'
		_cJson += '"mensagem":"encontrou",'
		_cJson += '"FILIAL":"'+_cFilial+'",'
		_cJson += '"ID_PAYTRACK":"'+_cID+'",'
		_cJson += '"TIPO":"'+_cTipo+'",'
		_cJson += '"VALOR_LIQUIDADO":"'+_cVrLiq+'",'
		_cJson += '"VALOR_SALDO":"'+_cVrSaldo+'",'
		_cJson += '"DATA_EMISSAO":"'+_cDtEmiss+'",'
		_cJson += '"DATA_VENCTO":"'+_cDtVencto+'",'
		_cJson += '"DATA_VENCREA":"'+_cDtVencRe+'",'
		_cJson += '"DATA_BAIXA":"'+_cDtBaixa+'",'
		_cJson += '"STATUS":"'+_cStatus+'" '
		_cJson += "}"
	Else
		_cJson := "{" 
		_cJson += '"retorno":"500",'
		_cJson += '"mensagem":"n�o encontrou '+_cMsg+'"'
		_cJson += "}"

		::setStatus(500) 
	EndIf

	::SetResponse( _cJson )

Return(.T.)


/*
===============================================================================================================================
Programa----------: MFIN021VEN
Autor-------------: Igor Melga�o
Data da Criacao---: 15/09/2023
===============================================================================================================================
Descri��o---------: Retorna a data de vencimento do t�tulo
===============================================================================================================================
Parametros--------: dData
===============================================================================================================================
Retorno-----------: dData   
===============================================================================================================================
*/
User Function MFIN021VEN(dData As Date) As Date
Local cDTVenc    := U_ITGETMV("IT_MFIN21V","14;29") As Char
Local cRegVenc   := U_ITGETMV("IT_MFIN21R","13;27") As Char
Local aReg       := StrTokArr(cRegVenc,";") As Array
Local aVenc      := StrTokArr(cDTVenc,";") As Array

If Len(aVenc) <> 2 
	aVenc := StrTokArr("14;29",";")
EndIf

If Len(aReg) <> 2
	aReg := StrTokArr("13;27",";")
EndIf

If Day(dData) < Val(aReg[1]) .OR. Day(dData) > Val(aReg[2])
	If Day(dData) < Val(aReg[1])
		dData := CTOD(AllTrim(aVenc[1])+"/"+Strzero(Month(dData),2)+"/"+Alltrim(Str(Year(dData))))
	Else
		dData := CTOD(AllTrim(aVenc[1])+"/"+StrZero(Month(dData)+1,2)+"/"+Alltrim(Str(Year(dData))))
	EndIf
Else
	dData := CTOD(AllTrim(aVenc[2])+"/"+Strzero(Month(dData),2)+"/"+Alltrim(Str(Year(dData))))
EndIf

dData := MFIN021DTU(dData,.F.,.T.,.T.)

Return(dData)

/*
===============================================================================================================================
Programa----------: IT_DTVALIDA()
Autor-------------: Igor Melga�o
Data da Criacao---: 09/10/2023
===============================================================================================================================
Descri��o---------: Valida a Data util de acordo com os feriados
===============================================================================================================================
Parametros--------: dDataRef,lSoma,lConsFerEs,lConsFerMu,_cFil_SP3
===============================================================================================================================
Retorno-----------: dDataRef
===============================================================================================================================
*/
Static Function MFIN021DTU(dDataRef As Date,lSoma As Logical,lConsFerEs As Logical,lConsFerMu As Logical,cFil_SP3 As Char) As Date
Default lSoma      := .T.
Default lConsFerEs := .F.
Default cFil_SP3   := xFilial("SP3")

Static aFeriados  := {}

If LEN(aFeriados) = 0
	aFeriados := MFIN021BF(lConsFerEs,lConsFerMu,cFil_SP3)
EndIf

dDataRef := MFIN021PDT(dDataRef,aFeriados,lSoma)

If dDataRef < Date() // se a data calculada for menor que a atual traz o Proximo dia util
	dDataRef := MFIN021PDT(dDataRef,aFeriados,.T.)
EndIf

Return dDataRef

/*
===============================================================================================================================
Programa----------: IT_DTVALIDA()
Autor-------------: Igor Melga�o
Data da Criacao---: 09/05/2023
===============================================================================================================================
Descri��o---------: Valida a Data util de acordo com os feriados
===============================================================================================================================
Parametros--------: dDataRef,nDiasUteis,lSoma,lConsFerEs,_cFil_SP3
===============================================================================================================================
Retorno-----------: dDataRef
===============================================================================================================================
*/
Static Function MFIN021PDT(dDataRef As Date,aFeriados As Array,lSoma As Logical) As Date
Local nIncrement := 0 As Numeric

If lSoma
	nIncrement := 1
Else
	nIncrement := -1
Endif

If Dow(dDataRef) == 1 .OR. Dow(dDataRef) == 7//Se for domingo
	dDataRef := dDataRef + IIf(Dow(dDataRef) == 1,nIncrement*Iif(lSoma,1,2),nIncrement*Iif(lSoma,2,1))
EndIf

Do While ASCAN(aFeriados, DTOS(dDataRef)  ) <> 0
	dDataRef := dDataRef + nIncrement
	If Dow(dDataRef) = 1 .OR. Dow(dDataRef) == 7
		dDataRef := dDataRef + nIncrement
	EndIf
EndDo

Return dDataRef


/*
===============================================================================================================================
Programa----------: MFIN021BF()
Autor-------------: Igor Melga�o
Data da Criacao---: 09/10/2023
===============================================================================================================================
Descri��o---------: Busca feriados
===============================================================================================================================
Parametros--------: lConsFerEs,lConsFerMu,_cFil_SP3
===============================================================================================================================
Retorno-----------: aFeriados
===============================================================================================================================
*/
Static Function MFIN021BF(lConsFerEs As Logical, lConsFerMu As Logical, cFil_SP3 As Char) As Array
Local aFeriados := {} as Array
Default cFil_SP3 := xFilial("SP3") 

DbSelectArea("SP3")
SP3->(dbSetOrder(1))
SP3->(dbGoTop())
Do While SP3->(!EOF())
	If SP3->P3_I_TPFER == "N" // Nacional 
		If ASCAN(aFeriados,DTOS(SP3->P3_DATA) ) = 0
			AADD(aFeriados,DTOS(SP3->P3_DATA) )
		EndIf
	ElseIF SP3->P3_I_TPFER == "E" .AND. lConsFerEs
		If cFil_SP3 == SP3->P3_FILIAL //.AND. ASCAN(aFeriados, DTOS(SP3->P3_DATA) ) = 0
			AADD(aFeriados, DTOS(SP3->P3_DATA) )
		EndIf				
	ElseIF SP3->P3_I_TPFER == "M" .AND. lConsFerMu
		If cFil_SP3 == SP3->P3_FILIAL //.AND. ASCAN(aFeriados, DTOS(SP3->P3_DATA) ) = 0
			AADD(aFeriados, DTOS(SP3->P3_DATA) )
		EndIf			
	EndIf
	SP3->(dbSkip())
EndDo

Return aFeriados

