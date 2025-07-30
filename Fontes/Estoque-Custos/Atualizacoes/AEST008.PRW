/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Josué Prestes |16/01/2019| Chamado 27727. Revisão de fonte para novo appserver
Alex Wallauer |06/11/2019| Chamado 28346. Revisão de fonte para novo appserver
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da função de conout
================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMAKE.CH"  
#INCLUDE "PROTHEUS.CH"      


/*
===============================================================================================================================
Programa----------: AEST008
Autor-------------: Josué Danich Prestes
Data da Criacao---: 14/10/2015
Descrição---------: Rotina de estorno de desmontagem de produtos 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST008()

Local _nReg   	:= SD3->( Recno() )
Local _nopc		:= 5
Local _nCnt		:=0
Local _dDataFec 	:= If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))
Local _nzi			:=0
Local _lAbandona	:=.F.
Local _oDlg
Local _aObjects 	:={}
Local _aPosObj  	:={}
Local _aSize    	:= MsAdvSize()
Local _aInfo    	:={_aSize[1],_aSize[2],_aSize[3],_aSize[4],3,3}
Local _aButtons 	:= {}
Local _nX       	:= 0
Local _lContinua	:=.T.
Local _nziRec  	:= 0
Local _cCampos 	:= "D3_COD.D3_LOCAL.D3_QUANT.D3_RATEIO.D3_QTSEGUM.D3_LOCALIZ.D3_NUMLOTE.D3_LOTECTL.D3_DTVALID.D3_NUMSERI.D3_POTENCI.D3_CONTA.D3_ITEMCTA.D3_CLVL.D3_CC"
Local _cseq		:= SD3->D3_NUMSEQ
Local _bCampo		:= {|nCPO| Field(nCPO) }
Local _aLockSD3 	:= {}
Local _aLockSB2 	:= {}
Local  _cerro 	:= ""	, _nj
Local _lret 		:= .T. , i


PRIVATE oGet
PRIVATE nRecOld
PRIVATE cProduto,cLocOrig,nQtdOrig,nQtdOrigSe,cDocumento,cNumLote,cLoteDigi,dDtValid,dEmis260,nPotencia
PRIVATE cLocaliza,cNumSerie
PRIVATE nPosCod,nPosLocal,nPosLocali:=0,nPosNumSer:=0,nPosQuant,nPosRateio:=0,cTM:="499",nPosLotCtl,nPosDValid,nPosLote,nPosPotenc
PRIVATE nPosQTSegum,nPosCta,nPosItCta,nPosCLVL,nPosCC,nPosServic,aSldNeg := {}

//Log de utilização
U_ITLOGACS()

//================================================================
// Verificar data do ultimo fechamento em SX6.                  
//================================================================
If _dDataFec >= SD3->D3_EMISSAO
	u_itmsg("Movimento anterior ao último fechamento de estoque","Atenção",,1)
	_lContinua := .F.
EndIf

If _lContinua .And. SubStr(D3_CF,3,1) != "7"

	 u_itmsg("Nao é movimento de desmontagem!","Atenção",,1)
	_lContinua := .F.

EndIf

If _lContinua .And. D3_ESTORNO == "S"
	
	u_itmsg("Esse movimento ja foi estornado!","Atenção",,1)
	SetCursor(0)
	_lContinua := .F.

EndIf

If _lContinua

	dbSelectArea("SD3")
	SD3-> ( dbSetOrder(4) )

	//================================================================
	// Pega a seq. do movimento para achar a origem e recupera os   
	// dados da origem.                                             
	//================================================================
	SD3->( dbSeek(xFilial("SD3")+_cseq))
	cDocumento 	:= SD3->D3_DOC
	dEmis260  		:= D3_EMISSAO
	_cseq      		:= D3_NUMSEQ

	While !Eof() .And. SD3->D3_NUMSEQ == _cseq

		If SD3->D3_CF != "RE7" .Or. SD3->D3_DOC != cDocumento .Or. SD3->D3_EMISSAO != dEmis260

			dbSkip()
			Loop

		EndIf

		Exit

	End

	cProduto  :=D3_COD
	cLocOrig  :=D3_LOCAL
	nQtdOrig  :=D3_QUANT
	nQtdOrigSe:=D3_QTSEGUM
	cDocumento:=D3_DOC
	
	If !__lPyme
		cNumLote :=D3_NUMLOTE
		cLoteDigi:=D3_LOTECTL
		dDtValid :=D3_DTVALID
		nPotencia:=D3_POTENCI
		cLocaliza:=D3_LOCALIZ
		cNumSerie:=D3_NUMSERI
		
	EndIf
	
	dEmis260:=D3_EMISSAO
	_cseq    :=D3_NUMSEQ
	
	nRecOld:=Recno()
	dbSkip()

	Do While !Eof() .And. D3_FILIAL+D3_NUMSEQ == xFilial("SD3")+_cseq
	
		_nCnt++
		dbSkip()
	
	EndDo

	dbGoto(nRecOld)
	dbSkip()

	//================================================================
	// Monta a entrada de dados do arquivo                          
	//================================================================
	PRIVATE aHeader[0]
	PRIVATE nUsado:=0

    If IntDl()
    
		_cCampos +=  ".D3_SERVIC"
		
	EndIf

 	//================================================================
	// Monta o cabecalho da GetDados                                
	//================================================================
	aHeader := {}
	aadd(aheader,{"Produto","D3_COD    ","@!                                           ",15,0,"A093Prod().And.A241PrdGrd().And. A241VLDFan(M->D3_COD)                                                                          ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Desc. Detalh","D3_I_DESPR","@!                                           ",100,0," ","€€€€€€€€€€€€€€ ","C","SD3","V"})
	aadd(aheader,{"Quantidade","D3_QUANT  ","@E 99,999,999.999                            ",12,3,"A240Quant()                                                                                                                     ","€€€€€€€€€€€€€€ ","N","SD3","R"})
	aadd(aheader,{"% Rateio","D3_RATEIO ","@E 999.99                                    ",6,2,"M->D3_RATEIO > 0                                                                                                                ","€€€€€€€€€€€€€€ ","N","SD3"," "})
	aadd(aheader,{"Qtd. 2a UM","D3_QTSEGUM","@E 99,999,999.999                            ",12,3,"AQtdGrade().And.A240PriUm()                                                                                                     ","€€€€€€€€€€€€€€ ","N","SD3","R"})
	aadd(aheader,{"Armazem","D3_LOCAL  ","@!                                           ",2,0,'ExistCpo("NNR") .And. A240Local()                                                                                               ',"€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Cod Motivo","D3_I_MOTIV","@!                                           ",2,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"C Contabil","D3_CONTA  ","@!                                           ",20,0,"vazio().or. Ctb105Cta()                                                                                                         ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"C Custo","D3_CC     ","@!                                           ",9,0,"vazio().or. Ctb105CC()                                                                                                          ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Valid. Lote","D3_DTVALID","@D                                           ",8,0,"A240DtVali()                                                                                                                    ","€€€€€€€€€€€€€€ ","D","SD3","R"})
	aadd(aheader,{"Lote","D3_LOTECTL"," ",10,0,"A240Lote()                                                                                                                      ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Sub-Lote","D3_NUMLOTE","@!                                           ",6,0,"A240Lote()                                                                                                                      ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Endereco","D3_LOCALIZ","@!                                           ",15,0,"A240Locali()                                                                                                                    ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Num de Serie","D3_NUMSERI","@!                                           ",20,0,"A240NumSer()                                                                                                                    ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Item Conta","D3_ITEMCTA","@!                                           ",9,0,"vazio().or. Ctb105Item()                                                                                                        ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Classe Valor","D3_CLVL   ","@!                                           ",9,0,"vazio().or.Ctb105ClVl()                                                                                                         ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Cod.Servico","D3_SERVIC ","@!                                           ",3,0,"Vazio() .Or. ExistCpo('DC5')                                                                                                    ","€€€€€€€€€€€€€€ ","C","SD3"," "})
	aadd(aheader,{"Potencia Lot","D3_POTENCI","@E 999.99                                    ",6,2,"A240Potenc()                                                                                                                    ","€€€€€€€€€€€€€€ ","N","SD3"," "})
	aadd(aheader,{"Observacao","D3_I_OBS  ","@!                                           ",254,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Produto Pai","D3_I_PAI  ","@!                                           ",15,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Nro Doc Ita.","D3_I_DOC  ","@!                                           ",9,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Setor","D3_L_SETOR","@!                                           ",6,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Origem","D3_L_ORIG ","@!                                           ",50,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Num S.A.","D3_I_NUMCP","@!                                           ",6,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Doc Inventar","D3_I_DOCIN","@!                                           ",9,0," ","€€€€€€€€€€€€€€€","C","SD3","R"})
	aadd(aheader,{"Origem","D3_I_ORIGE"," ",40,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Hora Apon","D3_I_HRAP "," ",5,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})
	aadd(aheader,{"Data Apont.","D3_I_DTAP "," ",8,0," ","€€€€€€€€€€€€€€ ","D","SD3","R"})
	aadd(aheader,{"Tp de Transf","D3_I_TPTRS"," ",1,0," ","€€€€€€€€€€€€€€ ","C","SD3","R"})

	For _nX:= 1 To Len(aHeader)
		If Trim(aHeader[_nX][2]) == "D3_COD"
			nPosCod:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_LOCAL"
			nPosLocal:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_QUANT"
			nPosQuant:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_RATEIO"
			nPosRateio:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_QTSEGUM"
			nPosQTSegum:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_LOCALIZ"
			nPosLocali:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_NUMSERI"
			nPosNumSer:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_NUMLOTE"
			nPosLote:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_LOTECTL"
			nPosLotCtl:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_DTVALID"
			nPosDValid:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_POTENCI"
			nPosPotenc:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_CONTA"
			nPosCta:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_ITEMCTA"
			nPosItCta:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_CLVL"
			nPosCLVL:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_CC"
			nPosCC:=_nX
		ElseIf Trim(aHeader[_nX][2]) == "D3_SERVIC"
			nPosServic:=_nX
		EndIf
	Next _nX

	ADHeadRec("SD3",aHeader)
	_nziRec := Len(aHeader)
	
	PRIVATE aCOLS[_nCnt][_nziRec]
	dbSelectArea("SD3")
	_nCnt := 0
	
	While !(SD3->( Eof() )) .And. SD3->D3_FILIAL+SD3->D3_NUMSEQ == xFilial("SD3")+_cseq

		If SD3->D3_CF != "DE7" .or. SD3->D3_DOC != cDocumento .or. SD3->D3_EMISSAO != dEmis260
	
			dbSkip()
			Loop
	
		EndIf
		//============================================================================
		// AvalMovDiv - Funcao utilizada para avaliar possiveis divergencias de     |
		//|              saldo no estorno do movimento selecionado.                 
		//============================================================================
		If FindFunction("AvalMovDiv") .And. AvalMovDiv(D3_COD,D3_LOCAL,D3_LOTECTL,D3_NUMLOTE,D3_NUMSEQ)
			U_ITMSG('Divergência no saldo de estorno','Atenção','Estorno não serão executado',1)
			Return Nil
		EndIf
		
		_nCnt++
		nUsado:=0

		For _nj := 1 to len(aheader)-2
				nUsado++
				If aheader[_nj][10] != "V"
					aCOLS[_nCnt][nUsado] := &('SD3->'+alltrim(aheader[_nj][2]))
				ElseIf aheader[_nj][10] == "V"
					aCOLS[_nCnt][nUsado] := CriaVar(alltrim(aheader[_nj][2]))
				EndIf
		Next
		aCOLS[_nCnt][_nziRec-1] := "SD3"
		aCOLS[_nCnt][_nziRec]   := SD3->( Recno() )
		dbSelectArea("SD3")
		SD3->( dbSkip() )
	EndDo


	//================================================================
	// Verifica se algum produto esta  sendo inventariado.  
	//================================================================
	For _nzi:=1 To Len(aCols)

		If BlqInvent(aCols[_nzi,nPosCod],aCols[_nzi,nPosLocal])

			Help(" ",1,"BLQINVENT",,aCols[_nzi,nPosCod]+OemToAnsi("Produto bloqueado por inventario")+aCols[_nzi,nPosLocal],1,11)
			_lAbandona:=.T.

		EndIf

	Next _nzi
	
	//================================================================
	// Verifica se o produto origem est  sendo inventariado
	//================================================================

	If BlqInvent(cProduto,cLocOrig)

		Help(" ",1,"BLQINVENT",,cProduto+OemToAnsi("Produto bloqueado por inventario")+cLocOrig,1,11)
		_lContinua := .F.

	EndIf

	//======================================================================
	//Verifica se estorno não gerará saldos negativos
	//======================================================================

	For _nzi:=1 to len(acols)

		//Varre os saldos de cada dia atá a data de hoje buscando por saldo insuficiente

		MsAguarde({|| aSldNeg := U_VldEstRetrNeg(aCols[_nzi,nPosCod], aCols[_nzi,nPosLocal], aCols[_nzi,nPosQuant], dEmis260) },"Verificando saldos...")   

		If Len(aSldNeg) > 0
   
    		_cerro += "Produto: " + alltrim(aCols[_nzi,nPosCod]) + " no armazém " + aCols[_nzi,nPosLocal] + " com saldo " + TRANSFORM(aSldNeg[2],"@E 999,999.99") + " na data " + dtoc(aSldNeg[1]) + space(15)
    		_lret  := .F.
   
		EndIf 
	
	Next

	If .not. _lret

		xmaghelpfis("Atenção!", "Não permitido, deixará os seguintes produtos com saldo negativo: " + space(15) + _cerro,;
   						"Realizar os ajustes de estoque necessários antes de estornar a desmontagem")
   						
   		_lContinua := .F.
	
	Endif
	
	

EndIf


If _lContinua

	AADD(_aObjects,{100,050,.T.,.F.,.F.})
	AADD(_aObjects,{100,100,.T.,.T.,.F.})

	_aPosObj:=MsObjSize(_aInfo,_aObjects)
	
	_nopca:=2
	_nLin:=05

	DEFINE MSDIALOG _oDlg TITLE cCadastro OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]

	
	       oTPanel1 := TPanel():New(1,0,"",_oDlg,NIL,.T.,.F.,NIL,NIL,150,35,.T.,.F.) 
	
				@ _nLin+2,003 SAY OemToAnsi("Produto Origem")	SIZE 45,07 OF oTPanel1 PIXEL		
				@ _nLin  ,045 MSGET cProduto   SIZE 53,10 WHEN .F. OF oTPanel1 PIXEL
  				@ _nLin  ,120 MSGET (cDesc:=posicione("SB1",1, xfilial("SB1") + cProduto,"B1_DESC"))  SIZE 205,10 WHEN .F. OF oTPanel1 PIXEL
				@ _nLin+2,350 SAY OemToAnsi("Armazem")	SIZE 29,07 OF oTPanel1 PIXEL		
				@ _nLin  ,390 MSGET cLocOrig   SIZE 13,10 WHEN .F. OF oTPanel1 PIXEL
				@ _nLin+2,480 SAY OemToAnsi("Data")	SIZE 16,07 OF oTPanel1 PIXEL		
				@ _nLin  ,500 MSGET dEmis260   SIZE 38,10 WHEN .F. OF oTPanel1 PIXEL
                _nLin+=15
				@ _nLin+2,003 SAY OemToAnsi("Quantidade")	SIZE 34,07 OF oTPanel1 PIXEL		
				@ _nLin  ,045 MSGET nQtdOrig   SIZE 50,10 WHEN .F. OF oTPanel1 PIXEL Picture cPicQtOri
				@ _nLin+2,120 SAY OemToAnsi("Quantidade Secundaria")	SIZE 68,07 OF oTPanel1 PIXEL		
				@ _nLin  ,180 MSGET nQtdOrigSe SIZE 50,10 WHEN .F. OF oTPanel1 PIXEL Picture cPicQtDes
				@ _nLin+2,245 SAY OemToAnsi("Documento")	SIZE 34,07 OF oTPanel1 PIXEL		
				@ _nLin  ,275 MSGET cDocumento SIZE 50,10 WHEN .F. OF oTPanel1 PIXEL

	                             //_aPosObj[2,1]+15
		        oGet := MSGetDados():New(60,_aPosObj[2,2],_aPosObj[2,3],_aPosObj[2,4],_nopc,"AllwaysTrue","AllwaysTrue",,,,,,300)

			ACTIVATE MSDIALOG _oDlg ON INIT ( EnchoiceBar(_oDlg,{|| (_nopca:=1,_oDlg:End()) },{|| (_nopca:=2,_oDlg:End()) },,_aButtons)  , oTPanel1:Align := CONTROL_ALIGN_TOP , oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  )

		//se confirmou faz o estorno de todos os lançamentos
		if _nopca == 1		

			//================================================================
			// Verifica se o custo medio e' calculado On-Line               
			//================================================================
			If cCusMed == "O"
				
				//================================================================
				// Se necessario cria o cabecalho do arquivo de prova           
				//================================================================
	
				If lCriaHeader
		
					lCriaHeader := .F.
					nHdlPrv := HeadProva(cLoteEst,"MATA242",Subs(cUsuario,7,6),@cArquivo)
					
					If nHdlPrv <= 0
			
						//================================================================
						// Restaura a integridade da janela                             
						//================================================================
						dbSelectArea("SD3")
						_lContinua := .F.
						
					EndIf
				
				EndIf
			
			EndIf

		Else
		
			_lContinua := .F.
			
		Endif
		
			
		If _lContinua
	
			Begin Transaction
		
			//================================================================
			// Tratamento para Dead-Lock                                              
			//================================================================
		
			//Produto Origem
			If aScan(_aLockSD3,cProduto+cLocOrig+_cseq)==0
	
				aadd(_aLockSD3,cProduto+cLocOrig+_cseq)
	
			EndIf
		
			If aScan(_aLockSB2,cProduto+cLocOrig)==0
	
				aadd(_aLockSB2,cProduto+cLocOrig)
	
			EndIf
			
			For _nX := 1 to Len(aCols)
				
				If aScan(_aLockSD3,aCols[_nX][nPosCod]+aCols[_nX][nPosLocal]+_cseq)==0
				
					aadd(_aLockSD3,aCols[_nX][nPosCod]+aCols[_nX][nPosLocal]+_cseq)
			
				EndIf
				
				If aScan(_aLockSB2,aCols[_nX][nPosCod]+aCols[_nX][nPosLocal])==0
				
					aadd(_aLockSB2,aCols[_nX][nPosCod]+aCols[_nX][nPosLocal])
				
				EndIf
		
			Next _nX	

			//================================================================
			// Tratamento para Dead-Lock                                              
			//================================================================
			If MultLock("SD3",_aLockSD3,3) .And. MultLock("SB2",_aLockSB2,1)
			
				//================================================================
				// Gera movimento inverso da origem           
				//================================================================
				//================================================================
				// Grava o Flag de estorno                    
				//================================================================
			
				dbSelectArea("SD3")
				dbGoTo(nRecOld)
				
				If D3_ESTORNO == "S"
					
					Help(" ",1,"A242ESTORN")
				
				Else

					RecLock("SD3",.F.)
					Replace D3_ESTORNO With "S"
				
					//================================================================
					//³ Salva a integridade dos campos de Bancos de Dados            
					//================================================================
					For i := 1 To FCount()
			
						M->&(EVAL(_bCampo,i)) := FieldGet(i)
			
					Next i
		
					//================================================================
					// Cria o registro de estorno com mesmos dados do original      
					//================================================================
					RecLock("SD3",.T.)
				
					For i := 1 To FCount()
				
						FieldPut(i,M->&(EVAL(_bCampo,i)))
				
					Next i
				
					Replace D3_TM With "499",D3_CF With "DE7"
					Replace D3_CHAVE   With SubStr(D3_CF,2,1)+IIf(D3_CF=="DE7","9","0")
					Replace D3_USUARIO With CUSERNAME
				
					//================================================================
					// Pega o custo da movimentacao               
					//================================================================
					aCusto := PegaCusD3()
					//================================================================
					// Atualiza o saldo atual (VATU) com os dados do SD3     
					//================================================================
					If !B2AtuComD3(aCusto)
				
						//================================================================
						// Verifica se o custo medio e' calculado On-Line               
						//================================================================
						If cCusMed == "O"
				
							//================================================================
							// Gera o lancamento no arquivo de prova           
							//================================================================
							nTotal+=DetProva(nHdlPrv,"672","MATA242",cLoteEst)
				
						EndIf

						dbSelectArea("SD3")
						dbSetOrder(4)
						dbSeek(xFilial("SD3")+_cseq)

						//================================================================
						// Gera movimento inverso do destino          
						//================================================================
						While !Eof() .and. SD3->D3_NUMSEQ == _cseq

							If SD3->D3_CF != "DE7" .or. SD3->D3_DOC != cDocumento .or. SD3->D3_EMISSAO != dEmis260 .Or. SD3->D3_ESTORNO == "S"
				
								dbSkip()
								Loop
				
							EndIf

							//================================================================
							// Grava o Flag de estorno                    
							//================================================================
							dbSelectArea("SD3")
							RecLock("SD3",.F.)
							Replace D3_ESTORNO With "S"

							//================================================================
							// Salva a integridade dos campos de Bancos de Dados           
							//================================================================
							For i := 1 To FCount()
				
								M->&(EVAL(_bCampo,i)) := FieldGet(i)
				
							Next i

							//================================================================
							// Cria o registro de estorno com mesmos dados do original      
							//================================================================
							RecLock("SD3",.T.)
						
							For i := 1 To FCount()
						
								FieldPut(i,M->&(EVAL(_bCampo,i)))
							
							Next i
						
							Replace D3_TM 	   With "999",D3_CF With "RE7"
							Replace D3_CHAVE   With SubStr(D3_CF,2,1)+IIf(D3_CF=="DE7","9","0")
							Replace D3_USUARIO With CUSERNAME

							//================================================================
							// Pega o custo da movimentacao              
							//================================================================
							aCusto := PegaCusD3()

							//================================================================
							// Atualiza o saldo atual (VATU) com os dados do SD3     
							//================================================================
							If !B2AtuComD3(aCusto)

								//================================================================
								// Verifica se o custo medio e' calculado On-Line               
								//================================================================
								If cCusMed == "O"
							
									//================================================================
									// Gera o lancamento no arquivo de prova           
									//================================================================
									nTotal+=DetProva(nHdlPrv,"670","MATA242",cLoteEst)
						
								EndIf
						
							
							EndIf
						
							dbSelectArea("SD3")
							dbSkip()
					
						End
					
					EndIf
			
				EndIf
		
			Else
				FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "AEST008"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "AEST00801"/*cMsgId*/, "AEST008 - DEADLOCK CONTROL IS ON"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			EndIf
	
			End Transaction

			//================================================================
			// Verifica se o custo medio e' calculado On-Line               
			//================================================================
			If cCusMed == "O"
		
				//================================================================
				// Inicializa perguntas deste programa                          
				///================================================================
				//================================================================
				// mv_par01 - Se mostra e permite digitar lancamentos contabeis   
				// mv_par02 - Se deve aglutinar os lancamentos contabeis          
				//================================================================
			
				Pergunte("MTA260",.F.)
		
				lDigita   := Iif(mv_par01 == 1,.T.,.F.)
				lAglutina := Iif(mv_par02 == 1,.T.,.F.)

				//================================================================
				// Se ele criou o arquivo de prova ele deve gravar o rodape'    
				//================================================================
				RodaProva(nHdlPrv,nTotal)
				cA100Incl(cArquivo,nHdlPrv,3,cLoteEst,lDigita,lAglutina)
				lCriaHeader := .T.
	
			EndIf

			//================================================================
			// Restaura a integridade da janela                             
			//================================================================
		
			dbSelectArea("SD3")
			SetCursor(0)

		EndIf
	
			
	dbSelectArea("SD3")
	SD3->( dbGoto(_nReg) )
	
Endif

Return NIL
