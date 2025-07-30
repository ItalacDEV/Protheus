/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/10/2019 | Tratamento para o campo NOVO CLAIM. Chamado 30921 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 29/12/2020 | Inclu�do tratamento para execu��o desnecess�ria no execauto do leite. Chamado: 34986
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 25/03/2022 | Grava��o das informa��es no fechamento via PE ao inv�s de RecLock. Chamado 39465
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MT100GE2
Autor-------------: Vladimir Souza
Data da Criacao---: 16/12/2014
===============================================================================================================================
Descri��o---------: Ponto de Entrada apos gravacao do titulos no financeiro - SE2 , tela listando os titulos de impostos. Rotina 
					que efetua a integra��o entre o documento de entrada e os t�tulos financeiros a pagar,ap�s a grava��o de cada
					parcela. Finalidade: Complementar a grava��o na tabela dos t�tulos financeiros a pagar
===============================================================================================================================
Parametros--------: PARAMIXB[1]	-> A -> ACols dos t�tulos financeiro a pagar
					PARAMIXB[2]	-> N -> 1=inclus�o de t�tulos, 2=exclus�o de t�tulos
					PARAMIXB[3]	-> A -> AHeader dos t�tulos financeiros a pagar
					PARAMIXB[4]	-> N -> Numero da parcela sendo processada
					PARAMIXB[5]	-> N -> Array das parcelas do titulo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT100GE2()

Local _cAlias	:= ""
Local _aTitulos	:= {}
Local _lRLeite	:= !AllTrim( Upper( FUNNAME() ) ) $"U_MGLT009/MGLT010"
Local _oDlg		:= Nil
Local _oLbx		:= Nil
Local _cTitulo	:= 'Titulos de Impostos amarrados'

If _lRLeite

	SD1->(DBSetOrder(1))
	SD1->(DBSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	SC7->(DBSetOrder(1))
	If SC7->(DBSeek(xFilial("SC7")+SD1->D1_PEDIDO))
		If SC7->C7_I_CLAIM = "1"
			SE2->(RecLock("SE2",.F.))
			SE2->E2_I_CLAIM:="1"
			SE2->(MsUnlock())
		EndIf
	EndIf
	
	_cAlias	:= GetNextAlias()
	BeginSql alias _cAlias
		SELECT E2_NUM, E2_PREFIXO, E2_PARCELA, E2_NATUREZ, ED_DESCRIC, E2_FORNECE, E2_LOJA, E2_VALOR, E2_VENCREA
		FROM %table:SE2% SE2, %table:SED% SED
		WHERE SE2.D_E_L_E_T_ = ' '
		AND SED.D_E_L_E_T_ = ' '
		AND E2_FILIAL = %xFilial:SE2%
		AND ED_FILIAL = %xFilial:SED%
		AND E2_NATUREZ = ED_CODIGO
		AND SE2.E2_TITPAI  = %exp:SE2->(E2_PREFIXO+E2_NUM) +"  NF "+ SE2->(E2_FORNECE+E2_LOJA)%
	EndSql

	While (_cAlias)->( !Eof() )
		aAdd( _aTitulos , {	(_cAlias)->E2_NUM			,;
							(_cAlias)->E2_PREFIXO		,;
							(_cAlias)->E2_PARCELA		,;
							(_cAlias)->E2_NATUREZ		,;
							(_cAlias)->ED_DESCRIC		,;
							(_cAlias)->E2_FORNECE		,;
							(_cAlias)->E2_LOJA			,;
							(_cAlias)->E2_VALOR			,;
							STOD( (_cAlias)->E2_VENCREA )})

		(_cAlias)->( DBSkip() )
	EndDo

	(_cAlias)->( DBCloseArea() )

	If !Empty( _aTitulos )

		DEFINE MSDIALOG _oDlg TITLE _cTitulo FROM 0,0 TO 240,900 PIXEL

			@010,010 LISTBOX _oLbx	FIELDS	HEADER "Titulo", "Prefixo", "Parcela", "Natureza", "Desc.Natureza", "Fornecedor", "Loja" , "Valor" , "Vencimento" ;
		     						SIZE	430,095 ;
		     						OF		_oDlg PIXEL

			_oLbx:SetArray( _aTitulos )
			_oLbx:bLine := {|| {	_aTitulos[_oLbx:nAt][01]						,;
									_aTitulos[_oLbx:nAt][02]						,;
									_aTitulos[_oLbx:nAt][03]						,;
									_aTitulos[_oLbx:nAt][04]						,;
									_aTitulos[_oLbx:nAt][05]						,;
									_aTitulos[_oLbx:nAt][06]						,;
									_aTitulos[_oLbx:nAt][07]						,;
						Transform(	_aTitulos[_oLbx:nAt][08] , "99,999,999.99" )	,;
									_aTitulos[_oLbx:nAt][09]						}}

		DEFINE SBUTTON FROM 107,415 TYPE 1 ACTION _oDlg:End() ENABLE OF _oDlg

		ACTIVATE MSDIALOG _oDlg CENTER

	EndIf
ElseIf !_lRLeite .And. PARAMIXB[2] //MGLT009 e Inclus�o
	SE2->E2_L_MIX := ZLE->ZLE_COD
	SE2->E2_L_SETOR := ZL2->ZL2_COD
	SE2->E2_L_LINRO := ZL3->ZL3_COD
	If SA2->A2_L_TPPAG == "B"
		SE2->E2_L_TPPAG := SA2->A2_L_TPPAG
		SE2->E2_L_BANCO := SA2->A2_BANCO
		SE2->E2_L_AGENC := SA2->A2_AGENCIA
		SE2->E2_L_CONTA := SA2->A2_NUMCON
	EndIf
EndIf

Return
