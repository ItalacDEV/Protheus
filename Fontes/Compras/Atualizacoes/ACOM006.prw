/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |17/10/2019| Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
Lucas Borges  |11/03/2022| Inclu�do tratamento para Z-Plataformas. Chamado 39460
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada est�tica no nome das tabelas do sistema
===============================================================================================================================
*/

#include "protheus.ch"






/*
===============================================================================================================================
Programa----------: ACOM006
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008                                    .
Descri��o---------: Codifica��o do Cadastro de Fornecedores - C�digo da Loja
Parametros--------: _pcCGC    = Devera ser passado o conteudo do campo A2_CGC.
                    cCodigo   = Devera ser passado o conteudo do campo A2_COD.
                    cClass    = Devera ser passado o conteudo do campo A2_I_CLASS.
Retorno-----------: _cRet     = C�digo que dever� ser gravado no campo A2_LOJA.
===============================================================================================================================
*/
User Function ACOM006( _pcCNPJ , cCodigo , cClass )

Local _aArea := GetArea()
Local _cQuery := ""

Local _cRetorno := ""

If cClass $ 'P/Z'

	If Len(Alltrim(_pcCNPJ)) > 10

		_cQuery := " SELECT MAX(A2_LOJA) AS LOJA "
		_cQuery += " FROM " + RetSqlName("SA2")
		_cQuery += " WHERE D_E_L_E_T_ = ' '"
		_cQuery += " AND   A2_COD = '" + Alltrim(cCodigo) +"' "
		_cQuery := ChangeQuery(_cQuery)
		MPSysOpenQuery(_cQuery,"QRY")
		
		QRY->(dbGotop())
		_cRetorno := StrZero(Val(QRY->LOJA)+1,4)
		QRY->(dbCloseArea())
	EndIF    

Else

	If Len(Alltrim(_pcCNPJ)) > 11  
		
		_cRetorno := SubStr(_pcCNPJ,9,4) 
		
	Else
		
		_cQuery := " SELECT MAX(A2_LOJA) AS LOJA "
		_cQuery += " FROM " + RetSqlName("SA2")
		_cQuery += " WHERE D_E_L_E_T_ = ' '"
		_cQuery += " AND   A2_COD = '" + Alltrim(cCodigo) +"' "
		_cQuery := ChangeQuery(_cQuery)
		MPSysOpenQuery(_cQuery,"QRY")
		
		QRY->(dbGotop())
		_cRetorno := StrZero(Val(QRY->LOJA)+1,4)
		QRY->(dbCloseArea())

	EndIf

EndIf
 
If !MayIUseCode( "A2_COD"+ xFilial("SA2") + cCodigo + _cRetorno )  //verifica se esta na memoria, sendo usado
	MSGSTOP("C�digo "+ cCodigo + " loja " + _cRetorno + " j� est� sendo utilizado. Contacte o administrador do sistema." )
	Return .f.
EndIf                

//======================================================================
// Grava log de acesso a rotina Cadastro de Fornecedores. 
// Gera��o do c�digo da loja do fornecedor.
//====================================================================== 
U_ITLOGACS('ACOM006')




RestArea(_aArea)  

Return(_cRetorno)
