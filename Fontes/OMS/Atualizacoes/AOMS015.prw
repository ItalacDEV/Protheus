/*  
===============================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
     Autor    |   Data   |                                             Motivo                                          
-------------------------------------------------------------------------------------------------------------------------------
 Alex Walaluer| 19/07/18 | Chamado 25558. Corre��o do ERROLOG (variable does not exist C5_I_FILFT U_AOMS015R() line: 1180.
 Josu� Danich | 09/01/19 | Chamado 27607. Inclus�o de legenda de simulador de pre�os. 
 Lucas Borges | 15/10/19 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25.
 Jerry        | 20/05/20 | Chamado 32883. Ajuste na valida��o Pre�o M�ximo.
 Julio Paz    | 18/06/20 | Chamado 33284. Exibir novos dados e Remodelar tela de Avalia��o Pedidos Bloqueados Pre�o Portal
 Jerry        | 03/08/20 | Chamado 33740. Novos campos na Tela e no formato de mostrar Pre�o.
 Jerry        | 04/11/20 | Chamado 34582. Validar novo campo de Tabela de Pre�o. 
 Igor Melga�o | 24/01/22 | Chamado 37416. Ajuste para compartilhamento das tabelas DA0 e DA1.
 Alex Wallauer| 03/02/22 | Chamado 39057. Corre��o/altera��o do tratamento da fun��o BLQPRC().
 Jerry        | 13/05/22 | Chamado 40105. Ajuste para demonstrar Pre�o por Faixa.
 Julio Paz    | 14/11/22 | Chamado 41481. Ajustar a exibi��o de dados da rotina. Exibir Raz�o social e Nome reduzido. 
 Alex Wallauer| 04/01/24 | Chamado 45999. Vanderlei. variable does not exist _NPRCMIN on U_AOMS015R(AOMS015.PRW).
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================
Alex     - Alex Wallauer - 20/02/25 - 25/02/25 - 49966   - CORRE��O DE ERROR.LOG: variable does not exist _NPESOFAIXA on U_AOMS015R(AOMS015.PRW) 04/01/2024 17:41:14 line : 1398
Alex     - Julio Paz     - 25/02/25 - 25/02/25 - 49966   - Disponibilizar o bot�o Visualizar apenas para Pedidos de Vendas/Portal com status bloqueados.
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "vKey.ch"

/*
===============================================================================================================================
Programa----------: AOMS015
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Libera��o de Pedidos de Venda e Pedido Portal Bloqueados por pre�o de venda - Chamado 2721 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS015()

Private _cPerg    := "AOMS015"
Private aSize     := {}
Private _lVersao12:=(AllTrim( cVersao ) = "12")
Private _nAltCombo:=IF(_lVersao12,10,20)
Private _nLB      :=IF(_lVersao12,20,05)
Private _nMSS     :=IF(_lVersao12,24,10)

AOMS015TT() //Fun��o utilizada para mostrar as configura��es de tela do usu�rio

If pergunte(_cPerg,.T.)

	If MV_PAR01 == 1
	
		U_AOMS015Y() //Libera pedidos de venda normais
	
	Else
	
		U_AOMS015ZW() //Libera pedidos de venda do portal
	
	EndIf	

EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS015ZW
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Tela Libera��o de Pre�o Pedido Portal	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS015ZW()
Local _nPosCol := 40

Private _aCpoBrw
Private _aCpoTmp
Private _acores := {}
Private bped := nil

Private lInverte 		:= .T.
Private cmarca   		:= GetMark()
Private oMark
Private cPesq   		:= Space(50)
Private lCheck1 		:= .t.
Private lCheck2 		:= .t.
Private lCheck3 		:= .t.
Private cCombo		:= " "
Private cOrdem		:= " "
Private aOrdem		:= {"GERENTE","COORDENADOR","REPRESENTANTE","PEDIDO","CLIENTE"}
Private cPESQUISA		:= SPACE(200), oPesquisa
Private _aMarcados	:={}
Private TRB 			:= CriaTrab(Nil,.F.)
Public lClos 			:= .F.
Public cChama := "1"

Do while cChama == "1"

	Processa( {|| AOMS015PP() } , 'Aguarde...' , "Recarregando Tabela..." ) //Prepara dados para a tela
	cChama := "2"//Para sair no X
	@ aSize[7]/*000*/,000 TO aSize[6]/*650*/,aSize[5]/*935*/ DIALOG oDlgLib TITLE " Libera��o de Pedidos do Portal com bloqueio/rejei��o de  Pre�o "  //850,1135

	oMark:=MsSelect():New("TMP","","OK",_aCpoBrw,@lInverte,@cMarca,{040,005,aSize[4]-_nMSS,aSize[3]},,,,,_aCores)//{015,005,400,630,565}
	oMark:oBrowse:lHasMark := .T.
	oMark:oBrowse:lCanAllMark:=.T.

	@ 003,006 To 034,315 Title " Pedido "
	@ 016,015 Say "Ordem: "
	@ 015,037 ComboBox cOrdem ITEMS aOrdem SIZE 50,_nAltCombo Object oOrdem
	@ 015,099 Get    cPESQUISA			   Size 180,10 Object oPesquisa
	oOrdem:bChange := {|| AOMS015FO(CORDEM),oMark:oBrowse:Refresh(.T.)}

	@ 016,350	Button "Pesquisar"       	Size 40,13	Action AOMS015P(CORDEM) //Pesquisa Informa��es no Browse de acordo com a Ordem selecionada.
	@ aSize[4]-_nLB,295 Button "Legenda"	Size 40,13	Action AOMS015J() 								Object oBtnRet  //Fun��o utilizada no bot�o de legenda mostrar o significado de cada cor

    If MV_PAR02 == 2	
	   @ aSize[4]-_nLB,340 Button "Visualizar"	Size 40,13	Action U_AOMS015H(TMP->FILIAL,TMP->NUMPED)	Object oBtnRet  //Funcao que Visualiza Itens do(s) Pedido(s) de Venda 
	   _nPosCol := 0
	EndIf 

	@ aSize[4]-_nLB,385 - _nPosCol Button "Avaliar"	Size 40,13	Action AOMS0159(1)								Object oBtnRet  //Fun��o que chama autoriza��o ou bloqueio do pedido
	@ aSize[4]-_nLB,430 - _nPosCol Button "Sair"		Size 40,13	Action AOMS0158()								Object oBtnInv  //Funcao que fecha a rotina

	dbSelectArea("TMP")
	dbGoTop()

	While !TMP->(EOF())

		RecLock("TMP",.f.)
		TMP->OK    := ThisMark()
		TMP->(MsUnlock())
		TMP->(dbSkip())

	End

	dbGoTop()

	oMark:oBrowse:Refresh(.T.)

	ACTIVATE DIALOG oDlgLib CENTERED

	DBSELECTAREA("TMP")
	TMP->(Dbclosearea())

Enddo

Return


/*
===============================================================================================================================
Programa----------: AOMS015O
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Funcao que avalia os Pedido de Venda para classifica-lo corretamente na legenda.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015O()

Local _cRet
Local _aArea  := GetArea()
Local _cBloq	 := 0

If TMP->( EOF() )

	Return("")

Endif

DbSelectArea("SZW")
SZW->( DbSetorder(1) )
szw->( DbSeek(TMP->FILIAL+TMP->NUMPED) )

While SZW->(!EOF()) .And. SZW->ZW_IDPED == TMP->NUMPED

	If SZW->ZW_BLOPRC == 'B'

		If SZW->ZW_ENVWF == 'G'

			_cBloq:= 4

		ElseIF SZW->ZW_ENVWF == 'C'

			_cBloq:= 5

		EndIf

		Exit 

	EndIf

	If SZW->ZW_BLOPRC == 'L'
		_cBloq:= 2
		Exit
	EndIf

	If SZW->ZW_BLOPRC == 'R'
		_cBloq:= 1
		Exit
	EndIf

	SZW->( DbSkip() )

EndDo

If _cBloq == 3

	_cRet := "1"

ElseIf _cBloq == 1

	_cRet := "2"

ElseIf _cBloq == 2
	
	_cRet := ""

ElseIf _cBloq == 4

	_cRet := "4"	

ElseIf _cBloq == 5

	_cRet := "5"	

EndIf

RestArea(_aArea)

Return(_cRet)

/*
===============================================================================================================================
Programa----------: AOMS015H
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Funcao que Visualiza Itens do(s) Pedido(s) de Venda 	
===============================================================================================================================
Parametros--------: cFilAux , cPedAux
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS015H( cFilAux , cPedAux )

Local _aArea		:= GetArea()									// Salva a area atual
Local _oDlgHist													// Tela do Historico

Local S
Local aPosObj := AOMS015TT(200,200,.T.)
Local _nLarg  := aPosObj[2,3]
Local _nAlt   := aPosObj[2,4]

Private cObsMemo 	:= ""										// String com a descricao do MEMO

CursorWait()

//=======================================================================================
//Seleciona todas a ligacoes desse cliente indexando por ordem de ligacao decrescente
//=======================================================================================
aLigacoes	:= {}
aCC			:= {}
LCOORD		:= .F.

DbSelectArea("SZW")
SZW->( DBSETORDER(1) )
SZW->( DBSEEK( cFilAux + cPedAux ) )

While SZW->( !Eof() ) .AND. SZW->(ZW_FILIAL+ZW_IDPED) == cFilAux + cPedAux
	
	AAdd(aCC, {	SZW->ZW_BLOPRC,;
					IF(EMPTY(SZW->ZW_FILPRO),SZW->ZW_FILIAL,SZW->ZW_FILPRO),;
					SZW->ZW_FILIAL,;
					SZW->ZW_IDPED,;
					SZW->ZW_ITEM,;
					SZW->ZW_PRODUTO,;
					GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SZW->ZW_PRODUTO,1,""),;
					SZW->ZW_UM,;
					Transform(SZW->ZW_QTDVEN,"@E 999,999,999"),;
					Transform(SZW->ZW_PRCVEN, "@E 999,999,999.99"),;
					Transform(SZW->ZW_QTDVEN*SZW->ZW_PRCVEN, "@E 999,999,999.99"),;
					SZW->ZW_LOCAL,;
					SZW->ZW_CLIENTE,;
					SZW->ZW_LOJACLI,;
					Transform(SZW->ZW_PRUNIT, "@E 999,999,999.99"),;
					Transform(SZW->ZW_VALDESC, "@E 999,999,999.99"),;
					SZW->ZW_TES,;
					SZW->ZW_CF})
	
	SZW->(DbSkip())
	
End

aLigacoes := ASort(aCC,,,{|x,y|x[2]<y[2]})

If Len(aLigacoes) <= 0

	Help(" ",1,"SEMDADOS" )
	CursorArrow()
	Return(.F.)
	
Endif

SZW->( DBSEEK( cFilAux + cPedAux ) )
DbSelectArea("SZW")
FOR S := 1 TO FCount()
    M->&(FIELDNAME(S)) := FieldGet(S)
NEXT
aRotina:={}
aADD(aRotina,{ "Visualizar","Auxiliar",0,2})

DEFINE MSDIALOG _oDlgHist FROM aSize[7],000 TO aSize[6],aSize[5] TITLE "Itens do Pedido: " + cPedAux  PIXEL  

EnChoice( "SZW", SZW->(RECNO()) , 1 ,,,,, aPosObj[1] , , 3, , , , , ,.F. )

@aPosObj[2,1] ,aPosObj[2,2] LISTBOX oLbx FIELDS HEADER 	"Blq.Pre�o",;//08,05
										"Filial Faturamento",;
										"Filial Carregamento",;
										"Num. Pedido",;
										"Item",;
										"Produto",;
										"Descri��o",;
										"UM",;
										"Qtd Vend.",;
										"Prc. Vend.",;
										"Total",;
										"Armazem",;
										"Cliente",;
										"Loja",;
										"Prc. Unit.",;
										"Vlr. Desc.",;
										"TES",;
										"CFOP";
										 SIZE _nLarg,_nAlt OF _oDlgHist PIXEL //aSize[3]-10,aSize[4]-20


oLbx:SetArray(aLigacoes)
oLbx:bLine:={||{	aLigacoes[oLbx:nAt,01]	,;
					aLigacoes[oLbx:nAt,02]	,;
					aLigacoes[oLbx:nAt,03]	,;
					aLigacoes[oLbx:nAt,04]	,;
					aLigacoes[oLbx:nAt,05]	,;
					aLigacoes[oLbx:nAt,06]	,;
					aLigacoes[oLbx:nAt,07]	,;
					aLigacoes[oLbx:nAt,08]	,;
					aLigacoes[oLbx:nAt,09]	,;
					aLigacoes[oLbx:nAt,10]	,;
					aLigacoes[oLbx:nAt,11]	,;
					aLigacoes[oLbx:nAt,12]	,;
					aLigacoes[oLbx:nAt,13]	,;
					aLigacoes[oLbx:nAt,14]	,;
					aLigacoes[oLbx:nAt,15]	,;
					aLigacoes[oLbx:nAt,16]	,;
					aLigacoes[oLbx:nAt,17]	}}

oLbx:Refresh()
oLbx:SetFocus(.T.)

ACTIVATE MSDIALOG _oDlgHist CENTER ON INIT EnchoiceBar(_oDlgHist,{|| _oDlgHist:End()},{|| _oDlgHist:End()})

RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: AOMS015P
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Pesquisa Informa��es no Browse de acordo com a Ordem selecionada.
===============================================================================================================================
Parametros--------: cOrdem
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015P(cOrdem)

DbSelectArea("TMP")
TMP->( DbSetOrder(Ascan(aOrdem,cOrdem)) )
TMP->( DbGoTop() )
TMP->( DbSeek(Alltrim(cPesquisa),.T.) )
oMark:oBrowse:Refresh(.T.)

Return

/*
===============================================================================================================================
Programa----------: AOMS015FO
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Funcao executada na saida do campo Ordem, para ordenar o browse
===============================================================================================================================
Parametros--------: cORDEM
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015FO(cORDEM)

_nReg:=Recno()
cPesquisa:=Space(200)
oPesquisa:Refresh()

_aMarcados:={}

DbSelectArea("TMP")
TMP->(DbGoTop())

IF CORDEM == 'PEDIDO'

	While TMP->(!EOF())
	
		AADD(_aMarcados,{TMP->NUMPED,TMP->OK})
		TMP->(DbSkip())
		
	End
	
ELSEIF CORDEM == 'CLIENTE'

	While TMP->(!EOF())
	
		AADD(_aMarcados,{TMP->CODCLI,TMP->OK})
		TMP->(DbSkip())
		
	End

ELSEIF CORDEM == "GERENTE"

	While TMP->(!EOF())
	
		AADD(_aMarcados,{TMP->VEND3,TMP->OK})
		TMP->(DbSkip())
		
	End
	

ELSEIF CORDEM == "COORDENADOR"

	While TMP->(!EOF())
	
		AADD(_aMarcados,{TMP->VEND2,TMP->OK})
		TMP->(DbSkip())
		
	End
	

ELSEIF CORDEM == "REPRESENTANTE"

	While TMP->(!EOF())
	
		AADD(_aMarcados,{TMP->VEND1,TMP->OK})
		TMP->(DbSkip())
		
	End
	
ENDIF

DbSelectArea("TMP")
TMP->( DbSetOrder(Ascan(aOrdem,cOrdem)) )
TMP->( DbGoTo(_nReg) )    //Mantendo no mesmo registro que estava posicionado anteriormente
oMark:oBrowse:Refresh(.T.)

Return

/*
===============================================================================================================================
Programa----------: AOMS015J
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Fun��o utilizada no bot�o de legenda mostrar o significado de cada cor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015J()

Local _cCadastro:=OemToAnsi("Pedido")

BrwLegenda(_cCadastro,"Legenda",{	{"BR_CINZA"       ,"Pedido Com Pre�o Bloqueado"},;
									{"BR_VERDE_ESCURO","Pendente Gerente"},;
									{"BR_AMARELO"     ,"Pendente Coordenador"},;									
									{"BR_VERMELHO"    ,"Pedido Com Pre�o Rejei��o"}} )
Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS015TT
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Fun��o utilizada para mostrar as configura��es de tela do usu�rio	
===============================================================================================================================
Parametros--------: _nPosEnch,_nPosGetDados,_lDimensao
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015TT(_nPosEnch,_nPosGetDados,_lDimensao)

LOCAL aObjects:= {}
LOCAL aInfo   := {}
LOCAL aPosObj := {}
aSize   := {}

DEFAULT _nPosEnch    := 0
DEFAULT _nPosGetDados:= 0
DEFAULT _lDimensao   :=.F.

// Obt�m a a �rea de trabalho e tamanho da dialog
aSize := MsAdvSize()

AAdd( aObjects, { _nPosEnch    , _nPosEnch    , .T., .T.             } ) // Dados da Enchoice
AAdd( aObjects, { _nPosGetDados, _nPosGetDados, .T., .T. ,_lDimensao } ) // Dados da getdados

// Dados da �rea de trabalho e separa��o
aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, 3, 3 } // Chama MsObjSize e recebe array e tamanhos

aPosObj := MsObjSize( aInfo, aObjects,.T.)

Return aPosObj

/*
===============================================================================================================================
Programa----------: AOMS015W
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Tela do pedido do portal chamada a partir do bot�o Avalia na tela principal
===============================================================================================================================
Parametros--------: cFilAux , cPedAux
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS015W( cFilAux , cPedAux )

Local _ccodcomp	:= ""
Local _cnomefil 	:= ""
Local _cfilori := cfilant
Local _nLinha, _cOper, _dDtEmiss, _dDtEntr
Local _dDtLiber, _cCondPg, _cDescCond, _cTipCarg
Local _nPrecoTab := 0 
Local _cPrTela1  := ""
Local _cPrTela2  := ""
Local _cRazaoSocial := ""

// Variaveis para GetDados()
Private aCols		:= {}
Private aHeader	:= {}
Private oVermelho	 := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerde   	 := LoadBitmap( GetResources(), "BR_VERDE" )

//Muda para filial do pedido para garantir o processamento correto
cfilant := IIF(empty(TMP->FILPRO),TMP->FILIAL,TMP->FILPRO)

aLigacoes := {}
aCC       := {}
LCOORD := .F.

DbSelectArea("SZW")
SZW->( DBSETORDER(1) )
SZW->( DBSEEK( cFilAux + cPedAux ) ) 

_cvend2 := Posicione("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")  
_cvend3 := SA3->A3_GEREN
_cvend4 := SA3->A3_I_SUPE
_cRede  := Posicione("SA1",1,xfilial("SA1")+SZW->ZW_CLIENTE,"A1_GRPVEN")
If SA1->A1_SIMPNAC == "1"
	_lSimplNac := .T. // O cliente � optante do Simples Nacional
Else
	_lSimplNac := .F. // O cliente n�o � Optante do Simples Nacional
EndIf

_nPesoBrut := AOMS015PESO(SZW->ZW_FILIAL,SZW->ZW_IDPED)
SZW->( DBSEEK( cFilAux + cPedAux ) ) 

//_atab := {}
//_aTab	:= u_ittabprc( TMP->FILIAL, IIF(empty(TMP->FILPRO),TMP->FILIAL,TMP->FILPRO),_cvend3,_cvend2,SZW->ZW_VEND1,SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,.T.,SZW->ZW_TABELA,_cVend4,_cRede)
_ctab := SZW->ZW_TABELA
 
//_atabs := {}
//_aTabs	:= u_ittabprc( TMP->FILIAL, IIF(empty(TMP->FILPRO),TMP->FILIAL,TMP->FILPRO),_cvend3,_cvend2,SZW->ZW_VEND1,SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,.T.)
_ctabs := SZW->ZW_TABELA   //N�o validar tabela simular com o novo processo de pre�o

While !Eof() .AND. SZW->ZW_IDPED == cPedAux

	nQtd2UM    := 0
	nPrcMin    := 0
	nPrcMax    := 0
	_nPrecoTab := 0
	_cPrTela1  := ""
	_cPrTela2  := "" 
/*
	DA1->(Dbsetorder(1))
	If DA1->(Dbseek(xFilial("DA1")+SZW->ZW_TABELA+SZW->ZW_PRODUTO))
	   	 nPrcMax   := DA1->DA1_PRCMAX
		If SZW->ZW_TPVENDA = "F" 
			nPrcMin := DA1->DA1_I_PMFE
			_nPrecoTab := DA1->DA1_PRCVEN
		else
			nPrcMin := DA1->DA1_I_PMFR
		   _nPrecoTab := DA1->DA1_I_PRFE 
		EndIf
	EndIf*/
//                 BLQPRC(_cProd         ,_nPrcVen      ,_cFil         ,_lshow,_ctab         ,_ltrans,_lusanovo, _nFatorPrc, _lVldLinha, _cGrupoP,_cUFPedV   , _lRetPrc,_cTpVenda      ,_lSimplNac,_nPesoBrut,_nFaixa        )
	_aBlqprc  := U_BLQPRC(SZW->ZW_PRODUTO,SZW->ZW_PRCVEN,SZW->ZW_FILIAL,  .F. ,SZW->ZW_TABELA,    .T.,      .T.,          0,           ,         ,SA1->A1_EST,         ,SZW->ZW_TPVENDA,_lSimplNac,_nPesoBrut,SZW->ZW_I_FXPES)
	_lPrecErro:= _aBlqprc[1]
	_nFaixa   := _aBlqprc[2]
   _nPrecoTab := _aBlqprc[4]

	nFator 	:= GetAdvFVal("SB1","B1_CONV"		,xFilial("SB1")+SZW->ZW_PRODUTO				,1,"")
	cTipConv:= GetAdvFVal("SB1","B1_TIPCONV"	,xFilial("SB1")+SZW->ZW_PRODUTO				,1,"")
	
	nNewFat := GetAdvFVal("SB1","B1_I_FATCO"	,xFilial("SB1")+SZW->ZW_PRODUTO				,1,"") 
	
	nFator := (If(nFator == 0, nNewFat, nFator)) 
	
	If cTipConv == 'D'
	
		nQtd2UM := SZW->ZW_QTDVEN/nFator
	
	ElseIf cTipConv == 'M'
	
	 	nQtd2UM := SZW->ZW_QTDVEN*nFator
	
	EndIf
	
	//Puxa dados de desconto contratual
	_aVlrDesc := U_veriContrato( SZW->ZW_CLIENTE , SZW->ZW_LOJACLI , SZW->ZW_PRODUTO ) 

    If _nPrecoTab > 0	 	
    	_cPrTela1 :="Faixa: "+Transform(_nFaixa, "@E 99") + " ---> " + Transform(_nPrecoTab, "@E 9,999.99")
    	_cPrTela2 :="Faixa: "+Transform(_nFaixa, "@E 99") + " ---> " + Transform(_nPrecoTab, "@E 9,999.99")
    Else 
    	_cPrTela1 := "Sem Tabela de Pre�o"
    EndIf

	AAdd(aCC, {		SZW->ZW_ITEM,;
						SZW->ZW_PRODUTO,;
						alltrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SZW->ZW_PRODUTO,1,"")),;
						Transform(SZW->ZW_QTDVEN,"@E 99,999") + " " + 						SZW->ZW_UM,;
						Transform(nQtd2UM,"@E 99,999") + " " + GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+SZW->ZW_PRODUTO,1,""),;
						Transform(SZW->ZW_PRCVEN, "@E 99,999.99"),;
						Transform(_aVlrDesc[1], "@E 999.99"),;
						Transform(SZW->ZW_PRCVEN - ( SZW->ZW_PRCVEN * (_aVlrDesc[1] / 100 ) ) , "@E 99,999.99"),;
    					_cPrTela1,;
    					_cPrTela2,;
 						Transform(SZW->ZW_QTDVEN*SZW->ZW_PRCVEN, "@E 999,999.99"),;
 						IF(_lPrecErro,"B"," "),;
 						IF(_lPrecErro,"B"," ")})
												
	SZW->(DbSkip())
	
End

DbSelectArea("SZW")
SZW->( DBSETORDER(1) ) 
SZW->( DBSEEK( cFilAux + cPedAux ) )

aLigacoes := ASort(aCC,,,{|x,y|x[1]<y[1]})

If Len(aLigacoes) <= 0

	Help(" ",1,"SEMDADOS" )
	CursorArrow()
	cfilant := _cfilori
	Return(.F.)
	
Endif
lClos := .F.
DEFINE MSDIALOG _oDlgHist FROM aSize[7],000 TO aSize[6],aSize[5] TITLE "Itens do Pedido do portal de Id " + cPedAux  PIXEL  


_cnomefil := alltrim(TMP->FILIAL) + " / " + FWFilialName(cEmpAnt,TMP->FILIAL)

If empty(TMP->FILPRO)

	_cnomefat := alltrim(TMP->FILIAL) + " / " + FWFilialName(cEmpAnt,TMP->FILIAL)
	
Else

	_cnomefat := alltrim(TMP->FILIAL) + " / " + FWFilialName(cEmpAnt,TMP->FILIAL)
	_cnomefil := alltrim(TMP->FILPRO) + " / " + FWFilialName(cEmpAnt,TMP->FILPRO)

Endif
_cOper     := SZW->ZW_TIPO      // "Opera��o" 
_dDtEmiss  := SZW->ZW_EMISSAO   // "Data de Emiss�o"  
_dDtEntr   := SZW->ZW_FECENT    // "Data de Entrega" 
_dDtLiber  := SZW->ZW_I_LIBCD   // "Data Libera��o de Credito"
_cCondPg   := SZW->ZW_CONDPAG   // "Condi��o de Pagamento"
_cDescCond := AllTrim(posicione("SE4",1,xFilial("SE4")+SZW->ZW_CONDPAG,"E4_DESCRI")) // "Condi��o de Pagamento"     
_cTipCarg  := If(SZW->ZW_TPVENDA == "F","Fechada", "Fracionada") // "Tipo de Carga"

_nLinha := 5
@ _nLinha,005 Say "Pedido:" 
@ _nLinha,055 Get TMP->NUMPED Picture "@!"  SIZE 050,10 when .f.   // 045
@ _nLinha,105 Get _cnomefil   Picture "@!"  SIZE 200,10 when .f.   // 095

@ _nLinha,330 Say "Opera��o:"                  
@ _nLinha,405 Get _cOper      Picture "@!"  SIZE 050,10 when .f. // 375

_nLinha += 15

@ _nLinha,005 Say "Filial Faturamento:" 
@ _nLinha,055 Get _cnomefat   Picture "@!"  SIZE 250,10 when .f. 

@ _nLinha,330 Say "Data de Emiss�o:"           
@ _nLinha,405 Get _dDtEmiss   Picture "@D"  SIZE 050,10 when .f. 
_nLinha += 15

@ _nLinha,005 Say "Cliente:"

SA1->(DBSETORDER(1))
SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

_ccodcomp     := alltrim(SZW->ZW_CLIENTE) + " / " + alltrim(SZW->ZW_LOJACLI)
_cRazaoSocial := SA1->A1_NOME + " / " + SA1->A1_EST 

@ _nLinha,055 Get _ccodcomp      Picture "@!"  SIZE 050,10 when .f. 
@ _nLinha,105 Get _cRazaoSocial  Picture "@!"  SIZE 200,10 when .f. 

@ _nLinha,330 Say "Data de Entrega:"           
@ _nLinha,405 Get _dDtEntr   Picture "@D"  SIZE 050,10 when .f. 

_nLinha += 15

@ _nLinha,005 Say "Loja do Cliente:"
@ _nLinha,055 Get AllTrim(GetAdvFval("SA1","A1_NREDUZ",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")) Picture "@!"  SIZE 250,10 when .f.

@ _nLinha,330 Say "Data Libera��o de Credito:" 
@ _nLinha,405 Get _dDtLiber    Picture "@D"  SIZE 050,10 when .f.
_nLinha += 15

@ _nLinha,005 Say "Representante:"
@ _nLinha,055 Get SZW->ZW_VEND1 Picture "@!"  SIZE 050,10 when .f. 
@ _nLinha,105 Get AllTrim(posicione("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_NOME")) Picture "@!"  SIZE 200,10 when .f.  

@ _nLinha,330 Say "Condi��o de Pagamento:"     
@ _nLinha,405 Get _cCondPg     Picture "@!"  SIZE 020,10 when .f.
@ _nLinha,430 Get _cDescCond   Picture "@!"  SIZE 175,10 when .f.  

_nLinha += 15

_csuper := SA3->A3_I_SUPE
_coord  := SA3->A3_SUPER
_cgeren := SA3->A3_GEREN

@ _nLinha,005 Say "Supervisor:"
@ _nLinha,055 Get _csuper Picture "@!"  SIZE 050,10 when .f. 
@ _nLinha,105 Get AllTrim(posicione("SA3",1,xFilial("SA3")+_csuper,"A3_NOME")) Picture "@!"  SIZE 200,10 when .f.  

@ _nLinha,330 Say "Tipo de Carga:"             
@ _nLinha,405 Get _cTipCarg Picture "@!"  SIZE 200,10 when .f.

_nLinha += 15

@ _nLinha,005 Say "Coordenador:"
@ _nLinha,055 Get _coord Picture "@!"  SIZE 050,10 when .f. 
@ _nLinha,105 Get AllTrim(posicione("SA3",1,xFilial("SA3")+_coord,"A3_NOME")) Picture "@!"  SIZE 200,10 when .f.

_ctabela := _ctab + " - " + ALLTRIM(POSICIONE("DA0",1,xFilial("DA0")+_ctab,'DA0_DESCRI'))
_ctabels := _ctabela

@ _nLinha,330 Say "Tabela de pre�os Pedido:" 
@ _nLinha,405 Get  _ctabela  Picture "@!"  SIZE 200,10 when .f.

_nLinha += 15

@ _nLinha,005 Say "Gerente:"
@ _nLinha,055 Get _cgeren Picture "@!"  SIZE 050,10 when .f. 
@ _nLinha,105 Get AllTrim(posicione("SA3",1,xFilial("SA3")+_cgeren,"A3_NOME")) Picture "@!"  SIZE 200,10 when .f.

@ _nLinha,330 Say "Faixa de Pre�os Pedido:" 
@ _nLinha,405 Get  SZW->ZW_I_FXPES  Picture "99"  SIZE 050,10 when .f.

_nLinha += 15


@_nLinha,05 LISTBOX oLbx FIELDS HEADER 		"Item",; 
											"Produto",;
											"Descri��o",;
											"Qtd 1�UM",;
											"Qtd 2�UM",;
											"Prc Vend",;
											"% Contrat.",;
											"Prc Net",;
											" ",;
											"Prcs Tabela",; 
											"Total";
											SIZE aSize[3] ,aSize[4]-155 OF _oDlgHist PIXEL 


oLbx:SetArray(aLigacoes)
oLbx:bLine:={||			{ aLigacoes[oLbx:nAt,1],;
						aLigacoes[oLbx:nAt,2],;
						aLigacoes[oLbx:nAt,3],;
						aLigacoes[oLbx:nAt,4],;
						aLigacoes[oLbx:nAt,5],;
						aLigacoes[oLbx:nAt,6],;
						aLigacoes[oLbx:nAt,7],;
						aLigacoes[oLbx:nAt,8],;
						If(aLigacoes[oLbx:nAt,12]='B',oVermelho,oVerde),;
						aLigacoes[oLbx:nAt,9],; 
						aLigacoes[oLbx:nAt,11]}}

oLbx:Refresh()
oLbx:SetFocus(.T.)

@ aSize[4]-_nLB,aSize[3]-175	Button "Rejeitar"	Size 037,012 action (Iif(AOMS015B(2),(lClos := .T.,_oDlgHist:end()),.F.))  //Fun��o chamada para a libera��o ou rejei��o de acordo com a chamada da mesma pelo seu respectivo bot�o
@ aSize[4]-_nLB,aSize[3]-130	Button "Liberar"	Size 037,012 action (Iif(AOMS015B(1),(lClos := .T.,_oDlgHist:end()),.F.))	//Fun��o chamada para a libera��o ou rejei��o de acordo com a chamada da mesma pelo seu respectivo bot�o
@ aSize[4]-_nLB,aSize[3]-85 	Button "Sair"		Size 037,012 action (lClos := .F.,_oDlgHist:end())

ACTIVATE MSDIALOG _oDlgHist CENTER ON INIT CursorArrow()

oMark:oBrowse:Refresh(.T.)

IF lClos 
   Close(oDlgLIb)
ENDIF

cfilant := _cfilori

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS015B
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Fun��o chamada para a libera��o ou rejei��o de acordo com a chamada da mesma pelo seu respectivo bot�o
===============================================================================================================================
Parametros--------: _nAcao
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015B( _nAcao )

Local _cmotivo 	:= space(100)
Local _nopc 	:= 0
Local _odlg		:= nil
Public lRetLib

Do while _nopc == 0 .or. ( empty(_cmotivo) .and. _nopc == 1) 

    _cmotivo:=IF(_nacao = 1, "Autorizado"+SPACE(100-LEN("Autorizado")) , SPACE(100) )

	DEFINE MSDIALOG _oDlg;
				 TITLE "Confirmar Motivo de " + iif(_nacao == 1, "libera��o", "bloqueio") + " do pedido " + ALLTRIM(TMP->NUMPED);
				 FROM 000,000 TO 140,600 OF _oDlg PIXEL
	
	@ 006,008 SAY "Motivo de " + iif(_nacao == 1, "libera��o", "bloqueio") + " do pedido " + ALLTRIM(TMP->NUMPED) + " - " + posicione("SA1",1,xfilial("SA1")+TMP->CODCLI,"A1_NOME")	
	
	@ 020,008 GET _cmotivo PICTURE "@x"	SIZE 220,010 
	
	@ 040,230 BUTTON "&Ok"			SIZE 030,014 ACTION ( _nopc := 1, _oDlg:End() )
	@ 040,261 BUTTON "&Cancelar"	SIZE 030,014 ACTION ( _oDlg:End() )
	
	ACTIVATE MSDIALOG _oDlg CENTER

	If _nopc == 0

		Return .F.
	
	Elseif empty(_cmotivo)

		u_itmsg("Obrigat�rio informar o motivo.","Aten��o",,1)

	Endif
	
Enddo

DbSelectArea("SZW")
SZW->( DBSETORDER(1) )

If SZW->( DBSEEK(TMP->(FILIAL+NUMPED)) ) 
		
	While SZW->(!EOF()) .And. SZW->(ZW_FILIAL+ZW_IDPED) == TMP->(FILIAL+NUMPED)
	
 		SZW->( Reclock("SZW",.F.) )
			If SZW->ZW_BLOPRC == "B"
	   		 	SZW->ZW_BLOPRC := IIF( _nAcao == 1 , "L" , "R" )
			EndIf
    		SZW->ZW_STATUS := IIF( _nAcao == 1 , "L" , "Q" )
			SZW->ZW_MLIBPRC:= "AOMS015"
			SZW->ZW_DTLIB := Date() 
			SZW->ZW_MOTLP  := Alltrim(_cmotivo) + " Via AOMS015" 
			SZW->ZW_DLIBP  := date()
			SZW->ZW_HLIBP  := time()
			SZW->ZW_MLIBP  := U_UCFG001(1) 
			SZW->ZW_ULIBP  := cUsername  

			If _nacao == 1
			
				SZW->ZW_VLIBP  := SZW->ZW_PRCVEN
				SZW->ZW_QTLIP  := SZW->ZW_QTDVEN
				SZW->ZW_LLIBP  := SZW->ZW_LOJACLI
				SZW->ZW_CLILP  := SZW->ZW_CLIENTE
				SZW->ZW_PLIBP  := DDATABASE + 30 
							 
			Endif
	
	   	SZW->( MsUnLock() )
	
		SZW->( DbSkip() )
	
	EndDo

EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS015Y
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Tela de Libera��o de Pre�o de Venda Pedido de Venda - CHAMADO 2721
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS015Y()
Local _nPosCol := 40

Private lInverte := .T.
Private cmarca   := GetMark()
Private oMark
Private cPesq     := Space(50)
Private lCheck1   := .t.
Private lCheck2   := .t.
Private lCheck3   := .t.
Private cCombo, cOrdem	:= " "
//Private aOrdem	:= {"PEDIDO","CLIENTE"}
Private aOrdem		:= {"GERENTE","COORDENADOR","REPRESENTANTE","PEDIDO","CLIENTE"}
Private cPESQUISA:= SPACE(200), oPesquisa
Private _aMarcados:={}
Private TRB := CriaTrab(Nil,.F.)
Private _aCpoBrw
Private _aCpoTmp
Private _acores := {}
Private bped := nil
Public cChama := "1"


Do while cChama == "1"

	
	Processa( {|| AOMS015P2() } , 'Aguarde...' , "Recarregando Tabela..." ) //Prepara dados para a tela
	cChama := "2"//Para sair no X
	@ aSize[7]/*000*/,000 TO aSize[6]/*650*/,aSize[5]/*935*/ DIALOG oDlgLib TITLE " Libera��o de Pedidos Protheus com bloqueio/rejei��o Pre�o "  

	oMark:=MsSelect():New("TMP","","OK",_aCpoBrw,@lInverte,@cMarca,{040,005,aSize[4]-_nMSS,aSize[3]},,,,,_aCores)//{015,005,400,630,565}
	oMark:oBrowse:lHasMark := .T.
	oMark:oBrowse:lCanAllMark:=.T.

	@ 003,006 To 034,315 Title " Pedido "
	@ 016,015 Say "Ordem: "
	@ 015,037 ComboBox cOrdem ITEMS aOrdem SIZE 50,_nAltCombo Object oOrdem
	@ 015,099 Get    cPESQUISA			   Size 180,10 Object oPesquisa
	oOrdem:bChange := {|| AOMS015FO(CORDEM),oMark:oBrowse:Refresh(.T.)}

	@ 016,350 Button "Pesquisar"       	Size 40,13	Action AOMS015P(CORDEM)
	@ aSize[4]-_nLB,295 Button "Legenda"	Size 40,13	Action AOMS015C() 				Object oBtnRet

    If MV_PAR02 == 2
	   @ aSize[4]-_nLB,340 Button "Visualizar"	Size 40,13	Action U_AOMS015X(TMP->NUMPED)	Object oBtnRet
	   _nPosCol := 0
    EndIf 

	@ aSize[4]-_nLB,385 - _nPosCol Button "Avaliar"	Size 40,13	Action AOMS0159(2)				Object oBtnRet
	@ aSize[4]-_nLB,430 - _nPosCol Button "Sair"		Size 40,13	Action AOMS0158()				Object oBtnInv

	dbSelectArea("TMP")
	TMP->( dbGoTop() )

	While !TMP->(EOF())

		RecLock("TMP",.f.)
		TMP->OK    := ThisMark()
		TMP->(MsUnlock())
		TMP->(dbSkip())

	End

	TMP->( dbGoTop() )

	oMark:oBrowse:Refresh()

	ACTIVATE DIALOG oDlgLib CENTERED

	Dbselectarea("TMP")
	TMP->(Dbclosearea())

Enddo


Return

/*
===============================================================================================================================
Programa----------: AOMS015I
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Funcao que avalia os Pedido de Venda para classifica-lo corretamente na legenda.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015I()

Local _cRet
Local _aArea  := GetArea()

If TMP->( EOF() )

	Return("")

Endif

If TMP->BLPRC == 'B'

	_cRet := "1"

ElseIf TMP->BLPRC == 'L'

	_cRet := ""

ElseIf TMP->BLPRC == 'R'

	_cRet := "2"

EndIf

RestArea(_aArea)

Return(_cRet)

/*
===============================================================================================================================
Programa----------: AOMS015X
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Funcao que Visualiza Itens do(s) Pedido(s) de Venda 
===============================================================================================================================
Parametros--------: _CPED - NUMERO DO PEDIDO DE VENDA
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS015X(CPED)

Local _aArea		:= GetArea()									// Salva a area atual
Local _oDlgHist													// Tela do Historico

Local aOldSize:= aSize,S
Local aPosObj := AOMS015TT(200,200,.T.)
Local _nLarg  := aPosObj[2,3]
Local _nAlt   := aPosObj[2,4]

Private cObsMemo 	:= ""											// String com a descricao do MEMO

//=======================================================================================
//Seleciona todas a ligacoes desse cliente indexando por ordem de liga�ao decrescente
//=======================================================================================

aLigacoes := {}
aCC       := {}
LCOORD := .F.

DbSelectArea("SC6")
SC6->( DBSETORDER(1) )
SC6->( DBSEEK(xFilial("SC6")+ALLTRIM(CPED),.T.) )

While SC6->( !Eof() ) .AND. SC6->C6_NUM == ALLTRIM(CPED)
	
	AAdd(aCC, {	SC6->C6_FILIAL,;
					SC6->C6_NUM,;
					SC6->C6_ITEM,;
					SC6->C6_PRODUTO,;
					GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SC6->C6_PRODUTO,1,""),;
					SC6->C6_UM,;
					Transform(SC6->C6_QTDVEN,"@E 999,999,999"),;
					Transform(SC6->C6_PRCVEN, "@E 999,999,999.99"),;
					Transform(SC6->C6_QTDVEN*SC6->C6_PRCVEN, "@E 999,999,999.99"),;
					SC6->C6_LOCAL,;
					SC6->C6_CLI,;
					SC6->C6_LOJA,;
					Transform(SC6->C6_PRUNIT, "@E 999,999,999.99"),;
					Transform(SC6->C6_VALDESC, "@E 999,999,999.99"),;
					SC6->C6_TES,;
					SC6->C6_CF})
	
	SC6->(DbSkip())
	
End

aLigacoes := ASort(aCC,,,{|x,y|x[2]<y[2]})

If Len(aLigacoes) <= 0

	Help(" ",1,"SEMDADOS" )
	CursorArrow()
	Return(.F.)

Endif

SC5->( DBSETORDER(1) )
SC5->( DBSEEK(xFilial("SC5")+ALLTRIM(CPED),.T.) )
DbSelectArea("SC5")
FOR S := 1 TO FCount()
    M->&(FIELDNAME(S)) := FieldGet(S)
NEXT
aRotina:={}
aADD(aRotina,{ "Visualizar","Auxiliar",0,2})

DEFINE MSDIALOG _oDlgHist FROM aSize[7],000 TO aSize[6],aSize[5] TITLE "Itens do Pedido Protheus de n�mero  " + CPED  PIXEL  //"Historico" //750SC5->C5_NUM

oMsMGet:=MsMGet():New("SC5", SC5->(RECNO()) , 1 ,,,,, aPosObj[1] , , 3, , , , , ,.F. )

@ aPosObj[2,1] ,aPosObj[2,2] LISTBOX oLbx FIELDS HEADER 	"Blq.Pre�o",;//08,05
										"Filial",;
										"Num. Pedido",;
										"Item","Produto",;
										"Descri��o",;
										"UM",;
										"Qtd Vend.",;
										"Prc. Vend.",;
										"Total",;
										"Armazem",;
										"Cliente",;
										"Loja",;
										"Prc. Unit.",;
										"Vlr. Desc.",;
										"TES",;
										"CFOP";
SIZE _nLarg,_nAlt OF _oDlgHist PIXEL //365

oLbx:SetArray(aLigacoes)
oLbx:bLine:={||{	aLigacoes[oLbx:nAt,1],;
					aLigacoes[oLbx:nAt,2],;
					aLigacoes[oLbx:nAt,3],;
					aLigacoes[oLbx:nAt,4],;
					aLigacoes[oLbx:nAt,5],;
					aLigacoes[oLbx:nAt,6],;
					aLigacoes[oLbx:nAt,7],;
					aLigacoes[oLbx:nAt,8],;
					aLigacoes[oLbx:nAt,9]}}

oLbx:Refresh()
oLbx:SetFocus(.T.)

//DEFINE SBUTTON FROM aSize[4]-02,aSize[3]-40 TYPE 02 ENABLE OF _oDlgHist PIXEL ACTION (_oDlgHist:End())

ACTIVATE MSDIALOG _oDlgHist CENTER ON INIT EnchoiceBar(_oDlgHist,{|| _oDlgHist:End()},{|| _oDlgHist:End()})

RestArea(_aArea)

aSize:=aOldSize

Return

/*
===============================================================================================================================
Programa----------: AOMS015C
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Fun��o utilizada no bot�o de legenda mostrar o significado de cada cor	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015C()

Local _cCadastro:=OemToAnsi("Pedido")

BrwLegenda(_cCadastro,"Legenda",{	{"BR_VERMELHO","Pedido Com Pre�o Bloqueado"},;
										{"BR_CINZA","Pedido Com Pre�o Rejei��o"}})

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS015R
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Tela do pedido de Venda chamada a partir do bot�o Avalia na tela principal		
===============================================================================================================================
Parametros--------: _cped - Numero do pedido
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS015R(CPED)

Local _cnomefil	:= ""
Local _ccodcomp	:= ""
Local _aVlrDesc  	:= {}

// Variaveis para GetDados()
Private aCols		:= {}
Private aHeader	:= {}
Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE" )

aLigacoes := {}
aCC       := {}
LCOORD := .F.

DbSelectArea("SC6")
SC6->( DBSETORDER(1) )
SC6->( DBSEEK(xFilial("SC6")+ALLTRIM(CPED),.T.) )

SC5->( DBSETORDER(1) )
SC5->( DBSEEK(xFilial("SC5")+ALLTRIM(CPED)) )

nQtd2UM := 0
nPrcMax := 0

DA1->(Dbsetorder(1))

While !Eof() .AND. SC6->C6_NUM == ALLTRIM(CPED)

/*
	_aTab	:= u_ittabprc( IIF(EMPTY(SC5->C5_FILGCT),SC5->C5_FILIAL,C5_FILGCT), IIF(EMPTY(SC5->C5_I_FILFT),SC5->C5_FILIAL,SC5->C5_I_FILFT),;
									SC5->C5_VEND3,SC5->C5_VEND2,SC5->C5_VEND1,SC5->C5_CLIENTE,SC5->C5_LOJACLI,.T.,SC5->C5_I_TAB,SC5->C5_VEND4,SC5->C5_I_GRPVE)
	_ctab := _atab[1]
	

	_atabs	:= u_ittabprc( IIF(EMPTY(SC5->C5_FILGCT),SC5->C5_FILIAL,C5_FILGCT), IIF(EMPTY(SC5->C5_I_FILFT),SC5->C5_FILIAL,SC5->C5_I_FILFT),;
									SC5->C5_VEND3,SC5->C5_VEND2,SC5->C5_VEND1,SC5->C5_CLIENTE,SC5->C5_LOJACLI,.T.,SC5->C5_I_TAB,SC5->C5_VEND4,SC5->C5_I_GRPVE)

	_ctabs := _atabs[1]
*/
    _nPrcMin:=9999
	_nPrcTabela:=0
	_nPesoFaixa:=0
	If DA1->(Dbseek(xFilial("DA1")+SC5->C5_I_TAB+SC6->C6_PRODUTO))

		_nPesoFaixa := SC6->C6_I_FXPES

		If _nPesoFaixa == 3
			_nPrcTabela := DA1->DA1_I_PRF3
			_nPrcMin    := DA1->DA1_I_PMF3 
		ElseIf _nPesoFaixa == 2
			_nPrcTabela := DA1->DA1_I_PRF2
			_nPrcMin    := DA1->DA1_I_PMF2
		else
			_nPrcTabela := DA1->DA1_I_PRF1						
			_nPrcMin    := DA1->DA1_I_PMF1
		ENDIF					

	ENDIF
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + SC6->C6_PRODUTO)

 	nFator  := SB1->B1_CONV 
	cTipConv:= SB1->B1_TIPCONV
	nNewFat := SB1->B1_I_FATCO 
	
	nFator := (If(nFator == 0, nNewFat, nFator))
	
	If cTipConv == 'D'
	
		nQtd2UM := SC6->C6_QTDVEN/nFator
	
	ElseIf cTipConv == 'M'
	
	 	nQtd2UM := SC6->C6_QTDVEN*nFator
	
	EndIf
	 
	//Puxa dados de desconto contratual
	_aVlrDesc := U_veriContrato( SC6->C6_CLI , SC6->C6_LOJA , SC6->C6_PRODUTO ) 
	 	
	AAdd(aCC, {		SC6->C6_ITEM,;
					alltrim(SC6->C6_PRODUTO),;
					alltrim(substr(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SC6->C6_PRODUTO,1,""),1,40)),;
					Transform(SC6->C6_QTDVEN,"@E 999,999") + " " + alltrim(SC6->C6_UM),;
					Transform(nQtd2UM,"@E 99,999") + " " + 	GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+SC6->C6_PRODUTO,1,""),;
					Transform(SC6->C6_PRCVEN, "@E 9,999.99"),;
					Transform(_aVlrDesc[1], "@E 99.99"),;
					Transform(SC6->C6_PRCVEN - ( SC6->C6_PRCVEN * (_aVlrDesc[1] / 100 ) ) , "@E 9,999.99"),;
					Transform(_nPrcMin, "@E 9,999.99") + "   --->" + Transform(_nPrcTabela, "@E 9,999.99"),;
					Transform(_nPrcMin, "@E 9,999.99") + "   --->" + Transform(_nPrcTabela, "@E 9,999.99"),;
					Transform(SC6->C6_QTDVEN*SC6->C6_PRCVEN, "@E 999,999.99"),;
					IF(SC6->C6_PRCVEN < _nPrcMin .OR. SC6->C6_PRCVEN > _nPrcTabela,"B"," "),;
					IF(SC6->C6_PRCVEN < _nPrcMin .OR. SC6->C6_PRCVEN > _nPrcTabela,"B"," ")})
					
	SC6->( DbSkip() )
	
End

DbSelectArea("SC5")
SC5->( DBSETORDER(1) )
SC5->( DBSEEK(xFilial("SC5")+ALLTRIM(CPED),.T.) )

aLigacoes := ASort(aCC,,,{|x,y|x[1]<y[1]})

If Len(aLigacoes) <= 0

	Help(" ",1,"SEMDADOS" )
	CursorArrow()
	Return(.F.)
	
Endif
lClos := .F.
DEFINE MSDIALOG _oDlgHist FROM aSize[7],000 TO aSize[6],aSize[5] TITLE "Itens do Pedido " + CPED  PIXEL  //"Historico" //750SC5->C5_NUM

_cnomefil := alltrim(TMP->FILIAL) + " / " + FWFilialName(cEmpAnt,TMP->FILIAL)

If empty(TMP->FILFAT)

	_cnomefat := alltrim(TMP->FILIAL) + " / " + FWFilialName(cEmpAnt,TMP->FILIAL)
	
Else

	_cnomefat := alltrim(TMP->FILFAT) + " / " + FWFilialName(cEmpAnt,TMP->FILFAT)

Endif

If TMP->TROCANF = "S"

	_cnomefat := "Troca Nota - " + _cnomefat
	
Else

	_cnomefat := "Faturamento Direto - " + _cnomefat

Endif

@ 005,005 Say "Pedido:" 
@ 005,045 Get TMP->NUMPED Picture "@!"  SIZE 050,10 when .f. 
@ 005,095 Get _cnomefil   Picture "@!"  SIZE 200,10 when .f. 

@ 005,330 Say "Filial Faturamento:" 
@ 005,375 Get _cnomefat   Picture "@!"  SIZE 200,10 when .f. 

@ 020,005 Say "Cliente:"

_ccodcomp := alltrim(SC5->C5_CLIENTE) + " / " + alltrim(SC5->C5_LOJACLI)

@ 020,045 Get _ccodcomp  Picture "@!"  SIZE 050,10 when .f. 
@ 020,095 Get AllTrim(GetAdvFval("SA1","A1_NOME",xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,1,"")) Picture "@!"  SIZE 200,10 when .f. 

@ 020,330 Say "Loja cliente: " 
@ 020,375 Get AllTrim(GetAdvFval("SA1","A1_NREDUZ",xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,1,"")) Picture "@!"  SIZE 200,10 when .f.

@ 035,005 Say "Representante:"
@ 035,045 Get SC5->C5_VEND1 Picture "@!"  SIZE 050,10 when .f. 
@ 035,095 Get AllTrim(GetAdvFval("SA3","A3_NOME",xFilial("SA3")+SC5->C5_VEND1,1,"")) Picture "@!"  SIZE 200,10 when .f.  

@ 050,005 Say "Supervisor:"
@ 050,045 Get SC5->C5_VEND4 Picture "@!"  SIZE 050,10 when .f. 
@ 050,095 Get AllTrim(GetAdvFval("SA3","A3_NOME",xFilial("SA3")+SC5->C5_VEND4,1,"")) Picture "@!"  SIZE 200,10 when .f.  

@ 065,005 Say "Coordenador:"
@ 065,045 Get SC5->C5_VEND2 Picture "@!"  SIZE 050,10 when .f. 
@ 065,095 Get AllTrim(GetAdvFval("SA3","A3_NOME",xFilial("SA3")+SC5->C5_VEND2,1,"")) Picture "@!"  SIZE 200,10 when .f.

@ 080,005 Say "Gerente:"
@ 080,045 Get SC5->C5_VEND3 Picture "@!"  SIZE 050,10 when .f. 
@ 080,095 Get AllTrim(GetAdvFval("SA3","A3_NOME",xFilial("SA3")+SC5->C5_VEND3,1,"")) Picture "@!"  SIZE 200,10 when .f.

_ctabela := SC5->C5_I_TAB + " - " + POSICIONE("DA0",1,xFilial("DA0")+SC5->C5_I_TAB ,'DA0_DESCRI') + " Faixa " + Str(_nPesoFaixa)
@ 065,330 Say "Tabela de pre�os padr�o:" 
@ 065,400 Get  _ctabela  Picture "@!"  SIZE 200,10 when .f. 

_ctabels := SC5->C5_I_TAB  + " - " + POSICIONE("DA0",1,xFilial("DA0")+SC5->C5_I_TAB ,'DA0_DESCRI') + " Faixa " + Str(_nPesoFaixa)
@ 080,330 Say "Tabela de pre�os simulador:" 
@ 080,400 Get  _ctabels  Picture "@!"  SIZE 200,10 when .f. 



@095,05 LISTBOX oLbx FIELDS HEADER 			"Item",;
											"Produto",;
											"Descri��o",;
											"Qtd 1�UM",;
											"Qtd 2�UM",;
											"Prc Vend",;
											"% Contrat.",;
											"Prc Net",;
											" ",;
											"Prcs Padrao",;
											" ",;
											"Prcs Simula",;
											"Total";
											SIZE aSize[3],aSize[4]-125 OF _oDlgHist PIXEL 

oLbx:SetArray(aLigacoes)			
oLbx:bLine:={||			{ aLigacoes[oLbx:nAt,1],;
						aLigacoes[oLbx:nAt,2],;
						aLigacoes[oLbx:nAt,3],;
						aLigacoes[oLbx:nAt,4],;
						aLigacoes[oLbx:nAt,5],;
						aLigacoes[oLbx:nAt,6],;
						aLigacoes[oLbx:nAt,7],;
						aLigacoes[oLbx:nAt,8],;
						If(aLigacoes[oLbx:nAt,12]='B',oVermelho,oVerde),;
						aLigacoes[oLbx:nAt,9],;
						If(aLigacoes[oLbx:nAt,13]='B',oVermelho,oVerde),;
						aLigacoes[oLbx:nAt,10],;
						aLigacoes[oLbx:nAt,11]}}

oLbx:Refresh()
oLbx:SetFocus(.T.)

@ aSize[4]-_nLB,aSize[3]-260	Button "Hist�rico"	Size 037,012 action ( AOMS015CP() )
@ aSize[4]-_nLB,aSize[3]-195	Button "Rejeitar"	Size 037,012 action (Iif(AOMS015E(2),(lClos := .T.,_oDlgHist:end()),.F.) )
@ aSize[4]-_nLB,aSize[3]-130	Button "Liberar"	Size 037,012 action (Iif(AOMS015E(1),(lClos := .T.,_oDlgHist:end()),.F.))
@ aSize[4]-_nLB,aSize[3]-65 	Button "&Sair" 		Size 037,012 action (lClos := .F.,_oDlgHist:end())

ACTIVATE MSDIALOG _oDlgHist CENTER ON INIT CursorArrow()

oMark:oBrowse:Refresh(.T.)

IF lClos 
   Close(oDlgLIb)
ENDIF

Return

/*
===============================================================================================================================
Programa----------: AOMS015E
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Fun��o chamada para a libera��o ou rejei��o de acordo com a chamada da mesma pelo seu respectivo bot�o	
===============================================================================================================================
Parametros--------: _ctipo - 1 Libera - 2 Bloqueia
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function AOMS015E(cTipo)

Local _ntotqtd 	:= 0
Local _ntotprc 	:= 0
Local _cmotivo 	:= space(100)
Local _nopc 		:= 0
Local _odlg		:= nil
Public lRetLib


Do while _nopc == 0 .or. ( empty(_cmotivo) .and. _nopc == 1) 

    _cmotivo:=IF(ctipo = 1, "Autorizado"+SPACE(100-LEN("Autorizado")) , SPACE(100) )

	DEFINE MSDIALOG _oDlg;
				 TITLE "Confirmar Motivo de " + iif(ctipo == 1, "libera��o", "rejei��o") + " do pedido " + ALLTRIM(TMP->NUMPED) + " - " + posicione("SA1",1,xfilial("SA1")+TMP->CODCLI,"A1_NOME");
				 FROM 000,000 TO 140,600 OF _oDlg PIXEL
	
	@ 006,008 SAY "Motivo de " + iif(ctipo == 1, "libera��o", "rejei��o") + " do pedido " + ALLTRIM(TMP->NUMPED) + " - " + posicione("SA1",1,xfilial("SA1")+TMP->CODCLI,"A1_NOME")	
	
	@ 020,008 GET _cmotivo PICTURE "@x"	SIZE 220,010 
	
	@ 040,230 BUTTON "&Ok"			SIZE 030,014 ACTION ( _nopc := 1, _oDlg:End() )
	@ 040,261 BUTTON "&Cancelar"	SIZE 030,014 ACTION ( _oDlg:End() )
	
	ACTIVATE MSDIALOG _oDlg CENTER

	If _nopc == 0

		Return .F.
	
	Elseif empty(_cmotivo)

		u_itmsg("Obrigat�rio informar o motivo.","Aten��o",,1)

	Endif
	
Enddo


IF cTipo == 1

	DbSelectArea("SC6")
	DBSETORDER(1)
	SC6->( DBSEEK(xFilial("SC6")+ALLTRIM(TMP->NUMPED),.T.) )		
	
	While SC6->(!EOF()) .And. SC6->C6_NUM == ALLTRIM(TMP->NUMPED)
	
 		_ntotqtd += SC6->C6_QTDVEN
 		_ntotprc += SC6->C6_PRCVEN
 		
 		Reclock("SC6",.F.)
   	 	SC6->C6_I_LIBPE := U_UCFG001(1) 
   	 	SC6->C6_I_BLPRC := "L" 
   	 	SC6->C6_I_LLIBP := SC6->C6_LOJA
   	 	SC6->C6_I_CLILP := SC6->C6_CLI
   	 	SC6->C6_I_VLIBP := SC6->C6_PRCVEN
   	 	SC6->C6_I_QTLIP := SC6->C6_QTDVEN
   	 	SC6->C6_I_MOTLP := _cmotivo
   	 	SC6->C6_I_PLIBP := DDATABASE + 30
   	 	SC6->C6_I_DLIBP := DDATABASE
    	SC6->(MsUnLock())
		SC6->(DbSkip())
	
	EndDo


	DbSelectArea("SC5")
	SC5->( DBSETORDER(1) )
	SC5->( DBSEEK(xFilial("SC5")+ALLTRIM(TMP->NUMPED),.T.) )	
	_cusernome := UsrFullName(__cUserID)	
	
	While SC5->(!EOF()) .And. SC5->C5_NUM == ALLTRIM(TMP->NUMPED)
	
 		Reclock("SC5",.F.)
   	 	SC5->C5_I_BLPRC := "L"
   	 	SC5->C5_I_DTLIP := dDataBase
   	 	SC5->C5_I_HLIBP := TIME()
   	 	SC5->C5_I_VLIBP := _ntotprc
   	 	SC5->C5_I_QLIBP := _ntotqtd
   	 	SC5->C5_I_CLILP := SC5->C5_CLIENTE
   	 	SC5->C5_I_LLIBP := SC5->C5_LOJACLI
   	 	SC5->C5_I_MOTLP := _cmotivo
   	 	SC5->C5_I_ULIBP := _cusernome
   	 	SC5->C5_I_MLIBP := U_UCFG001(1) 
   	 	SC5->C5_I_PLIBP := ddatabase + 30
   	 	
    	SC5->(MsUnLock())
    	
    	//==============================================================
		//Envia interface para o rdc com status do pedido
		//==============================================================
		If  SC5->C5_I_ENVRD == "S"

			U_ENVSITPV()   //Envia interface de altera��o de situa��o do pedido atual
    
		Endif
    	
		SC5->(DbSkip())
		
	EndDo
	
	
Else

	DbSelectArea("SC5")
	SC5->( DBSETORDER(1) )
	SC5->( DBSEEK(xFilial("SC5")+ALLTRIM(TMP->NUMPED),.T.) )		
	_cusernome := UsrFullName(__cUserID)
	 
	While SZW->(!EOF()) .And. SC5->C5_NUM == ALLTRIM(TMP->NUMPED)
	
 		Reclock("SC5",.F.)
   	 	SC5->C5_I_BLPRC := "R"
   	 	SC5->C5_I_DTLIB := dDataBase
   	 	SC5->C5_I_ULIBP := _cusernome
   	 	SC5->C5_I_MOTLP := _cmotivo
   	 	SC5->C5_I_MLIBP := U_UCFG001(1)
   	 	SC5->C5_I_DTLIP := dDataBase
   	 	SC5->C5_I_HLIBP := TIME() 
    	SC5->(MsUnLock())
    	
    	//==============================================================
		//Envia interface para o rdc com status do pedido
		//==============================================================
		If  SC5->C5_I_ENVRD == "S"

			U_ENVSITPV()   //Envia interface de altera��o de situa��o do pedido atual
    
		Endif
    	
		SC5->(DbSkip())
		
	EndDo	

	DbSelectArea("SC6")
	SC6->( DBSETORDER(1) )
	SC6->( DBSEEK(xFilial("SC6")+ALLTRIM(TMP->NUMPED),.T.) )		
	
	While SC6->(!EOF()) .And. SC6->C6_NUM == ALLTRIM(TMP->NUMPED)
	
 		Reclock("SC6",.F.)
   	 	SC6->C6_I_LIBPE := U_UCFG001(1)
   	 	SC6->C6_I_BLPRC := "R" 
    	SC6->(MsUnLock())
		SC6->(DbSkip())
		
	EndDo

EndIf

Return .T. 	

/*
===============================================================================================================================
Programa----------: AOMS0158
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Funcao que fecha a tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS0158()

Close(oDlgLIb)
cChama := "2"

Return

/*
===============================================================================================================================
Programa----------: AOMS0159
Autor-------------: Erich Buttner
Data da Criacao---: 18/03/2013
===============================================================================================================================
Descri��o---------: Fun��o que chama autoriza��o ou bloqueio do pedido
===============================================================================================================================
Parametros--------: __cBotao - 1 - avalia pedido do portal
							   2 - avalia pedido de vendas
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS0159(_cBotao)

Local _cMatric  := U_UCFG001(1) 
Local _cAutoriz := GetAdvFVal("ZZL","ZZL_APRPRC",xFilial("ZZL")+_cMatric,1,"")

//Mant�m browse aberto
cChama := "1"

If _cAutoriz == "S"
	
	If _cBotao == 1

		U_AOMS015W(TMP->FILIAL,TMP->NUMPED)  //Tela do pedido do portal chamada a partir do bot�o Avalia na tela principal

    Else

    	U_AOMS015R(TMP->NUMPED) //Tela do pedido de Venda chamada a partir do bot�o Avalia na tela principal	

    EndIf	

Else

	u_itmsg("Voc� N�o Tem Autoriza��o Para Efetuar a Libera��o/Rejei��o do Pre�o","Aten��o",,1)

EndIf

Return	

/*
===============================================================================================================================
Programa----------: AOMS015PP
Autor-------------: Josu� Danich
Data da Criacao---: 08/04/2016
===============================================================================================================================
Descri��o---------: Prepara dados para tela para pedidos do portal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015PP()
Local _cVend1, _cVend2, _cVend3, _cVend4

Procregua(3)

Incproc("")
Incproc("Carregando pedidos do portal...")

//========================================
// Monta Query 
//========================================

cQuery := " SELECT 	ZW_FILIAL FILIAL,"
cQuery += " 			ZW_TIPO TIPO,"
cQuery += " 			ZW_CLIENTE CODCLI,"	
cQuery += " 			ZW_LOJACLI LOJA,"
cQuery += " 			ZW_CLIENT CODCLIENT,"
cQuery += " 			ZW_LOJAENT LOJAENT, "
cQuery += " 			ZW_TIPOCLI TIPOCLI,"
cQuery += " 			ZW_CONDPAG CONDPAGTO,"
cQuery += " 			ZW_VEND1 VEND1,"
cQuery += " 			ZW_VEND2 VEND2,"
cQuery += " 			ZW_VEND3 VEND3,"	
cQuery += " 			ZW_VEND4 VEND4,"
cQuery += " 			SUM(ZW_DESC1) DESC1,"
cQuery += " 			SUM(ZW_DESC2) DESC2,"
cQuery += " 			SUM(ZW_DESC3) DESC3,"
cQuery += " 			SUM(ZW_DESC4) DESC4,"
cQuery += " 			ZW_TABELA TAB_PREC,"
cQuery += " 			ZW_EMISSAO DTEMISS,"
cQuery += " 			ZW_TPFRETE TPFRETE," 
cQuery += " 			ZW_TRANSP TRANSP,"
cQuery += " 			ZW_DESPESA DESPESA,"
cQuery += " 			ZW_MENNOTA MENSANF,"
cQuery += " 			ZW_TIPCAR TPCAR,"
cQuery += " 			ZW_OBSCOM OBSCOMER,"
cQuery += " 			ZW_HOREN HORAENTR,"
cQuery += " 			ZW_SENHA SENHA,"
cQuery += " 			ZW_FECENT DT_ENTREG,"
cQuery += " 			ZW_EVENTO EVENTO,"
cQuery += " 			ZW_STATUS STAT_ZW,"
cQuery += "             CASE 
cQuery += "					WHEN ZW_FILPRO = '0 '  THEN '  '
cQuery += "					ELSE ZW_FILPRO
cQuery += "				END AS FILPRO, 			
cQuery += " 			ZW_IDPED NUMPED,"
cQuery += " 			ZW_ENVWF BLOPRC"
cQuery += " FROM SZW010 "
cQuery += " WHERE ZW_STATUS IN ('L','P','Q') "
cQuery += " 			AND "+Iif (MV_PAR02 == 1,"ZW_BLOPRC = 'R'", Iif(MV_PAR02 == 2,"ZW_BLOPRC = 'B'", "(ZW_BLOPRC = 'R' OR ZW_BLOPRC = 'B')"))
cQuery += " 			AND D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY ZW_FILIAL,"
cQuery += " 			ZW_TIPO,"
cQuery += " 			ZW_CLIENTE,"
cQuery += " 			ZW_LOJACLI,"
cQuery += " 			ZW_CLIENT,"
cQuery += " 			ZW_LOJAENT,"
cQuery += " 			ZW_TIPOCLI,"
cQuery += " 			ZW_CONDPAG,"
cQuery += " 			ZW_VEND1,"
cQuery += " 			ZW_VEND2," 
cQuery += " 			ZW_VEND3,"
cQuery += " 			ZW_VEND4,"
cQuery += " 			ZW_TABELA,"
cQuery += " 			ZW_EMISSAO,"
cQuery += " 			ZW_TPFRETE,"
cQuery += " 			ZW_TRANSP,"
cQuery += " 			ZW_DESPESA,"
cQuery += " 			ZW_MENNOTA,"
cQuery += " 			ZW_TIPCAR,"
cQuery += " 			ZW_OBSCOM,"
cQuery += " 			ZW_HOREN,"
cQuery += " 			ZW_SENHA,"
cQuery += " 			ZW_FECENT,"
cQuery += " 			ZW_EVENTO,"
cQuery += " 			ZW_STATUS,"
cQuery += " 			ZW_FILPRO,"
cQuery += " 			ZW_IDPED, ZW_ENVWF "

cQuery := ChangeQuery(cQuery)
//========================================
// Fecha Alias se estiver em Uso 
//========================================
If Select("TRB") >0

	dbSelectArea("TRB")
	dbCloseArea()
	Endif
	If Select("TMP") >0
		dbSelectArea("TMP")
	dbCloseArea()

Endif

//================================================
// Monta Area de Trabalho executando a Query 
//================================================
TCQUERY cQuery New Alias "TRB"
dbSelectArea("TRB")
dbGoTop()
//================================================
// Monta arquivo temporario 
//================================================

Incproc("Montando arquivo temporario...")

_aCpoTmp:={}

aAdd(_aCpoTmp,{"OK"				,"C",01,0})
aAdd(_aCpoTmp,{"FILIAL"			,"C",02,0})
aAdd(_aCpoTmp,{"FILPRO"			,"C",02,0})
aAdd(_aCpoTmp,{"NUMPED"			,"C",25,0})
aAdd(_aCpoTmp,{"TIPO"			,"C",01,0})
aAdd(_aCpoTmp,{"CODCLI"			,"C",06,0})
aAdd(_aCpoTmp,{"LOJA"			,"C",04,0})
aAdd(_aCpoTmp,{"CODCLIENT"		,"C",06,0})
aAdd(_aCpoTmp,{"LOJAENT"		,"C",04,0})

aAdd(_aCpoTmp,{"RAZAOSOC"       ,"C",060,0})  
aAdd(_aCpoTmp,{"NREDUZ"	        ,"C",020,0})  


aAdd(_aCpoTmp,{"TIPOCLI"		,"C",01,0})
aAdd(_aCpoTmp,{"CONDPAGTO"		,"C",03,0})
aAdd(_aCpoTmp,{"VEND1"      	,"C",06,0})
aAdd(_aCpoTmp,{"NOMEVEND1"     	,"C",40,0}) 
aAdd(_aCpoTmp,{"VEND2"      	,"C",06,0})
aAdd(_aCpoTmp,{"NOMEVEND2"     	,"C",40,0}) 
aAdd(_aCpoTmp,{"VEND3"      	,"C",06,0})
aAdd(_aCpoTmp,{"NOMEVEND3"     	,"C",40,0}) 
aAdd(_aCpoTmp,{"VEND4"      	,"C",06,0})
aAdd(_aCpoTmp,{"NOMEVEND4"     	,"C",40,0}) 
aAdd(_aCpoTmp,{"DESC1"      	,"N",14,2})
aAdd(_aCpoTmp,{"DESC2"      	,"N",14,2})
aAdd(_aCpoTmp,{"DESC3"      	,"N",14,2})
aAdd(_aCpoTmp,{"DESC4"      	,"N",14,2})
aAdd(_aCpoTmp,{"TAB_PREC"		,"C",03,0})
aAdd(_aCpoTmp,{"DTEMISS"    	,"C",10,0})
aAdd(_aCpoTmp,{"TPFRETE"    	,"C",01,0})
aAdd(_aCpoTmp,{"TRANSP"			,"C",06,0})
aAdd(_aCpoTmp,{"DESPESA"    	,"N",14,2})
aAdd(_aCpoTmp,{"MENSANF"    	,"C",120,0})
aAdd(_aCpoTmp,{"TPCAR"      	,"C",01,0})
aAdd(_aCpoTmp,{"OBSCOMER"   	,"C",120,0})
aAdd(_aCpoTmp,{"HORAENTR"   	,"C",05,0})
aAdd(_aCpoTmp,{"SENHA"      	,"C",14,0})
aAdd(_aCpoTmp,{"DT_ENTREG"  	,"C",10,0})
aAdd(_aCpoTmp,{"EVENTO"			,"C",06,0})
aAdd(_aCpoTmp,{"STAT_ZW"    	,"C",02,0})
aAdd(_aCpoTmp,{"BLOPRC"     	,"C",01,0})

_otemp := FWTemporaryTable():New( "TMP", _aCpoTmp )

_otemp:AddIndex( "01", {"VEND3","VEND2","VEND1"} ) // GERENTE/COORDENADOR/VENDEDOR
_otemp:AddIndex( "02", {"VEND2","VEND3","VEND1"} ) // COORDENADOR/GERENTE/VENDEDOR
_otemp:AddIndex( "03", {"VEND1","VEND3","VEND2"} ) // VENDEDOR/GERENTE/COORDENADOR
_otemp:AddIndex( "04", {"NUMPED"} ) // NUMERO PEDIDO
_otemp:AddIndex( "05", {"CODCLI"} ) // CODIGO DO CLIENTE

_otemp:Create()

//================================================
// Alimenta arquivo temporario 
//================================================
SA3->(DBSetOrder(1))

dbSelectArea("TMP")
While !TRB->(EOF())
    SA3->(DbSeek(xFilial("SA3")+TRB->VEND1))
    _cVend1 := TRB->VEND1     // REPRESENTANTE
	_cVend2 := SA3->A3_SUPER  // COORDENADOR
	_cVend3 := SA3->A3_GEREN  // GERENTE
	_cVend4 := SA3->A3_I_SUPE // SUPERVISOR 
	
	If ! Empty(TRB->VEND2)
       _cVend2 := TRB->VEND2
    EndIf 

	If ! Empty(TRB->VEND3)
       _cVend3 := TRB->VEND3
    EndIf 

	If ! Empty(TRB->VEND4)
       _cVend4 := TRB->VEND4
    EndIf 

	DbSelectArea("TMP")
	RecLock("TMP",.t.)
	TMP->OK			    := ""
	TMP->FILIAL 		:= TRB->FILIAL
	TMP->FILPRO 		:= TRB->FILPRO
	TMP->NUMPED 		:= TRB->NUMPED
	TMP->TIPO   		:= TRB->TIPO
	TMP->CODCLI 		:= TRB->CODCLI
	TMP->LOJA 			:= TRB->LOJA
	TMP->CODCLIENT	    := TRB->CODCLIENT
	TMP->LOJAENT		:= TRB->LOJAENT
	TMP->TIPOCLI		:= TRB->TIPOCLI
	TMP->CONDPAGTO	    := TRB->CONDPAGTO
    TMP->VEND1 		    := TRB->VEND1
	TMP->NOMEVEND1      := Posicione("SA3",1,xFilial("SA3")+_cVend1,"A3_NOME")  
	TMP->VEND2			:= _cVend2 // TRB->VEND2
	TMP->NOMEVEND2      := Posicione("SA3",1,xFilial("SA3")+_cVend2,"A3_NOME")
	TMP->VEND3			:= _cVend3 // TRB->VEND3
	TMP->NOMEVEND3      := Posicione("SA3",1,xFilial("SA3")+_cVend3,"A3_NOME")
	TMP->VEND4			:= _cVend4 // TRB->VEND4
	TMP->NOMEVEND4      := Posicione("SA3",1,xFilial("SA3")+_cVend4,"A3_NOME")
	TMP->DESC1			:= TRB->DESC1
	TMP->DESC2			:= TRB->DESC2
	TMP->DESC3			:= TRB->DESC3
	TMP->DESC4			:= TRB->DESC4
	TMP->TAB_PREC		:= TRB->TAB_PREC
	TMP->DTEMISS		:= SUBSTR(TRB->DTEMISS,7,2)+"/"+SUBSTR(TRB->DTEMISS,5,2)+"/"+SUBSTR(TRB->DTEMISS,1,4)
	TMP->TPFRETE		:= TRB->TPFRETE
	TMP->TRANSP		    := TRB->TRANSP
	TMP->DESPESA		:= TRB->DESPESA
	TMP->MENSANF		:= TRB->MENSANF
	TMP->TPCAR			:= TRB->TPCAR
	TMP->OBSCOMER		:= TRB->OBSCOMER
	TMP->HORAENTR		:= TRB->HORAENTR
	TMP->SENHA			:= TRB->SENHA
	TMP->DT_ENTREG	    := SUBSTR(TRB->DT_ENTREG,7,2)+"/"+SUBSTR(TRB->DT_ENTREG,5,2)+"/"+SUBSTR(TRB->DT_ENTREG,1,4)
	TMP->EVENTO		    := TRB->EVENTO
	TMP->STAT_ZW		:= TRB->STAT_ZW
	TMP->BLOPRC  		:= TRB->BLOPRC

	TMP->RAZAOSOC       := Posicione("SA1",1,xFilial("SA1")+TRB->CODCLI+TRB->LOJA,"A1_NOME")  
	TMP->NREDUZ         := Posicione("SA1",1,xFilial("SA1")+TRB->CODCLI+TRB->LOJA,"A1_NREDUZ") 


	TMP->(MsUnlock())
	DbSelectArea("TRB")
	TRB->( dbSkip() )

End
	
TRB->(dbCloseArea())

_aCores:={}

bped := {|| AOMS015O()} //monta v�riavel de legenda

AADD(_aCores,{'Eval(bped)==""' ,"BR_VERDE"})
AADD(_aCores,{'Eval(bped)=="1"',"BR_VERMELHO"})
AADD(_aCores,{'Eval(bped)=="2"',"BR_CINZA"})
AADD(_aCores,{'Eval(bped)=="4"',"BR_VERDE_ESCURO"})
AADD(_aCores,{'Eval(bped)=="5"',"BR_AMARELO"}) 



//================================================
// Array com definicoes dos campos do browse 
//================================================
_aCpoBrw:={}
aAdd(_aCpoBrw,{"BLOPRC"     	,""	,"Aguardando"     		,		            		,"02" ,"0"})
aAdd(_aCpoBrw,{"DTEMISS"    	,""	,"Dt. Emiss�o"     		,		            		,"08" ,"0"})
aAdd(_aCpoBrw,{"FILIAL"			,"" ,"Fil.Fat."	,"@!"						,"02" ,"0"})
aAdd(_aCpoBrw,{"FILPRO"			,"" ,"Fil.Car."	,"@!"						,"02" ,"0"})
aAdd(_aCpoBrw,{"NUMPED"    		,""	,"Pedido"     		,"@!"               		,"15" ,"0"})
//aAdd(_aCpoBrw,{"TIPO"    		,""	,"Tipo"         		,"@!"               		,"06" ,"0"})
aAdd(_aCpoBrw,{"CODCLI"    		,""	,"Cliente"         		,"@!"               		,"01" ,"0"})
aAdd(_aCpoBrw,{"LOJA"    		,""	,"Loja"         		,"@!"               		,"04" ,"0"})

aAdd(_aCpoBrw,{"RAZAOSOC"       ,""	,"Raz�o Social"   	    ,"@!"               		,"60" ,"0"}) 
aAdd(_aCpoBrw,{"NREDUZ"	        ,""	,"Nome Fantasia"   	    ,"@!"	            		,"20" ,"0"}) 

//aAdd(_aCpoBrw,{"CODCLIENT"  	,""	,"Cliente Entr."   		,"@!"               		,"06" ,"0"})
//aAdd(_aCpoBrw,{"LOJAENT"		,""	,"Loja Entrega"     	,"@!"	            		,"04" ,"0"})
//aAdd(_aCpoBrw,{"TIPOCLI"  		,""	,"Tp. Cliente"    		,"@!"               		,"01" ,"0"})
aAdd(_aCpoBrw,{"CONDPAGTO"  	,""	,"Cond. Pagto."    		,"@!"						,"03" ,"0"})
aAdd(_aCpoBrw,{"VEND1" 		    ,""	,"C�d.Repr."       	,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND1 "     ,""	,"Nome Repr"         	,"@!"						,"30" ,"0"})
aAdd(_aCpoBrw,{"VEND2" 		    ,""	,"Coord."       	,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND2 "     ,""	,"Nome Coord"       	,"@!"						,"30" ,"0"})
aAdd(_aCpoBrw,{"VEND3" 		    ,""	,"Geren."       	    ,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND3 "     ,""	,"Nome Ger"       	    ,"@!"						,"30" ,"0"})
aAdd(_aCpoBrw,{"VEND4" 		    ,""	,"Super."       	,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND4 "     ,""	,"Nome Sup"         	,"@!"						,"30" ,"0"})
//aAdd(_aCpoBrw,{"DESC1"			,""	,"Desconto1"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
//aAdd(_aCpoBrw,{"DESC2"			,""	,"Desconto2"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
//aAdd(_aCpoBrw,{"DESC3"			,""	,"Desconto3"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
//aAdd(_aCpoBrw,{"DESC4"			,""	,"Desconto4"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
aAdd(_aCpoBrw,{"TAB_PREC"   	,""	,"Tabela Pre�o"    		,"@!"						,"03" ,"0"})
aAdd(_aCpoBrw,{"TPFRETE"		,""	,"Tp. Frete"	  		,"@!"               		,"06" ,"0"})
//aAdd(_aCpoBrw,{"DESPESA"		,""	,"Despesa"         		,"@E 9999,999,999.99"	    ,"02" ,"0"})
aAdd(_aCpoBrw,{"MENSANF"    	,""	,"Mens. NF"       		,"@!"               		,"120","0"})
aAdd(_aCpoBrw,{"TPCAR" 			,""	,"Tp. Carga"      		,"@!"               		,"01" ,"0"})
aAdd(_aCpoBrw,{"OBSCOMER"   	,""	,"Observ. Comercial"	,"@!"               		,"120","0"})
aAdd(_aCpoBrw,{"SENHA"   		,""	,"Senha"		 		,"@!"               		,"14" ,"0"})
aAdd(_aCpoBrw,{"DT_ENTREG"		,""	,"Dt. Entrega"	     	,		            		,"08" ,"0"})
aAdd(_aCpoBrw,{"EVENTO"   		,""	,"Evento"				,"@!"               		,"06" ,"0"})

Return

/*
===============================================================================================================================
Programa----------: AOMS015P2
Autor-------------: Josu� Danich
Data da Criacao---: 08/04/2016
===============================================================================================================================
Descri��o---------: Prepara dados para tela para pedido de vendas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS015P2()

Procregua(3)

Incproc("")
Incproc("Carregando pedidos de venda")

//==========================================
// Monta Query 
//==========================================
cQuery := " SELECT 	C5_FILIAL FILIAL,"
cQuery += " 			C5_TIPO TIPO,"
cQuery += " 			C5_CLIENTE CODCLI,"
cQuery += " 			C5_LOJACLI LOJA,"
cQuery += " 			C5_CLIENT CODCLIENT,"	
cQuery += " 			C5_LOJAENT LOJAENT,"
cQuery += " 			C5_TIPOCLI TIPOCLI,"
cQuery += " 			C5_CONDPAG CONDPAGTO,"	
cQuery += " 			C5_VEND1 VEND1,"
cQuery += " 			C5_VEND2 VEND2,"
cQuery += " 			C5_VEND3 VEND3,"
cQuery += " 			C5_VEND4 VEND4,"
cQuery += " 			SUM(C5_DESC1) DESC1,"
cQuery += " 			SUM(C5_DESC2) DESC2,"
cQuery += " 			SUM(C5_DESC3) DESC3,"
cQuery += " 			SUM(C5_DESC4) DESC4,"
cQuery += " 			C5_I_TAB TAB_PREC,"
cQuery += " 			C5_EMISSAO DTEMISS,"
cQuery += " 			C5_TPFRETE TPFRETE,"
cQuery += " 			C5_TRANSP TRANSP," 
cQuery += " 			C5_DESPESA DESPESA," 
cQuery += " 			C5_MENNOTA MENSANF," 
cQuery += " 			C5_TPCARGA TPCAR," 
cQuery += " 			C5_I_OBPED OBSCOMER," 
cQuery += " 			C5_I_HOREN HORAENTR," 
cQuery += " 			C5_I_SENHA SENHA," 
cQuery += " 			C5_FECENT DT_ENTREG," 
cQuery += " 			C5_NUM NUMPED," 
cQuery += " 			C5_I_TRCNF TROCANF," 
cQuery += " 			C5_I_FILFT FILFAT," 
cQuery += " 			C5_I_BLPRC BLPRC"
cQuery += " FROM SC5010 
cQuery += " WHERE " + Iif (MV_PAR02 == 1,"C5_I_BLPRC = 'R' ", Iif(MV_PAR02 == 2,"C5_I_BLPRC = 'B'", "(C5_I_BLPRC = 'R' OR C5_I_BLPRC = 'B')"))
cQuery += " 			AND D_E_L_E_T_ = ' ' 
cQuery += " 			AND C5_FILIAL = '"+xFilial("SC5")+"' 
cQuery += " GROUP BY C5_FILIAL,"
cQuery += " 			C5_TIPO,"
cQuery += " 			C5_CLIENTE,"
cQuery += " 			C5_LOJACLI,"
cQuery += " 			C5_CLIENT,"
cQuery += " 			C5_LOJAENT,"
cQuery += " 			C5_TIPOCLI,"
cQuery += " 			C5_CONDPAG,"
cQuery += " 			C5_VEND1,"
cQuery += " 			C5_VEND2,"
cQuery += " 			C5_VEND3,"
cQuery += " 			C5_VEND4,"
cQuery += " 			C5_I_TAB,"
cQuery += " 			C5_EMISSAO,"
cQuery += " 			C5_TPFRETE,"
cQuery += " 			C5_TRANSP,"
cQuery += " 			C5_DESPESA,"
cQuery += " 			C5_MENNOTA,"
cQuery += " 			C5_TPCARGA,"
cQuery += " 			C5_I_OBPED,"
cQuery += " 			C5_I_HOREN,"
cQuery += " 			C5_I_SENHA,"
cQuery += " 			C5_FECENT,"
cQuery += " 			C5_NUM,"
cQuery += " 			C5_I_TRCNF,"
cQuery += " 			C5_I_FILFT,"
cQuery += " 			C5_I_BLPRC"

cQuery := ChangeQuery(cQuery)
//==========================================
// Fecha Alias se estiver em Uso 
//==========================================
If Select("TRB") >0

	dbSelectArea("TRB")
	TRB->( dbCloseArea() )

Endif

If Select("TMP") >0

	dbSelectArea("TMP")
	TMP->( dbCloseArea() )

Endif


//==========================================
// Monta Area de Trabalho executando a Query 
//==========================================
TCQUERY cQuery New Alias "TRB"
dbSelectArea("TRB")

TRB->( dbGoTop() )

//==========================================
// Monta arquivo temporario 
//==========================================
_aCpoTmp:={}
aAdd(_aCpoTmp,{"OK"				,"C",001,0})
aAdd(_aCpoTmp,{"FILIAL"			,"C",002,0})
aAdd(_aCpoTmp,{"FILFAT"			,"C",002,0})
aAdd(_aCpoTmp,{"TROCANF"		,"C",001,0})
aAdd(_aCpoTmp,{"NUMPED"			,"C",025,0})
aAdd(_aCpoTmp,{"TIPO"			,"C",001,0})
aAdd(_aCpoTmp,{"CODCLI"			,"C",006,0})
aAdd(_aCpoTmp,{"LOJA"			,"C",004,0})
aAdd(_aCpoTmp,{"CODCLIENT"		,"C",006,0})
aAdd(_aCpoTmp,{"LOJAENT"		,"C",004,0})

aAdd(_aCpoTmp,{"RAZAOSOC"       ,"C",060,0})  
aAdd(_aCpoTmp,{"NREDUZ"	        ,"C",020,0})  

aAdd(_aCpoTmp,{"TIPOCLI"		,"C",001,0})
aAdd(_aCpoTmp,{"CONDPAGTO"		,"C",003,0})
aAdd(_aCpoTmp,{"VEND1"      	,"C",006,0})
aAdd(_aCpoTmp,{"NOMEVEND1"     	,"C",040,0}) 
aAdd(_aCpoTmp,{"VEND2"      	,"C",006,0})
aAdd(_aCpoTmp,{"NOMEVEND2"     	,"C",040,0}) 
aAdd(_aCpoTmp,{"VEND3"      	,"C",006,0})
aAdd(_aCpoTmp,{"NOMEVEND3"     	,"C",040,0}) 
aAdd(_aCpoTmp,{"VEND4"      	,"C",006,0})
aAdd(_aCpoTmp,{"NOMEVEND4"     	,"C",040,0}) 
aAdd(_aCpoTmp,{"DESC1"      	,"N",014,2})	
aAdd(_aCpoTmp,{"DESC2"      	,"N",014,2})
aAdd(_aCpoTmp,{"DESC3"      	,"N",014,2})
aAdd(_aCpoTmp,{"DESC4"      	,"N",014,2})
aAdd(_aCpoTmp,{"TAB_PREC"		,"C",003,0})
aAdd(_aCpoTmp,{"DTEMISS"    	,"C",010,0})
aAdd(_aCpoTmp,{"TPFRETE"    	,"C",001,0})
aAdd(_aCpoTmp,{"TRANSP"			,"C",006,0})
aAdd(_aCpoTmp,{"DESPESA"    	,"N",014,2})
aAdd(_aCpoTmp,{"MENSANF"    	,"C",120,0})
aAdd(_aCpoTmp,{"TPCAR"      	,"C",001,0})
aAdd(_aCpoTmp,{"OBSCOMER"   	,"C",120,0})
aAdd(_aCpoTmp,{"HORAENTR"   	,"C",005,0})
aAdd(_aCpoTmp,{"SENHA"      	,"C",014,0})
aAdd(_aCpoTmp,{"DT_ENTREG"  	,"C",010,0})
aAdd(_aCpoTmp,{"BLPRC"	  		,"C",001,0})

_otemp := FWTemporaryTable():New( "TMP", _aCpoTmp )

_otemp:AddIndex( "01", {"VEND3","VEND2","VEND1"} ) // GERENTE/COORDENADOR/VENDEDOR
_otemp:AddIndex( "02", {"VEND2","VEND3","VEND1"} ) // COORDENADOR/GERENTE/VENDEDOR
_otemp:AddIndex( "03", {"VEND1","VEND3","VEND2"} ) // VENDEDOR/GERENTE/COORDENADOR
_otemp:AddIndex( "04", {"NUMPED"} ) // NUMERO DO PEDIDO
_otemp:AddIndex( "05", {"CODCLI"} ) // CODIGO DO CLIENTE

_otemp:Create()

incproc("Carregando arquivo temporario...")

//==========================================
// Alimenta arquivo temporario 
//==========================================
dbSelectArea("TMP")

While !TRB->(EOF())
	
	DbSelectArea("TMP")
	RecLock("TMP",.t.)
	TMP->OK			:= ""
	TMP->FILIAL 		:= TRB->FILIAL
	TMP->FILFAT 		:= IIF(EMPTY(TRB->FILFAT),TRB->FILIAL,TRB->FILFAT)
	TMP->TROCANF 		:= IIF(TRB->TROCANF="S","S","N")
	TMP->NUMPED 		:= TRB->NUMPED
	TMP->TIPO   		:= TRB->TIPO
	TMP->CODCLI 		:= TRB->CODCLI
	TMP->LOJA 			:= TRB->LOJA
	TMP->CODCLIENT	    := TRB->CODCLIENT
	TMP->LOJAENT		:= TRB->LOJAENT
	TMP->TIPOCLI		:= TRB->TIPOCLI
	TMP->CONDPAGTO	    := TRB->CONDPAGTO
	TMP->VEND1 		    := TRB->VEND1
	TMP->NOMEVEND1      := Posicione("SA3",1,xFilial("SA3")+TRB->VEND1,"A3_NOME")
	TMP->VEND2			:= TRB->VEND2
	TMP->NOMEVEND2      := Posicione("SA3",1,xFilial("SA3")+TRB->VEND2,"A3_NOME")
	TMP->VEND3			:= TRB->VEND3
	TMP->NOMEVEND3      := Posicione("SA3",1,xFilial("SA3")+TRB->VEND3,"A3_NOME")
	TMP->VEND4			:= TRB->VEND4
	TMP->NOMEVEND4      := Posicione("SA3",1,xFilial("SA3")+TRB->VEND4,"A3_NOME")
	TMP->DESC1			:= TRB->DESC1
	TMP->DESC2			:= TRB->DESC2
	TMP->DESC3			:= TRB->DESC3
	TMP->DESC4			:= TRB->DESC4
	TMP->TAB_PREC		:= TRB->TAB_PREC
	TMP->DTEMISS		:= SUBSTR(TRB->DTEMISS,7,2)+"/"+SUBSTR(TRB->DTEMISS,5,2)+"/"+SUBSTR(TRB->DTEMISS,1,4)
	TMP->TPFRETE		:= TRB->TPFRETE
	TMP->TRANSP		    := TRB->TRANSP
	TMP->DESPESA		:= TRB->DESPESA
	TMP->MENSANF		:= TRB->MENSANF
	TMP->TPCAR			:= TRB->TPCAR
	TMP->OBSCOMER		:= TRB->OBSCOMER
	TMP->HORAENTR		:= TRB->HORAENTR
	TMP->SENHA			:= TRB->SENHA
	TMP->DT_ENTREG	    := SUBSTR(TRB->DT_ENTREG,7,2)+"/"+SUBSTR(TRB->DT_ENTREG,5,2)+"/"+SUBSTR(TRB->DT_ENTREG,1,4)
	TMP->BLPRC			:= TRB->BLPRC

	TMP->RAZAOSOC       := Posicione("SA1",1,xFilial("SA1")+TRB->CODCLI+TRB->LOJA,"A1_NOME")   
	TMP->NREDUZ         := Posicione("SA1",1,xFilial("SA1")+TRB->CODCLI+TRB->LOJA,"A1_NREDUZ") 

	TMP->(MsUnlock())
	DbSelectArea("TRB")
	TRB->( dbSkip() )
	
End

TRB->(dbCloseArea())

_aCores:={}
bped := {|| AOMS015I()} //Fun��o que carrega v�riavel com cores da legenda
AADD(_aCores,{'Eval(bped)==""' ,"BR_VERDE"})
AADD(_aCores,{'Eval(bped)=="1"',"BR_VERMELHO"})
AADD(_aCores,{'Eval(bped)=="2"',"BR_CINZA"})

//==========================================
// Array com definicoes dos campos do browse 
//==========================================

_aCpoBrw:={}
aAdd(_aCpoBrw,{"DTEMISS"    ,""	,"Dt. Emiss�o"       	,"@D"	            		,"08" ,"0"})
aAdd(_aCpoBrw,{"FILIAL"		,"" ,"Filial"				,"@!"						,"02" ,"0"})
aAdd(_aCpoBrw,{"FILFAT"		,"" ,"Filial Faturamento"	,"@!"						,"02" ,"0"})
aAdd(_aCpoBrw,{"TROCANF"	,"" ,"Troca Nota"			,"@!"						,"02" ,"0"})
aAdd(_aCpoBrw,{"NUMPED"    	,""	,"Num. Pedido"       	,"@!"               		,"25" ,"0"})
aAdd(_aCpoBrw,{"TIPO"    	,""	,"Tipo"         		,"@!"               		,"06" ,"0"})
aAdd(_aCpoBrw,{"CODCLI"    	,""	,"Cliente"          	,"@!"               		,"01" ,"0"})
aAdd(_aCpoBrw,{"LOJA"    	,""	,"Loja"         		,"@!"               		,"04" ,"0"}) 

aAdd(_aCpoBrw,{"RAZAOSOC"   ,""	,"Raz�o Social"   	    ,"@!"               		,"60" ,"0"})  
aAdd(_aCpoBrw,{"NREDUZ"	    ,""	,"Nome Fantasia"   	    ,"@!"	            		,"20" ,"0"})  

//aAdd(_aCpoBrw,{"CODCLIENT"  ,""	,"Cliente Entr."   	    ,"@!"               		,"06" ,"0"}) 
//aAdd(_aCpoBrw,{"LOJAENT"	,""	,"Loja Entrega"    	    ,"@!"	            		,"04" ,"0"})     

aAdd(_aCpoBrw,{"TIPOCLI"  	,""	,"Tp. Cliente"    	    ,"@!"               		,"01" ,"0"})
aAdd(_aCpoBrw,{"CONDPAGTO"  ,""	,"Cond. Pagto."    	    ,"@!"						,"03" ,"0"})
aAdd(_aCpoBrw,{"VEND1" 		,""	,"Representante"       	,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND1 " ,""	,"Nome Repr"         	,"@!"						,"30" ,"0"})
aAdd(_aCpoBrw,{"VEND2" 		,""	,"Coordenador"       	,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND2 " ,""	,"Nome Coord"       	,"@!"						,"30" ,"0"})
aAdd(_aCpoBrw,{"VEND3" 		,""	,"Gerente"       	    ,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND3 " ,""	,"Nome Ger"       	    ,"@!"						,"30" ,"0"})
aAdd(_aCpoBrw,{"VEND4" 		,""	,"Supervisor"       	,"@!"						,"06" ,"0"})
aAdd(_aCpoBrw,{"NOMEVEND4 " ,""	,"Nome Sup"         	,"@!"						,"30" ,"0"})
aAdd(_aCpoBrw,{"DESC1"		,""	,"Desconto1"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
aAdd(_aCpoBrw,{"DESC2"		,""	,"Desconto2"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
aAdd(_aCpoBrw,{"DESC3"		,""	,"Desconto3"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
aAdd(_aCpoBrw,{"DESC4"		,""	,"Desconto4"     		,"@E 9999,999,999.99"	    ,"14" ,"2"})
aAdd(_aCpoBrw,{"TAB_PREC"   ,""	,"Tabela Pre�o"    	    ,"@!"						,"03" ,"0"})
aAdd(_aCpoBrw,{"TPFRETE"	,""	,"Tp. Frete"	  		,"@!"               		,"06" ,"0"})
aAdd(_aCpoBrw,{"DESPESA"	,""	,"Despesa"         	    ,"@E 9999,999,999.99"	    ,"02" ,"0"})
aAdd(_aCpoBrw,{"MENSANF"    ,""	,"Mens. NF"       	    ,"@!"               		,"120","0"})
aAdd(_aCpoBrw,{"TPCAR" 		,""	,"Tp. Carga"      	    ,"@!"               		,"01" ,"0"})
aAdd(_aCpoBrw,{"OBSCOMER"   ,""	,"Observ. Comercial"	,"@!"               		,"120","0"})
aAdd(_aCpoBrw,{"SENHA"   	,""	,"Senha"		 		,"@!"               		,"14" ,"0"})
aAdd(_aCpoBrw,{"DT_ENTREG"	,""	,"Dt. Entrega"	        ,		            		,"08" ,"0"})

Return

/*
===============================================================================================================================
Programa----------: AOMS015CP(
Autor-------------: Josu� Danich
Data da Criacao---: 08/04/2016
===============================================================================================================================
Descri��o---------: Chama tela de consulta de hist�rico e refaz posicionamento de tabelas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
static function AOMS015CP()

Local _asc5 := SC5->( Getarea() )
Local _asa1 := SA1->( Getarea() )

U_COMS001( 'SC5' , TMP->( TMP->FILIAL + TMP->NUMPED ) )

SC5->( Restarea(_asc5) )
SA1->( Restarea(_asa1) )

DbSelectArea("SC5")
SC5->( DBSETORDER(1) )
SC5->( DBSEEK(TMP->FILIAL+TMP->NUMPED,.T.) )

Return

/*
===============================================================================================================================
Programa----------: AOMS015PESO
Autor-------------: Alex Wallauer
Data da Criacao---: 31/01/2022
===============================================================================================================================
Descri��o---------: Rotina para calcular o Peso Bruto para validar Pre�o por Faixa de Peso
===============================================================================================================================
Parametros--------: _cFilped,_cIdPed
===============================================================================================================================
Retorno-----------: _nPesBruTot
===============================================================================================================================
*/
Static Function AOMS015PESO(_cFilped,_cIdPed)
Local _nPesBruTot:= 0
Local _aAreaSZW	 := SZW->(GetArea())
SB1->(DbSetOrder(1))
IF SZW->(dbSeek(_cFilped+_cIdPed))
	DO WHILE SZW->(!EOF()  .AND. SZW->ZW_FILIAL == _cFilped .AND. SZW->ZW_IDPED == _cIdPed )
		SB1->(DbSeek(xfilial("SB1")+ SZW->ZW_PRODUTO))
		_nPesBruTot:=(SB1->B1_PESBRU * SZW->ZW_QTDVEN)
		SZW->(DBSKIP())
	ENDDO
ENDIF
RestArea(_aAreaSZW)
RETURN _nPesBruTot
