/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 27/07/2017 | Chamado: 20916 - Validar campos de pallet chep, revis�o para 12.
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 13/06/2019 | Chamado: 29648 - N�o valida isento/email na importa��o de funcion�rio.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Chamado: 28346 - Removidos os Warning na compila��o da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 12/03/2021 | Chamado: 35759 - Quando Cliente alterado p/Simples Nacional=N�o,limpar codigo tab Tre�o Simp.Nac.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 04/05/2021 | Chamado: 36378 - Quando grupo de cliente � gen�rico o vendedor tb tem que ser gen�rico.
------------------:------------:-----------------------------------------------------------------------------------------------
 Julio Paz        | 20/12/2021 | Chamado: 25540 - Desenv.Rotina Env.WorkFlow quando vendedor1,2,3,4 for alter.e Grupo Env.WorkFlow.
------------------:------------:-----------------------------------------------------------------------------------------------
 Julio Paz        | 23/12/2021 | Chamado: 30177 - Altera��es diversas relacionados a Desconto Contratual. 
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 30/05/2022 | Chamado: 40048 - Ajustes para valida��o de caracteres inv�lidos. 
------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 11/08/2022 | Chamado: 40048 - Ajustes para convers�o de caracteres.
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 24/05/2023 | Chamado: 43808 - Ajustar layout/valida��es execauto p/Importa��o Clientes Broker p/novo layout  
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 07/07/2023 | Chamado: 44399 - Corre��es nas valida��es de cadastro clientes criados na efetiva��o prospect
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 25/07/2023 | Chamado: 44096 - Ajustar rotina incl/alter gravar Grupo Tributa��o "023" p/Parana e Simples Nac
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 02/07/2024 | Chamado: 47127 - Ajustes para n�o gravar o campo A1_MSBLQL.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 12/07/2024 | Chamado: 47556 - Ajuste para preenchimento obrigat�rio do campo A1_CNAE.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 16/07/2024 | Chamado: 48523 - Ajuste para exce��o do fonte MOMS003.
===============================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
===================================================================================================================================================================================================
Antonio  - Julio Paz     - 17/06/25 - 27/06/25 - 50278   - Cria��o de Campo e Inclus�o de valida��es para determinar usu�rios que podem incluir/alterar Clientes com base nos limetes de cr�dito.
Antonio  - Julio Paz     - 01/07/25 - 01/07/25 - 51203   - Ajustar as valida��es por limite de cr�dito para n�o validar quando for MSEXECAUTO dos fontes: GP010VALPE/GPE10MENU/MOMS003/MOMS055. 
===================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "RwMake.ch"
#include "TopConn.ch" 
#INCLUDE "PROTHEUS.CH"
#Include 'fileio.ch'

#define CRLF		Chr(13) + Chr(10)

Static _aBloqSA1 := {}  // Array Static para guardar informa��es de bloqueio por desconto contratual.

/*
===============================================================================================================================
Programa----------: MA030TOK
Autor-------------: Talita Teixeira
Data da Criacao---: 27/03/2013
===============================================================================================================================
Descri��o---------: Valida��es no cadastro de Clientes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico com exibi��o de mensagens para tratativa das negativas
===============================================================================================================================
*/
User Function MA030TOK()

Local _aArea	:= GetArea()
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""
Local _cUser	:= ""
Local _cCodigo	:= ""
Local _cTxtAux	:= ""
Local _lRet		:= .T.
Local _cfilsa1 	:= xFilial("SA1")
Local _ccodcli 	:= M->A1_COD
Local _cgrpcli 	:= M->A1_GRPVEN
Local _cloja	:= M->A1_LOJA

Local _lMashup	:= U_ItGetMV("IT_MASHUP",.F.)
Local _lLibMas	:= .F.

Local _nQtdDia	:= Val(M->A1_I_PEREX)
Local _nQtdiaT	:= Iif(Empty(M->A1_I_DTEXE),0,dDataBase - M->A1_I_DTEXE)
Local _lExec	:= Iif(_nQtdiaT > _nQtdDia, .T., .F.)

Local _cVendGen := U_ITGetMV("IT_VENDGEN","000156")
Local _cGrpGen  := U_ITGetMV("IT_GRPGEN","11")

Local _cEnvWorkF  := "S"
Local _aListaVend := {}
Local _cNomeGrupo := ""
Local _cNomVendA := ""
Local _cNomVendB := ""
Local _cDescCont := ""

Local _cA1_NOME    := ""
Local _cA1_END     := ""
Local _cA1_BAIRRO  := ""
Local _cA1_ENDCOB  := ""
Local _cA1_ENDREC  := ""
Local _cA1_ENDENT  := ""
Local _cA1_BAIRROE := ""

Local _cUfMVA := U_ITGetMV("IT_UFSMVA","PR") 
Local _cTRIBMVA := U_ITGetMV("IT_TRIBMVA","023")
Local _nLimeteAp

Private _cMensagem	:= ""
Private _lAuto		:= FunName() == "MOMS003"
Private _lVarLog	:= Type("_aLogM003") == "A"

//==================================================================
// Valida permiss�o do usu�rio para incluir ou alterar um cliente.
// Tendo como base o limite de cr�dito no cadastro de usu�rios. 
//==================================================================
If ! FWIsInCallStack("U_GP010VALPE") .And. ! FWIsInCallStack("IMPORTAFUN") .And. ! FWIsInCallStack("U_IMPCLI") .And. ! FWIsInCallStack("MOMS003L") .And. ! FWIsInCallStack("MOMS055I")

   _nLimeteAp :=  Posicione("ZZL",3,xfilial("ZZL")+AllTrim(__cUserId),"ZZL_VLMAXP") // ZZL_FILIAL+ZZL_CODUSU
   If ValType(_nLimeteAp) <> "N"
      _nLimeteAp := 0
   EndIf 
 
   If Inclui .And. _lRet
      If M->A1_LC > _nLimeteAp
         U_ITMSG("O Valor do limite de cr�dito deste cliente: " + AllTrim(Str(M->A1_LC,14,2)) + ", � superior ao limite permitido para este usu�rio incluir o cliente: " + AllTrim(Str(_nLimeteAp,14,2))+".","Aten��o","",1)
         _lRet := .F.      
      EndIf 
   EndIf 

   If Altera .And. _lRet
      If M->A1_LC <> SA1->A1_LC 
         If M->A1_LC > _nLimeteAp
            U_ITMSG("O Valor do limite de cr�dito deste cliente: " + AllTrim(Str(M->A1_LC,14,2)) + ", � superior ao limite permitido para este usu�rio alterar o cliente: " + AllTrim(Str(_nLimeteAp,14,2))+".","Aten��o","",1)
            _lRet := .F.      
         EndIf 
      EndIF 
   EndIf 
EndIf 

//===================================================
// Demais valida��es do Cadastro de Clientes.
//===================================================
If Inclui
	
	//================================================================================
	// Valida��o do c�digo de Cliente gerado automaticamente
	//================================================================================
	_cQuery := " SELECT MAX(A1_COD) AS CODIGO "
	_cQuery += " FROM "+ RetSqlName( 'SA1' )
	_cQuery += " WHERE D_E_L_E_T_ = ' ' "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea( _cAlias )
 	(_cAlias)->( DBGotop() )
	IF (_cAlias)->( !Eof() )
		_cCodigo := (_cAlias)->CODIGO
	Else
		_cCodigo := StrZero( 0 , TamSX3("A1_COD")[01] )
	EndIf
	
	(_cAlias)->( DBCloseArea() )
	
    If _cCodigo == M->A1_COD

		//Verifica se existe o codigo do cliente com a mesma loja ja cadastrado.
		_cQry := " SELECT COUNT(*) AS CONTADOR "
		_cQry += " FROM " + RetSqlName("SA1") + " "
		_cQry += " WHERE A1_COD = '" + M->A1_COD + "' "
		_cQry += "   AND A1_LOJA = '" + M->A1_LOJA + "' "

		DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBCLI" , .T. , .F. )
		
		dbSelectArea("TRBCLI")
		TRBCLI->(dbGotop())
		
		If TRBCLI->CONTADOR <> 0

			If _lAuto
				If _lVarLog
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O c�digo de cliente: " + M->A1_COD + " e Loja: " + M->A1_LOJA + " j� existe." } )
				EndIf
			Else
				u_itmsg("Este c�digo de cliente j� est� em uso!","Valida��o C�digo","Favor digitar novamente o CPF/CNPJ.",1)
			EndIf
			
			_lRet := .F.

		EndIf
		
		dbSelectArea("TRBCLI")
		TRBCLI->(dbCloseArea())
	
	EndIf

	DBSelectArea( 'SA1' )
	SA1->( DBSetOrder (3) )
	If SA1->( DBSeek( xFilial("SA1") + M->A1_CGC ) )
	
		_cUser := RetCodUsr()
		
		DBSelectArea("ZZL")
		ZZL->( DBSetOrder(3) )
		If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
		
			If ZZL->ZZL_INCCLI <> 'S'
				
				If _lAuto
					If _lVarLog
						aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O usu�rio: " + Capital( UsrFullName( _cUser ) ) + " n�o tem permiss�o para incluir cliente que j� possui cadastro com o mesmo CPF/CNPJ" } )
					EndIf
				Else
					u_itmsg("O usu�rio "+ Capital( UsrFullName( _cUser ) ) +" n�o tem permiss�o para incluir um cliente que j� possui cadastro com o mesmo CPF/CNPJ.",;
							"Valida��o usu�rio",;
							"Informar a �rea de TI/ERP solicitando a libera��o!",1)
				EndIf
				
				_lRet := .F.
				
			EndIf
		
		Else

			If _lAuto
				If _lVarLog
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O usu�rio: " + Capital( UsrFullName( _cUser ) ) + " n�o tem permiss�o para incluir cliente que j� possui cadastro com o mesmo CPF/CNPJ" } )
				EndIf
			Else
				u_itmsg("O usu�rio "+ Capital( UsrFullName( _cUser ) ) +" n�o tem permiss�o para incluir um cliente que j� possui cadastro com o mesmo CPF/CNPJ.",;
						"Valida��o usu�rio",;
						"Informar a �rea de TI/ERP solicitando a libera��o!",1)
			EndIf
			
			_lRet := .F.
			
		EndIf
		
	EndIf
	
	If _lRet .And. !IsInCallStack("U_AOMS014")
    	_lRet := MA030RIS()   
    EndIf
	
EndIf

If Inclui .Or. Altera
   
    
	//================================================================================
	// Valida��o do preenchimento do campo de e-mail. Rotina automatica n�o deve mostrar
	//================================================================================
	If !IsInCallStack("U_GP010VALPE") .And. !IsInCallStack("U_GP265VALPE")
		If Empty( M->A1_EMAIL ) .AND. ( FunName() <> "MOMS003" ) .AND. FUNNAME() <> "GPEA010"
			
			If _lAuto
				If _lVarLog
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo E-Mail n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ". N�o cadastre endere�os gen�ricos." } )
				EndIf
			Else
				u_itmsg('O campo "e-mail" n�o foi preenchido, esse campo n�o � obrigat�rio mas deve ser preenchido com um endere�o v�lido!',;
						'Valida��o Email','N�o cadastre endere�os gen�ricos como "funcionarios@italac.com.br" ou nfe@italac.com.br', 3)
			EndIf		
	
		EndIf
	
		If Empty(M->A1_INSCR) .AND. ( FunName() <> "MOMS003" ) .AND. ( FunName() <> "GPEA010" )
	
			
			u_itmsg('Preencher como ISENTO quando for dispensado de IE e deixar em branco quando for n�o contribuinte do ICMS.  ',;
					'Aten��o','D�vidas procurar departamento FISCAL.',2)
	
		EndIf
		
	EndIf

    _cTxtAux := LTrim( StrTran( M->A1_NOME , '	' , '' ) )
    
    If _cTxtAux <> M->A1_NOME

    	If _lAuto
   			If _lVarLog
	   			aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Nome n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + "." } )
	   		EndIf
	   	Else
	   		u_itmsg("Erro no preenchimento do campo Nome!","Valida��o de Nome","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
	   	EndIf

   		_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_END , '	' , '' ) )
    
    If _cTxtAux <> M->A1_END
		
		If _lAuto
			If _lVarLog
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Endere�o n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			EndIf
		Else
			u_itmsg("Erro no preenchimento do campo Endere�o!","Valida��o de endere�o","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
		EndIf

   		_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_BAIRRO , '	' , "" ) )
    
    If _cTxtAux <> M->A1_BAIRRO
   		
   		If _lAuto
   			If _lVarLog
	   			aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Bairro n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
	   		EndIf
   		Else
   			u_itmsg("Erro no preenchimento do campo Endere�o!","Valida��o de endere�o","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
   		EndIf

   		_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_COMPLEM , '	' , "" ) )
    
    If M->A1_COMPLEM <> ' ' .And. _cTxtAux <> M->A1_COMPLEM
	   	
		If _lAuto
			If _lVarLog
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Complemento n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			EndIf
  		Else
  			u_itmsg("Erro no preenchimento do campo Complemento do Endere�o!","Valida��o Endere�o","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
  		EndIf

	   	_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_INSCR , '	' , "" ) )
    
    If _cTxtAux <> AllTrim(M->A1_INSCR)
   		
   		If _lAuto
			If _lVarLog
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Inscri��o Estadual n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			EndIf
		Else
			u_itmsg("Erro no preenchimento do campo Inscri��o Estadual!","Valida��o de inscri��o estadual","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
		EndIf

   		_lRet := .F.
    EndIf
 	
    If _lRet .And. !IsInCallStack("U_AOMS014")
    	_lRet := MA030RIS() 
    EndIf

	//--------------------------------------------------------------------------------------------------------------
	//Valida se cliente tem outros registros com mesmo c�digo e lojas diferentes e se est�o todos na mesma rede	
	//--------------------------------------------------------------------------------------------------------------
	If M->A1_MSBLQL <> '1' .and. _lRet

		_cAlias  := GetNextAlias()
		_cfilsa1 := xFilial("SA1")
		_ccodcli := M->A1_COD
		_cgrpcli := M->A1_GRPVEN
		_cloja	  := M->A1_LOJA
  
		BeginSql alias _cAlias
			   	
   			SELECT 
	 			A1_GRPVEN, A1_LOJA
			FROM 
			%table:SA1% SA1
			WHERE 
	   			a1_filial = %exp:_cfilsa1%
	   			and a1_msblql <> '1'
	   			and a1_cod = %exp:_ccodcli%
	   			and a1_loja <> %exp:_cloja%
	   			and d_e_l_e_t_ = ' ' 

		EndSql

		DbSelectArea(_cAlias)
		(_cAlias)->(  dbgotop() )
 
		//-----------------------------------------------------
		//Prepara matriz com lojas com grupo diferente 
		//Analisa de grupo est� ok ou se existem outras com problema
		//-----------------------------------------------------
		_alojas := {}
		_cult := alltrim((_cAlias)->A1_GRPVEN)
		
		Do while .not. (_cAlias)->( Eof() )
		
			if alltrim((_cAlias)->A1_GRPVEN) != alltrim(_cult)
			
				_cult := "mudou"
				
			Endif
			
			if alltrim((_cAlias)->A1_GRPVEN) != alltrim(_cgrpcli)
			
				aadd( _alojas, { alltrim((_cAlias)->A1_LOJA), alltrim((_cAlias)->A1_GRPVEN)})
			
			Endif
			
			(_cAlias)->( dbskip())
			
		EndDo		
		
		//-----------------------------------------------------
		//se achou cliente do mesmo c�digo e grupo diferente
		//d� mensagem e trava o processo
		//-----------------------------------------------------
		(_cAlias)->(  dbgotop() )
 
		if .not. (_cAlias)->( Eof() )

			_cMensagem += "Erro no preenchimento do grupo de vendas!" + chr(10) + chr(13)
			
			//------------------------------------------------------------------------
			//Se o _cult n�o mudou significa que todas as lojas est�o no mesmo grupo
			//-----------------------------------------------------------------------
			If _cult == alltrim((_cAlias)->A1_GRPVEN)
			
				if _cult == alltrim((_cAlias)->A1_GRPVEN) .and. alltrim((_cAlias)->A1_GRPVEN) != alltrim(M->A1_GRPVEN)
				
					_lRet := .F.
					_cMensagem += "Todas as lojas desse cliente est�o no grupo " + alltrim((_cAlias)->A1_GRPVEN)
					
				Endif 
				
			//------------------------------------------------------------------------
			//Se n�o mostra lista de lojas com problema
			//-----------------------------------------------------------------------
			Else
				
				
				_lRet := .F.
				_cMensagem += "Existem clientes do mesmo c�digo em grupo de vendas diferente."
				_cMensagem += chr(10)+chr(13)
				
				_nx := 1
				
				Do while _nx <=  2 .and. _nx <= len(_alojas)
				
					_cMensagem += "Loja: " + _alojas[_nx][1] + "  - Grupo: " + _alojas[_nx][2]
					_cMensagem += chr(10)+chr(13)
					
					_nx++
					
				Enddo	
				
				If len(_alojas) > 2
				
					_cMensagem += "E mais " + alltrim(str(len(_alojas) - 2)) + " lojas com diverg�ncia."
					_cMensagem += chr(10)+chr(13)
				
				Endif	
			
			Endif
			
			_cMen2 := "Continua mesmo assim?"
	
			If _lAuto .and. !(_lRet)
			
				If _lVarLog
			
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"Existem clientes do mesmo c�digo em grupo de vendas diferente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			
				EndIf
		
			Elseif  !(_lRet)
			
				if u_itmsg(_cMensagem, "Valida��o Grupo de Vendas",_cMen2,3,2,2) 
				
					_lRet := .T.
					
				Else
				
					_lRet := .F.
					
				Endif
			
			EndIf
		
		Endif
 
        If Select(_cAlias) > 0 
		   (_cAlias)->( DBCloseArea() )
	    EndIf

	Endif

	//================================================================================
	// Valida��o da sita��o cadastral do cliente, conforme retorno no mashups
	//================================================================================
	If _lMashup
		If M->A1_PESSOA <> "F" .And. M->A1_COD <> "000001"
			_cUser := RetCodUsr()
			
			DBSelectArea("ZZL")
			ZZL->( DBSetOrder(3) )
			If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
				If ZZL->ZZL_LIBMAS == "S"
					_lLibMas := .T.
				EndIf
			EndIf
	
			If !_lLibMas
				If Inclui
					If (ALLTRIM(M->A1_I_SITRF) <> "ATIVO" .AND. ALLTRIM(M->A1_I_SITRF) <> "REGULAR" .AND. ALLTRIM(M->A1_I_SITRF) <> "APTO" .AND. ALLTRIM(M->A1_I_SITRF) <> "ATIVA") .Or. _lExec
						If _lExec
							_lRet := .F.
							If IsInCallStack("U_MOMS003")
								aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal devido a periodicidade de consulta. A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.' } )
							Else
								u_itmsg( "� necess�rio realizar a consulta deste cadastro na Receita Federal devido a periodicidade de consulta.","Valida��o Mashup","A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.",1 )
							EndIf
						Else
							_lRet := .F.
							If Empty(M->A1_I_SITRF)
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal e se "Jur�dico" no Sintegra tamb�m. A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.' } )
								Else
									u_itmsg( "� necess�rio realizar a consulta deste cadastro na Receita Federal e se 'Jur�dico' no Sintegra tamb�m.","Valida��o Mashup","A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.",1 )
								EndIf
							Else
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'N�o � poss�vel concluir a cria��o do cadastro de cliente, devido o status deste Fornecedor na Receita Federal estar como [' + ALLTRIM(A1_I_SITRF) + '].' } )
								Else
									u_itmsg( 'N�o � poss�vel concluir o cadastro deste cliente, devido seu status na Receita Federal estar como [' + ALLTRIM(M->A1_I_SITRF) + '].' , "Valida��o Mashup",,1 )
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf Altera
					If (ALLTRIM(A1_I_SITRF) <> "ATIVO" .AND. ALLTRIM(A1_I_SITRF) <> "REGULAR" .AND. ALLTRIM(A1_I_SITRF) <> "APTO" .AND. ALLTRIM(A1_I_SITRF) <> "ATIVA") .Or. _lExec
						If _lExec
							_lRet := .F.
							If IsInCallStack("U_MOMS003")
								aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal devido a periodicidade de consulta. A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.' } )
							Else
								u_itmsg( '� necess�rio realizar a consulta deste cadastro na Receita Federal devido a periodicidade de consulta.',"Valida��o Mashup",'A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.' , 1)
							EndIf
						Else
							_lRet := .F.
							If Empty(A1_I_SITRF)
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal e se "Jur�dico" no Sintegra tamb�m. A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.' } )
								Else
									u_itmsg( '� necess�rio realizar a consulta deste cadastro na Receita Federal e se "Jur�dico" no Sintegra tamb�m.',"Valida��o Mashup",'A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.' , 1 )
								EndIf
							Else
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'N�o � poss�vel concluir a cria��o do cadastro de cliente, devido o status deste Fornecedor na Receita Federal estar como [' + ALLTRIM(A1_I_SITRF) + '].' } )
								Else
									u_itmsg( 'N�o � poss�vel concluir o cadastro deste cliente, devido seu status na Receita Federal estar como [' + ALLTRIM(A1_I_SITRF) + '].' ,"Valida��o Mashup",,1 )
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf


//================================================================================
//Valida��o de campos Chep
//================================================================================
If _lRet .and. M->A1_I_CHEP  == "C" .AND. LEN(ALLTRIM(A1_I_CCHEP)) != 10

	u_itmsg("Campo de c�digo de cadastro chep inv�lido!","Valida��o Chep","Mude cliente para pallet pbr ou inclua c�digo Chep v�lido!",1)
	_lRet := .F.
	
Endif

If _lRet .and. M->A1_I_CHEP  != "C" .AND. LEN(ALLTRIM(A1_I_CCHEP)) > 0 

	u_itmsg("Campo de c�digo de cadastro chep prenchido para cliente n�o Chep!","Valida��o Chep","Mude cliente para chep pbr ou limpe o c�digo Chep v�lido!",1)
	_lRet := .F.
	
Endif

If !IsInCallStack("U_AOMS014")
	If !Empty(M->A1_INSCR)
		M->A1_INSCR := AllTrim(Strtran(M->A1_INSCR,"-",""))
	EndIf
    
	//==========================================================================
	// Quando o cliente for alterado para Simples Nacional == N�O, 
	// Limpar c�digo de tabela de pre�os Simples Nacional do campo A1_TABELA.
	//==========================================================================
	If _lRet .And. Altera
       If SA1->A1_SIMPNAC == "1" .And. M->A1_SIMPNAC == "2"
          U_M30PALTAB(.T.)
	   Else
	      U_M30PALTAB(.F.)
	   EndIf 
	EndIf 
EndIf

If _lRet .And. !Empty(Alltrim(_cGrpGen)) .And. !Empty(Alltrim(_cVendGen))

	If M->A1_I_GRCLI $ _cGrpGen .And. IsInCallStack("MATA030") .And. !(M->A1_VEND $ _cVendGen)
		
		U_ITMSG("A efetiva��o n�o ser� realizada!"+Chr(13)+Chr(10)+"Para este grupo de clientes "+M->A1_I_GRCLI+" s� � permito vincular os vendedores gen�ricos: "+_cVendGen,"Aten��o","Altere o vendedor para um que seja gen�rico conforme informado.",1)
		_lRet := .F.	

	EndIf

EndIf

If _lRet .And. Altera
   //===================================================================================
   // Verifica se houve altera��es nos Vendedores para envio de Workflow para o
   // Respons�vel. Chamado 25540.
   //===================================================================================
   If (M->A1_VEND <> SA1->A1_VEND ;
      .OR. M->A1_I_VEND2 <> SA1->A1_I_VEND2;
      .OR. M->A1_I_VEND3 <> SA1->A1_I_VEND3;
      .OR. M->A1_I_VEND4 <> SA1->A1_I_VEND4)
          
      _aListaVend := {} 

      _cEnvWorkF  := Posicione("ACY",1,xFilial("ACY")+M->A1_GRPVEN,"ACY_I_ALTV") // 1 = ACY_FILIAL+ACY_GRPVEN 
      _cNomeGrupo := Posicione("ACY",1,xFilial("ACY")+M->A1_GRPVEN,"ACY_DESCRI")

	  If _cEnvWorkF == "S"

         If M->A1_VEND <> SA1->A1_VEND
            _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_NOME")
            _cNomVendB := Posicione("SA3",1,xFilial("SA3")+M->A1_VEND,"A3_NOME")
		    Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_VEND,_cNomVendA,M->A1_VEND,_cNomVendB,"Vendedor1"})
		 EndIf 

	     If M->A1_I_VEND2 <> SA1->A1_I_VEND2
            _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_I_VEND2,"A3_NOME")
            _cNomVendB := Posicione("SA3",1,xFilial("SA3")+M->A1_I_VEND2,"A3_NOME")
		    Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_I_VEND2,_cNomVendA,M->A1_I_VEND2,_cNomVendB,"Vendedor2"})
		 EndIf 

	     If M->A1_I_VEND3 <> SA1->A1_I_VEND3
            _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_I_VEND3,"A3_NOME")
            _cNomVendB := Posicione("SA3",1,xFilial("SA3")+M->A1_I_VEND3,"A3_NOME")
		    Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_I_VEND3,_cNomVendA,M->A1_I_VEND3,_cNomVendB,"Vendedor3"})
		 EndIf 

	     If M->A1_I_VEND4 <> SA1->A1_I_VEND4
            _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_I_VEND4,"A3_NOME")
            _cNomVendB := Posicione("SA3",1,xFilial("SA3")+M->A1_I_VEND4,"A3_NOME")
		    Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_I_VEND4,_cNomVendA,M->A1_I_VEND4,_cNomVendB,"Vendedor4"})
		 EndIf 

         U_M030WKFLOW(_aListaVend)
	  EndIf 
   EndIf  
EndIf 

//===================================================================================
// Realiza bloqueio de Cliente por desconto contratual. Chamado 30177.
//===================================================================================
If _lRet .And. (Altera .Or. Inclui)
   
   _cDescCont := Posicione("ACY",1,xFilial("ACY")+M->A1_GRPVEN,"ACY_I_DESC") // ACY_FILIAL+ACY_GRPVEN 
   _aBloqSA1 := {.F.,;          // Bloqueio por contrato
	             M->A1_MSBLQL,; // Bloqueio por Cliente
		         M->A1_I_BLQDC} // Bloqueio Contrato 

   If (AllTrim(_cDescCont) == "S" .And. Inclui) .Or. (Altera .And. M->A1_GRPVEN <> SA1->A1_GRPVEN .And. AllTrim(_cDescCont) == "S")
      
	   If U_ItMsg("O grupo de cliente informado para este cliente possui uma regra de desconto contratual de uso restrito," +; //If U_ItMsg("O grupo de cliente informado para este cliente possui uma regra de desconto contratual preexistente,"+;
	             " ao confirmar este cadastro o mesmo ser� bloqueado para an�lise do setor de contratos. "+ CRLF +;
				 " Deseja prosseguir?", "Aten��o", "",2,2,2) // 3,2,2 
		 
		 //M->A1_MSBLQL  := "1"
		 M->A1_I_BLQDC := "1"
		 
		 //----------------------//
		 _aBloqSA1 := {.T.,;     // Bloqueio por contrato
		               "1",;     // Bloqueio por Cliente
					   "1"}      // Bloqueio Contrato
		 //----------------------//
      
	  Else
		 
		 _aBloqSA1 := {.F.,;          // Bloqueio por contrato
		               M->A1_MSBLQL,; // Bloqueio por Cliente
					   M->A1_I_BLQDC} // Bloqueio Contrato
         //-----------------------------------------------------------// 					   
		 _lRet := .F. 

      EndIf 

   EndIf 

EndIf 

If _lRet .And. (Altera .Or. Inclui)

	_cA1_NOME := M->A1_NOME
	If !Empty(Alltrim(M->A1_NOME))
		_lRet := U_CRMA980VCP(@_cA1_NOME   ,"A1_NOME")
		M->A1_NOME := _cA1_NOME
	EndIf

	_cA1_END := M->A1_END
	If _lRet .And. !Empty(Alltrim(_cA1_END))
		_lRet := U_CRMA980VCP(@_cA1_END    ,"A1_END")
		M->A1_END := _cA1_END
	EndIf

	_cA1_BAIRRO := M->A1_BAIRRO
	If _lRet .And. !Empty(Alltrim(_cA1_BAIRRO))
		_lRet := U_CRMA980VCP(@_cA1_BAIRRO ,"A1_BAIRRO")
		M->A1_BAIRRO := _cA1_BAIRRO
	EndIf

	_cA1_ENDCOB := M->A1_ENDCOB
	If _lRet .And. !Empty(Alltrim(_cA1_ENDCOB))
		_lRet := U_CRMA980VCP(@_cA1_ENDCOB ,"A1_ENDCOB")
		M->A1_ENDCOB := _cA1_ENDCOB
	EndIf

	_cA1_ENDREC := M->A1_ENDREC
	If _lRet .And. !Empty(Alltrim(_cA1_ENDREC))
		_lRet := U_CRMA980VCP(@_cA1_ENDREC ,"A1_ENDREC")
		M->A1_ENDREC := _cA1_ENDREC
	EndIf

	_cA1_ENDENT := M->A1_ENDENT
	If _lRet .And. !Empty(Alltrim(_cA1_ENDENT))
		_lRet := U_CRMA980VCP(@_cA1_ENDENT,"A1_ENDENT")
		M->A1_ENDENT := _cA1_ENDENT
	EndIf

	_cA1_BAIRROE := M->A1_BAIRROE
	If _lRet .And. !Empty(Alltrim(_cA1_BAIRROE))
		_lRet := U_CRMA980VCP(@_cA1_BAIRROE,"A1_BAIRROE")
		M->A1_BAIRROE := _cA1_BAIRROE
	EndIf

    If M->A1_EST $ _cUfMVA .And. M->A1_SIMPNAC == "1" // 1=Sim;2=N�o
	   M->A1_GRPTRIB := _cTRIBMVA //"023" //  Motivo: estado reduz o MVA para 30% (exce��o fiscal) e estamos iniciando opera��o de 4 Brokers que atender�o este grupo.
	Else 
       If  AllTrim(M->A1_GRPTRIB) == AllTrim(_cTRIBMVA)
           M->A1_GRPTRIB :=  " "
       EndIf 
	EndIf 
	
EndIf

If _lRet .And. (Altera .Or. Inclui) .AND. !IsInCallStack("U_AOMS014") .AND. !IsInCallStack("U_MOMS003")
   If M->A1_PESSOA <> "F" .AND. (Empty(Alltrim(M->A1_CNAE)) .OR. M->A1_CNAE == "    - /  ")
		U_ITMSG("Necess�rio o preenchimento do campo CNAE para Clientes pessoa Jur�dica!","Aten��o","",1)
		_lRet := .F.	
   EndIf
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: MA030RIS
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 22/06/2015
===============================================================================================================================
Descri��o---------: Valida�ao do grau de risco e limite de credito
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico com exibi��o de mensagens para tratativa das negativas
===============================================================================================================================
*/
Static Function MA030RIS()
Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cQry		:= ""
Local _cCliente	:= ""
Local _cLoja	:= ""
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ''
Local _aCliente	:= {}
Local _cLjvalid	:= ""
Local _aRecnos	:= {}
Local _lLimite	:= .F.
Local _lRisco	:= .F.
Local _nI		:= 0
		
Begin Sequence 
   
   If IsInCallStack("U_MOMS055") // N�o validar msexecauto da integra��o do Broker.
      Break
   EndIf 

   _cCliente	:= M->A1_COD
   _cLoja		:= M->A1_LOJA
			
   _cQuery := " SELECT "
   _cQuery += " 	A1.A1_COD, A1.A1_LOJA, A1.A1_LC, A1.R_E_C_N_O_ AS SA1REG "
   _cQuery += " FROM "+ RetSqlName ("SA1")+ " A1  "
   _cQuery += " WHERE "
   _cQuery += " 		A1.D_E_L_E_T_	= ' ' "
   _cQuery += " AND	A1.A1_LC		<> '0'   " 
   _cQuery += " AND	A1.A1_COD		= '"+ _cCliente + "' "
			
   If Select(_cAlias) > 0
	  (_cAlias)->( DBCloseArea() )
   EndIf
			
   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery ) , _cAlias , .T. , .F. )
		    
   DBSelectArea(_cAlias)
   (_cAlias)->( DBGoTop() )
   While (_cAlias)->( !EOF() )
			
	  If _cLoja <> (_cAlias)->A1_LOJA
    	 AAdd( _aCliente,	{ (_cAlias)->A1_LOJA }	)
    	 AAdd( _aRecnos,		{ (_cAlias)->SA1REG }	)
   	  EndIf
		    
      (_cAlias)->( DBSkip() )
   EndDo
		   	
   //================================================================================
   // N�o permite gravar Limite se j� tiver Limite gravado em outras Lojas. Rotina automatica n�o deve mostrar
   //================================================================================
   If Len( _aCliente ) > 0
			
	  If M->A1_LC <> 0 .AND. ( FunName() <> "MOMS003" )
		 _lLimite := .T.
	  EndIf
      //================================================================================
      // Tratativa para o chamado - 5717 - Permitir gravar Prospect sem Limite
      //================================================================================
   ElseIf M->A1_LC == 0 .And. ( FunName() <> "AOMS016" ) 

	  If _lAuto
	     If _lVarLog
			aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Limite de Cr�dito n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ". � obrigat�rio o preencimento deste campo." } )
		 EndIf
	  Else
	   	 u_itmsg("Limite de cr�dito n�o preenchido!","Valida��o Cr�dito","� obrigat�rio incluir um limite de cr�dito para o cliente.",1)
	  EndIf

	  _lRet := .F.
   EndIf
			
   (_cAlias)->( DBCloseArea() )

   // Verificacao se existe alguma loja deste cliente com o risco diferente do que est� sendo informado
   _cQry := "SELECT COUNT(*) AS QTDENT "
   _cQry += "FROM " + RetSqlName("SA1") + " "
   _cQry += "WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
   _cQry += "  AND A1_COD = '" + M->A1_COD + "' "
   _cQry += "  AND A1_LOJA <> '" + M->A1_LOJA + "' "
   _cQry += "  AND A1_RISCO <> '" + M->A1_RISCO + "' "
   _cQry += "  AND D_E_L_E_T_ = ' ' "
	
   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQTD" , .T. , .F. )
	
   dbSelectArea("TRBQTD")
   TRBQTD->(dbGoTop())
		
   If TRBQTD->QTDENT > 0
	  _lRisco := .T.
   EndIf

   dbSelectArea("TRBQTD")
   TRBQTD->(dbCloseArea())	

   If _lLimite .And. !_lRisco

	  _cLjvalid := ""
		   			
	  For _nI := 1 to Len( _aCliente )
					
		  If _nI == Len( _aCliente )
		     _cLjvalid  += _aCliente[_nI][01]
		  Else
			 _cLjvalid  += _aCliente[_nI][01] + "; "
		  EndIf
						
	  Next _nI
		
	  If u_itmsg("A(s) Loja(s) " + _cLjvalid + " do cliente " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + M->A1_COD + M->A1_LOJA, "A1_NOME")) + ;
	 			" j� possui(em) valor(es) de Limite(s) cadastrado(s), como o valor de Limite � compartilhado entre as lojas somente uma loja dever� ter limite estabelecido!",;
	 			"Valida��o Cr�dito","Deseja manter este limite de cr�dito compartilhado para todas as lojas? O sistema ir� zerar o limite de cr�dito das outras lojas.",2,2,2)
		 VLDLIM(_lLimite, _aCliente, _aRecnos)
	  Else
	     If _lAuto
			If _lVarLog
		 	   aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"As lojas: " + _cLjvalid + " do cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", j� possui(em) valor(es) de Limite(s) cadastrado(s)." } )
			EndIf
		 EndIf
		 _lRet := .F.
	  EndIf
   ElseIf !_lLimite .And. _lRisco

	  If !IsInCallStack("U_MOMS003")
		
		 If u_itmsg("Erro no Grau de Risco informado para o cliente - " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + M->A1_COD + M->A1_LOJA, "A1_NOME")) + chr(10) + chr(13) + ;
	 			"� necess�rio verificar o cadastro deste cliente, pois existem outras lojas com o Grau de Risco diferente deste cadastro.",;
	 			"Valida��o Cr�dito","Deseja replicar este Risco para todas as lojas?",2,2,2)
		
		    VLDRIS()
		 Else
		    _lRet := .F.
		 EndIf
	  Else
		 If _lAuto
			If _lVarLog
			   aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"Erro no Grau de Risco informado no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", existem outras lojas com o Grau de Risco diferente deste cadastro." } )
			EndIf
		 EndIf
		 _lRet := .F.
	  EndIf
   ElseIf _lLimite .And. _lRisco

	  _cLjvalid := ""
		   			
	  For _nI := 1 to Len( _aCliente )
					
		  If _nI == Len( _aCliente )
			 _cLjvalid  += _aCliente[_nI][01]
		  Else
			 _cLjvalid  += _aCliente[_nI][01] + "; "
		  EndIf
						
	  Next _nI
	
	  If u_itmsg("A(s) Loja(s) " + _cLjvalid + " do cliente - " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + M->A1_COD + M->A1_LOJA, "A1_NOME")) + ;
				"j� possui(em) valor(es) de Limite(s) cadastrado(s), como o valor de Limite � compartilhado entre as lojas somente uma loja dever� ter limite estabelecido!",;
				"Valida��o de limite de cr�dito","Deseja manter este Grau de Risco e limite de cr�dito compartilhado para todas as lojas? O sistema ir� zerar o limite de cr�dito das outras lojas.",2,2,2)
				
		 VLDLIM(_lLimite, _aCliente, _aRecnos)
	  	 VLDRIS()
	  Else
		 If _lAuto
			If _lVarLog
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"As lojas: " + _cLjvalid + " do cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", j� possui(em) valor(es) de Limite(s) cadastrado(s)." } )
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"Erro no Grau de Risco informado no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", existem outras lojas com o Grau de Risco diferente deste cadastro." } )
			EndIf
		 EndIf
		 _lRet := .F.
	  EndIf
   EndIf

End Sequence 

RestArea(_aArea)

Return(_lRet)

/*
===============================================================================================================================
Programa----------: VLDLIM
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 23/06/2015
===============================================================================================================================
Descri��o---------: Funcao para zerar o limite de credito, caso uma outra loja ja o tenha
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VLDLIM(_lLimite, _aCliente, _aRecnos)

Local _nI		:= 0

If _lLimite
	If M->A1_LC > 0
		dbSelectArea("SA1")
		For _nI := 1 To Len( _aRecnos )
			dbGoTo( _aRecnos[_nI][01] )
			RecLock("SA1", .F.)
				Replace SA1->A1_LC With 0
				MsUnLock()
		Next _nI
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa----------: VLDLIM
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 23/06/2015
===============================================================================================================================
Descri��o---------: Funcao para gravar o mesmo grau de risco para todas as lojas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VLDRIS()
Local _cQry	:= ""

// Seleciona todos as lojas do cliente em questao, para que sejam atualizados os riscos em todos os registros deste cliente
_cQry := "SELECT A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_ AS RECSA1 "
_cQry += "FROM " + RetSqlName("SA1") + " "
_cQry += "WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
_cQry += "  AND A1_COD = '" + M->A1_COD + "' "
_cQry += "  AND A1_LOJA <> '" + M->A1_LOJA + "' " 
_cQry += "  AND D_E_L_E_T_ = ' ' "
			
DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBSA1" , .T. , .F. )
					
dbSelectArea("TRBSA1")
TRBSA1->(dbGoTop())
					
While !TRBSA1->(Eof())
	dbSelectArea("SA1")
	dbGoTo(TRBSA1->RECSA1)
	RecLock("SA1", .F.)
		Replace SA1->A1_RISCO With M->A1_RISCO
	MsUnLock()
	TRBSA1->(dbSkip())
End
					
dbSelectArea("TRBSA1")
TRBSA1->(dbCloseArea())

Return

/*
===============================================================================================================================
Programa----------: M030WKFLOW()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/12/2021
===============================================================================================================================
Descri��o---------: Rotina de envio de e-mail WorkFlow notificando a altera��o dos vendedores. Chamado 25540.
===============================================================================================================================
Parametros--------: _aDados = {{ Rede , Nome Rede, Cod Vend. Anterior, Nome Vend. Anterior, Cod. Vend.Atual, Nome Vend.Atual},
                           ...,{ Rede , Nome Rede, Cod Vend. Anterior, Nome Vend. Anterior, Cod. Vend.Atual, Nome Vend.Atual}} 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function M030WKFLOW(_aDados)
Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= '',_nI 
Local _cAssunto := "WORKFLOW - ALTERA��O DE VENDEDOR EM CLIENTE COM CONTROLE DE REDE"
Local _cEmail1	:= AllTrim(U_ITGETMV("IT_EMALGP1",""))
Local _cEmail2	:= AllTrim(U_ITGETMV("IT_EMALGP2",""))
Local _cEmailEnv, _cEmlLog := "" 

If Empty(_cEmail1) .And. Empty(_cEmail2)
   Return Nil 
EndIf 

_cEmailEnv := AllTrim(_cEmail1) + ";" + AllTrim(_cEmail2)

_cMsgEml := '<html>'
_cMsgEml += '<head><title>' + _cAssunto + '</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += 'td.AZUL    { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #0000FF; }'
_cMsgEml += 'td.amarelo { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFF00; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center>Log de Processamento</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos" width="100%"><b>' + _cAssunto + '</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="20%"><b>Cliente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="80%">' + SA1->A1_COD +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Loja:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + SA1->A1_LOJA +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Nome:</b></td>'
_cMsgEml += '      <td class="itens" align="left width="65%">' + SA1->A1_NOME +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Rede:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + _aDados[01][01] +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Descri��o Rede:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + _aDados[01][02]  +'</td>'
_cMsgEml += '    </tr>'
//_cMsgEml += '    <tr>'
//_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Usuario:</b></td>'
//_cMsgEml += '      <td class="itens" align="left" >' + __cUserId +'</td>'
//_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Usuario Alterador:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + UsrFullName (__cUserId)  +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Data da Altera��o:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + Dtoc(Date()) +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Hora da Altera��o:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + Time() + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += ' <tr>'
_cMsgEml += '   <td class="titulos" align="center" colspan="2"><font color="red">Esta � uma mensagem autom�tica. Por favor n�o responder!</font></td>'
_cMsgEml += ' </tr>'
_cMsgEml += '</table>'

_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1300">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="center" width=10%"><b>Codigo Vendedor Anterior</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=25%"><b>Nome Vendedor Anterior</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=10%"><b>Codigo Vendedor Atual</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=25%"><b>Nome Vendedor Atual</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=25%"><b>Vendedor Alterado</b></td>'
_cMsgEml += '    </tr>'

For _nI := 1 To Len( _aDados )
	_cMsgEml += '    <tr>'
    _cMsgEml += '     <td class="itens" align="left" width="10%">'+_aDados[_nI][03]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="25%">'+_aDados[_nI][04]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="10%">'+_aDados[_nI][05]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="25%">'+_aDados[_nI][06]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="25%">'+_aDados[_nI][07]+'</td>'
	_cMsgEml += '    </tr>'
Next _nI
	
_cMsgEml += '</table>'

U_ITConOut('Enviando E-mail(s) para: '+_cEmailEnv+ " - Log de Processamento - Vendedores Alterados - "+TIME()+" - [ M030PALT]")

//    ITEnvMail(cFrom     ,cEmailTo ,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
U_ITENVMAIL( _aConfig[01] , _cEmailEnv ,"",         ,_cAssunto, _cMsgEml ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

Return .T.

/*
===============================================================================================================================
Programa----------: MA30RETA
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/12/2021
===============================================================================================================================
Descri��o---------: Retorna a vari�vel Static _aBloqSA1 para outros programas. Chamado 30177.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRet = Conte�do da vari�vel Static _aBloqSA1.
===============================================================================================================================
*/
User Function MA30RETA()
Local _aRet :={}

Begin Sequence 

   _aRet := AClone(_aBloqSA1)

End Sequence 

Return _aRet
