/* 
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor   |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 01/04/2019 | Chamado 28716. Realiza inclusão de cliente não existente na alteração de funcionário.
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 13/06/2019 | Chamado 29648. Retirada obrigatoriedade de cadastro cliente/fornecedor na inclusão. 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges  | 02/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.   
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz     | 14/11/2019 | Chamado 30011. Ajustar Rotina p/Enviar para os Cadastros Clientes/Fornecedores Nr e Complem.End.  
-------------------------------------------------------------------------------------------------------------------------------                  
 Igor Melgaço  | 06/08/2021 | Chamado 37363. Troca de chamada mata030 por CRMA980.	
-------------------------------------------------------------------------------------------------------------------------------                  
 Alex Wallauer | 06/10/2021 | Chamado 37942. Não atualizar os dados da conta do funcionario na alteracao do SA2.
-------------------------------------------------------------------------------------------------------------------------------                  
 Igor Melgaço  | 26/10/2021 | Chamado 38064. Correção de validação de campo MEMO na função acerta dados.		
-------------------------------------------------------------------------------------------------------------------------------                  
 Igor Melgaço  | 04/11/2021 | Chamado 37363. Ajuste para troca do Execauto do CRMA980 pelo Mata030. 		
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz     | 09/08/2022 | Chamado 40931. Na inclusão de funcionários, Gravar cad.Clientes: Segmento=39 e contribuinte=Não.
-------------------------------------------------------------------------------------------------------------------------------                  
 Alex Wallauer | 13/09/2023 | Chamado 45011. Ao realizar a "Alteração" de funcionários, NAO atualizar o campo A1_LC.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "RwMake.ch"      
#Include "Protheus.ch"   
#Include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: GP010VALPE
Autor-------------: Tiago Correa Castro
Data da Criacao---: 05/11/2008
===============================================================================================================================
Descrição---------: Ponto de Entrada para validar a inclusao/alteracao no cadastro de funcionários
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o cadastro foi validado ou não.
===============================================================================================================================
*/

User Function GP010ValPE()

Local _aArea 	:= 	GetArea()
Local _lRet		:=	.T. 
Local _cQuery	:=	""
Local _cCPF		:=	M->RA_CIC
Local _cSefip	:=	M->RA_CATEG			
Local _cCatFunc	:=	M->RA_CATFUNC //M:MENSALISTA, A=AUTONOMO, E=ESTAGIARIO, P=PRO-LABORE, ETC.  
Local _cMatric	:=	M->RA_MAT

IF IsInCallStack('U_MGPE023')
   RETURN .T.
ENDIF

PRIVATE _cCPFAnterior:=	M->RA_CIC

Begin Sequence

_cQuery := "SELECT COUNT(*) AS CONTADOR"
_cQuery += " FROM "+ RetSqlName("SRA")

If Inclui

	_cQuery += " WHERE "
	_cQuery += "     D_E_L_E_T_ = ' ' "
	_cQuery += " AND RA_CIC     = '"+ _cCPF		+"' "
	_cQuery += " AND RA_CATEG   = '"+ _cSefip	+"' "
	_cQuery += " AND RA_CATFUNC = '"+ _cCatFunc	+"' "
	_cQuery += " AND RA_SITFOLH <> 'D' "
	_cQuery += " AND RA_FILIAL = '" + xfilial("SRA") +"' "
	
ElseIf Altera

    _cCPFAnterior:=SRA->RA_CIC

	_cQuery += " WHERE "
	_cQuery += "     D_E_L_E_T_ = ' ' "
	_cQuery += " AND RA_MAT     <> '"+ _cMatric	+"' "
	_cQuery += " AND RA_CIC     = '"+ _cCPF		+"' "
	_cQuery += " AND RA_CATEG   = '"+ _cSefip	+"' "
	_cQuery += " AND RA_CATFUNC = '"+ _cCatFunc	+"' "
	_cQuery += " AND RA_SITFOLH <> 'D' "
	_cQuery += " AND RA_FILIAL = '" + xfilial("SRA") +"' "
	
EndIf

TcQuery _cQuery New Alias "TEMP"

DBSelectArea("TEMP")
TEMP->( DbGotop() )
			
If TEMP->CONTADOR > 0

	If Inclui
	
		u_itmsg(		"Nao será possível a inclusao desse registro pois ja existe um registro com o mesmo CPF, Categ. SEFIP e Cat. Func. na base de Dados!!"	,;
						"Cadastro duplicado - Inclusao"																											,;
						"Favor verificar se os dados do Registro estão corretos!!",1																				 )
		
		_lRet := .F.
		Break
		
	ElseIf Altera .And. ( _cCPF <> Space(11) )
	
		u_itmsg(	"Nao será possível a alteracao desse registro pois ja existe um registro com o mesmo CPF, Categ. SEFIP e Cat. Func. com Matricula "	+;
						"diferente na base de Dados!!"																										,;
						"Cadastro duplicado - Alteracao"																									,;
						"Favor verificar se os dados do Registro estão corretos!!"	,1																		 )
		_lRet := .F.
		Break
		
	EndIf
	
EndIf 

If Select("TEMP") > 0

	TEMP->( DBCloseArea() )
	
Endif

//===============================================================================================
//Valida se tem outro funcionário com mesmo crachá
//===============================================================================================
If !empty(M->RA_CRACHA)

	cQuery := "SELECT RA_MAT, RA_NOME"
	cQuery += " FROM "+ RetSqlName("SRA")
	cQuery += " WHERE "
	cQuery += "     D_E_L_E_T_ = ' ' "
	cQuery += " AND RA_CRACHA = '" + alltrim(M->RA_CRACHA) + "' "
	cQuery += " AND RA_FILIAL = '" + xfilial("SRA") +"' "
	cQuery += " AND RA_MAT <> '" + alltrim(M->RA_MAT) + "' "
	
	TcQuery cQuery New Alias "TEMP"

	DBSelectArea("TEMP")
	TEMP->( DbGotop() )
	
	If !TEMP->(Eof())
	
		U_ITMSG("O crachá " + alltrim(M->RA_CRACHA) + " já está em uso no funcionário " +  TEMP->RA_MAT + " - " + TEMP->RA_NOME, "Atenção!",;
		 "Escolha outro crachá ou retire o vínculo já existente",1)
		 
		 _lret := .F.
		 
		 If Select("TEMP") > 0

		 	TEMP->( DBCloseArea() )
	
		 Endif
	 
		 Break
		
	Endif
	
Endif

If Select("TEMP") > 0

	TEMP->( DBCloseArea() )
	
Endif

//===============================================================================================
//Valida se tem outro funcionário com mesmo rfid
//===============================================================================================
If !empty(M->RA_I_CRACH)

	cQuery := "SELECT RA_MAT, RA_NOME"
	cQuery += " FROM "+ RetSqlName("SRA")
	cQuery += " WHERE "
	cQuery += "     D_E_L_E_T_ = ' ' "
	cQuery += " AND RA_I_CRACH = '" + alltrim(M->RA_I_CRACH) + "' "
	cQuery += " AND RA_FILIAL = '" + xfilial("SRA") +"' "
	cQuery += " AND RA_MAT <> '" + alltrim(M->RA_MAT) + "' "
	
	TcQuery cQuery New Alias "TEMP"

	DBSelectArea("TEMP")
	TEMP->( DbGotop() )
	
	If !TEMP->(Eof())
	
		U_ITMSG("O crachá " + alltrim(M->RA_I_CRACH) + " já está em uso no funcionário " +  TEMP->RA_MAT + " - " + TEMP->RA_NOME, "Atenção!",;
		 "Escolha outro crachá ou retire o vínculo já existente",1)
		 
		 _lret := .F.
		 
		 If Select("TEMP") > 0

		 	TEMP->( DBCloseArea() )
	
		 Endif
	 
		 Break
		
	Endif
	
Endif

If Select("TEMP") > 0

	TEMP->( DBCloseArea() )
	
Endif


Begin Transaction     

//===============================================================================================
// VERIFICA SE O CADASTRO DO FUNCIONARIO NAO POSSUI NENHUMA INCONSISTENCIA 
// DETECTADA ANTES DE REALIZAR A INTEGRACAO COM O CADASTRO DE CLIENTES
//===============================================================================================
If _lRet

  _ltemp := ImportaFun()

	If !_ltemp
		u_itmsg("Não foi possível criar cadastro de cliente para o funcionário","Atenção","Crie o cliente se necessário",2)
	Endif

EndIf

//================================================================================
// EXPORTA O FUNCIONÁRIO PARA O CADASTRO DE FORNECEDOR DO SISTEMA
//================================================================================
If _lRet
   _ltemp := ImportFor()

   	If !_ltemp
		u_itmsg("Não foi possível criar cadastro de fornecedor para o funcionário","Atenção","Crie o fornecedor se necessário",2)
	Endif

EndIf

If !_lRet
   Disarmtransaction()
   BREAK
EndIf

//=================================================================================
//ATUALIZA ARQUIVO DE CRACHAS
//=================================================================================
//Zera vínculos a matricula atual 
DBSELECTAREA("ZGI")
ZGI->(Dbsetorder(2))
If _lRet .AND. ZGI->(Dbseek(xfilial("ZGI")+M->RA_MAT))

	Do while cFilAnt == ZGI->ZGI_FILIAL .AND. M->RA_MAT == ZGI->ZGI_MAT
	
	 	Reclock("ZGI", .F.)
	 	ZGI->ZGI_MAT := ""
	 	ZGI->ZGI_ENVISU := ""
	 	ZGI->(Msunlock())
	 	
	 	ZGI->(Dbskip())
	 	
	 Enddo
	 
Endif

//Atualiza cracha com matricula atual
ZGI->(Dbsetorder(1))
If _lRet .AND. !Empty(M->RA_CRACHA) .AND. ZGI->(Dbseek(xfilial("ZGI")+M->RA_CRACHA))

	Reclock("ZGI", .F.)
 	ZGI->ZGI_MAT := M->RA_MAT
 	ZGI->ZGI_ENVISU := ""
 	ZGI->(Msunlock())
 	
ElseIf _lRet

	Reclock("ZGI", .T.)
	ZGI->ZGI_FILIAL := xfilial("ZGI")
 	ZGI->ZGI_MAT := M->RA_MAT
 	ZGI->ZGI_ENVISU := ""
 	ZGI->(Msunlock())
	
Endif

End Transaction     

End Sequence

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ImportaFun
Autor-------------: Fabiano Dias
Data da Criacao---: 07/07/2010
===============================================================================================================================
Descrição---------: Função que importa os dados de funcionários para o cadastro de Clientes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o cadastro foi importado ou não.
===============================================================================================================================
*/
Static Function ImportaFun()

Local _aArea		:= GetArea()
Local _lRetorno		:= .T.
Local _aCadCliente	:= {}
Local _lMVCSA1      := U_ItGetMv( "MV_MVCSA1" , .F. ) // Parammetro para habilitar execução do ExecAuto do novo CRMA980 


Private nSaveSX8	:= ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.

//================================================================================
// VERIFICA SE ESTA REALIZANDO A INCLUSAO DE UM FUNCIONARIO
//================================================================================

_aCadCliente := vldImport( M->RA_CIC )

If Inclui .or. (Altera .and. _aCadCliente[1,1] .and.  alltrim(_cCPFAnterior) == alltrim(M->RA_CIC) )
		
	//================================================================================
	// VERIFICA SE O FUNCIONARIO JA POSSUI CADASTRO REALIZADO NO CADASTRO DE CLIENTES
	//================================================================================
	_aCadCliente := vldImport( M->RA_CIC )
	
	If _aCadCliente[1,1]
	
		//================================================================================
		// RECUPERA OS DADOS DO FUNCIONÁRIO PARA INCLUSÃO DO CLIENTE
		//================================================================================
		_aCliente := DadosImpor( 1 , "" , "" )
		
		lMsErroAuto := .F.
		
		//Guarda e recupera posição do SRA pois o execauto pode desposicionar
		_nposSRA := SRA->(Recno())
		_aCliente:=U_AcertaDados("SA1",_aCliente)//por causado MVC
		//================================================================================
		// Variavel que controla numeracao
		//================================================================================
		nSaveSX8 := GetSx8Len()
        If _lMVCSA1
            MSExecAuto( {|x,y,z| CRMA980(x,y,z) } , _aCliente , 3 , ) // SIGA AUTO PARA A INCLUSAO DO CLIENTE
		Else
            MSExecAuto( {|x,y,z| mata030(x,y,z) } , _aCliente ,, 3 ) // SIGA AUTO PARA A INCLUSAO DO CLIENTE
        EndIf
        SRA->(Dbgoto(_nposSRA))
		
		If lMsErroAuto
		
			If ( __lSX8 )
				RollBackSx8()
			EndIf
			
			MostraErro()
			
			u_itmsg(		"O cadastro do Funcionário: " + AllTrim(M->RA_NOME) + " possui alguns campos obrigatorios para realizar "	+;
							"a importacao para o cadastro de Clientes que não foram preenchidos."										,;
							"Informação!"																								,;
							"Desta forma não será gerada a sua importação, favor checar novamente o cadastro deste funcionario, ao "	+;
							"persistir o erro favor informar a área de TI/ERP."	,2														 )
			
			_lRetorno := .F.
			
		Else
		
			If __lSX8
				While ( GetSX8Len() > nSaveSX8 )
					ConfirmSX8()
				EndDo
			EndIf
			
		EndIf
		
	Else
		
		u_itmsg(		"O Funcionário: " + AllTrim(M->RA_NOME) + " ja possui um cadastro de cliente realizado"	,;
						"Informação"																			,;
						"Desta forma não será gerada a sua importação.",2										 )
	
	EndIf
	
//================================================================================
// VERIFICA SE ESTA REALIZANDO A ALTERACAO DE UM FUNCIONARIO
//================================================================================
ElseIf Altera

	_aCadCliente := vldImport( _cCPFAnterior )

	//================================================================================
	// SE O FUNCIONARIO JÁ FOI CADASTRADO COMO CLIENTE É POSSIVEL REALIZAR A ALTERACAO
	//================================================================================
	If !_aCadCliente[1,1]
		
		dbSelectArea("SA1")                      
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1") + _aCadCliente[1,2] + _aCadCliente[1,3]))
		
		    _aCliente := DadosImpor( 2 , _aCadCliente[1,2] , _aCadCliente[1,3] )
		
			//Guarda e recupera posição do SRA pois o execauto pode desposicionar
			_nposSRA := SRA->(Recno())
			
		    _aCliente:=U_AcertaDados("SA1",_aCliente)//por causado MVC

			lMsErroAuto := .F.
			
			RecLock( "SA1" , .F. )
			If _lMVCSA1
			    MSExecAuto( {|x,y,z| CRMA980(x,y,z)} , _aCliente , 4 , ) //SIGA AUTO PARA A ALTERAÇÃO DO CLIENTE
            Else
                MSExecAuto( {|x,y| MATA030(x,y)} , _aCliente , 4 ) //SIGA AUTO PARA A ALTERAÇÃO DO CLIENTE
            EndIf
            SA1->( MsUnlock() )
			
			SRA->(Dbgoto(_nposSRA))
		
		EndIf
				
		If lMsErroAuto
		
			MostraErro()
			
			u_itmsg(		"O cadastro do(a) Funcionário(a): " + AllTrim(M->RA_NOME) + " possui alguns campos obrigatorios para "		+;
							"realizar a importacao para o cadastro de clientes que nao foram preenchidos."								,;
							"Informação"																								,;
    							"Desta forma não será gerada a sua importação, favor checar novamente o cadastro deste(a) funcionario(a), "	+;
    							"ao persistir o erro favor contactar o depto de informática.",2												 )
			
   				_lRetorno := .F.
		
	    EndIf
	
	EndIf

EndIf
	                                  
//================================================================================
// Restaura a area
//================================================================================
RestArea( _aArea )

Return( _lRetorno )

/*
===============================================================================================================================
Programa----------: vldImport
Autor-------------: Fabiano Dias
Data da Criacao---: 07/07/2010
===============================================================================================================================
Descrição---------: Função que valida se já existe cadastro de cliente para o funcionário que está sendo inserido/alterado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRet - Retorna os dados referentes ao cadastro, ou indicação de que o mesmo não existe
===============================================================================================================================
*/

Static Function vldImport( _cCPF )

Local _nCntRec		:= 0
Local _cQuery		:= ""
Local _cAliasSA1	:= GetNextAlias()          
Local _aRet			:= {}

_cQuery := " SELECT" 
_cQuery += "     SA1.A1_COD ,"
_cQuery += "     SA1.A1_LOJA "
_cQuery += " FROM "+ RetSqlName("SA1") +" SA1 "
_cQuery += " WHERE "
_cQuery += "     SA1.D_E_L_E_T_ = ' ' "        
_cQuery += " AND SA1.A1_Filial  = '"+ xFilial("SA1") +"' "
_cQuery += " AND SA1.A1_MSBLQL  <> '1' "  
_cQuery += " AND SA1.A1_CGC     = '"+ _cCPF +"' "
	
If Select(_cAliasSA1) > 0
	(_cAliasSA1)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasSA1 , .T. , .F. )
COUNT TO _nCntRec

DBSelectArea(_cAliasSA1)    
(_cAliasSA1)->( DBGotop() )

If _nCntRec > 0
	aAdd( _aRet , { .F. , (_cAliasSA1)->A1_COD	, (_cAliasSA1)->A1_LOJA	})
Else
 	aAdd( _aRet , { .T. , ""					, ""					})
EndIf

(_cAliasSA1)->( DBCloseArea() )

Return( _aRet )

/*
===============================================================================================================================
Programa----------: DadosImpor
Autor-------------: Fabiano Dias
Data da Criacao---: 07/07/2010
===============================================================================================================================
Descrição---------: Função que insere os dados da importação dos funcionários para o cadastro de clientes de acordo com a
------------------: operação (inclusão/alteração)
===============================================================================================================================
Parametros--------: _nTipo   = 1 - Inclusão / 2 - Alteração
------------------: _cCodCli = Código do Cliente
------------------: _cLojCLi = Loja do Cliente
===============================================================================================================================
Retorno-----------: _aCliente - Retorna os dados referentes ao cadastro
===============================================================================================================================
*/

Static Function DadosImpor( _nTipo , _cCodCli , _cLojaCli )
                         
Local _aCliente		:= {}
Local _cCodVend		:= "000156"
Local _cDDD			:= ""
Local _cTel			:= ""
Local _cEmail		:= AllTrim( M->RA_EMAIL )
Local _cCContabil	:= ""
Local _cRisco		:= ""
Local _nLimite		:= 0
Local _dLimite		:= stod("20010101")

//================================================================================
// Valida de qual filial esta sendo executado o cadastro do 
// funcionario para preenchimento do campo A1_CONTA (HELP 583).
//================================================================================
Do Case

	Case cFilAnt $ '01/02/03/04/05/06'
		_cCContabil := "1102069998"
		
	Case cFilAnt $ '10/11/12/13/14/15/16/17/18/19/1A/1B/1C' 
		_cCContabil := "1102069999"
	
	Case cFilAnt $ '20/21/22'
		_cCContabil := "1102069993"
	
	Case cFilAnt == '30'
		_cCContabil := "1102064806"
	
	Case cFilAnt == '90'
		_cCContabil := "1102069996"
	
	Case cFilAnt == '91' 
		_cCContabil := "1102069992"
		
	OTHERWISE			
		_cCContabil := " "
	
EndCase

//================================================================================
// VERIFICA SE O FUNCIONARIO POSSUI TELEFONE
//================================================================================
If Len( AllTrim( M->RA_TELEFON ) ) > 0

	_cDDD	:= "0" + SubStr( M->RA_TELEFON , 1 , 2 )
    _cTel	:= SubStr( M->RA_TELEFON , 3 , 8 )

Else

	_cDDD :="999"
	_cTel :="99999999"
	
EndIf          
 
aAdd( _aCliente , { "A1_FILIAL"		, xFilial("SA1")			, Nil }) // FILIAL

//================================================================================ 	
//Carrega parâmetros de limite de crédito
//================================================================================ 	
_cRisco 	:= 	U_ITGETMV( "IT_RISCOFUN" , "B" )
_nLimite 	:=	U_ITGETMV( "IT_LIMFUNC" , 150 )
_dLimite 	:=	U_ITGETMV( "IT_VENCLIMFUNC" , stod("20491231") )


//================================================================================ 	
// Alteracao
//================================================================================
If _nTipo == 2

	aAdd( _aCliente , { "A1_COD"		, _cCodCli				, Nil }) // CODIGO DO CLIENTES
	aAdd( _aCliente , { "A1_LOJA"		, _cLojaCli				, Nil }) // LOJA DO CLENTE

EndIf

aAdd( _aCliente , { "A1_NOME"		, LEFT(M->RA_NOMECMP,LEN(SA1->A1_NOME))	, Nil }) // NOME
aAdd( _aCliente , { "A1_PESSOA"		, "F"						, Nil }) // PESSOA FISICA OU JURIDICA
aAdd( _aCliente , { "A1_CGC"		, M->RA_CIC					, Nil }) // CGC
aAdd( _aCliente , { "A1_NREDUZ"		, LEFT(M->RA_NOME,LEN(SA1->A1_NREDUZ))		, Nil }) // NOME REDUZIDO
aAdd( _aCliente , { "A1_TIPO"		, "F"						, Nil }) // TIPO DE CLIENTE
aAdd( _aCliente , { "A1_EST"		, M->RA_ESTADO				, Nil }) // ESTADO
aAdd( _aCliente , { "A1_COD_MUN"	, M->RA_CODMUN				, Nil }) // COD.MUNICIPIO
aAdd( _aCliente , { "A1_CEP"		, M->RA_CEP					, Nil }) // CEP
aAdd( _aCliente , { "A1_END"		, AllTrim(M->RA_ENDEREC)+", "+AllTrim(M->RA_LOGRNUM), Nil }) // ENDEREÇO   // aAdd( _aCliente , { "A1_END", M->RA_ENDEREC	, Nil }) // ENDEREÇO
aAdd( _aCliente , { "A1_BAIRRO"		, M->RA_BAIRRO				, Nil }) // BAIRRO
aAdd( _aCliente , { "A1_DDD"		, _cDDD						, Nil }) // DDD DO TELEFONE
aAdd( _aCliente , { "A1_TEL"		, _cTel						, Nil }) // NUMERO DO TELEFONE
aAdd( _aCliente , { "A1_PAIS"		, "105"						, Nil }) // PAIS
aAdd( _aCliente , { "A1_CODPAIS"	, "01058"					, Nil }) // PAIS BACEN
aAdd( _aCliente , { "A1_ESTC"		, M->RA_ESTADO				, Nil }) // ESTADO COBRANCA
aAdd( _aCliente , { "A1_I_CMUNC"	, M->RA_CODMUN				, Nil }) // COD.MUNICIPIO COBRANCA
aAdd( _aCliente , { "A1_CEPC"		, M->RA_CEP					, Nil }) // CEP COBRANCA
aAdd( _aCliente , { "A1_ENDCOB "	, AllTrim(M->RA_ENDEREC)+", "+AllTrim(M->RA_LOGRNUM), Nil }) // ENDERECO COBRANCA   // aAdd( _aCliente , { "A1_ENDCOB "	, M->RA_ENDEREC	, Nil }) // ENDERECO COBRANCA
aAdd( _aCliente , { "A1_BAIRROC"	, M->RA_BAIRRO				, Nil }) // BAIRRO COBRANCA
aAdd( _aCliente , { "A1_INSCR"		, ""						, Nil }) // INSCRICAO ESTADUAL
aAdd( _aCliente , { "A1_I_GRCLI"	, "39"						, Nil }) // GRUPO CLIENTE // "11" // SEGUIMENTO
aAdd( _aCliente , { "A1_NATUREZ"	, "111001"					, Nil }) // NATUREZA
aAdd( _aCliente , { "A1_VEND"		, _cCodVend					, Nil }) // CODIGO DO VENDEDOR
aAdd( _aCliente , { "A1_GRPVEN"		, "999999"					, Nil }) // GRUPO DE VENDAS
aAdd( _aCliente , { "A1_RISCO"		, _cRisco					, Nil }) // RISCO CLIENTE
IF _nTipo == 1//INCLUSAO
   aAdd( _aCliente,{ "A1_LC"		, _nLimite					, Nil }) // VALOR DO LIMITE
ELSE // ALTERAÇÃO 
   IF SA1->A1_LC < _nLimite 
      aAdd( _aCliente,{ "A1_LC"		, _nLimite					, Nil }) // VALOR DO LIMITE
   ENDIF
ENDIF
aAdd( _aCliente , { "A1_VENCLC"		, _dLimite					, Nil }) // DATA DE VENCIMENTO DO LIMITE
aAdd( _aCliente , { "A1_EMAIL"		, _cEmail					, Nil }) // EMAIL
aAdd( _aCliente , { "A1_CONTA"		, _cCContabil				, Nil }) // Conta Contabil
aAdd( _aCliente , { "A1_COND"		, "001"						, Nil }) // CONDICAO DE PAGTO INCLUSÃO 
aAdd( _aCliente , { "A1_CONTRIB"	, "2"						, Nil }) // Contribuinte do ICMS
aAdd( _aCliente , { "A1_SIMPNAC"	, "2"						, Nil }) // Opt Simples Nacional
aAdd( _aCliente , { "A1_CLIFUN"		, "1"						, Nil }) // Funcionário 
aAdd( _aCliente , { "A1_COMPLEM"	, M->RA_COMPLEM				, Nil }) // COMPLEMENTO DO ENDEREÇO.

Return( _aCliente )

//***********************************************************************************************************
/*
===============================================================================================================================
Programa----------: ImportFor
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 20/03/2017
===============================================================================================================================
Descrição---------: Função que importa os dados de funcionários para o cadastro de fornecedores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o cadastro foi importado ou não.
===============================================================================================================================
*/
Static Function ImportFor()

Local _aArea		:= GetArea()
Local _lRetorno		:= .T.
Local _aCadFornec	:= {}

Private nSaveSX8	:= ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.

//================================================================================
// VERIFICA SE O FUNCIONARIO JA POSSUI CADASTRO REALIZADO NO CADASTRO DE FORNECED
//================================================================================
_aCadFornec := vldFornec( _cCPFAnterior )
Dbselectarea("SA2")
SA2->(Dbsetorder(1))
	
If _aCadFornec[1,1]
	
	//================================================================================
	// RECUPERA OS DADOS DO FUNCIONÁRIO PARA INCLUSÃO DO FORNECEDOR
	//================================================================================
	_aFornec := DadosForn( 1 , "" , "" )

Elseif SA2->(Dbseek(xfilial("SA2")+_aCadFornec[1,2]+_aCadFornec[1,3]))
		
	//================================================================================
	// RECUPERA OS DADOS DO FUNCIONÁRIO PARA ALTERAÇÃO DO FORNECEDOR
	//================================================================================
	_aFornec := DadosForn( 2 , _aCadFornec[1,2] , _aCadFornec[1,3] )	
	
EndIf
	
	                                  
//================================================================================
// Restaura a area
//================================================================================
RestArea( _aArea )

Return( _lRetorno )

/*
===============================================================================================================================
Programa----------: vldFornec
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 20/03/2017
===============================================================================================================================
Descrição---------: Função que valida se já existe cadastro de fornecedor para o funcionário que está sendo inserido/alterado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRet - Retorna os dados referentes ao cadastro, ou indicação de que o mesmo não existe
===============================================================================================================================
*/

Static Function vldFornec( _cCPF )

Local _nCntRec		:= 0
Local _cQuery		:= ""
Local _cAliasSA2	:= GetNextAlias()          
Local _aRet			:= {}

_cQuery := " SELECT" 
_cQuery += "     SA2.A2_COD ,"
_cQuery += "     SA2.A2_LOJA "
_cQuery += " FROM "+ RetSqlName("SA2") +" SA2 "
_cQuery += " WHERE "
_cQuery += "     SA2.D_E_L_E_T_ = ' ' "        
_cQuery += " AND SA2.A2_Filial  = '"+ xFilial("SA2") +"' "
_cQuery += " AND SA2.A2_CGC     = '"+ _cCPF +"' "
	
If Select(_cAliasSA2) > 0
	(_cAliasSA2)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasSA2 , .T. , .F. )
COUNT TO _nCntRec

DBSelectArea(_cAliasSA2)
(_cAliasSA2)->( DBGotop() )

If _nCntRec > 0
	aAdd( _aRet , { .F. , (_cAliasSA2)->A2_COD	, (_cAliasSA2)->A2_LOJA	})
Else
 	aAdd( _aRet , { .T. , ""					, ""					})
EndIf

(_cAliasSA2)->( DBCloseArea() )

Return( _aRet )

/*
===============================================================================================================================
Programa----------: DadosForn
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 20/03/2017
===============================================================================================================================
Descrição---------: Função que insere os dados da importação dos funcionários para o cadastro de fornecedores de acordo com a
------------------: operação (inclusão/alteração)
===============================================================================================================================
Parametros--------: _nTipo   = 1 - Inclusão / 2 - Alteração
------------------: _cCodCli = Código do Cliente
------------------: _cLojCLi = Loja do Cliente
===============================================================================================================================
Retorno-----------: _aCliente - Retorna os dados referentes ao cadastro
===============================================================================================================================
*/

Static Function DadosForn( _nTipo , _cCodFor , _cLojaFor )

Local _aFornec		:= {}
Local aVetor 		:= {}

Default _cCodFor	:= U_ACOM005("J", "F", _cCPFAnterior)
Default _cLojaFor	:= "0001"

If Empty(_cCodFor)
	_cCodFor	:= U_ACOM005("J", "F", _cCPFAnterior)
EndIf

If Empty(_cLojaFor)
	_cLojaFor	:= "0001"
EndIf


//Monta array do execauto
aAdd( aVetor , {	"A2_I_CLASS"	, "J"												, nil } )
aAdd( aVetor , {	"A2_TIPO"		, "F"											 	, nil } )
aAdd( aVetor , {	"A2_CGC"		, M->RA_CIC											, nil } )
aAdd( aVetor , {	"A2_COD"		, _cCodFor											, nil } )
aAdd( aVetor , {	"A2_LOJA"		, _cLojaFor											, nil } )
aAdd( aVetor , {	"A2_NOME"		, AllTrim(M->RA_NOME)								, nil } ) 
aAdd( aVetor , {	"A2_NREDUZ"		, substr(AllTrim(M->RA_NOME),1,20)					, nil } ) 
aAdd( aVetor , {	"A2_EST"		, AllTrim(M->RA_ESTADO)								, nil } )
aAdd( aVetor , {	"A2_COD_MUN"	, AllTrim(M->RA_CODMUN)								, nil } )
aAdd( aVetor , {	"A2_MUN"	     ,ALLTRIM(POSICIONE('CC2',1,xFilial('CC2')+M->RA_ESTADO+M->RA_CODMUN,'CC2_MUN'))   , nil } )                                                           
aAdd( aVetor , {	"A2_CEP"		, AllTrim(M->RA_CEP)								, nil } )
aAdd( aVetor , {	"A2_END"		, AllTrim(M->RA_ENDEREC)+", "+AllTrim(M->RA_LOGRNUM), nil } )
aAdd( aVetor , {	"A2_BAIRRO"		, AllTrim(M->RA_BAIRRO)								, nil } )
aAdd( aVetor , {	"A2_DDD"		, AllTrim(M->RA_DDDFONE)							, nil } )
aAdd( aVetor , {	"A2_TEL"		, AllTrim(M->RA_TELEFON)							, nil } )
If !Empty( AllTrim(M->RA_EMAIL) )
	aAdd( aVetor , {	"A2_EMAIL"		,AllTrim(M->RA_EMAIL)								, nil } )
EndIf
IF _nTipo = 1//SÓ NA INCLUSAO
   aAdd( aVetor , {	"A2_BANCO"		, SubStr(M->RA_BCDEPSA,1,3)							, nil } )
   aAdd( aVetor , {	"A2_AGENCIA"	, SubStr(M->RA_BCDEPSA,4,5)							, nil } )
   aAdd( aVetor , {	"A2_NUMCON"		, substr(M->RA_CTDEPSA,1,10)						, nil } )
ENDIF
aAdd( aVetor , {	"A2_PAIS"		, '105'		 										, nil } )
aAdd( aVetor , {	"A2_CODPAIS"	, '01058'	 										, nil } )
aAdd( aVetor , {	"A2_TRIBFAV"	, '2'	 											, nil } )  
aAdd( aVetor , {	"A2_COMPLEM"	, M->RA_COMPLEM										, nil } ) // COMPLEMENTO DO ENDEREÇO

MSExecAuto( {|x,y| Mata020(x,y) } , aVetor , iif(_nTipo==2,4,3) )
	
IF lMSErroAuto
	
	DisarmTransaction()
		
	If ( __lSx8 )
		RollBackSx8()
	EndIf 
		
	Mostraerro()
	_lRet:= .F.    
		
Else        
	
	dbCommit()
		
	If ( __lSX8 )
		ConfirmSX8()
	EndIf				
		
Endif

M->RA_I_F := _cCodFor

Return( _aFornec )



/*
===============================================================================================================================
Programa--------: AcertaDados()
Autor-----------: Alex Wallauer
Data da Criacao-: 13/08/2021
===============================================================================================================================
Descrição-------: Acerta os dados para o tamanho do campo de destino por causado MVC
===============================================================================================================================
Parametros------: cAlias do MS EXECAUTO() ,_aDados: Array do MS EXECAUTO()
==============================================================================================================================
Retorno---------:_aDados
===============================================================================================================================
*/
*====================================================================================================*
User Function AcertaDados(cAlias,_aDados)
LOCAL D,_cCampo
Local aRet := {}
FOR D := 1 TO LEN(_aDados)
    IF VALTYPE(_aDados[D,2]) = "C"
        aRet := TamSx3(_aDados[D,1])
        IF aRet[3] <> "M"
            _cCampo:=(cAlias)->&(_aDados[D,1])
            _aDados[D,2]:=LEFT(_aDados[D,2],LEN( _cCampo ))
        ENDIF
	ENDIF
NEXT
RETURN _aDados
