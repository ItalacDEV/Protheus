/*
=====================================================================================================================================
         							ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	  |	Data	 |										Motivo														
-------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 03/12/21 | Criacao da opcao de Reenvio de WF. Chamado: 38508
=====================================================================================================================================
*/
#Include "RwMake.ch"
/*
===============================================================================================================================
Programa----------: MT105MNU
Autor-------------: Tiago Correa Castro
Data da Criacao---: 05/03/2009  
===============================================================================================================================
Descrição---------: Ponto de entrada com o objetivo de incluir novas opcoes nao rotina de Solicitacao ao Almoxarifado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRet: Opcoes de menu
===============================================================================================================================*/
User Function MT105MNU()
Local _aRet:={}
	
AADD(_aRet,{"Imp. Solic.",'U_REST001()',0,2})
AADD(_aRet,{"Reenvio WF" ,'U_REEVIOWF()',0,2})

Return(_aRet)                       
/*
===============================================================================================================================
Programa----------: REEVIOWF
Autor-------------: Alex Wallauer
Data da Criacao---: 03/12/2021
===============================================================================================================================
Descrição---------: Rotina responsável por atualizar a flag de reenvio do workflow
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function REEVIOWF()
Local aArea	:= SCP->(GetArea())
Local cFilSP:= SCP->CP_FILIAL
Local cNumSP:= SCP->CP_NUM

If SCP->CP_STATSA == 'B'

   SCP->(DBSETORDER(1))
   SCP->(DBSEEK(cFilSP+cNumSP))        
   DO WHILE (!SCP->(eof()) .and. ( cFilSP+cNumSP == SCP->CP_FILIAL+SCP->CP_NUM )) 
   	  SCP->(RecLock("SCP",.F.))
   	  SCP->CP_I_SITWF:= "1"//para enviar
        SCP->CP_I_HTMWF:= ""
   	  SCP->(MSUNLOCK())    		
      SCP->(DBSKIP())
   ENDDO
   U_ITMSG("Solicitação ao armazem preparada para reenvio.",'REENVO DE SOLICITACAO',,2) // OK
Else
   U_ITMSG("Esta solicitação  ao armazem não pode ser reenviada, pois esta encontra-se Liberada ou Rejeitada.",'Atenção!',,3) // ALERT
EndIf

RestArea(aArea)
Return
