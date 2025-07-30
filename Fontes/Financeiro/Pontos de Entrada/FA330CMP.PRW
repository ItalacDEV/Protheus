/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 09/04/2024 | Chamado 46400 - Ajuste para Instução bancária dos registros marcados na janela de compensação
===============================================================================================================================
*/


#Include "Totvs.ch"

/*
===============================================================================================================================
Programa----------: F330CMP
Autor-------------: Antonio Neves
Data da Criacao---: 26/02/2024
===============================================================================================================================
Descrição---------: P.E. Para geração a Instrução Bancária de Abatimento. O padrão não gera quando Compensação
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function FA330CMP()

	Local _aAreaSE1   := GetArea()
	Local _nValTrs 	:= 0   //06/02/2024
	Local _cFilInst	:= 0
	Local _cNumTit		:= ""
	Local _cPrefixo	:= ""
	Local _cParcela	:= ""
	Local _cTipo		:= ""
	Local _cCliente	:= ""
	Local _cLoja		:= ""
	Local _cNumBor		:= ""
	Local _nSaldo		:= 0
	Local _cPortado	:= ""
	Local _cEnvBol    := ""
	Local _nX			:= 0
	Local _nI         := 0
	Local _nPosFilial := 0
	Local lInstruBanc := .F.

	//ADICIONADO INSTRUCAO BANCARIA
	_cFilInst	:= SE1->E1_FILIAL
	_cNumTit	   := SE1->E1_NUM
	_cPrefixo	:= SE1->E1_PREFIXO
	_cParcela	:= SE1->E1_PARCELA
	_cTipo		:= SE1->E1_TIPO
	_cCliente	:= SE1->E1_CLIENTE
	_cLoja		:= SE1->E1_LOJA
	_cNumBor	   := SE1->E1_NUMBOR
	_nSaldo		:= SE1->E1_SALDO
	_cPortado	:= SE1->E1_PORTADO
	_cNumBco    := SE1->E1_NUMBCO
	//FIM ADICAO INSTRUCAO BANCARIA

	_lBcoInst	:= U_ITGETMV('IT_BCOINST', "")

	If _cPortado $ _lBcoInst

		_cEnvBol    := POSICIONE("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_I_IBOLE")

		For _nX := 1 To Len( aTitulos )
			_nValTrs += Val(StrTran(StrTran(aTitulos[_nX][7],".",""),",","."))
		Next _nX

		If !Empty(_cNumBco) .And. !Empty(_cPortado) //.And. _cEnvBol == "S"
			lInstruBanc := MsgYesNo("Deseja Gerar Instrução Bancária?", "Confirma?")

			If lInstruBanc
				//ADICAO DA INCLUSÃO DA INSTRUCAO BANCARIA
				FI2->(Reclock("FI2",.T.))

				FI2->FI2_FILIAL := _cFilInst
				FI2->FI2_OCORR  := "04"
				FI2->FI2_DESCOC := "CONCESSAO DE ABATIME"
				FI2->FI2_PREFIX := _cPrefixo
				FI2->FI2_TITULO := _cNumTit
				FI2->FI2_PARCEL := _cParcela
				FI2->FI2_TIPO 	:= _cTipo
				FI2->FI2_CODCLI := _cCliente
				FI2->FI2_LOJCLI := _cLoja
				FI2->FI2_GERADO := "2"
				FI2->FI2_NUMBOR := _cNumbor
				FI2->FI2_CARTEI := "1"
				FI2->FI2_DTOCOR := dDataBase
				FI2->FI2_VALANT := STR(_nSaldo,30,2)
				FI2->FI2_VALNOV := STR(_nValTrs,30,2)
				FI2->FI2_CAMPO  := "FI2_VALNOV"
				FI2->FI2_TIPCPO := "C"

				FI2->(MsUnlock())

			EndIf
		EndIf
	EndIf

	If lInstruBanc
		For _nI := 1 TO LEN(aTitulos)
			If aTitulos[_nI,8]

				If MV_PAR02 <> 2
					_nPosFilial := 13
				Else
					_nPosFilial := 16
				EndIf

				DbSelectArea("SE1")
				DbSetOrder(1)
				If Dbseek(aTitulos[_nI,_nPosFilial]+aTitulos[_nI,1]+aTitulos[_nI,2]+aTitulos[_nI,3]+aTitulos[_nI,4])   
			
					_cNumBor	 := SE1->E1_NUMBOR
					_cPortado := SE1->E1_PORTADO
					_cNumBco  := SE1->E1_NUMBCO	
					_cCliente := SE1->E1_CLIENTE
					_nSaldo   := SE1->E1_SALDO
					_nValTrs  := Val(StrTran(StrTran(aTitulos[_nI][7],".",""),",","."))
					
					If _cPortado $ _lBcoInst .AND. !Empty(_cNumBco) .And. !Empty(_cPortado) //.And. _cEnvBol == "S"

						FI2->(Reclock("FI2",.T.))

						FI2->FI2_FILIAL := aTitulos[_nI,_nPosFilial]
						FI2->FI2_OCORR  := "04"
						FI2->FI2_DESCOC := "CONCESSAO DE ABATIME"
						FI2->FI2_PREFIX := aTitulos[_nI,1] //Prefixo
						FI2->FI2_TITULO := aTitulos[_nI,2]
						FI2->FI2_PARCEL := aTitulos[_nI,3]
						FI2->FI2_TIPO 	 := aTitulos[_nI,4]
						FI2->FI2_CODCLI := _cCliente 
						FI2->FI2_LOJCLI := aTitulos[_nI,5]
						FI2->FI2_GERADO := "2"
						FI2->FI2_NUMBOR := _cNumbor
						FI2->FI2_CARTEI := "1"
						FI2->FI2_DTOCOR := dDataBase
						FI2->FI2_VALANT := STR(_nSaldo,30,2)
						FI2->FI2_VALNOV := STR(_nValTrs,30,2)						
						FI2->FI2_CAMPO  := "FI2_VALNOV"
						FI2->FI2_TIPCPO := "C"

						FI2->(MsUnlock())

					EndIf
				EndIf
			EndIf
		Next
	EndIf

	//FIM DA ADICAO DA INSTRUCAO BANCARIA
	RestArea(_aAreaSE1)

Return
