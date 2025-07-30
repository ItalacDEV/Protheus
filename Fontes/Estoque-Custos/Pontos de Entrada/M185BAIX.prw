/*
-------------------------------------------------------------------------------------------------------------------------------
               						ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                   						   
-------------------------------------------------------------------------------------------------------------------------------
 Talita       | 09/05/2013 | Incluida validação para que o conteudo do campo CP_OBS seja gravado no campo D3_I_OBS Chamado:3168                    				   ³                                  ³ 			º±±
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 10/01/2018 | Nova Validação referente ao paramenrto IT_ARMCPR - Chamado 23039
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 04/09/2018 | Retirada a Validação referente ao paramenrto IT_ARMCPR - Chamado 26146
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#include "protheus.ch"
#include "report.ch"
#include "topconn.ch"

/*
===============================================================================================================================
Programa--------: M185BAIX
Autor-----------: Talita Teixeira 
Data da Criacao-: 11/03/2013 
===============================================================================================================================
Descrição-------: Ponto de Entrada que valida a baixas Pre-requisicoes gerando as requisicoes
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Lógico
===============================================================================================================================
*/
User Function M185BAIX() 
Local lRet	:= .T.
//Local cteste:= PARAMIXB
//Local cObs	:= SD3->D3_I_OBS
//Local _cArmazens:= U_ITGETMV( 'IT_ARMCPR' , "02,04" ) 
/*  ESSA VALIDAÇão JÁ FEITA NO MT241TOK.PRW corretamente
If SD3->D3_TM >= "500" .AND. (SCP->CP_LOCAL $ _cArmazens .AND. !U_ITVACESS( 'ZZL' , 3 , 'ZZL_PERTRA' , 'S' ))//ZZL->ZZL_PERTRA <> "S"
   U_ITMSG("Para o "+SCP->CP_LOCAL+" não é permitido a movimentação interna, somente tranferencia entre armazens. Armazens não permitidos: '"+AllTrim(_cArmazens)+"'.",;
           "Permissões de Acesso Italac",;
           "Realize a transferencia entre armazens ou entre em contato com o departamento de Custo.",1)
    RETURN .F.
EndIf
*/
Public cNumSA:= SCP->CP_NUM
  
If SD3->D3_COD = SCP->CP_PRODUTO .AND. SD3->D3_I_NUMCP = ' '
	
	SD3->(Reclock("SD3",.F.))
	SD3->D3_I_NUMCP := cNumSA
	SD3->(MsUnlock())
	
EndIf

SCP->(MsUnlock())

Return lRet