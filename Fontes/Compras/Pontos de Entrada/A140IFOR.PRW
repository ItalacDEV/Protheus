/*
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira | 08/04/2019 | Informado tipos de fornecedores disponíveis para NF-e - Chamado 28802
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira | 05/08/2021 | Informado tipos de fornecedores disponíveis para NF-e - Chamado 37395
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira | 20/12/2022 | Compatibilizada validação da Incrição Estadual usando a função da TOTVS - Chamado 42163
===============================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: A140IFOR
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/07/2015
===============================================================================================================================
Descrição---------: Ponto de Entrada para informar o fornecedor/cliente da NFe, caso exista duplicidade de CNPJ e Inscrição 
					Estadual nos cadastros de Cliente e/ou Fornecedor.
					Esse PE só é chamado caso exista mais de um fornecedor valido, ou seja, se existirem 3 cadastros e apenas 
					1 desbloqueado, o PE não será chamado.
					Executado no momento da leitura do xml de NF-e para gravação na SDS e SDT - Chamado 15090
===============================================================================================================================
Parametros--------: 	ParamIxb[1] - Tabela de origem dos dados: SA1 ou SA2
					  	ParamIxb[2] - CNPJ do Cliente / Fornecedor
					  	ParamIxb[3] - Inscrição Estadual do Cliente / Fornecedor
					  	ParamIxb[4] - Objeto para obtenção das informações das TAGS do XML
===============================================================================================================================
Retorno-----------: _aRet = Array "aRet" de três posições, contendo obrigatoriamente três elementos.
						Elemento 1 = Código do fornecedor/cliente
						Elemento 2 = Loja do fornecedor/cliente
						Elemento 3 = Nome do fornecedor/cliente
===============================================================================================================================
*/
User Function A140IFOR

Local _aRet		:= {}
Local _cAlias	:= ParamIxb[1]
Local _cCampo	:= _cAlias + " ->" + Substr(ParamIxb[1],2,2)
Local _nX		:= 0
Local _lTroca	:= .F.
Local _cForn	:= SuperGetMV("IT_XMLCFOR",.F.,"L001050020;L001050014;F090570001;L001930002;P285100002")
Local _cCGC		:= SuperGetMV("IT_XMLFFOR",.F.,"76108349002076;76108349001428;06203406000158;07510884000254;14351004000129")
Local _cCFOP	:= SuperGetMV("IT_XMLTCFO",.F.,"5102;6102;6122;6101")
Local _cTipoForn:= SuperGetMV("IT_XMLTFOR",.F.,"F/L/P/0")
Local _cForOri	:= ""

DBSelectArea(_cAlias)
(_cAlias)->( DBSetOrder(3))
	
//Procura registro com CNPJ
If (_cAlias)->( DBSeek(xFilial(_cAlias) + AllTrim(ParamIxb[2]) ) )
	//Roda todos os registros com cnpj válido. Só retorna se achar um que esteja desbloqueado e tenha a mesma inscrição estadual
	Do While AllTrim( &(_cCampo + "_CGC") ) == AllTrim(ParamIxb[2])
		//Tratamentto específico para determinado fornecedor/tipo de operação
		If !_lTroca .And. AllTrim(&(_cCampo + "_CGC")) $ _cCGC
			_aItens := IIF(ValType(ParamIxb[4]:_InfNfe:_Det) == "O",{ParamIxb[4]:_InfNfe:_Det},ParamIxb[4]:_InfNfe:_Det)
			//-- Valida o tipo da nf
			For _nX := 1 To Len(_aItens)
				If _aItens[_nX]:_PROD:_CFOP:TEXT $ _cCFOP
					_lTroca := .T.
					Exit
				EndIf
			Next _nX
		EndIf
		//Pàra NF-e só será permitido fornecedores do tipo F/L/P ou Clientes (0)
		If &(_cCampo + "_MSBLQL") <> '1' .And. A140INSC(ParamIxb[3],&(_cCampo + "_INSCR")) .And. Substr(&(_cCampo + "_COD"),1,1) $ _cTipoForn
			_aRet := { 	&(_cCampo + "_COD"),;
						&(_cCampo + "_LOJA"),;
						&(_cCampo + "_NOME")}
						
			_cForOri := &(_cCampo + "_COD") + &(_cCampo + "_LOJA")

			If !_lTroca .Or. (_lTroca .And. _cForOri $ _cForn)
				Exit
			EndIf 
		Endif
		(_cAlias)->( DBSkip() )
	EndDo
EndIf
Return _aRet
