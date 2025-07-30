/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
/*
===============================================================================================================================
Programa----------: MACALCICMS
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 15/06/2025
Descri��o---------: Ponto de entrada na MATXFIS reprocessamento executado ap�s o processamento do calculo da Base do ICMS e 
                    ap�s o calculo do Valor do ICMS. Chamado 50998
Parametros--------: ParamIXB[1]	-C-	Tipo de opera��o da Nota Fiscal
                    ParamIXB[2]	-N-	Numero do item processado
                    ParamIXB[3]	-N-	Base do ICMS
                    ParamIXB[4]	-N-	Al�quota do ICMS 
                    ParamIXB[5]	-N-	Valor do ICMS calculado
Retorno-----------: aRet -A- Retorna um array com os dados Base, Al�quota, Valor
===============================================================================================================================
*/  
User Function MACALCICMS
 
Local _nBsICM   := ParamIXB[3] As Numeric
Local _nAliqICM := ParamIXB[4] As Numeric
Local _nVlrICM  := ParamIXB[5] As Numeric
Local _aRet     := {}          As Array

_aRet := {_nBsICM,_nAliqICM,_nVlrICM}

If FWIsInCallStack("MATA120")//Pedido de Compras
    If SA2->A2_SIMPNAC == '1'
        _aRet := {0,0,0}
    EndIf
EndIf
 
Return _aRet
