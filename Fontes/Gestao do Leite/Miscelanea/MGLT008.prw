/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/07/2024 | Inclu�da exporta��o para planilha. Chamado 47820
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MGLT008
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 19/12/2023
===============================================================================================================================
Descri��o---------: Fechamento de terceiros (RGLT020) por e-mail. Chamado 45906
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT008

Local _cPerg		:= "MGLT008"
Local _oSelf		:= nil

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	_cPerg											,; // Fun��o inicial
					"Envio do Fechamento de Terceiros - RGLT020 por e-mail"		,; // Descri��o da Rotina
					{|_oSelf| MGLT008P(_oSelf,_cPerg) }					,; // Fun��o do processamento
					"Este programa ir� enviar por e-mail o Fechamento de terceiros individualmente para cada transportador.",; // Descri��o da Funcionalidade
					_cPerg											,; // Configura��o dos Par�metros
					{}												,; // Op��es adicionais para o painel lateral
					.F.												,; // Define cria��o do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descri��o do Painel Auxiliar
					.T.												,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
                    .T.                                              ) // Se .T. cria apenas uma regua de processamento.

Return

/*
===============================================================================================================================
Programa----------: MGLT008P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 19/12/2023
===============================================================================================================================
Descri��o---------: Realiza o processamento da rotina.
===============================================================================================================================
Parametros--------: _oSelf, _cPerg
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT008P(_oSelf,_cPerg)

Local _cAlias 	:= GetNextAlias()
Local _cReplyTo	:= AllTrim(MV_PAR12)
Local _cFrom	:= Lower(FWSFAllUsers({RetCodUsr()})[1][5])//retorna o e-mail do usu�rio
Local _cAssunto	:= ""
Local _cMensagem:= ""
Local _aAttach 	:= {}
Local _cDtIni 	:= ""
Local _cDtFim 	:= ""
Local _cFiltro	:= "%"
Local _lJob 	:= .T.
Local _aPergunte:= {}
Local _nX 		:= 1
Local _nCountRec:= 0
Local _cDirPlan := ""
Local _lEnvMail := .F.

For _nX := 1 To 11//Tamanho do pergunte do RGLT020
	aAdd(_aPergunte, &("MV_PAR"+StrZero(_nX,2,0)))
Next _nX

_oSelf:SetRegua1(1)
_oSelf:IncRegua1("Buscando registros no banco de dados...")

If MV_PAR01 == 1
	_cDtIni := SubStr( MV_PAR02 , 3 , 4 ) + SubStr( MV_PAR02 , 1 , 2 ) + '01'
	_cDtFim := SubStr( MV_PAR02 , 3 , 4 ) + SubStr( MV_PAR02 , 1 , 2 ) + '15'
Else
	_cDtIni := SubStr( MV_PAR02 , 3 , 4 ) + SubStr( MV_PAR02 , 1 , 2 ) + '16'
	_cDtFim := DtoS( LastDay( StoD( SubStr( MV_PAR02 , 3 , 4 ) + SubStr( MV_PAR02 , 1 , 2 ) + '01' ) ) )
EndIf


_cFiltro += IIf( MV_PAR03 == 1 , " AND SC7.C7_FORNECE  = 'F00001' ", "" )
_cFiltro += IIf( MV_PAR03 == 2 , " AND SC7.C7_FORNECE <> 'F00001' AND SUBSTR(SC7.C7_FORNECE,1,1) <> 'Z' ", "" )
_cFiltro += IIf( MV_PAR03 == 3 , " AND SUBSTR(SC7.C7_FORNECE,1,1) = 'Z' ", "" )
_cFiltro += IIf( !Empty(MV_PAR04) , " AND ZA7.ZA7_TIPPRD IN "+ FormatIn( MV_PAR04 , ';' ), "" )
_cFiltro += "%"

BeginSql alias _cAlias
SELECT A2_COD, A2_LOJA, A2_EMAIL, A2_NOME
          FROM %Table:SC7% SC7, %Table:ZA7% ZA7, %Table:SD1% SD1, %Table:ZLX% ZLX, %Table:SA2% SA2, %Table:ZZX% ZZX
         WHERE SC7.D_E_L_E_T_ = ' '
           AND ZA7.D_E_L_E_T_ = ' '
           AND SD1.D_E_L_E_T_ = ' '
           AND ZLX.D_E_L_E_T_ = ' '
		   AND SA2.D_E_L_E_T_ = ' '
           AND SC7.C7_FILIAL = %xFilial:SC7%
           AND ZA7.ZA7_FILIAL = %xFilial:ZA7%
           AND SD1.D1_FILIAL = %xFilial:SD1%
           AND ZLX.ZLX_FILIAL = %xFilial:ZLX%
		   AND ZA7.ZA7_FILIAL = ZZX.ZZX_FILIAL
           AND ZA7_TIPPRD = ZZX.ZZX_CODPRD
           AND ZA7.ZA7_CODPRD = ZLX_PRODLT
           AND ZZX_CODIGO = ZLX.ZLX_CODANA
           AND SD1.D1_FILIAL = ZLX.ZLX_FILIAL
           AND SD1.D1_FILIAL = ZLX.ZLX_FILIAL
		   AND SA2.A2_COD = SC7.C7_FORNECE
		   AND SA2.A2_LOJA = SC7.C7_LOJA
           %exp:_cFiltro%
           AND SC7.C7_EMISSAO BETWEEN %exp:_cDtIni% AND %exp:_cDtFim%
           AND SC7.C7_FORNECE BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
           AND SC7.C7_LOJA BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR08%
           AND D1_FORNECE = SC7.C7_FORNECE
           AND D1_LOJA = SC7.C7_LOJA
           AND D1_PEDIDO = SC7.C7_NUM
           AND D1_COD = SC7.C7_PRODUTO
           AND ZLX_FORNEC = SC7.C7_FORNECE
           AND ZLX_LJFORN = SC7.C7_LOJA
           AND ZLX_PRODLT = SC7.C7_PRODUTO
           AND ZLX_NRONF = D1_DOC
           AND ZLX_SERINF = D1_SERIE
         GROUP BY A2_COD, A2_LOJA,A2_EMAIL, A2_NOME
		 ORDER BY A2_COD, A2_LOJA
EndSql

Count To _nCountRec
(_cAlias)->( DbGotop() )

_oSelf:SetRegua1(_nCountRec)
_oSelf:IncRegua1("Processando fornecedor "+(_cAlias)->A2_COD+"\"+(_cAlias)->A2_LOJA)
//Criando as Linhas
While (_cAlias)->(!EOF())
	_aAttach := {}
	_aPergunte[5] := (_cAlias)->A2_COD
	_aPergunte[7] := (_cAlias)->A2_COD
	_aPergunte[6] := (_cAlias)->A2_LOJA
	_aPergunte[8] := (_cAlias)->A2_LOJA

	_cErro := ""
	_cAssunto := "Fechamento da "+If(MV_PAR01==1,"1�","2�")+ " quinzena de "+MesExtenso(SToD(_cDtIni))+" "+SubStr(MV_PAR02,3,4)+" - "+AllTrim((_cAlias)->A2_NOME)
	_cMensagem := "<HTML><HEAD></HEAD><BODY><Font face='arial' Style='font-size:14px'>"
	_cMensagem += "O fechamento da "+If(MV_PAR01==1,"1�","2�")+ " quinzena de "+MesExtenso(SToD(_cDtIni))+" "+SubStr(MV_PAR02,3,4)+" est� anexo.<br>"
	_cMensagem += "    Favor emitir e nos enviar as notas fiscais complementares, se houver.<br>"
	_cMensagem += "    Essas notas devem ser enviadas respondendo este e-mail, at� o dia "+AllTrim(Str(Day(DaySum(Date(),5))))+" de "+MesExtenso(DaySum(Date(),5))+ ", para evitarmos transtornos para ambas as partes.<br><br>"
	_cMensagem += "  *Os complementos que n�o forem enviados respondendo este e-mail, est�o sujeitos a serem pagos no dia 10 do m�s seguinte.<br><br>"
	_cMensagem += "    As notas que n�o forem emitidas no padr�o abaixo ser�o recusadas/devolvidas.<br><br><br>"
	_cMensagem += "�        Natureza da opera��o � nota fiscal complementar;<br><br>"
	_cMensagem += "�        Para notas fiscais complementares de valor � Volume igual a 0 (zero);<br><br>"
	_cMensagem += "�        Referenciar o xml de uma NF de origem, emitida durante a quinzena que est� sendo acertada. (N�o basta descrever a NF de refer�ncia no campo informa��es complementares, � necess�rio amarrar o xml da NF de origem ao xml da NF complementar de valor que est� sendo emitida).<br><br>"
	_cMensagem += "    * A refer�ncia do m�s e quinzena deve ser inclu�da no campo das 'informa��es complementares' indicando , ao menos , uma nota de origem.<br>"
	_cMensagem += "            (exemplo 1: Nota fiscal complementar de litragem referente a "+If(MV_PAR01==1,"1�","2�")+ " quinzena de "+If(MV_PAR01==1,MesExtenso(StoD(_cDtIni),1),MesExtenso(MonthSum(StoD(_cDtIni),1)))+ " "+SubStr(MV_PAR02,3,4)+" ref.  Nfs: 000.000 , 000.000 , 000.000).<br>"
	_cMensagem += "               (exemplo 2: Nota fiscal complementar de valor referente a "+If(MV_PAR01==1,"1�","2�")+ " quinzena de "+If(MV_PAR01==1,MesExtenso(StoD(_cDtIni),1),MesExtenso(MonthSum(StoD(_cDtIni),1)))+ " "+SubStr(MV_PAR02,3,4)+" ref.  Nfs: 000.000 , 000.000 , 000.000).<br>"
	
	_cMensagem += "</Font></BODY></HTML>"
	If MV_PAR13 == 1
		_lEnvMail := .T.
	EndIf
	If MV_PAR11 <> 2
		_cDirPlan := __RelDir+(_cAlias)->A2_COD+(_cAlias)->A2_LOJA+"_RGLT020.pdf"
		aAdd(_aAttach,_cDirPlan)
		U_RGLT020(_lJob,_aPergunte,.T.,_lEnvMail,_cDirPlan,MV_PAR14)
	EndIf
	If MV_PAR11 <> 1
		_cDirPlan := __RelDir+(_cAlias)->A2_COD+(_cAlias)->A2_LOJA+"_RGLT020.xlsx"
		aAdd(_aAttach,_cDirPlan)
		U_RGLT020(_lJob,_aPergunte,.F.,_lEnvMail,_cDirPlan,MV_PAR14)
	EndIf

	If _lEnvMail
		U_EnvMail(_cMensagem/*_cMensagem*/,_cFrom/*_cFrom*/,(_cAlias)->A2_EMAIL /*_cTO*/,;
				_cReplyTo/*_cCC*/,/*_cBCC*/,_cReplyTo/*_cReplyTo*/,_cAssunto/*_cAssunto*/,@_cErro/*_cErro*/,_aAttach/*_aAttach*/)
		If !Empty(_cErro)
			MsgStop("MGLT00801 - E-mail:" + (_cAlias)->A2_EMAIL + " Resultado: " +AllTrim(_cErro),"MGLT00801")
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGLT00801"/*cMsgId*/, "E-mail:" + (_cAlias)->A2_EMAIL + " Resultado: " +AllTrim(_cErro)/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
	EndIf
	For _nX := 1 To Len(_aAttach)
		FErase(_aAttach[_nX])
	Next _nX
	(_cAlias)->(DbSkip())
EndDo
(_cAlias)->(DbCloseArea())

Return
