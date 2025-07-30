/*
===============================================================================================================================
               ULTIMAS ATUALIZACOES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 10/09/15 | Chamado 10999. Foi feito tratamento se o usuario logado esta cadastrado na tabela de Solicitantes/Aprovadores. 
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 05/10/15 | Chamado 10999. Incluido tratamento, onde o sistema valida se ha comprador informado na solicitacao, caso
			               haja, o sistema nao deixa o registro ser alterado. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/19 | Chamado 28346. Removidos os Warning na compilacao da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 28/04/20 | Chamado 32763. Alterar chamada "MsgBox" para "U_ITMSG". 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 15/07/24 | Chamado 47732. Ajsute para as mensagens/U_ITMSG de erro aparece com a figura de erro.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MSC1110D
Autor-------------: Tiago Correa Castro
Data da Criacao---: 31/07/2008
===============================================================================================================================
Descricao---------: Ponto de Entrada para validar exclusao da Solicitacao de Compra
					Localizacao: Function A110Deleta  - Funcao de exclusao da Solicitacao de Compras
					Em que Ponto: Antes da apresentacao da dialog de exclusao da SC possibilita validar a solicitacao posicionada
					para continuar e executar a exclusao ou nao.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lDeleta -> L -> .T. Deleta / .F. Aborta delecao.
===============================================================================================================================
*/
User Function MSC1110D

Local _aArea 	:=	GetArea()
Local _lDeleta	:= 	.T.
Local _cCodSol 	:= 	__cUserId

If 	_cCodSol <> SC1->C1_I_CDSOL
	_lDeleta := .F. 
	  U_ITMSG("Solicitacao nao podera ser excluida, pois a mesma foi incluida pelo usuario: "+SC1->C1_I_CDSOL + "- "+AllTrim(Posicione("SRA",1,SUBSTR(SC1->C1_I_CDSOL,1,2)+SUBSTR(SC1->C1_I_CDSOL,3,6),"RA_NOME")),;
		        "Usuário Inválido",;
		        "Verificar com o usuário que incluiu s SC.",1)  
Endif

If _lDeleta
	//=====================================================================================================================
	// Valida se o usurio corrente existe na tabela de cadastro de solicitante e aprovadores, e se este no est bloqueado
	//=====================================================================================================================
	DBSelectArea("ZZ7")
	ZZ7->(DBSetOrder(1))
	If !ZZ7->(DBSeek(xFilial("ZZ7") + _cCodSol))
		_lDeleta := .F.
		U_ITMSG("O usuário logado não está cadastrado como Solicitante ou Aprovador, usuario: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),;
		        "Usuário Inválido",;
		        "Verificar com a área de TI a possibilidade de habilitar o seu usuário.",1)  
	Else
		If ZZ7->ZZ7_STATUS == "B"
			_lDeleta := .F.
			U_ITMSG("O usuário logado está Bloqueado no cadastrado de Solicitante / Aprovador, usuario: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),;
		        "Usuário Inválido",;
		        "Verificar com a área de TI a possibilidade de habilitar o seu usuário.",1)  
		EndIf
	EndIf
EndIf

If !Empty(SC1->C1_CODCOMP)
	_lDeleta := .F.
	U_ITMSG("Solicitação não poderá ser excluída, pois a mesma já possui comprador indicado.",;
		        "Não permitido",;
		        "Verificar com o depto. de compras a indicação a sua SC.",1)  
EndIf

RestArea(_aArea)
Return(_lDeleta)
