/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Xavier        | 12/05/2015 | Chamado 9551. Exclus�o de linha ou todos registros da filial.
-------------------------------------------------------------------------------------------------------------------------------
Jonathan      | 04/05/2020 | Chamado 32763. Alterar chamada "MsgBox" para "U_ITMSG".
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
Programa----------: AEST026
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 25/10/2012
===============================================================================================================================
Descri��o---------: Cadastro de produtos na tabela do almoxarifado (ZZR)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST026

Local 	_cAlias		:= "ZZR"
Private cCadastro	:= "Cadastro Tabela Almoxarifado"
Private aRotina		:= {}
Private _aCores    	:= { 	{ "ZZR_STATUS == '1'", 'BR_VERMELHO' },;
							{ "ZZR_STATUS == '3'", 'BR_AZUL' },;
                    	  	{ "ZZR_STATUS == '2'", 'BR_VERDE' } }

AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
AADD(aRotina,{"Excluir"		,"U_AEST026A()",0,5})
AADD(aRotina,{"Legenda"		,"U_AEST026L()",0,6})

mBrowse(6,1,22,75,_cAlias,,,,,, _aCores)

Return

/*
===============================================================================================================================
Programa----------: AEST026
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 25/10/2012
===============================================================================================================================
Descri��o---------: Excluir a linha ou todos os registros da filial do registro posicionado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST026A()

Local _oDlg		:= Nil
Local oButton1	:= Nil
Local oButton2	:= Nil
Local oComboBox1:= Nil
Local cComboBox1:= "1"
Local oSay1		:= Nil
Local nOpca 	:= 0

DEFINE MSDIALOG _oDlg TITLE "Forma de excluir" FROM 000, 000  TO 100, 300 COLORS 0, 16777215 PIXEL
@ 012, 015 SAY oSay1 PROMPT "Excluir ?" SIZE 025, 007 OF _oDlg COLORS 0, 16777215 PIXEL
@ 010, 045 MSCOMBOBOX oComboBox1 VAR cComboBox1 ITEMS {"1=Registro atual","2=Registros da filial","3=Documento"} SIZE 072, 010 OF _oDlg COLORS 0, 16777215 PIXEL
DEFINE SBUTTON oButton1 FROM 028, 036 TYPE 01 OF _oDlg ENABLE ACTION {|| nOpca := 1 , _oDlg:End() }
DEFINE SBUTTON oButton2 FROM 027, 087 TYPE 02 OF _oDlg ENABLE ACTION { || nOpca := 2 , _oDlg:End() }
ACTIVATE MSDIALOG _oDlg

//Processar rotina
If nOpca = 1 //confirmar
	If cComboBox1 = "2" //excluir todos
		If U_ITMSG("Todos os registros da filial "+ZZR->ZZR_FILIAL+" ser�o excluidos.","AEST026","Todos os registros da filial "+ZZR->ZZR_FILIAL+" ser�o excluidos.",3,2,2)
			If U_ITMSG( UsrRetName( RetCodUsr() )+", confirma a exclus�o de todos os registros da filial "+ZZR->ZZR_FILIAL+" ?","AEST026",UsrRetName( RetCodUsr() )+", confirma a exclus�o de todos os registros da filial "+ZZR->ZZR_FILIAL+" ?",3,2,2)
				MsAguarde({|| sExcluir() },"Excluir registros...")
				
			EndIf
		EndIf
	Elseif cComboBox1 = "3" //todo o documento
		If U_ITMSG("Todos os registros do documento "+ZZR->ZZR_DOC+" ser�o excluidos.","AEST026","Todos os registros do documento "+ZZR->ZZR_DOC+" ser�o excluidos.",3,2,2)
			If U_ITMSG( UsrRetName( RetCodUsr() )+", confirma a exclus�o de todos os registros do documento "+ZZR->ZZR_DOC+" ?","AEST026",UsrRetName( RetCodUsr() )+", confirma a exclus�o de todos os registros do documento "+ZZR->ZZR_DOC+" ?",3,2,2)
				MsAguarde({|| AEST0026D() },"Excluir registros...")
			EndIf
		EndIf
	Else	
		If U_ITMSG("Apenas o registro posicionado sera excluido.","AEST026","Apenas o registro posicionado sera excluido.",3,2,2)
			RecLock("ZZR",.F.)
			ZZR->(DbDelete())
			ZZR->(MsUnLock())
		EndIf
	EndIf
EndIf
Return .T.

/*
===============================================================================================================================
Programa----------: AEST026
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 25/10/2012
===============================================================================================================================
Descri��o---------: Excluir registros da filial
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function sExcluir()

Local _cFil := ZZR->ZZR_FILIAL

ZZR->(DbSeek(_cFil))
While ZZR->(!EOF()) .And. ZZR->ZZR_FILIAL = _cFil
	MsProcTxt("Processando linha "+ZZR->ZZR_LINHA+" da filial "+_cFil)
	RecLock("ZZR",.F.)
	ZZR->(DbDelete())
	ZZR->(MsUnLock())
	ZZR->(DbSkip())
EndDo

Return .T.

/*
===============================================================================================================================
Programa----------: AEST0026D
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 25/10/2012
===============================================================================================================================
Descri��o---------: 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AEST0026D

Local _cDoc := ZZR->ZZR_DOC

ZZR->(DBGoTop())

While ZZR->(!EOF()) 
	MsProcTxt("Processando linha "+ZZR->ZZR_LINHA+" da filial "+ZZR->ZZR_DOC)
	
	If _cDoc == ZZR->ZZR_DOC
		RecLock("ZZR",.F.)
		ZZR->(DbDelete())
		ZZR->(MsUnLock())
	EndIf
	ZZR->(DbSkip())
EndDo

Return .T.

/*
===============================================================================================================================
Programa----------: AEST0026L
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 25/10/2012
===============================================================================================================================
Descri��o---------: Legenda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST0026L

Local _aLegenda := {{ "BR_VERMELHO", "Pendente"  },;
   					{ "BR_AZUL",     "Cancelado" },;
                 	{ "BR_VERDE",    "Processado"} }

BRWLEGENDA( "Planilha de Inventario", "Legenda", _aLegenda )

Return .T.
