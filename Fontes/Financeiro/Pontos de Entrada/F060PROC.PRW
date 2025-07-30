/*
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges 	  | 09/10/2019 | Chamado 28346 - Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz         | 04/01/2021 | Chamado 35137 - Declarar a variável _LREIMPRIME, caso não exista, para corrigir erro log. 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço      | 12/06/2023 | Chamado 43943 - Ajuste para seleção de conta marcada como default na ZZL e falha de seek na SA6.
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço      | 04/07/2023 | Chamado 44322 - Ajuste para seleção correta do banco padrão da ZZJ.
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: F060PROC
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 14/11/2016
===============================================================================================================================
Descrição---------: Ponto de Entrada de validação de inclusão de títulos no bordero - Chamado 16924
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function F060PROC()

Local _aArea		:= GetArea()
Local _aAreaSE1		:= SE1->(GetArea())
Local _cbancoP		:= ""
Local _ccontaP		:= ""
Local _csubcoP		:= ""
Local _cagencP		:= ""
Local _coperP		:= ""
Local _cAgencia		:= ParamIXB[2]
Local _cConta		:= ParamIXB[3]
Local _abco			:= {}
Local _cTexto		:= ""
Local _cAux			:= ""
Local _nopc			:= 0
Local _aDatSacado	:= {}

If Type("_LREIMPRIME") == "U"
   _LREIMPRIME := .F.
EndIf 

Dbselectarea("ZZJ")
DbSetOrder(1)
If ZZJ->(dbseek(xfilial("ZZJ")+alltrim(cfilant)))
	Do while alltrim(ZZJ->ZZJ_FILIAL) == alltrim(xFilial("ZZJ")) .and. alltrim(ZZJ->ZZJ_FILACE) == alltrim(cfilant)
		aadd(_abco, {ZZJ->ZZJ_BANCO,ZZJ->ZZJ_CONTA,ZZJ->ZZJ_AGENCI,ZZJ->ZZJ_SUBCON,ZZJ->ZZJ_OPER,ZZJ->ZZJ_DEFAUL})
					//      1             2               3               4                5           6
		ZZJ->( dbskip() )
	End
EndIf

dbSelectArea("TRB")
TRB->(dbSetOrder(1))
TRB->(dbGoTop())

While !TRB->(Eof())
	dbSelectArea("SE1")
	SE1->( dbSetOrder(1) )
	If SE1->( dbSeek(xFilial("SE1")+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO) )
	
	   	If EMPTY(ALLTRIM(SE1->E1_NUMBCO)) 
			
			//Se tem incosistência entre campos de idcnab e nosso numero e parâmetro
			// de bloqueio estiver ativo vai impedir a geração do bordero
			If (!EMPTY(ALLTRIM(SE1->E1_IDCNAB)) .OR. !EMPTY(ALLTRIM(SE1->E1_I_NUMBC))) .AND. U_ITGETMV("ITBLCNAB",.F.)
		
						_cTexto += "Prefixo.....: " + SE1->E1_PREFIXO + CRLF
						_cTexto += "Título......: " + SE1->E1_NUM + CRLF
						_cTexto += "Parcela.....: " + SE1->E1_PARCELA + CRLF
						_cTexto += "Tipo........: " + SE1->E1_TIPO + CRLF
						_cTexto += "" + CRLF

						// Retiro a marcaçao, para não incluir o registro no borderô
						TRB->( RecLock( "TRB" , .F. ) )
						TRB->E1_OK := " "
						TRB->( MsUnLock() )
						
			Else
			
				Begin Transaction

				//============================================================
				//procura se o cliente tem um banco padrão
				//============================================================
				_cpadrao := posicione("SA1", 1,xfilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_I_BOLE")
			
				If empty(_cpadrao)
					
					If Len(_abco) > 0 
			
						For _nopc := 1 To Len(_abco)
							If substr(_cpadrao,1,3) == _abco[_nopc][1] .OR. (Empty(_cpadrao) .And. Len(_abco) = 1)
								_cbancoP 	:= 	alltrim(_abco[_nopc][1])
								_ccontaP 	:=	alltrim(_abco[_nopc][2])
								_csubcoP 	:=	alltrim(_abco[_nopc][4])
								_cagencP 	:= 	alltrim(_abco[_nopc][3])
								_coperP		:=	alltrim(_abco[_nopc][5])
								Exit
							ElseIf alltrim(_abco[_nopc][6]) == "S"
								_cbancoP 	:= 	alltrim(_abco[_nopc][1])
								_ccontaP 	:=	alltrim(_abco[_nopc][2])
								_csubcoP 	:=	alltrim(_abco[_nopc][4])
								_cagencP 	:= 	alltrim(_abco[_nopc][3])
								_coperP		:=	alltrim(_abco[_nopc][5])
								Exit							
							EndIf
						Next _nopc
						
					EndIf			
					
				EndIf
			
				_cPortado := IIf( Empty( SE1->E1_PORTADO )	, _cbancoP , SE1->E1_PORTADO	)
				_cAgencia := IIf( Empty( SE1->E1_AGEDEP )	, _cagencP , SE1->E1_AGEDEP		)
				_cConta   := IIf( Empty( SE1->E1_CONTA ) 	, _ccontaP , SE1->E1_CONTA		)	            

				//Posiciona o SA6 (Bancos)
				DBSelectArea("SA6")
				SA6->( DBSetOrder(1) )
				SA6->( DBSeek(xFilial("SA6")+U_ITKEY(_cPortado, "A6_COD")+U_ITKEY(_cAgencia, "A6_AGENCIA")+U_ITKEY(_cConta, "A6_NUMCON")) )		

				//Posiciona o SA1 (Cliente)
				DBSelectArea("SA1")
				SA1->( DBSetOrder(1) )
				SA1->( DBSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA) )
				
				//Posiciona o SEE (Parametros banco)
				DbSelectArea("SEE")
				SEE->( DbSetOrder(1) )
				If SEE->( DbSeek(xFilial("SEE");
							+alltrim(_cPortado)+space(TAMSX3("EE_CODIGO")[1]-len(alltrim(_cPortado)));
							+alltrim(_cAgencia)+space(TAMSX3("EE_AGENCIA")[1]-len(alltrim(_cAgencia)));
							+alltrim(_cConta)+space(TAMSX3("EE_CONTA")[1]-len(alltrim(_cConta)));
							+alltrim(_csubcoP) ) )
				
					_cNumFaixa := StrZero(Val(SEE->EE_FAXATU) + 1,10)		       
											
					While !MayIUseCode(_cPortado + _cAgencia + _cConta + xFilial("SEE") + _cNumFaixa)	//verifica se esta sendo usado na memoria
						_cNumFaixa := StrZero(Val(_cNumFaixa) + 1,10)							  		//busca o proximo numero disponivel 						
					EndDo  
									
					SEE->( RecLock( "SEE" , .F. ) )
						SEE->EE_FAXATU := _cNumFaixa
					SEE->( MsUnlock() )
				EndIf
				
				_aDadosBanco	:= {	SA6->A6_COD																									,; 	//Numero do Banco
										Left( SA6->A6_NOME , AT("-",SA6->A6_NOME)-1 )																,; 	//Nome do Banco
										IIf( SA6->A6_COD=="479" , StrZero(Val(AllTrim(SEE->EE_AGBOSTO)),7),u_agencia(SA6->A6_COD,SA6->A6_AGENCIA))	,; 	//Agência
										IIf( SA6->A6_COD=="479" , AllTrim(SEE->EE_CODEMP), u_conta(SA6->A6_COD,SA6->A6_NUMCON) )						,; 	//Conta Corrente
										IIf( SA6->A6_COD $ "479/033" , "" ,SubStr( AllTrim(SA6->A6_NUMCON) ,Len(AllTrim(SA6->A6_NUMCON)) , 1 ) )	,; 	//Dígito da conta corrente
										AllTrim(SEE->EE_I_CARTE)																					,; 	//Carteira
										0																											 }	//VARIACAO //AllTrim(SEE->EE_VARIACA)}
						
				_aDatSacado	:= {	AllTrim( SA1->A1_NOME )						,; //Razão Social
									AllTrim( SA1->A1_COD )						,; //Código
									AllTrim( SA1->A1_END )+"-"+SA1->A1_BAIRRO	,; //Endereço
									AllTrim( SA1->A1_MUN )						,; //Cidade
									SA1->A1_EST									,; //Estado
									SA1->A1_CEP									 } //CEP
				
				_nVlrAbat	:= SomaAbat( SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_PARCELA , "R" , 1 ,, SE1->E1_CLIENTE , SE1->E1_LOJA )
				
				_CB_RN_NN	:= u_Ret_cBarra(Subs(_aDadosBanco[1],1,3)+"9",;
											Subs(_aDadosBanco[3],1,4),;
											_aDadosBanco[4],;
											_aDadosBanco[5],;                                                     
											_aDadosBanco[6],;
											AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),;
											(SE1->E1_SALDO-_nVlrAbat),;
											SE1->E1_VENCTO,;
											SEE->EE_CODEMP,;
											_cNumFaixa,;
											Iif(SE1->E1_DECRESC > 0,.t.,.f.),;
											SE1->E1_PARCELA)
				
				//Gravo o desbloqueio do título
				RecLock("SE1",.F.)
					SE1->E1_NUMBCO	:= StrTran(StrTran(_CB_RN_NN[3],"/",""),"-","")	//GRAVA NOSSO NUMERO NO TITULO
					SE1->E1_I_NUMBC	:= StrTran(StrTran(_CB_RN_NN[3],"/",""),"-","")	//GRAVA NOSSO NUMERO NO TITULO BKP
				MsUnLock()
			
				End Transaction
		  	Endif
		Endif
	EndIf
	TRB->( dbSkip() )
End

If !Empty(_cTexto)
	_cAux := "LOG DE INCLUSÃO - BORDERÔ" + CRLF
	_cAux += "====================================================" + CRLF
	_cAux += "" + CRLF
	_cAux += "Os títulos selecionados, aparentemente já foram enviados para o banco e estão com problemas, estes registros estão sendo bloqueados." + CRLF
	_cAux += "Para desbloquear os títulos, acesse a rotina Desbloqueio Cnab em Atualizações / Específico Italac." + CRLF
	_cAux += "" + CRLF
	_cTexto := _cAux + _cTexto + CRLF
	
	fLog(_cTexto)
EndIf

RestArea(_aAreaSE1)
RestArea(_aArea)
Return

/*
===============================================================================================================================
Programa----------: fLog
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 16/11/2016
===============================================================================================================================
Descrição---------: Função criada para impressão de log, ao final da validação da seleção dos títulos
===============================================================================================================================
Parametros--------: _cTexto - Texto a ser mostrado em uma janela de log
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fLog(_cTexto)

Local _cFile	:= ""
Local _cMask	:= "Arquivos Texto" + "(*.TXT)|*.txt|"
Local _oDlg		:= NIL
Local _oFont	:= NIL
Local _oMemo	:= NIL

Define Font _oFont Name "Mono AS" Size 5, 12

Define MsDialog _oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

@ 5, 5 Get _oMemo Var _cTexto Memo Size 200, 145 Of _oDlg Pixel 
_oMemo:bRClicked := { || AllwaysTrue() }
_oMemo:oFont     := _oFont

Define SButton From 153, 175 Type  1 Action _oDlg:End() Enable Of _oDlg Pixel // Apaga
Define SButton From 153, 145 Type 13 Action ( _cFile := cGetFile( _cMask, "" ), If( _cFile == "", .T., ;
MemoWrite( _cFile, _cTexto ) ) ) Enable Of _oDlg Pixel

Activate MsDialog _oDlg Center

Return
