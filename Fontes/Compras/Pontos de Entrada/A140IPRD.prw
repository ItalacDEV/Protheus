/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2018 | Corrigido tratamento para c�digos com ponto (.). Chamado 26488
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 20/04/2022 | Tratamento para XMLs com c�digo do produto min�sculo. Chamado 39844
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 08/04/2024 | Retirado tratamento para a SA5 pois o padr�o trata o cen�rio. Chamado 46875
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"
/*
===============================================================================================================================
Programa----------: A140IPRD
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 14/11/2014
===============================================================================================================================
Descri��o---------: O Ponto de Entrada A140IPRD � utilizado para manipular produto que ser� importado na NF-e. Usado quando 
					existem v�rios c�digos do fornecedor para o mesmo produto no Protheus.
===============================================================================================================================
Parametros--------: cCodigo: Caracter, C�digo do fornecedor/cliente.
					cLoja: Caracter, C�digo da loja do fornecedor/cliente.
					cPrdXML: Caracter, C�digo do produto contido no arquivo xml.
					oDetItem: Objeto, Objeto contendo a Tag principal: InfNFE /subtag det nItem com os n�s referente ao item 
						posicionado no XML recebido de acordo com o Manual de Orienta��o ao Contribuinte da NFe.
					cAlias: Caracter, C�digo da tabela "SA5" ou "SA7" para identificar se o c�digo que est� vindo como par�metro
						� de um fornecedor ou de um cliente para os casos de notas do tipo devolu��o e beneficiamento.
===============================================================================================================================
Retorno-----------: cPrdNew: Caracter, Retorna o c�digo do produto da tabela SB1
===============================================================================================================================
*/
User Function A140IPRD()

Local _cCodFor	:= PARAMIXB[1]
Local _cLoja	:= PARAMIXB[2]
Local _cPrdXML	:= PARAMIXB[3]
Local _aTab		:= {}
Local _cQuery	:= ''
Local _cRet		:= ''
Local _cAlias	:= GetNextAlias()


aAdd(_aTab,{PARAMIXB[5],SUBSTR(PARAMIXB[5],2,2),IIF(PARAMIXB[5]=="SA5","A5_FORNECE","A7_CLIENTE"),IIF(PARAMIXB[5]=="SA5","A5_CODPRF","A7_CODCLI") })

_cQuery := " SELECT "
_cQuery += "     " + _aTab[1][2]+"_PRODUTO	PRODUTO, "
_cQuery += "     " + _aTab[1][2]+"_I_CDPRX	PRODALT"
_cQuery += " FROM "+ RetSqlName(_aTab[1][1])
_cQuery += " WHERE "
_cQuery += "     D_E_L_E_T_ = ' ' "
_cQuery += " AND "+_aTab[1][2]+"_FILIAL  = '"+ xFilial(_aTab[1][1])	+"' "
_cQuery += " AND "+_aTab[1][3]+" = '"+ _cCodFor			+"' "
_cQuery += " AND "+_aTab[1][2]+"_LOJA    = '"+ _cLoja  			+"' "
_cQuery += " AND REPLACE(UPPER("+_aTab[1][4]+"),' ','') = '"+ _cPrdXML			+"' "

DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery ) , _cAlias , .T. , .F. )

_cRet:= (_cAlias)->PRODUTO

(_cAlias)->( DBCloseArea() )

If Empty(_cRet) .And. ParamIXB[5] == "SA7"
	_cPrdXML	:= Upper(StrTran(StrTran(PARAMIXB[3]," "),".","\."))	
	_cAlias	:= GetNextAlias()
	
	_cQuery := " SELECT "
	_cQuery += "     " + _aTab[1][2]+"_PRODUTO	PRODUTO, "
	_cQuery += "     " + _aTab[1][2]+"_I_CDPRX	PRODALT"
	_cQuery += " FROM "+ RetSqlName(_aTab[1][1])
	_cQuery += " WHERE "
	_cQuery += "     D_E_L_E_T_ = ' ' "
	_cQuery += " AND "+_aTab[1][2]+"_FILIAL  = '"+ xFilial(_aTab[1][1])	+"' "
	_cQuery += " AND "+_aTab[1][3]+" = '"+ _cCodFor			+"' "
	_cQuery += " AND "+_aTab[1][2]+"_LOJA    = '"+ _cLoja  			+"' "
	_cQuery += " AND REGEXP_LIKE(REPLACE(UPPER("+_aTab[1][2]+"_I_CDPRX),' ',''),'^(" + _cPrdXML + ")|([a-zA-Z0-9]/(" + _cPrdXML + "))')"
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery ) , _cAlias , .T. , .F. )

	_cRet := (_cAlias)->PRODUTO

	(_cAlias)->( DBCloseArea() )
EndIf

Return( _cRet )
