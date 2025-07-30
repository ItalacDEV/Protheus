/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: MBRWBTN
Autor-------------: Talita Teixeira
Data da Criacao---: 17/02/2014
===============================================================================================================================
Descri��o---------: Ponto de Entrada generico utilizado para validar as execu��o das rotinas de libera��o de cr�dito
					Valida a permissao para liberacao automatica das rotinas de libera��o de cr�dito: MA450CLAUT, A450LIBAUT.
					Foi bloqueado tamb�m o uso da rotina de libera��o credito/estoque conforme solicitado pelo Tiago
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. = Permite liberacao manual do Estoque
					.F. = Nao Permite liberacao manual do Estoque
===============================================================================================================================
*/
User Function MBRWBTN()

Local cFunction := ParamIxb[4]
Local lRet 		:= .T.  
Local cUsuario	:= U_UCFG001(1)
Local aUsuAut	:= {}
Local cTemp		:= ""   
Local cValid 	:= .T.

If cFunction == "MA450CLAUT" .Or. cFunction == "A450LIBAUT" 

	DbSelectArea("ZZL")  
	DbSetOrder(1)
	DbSeek(xFilial("ZZL")+cUsuario)
	
	If ZZL->ZZL_LIBCRE == 'S'
		aAdd(aUsuAut, cTemp)
		cTemp := ""
		lRet := .T.	
	Else   
	
	cValid:= .F.
	lRet := .F.		
	
	EndIf
	
	If cValid
	
	Else
	xmaghelpfis("INFORMA��O","Usu�rio sem acesso para libera��o de pedido por cr�dito ","Favor contactar o departamento de inform�tica informando do erro ocorrido.")
	EndIf
	
	ZZL->(DbCloseArea())
	
EndIf

If cFunction == "A456LIBAUT" .Or.  cFunction == "A456LIBMAN"
xmaghelpfis("INFORMA��O","Rotina bloqueada pelo administrador do sistema ","Favor utilizar as rotinas de Libera��o de Estoque e/ou Libera��o de Cr�dito para a libera��o do pedido.")
lRet:= .F.	  

EndIf

Return lRet