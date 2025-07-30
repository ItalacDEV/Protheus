/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |24/09/2024| Chamado 48465. Sanado problemas apresentados no Code Analysis
Lucas Borges  |09/10/2024| Chamado 48465. Retirada da fun��o de conout
Lucas Borges  |27/05/2025| Chamado 50617. Revis�es diversas visando padronizar os fontes
Lucas Borges  |29/05/2025| Chamado 50853. Corrigido error.log
==================================================================================================================================================================================================================
Analista        - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==================================================================================================================================================================================================================
Andre           - Alex Wallauer - 24/06/25 - 24/06/25 -  51083 - Retirada da limita��o de largura das colunas do FWMarkBrowse().
==================================================================================================================================================================================================================
*/

#Include 'Protheus.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'FWMVCDEF.CH'

Static cAliasMrk	:= ""

/*
===============================================================================================================================
Programa----------: ACOM015
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/12/2015
Descri��o---------: Rotina respons�vel por Liberar o PC
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM015()

Local aAlias		:= {} As Array
Local aColumns		:= {} As Array
Local cFilPC		:= SuperGetMV("IT_FILWFPC",.F.,"01") As Character
Local _cFilSalva    := cFilAnt As Character

Private nPtol		:= SuperGetMV("IT_PTOLP3",.F.,0) As Numeric
Private aRegsSC7	:= {} As Array
Private aRegsAll	:= {} As Array
Private cPerg		:= "ACOM015" As Character
Private aRotina	 	:= Menudef() As Array
Private _oTemp      := Nil As Object
Private cTempTab    := GetNextAlias() As Character
Private oMrkBrowse  := Nil As Object

dbSelectArea("ZZL")
ZZL->(dbSetOrder(3))
If !ZZL->(dbSeek(xFilial("ZZL") + __cUserID))
	FWAlertInfo("Usu�rio n�o tem permiss�o para utilizar esta funcionalidade. "+;
			"Por favor comunicar a �rea de Compras que � respons�vel por solicitar para TI a libera��o desta funcionalidade.","Libera��o PC - Gestor de Compras - ACOM01501")
	Return(.T.)
Else
	If ZZL->ZZL_GCOM == "N"
		FWAlertInfo("Usu�rio n�o tem permiss�o para utilizar esta funcionalidade. "+;
			"Por favor comunicar a �rea de Compras que � respons�vel por solicitar para TI a libera��o desta funcionalidade.","Libera��o PC - Gestor de Compras - ACOM01502")
		Return(.T.)
	EndIf
EndIf

_cFilSel:=cFilAnt:=_cFilSalva//POR CAUSA DO LOOP
If !Pergunte(cPerg,.T.)
	RETURN .F.
EndIf

IF MV_PAR14 = 2
	_cFilSel:=FWPesqSM0()
	IF EMPTY(_cFilSel) 
	RETURN .F.
	ENDIF
ENDIF

IF !_cFilSel $ cFilPC
	FWAlertInfo("Rotina n�o habilitada para filial: "+"[ "+_cFilSel+" ] "+" selecionada. "+;
			"Por favor comunicar a �rea de Compras que � respons�vel por solicitar para TI a libera��o desta filial.","Libera��o PC - Gestor de Compras - ACOM01503")
	RETURN .F.
ENDIF
cFilAnt:=_cFilSel

aAlias	 := {}

	//--------------------------------------------------------
	//Retorna as colunas para o preenchimento da FWMarkBrowse
	//--------------------------------------------------------
	Processa( {|| aAlias := aCom015Q() } , 'Aguarde!' , 'Verificando os registros...' )
		
	cAliasMrk	:= aAlias[1]
	aColumns 	:= aAlias[2]
	
	If !(cAliasMrk)->(Eof())
		//----------------------
		//Cria��o da MarkBrowse
		//----------------------
		oMrkBrowse:= FWMarkBrowse():New()
		oMrkBrowse:SetAlias(cAliasMrk)
		oMrkBrowse:SetFieldMark("C7_OK")
		oMrkBrowse:SetDescription("")
		oMrkBrowse:AddLegend( '(B1_TIPO = "SV")'		, 'BLUE'	, 'Servi�os')				
		oMrkBrowse:AddLegend( '(((C7_PRECO *100) / BZ_UPRC) - 100 >= (-nPTol) .And. ((C7_PRECO * 100) / BZ_UPRC) - 100 <= nPTol) .Or. (BZ_UPRC = 0 .AND. B1_TIPO <> "SV") '		, 'GREEN'	, 'Dentro da Toler�ncia')
		oMrkBrowse:AddLegend( '(((C7_PRECO * 100) / BZ_UPRC) - 100) > nPTol'														, 'RED'   	, 'Acima da Toler�ncia'		)
		oMrkBrowse:AddLegend( '(((C7_PRECO *100) / BZ_UPRC) - 100) < (-nPTol)'														, 'YELLOW'  , 'Abaixo da Toler�ncia'	)
		oMrkBrowse:SetColumns(aColumns)
		oMrkBrowse:Activate()

	Else
		Help(" ",1,"RECNO")
	EndIf
	
	If !Empty (cAliasMrk)
		(cAliasMrk)->(dbCloseArea())
		Ferase(cAliasMrk+GetDBExtension())
		Ferase(cAliasMrk+OrdBagExt())
		cAliasMrk := ""
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
	Endif

cFilAnt:=_cFilSalva

Return (.T.)

/*
===============================================================================================================================
Programa----------: aCom015Q
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/12/2015
Descri��o---------: Fun��o utilizada para montar a query e arquivo tempor�rio
Parametros--------: Nenhum
Retorno-----------: Array [1] - Tabela tempor�ria / [2] - Colunas do browse
===============================================================================================================================
*/
Static Function aCom015Q()

Local cAliasTrb		:= GetNextAlias() As Character
Local aFields		:= {'C7_FILIAL', 'C7_NUM', 'C7_ITEM', 'C7_QUANT', 'C7_PRECO', 'C7_TOTAL', 'BZ_UPRC', 'C7_TOLERAN', 'C7_EMISSAO', 'C7_I_URGEN', 'C7_I_APLIC', 'C7_PRODUTO', 'C7_DESCRI', 'C7_UM', 'BZ_UCOM', 'C7_FORNECE',  'A2_NREDUZ', 'C7_I_DTFAT', 'C7_I_CDINV', 'ZZI_DESINV', 'C7_OBS', 'Y1_USER', 'Y1_NOME', 'Y1_COD','C7_OK'} As Array
Local cSelect		:= "" As Character
Local aStructSC7	:= SC7->(DBSTRUCT()) As Array
Local aColumns		:= {} As Array
Local dEmissIni		:= mv_par01 As Date
Local dEmissFim		:= mv_par02 As Date
Local cFornecIni	:= mv_par03 As Character
Local cLojaIni		:= mv_par04 As Character
Local cFornecFim	:= mv_par05 As Character
Local cLojaFim		:= mv_par06 As Character
Local cPedidoIni	:= mv_par07 As Character
Local cPedidoFim	:= mv_par08 As Character
Local cCompraIni	:= mv_par09 As Character
Local cCompraFim	:= mv_par10 As Character
Local cUrgente		:= mv_par11 As Character
Local cAplic		:= mv_par12 As Character
Local cInvest		:= mv_par13 As Character

//Variaveis utilizadas para montar o where da query, referente aos filtros preenchidos pelo usuario.
Local cWFilial		:= "" As Character
Local _oTemp		:= Nil As Object
Local _aStructQry	:= {} As Array
Local _nJ, nX, _nI	:= 0 As Numeric
Local _cCmpTemp		:= '' As Character
Local _cCmpSC7		:= '' As Character
Local _nTotRegSC7	:= 0 As Numeric
LOcal _cNomeCampo	:= '' As Character

ProcRegua(0)
IncProc('Inicializando a rotina...')

For nX := 1 To Len(aFields)
	cSelect += aFields[nX] + ", "
Next nX

//======================================
//Tratamento da clausula where da filial
//======================================
cWFilial := "%"
cWFilial += " SC7.C7_FILIAL  = '" + xFilial("SC7") + "' "

//=======================================
//Tratamento da clausula where do urgente
//=======================================
If cUrgente == 1				//Sim
	cWFilial += " AND SC7.C7_I_URGEN = 'S' "
ElseIf cUrgente == 2			//Nao
	cWFilial += " AND SC7.C7_I_URGEN = 'N' "
ElseIf cUrgente == 3			//NF
	cWFilial += " AND SC7.C7_I_URGEN = 'F' "
EndIf

//=========================================
//Tratamento da clausula where da aplicacao
//=========================================
If cAplic == 1				//Consumo
	cWFilial += " AND SC7.C7_I_APLIC = 'C' "
ElseIf cAplic == 2			//Investimento
	cWFilial += " AND SC7.C7_I_APLIC = 'I' "
ElseIf cAplic == 3			//Manuten��o
	cWFilial += " AND SC7.C7_I_APLIC = 'M' "
ElseIf cAplic == 4			//Servi�o
	cWFilial += " AND SC7.C7_I_APLIC = 'S' "
EndIf

//============================================
//Tratamento da clausula where do investimento
//============================================
If !Empty(cInvest)
	cWFilial += " AND SC7.C7_I_CDINV = '" + cInvest + "' "
EndIf
cWFilial += "%"

BeginSQL alias cAliasTrb

SELECT C7_OK, C7_FILIAL, C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_I_URGEN, C7_I_APLIC, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_UM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_VLDESC, 
       C7_I_DTFAT, C7_I_CDINV, ZZI_DESINV, C7_OBS, SC7.R_E_C_N_O_ SC7RECNO, Y1_USER, Y1_NOME, Y1_COD, B1_TIPO,  
       CASE WHEN BZ_UPRC > 0 AND B1_TIPO <> 'SV' THEN (((C7_PRECO - BZ_UPRC) / BZ_UPRC) * 100) WHEN BZ_UPRC = 0 THEN 0 END C7_TOLERAN,
       CASE WHEN BZ_UPRC > 0 AND B1_TIPO = 'SV'  THEN 0 ELSE BZ_UPRC END BZ_UPRC,
        BZ_UCOM
FROM %table:SC7% SC7                                                                                        
JOIN %table:SA2% SA2 ON A2_FILIAL = %xFilial:SA2% AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.%notDel%
JOIN %table:SY1% SY1 ON Y1_FILIAL = %xFilial:SY1% AND (Y1_COD BETWEEN %exp:cCompraIni% AND %exp:cCompraFim%) AND SY1.%notDel%    
JOIN %table:SB1% SB1 ON B1_FILIAL = %xFilial:SB1% AND B1_COD = C7_PRODUTO AND SB1.%notDel%
LEFT JOIN %table:ZZI% ZZI ON ZZI_FILIAL = %xFilial:ZZI% AND ZZI_CODINV = C7_I_CDINV AND ZZI.%notDel%
LEFT JOIN %table:SBZ% SBZ ON  BZ_FILIAL = %xFilial:SBZ% AND     BZ_COD = C7_PRODUTO AND SBZ.%notDel%
WHERE
	%Exp:cWFilial%
	AND C7_EMISSAO BETWEEN %exp:dEmissIni% AND %exp:dEmissFim%
	AND C7_FORNECE BETWEEN %exp:cFornecIni% AND %exp:cFornecFim%                         
	AND C7_LOJA BETWEEN %exp:cLojaIni% AND %exp:cLojaFim%
	AND C7_NUM BETWEEN %exp:cPedidoIni% AND %exp:cPedidoFim%
	AND C7_USER = Y1_USER
    AND C7_CONAPRO = 'B'
    AND C7_RESIDUO <> 'S'
	AND C7_QUJE < C7_QUANT
    AND C7_APROV = 'PENLIB'
	AND SC7.%notDel%
ORDER BY C7_I_URGEN, C7_FILIAL, C7_NUM, C7_ITEM, C7_EMISSAO, C7_FORNECE, C7_LOJA

EndSql

//----------------------------------------------------------------------
// Cria arquivo de dados tempor�rio
//----------------------------------------------------------------------
//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
//================================================================================
If Select(cTempTab) > 0
   (cTempTab)->(DBCloseArea())   
EndIf  
//================================================================================
// Abre o arquivo cTempTab criado dentro do Banco de Dados Protheus.
//================================================================================
_aStructQry := (cAliasTrb)->(DbStruct())

For _nI := 1 To Len(aStructSC7)
    _nJ := AsCan(_aStructQry,{|x| AllTrim(x[1]) == AllTrim(aStructSC7[_nI,1])})
    If _nJ == 0
       Aadd(_aStructQry , aStructSC7[_nI])
    EndIf
Next _nI

For _ni := 1 to len(_aStructQry)
    If _astructqry[_ni][2] == "N" //Garante que tamanho dos campos num�ricos est� igual ao do SX3
  		_astructqry[_ni][3] := 18	
   		_astructqry[_ni][4] := 2
    Endif	
Next _ni

Aadd(_aStructQry, {"DELETED"   ,"L" ,1  ,0})
   
_oTemp := FWTemporaryTable():New( cTempTab,  _aStructQry )
   
//================================================================================
// Cria os indices para o arquivo.
//================================================================================
_oTemp:AddIndex( "01", {"C7_NUM","C7_ITEM","C7_SEQUEN"} )
_oTemp:Create()

IncProc('Lendo os dados...')

(cAliasTrb)->(DbGoTop())

_nTotRegSC7 := (cAliasTrb)->(FCount()) 
cTot:=ALLTRIM(STR(_nTotRegSC7))
nConta:=0
ProcRegua(_nTotRegSC7)

Do While ! (cAliasTrb)->(Eof())
   nConta++
   IncProc('Lendo: '+ALLTRIM(STR(nConta))+" de "+cTot )
   
   (cTempTab)->(DBAPPEND())

   For _nI := 1 To _nTotRegSC7
       _cNomeCampo := AllTrim((cAliasTrb)->(FieldName(_nI)))  
       _cCmpTemp := cTempTab  + "->" + _cNomeCampo 
       _cCmpSC7  := cAliasTrb + "->" + _cNomeCampo 
       &(_cCmpTemp) := &(_cCmpSC7)
   Next _nI
   
   (cAliasTrb)->(DbSkip())
EndDo

//=========================================================
// Fecha a Tabela da Query ap�s gravar tabela temporaria.
//=========================================================
If ( Select( cAliasTrb ) > 0 )
   (cAliasTrb)->(DbCloseArea())
EndIf

nConta:=0
ProcRegua(_nTotRegSC7)

DBSelectArea(cTempTab)
(cTempTab)->( DBGoTop() )
While (cTempTab)->(!Eof())
	nConta++
	IncProc('Lendo: '+ALLTRIM(STR(nConta))+" de "+cTot )
	aAdd( aRegsAll , { (cTempTab)->C7_FILIAL, (cTempTab)->C7_NUM, (cTempTab)->C7_ITEM } )
	
	(cTempTab)->( DBSkip() )
EndDo

(cTempTab)->( DBGoTop() )

For nX := 1 To Len(aFields)
	If	!aFields[nX] == "SC7_OK" .And. aFields[nX] $ cSelect
		AAdd(aColumns,FWBrwColumn():New())
		If aFields[nX] == "C7_EMISSAO" .Or. aFields[nX] == "C7_I_DTFAT" .Or. aFields[nX] == "BZ_UCOM"
			aColumns[Len(aColumns)]:SetData( &("{||StoD(" + aFields[nX] + ")}") )
		Else
			aColumns[Len(aColumns)]:SetData( &("{||" + aFields[nX] + "}") )
		EndIf
		If "C7_TOLERAN" $ aFields[nX]
			aColumns[Len(aColumns)]:SetTitle("Diferen�a %") 
			aColumns[Len(aColumns)]:SetSize(TamSX3("C7_PRECO")[1]) 
			aColumns[Len(aColumns)]:SetDecimal(TamSX3("C7_PRECO")[2])
		Else
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aFields[nX])) 
			aColumns[Len(aColumns)]:SetSize(TamSX3(aFields[nX])[1]) 
			aColumns[Len(aColumns)]:SetDecimal(TamSX3(aFields[nX])[2])
		EndIf
		If "C7_PRECO" $ aFields[nX] .Or. "C7_TOLERAN" $ aFields[nX]
	  		aColumns[Len(aColumns)]:SetPicture("@E 999,999,999.999")		    
		ElseIf "Y1" $ aFields[nX]
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SY1",aFields[nX]))
		ElseIf "SA2" $ aFields[nX]
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SA2",aFields[nX]))
		ElseIf "ZZI" $ aFields[nX]
			aColumns[Len(aColumns)]:SetPicture(PesqPict("ZZI",aFields[nX]))
		ElseIf "BZ" $ aFields[nX]
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SBZ",aFields[nX]))
		Else
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SC7",aFields[nX]))
		EndIf
	EndIf
Next nX

Return( { cTempTab , aColumns } )

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/12/2015
Descri��o---------: Fun��o utilizada para cria��o do menu
Parametros--------: Nenhum
Retorno-----------: aRotina - Op��es de menu
===============================================================================================================================
*/
Static Function MenuDef()     

Local aRot := {} As Array

ADD OPTION aRot Title 'Visualizar'				Action 'U_Acom015V()'						OPERATION 2 ACCESS 0
ADD OPTION aRot Title 'Efetivar Liber.'			Action 'U_Acom015F()'						OPERATION 3 ACCESS 0
ADD OPTION aRot Title 'E-mail'					Action 'U_Acom015E()'						OPERATION 2 ACCESS 0
ADD OPTION aRot Title 'Planilha'				Action 'Processa( {|| U_ACOM015P() } )'		OPERATION 2 ACCESS 0

Return(Aclone(aRot))

/*
===============================================================================================================================
Programa----------: Acom015V
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/12/2015
Descri��o---------: Fun��o utilizada para visualizar um �nico pedido selecionado.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function Acom015V()

Local aArea	:= FwGetArea() As Array
SaveInter()

Private lIntGC 		:= IIf((SuperGetMV("MV_VEICULO",,"N")) == "S" .And. SC7->( FieldPos('C7_CODPRO') ) > 0 ,.T.,.F.) As Logical
Private l120Auto	:= .F. As Logical
Private CCADASTRO	:= "Pedido de Compras" As Character
Private nTipoPed	:= 1 As Numeric
Private aRotina		:= {} As Rotina

aAdd(aRotina,{"Pesquisar"		,"PesqBrw"		, 0, 1, 0, .F. }) //"Pesquisar"
aAdd(aRotina,{"Visualizar"		,"A120Pedido"	, 0, 2, 0, Nil }) //"Visualizar"
aAdd(aRotina,{"Incluir"			,"A120Pedido"	, 0, 3, 0, Nil }) //"Incluir"
aAdd(aRotina,{"Alterar"			,"A120Pedido"	, 0, 4, 6, Nil }) //"Alterar"
aAdd(aRotina,{"Excluir"			,"A120Pedido"	, 0, 5, 7, Nil }) //"Excluir"
aAdd(aRotina,{"Copia"			,"A120Copia"	, 0, 9, 0, Nil }) //"Copia"
aAdd(aRotina,{"Imprimir"		,"A120Impri"	, 0, 2, 0, Nil }) //"Imprimir"
aAdd(aRotina,{"Legenda"			,"A120Legend"	, 0, 2, 0, .F. }) //"Legenda"
aAdd(aRotina,{"Conhecimento"	,"MsDocument"	, 0, 4, 0, Nil }) //"Conhecimento" 

dbSelectArea("SC7")
SC7->(dbSetOrder(1))
SC7->(dbSeek(aRegsAll[oMrkBrowse:OBROWSE:NAT][1] + aRegsAll[oMrkBrowse:OBROWSE:NAT][2] + aRegsAll[oMrkBrowse:OBROWSE:NAT][3]))

A120Pedido("SC7",SC7->(Recno()),2)

RestInter()
FwRestArea(aArea)

Return

/*
===============================================================================================================================
Programa----------: Acom015F
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/12/2015
Descri��o---------: Fun��o utilizada para efetivar pedidos selecionados.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function Acom015F()

Local aArea			:= FwGetArea() As Array
Local cNumPC		:= "" As Character
Local nUsado		:= 0 As Numeric
Local cFilPC		:= "" As Character
Local cGetGrpA		:= Space(TamSX3("AL_COD")[1]) As Character
Local cGetGrpN		:= Space(TamSX3("AL_NOME")[1]) As Character
Local oGroupA		:= Nil As Logical
Local oSayGrpA		:= Nil As Logical
Local oSButton1		:= Nil As Logical
Local oSButtonOk	:= Nil As Logical
Local nX,nA,nY,_niz	:= 0 As Numeric
Local aFields		:= {"AL_ITEM","AL_COD","AL_USER","AL_NOME","AL_NIVEL","AL_TPLIBER"} As Array
Local aAlterFields	:= {} As Array
Local aColsAux		:= {} As Array
Local nOpca			:= 0 As Numeric
Local nTotLib		:= 0 As Numeric
Local aAlias		:= {} As Array
Local _aHeadAux     := {} As Array

Private aHeader		:= {} As Array
Private aCols		:= {} As Array

Private oDlgApr		:= Nil As Object
Private oMSNewApr	:= Nil As Object

//Monta array a partir do fwmarkbrowse

aRegsSC7 := {}

(cAliasMrk)->( DbGotop() )
Count to _nfim
(cAliasMrk)->( DbGotop() )

_cmark := oMrkBrowse:Mark()

SC7->(dbSetOrder(1))

For _niz := 1 to _nfim
	If oMrkBrowse:IsMark(_cmark)
		_npro := Ascan(aRegsSC7,{|x| alltrim(x[2]) = (cAliasMrk)->C7_NUM } )
		If _npro == 0
           IF SC7->(dbSeek((cAliasMrk)->C7_FILIAL+(cAliasMrk)->C7_NUM))
			  aAdd( aRegsSC7 , { (cAliasMrk)->C7_FILIAL, (cAliasMrk)->C7_NUM , SC7->(RECNO()) }  )
		   ENDIF  
		Endif
	Endif
	
	(cAliasMrk)->(  Dbskip() )
Next _niz

If Len(aRegsSC7) > 0
	If FWAlertYesNo("A libera��o do PC e o Aprovador informado, ser� efetivado em todos os PC's selecionados na tela anterior. Deseja Continuar?","Libera��o PC - Gestor de Compras - ACOM01504")
		//Monta acols e aheader
		aHeader:={}
		aCols:={}
		//   FillGetDados(nOpc>,cAlias>,[nOrder],cSeekKey],bSeekWhile],uSeekFor],aNoFields],aYesFields]lOnlyYes], cQuery],bMontCols], [ lEmpty], [ aHeaderAux], [ aColsAux], [ bAfterCols], [ bBeforeCols], [ bAfterHeader], [ cAliasQry], [ bCriaVar], [ lUserFields], [ aYesUsado] )
		//     FillGetDados(    2,"SAL"   ,1      ,         ,           ,{||.T.}  ,          ,           ,        ,        ,          ,.T.)
		For nUsado := 1 to len(aFields)
			_cCampo:=aFields[nUsado]
			_cUsado:=Getsx3cache(_cCampo,"X3_USADO")
			If X3USO(_cUsado)
				aAdd( aHeader , {Getsx3cache(_cCampo,"X3_TITULO") ,;
				                 Getsx3cache(_cCampo,"X3_CAMPO") ,;
				                 Getsx3cache(_cCampo,"X3_PICTURE") ,;
			                 	 Getsx3cache(_cCampo,"X3_TAMANHO") ,;
				                 Getsx3cache(_cCampo,"X3_DECIMAL") ,;
				                 Getsx3cache(_cCampo,"X3_VALID") ,;
				                 _cUsado��������������������� ,;
				                 Getsx3cache(_cCampo,"X3_TIPO") ,;
				                 Getsx3cache(_cCampo,"X3_F3") ,;
				                 Getsx3cache(_cCampo,"X3_CONTEXT") })
			Endif
		Next

       _aHeadAux := AClone(aHeader)
       aHeader:={}
       
       //                             1                2                 3              4               5                6               7          8              9              10        
       //Aadd(aHeader, {	AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL ,SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_CONTEXT, SX3->X3_CBOX})
       
       For nX := 1 to Len(aFields)
           nY := Ascan(_aHeadAux, {|x| AllTrim(x[2]) == AllTrim(aFields[nX])})
           If nY > 0
              If _aHeadAux[nY, 9] <> "V" .Or. AllTrim(_aHeadAux[nY, 2]) == 'AL_NOME'
                 Aadd(aHeader,_aHeadAux[nY])
                 If _aHeadAux[nY, 8] == "C" 
			        Aadd(aColsAux, "")
				 ElseIf _aHeadAux[nY, 8] == "N" 
	                Aadd(aColsAux, 0)
				 ElseIf _aHeadAux[nY, 8] == "D" 
	                Aadd(aColsAux, StoD(""))
				 EndIf
			  EndIf
           EndIf
        Next nX
	   
		// Define field properties
		Aadd(aColsAux, .F.)
		Aadd(aCols, aColsAux)
        nLin:=260
		nCol:=600
		nLin1:=110
		nLin2:=nLin1+3
		nLin3:=nLin2+3
		nCol1:=295
		nCol2:=nCol1+4
			
		DEFINE MSDIALOG oDlgApr TITLE "Grupos de Aprova��o" FROM 000, 000  TO nLin, nCol COLORS 0, 16777215 PIXEL

			@ 005, 006 SAY   oSayGrpA PROMPT "Grupo Aprovador" SIZE 044, 007 OF oDlgApr COLORS 0, 16777215 PIXEL
			@ 005, 054 MSGET cGetGrpA SIZE 032, 010 OF oDlgApr COLORS 0, 16777215 F3 "SAL" VALID {|| ACOM015Z(cGetGrpA, @cGetGrpN)} PIXEL
			@ 017, 054 MSGET cGetGrpN SIZE 158, 010 OF oDlgApr COLORS 0, 16777215 PIXEL

			@ 031, 003 GROUP oGroupA TO nLin2, nCol2 PROMPT "Aprovadores" OF oDlgApr PIXEL
			oMSNewApr := MsNewGetDados():New( 038, 007, nLin1, nCol1, 0, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgApr, aHeader, aCols)

			DEFINE SBUTTON oSButtonOk FROM nLin3, 091 TYPE 01 OF oDlgApr ENABLE Action (nOpca := 1, oDlgApr:End())
			DEFINE SBUTTON oSButton1  FROM nLin3, 170 TYPE 02 OF oDlgApr ENABLE Action oDlgApr:End()
			
		ACTIVATE MSDIALOG oDlgApr CENTERED
						
		If nOpca == 1
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
		
			For nY := 1 To Len(aRegsSC7)
				SC7->(Dbgotop())
				If SC7->(dbSeek(aRegsSC7[nY][1] + aRegsSC7[nY][2]))
					_nTotPed:=0
					_nItem:=0
					MaFisEnd()
					aRefImp	:= MaFisRelImp('MT100',{"SC7"})
					aStru	:= FWFormStruct(3,"SC7")[1]
					_cMens:=""
					Begin Transaction
						DO While (!EOF()) .And. aRegsSC7[nY][1] == SC7->C7_FILIAL .And. aRegsSC7[nY][2] == SC7->C7_NUM
							MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",aRefImp)						
					        MaFisIniLoad(1)
							_nItem++
					        For nA := 1 To Len(aRefImp)
					        	nPos := aScan(aStru,{|x| AllTrim(x[3]) == AllTrim(aRefImp[nA][2])})
					        	If nPos > 0 .And. !aStru[nPos,14]
					        		MaFisLoad(aRefImp[nA][3],SC7->(&(aRefImp[nA][2])),1)
									_cMens+=SC7->C7_NUM+";("+STRZERO(_nItem,3)+");"+aRefImp[nA][3]+";"+aRefImp[nA][2]+";"+CValToChar(SC7->(&(aRefImp[nA][2])))+CHR(13)+CHR(10)
					        	Endif
					        Next nA
							MaFisRecal("",1)
					        MaFisEndLoad(1)
					        MaFisAlt("IT_ALIQIPI",SC7->C7_IPI    ,1)
					        MaFisAlt("IT_ALIQICM",SC7->C7_PICM   ,1)
				            MaFisAlt("IT_VALSOL" ,SC7->C7_ICMSRET,1)
					        MaFisWrite(1,"SC7",1)
					        nTotLib += MaFisRet(1,"IT_TOTAL")
					        MaFisEnd()

							SC7->(RecLock("SC7",.F.))
							SC7->C7_APROV	:= cGetGrpA
							SC7->C7_I_GCOM	:= __cUserID
							SC7->C7_I_DTLIB	:= Date()
							SC7->C7_I_HRLIB	:= Time()
							SC7->(MsUnLock())
							SC7->(dbSkip())
						End
                        _cMens:=STRTRAN(_cMens,".",",")
					
						If cFilPC + cNumPC <> aRegsSC7[nY][1] + aRegsSC7[nY][2]
							cFilPC := aRegsSC7[nY][1]
							cNumPC := aRegsSC7[nY][2]
							
							//Inclui linhas de aprovador no SCR
							SAL->(Dbsetorder(2))//AL_FILIAL+AL_COD+AL_NIVEL
							If SAL->(Dbseek(xfilial("SAL")+cGetGrpA))
								nConta:=0		
								Do while !(SAL->(Eof())) .and. alltrim(cGetGrpA) == SAL->AL_COD
									IF SAL->AL_MSBLQL = '1' 
										SAL->(Dbskip())  
										LOOP									   
									ENDIF
									nConta++
									SCR->(Reclock("SCR",.T.))
									SCR->CR_FILIAL 	:= aRegsSC7[nY][1]
									SCR->CR_num 	:= aRegsSC7[nY][2]
									SCR->CR_TIPO 	:= "PC"
									SCR->CR_USER	:= SAL->AL_USER
									SCR->CR_APROV	:= SAL->AL_APROV
									SCR->CR_NIVEL	:= SAL->AL_NIVEL
									SCR->CR_STATUS	:= IF(nConta > 1 ,'01','02')//N�o olhamos o nivel mais pq o aprovador anterior pode esta bloqueado
									SCR->CR_EMISSAO := DDATABASE
									SCR->CR_MOEDA	:= 1
									SCR->CR_TXMOEDA	:= 1
									SCR->CR_GRUPO  	:= cGetGrpA
									SCR->CR_TOTAL 	:= nTotLib
									SCR->(Msunlock())
									
									SAL->(Dbskip())
								Enddo
							Endif
						EndIf
					End Transaction
				EndIf
			Next nY
			FWAlertSuccess('Processo conclu�do com sucesso.',"ACOM01505")

			aRegsAll := {}              
			cGetGrpA := ' '                 
			aAlias	 := {}

			Processa( {|| aAlias := aCom015Q() } , 'Aguarde!' , 'Verificando os registros...' )

			aRegsSC7	:= {}

			cAliasMrk	:= aAlias[1]
			aColumns 	:= aAlias[2]

			//----------------------
			//Cria��o da MarkBrowse
			//----------------------
			oMrkBrowse:SetAlias(cAliasMrk)   
			oMrkBrowse:Refresh()
			oMrkBrowse:Gotop()
		EndIf
	Else
		FWAlertInfo("Processo cancelado pelo usu�rio.","Libera��o PC - Gestor de Compras - ACOM01506")
	EndIf
Else
	FWAlertInfo("Favor selecionar pelo menos 1 registro, para poder efetivar a Libera��o do PC.","Libera��o PC - Gestor de Compras - ACOM01507")
EndIf

FwRestArea(aArea)                                      

Return

/*
===============================================================================================================================
Programa----------: ACOM015Z
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 10/12/2015
Descri��o---------: Fun��o criada para carregamento do grid.
Parametros--------: cGetGrpA - C�digo do grupo
                    cGetGrpN - Nome do grupo
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ACOM015Z(cGetGrpA As Character, cGetGrpN As Character)

Local aArea		:= GetArea() As Array
Local cQuery	:= "" As Character
Local cAlias	:= GetNextAlias() As Character
Local nX		:= 0 As Numeric
Local aColsAux	:= {} As Array
Local aForaLim	:= {} As Array
Local lRet		:= .T. As Logical
Local _cNome,nY,_cObs:="" As Character
Local _cAlias   := GetNextAlias() As Character
LOCAL _cPV      := SC7->C7_NUM As Character
Local _bGetMv   := {|x| GETMV("MV_SIMB"+x )} As Codeblock

cQuery := "SELECT R_E_C_N_O_ SALREC " 
cQuery += "FROM " + RetSqlName("SAL") + " "
cQuery += "WHERE AL_FILIAL = '" + xFilial("SAL") + "' "
cQuery += "  AND AL_COD = '" + cGetGrpA + "' "
cQuery += "  AND AL_MSBLQL = '2' "
cQuery += "  AND D_E_L_E_T_ = ' ' "
cQuery += "  ORDER BY AL_COD, AL_NIVEL  "
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,cAlias)
    
(cAlias)->( dbGotop() )

If (cAlias)->( !Eof() )
	For nY := 1 To Len(aRegsSC7)
		SC7->(Dbgoto(aRegsSC7[nY][3]))
		_cPV:=SC7->C7_NUM
		
		BeginSQL Alias _cAlias
			SELECT SUM(SC7.C7_TOTAL) C7TOTAL
			FROM %Table:SC7% SC7
			WHERE SC7.C7_FILIAL = %xFilial:SC7% AND	SC7.C7_NUM = %Exp:_cPV% AND ;
			SC7.%NotDel%
		EndSQL
		_nTotal:=(_cAlias)->C7TOTAL
		(_cAlias)->(dbCloseArea())
		DHL->(dbSetOrder(1))
		
		(cAlias)->( dbGotop() )
		DO While (cAlias)->( !Eof() )
			
			SAL->(DBGOTO( (cAlias)->SALREC) )
			_cNome:=Posicione("SAK",2,xFilial("SAK")+SAL->AL_USER,"AK_NOME")
			
			_nLimPerfil:=0
			_cMoePV :=ALLTRIM(Eval(_bGetMv, STR(SC7->C7_MOEDA,1)))
			_cMoeDHL:=""
			IF DHL->(MsSeek(xFilial("DHL")+SAL->AL_PERFIL))//Perfil
				_nLimPerfil:=DHL->DHL_LIMMAX
				_cMoeDHL:=ALLTRIM(Eval(_bGetMv, STR(DHL->DHL_MOEDA,1)))
				_cObs:=""
				IF _nTotal > _nLimPerfil
					_cObs:=" - Acima do Limite"
				ENDIF
				IF SC7->C7_MOEDA <> DHL->DHL_MOEDA
					_cObs+=" - Moeda diferente"
				ENDIF
			ELSE
				_cObs:=" - Perfil n�o encontrado nessa filial: "+xFilial("DHL")+" "+SAL->AL_PERFIL
			ENDIF
			
            IF !EMPTY(_cObs)
				AADD(aForaLim,{.F. , _cNome , _cMoeDHL+" "+STR(_nLimPerfil,15,2) ,SC7->C7_FILIAL+"-"+_cPV, _cMoePV+" "+STR(_nTotal,15,2), _cObs})
				lRet := .F.
			ELSE
				AADD(aForaLim,{.T. , _cNome , _cMoeDHL+" "+STR(_nLimPerfil,15,2) ,SC7->C7_FILIAL+"-"+_cPV, _cMoePV+" "+STR(_nTotal,15,2), " - OK" })
			ENDIF
			
			(cAlias)->(dbSkip())
		ENDDO
	NEXT nY
	
	oMSNewApr:aCols := {}
	(cAlias)->( dbGotop() )
	DO While (cAlias)->( !Eof() ) .AND. lRet
		SAL->(DBGOTO( (cAlias)->SALREC) )
		cGetGrpN := SAL->AL_DESC
		
		aColsAux := {}
		For nX := 1 To Len(aHeader)
			If AllTrim(aHeader[nX,2]) == "AL_NOME"
				_cNome:=Posicione("SAK",2,xFilial("SAK")+SAL->AL_USER,"AK_NOME")
				aAdd(aColsAux, _cNome)
			ElseIf aHeader[nX,8]  == "D" // SX3->X3_TIPO == "D"
				aAdd(aColsAux, StoD(SAL->&(aHeader[nX,2])))
			Else
				aAdd(aColsAux, SAL->&(aHeader[nX,2]) )
			EndIf
		Next nX
		Aadd(aColsAux, .F.)
		Aadd(oMSNewApr:aCols, aColsAux)
		
		(cAlias)->(dbSkip())
	ENDDO
Else
	FWAlertInfo("Grupo informado n�o existe, favor informar um c�digo de grupo existente.","Libera��o PC - Gestor de Compras - ACOM01508")
	lRet := .F.
EndIf

IF LEN(aForaLim) > 0 .AND. !lRet
	bBloco:={|| U_ITListBox('Lista de aprovadores com limite de aprova��o',;
	{" ",'Aprovador','Limite',"Pedido",'Total PV',"Observa��o"},aForaLim,.F.,4,,,;
	{ 10,         90,      50,      30,        50,         90}) }
	
	U_ITMSG("A indica��o n�o poder� ser feita para este grupo de aprova��o...",'Aten��o!',;
	"Pois existe aprovador que n�o tem limite suficiente para aprovar o valor do pedido ou a moeda do perfil � diferente: VER Mais Detalhes",1,,,,,,bBloco)
	
	lRet := .F.
ENDIF

(cAlias)->( dbCloseArea() )	

oMSNewApr:oBrowse:Refresh()
oMSNewApr:Refresh()

FwRestArea(aArea)

Return(lRet)

/*
===============================================================================================================================
Programa----------: Acom015E
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 18/02/2016
Descri��o---------: Fun��o criada enviar e-mail ao gestor, dos PC's pendentes de aprova��o.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM015E()

Local _aTables		:= {"SC7","SA2","SY1","ZZI","ZZL"} As Array
Local _lCriaAmb		:= .F. As Logical
Local _aAlias		:= {} As Array
Local _cAlias		:= "" As Character
Local _aColumns 	:= {} As Array
Local _cNumPC		:= "" As Character
Local _cFilial		:= "" As Character
Local _cHtml		:= "" As Character
Local cTo			:= "" As Character
Local cGetCc		:= "" As Character
Local cMailCom		:= "" As Character
Local cGetAssun		:= "" As Character
Local cGetAnx		:= "" As Character
Local _cQry			:= "" As Character
Local _aConfig		:= {} As Array
Local _cEmlLog		:= "" As Character

Private _cHostWF	:= "" As Character
Private _dDtIni		:= "" As Date

//=============================================================
// Verifica a necessidade de criar um ambiente, caso nao esteja
// criado anteriormente um ambiente, pois ocorrera erro
//=============================================================
If Type("oMrkBrowse") <> "O"  
   _lCriaAmb := .T.
EndIf

If _lCriaAmb

	//=====================
	// Nao consome licensas
	//=====================
	RPCSetType(3)

	//===========================================
	// Seta o ambiente com a empresa 01 filial 01
	//===========================================
	RpcSetEnv("01","01",,,,"SCHEDULE_WF_APROVACAO",_aTables)

	//========================================================================================
	// Mensagem que ficara armazenada no arquivo totvsconsole.log para posterior monitoramento
	//======================================================================================== 
    FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01509"/*cMsgId*/, "ACOM01509 - Gerando envio de e-mail ao aprovador na data: " + Dtoc(DATE()) + " - " + Time()/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

EndIf

_aConfig	:= U_ITCFGEML('')
_cHostWF 	:= SuperGetMV("IT_WFHOSTS",.F.,"http://wfteste.italac.com.br:4034/")
_dDtIni		:= DtoS(SuperGetMV("IT_WFDTINI",.F.,"26/11/2025"))

If _lCriaAmb
	_aAlias := aCom015M(_lCriaAmb)
Else
	FwMsgRun(,{|| _aAlias := aCom015M(_lCriaAmb)},,"Aguarde, gerando e processando e-mail...")
EndIf

_cAlias		:= _aAlias[1]
_aColumns 	:= _aAlias[2]

dbSelectArea(_cAlias)
(_cAlias)->(dbGoTop())
            
_cNumPC		:= (_cAlias)->C7_NUM
_cFilial	:= (_cAlias)->C7_FILIAL

_cHtml += '<html>'
_cHtml += '<head>'
_cHtml += '<meta charset="UTF-8">'
_cHtml += '<meta name="description" content="Free Web tutorials">'
_cHtml += '<meta name="keywords" content="HTML,CSS,XML,JavaScript">'
_cHtml += '<meta name="author" content="Hege Refsnes">'
_cHtml += '<title>Pedido de Compras</title>'
_cHtml += '</head>'

_cHtml += '<style type="text/css"><!--'
_cHtml += 'table.bordasimples { border-collapse: collapse; }'
_cHtml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cHtml += 'td.grupos	{ font-family:VERDANA; font-size:20px; V-align:middle; background-color: #C6E2FF; color:#000080; }'
_cHtml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #EEDD82; }'
_cHtml += 'td.mensagem	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cHtml += 'td.texto	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; }'
_cHtml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #DDDDDD; }'
_cHtml += 'td.totais	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #7f99b2; color:#FFFFFF; }'
_cHtml += '--></style>'

_cHtml += '<body bgcolor="#FFFFFF">'
_cHtml += '<center>'
_cHtml += '<table width="100%" cellspacing="0" cellpadding="2" border="0">'
_cHtml += '  <tr>'
_cHtml += '    <td width="02%" class="grupos">'
_cHtml += '      <center><img src="http://www.italac.com.br/wp-content/themes/italac/assets/images/logo.svg" width="100px" height="030px"></center>'
_cHtml += '	</td>'
_cHtml += '    <td width="98%" class="grupos"><center>Lista de Pedidos de Compras Pendente Libera��o do Gestor</center></td>'
_cHtml += '  </tr>'
_cHtml += '</table>'
_cHtml += '<table border="0" width="100%">'
_cHtml += '	<tr>'
_cHtml += '		<td valign="top" class="texto">'
_cHtml += '			<br><br>Existe(m) Pedido(s) de Compra(s) pendente(s) para sua avalia��o.'
_cHtml += '		</td>'
_cHtml += '	</tr>'
_cHtml += '</table>'
_cHtml += '<br>'

_cHtml += '<table width="100%" border="0" CellSpacing="2" CellPadding="0">'
_cHtml += '<tr>'
_cHtml +=     '<td align="center" class="totais">Filial</td>'
_cHtml +=     '<td align="center" class="totais">Data Emiss�o</td>'
_cHtml +=     '<td align="center" class="totais">N�m Pedido</td>'
_cHtml +=     '<td align="center" class="totais">Total PC</td>'
_cHtml +=     '<td align="center" class="totais">Comprador</td>'
_cHtml +=     '<td align="center" class="totais">Grupo Compras</td>'
_cHtml +=     '<td align="center" class="totais">Fornecedor</td>'
_cHtml +=     '<td align="center" class="totais">Data Entrega</td>'
_cHtml +=     '<td align="center" class="totais">Data Faturamento</td>'
_cHtml +=     '<td align="center" class="totais">Compra Direta</td>'
_cHtml +=     '<td align="center" class="totais">Urgente</td>'
_cHtml +=     '<td align="center" class="totais">Aplica��o</td>'
_cHtml +=     '<td align="center" class="totais">Investimento</td>'
_cHtml += '</tr>'

While !(_cAlias)->(Eof())

	_cHtml += '<tr>'
	_cHtml +=     '<td valign="top" align="center"	class="itens">' + (_cAlias)->C7_FILIAL + " - " + AllTrim(FwFilialName(cEmpAnt, (_cAlias)->C7_FILIAL)) + '</td>'
    _cHtml +=     '<td valign="top" align="center"	class="itens">' + DtoC((_cAlias)->C7_EMISSAO) + '</td>'
	_cHtml +=     '<td valign="top" align="left"	class="itens">' + (_cAlias)->C7_NUM + '</td>'
	_cHtml +=     '<td valign="top" align="right"	class="itens">' + Transform((_cAlias)->C7_TOTAL, PesqPict("SC7","C7_TOTAL")) + '</td>'
	_cHtml +=     '<td valign="top" align="left"	class="itens">' + SubStr(U_Acom015N((_cAlias)->C7_USER), 1, At(" ", U_Acom015N((_cAlias)->C7_USER))-1) + '</td>'
	_cHtml +=     '<td valign="top" align="center"	class="itens">' + (_cAlias)->C7_GRUPCOM + '</td>'
	_cHtml +=     '<td valign="top" align="left"	class="itens">' + (_cAlias)->C7_FORNECE + " - " + AllTrim((_cAlias)->A2_NREDUZ) + '</td>'
    _cHtml +=     '<td valign="top" align="center"	class="itens">' + DtoC((_cAlias)->C7_DATPRF) + '</td>'
	_cHtml +=     '<td valign="top" align="center"	class="itens">' + DtoC((_cAlias)->C7_I_DTFAT) + '</td>'
	_cHtml +=     '<td valign="top" align="center"	class="itens">' + (_cAlias)->C7_I_CMPDI + '</td>'
	_cHtml +=     '<td valign="top" align="center"	class="itens">' + (_cAlias)->C7_I_URGEN + '</td>'
	_cHtml +=     '<td valign="top" align="center"	class="itens">' + (_cAlias)->C7_I_APLIC + '</td>'
	_cHtml +=     '<td valign="top" align="left"	class="itens">' + (_cAlias)->ZZI_DESINV + '</td>'
	_cHtml += '</tr>'
	_cHtml += '<tr>'
	_cHtml +=     '<td valign="top" align="left" colspan="13" class="itens">OBS: ' + AllTrim(Posicione("SC7",1,(_cAlias)->C7_FILIAL + (_cAlias)->C7_NUM,"C7_OBS")) + '</td>'
	_cHtml += '</tr>'
	_cHtml += '<tr>'
	_cHtml +=     '<td valign="top" align="left" colspan="13">&nbsp;</td>'
	_cHtml += '</tr>'

	(_cAlias)->(dbSkip())
End

_cHtml += '</table>'
_cHtml += '</center>'

_cHtml += '<br>'
_cHtml += '<br>'

_cHtml += '<table width="38%" border="0" CellSpacing="2" CellPadding="0">'
_cHtml += '	<tr>'
_cHtml += '		<td valign="top" align="center" class="mensagem"><font color="red">Mensagem enviada autom�tica, favor n�o responder este e-mail.</fonte></td>'
_cHtml += '	</tr>'
_cHtml += '</table>'
_cHtml += '<br>'
_cHtml += '<br>'
_cHtml += '    <tr>'
_cHtml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cHtml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [ACOM015]</td>'
_cHtml += '    </tr>'
_cHtml += '</body>'
_cHtml += '</html>'

cGetAssun	:= "Lista de Pedidos de Compras Pendente Libera��o do Gestor"

If _lCriaAmb
	_cQry := "SELECT ZZL_EMAIL "
	_cQry += "FROM " + RetSqlName("ZZL") + " "
	_cQry += "WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "' "
	_cQry += "  AND ZZL_GCOM = 'S' "
	_cQry += "  AND D_E_L_E_T_ = ' ' "
	_cQry := ChangeQuery(_cQry)
	MPSysOpenQuery(_cQry,"TRBZZL")

	TRBZZL->(dbGoTop())
	
	While !TRBZZL->(Eof())
		cTo += AllTrim(TRBZZL->ZZL_EMAIL) + ","
		TRBZZL->(dbSkip())
	EndDo

	cTo := SubStr(cTo,1,Len(cTo)-1)
	TRBZZL->(dbCloseArea())
Else
	cTo      := Lower(AllTrim(UsrRetMail(RetCodUsr())))  
EndIf      

//====================================
// Chama a fun��o para envio do e-mail
//====================================
U_ITENVMAIL( ""  , cTo    , cGetCc , cMailCom, cGetAssun, _cHtml  , cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

If !Empty( _cEmlLog ) .And. !_lCriaAmb
	FWAlertSuccess(_cEmlLog,'T�rmino do processamento! - ACOM01510')
Else
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01511"/*cMsgId*/, "ACOM01511 - T�rmino do processamento de e-mail de libera��o do gestor: - " + _cEmlLog/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
EndIf

If _lCriaAmb

	//=============================================================
	// Limpa o ambiente, liberando a licen�a e fechando as conexoes
	//=============================================================
	RpcClearEnv()
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01512"/*cMsgId*/, "ACOM01512 - Termino do envio do workflow das solicita��es de compras"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

EndIf

aRegsAll := {}  
cGetGrpA := ' '                 
aAlias	 := {}

If !_lCriaAmb
   Processa( {|| aAlias := aCom015Q() } , 'Aguarde!' , 'Verificando os registros...' ) 
   cAliasMrk:= aAlias[1]
   aColumns := aAlias[2]
ENDIF
aRegsSC7	:= {}

//----------------------
//Cria��o da MarkBrowse
//----------------------
If Type("oMrkBrowse") = "O"  
   oMrkBrowse:SetAlias(cAliasMrk)    
   oMrkBrowse:Refresh()
   oMrkBrowse:Gotop()
ENDIF   

Return

/*
===============================================================================================================================
Programa----------: aCom015M
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/12/2015
Descri��o---------: Fun��o utilizada para montar a query e arquivo tempor�rio.
Parametros--------: _lCriaAmb - .T. = indica a cria��o do ambiente. .F. = n�o deve ser criado ambiente.
Retorno-----------: Array [1] - Tabela tempor�ria / [2] - Colunas do browse.
===============================================================================================================================
*/
Static Function aCom015M(_lCriaAmb As Logical)

Local cAliasTrb		:= GetNextAlias() As Character
Local aFields		:= {'C7_FILIAL', 'C7_EMISSAO', 'C7_NUM', 'C7_TOTAL', 'C7_USER', 'C7_GRUPCOM', 'C7_FORNECE', 'C7_LOJA', 'A2_NOME', 'C7_DATPRF', 'C7_I_CMPDI', 'C7_I_URGEN', 'C7_I_APLIC',  'C7_I_CDINV', 'ZZI_DESINV', 'C7_OBS', 'Y1_USER', 'Y1_NOME', 'Y1_COD'} As Array
Local cSelect		:= "" As Character
Local aStructSC7	:= SC7->(DBSTRUCT()) As Array
Local aColumns		:= {} As Array
Local nX			:= 0 As Numeric			
Local cTempTab		:= GetNextAlias() As Character
Local dEmissIni		:= CtoD("//") As Date
Local dEmissFim		:= CtoD("//") As Date
Local cFornecIni	:= "      " As Character
Local cLojaIni		:= "    " As Character
Local cFornecFim	:= "ZZZZZZ" As Character
Local cLojaFim		:= "ZZZZ" As Character
Local cPedidoIni	:= "      " As Character
Local cPedidoFim	:= "ZZZZZZ" As Character
Local cCompraIni	:= "      " As Character
Local cCompraFim	:= "ZZZZZZ" As Character
Local cUrgente		:= "" As Character
Local cAplic		:= "" As Character
Local cInvest		:= "" As Character

//Variaveis utilizadas para montar o where da query, referente aos filtros preenchidos pelo usuario.
Local cWFilial		:= "" As Character
Local _nJ, _nI     	:= 0 As Numeric
Local _cCmpTemp		:= "" As Character
Local _cCmpSC7		:= "" As Character
Local _nTotRegSC7	:= 0 As Numeric
Local _cNomeCampo 	:= "" As Character

ProcRegua(0)
IncProc('Inicializando a rotina...')

If !_lCriaAmb
	dEmissIni	:= mv_par01
	dEmissFim	:= mv_par02
	cFornecIni	:= mv_par03
	cLojaIni	:= mv_par04
	cFornecFim	:= mv_par05
	cLojaFim	:= mv_par06
	cPedidoIni	:= mv_par07
	cPedidoFim	:= mv_par08
	cCompraIni	:= mv_par09
	cCompraFim	:= mv_par10
	cUrgente	:= mv_par11
	cAplic		:= mv_par12
	cInvest		:= mv_par13
EndIf

For nX := 1 To Len(aFields)
	cSelect += aFields[nX] + ", "
Next nX

If _lCriaAmb

	dEmissIni := DtoS(SuperGetMV("IT_WFDTINI",.F.,"26/11/2025"))
	dEmissFim := DtoS(Date())

	BeginSQL alias cAliasTrb
	
	SELECT	C7_FILIAL, C7_EMISSAO, C7_NUM, SUM(C7_TOTAL) C7_TOTAL, C7_USER, C7_GRUPCOM, C7_FORNECE, C7_LOJA, A2_NREDUZ, MIN(C7_DATPRF) C7_DATPRF, C7_I_CMPDI, C7_I_URGEN, C7_I_APLIC, C7_I_CDINV, 
			MIN(C7_I_DTFAT) C7_I_DTFAT, ZZI_DESINV, Y1_USER, Y1_NOME, Y1_COD 
	FROM %table:SC7% SC7
	JOIN %table:SA2% SA2 ON A2_FILIAL = %xFilial:SA2% AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.%notDel%
	JOIN %table:SY1% SY1 ON Y1_FILIAL = %xFilial:SY1% AND (Y1_COD BETWEEN %exp:cCompraIni% AND %exp:cCompraFim%) AND SY1.%notDel%
	LEFT JOIN %table:ZZI% ZZI ON ZZI_FILIAL = %xFilial:ZZI% AND ZZI_CODINV = C7_I_CDINV AND ZZI.%notDel%
	WHERE
		C7_EMISSAO BETWEEN %exp:dEmissIni% AND %exp:dEmissFim%
		AND C7_USER = Y1_USER
		AND C7_CONAPRO = 'B'
        AND C7_RESIDUO <> 'S'
		AND C7_QUJE < C7_QUANT
		AND C7_APROV = 'PENLIB'
		AND SC7.C7_I_APLIC <> ' '
		AND SC7.%notDel%
	GROUP BY C7_FILIAL, C7_EMISSAO, C7_NUM, C7_USER, C7_GRUPCOM, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_I_CMPDI, C7_I_URGEN, C7_I_APLIC, C7_I_CDINV, ZZI_DESINV, Y1_USER, Y1_NOME, Y1_COD
	ORDER BY C7_FILIAL, C7_EMISSAO, C7_NUM, C7_USER, C7_GRUPCOM, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_DATPRF, C7_I_CMPDI, C7_I_URGEN, C7_I_APLIC, C7_I_CDINV, ZZI_DESINV, Y1_USER, Y1_NOME, Y1_COD
	
	EndSql

Else
	//======================================
	//Tratamento da clausula where da filial
	//======================================
	cWFilial := "%"
	cWFilial += " SC7.C7_FILIAL  = '" + xFilial("SC7") + "' "
	
	//=======================================
	//Tratamento da clausula where do urgente
	//=======================================
	If cUrgente == 1				//Sim
		cWFilial += " AND SC7.C7_I_URGEN = 'S' "
	ElseIf cUrgente == 2			//Nao
		cWFilial += " AND SC7.C7_I_URGEN = 'N' "
    ElseIf cUrgente == 3			//NF
	    cWFilial += " AND SC7.C7_I_URGEN = 'F' "
	EndIf
	
	//=========================================
	//Tratamento da clausula where da aplicacao
	//=========================================
	If cAplic == 1				//Consumo
		cWFilial += " AND SC7.C7_I_APLIC = 'C' "
	ElseIf cAplic == 2			//Investimento
		cWFilial += " AND SC7.C7_I_APLIC = 'I' "
	ElseIf cAplic == 3			//Manuten��o
		cWFilial += " AND SC7.C7_I_APLIC = 'M' "
	ElseIf cAplic == 4			//Servi�o
		cWFilial += " AND SC7.C7_I_APLIC = 'S' "
	EndIf
	
	//============================================
	//Tratamento da clausula where do investimento
	//============================================
	If !Empty(cInvest)
		cWFilial += " AND SC7.C7_I_CDINV = '" + cInvest + "' "
	EndIf
	cWFilial += "%"
	
	BeginSQL alias cAliasTrb
	
	SELECT	C7_FILIAL, C7_EMISSAO, C7_NUM, SUM(C7_TOTAL) C7_TOTAL, C7_USER, C7_GRUPCOM, C7_FORNECE, C7_LOJA, A2_NREDUZ, MIN(C7_DATPRF) C7_DATPRF, C7_I_CMPDI, C7_I_URGEN, C7_I_APLIC, C7_I_CDINV, 
			MIN(C7_I_DTFAT) C7_I_DTFAT, ZZI_DESINV, Y1_USER, Y1_NOME, Y1_COD 
	FROM %table:SC7% SC7
	JOIN %table:SA2% SA2 ON A2_FILIAL = %xFilial:SA2% AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.%notDel%
	JOIN %table:SY1% SY1 ON Y1_FILIAL = %xFilial:SY1% AND (Y1_COD BETWEEN %exp:cCompraIni% AND %exp:cCompraFim%) AND SY1.%notDel%
	LEFT JOIN %table:ZZI% ZZI ON ZZI_FILIAL = %xFilial:ZZI% AND ZZI_CODINV = C7_I_CDINV AND ZZI.%notDel%
	WHERE
		%Exp:cWFilial%
		AND C7_EMISSAO BETWEEN %exp:dEmissIni% AND %exp:dEmissFim%
		AND C7_FORNECE BETWEEN %exp:cFornecIni% AND %exp:cFornecFim%
		AND C7_LOJA BETWEEN %exp:cLojaIni% AND %exp:cLojaFim%
		AND C7_NUM BETWEEN %exp:cPedidoIni% AND %exp:cPedidoFim%
		AND C7_USER = Y1_USER
		AND C7_CONAPRO = 'B'
        AND C7_RESIDUO <> 'S'
		AND C7_QUJE < C7_QUANT
		AND C7_APROV = 'PENLIB'
		AND SC7.%notDel%
	GROUP BY C7_FILIAL, C7_EMISSAO, C7_NUM, C7_USER, C7_GRUPCOM, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_I_CMPDI, C7_I_URGEN, C7_I_APLIC, C7_I_CDINV, ZZI_DESINV, Y1_USER, Y1_NOME, Y1_COD
	ORDER BY C7_FILIAL, C7_EMISSAO, C7_NUM, C7_USER, C7_GRUPCOM, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_DATPRF, C7_I_CMPDI, C7_I_URGEN, C7_I_APLIC, C7_I_CDINV, ZZI_DESINV, Y1_USER, Y1_NOME, Y1_COD
	
	EndSql
EndIf

_aStructQry := (cAliasTrb)->(DbStruct())

For _nI := 1 To Len(_aStructQry)
    _nJ := AsCan(aStructSC7,{|x| AllTrim(x[1]) == AllTrim(_aStructQry[_nI,1])})
    If _nJ == 0
       Aadd(aStructSC7 , _aStructQry[_nI])
    EndIf
Next 

TCSetField(cAliasTrb,"C7_EMISSAO","D",08,0)
TCSetField(cAliasTrb,"C7_I_DTFAT","D",08,0)
TCSetField(cAliasTrb,"C7_DATPRF" ,"D",08,0)
TCSetField(cAliasTrb,"C7_TOTAL"  ,"N",18,2)

Aadd(_aStructQry, {"DELETED"   ,"L" ,1  ,0})
   
_oTemp := FWTemporaryTable():New( cTempTab,  aStructSC7 )
   
//================================================================================
// Cria os indices para o arquivo.
//================================================================================
_oTemp:AddIndex( "01", {"C7_NUM","C7_ITEM","C7_SEQUEN"} )
_oTemp:Create()

If !_lCriaAmb
   IncProc('Lendo os dados...')
ENDIF   

(cAliasTrb)->(DBGOTOP())
nConta:=0
COUNT TO nConta
FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01513"/*cMsgId*/, "ACOM01513 - Registros lidos "+ALLTRIM(STR(nConta))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

(cAliasTrb)->(DbGoTop())

_nTotRegSC7 := SC7->(FCount())

Do While ! (cAliasTrb)->(Eof())
   (cTempTab)->(RecLock(cTempTab,.T.))
   For _nI := 1 To _nTotRegSC7
       _cNomeCampo := ALLTRIM(SC7->(FieldName(_nI)))
       If (cAliasTrb)->(FieldPos(_cNomeCampo)) == 0
          Loop      
       EndIf
       _cCmpTemp := cTempTab  + "->" + SC7->(FieldName(_nI))
       _cCmpSC7  := cAliasTrb + "->" + SC7->(FieldName(_nI)) 
       &(_cCmpTemp) := &(_cCmpSC7)
   Next _nI
   (cAliasTrb)->(DbSkip())
EndDo

//=========================================================
// Fecha a Tabela da Query ap�s gravar tabela temporaria.
//=========================================================
If ( Select( cAliasTrb ) > 0 )
   (cAliasTrb)->(DbCloseArea())
EndIf

If !_lCriaAmb
	(cTempTab)->( DBGoTop() )

	For nX := 1 To Len(aFields)
		If	!aFields[nX] == "SC7_OK" .And. aFields[nX] $ cSelect
			AAdd(aColumns,FWBrwColumn():New())
			If aFields[nX] == "C7_EMISSAO" .Or. aFields[nX] == "C7_I_DATPRF"
				aColumns[Len(aColumns)]:SetData( &("{||StoD(" + aFields[nX] + ")}") )
			Else
				aColumns[Len(aColumns)]:SetData( &("{||" + aFields[nX] + "}") )
			EndIf
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aFields[nX])) 
			aColumns[Len(aColumns)]:SetSize(TamSX3(aFields[nX])[1]) 
			aColumns[Len(aColumns)]:SetDecimal(TamSX3(aFields[nX])[2])
			If "Y1" $ aFields[nX]
				aColumns[Len(aColumns)]:SetPicture(PesqPict("SY1",aFields[nX]))
			ElseIf "SA2" $ aFields[nX]
				aColumns[Len(aColumns)]:SetPicture(PesqPict("SA2",aFields[nX]))
			ElseIf "ZZI" $ aFields[nX]
				aColumns[Len(aColumns)]:SetPicture(PesqPict("ZZI",aFields[nX]))
			Else
				aColumns[Len(aColumns)]:SetPicture(PesqPict("SC7",aFields[nX]))
			EndIf
		EndIf
	Next nX
ENDIF

Return( { cTempTab , aColumns } )

/*
===============================================================================================================================
Programa----------: ACOM015P
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 23/02/2016
Descri��o---------: Fun��o criada para gerar tela para exporta��o dos dados para planilha.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM015P()

Local aArea		:= FwGetArea() As Array
Local aCampPla	:= {	'�ndice',;
						'Filial',;
						'Num PC',;
						'Item',;
						'Quantidade',;
						'Prc Unit�rio',;
						'Vlr. Total',;
						'Ult. Pre�o',;
						'Dt. Emiss�o',;
						'Urgente',;
						'Aplica��o',;
						'Produto',;
						'Descri��o',;
						'Unidade',;
						'Fornecedor',;
						'N Fantasia',;
						'Dt Faturado',;
						'Cod.Investim',;
						'Des.Investim',;
						'Observa��es',;
						'Cod. Usu�rio',;
						'Nome',;
						'C�digo'} As Array
Local aLogPla	:= {} As Array
Local nCont		:= 1 As Numeric


dbSelectArea(cAliasMrk)
(cAliasMrk)->(dbGoTop())

While !(cAliasMrk)->(Eof())
	aAdd( aLogPla , {	StrZero(nCont++,4),;																		//[1]�ndice
						(cAliasMrk)->C7_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,(cAliasMrk)->C7_FILIAL,1)),;	//[2]Filial
						(cAliasMrk)->C7_NUM,;																		//[3]Num PC
						(cAliasMrk)->C7_ITEM,;												 						//[4]Item
						AllTrim(Transform((cAliasMrk)->C7_QUANT,PesqPict("SC7","C7_QUANT"))),;						//[5]Quantidade
						AllTrim(Transform((cAliasMrk)->C7_PRECO,PesqPict("SC7","C7_PRECO"))),;						//[6]Pre�o Unit�rio
						AllTrim(Transform((cAliasMrk)->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))),;						//[7]Valor Total
						AllTrim(Transform((cAliasMrk)->BZ_UPRC,PesqPict("SBZ","BZ_UPRC"))),;						//[8]�ltimo Pre�o
						StoD((cAliasMrk)->C7_EMISSAO),;																//[9]Emiss�o
						(cAliasMrk)->C7_I_URGEN,;												  					//[10]Urgente
						(cAliasMrk)->C7_I_APLIC,;												  					//[11]Aplica��o
						(cAliasMrk)->C7_PRODUTO,;																	//[12]Produto
						(cAliasMrk)->C7_DESCRI,;																	//[13]Descri��o
						(cAliasMrk)->C7_UM,;																		//[14]Unidade
						(cAliasMrk)->C7_FORNECE,;										   							//[15]Fornecedor
						(cAliasMrk)->A2_NREDUZ,;										   							//[16]Nome Reduzido
						StoD((cAliasMrk)->C7_I_DTFAT),;											 					//[17]Dt Faturado
						(cAliasMrk)->C7_I_CDINV,;												 					//[18]C�digo Investimento
						(cAliasMrk)->ZZI_DESINV,;												 					//[19]Descri��o Investimento
						(cAliasMrk)->C7_OBS,;														   				//[20]Observa��o
						(cAliasMrk)->Y1_USER,;														   				//[21]C�digo do Usu�rio
						(cAliasMrk)->Y1_NOME,;														   				//[22]Nome do Usu�rio
						(cAliasMrk)->Y1_COD})												   						//[23]Descri��o Detalhada

	(cAliasMrk)->(dbSkip())
End

U_ITListBox( 'Gera��o Planilha' , aCampPla , aLogPla , .T. , 1 )

FwRestArea(aArea)

Return

/*
===============================================================================================================================
Programa----------: ACOM015U
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 25/02/2016
Descri��o---------: Fun��o criada para fazer a valida��o do % de toler�ncia entre o �ltimo pre�o x pre�o pedido.
Parametros--------: Nenhum
Retorno-----------: lRet -> .T. valida conte�do digitado / .F. caso contr�rio
===============================================================================================================================
*/
User Function Acom015U()

Local aArea		:= FwGetArea() As Array
Local lRet		:= .T. As Logical
Local cCampo	:= AllTrim(ReadVar()) As Character
Local nPtol		:= SuperGetMV("IT_PTOLP3",.F.,0) As Numeric
Local cTipo		:= SuperGetMV("IT_VALCMP",.F.,"") As Character
Local nDiff		:= 0 As Numeric
Local nPosUlt	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_I_ULTPR"}) As Numeric
Local nPosPrc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"}) As Numeric
Local nPosPro	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"}) As Numeric

If "C7_PRECO" $ cCampo
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + aCols[n][nPosPro]))
	
	If !(SB1->B1_TIPO $ cTipo)
	
		If aCols[n][nPosPrc] > aCols[n][nPosUlt]
			nDiff := ((aCols[n][nPosPrc] - aCols[n][nPosUlt]) / aCols[n][nPosUlt]) * 100
			If nDiff > nPtol
				If !U_ITMSG("O valor unit�rio informado, est� maior que a toler�ncia do �ltimo pre�o de compra. Gostaria de continuar assim mesmo ?","Aten��o",,3)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

FWRestArea(aArea)

Return(lRet)

/*
===============================================================================================================================
Programa----------: ACOM015N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/11/2018
Descri��o---------: Fun��o criada para retornar o nome do usu�rio, seguindo o padr�o de desenvolvimento Totvs e seguindo as 
                    regras de desenvolvimento para o novo servidor Totvs Lobo Guar�.
Parametros--------: _cCodUser = Codigo do usu�rio.
Retorno-----------: _cNomeUser = Nome do usu�rio.
===============================================================================================================================
*/
User Function Acom015N(_cCodUser As Character)

Local _cNomeUser := "" As Character

Begin Sequence
   _cNomeUser := UsrFullName(_cCodUser)

End Sequence

Return (_cNomeUser)
