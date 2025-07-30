/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 26/12/2018 | Ajuste de leitura de limite de crédito - Chamado 26928
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 13/03/2019 | Ajuste no "Grava TXT" para reenvio do email do aquivo da cisp com Data do dia - Chamado 28402
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
--------------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMake.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FileIO.ch"	

#DEFINE ENTER	Chr(13)+Chr(10)

Static dDataRef := Date()
Static lViaSch	:= GetRemoteType() == -1

/*
===============================================================================================================================
Programa----------: MOMS027
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Programa de Integração com a CISP
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027()

Private oBrowseSZY	:= Nil
Private cCadastro	:= "Integração - CISP"
Private aRotina		:= { 	{ 'Pesquisar'  	, 'AxPesqui'			, 0 , 1 } ,;
							{ 'Visualizar'	, 'U_MOMS027V'			, 0 , 2 } ,;
							{ 'Alterar'		, 'Axaltera'			, 0 , 4 } ,;
							{ 'Excluir'		, 'U_MOMS027D'			, 0 , 5 } ,;
							{ 'Processar'	, 'U_MOMS027X'			, 0 , 3 } ,;
							{ 'Grava TXT'	, 'U_MOMS027T(.F.,.F.)'	, 0 , 7 } ,;
							{ 'Validar'		, 'U_MOMS027L(1,.F.)'	, 0 , 8 } ,;
							{ 'Validar TXT'	, 'U_MOMS027I'			, 0 , 8 }  }


//Grava log de utilização
u_itlogacs()


//===========================================================================
//| Verifica a aplicação do Update do Chamado 5531                          |
//===========================================================================
If AliasInDic("SZY")

	oBrowseSZY := FWMBrowse():New()
	oBrowseSZY:DisableDetails()
	oBrowseSZY:SetAlias("SZY")
	oBrowseSZY:Activate()

Else
	
	u_itmsg(  "Para utilizar a integração é necessário aplicar a atualização de dicionários 'UPDCISP'." , "Atenção!",,1 )
	
EndIF

Return()

/*
===============================================================================================================================
Programa----------: MOMS027X
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de controle da atualização dos dados da base CISP
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027X()

Local cPerg			:= "MOMS027"
Local lThread			:= .F.
Local aparam			:= {cEmpAnt,cFilAnt,.T.,.F.}

//===========================================================================
//| Verifica o acesso do usuário à alteração dos dados da base da CISP      |
//===========================================================================
If !U_ITVLDUSR(4)

	u_itmsg("Usuário sem acesso à alteração dos dados da base da CISP.","Atenção", "Verifique com a área de TI/ERP.",1)

	Return()
	
EndIf


If !Pergunte( cPerg )
	u_itmsg( "Operação cancelada pelo usuário." , "Atenção!",,1 )
	Return()
EndIf

lThread := ( MV_PAR05 == 2 )

//===========================================================================
//| Chama a rotina de processamento                                         |
//===========================================================================
If lThread

	StartJob( "U_MOMS027P" , GetEnvServer() , .F. , Nil , .T. , cEmpAnt , cFilAnt , .T. )
	
	LjMsgRun( "Verificando o ambiente..." , "Aguarde!" , {|| Sleep(2000) } )
	
	
		//seta parâmetros como se fosse JOB
		
		MV_PAR01 := "00000000"
		MV_PAR02 := "99999999"
		MV_PAR03 := "000000"
		MV_PAR04 := "ZZZZZZ"
		MV_PAR05 := 2
		MV_PAR06 := GetMV( "IT_CISPENV" ,, 1 )
			
		U_MOMS027P( aparam , lThread ) //executa como se fosse job mas sem verificar dia da semana permitido
	
Else

	U_MOMS027P( Nil , lThread )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS027P
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina que processa a atualização dos dados da base CISP
===============================================================================================================================
Parametros--------: lThread		- se verdadeiro define que a rotina está sendo executada via JOB
------------------: cEmpAux		- variável da Empresa para criação do ambiente via JOB
------------------: cFilAux		- variável da Filial para criação do ambiente via JOB
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027P( aParam , lThread , cEmpAux , cFilAux , lJobMan )

//Local cDiaSem	:= ""
//Local cDiaAut	:= ""

Default aParam	:= {}
Default lThread := .F.
Default lJobMan	:= .F.

//===========================================================================
//| Verifica a entrada de Parâmetros                                        |
//===========================================================================
If !Empty(aParam) 
	cEmpAux	:= aParam[01]  
	cFilAux	:= aParam[02]
	lThread	:= .T.
	lJobMan	:= .F.
EndIF

//===========================================================================
//| Processa a abertura do ambiente caso a execução seja via JOB            |
//===========================================================================
If lThread
	
	
	//===========================================================================
	//| Prepara o ambiente pra processamento do JOB                             |
	//===========================================================================
	
	u_itconout("Iniciando processo de integracao CISP")
	
	RpcClearEnv()
	RpcSetType(2)
		
	If !RPCSETENV( cEmpAux , cFilAux )
		Return()
	EndIf
				
	//===========================================================================
	//| Chama o processo de atualização                                         |
	//===========================================================================
	MOMS027ATU( lThread )
	
Else

	//===========================================================================
	//| Chama o processo de atualização com a janela de acompanhamento          |
	//===========================================================================
	Proc2BarGauge( {|| MOMS027ATU( lThread ) } , "Atualização da Base de Dados" , "Processando..." , "Aguardando o Início..." , .T. )
	
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS027ATU
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de atualização dos dados
===============================================================================================================================
Parametros--------: lThread		- se verdadeiro define que a rotina está sendo executada via JOB
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027ATU( lThread )

Local _aCodCli	:= {}
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ''
Local _nnj		:= 0 

Local cAlias	:= GetNextAlias()
Local cPerg		:= "MOMS027"
Local cQuery	:= ""
Local cCodCisp	:= AllTrim( GetMV( "IT_CISPCOD" ,, "0095" ) )
Local cCNPJ		:= ""

Local _dDataDE2	:= YEARSUB( dDataRef , 1 )
Local dDataAc	:= STOD("")
Local dDataAnt	:= STOD("")
Local nVLimCre	:= 0
Local nValorX	:= 0
Local nValorY	:= 0
Local nValorZ	:= 0
Local nValorA	:= 0
Local nValACX	:= 0
Local nValACY	:= 0
Local nValACZ	:= 0
Local nValACA	:= 0
Local nValAVX	:= 0
Local nValAVY	:= 0
Local nValAVZ	:= 0
Local nValAVA	:= 0
Local nValTX	:= 0
Local nValTY	:= 0
Local nValTZ	:= 0
Local nValTA	:= 0
Local nDiasAt	:= 0
Local nSaldo	:= 0
Local nSaldoAC	:= 0
Local nSaldoAnt	:= 0
Local nI		:= 0
Local nTotReg	:= 0
Local nVal05	:= 0
Local nValAc05	:= 0
Local nVal15	:= 0
Local nValAc15	:= 0
Local nVal30	:= 0
Local nValAc30	:= 0
Local nValDebT	:= 0
//Local nValor01	:= 0
//Local nValor02	:= 0
Local _atitulos := {}

Default lThread	:= .F.

//===========================================================================
//| Verifica se a rotina está sendo executada via JOB                       |
//===========================================================================
IF lThread
	
	//===========================================================================
	//| Caso necessário inicializa os parâmetros de configuração                |
	//===========================================================================
	IF Type(MV_PAR05) <> "N"
	
		Pergunte( cPerg , .F. )
		
		MV_PAR01 := "00000000"
		MV_PAR02 := "99999999"
		MV_PAR03 := "000000"
		MV_PAR04 := "ZZZZZZ"
		MV_PAR05 := 2
		MV_PAR06 := GetMV( "IT_CISPENV" ,, 1 )
		
	EndIF
	
Else

	//===========================================================================
	//| Define a quantidade de Processos                                        |
	//===========================================================================
	BarGauge1Set(04)
	
	//===========================================================================
	//| Inicializa barras de processamento                                      |
	//===========================================================================
	IncProcG1( "Atualização de Clientes [ Processo 01 de 03 ]" )
	ProcessMessage()
	
	IncProcG2( "Lendo registros..." )
	ProcessMessage()

EndIF

u_itconout("Atualização de Clientes [ Processo 01 de 03 ] - Lendo registros...")

//===========================================================================
//| Monta a consulta de atualização do Cadastro de Clientes na base da CISP |
//===========================================================================
cQuery := " SELECT "+ENTER
cQuery += " 	'1'				   		AS PCTIPO	,"+ENTER
cQuery += " 	'"+ cCodCisp +"'   		AS PCCASS	,"+ENTER
cQuery += " 	SUBSTR(SA1.A1_CGC,1,8)	AS PCCCLI	,"+ENTER
cQuery += " 	'00000000'		   		AS PCDDAT	,"+ENTER
cQuery += " 	MIN(SA1.A1_I_DTCAD)		AS PCDCDD	,"+ENTER
cQuery += " 	'00000000'		 		AS PCDUCM	,"+ENTER
cQuery += " 	'000000000000000'  		AS PCVULC	,"+ENTER
cQuery += " 	'00000000'		   		AS PDCMAC	,"+ENTER
cQuery += " 	'000000000000000'  		AS PCVMAC	,"+ENTER
cQuery += " 	'000000000000000'  		AS PCVSAT	,"+ENTER
cQuery += " 	'000000000000000'  		AS PCVLCR	,"+ENTER
cQuery += " 	'000000'		   		AS PCQPAG	,"+ENTER
cQuery += " 	'000000'		   		AS PCQDAP	,"+ENTER
cQuery += " 	'000000000000000'  		AS PCVDAV	,"+ENTER
cQuery += " 	'000000'		   		AS PCMDAV	,"+ENTER
cQuery += " 	'000000'		   		AS PCMPMV	,"+ENTER
cQuery += " 	'000000000000000'  		AS PCDATV	,"+ENTER
cQuery += " 	'0000'			   		AS PCMTV	,"+ENTER
cQuery += " 	'000000000000000'		AS PCV15D	,"+ENTER
cQuery += " 	'0000'					AS PCM15D	,"+ENTER
cQuery += " 	'000000000000000'		AS PCV30D	,"+ENTER
cQuery += " 	'0000'					AS PCM30D	,"+ENTER
cQuery += " 	'00000000'				AS PCDTPC	,"+ENTER
cQuery += " 	'000000000000000'		AS PCVPCO	,"+ENTER
cQuery += " 	'2'						AS PCVSIT	,"+ENTER
cQuery += " 	'0'						AS PCTIPG	,"+ENTER
cQuery += " 	'00'					AS PCGGA	,"+ENTER
cQuery += " 	'00000000'				AS PCDTG	,"+ENTER
cQuery += " 	'000000000000000'		AS PCVLG	,"+ENTER
cQuery += " 	'000000000000000'		AS PCVPA	,"+ENTER
cQuery += " 	'  '					AS PCSVV	 "+ENTER
cQuery += " FROM "+ RetSqlName("SA1") +" SA1 "+ENTER

cQuery += " WHERE "+ENTER
cQuery += " 		SA1.D_E_L_E_T_			= ' ' "+ENTER
cQuery += " AND		SA1.A1_PESSOA			= 'J' "+ENTER
cQuery += " AND		SA1.A1_FILIAL			= '"+ xFilial("SA1") +"' "+ENTER
cQuery += " AND		SUBSTR(SA1.A1_CGC,1,8)	<> '"+ Space(08) +"' "+ENTER
cQuery += " AND		SUBSTR(SA1.A1_CGC,1,8)	<> '00000000' "+ENTER
cQuery += " AND		SA1.A1_I_DTCAD			< '"+ DtoS(dDataRef) +"' "+ENTER
cQuery += " AND		NOT EXISTS				( SELECT SZY.ZY_PCCCLI FROM "+ RetSqlName("SZY") +" SZY WHERE TRIM(SZY.ZY_PCCCLI) = TRIM(SUBSTR(SA1.A1_CGC,1,8)) AND TRIM(SZY.D_E_L_E_T_) IS NULL ) "+ENTER
cQuery += " AND		SA1.A1_COD				> '000001' "
cQuery += " AND		SUBSTR(SA1.A1_CGC,1,8)  BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "+ENTER
cQuery += " AND		SA1.A1_COD  BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "+ENTER
cQuery += " AND      SA1.A1_FILIAL = '" + xfilial("SA1") + "'"

cQuery += " GROUP BY SUBSTR(SA1.A1_CGC,1,8) "+ENTER
cQuery += " ORDER BY SUBSTR(SA1.A1_CGC,1,8) "+ENTER

//===========================================================================
//| Verifica e inicializa os dados para análise                             |
//===========================================================================
If Select(cAlias) > 0
	(cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAlias , .T. , .F. )

nI		:= 0
nTotReg	:= 0

DBSelectArea(cAlias)
(cAlias)->( DBGoTop() )

//===========================================================================
//| Tratativa das mensagens para processamento via JOB ou Rotina            |
//===========================================================================
IF !(lThread)
	
	(cAlias)->( DBEVAL( {|| nTotReg++ } ) )
	(cAlias)->( DBGoTop() )
	
	BarGauge2Set(nTotReg)

EndIF

//===========================================================================
//| Inclui os Clientes na Base da CISP                                      |
//===========================================================================
While (cAlias)->(!Eof())
	
	nI++
	
	IF !lThread
	
		IncProcG2( "["+StrZero(nI,9)+"] de ["+StrZero(nTotReg,9)+"]" )
		ProcessMessage()
	
	EndIF
	
	u_itconout("Atualizando clientes - ["+StrZero(nI,9)+"] de ["+StrZero(nTotReg,9)+"]")

	If !SZY->( DbSeek( xFilial("SZY") + (cAlias)->PCCCLI ) )
	
		SZY->( RecLock( "SZY" , .T. ) )
		
			SZY->ZY_FILIAL	:= xFilial("SZY")
			SZY->ZY_PCTIPO	:= (cAlias)->PCTIPO
			SZY->ZY_PCCASS	:= (cAlias)->PCCASS
			SZY->ZY_PCCCLI	:= (cAlias)->PCCCLI
			SZY->ZY_PCDCDD	:= STOD( (cAlias)->PCDCDD	)
			SZY->ZY_PCVULC	:= Val( (cAlias)->PCVULC	)
			SZY->ZY_PCVMAC	:= Val( (cAlias)->PCVMAC	)
			SZY->ZY_PCVSAT	:= Val( (cAlias)->PCVSAT	)
			SZY->ZY_PCVLCR	:= Val( (cAlias)->PCVLCR	)
			SZY->ZY_PCQPAG	:= Val( (cAlias)->PCQPAG	)
			SZY->ZY_PCQDAP	:= Val( (cAlias)->PCQDAP	)
			SZY->ZY_PCVDAV	:= Val( (cAlias)->PCVDAV	)
			SZY->ZY_PCMDAV	:= Val( (cAlias)->PCMDAV	)
			SZY->ZY_PCMPMV	:= Val( (cAlias)->PCMPMV	)
			SZY->ZY_PCDATV	:= Val( (cAlias)->PCDATV	)
			SZY->ZY_PCMPTV	:= Val( (cAlias)->PCMTV		)
			SZY->ZY_PCV15D	:= Val( (cAlias)->PCV15D	)
			SZY->ZY_PCM15D	:= Val( (cAlias)->PCM15D	)
			SZY->ZY_PCV30D	:= Val( (cAlias)->PCV30D	)
			SZY->ZY_PCM30D	:= Val( (cAlias)->PCM30D	)
			SZY->ZY_PCVPCO	:= Val( (cAlias)->PCVPCO	)
			SZY->ZY_PCVSIT	:= (cAlias)->PCVSIT
			SZY->ZY_PCTIPG	:= (cAlias)->PCTIPG
			SZY->ZY_PCGGA	:= (cAlias)->PCGGA
			SZY->ZY_PCDTG	:= STOD( (cAlias)->PCDTG	)
			SZY->ZY_PCVLG	:= Val( (cAlias)->PCVLG		)
			SZY->ZY_PCVPA	:= Val( (cAlias)->PCVPA		)
			SZY->ZY_PCSVV	:= (cAlias)->PCSVV
			
		SZY->(MsUnlock())
		
	EndIf
	
(cAlias)->(DBSKIP())
ENDDO

(cAlias)->( DBCloseArea() )

//===========================================================================
//| Tratativa das mensagens para processamento via JOB ou Rotina            |
//===========================================================================
IF !(lThread)

	//===========================================================================
	//| Inicializa barras de processamento                                      |
	//===========================================================================
	IncProcG1( "Atualização de Valores [ Processo 02 de 03 ]" )
	ProcessMessage()
	
	BarGauge2Set(0)
	IncProcG2( "Lendo registros..." )
	ProcessMessage()

EndIF

u_itconout("Atualização de Valores [ Processo 02 de 03 ] - Lendo registros...")

//===========================================================================
//| Monta consulta para análise dos Valores dos Clientes                    |
//===========================================================================
cQuery := " SELECT "+ENTER
cQuery += " 	SUBSTR(SA1.A1_CGC,1,8)	AS CNPJ, "+ENTER
cQuery += " 	SA1.A1_COD AS A1_COD, "+ENTER
cQuery += " 	SA1.A1_LOJA AS A1_LOJA, "+ENTER
cQuery += " 	SE1.E1_EMISSAO			AS DATACC, "+ENTER
cQuery += " 	SE1.E1_VALOR + SE1.E1_SDACRES + SE1.E1_JUROS - SE1.E1_SDDECRE AS VALOR, "+ENTER
cQuery += " 	SE1.E1_SALDO			AS SALDO, "+ENTER
cQuery += " 	SE1.E1_VENCREA AS VENCTO, "+ENTER
cQuery += " 	SE1.E1_FILIAL			, "+ENTER
cQuery += " 	SE1.E1_PREFIXO			, "+ENTER
cQuery += " 	SE1.E1_NUM			, "+ENTER
cQuery += " 	SE1.E1_PARCELA			, "+ENTER
cQuery += " 	SE1.E1_TIPO			, "+ENTER
cQuery += " 	SE1.E1_CLIENTE			, "+ENTER
cQuery += " 	SE1.E1_LOJA			, "+ENTER
cQuery += " 	1              AS ORDEM "+ENTER

cQuery += " FROM "+ RetSqlName("SE1") +" SE1 "+ENTER

cQuery += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON "+ENTER
cQuery += " 	SE1.E1_CLIENTE			= SA1.A1_COD "+ENTER
cQuery += " AND	SE1.E1_LOJA				= SA1.A1_LOJA "+ENTER
cQuery += " AND	SA1.D_E_L_E_T_			= ' ' "+ENTER
cQuery += " AND	SA1.A1_FILIAL			= '"+ xFilial("SA1") +"' "+ENTER
cQuery += " AND	SA1.A1_PESSOA			= 'J' "+ENTER

cQuery += " WHERE "+ENTER
cQuery += " 	SE1.D_E_L_E_T_			= ' ' "+ENTER
cQuery += " AND	SE1.E1_I_AVACC <> 'N' " +ENTER
cQuery += " AND	SE1.E1_TIPO				NOT IN ('NCC','RA', 'NDC') "+ENTER
cQuery += " AND	SE1.E1_CLIENTE			> '000001' "+ENTER
cQuery += " AND	SUBSTR(SA1.A1_CGC,1,8)	BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "+ENTER
cQuery += " AND	SE1.E1_EMISSAO			< '"+ DtoS( dDataRef ) +"' "+ENTER
cQuery += " AND SE1.E1_VENCREA > '" + DTOS(dDataRef - 1825) +"' "+ENTER
cQuery += " AND	SA1.A1_COD  BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "+ENTER     
cQuery += " AND SA1.A1_FILIAL = '" + xfilial("SA1") + "'"
cQuery += " ORDER BY CNPJ, DATACC, ORDEM "+ENTER


If Select(cAlias) > 0
	(cAlias)->( DBCloseArea() )
EndIf

IF !(lThread)
	
	IncProcG2( "Preparando tabela temporária..." )
	ProcessMessage()

EndIF

u_itconout("Atualização de Valores [ Processo 02 de 03 ] - Preparando tabela temporária...")

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAlias , .T. , .F. )

//===========================================================================
//| Inicializa o ambiente e processa a leitura e gravação dos dados         |
//===========================================================================
DBSelectArea(cAlias)
(cAlias)->( DBGoTop() )

nI			:= 0
nTotReg		:= 0

//===========================================================================
//| Tratativa das mensagens para processamento via JOB ou Rotina            |
//===========================================================================
(cAlias)->( DBEVAL( {|| nTotReg++ } ) )
(cAlias)->( DBGoTop() )

IF !(lThread)
	
	BarGauge2Set(nTotReg)

EndIF

//===========================================================================
//| Processa a análise e gravação dos dados                                 |
//===========================================================================
While !(cAlias)->(Eof())

	//===========================================================================
	//| Variáveis de controle                                                   |
	//===========================================================================
	cCNPJ		:= (cAlias)->CNPJ
	
	//Verifica se já foi gravado
	DBSelectArea("SZY")
	SZY->( DBSetOrder(1) )
	IF SZY->( DbSeek( xFilial("SZY") + cCNPJ ) ) .and. SZY->ZY_PCDDAT == dDataRef
	
		nI++
		u_itconout("Atualização de Valores [ Processo 02 de 03 ] - ["+StrZero(nI,9)+"] de ["+StrZero(nTotReg,9)+"]")
	
		(cAlias)->(Dbskip())
		Loop
		
	Endif
	
	nVLimCre	:= U_MOMS027K((cAlias)->A1_COD,(cAlias)->A1_LOJA)
	
	
	//===========================================================================
	//| Variáveis dos Cálculos das Médias                                       |
	//===========================================================================
	nValorX		:= 0
	nValorY		:= 0
	nValorZ		:= 0
	nValorA		:= 0
	nValACX		:= 0
	nValACY		:= 0
	nValACZ		:= 0
	nValACA		:= 0
	nValAVX		:= 0
	nValAVY		:= 0
	nValAVZ		:= 0
	nValAVA		:= 0
	nValTX		:= 0
	nValTY		:= 0
	nValTZ		:= 0
	nValTA		:= 0
	nDiasAt		:= 0
	nValTOT		:= 0
	
	//===========================================================================
	//| Variáveis de Atualização dos Saldos do Cliente                          |
	//===========================================================================
	nSaldo		:= 0
	nSaldoAC	:= 0
	dDataAc		:= StoD("")
	nSaldoAnt	:= 0
	dDataAnt	:= StoD("")
	
	//===========================================================================
	//| Variáveis de Atualização da Penúltima e Última compra do Cliente        |
	//===========================================================================
	nValUC		:= 0
	dDataUC		:= StoD("")
	nValPC		:= 0
	dDataPC		:= StoD("")
	
	//===========================================================================
	//| Variáveis do cálculo de atrasos dos Clientes                            |
	//===========================================================================
	nDiasAtr	:= 0
	nVal05		:= 0
	nValAc05	:= 0
	nVal15		:= 0
	nValAc15	:= 0
	nVal30		:= 0
	nValAc30	:= 0
	nValDebT	:= 0
	
	//Array de titulos acumulados
	_atitulos := {}
	
	While !(cAlias)->(Eof()) .And. (cAlias)->CNPJ == cCNPJ
	
		nI++
		
		IF !lThread
		
			IncProcG2("["+StrZero(nI,9)+"] de ["+StrZero(nTotReg,9)+"]")
			ProcessMessage()
		
		EndIF
		
		u_itconout("Atualização de Valores [ Processo 02 de 03 ] - ["+StrZero(nI,9)+"] de ["+StrZero(nTotReg,9)+"]")
 		
		//===========================================================================
		//| Construção do Saldo através da C.C. do Cliente                          |
		//===========================================================================
		If StoD( (cAlias)->DATACC ) >= _dDataDE2 .and. (cAlias)->ORDEM == 1
					
			aadd(_atitulos,{(cAlias)->(Recno()),; 	//1
				0,;						//2
				(cAlias)->E1_FILIAL,;	//3
				 (cAlias)->E1_PREFIXO,;	//4
				 (cAlias)->E1_NUM,;		//5
				 (cAlias)->E1_PARCELA,;	//6
				 (cAlias)->VALOR,;		//7
				 (cAlias)->E1_TIPO,;	//8
				 (cAlias)->E1_CLIENTE,;	//9
				 (cAlias)->E1_LOJA,;   //10
				 (cAlias)->DATACC ,;  //11
				  { }             } )	//12

			_atitulos[len(_atitulos)][12] := MOMS0278(_atitulos[len(_atitulos)] )
			nSaldo := 0
		
			//Roda todos os titulos anteriores para pegar os saldos no dia do novo titulo
			For _nnj := 1 to len(_atitulos)
				
				nSaldo += MOMS0279(_atitulos[_nnj][12],(cAlias)->DATACC)
			
			Next

			//===========================================================================
			//| Não permite saldo negativo por conta de pagamento de Juros/Multa        |
			//===========================================================================
			If nSaldo < 0
				nSaldo := 0
			EndIf
		
			_atitulos[len(_atitulos)][2] := nSaldo		
							
			//===========================================================================
			//| Atualização dos dados de Maior Acúmulo do Cliente                       |
			//===========================================================================
			If nSaldo >= nSaldoAc

				nSaldoAc	:= nSaldo
				dDataAc		:= STOD( (cAlias)->DATACC )

			EndIf
						
		EndIF
		
	(cAlias)->(DbSkip())
	EndDo
		
	
	//===============================================================================================
	// Cálculo das Médias de Atraso
	//===============================================================================================
	_aCodCli	:= {}
	_cQuery	:= " SELECT SA1.A1_COD,SA1.A1_LOJA,A1_I_DTCAD FROM "
	_cQuery	+= RetSqlName('SA1') +" SA1 WHERE SA1.D_E_L_E_T_ = ' ' AND SUBSTR( SA1.A1_CGC , 1 , 8 ) = '"+ AllTrim( cCNPJ ) +"' "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
		
	If (_cAlias)->( !Eof() )
	
			_ccodcli := (_cAlias)->A1_COD
			_clojacli := (_cAlias)->A1_LOJA
			
								
			(_cAlias)->( DBCloseArea() )
		
			_cQuery := " SELECT "
			_cQuery += "     SE1.E1_VENCREA AS VENCTO,"
			_cQuery += "     SE1.E1_BAIXA   AS BAIXA ,"
			_cQuery += "     SE1.E1_VALOR   AS VALOR,  "
			_cQuery += "     SE1.E1_SALDO   AS SALDO  "
			_cQuery += " FROM "+ RetSqlName('SE1') +" SE1 "
			_cQuery += " WHERE "
			_cQuery += "      SE1.D_E_L_E_T_ = ' ' "   
			_cQuery += " AND  SE1.E1_CLIENTE = '"+ _ccodcli +"' "
			_cQuery += " AND  SE1.E1_TIPO    NOT IN ('NCC','RA','NDC') "
			_cQuery += " AND  SE1.E1_I_AVACC <> 'N' " +ENTER
			_cQuery += " AND  SE1.E1_CLIENTE > '000001' "
			_cQuery += " AND  SE1.E1_VENCREA > '" + DTOS(dDataRef - 1825) +"' "+ENTER
			_cQuery += " AND  SE1.E1_EMISSAO < '"+ DtoS( dDataRef ) +"' "+ENTER
	
			
			If Select(_cAlias) > 0
				(_cAlias)->( DBCloseArea() )
			EndIf
			
			DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
			
			DBSelectArea(_cAlias)
			(_cAlias)->( DBGoTop() )
			While (_cAlias)->( !Eof() )
			
			
				//==========================================================================
				// Soma total dos titulos em aberto
				//==========================================================================
				nValTX += (_cAlias)->SALDO								// Soma o valor dos títulos 
				nValTY += nDiasAt										// Soma a quantidade de dias  do Cliente
				nValTZ += ( (_cAlias)->SALDO * nDiasAt )				// Soma a quantidade de dias x valor do título 
				nValTA++												// Soma a quantidade de titulos 
	
			
				//===========================================================================
				//| Guarda os valores a vencer para os calculos                             |
				//===========================================================================
				IF StoD( (_cAlias)->VENCTO ) > dDataRef .And. (_cAlias)->SALDO > 0
			
					nDiasAt := StoD( (_cAlias)->VENCTO ) - dDataRef
					
			      	IF nDiasAt < 0
			      	
			      		nDiasAt := 0
		        	
		        	EndIF
		
	        	
					nValAVX += (_cAlias)->SALDO								// Soma o valor dos títulos a vencer
					nValAVY += nDiasAt										// Soma a quantidade de dias a vencer do Cliente
					nValAVZ += ( (_cAlias)->SALDO * nDiasAt )				// Soma a quantidade de dias a vencer x valor do título a vencer
					nValAVA++												// Soma a quantidade de titulos a vencer
				
				EndIF
			
				//===========================================================================
				//| Calcula os Saldos e Médias de Títulos em Aberto e em Atraso             |
				//===========================================================================
				IF (_cAlias)->SALDO > 0 
            
					nDiasAtr := dDataRef - StoD( (_cAlias)->VENCTO )
				
					IF nDiasAtr > 5
						nVal05		+= Round( (_cAlias)->SALDO , 2 )
						nValAc05	+= Round( nDiasAtr * (_cAlias)->SALDO , 2 )
					EndIF
				
					IF nDiasAtr > 15
						nVal15		+= Round( (_cAlias)->SALDO , 2 )
						nValAc15	+= Round( nDiasAtr * (_cAlias)->SALDO , 2 )
					EndIF
				
					IF nDiasAtr > 30
						nVal30		+= Round( (_cAlias)->SALDO , 2 )
						nValAc30	+= Round( nDiasAtr * (_cAlias)->SALDO , 2 )
					EndIF
			
				EndIF
	
			
				//===============================================================================================
				// Guarda valores dos Títulos Baixados para o Cálculo das Médias de Atraso
				//===============================================================================================
		       	IF (_cAlias)->SALDO = 0 
		       	
		       		If StoD( (_cAlias)->BAIXA ) > Stod( '19900101' )
		       	
		       			nDiasAt := StoD( (_cAlias)->BAIXA ) - StoD( (_cAlias)->VENCTO )
		       		
		       		Else
		       	
		       			nDiasAt := dDataRef - StoD( (_cAlias)->VENCTO )
		       	
		       		Endif
		        
		       		IF nDiasAt < 0
		       			nDiasAt := 0
		       		EndIF
		        
		       		nValorX	+= ( (_cAlias)->VALOR  )	// Soma o valor dos títulos pagos
		       		nValorY += nDiasAt					 					// Soma a Quantidade de Dias em Atraso do Cliente
		       		nValorZ += ( ( (_cAlias)->VALOR  ) * nDiasAt )			// Soma a Quantidade de Dias em Atraso x Valor do Título Pagos com Atraso
		       		nValorA++												// Soma a Quantidade de títulos baixados
		       		
		       	Endif
				
			(_cAlias)->( DBSkip() )
			
			
			EndDo
			
			(_cAlias)->( DBCloseArea() )
			 
			//==========================================================================
			//Determina data e valor de última e penultima compra
			//==========================================================================
			_cQuery := " SELECT "
			_cQuery += "  		SF2.F2_EMISSAO EMISSAO, NVL(SUM(SF2.F2_VALBRUT),0) VALOR "
			_cQuery += " FROM "+ RetSqlName('SF2') +" SF2 "
			_cQuery += " WHERE "
			_cQuery += "      SF2.D_E_L_E_T_ = ' ' "
			_cQuery += " AND  SF2.F2_CLIENTE = '"+ _ccodcli +"' "
			_cQuery += " AND  SF2.F2_EMISSAO < '"+ DtoS( dDataRef ) +"' "+ENTER
			_cQuery += " GROUP BY SF2.F2_EMISSAO"
			_cQuery += " ORDER BY SF2.F2_EMISSAO DESC"
			
			If Select(_cAlias) > 0
				(_cAlias)->( DBCloseArea() )
			EndIf
			
			DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
			
			DBSelectArea(_cAlias)
			(_cAlias)->( DBGoTop() )

			dDataUC := stod('')
			nValUC := 0
			dDataPUC := stod('')
			nValPUC := 0

			 If !((_cAlias)->(Eof()))
			 
				//Grava ultima compra
				dDataUC := Stod((_cAlias)->EMISSAO)
				nValUC := (_cAlias)->VALOR				
			
			Endif
			
			(_cAlias)->(Dbskip())
			
			If !((_cAlias)->(Eof()))
			 
				//Grava penultima compra
				dDataPUC := Stod((_cAlias)->EMISSAO)
				nValPUC := (_cAlias)->VALOR				
			
			Endif		
	
	EndIf	
	
	nVLimCre :=  U_MOMS027K(_ccodcli,_clojacli)
		
	//===========================================================================
	//| Registra os dados na Base da CISP                                       |
	//===========================================================================
	DBSelectArea("SZY")
	SZY->( DBSetOrder(1) )
	IF SZY->( DbSeek( xFilial("SZY") + cCNPJ ) )
	
		SZY->( RecLock("SZY",.F.) )
		    
		    SZY->ZY_PCVLCR	:= nVLimCre									// Limite de Crédito do Cliente
		    SZY->ZY_PCVDAV	:= nValAVX									// Valor Total a vencer
		    SZY->ZY_PCVSAT	:= nValTX							 		// Valor Total do Débito Atual
		    
			//===========================================================================
			//| Grava as Médias de Atraso do Cliente                                    |
			//===========================================================================
			SZY->ZY_PCQPAG	:= Round( nValorZ / nValorX , 2 )			// Média Ponderada de Atraso
			SZY->ZY_PCQDAP	:= Round( nValorY / nValorA , 2 )			// Média Aritmética de Atraso
			
			//===========================================================================
			//| Tratativa para o arredondamento das médias                              |
			//===========================================================================
			IF SZY->ZY_PCQDAP == 0 .And. SZY->ZY_PCQPAG > 0
				SZY->ZY_PCQDAP := 0.01
			EndIF
			
			IF SZY->ZY_PCQPAG == 0 .And. SZY->ZY_PCQDAP > 0
				SZY->ZY_PCQPAG := 0.01
			EndIF
			
			//===========================================================================
			//| Grava as Médias à Vencer do Cliente                                     |
			//===========================================================================
			SZY->ZY_PCMDAV	:= Round( nValAVZ / nValAVX , 2 )			// Média Ponderada a Vencer
			SZY->ZY_PCMPMV	:= Round( nValAVY / nValAVA , 2 )			// Prazo Médio de Vendas
			
			//===========================================================================
			//| Registra a atualização dos dados de Valores Vencidos                    |
			//===========================================================================
			SZY->ZY_PCDATV	:= ROUND( nVal05 , 2 )					// Valor do Débito Vencido há mais de 5 dias
			SZY->ZY_PCMPTV	:= ROUND( nValAc05 / nVal05 , 0 )		// Média Ponderada dos vencidos há mais de 5 dias
			SZY->ZY_PCV15D	:= ROUND( nVal15 , 2 )					// Valor do Débito vencido há mais de 15 dias
			SZY->ZY_PCM15D	:= ROUND( nValAc15 / nVal15 , 0 )		// Média Ponderada dos vencidos há mais de 15 dias
			SZY->ZY_PCV30D	:= ROUND( nVal30 , 2 )					// Valor do Débito vencido há mais de 30 dias
			SZY->ZY_PCM30D	:= ROUND( nValAc30 / nVal30 , 0 )		// Média Ponderada dos vencidos há mais de 30 dias
			
			//===========================================================================
			//| Verifica a atualização dos dados de maior acúmulo                       |
			//===========================================================================
			IF dDataAC  >= _dDataDE2				// Verifica a atualização para os Clientes que possuem o maior acúmulo nos últimos 12 meses
			 
				If dDataAc > 	SZY->ZY_PCDMAC .and. nSaldoAC > SZY->ZY_PCVMAC // Se a data e o valor acumulado for maior que o último enviado
				
					SZY->ZY_PCVMAC	:= nSaldoAC		  		// Grava o novo Valor do Maior Acúmulo
					SZY->ZY_PCDMAC	:= dDataAC		  		// Grava a nova Data do Maior Acúmulo
					
				Endif
						
			EndIF
				
			//===========================================================================
			//| Registra a atualização da Penúltima e Última compra                     |
			//===========================================================================
			IF nValUC > 0 
			
				If  dDataUC > SZY->ZY_PCDUCM
						//Garante que só manda alteração se as datas de ultima compra e penultima compra são 
						//maiores que as já mandadas
				
					SZY->ZY_PCDTPC	:= dDataPUC
					SZY->ZY_PCVPCO	:= nValPUC
					SZY->ZY_PCDUCM	:= dDataUC
					SZY->ZY_PCVULC	:= nValUC
					
				Endif
							
			EndIF
			
			//=============================================================================
			// Se a data de maior acumuluo é de um ano anterior e a ultima compra menos que 
			// um ano anterior ajusta maior acumulo para a ultima compra 	
			//=============================================================================
			IF SZY->ZY_PCDUCM >= _dDataDE2	 .and. SZY->ZY_PCDMAC <= _dDataDE2
					
				  SZY->ZY_PCDMAC := SZY->ZY_PCDUCM
				  SZY->ZY_PCVMAC := SZY->ZY_PCVSAT
			
			EndIF		
		
	
			
			//===========================================================================
			//| Verifica acumulos e ultima compra                     |
			//===========================================================================
			IF SZY->ZY_PCVPCO == 0 .and. SZY->ZY_PCDUCM != SZY->ZY_PCDMAC 
			
				SZY->ZY_PCDMAC := SZY->ZY_PCDUCM
				SZY->ZY_PCDTPC := stod(" ")
							
			EndIF
			
			//===========================================================================
			//| Verifica acumulos e ultima compra                     |
			//===========================================================================
			IF SZY->ZY_PCDUCM < SZY->ZY_PCDMAC 
			
				SZY->ZY_PCDMAC := SZY->ZY_PCDUCM
							
			EndIF
			
	
						
			//===========================================================================
			// Se o saldo atual ou ultima compra for maior que o Maior Acúmulo faz ajuste
			//===========================================================================
			IF SZY->ZY_PCVMAC <= SZY->ZY_PCVSAT .OR. SZY->ZY_PCVMAC <= SZY->ZY_PCVULC
			
				If SZY->ZY_PCVULC >= SZY->ZY_PCVSAT
				
				  SZY->ZY_PCVMAC := SZY->ZY_PCVULC
				
				Else
				
				  SZY->ZY_PCVMAC := SZY->ZY_PCVSAT
				  
				Endif
			
			EndIF	
			
		SZY->ZY_PCDDAT	:= dDataRef
		
		SZY->( MsUnlock() )
		
	EndIF
    
EndDo

(cAlias)->( DBCloseArea() )

//===========================================================================
//| Tratativa das mensagens para processamento via JOB ou Rotina            |
//===========================================================================
IF !(lThread)
	
	//===========================================================================
	//| Inicializa barras de processamento                                      |
	//===========================================================================
	BarGauge1Set(0)
	IncProcG1( "Verificando os registros [ Processo 03 de 03 ]" )
	ProcessMessage()
	
	BarGauge2Set(0)
	IncProcG2( "Atualizando registros..." )
	ProcessMessage()
	
EndIF

u_itconout("Verificando os registros [ Processo 03 de 03 ] - Atualizando registros...")

DBSelectArea("SZY")
SZY->( DbGotop() )

//===========================================================================
//| Verificação final dos dados gravados e atualização da Data da Informação|
//===========================================================================
While SZY->(!Eof())

	IF SZY->ZY_PCCCLI >= MV_PAR01 .And. SZY->ZY_PCCCLI <= MV_PAR02
	
		SZY->( RecLock( "SZY" , .F. ) )
			
			IF !EMPTY(SZY->ZY_PCDCDD)
				IF !EMPTY(SZY->ZY_PCDUCM) .And. SZY->ZY_PCDUCM >= _dDataDE2
					IF !EMPTY(SZY->ZY_PCVULC)
						IF !EMPTY(SZY->ZY_PCDMAC)
							IF !EMPTY(SZY->ZY_PCVMAC)
								IF SZY->ZY_PCVPCO == 0 .AND. !EMPTY(SZY->ZY_PCDTPC)
									SZY->ZY_PCDTPC := StoD("")
								EndIF
							EndIF
						EndIF
					EndIF
				EndIF
			EndIF
			
			SZY->ZY_PCDDAT	:= dDataRef
		
		SZY->( MsUnlock() )
	
	EndIf
	
SZY->( DbSkip() )
EndDo

//===========================================================================
//| Tratativa das mensagens para processamento via JOB ou Rotina            |
//===========================================================================
IF !(lThread)
	
	//===========================================================================
	//| Inicializa barras de processamento                                      |
	//===========================================================================
	BarGauge1Set(0)
	IncProcG1( "Verificando os registros [ Processo 03 de 03 ]" )
	ProcessMessage()
	
	BarGauge2Set(0)
	IncProcG2( "Verificando registros..." )
	ProcessMessage()
	
EndIF

u_itconout("Verificando os registros [ Processo 03 de 03 ] - Verificando registros...")

IF MV_PAR06 == 1
	
	If lThread
	
		aValid := U_MOMS027L( 2 , lThread )
		
		If Empty(aValid)
		
			U_MOMS027T( lThread , .T. )
		
		Else
			
			U_MOMS027R( aValid )
			
		EndIf
		
	EndIf

	u_itconout("Verificando os registros [ Processo 03 de 03 ] - Gerando arquivo...")
	Processa( {|| U_MOMS027T( .F. , .T. ) } , "Geração do Arquivo" , "Iniciando, aguarde..." )
	u_itconout("Processo finalizado.")
	
EndIF

Return()

/*
===============================================================================================================================
Programa----------: MOMS027T
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de controle para geração do arquivo TXT da CISP
===============================================================================================================================
Parametros--------: lThread		- se verdadeiro define que a rotina está sendo executada via JOB
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027T( lThread , lEnvMail )

Local oDlg			:= Nil
Local cDir			:= Space(150)
Local nOpc			:= 0

Default lThread		:= .F.
Default lEnvMail	:= .F.

//===========================================================================
//| Verifica o acesso do usuário à utilização dos dados da base da CISP     |
//===========================================================================
If !lThread .And. !U_ITVLDUSR(4)

	u_itmsg("Usuário sem acesso à alteração dos dados da base da CISP.","Atenção","Verifique com a área de TI/ERP.",,1)
	
	Return()
	
EndIf

//===========================================================================
//| Solicita a indicação do diretório de destino                            |
//===========================================================================
If lThread

	nOpc	:= 1
	cDir	:= AllTrim( GetMV( "IT_CISPDIR" ,, "\data\CISP\" ) )
	
Else
	
	If !lEnvMail
	
		_nOp:=Aviso( "Atenção!","A rotina atual permite gerar o arquivo em um local específico ou processar o envio automático por e-mail." +ENTER+ENTER+;
								"Selecione a saída desejada:"	,;
								{"Arquivo","E-mail","Cancela"} )
								//1          2        3
		IF _nOp = 1
	
			DEFINE MSDIALOG oDlg TITLE "Geração de Arquivo [TXT]" FROM 0,0 TO 060,552 OF oDlg PIXEL
			
				@005,005 SAY "Diretório de Destino:"	SIZE 065,010 PIXEL OF oDlg COLOR CLR_HBLUE
				@014,005 MSGET cDir PICTURE "@!"		SIZE 195,010 PIXEL OF oDlg
				@014,200 BUTTON "..."					SIZE 013,012 PIXEL OF oDlg ACTION cDir := cGetFile( "\" , "Selecione o Diretorio de Destino:" ,,,, GETF_RETDIRECTORY+GETF_LOCALHARD )
				
				@004,245 BUTTON "&Ok"					SIZE 030,011 PIXEL OF oDlg ACTION ( nOpc := 1 , oDlg:End() )
				@016,245 BUTTON "&Cancelar"				SIZE 030,011 PIXEL OF oDlg ACTION ( nOpc := 0 , oDlg:End() )
			
			ACTIVATE MSDIALOG oDlg CENTER
		
		ElseIF _nOp = 2
		
			nOpc		:= 1
			cDir		:= AllTrim( GetMV( "IT_CISPDIR" ,, "\data\CISP\" ) )
			lEnvMail	:= .T.
			
		EndIf
	
	EndIf

EndIf

//===========================================================================
//| Verifica a opção e a pasta de destino                                   |
//===========================================================================
If nOpc == 1
	
	cDir := AllTrim(cDir)
	
	If lThread
		
		MOMS027TXT( cDir , lThread , lEnvMail )
	
	Else
	
		Processa( {|| MOMS027TXT( cDir , lThread , lEnvMail )} , "Gravando Arquivo TXT..." , "Aguarde!" , .F. )
	
	EndIf
	
Else

	u_itmsg(  "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS027TXT
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de processamento da geração do arquivo TXT da CISP
===============================================================================================================================
Parametros--------: lThread		- se verdadeiro define que a rotina está sendo executada via JOB
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027TXT( cDirAux , lThread , lEnvMail )

Local aValid		:= {}
Local cCodCisp		:= AllTrim( GetMV( "IT_CISPCOD" ,, "0095" ) )
Local _cNArq1		:= ""
Local _cNArq2		:= "PFJ_"+ cCodCisp +".TXT"
Local cQuery		:= ""
Local cLinha		:= ""
Local cAlias		:= GetNextAlias()
Local cEmailTo		:= ""
Local cEmailCo		:= ""
Local cEmailBcc		:= ""
Local cAssunto		:= ""
Local cMensagem		:= ""
Local cAttach		:= ""
Local aConfig		:= {}
Local cLog			:= ""

Local dRefAtu		:= StoD("")

Local nI			:= 0
Local nTotReg		:= 0
Local nRegOk		:= 0
Local nHandle		:= 0

Local lProcOk		:= .T.
Local lErroVal		:= .F.

Default cDirAux		:= ""
Default lThread		:= .F.
Default lEnvMail	:= .F.

If !Empty( cDirAux )
	_cNArq1	:= cDirAux + _cNArq2
Else
	_cNArq1	:= AllTrim( GetMV( "IT_CISPDIR" ,, "\data\CISP\" ) ) + _cNArq2
EndIf

If !(lThread)
   IF U_ITMSG("Deseja atulizar a data de processamento para a data de Hoje ?",'Atenção!',,2,2,2)

	  ProcRegua(3)
	  IncProc("Atualizando a Data...,Aguarde!")

	  cQuery := "UPDATE " + RETSQLNAME('SZY') + " SET ZY_PCDDAT = '"+DTOS(DATE())+"' WHERE D_E_L_E_T_ <> '*' "

	  IncProc("Atualizando a Data...,Aguarde!")
		
	   If TCSqlExec(cQuery) < 0
		   Conout(TcSqlError())
           bBloco:={||  AVISO("TcSqlError()",TcSqlError(),{"Fechar"},3) }
		   U_ITMSG("Erro na atualização da Data: Ver Detalhes ",'Atenção!',"O Arquivo será gerado mesmo assim.",3,,,,,,bBloco)
	   ELSE
			TCSQLEXEC( "COMMIT" )
	   ENDIF

	  IncProc("Atualizando a Data...,Aguarde!")

   ENDIF
ENDIF

//===========================================================================
//| Apaga o arquivo se o mesmo ja existir para criacao do novo.             |
//===========================================================================
If File( _cNArq1 )
	
	lProcOk := .F.
	
	For nI := 0 To 5 // Tentativas de exclusao do arquivo
	
		If FERASE(_cNArq1) <> -1
			lProcOk := .T.
			Exit
		EndIf
		
	SLEEP( 5000 )
	Next nI
	
	If !lProcOk
	
		If !(lThread)
			u_itmsg( "Não foi possível excluir o arquivo existente: "+ ENTER + ENTER + _cNArq1 , "Atenção!" , ,1 )
		EndIf
		
		Return()
		
	EndIf
	
EndIf

//===========================================================================
//| Cria arquivo novo.                                                      |
//===========================================================================
If lProcOk

	nHandle := FCREATE( _cNArq1 )
	
	If nHandle == -1
	
		If !(lThread)
			u_itmsg( "Não foi possível criar o arquivo: "+ ENTER + ENTER + _cNArq1 , "Atenção!" ,"Verifique o destino e tente novamente..." ,  ,1 )
		EndIf
		
		Return()
		
	EndIf
	
EndIf

DBSelectArea("SZY")
SZY->( DBGoTop() )
If SZY->( !Eof() )
	dRefAtu := YEARSUB( SZY->ZY_PCDDAT , 1 )
Else
	dRefAtu := YEARSUB( dDataRef , 1 )
EndIF

//===========================================================================
//| Seleciona os dados CISP para o arquivo.                                 |
//===========================================================================
cQuery := " SELECT "
cQuery += "     SZY.ZY_PCTIPO, "
cQuery += "     SZY.ZY_PCCASS, "
cQuery += "     SZY.ZY_PCCCLI, "
cQuery += "	  	SZY.ZY_PCDDAT, "
cQuery += "     SZY.ZY_PCDCDD, "
cQuery += "     SZY.ZY_PCDUCM, "
cQuery += "     SZY.ZY_PCVULC, "
cQuery += "     SZY.ZY_PCDMAC, "
cQuery += "     SZY.ZY_PCVMAC, "
cQuery += "     SZY.ZY_PCVSAT, "
cQuery += "     SZY.ZY_PCVLCR, "
cQuery += "     SZY.ZY_PCQPAG, "
cQuery += "     SZY.ZY_PCQDAP, "
cQuery += "     SZY.ZY_PCVDAV, "
cQuery += "     SZY.ZY_PCMDAV, "
cQuery += "     SZY.ZY_PCMPMV, "
cQuery += "     SZY.ZY_PCDATV, "
cQuery += "     SZY.ZY_PCMPTV, "
cQuery += "     SZY.ZY_PCV15D, "
cQuery += "     SZY.ZY_PCM15D, "
cQuery += "     SZY.ZY_PCV30D, "
cQuery += "     SZY.ZY_PCM30D, "
cQuery += "     SZY.ZY_PCDTPC, "
cQuery += "     SZY.ZY_PCVPCO "
cQuery += " FROM "+ RetSqlName("SZY") +" SZY "
cQuery += " WHERE "
cQuery += " 		SZY.D_E_L_E_T_	= ' ' "						// Não permite os deletados
cQuery += " AND		SZY.ZY_PCVMAC	> 0.01 "					// Deve possuir registro de Maior Acúmulo
cQuery += " AND	(	SZY.ZY_PCDUCM	> '"+ DtoS( dRefAtu ) +"' "	// A Data da última compra deve estar no período
cQuery += " 	OR	SZY.ZY_PCVSAT	> 0.01  "					// ou possuir saldo em aberto
cQuery += "     OR  SZY.ZY_FLAGEN = '1' ) "                       //Flag para forçar envio em caso de arquivo comp.pdf

//===========================================================================
//| Prepara e inicializa os dados para gravação do arquivo.                 |
//===========================================================================
If Select(cAlias) > 0
	(cAlias)->(DBCLOSEAREA())
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAlias , .T. , .F. )

nTotReg	:= 0
nI		:= 0

DBSELECTAREA(cAlias)
(cAlias)->( DBGOTOP() )
(cAlias)->( DBEVAL( {|| nTotReg++} ) )
(cAlias)->( DBGOTOP() )

If !(lThread)
	ProcRegua(nTotReg)
EndIf

//===========================================================================
//| Processa a gravação do arquivo.                                         |
//===========================================================================
While (cAlias)->(!EOF())

	nI++
	
	If !lThread
		IncProc("["+ StrZero(nI,9) +"] de ["+ StrZero(nTotReg,9) +"]")
	EndIF
	
	lErroVal := .F.
	
	//===========================================================================
	//| Validação da dada de cadastro do Cliente                                |
	//===========================================================================
	IF EMPTY( (cAlias)->ZY_PCDCDD )
		aAdd( aValid , { AllTrim( (cAlias)->ZY_PCCCLI ) , "Data de cadastro do Cliente é obrigatória." } )
		lErroVal := .T.
	EndIf
	
	//===========================================================================
	//| Validação da dada de última compra                                      |
	//===========================================================================
	IF EMPTY( (cAlias)->ZY_PCDUCM )
		aAdd( aValid , { AllTrim( (cAlias)->ZY_PCCCLI ) , "Não existe registro de última compra no histórico desde a implantação." } )
		lErroVal := .T.
	EndIf
	
	//===========================================================================
	//| Validação do valor da última compra                                     |
	//===========================================================================
	IF	EMPTY( (cAlias)->ZY_PCVULC ) .Or. (cAlias)->ZY_PCVULC == 0
		aAdd( aValid , { AllTrim( (cAlias)->ZY_PCCCLI ) , "Não existe valor de última compra no histórico desde a implantação." } )
		lErroVal := .T.
	EndIf
	
	//===========================================================================
	//| Validação da dada de maior acúmulo de saldo em aberto do Cliente        |
	//===========================================================================
	IF	EMPTY( (cAlias)->ZY_PCDMAC )
		aAdd( aValid , { AllTrim( (cAlias)->ZY_PCCCLI ) , "Não foram encontrados registros de data do maior acúmulo de saldo em aberto." } )
		lErroVal := .T.
	EndIf
	
	//===========================================================================
	//| Validação do valor de maior acúmulo de saldo em aberto do Cliente       |
	//===========================================================================
	IF	EMPTY( (cAlias)->ZY_PCVMAC )
		aAdd( aValid , { AllTrim( (cAlias)->ZY_PCCCLI ) , "Não foram encontrados registros de valor do maior acúmulo de saldo em aberto." } )
		lErroVal := .T.
	EndIf
	
	//===========================================================================
	//| Se não passou pela validação não inclui o registro no arquivo           |
	//===========================================================================
	IF lErroVal
		(cAlias)->( DBSKIP() )
		Loop
	EndIF
	
	nRegOk++
	
	//===========================================================================
	//| Monta a linha para gravação do arquivo                                  |
	//===========================================================================
	cLinha := ""
	
	//===========================================================================
	//| Tratativa para não gerar linha em branco no fim do arquivo              |
	//===========================================================================
	If nRegOk > 1
		cLinha += ENTER
	EndIf
	
	clinha += (cAlias)->ZY_PCTIPO												// | 01 | Identif. (1-CNPJ / 2-CPF / 3-RG / 4-Export. / 5-Insc.Prod./ 9-Outros)
	cLinha += STRZERO( VAL( (cAlias)->ZY_PCCASS ) , 04 )						// | 02 | Código do Associado
	cLinha += STRZERO( VAL( (cAlias)->ZY_PCCCLI ) , 20 )						// | 03 | Identificação. (CNPJ / CPF / RG / Export. / Insc.Prod. / Outros)
//	cLinha += PadR( AllTrim( (cAlias)->ZY_PCDDAT )	, 08 , "0" )				// | 04 | Data da Informação
	cLinha += PadR( AllTrim( DTOS(DATE()) )			, 08 , "0" )				// | 04 | Data da Informação
	cLinha += PadR( AllTrim( (cAlias)->ZY_PCDCDD )	, 08 , "0" )				// | 05 | Data do Cadastro do Cliente
	cLinha += PadR( AllTrim( (cAlias)->ZY_PCDUCM )	, 08 , "0" )				// | 06 | Data da Última Compra
	cLinha += STRZERO( (cAlias)->ZY_PCVULC * 100 , 15 )							// | 07 | Valor da Última Compra
	cLinha += PadR( AllTrim( (cAlias)->ZY_PCDMAC )	, 08 , "0" )				// | 08 | Data do Maior Acúmulo
	cLinha += STRZERO( (cAlias)->ZY_PCVMAC * 100 , 15 )							// | 09 | Valor do Maior Acúmulo
	cLinha += STRZERO( (cAlias)->ZY_PCVSAT * 100 , 15 )							// | 10 | Valor do Débito Atual Total
	cLinha += STRZERO( (cAlias)->ZY_PCVLCR * 100 , 15 )							// | 11 | Valor do Limite de Crédito
	cLinha += STRZERO( INT( (cAlias)->ZY_PCQPAG * 100 ) , 06 )					// | 12 | Média Ponderada de Atraso nos Pagamentos (Títulos Baixados)
	cLinha += STRZERO( INT( (cAlias)->ZY_PCQDAP * 100 ) , 06 )					// | 13 | Média Aritmética dos Dias de Atraso nos Pagamentos (Títulos Baixados)
	cLinha += STRZERO( (cAlias)->ZY_PCVDAV * 100 , 15 )							// | 14 | Valor Débito Atual a Vencer
	cLinha += STRZERO( INT( (cAlias)->ZY_PCMDAV * 100 ) , 06 )					// | 15 | Média Ponderada de Títulos a Vencer
	cLinha += STRZERO( INT( (cAlias)->ZY_PCMPMV * 100 ) , 06 )					// | 16 | Prazo Médio de Vendas
	cLinha += STRZERO( (cAlias)->ZY_PCDATV * 100 , 15 )							// | 17 | Valor do Débito Atual Vencido (+5 Dias)
	cLinha += STRZERO( INT( (cAlias)->ZY_PCMPTV ) , 04 )						// | 18 | Média Ponderada de Atraso Títulos Vencidos e não Pagos (+5 Dias)
	cLinha += STRZERO( (cAlias)->ZY_PCV15D * 100 , 15 )							// | 19 | Valor do Débito Atual Vencido (+15 Dias)
	cLinha += STRZERO( INT( (cAlias)->ZY_PCM15D ) , 04 )						// | 20 | Média Ponderada de Atraso Títulos Vencidos e não Pagos (+15 Dias)
	cLinha += STRZERO( (cAlias)->ZY_PCV30D * 100 , 15 )							// | 21 | Valor do Débito Atual Vencido (+30 Dias)
	cLinha += STRZERO( INT( (cAlias)->ZY_PCM30D ) , 04 )						// | 22 | Média Ponderada de Atraso Títulos Vencidos e não Pagos (+30 Dias)
	cLinha += PadR( AllTrim( (cAlias)->ZY_PCDTPC ) , 08 , "0" )					// | 23 | Data da Penúltima Compra
	cLinha += STRZERO( (cAlias)->ZY_PCVPCO * 100 , 15 )							// | 24 | Valor da Penúltima Compra
	cLinha += "2"																// | 25 | Situação do Cálculo Limite de Crédito: 2 - 2	Limite Operacional de Crédito 
	cLinha += "0"																// | 26 | Tipo de Garantia
	cLinha += "00"																// | 27 | Grau da Garantia - Hipoteca
	cLinha += "00000000"														// | 28 | Data da Validade da Garantia
	cLinha += "000000000000000"													// | 29 | Valor da Garantia
	cLinha += "000000000000000"													// | 30 | Valor da Venda de Pagamento Antecipado
	cLinha += "  "																// | 31 | Venda sem Crédito (Antecipado)
	
	FWRITE( nHandle , cLinha )

(cAlias)->( DBSKIP() )
EndDo

(cAlias)->(DBCLOSEAREA())
FCLOSE( nHandle )

//===========================================================================
//| Caso sejam identificadas inconsistências exibe janela de informações.   |
//===========================================================================
IF !Empty( aValid )
    
	If !(lThread)
		U_ITListBox( "Registros não enviados:" , {"CNPJ","Motivo"} , aValid )
	EndIf
	
EndIF

//===========================================================================
//| Verifica se foram gravados resgitros no arquivo.                        |
//===========================================================================
If nRegOk > 0
	
	If !(lThread)
		u_itmsg(  "Arquivo:"+ ENTER + ENTER + _cNArq1 + ENTER + ENTER +"gerado com Sucesso!" ,"Concluído!",,2 )
	EndIF
	
	If lEnvMail
		
		cEmailTo	:= Lower( AllTrim( SuperGetMV( "IT_CISPDES" ,.F., "sistema@italac.com.br"		) ) )
		cEmailCo	:= Lower( AllTrim( SuperGetMV( "IT_CISPCOP" ,.F., ""								) ) )
		cEmailBcc:= Lower( AllTrim( GetMV( "IT_CISPCOO" ,, ""								) ) )
		cAssunto	:= AllTrim( GetMV( 'IT_CISPTIT' ,, 'POSITIVAS - PRODUCAO - '+ AllTrim( GetMV( "IT_CISPCOD" ,, "0095" ) ) ) )
		cMensagem	:= MOMS027MSG( 1 )
		cAttach		:= _cNArq1
		aConfig		:= U_ITCFGEML( AllTrim( GetMV( "IT_CISPCFG" ,, "002" ) ) ) //Configuração de e-mail a ser considerada para o envio (Tabela Z02)
		cLog		:= ""
		
		If lThread
			U_ITENVMAIL( aConfig[01] , cEmailTo , cEmailCo , cEmailBcc , cAssunto , cMensagem , cAttach , aConfig[01] , aConfig[02] , aConfig[03] , aConfig[04] , aConfig[05] , aConfig[06] , aConfig[07] , @cLog )
		Else
			LjMsgRun( "Processando o envio por e-mail..." , "Aguarde!" , {|| U_ITENVMAIL( aConfig[01] , cEmailTo , cEmailCo , cEmailBcc , cAssunto , cMensagem , cAttach , aConfig[01] , aConfig[02] , aConfig[03] , aConfig[04] , aConfig[05] , aConfig[06] , aConfig[07] , @cLog ) } )
		EndIf
		
		If Empty( cLog )
			
			If !(lThread)
				u_itmsg( "E-mail enviado com sucesso!" , "Atenção!",,2 )
			Else
			
				//Grava data de envio de email para não enviar mais de um email por dia via schedule
				putmv("ITDTCISP",DATE())
			
			EndIf
			
			
			
		Else
		
			If !(lThread)
				u_itmsg(  cLog , "Atenção!",,3 )
			EndIf
			
		EndIf
		
		FRename( _cNArq1 , SubStr( _cNArq1 , 1 , Len(_cNArq1) - 4 ) +"_"+ DtoS( Date() ) +"_"+ StrTran( Time() , ":" , "" ) +".txt" )
		
	EndIf
	
ElseIf File(_cNArq1)

	//===========================================================================
	//| Tenta apagar o arquivo se o mesmo foi gerado em branco.                 |
	//===========================================================================
	For nI := 1 To 5
	
		If FERASE(_cNArq1) <> -1
			Exit
		EndIf
		
	SLEEP( 5000 )
	Next nI
	
	If !(lThread)
		u_itmsg(  "Falha na geração do arquivo!"+ CRLF +"O arquivo não pode ser gerado em branco." , "Atenção!",,1 )
	EndIf
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS027L
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de controle da validação dos dados gerados
===============================================================================================================================
Parametros--------: lThread		- se verdadeiro define que a rotina está sendo executada via JOB
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027L( nOpc , lThread )

Local aRet		:= {}

Default nOpc	:= 1
Default lThread	:= .F.

//===========================================================================
//| Verifica o acesso do usuário à alteração dos dados da base da CISP      |
//===========================================================================
If !lThread .And. !U_ITVLDUSR(4)

	u_itmsg("Usuário sem acesso à alteração dos dados da base da CISP.","Atenção","Verifique com a área de TI/ERP.",,1)

	Return()
	
EndIf

If lThread
	
	aRet := MOMS027INF( lThread )
	
Else

	Processa( {|lEnd| MOMS027INF() } , "Analisando Inconsistências na Base - Aguarde..." , "Processando..." )

EndIf

Return( aRet )

/*
===============================================================================================================================
Programa----------: MOMS027INF
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de validação das informações da Base CISP
===============================================================================================================================
Parametros--------: lThread		- se verdadeiro define que a rotina está sendo executada via JOB
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027INF( lThread )

Local _dDataDE2	:= StoD("")
Local aDadosAux	:= {}
Local lValid	:= .F.
Local nI		:= 0
Local nTotReg	:= 0

Default lThread	:= .F.

//===========================================================================
//| Posiciona no alias da base CISP                                         |
//===========================================================================
DBSelectArea("SZY")

SZY->( DBGotop() )
SZY->( DBEval( {|| nTotReg++ } ) )
SZY->( DBGotop() )

ProcRegua(nTotReg)

If nTotReg > 0
	_dDataDE2 := YearSub( SZY->ZY_PCDDAT , 1 )
EndIf

//===========================================================================
//| Processa a validação dos conteúdos                                      |
//===========================================================================
While SZY->(!Eof())
	
	nI++
	IncProc( "["+ StrZero( nI , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
	
	//===========================================================================
	//| Verifica o preenchimento da data de cadastro                            |
	//===========================================================================
	IF EMPTY(SZY->ZY_PCDCDD)
		lValid := .T.
		aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data de cadastro do Cliente está em branco." } )
	ElseIF SZY->ZY_PCDCDD > SZY->ZY_PCDDAT
		lValid := .T.
		aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data de cadastro do Cliente é maior que a data de atualização da base." } )
	EndIF
	
	//===========================================================================
	//| Só valida clientes que possuem registro de data de última compra.       |
	//===========================================================================
	If !EMPTY(SZY->ZY_PCDUCM)
		
		//===========================================================================
		//| Só valida clientes que possuem registro de valor da última compra.      |
		//===========================================================================
		If !EMPTY(SZY->ZY_PCVULC)

			//===========================================================================
			//| Validações da Data de Última Compra                                     |
			//===========================================================================
			IF SZY->ZY_PCDUCM > SZY->ZY_PCDDAT
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data da última compra é maior que a data de atualização da base." } )
			EndIF
			
			IF SZY->ZY_PCDUCM < SZY->ZY_PCDCDD
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data da última compra é menor do que a data de cadastro do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCDUCM <= SZY->ZY_PCDTPC
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data da última compra é menor ou igual do que a data da penúltima compra." } )
			EndIF
			
			//===========================================================================
			//| Validações da Data de Maior Acúmulo do Cliente                          |
			//===========================================================================
			IF SZY->ZY_PCDMAC > SZY->ZY_PCDDAT
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data de maior acúmulo é maior do que a data de atualização da base." } )
			EndIF
			
			IF SZY->ZY_PCDMAC < SZY->ZY_PCDCDD
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data de maior acúmulo é menor do que a data de cadastro do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCDMAC > SZY->ZY_PCDUCM
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Data de maior acúmulo é maior do que a data da última compra." } )
			EndIF
			
				
			//===========================================================================
			//| Validações do Valor de Maior Acúmulo do Cliente                         |
			//===========================================================================
			IF SZY->ZY_PCVMAC < SZY->ZY_PCVSAT
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O valor do maior acúmulo é menor do que o valor do saldo atual do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCVMAC < SZY->ZY_PCVULC
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O valor do maior acúmulo é menor do que o valor da última compra do Cliente." } )
			EndIF
			
			//===========================================================================
			//| Validações do Valor do Saldo Atual do Cliente                           |
			//===========================================================================
			IF SZY->ZY_PCVSAT < SZY->ZY_PCVDAV
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo atual é menor do que o saldo atual à vencer do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCVSAT < SZY->ZY_PCDATV
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo atual é menor do que o saldo vencido (+5) do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCVSAT < SZY->ZY_PCV15D
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo atual é menor do que o saldo vencido (+15) do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCVSAT < SZY->ZY_PCV30D
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo atual é menor do que o saldo vencido (+30) do Cliente." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média Ponderada de Atrasos do Cliente                      |
			//===========================================================================
			IF SZY->ZY_PCQPAG == 0 .And. SZY->ZY_PCQDAP <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de atrasos é igual a zero e a média aritmética não é igual a zero." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média Aritmética de Atrasos do Cliente                     |
			//===========================================================================
			IF SZY->ZY_PCQDAP == 0 .And. SZY->ZY_PCQPAG <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média aritmética de atrasos é igual a zero e a média ponderada não é igual a zero." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo Atual à vencer do Cliente                            |
			//===========================================================================
			IF SZY->ZY_PCVDAV > SZY->ZY_PCVSAT
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo atual à vencer é maior que o saldo total atual do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCVDAV == 0 .And. SZY->ZY_PCMDAV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo atual à vencer é igual a zero e foi calculada a média ponderada de títulos à vencer." } )
			EndIF
			
			IF SZY->ZY_PCVDAV == 0 .And. SZY->ZY_PCMPMV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo atual à vencer é igual a zero e foi calculada a média de prazo à vencer." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média Ponderada à vencer do Cliente                        |
			//===========================================================================
			IF SZY->ZY_PCMDAV == 0 .And. SZY->ZY_PCVDAV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de títulos à vencer é igual a zero e o saldo à vencer é maior que zero." } )
			EndIF
			
			IF SZY->ZY_PCMDAV == 0 .And. SZY->ZY_PCMPMV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de títulos à vencer é igual a zero e a média de prazo à vencer é maior que zero." } )
			EndIF
			
			//===========================================================================
			//| Validação do Prazo Médio à vencer do Cliente                            |
			//===========================================================================
			IF SZY->ZY_PCMPMV == 0 .And. SZY->ZY_PCVDAV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O prazo médio à vencer é igual a zero e o saldo à vencer é maior que zero." } )
			EndIF
			
			IF SZY->ZY_PCMPMV == 0 .And. SZY->ZY_PCMDAV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O prazo médio à vencer é igual a zero e a média ponderada à vencer é maior que zero." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo à vencido (+5) do Cliente                            |
			//===========================================================================
			IF SZY->ZY_PCDATV > SZY->ZY_PCVSAT
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo vencido (+5) é maior que o saldo total atual do Cliente." } )
			EndIF
			
			IF SZY->ZY_PCDATV == 0 .And. SZY->ZY_PCMPTV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo vencido (+5) é igual a zero e foi calculada média ponderada de vencidos (+5)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média ponderada vencida (+5) do Cliente                    |
			//===========================================================================
			IF SZY->ZY_PCMPTV <> 0 .And. SZY->ZY_PCMPTV < 5
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de vencidos (+5) é menor do que 5." } )
			EndIF
			
			IF SZY->ZY_PCMPTV == 0 .And. SZY->ZY_PCDATV <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de vencidos (+5) é igual a zero e existe saldo vencido (+5)." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo à vencido (+15) do Cliente                            |
			//===========================================================================
			IF SZY->ZY_PCV15D > SZY->ZY_PCDATV
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo vencido (+15) é maior que o saldo vencido (+5)." } )
			EndIF
			
			IF SZY->ZY_PCV15D == 0 .And. SZY->ZY_PCM15D <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo vencido (+15) é igual a zero e foi calculada média ponderada vencida (+15)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média ponderada vencida (+15) do Cliente                   |
			//===========================================================================
			IF SZY->ZY_PCM15D <> 0 .And. SZY->ZY_PCM15D < 15
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de vencidos (+15) é menor do que 15." } )
			EndIF
			
			IF SZY->ZY_PCM15D == 0 .And. SZY->ZY_PCV15D <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de vencidos (+15) é igual a zero e existe saldo vencido (+15)." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo à vencido (+30) do Cliente                            |
			//===========================================================================
			IF SZY->ZY_PCV30D > SZY->ZY_PCV15D
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo vencido (+30) é maior que o saldo vencido (+15)." } )
			EndIF
			
			IF SZY->ZY_PCV30D == 0 .And. SZY->ZY_PCM30D <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "O saldo vencido (+30) é igual a zero e foi calculada média ponderada vencida (+30)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média ponderada vencida (+30) do Cliente                   |
			//===========================================================================
			IF SZY->ZY_PCM30D <> 0 .And. SZY->ZY_PCM30D < 30
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de vencidos (+30) é menor do que 30." } )
			EndIF
			
			IF SZY->ZY_PCM30D == 0 .And. SZY->ZY_PCV30D <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A média ponderada de vencidos (+30) é igual a zero e existe saldo vencido (+30)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Data da Penúltima Compra do Cliente                        |
			//===========================================================================
			IF SZY->ZY_PCDTPC == SZY->ZY_PCDUCM
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A data da penúltima compra é igual à data de última compra." } )
			EndIF
			
			IF SZY->ZY_PCDTPC > SZY->ZY_PCDUCM
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A data da penúltima compra é maior que a data de última compra." } )
			EndIF
			
			IF Empty( SZY->ZY_PCDTPC ) .And. SZY->ZY_PCVPCO <> 0
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Não foi registrada a data da penúltima compra e o valor da penúltima compra é maior que zero." } )
			EndIF
			
			IF !Empty( SZY->ZY_PCDTPC ) .And. SZY->ZY_PCDTPC < SZY->ZY_PCDCDD
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "A data da penúltima compra é anterior à data de cadastro do Cliente." } )
			EndIF
			
			IF Empty( SZY->ZY_PCDTPC ) .And. !Empty( SZY->ZY_PCDUCM ) .And. !Empty( SZY->ZY_PCDMAC ) .And. SZY->ZY_PCDUCM <> SZY->ZY_PCDMAC
				lValid := .T.
				aAdd( aDadosAux , { SZY->ZY_PCCCLI , "Não foi registrada a data da penúltima compra e a data de maior acúmulo é diferente da data de última compra." } )
			EndIF
			
		EndIf
		
	EndIf
	
SZY->(DbSkip())
EndDo

SZY->(DbGotop())

//===========================================================================
//| Verifica se existem inconsistências e exibe informações caso necessário |
//===========================================================================
If lValid

	If !(lThread)
	
		MsgInfo( "Foram encontradas inconsistências durante a validação! É recomendado executar a atualização da base antes de gerar um novo arquivo para enviar." , "Atenção!" )
		U_ITListBox( "Inconsistências" , { "CNPJ" , "Mensagem" } , aDadosAux )
		
	EndIf
	
Else

	If !(lThread)
		
		MsgInfo( "Todos os registros foram validados com sucesso!" , "Concluído!" )
		
	EndIF
	
EndIF

Return( aDadosAux )

/*
===============================================================================================================================
Programa----------: MOMS027V
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de visualização dos dados de um Cliente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027V()

//Local nOpca			:= 0

Private aButtons	:= {}
Private cCadastro	:= "Integração - Cisp"
Private _aCamposVis	:= {	"NOUSER"	, "ZY_FILIAL"	, "ZY_PCTIPO"	, "ZY_PCCASS"	, "ZY_PCCCLI"	, "ZY_PCDDAT"	, "ZY_PCDCDD"	, "ZY_PCDUCM"	, "ZY_PCVULC"	,;
							"ZY_PCDMAC"	, "ZY_PCVMAC"	, "ZY_PCVSAT"	, "ZY_PCVLCR"	, "ZY_PCQPAG"	, "ZY_PCQDAP"	, "ZY_PCVDAV"	, "ZY_PCMDAV"	, "ZY_PCMPMV"	,;
							"ZY_PCDATV"	, "ZY_PCMPTV"	, "ZY_PCV15D"	, "ZY_PCM15D"	, "ZY_PCV30D"	, "ZY_PCM30D"	, "ZY_PCDTPC"	, "ZY_PCVPCO"	, "ZY_PCVSIT"	,;
							"ZY_PCTIPG"	, "ZY_PCGGA"	, "ZY_PCDTG"	, "ZY_PCVLG"	, "ZY_PCVPA"	, "ZY_PCSVV"	}


//===========================================================================
//| Adiciona botões das funcionalidades extras da rotina                    |
//===========================================================================
aAdd( aButtons , { "RECALC" , {|| MsgRun( "Selecionando Registros..." , "Aguarde" , {|| MOMS027CCR() } ) }	, "Conta Corrente"		, "C.Corrente"	} )
AaDD( aButtons , { "POSCLI" , {|| MsgRun( "Selecionando Registros..." , "Aguarde" , {|| MOMS027CAD() } ) }	, "Cadastro do Cliente"	, "Cadastro"	} )

//===========================================================================
//| Inicializa a visualização padrão da base                                |
//===========================================================================
DBSelectArea("SZY")
AxVisual( "SZY" , SZY->(Recno()) , 2 , _aCamposVis ,,,, aButtons )

Return()

/*
===============================================================================================================================
Programa----------: MOMS027D
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de exclusão dos dados de análise de um Cliente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027D( cAlias , nReg , nOpc )


Private aButtons	:= {}
Private cCadastro	:= "Integração - Cisp"


//===========================================================================
//| Verifica o acesso do usuário à alteração dos dados da base da CISP      |
//===========================================================================
If !U_ITVLDUSR(4)

	u_itmsg("Usuário sem acesso à alteração dos dados da base da CISP.","Atenção","Verifique com a área de TI/ERP.",,1)

	Return()
	
EndIf

//===========================================================================
//| Adiciona botões das funcionalidades extras da rotina                    |
//===========================================================================
aAdd( aButtons , { "RECALC" , {|| MsgRun( "Selecionando Registros..." , "Aguarde" , {|| MOMS027CCR() } ) }	, "Conta Corrente"		, "C.Corrente"	} )
AaDD( aButtons , { "POSCLI" , {|| MsgRun( "Selecionando Registros..." , "Aguarde" , {|| MOMS027CAD() } ) }	, "Cadastro do Cliente"	, "Cadastro"	} )

//===========================================================================
//| Inicializa a exclusão padrão da base                                    |
//===========================================================================
AxDeleta( cAlias , nReg , nOpc ,,, aButtons )

Return()


/*
===============================================================================================================================
Programa----------: MOMS027CAD
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de visualização dos ítens do cadastro de um Cliente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027CAD()

Local _aArea	:= GetArea()
Local aDadosAux	:= {}
Local oDlg		:= Nil
Local oLbx		:= Nil

//===========================================================================
//| Posiciona na tabela de Clientes                                         |
//===========================================================================
DBSelectArea("SA1")
SA1->( DBSetOrder(3) )
If SA1->( DBSeek( xFilial("SA1") + AllTrim(SZY->ZY_PCCCLI) ) )
	
	While SubStr( SA1->A1_CGC , 1 , 8 ) == AllTrim( SZY->ZY_PCCCLI )
	
		aAdd( aDadosAux , { SA1->A1_COD +' - '+ SA1->A1_LOJA , SA1->A1_NOME , SA1->A1_MUN , SA1->A1_EST } )
		SA1->(DbSkip())
	
	EndDo

	//===========================================================================
	//| Monta a ListBox com os dados do Cliente                                 |
	//===========================================================================
	DEFINE MSDIALOG oDlg TITLE "Cadastros do Cliente" FROM 000,000 TO 500,800 COLORS RGB(141,192,222),RGB(188,199,205) PIXEL
		
		@ 002,002 LISTBOX oLbx FIELDS HEADER "Cliente" , "Nome" , "Cidade" , "UF" SIZE 398,233 OF oDlg PIXEL
		
		oLbx:SetArray( aDadosAux )
		oLbx:bLine := {|| { aDadosAux[oLbx:nAt][01] , aDadosAux[oLbx:nAt][02] , aDadosAux[oLbx:nAt][03] , aDadosAux[oLbx:nAt][04] }}
	
	DEFINE SBUTTON FROM 237,374 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTER
   
Else

   u_itmsg( "Cliente não encontrado" , "Atenção" ,,1 )
   RestArea(_aArea)
   Return()
   
EndIf


RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: MOMS027CCR
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de construção da visualização do extrato da "conta corrente" de um Cliente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027CCR()

Private oButton1	:= Nil
Private oButton2	:= Nil
Private oGet1		:= Nil
Private cGet1		:= Space(9)
Private oGet2		:= Nil
Private cGet2		:= Space(3)
Private oGet3		:= Nil
Private cGet3		:= Space(1)
Private oGet4		:= Nil
Private cGet4		:= Space(1)
Private oPanel1		:= Nil
Private oSay1		:= Nil
Private oSay2		:= Nil
Private oSay3		:= Nil
Private oSay4		:= Nil
Private oWBrowse1	:= Nil
Private aWBrowse1	:= {}

Static oDlg			:= Nil

DEFINE MSDIALOG oDlg TITLE "Conta Corrente" FROM 000,000 TO 500,800 COLORS RGB(141,192,222),RGB(188,199,205) PIXEL

	MOMS027BR1()
	MOMS027CD1( ALLTRIM( SZY->ZY_PCCCLI ) )

ACTIVATE MSDIALOG oDlg CENTER ON INIT MOMS027ENB( oDlg )

Return()

/*
===============================================================================================================================
Programa----------: MOMS027ENB
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Monta a barra de menu superior da janela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027ENB( oObj , bObj )

Local oBar		:= Nil

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oObj

DEFINE BUTTON oBtnNp  RESOURCE "MDIEXCEL"	OF oBar ACTION Processa( {|lEnd| MOMS027EXC( oWBrowse1:aArray ) } , 'Processando arquivo...' )	TOOLTIP ""
DEFINE BUTTON oBtOk   RESOURCE "CANCEL"		OF oBar ACTION oDlg:End()												  		TOOLTIP ""

oBar:bRClicked :={|| AllwaysTrue() }

Return()

/*
===============================================================================================================================
Programa----------: MOMS027EXC
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de exportação dos dados da "conta corrente" do Cliente em arquivo formatado do Excel
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027EXC( aDadosAux )

Local nHandle	:= 0
Local cArqPesq	:= GetTempPath() +"\"+ AllTrim(SZY->ZY_PCCCLI) +".XLS"
Local cCabHtml	:= ""
Local cLinFile	:= ""
Local cFileCont	:= ""
Local lFlag		:= .T.
Local nTotReg	:= Len( aDadosAux )
Local nI		:= 0

If nTotReg <= 0
	
	u_itmsg(  "Não é possível gerar um arquivo vazio!" , "Atenção!",,1 )
	Return()
	
EndIf

ProcRegua( nTotReg )

//===========================================================================
//| Verifica a geração do arquivo                                           |
//===========================================================================
nHandle := FCREATE( cArqPesq , 0 )

If nHandle == -1
	u_itmsg( "Nao foi possivel abrir ou criar o arquivo: " + cArqPesq,"Atenção",,1 )
	Return()
EndIf

//===========================================================================
//| Monta o cabeçalho do arquivo                                            |
//===========================================================================
cCabHtml	:= "<!-- Created with AEdiX by Kirys Tech 2000,http://www.kt2k.com --> "				+ENTER
cCabHtml	+= "<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>"	 				+ENTER
cCabHtml	+= "<html>"															 					+ENTER
cCabHtml	+= "<head>"															 					+ENTER
cCabHtml	+= "  <title>Centro de custo</title>"									 				+ENTER
cCabHtml	+= "  <meta name='GENERATOR' content='AEdiX by Kirys Tech 2000,http://www.kt2k.com'>"	+ENTER
cCabHtml	+= "</head>"																			+ENTER
cCabHtml	+= "<body bgcolor='#FFFFFF'>"															+ENTER

cRodHtml	:= "</body>"																			+ENTER
cRodHtml	+= "</html>"

cFileCont	:= cCabHtml

cLinFile	:= "<table border='1' cellpadding='3' cellspacing='0' bordercolor='#8B8B83' bgColor='#FFFFFF'>"							+ENTER
cLinFile	+= "<TR>"																												+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Documento</b></TD>"							+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Parcela</b></TD>"								+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Emissao</b></TD>"								+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Cnpj</b></TD>"									+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Fatura</b></TD>"								+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Pagto.</b></TD>"								+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Dt.Operacao</b></TD>"							+ENTER
cLinFile	+= "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Saldo</b></FONT></TD>"			+ENTER
cLinFile	+= "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Maior Ac.</b></FONT></TD>"		+ENTER
cLinFile	+= "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Data M.A.</b></FONT></TD>"		+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Vcto Real</b></TD>"			  				+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Dt.Baixa</b></TD>"			 					+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Atraso</b></TD>"								+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Vlr.Atraso</b></TD>"							+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Dias AV</b></TD>"								+ENTER
cLinFile	+= "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Vlr.AV</b></TD>"								+ENTER
cLinFile	+= "</TR>"																												+ENTER

cFileCont	+= cLinFile
cLinFile	:= ""

FWRITE( nHandle , cFileCont )

lFlag		:= .T.

//===========================================================================
//| Monta o conteúdo do arquivo                                             |
//===========================================================================
For nI := 1 To nTotReg
	
	IncProc( "["+ StrZero(nI,6) +"] de ["+ StrZero( nTotReg , 6 ) +"]" )
	If lFlag
	
		IF	( SZY->ZY_PCVMAC == Val( StrTran( StrTran( aDadosAux[nI][08] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDMAC == CTOD( aDadosAux[nI][07] ) )	.OR.;
			( SZY->ZY_PCVPCO == Val( StrTran( StrTran( aDadosAux[nI][06] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDTPC == CTOD( aDadosAux[nI][03] ) )	.OR.;
			( SZY->ZY_PCVULC == Val( StrTran( StrTran( aDadosAux[nI][06] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDUCM == CTOD( aDadosAux[nI][03] ) )
			
			If CTOD( aDadosAux[nI][07] ) > YEARSUB( dDataRef , 1 )
			
				cLinFile		:= "<TR>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+ENTER
                Else
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                EndIf
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "</TR>"
				
 			ELSE
 			
				IF	( SZY->ZY_PCVMAC == Val( StrTran( StrTran( aDadosAux[nI][08] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDMAC == CTOD( aDadosAux[nI][07] ) )	.OR.;
					( SZY->ZY_PCVPCO == Val( StrTran( StrTran( aDadosAux[nI][06] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDTPC == CTOD( aDadosAux[nI][03] ) )	.OR.;
					( SZY->ZY_PCVULC == Val( StrTran( StrTran( aDadosAux[nI][06] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDUCM == CTOD( aDadosAux[nI][03] ) )

					cLinFile	:= "<TR>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+ AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                    If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
     				  cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
     				  cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+ENTER
                    Else
         			  cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+ENTER
      	    		  cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                    EndIf
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
    				cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
	    			cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "</TR>"

                 Else

					cLinFile	:= "<TR>"
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                    If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
     				  cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
         			  cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
                    Else
       		    	  cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
       			      cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                    EndIf
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
    				cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
	    			cLinFile	+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
					cLinFile	+= "</TR>"
					
			     EndIf
			     
			EndIf
						
		ELSE

			If	CTOD( aDadosAux[nI][07] ) > YEARSUB( dDataRef , 1 )

				cLinFile		:= "<TR>"
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b> </b></FONT></TD>"+ENTER
                Else
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b> </b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                EndIf
    			cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "</TR>"
				
			ELSE
			
				cLinFile := "<TR>"
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][03]		 		+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
	            If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
                Else
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                EndIf
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "</TR>"
				
			EndIf
					
		EndIf
		
		lFlag := .f.
		
	ELSE
	
		IF	( SZY->ZY_PCVMAC == Val( StrTran( StrTran( aDadosAux[nI][08] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDMAC == CTOD( aDadosAux[nI][07] ) )	.OR.;
			( SZY->ZY_PCVPCO == Val( StrTran( StrTran( aDadosAux[nI][06] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDTPC == CTOD( aDadosAux[nI][03] ) )	.OR.;
			( SZY->ZY_PCVULC == Val( StrTran( StrTran( aDadosAux[nI][06] ,".","" ) , "," , "." ) )	.AND. SZY->ZY_PCDUCM == CTOD( aDadosAux[nI][03] ) )
			
			If CTOD( aDadosAux[nI][07] ) > YEARSUB( dDataRef , 1 )
			
				cLinFile		:= "<TR>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+ENTER
                Else
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                EndIf
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "</TR>"
				
			ELSE
			
				cLinFile		:= "<TR>"
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
                Else
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                EndIf
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "</TR>"				

			EndIf
			
		ELSE
		
			IF	CTOD( aDadosAux[nI][07] ) > YEARSUB( dDataRef , 1 )
			
				cLinFile		:= "<TR>"
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>&nbsp</b></FONT></TD>"+ENTER
                Else
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>&nbsp</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                EndIf
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
    			cLinFile		+= "<TD bgcolor='#CAFF70' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "</TR>"
				
			ELSE
			
				cLinFile		:= "<TR>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][01] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][02] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][03]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][04] )	+"</b></FONT></TD>"+ENTER
                If Val( StrTran( StrTran( aDadosAux[nI][05] ,".","" ) , "," , "." ) ) > 0
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
                Else
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+ENTER
      				cLinFile	+= "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][06] )	+"</b></FONT></TD>"+ENTER
                EndIf
	    		cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][07]				+"</b></FONT></TD>"+ENTER
		        cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][08] )	+"</b></FONT></TD>"+ENTER
     			cLinFile		+= "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][09] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][10]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][11]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	aDadosAux[nI][12]				+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][13] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][14] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][17] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+	AllTrim( aDadosAux[nI][18] )	+"</b></FONT></TD>"+ENTER
				cLinFile		+= "</TR>"
				
			EndIf
			
		EndIf
		
		lFlag := .T.
		
	EndIf
	
	FWRITE( nHandle , cLinFile )
	cLinFile := ""
	
Next nI

cLinFile := "</Table>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<table border='1' cellpadding='3' cellspacing='0' bordercolor='#8B8B83' bgColor='#FFFFFF'>"+ENTER
cLinFile += "<TR>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Data Informação</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>"+DTOC(SZY->ZY_PCDDAT)+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Cnpj</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+SZY->ZY_PCCCLI+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data Cad.</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDCDD)+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vlr.Maior.Acum.</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVMAC,"@E 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data M.Acum</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDMAC)+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile ) 

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Deb.Atual Total</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVSAT,"@E 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Penúlt.Compra</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVPCO,"@e 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data Penúlt.Cp.</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDTPC)+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Ultima Compra.</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVULC,"@E 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data Ult.Compra</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDUCM)+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.Atraso</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCQPAG,"@E 999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Aritm.Atraso</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCQDAP,"@E 999.99")+"</b></FONT></TD>"+ENTER  
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vlr.Deb.a Venc.</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVDAV,"@E 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.A Vc.</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCMDAV,"@E 999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Prazo Med. Vd.</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCMPMV,"@E 999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vencido +5 dias</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCDATV,"@E 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.+5 dias</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCMPTV,"@E 999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vencido +15 dias</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCV15D,"@E 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.+15 dias</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCM15D,"@E 999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vencido +30 dias</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCV30D,"@E 9,999,999,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

cLinFile := "<TR>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.+30 dias</b></FONT></TD>"+ENTER
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCM30D,"@E 9,999.99")+"</b></FONT></TD>"+ENTER
cLinFile += "</TR>"+ENTER
FWRITE( nHandle , cLinFile )

//-- Acrescenta o rodape do html --//
FWRITE( nHandle , cRodHtml )

//-- Libera o Arquivo --//
FCLose(nHandle)

LjMsgRun( "Abrindo o arquivo..." , "Aguarde!" , {|| SHELLEXECUTE( "open" , cArqPesq , "" , "" , 5 ) } )

Return()

/*/

===============================================================================================================================
Programa----------: MOMS027BR1
Autor-------------: Alexandre Villar
Data da Criacao---: 28/02/2014
===============================================================================================================================
Descrição---------: Monta os itens do Browse 1 - [Rotina atualizada] 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
/*/

Static Function MOMS027BR1()

Local oFont1 := TFont():New( "Arial" , 9 , 7 ,.T.,.F.,5,.T.,5,.T.,.F.)

Aadd( aWBrowse1 , {" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "} )

@012,001 LISTBOX oWBrowse1	Fields HEADER	"Docto"		, "Parc."	, "Emissão"	, "CNPJ"	, "Valor Op."	, "Vlr Fat."	, "Data Op."	, "Saldo C/C "	, "Maior Acum. "	,;
											"Data M.A."	, "Vcto. "	, "Baixa"	, "Atraso"	, "Vlr Atr."	, "Data"		, "Valor"		, "Dias AV"		, "Vlr.AV"			 ;
							SIZE 400,220 FONT oFont1 OF oPanel1 PIXEL ColSizes 10,10,10,10,20,20,10,45,45,30,10,25,10,20,10,20,10,45

oWBrowse1:SetArray(aWBrowse1)

oWBrowse1:bLine := {|| {	aWBrowse1[oWBrowse1:nAt,01]	,;
							aWBrowse1[oWBrowse1:nAt,02]	,;
							aWBrowse1[oWBrowse1:nAt,03]	,;
							aWBrowse1[oWBrowse1:nAt,04]	,;
							aWBrowse1[oWBrowse1:nAt,05]	,;
							aWBrowse1[oWBrowse1:nAt,06]	,;
							aWBrowse1[oWBrowse1:nAt,07]	,;
							aWBrowse1[oWBrowse1:nAt,08]	,;
							aWBrowse1[oWBrowse1:nAt,09]	,;
							aWBrowse1[oWBrowse1:nAt,10]	,;
							aWBrowse1[oWBrowse1:nAt,11]	,;
							aWBrowse1[oWBrowse1:nAt,12]	,;
							aWBrowse1[oWBrowse1:nAt,13]	,;
							aWBrowse1[oWBrowse1:nAt,14]	,;
							aWBrowse1[oWBrowse1:nAt,15]	,;
							aWBrowse1[oWBrowse1:nAt,16]	,;
							aWBrowse1[oWBrowse1:nAt,17]	,;
							aWBrowse1[oWBrowse1:nAt,18]	}}
Return()

/*
===============================================================================================================================
Programa----------: MOMS027CD1
Autor-------------: Alexandre Villar
Data da Criacao---: 01/04/2014
===============================================================================================================================
Descrição---------: Carrega os dados do Browse 1 - Rotina atualizada
===============================================================================================================================
Parametros--------: cCNPJ - Chave do CNPJ do Cliente
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027CD1(cnpj)

Local _dDataDE2	:= YEARSUB( dDataRef , 1 )
Local cQuery	:= ""

cQuery := " SELECT "+ ENTER
cQuery += " 	E1_NUM,"+ENTER
cQuery += " 	E1_PARCELA,"+ENTER
cQuery += " 	E1_EMISSAO,"+ENTER
cQuery += " 	SUBSTR(A1_CGC,1,8) AS CNPJ,"+ENTER
cQuery += " 	E1_VALOR,"+ENTER
cQuery += " 	F2_VALFAT,"+ENTER
cQuery += " 	E1_EMISSAO AS DATACC,"+ENTER
cQuery += " 	0 AS SALDO,"+ENTER
cQuery += " 	E1_VENCREA,"+ ENTER
cQuery += " 	CASE WHEN E1_VENCREA >= '"+ DTOS(_dDataDE2) +"' THEN ' ' ELSE E1_BAIXA END AS E1_BAIXA , "+ENTER
cQuery += " 	0 AS DIATRA ,"+ENTER
cQuery += " 	0 AS VLRCALC, "+ENTER
cQuery += " 	'' AS DATAM,"+ENTER
cQuery += " 	0 AS VLRM,"+ENTER
cQuery += " 	CASE WHEN E1_VENCREA >= '"+ DTOS(Date()) +"' THEN E1_VALOR ELSE 0 END AS VLRDAV,"+ENTER
cQuery += " 	CASE WHEN E1_VENCREA > '"+ DTOS(Date()) +"' THEN ABS( TO_DATE(E1_EMISSAO,'YYYYMMDD')-TO_DATE(E1_VENCREA,'YYYYMMDD') ) ELSE 0 END AS DIASAV, "+ENTER
cQuery += " 	CASE WHEN E1_VENCREA > '"+ DTOS(Date()) +"' THEN ABS( TO_DATE(E1_EMISSAO,'YYYYMMDD')-TO_DATE(E1_VENCREA,'YYYYMMDD') ) * E1_VALOR ELSE 0 END AS VLRAVC,"+ENTER
cQuery += " 	A1_LC,"+ENTER
cQuery += " 	1 AS ORDEM"+ENTER

cQuery += " FROM "+ RetSqlName("SE1") +" SE1"+ENTER

cQuery += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON"+ENTER
cQuery += " 		SE1.E1_CLIENTE	= SA1.A1_COD "+ENTER
cQuery += " AND 	SE1.E1_LOJA		= SA1.A1_LOJA "+ENTER
cQuery += " AND		SA1.A1_FILIAL	= '"+ xFilial("SA1") +"' "+ENTER

cQuery += " INNER JOIN "+ RetSqlName("SF2") +" SF2 ON "+ENTER
cQuery += " 	SE1.E1_FILIAL			= SF2.F2_FILIAL "+ENTER
cQuery += " AND	SE1.E1_NUM				= SF2.F2_DOC "+ENTER
cQuery += " AND	SE1.E1_PREFIXO			= SF2.F2_SERIE "+ENTER
cQuery += " AND SE1.E1_CLIENTE			= SF2.F2_CLIENTE "+ENTER
cQuery += " AND	SE1.E1_LOJA				= SF2.F2_LOJA "+ENTER
cQuery += " AND	SF2.D_E_L_E_T_			= ' ' "+ENTER

cQuery += " WHERE"+ENTER
cQuery += " 		SE1.E1_EMISSAO	<= '"+ DTOS(Date())	+"'"+ENTER
cQuery += " AND (	SE1.E1_BAIXA	>= '"+ DTOS(_dDataDE2)	+"' OR TRIM(SE1.E1_BAIXA) IS NULL )"+ENTER
cQuery += " AND		SE1.E1_TIPO		NOT IN ( 'NCC' , 'RA', 'NDC' ) "+ENTER
cQuery += " AND		SE1.D_E_L_E_T_	= ' ' "+ENTER
cQuery += " AND	    SE1.E1_I_AVACC <> 'N' " +ENTER
cQuery += " AND     SE1.E1_VENCREA > '" + DTOS(dDataRef - 1825) +"' "+ENTER
cQuery += " AND		SA1.D_E_L_E_T_	= ' ' "+ENTER
cQuery += " AND		SUBSTR(A1_CGC,1,8)	BETWEEN '"+CNPJ+"' AND '"+CNPJ+"' "+ENTER

cQuery += " UNION ALL"+ENTER

cQuery += " SELECT"+ENTER
cQuery += " 	E1_NUM,"+ENTER
cQuery += " 	E1_PARCELA,"+ENTER
cQuery += " 	E1_EMISSAO,"+ENTER
cQuery += " 	SUBSTR(A1_CGC,1,8) AS CNPJ, "+ENTER
cQuery += " 	CASE WHEN TRIM(E1_BAIXA) IS NOT NULL THEN (E1_VALOR*-1) END AS E1_VALOR,"+ENTER
cQuery += " 	0 AS F2_VALFAT,"+ENTER
cQuery += " 	CASE WHEN TRIM(E1_BAIXA) IS NOT NULL THEN E1_BAIXA END AS DATACC,"+ENTER
cQuery += " 	0 AS SALDO,"+ENTER
cQuery += " 	E1_VENCREA,"+ENTER
cQuery += " 	E1_BAIXA,"+ENTER
cQuery += " 	CASE "+ENTER
cQuery += " 		WHEN ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE(E1_BAIXA,'YYYYMMDD') ) >= 0	THEN ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE(E1_BAIXA,'YYYYMMDD') ) "+ENTER
cQuery += " 		WHEN TRIM(E1_BAIXA) IS NOT NULL AND E1_BAIXA > E1_VENCREA					THEN ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE('"+ DTOS(Date()) +"','YYYYMMDD') ) "+ENTER
cQuery += " 		WHEN TRIM(E1_BAIXA) IS NULL AND E1_VENCREA < '"+ DTOS(Date())+"'		THEN ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE('"+ DTOS(Date()) +"','YYYYMMDD') ) "+ENTER
cQuery += " 		ELSE 0 END AS DIATRA,"+ENTER
cQuery += " 	CASE "+ENTER
cQuery += " 		WHEN ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE(E1_BAIXA,'YYYYMMDD') ) >= 0	THEN ( E1_VALOR * ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE(E1_BAIXA,'YYYYMMDD') ) ) "+ENTER
cQuery += " 		WHEN TRIM(E1_BAIXA) IS NOT NULL AND E1_BAIXA > E1_VENCREA					THEN ( E1_VALOR * ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE('"+ DTOS(Date()) +"','YYYYMMDD') ) )"+ENTER
cQuery += " 		WHEN TRIM(E1_BAIXA) IS NULL AND E1_VENCREA < '"+DTOS(Date())+"'		THEN ( E1_VALOR * ABS( TO_DATE(E1_VENCREA,'YYYYMMDD')-TO_DATE('"+ DTOS(Date()) +"','YYYYMMDD') ) )"+ENTER
cQuery += " 		ELSE 0 END AS VLRCALC,"+ENTER
cQuery += " 	'' AS DATAM,"+ENTER
cQuery += " 	0 AS VLRM,"+ENTER
cQuery += " 	0 AS VLRDAV,"+ENTER
cQuery += " 	0 AS DIASAV,"+ENTER
cQuery += " 	0 AS VLRAVC,"+ENTER
cQuery += " 	A1_LC,"+ENTER
cQuery += " 	2 AS ORDEM"+ENTER
cQuery += " FROM "+ RetSqlName("SE1") +" SE1 "+ENTER

cQuery += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON"+ENTER
cQuery += " 		SE1.E1_CLIENTE	= SA1.A1_COD"+ENTER
cQuery += " AND	SE1.E1_LOJA		= SA1.A1_LOJA"+ENTER
cQuery += " AND	SA1.D_E_L_E_T_	= ' ' "+ENTER
cQuery += " AND	SA1.A1_FILIAL	= '"+ xFilial("SA1") +"' "+ENTER

cQuery += " INNER JOIN "+ RetSqlName("SF2") +" SF2 ON "+ENTER
cQuery += " 	SE1.E1_FILIAL			= SF2.F2_FILIAL "+ENTER
cQuery += " AND	SE1.E1_NUM				= SF2.F2_DOC "+ENTER
cQuery += " AND	SE1.E1_PREFIXO			= SF2.F2_SERIE "+ENTER
cQuery += " AND SE1.E1_CLIENTE			= SF2.F2_CLIENTE "+ENTER
cQuery += " AND	SE1.E1_LOJA				= SF2.F2_LOJA "+ENTER
cQuery += " AND	SF2.D_E_L_E_T_			= ' ' "+ENTER

cQuery += " WHERE"+ENTER
cQuery += " 		SE1.E1_EMISSAO	<= '"+ DTOS(Date()) +"'"+ENTER
cQuery += " AND	SE1.E1_TIPO		NOT IN ( 'NCC' , 'RA', 'NDC' ) "+ENTER
cQuery += " AND	SE1.D_E_L_E_T_	= ' ' "+ENTER
cQuery += " AND	SE1.E1_I_AVACC <> 'N' " +ENTER
cQuery += " AND	SE1.E1_BAIXA	<> ' ' "+ENTER
cQuery += " AND	SE1.E1_BAIXA	>= '"+ DTOS(_dDataDE2) +"'"+ENTER
cQuery += " AND	SE1.E1_VENCREA	< '"+ DTOS(Date()) +"'"+ENTER
cQuery += " AND SE1.E1_VENCREA > '" + DTOS(dDataRef - 1825) +"' "+ENTER
cQuery += " AND	SUBSTR(SA1.A1_CGC,1,8) BETWEEN  '"+CNPJ+"' AND '"+CNPJ+"' "+ENTER

cQuery += " ORDER BY CNPJ , DATACC , E1_NUM , E1_PARCELA , ORDEM "+ENTER

If Select("TRB1") > 0
	TRB1->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , "TRB1" , .T. , .F. )
DBSelectArea("TRB1")

//==================================================================================
// Fecha Alias se estiver em Uso 
//==================================================================================
If Select("TRD1") > 0
	TRD1->( DBCloseArea() )
EndIf

//==================================================================================
// Monta a interface padrao com o usuario...                           
//==================================================================================
aCampos :=	{	{ "E1_NUM"    , "C" , 06 , 0 } ,;
				{ "E1_PARCELA", "C" , 03 , 0 } ,;
				{ "E1_EMISSAO", "D" , 08 , 0 } ,;
				{ "CNPJ"      , "C" , 08 , 0 } ,;
				{ "E1_VALOR"  , "N" , 16 , 2 } ,;
				{ "F2_VALFAT" , "N" , 16 , 2 } ,;
				{ "DATACC"    , "D" , 08 , 0 } ,;
				{ "SALDO"     , "N" , 16 , 2 } ,; 
				{ "MAIORAC"   , "N" , 16 , 2 } ,; 
				{ "DATAMAC"   , "D" , 08 , 2 } ,; 
				{ "E1_VENCREA", "D" , 08 , 2 } ,;
				{ "E1_BAIXA"  , "D" , 08 , 0 } ,;
				{ "DIATRA"    , "N" , 09 , 0 } ,;
				{ "VLRCALC"   , "N" , 16 , 2 } ,;
				{ "DATAM"     , "D" , 08 , 0 } ,;
				{ "VLRM"      , "N" , 16 , 2 } ,;
				{ "DIASAV"    , "N" , 09 , 0 } ,;
				{ "VLRAVC"    , "N" , 16 , 2 }  }

_otemp := FWTemporaryTable():New( "TRD1", aCampos )

_otemp:Create()

xSaldo	:= 0 
xSaldo1	:= 0
xSalac	:= 0
xData 	:= STOD("")

While TRB1->(!EoF()) 

	xSaldo1	+= TRB1->E1_VALOR
   	xSaldo	+= TRB1->E1_VALOR 
   	
   	If xSaldo1 < 0
       xSaldo1 := 0
	   xSaldo  := 0
   	EndIf
   	
	TRD1->( Reclock( "TRD1" , .T. ) )
	
		TRD1->E1_NUM		:= TRB1->E1_NUM
		TRD1->E1_PARCELA	:= TRB1->E1_PARCELA
		TRD1->E1_EMISSAO	:= STOD( TRB1->E1_EMISSAO )
		TRD1->CNPJ			:= TRB1->CNPJ
		TRD1->E1_VALOR		:= TRB1->E1_VALOR
		TRD1->F2_VALFAT		:= TRB1->F2_VALFAT
		TRD1->DATACC		:= STOD( TRB1->DATACC )
		
	    If xSaldo1 >= xSalac .and. STOD( TRB1->DATACC ) >= _dDataDE2
		    xSalac			:= xSaldo
		    xData			:= STOD( TRB1->DATACC )
		EndIf
		
		TRD1->E1_VENCREA	:= STOD( TRB1->E1_VENCREA )
		TRD1->E1_BAIXA		:= STOD( TRB1->E1_BAIXA )
		TRD1->DIATRA		:= TRB1->DIATRA
		TRD1->VLRCALC		:= TRB1->VLRCALC
		TRD1->DATAM			:= STOD( TRB1->DATAM )
		TRD1->VLRM			:= TRB1->VLRM
		TRD1->DIASAV		:= TRB1->DIASAV
		TRD1->VLRAVC		:= TRB1->VLRAVC
	   	TRD1->MAIORAC		:= xSalac
	    TRD1->DATAMAC		:= xData
		TRD1->SALDO			:= XSALDO
		
	TRD1->( Msunlock() )
	
TRB1->(DbSkip())
EndDo

TRD1->( DbGotop() )
xSaldo := 0

If TRD1->( !Eof() )

	aWBrowse1 := {}

	While TRD1->(!Eof())
	
		xSaldo += TRD1->E1_VALOR 
		
		Aadd( aWBrowse1 , {	ALLTRIM(	TRD1->E1_NUM )	  							,;
							ALLTRIM(	TRD1->E1_PARCELA )							,;
							DTOC(		TRD1->E1_EMISSAO )							,;
							ALLTRIM(	TRD1->CNPJ )								,;
							TRANSFORM(	TRD1->E1_VALOR	, "@e 9,999,999,999.99" )	,;
							TRANSFORM(	TRD1->F2_VALFAT	, "@e 9,999,999,999.99" )	,;
							DTOC(		TRD1->DATACC )								,;
							TRANSFORM(	TRD1->SALDO		, "@e 9,999,999,999.99" )	,;
							TRANSFORM(	TRD1->MAIORAC	, "@e 9,999,999,999.99" )	,;		
							DTOC(		TRD1->DATAMAC )								,;		
							DTOC(		TRD1->E1_VENCREA )							,;
							DTOC(		TRD1->E1_BAIXA )							,;
							TRANSFORM(	TRD1->DIATRA	, "@e 999,999" )			,;
							TRANSFORM(	TRD1->VLRCALC	, "@e 9,999,999,999.99" )	,;
							DTOC(		TRD1->DATAM )								,;
							TRANSFORM(	TRD1->VLRM		, "@e 9,999,999,999.99" )	,;
							TRANSFORM(	TRD1->DIASAV	, "@e 999,999")	  			,;
							TRANSFORM(	TRD1->VLRAVC	, "@e 9,999,999,999.99" )	})
		
	TRD1->(DbSkip())
	EndDo
	
Else

	cGet3		:= " "
	cGet4		:= " "
	aWBrowse1	:= {}
	
	aAdd( aWBrowse1 , {" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "} )
	u_itmsg( "Cnpj sem movimento!" , "Atenção",,1 )
	
EndIf

oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {	aWBrowse1[oWBrowse1:nAt,01]		,;
							aWBrowse1[oWBrowse1:nAt,02]		,;
							aWBrowse1[oWBrowse1:nAt,03]		,;
							aWBrowse1[oWBrowse1:nAt,04]		,;
							aWBrowse1[oWBrowse1:nAt,05]		,;
							aWBrowse1[oWBrowse1:nAt,06]		,;
							aWBrowse1[oWBrowse1:nAt,07]		,;
							aWBrowse1[oWBrowse1:nAt,08]		,;
							aWBrowse1[oWBrowse1:nAt,09]		,;
							aWBrowse1[oWBrowse1:nAt,10]		,;
							aWBrowse1[oWBrowse1:nAt,11]		,;
							aWBrowse1[oWBrowse1:nAt,12]		,;
							aWBrowse1[oWBrowse1:nAt,13]		,;
							aWBrowse1[oWBrowse1:nAt,14]		,;
							aWBrowse1[oWBrowse1:nAt,15]		,;
							aWBrowse1[oWBrowse1:nAt,16]		,;
							aWBrowse1[oWBrowse1:nAt,17]		,;
							aWBrowse1[oWBrowse1:nAt,18]		}}
							
Return

/*
===============================================================================================================================
Programa----------: MOMS027I
Autor-------------: Alexandre Villar
Data da Criacao---: 30/04/2014
===============================================================================================================================
Descrição---------: Importa o arquivo gerado e exibe na tela com opção de exportação pra Excel
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027I()

Local oDlg		:= Nil
Local oBtnAux	:= Nil
Local cArqAux	:= Space(150)
Local nOpc		:= 0

//===========================================================================
//| Solicita a indicação do diretório de destino                            |
//===========================================================================
DEFINE MSDIALOG oDlg TITLE "Validação de Arquivo [TXT]" FROM 0,0 TO 060,552 OF oDlg PIXEL

	@005,005 SAY "Selecione o Arquivo:"				SIZE 065,010 PIXEL OF oDlg COLOR CLR_HBLUE
	@014,005 MSGET cArqAux PICTURE "@!"				SIZE 195,010 PIXEL OF oDlg
	
	@029,400 BTNBMP oBtnAux RESOURCE "OPEN_OCEAN"	SIZE 025,025 PIXEL OF oDlg ACTION ( cArqAux := cGetFile( "*.txt" , "Selecione o Diretorio de Destino:" , 1 , "C:\" , .F. , GETF_LOCALHARD + GETF_NETWORKDRIVE ) )
	
	@004,245 BUTTON "&Ok"							SIZE 030,011 PIXEL OF oDlg ACTION ( nOpc := 1 , oDlg:End() )
	@016,245 BUTTON "&Cancelar"						SIZE 030,011 PIXEL OF oDlg ACTION ( nOpc := 0 , oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTER

//===========================================================================
//| Verifica a opção e a pasta de destino                                   |
//===========================================================================
If nOpc == 1

	cArqAux := AllTrim(cArqAux)
	Processa( {|| MOMS027VT( cArqAux ) } , "Lendo Arquivo TXT..." , "Aguarde!" , .F. )
	
Else

	u_itmsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS027VT
Autor-------------: Alexandre Villar
Data da Criacao---: 30/04/2014
===============================================================================================================================
Descrição---------: Monta os dados e prepara a exportação para Excel
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027VT( cArqAux )

Local aColAux	:= {}
Local aHeader	:= {}
Local cBuffer	:= ""
Local lValida	:= .F.
Local nHdlAux	:= FT_FUSE( cArqAux )
Local nLinha	:= 0
Local nTotReg	:= 0
Local nRegVal	:= 0 , nI

IF nHdlAux == -1
	u_itmsg( "Não foi possível abrir o arquivo informado! Verifique o arquivo e tente novamente.","Atenção",,1 )
	Return()
EndIF

nTotReg := FT_FLastRec()

IF nTotReg > 0

	aHeader := {	"Tipo Ident."					,; //| 01 |
					"Código Associado"				,; //| 02 |
					"Id. Cliente"					,; //| 03 |
					"Data da Informação"			,; //| 04 |
					"Data Inc. do Cliente" 			,; //| 05 |
					"Data da Última Compra"			,; //| 06 |
					"Valor da Última Compra"		,; //| 07 |
					"Data do Maior Acúmulo"			,; //| 08 |
					"Valor Maior Acúmulo"			,; //| 09 |
					"Valor Débito Atual Total"		,; //| 10 |
					"Valor Limite de Crédito"		,; //| 11 |
					"M.P. de Atrasos"				,; //| 12 |
					"M.A. de Atrasos"				,; //| 13 |
					"Valor Débito a Vencer"			,; //| 14 |
					"M.P. a Vencer"					,; //| 15 |
					"Prazo Médio de Vendas"			,; //| 16 |
					"Valor Vencido (>5 Dias)"		,; //| 17 |
					"M.P. Vencidos (>5 Dias)"		,; //| 18 |
					"Valor Vencido (>15 Dias)"		,; //| 19 |
					"M.P. Vencidos (>15 Dias)"		,; //| 20 |
					"Valor Vencido (>30 Dias)"		,; //| 21 |
					"M.P. Vencidos (>30 Dias)"		,; //| 22 |
					"Data da Penúltima Compra"		,; //| 23 |
					"Valor da Penúltima Compra"		,; //| 24 |
					"Cálculo Limite de Crédito"		,; //| 25 |
					"Tipo de Garantia"				,; //| 26 |
					"Grau da Garantia"				,; //| 27 |
					"Data Validade da Garantia"		,; //| 28 |
					"Valor da Garantia"				,; //| 29 |
					"Valor Pagamento Antecipado"	,; //| 30 |
					"Venda sem Crédito"				 } //| 31 |
	
	ProcRegua( nTotReg )
	
	FT_FGoTop()
	
	While !FT_FEOF()
	
		cBuffer	:= FT_FReadLn()
		nLinha++
		IncProc( "["+ StrZero( nLinha , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
		
		If !Empty(cBuffer) .And. Len( cBuffer ) == 280
			
			aAdd( aColAux , {	SubStr( cBuffer , 001 , 01 )									,; //01	PCTIPO	N 01 001 / 001	Identif. (1-CNPJ / 2-CPF / 3-RG / 4-Export. / 5-Insc.Prod./ 9-Outros)
								SubStr( cBuffer , 002 , 04 )									,; //02	PCCASS	N 04 002 / 005	Código do Associado
								SubStr( cBuffer , 006 , 20 )									,; //03	PCCCLI	N 20 006 / 025	Identificação. (CNPJ / CPF / RG / Export. / Insc.Prod. / Outros)
								SubStr( cBuffer , 026 , 08 )									,; //04	PCDDAT	N 08 026 / 033	Data da Informação
								SubStr( cBuffer , 034 , 08 )									,; //05	PCDCDD	N 08 034 / 041	Data  Cadastramento do Cliente
								SubStr( cBuffer , 042 , 08 )									,; //06	PCDUCM	N 08 042 / 049	Data da Última Compra
								SubStr( cBuffer , 050 , 13 ) +"."+ SubStr( cBuffer , 063 , 02 )	,; //07	PCVULC	N 15 050 / 064	Valor da Última Compra
								SubStr( cBuffer , 065 , 08 )									,; //08	PCDMAC	N 08 065 / 072	Data  do Maior Acúmulo
								SubStr( cBuffer , 073 , 13 ) +"."+ SubStr( cBuffer , 086 , 02 )	,; //09	PCVMAC	N 15 073 / 087	Valor Maior Acúmulo
								SubStr( cBuffer , 088 , 13 ) +"."+ SubStr( cBuffer , 101 , 02 )	,; //10	PCVSAT	N 15 088 / 102	Valor Débito Atual Total
								SubStr( cBuffer , 103 , 13 ) +"."+ SubStr( cBuffer , 116 , 02 )	,; //11	PCVLCR	N 15 103 / 117	Valor Limite de Crédito
								SubStr( cBuffer , 118 , 04 ) +"."+ SubStr( cBuffer , 122 , 02 )	,; //12	PCQPAG	N 06 118 / 123	Média Ponderada de Atraso (Títulos Pagos)
								SubStr( cBuffer , 124 , 04 ) +"."+ SubStr( cBuffer , 128 , 02 )	,; //13	PCQDAP	N 06 124 / 129	Média Aritm.Dias de Atraso Pagamento
								SubStr( cBuffer , 130 , 13 ) +"."+ SubStr( cBuffer , 143 , 02 )	,; //14	PCVDAV	N 15 130 / 144	Valor Débito Atual a Vencer
								SubStr( cBuffer , 145 , 04 ) +"."+ SubStr( cBuffer , 149 , 02 )	,; //15	PCMDAV	N 06 145 / 150	Média Ponderada de Títulos a Vencer
								SubStr( cBuffer , 151 , 04 ) +"."+ SubStr( cBuffer , 155 , 02 )	,; //16	PCMPMV	N 06 151 / 156	Prazo Médio de Vendas 
								SubStr( cBuffer , 157 , 13 ) +"."+ SubStr( cBuffer , 170 , 02 )	,; //17	PCDATV	N 15 157 / 171	Valor Débito Atual Vencido + 5 Dias
								SubStr( cBuffer , 172 , 04 )									,; //18	PCMPTV	N 04 172 / 175	Média Ponderada de Atraso + 5 Dias
								SubStr( cBuffer , 176 , 13 ) +"."+ SubStr( cBuffer , 189 , 02 )	,; //19	PCV+15D	N 15 176 / 190	Valor Débito Atual Vencido + 15 Dias
								SubStr( cBuffer , 191 , 04 )									,; //20	PCM+15D	N 04 191 / 194	Média Ponderada de Atraso + 15 Dias
								SubStr( cBuffer , 195 , 13 ) +"."+ SubStr( cBuffer , 208 , 02 )	,; //21	PCV+30D	N 15 195 / 209	Valor Débito Atual Vencido + 30 Dias
								SubStr( cBuffer , 210 , 04 )									,; //22	PCM+30D	N 04 210 / 213	Média Ponderada de Atraso + 30 Dias
								SubStr( cBuffer , 214 , 08 )									,; //23	PCDTPC	N 08 214 / 221	Data da Penúltima Compra
								SubStr( cBuffer , 222 , 13 ) +"."+ SubStr( cBuffer , 235 , 02 )	,; //24	PCVPCO	N 15 222 / 236	Valor da Penúltima Compra
								SubStr( cBuffer , 237 , 01 )									,; //25	PCVSIT	N 01 237 / 237	Situação do Cálculo Limite de Crédito
								SubStr( cBuffer , 238 , 01 )									,; //26	PCTIPG	N 01 238 / 238	Tipo de Garantia
								SubStr( cBuffer , 239 , 02 )									,; //27	PCGGA	N 02 239 / 240	Grau da Garantia - Hipoteca
								SubStr( cBuffer , 241 , 08 )									,; //28	PCDTG	N 08 241 / 248	Data Validade da Garantia
								SubStr( cBuffer , 249 , 13 ) +"."+ SubStr( cBuffer , 262 , 02 )	,; //29	PCVLG	N 15 249 / 263	Valor da Garantia
								SubStr( cBuffer , 264 , 13 ) +"."+ SubStr( cBuffer , 277 , 02 )	,; //30	PCVPA	N 15 264 / 278	Valor da Venda Pagamento Antecipado
								SubStr( cBuffer , 279 , 02 )									}) //31	PCSVV	C 02 279 / 280	Venda sem Crédito (ANTECIPADO)
		
		EndIF
		
	FT_FSKIP()
	EndDo
	
	IF Empty( aColAux )
		u_itmsg(  "Não foram encontrados registros válidos para exibir! Verifique o arquivo e tente novamente." , "Atenção!",,1 )
	Else
		
		nRegVal := Len( aColAux )
		
		ProcRegua( nRegVal )
		
		For nI := 1 To nRegVal
		
			IncProc( "["+ StrZero( nI , 9 ) +"] de ["+ StrZero( nRegVal , 9 ) +"]" )
			
			//===========================================================================
			//| Ajusta formato dos campos de Data                                       |
			//===========================================================================
			aColAux[nI][04] := StoD(	aColAux[nI][04] )
			aColAux[nI][05] := StoD(	aColAux[nI][05] )
			aColAux[nI][06] := StoD(	aColAux[nI][06] )
			aColAux[nI][08] := StoD(	aColAux[nI][08] )
			aColAux[nI][23] := StoD(	aColAux[nI][23] )
			aColAux[nI][28] := StoD(	aColAux[nI][28] )
			
			//===========================================================================
			//| Ajusta formato dos campos de Valor                                      |
			//===========================================================================
			aColAux[nI][07] := Val(		aColAux[nI][07] )
			aColAux[nI][09] := Val(		aColAux[nI][09] )
			aColAux[nI][10] := Val(		aColAux[nI][10] )
			aColAux[nI][11] := Val(		aColAux[nI][11] )
			aColAux[nI][12] := Val(		aColAux[nI][12] )
			aColAux[nI][13] := Val(		aColAux[nI][13] )
			aColAux[nI][14] := Val(		aColAux[nI][14] )
			aColAux[nI][15] := Val(		aColAux[nI][15] )
			aColAux[nI][16] := Val(		aColAux[nI][16] )
			aColAux[nI][17] := Val(		aColAux[nI][17] )
			aColAux[nI][18] := Val(		aColAux[nI][18] )
			aColAux[nI][19] := Val(		aColAux[nI][19] )
			aColAux[nI][20] := Val(		aColAux[nI][20] )
			aColAux[nI][21] := Val(		aColAux[nI][21] )
			aColAux[nI][22] := Val(		aColAux[nI][22] )
			aColAux[nI][24] := Val(		aColAux[nI][24] )
			aColAux[nI][29] := Val(		aColAux[nI][29] )
			aColAux[nI][30] := Val(		aColAux[nI][30] )
		
		Next nI
		
		//===========================================================================
		//| Chama a rotina que constrói a tela e permite a exportação               |
		//===========================================================================
		lValida := U_ITListBox( "Leitura do Arquivo CISP: ["+ StrZero( nRegVal , 9 ) +"] registros." , aHeader , aColAux , .T. )
		
		If lValida .And. u_itmsg( "Deseja processar a validação dos dados do arquivo?" , "Atenção!" ,,3,2,2 ) 
			LjMsgRun( "Validando dados do arquivo..." , "Aguarde!" , {|| MOMS027VAR(aColAux) } )
		EndIf
	
	EndIF

Else

	u_itmsg(  "O arquivo está vazio ou é inválido para análise! Verifique o arquivo e tente novamente." , "Atenção!" ,,1 )

EndIF

Return()

/*
===============================================================================================================================
Programa----------: MOMS027VAR
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Rotina de validação das informações da Base CISP
===============================================================================================================================
Parametros--------: aDados	- Array com os dados do arquivo para validação
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027VAR( aDados )

Local aDadosAux	:= {}
Local lValid	:= .F.
Local nI		:= 0
Local nTotReg	:= 0
                  
//===========================================================================
//| Posiciona no alias da base CISP                                         |
//===========================================================================
nTotReg := Len( aDados )

ProcRegua(nTotReg)

//===========================================================================
//| Processa a validação dos conteúdos                                      |
//===========================================================================
While nI < nTotReg
	
	nI++
	IncProc( "["+ StrZero( nI , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )

//01	PCTIPO	N 01 001 / 001	Identif. (1-CNPJ / 2-CPF / 3-RG / 4-Export. / 5-Insc.Prod./ 9-Outros)
//02	PCCASS	N 04 002 / 005	Código do Associado
//03	PCCCLI	N 20 006 / 025	Identificação. (CNPJ / CPF / RG / Export. / Insc.Prod. / Outros)
//04	PCDDAT	N 08 026 / 033	Data da Informação
//05	PCDCDD	N 08 034 / 041	Data  Cadastramento do Cliente
//06	PCDUCM	N 08 042 / 049	Data da Última Compra
//07	PCVULC	N 15 050 / 064	Valor da Última Compra
//08	PCDMAC	N 08 065 / 072	Data  do Maior Acúmulo
//09	PCVMAC	N 15 073 / 087	Valor Maior Acúmulo
//10	PCVSAT	N 15 088 / 102	Valor Débito Atual Total
//11	PCVLCR	N 15 103 / 117	Valor Limite de Crédito
//12	PCQPAG	N 06 118 / 123	Média Ponderada de Atraso (Títulos Pagos)
//13	PCQDAP	N 06 124 / 129	Média Aritm.Dias de Atraso Pagamento
//14	PCVDAV	N 15 130 / 144	Valor Débito Atual a Vencer
//15	PCMDAV	N 06 145 / 150	Média Ponderada de Títulos a Vencer
//16	PCMPMV	N 06 151 / 156	Prazo Médio de Vendas 
//17	PCDATV	N 15 157 / 171	Valor Débito Atual Vencido + 5 Dias
//18	PCMPTV	N 04 172 / 175	Média Ponderada de Atraso + 5 Dias
//19	PCV+15D	N 15 176 / 190	Valor Débito Atual Vencido + 15 Dias
//20	PCM+15D	N 04 191 / 194	Média Ponderada de Atraso + 15 Dias
//21	PCV+30D	N 15 195 / 209	Valor Débito Atual Vencido + 30 Dias
//22	PCM+30D	N 04 210 / 213	Média Ponderada de Atraso + 30 Dias
//23	PCDTPC	N 08 214 / 221	Data da Penúltima Compra
//24	PCVPCO	N 15 222 / 236	Valor da Penúltima Compra
//25	PCVSIT	N 01 237 / 237	Situação do Cálculo Limite de Crédito
//26	PCTIPG	N 01 238 / 238	Tipo de Garantia
//27	PCGGA	N 02 239 / 240	Grau da Garantia - Hipoteca
//28	PCDTG	N 08 241 / 248	Data Validade da Garantia
//29	PCVLG	N 15 249 / 263	Valor da Garantia
//30	PCVPA	N 15 264 / 278	Valor da Venda Pagamento Antecipado
//31	PCSVV	C 02 279 / 280	Venda sem Crédito (ANTECIPADO)

	//===========================================================================
	//| Verifica o preenchimento da data de cadastro                            |
	//===========================================================================
	IF EMPTY( aDados[nI][05] )
		lValid := .T.
		aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data de cadastro do Cliente está em branco." } )
	ElseIF aDados[nI][05] > aDados[nI][04]
		lValid := .T.
		aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data de cadastro do Cliente é maior que a data de atualização da base." } )
	EndIF
	
	//===========================================================================
	//| Só valida clientes que possuem registro de data de última compra.       |
	//===========================================================================
	If !EMPTY(aDados[nI][06])
		
		//===========================================================================
		//| Só valida clientes que possuem registro de valor da última compra.      |
		//===========================================================================
		If !EMPTY(aDados[nI][07]) .And. aDados[nI][07] > 0

			//===========================================================================
			//| Validações da Data de Última Compra                                     |
			//===========================================================================
			IF aDados[nI][06] > aDados[nI][04]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data da última compra é maior que a data de atualização da base." } )
			EndIF
			
			IF aDados[nI][06] < aDados[nI][05]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data da última compra é menor do que a data de cadastro do Cliente." } )
			EndIF
			
			IF aDados[nI][06] <= aDados[nI][23]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data da última compra é menor ou igual do que a data da penúltima compra." } )
			EndIF
			
			//===========================================================================
			//| Validações da Data de Maior Acúmulo do Cliente                          |
			//===========================================================================
			IF aDados[nI][08] > aDados[nI][04]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data de maior acúmulo é maior do que a data de atualização da base." } )
			EndIF
			
			IF aDados[nI][08] < aDados[nI][05]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data de maior acúmulo é menor do que a data de cadastro do Cliente." } )
			EndIF
			
			IF aDados[nI][08] > aDados[nI][06]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Data de maior acúmulo é maior do que a data da última compra." } )
			EndIF
			
				
			//===========================================================================
			//| Validações do Valor de Maior Acúmulo do Cliente                         |
			//===========================================================================
			IF aDados[nI][09] < aDados[nI][10]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O valor do maior acúmulo é menor do que o valor do saldo atual do Cliente." } )
			EndIF
			
			IF aDados[nI][09] < aDados[nI][07]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O valor do maior acúmulo é menor do que o valor da última compra do Cliente." } )
			EndIF
			
			//===========================================================================
			//| Validações do Valor do Saldo Atual do Cliente                           |
			//===========================================================================
			IF aDados[nI][10] < aDados[nI][14]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo atual é menor do que o saldo atual à vencer do Cliente." } )
			EndIF
			
			IF aDados[nI][10] < aDados[nI][17]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo atual é menor do que o saldo vencido (+5) do Cliente." } )
			EndIF
			
			IF aDados[nI][10] < aDados[nI][19]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo atual é menor do que o saldo vencido (+15) do Cliente." } )
			EndIF
			
			IF aDados[nI][10] < aDados[nI][21]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo atual é menor do que o saldo vencido (+30) do Cliente." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média Ponderada de Atrasos do Cliente                      |
			//===========================================================================
			IF aDados[nI][12] == 0 .And. aDados[nI][13] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de atrasos é igual a zero e a média aritmética não é igual a zero." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média Aritmética de Atrasos do Cliente                     |
			//===========================================================================
			IF aDados[nI][13] == 0 .And. aDados[nI][12] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média aritmética de atrasos é igual a zero e a média ponderada não é igual a zero." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo Atual à vencer do Cliente                            |
			//===========================================================================
			IF aDados[nI][14] > aDados[nI][10]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo atual à vencer é maior que o saldo total atual do Cliente." } )
			EndIF
			
			IF aDados[nI][14] == 0 .And. aDados[nI][15] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo atual à vencer é igual a zero e foi calculada a média ponderada de títulos à vencer." } )
			EndIF
			
			IF aDados[nI][14] == 0 .And. aDados[nI][16] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo atual à vencer é igual a zero e foi calculada a média de prazo à vencer." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média Ponderada à vencer do Cliente                        |
			//===========================================================================
			IF aDados[nI][15] == 0 .And. aDados[nI][14] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de títulos à vencer é igual a zero e o saldo à vencer é maior que zero." } )
			EndIF
			
			IF aDados[nI][15] == 0 .And. aDados[nI][16] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de títulos à vencer é igual a zero e a média de prazo à vencer é maior que zero." } )
			EndIF
			
			//===========================================================================
			//| Validação do Prazo Médio à vencer do Cliente                            |
			//===========================================================================
			IF aDados[nI][16] == 0 .And. aDados[nI][14] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O prazo médio à vencer é igual a zero e o saldo à vencer é maior que zero." } )
			EndIF
			
			IF aDados[nI][16] == 0 .And. aDados[nI][15] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O prazo médio à vencer é igual a zero e a média ponderada à vencer é maior que zero." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo à vencido (+5) do Cliente                            |
			//===========================================================================
			IF aDados[nI][17] > aDados[nI][10]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo vencido (+5) é maior que o saldo total atual do Cliente." } )
			EndIF
			
			IF aDados[nI][17] == 0 .And. aDados[nI][18] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo vencido (+5) é igual a zero e foi calculada média ponderada de vencidos (+5)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média ponderada vencida (+5) do Cliente                    |
			//===========================================================================
			IF aDados[nI][18] <> 0 .And. aDados[nI][18] < 5
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de vencidos (+5) é menor do que 5." } )
			EndIF
			
			IF aDados[nI][18] == 0 .And. aDados[nI][17] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de vencidos (+5) é igual a zero e existe saldo vencido (+5)." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo à vencido (+15) do Cliente                            |
			//===========================================================================
			IF aDados[nI][19] > aDados[nI][17]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo vencido (+15) é maior que o saldo vencido (+5)." } )
			EndIF
			
			IF aDados[nI][19] == 0 .And. aDados[nI][20] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo vencido (+15) é igual a zero e foi calculada média ponderada vencida (+15)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média ponderada vencida (+15) do Cliente                   |
			//===========================================================================
			IF aDados[nI][20] <> 0 .And. aDados[nI][20] < 15
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de vencidos (+15) é menor do que 15." } )
			EndIF
			
			IF aDados[nI][20] == 0 .And. aDados[nI][19] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de vencidos (+15) é igual a zero e existe saldo vencido (+15)." } )
			EndIF
			
			//===========================================================================
			//| Validação do Saldo à vencido (+30) do Cliente                            |
			//===========================================================================
			IF aDados[nI][21] > aDados[nI][19]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo vencido (+30) é maior que o saldo vencido (+15)." } )
			EndIF
			
			IF aDados[nI][21] == 0 .And. aDados[nI][22] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "O saldo vencido (+30) é igual a zero e foi calculada média ponderada vencida (+30)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Média ponderada vencida (+30) do Cliente                   |
			//===========================================================================
			IF aDados[nI][22] <> 0 .And. aDados[nI][22] < 30
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de vencidos (+30) é menor do que 30." } )
			EndIF
			
			IF aDados[nI][22] == 0 .And. aDados[nI][21] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A média ponderada de vencidos (+30) é igual a zero e existe saldo vencido (+30)." } )
			EndIF
			
			//===========================================================================
			//| Validação da Data da Penúltima Compra do Cliente                        |
			//===========================================================================
			IF aDados[nI][23] == aDados[nI][06]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A data da penúltima compra é igual à data de última compra." } )
			EndIF
			
			IF aDados[nI][23] > aDados[nI][06]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A data da penúltima compra é maior que a data de última compra." } )
			EndIF
			
			IF Empty( aDados[nI][23] ) .And. aDados[nI][24] <> 0
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Não foi registrada a data da penúltima compra e o valor da penúltima compra é maior que zero." } )
			EndIF
			
			IF !Empty( aDados[nI][23] ) .And. aDados[nI][23] < aDados[nI][05]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "A data da penúltima compra é anterior à data de cadastro do Cliente." } )
			EndIF
			
			IF Empty( aDados[nI][23] ) .And. !Empty( aDados[nI][06] ) .And. !Empty( aDados[nI][08] ) .And. aDados[nI][06] <> aDados[nI][08]
				lValid := .T.
				aAdd( aDadosAux , { StrZero(nI,6) , aDados[nI][03] , "Não foi registrada a data da penúltima compra e a data de maior acúmulo é diferente da data de última compra." } )
			EndIF
			
		EndIf
		
	EndIf
	
SZY->(DbSkip())
EndDo

SZY->(DbGotop())

//===========================================================================
//| Verifica se existem inconsistências e exibe informações caso necessário |
//===========================================================================
If lValid
	MsgInfo( "Foram encontradas inconsistências durante a validação! É recomendado executar a atualização da base antes de gerar um novo arquivo para enviar." , "Atenção!" )
	U_ITListBox( "Inconsistências" , { "Linha" , "CNPJ" , "Mensagem" } , aDadosAux )
Else
	MsgInfo( "Todos os registros foram validados com sucesso!" , "Concluído!" )
EndIF

Return()

/*
===============================================================================================================================
Programa----------: MOMS027MSG
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Define a mensagem para envio do e-mail.
===============================================================================================================================
Parametros--------: aDados	- Array com os dados do arquivo para validação
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS027MSG( nOpc )

Local cMsgAux	:= ""

Default nOpc	:= 1

cMsgAux := '<HMTL>'
cMsgAux += '<HEAD>'
cMsgAux += '<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
cMsgAux += '<TITLE>Arquivo CISP</TITLE>'
cMsgAux += '</HEAD>'
cMsgAux += '<BODY><br>'
cMsgAux += '<FONT FACE="Courier New" Style="font-size:12px">'
cMsgAux	+= 'Processamento do envio de Arquivos para a CISP para atualização de bases:<br>'
cMsgAux += '-------------------------------------------------------------------------------------------------------<br>'
cMsgAux += ' Ambiente.........: '+ GetEnvServer() +'<br>'
cMsgAux += ' Data Proc........: '+ DtoC( Date() ) +'<br>'
cMsgAux += ' Hora.............: '+ Time() +'<br>'
cMsgAux += '-------------------------------------------------------------------------------------------------------<br>'

If nOpc == 1
	cMsgAux += 'O arquivo anexo foi gerado com base na última atualização (Verificar a data da base no arquivo).<br><br>'
Else
	cMsgAux += 'O arquivo anexo contém o LOG de erros da validação dos dados da base atualizada.<br><br>'
EndIf

cMsgAux += '=======================================================================================================<br>'
cMsgAux += '<i><b> Atenção: essa é uma mensagem automática, favor não responder. </b></i>                          <br>'
cMsgAux += '=======================================================================================================<br>'
cMsgAux += '</FONT>'
cMsgAux += '</BODY>'
cMsgAux += '</HMTL>'

Return( cMsgAux )

/*
===============================================================================================================================
Programa----------: MOMS027R
Autor-------------: Alexandre Villar
Data da Criacao---: 07/03/2014
===============================================================================================================================
Descrição---------: Monta a mensagem de e-mail com o log de erros de validação.
===============================================================================================================================
Parametros--------: aDados	- Array com os dados do arquivo para validação
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS027R( aValid )

Local nHandle	:= 0
Local nI		:= 0
Local nConta	:= 0

Local _cNArq1	:= AllTrim( GetMV( "IT_CISPDIR" ,, "\data\CISP\" ) ) + "Log_Validacao_"+ DtoS(Date()) +"_"+ StrTran( Time() , ":" , "" ) +".txt"

Local cEmailTo	:= Lower( AllTrim( GetMV( "IT_CISPDEV" ,, "sistema@italac.com.br"		) ) )
Local cEmailCo	:= Lower( AllTrim( GetMV( "IT_CISPCOV" ,, ""							) ) )
Local cEmailBcc	:= Lower( AllTrim( GetMV( "IT_CISPOOV" ,, ""							) ) )

Local cAssunto	:= "Arquivo CISP - Falha de Validação da Base: "+ SubStr( DtoS( dDataRef ) , 7 , 2 ) +"-"+ SubStr( DtoS( dDataRef ) , 5 , 2 ) +"-"+ SubStr( DtoS( dDataRef ) , 1 , 4 )
Local cMensagem	:= MOMS027MSG( 2 )
Local aConfig	:= U_ITCFGEML( AllTrim( GetMV( "IT_CISPCFG" ,, "002" ) ) ) //Configuração de e-mail a ser considerada para o envio (Tabela Z02)
Local cLog		:= ""

Default aValid	:= {}

If !Empty(aValid)
	
	nHandle := FCREATE( _cNArq1 )
	
	If nHandle == -1
	
		Return()
		
	EndIf
	
	For nI := 1 To Len(aValid)
	    
		cLinha := "Cliente: "+ aValid[nI][01] +" - "+ aValid[nI][02] + ENTER
		
		FWRITE( nHandle , cLinha )
		
		nConta++
		
	Next nI
	
	FCLOSE( nHandle )
	
	If nConta > 0
		
		U_ITENVMAIL( aConfig[01] , cEmailTo , cEmailCo , cEmailBcc , cAssunto , cMensagem , _cNArq1 , aConfig[01] , aConfig[02] , aConfig[03] , aConfig[04] , aConfig[05] , aConfig[06] , aConfig[07] , @cLog )
		
	Else
		
		For nI := 0 To 5 // Tentativas de exclusao do arquivo
		
			If FERASE(_cNArq1) <> -1
				lProcOk := .T.
				Exit
			EndIf
			
		SLEEP( 5000 )
		Next nI
		
	EndIF
	
EndIF

Return()

/*
===============================================================================================================================
Programa----------: MOMS027K
Autor-------------: Josué Danich
Data da Criacao---: 10/11/2017
===============================================================================================================================
Descrição---------: Retorna limite de crédito do cliente
===============================================================================================================================
Parametros--------: _ccodigo - código do cliente
					_cloja - loja do cliente
===============================================================================================================================
Retorno-----------: _nlimite - valor de limite de crédito
===============================================================================================================================
*/

User Function MOMS027K( _ccodigo, _cloja  )

Local _nlimite := 0
Local _aareaSA1 := SA1->(Getarea())

//-- Posiciona no Cliente Atual (Cód.+Loja) para recuperar o Código do Risco e a Validade do Limite de Crédito --//
DBSelectArea("SA1")
SA1->( DBSetOrder(1) )
		
If SA1->( DBSeek( xfilial("SA1") + _ccodigo ) ) 

		   dDtLimCr:= SA1->A1_VENCLC			     // Recupera a Data de Validade do Limite de Crédito

		   DO WHILE SA1->(!EOF()) .AND.  _ccodigo == SA1->A1_COD
		      IF SA1->A1_LC > 0 .and. SA1->A1_VENCLC >= date() .and. SA1->A1_MSBLQL != '1'
	
		      	_nlimite += SA1->A1_LC
	
		      ENDIF
		      SA1->(DBSKIP())
		   ENDDO
		   
Endif

SA1->(Restarea(_aareaSA1))

Return _nlimite

/*
===============================================================================================================================
Programa----------: MOMS0278
Autor-------------: Josué Danich
Data da Criacao---: 10/11/2017
===============================================================================================================================
Descrição---------: Retorna saldo do título
===============================================================================================================================
Parametros--------: _atitulos - array com dado do titulo
===============================================================================================================================
Retorno-----------: _aextrato - extrato o titulo
===============================================================================================================================
*/
Static Function MOMS0278(_atitulos)

Local _aextrato := {{_atitulos[11],_atitulos[7], "P"}}
Local cQuery := ""

	
cQuery += " 	SELECT e5_data, e5_valor, e5_recpag "+ENTER
cQuery += " 				FROM "+ RetSqlName("SE5") +" SE5S WHERE "+ENTER
cQuery += " 					SE5S.E5_FILORIG   = '" + _atitulos[3] + "'	AND	SE5S.E5_PREFIXO  = '" +  _atitulos[4] + "' "+ENTER
cQuery += " 				AND	SE5S.E5_FILIAL   = '" + _atitulos[3] + "' " +ENTER
cQuery += " 				AND	SE5S.E5_NUMERO   = '" + _atitulos[5] + "'			AND	SE5S.E5_PARCELA  = '" + _atitulos[6] + "' "+ENTER
cQuery += " 				AND	SE5S.E5_TIPO     = '" + _atitulos[8] + "'			AND	SE5S.E5_CLIFOR   = '" + _atitulos[9] + "' "+ENTER
cQuery += " 				AND	SE5S.E5_LOJA     = '" + _atitulos[10] + "'			AND	SE5S.D_E_L_E_T_  = ' ' "+ENTER
cQuery += " 				AND	SE5S.E5_SITUACA  NOT IN ( 'C' , 'X' )	AND	SE5S.E5_TIPO     NOT IN ( 'NCC' , 'RA', 'NDC' ) "+ENTER
cQuery += " 				AND	SE5S.E5_VALOR    > 0			" +ENTER
cQuery += " 				AND	SE5S.E5_TIPODOC  IN ( 'VL' , 'ES' , 'CP' , 'BA' , 'DC' )  "+ENTER

If Select("SE5T") > 0
	SE5T->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , "SE5T" , .T. , .F. )
	
Do while !SE5T->(Eof())
	
	aadd(_aextrato,{SE5T->E5_DATA,SE5T->E5_VALOR,SE5T->E5_RECPAG})
	SE5T->(Dbskip())
	
Enddo

Return _aextrato

/*
===============================================================================================================================
Programa----------: MOMS0278
Autor-------------: Josué Danich
Data da Criacao---: 10/11/2017
===============================================================================================================================
Descrição---------: Retorna saldo do título
===============================================================================================================================
Parametros--------: _aextrato - array com movimento do titulo
					_cdata - data do saldo
===============================================================================================================================
Retorno-----------: _nsaldi - saldo do título na data
===============================================================================================================================
*/
Static Function MOMS0279(_aextrato,_cdata)

Local _nsaldi := 0   , _nnk

For _nnk := 1 to len(_aextrato)

	If stod(_aextrato[_nnk][1]) <= stod(_cdata)
	
		If _aextrato[_nnk][3] == "R"
		
			_nsaldi := _nsaldi - _aextrato[_nnk][2]
			
		Else
		
			_nsaldi := _nsaldi + _aextrato[_nnk][2]
		
		Endif
		
	Endif

Next

Return _nsaldi
