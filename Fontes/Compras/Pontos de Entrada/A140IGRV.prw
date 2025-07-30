/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/05/2023 | Problema na grava��o do DT_CLASFIS resolvido. Chamado 43234
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 30/11/2023 | Grava��o de novos campos de imposto que a TOTVS n�o quer fazer. Chamado 45717
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 01/07/2024 | Inclu�da grava��o na C00 para os casos em que n�o passou pelo A140ICFOP. Chamado 47711
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: A140IGRV
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/12/2020
===============================================================================================================================
Descri��o---------: Ponto de entrada ap�s a grava��o dos dados do XML nas tabelas de importa��o (SDS,SDT). Funcao para leitura 
					de XMLs de NFe no diretorio de download e geracao da pre-nota de entrada. Em que ponto: Ap�s a grava��o dos 
					registros importados na tabela SDS e SDT, permite manipular os dados importados para a tabela SDS e SDT.
===============================================================================================================================
Parametros--------: ParamIxb[1]	-> C -> N�mero do documento
					ParamIxb[2]	-> C -> S�rie do documento
					ParamIxb[3]	-> C -> C�digo do Fornecedor
					ParamIxb[4]	-> C -> Loja do Fornecedor
					ParamIxb[5]	-> O -> XML referente ao documento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A140IGRV

Local _cQuery	:= ''
Local _aItens	:= IIf(ValType(ParamIxb[5]:_InfNfe:_Det) == "O",{ParamIxb[5]:_InfNfe:_Det},ParamIxb[5]:_InfNfe:_Det)
Local _nX		:= 0
Local _cCSTCOF	:= ""
Local _cCSTPIS	:= ""
Local _aArea	:= GetArea()
Local _aAreaSA2 := SA2->(GetArea())

//Verifico se os par�metros vieram preenchidos pois o PE est� sendo chamado indevidamente, faltando par�metros
//e posicionando nos registros errados
If !Empty(ParamIxb[1]) .And. !Empty(ParamIxb[2]) .And. !Empty(ParamIxb[3]) .And. !Empty(ParamIxb[4])
	_cQuery:=" UPDATE "+RetSQLName('SDT')+" SET DT_LOCAL = '31' "
	_cQuery+="  WHERE D_E_L_E_T_ = ' ' "
	_cQuery+="  AND DT_FILIAL = '"+cFilAnt+"'"
	_cQuery+="  AND DT_DOC = '"+ParamIxb[1]+"'"
	_cQuery+="  AND DT_SERIE = '"+ParamIxb[2]+"'"
	_cQuery+="  AND DT_FORNEC = '"+ParamIxb[3]+"'"
	_cQuery+="  AND DT_LOJA = '"+ParamIxb[4]+"'"
	_cQuery+="  AND EXISTS (SELECT 1 FROM "+RetSQLName('SDS')
	_cQuery+="         WHERE D_E_L_E_T_ = ' '"
	_cQuery+="         AND DS_FILIAL = DT_FILIAL"
	_cQuery+="         AND DS_DOC = DT_DOC"
	_cQuery+="         AND DS_SERIE = DT_SERIE"
	_cQuery+="         AND DS_FORNEC = DT_FORNEC"
	_cQuery+="         AND DS_LOJA = DT_LOJA"
	_cQuery+="         AND DS_CNPJ = DT_CNPJ"
	_cQuery+="         AND DS_TIPO = 'D')"
	_cQuery+="  AND EXISTS (SELECT 1 FROM "+RetSQLName('SB1')
	_cQuery+="         WHERE D_E_L_E_T_ = ' '"
	_cQuery+="         AND DT_COD = B1_COD"
	_cQuery+="         AND B1_TIPO = 'PA')"

	If TCSqlExec( _cQuery ) < 0
		FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "A140IGRV01"/*cMsgId*/, "Filial: "+cFilant+"] - Erro: "+AllTrim(TCSQLError())/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
	
	DbSelectArea("SDT")
	SDT->(dbSetOrder(3))
	SDT->(dbSeek(cFilAnt+ParamIxb[3]+ParamIxb[4]+ParamIxb[1]+ParamIxb[2]))
	While !SDT->(EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == cFilAnt+ParamIxb[3]+ParamIxb[4]+ParamIxb[1]+ParamIxb[2]
		For _nX := 1 To Len(_aItens)
			If AllTrim(_aItens[_nX]:_PROD:_CPROD:TEXT) == AllTrim(SDT->DT_PRODFOR)
				//--PIS
				_cCSTPIS := ""
				If ValType(XmlChildEx(_aItens[_nX]:_Imposto,"_PIS")) == "O"
					If ValType(XmlChildEx(_aItens[_nX]:_Imposto:_PIS,"_PISALIQ")) == "O"//Grupo PIS tributado pela al�quota
						_cCSTPIS := _aItens[_nX]:_Imposto:_PIS:_PISAliq:_CST:Text
					ElseIf ValType(XmlChildEx(_aItens[_nX]:_Imposto:_PIS,"_PISQTDE")) == "O"//Grupo PIS tributado por Qtde
						_cCSTPIS := _aItens[_nX]:_Imposto:_PIS:_PISQtde:_CST:Text
					ElseIf ValType(XmlChildEx(_aItens[_nX]:_Imposto:_PIS,"_PISNT")) == "O"//Grupo PIS n�o tributado
						_cCSTPIS := _aItens[_nX]:_Imposto:_PIS:_PISNT:_CST:Text
					ElseIf ValType(XmlChildEx(_aItens[_nX]:_Imposto:_PIS,"_PISOUTR")) == "O"//Grupo PIS Outras Opera��es
						_cCSTPIS := _aItens[_nX]:_Imposto:_PIS:_PISOutr:_CST:Text
					EndIf
				EndIf
				//--COFINS
				_cCSTCOF := ""
				If ValType(XmlChildEx(_aItens[_nX]:_Imposto,"_COFINS")) == "O"
					If ValType(XmlChildEx(_aItens[_nX]:_Imposto:_COFINS,"_COFINSALIQ")) == "O"//Grupo PIS tributado pela al�quota
						_cCSTCOF := _aItens[_nX]:_Imposto:_COFINS:_COFINSAliq:_CST:Text
					ElseIf ValType(XmlChildEx(_aItens[_nX]:_Imposto:_COFINS,"_COFINSQTDE")) == "O"//Grupo PIS tributado por Qtde
						_cCSTCOF := _aItens[_nX]:_Imposto:_COFINS:_COFINSQtde:_CST:Text
					ElseIf ValType(XmlChildEx(_aItens[_nX]:_Imposto:_COFINS,"_COFINSNT")) == "O"//Grupo PIS n�o tributado
						_cCSTCOF := _aItens[_nX]:_Imposto:_COFINS:_COFINSNT:_CST:Text
					ElseIf ValType(XmlChildEx(_aItens[_nX]:_Imposto:_COFINS,"_COFINSOUTR")) == "O"//Grupo PIS Outras Opera��es
						_cCSTCOF := _aItens[_nX]:_Imposto:_COFINS:_COFINSOutr:_CST:Text
					Endif
				EndIf
				
				RecLock("SDT",.F.)
				SDT->DT_I_POSIP := If(ValType(XmlChildEx(_aItens[_nX]:_Prod,"_NCM")) == "O", AllTrim(_aItens[_nX]:_PROD:_NCM:TEXT),"")
				SDT->DT_I_XCEST := If(ValType(XmlChildEx(_aItens[_nX]:_Prod,"_CEST")) == "O", AllTrim(_aItens[_nX]:_PROD:_CEST:TEXT),"")
				SDT->DT_I_XFCI := If(ValType(XmlChildEx(_aItens[_nX]:_Prod,"_CBENEF")) == "O", AllTrim(_aItens[_nX]:_PROD:_CBENEF:TEXT),"")
				SDT->DT_I_XCPIS:= _cCSTPIS
				SDT->DT_I_XCCOF:= _cCSTCOF
				SDT->(MsUnLock())
				Exit
			EndIf
		Next _nX
		SDT->(dbSkip())
	Enddo

	DbSelectArea("C00")
	C00->(DbSetOrder(1))
	//Se o Documento j� foi marcado como cancelado, n�o preciso incl��-lo, pois outra fun��o far� a exclus�o. Sem isso ficar� um loop de incluir/excluir sempre que reprocessar os documentos.
	If !C00->(DBSeek(xFilial("C00")+SDS->DS_CHAVENF))
		SA2->(dbSetOrder(1))
		SA2->(DBSeek(xFilial("SA2")+SDS->(DS_FORNEC+DS_LOJA)))
		RecLock("C00",.T.)
		C00_FILIAL	:= SDS->DS_FILIAL
		C00_CHVNFE	:= SDS->DS_CHAVENF
		C00_SERNFE	:= SDS->DS_SERIE
		C00_NUMNFE	:= SDS->DS_DOC
		C00_VLDOC	:= SDS->DS_VALMERC
		C00_DTEMI	:= SDS->DS_EMISSA
		C00_DTREC	:= SDS->DS_DATAIMP
		C00_NOEMIT	:= SA2->A2_NOME
		C00_CNPJEM	:= SDS->DS_CNPJ
		C00_IEEMIT	:= SA2->A2_INSCR
		C00_STATUS	:= '0'
		C00_CODRET	:= '999'
		C00_DESRES	:= 'Documento incluido manualmente'
		C00_MESNFE	:= Strzero(Month(SDS->DS_EMISSA),2)
		C00_ANONFE	:= Strzero(Year(SDS->DS_EMISSA),4)
		C00_SITDOC	:= '1' //"Uso autorizado da NFe"
		C00_CODEVE	:= '1'//"Envio de Evento n�o realizado"_

		C00->(msUnlock())
	EndIf
EndIf

RestArea(_aAreaSA2)
RestArea(_aArea)

Return
