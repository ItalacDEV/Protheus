/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista      - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o                                                                                 
============================================================================================================================================================== 
Antonio Ramos  - Julio Paz    - 07/08/25 - 12/08/25 -  51685  - Cria��o de Nova valida��o na digita��o da data de baixa de T�tulos de Contas a Pagar.        
============================================================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch" 
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH" 

/*
===============================================================================================================================
Fun��o-------------: FADTMOV
Autor--------------: Julio de Paula Paz
Data da Criacao----: 29/08/2024 
===============================================================================================================================
Descri��o----------: Ponto de entrada na valida��o da Data da Baixa da tela Baixa Autom�tica de Contas a Pagar.
===============================================================================================================================
Parametros---------: {dDatabaixa} = data da baixa informada na tela.
===============================================================================================================================
Retorno------------: _lRet = .T. = Data OK.
                             .F. = Data inv�lida.
===============================================================================================================================
*/  
User Function FADTMOV()
Local _lRet := .T.
Local _aUsuario 
Local _aParam := PARAMIXB
Local _dData 
Local _nDiasAvan
Local _cCampo	:= ReadVar()

Begin Sequence 
   
   If FWIsInCallStack("FA090AUT") .And. _cCampo == "DBAIXA"
      PswOrder(1)
      PswSeek(__cUserId,.T.)
      _aUsuario := PswRet()
   
      _nDiasAvan := _aUsuario[1,23,3] // Numero de dias que o usu�rio pode avan�ar a data base do Protheus, ao fazer login no Protheus.

      _dData := _aParam[1] // Data da baixa informado na tela pelo usu�rio.

      If Dtos(_dData) > Dtos(Date() + _nDiasAvan)
         U_ItMsg("Usu�rio sem permiss�o de informar uma data de baixa superior a: " + Dtoc(Date() + _nDiasAvan) + ". ","Aten��o",,1)
         _lRet := .F.
      EndIf 
      
   EndIf

End Sequence 

Return _lRet 
