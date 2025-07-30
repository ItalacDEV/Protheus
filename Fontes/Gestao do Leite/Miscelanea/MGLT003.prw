/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 21/07/2021 | Replica��o dos dados importados para os produtores filhos e tratamento da linha. Chamado 37147
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 20/02/2023 | Alterado para permitir importar o layout 1 v�rias vezes. Chamado 43052
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 30/04/2024 | Corre��o na convers�o da linha. Chamado 47117
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/*
===============================================================================================================================
Programa----------: MGLT003
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 10/12/2018
===============================================================================================================================
Descri��o---------: Rotina para impora��o dos dados de an�lises de Leite a partir de arquivo recebido do Laborat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT003()

Private _cPerg		:= "MGLT003"
Private _oSelf		:= nil

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	_cPerg											,; // Fun��o inicial
					"Importa An�lise de Qualidade"		,; // Descri��o da Rotina
					{|_oSelf| MGLT003P(_oSelf) }					,; // Fun��o do processamento
					"Rotina para efetuar a importa��o das An�lises de Qualidade recebidos dos laborat�rios. ",; // Descri��o da Funcionalidade
					_cPerg											,; // Configura��o dos Par�metros
					{}												,; // Op��es adicionais para o painel lateral
					.F.												,; // Define cria��o do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descri��o do Painel Auxiliar
					.F.												,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
                    .F.                                              ) // Se .T. cria apenas uma regua de processamento.

Return

/*
===============================================================================================================================
Programa----------: MGLT003P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 10/12/2018
===============================================================================================================================
Descri��o---------: Realiza o processamento da rotina.
===============================================================================================================================
Parametros--------: _oSelf
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT003P(_oSelf)

Local _nHandle		:= 0
Local _aDados		:= {}
Local _aTemp		:= {}
Local _aArq			:= {}
Local _aArqTmp		:= {}
Local _cEOL 		:= CHR(13) + CHR(10)
Local _nBuffer		:= 300
Local _nFilePos		:= 0
Local _nPos			:= 0
Local _cLine		:= "" 
Local _cBuffer		:=''
Local _nTamArq		:= 0
Local _nLidos		:= 0
Local _nProc		:= 0
Local _nX,_nZ		:= 0
Local _nI,_nJ		:= 0
Local _nLayout		:= 0
Local _lRet			:= .T.
Local _nQtdReg		:= 0
Local _nLimGor		:= SuperGetMV('LT_LIMGORI',.F., 5.5 )
Local _aNaoPrc		:= {}
Local _cCodPrd		:= ""
Local _cLojPrd		:= ""
Local _cSetor		:= ""
Local _cLinha		:= ""
Local _aUTC			:= {}
Local _cAlias		:= ""
Local _cMsg			:= ""
Local _cLaudo		:= ""
Local _cData		:= ""
Local _cHora		:= ""
Local _nVlrFx		:= 0

_aArqTmp := Directory(AllTrim(MV_PAR01)+"*.*")
For _nX := 1 to Len(_aArqTmp)
	If ".FAT" $ Upper(_aArqTmp[_nX][01]) .Or. ".CSV" $ Upper(_aArqTmp[_nX][01]) .Or. ".TXT" $ Upper(_aArqTmp[_nX][01])
		aAdd( _aArq ,AllTrim(MV_PAR01)+_aArqTmp[_nX][01])
	EndIf
Next _nX
If Empty(_aArq)
	MsgStop("N�o foram encontrados arquivos v�lidos no diret�rio informado.", "MGLT00301")
EndIf

For _nJ := 1 to Len(_aArq)
	//Reinicio as vari�veis a cada arquivo
	_aDados		:= {}
	_nLidos		:= 0
	_nProc		:= 0
	_nLayout	:= 0
	_lRet		:= .T.
	_nQtdReg	:= 0
	_aNaoPrc	:= {}
	_cSetor		:= ""
	_cLinha		:= ""
	_aUTC		:= {}
	_cLaudo		:= ""
	_cData		:= ""
	_cHora		:= ""
	_oSelf:SetRegua2(1)
	_oSelf:IncRegua2("")
	//Abre arquivo de texto
	If (_nHandle := FOpen(_aArq[_nJ])) >= 0
	    _oSelf:SetRegua1(1)
		_oSelf:IncRegua1("Abrindo arquivo...")
		_nTamArq:= FSeek(_nHandle, 0, 2) //Posiciona no fim do arquivo para pegar o tamanho
	    _nFilePos:= FSeek(_nHandle, 0, 0) // Posiciona no in�cio do arquivo, no primeiro caracter
		_oSelf:SetRegua1(_nTamArq)
	
		DBSelectArea("ZLB")
		ZLB->( DBSetOrder(1) )
	
		While !(_nFilePos < 0 .Or. _nFilePos >= _nTamArq) .And. _lRet
		    _cBuffer	:= SPACE(_nBuffer) //Aloca Buffer
			FRead(_nHandle, _cBuffer, _nBuffer) //L� os primeiros 100 caracteres do arquivo
			_nPos	:= AT(_cEOL, _cBuffer) // Procura o primeiro final de linha
			For _nX:= 1 To _nPos
				_oSelf:IncRegua1("Lendo arquivo "+_aArq[_nJ]+"...")
			Next _nX
			
		    If _nPos == 0
				MsgStop("Arquivo + "+_aArq[_nJ]+" + inconsist�nte. Favor acionar o �rea de TI.","MGLT00302")
				Return()
			EndIf	    	
		    // Leitura dos campos e grava��o dos dados na tabela
		    _cLine := Substr(_cBuffer, 0, _nPos)
			_aTemp:= StrTokArr(Upper(_cLine),';')
			
			//Evito de importar as poss�veis linhas em branco que esquecem no fim do arquivo
	        If Len(_cLine)>1
				If _aTemp[1] == 'LAUDO'
					_cLaudo	:= ValTexto(_aTemp[2],"Laudo",@_lRet,@_aNaoPrc)
				ElseIf _aTemp[1]  == 'DATA LAUDO'
					_cData	:= _aTemp[2]
				ElseIf _aTemp[1] == 'HORA LAUDO'
					_cHora	:= _aTemp[2]
				ElseIf "ETIQUETA;CODIGO INDUSTRIA;PRODUTOR;GORDURA;PROTEINA;LACTOSE;EST;ESD;CCS;CBT CFU;CRIOSCOPIA" $ _cLine
					_nLayout:= 1
				ElseIf "                ROTA     COLETA    ANALISE  ORCOL          IDPROD PRODUC     GORD     PROT     LACT      SOL      CCS       N� RELAT ROTA_AMOSTRA" $ _cLine
					_nLayout:= 2
				ElseIf "                ROTA     COLETA    ANALISE  ORCOL          IDPROD PRODUC      CPP TEMPER       N� RELAT ROTA_AMOSTRA" $ _cLine
					_nLayout:= 3
				ElseIf "DATA;CODIGO;PRODUTOR;RESULTADO DE CRIOSCOPIA" $ _cLine //Importa as crioscopias
					_nLayout:= 4
				ElseIf "DATA;CODIGO;PRODUTOR;VOLUME CONDENADO (LITROS)" $ _cLine //Importa as condena��es
					_nLayout:= 5
				ElseIf "DATA;CODIGO;PRODUTOR;VALOR;FAIXA;LINHA" $ _cLine //Importa valor gen�rico de acordo com o evento
					_nLayout:= 6
				ElseIf _nLayout == 1 .Or. _nLayout == 4 .Or. _nLayout == 5 .Or. _nLayout == 6
					aAdd(_aDados, StrTokArr(Upper(_cLine),';'))
				ElseIf _nLayout == 2
					aAdd(_aDados,{AllTrim(SubStr(_cLine,001,20)) ,; //01
								AllTrim(SubStr(_cLine,022,10)),; //02
								AllTrim(SubStr(_cLine,033,10)),; //03
								AllTrim(SubStr(_cLine,044,06)),; //04
								AllTrim(SubStr(_cLine,051,15)),; //05
								AllTrim(SubStr(_cLine,067,06)),; //06
								AllTrim(SubStr(_cLine,074,08)),; //07
								AllTrim(SubStr(_cLine,083,08)),; //08
								AllTrim(SubStr(_cLine,092,08)),; //09
								AllTrim(SubStr(_cLine,101,08)),; //10
								AllTrim(SubStr(_cLine,110,08)),; //11
								AllTrim(SubStr(_cLine,119,14)),; //12
								AllTrim(SubStr(_cLine,134,51))}) //13
				ElseIf _nLayout == 3
					aAdd(_aDados,{AllTrim( SubStr(_cLine,001,20)),;//01
								AllTrim(SubStr(_cLine,022,10)),;//02
								AllTrim(SubStr(_cLine,033,10)),;//03
								AllTrim(SubStr(_cLine,044,06)),;//04
								AllTrim(SubStr(_cLine,051,15)),;//05
								AllTrim(SubStr(_cLine,067,06)),;//06
								AllTrim(SubStr(_cLine,074,08)),;//07
								AllTrim(SubStr(_cLine,083,06)),;//08
								AllTrim(SubStr(_cLine,090,14)),;//09
								AllTrim(SubStr(_cLine,105,51))})//10
				EndIf
			EndIf
			_nLidos+=_nPos+1 //Salvo at� qual posi��o do arquivo j� foi lido desde a primeira posi��o
			_nFilePos:=FSeek(_nHandle, _nLidos,0) //Posiciono na pr�xima linha a partir do in�cio do arquivo
		EndDo
	    
		If !_lRet
			MsgStop("Arquivo: "+_aArq[_nJ]+" . Campo Laudo com conte�do inv�lido.", "MGLT00303")
		ElseIf _nLayout == 0
				MsgStop("Arquivo: "+_aArq[_nJ]+" . Layout incompat�vel com a rotina. Caso o arquivo esteja correto, favor acionar a TI/Sistemas.", "MGLT00304")
			_lRet := .F.
		ElseIf _nLayout == 1 .And. (Empty(_cLaudo) .Or. Empty(_cData) .Or. Empty(_cHora))
			MsgStop("Arquivo: "+_aArq[_nJ]+" . N�o � poss�vel processar o arquivo selecionado! N�o foi poss�vel verificar corretamente as informa��es do Laudo, data " +;
					"e/ou hora do arquivo. Verifique o arquivo informado e tente novamente.", "MGLT00305")
			_lRet := .F.
		EndIf
		
		If _lRet
			_nQtdReg := Len(_aDados)
		    _oSelf:SetRegua2(_nQtdReg)
		
			DBSelectArea('ZL3')
			ZL3->( DBSetOrder(1) )
			DBSelectArea("SA2")
			SA2->( DBSetOrder(1) )
			DBSelectArea("ZLD")
			ZLD->( DBSetOrder(1) )
		
			Begin Transaction
				For _nI := 1 To _nQtdReg

					_cLinha := ""//reinicio a vari�vel para o caso de n�o ser informada a linha no arquivo

					_oSelf:IncRegua2("Gravando registros...["+ StrZero(_nI,6) +"] de ["+ StrZero(_nQtdReg,6) +"]" ) 
					If _nLayout == 1
						_cCodPrd := Substr(_aDados[_nI][02],1,GetSx3Cache("A2_COD","X3_TAMANHO"))
						_cLojPrd := Substr(_aDados[_nI][02],GetSx3Cache("A2_COD","X3_TAMANHO")+2,GetSx3Cache("A2_COD","X3_TAMANHO")+1+GetSx3Cache("A2_LOJA","X3_TAMANHO"))
						
						If Val( AllTrim( StrTran( StrTran( _aDados[_nI][04] , '.' , '' ) , ',' , '.' ) ) ) > _nLimGor
							aAdd( _aNaoPrc , { _cCodPrd , _cLojPrd , 'Resultado da an�lise de gordura acima do limite permitido!' } )
							Loop
						EndIf
					ElseIf _nLayout == 4 .Or. _nLayout == 5 .Or. _nLayout == 6
						_cCodPrd := Substr(_aDados[_nI][02],1,GetSx3Cache("A2_COD","X3_TAMANHO"))
						_cLojPrd := Substr(_aDados[_nI][02],GetSx3Cache("A2_COD","X3_TAMANHO")+2,GetSx3Cache("A2_COD","X3_TAMANHO")+1+GetSx3Cache("A2_LOJA","X3_TAMANHO"))
						_cData := _aDados[_nI][01]
					Else
						_cCodPrd:= Substr(_aDados[_nI][05],1,GetSx3Cache("A2_COD","X3_TAMANHO"))
						_cLojPrd:= Substr(_aDados[_nI][05],GetSx3Cache("A2_COD","X3_TAMANHO")+2,GetSx3Cache("A2_COD","X3_TAMANHO")+1+GetSx3Cache("A2_LOJA","X3_TAMANHO"))
						_cData := _aDados[_nI][02]
						_cHora := '00:00:00'
		
						If _nLayout == 2
							_cLaudo	:= SubStr( _aDados[_nI][12] , 1 , AT( "/" , _aDados[_nI][12] ) - 1 )
							If Val( AllTrim( StrTran( StrTran( _aDados[_nI][07] , '.' , '' ) , ',' , '.' ) ) ) > _nLimGor
								aAdd( _aNaoPrc , { _cCodPrd , _cLojPrd , 'Resultado da an�lise de gordura acima do limite permitido!' } )
								Loop
							EndIf
						ElseIf _nLayout == 3
							_cLaudo := SubStr( _aDados[_nI][09] , 1 , AT( "/" , _aDados[_nI][09] ) - 1 )
						EndIf
						
						If Empty( _cLaudo )
							MsgStop("Arquivo: "+_aArq[_nJ]+" . N�o � poss�vel processar o arquivo selecionado! N�o foi poss�vel verificar corretamente as informa��es do Laudo, data " +;
									"e/ou hora do arquivo. Verifique o arquivo informado e tente novamente.","MGLT00306")
							_lRet := .F.
						EndIf
						
						If _lRet .And. _nLayout == 3
							If !ZLB->( DBSeek( xFilial('ZLB') + _cCodPrd + _cLojPrd + DtoS( CtoD( _cData ) ) ) )
								aAdd( _aNaoPrc , { _cCodPrd , _cLojPrd , 'N�o foi importada a an�lise do arquivo tipo "1" para esse produtor!' } )
								Loop
							EndIf
						EndIf
						
					EndIf
					
					//====================================================================================================
					// Verifica se o Produtor atual pertence ao Setor informado
					//====================================================================================================
					If _lRet .And. SA2->( DBSeek( xFilial('SA2') + _cCodPrd + _cLojPrd ) )
						_cAlias := GetNextAlias()
						
						_cFiltro := "% "
						If MV_PAR02 == 1// Somente Donos de Tanque?
							_cFiltro += " AND A2_COD = A2_L_TANQ AND A2_LOJA = A2_L_TANLJ "
						EndIf
						//Nesses layouts sempre s�o informados os filhos, manualmente
						If _nLayout == 4 .Or. _nLayout == 5 .Or. _nLayout == 6
							_cFiltro += " AND A2_COD = '" + _cCodPrd +"' "
							_cFiltro += " AND A2_LOJA = '" + _cLojPrd +"' "
						Else
							_cFiltro += " AND A2_L_TANQ = '" + _cCodPrd +"' "
							_cFiltro += " AND A2_L_TANLJ = '" + _cLojPrd +"' "
						EndIf
						_cFiltro += " %"

						BeginSql alias _cAlias
							SELECT A2_COD, A2_LOJA, A2_NOME
							FROM %Table:SA2% SA2
							WHERE SA2.D_E_L_E_T_ = ' '
							%exp:_cFiltro%
							AND A2_MSBLQL <> '1' 
							AND A2_L_ATIVO = 'S'
						EndSql
						Do While (_cAlias)->(!Eof())
							_cLinha := Space(6)
							_cSetor := ""
							If _nLayout == 6 .And. !Empty(_aDados[_nI][06]) .And. ZL3->( DBSeek( xFilial('ZL3') + PadR(AllTrim(_aDados[_nI][6]),6,'0')) )//Convers�o burra necess�ria porque apesar do tipo ser reconhecido como caracter, as valida��es retornam F para a �ltima coluna do arquivo
								_cLinha := ZL3->ZL3_COD
								_cSetor := ZL3->ZL3_SETOR
								aAdd(_aUTC,{(_cAlias)->A2_COD,(_cAlias)->A2_LOJA , (_cAlias)->A2_NOME, _cSetor, _cLinha})
							ElseIf ZLD->( DBSeek( xFilial('ZLD') + _cCodPrd + _cLojPrd + _cData) )
								_cSetor:= ZLD->ZLD_SETOR
								If _nLayout == 4 .Or. _nLayout == 5 .Or. _nLayout == 6
									_cLinha := ZLD->ZLD_LINROT
								EndIf
								aAdd(_aUTC,{(_cAlias)->A2_COD,(_cAlias)->A2_LOJA , (_cAlias)->A2_NOME, _cSetor, _cLinha})
							ElseIf ZL3->( DBSeek( xFilial('ZL3') + SA2->A2_L_LI_RO ) )
								_cSetor:= ZL3->ZL3_SETOR
								If _nLayout == 4 .Or. _nLayout == 5 .Or. _nLayout == 6
									_cLinha := ZL3->ZL3_COD
								EndIf
								aAdd(_aUTC,{(_cAlias)->A2_COD,(_cAlias)->A2_LOJA , (_cAlias)->A2_NOME, _cSetor, _cLinha})
							Else
								aAdd( _aNaoPrc , { (_cAlias)->A2_COD , (_cAlias)->A2_LOJA , 'Produtor n�o possui um setor v�lido para essa Filial no cadastro do Sistema (SA2)!' } )
							EndIf

							(_cAlias)->( DBSkip() )
						EndDo
						(_cAlias)->( DBCloseArea() )
						For _nX := 1 to 7
							If _nLayout == 3
								_cDCRTPF := Posicione("ZL9",1,xFilial("ZL9")+'000007',"ZL9_DESCRI")
								If _nX > 1
									Exit
								EndIf
							ElseIf _nLayout == 4// Importa apenas Crioscopia
								_cDCRTPF := Posicione("ZL9",1,xFilial("ZL9")+'000012',"ZL9_DESCRI")
								If _nX > 1
									Exit
								EndIf
							ElseIf _nLayout == 5// Importa apenas Condena��es
								_cDCRTPF := Posicione("ZL9",1,xFilial("ZL9")+'000013',"ZL9_DESCRI")
								If _nX > 1
									Exit
								EndIf
							ElseIf _nLayout == 6// Importa apenas Materia Gorda
								_cDCRTPF := Posicione("ZL9",1,xFilial("ZL9")+_aDados[_nI][05],"ZL9_DESCRI")
								If _nX > 1
									Exit
								EndIf
							Else
								_cDCRTPF := Posicione("ZL9",1,xFilial("ZL9")+StrZero(_nX,6),"ZL9_DESCRI")
							EndIf
	
							For _nZ := 1 To Len(_aUTC)
								_lGrava := .T.
								If ZLB->(DBSeek( xFilial('ZLB') + _aUTC[_nZ][01] + _aUTC[_nZ][02] + DtoS(CtoD(_cData))))
									While ZLB->(ZLB_FILIAL+ZLB_RETIRO+ZLB_RETILJ+ZLB_SETOR+ZLB_LINROT) + DtoS( ZLB->ZLB_DATA ) == xFilial('ZLB') + _aUTC[_nZ][01] + _aUTC[_nZ][02] + _aUTC[_nZ][04] + _aUTC[_nZ][05]+ DtoS(CtoD(_cData))
										If ( _nLayout == 2 .And. ZLB->ZLB_TIPOFX == StrZero(_nX,6));
											.Or. (_nLayout == 3 .And. ZLB->ZLB_TIPOFX == '000007');
											.Or. (_nLayout == 4 .And. ZLB->ZLB_TIPOFX == '000012');
											.Or. (_nLayout == 5 .And. ZLB->ZLB_TIPOFX == '000013');
											.Or. (_nLayout == 6 .And. ZLB->ZLB_TIPOFX == _aDados[1][5])
											aAdd( _aNaoPrc , { _aUTC[_nZ][01] , _aUTC[_nZ][02] , 'Laudo do produtor j� importado para ['+ _cDCRTPF +'] com a data ['+ DtoC( ZLB->ZLB_DATA ) +']!' } )
											_lGrava := .F.
											Exit
										EndIf
										ZLB->( DBSkip() )
									EndDo
								EndIf
								
								If _lGrava
									If _nLayout == 1
										ZLB->( Reclock( 'ZLB' , .T. ) )
										ZLB->ZLB_FILIAL	:= xFilial('ZLB')
										ZLB->ZLB_LAUDO	:= _cLaudo
										ZLB->ZLB_SETOR	:= _aUTC[_nZ][04]
										ZLB->ZLB_DATA	:= CtoD( _cData )
										ZLB->ZLB_HORA	:= _cHora
										ZLB->ZLB_ETIQTA	:= _aDados[_nI][01]
										ZLB->ZLB_RETIRO	:= _aUTC[_nZ][01]
										ZLB->ZLB_RETILJ	:= _aUTC[_nZ][02]
										ZLB->ZLB_TIPOFX	:= StrZero( _nX , 6 )
										ZLB->ZLB_VLRFX	:= Val( AllTrim( StrTran( StrTran( _aDados[_nI][_nX+3] , '.' , '' ) , ',' , '.' ) ) )
										ZLB->ZLB_DTINCL	:= Date()
										ZLB->ZLB_HRINCL	:= Time()
										ZLB->( MsUnlock() )
										_nProc++
									ElseIf _nLayout == 2
										If _nX > 6
											Exit
										EndIf
										ZLB->( Reclock( 'ZLB' , .T. ) )
										ZLB->ZLB_FILIAL	:= xFilial('ZLB')
										ZLB->ZLB_LAUDO	:= _cLaudo
										ZLB->ZLB_SETOR	:= _aUTC[_nZ][04]
										ZLB->ZLB_DATA	:= CtoD( _cData )
										ZLB->ZLB_HORA	:= _cHora
										ZLB->ZLB_RETIRO	:= _aUTC[_nZ][01]
										ZLB->ZLB_RETILJ	:= _aUTC[_nZ][02]
										ZLB->ZLB_TIPOFX	:= StrZero( _nX , 6 )
										If _nX == 5
											ZLB->ZLB_VLRFX	:= Val(AllTrim(StrTran(StrTran(_aDados[_nI][10],'.',''),',','.'))) - Val(AllTrim(StrTran(StrTran(_aDados[_nI][07],'.',''),',','.')))
										ElseIf _nX > 5
											ZLB->ZLB_VLRFX	:= Val(AllTrim(StrTran(StrTran(_aDados[_nI][_nX+5],'.',''),',','.')))
										Else
											ZLB->ZLB_VLRFX	:= Val(AllTrim(StrTran(StrTran(_aDados[_nI][_nX+6],'.',''),',','.')))
										EndIf
										ZLB->ZLB_DTINCL	:= Date()
										ZLB->ZLB_HRINCL	:= Time()
										ZLB->( MsUnlock() )
										_nProc++
									ElseIf _nLayout == 3
										If _nX > 1
											Exit
										EndIf
										
										ZLB->( Reclock( 'ZLB' , .T. ) )
										ZLB->ZLB_FILIAL	:= xFilial('ZLB')
										ZLB->ZLB_LAUDO	:= _cLaudo
										ZLB->ZLB_SETOR	:= _aUTC[_nZ][04]
										ZLB->ZLB_DATA	:= CtoD( _cData )
										ZLB->ZLB_HORA	:= _cHora
										ZLB->ZLB_RETIRO	:= _aUTC[_nZ][01]
										ZLB->ZLB_RETILJ	:= _aUTC[_nZ][02]
										ZLB->ZLB_TIPOFX	:= '000007'
										ZLB->ZLB_VLRFX	:= Val(AllTrim(StrTran(StrTran(_aDados[_nI][07],'.',''),',','.')))
										ZLB->ZLB_DTINCL	:= Date()
										ZLB->ZLB_HRINCL	:= Time()
										ZLB->( MsUnlock() )
										_nProc++
									ElseIf _nLayout == 4
										_nVlrFx := Val( AllTrim( StrTran( StrTran( _aDados[_nI][4] , '.' , '' ) , ',' , '.' ) ) )
										//Busco no cadastro de faixas e j� calculo o valor a ser abatido na litragem do dia
										_cAlias	:= GetNextAlias()
										BeginSql alias _cAlias
										SELECT  ROUND(SUM(ZLD_QTDBOM)* ZLA_VALOR /100,0) DESCLT
											FROM %table:ZLD% ZLD, %table:ZLA% ZLA
										  WHERE ZLD.D_E_L_E_T_ = ' '
										  AND ZLA.D_E_L_E_T_ = ' '
										  AND ZLD.ZLD_FILIAL = %xFilial:ZLD%
										  AND ZLA.ZLA_FILIAL = %xFilial:ZLA%
										  AND ZLD.ZLD_RETIRO = %exp:_aUTC[_nZ][01]%
										  AND ZLD.ZLD_RETILJ = %exp:_aUTC[_nZ][02]%
										  AND ZLD.ZLD_SETOR = ZLA.ZLA_SETOR
										  AND ZLD.ZLD_SETOR = %exp:_aUTC[_nZ][04]%
										  AND ZLD.ZLD_LINROT = %exp:_aUTC[_nZ][05]%
										  AND ZLA.ZLA_FXINI <= %exp:_nVlrFx%
										  AND ZLA.ZLA_FXFIM >= %exp:_nVlrFx%
										  AND ZLD.ZLD_DTCOLE = %exp:CtoD(_cData)%
										  AND ZLA.ZLA_COD = '000012'
										  GROUP BY ZLA_VALOR
										EndSql
										
										ZLB->( Reclock( 'ZLB' , .T. ) )
										ZLB->ZLB_FILIAL	:= xFilial('ZLB')
										ZLB->ZLB_LAUDO	:= ''
										ZLB->ZLB_SETOR	:= _aUTC[_nZ][04]
										ZLB->ZLB_LINROT	:= _aUTC[_nZ][05]
										ZLB->ZLB_DATA	:= CtoD( _aDados[_nI][01] )
										ZLB->ZLB_HORA	:= ''
										ZLB->ZLB_ETIQTA	:= ''
										ZLB->ZLB_RETIRO	:= _aUTC[_nZ][01]
										ZLB->ZLB_RETILJ	:= _aUTC[_nZ][02]
										ZLB->ZLB_TIPOFX	:= '000012'
										ZLB->ZLB_VLRFX	:= _nVlrFx
										ZLB->ZLB_VOLCRI	:= (_cAlias)->DESCLT
										ZLB->ZLB_DTINCL	:= Date()
										ZLB->ZLB_HRINCL	:= Time()
										ZLB->( MsUnlock() )
										
										(_cAlias)->(DBCloseArea())
										_nProc++
									ElseIf _nLayout == 5 .Or. _nLayout == 6
										ZLB->( Reclock( 'ZLB' , .T. ) )
										ZLB->ZLB_FILIAL	:= xFilial('ZLB')
										ZLB->ZLB_LAUDO	:= ''
										ZLB->ZLB_SETOR	:= _aUTC[_nZ][04]
										ZLB->ZLB_LINROT	:= _aUTC[_nZ][05]
										ZLB->ZLB_DATA	:= CtoD( _aDados[_nI][01] )
										ZLB->ZLB_HORA	:= ''
										ZLB->ZLB_ETIQTA	:= ''
										ZLB->ZLB_RETIRO	:= _aUTC[_nZ][01]
										ZLB->ZLB_RETILJ	:= _aUTC[_nZ][02]
										ZLB->ZLB_TIPOFX	:= IIf(_nLayout == 5,'000013',_aDados[_nI][05])
										ZLB->ZLB_VLRFX	:= IIf(_nLayout == 5,0,Val(AllTrim(StrTran(StrTran(_aDados[_nI][04],'.',''),',','.'))))
										ZLB->ZLB_VOLCRI	:= IIf(_nLayout == 5,Int(Val( AllTrim( StrTran( StrTran( _aDados[_nI][4] , '.' , '' ) , ',' , '.' ) ) )),0)
										ZLB->ZLB_DTINCL	:= Date()
										ZLB->ZLB_HRINCL	:= Time()
										ZLB->( MsUnlock() )
										_nProc++
									EndIf
								EndIf
							Next _nZ
						Next _nX
					Else
						aAdd( _aNaoPrc , { _cCodPrd , _cLojPrd , 'Produtor n�o encontrado no cadastro do Sistema (SA2)!' } )
						Loop
					EndIf
					
					_aUTC := {}
					
				Next _nI		
			End Transaction
		
			// Fecha arquivo	
		    fClose(_nHandle)
		    _cMsg := "Arquivo: "+_aArq[_nJ]+". Foram atualizados "+AllTrim(Str(_nProc))+" produtores com sucesso."
		    If Len( _aNaoPrc ) > 0
			    _cMsg := "Arquivo: "+_aArq[_nJ]+". Foram encontrados "+AllTrim(Str(Len( _aNaoPrc )))+" registros relacionados ao arquivo que n�o puderam ser gravados corretamente!"
			EndIf
			MsgInfo(_cMsg,"MGLT00307")
			If Len( _aNaoPrc ) > 0
				U_ITListBox( "Arquivo: "+_aArq[_nJ]+". Lista de Produtores n�o processados/gravados:" , {'C�digo','Loja','Descri��o'} , _aNaoPrc , .F. , 1 )
			EndIf
		EndIf
	Else
		MsgAlert("Arquivo: "+_aArq[_nJ]+". O arquivo est� vazio ou � inv�lido para an�lise! Verifique o arquivo e tente novamente.","MGLT00308")
	EndIf
Next _nJ
Return

/*
===============================================================================================================================
Programa----------: ValTexto
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 10/12/2018
===============================================================================================================================
Descri��o---------: Valido se o conte�do do campo informado � v�lido.
===============================================================================================================================
Parametros--------: _cString,_cTipo,_lRet,_aNaoPrc
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/
Static Function ValTexto(_cString,_cTipo,_lRet,_aNaoPrc)
Local _cChar:= ""
Local _nX	:= 0 
Local _cRet	:= ""

For _nX:= 1 To Len(_cString)
	_cChar:=SubStr(_cString, _nX, 1)
	If !IsDigit(_cChar)
		aAdd( _aNaoPrc , { "" ,"" , "C�digo do "+_cTipo+" possui caracteres alfanum�ricos." } )
		_lRet := .F.
		Exit
	EndIf
Next _nX
If _lRet
	_cRet := _cString
EndIf
Return(_cRet)
