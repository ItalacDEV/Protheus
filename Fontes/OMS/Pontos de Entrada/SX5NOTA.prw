/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 08/06/2018 | Ajuste na sele��o das s�ries. Chamado 14156
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich  | 27/06/2019 | Ajuste para loboguara - Chamado 29782
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/08/2020 | Ajuste na sele��o das s�ries. Chamado 33714
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa--------: SX5NOTA
Autor-----------: Alexandre Villar
Data da Criacao-: 13/05/2014
===============================================================================================================================
Descri��o-------: Ponto de entrada que valida as s�ries que ser�o habilitadas para cada tipo de emiss�o de documento fiscal
					Chamado: 6168 / 6224 - Melhorias no controle de s�ries de documentos
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: lRet -> L�digo -> .T./.F. - Considera/N�o considera a s�rie da nota fiscal na gera��o.
===============================================================================================================================
*/
User Function SX5NOTA()

Local _aSeries	:= {}
Local _lRet		:= .F.
Local _nI 		:= 0
Local _cFunName := FunName()
//===========================================================================
//| Verifica o par�metro que ser� utilizado para valida��o.                 |
//===========================================================================
Do Case
	Case _cFunName $ "MATA103"
		_aSeries := StrToKArr(SuperGetMV("IT_SERDENT",,"2"),";")
	Case _cFunName $ "U_MGLT009"
		_aSeries := StrToKArr(SuperGetMV("IT_SERDLEI",,"3"),";")
	Case _cFunName $ "MATA460/MATA460A/MATA460B/MATA461/MATA461A/MATA461B"
		_aSeries := StrToKArr(SuperGetMV("IT_SERDSAI",,"1"),";")
	Case _cFunName == "SPEDMDFE"
		_aSeries := StrToKArr(SuperGetMV("IT_SERDMDF",,"001"),";")
	Case _cFunName == "MFIS006"
		_aSeries := StrToKArr(SuperGetMV("IT_SERAJU",,"1"),";")
EndCase

//===========================================================================
//Carrega SX5 via query para n�o conflitar com sonarcube
//===========================================================================
_nrec := SX5->(Recno())

_cQuery := " SELECT X5_CHAVE CHAVE "
_cQuery += " FROM " + RetSqlName("SX5")
_cQuery += " WHERE D_E_L_E_T_ <> '*'"
_cQuery += " AND   R_E_C_N_O_ = " + Alltrim(STR(_nrec)) + " "
	
TcQuery _cQuery New Alias "QRY"

_cchave := QRY->CHAVE

QRY->(Dbclosearea())

//===========================================================================
//| Verifica se a S�rie est� configurada para a rotina atual.               |
//===========================================================================
For _nI := 1 To Len(_aSeries)
	If AllTrim(_cchave) == _aSeries[_nI]
		_lRet := .T.
		Exit
	EndIf
Next _nI

Return( _lRet )
