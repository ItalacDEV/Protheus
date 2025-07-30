/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 07/05/2025 | Chamado 50535. PE Ajustar a conta banc�ria na Importa��o do Extrato Banc�rio
===============================================================================================================================
*/


#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
  
/*/{Protheus.doc} F474CTA
Ajustar informa��es banc�rias para a busca dos registros a conciliar
@type       Function
@author     TOTVS
@since      31/08/2023
@return     Nil
/*/

/*
===============================================================================================================================
Programa----------: F474CTA
Autor-------------: Antonio Neves
Data da Criacao---: 07/05/2025
Descri��o---------: PE Tratar os Dados Banc�rios na Importa��o do Extrato Banc�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/



User Function F474CTA()
    Local cBanco := paramixb[1]
    Local cAgencia := paramixb[2]
    Local cConta := STRTRAN(paramixb[3],' ','')
    Local aRet := {}

    aRet := {cBanco,cAgencia,cConta}
 
Return aRet
