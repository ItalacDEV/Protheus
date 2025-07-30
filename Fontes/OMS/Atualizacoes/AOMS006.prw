/*
===============================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                          
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 27/07/2018 | Inclus�o de c�lculo por supervisor - Chamado 25555
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 14/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 21/01/2021 | Inclus�o das comiss�es do novo Gerente Nacional. Chamado 35183.  
------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 20/12/2021 | Incluir na lista de sele��o de vendedores os campos A1_I_VEND3 e A1_I_VEND4. Chamado 38654.  
------------------------------------------------------------------------------------------------------------------------------- 
  Jerry           | 29/04/2022 | Ajuste na Efetiva��o Automatica Pedido Portal retirando paradas em tela. Chamado 38883
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"

/*
===============================================================================================================================
Programa--------: AOMS006
Autor-----------: Frederico O. C. Jr 
Data da Criacao-: 19/07/2008
===============================================================================================================================
Descri��o-------: Funcao chamada no GATILHO -> C5_CLIENTE - 002 - avalia se cliente possui mais de um vendedor, onde caso 
                  possua, monta uma tela para usuario selecionar qual o vendedor responsavel por aquela venda
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Codigo do Vendedor responsavel pela venda
===============================================================================================================================*/
User Function AOMS006()
	
Local aArea 	:= GetArea()
Local oDlg
Local aOpcoes	:= {}
Local cRet		:= ""
Local _lAoms112 := .F.

Private nOpcoes	:= 1

//Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetiva��ao Automatica)
If IsInCallStack("U_AOMS112") .or. IsInCallStack("U_MOMS050")
	_lAoms112 := .T.
Endif 
 
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
	
SA3->(dbSetOrder(1))
SA3->(dbSeek(xFilial("SA3")+SA1->A1_VEND))

aAdd(aOpcoes, SA3->A3_COD + " - " + AllTrim(SA3->A3_NREDUZ))

if (!Empty(AllTrim(SA1->A1_I_VEND2))) .Or. (!Empty(AllTrim(SA1->A1_I_VEND3))) .Or. (!Empty(AllTrim(SA1->A1_I_VEND4)))
	
	SA3->(dbSetOrder(1))
	SA3->(dbSeek(xFilial("SA3")+SA1->A1_I_VEND2))
	
	aAdd(aOpcoes, SA3->A3_COD + " - " + AllTrim(SA3->A3_NREDUZ))
	
    If !Empty(AllTrim(SA1->A1_I_VEND3))
       SA3->(dbSetOrder(1))
	   SA3->(dbSeek(xFilial("SA3")+SA1->A1_I_VEND3))
	
	   aAdd(aOpcoes, SA3->A3_COD + " - " + AllTrim(SA3->A3_NREDUZ))
	EndIf

	If !Empty(AllTrim(SA1->A1_I_VEND4))
       SA3->(dbSetOrder(1))
	   SA3->(dbSeek(xFilial("SA3")+SA1->A1_I_VEND4))
	
	   aAdd(aOpcoes, SA3->A3_COD + " - " + AllTrim(SA3->A3_NREDUZ))
    EndIf 
	If !_lAoms112
		@ 100,100 	To 270,450 Dialog oDlg Title OemToAnsi("Vendedores Cadastrados para este Cliente")
		@ 10,15 	To 65,162 Title OemToAnsi("Selecione um vendedor:")
		@ 20,25		Radio aOpcoes Var nOpcoes
		@ 70,80	BMPBUTTON TYPE 01 ACTION Close(oDlg)
		Activate Dialog oDlg  CENTERED
	endif 
	 
endif

If nOpcoes == 1
   cRet := SubStr(aOpcoes[1],1,6)
ElseIf nOpcoes == 2
   cRet := SubStr(aOpcoes[2],1,6)
ElseIf nOpcoes == 3
   cRet := SubStr(aOpcoes[3],1,6)
else
   cRet := SubStr(aOpcoes[4],1,6)
endif

SA3->(dbSetOrder(1))
SA3->(dbSeek(xFilial("SA3")+cRet))
M->C5_VEND2	:=	SA3->A3_SUPER
M->C5_VEND3	:=	SA3->A3_GEREN
M->C5_VEND4	:=	SA3->A3_I_SUPE
M->C5_VEND5	:=	SA3->A3_I_GERNC 
M->C5_I_V1NOM := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_NOME")    
M->C5_I_V2NOM := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND2,"A3_NOME")
M->C5_I_V3NOM := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND3,"A3_NOME")    
M->C5_I_V4NOM := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND4,"A3_NOME")    
M->C5_I_V5NOM := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND5,"A3_NOME")                                  

RestArea(aArea)

return cRet 
