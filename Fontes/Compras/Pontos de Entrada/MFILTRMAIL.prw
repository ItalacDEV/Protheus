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
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: MFILTRMAIL
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/07/2018
===============================================================================================================================
Descri��o---------: Esse ponto de entrada � utilizado para filtrar os e-mails, usu�rios e grupos que devem ser considerados no 
					envio do Messenger.
===============================================================================================================================
Parametros--------: cParUsuario -> C -> ParamIxb[1]- String com os usu�rios que devem receber o e-mail do Messenger
					cParGrUsuario -> C -> ParamIxb[2]-String com os grupos de usu�rios que devem receber o e-mail do Messenger
					cParEmails -> C -> ParamIxb[3]- String com as contas de e-mail avulsas que devem receber o e-mail do Messenger
					Existem duas vari�veis privadas que podem ser utilizadas para consulta, mas N�O PODE SEREM ALTERADAS:
					cFormEvent - Cont�m o codigo do evento
					aFormDados - Array com os dados relativos ao evento
===============================================================================================================================
Retorno-----------: aRetorMail -> A -> aRetorMail[1] - String com os usu�rios que devem receber o e-mail do Messenger.
									aRetorMail[2] - String com os grupos de usu�rios que devem receber o e-mail do Messenger.
									aRetorMail[3] - String com as contas de e-mail avulsas que deve m receber o e-mail do Messenger.
===============================================================================================================================
*/
User Function MFILTRMAIL

Local _aArea 	:= GetArea()
Local _aAreaSC7 := SC7->(GetArea())
Local _aAreaSC1 := SC1->(GetArea())
Local _aAreaSAN := SAN->(GetArea())
Local _aRetorMail := {}

//====================================================================================================
// Verifico se quem incluiu a SC est� cadastrado para receber o workflow. Se estiver, disparo o e-mail
// somente para ele. Preciso usar esse e o PE MAVALMMAIL em conjunto. Aqui defini para quem vai ser 
// enviado o e-mail e no outro fa�o a mesma valida��o para dizer que pode enviar.
//====================================================================================================
If cFormEvent == '030' .And. !Empty(SD1->D1_PEDIDO)
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(SD1->(D1_FILIAL+D1_PEDIDO+D1_ITEMPC)))
	If !Empty(SC7->C7_NUMSC)
		DBSelectArea("SC1")
		SC1->(DbSetOrder(1))
		SC1->(DbSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC))) 
		SAN->(DbSetOrder(3))
		If SAN->(DbSeek(xFilial("SAN")+cFormEvent+SC1->C1_USER)) 
			aAdd(_aRetorMail,SC1->C1_USER)
			aAdd(_aRetorMail,"")
			aAdd(_aRetorMail,"")
		EndIf
	EndIf
EndIf

RestArea(_aAreaSC7)
RestArea(_aAreaSC1)
RestArea(_aAreaSAN)
RestArea(_aArea)

Return _aRetorMail