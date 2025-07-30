/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |11/02/2025| Chamado 49877. Removido tratamento sobre a vers�o do Mix
Lucas Borges  |23/05/2025| Chamado 50754. Inclu�do tratamento para CT-e Simplificado
Lucas Borges  |03/06/2025| Chamado 50847. Inclu�da valida��o para n�o permitir gerar documento de fornecedor que emite a pr�pria
			  |			 | nota sem informar o c�digo do Mix.
===============================================================================================================================
*/

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa--------: COMXPROC
Autor-----------: Alexandre Villar
Data da Criacao-: 28/01/2016
Descri��o-------: P.E. na inicializa��o do processamento do Totvs Colabora��o
Parametros------: Nenhum
Retorno---------: ( .T. ) Dados validos para inclusao. / ( .F. ) Dados n�o validados.
===============================================================================================================================
*/
User Function COMXPROC()

Local _lRet		:= .T. As Logical
Local _cAlias	:= GetNextAlias() As Character
Local _aArea 	:= FWGetArea() As Character
Local _nI		:= 0 As Numeric
Local _aChaveCTe:= {} As Array
Local _aChaveOri:= {} As Array
Local _oXML		:= Nil As Object
Local _oFullXML	:= Nil As Object
Local _cXML		:= '' As Character
Local _cChaveNF	:= '' As Character
Local _cArquiv	:= '' As Character
Local _cError	:= '' As Character
Local _cWarning	:= '' As Character
Local _cPrdFrete:= '' As Character
Local _aPrdFrete:= StrTokArr(SuperGetMV("MV_XMLPFCT",.F.,""),";") As Array
Local _aItens	:= {} As Array
Local _oBrowse	:= Nil As Object
Local _bLine	:= Nil As CodeBlock
//====================================================================================================
// Verificar campo de Status pois o PE � chamado duas vezes
//====================================================================================================
If SDS->DS_STATUS <> 'P'
	//CT-e de Anula��o n� deve ser importado. Manter at� a TOTVS tratar a situa��o.
	If SDS->DS_TIPO == 'T' .AND. SDS->DS_TPCTE == 'A'
		_lRet := .F.
		MsgStop("O CT-e Filial: "+ SDS->DS_FILIAL +", Documento "+ SDS->DS_DOC +", S�rie "+ SDS->DS_SERIE+ ", Fornecedor " +SDS->DS_FORNEC+"-"+SDS->DS_LOJA+", chave " +SDS->DS_CHAVENF +;
				" � do tipo Anula��o de Valor e n�o ir� gerar pr�-nota.","COMXPROC10")
	EndIf
	//Evita gera��o de documentos quando j� existe um com mesma chave.
	If _lRet
		BeginSQL Alias _cAlias
			SELECT SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE
			FROM  %Table:SF1% SF1
			WHERE SF1.D_E_L_E_T_ = ' '
			AND SF1.F1_CHVNFE	= %exp:SDS->DS_CHAVENF%
		EndSQL
		
		If (_cAlias)->( !Eof() )
			_lRet := .F.
			FWAlertWarning("A chave: "+ SDS->DS_CHAVENF +" j� existe em outro documento! "+ CRLF +;
						"Filial: "+  (_cAlias)->F1_FILIAL +"/ Documento: "+ (_cAlias)->F1_DOC +"/ S�rie: "+ (_cAlias)->F1_SERIE,;
						"Lan�amento duplicado! Verifique os dados e caso necess�rio informe a �rea de TI/Sistemas.","COMXPROC01")
		EndIf
	
		(_cAlias)->( DBCloseArea() )
	EndIf
	//Valida se n�o � um documento de entrada, formul�rio pr�rio do fornecedor
	If _lRet .And. !SDS->DS_TIPO == 'T'
		_cAlias := GetNextAlias()
		BeginSQL Alias _cAlias
			SELECT COUNT(1) QTD FROM  %Table:SDT%
				WHERE D_E_L_E_T_ = ' '
				AND DT_FILIAL = %exp:SDS->DS_FILIAL%	
				AND DT_DOC = %exp:SDS->DS_DOC%
				AND DT_SERIE = %exp:SDS->DS_SERIE%
				AND DT_FORNEC = %exp:SDS->DS_FORNEC%
				AND DT_LOJA = %exp:SDS->DS_LOJA%
				AND DT_CODCFOP <> ' ' 
				AND DT_CODCFOP < '5000'
		EndSQL
		If (_cAlias)->QTD > 0
			_lRet := .F.
			FWAlertWarning("A chave: "+ SDS->DS_CHAVENF +" � referente a um documento de entrada formul�rio pr�prio! "+ CRLF +;
					"Exclua o documento do Monitor e informe a �rea de TI/Sistemas.","COMXPROC11")
		EndIf
		(_cAlias)->(DBCloseArea())
	EndIf

	If _lRet .And. SubStr(SDS->DS_FORNEC,1,1)=='P' .And. SM0->M0_ESTENT == 'RS'
		DbSelectArea("SDT")
		SDT->(dbSetOrder(3))
		SDT->(dbSeek(SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
		If AllTrim(SDT->DT_COD) $ '08000000030/08000000065/08000000004/08000000062' .And. !SDT->DT_CODCFOP $ '5601/6601'
			DbSelectArea("ZZ4")
			ZZ4->(dbSetorder(1))
			If Empty(SDS->DS_L_MIX)
				_lRet := .F.
				FWAlertWarning("C�digo o Mix n�o informado. Informa��o obrigat�rio para NF-e de Produtor.","COMXPROC02")
			ElseIf ZZ4->(dbSeek(SDS->(DS_FILIAL+DS_L_MIX)+SDS->(DS_FORNEC+DS_LOJA+DS_SERIE+DS_DOC)))
				_lRet := .F.
				FWAlertWarning("NF-e de produtor j� associada ao Mix "+ZZ4->ZZ4_CODMIX+". Verifique informa��o na rotina de Contra Nota.","COMXPROC03")
			ElseIf ZZ4->(dbSeek(SDS->(DS_FILIAL+DS_L_MIX)+SDS->(DS_FORNEC+DS_LOJA)))
				_lRet := .F.
				FWAlertWarning("Foi encontrada uma NF-e para o Mix informado: "+ZZ4->ZZ4_CODMIX+". Doc: " + ZZ4->ZZ4_NUMCNF + " S�rie: "+ZZ4->ZZ4_SERIE+". Verifique informa��o na rotina de Contra Nota.","COMXPROC12")
			Else
				DbSelectArea("ZLE")
				ZLE->(dbSetorder(1))
				ZLE->(dbSeek(xFilial("ZLE")+SDS->DS_L_MIX))
				
				If U_VolLeite(xFilial("SDS"),ZLE->ZLE_DTINI,ZLE->ZLE_DTFIM,,,SDS->DS_FORNEC,SDS->DS_LOJA,,) <= 0
					_lRet := .F.
					FWAlertWarning("Produtor sem movimenta��o de leite no per�odo do Mix "+SDS->DS_L_MIX,"COMXPROC04")
				EndIf
			EndIf
		EndIf
	EndIf
	If _lRet .And. Empty(SDS->DS_L_MIX) .And. SA2->A2_L_NFPRO == "S"
		_lRet := .F.
		FWAlertWarning("C�digo o Mix n�o informado. Informa��o obrigat�ria para NF-e de Produtor que emitem sua pr�pria NF-e.","COMXPROC14")
	EndIf
	//====================================================================================================	
	// Processa CT-e para validar amarra��o com documento de origem
	//====================================================================================================	
    If _lRet .And. AllTrim(SDS->DS_ESPECI) == 'CTE'

		//Abre o XML
		DBSelectArea('CKO')
		CKO->( DBSetOrder(1) )
		CKO->( DBSeek( SDS->DS_ARQUIVO ) )
		_cXML := AllTrim( CKO->( CKO_XMLRET ) )
		
		//====================================================================================================
		// Processa se conseguir ler os dados do arquivo XML
		//====================================================================================================
		If !Empty( _cXML )
			
			_cXML := SubStr( _cXML , At( '<' , _cXML ) )
			
			//====================================================================================================
			// Inicializa o objeto do XML
			//====================================================================================================
			_oFullXML := XmlParser( _cXML , "_" , @_cError , @_cWarning )
			If ValType(XmlChildEx(_oFullXML,"_CTE")) == "O" //-- Nota de transporte
				_oXML := _oFullXML:_CTe
			ElseIf ValType(XmlChildEx(_oFullXML,"_CTESIMPPROC")) == "O"
				_oXML := _oFullXML:_CTeSimpProc:_CTeSimp
			ElseIf ValType(XmlChildEx(_oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
				If ValType(XmlChildEx(_oFullXML:_CTEPROC,"_ENVICTE")) == "O"
					_oXML := _oFullXML:_CTeProc:_ENVICTE:_Cte
				ElseIf ValType(XmlChildEx(_oFullXML:_CTEPROC,"_CTEOS")) == "O" //-- Nota de transporte CTEOS
					_oXML := _oFullXML:_CTeProc:_CTEOS
				Else
					_oXML := _oFullXML:_CTeProc:_Cte
				EndIf
			ElseIf ValType(XmlChildEx(_oFullXML,"_CTEOSPROC")) == "O" //-- Nota de transporte CTEOS
				_oXML := _oFullXML:_CTeOSProc:_CteOS
			EndIf			
			If ValType( XmlChildEx( _oXML , "_CTEPROC" ) ) == "O"
			    _aChaveCTe := {}
				_aChaveOri := {}
			    If ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTENORM" ) ) <> 'U'
		    	   	If ValType( XmlChildEx(	_oXML:_INFCTE:_INFCTENORM , '_INFDOC' ) ) <> 'U'
				    	If ValType( XmlChildEx(	_oXML:_INFCTE:_INFCTENORM:_INFDOC , '_INFNFE' ) ) <> 'U'
				    		_aChaveCTe := IIf( ValType( XmlChildEx(	_oXML:_INFCTE:_INFCTENORM:_INFDOC , "_INFNFE" ) ) == "O" , { _oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE } , _oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE )
				    	EndIf
				   EndIf
				ElseIf ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTESUB" ) ) <> 'U'
					_aChaveCTe := IIf( ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTESUB"	) ) == "O" , { _oXML:_INFCTE:_INFCTESUB	} , _oXML:_INFCTE:_INFCTESUB	)
				ElseIf ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTECOMP" ) ) <> 'U'
					_aChaveCTe := IIf( ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTECOMP"	) ) == "O" , { _oXML:_INFCTE:_INFCTECOMP	} , _oXML:_INFCTE:_INFCTECOMP	)
				ElseIf ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTEANU" ) ) <> 'U'
					_aChaveCTe := IIf( ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTEANU"	) ) == "O" , { _oXML:_INFCTE:_INFCTEANU	} , _oXML:_INFCTE:_INFCTEANU	)
				EndIf
				
				If !Empty( _aChaveCTe )

					DbSelectArea("SDT")
					SDT->(dbSetOrder(3))
					SDT->(dbSeek(SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
					While !SDT->(EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE) 
						IIf (!Empty(SDT->DT_CHVNFO),aAdd(_aChaveOri,SDT->DT_CHVNFO),)
						_cPrdFrete:= AllTrim(SDT->DT_COD)
						SDT->(dbSkip())
					Enddo
				
					For _nI := 1 To Len( _aChaveCTe )
						If ValType(XmlChildEx(_aChaveCTe[_nI],"_CHAVE")) == "O"
							_cChaveNF := Padr( AllTrim( _aChaveCTe[_nI]:_chave:Text ) , TamSX3("F1_CHVNFE")[1] )
						ElseIf ValType(XmlChildEx(_aChaveCTe[_nI],"_CHCTE")) == "O"
							_cChaveNF := Padr( AllTrim( _aChaveCTe[_nI]:_chCTE:Text ) , TamSX3("F1_CHVNFE")[1] )
						EndIF
						
						If aScan(_aChaveOri,_cChaveNF) == 0

							If Substr(_cChaveNF,21,2)=='55'
								_cArquiv:= '109'+_cChaveNF+'.xml'
							Else
								_cArquiv:= '214'+_cChaveNF+'.xml'
							EndIf
							
							If CKO->(dbSeek(_cArquiv))
								If CKO->CKO_FLAG == '2'
									_lRet := .F.
									FWAlertWarning("Chave referenciada consta na lista de Erros. Reprocesse o documento referenciado."+;
									" Filial: "+AllTrim(CKO->CKO_FILPRO)+". Chave referenciada: "+_cChaveNF,"COMXPROC05")
								ElseIf CKO->CKO_FLAG == '1' .And. AllTrim(CKO->CKO_FILPRO)==cFilAnt
									DBSelectArea('SF1')
									SF1->( DBSetOrder(8) )
									If !SF1->( DBSeek( AllTrim(CKO->CKO_FILPRO)+_cChaveNF ) )
										FWAlertWarning("Chave referenciada est� no monitor, mas n�o foi classificada. Classifique o documento referenciado e "+;
										"reprocesse o CT-e "+SDS->DS_DOC+"/"+SDS->DS_SERIE+". Filial: "+AllTrim(CKO->CKO_FILPRO)+" Chave referenciada: "+_cChaveNF,"COMXPROC06")
									Else
										FWAlertWarning("Chave referenciada est� classificada mas a amarra��o n�o foi realizada corretamente. "+;
										"Reprocesse o CT-e "+SDS->DS_DOC+"/"+SDS->DS_SERIE+". Filial: "+AllTrim(CKO->CKO_FILPRO)+" Chave referenciada: "+_cChaveNF,"COMXPROC07")
									EndIf
									_lRet := .F.
								ElseIf CKO->CKO_FLAG == '1' .And. !AllTrim(CKO->CKO_FILPRO)==cFilAnt
									BeginSQL Alias _cAlias
										SELECT COUNT(1) QTDREG
										  FROM %Table:SF1% SF1
										 WHERE SF1.D_E_L_E_T_ = ' '
										   AND SF1.F1_FILIAL <> %xFilial:SDS%
										   AND SF1.F1_CHVNFE = %exp:_cChaveNF%
									EndSql
				
									If (_cAlias)->QTDREG == 0
										_lRet := .F.
										FWAlertWarning("Chave referenciada est� no monitor, mas n�o foi classificada. Classifique o documento referenciado e "+;
										"reprocesse o CT-e "+SDS->DS_DOC+"/"+SDS->DS_SERIE+". Filial: "+AllTrim(CKO->CKO_FILPRO)+" Chave referenciada: "+_cChaveNF,"COMXPROC08")
									ElseIf (_cAlias)->QTDREG > 0 .And. _cPrdFrete==_aPrdFrete[1]
										_lRet := .F.
										FWAlertWarning("Chave referenciada est� classificada mas a amarra��o n�o foi realizada corretamente. "+;
										"Reprocesse o CT-e "+SDS->DS_DOC+"/"+SDS->DS_SERIE+". Filial: "+AllTrim(CKO->CKO_FILPRO)+" Chave referenciada: "+_cChaveNF,"COMXPROC09")
									EndIf
									(_cAlias)->(DBCloseArea())
								EndIf
								Exit
							EndIf
						EndIf
					Next _nI
				EndIf
			EndIf
		EndIf
	EndIf
	
	If _lRet .And. AllTrim(SDS->DS_ESPECI) == 'SPED'
		_cAlias := GetNextAlias()
		BeginSQL alias _cAlias
			SELECT COUNT(1) QTD FROM %Table:SDT% SDT
			WHERE SDT.D_E_L_E_T_ = ' '
			AND DT_FILIAL = %exp:SDS->DS_FILIAL%
			AND DT_DOC = %exp:SDS->DS_DOC%
			AND DT_SERIE = %exp:SDS->DS_SERIE%
			AND DT_FORNEC = %exp:SDS->DS_FORNEC%
			AND DT_LOJA = %exp:SDS->DS_LOJA%
			AND DT_CODCFOP IN ('5910','6910','5911','6911')
			AND DT_PEDIDO <> ' '
			AND NOT EXISTS (SELECT 1 FROM %Table:ZA7% ZA7
				WHERE ZA7.D_E_L_E_T_ = ' '
				AND ZA7.ZA7_FILIAL = DT_FILIAL
				AND ZA7.ZA7_CODPRD = DT_COD)
		EndSQL
		If (_cAlias)->QTD > 0
			_lRet := .F.
			FWAlertWarning("O documento "+SDS->DS_DOC+"/"+SDS->DS_SERIE+", Fornecedor "+SDS->DS_FORNEC+"/"+SDS->DS_LOJA+", Filial "+SDS->DS_FILIAL+" se trata de uma bonifica��o/amostra gr�tis e n�o permite vincular um pedido de compra. O documento ser� ignorado.","COMXPROC13")
		EndIf
		(_cAlias)->(DBCloseArea())
	EndIf

	If _lRet .And. AllTrim(SDS->DS_ESPECI) == 'SPED'
		_cAlias := GetNextAlias()
		BeginSQL alias _cAlias
			SELECT B1_COD, B1_DESC, B1_POSIPI, DT_I_POSIP
			FROM %Table:SB1% SB1, %Table:SDT% SDT
			WHERE SB1.D_E_L_E_T_ = ' '
			AND SDT.D_E_L_E_T_ = ' '
			AND B1_COD = DT_COD
			AND B1_POSIPI <> DT_I_POSIP
			AND DT_FILIAL = %exp:SDS->DS_FILIAL%
			AND DT_DOC = %exp:SDS->DS_DOC%
			AND DT_SERIE = %exp:SDS->DS_SERIE%
			AND DT_FORNEC = %exp:SDS->DS_FORNEC%
			AND DT_LOJA = %exp:SDS->DS_LOJA%
		EndSQL
		While _lRet .And. (_cAlias)->( !Eof() )
			aAdd( _aItens , { (_cAlias)->B1_POSIPI, (_cAlias)->DT_I_POSIP, (_cAlias)->B1_COD, (_cAlias)->B1_DESC } )
			(_cAlias)->(DBSkip())
		EndDo
		If _lRet .And. Len(_aItens) > 0
			_bLine := {|| {	_aItens[_oBrowse:nAt,1],;									//-- C�digo Produto
					_aItens[_oBrowse:nAt,2],;											//-- Descri��o Produto
					_aItens[_oBrowse:nAt,3],;											//-- NCM Produto
					_aItens[_oBrowse:nAt,4],}}											//-- NCM Nota

			Define MsDialog oDlg Title "Inconsist�ncia - COMXCOL01" From 000,000 To 330,900 Pixel// alturaXlargura
			//Calcula dimens�es
			oSize := FwDefSize():New(.F.,,,oDlg)
			oSize:AddObject( "CABECALHO",  100, 15, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "GETDADOS" ,  100, 75, .T., .T. ) // Totalmente dimensionavel 
			oSize:AddObject( "RODAPE"   ,  100, 10, .T., .T. ) // Totalmente dimensionavel
			
			oSize:lProp 	:= .T. // Proporcional             
			oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
			oSize:Process() 	   // Dispara os calculos   
			//-- Cabecalho
			@oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI") Say "Documento " + SDS->DS_DOC + " - " + "Serie " + SDS->DS_SERIE;
							+ " - " + "Fornecedor " + SDS->DS_FORNEC + " - " + "Loja " + SDS->DS_LOJA + CRLF;
							+ "Clique em CONTINUAR para processar o documento mesmo com a inconsist�ncia ou ABORTAR para processar o pr�ximo."  Pixel Of oDlg

			//-- Itens
			_oBrowse := TCBrowse():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
											oSize:GetDimension("GETDADOS","XSIZE"),oSize:GetDimension("GETDADOS","YSIZE"),;
											,{"NCM Cadastro","NCM XML","C�digo","Descri��o"},,oDlg,,,,,{||},,,,,,,,,.T.)
			_oBrowse:SetArray(_aItens)
			_oBrowse:bLine := _bLine
			
			//-- Botoes
			TButton():New(oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI"),;
							"Continuar",oDlg,{|| _lRet := .T. ,oDlg:End()},055,012,,,,.T.) 
			TButton():New(oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+060,;
							"Abortar",oDlg,{|| _lRet := .F. ,oDlg:End()},055,012,,,,.T.) 
			Activate Dialog oDlg Centered
			
			(_cAlias)->(DBCloseArea())

		EndIf
	EndIf
EndIf

FWRestArea(_aArea)

_oXML := Nil
_oFullXML := Nil
DelClassIntF()

Return _lRet
