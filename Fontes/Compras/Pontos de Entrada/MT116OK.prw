/*  
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO                             
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich | 22/08/2018 | Incluida valida��o de TES quanto a movimento de estoque - Chamado 25937
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/10/2018 | Inclu�do tratamento para PE n�o ser chamado no TOTVS Colabora��o. Chamado 26587, 26586, 26585, 26583
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/07/2020 | Tratado para n�o ser executado quando chamado pelo Reprocessar. Chamado 33422
===============================================================================================================================
*/

#Include 'Protheus.ch'


/*
===============================================================================================================================
Programa--------: MT116OK
Autor-----------: Alexandre Villar
Data da Criacao-: 28/01/2016
===============================================================================================================================
Descri��o-------: P.E. ap�s a confirma��o do lan�amento do CTE na gera��o da NF
===============================================================================================================================
Parametros------: PARAMIXB[1] - .T. = Exclus�o / .F. = Inclus�o
===============================================================================================================================
Retorno---------: ( .T. ) Dados validos para inclusao. / ( .F. ) Dados n�o validados.
===============================================================================================================================
*/

User Function MT116OK()

Local _lExclui	:= PARAMIXB[1]
Local _lRet		:= .T.
Local _cQuery	:= ''
Local _cAlias	:= ''

//====================================================================================================
// Se n�o for exclus�o verifica se j� foi inclu�da uma NF com a mesma chave
//====================================================================================================
If !_lExclui .And. !FWIsInCallStack("SCHEDCOMCOL")

	If CFORMUL <> 'S'
	
		If !EMPTY( aNfeDanfe[13] )
		
			_cQuery := " SELECT "
			_cQuery += " 	SF1.F1_FILIAL	,"
			_cQuery += " 	SF1.F1_DOC		,"
			_cQuery += " 	SF1.F1_SERIE	,"
			_cQuery += " 	SF1.F1_FORNECE	,"
			_cQuery += " 	SF1.F1_LOJA		,"
			_cQuery += " 	SF1.F1_ESPECIE	,"
			_cQuery += "	SF1.F1_CHVNFE	 "
			_cQuery += " FROM "+ RetSqlName("SF1") +" SF1 "
			_cQuery += " WHERE "
			_cQuery += " 		SF1.D_E_L_E_T_	= ' ' "
			_cQuery += " AND	SF1.F1_CHVNFE	= '"+ aNfeDanfe[13] +"' "
			
			_cAlias := GetNextAlias()
			
			If Select(_cAlias) > 0
				(_cAlias)->( DBCloseArea() )
			EndIf
			
			DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
			
			DBSelectArea(_cAlias)
			(_cAlias)->( DBGoTop() )
			If (_cAlias)->( !Eof() )
			
				//====================================================================================================
				// Exibe Mensagem de Erro
				//====================================================================================================
				u_itmsg(	"A chave: "+ (_cAlias)->F1_CHVNFE +" j� existe em outro documento! "+ CRLF										+;
							"Filial: "+  (_cAlias)->F1_FILIAL +"/ Documento: "+ (_cAlias)->F1_DOC +"/ S�rie: "+ (_cAlias)->F1_SERIE , 'Lan�amento duplicado!',;
						 	"Verifique os dados e caso necess�rio informe a �rea de TI/Sistemas. O documento atual n�o ser� processado!",1 )
				
				_lRet := .F.
				
			EndIf
			
			(_cAlias)->( DBCloseArea() )
			
		EndIf
		
	EndIf

	//Verifica se TES do documento vinculado � compat�vel quanto a movimenta��o de estoque com o CTE sendo incluso
	_nposori := SD1->(Recno())
	_asd1 := SD1->(GetArea())
	_alog := {}
	
	SD1->(Dbsetorder(1))
	If SD1->(Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	
		Do while SF1->F1_FILIAL == SD1->D1_FILIAL .AND.;
		 			SF1->F1_DOC == SD1->D1_DOC .AND.;
		 			SF1->F1_SERIE == SD1->D1_SERIE .AND.;
		 			SF1->F1_FORNECE == SD1->D1_FORNECE .AND.;
		 			SF1->F1_LOJA == SD1->D1_LOJA
		 	
		 	_nPosTes := aScan( aHeader , {|X| Upper( Alltrim( X[2] ) ) == "D1_TES"     } ) // C�digo da TES
		 	_ctes := acols[1][_nPosTes]
		 	_cmvestnf := posicione("SF4",1,SD1->D1_FILIAL+SD1->D1_TES,"F4_ESTOQUE")
		 	_cmvestct := posicione("SF4",1,cfilant+_ctes,"F4_ESTOQUE")
		 	 		
		 	If !(alltrim(_cmvestct) == alltrim(_cmvestnf)) .and. _cmvestnf == "N"
		 	
		 		aadd(_alog,{SD1->D1_FILIAL,SD1->D1_DOC+"/"+SD1->D1_SERIE,SD1->D1_ITEM,SD1->D1_FORNECE+"/"+SD1->D1_LOJA, SD1->D1_TES + " - Estoque  " + _cmvestnf, _ctes + " - Estoque " + _cmvestct })
		 			 	
		 	Endif
		 			
		 	SD1->(Dbskip())
		 			
		Enddo
		
		If len(_alog) > 0
		
			u_itmsg("Diverg�ncia entre a TES do conhecimento e a utilizada na Nota Fiscal de Origem quanto a movimenta��o de estoque.",;
					"Aten��o","Documento n�o ser� gravado, verifique a TES na pr�xima tela.",1)
			_ahead := {"Filial","Nota origem","Item","Fornecedor","TES NF","TES CTE"}
			U_ITListBox( 'Existem diverg�ncias de TES' , _ahead , _aLog , .T. , 1 )
			_lret := .F.
			
		Endif
		
	Endif
	
	SD1->(Restarea(_asd1))
	SD1->(Dbgoto(_nposori)) 

EndIf

Return( _lRet )