/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------  
Josu� Danich  | 03/10/2017 | Chamado 16924 - Limpeza de fun��o antiga e integra��o a fun��o de bloqueio cnab.  
-------------------------------------------------------------------------------------------------------------------------------  
Josu� Danich  | 15/01/2017 | Chamado 22908 - Inclus�o de chamada de visualiza��o de canhoto da nota.            
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 23/01/2018 | Chamado 23332 - Ajuste na chamada do U_VISCANHO().
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  | 25/04/2024 | Chamado 46017 - Ajustes para conceder acesso ao Fonte AFIN034 atrav�s de privilegios do configurador
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================

/*
===============================================================================================================================
Programa--------: FA740BRW
Autor-----------: Fabiano Dias da Silva
Data da Criacao-: 29/10/2010
===============================================================================================================================
Descri��o-------: Ponto de Entrada que inclui uma opcao na mBrowse da Funcoes de contas a receber
				  (Bot�es inclusos aqui devem ser inclusos no PE FI040ROT para manter o padr�o de telas)
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Retorna um array aRotina com o(s) novo(s) itens do menu que foram adicionados.
===============================================================================================================================
*/
User Function FA740BRW()

Local aRotina := {}

aAdd( aRotina, {"Desbl Cnab", "U_AFIN024", 0, 3,0,nil}) 
aAdd( aRotina, {"Canhoto"   , "U_VISCANHO( SE1->E1_FILIAL, alltrim(SE1->E1_NUM) )", 0, 2,0,nil}) 

If FWIsInCallStack("CFGA530") // Trecho para conceder acesso ao Fonte AFIN034 atrav�s de privilegios do configurador 
   aAdd( aRotina, { 'AFIN034 Visualizar' , 'AxVisual', 0, 2, 0, NIL } )
   aAdd( aRotina, { 'AFIN034 Incluir' , 'AxInclui', 0, 3, 0, NIL } )
   aAdd( aRotina, { 'AFIN034 Alterar' , 'AxAltera', 0, 4, 0, NIL } )
   aAdd( aRotina, { 'AFIN034 Excluir' , 'AxDeleta', 0, 5, 0, NIL } )
EndIf

Return( aRotina )
