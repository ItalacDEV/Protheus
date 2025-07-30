/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/09/2024 | Chamado 48465. Removendo warning de compila��o.
==================================================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==================================================================================================================================================================================
Andre    - Julio Paz     - 25/10/24 - 06/11/24 -  48857  - Criar uma Op��o no Cadastro de Subgrupos de Produtos para o Usu�rio Alterar Apenas o Campo C�digo da Familia do subgrupo
==================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: AEST023
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 20/04/2010
===============================================================================================================================
Descri��o---------: Rotina para realizar as operacoes de inclusao, alteracao e exclusao dos dados do Sub Grupo
					As informacoes desse cadastro sera utilizado pelo campo SB1->B1_I_SUBGR
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST023

Private cAlias		:= "ZB9"
Private cCadastro	:= "Cadastro de sub Grupo"
Private aRotina		:= {}                

AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
AADD(aRotina,{"Alterar"		,"U_ValZB9",0,4})
AADD(aRotina,{"Excluir"		,"U_ValZB9",0,5})
AADD(aRotina,{"Alterar Familia","U_AEST023A()",0,4})
	
mBrowse(6,1,22,75,cAlias)

Return

/*
===============================================================================================================================
Programa----------: ValZB9
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 20/04/2010
===============================================================================================================================
Descri��o---------: Programa de Validacao da Alteracao e Exclusao, chamado pelo programa AEST023()
					Valida a alteracao e exclusao dos dados na tabela ZB9010, caso o codigo a ser excluido ja tenha amarracao na
					tabela SB1010 o programa nao permite a alteracao ou exclusao.
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Retorno Logico (.T. ou .F.) para exclusao ou alteracao
===============================================================================================================================
*/
User Function ValZB9(cAlias,nReg,nOpc)

Local _aArea 	:= FWGetArea()
Local _lRet		:= .F.
Local _cAlias	:= GetNextAlias()

BeginSql alias _cAlias
	SELECT COUNT(1) QTD FROM %Table:SB1% 
	WHERE D_E_L_E_T_ = ' ' AND B1_I_SUBGR = %exp:ZB9->ZB9_SUBGRU%
EndSql

If (_cAlias)->QTD > 0
	_lRet	:= .F.
   U_ItMsg("N�o ser� poss�vel realizar a altera��o ou exclusao de sub Grupos que estejam amarrados ao cadastro de algum produto. "+;
           "Favor excluir o cadastro de produtos que possui o Sub Grupo que deseja realizar a exclus�o.","Aten��o",,1)
EndIf

(_cAlias)->(DbCloseArea())

If _lRet .And. nOpc == 4
	AxAltera(cAlias,nReg,nOpc)
ElseIf _lRet .And. nOpc == 5 
	AxDeleta(cAlias,nReg,nOpc)
EndIf
FWRestArea(_aArea)

Return _lRet 

/*
=================================================================================================================================
Programa--------: AEST023A()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 25/10/2024
=================================================================================================================================
Descri��o-------: Permite alterar apenas o campo c�digo da Familia do subgrupo.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AEST023A()
Local _cTitulo
Local _bOk, _bCancel 
Local _oDlgF
Local _lRet := .T.
//Local _nTamPedido := TAMSX3("C5_NUM")[1]  
Local _cCodFamPr := ZB9->ZB9_CODFAM
Local _cDescFam  := Posicione("ZB3",1,xFilial("ZB3")+ZB9->ZB9_CODFAM,"ZB3_DESFAM")
Local _cDescFNov := ""  
Local _cTextPerg

Begin Sequence
   //================================================================================
   // Tela de Aprova��o de Pedido de Vendas
   //================================================================================      
   _cTitulo := "Altera��o do C�digo da Familia do Subgrupo"
   _bOk := {|| If(U_AEST023V(_cCodFamPr),(_lRet := .T., _oDlgF:End()),)}
   _bCancel := {|| _lRet := .F., _oDlgF:End()}
   
   Define MsDialog _oDlgF Title _cTitulo From 9,0 To 20,90 Of oMainWnd 
      
      @ 40,20 Say "Codigo Familia Subgrupo: " Of _oDlgF Pixel
      @ 37,80 MsGet _cCodFamPr F3 "ZB3" Size 10, 12 Of _oDlgF Valid(U_AEST023V(_cCodFamPr)) Pixel

   Activate MsDialog _oDlgF On Init EnchoiceBar(_oDlgF,_bOk,_bCancel) CENTERED 

   _cDescFNov := Posicione("ZB3",1,xFilial("ZB3")+_cCodFamPr,"ZB3_DESFAM")

   _cTextPerg := "Confirma a altera��o do c�digo '" + AllTrim(_cDescFam) + "' da fam�lia do subgrupo '" + AllTrim(ZB9->ZB9_DESSUB) + "' para o c�digo '" + AllTrim(_cDescFNov) + "' ?"

   If _lRet .And. U_ITMSG(_cTextPerg,"Aten��o" , , ,2, 2) 
	   ZB9->(RecLock("ZB9",.F.))
	   ZB9->ZB9_CODFAM := _cCodFamPr
      ZB9->(MsUnLock()) 

      U_ItMsg("C�digo da familia do subgrupo alterado com sucesso.","Aten��o",,2)
   EndIf 

   If ! _lRet	
      U_ItMsg("Altera��o do C�digo da familia do subgrupo cancelada.","Aten��o",,1)
   EndIf

End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AEST023V()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 25/10/2024
=================================================================================================================================
Descri��o-------: Valida a tela de altera��o do c�digo da familia do subgrupo.
=================================================================================================================================
Parametros------: _cConteudo = Conte�do informado na Tela
=================================================================================================================================
Retorno---------: _lRet = .T. = Valida��o OK
                          .F. = Valida��o inv�lida
=================================================================================================================================
*/
User Function AEST023V(_cConteudo)
Local _lRet := .T.

Begin Sequence

   If Empty(_cConteudo)
      U_ItMsg("C�digo da familia do subgrupo n�o preenchido. O preenchimento deste campo � obrigat�rio.","Aten��o",,1)
	  _lRet := .F.
	  Break
   EndIf 

   ZB3->(DbSetOrder(1))    
   If ! ZB3->(MsSeek(xFilial("ZB3")+_cConteudo))
      U_ItMsg("C�digo da familia do subgrupo informado, n�o existe no cadastro de familias de subgrupos.","Aten��o",,1)
	  _lRet := .F.
	  Break
   EndIf                                                     

End Sequence 

Return _lRet 
