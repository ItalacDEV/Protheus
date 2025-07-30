/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 07/05/2018 | Padroniza��o dos cabe�alhos dos fontes e fun��es do m�dulo financeiro. Chamado 24726.
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 17/11/2022 | Validar campo data de prorroga��o e n�o permitir data inferior a data atual. Chamado 41853.
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
Programa----------: AFIN003
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 28/08/2008  
===============================================================================================================================
Descri��o---------: Valida��o dos campos E1_PREFICO e E2_PREFIXO para verificar se estes tem amarra��o na ZAB.
===============================================================================================================================
Parametros--------: _nOpc = 1 - Pagar  /	2- Receber	
                    _cPref1	= Prefixo			                                        						
===============================================================================================================================
Retorno-----------: lRet = .T. = Se possui amarracao na ZAB 
                         = .F. = Se n�o possuir amarra��o na ZBA
===============================================================================================================================
*/
User Function AFIN003(_nOpc, _cPref)

	Local aArea 	:= GetArea()
	Local lRet		:= 	.F.
	
	dbSelectArea("ZAB")
	dbSetOrder(1)
	if ( dbSeek(xFilial("ZAB") + _cPref ) )

		if ( ZAB->ZAB_TIPO == "3" )

			lRet := .T.
	
		elseif ( _nOpc == 1 )
		
			dbSelectArea("ZAB")
			dbSetOrder(2)
			if ( dbSeek(xFilial("ZAB") + "1" + _cPref ) )
				lRet := .T.
			endif
		
		else
		
			dbSelectArea("ZAB")
			dbSetOrder(2)
			if ( dbSeek(xFilial("ZAB") + "2" + _cPref ) )
				lRet := .T.
			endif
		
		endif
		
	else
		lRet :=	.F. 
		xmaghelpfis("Consulta Prefixo",;
					"Nao existe esse Prefixo na tabela de Prefixos",;
					"Cadastrar primeiramente o Prefixo na tabela de Prefixos")
	endif
	
	RestArea(aArea)
Return lRet 

/*
===============================================================================================================================
Programa----------: AFIN003V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 16/11/2022
===============================================================================================================================
Descri��o---------: Valida��o a digita��o dos campos informados na vari�vel _cCampo, na inclus�o/altera��o de titulos de contas 
                    a receber.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a valida��o.	                                        						
===============================================================================================================================
Retorno-----------: lRet = .T. = Valida��o Ok. 
                         = .F. = Inconsistencia na valida��o.
===============================================================================================================================
*/
User Function AFIN003V(_cCampo)
Local _lRet := .T.

Begin Sequence
   
   If _cCampo == "E1_I_DTPRO"
      If ! Empty(M->E1_I_DTPRO) .And. Dtos(M->E1_I_DTPRO) < Dtos(Date()) 
         _lRet := .F.
		 U_ItMsg( 'A data de prorroga��o do t�tulo n�o pode ser menor que a data atual do sistema.' , 'Aten��o!' , , 1)
      EndIf 
   EndIf 

End Sequence 

Return _lRet 
