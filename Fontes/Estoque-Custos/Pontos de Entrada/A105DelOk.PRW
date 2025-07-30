/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa  | 13/11/17   | Chamado 22489. Alterada busca do solicitante para a variavel cSolic
-------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 11/06/2018 | Chamado 29598. Ajustes na validação acrescentou .AND. cUsr <> "0"
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/09/2024 | Chamado 48465. Removendo warning de compilação.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: A105DelOk
Autor-------------: Xavier
Data da Criacao---: 13-04-2015
===============================================================================================================================
Descrição---------: Ponto de entrada na validação do OK da exclusão solicitação ao armazem.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. = Permite confirmar operação, .F. = Nao Permite confirmar operação
===============================================================================================================================
*/
User Function A105DelOk

Local aArea := FWGetArea()
Local lRet :=.T.
Local cUsr, cSol :=  ""

//usuario do mesmo departamento do solicitante pode alterar (ZZL_GRPAPR)
cUsr := Posicione("ZZL",4,XFilial("ZZL")+UsrRetName(__CUSERID),"ZZL_GRPAPR")
cSol := Posicione("ZZL",4,XFilial("ZZL")+CSOLIC,"ZZL_GRPAPR")
If (cUsr # cSol) .And. lRet .AND. cUsr <> "0"
	lRet := .F.
	FWAlertWarning("Operação invalida ! Usuário não pertence ao departamento do solicitante.","A105DelOk01")
EndIf

FWRestArea(aArea)

Return lRet
