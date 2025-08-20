/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar função para validação de ambiente de teste
Lucas Borges  |01/08/2025| Chamado 51453. Substituir função EncodeUtf8 por FWHttpEncode
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "Protheus.ch"
#INCLUDE "Colors.ch"
#Include "ApWizard.Ch"

#Define ENTER	Chr(13)+Chr(10)
#Define TITULO	"Planos da Unimed ou ODONTOPREV"

/*
===============================================================================================================================
Programa--------: MGPE008
Autor-----------: Alexandre Villar
Data da Criacao-: 22/04/2014
Descrição-------: Rotina de geração dos arquivos de envio no Layout Unimed
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function MGPE008

Private cPerg		:= "MGPE008"
Private _oSelf		:= nil

SET DATE FORMAT TO "DD/MM/YYYY"

cFilOdontoPrev:=MGPE008ZP1()//Cria (se não existir) o paramentro IT_CDFILOND no ZP1 para cada filail que tem ODONTOPREV

//============================================
//Cria interface principal
//============================================
DO WHILE .T.
   _lLoop:=.F.
   tNewProcess():New(cPerg											,; // Função inicial
					"Geração de Arquivo Texto - Planos da Unimed ou ODONTOPREV"				,; // Descrição da Rotina
					{|_oSelf| MGPE008INI(_oSelf) }					,; // Função do processamento
					"Este programa gera o arquivo texto no Layout Unimed ou ODONTOPREV, conforme parâmetros definidos pelo usuário." ,; // Descrição da Funcionalidade
					cPerg											,; // Configuração dos Parâmetros
					{}												,; // Opções adicionais para o painel lateral
					.F.												,; // Define criação do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descrição do Painel Auxiliar
					.F.												,; // Se .T. exibe o painel de execução. Se falso, apenas executa a função sem exibir a régua de processamento.
                    .T.                                              ) // Se .T. cria apenas uma regua de processamento.
   IF !_lLoop
      EXIT
   ENDIF
ENDDO
                    
Return()

/*
===============================================================================================================================
Programa--------: MGPE008INI
Autor-----------: Alexandre Villar
Data da Criacao-: 10/02/2014
Descrição-------: Rotina de controle da geração dos arquivos de envio no layout Unimed ou ODONTOPREV
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MGPE008INI(_oSelf)

//===============================================================================================
// Tenta criar o arquivo conforme parametrização
//===============================================================================================
Local cNome		:= GetMv( "IT_ARQUNIM" ,, "ARQ_UNIMED" ) +"_"+ DtoS( Date() ) +"_"+ StrTran( TIME() , ":" , "" )
Local cArqTxt	:= AllTrim( MV_PAR17 ) + cNome + ".csv"
Local cNumLote	:= cArqTxtMem := ""
Local nRegPro	:= 0
_lLoop:=.T.

PRIVATE _dHojeSys:=DATE()
PRIVATE  nDiasAd := GetMv( "IT_DIASPLA" ,, 88 )//UNIMED

IF SuperGetMV("IT_AMBTEST",.F.,.T.) .AND. !EMPTY(MV_PAR09)
   _dHojeSys:=MV_PAR09
   dDataBase:=MV_PAR09
ENDIF
_lOK:=.T.
cFilOdontoPrev:="Todas"
If MV_PAR12  = 2 //2-ODONTO
   nDiasAd :=0
   cFilOdontoPrev:=MGPE008ZP1()//Cria (se não existir) o paramentro IT_CDFILOND no ZP1 para cada filail que tem ODONTOPREV
   nHdl:= 0
ELSE
   nHdl:= FCreate( cArqTxt )
   If nHdl = -1
   	  //MsgStop("O arquivo: "+ cArqTxt +" nao pode ser criado! Verifique os parâmetros.","MGPE00801")
   	  U_ITMSG("O arquivo: "+ cArqTxt +" nao pode ser criado!",'Atenção!',"Verifique os parâmetros.",1)
	  _lOK:=.F.
   ELSE
      cArqTxtMem:= STRTRAN( cArqTxt, "\", "\ ")
   ENDIF
ENDIF
//Validacao tem que ser depois do IF de cima por causa da variavel cFilOdontoPrev
IF !(U_MGPE008P(1) .AND. U_MGPE008P(2) .AND. U_MGPE008P(3) .AND. U_MGPE008P(4) .AND. U_MGPE008P(5) .AND. U_MGPE008P(6))
   RETURN .T.
ENDIF

If _lOK
	//===============================================================================================
	// Inicia o Lote de Processamento
	//===============================================================================================
	cNumLote := U_ITInLote( "Z04" , "001" ) // 001 - Processamento de Envio
	
	//===============================================================================================
	// Executa rotina de processamento do arquivo
	//===============================================================================================
	Processa( {|| MGPE008GER( nHdl , cNumLote , @nRegPro ) } , "Geração do Arquivo" , "Lendo registros..." )
	
	IF !EMPTY(cArqTxtMem)
	   FClose( nHdl )
	   IF nRegPro > 0
           U_ITMSG("Arquivo gerado com sucesso:"+ ENTER + cArqTxtMem,'SUCESSO!',,2)
	   Else
           U_ITMSG("Não foram encontrados registros para gerar o arquivo.",'Atenção!',"O arquivo será excluído: "+cArqTxtMem,,3)
	   	   FErase( cArqTxt )
	   EndIF
	ELSE
	   IF nRegPro > 0
           U_ITMSG("Dados gerado com sucesso.",'SUCESSO!',,2)
	   Else
           U_ITMSG("Não foram encontrados dados para os filtros selecionados.",'Atenção!',"Verifique os filtros e tente novamente",,3)
	   EndIF
	EndIF
	
	//===============================================================================================
	// Fecha o Lote de Processamento
	//===============================================================================================
	//LjMsgRun( "Gravando dados do lote..." , "Aguarde!" , {|| U_ITFnLote( "Z04" , cNumLote ) } )
	U_ITFnLote( "Z04" , cNumLote ) 
	
	//===============================================================================================
	// Verifica o Lote
	//===============================================================================================
	//LjMsgRun( "Verificando dados do lote..." , "Aguarde!" , {|| U_ITVlLote( "Z06" , cNumLote ) } )
	 U_ITVlLote( "Z06" , cNumLote ) 

EndIf

Return .T.

/*
===============================================================================================================================
Programa--------: MGPE008GER
Autor-----------: Erich Buttner
Data da Criacao-: 10/02/2010
Descrição-------: Rotina de geração dos arquivos de envio no layout Unimed ou ODONTOPREV
Parametros------: nHdl , cNumLote , nRegPro
Retorno---------: nRegPro
===============================================================================================================================
*/
Static Function MGPE008GER( nHdl , cNumLote , nRegPro )

Local nTamLin	:= 0
Local nI		:= 0
Local nTotReg	:= 0
Local nCtAux	:= 0
Local cDelim	:= ";"
Local cLin		:= ""
Local cCpo		:= ""
Local cSitFol	:= ""
Local cCatFun	:= ""
Local aLogDup	:= {}
Local aLogPro	:= {}
Local _cCodPla2 := GetMv("IT_CODPLA2")
Local _cCodPla	:= GetMv("IT_CODPLA")
Local cEstCi	:= ""
Local cCodDep	:= ""
Local cCodExc	:= ""
Local lRet		:= .T.
Local cMesRef	:= ""
Local nDiaFinal	:= 0
Local nContad	:= 0
Local dDiaRef	:= StoD("")

PRIVATE cTipOpe	:= ""
PRIVATE _cAlias	:= GetNextAlias()
PRIVATE aDadosOdonto:= {}
PRIVATE aXlsxOdonto:= {}

nRegPro := 0

//===============================================================================================
// Verifica o parâmetro de Situações na Folha
//===============================================================================================
If Empty( MV_PAR03 )
	cSitFol := " ;"
Else
	For nI := 1 To LEN( MV_PAR03 )
		If SubStr( MV_PAR03 , nI , 1 ) <> "*"
			cSitFol += SubStr( MV_PAR03 , nI , 1 ) + ";"
		EndIf
	Next nI
	cSitFol := SubStr( cSitFol , 1 , LEN(cSitFol) - 1 )
EndIf

//===============================================================================================
// Verifica o parâmetro de Categorias Funcionais
//===============================================================================================
If !Empty( MV_PAR02 )
	For nI := 1 To LEN( MV_PAR02 )
		If SubStr( MV_PAR02 , nI , 1 ) <> "*"
			cCatFun += SubStr( MV_PAR02 , nI , 1 ) + ";"
		EndIf
	Next nI
	cCatFun := SubStr( cCatFun , 1 , LEN(cCatFun) - 1 )
EndIf

//===============================================================================================
// Verifica a data de corte do mês atual informada nos parâmetros
//===============================================================================================
If Day(_dHojeSys) <= MV_PAR16
	dDiaRef := MonthSum( _dHojeSys , 01 )
Else
	dDiaRef := MonthSum( _dHojeSys , 02 )
EndIf

nDiaFinal	:= LastDay( dDiaRef )
cMesRef		:= StrZero( Month(dDiaRef) , 2 ) + StrZero( Year( dDiaRef ) , 4 )

//===============================================================================================
// Verifica a Inclusão de funcionários no Plano de Saúde - Envio-1
//===============================================================================================
If MV_PAR08 <> 2 // 1 = Inclusão , 2 = Exclusão , 3 = Alteração , 4 = Todos

	cBenef := " SELECT "
	cBenef += "     Z05.Z05_ACAO   ,"
	cBenef += "     Z05.Z05_STATUS ,"
	cBenef += "     RHK.RHK_PERINI ,"
	cBenef += "     RHK.RHK_PLANO  ,"
	cBenef += "     SRA.RA_FILIAL  ,"
	cBenef += "     SRA.RA_MAT     ,"
	cBenef += "     SRA.RA_NOMECMP ,"
	cBenef += "     SRA.RA_SEXO    ,"
	cBenef += "     SRA.RA_NASC    ,"
	cBenef += "     SRA.RA_CIC     ,"
	cBenef += "     SRA.RA_PIS     ,"
	cBenef += "     SRA.RA_ADMISSA ,"
	cBenef += "     SRA.RA_RG      ,"
	cBenef += "     SRA.RA_RGORG   ,"
	cBenef += "     SRA.RA_MAE     ,"
	cBenef += "     SRA.RA_ESTCIVI ,"
	cBenef += "     SRA.RA_TELEFON ," 
	cBenef += "     SRA.RA_DDDFONE ,"
	cBenef += "     SRA.RA_ENDEREC ,"
	cBenef += "     SRA.RA_NUMENDE ,"
	cBenef += "     SRA.RA_COMPLEM ,"
	cBenef += "     SRA.RA_BAIRRO  ,"
	cBenef += "     SRA.RA_MUNICIP ,"
	cBenef += "     SRA.RA_ESTADO  ,"
	cBenef += "     SRA.RA_CEP     ,"
	cBenef += "     SRA.RA_CC      ,"
	cBenef += "     SRA.RA_DDDCELU ,"
	cBenef += "     SRA.RA_NUMCELU  "
	cBenef += " FROM "+ RetSqlName("SRA")+" SRA "
	
	cBenef += " INNER JOIN "+ RetSqlName("RHK") +" RHK ON "
	cBenef += " 	SRA.RA_FILIAL	= RHK.RHK_FILIAL "
	cBenef += " AND	SRA.RA_MAT		= RHK.RHK_MAT "
	
	cBenef += " LEFT JOIN "+ RetSqlName("Z05") +" Z05 ON "
	cBenef += " 	Z05.Z05_FILMAT	= SRA.RA_FILIAL "
	cBenef += " AND	Z05.Z05_MATRIC	= SRA.RA_MAT "
	cBenef += " AND Z05.Z05_SEQ		= '00' "
	cBenef += " AND Z05.D_E_L_E_T_	= ' ' "
	
	cBenef += " WHERE "
	cBenef += " 	SRA.D_E_L_E_T_	= ' ' "
	cBenef += " AND RHK.D_E_L_E_T_	= ' ' "
	
	If !Empty(AllTrim(MV_PAR01))
	   cBenef += " AND SRA.RA_FILIAL IN "+FormatIn( AllTrim( MV_PAR01 ) , ";" )
	EndIf
	
	cBenef += " AND SRA.RA_CC		BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
	cBenef += " AND SRA.RA_MAT		BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' "
	cBenef += " AND SRA.RA_SITFOLH	<> 'D' "
	cBenef += " AND SRA.RA_SITFOLH	IN "+FormatIn( cSitFol , ";" )
	
	IF !Empty(cCatFun)
	   cBenef += " AND SRA.RA_CATFUNC IN "+FormatIn( cCatFun , ";" )
	EndIF
	
	cBenef += " AND RHK.RHK_TPFORN	= '"+ CVALTOCHAR(MV_PAR12) +"' "//1-UNIMED 2-ODONTOPREV
	cBenef += " AND RHK.RHK_CODFOR	= '"+ CVALTOCHAR(MV_PAR13) +"' "
	cBenef += " AND RHK.RHK_PLANO	= '"+ CVALTOCHAR(MV_PAR15) +"' "	
	
	cBenef += " ORDER BY Z05_ACAO, Z05_STATUS "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	Endif
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cBenef) , _cAlias , .T. , .F. )
	
	nTotReg	:= 0
	nCtAux	:= 0
	
	DBSelectArea(_cAlias)
	
	(_cAlias)->( DBGoTop() )
	(_cAlias)->( DBEval( {|| nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua( nTotReg )
	
	While (_cAlias)->( !Eof() )
	
		nCtAux++
		IncProc( "Lendo registos... ["+ StrZero( nCtAux , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
		lRet := .T.
		
		//===============================================================================================
		// Verifica os critérios para Inclusões
		//===============================================================================================
		IF MV_PAR08 == 1 .Or. ( (_cAlias)->Z05_ACAO == "E" .And. (_cAlias)->Z05_STATUS $ "PA" )
			
			//===============================================================================================
			// Verifica o período de inclusão no cadstro dos funcionários
			//===============================================================================================
			IF (_cAlias)->RHK_PERINI <> cMesRef
				
				AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
									(_cAlias)->RA_MAT	 	,;
									"00" 				,;
									"Funcionário" 		,;
									(_cAlias)->RA_NOMECMP	,;
									"Período inicial do cadastro ["+ SubStr((_cAlias)->RHK_PERINI,1,2)+"/"+ SubStr((_cAlias)->RHK_PERINI,3,4) +"] é diferente do atual ["+ SubStr(cMesRef,1,2) +"/"+ SubStr(cMesRef,3,4) +"]." } )
				
				(_cAlias)->( DBSkip() )
				Loop
				
			EndIF
			
			cTipOpe := "1"
			_cAcao	:= "I"
		
		Else
			
			cTipOpe := "2"
			_cAcao	:= "A"
			
		EndIF
		
		//===============================================================================================
		// Valida período de carência dos funcionários para inclusão no Plano
		//===============================================================================================
	    IF ( dDataBase - STOD((_cAlias)->RA_ADMISSA) ) < nDiasAd
	    	AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
								(_cAlias)->RA_MAT	 	,;
								"00" 				,;
								"Funcionário" 		,;
								(_cAlias)->RA_NOMECMP	,;
								"A Carência do Funcionário ["+ StrZero( nDiasAd , 3 ) +" dias] ainda não foi superada ["+ StrZero( dDataBase - STOD( (_cAlias)->RA_ADMISSA ) , 3 ) +" dias de contrato] [ Admissão: "+DTOC(STOD( (_cAlias)->RA_ADMISSA ))+" ]." } )
			(_cAlias)->( DBSkip() )
			Loop
	    	
	    Else
			
			//===============================================================================================
			// Valida o preenchimento do nome da mãe do Titular
			//===============================================================================================
			If Empty(AllTrim((_cAlias)->RA_MAE)) 
				
				//===============================================================================================
				// Grava o Item processado no Lote
				//===============================================================================================
				U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , '' , _cAcao , "T" , "É obrigatório informar o nome da mãe do funcionário titular." } } , "0" )
				
				lRet := .F.
				
				AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
									(_cAlias)->RA_MAT	 	,;
									"00" 				,;
									"Funcionário" 		,;
									(_cAlias)->RA_NOMECMP	,;
									"É obrigatório informar o nome da mãe do funcionário titular." } )
			
			EndIF
			
			If lRet
			
				//===============================================================================================
				// De/Para do estado civil para envio no arquivo
				//===============================================================================================
	   			Do Case
					Case (_cAlias)->RA_ESTCIVI == 'C'
						cEstCi:= 'C'
					Case (_cAlias)->RA_ESTCIVI == 'D'
						cEstCi:= 'I'
					Case (_cAlias)->RA_ESTCIVI == 'M'
						cEstCi:= 'U'
					Case (_cAlias)->RA_ESTCIVI == 'Q'
						cEstCi:= 'D'
					Case (_cAlias)->RA_ESTCIVI == 'S'
						cEstCi:= 'S'
					Case (_cAlias)->RA_ESTCIVI == 'V'
						cEstCi:= 'V'
				EndCase
				
			EndIf
		
		EndIF
		
		If lRet
		
			//===============================================================================================
			// Prepara as informações necessárias
			//===============================================================================================
		IF MV_PAR12 = 1 //1-UNIMED
			nTamLin	:= 2
			cLin	:= Space(nTamLin) + ENTER //Variavel para criacao da linha do registros para gravacao
			cTel	:= StrTran( SubStr( (_cAlias)->RA_TELEFON , 1 , LEN( (_cAlias)->RA_TELEFON ) - 2 ) , "-" , "" )
			cDDD	:= SubStr( (_cAlias)->RA_DDDFONE , 1 , 2 )
			cCodUni	:= AllTrim( GetAdvFVal( "SX6" , "X6_CONTEUD" , (_cAlias)->RA_FILIAL + "IT_CODUNI" , 1 , "" ) )		
			_cDtAux	:= IIF( MV_PAR08 == 1 , DtoC(MV_PAR09) , DtoC( StoD( SubStr( (_cAlias)->RHK_PERINI , 3 , 4 ) + SubStr( (_cAlias)->RHK_PERINI , 1 , 2 ) + '01' ) ) )
			
			If (_cAlias)->RHK_PLANO == "98"
				_cplano := _cCodPla2
			Else
				_cplano := _cCodPla
			Endif
			
			//===============================================================================================
			//Monta a estrutura da linha do arquivo
            //Enviar: A Inclusão de funcionários no Plano de Saúde - Envio-1
			//===============================================================================================
			cCpo	:=	"1"										 									+ cDelim //COD_TIPO_REGISTRO
			cCpo	+=	cCodUni																		+ cDelim //COD_EMPRESA
			cCpo	+=	cTipOpe																		+ cDelim //COD_TIPO_OPERACAO
			cCpo	+=	""																			+ cDelim //COD_FAMILIA
			cCpo	+=	"00"									 									+ cDelim //COD_DEPENDENCIA
			cCpo	+=	MGPE008TPD( AllTrim((_cAlias)->RA_NOMECMP) , 120 )							+ cDelim //NOME_ASSOCIADO
			cCpo	+=	(_cAlias)->RA_SEXO							 								+ cDelim //IND_SEXO
			cCpo	+=	cEstCi																		+ cDelim //IND_ESTADO_CIVIL
			cCpo	+=	IIf( !Empty((_cAlias)->RA_NASC) , DtoC( StoD( (_cAlias)->RA_NASC ) ) , "" )	+ cDelim //DATA_NASCIMENTO
			cCpo	+=	_cplano						  												+ cDelim //COD_PLANO
			cCpo	+=	""																			+ cDelim //COD_UNIMED_LCAT
			cCpo	+=	""																			+ cDelim //COD_LOTACAO
			cCpo	+=	""																			+ cDelim //NOME_LOTACAO
			cCpo	+=	_cDtAux																		+ cDelim //DATA_INCLUSAO
			cCpo	+=	""																			+ cDelim //DATA_EXCLUSAO
			cCpo	+=	""																			+ cDelim //DATA_TROCA_PLANO
			cCpo	+=	""																			+ cDelim //DATA_REATIVACAO
			cCpo	+=	_cDtAux																		+ cDelim //DT_LOTACAO
			cCpo	+=	If( !Empty((_cAlias)->RA_ADMISSA) , DtoC( StoD( (_cAlias)->RA_ADMISSA)),"" )+ cDelim //DATA_ADMISSAO
			cCpo	+=	""																			+ cDelim //DATA_CASAMENTO
			cCpo	+=	(_cAlias)->RA_FILIAL+(_cAlias)->RA_MAT										+ cDelim //NUM_MATRIC_EMPRESA
			cCpo	+=	"00"																		+ cDelim //NUM_SEQ_MATRIC_EMPRESA
			cCpo	+=	AllTrim( (_cAlias)->RA_CIC )												+ cDelim //NUM_CPF
			cCpo	+=	""																			+ cDelim //DT_INI_CONTRIB
			cCpo	+=	AllTrim( (_cAlias)->RA_PIS )												+ cDelim //NUM_PIS
			cCpo	+=	AllTrim( (_cAlias)->RA_MAE )												+ cDelim //NOME_MAE 
			cCpo	+=	""																			+ cDelim //COD_BANCO_DCC
			cCpo	+=	""																			+ cDelim //COD_AGENCIA_DCC
			cCpo	+=	""																			+ cDelim //NUM_DV_AGENCIA_DCC
			cCpo	+=	""																			+ cDelim //NUM_CONTA_CORRENTE_DCC
			cCpo	+=	""																			+ cDelim //NUM_DV_CC_DCC
			cCpo	+=	""																			+ cDelim //COD_MOTIVO_EXCLUSAO
			cCpo	+=	""																			+ cDelim //COD_PAIS_NASCIMENTO
			cCpo	+=	""																			+ cDelim //NUM_UNICO_SAUDE 
			cCpo	+=	StrTran( AllTrim( MGPE008END( (_cAlias)->RA_ENDEREC ) ) , ';' , '' )		+ cDelim //NOM_LOGRADOURO
			cCpo	+=	StrTran( AllTrim( (_cAlias)->RA_NUMENDE ) , ';' , '' )						+ cDelim //NUM_ENDERECO
			cCpo	+=	StrTran( AllTrim( (_cAlias)->RA_COMPLEM ) , ';' , '' )						+ cDelim //TXT_COMPLEMENTO
			cCpo	+=	AllTrim( MGPE008TPD( (_cAlias)->RA_BAIRRO , 72 ) )							+ cDelim //NOME_BAIRRO
			cCpo	+=	""																			+ cDelim //COD_MUNICIPIO
			cCpo	+=	(_cAlias)->RA_CEP															+ cDelim //NUM_CEP
			cCpo	+=	""																			+ cDelim //REGIAO
			cCpo	+=	AllTrim(cTel)																+ cDelim //NUM_TELEFONE_1
			cCpo	+=	""																			+ cDelim //RAMAL
			cCpo	+=	""																			+ cDelim //END_EMAIL_1
			cCpo	+=	""																			+ cDelim //SETOR
			cCpo	+=	""																			+ cDelim //IND_SITUACAO_EMPRESA
			cCpo	+=	""																			+ cDelim //CATEGORIA
			cCpo	+=	""																			+ cDelim //COD_FUNCAO
			cCpo	+=	StrTran( StrTran( AllTrim((_cAlias)->RA_RG) , "." , "" ) , "-" , "" )		+ cDelim //NUM_IDENTIDADE
			cCpo	+=	AllTrim((_cAlias)->RA_RGORG)												+ cDelim //COD_ORGAO_EMISSOR
			cCpo	+=	"032"																		+ cDelim //COD_PAIS_EMISSOR
			cCpo	+=	""																			+ cDelim //IND_TIPO_CARENCIA
			cCpo	+=	""																			+ cDelim //IND_MOVIMENTA_AT
			cCpo	+=	""																			+ cDelim //IND_MOVIMENTA_SO
			cCpo	+=	"U"																			+ cDelim //IND_LAYOUT_ORIGEM
			cCpo	+=	""																			+ cDelim //IND_CARTAO_RESID
			cCpo	+=	""																			+ cDelim //IND_EXTRATO_RESID
			cCpo	+=	(_cAlias)->RA_CC															+ cDelim //COD CENTRO DE CUSTO
			cCpo	+=	""																			+ cDelim //NOME CENTRO DE CUSTO
			cCpo	+=	""																			+ cDelim //COD_EMPRESA_SIAMED
			cCpo	+=	""																			+ cDelim //IND_EMPRESA_EMBUTIDA
			cCpo	+=	"N"																			+ cDelim //SEQUENCIAL_DEP_INFORMADA
			cCpo	+=	""																			+ cDelim //IND_EXTERIOR_1
			cCpo	+=	""																			+ cDelim //COD_PAIS_1
			cCpo	+=	""																			+ cDelim //COND_DEP
			cCpo	+=	""																			+ cDelim //NUM_DN
			cCpo	+=	""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+=	""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+=	""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+=	""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+=	cDDD																		+ cDelim //NUM_DDD_TELEFONE_1
			cCpo	+=	AllTrim((_cAlias)->RA_DDDCELU)												+ cDelim //DDD_CELULAR_1 
			cCpo	+=	StrTran( StrTran( AllTrim((_cAlias)->RA_NUMCELU) , "-" , "" ) , "." , "" )	+ cDelim + ENTER //NUM_CELULAR_1
	
			cLin := Stuff( cLin , 01 , LEN(cCPO) , cCpo )

		ENDIF

	 		//===============================================================================================
			// Gravação da Linha atual no arquivo
			//===============================================================================================
			_lGravouLinha:= (MV_PAR12 = 2 .AND. MGPE8Odonto("T","I",cNumLote))
			If _lGravouLinha .OR. (MV_PAR12 = 1 .AND. FWrite( nHdl , cLin , LEN(cLin) ) == LEN(cLin))
	  			
				//===============================================================================================
				// Grava o Item processado no Lote
				//===============================================================================================
				IF cTipOpe == "1"
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "I" , "F" , "Inclusão de titular gravada com sucesso!"	} } , "1" )
				Else
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "A" , "F" , "Alteração de titular gravada com sucesso!"	} } , "1" )
				EndIF
				
				nRegPro++
				
	  		ELSEIF MV_PAR12 = 1//Para o MV_PAR12 = 2 gravo dentro da função MGPE8Odonto ("T","I",cNumLote)
	  		
				//===============================================================================================
				// Grava o Item processado no Lote
				//===============================================================================================
				IF cTipOpe == "1"
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "I" , "F" , "Falha de gravação da linha no arquivo."	} } , "0" )
				Else
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "A" , "F" , "Falha de gravação da linha no arquivo."	} } , "0" )
				EndIF
				
				AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
										(_cAlias)->RA_MAT	 	,;
										"00" 				,;
										"Funcionário" 		,;
										(_cAlias)->RA_NOMECMP	,;
										"Falhou a gravação da Linha do Arquivo." } )
				
	 		EndIf
	 	
	 	EndIf
	
	(_cAlias)->( DBSkip() )
	
	EndDo
	
	(_cAlias)->( DBCloseArea() )
	
//===============================================================================================
// Verifica a Inclusão de dependentes - Envio-2
//===============================================================================================
	cDepen := " SELECT "
	cDepen += "     Z05.Z05_ACAO   ,"
	cDepen += "     Z05.Z05_STATUS ,"
	cDepen += "     SRA.RA_FILIAL  ,"
	cDepen += "     SRA.RA_MAT     ,"
	cDepen += "     SRA.RA_NOMECMP,"
	cDepen += "     SRA.RA_NASC   ,"          
	cDepen += "     SRA.RA_ENDEREC,"            
	cDepen += "     SRA.RA_NUMENDE,"            
	cDepen += "     SRA.RA_BAIRRO ,"           
	cDepen += "     SRA.RA_COMPLEM,"            
	cDepen += "     SRA.RA_CEP    ,"           
	cDepen += "     SRA.RA_ESTADO ,"           
	cDepen += "     SRA.RA_MUNICIP,"            
	cDepen += "     SRA.RA_CIC    ,"        
	cDepen += "     SRA.RA_ADMISSA ,"
	cDepen += "     SRA.RA_MAE     ,"
	cDepen += "     SRA.RA_RG      ,"
	cDepen += "     SRA.RA_RGORG   ,"
	cDepen += "     SRA.RA_ESTCIVI ,"
	cDepen += "     SRA.RA_SEXO    ,"
	cDepen += "     SRA.RA_CC      ,"
	cDepen += "     RHL.RHL_PERINI ,"
	cDepen += "     RHK.RHK_PLANO  ,"
	cDepen += "     SRB.RB_COD     ,"
	cDepen += "     SRB.RB_NOME    ,"
	cDepen += "     SRB.RB_GRAUPAR ,"
	cDepen += "     SRB.RB_CIC     ,"
	cDepen += "     SRB.RB_DTNASC  ,"
	cDepen += "     SRB.RB_DTBAIXA ,"
	cDepen += "     SRB.RB_SEXO    ,"
	cDepen += "     SRB.RB_I_MAE   ,"
	cDepen += "     SRB.RB_I_DTCA   "
	cDepen += " FROM "+ RetSqlName("SRB") +" SRB "
	
	cDepen += " INNER JOIN "+ RetSqlName("RHL") +" RHL ON "
	cDepen += "     RHL.RHL_FILIAL		= SRB.RB_FILIAL "
	cDepen += " AND	RHL.RHL_MAT			= SRB.RB_MAT "
	cDepen += " AND RHL.RHL_CODIGO		= SRB.RB_COD "
	cDepen += " AND	(	RHL.RHL_PERFIM 	= ' ' "
	cDepen += " 	OR	RHL.RHL_PERFIM  >= '"+ cMesRef +"' ) "
	cDepen += " AND RHL.D_E_L_E_T_		= ' ' "
	
	cDepen += " INNER JOIN "+ RetSqlName("RHK") +" RHK ON "
	cDepen += "     RHK.RHK_FILIAL = RHL.RHL_FILIAL "
	cDepen += " AND RHK.RHK_MAT	   = RHL.RHL_MAT "
	cDepen += " AND RHK.RHK_PLANO  = RHL.RHL_PLANO "
	cDepen += " AND RHK.RHK_TPFORN = RHL.RHL_TPFORN "
	cDepen += " AND RHK.RHK_CODFOR = RHL.RHL_CODFOR "
	cDepen += " AND	(  RHK.RHK_PERFIM  = ' ' "
	cDepen += " 	OR RHK.RHK_PERFIM >= '"+ cMesRef +"' ) "
	cDepen += " AND RHK.D_E_L_E_T_		= ' ' "
	
	cDepen += " INNER JOIN "+ RetSqlName("SRA") +" SRA ON "
	cDepen += "     SRA.RA_FILIAL		= SRB.RB_FILIAL "
	cDepen += " AND SRA.RA_MAT			= SRB.RB_MAT "
	cDepen += " AND SRA.D_E_L_E_T_		= ' ' "
	
	cDepen += " LEFT JOIN "+ RetSqlName("Z05") +" Z05 ON "
	cDepen += "     Z05.Z05_FILMAT		= SRB.RB_FILIAL "
	cDepen += " AND	Z05.Z05_MATRIC		= SRB.RB_MAT "
	cDepen += " AND Z05.Z05_SEQ			= SRB.RB_COD "
	cDepen += " AND Z05.D_E_L_E_T_		= ' ' "
	
	cDepen += " WHERE "
	cDepen += "     SRB.D_E_L_E_T_		= ' ' "
	
	If !Empty( AllTrim(MV_PAR01) )
	cDepen += " AND SRA.RA_FILIAL		IN "+ FormatIn( AllTrim( MV_PAR01 ) , ";" )
	EndIf
	
	cDepen += " AND SRA.RA_CC			BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
	cDepen += " AND SRA.RA_MAT			BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' "
	cDepen += " AND SRA.RA_SITFOLH		<> 'D' "
	cDepen += " AND SRA.RA_SITFOLH		IN "+FormatIn( cSitFol , ";" )
	
	IF !Empty(cCatFun)
	cDepen += " AND SRA.RA_CATFUNC		IN "+FormatIn( cCatFun , ";" )
	EndIF
	
	cDepen += " AND RHL.RHL_TPFORN		= '"+ CVALTOCHAR(MV_PAR12) +"' "//1-UNIMED 2-ODONTOPREV
	cDepen += " AND RHL.RHL_CODFOR		= '"+ CVALTOCHAR(MV_PAR13) +"' "
	cDepen += " AND RHL.RHL_PLANO		= '"+ CVALTOCHAR(MV_PAR15) +"' "
	
	cDepen += " ORDER BY Z05_ACAO, Z05_STATUS "
	
	If Select(_cAlias) > 0
		(_cAlias)->( dbCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cDepen) , _cAlias , .T. , .F. )
	
	nTotReg	:= 0
	nCtAux	:= 0
	
	DBSelectArea(_cAlias)
	
	(_cAlias)->( DBGoTop() )
	(_cAlias)->( DBEval( {|| nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua( nTotReg )
	
	While (_cAlias)->( !EoF() )
	
		nCtAux++
		lRet := .T.
		IncProc( "Lendo registos... ["+ StrZero( nCtAux , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
		
		//===============================================================================================
		// Verifica os critérios para Inclusões
		//===============================================================================================
		IF MV_PAR08 == 1 .Or. ( (_cAlias)->Z05_ACAO == "E" .And. (_cAlias)->Z05_STATUS $ "PA" )
		
			//===============================================================================================
			// Verifica o período de inclusão no cadstro dos dependentes
			//===============================================================================================
			IF (_cAlias)->RHL_PERINI <> cMesRef
				
				AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
									(_cAlias)->RA_MAT 		,;
									(_cAlias)->RB_COD		,;
									"Dependente" 		,;
									(_cAlias)->RB_NOME		,;
									"Período inicial do cadastro: ["+ SubStr((_cAlias)->RHL_PERINI,1,2)+"/"+ SubStr((_cAlias)->RHL_PERINI,3,4) +"] é diferente do atual: ["+ SubStr(cMesRef,1,2) +"/"+ SubStr(cMesRef,3,4) +"]." } )
				
				(_cAlias)->( DBSkip() )
				Loop
				
			EndIF
			
			cTipOpe := "1"
			_cAcao	:= "I"
			
		Else
		
			cTipOpe := "2"
			_cAcao	:= "A"
			
		EndIf
		
		//===============================================================================================
		// Validação da data de Período Inicial do Funcionário Titular
		//===============================================================================================
		If ( dDataBase - STOD((_cAlias)->RA_ADMISSA) ) < nDiasAd
			
			//===============================================================================================
			// Grava o Item processado no Lote
			//===============================================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "Funcionário titular "+ALLTRIM((_cAlias)->RA_NOMECMP)+" em período de carência para adesão ao Plano de Saúde." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
								(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Funcionário titular "+ALLTRIM((_cAlias)->RA_NOMECMP)+" em período de carência para adesão ao Plano de Saúde." } )
			
		EndIF
		
		//===============================================================================================
		// Valida o preenchimento do nome da mãe do Titular
		//===============================================================================================
		If Empty(AllTrim((_cAlias)->RA_MAE)) 
			
			//===============================================================================================
			// Grava o Item processado no Lote
			//===============================================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "É obrigatório informar o nome da mãe do funcionário titular." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
								(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"É obrigatório informar o nome da mãe do funcionário titular." } )
		
		EndIF
		
		//===============================================================================================
		// Valida grau de parentesco do dependente com o estado civil do titular
		//===============================================================================================
		//SÓ 1-UNIMED
		If MV_PAR12  = 1 .AND. ((_cAlias)->RA_ESTCIVI $ 'D/Q/V' .And. (_cAlias)->RB_GRAUPAR == 'C')//SÓ 1-UNIMED
			
			//===============================================================================================
			// Grava o Item processado no Lote
			//===============================================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "Parentesco do dependente não é compativel com o estado civil do funcionario titular." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
								(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Parentesco do dependente não é compativel com o estado civil do funcionario titular." } )
		
		EndIF
		
		//===============================================================================================
		// Valida grau de parentesco do dependente
		//===============================================================================================
		//SÓ 1-UNIMED
		If MV_PAR12  = 1 .AND. (_cAlias)->RB_GRAUPAR $ "E/P/O"//SÓ 1-UNIMED
			
			//===========================================================================
			//| Grava o Item processado no Lote                                         |
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "Parentesco do dependente não é compativel com o Plano de Saúde." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   				(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Parentesco do dependente não é compativel com o Plano de Saúde." } )
		
		EndIF
		
		//===========================================================================
		//| Valida o preenchimento do campo CPF do dependente maior de 18 anos      |
		//===========================================================================
 			If Empty(AllTrim((_cAlias)->RB_CIC)) //.And. ( ( _dHojeSys - StoD((_cAlias)->RB_DTNASC) ) / 365 ) > 18
			
			//===========================================================================
			//| Grava o Item processado no Lote                                         |
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "É obrigatório informar o CPF do dependente maior de 18 anos." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   				(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"É obrigatório informar o CPF do dependente." } )
		
		EndIF
 			
		//===========================================================================
		//Valida a data de baixa do denpendente
		//===========================================================================
		IF !Empty( (_cAlias)->RB_DTBAIXA ) .And. STOD( (_cAlias)->RB_DTBAIXA ) < _dHojeSys
			
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "Data de Baixa não permite a inclusão do dependente." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   				(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Data de Baixa não permite a inclusão do dependente." } )
		
		EndIf
		
		//===========================================================================
		//Valida preenchimento do nome da mãe do Dependente
		//===========================================================================
		If Empty(AllTrim((_cAlias)->RB_I_MAE)) .And. (_cAlias)->RA_SEXO + (_cAlias)->RB_GRAUPAR <> 'FF'
			
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "É obrigatório informar o nome da mãe do dependente." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   				(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"É obrigatório informar o nome da mãe do dependente." } )
		
		EndIf
		
		//===========================================================================
		//Valida Grau de Parentesco do Dependente x Estado Civil do Titular
		//===========================================================================
		//SÓ 1-UNIMED
		If MV_PAR12  = 1 .AND. (_cAlias)->RA_ESTCIVI + (_cAlias)->RB_GRAUPAR == 'SC'//SÓ 1-UNIMED
			
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "Dependente cadastrado como 'conjuge' e funcionário titular cadastrado como 'solteiro'." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   				(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Dependente cadastrado como 'conjuge' e funcionário titular "+ALLTRIM((_cAlias)->RA_NOMECMP)+" cadastrado como 'solteiro'." } )
		
		EndIf 
		
		//===========================================================================
		//Valida preenchimento da data de casamento do Dependente 'conjuge'
		//===========================================================================
		//SÓ 1-UNIMED
		If MV_PAR12  = 1 .AND.( (_cAlias)->RB_GRAUPAR == 'C' ) .And. Empty( (_cAlias)->RB_I_DTCA )//SÓ 1-UNIMED
			
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "É obrigatório informar a data de casamento para o dependente cadastrado como 'conjuge'." } } , "0" )
			
			lRet := .F.
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   				(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"É obrigatório informar a data de casamento para o dependente cadastrado como 'conjuge'." } )
		
		EndIf

		If lRet 
			
			//===========================================================================
			//De/Para do Estado Civil do Dependente
			//===========================================================================
			Do Case
			
				Case (_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RA_ESTCIVI == 'C'
					cEstCi := 'C'
					
				Case (_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RA_ESTCIVI == 'M'
					cEstCi := 'U'
					
				Case (_cAlias)->RB_GRAUPAR == 'F'
					cEstCi := 'S'
				
		        //SÓ 1-UNIMED
				Case MV_PAR12  = 1 .AND. ((_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RA_ESTCIVI == 'V')//SÓ 1-UNIMED
					//===========================================================================
					//Grava o Item processado no Lote
					//===========================================================================
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "O grau de parentesco do dependente não é válido." } } , "0" )
					
					lRet := .F.
					
					AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   						(_cAlias)->RA_MAT 		,;
										(_cAlias)->RB_COD		,;
										"Dependente" 		,;
										(_cAlias)->RB_NOME		,;
										"O grau de parentesco do dependente não é válido." } )
					
		        //SÓ 1-UNIMED
				Case MV_PAR12  = 1 .AND. ((_cAlias)->RB_GRAUPAR == 'E' .Or. (_cAlias)->RB_GRAUPAR == 'P' .Or. (_cAlias)->RB_GRAUPAR == 'O' )//SÓ 1-UNIMED
					//===========================================================================
					//Grava o Item processado no Lote
					//===========================================================================
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "O grau de parentesco do dependente não é válido." } } , "0" )
					
			   		lRet := .F.
			   		
			   		AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   						(_cAlias)->RA_MAT 		,;
										(_cAlias)->RB_COD		,;
										"Dependente" 		,;
										(_cAlias)->RB_NOME		,;
										"O Grau de parentesco do dependente não é válido." } )

		        //SÓ 1-UNIMED
				Case MV_PAR12  = 1 .AND. ( (_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RA_ESTCIVI == 'D' .Or. (_cAlias)->RA_ESTCIVI == 'Q' )//SÓ 1-UNIMED
					//===========================================================================
					//Grava o Item processado no Lote
					//===========================================================================
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , _cAcao , "D" , "O grau de parentesco do dependente não é válido." } } , "0" )
					
					lRet := .F.
					
					AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
				   						(_cAlias)->RA_MAT 		,;
										(_cAlias)->RB_COD		,;
										"Dependente" 		,;
										(_cAlias)->RB_NOME		,;
										"O Grau de parentesco do dependente não é válido." } )
			   		
			EndCase
			
		EndIF
		
		IF lRet
		
			//===========================================================================
			//De/Para do Código de Dependência
			//===========================================================================
			Do Case
				Case (_cAlias)->RA_ESTCIVI == 'C' .And. (_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RB_SEXO=='M' 
					cCodDep:= '09'
				Case (_cAlias)->RA_ESTCIVI == 'C' .And. (_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RB_SEXO=='F' 
					cCodDep:= '01'
				Case (_cAlias)->RA_ESTCIVI == 'M' .And. (_cAlias)->RB_GRAUPAR == 'C'  
					cCodDep:= '02'
				Case (_cAlias)->RB_GRAUPAR == 'F' .And. (_cAlias)->RB_SEXO=='M' 
					cCodDep:= '10'
				Case (_cAlias)->RB_GRAUPAR == 'F' .And. (_cAlias)->RB_SEXO=='F' 
					cCodDep:= '30'
			EndCase
		
		EndIF
		
		IF lRet
			
			//===========================================================================
			//Monta linha para gravação do arquivo
	        //Enviar: A Inclusão de dependentes - Envio-2
			//===========================================================================

		IF MV_PAR12 = 1 //1-UNIMED

			cDelim	:= ";"
			nTamLin	:= 2
			cCodUni	:= AllTrim( GetAdvFVal( "SX6" , "X6_CONTEUD" , (_cAlias)->RA_FILIAL + "IT_CODUNI" , 1 , "" ) )
			cLin	:= Space(nTamLin)+ENTER // Variavel para criacao da linha do registros para gravacao
			_cDtAux := IIF( MV_PAR08 == 1 , DtoC(MV_PAR09) , DtoC( StoD( SubStr( (_cAlias)->RHL_PERINI , 3 , 4 ) + SubStr( (_cAlias)->RHL_PERINI , 1 , 2 ) + '01' ) ) )
			
			If (_cAlias)->RHK_PLANO == "98"
				_cplano := _cCodPla2
			Else
				_cplano := _cCodPla
			Endif
			
			cCpo	:= "1"																			+ cDelim //COD_TIPO_REGISTRO
			cCpo	+= cCodUni																		+ cDelim //COD_EMPRESA
			cCpo	+= cTipOpe	   																	+ cDelim //COD_TIPO_OPERACAO
			cCpo	+= ""																			+ cDelim //COD_FAMILIA
			cCpo	+= cCodDep																		+ cDelim //COD_DEPENDENCIA
			cCpo	+= MGPE008TPD( AllTrim((_cAlias)->RB_NOME) , 120 )			 					+ cDelim //NOME_ASSOCIADO
			cCpo	+= (_cAlias)->RB_SEXO						  									+ cDelim //IND_SEXO
			cCpo	+= cEstCi								  						 				+ cDelim //IND_ESTADO_CIVIL
			cCpo	+= If( !Empty((_cAlias)->RB_DTNASC) , DtoC( StoD( (_cAlias)->RB_DTNASC ) ) , "" )	+ cDelim //DATA_NASCIMENTO
			cCpo	+= _cplano  																	+ cDelim //COD_PLANO
			cCpo	+= ""																			+ cDelim //COD_UNIMED_LCAT
			cCpo	+= ""																			+ cDelim //COD_LOTACAO
			cCpo	+= ""																			+ cDelim //NOME_LOTACAO
			cCpo	+= _cDtAux																		+ cDelim //DATA DE INCLUSÃO VERIFICAR NOVAMENTE
			cCpo	+= ""																			+ cDelim //DATA_EXCLUSAO
			cCpo	+= ""																			+ cDelim //DATA_TROCA_PLANO
			cCpo	+= ""																			+ cDelim //DATA_REATIVACAO
			cCpo	+= ""																			+ cDelim //DT_LOTACAO
			cCpo	+= ""																			+ cDelim //DATA_ADMISSAO
			cCpo	+= If( !Empty((_cAlias)->RB_I_DTCA) , DtoC( StoD( (_cAlias)->RB_I_DTCA ) )	, "" )	+ cDelim //DATA_CASAMENTO
			cCpo	+= (_cAlias)->RA_FILIAL + (_cAlias)->RA_MAT											+ cDelim //NUM_MATRIC_EMPRESA
			cCpo	+= (_cAlias)->RB_COD																+ cDelim //NUM_SEQ_MATRIC_EMPRESA
			cCpo	+= AllTrim((_cAlias)->RB_CIC)														+ cDelim //NUM_CPF
			cCpo	+= ""																			+ cDelim //DT_INI_CONTRIB
			cCpo	+= ""																			+ cDelim //NUM_PIS
			cCpo	+= MGPE008TPD( AllTrim((_cAlias)->RB_I_MAE) , 120 )								+ cDelim //NOME_MAE
			cCpo	+= ""																			+ cDelim //COD_BANCO_DCC
			cCpo	+= ""																			+ cDelim //COD_AGENCIA_DCC
			cCpo	+= ""																			+ cDelim //NUM_DV_AGENCIA_DCC
			cCpo	+= ""																			+ cDelim //NUM_CONTA_CORRENTE_DCC
			cCpo	+= ""																			+ cDelim //NUM_DV_CC_DCC
			cCpo	+= ""																			+ cDelim //COD_MOTIVO_EXCLUSAO
			cCpo	+= ""																			+ cDelim //COD_PAIS_NASCIMENTO
			cCpo	+= ""																			+ cDelim //NUM_UNICO_SAUDE
			cCpo	+= ""																			+ cDelim //NOM_LOGRADOURO
			cCpo	+= ""																			+ cDelim //NUM_ENDERECO
			cCpo	+= ""																			+ cDelim //TXT_COMPLEMENTO
			cCpo	+= ""																			+ cDelim //NOME_BAIRRO
			cCpo	+= ""																			+ cDelim //COD_MUNICIPIO
			cCpo	+= ""																			+ cDelim //NUM_CEP
			cCpo	+= ""																			+ cDelim //REGIAO
			cCpo	+= ""																			+ cDelim //NUM_TELEFONE_1
			cCpo	+= ""																			+ cDelim //RAMAL
			cCpo	+= ""																			+ cDelim //END_EMAIL_1
			cCpo	+= ""																			+ cDelim //SETOR
			cCpo	+= ""																			+ cDelim //IND_SITUACAO_EMPRESA
			cCpo	+= ""																			+ cDelim //CATEGORIA
			cCpo	+= ""																			+ cDelim //COD_FUNCAO 
			cCpo	+= ""																			+ cDelim //NUM_IDENTIDADE
			cCpo	+= ""																			+ cDelim //COD_ORGAO_EMISSOR
			cCpo	+= "032"																		+ cDelim //COD_PAIS_EMISSOR
			cCpo	+= ""																			+ cDelim //IND_TIPO_CARENCIA
			cCpo	+= ""																			+ cDelim //IND_MOVIMENTA_AT
			cCpo	+= ""																			+ cDelim //IND_MOVIMENTA_SO
			cCpo	+= "U"																			+ cDelim //IND_LAYOUT_ORIGEM  
			cCpo	+= ""																			+ cDelim //IND_CARTAO_RESID 
			cCpo	+= ""																			+ cDelim //IND_EXTRATO_RESID
			cCpo	+= (_cAlias)->RA_CC																+ cDelim //COD CENTRO DE CUSTO
			cCpo	+= ""																			+ cDelim //NOME CENTRO DE CUSTO
			cCpo	+= ""																			+ cDelim //COD_EMPRESA_SIAMED
			cCpo	+= ""																			+ cDelim //IND_EMPRESA_EMBUTIDA 
			cCpo	+= "N"																			+ cDelim //SEQUENCIAL_DEP_INFORMADA 
			cCpo	+= ""																			+ cDelim //IND_EXTERIOR_1
			cCpo	+= ""																			+ cDelim //COD_PAIS_1 
			cCpo	+= ""																			+ cDelim //COND_DEP
			cCpo	+= ""																			+ cDelim //NUM_DN
			cCpo	+= ""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+= ""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+= ""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+= ""																			+ cDelim //CAMPO RESTRITO À CNU
			cCpo	+= ""																			+ cDelim //NUM_DDD_TELEFONE_1
			cCpo	+= ""																			+ cDelim //DDD_CELULAR_1 
			cCpo	+= ""																			+ cDelim + ENTER //NUM_CELULAR_1
			
			cLin	:= Stuff(cLin,01,LEN(cCPO),cCpo)
		ENDIF	
	 		//===========================================================================
			//| Gravação no arquivo                                                     |
			//===========================================================================
			_lGravouLinha:= (MV_PAR12 = 2 .AND. MGPE8Odonto("D","ID",cNumLote, AllTrim((_cAlias)->RB_NOME) ))
			If _lGravouLinha .OR. (MV_PAR12 = 1 .AND. FWrite( nHdl , cLin , LEN(cLin) ) == LEN( cLin ) )
			    
				//===========================================================================
				//| Grava o Item processado no Lote                                         |
				//===========================================================================
				If cTipOpe == "1"
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , "I" , "D" , "Inclusão do dependente gravada com sucesso!" } } , "1" )
				Else
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , "A" , "D" , "Alteracao do dependente gravada com sucesso!" } } , "1" )
				EndIF
				nRegPro++
			
			ELSEIF MV_PAR12 = 1//Para o MV_PAR12 = 2 gravo dentro da função MGPE8Odonto ("T","I",cNumLote)
			
				//===========================================================================
				//| Grava o Item processado no Lote                                         |
				//===========================================================================
				If cTipOpe == "1"
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , "I" , "D" , "Falha na gravação da linha no arquivo." } } , "0" )
				Else
					U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , "A" , "D" , "Falha na gravação da linha no arquivo." } } , "0" )
				EndIF
				
				AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
			   						(_cAlias)->RA_MAT 		,;
									(_cAlias)->RB_COD		,;
									"Dependente" 		,;
									(_cAlias)->RB_NOME		,;
									"Falha na gravação da Linha do Arquivo." } )
				
			EndIF
			
		EndIF
			
	(_cAlias)->( DbSkip() )
	EndDo
	
	(_cAlias)->( DBCloseArea() )

EndIf

//===========================================================================
//Verifica a Exclusão de funcionários e dependentes - Envio-3
//===========================================================================
If MV_PAR08 == 2 .Or. MV_PAR08 == 4

	//===========================================================================
	//| Consulta funcionários demitidos                                         |
	//===========================================================================
	cBenEx := " SELECT "
	cBenEx += " 	SRA.RA_FILIAL, "
	cBenEx += " 	SRA.RA_MAT, "
	cBenEx += " 	SRA.RA_DEMISSA, "
	cBenEx += "     SRA.RA_NOMECMP,"
	cBenEx += "     SRA.RA_NASC   ,"
	cBenEx += "     SRA.RA_ENDEREC,"
	cBenEx += "     SRA.RA_NUMENDE,"
	cBenEx += "     SRA.RA_BAIRRO ,"
	cBenEx += "     SRA.RA_COMPLEM,"
	cBenEx += "     SRA.RA_CEP    ,"
	cBenEx += "     SRA.RA_ESTADO ,"
	cBenEx += "     SRA.RA_MUNICIP,"
	cBenEx += "     SRA.RA_CIC    ,"
	cBenEx += "     SRA.RA_SEXO   ,"
	cBenEx += "     SRA.RA_MAE    ,"
	cBenEx += " 	'01' AS ORGIGEM "
	cBenEx += " FROM "+ RetSqlName("SRA") +" SRA "
	cBenEx += " INNER JOIN "+ RetSqlName("RHK") +" RHK ON "
	cBenEx += "   	SRA.RA_FILIAL	= RHK.RHK_FILIAL "
	cBenEx += " AND	SRA.RA_MAT		= RHK.RHK_MAT "
	cBenEx += " WHERE "
	cBenEx += "     SRA.D_E_L_E_T_	= ' ' "
	cBenEx += " AND RHK.D_E_L_E_T_	= ' ' "
	
	If !Empty( AllTrim(MV_PAR01) )
	cBenEx += " AND	SRA.RA_FILIAL	IN "+ FormatIn( AllTrim( MV_PAR01 ) , ";" )
	EndIf
	
	cBenEx += " AND SRA.RA_SITFOLH	IN "+FormatIn( cSitFol , ";" )
	
	IF !Empty(cCatFun)
	cBenEx += " AND SRA.RA_CATFUNC	IN "+FormatIn( cCatFun , ";" )
	EndIF
	
	cBenEx += " AND	SRA.RA_CC		BETWEEN '"+ MV_PAR04		+"' AND '"+ MV_PAR05 +"' "
	cBenEx += " AND	SRA.RA_MAT		BETWEEN '"+ MV_PAR06		+"' AND '"+ MV_PAR07 +"' "
	cBenEx += " AND	RHK.RHK_PERFIM	BETWEEN '"+ StrZero( Month(MV_PAR10) , 2 ) + StrZero( Year(MV_PAR10) , 4 ) +"' AND '"+ StrZero( Month(MV_PAR11) , 2 ) + StrZero( Year(MV_PAR11) , 4 ) +"' "
	cBenEx += " AND	RHK.RHK_TPFORN	= '"+ CVALTOCHAR(MV_PAR12)	+"' "//1-UNIMED 2-ODONTOPREV
	cBenEx += " AND	RHK.RHK_CODFOR	= '"+ CVALTOCHAR(MV_PAR13)	+"' "
	cBenEx += " AND	RHK.RHK_PLANO	= '"+ CVALTOCHAR(MV_PAR15)	+"' "
	
	cBenEx += " UNION ALL "
	
	cBenEx += " SELECT "
	cBenEx += " 	SRA.RA_FILIAL, "
	cBenEx += " 	SRA.RA_MAT, "
	cBenEx += " 	SRA.RA_DEMISSA, "
	cBenEx += "     SRA.RA_NOMECMP,"
	cBenEx += "     SRA.RA_NASC   ,"
	cBenEx += "     SRA.RA_ENDEREC,"
	cBenEx += "     SRA.RA_NUMENDE,"
	cBenEx += "     SRA.RA_BAIRRO ,"
	cBenEx += "     SRA.RA_COMPLEM,"
	cBenEx += "     SRA.RA_CEP    ,"
	cBenEx += "     SRA.RA_ESTADO ,"
	cBenEx += "     SRA.RA_MUNICIP,"
	cBenEx += "     SRA.RA_CIC    ,"
	cBenEx += "     SRA.RA_SEXO   ,"
	cBenEx += "     SRA.RA_MAE    ,"
	cBenEx += " 	'02' AS ORGIGEM "
	cBenEx += " FROM "+ RetSqlName("SRA") +" SRA "
	cBenEx += " INNER JOIN "+ RetSqlName("RHN") +" RHN ON "
	cBenEx += " 	SRA.RA_FILIAL	= RHN.RHN_FILIAL "
	cBenEx += " AND	SRA.RA_MAT		= RHN.RHN_MAT "
	cBenEx += " WHERE "
	cBenEx += " 	SRA.D_E_L_E_T_	= ' ' "
	cBenEx += " AND	RHN.D_E_L_E_T_	= ' ' "
	
	If !Empty( AllTrim(MV_PAR01) )
	cBenEx += " AND	SRA.RA_FILIAL	IN "+ FormatIn( AllTrim( MV_PAR01 ) , ";" )
	EndIf
	
	cBenEx += " AND SRA.RA_SITFOLH	IN "+FormatIn( cSitFol , ";" )
	
	IF !Empty(cCatFun)
	cBenEx += " AND SRA.RA_CATFUNC	IN "+FormatIn( cCatFun , ";" )
	EndIF
	
	cBenEx += " AND	SRA.RA_CC		BETWEEN '"+ MV_PAR04		+"' AND '"+ MV_PAR05 +"' "
	cBenEx += " AND	SRA.RA_MAT		BETWEEN '"+ MV_PAR06		+"' AND '"+ MV_PAR07 +"' "
	cBenEx += " AND	RHN.RHN_PERFIM	BETWEEN '"+ StrZero( Month(MV_PAR10) , 2 ) + StrZero( Year(MV_PAR10) , 4 ) +"' AND '"+ StrZero( Month(MV_PAR11) , 2 ) + StrZero( Year(MV_PAR11) , 4 ) +"' "
	cBenEx += " AND	RHN.RHN_TPFORN	= '"+ CVALTOCHAR(MV_PAR12)	+"' "//1-UNIMED 2-ODONTOPREV
	cBenEx += " AND	RHN.RHN_CODFOR	= '"+ CVALTOCHAR(MV_PAR13)	+"' "
	cBenEx += " AND	RHN.RHN_PLANO	= '"+ CVALTOCHAR(MV_PAR15)	+"' "
	cBenEx += " AND	RHN.RHN_OPERAC	= '2' "
	cBenEx += " AND	RHN.RHN_ORIGEM	= '1' "
	cBenEx += " AND	NOT EXISTS		(	SELECT RHL.RHL_MAT FROM "+ RetSqlName("RHL") +" RHL "
	cBenEx += " 						WHERE "
	cBenEx += " 							RHL.D_E_L_E_T_	= ' ' "
	cBenEx += " 						AND RHL.RHL_FILIAL	= RHN.RHN_FILIAL "
	cBenEx += " 						AND RHL.RHL_MAT		= RHN.RHN_MAT "
	cBenEx += " 					) "
	
	cBenEx += " ORDER BY RA_FILIAL "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	Endif
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cBenEx) , _cAlias , .T. , .F. )
	
	nTotReg	:= 0
	nCtAux	:= 0
	
	DBSelectArea(_cAlias)
	
	(_cAlias)->( DBGoTop() )
	(_cAlias)->( DBEval( {|| nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua( nTotReg )
	
	While (_cAlias)->(!EOF())
	
		nCtAux++
		IncProc( "Lendo registos... ["+ StrZero( nCtAux , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
		
		//===========================================================================
		//De/Para do Motivo de Desligamento
		//===========================================================================
	IF MV_PAR12 = 1 //1-UNIMED

		IF (_cAlias)->RA_DEMISSA <> ' '
		
			DbSelectArea ("SRG")
			SRG->( DbSetOrder(1) )
			IF SRG->( DbSeek( (_cAlias)->( RA_FILIAL + RA_MAT ) ) )
				
				If SRG->RG_TIPORES == "14"
					cCodExc:= '5'
				Else 
					cCodExc:= '3'
				EndIf
				
			EndIF
					
		Else
			cCodExc := '1'
		EndIF
		
		//===========================================================================
		//Monta linha para gravação do arquivo
        //Enviar: A Exclusão de funcionários e dependentes - funcionários demitidos  - Envio-3
		//===========================================================================
	  	cDelim	:= ";"
		nTamLin	:= 2
		cLin	:= Space(nTamLin)+ENTER // Variavel para criacao da linha do registros para gravacao
		cCodUni	:= AllTrim( GetAdvFVal( "SX6" , "X6_CONTEUD" , (_cAlias)->RA_FILIAL + "IT_CODUNI" , 1 , "" ) )
		
		cCpo	:=	"1"									+ cDelim //COD_TIPO_REGISTRO
		cCpo	+=	cCodUni								+ cDelim //COD_EMPRESA
		cCpo	+=	"3"									+ cDelim //COD_TIPO_OPERACAO//
		cCpo	+=	""									+ cDelim //COD_FAMILIA
		cCpo	+=	"00"								+ cDelim //COD_DEPENDENCIA
		cCpo	+=	""									+ cDelim //NOME_ASSOCIADO
		cCpo	+=	""									+ cDelim //IND_SEXO 
		cCpo	+=	""									+ cDelim //IND_ESTADO_CIVIL
		cCpo	+=	""									+ cDelim //DATA_NASCIMENTO
		cCpo	+=	""									+ cDelim //COD_PLANO
		cCpo	+=	"" 									+ cDelim //COD_UNIMED_LCAT
		cCpo	+=	""									+ cDelim //COD_LOTACAO
		cCpo	+=	""									+ cDelim //NOME_LOTACAO
		cCpo	+=	""									+ cDelim //DATA_INCLUSAO
		cCpo	+=	DtoC(nDiaFinal)						+ cDelim //DATA_EXCLUSAO
		cCpo	+=	""									+ cDelim //DATA_TROCA_PLANO
		cCpo	+=	""									+ cDelim //DATA_REATIVACAO
		cCpo	+=	""									+ cDelim //DT_LOTACAO
		cCpo	+=	""									+ cDelim //DATA_ADMISSAO
		cCpo	+=	""									+ cDelim //DATA_CASAMENTO
		cCpo	+=	(_cAlias)->( RA_FILIAL + RA_MAT )	+ cDelim //NUM_MATRIC_EMPRESA 
		cCpo	+=	"00"								+ cDelim //NUM_SEQ_MATRIC_EMPRESA 
		cCpo	+=	""									+ cDelim //NUM_CPF 
		cCpo	+=	""									+ cDelim //DT_INI_CONTRIB 
		cCpo	+=	""									+ cDelim //NUM_PIS
		cCpo	+=	""									+ cDelim //NOME_MAE
		cCpo	+=	""									+ cDelim //COD_BANCO_DCC
		cCpo	+=	""									+ cDelim //COD_AGENCIA_DCC
		cCpo	+=	""									+ cDelim //NUM_DV_AGENCIA_DCC
		cCpo	+=	""									+ cDelim //NUM_CONTA_CORRENTE_DCC
		cCpo	+=	""									+ cDelim //NUM_DV_CC_DCC
		cCpo	+=	cCodExc								+ cDelim //COD_MOTIVO_EXCLUSAO
		cCpo	+=	""									+ cDelim //COD_PAIS_NASCIMENTO
		cCpo	+=	""									+ cDelim //NUM_UNICO_SAUDE
		cCpo	+=	""									+ cDelim //NOM_LOGRADOURO
		cCpo	+=	""									+ cDelim //NUM_ENDERECO
		cCpo	+=	""									+ cDelim //TXT_COMPLEMENTO
		cCpo	+=	""									+ cDelim //NOME_BAIRRO
		cCpo	+=	""									+ cDelim //COD_MUNICIPIO
		cCpo	+=	""									+ cDelim //NUM_CEP
		cCpo	+=	""									+ cDelim //REGIAO
		cCpo	+=	""									+ cDelim //NUM_TELEFONE_1  
		cCpo	+=	""									+ cDelim //RAMAL
		cCpo	+=	""									+ cDelim //END_EMAIL_1
		cCpo	+=	""									+ cDelim //SETOR
		cCpo	+=	""									+ cDelim //IND_SITUACAO_EMPRESA
		cCpo	+=	""									+ cDelim //CATEGORIA
		cCpo	+=	""									+ cDelim //COD_FUNCAO
		cCpo	+=	""									+ cDelim //NUM_IDENTIDADE 
		cCpo	+=	""									+ cDelim //COD_ORGAO_EMISSOR  
		cCpo	+=	""									+ cDelim //COD_PAIS_EMISSOR
		cCpo	+=	""									+ cDelim //IND_TIPO_CARENCIA
		cCpo	+=	""									+ cDelim //IND_MOVIMENTA_AT
		cCpo	+=	""									+ cDelim //IND_MOVIMENTA_SO   
		cCpo	+=	"U"									+ cDelim //IND_LAYOUT_ORIGEM 
		cCpo	+=	""									+ cDelim //IND_CARTAO_RESID
		cCpo	+=	""									+ cDelim //IND_EXTRATO_RESID
		cCpo	+=	""									+ cDelim //COD CENTRO DE CUSTO
		cCpo	+=	""									+ cDelim //NOME CENTRO DE CUSTO
		cCpo	+=	""									+ cDelim //COD_EMPRESA_SIAMED
		cCpo	+=	""									+ cDelim //IND_EMPRESA_EMBUTIDA
		cCpo	+=	""									+ cDelim //SEQUENCIAL_DEP_INFORMADA 
		cCpo	+=	""									+ cDelim //IND_EXTERIOR_1
		cCpo	+=	""									+ cDelim //COD_PAIS_1
		cCpo	+=	""									+ cDelim //COND_DEP
		cCpo	+=	""									+ cDelim //NUM_DN
		cCpo	+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+=	""									+ cDelim //NUM_DDD_TELEFONE_1
		cCpo	+=	""									+ cDelim //DDD_CELULAR_1
		cCpo	+=	""									+ cDelim +ENTER //NUM_CELULAR_1
		
		cLin := Stuff( cLin , 01 , LEN(cCPO) , cCpo )
	ENDIF		
 		//===========================================================================
		//Gravação no arquivo
		//===========================================================================
		_lGravouLinha:= (MV_PAR12 = 2 .AND. MGPE8Odonto("T","E",cNumLote))
		If MV_PAR12 = 1 .AND. FWrite( nHdl , cLin , LEN(cLin) ) != LEN(cLin)//Para o MV_PAR12 = 2 gravo dentro da função MGPE8Odonto ("T","I",cNumLote)
		    
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "E" , "F" , "Falha na gravação da linha no arquivo." } } , "0" )
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
								(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Falha na gravação da Linha do Arquivo." } )
		
		ELSEIF _lGravouLinha .OR. MV_PAR12 = 1
			
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "E" , "F" , "Exclusão de titular gravada com sucesso!" } } , "1" )
			nRegPro++
			
		EndIF
		
	(_cAlias)->( DBSkip() )
	EndDo
	
    (_cAlias)->( DBCloseArea() )
	
	//===========================================================================
	//Consulta funcionários que pediram a exclusão do plano - Envio-4
	//===========================================================================
	cBenEx2 := " SELECT * "
	cBenEx2 += " FROM "+ RetSqlName("SRA") +" SRA
	cBenEx2 += " INNER JOIN "+ RetSqlName("RHK") +" RHK ON "
	cBenEx2 += " 		SRA.RA_FILIAL	= RHK.RHK_FILIAL "
	cBenEx2 += " AND	SRA.RA_MAT		= RHK.RHK_MAT "
	cBenEx2 += " WHERE "
	cBenEx2 += " 		RHK.D_E_L_E_T_	= ' ' "
	cBenEx2 += " AND	SRA.D_E_L_E_T_	= ' ' "
	
	If !Empty( AllTrim(MV_PAR01) )
	cBenEx2 += " AND	SRA.RA_FILIAL	IN "+ FormatIn( AllTrim( MV_PAR01 ) , ";" )
	EndIf
	
	cBenEx2 += " AND SRA.RA_SITFOLH	IN "+FormatIn( cSitFol , ";" )
	
	IF !Empty(cCatFun)
	cBenEx2 += " AND SRA.RA_CATFUNC	IN "+FormatIn( cCatFun , ";" )
	EndIF
	
	cBenEx2 += " AND	SRA.RA_CC		BETWEEN '"+ MV_PAR04		+"' AND '"+ MV_PAR05 +"' "
	cBenEx2 += " AND	SRA.RA_MAT		BETWEEN '"+ MV_PAR06		+"' AND '"+ MV_PAR07 +"' "
	cBenEx2 += " AND	RHK.RHK_TPFORN	= '"+ CVALTOCHAR(MV_PAR12) +"' "//1-UNIMED 2-ODONTOPREV
	cBenEx2 += " AND	RHK.RHK_CODFOR	= '"+ CVALTOCHAR(MV_PAR13) +"' "
	cBenEx2 += " AND	RHK.RHK_PLANO	= '"+ CVALTOCHAR(MV_PAR15) +"' "
	cBenEx2 += " AND	RHK.RHK_PERFIM	<> ' ' "
	
	cBenEx2 += " ORDER BY RA_FILIAL, RA_MAT "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	Endif
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cBenEx2) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	
	(_cAlias)->( DBGoTop() )
	(_cAlias)->( DBEval( {|| nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua( nTotReg )
	
	While (_cAlias)->(!EOF())
	
		nCtAux++
		IncProc( "Lendo registos... ["+ StrZero( nCtAux , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
		
		//===========================================================================
		//Motivo da Exclusão
	    //Enviar: A Consulta funcionários que pediram a exclusão do plano - Envio-4
		//===========================================================================
		cCodExc := '1' //"A pedido do beneficiário"
		
		//===========================================================================
		//Monta a linha para gravação do arquivo
		//===========================================================================
	IF MV_PAR12 = 1 //1-UNIMED
		cDelim	:= ";"
		nTamLin	:= 2
		cLin	:= Space( nTamLin ) + ENTER // Variavel para criacao da linha do registros para gravacao
		cCodUni	:= AllTrim( GetAdvFVal( "SX6" , "X6_CONTEUD" , (_cAlias)->RA_FILIAL + "IT_CODUNI" , 1 , "" ) )
		
		cCpo	:= "1"								+ cDelim //COD_TIPO_REGISTRO
		cCpo	+= cCodUni							+ cDelim //COD_EMPRESA
		cCpo	+= "3"								+ cDelim //COD_TIPO_OPERACAO
		cCpo	+= ""								+ cDelim //COD_FAMILIA
		cCpo	+= "00"								+ cDelim //COD_DEPENDENCIA
		cCpo	+= ""								+ cDelim //NOME_ASSOCIADO
		cCpo	+= ""								+ cDelim //IND_SEXO
		cCpo	+= ""								+ cDelim //IND_ESTADO_CIVIL
		cCpo	+= ""								+ cDelim //DATA_NASCIMENTO
		cCpo	+= ""								+ cDelim //COD_PLANO
		cCpo	+= ""								+ cDelim //COD_UNIMED_LCAT
		cCpo	+= ""								+ cDelim //COD_LOTACAO
		cCpo	+= ""								+ cDelim //NOME_LOTACAO
		cCpo	+= ""								+ cDelim //DATA_INCLUSAO
		cCpo	+= DtoC( nDiaFinal )				+ cDelim //DATA_EXCLUSAO
		cCpo	+= ""								+ cDelim //DATA_TROCA_PLANO
		cCpo	+= ""								+ cDelim //DATA_REATIVACAO
		cCpo	+= ""								+ cDelim //DT_LOTACAO
		cCpo	+= ""								+ cDelim //DATA_ADMISSAO
		cCpo	+= ""								+ cDelim //DATA_CASAMENTO
		cCpo	+= (_cAlias)->( RA_FILIAL + RA_MAT )	+ cDelim //NUM_MATRIC_EMPRESA  
		cCpo	+= ""								+ cDelim //NUM_SEQ_MATRIC_EMPRESA
		cCpo	+= ""								+ cDelim //NUM_CPF
		cCpo	+= ""								+ cDelim //DT_INI_CONTRIB
		cCpo	+= ""								+ cDelim //NUM_PIS
		cCpo	+= ""								+ cDelim //NOME_MAE
		cCpo	+= ""								+ cDelim //COD_BANCO_DCC
		cCpo	+= ""								+ cDelim //COD_AGENCIA_DCC
		cCpo	+= ""								+ cDelim //NUM_DV_AGENCIA_DCC
		cCpo	+= ""								+ cDelim //NUM_CONTA_CORRENTE_DCC
		cCpo	+= ""								+ cDelim //NUM_DV_CC_DCC
		cCpo	+= cCodExc							+ cDelim //COD_MOTIVO_EXCLUSAO
		cCpo	+= ""								+ cDelim //COD_PAIS_NASCIMENTO
		cCpo	+= ""								+ cDelim //NUM_UNICO_SAUDE
		cCpo	+= ""								+ cDelim //NOM_LOGRADOURO
		cCpo	+= ""								+ cDelim //NUM_ENDERECO
		cCpo	+= ""								+ cDelim //TXT_COMPLEMENTO
		cCpo	+= ""								+ cDelim //NOME_BAIRRO
		cCpo	+= ""								+ cDelim //COD_MUNICIPIO
		cCpo	+= ""								+ cDelim //NUM_CEP
		cCpo	+= ""								+ cDelim //REGIAO
		cCpo	+= ""								+ cDelim //NUM_TELEFONE_1  
		cCpo	+= ""								+ cDelim //RAMAL
		cCpo	+= ""								+ cDelim //END_EMAIL_1
		cCpo	+= ""								+ cDelim //SETOR
		cCpo	+= ""								+ cDelim //IND_SITUACAO_EMPRESA
		cCpo	+= ""								+ cDelim //CATEGORIA
		cCpo	+= ""								+ cDelim //COD_FUNCAO
		cCpo	+= ""								+ cDelim //NUM_IDENTIDADE 
		cCpo	+= ""								+ cDelim //COD_ORGAO_EMISSOR  
		cCpo	+= ""								+ cDelim //COD_PAIS_EMISSOR
		cCpo	+= ""								+ cDelim //IND_TIPO_CARENCIA
		cCpo	+= ""								+ cDelim //IND_MOVIMENTA_AT
		cCpo	+= ""								+ cDelim //IND_MOVIMENTA_SO   
		cCpo	+= "U"								+ cDelim //IND_LAYOUT_ORIGEM 
		cCpo	+= ""								+ cDelim //IND_CARTAO_RESID
		cCpo	+= ""								+ cDelim //IND_EXTRATO_RESID
		cCpo	+= ""								+ cDelim //COD CENTRO DE CUSTO
		cCpo	+= ""								+ cDelim //NOME CENTRO DE CUSTO
		cCpo	+= ""								+ cDelim //COD_EMPRESA_SIAMED
		cCpo	+= ""								+ cDelim //IND_EMPRESA_EMBUTIDA
		cCpo	+= ""								+ cDelim //SEQUENCIAL_DEP_INFORMADA 
		cCpo	+= ""								+ cDelim //IND_EXTERIOR_1
		cCpo	+= ""								+ cDelim //COD_PAIS_1
		cCpo	+= ""								+ cDelim //COND_DEP
		cCpo	+= ""								+ cDelim //NUM_DN
		cCpo	+= ""								+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+= ""								+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+= ""								+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+= ""								+ cDelim //CAMPO RESTRITO À CNU
		cCpo	+= ""								+ cDelim //NUM_DDD_TELEFONE_1
		cCpo	+= ""								+ cDelim //DDD_CELULAR_1
		cCpo	+= ""								+ cDelim +ENTER //NUM_CELULAR_1
		
 		cLin := Stuff( cLin , 01 , LEN(cCPO) , cCpo )
 	ENDIF	
 		//===========================================================================
		//Gravação no arquivo
		//===========================================================================
		_lGravouLinha:= (MV_PAR12 = 2 .AND. MGPE8Odonto("T","E",cNumLote))
		If MV_PAR12 = 1 .AND. FWrite( nHdl , cLin , LEN(cLin) ) != LEN(cLin)//Para o MV_PAR12 = 2 gravo dentro da função MGPE8Odonto ("T","I",cNumLote)
		
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "E" , "F" , "Falha na gravação da linha no arquivo." } } , "0" )
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
								(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Falha na gravação da Linha do Arquivo." } )
			
		ELSEIF _lGravouLinha .OR. MV_PAR12 = 1
		
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "E" , "F" , "Exclusão de titular gravada com sucesso!" } } , "1" )
			nRegPro++
			
		EndIf
		
	    (_cAlias)->( DBSkip() )
	Enddo
		
	(_cAlias)->( DBCloseArea() )

	//===========================================================================
	//Consulta a exclusão de dependentes do plano - Envio-5
	//===========================================================================
	cBenEx3 := " SELECT "
	cBenEx3 += " 	SRA.*, "
	cBenEx3 += " 	SRB.*, "
	cBenEx3 += " 	'01' AS ORGIGEM "
	cBenEx3 += " FROM "+ RetSqlName("SRA") +" SRA "
	cBenEx3 += " INNER JOIN "+ RetSqlName("RHK") +" RHK ON "
	cBenEx3 += " 		SRA.RA_FILIAL		= RHK.RHK_FILIAL "
	cBenEx3 += " AND	SRA.RA_MAT			= RHK.RHK_MAT "
	cBenEx3 += " INNER JOIN "+ RetSqlName("SRB") +" SRB ON "
	cBenEx3 += " 		SRA.RA_FILIAL		= SRB.RB_FILIAL "
	cBenEx3 += " AND	SRA.RA_MAT			= SRB.RB_MAT "
	cBenEx3 += " INNER JOIN "+ RetSqlName("RHL") +" RHL ON "
	cBenEx3 += " 		SRA.RA_FILIAL		= RHL.RHL_FILIAL "
	cBenEx3 += " AND	SRA.RA_MAT			= RHL.RHL_MAT    "
	cBenEx3 += " AND	SRB.RB_COD			= RHL.RHL_CODIGO "
	cBenEx3 += " AND RHK.RHK_PLANO          = RHL.RHL_PLANO  "
	cBenEx3 += " AND RHK.RHK_TPFORN         = RHL.RHL_TPFORN "
	cBenEx3 += " AND RHK.RHK_CODFOR         = RHL.RHL_CODFOR "
	cBenEx3 += " WHERE "
	cBenEx3 += " 		SRA.D_E_L_E_T_		= ' ' "
	cBenEx3 += " AND	RHK.D_E_L_E_T_		= ' ' "
	cBenEx3 += " AND	SRB.D_E_L_E_T_		= ' ' "
	cBenEx3 += " AND	RHL.D_E_L_E_T_		= ' ' "
	
	If !Empty( AllTrim(MV_PAR01) )
	cBenEx3 += " AND	SRA.RA_FILIAL	IN "+ FormatIn( AllTrim( MV_PAR01 ) , ";" )
	EndIf
	
	cBenEx3 += " AND SRA.RA_SITFOLH	IN "+FormatIn( cSitFol , ";" )
	
	IF !Empty(cCatFun)
	cBenEx3 += " AND SRA.RA_CATFUNC	IN "+FormatIn( cCatFun , ";" )
	EndIF
	
	cBenEx3 += " AND	SRA.RA_CC			BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
	cBenEx3 += " AND	SRA.RA_MAT			BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' "
	cBenEx3 += " AND	RHL.RHL_TPFORN		= '"+ CVALTOCHAR(MV_PAR12) +"' "//1-UNIMED 2-ODONTOPREV
	cBenEx3 += " AND	RHL.RHL_CODFOR		= '"+ CVALTOCHAR(MV_PAR13) +"' "
	cBenEx3 += " AND	RHL.RHL_PLANO		= '"+ CVALTOCHAR(MV_PAR15) +"' "
	cBenEx3 += " AND	RHL.RHL_PERFIM		<> ' ' "
	cBenEx3 += " AND	( RHK.RHK_PERFIM	= ' ' OR RHK.RHK_PERFIM > '"+ DtoS( _dHojeSys ) +"' ) "
	
	cBenEx3 += " UNION ALL "

	cBenEx3 += " SELECT "
	cBenEx3 += " 	SRA.*, "
	cBenEx3 += " 	SRB.*, "
	cBenEx3 += " 	'02' AS ORGIGEM "
	cBenEx3 += " FROM "+ RetSqlName("SRA") +" SRA "
	cBenEx3 += " INNER JOIN "+ RetSqlName("RHK") +" RHK ON "
	cBenEx3 += "     	SRA.RA_FILIAL		= RHK.RHK_FILIAL "
	cBenEx3 += " AND	SRA.RA_MAT			= RHK.RHK_MAT "
	cBenEx3 += " INNER JOIN "+ RetSqlName("SRB") +" SRB ON "
	cBenEx3 += "     	SRA.RA_FILIAL		= SRB.RB_FILIAL "
	cBenEx3 += " AND	SRA.RA_MAT			= SRB.RB_MAT "
	cBenEx3 += " INNER JOIN "+ RetSqlName("RHN") +" RHN ON "
	cBenEx3 += "     	SRA.RA_FILIAL		= RHN.RHN_FILIAL "
	cBenEx3 += " AND	SRA.RA_MAT			= RHN.RHN_MAT "
	cBenEx3 += " AND	SRB.RB_COD			= RHN.RHN_CODIGO "
	cBenEx3 += " AND RHK.RHK_PLANO          = RHN.RHN_PLANO  "
	cBenEx3 += " AND RHK.RHK_TPFORN         = RHN.RHN_TPFORN "
	cBenEx3 += " AND RHK.RHK_CODFOR         = RHN.RHN_CODFOR "
	cBenEx3 += " WHERE "
	cBenEx3 += " 		SRA.D_E_L_E_T_		= ' ' "
	cBenEx3 += " AND	RHK.D_E_L_E_T_		= ' ' "
	cBenEx3 += " AND	SRB.D_E_L_E_T_		= ' ' "
	cBenEx3 += " AND	RHN.D_E_L_E_T_		= ' ' "
	
	If !Empty( AllTrim(MV_PAR01) )
	   cBenEx3 += " AND	SRA.RA_FILIAL	IN "+ FormatIn( AllTrim( MV_PAR01 ) , ";" )
	EndIf
	
	cBenEx3 += " AND SRA.RA_SITFOLH	IN "+FormatIn( cSitFol , ";" )
	
	IF !Empty(cCatFun)
	   cBenEx3 += " AND SRA.RA_CATFUNC	IN "+FormatIn( cCatFun , ";" )
	EndIF
	
	cBenEx3 += " AND	SRA.RA_CC			BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
	cBenEx3 += " AND	SRA.RA_MAT			BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"' "
	cBenEx3 += " AND	RHN.RHN_TPFORN		= '"+ CVALTOCHAR(MV_PAR12) +"' "//1-UNIMED 2-ODONTOPREV
	cBenEx3 += " AND	RHN.RHN_CODFOR		= '"+ CVALTOCHAR(MV_PAR13) +"' "
	cBenEx3 += " AND	RHN.RHN_PLANO		= '"+ CVALTOCHAR(MV_PAR15) +"' "
	cBenEx3 += " AND	RHN.RHN_PERFIM		<> ' ' "
	cBenEx3 += " AND	RHN.RHN_OPERAC		= '2' "
	cBenEx3 += " AND	RHN.RHN_ORIGEM		<> '1' "
	cBenEx3 += " AND	( RHK.RHK_PERFIM	= ' ' OR RHK.RHK_PERFIM > '"+ DtoS(_dHojeSys) +"' ) "
	cBenEx3 += " AND NOT EXISTS			(	SELECT RHL.RHL_MAT FROM "+ RetSqlName("RHL") +" RHL "
	cBenEx3 += " 							WHERE "
	cBenEx3 += " 								RHL.D_E_L_E_T_	= ' ' "
	cBenEx3 += " 							AND RHL.RHL_FILIAL	= RHN.RHN_FILIAL "
	cBenEx3 += " 							AND RHL.RHL_MAT		= RHN.RHN_MAT "
	cBenEx3 += " 							AND RHL.RHL_CODIGO	= RHN.RHN_CODIGO "
	cBenEx3 += " 						) "
		
	If Select(_cAlias) >0
		(_cAlias)->( DBCloseArea() )
	EndIF
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cBenEx3) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	
	(_cAlias)->( DBGoTop() )
	(_cAlias)->( DBEval( {|| nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua( nTotReg )
	
	cFilia		:= (_cAlias)->RB_FILIAL
	cMat		:= (_cAlias)->RB_MAT
	cGraupar	:= (_cAlias)->RB_GRAUPAR
	cSexo		:= (_cAlias)->RB_SEXO
	nContad		:= 0
	nConta		:= 0
	
	While (_cAlias)->(!EOF())
	
		nCtAux++
		IncProc( "Lendo registos... ["+ StrZero( nCtAux , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
		
		//===========================================================================
		//De/Para do código de dependencia
		//===========================================================================
	IF MV_PAR12 = 1 //1-UNIMED
		Do Case 
			
			Case (_cAlias)->RA_ESTCIVI == 'C' .And. (_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RB_SEXO == 'M'
				cCodDep	:= '09'
			Case (_cAlias)->RA_ESTCIVI == 'C' .And. (_cAlias)->RB_GRAUPAR == 'C' .And. (_cAlias)->RB_SEXO == 'F'
				cCodDep	:= '01'
			Case (_cAlias)->RA_ESTCIVI == 'M' .And. (_cAlias)->RB_GRAUPAR == 'C'
				cCodDep	:= '02'
			Case (_cAlias)->RB_GRAUPAR == 'F' .And. (_cAlias)->RB_SEXO == 'M'
				If cFilia <> (_cAlias)->RB_FILIAL .And. cMat <> (_cAlias)->RB_MAT
					cCodDep	:= '10'
					nContad	:=0
				Else
					If nContad == 0
						cCodDep	:= '10'
						nContad++
					Else
						cCodDep	:= Alltrim(Str(10+nContad))
						nContad++
					EndIf
				EndIf
				
			Case (_cAlias)->RB_GRAUPAR == 'F' .And. (_cAlias)->RB_SEXO=='F'  
				If cFilia <> (_cAlias)->RB_FILIAL .And. cMat <> (_cAlias)->RB_MAT
					cCodDep	:= '30'
					nConta	:= 0
				Else
					If nContad == 0
						cCodDep	:= '30'
						nConta++
					Else
						cCodDep	:= Alltrim(Str(30+nConta))
						nConta++
					EndIF
				EndIF
		EndCase
		
		//===========================================================================
		//Monta a linha para a gravação do arquivo
	    //Enviar: A Consulta a exclusão de dependentes do plano - Envio-5
		//===========================================================================
		cFilia		:= (_cAlias)->RB_FILIAL
		cMat		:= (_cAlias)->RB_MAT
		cGraupar	:= (_cAlias)->RB_GRAUPAR
		cSexo		:= (_cAlias)->RB_SEXO
		cCodExc		:= '1' //"A pedido do beneficiário" 
		cDelim 		:= ";"
		nTamLin		:= 2
		cLin   		:= Space(nTamLin) + ENTER // Variavel para criacao da linha do registros para gravacao
		cCodUni		:= AllTrim( GetAdvFVal( "SX6" , "X6_CONTEUD" , (_cAlias)->RA_FILIAL + "IT_CODUNI" , 1 , "" ) )
		
		cCpo		:=	"1"									+ cDelim //COD_TIPO_REGISTRO
		cCpo		+=	cCodUni								+ cDelim //COD_EMPRESA
		cCpo		+=	"3"									+ cDelim //COD_TIPO_OPERACAO
		cCpo		+=	""									+ cDelim //COD_FAMILIA
		cCpo		+=	cCodDep								+ cDelim //COD_DEPENDENCIA
		cCpo		+=	""									+ cDelim //NOME_ASSOCIADO
		cCpo		+=	""									+ cDelim //IND_SEXO 
		cCpo		+=	""									+ cDelim //IND_ESTADO_CIVIL
		cCpo		+=	""									+ cDelim //DATA_NASCIMENTO
		cCpo		+=	""									+ cDelim //COD_PLANO
		cCpo		+=	""									+ cDelim //COD_UNIMED_LCAT
		cCpo		+=	""									+ cDelim //COD_LOTACAO
		cCpo		+=	""									+ cDelim //NOME_LOTACAO
		cCpo		+=	""									+ cDelim //DATA_INCLUSAO
		cCpo		+=	DtoC( nDiaFinal )					+ cDelim //DATA_EXCLUSAO
		cCpo		+=	""									+ cDelim //DATA_TROCA_PLANO
		cCpo		+=	""									+ cDelim //DATA_REATIVACAO
		cCpo		+=	""									+ cDelim //DT_LOTACAO
		cCpo		+=	""									+ cDelim //DATA_ADMISSAO
		cCpo		+=	""									+ cDelim //DATA_CASAMENTO
		cCpo		+=	(_cAlias)->( RA_FILIAL + RA_MAT )	+ cDelim //NUM_MATRIC_EMPRESA  
		cCpo		+=	(_cAlias)->RB_COD					+ cDelim //NUM_SEQ_MATRIC_EMPRESA
		cCpo		+=	""									+ cDelim //NUM_CPF
		cCpo		+=	""									+ cDelim //DT_INI_CONTRIB
		cCpo		+=	""									+ cDelim //NUM_PIS
		cCpo		+=	""									+ cDelim //NOME_MAE
		cCpo		+=	""									+ cDelim //COD_BANCO_DCC
		cCpo		+=	""									+ cDelim //COD_AGENCIA_DCC
		cCpo		+=	""									+ cDelim //NUM_DV_AGENCIA_DCC
		cCpo		+=	""									+ cDelim //NUM_CONTA_CORRENTE_DCC
		cCpo		+=	""									+ cDelim //NUM_DV_CC_DCC
		cCpo		+=	cCodExc								+ cDelim //COD_MOTIVO_EXCLUSAO
		cCpo		+=	""									+ cDelim //COD_PAIS_NASCIMENTO
		cCpo		+=	""									+ cDelim //NUM_UNICO_SAUDE
		cCpo		+=	""									+ cDelim //NOM_LOGRADOURO
		cCpo		+=	""									+ cDelim //NUM_ENDERECO
		cCpo		+=	""									+ cDelim //TXT_COMPLEMENTO
		cCpo		+=	""									+ cDelim //NOME_BAIRRO
		cCpo		+=	""									+ cDelim //COD_MUNICIPIO
		cCpo		+=	""									+ cDelim //NUM_CEP
		cCpo		+=	""									+ cDelim //REGIAO
		cCpo		+=	""									+ cDelim //NUM_TELEFONE_1  
		cCpo		+=	""									+ cDelim //RAMAL
		cCpo		+=	""									+ cDelim //END_EMAIL_1
		cCpo		+=	""									+ cDelim //SETOR
		cCpo		+=	""									+ cDelim //IND_SITUACAO_EMPRESA
		cCpo		+=	""									+ cDelim //CATEGORIA
		cCpo		+=	""									+ cDelim //COD_FUNCAO
		cCpo		+=	""									+ cDelim //NUM_IDENTIDADE 
		cCpo		+=	""									+ cDelim //COD_ORGAO_EMISSOR  
		cCpo		+=	""									+ cDelim //COD_PAIS_EMISSOR
		cCpo		+=	""									+ cDelim //IND_TIPO_CARENCIA
		cCpo		+=	""									+ cDelim //IND_MOVIMENTA_AT
		cCpo		+=	""									+ cDelim //IND_MOVIMENTA_SO   
		cCpo		+=	"U"									+ cDelim //IND_LAYOUT_ORIGEM 
		cCpo		+=	""									+ cDelim //IND_CARTAO_RESID
		cCpo		+=	""									+ cDelim //IND_EXTRATO_RESID
		cCpo		+=	""									+ cDelim //COD CENTRO DE CUSTO
		cCpo		+=	""									+ cDelim //NOME CENTRO DE CUSTO
		cCpo		+=	""									+ cDelim //COD_EMPRESA_SIAMED
		cCpo		+=	""									+ cDelim //IND_EMPRESA_EMBUTIDA
		cCpo		+=	""									+ cDelim //SEQUENCIAL_DEP_INFORMADA 
		cCpo		+=	""									+ cDelim //IND_EXTERIOR_1
		cCpo		+=	""									+ cDelim //COD_PAIS_1
		cCpo		+=	""									+ cDelim //COND_DEP
		cCpo		+=	""									+ cDelim //NUM_DN
		cCpo		+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo		+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo		+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo		+=	""									+ cDelim //CAMPO RESTRITO À CNU
		cCpo		+=	""									+ cDelim //NUM_DDD_TELEFONE_1
		cCpo		+=	""									+ cDelim //DDD_CELULAR_1
		cCpo		+=	""									+ cDelim + ENTER //NUM_CELULAR_1
		
 		cLin := Stuff( cLin , 01 , LEN(cCPO) , cCpo )
 	ENDIF	

 		//===========================================================================
		//Gravação no arquivo
		//===========================================================================
		_lGravouLinha:= (MV_PAR12 = 2 .AND. MGPE8Odonto("D","E",cNumLote,AllTrim((_cAlias)->RB_NOME)))
		If MV_PAR12 = 1 .AND. FWrite( nHdl , cLin , LEN(cLin) ) != LEN(cLin)//Para o MV_PAR12 = 2 gravo dentro da função MGPE8Odonto ("T","I",cNumLote)
			
			//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , "E" , "D" , "Falha na gravação da linha no arquivo." } } , "0" )
			
			AADD( aLogPro , {	(_cAlias)->RA_FILIAL	,;
								(_cAlias)->RA_MAT 		,;
								(_cAlias)->RB_COD		,;
								"Dependente" 		,;
								(_cAlias)->RB_NOME		,;
								"Falha na gravação da Linha do Arquivo." } )
 			
 		ELSEIF _lGravouLinha .OR. MV_PAR12 = 1
 		    
	 		//===========================================================================
			//Grava o Item processado no Lote
			//===========================================================================
			U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RB_COD , "E" , "D" , "Exclusão de dependente gerada com sucesso." } } , "1" )
			nRegPro++
	 		
	 	EndIF
 	
	(_cAlias)->( DBSkip() )
	EndDo
	
	(_cAlias)->( DBCloseArea() )
    
EndIf 

//===========================================================================
//Consulta registros duplicados no cadastro
//===========================================================================
cDupl := " SELECT * "
cDupl += " FROM "+ RetSqlName("SRA") +" SRA "
cDupl += " WHERE "
cDupl += " 		SRA.RA_CIC IN (	SELECT SRA1.RA_CIC FROM "+ RetSqlName("SRA") +" SRA1 "
cDupl += " 						WHERE "
cDupl += " 							SRA1.RA_SITFOLH	<> 'D' "
cDupl += " 						AND	SRA1.RA_CATFUNC IN ('M','H') "
cDupl += " 						AND SRA1.D_E_L_E_T_ = ' ' "
cDupl += " 						GROUP BY SRA1.RA_CIC "
cDupl += " 						HAVING COUNT(*) > 1 ) "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
Endif

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cDupl) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)

(_cAlias)->( DBGoTop() )
(_cAlias)->( DBEval( {|| nTotReg++ } ) )
(_cAlias)->( DBGoTop() )

ProcRegua( nTotReg )

While (_cAlias)->(!EoF())

	nCtAux++
	IncProc( "Lendo registos... ["+ StrZero( nCtAux , 9 ) +"] de ["+ StrZero( nTotReg , 9 ) +"]" )
	
	AADD( aLogDup , { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , (_cAlias)->RA_NOMECMP , "Verificar duplicidade de registros" } )

(_cAlias)->( DbSkip() )
EndDo

IF LEN(aDadosOdonto) > 0//ODONTOPREV
   _aCabOdo:={}
   _aCabXLX:={}
   // Alinhamento: 1-Left   ,2-Center,3-Right
   // Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
   //             Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
   //   (_aCabXLX,{Titulo                  ,1           ,1         ,.F.       })
   AADD(_aCabOdo,"Filial")
   AADD(_aCabOdo,"Nome do titular")
   AADD(_aCabOdo,"Nome do beneficiário")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Identificação")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Plano")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Data nascimento")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,4         ,.F.})
   AADD(_aCabOdo,"Tipo endereço")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Endereço")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"N° do logradouro")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Bairro")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Complemento do endereço")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"CEP")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"UF")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Cidade")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Cidade beneficiário")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Telefone residencial")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Carteira de identidade")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Orgão emissor")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Estado civil")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Departamento")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Parentesco")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Número da carteirinha")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Ação")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Número de registro")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"CPF")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Sexo")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.})
   AADD(_aCabOdo,"Nome da mãe")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"PIS")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"N° declaração de nascido")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Código da empresa")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,2           ,1         ,.F.}) ; nPosCodEmp := LEN(_aCabXLX)
   AADD(_aCabOdo,"Email")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"CNS")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Motivos de exclusão")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Houve contribuição")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Período")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})
   AADD(_aCabOdo,"Informado do direito")
   AADD(_aCabXLX,{_aCabOdo[LEN(_aCabOdo)]   ,1           ,1         ,.F.})

    _aButtons:={}
   IF LEN(aLogDup) > 0
	  ASORT(aLogDup,,,{|x,y| x[1]+x[3] < y[1]+y[3] })
      AADD(_aButtons,{"",{|| U_ITListBox( "Relatório de Duplicidade" , {"Filial","Matrícula","Nome","Mensagem"} , aLogDup , .T. )   },"Relatório de Duplicidade", "Relatório de Duplicidade" }) 
   ELSE
      AADD(_aButtons,{"",{|| U_ITMsgLog("Não houve duplicidade!", "ATENCAO",2,.F.)   },"Relatório de Duplicidade", "Relatório de Duplicidade" }) 
   ENDIF
   IF LEN(aLogPro) > 0
	  ASORT(aLogPro,,,{|x,y| x[1]+x[5] < y[1]+y[5] })
      AADD(_aButtons,{"",{|| U_ITListBox( "Mensagens do processamento:" , {"Filial","Matrícula","Código","Tipo","Nome","Mensagem"} , aLogPro , .T. )  },"Mensagens do processamento", "Mensagens do processamento" }) 
   ELSE
      AADD(_aButtons,{"",{|| U_ITMsgLog("Não houve mensagens!", "ATENCAO",2,.F.)   },"Mensagens do processamento", "Mensagens do processamento" }) 
   ENDIF
   _cMsgTop:="Clique em 'Outras Ações' e escolha a Exportação para o Excel no formato desejada."
   ASORT(aXlsxOdonto ,,,{|x,y| x[nPosCodEmp]+x[1] < y[nPosCodEmp]+y[1] })//CODIGO DA EMPRESA + NOME
   ASORT(aDadosOdonto,,,{|x,y| x[1]+x[2]+x[4]     < y[1]+y[2]+y[4]     }) // FILIAL + NOME + IDENTIFICACAO
   //                                             _cTitAux            , _aHeader , _aCols       , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel,_aButtons, _aCab  , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1)
   U_ITListBox( 'Lista dos Funcionarios e Dependentes com ODONTOPREV' , _aCabOdo , aDadosOdonto , .T.      , 1      ,_cMsgTop  ,          ,         ,         ,     ,        ,_aButtons,_aCabXLX,         , aXlsxOdonto)

ELSEIF LEN(aLogPro) > 0 // UNIMED
    //===========================================================================
    //Se forem encontradas inconsistências dos cadastros exibe o LOG
    //===========================================================================
    _aButtons:={}
   IF LEN(aLogDup) > 0
	  ASORT(aLogDup,,,{|x,y| x[1]+x[3] < y[1]+y[3] })// FILIAL + NOME
      AADD(_aButtons,{"",{|| U_ITListBox( "Relatório de Duplicidade:" , {"Filial","Matrícula","Nome","Mensagem"} , aLogDup , .T. )   },"Relatório de Duplicidade", "Relatório de Duplicidade" }) 
   ELSE
      AADD(_aButtons,{"",{|| U_ITMsgLog("Não houve duplicidade!", "ATENCAO",2,.F.)   },"Relatório de Duplicidade", "Relatório de Duplicidade" }) 
   ENDIF
   _cMsgTop:='Para o "Relatório de Duplicidade" clique em "Outras Ações". '
	ASORT(aLogPro,,,{|x,y| x[1]+x[5] < y[1]+y[5] })// FILIAL + NOME
   //                      _cTitAux            , _aHeader                                                 , _aCols  , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel,_aButtons, _aCab  , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1)
	U_ITListBox( "Mensagens do processamento:" , {"Filial","Matrícula","Código","Tipo","Nome","Mensagem"} , aLogPro , .T.      ,        ,_cMsgTop  ,          ,         ,         ,     ,        ,_aButtons)

EndIF

Return()

/*
===============================================================================================================================
Programa--------: MGPE008TPD
Autor-----------: Erich Buttner
Data da Criacao-: 10/03/2013
Descrição-------: Rotina de formatação de conteúdos
Parametros------: xValor	: conteúdo da variável
----------------: nTam	: tamanho da variável formatada
----------------: nDec	: tamanho decimal da variável formatada
Retorno---------: cRet	: retorno do conteúdo formatado
===============================================================================================================================
*/
Static Function MGPE008TPD( xValor , nTam , nDec )

Local cRet		:= ""

DEFAULT nTam	:= 0
DEFAULT nDec	:= 0

Do Case
	Case ValType(xValor) == "N"
		IF nTam == 0
			cRet := cValToChar( Round( xValor , nDec ) )
		Else
			cRet := AllTrim( Str( xValor , nTam , nDec ) )
		EndIF
	Case ValType(xValor) == "D"
		cRet := DtoS( xValor )
		cRet := SubStr( cRet , 1 , 4 ) +"-"+ SubStr( cRet , 5 , 2 ) +"-"+ SubStr( cRet , 7 ) // YYYY-MM-DD
	Case ValType(xValor) == "C"
		If nTam == 0
			xValor := AllTrim( xValor )
		EndIf
		cRet := AllTrim( FWHttpEncode( NoAcento( SubStr( xValor , 1 , nTam ) ) ) )
EndCase

Return(cRet)

/*
===============================================================================================================================
Programa----------: MGPE008END
Autor-------------: Erich Buttner
Data da Criacao---: 10/03/2013
Descrição---------: Rotina que retorna o endereço formatado
Parametros--------: cEndAux	: Dados do Endereço
------------------: cEstAux	: Dados do Estado do Endereço
------------------: nOpc	: Opção de Formatação
Retorno-----------: cRet	: retorno do conteúdo formatado
===============================================================================================================================
*/
Static Function MGPE008END( cRet )

cRet := StrTran( cRet , 'RUA'			, "" )
cRet := StrTran( cRet , 'R.'			, "" )
cRet := StrTran( cRet , 'AV '			, "" )
cRet := StrTran( cRet , 'AV.'			, "" )
cRet := StrTran( cRet , 'ROD'			, "" )
cRet := StrTran( cRet , 'ROD.'			, "" )
cRet := StrTran( cRet , 'AVENIDA'		, "" )
cRet := StrTran( cRet , 'PRACA'			, "" )
cRet := StrTran( cRet , 'RODOVIA'		, "" )
cRet := StrTran( cRet , 'FAZ'			, "" )
cRet := StrTran( cRet , 'FAZ.'			, "" )
cRet := StrTran( cRet , 'FAZENDA'		, "" )
cRet := StrTran( cRet , 'PCA '			, "" )
cRet := StrTran( cRet , 'PCA.'			, "" )
cRet := StrTran( cRet , 'RESIDENCIAL'	, "" )
cRet := StrTran( cRet , 'TRAVESSA'		, "" )
cRet := StrTran( cRet , 'TRAV'			, "" )
cRet := StrTran( cRet , 'TRAV.'			, "" )
cRet := StrTran( cRet , 'VIELA'			, "" )
cRet := StrTran( cRet , 'CHACARA'		, "" )
cRet := StrTran( cRet , 'ALAMEDA'		, "" )
cRet := StrTran( cRet , 'ASSENTAMENTO'	, "" )
cRet := StrTran( cRet , 'BECO'			, "" )

cRet := AllTrim( cRet )

If SubStr( cRet , 1 , 2 ) == 'R '
	cRet := SubStr( cRet , 3 )
EndIf

Return( cRet )

/*
===============================================================================================================================
Programa--------: MGPE008P
Autor-----------: Alexandre Villar
Data da Criacao-: 21/02/2014
Descrição-------: Rotina de validação dos parâmetros durante o preenchimento.
Parametros------: nOpc	: Opção de Validação
Retorno---------: lRet	: Define se o conteúdo passou pela validação
===============================================================================================================================
*/
User Function MGPE008P( nOpc )

Local lRet		:= .T. //Se retornar .F. nao deixa sair do campo
Local aArea		:= GetArea()
Local cNomeVar	:= ReadVar()
Local aAcesso	:= FWEmpLoad(.F.)
Local aDadAux	:= {}
Local _nI, _nX	:= 0
Local xVarAux	:= NIL
Local _aSX5		:= {}

Do Case
	Case nOpc == 1 //"Filiais Consideradas ?"
		xVarAux := MV_PAR01
		_cFilsAcesso := ""
		For _nX := 1 To LEN(aAcesso)
			_cFilsAcesso+=aAcesso[_nX][03]+", "
		Next _nX
		//-- Verifica se o campo esta vazio --//
		If EMPTY(xVarAux)
			//MsgStop("É obrigatório informar o filtro de Filiais, clique em 'selecionar todas' para utilizar todas as Filiais.","MGPE00804")
	        U_ITMSG("Com a filial em branco, somente as filiais que o usuario tem acesso serao selecionadas: "+_cFilsAcesso+" (MV_PAR01)",'Atenção!',,1)
			MV_PAR01:=STRTRAN( _cFilsAcesso, ", ", ";")
			//lRet := .F.
		//-- Verifica se o campo foi preenchido com conteudo valido --//
		Else
			aDadAux := U_ITLinDel( AllTrim(xVarAux) , ";" )
			SM0->(dbSetOrder(1))
			For _nI := 1 To LEN(aDadAux)

				If !SM0->(dbSeek(cEmpAnt + aDadAux[_nI]))
					//MsgStop("As 'Filiais' informadas não são válidas!. Verifique os dados digitados.","MGPE00805")
	                U_ITMSG("Filial "+aDadAux[_nI]+" informada não existe. (MV_PAR01)",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
					Exit
				EndIf
				
				If !aDadAux[_nI] $ _cFilsAcesso
					//MsgStop("O usuário não tem acesso às 'Filiais' informadas! Verifique os dados digitados.","MGPE00806")
	                U_ITMSG("Filial "+aDadAux[_nI]+" informada o usuário não tem acesso.",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
					Exit
				EndIf
			
			Next _nI
			
		EndIf

	Case nOpc == 2 //"Categorias a Imp. ?"
		xVarAux := MV_PAR02
		If Empty(xVarAux)
			//MsgStop("É obrigatório informar o filtro de Categorias Funcionais. Clique em 'selecionar todas' para utilizar todas as Categorias.","MGPE00807")
            U_ITMSG("É obrigatório informar o filtro de Categorias Funcionais. (MV_PAR02)",'Atenção!',"Clique em 'selecionar todas' para utilizar todas as Categorias.",1)
			lRet := .F.
		Else
			aDadAux := U_ITLinDel( AllTrim(xVarAux) ,, 1 )
			_aSX5 := FWGetSX5("28")
			For _nI := 1 To LEN(aDadAux)
				If aDadAux[_nI] == "*"
					Loop
				EndIf
				If aScan( _aSX5,{|X| UPPER( Alltrim( X[3] ) ) == AllTrim(aDadAux[_nI])} ) == 0
					//MsgStop("As 'Categorias Funcionais' informadas não são válidas! Verifique os dados digitados.","MGPE00808")
                    U_ITMSG("As 'Categorias Funcionais' informadas não são válidas. (MV_PAR02)",'Atenção!',"Verifique os dados digitados.",1)
					lRet := .F.
					Exit
				EndIf
			Next _nI
		EndIF
	
	Case nOpc == 3 //"Situações ?"
		xVarAux := MV_PAR03
		If EMPTY(xVarAux)
			&(cNomeVar) := " "
		Else
			_aSX5 := FWGetSX5("31")
			aDadAux := U_ITLinDel( xVarAux ,, 1 )
			For _nI := 1 To LEN(aDadAux)
				If aDadAux[_nI] == "*"
					Loop
				EndIf
				If aScan( _aSX5,{|X| UPPER( Alltrim( X[3] ) ) == AllTrim(aDadAux[_nI])} ) == 0
					//MsgStop("As 'Situações na Folha' informadas não são válidas! Verifique os dados digitados.","MGPE00809")
                    U_ITMSG("As 'Situações na Folha' informadas não são válidas. (MV_PAR03)",'Atenção!',"Verifique os dados digitados.",1)
					lRet := .F.
					Exit
				EndIf
			Next _nI
		EndIf
	Case nOpc == 4 //"Fornecedor ?"
		xVarAux := MV_PAR13
		If Empty(xVarAux)
			//MsgStop("É obrigatório informar o 'Código do Fornecedor'!","MGPE00810")
            U_ITMSG("É obrigatório informar o Código do Fornecedor. (MV_PAR13)",'Atenção!',"Verifique os dados digitados.",1)
			lRet := .F.
		ElseIf !U_MGPEF3GN( MV_PAR12 ,, 1 , .T. , xVarAux )//1-UNIMED 2-ODONTOPREV
			//MsgStop("O 'Código do Fornecedor' informado não é válido! Verifique os dados digitados.","MGPE00811")
            U_ITMSG("O Código do Fornecedor informado não é válido. (MV_PAR12, MV_PAR13)",'Atenção!',"Verifique os dados digitados.",1)
			lRet := .F.
		EndIf
	Case nOpc == 5 //"Plano ?"p
		xVarAux := MV_PAR15
		If Empty(xVarAux)
			//MsgStop("É obrigatório informar o 'Código do Plano'!","MGPE00812")
            U_ITMSG("É obrigatório informar o 'Código do Plano. (MV_PAR15)",'Atenção!',"Verifique os dados digitados.",1)
			lRet := .F.
		ElseIf !U_ITMedOdo( MV_PAR12 , MV_PAR13 , MV_PAR14 , .T. , xVarAux )//1-UNIMED 2-ODONTOPREV
			//MsgStop("O 'Código do Plano' informado não é válido! Verifique os dados digitados.","MGPE00813")
            U_ITMSG("O 'Código do Plano' informado não é válido. (MV_PAR12, MV_PAR13, MV_PAR14, MV_PAR15)",'Atenção!',"Verifique os dados digitados.",1)
			lRet := .F.
		EndIf
	Case nOpc == 6
		xVarAux := MV_PAR16
		If Empty(xVarAux)
			//MsgStop( "É obrigatório informar o dia de corte para efetivações no plano!","MGPE00814")
            U_ITMSG("É obrigatório informar o dia de corte para efetivações no plano. (MV_PAR16)",'Atenção!',"Verifique os dados digitados.",1)
			lRet := .F.
		ElseIf xVarAux <= 0 .Or. xVarAux > 31
			//MSgStop("O dia de corte deve ser entre 1 e 31! Verifique os dados digitados.","MGPE00815")
            U_ITMSG("O dia de corte deve ser entre 1 e 3. (MV_PAR16)",'Atenção!',"Verifique os dados digitados.",1)
			lRet := .F.
		EndIF

EndCase

RestArea(aArea)

Return(lRet)

/*
===============================================================================================================================
Programa--------: MGPE008ZP1
Autor-----------: Alex Wallauer
Data da Criacao-: 06/12/2023
Descrição-------: Rotina para dar a primeira carga dos parametros por filial
Parametros------: Nenhum
Retorno---------: Define se o conteúdo passou pela validação
===============================================================================================================================
*/
STATIC FUNCTION MGPE008ZP1()

LOCAL _cTexto:="", Z
LOCAL aZP1:={}
LOCAL cFilOdontoPrev:=""
AADD(aZP1,{"01","156775"}) // CORUMBAIBA
AADD(aZP1,{"02","156857"}) // ITAPACI
AADD(aZP1,{"04","156863"}) // ARAGUARI
AADD(aZP1,{"06","156776"}) // PONTALINA
AADD(aZP1,{"09","156854"}) // IPORA
AADD(aZP1,{"10","156858"}) // JARU
AADD(aZP1,{"11","156780"}) // NOVA MAMORE
AADD(aZP1,{"20","156852"}) // PASSO FUNDO
AADD(aZP1,{"23","156859"}) // TAPEJARA
AADD(aZP1,{"24","156856"}) // CRISSIUMAL
AADD(aZP1,{"25","156777"}) // GIRUA
AADD(aZP1,{"30","156781"}) // XINGUARA
AADD(aZP1,{"31","156862"}) // CONCEICAO
AADD(aZP1,{"40","156861"}) // TRES CORACOES
AADD(aZP1,{"90","156855"}) // SP CD
AADD(aZP1,{"91","156778"}) // MANAUS
AADD(aZP1,{"92","156853"}) // SP ADM
AADD(aZP1,{"93","156779"}) // CASCAVEL
AADD(aZP1,{"0B","156860"}) // QUIRINOPOLIS

ZP1->(DBSETORDER(2))
FOR Z := 1 TO LEN(aZP1)
    cFilOdontoPrev+=aZP1[Z,1]+", "
    IF ZP1->(DBSEEK(xFilial()+aZP1[Z,1]+"IT_CDFILODO"))
       _cTexto+="Parametro IT_CDFILODO JA cadastrado: "+aZP1[Z,1]+" "+aZP1[Z,2]+CHR(13)+CHR(10)
       LOOP
    ELSE
       ZP1->(RECLOCK("ZP1",.T.))
    ENDIF
    ZP1->ZP1_FILPAR:=aZP1[Z,1]
    ZP1->ZP1_PARAM :="IT_CDFILODO"
    ZP1->ZP1_TIPO  :="C"
    ZP1->ZP1_DESCRI:="Preencher com o código da filial da ITALAC com ODONTOPREV."
    ZP1->ZP1_CONTEU:=aZP1[Z,2]
    ZP1->ZP1_MODULO:="09"
    ZP1->ZP1_GRUPO :="P"
    ZP1->ZP1_ROTINA:="MGPE008"
    ZP1->ZP1_DESROT:="Geracao de arquivo de dados para ODONTOPREV."
    ZP1->ZP1_FILIAL:=xFilial("ZP1")
    ZP1->(MSUNLOCK())
    _cTexto+="Parametro IT_CDFILODO foi cadastrado com sucesso: "+aZP1[Z,1]+" "+aZP1[Z,2]+CHR(13)+CHR(10)
NEXT
ZP1->(DBSETORDER(1))

RETURN cFilOdontoPrev 


/*
===============================================================================================================================
Programa--------: MGPE8Odonto
Autor-----------: Alex Wallauer
Data da Criacao-: 06/12/2023
Descrição-------: Rotina para grava a array aDadosOdonto
Parametros------: _cTipo,cAcao,cNumLote,cNome
Retorno---------: Define se o conteúdo passou pela validação
===============================================================================================================================
*/
STATIC FUNCTION MGPE8Odonto(_cTipo,cAcao,cNumLote,cNome)

LOCAL _aFunc :={} , T
LOCAL _aFuncT:={}
LOCAL _cParentesco:=""
LOCAL _cCodEmp:=""
DEFAULT cNome := (_cAlias)->RA_NOMECMP

ZP1->(DBSETORDER(2))
IF ZP1->(DBSEEK(xFilial()+(_cAlias)->RA_FILIAL+"IT_CDFILODO"))
   _cCodEmp:=ALLTRIM(ZP1->ZP1_CONTEU)
ELSE
    // Grava o Item processado no Lote
    IF cAcao == "I"
	   U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "I" , "F" , "Não encontrou o parametro IT_CDFILOND para filial: "+(_cAlias)->RA_FILIAL} } , "0" )
    Else
	   U_ITGrLote( "Z05" , cNumLote , { { (_cAlias)->RA_FILIAL , (_cAlias)->RA_MAT , "00" , "A" , "F" , "Não encontrou o parametro IT_CDFILOND para filial: "+(_cAlias)->RA_FILIAL} } , "0" )
    EndIF
    IF _cTipo = "D"
	  AADD( aLogPro , {(_cAlias)->RA_FILIAL,(_cAlias)->RA_MAT,"00","Dependente",(_cAlias)->RA_NOMECMP,"Não encontrou o parametro IT_CDFILOND para filial: "+(_cAlias)->RA_FILIAL } )
	ELSE
	  AADD( aLogPro , {(_cAlias)->RA_FILIAL,(_cAlias)->RA_MAT,"00","Funcionário",(_cAlias)->RA_NOMECMP,"Não encontrou o parametro IT_CDFILOND para filial: "+(_cAlias)->RA_FILIAL } )
	ENDIF
    ZP1->(DBSETORDER(1))
	RETURN .F. //////////////////// RETURN
ENDIF
ZP1->(DBSETORDER(1))
IF _cTipo = "D"
   _cParentesco:=If((_cAlias)->RB_GRAUPAR = 'C','Conjuge',IF((_cAlias)->RB_GRAUPAR = 'F','Filho','Outros'))
ENDIF

AADD(_aFunc,cNome                                          ) // NOME DO BENEFICIÁRIO Este campo contempla no máximo 70 caracteres,o nome deve estar escrito igual ao registro civil ou carteira de identidade, sem abreviações e sem pontos (CAMPO OBRIGATÓRIO)
AADD(_aFunc,_cTipo                                         ) // IDENTIFICAÇÃO DO BENEFICIÁRIO PREENCHER : T PARA TITULAR ou D PARA DEPENDENTE (CAMPO OBRIGATÓRIO)
AADD(_aFunc,"IPA"                                          ) // PLANO Informar a sigla do plano, por favor verifique qual é a sigla dos planos para sua empresa, com o representante Odontoprev (CAMPO OBRIGATÓRIO)
AADD(_aFunc,STOD( (_cAlias)->RA_NASC )                     ) // DATA DE NASCIMENTO preencher sempre no formato DD/MM/AAAA (CAMPO OBRIGATÓRIO)
AADD(_aFunc,"2"                                            ) // TIPO DE ENDEREÇO Profissional ou Residencial Informar 1 para endereço PROFISSIONAL Informar 2 – para endereços RESIDENCIAL
AADD(_aFunc,STRTRAN(ALLTRIM((_cAlias)->RA_ENDEREC),';','') ) // ENDEREÇO (CAMPO OBRIGATÓRIO)
AADD(_aFunc,STRTRAN(ALLTRIM((_cAlias)->RA_NUMENDE),';','') ) // N° DO LOGRADOURO (CAMPO OBRIGATÓRIO)
AADD(_aFunc,LEFT( (_cAlias)->RA_BAIRRO , 20 )              ) // BAIRRO no máximo 20 CARACTERES
AADD(_aFunc,STRTRAN(LEFT((_cAlias)->RA_COMPLEM,20),';','') ) // COMPLEMENTO DO ENDEREÇO no máximo 20 CARACTERES
AADD(_aFunc,(_cAlias)->RA_CEP                              ) // CEP Preencher no formato 00000000 (CAMPO OBRIGATÓRIO)
AADD(_aFunc,(_cAlias)->RA_ESTADO                           ) // ESTADO / UF Preencher com somente 2 caracteres (CAMPO OBRIGATÓRIO)
AADD(_aFunc,(_cAlias)->RA_MUNICIP                          ) // CIDADE                                                                     
AADD(_aFunc,""                                             ) // CIDADE BENEFICIÁRIO (Preencher somente quando o Tipo de Endereço escolhido for Profissional)
AADD(_aFunc,""                                             ) // TELEFONE RESIDENCIAL                                                                     
AADD(_aFunc,""                                             ) // CARTEIRA DE IDENTIDADE Preencher com no máximo 20 caracteres, este campo não deverá conter pontos, hífen ou traços
AADD(_aFunc,""                                             ) // ORGÃO EMISSOR                                                                     
AADD(_aFunc,""                                             ) // ESTADO CIVIL                                                                     
AADD(_aFunc,""                                             ) // DEPARTAMENTO Este dado será impresso na carteirinha, preencha este campo somente se necessário
AADD(_aFunc,_cParentesco                                   ) // PARENTESCO DOS DEPENDENTES Preencher com no máximo 10 caracteres: CONJUGE, FILHA, FILHO e AGREGADO (se contratado pela sua empresa) CAMPO OBRIGATÓRIO somente para dependentes
AADD(_aFunc,""                                             ) // NÚMERO DA CARTEIRINHA Para a primeira movimentação este campo deve vir em BRANCO Este campo é obrigatório somente para para as ações: Alteração , Transferência, Exclusão, Reativação, Solicitação de 2ª via ou Inclusão de dependentes de titulares já cadastrados
AADD(_aFunc,cAcao                                          ) // AÇÃO preencher com a letra: I para Inclusões ID para Inclusões de dependentes A para Alterações E para Exclusões T para Transferências S para pedido de 2ª vias R = Reativação (CAMPO OBRIGATÓRIO)
AADD(_aFunc,(_cAlias)->RA_FILIAL+(_cAlias)->RA_MAT         ) // NÚMERO DE REGISTRO DO FUNCIONÁRIO NA EMPRESA, matrícula do beneficiário (CAMPO OBRIGATÓRIO)
AADD(_aFunc,AllTrim( (_cAlias)->RA_CIC    )                ) // CPF Este campos deve ser preenchido com no máximo 11 caracteres, sem pontos e traços (CAMPO OBRIGATÓRIO PARA TITULARES E DEPENDENTES MAIORES DE 18 ANOS)
AADD(_aFunc,AllTrim( (_cAlias)->RA_SEXO   )                ) // SEXO Preencher com a letra: F para FEMININO ou M para MASCULINO (CAMPO OBRIGATÓRIO)
AADD(_aFunc,AllTrim( (_cAlias)->RA_MAE    )                ) // NOME DA MÃE Este campo contempla no máximo 70 caracteres, o nome deve estar escrito igual ao registro civil ou carteira de identidade, sem abreviações e sem pontos (lembramos que no caso de inclusão de dependentes não poderá ser informado o nome da mãe do beneficiário, deve ser informado o nome da mãe do DEPENDENTE) (CAMPO OBRIGATÓRIO)
AADD(_aFunc,""                                             ) // PIS Com no máximo 11 caracteres, sem pontos e traços
AADD(_aFunc,""                                             ) // N° DECLARAÇÃO DE NASCIDO VIVO Para nascidos a partir de 01/01/2010
AADD(_aFunc,_cCodEmp                                       ) // CÓDIGO DA EMPRESA Preencher com o código ou identificação da sua empresa (campo obrigatório somente para movimentações de mais de uma empresa no mesmo arquivo,verifique o código da sua empresa com um representante da Operadora)
AADD(_aFunc,""                                             ) // EMAIL                                                                     
AADD(_aFunc,""                                             ) // CNS Cartão Nacional de Sáude
AADD(_aFunc,""                                             ) // MOTIVOS DE EXCLUSÃO indique a letra correspondente ao motivo da exclusão A Rompimento do contrato por iniciativa do beneficiário C Inadimplência D Óbito F Inclusão indevida de beneficiários I Aponsentado Demitido K Aponsentadoria M Demissão COM justa causa (para planos coletivos) N Demissão SEM justa causa (para planos coletivos)
AADD(_aFunc,""                                             ) // HOUVE CONTRIBUIÇÃO beneficiário contribui para o plano ?
AADD(_aFunc,""                                             ) // PERÍODO DE CONTRIBUIÇÃO tempo em que o beneficiáriuo contribui
AADD(_aFunc,""                                             ) // FOI INFORMADO DO DIREITO DE PERMANÊNCIA

AADD(_aFuncT,(_cAlias)->RA_FILIAL                          ) // FILIAL          SÓ PARA TELA 
AADD(_aFuncT,(_cAlias)->RA_NOMECMP                         ) // NOME DO TITULAR SÓ PARA TELA
FOR T := 1 TO LEN(_aFunc)
    AADD(_aFuncT,_aFunc[T])
NEXT
_aFuncT[4]:=IF(_aFuncT[4]="D","2-Dependente","1-Funcionario")
AADD(aDadosOdonto,_aFunct)// para tela

AADD(aXlsxOdonto ,_aFunc)//para gera no layout Oficial

RETURN .T.
