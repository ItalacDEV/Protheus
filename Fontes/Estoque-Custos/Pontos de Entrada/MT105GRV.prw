 /*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 17/11/2017 | Alterações nas condições de define a impressão do recibo de entrega de EPIS. Chamado 22140.
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 28/11/2017 | Mudança da chamada de impressão do comprovante de entrega RMDT001, para o fonte MDTA6955.
              |            | Chamado 22680/22683/22685.   
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 10/04/2018 | Realização de ajustes nas rotinas de entrega e devolução de EPI, para impressão correta dos 
              |            | comprovantes. Chamado 23960.             
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 03/05/2018 | Gravação de 5 campos do SCP. Chamado 24680.           
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 05/09/2018 | Retirada de gravação e posicionamento SCP - Chamado 25283  
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 25/06/2020 | Gravação do campo CP_I_SITWF do SCP. Chamado 33355
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
Programa----------: MT105GRV
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 28/10/2008
===============================================================================================================================
Descrição---------: Este Ponto de Entrada e chamado apos conseguir gravar (l105GRV=.T.) os dados no arquivo SCP.
===============================================================================================================================
Parametros--------: PARAMIXB => nOpcao (Numerico)
                    [1] Inclusado
                    [2] Alteracao
                    [3] Exclusao
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT105GRV()
Local _aArea := GetArea()
Local _cNum	 := SCP->CP_NUM
Local _nscp  := SCP->(RECNO()) 
Local nOpcao := PARAMIXB

IF nOpcao = 3 //Exclusao 
   RETURN .T.
ENDIF		
		
SCP->(DBSETORDER(1))
SCP->(DBSEEK(xFilial("SCP")+_cNum))

DO WHILE (!SCP->(eof()) .and. ( xFilial("SCP")+_cNum == SCP->CP_FILIAL+SCP->CP_NUM )) .AND. !ISINCALLSTACK("MDTA695")

	SCP->(RecLock("SCP",.F.))
	SCP->CP_I_DTSOL := DATE()
	SCP->CP_I_RSSOL := TIME()
	SCP->CP_I_CDUSU := U_UCFG001(1)
	SCP->CP_I_GRAPR := Posicione("ZZL",4,xFilial("ZZL")+Trim(SCP->CP_SOLICIT),"ZZL_GRPAPR")
	SCP->CP_I_SITWF	:= "1"
	SCP->(MSUNLOCK())
		
	SCP->(DBSKIP())
	
ENDDO
		
RestArea(_aArea)
SCP->(DBGOTO(_nscp))
	
return .T.
