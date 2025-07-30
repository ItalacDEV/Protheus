/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 09/05/2018 | Padroniza��o dos cabe�alhos dos fontes e fun��es do m�dulo financeiro. Chamado 24726.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

/*
===============================================================================================================================
Programa----------: F040FRT
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 17/10/2012
===============================================================================================================================
Descri��o---------: Ponto de Entrada para gera��o da reten��o de PCC na emiss�o do Contas a Receber. 
					O ponto de entrada F040FRT possibilita a manipula��o de filiais no c�lculo de impostos na rotina de Contas 
					a Receber. Nesta  rotina o ponto de entrada define quais as filias ser�o inseridas no c�lculo.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aRet -> A -> Retorna por meio de uma array quais as filias ir�o fazer parte do c�lculo de impostos na 
					rotina de contas a receber.
===============================================================================================================================
*/
User Function F040FRT() 

Local aFilial := {} 
Local nRegSM0 := SM0->(RECNO()) 
Local cEmpAtu := SM0->M0_CODIGO 
Local cCnpj   := Substr(SM0->M0_CGC,1,8) 

dbselectArea ("SM0") 
dbSeek(cEmpAtu) 

While !Eof() .and. SM0->M0_CODIGO == cEmpAtu 

	If Substr(SM0->M0_CGC,1,8) == cCnpj 

    	AADD(aFilial,alltrim(SM0->M0_CODFIL)) 

    EndIf

DBSkip() 

EndDo

SM0->(DBGoto(nRegSM0)) 

Return (aFilial)