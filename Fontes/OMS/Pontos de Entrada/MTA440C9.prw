/*
==============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
==============================================================================================================================
 Alex Wallauer | 29/12/2020 | Ajuste para chamar a função u_UCFG001(1) - Chamado 35108
 -------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 02/02/2021 | Remoção de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
==============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
================================================================================================================================
Programa----------: MTA440C9
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 15/03/2010
================================================================================================================================
Descrição---------: Ponto de Entrada apos a liberacao do pedido de venda, para gravar a fililal + matricula do usuario, a data e a hora da liberacao do pedido de venda. 
================================================================================================================================
Parametros--------: NENHUM
================================================================================================================================
Retorno-----------: NENHUM
================================================================================================================================
*/
User Function MTA440C9()

_aArea:=GetArea()            //Salva area geral
_aAreaSC9:= SC9->(GetArea())
_aAreaSC5:= SC5->(GetArea())
_aAreaSC6:= SC6->(GetArea())

//Conout("MTA440C9: __cUserId: "+__cUserId+" / TYPE(_cCodUsuario) = "+TYPE("_cCodUsuario") )
IF TYPE("_cCodUsuario") = "C"
  // Conout("MTA440C9: _cCodUsuario: "+_cCodUsuario )
   IF !EMPTY(_cCodUsuario)
      __cUserId := _cCodUsuario // Carrega a variável do Workflow __cUserId com o código do solicitante da integração.
   ENDIF
ENDIF

DO While SC9->(!EOF()) .And. SC6->C6_FILIAL == SC9->C9_FILIAL .And. SC9->C9_PEDIDO = SC6->C6_NUM
	 
   SC9->(RecLock("SC9",.F.))
   SC9->C9_I_USLIB := u_UCFG001(1)
   SC9->C9_I_DTLIB := date()
   SC9->C9_I_HRLIB := TIME() 
   SC9->(MsUnlock())  
   SC9->(Dbskip())

EndDo   
      
Restarea(_aArea) //-- Restaura a posição da tabela corrente  
RestArea(_aAreaSC9)              
RestArea(_aAreaSC5)
RestArea(_aAreaSC6)

Return
