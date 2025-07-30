/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
                     
/*
===============================================================================================================================
Programa----------: MATA094
Autor-------------: Alex Wallauer
Data da Criacao---: 15/01/2019
===============================================================================================================================
Descrição---------: PE do MVC da Aprovação de Documentos Function MATA094() 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. ou .F. 
===============================================================================================================================
*/ 
USER FUNCTION MATA094()

Local _aParam:= PARAMIXB

If _aParam <> NIL
	
	_oObj		:= _aParam[01]
	_cIdPonto	:= _aParam[02]
//	cIdModel	:= _aParam[3]
	nOper		:= _oObj:GetOperation()
	
	IF _cIdPonto = "FORMPOS" .AND. nOper = 4
		
//		SAK->(dbSetOrder(1))
//		SAK->(MsSeek(xFilial("SAK")+SCR->CR_APROV))
//		_nLimGrupo:=SAK->AK_LIMMAX
		
		SAL->(dbSetOrder(3))
		SAL->(MsSeek( xFilial("SAL")+SCR->CR_GRUPO+SCR->CR_APROV ))
		
		DHL->(dbSetOrder(1))
		DHL->(MsSeek(xFilial("DHL")+SAL->AL_PERFIL))//Perfil
		_nLimPerfil:=DHL->DHL_LIMMAX
		
		_cAlias:=GetNextAlias()
		BeginSQL Alias _cAlias
			SELECT SUM(SC7.C7_TOTAL) C7TOTAL
			FROM %Table:SC7% SC7
			WHERE SC7.C7_FILIAL=%xFilial:SC7% AND	SC7.C7_NUM = %Exp:SCR->CR_NUM% AND ;
			SC7.%NotDel%
		EndSQL
		_nTotal:=(_cAlias)->C7TOTAL
		(_cAlias)->(dbCloseArea())
		_lRet:=.T.
		IF _nTotal > _nLimPerfil //.AND. _nTotal > _nLimGrupo
			
			U_ITMSG("Valor da Aprovação maior que o Limte do Perfil do Aprovador",'Atenção!',;
		            "Aprove ate o Limite do Perfil: "+STR(DHL->DHL_LIMMAX,18,2),1,,,.T.)//+CHR(13)+CHR(10)+"Limite do Grupo: "+STR(SAK->AK_LIMMAX,18,2)  ,2,,,.T.)
			
		    _lRet:=.F.
			
		ENDIF
		
		RETURN _lRet
		
	ENDIF
	
ENDIF

RETURN .T.

