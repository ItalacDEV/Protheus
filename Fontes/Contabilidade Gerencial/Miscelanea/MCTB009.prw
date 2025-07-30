/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 26/06/2017 | Corrigida mensagem de aviso. Chamado 20598
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/09/2019 | Revis�o do fonte. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: MCTB009
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2017
===============================================================================================================================
Descri��o---------: Rotina para remover caracteres inv�lidos no hist�rico das contabilia��es evitando erros nos arquivos magn�ticos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCTB009

Local _cPerg		:= "MCTB009"
Local _oSelf		:= nil

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	_cPerg								,; // Fun��o inicial
					"Gera arquivo Banco do Brasil"		,; // Descri��o da Rotina
					{|_oSelf| MCTB09P(_oSelf) }			,; // Fun��o do processamento
					"Rotina para remover caracteres inv�lidos no hist�rico das contabilia��es evitando erros " +;
					" nos arquivos magn�ticos" 			,; // Descri��o da Funcionalidade
					_cPerg								,; // Configura��o dos Par�metros
					{}									,; // Op��es adicionais para o painel lateral
					.F.									,; // Define cria��o do Painel auxiliar
					0									,; // Tamanho do Painel Auxiliar
					''									,; // Descri��o do Painel Auxiliar
					.T.									,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
					.T.									 ) // Op��o para cria��o de apenas uma r�gua de processamento

Return

/*
===============================================================================================================================
Programa----------: MGPE06P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/08/2019
===============================================================================================================================
Descri��o---------: Realiza o processamento da rotina.
===============================================================================================================================
Parametros--------: _oSelf
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCTB09P(_oSelf)

Local 	_cQuery:= " "

_oSelf:SaveLog("Iniciando a rotina. Par�metros: "+DToC(MV_PAR01)+"-"+DToC(MV_PAR02))

_cQuery := "UPDATE "
_cQuery += RETSQLNAME("CT2")
_cQuery += " SET	CT2_HIST = REGEXP_REPLACE (CT2_HIST , '(/|'||CHR(39)||'|&|%|'||CHR(34)||'|�||'||CHR(9)||')',' ')"
_cQuery += " WHERE "
_cQuery += " D_E_L_E_T_ = ' '" 
_cQuery += " AND CT2_DATA BETWEEN '"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) +"'"
_cQuery += " AND REGEXP_LIKE (CT2_HIST , '(/|'||CHR(39)||'|&|%|'||CHR(34)||'|�||'||CHR(9)||')','i')"
	
If TCSqlExec( _cQuery ) < 0
	MsgStop("Processamento com erro. " + TCSQLError(),"MCTB00901")
Else
	MsgInfo("Processamento conclu�do com sucesso!","MCTB00902")
EndIf

Return