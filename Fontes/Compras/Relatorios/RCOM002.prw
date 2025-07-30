/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da fun��o de conout
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada est�tica no nome das tabelas do sistema
===============================================================================================================================
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Altera��o
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remo��o de diret�rio local C:\SMARTCLIENT\.
Andre          - Alex Wallauer   - 09/06/2025 - 09/06/25 - 50934   - Ajuste no tratamento da descri��o do corpo do e-mail.
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FWPrintSetup.ch"

/*
===============================================================================================================================
Programa----------: RCOM002
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 04/02/2016
Descri��o---------: Rotina respons�vel por emitir pedido de compras em PDF por e-mail, apenas chama a rotina principal com
------------------: timer para que o usu�rio possa ver que o sistema est� rodando e n�o est� parado.
Parametros--------: _cAlias		- Alias da Tabela
------------------: _nRecno		- R_E_C_N_O_ do Registro Posicionado
------------------: _nOpc		- Op��o selecionada no menu aRotina
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM002()
PRIVATE _aArea:= SC7->(GetArea())//Private pq uso para restaurar o SC7 para imprimir o rodape
PRIVATE cPathSrv:=GETMV("MV_RELT")

//Grava log de utiliza��o
u_itlogacs()

If SC7->C7_CONAPRO == "L" .OR. IsInCallStack("U_RCOM006")
	FwMsgRun(,{|oProc| RCOM002E(oProc)},,"Aguarde, gerando arquivo PDF...")
Else
	u_itmsg("PC n�o autorizado para envio de e-mail ao Fornecedor. Pedido n�o liberado.","Pedido Inv�lido",,1)
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: RCOM002E
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 04/02/2016
Descri��o---------: Rotina respons�vel por emitir pedido de compras em PDF por e-mail
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM002E(oProc)
Local _aArea2  := GetArea()
Local _cNumPC  := SC7->C7_NUM  , nI
Local _aParRet :={}
Local _aParAux :={} 

Private _cFilial	:= SC7->C7_FILIAL
//Define fontes do Relatorio
Private oFont10		:= TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
Private oFont14		:= TFont():New("Arial",,14,,.T.,,,,,.F.,.F.)
Private oFont08		:= TFont():New("Arial",,08,,.F.,,,,,.F.,.F.)
Private oFont08N	:= TFont():New("Arial",,08,,.T.,,,,,.F.,.F.)

lImpObs := .F.                                                              
MV_PAR01:=SC7->C7_NUM
MV_PAR02:=SC7->C7_NUM

If IsInCallStack("U_RCOM006")
	lImpObs := .T.
	//Pode: BRANCO E BRANCO , PREENCHIDO E BRANCO , PREENCHIDO E PREENCHIDO
	
	AADD( _aParAux , { 1 , "No. PC de" , MV_PAR01, "@!"  , ""    , ""        , "" , 060 , .F. } )
	AADD( _aParAux , { 1 , "No. PC ate", MV_PAR02, "@!"  , ""    , ""        , "" , 060 , .F. } )
	
	For nI := 1 To Len( _aParAux )
		aAdd( _aParRet , _aParAux[nI][03] )
	Next nI
   DO WHILE .T.

      IF !ParamBox( _aParAux , "Sele��o de dados do Rela��o de Titulos CLAIMs" , @_aParRet ,)
         Return .T.
       EndIf

	   //Pode: BRANCO E BRANCO , PREENCHIDO E BRANCO , PREENCHIDO E PREENCHIDO
	   //N�O Pode: BRANCO E PREENCHIDO E O PRIMEIRO > SEGUNDO
	   IF  !EMPTY(MV_PAR02) .AND. (MV_PAR01 > MV_PAR02)
           U_ITMSG("Intervalo INVALIDO",'No. Titulo ' ,"Tente novamente com um Intervalo Valido",3)
           LOOP
       ELSEIF EMPTY(MV_PAR01) .AND. !EMPTY(MV_PAR02)
           U_ITMSG("Intervalo INVALIDO",'No. Titulo ' ,'Quando preencher campo "No. PC ate" obrigatoriamente deve se preencher o campo "No. PC de" ',3)
           LOOP
       ENDIF
       EXIT
   ENDDO

   IF EMPTY(MV_PAR01) .AND. EMPTY(MV_PAR02)
	  MV_PAR01:=SC7->C7_NUM
	  MV_PAR02:=SC7->C7_NUM
	  _cNumPC :=SC7->C7_NUM
   ENDIF	  

ELSEIF MsgYesNo("Deseja Imprimir OBSERVA��O para o FORNECEDOR ?")   
   lImpObs := .T.
EndIf  

cFileName := "pedido_compras_" + Lower(MV_PAR01) + "_" + _cFilial + ".pdf"

IF IsInCallStack("U_RCOM006")//cFilePrintert,[nDevice],lAdjustToLegacy, cPathInServer, lDisabeSetup,lTReport,@oPrintSetup,cPrinter],lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] 
	oPrint := FWMSPrinter():New( cFileName   , IMP_PDF , .F.           , cPathSrv     , .F.         ,        ,            ,         , .F.    , )
	If !(oPrint:nModalResult == PD_OK)
		oPrint:Deactivate() 
		Return
	EndIf
ENDIF

IF MV_PAR01 == MV_PAR02
	
   RCOM002Imp(oProc,MV_PAR01)
	
ELSE

	cQry := "SELECT DISTINCT C7_NUM  "
	cQry += "FROM " + RetSqlName("SC7") + " "
	cQry += "WHERE C7_FILIAL = '" + _cFilial + "' "
	IF !EMPTY(MV_PAR02)
		cQry += " AND C7_NUM BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	ELSEIF !EMPTY(MV_PAR01)
		cQry += " AND C7_NUM >= '" + MV_PAR01 + "'"
	ENDIF
	cQry += "  AND D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	_cAlias := GetNextAlias()
	MPSysOpenQuery( cQry , _cAlias )
	
	(_cAlias)->(dbGoTop())

	nConta:=0
	DO WHILE !(_cAlias)->(Eof())
		IF nConta >= 50
           U_ITMSG("Limite de Gera��o de PDF atingido: "+ALLTRIM(STR(nConta)),'Aten��o!',;
                    "Utilize / Limpe os PFDs ["+cPathSrv+"] gerados e entre novamente e continue o intervalo de onde parou",3)
		   EXIT
		ENDIF
		nConta++
		RCOM002Imp(oProc,(_cAlias)->C7_NUM)
		
		(_cAlias)->(DBSKIP())
		
	ENDDO
	
ENDIF

RestArea(_aArea2)

RETURN .T.
/*
===============================================================================================================================
Programa----------: RCOM002Imp
Autor-------------: Alex Wallauer
Data da Criacao---: 21/10/2019
Descri��o---------: Rotina respons�vel por emitir pedido de compras em PDF e/ou por e-mail
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM002Imp(oProc,_cNumPC)
Local _cAnexo		:= ""
Local _cEmail		:= ""
Local _cCc			:= ""
Local _cAssunto		:= ""
Local _cMens		:= ""
Local nLinIni		:= 10		// Linha Lateral (inicial) Esquerda
Local nColMax		:= 0835		// Para implementar layout A4
Local nCont			:= 0
Local nTotDesc		:= 0
Local nTotal		:= 0
Local nTotMerc		:= 0
Local nTotIpi		:= 0
Local nTotIcms		:= 0
Local nTotDesp		:= 0
Local nTotFrete		:= 0
Local nTotSeguro	:= 0
Local aValIVA		:= {}
Local cFiltro		:= ""
Local cFrete		:= ""
Local cCodTra		:= ""
Local cLojTra		:= ""
Local cTpFrt		:= ""
Local cNReduz		:= ""
Local cCidUni		:= ""
Local cNomUsr		:= ""
Local lPagina		:= .T.
Local dEmissao		:= CtoD("//")
Local cCompra		:= ""
Local cCond			:= ""
Local cMailCom		:= ""
Local cDescPro      := ""           
Local cObs          := ""
Local cObsAp		:= ""
Local nConta 		:= 0
Local _nBASEICM  	:= 0
Local _nALIQICM  	:= 0
Local _nVALORICMS	:= 0
Local _nVALORIPI 	:= 0
Local _bGetUsr		:= {|x| UsrFullName(x)}
Local _cUser		:= RetCodUsr()

Private oPrint		:= Nil
Private nLinAux		:= 0
Private nColIni		:= 10		// Coluna Lateral (inicial) Esquerda
Private ltemmil		:= .F.

cFileName := "pedido_compras_" + Lower(_cNumPC) + "_" + _cFilial + ".pdf"
//==========================
// Cria Arquivo do Relatorio
//==========================
oPrint := FWMSPrinter():New( cFileName   , IMP_PDF , .F.           , cPathSrv     , .T.         ,        ,            ,         , .T. )

//=====================================
// Configura modo Paisagem de Impressao
//=====================================
oPrint:SetLandscape()

//=============================
// Define impressao em papel A4
//=============================
oPrint:SetPaperSize(9)
oPrint:SetMargin(0,0,0,0)	// nEsquerda, nSuperior, nDireita, nInferior
	
//=========================================================
// Se enviar por e-mail nao abre o arquivo apos a impressao
//=========================================================
oPrint:SetViewPDF(.F.)
oPrint:cPathPDF := cPathSrv	// Caso seja utilizada impress�o em IMP_PDF

oPrint:StartPage()

//==================================
// Chama fun��o para desenhar o grid
//==================================
RCOM002G()

MaFisEnd()
R002FIniPC(_cNumPC,,,cFiltro,_cFilial,oProc)

dbSelectArea("SC7")
SC7->(dbSetOrder(1))
SC7->(dbSeek(_cFilial + _cNumPC))

ltemmil		:= .F. //zera flag de produto grupo 1000-servicos

DO While !SC7->(Eof()) .And. SC7->C7_FILIAL == _cFilial .And. SC7->C7_NUM == _cNumPC

	If posicione("SB1",1,xfilial("SB1")+SC7->C7_PRODUTO,'B1_GRUPO') == '1000' .and. SC7->C7_FILIAL = '01'
		ltemmil := .T.
	Endif
	
	oProc:cCaption := ("2-Lendo Item: "+SC7->C7_PRODUTO)
	ProcessMessages()
	
	If SC7->C7_RESIDUO <> "S"

	   nConta ++

		nLinIni	:= 005
		nColIni	:= 000
		nCont++
		
		If nLinAux > (nLinIni+590)
			lPagina := .T.
			oPrint:EndPage()
			oPrint:StartPage()
			RCOM002G()
			
			nLinIni	:= 005
			nColIni	:= 000
			nCont++
		EndIf
		
		If nCont = 1 .Or. lPagina

           lPagina := .F.			
		   RCOM002Cab(_cNumPC,_cFilial,nLinIni,nColIni)
			
			If nCont == 1
				cFrete		:= SC7->C7_TPFRETE
				cObsAp		:= AllTrim(SC7->C7_I_OBSAP)
				cCodTra		:= SC7->C7_I_CDTRA
				cLojTra		:= SC7->C7_I_LJTRA
				cTpFrt		:= SC7->C7_I_TPFRT
				_cEmail		:= Posicione("SA2",1,xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, "A2_EMAIL")
				cNReduz		:= Posicione("SA2",1,xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, "A2_NREDUZ")
				cCidUni		:= SubStr(AllTrim(SM0->M0_CIDCOB),1,50)
				dEmissao	:= SC7->C7_EMISSAO
				cCompra		:= SubStr(Eval(_bGetUsr,SC7->C7_USER), 1, At(" ", Eval(_bGetUsr,SC7->C7_USER))-1)
				cNomUsr		:= AllTrim(Eval(_bGetUsr,SC7->C7_USER))
				cCond		:= AllTrim(Posicione("SE4",1,xFilial("SE4") + SC7->C7_COND,"E4_DESCRI"))
				If _cUser == SC7->C7_USER
				   cMailCom:= AllTrim(UsrRetMail(SC7->C7_USER))
				Else
				   cMailCom:= AllTrim(UsrRetMail(SC7->C7_USER)) + "," + AllTrim(UsrRetMail(_cUser))
				EndIf
			EndIf
			
		EndIf

  		If lImpObs
			cObs += Alltrim(SC7->C7_OBS)+" "
		Else
			cObs := ""
		EndIf  
		
		oPrint:Say( (nLinAux) , (nColIni+020) , SC7->C7_ITEM				, oFont08 )
		oPrint:Say( (nLinAux) , (nColIni+045) , SC7->C7_PRODUTO				, oFont08 )
		
		If AllTrim(SC7->C7_I_DESCD) $ AllTrim(SC7->C7_DESCRI)
			cDescPro := SubStr(AllTrim(SC7->C7_DESCRI),1,70)
		Else
			cDescPro := AllTrim(SC7->C7_DESCRI) + " " + AllTrim(SC7->C7_I_DESCD)
		EndIf
		
		oPrint:Say( (nLinAux) , (nColIni+400) , SC7->C7_UM					, oFont08 )
		
		oPrint:SayAlign( (nLinAux-8),(nColIni+435),Transform(SC7->C7_QUANT, PesqPict("SC7","C7_QUANT"))		,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		
		_cValor:=MCOM002Totais(SC7->C7_MOEDA,0,SC7->C7_PRECO,.F.)
		oPrint:SayAlign( (nLinAux-8),(nColIni+495),_cValor			,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		//	oPrint:SayAlign( (nLinAux-8),(nColIni+495),Transform(SC7->C7_PRECO, "@E 999,999,999.99999")			,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		_cValor:=MCOM002Totais(SC7->C7_MOEDA,0,SC7->C7_VLDESC,.F.)
		oPrint:SayAlign( (nLinAux-8),(nColIni+545),_cValor	,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		//	oPrint:SayAlign( (nLinAux-8),(nColIni+545),Transform(SC7->C7_VLDESC, PesqPict("SC7","C7_VLDESC"))	,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		_cValor:=MCOM002Totais(SC7->C7_MOEDA,0,SC7->C7_TOTAL,.F.)
		oPrint:SayAlign( (nLinAux-8),(nColIni+595),_cValor		,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		//	oPrint:SayAlign( (nLinAux-8),(nColIni+595),Transform(SC7->C7_TOTAL, PesqPict("SC7","C7_TOTAL"))		,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		_cValor:=MCOM002Totais(SC7->C7_MOEDA,0,SC7->C7_VALIPI,.F.)
		oPrint:SayAlign( (nLinAux-8),(nColIni+645),_cValor	,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		//	oPrint:SayAlign( (nLinAux-8),(nColIni+645),Transform(SC7->C7_VALIPI, PesqPict("SC7","C7_VALIPI"))	,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		_cValor:=MCOM002Totais(SC7->C7_MOEDA,0,SC7->C7_ICMSRET,.F.)
		oPrint:SayAlign( (nLinAux-8),(nColIni+695),_cValor	,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		//	oPrint:SayAlign( (nLinAux-8),(nColIni+695),Transform(SC7->C7_ICMSRET, PesqPict("SC7","C7_ICMSRET"))	,oFont08, 55, 14, CLR_BLACK, 1, 0 )
		
		oPrint:Say( (nLinAux) , (nColIni+770) , DtoC(SC7->C7_DATPRF)	, oFont08 )
		
		If (Len(Alltrim(cDescPro))) > 70
			RCOM002A(cDescPro)//Descricao do produto
		Else
			oPrint:Say( (nLinAux) , (nColIni+100) , AllTrim(cDescPro), oFont08 )
		EndIf

		nLinAux := nLinAux + 010
		
		nTotDesc	+= SC7->C7_VLDESC
		
		nTotal		:= nTotal + SC7->C7_TOTAL
		
	   nTotMerc	   := MaFisRet(,'NF_TOTAL')
	   //nTotIpi   := MaFisRet(,'NF_VALIPI')
	   _nVALORIPI  := MaFisRet(nConta,"IT_VALIPI")
	   _nVALORICMS := MaFisRet(nConta,"IT_VALICM")
	   IF SB1->(dbSeek( xFilial("SB1")+SC7->C7_PRODUTO)) 
	   	  IF SB1->B1_TIPO = "SV"
	   	  	 nTotIpi += 0
	   	  	 nTotIcms+= 0

	   		 MaFisLoad("IT_VALIPI",0,nConta)
	   		 MaFisLoad("IT_VALICM",0,nConta)
	   	  ELSEIF !SB1->B1_TIPO $ "IN/EM/PA" .AND. _nVALORIPI <> 0
	           
	   		_nBASEICM  := MaFisRet(nConta,"IT_BASEICM")
	   		_nALIQICM  := MaFisRet(nConta,"IT_ALIQICM")	   		
	   		_nVALORICMS:= ROUND((_nVALORIPI+_nBASEICM)*(_nALIQICM/100),2)
   
	   		nTotIpi    += _nVALORIPI 
	   		nTotIcms   += _nVALORICMS 
	           
	   		MaFisLoad("IT_BASEICM",(_nVALORIPI+_nBASEICM),nConta)
	   		MaFisLoad("IT_VALICM" ,_nVALORICMS,nConta)

	   	  ELSE
	   	  	nTotIpi    += _nVALORIPI
	   	  	nTotIcms   += _nVALORICMS
	   	  ENDIF
	   ELSE
	   	  nTotIcms	:= MaFisRet(,'NF_VALICM')
	   	  nTotDesp	:= MaFisRet(,'NF_DESPESA')
	   ENDIF
	   nTotFrete	:= MaFisRet(,'NF_FRETE')
	   nTotSeguro	:= MaFisRet(,'NF_SEGURO')
	   aValIVA		:= MaFisRet(,"NF_VALIMP")
	EndIf

	SC7->(dbSkip())

ENDDO

SC7->(dbSeek(_cFilial + _cNumPC))//volta para o PC 
nTam:=185
IF !EMPTY(cObs)
	oPrint:Say((nLinAux),(nColIni+020),"OBSERVA��ES DOS ITENS:" ,oFont08N)
    nLinAux+= 10
ENDIF   
DO While !EMPTY(cObs) .AND. !SC7->(Eof()) .And. SC7->C7_FILIAL == _cFilial .And. SC7->C7_NUM == _cNumPC
	
	oProc:cCaption := ("2-Lendo Item: "+SC7->C7_PRODUTO)
	ProcessMessages()
	
	If SC7->C7_RESIDUO <> "S"

		nLinIni	:= 005
		nColIni	:= 000
		nCont++
		
		If nLinAux > (nLinIni+590)
			lPagina := .T.
			oPrint:EndPage()
			oPrint:StartPage()
			RCOM002G()
			
			nLinIni	:= 005
			nColIni	:= 000
			nCont++
		EndIf
		
		If nCont = 1 .Or. lPagina
           lPagina := .F.			
		   RCOM002Cab(_cNumPC,_cFilial,nLinIni,nColIni)
		EndIf
		
        IF !EMPTY(SC7->C7_OBS)
		   oPrint:Say((nLinAux),(nColIni+020),SC7->C7_ITEM,oFont08 )
		   IF LEN(ALLTRIM(SC7->C7_OBS)) > nTam
	          oPrint:Say((nLinAux),(nColIni+045),+MEMOLINE(ALLTRIM(SC7->C7_OBS),nTam,1),oFont08)
	          nLinAux+= 10
	          oPrint:Say((nLinAux),(nColIni+045),+MEMOLINE(ALLTRIM(SC7->C7_OBS),nTam,2),oFont08)
	       ELSE
	          oPrint:Say((nLinAux),(nColIni+045),+ALLTRIM(SC7->C7_OBS),oFont08)
	       ENDIF
	       nLinAux+= 10
	    ENDIF   
		
	EndIf

	SC7->(dbSkip())

ENDDO
SC7->(dbSeek(_cFilial + _cNumPC))//volta para o PC 


oProc:cCaption := ("3-Imprimindo Dados...")
ProcessMessages()

If nLinAux > (nLinIni+472)
	lPagina := .T.
	oPrint:EndPage()
	oPrint:StartPage()
	RCOM002G()

    RCOM002Cab(_cNumPC,_cFilial,nLinIni,nColIni)

	//=======================================
	// Chama fun��o para impress�o dos totais
	//=======================================
	RCOM002T(nColMax, nLinIni, nColIni, cTpFrt, cFrete, cObsAp, cCodTra, cLojTra, nTotal, nTotMerc, nTotDesc, nTotIpi, nTotFrete, nTotIcms, nTotDesp, nTotSeguro, dEmissao, cCompra, cCond, cObs,oProc)
Else
	//=======================================
	// Chama fun��o para impress�o dos totais
	//=======================================
	RCOM002T(nColMax, nLinIni, nColIni, cTpFrt, cFrete, cObsAp, cCodTra, cLojTra, nTotal, nTotMerc, nTotDesc, nTotIpi, nTotFrete, nTotIcms, nTotDesp, nTotSeguro, dEmissao, cCompra, cCond, cObs,oProc)
EndIf

PRIVATe	_cOrigem :=oPrint:cPathPDF+cFileName

oProc:cCaption := ("5-Gravando PDF: "+_cOrigem)
ProcessMessages()

oPrint:EndPage()

IF IsInCallStack("U_RCOM006")
   oPrint:lViewPDF := .F.
ELSE
   oPrint:lViewPDF := .F.
ENDIF   

LjMsgRun( "Gravando PDF: "+_cOrigem , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir

FreeObj(oPrint)

IF !IsInCallStack("U_RCOM006")

    _cAnexo1  :=_cOrigem
	If FILE(_cOrigem) 
	   _cDestino:=ALLTRIM(GETMV("MV_RELT",,"\SPOOL\"))
	   IF !_cDestino $ _cOrigem//sEN�O Esta no \SPOOL\ sen�o deixa
	      CPYT2S(_cOrigem,_cDestino,.F.) // Terminal To Server
	   ENDIF
	   _cAnexo1  :=_cDestino+cFileName
	ENDIF
    _cAnexo:=_cAnexo1+";\workflow\htm\aviso_importante.pdf"
	
	_cAssunto := "PC - " + _cNumPC + " - " + SubStr(AllTrim(SM0->M0_CIDCOB),1,50) + " - " + AllTrim(SM0->M0_ESTCOB) + ":" + cNReduz + Space(30)
	
	//=================================
	// Chama a fun��o da tela de E-mail
	//=================================
	RCOM002M(_cAnexo,@_cEmail,@_cCc,@_cAssunto,@_cMens,cMailCom,cNReduz,_cFilial,_cNumPC,cCidUni,cNomUsr)

    RCOM002D(cPathSrv +cFileName)
    RCOM002D(_cAnexo1)

ELSE

	cGetAnx := cPathSrv +cFileName///spool
	_cPathLocal:=GetTempPath()
	If File(cGetAnx)
		//Copia arquivo da spool para esta��o local
		IF !CpyS2T(cGetAnx,_cPathLocal)
			U_ITMSG("N�o foi possivel copiar o arquivo "+cGetAnx+" para "+_cPathLocal,'Aten��o!',"Feche o arquivo "+cGetAnx+", caso aberto,e tente novamente",1)
		ELSE

            _cOrigem2:=StrTran( _cOrigem, cPathSrv,_cPathLocal ) 
	        
	        ShellExecute("open", _cOrigem2, "", _cPathLocal, 1) 

   	        U_ITMSG("O arquivo  "+UPPER(cFileName)+"  foi gerado na PASTA: "+CHR(13)+CHR(10)+_cPathLocal,'Aten��o!',,2)

		ENDIF

	ELSE	
	    U_ITMSG("N�o foi possivel copiar o arquivo "+cGetAnx+" para "+_cPathLocal,'Aten��o!',"Arquivo "+cGetAnx+" n�o existe.",1)
	EndIf

ENDIF

Return

/*
===============================================================================================================================
Programa----------: RCOM002G
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 04/02/2016
Descri��o---------: Rotina respons�vel por criar o layout de impress�o
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM002G()
Local nLinIni		:= 0		// Linha Lateral (inicial) Esquerda
Local nColIni		:= 0		// Coluna Lateral (inicial) Esquerda
Local nLinMax		:= 0600		// Para implementar layout A4
Local nColMax		:= 0835		// Para implementar layout A4
Local cPathImg		:= GetSrvProfString("Startpath","")
Local cFileImg		:= ""

nLinIni	:= 005
nColIni	:= 000

cFileImg := cPathImg + "logoboleto.BMP"

//==============
// Box Principal
//==============
oPrint:Box( nLinIni + 008, nColIni + 010, nLinMax, nColMax, "-4")

//=========
// Logotipo
//=========
_nLinLogo:=nLinIni+9
oPrint:SayBitmap( _nLinLogo , nColIni + 018 , cFileImg , 170 , 058 )
//oPrint:SayBitmap( nLinIni + 010 , nColIni + 018 , cFileImg ,  100 , 020)//170 , 058 )

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 145 , nColIni + 010 , nLinIni + 145 , nColMax	)

//===============
// Linha Vertical
//===============
oPrint:Line( nLinIni + 008 , nColIni + 200 , nLinIni + 145 , nColIni + 200	)

//===============
// Linha Vertical
//===============
oPrint:Line( nLinIni + 008 , nColIni + 650 , nLinIni + 145 , nColIni + 650	)

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 050 , nColIni + 200 , nLinIni + 050 , nColIni + 650	)

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 165 , nColIni + 010 , nLinIni + 165 , nColMax	)

Return

/*
===============================================================================================================================
Programa----------: RCOM002T
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 04/02/2016
Descri��o---------: Fun��o respons�vel pela impress�o dos totais e seu layout
Parametros--------: _cAnexo		- Endere�o do arquivo do Pedido de Compras em PDF
------------------: _cEmail		- Endere�o de E-mail para qual ser� enviado o Pedido de Compras
------------------: _cCc		- Endere�o de E-mail que est� no campo Com C�pia
------------------: _cAssunto	- Assunto do E-mail
------------------: _cMens		- Mensagem de texto para o corpo do E-mail
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM002T(nColMax, nLinIni, nColIni, cTpFrt, cFrete, cObsAp, cCodTra, cLojTra, nTotal, nTotMerc, nTotDesc, nTotIpi, nTotFrete, nTotIcms, nTotDesp, nTotSeguro, dEmissao, cCompra, cCond, cObs,oProc)
Local cTpFrete	:= ""
Local nLinMax	:= 0600		// Para implementar layout A4

oProc:cCaption := ("4-Imprimindo totais...")
ProcessMessages()

oPrint:Say( (nLinIni+490) , (nColIni+020) , "Condi��o de Pagamento: "													, oFont08 )
oPrint:Say( (nLinIni+499) , (nColIni+020) , cCond																		, oFont08 )

IF SC7->C7_MOEDA <> 1
	oPrint:Say( (nLinIni+511) , (nColIni+020) ,"Valores do Pedido em : "+UPPER(ALLTRIM(GETMV("MV_MOEDA"+ALLTRIM(STR(SC7->C7_MOEDA))))), oFont08 )
	oPrint:Say( (nLinIni+520) , (nColIni+020) ,"Data da Taxa : "+DTOC(SC7->C7_EMISSAO)										, oFont08 )
	oPrint:Say( (nLinIni+529) , (nColIni+020) ,"Taxa : "+ALLTRIM(Transform(SC7->C7_TXMOEDA,PesqPict("SC7","C7_TXMOEDA"))), oFont08 )
ENDIF

oPrint:Say( (nLinIni+490) , (nColIni+180) , "Comprador:"																, oFont08 )
oPrint:Say( (nLinIni+499) , (nColIni+180) , cCompra																		, oFont08 )
oPrint:Say( (nLinIni+490) , (nColIni+300) , "Data de Emiss�o:"															, oFont08 )
oPrint:Say( (nLinIni+499) , (nColIni+300) , DtoC(dEmissao)																, oFont08 )

oPrint:Say( (nLinIni+490) , (nColIni+440) , "Total das Mercadorias:"													, oFont08 )
oPrint:Say( (nLinIni+500) , (nColIni+440) , "Total com Impostos:"														, oFont08 )
oPrint:Say( (nLinIni+510) , (nColIni+440) , "Total de Descontos:"														, oFont08 )

oPrint:Say( (nLinIni+520) , (nColIni+440) , "IPI:"																		, oFont08 )
oPrint:Say( (nLinIni+530) , (nColIni+440) , "Frete:"																	, oFont08 )

oPrint:Say( (nLinIni+540) , (nColIni+440) , "ICMS:"																		, oFont08 )
oPrint:Say( (nLinIni+550) , (nColIni+440) , "Despesas:"																	, oFont08 )
oPrint:Say( (nLinIni+560) , (nColIni+440) , "Seguro:"																	, oFont08 )

oPrint:Say( (nLinIni+580) , (nColIni+550) , "Total Geral:"																, oFont10 )

oPrint:Say( (nLinIni+540) , (nColIni+020) , "Transportadora:"															, oFont08 )

If cFrete == "C"
	cTpFrete := "CIF"
ElseIf cFrete == "F"
	cTpFrete := "FOB"
ElseIf cFrete == "T"
	cTpFrete := "TERCEIROS"
ElseIf cFrete == "S"
	cTpFrete := "SEM FRETE"
EndIf

oPrint:Say( (nLinIni+530) , (nColIni+520) , cTpFrete , oFont08 )

If !Empty(cCodTra) .And. !Empty(cLojTra)

	oPrint:Say( (nLinIni+540) , (nColIni+080) , "C�digo: " + cCodTra + " Loja: " + cLojTra , oFont08 )
	oPrint:Say( (nLinIni+550) , (nColIni+020) , "Raz�o Social: " + AllTrim(SubStr(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra,"A2_NOME"),1,30)) , oFont08 )
	oPrint:Say( (nLinIni+560) , (nColIni+020) , "Nome Fantasia: " + AllTrim(SubStr(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_NREDUZ"),1,30)) , oFont08 )
	oPrint:Say( (nLinIni+570) , (nColIni+020) , "CNPJ: " + Transform(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_CGC"), PesqPict("SA2","A2_CGC")) , oFont08 )
	oPrint:Say( (nLinIni+580) , (nColIni+020) , "Ins. Estad.: " + Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_INSCR") , oFont08 )

	oPrint:Say( (nLinIni+540) , (nColIni+275) , "Bairro: " + AllTrim(SubStr(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_BAIRRO"),1,25)) , oFont08 )
	oPrint:Say( (nLinIni+550) , (nColIni+275) , "Cidade: " + AllTrim(SubStr(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_MUN"),1,30)) + " - " + "Estado: " + Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_EST") , oFont08 )
	oPrint:Say( (nLinIni+560) , (nColIni+275) , "Telefone: (" + AllTrim(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_DDD")) + ")" + SubStr(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_TEL"),1,4) + "-" + SubStr(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_TEL"),5,4) , oFont08 )
	oPrint:Say( (nLinIni+570) , (nColIni+275) , "Contato: " + AllTrim(Posicione("SA2", 1, xFilial("SA2")+cCodTra+cLojTra, "A2_CONTATO")) , oFont08 )
	oPrint:Say( (nLinIni+580) , (nColIni+275) , "Obs. Frete: " + If(cTpFrt == "1","Entregar na Transportadora","Solicitar Coleta pela Transportadora" ) , oFont08 )

EndIf

RestArea(_aArea)//volta SC7 de quando entro no programa
nLarg:=99
nCol1:=730
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotal,.F.)
oPrint:SayAlign( (nLinIni+482),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotal+nTotIpi,.F.)
oPrint:SayAlign( (nLinIni+492),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotDesc,.F.)
oPrint:SayAlign( (nLinIni+502),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotIpi,.F.)
oPrint:SayAlign( (nLinIni+512),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotFrete,.F.)
oPrint:SayAlign( (nLinIni+522),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotIcms,.F.)
oPrint:SayAlign( (nLinIni+532),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotDesp,.F.)
oPrint:SayAlign( (nLinIni+542),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,nTotSeguro,.F.)
oPrint:SayAlign( (nLinIni+552),(nColIni+nCol1),_cTotais,oFont08, nLarg, 14, CLR_BLACK, 1, 0 )
_cTotais:=MCOM002Totais(SC7->C7_MOEDA,SC7->C7_TXMOEDA,(nTotMerc),.F.)
oPrint:SayAlign( (nLinIni+572),(nColIni+700),_cTotais,oFont10, 99, 16, CLR_BLACK, 1, 0 ) 

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 482 , nColIni + 010 , nLinIni + 482 , nColMax	)

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 532 , nColIni + 010 , nLinIni + 532 , nColMax	)

//===============
// Linha Vertical
//===============
oPrint:Line( nLinIni + 482 , nColIni + 438 , nLinMax , nColIni + 438	)

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 492 , nColIni + 438 , nLinIni + 492 , nColMax	)

//=================
// Linha Horizontal
//=================
IF SC7->C7_MOEDA <> 1
   oPrint:Line( nLinIni + 502 , nColIni + 010 , nLinIni + 502 , nColMax	)
ELSE
   oPrint:Line( nLinIni + 502 , nColIni + 438 , nLinIni + 502 , nColMax	)
ENDIF

//===============
// Linha Vertical
//===============
oPrint:Line( nLinIni + 482 , nColIni + 175 , nLinIni + 532 , nColIni + 175	)

//===============
// Linha Vertical
//===============
oPrint:Line( nLinIni + 482 , nColIni + 295 , nLinIni + 532 , nColIni + 295	)

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 512 , nColIni + 438 , nLinIni + 512 , nColMax	)//438

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 522 , nColIni + 438 , nLinIni + 522 , nColMax	)//438

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 542 , nColIni + 438 , nLinIni + 542 , nColMax	)

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 552 , nColIni + 438 , nLinIni + 552 , nColMax	)

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni + 562 , nColIni + 438 , nLinIni + 562 , nColMax	)

//===============
// Linha Vertical
//===============
oPrint:Line( nLinIni + 482 , nColIni + 660 , nLinIni + 562 , nColIni + 660	)

Return

/*
===============================================================================================================================
Programa----------: RCOM002M
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 04/02/2016
Descri��o---------: Fun��o respons�vel por exibir a janela para a digita��o dos endere�os de email, assunto, mensagem
Parametros--------: _cAnexo		- Endere�o do arquivo do Pedido de Compras em PDF
------------------: _cEmail		- Endere�o de E-mail para qual ser� enviado o Pedido de Compras
------------------: _cCc		- Endere�o de E-mail que est� no campo Com C�pia
------------------: _cAssunto	- Assunto do E-mail
------------------: _cMens		- Mensagem de texto para o corpo do E-mail
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM002M(_cAnexo,_cEmail,_cCc,_cAssunto,_cMens,cMailCom,cNReduz,_cFilial,_cNumPC,cCidUni,cNomUsr)
Local oAnexo
Local oAssunto
Local oButCan
Local oButEnv
Local oCc
Local oGetAnx
Local oGetAssun
Local oGetCc
//Local oGetMens
Local oGetPara
Local oMens
Local oPara
//Local oMemo
Local _csetor := ""

Local _aConfig	:= U_ITCFGEML('')
Local _cEmlLog	:= ""
Local cHtml		:= ""
Local nOpcA		:= 2

Local cGetAnx	:= _cAnexo
Local cGetAssun	:= _cAssunto
Local cGetCc	:= Space(100)
//Local cGetMens	:= ""
Local cGetPara	:= _cEmail + Space(80)

Private oDlgMail


If (Len(PswRet()) # 0) // Quando nao for rotina automatica do configurador

	_csetor	:= AllTrim(PswRet()[1][12])		// Pega departamento do usuario
   
Endif


If empty(alltrim(_csetor))
 
 	_csetor := "Suprimentos"
 	
Endif

cHtml := '� '+ cNReduz +','
cHtml += '<br><br>'
cHtml += '&nbsp;&nbsp;&nbsp;Segue anexo Pedido de Compra PC-' + _cNumPC + ' para nossa Unidade Industrial '+ cCidUni +' conforme negociado.<br>'
cHtml += '&nbsp;&nbsp;&nbsp;Favor confirmar o recebimento, retornando com o seu CIENTE!'
cHtml += '<br><br>'
cHtml += '<font color="#FF0000"><b><u>OBSERVA��ES IMPORTANTES:</u></b><br><br></font>'
cHtml += '<font color="#FF0000"><b>1)</b>� obrigat�ria a inclus�o das informa��es do <b>pedido de compra</b> na estrutura do XML (arquivo da nota fiscal eletr�nica), nos campos: (i) Tag e (ii) Tag , bem como no campo de dados adicionais.;</font>'
cHtml += '<br><br>'
cHtml += '<font color="#FF0000"><b>2)</b> � obrigat�rio anexar a Nota Fiscal ao <b>Boleto Banc�rio</b> de Pagamento;</font>'
cHtml += '<br><br>'
cHtml += '<font color="#FF0000"><b>3)</b> Ao emitir a <b>NFe</b>(Nota Fiscal Eletr�nica) para o pedido <b>� obrigat�rio</b> o envio do <b>arquivo XML da NFe</b> para o e-mail: </font>'
cHtml += '<b><a href="mailto:nfe@italac.com.br">nfe@italac.com.br</a> - ESTA OBRIGA��O FISCAL FICA SOB PENA DO N�O RECEBIMENTO DA MERCADORIA AT� O SEU CUMPRIMENTO!</b>'
cHtml += '<br><br>'
cHtml += '<font color="#FF0000"><b>4)</b> A Italac <b>n�o autoriza</b> os descontos do(s) t�tulo(s) gerados em nossa opera��o comercial, oportunidade em que estes '
cHtml += 'n�o devem ser oferecidos a cess�o/descontos/negocia��es perante qualquer terceiro, sejam eles institui��o financeiras/factoring ou n�o. '
cHtml += 'Fica ressalvado ainda que, na ocorr�ncia da indevida cess�o/descontos/negocia��o dos mesmos, estes ter�o sua recusa formalizada.</font>'
cHtml += '<br><br>'
 
//Se tem produto grupo 1000 adiciona mensagem de reten��o de iss
If ltemmil		

	cHtml += '<font color="#FF0000"><b>5)</b> � obrigat�rio informar nos documentos que <b>o local da reten��o/incid�ncia do ISSQN</b> dar-se-� no Munic�pio de Corumba�ba-GO, a al�quota '
	cHtml += 'a ser aplicada de 3,00%. Em ato cont�nuo, iremos promover as referidas reten��es, direcionando estes recolhimentos aos cofres do referido Munic�pio. Os fornecedores'
	cHtml += 'optantes pelo regime Simples Nacional dever�o informar no pr�prio documento fiscal o percentual de ISS para a faixa de receita bruta que estiver sujeito'
	cHtml += 'no m�s anterior ao da presta��o, para nossa reten��o do percentual correspondente. Caso n�o informado ser� aplicado a al�quota local de 3,00%</font>'
	cHtml += '<br><br>'

EndIf

cHtml += '&nbsp;&nbsp;&nbsp;A disposi��o!'
cHtml += '<br><br>'


cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml += '<tr>'
cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=         '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<b><span style="font-size:18.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">'+ Capital( AllTrim( UsrFullName( RetCodUsr() ) ) ) +'</span></b>'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=     '</td>'
cHtml +=     '<td style="background:#A2CFF0;padding:.75pt .75pt .75pt .75pt">&nbsp;</td>'
cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">
cHtml +=         '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml +=              '<tr>'
cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=                      '<p class=MsoNormal><b><span style="font-size:13.5pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#6FB4E3;mso-fareast-language:PT-BR">' + _cSetor + '</span></b>'
cHtml +=                      '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></b>
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"><br></span>
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=                  '</td>'
cHtml +=              '</tr>'
cHtml +=              '<tr>'
cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">
cHtml +=                      '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Tel: ' + Posicione("SY1",3,xFilial("SY1") + RetCodUsr(),"Y1_TEL") + '</span>'
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=                  '</td>'
cHtml +=              '</tr>'
cHtml +=         '</table>'
cHtml +=     '</td>'
cHtml += '</tr>'
cHtml += '</table>'
cHtml += '<table class=MsoNormalTable border=0 cellpadding=0 width=437 style="width:327.75pt">'
cHtml +=     '<tr>'
cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR">'
cHtml +=                 '<img width=400 height=51 src="http://www.italac.com.br/assinatura-italac/images/marcas-goiasminas-industria-de-laticinios-ltda.jpg">'
cHtml +=             '</span>
cHtml +=             '</p>'
cHtml +=         '</td>'
cHtml +=     '</tr>'
cHtml += '</table>'
cHtml += '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';display:none;mso-fareast-language:PT-BR">&nbsp;</span></p>'
cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml +=     '<tr>'
cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Pol�tica de Privacidade </span></b>'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=             '<p class=MsoNormal style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto;text-align:justify">'
cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">
cHtml +=                 'Esta mensagem � destinada exclusivamente para fins profissionais, para a(s) pessoa(s) a quem for dirigida, podendo conter informa��o confidencial e legalmente privilegiada. '
cHtml +=                 'Ao receb�-la, se voc� n�o for destinat�rio desta mensagem, fica automaticamente notificado de abster-se a divulgar, copiar, distribuir, examinar ou, de qualquer forma, utilizar '
cHtml +=                 'sua informa��o, por configurar ato ilegal. Caso voc� tenha recebido esta mensagem indevidamente, solicitamos que nos retorne este e-mail, promovendo, concomitantemente sua '
cHtml +=                 'elimina��o de sua base de dados, registros ou qualquer outro sistema de controle. Fica desprovida de efic�cia e validade a mensagem que contiver v�nculos obrigacionais, expedida '
cHtml +=                 'por quem n�o detenha poderes de representa��o, bem como n�o esteja legalmente habilitado para utilizar o referido endere�o eletr�nico, configurando falta grave conforme nossa '
cHtml +=                 'pol�tica de privacidade corporativa. As informa��es nela contidas s�o de propriedade da Italac, podendo ser divulgadas apenas a quem de direito e devidamente reconhecido pela empresa.'
cHtml += '<BR>Ambiente: ['+ GETENVSERVER() +'] / Fonte: [ROCOM002] </BR>'
cHtml +=             '</span>'
cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>'
cHtml +=         '</td>'
cHtml +=     '</tr>
cHtml += '</table>'

DEFINE MSDIALOG oDlgMail TITLE "E-Mail" FROM 000, 000  TO 415, 584 COLORS 0, 16777215 PIXEL

	//======
	// Para:
	//======
	@ 005, 006 SAY oPara PROMPT "Para:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 005, 030 MSGET oGetPara VAR cGetPara SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//===========
	// Com c�pia:
	//===========
	@ 021, 006 SAY oCc PROMPT "Cc:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 021, 030 MSGET oGetCc VAR cGetCc SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//=========
	// Assunto:
	//=========
	@ 037, 006 SAY oAssunto PROMPT "Assunto:" SIZE 022, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 037, 030 MSGET oGetAssun VAR cGetAssun SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//======
	// Anexo
	//======
	@ 053, 006 SAY oAnexo PROMPT "Anexo:" SIZE 019, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 053, 030 MSGET oGetAnx VAR cGetAnx SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 READONLY PIXEL

	//==========
	// Mensagem:
	//==========
	@ 069, 006 SAY oMens PROMPT "Mensagem:" SIZE 030, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
//	_oFont		:= TFont():New( 'Courier new' ,, 12 , .F. )
	_oScrAux	:= TSimpleEditor():New( 080 , 006 , oDlgMail , 285 , 105 ,,,,, .T. )
    _cHtml:=cHtml
	_oScrAux:Load( cHtml )
	_cPathLocal:=GetTempPath()
	If File(_cOrigem)


		//Copia anexo para esta��o local
		IF !CpyS2T(_cOrigem,_cPathLocal)
		    _cPathLocal:=""
			U_ITMSG("N�o foi possivel copiar o arquivo "+_cOrigem+" para "+_cPathLocal,'Aten��o!',"Feche o arquivo "+_cOrigem+", caso aberto, tente novamente",1)
		ENDIF
	ELSE	
	    U_ITMSG("N�o foi possivel copiar o arquivo "+_cOrigem+" para "+_cPathLocal,'Aten��o!',"Arquivo "+_cOrigem+" n�o existe.",1)
	EndIf

    _cOrigem2:=StrTran( _cOrigem, cPathSrv, _cPathLocal ) 
	
    IF !EMPTY(_cPathLocal)
	   @ 189, 156 BUTTON oButEnv PROMPT "&Visualizar"	SIZE 037, 012 OF oDlgMail ACTION ( ShellExecute("open", _cOrigem2, "", _cPathLocal, 1) ) PIXEL
	ENDIF
	@ 189, 201 BUTTON oButEnv PROMPT "&Enviar"		SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 1 , cHtml := _oScrAux:RetText() , oDlgMail:End() ) PIXEL
	@ 189, 245 BUTTON oButCan PROMPT "&Cancelar"	SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 2 , oDlgMail:End() ) PIXEL

ACTIVATE MSDIALOG oDlgMail CENTERED

If nOpcA == 1
   If Empty(cHtml) .OR. cHtml = NIL
      cHtml:=_cHtml
   EndIf
	//====================================
	// Chama a fun��o para envio do e-mail
	//====================================
	cGetPara:=STRTRAN( cGetPara, ";", "," )
	cGetCc  :=STRTRAN( cGetCc  , ";", "," )

	U_ITENVMAIL( Lower(AllTrim(UsrRetMail(RetCodUsr()))), cGetPara, cGetCc, cMailCom, cGetAssun, cHtml, cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

	If !Empty( _cEmlLog )
		//=====================================================================
		// Chama fun��o para grava��o do campo de envio de e-mail na tabela SC7
		//=====================================================================
		IF !IsInCallStack("U_RCOM006") .AND. "SUCESSO" $ UPPER(_cEmlLog)
		   RCOM002I(_cFilial, _cNumPC)
		ENDIF   

		U_ITMSG( _cEmlLog+CHR(13)+CHR(10)+"E-mail para: "+ALLTRIM(cGetPara)+CHR(13)+CHR(10)+"CC: "+cGetCc , 'T�rmino do processamento!' , ,3 )
	EndIf
EndIf

Return()

/*
===============================================================================================================================
Programa----------: RCOM002D
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 11/02/2016
Descri��o---------: Fun��o respons�vel pela exclus�o do arquivo pdf gerado no servidor
Parametros--------: cFile	- Caminho + nome do arquivo pdf
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM002D(cFile)
Local nRet := 0

If File(cFile)
	nRet := fErase(cFile)
	If nRet <> 0
		FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "RCOM002"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "RCOM00201"/*cMsgId*/, "RCOM00201 - Erro ao excluir o arquivo: " + cFile + " - Erro: " + str(FError())/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "RCOM002"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "RCOM00202"/*cMsgId*/, "RCOM00202 - Arquivo: " + cFile + " foi exclu�do com sucesso."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa----------: formCPFCNPJ
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 14/01/2016                                      
Descri��o---------: Fun��o criada para formatar CPF/CNPJ
Parametros--------: cCPFCNPJ	- Texto a ser quebrado
Retorno-----------: cCampFormat	- Retorna o campo formatado conforme CPF/CNPJ
===============================================================================================================================
*/
Static Function formCPFCNPJ(cCPFCNPJ)
Local cCampFormat := ""	//Armazena o CPF ou CNPJ formatado
   
If Len(AllTrim(cCPFCNPJ)) == 11			//CPF
	cCampFormat:=SubStr(cCPFCNPJ,1,3) + "." + SubStr(cCPFCNPJ,4,3) + "." + SubStr(cCPFCNPJ,7,3) + "-" + SubStr(cCPFCNPJ,10,2) 
Else									//CNPJ
	cCampFormat:=Substr(cCPFCNPJ,1,2)+"."+Substr(cCPFCNPJ,3,3)+"."+Substr(cCPFCNPJ,6,3)+"/"+Substr(cCPFCNPJ,9,4)+"-"+ Substr(cCPFCNPJ,13,2)
EndIf
	
Return cCampFormat

/*
===============================================================================================================================
Programa----------: R002FIniPC
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 14/01/2016
Descri��o---------: Inicializa as fun��es Fiscais com o Pedido de Compras
Parametros--------: ExpC1	- N�mero do Pedido
				  : ExpC2	- Item do Pedido
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function R002FIniPC(cPedido,cItem,cSequen,cFiltro,cFilScr,oProc)

Local aArea		:= GetArea() , D
Local aAreaSC7	:= SC7->(GetArea())
Local cValid	:= ""
Local nPosRef	:= 0
Local nItem		:= 0
Local cItemDe	:= IIf(cItem==Nil,'',cItem)
Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols	:= ''

Default cSequen	:= ""

_aSC7 := SC7->(DBSTRUCT())

dbSelectArea("SC7")
SC7->(dbSetOrder(1))
If SC7->(dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen)))
	MaFisEnd()
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
	While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
			SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

        oProc:cCaption := ("1-Lendo Item: "+SC7->C7_ITEM)
        ProcessMessages()
		//==============================================================
		// Nao processar os Impostos se o item possuir residuo eliminado
		//==============================================================  
		If  SC7->C7_RESIDUO = "S"		
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf
            
		// Inicia a Carga do item nas funcoes MATXFIS  
		nItem++
		MaFisIniLoad(nItem)

		FOR D := 1 TO LEN(_aSC7)
		    _cCampo := _aSC7[D][1]
			cValid	:= StrTran(UPPER(Getsx3cache(_cCampo,"X3_VALID") )," ","")
			cValid	:= StrTran(cValid,"'",'"')
			If "MAFISREF" $ cValid
				nPosRef  := AT('MAFISREF("',cValid) + 10
				cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				// Carrega os valores direto do SC7.           
				MaFisLoad(cRefCols,&("SC7->"+_cCampo),nItem)
			EndIf
		NEXT D

		MaFisEndLoad(nItem,2)
		dbSelectArea('SC7')
		dbSkip()
	End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.

/*
===============================================================================================================================
Programa----------: RCOM002I
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 16/02/2016
Descri��o---------: Fun��o criada para fazer a grava��o do campo de envio de e-mail
Parametros--------: ExpC1	- Filial
------------------: ExpC2	- N�mero do PC
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM002I(_cFilial, _cNumPC)
Local aArea	:= GetArea()  

dbSelectArea("SC7")
SC7->(dbSetOrder(1))
SC7->(dbSeek(_cFilial + _cNumPC))

While !SC7->(Eof()) .And. SC7->C7_FILIAL == _cFilial .And. SC7->C7_NUM == _cNumPC

	RecLock("SC7", .F.)
		Replace SC7->C7_I_ENVIO With Soma1(SC7->C7_I_ENVIO)
	MsUnLock()

	SC7->(dbSkip())
End

RestArea(aArea)
Return

/*
===============================================================================================================================
Programa----------: RCOM002A
Autor-------------: Jerry 
Data da Criacao---: 23/03/2016
Descri��o---------: Fun��o criada para fazer a quebra da Descri��o do Produto
Parametros--------: ExpC1	- Descri��o do Produto
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function RCOM002A(cTexto)    

Local nCont        := 1        
Local cTextoQbr   := "" 

cTexto:=STRTRAN( AllTrim(cTexto) , CHR(13)+CHR(10), " ")
             
While nCont <= Len(cTexto)              
	                            
	cTextoQbr:= AllTrim(SubStr(cTexto,nCont,65))
	IF !EMPTY(cTextoQbr)
	   oPrint:Say((nLinAux),(nColIni+100),cTextoQbr,oFont08)
	   nLinAux+= 10
	ENDIF
	nCont+= 65

EndDo                    

Return 

/*
===============================================================================================================================
Programa----------: MCOM002Totais()
Autor-------------: Alex Wallauer
Data da Criacao---: 04/09/2019
Descri��o---------: RETORNA A DESCRI��O DAS MOEDAS
Parametros--------: _nMoedaSC7,_nTxMoeSC7
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MCOM002Totais(_nMoedaSC7,_nTxMoeSC7,nTotMerc,_lSimbolo)

STATIC _aAllmoedas:= {}
DEFAULT _lSimbolo:=.T.

IF LEN(_aAllmoedas) = 0 .AND. _nMoedaSC7 > 1
   AADD(_aAllmoedas, ALLTRIM(GETMV("MV_SIMB1")) )
   AADD(_aAllmoedas, ALLTRIM(GETMV("MV_SIMB2")) )
   AADD(_aAllmoedas, ALLTRIM(GETMV("MV_SIMB3")) )
   AADD(_aAllmoedas, "�" )//ALLTRIM(GETMV("MV_SIMB4"))
   AADD(_aAllmoedas, ALLTRIM(GETMV("MV_SIMB5")) )
ENDIF   

IF _nMoedaSC7 > 1 .AND. _nMoedaSC7 < 6
   IF _nTxMoeSC7 <> 0// NA MOEDA / EM REAL
      RETURN  _aAllmoedas[_nMoedaSC7]+" "+ALLTRIM(Transform(nTotMerc,PesqPict("SC7","C7_TOTAL")))+" / R$ "+ALLTRIM(Transform( (nTotMerc*_nTxMoeSC7) ,PesqPict("SC7","C7_TOTAL")))
   ELSE//S� NA MOEDA
       IF VALTYPE(nTotMerc) = "N"
          RETURN _aAllmoedas[_nMoedaSC7]+" "+ALLTRIM(Transform(nTotMerc,PesqPict("SC7","C7_TOTAL")))// NA MOEDA
       ELSE
          RETURN _aAllmoedas[_nMoedaSC7]+" "+ALLTRIM(nTotMerc)// NA MOEDA
       ENDIF   
   ENDIF   
ELSE//EM REAL
   IF VALTYPE(nTotMerc) = "N"
      RETURN IF(_lSimbolo,"R$ ","")+ALLTRIM(Transform( nTotMerc ,PesqPict("SC7","C7_TOTAL")))//EM REAL
   ELSE   
      RETURN IF(_lSimbolo,"R$ ","")+ALLTRIM(nTotMerc)
   ENDIF   
ENDIF

Return

/*
===============================================================================================================================
Programa----------: RCOM002Cab()
Autor-------------: Alex Wallauer
Data da Criacao---: 01/10/2019
Descri��o---------: RETORNA A DESCRI��O DA MOEDA NA OBS
Parametros--------: _cNumPC , _cFilial
etorno-----------: .T.
===============================================================================================================================
*/
STATIC FUNCTION RCOM002Cab(_cNumPC,_cFilial,nLinIni,nColIni)

IF SC7->C7_I_APLIC == "I"
   oPrint:Say( (nLinIni+030) , (nColIni+300) , "PEDIDO DE COMPRAS ** INVESTIMENTO **" , oFont14 )
   oPrint:Say( (nLinIni+045) , (nColIni+300) , ALLTRIM(Posicione("ZZI",1,xFilial("ZZI")+SC7->C7_I_CDINV, "ZZI_DESINV")) , oFont08 )
ELSEIF SC7->(FIELDPOS("C7_I_CLAIM")) <> 0 .AND. SC7->C7_I_CLAIM = "1"
   oPrint:Say( (nLinIni+035) , (nColIni+375) , "PEDIDO DE COMPRAS ** CLAIM **" , oFont14 )
ELSE
   oPrint:Say( (nLinIni+035) , (nColIni+375) , "PEDIDO DE COMPRAS" , oFont14 )
ENDIF

oPrint:Say( (nLinIni+050) , (nColIni+730) , "N�" , oFont14 )
oPrint:Say( (nLinIni+070) , (nColIni+715) , _cNumPC , oFont14 )

SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt + _cFilial))

oPrint:Say( (nLinIni+080) , (nColIni+020) , AllTrim(SM0->M0_NOMECOM) , oFont08 )
oPrint:Say( (nLinIni+090) , (nColIni+020) , AllTrim(SM0->M0_ENDCOB) , oFont08 )
oPrint:Say( (nLinIni+100) , (nColIni+020) , "CEP: " + SubStr(AllTrim(SM0->M0_CEPCOB),1,2) + "." + SubStr(AllTrim(SM0->M0_CEPCOB),3,3) + "-" + SubStr(AllTrim(SM0->M0_CEPCOB),6,3) + " - " + SubStr(AllTrim(SM0->M0_CIDCOB),1,50) + " - " + AllTrim(SM0->M0_ESTCOB) , oFont08 )
oPrint:Say( (nLinIni+110) , (nColIni+020) , 'TEL:(' + SubStr(SM0->M0_TEL,4,2) + ')' + SubStr(SM0->M0_TEL,7,4) + '-' +SubStr(SM0->M0_TEL,11,4) + " - " + 'FAX:(' + SubStr(SM0->M0_FAX,4,2) + ')' + SubStr(SM0->M0_FAX,7,4) + '-' +SubStr(SM0->M0_FAX,11,4), oFont08 )
oPrint:Say( (nLinIni+120) , (nColIni+020) , "CNPJ/CPF:" + formCPFCNPJ(SM0->M0_CGC) , oFont08 )
oPrint:Say( (nLinIni+130) , (nColIni+020) , "I.E:" + AllTrim(SM0->M0_INSC) , oFont08 )

SA2->(dbSetOrder(1))
SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

oPrint:Say( (nLinIni+080) , (nColIni+260) , AllTrim(SA2->A2_NOME) + " - " + SA2->A2_COD + "/" + SA2->A2_LOJA , oFont08 )
oPrint:Say( (nLinIni+090) , (nColIni+260) ,  AllTrim(SA2->A2_END) , oFont08 )
oPrint:Say( (nLinIni+100) , (nColIni+260) , "CEP: " + SubStr(AllTrim(SA2->A2_CEP),1,2) + "." + SubStr(AllTrim(SA2->A2_CEP),3,3) + "-" + SubStr(AllTrim(SA2->A2_CEP),6,3) + " - " + AllTrim(SA2->A2_MUN) + " - " + SA2->A2_EST , oFont08 )
oPrint:Say( (nLinIni+110) , (nColIni+260) , "TEL:(" + AllTrim(SA2->A2_DDD) + ") " + SubStr(AllTrim(SA2->A2_TEL),1,4) + "-" + SubStr(AllTrim(SA2->A2_TEL),5,4) + " - " + "FAX:(" + AllTrim(SA2->A2_DDD) + ") " + SubStr(AllTrim(SA2->A2_FAX),1,4) + "-" + SubStr(AllTrim(SA2->A2_FAX),5,4) , oFont08 )
oPrint:Say( (nLinIni+120) , (nColIni+260) , "CNPJ/CPF: " + formCPFCNPJ(SA2->A2_CGC) + " - I.E:" + SA2->A2_INSCR , oFont08 )
oPrint:Say( (nLinIni+130) , (nColIni+260) ,  AllTrim(SC7->C7_CONTATO) , oFont08 )

oPrint:Say( (nLinIni+160) , (nColIni+020) , "Item"			, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+045) , "Produto"		, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+100) , "Descri��o"		, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+400) , "UM"			, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+450) , "Quantidade"	, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+525) , "Vlr.Unit."		, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+570) , "Vlr.Desc."		, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+622) , "Vlr.Total"		, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+690) , "IPI"			, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+721) , "ICMS ST"		, oFont08 )
oPrint:Say( (nLinIni+160) , (nColIni+770) , "Dt.Entrega"	, oFont08 )

nLinAux := nLinIni + 180

RETURN .T.
