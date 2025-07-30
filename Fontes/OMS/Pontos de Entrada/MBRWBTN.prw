/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
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
Descrição---------: Ponto de Entrada generico utilizado para validar as execução das rotinas de liberação de crédito
					Valida a permissao para liberacao automatica das rotinas de liberação de crédito: MA450CLAUT, A450LIBAUT.
					Foi bloqueado também o uso da rotina de liberação credito/estoque conforme solicitado pelo Tiago
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
	xmaghelpfis("INFORMAÇÃO","Usuário sem acesso para liberação de pedido por crédito ","Favor contactar o departamento de informática informando do erro ocorrido.")
	EndIf
	
	ZZL->(DbCloseArea())
	
EndIf

If cFunction == "A456LIBAUT" .Or.  cFunction == "A456LIBMAN"
xmaghelpfis("INFORMAÇÃO","Rotina bloqueada pelo administrador do sistema ","Favor utilizar as rotinas de Liberação de Estoque e/ou Liberação de Crédito para a liberação do pedido.")
lRet:= .F.	  

EndIf

Return lRet