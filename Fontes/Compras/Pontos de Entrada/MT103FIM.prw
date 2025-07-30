/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |22/04/2025| Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
Lucas Borges  |22/06/2025| Chamado 50617. Revis�es diversas visando padronizar os fontes
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
===============================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
===============================================================================================================================
Andre    - Alex Wallauer - 24/10/24 - 21/11/24 -  48952  - Novo tratamento para os produtos com rastro / lotes.
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MT103FIM
Autor-------------: Talita Teixeira
Data da Criacao---: 16/09/2013
Descri��o---------: PE executado ap�s concluir grava��o de documento de entrada. O ponto de entrada MT103FIM encontra-se no 
					final da fun��o A103NFISCAL. Ap�s o destravamento de todas as tabelas envolvidas na grava��o do documento 
					de entrada, depois de fechar a opera��o realizada neste. � utilizado para realizar alguma opera��o ap�s a 
					grava��o da NFE.
Parametros--------: PARAMIXB[1]	-> N -> Op��o Escolhida pelo usuario no aRotina
					PARAMIXB[2]	-> N -> Se o usuario confirmou a opera��o de grava��o da NF
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT103FIM

Local _aArea		:= FWGetArea() As Array
Local _aAreaSF9		:= SF9->(GetArea()) As Array
Local _aAreaSF1		:= SF1->(GetArea()) As Array
Local _aAreaSD1		:= SD1->(GetArea()) As Array
Local _aAreaSB8		:= SB8->(GetArea()) As Array
Local _aAreaSD5		:= SD5->(GetArea()) As Array
Local _aAreaSDD		:= SDD->(GetArea()) As Array
Local _nOpcao		:= PARAMIXB[1] As Numeric	// Op��o Escolhida pelo usuario no aRotina
Local _nConf		:= PARAMIXB[2] As Numeric	// Se o usuario confirmou a opera��o de grava��o da NF
Local _aPedZY1		:= {} As Array			// Pedidos para serem gerados monitoramento
Local _cocorr		:= "" As Character
Local _nX			:= 0 As Numeric
Local _aocor		:= {} As Array
Local _cCodUsr		:= "" As Character
Local _cUserAux		:= "" As Character
Local _cPedido		:= "" As Character
Local _aDadPSW 		:= {} As Array
Local _cfilusr		:= "" As Character
Local _lachou		:= .F. As Logical
Local _cordem		:= "" As Character
Local _cQryZY1		:= "" As Character
Local _cSeque		:= "" As Character
Local _cQrySF9		:= "" As Character
Local _nPosLoc  	:= aScan( aHeader , {|x| AllTrim(x[2]) == "D1_LOCAL"}) As Numeric
Local _cAlmox		:=  "" As Character
Local _cMovim		:= SuperGetMV("IT_MOVDIR",.F.,"560") As Character
Local _aItensAuto	:= {} As Array
Local _aSD3 		:= {} As Array
Local _aCabD3		:= {} As Array
Local _cObsSC		:= "" As Character
Local _nQtdLib      := 0 As Numeric
Local _ni			:= 0 As Numeric
Local _lRLeite		:= !AllTrim( Upper( FUNNAME() ) ) $"U_MGLT009/MGLT010" As Logical
Local _cAlias		:= '' As Character
Local _cnome        := UsrFullName(__cUserId) As Character
Local _cCFOP		:= SuperGetMV("LT_CFEXCL3",.F.,"1925/2925") As Character
Local _cFiltro		:= "" As Character
Local _cLote        := "" As Character
Local _dDtvalid     := CTOD("") As Date

If l103GAuto == .T. //.F. (Atualizando impostos) / .T. (Gravando documento)
    If (_nOpcao == 3 .Or. _nOpcao == 4) .AND. _lRLeite
        If _nConf == 1
            If TYPE("_cFUNDFIX") = "C"
                DbSelectArea("SF1")
                RecLock("SF1", .F.)
                SF1->F1_I_FUNDF := _cFUNDFIX   
                MsUnlock()
            EndIf
        EndIf
    EndIf
	//================================================================================
	//Grava Peso Total bruto do item na SD1
	//================================================================================
	If cTipo == "D"
		GravaPeso()
	EndIf

	If _lRLeite
		If _nOpcao == 3 .Or. _nOpcao == 4
			//=============================================================================
			//Verifica se � ativo fixo e monta matriz com ocorr�ncias
			// S� roda esta parte se fornecedor n�o for produtor e nota n�o for devolu��o
			//=============================================================================
			If _nConf == 1 .and. !(cTipo == "D") .and. !(substr(alltrim(SF1->F1_FORNECE),1,1) == "P")
				_lachou := .F.
				//decodifica usu�rio digitador
				_cCodUsr	:= 	substr(SF1->F1_USERLGI, 3,1) + substr(SF1->F1_USERLGI, 7,1) + substr(SF1->F1_USERLGI,11,1) + substr(SF1->F1_USERLGI,15,1) + substr(SF1->F1_USERLGI, 2,1) 
				_cCodUsr 	+= 	substr(SF1->F1_USERLGI, 6,1) + substr(SF1->F1_USERLGI,10,1) + substr(SF1->F1_USERLGI,14,1) + substr(SF1->F1_USERLGI, 1,1) + substr(SF1->F1_USERLGI, 5,1) 
				_cCodUsr 	+= 	substr(SF1->F1_USERLGI, 9,1) + substr(SF1->F1_USERLGI,13,1) + substr(SF1->F1_USERLGI,17,1) + substr(SF1->F1_USERLGI, 4,1) + substr(SF1->F1_USERLGI, 8,1) 
					
				If SubStr( _cCodUsr , 1 , 2 ) == "#@"
					_cUserAux	:= AllTrim( SubStr( _cCodUsr , 3 ) )
					If !Empty(_cUserAux)
						PSWOrder(1)
						PSWSeek( _cUserAux )
						_aDadPSW		:= PSWRet()
						_cUserAux	:= Capital( AllTrim( _aDadPSW[1][4] ) )
						_cfilusr     :=  substr( AllTrim( _aDadPSW[1][22] ), 3 ,2)
					Else
						_cUserAux:= "Nao indentificado"
						_cfilusr :=  _cUserAux							   
					EndIf
				Else
					_cUserAux	:= AllTrim( _cCodUsr )
					If !Empty(_cUserAux)
						PSWOrder(2)
						_aDadPSW		:= PSWRet()
						_cUserAux	:= Capital( AllTrim( _aDadPSW[1][4] ) )
						_cfilusr     :=  substr( AllTrim( _aDadPSW[1][22] ), 3 ,2)
					Else
						_cUserAux:= "Nao indentificado"
						_cfilusr :=  _cUserAux
					EndIf
				EndIf
				
				DBSelectArea("SD1")
				SD1->( DBSetOrder(1) )
				SD1->( Dbgotop() )
			
				If SD1->( DBSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA  ) )
					Do While 	SD1->D1_FILIAL == SF1->F1_FILIAL 	.AND.;
							SD1->D1_DOC == SF1->F1_DOC 			.AND.;
							SD1->D1_SERIE == SF1->F1_SERIE 		.AND.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .AND.;
							SD1->D1_LOJA == SF1->F1_LOJA 		
					
						_cocorr 	:= 	"Itens sem ocorr�ncia"
						_cdesc		:=	"Itens sem ocorr�ncia"
						_cordem	:= "9"
							
						//Verifica ocorr�ncias
						If Posicione("SF4",1,SD1->D1_FILIAL+SD1->D1_TES,"F4_ATUATF") == "S"
							_cocorr 	:= "NF com gera��o de Ativo Fixo"
							_cdesc		:= "Itens lan�ado cuja a TES utilizada gerou Ativo Fixo"
							_lachou 	:= .T.
							_cordem 	:=	"3" 
						ElseIf ALLTRIM(posicione("SB1",1,xfilial("SB1")+SD1->D1_COD,"B1_GRUPO")) == '1002'
							_cocorr	:= "NF utilizando Produtos do Grupo de Ativos porem a TES n�o gerou Ativo"
							_cdesc		:= "Itens lan�ados que cont�m Produto do Grupo de Ativo por�m a TES utilizada n�o gerou Ativo Fixo"
							_lachou 	:= .T.
							_cordem	:= "1"
						ElseIf posicione("SC7",1,SD1->D1_FILIAL+SD1->D1_PEDIDO+SD1->D1_ITEMPC,"C7_I_APLIC") == "I"
							_cocorr 	:= "NF do Tipo Investimento sem gera��o Ativo"
							_cdesc		:= "Itens lan�ados cujo o Pedido de Compra e do tipo 'Investimento'  por�m a TES utilizada n�o gerou Ativo Fixo"
							_lachou	:= .T.
							_cordem	:= "2"
						EndIf
					
						aAdd( _aocor, { SD1->D1_FILIAL,;		//01
										SD1->D1_DOC,;			//02
										SD1->D1_SERIE,;		//03
										SD1->D1_FORNECE,;		//04
										SD1->D1_LOJA,;		//05
										SD1->D1_COD,;			//06
										SD1->D1_QUANT,;		//07
										SD1->D1_VUNIT,;		//08
										SD1->D1_TOTAL,;		//09
										SD1->D1_TES,;			//10
										SD1->D1_CF,;			//11
										SD1->D1_CC,;			//12
										SD1->D1_PEDIDO,;		//13
										SD1->D1_ITEMPC,;		//14
										_cocorr,;				//15
										_cdesc,;				//16
										SF1->F1_DTDIGIT,;		//17
										_cfilusr + "/" + substr(_cCodUsr,3,6) + " - " +  _cUserAux,; //18
										SD1->D1_ITEM,;		//19
										_cordem	})			//20
						SD1->( Dbskip() )
					EndDo
				
					//Se teve ocorr�ncias envia os workflows
					If len(_aocor) > 0 .and. _lachou
						_aocor := asort(_aocor,,,{|x,y| x[20]+x[19] < y[20]+y[19]})
						FWMSGRUN( ,{|oProc| EnviaWF(_aocor) },"Aguarde...","Enviando Workflow 1-Ocorrencias...")
					EndIf
				EndIf
			EndIf
			
			//=============================================================================
			//Verifica se � entrada com inss de per�odo REinf fechado
			// S� roda esta parte se fornecedor � pessoa jur�dica e o m�s da 
			// data de emiss�o do documento de entrada j� existe na tabela de 
			// fechamento do reinf, V0C
			//=============================================================================
			V0C->(Dbsetorder(2))
			_aocor2 := {}
			_cemissa := SUBSTR(DTOS(SF1->F1_EMISSAO),5,2) + SUBSTR(DTOS(SF1->F1_EMISSAO),1,4)
					
			If _nConf == 1 .and. alltrim(posicione("SA2",1,xfilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA ,"A2_TIPO")) == "J" ;
						.AND. V0C->(Dbseek('01'+_cemissa))
			
				//Procura se algum item tem inss
				_lachou2 := .F.

				//decodifica usu�rio digitador
				_cCodUsr	:= 	substr(SF1->F1_USERLGI, 3,1) + substr(SF1->F1_USERLGI, 7,1) + substr(SF1->F1_USERLGI,11,1) + substr(SF1->F1_USERLGI,15,1) + substr(SF1->F1_USERLGI, 2,1) 
				_cCodUsr 	+= 	substr(SF1->F1_USERLGI, 6,1) + substr(SF1->F1_USERLGI,10,1) + substr(SF1->F1_USERLGI,14,1) + substr(SF1->F1_USERLGI, 1,1) + substr(SF1->F1_USERLGI, 5,1) 
				_cCodUsr 	+= 	substr(SF1->F1_USERLGI, 9,1) + substr(SF1->F1_USERLGI,13,1) + substr(SF1->F1_USERLGI,17,1) + substr(SF1->F1_USERLGI, 4,1) + substr(SF1->F1_USERLGI, 8,1) 
					
				If SubStr( _cCodUsr , 1 , 2 ) == "#@"
					_cUserAux	:= AllTrim( SubStr( _cCodUsr , 3 ) )
					If !Empty(_cUserAux)
						PSWOrder(1)
						PSWSeek( _cUserAux )
						_aDadPSW		:= PSWRet()
						_cUserAux	:= Capital( AllTrim( _aDadPSW[1][4] ) )
						_cfilusr     :=  substr( AllTrim( _aDadPSW[1][22] ), 3 ,2)
					Else
						_cUserAux:= "Nao indentificado"
						_cfilusr :=  _cUserAux
					EndIf
				Else
					_cUserAux	:= AllTrim( _cCodUsr )
					If !Empty(_cUserAux)
						PSWOrder(2)
						_aDadPSW		:= PSWRet()
						_cUserAux	:= Capital( AllTrim( _aDadPSW[1][4] ) )
						_cfilusr     := Substr( AllTrim( _aDadPSW[1][22] ), 3 ,2)
					Else
						_cUserAux:= "Nao indentificado"
						_cfilusr :=  _cUserAux
					EndIf
				EndIf

				DBSelectArea( "SD1" )
				SD1->( DBSetOrder(1) )
				SD1->( Dbgotop() )
			
				If SD1->( DBSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA  ) )
					Do While 	SD1->D1_FILIAL == SF1->F1_FILIAL 	.AND.;
							SD1->D1_DOC == SF1->F1_DOC 			.AND.;
							SD1->D1_SERIE == SF1->F1_SERIE 		.AND.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .AND.;
							SD1->D1_LOJA == SF1->F1_LOJA 		
					
						_cocorr := "Itens sem inss"
						_cdesc	:= "Itens sem inss"
						_cordem	:= "9"
							
						//Verifica ocorr�ncias
						If SD1->D1_VALINS > 0
							_cocorr 	:= "NF com com INSS e RFIS fechado"
							_cdesc		:= "Itens lan�ado com valor de INSS"
							_lachou2 	:= .T.
							_cordem 	:=	"1" 
						EndIf

						aAdd( _aocor2, {SD1->D1_FILIAL,;		//01
										SD1->D1_DOC,;			//02
										SD1->D1_SERIE,;			//03
										SD1->D1_FORNECE,;		//04
										SD1->D1_LOJA,;			//05
										SD1->D1_COD,;			//06
										SD1->D1_QUANT,;			//07
										SD1->D1_VUNIT,;			//08
										SD1->D1_TOTAL,;			//09
										SD1->D1_TES,;			//10
										SD1->D1_CF,;			//11
										SD1->D1_CC,;			//12
										SD1->D1_PEDIDO,;		//13
										SD1->D1_ITEMPC,;		//14
										_cocorr,;				//15
										_cdesc,;				//16
										SF1->F1_DTDIGIT,;		//17
										_cfilusr + "/" + substr(_cCodUsr,3,6) + " - " +  _cUserAux,; //18
										SD1->D1_ITEM,;			//19
										_cordem,;  				//20
										SD1->D1_VALINS,;		//21
										SF1->F1_EMISSAO	})		//22
						SD1->( Dbskip() )
					EndDo
				
					//Se teve ocorr�ncias envia os workflows
					If len(_aocor2) > 0 .and. _lachou2
						_aocor2 := asort(_aocor2,,,{|x,y| x[20]+x[19] < y[20]+y[19]})
						
						FWMSGRUN( ,{|oProc| EnviaWF2(_aocor2) },"Aguarde...","Enviando Workflow 2-Ocorrencias...")
					EndIf
				EndIf			   
			EndIf
		EndIf
			
		If _nConf == 1
			//==============================================================================
			// Varro todo o aCols, para pegar todos os pedidos vinculados a Nota de Entrada,
			// por�m apenas um pedido do mesmo para fazer o monitoramento.
			//==============================================================================
			For _nX := 1 To Len(aCols)
				If aCols[_nX][Len(aCols[_nX])]//Somente linhas nao deletadas
					Loop
				EndIf
				If !Empty(aCols[_nX, aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})])
					If _cPedido <> aCols[_nX, aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})]
						aAdd(_aPedZY1, {SF1->F1_FILIAL, aCols[_nX, aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})], SF1->F1_DOC, SF1->F1_SERIE,aCols[_nX, aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC"})]})
						_cPedido := aCols[_nX, aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})]
					EndIf
				EndIf
			Next _nX
		
			If Len(_aPedZY1) > 0
				For _nX := 1 To Len(_aPedZY1)
					_cencerra := "S"
					If Posicione("SC7",1,_aPedZY1[_nX,1] + _aPedZY1[_nX,2], "C7_ENCER") == "E"
						_c7filial := SC7->C7_FILIAL
						_c7numero := SC7->C7_NUM
						Do While SC7->C7_FILIAL ==  _c7filial .AND. SC7->C7_NUM == _c7numero
							If SC7->C7_ENCER != "E"
								_cencerra := " "
							EndIf
							SC7->( Dbskip() )
						EndDo
					Else
						_cencerra := " "
					EndIf
		
					_cQryZY1 := "SELECT MAX(ZY1_SEQUEN) ZY1_SEQUEN "
					_cQryZY1 += "FROM " + RetSqlName("ZY1") + " "
					_cQryZY1 += "WHERE ZY1_FILIAL = '" + _aPedZY1[_nX,1] + "' "
					_cQryZY1 += "  AND ZY1_NUMPC = '" + _aPedZY1[_nX,2] + "' "
					_cQryZY1 += "  AND D_E_L_E_T_ = ' ' "
					_cQryZY1 := ChangeQuery(_cQryZY1)
					MPSysOpenQuery(_cQryZY1,"TRBZY1")
		
					dbSelectArea("TRBZY1")
					TRBZY1->(dbGoTop())
		
					If !TRBZY1->(Eof()) .And. !Empty(TRBZY1->ZY1_SEQUEN)
						_cSeque := Soma1(TRBZY1->ZY1_SEQUEN)
							
						dbSelectArea("ZY1")
						ZY1->(dbSetOrder(1))
						If _nOpcao == 3		// Inclus�o de NF
							ZY1->(RecLock("ZY1", .T.))
								Replace ZY1->ZY1_FILIAL	With _aPedZY1[_nX,1]
								Replace ZY1->ZY1_NUMPC	With _aPedZY1[_nX,2]
								Replace ZY1->ZY1_SEQUEN	With _cSeque
								Replace ZY1->ZY1_DTMONI	With Date()
								Replace ZY1->ZY1_HRMONI	With Time()
								Replace ZY1->ZY1_COMENT	With "Foi Inclu�da a NF: " + _aPedZY1[_nX,3] + " S�rie: " + _aPedZY1[_nX,4]
								Replace ZY1->ZY1_CODUSR	With __cUserId
								Replace ZY1->ZY1_NOMUSR	With _cnome
								Replace ZY1->ZY1_DTNECE With Posicione("SC7",1,_aPedZY1[_nX,1] + _aPedZY1[_nX,2], "C7_DATPRF")
								Replace ZY1->ZY1_DTFAT  With Posicione("SC7",1,_aPedZY1[_nX,1] + _aPedZY1[_nX,2], "C7_I_DTFAT") 
							ZY1->(MsUnLock())
						ElseIf _nOpcao == 4	// Classifica��o da NF
							ZY1->(RecLock("ZY1", .T.))
								Replace ZY1->ZY1_FILIAL	With _aPedZY1[_nX,1]
								Replace ZY1->ZY1_NUMPC	With _aPedZY1[_nX,2]
								Replace ZY1->ZY1_SEQUEN	With _cSeque
								Replace ZY1->ZY1_DTMONI	With Date()
								Replace ZY1->ZY1_HRMONI	With Time()
								Replace ZY1->ZY1_COMENT	With "Foi Classificada a NF: " + _aPedZY1[_nX,3] + " S�rie: " + _aPedZY1[_nX,4]
								Replace ZY1->ZY1_CODUSR	With __cUserId
								Replace ZY1->ZY1_NOMUSR	With _cnome
								Replace ZY1->ZY1_DTNECE With Posicione("SC7",1,_aPedZY1[_nX,1] + _aPedZY1[_nX,2], "C7_DATPRF") 
								Replace ZY1->ZY1_DTFAT  With Posicione("SC7",1,_aPedZY1[_nX,1] + _aPedZY1[_nX,2], "C7_I_DTFAT") 
								Replace ZY1->ZY1_ENCMON	With _cencerra
							ZY1->(MsUnLock())
						ElseIf _nOpcao == 5	// Exclus�o da NF
							ZY1->(RecLock("ZY1", .T.))
								Replace ZY1->ZY1_FILIAL	With _aPedZY1[_nX,1]
								Replace ZY1->ZY1_NUMPC	With _aPedZY1[_nX,2]
								Replace ZY1->ZY1_SEQUEN	With _cSeque
								Replace ZY1->ZY1_DTMONI	With Date()
								Replace ZY1->ZY1_HRMONI	With Time()
								Replace ZY1->ZY1_COMENT	With "Foi Exclu�da a NF: " + _aPedZY1[_nX,3] + " S�rie: " + _aPedZY1[_nX,4]
								Replace ZY1->ZY1_CODUSR	With __cUserId
								Replace ZY1->ZY1_NOMUSR	With _cnome
								Replace ZY1->ZY1_DTNECE With Posicione("SC7",1,_aPedZY1[_nX,1] + _aPedZY1[_nX,2], "C7_DATPRF")
								Replace ZY1->ZY1_DTFAT  With Posicione("SC7",1,_aPedZY1[_nX,1] + _aPedZY1[_nX,2], "C7_I_DTFAT") 
								Replace ZY1->ZY1_ENCMON	With _cencerra
							ZY1->(MsUnLock())
						EndIf
					EndIf
					
					TRBZY1->(dbCloseArea())
					
					Dbselectarea("ZY1")
					ZY1->(Dbsetorder(1))
					ZY1->(Dbgotop())
					If ZY1->(Dbseek(_aPedZY1[_nX,1]+_aPedZY1[_nX,2]))
						Do While ZY1->ZY1_FILIAL == _aPedZY1[_nX,1] .AND. ZY1->ZY1_NUMPC == _aPedZY1[_nX,2]
							ZY1->(RecLock("ZY1", .F.))
							Replace ZY1->ZY1_ENCMON	With _cencerra
							ZY1->(MsUnLock())
							ZY1->( Dbskip() )
						EndDo
					EndIf
				Next _nX
			EndIf
		EndIf
		
		//==============================
		// Movimenta��o Interna de sa�da
		//==============================
		//Arrays mestre, ir�o conter os arrays dos v�rios movimentos internos, um para cada centro de custo
		_maitens := {}
		_macabec := {}

		If (_nOpcao == 3 .Or. l103Class) .And. _nConf == 1
			For _nX := 1 To Len(aCols)
				_cAlmox := Alltrim(aCols[_nX][_nPosLoc])
				If aCols[_nX][Len(aCols[_nX])]//Somente linhas nao deletadas
					Loop
				EndIf
				If aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL"})] == _cAlmox
					dbSelectArea("SF4")
					SF4->(dbSetOrder(1))
					If SF4->(dbSeek(xFilial("SF4") + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})]))
						If SF4->F4_ESTOQUE == "S"
							dbSelectArea("SC7")
							SC7->(dbSetOrder(1))
							If SC7->(dbSeek(xFilial("SC7") + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})] + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC"})]))
								If SC7->C7_I_USOD == "S"
									dbSelectArea("SC1")
									SC1->(dbSetOrder(1))
									If SC1->(dbSeek(xFilial("SC1") + SC7->C7_NUMSC))
										_cObsSC := SC1->C1_OBS
									EndIf
									dbSelectArea("SB1")
									SB1->(dbSetOrder(1))
									If SB1->(dbSeek(xFilial("SB1") + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})]))
										_aSD3 := {}
										_aCabD3 := {}
						
										DBSelectArea("SD3")
										SD3->( DBSetOrder(3) )
		
										_aCabD3 := {	/*{ "D3_DOC"		, _cDocEst		, NIL },*/ ;
															{ "D3_TM"		, _cMovim		, NIL },;
															{ "D3_EMISSAO"	, dDataBase		, NIL },;
															{ "D3_CC"		, aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"})]	, NIL } } //SC7->C7_CC
		
										_aSD3 := {	{ "D3_FILIAL"	, xFilial("SD3")												, NIL },;
													{ "D3_COD"		, aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})]	, NIL },;
													{ "D3_LOCAL"	, _cAlmox														, NIL },;
													{ "D3_QUANT"	, aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})]	, NIL },;
													{ "D3_GRUPO"	, SB1->B1_GRUPO													, NIL },;
													{ "D3_UM"		, SB1->B1_UM													, NIL },;
													{ "D3_SEGUM"	, SB1->B1_SEGUM													, NIL },;
													{ "D3_CONTA"	, SB1->B1_CONTA													, NIL },;
													{ "D3_TIPO"		, SB1->B1_TIPO													, NIL },;
													{ "D3_USUARIO"	, cUserName														, NIL },;
													{ "D3_I_OBS"	, _cObsSC														, NIL } }
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				If Len(_aSD3) > 0
					_aItensAuto := {}
					aAdd(_aItensAuto, _aSD3)
					_aSD3 := {}
					
					//inclui arrays nos arrays mestre
					If len(_macabec) == 0
						aAdd(_macabec,{SC7->C7_CC,_aCabD3})
						aAdd(_maitens,{SC7->C7_CC,_aItensAuto})
					Else
						_np := ascan(_maitens,{|_vAux|_vAux[1]==SC7->C7_CC}) 
						If _np > 0
							_ni := 1
							Do While _ni <= len(_aItensAuto)
								aAdd(_maitens[_np][2],_aItensAuto[_ni])
								_ni++
							EndDo
						Else
							aAdd(_macabec,{SC7->C7_CC,_aCabD3})
							aAdd(_maitens,{SC7->C7_CC,_aItensAuto})
						EndIf
					EndIf
				EndIf
			Next _nX
		
			BEGIN TRANSACTION
			
			_ni := 1
			Do While  _ni <= len(_macabec) 
				lMsErroAuto := .F.
				CTM:=_cMovim
				lSalva241:=l241
				l241:=.T.		
				MSExecAuto({|x,y,z| MATA241(x,y,z)},_macabec[_ni][2],_maitens[_ni][2],3)
				l241:=lSalva241		
				If lMsErroAuto
					If __lSx8
						RollBackSX8()
					EndIf
					MOSTRAERRO()				
					DisarmTransaction()
					EXIT
				Else
					If __lSx8
						While ( GetSX8Len() > nSaveSX8 )
							ConfirmSX8()
						End
					EndIf
					_cDoc_SD3:=SD3->D3_DOC
					//se movimentou ok atualiza SC7 gravando sequ�ncias do SD3
					For _nX := 1 To Len(aCols)
						If aCols[_nX][Len(aCols[_nX])]//Somente linhas nao deletadas
							Loop
						EndIf
						dbSelectArea("SC7")
						SC7->(dbSetOrder(1))
						If SC7->(dbSeek(xFilial("SC7") + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})] + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC"})]))
							dbSelectArea("SD3")
							SD3->(dbSetOrder(2))
							If SD3->(dbSeek(xFilial("SD3") + _cDoc_SD3 + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})])) //_macabec[_ni][2][1][2]
								SC7->(RecLock("SC7",.F.))
								SC7->C7_I_SEQD3 := SD3->D3_NUMSEQ
								SC7->(MsUnlock())
							EndIf
						EndIf
					Next _nX
				EndIf
				_ni++
			EndDo
			END TRANSACTION
		EndIf
		
		//=====
		// CIAP
		//=====
		If (_nOpcao == 3 .Or. _nOpcao == 4) .And. _nConf == 1
			dbSelectArea( "SD1" )
			SD1->( dbSetOrder(1) )
			SD1->( dbGoTop() )
		
			If SD1->( dbSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA  ) )
				While	SD1->D1_FILIAL == SF1->F1_FILIAL 	.AND.;
						SD1->D1_DOC == SF1->F1_DOC 			.AND.;
						SD1->D1_SERIE == SF1->F1_SERIE 		.AND.;
						SD1->D1_FORNECE == SF1->F1_FORNECE .AND.;
						SD1->D1_LOJA == SF1->F1_LOJA
		
					_cQrySF9 := "SELECT R_E_C_N_O_ F9_I_RECNO "
					_cQrySF9 += "FROM " + RetSqlName("SF9") + " "
					_cQrySF9 += "WHERE F9_FILIAL	= '" + SD1->D1_FILIAL + "' "
					_cQrySF9 += "  AND F9_FORNECE	= '" + SD1->D1_FORNECE + "' "
					_cQrySF9 += "  AND F9_LOJAFOR	= '" + D1_LOJA + "' "
					_cQrySF9 += "  AND F9_DOCNFE	= '" + D1_DOC + "' "
					_cQrySF9 += "  AND F9_SERNFE	= '" + D1_SERIE + "' "
					_cQrySF9 += "  AND F9_ITEMNFE	= '" + D1_ITEM + "' "
					_cQrySF9 += "  AND D_E_L_E_T_	= ' ' "
					_cQrySF9 := ChangeQuery(_cQrySF9)
					MPSysOpenQuery(_cQrySF9,"TRBSF9")
						
					dbSelectArea("TRBSF9")
					TRBSF9->(dbGoTop())
						
					If !TRBSF9->(Eof())
						While !TRBSF9->(Eof())
							dbSelectArea("SF9")
							SF9->(dbGoTo(TRBSF9->F9_I_RECNO))
								SF9->(RecLock("SF9",.F.))
									SF9->F9_FUNCIT := POSICIONE("ZZI",1,SD1->D1_FILIAL+posicione("SC7",1,SD1->D1_FILIAL+SD1->D1_PEDIDO+SD1->D1_ITEMPC,"C7_I_CDINV"),"ZZI_DESINV") //FUNCAO DO BEM
								SF9->(MsUnLock())
							TRBSF9->(dbSkip())
						EndDo
					EndIf
		
					dbSelectArea("TRBSF9")
					TRBSF9->(dbCloseArea())
					SD1->(dbSkip())
				EndDo
			EndIf
		EndIf

		//====================================
		// TRANSFERENCIA DE LEITE A GRANEL
		//====================================
		If (_nOpcao == 3 .OR. _nOpcao == 4) .And. _nConf == 1//TRANSFERENCIA DE LEITE A GRANEL na inclusao manual da nota e classificao tb
			If !(cFilAnt $ SuperGetMV('IT_FLNGRA',.F.,'10')) //Filiais que n�o fazem transfer�ncia de leite a granel
				//Detecta se � pre nota
				//_nposf1 := SF1->(Recno())
				SF1->(Dbsetorder(1))
				If SF1->(Dbseek(cFilAnt+cnfiscal+cSerie+ca100for+cloja)) //Verifica se j� tem o SF1, se n�o tiver n�o tem como fazer transfer�ncia
					If _lRLeite //N�o � recep��o de leite 
						fwmsgrun( ,{|| MT103Trans() },"Aguarde...","Processando transfer�ncia de leite a granel...")
					EndIf
				EndIf
			EndIf
		EndIf
		
		//====================================
		// TRANSFERENCIA DE CREME
		//====================================
		If (_nOpcao == 3 .OR. _nOpcao == 4) .And. _nConf == 1//TRANSFERENCIA DE CREME na inclusao manual da nota e classificao tb
			If !(cFilAnt $ SuperGetMV('IT_CRNGRA',.F.,'40')) //Filiais que n�o fazem transfer�ncia de creme  a granel
				If _lRLeite //N�o � recep��o de leite
					fwmsgrun( ,{|| MT103TranC() },"Aguarde...","Processando transfer�ncia de creme a granel...")
				EndIf
			EndIf
		EndIf

		//=============================================================================================
		//Criar workflow para avisar o solicitante de uma compra que seu produto j� chegou na empresa
		//=============================================================================================
		If (_nOpcao == 3 .OR. _nOpcao == 4) .And. _nConf == 1 .And. SF1->F1_TIPO == "N" .AND. _lRLeite //N�o � recep��o de leite
			FWMSGRUN( ,{|oProc| U_EnviaWF3(.F.,oProc) },"Aguarde...","Enviando Workflow 3-Solicitante...")
		EndIf	

		//=============================================================================================
		//Criar workflow para avisar o solicitante de uma compra que seu produto j� chegou na empresa
		//=============================================================================================
		If (_nOpcao == 3 ) .And. _nConf == 1 .And. _lRLeite //N�o � recep��o de leite
			If (SF1->F1_IRRF <> 0 .OR. SF1->F1_VALPIS <> 0 .OR. SF1->F1_VALCOFI <> 0 .OR. SF1->F1_VALCSLL <> 0)
				FWMSGRUN( ,{|oProc| U_EnviaWF4(.F.,oProc) },"Aguarde...","Enviando Workflow 4-NF fora do prazo...")
			EndIf
		EndIf	

		//=======================
		// CARGA DA TROCA NOTA
		//=======================
		If (_nOpcao == 3 .OR. _nOpcao == 4) .And. _nConf == 1//LIBERA PEDIDO DE FATURAMENTO na inclusao manual da nota e classificao tb
			If U_PosPedFaT(SF1->F1_FORNECE+SF1->F1_LOJA,SF1->F1_DOC+SF1->F1_SERIE) == "ACHOU_PF" //Fun��o se encontra no rdmake MT100TOK.PRW
				// Liberac�o de Pedido - reserva de estoque
				_cFilCarregamento:=""
				cCarga    :=""
		        l2Mensagem:=.F.
				lMensagem :=.F.
				_aLog     :={}
				_cMPedido :=SC5->C5_FILIAL+ " " +SC5->C5_NUM

				SC9->( DbSetOrder(1) )
				SC6->( DbSetOrder(1) )
				If !SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )//A funcao U_PosPedFaT() deixa o SC5 posicionado
				   lMensagem:=.T.
				EndIf
					
				Begin Transaction		
					Do While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM 
						If !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))		
							_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO
						Else
							_nQtdLib := SC9->C9_QTDLIB
						EndIf
							
						If _nQtdLib # SC6->C6_QTDVEN
							lMensagem:=.T.
							EXIT
						EndIf
						SC6->( DBSkip() )
					EndDo
			
					lMensagem:=(lMensagem .OR. !SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) ))
					
					If !lMensagem
					    _cMPedido:=SC5->C5_FILIAL+ " " +SC5->C5_NUM
						If ForcaLib( SC5->C5_FILIAL + SC5->C5_NUM )
						   _cFilCarregamento:=SC5->C5_I_FLFNC
						   _cPedCarregamento:=SC5->C5_I_PDPR
			   
						   SC5->( DbSetOrder(1) )
						   If SC5->( DBSeek( _cFilCarregamento + _cPedCarregamento ) )//Posiciono no Pedido de Carregamento para pegar a carga da filial de carregamento
						      cCarga:=SC5->C5_I_CARGA//A carga fica na filial de carregamento
							  l2Mensagem:=.T.
						   Else
						      FWAlertInfo("Pedido de Carregamento n�o encontrado: "+_cFilCarregamento+ " " +_cPedCarregamento+;
							          " Corrija o problema do pedido de Carregamento e refa�a a Classificacao.","MT103FIM01")
						      lMensagem:=.T.
						   EndIf
						Else
						   lMensagem:=.T.
						EndIf
					EndIf
			
					If lMensagem
						FWAlertWarning("Problema da Libera��o do pedido de faturamento: "+_cMPedido+;
							" Corrija o problema da Libera�ao do pedido de faturamento e refa�a a Classificacao.","MT103FIM02")
					ElseIf !Empty(cCarga) .AND. !Empty(_cFilCarregamento)
						Processa( {|| U_MT103GerCarga(_cFilCarregamento+cCarga,.F.,"")  } ,, "Geracao de Carga de Carregamento..." )
					ElseIf l2Mensagem
						FWAlertWarning("Problema para encontrar a Carga de Carregamento: "+cCarga+" "+_cFilCarregamento+" do pedido de faturamento: "+_cMPedido+;
							" Corrija o problema da Carga de Carregamento e refa�a a Classificacao ou fa�a a Carga de Carregamento manualmente.","MT103FIM03")
					EndIf
				End Transaction	
				MostraLog(_aLog)
			EndIf
		EndIf
		//==============================================================================================================================
		// Exclus�o de recep��o gerada indevidamente. Essa situa��o ocorre porque a gera��o da informa��o � feita na inclus�o
		// da pre-nota e nesse momento n�o tenho todas as vari�veis para serem analisadas.
		//==============================================================================================================================
		If (_nOpcao == 3 .OR. _nOpcao == 4) .And. _nConf == 1 .And. SF1->F1_TIPO == "N"
			DBSelectArea('ZLX')
			ZLX->( DBSetOrder(2) )
			If ZLX->( DBSeek( xFilial('ZLX') + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )
				_cFiltro := "% D1_CF IN " + FormatIn(_cCFOP,"/")+" %"
				_cAlias	:= GetNextAlias()
				BeginSQL Alias _cAlias
				SELECT COUNT(1) QTD
				FROM %Table:SD1% SD1
				WHERE D_E_L_E_T_ = ' '
					AND D1_FILIAL = %exp:SF1->F1_FILIAL%
					AND D1_DOC = %exp:SF1->F1_DOC%
					AND D1_SERIE = %exp:SF1->F1_SERIE%
					AND D1_FORNECE = %exp:SF1->F1_FORNECE%
					AND D1_LOJA = %exp:SF1->F1_LOJA%
					AND ((D1_NFORI <> ' ' AND D1_SERIORI <> ' ') 
							OR (%exp:_cFiltro%))
				EndSQL
				
				If (_cAlias)->QTD > 0
					If ZLX->ZLX_STATUS == '1' .And. Empty( ZLX->ZLX_CODANA )
						ZLX->( RecLock( 'ZLX' , .F. ) )
						ZLX->( DBDelete() )
						ZLX->( MsUnLock() )
					Else
						FWAlertWarning('A recep��o de Leite de Terceiros vinculada � esse documento n�o pode ser exclu�da. Realize o processo manualmente.',"MT103FIM04")
					EndIf
				EndIf
				(_cAlias)->(DbCloseArea())
			EndIf
		EndIf
	EndIf

	If (_nOpcao == 3 .Or. l103Class) .And. _nConf == 1
		SD1->( DBSetOrder(1) )
		If SD1->( DBSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA  ) )
			_cErro := ""
			
			Do While SD1->D1_FILIAL  == SF1->F1_FILIAL 	.AND.;
					SD1->D1_DOC     == SF1->F1_DOC		.AND.;
					SD1->D1_SERIE   == SF1->F1_SERIE 	.AND.;
					SD1->D1_FORNECE == SF1->F1_FORNECE  .AND.;
					SD1->D1_LOJA    == SF1->F1_LOJA 
			  
	          	If Rastro(SD1->D1_COD)
					SB8->(dbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID
					If SB8->(MsSeek(xFilial("SB8") + SD1->D1_COD + SD1->D1_Local + SD1->D1_LOTECTL + SD1->D1_NUMLOTE ))
                    	_dDtvalid := SB8->B8_DTVALID
				 	EndIf

					SDD->(dbSetOrder(1)) // DD_FILIAL + DD_DOC + DD_PRODUTO + DD_Local + DD_LOTECTL + DD_NUMLOTE
					_cCodSDD:=GetSxENum("SDD","DD_DOC")
					Do While SDD->(!EOF()) .AND. SDD->( DbSeek(xFilial("SDD") +_cCodSDD ) )//Por causa da Validacao do DD_DOC: ExistChav("SDD") .And. NaoVazio()
						ConfirmSX8()
						_cCodSDD:=GetSxENum("SDD","DD_DOC")
					EndDo

					aVetor := {{"DD_DOC"	 ,_cCodSDD                   ,NIL},;
								{"DD_PRODUTO",SD1->D1_COD                ,NIL},;
								{"DD_LOCAL"  ,SD1->D1_Local              ,NIL},;
								{"DD_I_LTORI",_cLote	                 ,NIL},;
								{"DD_LOTECTL",SD1->D1_LOTECTL	         ,NIL},;
								{"DD_LOTEFOR",SD1->D1_LOTEFOR	         ,NIL},;
								{"DD_QUANT"  ,SD1->D1_QUANT              ,NIL},;
								{"DD_DTVALID",_dDtvalid                  ,NIL},;
								{"DD_OBSERVA",SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,NIL},;
								{"DD_MOTIVO" ,"IN"                       ,NIL}}                                               	
								
					lMsErroAuto:=.F.
					MSExecAuto({|x, y| MATA275(X, Y)},aVetor, 3)  //BLOQUEANDO O LOTE NOVO - Opcoes da rotina autom�tica: 3-Bloqueio (INCLUI) / 4-Libera��o (ALTERA)
					If lMsErroAuto
						_cErro+=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MT103FIM.LOG")+"]"+CRLF
					Else    
						ConfirmSX8()
					EndIf
				 EndIf
		      	SD1->(DBSKIP())
			EndDo
			If !Empty(_cErro)
				FWAlertError("MostraErro() DO MSExecAuto DO MATA275: " +_cErro,"MT103FIM05")
			EndIf
		    SB8->(dbSetOrder(1)) 
		EndIf
	ElseIf _nOpcao == 5 .And. _nConf == 1
		SD1->( DBSetOrder(1) )
		If SD1->( DBSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA  ) )
			Do While SD1->D1_FILIAL  == SF1->F1_FILIAL 	.AND.;//ERRO 2 - N�O TINHA WHILE
					SD1->D1_DOC     == SF1->F1_DOC		.AND.;
					SD1->D1_SERIE   == SF1->F1_SERIE 	.AND.;
					SD1->D1_FORNECE == SF1->F1_FORNECE  .AND.;
					SD1->D1_LOJA    == SF1->F1_LOJA 
			  
	        	If Rastro(SD1->D1_COD)

					SB8->(dbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID
					If SB8->( MsSeek(xFilial("SB8") + SD1->D1_COD + SD1->D1_Local + SD1->D1_LOTECTL + SD1->D1_NUMLOTE) )
						SB8->(RECLOCK("SB8",.F.))
						SB8->(DbDelete())
						SB8->(MSUNLOCK())
					EndIf
			
					SD5->(dbSetOrder(2)) // D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ                                                                                                                                                                         
					//           // SD5->D5_FILIAL + SD5->D5_PRODUTO + SD5->D5_Local + SD5->D5_LOTECTL + SD5->D5_NUMLOTE + D5_NUMSEQ
					If SD5->(DbSeek(xFilial("SD5") + SDD->DD_PRODUTO + SDD->DD_Local + SDD->DD_LOTECTL + SDD->DD_NUMLOTE ))
						Do While SD5->D5_FILIAL + SD5->D5_PRODUTO + SD5->D5_Local + SD5->D5_LOTECTL + SD5->D5_NUMLOTE == ;//ERRO 3 - N�O TINHA WHILE
								SDD->DD_FILIAL + SDD->DD_PRODUTO + SDD->DD_Local + SDD->DD_LOTECTL + SDD->DD_NUMLOTE .And. SD5->(!EOF())
							SD5->(RECLOCK("SD5",.F.))
							SD5->(DbDelete())
							SD5->(MSUNLOCK())
							SD5->(Dbskip())
						EndDo
					EndIf

					SDD->(dbSetOrder(2)) // DD_FILIAL+DD_PRODUTO+DD_LOCAL+DD_LOTECTL+DD_NUMLOTE+DD_MOTIVO                                                                                                                                                                        
					If SDD->( DbSeek(xFilial("SDD") + SD1->D1_COD + SD1->D1_Local + SD1->D1_LOTECTL + SD1->D1_NUMLOTE) )
						SDD->(RECLOCK("SDD",.F.))
						SDD->(DbDelete())
						SDD->(MSUNLOCK())
					EndIf
				EndIf
				SD1->(DBSKIP())
			EndDo
	    EndIf
	EndIf

	//Garante desbloqueio de locks e final de transa��es abertas
	//Se for do mglt009 n�o faz aqui pois est� dentro da transa��o
	//Para o excluir italac tamb�m n�o faz pois tem transa��o em um n�vel superior do stack
	//Para o estorno de classifica��o tamb�m n�o faz pois tem transa��o em n�vel superior do stack
	//Para o estorno de documento de entrada de troca nota tamb�m n�o faz pois tem transa��o em n�vel superior do stacj
	If !IsInCallStack("U_MGLT009") .and. SuperGetMV("IT_F1UNL",.F.,.T.) .and. !IsInCallStack("U_ITEXCNFP");
			.and. !IsInCallStack("U_MA140EXE") .and. !IsInCallStack("EXCLUI_NF") .and. !IsInCallStack("U_MGLT010")
		Dbcommit()
		Dbcommitall()
		Dbunlock()
	EndIf

    If (_nOpcao == 3 .Or. _nOpcao == 4) .And. _nConf == 1    
    	dbSelectArea( "SD1" )
    	SD1->( dbSetOrder(1) )
    	SD1->( dbGoTop() )
    
    	If SD1->( dbSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA  ) )
    		While	SD1->D1_FILIAL == SF1->F1_FILIAL 	.AND.;
    				SD1->D1_DOC == SF1->F1_DOC 			.AND.;
    				SD1->D1_SERIE == SF1->F1_SERIE 		.AND.;
    				SD1->D1_FORNECE == SF1->F1_FORNECE .AND.;
    				SD1->D1_LOJA == SF1->F1_LOJA
    
    			DBSelectArea("SBZ")
    			SBZ->(DBSetOrder(1))
    			If DBSeek(xFilial("SBZ")+SD1->D1_COD)
    				If SBZ->BZ_LOCALIZ == "S"
    					fEnderec(_nOpcao)
    				EndIf
    			EndIf
	    		SD1->(Dbskip())
    		EndDo
    	EndIf
    EndIf

EndIf//QUAQUER ATUALIZACAO NOVA COLQUE DENTRO DESDE EndIf  /\ /\ /\ /\

FWRestArea(_aAreaSF1)
FWRestArea(_aAreaSD1)
FWRestArea(_aAreaSB8)
FWRestArea(_aAreaSD5)
FWRestArea(_aAreaSDD)
FWRestArea(_aAreaSF9)
FWRestArea(_aArea)
DelClassIntf()
Return

/*
===============================================================================================================================
Programa--------: EnviaWF
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 17/11/2015
Descri��o-------: Monta e dispara o WF de comunica��o nota de ativo fixo
Parametros------:  _aocor - array com dados de ocorr�ncias 
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function EnviaWF(_aocor As Array)

Local _aConfig	:= U_ITCFGEML('') As Array
Local _cMsgEml	:= '' As Character
Local _cEmail	:= '' As Character
Local _ni 		:= 1 As Numeric
Local _cinv		:= "" As Character
Local _ccdinv	:= "" As Character
Local _cult		:= "INI" As Character
Local _cFile 	:= SuperGetMV("IT_DIRLOG",.F.,"\temp\") As Character
Local _nH 		:= 0 As Numeric

DBSelectArea('ZZL')
ZZL->( Dbsetfilter({ | | ZZL->ZZL_WFATF="S" }, 'ZZL->ZZL_WFATF="S"') )
ZZL->( Dbgotop() )

Do While .not. ZZL->( EOF() )
	_cEmail += AllTrim( ZZL->ZZL_EMAIL ) + ";"
	ZZL->( Dbskip() )
EndDo

_cemail := substr(_cemail,1,len(_cemail)-1)	

If Empty( _cEmail )
	FWAlertWarning('Falha ao localizar o e-mail de destinat�rios do WF. Verifique com a �rea de TI/ERP','MT103FIM06')
Else
	//======================================================================================
	//Monta cabe�alho do email
	//======================================================================================
	_cMsgEml := '<html>'
	_cMsgEml += '<head><title> Nota fiscal de entrada com ocorr�ncia de ativo fixo</title></head>'
	_cMsgEml += '<body>'
	_cMsgEml += '<style type="text/css"><!--'
	_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
	_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
	_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
	_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
	_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
	_cMsgEml += '--></style>'
	_cMsgEml += '<left>'
	_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
	_cMsgEml += '<table class="bordasimples" width="600">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '	<td class="titulos"><center> Nota fiscal de entrada com ocorr�ncia de ativo fixo</center></td>'
	_cMsgEml += '	</tr>'
	_cMsgEml += '</table>'
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="600">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados da nota de entrada: <b></b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	
	//======================================================================================
	//Monta cabe�alho da nota
	//======================================================================================
	_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
	_cMsgEml += '      <td class="itens" >'
	_cMsgEml += _aocor[01][01] + " - " + FWFilialName( cEmpAnt ,  _aocor[01][01] , 2 ) + '</td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Nota:</b></td>'
	_cMsgEml += '      <td class="itens" > ' + ALLTRIM(_aocor[01][02]) + '/' +  ALLTRIM(_aocor[01][3]) + '</td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data Entrada.:</b></td>'
	_cMsgEml += '      <td class="itens" > ' + DTOC(_aocor[01][17]) + '</td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Fornecedor:</b></td>'   
	_cMsgEml += '      <td class="itens" >'
	_cMsgEml += ALLTRIM(_aocor[01][04]) + '/' + ALLTRIM(_aocor[01][05]) + ' - ' + posicione("SA2",1,xfilial("SA2")+_aocor[01][04]+_aocor[01][05],"A2_NREDUZ") +  '</td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Digitador.:</b></td>'
	_cMsgEml += '      <td class="itens" > ' + ALLTRIM(_aocor[01][18]) + '</td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '</table>'
	_cMsgEml += '<br>'
	
	//======================================================================================
	//Monta corpo da nota
	//======================================================================================
	For _ni := 1 to len(_aocor)
		If _cult <> _aocor[_ni][15]
			_cult := _aocor[_ni][15]
			If _ni > 1
				_cMsgEml += '</table>'
				_cMsgEml += '<br>'
			EndIf
			
			_cMsgEml += '<table class="bordasimples" width="1500">'
			_cMsgEml += '    <tr>'		
			_cMsgEml += '      <td align="left" colspan="15" class="grupos"> '+ _aocor[_ni][16] + '<b></b></td>'
			_cMsgEml += '    </tr>'
			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Cod. Prod.</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Desc Simples</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Desc Detalh</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Qtde</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Prc Unit</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Vl Total</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>TES</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>CFOP</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>CC</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Pedido</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Comprador</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Aplica��o</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>Investimento</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>OBS Inv</b></td>'
			_cMsgEml += '      <td class="itens" align="center" width="100"><b>OBS Ped</b></td>'
			_cMsgEml += '    </tr>'
		EndIf
		_cMsgEml += '    <tr>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> ' + ALLTRIM(_aocor[_ni][06]) + '</td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> ' + substr(alltrim(posicione("SB1",1,xfilial("SB1")+ALLTRIM(_aocor[_ni][06]),"B1_DESC")),1,30) + '</td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> ' + substr(alltrim(posicione("SB1",1,xfilial("SB1")+ALLTRIM(_aocor[_ni][06]),"B1_I_DESCD")),1,30) + '</td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"> ' + transform(_aocor[_ni][07],"@E 999,999,999.99")  + '</td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"> ' + transform(_aocor[_ni][08],"@E 999,999,999.99")  + '</td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"> ' + transform(_aocor[_ni][09],"@E 999,999,999.99")  + '</td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][10]) + '</td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][11]) + ' </td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][12]) + '</td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][13]) + '/' + alltrim(_aocor[_ni][14]) + '</td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> ' + posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_USER")
		_cMsgEml += ' - ' + posicione("SY1",3,Xfilial("SY1")+posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_USER"),"Y1_NOME") + '</td>'
		
		_cinv := posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_I_APLIC")
		
		If _cinv == "C"
			_cMsgEml += '      <td class="itens" align="center" width="100"> CONSUMO </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		ElseIf _cinv == "I"
			_cMsgEml += '      <td class="itens" align="center" width="100"> INVESTIMENTO </td>'
			_ccdinv := posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_I_CDINV")
			_cMsgEml += '      <td class="itens" align="left" width="100"> ' + _ccdinv + ' - ' + posicione("ZZI",1,_aocor[_ni][01]+_ccdinv,"ZZI_DESINV")  + '</td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> ' + posicione("ZZI",1,_aocor[_ni][01]+_ccdinv,"ZZI_OBS")  + '</td>'
		ElseIf _cinv == "M"
			_cMsgEml += '      <td class="itens" align="center" width="100"> MANUTEN��O </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		ElseIf _cinv == "S"
			_cMsgEml += '      <td class="itens" align="center" width="100"> SERVI�O </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		Else
			_cMsgEml += '      <td class="itens" align="left" width="100">  </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
			_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		EndIf	
		_cMsgEml += '      <td class="itens" > ' + posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_OBS") + '</td>'
		_cMsgEml += '    </tr>'
	Next _ni
	
	_cMsgEml += '</table>'
	
	//======================================================================================
	//Monta rodap� do email
	//======================================================================================
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="600">'
	_cMsgEml += '      <td class="itens" align="center" width="30%"><b></b></td>'
	_cMsgEml += '      <td class="itens" ></td>'
	_cMsgEml += '    </tr>'
		
	_cMsgEml += '	<tr>'
	_cMsgEml += '		<td class="grupos" align="center" colspan="2"><b>Para maiores informa��es acesse o sistema e visualize o documento de entrada.</b></td>'
	_cMsgEml += '	</tr>'
	_cMsgEml += '	<tr>'
	_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta � uma mensagem autom�tica. Por favor n�o a responda!</u></font></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '</table>'
	_cMsgEml += '</center>'
	_cMsgEml += '</body>'
	_cMsgEml += '</html>'
	
	//====================================================================================================
	//Monta arquivo para mandar anexado ao email
	//====================================================================================================
	_cfile := _cFile + 'WFATF_' + SF1->F1_FILIAL + ALLTRIM(SF1->F1_FORNECE) + ALLTRIM(SF1->F1_LOJA) + ALLTRIM(SF1->F1_DOC) + ALLTRIM(SF1->F1_SERIE) + ".html" 
	_nH := fCreate(_cfile) 
	fWrite(_nH,_cMsgEml) 
	fClose(_nH) 
	
	_cEmlLog 	:= ''
	_cassunto 	:= 'Nota fiscal de entrada com ocorr�ncia de ativo fixo - ' + SF1->F1_FILIAL + "/" 
	_cassunto 	+= alltrim(FWFilialName( cEmpAnt ,  SF1->F1_FILIAL , 1 )) + " - "  
	_cassunto 	+= alltrim(posicione("SA2",1,xfilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA ,"A2_NREDUZ"))
	_cassunto 	+= " - " + SF1->F1_DOC + "/" + SF1->F1_SERIE
	_ccorpo	:= 'Segue anexo Workflow de Nota fiscal de entrada com ocorr�ncia de ativo fixo.'
	_ccorpo	+= CRLF+CRLF
	_ccorpo	+= 'Favor n�o responder a este e-mail.' 
	
	U_ITENVMAIL( _aConfig[01] , _cEmail ,,, _cassunto  , _ccorpo ,_cfile, _aConfig[01] , _aConfig[02] , _aConfig[03] , _aConfig[04] , _aConfig[05] , _aConfig[06] , _aConfig[07] , @_cEmlLog )
EndIf

Return

/*
===============================================================================================================================
Programa--------: U_MT103GerCarga()
Autor-----------: Alex Wallauer
Data da Criacao-: 26/09/2016
Descri��o-------: Libera Pedidos de Carregamento Novos
Parametros------: cCarga: Numero da Carga ; _lLiberaPF: libera os PVs apos exclusao dos Docs para gerar a carga de novo
                 _cCargaExcluida: Numero da Carga excluida para reaproveitar
Retorno---------: L�gico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
User Function MT103GerCarga(cCarga As Character,_lLiberaPF As Logical,_cCargaExcluida As Character)//Fun��o chamada do rdmake M520BROW.PRW tb

Local _Ped			:= '' As Character
Local _cCliente		:= '' As Character
Local _cPedOrigem 	:= '' As Character
Local aLink_POV_PON	:= {} As Array
Local nSequencia	:= 0 
Local nInc 			:= 0 As Numeric  
Local _nLog 		:= 0 As Numeric
Local nSeqInc   	:=  SuperGetMV("MV_OMSENTR",.F.,5) As Logical
Local lRet			:= .T. As Logical
Local _aLogAux  	:= {} As Array
Local _cCargaAux	:= '' As Character
Local _nTotPeso 	:= 0 As Logical
Local _nTotValor	:= 0 As Logical
Local _nRecSM0  	:= SM0->(RECNO()) As Numeric
Local _cFornT   	:= '' As Character
Local _cLojaT   	:= '' As Character
Local _cFilCarregamento := '' As Character
Local nRecCargaOrigem := 0 As Logical

DAI->( DbSetOrder(1) )
SC5->( DbSetOrder(1) )
SC9->( DbSetOrder(1) )
SF1->( DBSETORDER(1) )

If DAI->( DBSEEK( cCarga )) .AND. DAK->(DBSEEK(cCarga)) //A  variavel esta com a Filial
	nRecCargaOrigem:=DAK->(RECNO())
	_cFilCarregamento:=DAI->DAI_FILIAL
	SM0->( dbSetOrder(1) )
	SM0->(DBGOTOP())
	Do While SM0->(!EOF())
		If _cFilCarregamento == ALLTRIM(SM0->M0_CODFIL)
			_cCNPJ:=SM0->M0_CGC
			Exit
		EndIf
		SM0->(DBSKIP())
	EndDo
	SM0->(DBGOTO(_nRecSM0))

	SA2->( DbSetOrder(3) )
	If SA2->(DBSEEK(xFilial("SA2")+_cCNPJ))
		_cFornT:=SA2->A2_COD
		_cLojaT:=SA2->A2_LOJA
	EndIf

	Do While DAI->( !EOF() ) .And. DAI->( DAI_FILIAL + DAI_COD) == cCarga
		If !SC5->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
			DAI->( DBSkip() )
			Loop
		EndIf
		_cPedOrigem:=DAI->DAI_PEDIDO
		
		If SC5->C5_I_TRCNF = 'S'             .AND.;//Pedidos de Troca Nota
			SC5->C5_I_FILFT # SC5->C5_I_FLFNC .AND.;
			!Empty(SC5->C5_I_FILFT)           .AND.;
			!Empty(SC5->C5_I_PDFT)            .AND.;
			SC5->C5_I_FILFT == cFilAnt  //Verifico a filial de faturamento pq pode ter pedidos de filiais de faturmento diferentes na mesma carga

			cPedidoFaturamento:=SC5->C5_I_FILFT + SC5->C5_I_PDFT
			_cMensagem:=""
			_cCargaAux:=""
			lRet:=.T.
			lVerde:=.F.

			If !SC5->( DbSeek( cPedidoFaturamento ) )//Se nao achou � erro
				lRet:=.F.
				_cMensagem:="Pedido de Faturamento nao encontrado"
			EndIf	

			If lRet .AND. !_lLiberaPF .AND. !SC9->( DbSeek( cPedidoFaturamento ) )//Se n�o achou o SC9 � pq n�o tentou classificar ainda, pois s� na classificacao que libera os pedidos de faturamento
				lRet:=.F.
				_cMensagem:="Pedido de Faturamento sem Classifica��o do Doc. de Transferencia (Sem Libera��o)"
			ElseIf SC9->( DbSeek( cPedidoFaturamento ) ) .AND. !Empty(SC9->C9_CARGA)//se achou no SC9 e tem carga � pq deu algum problema na exclusao da NFs da carga de faturamento e carga nao foi excluida
				lRet:=.F.
				lVerde:=.T.
				_cCargaAux:=SC9->C9_CARGA
				_cMensagem:="Pedido de Faturamento j� possui Carga de Faturamento Gerada"
			EndIf	

			_cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )

			If lRet 
				_cNotaT  :=DAI->DAI_NFISCA
				_cSerieT :=DAI->DAI_SERIE
				If Empty(_cFornT) .OR. !SF1->(DBSEEK(xFilial("SF1")+_cNotaT+_cSerieT+_cFornT+_cLojaT ))
					lRet:=.F.
					_cMensagem:="Nao foi possivel encontrar a NF: "+_cNotaT+" "+ALLTRIM(_cSerieT)+" de entrada de transferencia" 
					_cCliente:=_cFornT+" / "+_cLojaT+" / "+Alltrim( Posicione("SA2",1,xFilial("SA2")+_cFornT+_cLojaT,"A2_NREDUZ") )
				ElseIf Empty(SF1->F1_STATUS)
					lRet:=.F.
					_cMensagem:="Nao esta classificada a NF: "+_cNotaT+" "+ALLTRIM(_cSerieT)+" de entrada de transferencia" 
					_cCliente:=_cFornT+" / "+_cLojaT+" / "+Alltrim( Posicione("SA2",1,xFilial("SA2")+_cFornT+_cLojaT,"A2_NREDUZ") )
				EndIf
			EndIf
			
			If lRet .AND. !Ver_Lib_PV( cPedidoFaturamento , _lLiberaPF )       
				lRet:=.F.
				_cMensagem:="Pedido de Faturamento com problema na quantidade liberada - Item: "+SC9->C9_PRODUTO
			EndIf	

			If !lRet//Fica vermelho exceto "Pedido de Faturamento j� possui Carga de Faturamento Gerada"

			// aAdd( _aLog , {" "   ,'Carga Origem','Nota Serie'                                        ,'Carga Gerada','Movimentacao','Cliente',Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
				aAdd( _aLog , {lVerde,DAI->DAI_COD  ,ALLTRIM(DAI->DAI_NFISCA)+" "+ALLTRIM(DAI->DAI_SERIE),_cCargaAux    ,_cMensagem   ,_cCliente,SC5->C5_I_FLFNC     ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )

			Else//Fica Verde
				//               Recno do DAI   , Recno do SC5 do Pedido de Faturamento
				aAdd(aLink_POV_PON, { DAI->(RECNO()) , SC5->(RECNO()) , DAI->DAI_SEQUEN })

				_cMensagem:="Pedido de Faturamento Pronto para gera��o de Nota"
				// aAdd( _aLog  , {" ",'Carga Origem','Nota Serie'                                        ,'Carga Gerada','Movimentacao','Cliente',Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
					aAdd( _aLogAux,{.T.,DAI->DAI_COD  ,ALLTRIM(DAI->DAI_NFISCA)+" "+ALLTRIM(DAI->DAI_SERIE),""            ,_cMensagem    ,_cCliente,SC5->C5_I_FLFNC     ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )
			EndIf	
		EndIf

		DAI->( DBSkip() )
	EndDo
Else
   _cMensagem:="Carga nao encontrada"
   _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
// aAdd( _aLog , {" ",'Carga Origem','Nota Serie','Carga Gerada','Movimentacao','Cliente',Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
   aAdd( _aLog , {.F.,cCarga        ,""          ,""            ,_cMensagem    ,_cCliente,SC5->C5_I_FLFNC     ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )
   lRet:=.F.
EndIf

If !lRet .OR. LEN(_aLog) > 0
   For _nLog := 1 TO LEN(_aLogAux)
       aAdd( _aLog , _aLogAux[_nLog] )
   Next _nLog

   If _lLiberaPF
      DisarmTransaction()
      MostraLog(_aLog)
      _aLog:={}//Zera para nao mostra o log no rdmake M520BROW.PRW
   EndIf

   Return .F.
EndIf

DAK->( DbSetOrder(1) )
SA2->( DbSetOrder(1) )
SC6->( DbSetOrder(1) )
SC9->( DbSetOrder(1) )

ProcRegua(LEN(aLink_POV_PON))

//====================================================================================================
// Criando a carga
nRecCargaNew:=0
If DAK->(DBSEEK(cCarga)) 
	For nInc := 1 To DAK->(FCount())
		M->&(DAK->(FieldName(nInc))) := DAK->(FieldGet(nInc))
	Next nInc
	If Empty(_cCargaExcluida)
		M->DAK_COD:= U_AOMS089(.F.,"DAK","DAK_COD")//GetSxENum("DAK","DAK_COD")      
	Else
		M->DAK_COD:= _cCargaExcluida
	EndIf
	M->DAK_FILIAL:= xFilial("DAK")
	M->DAK_DATA  := DATE()
	M->DAK_HORA  := TIME()
	M->DAK_FEZNF := "2"
	M->DAK_I_CARG:= ""
	M->DAK_I_FRDC:= ""
	M->DAK_I_FRET:= 0// O Frete no destino da troca NF dever ser zerado
	M->DAK_I_VRPE:= 0// O Pedagio no destino da troca NF dever ser zerado

	If SA2->(FIELDPOS("A2_I_LJTRN")) <> 0 
		DA4->(DBSETORDER(1) )
		DA4->(DBSEEK( xFilial("DA4") + M->DAK_MOTORI) )
		SA2->(DBSETORDER(1) )
		SA2->(DBSEEK( xFilial("SA2") + DA4->DA4_FORNEC ) ) 
		_lTemenaomarcou:=.F.     
		_cListaLojas:="Transportadoras disponiveis em "+SM0->M0_ESTCOB+", lojas: "+CRLF
		Do While SA2->(!EOF()) .AND. xFilial("SA2")+DA4->DA4_FORNEC = SA2->A2_FILIAL+SA2->A2_COD
			
			If SA2->A2_MSBLQL <> '1' .AND. SA2->A2_EST == SM0->M0_ESTCOB 
				If SA2->A2_I_LJTRN = "S"
					M->DAK_I_LJTR:=SA2->A2_LOJA//Depois vai ser gravado no AvReplace("M", "DAK") abaixo
					_lTemenaomarcou:=.F.//Tem e marcou
					Exit
				EndIf
				_lTemenaomarcou:=.T.
				_cListaLojas+=SA2->A2_LOJA+" / "+TRANSFORM(SA2->A2_CGC,IF(Len(AllTrim(SA2->A2_CGC))>11,'@R! NN.NNN.NNN/NNNN-99','@R 999.999.999-99'))+" / "+ALLTRIM(SA2->A2_MUN)+CRLF
			EndIf      
			SA2->(DBSKIP())
		EndDo
		If _lTemenaomarcou
			FWAlertWarning('Existem lojas deste transportador ( '+DA4->DA4_FORNEC+' ) para a UF: '+ SM0->M0_ESTCOB+;
			" por�m nenhuma delas est� configurada para troca nota: " + _cListaLojas,"MT103FIM07")
		EndIf
	EndIf

	DAK->(RECLOCK("DAK",.T.))
	AvReplace("M", "DAK") 
	DAK->(MSUNLOCK())
	nRecCargaNew:=DAK->(RECNO())

	ConfirmSX8()
Else
   _cMensagem:="Carga nao encontrada"
   _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
	// aAdd( _aLog , {" ",'Carga Origem','Nota Serie','Carga Gerada','Movimentacao','Cliente',Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
   aAdd( _aLog , {.F.,cCarga        ,""          ,""            ,_cMensagem    ,_cCliente,SC5->C5_I_FLFNC     ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )
   lRet:=.F.
EndIf
//====================================================================================================
_nTotPeso :=0
_nTotValor:=0

If lRet 
    For _Ped := 1 TO LEN(aLink_POV_PON)
    	DAI->( DBGOTO( aLink_POV_PON[_Ped,1] ))
    	SC5->( DBGOTO( aLink_POV_PON[_Ped,2] ))//Recno do Pedido DA FATURAMENTO
    	_cNFE:=ALLTRIM(DAI->DAI_NFISCA)+" "+ALLTRIM(DAI->DAI_SERIE)
    
        IncProc("Lendo Pedido: "+SC5->C5_NUM)
    
    	// Criando itens da carga
        For nInc := 1 To DAI->(FCount())
            M->&(DAI->(FieldName(nInc))) := DAI->(FieldGet(nInc))
        Next nInc
        
		M->DAI_FILIAL := M->DAK_FILIAL
        M->DAI_COD    := M->DAK_COD
        M->DAI_PEDIDO := SC5->C5_NUM
        M->DAI_CLIENT := SC5->C5_CLIENTE
        M->DAI_LOJA   := SC5->C5_LOJACLI
        M->DAI_PESO   := SC5->C5_I_PESBR
        M->DAI_NFISCA := ""
        M->DAI_SERIE  := ""
        M->DAI_DATA   := DATE()
        M->DAI_HORA   := TIME()
        M->DAI_DTCHEG := DATE()
        M->DAI_TMSERV := '0000:00'
        M->DAI_CHEGAD := '08:00'
        M->DAI_DTSAID := DATE()
    	nSequencia    += nSeqInc
    	M->DAI_SEQUEN := StrZero(nSequencia,6)
        
        DAI->(RECLOCK("DAI",.T.))
        AvReplace("M", "DAI") 
        DAI->(MSUNLOCK())
    	
    	// Colocando a nova carga no SC9 do pedido de faturamento
    	SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
    	
    	Do While SC9->( !EOF() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == SC5->C5_FILIAL + SC5->C5_NUM
    		SC9->( RecLock('SC9',.F.) )
            SC9->C9_CARGA :=DAI->DAI_COD
            SC9->C9_SEQCAR:=DAI->DAI_SEQCAR
            SC9->C9_SEQENT:=DAI->DAI_SEQUEN
            //SC9->C9_BLEST :=""//J� estou fazendo isso antes de chamar essa funcao
            //SC9->C9_BLCRED:=""//J� estou fazendo isso antes de chamar essa funcao
    		SC9->( MsUnlock() )
            SC9->( DBSkip() )
    	EndDo
    
        _nTotPeso += DAI->DAI_PESO
    
        SC6->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
        Do While SC6->( !EOF() ) .AND. SC6->C6_FILIAL+SC6->C6_NUM == DAI->DAI_FILIAL+DAI->DAI_PEDIDO
           _nTotValor += SC6->C6_VALOR
     	   SC6->( DBSkip() )
        EndDo
    
    	// Colocando a nova carga no SC5 do pedido de faturamento
    	SC5->( RecLock( 'SC5' , .F. ) )
    	SC5->C5_I_CARGA:= DAK->DAK_COD   // Grava o numero da Carga Original para usar mais para frente
        SC5->( MsUnlock() )

        _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
        _cMensagem:="Carga Gerada Pronta para gera��o de Nota"
   		 //  aAdd( _aLog , {" ",'Carga Origem','Nota Serie','Carga Gerada','Movimentacao','Cliente',Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
        aAdd( _aLog , {.T.,cCarga        ,_cNFE       ,DAI->DAI_COD  ,_cMensagem   ,_cCliente,SC5->C5_I_FLFNC     ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )
    Next _Ped
EndIf

If nRecCargaNew <> 0 .AND. nRecCargaOrigem <> 0

	DAK->(DBGOTO(nRecCargaOrigem))//CARGA ORIGEM
	_cFilOri:=DAK->DAK_FILIAL
	_cCarOri:=DAK->DAK_COD

	DAK->(DBGOTO(nRecCargaNew))//CARGA DESTINO
	_cFilDes:=DAK->DAK_FILIAL
	_cCarDes:=DAK->DAK_COD

	DAK->(RECLOCK("DAK",.F.))
	DAK->DAK_PESO  := _nTotPeso
	DAK->DAK_VALOR := _nTotValor
	If DAK->(FIELDPOS( "DAK_I_TRNF" )) > 0
		DAK->DAK_I_TRNF:="F"      //Preencher o campo com F (Tem troca nota e � filial de faturamento)
		DAK->DAK_I_FITN:=_cFilOri //Filial de carregamento do troca nota (C5_I_FLFNC de algum pedido da carga)
		DAK->DAK_I_CATN:=_cCarOri //N�mero de carga da origem (Existe o campo C5_I_CARGA, mas este campo est� sendo alterado na classifica��o da nota, precisa gravar com a carga da filial de carregamento)
		DAK->DAK_I_INCC:="N"      //Preencher com N
		DAK->DAK_I_INCF:="N"      //Preencher com N
	EndIf
	DAK->(MSUNLOCK())

	If DAK->(FIELDPOS( "DAK_I_TRNF" )) > 0
		DAK->(DBGOTO(nRecCargaOrigem))//CARGA ORIGEM
		DAK->(RECLOCK("DAK",.F.))
		DAK->DAK_I_TRNF:= "C"     //Preencher o campo com C (Tem troca nota e � filial de carregamento)
		DAK->DAK_I_FITN:=_cFilDes //Filial de faturamento
		DAK->DAK_I_CATN:=_cCarDes //N�mero de carga do faturamento
		DAK->DAK_I_INCC:="N"      //Preencher com N
		DAK->DAK_I_INCF:="N"      //Preencher com N
		DAK->(MSUNLOCK())
	EndIf
Else
	_cMensagem:="Carga nova n�o Gerada"
	_cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Alltrim( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") )
	//dd( _aLog , {" ",'Carga Origem','Nota Serie','Carga Gerada','Movimentacao','Cliente',Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'} )
	aAdd( _aLog , {.F.,cCarga        ,""          ,""            ,_cMensagem    ,_cCliente,SC5->C5_I_FLFNC     ,SC5->C5_I_PDPR       ,SC5->C5_I_FILFT     ,SC5->C5_I_PDFT} )
	lRet:=.F.
EndIf

If !lRet .OR. LEN(_aLog) > 0
	For _nLog := 1 TO LEN(_aLogAux)
		aAdd( _aLog , _aLogAux[_nLog] )
	Next _nLog

	If _lLiberaPF
		DisarmTransaction()
		MostraLog(_aLog)
		_aLog:={}//Zera para nao mostra o log no rdmake M520BROW.PRW
	EndIf

	Return .F.
EndIf

If _lLiberaPF
	_aLog:={}//Zera para nao mostra o log no rdmake M520BROW.PRW
EndIf

Return lRet

/*
===============================================================================================================================
Programa--------: Ver_Lib_PV(cChave) / MostraLog(_aLog) / ForcaLib(cChaveSC5)
Autor-----------: Alex Wallauer
Data da Criacao-: 26/09/2016
Descri��o-------: Verefica se no SC9 esta tudo OK ou tenta liberar o Pedido
Parametros------: cChave: Filia + Pedido, _lLiberaPF: Se .T. tenta Liberar o Pedido senao s� ver se ta liberado OK
Retorno---------: L�gico (.F.) T� com erro (.T.) T� tudo OK
===============================================================================================================================
*/
Static Function Ver_Lib_PV(cChave As Character, _lLiberaPF As Logical)
 
Local _lOK		:= .T. As Logical//N�o Tem erro
Local _nQtdLib	:= 0 As Numeric

If _lLiberaPF

	SC6->( DbSetOrder(1) )//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If !SC6->( DBSeek( cChave ) )
		_lOK:=.F.//Tem erro
	EndIf

	SC9->( DbSetOrder(1) )//
	Do While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == cChave
		If !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))		
			_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO
		Else
			_nQtdLib := SC9->C9_QTDLIB
		EndIf
		If _nQtdLib # SC6->C6_QTDVEN
			_lOK:=.F.//Tem erro
			EXIT //J� deixa o SC6 posicionado
		EndIf
		SC6->( DBSkip() )
	EndDo

	If _lOK .AND. !ForcaLib(cChave)
		_lOK:=.F.//Tem erro
	EndIf

EndIf

Return _lOK

Static Function MostraLog(_aLog As Array)
If LEN(_aLog) > 0
	U_ITListBox( 'Log de Geracao de Carga (MT103FIM)' ,;//ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel )
				{" ",'Carga Origem','Nota Serie','Carga Gerada','Movimentacao','Cliente','Filial Carregamento','Pedido Carregamento','Filial Faturamento','Pedido Faturamento'},_aLog,.T.,4,"Lista / Status de Pedidos de Faturamento da Carga de Origem:",,;
				{ 10,            40,          40,            40,            185,      135,                  60,                   65,                  50,                  60})
EndIf

Return .T.

Static Function ForcaLib(cChaveSC5 As Character)

SC9->(DBSETORDER(1))

If !SC9->( DBSeek( cChaveSC5 ) )
	Return .F.
EndIf

SC5->(DBSETORDER(1))
If SC5->(DBSEEK(cChaveSC5))

	If SC5->C5_LIBEROK # "S"
		SC5->(RECLOCK("SC5",.F.))
		SC5->C5_LIBEROK:="S"
		SC5->(MSUNLOCK())
	EndIf
	If SC5->C5_I_BLCRE = "B"
		SC5->(RECLOCK("SC5",.F.))
		If Empty(SC5->C5_I_DTLIC)
			SC5->C5_I_BLCRE:=""
		Else
			SC5->C5_I_BLCRE:="L"
		EndIf
		SC5->(MSUNLOCK())
	EndIf

	//  Nao verificar se deu bloqueio de estoque pq j� vai entrar no estoque
	Do While SC9->( !EOF() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == SC5->C5_FILIAL + SC5->C5_NUM
		If !Empty(SC9->C9_BLCRED)
			SC9->(RECLOCK("SC9",.F.))
			SC9->C9_BLCRED:=""
			SC9->(MSUNLOCK())
		EndIf
		If !Empty(SC9->C9_BLEST)
			A450Grava(1,.F.,.T.,.F.)//SC9->C9_BLEST :="" //Faz an�lise e libera��o de estoque pois o padr�o n�o analisa estoque se o cr�dito est� bloqueado
		EndIf
		SC9->( DBSkip() )
	EndDo
Else
	Return .F.
EndIf

Return .T.

/*
===============================================================================================================================
Programa--------: MT103Trans()
Autor-----------: Alex Wallauer
Data da Criacao-: 11/01/2018
Descri��o-------: Transfere o produto de leite a granel (tem que estar com acols do mata103 montado)
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================*/
STATIC FUNCTION MT103Trans()

Local _aTransferecias	:={} as Array
Local _nOpcAuto   		:= 3 As Logical// Indica qual tipo de a��o ser� tomada (Inclus�o)
Local _cOriLocal  		:= "03" As Character
Local _cDesLocal  		:= "03" As Character
Local _aoriprod   		:= STRTOKARR(SuperGetMV("IT_LTGRN",.F.,'08000000062'),";") As Array
Local _cOriCodProd		:= AVKEY(_aoriprod[1],"D3_COD") As Character
Local _cDesCodProd		:= AVKEY(SuperGetMV("IT_LTMP",.F.,'08000000034'),"D3_COD") As Character
Local _cFilVld34  		:= SuperGetMV('IT_FILVLD3',.F.,'') As Character
Local _nQtde 			:=0 As Numeric
Local dDataVl			:=CTOD("") As Date
Local _nX 				:= 0 As Numeric
SF4->(dbSetOrder(1))
SB1->(dbSetOrder(1))

For _nX := 1 To Len(aCols)
	If aCols[_nX][Len(aCols[_nX])]//Somente linhas nao deletadas
		Loop
	EndIf

	If aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL"})] <> _cOriLocal
		Loop
	EndIf
	If !SF4->(dbSeek(xFilial("SF4") + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})])) .OR. SF4->F4_ESTOQUE <> "S"
		Loop
	EndIf

	//Repreenche o _coricodprod
	_ni := ascan(_aoriprod,ALLTRIM(aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})]))

	If _ni > 0 
		_cOriCodProd := AVKEY(_aoriprod[_ni],"D3_COD")
	EndIf

	//Se destino � igual a origem n�o precisa fazer transfer�ncia
	If alltrim(_cOriCodProd) == alltrim(_cDesCodProd)
		Loop
	EndIf

	_nQtde:=aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})]

	If ALLTRIM(_cOriCodProd) == ALLTRIM(aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})]) .AND. _nQtde > 0
		//****** Cabecalho a Incluir ***
		cDoc:=GetSxENum("SD3","D3_DOC",1)
		aAuto:={}
		aAdd(aAuto,{cDoc,dDataBase})  //Cabecalho
		//****** Cabecalho a Incluir ***

		//****** Itens a Incluir  ******
		SB1->(DBSEEK(xFilial()+_cOriCodProd)) // ORIGEM
		
		aItem:={}
		aAdd(aItem,_cOriCodProd)//D3_COD
		aAdd(aItem,SB1->B1_DESC)//D3_DESCRI
		aAdd(aItem,SB1->B1_UM)  //D3_UM
		aAdd(aItem,_cOriLocal)  //D3_LOCAL
		aAdd(aItem,"")		    //D3_LOCALIZ //Endere�o Orig

		SB1->(DBSEEK(xFilial()+_cDesCodProd)) // DESTINO
		aAdd(aItem,_cDesCodProd)//D3_COD
		aAdd(aItem,SB1->B1_DESC)//D3_DESCRI
		aAdd(aItem,SB1->B1_UM)  //D3_UM
		aAdd(aItem,_cDesLocal)  //D3_LOCAL
		aAdd(aItem,"")		    //D3_LOCALIZ //Endere�o Dest
		aAdd(aItem,"")          //D3_NUMSERI
		aAdd(aItem,"")  	    //D3_LOTECTL
		aAdd(aItem,"")         	//D3_NUMLOTE
		aAdd(aItem,dDataVl)	    //D3_DTVALID
		aAdd(aItem,0)		    //D3_POTENCI
		aAdd(aItem,_nQtde)      //D3_QUANT
		aAdd(aItem,0)		    //D3_QTSEGUM
		aAdd(aItem,"")          //D3_ESTORNO
		aAdd(aItem,"")      	//D3_NUMSEQ
		aAdd(aItem,"")  	    //D3_LOTECTL
		aAdd(aItem,dDataVl)	    //D3_DTVALID
		aAdd(aItem,"")	 	    //D3_ITEMGRD
		aAdd(aItem,"")	 	    //D3_OBSERVA  //Observa��o C        30
		//Campos Customizados:
		aAdd(aItem,"")	 	    //D3_I_OBS    // Observa��o C       254 		
		If ! cFilant $ _cFilVld34 // Este campo n�o deve estar dispon�vel para filiais de valida��o do armaz�m 34 (Descarte).
			//aAdd(aHeader, {'Tipo TRS'        ,'D3_I_TPTRS' , PesqPict('SD3', 'D3_I_TPTRS' , 1) , 1, 0, '', USADO, 'C', '', ''})
			//aAdd(aHeader, {'Descric.Tipo TRS','D3_I_DSCTM' , PesqPict('SD3', 'D3_I_DSCTM' , 1) , 1, 0, '', USADO, 'C', '', ''})
			aAdd(aItem,"")	 	              //D3_I_TPTRS  // Mot.Tran.R C  1
			aAdd(aItem,"")	 	              //D3_I_DSCTM  // Des.Mot.Tr C  1
		EndIf 
		If cFilant $ _cFilVld34 // Este campo n�o deve estar dispon�vel para filiais de valida��o do armaz�m 34 (Descarte).
			//aAdd(aHeader, {'Mot.Tran.Ref','D3_I_MOTTR' , PesqPict('SD3', 'D3_I_MOTTR' , 01) , 08, 0, '', USADO, 'C', '', ''})        
			//aAdd(aHeader, {'Des.Mot.Tr.R','D3_I_DSCMT' , PesqPict('SD3', 'D3_I_DSCMT' , 01) , 40, 0, '', USADO, 'C', '', ''})  
			//aAdd(aHeader, {'Origem Trf.' ,'D3_I_SETOR' , PesqPict('SD3', 'D3_I_SETOR' , 40) , 40, 0, '', USADO, 'C', '', ''}) 
			//aAdd(aHeader, {'Destino'     ,'D3_I_DESTI' , PesqPict('SD3', 'D3_I_DESTI' , 40) , 40, 0, '', USADO, 'C', '', ''}) 
			aAdd(aItem,"")	 	          //D3_I_MOTTR  // Mot.Tran.R C         8 
			aAdd(aItem,"")	 	          //D3_I_DSCMT  // Des.Mot.Tr C        40 
			aAdd(aItem,"")	 	          //D3_I_SETOR  // Origem Trf C        40 
			aAdd(aItem,"")	 	          //D3_I_DESTI  // Destino    C        40 
		EndIf 
		
		//****** Itens a INCLUSAO LEITE CRU ******

		aAdd(aAuto,aItem)
		aAdd(_aTransferecias,aAuto)//Tem que ser um MSExecAuto para cada linha pq ele n�o deixa em uma mesma inclusao colocar itens origem/destino repetidos
	EndIf
Next _nX

BEGIN TRANSACTION
	For _nX := 1 To Len(_aTransferecias)
		lMsErroAuto := .F.

		MSExecAuto({|x,y| MATA261(x,y)},_aTransferecias[_nX],_nOpcAuto)//INCLUSAO DE LEITE CRU

		If lMsErroAuto
			If __lSx8
				RollBackSX8()
			EndIf
			
			FWAlertError("Erro na transfer�ncia de produto " + _cOriCodProd + " para o produto " + _cDesCodProd + "! "+;
					"Realize a transfer�ncia manualmente para garantir saldo para as OPs", "MT103FIM08")
			
			MOSTRAERRO()
			DisarmTransaction()
			EXIT
		Else
			ConfirmSX8()
		EndIf
	Next _nX
END TRANSACTION

Return .T.

/*
===============================================================================================================================
Programa--------: MT103TranC()
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 21/06/2018
Descri��o-------: Transfere o produto de creme (tem que estar com acols do mata103 montado)
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================*/
STATIC FUNCTION MT103TranC()

Local _aTransferecias	:= {} As Array
Local _nOpcAuto   		:= 3 As Numeric// Indica qual tipo de a��o ser� tomada (Inclus�o)
Local _cOriLocal  		:= "03" As Character
Local _cDesLocal  		:= "03" As Character
Local _aoriprod   		:= STRTOKARR(SuperGetMV("IT_CRGRN",.F.,'08000000064;08000000063'),";") As Array
Local _cOriCodProd		:= AVKEY(_aoriprod[1],"D3_COD") As Character
Local _cDesCodProd		:= AVKEY(SuperGetMV("IT_CRMP",.F.,'08000000007'),"D3_COD") As Character
Local _cFilVld34  		:= SuperGetMV('IT_FILVLD3',.F.,'') As Character
Local _nQtde 			:= 0 As Numeric
Local dDataVl			:= CTOD("") As Date
Local _nX 				:= 0 As Numeric
SF4->(dbSetOrder(1))
SB1->(dbSetOrder(1))

For _nX := 1 To Len(aCols)
    If aCols[_nX][Len(aCols[_nX])]//Somente linhas nao deletadas
	   Loop
	EndIf
	
	If aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL"})] <> _cOriLocal
		Loop
	EndIf
	If !SF4->(dbSeek(xFilial("SF4") + aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})])) .OR. SF4->F4_ESTOQUE <> "S"
		Loop
	EndIf
	
	//Repreenche o _coricodprod
	_ni := ascan(_aoriprod,ALLTRIM(aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})]))
	
	If _ni > 0 
		_cOriCodProd := AVKEY(_aoriprod[_ni],"D3_COD")
	EndIf
	
	//Se destino � igual a origem n�o precisa fazer transfer�ncia
	If alltrim(_cOriCodProd) == alltrim(_cDesCodProd)
		Loop
	EndIf
	
	If ALLTRIM(_cOriCodProd) == ALLTRIM(aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})])
		//****** Cabecalho a Incluir ***
		cDoc:=GetSxENum("SD3","D3_DOC",1)
		aAuto:={}
		aAdd(aAuto,{cDoc,dDataBase})  //Cabecalho
		//****** Cabecalho a Incluir ***

		//****** Itens a Incluir  ******
        SB1->(DBSEEK(xFilial()+_cOriCodProd)) // ORIGEM
        _nQtde:=aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})]
        aItem:={}
		aAdd(aItem,_cOriCodProd)//D3_COD
		aAdd(aItem,SB1->B1_DESC)//D3_DESCRI
		aAdd(aItem,SB1->B1_UM)  //D3_UM
		aAdd(aItem,_cOriLocal)  //D3_LOCAL
		aAdd(aItem,"")		    //D3_LOCALIZ //Endere�o Orig

        SB1->(DBSEEK(xFilial()+_cDesCodProd)) // DESTINO
		aAdd(aItem,_cDesCodProd)//D3_COD                                          
		aAdd(aItem,SB1->B1_DESC)//D3_DESCRI                                          
		aAdd(aItem,SB1->B1_UM)  //D3_UM                                          
		aAdd(aItem,_cDesLocal)  //D3_Local                                          
		aAdd(aItem,"")		    //D3_LOCALIZ //Endere�o Dest                                          
		aAdd(aItem,"")          //D3_NUMSERI                                          
		aAdd(aItem,"")  	    //D3_LOTECTL                                          
		aAdd(aItem,"")         	//D3_NUMLOTE                                          
		aAdd(aItem,dDataVl)	    //D3_DTVALID                                          
		aAdd(aItem,0)		    //D3_POTENCI                                          
		aAdd(aItem,_nQtde)      //D3_QUANT                                          
		aAdd(aItem,0)		    //D3_QTSEGUM                                          
		aAdd(aItem,"")          //D3_ESTORNO                                          
		aAdd(aItem,"")      	//D3_NUMSEQ                                          
		aAdd(aItem,"")  	    //D3_LOTECTL                                          
		aAdd(aItem,dDataVl)	    //D3_DTVALID                                          
		aAdd(aItem,"")	 	    //D3_ITEMGRD                                          
		aAdd(aItem,"")	 	    //D3_OBSERVA  // Observa��o C        30   
		//campos Customizados:                                       
		aAdd(aItem,"")	 	    //D3_I_OBS    // Observa��o C       254                                          
        If ! cFilant $ _cFilVld34 // Este campo n�o deve estar dispon�vel para filiais de valida��o do armaz�m 34 (Descarte).
           //aAdd(aHeader, {'Tipo TRS'        ,'D3_I_TPTRS' , PesqPict('SD3', 'D3_I_TPTRS' , 1) , 1, 0, '', USADO, 'C', '', ''})
           //aAdd(aHeader, {'Descric.Tipo TRS','D3_I_DSCTM' , PesqPict('SD3', 'D3_I_DSCTM' , 1) , 1, 0, '', USADO, 'C', '', ''})
		   aAdd(aItem,"")	 	              //D3_I_TPTRS  // Mot.Tran.R C  1
		   aAdd(aItem,"")	 	              //D3_I_DSCTM  // Des.Mot.Tr C  1
        EndIf 
        If cFilant $ _cFilVld34 // Este campo n�o deve estar dispon�vel para filiais de valida��o do armaz�m 34 (Descarte).
           //aAdd(aHeader, {'Mot.Tran.Ref','D3_I_MOTTR' , PesqPict('SD3', 'D3_I_MOTTR' , 01) , 08, 0, '', USADO, 'C', '', ''})        
           //aAdd(aHeader, {'Des.Mot.Tr.R','D3_I_DSCMT' , PesqPict('SD3', 'D3_I_DSCMT' , 01) , 40, 0, '', USADO, 'C', '', ''})  
           //aAdd(aHeader, {'Origem Trf.' ,'D3_I_SETOR' , PesqPict('SD3', 'D3_I_SETOR' , 40) , 40, 0, '', USADO, 'C', '', ''}) 
           //aAdd(aHeader, {'Destino'     ,'D3_I_DESTI' , PesqPict('SD3', 'D3_I_DESTI' , 40) , 40, 0, '', USADO, 'C', '', ''}) 
		   aAdd(aItem,"")	 	          //D3_I_MOTTR  // Mot.Tran.R C         8 
		   aAdd(aItem,"")	 	          //D3_I_DSCMT  // Des.Mot.Tr C        40 
		   aAdd(aItem,"")	 	          //D3_I_SETOR  // Origem Trf C        40 
		   aAdd(aItem,"")	 	          //D3_I_DESTI  // Destino    C        40 
        EndIf 
		
		//****** Itens a INCLUSAO CREME ******

		aAdd(aAuto,aItem)
		
		aAdd(_aTransferecias,aAuto)//Tem que ser um MSExecAuto para cada linha pq ele n�o deixa em uma mesma inclusao colocar itens origem/destino repetidos
	EndIf
Next _nX

BEGIN TRANSACTION

For _nX := 1 To Len(_aTransferecias)
	lMsErroAuto := .F.
	
	MSExecAuto({|x,y| MATA261(x,y)},_aTransferecias[_nX],_nOpcAuto)//INCLUSAO DE CREME
	
	If lMsErroAuto
		If __lSx8
			RollBackSX8()
		EndIf
		
		FWAlertError("Erro na transfer�ncia de produto " + ALLTRIM(aCols[_nX][aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})]) +;
		 " para o produto " + _cDesCodProd + "! Realize a transfer�ncia manualmente para garantir saldo para as OPs", "MT103FIM09")
		
		MOSTRAERRO()
		DisarmTransaction()
        EXIT
	Else
		 ConfirmSX8()
	EndIf
Next _nX

END TRANSACTION

Return .T.

/*
===============================================================================================================================
Programa----------: GravaPeso
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2018
Descri��o---------: Processa a grava��o dos pesos do itens da NF
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function GravaPeso(_nGravados As Numeric)

Local _cFilSB1 := xFilial("SB1") As Character

If SD1->(FIELDPOS("D1_I_PTBRU")) = 0 
	Return .F.
EndIf

DEFAULT _nGravados:=0

SD1->( DBSetOrder(1) ) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
If SD1->( DBSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
	Do While SD1->(!Eof()) .and. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
		If Empty(SD1->D1_I_PTBRU) .AND. !Empty(SD1->D1_QUANT)
			_nPesoItem := ( POSICIONE( "SB1" , 1 , _cFilSB1 + SD1->D1_COD , "B1_PESBRU" ) * SD1->D1_QUANT )

			If _nPesoItem <> 0 .AND. SD1->( RecLock( "SD1",.F.,,.T.))
				SD1->D1_I_PTBRU := _nPesoItem
				SD1->( MsUnlock() )
				_nGravados++
			EndIf
		EndIf
		SD1->( DBSkip() )
	EndDo
EndIf
	
Return .T.

/*
===============================================================================================================================
Programa----------: CPBT_SF1()
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2018
Descri��o---------: Carga Peso Bruto Total _ SF1
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CPBT_SF1

Local cTimeInicial	:=TIME() As Character
Local _cPerg		:="FILTRA_NF" As Character
PRIVATE _nGravados	:=0 As Numeric

If !PERGUNTE(_cPerg , .T. )
	Return .F.
EndIf

FWMSGRUN( ,{|oProc|  CPBT_SF1(oProc,cTimeInicial) }  , "SD1 - Hora Inicial: "+cTimeInicial , "Aguarde...",  )

Return .T.

/*
===============================================================================================================================
Programa----------: CPBT_SF1()
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2018
Descri��o---------: Carga Peso Bruto Total _ SF1
Parametros--------: oProc,cTimeInicial
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function CPBT_SF1(oProc As Object,cTimeInicial As Character)

Local nConta	:= 0 As Numeric
Local xTotal	:= 0 As Variant
Local nTam		:= 0 As Numeric
Local _cAlias	:= GetNextAlias() As Character
Local cQuery 	:= " SELECT SF1.R_E_C_N_O_ RECSF FROM "+ RetSqlName("SF1")+" SF1 WHERE " As Character

oProc:cCaption :=  "Filtrando SF1, Aguarde..."
ProcessMessages()

cQuery += " SF1.D_E_L_E_T_	= ' ' "
If !Empty(MV_PAR01) 
	cQuery += " AND	SF1.F1_FILIAL IN "+ FormatIn(MV_PAR01,";")
EndIf   
If !Empty(MV_PAR03) 
	cQuery += " AND SF1.F1_EMISSAO BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"' "
ElseIf !Empty(MV_PAR02) 
	cQuery += " AND SF1.F1_EMISSAO = '"+ DTOS(MV_PAR02)+"' "
EndIf   
If !Empty(MV_PAR04) 
	cQuery += " AND	SF1.F1_TIPO IN "+ FormatIn(MV_PAR04,";")
EndIf   
	
If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,_cAlias)

(_cAlias)->( DBGOTOP() )
COUNT TO  xTotal

If xTotal > 30000
	xTotal:=ALLTRIM(STR(xTotal))

	If !FWAlertYesNo("Ser�o processado "+xTotal+" registros, CONFIRMA?","MT103FIM10")
		Return .F.
	EndIf

	cTimeInicial:=TIME()
Else
	xTotal:=ALLTRIM(STR(xTotal))
EndIf

(_cAlias)->( DBGOTOP() )
nTam:=LEN(xTotal)+1

Do While (_cAlias)->(!Eof()) 
	nConta++

	SF1->(DBGOTO( (_cAlias)->RECSF ) )

	oProc:cCaption :=  "Lendo "+STR(nConta,nTam)+" de "+xTotal +" Lendo NF: "+SF1->F1_FILIAL+" "+SF1->F1_DOC+" PB Gravados: "+ALLTRIM(STR(_nGravados))
	ProcessMessages()

	GravaPeso(@_nGravados)

	(_cAlias)->( DBSkip() )
EndDo

_nGravados:=ALLTRIM(STR(_nGravados))

FWAlertSuccess("Carga (SD1) do Peso Bruto completada com sucesso "+_nGravados+" registros gravados. Hora inicio "+cTimeInicial+" - Hora fim "+TIME()+" Parametros: ["+ALLTRIM(MV_PAR01)+"] ["+DTOC(MV_PAR02)+"] ["+DTOC(MV_PAR03)+"] ["+ALLTRIM(MV_PAR04)+"]","MT103FIM11")

Return .T.

/*
===============================================================================================================================
Programa--------: EnviaWF2
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 10/01/2019
Descri��o-------: Monta e dispara o WF de comunica��o nota de com reinf fechado
Parametros------:  _aocor - array com dados de ocorr�ncias 
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function EnviaWF2(_aocor As Array)

Local _aConfig	:= U_ITCFGEML('') As Array
Local _cMsgEml	:= '' As Character
Local _cEmail	:= '' As Character
Local _ni 		:= 1 As Numeric
Local _cinv		:= "" As Character
Local _ccdinv	:= "" As Character
Local _cult		:= "INI" As Character
Local _cFile 	:= SuperGetMV("IT_DIRLOG",.F.,"\temp\")  As Character
Local _nH 		:= 0 As Numeric

_cEmail := SuperGetMV("IT_MAILREI",.F.,"sistema@italac.com.br")

//======================================================================================
//Monta cabe�alho do email
//======================================================================================
_cMsgEml := '<html>'
_cMsgEml += '<head><title> Nota fiscal de entrada com per�odo Reinf j� encerrado</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<left>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center> Nota fiscal de entrada com per�odo Reinf j� encerrado</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados da nota de entrada: <b></b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'

//======================================================================================
//Monta cabe�alho da nota
//======================================================================================
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
_cMsgEml += '      <td class="itens" >'
_cMsgEml += _aocor[01][01] + " - " + FWFilialName( cEmpAnt ,  _aocor[01][01] , 2 ) + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Nota:</b></td>'
_cMsgEml += '      <td class="itens" > ' + ALLTRIM(_aocor[01][02]) + '/' +  ALLTRIM(_aocor[01][3]) + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data Emiss�o.:</b></td>'
_cMsgEml += '      <td class="itens" > ' + DTOC(_aocor[01][22]) + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data Entrada.:</b></td>'
_cMsgEml += '      <td class="itens" > ' + DTOC(_aocor[01][17]) + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Fornecedor:</b></td>'   
_cMsgEml += '      <td class="itens" >'
_cMsgEml += ALLTRIM(_aocor[01][04]) + '/' + ALLTRIM(_aocor[01][05]) + ' - ' + posicione("SA2",1,xfilial("SA2")+_aocor[01][04]+_aocor[01][05],"A2_NREDUZ") +  '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Digitador.:</b></td>'
_cMsgEml += '      <td class="itens" > ' + ALLTRIM(_aocor[01][18]) + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'

//======================================================================================
//Monta corpo da nota
//======================================================================================

For _ni := 1 to len(_aocor)
	If _cult <> _aocor[_ni][15]
		_cult := _aocor[_ni][15]
		If _ni > 1
			_cMsgEml += '</table>'
			_cMsgEml += '<br>'
		EndIf
		
		_cMsgEml += '<table class="bordasimples" width="1500">'
		_cMsgEml += '    <tr>'		
		_cMsgEml += '      <td align="left" colspan="15" class="grupos"> '+ _aocor[_ni][16] + '<b></b></td>'
		_cMsgEml += '    </tr>'
		_cMsgEml += '    <tr>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Cod. Prod.</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Desc Simples</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Desc Detalh</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Qtde</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Prc Unit</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Vl Total</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Vl Inss</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>TES</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>CFOP</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>CC</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Pedido</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Comprador</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Aplica��o</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>Investimento</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>OBS Inv</b></td>'
		_cMsgEml += '      <td class="itens" align="center" width="100"><b>OBS Ped</b></td>'
		_cMsgEml += '    </tr>'
	EndIf

	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="left" width="100"> ' + ALLTRIM(_aocor[_ni][06]) + '</td>'
	_cMsgEml += '      <td class="itens" align="left" width="100"> ' + substr(alltrim(posicione("SB1",1,xfilial("SB1")+ALLTRIM(_aocor[_ni][06]),"B1_DESC")),1,30) + '</td>'
	_cMsgEml += '      <td class="itens" align="left" width="100"> ' + substr(alltrim(posicione("SB1",1,xfilial("SB1")+ALLTRIM(_aocor[_ni][06]),"B1_I_DESCD")),1,30) + '</td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + transform(_aocor[_ni][07],"@E 999,999,999.99")  + '</td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + transform(_aocor[_ni][08],"@E 999,999,999.99")  + '</td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + transform(_aocor[_ni][09],"@E 999,999,999.99")  + '</td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + transform(_aocor[_ni][21],"@E 999,999,999.99")  + '</td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][10]) + '</td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][11]) + ' </td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][12]) + '</td>'
	_cMsgEml += '      <td class="itens" align="center" width="100"> ' + alltrim(_aocor[_ni][13]) + '/' + alltrim(_aocor[_ni][14]) + '</td>'
	_cMsgEml += '      <td class="itens" align="left" width="100"> ' + posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_USER")
	_cMsgEml += ' - ' + posicione("SY1",3,Xfilial("SY1")+posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_USER"),"Y1_NOME") + '</td>'
	
	_cinv := posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_I_APLIC")
	
	If _cinv == "C"
		_cMsgEml += '      <td class="itens" align="center" width="100"> CONSUMO </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
	ElseIf _cinv == "I"
		_cMsgEml += '      <td class="itens" align="center" width="100"> INVESTIMENTO </td>'
		_ccdinv := posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_I_CDINV")
		_cMsgEml += '      <td class="itens" align="left" width="100"> ' + _ccdinv + ' - ' + posicione("ZZI",1,_aocor[_ni][01]+_ccdinv,"ZZI_DESINV")  + '</td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> ' + posicione("ZZI",1,_aocor[_ni][01]+_ccdinv,"ZZI_OBS")  + '</td>'
	ElseIf _cinv == "M"
		_cMsgEml += '      <td class="itens" align="center" width="100"> MANUTEN��O </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
	ElseIf _cinv == "S"
		_cMsgEml += '      <td class="itens" align="center" width="100"> SERVI�O </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
	Else
		_cMsgEml += '      <td class="itens" align="left" width="100">  </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
		_cMsgEml += '      <td class="itens" align="left" width="100"> </td>'
	EndIf	
	
	_cMsgEml += '      <td class="itens" > ' + posicione("SC7",1,_aocor[_ni][01]+_aocor[_ni][13]+_aocor[_ni][14],"C7_OBS") + '</td>'
	_cMsgEml += '    </tr>'
Next _ni

_cMsgEml += '</table>'

//======================================================================================
//Monta rodap� do email
//======================================================================================

_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b></b></td>'
_cMsgEml += '      <td class="itens" ></td>'
_cMsgEml += '    </tr>'

_cMsgEml += '	<tr>'
_cMsgEml += '		<td class="grupos" align="center" colspan="2"><b>Para maiores informa��es acesse o sistema e visualize o documento de entrada.</b></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '	<tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta � uma mensagem autom�tica. Por favor n�o a responda!</u></font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'
_cMsgEml += '</center>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'


//====================================================================================================
//Monta arquivo para mandar anexado ao email
//====================================================================================================
_cfile := _cFile + 'WFATF_' + SF1->F1_FILIAL + ALLTRIM(SF1->F1_FORNECE) + ALLTRIM(SF1->F1_LOJA) + ALLTRIM(SF1->F1_DOC) + ALLTRIM(SF1->F1_SERIE) + ".html" 
_nH := fCreate(_cfile) 
fWrite(_nH,_cMsgEml) 
fClose(_nH) 

_cEmlLog 	:= ''
_cassunto 	:= 'Nota fiscal de entrada com per�odo Reinf j� encerrado - ' + SF1->F1_FILIAL + "/" 
_cassunto 	+= alltrim(FWFilialName( cEmpAnt ,  SF1->F1_FILIAL , 1 )) + " - "  
_cassunto 	+= alltrim(posicione("SA2",1,xfilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA ,"A2_NREDUZ"))
_cassunto 	+= " - " + SF1->F1_DOC + "/" + SF1->F1_SERIE
_ccorpo	:= 'Segue anexo Workflow de Nota fiscal de entrada com per�odo Reinf j� encerrado.'
_ccorpo	+= CRLF
_ccorpo	+= CRLF
_ccorpo	+= 'Favor n�o responder a este e-mail.' 

U_ITENVMAIL( _aConfig[01] , _cEmail ,,, _cassunto  , _ccorpo ,_cfile, _aConfig[01] , _aConfig[02] , _aConfig[03] , _aConfig[04] , _aConfig[05] , _aConfig[06] , _aConfig[07] , @_cEmlLog )

Return

/*
===============================================================================================================================
Programa--------: EnviaWF3()
Autor-----------: Alex Wallauer
Data da Criacao-: 12/08/2019
Descri��o-------: Monta e dispara o WF para avisar o solicitante de uma compra que seu produto j� chegou na empresa
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function EnviaWF3(_lReenvio As Logical,oProc As Object)

Local _aConfig	:= U_ITCFGEML('') As Array
Local _cEmlLog	:= "" As Character
Local _cMsgEml	:= "" As Character
Local cGetCc	:= SuperGetMV("IT_PRDCHEG",.F.,"") As Character
Local _cGetPara	:= "" As Character
Local _cMailUser:= "" As Character
Local _cUserSol := "" As Character
Local _cUserApr := "" As Character
Local _cNomeFil := cFilAnt+" - "+AllTrim( Posicione('SM0',1,"01"+cFilAnt,'M0_FILIAL') ) As Character
Local cGetAssun := "SEU PRODUTO CHEGOU DO PEDIDO NUMERO #PEDIDO#" As Character
Local _aSizes   := {} As Array
Local P			:= 0 As Numeric
Local _nI 		:= 0 As Numeric
Local _aTLinhas := {} As Array
Local _aLinhas  := {} As Array
Local _aItens   := {} As Array
Local _aCab     := {} As Array
Local _aPC      := {} As Array
Local _bUserN := {|x| UsrFullName(x)} As Codeblock


If _lReenvio	
	If !FWAlertYesNo("Confirma envio do Workflow de aquisi��o de produtos?","MT103FIM12")
		Return .T.
	EndIf
EndIf

SD1->( DBSetOrder(1) ) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
SC1->( DBSETORDER(1) )
SC7->( DBSETORDER(1) )
SF4->( DBSETORDER(1) )

If SD1->( DBSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
	_cPc:=SD1->D1_PEDIDO
	Do While SD1->(!Eof()) .and. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
		If VALTYPE(oProc) = "O"
			oProc:cCaption :=  "Lendo Item PC: "+SD1->D1_PEDIDO+"-"+SD1->D1_ITEM+" / Qtde Envio: "+STR(LEN(_aPC),2)
			ProcessMessages()
		EndIf   
		
		If SF4->(DBSEEK(xFilial("SF4")+SD1->D1_TES )) .AND. SF4->F4_ESTOQUE == "S"
			If SB1->(DBSEEK(xFilial("SB1")+SD1->D1_COD )) .AND. !SB1->B1_TIPO $ "PA/MP/SV"
				If SC7->(DBSEEK(xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC ))
					If _cPc <> SD1->D1_PEDIDO
						_cGetPara+=_cMailUser
						aAdd(_aPC,{_cPc,_aItens,_cGetPara, Empty(_cUserApr) })

						_cPc      := SD1->D1_PEDIDO
						_aItens   := {}
						_cGetPara := ""
						_cMailUser:= ""
					EndIf
					If !Empty(SC7->C7_NUMSC) .AND. SC1->(DBSEEK(xFilial("SC7")+SC7->C7_NUMSC+SC7->C7_ITEMSC ))
						_cUserSol:=Capital( AllTrim( Eval(_bUserN, SC1->C1_I_CDSOL )))
						_cUserApr:=Capital( AllTrim( Eval(_bUserN, SC1->C1_I_CODAP )))
						_cGetPara+=UsrRetMail(SC1->C1_I_CDSOL)+";"
						_cGetPara+=UsrRetMail(SC1->C1_I_CODAP)+";"
					Else
						_cUserSol:=""
						_cUserApr:=""
					EndIf
					_aLinhas:={}
					aAdd(_aLinhas,SD1->D1_ITEMPC)
					aAdd(_aLinhas,DTOC(SC7->C7_DATPRF))
					aAdd(_aLinhas,ALLTRIM(TRANSFORM(SD1->D1_QUANT,"@E 999,999,999,999.99")))
					aAdd(_aLinhas,ALLTRIM(SD1->D1_COD)+"-"+ALLTRIM(SB1->B1_DESC))
					aAdd(_aLinhas,_cUserSol )//SOLICITANTE 
					aAdd(_aLinhas,_cUserApr )//APROVADOR  
					aAdd(_aLinhas,Capital( AllTrim( Eval(_bUserN, SC7->C7_USER))) )//COMPRADOR   UsrRetMail(SC7->C7_USER)
					If !Empty(SC7->C7_USER)
						_cMailUser:=AllTrim( UsrRetMail(SC7->C7_USER) )
					EndIf   
					aAdd(_aItens,_aLinhas)
				EndIf
			EndIf
		EndIf
		SD1->( DBSkip() )
	EndDo
	If LEN(_aItens) > 0
		_cGetPara+=_cMailUser
		aAdd(_aPC,{_cPc,_aItens,_cGetPara, Empty(_cUserApr) })
	EndIf
	If VALTYPE(oProc) = "O"
		oProc:cCaption :=  "Lendo Item PC: "+_cPc+" / Qtde Envio: "+STR(LEN(_aPC),2)
		ProcessMessages()
	EndIf   
EndIf

If LEN(_aPC) = 0
	If _lReenvio	
		FWAlertInfo("N�o h� itens para envido do Workflow de aquisi��o de produtos","MT103FIM13")
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MT103FIM"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MT103FIM14"/*cMsgId*/, "MT103FIM14 - "+UPPER(_cEmlLog)+" - E-mail para: "+_cGetPara/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
	Return .F.
EndIf

aAdd(_aCab,"Item")       //01
aAdd(_aSizes,"05")
aAdd(_aCab,"Entrega")    //02
aAdd(_aSizes,"05")
aAdd(_aCab,"Quant.")     //03
aAdd(_aSizes,"05")           
aAdd(_aCab,"Produto")    //04
aAdd(_aSizes,"22")
aAdd(_aCab,"Solicitante")//05
aAdd(_aSizes,"21")
aAdd(_aCab,"Aprovador")  //06
aAdd(_aSizes,"21")
aAdd(_aCab,"Comprador")  //07
aAdd(_aSizes,"21")

_cMsgEml := '<html>'
_cMsgEml += '<head><title>'+cGetAssun+'</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '	     <td class="titulos"><center>'+cGetAssun+'</center></td>'
_cMsgEml += '	 </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados de envio</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>NF lancada por: </b></td>'
_cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>' 
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
_cMsgEml += '      <td class="itens" >'+ _cNomeFil +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Nota Fiscal:</b></td>'
_cMsgEml += '      <td class="itens" >'+SF1->F1_DOC +"-"+ SF1->F1_SERIE+'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data Emissao:</b></td>'
_cMsgEml += '      <td class="itens" >'+DTOC(SF1->F1_EMISSAO)+'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data Digitacao:</b></td>'
_cMsgEml += '      <td class="itens" >'+DTOC(SF1->F1_DTDIGIT)+'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Fornecedor:</b></td>'
_cMsgEml += '      <td class="itens" >'+SF1->F1_FORNECE+" "+SF1->F1_LOJA+"-"+Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NREDUZ")+'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '	<tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta � uma mensagem autom�tica. Por favor n�o a responda!</u></font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1200">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="7" class="grupos">Produtos que chegaram</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCab[01]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCab[02]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>'+_aCab[03]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>'+_aCab[04]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%"><b>'+_aCab[05]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%"><b>'+_aCab[06]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[07]+'%"><b>'+_aCab[07]+'</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    #LISTA#'
_cMsgEml += '</table>'
_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > [ '+ GETENVSERVER() +' ] / <b>Fonte:</b>[ MT103FIM ]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'

_cOldMsgEml :=_cMsgEml //Salva as vairaveis por causa dos coringas quando troca de PC
cOldGetAssun:=cGetAssun//Salva as vairaveis por causa dos coringas quando troca de PC

FOR P := 1 TO LEN(_aPC)
    If VALTYPE(oProc) = "O"
		oProc:cCaption :=  "Enviando E-mail do PC: "+_aPC[P,1]
		ProcessMessages()
    EndIf   

	_cMsgEml :=STRTRAN(_cMsgEml ,"#PEDIDO#",_aPC[P,1])//1 - PC
	cGetAssun:=STRTRAN(cGetAssun,"#PEDIDO#",_aPC[P,1])//1 - PC
	_aTLinhas:=_aPC[P,2]//2 - ITENS
	_cGetPara:=_aPC[P,3]//3 - EMAILS
    If _aPC[P,4]        //4 - SE NAO TEM APROVADOR NA SC OU N�O TEM SC
		_aRet:=LerAprovadores(_aPC[P,1],oProc)
		If !Empty(_aRet[1])
			_cGetPara+=";"+_aRet[1]
			_cUserApr:=_aRet[2]
		EndIf
    EndIf   
	
	_aGetPara:=STRTOKARR(LOWER(ALLTRIM(_cGetPara)),";")
	_cGetPara:=""
	For _nI := 1 To LEN(_aGetPara)
		If !Empty(_aGetPara[_nI]) .AND. !_aGetPara[_nI] $ _cGetPara
			_cGetPara+=_aGetPara[_nI]+";"
		EndIf  
    Next _nI

	_cGetLista:=""
	For _nI := 1 To LEN(_aTLinhas)
	    If _aPC[P,4] //Se n�o tem aprovador na SC
	    	_aTLinhas[_nI][06]:=_cUserApr
        EndIf
		_cGetLista += '    <tr>'
		_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[01]+'%">'+_aTLinhas[_nI][01]+'</td>'
		_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[02]+'%">'+_aTLinhas[_nI][02]+'</td>'
		_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[03]+'%">'+_aTLinhas[_nI][03]+'</td>'
		_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[04]+'%">'+_aTLinhas[_nI][04]+'</td>'
		_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[05]+'%">'+_aTLinhas[_nI][05]+'</td>'
		_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[06]+'%">'+_aTLinhas[_nI][06]+'</td>'
		_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[07]+'%">'+_aTLinhas[_nI][07]+'</td>'
		_cGetLista += '    </tr>'
	Next _nI
	_cMsgEml:=STRTRAN(_cMsgEml,"#LISTA#",_cGetLista)

	/// Chama a fun��o para envio do e-mail
	U_ITENVMAIL( _aConfig[01], _cGetPara, cGetCc, "", cGetAssun, _cMsgEml, "", _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

    If _lReenvio .OR. SuperGetMV("IT_AMBTEST",.F.,.T.)
		FWAlertInfo(UPPER(_cEmlLog)+CRLF+"E-mail para: "+_cGetPara+CRLF+cGetAssun,"MT103FIM15")
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MT103FIM"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MT103FIM16"/*cMsgId*/, "MT103FIM16 - "+UPPER(_cEmlLog)+" - E-mail para: "+_cGetPara/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
    
    _cMsgEml :=_cOldMsgEml //Volta as vairaveis por causa dos coringas quando troca de PC
    cGetAssun:=cOldGetAssun//Volta as vairaveis por causa dos coringas quando troca de PC

Next P

Return .T.

/*
===============================================================================================================================
Programa--------: LerAprovadores()
Autor-----------: Alex Wallauer
Data da Criacao-: 12/08/2019
Descri��o-------: LER aprovadores do PC
Parametros------: _cNumPC
Retorno---------: Nenhum
===============================================================================================================================
*/
STATIC Function LerAprovadores(_cNumPC As Character,oProc As Object)
 
Local _aAprov	:= {} As Array
Local _cEmail	:= "" As Character
Local _cNomes	:= "" As Character
Local _cDep  	:= "" As Character
Local cQrySCR	:= "" As Character

cQrySCR	:= "SELECT R_E_C_N_O_ RECNUM " 
cQrySCR += "FROM " + RetSqlName("SCR") + " "
cQrySCR += "WHERE CR_FILIAL = '" + cFilAnt + "' "
cQrySCR += "  AND CR_NUM = '" + _cNumPC + "' "
cQrySCR += "  AND CR_TIPO = 'PC' "
cQrySCR += "  AND D_E_L_E_T_ = ' ' "                        
cQrySCR += "  ORDER BY CR_NIVEL "	
cQrySCR := ChangeQuery(cQrySCR)
MPSysOpenQuery(cQrySCR,"TRBSCR")
		
DBSelectArea("TRBSCR")

TRBSCR->(dbGoTop())
				
Do While !TRBSCR->(EOF())

	SCR->(Dbgoto(TRBSCR->RECNUM))

	If ASCAN(_aAprov,SCR->CR_USER+"|"+SCR->CR_NIVEL ) = 0
		aAdd(_aAprov,SCR->CR_USER+"|"+SCR->CR_NIVEL)
	Else
		Loop
	EndIf
	_cDep:="XXXXXXX"
	PswOrder(1) // Busca por ID
	If PSWSEEK(SCR->CR_USER, .T. )
		_aDados:=PSWRET(1)// Retorna vetor com informa��es do usu�rio
		_cDep  :=ALLTRIM(_aDados[1][12])//CARGO
		
		If VALTYPE(oProc) = "O"
			oProc:cCaption :=  "Lendo Aprovador PC: "+_cNumPC+" / "+_aDados[1][2]
			ProcessMessages()
		EndIf   
		
		If UPPER(_cDep) <> "DIRECAO"//N�o envia para diretoria
			_cEmail += AllTrim( _aDados[1][14] )+";"
			_cNomes += Capital(AllTrim( _aDados[1][04] ))+CRLF
		EndIf
	EndIf
	TRBSCR->(dbSkip())
EndDo 

TRBSCR->(DBCloseArea())

Return {_cEmail,_cNomes}

/*
===============================================================================================================================
Programa--------: EnviaWF4()
Autor-----------: Alex Wallauer
Data da Criacao-: 07/11/2013
Descri��o-------: Monta e dispara o WF para avisar que a nota fiscal foi inclu�da fora do prazo.
Parametros------: _lReenvio,oProc
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function EnviaWF4(_lReenvio As Logical,oProc As Object)

Local _aConfig	:= U_ITCFGEML('') As Array
Local _cEmlLog	:= "" As Character
Local _cMsgEml	:= "" As Character
Local _cGetPara	:= SuperGetMV("IT_NFEWKFL4",.F.,"sistema@italac.com.br") As Character
Local cGetCc	:= "" As Character
Local _cNomeFil := cFilAnt+" - "+AllTrim( Posicione('SM0',1,"01"+cFilAnt,'M0_FILIAL') ) As Character
Local cGetAssun := "Nota fiscal foi inclu�da fora do prazo : "+SF1->F1_FILIAL+" "+SF1->F1_DOC+" "+SF1->F1_SERIE As Character
Local _aSizes   := {} As Array
Local _nI 		:= 0 As Numeric
Local _aTLinhas := {} As Array
Local _aLinhas  := {} As Array
Local _aCab     := {} As Array
Local _lEnvia   :=.F. As Logical
Local _lAmbTeste:= SuperGetMV("IT_AMBTEST",.F.,.T.) As Logical

If Day(DATE()) > 5 .AND. AnoMes(SF1->F1_EMISSAO) < AnoMes(Date())    //Emiss�o do mes passado depois do dia 5
   _lEnvia:=.T.
ElseIf Day(DATE()) <= 5 .AND. AnoMes(SF1->F1_EMISSAO) < AnoMes(MonthSub(Date(),1))//Emiss�o do mes retrasado ate o dia 5
   _lEnvia:=.T.
EndIf

If _lReenvio
	If !_lEnvia
		FWAlertWarning("E-mail n�o pode ser enviado. Data de Emissao: "+DTOC(SF1->F1_EMISSAO)+" no prazo." ,"MT103FIM17")
		Return .F.
	ElseIf !FWAlertYesNo("Confirma envio do Workflow de NOTA FISCAL FOI INCLU�DA FORA DO PRAZO? Data de Emissao: "+DTOC(SF1->F1_EMISSAO)+" fora do Prazo.","MT103FIM18")
		Return .F.
	EndIf
ElseIf !_lEnvia
	Return .F.
EndIf

SD1->( DBSetOrder(1) ) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
SC1->( DBSETORDER(1) )
SC7->( DBSETORDER(1) )
SF4->( DBSETORDER(1) )

_aLinhas:={}
If SD1->( DBSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
	If SF1->F1_TIPO = 'D'
		_cTipo:='Devolucao'
	ElseIf SF1->F1_TIPO = 'B'
		_cTipo:='Beneficiamento'
	ElseIf SF1->F1_TIPO = 'N'
		_cTipo:='Normal' 
	Else 
		_cTipo:='Complemento ['+SF1->F1_TIPO+"]"
	EndIf
	_cNome:=ALLTRIM(U_NomeCliFor(SF1->F1_TIPO,"SF1"))

	aAdd(_aLinhas, SF1->F1_FILIAL+"-"+ALLTRIM(FWFilialName(,SF1->F1_FILIAL)))
	aAdd(_aLinhas, _cTipo)
	aAdd(_aLinhas, SF1->F1_ESPECIE)
	aAdd(_aLinhas, SF1->F1_DOC)
	aAdd(_aLinhas, SF1->F1_SERIE)

	aAdd(_aLinhas, SF1->F1_FORNECE)
	aAdd(_aLinhas, SF1->F1_LOJA)
	aAdd(_aLinhas, _cNome)
	aAdd(_aLinhas, DTOC(SF1->F1_DTDIGIT))
	aAdd(_aLinhas, DTOC(SF1->F1_EMISSAO))

	aAdd(_aLinhas, ALLTRIM(TRANSFORM(SF1->F1_VALBRUT,"@E 999,999,999,999.99")))
	aAdd(_aLinhas, ALLTRIM(TRANSFORM(SF1->F1_IRRF   ,"@E 999,999,999,999.99")))
	aAdd(_aLinhas, ALLTRIM(TRANSFORM(SF1->F1_VALPIS ,"@E 999,999,999,999.99")))
	aAdd(_aLinhas, ALLTRIM(TRANSFORM(SF1->F1_VALCOFI,"@E 999,999,999,999.99")))
	aAdd(_aLinhas, ALLTRIM(TRANSFORM(SF1->F1_VALCSLL,"@E 999,999,999,999.99")))
EndIf

If LEN(_aLinhas) = 0
	If _lReenvio	
		FWAlertInfo("N�o h� itens para envido do Workflow de aquisi��o de produtos","MT103FIM19")
	EndIf
	Return .F.
EndIf

aAdd(_aCab,"Filial"      )    
aAdd(_aSizes,"16") 
aAdd(_aCab,"Tipo"        )  
aAdd(_aSizes,"08") 
aAdd(_aCab,"Especie"     )      
aAdd(_aSizes,"04") 
aAdd(_aCab,"Numero"      )     
aAdd(_aSizes,"08") 
aAdd(_aCab,"Serie"       )    
aAdd(_aSizes,"05") 
aAdd(_aCab,"Fornecedor"  )          
aAdd(_aSizes,"08") 
aAdd(_aCab,"Loja"        )  
aAdd(_aSizes,"05") 
aAdd(_aCab,"Razao"       )    
aAdd(_aSizes,"50")
aAdd(_aCab,"Digitacao")       
aAdd(_aSizes,"08")
aAdd(_aCab,"Emissao"     )      
aAdd(_aSizes,"08") 
aAdd(_aCab,"Total"       )    
aAdd(_aSizes,"16") 
aAdd(_aCab,"IRRF"        )   
aAdd(_aSizes,"16") 
aAdd(_aCab,"PIS"         )  
aAdd(_aSizes,"16") 
aAdd(_aCab,"COFINS"      )     
aAdd(_aSizes,"16") 
aAdd(_aCab,"CSL"         )  
aAdd(_aSizes,"16")

_cMsgEml := '<html>'
_cMsgEml += '<head><title>'+cGetAssun+'</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '	     <td class="titulos"><center>'+cGetAssun+'</center></td>'
_cMsgEml += '	 </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados de envio</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>NF lancada por: </b></td>'
_cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>' 
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
_cMsgEml += '      <td class="itens" >'+ _cNomeFil +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data / Hora:</b></td>'
_cMsgEml += '      <td class="itens" >'+ DTOC(DATE())+" / "+TIME() +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta � uma mensagem autom�tica. Por favor n�o a responda!</u></font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1500">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="'+STR(LEN(_aCab),2)+'" class="grupos">Nota fiscal foi inclu�da fora do prazo</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCab[01]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCab[02]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>'+_aCab[03]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>'+_aCab[04]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%"><b>'+_aCab[05]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%"><b>'+_aCab[06]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[07]+'%"><b>'+_aCab[07]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[08]+'%"><b>'+_aCab[08]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[09]+'%"><b>'+_aCab[09]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[10]+'%"><b>'+_aCab[10]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[11]+'%"><b>'+_aCab[11]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[12]+'%"><b>'+_aCab[12]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[13]+'%"><b>'+_aCab[13]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[14]+'%"><b>'+_aCab[14]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[15]+'%"><b>'+_aCab[15]+'</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    #LISTA#'
_cMsgEml += '</table>'
_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > [ '+ GETENVSERVER() +' ] / <b>Fonte:</b>[ MT103FIM ]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'

_aTLinhas :={_aLinhas}
_cGetLista:=""
For _nI := 1 To LEN(_aTLinhas)
	_cGetLista += '    <tr>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[01]+'%">'+_aTLinhas[_nI][01]+'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[02]+'%">'+_aTLinhas[_nI][02]+'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[03]+'%">'+_aTLinhas[_nI][03]+'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[04]+'%">'+_aTLinhas[_nI][04]+'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[05]+'%">'+_aTLinhas[_nI][05]+'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[06]+'%">'+_aTLinhas[_nI][06]+'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[07]+'%">'+_aTLinhas[_nI][07]+'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[08]+'%">'+_aTLinhas[_nI][08]+'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[09]+'%">'+_aTLinhas[_nI][09]+'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[10]+'%">'+_aTLinhas[_nI][10]+'</td>'
	_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[11]+'%">'+_aTLinhas[_nI][11]+'</td>'
	_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[12]+'%">'+_aTLinhas[_nI][12]+'</td>'
	_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[13]+'%">'+_aTLinhas[_nI][13]+'</td>'
	_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[14]+'%">'+_aTLinhas[_nI][14]+'</td>'
	_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[15]+'%">'+_aTLinhas[_nI][15]+'</td>'
	_cGetLista += '    </tr>'
Next _nI

_cMsgEml:=STRTRAN(_cMsgEml,"#LISTA#",_cGetLista)

/// Chama a fun��o para envio do e-mail
U_ITENVMAIL( _aConfig[01], _cGetPara, cGetCc, "", cGetAssun, _cMsgEml, "", _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

If _lReenvio .OR. _lAmbTeste
	FWAlertInfo(UPPER(_cEmlLog)+CRLF+"E-mail para: "+_cGetPara +CRLF+"CC: "+ALLTRIM(cGetCc)+CRLF + cGetAssun,"MT103FIM20")
Else
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MT103FIM"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MT103FIM21"/*cMsgId*/, "MT103FIM21 - "+UPPER(_cEmlLog)+" - E-mail para: "+_cGetPara/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
EndIf
    
Return .T.

/*
===============================================================================================================================
Programa----------: fEnderec
Autor-------------: Igor Melga�o
Data da Criacao---: 01/03/2023
Descri��o---------: Grava��o automatica do endere�o
Parametros--------: _nOpcao  3 - Executa o endere�amento do item  4 - Executa o estorno do item
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function fEnderec(_nOpcao As Numeric)

Local aCabSDA       := {} As Array
Local aItSDB        := {} As Array
Local _aItensSDB    := {} As Array
Private lMsErroAuto := .F. As Logical

//Cabecalho com a informa��oo do item e NumSeq que sera endere�ado.
aCabSDA := {{"DA_PRODUTO" ,SD1->D1_COD		,Nil},;
			{"DA_NUMSEQ"  ,SD1->D1_NUMSEQ	,Nil}}

//Dados do item que ser� endere�ado
aItSDB := {{"DB_ITEM"     ,SD1->D1_ITEM     ,Nil},;
			{"DB_ESTORNO" ,Iif(_nOpcao=4,"S ", " "),Nil},;
			{"DB_LOCALIZ" ,SBZ->BZ_I_LOCAL	,Nil},;
			{"DB_DATA"    ,dDataBase   		,Nil},;
			{"DB_QUANT"   ,SD1->D1_QUANT    ,Nil}}
aAdd(_aItensSDB,aitSDB)

//3 Executa o enderecamento do item
//4 Executa o estorno do item
MATA265( aCabSDA, _aItensSDB, _nOpcao)
If lMsErroAuto
	MostraErro()
EndIf
 
Return
