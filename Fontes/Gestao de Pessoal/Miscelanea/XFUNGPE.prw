/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich  | 04/04/2016 | Ajuste na gera��o de verba de empr�stimo  - Rotina ITParcel - Chamado 14967
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/03/2019 | Ajustes/Adapta��es para vers�o Lobo Guara. Chamado 28571
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 18/09/2019 | Revis�o do fonte, substitui��o da AGPE004 por VAltSal e retirada de fun��oes. Chamado 28346 
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#Include "Protheus.ch"
#Include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: XFUNGPE
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 21/05/2009
===============================================================================================================================
Descri��o---------: Rotinas gen�ricas para utiliza��o nos desenvolvimentos do m�dulo GPE
===============================================================================================================================
*/

/*
===============================================================================================================================
Programa--------: ITMedOdo
Autor-----------: Alexandre Villar
Data da Criacao-: 28/02/2014
===============================================================================================================================
Descri��o-------: Consulta Assistencia Medica/Odontologica para tela de Integracao Funcionarios x PLS
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ITMedOdo( cTipFor , cCodFor , cTipPla , lValid , cCodAux )

Local cQuery	:= ""
Local cCons		:= ""
Local cPosCod	:= ""
Local _cAlias	:= GetNextAlias()
Local cAliasAux	:= GetNextAlias()
Local lRet		:= .T.
Local nPosIni	:= 0
Local nRetorno	:= 0

Default lValid	:= .F.
Default cCodAux	:= ""

If cTipFor == 1 .and. cTipPla == 1		//Assistencia Medica - Faixa Salarial
	cCons := "S008"
ElseIf cTipFor == 1 .and. cTipPla == 2	//Assistencia Medica - Faixa Etaria
	cCons := "S009"
ElseIf cTipFor == 1 .and. cTipPla == 3 //Assistencia Medica - Valor Fixo
	cCons := "S028"
ElseIf cTipFor == 1 .and. cTipPla == 4 //Assistencia Medica - % Valor Salario
	cCons := "S029"
ElseIf cTipFor == 2 .and. cTipPla == 1	//Assistencia Odontologica - Faixa Salarial
	cCons := "S013"
Elseif cTipFor == 2 .and. cTipPla == 2	//Assistencia Odontologica - Faixa Etaria 
	cCons := "S014"
ElseIf cTipFor == 2 .and. cTipPla == 3	//Assistencia Odontologica - Valor Fixo
	cCons := "S030"
ElseIf cTipFor == 2 .and. cTipPla == 4	//Assistencia Odontologica - % Valor Salario
	cCons := "S031"
EndIf

If !EMPTY(cCons)
	BeginSql alias _cAlias
		SELECT RCB_ORDEM POSINI
		  FROM %Table:RCB%
		 WHERE D_E_L_E_T_ = ' '
		   AND RCB_FILIAL = %xFilial:RCB%
		   AND RCB_CODIGO = %exp:cCons%
		   AND RCB_CAMPOS = 'CODFOR'
	EndSql		

	If (_cAlias)->(!EOf())
		cPosCod := (_cAlias)->POSINI
	EndIf
	(_cAlias)->(DBCloseArea())
	_cAlias := GetNextAlias()
	
	BeginSql alias _cAlias
		SELECT SUM(RCB_TAMAN) + 1 POSINI
		  FROM %Table:RCB%
		 WHERE D_E_L_E_T_ = ' '
		   AND RCB_FILIAL = %xFilial:RCB%
		   AND RCB_CODIGO = %exp:cCons%
		   AND RCB_ORDEM < %exp:cPosCod%
	EndSql
	
	If (_cAlias)->(!EOf())
		nPosIni := (_cAlias)->POSINI
	EndIf
	(_cAlias)->(DBCloseArea())

EndIf

If nPosIni > 0
	
	cQuery := " SELECT "
	cQuery += "     SUBSTR( RCC_CONTEU , 1 , 02 )	AS CODIGO, "
	cQuery += "     SUBSTR( RCC_CONTEU , 3 , 20 )	AS DESCRI, "
	cQuery += "		R_E_C_N_O_						AS REGRCC
	cQuery += " FROM "+ RetSqlName("RCC")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND RCC_FILIAL = '"+ xFilial("RCC") +"'
	cQuery += " AND SUBSTR( RCC_CONTEU , "+ AllTrim(Str(nPosIni)) +" , 3 ) = '"+ cCodFor +"' "
	
	If lValid
		
		If Select(cAliasAux) > 0
			(cAliasAux)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery) , cAliasAux , .F. , .T. )
		
		lRet := .F.
		
		DBSelectArea(cAliasAux)
		(cAliasAux)->( DBGoTop() )
		While (cAliasAux)->(!Eof())
			If AllTrim( (cAliasAux)->CODIGO ) == AllTrim( cCodAux )
				lRet := .T.
				Exit
			EndIf
			(cAliasAux)->( DBSkip() )
		EndDo
		
	Else
	
		//-- Tela de Consulta Padrao a partir do resultado da Query --//
		If Tk510F3Qry( cQuery/*cQuery*/,"RCC002"/*cCodCon*/,"REGRCC"/*cCpoRecno*/,@nRetorno/*nRetorno*/,/*aCoord*/,/*aSearch*/,"RCC"/*cAlias*/)
			DBSELECTAREA("RCC")
			RCC->( DBGOTO( nRetorno ) )
		EndIf
	
	EndIf
	
EndIf

Return( lRet )

/*
===============================================================================================================================
Programa----------: VAltSal
Autor-------------: Heder Jose Andrade
Data da Criacao---: 04/01/2010
===============================================================================================================================
Descri��o---------: Valida��o do usu�rio para altera��o do sal�rio de Funcion�rios
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico : retorna se o usu�rio tem permiss�o para alterar o sal�rio de Funcion�rios
===============================================================================================================================
*/
User Function VAltSal

Local _aArea 	:= GetArea()
Local _lRet		:= .T.

If Altera .And. Posicione("ZZL",3,xFilial("ZZL")+RetCodUsr(),"ZZL_ALTSA") <> 'S'
	_lRet := .F.
	MsgStop("O usu�rio n�o esta liberado para alterar o sal�rio dos Funcion�rios!","XFUNGPE001")
EndIf

RestArea( _aArea )

Return( _lRet )