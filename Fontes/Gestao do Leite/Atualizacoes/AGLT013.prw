/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/08/2018 | Inclu�do MenuDef para padroniza��o - Chamado 25767
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 15/08/2019 | Modificada valida��o para dele��o de registros. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 29/06/2021 | Criada fun��o para replicar cadastro para outras filiais. Chamado 37004
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: AGLT013
Autor-------------: Wodson Reis
Data da Criacao---: 02/10/2008
===============================================================================================================================
Descri��o---------: Rotina desenvolvida para possibilitar o cadastramento dos Tipos de Analises existentes.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT013

Private cCadastro	:= "Cadastro de Tipos de Faixas"
Private aRotina		:= MenuDef()
Private cAlias 		:= "ZL9"

mBrowse( 6, 1,22,75,cAlias,,,,,,)

Return

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 02/08/2018
===============================================================================================================================
Descri��o---------: Utilizacao de Menu Funcional
===============================================================================================================================
Parametros--------: aRotina
					1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transa��o a ser efetuada:
						1 - Pesquisa e Posiciona em um Banco de Dados
						2 - Simplesmente Mostra os Campos
						3 - Inclui registros no Bancos de Dados
						4 - Altera o registro corrente
						5 - Remove o registro corrente do Banco de Dados
					5. Nivel de acesso
					6. Habilita Menu Funcional
===============================================================================================================================
Retorno-----------: Array com opcoes da rotina
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina := {	{ "Pesquisar"		, "AxPesqui" 		, 0 , 1 } ,;
					{ "Visualizar"		, "AxVisual" 		, 0 , 2 } ,;
					{ "Incluir"			, "AxInclui" 		, 0 , 3 } ,;
					{ "Alterar"			, "AxAltera" 		, 0 , 4 } ,;
					{ "Excluir"			, "U_AGLT013E"		, 0 , 5 } ,;
					{ "Replicar Filiais", "U_AGLT013R"		, 0 , 4 }  }

Return( aRotina )

/*
===============================================================================================================================
Programa----------: AGLT013E
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 02/08/2018
===============================================================================================================================
Descri��o---------: Funcao usada para apagar registro da ZL9
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT013E(cAlias,nReg,nOpc)
Local bAxParam 	:= {|| .T.}
Local bVldExc	:= {|| U_ChkReg("ZLA","ZLA_COD = '"+ZL9->ZL9_COD+"' AND ZLA_FILIAL = '"+xFilial("ZLA")+"'")}

AxDeleta(cAlias,nReg,nOpc,/*cTransact*/,/*aCpos*/,/*aButtons*/,{bAxParam,bVldExc,bAxParam,bAxParam},/*aAuto*/,/*lMaximized*/)

Return

/*
===============================================================================================================================
Programa----------: AGLT013R
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 29/06/2021
===============================================================================================================================
Descri��o---------: Fun��o usada para replicar o evento para todas as filiais
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT013R(cAlias,nReg,nOpc)

Local _aArea	:= GetArea()
Local _aSelFil	:= AdmGetFil(.F.,.F.,cAlias)
Local _nX, _nI	:= 0
Local _aFields	:= FWSX3Util():GetAllFields( cAlias , .F. )
Local _aOrig	:= {}
Local _lRet		:= .F.

If Len(_aSelFil) > 0
	//Adiciono todos os campos no array
	For _nX	:= 1 To Len(_aFields)
		aAdd(_aOrig,&(_aFields[_nX]))
	Next _nX

	(cAlias)->(DBSetOrder(1))
	For _nX := 1 To Len(_aSelFil)
		If !(cAlias)->(DbSeek(_aSelFil[_nX] + &(cAlias+"->"+cAlias+"_COD")))
			(cAlias)->(RecLock(cAlias, .T.))
				For _nI := 1 To Len(_aFields)
					If "FILIAL" $ _aFields[_nI]
						(cAlias)->&(_aFields[_nI]) := _aSelFil[_nX]
					Else
						(cAlias)->&(_aFields[_nI]) := _aOrig[_nI]
					EndIf
				Next _nI
			(cAlias)->(MsUnLock())
			_lRet := .T.
		EndIf
	Next _nX
EndIf

If _lRet
	MsgInfo("Registro replicado para as filiais selecionadas que n�o possuiam o registro.","AGLT01301")
Else
	MsgAlert("N�o foram identificadas filiais aptas para a r�plica do registro.","AGLT01302")
EndIf

RestArea(_aArea)
Return
