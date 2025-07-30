/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/12/2024 | Chamado 49436. Agrupado os registros por documento para que sejam feitas menos alterações
===============================================================================================================================
*/

//===========================================================================
//| Definições de Includes                                                  |
//===========================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MCTB006
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 18/12/2024
Descrição---------: Rotina para alterar lançamentos contábeis com base em CSV separado por vírgula. Chamado 49408
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCTB006

Local _oSelf as Object

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	"MCTB006"										,; // Função inicial
					"Ajusta Lançamentos Contábeis"					,; // Descrição da Rotina
					{|_oSelf| MCTB006P(_oSelf) }					,; // Função do processamento
					"Rotina para ajuste das contas de Débito e Crédito nos lançamentos contábeis"+;
					" com base em CSV separado por vírgula",; // Descrição da Funcionalidade
					"MCTB006"										,; // Configuração dos Parâmetros
					{}												,; // Opções adicionais para o painel lateral
					.F.												,; // Define criação do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descrição do Painel Auxiliar
					.F.												,; // Se .T. exibe o painel de execução. Se falso, apenas executa a função sem exibir a régua de processamento.
                    .T.                                              ) // Se .T. cria apenas uma regua de processamento.

Return

/*
===============================================================================================================================
Programa----------: MCTB006P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 18/12/2024
Descrição---------: Realiza o processamento da rotina.
Parametros--------: _oSelf
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCTB006P(_oSelf as Object)

Local _oFile	as Object
Local _aDados	:= {} as Array
Local _aAux		:= {} as Array
Local _nQtdReg	as Numeric
Local _aCab		as Array
Local _aItens	as Array
Local _nI		as Numeric
Local _cChave	as String

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private CTF_LOCK := 0

_oFile	:= FwFileReader():New(MV_PAR01)

If _oFile:Open()
	_aAux := _oFile:GetAllLines() //Acessa todas as Linhas
	//Caso tenha cabeçalho, separo ele
	//Layout do arquivo: DEBITO;CREDITO;RECNO;DELETA
	If "DEBITO"$ Upper(_aAux[1])
		ADel(_aAux, 1)
		ASize(_aAux, Len(_aAux) - 1)
	EndIf

	//Separa o Vetor em Nível conforme Token
	AEval(_aAux, {|x| AAdd(_aDados, StrTokArr2(x, ";", .T.))})

	_oFile:Close()
	If Empty(_aDados)
		FWAlertError("O arquivo está vazio! Verifique o arquivo e tente novamente.","MCTB00601")
	ElseIf Len(_aDados[1]) <> 4 
		FWAlertError("Layout inválido para o arquivo! Verifique o arquivo e tente novamente.","MCTB00602")
	Else
		DBSelectArea("CT2")
		_nQtdReg := Len(_aDados)
		_oSelf:SetRegua1(_nQtdReg)
		For _nI := 1 To _nQtdReg
			_oSelf:IncRegua1("Lendo registros...["+ StrZero(_nI,6) +"] de ["+ StrZero(_nQtdReg,6) +"]" ) 
			CT2->(DBGoTo(Val(_aDados[_nI][3])))
			If Val(_aDados[_nI][3]) == CT2->(RECNO())
				aAdd(_aDados[_nI],CT2->CT2_DATA)
				aAdd(_aDados[_nI],CT2->CT2_LOTE)
				aAdd(_aDados[_nI],CT2->CT2_SBLOTE)
				aAdd(_aDados[_nI],CT2->CT2_DOC)
				aAdd(_aDados[_nI],CT2->CT2_LINHA)
				aAdd(_aDados[_nI],CT2->CT2_DEBITO)
				aAdd(_aDados[_nI],CT2->CT2_CREDIT)
			Else
				FWAlertError("Não foi encontrado registro na CT2 referente ao Recno "+_aDados[_nI][3]+". Linha ignorada.","MCTB00603")
			EndIf
		Next _nI
		
		aSort(_aDados,,,{|x,y| DToS(x[5])+x[6]+x[7]+x[8]+x[9] < DToS(y[5])+y[6]+y[7]+y[8]+y[9]}) //Ordena itens

		_oSelf:SetRegua1(_nQtdReg)

		For _nI := 1 To _nQtdReg
			_oSelf:IncRegua1("Gravando registros...["+ StrZero(_nI,6) +"] de ["+ StrZero(_nQtdReg,6) +"]" )
			
			If _cChave <> DToS(_aDados[_nI][5])+_aDados[_nI][6]+_aDados[_nI][7]+_aDados[_nI][8]
				_aCab := {}
				_aItens := {}
			
				aAdd(_aCab, {'DDATALANC',_aDados[_nI][5],NIL} )//CT2->CT2_DATA
				aAdd(_aCab, {'CLOTE' 	,_aDados[_nI][6],NIL} )//CT2->CT2_LOTE
				aAdd(_aCab, {'CSUBLOTE' ,_aDados[_nI][7],NIL} )//CT2->CT2_SBLOTE
				aAdd(_aCab, {'CDOC' 	,_aDados[_nI][8],NIL} )//CT2->CT2_DOC
			EndIf
				
			If Upper(_aDados[_nI][4]) $ "DELETA"
				aAdd(_aItens,{{'LINPOS'	,'CT2_LINHA',_aDados[_nI][9]},;//CT2->CT2_LINHA - Necessário para qualquer alteração
							{'AUTDELETA','S'		, NIL			} })//Indica se é para deletar a linha
			Else //Se não for deleção, adiciono indicativo para alteração
				aAdd(_aItens,{{'CT2_DEBITO'	,IIf(Empty(_aDados[_nI][1]),_aDados[_nI][10],_aDados[_nI][1]), NIL},;//CT2->CT2_DEBITO
							{'CT2_CREDIT'	,IIf(Empty(_aDados[_nI][2]),_aDados[_nI][11],_aDados[_nI][2]), NIL},;//CT2->CT2_CREDIT
							{'LINPOS'		,'CT2_LINHA',_aDados[_nI][9]} } )//CT2->CT2_LINHA
			EndIf
			_cChave := DToS(_aDados[_nI][5])+_aDados[_nI][6]+_aDados[_nI][7]+_aDados[_nI][8]

			//Se a chave for mudar ou se for o último registro, gravo as alterações
			If _nI == _nQtdReg .OR. _cChave <> DToS(_aDados[_nI+1][5])+_aDados[_nI+1][6]+_aDados[_nI+1][7]+_aDados[_nI+1][8]
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
	FWAlertError("O arquivo está vazio ou é inválido para análise! Verifique o arquivo e tente novamente.","MCTB00604")
	Return
EndIf	

Return
