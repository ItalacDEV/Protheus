/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/07/2023 | Chamado 44446. Corrigida grava��o do campo ZLF_L_SEEK e retirada pergunta sobre gera��o de nova 
			  |			   | parcela. Por padr�o sempre ser� gerada. N�o identificamos motivos para perguntar. 
Lucas Borges  | 11/02/2025 | Chamado 49877. Removido tratamento sobre a vers�o do Mix
Lucas Borges  | 12/02/2025 | Chamado 49885. Corrigido nome da vari�vel
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: MGLT011
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina que processa o fechamento dos Fretistas. Rotina reestruturada para melhoria de performance e solu��o 
					de inconsist�ncias nas amarra��es. Chamados: 8071/8622
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function MGLT011()

Local _cPerg  		:= 'MGLT011'
Local _oProces		:= NIL

TNewProcess():New(	_cPerg											,; // Fun��o inicial
					"Fechamento de Transportadores de Leite Pr�prio",; // Descri��o da Rotina
					{|_oProces| MGLT011R(_oProces) }				,; // Fun��o do processamento
					"Essa rotina tem por objetivo processar o 'Fechamento do Frete sob Leite Pr�prio' "+;
					"realizando os c�lculos para acerto dos Transportadores!",; // Descri��o da Funcionalidade
					_cPerg											,; // Configura��o dos Par�metros
					{}												,; // Op��es adicionais para o painel lateral
					.F.												,; // Define cria��o do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descri��o do Painel Auxiliar
					.T.												,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
	                .F.                                              ) // Se .T. cria apenas uma regua de processamento.

Return

/*
===============================================================================================================================
Programa----------: MGLT011R
Autor-------------: Alexandre Villar
Data da Criacao---: 14/04/2015
Descri��o---------: Rotina que controla o processamento do acerto
Parametros--------: _oProces
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011R(_oProces)

Local _cAliasP		:= GetNextAlias()
Local _cQuery		:= ""
Local _nCont		:= 0
Local _cIndZLF		:= ''
Local _aLogCTE		:= {}
Local _nReg			:= 0
Local _nTipExe		:= MV_PAR01
Local _cMix			:= MV_PAR02
Local _cSetores		:= ''
Local _lFilCTe		:= .F.
Local _lErro		:= .F.
Local _nSldFrt		:= 0
Local _cNroTit		:= StrZero( Day( dDataBase ) , 2 ) + StrZero( Month( dDataBase ) , 2 ) + Substr( Dtos( dDataBase ) , 3 , 2 ) + SubStr( _cMix , 4 , 3 )
Local _cParcel		:= ''
Local _cPrefixo		:= ''
Local _cTipo		:= "NF "							// Tipo do Titulo do CTe
Local _cNum			:= ""								// Numero do Titulo do CTe
Local _cXParc		:= ""								// Parcela do Titulo do CTe
Local _cFornece		:= ''
Local _cLoja		:= ''
Local _cSetor		:= ''
Local _dPgto		:= MV_PAR08
Local _dVencto		:= MV_PAR09
Local _cThread		:= CValToChar(ThreadID())
Local _cHist		:= ''
Private _nValISS	:= 0 //Vari�vel private para poder ser executada no ZL8_FORMUL - evento 000147 - ISS

_oProces:SaveLog("Thread:"+_cThread+" Iniciando a rotina. Par�metros: "+CValToChar(MV_PAR01)+"-"+MV_PAR02+"-"+AllTrim(MV_PAR03)+"-"+MV_PAR04+"-"+MV_PAR05+"-"+MV_PAR06+"-"+MV_PAR07+"-"+DToC(MV_PAR08)+"-"+DToC(MV_PAR09))

//Se n�o preencheu e n�o tem acesso a todos, aborta processamento
If !Empty(MV_PAR03) .Or. Empty(MV_PAR03) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") == 'S'
	_cSetores	:= AllTrim(MV_PAR03)												// Setores de Refer�ncia
Else
	_oProces:SaveLog("Thread:"+_cThread+" MGLT01101 - Fim do processamento. N�o foram informados setores v�lidos para o usu�rio.")
	MsgStop("N�o foram informados setores v�lidos para o usu�rio.","MGLT01101")
	Return
EndIf

_oProces:SetRegua1(1)
_oProces:IncRegua1( "Aguarde - Iniciando a rotina de processamento..." )

//====================================================================================================
// Posiciona no cadastro do MIX
//====================================================================================================
DBSelectArea("ZLE")
ZLE->( DBSetOrder(1) )
ZLE->( DBSeek( xFILIAL("ZLE") + _cMix ) )
_cHist	:= "GLF"+ StrZero(Month(ZLE->ZLE_DTINI),2) +"/"+ StrZero(Year(ZLE->ZLE_DTINI),4) +'-'+ _cMix

// Valida��es para DataBbase
If dDataBase < ZLE->ZLE_DTFIM
	_oProces:SaveLog("Thread:"+_cThread+" MGLT01102 - Fim do processamento. DataBase Inv�lida.")
	MsgStop("A Data-base atual n�o � v�lida! A Data-base deve ser igual ou maior � data final do per�odo do MIX.","MGLT01102")
	Return
EndIf

If (Date() <> dDataBase)
	_oProces:SaveLog("Thread:"+_cThread+" MGLT01103 - Fim do processamento. DataBase Inv�lida.")
	MsgStop("A Data-base atual n�o � v�lida! A Data-base deve ser igual � data atual do Servidor ["+ DtoC(Date()) +"].","MGLT01103")
	Return
EndIf

If _dPgto < dDataBase
	_oProces:SaveLog("Thread:"+_cThread+" MGLT01104 - Fim do processamento. DataBase Inv�lida.")
	MsgStop("A Data-base atual n�o � v�lida! A Data-base deve ser maior ou igual ao Vencimento.","MGLT01104")
	Return
EndIf	

_oProces:IncRegua1( "Aguarde - Consultando os dados para o fechamento..." )

//====================================================================================================
// Chama fun��o para deletar eventos na ZLF gerados anteriormente pela rotina de Fechamento
//====================================================================================================
_cQuery := " DELETE "
_cQuery += " FROM "+RetSqlName("ZLF")
_cQuery += " WHERE D_E_L_E_T_ = ' ' "
_cQuery += " AND ZLF_FILIAL = '"+xFilial("ZLF")+"' "
_cQuery += " AND ZLF_CODZLE = '"+_cMix+"' "
_cQuery += " AND ZLF_A2COD BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"'"
_cQuery += " AND ZLF_A2LOJA BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR07 +"'"
_cQuery += " AND ZLF_ORIGEM = 'F' "				// So deleta originados pela rotina do Acerto
_cQuery += " AND ZLF_TP_MIX = 'F' "				// Deleta apenas registros de Frete
_cQuery += " AND ZLF_ACERTO NOT IN ('S','B') "	// Deleta se nao realizou acerto definitivo
If !Empty( _cSetores )							// Se o parametro com os setores estiver vazio considera todos
	_cQuery += " AND ZLF_SETOR  IN "+ FormatIn( _cSetores , ';' )
EndIf

If TCSqlExec( _cQuery ) < 0
	_oProces:SaveLog("Thread:"+_cThread+" MGLT01105 - Erro - Dele��o de eventos")
	MsgStop("Falha ao processar a exclus�o de registros da ZLF referente � fechamentos anteriores. Favor acionar o Suporte."+AllTrim(TCSQLError()),"MGLT01105")
	Return
EndIf

//====================================================================================================
// Filtra os Fretistas do MIX para iniciar o processamento
//====================================================================================================
_cQuery := "%"
If !Empty( _cSetores )
	_cQuery += "AND ZLF.ZLF_SETOR  IN "+ FormatIn( _cSetores , ';' )
EndIf
_cQuery += "%"
BeginSql alias _cAliasP
	SELECT SA2.A2_COD CODFRT, SA2.A2_LOJA LOJFRT, SA2.R_E_C_N_O_ REGSA2, ZLF_SETOR SETOR,
		   SUM(CASE WHEN ZL8_DEBCRE = 'C' THEN ZLF_TOTAL ELSE 0 END) CREDITO,
		   SUM(CASE WHEN ZL8_DEBCRE = 'D' THEN ZLF_TOTAL ELSE 0 END) DEBITO
	  FROM %Table:ZLF% ZLF, %Table:ZL8% ZL8, %Table:SA2% SA2
	 WHERE ZLF.D_E_L_E_T_ = ' '
	   AND ZL8.D_E_L_E_T_ = ' '
	   AND SA2.D_E_L_E_T_ = ' '
	   AND ZLF.ZLF_FILIAL = %xFilial:ZLF%
	   AND ZL8.ZL8_FILIAL = %xFilial:ZL8%
	   AND SA2.A2_FILIAL = %xFilial:SA2%
	   AND ZLF.ZLF_EVENTO = ZL8.ZL8_COD
	   AND ZLF.ZLF_A2COD = SA2.A2_COD
	   AND ZLF.ZLF_A2LOJA = SA2.A2_LOJA
	   %exp:_cQuery%
	   AND ZLF.ZLF_A2COD BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
	   AND ZLF.ZLF_A2LOJA BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR07%
	   AND SUBSTR(ZLF.ZLF_A2COD, 1, 1) = 'G'
	   AND ZLF.ZLF_CODZLE = %exp:_cMix%
	   AND ZLF.ZLF_ORIGEM <> 'F' /*Origem Fechamento*/
	   AND ZLF.ZLF_ACERTO NOT IN ('S', 'B') /*Nao foi feito acerto*/
	   AND ZLF.ZLF_STATUS = 'E' /*Efetivado*/
	   AND ZLF.ZLF_TP_MIX = 'F' /*Tipo do Mix para Frete*/
	 GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.R_E_C_N_O_, ZLF_SETOR
	 ORDER BY ZLF_SETOR, SA2.A2_COD, SA2.A2_LOJA
EndSql
	
Count To _nReg
(_cAliasP)->( DbGoTop() )
_oProces:SetRegua1( _nReg )
	
If _nReg <= 0
	(_cAliasP)->( DBCloseArea() )
	_oProces:SaveLog("Thread:"+_cThread+" MGLT01106 - Fim do processamento. N�o foram encontrados registros para processar")
	MsgStop("N�o foram encontrados registros para processar! Verifique os par�metros e tente novamente.","MGLT01106")
	Return
EndIf
DBSelectArea("SA2")
DBSelectArea("ZL2")
DbselectArea("ZLF")
DBSelectArea("SE2")
DbSelectArea("ZL8")
While (_cAliasP)->( !Eof() )
	
	BEGIN TRANSACTION
	
	_nCont++
	SA2->( DBGoTo( (_cAliasP)->REGSA2 ) )
	If !ZL2->( DBSeek( xFilial("ZL2") + (_cAliasP)->SETOR ) )
		_lErro := .T.
		_oProces:SaveLog("Thread:"+_cThread+" MGLT01107 - Erro - Setor n�o encontrado: "+ (_cAliasP)->SETOR)
		MsgStop("Falha na identifica��o do setor para o processamento ["+ (_cAliasP)->SETOR +"]!"+;
				"N�o foi poss�vel encontrar o setor que est� configurado no cadastro do fretista. ["+ (_cAliasP)->CODFRT +"/"+ (_cAliasP)->LOJFRT +"]";
				,"MGLT01107")
	EndIf
	
	If !_lErro
		//====================================================================================================
		// Vari�veis de controle para n�o referenciar diretamente as tabelas
		//====================================================================================================
		_cFornece := SA2->A2_COD
		_cLoja := SA2->A2_LOJA
		_cSetor := ZL2->ZL2_COD
		
		_nValISS := 0 //Zera vari�vel para que valor n�o seja carregado erroneamente para outro fretista
		//====================================================================================================
		// Verifica a atualiza��o do objeto de processamento
		//====================================================================================================
		_oProces:IncRegua1( "Fretista ["+ StrZero(_nCont,6) +"] de ["+ StrZero(_nReg,6) +"] -> "+ _cFornece +"/"+ _cLoja +" - "+ AllTrim(SA2->A2_NOME) )
		
		//====================================================================================================
		// Alimenta a vari�vel que vai controlar o saldo do Fretista e verificar se os t�tulos ser�o baixados
		//====================================================================================================
		_nSldFrt	:= (_cAliasP)->CREDITO
		_cIndZLF	:= xFilial("ZLF") + _cMix + "001" + "1" + _cFornece + _cLoja
		_cParcel	:= StrZero( 1 , TamSx3("E2_PARCELA")[1] )	// Parcela do titulo do Fretista( NF )
		
		If _nTipExe == 2
			//====================================================================================================
			// Valida documento de entrada lan�ado
			//====================================================================================================
			If ( _nValCTE := MGLT011CTE(_cFornece,_cLoja,_lFilCTe,@_cPrefixo,@_cNum,@_cXParc,_nSldFrt,_dVencto,_cTipo,_cMix,_cSetor)) == 0
				_lErro := .T.
				_oProces:SaveLog("Thread:"+_cThread+" MGLT01109A - Erro - N�o foi encontrado o t�tulo financeiro referente ao CT-e "+_cFornece +"/"+ _cLoja)
				aAdd( _aLogCTE , { _cFornece +'/'+ _cLoja , 'N�o foi encontrado o t�tulo financeiro referente ao CT-e!' } )
			EndIf
			If !_lErro .And. _nSldFrt <> _nValCTE
				_lErro := .T.
				_oProces:SaveLog("Thread:"+_cThread+" MGLT01109B - Erro - O saldo do CT-e � divergente do valor da folha de pagamento "+_cFornece +"/"+ _cLoja)
				aAdd( _aLogCTE , { _cFornece +'/'+ _cLoja , 'O saldo do CT-e � divergente do valor da folha de pagamento!' } )
			EndIf
		Else //Previs�o
			//Chamado a fun��o para buscar a nota fiscal apenas para apurar o valor dos casos que possuem ISS, 
			//assim o evento de previs�o do imposto � gerado para confer�ncia
			MGLT011CTE(_cFornece,_cLoja,_lFilCTe,@_cPrefixo,@_cNum,@_cXParc,_nSldFrt,_dVencto,_cTipo,_cMix,_cSetor)
		EndIf
	EndIf
	
	//====================================================================================================
	// Acerto de Eventos digitados manualmente e Avulsos( ZLF > gera e baixa SE2 )
	//====================================================================================================
	If !_lErro
		MGLT011PFM(_oProces,_cThread,_nTipExe,_cPrefixo,_cNum,_cXParc,_cTipo,_dPgto,_cMix,_cFornece,_cLoja,_cSetor,@_cParcel,@_nSldFrt,_cHist,@_lErro)
	EndIf
	
	//====================================================================================================
	// Acerto de Eventos Avulsos ( ZL8 > gera ZLF e SE2 e baixa SE2 )
	//====================================================================================================
	If !_lErro
		MGLT011PFE(_oProces,_cThread,_nTipExe,_cNroTit,_cXParc,_cTipo,_dPgto,_cMix,_cSetor,_cFornece,_cLoja,_cPrefixo,_cNum,@_cParcel,@_nSldFrt,_cHist,@_lErro)
	EndIf
	
	//====================================================================================================
	// Acerto Financeiro ( Baixa e gera Contas a Pagar e ZLF )
	//====================================================================================================
	If !_lErro
		MGLT011PFF( _oProces,_cThread,_nTipExe,_cTipo,_dVencto,_cMix,_cSetor,_cFornece,_cLoja,_cHist,_cPrefixo,_cNum,_cXParc,_cTipo,@_cParcel,@_nSldFrt,@_lErro)
	EndIf
	
	//====================================================================================================
	// Ajusta o Status do Processamento ap�s concluir os acertos
	//====================================================================================================
	If !_lErro .And. _nTipExe == 2
		_cQuery := " UPDATE "+RetSqlName("ZLF")
		_cQuery += " SET ZLF_ACERTO = 'S', ZLF_STATUS = 'F' , ZLF_DTFECH = '"+ DtoS( dDataBase ) +"' "
		_cQuery += " WHERE D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZLF_FILIAL = '"+xFilial("ZLF")+"' "
		_cQuery += " AND ZLF_A2COD  = '"+_cFornece+"' "
		_cQuery += " AND ZLF_A2LOJA = '"+_cLoja+"' "
		_cQuery += " AND ZLF_CODZLE = '"+_cMix + "' "
		_cQuery += " AND ZLF_ACERTO NOT IN ('S','B') "
		_cQuery += " AND ZLF_TP_MIX = 'F' "
		_cQuery += " AND ZLF_SETOR = '"+_cSetor+"' "
		
		If TCSqlExec(_cQuery) < 0
			_lErro := .T.
			_oProces:SaveLog("Thread:"+_cThread+" MGLT01108 - Erro - Falhou ao gravar o Status do processo do fechamento")
			MsgStop("Falhou ao gravar o Status do processo do fechamento! Favor acionar o Suporte." + CRLF + AllTrim(TCSQLError()),"MGLT01108")
		EndIf
	EndIf
	
	//====================================================================================================
	// Desfaz o processamento se for encontrado algum erro
	//====================================================================================================
	If _lErro
		_lErro := .F.
		DisarmTransaction()
		Break
	EndIf
	//====================================================================================================
	// Confirma o processamento ao fim do processo sem erros
	//====================================================================================================			
	END TRANSACTION
	MsUnLockAll()
	
(_cAliasP)->( DBSkip() )
EndDo

(_cAliasP)->( DBCloseArea() )

If _nTipExe == 2 // Ajusta o Status caso o Acerto seja Definitivo
	_oProces:SetRegua1(1)
	_oProces:IncRegua1( "Fim do Acerto - Verificando Status..." )

	//====================================================================================================
	// Altera o Status da ZLE
	//====================================================================================================
	If ZLE->( DBSeek( xFilial('ZLE') + _cMix) )
		ZLE->(RecLock( "ZLE" , .F. ))
		ZLE->ZLE_STATUS := 'P'
		ZLE->( MsUnLock() )
	EndIf
EndIf
_oProces:SaveLog("Thread:"+_cThread+" Processamento conclu�do com sucesso")

If !Empty( _aLogCTE )
	MsgStop("Existem fechamentos n�o realizados por problemas relacionados ao CTe!","MGLT01109")
	U_ITListBox( 'Fechamentos n�o realizados!' , {'C�d.Fornec.','Motivo'} , _aLogCTE , .F. , 1 , 'Verifique os probelams encontrados para os fretistas abaixo:' )
EndIf

Return

/*
===============================================================================================================================
Programa----------: MGLT011PFM
Autor-------------: Alexandre Villar
Data da Criacao---: 14/04/2015
Descri��o---------: Rotina que processa o fechamento dos eventos manuais dos Fretistas
Parametros--------: _oProces - Objeto de controle do processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011PFM(_oProces,_cThread,_nTipExe,_cPrefixo,_cNum,_cXParc,_cTipo,_dPgto,_cMix,_cFornece,_cLoja,_cSetor,_cParcel,_nSldFrt,_cHist,_lErro)

Local _aArea	:= GetArea()
Local _cAliasPFM:= GetNextAlias()
Local _nTotReg	:= 0
Local _nCont	:= 0
Local _nVlrEve	:= 0
Local _cNumTit	:= StrZero( Day(dDataBase) , 2 ) + StrZero( Month( dDataBase ) , 2 ) + Substr( DtoS(dDataBase) , 3 , 2 ) + SubStr( _cMix , 4 , 3 )
Local _cParc	:= StrZero( 1 , TamSx3("E2_PARCELA")[1] ) //Parcela do titulo do evento
Local _cSeekZLF	:= ''

//====================================================================================================
// Cria Tabela tempor�ria com os dados dos Eventos( ZL8 )
// Acerto Manual( Busca na ZLF para gerar e baixar na SE2 )
//====================================================================================================
BeginSql alias _cAliasPFM
	SELECT ZL8.R_E_C_N_O_ REGZL8, ZLF.ZLF_SEQ SEQ, ZLF.ZLF_TOTAL TOTAL
	  FROM %Table:ZLF% ZLF, %Table:ZL8% ZL8
	 WHERE ZLF.D_E_L_E_T_ = ' '
	   AND ZL8.D_E_L_E_T_ = ' '
	   AND ZLF.ZLF_FILIAL = %xFilial:ZLF%
	   AND ZL8.ZL8_FILIAL = %xFilial:ZL8%
	   AND ZL8.ZL8_COD = ZLF.ZLF_EVENTO
	   AND ZLF.ZLF_CODZLE = %exp:_cMix%
	   AND ZLF.ZLF_A2COD = %exp:_cFornece%
	   AND ZLF.ZLF_A2LOJA = %exp:_cLoja%
	   AND ZLF.ZLF_SETOR = %exp:_cSetor%
	   AND SUBSTR(ZLF.ZLF_A2COD, 1, 1) = 'G'
	   AND ZLF.ZLF_ORIGEM = 'M'
	   AND ZLF.ZLF_DEBCRE = 'D'
	   AND ZLF.ZLF_ACERTO NOT IN ('S', 'B')
	   AND ZLF.ZLF_TP_MIX = 'F'
EndSql

Count To _nTotReg
(_cAliasPFM)->( DBGoTop() )
_oProces:SetRegua2(_nTotReg)

While !_lErro .And. (_cAliasPFM)->( !Eof() )
	_nCont++
	_oProces:IncRegua2( "Eventos Manuais - Tarefa ["+ StrZero(_nCont,6) +"] de ["+ StrZero(_nTotReg,6) +"]" )
	
	//====================================================================================================
	// Posiciona no cadastro de Eventos
	//====================================================================================================
	DBSelectArea("ZL8")
	ZL8->( DBGoTo( (_cAliasPFM)->REGZL8 ) )
	If ZL8->ZL8_MSBLQL <> '1'
		//====================================================================================================
		// Verifica se a condi��o do Evento eh satisfat�ria
		//====================================================================================================
		If &( ZL8->ZL8_CONDIC )
			//====================================================================================================
			// Busca o valor do Evento na ZLF e grava no t�tulo
			//====================================================================================================
			_nVlrEve := (_cAliasPFM)->TOTAL
			
			If _nVlrEve > 0
				If !_lErro .And. _nTipExe == 2
					//====================================================================================================
					// Pega a chave da ZLF de D�bito referente ao valor do evento lido
					//====================================================================================================
					_cSeekZLF:= MGLT011ZLF(_oProces,_cThread,ZL8->ZL8_COD,_nVlrEve,xFilial("ZLF")+ZL8->ZL8_PREFIX+_cNumTit+_cParc+"NDF"+_cFornece+_cLoja,.F.,.T.,(_cAliasPFM)->SEQ,_cMix,_cSetor,_cFornece,_cLoja,,@_lErro)
					
					//====================================================================================================
					// Inclui o t�tulo do Evento e realiza as baixas
					//====================================================================================================
					If !_lErro
						_cParc := MGLT011IE2( _oProces,_cThread,{ _nVlrEve , ZL8->ZL8_PREFIX , _cNumTit , _cParc , "NDF" , ZL8->ZL8_DESCRI , _cSeekZLF , ZL8->ZL8_NATFRT },,_dPgto,@_cParcel,_cMix,_cSetor,_cFornece,_cLoja,@_lErro)
					EndIf

					If !_lErro .And. (_nSldFrt - _nVlrEve) >= 0 
						MGLT011BE2(_oProces,_cThread,{_nVlrEve,ZL8->ZL8_PREFIX,_cNumTit,_cParc ,"NDF" ,ZL8->ZL8_PREFIX , _cSeekZLF },_cMix,_cFornece,_cLoja,_cHist,@_lErro)
						If !_lErro
							MGLT011BE2(_oProces,_cThread,{_nVlrEve,_cPrefixo      ,_cNum   ,_cXParc,_cTipo,''              , ''        },_cMix,_cFornece,_cLoja,_cHist,@_lErro)
						EndIf
						If !_lErro
							MGLT011AVL(_cSeekZLF,_nVlrEve)
						EndIf
						_cParc		:= SOMA1( _cParc )
						_nSldFrt	-= _nVlrEve
					ElseIf !_lErro .And. _nSldFrt > 0
						MGLT011BE2(_oProces,_cThread,{_nSldFrt,ZL8->ZL8_PREFIX,_cNumTit,_cParc ,"NDF" ,ZL8->ZL8_PREFIX,_cSeekZLF},_cMix,_cFornece,_cLoja,_cHist,@_lErro)
						If !_lErro
							MGLT011BE2(_oProces,_cThread,{_nSldFrt,_cPrefixo      ,_cNum   ,_cXParc,_cTipo,''             ,''       },_cMix,_cFornece,_cLoja,_cHist,@_lErro)
						EndIf
						If !_lErro
							MGLT011AVL(_cSeekZLF,_nSldFrt )
						EndIf
						_cParc		:= SOMA1( _cParc )
						_nSldFrt	:= 0
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	(_cAliasPFM)->( DbSkip() )
EndDo

(_cAliasPFM)->( DBCloseArea() )
RestArea( _aArea )

Return

/*
===============================================================================================================================
Programa----------: MGLT011PFE
Autor-------------: Alexandre Villar
Data da Criacao---: 14/04/2015
Descri��o---------: Rotina que processa o fechamento dos eventos avulsos dos Fretistas
Parametros--------: _oProces - Objeto de controle do processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011PFE(_oProces,_cThread,_nTipExe,_cNroTit,_cXParc,_cTipo,_dPgto,_cMix,_cSetor,_cFornece,_cLoja,_cPrefixo,_cNum,_cParcel,_nSldFrt,_cHist,_lErro)

Local _aArea	:= GetArea()
Local _nTotReg	:= 0
Local _cAliasPFE:= GetNextAlias()
Local _nCont	:= 0
Local _nVlrEve	:= 0
Local _cSeekZLF	:= ""
Local _cMyLinha	:= MGLT011PLF(_cMix,_cSetor,_cFornece,_cLoja) // Obtem linha do setor

//====================================================================================================
// Acerto de Eventos Avulsos
//====================================================================================================
BeginSql alias _cAliasPFE
	SELECT ZL8.R_E_C_N_O_ REGZL8
	  FROM %Table:ZL8% ZL8
	 WHERE ZL8.D_E_L_E_T_ = ' '
	   AND ZL8.ZL8_FILIAL = %xFilial:ZL8%
	   AND ((ZL8.ZL8_TPEVEN = 'A' AND ZL8.ZL8_PREFIX <> ' ') OR
	       ZL8.ZL8_TPEVEN = 'M')
	   AND ZL8.ZL8_DEBCRE = 'D'
	   AND ZL8.ZL8_PERTEN IN ('F', 'T')
	 ORDER BY ZL8.ZL8_PRIORI
EndSql

Count To _nTotReg
(_cAliasPFE)->( DBGoTop() )
_oProces:SetRegua2(_nTotReg)

While !_lErro .And. (_cAliasPFE)->( !Eof() )
	_nCont++
	_oProces:IncRegua2( "Eventos - Tarefa ["+ StrZero(_nCont,6) +" de "+ StrZero(_nTotReg,6) +"]" )
	
	//====================================================================================================
	// Posiciona no cadastro de Eventos
	//====================================================================================================
	ZL8->( DBGoTo( (_cAliasPFE)->REGZL8 ) )
	If ZL8->ZL8_MSBLQL <> '1'
		//====================================================================================================
		// Verifica se a condicao do Evento eh satisfat�ria
		//====================================================================================================
		If &( ZL8->ZL8_CONDIC )
			//====================================================================================================
			// Busca o valor a ser gravado no Evento e no titulo
			//====================================================================================================
			_nVlrEve := &( ZL8->ZL8_FORMUL )
			
			If _nVlrEve > 0
			
				//====================================================================================================
				// Caso o acerto tenha sido configurado como definitivo
				//====================================================================================================
				If !_lErro .And. _nTipExe == 2
					If ZL8->ZL8_TPEVEN == 'M'
						//====================================================================================================
						// Grava um registro na ZLF de Debito referente ao valor do evento para fins de demonstra��o
						//====================================================================================================
						_cSeekZLF := MGLT011ZLF(_oProces,_cThread,ZL8->ZL8_COD,_nVlrEve,,.F.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
						_nSldFrt -= _nVlrEve
					Else
						//====================================================================================================
						// Grava um registro na ZLF de Debito referente ao valor do evento lido
						//====================================================================================================
						_cSeekZLF := MGLT011ZLF(_oProces,_cThread,ZL8->ZL8_COD,_nVlrEve,xFILIAL("SE2")+ZL8->ZL8_PREFIX+_cNroTit+_cParcel+"NDF"+_cFornece+_cLoja,.F.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
						//====================================================================================================
						// Inclui o titulo relacionado ao evento lido
						//====================================================================================================
						If !_lErro
							_cParcTit := MGLT011IE2( _oProces,_cThread,{ _nVlrEve , ZL8->ZL8_PREFIX , _cNroTit , _cParcel , "NDF" , ZL8->ZL8_DESCRI , _cSeekZLF , ZL8->ZL8_NATFRT},.T.,_dPgto,@_cParcel,_cMix,_cSetor,_cFornece,_cLoja,@_lErro)
						EndIf
						
						If !_lErro .And. (_nSldFrt - _nVlrEve) >= 0
							MGLT011BE2(_oProces,_cThread,{_nVlrEve,ZL8->ZL8_PREFIX,_cNroTit,_cParcTit,"NDF" ,ZL8->ZL8_PREFIX,_cSeekZLF},_cMix,_cFornece,_cLoja,_cHist,@_lErro)
							
							If !_lErro
								MGLT011BE2(_oProces,_cThread,{_nVlrEve,_cPrefixo      ,_cNum   ,_cXParc  ,_cTipo,''             ,''       },_cMix,_cFornece,_cLoja,_cHist,@_lErro)
							EndIf
							//====================================================================================================
							// Grava o valor baixado na ZLF
							//====================================================================================================
							If !_lErro
								MGLT011AVL( _cSeekZLF , _nVlrEve )
							EndIf
							_cParcel := SOMA1( _cParcel )
							_nSldFrt -= _nVlrEve
							
						ElseIf !_lErro .And. _nSldFrt > 0
							MGLT011BE2(_oProces,_cThread,{_nSldFrt,ZL8->ZL8_PREFIX,_cNroTit,_cParcTit,"NDF",ZL8->ZL8_PREFIX,_cSeekZLF},_cMix,_cFornece,_cLoja,_cHist,@_lErro)
							If !_lErro
								MGLT011BE2(_oProces,_cThread,{_nSldFrt,_cPrefixo      ,_cNum   ,_cXParc  ,"NF ",''             ,''       },_cMix,_cFornece,_cLoja,_cHist,@_lErro)
		                	EndIf
		                	//====================================================================================================
							// Grava o valor baixado na ZLF (baixa parcial)
							//====================================================================================================
		                	If !_lErro
								MGLT011AVL( _cSeekZLF , _nSldFrt )
		                	EndIf

							_cParcTit	:= SOMA1( _cParcTit )
							_nSldFrt	:= 0
						EndIf
					EndIf
				ElseIf !_lErro
					//====================================================================================================
					// Grava um registro na ZLF de Debito referente ao valor do evento lido
					//====================================================================================================
					MGLT011ZLF(_oProces,_cThread,ZL8->ZL8_COD,_nVlrEve,"PREVISAO",.F.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
				EndIf
			EndIf
		EndIf
	EndIf
	
	(_cAliasPFE)->( DbSkip() )
EndDo

(_cAliasPFE)->( DBCloseArea() )
RestArea( _aArea )

Return

/*
===============================================================================================================================
Programa----------: MGLT011PFF
Autor-------------: Alexandre Villar
Data da Criacao---: 14/04/2015\
Descri��o---------: Rotina que processa o fechamento dos eventos Financeiros dos Fretistas
Parametros--------: _oProces - Objeto de controle do processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011PFF(_oProces,_cThread,_nTipExe,_cTipo,_dVencto,_cMix,_cSetor,_cFornece,_cLoja,_cHist,_cPrefixo,_cNum,_cXParc,_cTipo,_cParcel,_nSldFrt,_lErro)

Local _cAliasPFF:= GetNextAlias()
Local _cAliasPFT:= ""
Local _aArea	:= GetArea()
Local _nTotReg	:= 0
Local _nCont    := 0
Local _nSldTit  := 0
Local _nJurTit  := 0
Local _cSeekZLF := ""
Local _cMyLinha := MGLT011PLF(_cMix,_cSetor,_cFornece,_cLoja) // obtem linha do setor

//====================================================================================================
// Acerto Financeiro - Eventos
//====================================================================================================
BeginSql alias _cAliasPFF
	SELECT ZL8.ZL8_COD, ZL8.ZL8_DESCRI, ZL8.ZL8_PREFIX, ZL8.ZL8_SITUAC
	  FROM %Table:ZL8% ZL8
	 WHERE ZL8.D_E_L_E_T_ = ' '
	   AND ZL8.ZL8_FILIAL = %xFilial:ZL8%
	   AND ZL8.ZL8_TPEVEN = 'F'
	   AND ZL8.ZL8_DEBCRE = 'D'
	   AND ZL8.ZL8_PREFIX <> ' '
	   AND ZL8.ZL8_SITUAC <> ' '
	 ORDER BY ZL8.ZL8_PRIORI
EndSql

While (_cAliasPFF)->( !Eof() )
	
	//====================================================================================================
	// Cria tabela temporaria com os dados do SE2 filtrados a partir do prefixo informado no Evento(ZL8)
	// Acerto Financeiro - T�tulos
	//====================================================================================================
	_cAliasPFT:= GetNextAlias()

	BeginSql alias _cAliasPFT
		SELECT SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_SALDO,
		       SE2.E2_VENCTO, SE2.E2_NATUREZ, SE2.E2_MOEDA, SE2.E2_VALOR, SE2.E2_VALJUR, SE2.E2_PORCJUR, SE2.E2_EMISSAO,
		       SE2.E2_TXMOEDA, SE2.E2_BAIXA, SE2.E2_DECRESC, SE2.E2_ACRESC, SE2.R_E_C_N_O_ REGSE2
		  FROM %Table:SE2% SE2
		 WHERE SE2.D_E_L_E_T_ = ' '
		   AND SE2.E2_FILIAL = %xFilial:SE2%
		   AND SE2.E2_TIPO = 'NDF'
		   AND SE2.E2_SALDO > 0
		   AND SE2.E2_L_SETOR = %exp:_cSetor%
		   AND SE2.E2_PREFIXO = %exp:(_cAliasPFF)->ZL8_PREFIX%
		   AND SE2.E2_VENCTO <= %exp:_dVencto%
		   AND SE2.E2_FORNECE = %exp:_cFornece%
		   AND SE2.E2_LOJA = %exp:_cLoja%
		 ORDER BY SE2.E2_SALDO, SE2.E2_VENCTO
	EndSql

	Count To _nTotReg
	(_cAliasPFT)->( DBGoTop() )
	_oProces:SetRegua2( _nTotReg )
	_nCont := 0
	
	While !_lErro .And. (_cAliasPFT)->( !Eof() )
		
		_nCont++
		_oProces:IncRegua2( "Financeiro - Tarefa ["+ StrZero(_nCont,6)+"] de ["+ StrZero(_nTotReg,6) +"]" )
		
		SE2->( DBGoTo( (_cAliasPFT)->REGSE2 ) )
		
		_nSldTit := SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE)
		_nJurTit := FaJuros((_cAliasPFT)->E2_VALOR,(_cAliasPFT)->E2_SALDO,STOD((_cAliasPFT)->E2_VENCTO),(_cAliasPFT)->E2_VALJUR,(_cAliasPFT)->E2_PORCJUR,(_cAliasPFT)->E2_MOEDA,STOD((_cAliasPFT)->E2_EMISSAO),dDataBase,(_cAliasPFT)->E2_TXMOEDA,STOD((_cAliasPFT)->E2_BAIXA))
		
		//====================================================================================================
		// Valor a ser baixado no titulo
		//====================================================================================================
		_nSldTit := _nSldTit + _nJurTit
		
		//====================================================================================================
		// Se o saldo do Fretista for maior que zero, baixa os titulos no SE2
		//====================================================================================================
		If _nSldFrt > 0
		    
			//====================================================================================================
			// Verifica se tem saldo para baixar
			//====================================================================================================
			If ( _nSldFrt - _nSldTit ) >= 0
				If _nTipExe == 2
					_cSeekZLF := MGLT011ZLF(_oProces,_cThread,(_cAliasPFF)->ZL8_COD,_nSldTit,xFilial("SE2")+(_cAliasPFT)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+SA2->(A2_COD+A2_LOJA),.T.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
				Else
					_cSeekZLF := MGLT011ZLF(_oProces,_cThread,(_cAliasPFF)->ZL8_COD,_nSldTit,"PREVISAO",.T.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
				EndIf
				
				If !_lErro .And. _nTipExe == 2
					MGLT011BE2(_oProces,_cThread,{_nSldTit,(_cAliasPFT)->E2_PREFIXO,(_cAliasPFT)->E2_NUM,(_cAliasPFT)->E2_PARCELA,(_cAliasPFT)->E2_TIPO, (_cAliasPFF)->ZL8_PREFIX,_cSeekZLF},_cMix,_cFornece,_cLoja,_cHist,@_lErro)
					If !_lErro
						MGLT011BE2(_oProces,_cThread,{_nSldTit,_cPrefixo				  ,_cNum           	   ,_cXParc                 ,_cTipo           	  , ''                   ,''       },_cMix,_cFornece,_cLoja,_cHist,@_lErro)
					EndIf
				EndIf
			    
				//====================================================================================================
				// Descresce o saldo do Fretista
				//====================================================================================================
				_nSldFrt -= _nSldTit
			
			//====================================================================================================
			// Processa a baixa parcial quando n�o tiver saldo
			//====================================================================================================
			Else
				If !_lErro .And. _nTipExe == 2
					_cSeekZLF := MGLT011ZLF(_oProces,_cThread,(_cAliasPFF)->ZL8_COD,_nSldFrt,xFilial("SE2")+(_cAliasPFT)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+SA2->(A2_COD+A2_LOJA),.T.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
				ElseIf !_lErro
					_cSeekZLF := MGLT011ZLF(_oProces,_cThread,(_cAliasPFF)->ZL8_COD,_nSldTit,"PREVISAO",.T.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
				EndIf
				
				If !_lErro .And. _nTipExe == 2 .And. (_cAliasPFF)->ZL8_SITUAC == 'B'
				    
					//====================================================================================================
					// Baixa os titulos de convenio, emprestimo, adiantamentos e antecipacoes
					//====================================================================================================
					MGLT011BE2(_oProces,_cThread,{_nSldFrt,(_cAliasPFT)->E2_PREFIXO,(_cAliasPFT)->E2_NUM,(_cAliasPFT)->E2_PARCELA,(_cAliasPFT)->E2_TIPO,(_cAliasPFF)->ZL8_PREFIX,_cSeekZLF},_cMix,_cFornece,_cLoja,_cHist,@_lErro)
					If !_lErro
						MGLT011BE2(_oProces,_cThread,{_nSldFrt,_cPrefixo				  ,_cNum			   ,_cXParc  				,_cTipo				  ,''					   ,''    },_cMix,_cFornece,_cLoja,_cHist,@_lErro)
					EndIf

					//====================================================================================================
					// Grava o valor baixado na ZLF (baixa parcial)
					//====================================================================================================
                	If !_lErro
						MGLT011AVL( _cSeekZLF , _nSldFrt )
                	EndIf
					//====================================================================================================
					// Descresce o saldo do Fretista
					//====================================================================================================
					_nSldFrt := 0
					
				//====================================================================================================
				// Se o acerto eh definitivo e deve Deletar o titulo qdo na ha saldo suficiente para baixar
				//====================================================================================================
				ElseIf !_lErro .And. _nTipExe == 2 .And. (_cAliasPFF)->ZL8_SITUAC == 'D'
					MGLT011DE2(_oProces,_cThread,(_cAliasPFT)->E2_PREFIXO,(_cAliasPFT)->E2_NUM,(_cAliasPFT)->E2_PARCELA,(_cAliasPFT)->E2_TIPO,_cMix,_cFornece,_cLoja,@_lErro)
				EndIf
			EndIf
			
		//====================================================================================================
		// Se o saldo do Fretista esta zerado, NAO baixa os titulos no SE2
		//====================================================================================================
		Else
			If !_lErro .And. _nTipExe == 1
				MGLT011ZLF(_oProces,_cThread,(_cAliasPFF)->ZL8_COD,_nSldTit,"PREVISAO",.T.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
			Else
				_oProces:SaveLog("Thread:"+_cThread+" MGLT01126 - Aviso- Saldo insuficiente para fretista "+ _cFornece +"/"+ _cLoja)
				_lErro := !MsgYesNo("O saldo do Fretista "+ _cFornece +"/"+ _cLoja +" � insuficiente. Deseja continuar mesmo assim?","MGLT01126")
				If !_lErro .And. _nTipExe == 2
					MGLT011ZLF(_oProces,_cThread,(_cAliasPFF)->ZL8_COD,_nSldTit,xFilial("SE2")+(_cAliasPFT)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+SA2->(A2_COD+A2_LOJA),.T.,.F.,,_cMix,_cSetor,_cFornece,_cLoja,_cMyLinha,@_lErro)
				EndIf
				
			EndIf
			
			//====================================================================================================
			// Se o acerto eh definitivo e deve Deletar o titulo qdo na ha saldo suficiente para baixar
			//====================================================================================================
			If !_lErro .And. _nTipExe == 2 .And. (_cAliasPFF)->ZL8_SITUAC == 'D'
				MGLT011DE2(_oProces,_cThread,(_cAliasPFT)->E2_PREFIXO,(_cAliasPFT)->E2_NUM,(_cAliasPFT)->E2_PARCELA,(_cAliasPFT)->E2_TIPO,_cMix,_cFornece,_cLoja,@_lErro)
			EndIf
		EndIf
		
		(_cAliasPFT)->( DBSkip() )
	EndDo
	
	(_cAliasPFT)->( DBCloseArea() )
	(_cAliasPFF)->( DBSkip() )
EndDo

(_cAliasPFF)->( DBCloseArea() )
RestArea( _aArea )

Return

/*
===============================================================================================================================
Programa--------: MGLT011DE2
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina que exclui os t�tulos financeiros via ExecAuto
Parametros------: _oProces    - Objeto de controle do processamento
----------------: _cPrfAux - Prefixo do t�tulo
----------------: _cNroAux - N�mero do t�tulo
----------------: _cParAux - Parcela do t�tulo
----------------: _cTipAux - Tipo do t�tulo
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011DE2(_oProces,_cThread,_cPrxAux,_cNroAux,_cParAux,_cTipAux,_cMix,_cFornece,_cLoja,_lErro)

Local _cQuery	:= ""
Local _aAutSE2	:= {}
Local _nModAnt	:= nModulo
Local _cModAnt	:= cModulo
Local _nValor	:= 0
Local _cPrfCon	:= AllTrim(SuperGetMV("LT_CONVPRE",.F.,"GLC")) // Prefixo do titulo NF gerado pela rotina de convenio
Local _cChave	:= xFILIAL("SE2") + _cPrxAux + _cNroAux + _cParAux + _cTipAux + _cFornece + _cLoja
Local _cChvCon	:= xFILIAL("SE2") + _cPrfCon + SubStr( _cNroAux , 1 , 6 ) + "000" + "1" +"NF "+ _cFornece + _cLoja

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

//====================================================================================================
// Verifica se o T�tulo existe na Base
//====================================================================================================
SE2->( DBSetOrder(1) )
If SE2->( DBSeek( _cChave ) )
	
	//====================================================================================================
	// Monta os dados e chama a exclus�o do t�tulo via ExecAuto
	//====================================================================================================
	_nValor		:= SE2->E2_VALOR
	_aAutSE2	:= {	{ "E2_PREFIXO"	, SE2->E2_PREFIXO	, Nil },;
						{ "E2_NUM"		, SE2->E2_NUM		, Nil },;
						{ "E2_TIPO"		, SE2->E2_TIPO		, Nil },;
						{ "E2_PARCELA"	, SE2->E2_PARCELA	, Nil },;
						{ "E2_NATUREZ"	, SE2->E2_NATUREZ	, Nil },;
						{ "E2_FORNECE"	, _cFornece			, Nil },;
						{ "E2_LOJA"		, _cLoja			, Nil } }
	
	nModulo := 6
	cModulo := "FIN"
	
	MSExecAuto( {|x,y,z| Fina050(x,y,z) } , _aAutSE2 , .T. , 5 )
	
	nModulo := _nModAnt
	cModulo := _cModAnt
	
EndIf

If lMsErroAuto
	_lErro := .T.
	_oProces:SaveLog("Thread:"+_cThread+" MGLT01110 - Erro - Falha no ExecAuto de Exclus�o do T�tulo - "+ _cChave)
	MsgStop(	"O t�tulo ["+ _cChave + "] n�o foi excluido! "															+CRLF+;
				"Fretista: "+ _cFornece +"/"+ _cLoja +" - "+ SA2->A2_NOME												+CRLF+;
				"Verifique no financeiro se este titulo ja foi baixado ou o motivo pelo qual n�o pode ser exclu�do."	+CRLF+;
				"Ao confimar esta tela, ser� apresentada a tela que possui informa��es detalhadas do erro. Favor acionar o Suporte.","MGLT01110")
	
	Mostraerro()
Else

	//====================================================================================================
	// Atualiza o Status do conv�nio
	//====================================================================================================
	_cQuery := " UPDATE "+RetSqlName('ZLL') 
	_cQuery += " SET ZLL_STATUS = 'S' "
	_cQuery += " WHERE  D_E_L_E_T_ = ' ' "
	_cQuery += " AND ZLL_FILIAL = '" +xFilial("ZLL")+"' "
	_cQuery += " AND ZLL_COD = '"+ SubStr(_cNroAux,1,6)+"' "
	_cQuery += " AND ZLL_SEQ = '"+ SubStr(_cNroAux,7,3)+"' "
	_cQuery += " AND ZLL_RETIRO = '"+ _cFornece+"' "
	_cQuery += " AND ZLL_RETILJ = '"+ _cLoja+"' "
	
	If TCSqlExec(_cQuery) < 0
		_lErro := .T.
		_oProces:SaveLog("Thread:"+_cThread+" MGLT01111 - Erro - Falha na atualiza��o do Conv�nio ap�s exclus�o do T�tulo - "+ _cNroAux+_cFornece+_cLoja)
		MsgStop("N�o Conformidade ao executar o Update de gravacao do Status do Convenio! Favor acionar o Suporte." + CRLF + AllTrim(TCSQLError()),"MGLT01111")
	EndIf
	
	//====================================================================================================
	// Tratamento para subtrair do Titulo NF o valor do titulo NDF de convenio que foi deletado
	//====================================================================================================
	SE2->( DBSetOrder(1) )
	If SE2->( DBSeek( _cChvCon ) )
		If SE2->E2_SALDO == SE2->E2_VALOR
			_nValor := SE2->E2_VALOR - _nValor
			
			SE2->(RecLock( "SE2" , .F. ))
			SE2->E2_VALOR  := _nValor
			SE2->E2_SALDO  := _nValor
			SE2->E2_VLCRUZ := _nValor
			SE2->( MsUnlock() )
		Else
			_lErro := .T.
			_oProces:SaveLog("Thread:"+_cThread+" MGLT01112 - Erro - T�tulo do Conv�nio j� possui baixas - "+ _cChvCon)
			MsgStop("O t�tulo da NF do Conv�nio j� foi baixado! Favor acionar o Suporte. T�tulo: "+ _cChvCon,"MGLT01112")
		EndIf
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa--------: MGLT011IE2
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina que inclui os t�tulos financeiros via ExecAuto
Parametros------: _oProces    - Objeto de controle do processamento
----------------: _aDados  - Dados do t�tulo a ser inclu�do
----------------: _lAtuZLF - Indica se deve atualizar o Seek da ZLF por causa da altera��o da parcela
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011IE2(_oProces,_cThread,_aDados,_lAtuZLF,_dPgto,_cParcel,_cMix,_cSetor,_cFornece,_cLoja,_lErro)

Local _nModAnt  := nModulo
Local _cModAnt  := cModulo
Local _aAutSE2	:= {}
Local _lNExist	:= .T.
Local _lVer		:= .T.
Local _cChave	:= xFilial("SE2") + _aDados[02] + _aDados[03] + _aDados[04] + _aDados[05] + _cFornece + _cLoja
Local _cNature	:= ""
Default _lAtuZLF := .F.
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

//====================================================================================================
// Verifica se o titulo ja existe na base, para nao duplicar
//====================================================================================================
SE2->( DBSetOrder(1) )
If SE2->( DBSeek( _cChave ) )
	_lErro		:= .T.
	_lNExist	:= .F.
	_lVer		:= .T.
	
	While _lVer
		If SE2->( DBSeek( xFILIAL("SE2") + _aDados[02] + _aDados[03] + _aDados[04] + _aDados[05] + _cFornece + _cLoja ) )
			_aDados[04] := Soma1( _aDados[04] )
		Else
			_lVer := .F.
			//Se a parcela for atualizada, tenho que ajustar informa��o j� gravada na ZLF, buscando pela parcela antiga
			//O registro j� est� posicionado pois a �ltima opera��o foi sua inclus�o.
			//Para situa��es onde n�o gero a ZLF, n�o preciso atualizar
			If _lAtuZLF
				If AllTrim(ZLF->ZLF_L_SEEK) ==xFILIAL("SE2") + _aDados[02] + _aDados[03] + _cParcel + _aDados[05] + _cFornece + _cLoja
					RecLock( "ZLF" , .F. )
					ZLF->ZLF_L_SEEK := xFILIAL("SE2") + _aDados[02] + _aDados[03] + _aDados[04] + _aDados[05] + _cFornece + _cLoja
					ZLF->( MsUnlock() )
					_lErro		:= .F.
					_lNExist	:= .T.
				Else
					_oProces:SaveLog("Thread:"+_cThread+" MGLT01123 - Erro - Tentativa de atualizar ZLF_L_SEEK para corrigir Parcela - "+ _aDados[07] )
					MsgStop("N�o foi poss�vel atualizar o campo ZLF_L_SEEK com a nova parcela gerada: "+ _aDados[04]+;
							". Favor acionar o Suporte. Chave ZLF a ser atualizada: "+_aDados[07],"MGLT01123")
					_lErro		:= .T.
					_lNExist	:= .F.
				EndIf
			Else
				_lErro		:= .F.
				_lNExist	:= .T.
			EndIf				
		EndIf
	EndDo
	_cParcel	:= _aDados[04]		
	_cChave		:= xFilial("SE2") + _aDados[02] + _aDados[03] + _aDados[04] + _aDados[05] + _cFornece + _cLoja
EndIf

//====================================================================================================
// Processamento da inclus�o
//====================================================================================================
If _lNExist

	//====================================================================================================
	// Verifica a Natureza para os titulos de Fretistas
	//====================================================================================================
	If Empty( _aDados[08] )
		_cNature := AllTrim(SuperGetMV("LT_NATGLF",.F.,"222038"))
	Else
		_cNature := _aDados[08]
	EndIf
	
	//====================================================================================================
	// Monta os dados para gerar o t�tulo e chama o ExecAuto
	//====================================================================================================
	_aAutSE2 := {	{ "E2_PREFIXO"	, _aDados[02]		, Nil },;
					{ "E2_NUM"		, _aDados[03]		, Nil },;
					{ "E2_TIPO"		, _aDados[05]		, Nil },;
					{ "E2_PARCELA"	, _aDados[04]		, Nil },;
					{ "E2_NATUREZ"	, _cNature			, Nil },;
					{ "E2_FORNECE"	, _cFornece			, Nil },;
					{ "E2_LOJA"		, _cLoja			, Nil },;
					{ "E2_EMISSAO"	, dDataBase			, Nil },;
					{ "E2_VENCTO"	, _dPgto			, Nil },;
					{ "E2_VENCREA"	, _dPgto			, Nil },;
					{ "E2_HIST"		, _aDados[06]		, Nil },;
					{ "E2_VALOR"	, _aDados[01]		, Nil },;
					{ "E2_PORCJUR"	, 0					, Nil },;
					{ "E2_DATALIB"	, dDataBase			, Nil },;
					{ "E2_USUALIB"	, cUserName			, Nil },;
					{ "E2_L_LINRO"	, ""				, Nil },;
					{ "E2_L_SETOR"	, _cSetor			, Nil },;
					{ "E2_L_MIX"	, _cMix				, Nil },;
					{ "E2_L_TPPAG"	, SA2->A2_L_TPPAG	, Nil },;
					{ "E2_L_SITUA"	, "I"				, Nil },;
					{ "E2_L_SEEK"	, _aDados[07]		, Nil },;
					{ "E2_ORIGEM"	, "MGLT011"			, Nil },;
					{ "E2_L_BANCO"	, SA2->A2_BANCO		, Nil },;
					{ "E2_L_AGENC"	, SA2->A2_AGENCIA	, Nil },;
					{ "E2_L_CONTA"	, SA2->A2_NUMCON	, Nil }}
	
	nModulo := 6
	cModulo := "FIN"
	
	MSExecAuto( {|x,y| Fina050( x , y ) } , _aAutSE2 , 3 )
	
	//====================================================================================================
	// Verifica se o t�tulo foi gerado corretamente e atualiza os dados banc�rios
	//====================================================================================================
	If lMsErroAuto
		_lErro := .T.
		_oProces:SaveLog("Thread:"+_cThread+" MGLT01125 - Erro - Falha no ExecAuto de inclus�o do t�tulo - "+ _cChave)
		MsgStop("Falha no ExecAuto de inclus�o do t�tulo - "+ _cChave+". Favor acionar o Suporte.","MGLT01125")
		Mostraerro()
	EndIf
	
	nModulo := _nModAnt
	cModulo := _cModAnt
	
EndIf

Return( _aDados[04] )

/*
===============================================================================================================================
Programa--------: MGLT011BE2
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina que processa a baixa dos t�tulos financeiros via ExecAuto
Parametros------: _oProces    - Objeto de controle do processamento
----------------: _aDados  - Dados do t�tulo a ser inclu�do
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011BE2(_oProces,_cThread,_aDados,_cMix,_cFornece,_cLoja,_cHist,_lErro)

Local _cQuery	:= ""
Local _nModAnt	:= nModulo
Local _cMotBxa	:= AllTrim(SuperGetMV("LT_MOTBX",.F.,"GLT"))
Local _cModAnt	:= cModulo
Local _cOrigem	:= ""
Local _aTitSE2	:= {}
Local _cChave	:= xFILIAL("SE2") + _aDados[02] + _aDados[03] + _aDados[04] + _aDados[05] + _cFornece + _cLoja

Private lMsErroAuto:= .F.
Private lMsHelpAuto:= .T.

//====================================================================================================
// Verifica se o t�tulo existe na base de dados
//====================================================================================================
SE2->( DBSetOrder(1) )
If SE2->( DBSeek( _cChave ) )
	_cOrigem := SE2->E2_ORIGEM
	//====================================================================================================
	// Verifica e libera o t�tulo para permitir a baixa
	//====================================================================================================
	If Empty(SE2->E2_DATALIB)
		SE2->(RecLock( "SE2" , .F. ))
		SE2->E2_DATALIB := dDataBase
		SE2->E2_USUALIB := cUserName
		SE2->( MsUnLock() )
	EndIf
	
	//====================================================================================================
	// Prepara os dados e chama o ExecAuto para processar a baixa
	//====================================================================================================
	_aTitSE2 := {	{ "E2_PREFIXO"		, _aDados[02]							, Nil },;
					{ "E2_NUM"			, _aDados[03]							, Nil },;
					{ "E2_PARCELA"		, _aDados[04]							, Nil },;
					{ "E2_TIPO"			, _aDados[05]							, Nil },;
					{ "E2_FORNECE"		, _cFornece								, Nil },;
					{ "E2_LOJA"			, _cLoja								, Nil },;
					{ "AUTBANCO"		, ""									, Nil },;
					{ "AUTAGENCIA"		, ""									, Nil },;
					{ "AUTCONTA"		, ""									, Nil },;
					{ "AUTCHEQUE"		, ""									, Nil },;
					{ "AUTMOTBX"		, _cMotBxa								, Nil },;
					{ "AUTDTBAIXA"		, dDataBase								, Nil },;
					{ "AUTDTCREDITO"	, dDataBase								, Nil },;
					{ "AUTBENEF"		, _cFornece +" - "+ ALLTRIM(SA2->A2_NOME), Nil },;
					{ "AUTHIST"			, _cHist								, Nil },;
					{ "AUTVLRPG"		, _aDados[01]							, Nil } }
	
	nModulo := 6
	cModulo := "FIN"
	
	MSExecAuto( {|x,y| Fina080(x,y)} , _aTitSE2 , 3 )
	
	nModulo := _nModAnt
	cModulo := _cModAnt
	
	If lMsErroAuto
		_lErro := .T.
		_oProces:SaveLog("Thread:"+_cThread+" MGLT01114 - Erro - Falha no ExecAuto de baixa do t�tulo - "+ _cChave)
		MsgStop("Existe uma n�o conformidade no ExecAuto de Baixa de Contas a Pagar! T�tulo: "+ _cChave +;
				" Verifique o T�tulo no Contas a Pagar! Ap�s confirmar esta tela ser� exibido o detalhe do erro. Favor acionar o Suporte.","MGLT01114")
		MostraErro()
	Else
	
		//====================================================================================================
		// Grava o codigo do MIX no t�tulo do Contas a Pagar
		//====================================================================================================
		_cQuery := " UPDATE "+RetSqlName("SE2")
		_cQuery += " SET E2_L_MIX = '"+_cMix+"' "
		If !Empty( _aDados[07] )
			_cQuery += ", E2_L_SEEK = '"+_aDados[07]+"' "
		EndIf
		_cQuery += " WHERE D_E_L_E_T_ =' ' "
		_cQuery += " AND E2_FILIAL ='"+xFilial("SE2")+"' "
		_cQuery += " AND E2_PREFIXO = '"+_aDados[02]+"' "
		_cQuery += " AND E2_NUM = '"+_aDados[03]+"' "
		_cQuery += " AND E2_PARCELA = '"+_aDados[04]+"' "
		_cQuery += " AND E2_TIPO = '"+_aDados[05]+"' "
		_cQuery += " AND E2_FORNECE = '"+_cFornece+"' "
		_cQuery += " AND E2_LOJA = '"+_cLoja+"' "
		
		If TCSqlExec(_cQuery) < 0
			_lErro := .T.
			_oProces:SaveLog("Thread:"+_cThread+" MGLT01115 - Erro - Falha no Update de dados do MIX no T�tulo - "+ _cChave )
			MsgStop("Existe uma n�o conformidade na atualiza��o dos dados do MIX no T�tulo Financeiro! T�tulo: "+ _cChave +;
					" Favor acionar o Suporte." + CRLF + AllTrim(TCSQLError()),"MGLT01116")
		EndIf
		
		//====================================================================================================
		// Atualiza dados de Conv�nio
		//====================================================================================================
		If Upper( AllTrim( _cOrigem ) ) == "AGLT010"
			_cQuery := " UPDATE "+ RetSqlName("ZLL") +" ZLL SET ZLL_STATUS = 'P' "
			_cQuery += " WHERE D_E_L_E_T_ = ' ' "
			_cQuery += " AND ZLL_FILIAL = '"+xFilial("ZLL")+"' "
			_cQuery += " AND ZLL_COD = '"+SubStr(_aDados[03],1,6 )+"' "
			_cQuery += " AND ZLL_SEQ = '"+SubStr(_aDados[03],7,3 )+"' "
			_cQuery += " AND ZLL_RETIRO = '"+ _cFornece+"' "
			_cQuery += " AND ZLL_RETILJ = '"+_cLoja+"' "
			
			If TCSqlExec(_cQuery) < 0
				_lErro := .T.
				_oProces:SaveLog("Thread:"+_cThread+" MGLT01117 - Erro - Falha na atualiza��o do Conv�nio - "+SubStr(_aDados[03],1,6 )+"/"+SubStr(_aDados[03],7,3 )+"/"+_cFornece+"/"+_cLoja )
				MsgStop("Existe uma n�o conformidade na atualiza��o do Status do Conv�nio! Chave: "+SubStr(_aDados[03],1,6 )+"/"+;
						SubStr(_aDados[03],7,3 )+"/"+_cFornece+"/"+_cLoja + " Favor acionar o Suporte." + CRLF + AllTrim(TCSQLError()),"MGLT01117")
			EndIf
		EndIf
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa--------: MGLT011ZLF
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina que inclui registros de processamento na ZLF
Parametros------: _cEvento - C�digo do Evento do registro
----------------: _nValor  - Valor do registro
----------------: _cSeek   - Chave auxiliar para grava��o no registro
----------------: _lGrvZLF - vari�vel de controle de grava��o
----------------: _cLinha  - C�digo da linha do Setor
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011ZLF(_oProces,_cThread,_cEvento,_nValor,_cSeek,_lGrvZLF,_lAltZLF,_cSeq,_cMix,_cSetor,_cFornece,_cLoja,_cLinha,_lErro)

Local _aDadZLF  := {}
Local _cRet     := ''
Local _lAchou   := .F.
Local _lNovo    := .T.
Local _cMenAux	:= ''
Default _cSeq	:= MGLT011ULT(_cMix,_cFornece,_cLoja,_cSetor)
Default _cSeek	:= ''
Default _lAltZLF	:= .F.

ZL8->( DBSetOrder(1) ) // ZL8_FILIAL + ZL8_COD
ZL8->( DBSeek( xFILIAL("ZL8") + _cEvento ) )

//====================================================================================================
// Se altera a ZLF. Usado quando o Evento foi lancado na ZLF.
//====================================================================================================
If _lAltZLF
	//====================================================================================================
	// Posiciona na ZLF para alterar o campo ZLF_L_SEEK do registro.
	//====================================================================================================
	_cUpdate := " UPDATE "+ RETSQLNAME('ZLF') +" ZLF SET ZLF.ZLF_L_SEEK = '"+ _cSeek +"' "
	_cUpdate += " WHERE  "+ RETSQLCOND('ZLF')
	_cUpdate += " AND ZLF.ZLF_CODZLE = '"+ _cMix +"' "
	_cUpdate += " AND ZLF.ZLF_A2COD  = '"+ _cFornece +"' "
	_cUpdate += " AND ZLF.ZLF_A2LOJA = '"+ _cLoja +"' "
	_cUpdate += " AND ZLF.ZLF_EVENTO = '"+ _cEvento +"' "
	_cUpdate += " AND ZLF.ZLF_SETOR = '"+ _cSetor +"' "
	_cUpdate += " AND ZLF.ZLF_SEQ    = '"+ _cSeq    +"' "
	
	_lGera := !( TCSqlExec(_cUpdate) < 0 )
	
	If _lGera // ZLF->( ZLF_FILIAL + ZLF_CODZLE + ZLF_VERSAO + ZLF_A2COD + ZLF_A2LOJA + ZLF_EVENTO + ZLF_SEQ )
		_cRet := xFilial('ZLF') + _cMix + "1" + _cFornece + _cLoja + _cEvento + _cSeq
	EndIf
Else
	//====================================================================================================
	// Posiciona na ZLF para verificar se ja existe um registro para o mesmo evento. Se existir e a 
	// variavel lGrvZLF estiver como .T., ele grava um novo registro para o mesmo evento.
	//====================================================================================================
	DBSelectArea("ZLF")
	ZLF->( DBSetOrder(3) )
	_lAchou := ZLF->( DBSeek( xFILIAL("ZLF") + _cMix + "1" + _cSetor + _cLinha + _cEvento + _cFornece + _cLoja ) )
	If _lAchou .And. !_lGrvZLF
		_lNovo := .F.//N�o grava ZLF. Apenas usa o que est� posicionado. V�lido apenas para o �ndice 3
	EndIf
	If !_lAchou
		ZLF->( DbSetOrder(8) )
		_lAchou := ZLF->( DBSeek( xFILIAL("ZLF") + _cMix + "1" + _cSetor + _cLinha + _cFornece + _cLoja ) )	
	EndIf
	//Se posicionou pelo �ndice 3 e era para gravar (_lGrvZLF=.T.), grava. Se posicinou mas n�o � para gravar, n�o faz nada.
	//O posicionamento ser� usado apenas para montar a chave a ser referenciada no futuro
	If _lAchou .And. _lNovo 
		_aDadZLF := {	{ 'ZLF_FILIAL'	, xFilial("ZLF")										} ,;
						{ 'ZLF_CODZLE'	, ZLF->ZLF_CODZLE										} ,;
						{ 'ZLF_VERSAO'	, ZLF->ZLF_VERSAO										} ,;
						{ 'ZLF_DTINI'	, ZLF->ZLF_DTINI										} ,;
						{ 'ZLF_DTFIM'	, ZLF->ZLF_DTFIM										} ,;
						{ 'ZLF_SETOR'	, IIF( Empty(_cSetor) , ZLF->ZLF_SETOR  , _cSetor  )	} ,;
						{ 'ZLF_LINROT'	, IIF( Empty(_cLinha) , ZLF->ZLF_LINROT , _cLinha  )	} ,;
						{ 'ZLF_A2COD'	, ZLF->ZLF_A2COD										} ,;
						{ 'ZLF_A2LOJA'	, ZLF->ZLF_A2LOJA										} ,;
						{ 'ZLF_EVENTO'	, _cEvento												} ,;
						{ 'ZLF_SEQ'		, _cSeq													} ,;
						{ 'ZLF_DEBCRE'	, 'D'   												} ,;
						{ 'ZLF_TOTAL'	, _nValor												} ,;
						{ 'ZLF_VLRPAG'	, ZLF->ZLF_VLRPAG      									} ,;
						{ 'ZLF_ORIGEM'	, 'F'													} ,;
						{ 'ZLF_RETIRO'	, ZLF->ZLF_RETIRO										} ,;
						{ 'ZLF_RETILJ'	, ZLF->ZLF_RETILJ										} ,;
						{ 'ZLF_ACERTO'	, ZLF->ZLF_ACERTO										} ,;
						{ 'ZLF_TP_MIX'	, ZLF->ZLF_TP_MIX										} ,;
						{ 'ZLF_TIPO'	, ZLF->ZLF_TIPO											} ,;
						{ 'ZLF_ENTMIX'	, ZL8->ZL8_MIX											} ,;
						{ 'ZLF_STATUS'	, ZLF->ZLF_STATUS										} ,;
						{ 'ZLF_L_SEEK'	, _cSeek												} ,;
						{ 'ZLF_EST'		, ZLF->ZLF_EST											} ,;
						{ 'ZLF_MUN'		, ZLF->ZLF_MUN											} ,;
						{ 'ZLF_F1SEEK'	, ZLF->ZLF_F1SEEK										} ,;
						{ 'ZLF_DTCALC'	, ZLF->ZLF_DTCALC										} ,;
						{ 'ZLF_DTFECH'	, ZLF->ZLF_DTFECH										}  }
	ElseIf !_lAchou //Se n�o posicinou pelo �ndice 3 ou 8, retorna erro
		_lErro := .T.
		_cMenAux := _cFornece +';'+ _cLoja +';'+ _cSetor +';'+ _cLinha +';Gera��o dos Itens do MIX;N�o foram encontrados registros do Fretista no MIX ['+ _cCodMix +']!'
		_oProces:SaveLog("Thread:"+_cThread+" MGLT01118 - " + _cMenAux)
		MsgStop("Existe uma n�o conformidade na grava��o no Lan�amento de Eventos! Fretista: "+ _cFornece +"/"+_cLoja +" n�o encontrado no MIX!"+;
				"N�o ser�o gerados eventos do MIX para esse fretista! Favor acionar o Suporte.","MGLT01118")
	EndIf

	If !_lErro
		If !Empty( _aDadZLF )
			RecLock("ZLF" , .T. )
				ZLF->ZLF_FILIAL := _aDadZLF[01][02] // xFilial("ZLF")
				ZLF->ZLF_CODZLE := _aDadZLF[02][02] // ZLF->ZLF_CODZLE
				ZLF->ZLF_VERSAO := _aDadZLF[03][02] // ZLF->ZLF_VERSAO
				ZLF->ZLF_DTINI  := _aDadZLF[04][02] // ZLF->ZLF_DTINI
				ZLF->ZLF_DTFIM  := _aDadZLF[05][02] // ZLF->ZLF_DTFIM
				ZLF->ZLF_SETOR  := _aDadZLF[06][02] // IIF( Empty(_cSetor) , ZLF->ZLF_SETOR  , _cSetor  )
				ZLF->ZLF_LINROT := _aDadZLF[07][02] // IIF( Empty(_cLinha) , ZLF->ZLF_LINROT , _cLinha  )
				ZLF->ZLF_A2COD  := _aDadZLF[08][02] // ZLF->ZLF_A2COD
				ZLF->ZLF_A2LOJA := _aDadZLF[09][02] // ZLF->ZLF_A2LOJA
				ZLF->ZLF_EVENTO := _aDadZLF[10][02] // ZL8->ZL8_COD
				ZLF->ZLF_SEQ    := _aDadZLF[11][02] // _cSeq
				ZLF->ZLF_DEBCRE := _aDadZLF[12][02] // 'D'
				ZLF->ZLF_TOTAL  := _aDadZLF[13][02] // _nValor
				ZLF->ZLF_VLRPAG := _aDadZLF[14][02] // 0
				ZLF->ZLF_ORIGEM := _aDadZLF[15][02] // 'F'
				ZLF->ZLF_RETIRO := _aDadZLF[16][02] // ZLF->ZLF_RETIRO
				ZLF->ZLF_RETILJ := _aDadZLF[17][02] // ZLF->ZLF_RETILJ
				ZLF->ZLF_ACERTO := _aDadZLF[18][02] // ZLF->ZLF_ACERTO
				ZLF->ZLF_TP_MIX := _aDadZLF[19][02] // ZLF->ZLF_TP_MIX
				ZLF->ZLF_TIPO   := _aDadZLF[20][02] // ZLF->ZLF_TIPO
				ZLF->ZLF_ENTMIX := _aDadZLF[21][02] // ZL8->ZL8_MIX
				ZLF->ZLF_STATUS := _aDadZLF[22][02] // ZLF->ZLF_STATUS
				ZLF->ZLF_L_SEEK := _aDadZLF[23][02] // _cSeek
				ZLF->ZLF_EST    := _aDadZLF[24][02] // ZLF->ZLF_EST
				ZLF->ZLF_MUN    := _aDadZLF[25][02] // ZLF->ZLF_MUN
				ZLF->ZLF_F1SEEK := _aDadZLF[26][02] // ZLF->ZLF_F1SEEK
				ZLF->ZLF_DTCALC	:= _aDadZLF[27][02] //ZLF->ZLF_DTCALC
				ZLF->ZLF_DTFECH := _aDadZLF[28][02] // ZLF->ZLF_DTFECH
			ZLF->( MsUnlock() )
		EndIf
		_cRet := ZLF->(ZLF_FILIAL+ZLF_CODZLE+ZLF_VERSAO+ZLF_A2COD+ZLF_A2LOJA+ZLF_EVENTO+ZLF_SEQ)
	EndIf
EndIf

Return(_cRet)

/*
===============================================================================================================================
Programa--------: MGLT011ULT
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina que retorna a �ltima chave utilizada na ZLF para novos cadastros
Parametros------: Nenhum
Retorno---------: _cSeq - Retorna o �ltimo c�digo utilizado na ZLF
===============================================================================================================================
*/
Static Function MGLT011ULT(_cMix,_cFornece,_cLoja,_cSetor)

Local _cSeq		:= ''
Local _cAlias	:= GetNextAlias()

BeginSQL Alias _cAlias
	SELECT MAX(ZLF_SEQ) COD
	FROM %Table:ZLF%
	WHERE D_E_L_E_T_ =' '
	AND ZLF_FILIAL = %xFilial:ZLF%
	AND ZLF_CODZLE = %exp:_cMix%
	AND ZLF_A2COD = %exp:_cFornece%
	AND ZLF_A2LOJA = %exp:_cLoja%
	AND ZLF_SETOR = %exp:_cSetor%
EndSQL

If (_cAlias)->(!Eof()) .And. !Empty( (_cAlias)->COD )
	_cSeq := SOMA1( (_cAlias)->COD )
EndIf

(_cAlias)->(DBCloseArea())

Return(_cSeq)

/*
===============================================================================================================================
Programa----------: MGLT011CTE
Autor-------------: Alexandre Villar
Data da Criacao---: 14/04/2015
Descri��o---------: Monta lista para sele��o de t�tulos existentes no financeiro do fretista corrente
Parametros--------: _cCod	:= C�digo do Fornecedor
------------------: _cLoja	:= Loja do Fornecedor
Retorno-----------: _nValCTE:= Valor do CTe
===============================================================================================================================
*/
Static Function MGLT011CTE(_cFornece,_cLoja,_lFilCTe,_cPrefixo,_cNum,_cXParc,_nSldFrt,_dVencto,_cTipo,_cMix,_cSetor)

Local _cAlias		:= GetNextAlias()
Local _cFiltro		:= '%'
Local _cTxtAux		:= ''
Local _aHeader		:= {}
Local _aDados		:= {}
Local _nItem		:= 0
Local _nI			:= 0
Local _nValCTE		:= 0
Local _oButton2		:= Nil
Local _oGroup1		:= Nil
Local _oSay1		:= Nil
Local _oSay2		:= Nil
Local _oDlgCTE 		:= Nil

Private _oGetFil	:= Nil
Private _cGetFil	:= Space(100)

//====================================================================================================
// Verifica somente no primeiro Trasnportador do fechamento da Filial corrente
//====================================================================================================
If !_lFilCTe
	
	_cTxtAux := "Favor informar uma ou mais filiais diferentes da filial corrente onde se deseja selecionar os t�tulos de CTe gerados para as transportadoras desta Filial. "
	_cTxtAux += "A filial corrente ja esta sendo considerada, caso n�o necessite deste recurso apenas clique em fechar."
	
	DEFINE MSDIALOG _oDlgCTE TITLE "Filiais - T�tulos CTe" FROM 000, 000  TO 220, 400 COLORS 0, 16777215 PIXEL
		@010,008 GROUP	_oGroup1 TO 061, 190 PROMPT	"Informa��o CTe" 					OF _oDlgCTE PIXEL COLOR  0, 16777215
		@020,019 SAY	_oSay1				PROMPT	_cTxtAux			SIZE 160,037	OF _oDlgCTE PIXEL COLORS 0, 16777215
		@072,046 MSGET	_oGetFil VAR _cGetFil							SIZE 146,008	OF _oDlgCTE PIXEL F3 "SM0001"
		@072,014 SAY	_oSay2				PROMPT	"Filial(is):"		SIZE 025,007	OF _oDlgCTE PIXEL COLORS 0, 16777215
		@090,085 BUTTON	_oButton2			PROMPT	"Fechar"			SIZE 045,016	OF _oDlgCTE PIXEL ACTION _oDlgCTE:End()
	ACTIVATE MSDIALOG _oDlgCTE CENTERED
	
	_lFilCTe := .T.
	
	_cFiltro += " AND E2_VALOR + E2_ISS = "+ cValtoChar( _nSldFrt )
	//====================================================================================================
	// Caso o usuario tenha fornecido uma ou varias filiais
	//====================================================================================================
	If Len( AllTrim(_cGetFil) ) > 1
		_cFiltro += " AND E2_FILIAL IN "+ FormatIn( ( AllTrim(_cGetFil) + ";" + cFilAnt ) , ";" )
	//====================================================================================================
	// Caso ele nao tenha fornecido filiais
	//====================================================================================================
	Else
		_cFiltro += " AND E2_FILIAL = '"+ cFilAnt +"' "
	EndIf
	_cFiltro += " %"
EndIf

//====================================================================================================
// Consulta os t�tulos de CTe na base
//====================================================================================================
BeginSQL Alias _cAlias
	SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_LOJA, E2_VALOR, E2_ISS, E2_FORNECE, E2_LOJA, E2_EMISSAO
	FROM %Table:SE2%
	WHERE D_E_L_E_T_ =' '
	%exp:_cFiltro%
	AND E2_FORNECE = %exp:_cFornece%
	AND E2_LOJA = %exp:_cLoja%
	AND E2_TIPO = %exp:_cTipo%
	AND E2_VENCTO  <= %exp:_dVencto%
	AND E2_ORIGEM = 'MATA100'
	AND E2_VALOR > 0
	AND E2_SALDO > 0
	ORDER BY E2_FILIAL,E2_EMISSAO DESC 
EndSQL

_nItem := 0

While (_cAlias)->( !EoF() )
	_nItem++
	aAdd( _aDados , {	.F.							,;
						(_cAlias)->E2_FILIAL		,;
						_nItem						,;
						(_cAlias)->E2_PREFIXO		,;
						(_cAlias)->E2_NUM			,;
						(_cAlias)->E2_PARCELA		,;
						(_cAlias)->E2_TIPO			,;
						StoD((_cAlias)->E2_EMISSAO)	,;
						Transform( (_cAlias)->E2_VALOR , PesqPict("SE2","E2_VALOR") ),;
						Transform( (_cAlias)->E2_ISS , PesqPict("SE2","E2_ISS") )})
	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

If Len(_aDados) > 0
	//====================================================================================================
	// Monta tela de Selecao do CTE
	//====================================================================================================
	_aHeader := { ' ' , 'Filial' , 'Item' , 'Prefixo' , 'N�mero' , 'Parcela' , 'Tipo' , 'Emiss�o' , 'Valor', 'ISS' }
	
	If Len(_aDados) > 1
		_lConfirm := U_ITListBox( 'Selec�o de CTE' , _aHeader , @_aDados , .F. , 2 , "Fretista: "+ _cFornece +"-"+ _cLoja +"-"+ left(SA2->A2_NOME,20) +" - "+ TRANSFORM(_nSldFrt,"@E 999,999,999.99") , .T. )
	Else
		_aDados[01][01]	:= .T.
		_lConfirm		:= .T.
	EndIf
	
	If _lConfirm
		For _nI := 1 To Len(_aDados)
			If _aDados[_nI][01]
				SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If SE2->( DBSeek( _aDados[_nI][02] + _aDados[_nI][04] + _aDados[_nI][05] + _aDados[_nI][06] + _aDados[_nI][07] + _cFornece + _cLoja ) )
					_cNum		:= SE2->E2_NUM
					_cPrefixo	:= SE2->E2_PREFIXO
					_cXParc		:= SE2->E2_PARCELA
					_nValCTE	:= SE2->E2_VALOR + SE2->E2_ISS
					_nValISS	:= SE2->E2_ISS
					
					//====================================================================================================
					// Verifica se o t�tulo selecionado tem o mesmo saldo do total a pagar ao transportador
					//====================================================================================================
					If _nValCTE == _nSldFrt
						RecLock( "SE2" , .F. )
						SE2->E2_L_MIX   := _cMix
						SE2->E2_L_SETOR := _cSetor
						SE2->E2_L_BANCO := SA2->A2_BANCO
						SE2->E2_L_AGENC := SA2->A2_AGENCIA
						SE2->E2_L_CONTA := SA2->A2_NUMCON
						SE2->E2_DATALIB := dDataBase
						SE2->E2_USUALIB := cUserName
						SE2->( MsUnlock() )
						Exit
					EndIf
				EndIf
			EndIf
		Next _nI
	EndIf
EndIf

Return( _nValCTE )

/*
===============================================================================================================================
Programa--------: MGLT011PLF
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina que retorna uma linha na qual o fretista tenha registro de entrega
Parametros------: _cMix - C�digo do Mix
----------------: _cSetor  - Setor para consultar
----------------: _cFornec - C�digo do Fornecedor para consultar
----------------: _cLoja   - Loja do Fornecedor para consultar
Retorno---------: _cRet	:= Retorna linha que o fretista tem registro
===============================================================================================================================
*/
Static Function MGLT011PLF(_cMix,_cSetor,_cFornece,_cLoja)

Local _cAlias	:= GetNextAlias()
Local _cRet		:= ''

BeginSQL Alias _cAlias
	SELECT ZLF_LINROT LINHA
	FROM %Table:ZLF%
	WHERE D_E_L_E_T_ =' '
	AND ZLF_FILIAL = %xFilial:ZLF%
	AND ZLF_CODZLE = %exp:_cMix%
	AND ZLF_A2COD = %exp:_cFornece%
	AND ZLF_A2LOJA = %exp:_cLoja%
	AND ZLF_SETOR = %exp:_cSetor%
	AND ZLF_DEBCRE = 'C'
	GROUP BY ZLF_LINROT
EndSQL

If (_cAlias)->( !Eof() )
	_cRet := (_cAlias)->LINHA
EndIf

(_cAlias)->( DBCloseArea() )

Return(_cRet)

/*
===============================================================================================================================
Programa--------: MGLT011AVL
Autor-----------: Alexandre Villar
Data da Criacao-: 14/04/2015
Descri��o-------: Rotina altera o valor da ZLF
Parametros------: _cSeek   - Chave da ZLF
----------------: _nValor  - Valor a ser gravado no campo ZLF_TOTAL
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MGLT011AVL(_cSeek,_nValor)

Default _cSeek	:= ''

If !Empty( _cSeek )
	ZLF->(DBSetOrder(1))
	If ZLF->(DBSeek(_cSeek))
		ZLF->(RecLock("ZLF",.F.))
		ZLF->ZLF_TOTAL	:= _nValor
		ZLF->ZLF_VLRLTR	:= Round( ZLF->ZLF_TOTAL / ZLF->ZLF_QTDBOM , 4 )
		ZLF->(MsUnlock())
	EndIf
EndIf

Return
