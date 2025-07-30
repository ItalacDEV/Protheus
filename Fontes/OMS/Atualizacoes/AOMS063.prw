/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 06/11/2018 | Validação planilha importação de metas de vendas - Chamado 26886 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 04/02/2019 | Correções de erro log com a utilização da função GDDeleted(). Chamado 27917.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 14/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "vKey.ch"
#INCLUDE "TOTVS.CH" 
#INCLUDE 'protheus.ch'

/*
===============================================================================================================================
Programa----------: AOMS063
Autor-------------: Erich Buttner
Data da Criacao---: 11/04/2013
===============================================================================================================================
Descrição---------: Cadastro de Previsão de Vendas	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063()

Private aCpoBrw:=nil
Private aCpoTmp
Private cArq
Private lInverte := .T.
Private cMarca   := GetMark()
Private oMark
Private cPesq     := Space(50)
Private lCheck1   := .t.
Private lCheck2   := .t.
Private lCheck3   := .t.
Private cOrdem	:= " "
Private aOrdem	:= {"ANO_MES","COORD/VEND","NOME_COORD/VEND"}
Private cPESQUISA:= SPACE(200), oPesquisa
Private _aMarcados:={}
Private TRB := getnextalias()
Public cAnoMes := ""
Public cCoord  := ""
Public cChama := ""
Private _cusername := UsrFullName(RetCodUsr())

Private _lVersao12:=(AllTrim( cVersao ) = "12")
Private _nAltCombo:=IF(_lVersao12,10,20)
Private _nLB      :=IF(_lVersao12,20,11)
Private _nMSS     :=IF(_lVersao12,24,15)


AOMS063TT()  // Prepara variaveis de tamanho de tela

cChama := "1"

Do while cChama != "5"

	fwmsgrun( ,{|| AOMS063U() }				, 'Aguarde!' , 'Carregando os dados...'  ) //Prepara acols
	
	//Grava Log de execução da rotina
	U_ITLOGACS()

    cChama := "5"
	@ aSize[7]/*000*/,000 TO aSize[6]/*650*/,aSize[5]/*935*/ DIALOG oDlgLib TITLE " Metas de Vendas "  //850,1135

  	oMark:=MsSelect():New("TMP","",,aCpoBrw,@lInverte,@cMarca,{040,005,aSize[4]-_nMSS,aSize[3]},,,,,)//{015,005,400,630,565}
  	oMark:oBrowse:lHasMark := .T.
  	oMark:oBrowse:lCanAllMark:=.T.

	@ 003,006 To 034,315 Title OemToAnsi("Pedido")
	@ 016,007 Say "Ordem: "
	@ 016,025 ComboBox cOrdem ITEMS aOrdem SIZE 60,50 Object oOrdem
	@ 016,085 Get    cPESQUISA			   Size 200,10 Object oPesquisa
  	oOrdem:bChange := {|| AOMS063FO(CORDEM),oMark:oBrowse:Refresh(.T.)}

	@ 015,330 Button "Pesquisar"       	Size 40,13	Action AOMS063PC(CORDEM)	Object oBtnRet
	@ 015,400 Button "Log"          	Size 40,13	Action AOMS063R()	Object oBtnRet

	@ aSize[4]-_nLB,160 Button "Exportar"	Size 40,13	Action AOMS063E()		Object oBtnRet
	@ aSize[4]-_nLB,205 Button "Importar"	Size 40,13	Action AOMS063K()		Object oBtnRet
	@ aSize[4]-_nLB,250 Button "Visualizar"	Size 40,13	Action AOMS063I()		Object oBtnRet
	@ aSize[4]-_nLB,295 Button "Incluir"	Size 40,13	Action AOMS063IM()		Object oBtnRet
	@ aSize[4]-_nLB,340 Button "Copiar"		Size 40,13	Action AOMS063Y()		Object oBtnRet
	@ aSize[4]-_nLB,385 Button "Replicar"  	Size 40,13	Action AOMS063Z()		Object oBtnRet
	@ aSize[4]-_nLB,430 Button "Alterar"	Size 40,13	Action AOMS063G()		Object oBtnRet	
	@ aSize[4]-_nLB,475 Button "Excluir"	Size 40,13	Action AOMS063N()		Object oBtnRet
	@ aSize[4]-_nLB,520 Button "Sair"		Size 40,13	Action AOMS063H()		Object oBtnRet


	ACTIVATE DIALOG oDlgLib CENTERED

Enddo

Return

/*
===============================================================================================================================
Programa----------: AOMS063PC
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Pesquisa Informações no Browse de acordo com a Ordem selecionada
===============================================================================================================================
Parametros--------: cOrdem - indice a ser usado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063PC(cOrdem)

DbSelectArea("TMP")

TMP->( DbSetOrder(Ascan(aOrdem,cOrdem)) )
TMP->( DbGoTop() )
TMP->( DbSeek(Alltrim(cPesquisa),.T.) )

oMark:oBrowse:Refresh(.T.)

Return

/*
===============================================================================================================================
Programa----------: AOMS063PC
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Funcao executada na saida do campo Ordem, para ordenar o browse
===============================================================================================================================
Parametros--------: cordem - indice a ser usado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063FO(cORDEM)

_nReg:=Recno()
cPesquisa:=Space(200)
oPesquisa:Refresh()

_aMarcados:={}
DbSelectArea("TMP")
TMP->(DbGoTop())

IF CORDEM == 'ANO_MES'
	While TMP->(!EOF())
		AADD(_aMarcados,{TMP->ANOMES})
		TMP->(DbSkip())
	End
ELSEIF CORDEM == 'COORD/VEND'
	While TMP->(!EOF())
		AADD(_aMarcados,{TMP->COORD})
		TMP->(DbSkip())
	End
ELSEIF CORDEM == 'NOME_COORD/VEND'
	While TMP->(!EOF())
		AADD(_aMarcados,{TMP->NMCOORD})
		TMP->(DbSkip())
	End
ENDIF

DbSelectArea("TMP")
DbSetOrder(Ascan(aOrdem,cOrdem))
DbGoTo(_nReg)     //Mantendo no mesmo registro que estava posicionado anteriormente
oMark:oBrowse:Refresh(.T.)

Return


/*
===============================================================================================================================
Programa----------: AOMS063TT
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Define tamanho da tela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aposobj - array com linhas e colunas
===============================================================================================================================
*/
Static Function AOMS063TT()

Public aSize           := {}
Public aObjects        := {}
Public aInfo           := {}
Public aPosObj		   := {}
// Obtém a a área de trabalho e tamanho da dialog

aSize := MsAdvSize()
AAdd( aObjects, { 000, 000, .T., .T. } ) // Dados da Enchoice
AAdd( aObjects, { 000, 000, .T., .T. } ) // Dados da getdados
// Dados da área de trabalho e separação
aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } // Chama MsObjSize e recebe array e tamanhos

aPosObj := MsObjSize( aInfo, aObjects,.T.)


Return aPosObj

/*
===============================================================================================================================
Programa----------: AOMS063IM
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Inclusão de Metas de Vendas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063IM()

Local cTitulo	:= "Inclusão de Metas de Vendas",_l
Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
Public nOpcx := 3

dbSelectArea("Sx3")
SX3->( dbSetOrder(1) )
SX3->( dbSeek("ZZS") )
nUsado:=0
aHeader:={}
aCols:={}

//Carrega aheader
aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM"}
FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )
	
//Limpa dois ultimos campos do aheader
asize(aheader,len(aheader)-2)


cAnoMes  	:= Space(06)
cCoord	 	:= Space(06)
cNmCoor 	:= Space(60)


aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.

AADD(aC,{"cAnoMes"	,{15,03} 	,"Ano/Mes"   	  		,"@!"   ,				,		,.T.	})
AADD(aC,{"cCoord"	,{15,65} 	,"Coord/Vend"  			,"@!"   ,"U_AOMS063V().And. (ExistCPO('SA3'))"	,"SA3"	,.T.	})
AADD(aC,{"cNmCoor"	,{15,140} 	,"Nome Coord/Vend"   	,"@!"   ,	,		,.F.	})

//================================================================
// Array com descricao dos campos do Rodape do Modelo 2         
//================================================================

aR:={}
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.

aButtons := {}
Aadd(aButtons,{"S4WB011N",	{||U_AOMS063D(cAnoMes,cCoord)},"Imp. Produtos","Imp. Produtos"})

//================================================================
// Array com coordenadas da GetDados no modelo2                 
//================================================================

aCGD:={60,06,26,74}
ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]} 

cLinhaOk:=   "U_AOMS063O()" // "ExecBlock('AOMS063O',.f.,.f.)"   
cTudoOk :="ExecBlock('AOMS063Z',.f.,.f.)"

//================================================================
// Chamada da Modelo2                                           
//================================================================
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
//		          cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ]aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ]
lRetMod2:=Modelo2(cTitulo,aC	,  aR	, aCGD	,nOpcx	,  cLinhaOk	,  cTudoOk ,	  ,		  ,		   		,  9999	,   ACORDW ,            ,    .T.      , aButtons  ) 

If lRetMod2 // Gravacao. . .
	nPosProd:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
	nPosDesc:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
	nPosDesD:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
	nPosUM	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'} )
	nPosQtd	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'} )
	nPos2UM	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'} )
	nPos2Qtd:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
	
	For _l := 1 To Len(aCols)

		If ! Atail(aCols[_l]) // aCols[_l,Len(aHeader)+1]  // alterar para len(aCols). 

			RecLock("ZZS",.T.)
			ZZS->ZZS_FILIAL	:= xFilial("ZZS")
			ZZS->ZZS_COD	:= aCols [_l,nPosProd]
			ZZS->ZZS_DESCR	:= aCols [_l,nPosDesc]
			ZZS->ZZS_DESCD	:= aCols [_l,nPosDesD]
			ZZS->ZZS_UM		:= aCols [_l,nPosUM]
			ZZS->ZZS_QTD   	:= aCols [_l,nPosQtd]
			ZZS->ZZS_2UM	:= aCols [_l,nPos2UM]
			ZZS->ZZS_QTD2UM	:= aCols [_l,nPos2Qtd]
			ZZS->ZZS_COOR	:= cCoord
			ZZS->ZZS_NMCOOR	:= cNmCoor
			ZZS->ZZS_ANOMES	:= cAnoMes
			ZZS->(MsUnLock())
			
			RecLock("ZGW",.T.)
			ZGW->ZGW_FILIAL	:= xFilial("ZGW")
			ZGW->ZGW_COD	:= aCols [_l,nPosProd]
			ZGW->ZGW_DESCR	:= aCols [_l,nPosDesc]
			ZGW->ZGW_DESCD	:= aCols [_l,nPosDesD]
			ZGW->ZGW_UM		:= aCols [_l,nPosUM]
			ZGW->ZGW_QTD   	:= aCols [_l,nPosQtd]
			ZGW->ZGW_2UM	:= aCols [_l,nPos2UM]
			ZGW->ZGW_QTD2UM	:= aCols [_l,nPos2Qtd]
			ZGW->ZGW_COOR	:= cCoord
			ZGW->ZGW_NMCOOR	:= cNmCoor
			ZGW->ZGW_ANOMES	:= cAnoMes
			ZGW->ZGW_OPER   := "INCLUSAO"
			ZGW->ZGW_USER   := _cusername
			ZGW->ZGW_DATA   := DATE()
			ZGW->ZGW_HORA   := TIME()
			ZGW->(MsUnLock())
			

		EndIf

	Next _l
	
	u_itmsg("Inclusão gravada com sucesso","Atenção",,2)

Endif

Close(oDlgLIb)
cchama := "" //Refaz a tela

Return .T.


/*
===============================================================================================================================
Programa----------: AOMS063W
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Importação de Produtos para Inclusão	
===============================================================================================================================
Parametros--------: cporc - Porcentagem de reajuste dos precos
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063W(cporc)

Local cPrd 		:= ""
Local TRB  		:= GetNextAlias()
Local aItens	:= {} 
Local nY,nX

cPrd := " SELECT D2_COD PRODUTO, B1_DESC DESCR, B1_I_DESCD DESCRDET," 
cPrd += " ROUND((SUM(D2_QUANT)/3)+((SUM(D2_QUANT)/3)* '"+ AllTrim(Str(cPorc))+ "'),2) QTDMEDIA1UM, " 
cPrd += " ROUND((SUM(D2_QTSEGUM)/3)+((SUM(D2_QTSEGUM)/3)* '"+AllTrim(Str(cPorc))+ "'),2) QTDMEDIA2UM," 
cPrd += " D2_UM UM, D2_SEGUM SEGUM "
cPrd += " FROM SD2010 SD2, SF2010 SF2, SB1010 SB1 "
cPrd += " WHERE SF2.F2_EMISSAO > '"+DTOS(DATE()-90)+"' "
cPrd += " AND SF2.D_E_L_E_T_ = ' ' "
cPrd += " AND SD2.D_E_L_E_T_ = ' ' "
cPrd += " AND SB1.D_E_L_E_T_ = ' ' "
cPrd += " AND SB1.B1_FILIAL = ' ' "
cPrd += " AND SD2.D2_COD = SB1.B1_COD "
cPrd += " AND SD2.D2_FILIAL = SF2.F2_FILIAL "
cPrd += " AND SD2.D2_DOC = SF2.F2_DOC "
cPrd += " AND SD2.D2_SERIE = SF2.F2_SERIE "
cPrd += " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
cPrd += " AND SD2.D2_LOJA = SF2.F2_LOJA "
cPrd += " AND SF2.F2_FORMUL = ' ' "
cPrd += " AND SF2.F2_TIPO = 'N' "
cPrd += " AND (SF2.F2_VEND2 = '"+ALLTRIM(cCoord)+"' OR SF2.F2_VEND1 = '"+ALLTRIM(cCoord)+"') "
cPrd += " AND SB1.B1_TIPO = 'PA' "
cPrd += " AND SB1.B1_MSBLQL = '2' "
cPrd += " GROUP BY D2_COD,B1_DESC, B1_I_DESCD, D2_UM, D2_SEGUM "
cPrd += " ORDER BY D2_COD "

cPrd := ChangeQuery(cPrd)

//=================================
// Fecha Alias se estiver em Uso 
//=================================
If Select("TRB") >0
	(TRB)->(dbCloseArea())
Endif

//==============================================
// Monta Area de Trabalho executando a Query 
//==============================================
TCQUERY cPrd New Alias "TRB"

(TRB)->(dbGoTop())

aCols		:= {} 

While TRB->(!Eof())
	
	cProd   := TRB->PRODUTO
	cDescr  := TRB->DESCR
	cDescrD := TRB->DESCRDET
	cUM		:= TRB->UM
	nQtd	:= TRB->QTDMEDIA1UM
	c2UM	:= TRB->SEGUM
	nQtd2um	:= TRB->QTDMEDIA2UM
	
	
	aAdd(aItens,{cProd,cDescr,cDescrD,cUM,nQtd,c2UM,nQtd2um})
	
	TRB->(DbSkip())

EndDo

FOR nX:= 1 TO Len(aItens)

	nPosProd 	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
	nPosDesc 	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
	nPosDesD 	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
	nPosUM	 	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'} )
	nPosQtd	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'} )
	nPos2UM	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'} )
	nPos2Qtd 	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
	
	aadd(aCOLS,Array(Len(aHeader)+1))
	For nY	:= 1 To Len(aHeader)
		aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
	Next nY
	
	N := Len(aCols)
   aCOLS[N][Len(aHeader)+1] := .F.
	
	aCols [N,nPosProd]	:= aItens[nX][1]
	aCols [N,nPosDesc]	:= GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+aItens[nX][1],1,"")//aItens[nX][2]
	aCols [N,nPosDesD]	:= GetAdvFVal("SB1","B1_I_DESCD",xFilial("SB1")+aItens[nX][1],1,"") //aItens[nX][3]
	aCols [N,nPosUM]		:= GetAdvFVal("SB1","B1_UM",xFilial("SB1")+aItens[nX][1],1,"")  //aItens[nX][4]
	aCols [N,nPosQtd]		:= aItens[nX][5]
	aCols [N,nPos2UM]		:= GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+aItens[nX][1],1,"")//aItens[nX][6]
	aCols [N,nPos2Qtd]	:= aItens[nX][7]
	
Next nX

xObj := CallMod2Obj()
xObj:oBrowse:Refresh()

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS063O
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Valida linha do acols
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063O()
Local I
Local nPosDesc 
Local nPosDesD 
Local nPosUM	 
Local nPos2UM	

lPrd := .F.
nPosProd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
n := Len(aCols)
cProd 	 := GetAdvFVal("SB1","B1_COD",xFilial("SB1")+aCols [n,nPosProd],1,"")
cbloq 	 := GetAdvFVal("SB1","B1_MSBLQL",xFilial("SB1")+aCols [n,nPosProd],1,"")

If cbloq == '1' .and. !Atail(aCols [n]) //GDDeleted(n)

	U_ITMSG("Produto Bloqueado","Atenção",,1)
	
	Return .F.
	
Endif

For I:= 1 To Len(aCols)-1

	If aCols [I,nPosProd] == cProd .and. I != n

		If!Atail(aCols [I+1]).And. !Atail(aCols[n]) // !GDDeleted(I+1).And. !GDDeleted(n)

			lPrd := .T.

		EndIf	

	EndIf	

Next I

If Empty(AllTrim(cProd)).And. !Atail(aCols[n]) // !GDDeleted(n)

	u_itmsg("Escolha um Produto Valido","Atenção",,1)
	LLINHA	:= .F.

Else

	LLINHA	:= .T.

EndIf

If lPrd 

	u_itmsg("Produto Existente. Escolha Outro Produto","Atenção",,1)
	LLINHA	:= .F.

EndIf

nPosQtd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'} )
nPos2Qtd:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )

nPosDesc := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
nPosDesD := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
nPosUM	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'} )
nPos2UM	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'} )

aCols [N,nPosDesc] := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+aCols[n,nPosProd],1,"")    
aCols [N,nPosDesD] := GetAdvFVal("SB1","B1_I_DESCD",xFilial("SB1")+aCols[n,nPosProd],1,"") 
aCols [N,nPosUM]   := GetAdvFVal("SB1","B1_UM",xFilial("SB1")+aCols[n,nPosProd],1,"")      
aCols [N,nPos2UM]  := GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+aCols[n,nPosProd],1,"")   

nQtd2UM := aCols [n,nPos2Qtd]
nQtd	:= aCols [n,nPosQtd]

If nQtd == 0 .Or. nQtd2UM == 0

	u_itmsg("Quantidade com o Valor Zerado.","Atenção","Preencha a Quantidade antes de continuar",1)
	LLINHA	:= .F.
	
EndIf	
	
RETURN LLINHA

/*
===============================================================================================================================
Programa----------: AOMS063Z
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Validação geral das telas de inclusão e alteração	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063Z()
LOCAL X
lRt := .F.
DbSelectArea("ZZS")
DbSetOrder(4)

If Empty(cAnoMes)
	u_itmsg("Ano / Mês não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)
	LLINHA	:= .F.
ElseIf AOMS063B()
	u_itmsg("Nâo Há Produtos Importados, Favor Preencher ou Importar Algum Produtos Antes de Prosseguir","Atenção",,1)
	LLINHA	:= .F.
ElseIf Empty(cCoord)
	u_itmsg("Coord/Vend não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)
	LLINHA	:= .F.
ElseIf DbSeek(xFilial("ZZS")+AllTrim(cAnoMes)+AllTrim(cCoord))
	u_itmsg("Tabela Já Cadastrada, Favor alterar o Coordenador ou o Ano / Mês, para dar continuidade","Atenção",,1)
	LLINHA	:= .F.
ElseIf AllTrim(cAnoMes) < Substr(DtoS(dDataBase),1,6)
	u_itmsg("Ano / Mes Menor Que o Ano / Mês Atual","Atenção",,1)
	LLINHA	:= .F.
Else
	LLINHA	:= .T.
EndIf

aCols:=aSort(aCols,,,{|x, y| x[1] < y[1]}) 
nPosProd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
_cprods := ""
_cdups := ""

For X:= 1 To Len(aCols)
	If !Atail(aCols[X]) // !GDDeleted(X)
		If (X+1) <= Len(aCols)
 			If!Atail(aCols[X+1]) // !GDDeleted(X+1)
				If aCols [X,nPosProd] == aCols [X+1,nPosProd]
   					If X < Len(aCols) 
   						lRt := .T.
   						_cdups += " Posição: " + strzero(x,4) + " - produto: " + aCols[x,nPosProd] + CHR(10) + CHR(13)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	cbloq 	 := GetAdvFVal("SB1","B1_MSBLQL",xFilial("SB1")+aCols [x,nPosProd],1,"")

	If cbloq == '1'

		_cprods += " Posição: " + strzero(x,4) + " - produto: " + aCols[x,nPosProd] + CHR(10) + CHR(13)
	
	Endif
			
Next X 

if len(_CPRODS) > 0

	u_itmsg("Existe(m) Produto(s) Bloqueado(s) - Verifique os produtos abaixo:","Atenção",_cprods,1)
	LLINHA	:= .F.
	
EndIf

If lRt
	u_itmsg("Existe(m) Produto(s) Duplicado(s) - Verifique os produtos abaixo:","Atenção",_cdups,1)
	LLINHA	:= .F.
EndIf


xObj := CallMod2Obj()
xObj:oBrowse:Refresh()

RETURN LLINHA

/*
===============================================================================================================================
Programa----------: AOMS063V
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: gatilho do nome do vendedor	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/
User Function AOMS063V ()

lRet := .T.

cNmCoor:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCoord,1,"")

If len(acols) > 0 .and. len(acols[1]) > 0 .and. aCols [1][1] == 'ZZS_COD'
	lRet := .F.
EndIf


Return lRet

/*
===============================================================================================================================
Programa----------: AOMS063D
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Valida Dados
===============================================================================================================================
Parametros--------: cAnoMes,cCoord,nRet
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063D (cAnoMes,cCoord,nRet)
Local oDlg5, nGet1:=0 
Local cPorc


DbSelectArea("ZZS")
DbSetOrder(4)

If Empty(cCoord)

	u_itmsg("Coord/Vend não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)

ElseIf DbSeek(xFilial("ZZS")+AllTrim(cAnoMes)+AllTrim(cCoord))

	u_itmsg("Tabela Já Cadastrada, Favor alterar o Coordenador ou o Ano / Mês, para dar continuidade","Atenção",,1)

ElseIf EMPTY(cAnoMes)

	u_itmsg("Ano / Mês não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)

ElseIf AllTrim(cAnoMes) < Substr(DtoS(dDataBase),1,6)

	u_itmsg("Ano / Mes Menor Que o Ano / Mês Atual","Atenção",,1)

Else

	DEFINE MSDIALOG oDlg5 FROM 0,0 TO 150,200 PIXEL TITLE 'Digite a Porcentagem'
	    
	@10,05 Say "Digite a Porcentagem para o Calculo:" Size 91,08 COLOR CLR_BLACK PIXEL OF oDlg5 
	@30,10 MSGet nGet1 Picture "@E 999,999.99" Size 60,10 Pixel Of oDlg5
	
	@50,15 Button "Ok" Size 20,10 PIXEL OF oDlg5 action (oDlg5:end())
	
	ACTIVATE MSDIALOG oDlg5 CENTERED   

	cPorc:= nGet1/100


	fwmsgrun( ,{|| U_AOMS063W(cporc) }				, 'Aguarde!' , 'Carregando os dados...'  )

EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS063I
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Visualizar Cadastro de Previsão de Vendas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063I()

Local cTitulo	:= "Visualizar"
Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
Public nOpcx := 2

If(EMPTY(TMP->ANOMES))
	
	u_itmsg("Não Há Tabela A ser Visualizada","Atenção",,1)
	
Else
	
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("ZZS")
	nUsado:=0
	aHeader:={}
	aCols:={}

	//Carrega aheader
	aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM"}
	FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )
	
	//Limpa dois ultimos campos do aheader
	asize(aheader,len(aheader)-2)
	
	cAnoMes  := Space(06)
	cCoord	 := Space(06)
	cNmCoor	 := Space(60)
	
	
	aC:={}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
	
	AADD(aC,{"cAnoMes"	,{15,03} 	,"Ano/Mes"   	  		,"@!"   ,				,		,.T.	})
	AADD(aC,{"cCoord"	,{15,65} 	,"Coord/Vend"  	   		,"@!"   ,"U_AOMS063V().And. (ExistCPO('SA3'))"	,"SA3"	,.T.	})
	AADD(aC,{"cNmCoor"	,{15,140} 	,"Nome Coord/Vend"   	,"@!"   ,	,		,.F.	})
	
	//================================================================
	// Array com descricao dos campos do Rodape do Modelo 2         
	//================================================================
	
	aR:={}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	
	cAnoMes       := TMP->ANOMES
	cCoord	      := TMP->COORD
	cNmCoor		  := TMP->NMCOORD
	ACOLS         := {}
	
	//------------MONTA OS ITENS COM OS DADOS-----------------------//
	
	DBSELECTAREA("ZZS")
	DbSetOrder (4)
	DbSeek (xFilial("ZZS")+cAnoMes+cCoord)
	WHILE ZZS->(!EOF()).AND.cAnoMes == ZZS->ZZS_ANOMES .AND. cCoord == ZZS->ZZS_COOR
		AADD(ACOLS,{ZZS->ZZS_COD,ZZS->ZZS_DESCR,ZZS->ZZS_DESCD,ZZS->ZZS_QTD,ZZS->ZZS_UM,ZZS->ZZS_QTD2UM,ZZS->ZZS_2UM,.F.})
		DBSKIP()
	ENDDO
	
	//================================================================
	// Array com coordenadas da GetDados no modelo2                 
	//================================================================
	
	aCGD:={60,06,26,74}
	ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]} 

	cLinhaOk:=".T."
	cTudoOk:=".T."
	
	//================================================================
	// Chamada da Modelo2                                           
	//================================================================
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	//		          cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ]aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ]
	lRetMod2:=Modelo2(cTitulo,aC	,  aR	, aCGD	,nOpcx	,  cLinhaOk	,  cTudoOk ,	  ,		  ,			   ,  9999	, ACORDW   ,        ,    .T.  		, 	     	) 
	
EndIf

Return


/*
===============================================================================================================================
Programa----------: AOMS063Y
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Copia Cadastro de Previsão de Vendas - CHAMADO 3008
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063Y()

Local cTitulo	:= "Copiar",_l
Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
Public nOpcx := 3

If(EMPTY(TMP->ANOMES))
	
	u_itmsg("Não Há Tabela a ser Copiada","Atenção",,1)
	
Else
	
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("ZZS")
	nUsado:=0
	aHeader:={}
	aCols:={}

	//Carrega aheader
	aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM"}
	FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )
	
	//Limpa dois ultimos campos do aheader
	asize(aheader,len(aheader)-2)

	
	cAnoMes  := Space(06)
	cCoord	 := Space(06)
	cNmCoor	 := Space(60)
	
	
	aC:={}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
	
	AADD(aC,{"cAnoMes"	,{15,03} 	,"Ano/Mes"   	  		,"@!"   ,									,		,.T.	})
	AADD(aC,{"cCoord"	,{15,65} 	,"Coord/Vend"  	   		,"@!"   ,"U_AOMS063V() .And. (ExistCPO('SA3'))"	,"SA3"	,.T.	})
	AADD(aC,{"cNmCoor"	,{15,140} 	,"Nome Coord/Vend"   	,"@!"   ,	,		,.F.	})
	
	//================================================================
	// Array com descricao dos campos do Rodape do Modelo 2         
	//================================================================
	
	aR:={}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	
	cMesAno       := TMP->ANOMES
	cCoord	      := TMP->COORD
	cNmCoor		  := TMP->NMCOORD
	ACOLS         := {}
	
	//------------MONTA OS ITENS COM OS DADOS-----------------------//
	
	DBSELECTAREA("ZZS")
	DbSetOrder (4)
	DbSeek (xFilial("ZZS")+cMesAno+cCoord)
	WHILE ZZS->(!EOF()).AND.cMesAno == ZZS->ZZS_ANOMES .AND. cCoord == ZZS->ZZS_COOR
		AADD(ACOLS,{ZZS->ZZS_COD,ZZS->ZZS_DESCR,ZZS->ZZS_DESCD,ZZS->ZZS_QTD,ZZS->ZZS_UM,ZZS->ZZS_QTD2UM,ZZS->ZZS_2UM,.F.})
		DBSKIP()
	ENDDO
	
	//================================================================
	// Array com coordenadas da GetDados no modelo2                 
	//================================================================
	
	aCGD:={60,06,26,74}
	ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]}  
	
	cLinhaOk:="ExecBlock('AOMS063O',.f.,.f.)"
	cTudoOk:="ExecBlock('AOMS063Z',.f.,.f.)"
	
	//================================================================
	// Chamada da Modelo2                                           
	//================================================================
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	//		          cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ]aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ]
	lRetMod2:=Modelo2(cTitulo,aC	,  aR	, aCGD	,nOpcx	,  cLinhaOk	,  cTudoOk ,	  ,		  ,			   ,  9999	,  ACORDW  ,        ,    .T.  		, 	     	)
	
	If lRetMod2 // Gravacao. . .
		nPosProd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
		nPosDesc := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
		nPosDesD := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
		nPosUM	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'} )
		nPosQtd	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'} )
		nPos2UM	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'} )
		nPos2Qtd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
		
		For _l := 1 To Len(aCols)
			If !aCols[_l,Len(aHeader)+1]
				
				RecLock("ZZS",.T.)
				ZZS->ZZS_FILIAL	:= xFilial("ZZS")
				ZZS->ZZS_COD	:= aCols [_l,nPosProd]
				ZZS->ZZS_DESCR	:= aCols [_l,nPosDesc]
				ZZS->ZZS_DESCD	:= aCols [_l,nPosDesD]
				ZZS->ZZS_UM		:= aCols [_l,nPosUM]
				ZZS->ZZS_QTD   	:= aCols [_l,nPosQtd]
				ZZS->ZZS_2UM	:= aCols [_l,nPos2UM]
				ZZS->ZZS_QTD2UM	:= aCols [_l,nPos2Qtd]
				ZZS->ZZS_COOR	:= cCoord
				ZZS->ZZS_NMCOOR	:= cNmCoor
				ZZS->ZZS_ANOMES	:= cAnoMes
				ZZS->(MsUnLock())
				
				RecLock("ZGW",.T.)
				ZGW->ZGW_FILIAL	:= xFilial("ZGW")
				ZGW->ZGW_COD	:= aCols [_l,nPosProd]
				ZGW->ZGW_DESCR	:= aCols [_l,nPosDesc]
				ZGW->ZGW_DESCD	:= aCols [_l,nPosDesD]
				ZGW->ZGW_UM		:= aCols [_l,nPosUM]
				ZGW->ZGW_QTD   	:= aCols [_l,nPosQtd]
				ZGW->ZGW_2UM	:= aCols [_l,nPos2UM]
				ZGW->ZGW_QTD2UM	:= aCols [_l,nPos2Qtd]
				ZGW->ZGW_COOR	:= cCoord
				ZGW->ZGW_NMCOOR	:= cNmCoor
				ZGW->ZGW_ANOMES	:= cAnoMes
				ZGW->ZGW_OPER   := "INCLUSAO"
				ZGW->ZGW_USER   := _cusername
				ZGW->ZGW_DATA   := DATE()
				ZGW->ZGW_HORA   := TIME()
				ZGW->(MsUnLock())
	
				
			EndIf
		Next _l

	    Close(oDlgLIb)
	    CCHAMA := ""
	    
	Endif
EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS063Y
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Replicar Cadastro de Previsão de Vendas - CHAMADO 3008  	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063Z()

Local nPeriod	:= SPACE(4)
Local cAnoMes	:= TMP->ANOMES
Local cCoord	:= TMP->COORD
Local cNmCoord	:= TMP->NMCOORD

If(EMPTY(TMP->ANOMES))
	
	u_itmsg("Não Há Tabela a ser Replicada","Atenção",,1)
	
Else
	
	@ 120,200 To 300,750 Dialog oDlg2 Title OemToAnsi("Periodo de Replicação")
	
	@ 007,002 Say "Periodo a Ser Replicado (Em Meses):" Size 150,10 Pixel Of oDlg2
	@ 005,100 GET nPeriod SIZE 60,10 Pixel Of oDlg2
	@ 005,002 BUTTON "Confirma"  SIZE 40,15 ACTION AOMS063Q (nPeriod,cAnoMes,cCoord,cNmCoord)
	@ 005,015 BUTTON "Sair"      SIZE 40,15 ACTION Close(oDlg2)
	ACTIVATE DIALOG oDlg2 CENTERED
	
EndIf


Return

/*
===============================================================================================================================
Programa----------: AOMS063Q
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Processa Replicacao Cadastro de Previsão de Vendas - CHAMADO 3008  	
===============================================================================================================================
Parametros--------: 	nPeriod - Quantidade de periodos a replicar
						cAnoMes - Data do movimento a replicar
						cCoord - Coordenador a replicar
						cNmCoor - numero do coordenador
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063Q (nPeriod,cAnoMes,cCoord,cNmCoor)
local x
cAMes:= cAnoMes

For x:=1 To VAL(nPeriod)
	DbSelectArea("ZZS")
	DbSetOrder(4)
	DbSeek(xFilial("ZZS")+cAnoMes+cCoord)
	cAMes:= If(STRZERO((VAL(SubStr(cAMes,5,2))+1),2) > "12", STRZERO((VAL(SubStr(cAMes,1,4))+1),4)+"01",;
	StrZero(VAL(SubStr(cAMes,1,4)),4)+STRZERO((VAL(SubStr(cAMes,5,2))+1),2))
	If !(DbSeek(xFilial("ZZS")+cAMes+cCoord))
		
		cRep:= " SELECT ZZS_COD COD, ZZS_DESCR DESCR, ZZS_DESCD DESCD, ZZS_QTD QTD1UM, ZZS_UM UM1, ZZS_QTD2UM QTD2UM,
		cRep+= " ZZS_2UM UM2
		cRep+= " FROM ZZS010
		cRep+= " WHERE ZZS_ANOMES = '"+cAnoMes+"'
		cRep+= " AND ZZS_COOR = '"+cCoord+"'
		cRep+= " AND D_E_L_E_T_ = ' '
		cRep+= " AND ZZS_FILIAL = '"+xFilial("ZZS")+"'
		
		cRep := ChangeQuery(cRep)
		
		//=================================
		// Fecha Alias se estiver em Uso 
		//=================================
		If Select("TRB") >0
			dbSelectArea("TRB")
			dbCloseArea()
		Endif
		
		
		//==============================================
		// Monta Area de Trabalho executando a Query 
		//==============================================
		TCQUERY cRep New Alias "TRB"
		dbSelectArea("TRB")
		
		dbGoTop()
		
		While TRB->(!EoF())
	
			RecLock("ZZS",.T.)
			ZZS->ZZS_FILIAL	:= xFilial("ZZS")
			ZZS->ZZS_COD	:= TRB->COD
			ZZS->ZZS_DESCR	:= TRB->DESCR
			ZZS->ZZS_DESCD	:= TRB->DESCD
			ZZS->ZZS_UM		:= TRB->UM1
			ZZS->ZZS_QTD   	:= TRB->QTD1UM
			ZZS->ZZS_2UM	:= TRB->UM2
			ZZS->ZZS_QTD2UM	:= TRB->QTD2UM
			ZZS->ZZS_COOR	:= cCoord
			ZZS->ZZS_NMCOOR	:= cNmCoor
			ZZS->ZZS_ANOMES	:= cAMes
			
			ZZS->(MsUnLock())
			
			RecLock("ZGW",.T.)
			ZGW->ZGW_FILIAL	:= xFilial("ZGW")
			ZGW->ZGW_COD	:= TRB->COD
			ZGW->ZGW_DESCR	:= TRB->DESCR
			ZGW->ZGW_DESCD	:= TRB->DESCD
			ZGW->ZGW_UM		:= TRB->UM1
			ZGW->ZGW_QTD   	:= TRB->QTD1UM
			ZGW->ZGW_2UM	:= TRB->UM2
			ZGW->ZGW_QTD2UM	:= TRB->QTD2UM
			ZGW->ZGW_COOR	:= cCoord
			ZGW->ZGW_NMCOOR	:= cNmCoor
			ZGW->ZGW_ANOMES	:= cAMes
			ZGW->ZGW_OPER   := "INCLUSAO"
			ZGW->ZGW_USER   := _cusername
			ZGW->ZGW_DATA   := DATE()
			ZGW->ZGW_HORA   := TIME()
			ZGW->(MsUnLock())
			
			TRB->(DbSkip())
			
		EndDo
	EndIf
Next x

u_itmsg("Replicação Concluida Com Sucesso","Atenção",,2)

Close(oDlgLIb)
cchama := "" //Refaz a tela

Return

/*
===============================================================================================================================
Programa----------: AOMS063G
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Alterar Cadastro de Previsão de Vendas  	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063G()

Local cTitulo	:= "Alterar",_l
Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
Public nOpcx := 4

If(EMPTY(TMP->ANOMES))
	
	u_itmsg("Não Há Tabela A ser Visualizada","Atenção",,1)
	
Else
	
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("ZZS")
	nUsado:=0
	aHeader:={}
	aCols:={}

	//Carrega aheader
	aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM"}
	FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )
	
	//Limpa dois ultimos campos do aheader
	asize(aheader,len(aheader)-2)

		
	cAnoMes  := Space(06)
	cCoord	 := Space(06)
	cNmCoor	 := Space(60)
	
	
	aC:={}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
	
	AADD(aC,{"cAnoMes"	,{15,03} 	,"Ano/Mes"   	  		,"@!"   ,				,		,.F.	})
	AADD(aC,{"cCoord"	,{15,65} 	,"Coord/Vend"	  		,"@!"   ,"U_AOMS063V().And. (ExistCPO('SA3'))"	,"SA3"	,.F.	})
	AADD(aC,{"cNmCoor"	,{15,140} 	,"Nome Coord/Vend"   	,"@!"   ,	,		,.F.	})
	
	//================================================================
	// Array com descricao dos campos do Rodape do Modelo 2         
	//================================================================
	
	aR:={}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	
	cAnoMes       := TMP->ANOMES
	cCoord	      := TMP->COORD
	cNmCoor		  := TMP->NMCOORD
	ACOLS         := {}
	
	//------------MONTA OS ITENS COM OS DADOS-----------------------//
	
	DBSELECTAREA("ZZS")
	DbSetOrder (4)
	DbSeek (xFilial("ZZS")+cAnoMes+cCoord)
	WHILE ZZS->(!EOF()).AND.cAnoMes == ZZS->ZZS_ANOMES .AND. cCoord == ZZS->ZZS_COOR
		AADD(ACOLS,{ZZS->ZZS_COD,ZZS->ZZS_DESCR,ZZS->ZZS_DESCD,ZZS->ZZS_QTD,ZZS->ZZS_UM,ZZS->ZZS_QTD2UM,ZZS->ZZS_2UM,.F.})
		DBSKIP()
	ENDDO
	
	//================================================================
	// Array com coordenadas da GetDados no modelo2                 
	//================================================================
	
	aCGD:={60,06,26,74}
	ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]} 
	
	cLinhaOk	:="ExecBlock('AOMS063O',.f.,.f.)"
	
	//================================================================
	// Chamada da Modelo2                                           
	//================================================================
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	//		          cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ]aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ]
	lRetMod2:=Modelo2(cTitulo,aC	,  aR	, aCGD	,nOpcx	,  cLinhaOk	,   ,	  ,		  ,			   ,  9999	,   ACORDW     ,    .T.    ,    .T.  		, 	     	)	 
	
	If lRetMod2 // Gravacao. . .
		nPosProd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
		nPosDesc := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
		nPosDesD := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
		nPosUM	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'} )
		nPosQtd	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'} )
		nPos2UM	 := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'} )
		nPos2Qtd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
		
		DbSelectArea("ZZS")
		ZZS->(DbSetOrder(5))
		For _l := 1 To Len(aCols)
			
			If !aCols[_l,Len(aHeader)+1] .And. !Atail(aCols[_l]) //  !GDDeleted(_l)
				IF ZZS->(!DbSeek(xFilial("ZZS")+aCols [_l,nPosProd]+cAnoMes+cCoord))
					RecLock("ZZS",.T.)
					_COPER := "INCLUSAO"
					ZZS->ZZS_ANOMES	:= cAnoMes
					ZZS->ZZS_COOR 	:= cCoord
					ZZS->ZZS_NMCOOR	:= cNmCoor
				Else
				
					RecLock("ZGW",.T.)
					ZGW->ZGW_FILIAL	:= xFilial("ZGW")
					ZGW->ZGW_COD	:= ZZS->ZZS_COD
					ZGW->ZGW_DESCR	:= ZZS->ZZS_DESCR
					ZGW->ZGW_DESCD	:= ZZS->ZZS_DESCD
					ZGW->ZGW_UM		:= ZZS->ZZS_UM
					ZGW->ZGW_QTD   	:= ZZS->ZZS_QTD
					ZGW->ZGW_2UM	:= ZZS->ZZS_2UM
					ZGW->ZGW_QTD2UM	:= ZZS->ZZS_QTD2UM
					ZGW->ZGW_COOR	:= ZZS->ZZS_COOR
					ZGW->ZGW_NMCOOR	:= ZZS->ZZS_NMCOOR
					ZGW->ZGW_ANOMES	:= ZZS->ZZS_ANOMES
					ZGW->ZGW_OPER   := "ALTERADO-INICIAL"
					ZGW->ZGW_USER   := _cusername
					ZGW->ZGW_DATA   := DATE()
					ZGW->ZGW_HORA   := TIME()
					ZGW->(MsUnLock())
				
					RecLock("ZZS",.F.)
					_COPER := "ALTERADO-FINAL"
				EndIf

				ZZS->ZZS_COD	:= aCols [_l,nPosProd]
				ZZS->ZZS_DESCR	:= aCols [_l,nPosDesc]
				ZZS->ZZS_DESCD	:= aCols [_l,nPosDesD]
				ZZS->ZZS_UM		:= aCols [_l,nPosUM]
				ZZS->ZZS_QTD   	:= aCols [_l,nPosQtd]
				ZZS->ZZS_2UM	:= aCols [_l,nPos2UM]
				ZZS->ZZS_QTD2UM	:= aCols [_l,nPos2Qtd]
				ZZS->(MsUnLock())
				
				RecLock("ZGW",.T.)
				ZGW->ZGW_FILIAL	:= xFilial("ZGW")
				ZGW->ZGW_COD	:= ZZS->ZZS_COD
				ZGW->ZGW_DESCR	:= ZZS->ZZS_DESCR
				ZGW->ZGW_DESCD	:= ZZS->ZZS_DESCD
				ZGW->ZGW_UM		:= ZZS->ZZS_UM
				ZGW->ZGW_QTD   	:= ZZS->ZZS_QTD
				ZGW->ZGW_2UM	:= ZZS->ZZS_2UM
				ZGW->ZGW_QTD2UM	:= ZZS->ZZS_QTD2UM
				ZGW->ZGW_COOR	:= ZZS->ZZS_COOR
				ZGW->ZGW_NMCOOR	:= ZZS->ZZS_NMCOOR
				ZGW->ZGW_ANOMES	:= ZZS->ZZS_ANOMES
				ZGW->ZGW_OPER   := _COPER
				ZGW->ZGW_USER   := _cusername
				ZGW->ZGW_DATA   := DATE()
				ZGW->ZGW_HORA   := TIME()
				ZGW->(MsUnLock())
				
			Else
				IF ZZS->(DbSeek(xFilial("ZZS")+aCols [_l,nPosProd]+cAnoMes+cCoord))
		
					RecLock("ZGW",.T.)
					ZGW->ZGW_FILIAL	:= xFilial("ZGW")
					ZGW->ZGW_COD	:= ZZS->ZZS_COD
					ZGW->ZGW_DESCR	:= ZZS->ZZS_DESCR
					ZGW->ZGW_DESCD	:= ZZS->ZZS_DESCD
					ZGW->ZGW_UM		:= ZZS->ZZS_UM
					ZGW->ZGW_QTD   	:= ZZS->ZZS_QTD
					ZGW->ZGW_2UM	:= ZZS->ZZS_2UM
					ZGW->ZGW_QTD2UM	:= ZZS->ZZS_QTD2UM
					ZGW->ZGW_COOR	:= ZZS->ZZS_COOR
					ZGW->ZGW_NMCOOR	:= ZZS->ZZS_NMCOOR
					ZGW->ZGW_ANOMES	:= ZZS->ZZS_ANOMES
					ZGW->ZGW_OPER   := "EXCLUSAO LINHA"
					ZGW->ZGW_USER   := _cusername
					ZGW->ZGW_DATA   := DATE()
					ZGW->ZGW_HORA   := TIME()
					ZGW->(MsUnLock())
				
				   RecLock("ZZS",.F.)
				   ZZS->(dbDelete())
				   ZZS->(MsUnLock())
				   
				ENDIF
			EndIf
			
		Next _l
	Endif
EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS063G
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Sai da rotina 	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063H()

Close(oDlgLIb)
cChama := "5"

Return

/*
===============================================================================================================================
Programa----------: AOMS063N
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Exclusão Cadastro de Previsão de Vendas - CHAMADO 3008  
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063N()

Public nOpcx := 4

cAno  := TMP->ANOMES
cCoo  := TMP->COORD
cCooD :=TMP->NMCOORD

If u_itmsg("Deseja Excluir Tabela: "+TMP->ANOMES+" do Coord/Vend: "+TMP->COORD+" - "+TMP->NMCOORD,"Atenção",,2,2,2)

	DbSelectArea("ZZS")
	DbSetOrder(4)
	DbSeek(xFilial("ZZS")+TMP->ANOMES+TMP->COORD)
	
	While !(EoF()) .And. TMP->ANOMES == ZZS->ZZS_ANOMES .And. TMP->COORD == ZZS->ZZS_COOR

		RecLock("ZGW",.T.)
		ZGW->ZGW_FILIAL	:= xFilial("ZGW")
		ZGW->ZGW_COD	:= ZZS->ZZS_COD
		ZGW->ZGW_DESCR	:= ZZS->ZZS_DESCR
		ZGW->ZGW_DESCD	:= ZZS->ZZS_DESCD
		ZGW->ZGW_UM		:= ZZS->ZZS_UM
		ZGW->ZGW_QTD   	:= ZZS->ZZS_QTD
		ZGW->ZGW_2UM	:= ZZS->ZZS_2UM
		ZGW->ZGW_QTD2UM	:= ZZS->ZZS_QTD2UM
		ZGW->ZGW_COOR	:= ZZS->ZZS_COOR
		ZGW->ZGW_NMCOOR	:= ZZS->ZZS_NMCOOR
		ZGW->ZGW_ANOMES	:= ZZS->ZZS_ANOMES
		ZGW->ZGW_OPER   := "EXCLUSAO/VENDEDOR"
		ZGW->ZGW_USER   := _cusername
		ZGW->ZGW_DATA   := DATE()
		ZGW->ZGW_HORA   := TIME()
		ZGW->(MsUnLock())

		RecLock("ZZS",.F.)
		DbDelete()
	    ZZS->(MsUnLock())
	    ZZS->(DbSkip())
	EndDo	
	
	u_itmsg("Tabela: "+cAno+" do Coord/Vend: "+cCoo+" - "+cCooD+" Excluida Com Sucesso","Atenção",,2)

    Close(oDlgLIb)
    cchama := "" //Reinicia tela

EndIf	

Return


/*
===============================================================================================================================
Programa----------: AOMS063B
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Valida produtos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - True se emcontro produtos
===============================================================================================================================
*/
Static Function AOMS063B()
LOCAL I
nPosProd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
lRet := .T.

For I:= 1 to Len(aCols)

	If !Empty(aCols [I,nPosProd]) .And. !Atail(aCols[I]) // .And. !GDDeleted(I) 
		Return .F.
	EndIf

Next I
	
Return lRet 	

/*
===============================================================================================================================
Programa----------: AOMS063U
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
===============================================================================================================================
Descrição---------: Prepara variáveis e dados 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063U()

//===============
// Monta Query 
//===============

cQuery := " SELECT ZZS.ZZS_COOR COORD, ZZS.ZZS_NMCOOR NMCOORD, ZZS.ZZS_ANOMES ANOMES "
cQuery += " FROM ZZS010 ZZS "
cQuery += " WHERE ZZS_FILIAL = '"+xFilial("ZZS")+"' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY ZZS.ZZS_COOR, ZZS_NMCOOR, ZZS.ZZS_ANOMES "

cQuery := ChangeQuery(cQuery)

//=================================
// Fecha Alias se estiver em Uso 
//=================================
If Select("TRB") >0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

If Select("TMP") >0
	dbSelectArea("TMP")
	dbCloseArea()
Endif


//==============================================
// Monta Area de Trabalho executando a Query 
//==============================================
TCQUERY cQuery New Alias "TRB"
dbSelectArea("TRB")

dbGoTop()

//============================
// Monta arquivo temporario 
//============================

aCpoTmp:={}
aAdd(aCpoTmp,{"ANOMES"		,"C",06,0})
aAdd(aCpoTmp,{"COORD"		,"C",06,0})
aAdd(aCpoTmp,{"NMCOORD"		,"C",60,0})

//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
If Select("TMP") > 0 .AND. TYPE("_otemp") == "O"
	_otemp:Delete()
EndIf

_otemp := FWTemporaryTable():New( "TMP", aCpoTmp )
_otemp:AddIndex( "01", {"ANOMES"} )
_otemp:AddIndex( "02", {"COORD"} )
_otemp:AddIndex( "03", {"NMCOORD"} )

_otemp:Create()

//===============================
// Alimenta arquivo temporario 
//===============================
While !TRB->(EOF())
	
	DbSelectArea("TMP")
	RecLock("TMP",.t.)
	TMP->COORD 		:= TRB->COORD
	TMP->ANOMES   	:= TRB->ANOMES
	TMP->NMCOORD 	:= TRB->NMCOORD
	
	TMP->(MsUnlock())
	DbSelectArea("TRB")
	TRB->(dbSkip())
	
End

TRB->(dbCloseArea())


//=============================================
// Array com definicoes dos campos do browse 
//=============================================

aCpoBrw:={}
aAdd(aCpoBrw,{"ANOMES"    	,""	,"Ano / Mes"     		,"@!"               	,"06" ,"0"})
aAdd(aCpoBrw,{"COORD"    	,""	,"Coord/Vend"     		,"@!"               	,"06" ,"0"})
aAdd(aCpoBrw,{"NMCOORD"    	,""	,"Nome Coord/Vend"		,"@!"               	,"60" ,"0"})


Return

/*
===============================================================================================================================
Programa----------: AOMS063E
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/04/2018
===============================================================================================================================
Descrição---------: Exporta tabela de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063E()

If Pergunte( 'AOMS063' )

	If empty(MV_PAR01)
	
		U_ITMSG("Preenchimento do mês e ano é obrigatório!","Atenção",,1)
		Return
		
	Else

		fwmsgrun( ,{|| _aAlias := AOMS063L() } , 'Aguarde!' , 'Verificando os registros...' )
		
	Endif

EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS063L
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/04/2018
===============================================================================================================================
Descrição---------: Gera tabela de exportação
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063L()

Local _cquery := ""
Local calias  := GetNextAlias()
Local _alista := {}
Local _ni		:= 0
Local _nii		:= 0

_cQuery := " SELECT "
_cQuery += "    ZZS_COD,ZZS_DESCR,ZZS_DESCD,ZZS_QTD,ZZS_UM,ZZS_QTD2UM,ZZS_2UM,ZZS_COOR,ZZS_NMCOOR,ZZS_ANOMES"
_cQuery += " FROM "+ RetSqlName("ZZS") +" ZZS "
_cQuery += " WHERE ZZS.D_E_L_E_T_	= ' ' "

If !empty(MV_PAR01) 

	_cQuery += " AND	ZZS.ZZS_ANOMES	= '"+ MV_PAR01 +"' "
	
Endif

If !empty(MV_PAR02) 

	_cQuery += " AND	ZZS.ZZS_COOR	>= '"+ MV_PAR02 +"' "
	_cQuery += " AND	ZZS.ZZS_COOR	<= '"+ MV_PAR03 +"' "
	
Endif

_cQuery += " ORDER BY ZZS_ANOMES,ZZS_COOR,ZZS_DESCR"

If Select(cAlias) > 0
	(cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , cAlias , .T. , .F. )

DBSelectArea(cAlias)

//Popula array com coordenadores/vendedores
(cAlias)->( DBGoTop() )
_avend := {}

Do while  (cAlias)->(!Eof()) 

	If ascan(_avend,(cAlias)->ZZS_COOR + "/" + (cAlias)->ZZS_NMCOOR) == 0  .and. !empty((cAlias)->ZZS_COOR)
	
		aadd(_avend,(cAlias)->ZZS_COOR+ "/" + (cAlias)->ZZS_NMCOOR)
		aadd(_avend,"UN")
		
	Endif
	
	(cAlias)->(Dbskip())
	
Enddo

//Popula alista

(cAlias)->( DBGoTop() )

Do while  (cAlias)->(!Eof()) 


	_nposi := ascan(_alista,{|x| x[3] = alltrim((cAlias)->ZZS_COD)})
		
	If _nposi == 0

		aadd(_alista,{ MV_PAR01,;
		 			   alltrim((cAlias)->ZZS_DESCR) ,;
		 			   (cAlias)->ZZS_COD  })
					
		For _ni := 1 to len(_avend)
	
			If ascan(_avend,(cAlias)->ZZS_COOR + "/" + (cAlias)->ZZS_NMCOOR) == _ni
	
				aadd(_alista[len(_alista)],(cAlias)->ZZS_QTD2UM)
				aadd(_alista[len(_alista)],(cAlias)->ZZS_2UM)
				
			Else
			
				aadd(_alista[len(_alista)],0)
				aadd(_alista[len(_alista)],(cAlias)->ZZS_2UM)
				
			Endif
		
		Next
		
	Else
		
		_alista[_nposi][ascan(_avend,(cAlias)->ZZS_COOR + "/" + (cAlias)->ZZS_NMCOOR)+3] := (cAlias)->ZZS_QTD2UM
	
	Endif

	(cAlias)->( Dbskip() )
	
Enddo

_ahead := {	"ANOMES",;
			"PRODUTO",;
			"CODIGO"	}
			
For _ni := 1 to len(_avend)
	
	aadd(_ahead,_avend[_ni])
		
Next


//Correcao de linhas para excluir colunas extras
_atemp := {}

For _ni := 1 to len(_alista)

	aadd(_atemp, {})
	For _nii := 1 to len(_alista[_ni])

		If _nii <= len(_ahead)
		
			aadd(_atemp[len(_atemp)],_alista[_ni][_nii])
			
		Endif
		
	Next
	
Next

_alista := _atemp

If len(_alista) > 0

 U_ITListBox( "Metas Venda",	_ahead,	 _alista , .F. , 1,"Metas Venda"  )

Else

	u_itmsg("Não foram localizados registros com os parâmetros indicados","Atenção",,1)
	
Endif

Return


/*
===============================================================================================================================
Programa----------: AOMS063K
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/04/2018
===============================================================================================================================
Descrição---------: Importa tabela de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063K()

Local _cdados := ""
Local _ahead := {}
Local _alinhas := {}
Local cPerg2 := "AOMS063F"
Local _np		:= 0
Local _nnj		:= 0

If !pergunte(cPerg2)

	Return
	
Endif

If FT_FUSE(MV_PAR02) == -1
	
	u_itmsg("Falha ao abrir arquivo csv","Erro",,1)
		
	Return
		
Endif

FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO

FT_FSKIP()
FT_FSKIP()
_cDados := FT_FREADLN()

//Verifica segunda linha de headers
If substr(alltrim(_cDados),1,22) != "ANOMES;PRODUTO;CODIGO;"

	u_itmsg("Arquivo não está no layout de metas de venda","Atenção",,1)

	Return
	
Endif

//Monta headers
_cDados := alltrim(_cDados)
_ahead := strtokarr(_cDados,";")

//Monta alinhas
FT_FSKIP()
Do  while !(FT_FEOF())

	_cDados := FT_FREADLN()
	_cDados := alltrim(_cDados)
	aadd(_alinhas,strtokarr(_cDados,";"))
	
	//Normaliza campos de código
	_alinhas[len(_alinhas)][1] := MV_PAR01
	_alinhas[len(_alinhas)][3] := strzero(val(_alinhas[len(_alinhas)][3]),11)
	
	//Normaliza campos de valores para numérico
	For _np := 4 to len(_alinhas[len(_alinhas)])
	
		_alinhas[len(_alinhas)][_np] := val(_alinhas[len(_alinhas)][_np])
		_np++
		
	Next

	FT_FSKIP()

Enddo

//Verifica se carregou colunas corretamente
_aerros := {}

For _nnj := 1 to len(_alinhas)

	If len(_alinhas[_nnj]) != len(_ahead)
	
		aadd(_aerros,{"Linha " + strzero(_nnj+3,6) + " com divergência de colunas, verifique se todos as metas contém valores numéricos, em caso de meta zerada deve estar com número 0"})
		
	Endif
	
Next

If len(_aerros) > 0

		
	u_itlistbox('Ajuste de meta de vendas',{"Erros"},_aerros)
	Return
	
Endif

//Chama função de reajuste com arrays
If U_ITListBox( 'Ajuste de meta de vendas' , _ahead , _alinhas , .T. , 1, "Realizar ajuste de meta de vendas abaixo?" )
 	
	fwmsgrun( ,{|| _aAlias := AOMS063A(_alinhas,_ahead) } , 'Aguarde!' , 'Ajustando metas...' )
 		
Endif


Return

/*
===============================================================================================================================
Programa--------: AOMS063A
Autor-----------: Josué Danich Prestes
Data da Criacao-: 29/03/2018
===============================================================================================================================
Descrição-------: Ajusta metas de vendas
===============================================================================================================================
Parametros------:   _alista - dados
					_ahead - cabecalho
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063A(_alista,_ahead)

Local _ni := 0
Local _aerros := {}
Local _cprod :=  "N/C"
Local _cvend := "N/C"
Local _lconf := .F.
Local _nrep	:= 0
Local _nni	:= 0
//Roda tabela vendo deletando vendedores do mês baseado no excel

ZZS->(Dbsetorder(4))

If ZZS->(Dbseek(xfilial("ZZS")+alltrim(MV_PAR01)))

	Do while ALLTRIM(ZZS->ZZS_ANOMES) == alltrim(MV_PAR01)

		_nposv := ascan(_ahead,alltrim(ZZS->ZZS_COOR) + "/" + alltrim(ZZS->ZZS_NMCOOR))
		
		if _nposv > 0 //Tem vendedor no excel
	
			If !_lconf
			
				If u_itmsg("Existem dados para o mês e vendedores sendo importados, sobscrever?","Atenção","Todos os dados do Protheus serão sobrescritos pelos dados da tabela",2,2,2)
				
					_lconf := .T.
					
				Else
				
					U_ITMSG("Processo Cancelado","Atenção",,1)
					Return
					
				Endif
				
			Endif
	
			RecLock("ZGW",.T.)
			ZGW->ZGW_FILIAL	:= xFilial("ZGW")
			ZGW->ZGW_COD	:= ZZS->ZZS_COD
			ZGW->ZGW_DESCR	:= ZZS->ZZS_DESCR
			ZGW->ZGW_DESCD	:= ZZS->ZZS_DESCD
			ZGW->ZGW_UM		:= ZZS->ZZS_UM
			ZGW->ZGW_QTD   	:= ZZS->ZZS_QTD
			ZGW->ZGW_2UM	:= ZZS->ZZS_2UM
			ZGW->ZGW_QTD2UM	:= ZZS->ZZS_QTD2UM
			ZGW->ZGW_COOR	:= ZZS->ZZS_COOR
			ZGW->ZGW_NMCOOR	:= ZZS->ZZS_NMCOOR
			ZGW->ZGW_ANOMES	:= ZZS->ZZS_ANOMES
			ZGW->ZGW_OPER   := "EXCLUSAO/PREIMPORTACAO"
			ZGW->ZGW_USER   := _cusername
			ZGW->ZGW_DATA   := DATE()
			ZGW->ZGW_HORA   := TIME()
			ZGW->(MsUnLock())
				
			Reclock("ZZS",.F.)
			ZZS->(Dbdelete())
			ZZS->(Msunlock())
		
		Endif
		
		ZZS->(Dbskip())
		
	Enddo
		
Endif

ZZS->(Dbsetorder(6))

For _ni := 1 to len(_alista)

	For _nni := 4 to len(_ahead)

		//Pula colunas de separação
		If _ahead[_nni] == "UN"
		
			Loop
			
		Endif
		
		//Pula quantidades zeradas
		If _alista[_ni][_nni] == 0
		
			Loop
			
		Endif
		

		//Procura se existe o produto e vendedor e inclui se não achar
		If !(ZZS->(Dbseek(xfilial("ZZS")+alltrim(MV_PAR01)+_alista[_ni][3]+substr(_ahead[_nni],1,6) ) ))
		
			//Antes de incluir verifica se produto e vendedor existem
			_lprod := .F.
			_cerro := ""
			SB1->(Dbsetorder(1))
			If SB1->(Dbseek(xfilial("SB1")+_alista[_ni][3]))
			
				_cprod := SB1->B1_DESC
			
				If SB1->B1_MSBLQL == '1'
				
					_lprod := .F.
					_cerro += "Produto Bloqueado "
					
				Else
				
					_lprod := .T.
				
				Endif
				
			Else
			
				_cerro += "Produto não encontrado "
				_lprod := .F.
				_cprod := "N/C"
			
			Endif
			
			_lvend := .F.
			SA3->(Dbsetorder(1))
			If SA3->(Dbseek(xfilial("SA3")+substr(_ahead[_nni],1,6)))
			
				_cvend := SA3->A3_NOME
			
				If SA3->A3_MSBLQL == '1'
				
					_lvend := .F.
					_cerro += "Vendedor Bloqueado "
					
				Else
				
					_lvend := .T.
				
				Endif
				
			Else
			
				_cerro += "Vendedor não encontrado "
				_lvend := .F.
				_cvend := "N/C"
			
			Endif
			
			//Valida se não está repetido na lista
			If _lprod
			
				For _nrep := 1 to len(_alista)
			
					If _lprod .and.  alltrim(_alista[_nrep][2]) == alltrim(SB1->B1_COD) .and. _nrep != _ni 
				
						_lprod := .F.
						_cerro += " Produto duplicado na tabela "
				 	
					Endif
				 
				Next
				
			Endif
			
			If !_lprod .or. !_lvend
			
				aadd(_aerros,{alltrim(MV_PAR01),substr(_ahead[_nni],1,6),_cvend,_alista[_ni][3],_cprod,_cerro})
 
			Else
			
				//Carrega fator de conversão se existir
				If SB1->B1_CONV == 0
				
					If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
					
						_nfator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
					
					Else
					
						_nfator := 0
						
					Endif
					
				Else
				
					_nfator := IIF(SB1->B1_TIPCONV=="M", 1/SB1->B1_CONV,SB1->B1_CONV)
					
				Endif
		
				Reclock("ZZS",.T.)
				ZZS->ZZS_COD := SB1->B1_COD
				ZZS->ZZS_DESCR := SB1->B1_DESC
				ZZS->ZZS_DESCD := SB1->B1_I_DESCD
				ZZS->ZZS_QTD := IIF(_nfator>0,_alista[_ni][_nni]*_nfator,_alista[_ni][_nni])
				ZZS->ZZS_UM := SB1->B1_UM
				ZZS->ZZS_QTD2UM := IIF(_nfator>0,_alista[_ni][_nni],0)
				ZZS->ZZS_2UM := SB1->B1_SEGUM
				ZZS->ZZS_COOR := SA3->A3_COD
				ZZS->ZZS_NMCOOR := SA3->A3_NOME
				ZZS->ZZS_ANOMES := MV_PAR01
				ZZS->(Msunlock())
				
				RecLock("ZGW",.T.)
				ZGW->ZGW_FILIAL	:= xFilial("ZGW")
				ZGW->ZGW_COD	:= ZZS->ZZS_COD
				ZGW->ZGW_DESCR	:= ZZS->ZZS_DESCR
				ZGW->ZGW_DESCD	:= ZZS->ZZS_DESCD
				ZGW->ZGW_UM		:= ZZS->ZZS_UM
				ZGW->ZGW_QTD   	:= ZZS->ZZS_QTD
				ZGW->ZGW_2UM	:= ZZS->ZZS_2UM
				ZGW->ZGW_QTD2UM	:= ZZS->ZZS_QTD2UM
				ZGW->ZGW_COOR	:= ZZS->ZZS_COOR
				ZGW->ZGW_NMCOOR	:= ZZS->ZZS_NMCOOR
				ZGW->ZGW_ANOMES	:= ZZS->ZZS_ANOMES
				ZGW->ZGW_OPER   := "INCLUSAO/IMPORTACAO"
				ZGW->ZGW_USER   := _cusername
				ZGW->ZGW_DATA   := DATE()
				ZGW->ZGW_HORA   := TIME()
				ZGW->(MsUnLock())
			
			Endif
			
		Endif
		
	Next

Next

If len(_aerros) > 0
 
 	_ahead2 := {"MESANO"         ,"COD VEND"              ,"VENDEDOR","COD PROD"     ,"PRODUTO","STATUS"}
	U_ITListBox( 'Ajuste de meta de vendas' , _ahead2 , _aerros , .T. , 1, "Ocorreram erros no processamento:" ) 

Else

	u_itmsg("Ajuste concluido","Atenção",,2)
	
Endif

Close(oDlgLIb)
cchama := "" //Recarrega dados da tela

Return

/*
===============================================================================================================================
Programa--------: AOMS063R
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/09/2018
===============================================================================================================================
Descrição-------: Relatório de log de metas de vendas
===============================================================================================================================
Parametros------:  Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063R()

If Pergunte( 'AOMS063R' )

	fwmsgrun( ,{||  AOMS063S() } , 'Aguarde!' , 'Gerando Log...' )

EndIf

Return

/*
===============================================================================================================================
Programa--------: AOMS063S
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/09/2018
===============================================================================================================================
Descrição-------: Execução de Relatório de log de metas de vendas
===============================================================================================================================
Parametros------:  Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063S()

Local cRep := ""
Local _ahead := {}
Local _alog := {}

cRep:= " SELECT ZGW_COD,ZGW_DESCR,ZGW_DESCD,ZGW_QTD,ZGW_UM,ZGW_QTD2UM,ZGW_2UM,ZGW_COOR,ZGW_NMCOOR,ZGW_ANOMES,ZGW_OPER,ZGW_USER,ZGW_DATA,ZGW_HORA
cRep+= " FROM " + retsqlname("ZGW")

cRep+= " WHERE ZGW_ANOMES = '"+alltrim(MV_PAR01)+"'

If !empty(alltrim(MV_PAR03))
cRep+= " AND ZGW_COOR >= '"+ (MV_PAR02) + "' AND ZGW_COOR <= '" + (MV_PAR03) + "' "
Endif

If !empty(alltrim(MV_PAR05))
	cRep+= " AND ZGW_COD >= '"+ (MV_PAR04) + "' AND ZGW_COD <= '" + (MV_PAR05) + "' ""
Endif

cRep+= " AND D_E_L_E_T_ = ' ' "
cRep+= " ORDER BY ZGW_ANOMES,ZGW_NMCOOR,ZGW_DESCD,ZGW_DATA,ZGW_HORA"

		
If Select("TRB2") >0
	dbSelectArea("TRB2")
	dbCloseArea()
Endif

TCQUERY cRep New Alias "TRB2"
dbSelectArea("TRB2")
		
TRB2->(dbGoTop())

_ahead := {	"Data",; //1
			"Hora",; //2
			"Usuário",; //3
			"Ano/Mês",; //4
			"Operação",; //5
			"Cod Vend",; //6
			"Vendedor",; //7
			"Cod Prod",; //8
			"Produto",; //9
			"Quantidade",; //10
			"Unidade"} //11
		
Do While TRB2->(!EoF())

	aadd(_alog,{stod(TRB2->ZGW_DATA),; //1
				TRB2->ZGW_HORA,; //2
				TRB2->ZGW_USER,; //3
				TRB2->ZGW_ANOMES,; //4
				TRB2->ZGW_OPER,; //5
				TRB2->ZGW_COOR,; //6
				TRB2->ZGW_NMCOOR,; //7
				TRB2->ZGW_COD,; //8
				TRB2->ZGW_DESCR,; //9
				TRB2->ZGW_QTD2UM,; //10
				TRB2->ZGW_2UM}) //11
	TRB2->(Dbskip())

Enddo

If Select("TRB2") >0
	dbSelectArea("TRB2")
	dbCloseArea()
Endif

If len(_alog) > 0

	U_ITListBox( 'Log de registros de meta de vendas' , _ahead , _alog , .T. , 1, "Log de registros de meta de vendas:" )
	
Else

 u_itmsg("Não foram localizados registros de log para os parâmetros indicados.","Atenção",,1)
 
Endif

Return

/*
===============================================================================================================================
Programa--------: AOMS063M
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/02/2019
===============================================================================================================================
Descrição-------: Gatilho para preenchimento dos campos de somente leitura do acols para a tabela ZZS.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS063M()
Local _nPosProd
Local _nPosDesc 
Local _nPosDesD 
Local _nPosUM	 
Local _nPos2UM
Local _cCodProd	 

Begin Sequence
   If IsInCallStack("AOMS063IM")
      _cCodProd := M->ZZS_COD
      _nPosProd := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
      _nPosDesc := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
      _nPosDesD := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
      _nPosUM	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'} )
      _nPos2UM  := aScan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'} )

      aCols[N,_nPosDesc] := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+_cCodProd,1,"")    
      aCols[N,_nPosDesD] := GetAdvFVal("SB1","B1_I_DESCD",xFilial("SB1")+_cCodProd,1,"") 
      aCols[N,_nPosUM]   := GetAdvFVal("SB1","B1_UM",xFilial("SB1")+_cCodProd,1,"")      
      aCols[N,_nPos2UM]  := GetAdvFVal("SB1","B1_SEGUM",xFilial("SB1")+_cCodProd,1,"")   
   EndIf

End Sequence

Return .T.