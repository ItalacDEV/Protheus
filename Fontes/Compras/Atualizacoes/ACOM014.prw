/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 17/07/17   | Virada de vers�o da P11 para a vers�o P12. Ajustes no fonte para a vers�o P12. Chamado 20777.                             
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 25/09/19   | Ajustes para o novo nivel 5 dos produtos. Chamado 30673
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"


/*
===============================================================================================================================
Programa----------: ACOM014
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 26/08/2008
===============================================================================================================================
Descri��o---------: Retorno de Inicializador Padrao e Inicializador do Browse
                    Rotina chamada na validacao de Inicializador Padrao(X3_RELACAO) e no Inicializador de Browse (X3_INIBRW)  
                    dos campos: SB1->B1_I_NOMGR								                                               
                                SB1->B1_I_DESN2						                                   						
                                SB1->B1_I_DESN3						                                   						
                                SB1->B1_I_DESN4						                                   						
                                SBZ->BZ_COD							                                   						
                                SB1->B1_I_DESTP

===============================================================================================================================
Parametros--------: 1=Retorna informacao para preenchimento do Inicializador Padrao(X3_RELACAO) do campo SB1->B1_I_NOMGR        
                    2=Retorna informacao para preenchimento do Inicializador de Browse (X3_INIBRW) do campo SB1->B1_I_NOMGR   	
                    3=Retorna informacao para preenchimento do Inicializador Padrao(X3_RELACAO) do campo SB1->B1_I_DESN2        
                    4=Retorna informacao para preenchimento do Inicializador de Browse (X3_INIBRW) do campo SB1->B1_I_DESN2   	
                    5=Retorna informacao para preenchimento do Inicializador Padrao(X3_RELACAO) do campo SB1->B1_I_DESN3        
                    6=Retorna informacao para preenchimento do Inicializador de Browse (X3_INIBRW) do campo SB1->B1_I_DESN3   	
                    7=Retorna informacao para preenchimento do Inicializador Padrao(X3_RELACAO) do campo SB1->B1_I_DESN4        
                    8=Retorna informacao para preenchimento do Inicializador de Browse (X3_INIBRW) do campo SB1->B1_I_DESN4   	
                    9= N�o utilizado.	        
                    10=N�o utilizado.		   
                    11=Retorna informacao para preenchimento do Inicializador Padrao(X3_RELACAO) do campo SB1->B1_I_DESTP        
                    12=Retorna informacao para preenchimento do Inicializador de Browse (X3_INIBRW) do campo SB1->B1_I_DESTP	   

===============================================================================================================================
Retorno-----------: Retorna o nome para ser preenchido no Inicializador Padrao(X3_RELACAO) e Inicializador de Browse 
                    (X3_INIBRW).
===============================================================================================================================
*/
User Function ACOM014(_nOpc)

	Local aArea 	:= GetArea()
	Local cRet		:=	""     
	
	If _nOpc == 1 .and. !inclui 
		cRet	:=	AllTrim(Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))
	ElseIf _nOpc == 2
		cRet	:=	AllTrim(Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))

	ElseIf _nOpc == 3 .and. !inclui
		cRet	:=	AllTrim(Posicione("ZA1",1,xFilial("ZA1")+SB1->B1_GRUPO+SB1->B1_I_NIV2,"ZA1_DESCRI"))
	ElseIf _nOpc == 4
		cRet	:=	AllTrim(Posicione("ZA1",1,xFilial("ZA1")+SB1->B1_GRUPO+SB1->B1_I_NIV2,"ZA1_DESCRI"))

	ElseIf _nOpc == 5 .and. !inclui
		cRet	:=	AllTrim(Posicione("ZA2",1,xFilial("ZA2")+SB1->B1_I_NIV3,"ZA2_DESCRI"))
	ElseIf _nOpc == 6
		cRet	:=	AllTrim(Posicione("ZA2",1,xFilial("ZA2")+SB1->B1_I_NIV3,"ZA2_DESCRI"))

	ElseIf _nOpc == 7 .and. !inclui
		cRet	:=	AllTrim(Posicione("ZA3",1,xFilial("ZA3")+SB1->B1_I_NIV4,"ZA3_DESCRI"))
	ElseIf _nOpc == 8
		cRet	:=	AllTrim(Posicione("ZA3",1,xFilial("ZA3")+SB1->B1_I_NIV4,"ZA3_DESCRI"))

	ElseIf _nOpc == 11 .and. !inclui
		cRet	:=	AllTrim(Posicione("SX5",1,xFilial("SX5")+"02"+AllTrim(SB1->B1_TIPO),"X5_DESCRI"))
	ElseIf _nOpc == 12
		cRet	:=	AllTrim(Posicione("SX5",1,xFilial("SX5")+"02"+AllTrim(SB1->B1_TIPO),"X5_DESCRI"))

	ElseIf _nOpc == 13 .and. !inclui
		cRet	:=	AllTrim(Posicione("ZA0",1,xFilial("ZA0")+SB1->B1_I_NIV5,"ZA0_DESCRI"))
	ElseIf _nOpc == 14
		cRet	:=	AllTrim(Posicione("ZA0",1,xFilial("ZA0")+SB1->B1_I_NIV5,"ZA0_DESCRI"))
	Endif
	
   //===============================================================
   // Grava log da rotina de Inicializador Padr�o e Inicilizador de 
   // Browser.
   //=============================================================== 
   U_ITLOGACS('ACOM014')
	
   RestArea(aArea)

Return (cRet)
