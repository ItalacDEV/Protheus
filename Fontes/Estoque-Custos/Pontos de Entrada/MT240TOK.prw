/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 15/04/2019 | Chamado 28685. Valida��o p/ n�o permitir fracionamento de UM que s�o inteiras
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 06/11/2019 | Chamado 30984. N�o valida fracionamento de UM quando vem do IsInCallStack("U_A010TOK")
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/09/2024 | Chamado 48569. Incluir a rotina de Desconto Tetra Pak nas exce��es para valida��o de acesso
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa--------: MT240TOK
Autor-----------: Tiago Correa Castro
Data da Criacao-: 25/04/2009
===============================================================================================================================
Descri��o-------: Ponto de Entrada que valida movimento interno modelo I
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: L�gico, permitindo ou n�o a grava��o o movimento
===============================================================================================================================
*/
User Function MT240TOK

Local _aArea      := FWGetArea()
Local _aAreaZZL   := ZZL->(FWGetArea())
Local _aAreaSB1   := SB1->(FWGetArea())
Local _lRet		   :=	.T.  
Local cTipo  	   := SuperGetMV("IT_TPMOV",.F., "")
Local _cDados	   := {}
Local _aSldNeg  	:= {}
Local _cArmazens  := U_ITGetMV( 'IT_ARMCPR' , "02,04" ) 
Local _cUMNoFrac  := U_ITGetMV("IT_UMNOFRAC","PC,UN")
Local _lVldFr1UM  :=.T.
Local _nX         := 0

If Substr(M->D3_COD,1,4) == "0006" .And. !IsInCallStack("U_MEST015") .And. M->D3_QTSEGUM == 0
   FWAlertWarning("Para esse produto e obrigatorio o preenchimento da segunda unidade de medida (Pe�as).",;
                  "Favor preencher a segunda unidade de medida (Pe�as).","MT240TOK01")
   _lRet := .F.
ElseIf SuperGetMV("IT_BLQMOV",.F., "") .And. M->D3_EMISSAO > DATE()
   FWAlertWarning("Os movimentos com data maior que a data atual est�o bloqueados.",;
                  "Entre em contato com o departamento de TI para maiores informa��es.","MT240TOK02")
   _lRet := .F.
ElseIf !FWIsInCallStack("DESCTETRAE") .And. !FWIsInCallStack("DESCTETRAE") .And. !FWIsInCallStack("AGLT003G") .And. !FWIsInCallStack("MATA103")
   ZZL->(DbSetOrder(3))
   If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
      If ZZL->ZZL_AUTSIM <> 'S'
         FWAlertWarning("Usu�rio sem permiss�o para realizar movimenta��o simples. N�o ser� poss�vel realizar a movimenta��o. Entre em contato com o suporte do TI.", "MT240TOK03")
         _lRet := .F.
      ElseIf M->D3_TM >= "500" .And. (M->D3_LOCAL $ _cArmazens) .And. ZZL->ZZL_PERTRA <> "S"
         FWAlertWarning("Para o "+M->D3_LOCAL+" n�o � permitido a movimenta��o interna, somente tranferencia entre armazens. Armazens n�o permitidos: '"+AllTrim(_cArmazens)+"'.",;
                        "Realize a transferencia entre armazens ou entre em contato com o departamento de Custo.","MT240TOK04")
         _lRet := .F.
      ElseIf !(M->D3_TM $ ZZL->ZZL_TIPMOV)
         FWAlertWarning("Usu�rio sem permiss�o para utilizar este tipo de movimento. N�o ser� poss�vel realizar a movimenta��o. Tipos de Movimentos permitidos ao usu�rio: '"+AllTrim(ZZL->ZZL_TIPMOV)+"'.",;
                        "Entre em contato com o suporte do TI.","MT240TOK05")
         _lRet := .F.
      ElseIf !(M->D3_LOCAL $ ZZL->ZZL_ARMAZE)
         FWAlertWarning("Usu�rio sem permiss�o para utilizar este armazem. N�o ser� poss�vel realizar a movimenta��o simples. Armazens permitidos ao usu�rio: '"+AllTrim(ZZL->ZZL_ARMAZE)+"'.",;
                        "Entre em contato com o suporte do TI.","MT240TOK06")
         _lRet := .F.
      Else
         _cTipoProd:=Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_TIPO")
         If !(_cTipoProd $ ZZL->ZZL_TIPROD)
            FWAlertWarning("Usu�rio sem permiss�o para utilizar este Tipo de Produto ["+_cTipoProd+"]. N�o ser� poss�vel realizar a movimenta��o multipla. Tipos permitidos ao usu�rio: '"+AllTrim(ZZL->ZZL_TIPROD)+"'.",;
                           "Entre em contato com o suporte do TI.",,"MT240TOK07")
            _lRet := .F.
         EndIf
      EndIf
   Else
      FWAlertWarning("Usu�rio sem cadastro na ZZL. Entre em contato com o suporte do TI.","MT240TOK08")
      _lRet := .F.
      EndIf
EndIf

//=========================================================================================
//S� roda valida��es abaixo se n�o for execu��o autom�tica de entrada de recep��o de leite	
//=========================================================================================
If !FWIsInCallStack("AGLT003") .And. !FWIsInCallStack("MGLT002") .And. !FWIsInCallStack("AGLT021") 
   //Criado para impedir que seja feito lan�amento de sa�da retroativo deixando o saldo negativo em alguma data posterior.
   If M->D3_TM >= "500"          //Se movimento de sa�da
      _aSldNeg := U_VldEstRetrNeg(M->D3_COD, M->D3_LOCAL, M->D3_QUANT, M->D3_EMISSAO)    //Varre os saldos de cada dia at� a data de hoje buscando por saldo insuficiente
      If Len(_aSldNeg) > 0
         FWAlertWarning("N�o permitido, pois o produto " + M->D3_COD + "-" + M->D3_LOCAL + " n�o tem saldo suficiente em " + DToC(_aSldNeg[1]) + ;
                        ". Saldo na data:" + Transform(_aSldNeg[2],"@E 999,999.99"),"MT240TOK09")
         _lRet  := .F.
      EndIf
   EndIf
   
   If _lRet
      If ZZL->ZZL_PEFRPA == "S"
         _lVldFr1UM:=.F.
      EndIf

      If IsInCallStack("U_A010TOK")//Quando vem do cadastro de produtos apos trocar de UM zera o estoque
         _lVldFr1UM:=.F.
      EndIf

      SB1->(DBSetOrder(1))
      If _lVldFr1UM .And. SB1->(DBSeek(xFilial("SB1") + M->D3_COD))
         If (SB1->B1_UM $ _cUMNoFrac .And. M->D3_QUANT <> Int(M->D3_QUANT))
            FWAlertWarning("N�o � permitido fracionar a quantidade da 1a. UM de produto onde a Unid. Medida for "+_cUMNoFrac+".",;
                     "Favor informar apenas quantidades inteiras na Primeira Unidade de Medida.","MT240TOK10")
            _lRet := .F.
         ElseIf (SB1->B1_SEGUM $ _cUMNoFrac .AND. M->D3_QTSEGUM <> Int(M->D3_QTSEGUM))//= "PC" .AND. LEFT(M->D3_COD,4)=="0006" .AND. M->D3_QTSEGUM <> Int(M->D3_QTSEGUM) )
            FWAlertWarning("N�o � permitido fracionar a quantidade da 2a. UM de produto onde a Unid. Medida for "+_cUMNoFrac+".",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                     "Favor informar apenas quantidades inteiras na Segunda Unidade de Medida.","MT240TOK11")
            _lRet := .F.
         EndIf
      EndIf
   EndIf
EndIf

If _lRet
   _cDados:= StrTokArr(cTipo,"/")//  valida��o do centro de custo para que n�o deixe baixar se o mesmo estiver em branco de acordo com o tipo de movimenta��o do parametro IT_TPMOV. Chamado 3360.
   For _nX:=1 To Len(_cDados)
      If M->D3_TM == _cDados[_nX] .And. Empty(M->D3_CC)
         FWAlertWarning("N�o � possivel fazer movimento com o centro de custo em branco. Favor preencher o campo centro de custo.","MT240TOK12")
         _lRet := .F.
      ElseIf !Empty(M->D3_CC) // valida��o para preenchimento do centro de custo na tabela SCP conforme o que for baixado na tabela SD3. Chamado: 3409.
         SCP->(RecLock("SCP",.F.))
         SCP->CP_CC     := M->D3_CC
         SCP->CP_I_MOTIV:= M->D3_I_MOTIV   //  valida��o para grava��o do conteudo do campo CP_I_MOTIV para o campo D3_I_MOTIV.
         SCP->CP_OBS	   := M->D3_I_OBS
         SCP->(MsUnlock())
      EndIf
   Next _nX
EndIf

SB1->(FwRestArea(_aAreaSB1))
ZZL->(FwRestArea(_aAreaZZL))
FwRestArea(_aArea)

Return _lRet
