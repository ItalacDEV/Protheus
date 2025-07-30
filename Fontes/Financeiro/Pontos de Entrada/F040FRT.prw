/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 09/05/2018 | Padronização dos cabeçalhos dos fontes e funções do módulo financeiro. Chamado 24726.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
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
Descrição---------: Ponto de Entrada para geração da retenção de PCC na emissão do Contas a Receber. 
					O ponto de entrada F040FRT possibilita a manipulação de filiais no cálculo de impostos na rotina de Contas 
					a Receber. Nesta  rotina o ponto de entrada define quais as filias serão inseridas no cálculo.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aRet -> A -> Retorna por meio de uma array quais as filias irão fazer parte do cálculo de impostos na 
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