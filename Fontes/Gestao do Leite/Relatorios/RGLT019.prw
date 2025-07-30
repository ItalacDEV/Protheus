/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 18/06/2021 | Chamado 36884. Inclusão do Nome do atravessador PF do produtor PJ
Lucas Borges  | 17/04/2023 | Chamado 43587. Imprimir o Informativo de qualidade independente da quantidade de análise
Lucas Borges  | 05/05/2025 | Chamado 50600. Criada exceção para o evento 000229, prefixo GLA devido indefinição da diretoria
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT019
Autor-------------: Abrahao P. Santos
Data da Criacao---: 24/01/2009
Descrição---------: Demonstrativo do Produtor - Gestão do Leite
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT019()

Static cpMix	:= ""
Static cpSetor	:= ""
Static cpPrdIni	:= ""
Static cpPrdFim	:= ""
Static cpLjIni	:= ""
Static cpLjFim	:= ""
Static cpLinIni	:= ""
Static cpLinFim	:= ""
Static dpDtIni	:= StoD("")
Static dpDtFim	:= StoD("")

Private cPerg	:= "RGLT019"

If !Pergunte( cPerg , .T. )
	Return()
EndIf

//================================================================================
// Obtem parametros
//================================================================================
cpMix		:= mv_par01
cpSetor		:= mv_par02
cpPrdIni	:= mv_par03
cpLjIni		:= mv_par04
cpPrdFim	:= mv_par05
cpLjFim		:= mv_par06
cpLinIni	:= mv_par07
cpLinFim	:= mv_par08
dpDtIni		:= POSICIONE("ZLE",1,XFILIAL("ZLE")+cpMix,"ZLE_DTINI")
dpDtFim		:= POSICIONE("ZLE",1,XFILIAL("ZLE")+cpMix,"ZLE_DTFIM")

Processa({|| RGLT019RUN() })

Return()

/*
===============================================================================================================================
Programa----------: RGLT019RUN
Autor-------------: Abrahao P. Santos
Data da Criacao---: 24/01/2009
Descrição---------: Demonstrativo do Produtor - Gestão do Leite
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT019RUN()

Local nCount		:= 0
Local nPos4			:= 1800
Local nTab01		:= 100
Local nTab02		:= 800
Local nTab03		:= 1200
Local nTab04		:= 1600
Local nTab05		:= 2000
Local nTab11		:= 100
Local nTab12		:= 400
Local nTab13		:= 700
Local nTab14		:= 1000
Local nTab15		:= 1300
Local nTab16		:= 1700
Local nTotCre		:= 0
Local nTotDeb		:= 0
Local nTotVol		:= 0
Local nUltDia		:= 0
Local nTotQual		:= 0
Local dQual1
Local dQual2
Local dQual3
Local nOk			:= 0
Local aMensagem		:= {}
Local lmostra		:= .T.
Local nVolProd		:= 0
Local _cAliasZLF	:= GetNextAlias()
Local _cAliasPRD	:= ""
Local nReg			:= 0
Local nTotPend		:= 0                                                          
Local cCodLinRota	:= ""      
Local _cMesAno		:= ""  
Local _cDescEven	:= ""
Local _nTotal		:= 0
Local _nVlrPag		:= 0
Local _cCampo		:= ""
Local _cFiltro		:= ""
Local _nX			:= 0
Local _aClass 		:= RetSX3Box(GetSX3Cache("A2_L_CLASS","X3_CBOX"),,,1)
Local _cBonif		:= ""
Local _nInfQual		:= 0
Local _cMenAux		:= ""
Private nL			:= 0
Private nPos1		:= 100
Private nPos2		:= 350
Private nPos3		:= 1500
Private oFontTitulo	:= TFont():New("Arial",09,10,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFontRotulo	:= TFont():New("Arial",09,09,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFontNormal	:= TFont():New("Arial",09,08,.T.,.T.,5,.T.,5,.T.,.F.)
Private cRaizServer	:= If(issrvunix(), "/", "\")
Private _nBase		:= 0 //varivável declarada como private para poder ser lida por macroexecução (ZL8_FORMUL)

OpenSm0(cEmpAnt, .F.)// Cadatro de Filial
SM0->(DbSeek(cEmpAnt + cFilAnt))
// Objeto de impressao grafica
oPrint:= TMSPrinter():New( "Relatorio de Grafico" )
oPrint:SetPortrait() 
oPrint:Setup()
    
//Verifico qual evento deve ser usado na exceção de Jaru
If cFilAnt == "10"
	_cBonif:= "000095"
ElseIf cFilAnt == "11"
	_cBonif:= "000080"
EndIf
// Obtem dados de impressao
BeginSql alias _cAliasZLF
	SELECT ZLF_SETOR,ZLF_RETIRO,ZLF_RETILJ,ZLF_LINROT
	FROM %table:ZLF% ZLF
	WHERE D_E_L_E_T_ = ' '
	AND ZLF_FILIAL = %xFilial:ZLF%
	AND ZLF_CODZLE = %exp:cpMix%
	AND ZLF_SETOR = %exp:cpSetor%
	AND ZLF_RETIRO != ' '
	AND ZLF_LINROT BETWEEN %exp:cpLinIni% AND %exp:cpLinFim%
	AND ZLF_RETIRO BETWEEN %exp:cpPrdIni% AND %exp:cpPrdFim%
	AND ZLF_RETILJ BETWEEN %exp:cpLjIni% AND %exp:cpLjFim%
	GROUP BY ZLF_SETOR,ZLF_RETIRO,ZLF_RETILJ,ZLF_LINROT
	ORDER BY ZLF_LINROT,ZLF_RETIRO,ZLF_RETILJ
EndSql
Count to nQtdReg

ProcRegua(nQtdReg)

(_cAliasZLF)->(DbGoTop())
While !(_cAliasZLF)->(EOf())
	nCount++                   

	cCodLinRota:=(_cAliasZLF)->ZLF_LINROT
	incproc((_cAliasZLF)->ZLF_RETIRO)

    oPrint:StartPage()
    
	ImpCab()
		
	//===================================================================
	// Início dos dados do Produtor
	//===================================================================
		
	// Posiciona no Produtor
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+(_cAliasZLF)->(ZLF_RETIRO+ZLF_RETILJ)))
	DbSelectArea("ZL3")
	ZL3->(DbSetOrder(1))
	ZL3->(DbSeek(xFilial("ZL3")+(_cAliasZLF)->ZLF_LINROT))
		
	nL += 50
	oPrint:Say(nL,nPos1,"PRODUTOR:",oFontRotulo) 
	oPrint:Say(nL,nPos2,SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SA2->A2_NOME,oFontNormal) 
	oPrint:Say(nL,nPos3,"CPF:",oFontRotulo)
	oPrint:Say(nL,nPos4,SA2->A2_CGC,oFontNormal)

	nL += 50
	oPrint:Say(nL,nPos1,"FAZENDA:",oFontRotulo) 
	oPrint:Say(nL,nPos2,SA2->A2_L_FAZEN,oFontNormal) 
	oPrint:Say(nL,nPos3,"INSCRICAO:",oFontRotulo)
	oPrint:Say(nL,nPos4,SA2->A2_INSCR,oFontNormal)
		
	nL += 50
	oPrint:Say(nL,nPos1,"MUNICIPIO:",oFontRotulo) 
	oPrint:Say(nL,nPos2,SA2->A2_MUN,oFontNormal) 
	oPrint:Say(nL,nPos3,"SIGSIF:",oFontRotulo)
	oPrint:Say(nL,nPos4,SA2->A2_L_SIGSI,oFontNormal)

	nL += 50
	oPrint:Say(nL,nPos1,"LINHA:",oFontRotulo) 
	oPrint:Say(nL,nPos2,(_cAliasZLF)->ZLF_LINROT+" - "+ZL3->ZL3_DESCRI,oFontNormal) 
	oPrint:Say(nL,nPos3,"NIRF:",oFontRotulo)
	oPrint:Say(nL,nPos4,SA2->A2_L_NIRF,oFontNormal)

	nL += 50
	If !Empty(SA2->A2_L_NATRA)
		oPrint:Say(nL,nPos3,"ATRAVESSADOR:",oFontRotulo)
		oPrint:Say(nL,nPos4,SA2->A2_L_NATRA,oFontNormal)
	EndIf
	oPrint:Say(nL,nPos1,"FRETISTA:",oFontRotulo)
		

	SA2->(DbSeek(xFilial("SA2")+ZL3->(ZL3_FRETIS+ZL3_FRETLJ)))
		
	oPrint:Say(nL,nPos2, ZL3->ZL3_FRETIS +'/'+ ZL3->ZL3_FRETLJ +" - "+ SA2->A2_NOME , oFontNormal ) //Ajuste para considerar a Loja no posicionamento e exibição [Chamado-6851]
	oPrint:Say(nL,nPos3,"",oFontRotulo)
	oPrint:Say(nL,nPos4,"",oFontNormal)
		
	SA2->(DbSeek(xFilial("SA2")+(_cAliasZLF)->(ZLF_RETIRO+ZLF_RETILJ)))
	SA2->(DbSeek(xFilial("SA2")+SA2->(A2_L_TANQ + A2_L_TANLJ)))
	nL += 50
	oPrint:Say(nL,nPos1,"RESP.TANQUE:",oFontRotulo) 
	oPrint:Say(nL,nPos2,SA2->A2_COD +'/'+ SA2->A2_LOJA +" - "+ SA2->A2_NOME , oFontNormal ) //Ajuste para considerar a Loja no posicionamento e exibição [Chamado-6851]
		
	SA2->(DbSeek(xFilial("SA2")+(_cAliasZLF)->(ZLF_RETIRO+ZLF_RETILJ)))
	oPrint:Say(nL,nPos3,"CLASS.TANQUE:",oFontRotulo)
	oPrint:Say(nL,nPos4,_aClass[aScan(_aClass,{|x| x[2] == SA2->A2_L_CLASS})][3],oFontNormal) 

	nL += 50
	oPrint:Say(nL,nPos1,"BANCO:",oFontRotulo) 
	oPrint:Say(nL,nPos2,SA2->A2_BANCO+" AG:"+SA2->A2_AGENCIA+" CC:"+SA2->A2_NUMCON,oFontNormal) 

	nL += 50
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	//===================================================================
	// Fim dos dados do Produtor
	//===================================================================

	//===================================================================
	// Início dos eventos do Produtor na ZLF
	//===================================================================
	If mv_par09 != 2 //Default ou por produtor
		nL += 50
		oPrint:Say(nL,900,"DEMONSTRATIVO DE PAGAMENTO DE LEITE",oFontRotulo)
		nL += 50
		oPrint:Say(nL,900,"PERIODO DE "+dtoc(dpDtIni)+" A "+dtoc(dpDtFim),oFontRotulo)
		nL += 50
		oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
		nL += 10
		oPrint:Say(nL,nTab01,"Eventos       ",oFontRotulo)
		oPrint:Say(nL,nTab02,"Litros        ",oFontRotulo)
		oPrint:Say(nL,nTab03,"Vlr Unit.(R$) ",oFontRotulo)
		oPrint:Say(nL,nTab04,"Ganhos (R$)   ",oFontRotulo)
		oPrint:Say(nL,nTab05,"Descontos (R$)",oFontRotulo)
		nL += 50
		oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 

		nL += 10

		// Obtem Eventos lancados ao produtor corrente
		_cCampo := "% "
		_cFiltro:= "% "
		If cpMix == "000118" .And. cFilAnt $ "10/11"
			_cCampo += " SUM (CASE WHEN ZLF_EVENTO = '000002' THEN ZLF_TOTAL "
			_cCampo += " + NVL((SELECT SUM(ZLF_TOTAL)
			_cCampo += " FROM "+RetSqlName("ZLF")+" B "
			_cCampo += " WHERE B.D_E_L_E_T_ = ' '"
			_cCampo += " AND B.ZLF_FILIAL = ZLF.ZLF_FILIAL"
			_cCampo += " AND B.ZLF_CODZLE = '"+cpMix+"' "
			_cCampo += " AND B.ZLF_SETOR = ZLF.ZLF_SETOR"
			_cCampo += " AND B.ZLF_RETIRO = ZLF.ZLF_RETIRO"
			_cCampo += " AND B.ZLF_RETILJ = ZLF.ZLF_RETILJ"
			_cCampo += " AND B.ZLF_LINROT = ZLF.ZLF_LINROT"
			_cCampo += " AND B.ZLF_TP_MIX = 'L'"
			_cCampo += " AND B.ZLF_EVENTO = '"+_cBonif+"'),0)"
			_cCampo += " ELSE ZLF_TOTAL"
			_cCampo += " END) AS TOTAL, "
			_cCampo += " SUM (CASE WHEN ZLF_EVENTO = '000002' THEN ZLF_VLRPAG "
			_cCampo += " + NVL((SELECT SUM(ZLF_VLRPAG)
			_cCampo += " FROM "+RetSqlName("ZLF")+" B "
			_cCampo += " WHERE B.D_E_L_E_T_ = ' '"
			_cCampo += " AND B.ZLF_FILIAL = ZLF.ZLF_FILIAL"
			_cCampo += " AND B.ZLF_CODZLE = '"+cpMix+"' "
			_cCampo += " AND B.ZLF_SETOR = ZLF.ZLF_SETOR"
			_cCampo += " AND B.ZLF_RETIRO = ZLF.ZLF_RETIRO"
			_cCampo += " AND B.ZLF_RETILJ = ZLF.ZLF_RETILJ"
			_cCampo += " AND B.ZLF_LINROT = ZLF.ZLF_LINROT"
			_cCampo += " AND B.ZLF_TP_MIX = 'L'"
			_cCampo += " AND B.ZLF_EVENTO = '"+_cBonif+"'),0)"
			_cCampo += " ELSE ZLF_VLRPAG"
			_cCampo += " END) AS VLRPAG, "
		Else
			_cCampo += " SUM(ZLF_TOTAL) AS TOTAL,SUM(ZLF_VLRPAG) AS VLRPAG,"
		EndIf
		If cpMix $ ("000118/000119") .And. cFilAnt $ "10/11"
			_cCampo += " SUM(NVL((SELECT SUM(ZLF_TOTAL)
			_cCampo += " FROM "+RetSqlName("ZLF")+" A "
			_cCampo += " WHERE A.D_E_L_E_T_ = ' '"
			_cCampo += " AND A.ZLF_FILIAL = ZLF.ZLF_FILIAL"
			_cCampo += " AND A.ZLF_CODZLE = '000119'
			_cCampo += " AND A.ZLF_SETOR = ZLF.ZLF_SETOR"
			_cCampo += " AND A.ZLF_RETIRO = ZLF.ZLF_RETIRO"
			_cCampo += " AND A.ZLF_RETILJ = ZLF.ZLF_RETILJ"
			_cCampo += " AND A.ZLF_LINROT = ZLF.ZLF_LINROT"
			_cCampo += " AND A.ZLF_TP_MIX = 'L'"
			_cCampo += " AND A.ZLF_EVENTO = '000035'),0)) ADTO_TOTAL,"

			_cCampo += " SUM(NVL((SELECT SUM(ZLF_VLRPAG)
			_cCampo += " FROM "+RetSqlName("ZLF")+" A "
			_cCampo += " WHERE A.D_E_L_E_T_ = ' '"
			_cCampo += " AND A.ZLF_FILIAL = ZLF.ZLF_FILIAL"
			_cCampo += " AND A.ZLF_CODZLE = '000119' "
			_cCampo += " AND A.ZLF_SETOR = ZLF.ZLF_SETOR"
			_cCampo += " AND A.ZLF_RETIRO = ZLF.ZLF_RETIRO"
			_cCampo += " AND A.ZLF_RETILJ = ZLF.ZLF_RETILJ"
			_cCampo += " AND A.ZLF_LINROT = ZLF.ZLF_LINROT"
			_cCampo += " AND A.ZLF_TP_MIX = 'L'"
			_cCampo += " AND A.ZLF_EVENTO = '000035'),0)) ADTO_VLRPAG, "
		EndIf
		_cCampo += " %"
		
		If cpMix == "000118" .And. cFilAnt $ "10/11"
			_cFiltro += " AND ZLF_EVENTO NOT IN('"+_cBonif+"')"
		ElseIf cpMix == "000119" .And. cFilAnt $ "10/11"
			_cFiltro += " AND ZLF_EVENTO NOT IN ('000035','000036') "
		EndIf
		_cFiltro += " %"

		_cAliasPRD:= GetNextAlias()
		BeginSql alias _cAliasPRD 
			SELECT  ZLF_SETOR, ZLF_EVENTO EVENTO,ZLF_DEBCRE DEBCRE,MAX(ZLF_QTDBOM) QTDBOM, %exp:_cCampo% MAX(ZLF_SEEKCO) SEEKCOMPL
			FROM %table:ZLF% ZLF
			WHERE D_E_L_E_T_ = ' '
			AND ZLF_FILIAL = %xFilial:ZLF%
			AND ZLF_CODZLE = %exp:cpMix%
			AND ZLF_SETOR = %exp:cpSetor%
			AND ZLF_RETIRO = %exp:(_cAliasZLF)->ZLF_RETIRO%
			AND ZLF_RETILJ = %exp:(_cAliasZLF)->ZLF_RETILJ%
			AND ZLF_LINROT = %exp:(_cAliasZLF)->ZLF_LINROT%
			AND ZLF_TP_MIX = 'L'
			%exp:_cFiltro%
			GROUP BY ZLF_SETOR, ZLF_EVENTO,ZLF_DEBCRE
			ORDER BY ZLF_SETOR, ZLF_DEBCRE,ZLF_EVENTO
		EndSql

		DbSelectArea("ZL8")
		ZL8->( DbSetOrder(1) )
		DbSelectArea("ZL2")
		ZL2->( DbSetOrder(1) )
		
		While !(_cAliasPRD)->(EOf())
			_nInfQual:= 0
			_nTotal := (_cAliasPRD)->TOTAL
			_nVlrPag := (_cAliasPRD)->VLRPAG
			If cpMix $ ("000118/000119") .And. cFilAnt $ "10/11"
				_nBase	:= (_cAliasPRD)->ADTO_TOTAL
			EndIf
			ZL8->(DbSeek(xFilial("ZL8")+(_cAliasPRD)->EVENTO) )
			ZL2->(DbSeek(xFilial("ZL2")+(_cAliasPRD)->ZLF_SETOR) )

			If cpMix == "000118" .And. cFilAnt $ "10/11" .And. (_cAliasPRD)->EVENTO == "000002"
				_nTotal += (_cAliasPRD)->ADTO_TOTAL
				_nVlrPag := (_cAliasPRD)->ADTO_VLRPAG
			ElseIf cpMix == "000118" .And. cFilAnt $ "10/11" .And. (_cAliasPRD)->EVENTO $ "000013/000016/000019" .And. _nBase > 0
				_nVlrPag += &(ZL8->ZL8_FORMUL)
			ElseIf cpMix == "000119" .And. cFilAnt $ "10/11" .And. (_cAliasPRD)->EVENTO $ "000013/000016/000019" .And. _nBase > 0
				_nVlrPag -= &(ZL8->ZL8_FORMUL)
			EndIf
			
			If ZL8->ZL8_RECIBO == "S"
				lmostra:=.t.
			Else
				lmostra:=.f.
			EndIf       
			    
			If lmostra  
			
				_cMesAno  := ""  
				_cDescEven:= POSICIONE("ZL8",1,XFILIAL("ZL8")+(_cAliasPRD)->EVENTO,"ZL8_DESCRI")
			          			    				
				//=============================================================
				// Verifica se o evento gerado eh de complemento de pagamento. 
				//=============================================================
				If Len(AllTrim((_cAliasPRD)->SEEKCOMPL)) > 0
					_cMesAno:= RGLT019D((_cAliasPRD)->SEEKCOMPL) 
					_cDescEven:= SubStr(AllTrim(_cDescEven),1,26) +'-'+ _cMesAno            
				EndIf
				
				oPrint:Say(nL,nTab01,SubStr(_cDescEven,1,32),oFontRotulo)								
				
				If (_cAliasPRD)->QTDBOM > 0
					oPrint:Say(nL,nTab02,Transform((_cAliasPRD)->QTDBOM,"@E 999,999,999"),oFontNormal)
				EndIf
				If (_cAliasPRD)->DEBCRE == "C"
					oPrint:Say(nL,nTab03,transform(_nTotal/(_cAliasPRD)->QTDBOM,"@E 9,999,999.9999"),oFontNormal)
					oPrint:Say(nL,nTab04,transform(_nTotal,"@E 999,999,999.99"),oFontNormal)
					nTotCre+=_nTotal
				Else
					oPrint:Say(nL,nTab03,transform(_nVlrPag/(_cAliasPRD)->QTDBOM,"@E 9,999,999.9999"),oFontNormal)
					oPrint:Say(nL,nTab05,transform(_nVlrPag,"@E 999,999,999.99"),oFontNormal)
					nTotDeb+=_nVlrPag
				EndIf
				nL += 50 
			EndIf
			(_cAliasPRD)->(DBSkip())
		EndDo
		(_cAliasPRD)->(dbcloseArea())
		oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 

		nL += 10
		oPrint:Say(nL,nTab01,"TOTAL",oFontRotulo)
		nVolProd:=U_VolLeite(xfilial("ZLF"),dpDtIni,dpDtFim,cpSetor,(_cAliasZLF)->ZLF_LINROT,(_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ)
		oPrint:Say(nL,nTab02,transform(nVolProd,"@E 999,999,999.99"),oFontRotulo)
		If !(cpMix $ "000118/000119" .And. cFilAnt $ "10/11")
			oPrint:Say(nL,nTab03,transform((nTotCre/nVolProd),"@E 999,999,999.9999"),oFontRotulo)
		EndIf
		oPrint:Say(nL,nTab04,transform(nTotCre,"@E 999,999,999.99"),oFontRotulo)
		oPrint:Say(nL,nTab05,transform(nTotDeb,"@E 999,999,999.99"),oFontRotulo)
		nL += 50
		oPrint:Say(nL,nTab04,"TOTAL A RECEBER-->",oFontRotulo)
		oPrint:Say(nL,nTab05,transform(nTotCre-nTotDeb,"@E 999,999,999.99"),oFontRotulo)
		
		nTotDeb:=0
		nTotCre:=0
	EndIf
	//===================================================================
	// Fim dos eventos do Produtor na ZLF
	//===================================================================

	//===================================================================
	// Início da recepção diária do Leite
	//===================================================================
	nL += 100
	oPrint:Say(nL,900,"VOLUME DE LEITE PRODUZIDO",oFontRotulo)
	nL += 50
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	nL += 10

	// Primeira Quinzena
	oPrint:Say(nL,nPos1,"Dia",oFontRotulo)		
	For _nX:=1 To 15
		oPrint:Say(nL,200+(_nX*120),Space(11-Len(AllTrim(Str(_nX))))+AllTrim(Str(_nX)),oFontRotulo)
	Next _nX
	nL += 50
	oPrint:Say(nL,nPos1,"Volume",oFontRotulo)
	For _nX:=1 To 15
		nAux:=RGLT019O((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,Substr(DToS(dpDtIni),1,6)+StrZero(_nX,2),(_cAliasZLF)->ZLF_LINROT)
		oPrint:Say(nL,200+(_nX*120),Transform(nAux,"@E 999,999,999"),oFontNormal)
		nTotVol+=nAux
	Next _nX
	nL += 50
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 

    // Segunda  Quinzena
	oPrint:Say(nL,nPos1,"Dia",oFontRotulo)	
	nUltDia:=val(substr(dtos(dpDtFim),7,2)) // ultimo dia do mes
	For _nX:=16 To nUltDia
		oPrint:Say(nL,200+((_nX-15)*120),Space(11-Len(AllTrim(str(_nX))))+AllTrim(str(_nX)),oFontRotulo)
	Next _nX
	nL += 50
	oPrint:Say(nL,nPos1,"Volume",oFontRotulo)
	For _nX:=16 To nUltDia
		//oPrint:Say(nL,200+(n*120),transform(99999,"@E 999,999,999"),oFontNormal)
		nAux:=RGLT019O((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,Substr(DToS(dpDtIni),1,6)+StrZero(_nX,2),(_cAliasZLF)->ZLF_LINROT)
		oPrint:Say(nL,200+((_nX-15)*120),Transform(nAux,"@E 999,999,999"),oFontNormal)
		nTotVol+=nAux
	Next _nX
	nL += 50
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	nL += 10
	oPrint:Say(nL,nPos1,"Total:",oFontRotulo)		
	oPrint:Say(nL,nPos2,transform(nTotVol,"@E 999,999,999")+" Litros",oFontNormal)		
	oPrint:Say(nL,nPos3,"Media Diária:",oFontRotulo)		
	oPrint:Say(nL,nPos4,transform(nTotVol/nUltDia,"@E 999,999,999")+" Litros",oFontNormal)		

	nTotVol:=0
	//===================================================================
	// Fim da recepção diária do Leite
	//===================================================================
	
	//===================================================================
	// Início do pagamento por qualidade
	//===================================================================
	// Obtem Data das ultimas 3 analises
	dQual1:= ""  
	dQual2:= ""
	dQual3:= ""
		
	aAux:= RGLT019N((_cAliasZLF)->ZLF_RETIRO,dpDtFim,(_cAliasZLF)->ZLF_RETILJ) 
	
	If Len(aAux)>=3
		dQual1:=aAux[3]
		dQual2:=aAux[2]
		dQual3:=aAux[1]
	EndIf
	If Len(aAux)==2
		dQual1:=aAux[2]
		dQual2:=aAux[1]
	EndIf
	If Len(aAux)==1
		dQual1:=aAux[1]
	EndIf
		
	nL += 100
	oPrint:Say(nL,900,"TABELA DE ANALISES",oFontRotulo)
	nL += 50
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	nL += 10
	oPrint:Say(nL,nTab11,"Análise",oFontRotulo)		
	oPrint:Say(nL,nTab12,"Referencia",oFontRotulo)		
	If !Empty(dQual1)
		oPrint:Say(nL,nTab13,dtoc(dQual1),oFontRotulo)		
	EndIf
	If !Empty(dQual2)
		oPrint:Say(nL,nTab14,dtoc(dQual2),oFontRotulo)		
	EndIf
	If !Empty(dQual3)
		oPrint:Say(nL,nTab15,dtoc(dQual3),oFontRotulo)		
	EndIf
	oPrint:Say(nL,nTab16,"Media Arit/Geom.",oFontRotulo)
	nL += 50
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	nL += 10
		
	DbSelectArea("ZL9")
	ZL9->(DbSetOrder(1))
	ZL9->(DbSeek(xFilial("ZL9")))
	While !ZL9->(EOf()) .and. xFilial("ZL9")==ZL9->ZL9_FILIAL
		If ZL9->ZL9_TIPO = "Q"   
			oPrint:Say(nL,nTab11,ZL9->ZL9_DESCRI,oFontRotulo)		
			oPrint:Say(nL,nTab12,ZL9->ZL9_REFERE,oFontRotulo)		

			// Verifica tipo de media a ser calculada: Aritmetica ou Geometrica
			IIf(ZL9->ZL9_MEDIA=="G",nTotQual:=1,nTotQual:=0)				                     
			// Obtem valor da primeira Data
			If !Empty(dQual1)
				nAux:=RGLT019V((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,dQual1,ZL9->ZL9_COD)
				//Define qual Informativo de qualidade deve ser impresso
				//0-Nenhum 1-CCS 2-CBT 3-CCS+CBT
				If ZL9->ZL9_COD == '000006' .And. nAux > 500//CCS
					_nInfQual := IIf(_nInfQual==0,1,3)
				ElseIf ZL9->ZL9_COD == '000007' .And. nAux > 300//CBT
					_nInfQual := IIf(_nInfQual==0,2,3)
				EndIf
				IIf(ZL9->ZL9_MEDIA=="G",IIf(nAux != 0,nTotQual*=nAux,),nTotQual+=nAux)
				IIf(nAux != 0,nOk++,)
				oPrint:Say(nL,nTab13,Transform(nAux,"@E 9,999,999.99"),oFontNormal)
			EndIf
				
			// Obtem valor da segunda Data
			If !Empty(dQual2)
				nAux:=RGLT019V((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,dQual2,ZL9->ZL9_COD)
				//Define qual Informativo de qualidade deve ser impresso
				//0-Nenhum 1-CCS 2-CBT 3-CCS+CBT
				If ZL9->ZL9_COD == '000006' .And. nAux > 500//CCS
					_nInfQual := IIf(_nInfQual==0,1,3)
				ElseIf ZL9->ZL9_COD == '000007' .And. nAux > 300//CBT
					_nInfQual := IIf(_nInfQual==0,2,3)
				EndIf
				IIf(ZL9->ZL9_MEDIA=="G",IIf(nAux != 0,nTotQual*=nAux,),nTotQual+=nAux)
				IIf(nAux != 0,nOk++,)
				oPrint:Say(nL,nTab14,Transform(nAux,"@E 9,999,999.99"),oFontNormal)
			EndIf
				
			// Obtem valor da terceira Data
			If !Empty(dQual3)
				nAux:=RGLT019V((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,dQual3,ZL9->ZL9_COD)
				//Define qual Informativo de qualidade deve ser impresso
				//0-Nenhum 1-CCS 2-CBT 3-CCS+CBT
				If ZL9->ZL9_COD == '000006' .And. nAux > 500//CCS
					_nInfQual := IIf(_nInfQual==0,1,3)
				ElseIf ZL9->ZL9_COD == '000007' .And. nAux > 300//CBT
					_nInfQual := IIf(_nInfQual==0,2,3)
				EndIf
				IIf(ZL9->ZL9_MEDIA=="G",IIf(nAux != 0,nTotQual*=nAux,),nTotQual+=nAux)
				IIf(nAux != 0,nOk++,)
				oPrint:Say(nL,nTab15,Transform(nAux,"@E 9,999,999.99"),oFontNormal)
			EndIf
				
			// Media
			If ZL9->ZL9_MEDIA=="G"
				nTotQual:=nTotQual^(1/nOk)
			Else
				nTotQual:=nTotQual/nOk
			EndIf
			
			oPrint:Say(nL,nTab16,Transform(nTotQual,"@E 9,999,999.99")+" "+ZL9->ZL9_MEDIA,oFontNormal)
			nTotQual:=0
			nOk:=0
				
			nL += 50
			nTotQual:=0
		EndIf
		ZL9->(DbSkip())
	EndDo

	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	nL += 100
	//===================================================================
	// Fim do pagamento por qualidade
	//===================================================================
		
	//===================================================================
	// Início dos débitos futuros
	//===================================================================
	//Incluída exceção para prefixo GLA na filial 04 porque a diretoria não conseguiu se decidir sobre esse evento
	_cAliasSE2 := GetNextAlias()
	BeginSql alias _cAliasSE2
		SELECT ZL8_COD, ZL8_DESCRI, SUM(E2_SALDO + E2_SDACRES) AS SALDO
		FROM %table:SE2% SE2, %table:ZL8% ZL8
		WHERE SE2.D_E_L_E_T_ = ' ' 
		AND ZL8.D_E_L_E_T_ = ' '
		AND E2_PREFIXO = ZL8_PREFIX 
		AND E2_FILIAL = ZL8_FILIAL
		AND E2_TIPO = 'NDF'
		AND ((E2_PREFIXO <> 'GLA' AND E2_FILIAL = '04') OR (E2_FILIAL <> '04'))
		AND E2_SALDO   > 0  
		AND E2_FORNECE = %exp:(_cAliasZLF)->ZLF_RETIRO%
		AND E2_LOJA    = %exp:(_cAliasZLF)->ZLF_RETILJ%
		GROUP BY ZL8_COD,ZL8_DESCRI
	EndSql
        
	Count to nReg
	(_cAliasSE2)->(DbGoTop())
	If nReg > 0
		oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
		nL += 10
		oPrint:Say(nL,900,"DEBITOS FUTUROS",oFontRotulo)
		nL += 50
		nTotPend:=0
		oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
		nL += 10
    EndIf               
	                             
	While (_cAliasSE2)->(!EOF())
		oPrint:Say(nL,nPos1,(_cAliasSE2)->ZL8_COD,oFontRotulo)
		oPrint:Say(nL,nPos2,(_cAliasSE2)->ZL8_DESCRI,oFontRotulo)
		oPrint:Say(nL,nPos3,transform((_cAliasSE2)->SALDO,"@E 999,999.99"),oFontRotulo) 
		nL += 50
		
		nTotPend+=(_cAliasSE2)->SALDO
		
		(_cAliasSE2)->(DbSkip())
	EndDo
	(_cAliasSE2)->(DbCloseArea())

	If nReg > 0
		oPrint:Say(nL,nPos1,"Valor Total Pendente ------>",oFontRotulo)
		oPrint:Say(nL,nPos3,transform(nTotPend,"@E 999,999.99"),oFontRotulo)
		nL += 50
	EndIf
	//===================================================================
	// Fim dos débitos futuros
	//===================================================================
		
	//===================================================================
	// Início do rodapé
	//===================================================================
	nL += 50 
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	nL += 10
	oPrint:Say(nL,800,"I N F O R M A T I V O      A O     P R O D U T O R ",oFontRotulo)
	nL += 50
	oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
	nL += 10

	aMensagem := u_showMemo(POSICIONE("ZLP",2,xFilial("ZLP")+cpMix+"1"+cpSetor,"ZLP_MENSAG"),120)
	For _nX:=1 To Len(aMensagem)
		If _nX <= 7 // Max. de Linhas
			oPrint:Say(nL,nPos1,aMensagem[_nX],oFontNormal)
			nL += 50 
		EndIf
	Next _nX
	//===================================================================
	// Fim do rodapé
	//===================================================================
	
	oPrint:EndPage()
	//===================================================================
	// Início do Informativo de Qualidade
	//===================================================================
	If _nInfQual > 0 .And. MV_PAR10 == 1

	    oPrint:StartPage()

	    ImpCab()
		nL += 50
		oPrint:Say(nL,900,"INFORMATIVO DE QUALIDADE INDIVIDUAL",oFontTitulo)
		nL += 100
		oPrint:Say(nL,nPos1,"Prezado (a) "+ AllTrim(SA2->A2_NOME)+",",oFontTitulo)
		nL += 100
		
		_cMenAux:= "O leite fornecido (a) pela sua propriedade rural a ITALAC se encontra fora dos padrões definidos pelas Instruções Normativas 76 e 77 "
		_cMenAux+= "(preconizadas pelo Ministério da Agricultura, Pecuária e Abastecimento) devido à alta taxa de "
		If _nInfQual == 1
			_cMenAux += "Contagem de Células Somáticas - CCS (também chamado de indicador de mastite)."
		ElseIf _nInfQual == 2
			_cMenAux += "Contagem Bacteriana Total - CBT (também chamado de indicador de Higiene)."
		Else
			_cMenAux += "Contagem Bacteriana Total - CBT (também chamado de indicador de Higiene) "
			_cMenAux += "e alta taxa de Contagem de Células Somáticas (também chamado de indicador de mastite)."
		EndIf
		impTexto(_cMenAux)
		If _nInfQual == 1
			oPrint:Say(nL,nPos1,"LOGO, SEGUE ABAIXO ALGUMAS INSTRUÇÕES DE COMO MELHORAR A TAXA DE CCS: ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"1.	DETECÇÃO DOS CASOS DE MASTITE ATRAVÉS DO USO DO TESTE DA CANECA DE FUNDO ESCURO (O LEITE QUE APRESENTAR GRUMOS, O(A) SENHOR(A) ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"DEVE SEPARAR ESTE ANIMAL PARA O FINAL DA ORDENHA E ESTE LEITE NÃO DEVE SER COLOCADO JUNTO AO LEITE FORNECIDO PARA O LATICÍNIO) ",oFontTitulo); nL += 100
			oPrint:Say(nL,nPos1,"2.	USO DO PÓS-DIPPING (EXEMPLO: IODO, ÁCIDO LÁCTICO, ENTRE OUTROS) APÓS A ORDENHA: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Cerca de 50% das Mastites é controlado com o uso diário do Pós Dipping ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"3.	APÓS A ORDENHA FORNECER ALIMENTAÇÃO PARA OS ANIMAIS, PARA QUE OS MESMOS NÃO DEITEM, POIS O TETO DO ANIMAL SE ENCONTRA ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"ABERTO ",oFontTitulo); nL += 100
			oPrint:Say(nL,nPos1,"4.	TRATAMENTO DOS CASOS DE MASTITE – CLÍNICA ",oFontTitulo); nL += 100
			oPrint:Say(nL,nPos1,"5.	CORRETA SECAGEM DOS ANIMAIS: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Uso do “antibiótico vaca-seca” para controle de Mastite no período seco ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Não ultrapassar o tempo de 10 meses de Lactação ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"6.	CUIDADOS NO PRÉ - PARTO: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	O local do pré - parto tem que ser o mais adequado (evitar locais com acúmulo de “barro”) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Se o animal já começou a soltar leite antes da parição, o mesmo deve passar pela ordenha para realização do Pós Dipping ",oFontRotulo); nL += 100
		ElseIf _nInfQual == 2
			oPrint:Say(nL,nPos1,"LOGO, SEGUE ABAIXO ALGUMAS INSTRUÇÕES DE COMO MELHORAR A TAXA DE CBT: ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"1.	REALIZAÇÃO DE UMA ORDENHA HIGIÊNICA: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Realizar a desinfecção dos tetos antes do inicio da ordenha (chamado de Pré-dipping) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Secar os tetos com papel toalha ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"c.	Após o término da ordenha utilizar o Pós-dipping (exemplo: iodo, ácido láctico, entre outros) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"d.	Utilização do coador/filtro adequado a ordenha ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"e.	Caso use ordenha “balde ao pé”, levar o leite para o tanque quando o latão atingir metade de sua capacidade ou, o mais rápido possível ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"2.	HIGIENIZAÇÃO DO EQUIPAMENTO DE ORDENHA: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Após o término da ordenha, circular água morna no sistema até a água sair completamente limpa ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Passagem do detergente alcalino clorado, em água com temperatura de 70 a 75º C (esta água deve circular de 08 a 10 minutos, não deixando ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"a água sair fria (menor que 45º C)) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"d.	Passagem do detergente ácido, em água a temperatura “ambiente” 01 ou mais vezes por semana ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"e.	Realizar a inspeção da ordenha a cada 07 dias, para verificar se não existe o acumulo de resíduo na ordenhadeira (caso exista realizar ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"a limpeza manual) ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"3.	HIGIENIZAÇÃO DO TANQUE DE EXPANSÃO OU LATÃO: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	A lavagem dos latões e do tanque tem que ser realizada com detergente alcalino clorado, juntamente com uma escova adequada ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Retirar toda a água com detergente ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"c.	Passagem do detergente ácido, em água a temperatura “ambiente” 01 vez por semana ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"d.	Verificar a limpeza do tanque, quando ele estiver seco, com o auxílio de uma lanterna ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"4.	MANUTENÇÃO DO TERMÔMETRO DO TANQUE: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Verifique junto ao transportador de seu leite, se a temperatura do seu leite analisada pelo termômetro do transportador é igual a temperatura ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"marcada pelo tanque (caso apareça diferença, contate um técnico para a realização da manutenção do seu tanque) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b. A temperatura máxima de estocagem e de coleta do seu leite deve ser de 4º C ou menos ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"A Contagem Bacteriana de seu leite é determinada pela Higiene durante o processo de ordenha e pela refrigeração rápida do leite, logo as ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"instruções acima vão indicar qual caminho seguir ",oFontRotulo); nL += 50
		Else
			oPrint:Say(nL,nPos1,"LOGO, SEGUE ABAIXO ALGUMAS INSTRUÇÕES DE COMO MELHORAR AS TAXAS DE CBT e CCS: ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"1.	REALIZAÇÃO DE UMA ORDENHA HIGIÊNICA: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Detecção dos casos de mastite através do uso do teste da caneca de fundo escuro (o leite que apresentar grumos, o(a) senhor(a) ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1," deve separar este animal para o final da ordenha e este leite não deve ser colocado junto ao leite fornecido para o laticínio) ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Após, realizar a desinfecção dos tetos (chamado de Pré-dipping) e a secagem com papel toalha ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"c.	Ao término da ordenha nos animais, utilizar o Pós-dipping (exemplo: iodo, ácido láctico, entre outros) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"d.	Cerca de 50% das Mastites é controlado com o uso diário do Pós Dipping ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"e.	Utilização do coador/filtro adequado a ordenha e caso use ordenha “balde ao pé”, levar o leite para o tanque quando o latão atingir metade ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"de sua capacidade ou, o mais rápido possível ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"2.	APÓS A ORDENHA FORNECER ALIMENTAÇÃO PARA OS ANIMAIS, PARA QUE OS MESMOS NÃO DEITEM, POIS O TETO DO ANIMAL SE ENCONTRA ABERTO ",oFontTitulo); nL += 100
			oPrint:Say(nL,nPos1,"3.	TRATAMENTO DOS CASOS DE MASTITE – CLÍNICA ",oFontTitulo); nL += 100
			oPrint:Say(nL,nPos1,"4.	CORRETA SECAGEM DOS ANIMAIS: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Uso do “antibiótico vaca-seca” para controle de Mastite no período seco ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Não ultrapassar o tempo de 10 meses de Lactação ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"5.	HIGIENIZAÇÃO DO EQUIPAMENTO DE ORDENHA: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Após o término da ordenha, circular água morna no sistema até a água sair completamente limpa ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Passagem do detergente alcalino clorado, em água com temperatura de 70 a 75º C (esta água deve circular de 08 a 10 minutos, não deixando ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"a água sair fria (menor que 45º C)) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"c.	Passagem do detergente ácido, em água a temperatura “ambiente” 01 ou mais vezes por semana ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"d.	Realizar a inspeção da ordenha a cada 07 dias, para verificar se não existe o acumulo de resíduo na ordenhadeira (caso exista realizar ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"a limpeza manual) ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"6.	HIGIENIZAÇÃO DO TANQUE DE EXPANSÃO OU LATÃO: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	A lavagem dos latões e do tanque tem que ser realizada com detergente alcalino, juntamente com uma escova adequada ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b.	Passagem do detergente ácido, em água a temperatura “ambiente” 01 ou mais vezes por semana ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"c.	Verificar a limpeza do tanque, quando ele estiver seco, com o auxílio de uma lanterna ",oFontRotulo); nL += 100
			oPrint:Say(nL,nPos1,"7.	MANUTENÇÃO DO TERMÔMETRO DO TANQUE: ",oFontTitulo); nL += 50
			oPrint:Say(nL,nPos1,"a.	Verifique junto ao transportador de seu leite, se a temperatura do seu leite analisada pelo termômetro do transportador é igual a temperatura ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"marcada pelo tanque (caso apareça diferença, contate um técnico para a realização da manutenção do seu tanque) ",oFontRotulo); nL += 50
			oPrint:Say(nL,nPos1,"b. A temperatura máxima de estocagem e de coleta do seu leite deve ser de 4ºC ou menos ",oFontRotulo); nL += 100
		EndIf
		
		nL += 100
		oPrint:Say(nL,nPos1,"Segue abaixo os padrões das Instruções Normativas 76 e 77:",oFontRotulo)
		nL += 100
		oPrint:FillRect({nL,500,nL+1,2000},TBrush():New("",0))
		nL += 10
		oPrint:Say(nL,nTab13,"CBT",oFontRotulo)
		oPrint:Say(nL,nTab14,"CCS",oFontRotulo)
		oPrint:Say(nL,nTab15,"GORDURA",oFontRotulo)
		oPrint:Say(nL,nTab16,"PROTEINA",oFontRotulo)
		nL += 50
		oPrint:FillRect({nL,500,nL+1,2000},TBrush():New("",0))
		nL += 10
		oPrint:Say(nL,nTab13,"Máximo de 300",oFontRotulo)
		oPrint:Say(nL,nTab14,"Máximo de 500 ",oFontRotulo)
		oPrint:Say(nL,nTab15,"Mínimo de 3,0 %",oFontRotulo)
		oPrint:Say(nL,nTab16,"Mínimo de 2,9%",oFontRotulo)
		nL += 50
		oPrint:Say(nL,nTab13,"(x 1.000 UFC/ml)",oFontNormal)
		oPrint:Say(nL,nTab14,"(x 1.000 CCS/ml)",oFontNormal)
		nL += 50
		oPrint:FillRect({nL,500,nL+1,2000},TBrush():New("",0)) 
		
		nL += 100
		oPrint:Say(nL,nPos1,"Qualquer dúvida, estamos à disposição para marcarmos visitas técnicas na melhoria da qualidade do seu leite.",oFontRotulo)
		nL += 10
		
		oPrint:EndPage()
	EndIf
	//===================================================================
	// Fim do Informativo de Qualidade
	//===================================================================
	(_cAliasZLF)->(DbSkip())
	
EndDo
(_cAliasZLF)->(DbCloseArea())
	
oPrint:Preview()

Return

/*
===============================================================================================================================
Programa----------: RGLT019N
Autor-------------: Abrahao P. Santos
Data da Criacao---: 24/01/2009
Descrição---------:Obtem datas das ultimas tres analises
Parametros--------: cpCodPrd - código do produtor
					dpData - database
					cLojaProd - loja do produtor
Retorno-----------: aret - array com datas das últimas análises
===============================================================================================================================
*/
Static function RGLT019N(cpCodPrd,dpData,cLojaProd)

Local aArea		:= GetArea()
Local _cAlias	:= GetNextAlias()
Local aRet		:={}
Local nQtd		:=0
Local _nAno		:= Val( SubStr( DtoS( dpData ) , 1 , 4 ) )
Local _nMes		:= Val( SubStr( DtoS( dpData ) , 5 , 2 ) )
Local _sDtInic	:= ""
Local _sDtFinal	:= DtoS(dpData)

//===================================================================
// Define os ultimos tres meses a serem considerados para obter      
// as analises de qualidade, isto de acordo com o mes de fechamento. 
//===================================================================
If _nMes - 2 == 0 
	_sDtInic:= AllTrim(Str(_nAno - 1)) + '1201'
ElseIf _nMes - 2 == -1 
	_sDtInic:= AllTrim(Str(_nAno - 1)) + '1101'
Else   
	_sDtInic:= AllTrim(Str(_nAno)) + AllTrim(Strzero(_nMes - 2,2)) + '01' //HEDER - 05/04/12 - Corrigido para considerar dois digitos no mes
EndIf

// Obtem Data das analise
BeginSql alias _cAlias 
	SELECT ZLB_DATA
	FROM %table:ZLB%
	WHERE D_E_L_E_T_ = ' '
	AND ZLB_FILIAL = %xFilial:ZLB%
	AND ZLB_RETIRO = %exp:cpCodPrd%
	AND ZLB_RETILJ = %exp:cLojaProd%
	AND ZLB_DATA BETWEEN %exp:_sDtInic% AND %exp:_sDtFinal%
	GROUP BY ZLB_DATA
	ORDER BY ZLB_DATA DESC
EndSql

While !(_cALias)->(EOf()) .And. nQtd<=2
	nQtd++
	aAdd(aRet,SToD((_cALias)->ZLB_DATA))
	(_cALias)->(DbSkip())
EndDo          

(_cAlias)->(DbCloseArea())

RestArea(aArea)	
Return aRet

/*
===============================================================================================================================
Programa----------: RGLT019V
Autor-------------: Abrahao P. Santos
Data da Criacao---: 24/01/2009
Descrição---------:Obtem valor analises
Parametros--------: cpCodPrd - código do produtor
					dpData - data da análise
					cLojaProd - loja do produtor
					cpTipoFx - tipo da análise
Retorno-----------: nret - valor da análise
===============================================================================================================================
*/
Static Function RGLT019V(cpCodPrd,cpLj,dpData,cpTipoFx)

Local _cAlias	:= GetNextAlias()
Local _aArea	:= GetArea()
Local _nRet		:=0

If Empty(dpData)
	Return 0
EndIf                            

// Obtem valor da analise na data referida
BeginSql Alias _cAlias
	SELECT ZLB_VLRFX
	FROM %Table:ZLB% ZLB
	WHERE D_E_L_E_T_ = ' '
	AND ZLB_FILIAL = %xFilial:ZLB%
	AND ZLB_DATA   = %exp:dpData%
	AND ZLB_TIPOFX = %exp:cpTipoFx%
	AND ZLB_RETIRO = %exp:cpCodPrd%
	AND ZLB_RETILJ = %exp:cpLj%
EndSql

_nRet := (_cAlias)->ZLB_VLRFX

(_cAlias)->(DbCloseArea())

RestArea(_aArea)

Return _nRet

/*
===============================================================================================================================
Programa----------: RGLT019O
Autor-------------: Abrahao P. Santos
Data da Criacao---: 24/01/2009
Descrição---------: Retorna volume por dia/produtor
Parametros--------: cpCodPrd - código do produtor
					cpdia - data da doleta
					cpLj - loja do produtor
					clinrota - linha da coleta
Retorno-----------: nret - volume coletado
===============================================================================================================================
*/
Static Function RGLT019O(cpCodPrd,cpLj,cpDia,cLinRota)

Local _cAlias	:= GetNextAlias()
Local _aArea	:= GetArea()
Local _nRet		:=0

// Obtem Volume do dia 
BeginSql alias _cAlias
	SELECT SUM(ZLD_QTDBOM) VOLUME
	FROM %table:ZLD% ZLD
	WHERE D_E_L_E_T_ = ' '
	AND ZLD_FILIAL = %xFilial:ZLD%
	AND ZLD_RETIRO = %exp:cpCodPrd%
	AND ZLD_RETILJ = %exp:cpLj%
	AND ZLD_DTCOLE = %exp:cpDia%
	AND ZLD_LINROT = %exp:cLinRota%
EndSql

_nRet:=(_cAlias)->VOLUME

(_cAlias)->(DbCloseArea())

RestArea(_aArea)

Return _nRet

/*
===============================================================================================================================
Programa----------: RGLT019O
Autor-------------: Abrahao P. Santos
Data da Criacao---: 24/01/2009
Descrição---------: Retorna data do complemento
Parametros--------: _cSeekComp - código do complemento
Retorno-----------: _cMesAno - data do complemento
===============================================================================================================================
*/
Static Function RGLT019D(_cSeekComp)      

Local _cAlias := GetNextAlias()
Local _cMesAno:= "" 
Local _cFiltro:= "%" 

//===============================================================
// Complemento de pagamento gerado para ser pago no proximo Mix. 
//===============================================================
If 'MGLT026' $ _cSeekComp   

	_cFiltro += " AND ZZD.ZZD_CODIGO = '" + SubStr(_cSeekComp,1,6)+ "'"
	_cFiltro += "%"
     
	BeginSql alias _cAlias
		SELECT SUBSTR(ZLE.ZLE_DTINI,1,6) anoMes
		FROM %table:ZZD% ZZD, %table:ZLE% ZLE 		      
		WHERE ZZD.D_E_L_E_T_ = ' '
		AND ZLE.D_E_L_E_T_ = ' '
		AND ZLE.ZLE_COD = ZZD.ZZD_MIXORI
		%exp:_cFiltro%
	EndSql  
	_cMesAno:= SubStr((_cAlias)->anoMes,5,2) + '/' + SubStr((_cAlias)->anoMes,1,4) 

//==============================================================
// Complemento de pagamento gerado para ser pagao no mix atual  
// fechamento gerar financeiro.                                 
//==============================================================
ElseIf 'MGLT027' $ _cSeekComp
	
	_cFiltro += " AND ZZE.ZZE_CODIGO = '" + SubStr(_cSeekComp,1,9)+ "'"
	_cFiltro += "%"
	
	BeginSql alias _cAlias 
		SELECT SUBSTR(ZLE.ZLE_DTINI,1,6) anoMes
		FROM %table:ZZE% ZZE, %table:ZLE% ZLE
		WHERE ZZE.D_E_L_E_T_ = ' '
		AND ZLE.D_E_L_E_T_ = ' '
		AND ZLE.ZLE_COD = ZZE.ZZE_MIXORI
		%exp:_cFiltro%
	EndSql
	_cMesAno:= SubStr((_cAlias)->anoMes,5,2) + '/' + SubStr((_cAlias)->anoMes,1,4) 

EndIf     
(_cAlias)->(dbCloseArea())   

Return _cMesAno

/*
===============================================================================================================================
Programa----------: ImpCab()
Autor-------------: Abrahao P. Santos
Data da Criacao---: 24/01/2009
Descrição---------: Faz a impressão do cabeçalho do relatório
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ImpCab()

//===================================================================
// Início Cabecalho
//===================================================================
nL := 50
oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0))
oPrint:SayBitmap(nL+20,100,cRaizServer + "system/lgrl01.bmp",250,100)
nL += 10
oPrint:Say(nL,2000,"Emissão:"+dtoc(DDataBase),oFontNormal)
nL += 50

If MV_PAR09 != 2 //Default ou por produtor
	oPrint:Say(nL,1000,"Demonstrativo do Produtor",oFontTitulo)
Else
	oPrint:Say(nL,1000,"Demonstrativo do Leite",oFontTitulo)
EndIf
oPrint:Say(nL,2000,"Paginas: 1/1 ",oFontNormal)
nL += 50
oPrint:Say(nL,2000,"Hora:"+time(),oFontNormal)
nL += 50
oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
nL += 10
//===================================================================
// Fim Cabecalho
//===================================================================

//===================================================================
// Início dos dados da Empresa
//===================================================================
oPrint:Say(nL,nPos1,alltrim(SM0->M0_NOME)+"-"+alltrim(SM0->M0_FILIAL)+"-"+SM0->M0_NOMECOM,oFontRotulo)
oPrint:Say(nL,nPos3,"CNPJ:"+SM0->M0_CGC,oFontRotulo)
nL += 50
oPrint:Say(nL,nPos1,ALLTRIM(SM0->M0_ENDENT)+"-"+ALLTRIM(SM0->M0_CIDENT)+"-"+ALLTRIM(SM0->M0_ESTENT),oFontRotulo)
nL += 50
oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0))
nL += 10
//===================================================================
// Fim dos dados da Empresa
//===================================================================
Return

/*
===============================================================================================================================
Programa--------: impTexto
Autor-----------: Fabiano Dias
Data da Criacao-: 05/09/2011
Descrição-------: Funçãoo para realizar a formataçãoo, ou seja, justificar o texto para que o mesmo fique melhor disposto no
				  corpo da página.
Parametros------: _cTexto -> Texto a ser formatado de forma justificada
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function impTexto(_cTexto)

Local _aTexto   := Separa(_cTexto," ",.F.)//Quebro o texto em palavras
Local _nNumCarac:= 131 //Numero maximo de caracteres por linha

Local _cLinImpr := "" //Texto de impressao inicial do array
Local _nPosInic := 1 //Posicao inicial do array que comecou uma linha     
Local _nNumEspac:= 0 //Numero de espacos vazios necessario para justificar o texto
Local _nNumPalav:= 0 

Local _lEntrou  := .F.    
Local _nVlrDiv  := 0
Local _nEspacame:= 0      

Local _nEspcAdic:= 0                
Local _nVlrEspac:= 0
Local _nK		:= 0
Local _nX		:= 0

//Para que todo inicio de nova linha seja impresa como um paragrafo
_aTexto[1]:= "       "  + _aTexto[1]                           

//Percorre todas as palavras quebradas por espaco do texto passado como parametro
For _nX:=1 to Len(_aTexto)

	_lEntrou  := .F. 
	_nNumPalav++                     	  	                     	

	//Verifica se eh a primeira palavra a ser inserida
	If Len(_cLinImpr) == 0
		_cLinImpr := _aTexto[_nX]
 	Else				
	  	If Len(_cLinImpr + " " + _aTexto[_nX]) <= _nNumCarac
			_cLinImpr += " " + _aTexto[_nX]
		ElseIf Len(_cLinImpr) < _nNumCarac 
			//Numero de espacos em branco a complementar					                                                    					
			_nNumEspac:= _nNumCarac - Len(_cLinImpr) 	
			_cLinImpr := ""					 					 					                  					
					
			//Se numero de caracteres for possivel de se distribuir os espacos em branco entre os numero de palavras
			If _nNumEspac < _nNumPalav - 2												
				For _nK:=_nPosInic to _nX-1  
					If Len(_cLinImpr) == 0
						_cLinImpr := _aTexto[_nK]
					Else
						If _nNumEspac > 0   
							_cLinImpr += "  " + _aTexto[_nK]
							_nNumEspac-= 1
						Else
							_cLinImpr += " " +_aTexto[_nK]
						EndIf   
					EndIf					                                						   							
				Next _nK
			                    			                
			//==================================================================
			//Caso o numero de espacos em branco a complementar a linha atual
			//seja maior que o numero de palavras da linha atual
			//==================================================================
			Else          			                	               
				_nEspcAdic:= 0
			    _nNumPalav:= _nNumPalav - 2//Numero de palavras a serem consideradas para insercao dos espacos em branco			                		
			    _nVlrDiv  := Mod(_nNumEspac,_nNumPalav)//Divisao para constatar se o numero de espacos em branco dividido pelo numero de palavras eh multiplo									    
				_nEspacame:= Int(_nNumEspac / _nNumPalav)
				
				//Contabiliza o numero de caracteres restantes entre o multiplo da divisao para ser valores adicionais
				If _nVlrDiv != 0 
					_nEspcAdic:= _nNumEspac - (_nNumPalav * _nEspacame)
				EndIf 
									    
				For _nK:=_nPosInic to _nX-1  
					If Len(_cLinImpr) == 0
						_cLinImpr := _aTexto[_nK]
					Else			  
						If _nEspcAdic > 0
							_nEspcAdic-- 																			
							_nVlrEspac:= _nEspacame + 2
						Else
							_nVlrEspac:= _nEspacame + 1
						EndIf
						_cLinImpr += Space(_nVlrEspac) + _aTexto[_nK]
					EndIf
				Next _nK
		  	EndIf    	                 	                	                	                

		    _nPosInic:= _nX
            //Para que a palavra que nao foi impressa neste loop seja impressa na proxima execucao
            _nX:= _nX-1
            _lEntrou:= .T.     
		EndIf 	
	EndIf         		

	//Imprime de acordo com o numero maximo de caracteres montados a linha formatada anteriormente
	If Len(_cLinImpr) == _nNumCarac
	  
		oPrint:Say (nL + 10,nPos1,_cLinImpr,oFontRotulo) 
		nL+=50
		
		_cLinImpr:= ""     
		_nNumPalav:= 0
		            
		If !_lEntrou
			_nPosInic:= _nX + 1
		EndIf
	
	EndIf

Next _nX

//Imprime a ultima parte da mensagem que eh menor do que o numero de caracteres estipulado por linha
If Len(_cLinImpr) < _nNumCarac 
	oPrint:Say (nL + 10,nPos1,_cLinImpr,oFontRotulo)
	nL+=50
EndIf

Return
