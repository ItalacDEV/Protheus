/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz         |10/10/2018  | Chamado 26570. Alterar rotina de envio de WorkFlow para enviar e-mail apenas a aprovadore ativos.
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich      |20/02/2019  | Chamado 28160. Inclus�o de observa��o na libera��o de cliente.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 10/06/2020 | Chamado 33192. Aprova��o de Cr�dito Tratar Percetual do Queijo no Valor. 
-------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 02/07/2020 | Chamado 33426. Ajuste do Layout Aprova��o de Pre�o. 
 -------------------------------------------------------------------------------------------------------------------------------
 Jonathan         | 23/09/2020 | Chamado 34163. Corre��o para apresentar o valor do pre�o tabela no LIBPV_PRECO.HTM. 
 ------------------------------------------------------------------------------------------------------------------------------
 Jonathan         | 09/10/2020 | Chamado 34262. Remocao de bugs apontados pelo Totvs CodeAnalysis. 
--------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 04/11/2020 | Chamado 34582. Validar novo campo de Tabela de Pre�o. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 29/12/2020 | Chamado 35108. Corre��o troca da fun��o UsrRetMail() para U_UCFG001(3).
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 14/05/2021 | Chamado 36000. Ajustes para melhoria de performance. 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 26/07/2021 | Chamado 37265. Corre��o no nome do array utilizado p/pegar nome e e-mail do usu�rio aprovador.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 13/09/2021 | Chamado 36809. Ajustes para detalhamento de bloqueio e atualiza��o para RDC.  
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 13/08/2021 | Chamado 37416. Retirado valida��o da Filial DA0 e DA1. 
-------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 06/10/2021 | Chamado 37949. Ajustes para Tratar o Tipo de Bloqueio de Vendas.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 18/10/2021 | Chamado 37491. Ajustes para n�o processamento de workflow em duplicidade em X periodo de tempo.  
------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 14/12/2021 | Chamado 38612. Ajustes do retorno de varivel dos htms . 
------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 12/04/2022 | Chamado 39761. Ajuste para controle de envio WF com origem do RDC. 
-------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 29/04/2022 | Chamado 38883. Ajuste na Efetiva��o Automatica Pedido Portal retirando paradas em tela. 
-------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 10/05/2022 | Chamado 39999. Ajuste no Layout para mostrar Vlr do Pre�o por Faixa. 
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 12/03/2024 | Chamado 45575. Ajuste para convers�o de texto do Assunto do email em padrao UTF8.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 23/07/2025 | Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
================================================================================================================================
*/ 

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "rwmake.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"
#include "protheus.ch"
#include "topconn.ch"

Static _cHostWF 	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4034/")
Static _dDtIni		:= DtoS(U_ItGetMv("IT_WFDTINI","20150101"))
Static _aAprCredito	:= {}
Static _aAprPreco  	:= {}
Static _aAprBonif	:= {}
Static _cAprCredito	:= ""
Static _cAprPreco  	:= ""
Static _cAprBonif	:= ""
Static _cEmaisEnv	:= ""
Static _lApr		:= .F.

/*
===============================================================================================================================
Programa----------: MOMS030
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 01/04/2016
===============================================================================================================================
Descri��o---------: Rotina responsavel pelo envio de workflow de libera��o de cr�dito Pedido de Vendas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS030()

	Local _aArea		:= GetArea()
	Local _cBlqCre		:= SC5->C5_I_BLCRE
	Local _cBlqPre		:= SC5->C5_I_BLPRC
	Local _cBlqBon		:= SC5->C5_I_BLOQ
	Local _lCliBlq		:= .F.
	Local _cGetSol		:= Space(100)
	Local _oGetSol
	Local _oSaySol
	Local _oSBtCan
	Local _oSBtOk
	Local _nOpca		:= 0
	Local _lRet         := .F.
	Local _cTipoLib		:= ""
	Local _cTempoWF     := U_ITGETMV("IT_TMPLIBWF","00:30:00") // Padrao de preenchimento do parametro: Tempo em HH:MM:SS
	Local _cHora        := ""

	Private _oDlg

	_cEmaisEnv	:= "" // Limpa vari�vel para pegar somente os e-mails da excu��o atual

	If SC5->C5_I_DTUWF >= Date() .or. Empty(Alltrim(SC5->C5_I_DTUWF))
		If SC5->C5_I_DTUWF > Date()
			lContinua := .T.
		Else
			cTime := TIME()
			nDif := ELAPTIME( SC5->C5_I_HRUWF, cTime )

			If nDif > _cTempoWF
				lContinua := .T.
			Else
				_cHora := SomaHoras(SC5->C5_I_HRUWF,_cTempoWF)
				lContinua := .F.
			EndIf
		EndIf
	Else
		lContinua := .T.
	EndIf

	If !lContinua .And. !(FWIsInCallStack("U_AOMS109") .OR. FWIsInCallStack("U_MA410MNU"))
		U_ITMSG("Existe uma Solicita��o Pendentes para o Pedido, solicitanda em: "+DTOC(SC5->C5_I_DTUWF)+" as "+ Subs(SC5->C5_I_HRUWF,1,5) + ".",'Aten��o!',"Somente permitido nova solicita��o a partir das "+strtran(Alltrim(Str(_cHora)),".",":")+". Caso seja urgente entrar em contato com o Departamento Respons�vel !",3)
	EndIf

	If lContinua

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

		_lCliBlq := (SA1->A1_MSBLQL == "1")

		If _cBlqBon == 'B' //Solicita Libera��o por Bonifica��o

			Do Case
			Case SC5->C5_TPFRETE == 'F'
				_cTipoLib := "BLOQUEIO FRETE FOB"
			Case SC5->C5_I_OPER == '10'
				_cTipoLib := "BLOQUEIO DE BONIFICACAO"
			Case SC5->C5_I_OPER == '24'
				_cTipoLib := "BLOQUEIO DATA CRITICA"
			Case SC5->C5_I_OPER == '05'
				_cTipoLib := "BLOQUEIO OPERACAO TRIANGULAR"
			Case SC5->C5_CONDPAG == '001'
				_cTipoLib := "BLOQUEIO VENDA A VISTA"
			Otherwise
				_cTipoLib := "BLOQUEIO INEXISTENTE"
			EndCase

		ElseIf _cBlqPre == 'B' //Solicita Libera��o por Pre�o

			_cTipoLib	:= "por Pre�o"

		ElseIf _cBlqCre == 'B' .Or. _lCliBlq //Solicita Libera��o por Cr�dito

			_cTipoLib	:= "por Cr�dito"

		EndIf

		If !Empty(_cTipoLib)

			DEFINE MSDIALOG _oDlg TITLE "Solicita Libera��o "+_cTipoLib+" do Pedido: "+SC5->C5_NUM FROM 000, 000  TO 090, 500 COLORS 0, 16777215 PIXEL

			@ 005, 004 SAY _oSaySol PROMPT "Motivo da Solicita��o:" SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
			@ 017, 003 MSGET _oGetSol VAR _cGetSol SIZE 242, 010 OF _oDlg PICTURE "@!" COLORS 0, 16777215 PIXEL
			DEFINE SBUTTON _oSBtOk FROM 031, 185 TYPE 01 OF _oDlg ENABLE ACTION (_nOpca := 1, _oDlg:End())
			DEFINE SBUTTON _oSBtCan FROM 031, 216 TYPE 02 OF _oDlg ENABLE ACTION (_nOpca := 2, _oDlg:End())

			ACTIVATE MSDIALOG _oDlg CENTERED

			If _nOpca == 1 // Opera��o confirmada pelo usu�rio

				FwMsgRun(,{|| _lRet := U_MOMS030W( , _cGetSol )},,"Enviando Solicita��o de Libera��o do Pedido: "+SC5->C5_NUM)

				If _lRet
					U_ITMSG("Sua solicita��o foi enviada ao Aprovador(es) com sucesso.",,,2,,,,,,{|| Aviso("EMAIL(s)",_cEmaisEnv,{"OK"})} )
					DbSelectArea("SC5")
					RecLock("SC5", .F.)
					SC5->C5_I_DTUWF := Date()
					SC5->C5_I_HRUWF := Time()
					MsUnlock()
				Else
					U_ITMSG("Falha no envio de solicita��o de libera��o!",,,3)
				EndIf

				U_ITCONOUT('Termino do envio do workflow de libera��o de cr�dito na data: ' + Dtoc(DATE()) + ' - ' + Time())

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return


/*
===============================================================================================================================
Programa----------: MOMS030R
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 01/04/2016
===============================================================================================================================
Descri��o---------: Rotina respons�vel pela execu��o do retorno do workflow
===============================================================================================================================
Parametros--------: _oProcess - Processo inicializado do workflow
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS030R( _oProcess )

	Local _cFilial		:= SubStr(_oProcess:oHtml:RetByName("cFilPV"),1,2)
	Local _cNumPV		:= _oProcess:oHtml:RetByName("cNumPV")
	Local _cOpcao		:= IF("APROVAR" $ UPPER(_oProcess:oHtml:RetByName("OPCAO")), "APROVADO", "REJEITADO")//na variavel vem escrito "APROVAR (Aguarde...)"
	Local _cCodSol		:= _oProcess:oHtml:RetByName("cCodSol")
	Local _cObs			:= AllTrim(SubStr(UPPER(_oProcess:oHtml:RetByName("CR_OBS")),1,100))
	Local _cArqHtm		:= SubStr(_oProcess:oHtml:RetByName("WFMAILID"),3,Len(_oProcess:oHtml:RetByName("WFMAILID")))
	Local _cTipRet		:= ALLTRIM(_oProcess:oHtml:RetByName("CTIPOPER"))
	Local _cHtmlMode	:= "\Workflow\htm\pv_concluido.htm"
	Local _cQryZY0		:= ""
	Local _cCodApr		:= _oProcess:oHtml:RetByName("cCodApr")
	Local _cTipo		:= _cTipRet
	Local _cUsrBkp		:= __cUserId
	Local _cCliente		:= ""
	Local _lSoAprvador  :=.F.
	Local _aAvaliacao   :={}
	Local cMailZY0      :=""
	Local _bUserN		:= {|x| UsrFullName(x)}

	u_itconout("////////////////////// INICIO DA MOMS030R - PV "+_cFilial+" "+_cNumPV+" "+_cOpcao+" ///////////////////////")

	__cUserId := _cCodApr

	_cQryZY0 := "SELECT ZY0_TIPO,ZY0_EMAIL "
	_cQryZY0 += "FROM " + RetSqlName("ZY0") + " "
	_cQryZY0 += "WHERE ZY0_FILIAL = '" + xFilial("ZY0") + "' "
	_cQryZY0 += "  AND ZY0_CODUSR = '" + _cCodApr + "' "
	_cQryZY0 += "  AND ZY0_ATIVO = 'S' "
	_cQryZY0 += "  AND D_E_L_E_T_ = ' ' "

	If Select("TRBZY0") > 0
		TRBZY0->(DbCloseArea())
	EndIf
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryZY0 ) , "TRBZY0" , .T., .F. )

	dbSelectArea("TRBZY0")
	TRBZY0->(dbGoTop())
	cMailZY0:= ALLTRIM(TRBZY0->ZY0_EMAIL)

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(_cFilial + _cNumPV)

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
	_cCliente := SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + " - " + AllTrim(SA1->A1_NOME) + " - " + AllTrim(SA1->A1_NREDUZ)

	_lSoAprvador:=.F.
	_aAvaliacao:={}

	If _cTipRet == "PRECO" .AND. (SC5->C5_I_BLPRC = "L" .OR. SC5->C5_I_BLPRC = "R")

		IF SC5->C5_I_BLPRC = "L"
			_cOpcao:= "APROVADO"
			AADD(_aAvaliacao,{SC5->C5_I_DTLIP,SC5->C5_I_HLIBP,"Ja foi Aprovado por "+SC5->C5_I_ULIBP})
		ELSE
			_cOpcao:= "REJEITADO"
			AADD(_aAvaliacao,{SC5->C5_I_DTLIB,SC5->C5_I_HLIBP,"Ja foi Rejeitado por "+SC5->C5_I_ULIBP})
		ENDIF
		_cObs:=SC5->C5_I_MOTLP
		_lSoAprvador:=.T.

	ElseIf _cTipRet == "BONIFICACAO" .AND. (SC5->C5_I_BLOQ = "L" .OR. SC5->C5_I_BLOQ = "R")

		IF SC5->C5_I_BLOQ = "L"
			_cOpcao:= "APROVADO"
			AADD(_aAvaliacao,{SC5->C5_I_DLIBE,SC5->C5_I_HLIBE,"Ja foi Aprovado por "+SC5->C5_I_ULIBB})
		ELSE
			_cOpcao:= "REJEITADO"
			AADD(_aAvaliacao,{SC5->C5_I_DLIBE,SC5->C5_I_HLIBE,"Ja foi Rejeitado por "+SC5->C5_I_ULIBB})
		ENDIF
		_cObs:=SC5->C5_I_MOTLB
		_lSoAprvador:=.T.

	ELSEIf _cTipRet == "CREDITO" //.AND. !SC5->C5_I_BLCRE $ "L,R"

		//Se o cliente est� bloqueado faz o desbloqueio
		If _cOpcao == "APROVADO"
			If SA1->A1_MSBLQL == "1"
				RecLock("SA1", .F.)
				SA1->A1_MSBLQL := "2"
				SA1->A1_I_ACRED := SA1->A1_I_ACRED +  CHR(13)+CHR(10) + "Desbloqueado via workflow de libera��o de cr�dito do pedido " + SC5->C5_NUM + " em " + dtoc(date()) + " por " + AllTrim(UsrFullName(__cUserId))
				MsUnLock()
			EndIf

			//Se a data do limite de cr�dito est� vencida atualiza at� o dia atual
			_npos := SA1->(Recno())
			_ccodcli := SA1->A1_COD
			SA1->(Dbsetorder(1))

			If SA1->(Dbseek(xfilial("SA1")+_ccodcli))

				Do while SA1->A1_FILIAL == xfilial("SA1") .AND. SA1->A1_COD == _ccodcli

					If SA1->A1_VENCLC < DATE()

						RecLock("SA1", .F.)
						SA1->A1_VENCLC := DATE()
						SA1->A1_I_ACRED := SA1->A1_I_ACRED +  CHR(13)+CHR(10) + "Data de vencimento atualizada via  workflow de libera��o de cr�dito do pedido "
						SA1->A1_I_ACRED := SA1->A1_I_ACRED + SC5->C5_NUM + " em " + dtoc(date()) + " por " + AllTrim(Eval(_bUserN,__cUserId))
						MsUnLock()

					Endif

					SA1->(Dbskip())

				Enddo

			Endif

			SA1->(Dbgoto(_npos))

		EndIf

		IF SC5->C5_I_BLCRE = "L"
			AADD(_aAvaliacao,{SC5->C5_I_DTLIC,SC5->C5_I_LIBCT,"Ja foi Aprovado por "+SC5->C5_I_LIBCA})
			_cOpcao:= "APROVADO"
			_cObs:=SC5->C5_I_MOTBL
			_lSoAprvador:=.T.
		EndIF
		IF SC5->C5_I_BLCRE = "R"
			AADD(_aAvaliacao,{SC5->C5_I_DTLIC,SC5->C5_I_LIBCT,"Ja foi Rejeitado por "+SC5->C5_I_LIBCA})
			_cOpcao:= "REJEITADO"
			_cObs:=SC5->C5_I_MOTBL
			_lSoAprvador:=.T.
		ENDIF

		If SC5->C5_I_BLCRE = "B"

			dbSelectArea("TRBZY0")
			TRBZY0->(dbGoTop())

			While !TRBZY0->(Eof())

				If TRBZY0->ZY0_TIPO == "C" .And. SC5->C5_I_BLCRE == "B"
					_cTipo := "CREDITO"
					If _cOpcao == "APROVADO"
						SC5->(RecLock("SC5",.F.))

						SC5->C5_I_BLCRE := "L"
						SC5->C5_I_LIBCD := Date()
						SC5->C5_I_LIBCA := Eval(_bUserN,_cCodApr)//UsrRetName(_cCodApr)
						SC5->C5_I_LIBCT := Time()
						SC5->C5_I_LIBCV := MOMS030VT2( _cNumPV , _cFilial, ,3)
						SC5->C5_I_LIBL  := Date() + 7
						SC5->C5_I_LIBC  := 2
						SC5->C5_I_DTLIC	:= Date()
						SC5->C5_I_MOTBL := _cObs

						If SC5->C5_I_TRCNF = "N"
							SC5->C5_I_STATU = "01"
						Else
							If SC5->C5_I_FLFNC <> SC5->C5_FILIAL
								SC5->C5_I_STATU = "14"	//PEDIDO FATURAMENTO
							Else
								SC5->C5_I_STATU = "12"	//PEDIDO CARREGAMENTO
							EndIf
						EndIf

						SC5->( MsUnlock() )


						//Faz libera��o da SC9 se existir
						Dbselectarea("SC9")
						SC9->( DbSetorder(1) )


						If SC9->( DbSeek( _cFilial + _cNumPV ) )


							Do while SC9->C9_FILIAL = _cFilial .and. SC9->C9_PEDIDO = _cNumPV


								If !(empty(SC9->C9_BLCRED))

									RecLock("SC9",.F.)

									SC9->C9_BLCRED := " "

									MsUnlock("SC9")

									//Faz an�lise e libera��o de estoque pois o padr�o n�o analisa estoque se o cr�dito est� bloqueado
									//Posiciona SC6 pois a fun��o A440VerSb2 depende do SC6 posicionado para analisar o estoque
									Dbselectarea("SC6")
									SC6->(DbSetorder(1))

									If SC6->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM)) .AND. A440VerSB2(SC9->C9_QTDLIB)

										If !(empty(SC9->C9_BLEST))

											RecLock("SC9",.F.)

											SC9->C9_BLEST := ""
											If !(MaAvalSC9("SC9",5,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}}))

												SC9->C9_BLEST := "02"

											Endif

											MsUnlock("SC9")

										Endif


									Endif

								Endif

								SC9->( Dbskip() )

							Enddo

						Endif

					Else
						SC5->(RecLock("SC5",.F.))

						SC5->C5_I_BLCRE := "R"
						SC5->C5_I_LIBCA := Eval(_bUserN,_cCodApr)//UsrRetName(_cCodApr)
						SC5->C5_I_DTLIC := date()
						SC5->C5_I_LIBCT := Time()
						SC5->C5_I_MOTBL := IF(EMPTY(_cObs),"Rejeitado",_cObs)
						SC5->C5_I_STATU = "11"

						SC5->( MsUnlock() )
					EndIf
				EndIf
				TRBZY0->(dbSkip())
			End
		EndIF
	ElseIf _cTipRet == "PRECO" //.AND. !SC5->C5_I_BLPRC $ "L,R"

		dbSelectArea("TRBZY0")
		TRBZY0->(dbGoTop())

		While !TRBZY0->(Eof())

			If TRBZY0->ZY0_TIPO == "P" .And. SC5->C5_I_BLPRC == "B"

				_cTipo := "PRECO"
				If _cOpcao == "APROVADO"
					SC5->(RecLock("SC5",.F.))

					SC5->C5_I_BLPRC := "L"
					SC5->C5_I_VLIBP := MOMS030VT2(_cNumPV , _cFilial, , 3)	//Soma do C6_PRCVEN
					SC5->C5_I_QLIBP := MOMS030QT2(_cNumPV , _cFilial)	//Soma do C6_QTDVEN
					SC5->C5_I_LLIBP := SC5->C5_LOJAENT
					SC5->C5_I_CLILP := SC5->C5_CLIENT
					SC5->C5_I_MOTLP := _cObs
					SC5->C5_I_DTLIP	:= Date()
					SC5->C5_I_HLIBP	:= Time()
					SC5->C5_I_ULIBP	:= Eval(_bUserN,_cCodApr)//U_UCFG001(2)
					SC5->C5_I_PLIBP := (Date() + 30)
					SC5->C5_I_MLIBP	:= U_UCFG001(1)
					SC5->C5_I_STATU := "01"

					U_MOMS030C6(_cFilial, _cNumPV, _cCodApr, "P", _cObs, "L")

					SC5->( MsUnlock() )
				Else
					SC5->(RecLock("SC5",.F.))

					SC5->C5_I_BLPRC := "R"
					SC5->C5_I_DTLIB := date()
					SC5->C5_I_ULIBP := _bUserN(_bUserN,_cCodApr)//U_UCFG001(2)
					SC5->C5_I_MLIBP := U_UCFG001(1)
					SC5->C5_I_HLIBP := TIME()
					SC5->C5_I_MOTLP := _cObs
					SC5->C5_I_STATU := "09"

					U_MOMS030C6(_cFilial, _cNumPV, _cCodApr, "P", _cObs, "R")

					SC5->( MsUnlock() )
				EndIf
			EndIf
			TRBZY0->(dbSkip())
		End

	ElseIf _cTipRet == "BONIFICACAO" //.AND. !SC5->C5_I_BLOQ $ "L,R"

		dbSelectArea("TRBZY0")
		TRBZY0->(dbGoTop())

		While !TRBZY0->(Eof())

			If TRBZY0->ZY0_TIPO == "B" .And. SC5->C5_I_BLOQ	== "B"

				_cTipo := "BONIFICACAO"
				If _cOpcao == "APROVADO"
					SC5->(RecLock("SC5",.F.))

					SC5->C5_I_BLOQ	:= "L"
					SC5->C5_I_VLIBB := MOMS030VT2(_cNumPV , _cFilial, ,3)	//Soma do C6_PRCVEN
					SC5->C5_I_QLIBB := MOMS030QT2(_cNumPV , _cFilial)	//Soma do C6_QTDVEN
					SC5->C5_I_LLIBB := SC5->C5_LOJAENT
					SC5->C5_I_CLILB := SC5->C5_CLIENT
					SC5->C5_I_MOTLB := _cObs
					SC5->C5_I_DLIBE	:= Date()
					SC5->C5_I_HLIBE	:= Time()
					SC5->C5_I_ULIBB	:= Eval(_bUserN,_cCodApr)//U_UCFG001(1)
					SC5->C5_I_MTBON	:= U_UCFG001(1)

					U_MOMS030C6(_cFilial, _cNumPV, _cCodApr, "B", _cObs)

					SC5->( MsUnlock() )
				Else

					Do Case
					Case SC5->C5_TPFRETE = "F"
						_cObs := "BLOQUEIO FRETE FOB"
					Case SC5->C5_I_OPER = '10'
						_cObs := "BLOQUEIO DE BONIFICACAO"
					Case SC5->C5_I_OPER = '24'
						_cObs := "BLOQUEIO DATA CRITICA"
					Case SC5->C5_I_OPER = '05'
						_cObs := "BLOQUEIO OPERACAO TRIANGULAR"
					Otherwise
						_cObs := "BLOQUEIO INEXISTENTE"
					EndCase

					SC5->(RecLock("SC5",.F.))

					SC5->C5_I_BLOQ	:= "R"
					SC5->C5_I_VLIBB := MOMS030VT2(_cNumPV , _cFilial, ,3 )	//Soma do C6_PRCVEN
					SC5->C5_I_QLIBB := MOMS030QT2(_cNumPV , _cFilial)	//Soma do C6_QTDVEN
					SC5->C5_I_LLIBB := SC5->C5_LOJAENT
					SC5->C5_I_CLILB := SC5->C5_CLIENT
					SC5->C5_I_MOTLB := _cObs
					SC5->C5_I_DLIBE	:= Date()
					SC5->C5_I_HLIBE	:= Time()
					SC5->C5_I_ULIBB	:= Eval(_bUserN,_cCodApr)//U_UCFG001(1)
					SC5->C5_I_MTBON	:= U_UCFG001(1)

					U_MOMS030C6(_cFilial, _cNumPV, _cCodApr, "B", _cObs)

					SC5->( MsUnlock() )
				EndIf
			EndIf
			TRBZY0->(dbSkip())
		End
	EndIf

	dbSelectArea("TRBZY0")
	TRBZY0->(dbCloseArea())

	__cUserId := _cUsrBkp

//==================================================
//Finalize a tarefa anterior para n�o ficar pendente
//==================================================
	_oProcess:Finish()

//========================================================================================
//Faz a c�pia do arquivo de aprova��o para .old, e cria o arquivo de processo j� conclu�do
//========================================================================================
	If File("\workflow\emp01\" + _cArqHtm + ".htm")
		If __CopyFile("\workflow\emp01\" + _cArqHtm + ".htm", "\workflow\emp01\" + _cArqHtm + ".old")
			If __CopyFile(_cHtmlMode, "\workflow\emp01\" + _cArqHtm + ".htm")
				u_itconout("C�pia de arquivo de conclus�o efetuada com sucesso.")
			Else
				u_itconout("Problema na c�pia de arquivo de conclus�o.")
			EndIf
		Else
			u_itconout("N�o foi poss�vel renomear o arquivo " + _cArqHtm + ".htm.")
		EndIf
	EndIf

//==============================================================
//Envia e-mail ao Aprovadores e/ou Solicitante com o status do pedido
//==============================================================
	U_MOMS30ML(_cFilial, _cNumPV, _cOpcao, _cObs, _cCodApr, _cCodSol, _cTipo, _cCliente, _lSoAprvador, _aAvaliacao, cMailZY0)

//==============================================================
//Envia interface para o rdc com status do pedido
//==============================================================
	SC5->(dbSetOrder(1))

	If SC5->(dbSeek(_cFilial + _cNumPV))

		__CUSERID := _cCodApr
		U_ENVSITPV(,.F.)   //Envia interface de altera��o de situa��o do pedido atual

	Endif

Return

/*
===============================================================================================================================
Programa----------: MOMS030P
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 01/04/2016
===============================================================================================================================
Descri��o---------: Rotina respons�vel por montar o formul�rio de aprova��o e o envio do link gerado. (Libera��o Cr�dito)
===============================================================================================================================
Parametros--------: _cAliasSCR - Recebe o alias aberto das aprova��es dos pedidos de compras
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS030P(_cBlqCre, _lCliBlq, _cGetSol)

	Static _nValAtraso	:= 0
	Static _nValPed     := 0

	Local _cMailID		:= ""
	Local _cTaskID		:= ""
	Local _aArea		:= GetArea()
	Local _aAreaSC5		:= SC5->(GetArea())
	Local _cLogo		:= _cHostWF + "htm/logo_novo.jpg"
	Local _nMCusto		:= 0
	Local _cMailApr		:= ""
	Local _cCodiApr		:= ""
	Local _cNomeApr		:= ""
	Local _cMailSol		:= ""
	Local _cFilial		:= SC5->C5_FILIAL
	Local _nMCustoCli	:= 0
	Local _nLimCred		:= 0
	Local _nSalPed 		:= 0
	Local _nSalPedL		:= 0
	Local _nSalDupM		:= 0
	Local _nLcFin		:= 0
	Local _nSalFinM		:= 0
	Local _nSalDup		:= 0
	Local _nSalFin		:= 0
	Local _nMoeda		:= 0
//Local _nSalPed		:= 0
	Local _nRecnoSC5    := SC5->(Recno())
	Local _cMCusto		:= SuperGetMv("MV_MCUSTO")
	Local _aItens       := {}
	Local _aItens1       := {}
	Local _nItem        := 0
	Local _nItem1       := 0
	Local _nI			:= 0
	Local _lEnvSolic	:= .F.

	Local _cFilSol 		:= ""
	Local _cNumPVSol 	:= ""
	Local _cCodRep 		:= ""
	Local _cNomRep 		:= ""
	Local _cCodCoo 		:= ""
	Local _cNomCoo 		:= ""
	Local _cCodGer 		:= ""
	Local _cNomGer 		:= ""
	Local _cNumPV  		:= ""
	Local _cTipoPV 		:= ""
	Local _cFilPV  		:= ""
	Local _cEmisPV 		:= ""
	Local _cCondPG		:= ""
	Local _cCondPgPad 	:= ""
	Local _cRespPed 	:= ""
	Local _cNomCli 		:= ""
	Local _cNomRed 		:= ""
	Local _cCodCli 		:= ""
	Local _cLojCli 		:= ""
	Local _cCnpjCli 	:= ""
	Local _cGrpVen 		:= ""
	Local _cContatCli 	:= ""
	Local _cFoneCli 	:= ""
	Local _cEmailCli	:= ""
	Local _cCidCli 		:= ""
	Local _cEstCli	 	:= ""
	Local _cEndCli 		:= ""
	Local _cAnaCre 		:= ""
	Local _cnTitProt  	:= ""
	Local _cnChqDev		:= ""
	Local _cnMComp 		:= ""
	Local _cnMDuplic 	:= ""
	Local _cnMAtras  	:= ""
	Local _ccVenLCr  	:= ""
	Local _ccDtLiLib 	:= ""
	Local _cnAtraAtu 	:= ""
	Local _cnLimCrl 	:= ""
	Local _cnSldHist 	:= ""
	Local _cnLimcSec 	:= ""
	Local _cn2LimcSec	:= ""
	Local _cnSldLcSe 	:= ""
	Local _cnMaiCom 	:= ""
	Local _cnMaiCom2 	:= ""
	Local _cnMaiSld 	:= ""
	Local _ccPriCom 	:= ""
	Local _ccUltCom 	:= ""
	Local _cnMaiAtr 	:= ""
	Local _cnMedAtr 	:= ""
	Local _ccGrauRis 	:= ""
	Local _ccFrete 		:= ""
	Local _ccTpCarga 	:= ""
	Local _cnQtdChap 	:= ""
	Local _ccHrDescg 	:= ""
	Local _cnCusCarg 	:= ""
	Local _cdDtEntrega 	:= ""
	Local _ccHrEntrega 	:= ""
	Local _ccSenhaEntr 	:= ""
	Local _ccTpOper 	:= ""
	Local _ccMensNF 	:= ""
	Local _ccObsPed 	:= ""
	Local _cA_FILIAL 	:= ""
	Local _cA_PEDVEN 	:= ""
	Local _cA_NOMREP 	:= ""
	Local _cA_CLIENTE 	:= ""
	Local _cA_LIMCRED 	:= ""
	Local _cA_VLRPED  	:= ""
	Local _cA_TITPRO 	:= ""
	Local _cA_MCOMP 	:= ""
	Local _cA_MDUPL 	:= ""
	Local _cA_VLCRED 	:= ""
	Local _cA_DTLIMLB 	:= ""
	Local _cA_PCOMP 	:= ""
	Local _cA_UCOMP 	:= ""
	Local _cA_GRISC		:= ""
	Local _cA_RODAP     := ""
	Local _cMenBlq		:= ""
	Local _cBloq 		:= ""
	Local _ccObsAval	:= ""


//Codigo do processo cadastrado no CFG
	_cCodProce := "LIBPVC"
// Arquivo html template utilizado para montagem da aprova��o
	_cHtmlMode := "\Workflow\htm\libpv_credito.htm"

	If _cBlqCre == "B" .And. _lCliBlq
		// Assunto da mensagem
		_cAssunto := "Solicita��o de Libera��o de Cr�dito " + SC5->C5_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1)) + " - PV N�mero: " + SUBSTR(SC5->C5_NUM,1,6) + " Solicita��o de Desbloqueio do Cliente " + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + " - " + Posicione("SA1",1,xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A1_NREDUZ")
	ElseIf _cBlqCre <> "B" .And. _lCliBlq
		// Assunto da mensagem
		_cAssunto := "Solicita��o de Desbloqueio do Cliente " + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + " - " + Posicione("SA1",1,xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A1_NREDUZ")
	ElseIf _cBlqCre == "B" .And. !_lCliBlq
		// Assunto da mensagem
		_cAssunto := "Solicita��o de Libera��o de Cr�dito " + SC5->C5_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1)) + " - PV N�mero: " + SUBSTR(SC5->C5_NUM,1,6)
	EndIf

	For _nI := 1 to Len(_aAprCredito)

		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		_oProcess := TWFProcess():New(_cCodProce,"Libera��o de Cr�dito Pedido de Vendas")
		_oProcess:NewTask("Liberacao_PVC", _cHtmlMode)

		//Garante posicionamento do SC5 ap�s cria��o do processo de workflow
		//SC5->(Dbsetorder(1))
		//SC5->(Dbseek(_cfilial+_cpedido))

		SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

		//==========================
		//Pega os dados do aprovador
		//==========================
		_cCodiApr	:= _aAprCredito[_nI,1]//TRBZY0->ZY0_CODUSR
		_cNomeApr	:= _aAprCredito[_nI,2]//AllTrim(TRBZY0->ZY0_NOMINT)
		_cMailApr	:= _aAprCredito[_nI,3]//AllTrim(UsrRetMail(TRBZY0->ZY0_CODUSR)) + ";" + TRBZY0->ZY0_EMAIL

		If _nI = 1

			//====================
			//Dados do Solicitante
			//====================
			If Empty(__cUserId) .And. IsInCallStack("U_LIBERAP") // No WebService, a vari�vel __cUserID fica vazia. Ent�o o e-mail do solicitante � lido a partir do c�digo do usu�rio do XML de integra��o.
				If Type("_cEmailZZL") == "C"
					__cUserId := _cCodUsuario
				EndIf
			EndIf

			_cFilSol 	:= SC5->C5_FILIAL + ' - ' + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1))
			_cNumPVSol 	:= SUBSTR(SC5->C5_NUM,1,6)
			_cCodRep 	:= SC5->C5_VEND1
			_cNomRep 	:= AllTrim(SC5->C5_I_V1NOM)
			_cCodCoo 	:= SC5->C5_VEND2
			_cNomCoo 	:= AllTrim(SC5->C5_I_V2NOM)
			_cCodGer 	:= SC5->C5_VEND3
			_cNomGer 	:= AllTrim(SC5->C5_I_V3NOM)
			_cNumPV  	:= SC5->C5_NUM

			Do Case
			Case SC5->C5_TIPO == "N"
				_cTipoPV := "Normal"
			Case SC5->C5_TIPO == "C"
				_cTipoPV := "Compl.Pre�o/Quantidade"
			Case SC5->C5_TIPO == "I"
				_cTipoPV := "Compl.ICMS"
			Case SC5->C5_TIPO == "P"
				_cTipoPV := "Compl.IPI"
			Case SC5->C5_TIPO == "D"
				_cTipoPV := "Dev.Compras"
			Case SC5->C5_TIPO == "B"
				_cTipoPV := "Utiliza Fornecedor"
			EndCase

			_cFilPV  := SC5->C5_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1))
			_cEmisPV := DtoC(SC5->C5_EMISSAO)

			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4") + SC5->C5_CONDPAG)
			_cCondPG := SE4->E4_CODIGO + " - " + SE4->E4_DESCRI

			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4") + SA1->A1_COND)
			_cCondPgPad := SE4->E4_CODIGO + " - " + SE4->E4_DESCRI
			_cRespPed 	:= Posicione("SRA",1,SC5->C5_I_CDUSU,"RA_NOME")

			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

			_cNomCli 	:= SA1->A1_NOME
			_cNomRed 	:= SA1->A1_NREDUZ
			_cCodCli 	:= SA1->A1_COD
			_cLojCli 	:= SA1->A1_LOJA
			_cCnpjCli 	:= MOMS030CPF(SA1->A1_CGC)
			_cGrpVen 	:= SA1->A1_GRPVEN + " - " + Posicione("ACY",1,xFilial("ACY") + SA1->A1_GRPVEN, "ACY_DESCRI")
			_cContatCli := SA1->A1_CONTATO
			_cFoneCli 	:= SA1->A1_TEL
			_cEmailCli 	:= SA1->A1_EMAIL
			_cCidCli 	:= SA1->A1_MUN
			_cEstCli 	:= SA1->A1_EST
			_cEndCli 	:= SA1->A1_END
			_cAnaCre 	:= SA1->A1_I_ACRED

			If SA1->A1_MSBLQL == "2"
				_cBloq := "N�O"
			ElseIf SA1->A1_MSBLQL == "1"
				_cBloq := "SIM"
				_cMenBlq := " - APROVANDO ESTE PEDIDO, O CLIENTE SER� AUTOMATICAMENTE DESBLOQUEADO."
			Else
				_cBloq := ""
			EndIf

			//========================
			//Informar��es Financeiras
			//========================
			DBSelectArea("SA1")
			SA1->( DBSetOrder(1) )
			SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE ) )

			While SA1->(!Eof()) .And. SA1->A1_COD == SC5->C5_CLIENTE

				_nMCustoCli	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC	, Val(_cMCusto) )
				_nLimCred	+= xMoeda( SA1->A1_LC							, _nMCustoCli , _nMCusto , Date() )
				_nSalPed 	+= xMoeda( SA1->A1_SALPED + SA1->A1_SALPEDB		, _nMCustoCli , _nMCusto , Date() )
				_nSalPedL	+= xMoeda( SA1->A1_SALPEDL						, _nMCustoCli , _nMCusto , Date() )
				_nSalDupM	+= xMoeda( SA1->A1_SALDUPM						, _nMCustoCli , _nMCusto , Date() )
				_nLcFin		+= xMoeda( SA1->A1_LCFIN						, _nMCustoCli , _nMCusto , Date() )
				_nSalFinM	+= xMoeda( SA1->A1_SALFINM						, _nMCustoCli , _nMCusto , Date() )
				_nSalDup	+= SA1->A1_SALDUP
				_nSalFin	+= SA1->A1_SALFIN

				SA1->( DBSkip() )
			EndDo

			DBSelectArea("SA1")
			SA1->( DBSetOrder(1) )
			SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )

			_nMCusto 	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC , VAL( SuperGetMv("MV_MCUSTO") ) )
			_nMoeda		:= 1

			_nValAtraso	:= MOMS030VSC( SC5->C5_CLIENTE )
			_nValPed	:= MOMS030VT2( SC5->C5_NUM , SC5->C5_FILIAL , 1 )

			_cnTitProt  := STR(SA1->A1_TITPROT,3)
			_cnChqDev	:= STR(SA1->A1_CHQDEVO,3)
			_cnMComp 	:= Transform(SA1->A1_MCOMPRA ,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto))
			_cnMDuplic 	:= Transform(SA1->A1_MAIDUPL ,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto))
			_cnMAtras  	:= Transform(SA1->A1_METR ,PesqPict("SA1","A1_METR",7))
			_ccVenLCr  	:= DtoC(SA1->A1_VENCLC)
			_ccDtLiLib 	:= DtoC(StoD(""))
			_cnAtraAtu 	:= TRansform(_nValAtraso ,PesqPict("SA1","A1_SALDUP",17,1))

			_cnLimCrl 	:= TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",14,_nMCusto))
			_cnSldHist 	:= TRansform(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP",14,1))
			_cnLimcSec 	:= TRansform(Round(Noround(xMoeda(SA1->A1_LCFIN,_nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1))
			_cn2LimcSec	:= TRansform(SA1->A1_LCFIN,PesqPict("SA1","A1_LCFIN",14,_nMcusto))
			_cnSldLcSe 	:= TRansform(SA1->A1_SALFIN,PesqPict("SA1","A1_SALFIN",14,1))
			_cnMaiCom 	:= TRansform(Round(Noround(xMoeda(SA1->A1_MCOMPRA, _nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1))
			_cnMaiCom2 	:= TRansform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,_nMcusto))
			_cnMaiSld 	:= TRansform(Round(Noround(xMoeda(SA1->A1_MSALDO, _nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1))
			_ccPriCom 	:= DtoC(SA1->A1_PRICOM)
			_ccUltCom 	:= DtoC(SA1->A1_ULTCOM)
			_cnMaiAtr 	:= Transform(SA1->A1_MATR,PesqPict("SA1","A1_MATR",14))
			_cnMedAtr 	:= PADC(STR(SA1->A1_METR,7,2),22)
			_ccGrauRis 	:= SA1->A1_RISCO

			Do Case
			Case SC5->C5_TPFRETE == "C"
				_ccFrete := "CIF"
			Case SC5->C5_TPFRETE == "F"
				_ccFrete := "FOB"
			Case SC5->C5_TPFRETE == "T"
				_ccFrete := "TERCEIROS"
			Case SC5->C5_TPFRETE == "S"
				_ccFrete := "Sem Frete"
			EndCase

			_ccTpCarga 	:= Iif(SC5->C5_I_TIPCA == "1", SC5->C5_I_TIPCA + " - Paletizada", Iif(SC5->C5_I_TIPCA == "2", SC5->C5_I_TIPCA + " - Batida", ""))
			_cnQtdChap 	:= SC5->C5_I_CHAPA
			_ccHrDescg 	:= SC5->C5_I_HORDE
			_cnCusCarg 	:= "0"
			_cdDtEntrega := SC5->C5_I_DTENT
			_ccHrEntrega := SC5->C5_I_HOREN
			_ccSenhaEntr := SC5->C5_I_SENHA

			dbSelectArea("ZB4")
			dbSetOrder(1)
			dbSeek(xFilial("ZB4") + SC5->C5_I_OPER)
			_ccTpOper := SC5->C5_I_OPER + " - " + ZB4->ZB4_DESCRI
			_ccMensNF := SC5->C5_MENNOTA
			_ccObsPed := SC5->C5_I_OBPED

			If _cBlqCre == "B" .And. _lCliBlq
				_ccObsAval := SC5->C5_I_MOTBL + " / CLIENTE BLOQUEADO"
			ElseIf _cBlqCre <> "B" .And. _lCliBlq
				_ccObsAval := "CLIENTE BLOQUEADO"
			ElseIf _cBlqCre == "B" .And. !_lCliBlq
				_ccObsAval :=  SC5->C5_I_MOTBL
			EndIf

			//=========================================
			//Informa��es dos itens do Pedido de Vendas
			//=========================================
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(SC5->C5_FILIAL + SC5->C5_NUM)
			While !SC6->(Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM

				aAdd(_aItens,{SC6->C6_ITEM,;
					SC6->C6_PRODUTO,;
					AllTrim(SC6->C6_DESCRI),;
					SC6->C6_PEDCLI,;
					Transform(SC6->C6_PRCVEN, "@E 999,999,999.999"),;
					Transform(SC6->C6_UNSVEN, PesqPict("SC6","C6_UNSVEN")),;
					SC6->C6_SEGUM,;
					Transform(SC6->C6_VALOR, PesqPict("SC6","C6_VALOR")),;
					Transform(SC6->C6_VALOR - SC6->C6_VALDESC, PesqPict("SC6","C6_VALOR")) })

				SC6->(dbSkip())
			End

			//=================================
			//Informa��es dos T�tulos em Aberto
			//=================================
			cQrySE1 := "SELECT E1_LOJA, E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_EMISSAO, E1_VENCTO, E1_BAIXA, E1_VENCREA, E1_MOEDA, E1_VALOR, E1_VLCRUZ, E1_SDACRES, E1_SDDECRE, E1_VALJUR, E1_MULTA, E1_JUROS, E1_SALDO, E1_NATUREZ, E1_PORTADO, E1_NUMBCO, E1_NUMLIQ, E1_HIST, E1_SITUACA, SE1.R_E_C_N_O_ SE1RECNO "
			cQrySE1 += ", SX5.X5_DESCRI "
			cQrySE1 += "FROM "+RetSqlName("SE1")+" SE1,"
			cQrySE1 +=         RetSqlName("SX5")+" SX5 "
			cQrySE1 += "WHERE SE1.E1_CLIENTE = '"+SC5->C5_CLIENTE+"' AND "
			cQrySE1 +=       "SE1.E1_EMISSAO >= ' ' AND "
			cQrySE1 +=       "SE1.E1_EMISSAO <= 'Z' AND "
			cQrySE1 +=       "SE1.E1_VENCREA >= ' ' AND "
			cQrySE1 +=       "SE1.E1_VENCREA <= 'Z' AND "
			cQrySE1 += "SE1.E1_TIPO <> 'PR ' AND "
			cQrySE1 += "SE1.E1_PREFIXO >= '" + Space(TamSX3("E1_PREFIXO")[1]) + "' AND "
			cQrySE1 += "SE1.E1_PREFIXO <= '" + Replicate("Z",TamSX3("E1_PREFIXO")[1]) + "' AND "
			cQrySE1 += "SE1.E1_SALDO > 0 AND "
			cQrySE1 += "SE1.D_E_L_E_T_ = ' ' AND "
			cQrySE1 += "SX5.X5_FILIAL = '" +xFilial("SX5") + "' AND "
			cQrySE1 += "SX5.X5_TABELA = '07' AND "
			cQrySE1 += "SX5.X5_CHAVE = SE1.E1_SITUACA AND "
			cQrySE1 += "SX5.D_E_L_E_T_ = ' ' "

			cQrySE1 += "AND SE1.E1_TIPO NOT LIKE '__-' UNION ALL " + cQrySE1
			cQrySE1 += "AND SE1.E1_TIPO LIKE '__-' "
			cQrySE1 += "ORDER BY E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,SE1RECNO"

			If Select("TRBSE1") > 0
				TRBSE1->(DbCloseArea())
			EndIf
			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, cQrySE1 ) , "TRBSE1" , .T., .F. )

			dbSelectArea("TRBSE1")
			TRBSE1->(dbGoTop())
			Do While !TRBSE1->(Eof())
				aAdd(_aItens1,{TRBSE1->E1_FILORIG,;
					TRBSE1->E1_PREFIXO,;
					TRBSE1->E1_NUM,;
					TRBSE1->E1_PARCELA,;
					TRBSE1->E1_TIPO,;
					DtoC(StoD(TRBSE1->E1_EMISSAO)),;
					DtoC(StoD(TRBSE1->E1_VENCTO)),;
					DtoC(StoD(TRBSE1->E1_VENCREA)),;
					Transform(TRBSE1->E1_VALOR, PesqPict("SE1","E1_VALOR")),;
					Transform(TRBSE1->E1_SALDO, PesqPict("SE1","E1_SALDO")),;
					TRBSE1->E1_NATUREZ,;
					TRBSE1->E1_PORTADO,;
					TRBSE1->E1_NUMBCO,;
					AllTrim(TRBSE1->E1_HIST),;
					Str(dDataBase - StoD(TRBSE1->E1_VENCTO),6) })


				TRBSE1->(dbSkip())
			EndDo

			dbSelectArea("TRBSE1")
			TRBSE1->(dbCloseArea())

		EndIf

		//======================================
		//Dados do cabe�alho do pedido de vendas
		//======================================
		_oProcess:oHtml:ValByName("cLogo"		, _cLogo							)
		_oProcess:oHtml:ValByName("cCodSol"		, __cUserId							)
		_oProcess:oHtml:ValByName("cNomSol"		, AllTrim(UsrFullName(__cUserId))	)
		_oProcess:oHtml:ValByName("cMaiSol"		, AllTrim(U_UCFG001(3))				) //UsrRetMail(__cUserId)))
		_oProcess:oHtml:ValByName("cFilSol"		, _cFilSol							)
		_oProcess:oHtml:ValByName("cNumPVSol"	, _cNumPVSol						)
		_oProcess:oHtml:ValByName("cDtAtu"		, DtoC(Date()) + " - " + Time()		)
		_oProcess:oHtml:ValByName("cTipOper"	, "CREDITO"							)

		//==================
		//Dados do Aprovador
		//==================
		_oProcess:oHtml:ValByName("cCodApr"		, _cCodiApr	)
		_oProcess:oHtml:ValByName("cNomApr"		, _cNomeApr	)

		//======================
		//Dados do Representante
		//======================
		_oProcess:oHtml:ValByName("cCodRep"		, _cCodRep	)
		_oProcess:oHtml:ValByName("cNomRep"		, _cNomRep	)

		//====================
		//Dados do Coordenador
		//====================
		_oProcess:oHtml:ValByName("cCodCoo"		, _cCodCoo	)
		_oProcess:oHtml:ValByName("cNomCoo"		, _cNomCoo	)

		//================
		//Dados do Gerente
		//================
		_oProcess:oHtml:ValByName("cCodGer"		, _cCodGer )
		_oProcess:oHtml:ValByName("cNomGer"		, _cNomGer )

		//===============
		//Dados do Pedido
		//===============
		_oProcess:oHtml:ValByName("cNumPV"		, _cNumPV	)
		_oProcess:oHtml:ValByName("cTipoPV"		, _cTipoPV	)
		_oProcess:oHtml:ValByName("cFilPV"		, _cFilPV	)
		_oProcess:oHtml:ValByName("cEmisPV"		, _cEmisPV	)

		_oProcess:oHtml:ValByName("cCondPG"		, _cCondPG	)
		_oProcess:oHtml:ValByName("cCondPgPad"	, _cCondPgPad	)
		_oProcess:oHtml:ValByName("cRespPed"	, _cRespPed		)

		//================
		//Dados do Cliente
		//================
		_oProcess:oHtml:ValByName("cNomCli"			, _cNomCli	)
		_oProcess:oHtml:ValByName("cNomRed"			, _cNomRed	)
		_oProcess:oHtml:ValByName("cCodCli"			, _cCodCli	)
		_oProcess:oHtml:ValByName("cLojCli"			, _cLojCli	)
		_oProcess:oHtml:ValByName("cCnpjCli"		, _cCnpjCli	)
		_oProcess:oHtml:ValByName("cGrpVen"			, _cGrpVen	)
		_oProcess:oHtml:ValByName("cContatCli"		, _cContatCli)
		_oProcess:oHtml:ValByName("cFoneCli"		, _cFoneCli	)
		_oProcess:oHtml:ValByName("cEmailCli"		, _cEmailCli)
		_oProcess:oHtml:ValByName("cCidCli"			, _cCidCli	)
		_oProcess:oHtml:ValByName("cEstCli"			, _cEstCli	)
		_oProcess:oHtml:ValByName("cEndCli"			, _cEndCli	)
		_oProcess:oHtml:ValByName("cAnaCre"			, _cAnaCre	)
		_oProcess:oHtml:ValByName("cBloq"			, _cBloq	)
		_oProcess:oHtml:ValByName("cMenBlq"			, _cMenBlq	)

		//========================
		//Informar��es Financeiras
		//========================
		_oProcess:oHtml:ValByName("nLimCrd"			, TRansform(_nLimCred,PesqPict("SA1","A1_LC",17,1)))
		_oProcess:oHtml:ValByName("nTitAber"		, TRansform(_nSalDup,PesqPict("SA1","A1_SALDUP",17,1)))
		_oProcess:oHtml:ValByName("nTitVenc"		, TRansform(_nSalPedL,PesqPict("SA1","A1_SALPEDL",17,1)))
		_oProcess:oHtml:ValByName("nSLimCrd"		, TRansform(_nLimCred-_nSaldupM-_nSalPedL,PesqPict("SA1","A1_SALDUP",17,1)))
		_oProcess:oHtml:ValByName("nPedAtu"			, TRansform(_nValPed ,PesqPict("SA1","A1_SALDUP",17,1)))
		_oProcess:oHtml:ValByName("nSalNFat"		, TRansform(_nSalPed ,PesqPict("SA1","A1_SALPED",17,1)))
		_oProcess:oHtml:ValByName("nLimCChe"		, TRansform(_nLcFin ,PesqPict("SA1","A1_LCFIN",17,1)))
		_oProcess:oHtml:ValByName("nSldChq"			, TRansform(_nSalFin ,PesqPict("SA1","A1_SALDUP",17,1)))

		_oProcess:oHtml:ValByName("nTitProt"		, _cnTitProt)
		_oProcess:oHtml:ValByName("nChqDev"			, _cnChqDev)
		_oProcess:oHtml:ValByName("nMComp"			, _cnMComp)
		_oProcess:oHtml:ValByName("nMDuplic"		, _cnMDuplic)
		_oProcess:oHtml:ValByName("nMAtras"			, _cnMAtras)
		_oProcess:oHtml:ValByName("cVenLCr"			, _ccVenLCr)
		_oProcess:oHtml:ValByName("cDtLiLib"		, _ccDtLiLib)
		_oProcess:oHtml:ValByName("nAtraAtu"		, _cnAtraAtu)

		//==================
		//Posi��o do Cliente
		//==================
		_oProcess:oHtml:ValByName("nLimCrl"			, _cnLimCrl					)
		_oProcess:oHtml:ValByName("nSldHist"		, _cnSldHist				)
		_oProcess:oHtml:ValByName("nLimcSec"		, _cnLimcSec, _cn2LimcSec 	)
		_oProcess:oHtml:ValByName("nSldLcSe"		, _cnSldLcSe				)
		_oProcess:oHtml:ValByName("nMaiCom"			, _cnMaiCom, _cnMaiCom2 	)
		_oProcess:oHtml:ValByName("nMaiSld"			, _cnMaiSld					)
		_oProcess:oHtml:ValByName("cPriCom"			, _ccPriCom					)
		_oProcess:oHtml:ValByName("cUltCom"			, _ccUltCom					)
		_oProcess:oHtml:ValByName("nMaiAtr"			, _cnMaiAtr					)
		_oProcess:oHtml:ValByName("nMedAtr"			, _cnMedAtr					)
		_oProcess:oHtml:ValByName("cGrauRis"		, _ccGrauRis				)

		//===============================
		//Informa��es do Pedido de Vendas
		//===============================
		_oProcess:oHtml:ValByName("cFrete"			, _ccFrete		)
		_oProcess:oHtml:ValByName("cTpCarga"		, _ccTpCarga	)
		_oProcess:oHtml:ValByName("nQtdChap"		, _cnQtdChap	)
		_oProcess:oHtml:ValByName("cHrDescg"		, _ccHrDescg	)
		_oProcess:oHtml:ValByName("nCusCarg"		, _cnCusCarg	)
		_oProcess:oHtml:ValByName("dDtEntrega"		, _cdDtEntrega	)
		_oProcess:oHtml:ValByName("cHrEntrega"		, _ccHrEntrega	)
		_oProcess:oHtml:ValByName("cSenhaEntr"		, _ccSenhaEntr	)
		_oProcess:oHtml:ValByName("cTpOper"			, _ccTpOper		)
		_oProcess:oHtml:ValByName("cMensNF"			, _ccMensNF		)
		_oProcess:oHtml:ValByName("cObsPed"			, _ccObsPed		)
		_oProcess:oHtml:ValByName("cObsAval"		, _ccObsAval	)

		//=========================================
		//Informa��es dos itens do Pedido de Vendas
		//=========================================
		For _nItem := 1 To Len(_aItens)

			aAdd( _oProcess:oHtml:ValByName("Itens.cItem" 			), _aItens[_nItem,01]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.cProdPV" 		), _aItens[_nItem,02]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.cDescPV"			), _aItens[_nItem,03]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.cNumPCli"		), _aItens[_nItem,04]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.nPrcVen"			), _aItens[_nItem,05]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.nQuantPV"		), _aItens[_nItem,06]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.cUM"				), _aItens[_nItem,07]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.nTotalPV"	   	), _aItens[_nItem,08]	)
			aAdd( _oProcess:oHtml:ValByName("Itens.nTotGer"			), _aItens[_nItem,09] 	)

		Next

		//=================================
		//Informa��es dos T�tulos em Aberto
		//=================================
		For _nItem1 := 1 To Len(_aItens1)

			aAdd( _oProcess:oHtml:ValByName("Itens1.FilOrig"	), _aItens1[_nItem1][01]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Pref" 		), _aItens1[_nItem1][02]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Num"		), _aItens1[_nItem1][03]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Parc"		), _aItens1[_nItem1][04]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Tipo"		), _aItens1[_nItem1][05]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Emissao"	), _aItens1[_nItem1][06]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Vencto"		), _aItens1[_nItem1][07]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.VencRea"   	), _aItens1[_nItem1][08]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.VlrTit"		), _aItens1[_nItem1][09]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.SldRec"		), _aItens1[_nItem1][10]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Natur"		), _aItens1[_nItem1][11]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Portad"		), _aItens1[_nItem1][12]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Banco"		), _aItens1[_nItem1][13]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Hist"   	), _aItens1[_nItem1][14]	)
			aAdd( _oProcess:oHtml:ValByName("Itens1.Atraso"		), _aItens1[_nItem1][15]	)

		Next

		If Len(_aItens1) = 0
			aAdd( _oProcess:oHtml:ValByName("Itens1.FilOrig"	), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Pref"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Num"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Parc"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Tipo"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Emissao"	), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Vencto"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.VencRea"	), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.VlrTit"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.SldRec"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Natur"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Portad"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Banco"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Hist"		), "" )
			aAdd( _oProcess:oHtml:ValByName("Itens1.Atraso"		), "" )
		EndIf

		_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol	)
		//=========================================================================
		// Informe o nome da fun��o de retorno a ser executada quando a mensagem de
		// respostas retornar ao Workflow:
		//=========================================================================
		_oProcess:bReturn := "U_MOMS030R"

		//========================================================================
		// Ap�s ter repassado todas as informac�es necess�rias para o Workflow,
		// execute o m�todo Start() para gerar todo o processo e enviar a mensagem
		// ao destinat�rio.
		//========================================================================
		_cMailID	:= _oProcess:Start("\workflow\emp01")
		_cLink		:= _cMailID

		If File("\workflow\emp01\" + _cMailID + ".htm")
			U_ITCONOUT("Arquivo \workflow\emp01\" + _cMailID + ".htm criado com sucesso.")
		ELSE
			U_ITCONOUT("Arquivo \workflow\emp01\" + _cMailID + ".htm n�o encotrado.")
		EndIf

		//====================================
		//Codigo do processo cadastrado no CFG
		//====================================
		_cCodProce := "LIBPVCRE"

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		//======================================================================
		_oProcess := TWFProcess():New(_cCodProce,"Libera��o PV Cr�dito")

		SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================
		_oProcess:NewTask("LINK", "\workflow\htm\pvcred_link.htm")

		_chtmlfile	:= _cLink + ".htm"
		_cMailTo	:= "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + AllTrim(GetMV('MV_WFMLBOX')), "WF7_ENDERE"))//Monta string a ser procurada
		U_ITCONOUT("Lendo Arquivo \workflow\emp01\" + _chtmlfile)
		_chtmltexto	:= wfloadfile("\workflow\emp01\" + _chtmlfile )      //Carrega o arquivo
		_chtmltexto	:= strtran( _chtmltexto, _cmailto, "WFHTTPRET.APL" ) //Procura e troca a string
		wfsavefile("\workflow\emp"+cEmpAnt+"\" + _chtmlfile, _chtmltexto)//Grava o arquivo de volta
		U_ITCONOUT("Gravou Arquivo \workflow\emp"+cEmpAnt+"\" + _chtmlfile)

		_cLink := _cHostWF + "emp01/" + _cLink + ".htm"


		If _nI = 1
			_cA_FILIAL 	:= _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1)
			_cA_PEDVEN 	:= SC5->C5_NUM
			_cA_NOMREP 	:= SC5->C5_VEND1 + " - " + AllTrim(SC5->C5_I_V1NOM)
			_cA_CLIENTE := SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME
			_cA_LIMCRED := TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1))
			_cA_VLRPED  := TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1))
			_cA_TITPRO 	:= STR(SA1->A1_TITPROT,3)
			_cA_MCOMP 	:= Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto))
			_cA_MDUPL 	:= Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto))
			_cA_VLCRED 	:= DtoC(SA1->A1_VENCLC)
			_cA_DTLIMLB := DtoC(StoD(""))
			_cA_PCOMP 	:= DtoC(SA1->A1_PRICOM)
			_cA_UCOMP 	:= DtoC(SA1->A1_ULTCOM)
			_cA_GRISC 	:= SA1->A1_RISCO
			_cA_RODAP   := GETENVSERVER()
		EndIf

		//=====================================
		// Populo as vari�veis do template html
		//=====================================
		_oProcess:oHtml:ValByName("cLogo"		, _cLogo		)
		_oProcess:oHtml:ValByName("A_FILIAL"	, _cA_FILIAL	)
		_oProcess:oHtml:ValByName("A_PEDVEN"	, _cA_PEDVEN	)
		_oProcess:oHtml:ValByName("A_LINK"		, _cLink		)
		_oProcess:oHtml:ValByName("A_NOMREP"	, _cA_NOMREP	)
		_oProcess:oHtml:ValByName("A_CLIENTE"	, _cA_CLIENTE	)
		_oProcess:oHtml:ValByName("A_LIMCRED"	, _cA_LIMCRED	)
		_oProcess:oHtml:ValByName("A_VLRPED"	, _cA_VLRPED	)
		_oProcess:oHtml:ValByName("A_TITPRO"	, _cA_TITPRO	)
		_oProcess:oHtml:ValByName("A_MCOMP"		, _cA_MCOMP		)
		_oProcess:oHtml:ValByName("A_MDUPL"		, _cA_MDUPL		)
		_oProcess:oHtml:ValByName("A_VLCRED"	, _cA_VLCRED	)
		_oProcess:oHtml:ValByName("A_DTLIMLB"	, _cA_DTLIMLB	)
		_oProcess:oHtml:ValByName("A_PCOMP"		, _cA_PCOMP		)
		_oProcess:oHtml:ValByName("A_UCOMP"		, _cA_UCOMP		)
		_oProcess:oHtml:ValByName("A_GRISC"		, _cA_GRISC		)
		_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol		)
		_oProcess:oHtml:ValByName("A_RODAP"		, _cA_RODAP		)

		//================================================================
		// Informamos o destinat�rio (aprovador) do email contendo o link.
		//================================================================
		_oProcess:cTo := _cMailApr

		//===============================
		// Informamos o assunto do email.
		//===============================
		_oProcess:cSubject	:= U_ITEncode(_cAssunto)

		_cMailID	:= _oProcess:fProcessId
		_cTaskID	:= _oProcess:fTaskID

		//=======================================================
		// Iniciamos a tarefa e enviamos o email ao destinat�rio.
		//=======================================================
		_oProcess:Start()

		u_itconout("Email enviado para o aprovador: " + _cMailApr + ", enviado com sucesso! Data: " + DtoC(dDataBase) + " hora: " + Time() + " Filial: " + SC5->C5_FILIAL + " Pedido: " + SC5->C5_NUM)

		DbSelectArea("SC5")
		RecLock("SC5", .F.)
		SC5->C5_I_DTUWF := Date()
		SC5->C5_I_HRUWF := Time()
		MsUnlock()

		_lEnvSolic	:= .T.

		//_cEmaisEnv	+= _aAprPreco[_nI,2] + "  E-mail: " + _aAprPreco[_nI,3] + CHR(13) + CHR(10)
		_cEmaisEnv	+= _aAprCredito[_nI,2] + "  E-mail: " + _aAprCredito[_nI,3] + CHR(13) + CHR(10)

		RestArea(_aArea)
		RestArea(_aAreaSC5)

	Next

//==========================================================
//Monta e faz o envio ao solicitante da aprova��o de Cr�dito
//==========================================================
	If _lEnvSolic

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		//======================================================================
		_oProcess := TWFProcess():New("LIBPVCRE","Libera��o PV Cr�dito - Solicitante")

		SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================
		_oProcess:NewTask("LINK", "\workflow\htm\pvcred_solic.htm")

		//=====================================
		// Populo as vari�veis do template html
		//=====================================
		_oProcess:oHtml:ValByName("cLogo"		, _cLogo)
		_oProcess:oHtml:ValByName("A_FILIAL"	    , _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1))
		_oProcess:oHtml:ValByName("A_PEDVEN"	    , SC5->C5_NUM)
		_oProcess:oHtml:ValByName("A_NOMREP"	    , SC5->C5_VEND1 + " - " + AllTrim(SC5->C5_I_V1NOM))
		_oProcess:oHtml:ValByName("A_CLIENTE"	, SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME)
		_oProcess:oHtml:ValByName("A_LIMCRED"	, TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1)))
		_oProcess:oHtml:ValByName("A_VLRPED"	    , TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1)))
		_oProcess:oHtml:ValByName("A_TITPRO"	    , STR(SA1->A1_TITPROT,3))
		_oProcess:oHtml:ValByName("A_MCOMP"		, Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto)))
		_oProcess:oHtml:ValByName("A_MDUPL"		, Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto)))
		_oProcess:oHtml:ValByName("A_VLCRED"	    , DtoC(SA1->A1_VENCLC))
		_oProcess:oHtml:ValByName("A_DTLIMLB"	, DtoC(StoD("")))
		_oProcess:oHtml:ValByName("A_PCOMP"		, DtoC(SA1->A1_PRICOM))
		_oProcess:oHtml:ValByName("A_UCOMP"		, DtoC(SA1->A1_ULTCOM))
		_oProcess:oHtml:ValByName("A_GRISC"		, SA1->A1_RISCO)
		_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol)
		_oProcess:oHtml:ValByName("Texto01"		, "Aprovadores:")//AWF-09/06/2016
		_oProcess:oHtml:ValByName("Texto02"		, _cAprCredito)
		_oProcess:oHtml:ValByName("A_RODAP"		, _cA_RODAP		)
		//================================================================
		// Informamos o destinat�rio (aprovador) do email contendo o link.
		//================================================================
		_cMailSol := AllTrim(U_UCFG001(3)) //UsrRetMail(__cUserID)

		If Empty(_cMailSol) .And. IsInCallStack("U_LIBERAP") // No WebService, a vari�vel __cUserID fica vazia. Ent�o o e-mail do solicitante � lido a partir do c�digo do usu�rio do XML de integra��o.
			If Type("_cEmailZZL") == "C"
				_cMailSol := _cEmailZZL
			EndIf
		EndIf

		_oProcess:cTo := _cMailSol

		//===============================
		// Informamos o assunto do email.
		//===============================
		_oProcess:cSubject	:= U_ITEncode(_cAssunto)

		_cMailID	:= _oProcess:fProcessId
		_cTaskID	:= _oProcess:fTaskID

		//=======================================================
		// Iniciamos a tarefa e enviamos o email ao destinat�rio.
		//=======================================================
		_oProcess:Start()

		u_itconout("Email enviado para o solicitante: " + _cMailSol + ", enviado com sucesso! Data: " + DtoC(dDataBase) + " hora: " + Time() + " Filial: " + SC5->C5_FILIAL + " Pedido: " + SC5->C5_NUM)

	EndIf

Return

/*
===============================================================================================================================
Programa----------: MOMS030CPF
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 14/01/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para formatar CPF/CNPJ
===============================================================================================================================
Parametros--------: cCPFCNPJ	- Texto a ser quebrado
===============================================================================================================================
Retorno-----------: cCampFormat	- Retorna o campo formatado conforme CPF/CNPJ
===============================================================================================================================
*/
Static Function MOMS030CPF(_cCPFCNPJ)
	Local _cCampFormat := ""	//Armazena o CPF ou CNPJ formatado

	If Len(AllTrim(_cCPFCNPJ)) == 11			//CPF
		_cCampFormat:=SubStr(_cCPFCNPJ,1,3) + "." + SubStr(_cCPFCNPJ,4,3) + "." + SubStr(_cCPFCNPJ,7,3) + "-" + SubStr(_cCPFCNPJ,10,2)
	Else									//CNPJ
		_cCampFormat:=Substr(_cCPFCNPJ,1,2)+"."+Substr(_cCPFCNPJ,3,3)+"."+Substr(_cCPFCNPJ,6,3)+"/"+Substr(_cCPFCNPJ,9,4)+"-"+ Substr(_cCPFCNPJ,13,2)
	EndIf

Return(_cCampFormat)

/*
===============================================================================================================================
Programa----------: MOMS030VSC
Autor-------------: Darcio Sporl
Data da Criacao---: 17/02/2014
===============================================================================================================================
Descri��o---------: Recupera saldo atual em aberto do Cliente.
===============================================================================================================================
Parametros--------: cCodCli := codigo do cliente. 
===============================================================================================================================
Retorno-----------: nValUso := valor em aberto do cliente.  
===============================================================================================================================
*/

Static Function MOMS030VSC( _cCodCli )

	Local _cAlias	:= GetNextAlias()
	Local _cQuery	:= ""
	Local _nValUso	:= 0

	Default _cCodCli	:= ""

//-- Verifica o saldo atual em aberto do Cliente --//
	_cQuery := " SELECT "
	_cQuery += "     SUM( SE1.E1_SALDO + SE1.E1_SDACRES - SE1.E1_SDDECRE ) AS VALUSO "
	_cQuery += " FROM "+ RetSqlName("SE1") +" SE1 "
	_cQuery += " WHERE "
	_cQuery += "     SE1.E1_CLIENTE	= '"+ _cCodCli +"' "
	_cQuery += " AND SE1.D_E_L_E_T_	= ' ' "
	_cQuery += " AND SE1.E1_TIPO		NOT IN ('RA','NCC') "
	_cQuery += " AND SE1.E1_SALDO + SE1.E1_SDACRES - SE1.E1_SDDECRE > 0 "

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->(!Eof()) .And. (_cAlias)->VALUSO > 0
		_nValUso := (_cAlias)->VALUSO
	EndIf

	(_cAlias)->( DBCloseArea() )

Return(_nValUso)

/*
===============================================================================================================================
Programa----------: MOMS030VT2
Autor-------------: Alexandre Villar
Data da Criacao---: 17/02/2014
===============================================================================================================================
Descri��o---------: Recupera valor total do pedido de vendas. 
===============================================================================================================================
Parametros--------: cCodCli := codigo do cliente. 
===============================================================================================================================
Retorno-----------: nValUso := valor em aberto do cliente.  
===============================================================================================================================
*/
Static Function MOMS030VT2( _cNumPed , _cFilAux , _cCodCli , _nOpc )
	Local _aArea	:= GetArea()
	Local _cAlias	:= GetNextAlias()
	Local _cQuery	:= ""
	Local _nValPed	:= 0
	Local _ntolporc := u_itgetmv("IT_TOLPC",10) //Percentual Toler�ncia para Produto PA do Tipo Queijo.

	Default _cNumPed	:= ""
	Default _cFilAux	:= ""
	Default _cCodCli	:= ""
	Default _nOpc		:= 0


//INICIO

//-- Verifica o valor total do pedido --//
	_cQuery := " SELECT "
	_cQuery += " SC6.C6_PRODUTO, SB1.B1_I_QQUEI, (SC6.C6_QTDVEN * SC6.C6_PRCVEN ) AS VALPED
	_cQuery += " FROM "+ RetSqlName("SC6") +" SC6, " + RetSqlName("SB1") +" SB1 "
	_cQuery += " WHERE "
	_cQuery += "     SC6.C6_NUM	= '"+ _cNumPed +"' "
	_cQuery += " AND	SC6.C6_FILIAL	= '"+ _cFilAux +"' "
	_cQuery += " AND SC6.D_E_L_E_T_	= ' ' "
	_cQuery += " AND SB1.B1_FILIAL = ' ' "
	_cQuery += " AND SB1.B1_COD = SC6.C6_PRODUTO "
	_cQuery += " AND SB1.D_E_L_E_T_	= ' ' "

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf

	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

	DbSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	While (_cAlias)->(!EOF())

		If _nOpc == 3
			If (_cAlias)->( B1_I_QQUEI = "S" )
				_nValPed +=  (  (_cAlias)->VALPED + (( (_cAlias)->VALPED * _ntolporc) / 100 ) )
			Else
				_nValPed +=  (_cAlias)->VALPED
			EndIf
		Else
			_nValPed +=  (_cAlias)->VALPED
		EndIf

		(_cAlias)->( DBSkip())
	EndDo

	(_cAlias)->( DBCloseArea() )

	RestArea(_aArea)

Return(_nValPed)

/*
===============================================================================================================================
Programa----------: MOMS030VT2
Autor-------------: Alexandre Villar
Data da Criacao---: 17/02/2014
===============================================================================================================================
Descri��o---------: Recupera valor total do pedido de vendas. 
===============================================================================================================================
Parametros--------: cCodCli := codigo do cliente. 
===============================================================================================================================
Retorno-----------: nValUso := valor em aberto do cliente.  
===============================================================================================================================
*/
Static Function MOMS030QT2( _cNumPed , _cFilAux , _cCodCli , _nOpc )
	Local _aArea	:= GetArea()
	Local _cAlias	:= GetNextAlias()
	Local _cQuery	:= ""
	Local _nQtdPed	:= 0

	Default _cNumPed	:= ""
	Default _cFilAux	:= ""
	Default _cCodCli	:= ""
	Default _nOpc		:= 0

//================================
//Verifica o valor total do pedido
//================================
	_cQuery := " SELECT "
	_cQuery += "     SUM( SC6.C6_QTDVEN ) AS QTDPED "
	_cQuery += " FROM "+ RetSqlName("SC6") +" SC6 "
	_cQuery += " WHERE "
	_cQuery += "     SC6.C6_NUM	= '"+ _cNumPed +"' "
	_cQuery += " AND	SC6.C6_FILIAL	= '"+ _cFilAux +"' "
	_cQuery += " AND SC6.D_E_L_E_T_	= ' ' "

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery), _cAlias, .T., .F. )

	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->(!Eof()) .And. (_cAlias)->QTDPED > 0
		_nQtdPed := (_cAlias)->QTDPED
	EndIf

	(_cAlias)->( DBCloseArea() )

	RestArea(_aArea)

Return(_nQtdPed)

/*
===============================================================================================================================
Programa----------: MOMS30ML
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 07/04/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para enviar e-mail ao Aprovador e ao Solicitante com o status do pedido de vendas
===============================================================================================================================
Parametros--------: _cFilial	- Filial do Pedido de Vendas
------------------: _cNumPV		- N�mero do Pedido de Vendas
------------------: _cOpcao		- Status de Aprova��o/Rejei��o
------------------: _cObs		- Observa��o da Aprova��o/Rejei��o
------------------: _cCodApr	- C�digo do Aprovador
------------------: _cCodSol	- C�digo do Solicitante
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS30ML(_cFilial, _cNumPV, _cOpcao, _cObs, _cCodApr, _cCodSol, _cTipo, _cCliente, _lSoAprvador, _aAvaliacao, cMailZY0)
	Local _cHostWF 	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4034/")
	Local _cLogo	:= _cHostWF + "htm/logo_novo.jpg"
	Local _chtmfile	:= ""
	Local oProc	:= Nil

	u_itconout("********************** INICIO DA MOMS30ML ***********************")

	u_itconout("_cNumPV----: " + _cNumPV)

	If _cTipo == "CREDITO"

		_chtmfile	:= _cHostWF + "htm/pvcred_retorno.htm"
		//====================================
		//Codigo do processo cadastrado no CFG
		//====================================
		_cCodProce := "LIBPVCRE"

		//====================
		// Assunto da mensagem
		//====================
		_cAssunto := 'Retorno da Solicita��o da Libera��o Cr�dito - ' + _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt, _cFilial,1)) + ' - PV ' + _cNumPV + ' - ' + '"' + _cOpcao + '"'

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		//======================================================================
		oProc := TWFProcess():New(_cCodProce,"Libera��o PV Cr�dito - Retorno")

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================
		oProc:NewTask("SendMail", "/workflow/htm/pvcred_retorno.htm")

	ElseIf _cTipo == "PRECO"

		_chtmfile	:= _cHostWF + "htm/pvprec_retorno.htm"
		//====================================
		//Codigo do processo cadastrado no CFG
		//====================================
		_cCodProce := "LIBPVPRE"

		//====================
		// Assunto da mensagem
		//====================
		_cAssunto := 'Retorno da Solicita��o da Libera��o Pre�o Pedido Protheus- ' + _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt, _cFilial,1)) + ' - PV ' + _cNumPV + ' - ' + '"' + _cOpcao + '"'

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		//======================================================================
		oProc := TWFProcess():New(_cCodProce,"Lib.Pre�o Pedido Protheus - Retorno")

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================

		oProc:NewTask("SendMail", "/workflow/htm/pvprec_retorno.htm")

	ElseIf _cTipo == "BONIFICACAO"

		_chtmfile	:= _cHostWF + "htm/pvboni_retorno.htm"
		//====================================
		//Codigo do processo cadastrado no CFG
		//====================================
		_cCodProce := "LIBPVBON"

		//====================
		// Assunto da mensagem
		//====================
		_cAssunto := 'Retorno da Solicita��o da Libera��o Bonifica��o - ' + _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt, _cFilial,1)) + ' - PV ' + _cNumPV + ' - ' + '"' + _cOpcao + '"'

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		//======================================================================

		oProc := TWFProcess():New("SendMail","Libera��o PV Bonifica��o - Retorno")

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================

		oProc:NewTask("SendMail", "/workflow/htm/pvboni_retorno.htm")

	EndIf

//=====================================
// Populo as vari�veis do template html
//=====================================
	oProc:oHtml:ValByName("cLogo"		, _cLogo)
	oProc:oHtml:ValByName("A_FILIAL"	, _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt,_cFilial,1)))
	oProc:oHtml:ValByName("A_CLIENTE"	, _cCliente)
	oProc:oHtml:ValByName("A_PEDVEN"	, _cNumPV)
	oProc:oHtml:ValByName("A_STATUS"	, _cOpcao)
	oProc:oHtml:ValByName("A_OBSERV"	, AllTrim(_cObs))
	oProc:oHtml:ValByName("A_RODAP"		, GETENVSERVER())
	IF _lSoAprvador//Quando j� foi re/aprovado por outro aprovador
		oProc:oHtml:ValByName("A_TESTE01", "***J� FOI EXECUTADO POR OUTRO APROVADOR***")
		oProc:oHtml:ValByName("A_DATA"	, _aAvaliacao[1,1])
		oProc:oHtml:ValByName("A_HORA"	, _aAvaliacao[1,2])
		oProc:oHtml:ValByName("A_APROV"	, _aAvaliacao[1,3])
	ELSE
		oProc:oHtml:ValByName("A_TESTE01", "Foi efetivado")
		oProc:oHtml:ValByName("A_DATA"	, DtoC(Date()))
		oProc:oHtml:ValByName("A_HORA"	, Time())
		oProc:oHtml:ValByName("A_APROV"	, Posicione("ZY0",1,xFilial("ZY0") + _cCodApr,"ZY0_NOMINT"))
	ENDIF

//================================================================
// Informamos o destinat�rio (aprovador) do email contendo o link.  
//================================================================
	oProc:cTo := cMailZY0

	u_itconout("Email de retorno enviado para o aprovador: " + oProc:cTo + " com sucesso! Data: " + DtoC(dDataBase) + " hora: " + Time() + " Filial: " + _cFilial + " Pedido: " + _cNumPV)

	IF !_lSoAprvador//Quando j� foi re/aprovado por outro aprovador
		oProc:cCc := AllTrim(U_UCFG001(3,_cCodSol)) //UsrRetMail(_cCodSol))
		u_itconout("Email de retorno enviado para o solicitante: " + oProc:cCc + " com sucesso! Data: " + DtoC(dDataBase) + " hora: " + Time() + " Filial: " + _cFilial + " Pedido: " + _cNumPV)
	ENDIF
//===============================
// Informamos o assunto do email.  
//===============================
	oProc:cSubject	:= U_ITEncode(_cAssunto)

//===============================================
// Informamos o arquivo a ser atachado no e-mail.
//===============================================
//_oProcess:AttachFile(cConsulta)

	_cMailID	:= oProc:fProcessId
	_cTaskID	:= oProc:fTaskID

//=======================================================
// Iniciamos a tarefa e enviamos o email ao destinat�rio.
//=======================================================
	oProc:Start()

	u_itconout("********************** FIM DA MOMS30ML ***********************")

Return

/*
===============================================================================================================================
Programa----------: MOMS030O
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 01/04/2016
===============================================================================================================================
Descri��o---------: Rotina respons�vel por montar o formul�rio de aprova��o e o envio do link gerado. (Libera��o Pre�o)
===============================================================================================================================
Parametros--------: _cAliasSCR - Recebe o alias aberto das aprova��es dos pedidos de compras
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS030O(_cGetSol)
	Static _nValAtraso	:= 0
	Static _nValPed     := 0
	Local _aArea		:= GetArea()
	Local _aAreaSC5		:= SC5->(GetArea())
	Local _cLogo		:= _cHostWF + "htm/logo_novo.jpg"
	Local _nMCusto		:= 0
	Local _cMailApr		:= ""
	Local _cCodiApr		:= ""
	Local _cNomeApr		:= ""
	Local _cFilApr		:= ""
	Local _cMailSol		:= ""
	Local _cFilial		:= SC5->C5_FILIAL
	Local _nMCustoCli	:= 0
	Local _nLimCred		:= 0
	Local _nSalPed 		:= 0
	Local _nSalPedL		:= 0
	Local _nSalDupM		:= 0
	Local _nLcFin		:= 0
	Local _nSalFinM		:= 0
	Local _nSalDup		:= 0
	Local _nSalFin		:= 0
	Local _nMoeda		:= 0
	Local _cTpCarg		:= ""
	Local _cQryDA1		:= ""
	Local _aVlrDesc		:= {}
	Local _nRecnoSC5    := SC5->(Recno())
	Local _cMCusto		:= SuperGetMv("MV_MCUSTO")
	Local _aItens       := {}
	Local _nItem        := 0
	Local _nI			:= 0
	Local _lEnvSolic	:= .F.

	Local _cFilSol 		:= ""
	Local _cNumPVSol 	:= ""
	Local _cCodRep 		:= ""
	Local _cNomRep 		:= ""
	Local _cCodCoo 		:= ""
	Local _cNomCoo 		:= ""
	Local _cCodGer 		:= ""
	Local _cNomGer 		:= ""
	Local _cNumPV  		:= ""
	Local _cTipoPV 		:= ""
	Local _cFilPV  		:= ""
	Local _cEmisPV 		:= ""
	Local _cTrocanf 	:= ""
	Local _cFilFT 		:= ""
	Local _ccTabPrc 	:= ""
	Local _ccDecPrc 	:= ""
	Local _cCarga 		:= ""
	Local _cCondPG		:= ""
	Local _cCondPgPad 	:= ""
	Local _cRespPed 	:= ""
	Local _cNomCli 		:= ""
	Local _cNomRed 		:= ""
	Local _cCodCli 		:= ""
	Local _cLojCli 		:= ""
	Local _cCnpjCli 	:= ""
	Local _cGrpVen 		:= ""
	Local _cContatCli 	:= ""
	Local _cFoneCli 	:= ""
	Local _cEmailCli	:= ""
	Local _cCidCli 		:= ""
	Local _cEstCli	 	:= ""
	Local _cEndCli 		:= ""
	Local _cAnaCre 		:= ""
	Local _cnTitProt  	:= ""
	Local _cnChqDev		:= ""
	Local _cnMComp 		:= ""
	Local _cnMDuplic 	:= ""
	Local _cnMAtras  	:= ""
	Local _ccVenLCr  	:= ""
	Local _ccDtLiLib 	:= ""
	Local _cnAtraAtu 	:= ""
	Local _cnLimCrl 	:= ""
	Local _cnSldHist 	:= ""
	Local _cnLimcSec 	:= ""
	Local _cn2LimcSec	:= ""
	Local _cnSldLcSe 	:= ""
	Local _cnMaiCom 	:= ""
	Local _cnMaiCom2 	:= ""
	Local _cnMaiSld 	:= ""
	Local _ccPriCom 	:= ""
	Local _ccUltCom 	:= ""
	Local _cnMaiAtr 	:= ""
	Local _cnMedAtr 	:= ""
	Local _ccGrauRis 	:= ""
	Local _ccFrete 		:= ""
	Local _ccTpCarga 	:= ""
	Local _cnQtdChap 	:= ""
	Local _ccHrDescg 	:= ""
	Local _cnCusCarg 	:= ""
	Local _cdDtEntrega 	:= ""
	Local _ccHrEntrega 	:= ""
	Local _ccSenhaEntr 	:= ""
	Local _ccTpOper 	:= ""
	Local _ccMensNF 	:= ""
	Local _ccObsPed 	:= ""
	Local _cA_FILIAL 	:= ""
	Local _cA_PEDVEN 	:= ""
	Local _cA_NOMREP 	:= ""
	Local _cA_CLIENTE 	:= ""
	Local _cA_LIMCRED 	:= ""
	Local _cA_VLRPED  	:= ""
	Local _cA_TITPRO 	:= ""
	Local _cA_MCOMP 	:= ""
	Local _cA_MDUPL 	:= ""
	Local _cA_VLCRED 	:= ""
	Local _cA_DTLIMLB 	:= ""
	Local _cA_PCOMP 	:= ""
	Local _cA_UCOMP 	:= ""
	Local _cA_GRISC		:= ""
	Local _cA_RODAP     := ""
	Local _nPrcTabela   := 0
	Local _nPesoFaixa	:= 0

	For _nI := 1 To Len(_aAprPreco)

		_cCodiApr	:= _aAprPreco[_nI,1] //TRBZY0->ZY0_CODUSR
		_cNomeApr	:= _aAprPreco[_nI,2] //AllTrim(TRBZY0->ZY0_NOMINT)
		_cMailApr	:= _aAprPreco[_nI,3] //AllTrim(UsrRetMail(TRBZY0->ZY0_CODUSR)) + ";" + TRBZY0->ZY0_EMAIL
		_cFilApr	:= _aAprPreco[_nI,4]

		If !(!Empty(_cFilApr) .And. !(_cFilial $ _cFilApr))

			//Codigo do processo cadastrado no CFG
			_cCodProce := "LIBPVC"

			// Arquivo html template utilizado para montagem da aprova��o
			_cHtmlMode := "\Workflow\htm\libpv_preco.htm"

			// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
			_oProcess := TWFProcess():New(_cCodProce,"Libera��o de Pre�o Pedido de Vendas")

			SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

			_oProcess:NewTask("Liberacao_PVP", _cHtmlMode)

			If _nI = 1 

				//====================
				//Dados do Solicitante
				//====================
				If Empty(__cUserId) .And. IsInCallStack("U_LIBERAP") // No WebService, a vari�vel __cUserID fica vazia. Ent�o o e-mail do solicitante � lido a partir do c�digo do usu�rio do XML de integra��o.
					If Type("_cEmailZZL") == "C"
						__cUserId := _cCodUsuario
					EndIf
				EndIf

				_cFilSol 	:= SC5->C5_FILIAL + ' - ' + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1))
				_cNumPVSol 	:= SUBSTR(SC5->C5_NUM,1,6)
				_cCodRep 	:= SC5->C5_VEND1
				_cNomRep 	:= AllTrim(SC5->C5_I_V1NOM)
				_cCodCoo 	:= SC5->C5_VEND2
				_cNomCoo 	:= AllTrim(SC5->C5_I_V2NOM)
				_cCodGer 	:= SC5->C5_VEND3
				_cNomGer 	:= AllTrim(SC5->C5_I_V3NOM)
				_cNumPV  	:= SC5->C5_NUM

				Do Case
				Case SC5->C5_TIPO == "N"
					_cTipoPV := "Normal"
				Case SC5->C5_TIPO == "C"
					_cTipoPV := "Compl.Pre�o/Quantidade"
				Case SC5->C5_TIPO == "I"
					_cTipoPV := "Compl.ICMS"
				Case SC5->C5_TIPO == "P"
					_cTipoPV := "Compl.IPI"
				Case SC5->C5_TIPO == "D"
					_cTipoPV := "Dev.Compras"
				Case SC5->C5_TIPO == "B"
					_cTipoPV := "Utiliza Fornecedor"
				EndCase

				_cFilPV  := SC5->C5_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1))
				_cEmisPV := DtoC(SC5->C5_EMISSAO)

				If SC5->C5_I_TRCNF == 'S'
					_cTrocanf 	:= "Sim"
					_cFilFT 	:= SC5->C5_I_FILFT + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_I_FILFT,1))
				Else
					_cTrocanf	:= "N�o"
					_cFilFT		:= SC5->C5_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1))
				EndIf

				_ccTabPrc 	:= SC5->C5_I_TAB
				_ccDecPrc 	:= IIF(!Empty(_ccTabPrc), POSICIONE("DA0",1,xFilial("DA0")+_ccTabPrc,'DA0_DESCRI'),"")
				_cCarga 	:= IIF(AllTrim(SC5->C5_I_TPVEN) == "F" .AND. SC5->C5_I_TPVEN != "", " F - Fechada", " V - Fracionada")

				dbSelectArea("SE4")
				dbSetOrder(1)
				dbSeek(xFilial("SE4") + SC5->C5_CONDPAG)
				_cCondPG := SE4->E4_CODIGO + " - " + SE4->E4_DESCRI

				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

				dbSelectArea("SE4")
				dbSetOrder(1)
				dbSeek(xFilial("SE4") + SA1->A1_COND)
				_cCondPgPad := SE4->E4_CODIGO + " - " + SE4->E4_DESCRI
				_cRespPed 	:= Posicione("SRA",1,SC5->C5_I_CDUSU,"RA_NOME")

				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

				_cNomCli 	:= SA1->A1_NOME
				_cNomRed 	:= SA1->A1_NREDUZ
				_cCodCli 	:= SA1->A1_COD
				_cLojCli 	:= SA1->A1_LOJA
				_cCnpjCli 	:= MOMS030CPF(SA1->A1_CGC)
				_cGrpVen 	:= SA1->A1_GRPVEN + " - " + Posicione("ACY",1,xFilial("ACY") + SA1->A1_GRPVEN, "ACY_DESCRI")
				_cContatCli := SA1->A1_CONTATO
				_cFoneCli 	:= SA1->A1_TEL
				_cEmailCli 	:= SA1->A1_EMAIL
				_cCidCli 	:= SA1->A1_MUN
				_cEstCli 	:= SA1->A1_EST
				_cEndCli 	:= SA1->A1_END
				_cAnaCre 	:= SA1->A1_I_ACRED

				//========================
				//Informar��es Financeiras
				//========================
				DBSelectArea("SA1")
				SA1->( DBSetOrder(1) )
				SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE ) )

				While SA1->(!Eof()) .And. SA1->A1_COD == SC5->C5_CLIENTE

					_nMCustoCli	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC	, Val(_cMCusto) )
					_nLimCred	+= xMoeda( SA1->A1_LC							, _nMCustoCli , _nMCusto , Date() )
					_nSalPed 	+= xMoeda( SA1->A1_SALPED + SA1->A1_SALPEDB		, _nMCustoCli , _nMCusto , Date() )
					_nSalPedL	+= xMoeda( SA1->A1_SALPEDL						, _nMCustoCli , _nMCusto , Date() )
					_nSalDupM	+= xMoeda( SA1->A1_SALDUPM						, _nMCustoCli , _nMCusto , Date() )
					_nLcFin		+= xMoeda( SA1->A1_LCFIN						, _nMCustoCli , _nMCusto , Date() )
					_nSalFinM	+= xMoeda( SA1->A1_SALFINM						, _nMCustoCli , _nMCusto , Date() )
					_nSalDup	+= SA1->A1_SALDUP
					_nSalFin	+= SA1->A1_SALFIN

					SA1->( DBSkip() )
				EndDo

				DBSelectArea("SA1")
				SA1->( DBSetOrder(1) )
				SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )

				_nMCusto 	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC , VAL( SuperGetMv("MV_MCUSTO") ) )
				_nMoeda		:= 1

				_nValAtraso	:= MOMS030VSC( SC5->C5_CLIENTE )
				_nValPed	:= MOMS030VT2( SC5->C5_NUM , SC5->C5_FILIAL , 1 )

				_cnTitProt  := STR(SA1->A1_TITPROT,3)
				_cnChqDev	:= STR(SA1->A1_CHQDEVO,3)
				_cnMComp 	:= Transform(SA1->A1_MCOMPRA ,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto))
				_cnMDuplic 	:= Transform(SA1->A1_MAIDUPL ,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto))
				_cnMAtras  	:= Transform(SA1->A1_METR ,PesqPict("SA1","A1_METR",7))
				_ccVenLCr  	:= DtoC(SA1->A1_VENCLC)
				_ccDtLiLib 	:= DtoC(StoD(""))
				_cnAtraAtu 	:= TRansform(_nValAtraso ,PesqPict("SA1","A1_SALDUP",17,1))

				//==================
				//Posi��o do Cliente
				//==================
				_cnLimCrl 	:= TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",14,_nMCusto))
				_cnSldHist 	:= TRansform(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP",14,1))
				_cnLimcSec 	:= TRansform(Round(Noround(xMoeda(SA1->A1_LCFIN,_nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1))
				_cn2LimcSec	:= TRansform(SA1->A1_LCFIN,PesqPict("SA1","A1_LCFIN",14,_nMcusto))
				_cnSldLcSe 	:= TRansform(SA1->A1_SALFIN,PesqPict("SA1","A1_SALFIN",14,1))
				_cnMaiCom 	:= TRansform(Round(Noround(xMoeda(SA1->A1_MCOMPRA, _nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1))
				_cnMaiCom2 	:= TRansform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,_nMcusto))
				_cnMaiSld 	:= TRansform(Round(Noround(xMoeda(SA1->A1_MSALDO, _nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1))
				_ccPriCom 	:= DtoC(SA1->A1_PRICOM)
				_ccUltCom 	:= DtoC(SA1->A1_ULTCOM)
				_cnMaiAtr 	:= Transform(SA1->A1_MATR,PesqPict("SA1","A1_MATR",14))
				_cnMedAtr 	:= PADC(STR(SA1->A1_METR,7,2),22)
				_ccGrauRis 	:= SA1->A1_RISCO

				Do Case
				Case SC5->C5_TPFRETE == "C"
					_ccFrete := "CIF"
				Case SC5->C5_TPFRETE == "F"
					_ccFrete := "FOB"
				Case SC5->C5_TPFRETE == "T"
					_ccFrete := "TERCEIROS"
				Case SC5->C5_TPFRETE == "S"
					_ccFrete := "Sem Frete"
				EndCase

				_ccTpCarga 	:= Iif(SC5->C5_I_TIPCA == "1", SC5->C5_I_TIPCA + " - Paletizada", Iif(SC5->C5_I_TIPCA == "2", SC5->C5_I_TIPCA + " - Batida", ""))
				_cnQtdChap 	:= SC5->C5_I_CHAPA
				_ccHrDescg 	:= SC5->C5_I_HORDE
				_cnCusCarg 	:= "0"
				_cdDtEntrega := SC5->C5_I_DTENT
				_ccHrEntrega := SC5->C5_I_HOREN
				_ccSenhaEntr := SC5->C5_I_SENHA

				dbSelectArea("ZB4")
				dbSetOrder(1)
				dbSeek(xFilial("ZB4") + SC5->C5_I_OPER)
				_ccTpOper := SC5->C5_I_OPER + " - " + ZB4->ZB4_DESCRI
				_ccMensNF := SC5->C5_MENNOTA
				_ccObsPed := SC5->C5_I_OBPED

				//=========================================
				//Informa��es dos itens do Pedido de Vendas
				//=========================================
				dbSelectArea("SC6")
				dbSetOrder(1)
				dbSeek(SC5->C5_FILIAL + SC5->C5_NUM)

				Do While !SC6->(Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM

        			_cQryDA1 := " SELECT DA1_I_PRF1,DA1_I_PMF1, DA1_I_PRF2, DA1_I_PMF2,DA1_I_PRF3, DA1_I_PMF3,  "
					_cQryDA1 += " DA0_I_PES3 , DA0_I_PES2, DA0_I_PES1 "					
					_cQryDA1 += "FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("DA0") + " DA0 "
					_cQryDA1 += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
					_cQryDA1 += "  AND DA1_CODTAB = '" + _ccTabPrc + "' "
					_cQryDA1 += "  AND DA1_CODPRO = '" + Alltrim(SC6->C6_PRODUTO) + "' "
					_cQryDA1 += "  AND DA1.D_E_L_E_T_ = ' ' "
					_cQryDA1 += "  AND DA0.DA0_FILIAL = DA1.DA1_FILIAL " 
					_cQryDA1 += "  AND DA0.DA0_CODTAB = DA1.DA1_CODTAB "
					_cQryDA1 += "  AND DA0.D_E_L_E_T_ = ' ' "		

					If Select("TRBDA1") > 0 
						TRBDA1->(DbCloseArea())  
					EndIf
					dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryDA1 ) , "TRBDA1" , .T., .F. )

					Do Case
					Case AllTrim(SC5->C5_I_TPVEN) == "F"
						_cTpCarg := "F"
					Case AllTrim(SC5->C5_I_TPVEN) == "V"
						_cTpCarg := "V"
					EndCase

					dbSelectArea("TRBDA1")
					TRBDA1->(dbGoTop())

					If SC6->C6_I_FXPES == 3
						_nPesoFaixa := TRBDA1->DA0_I_PES3
						_nPrcTabela := TRBDA1->DA1_I_PRF3
					ElseIf SZW->ZW_I_FXPES == 2
						_nPesoFaixa := TRBDA1->DA0_I_PES2
						_nPrcTabela := TRBDA1->DA1_I_PRF2						
					else
						_nPesoFaixa := TRBDA1->DA0_I_PES1        
						_nPrcTabela := TRBDA1->DA1_I_PRF1						
					ENDIF					

					_aVlrDesc	:= U_veriContrato( SC5->C5_CLIENTE , SC5->C5_LOJACLI , SC6->C6_PRODUTO )

					If _aVlrDesc[1] <> 0
						_nPrecoNet := (SC6->C6_PRCVEN - ( ( _aVlrDesc[1] * SC6->C6_PRCVEN ) / 100 ))
					Else
						_nPrecoNet := SC6->C6_PRCVEN
					EndIf

					If _nPrecoNet < _nPrcTabela 
						_cColor := "color=#FF0000"
					Else
						_cColor := "color=#006400"
					EndIf
 

					aAdd(_aItens,{SC6->C6_ITEM,;
						SC6->C6_PRODUTO,;
						AllTrim(SC6->C6_DESCRI),;
						SC6->C6_PEDCLI,;
						Transform(SC6->C6_PRCVEN, "@E 999,999,999.999"),;
						Transform(SC6->C6_UNSVEN, PesqPict("SC6","C6_UNSVEN")),;
						SC6->C6_SEGUM,;
						Transform(SC6->C6_VALOR, PesqPict("SC6","C6_VALOR")),;
						Transform(_nPrcTabela, PesqPict("SC6","C6_VALOR")),;
						Transform(_aVlrDesc[1], PesqPict("SC6","C6_VALOR")),;
						Transform(SC6->C6_PRCVEN - ( ( _aVlrDesc[1] * SC6->C6_PRCVEN ) / 100 ), PesqPict("SC6","C6_VALOR")),;
						_cColor})

					dbSelectArea("TRBDA1")
					TRBDA1->(dbCloseArea())

					SC6->(dbSkip())
				EndDo

			EndIf


			//======================================
			//Dados do cabe�alho do pedido de vendas
			//======================================
			_oProcess:oHtml:ValByName("cLogo"		, _cLogo							)
			_oProcess:oHtml:ValByName("cCodSol"		, __cUserId							)
			_oProcess:oHtml:ValByName("cNomSol"		, AllTrim(UsrFullName(__cUserId))	)
			_oProcess:oHtml:ValByName("cMaiSol"		, AllTrim(U_UCFG001(3))				) //UsrRetMail(__cUserId)))
			_oProcess:oHtml:ValByName("cFilSol"		, _cFilSol							)
			_oProcess:oHtml:ValByName("cNumPVSol"	, _cNumPVSol						)
			_oProcess:oHtml:ValByName("cDtAtu"		, DtoC(Date()) + " - " + Time()		)
			_oProcess:oHtml:ValByName("cTipOper"	, "PRECO"							)

			//==================
			//Dados do Aprovador
			//==================
			_oProcess:oHtml:ValByName("cCodApr"		, _cCodiApr	)
			_oProcess:oHtml:ValByName("cNomApr"		, _cNomeApr	)

			//======================
			//Dados do Representante
			//======================
			_oProcess:oHtml:ValByName("cCodRep"		, _cCodRep	)
			_oProcess:oHtml:ValByName("cNomRep"		, _cNomRep	)

			//====================
			//Dados do Coordenador
			//====================
			_oProcess:oHtml:ValByName("cCodCoo"		, _cCodCoo	)
			_oProcess:oHtml:ValByName("cNomCoo"		, _cNomCoo	)

			//================
			//Dados do Gerente
			//================
			_oProcess:oHtml:ValByName("cCodGer"		, _cCodGer )
			_oProcess:oHtml:ValByName("cNomGer"		, _cNomGer )

			//===============
			//Dados do Pedido
			//===============
			_oProcess:oHtml:ValByName("cNumPV"		, _cNumPV	)
			_oProcess:oHtml:ValByName("cTipoPV"		, _cTipoPV	)
			_oProcess:oHtml:ValByName("cFilPV"		, _cFilPV	)
			_oProcess:oHtml:ValByName("cEmisPV"		, _cEmisPV	)
			_oProcess:oHtml:ValByName("ctrocanf"	, _cTrocanf	)
			_oProcess:oHtml:ValByName("cFilFT"		, _cFilFT	)
			_oProcess:oHtml:ValByName("cTabPrc"		, _ccTabPrc	)
			_oProcess:oHtml:ValByName("cDecPrc"		, _ccDecPrc	)
			_oProcess:oHtml:ValByName("cCarga"      , _cCarga	)
			_oProcess:oHtml:ValByName("cCondPG"		, _cCondPG	)
			_oProcess:oHtml:ValByName("cCondPgPad"	, _cCondPgPad	)
			_oProcess:oHtml:ValByName("cRespPed"	, _cRespPed		)

			//================
			//Dados do Cliente
			//================
			_oProcess:oHtml:ValByName("cNomCli"			, _cNomCli	)
			_oProcess:oHtml:ValByName("cNomRed"			, _cNomRed	)
			_oProcess:oHtml:ValByName("cCodCli"			, _cCodCli	)
			_oProcess:oHtml:ValByName("cLojCli"			, _cLojCli	)
			_oProcess:oHtml:ValByName("cCnpjCli"		, _cCnpjCli	)
			_oProcess:oHtml:ValByName("cGrpVen"			, _cGrpVen	)
			_oProcess:oHtml:ValByName("cContatCli"		, _cContatCli)
			_oProcess:oHtml:ValByName("cFoneCli"		, _cFoneCli	)
			_oProcess:oHtml:ValByName("cEmailCli"		, _cEmailCli)
			_oProcess:oHtml:ValByName("cCidCli"			, _cCidCli	)
			_oProcess:oHtml:ValByName("cEstCli"			, _cEstCli	)
			_oProcess:oHtml:ValByName("cEndCli"			, _cEndCli	)
			_oProcess:oHtml:ValByName("cAnaCre"			, _cAnaCre	)

			//========================
			//Informar��es Financeiras
			//========================
			_oProcess:oHtml:ValByName("nLimCrd"			, TRansform(_nLimCred,PesqPict("SA1","A1_LC",17,1)))
			_oProcess:oHtml:ValByName("nTitAber"		, TRansform(_nSalDup,PesqPict("SA1","A1_SALDUP",17,1)))
			_oProcess:oHtml:ValByName("nTitVenc"		, TRansform(_nSalPedL,PesqPict("SA1","A1_SALPEDL",17,1)))
			_oProcess:oHtml:ValByName("nSLimCrd"		, TRansform(_nLimCred-_nSaldupM-_nSalPedL,PesqPict("SA1","A1_SALDUP",17,1)))
			_oProcess:oHtml:ValByName("nPedAtu"			, TRansform(_nValPed ,PesqPict("SA1","A1_SALDUP",17,1)))
			_oProcess:oHtml:ValByName("nSalNFat"		, TRansform(_nSalPed ,PesqPict("SA1","A1_SALPED",17,1)))
			_oProcess:oHtml:ValByName("nLimCChe"		, TRansform(_nLcFin ,PesqPict("SA1","A1_LCFIN",17,1)))
			_oProcess:oHtml:ValByName("nSldChq"			, TRansform(_nSalFin ,PesqPict("SA1","A1_SALDUP",17,1)))

			_oProcess:oHtml:ValByName("nTitProt"		, _cnTitProt)
			_oProcess:oHtml:ValByName("nChqDev"			, _cnChqDev)
			_oProcess:oHtml:ValByName("nMComp"			, _cnMComp)
			_oProcess:oHtml:ValByName("nMDuplic"		, _cnMDuplic)
			_oProcess:oHtml:ValByName("nMAtras"			, _cnMAtras)
			_oProcess:oHtml:ValByName("cVenLCr"			, _ccVenLCr)
			_oProcess:oHtml:ValByName("cDtLiLib"		, _ccDtLiLib)
			_oProcess:oHtml:ValByName("nAtraAtu"		, _cnAtraAtu)

			//==================
			//Posi��o do Cliente
			//==================
			_oProcess:oHtml:ValByName("nLimCrl"			, _cnLimCrl					)
			_oProcess:oHtml:ValByName("nSldHist"		, _cnSldHist				)
			_oProcess:oHtml:ValByName("nLimcSec"		, _cnLimcSec, _cn2LimcSec 	)
			_oProcess:oHtml:ValByName("nSldLcSe"		, _cnSldLcSe				)
			_oProcess:oHtml:ValByName("nMaiCom"			, _cnMaiCom, _cnMaiCom2 	)
			_oProcess:oHtml:ValByName("nMaiSld"			, _cnMaiSld					)
			_oProcess:oHtml:ValByName("cPriCom"			, _ccPriCom					)
			_oProcess:oHtml:ValByName("cUltCom"			, _ccUltCom					)
			_oProcess:oHtml:ValByName("nMaiAtr"			, _cnMaiAtr					)
			_oProcess:oHtml:ValByName("nMedAtr"			, _cnMedAtr					)
			_oProcess:oHtml:ValByName("cGrauRis"		, _ccGrauRis				)

			//===============================
			//Informa��es do Pedido de Vendas
			//===============================
			_oProcess:oHtml:ValByName("cFrete"			, _ccFrete		)
			_oProcess:oHtml:ValByName("cTpCarga"		, _ccTpCarga	)
			_oProcess:oHtml:ValByName("nQtdChap"		, _cnQtdChap	)
			_oProcess:oHtml:ValByName("cHrDescg"		, _ccHrDescg	)
			_oProcess:oHtml:ValByName("nCusCarg"		, _cnCusCarg	)
			_oProcess:oHtml:ValByName("dDtEntrega"		, _cdDtEntrega	)
			_oProcess:oHtml:ValByName("cHrEntrega"		, _ccHrEntrega	)
			_oProcess:oHtml:ValByName("cSenhaEntr"		, _ccSenhaEntr	)
			_oProcess:oHtml:ValByName("cTpOper"			, _ccTpOper		)
			_oProcess:oHtml:ValByName("cMensNF"			, _ccMensNF		)
			_oProcess:oHtml:ValByName("cObsPed"			, _ccObsPed		)

			//=========================================
			//Informa��es dos itens do Pedido de Vendas
			//=========================================
			For _nItem := 1 To Len(_aItens)

				aAdd( _oProcess:oHtml:ValByName("Itens.cItem" 			), _aItens[_nItem,01]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cProdPV" 		), _aItens[_nItem,02]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cDescPV"			), _aItens[_nItem,03]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cNumPCli"		), _aItens[_nItem,04]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPrcVen"			), _aItens[_nItem,05]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nQuantPV"		), _aItens[_nItem,06]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cUM"				), _aItens[_nItem,07]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nTotalPV"	   	), _aItens[_nItem,08]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPrcTab"			), _aItens[_nItem,09] 	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPerCon"			), _aItens[_nItem,10]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPrcNet"			), _aItens[_nItem,11] 	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cCor"			), _aItens[_nItem,12] 	)

			Next

			_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol			)

			//=========================================================================
			// Informe o nome da fun��o de retorno a ser executada quando a mensagem de
			// respostas retornar ao Workflow:
			//=========================================================================
			_oProcess:bReturn := "U_MOMS030R"


			//========================================================================
			// Ap�s ter repassado todas as informac�es necess�rias para o Workflow,
			// execute o m�todo Start() para gerar todo o processo e enviar a mensagem
			// ao destinat�rio.
			//========================================================================
			_cMailID	:= _oProcess:Start("\workflow\emp01")
			_cLink		:= _cMailID

			If File("\workflow\emp01\" + _cMailID + ".htm")
				U_ITCONOUT("Arquivo \workflow\emp01\" + _cMailID + ".htm criado com sucesso.")
			ELSE
				U_ITCONOUT("Arquivo \workflow\emp01\" + _cMailID + ".htm n�o encotrado.")
			EndIf



			//====================================
			//Codigo do processo cadastrado no CFG
			//====================================
			_cCodProce := "LIBPVBON"

			//======================================================================
			// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
			//======================================================================
			_oProcess := TWFProcess():New(_cCodProce,"Libera��o PV Pre�o")

			SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

			//=================================================================
			// Criamos o link para o arquivo que foi gerado na tarefa anterior.
			//=================================================================
			_oProcess:NewTask("LINK", "\workflow\htm\pvprec_link.htm")

			_chtmlfile	:= _cLink + ".htm"
			_cMailTo	:= "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + AllTrim(GetMV('MV_WFMLBOX')), "WF7_ENDERE"))
			U_ITCONOUT("Lendo Arquivo \workflow\emp01\" + _chtmlfile)

			_chtmltexto := wfloadfile("\workflow\emp01\" + _chtmlfile )
			_chtmltexto := strtran( _chtmltexto, _cmailto, "WFHTTPRET.APL" )
			wfsavefile("\workflow\emp"+cEmpAnt+"\" + _chtmlfile, _chtmltexto)
			U_ITCONOUT("Gravou Arquivo \workflow\emp"+cEmpAnt+"\" + _chtmlfile)

			_cLink := _cHostWF + "emp01/" + _cLink + ".htm"

			If _nI = 1
				_cA_FILIAL 	:= _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1)
				_cA_PEDVEN 	:= SC5->C5_NUM
				_cA_NOMREP 	:= SC5->C5_VEND1 + " - " + AllTrim(SC5->C5_I_V1NOM)
				_cA_CLIENTE := SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME
				_cA_LIMCRED := TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1))
				_cA_VLRPED  := TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1))
				_cA_TITPRO 	:= STR(SA1->A1_TITPROT,3)
				_cA_MCOMP 	:= Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto))
				_cA_MDUPL 	:= Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto))
				_cA_VLCRED 	:= DtoC(SA1->A1_VENCLC)
				_cA_DTLIMLB := DtoC(StoD(""))
				_cA_PCOMP 	:= DtoC(SA1->A1_PRICOM)
				_cA_UCOMP 	:= DtoC(SA1->A1_ULTCOM)
				_cA_GRISC 	:= SA1->A1_RISCO
				_cA_RODAP   := GETENVSERVER()
			EndIf
			//=====================================
			// Populo as vari�veis do template html
			//=====================================
			_oProcess:oHtml:ValByName("cLogo"		, _cLogo		)
			_oProcess:oHtml:ValByName("A_FILIAL"	, _cA_FILIAL	)
			_oProcess:oHtml:ValByName("A_PEDVEN"	, _cA_PEDVEN	)
			_oProcess:oHtml:ValByName("A_LINK"		, _cLink		)
			_oProcess:oHtml:ValByName("A_NOMREP"	, _cA_NOMREP	)
			_oProcess:oHtml:ValByName("A_CLIENTE"	, _cA_CLIENTE	)
			_oProcess:oHtml:ValByName("A_LIMCRED"	, _cA_LIMCRED	)
			_oProcess:oHtml:ValByName("A_VLRPED"	, _cA_VLRPED	)
			_oProcess:oHtml:ValByName("A_TITPRO"	, _cA_TITPRO	)
			_oProcess:oHtml:ValByName("A_MCOMP"		, _cA_MCOMP		)
			_oProcess:oHtml:ValByName("A_MDUPL"		, _cA_MDUPL		)
			_oProcess:oHtml:ValByName("A_VLCRED"	, _cA_VLCRED	)
			_oProcess:oHtml:ValByName("A_DTLIMLB"	, _cA_DTLIMLB	)
			_oProcess:oHtml:ValByName("A_PCOMP"		, _cA_PCOMP		)
			_oProcess:oHtml:ValByName("A_UCOMP"		, _cA_UCOMP		)
			_oProcess:oHtml:ValByName("A_GRISC"		, _cA_GRISC		)
			_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol		)
			_oProcess:oHtml:ValByName("A_RODAP"		, _cA_RODAP		)

			//================================================================
			// Informamos o destinat�rio (aprovador) do email contendo o link.
			//================================================================
			_oProcess:cTo := _cMailApr

			//===============================
			// Informamos o assunto do email.
			//===============================
			// Assunto da mensagem
			_cAssunto := "Sol.Lib de Pre�o Protheus " + SC5->C5_FILIAL + " Cliente " + SA1->A1_NOME + " Ped.: " + SUBSTR(SC5->C5_NUM,1,6)

			_oProcess:cSubject	:= U_ITEncode(_cAssunto)

			_cMailID	:= _oProcess:fProcessId
			_cTaskID	:= _oProcess:fTaskID

			//=======================================================
			// Iniciamos a tarefa e enviamos o email ao destinat�rio.
			//=======================================================
			_oProcess:Start()
			_lEnvSolic := .T.
			_cEmaisEnv += _aAprPreco[_nI,2] + "  E-mail: " +_aAprPreco[_nI,3] + CHR(13) + CHR(10)

		EndIf
		RestArea(_aArea)
		RestArea(_aAreaSC5)

	Next

//==========================================================
//Monta e faz o envio ao solicitante da aprova��o de Cr�dito
//==========================================================
	If _lEnvSolic
		//====================================
		//Codigo do processo cadastrado no CFG
		//====================================
		_cCodProce := "LIBPVPRE"

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		//======================================================================
		_oProcess := TWFProcess():New(_cCodProce,"Libera��o PV Pre�o - Solicitante")

		SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================
		_oProcess:NewTask("LINK", "\workflow\htm\pvprec_solic.htm")

		//=====================================
		// Populo as vari�veis do template html
		//=====================================
		_oProcess:oHtml:ValByName("cLogo"		, _cLogo)
		_oProcess:oHtml:ValByName("A_FILIAL"	, _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1))
		_oProcess:oHtml:ValByName("A_PEDVEN"	, SC5->C5_NUM)
		_oProcess:oHtml:ValByName("A_NOMREP"	, SC5->C5_VEND1 + " - " + AllTrim(SC5->C5_I_V1NOM))
		_oProcess:oHtml:ValByName("A_CLIENTE"	, SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME)
		_oProcess:oHtml:ValByName("A_LIMCRED"	, TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1)))
		_oProcess:oHtml:ValByName("A_VLRPED"	, TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1)))
		_oProcess:oHtml:ValByName("A_TITPRO"	, STR(SA1->A1_TITPROT,3))
		_oProcess:oHtml:ValByName("A_MCOMP"		, Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto)))
		_oProcess:oHtml:ValByName("A_MDUPL"		, Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto)))
		_oProcess:oHtml:ValByName("A_VLCRED"	, DtoC(SA1->A1_VENCLC))
		_oProcess:oHtml:ValByName("A_DTLIMLB"	, DtoC(StoD("")))
		_oProcess:oHtml:ValByName("A_PCOMP"		, DtoC(SA1->A1_PRICOM))
		_oProcess:oHtml:ValByName("A_UCOMP"		, DtoC(SA1->A1_ULTCOM))
		_oProcess:oHtml:ValByName("A_GRISC"		, SA1->A1_RISCO)
		_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol)
		_oProcess:oHtml:ValByName("Texto01"		, "Aprovadores:")//AWF-09/06/2016
		_oProcess:oHtml:ValByName("Texto02"		, _cAprPreco)
		_oProcess:oHtml:ValByName("A_RODAP"		, _cA_RODAP)

		//================================================================
		// Informamos o destinat�rio (aprovador) do email contendo o link.
		//================================================================
		_cMailSol := AllTrim(  U_UCFG001(3) ) //UsrRetMail(__cUserID))

		If Empty(_cMailSol) .And. IsInCallStack("U_LIBERAP") // No WebService, a vari�vel __cUserID fica vazia. Ent�o o e-mail do solicitante � lido a partir do c�digo do usu�rio do XML de integra��o.
			If Type("_cEmailZZL") == "C"
				_cMailSol := _cEmailZZL
			EndIf
		EndIf

		_oProcess:cTo := _cMailSol

		//===============================
		// Informamos o assunto do email.
		//===============================
		_oProcess:cSubject	:= U_ITEncode(_cAssunto)

		_cMailID	:= _oProcess:fProcessId
		_cTaskID	:= _oProcess:fTaskID

		//=======================================================
		// Iniciamos a tarefa e enviamos o email ao destinat�rio.
		//=======================================================
		_oProcess:Start()

		u_itconout("Email enviado para o solicitante: " + _cMailSol + ", enviado com sucesso! Data: " + DtoC(dDataBase) + " hora: " + Time() + " Filial: " + SC5->C5_FILIAL + " Pedido: " + SC5->C5_NUM)

	EndIf

Return

/*
===============================================================================================================================
Programa----------: MOMS030K
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 08/04/2016
===============================================================================================================================
Descri��o---------: Rotina respons�vel por montar o formul�rio de aprova��o e o envio do link gerado. (Libera��o Bonifica��o)
===============================================================================================================================
Parametros--------: _cAliasSCR - Recebe o alias aberto das aprova��es dos pedidos de compras
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS030K(_cGetSol)
	Static _nValAtraso	:= 0
	Static _nValPed     := 0
	Local _aArea		:= GetArea()
	Local _aAreaSC5		:= SC5->(GetArea())
	Local _cLogo		:= _cHostWF + "htm/logo_novo.jpg"
	Local _nMCusto		:= 0
	Local _cMailApr		:= ""
	Local _cCodiApr		:= ""
	Local _cNomeApr		:= ""
	Local _cMailSol		:= ""
	Local _cFilApr		:= ""
	Local _cFilial		:= SC5->C5_FILIAL
	Local _nMCustoCli	:= 0
	Local _nLimCred		:= 0
	Local _nSalPed 		:= 0
	Local _nSalPedL		:= 0
	Local _nSalDupM		:= 0
	Local _nLcFin		:= 0
	Local _nSalFinM		:= 0
	Local _nSalDup		:= 0
	Local _nSalFin		:= 0
	Local _nMoeda		:= 0
//Local _nSalPed		:= 0
	Local _cQryDA1		:= ""
	Local _aVlrDesc		:= {}
	Local _nRecnoSC5    := SC5->(Recno())
	Local _cTab			:=""
	Local _dTab			:=""
	Local _cMCusto		:= SuperGetMv("MV_MCUSTO")
	Local _aItens       := {}
	Local _nItem        := 0
	Local _nBonif		:= 0
	Local _lEnvSolic	:= .F.

	Local _cFilSol 		:= ""
	Local _cNumPVSol 	:= ""
	Local _cCodRep 		:= ""
	Local _cNomRep 		:= ""
	Local _cCodCoo 		:= ""
	Local _cNomCoo 		:= ""
	Local _cCodGer 		:= ""
	Local _cNomGer 		:= ""
	Local _cNumPV  		:= ""
	Local _cTipoPV 		:= ""
	Local _cFilPV  		:= ""
	Local _cEmisPV 		:= ""
	Local _cCondPG		:= ""
	Local _cCondPgPad 	:= ""
	Local _cRespPed 	:= ""
	Local _cNomCli 		:= ""
	Local _cNomRed 		:= ""
	Local _cCodCli 		:= ""
	Local _cLojCli 		:= ""
	Local _cCnpjCli 	:= ""
	Local _cGrpVen 		:= ""
	Local _cContatCli 	:= ""
	Local _cFoneCli 	:= ""
	Local _cEmailCli	:= ""
	Local _cCidCli 		:= ""
	Local _cEstCli	 	:= ""
	Local _cEndCli 		:= ""
	Local _cAnaCre 		:= ""
	Local _cnTitProt  	:= ""
	Local _cnChqDev		:= ""
	Local _cnMComp 		:= ""
	Local _cnMDuplic 	:= ""
	Local _cnMAtras  	:= ""
	Local _ccVenLCr  	:= ""
	Local _ccDtLiLib 	:= ""
	Local _cnAtraAtu 	:= ""
	Local _cnLimCrl 	:= ""
	Local _cnSldHist 	:= ""
	Local _cnLimcSec 	:= ""
	Local _cn2LimcSec	:= ""
	Local _cnSldLcSe 	:= ""
	Local _cnMaiCom 	:= ""
	Local _cnMaiCom2 	:= ""
	Local _cnMaiSld 	:= ""
	Local _ccPriCom 	:= ""
	Local _ccUltCom 	:= ""
	Local _cnMaiAtr 	:= ""
	Local _cnMedAtr 	:= ""
	Local _ccGrauRis 	:= ""
	Local _ccFrete 		:= ""
	Local _ccTpCarga 	:= ""
	Local _cnQtdChap 	:= ""
	Local _ccHrDescg 	:= ""
	Local _cnCusCarg 	:= ""
	Local _cdDtEntrega 	:= ""
	Local _ccHrEntrega 	:= ""
	Local _ccSenhaEntr 	:= ""
	Local _ccTpOper 	:= ""
	Local _ccMensNF 	:= ""
	Local _ccObsPed 	:= ""
	Local _cA_FILIAL 	:= ""
	Local _cA_PEDVEN 	:= ""
	Local _cA_NOMREP 	:= ""
	Local _cA_CLIENTE 	:= ""
	Local _cA_LIMCRED 	:= ""
	Local _cA_VLRPED  	:= ""
	Local _cA_TITPRO 	:= ""
	Local _cA_MCOMP 	:= ""
	Local _cA_MDUPL 	:= ""
	Local _cA_VLCRED 	:= ""
	Local _cA_DTLIMLB 	:= ""
	Local _cA_PCOMP 	:= ""
	Local _cA_UCOMP 	:= ""
	Local _cA_GRISC		:= ""
	Local _cA_RODAP     := ""
	Local _cTipoLib		:= ""

	Do Case
	Case SC5->C5_TPFRETE = "F"
		_cTipoLib := "BLOQUEIO FRETE FOB"
	Case SC5->C5_I_OPER = '10'
		_cTipoLib := "BLOQUEIO DE BONIFICACAO"
	Case SC5->C5_I_OPER = '24'
		_cTipoLib := "BLOQUEIO DATA CRITICA"
	Case SC5->C5_I_OPER = '05'
		_cTipoLib := "BLOQUEIO OPERACAO TRIANGULAR"
	Case SC5->C5_CONDPAG = '001'
		_cTipoLib := "BLOQUEIO VENDA A VISTA"
	Otherwise
		_cTipoLib := "BLOQUEIO INEXISTENTE"
	EndCase

	For _nBonif := 1 To Len(_aAprBonif)

		_cCodiApr	:= _aAprBonif[_nBonif,1]//TRBZY0->ZY0_CODUSR
		_cNomeApr	:= _aAprBonif[_nBonif,2]//AllTrim(TRBZY0->ZY0_NOMINT)
		_cMailApr	:= _aAprBonif[_nBonif,3]//AllTrim(UsrRetMail(TRBZY0->ZY0_CODUSR)) + ";" + TRBZY0->ZY0_EMAIL
		_cFilApr	:= _aAprBonif[_nBonif,4]

		If !(!Empty(_cFilApr) .And. !(_cFilial $ _cFilApr))

			//Codigo do processo cadastrado no CFG
			_cCodProce := "LIBPVC"
			// Arquivo html template utilizado para montagem da aprova��o
			_cHtmlMode := "\Workflow\htm\libpv_bonifica.htm"
			// Assunto da mensagem
			_cAssunto := "Solicita��o de Libera��o do " + _cTipoLib + " " + SC5->C5_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1)) + " - PV N�mero: " + SUBSTR(SC5->C5_NUM,1,6)
			// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
			_oProcess := TWFProcess():New(_cCodProce,"Libera��o de Bonifica��o Pedido de Vendas")
			_oProcess:NewTask("Liberacao_PVB", _cHtmlMode)

			SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.


			If _nBonif = 1

				//====================
				//Dados do Solicitante
				//====================
				If Empty(__cUserId) .And. IsInCallStack("U_LIBERAP") // No WebService, a vari�vel __cUserID fica vazia. Ent�o o e-mail do solicitante � lido a partir do c�digo do usu�rio do XML de integra��o.
					If Type("_cEmailZZL") == "C"
						__cUserId := _cCodUsuario
					EndIf
				EndIf

				_cNomSol	:= AllTrim(UsrFullName(__cUserId))
				_cMaiSol	:= AllTrim( U_UCFG001(3) )
				_cFilSol	:= SC5->C5_FILIAL + ' - ' + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1))
				_cNumPVSol	:= SUBSTR(SC5->C5_NUM,1,6)
				_cCodRep	:= SC5->C5_VEND1
				_cNomRep	:= AllTrim(SC5->C5_I_V1NOM)
				_cCodCoo	:= SC5->C5_VEND2
				_cNomCoo	:= AllTrim(SC5->C5_I_V2NOM)
				_cCodGer	:= SC5->C5_VEND3
				_cNomGer	:= AllTrim(SC5->C5_I_V3NOM)
				_cNumPV		:= SC5->C5_NUM

				Do Case
				Case SC5->C5_TIPO == "N"
					_cTipoPV := "Normal"
				Case SC5->C5_TIPO == "C"
					_cTipoPV := "Compl.Pre�o/Quantidade"
				Case SC5->C5_TIPO == "I"
					_cTipoPV := "Compl.ICMS"
				Case SC5->C5_TIPO == "P"
					_cTipoPV := "Compl.IPI"
				Case SC5->C5_TIPO == "D"
					_cTipoPV := "Dev.Compras"
				Case SC5->C5_TIPO == "B"
					_cTipoPV := "Utiliza Fornecedor"
				EndCase

				_cFilPV  := SC5->C5_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC5->C5_FILIAL,1))
				_cEmisPV := DtoC(SC5->C5_EMISSAO)

				dbSelectArea("SE4")
				dbSetOrder(1)
				dbSeek(xFilial("SE4") + SC5->C5_CONDPAG)
				_cCondPG := SE4->E4_CODIGO + " - " + SE4->E4_DESCRI

				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

				dbSelectArea("SE4")
				dbSetOrder(1)
				dbSeek(xFilial("SE4") + SA1->A1_COND)
				_cCondPgPad := SE4->E4_CODIGO + " - " + SE4->E4_DESCRI
				_cRespPed 	:= Posicione("SRA",1,SC5->C5_I_CDUSU,"RA_NOME")

				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
				_cNomCli 	:= SA1->A1_NOME
				_cNomRed 	:= SA1->A1_NREDUZ
				_cCodCli 	:= SA1->A1_COD
				_cLojCli 	:= SA1->A1_LOJA
				_cCnpjCli 	:= MOMS030CPF(SA1->A1_CGC)
				_cGrpVen 	:= SA1->A1_GRPVEN + " - " + Posicione("ACY",1,xFilial("ACY") + SA1->A1_GRPVEN, "ACY_DESCRI")
				_cContatCli := SA1->A1_CONTATO
				_cFoneCli 	:= SA1->A1_TEL
				_cEmailCli 	:= SA1->A1_EMAIL
				_cCidCli 	:= SA1->A1_MUN
				_cEstCli 	:= SA1->A1_EST
				_cEndCli 	:= SA1->A1_END
				_cAnaCre 	:= SA1->A1_I_ACRED

				//========================
				//Informar��es Financeiras
				//========================
				DBSelectArea("SA1")
				SA1->( DBSetOrder(1) )
				SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE ) )

				While SA1->(!Eof()) .And. SA1->A1_COD == SC5->C5_CLIENTE

					_nMCustoCli	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC	, Val(_cMCusto) )
					_nLimCred	+= xMoeda( SA1->A1_LC							, _nMCustoCli , _nMCusto , Date() )
					_nSalPed 	+= xMoeda( SA1->A1_SALPED + SA1->A1_SALPEDB		, _nMCustoCli , _nMCusto , Date() )
					_nSalPedL	+= xMoeda( SA1->A1_SALPEDL						, _nMCustoCli , _nMCusto , Date() )
					_nSalDupM	+= xMoeda( SA1->A1_SALDUPM						, _nMCustoCli , _nMCusto , Date() )
					_nLcFin		+= xMoeda( SA1->A1_LCFIN						, _nMCustoCli , _nMCusto , Date() )
					_nSalFinM	+= xMoeda( SA1->A1_SALFINM						, _nMCustoCli , _nMCusto , Date() )
					_nSalDup	+= SA1->A1_SALDUP
					_nSalFin	+= SA1->A1_SALFIN

					SA1->( DBSkip() )
				EndDo

				DBSelectArea("SA1")
				SA1->( DBSetOrder(1) )
				SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )

				_nMCusto 	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC , VAL( SuperGetMv("MV_MCUSTO") ) )
				_nMoeda		:= 1

				_nValAtraso	:= MOMS030VSC( SC5->C5_CLIENTE )
				_nValPed	:= MOMS030VT2( SC5->C5_NUM , SC5->C5_FILIAL , 1 )

				_cnTitProt  := STR(SA1->A1_TITPROT,3)
				_cnChqDev	:= STR(SA1->A1_CHQDEVO,3)
				_cnMComp 	:= Transform(SA1->A1_MCOMPRA ,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto))
				_cnMDuplic 	:= Transform(SA1->A1_MAIDUPL ,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto))
				_cnMAtras  	:= Transform(SA1->A1_METR ,PesqPict("SA1","A1_METR",7))
				_ccVenLCr  	:= DtoC(SA1->A1_VENCLC)
				_ccDtLiLib 	:= DtoC(StoD(""))
				_cnAtraAtu 	:= TRansform(_nValAtraso ,PesqPict("SA1","A1_SALDUP",17,1))

				//==================
				//Posi��o do Cliente
				//==================
				_cnLimCrl 	:= TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",14,_nMCusto))
				_cnSldHist 	:= TRansform(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP",14,1))
				_cnLimcSec 	:= TRansform(Round(Noround(xMoeda(SA1->A1_LCFIN,_nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1))
				_cn2LimcSec	:= TRansform(SA1->A1_LCFIN,PesqPict("SA1","A1_LCFIN",14,_nMcusto))
				_cnSldLcSe 	:= TRansform(SA1->A1_SALFIN,PesqPict("SA1","A1_SALFIN",14,1))
				_cnMaiCom 	:= TRansform(Round(Noround(xMoeda(SA1->A1_MCOMPRA, _nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1))
				_cnMaiCom2 	:= TRansform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,_nMcusto))
				_cnMaiSld 	:= TRansform(Round(Noround(xMoeda(SA1->A1_MSALDO, _nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1))
				_ccPriCom 	:= DtoC(SA1->A1_PRICOM)
				_ccUltCom 	:= DtoC(SA1->A1_ULTCOM)
				_cnMaiAtr 	:= Transform(SA1->A1_MATR,PesqPict("SA1","A1_MATR",14))
				_cnMedAtr 	:= PADC(STR(SA1->A1_METR,7,2),22)
				_ccGrauRis 	:= SA1->A1_RISCO

				Do Case
				Case SC5->C5_TPFRETE == "C"
					_ccFrete := "CIF"
				Case SC5->C5_TPFRETE == "F"
					_ccFrete := "FOB"
				Case SC5->C5_TPFRETE == "T"
					_ccFrete := "TERCEIROS"
				Case SC5->C5_TPFRETE == "S"
					_ccFrete := "Sem Frete"
				EndCase

				_ccTpCarga 	:= Iif(SC5->C5_I_TIPCA == "1", SC5->C5_I_TIPCA + " - Paletizada", Iif(SC5->C5_I_TIPCA == "2", SC5->C5_I_TIPCA + " - Batida", ""))
				_cnQtdChap 	:= SC5->C5_I_CHAPA
				_ccHrDescg 	:= SC5->C5_I_HORDE
				_cnCusCarg 	:= "0"
				_cdDtEntrega := SC5->C5_I_DTENT
				_ccHrEntrega := SC5->C5_I_HOREN
				_ccSenhaEntr := SC5->C5_I_SENHA

				dbSelectArea("ZB4")
				dbSetOrder(1)
				dbSeek(xFilial("ZB4") + SC5->C5_I_OPER)
				_ccTpOper := SC5->C5_I_OPER + " - " + ZB4->ZB4_DESCRI
				_ccMensNF := SC5->C5_MENNOTA
				_ccObsPed := SC5->C5_I_OBPED

				_cTab:=""
				_dTab:=""

				_ctab := SC5->C5_I_TAB

				If !Empty(_cTab)
					_dtab := POSICIONE("DA0",1,xFilial("DA0")+_cTab,'DA0_DESCRI')
				End

				dbSelectArea("SC6")
				dbSetOrder(1)
				dbSeek(SC5->C5_FILIAL + SC5->C5_NUM)

				Do While !SC6->(Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM

					_cQryDA1 := "SELECT DA1_PRCVEN, DA1_I_PRCA "
					_cQryDA1 += "FROM " + RetSqlName("DA1") + " "
					_cQryDA1 += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
					_cQryDA1 += "  AND DA1_CODTAB = '" + _ctab + "' "
					_cQryDA1 += "  AND DA1_CODPRO = '" + SC6->C6_PRODUTO + "' "
					_cQryDA1 += "  AND D_E_L_E_T_ = ' ' "

					If Select("TRBDA1") > 0
						TRBDA1->(DbCloseArea())
					EndIf
					dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryDA1 ) , "TRBDA1" , .T., .F. )

					dbSelectArea("TRBDA1")
					TRBDA1->(dbGoTop())

					_aVlrDesc	:= U_veriContrato( SC5->C5_CLIENTE , SC5->C5_LOJACLI , SC6->C6_PRODUTO )

					aAdd(_aItens,{SC6->C6_ITEM,;
						SC6->C6_PRODUTO,;
						AllTrim(SC6->C6_DESCRI),;
						SC6->C6_PEDCLI,;
						Transform(SC6->C6_PRCVEN, "@E 999,999,999.999"),;
						Transform(SC6->C6_QTDVEN, PesqPict("SC6","C6_QTDVEN")),;
						SC6->C6_SEGUM,;
						Transform(SC6->C6_VALOR, PesqPict("SC6","C6_VALOR")),;
						Transform(SC6->C6_VALDESC, PesqPict("SC6","C6_VALDESC"))	,;
						Transform(SC6->C6_VALOR - SC6->C6_VALDESC, PesqPict("SC6","C6_VALOR")),;
						Transform(TRBDA1->DA1_PRCVEN, PesqPict("SC6","C6_VALOR")),;
						Transform(TRBDA1->DA1_I_PRCA, PesqPict("SC6","C6_VALOR")),;
						Transform(_aVlrDesc[1], PesqPict("SC6","C6_VALOR")),;
						Transform(SC6->C6_PRCVEN - ( ( _aVlrDesc[1] * SC6->C6_PRCVEN ) / 100 ), PesqPict("SC6","C6_VALOR")) })

					dbSelectArea("TRBDA1")
					TRBDA1->(dbCloseArea())

					SC6->(dbSkip())
				EndDo


			EndIf

			//======================================
			//Dados do cabe�alho do pedido de vendas
			//======================================
			_oProcess:oHtml:ValByName("cLogo"			, _cLogo			)
			_oProcess:oHtml:ValByName("cCodSol"			, __cUserId)
			_oProcess:oHtml:ValByName("cNomSol"			, _cNomSol )
			_oProcess:oHtml:ValByName("cMaiSol"			, _cMaiSol )//UsrRetMail(__cUserId)))
			_oProcess:oHtml:ValByName("cFilSol"			, _cFilSol)
			_oProcess:oHtml:ValByName("cNumPVSol"		, _cNumPVSol)
			_oProcess:oHtml:ValByName("cDtAtu"			, DtoC(Date()) + " - " + Time())
			_oProcess:oHtml:ValByName("cTipOper"		, "BONIFICACAO"			)

			//==================
			//Dados do Aprovador
			//==================
			_oProcess:oHtml:ValByName("cCodApr"			, _cCodiApr	)
			_oProcess:oHtml:ValByName("cNomApr"			, _cNomeApr	)
			//_oProcess:oHtml:ValByName("cCodAprovs"		, _cCodAprBonif	    )

			//======================
			//Dados do Representante
			//======================
			_oProcess:oHtml:ValByName("cCodRep"			, _cCodRep	)
			_oProcess:oHtml:ValByName("cNomRep"			, _cNomRep	)

			//====================
			//Dados do Coordenador
			//====================
			_oProcess:oHtml:ValByName("cCodCoo"			, _cCodCoo	)
			_oProcess:oHtml:ValByName("cNomCoo"			, _cNomCoo	)

			//================
			//Dados do Gerente
			//================
			_oProcess:oHtml:ValByName("cCodGer"			, _cCodGer	)
			_oProcess:oHtml:ValByName("cNomGer"			, _cNomGer	)

			//===============
			//Dados do Pedido
			//===============
			_oProcess:oHtml:ValByName("cNumPV"		, _cNumPV	)
			_oProcess:oHtml:ValByName("cTipoLib"	, _cTipoLib	)
			_oProcess:oHtml:ValByName("cTipoPV"		, _cTipoPV	)
			_oProcess:oHtml:ValByName("cFilPV"		, _cFilPV	)
			_oProcess:oHtml:ValByName("cEmisPV"		, _cEmisPV	)

			_oProcess:oHtml:ValByName("cCondPG"		, _cCondPG	)
			_oProcess:oHtml:ValByName("cCondPgPad"	, _cCondPgPad	)
			_oProcess:oHtml:ValByName("cRespPed"	, _cRespPed		)

			//================
			//Dados do Cliente
			//================
			_oProcess:oHtml:ValByName("cNomCli"			, _cNomCli	)
			_oProcess:oHtml:ValByName("cNomRed"			, _cNomRed	)
			_oProcess:oHtml:ValByName("cCodCli"			, _cCodCli	)
			_oProcess:oHtml:ValByName("cLojCli"			, _cLojCli	)
			_oProcess:oHtml:ValByName("cCnpjCli"		, _cCnpjCli	)
			_oProcess:oHtml:ValByName("cGrpVen"			, _cGrpVen	)
			_oProcess:oHtml:ValByName("cContatCli"		, _cContatCli)
			_oProcess:oHtml:ValByName("cFoneCli"		, _cFoneCli	)
			_oProcess:oHtml:ValByName("cEmailCli"		, _cEmailCli)
			_oProcess:oHtml:ValByName("cCidCli"			, _cCidCli	)
			_oProcess:oHtml:ValByName("cEstCli"			, _cEstCli	)
			_oProcess:oHtml:ValByName("cEndCli"			, _cEndCli	)
			_oProcess:oHtml:ValByName("cAnaCre"			, _cAnaCre	)

			//========================
			//Informar��es Financeiras
			//========================
			_oProcess:oHtml:ValByName("nLimCrd"			, TRansform(_nLimCred,PesqPict("SA1","A1_LC",17,1)))
			_oProcess:oHtml:ValByName("nTitAber"		, TRansform(_nSalDup,PesqPict("SA1","A1_SALDUP",17,1)))
			_oProcess:oHtml:ValByName("nTitVenc"		, TRansform(_nSalPedL,PesqPict("SA1","A1_SALPEDL",17,1)))
			_oProcess:oHtml:ValByName("nSLimCrd"		, TRansform(_nLimCred-_nSaldupM-_nSalPedL,PesqPict("SA1","A1_SALDUP",17,1)))
			_oProcess:oHtml:ValByName("nPedAtu"			, TRansform(_nValPed ,PesqPict("SA1","A1_SALDUP",17,1)))
			_oProcess:oHtml:ValByName("nSalNFat"		, TRansform(_nSalPed ,PesqPict("SA1","A1_SALPED",17,1)))
			_oProcess:oHtml:ValByName("nLimCChe"		, TRansform(_nLcFin ,PesqPict("SA1","A1_LCFIN",17,1)))
			_oProcess:oHtml:ValByName("nSldChq"			, TRansform(_nSalFin ,PesqPict("SA1","A1_SALDUP",17,1)))

			_oProcess:oHtml:ValByName("nTitProt"		, _cnTitProt)
			_oProcess:oHtml:ValByName("nChqDev"			, _cnChqDev)
			_oProcess:oHtml:ValByName("nMComp"			, _cnMComp)
			_oProcess:oHtml:ValByName("nMDuplic"		, _cnMDuplic)
			_oProcess:oHtml:ValByName("nMAtras"			, _cnMAtras)
			_oProcess:oHtml:ValByName("cVenLCr"			, _ccVenLCr)
			_oProcess:oHtml:ValByName("cDtLiLib"		, _ccDtLiLib)
			_oProcess:oHtml:ValByName("nAtraAtu"		, _cnAtraAtu)

			//==================
			//Posi��o do Cliente
			//==================
			_oProcess:oHtml:ValByName("nLimCrl"			, _cnLimCrl					)
			_oProcess:oHtml:ValByName("nSldHist"		, _cnSldHist				)
			_oProcess:oHtml:ValByName("nLimcSec"		, _cnLimcSec, _cn2LimcSec 	)
			_oProcess:oHtml:ValByName("nSldLcSe"		, _cnSldLcSe				)
			_oProcess:oHtml:ValByName("nMaiCom"			, _cnMaiCom, _cnMaiCom2 	)
			_oProcess:oHtml:ValByName("nMaiSld"			, _cnMaiSld					)
			_oProcess:oHtml:ValByName("cPriCom"			, _ccPriCom					)
			_oProcess:oHtml:ValByName("cUltCom"			, _ccUltCom					)
			_oProcess:oHtml:ValByName("nMaiAtr"			, _cnMaiAtr					)
			_oProcess:oHtml:ValByName("nMedAtr"			, _cnMedAtr					)
			_oProcess:oHtml:ValByName("cGrauRis"		, _ccGrauRis				)

			//===============================
			//Informa��es do Pedido de Vendas
			//===============================
			_oProcess:oHtml:ValByName("cFrete"			, _ccFrete		)
			_oProcess:oHtml:ValByName("cTpCarga"		, _ccTpCarga	)
			_oProcess:oHtml:ValByName("nQtdChap"		, _cnQtdChap	)
			_oProcess:oHtml:ValByName("cHrDescg"		, _ccHrDescg	)
			_oProcess:oHtml:ValByName("nCusCarg"		, _cnCusCarg	)
			_oProcess:oHtml:ValByName("dDtEntrega"		, _cdDtEntrega	)
			_oProcess:oHtml:ValByName("cHrEntrega"		, _ccHrEntrega	)
			_oProcess:oHtml:ValByName("cSenhaEntr"		, _ccSenhaEntr	)
			_oProcess:oHtml:ValByName("cTpOper"			, _ccTpOper		)
			_oProcess:oHtml:ValByName("cMensNF"			, _ccMensNF		)
			_oProcess:oHtml:ValByName("cObsPed"			, _ccObsPed		)

			//=========================================
			//Informa��es dos itens do Pedido de Vendas
			//=========================================
			For _nItem := 1 To Len(_aItens)

				aAdd( _oProcess:oHtml:ValByName("Itens.cItem" 			), _aItens[_nItem,01]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cProdPV" 		), _aItens[_nItem,02]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cDescPV"			), _aItens[_nItem,03]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cNumPCli"		), _aItens[_nItem,04]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPrcVen"			), _aItens[_nItem,05]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nQuantPV"		), _aItens[_nItem,06]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.cUM"				), _aItens[_nItem,07]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nTotalPV"	   	), _aItens[_nItem,08]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nDescont"		), _aItens[_nItem,09] 	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nTotGer"			), _aItens[_nItem,10]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPrcMin"			), _aItens[_nItem,11]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPrcMax"			), _aItens[_nItem,12]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPerCon"			), _aItens[_nItem,13]	)
				aAdd( _oProcess:oHtml:ValByName("Itens.nPrcNet"			), _aItens[_nItem,14]	)

			Next


			_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol			)
			//=========================================================================
			// Informe o nome da fun��o de retorno a ser executada quando a mensagem de
			// respostas retornar ao Workflow:
			//=========================================================================
			_oProcess:bReturn := "U_MOMS030R"

			//========================================================================
			// Ap�s ter repassado todas as informac�es necess�rias para o Workflow,
			// execute o m�todo Start() para gerar todo o processo e enviar a mensagem
			// ao destinat�rio.
			//========================================================================
			_cMailID	:= _oProcess:Start("\workflow\emp01")
			_cLink		:= _cMailID

			If File("\workflow\emp01\" + _cMailID + ".htm")
				U_ITCONOUT("Arquivo \workflow\emp01\" + _cMailID + ".htm criado com sucesso.")
			ELSE
				U_ITCONOUT("Arquivo \workflow\emp01\" + _cMailID + ".htm n�o encotrado.")
			EndIf

			//====================================
			//Codigo do processo cadastrado no CFG
			//====================================
			_cCodProce := "LIBPVBON"

			//======================================================================
			// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
			//======================================================================
			_oProcess := TWFProcess():New(_cCodProce,"Libera��o PV Bonifica��o")

			SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

			//=================================================================
			// Criamos o link para o arquivo que foi gerado na tarefa anterior.
			//=================================================================
			_oProcess:NewTask("LINK", "\workflow\htm\pvboni_link.htm")

			_chtmlfile	:= _cLink + ".htm"
			_cMailTo	:= "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + AllTrim(GetMV('MV_WFMLBOX')), "WF7_ENDERE"))
			U_ITCONOUT("Lendo Arquivo \workflow\emp01\" + _chtmlfile)
			_chtmltexto := wfloadfile("\workflow\emp01\" + _chtmlfile )
			_chtmltexto := strtran( _chtmltexto, _cmailto, "WFHTTPRET.APL" )
			wfsavefile("\workflow\emp"+cEmpAnt+"\" + _chtmlfile, _chtmltexto)
			U_ITCONOUT("Gravou Arquivo \workflow\emp"+cEmpAnt+"\" + _chtmlfile)

			_cLink := _cHostWF + "emp01/" + _cLink + ".htm"

			If _nBonif = 1
				_cA_FILIAL 	:= _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1)
				_cA_PEDVEN 	:= SC5->C5_NUM
				_cA_NOMREP 	:= SC5->C5_VEND1 + " - " + AllTrim(SC5->C5_I_V1NOM)
				_cA_CLIENTE := SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME
				_cA_LIMCRED := TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1))
				_cA_VLRPED  := TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1))
				_cA_TITPRO 	:= STR(SA1->A1_TITPROT,3)
				_cA_MCOMP 	:= Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto))
				_cA_MDUPL 	:= Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto))
				_cA_VLCRED 	:= DtoC(SA1->A1_VENCLC)
				_cA_DTLIMLB := DtoC(StoD(""))
				_cA_PCOMP 	:= DtoC(SA1->A1_PRICOM)
				_cA_UCOMP 	:= DtoC(SA1->A1_ULTCOM)
				_cA_GRISC 	:= SA1->A1_RISCO
				_cA_RODAP   := GETENVSERVER()
			EndIf
			//=====================================
			// Populo as vari�veis do template html
			//=====================================
			_oProcess:oHtml:ValByName("cTipoLib"		, _cTipoLib		)
			_oProcess:oHtml:ValByName("cLogo"		, _cLogo		)
			_oProcess:oHtml:ValByName("A_FILIAL"	, _cA_FILIAL	)
			_oProcess:oHtml:ValByName("A_PEDVEN"	, _cA_PEDVEN	)
			_oProcess:oHtml:ValByName("A_LINK"		, _cLink		)
			_oProcess:oHtml:ValByName("A_NOMREP"	, _cA_NOMREP	)
			_oProcess:oHtml:ValByName("A_CLIENTE"	, _cA_CLIENTE	)
			_oProcess:oHtml:ValByName("A_LIMCRED"	, _cA_LIMCRED	)
			_oProcess:oHtml:ValByName("A_VLRPED"	, _cA_VLRPED	)
			_oProcess:oHtml:ValByName("A_TITPRO"	, _cA_TITPRO	)
			_oProcess:oHtml:ValByName("A_MCOMP"		, _cA_MCOMP		)
			_oProcess:oHtml:ValByName("A_MDUPL"		, _cA_MDUPL		)
			_oProcess:oHtml:ValByName("A_VLCRED"	, _cA_VLCRED	)
			_oProcess:oHtml:ValByName("A_DTLIMLB"	, _cA_DTLIMLB	)
			_oProcess:oHtml:ValByName("A_PCOMP"		, _cA_PCOMP		)
			_oProcess:oHtml:ValByName("A_UCOMP"		, _cA_UCOMP		)
			_oProcess:oHtml:ValByName("A_GRISC"		, _cA_GRISC		)
			_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol		)
			_oProcess:oHtml:ValByName("A_RODAP"		, _cA_RODAP		)

			//================================================================
			// Informamos o destinat�rio (aprovador) do email contendo o link.
			//================================================================
			_oProcess:cTo := _cMailApr

			//===============================
			// Informamos o assunto do email.
			//===============================
			_oProcess:cSubject	:= U_ITEncode(_cAssunto)

			_cMailID	:= _oProcess:fProcessId
			_cTaskID	:= _oProcess:fTaskID

			//=======================================================
			// Iniciamos a tarefa e enviamos o email ao destinat�rio.
			//=======================================================
			_oProcess:Start()

			u_itconout("Email enviado para o aprovador: " + _cMailApr + ", enviado com sucesso! Data: " + DtoC(dDataBase) + " hora: " + Time() + " Filial: " + SC5->C5_FILIAL + " Pedido: " + SC5->C5_NUM)

			_lEnvSolic := .T.
			_cEmaisEnv += _aAprBonif[_nBonif,2] + "  E-mail: " +_aAprBonif[_nBonif,3] + CHR(13) + CHR(10)

		EndIf

		u_itconout("Email enviado para o solicitante: " + _cMailSol + ", enviado com sucesso! Data: " + DtoC(dDataBase) + " hora: " + Time() + " Filial: " + SC5->C5_FILIAL + " Pedido: " + SC5->C5_NUM)

		RestArea(_aArea)
		RestArea(_aAreaSC5)
	Next


//==========================================================
//Monta e faz o envio ao solicitante da aprova��o de Cr�dito
//==========================================================
	If _lEnvSolic
		//====================================
		//Codigo do processo cadastrado no CFG
		//====================================
		_cCodProce := "LIBPVBON"

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a vari�vel objeto oProcess:
		//======================================================================
		_oProcess := TWFProcess():New(_cCodProce,"Libera��o PV Bonifica��o - Solicitante")

		SC5->(DbGoTo(_nRecnoSC5)) // Ao rodar o comando TWFProcess():New, a tabela SC5 estava sendo desposicionada. Esta instru��o reposiciona a tabela SC5.

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================
		_oProcess:NewTask("LINK", "\workflow\htm\pvboni_solic.htm")

		//=====================================
		// Populo as vari�veis do template html
		//=====================================
		_oProcess:oHtml:ValByName("cLogo"		, _cLogo)
		_oProcess:oHtml:ValByName("cTipoLib"	, _cTipoLib	)
		_oProcess:oHtml:ValByName("A_FILIAL"	, _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1))
		_oProcess:oHtml:ValByName("A_PEDVEN"	, SC5->C5_NUM)
		_oProcess:oHtml:ValByName("A_NOMREP"	, SC5->C5_VEND1 + " - " + AllTrim(SC5->C5_I_V1NOM))
		_oProcess:oHtml:ValByName("A_CLIENTE"	, SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME)
		_oProcess:oHtml:ValByName("A_LIMCRED"	, TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1)))
		_oProcess:oHtml:ValByName("A_VLRPED"	, TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1)))
		_oProcess:oHtml:ValByName("A_TITPRO"	, STR(SA1->A1_TITPROT,3))
		_oProcess:oHtml:ValByName("A_MCOMP"		, Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto)))
		_oProcess:oHtml:ValByName("A_MDUPL"		, Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto)))
		_oProcess:oHtml:ValByName("A_VLCRED"	, DtoC(SA1->A1_VENCLC))
		_oProcess:oHtml:ValByName("A_DTLIMLB"	, DtoC(StoD("")))
		_oProcess:oHtml:ValByName("A_PCOMP"		, DtoC(SA1->A1_PRICOM))
		_oProcess:oHtml:ValByName("A_UCOMP"		, DtoC(SA1->A1_ULTCOM))
		_oProcess:oHtml:ValByName("A_GRISC"		, SA1->A1_RISCO)
		_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol)
		_oProcess:oHtml:ValByName("Texto01"		, "Aprovadores:")//AWF-09/06/2016
		_oProcess:oHtml:ValByName("Texto02"		, _cAprBonif)
		_oProcess:oHtml:ValByName("A_RODAP"		, _cA_RODAP)

		//================================================================
		// Informamos o destinat�rio (aprovador) do email contendo o link.
		//================================================================
		_cMailSol := AllTrim( U_UCFG001(3) ) //UsrRetMail(__cUserID))

		If Empty(_cMailSol) .And. IsInCallStack("U_LIBERAP") // No WebService, a vari�vel __cUserID fica vazia. Ent�o o e-mail do solicitante � lido a partir do c�digo do usu�rio do XML de integra��o.
			If Type("_cEmailZZL") == "C"
				_cMailSol := _cEmailZZL
			EndIf
		EndIf

		_oProcess:cTo := _cMailSol

		//===============================
		// Informamos o assunto do email.
		//===============================
		_oProcess:cSubject	:= U_ITEncode(_cAssunto)

		_cMailID	:= _oProcess:fProcessId
		_cTaskID	:= _oProcess:fTaskID

		//=======================================================
		// Iniciamos a tarefa e enviamos o email ao destinat�rio.
		//=======================================================
		_oProcess:Start()

	EndIf

Return

/*
===============================================================================================================================
Programa----------: MOMS030C6
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 08/04/2016
===============================================================================================================================
Descri��o---------: Rotina respons�vel por montar o formul�rio de aprova��o e o envio do link gerado. (Libera��o Bonifica��o)
===============================================================================================================================
Parametros--------: _cFilial	- Filial do Pedido de Vendas
------------------: _cNumPV		- N�mero do Pedido de Vendas
------------------: _cCodApr	- C�digo do Aprovador
------------------: _cTipo		- Tipo de libera��o (C = Cr�dito, P = Pre�o, B = Bonifica��o)
------------------: _cObs		- Observa��o digitada pelo aprovador
------------------: _cBloq		- Status do pedido se liberado "L" ou rejeitado "R"
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS030C6(_cFilial, _cNumPV, _cCodApr, _cTipo, _cObs, _cBloq)

	Local _aArea		:= GetArea()
	Local _cUsrBkp	:= __cUserId

	Default _cFilial	:= "01"
	Default _cNumPV	:= ""
	Default _cCodApr	:= ""
	Default _cTipo	:= "C"
	Default _cObs		:= ""
	Default _cBloq	:= "L"

	__cUserId := _cCodApr

	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(_cFilial + _cNumPV)

//===============================
//Libera itens do pedido de venda
//===============================
	While !SC6->(Eof()) .And. SC6->C6_NUM == _cNumPV

		If _cTipo == "C"	// Libera��o de Cr�dito
			RecLock("SC6", .F.)
			SC6->C6_I_LIBPE := U_UCFG001(1)
			SC6->C6_I_BLPRC := _cBloq
			SC6->C6_I_LIBPC	:= 2
			MsUnLock()
		EndIf

		If _cTipo == "P"	// Libera��o de Pre�o
			RecLock("SC6", .F.)
			SC6->C6_I_BLPRC	:= _cBloq
			SC6->C6_I_LLIBP := SC6->C6_LOJA
			SC6->C6_I_CLILP := SC6->C6_CLI
			SC6->C6_I_VLIBP := SC6->C6_PRCVEN
			SC6->C6_I_QTLIP := SC6->C6_QTDVEN
			SC6->C6_I_MOTLP := _cObs
			SC6->C6_I_DLIBP	:= Date()
			SC6->C6_I_PLIBP	:= (Date() + 30)
			SC6->C6_I_ULIBP  := U_UCFG001(2)
			SC6->C6_I_LIBPE  := U_UCFG001(1)
			MsUnLock()
		EndIf

		If _cTipo == "B"	// Libera��o de Bonifica��o
			RecLock("SC6", .F.)
			SC6->C6_I_LLIBB	:= SC6->C6_LOJA
			SC6->C6_I_CLILB	:= SC6->C6_CLI
			SC6->C6_I_VLIBB	:= SC6->C6_PRCVEN
			SC6->C6_I_QLIBB	:= SC6->C6_QTDVEN
			SC6->C6_I_MOTLB	:= _cObs
			SC6->C6_I_DLIBB	:= Date()
			SC6->C6_I_PLIBB	:= Date() + 30
			MsUnLock()
		EndIf

		SC6->(dbSkip())
	End

	__cUserId := _cUsrBkp

	RestArea(_aArea)
Return

/*
===============================================================================================================================
Programa----------: MOMS030W
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 17/05/2017
===============================================================================================================================
Descri��o---------: Rotina envia WF chamada por um Webservice
===============================================================================================================================
Parametros--------: _cGetSol	- Motivo da Solicita��o de Libera��o
===============================================================================================================================
Retorno-----------: _lRet 		- Quando .T. Libera��o enviada e .F. falha no envio
------------------: cNaousa     - Sendo passado o numero do pedido de venda e n�o usado pois j� esta posicionado no registro
===============================================================================================================================
*/
User Function MOMS030W(cNaousa,_cGetSol)
	Local _aArea		:= GetArea()
	Local _cBlqCre		:= " "
	Local _cBlqPre		:= " "
	Local _cBlqBon		:= " "
	Local _nRecC5       := SC5->(Recno())
	Local _lWFHTML		:= .T.
	Local _lCliBlq		:= .F.
	Local _lRet		    := .T. //"WF de libera��o de pedido de vendas enviado com sucesso."
	Local _cTempoWF     := U_ITGETMV("IT_TMPLIBWF","00:30:00") // Padrao de preenchimento do parametro: Tempo em HH:MM:SS
	Local _cHora        := ""
		
	Default _cGetSol	:= Space(100)

	//Se esta sendo chamado via AOMS074 (WS RDC X PROTHEUS)
	If IsInCallStack("U_AOMS074") 
		_cGetSol := "Solicitado pela Log�stica via RDC"
	Endif

	//INICIO
	If SC5->C5_I_DTUWF >= Date() .or. Empty(Alltrim(SC5->C5_I_DTUWF))
		If SC5->C5_I_DTUWF > Date()
			lContinua := .T.
		Else
			cTime := TIME()
			nDif := ELAPTIME( SC5->C5_I_HRUWF, cTime )

			If nDif > _cTempoWF
				lContinua := .T.
			Else
				_cHora := SomaHoras (SC5->C5_I_HRUWF,_cTempoWF)
				lContinua := .F.
			EndIf
		EndIf
	Else
		lContinua := .T.
	EndIf

	//FIM

	If lContinua
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

		If SA1->A1_MSBLQL == "1"
			_lCliBlq := .T.
		EndIf

		If !_lApr // Se .T. j� foi alimentado os arrays dos aprovadores
			_lApr := MOMS030A() //Alimenta os arrays dos aprovadores
		EndIf

		_lWFHTML	:= GetMv("MV_WFHTML") //Coleta conteudo do par�metro

		PutMV("MV_WFHTML",.T.) // Habilita html no corpo da msg

		SC5->(Dbgoto(_nRecC5))

		_cBlqCre := SC5->C5_I_BLCRE
		_cBlqPre := SC5->C5_I_BLPRC
		_cBlqBon := SC5->C5_I_BLOQ

		If _cBlqBon == 'B' //Solicita Libera��o Bonifica��o/FOB/Data Critica

			If Len(_aAprBonif) > 0
				U_MOMS030K(_cGetSol)
			Else
				_lRet := .F. //"Falha no envio de solicita��o de libera��o! N�o h� aprovadores para o pedido."
			EndIf

		ElseIf _cBlqPre == 'B' //Solicita Libera��o por Pre�o

			If Len(_aAprPreco) > 0
				U_MOMS030O(_cGetSol)
			Else
				_lRet := .F.
			EndIf

		ElseIf _cBlqCre == 'B' .Or. _lCliBlq //Solicita Libera��o por Cr�dito

			If Len(_aAprCredito) > 0
				U_MOMS030P(_cBlqCre, _lCliBlq, _cGetSol)
			Else
				_lRet := .F.
			EndIf
		Else
			_lRet := .F.
		EndIf

		PutMV("MV_WFHTML",_lWFHTML) // Restaura conteudo do par�metro
	EndIf

	If _lRet
		RecLock("SC5", .F.)
		SC5->C5_I_DTUWF := Date()
		SC5->C5_I_HRUWF := Time()
		MsUnlock()	
	EndIf

	RestArea(_aArea)

Return _lRet



/*
===============================================================================================================================
Programa----------: MOMS030A
Autor-------------: Igor Melga�o
Data da Criacao---: 14/05/2021
===============================================================================================================================
Descri��o---------: Rotina que alimenta os arrays dos aprovadores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function MOMS030A()
	Local _cQryZY0 := ""

//==========================
//Pega os dados dos aprovadores
//==========================
	_cQryZY0 := "SELECT * "
	_cQryZY0 += "FROM " + RetSqlName("ZY0") + " "
	_cQryZY0 += "WHERE ZY0_FILIAL = '" + xFilial("ZY0") + "' "
	_cQryZY0 += "  AND ZY0_ATIVO = 'S' "
	_cQryZY0 += "  AND D_E_L_E_T_ = ' ' "
 
	If Select("TRBZY0") > 0
		TRBZY0->(DbCloseArea())
	EndIf
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryZY0 ) , "TRBZY0" , .T., .F. )

	dbSelectArea("TRBZY0")
	TRBZY0->(dbGoTop())

	Do While !TRBZY0->(EOF())

		IF TRBZY0->ZY0_TIPO = 'C'//Solicita Libera��o por Cr�dito
			AADD(_aAprCredito,{TRBZY0->ZY0_CODUSR,AllTrim(TRBZY0->ZY0_NOMINT),Alltrim(TRBZY0->ZY0_EMAIL)})
			_cAprCredito   +=AllTrim(TRBZY0->ZY0_NOMINT)+", "

		ELSEIF TRBZY0->ZY0_TIPO = 'P'//Solicita Libera��o por Pre�o
			AADD(_aAprPreco  ,{TRBZY0->ZY0_CODUSR,AllTrim(TRBZY0->ZY0_NOMINT),Alltrim(TRBZY0->ZY0_EMAIL),TRBZY0->ZY0_FILAPR})
			_cAprPreco   +=AllTrim(TRBZY0->ZY0_NOMINT)+", "

		ELSEIF TRBZY0->ZY0_TIPO = 'B'//Solicita Libera��o por Bonifica��o
			AADD(_aAprBonif  ,{TRBZY0->ZY0_CODUSR,AllTrim(TRBZY0->ZY0_NOMINT),Alltrim(TRBZY0->ZY0_EMAIL),TRBZY0->ZY0_FILAPR})
			_cAprBonif   +=AllTrim(TRBZY0->ZY0_NOMINT)+", "

		ENDIF
		TRBZY0->(DBSKIP())

	EndDo

	_cAprCredito:= LEFT(_cAprCredito,LEN(_cAprCredito)-2)
	_cAprPreco  := LEFT(_cAprPreco  ,LEN(_cAprPreco  )-2)
	_cAprBonif	:= LEFT(_cAprBonif	,LEN(_cAprBonif	 )-2)

	dbSelectArea("TRBZY0")
	TRBZY0->(dbCloseArea())

Return .T.
