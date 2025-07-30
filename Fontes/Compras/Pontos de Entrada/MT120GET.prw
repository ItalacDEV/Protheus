/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data  |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 17/07/17 | Virada de vers�o da P11 para a vers�o P12. Ajustes no fonte para a vers�o P12. Chamado 20777.                             
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 31/10/18 | Altera��es  para aceitar moeda diferente de Real. Chamado 26721
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
Programa----------: MT120GET
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/07/2017
===============================================================================================================================
Descri��o---------: Ponto de entrada de ajuste de coordenadas da tela de Pedido de Compras.
					Localiza��o: Function A120PEDIDO - Fun��o do Pedido de Compras responsavel pela inclus�o, altera��o, 
					exclus�o e c�pia dos PCs.
					Em que Ponto: Se encontra dentro da rotina que monta a dialog do pedido de compras antes  da montagem dos 
					gets da tela. � utilizado para alterar as coordenadas do array aPosObj para redimensionar a dialog.
===============================================================================================================================
Parametros--------: PARAMIXB[1] - Array das coordenadas do objeto da dialog do Pedido de Compras
                    PARAMIXB[2] - Op��o selecionada no Pedido de Compras (inclus�o, altera��o, exclus�o, etc.)
===============================================================================================================================
Retorno-----------: aPosObjPE = Objeto das coordenadas da dialog do Pedido de Compras
===============================================================================================================================
*/
User Function MT120GET()

Local aPosObjPE	:= PARAMIXB[1]
Local _cVersaoProtheus := AllTrim(OAPP:CVERSION) , C  ,_aCposRela  , L

Begin Sequence 
   //==============================================================================
   // Define tratamentos de posi��o de tela para as vers�es P11 e P12 do Protheus.
   //==============================================================================
   If _cVersaoProtheus <> "11" // Se for a vers�o P12 do Protheus reajusta as posi��es da tela.
      aPosObjPE[2,1] := aPosObjPE[2,1] + 25
      aPosObjPE[1,3] := aPosObjPE[1,3] + 21
   EndIf

   If nMoedaPed = 1 

      _aCposRela:={"C7_I_PRURS","C7_I_PRTRS"}
      
      For C := 1 To Len(_aCposRela)
	      nPos:=Ascan(aHeader,{|x| ALLTRIM(x[2]) == _aCposRela[C] })
	      If nPos > 0

	   	     aDel(aHeader,nPos)
		     aSize(aHeader,Len(aHeader)-1)
             For L := 1 To Len(aCols)
	   	         aDel(aCols[L],nPos)
		         aSize(aCols[L],Len(aCols[L])-1)
		     Next L

	       EndIf
      Next C
      
	EndIf

End Sequence

Return aPosObjPE