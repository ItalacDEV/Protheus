/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  |01/12/2017| Chamado 22690. Inclusão de regra por fornecedor
Josué Danich  |31/08/2017| Chamado 26044. Inclusão de regra por cliente
Lucas Borges  |27/05/2025| Chamado 50617. Revisões diversas visando padronizar os fontes
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
/*
===============================================================================================================================
Programa----------: ACOM034
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/12/2016
Descrição---------: Rotina de manutenção no cadastro de vinculação de filial x centro de custo x produtos.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function ACOM034()  

Local _cTitulo := "Cadastro de Vinculação Filial x Centro de Custo x Produtos/Fornecedor" As Character
Local _bok := {||U_ACOM034O()} As Codeblock

AxCadastro("ZFX",_cTitulo,,,,,_bok)

Return

/*
===============================================================================================================================
Programa----------: ACOM034V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/12/2016
Descrição---------: Validar a digitação dos dados no cadastro de vinculação de filial x centro de custo x produtos.
Parametros--------: _cCampo = Campo ou trecho da rotina que chamou a validação.
Retorno-----------: True ou False
===============================================================================================================================
*/  
User Function ACOM034V(_cCampo As Character) 

Local _lRet := .T. As Logical
Local _aOrd := SaveOrd({"ZFX"}) As Array
Local _cnome := "" As Character

Begin Sequence
   If _cCampo == "ZFX_CCUSTO" 
      ZFX->(DbSetOrder(1))
      
      If M->ZFX_TIPO == "P" .AND. ZFX->(DbSeek(xFilial("ZFX")+M->ZFX_PRODUT+M->ZFX_CCUSTO)) 
         FWAlertWarning("Produto x Centro de Custo já cadastrado para esta filial.","ACOM03401")
         _lRet := .F.    
         Break
      EndIf
   
   EndIf

   SA1->(Dbsetorder(1))
   If SA1->(Dbseek(xfilial("SA1")+M->ZFX_CLIENT+M->ZFX_LOJC))
      _cnome := SA1->A1_NOME
   EndIf

   If !Empty(M->ZFX_CLIENT) .AND. !EMPTY(M->ZFX_LOJC)
	  M->ZFX_NOMEC := _cnome
   EndIf
   
End Sequence

RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa----------: ACOM034O
Autor-------------: Josué Danich Prestes
Data da Criacao---: 05/12/2016
Descrição---------: Validação do cadastro
Parametros--------: Nenhum
Retorno-----------: True ou False
===============================================================================================================================
*/  
User Function ACOM034O

Local _lret := .T. As Logical

Begin Sequence

If M->ZFX_TIPO == 'P' 
	If EMPTY(M->ZFX_PRODUT)
		FWAlertWarning("Para regra tipo produto o campo produto é obrigatório!","ACOM03402")
 		_lret := .F.
 		Break
 	Endif
 	
 	ZFX->(DbSetOrder(1))
    If (inclui .or. M->ZFX_PRODUT != ZFX->ZFX_PRODUT) .AND. ZFX->(DbSeek(xFilial("ZFX")+M->ZFX_PRODUT)) 
 		FWAlertInfo("Regra para esse produto já cadastrada nessa filial.","ACOM03403")
 		_lRet := .F.    
 		Break
 	EndIf
 
 	If !(EMPTY(M->ZX_FORNEC) .AND. EMPTY(M->ZX_LOJA) .AND. EMPTY(M->ZX_CLIENT) .AND. EMPTY(M->ZX_LOJC) )
 		If FWAlertYesNo("Para registro do tipo produto os campos Fornecedor e Cliente devem estar vazios, apagar campos e confirmar gravação?","ACOM03404")
 			M->ZX_FORNEC := ""
 			M->ZX_LOJA := ""
 			M->ZX_CLIENT := ""
 			M->ZX_LOJC := ""
 		Else
			_lRet := .F.    
 			Break
 		Endif
 	Endif
Endif

If M->ZFX_TIPO == 'F' 
 	If EMPTY(M->ZFX_FORNEC)
 		FWAlertWarning("Para regra tipo fornecedor o campo fornecedor é obrigatório!","ACOM03405")
 		_lret := .F.
 		Break
 	Endif
 	
 	ZFX->(DbSetOrder(3))
      
 	If  (inclui .or. M->ZFX_FORNEC+M->ZFX_LOJA != ZFX->ZFX_FORNEC+ZFX->ZFX_LOJA) .AND. ZFX->(DbSeek(xFilial("ZFX")+M->ZFX_FORNEC+M->ZFX_LOJA)) 
 		FWAlertInfo("Regra de para esse fornecedor já cadastrada nessa filial.","ACOM03406")
 		_lRet := .F.    
 		Break
 	Endif
 	
 	If !(EMPTY(M->ZX_PRODUT) .AND. EMPTY(M->ZX_CLIENT) .AND. EMPTY(M->ZX_LOJC) )
 		If FWAlertYesNo("Para registro do tipo fornecedor os campos Produto e Cliente devem estar vazios, apagar campos e confirmar gravação?","ACOM03407")
 			M->ZX_PRODUT := ""
 			M->ZX_CLIENT := ""
 			M->ZX_LOJC := ""
 		Else
 			_lRet := .F.    
 			Break
 		Endif
 	Endif
Endif

If M->ZFX_TIPO == 'C' 
 	If EMPTY(M->ZFX_CLIENT)
 		FWAlertWarning("Para regra tipo cliente o campo cliente é obrigatório!","ACOM03408")
 		_lret := .F.
 		Break
 	Endif
 	
 	ZFX->(DbSetOrder(4))
 	If (inclui .or. M->ZFX_CLIENT+M->ZFX_LOJC != ZFX->ZFX_CLIENT+ZFX->ZFX_LOJC) .AND. ZFX->(DbSeek(xFilial("ZFX")+M->ZFX_CLIENT+M->ZFX_LOJC)) 
 		FWAlertInfo("Regra de para esse cliente já cadastrada nessa filial.","ACOM03409")
 		_lRet := .F.    
 		Break
 	EndIf
 	
 	If !(EMPTY(M->ZX_PRODUT) .AND. EMPTY(M->ZX_CLIENT) .AND. EMPTY(M->ZX_LOJC) )
 		If FWAlertYesNo("Para registro do tipo cliente os campos Produto e Fornecedor devem estar vazios, apagar campos e confirmar gravação?","ACOM03410")
 			M->ZX_PRODUT := ""
 			M->ZX_FORNEC := ""
 			M->ZX_LOJA := ""
 		Else
 			_lRet := .F.    
 			Break
 		Endif
 	Endif
Endif

End Sequence

Return _lret

/*
===============================================================================================================================
Programa----------: ACOM034O
Autor-------------: Josué Danich Prestes
Data da Criacao---: 05/12/2016
Descrição---------: Gatilho do campo C6_CC
Parametros--------: Nenhum
Retorno-----------: _cCC - string com valor para o C6_CC
===============================================================================================================================
*/  
User Function ACOM034G

Local _cCC := Posicione('SB1',1,xfilial('SB1')+M->C6_PRODUTO, 'B1_CC') As Character//(só usa se não achar regra)
Local _cordem := SuperGetMV("IT_ORDCC",.F.,"C") As Character //Define ordem de prioridade de regra, C para cliente primeiro e P para produto primeiro
Local _lachou := .F. As Logical

//Atualiza com regra de produto 
ZFX->(Dbsetorder(1))

If ZFX->(Dbseek(xfilial("ZFX")+M->C6_PRODUTO))
	_cCC := ZFX->ZFX_CCUSTO
	_lachou := .F.
Endif

//Atualiza com regra de cliente se for prioridade ou se não achou regra de produto
ZFX->(Dbsetorder(4))
If (_cordem == "C" .or. !_lachou ) .and. ZFX->(Dbseek(xfilial("ZFX")+M->C5_CLIENTE+M->C5_LOJACLI))
	_cCC := ZFX->ZFX_CCUSTO
Endif

Return _cCC
