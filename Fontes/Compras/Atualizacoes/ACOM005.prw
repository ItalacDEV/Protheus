/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     |17/07/2017| Chamado 20777. Virada de vers�o da P11 para a vers�o P12. Ajustes no fonte para a vers�o P12
Lucas Borges  |11/03/2022| Chamado 39460. Inclu�do tratamento para Z-Plataformas
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada est�tica no nome das tabelas do sistema
===============================================================================================================================
*/

#Include "protheus.ch"

/*
===============================================================================================================================
Programa----------: ACOM005
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008                                  .
Descri��o---------: Codifica��o do Cadastro de Fornecedores
Parametros--------: _pcClasse = Devera ser passado o conteudo do campo A2_I_CLASS.
                    _pcTipo   = Devera ser passado o conteudo do campo A2_TIPO.
                    _pcCGC    = Devera ser passado o conteudo do campo A2_CGC.
Retorno-----------: _cRet     = C�digo que dever� ser gravado no campo A2_COD.
===============================================================================================================================
*/
User Function ACOM005( _pcClasse , _pcTipo , _pcCGC )

Local _aArea    := GetArea()
Local _cAlias	:= GetNextAlias()
Local _cQuery   := ""
Local _cCodigo  := ""

Local _lNew		:= .F.
Local _lTemCod	:= .F.

_cQuery := " SELECT DISTINCT A2_COD AS CODIGO "
_cQuery += " FROM  "+ RetSqlName("SA2") +" SA2 "
_cQuery += " WHERE "+ RetSqlCond("SA2")

If Alltrim(_pcTipo) == "J" .And. _pcClasse == 'Z'
	_cQuery += " AND LTrim(RTrim(A2_CGC)) = '"+ Alltrim(_pcCGC) +"' AND A2_TIPO = 'J'"
ElseIf Alltrim(_pcTipo) == "J"
	_cQuery += " AND SUBSTR( A2_CGC , 1 , 8 ) = '"+ Left( _pcCGC , 8 ) +"' AND A2_TIPO = 'J' "
Else
	_cQuery += " AND LTrim(RTrim(A2_CGC)) = '"+ Alltrim(_pcCGC) +"' AND A2_TIPO = 'F'"
EndIf

_cQuery := ChangeQuery(_cQuery)
MPSysOpenQuery(_cQuery,_cAlias)

(_cAlias)->( DBGotop() )
If (_cAlias)->( !Eof() )

	While (_cAlias)->( !Eof() )
		
		If !Empty( (_cAlias)->CODIGO )
		
			If SubStr( (_cAlias)->CODIGO , 1 , 1 ) == AllTrim( _pcClasse ) // validar se ja existe codigo para a classe
				_cCodigo := (_cAlias)->CODIGO
			EndIf
			
			_lTemCod := .T.
			
		EndIf
		
	(_cAlias)->( DBSkip() )
	EndDo
	
	If _lTemCod .And. Empty(_cCodigo)
	
		If MsgYesNo(	" Este "+ iif(Alltrim(_pcTipo)=="J","CNPF","CPF") +'/'+ AllTrim(_pcCGC) +" ja foi cadastrado para um fornecedor, "	+;
						" porem este fornecedor possui outra classe." + Chr(13) + Chr(10)													+;
						" Se deseja criar este fornecedor utilizando a nova classe, tecle SIM. Caso contrario, se desejar manter"			+;
						" a mesma codifica��o utilizada na outra classe, tecle N�O.", "Codifica��o de Fornecedor"							 )
			
			_lNew := .T.
		
		EndIf
	
	Else
	
		_lNew := !_lTemCod
	
	EndIf

Else

	_lNew := .T.
	
EndIf

(_cAlias)->( DBCloseArea() )

If _lNew

	_cQuery := " SELECT MAX(SA2.A2_COD) AS CODIGO "
	_cQuery += " FROM  "+ RetSqlName("SA2") +" SA2 "
	_cQuery += " WHERE "+ RetSqlCond("SA2")
	_cQuery += " AND SUBSTR( SA2.A2_COD , 1 , 1 ) = '"+ Alltrim(_pcClasse) +"' "
	_cQuery := ChangeQuery(_cQuery)
	MPSysOpenQuery(_cQuery,_cAlias)
	
	(_cAlias)->( DBGotop() )
	
	_cCodigo := Alltrim(_pcClasse) + soma1(   Right( (_cAlias)->CODIGO , 5 )  )  
	
	(_cAlias)->( DBCloseArea() )

EndIf

While !MayIUseCode( "A2_COD"+ xFilial("SA2") + _cCodigo )	// verifica se esta na memoria, sendo usado
	_cCodigo := Alltrim(_pcClasse) + soma1(   Right( _cCodigo , 5 )  )  							// busca o proximo numero disponivel
EndDo

//======================================================================
// Grava log de acesso a rotina Cadastro de Fornecedores. 
// Gera��o do c�digo do fornecedor.
//====================================================================== 
U_ITLOGACS('ACOM005')

RestArea(_aArea)

Return(_cCodigo)
