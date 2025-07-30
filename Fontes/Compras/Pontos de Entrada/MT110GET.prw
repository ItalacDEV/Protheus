/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 17/07/17   | Virada de versão da P11 para a versão P12. Ajustes no fonte para a versão P12. Chamado 20777.                             
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 04/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MT110GET
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/07/2017
===============================================================================================================================
Descrição---------: Ponto de entrada de ajuste de coordenadas da tela de Solicitação de Compras.
===============================================================================================================================
Parametros--------: PARAMIXB[1] - Array das coordenadas do objeto da dialog da Solicitação de Compras
                    PARAMIXB[2] - Opção selecionada na Solicitação de Compras (inclusão, alteração, exclusão, etc.)
===============================================================================================================================
Retorno-----------: aPosObjPE = Objeto das coordenadas da dialog da Solicitação de Compras
===============================================================================================================================
*/
User Function MT110GET()

Local aPosObjPE	:= PARAMIXB[1]
Local _cVersaoProtheus := AllTrim(OAPP:CVERSION)

Begin Sequence 
   //==============================================================================
   // Define tratamentos de posição de tela para as versões P11 e P12 do Protheus.
   //==============================================================================
   If _cVersaoProtheus <> "11" // Se for a versão P12 do Protheus reajusta as posições da tela.
      aPosObjPE[2,1] := aPosObjPE[2,1] + 29
      aPosObjPE[1,3] := aPosObjPE[1,3] + 27 //+ 25
   EndIf
   
End Sequence

Return aPosObjPE