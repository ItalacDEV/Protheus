/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich      | 10/10/2018 | Zera porcentual de comissão para sup/coord/ger conflitante - Chamado 26437     
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich      | 27/02/2019 | Bloqueia regras de comissão se o vendedor é bloqueado - Chamado 28112      
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 21/01/2021 | Inclusão das comissões do novo Gerente Nacional. Chamado 35183.  
------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 17/12/2021 | Inclusão de logs para registrar a inclusão, alteração e exclusão de Vendedores. Chamado 35404
------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 21/12/2021 | Acerto do SELECT da comissao do gerente nacional . Chamado 34402
------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 19/09/2023 | Inclusão RestArea() após POSICIONE (Gerente) que desposionava o registro
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Antônio  - Julio Paz     - 11/02/25 - 12/02/25 - 49868   - Ajustar as validações do cadastro de Vendedores/supervisores/coordenadores/gerentes/gerente nacional. Para gerente nacional permitir os campos coordenadores e gerentes vazios.
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"
#Include "TopConn.ch"

Static _aLogSA3 := {}

/*
===============================================================================================================================
Programa----------: MA040TOK
Autor-------------: Talita Teixeira
Data da Criacao---: 08/07/2013
===============================================================================================================================
Descrição---------: P.E. na validação do cadastro de Vendedores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Lógico (.T./.F.) para definir se o registro pode ser gravado
===============================================================================================================================
*/
User Function MA040TOK

Local _aArea   	:= GetArea()
Local _lRet		:= .T.
Local _lSqlOk	:= .T.

Local _cCod		:= M->A3_COD
Local _cCodSup	:= M->A3_SUPER
Local _cCodGer	:= M->A3_GEREN
Local _cCodSui	:= M->A3_I_SUPE
Local _cTipVen	:= M->A3_I_TIPV
Local _cCodGNac := M->A3_I_GERNC

Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()

//Se não veio do tudook já retorna .T.
If !(isincallstack("A040TUDOOK"))
	Return .T.
Endif

//=========================================================================================
// Valida a região. 
//=========================================================================================
If _lret .and. M->A3_I_REG == "BR" .and. M->A3_I_TIPV <> "N"
	U_ITMSG("A área de atuação Brasil é exclusiva para o tipo de vendedor Gerente Nacional!","Atenção","Escolha uma área de atuação diferente de Brasil para o vendedor, supervisor, coordenador e Gerente.",1)
	_lret := .F.
Endif

//=========================================================================================
//Validação de campos supervisor, coordenador, gerente e gerente nacional preenchidos    
//=========================================================================================
If _lret .and. EMPTY(M->A3_SUPER) .and. M->A3_I_TIPV != 'C' .and. M->A3_I_TIPV != 'G' .and. M->A3_I_TIPV != 'N' 
	U_ITMSG("Coordenador não preenchido!","Atenção","Escolha um código para o coordenador",1) 
	_lret := .F.
Endif

If _lret .and. EMPTY(M->A3_GEREN) .and. M->A3_I_TIPV != 'G' .and. M->A3_I_TIPV != 'N' 
	U_ITMSG("Gerente não preenchido!","Atenção","Escolha um código para o gerente",1) 
	_lret := .F.
Endif

If _lret .and. EMPTY(M->A3_I_GERNC) .and. M->A3_I_TIPV != 'N'  
	U_ITMSG("Gerente Nacional não preenchido!","Atenção","Escolha um código para o gerente nacional.",1)
	_lret := .F.
Endif

//====================================================================================================
// Validação de campos supervisor, coordenador, gerente e gerente nacional incorretamente preenchidos
//====================================================================================================
If _lret .and. !EMPTY(M->A3_SUPER) .and. ( M->A3_I_TIPV == 'C' .or. M->A3_I_TIPV == 'G')
	U_ITMSG("Coordenador preenchido!","Atenção","Deixe coordenador vazio para vendedor tipo coordenador e gerente",1)
	_lret := .F.
Endif
If _lret .and. !EMPTY(M->A3_I_SUPE) .and. ( M->A3_I_TIPV == 'S' .or. M->A3_I_TIPV == 'C' .or. M->A3_I_TIPV == 'G')
	U_ITMSG("Supervisor preenchido!","Atenção","Deixe supervisor vazio para vendedor tipo supervisor/coordenador/gerente",1)
	_lret := .F.
Endif
If _lret .and. !EMPTY(M->A3_GEREN) .and. M->A3_I_TIPV = 'G' 
	U_ITMSG("Gerente preenchido!","Atenção","Deixe gerente vazio para vendedor tipo gerente",1)
	_lret := .F.
Endif

If _lret .and. !EMPTY(M->A3_I_GERNC) .and. M->A3_I_TIPV = 'N' 
	U_ITMSG("Gerente Nacional preenchido!","Atenção","Deixe gerente nacional vazio para vendedor tipo gerente nacional.",1)
	_lret := .F.
Endif

//=============================================================================================================
//Validação de campos supervisor, coordenador, gerente e gerente nacional diferentes do campo do vendedor
// e entre si
//=============================================================================================================
If _lret .and. M->A3_SUPER == M->A3_COD .and. !EMPTY(M->A3_SUPER)
	U_ITMSG("Coordenador não pode ter o mesmo código do vendedor!","Atenção","Escolha um código diferente para o coordenador",1)
	_lret := .F.
Endif
If _lret .and. M->A3_I_SUPE == M->A3_COD .and. !EMPTY(M->A3_I_SUPE)
	U_ITMSG("Supervisor não pode ter o mesmo código do vendedor!","Atenção","Escolha um código diferente para o Supervisor",1)
	_lret := .F.
Endif
If _lret .and. M->A3_GEREN == M->A3_COD .and. !EMPTY(M->A3_GEREN)
	U_ITMSG("Gerente não pode ter o mesmo código do vendedor!","Atenção","Escolha um código diferente para o gerente",1)
	_lret := .F.
Endif

If _lret .and. M->A3_I_GERNC == M->A3_COD .and. !EMPTY(M->A3_I_GERNC)
	U_ITMSG("Gerente Nacional não pode ter o mesmo código do vendedor!","Atenção","Escolha um código diferente para o gerente nacional.",1)
	_lret := .F.
Endif

If _lret .and. M->A3_I_SUPE == M->A3_GEREN .and. !EMPTY(M->A3_I_SUPE)
	U_ITMSG("Supervisor não pode ter o mesmo código do gerente!","Atenção","Escolha um código diferente para o Supervisor ou gerente",1)
	_lret := .F.
Endif
If _lret .and. M->A3_SUPER == M->A3_GEREN .and. !EMPTY(M->A3_SUPER)
	U_ITMSG("Coordenador não pode ter o mesmo código do gerente!","Atenção","Escolha um código diferente para o coordenador ou gerente",1)
	_lret := .F.
Endif
If _lret .and. M->A3_SUPER == M->A3_I_SUPE .and. !EMPTY(M->A3_I_SUPE)
	U_ITMSG("Coordenador não pode ter o mesmo código do Supervisor!","Atenção","Escolha um código diferente para o coordenador ou supervisor",1)
	_lret := .F.
Endif

If _lret .and. M->A3_I_SUPE == M->A3_I_GERNC .and. !EMPTY(M->A3_I_SUPE)
	U_ITMSG("Supervisor não pode ter o mesmo código do gerente nacional!","Atenção","Escolha um código diferente para o Supervisor ou gerente nacioanl.",1)
	_lret := .F.
Endif
If _lret .and. M->A3_SUPER == M->A3_I_GERNC .and. !EMPTY(M->A3_SUPER)
	U_ITMSG("Coordenador não pode ter o mesmo código do gerente nacional!","Atenção","Escolha um código diferente para o coordenador ou gerente nacional.",1)
	_lret := .F.
Endif
If _lret .and. M->A3_I_GERNC == M->A3_GEREN .and. !EMPTY(M->A3_I_GERN)
	U_ITMSG("Gerente não pode ter o mesmo código do Gerente nacioanl!","Atenção","Escolha um código diferente para o gerente ou gerente nacioanal.",1)
	_lret := .F.
Endif

//=========================================================================================
//Validação de campos supervisor, coordenador e gerente com tipo correto
//=========================================================================================
If _lret .and. !EMPTY(M->A3_SUPER) .and. posicione("SA3",1,xfilial("SA3")+M->A3_SUPER,"A3_I_TIPV") != "C"
	U_ITMSG("Coordenador indicou um código de vendedor com tipo diferente de coordenador!","Atenção","Escolha um código de coordenador",1)
	_lret := .F.
Endif
If _lret .and. !EMPTY(M->A3_I_SUPE) .and. posicione("SA3",1,xfilial("SA3")+M->A3_I_SUPE,"A3_I_TIPV") != "S"
	U_ITMSG("Supervisor indicou um código de vendedor com tipo diferente de supervisor!","Atenção","Escolha um código de Supervisor",1)
	_lret := .F.
Endif
If _lret .and. !EMPTY(M->A3_GEREN) .and. posicione("SA3",1,xfilial("SA3")+M->A3_GEREN,"A3_I_TIPV") != "G"
	U_ITMSG("Gerente indicou um código de vendedor com tipo diferente de gerente!","Atenção","Escolha um código de gerente",1)
	_lret := .F.
Endif

If _lret .and. !EMPTY(M->A3_I_GERNC) .and. Posicione("SA3",1,xfilial("SA3")+M->A3_I_GERNC,"A3_I_TIPV") != "N"
	U_ITMSG("Gerente nacional indicou um código de vendedor com tipo diferente de gerente nacional!","Atenção","Escolha um código de gerente nacional.",1)
	_lret := .F.
Endif

RestArea(_aArea)
//=========================================================================================
//Validação de campo tipo em relação à outros cadastros
//=========================================================================================
If _lret 

		_cQuery := " SELECT A3_COD,A3_NOME,A3_SUPER,A3_GEREN,A3_I_SUPE, A3_I_GERNC " 
		_cQuery += " FROM  "+ RetSqlName("SA3") +" SA3 "
		_cQuery += " WHERE "
		_cQuery += "     SA3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND (  SA3.A3_SUPER   = '"+ _cCod +"' "
		_cQuery += "     OR SA3.A3_I_SUPE  = '"+ _cCod +"' "
		_cQuery += "     OR SA3.A3_GEREN   = '"+ _cCod +"' "
		_cQuery += "     OR SA3.A3_I_GERNC = '"+ _cCod +"' ) " 

		If Select(_cAlias) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf

		DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

		DBSelectArea(_cAlias)
		(_cAlias)->( DBGoTop() )

		_alist := {}
		_cmens := ""

		Do while (_cAlias)->( !Eof() ) 
	
			//Analise para cadastro de vendedor
			If _cTipVen == 'V'
			
				If alltrim((_cAlias)->A3_I_SUPE) == alltrim(_cCod)
					aadd(_alist,{"Consta como supervisor do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como vendedor pois já consta como supervisor/coordenador/gerente de outros vendedores!"
					_lret := .F.
				Endif
				If alltrim((_cAlias)->A3_SUPER) == alltrim(_cCod)
					aadd(_alist,{"Consta como coordenador do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como vendedor pois já consta como supervisor/coordenador/gerente de outros vendedores!"
					_lret := .F.
				Endif
				If alltrim((_cAlias)->A3_GEREN) == alltrim(_cCod)
					aadd(_alist,{"Consta como gerente do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como vendedor pois já consta como supervisor/coordenador/gerente de outros vendedores!"
					_lret := .F.
				Endif
			    
				If alltrim((_cAlias)->A3_I_GERNC) == alltrim(_cCod) 
					aadd(_alist,{"Consta como gerente nacional do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como vendedor pois já consta como supervisor/coordenador/gerente/gerente nacional de outros vendedores!"
					_lret := .F.
				Endif

			Endif
			
			//Analise para cadastro de supervisor
			If _cTipVen == 'S'
		
				If alltrim((_cAlias)->A3_SUPER) == alltrim(_cCod)
					aadd(_alist,{"Consta como coordenador do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como supervisor pois já consta como coordenador/gerente de outros vendedores!"
					_lret := .F.
				Endif
				If alltrim((_cAlias)->A3_GEREN) == alltrim(_cCod)
					aadd(_alist,{"Consta como gerente do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como supervisor pois já consta como coordenador/gerente de outros vendedores!"
					_lret := .F.
				Endif
			    
				If alltrim((_cAlias)->A3_I_GERNC) == alltrim(_cCod) 
					aadd(_alist,{"Consta como gerente nacional do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como supervisor pois já consta como coordenador/gerente/gerente nacional de outros vendedores!"
					_lret := .F.
				Endif
			Endif
			
			//Analise para cadastro de coordenador
			If _cTipVen == 'C'

				If alltrim((_cAlias)->A3_I_SUPE) == alltrim(_cCod)
					aadd(_alist,{"Consta como supervisor do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como coordenador pois já consta como supervisor/gerente de outros vendedores!"
					_lret := .F.
				Endif
				If alltrim((_cAlias)->A3_GEREN) == alltrim(_cCod)
					aadd(_alist,{"Consta como gerente do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como coordenador pois já consta como supervisor/gerente de outros vendedores!"
					_lret := .F.
				Endif

                If alltrim((_cAlias)->A3_I_GERNC) == alltrim(_cCod) 
					aadd(_alist,{"Consta como gerente nacional do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como coordenador pois já consta como supervisor/gerente/gerente nacional de outros vendedores!"
					_lret := .F.
				Endif

			Endif
			
			//Analise para cadastro de gerente
			If _cTipVen == 'G'
			
				If alltrim((_cAlias)->A3_I_SUPE) == alltrim(_cCod)
					aadd(_alist,{"Consta como supervisor do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como gerente pois já consta como supervisor/coordenador de outros vendedores!"
					_lret := .F.
				Endif
				If alltrim((_cAlias)->A3_SUPER) == alltrim(_cCod)
					aadd(_alist,{"Consta como coordenador do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como gerente pois já consta como supervisor/coordenador de outros vendedores!"
					_lret := .F.
				Endif
			    
				If alltrim((_cAlias)->A3_I_GERNC) == alltrim(_cCod) 
					aadd(_alist,{"Consta como gerente nacional do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como gerente pois já consta como supervisor/coordenador/gerente nacional de outros vendedores!"
					_lret := .F.
				Endif
			
			Endif
				
			//Analise para cadastro de gerente nacional
			If _cTipVen == 'N' 
			
				If alltrim((_cAlias)->A3_I_SUPE) == alltrim(_cCod)
					aadd(_alist,{"Consta como supervisor do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como gerente pois já consta como supervisor/coordenador de outros vendedores!"
					_lret := .F.
				Endif
				If alltrim((_cAlias)->A3_SUPER) == alltrim(_cCod)
					aadd(_alist,{"Consta como coordenador do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como gerente pois já consta como supervisor/coordenador de outros vendedores!"
					_lret := .F.
				Endif
			    
				If alltrim((_cAlias)->A3_GEREN) == alltrim(_cCod) 
					aadd(_alist,{"Consta como gerente do vendedor " + (_cAlias)->A3_COD + " - " + (_cAlias)->A3_NOME })
					_cmens := "Cadastro não pode ser definido como gerente pois já consta como supervisor/coordenador/gerente de outros vendedores!"
					_lret := .F.
				Endif
			
			Endif

			(_cAlias)->( Dbskip() ) 
			
		Enddo
		
		(_cAlias)->( DBCloseArea() )	
		
		If !_lret
			
			If len(_alist) > 0
			
				_aheader := {"Problemas"}
				U_ITListBox( _cmens , _aheader , _alist , .T. , 1 )

			Endif
			
		Endif
				
Endif

//=========================================================================================
//Validação de regras de comissão e bloqueio se necessário
//=========================================================================================
If _lRet 
	
	_cQuery := " SELECT "
	_cQuery += "     COUNT(1) AS CONT "
	_cQuery += " FROM  "+ RetSqlName('ZAE') +" ZAE "
	_cQuery += " WHERE "
	_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
	_cQuery += " AND ZAE.ZAE_VEND   = '"+ _cCod +"' "
	_cQuery += " AND ( ZAE.ZAE_CODSUP <> '"+ _cCodSup +"' OR ZAE.ZAE_CODGER <> '"+ _cCodGer +"' OR ZAE.ZAE_CODSUI <> '"+ _cCodSui +"' OR ZAE.ZAE_CODGNC <> '"+ _cCodGNac +"' ) " 

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If ((_cAlias)->( !Eof() ) .And. (_cAlias)->CONT > 0 ) .OR. M->A3_MSBLQL == '1'
		
		_cQuery := " UPDATE "+ RetSqlName('ZAE') +" ZAE "
		_cQuery += " SET ZAE.ZAE_MSBLQL = '1' "
		_cQuery += " WHERE "
		_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAE.ZAE_VEND   = '"+ _cCod +"' "
		
		_lSqlOk := !( TCSqlExec(_cQuery) < 0 )

/*		Alinhado com o Vanderson tava zerando somente atacado então deixa para zera os 2 na atualizacao da comissao

		//Zera porcentuais de supervisor conflitante
		_cQuery := " UPDATE "+ RetSqlName('ZAE') +" ZAE "
		_cQuery += " SET ZAE.ZAE_COMIS4 = 0 "
		_cQuery += " WHERE "
		_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAE.ZAE_VEND   = '"+ _cCod +"' "
		_cQuery += " AND ZAE.ZAE_CODSUI <> '"+ _cCodSui  +"' "
		
		_lSqlOk :=  _lSqlOk .and. !( TCSqlExec(_cQuery) < 0 )
		
		//Zera porcentuais de COORDENADOR conflitante
		_cQuery := " UPDATE "+ RetSqlName('ZAE') +" ZAE "
		_cQuery += " SET ZAE.ZAE_COMIS2 = 0 "
		_cQuery += " WHERE "
		_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAE.ZAE_VEND   = '"+ _cCod +"' "
		_cQuery += " AND ZAE.ZAE_CODSUP <> '"+ _cCodSup  +"' "
		
		_lSqlOk := !( TCSqlExec(_cQuery) < 0 )
		
		//Zera porcentuais de Gerente conflitante
		_cQuery := " UPDATE "+ RetSqlName('ZAE') +" ZAE "
		_cQuery += " SET ZAE.ZAE_COMIS3 = 0 "
		_cQuery += " WHERE "
		_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAE.ZAE_VEND   = '"+ _cCod +"' "
		_cQuery += " AND ZAE.ZAE_CODGER <> '"+ _cCodger  +"' "
		
		_lSqlOk := !( TCSqlExec(_cQuery) < 0 )

		//Zera porcentuais de Gerente Nacional conflitante 
		_cQuery := " UPDATE "+ RetSqlName('ZAE') +" ZAE "
		_cQuery += " SET ZAE.ZAE_COMIS5 = 0 "
		_cQuery += " WHERE "
		_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAE.ZAE_VEND   = '"+ _cCod +"' "
		_cQuery += " AND ZAE.ZAE_CODGNC <> '"+ _cCodGNac  +"' "
		
		_lSqlOk := !( TCSqlExec(_cQuery) < 0 )
*/
		If _lSqlOk
		
			u_itmsg('Foi identificado que o cadastro das Regras de Comissão do Vendedor ficou divergente com relação à nova configuração!' , "Atenção",;
					'O cadastro das Regras foi Bloqueado e deverá ser revisado para a Liberação do mesmo.' ,1)
				
		Else
		
			u_itmsg('Falha ao atualizar o cadastro das Regras de Comissão do Vendedor que ficou divergente com relação à nova configuração!' , "Atenção",;
					'O cadastro das Regras NÃO FOI BLOQUEADO e deverá ser revisado para permitir a gravação dessa alteração.' ,1)
					
			_lret := .F.
			
		EndIf
			
	EndIf

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
EndIf

If _lret 
   If Type("ALTERA") <> "U" .And. ALTERA
      //=============================================================================
      // Carrega array com os campos do cadastro de Vendedores antes das Alterações.
      //=============================================================================
      _aLogSA3 := U_ITIniLog("SA3")  

   ElseIf Type("EXCLUI") <> "U" .And. EXCLUI 
      //=============================================================================
      // Carrega array com os campos do cadastro de Vendedores antes das Alterações.
      //=============================================================================
      _aLogSA3 := U_ITIniLog("SA3")  
   EndIf  

EndIf 

RestArea(_aArea)

Return( _lRet )

/*
===============================================================================================================================
Programa----------: MA040LOG
Autor-------------: Julio de Paula Paz
Data da Criacao---: 16/12/2021 
===============================================================================================================================
Descrição---------: Função que retorna o array estático de log de alteração
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aCmpLog = Array do Log de Alteração, com os dados antes das alterações / exclusão.
===============================================================================================================================
*/
User Function MA040LOG()
Local _aDados

Begin Sequence
   
   _aDados := Aclone(_aLogSA3)

End Sequencelse
	
Return _aDados  





