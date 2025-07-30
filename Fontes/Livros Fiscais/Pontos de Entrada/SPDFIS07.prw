/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Darcio Sporl  | 17/03/16   | Ponto de entrada criado para retornar conta contábil no registro H010 do SPED Fiscal. Chamado 14763
-------------------------------------------------------------------------------------------------------------------------------
Darcio Sporl  | 31/01/17   | Foi reajustado o tratamento de retorno da conta contábil. Chamado 4058
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346  
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 17/12/2019 | Alterações na forma que a rotina de sped fiscal obtem o numero contábil. Chamado 31211.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: SPDFIS07
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 17/03/2016
===============================================================================================================================
Descrição---------: Ponto de entrada que permite a customização do Código da Conta Contábil no registro H010 do SPED Fiscal.
===============================================================================================================================
Parametros--------: PARAMIXB[1] - Codigo Produto
------------------: PARAMIXB[2] - Tipo
------------------: PARAMIXB[3] - Codigo Armazem
===============================================================================================================================
Retorno-----------: cRet - Retorna o número da conta contábil
===============================================================================================================================
*/
User Function SPDFIS07()
Local _aArea	:= GetArea()
Local _cCodProd	:= PARAMIXB[1] //Codigo do Produto
Local _cRet		:= ""

Begin Sequence
   ZGH->(DbSetOrder(6)) // ZGH_FILIAL+ZGH_TIPOPD
   SB1->(DbSetOrder(1))
   
   If SB1->(DbSeek(xFilial("SB1")+_cCodProd)) 
      If ZGH->(DbSeek(xFilial("ZGH")+SB1->B1_TIPO)) 
         _cRet := ZGH->ZGH_CONTA 
      EndIf
   EndIf
   
End Sequence

RestArea(_aArea)

Return _cRet