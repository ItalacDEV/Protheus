/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
    Autor    |   Data   |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 27/03/24 | Chamado 46749. Antonio. Correcao de error.log de tipo de variaveis diferentes.
Antonio Neves| 04/04/24| Chamado 46749. Antonio. Adicionados os valores de ICMS e IPI
Antonio Neves| 10/04/24| Chamado 46749. André. Adicioando a tratativa para produtos que mudam de código entre filiais. 
Antonio Neves| 20/04/24| Chamado 46749. André. Adicioando a tratativa para produtos que mudam de código entre filiais. 
===============================================================================================================================
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre    - Alex Wallauer - 18/09/24 - 20/09/24 -  48579  - Corrigir o relatório RCOM022, quando um item repete em duas linhas na mesma nota.
==============================================================================================================================================================

*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
/*
===============================================================================================================================
Programa.........: RCOM022
Autor............: Alex Wallauer
Data da Criacao..: 23/02/2024
===============================================================================================================================
Descricao........: Chamado 46294. André. Relatorio de Transferencias entre filiais.
===============================================================================================================================
Parametros.......: Nenhum
===============================================================================================================================
Retorno..........: Nenhum
===============================================================================================================================
*/
USER Function RCOM022()
	LOCAL  nI

	_aOpcoes:={"1-Em transito","2-Ja recebidas","3-Todos"}
	_aOrdem :={"1-Produto        ",;
		       "2-Documento/Serie",;
		       "3-Data de emissao"}

	MV_PAR01:=SPACE(200)  //FILIAL ORIGEM
	MV_PAR02:=SPACE(200)  //FILIAL DESTINO
	MV_PAR03:=dDataBase   //DATA DE EMISSAO DE
	MV_PAR04:=dDataBase   //DATA DE EMISSAO ATE
	MV_PAR05:=SPACE(009)  //DOC SAIDA DE
	MV_PAR06:=SPACE(009)  //DOC SAIDA ATE
	MV_PAR07:=SPACE(003)  //SER DOC SAIDA DE
	MV_PAR08:=SPACE(003)  //SER DOC SAIDA ATE
	MV_PAR09:=SPACE(015)  //PRODUTO DE
	MV_PAR10:=SPACE(015)  //PRODUTO ATE
	MV_PAR11:=SPACE(200)  //GRUPO DE PRODUTOS
	MV_PAR12:=VAL(_aOpcoes[3]) //LISTA NFS EM TRANSITO/JA RECEBIDAS/TODAS
	MV_PAR13:=_aOrdem[1] //aOrdem
	_aParAux:={}
	AADD( _aParAux , { 1 , "Filial Origem"      , MV_PAR01, "@!"  , ""  ,"LSTFIL", "" , 100 , .F. } )
	AADD( _aParAux , { 1 , "Filial Destino"     , MV_PAR02, "@!"  , ""  ,"LSTFIL", "" , 100 , .F. } )
	AADD( _aParAux , { 1 , "Data Emissao de"    , MV_PAR03, "@D"  , ""  ,""      , "" , 050 , .T. } )
	AADD( _aParAux , { 1 , "Data Emissao ate"   , MV_PAR04, "@D"  , ""  ,""      , "" , 050 , .T. } )
	AADD( _aParAux , { 1 , "Doc saida de"       , MV_PAR05, "@!"  , ""  ,""      , "" , 050 , .F. } )
	AADD( _aParAux , { 1 , "Doc saida ate"      , MV_PAR06, "@!"  , ""  ,""      , "" , 050 , .F. } )
	AADD( _aParAux , { 1 , "Serie Doc saída de" , MV_PAR07, "@!"  , ""  ,""      , "" , 050 , .F. } )
	AADD( _aParAux , { 1 , "Serie Doc saida ate", MV_PAR08, "@!"  , ""  ,""      , "" , 050 , .F. } )
	AADD( _aParAux , { 1 , "Produto de"         , MV_PAR09, "@!"  , ""  ,"SB1"   , "" , 100 , .F. } )
	AADD( _aParAux , { 1 , "Produto ate"        , MV_PAR10, "@!"  , ""  ,"SB1"   , "" , 100 , .F. } )
	AADD( _aParAux , { 1 , "Grupo de Produtos"  , MV_PAR11, "@!"  , ""  ,"LSTSBM", "" , 100 , .F. } )
	AADD( _aParAux , { 3 , "Lista NFs"          , MV_PAR12, _aOpcoes                  , 100 , "",.T.,.T.,.T.} )
	AADD( _aParAux , { 3 , "Ordenar por"        , MV_PAR13, _aOrdem                   , 100 , "",.T.,.T.,.T.} )

	_aParRet:={}
	For nI := 1 To Len( _aParAux )
		aAdd( _aParRet , _aParAux[nI][03] )
	Next

	cTitle:="Relatorio de Transferencias entre filiais"
	DO WHILE .T.
		//aParametros, cTitle , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ]
		IF !ParamBox( _aParAux , cTitle , @_aParRet,     , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
			RETURN .F.
		EndIf
		_aAcesso:= {}
		cTimeInicial:=TIME()

		FWMSGRUN( ,{|| _aAcesso:= FWEmpLoad(.F.) } , "Lendo Acessos de filiais - Hora Inicial: "+cTimeInicial+", Aguarde...",  )

		IF !ValFilial(@MV_PAR01,"Filial Origem" )
			LOOP
		ENDIF
		IF !ValFilial(@MV_PAR02,"Filial Destino")
			LOOP
		ENDIF

		IF !(MV_PAR04 >= MV_PAR03)
			U_ITMSG("Periodo da Data de Emissao INVALIDO",'Atenção!',"Tente novamente com outro periodo",1)
			LOOP
		ENDIF

		IF VALTYPE(MV_PAR12) = "N"
			MV_PAR12:=STR(MV_PAR12,1)
		ENDIF
		IF VALTYPE(MV_PAR13) = "N"
			MV_PAR13:=STR(MV_PAR13,1)
		ENDIF

		cTimeInicial:=TIME()

		FWMSGRUN( ,{|oProc| RCOM022R(oProc) } , "Lendo Dados - Hora Inicial: "+cTimeInicial+", Aguarde...",  )

	ENDDO

Return(.T.)
/*
===============================================================================================================================
Programa.........: RCOM022R
Autor............: Alex Wallauer
Data da Criacao..: 23/02/2024
===============================================================================================================================
Descricao........: Leitura dos dados selecinados.
===============================================================================================================================
Parametros.......: oProc
===============================================================================================================================
Retorno..........: Nenhum
===============================================================================================================================*/
Static Function RCOM022R(oProc)
Local aFilsCalc  := {}  , L               			// Array com dados das filiais
Local aAreaSM0   := SM0->(GetArea()) 				// Status original do arquivo SM0
Local cFilBack   := cFilAnt           		 		// Filial corrente original
Local lUsaFilTrf := UsaFilTrf()
Local _aDados := {}

U_ITLOGACS("RCOM022")

SB1->(DBSETORDER(1))
SF4->(DBSETORDER(1))

If MV_PAR13 = "1" // Ordem por produto 
	SD2->(DBSETORDER(1))
ElseIf MV_PAR13 = "2" // Ordem de documento
	SD2->(DBSETORDER(3))
ElseIf MV_PAR13 = "3" // Ordem de data
	SD2->(DBSETORDER(5))      
EndIf

//³ Carrega filiais da empresa corrente                          ³
DBSELECTAREA("SM0")
DBSEEK(CEMPANT)
DO WHILE ! EOF() .And. SM0->M0_CODIGO == cEmpAnt
	// Adiciona filial
	AADD(aFilsCalc,{ALLTRIM(SM0->M0_CODFIL),SM0->M0_CGC,SM0->M0_FILIAL})
	DBSKIP()
ENDDO

//	dbSelectArea("SD2")  IF(SerieNfId("SD2",3,"D2_SERIE")

	//cQuery := "SELECT SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_DOC,"+ IIF(SerieNfId("SD2",3,"D2_SERIE")<>"D2_SERIE","SD2."+SerieNfId("SD2",3,"D2_SERIE")+","," ")
	//cQuery += "SD2.D2_SERIE,SD2.D2_COD,SD2.D2_TES,SD2.D2_CF,SD2.D2_UM,"
	//cQuery += "SD2.D2_QUANT,SD2.D2_TOTAL,SD2.D2_CUSTO1,SD2.D2_TIPO,SD2.D2_CLIENTE,SD2.D2_LOJA"
	
	lQuery    := .T.
	cAliasSD2 := GetNextAlias()  

	cQuery := "SELECT SD2.R_E_C_N_O_ RECSD2 
	cQuery += " FROM "
	cQuery += RetSqlName("SD2")+" SD2 ,"+RetSqlName("SF4")+" SF4 
	cQuery += "WHERE SD2.D_E_L_E_T_ <> '*' "

    IF !EMPTY(MV_PAR01) // DESTINO
       cQuery += " AND SD2.D2_FILIAL IN "+FormatIn(ALLTRIM(MV_PAR01),";")+"  "
    ENDIF

	cQuery += " AND SF4.F4_FILIAL  = SD2.D2_FILIAL AND SF4.D_E_L_E_T_ <> '*'  "
	cQuery += " AND SF4.F4_TRANFIL = '1' AND SF4.F4_CODIGO = SD2.D2_TES  "
	
	cQuery += " AND SD2.D2_EMISSAO BETWEEN '"+ DTOS(MV_PAR03) +"' AND '"+ DTOS(MV_PAR04) +"'  "

    IF !EMPTY(MV_PAR05)
       cQuery += "   AND SD2.D2_DOC >= '" + (MV_PAR05) + "' "
    ENDIF
    IF !EMPTY(MV_PAR06)
       cQuery += "   AND SD2.D2_DOC <= '" + (MV_PAR06) + "' "
    ENDIF

    IF !EMPTY(MV_PAR07)
       cQuery += "   AND SD2."+SERIENFID("SD2",3,"D2_SERIE")+" >= '" + (MV_PAR07) + "' "
    ENDIF
    IF !EMPTY(MV_PAR08)
       cQuery += "   AND SD2."+SERIENFID("SD2",3,"D2_SERIE")+" <= '" + (MV_PAR08) + "' "
    ENDIF

    IF !EMPTY(MV_PAR09)
       cQuery += "   AND SD2.D2_COD >= '" + (MV_PAR09) + "' "
    ENDIF
    IF !EMPTY(MV_PAR10)
       cQuery += "   AND SD2.D2_COD <= '" + (MV_PAR10) + "' "
    ENDIF

    IF !EMPTY(MV_PAR11)
       cQuery += " AND EXISTS (SELECT 'Y' FROM " +RetSqlName("SB1")+" B1 WHERE B1.D_E_L_E_T_ = ' ' "
	   cQuery += "                                                         AND B1.B1_FILIAL  = '" + xFilial("SB1") + "'"
       cQuery += "                                                         AND B1_GRUPO IN "+FormatIn(ALLTRIM(MV_PAR11),";")+" ) "
    ENDIF

	cQuery += "ORDER BY " + SQLORDER(SD2->(INDEXKEY()))
	
	DBUSEAREA(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
	DBSELECTAREA(cAliasSD2)

    _nTot:=nConta:=0
    COUNT TO _nTot
    _cTot:=ALLTRIM(STR(_nTot))
    DBGOTOP()
    
	DO WHILE (cAliasSD2)->(!EOF())

       SD2->(DBGOTO((cAliasSD2)->RECSD2))

	    nConta++
	    oproc:cCaption := ("Lendo Dados: "+STRZERO(nConta,5) +" de "+ _cTot )
	    ProcessMessages()

			// Checa TES
			
			If lQuery //.Or. (!lQuery .And. SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)) .And. SF4->F4_TRANFIL == "1")
				
				//aEmp :=FWSM0Util():GetSM0Data("01",SD2->D2_FILIAL,{"M0_CGC","M0_CODFIL","M0_FILIAL"})
				aRetNF:=RCOM22BuscaNF(aFilsCalc,"SD2",lUsaFilTrf)
				
				If Len(aRetNF) > 0
					
					// Checa status de acordo com o parametro
					IF MV_PAR12 = "3" .OR. (MV_PAR12 = "2" .AND. !EMPTY(aRetNF[3])) .Or. ;
					                       (MV_PAR12 = "1" .AND.  EMPTY(aRetNf[3]))
						
	                    // Posiciona no produto
	                    SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))

                        _aItens:={}
						AADD(_aItens,SD2->D2_FILIAL)
						AADD(_aItens,FWSM0Util():GetSM0FullName("01",SD2->D2_FILIAL))//ALLTRIM(aEmp[3,2]))//
						IF SD2->D2_TIPO $ "DB"
                           AADD(_aItens,Posicione("SA2",1,xFilial("SA2")+SD2->(D2_CLIENTE+D2_LOJA),"A2_NREDUZ"))
						ELSE
						   AADD(_aItens,Posicione("SA1",1,xFilial("SA1")+SD2->(D2_CLIENTE+D2_LOJA),"A1_NREDUZ"))
						ENDIF
						AADD(_aItens,SD2->D2_DOC)
						AADD(_aItens,SD2->D2_SERIE)
						AADD(_aItens,SD2->D2_TES)
						AADD(_aItens,SD2->D2_CF)
						AADD(_aItens,SD2->D2_COD)
						AADD(_aItens,SB1->B1_DESC)
						AADD(_aItens,SB1->B1_GRUPO)
						AADD(_aItens,SD2->D2_UM)
						AADD(_aItens,SD2->D2_QUANT)
						AADD(_aItens,SD2->D2_TOTAL)
						AADD(_aItens,SD2->D2_VALIPI)
						AADD(_aItens,SD2->D2_VALICM)
						AADD(_aItens,SD2->D2_CUSTO1)
						AADD(_aItens,SD2->D2_EMISSAO)
						// Imprime informacoes da devolucao
						AADD(_aItens,aRetNf[1])
						IF !EMPTY(aRetNf[3])
						   AADD(_aItens,aRetNf[2])
						ELSE
						   AADD(_aItens,"O documento ainda nao foi classificado (pre-nota)")
						ENDIF
					    AADD(_aItens,aRetNf[3])
						AADD(_aItens,aRetNf[4])
						AADD(_aItens,aRetNf[5])
					    AADD(_aDados,_aItens)
					EndIf
				EndIf
			EndIf
			(cAliasSD2)->(DBSKIP())
		//EndDo
		
	EndDo

// Fecha arquivo da query
If lQuery
	dbSelectArea(cAliasSD2)
	dbCloseArea()
	dbSelectArea("SD2")
EndIf
		
// Restaura filial original
cFilAnt:=cFilBack
RestArea(aAreaSM0)

If LEN(_aDados) > 0 
	
   oproc:cCaption := ("Acertos finais...")
   _aTit:={}
   _aCabXML:={}
   // Alinhamento: 1-Left   ,2-Center,3-Right
   // Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
   //             Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
   //   (_aCabXML,{Titulo             ,1           ,1         ,.F.       })
   AADD(_aTit,'Filial Origem')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//01
   AADD(_aTit,'Nome da Filial')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,1           ,1         ,.F.})//02
   AADD(_aTit,'Nome do Cliente')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,1           ,1         ,.F.})//02
   AADD(_aTit,'Documento')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//03
   AADD(_aTit,'Serie') 
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//04
   AADD(_aTit,'TES Origem') 
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//05
   AADD(_aTit,'CFO Origem') 
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//06
   AADD(_aTit,'Produto') 
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//07
   AADD(_aTit,'Descricao do Produto')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,1           ,1         ,.F.})//08
   AADD(_aTit,'Grupo do Produto')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//09
   AADD(_aTit,'UM')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//10
   AADD(_aTit,'Quantidade')           ; _nPosQtde:=LEN(_aTit)
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,2         ,.F.})//11
   AADD(_aTit,'Valor Total')          ; _nPosVrT:=LEN(_aTit)
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,2         ,.F.})//12
   AADD(_aTit,'Valor IPI')          ; _nPosVICM:=LEN(_aTit)
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,2         ,.F.})//12
   AADD(_aTit,'Valor ICM')          ; _nPosVipi:=LEN(_aTit)
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,2         ,.F.})//12
   AADD(_aTit,'Custo Total')          ; _nPosCuT:=LEN(_aTit)
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,2         ,.F.})//13
   AADD(_aTit,'Data de Emissao')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,4         ,.F.})//14
   AADD(_aTit,'Filial Destino')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//15
   AADD(_aTit,'Nome da Filial')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,1           ,1         ,.F.})//16
   AADD(_aTit,'Data de Digitacao')
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,4         ,.F.})//17
   AADD(_aTit,'Valor Total Destino')  ; _nPosDVrT:=LEN(_aTit)
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,2         ,.F.})//18
   AADD(_aTit,'Custo Total Destino')  ; _nPosDCuT:=LEN(_aTit)
   AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,2         ,.F.})//19

   _cPictQtide:= "9999"+PesqPict("SD2","D2_QUANT")
   _cPictValor:= "9999"+PesqPict("SD2","D2_TOTAL")

//*************************************************************************************************
   _aColXML:=ACLONE(_aDados)//FORMATO CORRETO PARA GERAR O EXCEL EM INGLES COM PONTO PARA DECIMAIS
//*************************************************************************************************
   FOR L := 1 TO LEN(_aDados)//AJUSTE PARA MOSTRAR NA TELA DO U_ITListBox() CORRETA
       _aDados[L,_nPosQtde]:= TRANSFORM(_aDados[L,_nPosQtde],_cPictQtide)
       _aDados[L,_nPosVrT ]:= TRANSFORM(_aDados[L,_nPosVrT ],_cPictValor)
       _aDados[L,_nPosVICM]:= TRANSFORM(_aDados[L,_nPosVICM ],_cPictValor)
       _aDados[L,_nPosVIPI]:= TRANSFORM(_aDados[L,_nPosVIPI ],_cPictValor)
       _aDados[L,_nPosCuT ]:= TRANSFORM(_aDados[L,_nPosCuT ],_cPictValor)
       _aDados[L,_nPosDVrT]:= TRANSFORM(_aDados[L,_nPosDVrT],_cPictValor)
       _aDados[L,_nPosDCuT]:= TRANSFORM(_aDados[L,_nPosDCuT],_cPictValor)
   NEXT

    _cTitulo:=cTitle+" - "+DTOC(DATE())+" - "+TIME()
    _cMsgTop:= NIL
	_aSX1:=RCOM022X()
	//                        , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons , _aCab  , bDblClk , _aColXML , bCondMarca,_bLegenda:EVAL(_bLegenda,_aCols,oLbxAux:nAt),_lHasOk,_bHeadClk,_aSX1)
	U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 3    ,_cMsgTop,          ,        ,         ,     ,        ,           ,_aCabXML,         , _aColXML ,           ,                                            ,       ,         ,_aSX1)
Else				
	U_ITMSG("Não há dados para essa seleção",'Atenção!',"Redefina o Filtro por favor.",3)
EndIf

Return(.T.)

/*
===============================================================================================================================
Programa--------: RCOM22BuscaNF
Autor-----------: Alex Wallauer
Data da Criacao-: 23/02/2024
===============================================================================================================================
Descrição-------: Funcao que Busca a NF
===============================================================================================================================
Parametros------: aFilsCalc,cAliasSD2,lUsaFilTrf
===============================================================================================================================
Retorno---------: aRetNf:={aFilsCalc[nAchoFil,1] ,aFilsCalc[nAchoFil,3],SD1->D1_DTDIGIT,SD1->D1_TOTAL,SD1->D1_CUSTO}
===============================================================================================================================
*/                     
Static Function RCOM22BuscaNF(aFilsCalc,cAliasSD2,lUsaFilTrf)
	Local aRetNf      := {"","","",0,0}
//Local nAchoCGC    := 0
	Local nAchoFil    := 0
	Local aArea       := GetArea()
	Local cFilBack    := cFilAnt
//Local cCGCOrig    := ""
//Local cCGCDest    := aEmp[1,2]//SM0->M0_CGC
	Local cCodFilOrig := ""
	Local cCodFilDest := SD2->D2_FILIAL//ALLTRIM(aEmp[2,2])//SM0->M0_CODFIL
	Local _cProduto 	:= ""
	Local lCont			:= .F.

/*If !lUsaFilTrf
  // Posiciona no fornecedor
	If (cAliasSD2)->D2_TIPO $ "DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCGCOrig:=SA2->A2_CGC
		EndIf
	Else
		// Posiciona no cliente
		cArqCliFor:="SA1"
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCGCOrig:=SA1->A1_CGC
		EndIf
	EndIf
	
	// Checa se cliente / fornecedor esta configurado como filial do sistema
	If !Empty(cCGCOrig) .And. ((nAchoCGC:=ASCAN(aFilsCalc,{|x| x[2] == cCGCOrig})) > 0)
		// Pesquisa se nota fiscal ja foi registrada no destino
		cFilAnt := aFilsCalc[nAchoCGC,1]
		dbSelectArea("SD1")
		dbSetOrder(2)
		dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE)
		While !Eof() .And. xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE == D1_FILIAL+D1_COD+D1_DOC+D1_SERIE
			// Checa TES
			If !Empty(SD1->D1_TES)
				If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES)) .And. SF4->F4_TRANFIL == "1"
					// Itens de nota fiscal de entrada
					If SD1->D1_TIPO $ "DB"
						dbSelectArea("SA1")
						dbSetOrder(1)
						If MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. SA1->A1_CGC == cCGCDest
							aRetNf:={cFilAnt,aFilsCalc[nAchoCGC,3],SD1->D1_DTDIGIT,SD1->D1_TOTAL,SD1->D1_CUSTO}
							Exit
						EndIf
					Else
						dbSelectArea("SA2")
						dbSetOrder(1)
						If MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. SA2->A2_CGC == cCGCDest
							aRetNf:={aFilsCalc[nAchoCGC,1] ,aFilsCalc[nAchoCGC,3],SD1->D1_DTDIGIT,SD1->D1_TOTAL,SD1->D1_CUSTO}
							Exit
						EndIf
					EndIf
				EndIf
			Else
				// O documento ainda nao foi classificado (pre-nota), portanto o material pode ser considerado "ainda em transito"
				aRetNf:={cFilAnt,aFilsCalc[nAchoCGC,3],'',SD1->D1_TOTAL,SD1->D1_CUSTO}
			EndIf
			dbSelectArea("SD1")
			dbSkip()
		End
	EndIf  
Else  */
	// Posiciona no fornecedor
	If (cAliasSD2)->D2_TIPO $ "DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCodFilOrig := SA2->A2_FILTRF
		EndIf
	Else
		// Posiciona no cliente
		cArqCliFor:="SA1"
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCodFilOrig := SA1->A1_FILTRF
		EndIf
	EndIf
    
	IF !EMPTY(MV_PAR02) .AND. !cCodFilOrig $ ALLTRIM(MV_PAR02)//FILIAL DE DESTINO
       RETURN {}
    ENDIF
	
	// Checa se cliente / fornecedor esta configurado como filial do sistema
	If !Empty(cCodFilOrig) .And. (nAchoFil := ASCAN(aFilsCalc,{|x| x[1] == alltrim(cCodFilOrig)})) > 0 
		// Pesquisa se nota fiscal ja foi registrada no destino
		cFilAnt := aFilsCalc[nAchoFil,1]//FILIAL DE DESTINO
		
		If (cAliasSD2)->D2_FILIAL == "40" .AND. (cAliasSD2)->D2_COD == "08000000064    " .AND. cFilAnt == "01"
			_cProduto	:= "08000000007    "
		ElseIf (cAliasSD2)->D2_FILIAL == "11" .AND. (cAliasSD2)->D2_COD == "08000000034    " .AND. cFilAnt == "10"
			_cProduto	:= "08000000004    "
		ElseIf (cAliasSD2)->D2_FILIAL == "93" .AND. (cAliasSD2)->D2_COD == "080000000088    " .AND. cFilAnt == "01"
			_cProduto	:= "08000000007    "
		Else
			_cProduto	:= (cAliasSD2)->D2_COD
		EndIf

		dbSelectArea("SD1")
		dbSetOrder(2)
		
		If (cAliasSD2)->D2_FILIAL == "40" .And. cFilAnt == "01" .And. SD1->(DBSEEK(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				//SD1->(dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				lCont	:= .T.
		ElseIf (cAliasSD2)->D2_FILIAL == "40" .And. cFilAnt == "01" .And. SD1->(DBSEEK(xFilial("SD1")+_cProduto+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				//SD1->(dbSeek(xFilial("SD1")+_cProduto+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				lCont	:= .T.
		ElseIf (cAliasSD2)->D2_FILIAL == "11" .AND. cFilAnt == "10" .And. dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE)
				//SD1->(dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				lCont	:= .T.
		ElseIf (cAliasSD2)->D2_FILIAL == "11" .AND. cFilAnt == "10" .And. SD1->(DBSEEK(xFilial("SD1")+_cProduto+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				//SD1->(dbSeek(xFilial("SD1")+_cProduto+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				lCont	:= .T.
		ElseIf (cAliasSD2)->D2_FILIAL == "93" .AND. cFilAnt == "01" .And. SD1->(DBSEEK(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				//SD1->(dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				lCont	:= .T.
		ElseIf (cAliasSD2)->D2_FILIAL == "93" .AND. cFilAnt == "01" .And. SD1->(DBSEEK(xFilial("SD1")+_cProduto+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				//SD1->(dbSeek(xFilial("SD1")+_cProduto+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				lCont	:= .T.
		ElseIf SD1->(dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
			   //SD1->(dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))
				lCont	:= .T.
		EndIf
		If lCont
		   
		    While !Eof() .And. (xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE == D1_FILIAL+D1_COD+D1_DOC+D1_SERIE .OR.;
							    xFilial("SD1")+_cProduto          +(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE == D1_FILIAL+D1_COD+D1_DOC+D1_SERIE)
		    
			IF SD1->D1_QUANT <> (cAliasSD2)->D2_QUANT
			   SD1->(DBSKIP())
			   LOOP
			ENDIF
			// Checa TES
			If !Empty(SD1->D1_TES)
				If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES)) .And. SF4->F4_TRANFIL == "1"
					// Itens de nota fiscal de entrada
					If SD1->D1_TIPO $ "DB"
						dbSelectArea("SA1")
						dbSetOrder(1)
						If MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. alltrim(SA1->A1_FILTRF) == alltrim(cCodFilDest)
							aRetNf:={cFilAnt,aFilsCalc[nAchoFil,3],SD1->D1_DTDIGIT,SD1->D1_TOTAL,SD1->D1_CUSTO}
							Exit
						EndIf
					Else
						dbSelectArea("SA2")
						dbSetOrder(1)
						If MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. alltrim(SA2->A2_FILTRF) == alltrim(cCodFilDest)
							aRetNf:={aFilsCalc[nAchoFil,1] ,aFilsCalc[nAchoFil,3],SD1->D1_DTDIGIT,SD1->D1_TOTAL,SD1->D1_CUSTO}
							Exit
						EndIf
					EndIf
				EndIf
			Else
				// O documento ainda nao foi classificado (pre-nota), portanto o material pode ser considerado "ainda em transito"
				aRetNf:={cFilAnt,aFilsCalc[nAchoFil,3],'',SD1->D1_TOTAL,SD1->D1_CUSTO}
			EndIf
			dbSelectArea("SD1")
			dbSkip()
		    ENDDO
		Else
			SD1->(DBSETORDER(19))//D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA
			//dbGotop()

			SD1->(dbSeek((cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE))

			DO WHILE !SD1->(EOF()) .AND.  (cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE == SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI)
				   
				If (cAliasSD2)->D2_FILIAL == SD1->D1_FILIAL  .AND.;
				   (cAliasSD2)->D2_COD    == SD1->D1_COD     .AND.;
				   (cAliasSD2)->D2_DOC    == SD1->D1_NFORI   .AND.;
				   (cAliasSD2)->D2_SERIE  == SD1->D1_SERIORI .AND.;
				   (cAliasSD2)->D2_ITEM   == ALLTRIM(SD1->D1_ITEMORI)//D1_ITEMORI É 4 CARACTES E O D2_ITEM 2 CARACTERES
				 	
					If SD1->D1_FORMUL == "S"
				 		aRetNF[2] := "NF Devolvida - Formulário Próprio" 
				 		aRetNF[3] := DTOC(SD1->D1_DTDIGIT)
				 		aRetNF[5] := SD1->D1_CUSTO
				 	Else
				 		aRetNF[2] := "NF Devolvida" 
				 		aRetNf[3] := DTOC(SD1->D1_DTDIGIT)
				 		aRetNF[5] := SD1->D1_CUSTO
				 	EndIf
				EndIf
				
				SD1->(DBSKIP())
			EndDo

		EndIf

	EndIf
//EndIf
// Reposiciona area original
cFilAnt:=cFilBack
RestArea(aArea)
RETURN aRetNf 


/*
===============================================================================================================================
Programa--------: ValFilial
Autor-----------: Alex Wallauer
Data da Criacao-: 23/02/2024
===============================================================================================================================
Descrição-------: Funcao que mostra a aba de parametros do relatório
===============================================================================================================================
Parametros------: _cFilial,_cCampo
===============================================================================================================================
Retorno---------: .T. ou .F.
===============================================================================================================================
*/                     
STATIC FUNCTION ValFilial(_cFilial,_cCampo)
	LOCAL nI
	LOCAL xVarAux := ALLTRIM(_cFilial)
	LOCAL _cFilsAcesso := ""
//Local _aAcesso	:= FWEmpLoad(.F.)

	For nI := 1 To LEN(_aAcesso)
		_cFilsAcesso+=_aAcesso[nI][03]+", "
	Next
	If EMPTY(xVarAux)
		U_ITMSG("Com a "+_cCampo+" em branco, somente as filiais que o usuario tem acesso serao selecionadas: "+_cFilsAcesso,'Atenção!',,3)
		_cFilial:=STRTRAN( _cFilsAcesso, ", ", ";")
	Else
		aDadAux := U_ITLinDel( xVarAux , ";" )
		SM0->(dbSetOrder(1))
		For nI := 1 To LEN(aDadAux)
			If !SM0->(dbSeek(cEmpAnt + aDadAux[nI]))
				U_ITMSG("Filial "+aDadAux[nI]+" informada não existe.",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
				RETURN .F.
			EndIf
			If !aDadAux[nI] $ _cFilsAcesso
				U_ITMSG("Filial "+aDadAux[nI]+" informada o usuário não tem acesso.",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
				RETURN .F.
			EndIf
		Next
	EndIf

RETURN .T.

/*
===============================================================================================================================
Programa--------: RCOM022X
Autor-----------: Alex Wallauer
Data da Criacao-: 23/02/2024
===============================================================================================================================
Descrição-------: Funcao que mostra a aba de parametros do relatório
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aPergunte
===============================================================================================================================
*/                     
Static Function RCOM022X()
	Local nAux     := 1
	Local _aDadosParam := {}
	Aadd(_aDadosParam,{"01", "Filial Origem"      , MV_PAR01 })
	Aadd(_aDadosParam,{"02", "Filial Destino"     , MV_PAR02 })
	Aadd(_aDadosParam,{"03", "Data Emissao de"    , MV_PAR03 })
	Aadd(_aDadosParam,{"04", "Data Emissao ate"   , MV_PAR04 })
	Aadd(_aDadosParam,{"05", "Doc saida de"       , MV_PAR05 })
	Aadd(_aDadosParam,{"06", "Doc saida ate"      , MV_PAR06 })
	Aadd(_aDadosParam,{"07", "Serie Doc saída de" , MV_PAR07 })
	Aadd(_aDadosParam,{"08", "Serie Doc saida ate", MV_PAR08 })
	Aadd(_aDadosParam,{"09", "Produto de"         , MV_PAR09 })
	Aadd(_aDadosParam,{"10", "Produto ate"        , MV_PAR10 })
	Aadd(_aDadosParam,{"11", "Grupo de Produtos"  , MV_PAR11 })
	If MV_PAR12 = "1"
		_cMV_PAR12 :="1-Em transito"
	Elseif MV_PAR12 = "2"
		_cMV_PAR12 :="2-Ja recebidas"
	Else
		_cMV_PAR12 :="3-Todos"
	Endif
	Aadd(_aDadosParam,{"12", "Lista NFs"          , _cMV_PAR12 })
	If MV_PAR13 = "1"
		_cMV_PAR13 :="1-Produto"
	Elseif MV_PAR13 = "2"
		_cMV_PAR13 :="2-Documento / Serie"
	Else
		_cMV_PAR13 :="3-Data de emissao"
	Endif
	Aadd(_aDadosParam,{"13", "Ordenar por"        , _cMV_PAR13 })

	_aPergunte:={}
	For nAux := 1 To Len(_aDadosParam)
		AADD(_aPergunte,{"Pergunta " + _aDadosParam[nAux,1] + ':',_aDadosParam[nAux,2],_aDadosParam[nAux,3] })
	Next

Return _aPergunte
