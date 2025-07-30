/*
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 07/03/2017 | Ajuste para evitar erro em função automática - Chamado 19202                                 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 28/12/2018 | Correção do retorno da filial + matricula - Chamado 35108
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 28/12/2018 | Criação do tipo 3 e do parametro _cCodID - Chamado 35108
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 29/12/2018 | Retirada da função PswRet() - Chamado 35108
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 17/09/2021 | Retirada da função Count() - Chamado 37771
=============================================================================================================================== 
*/
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
/*
===============================================================================================================================
Programa----------: UCFG001
Autor-------------: Tiago Correa Castro
Data da Criacao---: 31/07/2008
===============================================================================================================================
Descrição---------: Rotina generica que retorna informacoes do Cadastro de Usuario baseado nos parametros recebidos.   
===============================================================================================================================
Parametros--------: _nOpc	1=Retorna FILIAL + MATRICULA do usuario  
							2=Retorna o nome do usuario.      
							3=Retorna o e-mail do usuario.      
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function UCFG001(_nOpc,_cCodID)

Local _cInfo	:=	""
//Local aUserTmp	:= 	{}
DEFAULT _cCodID := __cUserId

//Conout("UCFG001 _cCodID = "+_cCodID)

If _nOpc == 1                                               //FIL + MATRICULA
   _cInfo:=Posicione("ZZL",3,xfilial("ZZL")+AllTrim(_cCodID),"ZZL_MATRIC")// ZZL_FILIAL+ZZL_CODUSU 
ElseIf _nOpc == 2 
   _cInfo:=Posicione("ZZL",3,xfilial("ZZL")+AllTrim(_cCodID),"ZZL_NOME") // ZZL_FILIAL+ZZL_CODUSU       
ElseIf _nOpc == 3
   _cInfo:=Posicione("ZZL",3,xfilial("ZZL")+AllTrim(_cCodID),"ZZL_EMAIL") // ZZL_FILIAL+ZZL_CODUSU       
Endif

//Conout("UCFG001 RETORNO ZZL: "+_cInfo)

IF !EMPTY(_cInfo)
   RETURN _cInfo
ENDIF
/*
PswOrder(1)
If PswSeek(_cCodID,.T.)
	aUserTmp := PswRet()
Endif
//Conout("POS PswSeek DA UCFG001 "+__cUserId)

If len(aUserTmp) < 1 
	//não achou usuario pois é rotina automatica
	_cinfo := "Auto"
	_nopc := 0 	
EndIf
*/
If _nOpc == 1 
// _cEmp:=SubStr(aUserTmp[1,22],1,LEN(SM0->M0_CODIGO))
// _cFil:=SubStr(aUserTmp[1,22],LEN(SM0->M0_CODIGO)+1,LEN(SM0->M0_CODFIL))
// _cMat:=SubStr(aUserTmp[1,22],LEN(SM0->M0_CODIGO)+LEN(SM0->M0_CODFIL)+1,LEN(SRA->RA_MAT))
   IF MPUSR_VINCFUNC->(DBSEEK(_cCodID))
      _cInfo:=	ALLTRIM(MPUSR_VINCFUNC->USR_FILIAL)+MPUSR_VINCFUNC->USR_CODFUNC
   ENDIF
ElseIf _nOpc == 2 
//  _cInfo	:= aUserTmp[1,2]//nome completo
   IF MPUSR_USR->(DBSEEK(_cCodID))
      _cInfo:=	ALLTRIM(MPUSR_USR->USR_NOME)
   ENDIF
ElseIf _nOpc == 3
//    _cInfo	:= aUserTmp[1,14]//e-mail
   IF MPUSR_USR->(DBSEEK(_cCodID))
      _cInfo:=	ALLTRIM(MPUSR_USR->USR_EMAIL)
   ENDIF
Endif

//Conout("UCFG001 RETORNO PswRet(): "+_cInfo)

Return(_cInfo)		
