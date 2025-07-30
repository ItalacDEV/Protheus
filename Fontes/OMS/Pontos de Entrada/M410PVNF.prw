/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 27/11/2015 | Inclu�da valida��o para verificar a configura��o do pedido com rela��o ao vencimento e frete
                  |            | para informar ao usu�rio para que este confirme se quer continuar. Chamado 10369
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 12/02/2016 | Inclu�da valida��o da configura��o do Peso no cadastro de produtos quando a TES definir que
                  |            | atualiza ativo ou movimenta estoque. Chamado 14115
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 01/02/2021 | Remo��o de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: M410PVNF
Autor-----------: Tiago Correa Castro
Data da Criacao-: 17/01/2012
===============================================================================================================================
Descri��o-------: P.E. para validar o Pedido de Vendas na chamada de Prep. Doc. de Sa�da na tela de Pedidos de Vendas.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _lRet	:= define se o faturamento pode prosseguir
===============================================================================================================================
*/
User Function M410PVNF()

Local _lRet		:= .T.
Local _lVldPes	:= U_ITGetMV( 'IT_VALPESF' , .F. )
Local _cFilEst3	:= U_ITGETMV( 'IT_EST3FIL' , '' )

//====================================================================================================
// Funcao responsavel por validar se a DataBase e igual a data atual(Servidor) para nao permitir o
// faturamento com data retroativa ou posterior a data atual.
//====================================================================================================
If SC5->C5_I_BLPRC == "B" .Or. SC5->C5_I_BLPRC == "R"

	_lRet	:=	.F.

	If SC5->C5_I_BLPRC == "B"

		xMagHelpFis("PROBLEMA",;
					"Pedido de Venda com Bloqueio de Pre�o Solicite a Libera��o do Mesmo Antes de Fatura-lo") 

	Else

		xMagHelpFis("PROBLEMA",;
					"Pedido de Venda com Rejei��o de Pre�o Solicite a Libera��o do Mesmo Antes de Fatura-lo") 

	EndIf

EndIf

If DDATABASE <> DATE()

	_lRet	:=	.F.
	xMagHelpFis("PROBLEMA",;
				"Para o Faturamento a Data Base do sistema tem que ser igual a Data Atual do servidor. N�o e permitido faturamento anterior ou posterior a data atual",;
				"Mudar a data base do sistema") 	    	
Endif  

//====================================================================================================
// Valida��o do estoque para verificar se o pedido pode ser faturado
//====================================================================================================
If _lRet .And. SC5->C5_FILIAL $ _cFilEst3

	LjMsgRun( "Verificando estoque dos itens do pedido selecionado..." , "Aguarde!" , {|| _lRet := U_ITVLDEST( 1 , SC5->C5_FILIAL , SC5->C5_NUM ) } )
	
	If !_lRet
	
		//						 		|....:....|....:....|....:....|....:....|
		ShowHelpDlg( 'Aten��o!' ,	{	'N�o existe saldo em estoque para faturar '	,;
										'o pedido atual!'							} , 2 ,;
									{	'Verifique os saldos dos itens do pedido '	,;
										'pois devem constar "em estoque" para o '	,;
										'faturamento. Para a libera��o do pedido '	,;
										'utilize a rotina de libera��o!'			} , 4 )
	
	EndIf
	
EndIf

If _lRet
	LjMsgRun( "Verificando se existem itens de pedidos com o armaz�m incorreto..." , "Aguarde!" , {|| _lRet := VLDARM() } )
EndIf

If _lRet
	LjMsgRun( "Verificando se existem itens de pedidos com o armaz�m restrito..." , "Aguarde!" , {|| _lRet := VLDRES() } )
EndIf

//====================================================================================================
// Verifica se o Pedido � do Tipo "Normal" e suas amarra��es de Frete x Condi��o de Pagto.
//====================================================================================================
If _lRet .And. SC5->C5_TIPO == 'N'
	
	If SC5->C5_CONDPAG == '001'
		
		If ITVERTES( SC5->C5_FILIAL , SC5->C5_NUM )
			
			_lRet := MsgYesNo(	'A condi��o de pagamento do pedido ['+ SC5->C5_NUM +'] foi configurada como [001 - � Vista] e foi utilizada uma TES que gera financeiro, '	+;
								'� recomendado verificar o recebimento ou a antecipa��o do pagamento!'+ CRLF +'Deseja prosseguir com a libera��o do Pedido de Venda?'		 , 'Aten��o!' )
			
		EndIf
		
	EndIf
	
	If SC5->C5_TPFRETE == 'F'
		
		_lRet := MsgYesNo(	'O frete do pedido ['+ SC5->C5_NUM +'] foi configurado como [FOB] � recomendado verificar as quest�es de embarque/descontos do frete!'+ CRLF +;
				 			'Deseja prosseguir com a libera��o do Pedido de Venda?' , 'Aten��o!' )
		
	EndIf
	
EndIf

//====================================================================================================
// Valida��o da TES x Configura��o de peso dos produtos
//====================================================================================================
If _lRet .And. _lVldPes
	LjMsgRun( "Verificando os dados do cadastro de produtos..." , "Aguarde!" , {|| _lRet := IT_VLDPES() } )
EndIf

Return(_lRet)

/*
===============================================================================================================================
Programa--------: VLDARM
Autor-----------: Talita
Data da Criacao-: 27/02/2013
===============================================================================================================================
Descri��o-------: Valida se os pedidos est�o sendo gerados com o armaz�m correto e se precisa da montagem de carga.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _lRet	:= define se o faturamento pode prosseguir
===============================================================================================================================
*/
Static Function VLDARM()

Local _lRet		:= .T.
Local _cPedido	:= SC5->C5_NUM
Local _cLocal	:= AllTrim( GetMv("IT_ARMCARG") )
Local _nPed		:= 0
Local _nCont	:= 0
Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()
Local _nI		:= 0
Local _aParam	:= {}
Local _cTemp	:= ""

For _nI := 1 to Len( _cLocal )

	If ( SubStr( _cLocal , _nI , 1 ) == "/" )
	
		aAdd( _aParam , _cTemp )
		_cTemp := ""
		
	Else
	
		_cTemp += SubStr( _cLocal , _nI , 1 )
		
		If ( _nI == Len( _cLocal ) )
		
			aAdd( _aParam , _cTemp )
			_cTemp := ""
			
		EndIf
		
	EndIf
	
Next _nI

_cQuery := " SELECT "
_cQuery += "     DAI_COD   ,"
_cQuery += "     DAI_PEDIDO "
_cQuery += " FROM  "+ RetSqlName("DAI") +" DAI "
_cQuery += " WHERE "+ RetSqlCond("DAI")
_cQuery += " AND DAI_PEDIDO = '"+ AllTrim( _cPedido ) +"' " 

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
While (_cAlias)->( !EOF() )
	
	If (_cAlias)->DAI_PEDIDO <> ' '
		_nPed++
	EndIf
	
(_cAlias)->( DBSkip() )
EndDo
	
DbSelectArea("SC6")
SC6->( DBSetOrder(1) )
IF SC6->( DbSeek( xFilial("SC6") + _cPedido ) )

	While SC6->( !EOF() ) .and. SC6->C6_NUM = _cPedido
	
	   	For _nI := 1 To Len( _aParam )
	   	
		   	_cTes := GetAdvFVal( "SF4" , "F4_ESTOQUE" , xFilial("SF4") + SC6->C6_TES , 1 , "" )
		   	
			If _aParam[_nI] == SC6->C6_LOCAL .AND. _nPed == 0 .And. _cTes == "S"
	            _nCont++
		    EndIf
		    
	    Next _nI
	
	SC6->( DBSkip() )
	EndDo
		
	If _nCont > 0
	
		//						 		|....:....|....:....|....:....|....:....|
		ShowHelpDlg( 'Aten��o!' ,	{	'N�o � poss�vel faturar itens que est�o '	,;
										'configurados no armaz�m '+ _cLocal +'!'	} , 2 ,;
									{	'Neste armaz�m s� podem ser faturados os '	,;
										'pedidos que possu�rem montagem de carga '	,;
										'realizada. Verifique se o pedido est� '	,;
										'configurado no armaz�m correto.'			} , 4 )
		
		_lRet = .F.
		
	Else
	
		_lRet = .T.
		
	EndIf

EndIf
	
(_cAlias)->( DBCloseArea() )

Return( _lRet )

/*
===============================================================================================================================
Programa--------: VLDRES
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 16/10/2015
===============================================================================================================================
Descri��o-------: Valida se o pedido usam armaz�ns restritos quanto a usr x filial x armaz�m
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _lRet	:= define se o faturamento pode prosseguir
===============================================================================================================================
*/
Static Function VLDRES()

Local _lRet 	:= .T.
Local _aRet 	:= {}
Local _cmens	:= ""
Local _cCodUsr	:=ALLTRIM(RetCodUsr())

DbSelectArea("SC6")
SC6->( DbSetOrder(1) )
	
If DbSeek(xFilial("SC6")+SC5->C5_NUM)

	Do while alltrim(SC5->C5_NUM) == alltrim(SC6->C6_NUM)

		//============================================
		//Valida armaz�mxprodutoxfilialxusu�rio
		//============================================
		_aRet := U_ACFG004E(_cCodUsr, alltrim(xFilial("SC6")), alltrim(SC6->C6_LOCAL),alltrim(SC6->C6_PRODUTO), .F.)
			
		//se ainda est� valido verifica se n�o teve erro
		If _lRet
		
		  	_lRet:= _aRet[1]
		
		Endif
		
		// adiciona armazens com problema se ainda n�o estiver na mensagem
		if empty(_cmens)
		
			_cmens += _aRet[2]
			
		elseif !(_aRet[2]$_cmens) .and. !(Empty(_aRet[2])) 
		
			_cmens += ", " + _aRet[2]
			
		Endif
			
			
		SC6->( Dbskip() )
		
	Enddo
		
	//============================================
	//Mostra lista de armaz�ns com problema
	//============================================
	If !(_lRet)

		MessageBox( 'Usu�rio sem acesso ao(s) armaz�m(�ns) abaixo nessa filial: ' + CRLF + _cmens + CRLF + CRLF+;
					'Caso necess�rio solicite a manuten��o � um usu�rio com acesso ou, se necess�rio, solicite o acesso � �rea de TI/ERP.' , 'Aten��o!' , 48 )
	
	Endif
		
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: ITVERTES
Autor-----------: Alexandre Villar
Data da Criacao-: 27/11/2015
===============================================================================================================================
Descri��o-------: Fun��o para verificar se o pedido est� configurado com uma TES que gera Financeiro
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _lRet - Valor l�gico que determina se o processo de libera��o deve continuar
===============================================================================================================================
*/
Static Function ITVERTES( _cFilPed , _cNumPed )

Local _lRet		:= .F.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

_cQuery := " SELECT COUNT( 1 ) AS GERFIN "
_cQuery += " FROM  "+ RetSqlName('SC6') +" SC6, "+ RetSqlName('SF4') +" SF4 "
_cQuery += " WHERE "+ RetSqlDel('SC6,SF4')
_cQuery += " AND SF4.F4_FILIAL  = SC6.C6_FILIAL "
_cQuery += " AND SF4.F4_CODIGO  = SC6.C6_TES "
_cQuery += " AND SC6.C6_FILIAL  = '"+ _cFilPed +"' "
_cQuery += " AND SC6.C6_NUM     = '"+ _cNumPed +"' "
_cQuery += " AND SF4.F4_DUPLIC  = 'S' "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() )
	_lRet := ( (_cAlias)->GERFIN > 0 )
EndIf

(_cAlias)->( DBCloseArea() )

Return( _lRet )

/*
===============================================================================================================================
Programa--------: IT_VLDPES
Autor-----------: Alexandre Villar
Data da Criacao-: 12/02/2016
===============================================================================================================================
Descri��o-------: Fun��o para verificar se o produto possui os dados de peso cadastrados quando a TES exige
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _lRet - Valor l�gico que determina se o processo de libera��o deve continuar
===============================================================================================================================
*/
Static Function IT_VLDPES()

Local _lRet	:= .T.

DBSelectArea("SC6")
SC6->( DBSetOrder(1) )
If SC6->( DBSeek( SC5->( C5_FILIAL + C5_NUM ) ) )

	While SC6->( C6_FILIAL + C6_NUM ) == SC5->( C5_FILIAL + C5_NUM )
		
		DBSelectArea('SF4')
		SF4->( DBSetOrder(1) )
		If SF4->( DBSeek( xFilial('SF4') + SC6->C6_TES ) )
			
			If SF4->F4_ATUATF == 'S' .Or. SF4->F4_ESTOQUE == 'S'
				
				DBSelectArea('SB1')
				SB1->( DBSetOrder(1) )
				If SB1->( DBSeek( xFilial('SB1') + SC6->C6_PRODUTO ) )
					
					If ( SB1->B1_PESO == 0 ) .Or. ( SB1->B1_PESBRU == 0 )
						//								|....:....|....:....|....:....|....:....|
						ShowHelpDlg( 'Aten��o!' ,	{	'O produto utilizado nos pedidos n�o tem '		,;
														' informa��o de Peso (B1_PESO) nem Peso '		,;
														' Bruto (B1_PESBRU)!'							}, 3 ,;
													{	'Para a TES utilizada o produto deve ter '		,;
														' as informa��es de Peso cadastradas.'			,;
														' Pedido: '+ SC6->C6_FILIAL +'-'+ SC6->C6_NUM	+;
														' Item: '+ SC6->C6_ITEM							,;
														' Produto: '+ SC6->C6_PRODUTO					}, 4  )
						
						_lRet := .F.
						Exit
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	SC6->( DBSkip() )
	EndDo
	
EndIf

Return( _lRet )
