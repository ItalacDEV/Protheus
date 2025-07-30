#Include 'Protheus.ch'

#Define _nPosCTE	08
#Define _nPosSER	09
#Define _nPosFOR	10
#Define _nPosLOJ	11

/*
===============================================================================================================================
Programa----------: M116MARK
Autor-------------: Alexandre Villar
Data da Criacao---: 11/12/2014
===============================================================================================================================
Descri��o---------: P.E. para validar a marca��o dos �tens na tela de sele��o de NF no lan�amento de CTE
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: Gest�o do Leite
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich     | 04/08/2015 | Ajuste de chamada de nomes de fornecedor e transportadora - Chamado 11242                    |
===============================================================================================================================
*/

User Function M116MARK()

Local _aArea	:= GetArea()
Local _cMark	:= ThisMark()
Local _lRet		:= .T.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _cnome := ""

If IsMark('F1_OK',_cMark)

	SF1->( RecLock('SF1',.F.) )
	SF1->F1_OK := Space(2)
	SF1->( MsUnLock() )
	
Else

	_cQuery := " SELECT ZLX_NRONF, ZLX_SERINF, ZLX_FORNEC, ZLX_LJFORN, ZLX_CTE  "
	_cQuery += " FROM  "+ RETSQLNAME('ZLX') +" ZLX "
	_cQuery += " WHERE "+ RETSQLCOND('ZLX')
	_cQuery += " AND ZLX.ZLX_TRANSP = '"+ aParametros[_nPosFOR] +"' " //Fornecedor CTE
	_cQuery += " AND ZLX.ZLX_LJTRAN = '"+ aParametros[_nPosLOJ] +"' " //Loja Forn. CTE
	_cQuery += " AND ZLX.ZLX_CTE    = '"+ aParametros[_nPosCTE] +"' " //Numero do CTE
	_cQuery += " AND ZLX.ZLX_CTESER = '"+ aParametros[_nPosSER] +"' " //Serie do CTE
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->( !Eof() ) .And. !Empty( (_cAlias)->ZLX_CTE )
		
		If	(_cAlias)->ZLX_NRONF	<> SF1->F1_DOC		.Or. (_cAlias)->ZLX_SERINF	<> SF1->F1_SERIE .Or.;
			(_cAlias)->ZLX_FORNEC	<> SF1->F1_FORNECE	.Or. (_cAlias)->ZLX_LJFORN <> SF1->F1_LOJA
			
			_cNome := Posicione("SA2",1,xFilial("SA2")+(_cAlias)->ZLX_FORNEC+(_cAlias)->ZLX_LJFORN,"A2_NOME")
			
			MessageBox( 'O CTE atual est� amarrado � outra NF na Recep��o de Leite de Terceiros no m�dulo Gest�o do Leite: '	+CRLF+;
						'NF: '+ (_cAlias)->ZLX_NRONF +" / S�rie: "+ (_cAlias)->ZLX_SERINF										+CRLF+;
						'Fornecedor/Loja: '+ (_cAlias)->ZLX_FORNEC +"/"+ (_cAlias)->ZLX_LJFORN +" - "+ _cnome	+CRLF+;
						'S� poder� ser feita a amarra��o do CTE com a mesma NF/Fornecedor da Recep��o de Leite!'				, 'Aten��o!' , 0 )
			
			_lRet := .F.
			
		EndIf
		
	EndIf
	
	(_cAlias)->( DBCloseArea() )
	
	If _lRet
	
		_cQuery := " SELECT ZLX_CTE, ZLX_CTESER, ZLX_TRANSP, ZLX_LJTRAN "
		_cQuery += " FROM  "+ RETSQLNAME('ZLX') +" ZLX "
		_cQuery += " WHERE "+ RETSQLCOND('ZLX')
		_cQuery += " AND ZLX.ZLX_FORNEC = '"+ SF1->F1_FORNECE +"' "
		_cQuery += " AND ZLX.ZLX_LJFORN = '"+ SF1->F1_LOJA    +"' "
		_cQuery += " AND ZLX.ZLX_NRONF  = '"+ SF1->F1_DOC     +"' "
		_cQuery += " AND ZLX.ZLX_SERINF = '"+ SF1->F1_SERIE   +"' "
		
		If Select(_cAlias) > 0
			(_cAlias)->( DBCloseArea() )
		EndIf
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
		
		DBSelectArea(_cAlias)
		(_cAlias)->( DBGoTop() )
		If (_cAlias)->( !Eof() ) .And. !Empty( (_cAlias)->ZLX_CTE )
	 
			If	(_cAlias)->ZLX_CTE <> aParametros[_nPosCTE] .Or. (_cAlias)->ZLX_CTESER	<> aParametros[_nPosSER] .Or.;
				(_cAlias)->ZLX_TRANSP	<> aParametros[_nPosFOR] .Or. (_cAlias)->ZLX_LJTRAN	<> aParametros[_nPosLOJ]
				
				
				_cNome := Posicione("SA2",1,xFilial("SA2")+(_cAlias)->ZLX_TRANSP+(_cAlias)->ZLX_LJTRAN,"A2_NOME")
		
				MessageBox( 'A NF atual est� amarrada � outro CTE na Recep��o de Leite de Terceiros no m�dulo Gest�o do Leite: '	+ CRLF +;
							'CTE: '+ (_cAlias)->ZLX_CTE +" / S�rie: "+ (_cAlias)->ZLX_CTESER										+ CRLF +;
							'Transportador/Loja: '+ (_cAlias)->ZLX_TRANSP +"/"+ (_cAlias)->ZLX_LJTRAN +" - "+ _cNome	+ CRLF +;
							'S� poder� ser feita a amarra��o do CTE com a mesma NF/Fornecedor da Recep��o de Leite!'				, 'Aten��o!' , 0 )
				
				_lRet := .F.
				
			EndIf
			
		EndIf
		
		(_cAlias)->( DBCloseArea() )
	
	EndIf
	
	If _lRet
	
		SF1->( RecLock( "SF1" , .F. ) )
		SF1->F1_OK := _cMark
		SF1->( MsUnLock() )
	
	EndIf

EndIf

MarkBRefresh()
RestArea(_aArea)

Return()