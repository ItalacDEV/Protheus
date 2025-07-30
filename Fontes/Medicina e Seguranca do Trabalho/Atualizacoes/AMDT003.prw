/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 03/11/2017 | Realiza��o de ajustes nas rotinas de devolu��o de EPIs para que permitam a impress�o dos recibos de 
              |            | entrega de EPI. Chamados 22140/22154/19329.                   
--------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 10/04/2018 | Realiza��o de ajustes nas rotinas de entrega e devolu��o de EPI, para impress�o correta dos 
              |            | comprovantes. Chamado 23960.
--------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: AMDT003
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/06/2016
===============================================================================================================================
Descri��o---------: Devolu��es de EPI's
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AMDT003()
Local _cAlias		:= "TNF"
Local _aCores 		:=	{	{'TNF_I_TPDV == "T"'	, 'BR_BRANCO'	},;
							{'TNF_I_TPDV == "R"'	, 'BR_AMARELO'	} }

Private _aFixe 		:= { 	{ "Status Epi", "TNF_I_TPST"}	}
Private _cFiltro	:= " TNF_I_TPDV = 'T' OR TNF_I_TPDV = 'R' "
Private cCadastro	:= "Devolu��o de Epis"
Private aRotina		:= MenuDef()

mBrowse( 6, 1,22,75,_cAlias,_aFixe,,,,,_aCores,,,,,,,,_cFiltro)

Return


/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016
===============================================================================================================================
Descri��o---------: Rotina responsavel pela cria��o das op��es de menu
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Private aRotina	:=  {	{"Pesquisar"		,"AxPesqui"		, 0, 1, 0, .F.},;
						{"Devolu��o"		,"U_AMD003D"	, 0, 2, 0, .F.},;
						{"Exclus�o"			,"U_AMD003E"	, 0, 2, 0, .F.},;
						{"Visualizar"		,"AxVisual"		, 0, 2, 0, .F.},;
						{"Legenda"			,"U_AMD003LEG"	, 0, 2, 0, .F.} }

Return (aRotina)

/*
===============================================================================================================================
Programa----------: AMD003LEG
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/06/2016
===============================================================================================================================
Descri��o---------: Fun��o utilizada para montar a legenda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AMD003LEG()
aLegenda :=	{	{"BR_BRANCO"	, "Epi para Troca"		},;
				{"BR_AMARELO"	, "Epi para Re�so"		} }

BrwLegenda("Situa��o das Epi's","Legenda",aLegenda)
Return

/*
===============================================================================================================================
Programa----------: AMD003C
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/06/2016
===============================================================================================================================
Descri��o---------: Fun��o para marcar devolu��o dos EPI's
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AMD003C()

Local _aArea	:= GetArea()
Local _cMatric	:= SRA->RA_MAT
Local _nPosEpi	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_CODEPI"}	)
Local _nPosFor	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_FORNEC"}	)
Local _nPosLoj	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_LOJA"}		)
Local _nPosCap	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_NUMCAP"}	)
Local _nPosDte	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_DTENTR"}	)
Local _nPosHre	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_HRENTR"}	)
Local _nPosInd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_INDDEV"}	)
Local _oPnlSup, _oDlgQ
Local _nQtdEntr, _nQtdDevolv, _nSaldo, _nQtdADev
Local _nPosQEntr := aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_QTDENT"}	)
Local _nPosQDev  := aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_QTDEVO"}	)
Local _nLin := 2.5
Local _nOpcTNF := 0

Begin Sequence
   n:= ogettnf695:nat

   If aCols[n][_nPosInd] == "2"
	  If MsgYesNo("Deseja realmente confirmar a Devolu��o deste EPI?","AMDT00301")
	     _nQtdEntr := aCols[n][_nPosQEntr]
	     _nQtdDevolv := aCols[n][_nPosQDev]
	     _nSaldo := _nQtdEntr - _nQtdDevolv
	     _nQtdADev := 0
	     
	     If _nSaldo <= 0
	        MsgStop("N�o h� quantidades dispon�veis para devolu��o de EPIs.","AMDT00302 - Devolu��o de EPI")
	        Break
	     EndIf
	     
	     DEFINE MSDIALOG _oDlgQ TITLE "Devolu��o de EPIs" From 0,0 To 200,587 OF oMainWnd PIXEL // 440,587

	        @ 0.5+_nLin,1 SAY OemToAnsi("Qtd Entregue") Of _oDlgQ  
	        @ 0.5+_nLin,8.2  MSGET _nQtdEntr SIZE 20,10 Of _oDlgQ WHEN .F.   
	
	        @ 1.7+_nLin ,1 SAY OemToAnsi("Qtd Devolvida") Of _oDlgQ
	        @ 1.7+_nLin ,8.2  MSGET _nQtdDevolv SIZE 20,10 Of _oDlgQ WHEN .F.
	
	        @ 2.9+_nLin ,1 SAY OemToAnsi("Saldo") Of _oDlgQ
	        @ 2.9+_nLin ,8.2  MSGET _nSaldo SIZE 50,10 Of _oDlgQ WHEN .F.
	                                
	        @ 4.1+_nLin ,1 SAY OemToAnsi("Qtd a Devolver") Of _oPnlSup
	        @ 4.1+_nLin ,8.2  MSGET _nQtdADev SIZE 45,10 PICTURE "@E 999.99" VALID U_AMD003V(_nSaldo,_nQtdADev) Of _oDlgQ 

         ACTIVATE MSDIALOG _oDlgQ CENTERED ON INIT EnchoiceBar(_oDlgQ,{||_nOpcTNF:=1,_oDlgQ:End()},{||_nOpcTNF := 0,_oDlgQ:End()}) VALID U_AMD003V(_nSaldo,_nQtdADev)
	     
	     If _nOpcTNF <> 1
	        MsgStop("Rotina de Devolu��o de EPIs cancelada pelo usu�rio.","AMDT00303 - Devolu��o de EPI")
	        Break
	     EndIf
	     
         //=============================================	
         U_MDT6954G(.T.)
         
	  	 If Aviso("AMDT00304 - Reposicao do Estoque", "O EPI Ser�?", { "TROCA", "RE�SO" }, 1) = 1
			dbSelectArea("TNF")
			dbSetOrder(1)
			If dbSeek(xFilial("TNF") + aCols[n][_nPosFor] + aCols[n][_nPosLoj] + aCols[n][_nPosEpi] + aCols[n][_nPosCap] + _cMatric + DtoS(aCols[n][_nPosDte]) + aCols[n][_nPosHre])
				RecLock("TNF",.F.)
				TNF->TNF_I_TPDV := "T"
				TNF->TNF_I_QTDD := _nQtdADev
				TNF->(MsUnLock())
			    MsgInfo("O processo de devolu��o de EPI foi conlu�do com sucesso.","AMDT00305 - Devolu��o de EPI")
			 EndIf
		  Else
			 dbSelectArea("TNF")
			 dbSetOrder(1)
			 If dbSeek(xFilial("TNF") + aCols[n][_nPosFor] + aCols[n][_nPosLoj] + aCols[n][_nPosEpi] + aCols[n][_nPosCap] + _cMatric + DtoS(aCols[n][_nPosDte]) + aCols[n][_nPosHre])
	            RecLock("TNF",.F.)
				TNF->TNF_I_TPDV := "R"
				TNF->TNF_I_QTDD := _nQtdADev
				TNF->(MsUnLock())
				MsgInfo("O processo de devolu��o de EPI foi conlu�do com sucesso.","AMDT00306 - Devolu��o de EPI")
			 EndIf
		  EndIf
		  U_ITLOGACS('AMD003C')
	   EndIf
    Else
	   MsgAlert("Favor selecionar um EPI v�lido.","AMDT00307 - Devolu��o de EPI")
   EndIf
End Sequence

RestArea(_aArea)

Return


/*
===============================================================================================================================
Programa----------: AMD003D
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/06/2016
===============================================================================================================================
Descri��o---------: Fun��o efetivar a Devolu��o dos Epi's
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AMD003D()

Local _aArea	:= GetArea()
Local cMatricEn	:= TNF->TNF_MAT
Local cNomeFuEn	:= NGSeek("SRA",cMatricEn,1,"RA_NOME")
Local cFornecEn	:= TNF->TNF_FORNEC
Local cLojaSvEn	:= TNF->TNF_LOJA
Local cEpiSvoEn := TNF->TNF_CODEPI
Local cDesSb1En	:= NGSEEK("SB1",cEpiSvoEn,1,"B1_DESC")
Local cNumCapEn	:= TNF->TNF_NUMCAP
Local dDataSvEn	:= TNF->TNF_DTENTR
Local cHoraSvEn := TNF->TNF_HRENTR
Local nQtdadeEn	:= TNF->TNF_QTDENT
Local _nIQtdDev := TNF->TNF_I_QTDD
Local _nQtdSaldo:= nQtdadeEn - _nIQtdDev - TNF->TNF_QTDEVO
Local aNaoTLW	:= {}
Local nOpcTLW	:= 0
Local aAlter	:= {"TLW_QTDEVO"}
Local _cNUMSEQ	:= ""
Local _nPosDt	:= 0
Local _nPosHr	:= 0
Local _nPosQt	:= 0
Local _nPosAr	:= 0
Local _cTmpLote	:= ""
Local _cTmpSubL	:= ""
Local _cTmpLocz	:= ""
Local _cTmpNSer	:= ""
Local _nLocTipoDV, _nI 

Private aHeadTLW	:= {} //Cabe�alho da TLW
Private aHeader		:= {}
Private aCols		:= {}

Private lSigaMdtPS	:= If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private aDevEpi		:= {}
Private oPnlSup
Private oDlg

aHeadTLW	:= CABECGETD("TLW", aNaoTLW )
aHeader		:= aClone(aHeadTLW)

If TNF->TNF_I_TPDV == "T"
	aAdd(aCols,{Date(),Time(),0,"00","2","S",.F.})
ElseIf TNF->TNF_I_TPDV == "R"
	aAdd(aCols,{Date(),Time(),0,"05","2","S",.F.})
EndIf

_nLocTipoDV := aSCAN(aHeader, {|x| AllTrim(Upper(X[2])) == "TLW_TIPODV" })
For _nI := 1 To Len(aCols)
    aCols[_nI][_nLocTipoDV] := "1" // SIM
Next


DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 440,587 OF oMainWnd PIXEL

	oPnlSup := TPanel():New(0,0,,oDlg,,,,,,0,90,.F.,.F.) // 70
	oPnlSup:Align := CONTROL_ALIGN_TOP

	@ 0.5 ,.8 SAY OemToAnsi("Matricula") Of oPnlSup
	@ 0.5 ,5  MSGET cMatricEn SIZE 20,10 Of oPnlSup WHEN .F.
	@ 0.5 ,9  SAY OemToAnsi("Nome") Of oPnlSup
	@ 0.5 ,12 MSGET cNomeFuEn SIZE 196,10 Of oPnlSup WHEN .F.
	
	@ 1.7 ,.8 SAY OemToAnsi("Fornecedor") Of oPnlSup
	@ 1.7 ,5  MSGET cFornecEn SIZE 20,10 Of oPnlSup WHEN .F.
	@ 1.7 ,9  SAY OemToAnsi("Loja") Of oPnlSup
	@ 1.7 ,12 MSGET cLojaSvEn SIZE 15,10 Of oPnlSup WHEN .F.
	@ 1.7 ,17 SAY OemToAnsi("Nome Fornecedor") Of oPnlSup
	@ 1.7 ,24 MSGET Eval({|| Posicione("SA2",1,xFilial("SA2")+cFornecEn+cLojaSvEn,"A2_NOME")}) SIZE 100,10 Of oPnlSup WHEN .F.
	
	@ 2.9 ,.8 SAY OemToAnsi("Epi") Of oPnlSup
	@ 2.9 ,5  MSGET cEpiSvoEn SIZE 50,10 Of oPnlSup WHEN .F.
	@ 2.9 ,12 SAY OemToAnsi("Descricao") Of oPnlSup
	@ 2.9 ,17 MSGET cDesSb1En SIZE 65,10 Of oPnlSup WHEN .F.

	@ 2.9 ,26 SAY OemToAnsi("Num. C.A.") Of oPnlSup
	@ 2.9 ,30 MSGET cNumCapEn SIZE 40,10 Of oPnlSup WHEN .F.
	                                
	@ 4.1 ,.8 SAY OemToAnsi("Data Entrega") Of oPnlSup
	@ 4.1 ,5  MSGET dDataSvEn SIZE 45,10 Of oPnlSup WHEN .F. HASBUTTON
	
	@ 4.1 ,12 SAY OemToAnsi("Hora Entrega") Of oPnlSup
	@ 4.1 ,17 MSGET cHoraSvEn SIZE 18,10 Of oPnlSup WHEN .F.
	
	@ 4.1 ,24 SAY OemToAnsi("Qtde. Entregue") Of oPnlSup
	@ 4.1 ,29 MSGET nQtdadeEn Picture "@E 999.99" SIZE 25,10 Of oPnlSup WHEN .F. HASBUTTON
	
	@ 5.3 ,.8 SAY OemToAnsi("Qtd Devolvida") Of oPnlSup
	@ 5.3 ,5  MSGET _nIQtdDev SIZE 45,10 Of oPnlSup WHEN .F. 
	
	@ 5.3 ,12 SAY OemToAnsi("Saldo") Of oPnlSup
	@ 5.3 ,17 MSGET _nQtdSaldo SIZE 18,10 Of oPnlSup WHEN .F.
	
	dbSelectArea("TLW")
	oGet1 := MsNewGetDados():New( 090, 005, 205, 292, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "",aAlter,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader, aCols)  // 070, 005, 205, 292
	oGet1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcTLW:=1,oDlg:End()},{||nOpcTLW := 0,oDlg:End()}) VALID U_AMDTTOK(oGet1, nQtdadeEn, cMatricEn, cFornecEn, cLojaSvEn, cEpiSvoEn, cNumCapEn, dDataSvEn, cHoraSvEn,_nIQtdDev)

If nOpcTLW == 1

	_nPosDt	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "TLW_DTDEVO"}	)
	_nPosHr	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "TLW_HRDEVO"}	)
	_nPosQt	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "TLW_QTDEVO"}	)
	_nPosAr	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "TLW_LOCAL"}	)

	dbSelectArea("NNR")
	dbSetOrder(1)
	If dbSeek(xFilial("NNR") + oGet1:aCols[oGet1:nAt][_nPosAr])

		If TNF->TNF_I_TPDV == "T" .Or. TNF->TNF_I_TPDV == "R"
	
			aAdd( aDevEpi , TNF->(Recno()) )
		
			RecLock("TNF",.F.)
			If TNF->TNF_QTDENT == (TNF->TNF_QTDEVO + oGet1:aCols[oGet1:nAt][_nPosQt])
				TNF->TNF_INDDEV := "1"
				TNF->TNF_I_TPDV := "E"
			Else
			    TNF->TNF_I_TPDV := " " 
			EndIf
			TNF->TNF_DTDEVO := oGet1:aCols[oGet1:nAt][_nPosDt]
			TNF->TNF_QTDEVO	:= TNF->TNF_QTDEVO + oGet1:aCols[oGet1:nAt][_nPosQt]
			TNF->TNF_I_QTDD := 0 // Este campo deve ser zerado toda vez que as tabela TNF e TLW forem atualizadas.
			TNF->TNF_I_IMPR := "1"  // 1=Sim, deve ser impresso o recibo.
			TNF->(MsUnLock())
		
			dbSelectArea("TLW")
			dbSetOrder(1)
			If dbSeek(xFilial("TLW") + cFornecEn + cLojaSvEn + cEpiSvoEn + cNumCapEn + cMatricEn + ;
					DtoS(dDataSvEn) + cHoraSvEn ) // + DtoS(oGet1:aCols[oGet1:nAt][_nPosDt]) + oGet1:aCols[oGet1:nAt][_nPosHr] )
				RecLock("TLW",.F.)
			Else
				RecLock("TLW",.T.)
			Endif
		
			TLW->TLW_FILIAL := xFilial("TLW")
			TLW->TLW_FORNEC := cFornecEn
			TLW->TLW_LOJA   := cLojaSvEn
			TLW->TLW_CODEPI := cEpiSvoEn
			TLW->TLW_NUMCAP := cNumCapEn
			TLW->TLW_MAT    := cMatricEn
			TLW->TLW_DTENTR := dDataSvEn
			TLW->TLW_HRENTR := cHoraSvEn
			TLW->TLW_QTDEVO	:= oGet1:aCols[oGet1:nAt][_nPosQt]
			TLW->TLW_LOCAL	:= oGet1:aCols[oGet1:nAt][_nPosAr]
			TLW->TLW_DTDEVO	:= oGet1:aCols[oGet1:nAt][_nPosDt]
			TLW->TLW_HRDEVO	:= oGet1:aCols[oGet1:nAt][_nPosHr]
			TLW->TLW_TIPODV := "1" // Epi Devolvido  
			TLW->(MSUNLOCK())
						
			_cTmpLote	:= TNF->TNF_LOTECT
			_cTmpSubL	:= TNF->TNF_LOTESB
			_cTmpLocz	:= TNF->TNF_ENDLOC
			_cTmpNSer	:= TNF->TNF_NSERIE
			_cNUMSEQ	:= MdtMovEst("DE0", oGet1:aCols[oGet1:nAt][_nPosAr], cEpiSvoEn, oGet1:aCols[oGet1:nAt][_nPosQt], oGet1:aCols[oGet1:nAt][_nPosDt], " " , cMatricEn , nil ,;
								nil, TNF->TNF_NUMSEQ , _cTmpLote , _cTmpSubL , _cTmpLocz , _cTmpNSer )
			RecLock("TLW",.F.)
			TLW->TLW_NUMSEQ := _cNUMSEQ
			TLW->(MSUNLOCK())

			RecLock("SD3", .F.)
			SD3->D3_I_OBS := "RETORNO DE EPI DE REUSO SESMT."
			SD3->(MSUNLOCK())
			MsgInfo("O processo de devolu��o de EPI foi conlu�do com sucesso.", "AMDT00308 - Devolu��o de EPI")

		Else
			MsgAlert("Favor selecionar um EPI dispon�vel para Devolu��o.","AMDT00309 - Devolu��o de EPI")

		EndIf
	Else
		MsgStop("O armaz�m " + oGet1:aCols[oGet1:nAt][_nPosAr] + " n�o est� criado no sistema. Crie o armaz�m " + oGet1:aCols[oGet1:nAt][_nPosAr] + ", depois volte a executar esta rotina.","AMDT00310 - Devolu��o de EPI")

	EndIf
Else
	MsgStop("O processo de devolu��o de EPI foi cancelado pelo usu�rio.", "AMDT00311 - Devolu��o de EPI")
EndIf

RestArea(_aArea)
Return

/*
===============================================================================================================================
Programa----------: AMDTTOK
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 13/06/2016
===============================================================================================================================
Descri��o---------: Fun��o de valida��o da quantidade devolvida
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/                 //   1       2           3          4          5         6          7         8          9          10
User Function AMDTTOK(oGet1, nQtdadeEn, cMatricEn, cFornecEn, cLojaSvEn, cEpiSvoEn, cNumCapEn, dDataSvEn, cHoraSvEn,_nIQtdDev)
Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _nPosQtd	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "TLW_QTDEVO"	})

If oGet1:aCols[oGet1:nAt][_nPosQtd] > nQtdadeEn
	MsgAlert("A quantidade devolvida n�o pode ser maior que a quantidade entregue.","AMDT00312")
	_lRet := .F.
EndIf

If oGet1:aCols[oGet1:nAt][_nPosQtd] == 0
	MsgAlert("A quantidade devolvida tem que ser maior que 0(zero).","AMDT00313")
	_lRet := .F.
EndIf

DBSelectArea("TNF")
TNF->(DBSetOrder(1))
If TNF->(DBSeek(xFilial("TNF") + cFornecEn + cLojaSvEn + cEpiSvoEn + cNumCapEn + cMatricEn + DtoS(dDataSvEn) + cHoraSvEn))
	If oGet1:aCols[oGet1:nAt][_nPosQtd] > (TNF->TNF_QTDENT - TNF->TNF_QTDEVO)
		MsgStop('A quantidade a devolver deve ser menor ou igual ao saldo. Saldo: ' + AllTrim(Transform(TNF->TNF_QTDENT - TNF->TNF_QTDEVO,"@E 9,999,999.99")),"AMDT00314")
		_lRet := .F.
	EndIf
EndIf

If oGet1:aCols[oGet1:nAt][_nPosQtd] > _nIQtdDev
	MsgStop("A quantidade devolvida n�o pode ser maior que a quantidade de devolu��o informata na tela da rotina 'Dev.Almox.'."+;
	        "A quantidade dispon�vel para devolu��o est� visivel na parte superior da tela, no campo 'Qtd Devolvida', ao lado do campo 'Saldo'.","AMDT00315")
	_lRet := .F.
EndIf

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: AMD003E
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 16/06/2016
===============================================================================================================================
Descri��o---------: Fun��o para excluir a EPI do Monitor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AMD003E()
Local _aArea	:= GetArea()

If MsgYesNo("Deseja realmente confirmar a Devolu��o deste EPI?","AMDT00316")
	RecLock("TNF",.F.)
		TNF->TNF_I_TPDV := " "
	TNF->(MsUnLock())
	MsgInfo("O processo de exclu��o de EPI foi conlu�do com sucesso.","AMDT00317")
Else
	MsgAlert("Processo de exclus�o canelado pelo usu�rio.","AMDT00318")
EndIf

RestArea(_aArea)
Return

/*
===============================================================================================================================
Programa----------: AMD003F
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 19/09/2016
===============================================================================================================================
Descri��o---------: Fun��o para validar o descarte do EPI
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet - .T. continua com o descarte, .F. caso contr�rio
===============================================================================================================================
*/
User Function AMD003F()
Local _aArea	:= GetArea()
Local _lRet		:= .F.

Local _nPosForn
Local _nPosLoja
Local _nPosCodEPI
Local _nPosNumCap
Local _aOrd := SaveOrd({"TNF"})
Local _nRegAtu := TNF->(Recno())

If FUNNAME() == 'MDTA695'
	If MsgYesNo("Essa movimenta��o ser� de DESCARTE do EPI, deseja continuar?","AMDT00319")
		_lRet := .T.
		//============================================================================
		// TLW_FILIAL+TLW_FORNEC+TLW_LOJA+TLW_CODEPI+TLW_NUMCAP+TLW_MAT 
		//============================================================================
		_nPosForn   := aSCAN(aHeadPrin, {|x| AllTrim(Upper(X[2])) == "TNF_FORNEC" })
        _nPosLoja   := aSCAN(aHeadPrin, {|x| AllTrim(Upper(X[2])) == "TNF_LOJA" })
        _nPosCodEPI := aSCAN(aHeadPrin, {|x| AllTrim(Upper(X[2])) == "TNF_CODEPI" })
        _nPosNumCap := aSCAN(aHeadPrin, {|x| AllTrim(Upper(X[2])) == "TNF_NUMCAP" })
		
		TNF->(DbSetOrder(1)) // TNF_FILIAL+TNF_FORNEC+TNF_LOJA+TNF_CODEPI+TNF_NUMCAP+TNF_MAT+DTOS(TNF_DTENTR)+TNF_HRENTR
		If TNF->(DbSeek(xFilial("TNF")+aOldTNF[nSalTNF][_nPosForn]+aOldTNF[nSalTNF][_nPosLoja]+aOldTNF[nSalTNF][_nPosCodEPI]+aOldTNF[nSalTNF][_nPosNumCap]+M->RA_MAT))
		    Aadd(ADevEPI,TNF->(Recno()))
		EndIf
		
		RestOrd(_aOrd)
        TNF->(DbGoTo(_nRegAtu))
	EndIf
Else
	_lRet := .T.
EndIf
If IsInCallStack("U_AMD003D")
   aCols[n][5] := '1' // Ficou definido (Analista Andr� Carvalho) que o campo TLW_TIPODV (Repor Estoque) sempre ser� Sim='1', quando for a rotina AMD003D.
Else
   aCols[n][5] := '2' // Ficou definido (Analista Andr� Carvalho) que o campo TLW_TIPODV (Repor Estoque) sempre ser� N�o='2'.
EndIf

RestArea(_aArea)

Return(_lRet)


/*
===============================================================================================================================
Programa----------: AMD003V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/10/2017
===============================================================================================================================
Descri��o---------: Valida a digita��o da quantidade de devolu��o de EPI.
===============================================================================================================================
Parametros--------: _nSaldo = Saldo dispon�vel para devolu��o.
                    _nQtdADev = Quantidade a ser devolvida.
===============================================================================================================================
Retorno-----------: _lRet - .T. = Valida��o correta. /  .F. = foram encontrados problemas na valida��o.
===============================================================================================================================
*/
User Function AMD003V(_nSaldo,_nQtdADev)

Local _lRet := .T.

Begin Sequence
   If _nQtdADev <= 0
      MsgAlert("Informe uma quantidade de devolu��o maior que zero.","AMDT00320")
      _lRet := .F.
      Break
   EndIf
   
   If _nSaldo <_nQtdADev
      MsgAlert("A quantidade de devolu��o deve ser inferior ou igual ao saldo dispon�vel.","AMDT00321")
      _lRet := .F.
      Break
   EndIf

End Sequence

Return _lRet