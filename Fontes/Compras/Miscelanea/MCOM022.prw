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
#Include "Protheus.ch"
/*
===============================================================================================================================
Programa----------: MCOM022
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/03/2024
===============================================================================================================================
Descri��o---------: Executa a rotina Refaz Poder de Terceiros (MATA216). Usar at� a TOTVS implementar o agendamento no padr�o
					Chamado 46524
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM022

MSExecAuto({|x| MATA216(x)},.T.)

Return

/*
===============================================================================================================================
Programa----------: SchedDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 25/05/2017
===============================================================================================================================
Descri��o---------: Defini��o de Static Function SchedDef para o novo Schedule
					No novo Schedule existe uma forma para a defini��o dos Perguntes para o bot�o Par�metros, al�m do cadastro 
					das fun��es no SXD. Ao definir em sua rotina a static function SchedDef(), no cadastro da rotina no Agenda-
					mento do Schedule ser� verificado se existe esta static function e ir� execut�-la habilitando o bot�o Par�-
					metros com as informa��es do retorno da SchedDef(), deixando de verificar assim as informa��es na SXD. O 
					retorno da SchedDef dever� ser um array.
					V�lido para Function e User Function, lembrando que uma vez definido a SchedDef, ao chamar a rotina o ambi-
					ente j� est� inicializado.
					Uma vez definido a Static Function SchedDef(), a rotina deixa de ser uma execu��o como processo especial, 
					ou seja, n�o se deve cadastr�-la no Agendamento passando par�metros de linha. Ex: Funcao("A","B") ou 
					U_Funcao("A","B").
===============================================================================================================================
Parametros--------: aReturn[1] - Tipo: "P" - para Processo, "R" -  para Relat�rios
					aReturn[2] - Nome do Pergunte, caso nao use passar ParamDef
					aReturn[3] - Alias  (para Relat�rio)
					aReturn[4] - Array de ordem  (para Relat�rio)
					aReturn[5] - T�tulo (para Relat�rio)
===============================================================================================================================
Retorno-----------: aParam
===============================================================================================================================
*/
Static Function SchedDef()

Local aParam  := {}
Local aOrd := {}

aParam := { "P",;
            "MTA216",;
            "",;
            aOrd,;
            }
            
Return aParam
