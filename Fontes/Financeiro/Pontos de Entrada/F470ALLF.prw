/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor                |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Vanderson Vasconcelos | 10/04/2017 | Altera��o do ponto-de-entrada para retornar .T. e considerar apenas a filial corrente.
                      |            | Chamados 21905/21857/21793.             
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz             | 13/10/2017 | Padroniza��o do fonte (Cabe�alhos, grava��o de log de acesso). Chamado 21905.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges 		  | 09/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "rwmake.ch"
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: F470ALLF
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/06/2016
===============================================================================================================================
Descri��o---------: Ponto de Entrada que defini se o sistema filtrar� todas as filiais ou apenas a filial corrente.
                    Este ponto de entrada permite a sinaliza��o de que deve ser feito o  tratamento do extrato utilizando o 
                    filtro da filial corrente. A rotina de Extrato Bancario disp�e de tratamentos para que a filial do SE5 n�o 
                    seja filtrada caso quando 'SA6 exclusivo' e 'SE5 compartilhado' Esse controle � feito garantir a 
                    integridade do Extrato Banc�rio. No entanto,  o cliente pode utilizar suas tabelas nessa configura��o e  
                    ainda assim ter somente 1 filial ou todos os movimentos banc�rios na mesma filial. Para tal,foi 
                    disponibilizado um Ponto de Entrada para que possa ser sinalizado que quer o tratamento do extrato 
                    utilizando o filtro da filial corrente. 
===============================================================================================================================
Parametros--------: ParamIxb[1] lAllFil (L) - informa se o sistema n�o vai filtrar por filial - considerando todas as filiais 
					(.T.) ou vai filtrar por filial - considerando somente os registros da filial corrente(.F.)
===============================================================================================================================
Retorno-----------: lRet -> .F. Considera todas as filiais / .T. Considera apenas filial corrente.
===============================================================================================================================
*/
User Function F470ALLF()
Local _aArea	:= GetArea()
Local _lRet		:= .T. 

U_ITLOGACS() //Grava log de utiliza��o

RestArea(_aArea)
Return(_lRet)