/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Talita       | 14/01/2013 | Alteracao realizada na validacao da exclusao da  carteira. Chamado: 02305                              
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 08/05/2018 | Padroniza��o dos cabe�alhos dos fontes e fun��es do m�dulo financeiro. Chamado 24726.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/10/2019 | Rotina reescrita. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: AFIN021
Autor-------------: Guilherme Diogo  
Data da Criacao---: 08/01/2013
===============================================================================================================================
Descri��o---------: Cadastro de Tipos de Carteira de Cobranca.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN021

Private cAlias		:= "ZAR"
Private cCadastro	:= "Cadastro de Tipos de Carteira de Cobra�a"
Private aRotina		:= MenuDef()

mBrowse(6,1,22,75,cAlias)

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
					{ "Excluir"			, "U_ValZAR"		, 0 , 5 }  }

Return( aRotina )

/*
===============================================================================================================================
Fun��o------------: ValZAR
Autor-------------: Talita Teixeira  
Data da Criacao---: 14/01/2013 
===============================================================================================================================
Descri��o---------: Exclus�o de Tipos de Carteira de Cobranca
                    Valida��o da exclus�o do tipo de carteira, para que n�o permita que o usu�rio n�o exclua a carteira quando
                    o mesmo possuir vinculo no contas a receber.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ValZAR (cAlias,nReg,nOpc)

Local bAxParam 	:= {|| .T.}
Local bVldExc	:= {|| U_ChkReg("SE1","E1_I_CART = '"+ZAR->ZAR_COD+"' ")}

AxDeleta(cAlias,nReg,nOpc,/*cTransact*/,/*aCpos*/,/*aButtons*/,{bAxParam,bVldExc,bAxParam,bAxParam},/*aAuto*/,/*lMaximized*/)

Return