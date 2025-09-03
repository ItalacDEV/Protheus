/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 04/09/2024 | Chamado 48431. Jerry. Correção de error.log na função ITmsg()
Alex Wallauer | 09/09/2024 | Chamado 48431. Jerry. Correção função ITmsg() para não mostrar as mensagem somente se for MSExecAuto()
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
Lucas Borges  | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
Lucas Borges  | 01/08/2025 | Chamado 51453. Substituir função EncodeUtf8 por FWHttpEncode e removida função U_ITEncode
===============================================================================================================================
Analista      - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================
jerry         - Alex Wallauer - 17/09/24 - 20/09/24 - 47782   - Correção função ITmsg() para não da erro se for MSExecAuto() diferente do Pedido.
Jerry         - Alex Wallauer - 02/10/24 - 13/11/24 - 46161   - Mostrar os dados da aprovação do canhoto do O.L. na tela do "VISUALIZA OS DADOS DO RECEBIMENTO DO CANHOTO" (VISCANHO()).
Bremmer       - Igor Melgaço  - 14/11/24 - 14/11/24 - 49122   - Modificação na função CARCANHO para comunicação via REST.
Antonio Ramos - Igor Melgaço  - 21/11/24 - 21/11/24 - 49173   - Correção da utilização do RetSqlName("SXA").
Bremmer       - Alex Wallauer - 22/11/24 - 22/11/24 - 49203   - Correção de error.log array out of bounds [1] of [0]  na função CARCANHO para comunicação via REST.
Jerry         - Alex Wallauer - 21/11/24 - 17/01/25 - 37652   - Criação da variavel "_cCampos_F3_LSTTPA" nos F3s "LSTAGE" e "LSTTPA" para usar o F3 em qq campo de qq programa
Jerry         - Alex Wallauer - 11/12/24 - 17/01/25 - 37652   - Adicionei o F3 "ZLSTCA" na função ITF3GEN() pq a TOTVS sobrepos o F3 de "LSTCAR" no SXB.
Vanderlei     - Alex Walaluer - 17/01/25 - 17/01/25 - 49630   - Novo parametro na função ITGEREXCEL (...lComCab) para gerar o arquivo com ou sem cabeçalho.
Jerry         - Igor Melgaço  - 25/04/25 - 09/05/25 - 50065   - Ajustes para nova regra para que os títulos alocados em determinadas carteiras sejam desconsideradas da regra de bloqueio
Lucas Borges  - Lucas Borges  - 12/05/25 - 12/05/25 - 50672   - Corrigido error.log InterFunctionCall: cannot find function CLOSE in AppMap.
Andre         - Alex Wallauer - 16/05/25 - 29/05/25 - 49966   - Correção da tela da função ITmsg() para mostrar corretamente os títulos sem sobrepô-los.
Lucas Borges  - Lucas Borges  - 29/05/25 - 29/05/25 - 50833   - Inclusão do código 610111 no F3
Antonio Ramos - Igor Melgaço  - 24/02/25 - 09/06/25 - 42949   - Ajustes para consulta de limite de credito com operações 05 e 42.
Vanderlei     - Alex Wallauer - 09/06/25 - 09/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP").
Jerry         - Alex Wallauer - 17/07/25 - 05/08/25 - 37652   - Acerto da janela das mensagens da função ITMSG() para deixa a janela mais larga.
================================================================================================================================================================================================
*/ 

#Include "Protheus.ch"
#Include "Ap5Mail.Ch" 
#Include "FWMVCDef.ch"
#Include "TOPCONN.ch"
#Include "APWEBSRV.CH"  
#Include "TBICONN.CH"  

/*
===============================================================================================================================
Programa----------: ITALACXFUN
Autor-------------: Alexandre Villar
Data da Criacao---: 20/02/2014
Descrição---------: Rotinas genéricas para utilização nos desenvolvimentos
===============================================================================================================================
*/

/*
===============================================================================================================================
Programa----------: ITALACXFUN
Autor-------------: Alexandre Villar
Data da Criacao---: 20/02/2014
Descrição---------: Rotinas genéricas para utilização nos desenvolvimentos
===============================================================================================================================
*/


/*
===============================================================================================================================
Programa----------: ITALACXFUN
Autor-------------: Alexandre Villar
Data da Criacao---: 20/02/2014
Descrição---------: Rotinas genéricas para utilização nos desenvolvimentos
===============================================================================================================================
*/

/*
===============================================================================================================================
Programa--------: ITSX5GEN
Autor-----------: Alexandre Villar
Data da Criacao-: 24/02/2014
Descrição-------: Consulta genérica para tabelas do SX5
Parametros------: cTabAux := Código da Tabela no SX5
----------------: nTamAux := Tamanho da Chave para o Retorno
Retorno---------: .T. - Compatibilidade com a utilização em F3
===============================================================================================================================
*/

User Function ITSX5GEN( cTabAux , nTamAux ,nLMaxSelect)

Local cAliasX       := GetNextAlias()

Private nTam		:= 0
Private aResAux		:= {}
Private MvRet		:= Alltrim(ReadVar())
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""
Private nMaxSelect	:= 0

Default cTabAux		:= "00"
Default nTamAux		:= 2
Default nLMaxSelect := 0


#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

cTitulo	:= "Consulta Genérica SX5"
nTam	:= nTamAux

cQuery := " SELECT X5_FILIAL AS FILIAL, X5_TABELA AS TABELA,X5_CHAVE AS CHAVE,X5_DESCRI AS DESCRI   FROM "+ RetSQLName("SX5") +" WHERE D_E_L_E_T_ = ' ' " 
cQuery += " AND X5_TABELA = '" + cTabAux + "'"
		
MPSysOpenQuery( cQuery , cAliasX )
(cAliasX)->( DBGoTop() )

IF (cAliasX)->(!Eof())

	While (cAliasX)->(!Eof())
		
		nMaxSelect++
		MvParDef += PadR( (cAliasX)->CHAVE , nTam )
		aAdd( aResAux , AllTrim((cAliasX)->DESCRI) )
		
	(cAliasX)->( DBSkip() )
	EndDo
    IF nLMaxSelect <> 0
       nMaxSelect:=nLMaxSelect
    ENDIF
	//===========================================================================
	//| Mantém a marcação anterior                                              |
	//===========================================================================
	If Empty( &MvRet )                              
	
		MvPar	:= PadR( &MvRet , ( nMaxSelect * nTam ) )
		&MvRet	:= PadR( &MvRet , ( nMaxSelect * nTam ) )
	
	Else
	
		MvPar	:= &MvRet
	
	EndIf

	//===========================================================================
	//| Monta a tela de Opções genérica do Sistema                              |
	//===========================================================================
	f_Opcoes( @MvPar , cTitulo , aResAux , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )
	
	&MvRet := MvPar
	
Else

	 u_itmsg( "Não foi encontrada a Tabela informada no SX5! [Tabela: "+ cTabAux +"]" ,"Atenção",,1 )
	
EndIf

(cAliasX)->(Dbclosearea())

Return(.T.)

/*
===============================================================================================================================
Programa----------: ITInLote
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Registra o início do Lote de Processamento
Parametros--------: cAlias		- Tabela genérica de gravação dos Lotes
------------------: cOperacao	- Operação realizada no Lote
Retorno-----------: cNumLote	- Código do Lote gerado para o processamento
===============================================================================================================================
 */

User Function ITInLote( cAlias , cOperacao )

Local cNumLote 		:= ""

Default cAlias		:= ""
Default cOperacao	:= ""


(cAlias)->( DBSetOrder(1) )
(cAlias)->( DBGoTop() )

//===========================================================================
//| Recupera o próximo código disponível para o Lote                        |
//===========================================================================
cNumLote := U_ITProCod( cAlias , cAlias+"_LOTE" )

//===========================================================================
//| Registra a abertura do Lote de Processamento                            |
//===========================================================================
(cAlias)->( RecLock( cAlias , .T. ) )

	(cAlias)->&(cAlias+"_FILIAL")	:= xFilial("cAlias")
	(cAlias)->&(cAlias+"_LOTE") 	:= cNumLote
	(cAlias)->&(cAlias+"_ROTINA")	:= FunName()
	(cAlias)->&(cAlias+"_OPERAC")	:= cOperacao
	(cAlias)->&(cAlias+"_USER")		:= RetCodUsr()
	(cAlias)->&(cAlias+"_DATINI")	:= Date()
	(cAlias)->&(cAlias+"_HORINI")	:= Time()

(cAlias)->( MsUnLock() )
	
Return( cNumLote )

/*
===============================================================================================================================
Programa----------: ITFnLote
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Registra o fim do Lote de Processamento
Parametros--------: cAlias		- Tabela genérica de gravação dos Lotes
------------------: cNumLote	- Código do Lote que deverá ser encerrado
Retorno-----------: Nenhum
===============================================================================================================================
 */

User Function ITFnLote( cAlias , cNumLote )


//===========================================================================
//| Registra o encerramento do Lote de Processamento                        |
//===========================================================================
(cAlias)->( DBSetOrder(1) )
If (cAlias)->( DBSeek( xFilial(cAlias) + cNumLote ) )

	(cAlias)->( RecLock( cAlias , .F. ) ) 
	(cAlias)->&(cAlias+"_DATFIM") := Date()
	(cAlias)->&(cAlias+"_HORFIM") := Time()	
	(cAlias)->( MsUnLock() )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ITGrLote
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Registra o início do Lote de Processamento
Parametros--------: nOpc		- Número da Opção de Gravação
------------------: cNumLote	- Código do Lote
------------------: aLoteIn		- Dados para gravação do registro no Lote
------------------: cStatus		- Status do registro no Lote
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITGrLote( cAlias , cNumLote , aLoteIn , cStatus , lImporta )

Local nI			:= 0

Default cAlias		:= ""
Default cNumLote	:= ""
Default aLoteIn		:= {}
Default cStatus		:= ""
Default lImporta	:= .F.

//===========================================================================
//| Verifica os Parâmetros Iniciais para a gravação dos registros no Lote   |
//===========================================================================
IF Empty(cAlias)
	u_itmsg( "Não foi possível identificar o Alias da Tabela para registro dos dados."	, "Atenção!",,1 )
	Return()
EndIF

If Empty(cNumLote)
	u_itmsg( "Não foi possível identificar o número do lote para registro dos dados."	, "Atenção!",,1 )
	Return()
EndIf

If Empty(aLoteIn) .Or. Empty( cStatus )
	u_itmsg(  "Não foi possível identificar os dados necessários para registro no Lote."	, "Atenção!",,1 )
	Return()
EndIf

//===========================================================================
//| Processa a gravação do Lote                                             |
//===========================================================================
Do Case

	//===========================================================================
	//| Registra os itens do Lote na Tabela Z01                                 |
	//===========================================================================
	Case cAlias == "Z01"
	
		Z00->( DBSetOrder(1) )
		If !Z00->( DBSeek( xFilial("Z00") + cNumLote ) )
			//U_ITCONOUT( "Atenção: O Lote informado não existe no cadastro ou ainda não foi iniciado. [Z00-"+ cNumLote +"]" )
			Return()
		EndIf
	
		Z01->( DBSetOrder(1) )
		
		For nI := 1 To Len( aLoteIn )
		
			If Z01->( DBSeek( xFilial("Z01") + cNumLote + aLoteIn[nI][01] ) )
				Z01->( RecLock( "Z01" , .F. ) )
			Else
				Z01->( RecLock( "Z01" , .T. ) )
			EndIf				
			Z01->Z01_FILIAL		:= xFilial("Z01")
			Z01->Z01_LOTE		:= cNumLote
			Z01->Z01_CHAVE		:= aLoteIn[nI][01]
			Z01->Z01_TIPO		:= aLoteIn[nI][02]
			Z01->Z01_TPFORN		:= aLoteIn[nI][03]
			Z01->Z01_CODFOR		:= aLoteIn[nI][04]
			Z01->Z01_TPPLAN		:= aLoteIn[nI][05]
			Z01->Z01_PLANO		:= aLoteIn[nI][06]
			Z01->Z01_VERTIT		:= aLoteIn[nI][07]
			Z01->Z01_VERDEP		:= aLoteIn[nI][08]
			Z01->Z01_PERINI		:= aLoteIn[nI][09]
			Z01->Z01_DTPRO		:= Date()
			Z01->Z01_HRPRO		:= Time()
			Z01->Z01_STATUS		:= cStatus				
			Z01->( MsUnlock() )
			
		Next nI
    
	//===========================================================================
	//| Registra os itens do Lote na Tabela Z03                                 |
	//===========================================================================
	Case cAlias == "Z03"
		
		Z00->( DBSetOrder(1) )
		If !Z00->( DBSeek( xFilial("Z00") + cNumLote ) )
			//U_ITCONOUT( "Atenção: O Lote informado não existe no cadastro ou ainda não foi iniciado. [Z00-"+ cNumLote +"]" )
			Return()
		EndIf
		
		Z03->( DBSetOrder(1) )
		
		For nI := 1 To Len( aLoteIn )
			If Z03->( DBSeek( xFilial("Z03") + cNumLote + aLoteIn[nI][01] ) )
				Z03->( RecLock( "Z03" , .F. ) )
			Else
				Z03->( RecLock( "Z03" , .T. ) )
			EndIf				
			Z03->Z03_FILIAL		:= xFilial("Z03")
			Z03->Z03_LOTE		:= cNumLote
			Z03->Z03_CHAVE		:= aLoteIn[nI][01]
			Z03->Z03_DATINI		:= aLoteIn[nI][02]
			Z03->Z03_DATFIM		:= aLoteIn[nI][03]
			Z03->Z03_DATA		:= Date()
			Z03->Z03_HORA		:= Time()
			Z03->Z03_ACAO		:= aLoteIn[nI][04]
			Z03->Z03_STATUS		:= cStatus				
			Z03->( MsUnlock() )
		Next nI
	
	Case cAlias == "Z05"
		
		Z04->( DBSetOrder(1) )
		If !Z04->( DBSeek( xFilial("Z04") + cNumLote ) )
			//U_ITCONOUT( "Atenção: O Lote informado não existe no cadastro ou ainda não foi iniciado. [Z04-"+ cNumLote +"]" )
			Return()
		EndIf
		
		Z05->( DBSetOrder(1) )
		IF Z05->( DBSeek( xFilial("Z05") + aLoteIn[01][01] + aLoteIn[01][02] + aLoteIn[01][03] ) )
		
			Z05->( RecLock( "Z05" , .F. ) )
			
		Else
			
			Z05->( RecLock( "Z05" , .T. ) )
			Z05->Z05_FILIAL	:= xFilial("Z05")
			Z05->Z05_FILMAT	:= aLoteIn[01][01]
			Z05->Z05_MATRIC	:= aLoteIn[01][02]
			Z05->Z05_SEQ	:= aLoteIn[01][03]
		
		EndIF
		
		IF Z05->Z05_STATUS == "E"
			Z05->Z05_STATUS := IIF( cStatus == "0" , "R" , "P" )
		ElseIf lImporta
			Z05->Z05_STATUS := IIF( cStatus == "0" , "F" , "A" )
		Else
			Z05->Z05_STATUS := IIF( cStatus == "0" , "R" , "E" )
		EndIF
		
		Z05->Z05_ACAO	:= aLoteIn[01][04]
		Z05->Z05_TIPO	:= aLoteIn[01][05]
		Z05->Z05_DATA	:= Date()
		Z05->Z05_HORA	:= Time()		
		Z05->( MsUnLock() )
		
		Z06->( RecLock( "Z06" , .T. ) )
		Z06->Z06_FILIAL	:= xFilial("Z06")
		Z06->Z06_LOTE	:= cNumLote
		Z06->Z06_CHAVE	:= Z05->( Z05_FILMAT + Z05_MATRIC + Z05_SEQ ) 
		Z06->Z06_TIPO	:= Z05->Z05_TIPO
		Z06->Z06_ACAO	:= Z05->Z05_ACAO
		Z06->Z06_STATUS	:= Z05->Z05_STATUS
		Z06->Z06_OBS	:= PadR( aLoteIn[01][06] , 120 )
		Z06->Z06_DATA	:= Z05->Z05_DATA
		Z06->Z06_HORA	:= Z05->Z05_HORA
		Z06->( MSUnlock() )
	
EndCase

Return()

/*
===============================================================================================================================
Programa----------: ITVlLote
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Registra o fim do Lote de Processamento
Parametros--------: cAlias		- Tabela genérica de gravação dos Lotes
------------------: cNumLote	- Código do Lote que deverá ser encerrado
Retorno-----------: Nenhum
===============================================================================================================================
 */
User Function ITVlLote( cAlias , cNumLote )

//===========================================================================
//| Registra o encerramento do Lote de Processamento                        |
//===========================================================================
(cAlias)->( DBSetOrder(1) )
IF !(cAlias)->( DBSeek( xFilial(cAlias) + cNumLote ) )

	Do Case
	
		Case cAlias $ "Z01/Z03"
			
			Z00->( DBSetOrder(1) )
			IF Z00->( DBSeek( xFilial("Z00") + cNumLote ) )
				
				Z00->( RecLock( "Z00" , .F. ) )
				Z00->( DBDelete() )
				Z00->( MsUnlock() )
				
			EndIF
			
		Case cAlias $ "Z05"
			
			Z04->( DBSetOrder(1) )
			IF Z04->( DBSeek( xFilial("Z04") + cNumLote ) )
				
				Z04->( RecLock( "Z04" , .F. ) )
				Z04->( DBDelete() )
				Z04->( MsUnlock() )
				
			EndIF
			
	EndCase
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ITRetBox
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Retorna a descrição do item do Box do SX3
Parametros--------: xValor	- Valor ou Posição do Box
------------------: cCampo	- Campo do Box
Retorno-----------: cRet	- Retorna a descrição da posição do Box
===============================================================================================================================
*/
User Function ITRetBox( xValor , cCampo )

Local cRet		:= ""
Local aSX3Box   := {}
Local nPos		:= 0

//===========================================================================
//| Verifica o Campo no SX3 e recupera o Box                                |
//===========================================================================
If ValType(cCampo) == "C" .And. !Empty(cCampo)
	aSX3Box := RetSx3Box( Posicione( "SX3" , 2 , cCampo , "X3CBox()" ) ,,, 1 )
EndIf

//===========================================================================
//| Recupera a posição no Box                                               |
//===========================================================================
If !Empty(aSX3Box)
	nPos := Ascan( aSx3Box , { |aBox| AllTrim(aBox[2]) == xValor } )
EndIf

//===========================================================================
//| Recupera a descrição da posição do Box                                  |
//===========================================================================
If nPos > 0
	cRet := AllTrim( aSx3Box[nPos][03] )
EndIf

Return( cRet )

/*
===============================================================================================================================
Programa----------: ITOrdLbx
Autor-------------: Alexandre Villar
Data da Criacao---: 28/02/2014
Descrição---------: Realiza a ordenação dos conteúdos do ListBox de acordo com a coluna informada
Parametros--------: oObj	- Objeto Auxiliar
------------------: nCol	- Coluna do ListBox referência para a ordenação
------------------: oLbxAux	- Objeto do ListBox
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITOrdLbx( oObj , nCol , oLbxAux )


If Type("nITPosAnt") == "U"
	Return()
EndIf

//===========================================================================
//| Processa a ordenação dos registros com base no Header informado         |
//===========================================================================
If	nCol > 0

	If nCol <> nITPosAnt
		aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
		nITPosAnt := nCol
	Else
		aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
		nITPosAnt := 0
	EndIf

	oLbxAux:Refresh()
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ITLinDel
Autor-------------: Alexandre Villar
Data da Criacao---: 28/02/2014
Descrição---------: Retorna um Array contendo os dados do Buffer com Limitadores
Parametros--------: cBuffer		- Variável texto contendo os registros separados por delimitador
------------------: cDelimita	- Delimitador de conteúdo
Retorno-----------: aRetAux		- Array contendo os registros do Buffer
===============================================================================================================================
*/
User Function ITLinDel( cBuffer , cDelimita , nTam )

Local aRetAux		:= {}
Local cString 		:= ""       
Local cCaracter		:= ""
Local nI			:= 0

Default cDelimita	:= ""
Default nTam		:= 0

//===========================================================================
//| Registra o delimitador ao final da linha                                |
//===========================================================================
IF !Empty( cDelimita )

	IF SubStr(cBuffer,Len(cBuffer),1) != cDelimita
		cBuffer += cDelimita
	EndIf

EndIF

//===========================================================================
//| Realiza leitura do buffer e retorna os dados em um Array                |
//===========================================================================
For nI := 1 To Len(cBuffer)
    
    If !Empty( cDelimita )
    
		cCaracter := SubStr( cBuffer , nI , 1 )
		
		IF	cCaracter == cDelimita .Or. nI == Len( cBuffer )
			aAdd( aRetAux , cString )
			cString := ""
		Else
			cString += cCaracter
		EndIf

	ElseIF nTam > 0
		
		aAdd( aRetAux , SubStr( cBuffer , nI , nTam ) )
		nI += ( nTam - 1 )
		
	EndIF
	
Next nI

Return( aRetAux )

/*
===============================================================================================================================
Programa----------: ITEnvMail
Autor-------------: Alexandre Villar
Data da Criacao---: 28/02/2014
Descrição---------: Processa o envio de e-mails utilizando a configuração informada
Parametros--------: cFrom		- Conta de e-mail de origem (pode ser diferente da conta de autenticação)
------------------: cEmailTo	- Conta(s) de e-mail do(s) Destinatário(os) do e-mail
------------------: cEmailCo	- Conta(s) de e-mail que receberão em cópia
------------------: cEmailBcc	- Conta(s) de e-mail que receberão como cópia oculta
------------------: cAssunto	- Título do e-mail
------------------: cMensagem	- Mensagem do corpo do e-mail
------------------: cAttach		- Arquivo que será anexado ao e-mail
------------------: cAccount	- Conta para envio do e-mail
------------------: cPassword	- Senha da conta para envio do e-mail
------------------: cServer		- Servidor SMTP
------------------: cPortCon	- Porta de Conexão ao servidor SMTP
------------------: lRelauth	- Identifica se o servidor exige autenticação
------------------: cUserAut	- Conta para autenticação (caso não informada utiliza a conta principal)
------------------: cPassAut	- Senha para autenticação (caso não informada utiliza a senha principal)
------------------: cLogErro	- Variável para retorno das mensagens de processamento
------------------: lExibeAmb   - Quando .T. exibe ambiente do Protheus no corpo do e-mail. Quando .F. não exibe ambiente no corpo do e-mail.
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITEnvMail(cFrom,cEmailTo,cEmailCo,cEmailBcc,cAssunto,cMensagem,cAttach,cAccount,cPassword,cServer,cPortCon,lRelauth,cUserAut,cPassAut,cLogErro,lExibeAmb,_cReplyTo)

Local lResult  		:= .F.	// Se a conexao com o SMPT esta ok
Local cError   		:= ""	// String de erro
Local lRet	   		:= .F.	// Se tem autorizacao para o envio de e-mail
Local cContaMail	:= ""	// Conta de acesso 
Local cSenhaMail   	:= ""	// Senha de acesso
Local _nI, _nTamMsg, _cTextoMsg, _cTextoAmb

Default	cEmailTo	:= ""
Default	cEmailCo	:= ""
Default	cEmailBcc	:= ""
Default cAssunto	:= ""
Default cMensagem	:= ""
Default	cAttach		:= ""
Default	cAccount	:= ""
Default	cPassword	:= ""
Default	cServer  	:= ""
Default	cPortCon  	:= ""
Default	lRelauth 	:= ""
DEfault cUserAut	:= ""
Default cPassAut	:= ""
Default lExibeAmb   := .F.
Default _cReplyTo   := ""

//====================================================================================================
// Inicializa o Log de Erro Vazio
//====================================================================================================
cLogErro := ""

//====================================================================================================
// Valida se o e-mail do destinatário foi preenchido
//====================================================================================================
If Empty(cEmailTo)
	cLogErro := "O E-mail do destinatário não foi informado."
	Return()
EndIf

//====================================================================================================
// Valida as configurações para autenticação no servidor
//====================================================================================================
If ( Empty(cAccount) .Or. Empty(cPassword) )

	cLogErro := "Não foram encontradas as configurações de E-mail e Senha de envio."
	Return()
	
ElseIf Empty(cUserAut) .Or. Empty(cPassAut)

	cUserAut    := AllTrim(cAccount) 	//Usuário para Autenticação no Servidor de Email
	cPassAut    := AllTrim(cPassword)	//Senha para Autenticação no Servidor de Email
	
EndIf

//====================================================================================================
// Atualiza os dados de autenticação e conta de envio
//====================================================================================================
cContaMail	:= AllTrim( cAccount  )	// Conta de acesso
cSenhaMail	:= AllTrim( cPassword )	// Senha de acesso

//====================================================================================================
// Se a conta de 'origem' estiver vazia, utiliza a conta padrão de autenticação para o envio
//====================================================================================================
If Empty( cFrom )
	cFrom := cContaMail
EndIf

If !Empty( cPortCon )
	cServer := cServer +":"+ cPortCon
EndIf

//====================================================================================================
// Incorpora na Mensagem no nome do ambiente Protheus, caso o parâmetro lExibeAmb esteja com True(.T.) 
//====================================================================================================
If !Empty(cMensagem) .And. lExibeAmb
  
   //_nI, _nTamMsg, _cTextoMsg, _cTextoAmb
   
   _cTextoMsg := Upper(cMensagem)
   _nI := At("</BODY>",_cTextoMsg)
   If _nI > 0
      _nTamMsg := Len(cMensagem)
      _cTextoMsg := SubStr(cMensagem,1,_nI-1)
      
      _cTextoAmb := '    <tr>'
      _cTextoAmb += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
      _cTextoAmb += '      <td class="itens" align="left" > ['+ GetEnvServer() +'] </td>'
      _cTextoAmb += '    </tr>'
      
      _cTextoMsg := _cTextoMsg + _cTextoAmb + SubStr(cMensagem,_nI,_nTamMsg) 
      
      cMensagem  := _cTextoMsg 
   EndIf
   
EndIf

IF U_ITGetMV("IT_MAILULU",.T.) 
   //_cMensagem -> Mensagem do e-mail
   //_cFrom -> remetente
   //_cTO -> destinatário
   //_cCC -> Indica os e-mails para o qual se deseja enviar uma determinada mensagem. Os endereços estarão na seção 'Com Cópia' da mensagem.
   //_cBCC -> Indica os e-mails para o qual se deseja enviar uma determinada mensagem. Os endereços estarão na seção 'Com Cópia Oculta' da mensagem.
   //_cReplyTo -> Indica os endereços de e-mail que serão colocados como uma possível resposta para uma mensagem
   //_cAssunto -> Assunto
   //_cErro -> Retorna Mensagem de erro
   //_aAttach -> Lista de anexos para serem enviados
   //===============================================================================================================================
   //Retorno-----------: _lRet -> .T./.F. indica se houve sucesso no envio do e-mail
   //===============================================================================================================================
   IF EMPTY(cAttach)
      cAttach:={}
   ELSE
      IF ";" $ cAttach
         cAttach:=STRTOKARR(ALLTRIM(cAttach),";")
	  ELSE
         cAttach:={ALLTRIM(cAttach)}
	  ENDIF
   ENDIF
   
   _lEnviou:=U_EnvMail(cMensagem,cFrom,cEmailTo,cEmailCo,cEmailBcc,_cReplyTo,cAssunto,@cLogErro,cAttach)

   IF !_lEnviou
	  cLogErro := "Falha de Envio: "+ AllTrim(cLogErro)
   Else
	  cLogErro := "Sucesso: e-mail enviado corretamente!"
   ENDIF
   RETURN _lEnviou

ENDIF

cLogErro:=""
//====================================================================================================
// Abre a conexão com o servidor SMTP
//====================================================================================================
CONNECT SMTP SERVER cServer ACCOUNT cContaMail PASSWORD cSenhaMail RESULT lResult

//====================================================================================================
// Verifica se a conexão foi aberta com sucesso
//====================================================================================================
If lResult

	//====================================================================================================
	// Verifica a necessidade de autenticação no servidor
	//====================================================================================================
	If lRelauth
		lRet 	:= Mailauth(cUserAut,cPassAut)	
		lResult := .F.
	Else
		lRet := .T.
    Endif    

	//====================================================================================================
	// Processa o envio do e-mail
	//====================================================================================================
	If lRet
       cEmailTo :=STRTRAN(cEmailTo ,";",",")
       cEmailCo :=STRTRAN(cEmailCo ,";",",")
       cEmailBcc:=STRTRAN(cEmailBcc,";",",")

		SEND MAIL 	FROM 		cFrom 				;
					TO      	Lower(cEmailTo)		;
					CC     		Lower(cEmailCo)		;
					BCC     	Lower(cEmailBcc)	;
					SUBJECT 	cAssunto			;
					BODY    	cMensagem			;
					ATTACHMENT  cAttach  			;
					RESULT 		lResult
					
		If !lResult
			
		    GET MAIL ERROR cError
			cLogErro := "Falha de Envio: "+ AllTrim(cError)
		
		Else
		
			cLogErro := "Sucesso: e-mail enviado corretamente!"
			
		EndIf

	Else
		
		cLogErro := "Falha de Autenticação User: "+ AllTrim(cUserAut)+" / Verifica parametros: MV_RELAUSR / MV_RELAPSW"
		
	Endif
		
	DISCONNECT SMTP SERVER
	
Else

	GET MAIL ERROR cError
	cLogErro := "Falha de Conexão: "+ AllTrim(cError)
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: ITSelDir
Autor-------------: Alexandre Villar
Data da Criacao---: 14/03/2014
Descrição---------: Permite selecionar um diretório local
Parametros--------: Nenhum
Retorno-----------: cDir - Caminho do diretório selecionado
===============================================================================================================================
*/
User Function ITSELDIR()

Local oDlg	:= Nil
Local cDir	:= Space(150)
Local nOpc	:= 0
Local _lHtml := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml

//===========================================================================
//| Monta a tela para seleção do diretório                                  |
//===========================================================================
DEFINE MSDIALOG oDlg TITLE "Geração de Arquivo" FROM 0,0 TO 060,552 OF oDlg PIXEL

@005,005 SAY "Diretório de Destino:"	SIZE 065,010 PIXEL OF oDlg COLOR CLR_HBLUE
@014,005 MSGET cDir PICTURE "@!"		SIZE 195,010 PIXEL OF oDlg
@014,200 BUTTON "..."					SIZE 013,012 PIXEL OF oDlg ACTION cDir := cGetFile( "\" , "Selecione o Diretorio de Destino:" ,,,, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE )

@004,245 BUTTON "&Ok"					SIZE 030,011 PIXEL OF oDlg ACTION ( IIF( Empty(cDir) , u_itmsg("É obrigatório informar um diretório!","Atenção!",,1) , ( nOpc := 1 , oDlg:End() ) ) )
@016,245 BUTTON "&Cancelar"				SIZE 030,011 PIXEL OF oDlg ACTION ( nOpc := 0 , oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTER

cDir := Lower(AllTrim(cDir))

If nOpc == 1

	//===========================================================================
	//| Verifica a existência do diretório e tenta criar caso não exista        |
	//===========================================================================
	If !ExistDir(cDir) .And. ! _lHtml
	
		nCriaDir := MakeDir( cDir )
		
		If nCriaDir <> 0
		
			u_itmsg("Não foi possível criar ou utilizar o diretório:"+ CRLF + CRLF + cDir,;
					            "Alerta", " Verificar permissões para Gravação na Pasta de destino.",1)
					

			Return("")
			
		EndIf
		
	EndIf

Else

	u_itmsg( "Operação cancelada pelo usuário!" ,  "Atenção!",,1 )

EndIf

Return(cDir)

/*
===============================================================================================================================
Programa----: ITListBox
Autor-------: Alexandre Villar / Alex Wallauer
Data Criacao: 14/03/2014
Descrição---: Monta tela para exibição de Mensagem/ListBox com opção de exportação
Parametros--: _cTitAux	: Título da Janela
------------: _aHeader	: Cabeçalho do conteúdo
------------: _aCols    : Itens do conteúdo
------------: _lMaxSiz  : Define se utiliza o Listbox em tela cheia
------------: _nTipo	: Define se o ListBox é de exibição ou de seleção
------------: _cMsgTop	: Mensagem auxiliar na parte superior do Listbox
------------: _aSizes	: Tamanho das colunas do Listbox
------------: _nCampo	: Posição do Array que deve ser retornada em caso de Tela de Seleção Simples
------------: bOk	    : Codeblock do botão OK  
------------: bCancel	: Codeblock do botão Cancela
------------: _abuttons	: Para adicionar botões extras
------------: _aCab     : Cabecalho da geração do XML
------------: bDblClk   : Função executada no 2 clique da linha
------------: _aColXML  : Itens do conteúdo para gerar o XML
------------: bCondMarca: Condição para marcar uma linha
------------: _bLegenda : Code block que devolve a cor da bolinha custumizada
------------: _lHasOk   : Indica se o botão "OK" deve ser exibido.
------------: _bHeadClk : Condição ao clicar no Header
------------: _aSX1     : Array com 3 colunas dos parametros de filtro do Pergunte/ParamBox, usada na U_ITGEREXCEL()
                        - Ex.: AADD(_aPergunte,{"Pergunta 01 :',"Filiais ?","90,92" }) / Programa ROMS078.PRW
------------: _lComCab  : Indica se o cabeçalho deve ser exibido
Retorno-----: lRet	    : Caso o usuário saia da tela clicando em "Confirmar" retorna conforme o bOk senão bCancel.
===============================================================================================================================
*/
User Function ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1,_lComCab)

Local oOk			:= LoadBitmap( GetResources() , "LBOK" )
Local oNo			:= LoadBitmap( GetResources() , "LBNO" )
Local oOk2          := LoadBitmap( GetResources() , "BR_VERDE"    )
Local oNo2          := LoadBitmap( GetResources() , "BR_VERMELHO" )
Local _lRet			:= .F.
Local aCoors 		:= FWGetDialogSize(oMainWnd)
Local aSize     	:= MsAdvSize( .T. ) 
Local aObjAux		:= {}
Local aPosAux		:= {}
Local aButtons		:= {}
Local oDlg			:= Nil
Local oFont			:= Nil
Local cColsAux		:= ""
Local nI			:= 0 , _nni , _nnp
Local cPilha        := ""
Local lHtml 		:= (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
Local bType			:= {|x| Type(x)}

//Local _lVersao12    := (AllTrim(OAPP:CVERSION) = "12")
//Local bDblClk	 	:= Nil

Private oLbxAux		:= Nil
Private	nITPosAnt	:= 0
Private oSayAux     := Nil

Default _cTitAux	:= "Exibição de dados"
Default _aHeader	:= { "Falha" }
Default _aCols		:= { { "Sem conteúdo para exibir." } }
Default _lMaxSiz	:= .F.
Default _nTipo		:= 1
Default _cMsgTop	:= ""
Default _lSelUnc	:= .F.
Default _aSizes		:= {}
Default _nCampo		:= 1
Default bOk			:= {|x| _lRet := .T. , IIf( _nTipo == 2 , _aCols := oLbxAux:aArray , IIF( _nTipo == 3 , _lRet := oLbxAux:aArray[oLbxAux:nAt][_nCampo] , Nil ) ) , oDlg:End() }
Default bCancel		:= {|x| _lRet := .F. , oDlg:End() }
Default _abuttons   := {}
Default bCondMarca  := {|oLbxAux| .T. }
Default bDblClk     := {|| ITDblClk( @oLbxAux , _nTipo , _lSelUnc , bCondMarca ) }
Default _lHasOk     := .T.
Default _bHeadClk   := { |oObj,nCol| ITOrdLbx( oObj , nCol , oLbxAux , _nTipo , _lSelUnc  , bCondMarca ) }
Default _lComCab    := .T.

//==========================================================================================================
//Detecta se tela está montada, se não estiver manda U_ITCONOUT (conout italac)
//==========================================================================================================
//If !(FWIsInCallStack("MDIEXECUTE") .or. FWIsInCallStack("SIGAADV"))
If FWGetRunSchedule() .OR. GetRemoteType() == -1

	_cmens := ""
	For _nni := 1 to len(_aheader)

		_cmens := _cmens + _aheader[_nni] + " / "

	Next

	//u_itconout("Listbox - Titulo: [" + _cTitAux + "] Cabecalho: [" + _cMens + "]")
	
	For _nni := 1 to len(_acols)
	
		_cmens := ""
		
		For _nnp := 1 to len(_acols[_nni])
		
			If Valtype(_acols[_nni][_nnp]) = "C"
				_cmens := _cmens + _acols[_nni][_nnp] + " / "
			EndIf					
			
			//u_itconout("Listbox - Titulo: [" + _cTitAux + "] Linha " + strzero(_nni,6) + " : [" + _cMens + "]")

		Next
		
	Next

	_lRet := .F.

	Return _lRet
	
Endif


IF _nTipo = 4
   oOk:=oOk2
   oNo:=oNo2
ENDIF


If _lMaxSiz

	aAdd( aObjAux, { 100, 100, .T., .T. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
	aPosAux := MsObjSize( aInfo , aObjAux )

Else

	aCoors[01]	:= 000
	aCoors[02]	:= 000
	aCoors[03]	:= 400
	aCoors[04]	:= 700
	aPosAux		:= { { 002 , 002 , 186 , 350 } }
    aPosAux[01][01] += 030
	
EndIF

DEFINE FONT oFont NAME "Verdana" SIZE 05,12

nConta:=0
cProcName:="XX"
DO WHILE !EMPTY(cProcName) .AND. nConta < 25
   cProcName:=PROCNAME(nConta)
   IF !EMPTY(cProcName) .AND. !cProcName $ "ACTIVATE/FWMSGRUN/PROCESSA/__EXECUTE/FWPREEXECUTE/SIGAIXB"///SIGAADV
      aTipo:={};   aArquivo:={};   aLinha:={};   aData:={};   aHora:={}
	  aRet :=GetFuncArray( PROCNAME(nConta),aTipo,aArquivo,aLinha,aData,aHora)
      cPilha+=STRTRAN(PROCNAME(nConta),"  ","")
      IF Eval(bType,"aArquivo[1]") = "C" 
         cPilha+=" Fonte: "+aArquivo[1]
      ENDIF
      IF  Eval(bType,"aData[1]") = "D"
         cPilha+=" "+DTOC(aData[1])
      ENDIF
      IF Eval(bType,"aHora[1]") = "C" 
         cPilha+=" "+aHora[1]
      ENDIF
      IF Eval(bType,"aLinha[1]") = "C"
         cPilha+=" linha " +aLinha[1]
      ENDIF
      cPilha+=CRLF
   ENDIF
   nConta++   
ENDDO

IF VALTYPE(_aCab) <> "A"
	_aCab:={}
	For _nni := 1 to len(_aheader)
		// Alinhamento: 1-Left   ,2-Center,3-Right
		// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
		//          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza 
		Aadd(_aCab,{_aheader[_nni]     ,1           ,1         ,.F.})
	Next
ENDIF

IF VALTYPE(_aColXML) <> "A"
   _aColXML:=_aCols
ENDIF

//ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX,_lComCab
//Exportação para Excel (.XML)
AADD(aButtons,{"",{|| FWMSGRUN( ,{|_oProc| U_ITGEREXCEL(,,_cTitAux,,_aCab,_aColXML,,,,,,_aSX1,,.F.,_oProc,_lComCab),U_ITMSG("Geração Concluida!  ["+DTOC(DATE())+"] ["+TIME()+"]") },"H.I. : "+TIME()+" - Aguarde...","Gerando Excel (.XML)..."  )},"","Exportação para Excel (.XML)"  } )

//Exportação para Excel (.XLSX)
AADD(aButtons,{"",{|| FWMSGRUN( ,{|_oProc| U_ITGEREXCEL(,,_cTitAux,,_aCab,_aColXML,,,,,,_aSX1,,.T.,_oProc,_lComCab),U_ITMSG("Geração Concluida!  ["+DTOC(DATE())+"] ["+TIME()+"]") },"H.I. : "+TIME()+" - Aguarde...","Gerando Excel (.XLSX)..." )},"","Exportação para Excel (.XLSX)" } )

//Exportação para Excel (.CSV)
IF !lHtml 
   AADD(aButtons,{"",{|| FWMSGRUN( ,{|| DlgToExcel({{"ARRAY",_cTitAux,_aHeader,_aCols } }),U_ITMSG("Geração Concluida!  ["+DTOC(DATE())+"] ["+TIME()+"]") },"H.I. : "+TIME()+" - Aguarde...","Gerando Excel (.CSV)..."  )},"","Exportação para Excel (.CSV)"  } )
ENDIF    
//Exportação para Arquivo (.CSV)
AADD(aButtons,{"",{|| FWMSGRUN( ,{|| U_ITGERARQ( _cTitAux,_aHeader , _aCols              ),U_ITMSG("Geração Concluida!  ["+DTOC(DATE())+"] ["+TIME()+"]") },"H.I. : "+TIME()+" - Aguarde...","Gerando Arquivo (.CSV)...")},"","Exportação para Arquivo (.CSV)"} )

AADD(aButtons,{"",{|| U_ITMsgLog(cPilha, "PILHA DE CHAMADAS", 1, .F.) },"","Pilha de chamadas"} )

_ni := 1

Do while _ni <= len(_abuttons)

	aadd(aButtons, _abuttons[_ni])
	
	_ni++
	
Enddo

DEFINE MSDIALOG oDlg TITLE _cTitAux FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
	
	If !Empty( _cMsgTop )
		@aPosAux[01][01] , aPosAux[01][02] SAY oSayAux Var _cMsgTop OF oDlg PIXEL
		aPosAux[01][01] += 010
	EndIf
	
	@aPosAux[01][01] , aPosAux[01][02]	LISTBOX	oLbxAux						;
										FIELDS	HEADER ""					;
										ON		DblClick( Eval(bDblClk,oLbxAux) )	;
										SIZE	aPosAux[01][04] , ( aPosAux[01][03] - aPosAux[01][01] ) OF oDlg PIXEL
	                                            //Largura       , Altura
	oLbxAux:AHeaders		:= aClone( _aHeader )
	oLbxAux:bHeaderClick	:= _bHeadClk
	oLbxAux:SetArray( _aCols )
	oLbxAux:AColSizes		:= aClone( _aSizes )
	
	//===========================================================================
	//| Monta os dados para o ListBox                                           |
	//===========================================================================
	For nI := 1 To Len(_aHeader)
	
		If nI == 1
			
			If _nTipo = 2 .OR. _nTipo = 4
				cColsAux := "{|| {	IIF( _aCols[oLbxAux:nAt,"+ cValtoChar(nI) +"] , oOk , oNo ) ,"
			Else
				cColsAux := "{|| {	_aCols[oLbxAux:nAt,"+ cValtoChar(nI) +"] ,"
			EndIf
            IF VALTYPE(_bLegenda) = "B"
				cColsAux := "{|| {	EVAL(_bLegenda,_aCols,oLbxAux:nAt) ,"
            ENDIF
		ELSEIf nI == 2
			
			If _nTipo = 2 .AND. VALTYPE(_aCols[oLbxAux:nAt,2]) = "L"
				cColsAux += "	IF( _aCols[oLbxAux:nAt,"+ cValtoChar(nI) +"] , oOk2 , oNo2 ) ,"
			Else
				cColsAux += "	_aCols[oLbxAux:nAt,"+ cValtoChar(nI) +"] ,"
			EndIf			
		Else
			cColsAux += "		_aCols[oLbxAux:nAt,"+ cValtoChar(nI) +"] ,"
		EndIf
		
	Next nI
	
	//===========================================================================
	//| Atribui os dados ao ListBox                                             |
	//===========================================================================
	cColsAux		:= SubStr( cColsAux , 1 , Len(cColsAux)-1 ) + "}}"
	oLbxAux:bLine	:= &( cColsAux )

ACTIVATE MSDIALOG oDlg	ON INIT EnchoiceBar(oDlg,{ || EVAL(bOk,oDlg) },{ || EVAL(bCancel,oDlg) },,aButtons,,,,,,_lHasOk,,) CENTERED

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ITDBLCLK
Autor-------------: Alexandre Villar
Data da Criacao---: 14/03/2014
Descrição---------: Processa função do duplo click
Parametros--------: oLbxDados - Objeto de Dados do ListBox
Retorno-----------: lRet	- Caso o usuário saia da tela clicando em "Confirmar" retorna .T.
===============================================================================================================================
*/
Static Function ITDBLCLK( oLbxDados , nTipo , _lSelUnc , bCondMarca )

Local _nI			:= 0
Local _lSel			:= .T.

Default _lSelUnc	:= .F.

If nTipo == 2
	
	If _lSelUnc
		
		If oLbxDados:aArray[ oLbxDados:nAt , 01 ]
			_lSel := .T.
		Else
		
			For _nI := 1 To Len( oLbxDados:aArray )
				
				If oLbxDados:aArray[ _nI , 01 ]
				
					_lSel := .F.
					Exit
					
				EndIf
				
			Next _nI
		
		EndIf
	
	EndIf
	
	If _lSel .AND. EVAL(bCondMarca,oLbxDados,oLbxDados:nAt)
		oLbxDados:aArray[ oLbxDados:nAt , 01 ] := !oLbxDados:aArray[ oLbxDados:nAt , 01 ]
		oLbxDados:Refresh()
	EndIf

EndIf

Return()

/*
===============================================================================================================================
Programa----------: ITOrdLbx
Autor-------------: Alexandre Villar
Data da Criacao---: 14/03/2014
Descrição---------: Rotina que processa a ordenação dos dados do ListBox Genérico conforme parâmetros informados
Parametros--------: oLbxDados - Objeto de Dados do ListBox
Retorno-----------: lRet	- Caso o usuário saia da tela clicando em "Confirmar" retorna .T.
===============================================================================================================================
*/
Static Function ITOrdLbx( oX , nCol , oLbxAux , nTipo , _lSelUnc  , bCondMarca )

Local nI		:= 0
Default nTipo	:= 1

If nTipo == 2 .And. nCol == 1

	For nI := 1 To Len( oLbxAux:aArray )
		
		If _lSelUnc
			oLbxAux:aArray[nI][01] := .F.
		ElseIF EVAL(bCondMarca,oLbxAux,nI)
			oLbxAux:aArray[nI][01] := !oLbxAux:aArray[nI][01]
		EndIf
	
	Next nI

ElseIf nTipo # 4

	If	Type("nITPosAnt") == "U"
		Return()
	EndIf
	
	If	nCol > 0
		
		If nCol <> nITPosAnt
			aSort( oLbxAux:aArray ,,, { |x,y| x[nCol] < y[nCol] } )
			nITPosAnt := nCol
		Else
			aSort( oLbxAux:aArray ,,, { |x,y| x[nCol] > y[nCol] } )
			nITPosAnt := 0
		EndIf
		
	EndIf

EndIf

oLbxAux:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: ITUNQSX2
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descrição---------: Rotina de Atualização do SX2 para configuração do X2_UNICO quando chamado via MVC
Parametros--------: cAlias	- Alias da Tabela no SX2
------------------: cUnico	- Chave Unica a ser gravada na Tabela
Retorno-----------: lRet	- Informa se o processamento foi concluído com sucesso
===============================================================================================================================
*/
User Function ITUNQSX2( cAlias , cUnico )

//Local aSaveArea := GetArea()
Local lRet		:= .T.

Default cAlias	:= ""
Default cUnico	:= ""

//Eliminada funcionalidade da rotina em previsão a nova estrutura de sxs
//Mantida rotina para compatibilidade, conforme for excluida de outros fontes poderá ser excluida aqui

Return( lRet )

/*
===============================================================================================================================
Programa----------: ITVLDUSR
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descrição---------: Rotina de Atualização do SX2 para configuração do X2_UNICO quando chamado via MVC
Parametros--------: cAlias	- Alias da Tabela no SX2
------------------: cUnico	- Chave Unica a ser gravada na Tabela
Retorno-----------: lRet	- Informa se o processamento foi concluído com sucesso
===============================================================================================================================
*/
User Function ITVLDUSR( nOpc )

Local _lRet	:= .F.

ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
	
	Do Case

		//====================================================================================================
		// Verifica se usuário pode alterar o cadastro de contas de e-mail
		//====================================================================================================
		Case nOpc == 1
			_lRet := ( ZZL->ZZL_ALTEML == "S" )
		
		//====================================================================================================
		// Verifica se usuário pode alterar o cadastro de prazos de transferências
		//====================================================================================================
		Case nOpc == 2
			_lRet := ( ZZL->ZZL_ALTPRZ == "S" )
		
		//====================================================================================================
		// Verifica se usuário pode executar a rotina de Bloqueio de Clientes
		//====================================================================================================
		Case nOpc == 3
			_lRet := ( ZZL->ZZL_BLQCLI == "S" )
		
		//====================================================================================================
		// Verifica se usuário pode executar rotinas de Atualização dos dados CISP
		//====================================================================================================
		Case nOpc == 4
			_lRet := ( ZZL->ZZL_CISP == "S" )
		
		//====================================================================================================
		// Verifica se usuário pode executar rotinas de Administração de Comissões
		//====================================================================================================
		Case nOpc == 5
			_lRet := ( ZZL->ZZL_ADMCMS == "S" )
		
		//====================================================================================================
		// Verifica se usuário pode executar rotinas de Administração de Comissões
		//====================================================================================================
		Case nOpc == 6
			_lRet := ( ZZL->ZZL_METAS == "S" )
		
		//====================================================================================================
		// Verifica se usuário pode executar a rotina de Regras de Comissões
		//====================================================================================================
		Case nOpc == 7
			_lRet := ( ZZL->ZZL_REGCOM == "S" )
		
		//====================================================================================================
		// Verifica se usuário pode executar a rotina de tabela preço transferencias (xavier)
		//====================================================================================================
		Case nOpc == 8
			_lRet := ( ZZL->ZZL_PRCTRF == "1" )
		//====================================================================================================
		// Verifica se usuário pode executar a rotina gerar clientes apartir dos fornecedores (xavier)
		//====================================================================================================
		Case nOpc == 9
			_lRet := ( ZZL->ZZL_GERCLI == "1" )
		
		//====================================================================================================
		// Verifica se usuário pode fazer manutenção no cadastro de parâmetros Italac
		//====================================================================================================
		Case nOpc == 10
			_lRet := ( ZZL->ZZL_MNTPAR == "S" )
		
	EndCase
	
Else
	_lRet := .F.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ITCFGEML
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descrição---------: Retora as configurações de e-mail de acordo com o código informado
Parametros--------: cCodConf	- código da configuração de e-mail a ser obtida
Retorno-----------: aRet		- Array com os dados da configuração da conta
===============================================================================================================================
*/
User Function ITCFGEML( cConfig )

Local aConfig	:= {}

If Empty( aConfig )

	aConfig := {	GetMV( "MV_RELAUSR",, "" )	,; //Conta do E-mail
					GetMV( "MV_RELAPSW",, "" )	,; //Senha do E-mail
					GetMV( "MV_RELSERV",, "" )	,; //Servidor SMTP
					""							,; //Porta do Servidor SMTP
					GetMV( "MV_RELAUTH",, "" )	,; //SMTP requer autenticação ?
					GetMV( "MV_RELACNT",, "" )	,; //Conta para autenticação
					GetMV( "MV_RELPSW" ,, "" )	 } //Senha para autenticação
	
	If Empty(aConfig[06])
		aConfig[06] := aConfig[01]
	EndIf
	If Empty(aConfig[07])
		aConfig[07] := aConfig[02]
	EndIf
	
EndIF

Return( aConfig )

/*
===============================================================================================================================
Programa----------: ITCADHLP
Autor-------------: Alexandre Villar
Data da Criacao---: 19/03/2014
Descrição---------: Cadastra as configurações e exibe o Help na Tela
Parametros--------: aInfHelp	- Informações do Problema e da Solução
------------------: cKey		- Chave de identificação do Help
------------------: lExibe		- Define se o Help será exibido ao final do cadastro
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITCADHLP( aInfHelp , cKey , lExibe )

Local cChvHelp	:= ""
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}
Local _ni

Default aInfHelp	:= {}
Default cKey		:= ""
Default lExibe		:= .T.

If !Empty(aInfHelp) .And. !Empty(cKey)

	//===========================================================================
	//| Cadastra o Problema do Help                                             |
	//===========================================================================
	cChvHelp := "P"+ cKey
	
	For _nI := 1 To Len( aInfHelp[01] )
		AAdd( aHelpPor , aInfHelp[01][_nI] )
		AAdd( aHelpSpa , aInfHelp[01][_nI] )
		AAdd( aHelpEng , aInfHelp[01][_nI] )
	Next _nI
	
	u_ITX1Help( cChvHelp , aHelpPor , aHelpEng , aHelpSpa )
	
	//===========================================================================
	//| Cadastra a Solução do Help                                              |
	//===========================================================================
	cChvHelp	:= "S"+ cKey
	aHelpPor	:= {}
	aHelpSpa	:= {}
	aHelpEng	:= {}
	
	For _nI := 1 To Len( aInfHelp[02] )
		AAdd( aHelpPor , aInfHelp[02][_nI] )
		AAdd( aHelpSpa , aInfHelp[02][_nI] )
		AAdd( aHelpEng , aInfHelp[02][_nI] )
	Next _nI
	
	u_ITX1Help( cChvHelp , aHelpPor , aHelpEng , aHelpSpa )
	
	If lExibe
		Help( "" , 1 , cKey )
	EndIf

EndIf

Return()

/*
===============================================================================================================================
Programa----------: ITZAKSEL
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Permite selecionar setores da ZAK para o processamento
Parametros--------: Nenhum
Retorno-----------: .T. - Compatibilidade com a utilização em F3
===============================================================================================================================
*/
User Function ITZAKSEL()

Local nI			:= 0

Private nTam		:= 0
Private nMaxSelect	:= 16
Private aResAux		:= {}
Private MvRet		:= Alltrim(ReadVar())
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

cRet := ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

cTitulo	:= "Seleção de Setores"
nTam	:= TamSX3( "ZAK_COD" )[01]

ZAK->( DBSetOrder(1) )
ZAK->( DBGoTop() )
While ZAK->( !Eof() )
	
	MvParDef += ZAK->ZAK_COD
	aAdd( aResAux , AllTrim( ZAK->ZAK_DESCRI ) )
	
ZAK->( DBSkip() )
EndDo

//===========================================================================
//| Mantém a marcação anterior                                              |
//===========================================================================
If Len( AllTrim(&MvRet) ) == 0

	MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aResAux) )
	&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aResAux) )

Else

	MvPar	:= AllTrim( StrTran( &MvRet , ";" , "" ) )

EndIf

//===========================================================================
//| Monta a tela de Opções genérica do Sistema                              |
//===========================================================================
f_Opcoes( @MvPar , cTitulo , aResAux , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

//===========================================================================
//| Tratamento do retorno para separação por ";"                            |
//===========================================================================
&MvRet := ""

If !Empty(MvPar)
	
	For	nI:= 1 to Len(MvPar) Step nTam
		If !( SubStr( MvPar , nI , 1 ) $ "|*" )
			&MvRet  += SubStr(MvPar,nI,nTam) + ";"
		EndIf
	Next
	
	//===========================================================================
	//| Retira separação do último registro                                     |
	//===========================================================================
	&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1)

EndIF

Return(.T.)

/*
===============================================================================================================================
Programa----------: ITENVFTP
Autor-------------: Alexandre Villar
Data da Criacao---: 09/05/2014
Descrição---------: Rotina que processa o envio de arquivos para servidores FTP
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITENVFTP( cServer , nPorta , cUser , cPass , cPath , aArqEnv , lChgDir , cDirFtp , lViaJob )

Local aRetOk	:= {}
Local aLogErro	:= {}
Local lEnvia	:= .T.
Local nI
Local lAmbTeste :=SuperGetMV("IT_AMBTEST",.F.,.T.)

Default cServer	:= ""
Default nPorta	:= 21
Default cUser	:= ""
Default cPass	:= ""
Default cPath	:= ""
Default aArqEnv	:= {}
Default lChgDir	:= .F.
Default cDirFtp	:= ""
Default lViaJob	:= .F.

IF Empty(cServer) .Or. Empty(cUser) .Or. Empty(cPass)
	
	IF lViaJob
		//U_ITCONOUT( "Falha ao identificar os dados para Login no Servidor de FTP." )
	Else
		u_itmsg("Falha ao identificar os dados para Login no Servidor de FTP","Alerta",,1)
	EndIF
	
	Return( aRetOk )
	
EndIF

IF Empty(cPath) .Or. Empty(aArqEnv)
	
	IF lViaJob
		//U_ITCONOUT( "Falha ao identificar o diretório de origem e os arquivos a enviar." )
	Else
		u_itmsg("Falha ao identificar o diretório de origem e os arquivos a enviar.","Alerta",,1)
	EndIF
	
	Return( aRetOk )
	
EndIF

If lAmbTeste
	
	IF !lViaJob
	
		u_itmsg("A Rotina foi executada em Ambiente de Testes:   "+ GetEnvServer() +  Chr(13) + Chr(10) + Chr(13) + Chr(10)	+;
				"Não será processada a integração com o FTP!"				 			, "Atenção!" ,,3)
				
	EndIF
	
	Return( aRetOk )

EndIF

If FTPConnect( cServer , nPorta , cUser , cPass )

	IF lChgDir .And. !Empty( cDirFtp )
	
		IF !FTPDirChange( cDirFtp )
		
			IF lViaJob
			   //U_ITCONOUT( "Não foi possível acessar o diretório no FTP: "+ cDirFtp +CRLF+ "Informe a área de TI/ERP." )
			Else

				u_itmsg("Não foi possível acessar o diretório no FTP: "+ cDirFtp +CRLF+ "Informe a área de TI/ERP." +  Chr(13) + Chr(10) + Chr(13) + Chr(10)	+;
						"Informe a área de TI/ERP"				 			, "Atenção!" ,,3)
	
			EndIF
			
			lEnvia := .F.
			
		EndIF
		
	EndIF
	
	IF lEnvia
	
		FTPSetPasv( .T. )
		
		For nI := 1 to Len( aArqEnv )
		
			If FTPUpLoad( cPath + aArqEnv[nI] , aArqEnv[nI] )
			
				aAdd( aRetOk , aArqEnv[nI] )
				
			Else
			
				aAdd( aLogErro , 'Falha no UpLoad do arquivo: '+ aArqEnv[nI] )
				
			EndIF
			
		Next nI
	
	EndIF
	
	FTPDISCONNECT()
ELSE

	IF lViaJob
	  //U_ITCONOUT( "Não foi possivel onectar no FTP: FTPConnect( Sever: "+cServer+" , Porta: "+ALLTRIM(str(nPorta))+" , User: "+cUser+" , Senha: "+cPass+" )" )
	Else
	   U_ITMSG("Não foi possivel onectar no FTP: FTPConnect( Sever: "+cServer+" , Porta: "+ALLTRIM(str(nPorta))+" , User "+cUser+" , Senha: "+cPass+" )","Atenção!",;
	           "Entre em contato com a Area de TI",1)
	EndIF
	Return( aRetOk )
	
EndIf

IF !Empty( aLogErro ) .And. !lViaJob
	ITListBox( "Falhas de UpLoad" , { "Não Enviados" } , aLogErro , .F. )
EndIF

Return( aRetOk )

/*
===============================================================================================================================
Programa--------: ITSEPDEL
Autor-----------: Alexandre Villar
Data da Criacao-: 09/05/2014
Descrição-------: Rotina que separa o conteúdo da String com delimitador informado, excluindo string informada
Parametros------: cVarAux	- Texto da String Original
----------------: nTam		- Tamanho dos conteúdos a serem separados
----------------: cDelim	- Delimitador que deve ser utilizado
----------------: cExc		- Texto que deve ser excluído da String
Retorno---------: cRet		- String contendo o texto separado com o delimitador e excluidos os conteudos
===============================================================================================================================
*/
User Function ITSEPDEL( cVarAux , nTam , cDelim , cExc )

Local cRet		:= ""
Local cString	:= ""
Local cExcStr	:= ""
Local nI		:= 0

Default cVarAux	:= ""
Default nTam	:= 0
Default cDelim	:= ""
Default cExc	:= ""

IF Empty(cVarAux) .Or. Empty(cDelim) .Or. nTam <= 0
	Return( cRet )
EndIF

cExcStr := Replicate( cExc , nTam )

For nI := 1 To Len( cVarAux )
	
	cString := SubStr( cVarAux , nI , nTam )
	
	IF cString == cExcStr
		cString	:= ""
	Else
		cRet	+= cString + cDelim
	EndIF
	
	nI += ( nTam - 1 )
	
Next nI

Return( cRet )

/*
===============================================================================================================================
Programa----------: ITCONREG
Autor-------------: Alexandre Villar
Data da Criacao---: 13/05/2014
Descrição---------: Rotina que retorna a quantidade de registros contidos no Alias indicado
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITCONREG( cAlias , cTabela , cCpoFil )

Local cAliasX	:= GetNextAlias()
Local cQuery	:= ""
Local nRet		:= 0

Default cTabela := "00"
Default cCpoFil	:= ""

IF Empty(cAlias)
	Return( nRet )
EndIF

Do Case

	Case cAlias == "SM0"
	
		nRet := 100
	
	Case cAlias == "SX5"

		nRet := Len(FWGetSX5(cTabela))
	
	Case AliasInDic( cAlias )
		
		cQuery := " SELECT COUNT(*) AS TOTAL FROM "+ RetSQLName(cAlias) +" WHERE D_E_L_E_T_ = ' ' " 
		//nesse ponto o count(*) e count(r_e_c_n_o) não 
		//apresentam diferença de custo no plano de explicação do Oracle pois 
		//sempre faz fast scan devido ao índice do d_e_l_e_t
		
		IF !Empty(cCpoFil)
			cQuery += " AND "+ cCpoFil +" = '"+ xFilial(cAlias) +"' "
		EndIF
		
		MPSysOpenQuery( cQuery , cAliasX )
		(cAliasX)->( DBGoTop() )
		IF (cAliasX)->(!Eof())
			nRet := (cAliasX)->TOTAL
		EndIF
		
		(cAliasX)->( DBCloseArea() )
	
EndCase

Return( nRet )

/*
===============================================================================================================================
Programa--------: ITGENSEL
Autor-----------: Alexandre Villar
Data da Criacao-: 24/02/2014
Descrição-------: Função genérica para seleção de registros de um determinado Alias
Parametros------: cTitAux	- Título da janela
----------------: nTamAux	- Tamanho da chave do registro
----------------: cAlias	- Alias do dicionário para seleção dos dados
----------------: nIndPos	- Índice que deve ser utilizado para exibição
----------------: cCpoRet	- Campo que deve ser retornado caso selecionado o registro
----------------: cCpoDes	- Campo que contém a descrição a ser exibida para seleção
Retorno---------: aRet		- Array contendo os registros selecionados
===============================================================================================================================
 */
User Function ITGENSEL( cTitAux , nTamAux , cAlias , nIndPos , cCpoRet , cCpoDes )

Local nI			:= 0
Local aRet			:= {}

Private nTam		:= 0
Private nMaxSelect	:= 0
Private aResAux		:= {}
Private MvRet		:= "cRet"
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

cRet := ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

cTitulo	:= cTitAux
nTam	:= nTamAux

(cAlias)->( DBSetOrder(1) )
(cAlias)->( DBGoTop() )
While (cAlias)->( !Eof() )
	
	nMaxSelect++
	MvParDef += (cAlias)->&( cCpoRet )
	aAdd( aResAux , AllTrim( (cAlias)->&( cCpoDes ) ) )
	
(cAlias)->( DBSkip() )
EndDo

//===========================================================================
//| Mantém a marcação anterior                                              |
//===========================================================================
If Len( AllTrim(&MvRet) ) == 0

	MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aResAux) )
	&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aResAux) )

Else

	MvPar	:= AllTrim( StrTran( &MvRet , ";" , "" ) )

EndIf

//===========================================================================
//| Monta a tela de Opções genérica do Sistema                              |
//===========================================================================
f_Opcoes( @MvPar , cTitulo , aResAux , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

//===========================================================================
//| Tratamento do retorno para separação por ";"                            |
//===========================================================================
&MvRet := ""

If !Empty(MvPar)
	
	For	nI:= 1 to Len(MvPar) Step nTam
	
		If !( SubStr( MvPar , nI , 1 ) $ "|*" )
		
			aAdd( aRet , SubStr(MvPar,nI,nTam) )
			
		EndIf
		
	Next
	
EndIF

Return( aRet )

/*
===============================================================================================================================
Programa----------: ITIniLog
Autor-------------: Alexandre Villar
Data da Criacao---: 17/06/2014
Descrição---------: Processa gravação dos LOGS de alterações
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITIniLog( _cAliasX , _aCampos )

Local _aDadIni		:= {}
Local _cCpoAux		:= ""  , _nni
Local _astruct     := (_cAliasX)->(Dbstruct())

Default _cAliasX	:= ""

If !Empty( _cAliasX )

		For _nni := 1 to len(_astruct)
		
				If !Empty(_aCampos) .And. aScan( _aCampos , AllTrim( _astruct[_nni][1] ) ) == 0
					
					Loop
					
				Else
				
					_cCpoAux := _cAliasX +"->"+ AllTrim( _astruct[_nni][1] )
					aAdd( _aDadIni , { AllTrim( _astruct[_nni][1] ) , &_cCpoAux } )
			
				EndIf
				
		Next
	
EndIf

Return( _aDadIni )

/*
===============================================================================================================================
Programa----------: ITGrvLog
Autor-------------: Alexandre Villar
Data da Criacao---: 17/06/2014
Descrição---------: Processa gravação dos LOGS de alterações
Parametros--------: _aAux	- 
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITGrvLog( _aAux , _cAlias , _nOrdem , _cChave , _cOpcLog , _cCodUsr , _dDatLog , _cHorLog )

Local _aArea	:= GetArea()
Local _aCpoLog	:= {}

Local _cAlAux	:= GetNextAlias()
Local _cQuery	:= ''
Local _cConOrg	:= ''
Local _cConAlt	:= ''
Local _astruct  := (_calias)->( Dbstruct() )
Local _nI		:= 0
Local nConta    := 1// começa no 1 para igonorar a funcao U_ITGRVLOG
Local cPilha    := FUNNAME()

Default _aAux		:= {}
Default _dDatlog	:= Date()
Default _cHorLog	:= Time()


//Se não recebeu flag de motivo de corte preenchido como variável pública cria agora para não dar erro
If type("_cmotivs") != "C"
	_cmotivs := " "
Endif

//Se é desmembramento grava motivo específico de desmembramento
If (FWIsInCallStack("U_AOMS099")  .and. !FWIsInCallStack("U_ALTERAP")) .AND. !FWIsInCallStack("U_AOMS098")
	_cmotivs := "98"
Endif


IF EMPTY(cPilha) .OR. "RPC" $ cPilha .OR. "WORKFLOW" $ cPilha
   cPilha:=""
   cProcName:="XX"
   DO WHILE !EMPTY(cProcName) .AND. nConta < 25
      cProcName:=ALLTRIM(PROCNAME(nConta))
      IF !EMPTY(cProcName) .AND. !"{|" $ cProcName .AND.  !cProcName $ "ACTIVATE/FWMSGRUN/PROCESSA/__EXECUTE/FWPREEXECUTE/SIGAIXB/EXECBLOCK/SIGAADV/BROWSEDEF"
         cPilha+=STRTRAN(cProcName," ","")+"-"
      ENDIF
      nConta++   
   ENDDO
   cPilha:=LEFT(cPilha,LEN(cPilha)-1)
ENDIF

If _cOpcLog == 'I'
	
	Z07->( DBSetOrder(1) )
	
	For _nI := 1 To Len(_aAux)
	
		_nk := aScan( _aStruct, { |aX| alltrim(ax[1]) == alltrim(_aAux[_nI][01]) } )
		IF _nk > 0
			
			DO CASE
			
				CASE _astruct[_nk][2] == "C"
					_cConOrg := AllTrim( _aAux[_nI][02] )
					_cConAlt := AllTrim( _aAux[_nI][03] )
					
				CASE _astruct[_nk][2] == "N"
					_cConOrg := cValToChar( _aAux[_nI][02] )
					_cConAlt := cValToChar( _aAux[_nI][03] )
				
				CASE _astruct[_nk][2] == "D"
					_cConOrg := DtoC( _aAux[_nI][02] )
					_cConAlt := DtoC( _aAux[_nI][03] )
				
				CASE _astruct[_nk][2] == "L"
					_cConOrg := IIF( _aAux[_nI][02] , ".T." , ".F." )
					_cConAlt := IIF( _aAux[_nI][03] , ".T." , ".F." )
				
				CASE _astruct[_nk][2] == "M"
					_cConOrg := AllTrim( _aAux[_nI][02] )
					_cConAlt := AllTrim( _aAux[_nI][03] )
					
			ENDCASE
			
			(_cAlias)->( DBSetOrder(_nOrdem) )
			IF (_cAlias)->( DBSeek( _cChave ) )
			
				Z07->( DBSetOrder(1) ) //Z07_FILIAL + Z07_ALIAS + Z07_ORDEM + Z07_CHAVE + Z07_OPCAO + Z07_CAMPO + Z07_CODUSU + Z07_DATA + Z07_HORA
				If !Z07->( DBSeek( xFilial('Z07') + _cAlias + Str( _nOrdem , 2 , 0 ) + _cChave + _cOpcLog + _aAux[_nI][01] + _cCodUsr + DtoS(_dDatLog) + _cHorLog ) )
				
					Z07->( RecLock( "Z07" , .T. ) )
						
						Z07->Z07_FILIAL		:= xFilial("Z07")
						Z07->Z07_ALIAS		:= _cAlias
						Z07->Z07_ORDEM		:= _nOrdem
						Z07->Z07_CHAVE		:= _cChave
						Z07->Z07_OPCAO		:= _cOpcLog
						Z07->Z07_CAMPO		:= _aAux[_nI][01]
						Z07->Z07_CONORG		:= _cConOrg
						Z07->Z07_CONALT		:= _cConAlt
						Z07->Z07_CODUSU		:= _cCodUsr
						Z07->Z07_DATA		:= _dDatLog
						Z07->Z07_HORA		:= _cHorLog
					    IF Z07->(FIELDPOS("Z07_ORIGEM")) <> 0
						   Z07->Z07_ORIGEM := cPilha
						ENDIF

						
						IF _cAlias == "SC5" .or. _cAlias == "SC6"
						
							Z07->Z07_IFILIA		:= SUBSTR(_cChave,1,2)
							Z07->Z07_INUM		:= SUBSTR(_cChave,3,6)
						
						Endif
												
					Z07->( MsUnLock() )
				
				EndIf
				
			EndIF
		
		ENDIF
		
	Next _nI
	
ElseIf _cOpcLog == 'E'
	
	Z07->( DBSetOrder(1) )
	
	For _nI := 1 To Len(_aAux)
	
		_nk := aScan( _aStruct, { |aX| alltrim(ax[1]) == alltrim(_aAux[_nI][01]) } )
		IF _nk > 0
			
			DO CASE
			
				CASE _astruct[_nk][2] == "C"
					_cConOrg := AllTrim( _aAux[_nI][02] )
					_cConAlt := AllTrim( _aAux[_nI][03] )
					
				CASE _astruct[_nk][2] == "N"
					_cConOrg := cValToChar( _aAux[_nI][02] )
					_cConAlt := cValToChar( _aAux[_nI][03] )
				
				CASE _astruct[_nk][2] == "D"
					_cConOrg := DtoC( _aAux[_nI][02] )
					_cConAlt := DtoC( _aAux[_nI][03] )
				
				CASE _astruct[_nk][2] == "L"
					_cConOrg := IIF( _aAux[_nI][02] , ".T." , ".F." )
					_cConAlt := IIF( _aAux[_nI][03] , ".T." , ".F." )
				
				CASE _astruct[_nk][2] == "M"
					_cConOrg := AllTrim( _aAux[_nI][02] )
					_cConAlt := AllTrim( _aAux[_nI][03] )
					
			ENDCASE
			
			(_cAlias)->( DBSetOrder(_nOrdem) )
			IF (_cAlias)->( DBSeek( _cChave ) )
			
				Z07->( DBSetOrder(1) ) //Z07_FILIAL + Z07_ALIAS + Z07_ORDEM + Z07_CHAVE + Z07_OPCAO + Z07_CAMPO + Z07_CODUSU + Z07_DATA + Z07_HORA
				If !Z07->( DBSeek( xFilial('Z07') + _cAlias + Str( _nOrdem , 2 , 0 ) + _cChave + _cOpcLog + _aAux[_nI][01] + _cCodUsr + DtoS(_dDatLog) + _cHorLog ) )
				
					Z07->( RecLock( "Z07" , .T. ) )
						
						Z07->Z07_FILIAL		:= xFilial("Z07")
						Z07->Z07_ALIAS		:= _cAlias
						Z07->Z07_ORDEM		:= _nOrdem
						Z07->Z07_CHAVE		:= _cChave
						Z07->Z07_OPCAO		:= _cOpcLog
						Z07->Z07_CAMPO		:= _aAux[_nI][01]
						Z07->Z07_CONORG		:= _cConOrg
						Z07->Z07_CONALT		:= _cConAlt
						Z07->Z07_CODUSU		:= _cCodUsr
						Z07->Z07_DATA		:= _dDatLog
						Z07->Z07_HORA		:= _cHorLog
					    IF Z07->(FIELDPOS("Z07_ORIGEM")) <> 0
						   Z07->Z07_ORIGEM := cPilha
						ENDIF

						
						IF _cAlias == "SC5" .or. _cAlias == "SC6"
						
							Z07->Z07_IFILIA		:= SUBSTR(_cChave,1,2)
							Z07->Z07_INUM		:= SUBSTR(_cChave,3,6)
						
						Endif
						
						If (_cAlias == "SC6" .OR. _cAlias == "SC5") 
							
								Z07->Z07_IITEM := substr(_cmotivs,1,2)
							
						Endif
						
												
					Z07->( MsUnLock() )
				
				EndIf
				
			EndIF
		
		ENDIF
		
	Next _nI

ElseIf _cOpcLog == 'T'
	
	_cmotivs := "96"  //Exclusão por transferência

	Z07->( DBSetOrder(1) )
	
	For _nI := 1 To Len(_aAux)
	
		_nk := aScan( _aStruct, { |aX| alltrim(ax[1]) == alltrim(_aAux[_nI][01]) } )
		IF _nk > 0
			
			DO CASE
			
				CASE _astruct[_nk][2] == "C"
					_cConOrg := AllTrim( _aAux[_nI][02] )
					_cConAlt := AllTrim( _aAux[_nI][03] )
					
				CASE _astruct[_nk][2] == "N"
					_cConOrg := cValToChar( _aAux[_nI][02] )
					_cConAlt := cValToChar( _aAux[_nI][03] )
				
				CASE _astruct[_nk][2] == "D"
					_cConOrg := DtoC( _aAux[_nI][02] )
					_cConAlt := DtoC( _aAux[_nI][03] )
				
				CASE _astruct[_nk][2] == "L"
					_cConOrg := IIF( _aAux[_nI][02] , ".T." , ".F." )
					_cConAlt := IIF( _aAux[_nI][03] , ".T." , ".F." )
				
				CASE _astruct[_nk][2] == "M"
					_cConOrg := AllTrim( _aAux[_nI][02] )
					_cConAlt := AllTrim( _aAux[_nI][03] )
					
			ENDCASE
			
			(_cAlias)->( DBSetOrder(_nOrdem) )
			IF (_cAlias)->( DBSeek( _cChave ) )
			
				Z07->( DBSetOrder(1) ) //Z07_FILIAL + Z07_ALIAS + Z07_ORDEM + Z07_CHAVE + Z07_OPCAO + Z07_CAMPO + Z07_CODUSU + Z07_DATA + Z07_HORA
				If !Z07->( DBSeek( xFilial('Z07') + _cAlias + Str( _nOrdem , 2 , 0 ) + _cChave + _cOpcLog + _aAux[_nI][01] + _cCodUsr + DtoS(_dDatLog) + _cHorLog ) )
				
					Z07->( RecLock( "Z07" , .T. ) )
						
						Z07->Z07_FILIAL		:= xFilial("Z07")
						Z07->Z07_ALIAS		:= _cAlias
						Z07->Z07_ORDEM		:= _nOrdem
						Z07->Z07_CHAVE		:= _cChave
						Z07->Z07_OPCAO		:= _cOpcLog
						Z07->Z07_CAMPO		:= _aAux[_nI][01]
						Z07->Z07_CONORG		:= _cConOrg
						Z07->Z07_CONALT		:= _cConAlt
						Z07->Z07_CODUSU		:= _cCodUsr
						Z07->Z07_DATA		:= _dDatLog
						Z07->Z07_HORA		:= _cHorLog
					    IF Z07->(FIELDPOS("Z07_ORIGEM")) <> 0
						   Z07->Z07_ORIGEM := cPilha
						ENDIF
						
						IF _cAlias == "SC5" .or. _cAlias == "SC6"
						
							Z07->Z07_IFILIA		:= SUBSTR(_cChave,1,2)
							Z07->Z07_INUM		:= SUBSTR(_cChave,3,6)
						
						Endif
						
						If (_cAlias == "SC6" .OR. _cAlias == "SC5") 
							
								Z07->Z07_IITEM := substr(_cmotivs,1,2)
							
						Endif
						
												
					Z07->( MsUnLock() )
				
				EndIf
				
			EndIF
		
		ENDIF
		
	Next _nI

Else

	If !Empty( _aAux )
	
		
		//================================================================================
		//| Gera Array com Log dos campos que foram alterados.                           |
		//================================================================================
		If _cAlias == 'SC6'
			
			For _nI := 1 To Len( _aAux )
			    
				SC6->( DBSetOrder(1) )
				If SC6->( DBSeek( _aAux[_nI][01] ) )
				
					If	&( _cAlias +'->'+ _aAux[_nI][02] ) <> _aAux[_nI][03]
						aAdd( _aCpoLog , { _aAux[_nI][02] , _aAux[_nI][03] , &( _cAlias +'->'+ _aAux[_nI][02] ) , _aAux[_nI][01] } )
					EndIF
				
				Else
					
					If	&( _cAlias +'->'+ _aAux[_nI][02] ) <> _aAux[_nI][03]
						aAdd( _aCpoLog , { _aAux[_nI][02] , _aAux[_nI][03] , '' , _aAux[_nI][01] } )
					EndIF
					
				EndIf
			
			Next _nI
			
			SC6->( DBSetOrder(1) )
			If SC6->( DBSeek( _cChave ) )
				
				While SC6->(!Eof()) .And. SC6->( C6_FILIAL + C6_NUM ) == _cChave
				
					If ( _nI := aScan( _aAux , {|x| x[01] == SC6->( C6_FILIAL + C6_NUM + C6_ITEM )  } ) ) == 0
					
						aAdd( _aCpoLog , { 'C6_ITEM'	, NIL , SC6->C6_ITEM	, SC6->( C6_FILIAL + C6_NUM + C6_ITEM ) } )
						aAdd( _aCpoLog , { 'C6_PRODUTO'	, NIL , SC6->C6_PRODUTO	, SC6->( C6_FILIAL + C6_NUM + C6_ITEM ) } )
						aAdd( _aCpoLog , { 'C6_PRCVEN'	, NIL , SC6->C6_PRCVEN	, SC6->( C6_FILIAL + C6_NUM + C6_ITEM ) } )
						aAdd( _aCpoLog , { 'C6_TES'		, NIL , SC6->C6_TES		, SC6->( C6_FILIAL + C6_NUM + C6_ITEM ) } )
						aAdd( _aCpoLog , { 'C6_QTDVEN'	, NIL , SC6->C6_QTDVEN	, SC6->( C6_FILIAL + C6_NUM + C6_ITEM ) } )
						
					EndIf
				
				SC6->( DBSkip() )
				EndDo
				
			EndIf
			
			_cQuery := " SELECT "
			_cQuery += "     SC6.C6_ITEM, "
			_cQuery += "     SC6.C6_PRODUTO, "
			_cQuery += "     SC6.C6_PRCVEN, "
			_cQuery += "     SC6.C6_QTDVEN, "
			_cQuery += "     SC6.C6_TES, "
			_cQuery += "     SC6.C6_FILIAL || SC6.C6_NUM || SC6.C6_ITEM AS CHAVE "
			_cQuery += " FROM "+ RetSqlName('SC6') +" SC6 "
			_cQuery += " WHERE "
			_cQuery += "     SC6.C6_FILIAL = '"+ SubStr( _cChave , 1 , 2 ) +"' "
			_cQuery += " AND SC6.C6_NUM    = '"+ SubStr( _cChave , 3 , 6 ) +"' "
			_cQuery += " AND SC6.D_E_L_E_T_ = '*' "

		 	_cQuery += " AND NOT EXISTS (SELECT 'Y' FROM " + RetSqlName('SC6') + " SC6B  WHERE SC6B.D_E_L_E_T_ = ' ' AND SC6B.C6_FILIAL = SC6.C6_FILIAL AND SC6B.C6_NUM = SC6.C6_NUM "
         	_cQuery += " AND SC6B.C6_PRODUTO = SC6.C6_PRODUTO AND SC6B.C6_ITEM = SC6.C6_ITEM ) "

			_cQuery += " AND NOT EXISTS ( SELECT Z07_CHAVE FROM "+ RetSqlName('Z07') +" Z07 "
			_cQuery += "                  WHERE "
			_cQuery += "                      Z07.D_E_L_E_T_ = ' ' "
			_cQuery += "                  AND Z07.Z07_CHAVE  = C6_FILIAL || C6_NUM || C6_ITEM "
			_cQuery += "                  AND Z07.Z07_OPCAO  = 'E' ) "
			_cQuery += " ORDER BY SC6.C6_ITEM "
			
			MPSysOpenQuery( _cQuery , _cAlAux )
			(_cAlAux)->( DBGoTop() )
			
			While (_cAlAux)->(!Eof())
			
				aAdd( _aCpoLog , { 'C6_ITEM'	, (_cAlAux)->C6_ITEM	, Nil , (_cAlAux)->CHAVE } )
				aAdd( _aCpoLog , { 'C6_PRODUTO'	, (_cAlAux)->C6_PRODUTO	, Nil , (_cAlAux)->CHAVE } )
				aAdd( _aCpoLog , { 'C6_PRCVEN'	, (_cAlAux)->C6_PRCVEN	, Nil , (_cAlAux)->CHAVE } )
				aAdd( _aCpoLog , { 'C6_QTDVEN'	, (_cAlAux)->C6_QTDVEN	, Nil , (_cAlAux)->CHAVE } )
				aAdd( _aCpoLog , { 'C6_TES'		, (_cAlAux)->C6_TES		, Nil , (_cAlAux)->CHAVE } )
			
			(_cAlAux)->( DBSkip() )
			EndDo
			
			(_cAlAux)->( DBCloseArea() )
			
		Else
		
			For	_nI := 1 To Len( _aAux )
				
					If	&( _cAlias +'->'+ _aAux[_nI][01] ) <> _aAux[_nI][02]
						aAdd( _aCpoLog , { _aAux[_nI][01] , _aAux[_nI][02] , &( _cAlias +'->'+ _aAux[_nI][01] ) } )
					EndIf
				
			Next _nI
		
		EndIf
		
		//================================================================================
		//| Gravação do Log apenas dos campos que foram alterados.                       |
		//================================================================================
		IF !Empty( _aCpoLog )
			
			Z07->( DBSetOrder(1) )
			
			For _nI := 1 To Len(_aCpoLog)
			
				_nk := aScan( _aStruct, { |aX| alltrim(ax[1]) == alltrim( _aCpoLog[_nI][01] ) } )
				IF _nk > 0
					
					DO CASE
					
						CASE _astruct[_nk][2] == "C"
							_cConOrg := FwCutOff( AllTrim( _aCpoLog[_nI][02] ) )
							_cConAlt := FwCutOff( AllTrim( _aCpoLog[_nI][03] ) )
							
						CASE _astruct[_nk][2] == "N"
							_cConOrg := cValToChar( _aCpoLog[_nI][02] )
							_cConAlt := cValToChar( _aCpoLog[_nI][03] )
						
						CASE _astruct[_nk][2] == "D"
							_cConOrg := DtoC( _aCpoLog[_nI][02] )
							_cConAlt := DtoC( _aCpoLog[_nI][03] )
						
						CASE _astruct[_nk][2] == "L"
							_cConOrg := IIF( _aCpoLog[_nI][02] , ".T." , ".F." )
							_cConAlt := IIF( _aCpoLog[_nI][03] , ".T." , ".F." )
						
						CASE _astruct[_nk][2] == "M"
							_cConOrg := Transform( AllTrim( _aCpoLog[_nI][02] ) , "@!" )
							_cConAlt := Transform( AllTrim( _aCpoLog[_nI][03] ) , "@!" )
							
					ENDCASE
					
					If _cAlias == 'SC6'
						_cChave := _aCpoLog[_nI][04]
					EndIf
					
					_cOpcOrg := _cOpcLog
					
					If Empty( _cConOrg ) .AND. _cAlias == 'SC6'
						_cConOrg := 'Incluido'
						_cOpcLog := 'I'
					Elseif Empty( _cConOrg )
						_cConOrg := 'Em Branco'
						_cOpcLog := 'A'
					EndIf
					
					If Empty( _cConAlt )  .AND. _cAlias == 'SC6'
						_cConAlt := 'Excluido'
						_cOpcLog := 'E'
					Elseif Empty( _cConAlt )
						_cConOrg := 'Em Branco'
						_cOpcLog := 'A'
					EndIf
					
					Z07->( DBSetOrder(1) ) //Z07_FILIAL + Z07_ALIAS + Z07_ORDEM + Z07_CHAVE + Z07_OPCAO + Z07_CAMPO + Z07_CODUSU + Z07_DATA + Z07_HORA
					If !Z07->( DBSeek(xFilial('Z07')+_cAlias+Str(_nOrdem,2,0)+PadR(_cChave,TamSX3('Z07_CHAVE')[01])+_cOpcLog+PadR(_aCpoLog[_nI][01],TamSX3('Z07_CAMPO')[01])+_cCodUsr+DtoS(_dDatLog)+_cHorLog ) )
					
						Z07->( RecLock( "Z07" , .T. ) )
						
							Z07->Z07_FILIAL		:= xFilial("Z07")
							Z07->Z07_ALIAS		:= _cAlias
							Z07->Z07_ORDEM		:= _nOrdem
							Z07->Z07_CHAVE		:= _cChave
							Z07->Z07_OPCAO		:= _cOpcLog
							Z07->Z07_CAMPO		:= _aCpoLog[_nI][01]
							Z07->Z07_CONORG		:= _cConOrg
							Z07->Z07_CONALT		:= _cConAlt
							Z07->Z07_CODUSU		:= _cCodUsr
							Z07->Z07_DATA		:= _dDatLog
							Z07->Z07_HORA		:= _cHorLog
					        IF Z07->(FIELDPOS("Z07_ORIGEM")) <> 0
						       Z07->Z07_ORIGEM := cPilha
						    ENDIF
							
							IF _cAlias == "SC5" .or. _cAlias == "SC6"
						
								Z07->Z07_IFILIA		:= SUBSTR(_cChave,1,2)
								Z07->Z07_INUM		:= SUBSTR(_cChave,3,6)
						
							Endif

							If (_cAlias == "SC6" .OR. _cAlias == "SC5") .and. (FWIsInCallStack("U_ALTERAP") .OR. FWIsInCallStack("U_AOMS098"))

							 	Z07->Z07_IITEM := "99"

							Elseif (_cAlias == "SC6" .OR. _cAlias == "SC5") 
							
								Z07->Z07_IITEM := substr(_cmotivs,1,2)
							 	
							Endif
							
						Z07->( MsUnLock() )
					
					EndIf
						
					_cOpcLog := _cOpcOrg
				
				ENDIF
				
			Next _nI
			
		EndIF
	
	EndIf

EndIf

If _cAlias == "SC6" .or. (_cOpcLog == 'E' .and. _cAlias == "SC5") 

	_cmotivs := "  " //Zera variável pública de motivo de corte para não repetir uso por engano
	
Endif
	
RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: VldEstRetrNeg
Autor-------------: André Lisboa
Data da Criacao---: 09/06/2014
Descrição---------: Função para validar saldo em estoque para datas retroativas.
                    Necessário para evitar que haja uma saída ou estorno de entrada  e movimentando estoque com data 
                    retroativa que venha deixar o saldo negativo em alguma data posterior.
Parametros--------: cCodigo => Código do produto
					cLocal  => Almoxarifado a verifiar
					nQuant  => Quantidade do movimento para comparação de saldo suficiente
					dMovto  => Data a partir da qual vai checar se o saldo pode ficar negativo
Retorno-----------: Posição 1-Data em que os sld ficaria insuficiente, Posição 2-Saldo naquela data.
===============================================================================================================================
*/
User Function VldEstRetrNeg( cCodigo , cLocal , nQuant , dMovto )

Local aRet		:= {}
Local dData		:= StoD("")
Local aSaldos	:= { 0 }

Default cCodigo	:= ""
Default cLocal	:= ""
Default dMovto	:= dDataBase
Default nQuant	:= 0

If !Empty(cCodigo)

	For dData := dMovto To Date()
	
		aSaldos := CalcEst( cCodigo , cLocal , dData + 1 ) //obtém o saldo final em estoque na data informada
		
		If aSaldos[1] < nQuant //a quantidade requisitada não pode ser menor que o saldo da data.
			aRet := { dData , aSaldos[1] }
			Exit
		EndIf
		
	Next dData
	
EndIf

Return(aRet)

/*
===============================================================================================================================
Programa----------: ITLeCod
Autor-------------: Alexandre Villar
Data da Criacao---: 14/03/2014
Descrição---------: Rotina que exibe tela para leitura de código de barras
Parametros--------: Nenhum
Retorno-----------: cDir - Caminho do diretório selecionado
===============================================================================================================================
*/
User Function ITLeCod( nChars )

Local _oDlg			:= Nil
Local _cRet			:= Space( nChars )

//===========================================================================
//| Monta a tela para seleção do diretório                                  |
//===========================================================================
DEFINE MSDIALOG _oDlg TITLE "Leitura de Código" FROM 0,0 TO 050,210 OF _oDlg PIXEL

@005,005	MSGET _cRet PICTURE "@!" 							SIZE 100,010 PIXEL OF _oDlg VALID ( IIF( Empty(_cRet) , .F. , _oDlg:End() ) )
@005,300	BUTTON "OK"		  									SIZE 010,010 PIXEL OF _oDlg ACTION ( Nil ) //Botão apenas para disparo da função VALID
@018,005	SAY '[Digite "X" e pressione "Enter" para Sair]'	SIZE 110,010 PIXEL OF _oDlg

ACTIVATE MSDIALOG _oDlg CENTER

If Empty( _cRet )
	Return( U_ITLeCod( nChars ) )
EndIf

If AllTrim( Upper( _cRet ) ) == "X"
	_cRet := ''
EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa----------: EEmail
Autor-------------: Fabiano Dias
Data da Criacao---: 16/02/2011
Descrição---------: Função para validar se o e-mail informado é válido
Parametros--------: _cmail - E-mail a ser validado
Retorno-----------: Lógico - define se o e-mail informado possui os requisitos mínimos de validade
===============================================================================================================================
*/
User Function EEmail( _cmail )

Local _cCaracPerm	:= "ABCDEFGHIJKLMNOPQRSTUVXZWY0123456789"
Local _cCarEspPer	:= "@._-;"  
Local _cCaracter	:= _cCaracPerm + _cCarEspPer
Local _cEmail		:= Upper(AllTrim(_cmail))
Local _cEmailAux	:= ''
Local _lRet			:= .T.
Local _nQtde		:= 0
Local _nX			:= 1
Local _nI			:= 1
Local _nPosArrob	:= 0
Local _nPosPonto	:= 0

Private _aEmail		:= {}

_aEmail := StrTokarr(_cEmail,";")  

//================================================================================
// Caso o e-mail esteja em branco não valida e retorna .T. - Chamado 7767
//================================================================================
If Empty(_cEmail)
	Return( .T. ) 
EndIf

//================================================================================
// Verifica se existem caracteres que nao podem ser inseridos no campo e-mail, e 
// verifica o numero de caractres @.
//================================================================================
For _nI := 1 To Len( _aEmail )
    
	_nX := 1
	
	If _lRet
		
		_cEmailAux := AllTrim( _aEmail[_nI] )
		
		While _nX <= Len( _cEmailAux ) .And. _lRet
		
			If !( SubStr( _cEmailAux , _nX , 1 ) $ _cCaracter )
				_lRet := .F.
			EndIf
			
			If '@' == SubStr( _cEmailAux , _nX , 1 )
				_nQtde++
			EndIf
			
		_nX++
		EndDo
		
		If _lRet
		
			//================================================================================
			// Devera ser fornecido pelo  menos um '@' por e-mail
			//================================================================================
			If _nQtde == 0
				_lRet := .F.
			EndIf
			
			//================================================================================
			// Verifca se o primeiro cacter é válido
			//================================================================================
			If !( SubStr( _cEmailAux , 1 , 1 ) $ _cCaracPerm )
				_lRet := .F.
			EndIf
			
			If _lRet 
				
				//================================================================================
				// Verifica a posicao do simbolo @ dentro da string
				//================================================================================
				_nPosArrob := AT( "@" , _cEmailAux )
				
				//================================================================================
				// Verifica a posicao do simbolo @ é a primeira posição da String
				//================================================================================
				If _nPosArrob == 1
					_lRet := .F.
				EndIf
				
				//================================================================================
				// Verifica se existe o caracter '.' depois do '@'
				//================================================================================
				If !( '.' $ SubStr( _cEmailAux , _nPosArrob + 1 , Len( _cEmailAux ) ) )
					_lRet := .F.
				Else
				
					//================================================================================
					// Deve existir no minimo o caracter '.' e mais um carcter depois do .
					//================================================================================
					_nPosPonto := AT( "." , SubStr( _cEmailAux , _nPosArrob + 1 , Len( _cEmailAux ) ) )
					
					//================================================================================
					// Somatorio necessario para saber a posicao do caracter ponto depois do arroba
					//================================================================================
					_nPosPonto += _nPosArrob
					
					If _nPosPonto >= Len( _cEmailAux )
					
						_lRet := .F.
						
					Else
						
						//================================================================================
						// Deve existir no minimo um caracter entre o simbolo de @ e o primeiro '.'
						//================================================================================
						If _nPosArrob + 1 == _nPosPonto
							_lRet := .F.
						EndIf
						
					EndIf
					
					If SubStr( _cEmailAux , Len( _cEmailAux ) , 1 ) $ _cCarEspPer
						_lRet := .F.
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
Next _nI

If "ITALAC@ITALAC.COM.BR" $ _cEmail .and. _lRet

	_lRet := .F.
	
Endif	

If !_lRet .And. !FWIsInCallStack('MSEXECAUTO')
	u_itmsg( 'O e-Mail informado não é válido para o cadastro!' , 'Atenção!',,1 )
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ITZERESQ
Autor-------------: Alexandre Villar
Data da Criacao---: 28/10/2014
Descrição---------: Função para preencher campos com zeros à esquerda no momento da digitação para telas em MVC
Parametros--------: _cCntOrg  - Conteúdo digitado no campo
------------------: _cNomCpo  - Nome do Campo no Alias, exemplo: 'F2_DOC'
------------------: _cIDModel - Id do Modelo de Dados onde o campo está alocado
Retorno-----------: _cRet     - Conteúdo corrigido com os zeros à esqueda
===============================================================================================================================
*/
User Function ITZERESQ( _cCntOrg , _cNomCpo , _cIDModel )

Local _oModel	:= FWModelActive()
Local _cRet		:= PADL( ALLTRIM(_cCntOrg) , TamSX3(_cNomCpo)[01] , '0' )


If Empty( _cCntOrg )
	_cRet := ''
Else
	_oModel:LoadValue( _cIDModel , _cNomCpo , _cRet )
EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa----------: ITGERARQ
Autor-------------: Alexandre Villar
Data da Criacao---: 26/02/2015
Descrição---------: Função para gerar arquivo CSV a partir de um Array
Parametros--------: _cTitArq  - Título do arquivo
------------------: _aHeader  - Cabeçalho do arquivo
------------------: _aCols    - Dados do arquivo
Retorno-----------: Nenhum
===============================================================================================================================
 */
User Function ITGERARQ( _cTitAux , _aHeader , _aCols , _cNameFile )

Local _nHdlArq	:= 0
Local _nI		:= 0
Local _nX		:= 0
Local _cPthArq	:= ALLTRIM(GETMV("MV_RELT",,"/spool/"))//'/temp'  
Local _cPthDes	:= ''
Local _cNomArq	:= IF(_cNameFile = NIL,'PROTHEUS_'+ StrTran( Time() , ':' , '' ) + DtoS( Date() ) + RetCodUsr() +'.csv', _cNameFile+StrTran( Time() , ':' , '' )+DtoS( Date() )+RetCodUsr() +'.csv' )
Local _cArqTmp	:= _cPthArq + _cNomArq  // _cPthArq +'\'+ _cNomArq
Local _cBuffer	:= ''
Local _lHtml    :=  (GetRemoteType() == 5) // Valida se o ambiente é SmartClientHtml
Local _aConfig	:= U_ITCFGEML('')


If !Empty( _aHeader ) .And. !Empty( _aCols )
    
	_cArqTmp := Lower(_cArqTmp)

	If !ExistDir( _cPthArq )
		If MakeDir( _cPthArq ) <> 0
			u_itmsg( 'Não foi possível criar o diretório temporário para o arquivo, informe a área de TI/ERP!', "Alerta",,1  )
			Return .F.
		EndIf
	EndIf
	
	_nHdlArq := FCreate( _cArqTmp ,,, .F. )
	
	If _nHdlArq < 0
		u_itmsg(  'Não foi possível criar o arquivo no diretório temporário, informe a área de TI/ERP!' , "Alerta",,1 )
		Return .F.
	EndIf
	
	If !Empty( _cTitAux )
		FWrite( _nHdlArq , AllTrim( _cTitAux ) + CRLF )
	EndIf
	
	_cBuffer := ''
	
	For _nI := 1 To Len( _aHeader )
		_cBuffer += _aHeader[_nI] + ';'
	Next _nI
	
	FWrite( _nHdlArq , AllTrim( _cBuffer ) + CRLF )
	
	For _nI := 1 To Len( _aCols )
		
		_cBuffer := ''
		
		For _nX := 1 To Len( _aCols[_nI] )
			
			Do Case
				
				Case ValType( _aCols[_nI][_nX] ) == 'C'	; _cBuffer += _aCols[_nI][_nX]							+ ';'
				Case ValType( _aCols[_nI][_nX] ) == 'N'	; _cBuffer += cValToChar( _aCols[_nI][_nX] )			+ ';'
				Case ValType( _aCols[_nI][_nX] ) == 'L'	; _cBuffer += IIF( _aCols[_nI][_nX] , '.T.' , '.F.' )	+ ';'
				Case ValType( _aCols[_nI][_nX] ) == 'D'	; _cBuffer += DtoC( _aCols[_nI][_nX] )					+ ';'
				OtherWise								; _cBuffer += ';'
				
			EndCase
					
		Next _nX
		
		FWrite( _nHdlArq , AllTrim( _cBuffer ) + CRLF )
		
	Next _nI
	
	FClose( _nHdlArq )

    IF _cNameFile # NIL
       RETURN .T.
    ENDIF
	
	If  File( _cArqTmp )
		If ! _lHtml 
		   _cPthDes := U_ITSELDIR()//GET DO DIRETORIO DE DESTINO
		   LjMsgRun( 'Copiando o arquivo...' , 'Aguarde!' , {|| lRet:=CpyS2T( _cArqTmp , _cPthDes , .T. ) } )
		   FErase( _cArqTmp )
		Else 
           If .T.//__CopyFile( _cPthDes+"\"+_cArqTmp , "\sp ool\"+_cNomArq)// - JÁ CRIA NO SPOOL
		      _cPthArq  := _cArqTmp//"/sp ool/"+_cNomArq 
			  _cEmlLog  := "" 
              cGetPara  := UsrRetMail(__cUserID) 
			  _cGetCc   := Space(200) 
			  _cMsgEml  := "ARQUIVO GERADO ANEXO: "+_cPthArq
			  _cTitulo  := _cMsgEml
			  cGetAssun := _cTitulo + Space(200) 
			  _cFrom    := _aConfig[01] 
              //===================================================================
			  // Chama uma tela para conferência / Alteração dos dados do E-mail.  
			  //===================================================================
              If U_ITTLMAIL(@_cFrom,@cGetPara,@_cGetCc,@cGetAssun,@_cMsgEml,_cTitulo)  
                 //ITEnvMail(cFrom ,cEmailTo,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach    ,cAccount    ,cPassword   ,cServer     ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
           	     U_ITENVMAIL(_cFrom, cGetPara,_cGetCc  ,         ,cGetAssun,_cMsgEml ,_cPthArq,_aConfig[01],_aConfig[02],_aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
				 U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+"E-mail para: "+AllTrim(cGetPara)+";"+AllTrim(_cGetCc),"Envio do E-MAIL","Anexo: "+_cPthArq,3)
		         FErase( _cArqTmp )
			  Else 
                 U_ITMSG("Cancelamento do envio de E-mail para: "+AllTrim(cGetPara)+";"+AllTrim(_cGetCc),"Cancelamento de Envio do E-MAIL",,1)
			  EndIf 
		   EndIf 

		EndIf 
	Else
		u_itmsg(  'Falha no processamento do arquivo, informe a área de TI/ERP!' , "Atenção","Arquivo: "+_cArqTmp,1 )
        Return .F.
	EndIf
	
Else

	u_itmsg(  'Não foi possível verificar os dados para a geração do arquivo, não é possível criar um arquivo em branco!' ,  "Atenção",,1 )
    Return .F.
	
EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: ITVACESS
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Verifica a configuração de acessos dos usuários em tabelas de parametrização
Parametros--------: _cAlias	- Alias da tabela de parametrização
------------------: _nOrdem	- Índice para consulta na tabela pelo código do usuário
------------------: _cCampo	- Campo que será verificado
------------------: _xValOk	- Parâmetro de referência para o conteúdo a ser considerado autorizado
Retorno-----------: _lRet	- Define se o usuário tem o acesso referenciado ou se houve falha na identificação do acesso
===============================================================================================================================
*/
User Function ITVACESS( _cAlias , _nOrdem , _cCampo , _xValOk )

Local _lRet		:= .F.
//Local _aInfHlp	:= {}
Local _astruct := (_cAlias)->( Dbstruct() )

//=====================================================
//Nunca valida usuários para integração smartquestion
// e transferencias de recepcao
//=====================================================
If FWIsInCallStack("U_MGLT2JOB") .OR.  FWIsInCallStack("U_MGLT002") .OR. (FWIsInCallStack("U_AGLT003") .AND. _cAlias != 'ZLU')

	Return .T.
	
Endif

If Empty( _cCampo ) .Or. ValType( _cCampo ) <> 'C' .Or. Empty( _xValOk )
	U_ITMSG('Falha na inicialização da rotina de validação de usuários para verificar a permissão para essa operação!',"Atenção",,1)
	Return( _lRet )
EndIf

_nk := aScan( _aStruct, { |aX| alltrim(ax[1]) == alltrim( _cCampo ) } )

IF _nk > 0
		
		(_cAlias)->( DBSetOrder( _nOrdem ) )
		If (_cAlias)->( DBSeek( xFilial( _cAlias ) + RetCodUsr() ) )
			
			_lRet := ( &( _cAlias +'->'+ _cCampo ) == _xValOk )
			
		Else
						
			u_itmsg('O Usuário atual não foi cadastrado no sistema para ter acesso à rotina atual!',"Atenção",;
					 'Informe a área de TI/ERP para solicitar o acesso com o código ['+_cAlias+'].',1	)
					 
			Return( _lRet )
			
		EndIf
		
Else

		u_itmsg('Falha na inicialização da rotina de validação de usuários para verificar a permissão para essa operação!',"Atenção",,1)
		Return( _lRet )
	
EndIf

Return( _lRet )


/*
===============================================================================================================================
Programa----------: ITLSTSBM
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
Descrição---------: Consulta múltipla para o cadastro de grupos de produtos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITLSTSBM()

Local _nI			:= 0
Local _cQuery		:= ""
Local _cAlias		:= GetNextAlias()
Local _aArea 		:= GetArea()

Private nTam		:= 4
Private nMaxSelect	:= 25
Private aCat		:= {}
Private MvRet		:= Alltrim(ReadVar())
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

If Empty(MvRet) .And. FWIsInCallStack("U_AFIN004R") .And. Type("_cGrupo") == "C"  // Rotina principal desenvolvida em MVC. A função 'U_AFIN004R' não está em MVC.                 
   MvRet := "_cGrupo"                                                           // Por algum motivo a função ReadVar() não está retornando a variavel em foco. Isto está ocorrendo na P12.
EndIf

_cQuery := " SELECT "
_cQuery += "     SBM.BM_GRUPO , SBM.BM_DESC "
_cQuery += " FROM  "+ RetSqlName("SBM") +" SBM "
_cQuery += " WHERE "+ RetSqlCond('SBM')
_cQuery += " ORDER BY SBM.BM_GRUPO "

MPSysOpenQuery( _cQuery , _cAlias )

cTitulo := "Grupos de Produtos"

(_cAlias)->( DBGoTop() )
While (_cAlias)->( !Eof() )

	MvParDef  += AllTrim( (_cAlias)->BM_GRUPO )
	aAdd( aCat , AllTrim( (_cAlias)->BM_DESC  ) )

(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )

F_Opcoes(	@MvPar		,; //01 -> Variavel de Retorno
			cTitulo		,; //02 -> Titulo da Coluna com as opcoes
			aCat		,; //03 -> Opcoes de Escolha (Array de Opcoes)
			MvParDef	,; //04 -> String de Opcoes para Retorno
			12			,; //05 ->                             
			49			,; //06 -> 
			.F.			,; //07 -> Se a Selecao sera de apenas 1 Elemento por vez
			nTam		,; //08 -> Tamanho da Chave
			nMaxSelect	 ) //09 -> Quantidade máxima de registros selecionados ao mesmo tempo

&MvRet := ""

For _nI := 1 To Len( MvPar ) Step 4

	If !( SubStr( MvPar , _nI , 1 ) $ " |*" )
		&MvRet += SubStr( MvPar , _nI , 4 ) + ";"
	EndIf

Next

&MvRet := SubStr( &MvRet , 1 , Len(&MvRet) - 1 )

RestArea(_aArea)

Return(.T.)

/*
===============================================================================================================================
Programa----------: ITLSTGER
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
Descrição---------: Consulta múltipla para o cadastro de Gerentes de Vendas
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITLSTGER()

Local _nI     := 0
Local _aGeren := {}
Local _cQuery := ''
Local _cAlias := GetNextAlias()

Private nTam		:= 0
Private nMaxSelect	:= 0
Private aCat		:= {}
Private MvRet		:= Alltrim(ReadVar())
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//====================================================================================================
// Primeiro busca lista de supervisores
//====================================================================================================
_cQuery := " SELECT SA3.A3_COD FROM "+ RetSqlName('SA3') +" SA3 WHERE SA3.D_E_L_E_T_ = ' ' AND SA3.A3_I_TIPV = 'G' ORDER BY A3_COD "

MPSysOpenQuery( _cQuery , _cAlias )
(_cAlias)->( DBGoTop() )
While (_cAlias)->( !Eof() )

	aAdd( _aGeren , (_cAlias)->A3_COD )
	
(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

//====================================================================================================
// Tratamento para carregar variaveis da lista de opcoes
//====================================================================================================
nTam		:= 6
nMaxSelect	:= Len( _aGeren )
cTitulo		:= "Gerentes"

For _nI := 1 To Len( _aGeren ) 

	MvParDef += AllTrim( _aGeren[_nI] )
	aAdd( aCat , AllTrim( Posicione( 'SA3' , 1 , xFilial('SA3')+_aGeren[_nI] , 'A3_NOME' ) ) +" "+IF(SA3->A3_MSBLQL="1","( BLQ )","") )
	
Next _nI

//====================================================================================================
// Trativa abaixo para no caso de uma alteracao do campo trazer todos os dados que foram selecionados
//====================================================================================================
If Len( AllTrim( &MvRet ) ) == 0

	MvPar  := PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
	&MvRet := PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
	
Else

	MvPar := AllTrim( StrTran( &MvRet , ";" , "/" ) )

EndIf

//====================================================================================================
// Executa funcao que monta tela de opcoes
//====================================================================================================
If f_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

	//====================================================================================================
	// Tratamento para separar retorno com ";"
	//====================================================================================================
	&MvRet := ""
	
	For _nI := 1 to Len( MvPar ) step nTam
	
		If !(SubStr( MvPar , _nI , 1 ) $ " |*" )
			&MvRet += SubStr( MvPar , _nI , nTam ) +";"
		EndIf
		
	Next _nI
	
	//====================================================================================================
	// Trata para tirar o ultimo caracter
	//====================================================================================================
	&MvRet := SubStr( &MvRet , 1 , Len(&MvRet) - 1 )
	
EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: ITLSTVEN
Autor-------------: Alexandre Villar
Data da Criacao---: 06/05/2015
Descrição---------: Consulta múltipla para o cadastro de Vendedores
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITLSTVEN()

Local _nI := 0

Private nTam		:= 0
Private nMaxSelect	:= 0
Private aCat		:= {}
Private MvRet		:= Alltrim(ReadVar())
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

nTam		:= 06
nMaxSelect	:= 10
cTitulo		:= "Vendedores"

SA3->( DBSetOrder(1) )
SA3->( DBSeek( xFilial("SA3") ) )
While SA3->(!Eof()) .And. SA3->A3_FILIAL == xFilial("SA3")

	If SA3->A3_I_TIPV == 'V'
	
		MvParDef += AllTrim( SA3->A3_COD )
		aAdd( aCat , AllTrim( SA3->A3_NOME ) )
	
	EndIf
	
SA3->( DBSkip() )
EndDo

//====================================================================================================
// Trativa para no caso de uma alteracao do campo trazer todos os dados que já foram selecionados
//====================================================================================================
If Len( AllTrim( &MvRet ) ) == 0

	MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
	&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
	
Else
		
	MvPar	:= AllTrim( StrTran( &MvRet , ";" , "/" ) )

EndIf

//====================================================================================================
// Executa funcao que monta tela de opcoes
//====================================================================================================
If F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

	&MvRet := ""
	
	For _nI := 1 To Len( MvPar ) Step nTam
	
		If !( SubStr( MvPar , _nI , 1 ) $ " |*" )
			&MvRet += SubStr( MvPar , _nI , nTam ) + ";"
		EndIf
		
	Next _nI
	
	&MvRet := SubStr( &MvRet , 1 , Len( &MvRet ) - 1 )

EndIf     

Return(.T.)


/*
===============================================================================================================================
Programa----------: ITSelAmb
Autor-------------: Alexandre Villar
Data da Criacao---: 17/06/2015
Descrição---------: Rotina para utilização via F3 para seleção de módulos do Sistema
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITSELAMB( _nOpc )

Local _cCodAux	:= ''
Local _cTitAux	:= 'Selecione o módulo - Italac'
Local _aAmbPad	:= RetModName(.T.)
Local _aDadAmb	:= {}
Local _ni

For _nI := 1 To Len(_aAmbPad)
	If _nOpc == 1
		aAdd( _aDadAmb , { StrZero( _aAmbPad[_nI][01] , 2 ) , _aAmbPad[_nI][03] , _aAmbPad[_nI][02] } )
	Else
		aAdd( _aDadAmb , { .F. , StrZero( _aAmbPad[_nI][01] , 2 ) , _aAmbPad[_nI][03] , _aAmbPad[_nI][02] } )
	EndIf
Next _nI

If _nOpc == 1

	&( ReadVar() )	:= U_ITListBox( _cTitAux , {'Código','Descrição','Sigla'} , _aDadAmb , .F. , 3 ,,, {20,150,50} , 1 )

Else
	
	If U_ITListBox( 'Módulos do Sistema:' , { 'Sel' , 'Código' , 'Descrição' , 'Sigla' } , @_aDadAmb , .F. , 2 , 'Selecione os módulos desejados: ' )
		
		For _nI := 1 To Len( _aDadAmb )
			
			If _aDadAmb[_nI][01]
				_cCodAux += _aDadAmb[_nI][02] +';'
			EndIf
			
		Next _nI
		
		&( ReadVar() ) := SubStr( _cCodAux , 1 , Len(_cCodAux) - 1 )
		
	EndIf
	
EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: ITNomAmb
Autor-------------: Alexandre Villar
Data da Criacao---: 17/06/2015
Descrição---------: Rotina para retornar o nome do módulo informado
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITNOMAMB( _cCodMod )

Local _cRet		:= 'Módulo não encontrado com o código informado!'
Local _aAmbPad	:= RetModName(.T.)
Local _nPos		:= aScan( _aAmbPad , {|x| x[1] == Val(_cCodMod) } )

If _nPos > 0
	_cRet := Capital( AllTrim( _aAmbPad[_nPos][03] ) ) 
EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa--------: ITGetMV
Autor-----------: Alexandre Villar
Data da Criacao-: 17/06/2015
Descrição-------: Rotina de consulta dos parâmetros de configuração Italac - Chamado 10618
Parametros------: _cParam	- ID do Parâmetro
----------------: _cValPad	- Valor padrão a retornar caso o Parâmetro não exista
Retorno---------: _xRet		- Conteúdo referente ao parâmetro informado ou o valor padrão se o mesmo não existir
===============================================================================================================================
*/
User Function ITGetMV( _cParam , _cValPad )

Local _xRet			:= Nil
Default _cValPad	:= Nil

If Select('ZP1') = 0//Solicitado por Lucas
   IF !ChkFile('ZP1')
	  Return _cValPad
   ENDIF  	  
Endif

ZP1->( DBSetOrder(2) )
If ZP1->( DBSeek( xFilial('ZP1') + cFilAnt + _cParam ) )
	
	If ZP1->ZP1_TIPO == "C"
		_xRet := AllTrim( ZP1->ZP1_CONTEU )
	ElseIf ZP1->ZP1_TIPO == "N"
		_xRet := Val( ZP1->ZP1_CONTEU )
	ElseIf ZP1->ZP1_TIPO == "L"
		_xRet := IIF( "T" $ AllTrim( ZP1->ZP1_CONTEU ) , .T. , .F. )
	ElseIf ZP1->ZP1_TIPO == "D"
		_xRet := CtoD( ZP1->ZP1_CONTEU )
	EndIf
	
ElseIf ZP1->( DBSeek( xFilial('ZP1') + '  ' + _cParam ) )
	
	If ZP1->ZP1_TIPO == "C"
		_xRet := AllTrim( ZP1->ZP1_CONTEU )
	ElseIf ZP1->ZP1_TIPO == "N"
		_xRet := Val( ZP1->ZP1_CONTEU )
	ElseIf ZP1->ZP1_TIPO == "L"
		_xRet := IIF( "T" $ AllTrim( ZP1->ZP1_CONTEU ) , .T. , .F. )
	ElseIf ZP1->ZP1_TIPO == "D"
		_xRet := CtoD( ZP1->ZP1_CONTEU )
	EndIf

Else

	_xRet := _cValPad
	
EndIf

Return( _xRet )

/*
===============================================================================================================================
Programa----------: ITSelBox
Autor-------------: Alexandre Villar
Data da Criacao---: 06/07/2015
Descrição---------: Rotina para utilização via F3 para seleção item do box de determinado campo
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITSELBOX( _cCampo )

Local _cRet		:= ''
Local _cTitAux	:= 'Consulta padrão de opções:'
Local _aDadAmb	:= StrTokArr( AllTrim( Posicione('SX3',2, AllTrim(_cCampo) , 'X3_CBOX' ) ) , ';' )
Local _aDados	:= {}
Local _ni

For _nI := 1 To Len(_aDadAmb)
	aAdd( _aDados , { .F. , _aDadAmb[_nI] } )
Next _nI

U_ITListBox( _cTitAux , { '__' , 'Opção' } , @_aDados , .F. , 2 , 'Selecione as opções desejadas: ' )

For _nI := 1 To Len( _aDados )
	
	If _aDados[_nI][01]
		_cRet += SubStr( _aDados[_nI][02] , 1 , 1 ) + ';'
	EndIf
	
Next _nI

&( ReadVar() ) := SubStr( _cRet , 1 , Len(_cRet) - 1 )

Return(.T.)

/*
===============================================================================================================================
Programa--------: ITACSUSR
Autor-----------: Alexandre Villar
Data da Criacao-: 03/08/2015
Descrição-------: Rotina para verificar o acesso do usuário no cadastro de Gestão de Usuários
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ITACSUSR( _cCpoVld , _xValLib , _cCodUsr )

Local _xRet			:= NIL
Local _astruct      := {}
Default _cCodUsr	:= RetCodUsr()

//Carrega estrutura da tabela
If substr(_cCpoVld,1,3) == "ZZL"

	_astruct := ZZL->( Dbstruct() )
	
Else

	_astruct := ZLU->( Dbstruct() )

Endif

_nk := aScan( _aStruct, { |aX| alltrim(ax[1]) == alltrim( _cCpoVld ) } )
IF _nk > 0
	
	If substr(_cCpoVld,1,3) == 'ZZL'
	
		ZZL->( DBSetOrder(3) )
		If ZZL->( DBSeek( xFilial("ZZL") + _cCodUsr ) )
			
			If Empty( _xValLib )
				_xRet := &( "ZZL->"+ _cCpoVld )
			Else
				_xRet := &( "ZZL->"+ _cCpoVld ) == _xValLib
			EndIf
			
		Else
		
			If Empty( _xValLib )
				_xRet := &( "ZZL->"+ _cCpoVld )// O Conteudo do campo vai ser vazio pq tá em eof()
			Else
			    _xRet := .F.//0 Coloquei .F. pq nem todo o lugar esta tratando o retorno numerico = 0
			ENDIF
		
		EndIf
	
	ElseIf substr(_cCpoVld,1,3) == 'ZLU'
		
		ZLU->( DBSetOrder(1) )
		If ZLU->( DBSeek( xFilial("ZLU") + _cCodUsr ) )
			
			If Empty( _xValLib )
				_xRet := &( "ZLU->"+ _cCpoVld )
			Else
				_xRet := &( "ZLU->"+ _cCpoVld ) == _xValLib
			EndIf
			
		Else
		
			If Empty( _xValLib )
				_xRet := &( "ZLU->"+ _cCpoVld )// O Conteudo do campo vai ser vazio pq tá em eof()
			Else
			    _xRet := .F.//0 Coloquei .F. pq nem todo o lugar esta tratando o retorno numerico = 0
			ENDIF
		
		EndIf
		
	EndIf

Else

	_xRet := .F.

EndIf

Return( _xRet )

/*
===============================================================================================================================
Programa--------: ITMsHTML
Autor-----------: Darcio Ribeiro Spörl
Data da Criacao-: 31/08/2015
Descrição-------: Rotina criada para montar o código HTML da mensagem da função MESSAGEBOX
Parametros------: _aParam - Vetor com três posições, sendo a primeira contendo uma posição texto para o título da janela,
----------------:           na segunda posição um array contendo a(s) mensagem(s) referente ao problema, e na terceira posição
----------------:           um array contendo a(s) mensagem(s) referente a solução do problema, os array deverão ser preenchidos
----------------:           com uma frase em cada posição do array Ex: _aParam := {"Texto", aProb, aSoluc}
----------------:
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ITMsHTML( _aParam , _nTipo)

Local _cTit	:= _aParam[1]
Local _cRetP:= ""
Local _cRetS:= ""
Local _nI	:= 0
Local _nJ	:= 0
DEFAULT _nTipo :=1
DEFAULT _aParam:= {}
/*
_cRet := "<html>"
_cRet += "<body>"
_cRet += "<p>"
_cRet += "<strong>"
_cRet += _aParam[1] + "<br><br>"
_cRet += "</strong>"
*/
For _nI := 1 To Len(_aParam[2])
	_cRetP += _aParam[2][_nI] + "<br>"
Next _nI
/*
_cRet += "</p>"
_cRet += "<hr>"
_cRet += "<p>"
*/
For _nJ := 1 To Len(_aParam[3])
	_cRetS += _aParam[3][_nJ]
Next _nJ
/*
_cRet += "</p>"
_cRet += "</body>"
_cRet += "</html>"
*/
//MessageBox( _cRet , "Atenção" , 0 )
U_ITMSG(_cRetP,_cTit,_cRetS,_nTipo)

Return()

/*
===============================================================================================================================
Programa--------: ITVALPED
Autor-----------: Alexandre Villar
Data da Criacao-: 02/10/2015
Descrição-------: Rotina para retornar o valor total dos ítens de um pedido de compra/venda
Parametros------: _cTipPed - Tipo de Pedido: C = Compras , V = Vendas
----------------: _cFilPed - Filial do Pedido
----------------: _cNumPed - Número do Pedido
Retorno---------: _nValPed - Valor total dos ítens dos pedidos
===============================================================================================================================
*/
User Function ITVALPED( _cTipPed , _cFilPed , _cNumPed )

Local _aArea		:= GetArea()
Local _cAlias		:= ''
Local _cQuery		:= ''
Local _nValPed		:= 0

Default _cTipPed	:= ''

If Empty(_cTipPed) .Or. Empty(_cFilPed) .Or. Empty(_cNumPed)
	
	_nValPed := 0

Else
	
	If _cTipPed == "C"
	
		_cQuery := " SELECT SUM( SC7.C7_TOTAL ) AS VALOR FROM "+ RetSqlName('SC7') +" SC7 WHERE "+ RetSqlDel('SC7') +" AND SC7.C7_FILIAL = '"+ _cFilPed +"' AND SC7.C7_NUM = '"+ _cNumPed +"' "
		
	ElseIf _cTipPed == "V"
	
		_cQuery := " SELECT SUM( SC6.C6_VALOR ) AS VALOR FROM "+ RetSqlName('SC6') +" SC6 WHERE "+ RetSqlDel('SC6') +" AND SC6.C6_FILIAL = '"+ _cFilPed +"' AND SC6.C6_NUM = '"+ _cNumPed +"' "
		
	EndIf
	
	_cAlias := GetNextAlias()
	
	MPSysOpenQuery( _cQuery , _cAlias )
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->( !Eof() ) .And. (_cAlias)->VALOR > 0
		_nValPed := (_cAlias)->VALOR
	Else
		_nValPed := 0
	EndIf
	
	(_cAlias)->( DBCloseArea() )
	
EndIf

RestArea( _aArea )

Return( _nValPed )

/*
===============================================================================================================================
Programa--------: ITUSRLOG
Autor-----------: Alexandre Villar
Data da Criacao-: 08/10/2015
Descrição-------: F3 para consultar usuários cadastrados para as rotinas de Logística
Parametros------: Nenhum
Retorno---------: _lRet - Define se o F3 foi confirmado
===============================================================================================================================
*/
User Function ITUSRLOG()

Local _lRet	   	:= .F.
Local _nRet 	:= 0
Local _cQuery  	:= ""

_cQuery := " SELECT "
_cQuery += " 	ZZL.ZZL_CODUSU , ZZL.ZZL_NOME , ZZL.ZZL_PRGLOG , ZZL.R_E_C_N_O_ AS REGZZL "
_cQuery += " FROM  "+ RetSQLName("ZZL") +" ZZL "
_cQuery += " WHERE "+ RetSqlCond('ZZL')
_cQuery += " AND   ZZL.ZZL_PRGLOG = '2' "

If Tk510F3Qry( _cQuery , "ZZL_01" , "REGZZL" , @_nRet ,, { "ZZL_CODUSU" , "ZZL_NOME" } , "ZZL" )
	ZZL->( DBGoto( _nRet ) )
	_lRet := .T.
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: LstNat
Autor-----------: Alexandre Villar
Data da Criacao-: 18/03/2015
Descrição-------: Função genérica que permite selecionar uma lista de naturezas
Parametros------: Nenhum
Retorno---------: _lRet - Compatibilidade com o F3
===============================================================================================================================
*/
User Function LstNat()

Local i           := 0
Private nTam      := 0
Private nMaxSelect:= 0
Private aCat      := {}
Private MvRet     := Alltrim(ReadVar())
Private MvPar     := ""
Private cTitulo   := ""
Private MvParDef  := ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//Tratamento para carregar variaveis da lista de opcoes
nTam       :=6
//nMaxSelect := 14 //14 * 7 = 98 (cod(6) +";") = 7
nMaxSelect := 10 //75 / 7
cTitulo    :="Naturezas"
                 
SED->(dbSetOrder(1))      
SED->(dbGotop())

while SED->(!Eof())      

	MvParDef += AllTrim(SED->ED_CODIGO)
	aAdd(aCat,AllTrim(SED->ED_DESCRIC))
	
	SED->(dbSkip())   
enddo              

//====================================================================
//Trativa abaixo para no caso de uma alteracao do campo trazer todos
//os dados que foram selecionados anteriormente.                    
//====================================================================
If Len(AllTrim(&MvRet)) == 0                              

	MvPar:= PadR(AllTrim(StrTran(&MvRet,";","")),Len(aCat))
	&MvRet:= PadR(AllTrim(StrTran(&MvRet,";","")),Len(aCat))
	
Else
		
	MvPar:= AllTrim(StrTran(&MvRet,";","/"))

EndIf

//=============================================================
//Somente altera o conteudo caso o usuario clique no botao ok
//=============================================================
If f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.,nTam,nMaxSelect)        

	//Tratamento para separar retorno com barra ";"
	&MvRet := ""
	for i:=1 to Len(MvPar) step nTam
		if !(SubStr(MvPar,i,1) $ " |*")
			&MvRet  += SubStr(MvPar,i,nTam) + ";"
		endIf
	next i
	
	//Trata para tirar o ultimo caracter
	&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1) 

EndIf     

Return(.T.)

/*
===================================================================================================================================================================================================
Programa--------: ITF3GEN
Autor-----------: Alexandre Villar
Data da Criacao-: 22/03/2015
Descrição-------: Função genérica que permite selecionar uma lista de itens conforme configuração informada
Parametros-------:
01 _cNomeSXB-----: Opção do Case               DEFAULT: 'F3_GENER'           Ex.: "F3_GENER"
02 _cTabela------: Nome da Tabela              DEFAULT: ''                   Ex.: "SA2" ou um "SELECT * FROM SA2010'"
03 _nCpoChave----: Posição do Campo Chave      DEFAULT: 2                    Ex.: SA2->(FIELDPOS("A2_COD")) ou {|| SA2->A2_COD+" "+SA2->A2_LOJA }
04 _nCpoDesc-----: Posição do Campo Descrição  DEFAULT: 3                    Ex.: SA2->(FIELDPOS("A2_NREDUZ")) ou {|| SA2->A2_NREDUZ }
05 _bCondTab-----: CodeBlock de Exceção        DEFAULT: {|| .T. }            Ex.: {|| SA3->A3_MSBLQL <> '1' }
06 _cTitAux------: Titulo da Janela            DEFAULT: ''                   Ex.: "Tipos de Informação"
07 _nTamChv------: Tamanho do Campo Chave      DEFAULT: 1                    Ex.: LEN(SA2->A2_COD)
08 _aDados-------: Array com as descrições     DEFAULT: {}                   Ex.: Função que retorna uma array (_aDados) ou uma String: "V=VENDA;R=REMESSA;O=OUTROS"
09 _nMaxSel------: Quantidade de Seleção       DEFAULT: 0 (Todos)            Ex.: LEN(_aDados) ou 10
10 _lFilAtual----: Opção de ler as Filiais     DEFAULT: .T.                  Ex.: .T. : Le a Filial Atual , .F. : Le Todas as Filiais
11 _cMVRET-------: Nome do campo do ReadVar()  DEFAULT: Alltrim( ReadVar() ) Ex.: "MV_PAR01"
12 _bValida------: Executado antes da Tela     DEFAULT: {|| .T. }            Ex.: {|| IF(LEN(_aDados) > 0 , .T. , .F. ) }
13 _oProc--------: Obejeto do da função FWMSGRUN()
14 _aParam-------: Array equivalente a array _aItalac_F3 abaixo
  _aItalac_F3----: Array Private iniciada no rdmake/PE com os 12 parametros de cada campo OU parametro (MV_PAR??) na tela do rdmake/PE, pergunte OU Parambox e usar o F3 'F3ITLC' 
  Ex.: _aItalac_F3:={}         1           2         3           4           5          6           7         8          9         10         11        12       13        14
       AADD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela ,_nCpoChave , _nCpoDesc , _bCondTab , _cTitAux , _nTamChv , _aDados , _nMaxSel , _lFilAtual,_cMVRET,_bValida, _oProc , _aParam)
       AADD(_aItalac_F3,{"2CPO_CAMPO2",_cTabela ,_nCpoChave , _nCpoDesc , _bCondTab , _cTitAux , _nTamChv , _aDados , _nMaxSel , _lFilAtual,_cMVRET,_bValida, _oProc , _aParam})
Retorno---------: _lRet - Compatibilidade com o F3
===================================================================================================================================================================================================*/
//                          1           2         3           4           5          6           7         8          9         10           11        12        13       14
User Function ITF3GEN( _cNomeSXB , _cTabela ,_nCpoChave , _nCpoDesc , _bCondTab , _cTitAux , _nTamChv , _aDados , _nMaxSel , _lFilAtual , _cMVRET , _bValida , _oProc , _aParam )
Local _lRet			:= .F.
Local _aDadAux		:= {}
Local _cQuery		:= ''
Local _cAlias		:= ''
Local _cCodAux		:= ''
Local _cParDef		:= ''
Local _nI			:= 0
Local _cCombo		:= ""
Local _cTiposRef , _nX , nPosFil , _nConta:=0

Public _cRetorno	:= ""

DEFAULT _cNomeSXB := 'F3_GENER'
DEFAULT	_cTabela  := ''
DEFAULT	_nCpoChave:= 2
DEFAULT	_nCpoDesc := 3
DEFAULT	_bCondTab := {|| .T. }
DEFAULT	_cTitAux  := ''
DEFAULT	_nTamChv  := 1
DEFAULT	_aDados   := {}
DEFAULT	_nMaxSel  := 0
DEFAULT	_lFilAtual:= .T.
DEFAULT	_cMVRET	  := Alltrim( ReadVar() )
DEFAULT	_bValida  := {|| .T. }

IF TYPE("_cSeparador") <> "C"
   PRIVATE _cSeparador:=";"
ENDIF 

IF !EMPTY(_cTabela) .AND. _cTabela = "SA3" 
   IF _nMaxSel = 0
      _nMaxSel:= 14//Limitado a 14 pq é a quantidade codigos (cod(6)+";") que cabem em 99 caracteres  //(cod(6)+";") = 7 // 14 * 7 = 98 que cabem em 99
   ELSEIF _nMaxSel < 0 //=-1  para os F3s Novos: LSTVE1-Lista Vendedores e LSTSU1-Lista de Coordenador
      _nMaxSel:= 0//Com zero ele pega o limite total
   ENDIF
ENDIF 

Do Case

	//====================================================================================================
	// Monta estrutura de seleção DAS PLAMILHAS GERADAS PELO MEST009.PRW
	//====================================================================================================
	Case _cNomeSXB = 'F3_GENER'
        IF TYPE("_aParam") = "A"
           _aItalac_F3:=ACRONE(_aParam)
	    ENDIF 
                                    //_aItalac_F3:={}        1           2         3           4           5          6           7         8          9         10         11      12
        IF TYPE("_aItalac_F3") = "A"//AADD(_aItalac_F3,{"TST_CAMPO",_cTabela ,_nCpoChave , _nCpoDesc , _bCondTab , _cTitAux , _nTamChv , _aDados , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
		   FOR _nI := 1 TO LEN(_aItalac_F3)
               IF UPPER(_cMVRET) == UPPER(_aItalac_F3[_ni,1])
                  IF(_aItalac_F3[_ni,02] # NIL  , _cTabela:=_aItalac_F3[_ni,02],)
                  IF(LEN(_aItalac_F3[_ni]) > 02 .AND. _aItalac_F3[_ni,03] # NIL ,_nCpoChave:=_aItalac_F3[_ni,03],)
                  IF(LEN(_aItalac_F3[_ni]) > 03 .AND. _aItalac_F3[_ni,04] # NIL ,_nCpoDesc :=_aItalac_F3[_ni,04],)
                  IF(LEN(_aItalac_F3[_ni]) > 04 .AND. _aItalac_F3[_ni,05] # NIL ,_bCondTab :=_aItalac_F3[_ni,05],)
                  IF(LEN(_aItalac_F3[_ni]) > 05 .AND. _aItalac_F3[_ni,06] # NIL ,_cTitAux  :=_aItalac_F3[_ni,06],)
                  IF(LEN(_aItalac_F3[_ni]) > 06 .AND. _aItalac_F3[_ni,07] # NIL ,_nTamChv  :=_aItalac_F3[_ni,07],)
                  IF(LEN(_aItalac_F3[_ni]) > 07 .AND. _aItalac_F3[_ni,08] # NIL ,_aDados   :=_aItalac_F3[_ni,08],)
                  IF(LEN(_aItalac_F3[_ni]) > 08 .AND. _aItalac_F3[_ni,09] # NIL ,_nMaxSel  :=_aItalac_F3[_ni,09],)
                  IF(LEN(_aItalac_F3[_ni]) > 09 .AND. _aItalac_F3[_ni,10] # NIL ,_lFilAtual:=_aItalac_F3[_ni,10],)
                  IF(LEN(_aItalac_F3[_ni]) > 10 .AND. _aItalac_F3[_ni,11] # NIL ,_cMVRET   :=_aItalac_F3[_ni,11],)
                  IF(LEN(_aItalac_F3[_ni]) > 11 .AND. _aItalac_F3[_ni,12] # NIL ,_bValida  :=_aItalac_F3[_ni,12],)
               ENDIF
           NEXT
        ENDIF

        IF !EVAL(_bValida,"A",_aDados)//ANTES
           RETURN _cRetorno
        ENDIF

		IF !EMPTY(_cTabela)//TABELAS

           IF VALTYPE(_cTabela) = "B" .OR. "SELECT" $ _cTabela

		      _cAlias := GetNextAlias()
              IF VALTYPE(_cTabela) = "B" 
                 _cTabela:=EVAL(_cTabela)//Para os casos que o select dependa dos outros parametros
              ENDIF

			  MPSysOpenQuery( _cTabela , _cAlias )
              DBSELECTAREA(_cAlias)//NÃO TIRAR
		      (_cAlias)->(DBGOTOP())
		      _lFilAtual:=.F.
		      _cTabela:=_cAlias
		   ELSE
		      DBSELECTAREA(_cTabela)//NÃO TIRAR
		      (_cTabela)->(DBGOTOP())
		      IF _lFilAtual
		         DBSeek( xFilial(_cTabela) ) 
		      ENDIF   
	          nPosFil:=FIELDPOS(IF(LEFT(_cTabela,1)="S",SUBSTR(_cTabela,2),_cTabela )+"_FILIAL")
           ENDIF

		   DO WHILE !EOF() .AND. (IF(_lFilAtual, (FIELDGET(nPosFil) == xFilial(_cTabela)) ,.T.))
		      IF EVAL(_bCondTab)
                 IF VALTYPE(_oProc) = "O"
                    _nConta++
                    _oProc:cCaption := ("Lendo dados da "+_cTabela+": "+ALLTRIM(STR(_nConta)))
                    ProcessMessages()
                 ENDIF   
                 IF VALTYPE(_nCpoChave) = "B"
		            _cParDef +=EVAL(_nCpoChave,_cTabela)
                 ELSEIF _lFilAtual
		            _cParDef +=FIELDGET(_nCpoChave)
		         ELSE   
		            _cParDef +=FIELDGET(nPosFil) + FIELDGET(_nCpoChave)
		         ENDIF   
                 IF VALTYPE(_nCpoDesc) = "B"
		            AADD( _aDados , EVAL(_nCpoDesc,_cTabela) )
                 ELSE
		            AADD( _aDados , STRTRAN(AllTrim( FIELDGET(_nCpoDesc) ),"-"," ") )//tira os traços da Descricao para não dar erro no F3 , pois traço (-) é caracter reservado nesse F3 
		         ENDIF   
		      ENDIF   
		      DBSKIP()
		   ENDDO
           IF VALTYPE(_nCpoChave) = "B"
		      DBSELECTAREA(_cTabela)//NÃO TIRAR
		      DBGOTOP() 
		      _nTamChv:=LEN(EVAL(_nCpoChave,_cTabela))
           ELSEIF _lFilAtual
		      _nTamChv:=LEN(FIELDGET(_nCpoChave))
		   ELSE
		      _nTamChv:=LEN(FIELDGET(nPosFil)+FIELDGET(_nCpoChave))
		   ENDIF   
		   IF _nMaxSel = 0
		      _nMaxSel  := LEN(_aDados)
		   ENDIF   
		   IF EMPTY(_cTitAux)
	         _cTitAux:=ALLTRIM(FWX2Nome(_cTabela))
		   ENDIF

		ELSEIF !EMPTY(_aDados)//ARRAYS
           
           IF VALTYPE(_aDados) = "C"
		      _aDados := STRTOKARR(_aDados, ';')
		   ENDIF   
		   IF EMPTY(_cTitAux)
	          _cTitAux:="Lista de Opcoes"
		   ENDIF
		   IF _nMaxSel = 0
		      _nMaxSel  := LEN(_aDados)
		   ENDIF   
		   FOR _ni := 1 TO LEN(_aDados)
              IF VALTYPE(_oProc) = "O"
                 _nConta++
                 _oProc:cCaption := ("Lendo "+_cTitAux+": "+ALLTRIM(STR(_nConta))+" de "+ALLTRIM(STR(_nMaxSel)))
                 ProcessMessages()
              ENDIF   
			  _cParDef += SUBSTR(_aDados[_ni],1,_nTamChv)
		   NEXT	

        ENDIF

        IF !EVAL(_bValida,"D",_aDados)//DEPOIS
           RETURN _cRetorno
        ENDIF

	Case _cNomeSXB == 'TPEMBS'

		_aDados:=U_SubEmbagem(_cMVRET,.T.)
        IF LEN(_aDados) = 0
		   U_ITMSG("Não tem sub nivel para a conbinção de niveis anteriores",'Atenção!',,3) // ALERT
		   Return .T.
		ENDIF

		_nTamChv:= 1
		_cTitAux:= "Sub Tipos de Embalagens"
		_nMaxSel:= 1

		For _ni := 1 to LEN(_aDados)
			_cParDef += SUBSTR(_aDados[_ni],1,1)
		Next	

	Case _cNomeSXB == 'LSTME9'
		
		// Mont8a estrutura dos dados
		_nTamChv	:= 02
		_cTitAux	:= "Planilhas disponiveis para Geração"
		
		_aDados := U_MEST9Plan()//Função no MEST009.PRW
		_nMaxSel:= LEN(_aDados)
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += SUBSTR(_aDados[_ni],1,_nTamChv)

		Next	

	//====================================================================================================
	// Monta estrutura de seleção DOS TIPOS DO CAMPO ZL6_OBSERV INFORMAÇÃO MEST009.PRW
	//====================================================================================================
	Case _cNomeSXB == 'LSTMT9'
		
		// Monta estrutura dos dados
		_nTamChv:= 01
		_cTitAux:= "Tipos de Informação"
		
		_aDados := U_MEST9Info()//Função no MEST009.PRW
		_nMaxSel:= 1
		
		For _ni := 1 TO LEN(_aDados)
			_cParDef += SUBSTR(_aDados[_ni],1,_nTamChv)
		Next	

	//=======================================================================================================
    // Monta estrutura de seleção de Filial - Projeto de unificação de pedidos de troca nota - Chamado 16548      
	//=======================================================================================================
	Case _cNomeSXB $ "LSTSM0,LSTFAT,LSTZZM,ZLSTCA,LSTCAR"// Adicionei o F3 "ZLSTCA" pq a TOTVS sobrepos o F3 de "LSTCAR" no SXB.
		
		IF _cNomeSXB $ "LSTSM0,LSTFAT,LSTZZM"
		   _cFilTpLista_:="FAT"
		ELSE//ZLSTCA,LSTCAR
		   _cFilTpLista_:="CAR"
		ENDIF
		
		IF _cNomeSXB = "LSTZZM"
		   _nMaxSeLista_:=40
		ELSE
		   _nMaxSeLista_:=1
		ENDIF
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados
		//----------------------------------------------------------------------------------------------------
		_nTamChv  := 02
		_nMaxSel  := _nMaxSeLista_
		_cTitAux  := 'Filial'
        _cFilSalva:= cFilAnt
		_nRecZZM  := ZZM->( Recno() )

		ZZM->( DBGoTop() )
		DO While ZZM->(!Eof()) 
		
           cFilAnt:=ZZM->ZZM_CODIGO
		
           If _cFilTpLista_ = "FAT" .AND. Alltrim(U_ITGETMV( "IT_FATNF" , "N")) == "S"    // Filiais de Faturamento
		      _cParDef += AllTrim( ZZM->ZZM_CODIGO )
		      aAdd( _aDados , AllTrim( ZZM->ZZM_DESCRI ) )
           ELSEIf _cFilTpLista_ = "CAR" .AND. Alltrim(U_ITGETMV( "IT_PRONF" , "N")) == "S"// Filiais de Carregamento
		      _cParDef += AllTrim( ZZM->ZZM_CODIGO )
		      aAdd( _aDados , AllTrim( ZZM->ZZM_DESCRI ) )
           ENDIF
		
		   ZZM->( DBSkip() )
		EndDo
		ZZM->( DBGoTo(_nRecZZM) )
        cFilAnt:= _cFilSalva

	//====================================================================================================
	// Monta estrutura de seleção para tipos de CFOP de acordo com a ZAY
	//====================================================================================================
	Case _cNomeSXB == 'LSTTCF'
	
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os tipos de CFOP de acordo com a ZAY
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 10
		_cTitAux	:= "CFOP X Tipo de Operacao"
		
		
		//procura opções no combo da ZAY
		SX3-> ( dbSetOrder(2) )
		
		if SX3->( dbSeek("ZAY_TPOPER"))
		
			_cCombo := X3Cbox()

		else
		
			_cCombo := "V=VENDA;T=TRANSFERENCIA;B=BONIFICACAO;R=REMESSA;O=OUTROS"
		
		endif
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	
	
	//====================================================================================================
	// Monta estrutura de seleção para campos de tabela de preço
	//====================================================================================================
	Case _cNomeSXB == 'LSTCMP'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os campos de tabela de preço
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 10
		_cTitAux	:= "Campos de preço"
		
		_cCombo := "1=PRECO MINIMO DO PORTAL;2=PRECO MINIMO PROTHEUS;3=PRECO MAXIMO PROTHEUS;4=PRECO MAXIMO PERSON"
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	
			
    //====================================================================================================
	// Monta estrutura de seleção para tabelas de preço.
	//====================================================================================================
	Case _cNomeSXB == 'LSTDA0'
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Status de Ocorrência de Frete
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 03
		_nMaxSel	:= 20
		_cTitAux	:= 'Tabelas de preço'
		
		DA0->( DBSetOrder(1) )
		DA0->( DBGoTop() )
		 _acods := {}
		
		While DA0->(!Eof()) 
		
		   
		   If ascan(_acods,AllTrim( DA0->DA0_CODTAB )) == 0
		   
		   		 _cParDef += AllTrim( DA0->DA0_CODTAB ) 	
		   		aAdd( _aDados , AllTrim( DA0->DA0_DESCRI ) )
		   		aadd(_acods,AllTrim( DA0->DA0_CODTAB ))
		   	
		   Endif
		
		   DA0->( DBSkip() )
		EndDo    		
	
	//====================================================================================================
	// Monta estrutura de seleção para status de ocorrência de frete
	//====================================================================================================
	Case _cNomeSXB == 'LSTZFD'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os status de ocorrências de frete
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 05
		_cTitAux	:= "Status de ocorrência de frete"
		
		_cCombo := "P=PENDENTE;T=TRATAMENTO;N=NAO PROCEDE;E=ENCERRADO"
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)

			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	
		
    //====================================================================================================
	// Monta estrutura de seleção para status de ocorrência de frete. Segundo tipo de consulta.
	//====================================================================================================
	Case _cNomeSXB == 'LSZFD2'
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Status de Ocorrência de Frete
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 06
		_nMaxSel	:= 18
		_cTitAux	:= 'Status de Ocorrência de Frete'
		
		ZFD->( DBSetOrder(1) )
		ZFD->( DBGoTop() )
		ZFD->( DBSeek( xFilial("ZFD") ) )
		While ZFD->(!Eof()) .And. ZFD->ZFD_FILIAL == xFilial("ZFD")
		
		   _cParDef += AllTrim( ZFD->ZFD_CODIGO )
		   aAdd( _aDados , AllTrim( ZFD->ZFD_DESCRI ) )
		
		   ZFD->( DBSkip() )
		EndDo    		

	Case _cNomeSXB == 'LSTTPF'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos dos tipos de cargas
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 01
		_nMaxSel := 09
		_cTitAux := "Tipos de Carga"
		
		SX3->( DBSetOrder(2) )
		If SX3->( DBSeek("C5_TPFRETE") )
			_cCodAux := AllTrim( X3Cbox() )
		EndIf
		
		//====================================================================================================
		// A funcao STRTOKARR() tem o objetivo de retornar um array com as opções
		//====================================================================================================
		_aDadAux := STRTOKARR( _cCodAux , ';' )
		
		For _nI := 1 to Len( _aDadAux )
		
			_cCodAux := AllTrim( _aDadAux[_nI] )
			_cParDef += SubStr( _cCodAux , 1 , AT( "=" , _cCodAux ) - 1 )
			
			aAdd( _aDados , Right(_cCodAux,Len(_cCodAux) - RAT("=",_cCodAux)) )
		
		Next _nI

	
	
	//====================================================================================================
	// Monta estrutura de seleção para tipos de ocorrência de frete
	//====================================================================================================
	Case _cNomeSXB == 'LSTZFC'
	
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos dos tipos de ocorrência de frete
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 06
		_nMaxSel	:= 15
		_cTitAux	:= 'Tipos de ocorrências de frete'
		
		ZFC->( DBSetOrder(1) )
		ZFC->( DBSeek( xFilial("ZFC") ) )
		While ZFC->(!Eof()) .And. ZFC->ZFC_FILIAL == xFilial("ZFC")
		
			_cParDef += AllTrim( ZFC->ZFC_CODIGO )
			aAdd( _aDados , AllTrim( ZFC->ZFC_DESC ) )
		
		ZFC->( DBSkip() )
		EndDo
	
	//====================================================================================================
    // Monta estrutura de seleção para operações - LSTZB4
	//====================================================================================================
	Case _cNomeSXB == 'LSTZB4'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos das Redes
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 02
		_nMaxSel	:= 10
		_cTitAux	:= 'Operacao'
		
		ZB4->( DBSetOrder(1) )
		ZB4->( DBSeek( xFilial("ZB4") ) )
		While ZB4->(!Eof()) .And. ZB4->ZB4_FILIAL == xFilial("ZB4")
		
			_cParDef += AllTrim( ZB4->ZB4_COD )
			aAdd( _aDados , AllTrim( ZB4->ZB4_DESCRI ) )
		
		ZB4->( DBSkip() )
		EndDo
	
	

	//====================================================================================================
	// Monta estrutura de seleção para Redes - LSTRED
	//====================================================================================================
	Case _cNomeSXB == 'LSTRED'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos das Redes
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 06
		_nMaxSel	:= 14//Limitado a 14 pq é a quantidade codigos (cod(6)+";") que cabem em 99 caracteres  //(cod(6)+";") = 7 // 14 * 7 = 98
		_cTitAux	:= 'Redes'
		
		ACY->( DBSetOrder(1) )
		ACY->( DBSeek( xFilial("ACY") ) )
		While ACY->(!Eof()) .And. ACY->ACY_FILIAL == xFilial("ACY")
		
			_cParDef += AllTrim( ACY->ACY_GRPVEN )
			aAdd( _aDados , AllTrim( ACY->ACY_DESCRI ) )
		
		ACY->( DBSkip() )
		EndDo
		
	//====================================================================================================
	// Monta estrutura de seleção para Vendedores - LSTVEN
	//====================================================================================================
	Case _cNomeSXB == 'LSTVEN'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos dos Vendedores
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 06
		_nMaxSel := 10
		_cTitAux := "Vendedores"
		
		SA3->( DBSetOrder(2) ) // A3_FILIAL+A3_NOME 
		While SA3->(!Eof()) .And. SA3->A3_FILIAL == xFilial('SA3')
		 
			If SA3->A3_MSBLQL <> '1'
			
				_cParDef += AllTrim( SA3->A3_COD )
				aAdd( _aDados , AllTrim( SA3->A3_NOME ) )
				
			EndIf
		
		   SA3->( DBSkip() )
		EndDo
		
	//====================================================================================================
	// Monta estrutura de seleção para Supervisores de Vendas - LSTSUP
	//====================================================================================================
	Case _cNomeSXB == 'LSTSUP'
		
		//----------------------------------------------------------------------------------------------------
		// Primeiro busca lista de supervisores
		//----------------------------------------------------------------------------------------------------
		_cQuery := " SELECT DISTINCT SA3.A3_COD AS CODSUP, A3_NOME "
		_cQuery += " FROM  "+ RetSqlName('SA3') +" SA3 "
		_cQuery += " WHERE "+ RetSqlCond('SA3')
		_cQuery += " AND SA3.A3_I_TIPV = 'C' "  // (SA3.A3_I_TIPV = 'C' OR SA3.A3_I_TIPV = 'G')
		_cQuery += " ORDER BY A3_NOME, SA3.A3_COD "
				
		_cAlias := GetNextAlias()
		
		MPSysOpenQuery( _cQuery , _cAlias )
		(_cAlias)->( DBGoTop() )
		While (_cAlias)->(!Eof())
			aAdd( _aDadAux , (_cAlias)->CODSUP )
		    (_cAlias)->( DBSkip() )
		EndDo
		
		(_cAlias)->( DBCloseArea() )
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos dos Supervisores
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 06
		_nMaxSel := 10
		_cTitAux := "Supervisores"
		
		SA3->( DBSetOrder(1) )
		For _nI := 1 To Len( _aDadAux )
		
			If SA3->( DBSeek( xFilial("SA3") + _aDadAux[_nI] ) )
			
				_cParDef += AllTrim( SA3->A3_COD )
				aAdd( _aDados , AllTrim( SA3->A3_NOME ) )
				
			EndIf
			
		Next _nI
		
	//====================================================================================================
	// Monta estrutura de seleção para Grupos de Produtos - LSTGRP
	//====================================================================================================
	Case _cNomeSXB == 'LSTGRP'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos dos Grupos de Produtos
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 04
		_nMaxSel := 30
		_cTitAux := "Grupos de Produtos"
		
		SBM->( DBSetOrder(1) )
		SBM->( DBSeek( xFilial("SBM") ) )
		While SBM->( !eof() ) .And. SBM->BM_FILIAL == xFilial("SBM")
		
			_cParDef += AllTrim( SBM->BM_GRUPO )
			aAdd( _aDados , AllTrim( SBM->BM_DESC ) )
			
		SBM->( DBSkip() )
		EndDo
		
	//====================================================================================================
	// Monta estrutura de seleção para o nível 2 de Grupos de Produtos - LSTN2
	//====================================================================================================
	Case _cNomeSXB == 'LSTN2'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos de nível 2 dos Grupos de Produtos
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 03
		_nMaxSel := 18
		_cTitAux := "Nivel 2 - Grupos de Produtos"
		
		ZA1->( DBSetOrder(1) )
		ZA1->( DBSeek( xFilial("ZA1") ) )
		While ZA1->(!Eof()) .And. ZA1->ZA1_FILIAL == xFilial("ZA1")
		
			_cParDef += AllTrim( ZA1->ZA1_COD )
			aAdd( _aDados , AllTrim( ZA1->ZA1_DESCRI ) )
			
		ZA1->( DBSkip() )
		EndDo
		
	//====================================================================================================
	// Monta estrutura de seleção para o nível 3 de Grupos de Produtos - LSTN3
	//====================================================================================================
	Case _cNomeSXB == 'LSTN3'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos de nível 3 dos Grupos de Produtos
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 02
		_nMaxSel := 25
		_cTitAux := "Nivel 3 - Grupos de Produtos"
		
		ZA2->( DBSetOrder(1) )
		ZA2->( DBSeek( xFilial("ZA2") ) )
		While ZA2->(!Eof()) .And. ZA2->ZA2_FILIAL == xFilial("ZA2")
		
			_cParDef += AllTrim( ZA2->ZA2_COD )
			aAdd( _aDados , AllTrim( ZA2->ZA2_DESCRI ) )
			
		ZA2->( DBSkip() )
		EndDo
	
	//====================================================================================================
	// Monta estrutura de seleção para relógios SP0
	//====================================================================================================
	Case _cNomeSXB == 'LSTSP0'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos de relógio da SP0
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 03
		_nMaxSel := 25
		_cTitAux := "Equipamentos de ponto"
		
		SP0->( DBSetOrder(1) )
		SP0->( DBSeek( xFilial("SP0") ) )
		While SP0->(!Eof()) .And. SP0->P0_FILIAL == xFilial("SP0")
		
			_cParDef += AllTrim( SP0->P0_RELOGIO )
			aAdd( _aDados , AllTrim( SP0->P0_DESC ) )
			
		SP0->( DBSkip() )
		EndDo
	
	//====================================================================================================
	// Monta estrutura de seleção para relógios SP0
	//====================================================================================================
	Case _cNomeSXB == 'LS2SP0'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos de relógio da SP0
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 03
		_nMaxSel := 25
		_cTitAux := "Equipamentos ControlID"
		
		SP0->( DBSetOrder(1) )
		SP0->( DBSeek( xFilial("SP0") ) )
		While SP0->(!Eof()) 
		
			If (SP0->P0_I_CTRID == 'W' .OR. SP0->P0_I_CTRID == 'A') .AND. SP0->P0_I_IP > ' ' ;
									.AND. (SP0->P0_I_TIPO == 'R' .OR. SP0->P0_I_TIPO == 'C') .AND. SP0->P0_CONTROL == 'P' .AND. SP0->P0_FILIAL == cFilAnt
		
					_cParDef += AllTrim( SP0->P0_RELOGIO )
					aAdd( _aDados , AllTrim( SP0->P0_DESC ) )
					
			Endif
			
		SP0->( DBSkip() )
		EndDo
		
	//====================================================================================================
	// Monta estrutura de seleção para o nível 4 de Grupos de Produtos - LSTN4
	//====================================================================================================
	Case _cNomeSXB == 'LSTN4'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os Códigos de nível 4 dos Grupos de Produtos
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 02
		_nMaxSel := 25
		_cTitAux := "Nivel 4 - Grupos de Produtos"
		
		ZA3->( DBSetOrder(1) )
		ZA3->( DBSeek( xFilial("ZA3") ) )
		While ZA3->(!Eof()) .And. ZA3->ZA3_FILIAL == xFilial("ZA3")
		
			_cParDef += AllTrim( ZA3->ZA3_COD )
			aAdd( _aDados , AllTrim( ZA3->ZA3_DESCRI ) )
			
		ZA3->( DBSkip() )
		EndDo
		
	//====================================================================================================
	// Monta estrutura de seleção para siglas de estados (UF) - LSTEST
	//====================================================================================================
	Case _cNomeSXB == 'LSTEST'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com as siglas de estados (UF)
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 02
		_cTitAux := "Estados (UF)"
		cAliasX  := GetNextAlias()
		
		
		cQuery := " SELECT X5_FILIAL AS FILIAL, X5_TABELA AS TABELA,X5_CHAVE AS CHAVE,X5_DESCRI AS DESCRI   FROM "+ RetSQLName("SX5") +" WHERE D_E_L_E_T_ = ' ' " 
		cQuery += " AND X5_TABELA = '12'"
		
		MPSysOpenQuery( cQuery , cAliasX )
		(cAliasX)->( DBGoTop() )
		
		While (cAliasX)->(!Eof()) 
		
			_cParDef += AllTrim( (cAliasX)->CHAVE )
			aAdd( _aDados , AllTrim( (cAliasX)->DESCRI ) )
			
		    (cAliasX)->( DBSkip() )
		EndDo
		
		(cAliasX)->(Dbclosearea())

		_nMaxSel := LEN(_aDados) //TODOS os 28 estados cabem em 99 caracteres

	//====================================================================================================
	// Monta estrutura de seleção para códigos de municípios de acordo com uma UF já selecionada - LSTMUN
	//====================================================================================================
	Case _cNomeSXB == 'LSTMUN'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com as siglas de estados (UF)
		//----------------------------------------------------------------------------------------------------
		If		AllTrim( Upper( FunName() ) ) $ "ROMS006/ROMS005/MOMS004/ROMS003/RCOM007/ROMS014/ROMS015"
			_cCodAux := MV_PAR11
		ElseIf	AllTrim( Upper( FunName() ) ) $ "AOMS032"
			_cCodAux := MV_PAR10
		ElseIf	AllTrim( Upper( FunName() ) ) $ "MATA440"
			_cCodAux := MV_PAR01
		ElseIf	AllTrim( Upper( FunName() ) ) $ "RGLT032"
			_cCodAux := MV_PAR04
		Else
			_cCodAux := ''
		EndIf

		_nTamChv := 05
		_nMaxSel := 12
		_cTitulo := "Municípios"
		
		CC2->( DBSetOrder(1) )
		CC2->( DBSeek( xFilial("CC2") ) )
		While CC2->(!Eof()) .And. CC2->CC2_FILIAL == xFilial("CC2")
		
			If !Empty( _cCodAux ) // Caso tenha preenchido só adiciona municípios de estados presentes no parâmetro
			
			   	If CC2->CC2_EST $ _cCodAux
			   	
			   		_cParDef += CC2->CC2_CODMUN
					aAdd( _aDados , AllTrim( CC2->CC2_MUN ) )
					
			   	EndIf
			   	
			Else
			
				_cParDef += CC2->CC2_CODMUN
				aAdd( _aDados , AllTrim( CC2->CC2_MUN ) )
				
			EndIf
			
		CC2->( DBSkip() )
		EndDo

	//====================================================================================================
	// Monta estrutura de seleção para Tipos de Cargas - LSTDAK
	//====================================================================================================
	Case _cNomeSXB == 'LSTDAK'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos dos tipos de cargas
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 01
		_nMaxSel := 09
		_cTitAux := "Tipos de Carga"
		
		SX3->( DBSetOrder(2) )
		If SX3->( DBSeek("DAK_I_TPCA") )
			_cCodAux := AllTrim( X3Cbox() )
		EndIf
		
		//====================================================================================================
		// A funcao STRTOKARR() tem o objetivo de retornar um array com as opções
		//====================================================================================================
		_aDadAux := STRTOKARR( _cCodAux , ';' )
		
		For _nI := 1 to Len( _aDadAux )
		
			_cCodAux := AllTrim( _aDadAux[_nI] )
			_cParDef += SubStr( _cCodAux , 1 , AT( "=" , _cCodAux ) - 1 )
			
			aAdd( _aDados , SubStr( _cCodAux , AT( "=" , _cCodAux ) + 1 ) )
		
		Next _nI
	
	//====================================================================================================
	// Monta estrutura de seleção para Transportadores - LSTSA2
	//====================================================================================================
	Case _cNomeSXB == 'LSTSA2'
	
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos dos Transportadores
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 6
		_nMaxSel := 16
		_cTitAux := "Transportadores"
		
		_cQuery := " SELECT DISTINCT "
		_cQuery +=     " A2_COD ,"
		_cQuery +=     " A2_NOME "
		_cQuery += " FROM  "+ RetSqlName('SA2') +' SA2 '
		_cQuery += " WHERE "+ RetSqlCond('SA2')
		_cQuery += " AND A2_I_CLASS IN ('A','T','G') "
		_cQuery += " ORDER BY A2_COD"
		
		_cAlias := GetNextAlias()
		
		MPSysOpenQuery( _cQuery , _cAlias )
		(_cAlias)->( DBGoTop() )
		While (_cAlias)->( !Eof() )
		
			_cParDef += AllTrim( (_cAlias)->A2_COD )
			aAdd( _aDados , AllTrim( (_cAlias)->A2_NOME ) )
			
		    (_cAlias)->( DBSkip() )
		EndDo
		
		(_cAlias)->( DBCloseArea() )

    //====================================================================================================
	// Monta estrutura de seleção para Tipos de Movimentações - LSTSF5                                                   
	//====================================================================================================
	Case _cNomeSXB == 'LSTSF5'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos dos tipos de cargas
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 03
		_nMaxSel := 50
		_cTitAux := "Tipos de Movimentações"
		
		SF5->( DBSetOrder(1) )
		SF5->( DBSeek( xFilial("SF5") ) )
		Do While SF5->(!Eof()) .And. SF5->F5_FILIAL == xFilial("SF5")
		   If SF5->F5_MSBLQL  <> "1"   	
		      _cParDef += SF5->F5_CODIGO
		      aAdd( _aDados , AllTrim( SF5->F5_TEXTO ) )
		   EndIf
			
		   SF5->( DBSkip() )
		EndDo

	//====================================================================================================
	// Monta estrutura de seleção para Tipos de Movimentações - LSTSF5                                                   
	//====================================================================================================
	Case _cNomeSXB == 'SELLIN'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos dos tipos de cargas
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 02
		_nMaxSel := 50
		_cTitAux := "Seleção de Linha"
		
		_cQuery := "SELECT X5_TABELA AS TABELA, X5_CHAVE AS CHAVE, X5_DESCRI AS DESCRI "
		_cQuery += "FROM " + RetSqlName("SX5") + " "
		_cQuery += "WHERE X5_FILIAL = '" + xFilial("SX5") + "' "
		_cQuery += "  AND X5_TABELA = 'ZP' "
		_cQuery += "  AND D_E_L_E_T_ = ' ' "
		
		_cAlias := GetNextAlias()
		
		MPSysOpenQuery( _cQuery , _cAlias )
		(_cAlias)->( DBGoTop() )
		While (_cAlias)->( !Eof() )
		
			_cParDef += AllTrim( (_cAlias)->CHAVE )
			aAdd( _aDados , AllTrim( (_cAlias)->DESCRI ) )
			
		    (_cAlias)->( DBSkip() )
		EndDo
		
		(_cAlias)->( DBCloseArea() )

    Case _cNomeSXB == 'LSTSPV'
	
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os status de ocorrências de frete
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 04
		_cTitAux	:= "Situação Pedido de Vendas"
		
		_cCombo := "S=Sem Bloqueio;C=Bloqueio Credito;P=Bloqueio Preco;B=Bloqueio Bonificacao"
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	
		
	Case _cNomeSXB == 'LSTABA'
	
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os abatimento de contrato.
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 03
		_cTitAux	:= "Abatimento Contrato"
		
		_cCombo := "I=Integral;P=Parcial;N=Nao possui"
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	
	
	//====================================================================================================
	// Monta estrutura de seleção para Multiplos Grupos de Produtos - SBM_02                                               
	//====================================================================================================
	Case _cNomeSXB == 'SBM_02'
		 //----------------------------------------------------------------------------------------------------
		 // Monta estrutura dos dados com Multiplos Grupos de Produtos
		 //----------------------------------------------------------------------------------------------------
		 _nTamChv := 04
		 _nMaxSel := 25
		 _cTitAux := "Seleção de Linha"
		 
		 _cAlias := GetNextAlias()
		 
		 _cQuery := " SELECT "
         _cQuery += "     SBM.BM_GRUPO , SBM.BM_DESC "
         _cQuery += " FROM  "+ RetSqlName("SBM") +" SBM "
         _cQuery += " WHERE "+ RetSqlCond('SBM')
         _cQuery += " ORDER BY SBM.BM_GRUPO "
         
         MPSysOpenQuery( _cQuery , _cAlias )

         cTitulo := "Grupos de Produtos"

         (_cAlias)->( DBGoTop() )
         While (_cAlias)->( !Eof() )
             _cParDef += AllTrim( (_cAlias)->BM_GRUPO )
		     aAdd( _aDados , AllTrim( (_cAlias)->BM_DESC ) )         

             (_cAlias)->( DBSkip() )
         EndDo

         (_cAlias)->( DBCloseArea() )
	
	
	//====================================================================================================
	// Monta estrutura de seleção para status de canhoto
	//====================================================================================================
	Case _cNomeSXB == 'LSTSIT'

		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com situações do pedido de vendas.
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 06
		_cTitAux	:= "Situações do Pedido de Vendas"
		
		_cCombo := "I=PEDIDO IMPLANTADO;L=PEDIDO LIBERADO;E=PEDIDO LIBERADO COM BLOQUEIO ESTOQUE;C=PEDIDO LIBERADO COM BLOQUEIO CREDIDO;P=PEDIDO COM CARGA;F=PEDIDO FATURADO"
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	
	
	
	//====================================================================================================
	// Monta estrutura de seleção para situações de pedidos de vendas
	//====================================================================================================
	Case _cNomeSXB == 'LSTCAN'

		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com situações do pedido de vendas.
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 06
		_cTitAux	:= "Situações de Canhoto de NF"
		
		_cCombo := "C=Aguardando Conf;A=Aprovado;R=Reprovado;N=Nao recepcionado"
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	

    //=======================================================================================================
    // Monta estrutura de seleção de Filial - Exibe todas as filiais cadastradas na tabela ZZM.      
	//=======================================================================================================
	Case _cNomeSXB $ "FILIAL"
        //----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados
		//----------------------------------------------------------------------------------------------------
		_nTamChv  := 02
		_nMaxSel  := 40
		_cTitAux  := 'Filial'
        _cFilSalva:= cFilAnt
		_nRecZZM  := ZZM->( Recno() )

		ZZM->( DBGoTop() )
		DO While ZZM->(!Eof()) 
		
           cFilAnt:=ZZM->ZZM_CODIGO
           _cParDef += AllTrim( ZZM->ZZM_CODIGO )
           aAdd( _aDados , AllTrim( ZZM->ZZM_DESCRI ) )
		
		   ZZM->( DBSkip() )
		EndDo
		ZZM->( DBGoTo(_nRecZZM) )
        cFilAnt:= _cFilSalva
	
	//====================================================================================================
	// Monta estrutura de seleção para Lista de Categorias - LSTCAT                                                   
	//====================================================================================================
	Case _cNomeSXB == 'LSTCAT'
		
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados com os códigos das categorias.
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 01
		_nMaxSel := 50
		_cTitAux := "Lista de Categorias"
		
		_cQuery := "SELECT X5_TABELA AS TABELA, X5_CHAVE AS CHAVE, X5_DESCRI AS DESCRI "
		_cQuery += "FROM " + RetSqlName("SX5") + " "
		_cQuery += "WHERE X5_FILIAL = '" + xFilial("SX5") + "' "
		_cQuery += "  AND X5_TABELA = '28' "
		_cQuery += "  AND D_E_L_E_T_ = ' ' "
		
		_cAlias := GetNextAlias()
		
		MPSysOpenQuery( _cQuery , _cAlias )
		(_cAlias)->( DBGoTop() )
		While (_cAlias)->( !Eof() )
		   If AllTrim((_cAlias)->CHAVE) $ "0123456789"
		      (_cAlias)->( DBSkip() )
		      Loop
		   EndIf
		   
		   _cParDef += AllTrim( (_cAlias)->CHAVE )
		   aAdd( _aDados , AllTrim( (_cAlias)->DESCRI ) )
			
		   (_cAlias)->( DBSkip() )
		EndDo
		
		(_cAlias)->( DBCloseArea() )
	
	//=======================================================================================================
    // Monta estrutura de seleção de Tipos de refeições (SPM).
	//=======================================================================================================
	Case _cNomeSXB $ "LSTSPM"
        //----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados
		//----------------------------------------------------------------------------------------------------
		_nTamChv  := 02
		_nMaxSel  := 40
		_cTitAux  := 'Tipos de Refeições'
		_nRecSPM  := SPM->( Recno() )
        _cTiposRef:= ""
        
		SPM->( DBGoTop() )
		DO While SPM->(!Eof()) 
		   If ! (SPM->PM_TIPOREF $ _cTiposRef )
		      _cTiposRef += ";" + SPM->PM_TIPOREF
              _cParDef += AllTrim( SPM->PM_TIPOREF )
              aAdd( _aDados , AllTrim( SPM->PM_DESCREF ) )
		   EndIf
		   
		   SPM->( DBSkip() )
		EndDo
		SPM->( DBGoTo(_nRecSPM) )
	
	Case _cNomeSXB == 'LSTTPA'
	    //=======================================================================================================
        // Monta estrutura de seleção de Tipos de Agendamento.
	    //=======================================================================================================
		_nTamChv:= 01
		_cTitAux:= "Tipos de Entrega"
		_aDados := U_TipoEntrega()        
		IF TYPE("_cCampos_F3_LSTTPA") <> "C"//Essa variavel deve ser iniciada com o campo que vc quer que selecione 1 só no programa custumizado
		   _cCampos_F3_LSTTPA:=""
		ENDIF		
        IF STRTRAN(_cMVRET,"M->","") $ "C5_I_AGEND/A1_I_AGEND/"+_cCampos_F3_LSTTPA//Se tiver mais um campo em programa padrão para usar esse F3 coloque nessa lista se não ser para inicia a variavel _cCampos_F3_LSTTPA
           _nMaxSel:=1// ESSE F3 É PARA SELECIONAR UM SÓ
        ELSE
           _nMaxSel:=LEN(_aDados)// ESSE F3 É PARA SELECIONAR MAIS DE UM 
        ENDIF
		For _ni := 1 to len(_aDados)
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)//"AIPMRNTO"
		Next	

	Case _cNomeSXB == 'LSTCLA'
	    //=======================================================================================================
        // Monta estrutura de seleção de Classes de clientes
	    //=======================================================================================================
		_nTamChv	:= 01
		_nMaxSel	:= 03
		_cTitAux	:= "Classes de clientes"
		//          
		_cCombo := "A=Classe A;B=Classe B;C=Classe C"
		
		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next	

	//=======================================================================================================
    // Monta estrutura de seleção de Tipos de transmissão de MD-e e CT-e
	//=======================================================================================================
	Case _cNomeSXB == 'LSTEVE'
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura de seleção de Tipos de transmissão de MD-e e CT-e
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 06
		_nMaxSel	:= 08
		_cTitAux	:= "Eventos Manifestados"
		_cCombo 	:= "210200 - Confirmada;210220 - Desconhecida;210240 - Nao Realizada;210210 - Ciencia;888888 - NF-e Nao Transmitida;999999 - CT-e Nao Transmitido;610110 - Prestacao de Servico em Desacordo;610111 - Cancelamento Prestacao de Servico em Desacordo"

		_aDados := STRTOKARR(_cCombo, ';')
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += substr(alltrim(_aDados[_ni]),1,6)

		Next

	//=======================================================================================================
    // Monta estrutura de seleção de Status de transmissão de MD-e e CT-e
	//=======================================================================================================
	Case _cNomeSXB == 'LSTSTR'
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura de seleção de Status de transmissão e MD-e.
		//----------------------------------------------------------------------------------------------------
		_nTamChv	:= 01
		_nMaxSel	:= 04
		_cTitAux	:= "Status Transmissão MD-e/CT-e"
		_cCombo 	:= "6 - Evento Autorizado;5 - Evento com erro;8 - NF-e Não Transmitida;9 - CT-e Não Transmitido"

		_aDados := STRTOKARR(_cCombo, ';')

		For _ni := 1 to len(_aDados)

			_cParDef += substr(alltrim(_aDados[_ni]),1,1)

		Next

	//=======================================================================================================
    // Monta estrutura de seleção de Parâmetros permitidos para alteração
	//=======================================================================================================
	Case _cNomeSXB == 'LSTPAR'
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura de seleção de Parâmetros permitidos para alteração
		//----------------------------------------------------------------------------------------------------
		_nTamChv := 10
		_nMaxSel := 1
		_cTitAux := "Lista de Parâmetros"
		
		ZZL->( DBSetOrder(3) )
		If ZZL->( DBSeek(xFilial("ZZL")+RetCodUsr()) )
			_aDadAux := StrTokArr(AllTrim(ZZL->ZZL_PARAME), ';') 
			SX6->( DBSetOrder(1) )
			For _nX:=1 to Len(_aDadAux)
				If SX6->( DBSeek( cFilAnt + _aDadAux[_nX] ) )
			       	_cParDef += Pad(_aDadAux[_nX],_nTamChv)
					aAdd( _aDados , _aDadAux[_nX]+'-'+X6Descric()+X6Desc1()+X6Desc2() )
				ElseIf SX6->( DBSeek( '  ' + _aDadAux[_nX] ) )
			       	_cParDef += Pad(_aDadAux[_nX],_nTamChv)
					aAdd( _aDados , _aDadAux[_nX]+'-'+X6Descric()+X6Desc1()+X6Desc2() )
				EndIf
			Next
		EndIf
		
	//====================================================================================================
	// Monta estrutura de seleção de Multiplos Produtos - SB1_05                                               
	//====================================================================================================
	Case _cNomeSXB == 'SB1_05' 
		 //----------------------------------------------------------------------------------------------------
		 // Monta estrutura dos dados de Multiplos Produtos
		 //----------------------------------------------------------------------------------------------------
		 _nTamChv := 11
		 _nMaxSel := 25
		 _cTitAux := "Seleção de Linha"
		 
		 _cAlias := GetNextAlias()
		 
		 _cQuery := " SELECT "
         _cQuery += "     SB1.B1_COD , SB1.B1_DESC "
         _cQuery += " FROM  "+ RetSqlName("SB1") +" SB1 "
         _cQuery += " WHERE "+ RetSqlCond('SB1')
         _cQuery += " AND B1_TIPO = 'PA' AND B1_MSBLQL = '2' "
         _cQuery += " ORDER BY SB1.B1_COD "
         
		 MPSysOpenQuery( _cQuery , _cAlias )
         cTitulo := "Lista de Produtos"

         (_cAlias)->( DBGoTop() )
         While (_cAlias)->( !Eof() )
             _cParDef += AllTrim( (_cAlias)->B1_COD )
		     aAdd( _aDados , AllTrim( (_cAlias)->B1_DESC ) )         

             (_cAlias)->( DBSkip() )
         EndDo

         (_cAlias)->( DBCloseArea() )

    //=======================================================================================================
    // Monta estrutura de seleção de Eventos para emissão do Previsão Reinf.
	//=======================================================================================================
	Case _cNomeSXB == 'EVETAF'
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura de seleção de Status de transmissão e MD-e.
		//----------------------------------------------------------------------------------------------------
		// Monta estrutura dos dados
		_nTamChv	:= 06
		_cTitAux	:= "Eventos Emissão Previsão Reinf"
		
		_aDados := U_RFIN016B() 
		_nMaxSel:= LEN(_aDados)
		
		For _ni := 1 to len(_aDados)
		
			_cParDef += SUBSTR(_aDados[_ni],1,_nTamChv)

		Next	
		
    //====================================================================================================
	// Monta estrutura de seleção de Multiplos Produtos - utilizados na extração do Reinf.                                              
	//====================================================================================================
	Case _cNomeSXB == 'SB1TAF' 
		 //----------------------------------------------------------------------------------------------------
		 // Monta estrutura dos dados de Multiplos Produtos
		 //----------------------------------------------------------------------------------------------------
		 _nTamChv := 11
		 _nMaxSel := 25
		 _cTitAux := "Produtos Extração Reinf"
		 
		 _cAlias := GetNextAlias()
		 
		 _cQuery := " SELECT "
         _cQuery += "     SB1.B1_COD , SB1.B1_DESC "
         _cQuery += " FROM  "+ RetSqlName("SB1") +" SB1 "
         _cQuery += " WHERE "+ RetSqlCond('SB1')
         _cQuery += " AND B1_INSS = 'S' "
         _cQuery += " ORDER BY SB1.B1_COD "
         
		 MPSysOpenQuery( _cQuery , _cAlias )
         cTitulo := "Lista de Produtos Reinf"

         (_cAlias)->( DBGoTop() )
         While (_cAlias)->( !Eof() )
             _cParDef += AllTrim( (_cAlias)->B1_COD )
		     aAdd( _aDados , AllTrim( (_cAlias)->B1_DESC ) )         

             (_cAlias)->( DBSkip() )
         EndDo

         (_cAlias)->( DBCloseArea() )
		
	//====================================================================================================
	// Monta estrutura de seleção de Multiplos Produtos do Leite - LSTZA7
	//====================================================================================================
	Case _cNomeSXB == 'LSTZA7' 
		 //----------------------------------------------------------------------------------------------------
		 // Monta estrutura dos dados de Multiplos Produtos
		 //----------------------------------------------------------------------------------------------------
		 _nTamChv := 11
		 _nMaxSel := 9
		 _cTitAux := "Seleção de Produtos"
		 cTitulo := "Lista de Produtos Leite" 
		 _cAlias := GetNextAlias()
		 BeginSql alias _cAlias
			SELECT ZA7_CODPRD, B1_DESC
			FROM ZA7010 ZA7, SB1010 SB1
			WHERE ZA7.D_E_L_E_T_ = ' '
			AND SB1.D_E_L_E_T_ = ' '
			AND B1_COD = ZA7_CODPRD
			GROUP BY ZA7_CODPRD, B1_DESC
			ORDER BY ZA7_CODPRD
		EndSql

        While (_cAlias)->( !Eof() )
             _cParDef += AllTrim((_cAlias)->ZA7_CODPRD)
		     aAdd( _aDados , AllTrim( (_cAlias)->B1_DESC ) )         
             (_cAlias)->( DBSkip() )
         EndDo
         (_cAlias)->( DBCloseArea() )
		
    //====================================================================================================
	// Monta estrutura de seleção de Multiplos Produtos - utilizados na extração do Reinf.                                              
	//====================================================================================================
	Case _cNomeSXB == 'ZCFDES' 
		 //----------------------------------------------------------------------------------------
		 // Monta estrutura dos dados para a Consulta de Traansferência de Produtos.
		 //----------------------------------------------------------------------------------------
		 _nTamChv := 40
		 _nMaxSel := 1
		 _cTitAux := "Destino Transferência de Produtos"
		 _cCodDest:= U_ITGETMV( "IT_DESTTRA", "T00001;T00002;")
		 
		 _cAlias := GetNextAlias()
		 
		 _cQuery := " SELECT "
         _cQuery += "     ZCF.ZCF_CODIGO , ZCF.ZCF_ORIGDE "
         _cQuery += " FROM  "+ RetSqlName("ZCF") +" ZCF "
         _cQuery += " WHERE "+ RetSqlCond('ZCF')
         _cQuery += " AND ZCF_CODIGO IN " + FormatIn(_cCodDest,";") 

         _cQuery += " ORDER BY ZCF.ZCF_CODIGO "
         
		 MPSysOpenQuery( _cQuery , _cAlias )
         cTitulo := "Destino Transferência de Produtos"

         (_cAlias)->( DBGoTop() )
         While (_cAlias)->( !Eof() )
             _cParDef += U_ITKey( (_cAlias)->ZCF_ORIGDE,"ZCF_ORIGDE")       //AllTrim( (_cAlias)->ZCF_ORIGDE)
		     aAdd( _aDados , U_ITKey( (_cAlias)->ZCF_CODIGO,"ZCF_CODIGO") ) //AllTrim( (_cAlias)->ZCF_ORIGDE) )         

             (_cAlias)->( DBSkip() )
         EndDo
		 
		 //_cParDef += "*"
		 //aAdd( _aDados , "*End of File*" ) 

         (_cAlias)->( DBCloseArea() )

EndCase 

If !Empty( _aDados )
	_lRet    := .T.
	&_cMVRET := IT_MNTTELSEL( _nTamChv , _nMaxSel , &_cMVRET , _cTitAux , _cParDef , _aDados )
	_cRetorno := &_cMVRET
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: IT_MNTTELSEL
Autor-----------: Alexandre Villar
Data da Criacao-: 22/03/2015
Descrição-------: Função que monta a tela para seleção de ítens via F3 de acordo com parâmetros recebidos
Parametros------: _nTamChv - Tamanho da Chave dos registros
----------------: _nMaxSel - Número máximo de registros que podem ser selecionados ao mesmo tempo
----------------: _cMVRET  - Nome da variável ou campo onde será gravado o retorno
----------------: _cTitAux - Título que será exibido na janela de seleção dos itens
----------------: _cParDef - String contendo os códigos dos itens que serão listados
----------------: _aDados  - Array contendo a descrição dos itens que serão listados
Retorno---------: _cRetAux - Lista de registros selecionados
===============================================================================================================================
*/
Static Function IT_MNTTELSEL( _nTamChv , _nMaxSel , _cMVRET , _cTitAux , _cParDef , _aDados )

Local _cRetAux	:= _cMVRET
Local i

Private nTam       := _nTamChv //Tratamento para carregar variaveis da lista de opcoes
Private nMaxSelect := _nMaxSel //Define a quantidade máxima de itens que podem ser selecionados ao mesmo tempo
Private aCat       := aClone( _aDados )
Private MvPar      := ""
Private cTitulo    := _cTitAux
Private MvParDef   := _cParDef       

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//====================================================================================================
// Tratativa para carregar selecionados registros já marcados anteriormente
//====================================================================================================
If Len( AllTrim( _cRetAux ) ) == 0

	MvPar		:= PadR( AllTrim( StrTran( _cRetAux , ";" , "" ) ) , Len(aCat) )
	_cRetAux	:= PadR( AllTrim( StrTran( _cRetAux , ";" , "" ) ) , Len(aCat) )

Else

	MvPar  := AllTrim( StrTran( _cRetAux , ";" , "/" ) )

EndIf

//====================================================================================================
// Função que chama a tela de opções e só registra se usuário confirmar com "Ok"
//====================================================================================================
If F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

	_cRetAux := ""
	
	For i := 1 To Len(MvPar) Step nTam
	
		If !( SubStr( MvPar , i , 1 ) $ " |*" )
			_cRetAux += SubStr( MvPar , i , nTam ) +_cSeparador //Separa os registros selecionados com ';'
		EndIf
		
	Next i
	
	IF !EMPTY(_cRetAux)
	   _cRetAux := SubStr( _cRetAux , 1 , Len( _cRetAux ) - 1 ) //Trata para tirar o ultimo caracter
	ELSE
       _cRetAux := SPACE(((nMaxSelect*(_nTamChv+1)))-1)// No. de selecao maxima * tam da chave + ; - o ultimo ;
	ENDIF

EndIf     

Return( _cRetAux )

/*
===============================================================================================================================
Programa--------: ITLOGACS
Autor-----------: Alexandre Villar
Data da Criacao-: 23/03/2015
Descrição-------: Função que faz o LOG de utilização das rotinas customizadas do sistema
Parametros------: _cponto - Nome da rotina
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ITLOGACS( _cPonto )
Local _aArea    := {}
Local _crotinas := "" 
Local nConta    := 0
Local _cRotina  := ""
Local _cCaminho := ""
Default _cPonto := ""

If FWIsInCallStack("MSEXECAUTO")      .OR.;
   FWIsInCallStack("INITPAD")         .OR.;
   FWIsInCallStack("VLDDATA")         .OR.;
   FWIsInCallStack("WSEXECUTE")       .OR.;
   FWIsInCallStack("CONPAD1")         .OR.;
   FWIsInCallStack("FWBOSCHDEXECUTE") .OR.;   
   FWIsInCallStack("RUNTRIGGER")      .OR.;      
   FWIsInCallStack("RPC")             .OR.;      
   FWIsInCallStack("EXECBLOCK")       .OR.;         
   FWIsInCallStack("GETCOLUMNDATA")
   Return .F.
ENDIF

//Só gravará log de rotinas especificadas
_cRotinas += "ACOM/MCOM/RCOM/"
_cRotinas += "AEST/MEST/REST/"
_cRotinas += "AOMS/MOMS/ROMS/"
_cRotinas += "AGLT/MGLT/RGLT/"
_cRotinas += "AGPE/MGPE/RGPE/"
_cRotinas += "AFIN/MFIN/RFIN/"
_cRotinas += "AAMD/MAMD/RAMD/"
_cRotinas += "AFIS/MFIS/RFIS/"
_cRotinas += "ACTB/MCTB/RCTB/"

If !(((substr(AllTrim( FUNNAME() ),3,4)) $ _crotinas) .or. (substr(AllTrim( FUNNAME() ),1,4) $ _crotinas))
   If !(((substr(AllTrim( ProcName(1) ),3,4)) $ _crotinas) .or. (substr(AllTrim( ProcName(1) ),1,4) $ _crotinas))
	  Return .F.
   ELSE
      _cRotina:=PadR( AllTrim( ProcName(1) ) , 30 )	  
   Endif
ELSE
   _cRotina:=PadR( AllTrim( FUNNAME() ) , 30 )	  
Endif

_aArea:=GetArea()

If Select('ZP1') = 0
   IF Select('SX2') = 0 .OR. !ChkFile('ZP1')
	  Return .F.
   ENDIF  	  
Endif

If !(U_ITGETMV("IT_LOGACS",.F.)) //Parâmetro de controle de gravação de log 
	Return .F.
Endif

If Select('Z16') = 0
   IF Select('SX2') = 0 .OR. !ChkFile('Z16')
	  Return .F.
   ENDIF  	  
Endif
/*
IF EMPTY(_cPonto)
   _cPonto := cValToChar( ProcLine(1) )
ELSE
   _cPonto += "/"+cValToChar( ProcLine(1) )
ENDIF*/
FOR nConta := 1 TO 12 
   cProcName:=STRTRAN(PROCNAME(nConta)," ","")
   IF !EMPTY(cProcName) .AND. !"{|" $ cProcName .AND. !cProcName $ "ACTIVATE/FWMSGRUN/PROCESSA/__EXECUTE/FWPREEXECUTE/SIGAIXB/SIGAADV/BROWSEDEF/MDIEXECUTE/SHOWWAIT/SEARCH"
      _cCaminho+=STRTRAN(PROCNAME(nConta)," ","")+"/"
   ENDIF
NEXT
IF !EMPTY(_cPonto)
   _cPonto += "/"
ENDIF
//IF !FUNNAME() $ _cCaminho
   _cPonto+=_cCaminho+FUNNAME()
//ELSEif !EMPTY(_cCaminho)
   //_cPonto+=LEFT(_cCaminho,LEN(_cCaminho)-1)
//ENDIF

Z16->( DBSetOrder(1) )
If Z16->( DBSeek( xFilial('Z16') + _cRotina + _cPonto ) )

	_nRec := Z16->(Recno())
	
	If Z16->(Dbrlock()) //Só grava se o registro estiver livre

		Z16->Z16_CONTA		:= IIF( Z16->Z16_CONTA < 999999999999 , ( Z16->Z16_CONTA + 1 ) , Z16->Z16_CONTA )
		Z16->Z16_PENUSR		:= Z16->Z16_ULTUSR
		Z16->Z16_DATPEN		:= Z16->Z16_DATA
		Z16->Z16_HORPEN		:= Z16->Z16_HORA
		Z16->Z16_ULTUSR		:= RetCodUsr()
		Z16->Z16_DATA		:= Date()
		Z16->Z16_HORA		:= Time()	
	    Z16->Z16_PENOME     := Z16->Z16_ULTNOM
		Z16->Z16_ULTNOM     := SubStr(cUsuario, 7,15)
		Z16->(Msunlock())
		
	Endif	
Else	
	Z16->(RecLock('Z16',.T.))
	Z16->Z16_FILIAL		:= xFilial('Z16')
	Z16->Z16_ROTINA		:= _cRotina
	Z16->Z16_PONTO		:= _cPonto
	Z16->Z16_CONTA		:= 1
	Z16->Z16_ULTUSR		:= RetCodUsr()
	Z16->Z16_DATA		:= Date()
	Z16->Z16_HORA		:= Time()
    Z16->Z16_ULTNOM     := SubStr(cUsuario, 7,15)
	Z16->( MsUnLock() )
EndIf

RestArea( _aArea )
Return .T.

/*
===============================================================================================================================
Programa--------: ITGESTOR
Autor-----------: Jerry
Data da Criacao-: 18/04/2016
Descrição-------: Rotina para retornar o Gestor de Compras do Comprador
Parametros------: _cGrpCompras
----------------: _cUsrComprador
Retorno---------: _cGestor - Código do Gestor de Compras
===============================================================================================================================
*/
User Function ITGESTOR(_cGrpCompras,_cUsrComprador )

Local _aArea		:= GetArea()
Local _cAlias		:= ''
Local _cQuery		:= ''
Local _cGestor		:= ''

Default _cGrpCompras   := ''             
Default _cUsrComprador := ''


_cQuery := "SELECT AJ_I_GCOM AS GESTOR  "
_cQuery += "FROM " + RetSqlName("SAJ") + " SAJ "
_cQuery += "WHERE AJ_FILIAL = '" + xFilial("SAJ") + "' "
_cQuery += "  AND SAJ.AJ_GRCOM IN " + FormatIn(_cGrpCompras,";") 
_cQuery += "  AND SAJ.AJ_USER  = '" +  _cUsrComprador + "' "
_cQuery += "  AND D_E_L_E_T_ = ' ' "

_cAlias := GetNextAlias()
	
MPSysOpenQuery( _cQuery , _cAlias )
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() ) 
	_cGestor := (_cAlias)->GESTOR
Else
	_cGestor := ""
EndIf
	
(_cAlias)->( DBCloseArea() )
	
RestArea( _aArea )

Return( _cGestor)

/*
===============================================================================================================================
Programa----------: ITGEREXCEL
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/06/2016
Descrição---------: Função generica para geração de relatórios em Excel. Chamado 8908.
Parametros--------: _cNomeArq    : Nome do Arquivo. Este arquivo será gerada no formato XML. Exemplo: "Planilha.xml"
                    _cDiretorio  : Diretório de gravação da planilha. 
                    _cTitulo     : Titulo do Relatório
                    _cNomePlan   : Nome da Planilha
                    _aCabecalho  : Array de cabecalho da planilha {{"Titulo 1","Alinhamento","Formatacao","Totaliza(.T./.F.)", cPicture },
                                 -                                 {"Titulo 2","Alinhamento","Formatacao","Totaliza(.T./.F.)", cPicture },...}
                                 - Alinhamento( 1-Left,2-Center,3-Right )
                                 - Formatação( 1-General,2-Number,3-Monetário,4-DateTime )
                                 - Totaliza? (.T. ou .F.)
								 - cPicture (somente para XLSX e campos tipos numericos)
                    _aDetalhe    : Array com os dados a serem impressos {{dado 1, dado 2, dado 3,...},
                                 -                                       {dado 1, dado 2, dado 3,...},...}
                    _lLeTabTemp  : Informa se Lê tabela temporária ou não (.T. ou .F.).
                    _cAliasTab   : Alias da Tabela. Exemplo: "TRBSA1"
                    _aCampos     : Array com os campos das colunas. Exemplo: {"TRBSA1->A1_COD","TRBSA1->A1_NOME",...}     
                    _lScheduller : .F. = Rotina sendo executada via tela pelo usuário
                                 - .T. = Rotina sendo executada via Scheduller sem interação do usuário.                              
					_lCriaPastas : .T. = Cria várias pastas para um array de dados multiplo.
					_aPergunte   : Array com 3 colunas dos parametros de filtro do Pergunte/ParamBox, Ex.: AADD(_aPergunte,{"Pergunta 01 :',"Filiais ?","90,92" }) / Programa ROMS078.PRW
					_lEnviaEmail : .T. = Desconsidera as formatações de cores dos titulos no FWMsExcelEx() (.XML)
					_lXLSX       : .T. = Gera com a CLASSE FwMsExcelXlsx() (.XLSX)
					             - .F. = Gera com a CLASSE FWMsExcelEx() (.XML)
 	                _oProc		 : Tem que ser o objeto da função FWMSGRUN()
					_lComCab	 : .T. = Gera com o cabeçalho
Retorno-----------: Nenhum
Observação--------: O site da Totvs com as definições dos comandos para geração de arquivos XML no formato Excel, encontram-se 
                    no Link: 
                               // http://tdn.totvs.com/display/public/mp/FWMsExcel
===============================================================================================================================
*/
User Function ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX,_oProc,_lComCab)
Local _oExcel
Local _cTipoGeracao, _nI, _cDetalhe, _aItem
Local _nJ, _aCabecPlan, _aDadosPlan
Local lHtml := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml ou Web
Local _aConfig:= U_ITCFGEML('')
Local _cFrom 
Local _cPthArq:= ALLTRIM(GETMV("MV_RELT",,"/spool/"))

Default _lXLSX       := .F.
Default _cDiretorio  := GetTempPath()
Default _cNomeArq    := "PLANILHA_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+IF(_lXLSX,".XLSX",".xml")
Default _cNomePlan   := "Relatorio"
Default _cTitulo     := "Relatório" 
Default _lLeTabTemp  := .F.
Default _lScheduller := .F.
Default _lCriaPastas := .F.
Default _lEnviaEmail := .F.
Default _lComCab     := .T.

#Define AZUL_EM_HEXA "#0000FF"
#Define LARANJA_EM_HEXA "#FFA500"
#Define VERMELHO_EM_HEXA "#FF0000"
#Define AZUL_CLARO_EM_HEXA "#00BFFF"

IF IsSrvUnix()
   _cNomeArq  :=LOWER(_cNomeArq)
   _cDiretorio:=LOWER(_cDiretorio)
ENDIF

Begin Sequence                                                                       
   //================================================================================
   // Validações iniciais
   //================================================================================   
   If Empty(_aCabecalho)
      If _lScheduller
        //U_ITCONOUT("[ITGEREXCEL] - O array com os dados de cabeçalho da planilha precisa ser informado.")
      Else
         u_itmsg("O array com os dados de cabeçalho da planilha precisa ser informado.","Atenção",,1)
      EndIf
      
      Break
   EndIf
   
   If Empty(_aDetalhe) .And. !_lLeTabTemp
      If _lScheduller
        //U_ITCONOUT("[ITGEREXCEL] - O array com os dados da planilha precisa ser informado.")
      Else
	     U_ITMSG('Planilha: "'+_cNomePlan+'" sem dados para gerar.','Atenção!',,1)
      EndIf
      
      Break
   EndIf
   
   If Empty(_cAliasTab) .And. _lLeTabTemp
      If _lScheduller
        //U_ITCONOUT("[ITGEREXCEL] - Para gerar o relatorio com base em tabelas temporárias, o alias da tabela precisa ser informado.")
      Else
         u_itmsg("Para gerar o relatorio com base em tabelas temporárias, o alias da tabela precisa ser informado.","Atenção",,1)
      EndIf
      
      Break
   EndIf
   
   If Empty(_aCampos) .And. _lLeTabTemp
      If _lScheduller
        //U_ITCONOUT("[ITGEREXCEL] - Para gerar o relatorio com base em tabalas temporárias, o array de campos da tabela precisa ser informado.")
      Else
         u_itmsg("Para gerar o relatorio com base em tabalas temporárias, o array de campos da tabela precisa ser informado.","Atenção",,1)
      EndIf
      
      Break
   EndIf
   
   If _lLeTabTemp 
      _cTipoGeracao := "GERACAO_POR_TABELA"
   Else
      _cTipoGeracao := "GERACAO_POR_ARRAY"
   EndIf
   //================================================================================
   // Cria instancia para geração do arquivo em XML
   //================================================================================
   IF _lXLSX
     _oExcel := FwMsExcelXlsx():New()//FwMsExcelXlsx(): NOVA CLASSE para gera XLSX: https://tdn.totvs.com/display/public/framework/FWMsExcelXlsx
	 //_aXlxs:=ClassMethArr( _oExcel, .T. ) //PARA TESTES
     //_lHabilitou:=_oExcel:SetWriteinFile(.T.)//Caso essa opção seja utilizada a geração da planilha não mais irá consumir memória ram do servidor
   ELSE
     _oExcel := FWMsExcelEx():New()//FWMSEXCEL():New() ==> FWMsExcelEx(): NOVA CLASSE para gera XML: https://tdn.totvs.com/display/public/framework/FWMsExcelEx
	 _aXlxs:=ClassMethArr( _oExcel, .T. )
   ENDIF

   If ! _lCriaPastas  // Cria uma única pasta para um array de dados simples.

      //================================================================================
      // Cria a pasta/Planilha
      //================================================================================   
      _oExcel:AddworkSheet(_cNomePlan)
   
      //================================================================================
      // Adiciona uma tabela na planilha.
      //================================================================================   
      _oExcel:AddTable(_cNomePlan,_cTitulo,_lComCab)

      //================================================================================
      // Adiciona as colunas da tabela e suas formatações. 
      //================================================================================   
      For _nI := 1 To Len(_aCabecalho)        
          IF _lXLSX
                              //Nome Planilha ,TituloPlanilha ,Titulo Coluna      ,Alinhamento        , Formatação        , Totaliza         ,cPicture          )   
             _oExcel:AddColumn(_cNomePlan     ,_cTitulo       ,_aCabecalho[_nI,1] ,_aCabecalho[_nI,2] ,_aCabecalho[_nI,3] ,_aCabecalho[_nI,4],IF(LEN(_aCabecalho[_nI])>4,_aCabecalho[_nI,5],))
          ELSE
                               //Nome Planilha ,TituloPlanilha ,Titulo Coluna      ,Alinhamento        , Formatação        , Totaliza         )   
             _oExcel:AddColumn(_cNomePlan     ,_cTitulo       ,_aCabecalho[_nI,1] ,_aCabecalho[_nI,2] ,_aCabecalho[_nI,3] ,_aCabecalho[_nI,4])                                       
		  ENDIF
      Next
   
      IF ! _lEnviaEmail
         IF _lXLSX
            _oExcel:SetFontSize(10)// Tamanho da fonte.
            _oExcel:SetBold(.F.)   // Efeito Negrito.         
         ELSE
           //================================================================================
           // Define as formatações do Titulo PRINCIPAL CENTRALIZADO 1
           //================================================================================   
            _oExcel:SetTitleSizeFont(16)             // Tamanho da fonte.
            _oExcel:SetTitleBold(.T.)                // Efeito Negrito.         
            _oExcel:SetTitleFrColor(AZUL_EM_HEXA)    // Cor da fonte do título.
            _oExcel:SetTitleBgColor(LARANJA_EM_HEXA) // Cor de fundo do título 
		    _oExcel:SetTitleHeight(22)               // Altura da linha
		 ENDIF
	  ENDIF
      
      //================================================================================
      // Monta as colunas e linhas de dados do relatório.
      //================================================================================      
      Do Case
         Case _cTipoGeracao == "GERACAO_POR_ARRAY"       
            _nItemDif:=0
            _cTot  := ALLTRIM(STR(Len(_aDetalhe)))
            For _nI := 1 To Len(_aDetalhe)
               _aItem := Aclone(_aDetalhe[_nI])

               IF Len(_aCabecalho) <> LEN(_aItem)
                  _nItemDif:=LEN(_aItem)
                  ASIZE(_aItem,Len(_aCabecalho))
                  //LOOP    
               ENDIF
               IF VALTYPE(_oProc) = "O"//Tem que ser o objeto da função FWMSGRUN()
                  _oProc:cCaption := ("Lendo Registro: " + Alltrim(STR(_nI)) + " de " + _cTot )
                  ProcessMessages()
               ENDIF   
               _oExcel:AddRow(_cNomePlan,_cTitulo,_aItem)   
            Next
            IF _nItemDif > 0
               If _lScheduller
                //U_ITCONOUT("[ITGEREXCEL] - Quantidade de Colunas no cabeçalho ("+ALLTRIM( STR(Len(_aCabecalho)) )+") <> da quantidade de colunas dos dados ("+ALLTRIM( STR(_nItemDif) )+").")
               Else
                 U_ITMSG("Quantidade de Colunas no cabeçalho ("+ALLTRIM( STR(Len(_aCabecalho)) )+") <> da quantidade de colunas dos dados ("+ALLTRIM( STR(_nItemDif) )+").","Atenção","Entre em contato com a Area de TI.",1)
               EndIf  
            EndIf  
         Case _cTipoGeracao == "GERACAO_POR_TABELA"
              _cDetalhe := "{"
              For _nI := 1 To Len(_aCampos)
                  If _nI > 1 
                     _cDetalhe += ","
                  EndIf
                  _cDetalhe += _aCampos[_nI]                                   
              Next
              _cDetalhe += "}"
           
              _nI := 1   
              _nItemDif:=0
              (_cAliasTab)->(DbGoTop())
              Do While ! (_cAliasTab)->(Eof()) 

                  _aItem:=&(_cDetalhe)
                  IF Len(_aCabecalho) <> LEN(_aItem)
				     _nItemDif:=LEN(_aItem)
					 ASIZE(_aItem,Len(_aCabecalho))
					 //LOOP    
			      ENDIF

                 _oExcel:AddRow(_cNomePlan,_cTitulo,_aItem)              
              
                 (_cAliasTab)->(DbSkip()) 

              EndDo

              IF _nItemDif > 0
                 If _lScheduller
                   //U_ITCONOUT("[ITGEREXCEL] - Quantidade de Colunas no cabeçalho ("+ALLTRIM( STR(Len(_aCabecalho)) )+") <> da quantidade de colunas dos dados ("+ALLTRIM( STR(_nItemDif) )+").")
                 Else
                    U_ITMSG("Quantidade de Colunas no cabeçalho ("+ALLTRIM( STR(Len(_aCabecalho)) )+") <> da quantidade de colunas dos dados ("+ALLTRIM( STR(_nItemDif) )+").","Atenção","Entre em contato com a Area de TI.",1)
                 EndIf  
              EndIf  

      EndCase
   Else // Cria várias pastas para um array de dados multiplo.
      For _nJ := 1 To Len(_aCabecalho)
	      _cNomePlan  := _aCabecalho[_nJ,1]
          _aCabecPlan := _aCabecalho[_nJ,2]
		  _aDadosPlan := _aDetalhe[_nJ]
		  IF (LEN(_aDadosPlan) = 0 .OR. LEN(_aCabecPlan) = 0)
             If _lScheduller
               //U_ITCONOUT('[ITGEREXCEL] - Planilha: "'+_cNomePlan+'" sem dados para gerar.')
             Else
	            U_ITMSG('Planilha: "'+_cNomePlan+'" sem dados para gerar.','Atenção!',,1)
			ENDIF
			 _oExcel:DeActivate() 
		     Break
		  ENDIF
          IF _nJ > 0 .AND. Len(_aCabecPlan) <> LEN(_aDadosPlan[1])
             If _lScheduller
               //U_ITCONOUT("[ITGEREXCEL] - Quantidade de Colunas no cabeçalho ("+ALLTRIM( STR(Len(_aCabecPlan)) )+") <> da quantidade de colunas dos dados ("+ALLTRIM( STR(LEN(_aDadosPlan[1])) )+").")
             Else
                U_ITMSG("Quantidade de Colunas no cabeçalho ("+ALLTRIM( STR(Len(_aCabecPlan)) )+") <> da quantidade de colunas dos dados ("+ALLTRIM( STR(LEN(_aDadosPlan[1])) )+").","Atenção","Entre em contato com a Area de TI.",1)
             EndIf      
		     _oExcel:DeActivate()      
             Break
		  ENDIF

	      //================================================================================
          // Cria a pasta/Planilha
          //================================================================================   
          _oExcel:AddworkSheet(_cNomePlan)
   
          //================================================================================
          // Adiciona uma tabela na planilha.
          //================================================================================   
          _oExcel:AddTable (_cNomePlan,_cTitulo,_lComCab)
   
          //================================================================================
          // Adiciona as colunas da tabela e suas formatações. 
          //================================================================================   
          For _nI := 1 To Len(_aCabecPlan)        
              IF _lXLSX
                                  //Nome Planilha ,TituloPlanilha ,Titulo Coluna      ,Alinhamento        , Formatação        , Totaliza         ,cPicture          )   
                 _oExcel:AddColumn(_cNomePlan     ,_cTitulo       ,_aCabecPlan[_nI,1] ,_aCabecPlan[_nI,2] ,_aCabecPlan[_nI,3] ,_aCabecPlan[_nI,4],IF(LEN(_aCabecPlan[_nI])>4,_aCabecPlan[_nI,5],))
              ELSE
                                   //Nome Planilha ,TituloPlanilha ,Titulo Coluna      ,Alinhamento        , Formatação        , Totaliza         )   
                 _oExcel:AddColumn(_cNomePlan     ,_cTitulo       ,_aCabecPlan[_nI,1] ,_aCabecPlan[_nI,2] ,_aCabecPlan[_nI,3] ,_aCabecPlan[_nI,4])                                       
		      ENDIF
          Next
   
          IF ! _lEnviaEmail
             IF _lXLSX
                _oExcel:SetFontSize(10)// Tamanho da fonte.
                _oExcel:SetBold(.F.)   // Efeito Negrito.         
             ELSE
               //================================================================================
               // Define as formatações do Titulo PRINCIPAL CENTRALIZADO 2
               //================================================================================   
               _oExcel:SetTitleSizeFont(16)             // Tamanho da fonte.
               _oExcel:SetTitleBold(.T.)                // Efeito Negrito.         
               _oExcel:SetTitleFrColor(AZUL_EM_HEXA)    // Cor da fonte do título.
               _oExcel:SetTitleBgColor(LARANJA_EM_HEXA) // Cor de fundo do título 
		       _oExcel:SetTitleHeight(22)               // Altura da linha
             ENDIF
          ENDIF
      
          //================================================================================
          // Monta as colunas e linhas de dados do relatório.
          //================================================================================      
          Do Case
             Case _cTipoGeracao == "GERACAO_POR_ARRAY"       
                  For _nI := 1 To Len(_aDadosPlan)               
                      _aItem := Aclone(_aDadosPlan[_nI])                    
                      _oExcel:AddRow(_cNomePlan,_cTitulo,_aItem)   
                  Next
          
             Case _cTipoGeracao == "GERACAO_POR_TABELA"
                  If _lScheduller
                    //U_ITCONOUT("[ITGEREXCEL] - A opção de geraçãode relatório em Excel em várias pastas não está disponível para geração por Tabela de dados.")
                  Else
                     u_itmsg("A opção de geraçãode relatório em Excel em várias pastas não está disponível para geração por Tabela de dados.","Atenção",,1)
                  EndIf
            
			      Break           
          EndCase
      Next

   EndIf

   IF !_lEnviaEmail
      IF !_lXLSX
         //================================================================================
         // Formatação DOS TÍTULOS DAS COLUNAS.
         //================================================================================      
         _oExcel:SetFrColorHeader(VERMELHO_EM_HEXA)    // Cor da fonte dos cabeçalhos das colunas.
         _oExcel:SetBgColorHeader(AZUL_CLARO_EM_HEXA)  // Cor de fundo dos cabeçalhos das colunas. 
	  ENDIF
   ENDIF
   IF VALTYPE(_aPergunte) = "A"
      
	  _cNomePlan:=_cTitulo:="Parametros"
	  //================================================================================
      // Cria a pasta/Planilha
      //================================================================================   
      _oExcel:AddworkSheet(_cNomePlan)
   
      //================================================================================
      // Adiciona uma tabela na planilha.
      //================================================================================   
      _oExcel:AddTable (_cNomePlan,_cTitulo)
   
      //================================================================================
      // Adiciona as colunas da tabela e suas formatações. 
      //================================================================================   
                       //Nome Planilha ,TituloPlanilha ,Titulo Coluna         ,Alinhamento , Formatação  , Totaliza)   
      _oExcel:AddColumn(_cNomePlan     ,_cTitulo       ,"Posicao da Pergunta ",2           ,1            ,.F.      )                                       
      _oExcel:AddColumn(_cNomePlan     ,_cTitulo       ,"Titulo da Pergunta  ",1           ,1            ,.F.      )                                       
      _oExcel:AddColumn(_cNomePlan     ,_cTitulo       ,"Resposta da Pergunta",2           ,1            ,.F.      )                                       
      IF _lXLSX
         _oExcel:SetBold(.F.)   // Efeito Negrito.         
	  ELSE
         //================================================================================
         // Define as formatações do Titulo PRINCIPAL CENTRALIZADO 3
         //================================================================================   
         _oExcel:SetTitleBold(.T.)                // Efeito Negrito.         
         _oExcel:SetTitleFrColor(AZUL_EM_HEXA)    // Cor da fonte do título.
         _oExcel:SetTitleBgColor(LARANJA_EM_HEXA) // Cor de fundo do título 
		 _oExcel:SetTitleHeight(22)               // Altura da linha
	  ENDIF
         //================================================================================
      // Monta as colunas e linhas de dados do relatório.
      //================================================================================      
      For _nI := 1 To Len(_aPergunte)               
          _aItem := Aclone(_aPergunte[_nI])                    
          _oExcel:AddRow(_cNomePlan,_cTitulo,_aItem)   
      Next          
   
   ENDIF
   //================================================================================
   // Gera o arquivo XML no diretório indicado.
   //================================================================================      

   _oExcel:Activate()
   _oExcel:GetXMLFile(_cDiretorio+"\"+_cNomeArq)//Esse metodo serve tanto para Classe FWMsExcelEx() quanto para FwMsExcelXlsx()
   _oExcel:DeActivate() 

   //================================================================================
   // Abre o arquivo XML. Para o arquivo ser aberto como planilha, o Windows deve
   // estar configurado para abrir arquivos XML com o Excel, ou com similares como 
   // Libre Office.
   //================================================================================       
   If ! _lScheduller
		IF !lHtml
			//ShellExecute("open", _cNomeArq, "", _cDiretorio, 1)
			ShellExecute("open", _cDiretorio+"\"+_cnomearq, "", _cDiretorio, 1) 
		ELSE
               //===================================================================
			   // Chama uma tela para conferência / Alteração dos dados do E-mail.  
			   //===================================================================
		   If ! _lEnviaEmail // Exibe tela de alteração de dados de e-mail, apenas quando a rotina não envia e-mails automaticamente.
			   If !__CopyFile( _cDiretorio+"\"+_cNomeArq , _cPthArq+_cNomeArq) 
			      _cDiretorio:= _cPthArq+_cNomeArq
			      _cEmlLog   := "" 
                  cGetPara   := UsrRetMail(__cUserID)
			      _cGetCc    := Space(200) 
			      cGetAssun  := _cTitulo + Space(200) 
			      _cMsgEml   := "ARQUIVO GERADO ANEXO: "+_cDiretorio
			      _cFrom     := _aConfig[01] 
                  If U_ITTLMAIL(@_cFrom,@cGetPara,@_cGetCc,@cGetAssun,@_cMsgEml,_cTitulo)  
                     //ITEnvMail(cFrom ,cEmailTo,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach    ,cAccount    ,cPassword   ,cServer     ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
                     U_ITENVMAIL(_cFrom, cGetPara,_cGetCc  ,         ,cGetAssun,_cMsgEml ,_cDiretorio,_aConfig[01],_aConfig[02],_aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
	           	   
				     U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+"E-mail para: "+AllTrim(cGetPara)+";"+AllTrim(_cGetCc),"Envio do E-MAIL","Anexo: "+_cDiretorio,3)
			      Else 
                     U_ITMSG("Cancelamento do envio de E-mail para: "+AllTrim(cGetPara)+";"+AllTrim(_cGetCc),"Cancelamento de Envio do E-MAIL",,1)
			      EndIf
			   //Else 
               //   U_ITENVMAIL(_cFrom, cGetPara,_cGetCc  ,         ,cGetAssun,_cMsgEml ,_cDiretorio,_aConfig[01],_aConfig[02],_aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )	           	   
			   //   U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+"E-mail para: "+AllTrim(cGetPara)+";"+AllTrim(_cGetCc),"Envio do E-MAIL",,3)
			   EndIf  
			ENDIF
		ENDIF
   EndIf
              
End Sequence   

Return Nil

/*
===============================================================================================================================
Programa----------: LSTAGE
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 08/08/2016
Descrição---------: Consulta para a pergunta de tipo de agenda - F3: LSTAGE
Parametros--------: _cPerg - Configuração das Perguntas
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function LSTAGE()
Local _nI			:= 0

Private nTam		:= 0
Private nMaxSelect	:= 0
Private aCat		:= {}
Private MvRet		:= Alltrim( ReadVar() )
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

IF !LEFT(UPPER(MvRet),3) == "M->"//POR CASUA DO VISUALIZAR
   IF "->" $ MvRet
      IF (_nPosMV:=AT(">",MvRet)) > 0 
	     MvRet:="M->"+SUBSTR(MvRet,(_nPosMV+1))
      ENDIF   
   ENDIF
ENDIF

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//================================================================================
// Tratamento para carregar variaveis da lista de opcoes já selecionadas
//================================================================================
nTam		:= 1
cTitulo		:= "Tipos de Entrega"

//A=AGENDADA;I=IMEDIATA;M=AGENDADA C/MULTA;P=AGUARD. AGENDA;R=REAGENDAR;N=REAGENDAR C/MULTA;T=Agend. pelo Transp;O=AGENDADO PELO OP.LOG

MvParDef := ""

aCat := U_TipoEntrega() 

IF TYPE("_cCampos_F3_LSTTPA") <> "C"//Essa variavel deve ser iniciada com o campo que vc quer que selecione 1 só no programa custumizado
   _cCampos_F3_LSTTPA:=""
ENDIF		

IF STRTRAN(MvRet,"M->","") $ "C5_I_AGEND/A1_I_AGEND"+_cCampos_F3_LSTTPA//Se tiver mais um campo em programa padrão para usar esse F3 coloque nessa lista se não ser para inicia a variavel _cCampos_F3_LSTTPA
   nMaxSelect:=1// ESSE F3 É PARA SELECIONAR UM SÓ
ELSE
   nMaxSelect:=LEN(aCat)// ESSE F3 É PARA SELECIONAR MAIS DE UM 
ENDIF

For _ni := 1 to len(aCat)
	MvParDef += substr(alltrim(aCat[_ni]),1,1) //"AIPMRNTO"
Next	

MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )

//================================================================================
// Executa funcao que monta tela de opcoes
//================================================================================
 
IF F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

    //================================================================================
    // Tratamento para separar retorno com barra ";"
    //================================================================================
    &MvRet := ""
    
    For _nI := 1 To Len( MvPar ) //Step 1
    
    	If !( SubStr( MvPar , _nI , 1 ) $ " |*" )
    		&MvRet += SubStr( MvPar , _nI , 1 ) + ";"
    	EndIf
    	
    Next
    
    // Trata para tirar o ultimo caracter
	IF !EMPTY(&MvRet)
       &MvRet := SubStr( &MvRet , 1 , Len( &MvRet ) - 1 )
	ELSE
       &MvRet := SPACE(((nMaxSelect*(nTam+1)))-1)// No. de selecao (maxima * (tam da chave + ;) )- o ultimo ;
	ENDIF

ENDIF

Return(.T.)

/*
===============================================================================================================================
Programa----------: LSTTCA
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 08/08/2016
Descrição---------: Consulta para a pergunta de tipo de carga
Parametros--------: _cPerg - Configuração das Perguntas
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function LSTTCA()
Local _nI			:= 0

Private nTam		:= 0
Private nMaxSelect	:= 0
Private aCat		:= {}
Private MvRet		:= Alltrim( ReadVar() )
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""


#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//================================================================================
// Tratamento para carregar variaveis da lista de opcoes já selecionadas
//================================================================================
nTam		:= 1
nMaxSelect	:= 2
cTitulo		:= "Tipo de Carga"

MvParDef := "12"
aAdd( aCat , "Paletizada" 	)
aAdd( aCat , "Batida" 		)
	
MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )

//================================================================================
// Executa funcao que monta tela de opcoes
//================================================================================

F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

//================================================================================
// Tratamento para separar retorno com barra ";"
//================================================================================
&MvRet := ""

For _nI := 1 To Len( MvPar ) //Step 1

	If !( SubStr( MvPar , _nI , 1 ) $ " |*" )
		&MvRet += SubStr( MvPar , _nI , 1 ) + ";"
	EndIf
	
Next

//================================================================================
// Trata para tirar o ultimo caracter
//================================================================================
&MvRet := SubStr( &MvRet , 1 , Len( &MvRet ) - 1 )

Return(.T.)                                                                                                                                                 

/*
===============================================================================================================================
Função----------: IGravSCY
Autor-----------: Júlio de Paula Paz
Data da Criacao-: 30/08/2016
Descrição-------: Rotina para gravar histórico da tabela SC7 (Pedidos de Compras)na tabela SCY(Histórico do pedido de compras).
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function IGravSCY(_cFilial, _cNrPedido)                           
Local _lRet 
Local _aOrd := SaveOrd({"SC7","SCY"})
Local _nRegAtu := SC7->(Recno())
Local _nNovaVersao  // CY_VERSAO
Local _nI, _cSufixo  
Local _cCmpSC7, _cCmpSCY, _cCampo


Begin Sequence 
  _nNovaVersao := 0
    
   SCY->(DbSetOrder(1)) // CY_FILIAL+CY_NUM+CY_ITEM+CY_VERSAO+CY_SEQUEN
   SCY->(DbSeek(_cFilial+_cNrPedido))
   Do While ! SCY->(Eof()) .And. SCY->CY_FILIAL+SCY->CY_NUM == _cFilial+_cNrPedido
      If Val(AllTrim(SCY->CY_VERSAO)) > _nNovaVersao
         _nNovaVersao := Val(AllTrim(SCY->CY_VERSAO))
      EndIf
   
      SCY->(DbSkip())
   EndDo
   _nNovaVersao += 1

   SC7->(DbSetOrder(1)) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN 
   SC7->(DbSeek(_cFilial+_cNrPedido))
   Do While ! SC7->(Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == _cFilial+_cNrPedido   
      SCY->(RecLock("SCY",.T.))
      
      For _nI := 1 To  SC7->(Fcount())              
          _cSufixo := AllTrim(SubStr(SC7->(FieldName(_nI)),3,8))
          _cCmpSC7 := "SC7->"+SC7->(FieldName(_nI))
          _cCmpSCY := "SCY->CY"+_cSufixo          
          _cCampo  := "CY"+_cSufixo
          
          If SCY->(FieldPos(_cCampo)) > 0
             &(_cCmpSCY) := &(_cCmpSC7)          
          EndIf
      Next                              
      
      SCY->CY_VERSAO := StrZero(_nNovaVersao,TamSX3("CY_VERSAO")[1])
      
      SCY->(MsUnLock())
      
      SC7->(DbSkip())
   EndDo                
   
   SC7->(DbGoTo(_nRegAtu))
   
End Sequence 

RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa----------: LSTNNR
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Consulta múltipla para o cadastro de armazen
Parametros--------: Nenhum
Retorno-----------: .T.
===============================================================================================================================
*/
User Function LSTNNR()

Local i := 0

Local _aMvPar		:= {}
Local _aMvAju		:= {}
Local _aMvOri		:= {}
Local _ni

Private nTam      := 0
Private nMaxSelect:= 0
Private aCat      := {}
Private MvRet     := Alltrim(ReadVar())
Private MvPar     := ""
Private cTitulo   := ""
Private MvParDef  := ""
Private cAlias    := GetNextAlias()
IF TYPE("_cSeparador") <> "C"
   PRIVATE _cSeparador:=";"
ENDIF 

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//Tratamento para carregar variaveis da lista de opcoes
nTam:=2
nMaxSelect := 50 //75 / 3
cTitulo :="Armazens"


cGrpCus := " SELECT "
cGrpCus += " NNR_CODIGO,NNR_DESCRI "
cGrpCus += " FROM "+ RetSqlName("NNR") +" NNR "
cGrpCus += " WHERE D_E_L_E_T_ = ' ' "
cGrpCus += " AND NNR_FILIAL  = '" + xFilial("NNR") + "'"	
cGrpCus += " ORDER BY NNR_CODIGO"


MPSysOpenQuery( cGrpCus , cAlias)

while (cAlias)->(!Eof())

	MvParDef += strzero( val((cAlias)->NNR_CODIGO), ntam) 
	aAdd(aCat,AllTrim(StrTran( (cAlias)->NNR_DESCRI, "-", " " )))
	aadd(_aMvAju, strzero( val(NNR->NNR_CODIGO), ntam)  )
	aadd(_aMvOri, alltrim((cAlias)->NNR_CODIGO)  )
	(cAlias)->(dbSkip())

enddo

(cAlias)->( DBCloseArea() )
/*
//==========================================================================
//Trativa abaixo para no caso de uma alteracao do campo trazer todos
//os dados que foram selecionados anteriormente.                    
//==========================================================================
*/

If Len(AllTrim(&MvRet)) == 0
	
	MvPar:= PadR(AllTrim(StrTran(&MvRet,_cSeparador,"")),Len(aCat))
	&MvRet:= PadR(AllTrim(StrTran(&MvRet,_cSeparador,"")),Len(aCat))
	
Else
	
	_aMvPar := StrTokArr( &MvRet, _cSeparador )
	&MvRet := ""

	For _ni := 1 to len(_aMvPar)
	
		&MvRet += strzero( val(_aMvPar[_ni]), ntam) + _cSeparador		
	Next
	
	&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1)
	
	MvPar:= AllTrim(StrTran(&MvRet,_cSeparador,"/"))
	
EndIf

/*
//==========================================================================
//Somente altera o conteudo caso o usuario clique no botao ok
//==========================================================================
*/

//Executa funcao que monta tela de opcoes
If f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.,nTam,nMaxSelect)
	
	//Tratamento para separar retorno com barra _cSeparador
	&MvRet := ""

	for i:=1 to Len(MvPar) step nTam

		if !(SubStr(MvPar,i,1) $ " |*")
 
           If ascan(_aMvAju, alltrim(SubStr(MvPar,i,nTam ))) > 0
           
    			&MvRet  += _aMvOri[ascan(_aMvAju, alltrim(SubStr(MvPar,i,nTam )))] + _cSeparador
			
			Else
			
				&MvRet  += alltrim(SubStr(MvPar,i,nTam)) + _cSeparador
				
			Endif

		endIf

	next i
	
	//Trata para tirar o ultimo caracter
	&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1)
	
EndIf

Return(.T.)


/*
===============================================================================================================================
Programa--------: ValidaCredito()
Autor-----------: Alex Wallauer Ferreira
Data da Criacao-: 10/01/2017
Descrição-------: Valida Limite de Crédito do Cliente para gravação do Pedido de Venda.
Parametros------: nTotped - Valor total do PV - [Obrigatório]
----------------: cCodCli - Codigo do Cliente - [Obrigatório se não for alteração]
----------------: cLojCli - Loja do Cliente   - [Obrigatório se não for alteração]
----------------: lAltera - (.T.) Alteração com PV posicionado / (.F.) Inclusão e PV não existe 
----------------: bLiberacao - Padrão: {|| SC5->C5_I_LIBC == 2  }
----------------: dDtLimite  - Padrão: SC5->C5_I_LIBL
----------------: nValorLib  - Padrão: SC5->C5_I_LIBCV
----------------: nMoeda     - Padrão: SC5->C5_MOEDA
----------------: _cGerente  - Código do Gerente.      (SC5->C5_VEND3)
----------------: _cCoordena - Código do Coordenador.  (SC5->C5_VEND2)
----------------: _cSupervis - Código do Supervisor.   (SC5->C5_VEND4)
----------------: _cRepresen - Código do Representante.(SC5->C5_VEND1)
Retorno---------: _aRet - {"Descrição da avaliação","Tipo","Código","Complemento da Descrição da avaliação"}
                          |
                          |--> "Descrição da avaliação"                => Mensagem de rejeição ou sucesso.
                          |--> "Tipo"                                  => "B" = Bloqueado / "L" = Liberado
                          |--> "Código"                                => 1 = Limite Expirado | 2 = Atraso Titulos | 
                          |                                               3 = Limite Excedido | 4 = Risco | 5 = Automatico
                          |--> "Complemento da Descrição da avaliação" => Complemento da mensagem de rejeição ou sucesso.
===============================================================================================================================
*/
USER Function ValidaCredito( nTotped , cCodCli , cLojCli , lAltera , bLiberacao , dDtLimite , nValorLib , nMoeda, linclui , _cPedido, _cGerente, _cCoordena, _cSupervis, _cRepresen,_cCond )//U_ValidaCr(nTotped)

Local aAreaAux	  := GetArea()
Local cRisCli	  := ""
Local _aRet 	  := {"Outros","L","5"}
Local _cFilSA1    := xFilial("SA1")
Local _cDescRepr  := ""
Local _cRiscoVend := ""
//Local _cBroker    := ""
Local cCadCrd		:= "Filial de Crédito Bloqueada" //Chamado 46249 - Motivo Bloqueio
Local cLojaCrd		:= ""//Chamado 46249 - Motivo Bloqueio
Default lAltera   := .T.
Default nTotped   := 0
Default linclui   := .F.
                     
If linclui               
	Default cCodCli    := M->C5_CLIENTE
	Default cLojCli	   := M->C5_LOJACLI
	Default bLiberacao := {|| M->C5_I_LIBC == 2 } //Só usa quando lAltera = .T.
	Default dDtLimite  := M->C5_I_LIBL            //Só usa quando lAltera = .T.
	Default nValorLib  := M->C5_I_LIBCV           //Só usa quando lAltera = .T.
	Default nMoeda     := M->C5_MOEDA
	
	Default _cPedido   := M->C5_NUM
	Default _cGerente  := M->C5_VEND3
	Default _cCoordena := M->C5_VEND2
	Default _cSupervis := M->C5_VEND4
	Default _cRepresen := M->C5_VEND1
	Default _cCond     := M->C5_CONDPAG
Else
	Default cCodCli    := SC5->C5_CLIENTE
	Default cLojCli	   := SC5->C5_LOJACLI
	Default bLiberacao := {|| SC5->C5_I_LIBC == 2 } //Só usa quando lAltera = .T.
	Default dDtLimite  := SC5->C5_I_LIBL            //Só usa quando lAltera = .T.
	Default nValorLib  := SC5->C5_I_LIBCV           //Só usa quando lAltera = .T.
	Default nMoeda     := SC5->C5_MOEDA
	
	Default _cPedido   := SC5->C5_NUM
	Default _cGerente  := SC5->C5_VEND3
	Default _cCoordena := SC5->C5_VEND2
	Default _cSupervis := SC5->C5_VEND4
	Default _cRepresen := SC5->C5_VEND1
	Default _cCond     := SC5->C5_CONDPAG
EndIf

Begin Sequence
_cDescRepr := ""
SA3->(DbSetOrder(1))
If ! Empty(_cRepresen)
	If SA3->(DbSeek(xFilial("SA3")+_cRepresen))
		_cRiscoVend := SA3->A3_I_RISCO
		//_cBroker    := SA3->A3_I_VBROK	
		Do While ! SA3->(Eof()) .And. SA3->(A3_FILIAL+A3_COD) == xFilial("SA3")+_cRepresen
			If SA3->A3_MSBLQL == "1"
				_cDescRepr += " Representante("+_cRepresen+"). "
			EndIf
			
			SA3->(DbSkip())
		EndDo
	EndIf
EndIf

If ! Empty(_cCoordena)
	If SA3->(DbSeek(xFilial("SA3")+_cCoordena))
		Do While ! SA3->(Eof()) .And. SA3->(A3_FILIAL+A3_COD) == xFilial("SA3")+_cCoordena
			If SA3->A3_MSBLQL == "1"
				_cDescRepr += " Coordenador("+_cCoordena+"). "
			EndIf
			
			SA3->(DbSkip())
		EndDo
	EndIf
EndIf

If ! Empty(_cGerente)
	If SA3->(DbSeek(xFilial("SA3")+_cGerente))
		Do While ! SA3->(Eof()) .And. SA3->(A3_FILIAL+A3_COD) == xFilial("SA3")+_cGerente
			If SA3->A3_MSBLQL == "1"
				_cDescRepr += " Gerente("+_cGerente+"). "
			EndIf
			
			SA3->(DbSkip())
		EndDo
	EndIf
EndIf

If ! Empty(_cSupervis)
	If SA3->(DbSeek(xFilial("SA3")+_cSupervis))
		Do While ! SA3->(Eof()) .And. SA3->(A3_FILIAL+A3_COD) == xFilial("SA3")+_cSupervis
			If SA3->A3_MSBLQL == "1"
				_cDescRepr += " Supervisor("+_cSupervis+"). "
			EndIf
			
			SA3->(DbSkip())
		EndDo
	EndIf
EndIf

If ! Empty(_cDescRepr)
	_aRet :=  {"Está(ão) bloqueado(s) ou inativo(s) o(s): " + _cDescRepr,"B","5","Verifique a situação Inativo(s) dele(s) no cadastro de vendedores."}
	Break
EndIf

If !(  Empty(cCodCli) .Or. Empty(cLojCli) .Or. Empty(nTotped) )
	
	//-- Posiciona no Cliente Atual (Cód.+Loja) para recuperar o Código do Risco e a Validade do Limite de Crédito --//
	SA1->( DBSetOrder(1) )
	
	If SA1->( DBSeek( _cFilSA1 + cCodCli + cLojCli) )
		
		cRisCli := AllTrim( UPPER(SA1->A1_RISCO) )// Recupera o Código do Risco do Cliente/Loja Atual
		dDtLimCr:= SA1->A1_VENCLC			      // Recupera a Data de Validade do Limite de Crédito
		SA1->( DBSeek( _cFilSA1 + cCodCli ) )
		DO WHILE SA1->(!EOF()) .AND. _cFilSA1 == SA1->A1_FILIAL .AND.  cCodCli == SA1->A1_COD
			IF !EMPTY(SA1->A1_LC) //Chamado 46249 - Motivo Bloqueio
				cLojaCrd := SA1->A1_LOJA //Chamado 46249 - Motivo Bloqueio
			If SA1->A1_MSBLQL <> "1"// Pega a data e risco da loja matriz
				cRisCli := AllTrim( UPPER(SA1->A1_RISCO) )   // Recupera o Código do Risco do Cliente/Loja Atual
				dDtLimCr:= SA1->A1_VENCLC			         // Recupera a Data de Validade do Limite de Crédito
				cCadCrd := ""  //Chamado 46249 - Motivo Bloqueio
				EXIT
			EndIf 
			ENDIF
			SA1->(DBSKIP())
		ENDDO

		If Alltrim(cRisCli) = "C" //.And. Alltrim(_cBroker) == "B"
			cRisCli := _cRiscoVend  
		EndIf		                                                      
		                                                       
		Do Case
			 
			//-- Verifica a Validade do Limite de Crédito do Cliete/Loja Atual
			Case dDtLimCr < Date()
				
					If !Empty(cCadCrd)  //Chamado 46249 - Motivo Bloqueio
						_aRet :=  {"Bloqueado por Limite de Crédito Expirado. "+cCadCrd,"B","1","A data de vencimento do Limite de Crédito está expirada e Bloqueada ["+ DtoC(dDtLimCr) +"]"}
					Else
						_aRet :=  {"Bloqueado por Limite de Crédito Expirado.","B","1","A data de vencimento do Limite de Crédito está expirada ["+ DtoC(dDtLimCr) +"]"}
					EndIf				
			
			Case _cCond == "001" .And. !Eval(bLiberacao)          

				_aRet := {"Bloqueado por Venda a Vista -- ConPgto = 001","B","3","Aguardar Liberação Completa" }
					
			Case cRisCli $ "AC" // Clientes com Risco "A" são liberados automaticamente.       
				
				If dDtLimCr < Date()
					
						If !Empty(cCadCrd)  //Chamado 46249 - Motivo Bloqueio
							_aRet := {"Bloqueado por Limite de Crédito Expirado. "+cCadCrd,"B","1","A data de vencimento do Limite de Crédito está expirada e Bloqueada ["+ DtoC(dDtLimCr) +"]"}
						Else
							_aRet := {"Bloqueado por Limite de Crédito Expirado.","B","1","A data de vencimento do Limite de Crédito está expirada ["+ DtoC(dDtLimCr) +"]"}
						EndIf
					
				//ELSEIf Eval(bLiberacao) .and. dDtLimite < date()
					
					//_aRet := {"Bloqueado por liberação completa de crédito expirada","B","3","O pedido excede o data de Liberação de Crédito: "+DTOC(dDtLimite)}
					
				Else
					
					_aRet := {"Liberado por risco A","L","5"}
					
				ENDIF
				
			Case Eval(bLiberacao)//SC5->C5_I_LIBC == 2 //Liberação completa de crédito
				
				If dDtLimite < date() //SC5->C5_I_LIBL < date()
					
					_aRet := {"Bloqueado por liberação completa de crédito expirada","B","3","O pedido excede o data de Liberação de Crédito: "+DTOC(dDtLimite)}
					
				Elseif (nTotped  - nValorLib) > 0.02 //nTotped > SC5->C5_I_LIBCV
					
					_aRet := {"Bloqueado por valor de liberação completa excedido","B","3"}
					
				Else                      
					
					_aRet := {"Liberação completa de crédito","L","5"}
					
				Endif  
			Case cRisCli == "E" //Clientes com Risco "E" são bloqueados automaticamente.
				
				_aRet := {"Bloqueado por Risco E" ,"B","4","Limite de Crédito do Cliente bloqueado pelo Código do Risco [E]"}
				
			Case cRisCli $ ("BD") //Clientes com Risco "B", "C", "D" passam pela análise de Crédito.
				//B - Risco Normal --> C - Brokser --> D - Varejo
				//-- Verifica se existem Títulos em Atraso do Cliente --//
 				
				If _aRet[1] == "Outros" .And. u_VeriTit(cCodCli)//U_AOMS061Z( cCodCli )
					
						If !Empty(cCadCrd)  //Chamado 46249 - Motivo Bloqueio
							_aRet := {cCadCrd+" - Loja: "+cLojaCrd,"B","3","O Cadastro de Cliente Sem Loja de Crédito Disponível."}
						Else
							_aRet := {"Bloqueado por Limite de Crédito Excedido.","B","3","O pedido excede o atual Limite de Crédito do Cliente."}
						EndIf
					
				EndIf
				
				//-- Verifica se o Pedido atual 'cabe' no Limite de Crédito disponível para o Cliente --//
				If _aRet[1] == "Outros" .And. u_VERISAL( cCodCli , cLojCli , nTotped , linclui , _cPedido )
					
					_aRet := {"Bloqueado por Limite de Crédito Excedido.","B","3","O pedido excede o atual Limite de Crédito do Cliente."}
					
				EndIf
				
				
		EndCase
		
		//-- Se não achou motivo de bloqueio de crédito manda liberação do pedido
		If _aRet[1] == "Outros"                        
			
			_aRet := {"Aprovado em análise de crédito","L","5"}
			
		Endif
		
	EndIf
	
EndIf

End Sequence

RestArea(aAreaAux)

Return( _aRet )

/*
===============================================================================================================================
Programa--------: VeriTit()  antiga U_AOMS061Z()
Autor-----------: Alexandre Villar
Data da Criacao-: 14/02/2014
Descrição-------: Verifica se os Clientes possuem títulos em aberto vencidos a mais de x dias de acordo com a parametrização.
Parametros------: cCodCli := Código do Cliente do Pedido
                : cRisCli := Código do Risco do Cliente																															   
Retorno---------: lRet := Informa se existem títulos em aberto com vencimento acima do limite (.T. = Sim / .F. = Não )
===============================================================================================================================
*/
User Function VeriTit(cCodCli,cRisCli) //AOMS061Z( cCodCli )

Local lRet		:= .F.
Local cAlias	:= GetNextAlias()
Local _cQuery	:= ""
Local nDiasAux  := 3


Private _nvenc	:= 0
Default cRisCli := ""
  
Do Case
	Case cRisCli == "A'
		nDiasAux := U_ITGETMV("ITDIASRISA",3) //Qtd Dias Risco A
	Case cRisCli == "B'
		nDiasAux := U_ITGETMV("ITDIASRISB",3) //Qtd Dias Risco B                          	
	Case cRisCli == "C'
		nDiasAux := U_ITGETMV("ITDIASRISC",3) //Qtd Dias Risco C
	Case cRisCli == "D'
		nDiasAux := U_ITGETMV("ITDIASRISD",3) //Qtd Dias Risco D
EndCase


_cQuery := " SELECT "
_cQuery += "		COUNT(*) AS QTTITVEN "
_cQuery += "	FROM "+ RetSqlName("SE1") +" SE1 "
_cQuery += "       LEFT JOIN "+ RetSqlName("ZAR") +" ZAR ON ZAR.ZAR_FILIAL = ' ' AND ZAR.ZAR_COD = SE1.E1_I_CART AND ZAR.D_E_L_E_T_	= ' ' "
_cQuery += " WHERE "
_cQuery += "     ( SE1.E1_CLIENTE = '"+ cCodCli +"' OR SE1.E1_I_CLIEN	= '"+ cCodCli +"' ) " 
_cQuery += "	AND SE1.E1_SALDO + SE1.E1_SDACRES - SE1.E1_SDDECRE > 0 "
_cQuery += "	AND SE1.E1_TIPO		NOT IN ('RA','NCC') "
_cQuery += "	AND SE1.E1_VENCREA < '"+ DtoS( Date() - nDiasAux ) +"' "
_cQuery += "	AND SE1.D_E_L_E_T_ = ' ' "
_cQuery += "    AND SE1.E1_I_AVACC <> 'N'"
_cQuery += "    AND (ZAR.ZAR_AVACC  <> 'N' OR SE1.E1_I_CART = ' ') "

MPSysOpenQuery( _cQuery , cAlias )
(cAlias)->( DBGoTop() )
If (cAlias)->(!Eof()) .And. (cAlias)->QTTITVEN > 0
	lRet := .T.
EndIf

_nvenc := (cAlias)->QTTITVEN

(cAlias)->( DBCloseArea() )

Return( lRet )

/*
===============================================================================================================================
Programa--------: VERISAL
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/02/2016
Descrição-------: Valida o saldo disponível no Limite de Crédito do Cliente para verificar se o pedido atual excede.
Parametros------: cCodCli - Código do Cliente do Pedido
----------------: cLojCli - Código da Loja do Cliente do Pedido
----------------: nTotped - Valor total do PV - obrigatório
Retorno---------: lRet := Informa se o Pedido atual 'cabe' no Limite disponível ( .F. = Sim / .T. = Não )
===============================================================================================================================
*/
User Function VeriSal( cCodCli , cLojCli , nTotped, linclui , _cPedido)

Local lRet		:= .F.
Local cAlias	:= GetNextAlias()
Local _cQuery	:= ""
Public _nLimCr	
Public nValUso	
Public _nvalped 
Public _nvalzw  

_nLimCr	:= 0
nValUso	:= 0
_nvalped := 0
_nvalzw  := 0


//-- Verifica o Limite de Crédito Cadastrado para o Cliente --//
_cQuery := " SELECT "
_cQuery += "     SUM( SA1.A1_LC ) AS LIMITE "
_cQuery += " FROM "+ RetSqlName("SA1") +" SA1 "
_cQuery += " WHERE "
_cQuery += "     SA1.A1_COD		= '"+ cCodCli +"' "
_cQuery += " AND SA1.D_E_L_E_T_	= ' ' "
_cQuery += " AND SA1.A1_MSBLQL  = '2' "
_cQuery += " AND SA1.A1_VENCLC  >= '"+ DtoS(Date()) +"' "

MPSysOpenQuery( _cQuery , cAlias )
(cAlias)->( DBGoTop() )
If (cAlias)->(!Eof()) .And. (cAlias)->LIMITE > 0
	_nLimCr := (cAlias)->LIMITE
EndIf

(cAlias)->( DBCloseArea() )


//-- Verifica o saldo atual em aberto do Cliente --//
_cQuery := " SELECT "
_cQuery += "     SUM( SE1.E1_SALDO + SE1.E1_SDACRES - SE1.E1_SDDECRE ) AS VALUSO "
_cQuery += " FROM "+ RetSqlName("SE1") +" SE1 "
_cQuery += "   LEFT JOIN "+ RetSqlName("ZAR") +" ZAR ON ZAR.ZAR_FILIAL = ' ' AND ZAR.ZAR_COD = SE1.E1_I_CART AND ZAR.D_E_L_E_T_	= ' ' "
_cQuery += " WHERE "
_cQuery += "     ( SE1.E1_CLIENTE	= '"+ cCodCli +"' OR SE1.E1_I_CLIEN	= '"+ cCodCli +"' ) " 
_cQuery += " AND SE1.D_E_L_E_T_	= ' ' "
_cQuery += " AND SE1.E1_TIPO		NOT IN ('RA','NCC') "
_cQuery += " AND SE1.E1_SALDO + SE1.E1_SDACRES - SE1.E1_SDDECRE > 0 "
_cQuery += " AND SE1.E1_I_AVACC <> 'N'"
_cQuery += " AND (ZAR.ZAR_AVACC  <> 'N' OR SE1.E1_I_CART = ' ') "

MPSysOpenQuery( _cQuery , cAlias )
(cAlias)->( DBGoTop() )
If (cAlias)->(!Eof()) .And. (cAlias)->VALUSO > 0
	nValUso := (cAlias)->VALUSO
EndIf

(cAlias)->( DBCloseArea() )


//-- Verifica o saldo de pedidos em carteira do cliente --//
_cQuery := " SELECT "
_cQuery += "     SUM( ((SC6.C6_QTDVEN - SC6.C6_QTDENT)/SC6.C6_QTDVEN) * SC6.C6_VALOR ) AS VALPED "
_cQuery += " FROM "+ RetSqlName("SC6") +" SC6,  "+ RetSqlName("SC5") +" SC5,  "+ RetSqlName("SF4") +" SF4"
_cQuery += " WHERE "
_cQuery += "     SC6.C6_CLI	= '"+ cCodCli +"' " 
_cQuery += " AND SC6.D_E_L_E_T_	= ' ' "
_cQuery += " AND SC5.D_E_L_E_T_	= ' ' "
_cQuery += " AND SC5.C5_FILIAL = SC6.C6_FILIAL "
_cQuery += " AND SC5.C5_NUM = SC6.C6_NUM "
_cQuery += " AND SC5.C5_TIPO = 'N' "
_cQuery += " AND SC6.C6_QTDVEN <> 0 "
_cQuery += " AND SC5.C5_I_BLCRE <> 'B' AND SC5.C5_I_BLCRE <> 'R' "
_cQuery += " AND SC6.C6_BLQ <> 'R' "
_cQuery += " AND SF4.F4_CODIGO = SC6.C6_TES"
_cquery += " AND SF4.D_E_L_E_T_ = ' ' "
_cquery += " AND SF4.F4_FILIAL = SC6.C6_FILIAL "
_cquery += " AND SF4.F4_DUPLIC = 'S' "

IF !EMPTY(_cPedido)
   _cQuery += " AND SC5.C5_NUM <> '"+_cPedido+"'"//Não pode contar o pedido atual em nenhum hipotise
ENDIF

MPSysOpenQuery( _cQuery , cAlias )
(cAlias)->( DBGoTop() )
If (cAlias)->(!Eof()) .And. (cAlias)->VALPED > 0
	_nValped := (cAlias)->VALPED
EndIf

(cAlias)->( DBCloseArea() )

//-- Verifica o saldo de pedidos em carteira do cliente --//
_cQuery := " SELECT "
_cQuery += "     SUM( SZW.ZW_QTDVEN * SZW.ZW_PRCVEN ) AS VALPED "
_cQuery += " FROM "+ RetSqlName("SZW") +" SZW" 
_cQuery += " WHERE "
_cQuery += "     SZW.ZW_CLIENTE	= '"+ cCodCli +"' " 
_cQuery += " AND SZW.D_E_L_E_T_	= ' ' "
_cQuery += " AND (SZW.ZW_STATUS = 'L' OR SZW.ZW_STATUS = 'D') "
_cQuery += " AND SZW.ZW_NUMPED = ' ' "
_cQuery += " AND SZW.ZW_TIPO <> '10' "//Diferente de Bonificação
_cQuery += " AND SZW.ZW_BLQLCR <> 'B' AND SZW.ZW_BLQLCR <> 'R'"


MPSysOpenQuery( _cQuery , cAlias )
(cAlias)->( DBGoTop() )
If (cAlias)->(!Eof()) .And. (cAlias)->VALPED > 0
	_nValzw := (cAlias)->VALPED
EndIf

(cAlias)->( DBCloseArea() )


//-- Se o Pedido atual 'couber' no Limite de Crédito atual retorna .F. --//
if !linclui .AND. EMPTY(_cPedido)//se não é inclusão manual do pedido não conta o valor do pedido na análise pois já está na base de pedidos em carteira

	nTotped := 0

Endif


lRet := ( ( _nLimCr - nValUso -_nvalped - _nvalzw - nTotped ) < 0 )

Return( lRet )

/*
============================================================================================================================================================================
Programa----------: LockPed()
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/01/2017
Descrição---------: Testa lock de pedido para SB2 e SA1 om prevenção de deadlock
Parametros--------: _ccliente - Cliente do pedido
					_cloja - Loja do pedido
					_acols - lista de filial, produtos, armazém
RETORNO-----------: DEVOLVE .T. SE TIVER CLIENTE OU QQ ITEM TRAVADO COM ALGUM OUTRO USUARIO
Observação--------: O que é deadlock: http://homepages.dcc.ufmg.br/~scampos/cursos/so/aulas/aula9.html - algoritmo do banqueiro :-)
============================================================================================================================================================================
*/
*====================================================*
USER FUNCTION lockped(_ccliente, _cloja, _cFilial , _acols , _lAviso, _lForca)
*====================================================*
LOCAL _lTravadoPorAlguem:= .F.
LOCAL _lTravou := .T.
LOCAL _cUser   := ""
LOCAL _aLog    := {}
LOCAL _cMen    := ""
Local _ni      := 1,M 
DEFAULT _lForca:= .F.


IF !_lForca .AND. !GETMV("MV_DEADLOC",,.T.)
   RETURN .F.
ENDIF

DEFAULT _lAviso := .T.

SB2->(dbSetOrder(1))
FOR _ni := 1 TO len(_acols)

   If SB2->(dbSeek(_cFilial+_acols[_ni][1]+_acols[_ni][2]))
     
      _lTravou:=.T.
      _cUser:= "Liberado para uso"
      IF !SB2->(MsRLock(SB2->(RECNO())))
         _lTravou:=.F.
         FOR M := 1 TO 5
             IF SB2->(MsRLock(SB2->(RECNO())))
                _lTravou:=.T.
                EXIT
             ENDIF
         NEXT    
         IF !_lTravou
            _lTravadoPorAlguem:=.T.
   	        _cUser:= TCInternal(53)
   	     ENDIF
      ENDIF

	  aAdd( _aLog , {_lTravou       ,;
	                 _acols[_ni][1] ,;
	                 Posicione("SB1",1,"  "+_acols[_ni][1],'B1_DESC'),;
	                 _acols[_ni][2] ,;
	                 _cUser         ,;
	                 SB2->(RECNO()) })
   EndIf
   
NEXT

SA1->( DBSetOrder(1) )
IF SA1->( DBSeek( xFilial("SA1") + _ccliente + _cloja  ) )
   _lTravou:=.T.
   _cUser:= "Liberado para uso"
   IF !SA1->(MsRLock( SA1->(RECNO()) ))
      _lTravou:=.F.
      _lTravadoPorAlguem:=.T.
      _cUser:= TCInternal(53)
   ENDIF
   aAdd( _aLog , {_lTravou,"Cliente / Loja:" ,_ccliente+" / "+_cloja,"",_cUser,0})
ENDIF

If LEN(_aLog) > 0 .AND. _lTravadoPorAlguem

   IF _lTravadoPorAlguem
      FOR _ni := 1 TO LEN(_aLog)
          SB2->(DBGOTO(_aLog[_ni,6]))
          SB2->(MSUNLOCK())
          IF !_aLog[_ni,1]
            //U_ITCONOUT("PRODUTO LOCADO: "+_aLog[_ni,2])
          ENDIF
      NEXT 
      SA1->(MSUNLOCK())
   ENDIF

	_cMen:="Existem cliente ou produtos desse Pedido cujo o estoque esta sendo atualizado por outro usuario, "+;
		   "aguarde por alguns instantes a liberação dos produtos e tente novamente daqui apouco." + chr(10) + chr(13) + chr(10) + chr(13) + "Deseja ver detalhes?"
		   
    
    _lRet := u_itmsg( _cMen , 'Atenção! (ITALACXFUN - LOCKPED)', ,1,2,2 )

   IF _lRet 

      U_ITListBox('Lista de itens travados (bolinha vermelha) por outros usuarios (ITALACXFUN - LOCKPED)',;
                 {" ",'Produto','Descricao','Armazem','Usuario'},_aLog,.F.,4,"Abaixo segue a lista de itens travados por outroa usuarios:",,;
                 { 10,       40,        100,       30,      100})

   ENDIF

   SB2->(MSUNLOCKALL())
   SA1->(MSUNLOCKALL())

ENDIF

RETURN _lTravadoPorAlguem

/*
===============================================================================================================================
Programa----------: ITOPEREST
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 31/01/2017
Descrição---------: Seleção de armazém por produto e tipo de operação
Parametros--------: _cFilial	- Filial a ser validada
------------------: _cPdod		- Código do produto a ser validado
------------------: _cOper		- Tipo de operação a ser validado
Retorno-----------: _cRet		- Retorna o número do almoxarifado
===============================================================================================================================
*/
User Function ITOPEREST(_cFilial, _cProd, _cOper)//U_ITOPEREST(
Local _aArea    := GetArea()
Local _cRet        := ""

Local _cFilOper        := U_ITGETMV( "IT_FILOPE" , "01")
Local _cOperEst        := U_ITGETMV( "IT_OPEEST" , "02|04")
Local _cEstFun		:= U_ITGETMV( "IT_ESTFUN" , "21")

Default _cFilial	:= ""
Default _cProd		:= ""
Default _cOper		:= ""


If _cFilial $ _cFilOper .And. _cOper $ _cOperEst
	_cRet := AllTrim(_cEstFun)
Else
   _cRet := Posicione("SBZ", 1, _cFilial + _cProd, "BZ_LOCPAD")
EndIf

RestArea(_aArea)
Return(_cRet)

/*
===============================================================================================================================
Programa----------: selectTES
Autor-------------:  Fabiano Dias 
Data da Criacao---: 23/08/2011
Descrição---------: Funcao utilizada para checar na tabela de TES INTELIGENTE se eh encontrada uma TES de acordo com os dados do 
			  cliente e filial corrente que o pedido esta sendo realizado.	
Parametros--------: _cProduto  - Codigo do Produto.																				
           _cSuframa  - S - Indica que o cliente eh da Zona Franca.														
           _cEstCli   - Estado do cliente para comparacao para verificar se a venda eh para dentro ou fora do estado	
           _cEstFil   - Estado da filial corrente para comparacao para constatar se a venda eh para dentro ou fora do UF
           _cCliPed   - Codigo do cliente que esta sendo realizado o pedido de venda.									
           _cLjCliPed - Loja do cliente que esta sendo realizado o pedido de venda.		
           _cTpOper   - Tipo da operação
           _clocal    - armazem
		   _cTipoPV   - Tipo do PV
           _cSimplesNacional - Simples Nacional
           _cContribuinte    - Contribuinte ICMS
           
Retorno-----------: _cTES - Tes selecionada
===============================================================================================================================
*/
User Function selectTES(_cProduto,_cSuframa,_cEstCli,_cEstFil,_cCliPed,_cLjCliPed,_cTpOper,_clocal,_cTipoPV,_cSimplesNacional,_cContribuinte)

Local _cTES     := Space(03)                     
Local _cAlias   := GetNextAlias()
Local _lControl := .F.  
Local _lTesFora := _cEstCli == _cEstFil
Local _nfase    := 1
Local _cFiltro  := "%"
Local _cSelect  := "%"          
Local _cTipTES  := "" 
Local _cBusca   :="SA1"
Local _cCpoSN   :="A1_SIMPNAC"
Local _cCpoCI   :="A1_CONTRIB"
Local _lExistCpo:=(ZZP->(FIELDPOS("ZZP_SIMPNA")) # 0 .AND. ZZP->(FIELDPOS("ZZP_CONTRI")) # 0)

IF _lExistCpo
   IF _cTipoPV # NIL .AND. _cTipoPV $ "B"
      _cBusca:="SA2"
      _cCpoSN:="A2_SIMPNAC"
      _cCpoCI:="A2_CONTRIB"
   ENDIF

   IF _cSimplesNacional = NIL
      _cSimplesNacional:=Posicione(_cBusca,1,xFilial(_cBusca)+_cCliPed+_cLjCliPed,_cCpoSN)
   ENDIF

   IF _cContribuinte = NIL
      _cContribuinte:=Posicione(_cBusca,1,xFilial(_cBusca)+_cCliPed+_cLjCliPed,_cCpoCI)
   ENDIF

   IF EMPTY(_cTpOper)//Quando o _cTipoPV = "B" a operação não é preenchida
      _cTpOper:="9F"
   ENDIF
ENDIF

/*
//===================================================================
//Seleciona os registros que se enquadram nos primeiros requisitos 
//de avaliacao para checagem da TES Inteligente.                   
//===================================================================
                                   
//======================================================¿
//Venda para dentro do estado, seleciona a TES interna.
//======================================================Ù
*/
If _cEstCli == _cEstFil
		
	_cSelect += "ZZP_CLIENT, ZZP_LOJA, ZZP_ESTADO, ZZP_TSIN TES, ZZP_LOCAL"         
	_cTipTES := "ZZP_TSIN"           				
	/*
	//==================================================¿
	//Venda para fora do estado, seleciona TES Externa.
	//==================================================Ù
	*/
Else 
				
	_cSelect += "ZZP_CLIENT, ZZP_LOJA, ZZP_ESTADO, ZZP_TSOUT TES, ZZP_LOCAL"      
	_cTipTES := "ZZP_TSOUT" 
				
EndIf
		
_cSelect += "%"
	
_cFiltro += " AND ZZP_FILIAL = '"  + xFilial("ZZP") + "'"
_cFiltro += " AND ZZP_TIPO = '"    + _cTpOper       + "'"
_cFiltro += " AND ZZP_PRODUT = '"  + _cProduto      + "'"

If _cSuframa = "S"
   _cFiltro += " AND ZZP_CLIZN = 'S' "
Else
   _cFiltro += " AND ZZP_CLIZN IN ('N',' ') "
Endif  

IF _lExistCpo
   If _cSimplesNacional = "1"
      _cFiltro += " AND ZZP_SIMPNA = 'S' "
   Else
      _cFiltro += " AND ZZP_SIMPNA IN ('N',' ') "
   Endif  

   If _cContribuinte = "2"//Não
      _cFiltro += " AND ZZP_CONTRI = 'N' "
   Else
      _cFiltro += " AND ZZP_CONTRI IN ('S',' ') "
   Endif  
Endif  

_cFiltro += " AND ZZP_ESTADO IN ('"+_cEstCli+"','  ')" //FILTRA SOMENTE O ESTADO DO CLIENTE OU O ESTADO COMO VAZIO POIS PODE NAO HAVER UMA REGRA PARA O ESTADO DO CLIENTE CADASTRADA NA TES INTELIGENTE
_cFiltro += " AND " + _cTipTES + " <> '   '"  //TIPO DA TES DIFERENTE DE VAZIO, OU SEJA, TEM QUE TER SIDO FORNECIDA UMA TES NO CADASTRO DE TES INTELIGENTE 
	
_cFiltro += "%"
	
BeginSql alias _cAlias 
SELECT
      %Exp:_cSelect%
FROM
      %table:ZZP%
WHERE
      D_E_L_E_T_ = ' '
      %Exp:_cFiltro%	   
ORDER BY
	  ZZP_ESTADO DESC				      		 	 			
EndSql	

(_cAlias)->(dbGotop())

     	                      
Do while _nfase <= 6 .and. !_lControl                     
	
	
	//==================================================================================================
	//Primeira fase para verificar o cliente, loja e armazem da regra de TES inteligente
	//que estejam preenchidos, regra mais especifica.                              
	//==================================================================================================
	//==================================================================================================
	//Segunda fase para verificar o cliente e loja da regra de TES inteligente
	//que estejam preenchidos, 2a. regra mais especifica.                              
	//==================================================================================================
	//==================================================================================================
	//Terceira fase para verificar o cliente preenchido, a loja vazia e armazém preenchido da regra de 
	//TES inteligente                                                     
	//==================================================================================================
	//==================================================================================================
	//Quarta fase para verificar o cliente preenchido e a loja vazia da regra de TES inteligente                                                     
	//==================================================================================================
	//==================================================================================================
	//Quinta fase para verificar uma regra com o cliente e loja vazios e armazém preenchido.	                                                       
	//==================================================================================================
	//==================================================================================================
	//Sexta fase para verificar uma regra que seja geral ou seja o cliente e loja vazios.	                                                       
	//==================================================================================================



	While !(_cAlias)->(Eof()) .And. !_lControl   
	
		//===============================================================================
		//Verifica se o cliente e loja foram preenchidos na regra da TES inteligente.
		//===============================================================================
	
		If 	( Len(AllTrim((_cAlias)->ZZP_CLIENT)) > 0 .And. Len(AllTrim((_cAlias)->ZZP_LOJA)) > 0 .And. Len(AllTrim((_cAlias)->ZZP_LOCAL)) > 0 .and. _nFase == 1 ) .OR.;
			( Len(AllTrim((_cAlias)->ZZP_CLIENT)) > 0 .And. Len(AllTrim((_cAlias)->ZZP_LOJA)) > 0 .And. Len(AllTrim((_cAlias)->ZZP_LOCAL)) == 0 .And. _nFase == 2 ) .OR.;  
	       ( Len(AllTrim((_cAlias)->ZZP_CLIENT)) > 0 .And. Len(AllTrim((_cAlias)->ZZP_LOJA)) == 0 .And. Len(AllTrim((_cAlias)->ZZP_LOCAL)) > 0 .and. _nFase == 3 ) .OR.;
	       ( Len(AllTrim((_cAlias)->ZZP_CLIENT)) > 0 .And. Len(AllTrim((_cAlias)->ZZP_LOJA)) == 0 .And. Len(AllTrim((_cAlias)->ZZP_LOCAL)) == 0 .and. _nFase == 4 ) .OR.;
	       ( Len(AllTrim((_cAlias)->ZZP_CLIENT)) == 0 .And. Len(AllTrim((_cAlias)->ZZP_LOJA)) == 0 .And. Len(AllTrim((_cAlias)->ZZP_LOCAL)) > 0 .and. _nFase == 5 ) .OR.;
	       ( Len(AllTrim((_cAlias)->ZZP_CLIENT)) == 0 .And. Len(AllTrim((_cAlias)->ZZP_LOJA)) == 0 .And. Len(AllTrim((_cAlias)->ZZP_LOCAL)) == 0 .and. _nFase == 6)      
	                    		
			//==================================================================================================
			//Verifica se encontrou uma regra especifica para o cliente e loja indicados no pedido de venda.
			//==================================================================================================
		
			If 	((_cAlias)->ZZP_CLIENT == _cCliPed .And. (_cAlias)->ZZP_LOJA == _cLjCliPed .and. (_cAlias)->ZZP_LOCAL == _cLocal .and. _nfase == 1 ) .or.;
				((_cAlias)->ZZP_CLIENT == _cCliPed .And. (_cAlias)->ZZP_LOJA == _cLjCliPed .and. _nfase == 2 ) .or.;
			 	((_cAlias)->ZZP_CLIENT == _cCliPed .and. (_cAlias)->ZZP_LOCAL == _cLocal .and. _nfase == 3 ) .or.; 
			 	((_cAlias)->ZZP_CLIENT == _cCliPed  .and. _nfase == 4 ) .or.;
			 	((_cAlias)->ZZP_LOCAL == _cLocal  .and. _nfase == 5 ) .or. _nfase == 6	
			 			 	     		         			
			
				//==================================================================================================
				//Verifica se foi encontrada uma regra para o estado preenchido na regra da TES inteligente,
				//quando a venda eh para fora do esado tem que se verificar se existe uma regra             
				//especifica caso nao encontre procura pela geral.                                          
				//==================================================================================================
				

				If _lTesFora
			 			
					If _cEstCli == (_cAlias)->ZZP_ESTADO      
				    				    
						_cTES    := (_cAlias)->TES
						_lControl:= .T.
						exit			
							 						            							
					EndIf        
				        			
					/*
					//=======================================================================================================================================
					//Verifica se foi encontrada uma regra generica para o produto no cadastro da TES inteligente para o cliente e loja do pedido de venda.
					//=======================================================================================================================================
					*/
					If Len(AllTrim((_cAlias)->ZZP_ESTADO)) == 0 .And. !_lControl
				
						_cTES    := (_cAlias)->TES
						_lControl:= .T.
						exit	
				
					EndIf     				                
					/*
					//==================================================================
					//No caso da analise de uma TES interna nao eh necessaria a       
					//verificacao do estado, desta forma como ja se passou o produto  
					//somente pode haver uma TES interna por regra no cadastro da TES 
					//inteligente.                                                    
					//==================================================================
					*/
				Else  
			
					_cTES    := (_cAlias)->TES
					_lControl:= .T.                 
			
				EndIf
		
			EndIf  	
	
		EndIf

	  (_cAlias)->(dbSkip())

  EndDo


  (_cAlias)->(dbGotop())
 
  _nfase++
  
Enddo

/*
//=======================================
//Finaliza a area criada anteriormente.
//=======================================
*/
  
(_cAlias)->(dbCloseArea())

Return _cTES       


/*
===============================================================================================================================
Programa----------: VldCust
Autor-------------: André Lisboa
Data da Criacao---: 23/03/2017
Descrição---------: Função para verificar custo nos apontamentos de produção
Parametros--------: cCodigo - Código do produto
					cLocal - Armazém do produto
					dMovto - Data da informação
Retorno-----------: aRet - array com primeira posição tendo o custo unitário do produto no armazém na da indicada
===============================================================================================================================
*/
User Function VldCust( cCodigo , cLocal , dMovto )

Local aRet		:= {}
Local aSaldos	:= { 0 }

Default cCodigo	:= ""
Default cLocal	:= ""
Default dMovto	:= dDataBase

If !Empty(cCodigo)

	aSaldos := CalcEst( cCodigo , cLocal , dMovto + 1 ) //obtém o saldo final em estoque na data informada
		
	aRet := { aSaldos[2]/aSaldos[1] }
			
EndIf

Return(aRet)


/*
===============================================================================================================================
Programa----------: BloqueiaPV()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 19/04/2017
Descrição---------: Funcao utilizada para checar se bloqueia a gravação do PV - Chamado 19585
Parametros--------: _cProduto  - Codigo do Produto.																				
                    _cCliPed   - Codigo do cliente que esta sendo realizado o pedido de venda.									
                    _cLjCliPed - Loja do cliente que esta sendo realizado o pedido de venda.		
Retorno-----------: .T. - Bloqueia / .F. - Não Bloqueia
===============================================================================================================================
*/
User Function BloqueiaPV(_cCliPed,_cLjCliPed,_cProduto,_cMenBroqueio,_cOperacao)

Local _aSaveArea := GetArea()
Local _cAlias    := GetNextAlias()
Local _cFiltro   := "%"
Local _lBloqueia := .F.
Local _cEstado   := " "
Local _cMunicipio:= " "
Local _cTpCliente:= " "
Local _cGrupo    := " "
Local _cNCM      := " "
_cMenBroqueio:=""

//Estado -> Municipio -> Tipo de Cliente -> Cliente -> Loja -> Grupo de Produto -> NCM -> Produto 

SA1->(DBSETORDER(1))
//Estado -> Municipio -> Tipo de Cliente 
IF SA1->(DBSEEK( xFilial("SA1")+_cCliPed+_cLjCliPed ))
   _cEstado   :=SA1->A1_EST
   _cMunicipio:=SA1->A1_COD_MUN
   _cTpCliente:=SA1->A1_TIPO
ELSE
   RETURN .F.
ENDIF

SB1->(DBSETORDER(1))
//Grupo de Produto -> NCM
IF SB1->(DBSEEK( xFilial("SB1")+_cProduto ))
   _cGrupo:=SB1->B1_GRUPO
   _cNCM  :=SB1->B1_POSIPI
ELSE
   RETURN .F.
ENDIF

//Estado -> Municipio -> Tipo de Cliente -> Cliente -> Loja -> Grupo de Produto -> NCM -> Produto 
_cFiltro := "%"
_cFiltro += " ZBP_FILIAL = '"+xFilial("ZBP") +"' AND D_E_L_E_T_ = ' ' AND ( "
_cFiltro += " ZBP_OPERAC = '"+_cOperacao     +"' OR "
_cFiltro += " ZBP_ESTADO = '"+_cEstado       +"' OR "
_cFiltro += " ZBP_CODMUN = '"+_cMunicipio    +"' OR "
_cFiltro += " ZBP_TIPCLI = '"+_cTpCliente    +"' OR "
_cFiltro += " ZBP_CLIENT = '"+_cCliPed       +"' OR "
_cFiltro += " ZBP_CLILOJ = '"+_cLjCliPed     +"' OR "
_cFiltro += " ZBP_GRUPO  = '"+_cGrupo        +"' OR "
_cFiltro += " ZBP_NCM    = '"+_cNCM          +"' OR "
_cFiltro += " ZBP_PRODUT = '"+_cProduto      +"'"
_cFiltro += " ) %"
	
BeginSql alias _cAlias 

  SELECT ZBP_FILIAL,ZBP_OPERAC,ZBP_ESTADO,ZBP_CODMUN,ZBP_TIPCLI,ZBP_CLIENT,ZBP_CLILOJ,ZBP_GRUPO,ZBP_NCM,ZBP_PRODUT
    FROM %table:ZBP% 
   WHERE %Exp:_cFiltro% 
   ORDER BY ZBP_FILIAL,ZBP_OPERAC,ZBP_ESTADO,ZBP_CODMUN,ZBP_TIPCLI,ZBP_CLIENT,ZBP_CLILOJ,ZBP_GRUPO,ZBP_NCM,ZBP_PRODUT

EndSql	

(_cAlias)->(dbGotop())

DO WHILE (_cAlias)->(!EOF())

   IF !EMPTY((_cAlias)->ZBP_OPERAC) .AND. (_cAlias)->ZBP_OPERAC # _cOperacao
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_ESTADO) .AND. (_cAlias)->ZBP_ESTADO # _cEstado
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_CODMUN) .AND. (_cAlias)->ZBP_CODMUN # _cMunicipio 
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_TIPCLI) .AND. (_cAlias)->ZBP_TIPCLI # _cTpCliente
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_CLIENT) .AND. (_cAlias)->ZBP_CLIENT # _cCliPed
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_CLILOJ) .AND. (_cAlias)->ZBP_CLILOJ # _cLjCliPed
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_GRUPO)  .AND. (_cAlias)->ZBP_GRUPO  # _cGrupo
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_NCM)    .AND. (_cAlias)->ZBP_NCM    # _cNCM
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_PRODUT) .AND. (_cAlias)->ZBP_PRODUT # _cProduto
      (_cAlias)->(DBSKIP())
      LOOP 
   ENDIF

   _cMenBroqueio:="A venda esta bloqueada para: "+CRLF

   IF !EMPTY((_cAlias)->ZBP_OPERAC)
      _cMenBroqueio+="[ Operacao = "+(_cAlias)->ZBP_OPERAC+" ] "+CRLF
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_ESTADO)
      _cMenBroqueio+="[ Estado = "+(_cAlias)->ZBP_ESTADO+" ] "+CRLF
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_CODMUN) 
      _cMenBroqueio+="[ Municipio = "+ALLTRIM(POSICIONE("CC2",1,XFILIAL("CC2")+(_cAlias)->ZBP_ESTADO+(_cAlias)->ZBP_CODMUN,"CC2_MUN"))+" ] "+CRLF
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_TIPCLI)
      _cMenBroqueio+="[ Tipo Cliente = '"+(_cAlias)->ZBP_TIPCLI+"' ] "+CRLF
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_CLIENT)
      _cMenBroqueio+="[ Cliente = "+ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+(_cAlias)->ZBP_CLIENT+ALLTRIM((_cAlias)->ZBP_CLILOJ),"A1_NREDUZ"))+" ] "+CRLF
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_GRUPO)  
      _cMenBroqueio+="[ Grupo de Produto = "+ALLTRIM(POSICIONE("SBM",1,XFILIAL("SBM")+(_cAlias)->ZBP_GRUPO,"BM_DESC"))+" ] "+CRLF
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_NCM)
      _cMenBroqueio+="[ NCM = "+ALLTRIM((_cAlias)->ZBP_NCM)+" ] "+CRLF
   ENDIF

   IF !EMPTY((_cAlias)->ZBP_PRODUT)
      _cMenBroqueio+="[ Produto = "+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+(_cAlias)->ZBP_PRODUT,"B1_DESC"))+" ] "+CRLF
   ENDIF
   
   _lBloqueia:=.T.   
   EXIT

   (_cAlias)->(DBSKIP())

ENDDO

(_cAlias)->(DBCLOSEAREA())

RestArea(_aSaveArea)

Return _lBloqueia

/*
===============================================================================================================================
Programa----------: ITConout()
Autor-------------: Josué Danich Prestes
Data da Criacao---: 03/07/2017
Descrição---------: Função Counout personalizada
Parametros--------: _cMens - String a ser gravado no console.log	
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITConout(_cMens)

Local _cfuncao := ""
Local _cambiente := GetEnvServer()

If !empty(funname())

	_cfuncao := funname() + " - " + procname(2)+ " (" + strzero(procline(2),6) + ") - " + procname(1) + " (" + strzero(procline(1),6)+")"
	
Else

	_cfuncao := procname(2)+ " (" + strzero(procline(2),6) + ") - " + procname(1) + " (" + strzero(procline(1),6)+")"

Endif

//Modificar esse trecho para gravar em tabela de dados
// conout("[Thread " + strzero(ThreadID(),6) + "] - [" + _cfuncao + "] - [" + dtoc(date()) + " - " + time() + "] -[" + _cambiente + "]   -  [" + _cMens + "]")
_cMens := "[Thread " + strzero(ThreadID(),6) + "] - [" + _cfuncao + "] - [" + _cambiente + "]   -  [" + _cMens + "]"

FwLogMsg("ITALAC","LAST", _cAmbiente, FunName()       ,"cValToChar(nI)", "01"   , _cMens                   , 0      , 1                 ,       ,) // A função FwLogMsg não está gravando no arquivo Console.log.
//LogMsg("INFO" , "LAST", "MeuGrupo", "MinhaCategoria", cValToChar(nI) , "MeuID", "Meu registro de sistema", nQtdMsg, Seconds() - nBegin,aMessage)

//ConOut(_cMens)

Return

/*
===============================================================================================================================
Programa----------: ITmsg()
Autor-------------: Josué Danich Prestes
Data da Criacao---: 03/07/2017
Descrição---------: Função mensagem personalizada
Parametros--------:   _cMens  - String a ser apresentado na mensagem
					  _ctitu  - String com título da mensagem
					  _csolu  - String a ser apresentado como solução
					  _ntipo  - número para escolher estilo e figura da mensagem
					  _nbotao - botão ok (1) ou botão ok e cancela (2)
					  _nmenbot  - Mensagem botões (1) Ok/Cancela (2) Sim/Não (3) _cbt1/_cbt2 (4) _cbt1/_cbt2 sem cor
					  _lHelpMvc - .T. chama função Help do MVC, .F. exibe tela customizada para a função ITMSG.
					  _cbt1 - "CONFIRMA"
					  _cbt2 - "Voltar"
					  _bMaisDetalhes - CodeBlock que será executado no botão "Mais Detalhes"
					  _cMaisDetalhes - Conteudo em caracter do botão "Mais detalhes" para quando não tem tela (MSExecAuto())
					  _lRetXNil - Ativa retornar NIL quando apertar o X da Janela 
Retorno-----------: True ou False de acordo com botão ok/sim ou cancela/não escolhido
===============================================================================================================================
*/
User Function ITmsg(_cMens,_ctitu,_csolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes,_cMaisDetalhes,_lRetXNil)

Local _cfuncao,oSay1,oSay4,oSay11,oSay32,oSay33,oTBitmap1,oBtnOK,oBtnCan,oBtnMD
Local cEstilo0,cEstilo1,cEstilo2,cEstilo3,cEstilo4,cEstilo11,cEstiloMD
Local _cmenok := "OK"
Local _cmencan := "CANCELA"
Local oDlg,_nProc,_cTitMen:=""
Local nConta:=0, bPilha:={||""}  , cPilha:=""
Local lHtml := .T.// (GetRemoteType() == 5) //VALIDA SE O AMBIENTE É SMARTCLIENTHTML (WEB)
Local bType := {|x| Type(x)} , _lincone, _nlinbot, _nlfim, nLinFim , nIniSol , nLinIni
Local _lRet:=.T.

Default _lRetXNil:=.F.
Default _cTitu := "Atenção"
Default _cMens := "MENSAGEM NÃO DEFINIDA"
Default _cSolu := ""
Default _ntipo := 0
Default _nbotao := 1
Default _nmenbot := 1
Default _lHelpMvc := .F.
DEFAULT _cMaisDetalhes:=""

Begin Sequence

IF VALTYPE(_cSolu) <> "C"
   _cSolu:=""
ENDIF
IF VALTYPE(_cMaisDetalhes) <> "C"
   _cMaisDetalhes:=""
ENDIF

If TYPE("_lMsgEmTela") <> "L" 
   _lMsgEmTela := .T.
ENDIF

If Type("_cAOMS074") <> "U" 
   _lMsgEmTela := .F.
EndIf 

If !_lMsgEmTela .AND. FWIsInCallStack("MSEXECAUTO")

   If TYPE("_cAOMS074Vld") <> "C" 
      _cAOMS074Vld:=""
   ENDIF
   If TYPE("_cAOMS074") <> "C" 
      _cAOMS074 := "U_ITmsg chamado do MSExecAuto()"
   EndIf

   If TYPE("_cAOMS074Vld") = "C" 
      IF EMPTY(_cAOMS074Vld) 
	     IF !EMPTY(_cAOMS074)
            _cAOMS074Vld += '('+_cAOMS074+') '
		 ENDIF
      ENDIF
	  _cMens:=STRTRAN(_cMens,"Clique em mais detalhes","")
      _cAOMS074Vld += _cTitu+": "+_cMens+". "
	  IF !EMPTY(_cSolu)
          _cAOMS074Vld += "Solucao: "+_cSolu+". "
	  ENDIF
	  IF !EMPTY(_cMaisDetalhes)
          _cAOMS074Vld += "Detalhes: "+_cMaisDetalhes+". "
	  ENDIF
   ENDIF

   RETURN .F.

Endif 

//=============================================================================
//Monta string com programa e função
//=============================================================================
IF FWIsInCallStack("U_MT_ITMSG") 
   _nProc:=2
ELSE
   _nProc:=1
ENDIF

If empty(funname())

  _cfuncao := procname(1) + " - Linha " + strzero(procline(1),6)

Else

  _cfuncao := funname() + " - " + procname(_nProc) + " - Linha " + strzero(procline(_nProc),6)
  
Endif 

//==========================================================================================================
//Detecta se tela está montada, se não estiver manda U_ITCONOUT (conout italac)
//_cMenITmsgLog: VAIRAVEL PRIVATE INICIADA ANTES DA CHAMADA DESSA FUNÇÃO
//==========================================================================================================
If FwGetRunSchedule() .OR. GetRemoteType() == -1
   
	If EMPTY(_csolu)	
		//U_ITCONOUT("Mensagem - Titulo: [" + _ctitu + "] Mensagem: [" + _cMens + "]")
		_cMenITmsgLog:="Mensagem ITmsg: [" + _cMens + "]"
	Else
		//U_ITCONOUT("Mensagem - Titulo: [" + _ctitu + "] Mensagem: [" + _cMens + "] Solucao: [" + _csolu + "]")
		_cMenITmsgLog:="Mensagem ITmsg: [" + _cMens + "] Solucao: [" + _csolu + "]"
	Endif
	_lRet := .T.
	Break
	
Endif

//==========================================================================================================
// Caso a rotina seja chamada do MVC, chama a função Help padrão do MVC.
//==========================================================================================================
If _lHelpMvc
   _cTextoMvc := _cMens //+ " "
   IF EMPTY(_cSolu)
      _cSolu:="["+_cfuncao+"]"
   ELSE
      _cSolu:= _cSolu+CRLF+"["+_cfuncao+"]"
   ENDIF
   Help( ,, _ctitu+" ["+DTOC(DATE())+"] ["+TIME()+"]" ,, _cTextoMvc , 1 , 0 ,.F.,,,,,{_cSolu} )   
   Break
EndIf

//==========================================================================================================
// Definição de estilos CSS
//==========================================================================================================
//Janela 
cEstilo0 := "TDialog { " 
cEstilo0 += " background-color: #FFFFFF;"
cEstilo0 += " font: bold 12px Arial;"
cEstilo0 += " padding: 6px};"

//If .T.//_nmenbot <> 3 //!lHtml
  	//Botão OK
	cEstilo1 := "QPushButton {"  
	cEstilo1 += " background-image: url(rpo:ok.png);background-repeat: no-repeat; margin: 2px;" 
	cEstilo1 += " border-style: outset;"
	cEstilo1 += " border-width: 2px;"
	cEstilo1 += " border: 1px solid #C0C0C0;"
	cEstilo1 += " border-radius: 5px;"
	cEstilo1 += " border-color: #C0C0C0;"
	cEstilo1 += " font: bold 12px Arial;"
	cEstilo1 += " padding: 6px;"
	cEstilo1 += " background-color: rgb(0,128,0); color: white" //(105, 222, 152)
	cEstilo1 += "}"
	cEstilo1 += "QPushButton:pressed {"
	cEstilo1 += " background-color: #696969;"
	cEstilo1 += " border-style: inset;"
	cEstilo1 += "}"
    
  	//Botão Cancel 
	cEstilo2 := "QPushButton {background-image: url(rpo:cancel.png);background-repeat: no-repeat; margin: 2px; "
	cEstilo2 += " border-style: outset;"
	cEstilo2 += " border-width: 2px;"
	cEstilo2 += " border: 1px solid #C0C0C0;"
	cEstilo2 += " border-radius: 5px;"
	cEstilo2 += " border-color: #C0C0C0;"
	cEstilo2 += " font: bold 12px Arial;"
	cEstilo2 += " padding: 6px;" 
	cEstilo2 += " background-color: rgb(255,0,0); color: white"//(255 ,100, 100)
	cEstilo2 += "}"
	cEstilo2 += "QPushButton:pressed {"
	cEstilo2 += " background-color: #696969;"//#e6e6f9
	cEstilo2 += " border-style: inset;"
	cEstilo2 += "}"
 /*Else //QUANDO O SMARTCLIENT FOR HTML
//Botão OK
	cEstilo1 := "QPushButton {"  
	cEstilo1 += " background-image: url(rpo:ok.png);background-repeat: no-repeat; margin: 2px;" 
	cEstilo1 += " background-color: rgb"+cCor+"; color: white;" //rgb(105, 222, 152)
	cEstilo1 += " border-style: outset;"
	cEstilo1 += " border-width: 2px;"
	cEstilo1 += " border: 1px solid #C0C0C0;"
	cEstilo1 += " border-radius: 5px;"
	cEstilo1 += " border-color: #C0C0C0;"
	cEstilo1 += " font: bold 12px Arial;"
	cEstilo1 += " padding: 6px;"
	cEstilo1 += "}"
	cEstilo1 += "QPushButton:pressed {"
	cEstilo1 += " background-color: #696969;"
	cEstilo1 += " border-style: inset;"
	cEstilo1 += "}"

	//Botão Cancel 
	cEstilo2 := "QPushButton {background-image: url(rpo:cancel.png);background-repeat: no-repeat; margin: 2px; "
	//cEstilo2 := "QPushButton {"
	cEstilo2 += " background-color: rgb(105, 222, 152); color: white;"//rgb(255 ,100, 100)
	cEstilo2 += " border-style: outset;"
	cEstilo2 += " border-width: 2px;"
	cEstilo2 += " border: 1px solid #C0C0C0;"
	cEstilo2 += " border-radius: 5px;"
	cEstilo2 += " border-color: #C0C0C0;"
	cEstilo2 += " font: bold 12px Arial;"
	cEstilo2 += " padding: 6px;"
	cEstilo2 += "}"
	cEstilo2 += "QPushButton:pressed {"
	cEstilo2 += " background-color: #696969;"
	cEstilo2 += " border-style: inset;"
	cEstilo2 += "}"
ENDIF*/
//Quadro de função  
cEstilo3 := "QLabel { " 
cEstilo3 += " border-style: solid;"//outset
cEstilo3 += " border-width: 2px;"
cEstilo3 += " border: 1px solid #C0C0C0;"
cEstilo3 += " border-radius: 5px;"
cEstilo3 += " border-color: black;"//#C0C0C0
cEstilo3 += " background-color: #FFFFFF;"
cEstilo3 += " font: bold 12px Arial;"
cEstilo3 += " padding: 6px};"

//Quadro de mensagem e solução   
cEstilo11 := "QLabel { " 
cEstilo11 += " border-style: none;"//outset
cEstilo11 += " border-width: 2px;"
cEstilo11 += " border: none;"//"1px solid #C0C0C0
cEstilo11 += " border-radius: 5px;"
cEstilo11 += " border-color: #C0C0C0;"// black
cEstilo11 += " background-color: #FFFFFF;"
cEstilo11 += " font: 12px Arial;"
cEstilo11 += " padding: 6px};"
 
//Mensagem e solução     
cEstilo4 := "QLabel { " 
cEstilo4 += " font: bold 12px Arial;"
cEstilo4 += " background-color: #FFFFFF;"
cEstilo4 += " padding: 2px};"
  
cEstiloMD:= "QPushButton {"  
//cEstiloMD+= " background-image: url(rpo:ok.png);background-repeat: no-repeat; margin: 2px;" 
cEstiloMD+= " background-color: rgb(105, 222, 152); color: black;"//rgb(255 ,100, 100)
cEstiloMD+= " border-style: outset;"
cEstiloMD+= " border-width: 2px;"
cEstiloMD+= " border: 1px solid #C0C0C0;"
cEstiloMD+= " border-radius: 5px;"
cEstiloMD+= " border-color: #C0C0C0;"
cEstiloMD+= " font: bold 12px Arial;"
cEstiloMD+= " padding: 6px;"
cEstiloMD+= "}"
cEstiloMD+= "QPushButton:pressed {"
cEstiloMD+= " background-color: #696969;"
cEstiloMD+= " border-style: inset;"
cEstiloMD+= "}"

nConta:=0
cPilha:=""

cProcName:="XX"
DO WHILE !EMPTY(cProcName) .AND. nConta < 25
   cProcName:=PROCNAME(nConta)
   IF !EMPTY(cProcName) .AND. !cProcName $ "ACTIVATE/FWMSGRUN/PROCESSA/__EXECUTE/FWPREEXECUTE/SIGAIXB"///SIGAADV
      aTipo:={};   aArquivo:={};   aLinha:={};   aData:={};   aHora:={}
	  aRet :=GetFuncArray( PROCNAME(nConta),aTipo,aArquivo,aLinha,aData,aHora)

      cPilha+=STRTRAN(PROCNAME(nConta),"  ","")
      IF Eval(bType,"aArquivo[1]") = "C" 
         cPilha+=" Fonte: ("+aArquivo[1]+")"
      ENDIF
      IF Eval(bType,"aData[1]") = "D" 
         cPilha+=" "+DTOC(aData[1])
      ENDIF
      IF Eval(bType,"aHora[1]") = "C" 
         cPilha+=" "+aHora[1]
      ENDIF
      IF Eval(bType,"aLinha[1]") = "C"
         cPilha+=" linha " +aLinha[1]
      ENDIF
      cPilha+=CRLF

   ENDIF
   nConta++   
ENDDO

bPilha:={||  U_ITMsgLog(cPilha, "PILHA DE CHAMADAS", 1, .F.) }

//=============================================================================
//Monta tamanho da tela de mensagem de acordo com parâmetros
//=============================================================================

_ncini := 0   //coluna inicial da janela
_nlini := 0   //linha inicial da janela

_ncfim := 576 //coluna final da janela
_nlfim := 430 //linha final da janela

_ncbok     := 175 //coluna do botao de ok

IF _nbotao == 2
   _ncbcancel:= 235 //coluna do botão de cancelar 
   _ncfuncin := 165 //largura do campo de função
ELSE
   _ncbcancel:= 225 //coluna do botão de cancelar 
   _ncfuncin := 205 //largura do campo de função
ENDIF

If _nmenbot == 2 //Ajusta texto dos botões se tiver parâmetro diferente do default (Ok/Cancela)

	_cmenok := "SIM"
	_cmencan:= "NAO"
	
ELSEIf _nmenbot = 3 //Ajusta texto dos botões se tiver parâmetro diferente do default (texto personalizado)

	IF UPPER(_cbt1) $ "OK,SIM,NAO,NÃO"
	   _cmenok:= UPPER(_cbt1)
	ELSE
	   _cmenok:= Capital(_cbt1)
	ENDIF
	IF UPPER(_cbt2) $ "OK,SIM,NAO,NÃO"
	   _cmencan := UPPER(_cbt2)
	ELSE
	   _cmencan:= Capital(_cbt2)
	ENDIF

ELSEIf _nmenbot = 4 //botões se tiver parâmetro diferente do default (texto personalizado)

   _cmenok := _cbt1
   _cmencan:= _cbt2
	
Endif

If !EMPTY(_csolu)
	_lincone := 030 //LINHA DO ICONE : CANCEL.PNG / OK.PNG / ALERT.PNG
	_nlinbot := 185 //LINHA DOS BOTÕES / BOX DE FUNÇÃO / PINHA DE CHAMADAS
Else
	_lincone := 003 //LINHA DO ICONE : CANCEL.PNG / OK.PNG / ALERT.PNG
	_nlinbot := 110 //LINHA DOS BOTÕES / BOX DE FUNÇÃO / PINHA DE CHAMADAS
	_nlfim   := 290	//linha final da janela
Endif


If _ntipo == 0

	_ncfim := 450
	_ncbok := 110
    IF _nbotao == 2
	   _ncbcancel:= 170
	   _ncfuncin := 095
	ELSE   
	   _ncbcancel:= 160
	   _ncfuncin := 150
	ENDIF   
	
Endif

If _nbotao == 1 //Se só tem botão de ok posiciona o ok na coluna do cancel

	_ncbok := _ncbcancel
	
Endif

//=============================================================================
//Monta tela
//=============================================================================

oDlg = TDialog():New( _nlini,_ncini, _nlfim,(_ncfim+10), _ctitu+" ["+DTOC(DATE())+"] ["+TIME()+"]",,,,, CLR_BLACK,CLR_WHITE ,,,.T.,,,,,, )
oDlg:SetCss(cEstilo0)  
    
 
    //==========================================================================
    //Box de Mensagem/Problema
    //==========================================================================    
  	IF VALTYPE(_bMaisDetalhes) = "B" 
       nLinIni:=IF(lHtml,53,52) 
       oBtnMD:= TButton():New( nLinIni ,03,"Mais Detalhes" ,oDlg,{|| EVAL(_bMaisDetalhes) },53,14,,,.F.,.T.,.F.,,.F.,,,.F. )
       oBtnMD:SetCss(cEstiloMD) 
       nLinFim:=IF(lHtml,47,47)
	   nIniSol:=nLinFim+22
    ELSE
       nLinFim:=IF(lHtml,55,62)
	   nIniSol:=nLinFim+7
    ENDIF
  	If !EMPTY(_csolu)
	   _cTitMen:="Problema"
	ELSE
	   _cTitMen:="Mensagem"
	ENDIF
    nLinIni:=01                                          //Largura ,Altura   
  	oSay1:= TSay():New(nLinIni ,03,{||_cTitMen},oDlg,,,,,,.T.,,,205,nLinFim,,,,,,.T.) 
  	oSay1:SetCss(cEstilo3) 

    nLinIni:=nLinIni+12
  	oSay11:= TSay():New(nLinIni,05,{||_cMens  },oDlg,,,,,,.T.,,,201,(nLinFim-14),,,,,,.T.) 
  	oSay11:SetCss(cEstilo11) 
  	
  	//==========================================================================
    //Box de solução
    //==========================================================================
  	If !EMPTY(_csolu)
  	  	nLinFim:=IF(lHtml,71,74)                             //Largura ,Altura   
  		oSay32:=TSay():New(nIniSol,03,{||"Solução"},oDlg,,,,,,.T.,,,205,nLinFim,,,,,,.T.) 
  		oSay32:SetCss(cEstilo3)
  		
        nIniSol:=nIniSol+12
  	  	nLinFim:=IF(lHtml,56,nLinFim-12)                     //Largura ,Altura   
  		oSay33:=TSay():New(nIniSol,05,{||_csolu   },oDlg,,,,,,.T.,,,201,nLinFim,,,,,,.T.) 
  		oSay33:SetCss(cEstilo11)  		
	    
		_nlinbot := 185 //LINHA DOS BOTÕES / BOX DE FUNÇÃO / PILHA DE CHAMADAS
    ELSE
	    _nlinbot := 110 //LINHA DOS BOTÕES / BOX DE FUNÇÃO / PILHA DE CHAMADAS
  	Endif 

  	//==========================================================================
    //Ícone
    //==========================================================================
  	
  	If _ntipo == 1
  	
  	 	oTBitmap1 := TBitmap():New(_lincone,220,63,275,,"\data\italac\img\cancel.png",.T.,oDlg,;
  	 	{||},,.F.,.F.,,,.F.,,.T.,,.F.)
  	 	oTBitmap1:SetCss(cEstilo4)
  	 	
  	Endif 
  	
  	If _ntipo == 2
  	
  	 	oTBitmap1 := TBitmap():New(_lincone,220,63,275,,"\data\italac\img\ok.png",.T.,oDlg,;
  	 	{||},,.F.,.F.,,,.F.,,.T.,,.F.)
  	 	oTBitmap1:SetCss(cEstilo4)
  	 	
  	Endif 
   	
  	If _ntipo == 3
  	
  	 	oTBitmap1 := TBitmap():New(_lincone,220,63,275,,"\data\italac\img\alert.png",.T.,oDlg,;
  	 	{||},,.F.,.F.,,,.F.,,.T.,,.F.)
  	 	oTBitmap1:SetCss(cEstilo4)
  	 	
  	Endif 
  	
  	//==========================================================================
    //Box de função / Pinha de chamadas
    //==========================================================================
	                                                              //Largura ,Altura
   	oSay4:= TSay():New(_nlinbot-38,03,{||" "     },oDlg,,,,,,.T.,,,_ncfuncin,58,,,,,,.T.) 
  	oSay4:SetCss(cEstilo3) 

	                                                                 //Largura ,Altura
   	oSay5:= TSay():New(_nlinbot-36,14,{||_cfuncao},oDlg,,,,,,.T.,,,_ncfuncin-12,58-04,,,,,,.T.) 
    oSay5:SetCss(cEstilo11)  		

  	//==========================================================================
    //Botão OK/Sim
    //==========================================================================
    oBtnOK 		:= TButton():New(_nlinbot,_ncbok,_cmenok   ,oDlg,{|| _lRet := .T. , (oDlg:End()) },55,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    If _nmenbot <> 4 .AND. _ntipo <> 1
       oBtnOK:SetCss(cEstilo1) 
	ENDIF
    
    //==========================================================================
    //Botão Cancela/Não
    //==========================================================================
    If _nbotao == 2
    
    	oBtnCan 	:= TButton():New(_nlinbot,_ncbcancel,_cmencan	,oDlg,{|| _lRet := .F. , (oDlg:End()) },55,20,,,.F.,.T.,.F.,,.F.,,,.F. )
        If _nmenbot <> 4
    	   oBtnCan:SetCss(cEstilo2)
		ENDIF
    	
    Endif

  	//==========================================================================
    //Botão das pilhas de chamada
    //==========================================================================
    oBtnMD:= TButton():New(_nlinbot-36,04,"..." ,oDlg,bPilha,12,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnMD:SetCss(cEstiloMD) 

    IF _lRetXNil
	   _lRet:=NIL
	ENDIF

   oDlg:Activate( , , , .T. )
      
End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: ITputx1()
Autor-------------: Josué Danich Prestes
Data da Criacao---: 03/07/2017
Descrição---------: Função temporária de criação de sx1
Parametros--------: Iguais ao putsx1 original:
					http://tdn.totvs.com/pages/releaseview.action?pageId=244740739
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITPUTX1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lAmbTeste:=SuperGetMV("IT_AMBTEST",.F.,.T.)

Default cValid := " "
Default cPerSpa := " " 
Default cPerEng := " "
Default cVar := " "
Default nPresel := " "
Default cGSC := " "
Default cF3 := " "
Default cGrpSxg := " "
Default cPyme := " "

Default cVar01 := " "
Default cDef01 := " "
Default cDefSpa1 := " "
Default cDefEng1 := " "
Default cCnt01 := " "

Default cDef02 := " "
Default cDefSpa2 := " "
Default cDefEng2 := " "

Default cDef03 := " "
Default cDefSpa3 := " "
Default cDefEng3 := " "


Default cDef04 := " "
Default cDefSpa4 := " "
Default cDefEng4 := " "


Default cDef05 := " "
Default cDefSpa5 := " "
Default cDefEng5 := " "


Default cHelp := " "


cKey := "P" + AllTrim( cGrupo ) + AllTrim( cOrdem ) 

cPyme    := Iif( cPyme         	== Nil, " ", cPyme        ) 
cF3      := Iif( cF3           	== NIl, " ", cF3          ) 
cGrpSxg  := Iif( cGrpSxg     	== Nil, " ", cGrpSxg      ) 
cCnt01   := Iif( cCnt01         == Nil, "" , cCnt01       ) 
cHelp    := Iif( cHelp          == Nil, "" , cHelp        ) 

SX1->(dbSetOrder( 1 ) )

IF LEFT(cGrupo,1) = "*"

   cGrupo := SUBSTR(cGrupo,2)
   cGrupo := PadR( cGrupo , 10 , " " ) 
   If !SX1->( DbSeek( cGrupo + cOrdem ))
     //U_ITCONOUT("CHAVE SX1: "+cGrupo + cOrdem+" JÁ EXCLUIDA.")
      RETURN .F.
   ELSE
      IF !SuperGetMV("IT_AMBTEST",.F.,.T.)
         SX1->(Reclock( "SX1" , .F. ))
         SX1->(DBDELETE())
		 SX1->(MSUNLOCK())
      ELSE
	     U_ITMSG("CHAVE SX1: "+cGrupo + cOrdem+" NÃO PODE SER EXCLUIDA NO AMBIENTE: "+Upper( GetEnvServer() )+" por segurança.","Atenção","Somente em ambintes DESENV e quando atualizado na PRODUCAO",3)
         RETURN .F.
      ENDIF   
   ENDIF

   RETURN .T.
ENDIF


cGrupo := PadR( cGrupo , 10 , " " ) 

If !( DbSeek( cGrupo + cOrdem )) .OR. lAmbTeste

     cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     If !SX1->( DbSeek( cGrupo + cOrdem ))
        Reclock( "SX1" , .T. ) 
     ELSE
        Reclock( "SX1" , .F. ) 
     ENDIF

     SX1->( FieldPut( FieldPos( "X1_GRUPO"  ), cGrupo ) )
     SX1->( FieldPut( FieldPos( "X1_PERGUNT"  ), cPergunt ) )
     SX1->( FieldPut( FieldPos( "X1_PERSPA"  ), cPerSpa ) )
     SX1->( FieldPut( FieldPos( "X1_PERENG"  ), cPerEng ) )
     SX1->( FieldPut( FieldPos( "X1_VARIAVL"  ), cVar ) )
     SX1->( FieldPut( FieldPos( "X1_TIPO"  ), cTipo ) )
     SX1->( FieldPut( FieldPos( "X1_TAMANHO"  ), nTamanho ) )
     SX1->( FieldPut( FieldPos( "X1_DECIMAL"  ), nDecimal ) )
     SX1->( FieldPut( FieldPos( "X1_PRESEL"  ), nPresel ) )
     SX1->( FieldPut( FieldPos( "X1_GSC"  ), cGSC ) )
     SX1->( FieldPut( FieldPos( "X1_VALID"  ), cValid ) )
     SX1->( FieldPut( FieldPos( "X1_ORDEM"  ), cOrdem ) )
     SX1->( FieldPut( FieldPos( "X1_VAR01"  ), cVar01 ) )
     SX1->( FieldPut( FieldPos( "X1_F3"  ), cF3 ) )
     SX1->( FieldPut( FieldPos( "X1_GRPSXG"  ), cGrpSxg ) )
     SX1->( FieldPut( FieldPos( "X1_CNT01"  ), cCnt01 ) )
 
     If cGSC == "C"               // Mult Escolha 

          SX1->( FieldPut( FieldPos( "X1_DEF01"  ), cDef01 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFSPA1"  ), cDefSpa1 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFENG1"  ), cDefEng1 ) )

          SX1->( FieldPut( FieldPos( "X1_DEF02"  ), cDef02 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFSPA2"  ), cDefSpa2 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFENG2"  ), cDefEng2 ) )

          SX1->( FieldPut( FieldPos( "X1_DEF03"  ), cDef03 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFSPA3"  ), cDefSpa3 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFENG3"  ), cDefEng3 ) )

          SX1->( FieldPut( FieldPos( "X1_DEF04"  ), cDef04 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFSPA4"  ), cDefSpa4 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFENG4"  ), cDefEng4 ) )

          SX1->( FieldPut( FieldPos( "X1_DEF05"  ), cDef05 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFSPA5"  ), cDefSpa5 ) )
          SX1->( FieldPut( FieldPos( "X1_DEFENG5"  ), cDefEng5 ) )

     Endif 

     SX1->( FieldPut( FieldPos( "X1_HELP"  ), cKey ) )

	 Pergunte(cGrupo,.F.)//chamado para abrir a tabela XB4 que sera gravada no u_ITX1Help()

     u_ITX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

     MsUnlock() 

Endif 

RestArea( aArea ) 

Return

/*
===============================================================================================================================
Programa----------: ITLstFil
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Lista as Filiais do Sistema para seleção - programado para mudar para admgetfil - F3 SM0001 do SXB
Parametros--------: lVldAcs	- Define se deve verificar o acesso do usuário às Filiais
Retorno-----------: .T.		- Compatibilização para utilização com F3 SM0001 do SXB
===============================================================================================================================
*/
User Function ITLSTFIL( lVldAcs )

Local _aAcesso		:= FWEmpLoad(.F.)
Local _nI			:= 0
Local  nI            := 0
Local _nPadR		:= 0

Private nTam		:= 02
Private nMaxSelect	:= 25
Private aCat		:= {}
Private MvRet		:= Alltrim( ReadVar() )
Private MvPar		:= ""
Private cTitulo		:= "Filiais do Sistema"
Private MvParDef	:= ""

IF TYPE("_cSeparador") <> "C"
   PRIVATE _cSeparador:=";"
ENDIF 

Default lVldAcs		:= .F.


#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//===========================================================================
//| Recupera dados das filiais                                              |
//===========================================================================
SM0->( DBSetOrder(1) )
//SM0->( DBGoTop() )
//While SM0->( !Eof() )
	
	//If lVldAcs
		
		For nI := 1 To Len(_aAcesso)
			
			If  SM0->(dbSeek( AllTrim(_aAcesso[nI][01]) + AllTrim(_aAcesso[nI][03]) )) //AllTrim(SM0->M0_CODIGO) == AllTrim(_aAcesso[nI][01]) .And. AllTrim(SM0->M0_CODFIL) == AllTrim(_aAcesso[nI][03])
				
				MvParDef += alltrim(SM0->M0_CODFIL)
				aAdd( aCat , AllTrim( SM0->M0_FILIAL ) )
				//Exit
				
			EndIf
			
		Next
		
	//Else
	
		//MvParDef += alltrim(SM0->M0_CODFIL)
		//aAdd( aCat , AllTrim( SM0->M0_FILIAL ) )
	
	//EndIf
	
//SM0->( DBSkip() )
//EndDo

If Empty(MvRet)
	MvRet := '_cGetFil'
EndIf

_nPadR := Len( &MvRet )

//===========================================================================
//| Mantém a marcação anterior                                              |
//===========================================================================
If Len( AllTrim(&MvRet) ) == 0

	MvPar	:= PadR( AllTrim( StrTran( &MvRet , _cSeparador , "" ) ) , Len(aCat) )
	&MvRet	:= PadR( AllTrim( StrTran( &MvRet , _cSeparador , "" ) ) , Len(aCat) )

Else

	MvPar	:= AllTrim( StrTran( &MvRet , _cSeparador , "/" ) )

EndIf

//====================================================================================================
// Executa funcao que monta tela de opcoes
//====================================================================================================
If F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )
	
	&MvRet := ''
	
	For _nI := 1 To Len( MvPar ) Step nTam
	
		If !( SubStr( MvPar , _nI , 1 ) $ " |*" )
			&MvRet += SubStr( MvPar , _nI , nTam ) + _cSeparador
		EndIf
		
	Next _nI
	
	&MvRet := PadR( SubStr( &MvRet , 1 , Len( &MvRet ) - 1 ) , _nPadR )

EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: U_ITVALFIL(@MV_PARXX)
Autor-------------: Alex Wallauer
Data da Criacao---: 04/06/2014
Descrição---------: Valida se as filiais são válidas e se o usuario tem acesso
Parametros--------: _cFiliais: passe com @sua variavel
Retorno-----------: .T.
===============================================================================================================================
*/
User Function ITVALFIL( _cFiliais )
LOCAL cTimeInicial:=TIME() , nI
LOCAL _cFilSemAcesso:=""
LOCAL _cFilNaoExiste:=""
LOCAL _cFilsAcesso  :=""
PRIVATE _aAcesso:= {}

FWMSGRUN( ,{|| _aAcesso:= FWEmpLoad(.F.) } , "Lendo Acessos de filiais - Hora Inicial: "+cTimeInicial+", Aguarde...",  )
For nI := 1 To LEN(_aAcesso)
	_cFilsAcesso+=_aAcesso[nI][03]+", "
Next

If EMPTY(_cFiliais)
   U_ITMSG("Com O campo filial em branco, somente as filiais que o usuario tem acesso serao selecionadas: "+_cFilsAcesso,'Atenção!',,3)
   _cFiliais:=STRTRAN( _cFilsAcesso, ", ", ";")
Else
  SM0->(dbSetOrder(1))
  _nRecnoSM0 := SM0->(Recno())
  _aFilSelecionados := U_ITLinDel( AllTrim(_cFiliais) , ";" )
  For nI := 1 To Len(_aFilSelecionados)
       IF !SM0->(dbSeek(cEmpAnt + _aFilSelecionados[nI]))
  	     _cFilNaoExiste+="[ "+_aFilSelecionados[nI]+" ] "
		 LOOP
  	  EndIf
  	  If ASCAN( _aAcesso , {|F| F[3] == _aFilSelecionados[nI] } ) = 0
  	     _cFilSemAcesso+="[ "+_aFilSelecionados[nI]+" ] "
  	  EndIf
  Next
  SM0->(DbGoTo(_nRecnoSM0))
  If !EMPTY(_cFilNaoExiste)
  	  u_itmsg("A(s) Filiai(s): "+_cFilNaoExiste+" não são válidas." , "Atenção!" ,"Selecione as filiais validas pelo F3.",1 )
  	  RETURN .F.	
  EndIf
  If !EMPTY(_cFilSemAcesso)
  	  u_itmsg("O usuário não tem acesso a(s) Filiai(s): "+_cFilSemAcesso,"Atenção!","Selecione as filiais com acesso pelo F3.",1 )
  	  RETURN .F.	
  EndIf
ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa----------: ITProCod
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Recupera o próximo código para o Alias e Campo informados
Parametros--------: cAlias	- Alias da Tabela
------------------: cCampo	- Campo da Tabela
Retorno-----------: cRet	- Retorna o próximo código disponível
===============================================================================================================================
*/
User Function ITProCod( cAlias , cCampo )

Local cRet		:= ""
Local nValAux	:= 0
Local cQuery	:= ""
Local cTrbAux	:= GetNextAlias()

//===========================================================================
//| Monta a consulta                                                        |
//===========================================================================
cQuery := " SELECT "
cQuery += "		MAX( AUX."+ cCampo +" ) AS COD "
cQuery += " FROM "+ RetSqlName(cAlias) +" AUX "
cQuery += " WHERE "
cQuery += " 		AUX.D_E_L_E_T_ = ' ' "


MPSysOpenQuery( cQuery , cTrbAux )

//===========================================================================
//| Recupera o código                                                       |
//===========================================================================
(cTrbAux)->( DBGoTop() )
If (cTrbAux)->(!Eof())
	nValAux := Val( (cTrbAux)->COD )
EndIf

cRet := StrZero( nValAux + 1 , TamSX3(cCampo)[01] )

Return(cRet)

/*
===============================================================================================================================
Programa----------: ITRETMAT
Autor-------------: Alexandre Villar
Data da Criacao---: 03/06/2014
Descrição---------: Rotina que retorna a matrícula do usuário a partir do Cód. Usuário do Protheus.
Parametros--------: cCodUsr - id do usuário 
Retorno-----------: cmatric - matricula do usuário no SRA
===============================================================================================================================
*/
User Function ITRETMAT( cCodUsr )

//Local nRecUSR	:= PswRecno()
Local aUsrAux	:= {}
Local cMatric	:= ""

PswOrder(1)
IF PswSeek(cCodUsr)
	aUsrAux := PswRet(1)
	cMatric := SubStr( aUsrAux[01][22] , 3 , 8 )
EndIF

Return( cMatric )	

/*
===============================================================================================================================
Programa----------: LSTCARGA
Autor-------------: Cleiton Campos
Data da Criacao---: 17/03/2009
Descrição---------: Monta tela para consulta e seleção de cargas
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
user function LSTCARGA()

Local i		 		:= 0
//Local n		 		:= 0
Local _cQuery		:= ""

Private nTam		:= 0
Private nMaxSelect	:= 0
Private aCat		:= {}
Private MvRet		:= Alltrim( ReadVar() )
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//Tratamento para carregar variaveis da lista de opcoes
nTam		:= 6
nMaxSelect	:= 27 //16 * 6 = 96 (cod(5) +";") = 6
cTitulo		:="Cargas"

_cQuery := " SELECT DAK_COD, DAK_DATA "
_cQuery += " FROM  "+ RetSqlName("DAK") +" DAK "
_cQuery += " WHERE "+ RetSqlCond('DAK')
_cQuery += " AND   DAK_DATA BETWEEN '"+ DtoS(MV_PAR15) +"' AND '"+ DtoS(MV_PAR16) +"' "
_cQuery += " ORDER BY DAK_COD "

MPSysOpenQuery( _cQuery , "TDAK")

TDAK->( DBGoTop() )
while TDAK->( !Eof() )

	MvParDef += AllTrim(TDAK->DAK_COD)
	aAdd(aCat,AllTrim(DtoC(StoD(TDAK->DAK_DATA))))
	
TDAK->( DBSkip() )
EndDo

TDAK->( DBCloseArea() )

//===================================================================================================
//Trativa abaixo para no caso de uma alteracao do campo trazer todos
//os dados que foram selecionados anteriormente.                    
//===================================================================================================
If Len( AllTrim( &MvRet ) ) == 0

	MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len( aCat ) )
	&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len( aCat ) )
	
Else
		
	MvPar	:= AllTrim( StrTran( &MvRet , ";" , "/" ) )

EndIf

//===================================================================================================
//Somente altera o conteudo caso o usuario clique no botao ok
//===================================================================================================
//Executa funcao que monta tela de opcoes
If f_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

	//Tratamento para separar retorno com barra ";"
	&MvRet := ""
	
	For i := 1 to Len(MvPar) step nTam
	
		If !( SubStr( MvPar , i , 1 ) $ " |*" )
			&MvRet += SubStr( MvPar , i , nTam ) +";"
		EndIf
		
	Next i
	
	//Trata para tirar o ultimo caracter
	&MvRet := SubStr( &MvRet , 1 , Len( &MvRet ) - 1 )
    &MvRet := &MvRet + Space(100)
ELSE
    IF LEN(&MvRet) < 99
       &MvRet := &MvRet + Space(100)
    ENDIF
EndIf

Return(.T.) 

/*
===============================================================================================================================
Programa----------: VISCANHO
Autor-------------: Josué Danich
Data da Criacao---: 12/01/2018
Descrição---------: Tela de visualização de canhoto armazenado na Estec
Parametros--------: _cFilial - Filial da nota
					_cNota - Número da Nota
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function VISCANHO( _cFilial, _cNota , _lBotao )

Local oDlg2			:= Nil
Local oGCarga		:= Nil
Local cGCarga		:= Nil
Local oGCGC			:= Nil
Local cGCGC			:= Nil
Local oGDescCli		:= Nil
Local cGDescCli		:= Nil
Local oGEmissao		:= Nil
Local cGEmissao		:= Nil
Local cGetObser		:= Nil
Local cPGetObser	:= ""
Local cGNumNF		:= Nil
//Local oGRede		:= Nil
Local cGRede		:= ""
Local cGSerie		:= Nil
Local oGVlrNF		:= Nil
Local cGVlrNF		:= Nil
Local oGetStat      := Nil
Local cGetstat      := "Aguardando Conferencia" 
Local cGetDtCanh  	:= ""
Local _aBotoes		:= {}
Local _nColFolder   :=  600
Local _nLinFolder   :=  250
Local _nColPanel    :=  600
Local _nLinPanel    :=  125 // 100
Local _nDivisao     :=  99  //130
Local _nInicio      :=  30
Local _nRecAtual    :=  SC5->(RECNO())//mBrowse
Local _nRecSC5      :=  0//quando clica no _lBotao e é troca nota
Local _nRecSF2      :=  SF2->(RECNO())//mBrowse
Local _nRecGerador  :=  0
Local cPGCGC		:= ""
Local cPEndCliente  := ""
Local cPGDescCli    := ""
Local cPGRede       := ""
Local cPGSerie      := ""
Local cPGCarga      := ""
Local cPGEmissao    := ""
Local cPGVlrNF      := ""
Local cPPresoBruto  := ""
Local cPGetstat     := ""
Local cPGetDtCanh   := ""
Local cPTransport   := ""
Local cPTpOperacao  := ""
Local cPTpcarga     := ""
Local cQtdePallets  := ""
Local cFilAux2      := ""
Local cCanhoto2     := ""
Local cFilAux3      := ""
Local cCanhoto3     := ""
Local cSerie3       := ""
Local cEndCliente   := ""
Local cNFBotao      := ""
Local cTpcarga      := ""
Local cTpOperacao   := ""
Local cPVProd       := ""
Local cPVPallet     := ""
Local nCol1         := 05
Local nCol2         := 90 
Local _aFoders      := {}
Local _cOpCod       := ""
Local _cOPLoja      := ""
Local _cOPTitu      := ""
Local _cOPTit2      := ""
Local _cAprOperL    := ""
                   
//-------------- Variáveis do Produto				   
Local _dPrevEOL := Ctod("  /  /  ") // F2_I_PENOL - Previsão de entrega no operador logístico 
Local _dPrevECL := Ctod("  /  /  ") // F2_I_PENCL - Previsão de entrega no cliente
Local _dChegOL  := Ctod("  /  /  ") // F2_I_DCHOL - Data de chegada no operador logístico 
Local _dChegCL  := Ctod("  /  /  ") // F2_I_DCHCL - Data de chegada no cliente
Local _dEntrOL  := Ctod("  /  /  ") // F2_I_DENOL - Data de entrega no operador logístico 
Local _dEntrCL  := Ctod("  /  /  ") // F2_I_DENCL - Data de entrega no cliente
//--------------- Variáveis do Pallet
Local _dPPrevEOL := Ctod("  /  /  ") // F2_I_PENOL - Previsão de entrega no operador logístico 
Local _dPPrevECL := Ctod("  /  /  ") // F2_I_PENCL - Previsão de entrega no cliente
Local _dPChegOL  := Ctod("  /  /  ") // F2_I_DCHOL - Data de chegada no operador logístico 
Local _dPChegCL  := Ctod("  /  /  ") // F2_I_DCHCL - Data de chegada no cliente
Local _dPEntrOL  := Ctod("  /  /  ") // F2_I_DENOL - Data de entrega no operador logístico 
Local _dPEntrCL  := Ctod("  /  /  ") // F2_I_DENCL - Data de entrega no cliente

DEFAULT _cFilial:= SC5->C5_FILIAL
DEFAULT _cNota  := SC5->C5_NOTA
DEFAULT _lBotao := .T.

cFilAux2 := _cFilial //Não usar cfilant por causa do troca nota

//Valida Dados
SF2->(Dbsetorder(1))
If !SF2->(Dbseek(_cFilial+_cNota)) .OR. SF2->F2_TIPO != "N"
	U_ITMSG("Nota Fiscal não encontrada: "+_cFilial+" - "+_cNota+" ou não é Tipo Normal","Atenção",,1)
	Return .F.
Endif

SC5->(DBSETORDER(1))
IF !SC5->(DBSeek(_cFilial+SF2->F2_I_PEDID))
	U_ITMSG("Pedido não encontrado: "+_cFilial+" - "+SF2->F2_I_PEDID,"Atenção",,1)
	Return .F.
Endif
_nRecSC5:= SC5->(RECNO())//quando clica no _lBotao e é troca nota

SA1->(Dbsetorder(1))
SA2->(DBSETORDER(1))
SC6->(DBSETORDER(1))
DAK->(DBSetOrder(1))
DAI->(DBSetOrder(4))//DAI_FILIAL+DAI_PEDIDO+DAI->DAI_COD+DAI_SEQCAR

IF !EMPTY(SC5->C5_I_NPALE) .AND. SC5->(DBSeek(_cFilial+SC5->C5_I_NPALE))

	IF SC5->C5_I_PEDGE == 'S' // É o Pedido Gerador de Pallet
	   _nRecGerador:=SC5->(RECNO())
       SC5->(DBGOTO(_nRecSC5))//Volta para o pedido de Pallet posicionado anterior quando chamada no browse para dar carga do Pallet
	ENDIF

	IF SC5->C5_I_PEDPA == 'S'// É o Pedido de Pallet carrega os dados da tela de Pallet

	   //AQUI SEMPRE CARREGA OS DADOS DO PEDIDO DO PALLET

       SF2->(Dbseek(SC5->C5_FILIAL+SC5->C5_NOTA)) 
       ZGJ->(Dbseek(SC5->C5_FILIAL+SC5->C5_NOTA))
       SA1->(Dbseek(xFilial()+SF2->F2_CLIENTE+SF2->F2_LOJA))
       SA2->(DBSeek(xFilial()+SF2->F2_I_CTRA+SF2->F2_I_LTRA))
       SC6->(DBSeek(SC5->C5_FILIAL+SC5->C5_NUM))//Para pegar a qtde do Pallet do pedido de pallet pois estou posicionado nele
       cQtdePallets := AllTrim( Transform(  SC6->C6_QTDVEN , PesqPict( "SC6" , "C6_QTDVEN" ) ) )
	   cFilAux2     := SC5->C5_FILIAL
       cCanhoto2    := SC5->C5_NOTA//Tem Pallet
       cPVPallet    := SC5->C5_FILIAL+" / "+SC5->C5_NUM//PEDIO DO PALLET
       cPGCGC		:= IF(LEN(ALLTRIM(SA1->A1_CGC)) == 11,Transform(SA1->A1_CGC,"@R 999.999.999-99"),Transform(SA1->A1_CGC,"@R! NN.NNN.NNN/NNNN-99"))
       cPEndCliente	:= ALLTRIM(SA1->A1_END) + ' / ' + Alltrim(SA1->A1_BAIRRO) + ' / '+ALLTRIM(SA1->A1_MUN) + ' / '+ALLTRIM(SA1->A1_EST)
       cPGDescCli	:= SA1->A1_NOME
       cPGRede		:= POSICIONE("ACY",1,xfilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI")
       cPGSerie		:= SF2->F2_SERIE
       cPGCarga		:= SF2->F2_CARGA
       cPGEmissao	:= SF2->F2_EMISSAO
       cPGVlrNF	    := AllTrim( Transform(  SF2->F2_VALBRUT, PesqPict( "SF2" , "F2_VALBRUT") ) )
       cPPresoBruto := AllTrim( Transform(  SF2->F2_PBRUTO , PesqPict( "SF2" , "F2_PBRUTO" ) ) )
       
	   //------------ Carrega as datas com os dados da nota de pallet.
       _dPPrevEOL   := SF2->F2_I_PENOL // Previsão de entrega no operador logístico 
       _dPPrevECL   := SF2->F2_I_PENCL // Previsão de entrega no cliente
       _dPChegOL    := SF2->F2_I_DCHOL // Data de chegada no operador logístico 
       _dPChegCL    := SF2->F2_I_DCHCL // Data de chegada no cliente
       _dPEntrOL    := SF2->F2_I_DENOL // Data de entrega no operador logístico 
       _dPEntrCL    := SF2->F2_I_DENCL // Data de entrega no cliente

	   cPAprovCanh  := ""
	   ZGJ->(Dbsetorder(1))
	   IF ZGJ->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
          cPGetDtCanh  := DTOC(ZGJ->ZGJ_DTENT)
          cPAprovCanh  := UsrFullName(ALLTRIM(ZGJ->ZGJ_APROVA))
          cPDatavCanh  := DTOC(ZGJ->ZGJ_DATAA)
          cPHoravCanh  := ZGJ->ZGJ_HORAA
          cPGetObser   := ZGJ->ZGJ_OBS
          cPGetstat    := ZGJ->ZGJ_STATUS
	   ELSE
          cPGetDtCanh  := DTOC(SF2->F2_I_DTRC)
          cPDatavCanh  := DTOC(SF2->F2_I_CDATA)
          cPHoravCanh  := SF2->F2_I_CHORA
          cPGetObser   := SF2->F2_I_OBRC
          IF !EMPTY(CTOD(cPGetDtCanh))
             cPGetstat := "Aprovado"
          ENDIF
	   ENDIF
       IF EMPTY(cPAprovCanh)//Pq o conteudo do campo ZGJ_APROVA dos antigos não é __cUserID, coloquei a partir de 16/06/2022
          cPAprovCanh  := UsrFullName((SF2->F2_I_CUSER))
	   ENDIF
       IF EMPTY(cPAprovCanh)//Pq se conteudo do campo F2_I_CUSER for branco e o ZGJ_APROVA for o antigo vai ele mesmo
          cPAprovCanh  := ZGJ->ZGJ_APROVA
       ENDIF
       cPAprovacao:=ALLTRIM(cPAprovCanh)
       IF !EMPTY(CTOD(cPDatavCanh))
          cPAprovacao+=" - "+cPDatavCanh
       ENDIF
       IF !EMPTY(cPHoravCanh)
          cPAprovacao+=" - "+cPHoravCanh
       ENDIF

	   _cCPFCNPJ  := IF(LEN(ALLTRIM(SA2->A2_CGC)) == 11,Transform(SA2->A2_CGC,"@R 999.999.999-99"),Transform(SA2->A2_CGC,"@R! NN.NNN.NNN/NNNN-99"))
       cPTransport:= ALLTRIM(SF2->F2_I_NTRAN) + ' / '+_cCPFCNPJ

	  cPTpOperacao := SC5->C5_I_OPER
       If !Empty( SF2->F2_CARGA )
          DAK->(DBSEEK(_cFilial + SF2->F2_CARGA ) )
          DAI->(DBSEEK(DAK->DAK_FILIAL+ SF2->F2_I_PEDID + DAK->DAK_COD + DAK->DAK_SEQCAR ))
          cPTpcarga:=IF(DAI->DAI_I_TIPC="1","1-Pallet Chep",IF(DAI->DAI_I_TIPC="2","2-Estivada",IF(DAI->DAI_I_TIPC="3","3-Pallet PBR",IF(DAI->DAI_I_TIPC="4","4-Pallet Descartavel",IF(DAI->DAI_I_TIPC="5","5-Pallet Chep Retorno",IF(DAI->DAI_I_TIPC="6","6-Pallet PBR Retorno","            "))))))
       ELSE
          cPTpcarga:=IF(SC5->C5_I_TIPCA='1','1=Paletizada','2=Batida')   
       ENDIF

	   IF _nRecGerador # 0
          SC5->(DBGOTO(_nRecGerador))//Volta para o pedido Gerador de Pallet QUANDO ESTOU NO PV DE PALLET NO BROWSE
       ELSE  
          SC5->(DBGOTO(_nRecSC5))//Volta para o pedido Gerador de Pallet QUANDO JA ESTOU NO PV GERADOR NO BROWSE
       ENDIF   
       SF2->(Dbseek(SC5->C5_FILIAL+SC5->C5_NOTA)) //Volta para a NF do pedido Gerador de Pallet

	ENDIF

ENDIF

//AQUI SEMPRE CARREGA OS DADOS DO PEDIDO DO PRODUTO
cPVProd := SC5->C5_FILIAL+" / "+SC5->C5_NUM

If !Empty( SF2->F2_CARGA )
   DAK->(DBSEEK(_cFilial + SF2->F2_CARGA ) )
   DAI->(DBSEEK(DAK->DAK_FILIAL+ SF2->F2_I_PEDID + DAK->DAK_COD + DAK->DAK_SEQCAR ))
   cTpcarga:=IF(DAI->DAI_I_TIPC="1","1-Pallet Chep",IF(DAI->DAI_I_TIPC="2","2-Estivada",IF(DAI->DAI_I_TIPC="3","3-Pallet PBR",IF(DAI->DAI_I_TIPC="4","4-Pallet Descartavel",IF(DAI->DAI_I_TIPC="5","5-Pallet Chep Retorno",IF(DAI->DAI_I_TIPC="6","6-Pallet PBR Retorno","            "))))))
ELSE
   cTpcarga:=IF(SC5->C5_I_TIPCA='1','1=Paletizada','2=Batida')   
ENDIF

SA1->(Dbseek(xFilial()+SF2->F2_CLIENTE+SF2->F2_LOJA))
SA2->(DBSeek(xFilial()+SF2->F2_I_CTRA+SF2->F2_I_LTRA))
cGCGC		:=IF(LEN(ALLTRIM(SA1->A1_CGC)) == 11,Transform(SA1->A1_CGC,"@R 999.999.999-99"),Transform(SA1->A1_CGC,"@R! NN.NNN.NNN/NNNN-99"))
cEndCliente	:= ALLTRIM(SA1->A1_END) + ' / ' + Alltrim(SA1->A1_BAIRRO) + ' / '+ALLTRIM(SA1->A1_MUN) + ' / '+ALLTRIM(SA1->A1_EST)
cGDescCli	:= SA1->A1_NOME
cGCarga		:= SF2->F2_CARGA
cGEmissao	:= SF2->F2_EMISSAO
cGNumNF		:= SF2->F2_DOC
cGRede		:= POSICIONE("ACY",1,xfilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI")
cGSerie		:= SF2->F2_SERIE
cGVlrNF		:= AllTrim( Transform(  SF2->F2_VALBRUT, PesqPict( "SF2" , "F2_VALBRUT") ) )
cPresoBruto	:= AllTrim( Transform(  SF2->F2_PBRUTO , PesqPict( "SF2" , "F2_PBRUTO" ) ) )

//------ carrega as datas com os dados da nota do produto
_dPrevEOL := SF2->F2_I_PENOL // Previsão de entrega no operador logístico 
_dPrevECL := SF2->F2_I_PENCL // Previsão de entrega no cliente
_dChegOL  := SF2->F2_I_DCHOL // Data de chegada no operador logístico 
_dChegCL  := SF2->F2_I_DCHCL // Data de chegada no cliente
_dEntrOL  := SF2->F2_I_DENOL // Data de entrega no operador logístico 
_dEntrCL  := SF2->F2_I_DENCL // Data de entrega no cliente

If ! Empty(SF2->F2_I_OUSER)
    _cAprOperL  := ALLTRIM(LEFT(UsrFullName(SF2->F2_I_OUSER),25)) + " - " + DToc(SF2->F2_I_ODATA) + " - " + SF2->F2_I_OHORA
EndIf

cAprovCanh  := ""
ZGJ->(Dbsetorder(1))
IF ZGJ->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
   cGetstat    := ZGJ->ZGJ_STATUS
   cGetDtCanh  := DTOC(ZGJ->ZGJ_DTENT)
   cAprovCanh  := UsrFullName(ALLTRIM(ZGJ->ZGJ_APROVA))
   cDatavCanh  := DTOC(ZGJ->ZGJ_DATAA)
   cHoravCanh  := ZGJ->ZGJ_HORAA
   cGetObser   := ZGJ->ZGJ_OBS
ELSE
   cGetDtCanh  := DTOC(SF2->F2_I_DTRC)
   cDatavCanh  := DTOC(SF2->F2_I_CDATA)
   cHoravCanh  := SF2->F2_I_CHORA
   cGetObser   := SF2->F2_I_OBRC
   IF !EMPTY(CTOD(cGetDtCanh))
      cGetstat := "Aprovado"
   ENDIF
ENDIF
IF EMPTY(cAprovCanh)//Pq o conteudo do campo ZGJ_APROVA dos antigos não é __cUserID, coloquei a partir de 16/06/2022
   cAprovCanh  := ALLTRIM(LEFT(UsrFullName((SF2->F2_I_CUSER)),25))
ENDIF
IF EMPTY(cAprovCanh)//Pq se conteudo do campo F2_I_CUSER for branco e o ZGJ_APROVA for o antigo vai ele mesmo
   cAprovCanh  := ZGJ->ZGJ_APROVA
ENDIF
cAprovacao:=ALLTRIM(cAprovCanh)
IF !EMPTY(CTOD(cDatavCanh))
   cAprovacao+=" - "+cDatavCanh
ENDIF
IF !EMPTY(cHoravCanh)
   cAprovacao+=" - "+ALLTRIM(cHoravCanh)
ENDIF

_aAprovadores:={}
IF !EMPTY(cAprovacao) .AND. !Empty(_cAprOperL)
   _cAPTitu  := "Usuaraios de Aprovação - Data - Hora: "
   _cAprOperL:= "Alt.Dt.Entr.Opl.:"+STRTRAN(_cAprOperL," - ","-")
   cAprovacao:= "Apr. Canhoto: "+STRTRAN(cAprovacao," - ","-")
  _aAprovadores:={cAprovacao,_cAprOperL}
ENDIF      

_cCPFCNPJ:= IF(LEN(ALLTRIM(SA2->A2_CGC)) == 11,Transform(SA2->A2_CGC,"@R 999.999.999-99"),Transform(SA2->A2_CGC,"@R! NN.NNN.NNN/NNNN-99"))
cTransport  := ALLTRIM(SF2->F2_I_NTRAN) + ' / '+_cCPFCNPJ
cTpOperacao := SC5->C5_I_OPER

If !Empty(SF2->F2_I_REDP) 
   _cOpCod  := SF2->F2_I_REDP
   _cOPLoja := SF2->F2_I_RELO
   _cOPTitu := "Transportadora / Redespacho"
   _cOPTit2 := "Redespacho: "
ElseIf !Empty(SF2->F2_I_OPER) 
   _cOpCod  := SF2->F2_I_OPER
   _cOpLoja := SF2->F2_I_OPLO
   _cOPTitu := "Transportadora / Operador Logistico"
   _cOPTit2 := "Op. Log.: "
EndIf   
_aTransOperLog:={}
IF !EMPTY(_cOpCod) .AND. !Empty(_cOPLoja)
   SA2->(MsSeek(xFilial("SA2")+_cOpCod+_cOPLoja))
   _cCPFCNPJ := IF(LEN(ALLTRIM(SA2->A2_CGC)) == 11,Transform(SA2->A2_CGC,"@R 999.999.999-99"),Transform(SA2->A2_CGC,"@R! NN.NNN.NNN/NNNN-99"))
   _cOperLog := _cOPTit2+ALLTRIM(SA2->A2_NOME)+' / '+_cCPFCNPJ
   cTransport:= "Transp.: "+cTransport
  _aTransOperLog:={cTransport,_cOperLog}
ENDIF      

IF SC5->C5_I_TRCNF = "S" //TROCA NOTA
	
   IF SC5->C5_I_FLFNC <> SC5->C5_FILIAL  
	  cNFBotao:= "NF de Carregamento"
  	  SC5->(DBSeek(SC5->C5_I_FLFNC+SC5->C5_I_PDPR))
   ELSEIF SC5->C5_I_FILFT <> SC5->C5_FILIAL
	  cNFBotao:= "NF de Faturamento"
  	  SC5->(DBSeek(SC5->C5_I_FILFT+SC5->C5_I_PDFT))
   ENDIF
   SF2->(Dbseek(SC5->C5_FILIAL+SC5->C5_NOTA))
   cFilAux3  := SC5->C5_FILIAL
   cCanhoto3 := SC5->C5_NOTA
   cSerie3   := SF2->F2_SERIE

ELSEIF SC5->C5_I_OPER $ (ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42")))// Tipos de operações da operação trigular
   _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))
   _cOperFat       := LEFT(_cOperTriangular,2)
   _cOperRemessa   := RIGHT(_cOperTriangular,2)

   IF !EMPTY(SC5->C5_I_PVREM) .AND. SC5->C5_I_OPER = _cOperFat//Pedido de remessa do Pedido de Venda 
	  cNFBotao:= "NF de Remessa"
  	  SC5->(DBSeek(SC5->C5_FILIAL+SC5->C5_I_PVREM))
   ELSEIF !EMPTY(SC5->C5_I_PVFAT) .AND. SC5->C5_I_OPER = _cOperRemessa//Pedido de Venda do pedido de remessa
	  cNFBotao:= "NF de Venda"
  	  SC5->(DBSeek(SC5->C5_FILIAL+SC5->C5_I_PVFAT))
   ENDIF
   SF2->(Dbseek(SC5->C5_FILIAL+SC5->C5_NOTA))
   cFilAux3  := SC5->C5_FILIAL
   cCanhoto3 := SC5->C5_NOTA
   cSerie3   := SF2->F2_SERIE

ELSEIF !EMPTY(SC5->C5_I_PEVIN)// PEDIDO VINCULADO

   cNFBotao := "NF Vinculada"
   SC5->(Dbseek(_cFilial+SC5->C5_I_PEVIN))
   SF2->(Dbseek(SC5->C5_FILIAL+SC5->C5_NOTA))
   cFilAux3 := SC5->C5_FILIAL
   cCanhoto3:= SC5->C5_NOTA
   cSerie3  := SF2->F2_SERIE

ELSEIF SC5->C5_I_NFSED = "S" .and. !empty(SC5->C5_I_NFREF)//SEDEX

   cNFBotao := "NF de Sedex"
   cFilAux3 := SC5->C5_FILIAL
   cCanhoto3:= SC5->C5_I_NFREF
   cSerie3  := SC5->C5_I_SERNF
   _lBotao:=.F.//poe falso pq o default do parametro é .T. e o botão só vai aparecer se tiver outra nota DE SF2 vinculada

ENDIF

IF EMPTY(cCanhoto3)
   _lBotao:=.F.//poe falso pq o default do parametro é .T. e o botão só vai aparecer se tiver outra nota vinculada
ENDIF


SC5->(DBGOTO(_nRecSC5))//Volta para o pedido posicionado anterior quando do primeiro SEEK
SF2->(DBGOTO(_nRecSF2))//Volta para a NF posicionado anterior quando chamada no browse
DAI->(DBSetOrder(1))

DEFINE MSDIALOG oDlg2 TITLE "VISUALIZA OS DADOS DO RECEBIMENTO DO CANHOTO" FROM 000, 000  TO 590, 1200 COLORS 0, 16777215 PIXEL // 570, 1200

    _aFoders:={"Nota do Produto: "+(_cFilial+" / "+alltrim(cGNumNF)+" / "+cGSerie)}
    IF !EMPTY(cCanhoto2)
       AADD(_aFoders,"Nota do Pallet: "+(cFilAux2+" / "+alltrim(cCanhoto2)+" / "+cPGSerie) )
    ENDIF

    oTFolder1:= TFolder():New( _nInicio,1,_aFoders,,oDlg2,,,,.T., , _nColFolder,_nLinFolder )
	oPanel	 := TPanel():New( 1 , 1 , '' , oTFolder1:aDialogs[1] ,, .T. , .T. ,, , _nColPanel-5 , _nLinPanel , .T. , .T. )

    nLin5:=053
    nLin6:=nLin5+8
    nLin7:=076
    nLin8:=nLin7+8
    nCol1:=05
    nCol2:=80
    nCol3:=160
    nCol4:=268
    nCol5:=220
    nCol6:=410
    nCol7:=nCol6+77

//***********************************************************\\ FOLDER 1 //**************************************************************************
	@ 002, nCol1 SAY "Filial / No. / Serie da NF"				SIZE 090, 007 PIXEL OF oPanel  
	@ 010, nCol1 MSGET (_cFilial+" / "+alltrim(cGNumNF)+" / "+cGSerie) SIZE 060, 010 PIXEL OF oPanel  READONLY
	
	@ 002, nCol2 SAY "Cliente"					SIZE 175, 007 PIXEL OF oPanel  
	@ 010, nCol2 MSGET oGDescCli VAR cGDescCli	SIZE 175, 010 PIXEL OF oPanel  WHEN .F.
	
	@ 002, nCol4 SAY "Endereço do Cliente"		SIZE 300, 007 PIXEL OF oPanel    
	@ 010, nCol4 MSGET cEndCliente	            SIZE 300, 010 PIXEL OF oPanel  WHEN .F.

	@ 029, nCol1 SAY "CNPJ/CPF"					SIZE 025, 007 PIXEL OF oPanel  
	@ 037, nCol1 MSGET oGCGC VAR cGCGC			SIZE 060, 010 PIXEL OF oPanel  WHEN .F.
	
	@ 029, nCol2 SAY "Rede"						SIZE 074, 007 PIXEL OF oPanel  
	@ 037, nCol2 MSGET cGRede					SIZE 074, 010 PIXEL OF oPanel  WHEN .F.
	
	@ 029, nCol3 SAY "Emissão NF"				SIZE 025, 007 PIXEL OF oPanel  
	@ 037, nCol3 MSGET oGEmissao VAR cGEmissao	SIZE 050, 010 PIXEL OF oPanel  WHEN .F.
	
	@ 029, nCol5 SAY "Carga"					SIZE 025, 007 PIXEL OF oPanel  
	@ 037, nCol5 MSGET oGCarga VAR cGCarga		SIZE 035, 010 PIXEL OF oPanel  READONLY
	
 	@ 029, nCol4 SAY "Pedido"         			SIZE 060, 007 PIXEL OF oPanel  
	@ 037, nCol4 MSGET cPVProd  				SIZE 060, 010 PIXEL OF oPanel  READONLY

	@ 029, 343 SAY "Valor da N.F."				SIZE 060, 007 PIXEL OF oPanel  
	@ 037, 343 MSGET oGVlrNF VAR cGVlrNF		SIZE 060, 010 PIXEL OF oPanel  WHEN .F.
	
	@ 029, nCol6 SAY "Peso Bruto N.F."			SIZE 060, 007 PIXEL OF oPanel  
	@ 037, nCol6 MSGET cPresoBruto				SIZE 060, 010 PIXEL OF oPanel  WHEN .F.

    IF !EMPTY(cNFBotao)
  	   @ 029, nCol7 SAY cNFBotao  											SIZE 060, 007 PIXEL OF oPanel  
  	   @ 037, nCol7 MSGET (cFilAux3+" / "+alltrim(cCanhoto3)+" / "+cSerie3) SIZE 070, 010 PIXEL OF oPanel  READONLY
    ENDIF
//---------------------------------------------------------------------------------------------
    @ nLin5, nCol1    SAY   "Prev.Entrega Oper.Log." SIZE 081, 007 PIXEL OF oPanel  
    @ nLin6, nCol1    MSGET _dPrevEOL SIZE 060, 010  PIXEL OF oPanel  WHEN .F.    // SF2->F2_I_PENOL // Previsão de entrega no operador logístico 
    @ nLin5, nCol2    SAY   "Dt.Ocorr.Oper.Log."     SIZE 081, 007 PIXEL OF oPanel// Dt.Cheg.Oper.Log
    @ nLin6, nCol2    MSGET _dChegOL  SIZE 060, 010  PIXEL OF oPanel  WHEN .F.    // SF2->F2_I_DCHOL // Data de chegada no operador logístico 
    @ nLin5, nCol3    SAY   "Dt.Entr.Oper.Log"       SIZE 081, 007 PIXEL OF oPanel 
    @ nLin6, nCol3    MSGET _dEntrOL  SIZE 060, 010  PIXEL OF oPanel  WHEN .F.    // SF2->F2_I_DENOL // Data de entrega no operador logístico 

    @ nLin5, nCol5+20 SAY   "Prev.Entrega Cliente"   SIZE 081, 007 PIXEL OF oPanel 
    @ nLin6, nCol5+20 MSGET _dPrevECL SIZE 060, 010  PIXEL OF oPanel  WHEN .F.     // SF2->F2_I_PENCL // Previsão de entrega no cliente
    @ nLin5, nCol4+50 SAY   "Dt.Ocorr.Cliente"       SIZE 081, 007 PIXEL OF oPanel // Dt.Cheg.Cliente
    @ nLin6, nCol4+50 MSGET _dChegCL  SIZE 060, 010  PIXEL OF oPanel  WHEN .F.     // SF2->F2_I_DCHCL // Data de chegada no cliente
    @ nLin5, nCol6    SAY   "Dt.Entr.Cliente"        SIZE 081, 007 PIXEL OF oPanel 
    @ nLin6, nCol6    MSGET _dEntrCL  SIZE 060, 010  PIXEL OF oPanel  WHEN .F.     // SF2->F2_I_DENCL // Data de entrega no cliente

    nlin5 += 22 
	nlin6 += 22 
    _nDivisao += 30 
    nlin7 += 22
	nlin8 += 22
	_nLinPanel += 22

	//@ nLin5, nCol1 SAY "Dt.Recebimento Merc."	  SIZE 081, 007 PIXEL OF oPanel  
	@ nLin5, nCol1 SAY "Dt.Canhoto"         	  SIZE 081, 007 PIXEL OF oPanel  
	@ nLin6, nCol1 MSGET cGetDtCanh				  SIZE 060, 010 PIXEL OF oPanel  WHEN .F.
	
	@ nLin5, nCol2 SAY "Status"				      SIZE 040, 007 PIXEL OF oPanel  
	@ nLin6, nCol2 MSGET oGetStat VAR cGetStat    SIZE 074, 010 PIXEL OF oPanel  WHEN .F.

	IF LEN(_aTransOperLog) > 0
	   @ nLin5, nCol3 SAY _cOPTitu                SIZE 200, 007 PIXEL OF oPanel   
	   @ nLin6, nCol3 MSCOMBOBOX cTransport ITEMS _aTransOperLog SIZE 243, 013 OF oPanel PIXEL 
    ELSE
	   @ nLin5, nCol3 SAY "Transportadora"        SIZE 200, 007 PIXEL OF oPanel   
	   @ nLin6, nCol3 MSGET cTransport     		  SIZE 243, 010 PIXEL OF oPanel  WHEN .F.
	ENDIF

	@ nLin5, nCol6 SAY "Tipo da Carga"  		  SIZE 036, 007 PIXEL OF oPanel  
	@ nLin6, nCol6 MSGET cTpcarga				  SIZE 060, 010 PIXEL OF oPanel  WHEN .F.

 	@ nLin5, nCol7 SAY "Tipo Operacao"			  SIZE 060, 007 PIXEL OF oPanel  
	@ nLin6, nCol7 MSGET cTpOperacao  			  SIZE 050, 010 PIXEL OF oPanel  WHEN .F.

	@ nLin7, nCol1 SAY "Observação:"         	  SIZE 300, 007 PIXEL OF oPanel    
	@ nLin8, nCol1 MSGET cGetObser	              SIZE 398, 010 PIXEL OF oPanel  WHEN .F.

	IF LEN(_aAprovadores) > 0
	   @ nLin7, nCol6 SAY _cAPTitu                              SIZE 200, 007 PIXEL OF oPanel   
	   @ nLin8, nCol6 MSCOMBOBOX cAprovacao ITEMS _aAprovadores SIZE 180, 013 PIXEL OF oPanel  
    ELSE
	   @ nLin7, nCol6 SAY "Usuario Apr. Canhoto - Data - Hora:" SIZE 300, 007 PIXEL OF oPanel    
	   @ nLin8, nCol6 MSGET cAprovacao                          SIZE 175, 010 PIXEL OF oPanel  WHEN .F.
	ENDIF 

	//Carrega canhoto1 da página da Estec
	FWMSGRUN( ,{|_oProc| U_CARCANHO(_cFilial,alltrim(cGNumNF),_oProc,.F.) } , "Aguarde!", "Carregando imagem do canhoto Produto..."  )
	oTBitmap1 := TBitmap():New(_nDivisao,00,900,304,,"\temp\canhoto" + alltrim(cGNumNF) + "_" + AllTrim(_cFilial) + ".jpg",.T.,oTFolder1:aDialogs[1] ,,,.F.,.F.,,,.F.,,.T.,,.F.)
    oTBitmap1:lAutoSize := .T.//Não funciona quando for via WEB

	Aadd( _aBotoes, {"EMAIL",{|| U_ENVCAN(_cFilial,Alltrim(cGNumNF)  ) },"","NF Prod Enviar Email"   })
	Aadd( _aBotoes, {"SALVA",{|| U_SAVCAN(_cFilial,Alltrim(cGNumNF)  ) },"","NF Prod Salvar Imagem"  })
	Aadd( _aBotoes, {"VERNF",{|| U_VerNotaFiscal(_cFilial ,cGNumNF ,cGSerie )},"","Ver NF Produto"   })
	Aadd( _aBotoes, {'NOTE' ,{|| U_AOMS003(" ZF5->ZF5_FILIAL == '"+_cFilial+"' .AND. ZF5->ZF5_DOCOC ==  '"+cGNumNF+"' .AND. ZF5->ZF5_SEROC ==  '"+cGSerie+"' " )},"","Ocorrências de frete"})  

//***********************************************************\\ FOLDER 2 //**************************************************************************
    IF !EMPTY(cCanhoto2)
	   nlin5 -= 22 
	   nlin6 -= 22 
       nlin7 -= 22
	   nlin8 -= 22
	   _nLinPanel -= 22
	
		oPanel2	:= TPanel():New( 1 , 1 , '' , oTFolder1:aDialogs[2] ,, .T. , .T. ,,, _nColPanel , _nLinPanel , .T. , .T. )
	
		@ 002, nCol1 SAY "Filial / No. / Serie da NF"				         SIZE 090, 007 PIXEL OF oPanel2  
		@ 010, nCol1 MSGET (cFilAux2+" / "+alltrim(cCanhoto2)+" / "+cPGSerie) SIZE 060, 010 PIXEL OF oPanel2  READONLY
		
		@ 002, nCol2 SAY "Cliente"					SIZE 175, 007 PIXEL OF oPanel2  
		@ 010, nCol2 MSGET  cPGDescCli				SIZE 175, 010 PIXEL OF oPanel2  WHEN .F.
		
		@ 002, nCol4 SAY "Endereço do Cliente"		SIZE 300, 007 PIXEL OF oPanel2    
		@ 010, nCol4 MSGET cPEndCliente	            SIZE 300, 010 PIXEL OF oPanel2  WHEN .F.
	
		@ 029, nCol1 SAY "CNPJ/CPF"					SIZE 025, 007 PIXEL OF oPanel2  
		@ 037, nCol1 MSGET cPGCGC					SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.
		
		@ 029, nCol2 SAY "Rede"						SIZE 074, 007 PIXEL OF oPanel2  
		@ 037, nCol2 MSGET cPGRede					SIZE 074, 010 PIXEL OF oPanel2  WHEN .F.
		
		@ 029, nCol3 SAY "Emissão NF"				SIZE 025, 007 PIXEL OF oPanel2  
		@ 037, nCol3 MSGET cPGEmissao				SIZE 050, 010 PIXEL OF oPanel2  WHEN .F.
		
		@ 029, nCol5 SAY "Carga"					SIZE 025, 007 PIXEL OF oPanel2  
		@ 037, nCol5 MSGET cPGCarga					SIZE 035, 010 PIXEL OF oPanel2  READONLY
		
 	    @ 029, nCol4 SAY "Pedido"          			SIZE 060, 007 PIXEL OF oPanel2 
	    @ 037, nCol4 MSGET cPVPallet 				SIZE 060, 010 PIXEL OF oPanel2  READONLY

		@ 029, 343 SAY "Valor da N.F."				SIZE 060, 007 PIXEL OF oPanel2  
		@ 037, 343 MSGET cPGVlrNF					SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.
		
		@ 029, nCol6 SAY "Peso Bruto N.F."			SIZE 060, 007 PIXEL OF oPanel2  
		@ 037, nCol6 MSGET cPPresoBruto				SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.
	
	    @ 029, nCol7 SAY "Qtde Pallets"			    SIZE 040, 007 PIXEL OF oPanel2  
	    @ 037, nCol7 MSGET cQtdePallets   			SIZE 050, 010 PIXEL OF oPanel2  WHEN .F.
//---------------------------------------------------------------------------------------------
        @ nLin5, nCol1    SAY   "Prev.Entrega Oper.Log." SIZE 081, 007 PIXEL OF oPanel2  
        @ nLin6, nCol1    MSGET _dPPrevEOL SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.    // SF2->F2_I_PENOL // Previsão de entrega no operador logístico 
        @ nLin5, nCol2    SAY   "Dt.Ocorr.Oper.Log."     SIZE 081, 007 PIXEL OF oPanel2// Dt.Cheg.Oper.Log
        @ nLin6, nCol2    MSGET _dPChegOL  SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.    // SF2->F2_I_DCHOL // Data de chegada no operador logístico 
        @ nLin5, nCol3    SAY   "Dt.Entr.Oper.Log"       SIZE 081, 007 PIXEL OF oPanel2 
        @ nLin6, nCol3    MSGET _dPEntrOL  SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.    // SF2->F2_I_DENOL // Data de entrega no operador logístico 

        @ nLin5, nCol5+20 SAY   "Prev.Entrega Cliente"   SIZE 081, 007 PIXEL OF oPanel2 
        @ nLin6, nCol5+20 MSGET _dPPrevECL SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.    // SF2->F2_I_PENCL // Previsão de entrega no cliente
        @ nLin5, nCol4+50 SAY   "Dt.Ocorr.Cliente"       SIZE 081, 007 PIXEL OF oPanel2// Dt.Cheg.Cliente
        @ nLin6, nCol4+50 MSGET _dPChegCL  SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.    // SF2->F2_I_DCHCL // Data de chegada no cliente
        @ nLin5, nCol6    SAY   "Dt.Entr.Cliente"        SIZE 081, 007 PIXEL OF oPanel2 
        @ nLin6, nCol6    MSGET _dPEntrCL  SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.    // SF2->F2_I_DENCL // Data de entrega no cliente
        
		nlin5 += 22 
	    nlin6 += 22 
        //_nDivisao += 30 
        nlin7 += 22
	    nlin8 += 22
	    _nLinPanel += 22

//---------------------------------------------------------------------------------------------
		//@ nLin5, nCol1 SAY "Dt.Recebimento Merc."	SIZE 081, 007 PIXEL OF oPanel2  
		@ nLin5, nCol1 SAY "Entr.no Cliente (Dt.Canhoto)" SIZE 081, 007 PIXEL OF oPanel2  
		@ nLin6, nCol1 MSGET cPGetDtCanh			SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.
		
		@ nLin5, nCol2 SAY "Status"					SIZE 040, 007 PIXEL OF oPanel2  
		@ nLin6, nCol2 MSGET cPGetStat 			  	SIZE 074, 010 PIXEL OF oPanel2  WHEN .F.
		
		@ nLin5, nCol3 SAY "Transportadora"         SIZE 200, 007 PIXEL OF oPanel2   
		@ nLin6, nCol3 MSGET cPTransport     		SIZE 243, 010 PIXEL OF oPanel2  WHEN .F.
	
		@ nLin5, nCol6 SAY "Tipo da Carga"  			SIZE 036, 007 PIXEL OF oPanel2  
		@ nLin6, nCol6 MSGET cPTpcarga				SIZE 060, 010 PIXEL OF oPanel2  WHEN .F.
	
	 	@ nLin5, nCol7 SAY "Tipo Operacao"			SIZE 060, 007 PIXEL OF oPanel2  
		@ nLin6, nCol7 MSGET cPTpOperacao 			SIZE 050, 010 PIXEL OF oPanel2  WHEN .F.
	
		@ nLin7, nCol1 SAY "Observação"         	SIZE 300, 007 PIXEL OF oPanel2   
		@ nLin8, nCol1 MSGET cPGetObser	            SIZE 398, 010 PIXEL OF oPanel2  WHEN .F.

	    @ nLin7, nCol6 SAY "Usuario - Data - Hora:" SIZE 300, 007 PIXEL OF oPanel2    
	    @ nLin8, nCol6 MSGET cpAprovacao            SIZE 175, 010 PIXEL OF oPanel2  WHEN .F.
	
		//Carrega canhoto2 da página da Estec
		FWMSGRUN( ,{|_oProc| U_CARCANHO(cFilAux2,alltrim(cCanhoto2),_oProc,.F.) } , "Aguarde!", "Carregando imagem do canhoto Pallet..."  )
	    oTBitmap1 := TBitmap():New(_nDivisao,00,900,304,,"\temp\canhoto" + alltrim(cCanhoto2)  + "_" + AllTrim(cFilAux2) + ".jpg",.T.,oTFolder1:aDialogs[2] ,,,.F.,.F.,,,.F.,,.T.,,.F.)
	    oTBitmap1:lAutoSize := .T.//Não funciona quando for via WEB
	     	
		Aadd( _aBotoes, {"EMAIL",{|| U_ENVCAN(cFilAux2,Alltrim(cCanhoto2)) },"","NF Pallet Enviar Email" })
		Aadd( _aBotoes, {"SALVA",{|| U_SAVCAN(cFilAux2,Alltrim(cCanhoto2)) },"","NF Pallet Salvar Imagem"})
		Aadd( _aBotoes, {"VERNF",{|| U_VerNotaFiscal(cFilAux2,cCanhoto2,cPGSerie)},"","Ver NF Pallet"    })
	    
	ENDIF
	    
    IF _lBotao
	   Aadd(_aBotoes,{"VINCU",{|| U_VISCANHO(cFilAux3,cCanhoto3,.F.) },"",cNFBotao})
	ENDIF

ACTIVATE MSDIALOG oDlg2 ON INIT ( EnchoiceBar( oDlg2 , {|| oDlg2:End()  } , {||  oDlg2:End() } ,, _aBotoes) )

//Apaga os arquivos gerados para mostrar o canhoto
FERASE("\temp\canhoto" + alltrim(cGNumNF)  + "_" + AllTrim(_cFilial) + ".pdf")
FERASE("\temp\canhoto" + alltrim(cGNumNF)  + "_" + AllTrim(_cFilial) + ".jpg")
FERASE("\temp\canhoto" + alltrim(cCanhoto2)+ "_" + AllTrim(cFilAux2) + ".pdf")
FERASE("\temp\canhoto" + alltrim(cCanhoto2)+ "_" + AllTrim(cFilAux2) + ".jpg")

SC5->(DBGOTO(_nRecAtual))//Volta para o pedido posicionado anterior quando chamada no browse

Return

/*
===============================================================================================================================
Programa----------: VerNotaFiscal()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 29/01/2019
Descrição---------: Ver nota Fiscal
Parametros--------: _cFilial - Filial da nota , _cNota - numero da nota , _cSerie - serie da nota
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function VerNotaFiscal(_cFilial,_cNota,_cSerie)
Local aRotRec
Local _cSalvaFilant:=cFilant

IF TYPE("aRotina") = "A"
   aRotRec:=aClone(aRotina)
ENDIF

If !SF2->(Dbseek(_cFilial+_cNota+_cSerie))
	U_ITMSG("Nota não existe: "+_cFilial+" / "+_cNota+" / "+_cSerie ,"Atenção",,1)
	Return .F.
Endif

aRotina := {{"Ver Nota","Mc090Visual",0,2,0,NIL}}

cFilant:=_cFilial//Eu troco pq pode ta visualizando uma nota de uma filial diferente da atual por exemplo uma troca nota

Mc090Visual("SF2",SF2->(RecNo()),1)

IF TYPE("aRotRec") = "A"
   aRotina := aClone(aRotRec)
ENDIF

cFilant:=_cSalvaFilant

RETURN .T.
/*
===============================================================================================================================
Programa----------: CARCANHO
Autor-------------: Josue Danich Prestes
Data da Criacao---: 11/01/2018
Descrição---------: Carrega canhoto da pagina da Estec
Parametros--------: _cFilial - Filial da nota
					_cNota - numero da nota
					_oProc - objeto da barra de processamento
					_lMe - mostra mensagens
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CARCANHO(_cFilial As Character, _cNota As Character, _oProc As Object, _lMen As Logical) As Logical
Local _lNovo As Logical
Local _lRest As Logical
Local _cUrlE2doc As Character
Local _cResult As Character
Local _aHeader As Array
Local _lContinua As Logical
Local _cKeyBase As Character
Local _cUsuario As Character
Local _cSenha As Character
Local _cToken As Character
Local oJson As Object

Default _lMen := .T.

_lNovo     := SuperGetMv( "IT_CONE2",,.T.)
_lRest     := SuperGetMv( "IT_E2REST",,.T.)
_cUrlE2doc := SuperGetMv( "IT_E2URL",,"https://www.e2doc.com.br/e2doc_api")
_cResult   := ""
_aHeader   := {}
_lContinua := .F.
_cKeyBase  := SuperGetMv( "IT_E2KEY",,"itlc") 
_cUsuario  := SuperGetMv( "IT_E2USR",,"webservice")
_cSenha    := SuperGetMv( "IT_E2PSW",,"Hoje01%")
_cToken    := ""

oJson := Nil

If _lRest

   _cBodyJson := "{"
   _cBodyJson += '"keybase": "' + _cKeyBase + '",'
   _cBodyJson += '"Usuario": "' + _cUsuario + '",'
   _cBodyJson += '"Senha": "' + _cSenha + '",'
   _cBodyJson += '"Modulo": "consulta",'
   _cBodyJson += '"Param": "",'
   _cBodyJson += '"Versao": "20"'
   _cBodyJson += "}"

   _cResult := ""

   If fRestE2doc(_cUrlE2doc,"/Autentica/Usuario",_aHeader,_cBodyJson,@_cResult)

      FWJsonDeserialize(_cResult, @oJson)
      _cToken  := oJson:AccessToken
      
      _cBodyJson := "{"
      _cBodyJson += '"token": "' + _cToken + '",'
      _cBodyJson += '"param": "",'
      _cBodyJson += '"flags": "",'
      _cBodyJson += '"modelo": "Nota Fiscal",'
      _cBodyJson += '"indices": [ '
      _cBodyJson += '{"label": "Numero da nota", "operador": "IGUAL", "valor": "' + _cNota + '"},'
      _cBodyJson += '{"label": "Filial", "operador": "IGUAL", "valor": "' + _cFilial + '"}]'
      _cBodyJson += "}"

      _cResult := ""

      If fRestE2doc(_cUrlE2doc,"/Consulta/Consultar",_aHeader,_cBodyJson,@_cResult)

         FWJsonDeserialize(_cResult, @oJson)
         IF LEN(oJson:PASTAS) > 0 .AND. LEN(oJson:PASTAS[1]:DOCUMENTOS) > 0
            _cId := oJson:PASTAS[1]:DOCUMENTOS[1]:ID
	     ELSE
		    Return .F.
		 ENDIF

         _cBodyJson := "{"
         _cBodyJson += '"token": "' + _cToken + '",'
         _cBodyJson += '"id": ["' + _cId + '"],'
         _cBodyJson += '"texto": "",'
         _cBodyJson += '"param": "",'
         _cBodyJson += '"impressao": false ,'
         _cBodyJson += '"paginas": true'
         _cBodyJson += "}"

         _cResult := ""

         If fRestE2doc(_cUrlE2doc,"/Consulta/VerDoc",_aHeader,_cBodyJson,@_cResult)
            FWJsonDeserialize(_cResult, @oJson)
            _cUrl := Iif(AttIsMemberOf(oJson, "link"),oJson:link,"") //oJson:GetJsonText("link") 
         Else
            If _lMen
               U_ItMsg(_cResult,"Atenção",,1)
            EndIf
            Return .F.
         EndIf
      Else
         If _lMen
            U_ItMsg(_cResult,"Atenção",,1)
         EndIf
         Return .F.
      EndIf
   Else
      If _lMen
         U_ItMsg(_cResult,"Atenção",,1)
      EndIf
      Return .F.
   EndIf

   FreeObj(oJson)
Else
		
	//Baixando pdf da página da estec
	_oProc:cCaption := ("Baixando pdf do canhoto da página da Estec...")
	ProcessMessages()
	
	oWsdl := tWSDLManager():New() // Cria o objeto da WSDL.

	oWsdl:nTimeout := 30          // Timeout de 10 segundos   
	oWsdl:lSSLInsecure := .T. //Acessa com certificado anônimo                                                            
	
	If _lNovo
		_cUrl := "https://www.e2doc.com.br/e2doc_webservice/consulta.asmx?wsdl"
	Else
		_cUrl := "https://www.e2doc.com.br/e2doc_webservice/pesquisa.asmx?wsdl"
	EndIf

	oWsdl:ParseURL( _cUrl ) // Manda para dentro do Objeto qual é o link do WSDL de integração Webservice.  

	oWsdl:SetOperation( "AutenticarUsuario") // Define qual operação será realizada.
	
	_cXml := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:e2d="http://www.e2doc.com.br/">'
	_cXml += '<soap:Header/>'
	_cXml += '<soap:Body>'
	_cXml += '<e2d:AutenticarUsuario>'
	_cXml += '<e2d:usuario>'+_cUsuario+'</e2d:usuario>'
	_cXml += '<e2d:senha>'+_cSenha+'</e2d:senha>'       // '<e2d:senha>webservice</e2d:senha>'
	_cXml += '<e2d:chave>'+_cKeyBase+'</e2d:chave>'
	_cXml += '</e2d:AutenticarUsuario>'
	_cXml += '</soap:Body>'
	_cXml += '</soap:Envelope>' 
	
	// Envia para o servidor
    _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            

    If _cOk 
         _cResult := oWsdl:GetParsedResponse() // Pega o resultado de envio já no formato em string.
    Else
         _cResult := oWsdl:cError
         u_itmsg("Erro na conexão com a Estec","Atenção",,1)
        Return .F.
    EndIf   
	
	_nposi := AT("AutenticarUsuarioResult:", _cresult)             
		
	
	_cKey := substr(_cresult,_nposi+24,121)


	oWsdl:SetOperation( "Consultar") // Define qual operação será realizada.
	
	If _lNovo
		_cXml := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:e2d="http://www.e2doc.com.br/">'
		_cXml += '<soap:Header/>'
		_cXml += '<soap:Body>'
		_cXml += '<e2d:Consultar>'
		_cXml += '<e2d:key>' + _cKey + '</e2d:key>'
		_cXml += '<e2d:modelo>Nota Fiscal</e2d:modelo>'
		_cXml += '<e2d:campos>'
		_cXml += '<e2d:indices>'
		_cXml += '<e2d:PesquisaIndice>'
		_cXml += '<e2d:label>Filial</e2d:label>'
		_cXml += '<e2d:valor>' + _cFilial + '</e2d:valor>'
		_cXml += '<e2d:operacao>IGUAL</e2d:operacao>'
		_cXml += '</e2d:PesquisaIndice>'
		_cXml += '<e2d:PesquisaIndice>'
		_cXml += '<e2d:label>Numero da nota</e2d:label>'
		_cXml += '<e2d:valor>' + _cNota + '</e2d:valor>'
		_cXml += '<e2d:operacao>IGUAL</e2d:operacao>'
		_cXml += '</e2d:PesquisaIndice>'
		_cXml += '</e2d:indices>'
		_cXml += '</e2d:campos>'
		//_cXml += '<e2d:chave></e2d:chave>'
		//_cXml += '<e2d:flags></e2d:flags>'
		_cXml += '</e2d:Consultar>'
		_cXml += '</soap:Body>'
		_cXml += '</soap:Envelope>' 	
	Else
		_cXml := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:e2d="http://www.e2doc.com.br/">'
		_cXml += '<soap:Header/>'
		_cXml += '<soap:Body>'
		_cXml += '<e2d:Consultar>'
		_cXml += '<e2d:key>' + _cKey + '</e2d:key>'
		_cXml += '<e2d:modelo>Nota Fiscal</e2d:modelo>'
		_cXml += '<e2d:campos>&lt;indice0&gt;Filial&lt;/indice0&gt;&lt;valor0&gt;' + _cFilial + '&lt;/valor0'
		_cXml += '&gt;&lt;indice1&gt;Numero da nota&lt;/indice1&gt;&lt;valor1&gt;' + _cNota + '&lt;/valor1&gt;</e2d:campos>'
		_cXml += '</e2d:Consultar>'
		_cXml += '</soap:Body>'
		_cXml += '</soap:Envelope>' 
	EndIf
	// Envia para o servidor
    _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            

    If _cOk 
    	 _cerror := ""
    	 _cWarning := ""
         _cResult := oWsdl:GetSoapResponse() // Pega o resultado de envio sem parser.
        
    Else
         _cResult := oWsdl:cError
         IF _lMen
            u_itmsg("Erro na conexão com a Estec","Atenção",,1)
         ENDIF
         Return .F.
    EndIf   
	
	_nposi := AT("<id>", _cresult)             
	_nposf := AT("</id>", _cresult)	
	
	If _nposi == 0
	
        IF _lMen
	 	   u_itmsg("Cupom não localizado na Estec","Atenção",,1)
	    ELSE
           _oProc:cCaption := ("Canhoto não localizado na Estec")
	       ProcessMessages()
	       SLEEP(4000)
	    ENDIF
        Return .F.
	 	
	Endif
	
	_cdocid := substr(_cresult,_nposi+4,_nposf-_nposi-4)
		
	
	oWsdl:SetOperation( "VerDoc") // Define qual operação será realizada.
	
	_cXml := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:e2d="http://www.e2doc.com.br/">'
    _cXml += '<soap:Header/>'
    _cXml += '<soap:Body>'
    _cXml += '<e2d:VerDoc>'
    _cXml += '<e2d:key>' + _cKey + '</e2d:key>'
    _cXml += '<e2d:id>'+ _cdocid + '</e2d:id>'
    _cXml += '</e2d:VerDoc>'
    _cXml += '</soap:Body>'
    _cXml += '</soap:Envelope>' 
	
	// Envia para o servidor
    _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            

    If _cOk 
    	 _cerror := ""
    	 _cWarning := ""
         _cResult := oWsdl:GetSoapResponse() // Pega o resultado de envio sem parser.
        
    Else
         _cResult := oWsdl:cError
         If _lMen
         	u_itmsg("Erro na conexão com a Estec","Atenção",,1)
         Endif
         Return .F.
    EndIf   
	
	_nposi := AT('<lk xmlns="">', _cresult)             
	_nposf := AT("</lk>", _cresult)	
	
	If _nposi == 0
	
        IF _lMen
		   u_itmsg("Canhoto não localizado na Estec","Atenção",1)
	    ELSE
           _oProc:cCaption := ("Canhoto não localizado na Estec")
	       ProcessMessages()
	       SLEEP(4000)
	    ENDIF
        Return .F.
		
	Endif

	_cUrl := substr(_cresult,_nposi+13,_nposf-_nposi-13)

EndIf	
	
If !Empty(_cUrl)

	//url := "https://www.e2doc.com.br/comum/tmp/6VXDUA3O8QC2.pdf" 
	Html  := HttpGet( _cUrl )
	MemoWrite( "\temp\canhoto" + alltrim(_cNota) + "_" + AllTrim(_cFilial) + ".pdf", Html )
    
    //Convertendo pdf em jpeg
    _oProc:cCaption := ("Convertendo canhoto em jpg...")
	ProcessMessages()
	
	If IsSrvUnix()
		cNome := " -quality 100 -density 300 ."+GetSrvProfString("RootPath", "") +"/temp/canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial)+ ".pdf -resize 40% ."+GetSrvProfString("RootPath", "") +"/temp/canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial)+".jpg"
		
		WaitRunSrv("convert " + cNome,.T.,"/")

	Else
		cNome := " -quality 100 -density 300 "+GetSrvProfString("RootPath", "") +"\temp\canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial)+ ".pdf -resize 40% "+GetSrvProfString("RootPath", "") +"\temp\canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial)+".jpg"
		WaitRunSrv("D:\TOTVS\Estec\ImageMagick\magick.exe "+cNome,.T.,"\")
	EndIf

EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: fRestE2doc
Autor-------------: Igor Melgaço
Data da Criacao---: 14/11/2024
Descrição---------: Comunicação com a E2doc via Rest
Parametros--------: _cUrl,_cParms,_aHeader,_cBodyJson,_cResult
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function fRestE2doc(_cUrl As Character,_cParms As Character,_aHeader As Array,_cBodyJson As Character,_cResult As Character) As Logical
Local cError As Character
Local nStatus As Numeric
Local cResult As Character
Local lReturn As Logical
Local oRest As Object
Local oJson As Object

Default _aHeader := {}

   cError := ""
   nStatus := 0
   cResult := ""
   lReturn := .F.
   oRest := Nil
   oJson := Nil

   Aadd(_aHeader, "Content-Type: application/json")

   oRest := FWRest():New(_cUrl)
   oRest:SetPath(_cParms)
   oRest:SetPostParams(_cBodyJson)
   oRest:SetChkStatus(.F.)

   If oRest:Post(_aHeader)
      cError := ""
      nStatus := HTTPGetStatus(@cError)

      If nStatus >= 200 .And. nStatus <= 299
         If Empty(oRest:getResult())
            
            _cResult := "Falha de comunicação no retorno da requisição com sistema da ESTEC!" + CRLF + "Status " + Alltrim(Str(nStatus))

            lReturn := .F.
            
         Else
            _cResult := oRest:getResult()                

            oJson := JsonObject():new()

            cRegistro := oJson:fromJson(_cResult)

            If ValType(cRegistro) == "U" //"JsonObject populado com sucesso"
               lReturn := .T.
            Else
               _cResult := ' "Erro": "Falha ao popular JsonObject. Erro: ' + cRegistro +'" '
               lReturn := .F.
            EndIf
            
         EndIf
      Else

         _cResult := oRest:getResult() 

         oJson := JsonObject():new()

         cRegistro := oJson:fromJson(_cResult)

         If ValType(cRegistro) == "U"

            cRegistro := oJson:GetJsonText("erros") 

            If cRegistro <> "null"
               FWJsonDeserialize(cRegistro,@oErro)
               cMsg := oErro[1]:MENSAGEM
            Else
               If cError == "Unauthorized"
                   cMsg := "Falha de auorização do token."
               Else
                   cMsg := ""
               EndIf
            EndIf

            _cResult := "Falha no Registro do Título no sistema da Estec!" + CRLF + "Erro:" + cError  + CRLF + "Mensagem" + CRLF + cMsg // LimpaString(oErro[1]:MENSAGEM),"")
            
            lReturn := .F.            
         Else
            _cResult := ' "Erro": "Falha ao popular JsonObject. Erro: ' + cRegistro +'" '
         EndIf

         lReturn := .F.
      EndIf
   Else
      _cResult := oRest:getResult() 

      If ValType(_cResult) == "U"
        _cResult := ""
      EndIf

      _cResult := "Falha de comunicação com sistema da Estec!" + CRLF + oRest:getLastError() + CRLF + cResult

      lReturn := .F.
   EndIf

   FreeObj(oRest)
   FreeObj(oJson)
   
Return lReturn

/*
===============================================================================================================================
Programa----------: SAVCAN
Autor-------------: Josue Danich Prestes
Data da Criacao---: 11/01/2018
Descrição---------: Salva pdf de canhoto da pagina da Estec
Parametros--------: _cFilial - Filial da nota
					_cNota - numero da nota
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function SAVCAN( _cFilial, _cNota )

Local _cDir := cGetFile( "\" , "Selecione o Diretorio de Destino:" ,,,, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE)

If empty(_cDir)

	u_itmsg("Operação cancelada!","Atenção",,1)
	
Else

	If __CopyFile( "\temp\canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial) + ".pdf", _cDir + "canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial) + ".pdf" )
	
		U_ITMSG("PDF salvo com SUCESSO em " + _cDir + "canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial) + ".pdf","Atenção",,2)
		
	Else
	
		U_ITMSG("Operação de salvar o PDF: "+ _cDir + "canhoto" + alltrim(_cNota)+ "_" + AllTrim(_cFilial) + ".pdf FALHOU!","Atenção","Verifique o nome do arquivo e do diretorio e tente novamente.",1)
		
	Endif
	
Endif

Return

/*
===============================================================================================================================
Programa----------: ENVCAN
Autor-------------: Josue Danich Prestes
Data da Criacao---: 11/01/2018
Descrição---------: Envia email com pdf de canhoto da pagina da Estec
Parametros--------: _cFilial - Filial da nota
					_cNota - numero da nota
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ENVCAN( _cFilial, _cNota )

Local oAnexo
Local oAssunto
Local oButCan
Local oButEnv
Local oCc
Local oGetAnx
Local oGetAssun
Local oGetCc
Local oGetPara
Local oMens
Local oPara
Local _csetor := ""

Local _aConfig	:= U_ITCFGEML('')
Local _cEmlLog	:= ""
Local cHtml		:= ""
Local nOpcA		:= 2

Local cGetAnx	:= ""
Local cGetAssun	:= "Canhoto da nota fiscal " + _cFilial + "/" + _cNota
Local cGetCc	:= Space(100)
Local cGetMens	:= ""
Local cGetPara	:= Space(150)

Private oDlgMail


cGetAnx := "\temp\canhoto" + alltrim(_cNota) + "_" + AllTrim(_cFilial) + ".pdf"

If (Len(PswRet()) # 0) // Quando nao for rotina automatica do configurador

	_csetor	:= AllTrim(PswRet()[1][12])		// Pega departamento do usuario
   
Endif


If empty(alltrim(_csetor))
 
 	_csetor := "Comercial"
 	
Endif

//Localiza nota fiscal
SF2->(Dbsetorder(1))
SF2->(Dbseek(_cFilial+_cNota))

//Localiza cliente
SA1->(Dbsetorder(1))
SA1->(Dbseek(xfilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

cGetPara := alltrim(SA1->A1_EMAIL) + SPACE(80)
cGetAssun	:= "Canhoto da nota fiscal " + _cFilial + "/" + _cNota + " - " + SA1->A1_NREDUZ

cHtml := 'À '+ SA1->A1_NREDUZ +','
cHtml += '<br><br>'
cHtml += '&nbsp;&nbsp;&nbsp;Segue anexo canhoto de nota fiscal ' + _cNota + ' entregue por nossa filial  '+ _cFilial +' conforme negociado.<br>'
cHtml += '&nbsp;&nbsp;&nbsp;Favor confirmar o recebimento, retornando com o seu CIENTE!'
cHtml += '<br><br>'

cHtml += '&nbsp;&nbsp;&nbsp;A disposição!'
cHtml += '<br><br>'


cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml += '<tr>'
cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=         '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<b><span style="font-size:18.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">'+ Capital( AllTrim( UsrFullName( RetCodUsr() ) ) ) +'</span></b>'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=     '</td>'
cHtml +=     '<td style="background:#A2CFF0;padding:.75pt .75pt .75pt .75pt">&nbsp;</td>'
cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">
cHtml +=         '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml +=              '<tr>'
cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=                      '<p class=MsoNormal><b><span style="font-size:13.5pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#6FB4E3;mso-fareast-language:PT-BR">' + _cSetor + '</span></b>'
cHtml +=                      '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></b>
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"><br></span>
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=                  '</td>'
cHtml +=              '</tr>'
cHtml +=              '<tr>'
cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">
cHtml +=                      '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Tel: ' + Posicione("SY1",3,xFilial("SY1") + RetCodUsr(),"Y1_TEL") + '</span>'
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=                  '</td>'
cHtml +=              '</tr>'
cHtml +=         '</table>'
cHtml +=     '</td>'
cHtml += '</tr>'
cHtml += '</table>'
cHtml += '<table class=MsoNormalTable border=0 cellpadding=0 width=437 style="width:327.75pt">'
cHtml +=     '<tr>'
cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR">'
cHtml +=                 '<img width=400 height=51 src="http://www.italac.com.br/assinatura-italac/images/marcas-goiasminas-industria-de-laticinios-ltda.jpg">'
cHtml +=             '</span>
cHtml +=             '</p>'
cHtml +=         '</td>'
cHtml +=     '</tr>'
cHtml += '</table>'
cHtml += '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';display:none;mso-fareast-language:PT-BR">&nbsp;</span></p>'
cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml +=     '<tr>'
cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Política de Privacidade </span></b>'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=             '<p class=MsoNormal style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto;text-align:justify">'
cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">
cHtml +=                 'Esta mensagem é destinada exclusivamente para fins profissionais, para a(s) pessoa(s) a quem for dirigida, podendo conter informação confidencial e legalmente privilegiada. '
cHtml +=                 'Ao recebê-la, se você não for destinatário desta mensagem, fica automaticamente notificado de abster-se a divulgar, copiar, distribuir, examinar ou, de qualquer forma, utilizar '
cHtml +=                 'sua informação, por configurar ato ilegal. Caso você tenha recebido esta mensagem indevidamente, solicitamos que nos retorne este e-mail, promovendo, concomitantemente sua '
cHtml +=                 'eliminação de sua base de dados, registros ou qualquer outro sistema de controle. Fica desprovida de eficácia e validade a mensagem que contiver vínculos obrigacionais, expedida '
cHtml +=                 'por quem não detenha poderes de representação, bem como não esteja legalmente habilitado para utilizar o referido endereço eletrônico, configurando falta grave conforme nossa '
cHtml +=                 'política de privacidade corporativa. As informações nela contidas são de propriedade da Italac, podendo ser divulgadas apenas a quem de direito e devidamente reconhecido pela empresa.'
cHtml +=             '</span>'
cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>'
cHtml +=         '</td>'
cHtml +=     '</tr>
cHtml += '</table>'

DEFINE MSDIALOG oDlgMail TITLE "E-Mail" FROM 000, 000  TO 415, 584 COLORS 0, 16777215 PIXEL

	//======
	// Para:
	//======
	@ 005, 006 SAY oPara PROMPT "Para:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 005, 030 MSGET oGetPara VAR cGetPara SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//===========
	// Com cópia:
	//===========
	@ 021, 006 SAY oCc PROMPT "Cc:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 021, 030 MSGET oGetCc VAR cGetCc SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//=========
	// Assunto:
	//=========
	@ 037, 006 SAY oAssunto PROMPT "Assunto:" SIZE 022, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 037, 030 MSGET oGetAssun VAR cGetAssun SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//======
	// Anexo
	//======
	@ 053, 006 SAY oAnexo PROMPT "Anexo:" SIZE 019, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 053, 030 MSGET oGetAnx VAR cGetAnx SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 READONLY PIXEL

	//==========
	// Mensagem:
	//==========
	@ 069, 006 SAY oMens PROMPT "Mensagem:" SIZE 030, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	_oScrAux	:= TSimpleEditor():New( 080 , 006 , oDlgMail , 285 , 105 ,,,,, .T. )
	
	_oScrAux:Load( cHtml )
	
	@ 189, 201 BUTTON oButEnv PROMPT "&Enviar"		SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 1 , cHtml := _oScrAux:RetText() , oDlgMail:End() ) PIXEL
	@ 189, 245 BUTTON oButCan PROMPT "&Cancelar"	SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 2 , oDlgMail:End() ) PIXEL

ACTIVATE MSDIALOG oDlgMail CENTERED

If nOpcA == 1
	cGetMens := u_FormatTxt(cGetMens)
	//====================================
	// Chama a função para envio do e-mail
	//====================================
	U_ITENVMAIL( Lower(AllTrim(UsrRetMail(RetCodUsr()))), cGetPara, cGetCc, Lower(AllTrim(UsrRetMail(RetCodUsr()))), cGetAssun, cHtml, cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

	If !Empty( _cEmlLog )

		u_itmsg( _cEmlLog , 'Término do processamento!' , ,3 )
	EndIf
Else
	u_itmsg( 'Envio de e-mail cancelado pelo usuário.' , 'Atenção!' , ,1 )
EndIf


Return

/*
===============================================================================================================================
Programa----------: FormatTxt
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 12/02/2016
Descrição---------: Função criada para fazer a quebra de linha na mensagem digitada pelo usuário
Parametros--------: ExpC1	- Texto da mensagem
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function FormatTxt(cGetMens)
Local aTexto	:= StrTokArr( cGetMens, chr(10)+chr(13) )
Local cRet		:= ""
Local nI		:= 0

For nI := 1 To Len(aTexto)
	cRet += aTexto[nI] + "<br>"
Next

Return(cRet)

/*
===============================================================================================================================
Programa----------: ITKEY
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/02/2018
Descrição---------: Deixa o conteúdo caracter passado como parâmetro no tamanho campo de dicionario de dados SX3 passado como 
                    segundo parâmetro, preenchendo a direita com espaços em branco, até completar o tamanho do campo do 
                    segundo parâmetro.
                    O objetivo desta função é montar a chave de pesquisa em índice.
Parametros--------: _cDado  = Contéudo a ter o tamanho transformado no tamanho do campo passado no segundo parâmetro, 
                              preenchendo a direita com espaços.
                    _cCampo = Nome do campo do dicionário de dados SX3 que será utilizado como base para determinar o tamanho
                              na qual o dado será tranformado. 
                    _lTela  = .T. = Exibe mensagens na tela / .F. = Exibe mensagens no console.
Retorno-----------: _cRet = Dado passado como parâmetro que teve o tamanho alterado para o tamanho do campo de dicionario de 
                            dados SX3 passado no segundo parâmetro da função, preenchedo a direita com espaços em branco.
===============================================================================================================================
*/
User Function ITKEY(_cDado,_cCampo,_lTela)
Local _cRet := ""
Local _nTamanho, _nI, _cCmpSX3
Local _nRegAtu := SX3->(Recno())
Local _nOrd := SX3->(IndexOrd())

Default _lTela := .F.

Begin Sequence
   If Empty(_cCampo) 
      If _lTela
         U_ITMSG("Função ITKEY(): Segundo parâmetro não informado.","Atenção", ,1)    
      //Else
      //  //U_ITCONOUT("Função ITKEY(): Segundo parâmetro não informado.")
      EndIf
      Break
   EndIf
   
   _cCmpSX3  := AllTrim(_cCampo)
   _nTamanho := Len(_cCmpSX3) 
   _nI       := 10 - _nTamanho 
   _cCmpSX3  := _cCmpSX3 + Space(_nI)
   
   SX3->(DbSetOrder(2))
   If ! SX3->(DbSeek(AllTrim(_cCmpSX3)))
      If _lTela
         U_ITMSG("Função ITKEY(): Segundo parâmetro não encontrado no dicionário de dados SX3.","Atenção", ,1)    
      //Else
      //  //U_ITCONOUT("Função ITKEY(): Segundo parâmetro não encontrado no dicionário de dados SX3.")
      EndIf
      Break
   EndIf
   
   _nTamanho := TAMSX3(_cCmpSX3)[1]
   _cRet := Padr(_cDado, _nTamanho, " ")

End Sequence

SX3->(DbSetOrder(_nOrd))
SX3->(DbGoTo(_nRegAtu))

Return _cRet

/*
===============================================================================================================================
Programa----------: ITTXTARRAY
Autor-------------: Julio de Paula Paz
Data da Criacao---: 15/12/2017
Descrição---------: Convertge o Texto recebido como parâmetro em Array
Parametros--------: _cTexto         = Texto a ser convertido
                    _cSeparador     = Caracter utilizado como separador de colunas 
                    _nNrPosicArray  = Numero máximo de posições do Array
                    _nNrMinimoArray = Numero minimo de posições do Array
Retorno-----------: _aRet = Retorna o campo _cTexto no formato de Array.
===============================================================================================================================
*/
User function ITTXTARRAY(_cTexto,_cSeparador,_nNrPosicArray,_nNrMinimoArray)
Local _aRet := {}
Local _nPosInc, _nInic, _cColuna
Local _nTamTexto := Len(_cTexto)
Local _nTamColuna , I
Local _lWhile := .T.

Default _nNrPosicArray := 6

Begin Sequence
   
   If Len(_cTexto) == 0
      Break   
   EndIf
   
   // Exemplo:
   // Numero de colunas a serem lidas do arquivo texto.
   //        1              2            3             4                 5               6
   //"CNPJ_FORNECEDOR;CODIGO_CLIENTE;NOME_CLIENTE;NUMERO_DOCUMENTO;VALOR_DOCUMENTO;NOVO_VENCIMENTO"
   
    _nPosInc := 1 
	Do While _lWhile // .T.
	   _nInic := At(_cSeparador, _cTexto , _nPosInc) 
        
       If _nInic > 0
          _nPosInc := _nInic + 1
       Else
          Exit  
       EndIf
       
       If Len(_aRet) == 0 
          _cColuna := SubStr(_cTexto,1,_nInic-1)
          Aadd(_aRet,_cColuna)
       EndIf  
       
	   _nFin  := 0
	
	   _nFin := At(_cSeparador,_cTexto,_nInic+1)
	   
	   If _nFin == 0
	      _lWhile := .F.
	   EndIf
	   
	   If _nFin > 0
	      _nTamColuna := _nFin - (_nInic + 1)
	      _cColuna := SubStr(_cTexto,_nInic+1,_nTamColuna)
	   Else
	      _nTamColuna := _nTamTexto - _nInic // (_nInic + 1)
	      _cColuna := SubStr(_cTexto,_nInic+1,_nTamColuna)
	   EndIf
	   
	   Aadd(_aRet,_cColuna)
	   
	   If _nNrPosicArray > 0 .AND. Len(_aRet) = _nNrPosicArray  // Numero máximo de colunas da planilha gravada em CSV.
	      _lWhile := .F.  //Exit
	   EndIf
	   
    EndDo 

	Default _nNrMinimoArray := Len(_aRet)

	IF _nNrMinimoArray > Len(_aRet) 
		FOR I := (Len(_aRet)+1) TO _nNrMinimoArray
			Aadd(_aRet,"")
		NEXT
	ENDIF

End Sequence

Return _aRet

/*
===============================================================================================================================
Programa----------: lstProd
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
Descrição---------: Monta tela para consulta dos produtos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function lstProd()

Local i 		  := 0
Local cAlias      := GetNextAlias()

Private nTam      := 0
Private nMaxSelect:= 0
Private aCat      := {}
Private MvRet     := Alltrim( ReadVar() )
Private MvPar     := ""
Private cTitulo   := ""
Private MvParDef  := ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//================================================================================
// Tratamento para carregar variaveis da lista de opcoes
//================================================================================
nTam		:= 11
nMaxSelect	:= 8
cTitulo		:= "Selecione os Produtos"

cGrpCus := " SELECT "
cGrpCus += " B1_COD, B1_I_DESCD"
cGrpCus += " FROM "+ RetSqlName("SB1") +" SB1 "
cGrpCus += " WHERE D_E_L_E_T_ = ' ' "
cGrpCus += " AND B1_TIPO  IN "+ FormatIn(  U_ITGETMV("ITPRCON","PA"),";"  ) 	
cGrpCus += " ORDER BY B1_COD"

MPSysOpenQuery( cGrpCus , cAlias)

While (cAlias)->(!Eof())

	MvParDef += AllTrim( (cAlias)->B1_COD )
	aAdd( aCat , AllTrim( (cAlias)->B1_I_DESCD ) )
	
    (cAlias)->( DBSkip() )
EndDo

(cAlias)->( DBCloseArea() )

//================================================================================
// Trativa abaixo para no caso de uma alteracao do campo trazer todos os dados que
// foram selecionados anteriormente.
//================================================================================
If Len(AllTrim(&MvRet)) == 0                              

	MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len( aCat ) )
	&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len( aCat ) )

Else

	MvPar	:= AllTrim( StrTran( &MvRet , ";" , "/" ) )

EndIf

//================================================================================
// Somente altera o conteudo caso o usuario clique no botao ok
//================================================================================
If F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

	&MvRet := ""
	
	//================================================================================
	// Separa os registros com ';'
	//================================================================================
	For i := 1 To Len(MvPar) Step nTam
	
		If !( SubStr(MvPar,i,1) $ " |*" )
			&MvRet += SubStr(MvPar,i,nTam) + ";"
		EndIf
		
	Next i
	
	//================================================================================
	// Trata para tirar o ultimo caracter
	//================================================================================
	&MvRet := SubStr( &MvRet , 1 , Len(&MvRet) - 1 )

EndIf

Return( .T. )

/*
===============================================================================================================================
Programa----------: ITX1Help
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/04/2018
Descrição---------: Grava help das perguntas
Parametros--------: cKey	 	 	Caracter	  	Nome do help a ser cadastrado	 	 	 	 	 		 	 	 	 
 					aHelpPor	 	Vetor	 	 	Array com o texto do help em Português	 	 		 	 	 	 	 	 	 
 					aHelpEng	 	Vetor	 	 	Array com o texto do help em Inglês	 	 		 	 	 	 	 	 	 
 					aHelpSpa	 	Vetor	 	 	Array com o texto do help em Espanhol	 	 		 	 	 	 	 	 	 
 					lUpdate	 	 	Lógico	 	 	Caso seja .T. e já existir um help com o mesmo nome,
 					 									atualiza o registro. Se for .F. não atualiza	 	 	.T.	 	 	 	 	 	 	 
 					cStatus	 	 	Caracter	  	Parâmetro reservado
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdate,cStatus)
LOCAL nI
LOCAL cNewMemo:=""
LOCAL _cAlias:="XB4"
IF SELECT("XB4") = 0
   RETURN .F.
ENDIF
For nI:= 1 to Len(aHelpPor)
   cNewMemo += Alltrim((aHelpPor[nI]))+" "
Next

IF (_cAlias)->(DBSEEK("P"+cKey))//Independente de vc por "P" na frente da chave ou não ele sempre poe "P" na frente quando inclui no configurador
   (_cAlias)->(RECLOCK("XB4",.F.))
   (_cAlias)->XB4_HELP   := cNewMemo
ELSE
   (_cAlias)->(RECLOCK("XB4",.T.))
   (_cAlias)->XB4_CODIGO := "P"+cKey
   (_cAlias)->XB4_TIPO   := "P"
   (_cAlias)->XB4_HLP40  := "S"
   (_cAlias)->XB4_HELP   := cNewMemo
   (_cAlias)->XB4_IDIOMA := "pt-br"
ENDIF
(_cAlias)->(MsUnlock())

RETURN .T.

/*
===============================================================================================================================
Programa----------: itspdupd
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/04/2018
Descrição---------: Chamada por static funcion da spf_update para evitar bloqueio do framework Totvs
Parametros--------: Replicados da função SPF_UPDATE
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function itspdupd(cFile, nRet, cKey, cStatus, cNewMemo )

	SPF_UPDATE( cFile, nRet, cKey, cStatus,, cNewMemo )

Return

/*
===============================================================================================================================
Programa----------: ITDERRUBA
Autor-------------: Josué Danich Prestes
Data da Criacao---: 15/05/2018
Descrição---------: Serviço web para derrubar conexões por usuário
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function itderruba(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local chtml        := ''
Local _lpassw      := .F.
Local _cuser       := UPPER(alltrim(__aPostParms[1,2]))
Local _lbloq       := .F. , _ni

PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'  TABLES "ZGU"  MODULO 'OMS'


PswOrder(2)
If PswSeek(_cuser,.T.)

	ZGU->(Dbsetorder(1))
	If !(ZGU->(Dbseek(xfilial("ZGU")+_cuser)) .and. ZGU->ZGU_TENTS > 10) //Proteção contra brute forces

		_lpassw := PswName(alltrim(__aPostParms[2,2]))
	
		If  ZGU->(Dbseek(xfilial("ZGU")+_cuser))
		
		  Reclock("ZGU", .F.)
		  
		Else
		
		  Reclock("ZGU", .T.)
		  ZGU->ZGU_USER := UPPER(alltrim(__aPostParms[1,2]))	
		
		Endif
		
		If _lpassw
		
			ZGU->ZGU_TENTS := 0
			
		Else
		
			ZGU->ZGU_TENTS++
		
		Endif
	
		ZGU->(Msunlock())
	
	Elseif ZGU->(Dbseek(xfilial("ZGU")+_cuser)) .and. ZGU->ZGU_TENTS > 10
	
		_lbloq := .T.
	
	Endif
	
Endif

//Verifica Senha da matricula
If _lpassw

	//Conecta no servidor MASTER da Producao
	oRpcSrv := TRpc():New( 'PRODUCAO' )
	If ( oRpcSrv:Connect( u_itgetmv('ITIPSRV','10.7.0.55'), u_itgetmv('ITPRTSRV',1000)  ) )
	
		_aprocs := oRpcSrv:CallProc('GetUserInfoArray')
		
		//Encerra conexões do Protheus para o usuário
		For _ni := 1 to len(_aprocs)
		
			If alltrim(substr(_aprocs[_ni][11],20,15)) == alltrim(_cuser) 
		
				oRpcSrv:CallProc('KillUser',_aprocs[_ni][1] , _aprocs[_ni][2] , _aprocs[_ni][3] , _aprocs[_ni][4] )	
				
			Endif
			
		Next
		
		oRpcSrv:Disconnect()
	
	Endif


	chtml := '<body onLoad="window.alert(' + "'Conexões derrubadas com sucesso para o usuario " +  _cuser + "!')" + '; history.go(-1)"' + ">Conexões derrubadas com sucesso para o usuario " +  _cuser + "!</body>"
	
Elseif _lbloq

	chtml := '<body onLoad="window.alert(' + "'Usuário bloqueado por 10 erros de senha " +  _cuser + "!')" + '; history.go(-1)"' + ">Usuário bloqueado por 10 erros de senha " +  _cuser + "!</body>"

Else

	chtml := '<body onLoad="window.alert(' + "'Senha inválida para o usuario " +  _cuser + "!')" + '; history.go(-1)"' + ">Senha inválida para o usuario " +  _cuser + "!</body>"

Endif

Return(chtml)

/*
===============================================================================================================================
Programa--------: ITFormula
Autor-----------: ALEX WALLAUER
Data da Criacao-: 13/08/2018
Descrição-------: Função genérica que permite Chamar outra função
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================*/
User Function ITFormula()
Local _aParRet :={}
Local _aParAux :={} , nI , lRet:=.T.
MV_PAR01 := SPACE(100)
MV_SAL01 := SPACE(100)
 
AADD( _aParAux , { 1 , "Digite o nome da Função:"		, MV_PAR01, "@!"		, ""	, ""		, "" , 100 , .F. } )

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.
MV_PAR01:=MV_SAL01
                //aParametros, cTitle              , @aRet    ,[bOk]                     , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
IF !ParamBox( _aParAux , "Digite o nome da Função:" , @_aParRet, {|| !EMPTY(MV_PAR01) }   , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
//IF !ParamBox( _aParAux , "Digite o nome da Função:" , @_aParRet, {|| !EMPTY(MV_PAR01) }  )
	Return .T.
EndIf
MV_SAL01:=MV_PAR01
MV_PAR01:=ALLTRIM(MV_PAR01)
MV_PAR01:=STRTRAN(MV_PAR01,"()","")
IF !"(" $ MV_PAR01 .OR. !")" $ MV_PAR01
   IF (nAt:=AT("(",MV_PAR01)) <> 0
      MV_PAR01:=SUBSTR(MV_PAR01,1,(nAt-1))
   ENDIF   
   MV_PAR01:=STRTRAN(MV_PAR01,")","")
   IF !FindFunction(MV_PAR01)
      MSGSTOP("Funcao não compilada "+MV_PAR01)
      LOOP
   ENDIF
   MV_PAR01:=MV_PAR01+"()"
ELSE
   IF !FindFunction(MV_PAR01)
      MSGSTOP("Funcao não compilada "+MV_PAR01)
      LOOP
   ENDIF
ENDIF

//bError := ErrorBlock({|oError|  U_ITErro(oError:ErrorStack) }) // Comentado por solicitação do analista Alexandro F.
BEGIN SEQUENCE
  &(MV_PAR01)
RECOVER
  lRet:=.F.
END SEQUENCE
//ErrorBlock(bError) // Comentado por solicitação do analista Alexandro F.
ENDDO

RETURN  lRet

*=========================================*
User Function ITErro(cErro)
*=========================================*

AVISO("Erro e Pilha de chamadas",cErro,{"Fechar"},3) 

BREAK//Sai no primeiro erro da função executada

RETURN .T.

/*
===============================================================================================================================
Programa--------: ITMemtoR
Autor-----------: Josué Danich
Data da Criacao-: 17/10/2018
Descrição-------: Gravação de campos da memória para o registro do banco de dados
Parametros------: _cAlias - Alias da tabela em uso para gravação
Retorno---------: Nenhum
===============================================================================================================================*/
User Function ITMemtoR(_cAlias)

Local _ni := 0
Local _nTotCampos := (_cAlias)->(Fcount())
Local _aoldh := {}
Local _aoldc := {}

//Guarda acols e aheader se existerem
If type("aheader") != "U"
	_aoldh := aheader
Endif
If type("acols") != "U"
	_aoldc := acols
Endif

aHeader:={}
acols:={}

//Carrega aheader para identificar campos usados
FillGetDados(1,_calias,1,,,{||.T.},,,,,,.T.)

Reclock(_cAlias,.F.)

For _nI := 1 To _nTotCampos
 
    _cCampo := (_calias)->(FieldName(_nI))
    
    //Só atualiza campos que foram carregados no aheader
    If ascan(aheader,{|posi|, alltrim(posi[2]) == alltrim(_cCampo)}) > 0
    	_cVarCampo := M->&_cCampo
    Else
    	loop
    Endif
       
    If (_calias)->(DBFieldInfo(2,_ni)) == "D"
    
    	_cVarCampo := dtos(_cVarCampo)
    	
    Endif

    If "FILIAL" $ _cCampo
     
       (_calias)->(FieldPut(_nI, FWxFilial(_calias)))
     
    Else
     
       (_calias)->(FieldPut(_nI, _cVarCampo))
     
    EndIf
      
Next
	
(_calias)->(Msunlock())

//Recupera valores do aheader e acols
aheader := _aoldh
acols := _aoldc

Return

/*
===============================================================================================================================
Programa--------: ITVLDTEXTO
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/04/2019
Descrição-------: Validar o conteúdo dos dados de tipo texto passados como parâmetros, que poderão conter apenas os dígitos
                  contidos no parâmetro Italac IT_DIGTEXTO
Parametros------: _cTexto = Texto a ser validado.
                  _lMVC   = .T. = Indica que a rotina está utilizando MVC
                          = .F. = Indica que a rotina não está utilizando MVC.
Retorno---------: .T. = Texto de acordo com as definições do parâmetro.
                  .F. = Existem digitos ou caracteres especiais fora do contexto definido no parâmetro.
===============================================================================================================================
*/
User Function ITVLDTEXTO(_cTexto , _lMVC)
Local _lRet := .T.
Local _cTextoValido := U_ITGETMV( "IT_DIGTEXTO", "0123456789 ABCDEFGHIJKLMNOPQRSTUVXWYZ abcdefghijklmnopqrstuvxwyz")
Local _cLetra, _nI, _nTamTexto
Local _cTextoErro

Default _lMVC := .F.

Begin Sequence
   _nTamTexto  := Len(_cTexto)
   _cTextoErro := ""
   
   For _nI := 1 To _nTamTexto
       _cLetra := SubStr(_cTexto,_nI,1)

       If ! (_cLetra $ _cTextoValido)
          _cTextoErro += _cLetra
       EndIf
   Next
   
   If Len(_cTextoErro) > 0
      If _lMVC
         Help( ,, 'Atenção',, "Neste campo só é permitido a digitação dos Caracteres: " + _cTextoValido , 1, 0  ,,,,,,{"Retire os caracteres: "+_cTextoErro } )   
      Else
         U_ITMSG("Neste campo só é permitido a digitação dos Caracteres: " + _cTextoValido ,"Atenção","Retire os caracteres: "+_cTextoErro ,1) 
      EndIf
      _lRet := .F.
   EndIf
   
End Sequence

Return _lRet

/*
===============================================================================================================================
Programa--------: LstSb1
Autor-----------: Julio de Paula Paz
Data da Criacao-: 
Descrição-------: Função genérica de consulta específica Cadastro de produtos de multiplas seleções.
Parametros------: _cCampo = Campo que chamou a consulta específica.
Retorno---------: _lRet - Compatibilidade com o F3
===============================================================================================================================
*/
User Function LstSb1(_cCampo)  
Local _cAliasx, _cQRY
//Local _cTipoNF, aHeaderBk 
Local _nPosCampo, _nTamCampo , i

Private nTam       := 0
Private nMaxSelect := 0
Private aDescr     := {}
Private MvRet      := Alltrim(ReadVar())
Private MvPar      := ""
Private cTitulo    := ""
Private MvParDef   := ""

Begin Sequence
   oWnd := GetWndDefault()
   
   If AllTrim(_cCampo) == "B1_I_PRDSM" 
      //aHeaderBk := AClone(aHeader)
      //============================================================================
      // Montagem do aheader                                                        
      //=============================================================================
	  //                          1                    2               3              4               5                6             7        8              9                 10 
      // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
      aHeader := {}
	  FillGetDados(1,"SB1",1,,,{||.T.},,,,,,.T.)
      _nPosCampo := AsCan(aHeader,{|x| x[2] = "B1_I_PRDSM"})
      _nTamCampo := aHeader[_nPosCampo, 4]

      //Tratamento para carregar variaveis da lista de opcoes
      nTam          := 11 
      nMaxSelect    := 16
      cTitulo       := "Lista de Produtos Acabados"
      //M->B1_I_PRDSM := ""
            
      MvRet       := "M->B1_I_PRDSM"

      _cAliasx    := GetNextAlias()
		
	  _cQRY := " SELECT B1_COD,B1_DESC "
      _cQRY += " FROM  "+ RetSqlName('SB1') +' B1 '
      _cQRY += " WHERE	B1.D_E_L_E_T_ = ' ' AND B1_TIPO = 'PA' AND B1_MSBLQL = '2' "
      _cQRY += " ORDER BY B1.B1_COD "

	  MPSysOpenQuery( _cQRY , _cAliasX )
	  (_cAliasX)->( DBGoTop() )
		
	  While (_cAliasX)->(!Eof()) 
	     MvParDef += AllTrim( (_cAliasX)->B1_COD )
		 aAdd( aDescr , AllTrim( (_cAliasX)->B1_DESC ) )
			
		 (_cAliasX)->( DBSkip() )
	  EndDo
		
	  (_cAliasX)->(DbClosearea())
   
  
   EndIf
   
   //====================================================================
   //Trativa abaixo para no caso de uma alteracao do campo trazer todos
   //os dados que foram selecionados anteriormente.                    
   //====================================================================
   If Len(AllTrim(&(MvRet))) == 0                              

	  MvPar:= PadR(AllTrim(StrTran(&MvRet,";","")),Len(aDescr))
	  &(MvRet):= PadR(AllTrim(StrTran(&(MvRet),";","")),Len(aDescr))
	
   Else
		
      MvPar:= AllTrim(StrTran(&(MvRet),";","/"))

   EndIf

   //=============================================================
   //Somente altera o conteudo caso o usuario clique no botao ok
   //=============================================================
   If f_Opcoes(@MvPar,cTitulo,aDescr,MvParDef,12,49,.F.,nTam,nMaxSelect)        

	  //Tratamento para separar retorno com barra ";"
	  &(MvRet) := ""
	  For i:=1 to Len(MvPar) step nTam
		  If !(SubStr(MvPar,i,1) $ " |*")
			 &(MvRet)  += SubStr(MvPar,i,nTam) + ";"
		  EndIf
	  Next i
	
	  //Trata para tirar o ultimo caracter
	  &(MvRet)   := SubStr(&(MvRet),1,Len(&(MvRet))-1) 
  
   EndIf     

End Sequence

Return (.T.)

/*
===============================================================================================================================
Programa----------: U_ITMsgLog()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 09/03/2020
Descrição---------: Função que mostra uma mensagem de Log com a opção de salvar em txt
Parametros--------: 
cMsg...: character, Mensagem de Log
cTitulo: character, Título da Janela
nTipo..: numérico, Tipo da Janela (1 = Ok; 2 = Confirmar e Cancelar)
lEdit..: lógico, Define se o Log pode ser editado pelo usuário
Retorno-----------: lRetMens: Define se a janela foi confirmada
===============================================================================================================================
*/
User Function ITMsgLog(cMsg, cTitulo, nTipo, lEdit)
Local lRetMens := .F.
Local oDlgMens
Local oBtnOk, cTxtConf := ""
Local oBtnCnc, cTxtCancel := ""
Local oBtnSlv
Local oMsg
Local nCompriM := 300
Local nLarguraM := 500
Default cMsg    := "..."
Default cTitulo := "ITMsgLog"
Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
Default lEdit   := .F.


//Definindo os textos dos botões
If(nTipo == 1)
	cTxtConf:='&Ok'
Else
	cTxtConf:='&Confirmar'
	cTxtCancel:='C&ancelar'
EndIf

//Criando a janela centralizada com os botões
DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO nCompriM, nLarguraM PIXEL
//Get com o Log
@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 243, 121  HSCROLL PIXEL //191
If !lEdit
	oMsg:lReadOnly := .T.
EndIf

//Se for Tipo 1, cria somente o botão OK
If (nTipo==1)
	@ 127, 195 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL //144
	
	//Senão, cria os botões OK e Cancelar
ElseIf(nTipo==2)
	@ 127, 195 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL //144
	@ 137, 195 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL //144
EndIf

//Botão de Salvar em Txt
@ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return lRetMens
 
/*
===============================================================================================================================
Programa----------: fSalvArq()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 09/03/2020
Descrição---------: Função para gerar um arquivo texto 
Parametros--------: 
cMsg...: character, Mensagem de Log
cTitulo: character, Título da Janela
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function fSalvArq(cMsg, cTitulo)
    Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""
     
    //Pegando o caminho do arquivo
//    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
    _cDir := cGetFile( "\" , "Selecione o Diretorio de Destino:" ,,,, GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE)
 
    //Se o nome não estiver em branco    
    If !Empty(_cDir)
        //Teste de existência do diretório
        cFileNom:=_cDir+"\ERRO_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+".TXT"

        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cTexto := "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
         
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf
Return

/*
===============================================================================================================================
Programa----------: GrVLZGT
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 02/07/2020
Descrição---------: Grava log de movimentação referente ao processo de aprovação via WF na tabela ZGT
Parametros--------: _cFilPed	- Filial do pedido / Solicitação
				    _cAprov		- Código do aprovador
					_cRotina	- Nome da rotina
					_cTpOper	- Tipo da operação E-Envio | R-Retorno
					_cTpApro	- Status aprovação A-Aprovado | R-Rejeitado
					_cLink		- Link do html de aprovação.
					_cIdped		- Id do pedido portal | Número da solicitação
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function GrVLZGT(_cFilPed, _cAprov, _cRotina, _cTpOper, _cTpApro, _cLink, _cIdped)

	ZGT->(RECLOCK("ZGT",.T.))
	ZGT->ZGT_FILIAL := _cFilPed
	ZGT->ZGT_CDAPRV := _cAprov
	ZGT->ZGT_ROTINA := _cRotina//MOMS050/MEST019
	ZGT->ZGT_TPOPER := _cTpOper
	ZGT->ZGT_TPAPRO := _cTpApro
	ZGT->ZGT_HTML   := _cLink
	ZGT->ZGT_IDPED  := _cIdped
	ZGT->ZGT_DTOPER := DATE()
	ZGT->ZGT_HROPER := TIME()
	ZGT->(MsUnlock())

RETURN

/*
===============================================================================================================================
Programa----------: SubEmbagem
Autor-------------: Alex Wallauer
Data da Criacao---: 18/02/2022
Descrição---------: Tabelas de sutipos de embalagens em stand-by
Parametros--------: _cMVRET	- Campo que chamou
				    lDados	- Tipo de retorno
Retorno-----------: "Descricao" ou _aDadosRet
===============================================================================================================================
*/
User Function SubEmbagem(_cMVRET,lDados)
LOCAL _aDadosRet:={} , C
DEFAULT _cMVRET :=""
DEFAULT lDados:=.F.
STATIC _aDados01:={}
STATIC _aDados02:={}
//STATIC _aDados03:={}

_cTpEmb :=FwFldGet('BZ_I_TPEMB',,,.F.)
_cTpEmb1:=FwFldGet('BZ_I_TBEM1',,,.F.)
//_cTpEmb2:=FwFldGet('BZ_I_TBEM2',,,.F.)
//_cTpEmb3:=FwFldGet('BZ_I_TBEM3',,,.F.)

IF EMPTY(_aDados01)
   AADD(_aDados01,{"11","1-TETRA PAK"})
   AADD(_aDados01,{"12","2-LEITE EM PÓ "})
   AADD(_aDados01,{"13","3-LEITE CONDENSADO BAG"})
   AADD(_aDados01,{"14","4-QUEIJO"})
   AADD(_aDados01,{"15","5-MANTEIGA DE LEITE"})
   AADD(_aDados01,{"16","6-DOCE DE LEITE"})
   
   AADD(_aDados01,{"21","1-PRODUTOS TETRA PAK"})
   AADD(_aDados01,{"22","2-LEITE EM PÓ"})
   AADD(_aDados01,{"23","3-LEITE CONDENSADO BAG"})
   AADD(_aDados01,{"24","4-QUEIJO"})
   AADD(_aDados01,{"25","5-MANTEIGA DE LEITE"})
   AADD(_aDados01,{"26","6-DOCE DE LEITE"})
   
   AADD(_aDados01,{"31","1-PELÍCULAS/FILMES"})
   AADD(_aDados01,{"32","2-CANTONEIRAS E CHAPAS"})
   
   AADD(_aDados01,{"41","1-ADESIVO/COLA"})
   AADD(_aDados01,{"42","2-FLUIDOS"})
ENDIF

IF _cMVRET = "M->BZ_I_TBEM1"

   IF !lDados
      IF (nPos:=ASCANS(_aDados01,{|C1|C1[1]==_cTpEmb+_cTpEmb1})) <> 0
         RETURN  SUBSTR(_aDados01[nPos,2],3)//DEVOLVE A DESCRIACAO
	  ELSE
         RETURN " "
	  ENDIF
   ELSEIF lDados
      FOR C := 1 TO LEN(_aDados01)  
	      IF LEFT(_aDados01[C,1],1) = _cTpEmb
	         AADD(_aDadosRet,_aDados01[C,2])
		  ENDIF
	  NEXT
      RETURN  _aDadosRet//DEVOLVE ARRAY DE DADOS DO F3
	ENDIF

ELSEIF _cMVRET = "M->BZ_I_TBEM2"

   IF !lDados
      IF (nPos:=ASCANS(_aDados02,{|C1|C1[1]==_cTpEmb+_cTpEmb1+_cTpEmb2})) <> 0
         RETURN  SUBSTR(_aDados02[nPos,2],3)//DEVOLVE A DESCRIACAO
	  ELSE
         RETURN " "
	  ENDIF
   ELSEIF lDados
      FOR C := 1 TO LEN(_aDados02)  
	      IF LEFT(_aDados02[C,21],2) = _cTpEmb+_cTpEmb1
	         AADD(_aDadosRet,_aDados02[C,2])
		  ENDIF
	  NEXT
      RETURN  _aDadosRet//DEVOLVE ARRAY DE DADOS DO F3
	ENDIF

ENDIF

RETURN IF(lDados,{},"")

/*
===============================================================================================================================
Programa--------: ITSUBCHR()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 31/03/2023
Descrição-------: Faz a substituição de caracteres especiais de um texto passado por parâmetro e retorna o texto alterado.
Parametros------: _cTexto   = Texto a ter os caracteres especiais substituidos.
                  _aExcecao = Array com as alterações que devem prevalecer sobre a função. 
Retorno---------: _cRet   = Texto alterado.
===============================================================================================================================
*/
User Function ITSUBCHR(_cTexto, _aExcecao)
Local _cRet := ""
Local _nI 
Local _aCaracter := {} 

Default _cTexto := ""
Default _aExcecao := {{"",""}}

Begin Sequence 
   
   Aadd(_aCaracter,{"Ã?","A"})
   Aadd(_aCaracter,{"Âª","a"})
   Aadd(_aCaracter,{"Ã?","E"})
   Aadd(_aCaracter,{"Ã^","E"})
   Aadd(_aCaracter,{"^",""})
   Aadd(_aCaracter,{"á","a"})
   Aadd(_aCaracter,{"Á","A"})
   Aadd(_aCaracter,{"à","a"})
   Aadd(_aCaracter,{"À","A"})
   Aadd(_aCaracter,{"ã","a"})
   Aadd(_aCaracter,{"Ã","A"})
   Aadd(_aCaracter,{"â","a"})
   Aadd(_aCaracter,{"Â","A"})
   Aadd(_aCaracter,{"ä","a"})
   Aadd(_aCaracter,{"Ä","A"})
   Aadd(_aCaracter,{"é","e"})
   Aadd(_aCaracter,{"É","E"})
   Aadd(_aCaracter,{"ë","e"})
   Aadd(_aCaracter,{"Ë","E"})
   Aadd(_aCaracter,{"ê","e"})
   Aadd(_aCaracter,{"Ê","E"})
   Aadd(_aCaracter,{"í","i"})
   Aadd(_aCaracter,{"Í","I"})
   Aadd(_aCaracter,{"ï","i"})
   Aadd(_aCaracter,{"Ï","I"})
   Aadd(_aCaracter,{"î","i"})
   Aadd(_aCaracter,{"Î","I"})
   Aadd(_aCaracter,{"ý","y"})
   Aadd(_aCaracter,{"Ý","y"})
   Aadd(_aCaracter,{"ÿ","y"})
   Aadd(_aCaracter,{"ó","o"})
   Aadd(_aCaracter,{"Ó","O"})
   Aadd(_aCaracter,{"õ","o"})
   Aadd(_aCaracter,{"Õ","O"})
   Aadd(_aCaracter,{"ö","o"})
   Aadd(_aCaracter,{"Ö","O"})
   Aadd(_aCaracter,{"ô","o"})
   Aadd(_aCaracter,{"Ô","O"})
   Aadd(_aCaracter,{"ò","o"})
   Aadd(_aCaracter,{"Ò","O"})
   Aadd(_aCaracter,{"ú","u"})
   Aadd(_aCaracter,{"Ú","U"})
   Aadd(_aCaracter,{"ù","u"})
   Aadd(_aCaracter,{"Ù","U"})
   Aadd(_aCaracter,{"ü","u"})
   Aadd(_aCaracter,{"Ü","U"})
   Aadd(_aCaracter,{"ç","c"})
   Aadd(_aCaracter,{"Ç","C"})
   Aadd(_aCaracter,{"º","o"})
   Aadd(_aCaracter,{"°","o"})
   Aadd(_aCaracter,{"ª","a"})
   Aadd(_aCaracter,{"ñ","n"})
   Aadd(_aCaracter,{"Ñ","N"})
   Aadd(_aCaracter,{"²","2"})
   Aadd(_aCaracter,{"³","3"})
   Aadd(_aCaracter,{"’",""})
   Aadd(_aCaracter,{"§","S"})
   Aadd(_aCaracter,{"±","+"})
   Aadd(_aCaracter,{"­","-"})
   Aadd(_aCaracter,{"´",""})
   Aadd(_aCaracter,{"o","o"})
   Aadd(_aCaracter,{"µ","u"})
   Aadd(_aCaracter,{"¼","1/4"})
   Aadd(_aCaracter,{"½","1/2"})
   Aadd(_aCaracter,{"¾","3/4"})
   Aadd(_aCaracter,{"&","e"}) 
   Aadd(_aCaracter,{";",","})
   Aadd(_aCaracter,{"¡","i"})
   Aadd(_aCaracter,{"©","c."})
   Aadd(_aCaracter,{"®","r."})
   Aadd(_aCaracter,{"£","L"})
   Aadd(_aCaracter,{"‡","t"})
   Aadd(_aCaracter,{"ƒ","f"})
   Aadd(_aCaracter,{"–","-"})
   Aadd(_aCaracter,{"!",""})
   Aadd(_aCaracter,{"×","x"})
   Aadd(_aCaracter,{"¥",""})
   Aadd(_aCaracter,{"¤",""})
   Aadd(_aCaracter,{"?",""})
   Aadd(_aCaracter,{"`",""})
   Aadd(_aCaracter,{"~",""})
   Aadd(_aCaracter,{"'",""})
  
   _cRet := _cTexto 

   If ! Empty(_aExcecao) .And. Len(_aExcecao) > 0 .And. Len(_aExcecao[1]) > 1
      For _nI := 1 To Len(_aExcecao)
          _cRet := StrTran(_cRet, _aExcecao[_nI,1],_aExcecao[_nI,2])
	  Next
   EndIf 

   For _nI := 1 To Len(_aCaracter)
       _cRet := StrTran(_cRet, _aCaracter[_nI,1],_aCaracter[_nI,2])
   Next

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Programa----------: U_TipoEntrega ()
Autor-------------: Alex Wallauer
Data da Criacao---: 08/02/2024
Descrição---------: Valida , lista e devolve a descricao do Tipos de Entrega
Parametros--------: cLetra: Letra do Tipos de Entrega
				    lValida: Valida a letra de existe ou não 
					Valids: U_Tipo Entrega (M->C5_I_AGEND,.T.) / U_Tipo Entrega (M->A1_I_AGEND,.T.)
					F3 LSTTPA e LSTAGE: U_Tipo Entrega ()
					Descricao: U_Tipo Entrega (campo)
Retorno-----------: "Descricao" ou _aDados ou .t. ou .f.
===============================================================================================================================
*/
User Function TipoEntrega(cLetra,lValida)
LOCAL _aDados:={}
LOCAL _aLetras:={"A","I","P","M","R","N","T","O"}// NÃO ESQUEÇA DE POR A LETRA NOVA AQUI TB
LOCAL xRet
DEFAULT lValida:=.F.
        
aAdd( _aDados , "A=Agendada"             )//01 - A 
aAdd( _aDados , "I=Imediata"             )//02 - I 
aAdd( _aDados , "P=Aguardando Agenda"    )//03 - P 
aAdd( _aDados , "M=Agendada com Multa"   )//04 - M 
aAdd( _aDados , "R=Reagendar"	         )//05 - R 
aAdd( _aDados , "N=Reagendar com Multa"  )//06 - N 
aAdd( _aDados , "T=Agendada pelo Transp.")//07 - T 
aAdd( _aDados , "O=Agendada pelo Op.Log.")//08 - O 

IF lValida
   IF !EMPTY(cLetra) .AND. ASCAN(_aLetras,cLetra) = 0
               // NÃO ESQUEÇA DE POR A LETRA NOVA \/ AQUI \/ TB
      U_MT_ITMSG("Somente são aceitas as Letras: A,I,P,M,R,N,T e O","Atencao","Selecione uma letra da lista via F3.",1) 
	  //Pertence('AIPMRNTO')
      xRet := .F.
   ELSE
      xRet := .T.
   ENDIF
ELSEIF cLetra = NIL
   xRet := _aDados
ELSEIF ASCAN(_aLetras,cLetra) > 0
   xRet := SUBSTR(_aDados[ASCAN(_aLetras,cLetra)],3)
ELSE
   xRet := " "
ENDIF

RETURN xRet

/*
===============================================================================================================================
Programa----------: ITTLMAIL
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/03/2024
Descrição---------: Tela de Visualização e Alteração de dados de e-mail.
Parametros--------: @_cFrom     == E-mail de Origem   == E-mail do usuário Workflow configurado com e-mail de origem.
                    @_cGetPara  == E-Mail de Destino  == Altera o conteúdo da Variável passada por parâmetro.
                    @_cGetCc    == E-Mail em Cópia    == Altera o conteúdo da Variável passada por parâmetro.
					@_cGetAssun == Assunto do E-mail  == Altera o conteúdo da Variável passada por parâmetro.
					@_cBody     == Conteúdo do E-mail == Altera o conteúdo da Variável passada por parâmetro.
					_cTitTela   == Titulo da Tela
Retorno-----------: _lRet = .T. = Confirmação do E-mail
                            .F. = Cancelamento do E-mail
===============================================================================================================================
*/
User Function ITTLMAIL(_cFrom, _cGetPara,_cGetCc,_cGetAssun,_cBody,_cTitTela)
Local _oAssunto
Local oButCan
Local oButEnv
Local _oCc
Local _oGetAssun
Local _oGetCc
Local _oGetPara
Local _oMens
Local _oPara
Local _nOpcA := 2
Local _lRet  := .T. 
Local _nLinha 
Local _lEditar := .T. 

Private oDlgMail , _oFont

Begin Sequence 

   IF !SuperGetMV("IT_AMBTEST",.F.,.T.)  // Em ambiente de Produção desabilitar a edição. Permitir Edição apenas para Testes.
      _lEditar := .F.
   EndIf 
     
   DEFINE MSDIALOG oDlgMail TITLE _cTitTela FROM 000, 000  TO 445, 590 COLORS 0, 16777215 PIXEL
       _nLinha := 5 
       //======
	   // Para:
	   //======
	   @ _nLinha, 006 SAY _oFrom PROMPT "De:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   @ _nLinha, 030 MSGET _oGetFrom VAR _cFrom SIZE 256, 010 OF oDlgMail PICTURE "@x" WHEN _lEditar COLORS 0, 16777215 PIXEL
	   _nLinha += 16

	   //======
	   // Para:
	   //======
	   @ _nLinha, 006 SAY _oPara PROMPT "Para:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   @ _nLinha, 030 MSGET _oGetPara VAR _cGetPara SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL
	   _nLinha += 16

	   //===========
	   // Com cópia:
	   //===========
	   @ _nLinha, 006 SAY _oCc PROMPT "Cc:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   @ _nLinha, 030 MSGET _oGetCc VAR _cGetCc SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL
	   _nLinha += 16

	   //=========
	   // Assunto:
	   //=========
	   @ _nLinha, 006 SAY _oAssunto PROMPT "Assunto:" SIZE 022, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   @ _nLinha, 030 MSGET _oGetAssun VAR _cGetAssun SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL  //37
       _nLinha += 32

	   //==========
	   // Mensagem:
	   //==========
	   @ _nLinha, 006 SAY _oMens PROMPT "Mensagem:" SIZE 030, 007 OF oDlgMail COLORS 0, 16777215 PIXEL    // 69
	   _oFont		:= TFont():New( 'Courier new' ,, 12 , .F. )
	   _oScrAux	:= TSimpleEditor():New( _nLinha + 11 , 006 , oDlgMail , 285 , 105 ,,,,, .T. ) // ( 080 , 006 , oDlgMail , 285 , 105 ,,,,, .T. )
	
	   _oScrAux:Load( _cBody )
	   
	   _nLinha += 120
	   //189
	   @ _nLinha, 201 BUTTON oButEnv PROMPT "&Enviar"		SIZE 037, 012 OF oDlgMail ACTION ( _nOpcA := 1 , _cBody := _oScrAux:RetText() , oDlgMail:End() ) PIXEL
	   @ _nLinha, 245 BUTTON oButCan PROMPT "&Cancelar"	SIZE 037, 012 OF oDlgMail ACTION ( _nOpcA := 2 , oDlgMail:End() ) PIXEL

   ACTIVATE MSDIALOG oDlgMail CENTERED

   If _nOpcA == 1
      _lRet := .T.
   Else  
      _lRet := .F.
   EndIf 

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: U_ITCOPYARQ
Autor-------------: Igor Melgaço
Data da Criacao---: 16/05/2024
Descrição---------: Cópia de arquivos entre diretórios Chamado: 45006
Parametros--------: Nenhum
Retorno-----------: _lRet
===============================================================================================================================
*/
User Function ITCOPYARQ()
Local _nI        := 0
Local _aParRet   := {}
Local _aParAux   := {}
Local _bOK       := {|| IF(!Empty(Alltrim(MV_PAR01)) .AND. !Empty(Alltrim(MV_PAR02)) ,.T.,(U_ITMSG("Selecione qq um arquivo.",'Atenção!',"Preencha todos os campos!",3),.F.) ) }
Local lHtml      :=  (GetRemoteType() == 5) //VALIDA SE O AMBIENTE É SMARTCLIENTHTML (WEB)

MV_PAR01 :=  Space(600)
MV_PAR02 :=  Space(200)
MV_PAR03 :=  2

IF SELECT("SX3") = 0//Para a função ParamBox() funcionar no Remote
   cFilAnt  :="01"
   CEMPANT  :="01"
   CARQTAB  :=""
   cUserName:=""
   __CUSERID:=""
ENDIF

PRIVATE _lRemote:=IsBlind()

IF _lRemote .AND. !SuperGetMV("IT_AMBTEST",.F.,.T.)
   _nDestinos:=GETF_RETDIRECTORY+GETF_LOCALHARD
ELSE
   _nDestinos:=GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE
ENDIF

aAdd( _aParAux , { 6 , "Selecione o(s) arquivo(s)"    , MV_PAR01 , "","" ,"",80,.T.,"Todos os arquivos (*.*) |*.*","\DATA\",GETF_LOCALHARD + GETF_MULTISELECT})
IF !lHtml
   AADD( _aParAux , { 6 , "Selecione pasta de destino", MV_PAR02 , "","" ,"",80,.T.,"Todos os arquivos (*.*) |*.*","C:\"   ,_nDestinos})
ELSE
   MV_PAR02 :=  "C:\TEMP\"+Space(200)
   AADD( _aParAux , { 1 , "Digite a pasta de destino" , MV_PAR02, "@!" , "" , "" , "" , 80 , .T. } ) 
ENDIF
aAdd( _aParAux , { 3 , "Deixe-me decidir Substituir para cada Arquivo", MV_PAR03, {"Sim","Nao"}         , 40, "", .T., .T. , .T. } )

For _nI := 1 To Len( _aParAux )
   aAdd( _aParRet , _aParAux[_nI][03] )
Next _nI

_lRet:=.T.
_cTimeIni  := Time()
FWMSGRUN( ,{|_oProc|  _lRet := ITCOPYEXEC(_oProc,_aParAux,_aParRet,_bOK) } , "Hora Inicial: "+_cTimeIni )

Return _lRet

/*
===============================================================================================================================
Programa----------: ITCOPYEXEC
Autor-------------: Igor Melgaço
Data da Criacao---: 16/05/2024
Descrição---------: Procesamento da Cópia de Arquivos Chamado: 45006
Parametros--------: _oProc,_aParAux,_aParRet,_bOK
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function ITCOPYEXEC(_oProc,_aParAux,_aParRet,_bOK)
Local _nI  := P   := 0
Local _aLog       := {}
Local _aCab       := {"","Status","Origem","Destino"}
Local _cExtArq    := ""
Local _aExtArq    := {}
Local _lCopy      := .F.
Local _lExistArq  := .F.
Local _cExistArq  := ""
Local _cDir       := ""
Local _aFiles     := {}
Local _cNomeArqNew:= ""
Local _nOpcao     := 1

DO WHILE .T.

If !ParamBox( _aParAux , " Cópia de Arquivos do Server - Ambiente: "+GetEnvServer()  , @_aParRet, _bOK,, .T. , , , , , .T. , .T. )
   EXIT
ENDIF

//ITTXTARRAY(_cTexto,_cSeparador,_nNrPosicArray,_nNrMinimoArray)
_aFiles   := U_ITTXTARRAY(Alltrim(MV_PAR01)+"|","|",0)
_cDir     := Alltrim(MV_PAR02)
_cDir     += IIf(Subs(_cDir,Len(_cDir),1)=="\","","\")
_aLog     := {}
_nOpcao   := 1
_lCopy    := .F.
_lExistArq:= .F.

If MV_PAR03 = 2
	For _nI := 1 To Len(_aFiles)
       IF EMPTY(_aFiles[_nI])
	      LOOP
	   ENDIF
		_aFiles[_nI] := ALLTRIM(StrTran(_aFiles[_nI],"servidor",""))

        IF _oProc <> NIL
	       _oProc:cCaption := ("Lendo o Arquivo "+Alltrim(_aFiles[_nI]))
	       ProcessMessages()
	    ENDIF

		_aArquivo := StrTokArr(Alltrim(_aFiles[_nI]),"\")
		_cNomeArq := _aArquivo[Len(_aArquivo)]
        
		IF AT(".",_cNomeArq) > 0
		   _aExtArq  := StrTokArr(Alltrim(_cNomeArq),".")
		   _cExtArq  := "."+_aExtArq[Len(_aExtArq)]
		   _cNomeArq := ""
		   FOR P := 1 TO (LEN(_aExtArq)-1)//PARA CASO DE TER MAIS DE UM PONTO NO NOME DO ARQUIVO
		      _cNomeArq += IF(EMPTY(_cNomeArq),"",".")+_aExtArq[P]
		   NEXT
		ELSE
		   _cExtArq  := ""
		ENDIF

		_nCopy := 0
		_cNomeArqNew := _cNomeArq 

		If File(_cDir + "\"+_cNomeArqNew +  _cExtArq)
			_lExistArq := .T.
			_cExistArq += Iif(Empty(Alltrim(_cExistArq)),""," / ") + _cNomeArqNew + _cExtArq
		EndIf
	Next
    IF !EMPTY(_cExistArq)//Aviso("Título", cMsg, {"OK"}, 3, "Sub Título", , "BR_AZUL")
	   IF _lRemote
	      _nOpcao:= 3
	      IF MSGNOYES("O(S) ARQUIVO(S) "+UPPER(_cExistArq)+" JÁ EXITE(M) NO DIRETORIO : "+UPPER(_cDir)+". Deseja substituir?")
		     _nOpcao:= 1
	         IF MSGNOYES("Deseja Renomear(los)?")
		        _nOpcao:= 2
		     ENDIF
		  ENDIF
	   ELSE
	      _nOpcao := AVISO("Existência de arquivos no diretório de destino!",;
							UPPER(_cExistArq) + CHR(13)+CHR(10) +" já existe(m) no diretório "+ UPPER(Alltrim(MV_PAR02)),; //"O arquivo(s):"+ CHR(13)+CHR(10) + 
							{ "SUBSTITUIR"     ,; // 01
							  "RENOMEAR"       ,; // 02
							  "NÃO COPIAR" } ,3,; // 03
							  "O(s) arquivo(s) abaixo : ")   
	   ENDIF
    ENDIF
EndIf

For _nI := 1 To Len(_aFiles)

    IF EMPTY(_aFiles[_nI])
	   LOOP
	ENDIF
	_aFiles[_nI] := StrTran(_aFiles[_nI],"servidor","")
    IF _oProc <> NIL
	   _oProc:cCaption := ("Lendo o Arquivo "+Alltrim(_aFiles[_nI]))
	   ProcessMessages()
	ENDIF

	_aArquivo := StrTokArr(Alltrim(_aFiles[_nI]),"\")
	_cNomeArq := _aArquivo[Len(_aArquivo)]

	IF AT(".",_cNomeArq) > 0
	   _aExtArq  := StrTokArr(Alltrim(_cNomeArq),".")
	   _cExtArq  := "."+_aExtArq[Len(_aExtArq)]
	   _cNomeArq := ""
	   FOR P := 1 TO (LEN(_aExtArq)-1)//PARA CASO DE TER MAIS DE UM PONTO NO NOME DO ARQUIVO
	      _cNomeArq += IF(EMPTY(_cNomeArq),"",".")+_aExtArq[P]
	   NEXT
	ELSE
	   _cExtArq  := ""
	ENDIF

	_nCopy := 0
	_cNomeArqNew := _cNomeArq 
	
	If MV_PAR03 = 1 .AND. File(_cDir + "\"+_cNomeArqNew + _cExtArq)
	   IF _lRemote
	      _nOpcao:= 3
	      IF MSGNOYES("O ARQUIVO "+UPPER(Alltrim(_aFiles[_nI]))+" JÁ EXITE NO DIRETORIO : "+UPPER(_cDir)+". Deseja substituir?")
		     _nOpcao:= 1
	         IF MSGNOYES("Deseja Renomear?")
		        _nOpcao:= 2
		     ENDIF
		  ENDIF
	   ELSE
	      _nOpcao := AVISO("Existência de arquivos no diretório de destino!",;
								UPPER(Alltrim(_aFiles[_nI])) + CHR(13)+CHR(10) +" já existe no diretório "+ UPPER(Alltrim(MV_PAR02)),;
							  { "SUBSTITUIR"     ,; // 01 
								"RENOMEAR"       ,; // 02
							    "NÃO COPIAR" } ,3,; // 03
							    "O arquivo abaixo : ")   
	    ENDIF
	EndIf

	If _nOpcao = 1 .OR. _nOpcao = 2
		If _nOpcao = 2
			Do While File(_cDir + "\" + _cNomeArqNew  + _cExtArq)
				_nCopy++
				_cNomeArqNew := _cNomeArq + "("+Alltrim(Str(_nCopy))+")" 
			EndDo
			_cNomeArq := _cNomeArqNew	
		EndIf
        IF _oProc <> NIL
		   _oProc:cCaption := ("Copiando o Arquivo "+Alltrim(_aFiles[_nI]))
		   ProcessMessages()
		ENDIF
		If Alltrim(_aFiles[_nI]) <> Alltrim(_cDir + _cNomeArq  + _cExtArq)
			_lCopy :=  __CopyFile( Alltrim(_aFiles[_nI]),_cDir + _cNomeArq + _cExtArq)
			_cMsg := Iif(_lCopy,"Cópia Efetuada com sucesso","Falha no processo de cópia. Erro: " + ALLTRIM(STR(FERROR())))
			//MSGINFO("1) "+Alltrim(_aFiles[_nI]),_cDir + _cNomeArq + _cExtArq+ " - "+_cMsg)
			//_lCopy := CpyS2T( Alltrim(_aFiles[_nI]),_cDir )
			//MSGINFO("1) "+Alltrim(_aFiles[_nI]), AllToChar(_lCopy ) )
		Else
			_lCopy :=  .F.
			_cMsg := "Cópia não efetuada. Origem igual ao Destino"
		EndIf
	ElseIf _nOpcao = 3
		_cMsg := "Cópia não efetuada."
		_lCopy := .F.
	EndIf

	AADD(_aLog,{_lCopy,_cMsg,_aFiles[_nI],_cDir + _cNomeArq +  _cExtArq })
Next

IF LEN(_aLog) > 0

   IF SELECT("SX3") = 0
      IF _oProc <> NIL
         _oProc:cCaption := "Abrindo ambiente, Hora Inicial: "+_cTimeIni
         ProcessMessages()
      ENDIF
      RpcSetEnv("01", "01",,,,,)   
      //Sleep( 2000 ) //Aguarda 2 segundos para subam as configurações do ambiente.
   ENDIF
   
   //ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1)
   U_ITLISTBOX("Log de Cópia de Arquivos do Server", _aCab    , _aLog     , .F.      , 4      ,  ,          ,  ,         ,     ,        , ,      ,         ,           ,          ,        , .F.)

ELSE
    MSGSTOP("Não foi possivel copiar.")
ENDIF

ENDDO

Return .T.

/*
===============================================================================================================================
Programa----------: ITWF1WF2Put
Autor-------------: Alex Wallauer
Data da Criacao---: 04/07/2024
Descrição---------: Grava o WF1 E WF2 para o Rastreamento WorkFlow via monitor
Parametros--------: cTwProcess: Codigo do WorkFlow. Ex. "APRVTP"
                    cDescWF1..: Descrição do WorkFlow. Ex. "Workflow de Tabela de Preços de Fornecedores de Compras"
                    cStatusWF2: Codigo do status do WorkFlow. Ex. "WKTP01"
                    cDescWF1..: Descrição do status  do WorkFlow. Ex. "Enviado/Aguardando Aprovacao"
Retorno-----------: .T.
===============================================================================================================================
*/
USER Function ITWF1WF2Put( cTwProcess , cDescWF1 , cStatusWF2 , cDescWF2 )
DEFAULT cTwProcess:=""
DEFAULT cDescWF1  :=""
DEFAULT cStatusWF2:=""
DEFAULT cDescWF2  :=""

IF EMPTY(cTwProcess)
   RETURN .F.
ENDIF

IF !EMPTY(cDescWF1)
   WF1->( dbSetOrder( 1 ) )
   IF !WF1->(DBSEEK( xFilial( "WF1" ) + cTwProcess ) )
       WF1->( RecLock( "WF1" , .T. ) )
       WF1->WF1_FILIAL:= xFilial( "WF1" )
       WF1->WF1_COD   := cTwProcess
       WF1->WF1_DESCR := cDescWF1
       WF1->( MsUnLock() )
   EndIF
EndIF

IF !EMPTY(cStatusWF2)
    WF2->( dbSetOrder( 1 ) )
    IF !WF2->(dbSeek( xFilial( "WF2" ) + cTwProcess + cStatusWF2 ) )
    	WF2->( RecLock( "WF2" , .T. ) )
		WF2->WF2_FILIAL := xFilial( "WF2" )
		WF2->WF2_PROC 	:= cTwProcess
		WF2->WF2_STATUS	:= cStatusWF2
		WF2->WF2_DESCR	:= cDescWF2
    	WF2->( MsUnLock() )	
    EndIF
ENDIF

Return .T.

/*
===============================================================================================================================
Programa----------: ITRETPAS()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/08/2024
Descrição---------: Retorna o nome ou numero da pasta do campo passado por parâmetro.
Parametros--------: _cAliasTab = O alias da tabela do campo passado por parâmetro.
                    _cCampo    = Campo do dicionário SX3 para retornar o nome ou numero da pasta.
					_cTipoRet  = "D" = Descrição/Nome da pasta.
					             "N" = Numero da pasta.
Retorno-----------: _cRet  = Retorna o nome ou numero da pasta.
===============================================================================================================================
*/
User Function ITRETPAS(_cAliasTab,_cCampo, _cTipoRet)
Local _cRet := ""
Local _aPastas := {}
Local _nI 
Local cAliasX  := GetNextAlias()

Begin Sequence 
   
   If Empty(_cTipoRet)
      _cTipoRet := "D"
   EndIf 
   
   cQuery := " SELECT XA_TIPO , XA_ORDEM , XA_DESCRIC FROM SXA010 WHERE D_E_L_E_T_ = ' ' " 
   cQuery += " AND XA_ALIAS = '" + AllTrim(_cAliasTab) + "'"
   
   MPSysOpenQuery( cQuery , cAliasX )
   (cAliasX)->( DBGoTop() )

   IF (cAliasX)->(Eof()) .AND. (cAliasX)->(BOF())
      _cRet := ""
	  Break 
   EndIf 

   DO WHILE (cAliasX)->(!Eof())
      If Empty((cAliasX)->XA_TIPO)
         Aadd(_aPastas, {(cAliasX)->XA_ORDEM,(cAliasX)->XA_DESCRIC}) 
	  EndIf      
      (cAliasX)->(DbSkip())
   EndDo 

   If Empty(_aPastas)
      _cRet := ""
	  Break  
   EndIf 

   _cNrPasta := GetSx3Cache(_cCampo,"X3_FOLDER")

   If Empty(_cNrPasta)
      If _cTipoRet == "D"
         _cRet := "Outros"
	     Break  
	  EndIf 
   EndIf

   If _cTipoRet == "N"
      _cRet := _cNrPasta
	  Break  
   EndIf 
   
   _nI := Ascan(_aPastas,{|x| x[1] == _cNrPasta })

   If _nI = 0
      _cRet := ""
	  Break  
   EndIf

   _cRet := _aPastas[_nI,2]

End Sequence

(cAliasX)->( DBCloseArea() )

Return _cRet
