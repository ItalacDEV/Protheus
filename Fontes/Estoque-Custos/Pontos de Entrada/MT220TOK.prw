/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/09/2024 | Chamado 48465. Removendo warning de compila��o.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MT220TOK
Autor-------------: Renato de Morcerf
Data da Criacao---: 03/02/2009
===============================================================================================================================
Descri��o---------: Ponto de Entrada que valida tela de lancamento de Saldo Inicial. Valida a obrigatoriedade do preenchimento 
					da segunda unidade de medida quando os produtos pertence ao grupo de produto 0006(Queijo) para controle de 
					estoque de pecas de queijo.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. = Permite confirmar lancamento - .F. = Nao Permite confirmar lancamento
===============================================================================================================================
*/
User Function MT220TOK

Local _lRet 	:=	.T.

If Inclui .And. M->B9_QINI > 0 .And. Substr(M->B9_COD,1,4) == "0006" .And. M->B9_QISEGUM == 0
	FWAlertWarning("Segunda Unidade de Medida vazio. Para esse produto � obrigat�rio o preenchimento da segunda unidade de medida (Pe�as).","MT22OTOK01")
	_lRet := .F.
EndIf

Return _lRet
