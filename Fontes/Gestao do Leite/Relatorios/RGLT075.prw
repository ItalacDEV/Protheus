/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PARMTYPE.CH" 

/*
===============================================================================================================================
Programa----------: RGLT075 (Vers�o do fonte RGLT019)
Reescrito/Alterado: Julio de Paula Paz
Data da Criacao---: 23/04/2024
Descri��o---------: Demonstrativo do Produtor - Gest�o do Leite
                    Este fonte � uma vers�o do fonte RGLT019. Reescrito com as novas ferramentas de gera��o de relat�rio 
					da Totvs. Para possibilitar a gera��o autom�tica em PDF, para ser utilizado nas integra��es webservice:
				    Protheus x Cia do leite
                    Chamado: 46864.
                    Ap�s a gera��o do arquivo PDF. O arquivo ser� Criptografado em ENCODE64 e enviado via Webservice.
Parametros--------: _lSchedule = .T. = Rotina rodando em modo autom�tico/Scheduller. .F. = Rotina rodando em modo manual/menu.
                    _cGrupoMix = C�digo do Mix do leite.
					_cProdutor = C�digo do Produtor
					_cLojaProd = Loja do Produtor.
					_cFilProd  = Filial do Produtor
					_dEmisNf   = Data de emiss�o da nota
					_cDirDest  = Diret�rio de Grava��o do PDF
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT075(_lSchedule,_cGrupoMix,_cProdutor,_cLojaProd, _cFilProd,_dEmisNf,_cDirDest,_cNomeArq)

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

Private cPerg	  := "RGLT075"
Private cpFilProd := "  "
//Private _cDirDest := ""
Private _cLinhaRot := ""
Private _cSetor    := ""

Begin Sequence 

   If ! File("\temp\italapp\")
      MakeDir("\temp\italapp\")
   EndIf 
   
   If Empty(_lSchedule)
      _lSchedule := .F. 
   EndIf

   If _lSchedule
      Pergunte( cPerg , .F. )

      mv_par01 := U_RGLT075M(_dEmisNf)
      
      _cLinhaRot := Posicione("SA2",1,xFilial("SA2")+_cProdutor+_cLojaProd,"A2_L_LI_RO") 
      _cSetor    := Posicione("ZL3",1,_cFilProd +_cLinhaRot,"ZL3_SETOR") 
      mv_par02 := _cSetor
	  mv_par03 := _cProdutor  // P87493     // Produtor de 
      mv_par04 := _cLojaProd  // 0001       // Loja Produtor
      mv_par05 := _cProdutor  // P87493     // Produtor Ate
      mv_par06 := _cLojaProd  // 0001       // Loja Produtor
      mv_par07 := Space(6)    // Linha de
      mv_par08 := "ZZZZZZ"    // linha ate
      mv_par09 := 1           // Tipo Demonstrativo Produtor
      mv_par10 := 2           // N�o imprime o informe de qualidade
	  mv_par11 := "\temp\italapp\"
   Else 
      If ! Pergunte( cPerg , .T. )
	     Break 
	  EndIf 
  
      If Empty(mv_par11)
         mv_par11 := GetTempPath()
      EndIf
   EndIf     

   _cDirDest := mv_par11

   //================================================================================
   // Obtem parametros
   //================================================================================
   If Empty(_cFilProd)
      _cFilProd := XFILIAL("ZLF")
   EndIf 

   cpMix	:= mv_par01
   cpSetor	:= mv_par02 // Space(6) //mv_par02  
   cpPrdIni	:= mv_par03
   cpLjIni	:= mv_par04
   cpPrdFim	:= mv_par05
   cpLjFim	:= mv_par06
   cpLinIni	:= mv_par07
   cpLinFim	:= mv_par08
   dpDtIni	:= POSICIONE("ZLE",1,xFilial("ZLE")+cpMix,"ZLE_DTINI")
   dpDtFim	:= POSICIONE("ZLE",1,xFilial("ZLE")+cpMix,"ZLE_DTFIM")
   cpFilProd := _cFilProd

   If _lSchedule
      RGLT075RUN(_lSchedule, _cDirDest,_cNomeArq)
   Else
      Processa({|| RGLT075RUN(_lSchedule, _cDirDest,_cNomeArq) })
   EndIf 

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: RGLT075RUN
Autor-------------: Julio de Paula PAz
Data da Criacao---: 26/04/2024
Descri��o---------: Demonstrativo do Produtor - Gest�o do Leite
                    Vers�o do fonte RGLT019 ajustado para funcionar com as novas ferramentas Totvs para gera��o de relat�rio.
Parametros--------: _lSchedule = .T. = Rotina rodada via Scheduller
                                 .F. = Rotina rodada manualmente
					_cDirDest  = Diret�rio de Destino do PDF
					_cNomeArq = Nome do arquivo PDF
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT075RUN(_lSchedule,_cDirDest,_cNomeArq)

Local nCount		:= 0

Local nPos4		    := 500  
Local nTab01		:= 15   
Local nTab02		:= 200  
Local nTab03		:= 300  
Local nTab04		:= 400  
Local nTab05		:= 500  
Local nTab11		:= 15   
Local nTab12		:= 100  
Local nTab13		:= 200  
Local nTab14		:= 300  
Local nTab15		:= 400  
Local nTab16		:= 500  

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
Local nQtdReg       := 0
Local _aDevice      := {}
Local _cDir         := "\temp\italapp\"

Private cFilePrint 

Private nL			:= 0
Private nPos1		:= 15  
Private nPos2		:= 65  
Private nPos3		:= 400 
oFont1 := TFont():New( 'Courier New', , -18, .T.)
Private oFontTitulo	:= TFont():New("Arial",09,10,.T.,.T.,5,.T.,5,.T.,.F.) // TFont():New("Arial", ,10,.T.) 
Private oFontRotulo	:= TFont():New("Arial",09,09,.T.,.T.,5,.T.,5,.T.,.F.) // TFont():New("Arial", ,09,.T.) 
Private oFontNormal	:= TFont():New("Arial",09,08,.T.,.T.,5,.T.,5,.T.,.F.) // TFont():New("Arial", ,08,.T.)  
Private cRaizServer	:= If(issrvunix(), "/", "\")
Private _nBase		:= 0 //variv�vel declarada como private para poder ser lida por macroexecu��o (ZL8_FORMUL)

Begin Sequence 

   If ! Empty(_cDirDest)
      _cDir := _cDirDest
   EndIf 

   OpenSm0(cEmpAnt, .F.)// Cadatro de Filial
   SM0->(DbSeek(cEmpAnt + cFilAnt))
 
   _aDevice := {}
   Aadd(_aDevice,"DISCO") // 1
   Aadd(_aDevice,"SPOOL") // 2
   Aadd(_aDevice,"EMAIL") // 3
   Aadd(_aDevice,"EXCEL") // 4
   Aadd(_aDevice,"HTML" ) // 5
   Aadd(_aDevice,"PDF"  ) // 6
   IMP_PDF :=  6  

   If ! Empty(_cNomeArq)  
      cFilePrint := _cNomeArq
   Else 
      cFilePrint := "Demonstrativo_Produtor_" + AllTrim(cpPrdIni) +"_Loja_"+AllTrim(cpLjIni) + "_" + Dtos(MSDate()) + StrTran(Time(),":","") + ".pdf" 
   EndIf 
   
   If File(_cDir+cFilePrint) 
      ferase(_cDir+cFilePrint)
   EndIf 

   nLocal          := 1 // 2 //"LOCAL" //If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
   nOrientation    := 2 //1 // If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
   cDevice     	   := "PDF" // If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
   nPrintType      := aScan(_aDevice,{|x| x == cDevice })
   lAdjustToLegacy := .F.

   oPrint := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, _cDir /*cPathInServer*/, .T. )

   oPrint:SetViewPDF(.F.) // ORIGINAL     //oPrint:SetViewPDF(.t.) 
   oPrint:lInJob := .T.

   oPrint:SetResolution(78) //Tamanho estipulado para a Danfe
   oPrint:SetPortrait()
   oPrint:SetPaperSize(DMPAPER_A4) 
   oPrint:SetMargin(10,10,10,10) 
   oPrint:lServer := .T. 
   // ----------------------------------------------
   // Define saida de impress�o
   // ----------------------------------------------
	
   oPrint:nDevice := IMP_PDF 
   // ----------------------------------------------
   // Define para salvar o PDF
   // ----------------------------------------------
   oPrint:cPathPDF := _cDir 

   //Verifico qual evento deve ser usado na exce��o de Jaru
   If cFilAnt == "10"
	  _cBonif:= "000095"
   ElseIf cFilAnt == "11"
	  _cBonif:= "000080"
   EndIf
   
//================================================================
   cWhere01 := "% AND ZLF_FILIAL = '" + cpFilProd + "' "
   cWhere01 += "  AND ZLF_CODZLE = '" + cpMix     + "' "
   
   If ! Empty(cpSetor)
      cWhere01 += "  AND ZLF_SETOR = '" + cpSetor + "' "
   EndIf 

   If ! Empty(cpLinIni)
      cWhere01 += "  AND ZLF_LINROT >= '" + cpLinIni + "' "
   EndIf 
 
   If ! Empty(cpLinFim)
      cWhere01 += "  AND ZLF_LINROT <= '" + cpLinFim + "' "
   EndIf 

   If ! Empty(cpPrdIni) .And. Empty(cpLjIni)
      cWhere01 += "  AND ZLF_RETIRO >= '" + cpPrdIni + "' "  
   EndIf 

   If ! Empty(cpPrdIni) .And. ! Empty(cpLjIni)
      cWhere01 += "  AND ZLF_RETIRO >= '" + cpPrdIni + "' AND ZLF_RETILJ  >= '" + cpLjIni + "' "
   EndIf 

   If ! Empty(cpPrdFim) .And. Empty(cpLjFim)
      cWhere01 += "  AND ZLF_RETIRO <= '" + cpPrdFim + "' "  
   EndIf 

   If ! Empty(cpPrdFim) .And. ! Empty(cpLjFim)
      cWhere01 += "  AND ZLF_RETIRO <= '" + cpPrdFim + "' AND ZLF_RETILJ  <= '" + cpLjFim + "' "
   EndIf 

   cWhere01 += " %"

    // Obtem dados de impressao
    
   BeginSql alias _cAliasZLF
	  SELECT ZLF_SETOR,ZLF_RETIRO,ZLF_RETILJ,ZLF_LINROT
	  FROM %table:ZLF% ZLF
	  WHERE D_E_L_E_T_ = ' '
	        %exp:cWhere01%
	  GROUP BY ZLF_SETOR,ZLF_RETIRO,ZLF_RETILJ,ZLF_LINROT
	  ORDER BY ZLF_LINROT,ZLF_RETIRO,ZLF_RETILJ
   EndSql


   If ! _lSchedule
      Count to nQtdReg

      ProcRegua(nQtdReg)
   EndIf 

   (_cAliasZLF)->(DbGoTop())
   
   Do While !(_cAliasZLF)->(EOf())
	  nCount++                   

	  cCodLinRota:=(_cAliasZLF)->ZLF_LINROT

      If ! _lSchedule
	     Incproc((_cAliasZLF)->ZLF_RETIRO)
      EndIf 

      oPrint:StartPage()
    
	  ImpCab()
		
	  //===================================================================
	  // In�cio dos dados do Produtor
	  //===================================================================
		
  	  // Posiciona no Produtor
	  DbSelectArea("SA2")
	  SA2->(DbSetOrder(1))
	  SA2->(DbSeek(xFilial("SA2")+(_cAliasZLF)->(ZLF_RETIRO+ZLF_RETILJ)))
	  DbSelectArea("ZL3")
	  ZL3->(DbSetOrder(1))
	  ZL3->(DbSeek(xFilial("ZL3")+(_cAliasZLF)->ZLF_LINROT))
		
	  nL += 10 
	  oPrint:Say(nL,nPos1,"PRODUTOR:",oFontRotulo) 
	  oPrint:Say(nL,nPos2,SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SA2->A2_NOME,oFontNormal) 
	  oPrint:Say(nL,nPos3,"CPF:",oFontRotulo)
	  oPrint:Say(nL,nPos4,SA2->A2_CGC,oFontNormal)

	  nL += 10 
	  oPrint:Say(nL,nPos1,"FAZENDA:",oFontRotulo) 
	  oPrint:Say(nL,nPos2,SA2->A2_L_FAZEN,oFontNormal) 
	  oPrint:Say(nL,nPos3,"INSCRICAO:",oFontRotulo)
	  oPrint:Say(nL,nPos4,SA2->A2_INSCR,oFontNormal)
		
	  nL += 10 
	  oPrint:Say(nL,nPos1,"MUNICIPIO:",oFontRotulo) 
	  oPrint:Say(nL,nPos2,SA2->A2_MUN,oFontNormal) 
	  oPrint:Say(nL,nPos3,"SIGSIF:",oFontRotulo)
	  oPrint:Say(nL,nPos4,SA2->A2_L_SIGSI,oFontNormal)

	  nL += 10 
	  oPrint:Say(nL,nPos1,"LINHA:",oFontRotulo) 
	  oPrint:Say(nL,nPos2,(_cAliasZLF)->ZLF_LINROT+" - "+ZL3->ZL3_DESCRI,oFontNormal) 
	  oPrint:Say(nL,nPos3,"NIRF:",oFontRotulo)
	  oPrint:Say(nL,nPos4,SA2->A2_L_NIRF,oFontNormal)

	  nL += 10 
	  If !Empty(SA2->A2_L_NATRA)
		 oPrint:Say(nL,nPos3,"ATRAVESSADOR:",oFontRotulo)
		 oPrint:Say(nL,nPos4,SA2->A2_L_NATRA,oFontNormal)
	  EndIf
	  oPrint:Say(nL,nPos1,"FRETISTA:",oFontRotulo)

	  SA2->(DbSeek(xFilial("SA2")+ZL3->(ZL3_FRETIS+ZL3_FRETLJ)))
		
	  oPrint:Say(nL,nPos2, ZL3->ZL3_FRETIS +'/'+ ZL3->ZL3_FRETLJ +" - "+ SA2->A2_NOME , oFontNormal ) //Ajuste para considerar a Loja no posicionamento e exibi��o [Chamado-6851]
	  oPrint:Say(nL,nPos3,"",oFontRotulo)
	  oPrint:Say(nL,nPos4,"",oFontNormal)
		
	  SA2->(DbSeek(xFilial("SA2")+(_cAliasZLF)->(ZLF_RETIRO+ZLF_RETILJ)))
	  SA2->(DbSeek(xFilial("SA2")+SA2->(A2_L_TANQ + A2_L_TANLJ)))
	  nL += 10 
	  oPrint:Say(nL,nPos1,"RESP.TANQUE:",oFontRotulo) 
	  oPrint:Say(nL,nPos2,SA2->A2_COD +'/'+ SA2->A2_LOJA +" - "+ SA2->A2_NOME , oFontNormal ) //Ajuste para considerar a Loja no posicionamento e exibi��o [Chamado-6851]
		
	  SA2->(DbSeek(xFilial("SA2")+(_cAliasZLF)->(ZLF_RETIRO+ZLF_RETILJ)))
	  oPrint:Say(nL,nPos3,"CLASS.TANQUE:",oFontRotulo)
	  oPrint:Say(nL,nPos4,_aClass[aScan(_aClass,{|x| x[2] == SA2->A2_L_CLASS})][3],oFontNormal) 

	  nL += 10 
	  oPrint:Say(nL,nPos1,"BANCO:",oFontRotulo) 
	  oPrint:Say(nL,nPos2,SA2->A2_BANCO+" AG:"+SA2->A2_AGENCIA+" CC:"+SA2->A2_NUMCON,oFontNormal) 

	  nL += 10 
	  oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	  //===================================================================
	  // Fim dos dados do Produtor
	  //===================================================================

	  //===================================================================
	  // In�cio dos eventos do Produtor na ZLF
	  //===================================================================
	  If mv_par09 != 2 //Default ou por produtor
	     nL += 10 
		 oPrint:Say(nL,220,"DEMONSTRATIVO DE PAGAMENTO DE LEITE",oFontRotulo)
		 nL += 10 
		 oPrint:Say(nL,220,"PERIODO DE "+dtoc(dpDtIni)+" A "+dtoc(dpDtFim),oFontRotulo) 
		 nL += 10 
		 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
		 nL += 10 
		 oPrint:Say(nL,nTab01,"Eventos       ",oFontRotulo)
		 oPrint:Say(nL,nTab02,"Litros        ",oFontRotulo)
		 oPrint:Say(nL,nTab03,"Vlr Unit.(R$) ",oFontRotulo)
		 oPrint:Say(nL,nTab04,"Ganhos (R$)   ",oFontRotulo)
		 oPrint:Say(nL,nTab05,"Descontos (R$)",oFontRotulo)
		 nL += 10 
		 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 

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
		
		Do While !(_cAliasPRD)->(EOf())
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
			     _cMesAno:= RGLT075D((_cAliasPRD)->SEEKCOMPL) 
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
			  nL += 10 
		   EndIf
		
		   (_cAliasPRD)->(DBSkip())
		
		EndDo
		(_cAliasPRD)->(dbcloseArea())
		oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 

		nL += 10 
		oPrint:Say(nL,nTab01,"TOTAL",oFontRotulo)
		nVolProd:=U_VolLeite(xfilial("ZLF"),dpDtIni,dpDtFim,cpSetor,(_cAliasZLF)->ZLF_LINROT,(_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ)
		oPrint:Say(nL,nTab02,transform(nVolProd,"@E 999,999,999.99"),oFontRotulo)
		If !(cpMix $ "000118/000119" .And. cFilAnt $ "10/11")
		   oPrint:Say(nL,nTab03,transform((nTotCre/nVolProd),"@E 999,999,999.9999"),oFontRotulo)
		EndIf
		oPrint:Say(nL,nTab04,transform(nTotCre,"@E 999,999,999.99"),oFontRotulo)
		oPrint:Say(nL,nTab05,transform(nTotDeb,"@E 999,999,999.99"),oFontRotulo)
		nL += 10 
		oPrint:Say(nL,nTab04,"TOTAL A RECEBER-->",oFontRotulo)
		oPrint:Say(nL,nTab05,transform(nTotCre-nTotDeb,"@E 999,999,999.99"),oFontRotulo)
		
		nTotDeb:=0
		nTotCre:=0
	 EndIf
	 //===================================================================
	 // Fim dos eventos do Produtor na ZLF
	 //===================================================================

	 //===================================================================
	 // In�cio da recep��o di�ria do Leite
	 //===================================================================
	 nL += 20 
	 oPrint:Say(nL,220,"VOLUME DE LEITE PRODUZIDO",oFontRotulo)  
	 nL += 10 
	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	 nL += 10 

	 // Primeira Quinzena
	 oPrint:Say(nL,nPos1,"Dia",oFontRotulo)		
	 For _nX:=1 To 15
	     oPrint:Say(nL,30+(_nX*34),Space(11-Len(AllTrim(Str(_nX))))+AllTrim(Str(_nX)),oFontRotulo) 
	 Next _nX
	 nL += 10 
	 oPrint:Say(nL,nPos1,"Volume",oFontRotulo)
	 For _nX:=1 To 15
	     nAux:=RGLT075O((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,Substr(DToS(dpDtIni),1,6)+StrZero(_nX,2),(_cAliasZLF)->ZLF_LINROT)
		 oPrint:Say(nL,30+(_nX*34),Transform(nAux,"@E 999,999,999"),oFontNormal) 
		 nTotVol+=nAux
	 Next _nX

	 nL += 10 
	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	 nL += 10 

     // Segunda  Quinzena
	 oPrint:Say(nL,nPos1,"Dia",oFontRotulo)	
	 nUltDia:=val(substr(dtos(dpDtFim),7,2)) // ultimo dia do mes
	 For _nX:=16 To nUltDia
	     oPrint:Say(nL,30+((_nX-15)*34),Space(11-Len(AllTrim(str(_nX))))+AllTrim(str(_nX)),oFontRotulo) 
	 Next _nX

	 nL += 10 
	 oPrint:Say(nL,nPos1,"Volume",oFontRotulo)
	 For _nX:=16 To nUltDia
	     nAux:=RGLT075O((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,Substr(DToS(dpDtIni),1,6)+StrZero(_nX,2),(_cAliasZLF)->ZLF_LINROT)
		 oPrint:Say(nL,30+((_nX-15)*34),Transform(nAux,"@E 999,999,999"),oFontNormal) 
		 nTotVol+=nAux
     Next _nX

	 nL += 10 
	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	  
	 nL += 10 
	 oPrint:Say(nL,nPos1,"Total:",oFontRotulo)		
	 oPrint:Say(nL,nPos2,transform(nTotVol,"@E 999,999,999")+" Litros",oFontNormal)		
	 oPrint:Say(nL,nPos3,"Media Di�ria:",oFontRotulo)		
	 oPrint:Say(nL,nPos4,transform(nTotVol/nUltDia,"@E 999,999,999")+" Litros",oFontNormal)		

	 nTotVol:=0
	 //===================================================================
	 // Fim da recep��o di�ria do Leite
	 //===================================================================
	
	 //===================================================================
	 // In�cio do pagamento por qualidade
	 //===================================================================
	 // Obtem Data das ultimas 3 analises
	 dQual1:= ""  
	 dQual2:= ""
	 dQual3:= ""
		
	 aAux:= RGLT075N((_cAliasZLF)->ZLF_RETIRO,dpDtFim,(_cAliasZLF)->ZLF_RETILJ) 
	
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
		
	 nL += 20 
	 oPrint:Say(nL,900,"TABELA DE ANALISES",oFontRotulo)
	 nL += 10 
	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	 nL += 10 
	 oPrint:Say(nL,nTab11,"An�lise",oFontRotulo)		
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
	 nL += 10 
	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	 nL += 10 
		
	 DbSelectArea("ZL9")
	 ZL9->(DbSetOrder(1))
	 ZL9->(DbSeek(xFilial("ZL9")))
	 Do While !ZL9->(EOf()) .and. xFilial("ZL9")==ZL9->ZL9_FILIAL
	    If ZL9->ZL9_TIPO = "Q"   
		   oPrint:Say(nL,nTab11,ZL9->ZL9_DESCRI,oFontRotulo)		
		   oPrint:Say(nL,nTab12,ZL9->ZL9_REFERE,oFontRotulo)		

		   // Verifica tipo de media a ser calculada: Aritmetica ou Geometrica
		   IIf(ZL9->ZL9_MEDIA=="G",nTotQual:=1,nTotQual:=0)				                     
		   // Obtem valor da primeira Data
		   If !Empty(dQual1)
			  nAux:=RGLT075V((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,dQual1,ZL9->ZL9_COD)
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
			  nAux:=RGLT075V((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,dQual2,ZL9->ZL9_COD)
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
			  nAux:=RGLT075V((_cAliasZLF)->ZLF_RETIRO,(_cAliasZLF)->ZLF_RETILJ,dQual3,ZL9->ZL9_COD)
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
				
		   nL += 10 
		   nTotQual:=0
		EndIf
		ZL9->(DbSkip())
	 EndDo

	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	 nL += 20 
	 //===================================================================
	 // Fim do pagamento por qualidade
	 //===================================================================
	
	 //===================================================================
	 // In�cio dos d�bitos futuros
	 //===================================================================
	 _cAliasSE2 := GetNextAlias()
	   
	 BeginSql alias _cAliasSE2
		 SELECT ZL8_COD, ZL8_DESCRI, SUM(E2_SALDO + E2_SDACRES) AS SALDO
		 FROM %table:SE2% SE2, %table:ZL8% ZL8
		 WHERE SE2.D_E_L_E_T_ = ' ' 
		    AND ZL8.D_E_L_E_T_ = ' '
		    AND E2_PREFIXO = ZL8_PREFIX 
		    AND E2_FILIAL = ZL8_FILIAL
		    AND E2_TIPO = 'NDF'
		    AND E2_SALDO   > 0  
		    AND E2_FORNECE = %exp:(_cAliasZLF)->ZLF_RETIRO%
		    AND E2_LOJA    = %exp:(_cAliasZLF)->ZLF_RETILJ%
		 GROUP BY ZL8_COD,ZL8_DESCRI
	 EndSql
        
	 Count to nReg
	 (_cAliasSE2)->(DbGoTop())
	 If nReg > 0
	    oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
		nL += 10 
		oPrint:Say(nL,900,"DEBITOS FUTUROS",oFontRotulo)
	 	nL += 10 
		nTotPend:=0
		oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	    nL += 10 
     EndIf               
	                             
	 Do While (_cAliasSE2)->(!EOF())
		oPrint:Say(nL,nPos1,(_cAliasSE2)->ZL8_COD,oFontRotulo)
		oPrint:Say(nL,nPos2,(_cAliasSE2)->ZL8_DESCRI,oFontRotulo)
		oPrint:Say(nL,nPos3,transform((_cAliasSE2)->SALDO,"@E 999,999.99"),oFontRotulo) 
		nL += 10 
		
		nTotPend+=(_cAliasSE2)->SALDO
		
		(_cAliasSE2)->(DbSkip())
	 EndDo
	 (_cAliasSE2)->(DbCloseArea())

	 If nReg > 0
	    oPrint:Say(nL,nPos1,"Valor Total Pendente ------>",oFontRotulo)
		oPrint:Say(nL,nPos3,transform(nTotPend,"@E 999,999.99"),oFontRotulo)
	    nL += 10 
	 EndIf
	 //===================================================================
	 // Fim dos d�bitos futuros
	 //===================================================================
		
	 //===================================================================
	 // In�cio do rodap�
	 //===================================================================
	 nL += 10 
	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	 nL += 10 
	 oPrint:Say(nL,220,"I N F O R M A T I V O      A O     P R O D U T O R ",oFontRotulo) 
	 nL += 10 
	 oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) 
	 nL += 10 

	 aMensagem := u_showMemo(POSICIONE("ZLP",2,xFilial("ZLP")+cpMix+"1"+cpSetor,"ZLP_MENSAG"),120)
	 For _nX:=1 To Len(aMensagem)
	     If _nX <= 7 // Max. de Linhas
		    oPrint:Say(nL,nPos1,aMensagem[_nX],oFontNormal)
		    nL += 10 
	     EndIf
	 Next _nX
	 //===================================================================
	 // Fim do rodap�
	 //===================================================================
	
	 oPrint:EndPage()
	  
	 //===================================================================
	 // In�cio do Informativo de Qualidade
	 //===================================================================
	 If _nInfQual > 0 .And. MV_PAR10 == 1

	    oPrint:StartPage()

	    ImpCab()
		 
	    nL += 10 
		oPrint:Say(nL,220,"INFORMATIVO DE QUALIDADE INDIVIDUAL",oFontTitulo)
	    nL += 20 
		oPrint:Say(nL,nPos1,"Prezado (a) "+ AllTrim(SA2->A2_NOME)+",",oFontTitulo)
		nL += 20 
		
		_cMenAux:= "O leite fornecido (a) pela sua propriedade rural a ITALAC se encontra fora dos padr�es definidos pelas Instru��es Normativas 76 e 77 "
		_cMenAux+= "(preconizadas pelo Minist�rio da Agricultura, Pecu�ria e Abastecimento) devido � alta taxa de "

		If _nInfQual == 1
		   _cMenAux += "Contagem de C�lulas Som�ticas - CCS (tamb�m chamado de indicador de mastite)."
		ElseIf _nInfQual == 2
		   _cMenAux += "Contagem Bacteriana Total - CBT (tamb�m chamado de indicador de Higiene)."
		Else
		   _cMenAux += "Contagem Bacteriana Total - CBT (tamb�m chamado de indicador de Higiene) "
		   _cMenAux += "e alta taxa de Contagem de C�lulas Som�ticas (tamb�m chamado de indicador de mastite)."
		EndIf
		 
		impTexto(_cMenAux)
	 	 
		If _nInfQual == 1
		   oPrint:Say(nL,nPos1,"LOGO, SEGUE ABAIXO ALGUMAS INSTRU��ES DE COMO MELHORAR A TAXA DE CCS: ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"1.	DETEC��O DOS CASOS DE MASTITE ATRAV�S DO USO DO TESTE DA CANECA DE FUNDO ESCURO (O LEITE QUE APRESENTAR GRUMOS, O(A) SENHOR(A) ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"2.	USO DO P�S-DIPPING (EXEMPLO: IODO, �CIDO L�CTICO, ENTRE OUTROS) AP�S A ORDENHA: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	Cerca de 50% das Mastites � controlado com o uso di�rio do P�s Dipping ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"3.	AP�S A ORDENHA FORNECER ALIMENTA��O PARA OS ANIMAIS, PARA QUE OS MESMOS N�O DEITEM, POIS O TETO DO ANIMAL SE ENCONTRA ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"ABERTO ",oFontTitulo); nL += 20 
		   oPrint:Say(nL,nPos1,"4.	TRATAMENTO DOS CASOS DE MASTITE � CL�NICA ",oFontTitulo); nL += 20 
		   oPrint:Say(nL,nPos1,"5.	CORRETA SECAGEM DOS ANIMAIS: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	Uso do �antibi�tico vaca-seca� para controle de Mastite no per�odo seco ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	N�o ultrapassar o tempo de 10 meses de Lacta��o ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"6.	CUIDADOS NO PR� - PARTO: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	O local do pr� - parto tem que ser o mais adequado (evitar locais com ac�mulo de �barro�) ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	Se o animal j� come�ou a soltar leite antes da pari��o, o mesmo deve passar pela ordenha para realiza��o do P�s Dipping ",oFontRotulo); nL += 20 
		ElseIf _nInfQual == 2
		   oPrint:Say(nL,nPos1,"LOGO, SEGUE ABAIXO ALGUMAS INSTRU��ES DE COMO MELHORAR A TAXA DE CBT: ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"1.	REALIZA��O DE UMA ORDENHA HIGI�NICA: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	Realizar a desinfec��o dos tetos antes do inicio da ordenha (chamado de Pr�-dipping) ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	Secar os tetos com papel toalha ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"c.	Ap�s o t�rmino da ordenha utilizar o P�s-dipping (exemplo: iodo, �cido l�ctico, entre outros) ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"d.	Utiliza��o do coador/filtro adequado a ordenha ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"e.	Caso use ordenha �balde ao p�, levar o leite para o tanque quando o lat�o atingir metade de sua capacidade ou, o mais r�pido poss�vel ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"2.	HIGIENIZA��O DO EQUIPAMENTO DE ORDENHA: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	Ap�s o t�rmino da ordenha, circular �gua morna no sistema at� a �gua sair completamente limpa ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	Passagem do detergente alcalino clorado, em �gua com temperatura de 70 a 75� C (esta �gua deve circular de 08 a 10 minutos, n�o deixando ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a �gua sair fria (menor que 45� C)) ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"d.	Passagem do detergente �cido, em �gua a temperatura �ambiente� 01 ou mais vezes por semana ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"e.	Realizar a inspe��o da ordenha a cada 07 dias, para verificar se n�o existe o acumulo de res�duo na ordenhadeira (caso exista realizar ",oFontRotulo); nL += 10
		   oPrint:Say(nL,nPos1,"a limpeza manual) ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"3.	HIGIENIZA��O DO TANQUE DE EXPANS�O OU LAT�O: ",oFontTitulo); nL += 10 
	       oPrint:Say(nL,nPos1,"a.	A lavagem dos lat�es e do tanque tem que ser realizada com detergente alcalino clorado, juntamente com uma escova adequada ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	Retirar toda a �gua com detergente ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"c.	Passagem do detergente �cido, em �gua a temperatura �ambiente� 01 vez por semana ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"d.	Verificar a limpeza do tanque, quando ele estiver seco, com o aux�lio de uma lanterna ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"4.	MANUTEN��O DO TERM�METRO DO TANQUE: ",oFontTitulo); nL += 20 
		   oPrint:Say(nL,nPos1,"a.	Verifique junto ao transportador de seu leite, se a temperatura do seu leite analisada pelo term�metro do transportador � igual a temperatura ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"marcada pelo tanque (caso apare�a diferen�a, contate um t�cnico para a realiza��o da manuten��o do seu tanque) ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"b. A temperatura m�xima de estocagem e de coleta do seu leite deve ser de 4� C ou menos ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"A Contagem Bacteriana de seu leite � determinada pela Higiene durante o processo de ordenha e pela refrigera��o r�pida do leite, logo as ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"instru��es acima v�o indicar qual caminho seguir ",oFontRotulo); nL += 10 
		Else
		   oPrint:Say(nL,nPos1,"LOGO, SEGUE ABAIXO ALGUMAS INSTRU��ES DE COMO MELHORAR AS TAXAS DE CBT e CCS: ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"1.	REALIZA��O DE UMA ORDENHA HIGI�NICA: ",oFontTitulo); nL += 20 
		   oPrint:Say(nL,nPos1,"a.	Detec��o dos casos de mastite atrav�s do uso do teste da caneca de fundo escuro (o leite que apresentar grumos, o(a) senhor(a) ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1," deve separar este animal para o final da ordenha e este leite n�o deve ser colocado junto ao leite fornecido para o latic�nio) ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	Ap�s, realizar a desinfec��o dos tetos (chamado de Pr�-dipping) e a secagem com papel toalha ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"c.	Ao t�rmino da ordenha nos animais, utilizar o P�s-dipping (exemplo: iodo, �cido l�ctico, entre outros) ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"d.	Cerca de 50% das Mastites � controlado com o uso di�rio do P�s Dipping ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"e.	Utiliza��o do coador/filtro adequado a ordenha e caso use ordenha �balde ao p�, levar o leite para o tanque quando o lat�o atingir metade ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"de sua capacidade ou, o mais r�pido poss�vel ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"2.	AP�S A ORDENHA FORNECER ALIMENTA��O PARA OS ANIMAIS, PARA QUE OS MESMOS N�O DEITEM, POIS O TETO DO ANIMAL SE ENCONTRA ABERTO ",oFontTitulo); nL += 20 
		   oPrint:Say(nL,nPos1,"3.	TRATAMENTO DOS CASOS DE MASTITE � CL�NICA ",oFontTitulo); nL += 20 
		   oPrint:Say(nL,nPos1,"4.	CORRETA SECAGEM DOS ANIMAIS: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	Uso do �antibi�tico vaca-seca� para controle de Mastite no per�odo seco ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	N�o ultrapassar o tempo de 10 meses de Lacta��o ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"5.	HIGIENIZA��O DO EQUIPAMENTO DE ORDENHA: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	Ap�s o t�rmino da ordenha, circular �gua morna no sistema at� a �gua sair completamente limpa ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	Passagem do detergente alcalino clorado, em �gua com temperatura de 70 a 75� C (esta �gua deve circular de 08 a 10 minutos, n�o deixando ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a �gua sair fria (menor que 45� C)) ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"c.	Passagem do detergente �cido, em �gua a temperatura �ambiente� 01 ou mais vezes por semana ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"d.	Realizar a inspe��o da ordenha a cada 07 dias, para verificar se n�o existe o acumulo de res�duo na ordenhadeira (caso exista realizar ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a limpeza manual) ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"6.	HIGIENIZA��O DO TANQUE DE EXPANS�O OU LAT�O: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	A lavagem dos lat�es e do tanque tem que ser realizada com detergente alcalino, juntamente com uma escova adequada ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b.	Passagem do detergente �cido, em �gua a temperatura �ambiente� 01 ou mais vezes por semana ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"c.	Verificar a limpeza do tanque, quando ele estiver seco, com o aux�lio de uma lanterna ",oFontRotulo); nL += 20 
		   oPrint:Say(nL,nPos1,"7.	MANUTEN��O DO TERM�METRO DO TANQUE: ",oFontTitulo); nL += 10 
		   oPrint:Say(nL,nPos1,"a.	Verifique junto ao transportador de seu leite, se a temperatura do seu leite analisada pelo term�metro do transportador � igual a temperatura ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"marcada pelo tanque (caso apare�a diferen�a, contate um t�cnico para a realiza��o da manuten��o do seu tanque) ",oFontRotulo); nL += 10 
		   oPrint:Say(nL,nPos1,"b. A temperatura m�xima de estocagem e de coleta do seu leite deve ser de 4�C ou menos ",oFontRotulo); nL += 20 
		EndIf 
		
		nL += 20 
		oPrint:Say(nL,nPos1,"Segue abaixo os padr�es das Instru��es Normativas 76 e 77:",oFontRotulo)
		nL += 20 
		oPrint:FillRect({nL,35,nL+1,140},TBrush():New("",0)) 
		nL += 10 
		oPrint:Say(nL,nTab13,"CBT",oFontRotulo)
		oPrint:Say(nL,nTab14,"CCS",oFontRotulo)
		oPrint:Say(nL,nTab15,"GORDURA",oFontRotulo)
		oPrint:Say(nL,nTab16,"PROTEINA",oFontRotulo)
		nL += 10 
		oPrint:FillRect({nL,35,nL+1,140},TBrush():New("",0)) 
		nL += 10 
		oPrint:Say(nL,nTab13,"M�ximo de 300",oFontRotulo)
		oPrint:Say(nL,nTab14,"M�ximo de 500 ",oFontRotulo)
		oPrint:Say(nL,nTab15,"M�nimo de 3,0 %",oFontRotulo)
		oPrint:Say(nL,nTab16,"M�nimo de 2,9%",oFontRotulo)
		nL += 10 
		oPrint:Say(nL,nTab13,"(x 1.000 UFC/ml)",oFontNormal)
		oPrint:Say(nL,nTab14,"(x 1.000 CCS/ml)",oFontNormal)
		nL += 10 
		oPrint:FillRect({nL,35,nL+1,140},TBrush():New("",0)) 
		
		nL += 20 
		oPrint:Say(nL,nPos1,"Qualquer d�vida, estamos � disposi��o para marcarmos visitas t�cnicas na melhoria da qualidade do seu leite.",oFontRotulo)
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

End Sequence 

Return

/*
===============================================================================================================================
Programa----------: RGLT075N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/04/2024
Descri��o---------:Obtem datas das ultimas tres analises
                   Vers�o do fonte RGLT019 ajustado para funcionar com as novas ferramentas Totvs de gera��o de relat�rios.
Parametros--------: cpCodPrd - c�digo do produtor
					dpData - database
					cLojaProd - loja do produtor
Retorno-----------: aret - array com datas das �ltimas an�lises
===============================================================================================================================
*/
Static function RGLT075N(cpCodPrd,dpData,cLojaProd)

Local aArea		:= GetArea()
Local _cAlias	:= GetNextAlias()
Local aRet		:={}
Local nQtd		:=0
Local _nAno		:= Val( SubStr( DtoS( dpData ) , 1 , 4 ) )
Local _nMes		:= Val( SubStr( DtoS( dpData ) , 5 , 2 ) )
Local _sDtInic	:= ""
Local _sDtFinal	:= DtoS(dpData)

Begin Sequence 
   //===================================================================
   // Define os ultimos tres meses a serem considerados para obter      
   // as analises de qualidade, isto de acordo com o mes de fechamento. 
   //===================================================================
   If _nMes - 2 == 0 
	  _sDtInic:= AllTrim(Str(_nAno - 1)) + '1201'
   ElseIf _nMes - 2 == -1 
	  _sDtInic:= AllTrim(Str(_nAno - 1)) + '1101'
   Else   
	  _sDtInic:= AllTrim(Str(_nAno)) + AllTrim(Strzero(_nMes - 2,2)) + '01' 
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

   Do While !(_cALias)->(EOf()) .And. nQtd<=2
	  nQtd++
	  aAdd(aRet,SToD((_cALias)->ZLB_DATA))
	  (_cALias)->(DbSkip())
   EndDo          

   (_cAlias)->(DbCloseArea())

End Sequence  

RestArea(aArea)	

Return aRet

/*
===============================================================================================================================
Programa----------: RGLT075V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/04/2024
Descri��o---------: Obtem valor analises
                    Vers�o do fonte RGLT019 ajustado para funcionar com as novas ferramentas Totvs de gera��o de Relat�rio.
Parametros--------: cpCodPrd - c�digo do produtor
					dpData - data da an�lise
					cLojaProd - loja do produtor
					cpTipoFx - tipo da an�lise
Retorno-----------: nret - valor da an�lise
===============================================================================================================================
*/
Static Function RGLT075V(cpCodPrd,cpLj,dpData,cpTipoFx)

Local _cAlias	:= GetNextAlias()
Local _aArea	:= GetArea()
Local _nRet		:=0

Begin Sequence 

   If Empty(dpData)
	  Break
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

End Sequence 

RestArea(_aArea)

Return _nRet

/*
===============================================================================================================================
Programa----------: RGLT075O
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/04/2024
Descri��o---------: Retorna volume por dia/produtor
                    Vers�o do fonte RGLT019 ajustado para funcionar com as novas ferramentas Totvs de gera��o de relat�rio.
Parametros--------: cpCodPrd - c�digo do produtor
					cpdia - data da doleta
					cpLj - loja do produtor
					clinrota - linha da coleta
Retorno-----------: nret - volume coletado
===============================================================================================================================
*/
Static Function RGLT075O(cpCodPrd,cpLj,cpDia,cLinRota)

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
Programa----------: RGLT075O
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/04/2024
Descri��o---------: Retorna data do complemento
                    Vers�o do fonte RGLT019 ajustado para funcionar com as novas ferramentas Totvs de gera��o de relat�rio.
Parametros--------: _cSeekComp - c�digo do complemento
Retorno-----------: _cMesAno - data do complemento
===============================================================================================================================
*/
Static Function RGLT075D(_cSeekComp)      

Local _cAlias := GetNextAlias()
Local _cMesAno:= "" 
Local _cFiltro:= "%" 

Begin Sequence 
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

End Sequence 

Return _cMesAno

/*
===============================================================================================================================
Programa----------: ImpCab()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/04/2024
Descri��o---------: Faz a impress�o do cabe�alho do relat�rio
                    Vers�o do relat�rio RGLT019 ajustado para funcionar com as novas ferramentas Totvs de gera��o de relat�rio.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ImpCab()

Begin Sequence 

   //===================================================================
   // In�cio Cabecalho
   //===================================================================
   nL := 10 //50
   oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0)) // FillRect({nL,1150,nL+1,50},TBrush():New("",0))
   oPrint:SayBitmap(nL+05,20,cRaizServer + "system/lgrl01.bmp",80,25) // oPrint:SayBitmap(nL+20,100,cRaizServer + "system/lgrl01.bmp",250,100)
   nL += 10
   oPrint:Say(nL,550,"Emiss�o:"+dtoc(DDataBase),oFontNormal) // oPrint:Say(nL,2000,"Emiss�o:"+dtoc(DDataBase),oFontNormal)
   nL += 10 //50

   If MV_PAR09 != 2 //Default ou por produtor
	  oPrint:Say(nL,250,"Demonstrativo do Produtor",oFontTitulo) // oPrint:Say(nL,1000,"Demonstrativo do Produtor",oFontTitulo)
   Else
	  oPrint:Say(nL,250,"Demonstrativo do Leite",oFontTitulo) // oPrint:Say(nL,1000,"Demonstrativo do Leite",oFontTitulo) // 
   EndIf
   oPrint:Say(nL,550,"Paginas: 1/1 ",oFontNormal) // oPrint:Say(nL,2000,"Paginas: 1/1 ",oFontNormal)
   nL += 10 // 50
   oPrint:Say(nL,550,"Hora:"+time(),oFontNormal) // oPrint:Say(nL,2000,"Hora:"+time(),oFontNormal)
   nL += 10 // 50
   oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0))  // oPrint:FillRect({nL,2300,nL+1,100},TBrush():New("",0)) 
   nL += 10
   //===================================================================
   // Fim Cabecalho
   //===================================================================

   //===================================================================
   // In�cio dos dados da Empresa
   //===================================================================
   oPrint:Say(nL,nPos1,alltrim(SM0->M0_NOME)+"-"+alltrim(SM0->M0_FILIAL)+"-"+SM0->M0_NOMECOM,oFontRotulo)
   oPrint:Say(nL,nPos3,"CNPJ:"+SM0->M0_CGC,oFontRotulo)
   nL += 10 // 50
   oPrint:Say(nL,nPos1,ALLTRIM(SM0->M0_ENDENT)+"-"+ALLTRIM(SM0->M0_CIDENT)+"-"+ALLTRIM(SM0->M0_ESTENT),oFontRotulo)
   nL += 05 // 50
   oPrint:FillRect({nL,15,nL+1,630},TBrush():New("",0))
   nL += 10
   //===================================================================
   // Fim dos dados da Empresa
   //===================================================================

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa--------: impTexto
Autor-----------: Julio de Paula Paz
Data da Criacao-: 26/04/2024
Descri��o-------: Fun��oo para realizar a formata��oo, ou seja, justificar o texto para que o mesmo fique melhor disposto no
				  corpo da p�gina.
				  Vers�o do relat�rio RGLT019 ajustado para funcionar com as novas ferramentas Totvs de gera��o de relat�rio.
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

Begin Sequence 
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
		  nL += 10 
		
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
	  nL += 10 
   EndIf

End Sequence 

Return

/*
===============================================================================================================================
Programa----------: RGLT075M()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 24/04/2024
Descri��o---------: Retorna o c�digo do MIX para a data  passada por par�metro.
Parametros--------: _dDataEmis = Data de emiss�o da nota fiscal
Retorno-----------: _cRet = Retorna o c�digo do grupo do Mix.
===============================================================================================================================
*/
User Function RGLT075M(_dDataEmis)

Local _cRet := Space(6)

Begin Sequence 

   _cQry := " SELECT ZLE_COD "
   _cQry += " FROM " + RetSqlName("ZLE") + " ZLE " 
   _cQry += " WHERE ZLE.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZLE_DTINI <= '" + Dtos(_dDataEmis) + "' "
   _cQry += " AND ZLE_DTFIM >= '" + Dtos(_dDataEmis) + "' "
   
   If Select("QRYZLE") > 0
      QRYZLE->(DbCloseArea())
   EndIf

   DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQry ) , "QRYZLE" , .F. , .T. )

   Do While ! QRYZLE->(Eof())
      _cRet := QRYZLE->ZLE_COD

      QRYZLE->(DbSkip())
   EndDo 

End Sequence 

If Select("QRYZLE") > 0
   QRYZLE->(DbCloseArea())
EndIf

Return _cRet
