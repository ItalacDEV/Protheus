/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 22/08/2024 | Chamado 47670. Validar estorno considerando apenas os campos:ZZL_TIPMES,ZZL_ARMAES,ZZL_TIPRES.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/09/2024 | Chamado 48569. Incluir a rotina de Desconto Tetra Pak nas exce��es para valida��o de acesso
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 20/09/2024 | Chamado 48598. Corrigido nome do campo
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT240EST
Autor-------------: Tiago Correa Castro
Data da Criacao---: 24/12/2008
===============================================================================================================================
Descri��o---------: Ponto de entrada para validar estorno dos movimentos internos modelo 1
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet == Define se o movimento pode ser estornado
===============================================================================================================================
*/
User Function MT240EST

Local _aArea      := FWGetArea()
Local _aAreaZZL   := ZZL->(FWGetArea())
Local _lRet       := .T.
Local _aSldNeg    := {}
Local _cTipoProd  := ""

//================================================================================
// Parametro que guarda a informacao do Tipo de Movimento que sera utilizado para
// gerar movimento interno de entrada no Estoque apos recepcao do Leite
//================================================================================
If FUNNAME() == "MATA241" .And. SD3->D3_TM $ AllTrim(SuperGetMV("LT_ENTTM",.F., ""))
   FWAlertWarning("Nao ser� poss�vel o estorno desse movimento interno pois o mesmo foi gerado automaticamente por outra rotina!!"+;
            "Favor realizar estorno do movimento via rotina que gerou o mesmo!!","MT240EST01")
   _lRet := .F.
ElseIf !FWIsInCallStack("DESCTETRAE") .And. !FWIsInCallStack("DESCTETRAE")
   ZZL->(DbSetOrder(3))
   If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
      If ZZL->ZZL_AUMSIM <> 'S'
         FWAlertWarning("Usu�rio sem permiss�o para realizar estorno de movimenta��o simples. N�o ser� poss�vel realizar o estorno. Entre em contato com o suporte do TI.", "MT240EST02")
         _lRet := .F.
      ElseIf !(SD3->D3_TM $ AllTrim(ZZL->ZZL_TIPMES))
         FWAlertWarning("Usu�rio sem permiss�o para utilizar este tipo de movimento. N�o ser� poss�vel realizar o estorno. Tipos de Movimentos permitidos ao usu�rio: '"+;
                        (AllTrim(ZZL->ZZL_TIPMOV)+";"+AllTrim(ZZL->ZZL_TIPMES))+"'. Entre em contato com o suporte do TI.","MT240EST03")
         _lRet := .F.
      ElseIf !(SD3->D3_LOCAL $ ALLTRIM(ZZL->ZZL_ARMAES))
         FWAlertWarning("Usu�rio sem permiss�o para utilizar este armazem. N�o ser� poss�vel realizar o estorno. Armazens permitidos ao usu�rio: '"+;
                        (AllTrim(ZZL->ZZL_ARMAZE)+";"+AllTrim(ZZL->ZZL_ARMAES))+"'. Entre em contato com o suporte do TI.","MT240EST04")
         _lRet := .F.
      Else
         _cTipoProd:=Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_TIPO")
         If !(_cTipoProd $ AllTrim(ZZL->ZZL_TIPRES))
            FWAlertWarning("Usu�rio sem permiss�o para utilizar este Tipo de Produto ["+_cTipoProd+"]. N�o ser� poss�vel realizar a movimenta��o multipla. Tipos permitidos "+;
                           "ao usu�rio: '"+(AllTrim(ZZL->ZZL_TIPROD)+";"+AllTrim(ZZL->ZZL_TIPRES))+"'. Entre em contato com o suporte do TI.","MT240EST05")
            _lRet := .F.
         EndIf
      EndIf
   Else
      FWAlertWarning("Usu�rio sem cadastro na ZZL. Entre em contato com o suporte do TI.","MT240EST06")
      _lRet := .F.
   EndIf
EndIf
        
//================================================================================
// Validar o saldo em estoque na data do estorno.
//================================================================================
If SD3->D3_TM < "500" 		
   _aSldNeg := U_VldEstRetrNeg(SD3->D3_COD, SD3->D3_LOCAL, SD3->D3_QUANT, SD3->D3_EMISSAO) //Varre os saldos de cada dia at� a data de hoje buscando por saldo insuficiente
   If Len(_aSldNeg) > 0
      FWAlertWarning( "N�o permitido, pois o produto " + SD3->D3_COD + "-" + SD3->D3_LOCAL + " n�o tem saldo suficiente em " + DToC(_aSldNeg[1]) + ;
                     ". Saldo na data:" + Transform(_aSldNeg[2],"@E 999,999.99"),"MT240EST07")
      _lRet  := .F.
   EndIf
Endif

ZZL->(FwRestArea(_aAreaZZL))
FwRestArea(_aArea)

Return _lRet
