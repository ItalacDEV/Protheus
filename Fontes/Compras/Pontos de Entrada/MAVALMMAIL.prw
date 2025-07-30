/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 25/07/2018 | Corrido retorno do disparo do workflow. Chamado 25626
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: MAVALMMAIL
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/07/2018
===============================================================================================================================
Descrição---------: Esse ponto de entrada está localizado na Function MEnviaMail e tem como objetivo o envio de emails de even-
					tos pré-cadastrados do M-Messenger. É chamado no início da função, antes da query que obtém os usuários 
					destinatários dos e-mails conforme o evento disparado. Também é usado para continuar ou não o processo de 
					envio do e-mail, conforme avaliação do usuário.
===============================================================================================================================
Parametros--------: cEvento -> C -> Código do evento a ser disparado
					aDados -> A -> Array com os dados relativos ao evento
					cParUsuario -> A -> String com usuários a serem considerados
					cParGrUsuario -> A -> String com grupos de usuários a serem considerados
					cParEmails -> A -> String com e-mails a serem considerados
					lEvRH -> L ->  se o formato mensagem for HTML / .F. => se o formato não for HTML
===============================================================================================================================
Retorno-----------: lEnvia = .T. envia e-mail / lEnvia = .F. interrompe o processo e não envia o e-mail
===============================================================================================================================
*/
User Function MAVALMMAIL

Local cEvento := ParamIxb[1]
Local _lEnvia := .F.
Local _aArea 	:= GetArea()
Local _aAreaSC7 := SC7->(GetArea())
Local _aAreaSC1 := SC1->(GetArea())
Local _aAreaSAN := SAN->(GetArea())

//====================================================================================================
// Verifico se quem incluiu a SC está cadastrado para receber o workflow. Se estiver, disparo o e-mail
// somente para ele. Preciso usar esse e o PE MFILTRMAIL em conjunto. No outro, defini para quem vai ser 
// enviado o e-mail e nesse, faço a mesma validação para dizer que pode enviar.
//====================================================================================================
If cEvento == '030' .And. !Empty(SD1->D1_PEDIDO)
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(SD1->(D1_FILIAL+D1_PEDIDO+D1_ITEMPC)))
	If !Empty(SC7->C7_NUMSC)
		DBSelectArea("SC1")
		SC1->(DbSetOrder(1))
		SC1->(DbSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC))) 
		SAN->(DbSetOrder(3))
		If SAN->(DbSeek(xFilial("SAN")+cEvento+SC1->C1_USER)) 
			_lEnvia:= .T.
		EndIf
	EndIf
ElseIf !cEvento == '030'
	_lEnvia:= .T.
EndIf

RestArea(_aAreaSC7)
RestArea(_aAreaSC1)
RestArea(_aAreaSAN)
RestArea(_aArea)

Return _lEnvia