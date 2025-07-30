/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------

===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: ACOM040
Autor-------------: Igor Melga�o
Data da Criacao---: 22/03/2023
===============================================================================================================================
Descri��o---------: Valida��o de campos do Cadastro de Indicador de Produto Mod. 2 - Chamado 41686
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM040()
Local lReturn  := .T.
Local nPosOrig := GDFieldPos("BZ_ORIGEM") 
Local nPosFCI  := GDFieldPos("BZ_I_FCICO") 
Local cVar     := ReadVar()

Do CASE
	Case cVar == "M->BZ_I_FCICO"

		If !Empty(Alltrim(aCols[n][nPosFCI] ))
			If aCols[n][nPosOrig] == '0' .OR. Empty(Alltrim(aCols[n][nPosOrig]))
				lReturn := .F.
				U_ITMSG("Para preencher o c�digo da FCI, o conteudo do campo Origem deve ser diferente de 0 - Nacional.","Aten��o","Para opera�oes de produtos com  conteudo de importa��o a origem deve conter um destes valores 1, 2, 3, 4, 5, 6 ou 8",2,,,.T.)
			EndIf
		EndIf
	
	Case cVar == "M->BZ_ORIGEM"

		If !Empty(Alltrim(aCols[n][nPosFCI]))
			If aCols[n][nPosOrig] == '0' .OR. Empty(Alltrim(aCols[n][nPosOrig]))
				lReturn := .F.
				U_ITMSG("N�o � permitido colocar origem zero enquanto houver informa��o preenchida no campo C�digo FCI.","Aten��o","Apague o c�digo da FCI ou informe uma origem compativel com o conte�do de importa��o.",2,,,.T.)
			EndIf
		EndIf
EndCase

Return lReturn
