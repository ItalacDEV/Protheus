/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MFIS006
Autor-------------: Lucas Borges Ferrreira
Data da Criacao---: 03/08/2020
===============================================================================================================================
Descri��o---------: Permite ajustar a sequ�ncia de numera��o das Notas Formul�rio Pr�prio. Chamado 33714
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS006

Local _oSelf	:= nil
Local _aButtons	:={}

ProcLogIni( _aButtons )
//============================================
//Cria interface principal
//============================================
tNewProcess():New(	"MFIS006"							,; // Fun��o inicial
					"Atualiza N�mera��o da NF-e"		,; // Descri��o da Rotina
					{|_oSelf| MFIS06P(_oSelf) }   		,; // Fun��o do processamento
					"Rotina para permitir alterar o n�mero da pr�xima Nota Foruml�rio Pr�prio",; // Descri��o da Funcionalidade
														,; // Configura��o dos Par�metros
					{}									,; // Op��es adicionais para o painel lateral
					.F.									,; // Define cria��o do Painel auxiliar
					0									,; // Tamanho do Painel Auxiliar
					''									,; // Descri��o do Painel Auxiliar
					.F.									,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
                    .F.                                 ) // Se .T. cria apenas uma regua de processamento.

ProcLogAtu("FIM")

Return

/*
===============================================================================================================================
Programa----------: MFIS06P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 03/08/2020
===============================================================================================================================
Descri��o---------: Monta rotina para altera��o da numera��o das notas
===============================================================================================================================
Parametros--------: _oSelf
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS06P(_oSelf)

Local _cSerie := ""
If !Sx5NumNota(@_cSerie)
    ProcLogAtu("MENSAGEM","ERRO ao alterar numeracao de nota serie "+_cSerie,"","MFIS006")
Else
	ProcLogAtu("MENSAGEM","Alterada a numeracao de nota serie "+_cSerie,"","MFIS006")
EndIf

Return
