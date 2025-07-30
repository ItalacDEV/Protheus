/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Jerry         | 23/08/2019 | Chamado 30350. Correções na função de Indicar Comprador para SC.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/09/2019 | Chamado 33350. Ajustes e melhorias na gravacao do cTempTab e na função ACOM009F1().
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/09/2019 | Chamado 33609. Ajuste na estrutura do campo C1_I_ULTPR do TRB.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/04/2023 | Chamado 43472. Acrescentada a opcao NF no campo C1_I_URGEN : S(SIM), N(NAO) F(NF).
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 20/02/2024 | Chamado 46303. Andre. Correção da limpeza dos Campos da indicação do Comprador.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"                     
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'

Static cAliasMrk	:= ""

/*
===============================================================================================================================
Programa----------: ACOM009
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 22/09/2015
===============================================================================================================================
Descrição---------: Rotina responsável por Indicar Comprador para SC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM009()

Local aAlias		:= {}
Local aColumns	:= {}
Local oproc

Local bChkMarca	:= {|| IIf( aScan( aRegsSC1 , { |x| x[1] + x[2] + x[3] == (cAliasMrk)->C1_FILIAL + (cAliasMrk)->C1_NUM + (cAliasMrk)->C1_ITEM  } ) == 0 , 'LBNO' , 'LBOK' ) }
Local bSelMarca	:= {|| ( IIf( ( nPos := aScan( aRegsSC1 , { |x| x[1] + x[2] + x[3] == (cAliasMrk)->C1_FILIAL + (cAliasMrk)->C1_NUM + (cAliasMrk)->C1_ITEM } ) ) == 0 , ( aAdd( aRegsSC1 , { (cAliasMrk)->C1_FILIAL, (cAliasMrk)->C1_NUM, (cAliasMrk)->C1_ITEM }  ) , lMarcou := .T. ) , ( aDel( aRegsSC1 , nPos ) , aSize( aRegsSC1 , Len( aRegsSC1 ) -1 ) ) ) ) }
Local bAllMarca	:= {|| IIF( Empty( aRegsSC1 ) , aRegsSC1 := aClone( aRegsAll ) , aRegsSC1 := {} ) , oMrkBrowse:Refresh() , oMrkBrowse:GoTop() }

Private aSelFil	:= {}
Private aRegsSC1:= {}
Private aRegsAll:= {}
Private cPerg	:= "ACOM009"
Private aRotina	:= ACOM009M()

If !Pergunte(cPerg,.T.)
     return
Else
	If mv_par01 == 3
		aSelFil := AdmGetFil()
	EndIf
EndIf

//--------------------------------------------------------
//Retorna as colunas para o preenchimento da FWMarkBrowse
//--------------------------------------------------------
fwmsgrun( ,{|oproc| aAlias := aCom009Qry(oproc) } , 'Aguarde!' , 'Verificando os registros...' )
	
cAliasMrk	:= aAlias[1]
aColumns 	:= aAlias[2]

If !(cAliasMrk)->(Eof())
	//----------------------
	//Criação da MarkBrowse
	//----------------------
	oMrkBrowse:= FWMarkBrowse():New()
	oMrkBrowse:SetDataTable(.T.)
	oMrkBrowse:SetAlias(cAliasMrk)
	oMrkBrowse:AddMarkColumns( bChkMarca , bSelMarca , bAllMarca )
	oMrkBrowse:SetDescription("")
	oMrkBrowse:SetColumns(aColumns)
	oMrkBrowse:Activate()

Else
	U_ITMSG("Não foram localizadas SCs com os filtros selecionados","Atenção",,1)
EndIf

If !Empty (cAliasMrk)
	dbSelectArea(cAliasMrk)
	dbCloseArea()
	Ferase(cAliasMrk+GetDBExtension())
	Ferase(cAliasMrk+OrdBagExt())
	cAliasMrk := ""
	dbSelectArea("SC1")
	dbSetOrder(1)
Endif

//======================================================================
// Grava log da Rotina responsável por Indicar Comprador para SC 
//====================================================================== 
U_ITLOGACS('ACOM009')


Return (.T.)

/*
===============================================================================================================================
Programa----------: ACOM009Qry
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 29/07/2015
===============================================================================================================================
Descrição---------: Função utilizada para montar a query e arquivo temporário
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Array [1] - Tabela temporária / [2] - Colunas do browse
===============================================================================================================================
*/
Static Function aCom009Qry(oproc)

Local cAliasTrb		:= GetNextAlias()		
Local aFields		:= {'C1_FILIAL','C1_EMISSAO','C1_NUM','C1_ITEM','C1_CODCOMP','Y1_NOME','C1_I_CODAP','ZZ7_NOME','C1_PRODUTO','C1_DESCRI','C1_UM','C1_QUANT','C1_QUJE','C1_I_ULTPR','C1_I_ULTDT','C1_I_URGEN','C1_I_APLIC','C1_I_CDINV','ZZI_DESINV','C1_CC','C1_I_DTRET','C1_I_INDIC','C1_I_INDDT','C1_I_INDHR','C7_NUM','C7_ITEM','A2_NREDUZ'}
Local cSelect		:= ""
Local aStructSC1	:= SC1->(DBSTRUCT())
Local aColumns		:= {}
Local nX			:= 0					
Local cTempTab		:= ""
Local dEmissIni		:= MV_PAR02
Local dEmissFim		:= MV_PAR03
Local cSolicIni		:= MV_PAR04
Local cSolicFim		:= MV_PAR05
Local cCompraDe		:= MV_PAR06
Local cCompraAte	:= MV_PAR07
Local cUrgente		:= MV_PAR08
Local cAplic		:= MV_PAR09
Local cSituac		:= MV_PAR11

//Variaveis utilizadas para montar o where da query, referente aos filtros preenchidos pelo usuario.
Local cWFilial		:= ""
Local cWFils		:= ""
Local cWUrgen		:= ""
Local cWAplic		:= ""
Local cWhere		:= ""
Local cWSitu		:= ""

oproc:cCaption := ("Iniciando rotina...")
ProcessMessages()

For nX := 1 To Len(aFields)
	cSelect += aFields[nX] + ", "
Next nX

AADD(aStructSC1,{"SC1RECNO","N",15,0 })

//======================================
//Tratamento da clausula where da filial
//======================================
If mv_par01 == 1			//Todas as Filiais
	cWFilial := "%"
	cWFilial += " SC1.C1_FILIAL >= '" + Space(TamSX3("C1_FILIAL")[1]) + "' AND SC1.C1_FILIAL <= '" + Replicate("Z", TamSX3("C1_FILIAL")[1]) + "' "
	cWFilial += "%"
ElseIf mv_par01 == 2		//Filial Corrente
	cWFilial := "%"
	cWFilial += " SC1.C1_FILIAL  = '" + xFilial("SC1") + "' "
	cWFilial += "%"
ElseIf mv_par01 == 3 		//Seleciona Filiais
	//Leitura das filiais selecionadas
	For nX := 1 To Len(aSelFil)
		If nX == Len(aSelFil)
			cWFils += "'" + aSelFil[nX] + "'"
		Else
			cWFils += "'" + aSelFil[nX] + "',"
		EndIf
	Next nX
	cWFilial := "%"
	cWFilial += " SC1.C1_FILIAL IN (" + cWFils + ") "
	cWFilial += "%"
EndIf

//=======================================
//Tratamento da clausula where do urgente
//=======================================
If cUrgente == 1				//Sim
	cWUrgen := "%"
	cWUrgen += " SC1.C1_I_URGEN = 'S' "
	cWUrgen += "%"
ElseIf cUrgente == 2			//Nao
	cWUrgen := "%"
	cWUrgen += " SC1.C1_I_URGEN = 'N' "
	cWUrgen += "%"
ElseIf cUrgente == 3			//NF
	cWUrgen := "%"
	cWUrgen += " SC1.C1_I_URGEN = 'F' "
	cWUrgen += "%"
ElseIf cUrgente == 4			//NF
	cWUrgen := "%"
	cWUrgen += " SC1.C1_I_URGEN IN (' ','S','N','F') "
	cWUrgen += "%"
EndIf

//=========================================
//Tratamento da clausula where da aplicacao
//=========================================
If cAplic == 1				//Consumo
	cWAplic := "%"
	cWAplic += " SC1.C1_I_APLIC = 'C' "
	cWAplic += "%"
ElseIf cAplic == 2			//Investimento
	cWAplic := "%"
	cWAplic += " SC1.C1_I_APLIC = 'I' "
	cWAplic += "%"
ElseIf cAplic == 3			//Manutenção
	cWAplic := "%"
	cWAplic += " SC1.C1_I_APLIC = 'M' "
	cWAplic += "%"
ElseIf cAplic == 4			//Serviço
	cWAplic := "%"
	cWAplic += " SC1.C1_I_APLIC = 'S' "
	cWAplic += "%"
ElseIf cAplic == 5			//Todos
	cWAplic := "%"
	cWAplic += " SC1.C1_I_APLIC <> ' ' "
	cWAplic += "%"
EndIf

If cSituac == 1
	cWSitu := "%"
	cWSitu += " SC1.C1_QUJE = 0 "
	cWSitu += "%"
ElseIf cSituac == 2
	cWSitu := "%"
	cWSitu += " (SC1.C1_QUJE > 0 AND SC1.C1_QUJE < SC1.C1_QUANT) "
	cWSitu += "%"
ElseIf cSituac == 3
	cWSitu := "%"
	cWSitu += " SC1.C1_QUJE < SC1.C1_QUANT "
	cWSitu += "%"
EndIf

cWhere := "%"
cWhere += " SC1.C1_CODCOMP BETWEEN '" + cCompraDe + "' AND '" + cCompraAte + "' AND "
cWhere += " SC1.C1_QUJE < SC1.C1_QUANT AND "
cWhere += " SC1.C1_APROV = 'L' AND "
cWhere += " SC1.C1_RESIDUO <> 'S' "
cWhere += "%"

BeginSQL alias cAliasTrb

SELECT ' ' SC1_OK, C1_FILIAL, C1_EMISSAO, C1_NUM, C1_ITEM, C1_CODCOMP, Y1_NOME, C1_I_CODAP, ZZ7_NOME,
        C1_PRODUTO, C1_DESCRI, C1_UM, C1_QUANT, C1_QUJE, C1_I_ULTPR, C1_I_ULTDT, C1_I_URGEN, C1_I_APLIC,
		 C1_I_CDINV, ZZI_DESINV, C1_CC, C1_I_DTRET, C1_DATPRF, C1_OBS, B1_I_DESCD,C1_I_INDIC,C1_I_INDDT,
		 C7_NUM,C7_ITEM,C7_FORNECE,C7_LOJA,(SELECT A2_NREDUZ FROM %table:SA2% SA2 WHERE SA2.A2_COD = SC7.C7_FORNECE AND
		                                              SA2.A2_LOJA = SC7.C7_LOJA AND SC7.%notDel%) A2_NREDUZ,
		 C1_I_INDHR,SC1.R_E_C_N_O_ SC1RECNO  //SC1_OK é o campo criado para o campo de Marcação
FROM %table:SC1% SC1
LEFT JOIN %table:SY1% SY1 ON SY1.Y1_FILIAL = %xFilial:SY1% AND SC1.C1_CODCOMP = SY1.Y1_COD AND SY1.%notDel%
JOIN %table:ZZ7% ZZ7 ON SC1.C1_FILIAL = ZZ7.ZZ7_FILIAL AND SC1.C1_I_CODAP = ZZ7.ZZ7_CODUSR AND ZZ7.%notDel%
LEFT JOIN %table:ZZI% ZZI ON SC1.C1_FILIAL = ZZI.ZZI_FILIAL AND SC1.C1_I_CDINV = ZZI.ZZI_CODINV AND ZZI.%notDel%
LEFT JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SC1.C1_PRODUTO AND SB1.%notDel%
LEFT JOIN %table:SC7% SC7 ON SC7.C7_FILIAL = SC1.C1_FILIAL AND SC7.C7_NUMSC = SC1.C1_NUM AND SC7.C7_ITEMSC = SC1.C1_ITEM AND SC7.%notDel%
WHERE
	%Exp:cWFilial%							AND
	SC1.C1_NUM BETWEEN %exp:cSolicIni%		AND %exp:cSolicFim%	AND
	SC1.C1_EMISSAO BETWEEN %exp:dEmissIni%	AND %exp:dEmissFim% AND
	%Exp:cWUrgen%							AND
	%Exp:cWAplic%							AND
	%Exp:cWSitu%							AND
	%Exp:cWhere%							AND
	SC1.%notDel%
ORDER BY
	C1_FILIAL, C1_EMISSAO, C1_NUM, C1_ITEM, C1_CODCOMP, Y1_NOME, C1_I_CODAP, ZZ7_NOME, C1_PRODUTO, C1_DESCRI, C1_UM, C1_QUANT, C1_QUJE, C1_I_ULTPR, C1_I_ULTDT, C1_I_URGEN, C1_I_APLIC, C1_I_CDINV, ZZI_DESINV, C1_CC, C1_I_DTRET, C1_DATPRF, C1_OBS, B1_I_DESCD
EndSql

//----------------------------------------------------------------------
// Cria arquivo de dados temporário
//----------------------------------------------------------------------
aStruTRB:=(cAliasTrb)->(DBSTRUCT())    
 
If (NpOS:=ASCAN(aStruTRB,{|A|A[1]=="C1_QUANT"})) <> 0
   aStruTRB[NpOS,3]:=22
EndIf

If (NpOS:=ASCAN(aStruTRB,{|A|A[1]=="C1_QUJE"})) <> 0
   aStruTRB[NpOS,3]:=22
EndIf

If (NpOS:=ASCAN(aStruTRB,{|A|A[1]=="C1_I_ULTPR"})) <> 0
   aStruTRB[NpOS,3]:=22
EndIf

If (NpOS:=ASCAN(aStruTRB,{|A|A[1]=="SC1RECNO"})) <> 0
   aStruTRB[NpOS,3]:=22
EndIf

cTempTab := GetNextAlias()
_otemp := FWTemporaryTable():New( cTempTab,aStruTRB )
_otemp:Create()


(cAliasTrb)->(Dbgotop())

Do while (cAliasTrb)->(!Eof())

	(cTempTab)->(DBAPPEND())
    if EMPTY((cAliasTrb)->C7_FORNECE)
       aForn:=ACOM009F1(,cAliasTrb)
    ENDIF   
	
	(cTempTab)->C1_FILIAL := (cAliasTrb)->C1_FILIAL
	(cTempTab)->C1_NUM    := (cAliasTrb)->C1_NUM
	(cTempTab)->C1_ITEM   := (cAliasTrb)->C1_ITEM
	(cTempTab)->C7_NUM    := (cAliasTrb)->C7_NUM
	(cTempTab)->C7_ITEM   := (cAliasTrb)->C7_ITEM
	(cTempTab)->C7_FORNECE:= IF(EMPTY((cAliasTrb)->C7_FORNECE),aForn[1],(cAliasTrb)->C7_FORNECE)
	(cTempTab)->C7_LOJA   := IF(EMPTY((cAliasTrb)->C7_FORNECE),aForn[2],(cAliasTrb)->C7_LOJA)
	(cTempTab)->A2_NREDUZ := POSICIONE("SA2",1,xfilial("SA2")+(cTempTab)->C7_FORNECE+(cTempTab)->C7_LOJA,"A2_NREDUZ")
	(cTempTab)->SC1RECNO  := (cAliasTrb)->SC1RECNO
	(cTempTab)->C1_EMISSAO:= (cAliasTrb)->C1_EMISSAO
	(cTempTab)->C1_CODCOMP:= (cAliasTrb)->C1_CODCOMP
	(cTempTab)->Y1_NOME   := (cAliasTrb)->Y1_NOME
	(cTempTab)->C1_I_INDIC  := (cAliasTrb)->C1_I_INDIC
	(cTempTab)->C1_I_INDDT  := (cAliasTrb)->C1_I_INDDT
	(cTempTab)->C1_I_INDHR  := (cAliasTrb)->C1_I_INDHR
	(cTempTab)->C1_I_CODAP  := (cAliasTrb)->C1_I_CODAP
	(cTempTab)->ZZ7_NOME  := (cAliasTrb)->ZZ7_NOME
	(cTempTab)->C1_PRODUTO  := (cAliasTrb)->C1_PRODUTO
	(cTempTab)->C1_DESCRI  := (cAliasTrb)->C1_DESCRI
	(cTempTab)->B1_I_DESCD  := (cAliasTrb)->B1_I_DESCD
	(cTempTab)->C1_UM  := (cAliasTrb)->C1_UM
	(cTempTab)->C1_QUANT  := (cAliasTrb)->C1_QUANT
	(cTempTab)->C1_QUJE  := (cAliasTrb)->C1_QUJE
	(cTempTab)->C1_I_ULTPR  := (cAliasTrb)->C1_I_ULTPR
	(cTempTab)->C1_I_ULTDT :=  (cAliasTrb)->C1_I_ULTDT
	(cTempTab)->C1_I_URGEN  := (cAliasTrb)->C1_I_URGEN
	(cTempTab)->C1_I_APLIC  := (cAliasTrb)->C1_I_APLIC 
	(cTempTab)->C1_I_CDINV  := (cAliasTrb)->C1_I_CDINV 
	(cTempTab)->ZZI_DESINV  := (cAliasTrb)->ZZI_DESINV
	(cTempTab)->C1_CC  := (cAliasTrb)->C1_CC
	(cTempTab)->C1_I_DTRET  := (cAliasTrb)->C1_I_DTRET
	(cTempTab)->C1_DATPRF  := (cAliasTrb)->C1_DATPRF
	(cTempTab)->C1_OBS  := (cAliasTrb)->C1_OBS
	
	(cAliasTrb)->(Dbskip())

Enddo

If ( Select( cAliasTrb ) > 0 )
	DbSelectArea(cAliasTrb)
	DbCloseArea()
EndIf

oproc:cCaption := ("Montando dados...")
ProcessMessages()

(cTempTab)->( DBGoTop() )
While (cTempTab)->(!Eof())
	
	aAdd( aRegsAll , { (cTempTab)->C1_FILIAL, (cTempTab)->C1_NUM, (cTempTab)->C1_ITEM , (cTempTab)->SC1RECNO } )
	
(cTempTab)->( DBSkip() )
EndDo

(cTempTab)->( DBGoTop() )

For nX := 1 To Len(aFields)
	If	!aFields[nX] == "SC1_OK" .And. aFields[nX] $ cSelect
		AAdd(aColumns,FWBrwColumn():New())
		If aFields[nX] == "C1_EMISSAO" .Or. aFields[nX] == "C1_I_ULTDT" .Or. aFields[nX] == "C1_I_DTRET" .OR. aFields[nX] == "C1_I_INDDT"
			aColumns[Len(aColumns)]:SetData( &("{||StoD(" + aFields[nX] + ")}") )
		Else
			aColumns[Len(aColumns)]:SetData( &("{||" + aFields[nX] + "}") )
		EndIf
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aFields[nX])) 
		aColumns[Len(aColumns)]:SetSize(TamSX3(aFields[nX])[1]) 
		aColumns[Len(aColumns)]:SetDecimal(TamSX3(aFields[nX])[2])
		If "Y1" $ aFields[nX]
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SY1",aFields[nX]))
		ElseIf "ZZ7" $ aFields[nX]
			aColumns[Len(aColumns)]:SetPicture(PesqPict("ZZ7",aFields[nX]))
		ElseIf "ZZI" $ aFields[nX]
			aColumns[Len(aColumns)]:SetPicture(PesqPict("ZZI",aFields[nX]))
		Else
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SC1",aFields[nX]))
		EndIf
	EndIf
Next nX


Return( { cTempTab , aColumns } )

/*
===============================================================================================================================
Programa----------: ACOM009M
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 29/07/2015
===============================================================================================================================
Descrição---------: Função utilizada para criação do menu.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aRotina - Opções de menu
===============================================================================================================================
*/
Static Function ACOM009M()     
Local aRot := {}
Private oproc

ADD OPTION aRot Title 'Indicar Comprador'		Action 'fwmsgrun( ,{|oproc| U_ACOM009F(oproc) },"Processando...","Aguarde..." )'		OPERATION 2 ACCESS 0
ADD OPTION aRot Title 'Qtd SC x Comprador'		Action 'fwmsgrun( ,{|oproc| U_ACOM010(oproc) },"Processando","Aguarde..." )'		OPERATION 2 ACCESS 0
ADD OPTION aRot Title 'Visualizar'			Action 'U_Acom009Vis()'						OPERATION 2 ACCESS 0
ADD OPTION aRot Title 'Planilha'			Action 'fwmsgrun( ,{|oproc| U_ACOM009T(oproc) },"Processando...","Aguarde..." )'		OPERATION 2 ACCESS 0

Return(Aclone(aRot))

/*
===============================================================================================================================
Programa----------: ACOM009F
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 29/07/2015
===============================================================================================================================
Descrição---------: Função utilizada para fazer a gravação do comprador e data de retorno.
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: aRotina - Opções de menu
===============================================================================================================================
*/
User Function ACOM009F(oproc)

Local aArea			:= GetArea()
Local nX			:= 0
Local nI			:= 0
Local nCont			:= 0
Local nLenRegs 		:= 0
//Local cInfo			:= ''
Local nOpcC			:= 0

Local oGCNom
Local cGCNom		:= Space(TamSX3("Y1_NOME")[1])
Local oGComp
Local cGComp		:= Space(TamSX3("C1_CODCOMP")[1])
Local oGDTRet
Local dGDTRet		:= Date()
Local oSBtCanc
Local oSBtOK
Local oSComp
Local oSDTRet

Local _cConfig		:= GetMV( "IT_CMWFEP" ,, "001" )
Local _aConfig		:= U_ITCFGEML( _cConfig )
Local _cEmlLog		:= ''
Local _cEmail		:= ''
Local _cTxtCHTM		:= ''//Cabecario
Local _cTxtSCHTM	:= ''//SCs
Local _cTxtRHTM		:= ''//Rodape
Local _cGrupo		:= ''
Local _cChave		:= ''

Local aAlias		:= {}

//Valida se usuário pode usar rotina

dbSelectArea("ZZL")
dbSetOrder(3)


If !(dbSeek(xFilial("ZZL") + __cUserID) .AND. ZZL->ZZL_ADMSC == "S")

    U_ITMSG("Usuário não autorizado a indicar comprador!","Ação não permitida","Solicite autorização a area responsavel.",1)
	Return

Endif

Static oDlg

DEFINE MSDIALOG oDlg TITLE "Indica Comprador" FROM 000, 000  TO 150, 435 COLORS 0, 16777215 PIXEL

	@ 005, 006 SAY oSComp PROMPT "Código Comprador ?" SIZE 051, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 058 MSGET oGComp VAR cGComp SIZE 010, 010 OF oDlg COLORS 0, 16777215 F3 "SY1" VALID ACOM009R(cGComp, @cGCNom) PIXEL
    @ 021, 058 MSGET oGCNom VAR cGCNom SIZE 151, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 037, 006 SAY oSDTRet PROMPT "Data Prevista Retorno ?" SIZE 059, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 037, 070 MSGET oGDTRet VAR dGDTRet SIZE 039, 010 OF oDlg PIXEL 

	DEFINE SBUTTON oSBtOK	FROM 053, 082 TYPE 01 OF oDlg ENABLE ACTION (Iif(ACOM009B(dGDTRet),(nOpcC := 1, oDlg:End()),nOpcC := 0))
    DEFINE SBUTTON oSBtCanc	FROM 053, 114 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcC == 1

	//====================================================================================================
	// Define o cabecalho do HTML
	//====================================================================================================
	_cTxtCHTM += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
	_cTxtCHTM += '<HTML><HEAD><TITLE>.:: WF Indica Comprador ::.</TITLE>'
	_cTxtCHTM += '<META content="text/html; charset=windows-1252" http-equiv=Content-Type></HEAD>'
	_cTxtCHTM += '<style type="text/css"><!--'
	_cTxtCHTM += 'table.bordasimples { border-collapse: collapse; } '
	_cTxtCHTM += 'table.bordasimples tr td { border:1px solid #777777; } '
	_cTxtCHTM += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
	_cTxtCHTM += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
	_cTxtCHTM += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
	_cTxtCHTM += 'td.dados	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
	_cTxtCHTM += '--></style>'

	nLenRegs := Len(aRegsSC1)

	dbSelectArea("SY1")
	dbSetOrder(1)
	dbSeek(xFilial("SY1") + alltrim(cGComp))

    _cComprador:=cGComp+" - "+ALLTRIM(SY1->Y1_NOME)//" / Comprador: "+
    _cCodUser  :=SY1->Y1_USER//" / Cod. Usuario: "+
	_cEmail := ALLTRIM(UsrRetMail(SY1->Y1_USER))
	_cGrupo := SY1->Y1_GRUPCOM

	//====================================================================================================
	// Define o corpo do HTML
	//====================================================================================================
	_cTxtCHTM += '<BODY>'
	_cTxtCHTM += '<center>'
	_cTxtCHTM += '<img src="http://atendimento.italac.com.br/img/italac-logo-new.jpg"><br>'
	_cTxtCHTM += '<table cellSpacing=0 cellPadding=0 width="950" class="bordasimples">'
	_cTxtCHTM += '  <tr>'
	_cTxtCHTM += '     <td class="totais" colspan="8"><center>Relação das SCs para o comprador: <b>' + AllTrim(SY1->Y1_NOME) + '</b></td>'
	_cTxtCHTM += '  </tr>'

	If nLenRegs > 0

		ProcRegua(nLenRegs)

		_cTxtCHTM += '  <TR>'
		_cTxtCHTM += '    <TD width="05%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Filial</STRONG></P></TD>'
		_cTxtCHTM += '    <TD width="05%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Dt Emissão</STRONG></P></TD>'
		_cTxtCHTM += '    <TD width="05%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Num SC</STRONG></P></TD>'
		_cTxtCHTM += '    <TD width="05%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Urgente</STRONG></P></TD>'
		_cTxtCHTM += '    <TD width="05%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Aplicação</STRONG></P></TD>'
		_cTxtCHTM += '    <TD width="32%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Des.Investimento</STRONG></P></TD>'
		_cTxtCHTM += '    <TD width="05%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Dt Retorno</STRONG></P></TD>'
		_cTxtCHTM += '    <TD width="05%" bgcolor="#D8D8D8" align="center" class="itens"><P><STRONG>Necessidade</STRONG></P></TD>'
		_cTxtCHTM += '  </TR>'
        
		BEGIN TRANSACTION
            _aCapaSC:={}	
            _aCompAnterior:={}	
            _cSCsIndicado:=""
			dbSelectArea('SC1')
			SC1->(dbSetOrder(1))
			_cusername := UsrFullName(__cUserID)
			For nX := 1 To Len(aRegsSC1)

			    IF ASCAN(_aCapaSC,aRegsSC1[nX][1]+aRegsSC1[nX][2]) = 0
                   AADD(_aCapaSC,aRegsSC1[nX][1]+aRegsSC1[nX][2])
                ELSE
                   LOOP//Para fazer só uma vez por SC, caso tenha marcado mais de um item da SC
			    ENDIF

				For nI := 1 To Len(aRegsAll)

					If aRegsSC1[nX][1] == aRegsAll[nI][1] .And. aRegsSC1[nX][2] == aRegsAll[nI][2]
						nCont++

						oproc:cCaption := ('Processando Registros...')
						ProcessMessages()

						SC1->(Dbgoto(aRegsAll[nI][4]))
						_nPosComp:=0
						IF !EMPTY(SC1->C1_CODCOMP) .AND. cGComp <> SC1->C1_CODCOMP .AND. (_nPosComp:=ASCAN(_aCompAnterior, {|C|C[1]==SC1->C1_CODCOMP} )) = 0
						   AADD(_aCompAnterior,{ SC1->C1_CODCOMP , "" , "" })
						   _nPosComp:=LEN(_aCompAnterior)
						ENDIF
						
						IF SC1->C1_CODCOMP <> cGComp .OR. SC1->C1_I_DTRET <> dGDTRet
						   SC1->( RecLock( "SC1" , .F. ) )
						   SC1->C1_CODCOMP := cGComp
						   SC1->C1_I_DTRET := dGDTRet
						   SC1->C1_GRUPCOM := _cGrupo
					       SC1->C1_I_INDIC := ALLTRIM(_cusername)
					       SC1->C1_I_INDDT := DATE()
					       SC1->C1_I_INDHR := TIME()
						   SC1->( MsUnLock() )
						ENDIF
						
						If aRegsSC1[nX][1] + aRegsSC1[nX][2] <> _cChave

							SC1->(Dbgoto(aRegsAll[nI][4]))
	
							_cTxtAuxHTM := '<TR>'
							_cTxtAuxHTM += '  <TD width="05%" class="itens" align="left">' + SC1->C1_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC1->C1_FILIAL,1)) + '</TD>'
							_cTxtAuxHTM += '  <TD width="05%" class="itens" align="left">' + DtoC(SC1->C1_EMISSAO) + '</TD>'
							_cTxtAuxHTM += '  <TD width="05%" class="itens" align="left">' + SC1->C1_NUM + '</TD>'
							_cTxtAuxHTM += '  <TD width="05%" class="itens" align="center">' + SC1->C1_I_URGEN + '</TD>'
							_cTxtAuxHTM += '  <TD width="05%" class="itens" align="center">' + SC1->C1_I_APLIC + '</TD>'
							_cTxtAuxHTM += '  <TD width="32%" class="itens" align="left">' + AllTrim(Posicione("ZZI",1,xFilial("ZZI") + SC1->C1_I_CDINV,"ZZI_DESINV")) + '</TD>'
							_cTxtAuxHTM += '  <TD width="05%" class="itens" align="left">' + DtoC(C1_I_DTRET) + '</TD>'
							_cTxtAuxHTM += '  <TD width="05%" class="itens" align="left">' + DtoC(C1_DATPRF) + '</TD>'
							_cTxtAuxHTM += '</TR>'

							_cTxtSCHTM   += _cTxtAuxHTM
							_cSCsIndicado+= SC1->C1_FILIAL+"-"+SC1->C1_NUM+", "
							IF _nPosComp > 0 
							   _aCompAnterior[_nPosComp,2]+=_cTxtAuxHTM
							   _aCompAnterior[_nPosComp,3]+=SC1->C1_FILIAL+"-"+SC1->C1_NUM+", "
							ENDIF
							
							_cChave := aRegsSC1[nX][1] + aRegsSC1[nX][2]
						EndIf
						
					EndIf

				Next nI

			Next nX
			
		END TRANSACTION

		//====================================================================================================
		// Sessão Indicado por:                   
		//====================================================================================================
		_cTxtRHTM += '<tr>'
		_cTxtRHTM += '	<td class="grupos" align="center" colspan="8">Indicado Por: <b>' + UsrFullName(__cUserID) + '</b></td>'
		_cTxtRHTM += '</tr>'
		_cTxtRHTM += '<tr>'
		_cTxtRHTM += '	<td class="grupos" align="center" colspan="8"><a href="http://www.italac.com.br/">http://www.italac.com.br/</a></td>'
		_cTxtRHTM += '</tr>'
    	_cTxtRHTM += '<tr>'
      	_cTxtRHTM += '	<td class="grupos" align="center" colspan="8"><font color="red"><u>Esta é uma mensagem automática. Por favor não a responda!</u></font></td>'
    	_cTxtRHTM += '</tr>'

		//====================================================================================================
		// Finaliza a tabela anterior da secao
		//====================================================================================================
		_cTxtRHTM += '</table>'
		_cTxtRHTM += '</center>'
		_cTxtRHTM += '<br>'

		//====================================================================================================
		// Finaliza o HTML.
		//====================================================================================================
		_cTxtRHTM += '</BODY>'
		_cTxtRHTM += '</HTML>' 
		        //Cabecalho+SCS       +RODAPE
        _cTxtHTM:=_cTxtCHTM+_cTxtSCHTM+_cTxtRHTM

		U_ITENVMAIL( _aConfig[01] , _cEmail ,,, 'Protocolo das SC´s indicadas no dia ['+ DtoC(Date()) +']' , _cTxtHTM ,, _aConfig[01] , _aConfig[02] , _aConfig[03] , _aConfig[04] , _aConfig[05] , _aConfig[06] , _aConfig[07] , @_cEmlLog )

        _aStatus:={}
        AADD(_aStatus,{"Atual",_cComprador,_cCodUser,Lower(_cEmail),_cEmlLog,SUBSTR(_cSCsIndicado,1,LEN(_cSCsIndicado)-2)})
        
         FOR nI := 1 TO LEN(_aCompAnterior)

	         IF SY1->(DBSEEK(xFilial("SY1") + _aCompAnterior[nI,1] ))

	            _cEmailAnt:= UsrRetMail(SY1->Y1_USER)
		                //Cabecalho+SCS                 +RODAPE
                _cTxtHTM:=_cTxtCHTM+_aCompAnterior[nI,2]+_cTxtRHTM
                _cEmlLog:=""

		        U_ITENVMAIL( _aConfig[01] , _cEmailAnt ,,, 'Sua(s) SC(s) foram indicadas para outro comprador no dia ['+ DtoC(Date()) +']' , _cTxtHTM ,, _aConfig[01] , _aConfig[02] , _aConfig[03] , _aConfig[04] , _aConfig[05] , _aConfig[06] , _aConfig[07] , @_cEmlLog )
               
                AADD(_aStatus,{"Anterior",_aCompAnterior[nI,1]+" - "+SY1->Y1_NOME,SY1->Y1_USER,Lower(_cEmailAnt),_cEmlLog,SUBSTR(_aCompAnterior[nI,3],1,LEN(_aCompAnterior[nI,3])-2)})

             ENDIF
             
         NEXT

        IF LEN(_aStatus) > 0 
   	       U_ITListBox( 'Status do(s) Email(s) para o(s) compradore(s):' , {'Indicação','Comprador','Cod Usuario','Email','Status do envio','SCs Marcadas'} , _aStatus , .T. , 1 )
   	    ENDIF

		fwmsgrun( ,{|oproc| aAlias := aCom009Qry(oproc) } , 'Aguarde!' , 'Verificando os registros...' )

		aRegsSC1	:= {}
		
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]
		
		//----------------------
		//Criação da MarkBrowse
		//----------------------
		oMrkBrowse:SetAlias(cAliasMrk)
		oMrkBrowse:Refresh()
		oMrkBrowse:Gotop()
	Else

        U_ITMSG("Não foi selecionado nenhum item para o processamento.","Seleção Inválida","Favor selecionar pelo menos um registro.",1)

	EndIf

EndIf

RestArea(aArea)
Return

/*
===============================================================================================================================
Programa----------: ACOM009R
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 28/09/2015
===============================================================================================================================
Descrição---------: Função utilizada para retornar o nome do comprador caso ele exista, senão retorna mensagem.
===============================================================================================================================
Parametros--------: cGComp - Código do Comprador
------------------: cGCNom - Variável que irá receber o nome do comprador
===============================================================================================================================
Retorno-----------: lRet - Retorno .T. caso ache o comprador, .F. caso contrário e não deixa seguir o processo
===============================================================================================================================
*/
Static Function ACOM009R(cGComp, cGCNom)
Local aArea			:= GetArea()
Local lRet			:= .T.

dbSelectArea("SY1")
dbSetOrder(1)
If dbSeek(xFilial("SY1") + cGComp)
	cGCNom := SY1->Y1_NOME
Else

    U_ITMSG("Código do comprador não encontrado.","Comprador Inválido","Favor verificar o código informado.",1)
	lRet := .F.

EndIf

RestArea(aArea)
Return(lRet)

/*
===============================================================================================================================
Programa----------: Acom009Vis
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 28/09/2015
===============================================================================================================================
Descrição---------: Função utilizada para visualizar um única SC selecionada.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function Acom009Vis()
Local aArea		:= GetArea()
Local cFilAntOld := cFilAnt

Private lCopia  := Inclui:=Altera:=.F.//Inica essas variavel por causa do botão visualizar
                           
cFilAnt :=aRegsAll[oMrkBrowse:OBROWSE:NAT][1]

dbSelectArea("SC1")
SC1->(dbSetOrder(1))
If SC1->(dbSeek(aRegsAll[oMrkBrowse:OBROWSE:NAT][1] + aRegsAll[oMrkBrowse:OBROWSE:NAT][2] + aRegsAll[oMrkBrowse:OBROWSE:NAT][3]))
	A110Visual("SC1",SC1->(Recno()),2)
EndIf 

cFilAnt := cFilAntOld
RestArea(aArea)

Return

/*
===============================================================================================================================
Programa----------: ACOM009B
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 28/09/2015
===============================================================================================================================
Descrição---------: Função utilizada para validar a data de retorno.
===============================================================================================================================
Parametros--------: dGDTRet - Data de retorno informada
===============================================================================================================================
Retorno-----------: lRet - Retorno .T. caso ache o comprador, .F. caso contrário e não deixa seguir o processo
===============================================================================================================================
*/
Static Function ACOM009B(dGDTRet)
Local aArea			:= GetArea()
Local lRet			:= .T.

If Empty(dGDTRet)

    U_ITMSG("Data prevista de retorno é obrigatória","Data Prevista Retorno","Favor preencher a data prevista de retorno.",1)
	lRet := .F.

ELSEIF dGDTRet < DATE() 

   U_ITMSG("Data prevista de retorno menor que Hoje",'Atenção!',"Favor preencher a data prevista de retorno maior ou igual a Hoje.",1)
   lRet := .F.

EndIf

RestArea(aArea)
Return(lRet)


/*
===============================================================================================================================
Programa----------: ACOM009T
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 13/10/2015
===============================================================================================================================
Descrição---------: Função criada para gerar tela para exportação dos dados para planilha
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM009T()
Local aArea		:= GetArea()
Local aCampPla	:= {	'Índice',;
						'Filial',;
						'Dt Emissão',;
						'Núm.SC',;
						'Item',;
						'Núm PC',;
						'Item',;
						'Fornecedor',;
						'Cod. Comprad',;
						'Nome Comp.',;
						'Indicador',;
						'Data Indicação',;
						'Hora Indicação',;			
						'Cod. Aprovad',;
						'Nome Aprov',;
						'Produto',;
						'Descrição',;
						'Descrição Detalhada',;
						'Unid.Medida',;
						'Quantidade',;
						'Quant.em Ped',;
						'Último Preço',;
						'Ult.Compra',;
						'Urgente',;
						'Aplicação',;
						'Investimento',;
						'Desc.Invest.',;
						'Centro Custo',;
						'Data Retorno',;
						'Necessidade',;
						'Observação'}
Local aLogPla	:= {}
Local nCont		:= 1

dbSelectArea(cAliasMrk)
(cAliasMrk)->(dbGoTop())

While !(cAliasMrk)->(Eof())
	aAdd( aLogPla , {	StrZero(nCont++,4),;																		//[1]Índice
						(cAliasMrk)->C1_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,(cAliasMrk)->C1_FILIAL,1)),;	//[2]Filial
						StoD((cAliasMrk)->C1_EMISSAO),;																//[3]Emissão
						(cAliasMrk)->C1_NUM,;																		//[4]Número SC
						(cAliasMrk)->C1_ITEM,;												 						//[5]Item
						(cAliasMrk)->C7_NUM,;																		//[6]Número SC
						(cAliasMrk)->C7_ITEM,;												 						//[7]Item
						(cAliasMrk)->C7_FORNECE + "/" + (cAliasMrk)->C7_LOJA + " - " + (cAliasMrk)->A2_NREDUZ,;     //[8]Item
						(cAliasMrk)->C1_CODCOMP,;										   							//[9]Cod. Comprador
						(cAliasMrk)->Y1_NOME,;											   							//[10]Nome Comprador
						(cAliasMrk)->C1_I_INDIC,;																	//[11]Cod Indicador
						DTOC(STOD((cAliasMrk)->C1_I_INDDT)),;														//[12] Data indicação
						(cAliasMrk)->C1_I_INDHR,;																	//[13] Hora indicação
						(cAliasMrk)->C1_I_CODAP,;										  							//[14]Cod. Aprovador
						(cAliasMrk)->ZZ7_NOME,;											   							//[15]Nome Aprovador
						(cAliasMrk)->C1_PRODUTO,;																	//[16]Produto
						(cAliasMrk)->C1_DESCRI,;																	//[17]Descrição
						(cAliasMrk)->B1_I_DESCD,;											   						//[18]Descrição Detalhada
						(cAliasMrk)->C1_UM,;																		//[19]Unidade Medida
						AllTrim(Transform((cAliasMrk)->C1_QUANT,PesqPict("SC1","C1_QUANT"))),;						//[20]Quantidade
						AllTrim(Transform((cAliasMrk)->C1_QUJE,PesqPict("SC1","C1_QUJE"))),;						//[21]Quantidade Entregue
						AllTrim(Transform((cAliasMrk)->C1_I_ULTPR,PesqPict("SC1","C1_I_ULTPR"))),;					//[22]Último Preço
						StoD((cAliasMrk)->C1_I_ULTDT),;											  					//[23]Última Compra
						(cAliasMrk)->C1_I_URGEN,;												  					//[24]Urgente
						(cAliasMrk)->C1_I_APLIC,;												  					//[25]Aplicação
						(cAliasMrk)->C1_I_CDINV,;												 					//[26]Código Investimento
						(cAliasMrk)->ZZI_DESINV,;												 					//[27]Descrição Investimento
						(cAliasMrk)->C1_CC,;																		//[28]Centro de Custo
						StoD((cAliasMrk)->C1_I_DTRET),;											  					//[29]Data Retorno
						StoD((cAliasMrk)->C1_DATPRF),; 											 					//[30]Necessidade
						(cAliasMrk)->C1_OBS} )												   						//[31]Observação
	(cAliasMrk)->(dbSkip())
End

U_ITListBox( 'Geração Planilha' , aCampPla , aLogPla , .T. , 1 )

RestArea(aArea)
Return

/*
===============================================================================================================================
Programa----------: ACOM009F1
Autor-------------: Josué Danich Prestes
Data da Criacao---: 08/03/2019
===============================================================================================================================
Descrição---------: Localiza último fornecedor para um produto na filial
===============================================================================================================================
Parametros--------: _ntipo - 1 Retorna código do fornecedor, 2 Retorna código da loja
					_CALIAS - alias de trabalho
===============================================================================================================================
Retorno-----------: _cret - código do fornecedor ou loja
===============================================================================================================================
*/
Static Function ACOM009F1(_ntipo,_cAlias)
Local _cAliaFor  := GetNextAlias()
Local _c1produto := Alltrim((_cAlias)->C1_PRODUTO) 
Local _cFilSC    := Alltrim((_cAlias)->C1_FILIAL) 
LOCAL dData      := DTOS(CTOD("01/01"+STR(YEAR(dDataBase),4)))
LOCAL _aRet      := {"",""}

BeginSQL alias _cAliaFor
	SELECT C7_FORNECE,C7_LOJA
	FROM %table:SC7% SC7
	WHERE	SC7.%notDel%
			AND SC7.C7_FILIAL  = %exp:_cFilSC% 
			AND SC7.C7_PRODUTO = %exp:_c1produto% 
			AND SC7.C7_EMISSAO > %exp:dData% 
	ORDER BY SC7.R_E_C_N_O_ DESC
EndSql

If (_cAliaFor)->(!Eof())
	_aRet := {(_cAliaFor)->C7_FORNECE,(_cAliaFor)->C7_LOJA,}
ELSE
    (_cAliaFor)->(DBCLOSEAREA())
	BeginSQL alias _cAliaFor
		SELECT C7_FORNECE,C7_LOJA
		FROM %table:SC7% SC7
		WHERE	SC7.%notDel%
		AND SC7.C7_FILIAL  = %exp:_cFilSC%
		AND SC7.C7_PRODUTO = %exp:_c1produto%
		ORDER BY SC7.R_E_C_N_O_ DESC
	EndSql
	If (_cAliaFor)->(!Eof())
		_aRet := {(_cAliaFor)->C7_FORNECE,(_cAliaFor)->C7_LOJA,}
	Endif	
Endif

(_cAliaFor)->(DBCLOSEAREA())

Return _aRet
