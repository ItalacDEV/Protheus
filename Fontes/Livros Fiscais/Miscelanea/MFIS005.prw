/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |08/08/2024| Chamado 48156. Inclu�do item XMLs corrompidos na fila do TOTVS Colabora��o
Lucas Borges  |16/04/2025| Chamado 50480. Inclu�da valida��o para documentos recusados
Lucas Borges  |29/05/2025| Chamado 50833. Inclu�do evento 610110
===============================================================================================================================
*/

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MFIS005
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/01/2020
Descri��o---------: Workflow para verificar as inconsistencias nos Livros Fiscais. Chamado: 5200
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS005

Local _aArea 		:= FWGetArea() as Array
Local _oSelf		:= nil as Object
Local _cPerg		:= "MFIS005" as String
Local _cTitulo		:= "Workflow Inconsist�ncias Fiscais" as Strig
Local _cTexto		:= "Rotina para avaliar poss�veis inconsist�ncias na escritura��o de documentos fiscais, bem como nos Livros Fiscais." as String

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	_cPerg						,; // cFunction. Nome da fun��o que est� chamando o objeto
					_cTitulo					,; // cTitle. T�tulo da �rvore de op��es
					{|_oSelf| MFIS005P(_oSelf) },; // bProcess. Bloco de execu��o que ser� executado ao confirmar a tela
					_cTexto 					,; // cDescription. Descri��o da rotina
					_cPerg						,; // cPerg. Nome do Pergunte (SX1) a ser utilizado na rotina
					{}							,; // aInfoCustom. Informa��es adicionais carregada na �rvore de op��es. Estrutura:[1] - Nome da op��o[2] - Bloco de execu��o[3] - Nome do bitmap[4] - Informa��es do painel auxiliar.
					.F.							,; // lPanelAux. Se .T. cria um novo painel auxiliar ao executar a rotina
					0							,; // nSizePanelAux. Tamanho do painel auxiliar, utilizado quando lPanelAux = .T.
					''							,; // cDescriAux. Descri��o a ser exibida no painel auxiliar
					.T.							,; // lViewExecute. Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento
					.T.							,; // lOneMeter. Se .T. cria apenas uma r�gua de processamento
					.T.							)  // lSchedAuto. Se .T. habilita o bot�o de processamento em segundo plano (execu��o ocorre pelo Scheduler)

FWRestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: MFIS005P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/01/2020
Descri��o---------: Realiza o processamento da rotina.
Parametros--------: _oSelf
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS005P(_oSelf as Object)

Local _aSelFil		:= {} as Array
Local _aTitulos 	:= {} as Array
Local _aDocs		:= {} as Array
Local _aCabec		:= {} as Array
Local _nX			:= 0 as Numeric
Local _cArqLog		:= SuperGetMV("MV_RELT",.F.,"\spool\") + "wfstsnf_"+ DtoS(Date()) +"_"+ StrTran(Time(),":","") + ".htm" As Character//Nome do arquivo anexo a ser enviado ao usuario
Local _oArquivo		:= Nil as Object

_oArquivo:= FWFileWriter():New(_cArqLog)

If !_oArquivo:Create()
	FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MFIS005001"/*cMsgId*/, "Arquivo de Log n�o pode ser criado. Rotina ser� interrompida!"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	FWAlertWarning("Arquivo de Log n�o pode ser criado. Rotina ser� interrompida!","MFIS005001")
	Return
Else
	/*
	MV_PAR01-MV_PAR02	-> Data de/at�
	MV_PAR03			-> Seleciona Filiais
	MV_PAR04			-> Dias atraso escritura��o
	MV_PAR05			-> Corrige Data Canc. Dif 1 dia
	*/

	//====================================================================================================
	//Lista com as consultas que dever�o ser feitas no banco
	//====================================================================================================
	aAdd(_aTitulos,{"01","Quebra de Sequ�ncia de Numera��o"})
	aAdd(_aTitulos,{"02","Notas de emiss�o pr�pria com a chave gravada errada (n�mero)"})
	aAdd(_aTitulos,{"03","Notas de emiss�o pr�pria que possuem chave, est�o canceladas, mas sem status de cancelada"})
	aAdd(_aTitulos,{"04","Notas de emiss�o pr�pria que n�o possuem chave e que n�o est�o com os status de de negadas. Ou elas est�o com o status errado ou faltam a chave"})
	aAdd(_aTitulos,{"05","Notas de emiss�o pr�pria que possuem chave e que est�o com os status de de negadas"})
	aAdd(_aTitulos,{"06","Notas de emiss�o pr�pria que est�o com status indevidos e precisam ser analisadas"})
	aAdd(_aTitulos,{"07","Notas fiscais de entrada que foram lan�adas em duplicidade, ou seja, a mesma nota foi lan�ada em mais de uma filial"})
	aAdd(_aTitulos,{"08","Notas ficais e conhecimentos de transporte eletr�nicos lan�adas com s�rie ou esp�cie errada"})
	aAdd(_aTitulos,{"09","Notas de emiss�o pr�pria que n�o s�o do tipo SPED ou NFA"})
	aAdd(_aTitulos,{"10","Notas cuja emiss�o est� diferente da emiss�o que consta na Chave"})
	aAdd(_aTitulos,{"11","Verifica as notas cuja chave n�o possui os 44 caracteres obrigat�rios"})
	aAdd(_aTitulos,{"12","Notas de entrada que n�o s�o de emiss�o pr�pria e que o CNPJ utilizado na chave n�o pertence ao cliente/fornecedor"})
	aAdd(_aTitulos,{"13","Notas de entrada e sa�da, de emiss�o pr�pria e que o CNPJ utilizado na chave n�o pertence emissor"})
	aAdd(_aTitulos,{"14","Notas fiscais que n�o s�o eletr�nicas est�o com chave preenchida e se as eletr�nicas est�o com o modelo correto"})
	aAdd(_aTitulos,{"15","Notas fiscais que est�o com Status de cancelada, por�m n�o est�o com a data de cancelamento preenchida"})
	aAdd(_aTitulos,{"16","Notas fiscais que est�o com Chave errada"})
	aAdd(_aTitulos,{"17","Notas fiscais que n�o s�o formul�rio pr�prio e tem o retorno da SEFAZ preenchido"})
	aAdd(_aTitulos,{"18","Notas cuja entrada est� muito superior � emiss�o, caracterizando um poss�vel erro na data de emiss�o"})
	aAdd(_aTitulos,{"19","Data Cancelamento no Sistema em m�s divergente da SEFAZ. Diverg�ncias de 1 dia s�o movidas para dentro do m�s."})
	aAdd(_aTitulos,{"20","Notas cujo Retorno do SPED FISCAL no Sistema est� divergente do Retorno da SEFAZ"})
	aAdd(_aTitulos,{"21","Notas de devolu��o que n�o est�o devidamente amarradas com sua nota de origem"})
	aAdd(_aTitulos,{"22","T�tulos gerados pela apura��o e que n�o foram baixados ou possuem inconsist�ncias"})
	aAdd(_aTitulos,{"23","Documentos escriturados que foram recusados na SEFAZ"})
	aAdd(_aTitulos,{"24","NF-e com chave incorreta e/ou irregularidade nos Livros Fiscais."})
	aAdd(_aTitulos,{"25","Inutiliza��es que n�o geraram Livro Fiscal"})
	aAdd(_aTitulos,{"26","Devolu��es referenciando notas futuras"})
	aAdd(_aTitulos,{"27","NF-e Formul�rio Pr�prio do Fornecedor"})
	aAdd(_aTitulos,{"28","Documento com vinculo errado com o Monitor do Colabora��o (Esp�cie ou chave errada)"})
	aAdd(_aTitulos,{"29","Documentos com prazo para manifesta��o expirando"})
	aAdd(_aTitulos,{"30","XMLs corrompidos na fila do TOTVS Colabora��o"})

	_oSelf:SaveLog("Inicio do processamento")
	If !FWGetRunSchedule()
		If MV_PAR03 == 1
			If Empty(_aSelFil)
				_aSelFil := AdmGetFil(.F.,.F.,"SF1")
			EndIf
		Else
			Aadd(_aSelFil,cFilAnt)
		EndIf
	EndIf

	_oSelf:SetRegua1(Len(_aTitulos))

	For _nX:= 1 to Len(_aTitulos)
		_oSelf:IncRegua1(_aTitulos[_nX][01]+' - '+_aTitulos[_nX][02])
		//Busca registros para serem exibidos
		MFIS005Q(_aCabec, _aDocs, _nX, _aSelFil)
		//Monta HTML com os registros para serem exibidos
		MFIS005H(_aTitulos, _aCabec, _aDocs, _nX, _oArquivo)
	Next _nX

	//Realiza o envio do e-mail
	MFIS005E(_cArqLog)

	//==================================================================
	//Verifica e apaga o arquivo temporario ao final do processamento
	//==================================================================
	_oArquivo:erase()
	_oArquivo:= FWFileWriter():New(StrTran(_cArqLog,".htm",".zip"))
	_oArquivo:erase()
	FreeObj(_oArquivo)
	_oSelf:SaveLog("Fim do processamento")
EndIf

Return

/*
===============================================================================================================================
Programa----------: MFIS005Q
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/01/2020
Descri��o---------: Realiza consultas no banco buscando as inconsist�ncias
Parametros--------: _aCabec	-> A -> Array para armazenar o cabe�alho das colunas
					_aDocs	-> A -> Array para armazenar o retorno das querys
					_nX		-> N -> Posi��o do array _aTitulos, indicando qual query deve ser executada
					_aSelFil-> A -> Array com as filiais que devem ser processadas
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS005Q(_aCabec As Array, _aDocs As Array, _nX As Numeric, _aSelFil as Array)

Local _cAlias 	:= GetNextAlias() As Character
Local _cFiltro	:= "" As Character
Local _cFilSF1	:= "%%" As Character
Local _cFilSF3	:= "%%" As Character
Local _cFilSFT	:= "%%" As Character
Local _cFilSE2	:= "%%" As Character
Local _cFilSM0	:= "%%" As Character
Local _cFiltro2	:= "%%" As Character
Local _cFilSD1	:= "%%" As Character
Local _cFilSD2	:= "%%" As Character
Local _cFilCKO	:= "%%" As Character
Local _cFilC00	:= "%%" As Character
Local _cQuery	:= "" As Character

If Len(_aSelFil) > 0 
	_cFilSF1 := "% AND F1_FILIAL " + GetRngFil( _aSelFil, "SF1", .T.,) + "%"
	_cFilSF3 := "% AND F3_FILIAL " + GetRngFil( _aSelFil, "SF3", .T.,) + "%"
	_cFilSFT := "% AND FT_FILIAL " + GetRngFil( _aSelFil, "SFT", .T.,) + "%"
	_cFilSE2 := "% AND E2_FILIAL " + GetRngFil( _aSelFil, "SE2", .T.,) + "%"
	_cFilSM0 := "% AND M0_CODFIL " + GetRngFil( _aSelFil, "SF3", .T.,) + "%"
	_cFilSD1 := "% AND D1_FILIAL " + GetRngFil( _aSelFil, "SD1", .T.,) + "%"
	_cFilSD2 := "% AND D2_FILIAL " + GetRngFil( _aSelFil, "SD2", .T.,) + "%"
	_cFilCKO := "% AND CKO_FILPRO " + GetRngFil( _aSelFil, "SF1", .T.,) + "%"
	_cFilC00 := "% AND C00_FILIAL " + GetRngFil( _aSelFil, "C00", .T.,) + "%"
EndIf

_aCabec		:= {}
_aDocs		:= {}

If _nX == 1
		
	BeginSQL alias _cAlias
		SELECT F3_FILIAL, F3_SERIE, PROXIMA NOTA_DE, LPAD(NEXTFAIXA - 1, 9, 0) NOTA_ATE,
			CASE
				WHEN LPAD(NEXTFAIXA, 9, 0) - PROXIMA < 10 THEN TO_CHAR(LPAD(NEXTFAIXA, 9, 0) - PROXIMA)
				ELSE TO_CHAR(LPAD(NEXTFAIXA, 9, 0) - PROXIMA) || ' - Possivel problema. Acionar a TI.'
			END QTD
		FROM (SELECT F3_FILIAL, F3_SERIE, LPAD(F3_NFISCAL + 1, 9, 0) PROXIMA,
					LEAD(F3_NFISCAL, 1) OVER(PARTITION BY F3_FILIAL, F3_SERIE ORDER BY F3_FILIAL, F3_SERIE, F3_NFISCAL) AS NEXTFAIXA
				FROM (SELECT DISTINCT F3_FILIAL, F3_SERIE, F3_NFISCAL
						FROM %Table:SF3%
						WHERE D_E_L_E_T_ = ' '
						AND (F3_FORMUL = 'S' OR
							(F3_FORMUL = ' ' AND F3_CFO > '5000'))
						AND F3_ESPECIE = 'SPED'
						%exp:_cFilSF3%
						AND F3_NFISCAL < '900000000')) SF3
		WHERE PROXIMA <> NEXTFAIXA
		AND EXISTS
		(SELECT 1
				FROM %Table:SF3% A
				WHERE A.D_E_L_E_T_ = ' '
				AND (A.F3_FORMUL = 'S' OR
					(A.F3_FORMUL = ' ' AND A.F3_CFO > '5000'))
				AND A.F3_ESPECIE = 'SPED'
				AND A.F3_FILIAL = SF3.F3_FILIAL
				AND A.F3_SERIE = SF3.F3_SERIE
				AND A.F3_NFISCAL = LPAD(PROXIMA - 1, 9, 0)
				AND F3_ENTRADA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%)
		ORDER BY F3_FILIAL, F3_SERIE, PROXIMA
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","S�rie do Documento","Documento de","Documento at�","Quantidade de Inutiliza��es"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->F3_FILIAL, (_cAlias)->F3_SERIE, (_cAlias)->NOTA_DE, (_cAlias)->NOTA_ATE, (_cAlias)->QTD})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf (_nX >= 2 .And. _nX <= 17) .Or. _nX == 27
	If	_nX == 2
		_cFiltro := "% AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000')) "
		_cFiltro += " AND SUBSTR(F3_CHVNFE, 26, 9) <> F3_NFISCAL "
		_cFiltro += " AND F3_CHVNFE <> ' ' "
	ElseIf _nX == 3
		_cFiltro := "% AND F3_CODRSEF NOT IN ('101','155','205','301','302','303','205') "
		_cFiltro += " AND F3_CHVNFE <> ' ' "
		_cFiltro += " AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000')) "
		_cFiltro += " AND F3_DTCANC <> ' ' "
	ElseIf _nX == 4
		_cFiltro := "% AND F3_CODRSEF <> '102' "
		_cFiltro += " AND F3_CHVNFE = ' ' "
		_cFiltro += " AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000')) "
	ElseIf _nX == 5
		_cFiltro := "% AND F3_CODRSEF = '102' "
		_cFiltro += " AND (F3_CHVNFE <> ' ' OR F3_DTCANC = ' ') "
		_cFiltro += " AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000')) "
	ElseIf _nX == 6
		_cFiltro := "% AND F3_CODRSEF NOT IN ('100','101','102','155','205','301','302','303') "
		_cFiltro += " AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000')) "
	ElseIf _nX == 7
		_cFiltro := "% AND F3_FORMUL = ' ' "
		_cFiltro += " AND F3_CFO < '5000' "
		_cFiltro += " AND EXISTS (SELECT 1 "
		_cFiltro += " 		FROM "+RetSqlName("SF3")+ " B "
		_cFiltro += " 		WHERE D_E_L_E_T_ = ' ' "
		_cFiltro += " 		AND F3_FORMUL = ' ' "
		_cFiltro += " 		AND F3_CFO < '5000' "
		_cFiltro += " 		AND SF3.F3_FILIAL <> B.F3_FILIAL "
		_cFiltro += " 		AND SF3.F3_NFISCAL = B.F3_NFISCAL "
		_cFiltro += " 		AND SF3.F3_SERIE = B.F3_SERIE "
		_cFiltro += " 		AND SF3.F3_CLIEFOR = B.F3_CLIEFOR "
		_cFiltro += " 		AND SF3.F3_LOJA = B.F3_LOJA "
		_cFiltro += " 		AND SF3.F3_ESPECIE = B.F3_ESPECIE) "
	ElseIf _nX == 8
		_cFiltro := "% AND F3_CFO < '5000' "
		_cFiltro += " AND F3_ESPECIE IN ('SPED','CTE','CTEOS','NF3E') "
		_cFiltro += " AND (REGEXP_LIKE(F3_SERIE, '[A-Z]','i') OR REGEXP_LIKE(F3_SERIE,'^ ','i')) "
	ElseIf _nX == 9
		_cFiltro := "% AND F3_ESPECIE NOT IN ('SPED','NFA') "
		_cFiltro += " AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000')) "
	ElseIf _nX == 10
		_cFiltro := "% AND F3_CHVNFE <> ' ' "
		_cFiltro += " AND SUBSTR( F3_CHVNFE,3,4) <> SUBSTR(F3_EMISSAO,3,4) "
	ElseIf _nX == 11
		_cFiltro := "% AND LENGTH(RTRIM(F3_CHVNFE)) <> '44' "
	ElseIf _nX == 12
		_cFiltro := "% AND F3_CHVNFE <> ' ' "
		_cFiltro += " AND (F3_FORMUL <> 'S' AND SF3.F3_CFO < '5000' "
		_cFiltro += " 		AND F3_SERIE NOT BETWEEN '890' AND '899' "
		_cFiltro += " 		AND F3_SERIE NOT BETWEEN '910' AND '969' "
		_cFiltro += " AND (((F3_TIPO NOT IN ('B','D') "
		_cFiltro += " 		AND SUBSTR(F3_CHVNFE,7,14) <> (SELECT LPAD(TRIM(SA2.A2_CGC),14,'0') "
		_cFiltro += " 															FROM "+ RetSqlName("SA2") +" SA2 "
		_cFiltro += " 															WHERE SA2.D_E_L_E_T_	= ' ' "
		_cFiltro += " 															AND	F3_CLIEFOR = SA2.A2_COD "
		_cFiltro += " 															AND F3_LOJA	= SA2.A2_LOJA) "
		_cFiltro += " 			)) OR (F3_TIPO IN ('B','D') "
		_cFiltro += " 				AND	SUBSTR(F3_CHVNFE,7,14) <> ( SELECT LPAD(TRIM(SA1.A1_CGC),14,'0') "
		_cFiltro += " 															FROM "+ RetSqlName("SA1") +" SA1 "
		_cFiltro += " 															WHERE SA1.D_E_L_E_T_	= ' ' "
		_cFiltro += " 															AND F3_CLIEFOR = SA1.A1_COD "
		_cFiltro += " 															AND F3_LOJA	= SA1.A1_LOJA )))) "
	ElseIf _nX == 13
		_cFiltro := "% AND F3_CHVNFE <> ' ' "
		_cFiltro += " AND F3_SERIE NOT BETWEEN '890' AND '899' "
		_cFiltro += " AND F3_SERIE NOT BETWEEN '910' AND '969' "
		_cFiltro += " AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000' ) ) "
		_cFiltro += " AND SUBSTR(F3_CHVNFE,7,14) <> (SELECT DISTINCT M0_CGC
		_cFiltro += " 												FROM SYS_COMPANY S "
		_cFiltro += " 												WHERE S.D_E_L_E_T_	= ' ' "
		_cFiltro += " 										 		AND	S.M0_CODFIL = F3_FILIAL "
		_cFiltro += " 										 		AND	ROWNUM = 1) "
	ElseIf _nX == 14
		_cFiltro := "% AND F3_CHVNFE <> ' ' "
		_cFiltro += " AND (F3_ESPECIE NOT IN ('SPED', 'CTE', 'CTEOS', 'NF3E') "
		_cFiltro += " OR ( SUBSTR(F3_CHVNFE,21,2) <> '55' AND F3_ESPECIE = 'SPED') "
		_cFiltro += " OR (SUBSTR(F3_CHVNFE,21,2) <> '57' AND F3_ESPECIE = 'CTE' ) "
		_cFiltro += " OR (SUBSTR( F3_CHVNFE,21,2) <> '67' AND F3_ESPECIE = 'CTEOS') "
		_cFiltro += " OR (SUBSTR( F3_CHVNFE,21,2) <> '66' AND F3_ESPECIE = 'NF3E')) "
	ElseIf _nX == 15
		_cFiltro := "% AND F3_CODRSEF IN ('101','155') "
		_cFiltro += " AND F3_DTCANC = ' ' "
	ElseIf _nX == 16
		_cFiltro := "% AND SF3.F3_CHVNFE <> ' ' "
		_cFiltro += " AND (SF3.F3_FORMUL = 'S' OR "
		_cFiltro += "     (SF3.F3_FORMUL = ' ' AND SF3.F3_CFO > '5000')) "
		_cFiltro += " AND SUBSTR(SF3.F3_CHVNFE, 7, 14) <> "
		_cFiltro += "     (SELECT S.M0_CGC "
		_cFiltro += "        FROM SYS_COMPANY S"
		_cFiltro += "       WHERE D_E_L_E_T_ = ' ' "
		_cFiltro += "         AND F3_FILIAL = S.M0_CODFIL) "
	ElseIf _nX == 17
		_cFiltro := "% AND SF3.F3_CHVNFE <> ' ' "
		_cFiltro += " AND SF3.F3_FORMUL <> 'S' "
		_cFiltro += " AND SF3.F3_CFO < '5000' "
		_cFiltro += " AND SF3.F3_CODRSEF <> ' ' "
	ElseIf _nX == 27
		_cFiltro := "% AND F3_FORMUL = ' ' "
		_cFiltro += " AND F3_CFO < '5000' "
		_cFiltro += " AND EXISTS (SELECT 1 "
		_cFiltro += " 		FROM "+RetSqlName("SDT")+ " "
		_cFiltro += " 		WHERE D_E_L_E_T_ = ' ' "
		_cFiltro += " 		AND DT_CODCFOP <> ' ' "
		_cFiltro += " 		AND DT_CODCFOP < '5000' "
		_cFiltro += " 		AND F3_FILIAL = DT_FILIAL "
		_cFiltro += " 		AND F3_NFISCAL = DT_DOC "
		_cFiltro += " 		AND F3_SERIE = DT_SERIE "
		_cFiltro += " 		AND F3_CLIEFOR = DT_FORNEC "
		_cFiltro += " 		AND F3_LOJA = DT_LOJA) "
	EndIf
	_cFiltro += StrTran(_cFilSF3,"%","")+ " %"

	BeginSQL alias _cAlias
		column F3_EMISSAO as Date
		column F3_ENTRADA as Date
		column F3_DTCANC as Date
		SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL,
			CASE WHEN MAX(F3_CFO) < '5000' THEN 'ENTRADA' ELSE 'SAIDA' END TP_OPER,
			F3_EMISSAO, F3_ENTRADA, F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE
		FROM %Table:SF3% SF3
		WHERE D_E_L_E_T_ = ' '
		%exp:_cFiltro%
		AND F3_ENTRADA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		GROUP BY F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL, F3_EMISSAO, F3_ENTRADA,
				F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE
		ORDER BY F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","N�mero do Documento","S�rie","Esp�cie","Form Pr�prio","Tipo de Opera��o","Data de Emiss�o",;
				"Data de Entrada","Cod Cli/For","Loja","Data de Cancelamento","Cod Retorno Sefaz","Chave Eletr�nica"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->F3_FILIAL, (_cAlias)->F3_NFISCAL, (_cAlias)->F3_SERIE, (_cAlias)->F3_ESPECIE, (_cAlias)->F3_FORMUL,;
				(_cAlias)->TP_OPER, (_cAlias)->F3_EMISSAO, (_cAlias)->F3_ENTRADA, (_cAlias)->F3_CLIEFOR, (_cAlias)->F3_LOJA,;
				(_cAlias)->F3_DTCANC, (_cAlias)->F3_CODRSEF, (_cAlias)->F3_CHVNFE})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 18
			
	BeginSQL alias _cAlias
		column F3_EMISSAO as Date
		column F3_ENTRADA as Date
		column F3_DTCANC as Date
		SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL,
			CASE WHEN MAX(F3_CFO) < '5000' THEN 'ENTRADA' ELSE 'SAIDA' END TP_OPER,
			F3_EMISSAO, F3_ENTRADA, F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE,
			TO_DATE(F3_ENTRADA,'YYYYMMDD') - TO_DATE(F3_EMISSAO,'YYYYMMDD') DIAS_LANC
		FROM %Table:SF3%
		WHERE D_E_L_E_T_ = ' '
		%exp:_cFilSF3%
		AND F3_ENTRADA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND	TO_DATE(F3_ENTRADA,'YYYYMMDD')-TO_DATE(F3_EMISSAO,'YYYYMMDD') > %exp:MV_PAR04%
		GROUP BY F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL, F3_EMISSAO, F3_ENTRADA,
				F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE
		ORDER BY F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","N�mero do Documento","S�rie","Esp�cie","Form Pr�prio","Tipo de Opera��o","Data de Emiss�o",;
				"Data de Entrada","Cod Cli/For","Loja","Data de Cancelamento","Cod Retorno Sefaz","Chave Eletr�nica","Qtd de Dias Lanc"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->F3_FILIAL, (_cAlias)->F3_NFISCAL, (_cAlias)->F3_SERIE, (_cAlias)->F3_ESPECIE, (_cAlias)->F3_FORMUL,;
				(_cAlias)->TP_OPER, (_cAlias)->F3_EMISSAO, (_cAlias)->F3_ENTRADA, (_cAlias)->F3_CLIEFOR, (_cAlias)->F3_LOJA,;
				(_cAlias)->F3_DTCANC, (_cAlias)->F3_CODRSEF, (_cAlias)->F3_CHVNFE, (_cAlias)->DIAS_LANC})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 19
	//Devido problemas com estorno de cr�dito de PIS/COFINS n�o podemos ter cancelamento de notas em meses diferentes.
	//Apenas quando isso ocorre, alteramos a data do cancelamento.
	_cQuery:= "UPDATE "+RETSQLNAME('SF3')+" SET F3_DTCANC = F3_EMISSAO "
	_cQuery+= "WHERE D_E_L_E_T_ = ' ' "
	_cQuery+= Replace(_cFilSF3,'%','')
	_cQuery+= "AND SUBSTR(F3_DTCANC,1,6) <> SUBSTR(F3_EMISSAO,1,6) "
	_cQuery+= "AND F3_DTCANC <> ' ' "
	//Ajustar automaticamente apenas quando o cancelamento for 1 dia depois. Ap�s isso o Moacir quer ver caso a caso.
	If MV_PAR05 == 2
		_cQuery+= "AND TO_DATE(F3_DTCANC,'YYYYMMDD')-TO_DATE(F3_EMISSAO,'YYYYMMDD') = 1 "
	EndIf
	_cQuery+= "AND (F3_FORMUL = 'S' OR (F3_FORMUL = ' ' AND F3_CFO > '5000')) "
	_cQuery+= "AND F3_EMISSAO BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"'"
	TCSqlExec(_cQuery)

	_cQuery:= "UPDATE "+RETSQLNAME('SFT')+" SET FT_DTCANC = FT_EMISSAO "
	_cQuery+= "WHERE D_E_L_E_T_ = ' ' "
	_cQuery+= Replace(_cFilSFT,'%','')
	_cQuery+= "AND SUBSTR(FT_DTCANC,1,6) <> SUBSTR(FT_EMISSAO,1,6) "
	_cQuery+= "AND FT_DTCANC > '19500101' " //ap�s migra��o do banco ou o comportamento mudou ou apareceu algum registro inv�lido que n�o consegui localizar e precisei contornar
	//Ajustar automaticamente apenas quando o cancelamento for 1 dia depois. Ap�s isso o Moacir quer ver caso a caso.
	If MV_PAR05 == 2
		_cQuery+= "AND TO_DATE(FT_DTCANC,'YYYYMMDD')-TO_DATE(FT_EMISSAO,'YYYYMMDD') = 1 "
	EndIf
	_cQuery+= "AND (FT_FORMUL = 'S' OR (FT_FORMUL = ' ' AND FT_CFOP > '5000')) "
	_cQuery+= "AND FT_EMISSAO BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"'"
	TCSqlExec(ChangeQuery(_cQuery))

	/*_cQuery:= "UPDATE "+RETSQLNAME('SE5')+" SET E5_TPDESC = 'I' "
	_cQuery+= "WHERE D_E_L_E_T_ = ' ' "
	_cQuery+= "AND E5_TIPODOC = 'P' "
	_cQuery+= "AND E5_TPDESC ='C' "
	_cQuery+= "AND E5_TIPODOC BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"'"
	TCSqlExec(_cQuery)*/

	BeginSQL alias _cAlias
		column F3_EMISSAO as Date
		column F3_ENTRADA as Date
		column F3_DTCANC as Date
		column CANC_SEFAZ as Date
		SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL,
			CASE WHEN MAX(F3_CFO) < '5000' THEN 'ENTRADA' ELSE 'SAIDA' END TP_OPER,
			F3_EMISSAO, F3_ENTRADA, F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE, CANC_SEF.DTREC_SEFR CANC_SEFAZ
		FROM %Table:SF3%,
       (SELECT DTREC_SEFR, S.M0_CODFIL, NFE_ID
          FROM SPED054, SPED001, SYS_COMPANY S
          WHERE SPED054.D_E_L_E_T_ = ' '
          AND SPED001.D_E_L_E_T_ = ' '
          AND S.D_E_L_E_T_ = ' '
          AND SPED001.IE = S.M0_INSC
          AND SPED001.ID_ENT = SPED054.ID_ENT
          AND S.M0_CGC = SPED001.CNPJ
          AND CSTAT_SEFR IN ('101','102','155','205','301','302','303')) CANC_SEF
		WHERE D_E_L_E_T_ = ' '
		%exp:_cFilSF3%
		AND F3_ENTRADA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND F3_CODRSEF IN ('101','102','155','205','301','302','303')
		AND F3_DTCANC <> ' '
		AND F3_FILIAL = M0_CODFIL
		AND F3_SERIE || F3_NFISCAL = NFE_ID
		AND SUBSTR(DTREC_SEFR,1,6) <> SUBSTR(F3_DTCANC,1,6)
		GROUP BY F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL, F3_EMISSAO, F3_ENTRADA,
				F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE, CANC_SEF.DTREC_SEFR
		ORDER BY F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","N�mero do Documento","S�rie","Esp�cie","Form Pr�prio","Tipo de Opera��o","Data de Emiss�o",;
				"Data de Entrada","Cod Cli/For","Loja","Data de Cancelamento","Cod Retorno Sefaz","Chave Eletr�nica","Data Cancelamento Sefaz"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->F3_FILIAL, (_cAlias)->F3_NFISCAL, (_cAlias)->F3_SERIE, (_cAlias)->F3_ESPECIE, (_cAlias)->F3_FORMUL,;
				(_cAlias)->TP_OPER, (_cAlias)->F3_EMISSAO, (_cAlias)->F3_ENTRADA, (_cAlias)->F3_CLIEFOR, (_cAlias)->F3_LOJA,;
				(_cAlias)->F3_DTCANC, (_cAlias)->F3_CODRSEF, (_cAlias)->F3_CHVNFE, (_cAlias)->CANC_SEFAZ})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 20
			
	BeginSQL alias _cAlias
		column F3_EMISSAO as Date
		column F3_ENTRADA as Date
		column F3_DTCANC as Date
		SELECT *
		FROM (SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL,
					CASE WHEN MAX(F3_CFO) < '5000' THEN 'ENTRADA' ELSE 'SAIDA' END TP_OPER,
					F3_EMISSAO, F3_ENTRADA, F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE,
					(SELECT CSTAT_SEFR
						FROM SPED054
						WHERE R_E_C_N_O_ =
							(SELECT MAX(SPED054.R_E_C_N_O_)
								FROM SPED054, SPED001, SYS_COMPANY S
								WHERE SPED054.D_E_L_E_T_ = ' '
								AND SPED001.D_E_L_E_T_ = ' '
								AND S.D_E_L_E_T_ = ' '
								AND CSTAT_SEFR IN ('100','101','102','301','302','303','205','155')
								AND SPED001.IE = S.M0_INSC
								AND SPED001.ID_ENT = SPED054.ID_ENT
								AND S.M0_CGC = SPED001.CNPJ
								AND F3_SERIE || F3_NFISCAL = NFE_ID
								AND F3_FILIAL = S.M0_CODFIL)) RET_SPED054
				FROM %Table:SF3%
				WHERE D_E_L_E_T_ = ' '
				AND F3_ENTRADA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
				AND F3_CODRSEF <> ' '
				%exp:_cFilSF3%
				GROUP BY F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ESPECIE, F3_FORMUL, F3_EMISSAO, F3_ENTRADA,
						F3_CLIEFOR, F3_LOJA, F3_DTCANC, F3_CODRSEF, F3_CHVNFE
				ORDER BY F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE)
		WHERE RET_SPED054 <> F3_CODRSEF
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","N�mero do Documento","S�rie","Esp�cie","Form Pr�prio","Tipo de Opera��o","Data de Emiss�o",;
				"Data de Entrada","Cod Cli/For","Loja","Data de Cancelamento","Cod Retorno Sefaz","Chave Eletr�nica","Cod Retorno do SPED Fiscal"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->F3_FILIAL, (_cAlias)->F3_NFISCAL, (_cAlias)->F3_SERIE, (_cAlias)->F3_ESPECIE, (_cAlias)->F3_FORMUL,;
				(_cAlias)->TP_OPER, (_cAlias)->F3_EMISSAO, (_cAlias)->F3_ENTRADA, (_cAlias)->F3_CLIEFOR, (_cAlias)->F3_LOJA,;
				(_cAlias)->F3_DTCANC, (_cAlias)->F3_CODRSEF, (_cAlias)->F3_CHVNFE, (_cAlias)->RET_SPED054})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 21
			
	BeginSQL alias _cAlias
		column FT_EMISSAO as Date
		column FT_ENTRADA as Date
		column FT_DTCANC as Date
		SELECT FT_FILIAL, FT_NFISCAL, FT_SERIE, FT_ESPECIE, FT_FORMUL,
			CASE WHEN MAX(FT_CFOP) < '5000' THEN 'ENTRADA' ELSE 'SAIDA' END TP_OPER,
			FT_EMISSAO, FT_ENTRADA, FT_CLIEFOR, FT_LOJA, FT_DTCANC, FT_CHVNFE, FT_NFORI, FT_SERORI, FT_ITEMORI
		FROM %Table:SFT%
		WHERE D_E_L_E_T_ = ' '
		%exp:_cFilSFT%
		AND FT_ENTRADA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND FT_TIPO = 'D'
		AND FT_DTCANC = ' '
		AND (LENGTH(RTRIM(FT_NFORI)) <> 9 OR FT_ITEMORI = ' ' OR
			NOT REGEXP_LIKE(FT_NFORI, '[0-9]', 'i') OR
			NOT REGEXP_LIKE(FT_SERORI, '[0-9]', 'i') OR
			NOT REGEXP_LIKE(FT_ITEMORI, '[0-9]', 'i'))
		GROUP BY FT_FILIAL, FT_NFISCAL, FT_SERIE, FT_ESPECIE, FT_FORMUL, FT_EMISSAO, FT_ENTRADA,
				FT_CLIEFOR, FT_LOJA, FT_DTCANC, FT_CHVNFE, FT_NFORI, FT_SERORI, FT_ITEMORI
		ORDER BY FT_FILIAL, FT_NFISCAL, FT_SERIE
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","N�mero do Documento","S�rie","Esp�cie","Form Pr�prio","Tipo de Opera��o","Data de Emiss�o",;
				"Data de Entrada","Cod Cli/For","Loja","Data de Cancelamento","Chave Eletr�nica","NF Ori", "Serie Ori", "Item Ori"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->FT_FILIAL, (_cAlias)->FT_NFISCAL, (_cAlias)->FT_SERIE, (_cAlias)->FT_ESPECIE, (_cAlias)->FT_FORMUL,;
				(_cAlias)->TP_OPER, (_cAlias)->FT_EMISSAO, (_cAlias)->FT_ENTRADA, (_cAlias)->FT_CLIEFOR, (_cAlias)->FT_LOJA,;
				(_cAlias)->FT_DTCANC, (_cAlias)->FT_CHVNFE, (_cAlias)->FT_NFORI, (_cAlias)->FT_SERORI, (_cAlias)->FT_ITEMORI})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 22
			
	BeginSQL alias _cAlias
		column E2_EMISSAO as Date
		column E2_VENCREA as Date
		column E2_BAIXA as Date
		SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR,
			TO_DATE(CDH_DTINI,'YYYYMMDD')||' - '||TO_DATE(CDH_DTFIM,'YYYYMMDD') APURACAO,
			E2_EMISSAO, E2_VENCREA, E2_BAIXA,
			DECODE((SELECT MAX(CDHB.CDH_SEQUEN)
						FROM %Table:CDH% CDHB
					WHERE CDHB.D_E_L_E_T_ = ' '
						AND CDH.CDH_FILIAL = CDHB.CDH_FILIAL
						AND CDH.CDH_TIPOIP = CDHB.CDH_TIPOIP
						AND CDH.CDH_TIPOPR = CDHB.CDH_TIPOPR
						AND CDH.CDH_PERIOD = CDHB.CDH_PERIOD
						AND CDH.CDH_LIVRO = CDHB.CDH_LIVRO
						AND CDH.CDH_DTINI = CDHB.CDH_DTINI
						AND CDH.CDH_DTFIM = CDHB.CDH_DTFIM),
					CDH.CDH_SEQUEN, 'CERTO', 'ERRADO') NUMTIT
		FROM %Table:SE2% SE2, %Table:CDH% CDH
		WHERE SE2.D_E_L_E_T_ = ' '
		AND CDH.D_E_L_E_T_ = ' '
		AND E2_FILIAL = CDH_FILIAL
		AND E2_PREFIXO = CDH_PRETIT
		AND E2_NUM = CDH_NUMTIT
		AND E2_TIPO = CDH_TPTIT
		AND E2_FORNECE = CDH_FORTIT
		AND E2_LOJA = CDH_LOJTIT
		%exp:_cFilSE2%
		AND E2_EMISSAO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND E2_ORIGEM = 'MATA953'
		AND E2_BAIXA = ' '
		ORDER BY E2_FILIAL, E2_EMISSAO, E2_PREFIXO, E2_NUM
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","Prefixo","N�mero","Tipo","Fornecedor","Loja","Valor","Apura��o","Emiss�o","Vencimento","Baixa","Status"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->E2_FILIAL, (_cAlias)->E2_PREFIXO, (_cAlias)->E2_NUM, (_cAlias)->E2_TIPO, (_cAlias)->E2_FORNECE,;
				(_cAlias)->E2_LOJA, (_cAlias)->E2_VALOR, (_cAlias)->APURACAO, (_cAlias)->E2_EMISSAO, (_cAlias)->E2_VENCREA,;
				(_cAlias)->E2_BAIXA, (_cAlias)->NUMTIT})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 23 .Or. _nX == 28 .Or. _nX == 31

	If _nX == 23
		_cFiltro := "% AND EXISTS (SELECT 1 "
        _cFiltro += " 		FROM SPED154, SPED001, SYS_COMPANY S "
        _cFiltro += " 		WHERE SPED154.D_E_L_E_T_ = ' ' "
    	_cFiltro += " 		AND SPED001.D_E_L_E_T_ = ' ' "
        _cFiltro += " 		AND S.D_E_L_E_T_ = ' ' "
        _cFiltro += " 		AND SPED001.IE = S.M0_INSC "
        _cFiltro += " 		AND SPED001.ID_ENT = SPED154.ID_ENT "
        _cFiltro += " 		AND S.M0_CGC = SPED001.CNPJ "
        _cFiltro += " 		AND TPEVENTO IN (210220, 210240, 610110) "
        _cFiltro += " 		AND F1_FILIAL = S.M0_CODFIL "
        _cFiltro += " 		AND F1_CHVNFE = NFE_CHV "
        //_cFiltro += " 		AND STATUS = 6 " N�o filtrar o status para que os eventos com erro apare�am e sejam corrigidos
        _cFiltro += " 		AND SPED154.R_E_C_N_O_ = "
        _cFiltro += " 		   (SELECT MAX(B.R_E_C_N_O_) "
        _cFiltro += " 		      FROM SPED154 B "
        _cFiltro += " 		     WHERE B.D_E_L_E_T_ = ' ' "
        _cFiltro += " 		       AND B.NFE_CHV = SPED154.NFE_CHV "
		//_cFiltro += " 		   AND B.STATUS = 6 "
        _cFiltro += " 		       AND B.ID_ENT = SPED154.ID_ENT ))"
	ElseIf _nX == 28
		_cFiltro := "% AND EXISTS (SELECT 1 "
		_cFiltro += " 		FROM "+RetSqlName("SDS")+ " "
		_cFiltro += " 		WHERE D_E_L_E_T_ = ' ' "
		_cFiltro += " 		AND F1_FILIAL = DS_FILIAL "
		_cFiltro += " 		AND F1_DOC = DS_DOC "
		_cFiltro += " 		AND F1_SERIE = DS_SERIE "
		_cFiltro += " 		AND F1_FORNECE = DS_FORNEC "
		_cFiltro += " 		AND F1_LOJA = DS_LOJA "
		_cFiltro += " 		AND (F1_CHVNFE <> DS_CHAVENF OR F1_ESPECIE <> DS_ESPECI))""
	EndIf
	_cFiltro += StrTran(_cFilSF1,"%","")+ " %"

	BeginSQL alias _cAlias
		column F1_EMISSAO as Date
		column F1_DTDIGIT as Date
		SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_ESPECIE, F1_FORMUL, 'ENTRADA' TP_OPER, F1_EMISSAO, F1_DTDIGIT, 
				F1_FORNECE, F1_LOJA, F1_CHVNFE
		FROM %Table:SF1%
		WHERE D_E_L_E_T_ = ' '
		%exp:_cFiltro%
		AND F1_DTDIGIT BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		ORDER BY F1_FILIAL, F1_DTDIGIT, F1_DOC, F1_SERIE
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","N�mero do Documento","S�rie","Esp�cie","Form Pr�prio","Tipo de Opera��o","Data de Emiss�o",;
				"Data de Entrada","Cod Cli/For","Loja","Chave Eletr�nica"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->F1_FILIAL, (_cAlias)->F1_DOC, (_cAlias)->F1_SERIE, (_cAlias)->F1_ESPECIE, (_cAlias)->F1_FORMUL,;
				(_cAlias)->TP_OPER, (_cAlias)->F1_EMISSAO, (_cAlias)->F1_DTDIGIT, (_cAlias)->F1_FORNECE, (_cAlias)->F1_LOJA, (_cAlias)->F1_CHVNFE})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX >= 24 .And. _nX <= 25
	If	_nX == 24
		_cFiltro := "% AND DOC_CHV = F3_CHVNFE %"
		_cFiltro2 := "% NOT %"
	ElseIf _nX == 25
		_cFiltro := "% AND SUBSTR(A.NFE_ID, 4, 9) = B.F3_NFISCAL "
        _cFiltro += " AND SUBSTR(A.NFE_ID, 1, 3) = B.F3_SERIE "
        _cFiltro += " AND (B.F3_FORMUL = 'S' OR (B.F3_FORMUL = ' ' AND B.F3_CFO > '5000')) %"
	EndIf

	BeginSQL alias _cAlias
		column DATE_NFE as Date
		SELECT S.M0_CODFIL, A.ID_ENT, DATE_NFE, STATUS, STATUSCANC, DOC_CHV, SUBSTR(NFE_ID, 4, 9) DOCUMENTO, SUBSTR(NFE_ID, 1, 3) SERIE
		FROM SPED050 A, SPED001, SYS_COMPANY S
		WHERE A.D_E_L_E_T_ = ' '
		AND SPED001.D_E_L_E_T_ = ' '
		AND S.D_E_L_E_T_ = ' '
		AND SPED001.IE = S.M0_INSC
		AND SPED001.ID_ENT = A.ID_ENT
		AND S.M0_CGC = SPED001.CNPJ
		AND A.MODELO = '55'
		%exp:_cFilSM0%
		AND A.DATE_NFE BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND (NOT EXISTS (SELECT 1
							FROM %Table:SF3% B
							WHERE B.D_E_L_E_T_ = ' '
							AND B.F3_FILIAL = M0_CODFIL
							%exp:_cFiltro% ) AND %exp:_cFiltro2% EXISTS
				(SELECT 1
				FROM SPED054 C
				WHERE D_E_L_E_T_ = ' '
					AND A.ID_ENT = C.ID_ENT
					AND A.NFE_ID = C.NFE_ID
					AND CSTAT_SEFR = '102'))
		ORDER BY M0_CODFIL, DATE_NFE, SUBSTR(NFE_ID, 4, 9), SUBSTR(NFE_ID, 1, 3)
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","Data Transmiss�o","Chave Eletr�nica","N�mero do Documento","S�rie","Status Transmiss�o","Status Cancelamento"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->M0_CODFIL, (_cAlias)->DATE_NFE, (_cAlias)->DOC_CHV, (_cAlias)->DOCUMENTO, (_cAlias)->SERIE,;
						(_cAlias)->STATUS, (_cAlias)->STATUSCANC})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 26
			
	BeginSQL alias _cAlias
		column D1_EMISSAO as Date
		column D1_DTDIGIT as Date
		column D2_EMISSAO as Date
		SELECT 'ENTRADA' TP_OPER, D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA,D1_EMISSAO,
		       D1_DTDIGIT, D1_NFORI, D1_SERIORI, D1_ITEMORI, D2_EMISSAO
		FROM %Table:SD1% SD1, %Table:SD2% SD2
		WHERE SD1.D_E_L_E_T_ = ' '
		AND SD2.D_E_L_E_T_ = ' '
		%exp:_cFilSD1%
		AND D1_DTDIGIT BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND D1_TIPO IN ('D','B')
		AND D1_NFORI <> ' '
		AND D1_FILIAL = D2_FILIAL
		AND D1_NFORI = D2_DOC
		AND D1_SERIORI = D2_SERIE
		AND D1_FORNECE = D2_CLIENTE
		AND D1_LOJA = D2_LOJA
		AND D1_ITEMORI = D2_ITEM
		AND D1_EMISSAO < D2_EMISSAO
		UNION
		SELECT 'SAIDA' TP_OPER, D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_EMISSAO,
				D2_DTDIGIT, D2_NFORI, D2_SERIORI, D2_ITEMORI, D1_EMISSAO
		FROM %Table:SD1% SD1, %Table:SD2% SD2
		WHERE SD1.D_E_L_E_T_ = ' '
		AND SD2.D_E_L_E_T_ = ' '
		%exp:_cFilSD2%
		AND D2_EMISSAO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
		AND D2_TIPO IN ('D','B')
		AND D2_NFORI <> ' '
		AND D1_FILIAL = D2_FILIAL
		AND D2_NFORI = D1_DOC
		AND D2_SERIORI = D1_SERIE
		AND D1_FORNECE = D2_CLIENTE
		AND D1_LOJA = D2_LOJA
		AND D1_ITEMORI = D2_ITEM
		AND D2_EMISSAO < D1_EMISSAO
		ORDER BY TP_OPER, D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_SERIE
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Tipo de Opera��o","Filial","N�mero do Documento","S�rie","Cod Cli/For","Loja","Data de Emiss�o",;
				"Data de Entrada","NF Ori", "Serie Ori", "Item Ori","Dt Emiss�o Ori"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->TP_OPER, (_cAlias)->D1_FILIAL, (_cAlias)->D1_DOC, (_cAlias)->D1_SERIE, (_cAlias)->D1_FORNECE, (_cAlias)->D1_LOJA,;
			(_cAlias)->D1_EMISSAO, (_cAlias)->D1_DTDIGIT, (_cAlias)->D1_NFORI, (_cAlias)->D1_SERIORI, (_cAlias)->D1_ITEMORI, (_cAlias)->D2_EMISSAO })
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 29
			
	BeginSQL alias _cAlias
		column F1_EMISSAO as Date
		column F1_DTDIGIT as Date
		SELECT * FROM (
		SELECT F1_FILIAL,
			CASE
				WHEN F1_EMISSAO IS NOT NULL THEN F1_EMISSAO
				WHEN DS_EMISSA IS NOT NULL THEN DS_EMISSA
				WHEN C00_DTEMI IS NOT NULL THEN C00_DTEMI
				ELSE CKO_I_EMIS
			END F1_EMISSAO,
			F1_DTDIGIT,
			F1_EST,
			CASE
				WHEN F1_ESPECIE = 'NFE' THEN
				CASE
					WHEN EST_FIL = 'RO' AND F1_EST = 'RO' THEN 20
					WHEN EST_FIL = 'RO' AND F1_EST <> 'RO' THEN 35
					ELSE 180
				END - ROUND(SYSDATE - TO_DATE(CASE
												WHEN F1_EMISSAO IS NOT NULL THEN F1_EMISSAO
												WHEN DS_EMISSA IS NOT NULL THEN DS_EMISSA
												WHEN C00_DTEMI IS NOT NULL THEN C00_DTEMI
												ELSE CKO_I_EMIS
												END,'YYYYMMDD'),0)
			END CONF_NREAL,
			CASE
				WHEN F1_ESPECIE = 'NFE' THEN
				CASE
					WHEN EST_FIL = 'RO' AND F1_EST = 'RO' THEN 10
					WHEN EST_FIL = 'RO' AND F1_EST <> 'RO' THEN 15
					ELSE 180
				END
				ELSE 45
			END - ROUND(SYSDATE - TO_DATE(CASE
											WHEN F1_EMISSAO IS NOT NULL THEN F1_EMISSAO
											WHEN DS_EMISSA IS NOT NULL THEN DS_EMISSA
											WHEN C00_DTEMI IS NOT NULL THEN C00_DTEMI
											ELSE CKO_I_EMIS
											END, 'YYYYMMDD'),0) REST_DESC,
			F1_CHVNFE,
			F1_ESPECIE,
			CASE
				WHEN F1_TIPO IS NOT NULL THEN 
				DECODE(F1_TIPO,'N','Normal','D','Devolucao','I','Compl. ICMS','P','Compl. IPI','B','Beneficiamento','C','Compl. Preco') 
				ELSE DECODE(DS_TIPO,'N','Normal','O','Bonificacao','D','Devolucao','B','Beneficiamento','C','Compl. Preco','T','Transporte','')
			END TIPO,
			ENT_FOR,
			CASE
				WHEN F1_STATUS = 'A' THEN 'Classificado'
				WHEN F1_STATUS = ' ' THEN 'Pre-nota'
				WHEN DS_TIPO IS NOT NULL THEN 'Monitor'
				WHEN CKO_I_EMIS IS NOT NULL THEN 'Reprocessamento'
				ELSE 'Manifestacao'
			END STATUS_ESCRITURACAO
		FROM (SELECT BASE.F1_FILIAL, SY.M0_ESTENT EST_FIL, SF11.F1_EMISSAO, SF11.F1_DTDIGIT, C001.C00_DTEMI, SDS1.DS_EMISSA,
					CKO1.CKO_I_EMIS,
					CASE WHEN SF11.F1_EST IS NOT NULL THEN SF11.F1_EST ELSE
					DECODE(SUBSTR(BASE.F1_CHVNFE,1,2),'11','RO','12','AC','13','AM','14','RR','15','PA','16','AP','17','TO','21','MA','22','PI','23','CE','24','RN',
					'25','PB','26','PE','27','AL','31','MG','32','ES','33','RJ','35','SP','41','PR','42','SC','43','RS','50','MS','51','MT','52','GO',
					'53','DF','28','SE','29','BA','99','EX') END F1_EST,
					SF11.F1_TIPO, SDS1.DS_TIPO,
					CASE
						WHEN (SELECT COUNT(1) FROM SPED156 WHERE SPED156.D_E_L_E_T_ = ' ' AND BASE.F1_CHVNFE = DOCCHV AND DOCTPOP = '0') = 1 THEN 'Sim'
						ELSE 'Nao'
					END ENT_FOR,
					BASE.F1_CHVNFE, DECODE(SUBSTR(BASE.F1_CHVNFE, 21, 2), '55', 'NFE', '57','CTE','67','CTEOS') F1_ESPECIE,
					SF11.F1_STATUS
				FROM (SELECT RTRIM(CKO.CKO_FILPRO) F1_FILIAL, SUBSTR(CKO.CKO_ARQUIV, 4, 44) F1_CHVNFE
						FROM %Table:CKO% CKO
						WHERE CKO.D_E_L_E_T_ = ' '
						%exp:_cFilCKO%
						AND CKO.CKO_I_EMIS BETWEEN %exp:Date()-360% AND %exp:Date()%
						AND CKO.CKO_CODERR NOT IN ('COM002','COM040','COM036','COM045','COM041','COM037','COM046','MCOM06','MCOM004')
						AND NOT EXISTS (SELECT 1 FROM %Table:SF1%
								WHERE D_E_L_E_T_ = ' '
									AND F1_FILIAL = RTRIM(CKO_FILPRO)
									AND F1_CHVNFE = SUBSTR(CKO_ARQUIV, 4, 44))
						UNION
						SELECT F1_FILIAL, F1_CHVNFE
						FROM %Table:SF1% SF1
						WHERE SF1.D_E_L_E_T_ = ' '
						%exp:_cFilSF1%
						AND F1_EMISSAO BETWEEN %exp:Date()-360% AND %exp:Date()%
						AND F1_FORMUL <> 'S'
						AND F1_CHVNFE <> ' '
						AND F1_ESPECIE IN ('SPED', 'CTE','CTEOS')
						UNION
						SELECT C00.C00_FILIAL, C00.C00_CHVNFE
						FROM %Table:C00% C00
						WHERE C00.D_E_L_E_T_ = ' '
						%exp:_cFilC00%
						AND C00_DTEMI BETWEEN %exp:Date()-360% AND %exp:Date()%
						AND NOT EXISTS (SELECT 1 FROM %Table:SF1%
								WHERE D_E_L_E_T_ = ' '
									AND F1_FILIAL = C00_FILIAL
									AND F1_CHVNFE = C00_CHVNFE)
						) BASE
				INNER JOIN SYS_COMPANY SY
				ON (SY.D_E_L_E_T_ = ' '
				AND BASE.F1_FILIAL = RTRIM(SY.M0_CODFIL))
				LEFT JOIN %Table:CKO% CKO1
					ON (CKO1.D_E_L_E_T_ = ' ' AND
					RTRIM(CKO1.CKO_FILPRO) = BASE.F1_FILIAL AND
					SUBSTR(CKO1.CKO_ARQUIV, 4, 44) = BASE.F1_CHVNFE)
				LEFT JOIN %Table:SF1% SF11
					ON (SF11.D_E_L_E_T_ = ' ' AND SF11.F1_FILIAL = BASE.F1_FILIAL AND SF11.F1_CHVNFE = BASE.F1_CHVNFE)
				LEFT JOIN %Table:C00% C001
					ON (C001.D_E_L_E_T_ = ' ' AND C001.C00_FILIAL = BASE.F1_FILIAL AND C001.C00_CHVNFE = BASE.F1_CHVNFE)
				LEFT JOIN %Table:SDS% SDS1
					ON (SDS1.D_E_L_E_T_ = ' ' AND SDS1.DS_FILIAL = BASE.F1_FILIAL AND SDS1.DS_CHAVENF = BASE.F1_CHVNFE)
				LEFT JOIN (SELECT RTRIM(S.M0_CODFIL) F1_FILIAL, SPED154.NFE_CHV F1_CHVNFE
							FROM SPED154, SPED001, SYS_COMPANY S
							WHERE SPED154.D_E_L_E_T_ = ' '
							AND SPED001.D_E_L_E_T_ = ' '
							AND S.D_E_L_E_T_ = ' '
							AND SPED001.IE = S.M0_INSC
							AND SPED001.ID_ENT = SPED154.ID_ENT
							AND S.M0_CGC = SPED001.CNPJ
							AND SPED154.TPEVENTO IN (210200, 210220, 210240, 210210, 610110,610111)
							AND SPED154.R_E_C_N_O_ =
								(SELECT MAX(B.R_E_C_N_O_)
									FROM SPED154 B
									WHERE B.D_E_L_E_T_ = ' '
									AND B.NFE_CHV = SPED154.NFE_CHV
									AND B.ID_ENT = SPED154.ID_ENT)) SPED154T
					ON (SPED154T.F1_FILIAL = BASE.F1_FILIAL AND
					SPED154T.F1_CHVNFE = BASE.F1_CHVNFE))
		WHERE NOT EXISTS (SELECT 1
				FROM SPED150, SPED001, SYS_COMPANY
				WHERE SPED150.D_E_L_E_T_ = ' '
				AND SPED150.D_E_L_E_T_ = ' '
				AND SYS_COMPANY.D_E_L_E_T_ = ' '
				AND SPED150.NFE_CHV = F1_CHVNFE
				AND SPED001.IE = M0_INSC
				AND SPED001.ID_ENT = SPED150.ID_ENT
				AND SPED001.CNPJ = M0_CGC
				AND RTRIM(M0_CODFIL) = F1_FILIAL
				AND STATUS = 6))
		 WHERE NOT (F1_ESPECIE IN ('CTE','CTEOS') AND STATUS_ESCRITURACAO = 'Classificado')
			AND (CONF_NREAL BETWEEN 0 AND 5 OR REST_DESC BETWEEN 0 AND 5)
		ORDER BY F1_FILIAL, REST_DESC

	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Filial","Data de Emiss�o","Data de Entrada","Estado","Conf/N�o Real.","Desac./Desc.","Chave","Esp�cie","Tipo",;
				"Ent.For.","Escritura��o"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->F1_FILIAL, (_cAlias)->F1_EMISSAO, (_cAlias)->F1_DTDIGIT, (_cAlias)->F1_EST,(_cAlias)->CONF_NREAL,;
			(_cAlias)->REST_DESC,(_cAlias)->F1_CHVNFE, (_cAlias)->F1_ESPECIE,(_cAlias)->TIPO, (_cAlias)->ENT_FOR, (_cAlias)->STATUS_ESCRITURACAO})
		(_cAlias)->(DBSkip())
	EndDo

ElseIf _nX == 30
			
	BeginSQL alias _cAlias
		SELECT SUBSTR(CKO_ARQUIV,1,44) CHAVE, CKO_CODERR, CKO_MSGERR
		FROM %Table:CKO% CKO
		WHERE CKO.D_E_L_E_T_ = ' '
		AND CKO_CODERR IN ('COM001','COM016','COM017','COM026','COM043','COM049')
	EndSQL
	//Adiciono os cabe�alhos das colunas
	_aCabec :=  {"Chave","Cod. Erro","Erro"}

	While !(_cAlias)->(EOF())
		aAdd(_aDocs, {(_cAlias)->CHAVE, (_cAlias)->CKO_CODERR, Substr((_cAlias)->CKO_MSGERR,1,200)})
		(_cAlias)->(DBSkip())
	EndDo
EndIf

(_cAlias)->(DBCloseArea())

If Len(_aDocs) == 0
	_aCabec :={}
EndIf

Return

/*
===============================================================================================================================
Programa----------: MFIS005H
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/01/2020
Descri��o---------: Monta HTML que ser� eviado por e-mail
Parametros--------: _aTitulos 	-> A -> Array com os t�tulos de cada consulta para montagem do cabe�alho
					_aCabec		-> A -> Array com os nomes das colunas
					_aDocs		-> A -> Array com o resultado de cada consulta para montagem dos itens
					_nX			-> N -> Posi��o do array _aTitulos, indicando qual cabe�alho deve ser usado
					_nHdlLog	-> N -> Arquivo aberto
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS005H(_aTitulos As Array, _aCabec As Array, _aDocs As Array, _nX As Numeric, _oArquivo As Object)

Local _cText	:= "" As Character
Local _nY		:= 0 As Numeric
Local _nJ		:= 0 As Numeric

If _nX == 1 //No primeiro registro, monto o cabe�alho
	//=====================================
	//Monta o cabe�alho do HTML
	//=====================================
	_cText += '<HTML>'+CRLF
	_cText += '<HEAD><TITLE>:: WF - Analise de NF ::</TITLE></HEAD>'+CRLF
	_cText += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'+CRLF
	
	_cText += '<style type="text/css">'+CRLF
	_cText += '<!--'+CRLF
	_cText += 'table.bordasimples { border-collapse: collapse; }'+CRLF
	_cText += 'table.bordasimples tr td { border:1px solid #777777; }'+CRLF
	_cText += 'td.grupos	{ font-family:VERDANA; font-size:18px; V-align:middle; background-color: #000099; color:#FFFFFF; }'+CRLF
	_cText += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; background-color: #EEDD82; }'+CRLF
	_cText += 'td.citens	{ font-family:VERDANA; font-size:10px; V-align:middle; background-color: #D7D7D7; }'+CRLF
	_cText += 'td.ditens	{ font-family:ARIAL;   font-size:09px; V-align:middle; }'+CRLF
	_cText += '-->'+CRLF
	_cText += '</style>'+CRLF
	
	_cText += '<body>'+CRLF
	
	_cText += '<table class="bordasimples" width="100%" height="35px" align="center">'  +CRLF
	_cText += '  <tr>'+CRLF
	_cText += '    <td class="grupos" width="100%" align="center"><b>Analise de Documentos Fiscais</b></td>'+CRLF
	_cText += '  </tr>'+CRLF
	_cText += '</table>'+CRLF
	_cText += '<br>'+CRLF
	
EndIf
//=================================
//Grava cabe�alho das colunas
//=================================
_cText += '<table class="bordasimples" align="center" width="100%">'+CRLF
_cText += '  <tr>'+CRLF
_cText += '    <td class="titulos" align="center" colspan="'+AllTrim(Str(Len(_aCabec)))+'"><b>'+_aTitulos[_nX][01]+' - '+_aTitulos[_nX][02]+'</b></td>'+CRLF
_cText += '  </tr>'+CRLF
_cText += '  <tr>'+CRLF
For _nY := 1 to Len(_aCabec)
	_cText += '    <td class="citens" align="center"><font size="1" face="Verdana"><b>'+_aCabec[_nY]+'</b></td>'+CRLF
Next _nY
_cText += '  </tr>'+CRLF
//=================================
//Grava itens das colunas
//=================================
For _nY := 1 to Len(_aDocs)
	_cText += '  <tr>'+CRLF
	For _nJ := 1 to Len(_aDocs[_nY])
		_cText += '    <td class="ditens" align="center"><pre>'+IIf(ValType(_aDocs[_nY][_nJ]) == 'C',;
		_aDocs[_nY][_nJ],IIf(ValType(_aDocs[_nY][_nJ])=='D',DtoC(_aDocs[_nY][_nJ]),cValToChar(_aDocs[_nY][_nJ]))) +'</pre></td>'+CRLF
	Next _nJ
	_cText += '  </tr>'+CRLF
Next _nY
_cText	+= '</table>'+CRLF
_cText	+= '<br>'+CRLF

If _nX == Len(_aTitulos)
	//=================================
	//Finaliza o arquivo html
	//=================================
	_cText += '</body>'+CRLF
	_cText += '</html>'+CRLF
	_oArquivo:Write(_cText)
	_oArquivo:Close()
Else
	_oArquivo:Write(_cText)
EndIf

Return

/*
===============================================================================================================================
Programa----------: MFIS005E
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 28/01/2020
Descri��o---------: Executa envio do e-mails com os logs para os usu�rios habilitados para tal.
Parametros--------: _cArqLog -> C -> Caminho para o arquivo a ser anexado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS005E(_cArqLog as String)

Local _cAssunto	:= "Analise de Emiss�o das NF - Data/Hora de Cria��o: "+ DtoC( Date() ) +' / '+ Transform( Time() , "@R 99:99" ) As Character
Local _cMensagem:= "" As Character
Local _cErro	:= "" As Character
Local _cAlias	:= GetNextAlias() As Character
Local _cArqZip	:= StrTran(_cArqLog,".htm",".zip") As Character

If FZip(_cArqZip,{_cArqLog},SuperGetMV("MV_RELT",.F.,"\spool\")) <> 0
	FWAlertWarning("O arquivo n�o pode ser compactado. O e-mail n�o ser� enviado!","MFIS005002")
	FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MFIS005002"/*cMsgId*/, "O arquivo n�o pode ser compactado. O e-mail n�o ser� enviado!"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
Else
		
	//=====================================
	//Monta a mensagem do corpo do e-mail
	//=====================================
	_cMensagem := ' <HTML>
	_cMensagem += ' <HEAD>
	_cMensagem += ' 	<TITLE>:: WF - Analise dos documentos fiscais ::</TITLE>
	_cMensagem += ' 	<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	_cMensagem += ' </HEAD>
	_cMensagem += ' <BODY>
	_cMensagem += ' <center>
	_cMensagem += ' <table border="0" cellpadding="0" cellspacing="0" width="850px" class="TopMid">
	_cMensagem += ' 	<tr>
	_cMensagem += ' 		<td height="62px" ><img src="http://www.italac.com.br/imagens/logo_novo.png"></td>
	_cMensagem += ' 		<td height="62px" width="010px">&nbsp;</td>
	_cMensagem += ' 		<td height="62px" width="850px" style="font-family:Verdana;font-size:20px;color:#104E8B;border-width:3px;border-style:double;border-color:#104E8B;">
	_cMensagem += ' 			<b><center>&nbsp;&nbsp;&nbsp;WorkFlow: Analise de Documentos Fiscais&nbsp;&nbsp;&nbsp;</center></b>
	_cMensagem += ' 		</td>
	_cMensagem += ' 	</tr>
	_cMensagem += ' 	<tr>
	_cMensagem += ' 		<td style="font-family:Verdana;font-size:12px;color:#535353" width="831px" colspan="3">
	_cMensagem += ' 			<br>
	_cMensagem += ' 			<b>&nbsp;&nbsp;Prezado,</b>
	_cMensagem += ' 			<br><br>
	_cMensagem += ' 			&nbsp;&nbsp;Segue anexo arquivo contendo a Analise dos documentos fiscais do per�odo de '+ DtoC(MV_PAR01) +' at� '+ DtoC(MV_PAR02) +'.<br><br><br>
	_cMensagem += ' 		</td>
	_cMensagem += ' 	</tr>
	_cMensagem += ' 	<tr>
	_cMensagem += ' 		<td height="20px" width="831px" style="font-family:Verdana;font-size:10px;color:#FFFFFF;vertical-align:middle;background-color:#104E8B" colspan="3">
	_cMensagem += ' 			<center><b>Aten��o: essa mensagem � gerada de forma autom�tica, favor n�o responder esse e-mail.</b></center>
	_cMensagem += ' 		</td>
	_cMensagem += ' 	</tr>
	_cMensagem += ' </table>
	_cMensagem += ' </center>
	_cMensagem += ' </BODY>
	_cMensagem += ' </HTML>

	BeginSQL Alias _cAlias
		SELECT ZZL_EMAIL 
		FROM %Table:ZZL%
		WHERE D_E_L_E_T_ =' '
		AND ZZL_FILIAL = %xFilial:ZZL%
		AND ZZL_ENVANF	= 'S'
	EndSQL

	While (_cAlias)->( !Eof() )
		_cErro := ""
		U_EnvMail(_cMensagem/*_cMensagem*/,/*_cFrom*/,(_cAlias)->ZZL_EMAIL/* _cTO*/,/*_cCC*/,/*_cBCC*/,/*_cReplyTo*/,_cAssunto/*_cAssunto*/;
					,@_cErro/*_cErro*/,{_cArqZip}/*_aAttach*/)
		If !Empty(_cErro)
			FWAlertWarning("MFIS005003 - E-mail:" + AllTrim((_cAlias)->ZZL_EMAIL) + " Resultado: " +AllTrim(_cErro),"MFIS005003")
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MFIS005003"/*cMsgId*/, "E-mail:" + AllTrim((_cAlias)->ZZL_EMAIL) + " Resultado: " +AllTrim(_cErro)/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
		(_cAlias)->( DBSkip() )
	EndDo
	(_cAlias)->( DBCloseArea() )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
    Fun��o para defini��o de parametros na tela de schedule
@author Lucas Borges Ferreira
@since 25/07/2017
//-----------------------------------------------------------------*/
Static Function Scheddef()

Local aParam := {} as array
Local aOrd := {} as array

Aadd(aParam, "P"        ) // 01 - Tipo R para relatorio P para processo
Aadd(aParam, "MFIS005"  ) // 02 - Pergunte do relatorio, caso nao use passar ParamDef
Aadd(aParam, ""         ) // 03 - Alias
Aadd(aParam, aOrd       ) // 04 - Array de ordens
Aadd(aParam, ""         ) // 05 - Titulo
Aadd(aParam, ""         ) // 06 - Nome do relat�rio (parametro 1 do metodo new da classe TReport)
 
Return aParam
