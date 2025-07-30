/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 15/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"

/*
===============================================================================================================================
Programa--------: AOMS007
Autor-----------: Frederico O. C. Jr
Data da Criacao-: 29/07/2008
===============================================================================================================================
Descri��o-------: Cadastro de CEP
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS007()

	Local cAlias		:= "ZA5"
	Private cCadastro	:= "Cadastro de CEP"
	Private aRotina		:= {}                

	AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"		,"U_ValZA5",0,5})
	
	dbSelectArea(cAlias)
	dbSetOrder(1)
	mBrowse(6,1,22,75,cAlias)

return

/*
===============================================================================================================================
Programa--------: ValZA5
Autor-----------: Frederico O. C. Jr
Data da Criacao-: 21/07/2008
===============================================================================================================================
Descri��o-------: Validacao Exclusao ZA5
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ValZA5(cAlias,nReg,nOpc)

	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	
	Local aExist	:= {}
	Local oDlg
	Local oLbx
	
	Local cEst		:= ZA5->ZA5_UF
	Local cCEP		:= ZA5->ZA5_CEP
	Local cQuery	:= ""
	
	cQuery := " SELECT 'CADASTRO DE BANCO' AS TABELA, COUNT(A6_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("SA6")
	cQuery += " WHERE A6_EST = '" + cEst + "' AND A6_CEP = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	cQuery += " UNION ALL"
	
	cQuery += " SELECT 'CADASTRO DE CENTRO DE CUSTO' AS TABELA, COUNT(CTT_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("CTT")
	cQuery += " WHERE CTT_ESTADO = '" + cEst + "' AND CTT_CEP = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	cQuery += " UNION ALL"
	
	cQuery += " SELECT 'CADASTRO DE FUNCIONARIO' AS TABELA, COUNT(RA_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("SRA")
	cQuery += " WHERE RA_ESTADO = '" + cEst + "' AND RA_CEP = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	cQuery += " UNION ALL"
	
	cQuery += " SELECT 'CADASTRO DE USUARIO P.P.P.' AS TABELA, COUNT(TMK_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("TMK")
	cQuery += " WHERE TMK_I_EST = '" + cEst + "' AND TMK_I_C = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	cQuery += " UNION ALL"
	
	cQuery += " SELECT 'CADASTRO DE FORNECEDOR' AS TABELA, COUNT(A2_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("SA2")
	cQuery += " WHERE A2_EST = '" + cEst + "' AND A2_CEP = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	cQuery += " UNION ALL"
	
	cQuery += " SELECT 'CADASTRO DE CLIENTE' AS TABELA, COUNT(A1_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("SA1")
	cQuery += " WHERE A1_EST = '" + cEst + "' AND A1_CEP = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	cQuery += " UNION ALL"
	
	cQuery += " SELECT 'CADASTRO DE CLIENTE (COBRANCA)' AS TABELA, COUNT(A1_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("SA1")
	cQuery += " WHERE A1_ESTC = '" + cEst + "' AND A1_CEPC = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	cQuery += " UNION ALL"
	
	cQuery += " SELECT 'CADASTRO DE CLIENTE (ENTREGA)' AS TABELA, COUNT(A1_FILIAL) AS CONT"
	cQuery += " FROM " + RetSqlName("SA1")
	cQuery += " WHERE A1_ESTE = '" + cEst + "' AND A1_CEPE = '" + cCEP + "' AND D_E_L_E_T_ = ' '"
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .T., .F. )
	dbSelectArea("TEMP")

	while !eof()
		
		if (TEMP->CONT > 0)
			aAdd ( aExist, {TEMP->TABELA, TEMP->CONT} )
			lRet := .F.
		endif
	    
		dbSkip()
	end

	TEMP->(dbCloseArea())
	
	if (!lRet)

		DEFINE MSDIALOG oDlg TITLE "AMARRA��ES DA TABELA DE CEP:" FROM 0,0 TO 240,500 PIXEL		
		@ 10,10 LISTBOX oLbx FIELDS HEADER "Tabela", "Quant." SIZE 230,95 OF oDlg PIXEL
		
		oLbx:SetArray( aExist )
		oLbx:bLine := {|| aEval(aExist[oLbx:nAt],{|z,w| aExist[oLbx:nAt,w] } ) }
		
		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
		
	else
		AxDeleta(cAlias,nReg,nOpc)
	endif
	
	RestArea(aArea)
	
return lRet