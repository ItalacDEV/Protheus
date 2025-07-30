/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich  | 16/09/2015 | Chamado 11890. Incluida valida��o de usu�rio da ZZL para manuten��o no cadastro
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/09/2024 | Chamado 48465. Removendo warning de compila��o.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: AEST003
Autor-------------: Tiago Correa Castro
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descri��o---------: Programa de Criacao de Tela de Cadastro do Nivel 4. As informacoes desse cadastro sera utilizado pelo campo
					SB1->B1_I_NIV4
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST003()

Local 	_cAlias		:= "ZA3"
Private cCadastro	:= "Cadastro de Nivel 4"
Private aRotina		:= {}                

AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
AADD(aRotina,{"Incluir"		,"U_AEST003V",0,3})
AADD(aRotina,{"Alterar"		,"U_AEST003V",0,4})
AADD(aRotina,{"Excluir"		,"U_AEST003V",0,5})
	
mBrowse(6,1,22,75,_cAlias)

Return

/*
===============================================================================================================================
Programa----------: AEST003V
Autor-------------: Tiago Correa Castro
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descri��o---------: Programa de Validacao da Alteracao e Exclusao, chamado pelo programa AEST003(). Valida a alteracao e 
					exclusao dos dados na tabela ZA3010, caso o codigo a ser excluido ja tenha amarracao na tabela SB1010 o 
					programa nao permite a alteracao ou exclusao.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Retorno Logico (.T. ou .F.) para inclusao, exclusao ou alteracao   
===============================================================================================================================
*/
User Function AEST003V(cAlias,nReg,nOpc)

Local _aArea 	:= FWGetArea()
Local _lRet		:= 	.T. 
Local _cAlias	:= 	GetNextAlias()

//==============================================================================
//Valida acesso a manute��o de n�vel 4
//==============================================================================
If (nOpc == 4 .Or. nOpc == 5 .Or. nOpc == 3)
	If .Not. U_ITVACESS('ZZL',3,'ZZL_ALNV4',"S")
		FWAlertInfo("Usu�rio sem acesso � manuten��o de cadastros de n�vel 4! Caso necess�rio solicite a manuten��o � um usu�rio com acesso ou, se necess�rio, solicite o acesso � �rea de TI/ERP.","AEST00301")
		Return .F.
	EndIf
EndIf

//==============================================================================
//valida manuten��o de registro contra uso do cadastro na B1
//==============================================================================
If (nOpc == 4 .Or. nOpc == 5)
	BeginSql alias _cAlias
		SELECT COUNT(1) QTD FROM %Table:SB1% 
		WHERE D_E_L_E_T_ = ' ' AND B1_I_NIV4 = %exp:ZA3->ZA3_COD%
	EndSql

	If (_cAlias)->QTD > 0
		_lRet	:= .F.
		FWAlertWarning("Cadastro j� utilizado em produtos! Caso necess�rio modifique o grupo 4 utilizado nos produtos antes de alterar esse cadastro.","AEST00302")
	EndIf

	(_cAlias)->(DbCloseArea())
EndIf

//==============================================================================
//Se est� tudo certo faz inclus�o/altera��o/exclus�o
//==============================================================================
If _lRet .And. nOpc == 4
	AxAltera(cAlias,nReg,nOpc)
ElseIf _lRet .And. nOpc == 5 
	AxDeleta(cAlias,nReg,nOpc)
ElseIf _lRet .And. nOpc == 3
	AxInclui(cAlias,nreg,nOpc)
EndIf
FWRestArea(_aArea)

Return _lRet 
