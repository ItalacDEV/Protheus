/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 17/07/17   | Virada de vers�o da P11 para a vers�o P12. Ajustes no fonte para a vers�o P12. Chamado 20777.                             
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 04/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
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
Descri��o---------: Ponto de entrada de ajuste de coordenadas da tela de Solicita��o de Compras.
===============================================================================================================================
Parametros--------: PARAMIXB[1] - Array das coordenadas do objeto da dialog da Solicita��o de Compras
                    PARAMIXB[2] - Op��o selecionada na Solicita��o de Compras (inclus�o, altera��o, exclus�o, etc.)
===============================================================================================================================
Retorno-----------: aPosObjPE = Objeto das coordenadas da dialog da Solicita��o de Compras
===============================================================================================================================
*/
User Function MT110GET()

Local aPosObjPE	:= PARAMIXB[1]
Local _cVersaoProtheus := AllTrim(OAPP:CVERSION)

Begin Sequence 
   //==============================================================================
   // Define tratamentos de posi��o de tela para as vers�es P11 e P12 do Protheus.
   //==============================================================================
   If _cVersaoProtheus <> "11" // Se for a vers�o P12 do Protheus reajusta as posi��es da tela.
      aPosObjPE[2,1] := aPosObjPE[2,1] + 29
      aPosObjPE[1,3] := aPosObjPE[1,3] + 27 //+ 25
   EndIf
   
End Sequence

Return aPosObjPE