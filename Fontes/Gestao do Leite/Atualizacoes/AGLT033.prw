/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 28/09/2018 | Revis�o do fonte para padroniza��o - Chamado 26404
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 15/02/2019 | Ajustado bloqueio de acesso - Chamado 28109
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: AGLT033
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 03/05/2010
===============================================================================================================================
Descri��o---------: Cadastro Fabrica x Setores que sera utilizado como filtro pelo usuario antes de visualizar a tela do MIX.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT033

Private cCadastro	:= "Cadastro de Fabricas X Setores"
Private aRotina		:= MenuDef()
Private cAlias		:= "ZLT"

mBrowse( ,,,,cAlias,,,,,,)

Return

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 28/09/2018
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
						6 - Altera determinados campos sem incluir novos Regs
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
					{ "Excluir"			, "AxDeleta"		, 0 , 5 }  }

Return( aRotina )