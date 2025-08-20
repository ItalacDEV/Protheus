/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |23/12/2024| Chamado 49436. Agrupado os registros por documento para que sejam feitas menos altera��es
Lucas Borges  |08/08/2025| Chamado 51702. Inclu�do tratamento para Item Cont�bil e Centro de Custo
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MCTB006
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 18/12/2024
Descri��o---------: Rotina para alterar lan�amentos cont�beis com base em CSV separado por v�rgula. Chamado 49408
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCTB006

Local _oSelf := Nil As Object

//Cria interface principal
tNewProcess():New('MCTB006'			,; // cFunction. Nome da fun��o que est� chamando o objeto
				'Ajusta Lan�amentos Cont�beis',; // cTitle. T�tulo da �rvore de op��es
				{|_oSelf| MCTB006P(_oSelf) },; // bProcess. Bloco de execu��o que ser� executado ao confirmar a tela
				"Rotina para ajuste das contas de D�bito e Cr�dito nos lan�amentos cont�beis"+;
				" com base em CSV separado por v�rgula",; // cDescription. Descri��o da rotina
				'MCTB006'				,; // cPerg. Nome do Pergunte (SX1) a ser utilizado na rotina
				{}						,; // aInfoCustom. Informa��es adicionais carregada na �rvore de op��es. Estrutura:[1] - Nome da op��o[2] - Bloco de execu��o[3] - Nome do bitmap[4] - Informa��es do painel auxiliar.
				.F.						,; // lPanelAux. Se .T. cria um novo painel auxiliar ao executar a rotina
				0						,; // nSizePanelAux. Tamanho do painel auxiliar, utilizado quando lPanelAux = .T.
				''						,; // cDescriAux. Descri��o a ser exibida no painel auxiliar
				.F.						,; // lViewExecute. Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento
				.T.						,; // lOneMeter. Se .T. cria apenas uma r�gua de processamento
				.T.						)  // lSchedAuto. Se .T. habilita o bot�o de processamento em segundo plano (execu��o ocorre pelo Scheduler)

Return

/*
===============================================================================================================================
Programa----------: MCTB006P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 18/12/2024
Descri��o---------: Realiza o processamento da rotina.
Parametros--------: _oSelf
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCTB006P(_oSelf As Object)

Local _oFile	:= Nil As Object
Local _aDados	:= {} As Array
Local _aAux		:= {} As Array
Local _nQtdReg	:= 0 As Numeric
Local _aCab		:= {} As Array
Local _aItens	:= {} As Array
Local _nI		:= 0 As Numeric
Local _cChave	:= '' As Character

Private lMsErroAuto := .F. As Logical
Private lMsHelpAuto := .T. As Logical
Private CTF_LOCK := 0 As Numeric

_oFile	:= FwFileReader():New(MV_PAR01)

If _oFile:Open()
	_aAux := _oFile:GetAllLines() //Acessa todas as Linhas
	//Caso tenha cabe�alho, separo ele
	//Layout do arquivo: DEBITO;CREDITO;CCD;CCC;ITEMD;ITEMC;RECNO;DELETA
	If "DEBITO"$ Upper(_aAux[1])
		ADel(_aAux, 1)
		ASize(_aAux, Len(_aAux) - 1)
	EndIf

	//Separa o Vetor em N�vel conforme Token
	AEval(_aAux, {|x| AAdd(_aDados, StrTokArr2(x, ";", .T.))})

	_oFile:Close()
	If Empty(_aDados)
		FWAlertError("O arquivo est� vazio! Verifique o arquivo e tente novamente.","MCTB00601")
	ElseIf Len(_aDados[1]) <> 8
		FWAlertError("Layout inv�lido para o arquivo! Verifique o arquivo e tente novamente.","MCTB00602")
	Else
		DBSelectArea("CT2")
		_nQtdReg := Len(_aDados)
		_oSelf:SetRegua1(_nQtdReg)
		For _nI := 1 To _nQtdReg
			_oSelf:IncRegua1("Lendo registros...["+ StrZero(_nI,6) +"] de ["+ StrZero(_nQtdReg,6) +"]" ) 
			CT2->(DBGoTo(Val(_aDados[_nI][7])))
			If Val(_aDados[_nI][7]) == CT2->(RECNO())
				aAdd(_aDados[_nI],CT2->CT2_DATA)//9
				aAdd(_aDados[_nI],CT2->CT2_LOTE)//10
				aAdd(_aDados[_nI],CT2->CT2_SBLOTE)//11
				aAdd(_aDados[_nI],CT2->CT2_DOC)//12
				aAdd(_aDados[_nI],CT2->CT2_LINHA)//13
				aAdd(_aDados[_nI],CT2->CT2_DEBITO)//14
				aAdd(_aDados[_nI],CT2->CT2_CREDIT)//15
				aAdd(_aDados[_nI],CT2->CT2_CCD)//16
				aAdd(_aDados[_nI],CT2->CT2_CCC)//17
				aAdd(_aDados[_nI],CT2->CT2_ITEMD)//18
				aAdd(_aDados[_nI],CT2->CT2_ITEMC)//19
			Else
				FWAlertError("N�o foi encontrado registro na CT2 referente ao Recno "+_aDados[_nI][7]+". Linha ignorada.","MCTB00603")
			EndIf
		Next _nI
		
		aSort(_aDados,,,{|x,y| DToS(x[9])+x[10]+x[11]+x[12]+x[13] < DToS(y[9])+y[10]+y[11]+y[12]+y[13]}) //Ordena itens

		_oSelf:SetRegua1(_nQtdReg)

		For _nI := 1 To _nQtdReg
			_oSelf:IncRegua1("Gravando registros...["+ StrZero(_nI,6) +"] de ["+ StrZero(_nQtdReg,6) +"]" )
			
			If _cChave <> DToS(_aDados[_nI][9])+_aDados[_nI][10]+_aDados[_nI][11]+_aDados[_nI][12]
				_aCab := {}
				_aItens := {}
			
				aAdd(_aCab, {'DDATALANC',_aDados[_nI][09],NIL} )//CT2->CT2_DATA
				aAdd(_aCab, {'CLOTE' 	,_aDados[_nI][10],NIL} )//CT2->CT2_LOTE
				aAdd(_aCab, {'CSUBLOTE' ,_aDados[_nI][11],NIL} )//CT2->CT2_SBLOTE
				aAdd(_aCab, {'CDOC' 	,_aDados[_nI][12],NIL} )//CT2->CT2_DOC
			EndIf
				
			If Upper(_aDados[_nI][8]) $ "DELETA"
				aAdd(_aItens,{{'LINPOS'	,'CT2_LINHA',_aDados[_nI][13]},;//CT2->CT2_LINHA - Necess�rio para qualquer altera��o
							{'AUTDELETA','S'		, NIL			} })//Indica se � para deletar a linha
			Else //Se n�o for dele��o, adiciono indicativo para altera��o
				aAdd(_aItens,{{'CT2_DEBITO'	,IIf(Empty(_aDados[_nI][1]),_aDados[_nI][14],_aDados[_nI][1]), NIL},;//CT2->CT2_DEBITO
							{'CT2_CREDIT'	,IIf(Empty(_aDados[_nI][2]),_aDados[_nI][15],_aDados[_nI][2]), NIL},;//CT2->CT2_CREDIT
							{'CT2_CCD'		,IIf(Empty(_aDados[_nI][3]),_aDados[_nI][16],_aDados[_nI][3]), NIL},;//CT2->CT2_CCD
							{'CT2_CCC'		,IIf(Empty(_aDados[_nI][4]),_aDados[_nI][17],_aDados[_nI][4]), NIL},;//CT2->CT2_CCC
							{'CT2_ITEMD'	,IIf(Empty(_aDados[_nI][5]),_aDados[_nI][18],_aDados[_nI][5]), NIL},;//CT2->CT2_ITEMD
							{'CT2_ITEMC'	,IIf(Empty(_aDados[_nI][6]),_aDados[_nI][19],_aDados[_nI][6]), NIL},;//CT2->CT2_ITEMC
							{'LINPOS'		,'CT2_LINHA',_aDados[_nI][13]} } )//CT2->CT2_LINHA
			EndIf
			_cChave := DToS(_aDados[_nI][9])+_aDados[_nI][10]+_aDados[_nI][11]+_aDados[_nI][12]

			//Se a chave for mudar ou se for o �ltimo registro, gravo as altera��es
			If _nI == _nQtdReg .OR. _cChave <> DToS(_aDados[_nI+1][9])+_aDados[_nI+1][10]+_aDados[_nI+1][11]+_aDados[_nI+1][12]
				lMsErroAuto := .F.
				lMsHelpAuto := .T.

				MSExecAuto({|x, y,z| CTBA102(x,y,z)}, _aCab ,_aItens, 4)

				If lMsErroAuto
					lMsErroAuto := .F.
					MostraErro()
				EndIf
			EndIf
			
		Next _nI
	EndIf
Else
	FWAlertError("O arquivo est� vazio ou � inv�lido para an�lise! Verifique o arquivo e tente novamente.","MCTB00604")
	Return
EndIf	

Return
