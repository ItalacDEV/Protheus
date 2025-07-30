/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/05/2022 | Inclus�o de novas regras. Chamado 39942
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 05/07/2022 | Alterada condi��o de pagamento para filial 10, trasportador C. Chamado 40666
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/03/2023 | Inclu�da filial 94. Chamado 43372
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: A140ICOND
Autor-----------: Lucas Borges Ferreira
Data da Criacao-: 03/06/2020
===============================================================================================================================
Descri��o-------: Permite alterar e validar a condi��o de pagamento utilizada no monitor do totvs colabora��o
				 LOCALIZA��O: No monitor Totvs Colabora��o
===============================================================================================================================
Parametros--------: ParamIxb[01] -> C -> Fornecedor
                    ParamIxb[02] -> C -> Loja
                    ParamIxb[03] -> C -> Condi��o de Pagamento
===============================================================================================================================
Retorno---------: cCondPgto -> C -> Condi��o de Pagamento
===============================================================================================================================
*/
User Function A140ICOND

Local _cCondPgto    := PARAMIXB[3]

If AllTrim(SDS->DS_ESPECI) == 'CTE'
    If SubStr(PARAMIXB[1],1,1) =='G'
        If cFilAnt $ '10/11/1A/1B'
            _cCondPgto := '079'//16 m�s subsequente
        ElseIf cFilAnt $ '20/23/24/25'
            _cCondPgto := '078'//15 m�s subsequente
        ElseIf cFilAnt == '40'
            _cCondPgto := '083'//20 m�s subsequente
        Else 
            _cCondPgto := '088'//25 m�s subsequente
        EndIf
    ElseIf SubStr(PARAMIXB[1],1,1) $'T/C'
        If cFilAnt $ '10/11/1A/1B' .and. SubStr(PARAMIXB[1],1,1) $'T'
            _cCondPgto := '091'//28 m�s subsequente
        ElseIf cFilAnt $ '10/11/1A/1B' .and. SubStr(PARAMIXB[1],1,1) $'C'
            _cCondPgto := '073'//10 m�s subsequente
        ElseIf cFilAnt $ '20/23/24/25/93' .and. SubStr(PARAMIXB[1],1,1) $'C'
            _cCondPgto := '99H'//15 m�s subsequente
        Else
            If Day(SDS->DS_EMISSA) >= 1 .And. Day(SDS->DS_EMISSA) <= 15
                _cCondPgto := '071'//08 m�s subsequente
            Else
                _cCondPgto := '086'//23 m�s subsequente
            EndIf
        EndIf
    EndIf
EndIf

Return _cCondPgto
