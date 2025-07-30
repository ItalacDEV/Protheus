/* 
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 26/09/2019 | Revisão de fontes. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------                  
 Igor Melgaço     | 06/08/2021 | Troca de chamada mata030 por CRMA980 - Chamado 37363	
-------------------------------------------------------------------------------------------------------------------------------                  
 Igor Melgaço     | 04/11/2021 | Ajuste para troca do Execauto do CRMA980 pelo Mata030. Chamado 37363		
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: GP10MENU
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/06/2019
===============================================================================================================================
Descrição---------: Ponto de Entrada para incluir item no menu do cadastro de funcionarios - Chamado 29648
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function GPE10MENU()

aAdd(aRotina, { "Inclui Cliente", "fwmsgrun(,{|| U_IMPCLI()},'Aguarde...','Criando cliente...')", 0, 7, 0, Nil })
aAdd(aRotina, { "Inclui Fornecedor", "fwmsgrun(,{|| U_IMPFOR()},'Aguarde...','Criando fornecedor...')", 0, 7, 0, Nil })

Return

/*
===============================================================================================================================
Programa----------: IMPCLI
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/06/2019
===============================================================================================================================
Descrição---------: Cria cliente a partir do funcionario posicionado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function IMPCLI()

Local _aArea		:= GetArea()
Local _lMVCSA1      := U_ItGetMv( "MV_MVCSA1" , .F. ) // Parammetro para habilitar execução do ExecAuto do novo CRMA980 

Private nSaveSX8	:= ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.

//Valida se já não tem cliente com mesmo cnpj
SA1->(Dbsetorder(3))
If SA1->(Dbseek(xfilial("SA1")+SRA->RA_CIC))
    MsgAlert("Funcionário já possui cliente cadastrado sob código: " + SA1->A1_COD + "/" + SA1->A1_LOJA,"GPE010MENU01")
    Return
Endif

//================================================================================
// RECUPERA OS DADOS DO FUNCIONÁRIO PARA INCLUSÃO DO CLINTE
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
	MsgStop("O cadastro do Funcionário: " + AllTrim(SRA->RA_NOME) + " possui alguns campos obrigatórios para realizar a importação"	+;
			" para o cadastro de Clientes que não foram preenchidos. Desta forma não será gerada a sua importação, favor checar novamente"	+;
			" o cadastro deste funcionario, ao persistir o erro favor informar a área de TI/ERP.","GPE010MENU02")
Else
	If __lSX8
		While ( GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
	EndIf
    MsgInfo("Cliente " + SA1->A1_COD + "/" + SA1->A1_LOJA + "cadastrado com sucesso","GPE010MENU03")
EndIf
	                                  
//================================================================================
// Restaura a area
//================================================================================
RestArea( _aArea )

Return

/*
===============================================================================================================================
Programa----------: IMPFOR
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/06/2019
===============================================================================================================================
Descrição---------: Cria fornecedor a partir do funcionario posicionado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function IMPFOR()

Local aVetor := {}

//Valida se já não tem cliente com mesmo cnpj
SA2->(Dbsetorder(3))
If SA2->(Dbseek(xfilial("SA2")+SRA->RA_CIC))
    MsgStop("Funcionário já possui fornecedor cadastrado sob código: " + SA2->A2_COD + "/" + SA2->A2_LOJA,"GPE010MENU04")
    Return
Endif

_cCodFor	:= U_ACOM005("J", "F", SRA->RA_CIC)
_cLojaFor	:= "0001"

//Monta array do execauto
aAdd( aVetor , {	"A2_I_CLASS"	, "J"								, nil } )
aAdd( aVetor , {	"A2_TIPO"		, "F"								, nil } )
aAdd( aVetor , {	"A2_CGC"		, SRA->RA_CIC						, nil } )
aAdd( aVetor , {	"A2_COD"		, _cCodFor							, nil } )
aAdd( aVetor , {	"A2_LOJA"		, _cLojaFor							, nil } )
aAdd( aVetor , {	"A2_NOME"		, AllTrim(SRA->RA_NOME)				, nil } ) 
aAdd( aVetor , {	"A2_NREDUZ"		, substr(AllTrim(SRA->RA_NOME),1,20), nil } ) 
aAdd( aVetor , {	"A2_EST"		, AllTrim(SRA->RA_ESTADO)			, nil } )
aAdd( aVetor , {	"A2_COD_MUN"	, AllTrim(SRA->RA_CODMUN)			, nil } )
aAdd( aVetor , {	"A2_MUN"	     ,ALLTRIM(POSICIONE('CC2',1,xFilial('CC2')+SRA->RA_ESTADO+SRA->RA_CODMUN,'CC2_MUN'))   , nil } )                                                           
aAdd( aVetor , {	"A2_CEP"		, AllTrim(SRA->RA_CEP)				, nil } )
aAdd( aVetor , {	"A2_END"		, AllTrim(SRA->RA_ENDEREC)+", "+AllTrim(SRA->RA_LOGRNUM), nil } )
aAdd( aVetor , {	"A2_BAIRRO"		, AllTrim(SRA->RA_BAIRRO)			, nil } )
aAdd( aVetor , {	"A2_DDD"		, AllTrim(SRA->RA_DDDFONE)			, nil } )
aAdd( aVetor , {	"A2_TEL"		, AllTrim(SRA->RA_TELEFON)			, nil } )
If !Empty( AllTrim(SRA->RA_EMAIL) )
	aAdd( aVetor , {	"A2_EMAIL"		,AllTrim(SRA->RA_EMAIL)			, nil } )
EndIf
aAdd( aVetor , {	"A2_BANCO"		, SubStr(SRA->RA_BCDEPSA,1,3)		, nil } )
aAdd( aVetor , {	"A2_AGENCIA"	, SubStr(SRA->RA_BCDEPSA,4,5)		, nil } )
aAdd( aVetor , {	"A2_NUMCON"		, substr(SRA->RA_CTDEPSA,1,10)		, nil } )
aAdd( aVetor , {	"A2_PAIS"		, '105'		 						, nil } )
aAdd( aVetor , {	"A2_CODPAIS"	, '01058'	 						, nil } )
aAdd( aVetor , {	"A2_TRIBFAV"	, '2'	 							, nil } )

MSExecAuto( {|x,y| Mata020(x,y) } , aVetor , 3 )
	
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

Return

/*
===============================================================================================================================
Programa----------: DadosImpor
Autor-------------: Fabiano Dias
Data da Criacao---: 07/07/2010
===============================================================================================================================
Descrição---------: Função que insere os dados da importação dos funcionários para o cadastro de clientes de acordo com a
------------------: operação (inclusão/alteração)
===============================================================================================================================
Parametros--------: _cTipo   = 1 - Inclusão / 2 - Alteração
------------------: _cCodCli = Código do Cliente
------------------: _cLojCLi = Loja do Cliente
===============================================================================================================================
Retorno-----------: _aCliente - Retorna os dados referentes ao cadastro
===============================================================================================================================
*/
Static Function DadosImpor( _cTipo , _cCodCli , _cLojaCli )
                         
Local _aCliente		:= {}
Local _cCodVend		:= "000156"
Local _cDDD			:= ""
Local _cTel			:= ""
Local _cEmail		:= AllTrim( SRA->RA_EMAIL )
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
If Len( AllTrim( SRA->RA_TELEFON ) ) > 0
	_cDDD	:= "0" + SubStr( SRA->RA_TELEFON , 1 , 2 )
    _cTel	:= SubStr( SRA->RA_TELEFON , 3 , 8 )
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

aAdd( _aCliente , { "A1_NOME"		, LEFT(SRA->RA_NOMECMP,LEN(SA1->A1_NOME)), Nil }) // NOME
aAdd( _aCliente , { "A1_PESSOA"		, "F"						, Nil }) // PESSOA FISICA OU JURIDICA
aAdd( _aCliente , { "A1_CGC"		, SRA->RA_CIC				, Nil }) // CGC
aAdd( _aCliente , { "A1_NREDUZ"		, LEFT(SRA->RA_NOME,LEN(SA1->A1_NREDUZ))	, Nil }) // NOME REDUZIDO
aAdd( _aCliente , { "A1_TIPO"		, "F"						, Nil }) // TIPO DE CLIENTE
aAdd( _aCliente , { "A1_EST"		, SRA->RA_ESTADO			, Nil }) // ESTADO
aAdd( _aCliente , { "A1_COD_MUN"	, SRA->RA_CODMUN			, Nil }) // COD.MUNICIPIO
aAdd( _aCliente , { "A1_CEP"		, SRA->RA_CEP				, Nil }) // CEP
aAdd( _aCliente , { "A1_END"		, SRA->RA_ENDEREC			, Nil }) // ENDEREÇO
aAdd( _aCliente , { "A1_BAIRRO"		, SRA->RA_BAIRRO			, Nil }) // BAIRRO
aAdd( _aCliente , { "A1_DDD"		, _cDDD						, Nil }) // DDD DO TELEFONE
aAdd( _aCliente , { "A1_TEL"		, _cTel						, Nil }) // NUMERO DO TELEFONE
aAdd( _aCliente , { "A1_PAIS"		, "105"						, Nil }) // PAIS
aAdd( _aCliente , { "A1_CODPAIS"	, "01058"					, Nil }) // PAIS BACEN
aAdd( _aCliente , { "A1_ESTC"		, SRA->RA_ESTADO			, Nil }) // ESTADO COBRANCA
aAdd( _aCliente , { "A1_I_CMUNC"	, SRA->RA_CODMUN			, Nil }) // COD.MUNICIPIO COBRANCA
aAdd( _aCliente , { "A1_CEPC"		, SRA->RA_CEP				, Nil }) // CEP COBRANCA
aAdd( _aCliente , { "A1_ENDCOB "	, SRA->RA_ENDEREC			, Nil }) // ENDERECO COBRANCA
aAdd( _aCliente , { "A1_BAIRROC"	, SRA->RA_BAIRRO			, Nil }) // BAIRRO COBRANCA
aAdd( _aCliente , { "A1_INSCR"		, ""						, Nil }) // INSCRICAO ESTADUAL
aAdd( _aCliente , { "A1_I_GRCLI"	, "11"						, Nil }) // GRUPO CLIENTE
aAdd( _aCliente , { "A1_NATUREZ"	, "111001"					, Nil }) // NATUREZA
aAdd( _aCliente , { "A1_VEND"		, _cCodVend					, Nil }) // CODIGO DO VENDEDOR
aAdd( _aCliente , { "A1_GRPVEN"		, "999999"					, Nil }) // GRUPO DE VENDAS
aAdd( _aCliente , { "A1_RISCO"		, _cRisco					, Nil }) // RISCO CLIENTE
aAdd( _aCliente , { "A1_LC"			, _nLimite					, Nil }) // VALOR DO LIMITE
aAdd( _aCliente , { "A1_VENCLC"		, _dLimite					, Nil }) // DATA DE VENCIMENTO DO LIMITE
aAdd( _aCliente , { "A1_EMAIL"		, _cEmail					, Nil }) // EMAIL
aAdd( _aCliente , { "A1_CONTA"		, _cCContabil				, Nil }) // Conta Contabil
aAdd( _aCliente , { "A1_COND"		, "001"						, Nil }) // CONDICAO DE PAGTO INCLUSÃO 
aAdd( _aCliente , { "A1_CONTRIB"	, "2"						, Nil }) // Contribuinte do ICMS
aAdd( _aCliente , { "A1_SIMPNAC"	, "2"						, Nil }) // Opt Simples Nacional
aAdd( _aCliente , { "A1_CLIFUN"		, "1"						, Nil }) // Funcionário

Return( _aCliente )
