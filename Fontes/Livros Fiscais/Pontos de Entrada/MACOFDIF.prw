/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  |14/05/2015| Chamado 10102. Ajuste na valida��o da esp�cie e tipo quando a chamada for feita via MATA103.
Lucas Borges  |09/11/2023| Chamado 45494. Retirada valida��es diferenciando as fun��es. 
Lucas Borges  |15/06/2025| Chamado 50998. Revis�es diversas visando padronizar os fontes
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
/*
===============================================================================================================================
Programa----------: MACOFDIF
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 04/09/2013
Descri��o---------: Ponto de entrada para tratamento do COFINS com Al�quota Diferenciada.
Parametros--------: PARAMIXB[1] -> C -> Item atual do processo
                    PARAMIXB[2] -> N -> Al�quota do PIS de Apura��o
Retorno-----------: _cUsaAlq, _nAliq -> A -> Utiliza (S/N), o Valor do PIS Retornado pela Fun��o. Al�quota do COFINS de Apura��o.
===============================================================================================================================
*/
User Function MACOFDIF

Local _nAliq  := PARAMIXB[2] As Numeric
Local _cUsaAlq:= "N" As Character

If FWIsInCallStack("MATA116")
       _cUsaAlq := 'S'
ElseIf FWIsInCallStack("MATA103")
       If AllTrim(cEspecie) == 'CTE' .And. cTipo == 'C'
              _cUsaAlq := 'S'
       EndIf
ElseIf FWIsInCallStack("COMXCOL")
       If Type("cEspecie") == "C" .And. AllTrim(cEspecie) == 'CTE' .And. cTipo == 'C'
              _cUsaAlq := 'S'
       EndIf
EndIf
If _cUsaAlq == 'S'
       _nAliq := SuperGetMv("MV_TXCOF")
EndIf

Return({_cUsaAlq,_nAliq})
