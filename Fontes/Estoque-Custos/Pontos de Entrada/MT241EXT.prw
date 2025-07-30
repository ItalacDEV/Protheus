/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 06/11/2019 | Chamado 28346. Revis�o de fonte para novo appserver
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 22/08/2024 | Chamado 47670. Validar estorno considerando apenas os campos:ZZL_TIPMES,ZZL_ARMAES,ZZL_TIPRES. 
------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/09/2024 | Chamado 48569. Incluir a rotina de Desconto Tetra Pak nas exce��es para valida��o de acesso
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT241EXT
Autor-------------: Tiago Correa Castro
Data da Criacao---: 24/12/2008
===============================================================================================================================
Descri��o---------: Ponto de entrada para validar estorno dos movimentos internos modelo 2
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet == Define se o movimento pode ser estornado
===============================================================================================================================
*/
User Function MT241EXT

Local _aArea      := FWGetArea()
Local _aAreaZZL   := ZZL->(FWGetArea())
Local _aAreaSB1   := SB1->(FWGetArea())
Local _lRet	   	:= .T.
Local _nI         := 0
Local _nPosLocal  := aScan(aHeader,{|x| AllTrim(x[2])=="D3_LOCAL"})
Local _nPosCod    := aScan(aHeader,{|x| AllTrim(x[2])=="D3_COD"})
SB1->(DBSetOrder(1))

//================================================================================
// Verifica o Parametro que guarda a informacao do Tipo de Movimento utilizado 
// para gerar movimento interno de entrada no Estoque apos recepcao do Leite
//================================================================================
If FUNNAME() == "MATA241" .And. cTM $ AllTrim(SuperGetMV("LT_ENTTM",.F., ""))
   FWAlertWarning("Nao ser� poss�vel o estorno desse movimento interno pois o mesmo foi gerado automaticamente por outra rotina!!"+;
            "Favor realizar estorno do movimento via rotina que gerou o mesmo!!","MT241EXT01")
   _lRet := .F.
ElseIf !FWIsInCallStack("DESCTETRAE") .And. !FWIsInCallStack("DESCTETRAE")
   ZZL->(DbSetOrder(3))
   If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
      If !(cTm $ AllTrim(ZZL->ZZL_TIPMES))
         FWAlertWarning("Usu�rio sem permiss�o para utilizar este tipo de movimento. N�o ser� poss�vel realizar o estorno. Tipos de Movimentos permitidos ao usu�rio: '"+(ALLTRIM(ZZL->ZZL_TIPMOV)+";"+ALLTRIM(ZZL->ZZL_TIPMES))+"'. "+;
                     "Entre em contato com o suporte do TI.","MT241EXT02")
         _lRet := .F.
      ElseIf ZZL->ZZL_AUMMUL <> 'S'
         FWAlertWarning("Usu�rio sem permiss�o para realizar estorno de movimenta��o multipla. N�o ser� poss�vel realizar o estorno. Entre em contato com o suporte do TI.", "MT241EXT03")
         _lRet := .F.
      Else
         For _nI := 1 To Len(aCols)
            If !(aCols[_nI,_nPosLocal] $ AllTrim(ZZL->ZZL_ARMAES))
               FWAlertWarning("Usu�rio sem permiss�o para utilizar este armazem. N�o ser� poss�vel realizar o estorno. Armazens permitidos ao usu�rio: '"+;
                              (AllTrim(ZZL->ZZL_ARMAZE)+";"+AllTrim(ZZL->ZZL_ARMAES))+"'. Entre em contato com o suporte do TI.", "MT241EXT04")
               _lRet := .F.
               Exit
            EndIf
            //D3_TIPO n�o consta no aHeader
            SB1->(DBSeek(xFilial("SB1")+aCols[_nI,_nPosCod]))
            If !(SB1->B1_TIPO $ AllTrim(ZZL->ZZL_TIPRES))
               FWAlertWarning("Usu�rio sem permiss�o para utilizar este Tipo de Produto ["+SB1->B1_TIPO+"]. N�o ser� poss�vel realizar o estorno. Tipos "+;
                              "permitidos ao usu�rio: '"+(AllTrim(ZZL->ZZL_TIPROD)+";"+Alltrim(ZZL->ZZL_TIPRES))+"'. Entre em contato com o suporte do TI.","MT241EXT05")
               _lRet := .F.
               Exit
            EndIf
         Next _nI
      EndIf
   Else
      FWAlertWarning("Usu�rio sem cadastro na ZZL. Entre em contato com o suporte do TI.","MT241EXT06")
      _lRet := .F.
   EndIf
EndIf
ZZL->(FwRestArea(_aAreaZZL))
SB1->(FwRestArea(_aAreaSB1))
FwRestArea(_aArea)

Return _lRet
