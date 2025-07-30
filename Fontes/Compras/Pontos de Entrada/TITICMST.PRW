/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: TITICMST
Autor-----------: Julio de Paula PAz
Data da Criacao-: 19/09/2023
===============================================================================================================================
Descrição-------: Ponto de entrada que permite alterar a data de vencimento do título e da guia de recolhimento 
                  do ICMS / ICMS ST / DIFAL.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function TITICMST()
Local _cOrigem := PARAMIXB[1] 
Local cTipoImp := PARAMIXB[2] 
//Local lDifal := PARAMIXB[3] 
Local _aRet := {SE2->E2_NUM,SE2->E2_VENCTO} 
Local _cTesIcmst := U_ITGETMV( "IT_TESCCEE",'088')
Local _cNatIcmst := U_ITGETMV( "IT_NATCCEE",'212054')

Begin Sequence

   //========================================================================================
   // Permite alterar a data de vencimento de títulos SE2 e natureza de operação, 
   // para nota fiscal de entrada de liquidação de diferenças no mercado de curto prazo,
   // de CCEE.
   //========================================================================================
   If _cOrigem == "MATA103" .AND. SD1->D1_TES == U_ITKEY(_cTesIcmst,"D1_TES") .And. cTipoImp == "1" .AND. SF1->F1_FORMUL=="S" 
      SE2->(RecLock("SE2",.F.))
      SE2->E2_VENCTO  := DataValida(firstdate(monthsum(ddatabase,1))+9,.T.) 
      SE2->E2_VENCREA := DataValida(firstdate(monthsum(ddatabase,1))+9,.T.) 
      SE2->E2_NATUREZ := _cNatIcmst 
      SE2->(MsUnLock())
   EndIf 

End Sequence 

Return _aRet 
