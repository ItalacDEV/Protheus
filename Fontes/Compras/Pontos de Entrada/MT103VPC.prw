/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |12/04/2017| Chamado 18128. Altera��o da condi��o do filtro
Lucas Borges  |19/06/2025| Chamado 50617. Revis�es diversas visando padronizar os fontes
===============================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MT103VPC
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 02/07/2015
Descri��o---------: Ponto de entrada na execu��o do filtro na importa��o do pedido de compras
Parametros--------: Nenhum
Retorno-----------: L�gico - .T. se o registro for v�lido, .F. para descartar o registro
===============================================================================================================================
*/
User Function MT103VPC

Local _aArea	:= FWGetArea() As Array
Local _lRet		:= .T. As Logical
Local _nDiasPC	:= SuperGetMV("IT_DIASPC",.F.,30) As Numeric
Local _cFilTpc	:= SuperGetMV("IT_FILTPC",.F.,"01") As Character

If cFilAnt $ _cFilTpc
   If Empty(SC7->C7_I_DTFAT)
	  If SC7->C7_EMISSAO < (Date() - _nDiasPC)
		_lRet := .F.
	  EndIf
   Else
	  If SC7->C7_I_DTFAT < (Date() - _nDiasPC)
		_lRet := .F.
	  EndIf
   EndIf
EndIf

FWRestArea(_aArea)

Return(_lRet)
