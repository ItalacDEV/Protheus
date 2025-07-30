/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich      | 20/04/2018 | Revis�o de rotina e corre��o de itlist - Chamado 24498      
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer     | 04/02/2019 | Corre��o de error.log: array _aCliente vazia. Chamado 27938
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Jonathan          | 27/02/2020 | Novo tratamento quando vendedor de origem ou de destino for do Canal Broker. Chamado 32075.
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MOMS014
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Rotina para atualiza��o da carteira de Clientes de Vendedores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS014()

Local _oDlg			:= NIL
Local _oGRede		:= NIL
Local _oGUF	   		:= NIL
Local _oVenOri		:= NIL
Local _oVenDes		:= NIL
Local _oCombo		:= NIL
Local _oSay1		:= NIL
Local _oSay2		:= NIL
Local _oSay3		:= NIL
Local _oSay4		:= NIL
Local _oVenON		:= NIL
Local _oVenDN		:= NIL
Local _aBotoes		:= {}    

Private _nOpca		:= 0
Private _cCombo		:= Space(010)
Private _cVenOri	:= Space(006)
Private _cVenDes	:= Space(006)
Private _cGUF		:= Space(120)
Private _cGRede		:= Space(120)

DEFINE MSDIALOG _oDlg TITLE "Vendedores x Clientes - Substitui��o da carteira" FROM 000, 000  TO 320, 550 COLORS 0, 16777215 PIXEL   

	_oDlg:lMaximized := .F.
	
	@046,009 SAY _oSay1 PROMPT "Atualizar:"		SIZE 041,008 OF _oDlg PIXEL COLORS 0,16777215
	@066,009 SAY _oSay1 PROMPT "Vendedor de:"	SIZE 066,008 OF _oDlg PIXEL COLORS 0,16777215
    @086,009 SAY _oSay2 PROMPT "Vendedor para:"	SIZE 066,008 OF _oDlg PIXEL COLORS 0,16777215
    @106,009 SAY _oSay3 PROMPT "Rede:"			SIZE 025,008 OF _oDlg PIXEL COLORS 0,16777215
    @126,009 SAY _oSay4 PROMPT "UF:"				SIZE 025,008 OF _oDlg PIXEL COLORS 0,16777215
    
    @046,068 MSCOMBOBOX _oCombo	VAR _cCombo		SIZE 133,010 OF _oDlg PIXEL COLORS 0,16777215 ITEMS { "Vendedor 1" , "Vendedor 2" }
    @063,069 MSGET _oVenOri		VAR _cVenOri	SIZE 040,010 OF _oDlg PIXEL COLORS 0,16777215 F3 "SA3BLQ" VALID(IIF(!EMPTY(_cVenOri),IIF(EXISTCPO("SA3",_cVenOri,1),Eval({|| _oVenON:=Posicione("SA3",1,xFilial("SA3") + _cVenOri,"SA3->A3_NOME"),.T.}),Eval({|| _oVenOri:SETFOCUS(),.F.})),Eval({|| _oVenON:="",.T.})))
    @083,069 MSGET _oVenDes		VAR _cVenDes	SIZE 040,010 OF _oDlg PIXEL COLORS 0,16777215 F3 "SA3BLQ" VALID(IIF(!EMPTY(_cVenDes),IIF(EXISTCPO("SA3",_cVenDes,1),Eval({|| _oVenDN:=Posicione("SA3",1,xFilial("SA3") + _cVenDes,"SA3->A3_NOME"),.T.}),Eval({|| _oVenDes:SETFOCUS(),.F.})),Eval({|| _oVenDN:="",.T.})))
    @103,069 MSGET _oGRede		VAR _cGRede	  	SIZE 195,010 OF _oDlg PIXEL COLORS 0,16777215 F3 "LSTRED"
    @123,069 MSGET _oGUF		VAR _cGUF	  	SIZE 195,010 OF _oDlg PIXEL COLORS 0,16777215 F3 "LSTEST"
    
    @063,123 MSGET _oVenON						SIZE 141,010 OF _oDlg PIXEL COLORS 0,16777215 WHEN .F.
    @083,123 MSGET _oVenDN						SIZE 141,010 OF _oDlg PIXEL COLORS 0,16777215 WHEN .F.

ACTIVATE MSDIALOG _oDlg ON INIT (EnchoiceBar(_oDlg,{|| IIF(MOMS014V(),Eval({|| _nOpca := 1,_oDlg:End(),FWMsgRun( ,{|| MOMS014P() } , "Verificando os dados...",'Aguarde!' ) } ) , ) } , {|| _nOpca := 2,_oDlg:End()},,_aBotoes))

Return()

/*
===============================================================================================================================
Programa----------: MOMS014
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Rotina para atualiza��o da carteira de Clientes de Vendedores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/                
Static Function MOMS014V()

Local _lRet		:= .T.           

//====================================================================================================
// Verifica se os campos obrigat�rios foram preenchidos
//====================================================================================================
If !Empty( _cVenOri )

	DBSelectArea('SA3')
	SA3->( DBSetOrder(1) )
	If !SA3->( DBSeek( xFilial('SA3') + _cVenOri ) )
		
		_lRet := .F.

		U_ITMSG('O c�digo de vendedor de origem informado n�o � v�lido! ','Aten��o!',,1)
	
	EndIf
	
EndIf

If _lRet

	If Empty( _cVenDes )
	
		_lRet := .F.
		
		U_ITMSG('N�o foi informado um c�digo de vendedor de destino da carteira!  ','Aten��o!',,1)		
		
	Else
	
		If _cVenOri == _cVenDes
		
			_lRet := .F.

			U_ITMSG('O c�digo de vendedor de destino informado est� igual ao vendedor de origem!  ','Aten��o!',,1)		
			
		Else
		
			DBSelectArea('SA3')
			SA3->( DBSetOrder(1) )
			If SA3->( DBSeek( xFilial('SA3') + _cVenDes ) )
				
				If SA3->A3_I_TIPV <> 'V'
				
					_lRet := .F.
					
					U_ITMSG('O c�digo de vendedor de origem informado n�o � v�lido! ','Aten��o!',,1)			
				
				ElseIf SA3->A3_MSBLQL == '1'
				
					_lRet := .F.
	
					U_ITMSG('O c�digo de vendedor de destino informado est� bloqueado no sistema!','Aten��o!',,1)
					
				EndIF
				
			Else
			
				_lRet := .F.
				
				U_ITMSG('O c�digo de vendedor de destino informado n�o � v�lido!','Aten��o!',,1)
			
			EndIf
		
		EndIf
		
	EndIf

EndIf
	          
Return( _lRet )

/*
===============================================================================================================================
Programa----------: MOMS014P
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Rotina de processamento da transfer�ncia de Carteira
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS014P()

Local _aPedVen	:= {}  , _nI
Local _aRegSA1	:= {}
Local _aCliente	:= {}
//Local _aDados	:= {}
Local _lOk		:= .T.
Local _cAlias	:= GetNextAlias()

//====================================================================================================
// Verifica se existem pedidos de venda em aberto para o vendedor de origem(vendedor atual)
// Ser� emitida uma rela��o com os dados do pedido para possivel altera��o pelo usuario.
//====================================================================================================
If !Empty( _cVenOri )

	FWMsgRun( , {|| MOMS014QRY( 1 , _cAlias ) },'Verificando os pedidos do vendedor de origem...' , 'Aguarde!'  )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGotop() )
	If (_cAlias)->( !Eof() )
	
		U_ITMSG( 'Foram encontrados pedidos em aberto para o vendedor de origem!' ,"Aten��o",,1 )
		
		While (_cAlias)->(!Eof())
		
			_aHdrAux := {'Filial','N�mero','C�d. Cliente','Nome Cliente','Nome Fantasia','C�d.Vendedor','Nome Vendedor','C�d. Grupo','Descri��o'}
			_aSizes  := {20,30,40,200,100,40,100,40,100}
			
			aAdd( _aPedVen , {	(_cAlias)->C5_FILIAL								,;
								(_cAlias)->C5_NUM									,;
								(_cAlias)->C5_CLIENTE +'/'+ (_cAlias)->C5_LOJACLI	,;
								(_cAlias)->A1_NOME									,;
								(_cAlias)->A1_NREDUZ								,;
								(_cAlias)->C5_VEND1									,;
								(_cAlias)->A3_NOME									,;
								(_cAlias)->A1_GRPVEN								,;
								(_cAlias)->ACY_DESCRI								,;
								(_cAlias)->REGSA1 									})
			
		(_cAlias)->( DBSkip() )
		EndDo
		
		U_ITListBox( 'Pedidos de venda em aberto para o vendedor de origem:' , _aHdrAux , _aPedVen , .F. , 1 ,,, _aSizes )
		
		_lOk := u_itmsg( 'Deseja continuar e processar a transfer�ncia dos clientes que n�o estejam com pedidos em aberto?' , 'Aten��o!' ,,2,2,2)
		
	EndIf

	(_cAlias)->( DBCloseArea() )

EndIf

If _lOk

	fwMsgRun( , {|| MOMS014QRY( 2 , _cAlias ) },'Selecionando os clientes do vendedor de origem...' , 'Aguarde!'  )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGotop() )
	COUNT TO _nContReg
	
	If _nContReg == 0
		
		_lOk := .F.
		
		U_ITMSG( 'N�o foram encontrados clientes ativos na carteira do vendedor de origem!' ,"Aten��o",,1 )
		
    Else
		
		(_cAlias)->( DBGoTop() )
		While (_cAlias)->( !Eof() )
			
			If aScan( _aPedVen , {|x| x[10] == (_cAlias)->REGSA1 } ) == 0
			
				aAdd( _aCliente , {	.F.						,;
									(_cAlias)->A1_COD		,;
									(_cAlias)->A1_LOJA		,;
									(_cAlias)->A1_NOME		,;
									(_cAlias)->A1_NREDUZ	,;
									(_cAlias)->A1_CGC		,;
									(_cAlias)->CODVEN		,;
									(_cAlias)->A3_NOME		,;
									(_cAlias)->A1_GRPVEN	,;
									(_cAlias)->ACY_DESCRI	,;
									(_cAlias)->A1_EST		,;
									(_cAlias)->REGSA1		})
			
			EndIf
			
		(_cAlias)->( DBSkip() )
		EndDo
        
        IF LEN(_aCliente) = 0
  		   U_ITMSG( 'Todos os clientes desses vendedores possuem Pedido em aberto' ,"Aten��o",,1 )
		ENDIF

		_aHdrAux	:= {'[ ]','C�d. Cliente','Loja Cliente','Nome Cliente','Nome Fantasia','CPF/CNPJ','C�d. Vendedor','Nome Vendedor','C�d. Grupo','Descri��o','Estado'}
		
		If LEN(_aCliente) > 0 .AND. U_ITListBox( 'Clientes para transfer�ncia de carteira:' , _aHdrAux , @_aCliente , .T. , 2 , 'Selecione os clientes para transferir para o vendedor: '+ _cVenDes +' - '+ Posicione('SA3',1,xFilial('SA3')+_cVenDes,'A3_NOME') )
			
			For _nI := 1 To Len(_aCliente)
				
				If _aCliente[_nI][01]

					lVenOri := POSICIONE("SA3",1,xFilial("SA3")+_cVenOri,"A3_I_VBROK") = 'B'
					lVenDes := POSICIONE("SA3",1,xFilial("SA3")+_cVenDes,"A3_I_VBROK") = 'B'
					
					DBSelectArea('SA1')
					SA1->( DBGoTo( _aCliente[_nI][12] ) )
					SA1->( RecLock( 'SA1' , .F. ) )
					
					If _cCombo == 'Vendedor 1'
						SA1->A1_VEND	:= _cVenDes
						IF lVenOri .OR. lVenDes
							SA1->A1_RISCO := POSICIONE("SA3",1,xFilial("SA3")+_cVenDes,"A3_I_RISCO")
							SA1->A1_LC := SA3->A3_I_LC
							SA1->A1_TABELA := SA3->A3_I_TABPR		
						ENDIF
					Else
						SA1->A1_I_VEND2	:= _cVenDes
						IF lVenOri .OR. lVenDes
							SA1->A1_RISCO := POSICIONE("SA3",1,xFilial("SA3")+_cVenDes,"A3_I_RISCO")
							SA1->A1_LC := SA3->A3_I_LC
							SA1->A1_TABELA := SA3->A3_I_TABPR		
						ENDIF
					EndIf
					
					SA1->( MsUnLock() )
					
					aAdd( _aRegSA1 , { SA1->A1_COD +'/'+ SA1->A1_LOJA , SA1->A1_NOME , SA1->A1_VEND , SA1->A1_I_VEND2 } )
					
				EndIf
				
			Next _nI
		
		Else
			
			_lOk := .F.
//			U_ITMSG( 'Opera��o cancelada pelo usu�rio!' ,"Aten��o",,1 )
			
		EndIf
		
	EndIf

EndIf

If _lOk

	If Empty( _aRegSA1 )
	
		U_ITMSG( 'N�o foram atualizados os cadastros de clientes no Sistema!' ,"Aten��o",'Verifique os dados informados e/ou os cadastros dos clientes.',1 )
		
	Else
		
		If u_itmsg( 'Foram atualizados os cadastros de ['+ cValToChar( Len(_aRegSA1) ) +'] clientes! Deseja visualizar a rela��o de clientes atualizados?' , 'Conclu�do!',,2,2,2 )
			
			_aHdrAux := { 'C�digo' , 'Nome' , 'Vendedor 1' , 'Vendedor 2' }
			_aSizes  := { 40 , 200 , 50 , 50 }
			U_ITListBox( 'Clientes processados pela transfer�ncia de carteira:' , _aHdrAux , _aRegSA1 , .F. , 1 ,,, _aSizes )
			
		EndIf
		
	EndIf

EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS014QRY
Autor-------------: Alexandre Villar
Data da Criacao---: 08/05/2015
===============================================================================================================================
Descri��o---------: Montagem das tabelas tempor�rias para consultar os dados no sistema
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS014QRY( _nOpcao , _cAlias )

Local _cQuery	:= ''

Do Case

	//====================================================================================================
	// Verifica se existem pedidos em aberto para o Vendedor
	//====================================================================================================
	Case _nOpcao == 1

		_cQuery := " SELECT "
		_cQuery += "     C5_FILIAL    , "
		_cQuery += "     C5_NUM       , "
		_cQuery += "     C5_CLIENTE   , "
		_cQuery += "     C5_LOJACLI   , "
		_cQuery += "     A1.A1_NOME   , "
		_cQuery += "     A1.A1_NREDUZ , "
		_cQuery += "     C5.C5_VEND1  , "
		_cQuery += "     A3.A3_NOME   , "
		_cQuery += "     A1.A1_GRPVEN , "
		_cQuery += "     CY.ACY_DESCRI, "
		_cQuery += "     A1.R_E_C_N_O_ AS REGSA1 "
		_cQuery += " FROM "+ RetSqlName('SC5') +" C5 "
		_cQuery += " JOIN "+ RetSqlName('SA1') +" A1 ON A1.A1_COD = C5.C5_CLIENTE AND A1.A1_LOJA = C5.C5_LOJACLI "
		_cQuery += " JOIN "+ RetSqlName('SA3') +" A3 ON A3.A3_COD = C5.C5_VEND1 "
		_cQuery += " JOIN "+ RetSqlName('ACY') +" CY ON CY.ACY_GRPVEN = A1.A1_GRPVEN "
		_cQuery += " WHERE "
		_cQuery += "     C5.D_E_L_E_T_ = ' ' "
		_cQuery += " AND A1.D_E_L_E_T_ = ' ' "
		_cQuery += " AND A3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND CY.D_E_L_E_T_ = ' ' "
		_cQuery += " AND C5.C5_NOTA    = ' ' "
		_cQuery += " AND C5.C5_VEND1   = '"+ _cVenOri +"' "
		
		If !Empty( _cGRede )
		_cQuery += " AND A1.A1_GRPVEN IN " + FormatIn( _cGRede , ";" )
		EndIf
		
		If !Empty( _cGUF )
		_cQuery += " AND A1.A1_EST IN "    + FormatIn( _cGUF , ";" )
		EndIf
		
		_cQuery += " ORDER BY C5_FILIAL , C5_NUM "
		
		If Select( _cAlias ) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
		
	//====================================================================================================
	// Busca rela��o de clientes atualmente na carteira do vendedor de origem
	//====================================================================================================
	Case _nOpcao == 2
		
		_cQuery := " SELECT "
		_cQuery += "     A1.A1_COD     , "
		_cQuery += "     A1.A1_LOJA    , "
		_cQuery += "     A1.A1_NOME    , "
		_cQuery += "     A1.A1_NREDUZ  , "
		_cQuery += "     A1.A1_CGC     , "
		_cQuery += "     "+ IIF( _cCombo == 'Vendedor 1' , 'A1.A1_VEND ' , 'A1.A1_I_VEND2 ' ) +" AS CODVEN , "
		_cQuery += IIF( Empty(_cVenOri) , " ' ' AS A3_NOME , " , "     A3.A3_NOME    , " )
		_cQuery += "     A1.A1_GRPVEN  , "
		_cQuery += "     CY.ACY_DESCRI , "
		_cQuery += "     A1.A1_EST     , "
		_cQuery += "     A1.R_E_C_N_O_ AS REGSA1 "
		_cQuery += " FROM "+ RetSqlName('SA1') +" A1 "
		If !Empty(_cVenOri)
		_cQuery += " JOIN "+ RetSqlName('SA3') +" A3 ON A3.A3_COD     = "+ IIF( _cCombo == 'Vendedor 1' , 'A1.A1_VEND' , 'A1.A1_I_VEND2' )
		EndIf
		_cQuery += " JOIN "+ RetSqlName('ACY') +" CY ON CY.ACY_GRPVEN = A1.A1_GRPVEN "
		_cQuery += " WHERE "
		_cQuery += "     A1.D_E_L_E_T_ = ' ' "
		If !Empty(_cVenOri)
		_cQuery += " AND A3.D_E_L_E_T_ = ' ' "
		EndIf
		_cQuery += " AND CY.D_E_L_E_T_ = ' ' "
		_cQuery += " AND "+ IIF( _cCombo == 'Vendedor 1' , 'A1.A1_VEND' , 'A1.A1_I_VEND2' ) +" = '"+ _cVenOri +"' "
		
		If !Empty( _cGRede )
		_cQuery += " AND A1.A1_GRPVEN  IN "+ FormatIn( _cGRede , ";" )
		EndIf
		
		If !Empty( _cGUF )
		_cQuery += " AND A1.A1_EST     IN "+ FormatIn( _cGUF , ";" )
		EndIf
		
		_cQuery += " ORDER BY A1_COD , A1_LOJA "
		
		If Select( _cAlias ) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	        
EndCase

Return()