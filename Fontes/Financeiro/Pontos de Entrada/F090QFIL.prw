/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: F090QFIL
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 21/12/2017
===============================================================================================================================
Descri��o---------: Ponto de entrada para retornar a cl�usula Where para a query que filtra os registros da SE2 para a sele��o 
					na rotina FINA090 em substitui��o do ponto de entrada F090AFIL.
===============================================================================================================================
Parametros--------: PARAMIXB[1] -> cl�usula Where atual da rotina
===============================================================================================================================
Retorno-----------: cFiltro -> Caracter -> Sintaxe da cl�usula WHERE (SQL) que ser� utilizado para filtrar os registros para 
					sele��o para a baixa autom�tica -> Obrigat�rio
===============================================================================================================================
*/
User Function F090QFIL()

Local _cFiltro   := PARAMIXB[1]     
Local _cPerg	:= 'FIN090ITA'
Local _aParam	:= {}

//Salva par�metros utilizados na rotina padr�o
aAdd( _aParam , MV_PAR01 )
aAdd( _aParam , MV_PAR02 )
aAdd( _aParam , MV_PAR03 )
aAdd( _aParam , MV_PAR04 )
aAdd( _aParam , MV_PAR05 )
aAdd( _aParam , MV_PAR06 )

If Pergunte( _cPerg )

	_cFiltro += " AND E2_FORNECE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "'" 
	_cFiltro += " AND E2_LOJA BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "'"
	_cFiltro += " AND E2_NATUREZ BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"

EndIf

//Restaura par�metros utilizados na rotina padr�o
MV_PAR01 := _aParam[1]
MV_PAR02 := _aParam[2]
MV_PAR03 := _aParam[3]
MV_PAR04 := _aParam[4]
MV_PAR05 := _aParam[5]
MV_PAR06 := _aParam[6]

Return _cFiltro
