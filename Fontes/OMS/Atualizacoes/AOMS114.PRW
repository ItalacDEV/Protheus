/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 26/10/2020 | Chamado 34262. Remoção de bugs apontados pelo Totvs CodeAnalysis. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/11/2020 | Chamado 34584. Correcao do LOOP infinito da procura da Loja do SA2. 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 23/02/2021 | Chamado 35512. Ver existência taxa seguro tabela taxas p/transp/filial se não peger do parametro.
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 02/06/2021 | Chamado 30306. Inclusão de botão e rotina para o usuário selecionar quai notas irão gerar o titulo. 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 14/09/2022 | Chamado 41335. Alterar a data de validação do vencimento por DDatabase e não a data do sistema. 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 24/01/2023 | Chamado 42611. Ajustes para tratamento da Loja da Transportadora e gravação do campo NDFSE. 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 22/08/2023 | Chamado 44027. Coorigir a lentidão da rotina Central de Seguros de Frete,na visualização das Nfs.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina
//====================================================================================================
 
#Include "RWMAKE.CH"
#Include "TopConn.ch"
#Include "ap5mail.ch"
#Include "Protheus.ch"

#DEFINE CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: AOMS114  
Autor-------------: Alex Wallauer 
Data da Criacao---: 12/03/2013
===============================================================================================================================
Descrição---------: Central de seguros de frete  - Chamado 29372
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS114() 

Private _oTRBF := nil
Private _aTRBF := {}
Private nQtdTit:= 0
Private nValTit:= 0
Private dDtVenc:= DATE()
PRIVATE _aRecEsto:={}

IF DAY(DATE()) >  23
   dDtVenc:=CTOD("23/"+StrZero( Month(Date())+1 , 2 ) +'/'+ StrZero( Year(Date()) , 4 ))
ELSE
   dDtVenc:=CTOD("23/"+StrZero( Month(Date())   , 2 ) +'/'+ StrZero( Year(Date()) , 4 ))
ENDIF
AOMS114INI()

If Select("TRBF") > 0
	If ValType(_oTRBF) == "O"
	   TRBF->(DbCloseArea())
	    _oTRBF:Delete()
	Else
	   TRBF->(DbCloseArea())
	EndIf
EndIf

If Select("TRBSF2") > 0
	TRBSF2->(DBCLOSEAREA())
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS114INI
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Funcao que controla o processamento 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114INI()
Private _cPerg		  := 'AOMS114'
Private _cMV_ZP1    := "ITAOMS114TR"
Private _nPercSeguro:= U_ITGETMV("IT_PERCSEG",0.13)//Padrão é 0.13% criar o parametro tipo numerico
Private _dDtCorte   := U_ITGETMV("ITNDFDTCOR", CTOD("01/07/2019") )//
Private _cMarca     := GetMark()
PRIVATE _lTemPercDiferente:=.F.
Private _bPergunte := {|| Pergunte( _cPerg , .T. ) }

IF VALTYPE(_nPercSeguro) <> "N"
   _nPercSeguro:=0.13/100
ELSE
   _nPercSeguro:=(_nPercSeguro/100)
ENDIF

DO WHILE .T.
   
   ZP1->(DBSetOrder(2))
   ZP1->(MsSeek( xFilial('ZP1') + cFilant + _cMV_ZP1 ))//TRAVA POR FILIAL
   ZP1->(MsRUnLock())
   ZP1->(MSUNLOCKALL())
   nOpca:=0
   If EVAL(_bPergunte)
      IF !AOM114Trava()
         LOOP
      ENDIF
      _lTemReg:=.F.
	  // Cria o arquivo Temporario para insercao dos dados selecionados.	
	  FWMSGRUN( , {|oProc| _lTemReg:=AOMS114ArQ(oProc) }, "Aguarde!" , 'Lendo Dados das Notas...' )
	  IF _lTemReg 
        //FWMSGRUN( , {|oProc| U_AOMS114 B(oProc) }, "Aguarde!" , 'Gravando Dados das Notas...' )
        
	     nOpca:=AOMS114TRS()
	  ELSE
         U_ITMSG("Não há registros, altere o filtro!","ATENCAO",,3)
	     LOOP
	  ENDIF   
	  
	ENDIF
	IF nOpca <> 3   
	   EXIT
	ENDIF   
ENDDO

ZP1->(DBSETORDER(2))
ZP1->(MSSEEK( xFilial('ZP1') + cFilant + _cMV_ZP1 ))//TRAVA POR FILIAL
ZP1->(MSRUNLOCK())
ZP1->(MSUNLOCKALL())
ZP1->(DBSETORDER(1))

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS114TRS
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Função que monta a tela para processar
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114TRS()

Local oPanel		:= Nil
Local oDlg1			:= Nil
Local nHeight		:= 0
Local nWidth		:= 0
Local aSize			:= {}
Local aBotoes		:= {}
Local aCoors		:= {}
//LOCAL _bVal:={|| IF(dDtVenc >= DATE(),.T.,(U_ITMSG("Data INVALIDA",'Atenção!',"Tente novamente com a data maior ou igual que hoje",3),.F.) ) }
LOCAL _bVal:={|| IF(dDtVenc >= DDATABASE,.T.,(U_ITMSG("Data INVALIDA",'Atenção!',"Tente novamente com a data maior ou igual que hoje",3),.F.) ) }
Private nOpca	 := 2
Private cFiltro	 := "" 
Private oMark	 := Nil
Private oQtda	 := Nil
Private oValor   := Nil
// Botoes da tela.
Aadd( aBotoes , { "" , {|| AOMS114LEG() }   , "" , "Legenda"          } )
Aadd( aBotoes , { "" , {|| AOMS114ALL() }   , "" , "Marca/Desm.Todos"} )
Aadd( aBotoes , { "" , {|| AOMS114C(9)	}	  , "" , "Selecionar Notas"    } )
Aadd( aBotoes , { "" , {|| AOMS114C(4)	}	  , "" , "Visualiza NFs"    } )
Aadd( aBotoes , { "" , {|| AOMS114C(2) 	} , "" , "Pesquisar"		  } )
Aadd( aBotoes , { "" , {|| AOMS114C(5) 	} , "" , "Exporta Excel"    } )
// Faz o calculo automatico de dimensoes de objetos
aSize := MSADVSIZE() 

DO WHILE .T.
 
   nOpca:= 2
   DEFINE MSDIALOG oDlg1 TITLE "CENTRAL DE SEGUROS DE FRETE "+IF(MV_PAR06=1,"[ TITULOS GERADOS ]","[ TITULOS NAO GERADOS ]") From 0,0 To aSize[6],aSize[5] PIXEL

	oPanel:= TPanel():New(30,0,'',oDlg1,, .T., .T.,, ,315,20,.T.,.T. )
	oFont := TFont():New('Times New Roman',,-16,.T.)

	_nCol:=005
	_nSize:=60
	_nPula:= 65
	IF MV_PAR06 = 1//JÁ EMITIDOS                                                                                    //LOOP   ,SAI  
	   @003,_nCol BUTTON "ESTORNA TITULO"   SIZE _nSize, 015 PIXEL OF oPanel ACTION (IF(AOMS114C(8),(IF(AOMS114C(1),nOpca:=1,nOpca:=3),oDlg1:End()),))//SEM PERGUNTE()
	ELSE                                                                                                            //LOOP   ,SAI  
	   @003,_nCol BUTTON "GERA TITULO"      SIZE _nSize, 015 PIXEL OF oPanel ACTION (IF(AOMS114C(6),(IF(AOMS114C(1),nOpca:=1,nOpca:=3),oDlg1:End()),))//SEM PERGUNTE()
	ENDIF   
	_nCol+=_nPula

   IF MV_PAR06 == 2 //Não Emitidos
      @003,_nCol BUTTON "SELECIONAR NOTAS" SIZE _nSize, 015 PIXEL OF oPanel ACTION (AOMS114C(9)) 
      _nCol+=_nPula
   EndIf 

	@003,_nCol BUTTON "VISUALIZA NFS" SIZE _nSize, 015 PIXEL OF oPanel ACTION (AOMS114C(4))
	_nCol+=_nPula

	@003,_nCol BUTTON "PESQUISAR"     SIZE _nSize, 015 PIXEL OF oPanel ACTION (AOMS114C(2))
	_nCol+=_nPula
                                                                                              //LOOP   ,SAI  
    @003,_nCol BUTTON "ATUALIZAR"     SIZE _nSize, 015 PIXEL OF oPanel ACTION ( IF(AOMS114C(3),nOpca:=1,nOpca:=3),oDlg1:End() )//COM PERGUNTE()
	_nCol+=_nPula

	IF MV_PAR06 = 1//JÁ EMITIDOS 
	   @003,_nCol BUTTON "RE-ENVIA E-MAIL" SIZE _nSize, 015 PIXEL OF oPanel ACTION (AOMS114C(7))
	   _nCol+=_nPula
	ELSE                                                                                      
	   //@003,_nCol BUTTON "EXPORTA EXCEL"   SIZE _nSize, 015 PIXEL OF oPanel ACTION (AOMS114C(5))
	   //_nCol+=_nPula
	ENDIF   

	@003,_nCol BUTTON "MARCA/DESM.TODOS" SIZE _nSize, 015 PIXEL OF oPanel ACTION AOMS114ALL()
	_nCol+=_nPula

	TSay():New(05,_nCol,{||'Vencimento:'},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,18)
	_nCol+=_nPula
	_nCol-=25

    @ 05,_nCol MSGET dDtVenc Size 050,10 COLORS CLR_RED,CLR_WHITE Picture "@D" PIXEL OF oPanel FONT oFont  VALID Eval(_bVal)
    _nCol+=(_nPula-9)

	oQtda := TSay():New(05,_nCol,{||'Qtde transp: '+ALLTRIM(TRANSFORM(nQtdTit,"@E 99,999,999,999"))},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)//450
	_nCol+=(_nPula)

	oValor:= TSay():New(05,_nCol,{||'Valor seguro: '+ALLTRIM(TRANSFORM(nValTit,"@E 9999,999,999.99"))},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)//550
	
	If FlatMode()
		aCoors	:= GetScreenRes()
		nHeight	:= aCoors[2]
		nWidth	:= aCoors[1]
	Else
		nHeight	:= 143
		nWidth	:= 315
	Endif

  //TCBrowse():New( [ nRow ], [ nCol ], [ nWidth ], [ nHeight ], [ bLine ], [ aHeaders ], [ aColSizes ], [ oWnd ], [ cField ], [ uValue1 ], [ uValue2 ], [ bChange ], [ bLDblClick ]  , [ bRClick ], [ oFont ], [ oCursor ], [ nClrFore ], [ nClrBack ], [ cMsg ], [ uParam20 ], [ cAlias ], [ lPixel ], [ bWhen ], [ uParam24 ], [ bValid ], [ lHScroll ], [ lVScroll ] )
	oMark := TCBrowse():New(35,  01   , 35+nHeight, 01+nwidth  ,          ,             ,              , oDlg1   ,           ,            ,            ,            ,                 ,            ,          ,            ,             ,             ,         ,    .F.      ,           ,   .T.     ,          ,    .F.      ,           ,             ,              )

	oMark:SetArray(_aTRBF)
	oMark:bHeaderClick := {|| AOMS114ALL()}
	oMark:bLDblClick   := {|| AOMS114INV()}
	
	oMark:AddColumn(TCColumn():New(" "       			      ,{|| LoadBitmap(GetResources(), IF(LEN(_aTRBF)>0,IF(_aTRBF[oMark:nat,01]==_cMarca,"LBOK","LBNO"),"LBNO") ) },,,,,,.T.,.F.,,,,.F., ) )
  	oMark:AddColumn(TCColumn():New(" "       			      ,{|| LoadBitmap(GetResources(), IF(LEN(_aTRBF)>0,U_AOMS1149(_aTRBF[oMark:nat,14]),' '))  },    ,,,,,.T.,.F.,,,,.F., ) )
	oMark:AddColumn(TCColumn():New("Codigo"               ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,03], ' ') },"@!"       			  ,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark:AddColumn(TCColumn():New("Lojas"                ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,04], ' ') },"@!"       			  ,,,"LEFT" ,050,.F.,.F.,,,,,))

	oMark:AddColumn(TCColumn():New("Transportador"		   ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,05], ' ') },"@!"       			  ,,,"LEFT" ,250,.F.,.F.,,,,,))
	oMark:AddColumn(TCColumn():New("Valor Mercadoria"	   ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,08], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
   oMark:AddColumn(TCColumn():New("Frete" 				   ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,11], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
	oMark:AddColumn(TCColumn():New("Valor Bruto" 		   ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,09], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
   IF !_lTemPercDiferente
      oMark:AddColumn(TCColumn():New("% Seguro" 			   ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,12], ' ') },"@E 99,999,999,999.999",,,"RIGHT",050,.F.,.F.,,,,,))
   ENDIF
	oMark:AddColumn(TCColumn():New("Seguro" 			      ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,13], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
	oMark:AddColumn(TCColumn():New("Qtde NFs"    		   ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,10], ' ') },"@E 999,999,999,999"   ,,,"CENTER",050,.F.,.F.,,,,,))
	oMark:AddColumn(TCColumn():New("Chave do Titulo"      ,{|| if(len(_aTRBF)>0,_aTRBF[oMark:nat,14], ' ') },"@!"       			  ,,,"LEFT" ,050,.F.,.F.,,,,,))

	oDlg1:lMaximized:=.T.

   ACTIVATE MSDIALOG oDlg1 ON INIT ( EnchoiceBar(oDlg1,{|| nOpca:= 2,oDlg1:End() },;
                                                       {|| nOpca:= 2,oDlg1:End() },,aBotoes),;
                                     oPanel:Align:=CONTROL_ALIGN_TOP ,;
                                     oMark:Align:=CONTROL_ALIGN_ALLCLIENT ,;
                                     oMark:Refresh())
    IF nOpca = 1
       LOOP
    ELSEIF nOpca = 2  .AND. !U_ITMSG("Confirmar Sair ?",'Atenção!',,3,2,2)
       LOOP
    ENDIF

    EXIT

ENDDO 

Return nOpca

/*
===============================================================================================================================
Programa----------: AOMS114INV
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Rotina de duplo clique na linha do browse
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS114INV()

Local _nlinpos := oMark:nat

TRBF->(Dbgoto(_aTRBF[_nlinpos,15]))

//Duplo clique na marcação
If ALLTRIM(_cMarca)==ALLTRIM(_aTRBF[_nlinpos,01])
   nQtdTit--
   nValTit-= TRBF->SEGURO
   _aTRBF[_nlinpos,01] := "  "
ELSE//IF EMPTY(TRBF->F2_I_NDFSE) 
   nQtdTit++
   nValTit+= TRBF->SEGURO
   _aTRBF[_nlinpos,01] := _cMarca
EndIf

nQtdTit := IIf( nQtdTit < 0 , 0 , nQtdTit )
nValTit := IIf( nValTit < 0 , 0 , nValTit )

TRBF->OK := _aTRBF[_nlinpos,01]

oQtda:Refresh()
oValor:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: AOMS114ALL
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Rotina para inverter a marcacao de todos os registros.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS114ALL()
Local nReg     := _aTRBF[oMark:nAt,15]
Local _nnp     := 1
Local _cMarcALL:= IF(_aTRBF[nReg,1]==_cMarca,SPACE(2),_cMarca)//OU MARCA TODOS OU DESMARCA TODOS

For _nnp := 1 to len(_aTRBF)

	TRBF->(DBGOTO(_aTRBF[_nnp,15]))

	If !EMPTY(_aTRBF[_nnp,1]) .AND.  EMPTY(_cMarcALL)
	
		TRBF->OK       := SPACE(2)                     
		
		_aTRBF[_nnp,01]:= SPACE(2)
		nQtdTit--
		nValTit-= TRBF->SEGURO

	ELSEIF EMPTY(_aTRBF[_nnp,1]) .AND. !EMPTY(_cMarcALL)
	
		TRBF->OK       := _cMarca
		_aTRBF[_nnp][1]:= _cMarca
		nQtdTit++
		nValTit+= TRBF->SEGURO
		
	EndIf
	
	nQtdTit := IIf( nQtdTit < 0 , 0 , nQtdTit )
	nValTit := IIf( nValTit < 0 , 0 , nValTit )
	
Next

TRBF->( DBGoto(nReg) )
oQtda:Refresh()
oValor:Refresh()
oMark:Refresh()
PROCESSMESSAGES()

Return()

/*
===============================================================================================================================
Programa----------: AOMS114Arq
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Rotina para criação do arquivo temporário
===============================================================================================================================
Parametros--------: oProc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114Arq(oProc)
Local aEstru  := {}
Local cFiltro := "" 
Local _cQuery1:= ""
Local _npv    := 0
Local _lTemReg:=.F.
Local _nPerTransp, _nPSeguro

//GARANTE QUE O PERGUNTE ESTA CORRETO
Pergunte( _cPerg , .F. )

//================================================================================
// Armazena no array aEstru a estrutura dos campos da tabela.
//================================================================================
aEstru := {	{ "OK"			 , "C" , 002 , 0 } ,;
            { "COD"	  		 , "C" , LEN(SA2->A2_COD)  , 0 } ,;
            { "A2_LOJA"		 , "C" , LEN(SA2->A2_LOJA) , 0 } ,;
            { "F2_I_NDFSE"  , "C" , LEN(SF2->F2_I_NDFSE),0} ,;                        
	   		{ "TRANSP"	    , "C" , 040 , 0 } ,;
            { "LOJATRANSP"	 , "C" , 100, 0 } ,;
	   		{ "CNPJ"	  	    , "C" , 020 , 0 } ,;
	   		{ "UF"	    	 , "C" , 002 , 0 } ,;
	   		{ "TOTAL"	  	 , "N" , 018 , 2 } ,;
	   		{ "BRUTO"	    , "N" , 018 , 2 } ,;
	   		{ "QTDENF"      , "N" , 018 , 0 } ,;
		   	{ "FRETE"       , "N" , 018 , 2 } ,;
            { "ALIQS"       , "N" , 018 , 6 } ,;
		   	{ "SEGURO"      , "N" , 018 , 4 }  }

//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
If Select("TRBF") > 0
	If ValType(_oTRBF) == "O"
	   TRBF->(DbCloseArea())
	    _oTRBF:Delete()
	Else
	   TRBF->(DbCloseArea())
	EndIf
EndIf

oProc:cCaption := ("Criando arquivo temporário...")
ProcessMessages()
_oTRBF := FWTemporaryTable():New( "TRBF", aEstru )

oProc:cCaption := ("Criando indices do arquivo temporário...")
ProcessMessages()
_oTRBF:AddIndex( "TR", {"TRANSP"} )//NOME
_oTRBF:AddIndex( "CO", {"COD","F2_I_NDFSE"} )

_oTRBF:Create()

oProc:cCaption := ("Lendo dados das notas...")
ProcessMessages()

cFiltro:=AOMS114Filtro(.F.,.F.)

_cQuery1+= " SELECT 	DISTINCT SF2.F2_FILIAL,  SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, "
_cQuery1+= "			SF2.F2_I_CTRA AS TRANSP,  "
_cQuery1+= "         SF2.F2_I_NDFSE,           "
_cQuery1+= "         SF2.F2_VALMERC, "
_cQuery1+= "         SF2.F2_I_FRET , "
_cQuery1+= "         SF2.F2_VALBRUT, " 
//_cQuery1+= "         1 AS QTDENF, " 
_cQuery1+= "         SF2.F2_I_CTRA   AS TRANSPORT,   "            // Transportadora
_cQuery1+= "         SF2.F2_I_LTRA   AS LOJATRANSP, "               // Loja Transportadora
_cQuery1+= "         SA2.A2_NOME, SA2.A2_I_AVERB, SA2.A2_COD ,SA2.A2_LOJA, SA2.A2_EST,SA2.A2_NREDUZ,"
_cQuery1+= "         SF2.R_E_C_N_O_ SF2_REC "
_cQuery1+= "		FROM " + RetSqlName("SF2")+" SF2         "
_cQuery1+= "		JOIN " + RetSqlName("SA2")+" SA2 ON SA2.A2_COD	= SF2.F2_I_CTRA   AND SA2.A2_LOJA    = SF2.F2_I_LTRA "

IF !EMPTY(MV_PAR04)  
   _cQuery1+= "		JOIN " + RetSqlName("SD2")+" SD2 "
   _cQuery1+= "		    ON  SD2.D2_FILIAL  = SF2.F2_FILIAL  "
   _cQuery1+= "		    AND SD2.D2_DOC     = SF2.F2_DOC     " 
   _cQuery1+= "		    AND SD2.D2_SERIE   = SF2.F2_SERIE   "
   _cQuery1+= "		    AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
   _cQuery1+= "		    AND SD2.D2_LOJA    = SF2.F2_LOJA    "
EndIf 

_cQuery1+= "  WHERE     SF2.D_E_L_E_T_ = ' ' "
_cQuery1+= "		AND SA2.D_E_L_E_T_ = ' ' "
_cQuery1+= "		AND SF2.F2_CARGA  <> ' ' "

If MV_PAR06 = 1//JÁ EMITIDOS  
   _cQuery1+= "		AND SF2.F2_I_GERTS <> 'N' " 
EndIf

_cQuery1+= cFiltro
//_cQuery1+= "        GROUP BY       "
//_cQuery1+= "		SF2.F2_FILIAL, "
//_cQuery1+= "		SF2.F2_I_CTRA,    "
//_cQuery1+= "        SF2.F2_I_LTRA, "
//_cQuery1+= "        SF2.F2_I_NDFSE "

_cQuery1+= " ORDER BY SF2.F2_I_NDFSE, SF2.F2_I_CTRA , SF2.F2_I_LTRA"

_cAlias:=GetNextAlias()
MPSysOpenQuery( _cQuery1 , _cAlias ) 

TCSetField( _cAlias, "F2_EMISSAO", "D", 8, 0)

oProc:cCaption := ("Contando os dados lidos...")
ProcessMessages()
DBSELECTAREA(_cAlias)
(_cAlias)->(Dbgotop())
_cTot := 0
COUNT TO _cTot
_cTot:=ALLTRIM(STR(_cTot))
_nTam:=LEN(_cTot)
(_cAlias)->(Dbgotop())

_aTRBF := {}
nQtdTit:= 0
nValTit:= 0
SA2->(DBSETORDER(1)) 

If Select("TRBSF2") > 0
   TRBSF2->(DBCLOSEAREA())
EndIf

TRBF->(DBSETORDER(2)) //"COD","F2_I_NDFSE"

DO While (_cAlias)->(!EOF())

	//Atualiza régua
	_npv++
	oProc:cCaption := ("Processando Dados: "+ STRZERO(_npv,_nTam) +" de "+ _cTot)
	ProcessMessages()

   _nPerTransp := Posicione('ZGX',1,xFilial("ZGX")+(_cAlias)->F2_FILIAL+(_cAlias)->TRANSP+(_cAlias)->A2_LOJA,'ZGX_PERSEG')
   If ! Empty(_nPerTransp)
      IF !_lTemPercDiferente//Se mudou para .T. tem que ficar .T.
         _lTemPercDiferente:=(_nPerTransp<>_nPercSeguro)
      ENDIF
      _nPSeguro := (_nPerTransp/100)
   Else
      _nPSeguro := _nPercSeguro
   EndIf 
 
   //SA2->(Dbseek(xfilial("SA2")+(_cAlias)->TRANSP+TRBF->LOJATRANSP))
   IF !TRBF->(DBSEEK( (_cAlias)->TRANSP+(_cAlias)->F2_I_NDFSE ))//ORDEM 2
       TRBF->(DBAPPEND())
       TRBF->COD		   := (_cAlias)->TRANSP
       TRBF->A2_LOJA    := (_cAlias)->LOJATRANSP//PEGO A PRIMEIRA LOJA QUE ACHAR
       TRBF->LOJATRANSP := (_cAlias)->LOJATRANSP//PEGO A PRIMEIRA LOJA QUE ACHAR
	    TRBF->TRANSP		:= (_cAlias)->A2_NOME
       TRBF->F2_I_NDFSE := (_cAlias)->F2_I_NDFSE
	    TRBF->ALIQS 		:= _nPSeguro * 100              

	    IF EMPTY(TRBF->F2_I_NDFSE) .OR. MV_PAR06 = 1//SIM: JÁ EMITIDOS
	       _cOK:=_cMarca
	    ELSE   
          _cOK:="  "
	    ENDIF   
  	    TRBF->OK:=_cOK
    
       IF !EMPTY(TRBF->OK)//SÓ OS MARCADOS
	       nQtdTit++
	    ENDIF   
        _lTemReg:=.T.

   ELSEIF !(_cAlias)->LOJATRANSP $ TRBF->LOJATRANSP
       TRBF->LOJATRANSP := ALLTRIM(TRBF->LOJATRANSP)+"-"+(_cAlias)->LOJATRANSP//SOMA AS LOJAS DIFERENTES
   ENDIF

   TRBF->TOTAL       += (_cAlias)->F2_VALMERC
	TRBF->FRETE   		+= (_cAlias)->F2_I_FRET
	TRBF->BRUTO   		+= (_cAlias)->F2_VALBRUT
	TRBF->SEGURO		+= _nPSeguro * (_cAlias)->F2_VALBRUT 
	TRBF->QTDENF   	+= 1

   IF !EMPTY(TRBF->OK)//SÓ OS MARCADOS
	   nValTit+= _nPSeguro * (_cAlias)->F2_VALBRUT
	ENDIF   
	
   AOMS114B(oProc,_cAlias)

    (_cAlias)->( DBSkip() )

EndDo

(_cAlias)->( DBCloseArea())

oProc:cCaption := ("Re-Ordenando Dados...")
ProcessMessages()
_aTRBF:={}
TRBF->(DBSETORDER(1))//NOME da transportadora
TRBF->(DbGotop())
DO While TRBF->(!EOF())
    _aItens:={}
	AADD(_aItens,TRBF->OK)                 //01                                    
	AADD(_aItens,"")                       //02 //CAMPO FILLER
	AADD(_aItens,TRBF->COD)                //03                   
	AADD(_aItens,TRBF->LOJATRANSP)		   //04 //LOJAS
	AADD(_aItens,TRBF->TRANSP)             //05 
	AADD(_aItens,"")               		   //06 //CAMPO FILLER                
 	AADD(_aItens,"") 		                  //07 //CAMPO FILLER  
 	AADD(_aItens,TRBF->TOTAL)		         //08
 	AADD(_aItens,TRBF->BRUTO)              //09
 	AADD(_aItens,TRBF->QTDENF)		         //10
 	AADD(_aItens,TRBF->FRETE)              //11    
 	AADD(_aItens,TRBF->ALIQS)              //12  
 	AADD(_aItens,TRBF->SEGURO)             //13     
 	AADD(_aItens,TRBF->F2_I_NDFSE)         //14 //CAMPO FILLER
 	AADD(_aItens,TRBF->(RECNO()) )         //15    
	AADD(_aTRBF,_aItens)
   TRBF->( DBSkip() )
EndDo
TRBF->(DbGotop())

//Se browse já está montando garante que array está atualizado
iF TYPE("oMark") == "O" .and. LEN(_aTRBF) > 0

   oQtda:Refresh()
   oValor:Refresh()
	oMark:setarray(_aTRBF)
	oMark:refresh()
	TRBF->(Dbgoto(_aTRBF[oMark:NAT,15]))

Endif

Return _lTemReg

/*
===============================================================================================================================
Programa----------: AOMS114C()
Autor-------------: Alex Wallauer 
Data da Criacao---: 02/10/2018
===============================================================================================================================
Descrição---------: Chamada de itens do menu
===============================================================================================================================
Parametros--------: _nOpcao - Opção do menu
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114C(_nOpcao)

If LEN(_aTRBF) > 0
   TRBF->(Dbgoto(_aTRBF[oMark:NAT,15]))
ELSEIF _nOpcao <> 3
   U_ITMSG("Não há registros, altere o filtro!")
   RETURN .F.
Endif

Do Case

Case _nOpcao == 1 //Atualizar AÇÕES RELACIONADAS SEM PERGUNTE()

	 RETURN .F. //01/002/2023 agora sai sempre (não recarrega e volta para tela)
     _lTemReg:=.F.
	 FWMSGRUN(,{ |oProc| _lTemReg:=AOMS114Arq(oProc) }, "Aguarde...","Carregando dados...")
	 IF !_lTemReg
	    U_ITMSG("Não há registros, altere o filtro!","ATENCAO",,3)
	 ENDIF   
	 RETURN _lTemReg
	
Case _nOpcao == 2 //Pesquisa

	 AOMS114PSQ()

Case _nOpcao == 3 //Atualizar BOTÃO COM PERGUNTE()

     _lRet:=.F.
	 FWMSGRUN(,{ |oProc| _lRet:=AOMS114Atu(oProc) }, "Aguarde...","Carregando dados...")
	 RETURN _lRet

Case _nOpcao == 4	//Visualiza NFs
     _aRecEsto:={}//ZERA POR SEGURANÇA 
                                 //oProc,_cChave,_nRecTRBF,_lGrava,_lSoma
	 FWMSGRUN(,{ |oProc| AOMS114NF(oProc,""     ,         ,.F.    ,(MV_PAR06=1)) }, "Aguarde...","Carregando dados...")
	
Case _nOpcao == 5	//Exporta Excel

	 FWMSGRUN(,{ |oProc| AOMS114XC(oProc) }, "Aguarde...","Carregando dados...")

Case _nOpcao == 6	//Gera NDF
     
     IF U_ITMSG("Confirmar Geracao de Titulos ?",'Atenção!',,3,2,2)
        _lRet:=.F.
  	    FWMSGRUN(,{ |oProc| _lRet:=AOMS114GE(oProc,.F.,.T.) }, "Aguarde...","Gerando Titulo do Seguro...")//ENVIA E-MAIL SEM TELA
	    RETURN _lRet
     ELSE
	    RETURN .F.
     ENDIF

Case _nOpcao == 7	//ENVIA - EMAIL

	FWMSGRUN(,{ |oProc| _lRet:=AOMS114GE(oProc,.T.,.T.) }, "Aguarde...","Lendo Titulo do Seguro...")//ENVIA E-MAIL COM TELA

Case _nOpcao == 8	//Estorna NDF
     
     IF U_ITMSG("Confirmar Estorno de Titulos ?",'Atenção!',,3,2,2)
        _lRet:=.F.
  	    FWMSGRUN(,{ |oProc| _lRet:=AOMS114GE(oProc,.F.,.F.) }, "Aguarde...","Estorno Titulo do Seguro...")//ENVIA E-MAIL SEM TELA
	    RETURN _lRet
     ELSE
	    RETURN .F.
     ENDIF

Case _nOpcao == 9	// Permite selecionar Notas para geração dos titulos.  
                                 
	 FWMSGRUN(,{ |oProc| U_AOMS114R() }, "Aguarde...","Carregando dados...")


EndCase

If len(_aTRBF) > 0
   TRBF->(Dbgoto(_aTRBF[oMark:NAT,15]))
Endif


Return .T.

/*
===============================================================================================================================
Programa--------: AOMS1149
Autor-----------: Alex Wallauer 
Data da Criacao-: 18/02/2014
===============================================================================================================================
Descrição-------: Retorna cor e legenda
===============================================================================================================================
Parametros------: _cMarca: Marcacao
===============================================================================================================================
Retorno---------: string com cor da legenda da linha posicionada no TRBF
===============================================================================================================================
*/
User Function AOMS1149(_cMarca)

IF EMPTY(_cMarca)
   RETURN "BR_VERDE"
ELSE
   RETURN "BR_AZUL"
ENDIF

Return "BR_VERMELHO"


/*
===============================================================================================================================
Programa----------: AOMS114Atu
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Função que refaz filtro da tela
===============================================================================================================================
Parametros--------: oProc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114Atu(oProc)
LOCAL _lTemReg:=.T.//INICIA COM .T. PQ NA PRIMIERA FEZ QUE ENTRA ESTA COM REGISTROS, e o usuario pode cancelar o pergunte
DO WHILE .T.
   If EVAL(_bPergunte)
      _lTemReg:=.F.
	  // Cria o arquivo Temporario para insercao dos dados selecionados.	
	  FWMSGRUN( , {|oProc| _lTemReg:=AOMS114ArQ(oProc) }, "Aguarde!" , 'Lendo Dados das Notas...' )
	  IF _lTemReg 
	     Return .T.
	  ELSE
         U_ITMSG("Não há registros, altere o filtro!","ATENCAO",,3)
	     LOOP
	  ENDIF	  
	ENDIF  
	EXIT
ENDDO

Return _lTemReg

/*
===============================================================================================================================
Programa----------: AOMS114PSQ
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Funcao para pesquisa no arquivo temporario.
===============================================================================================================================
Parametros--------: oProc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS114PSQ( oProc)

Local oGet1		:= Nil  , nI
Local oDlg		:= Nil
Local cGet1		:= Space(40)
Local cComboBx1	:= ""
Local aComboBx1	:= { "Nome do Transportador","Codigo do Transportador" }
Local nOpca		:= 0

DEFINE MSDIALOG oDlg TITLE "Pesquisar" FROM 178,181 TO 259,697 PIXEL

	@004,003 ComboBox	cComboBx1	Items aComboBx1 Size 213,010 OF oDlg PIXEL
	@020,003 MsGet		oGet1		Var cGet1		Size 212,009 OF oDlg PIXEL COLOR CLR_BLACK Picture "@!"
	
	DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( nOpca := 1 , oDlg:End() ) OF oDlg
	DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( nOpca := 0 , oDlg:End() ) OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1

	For nI := 1 To Len(aComboBx1)
	
		If cComboBx1 == aComboBx1[nI]
		
			DBSelectArea("TRBF")
			TRBF->( DBSETORDER(nI) )
			
			If TRBF->(DbSeek( ALLTRIM(cGet1) ))
			
				_nPos := ascan(_aTRBF,{|x| x[15] == TRBF->(Recno())})
				oMark:GOPOSITION(_nPos)
				oMark:Refresh()

			Else

				U_ITMSG("Transportador não encontrado","Atenção",,1)

			Endif

			
		EndIf
		
	Next nI
	
EndIf

Return()

/*
===============================================================================================================================
Programa--------: AOMS114LEG
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Exibe a tela de detalhes da legenda
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114LEG()
LOCAL _aLegenda:={}
AADD(_aLegenda, { "BR_VERDE"   ,"Transp. / NF sem NDF gerado"} )
AADD(_aLegenda, { "BR_AZUL"    ,"Transp. com NDF gerado"     } )
AADD(_aLegenda, { "BR_VERMELHO","Nota com NDF gerado"        } )

BrwLegenda("Titulo de Seguros","Legenda" ,_aLegenda)										

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS114XC()
Autor-------------: Alex Wallauer 
Data da Criacao---: 11/03/2019
===============================================================================================================================
Descrição---------: Exporta browse para o excel
===============================================================================================================================
Parametros--------: oProc - objeto de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114XC(oProc)

Local _aExcel := {}  , _nnh
Local _aCabec := {}
Local _aItens := {}
Local _cTot:=ALLTRIM(STR(len(_aTRBF)))
Local _nTam:=LEN(_cTot)
Local _npv :=0

aadd(_aCabec,"Codigo")         //03
aadd(_aCabec,"Transportador" ) //05
aadd(_aCabec,"Valor Total")    //08
aadd(_aCabec,"Frete")          //11
aadd(_aCabec,"% Seguro")       //12
aadd(_aCabec,"Seguro")         //13
aadd(_aCabec,"Chave do Titulo")//14

For _nnh := 1 to len(_aTRBF)
 	_npv++ 
	 oProc:cCaption := ("Lendo dados: "+STRZERO(_npv,_nTam) +" de "+ _cTot)
    ProcessMessages()
    _aItens:={}
    AADD(_aItens,_aTRBF[_nnh,03])
    AADD(_aItens,_aTRBF[_nnh,05])
    AADD(_aItens,_aTRBF[_nnh,08])
	AADD(_aItens,_aTRBF[_nnh,11])
	AADD(_aItens,_aTRBF[_nnh,12])
	AADD(_aItens,_aTRBF[_nnh,13])
	AADD(_aItens,_aTRBF[_nnh,14])
    AADD(_aExcel,_aItens)
Next

If len(_aExcel) > 0
	U_ITLISTBOX("Seguro por transportador" , _aCabec , _aExcel , .T. , 1 )
Else
	U_ITMSG("Nenhum registro selecionado!","Atenção",,1)
Endif

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS114 NF()
Autor-------------: Alex Wallauer 
Data da Criacao---: 10/07/2019
===============================================================================================================================
Descrição---------: Visualiza Nfs do transportador. ATENCAO TEM 3 CHAMADAS DESSA FUNÇÃO COM 4 SITUACOES
===============================================================================================================================
Parametros--------: oProc,_cChave,_nRecTRBF,_lGrava,_lSoma,lGera
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114NF(oProc,_cChave,_nRecTRBF,_lGrava,_lSoma,_lGera)
Local _aLinhas := {}
Local _aCab    := {}
Local cFiltro  := ""
Local _npv     := 0
Local _nPerTransp, _nPSeguro
Local _cNfGerTit
Local _nTotNfs
Local _cNFTitSeg 

DEFAULT _cChave:= ""
DEFAULT _lGrava:= .F.
DEFAULT _lSoma := .F.
DEFAULT _lGera := .F.
DEFAULT _nRecTRBF:=_aTRBF[oMark:NAT,15]
TRBF->(DBGOTO(_nRecTRBF))

oProc:cCaption:="Lendo Notas do Transportador: "+LEFT(TRBF->TRANSP,30)
ProcessMessages()

cFiltro:=AOMS114Filtro(.T.,_lGera)

_cQuery1:= " SELECT DISTINCT " 
_cQuery1+= " SF2.F2_FILIAL , "
_cQuery1+= " SF2.F2_DOC    , "
_cQuery1+= " SF2.F2_SERIE  , "
_cQuery1+= " SF2.F2_EMISSAO, "
_cQuery1+= " SA2.A2_I_AVERB, " 
_cQuery1+= " SA2.A2_LOJA   , " 
_cQuery1+= " SA2.A2_EST    , "
_cQuery1+= " SA2.A2_NREDUZ , " 
_cQuery1+= " SF2.F2_I_NDFSE, "
_cQuery1+= " SF2.F2_I_FRET , "
_cQuery1+= " SF2.F2_VALMERC, "
_cQuery1+= " SF2.F2_VALBRUT TOTAL, " 
_cQuery1+= " SF2.R_E_C_N_O_ SF2_REC, "
_cQuery1+= " SF2.F2_I_CTRA AS TRANSPORT, "  // Transportadora
_cQuery1+= " SF2.F2_I_LTRA AS LOJATRANSP, "  // Loja Transportadora 
_cQuery1+= " SF2.F2_I_GERTS "

//_cQuery1+= " MAX(SD2.D2_LOCAL) D2_LOCAL  "//PARA NÃO QUEBRAR AS NOTAS POR LOCAL
//IF !_lGrava
//   _cQuery1+= ",SUM(SD2.D2_TOTAL)	AS TOTAL, "
//   _cQuery1+= " SUM(SD2.D2_I_FRET)	AS FRETE " 
//ENDIF
_cQuery1+= "		FROM " + RetSqlName("SF2")+" SF2 "
_cQuery1+= "		JOIN " + RetSqlName("SA2")+" SA2 ON SA2.A2_COD = SF2.F2_I_CTRA	AND SA2.A2_LOJA	 = SF2.F2_I_LTRA "

IF !EMPTY(MV_PAR04)  
   _cQuery1+= "		JOIN " + RetSqlName("SD2")+" SD2 "
   _cQuery1+= "		    ON  SD2.D2_FILIAL  = SF2.F2_FILIAL  "
   _cQuery1+= "		    AND SD2.D2_DOC     = SF2.F2_DOC     " 
   _cQuery1+= "		    AND SD2.D2_SERIE   = SF2.F2_SERIE   "
   _cQuery1+= "		    AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
   _cQuery1+= "		    AND SD2.D2_LOJA    = SF2.F2_LOJA    "
EndIf 

_cQuery1+= "		WHERE SF2.D_E_L_E_T_ = ' '	"
_cQuery1+= "		  AND SA2.D_E_L_E_T_ = ' '	"
_cQuery1+= "		  AND SF2.F2_CARGA  <> ' '  "
_cQuery1+= cFiltro
IF !_lGrava
   _cQuery1+= "        ORDER BY F2_I_NDFSE,SF2.F2_FILIAL,SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO "
ENDIF

IF SELECT("NFS") > 0
	NFS->(DBCLOSEAREA())
ENDIF

MPSysOpenQuery( _cQuery1 , "NFS" )  

// 27 Caracteres // F2_I_NDFSE 

DBSELECTAREA("NFS")
//NFS->(DBGOTOP())
_cTot := 0
oProc:cCaption:="Contando Notas do Transportador: "+LEFT(TRBF->TRANSP,30)
ProcessMessages()
IF LEN(_aRecEsto) > 0
   _cTot:=LEN(_aRecEsto)
ELSE
   COUNT TO _cTot
ENDIF   

If Select("TRBSF2") > 0 
   TRBSF2->(DbSetOrder(2))
EndIf 

_cTot:=ALLTRIM(STR(_cTot))
_nTam:=LEN(_cTot)+1
NFS->(DBGOTOP())

_aTotais:={0,0,0,0,0,0,0,0,0,0}

_nTotNfs := 0 

DO WHILE NFS->(!EOF())

	_npv++

   IF _lGrava
  	  oProc:cCaption := ("Gravando Nota: "+NFS->F2_DOC+"/"+NFS->F2_SERIE+" - "+ STRZERO(_npv,_nTam) +" de "+ _cTot)
	  ProcessMessages()
      SF2->( DBGOTO(NFS->SF2_REC) )
      IF _lGera .AND. EMPTY(SF2->F2_I_NDFSE)//QUANDO GERA
         _cNfGerTit := ""
         TRBSF2->(MsSeek(StrZero(NFS->SF2_REC,10))) 
         If Empty(TRBSF2->WK_OK) 
            _cNfGerTit := "N"
         Else 
            _cNfGerTit := "S"
            _nTotNfs += 1
         EndIf
         SF2->(RECLOCK("SF2",.F.))
         SF2->F2_I_NDFSE:=_cChave 
         SF2->F2_I_GERTS := _cNfGerTit 
         SF2->(MSUNLOCK())
      ELSEIF !_lGera .AND. !EMPTY(SF2->F2_I_NDFSE)//QUANDO ESTORNA
         If SF2->F2_I_GERTS <> "N"            
            _nTotNfs += 1
         EndIf
         SF2->(RECLOCK("SF2",.F.))
         SF2->F2_I_NDFSE:=""
         SF2->F2_I_GERTS := "N"       
         AADD(_aRecEsto,NFS->SF2_REC)
         SF2->(MSUNLOCK())
      ENDIF   
      NFS->(Dbskip())
      LOOP// SE _lGrava = .T. SÓ VAI ATE AQUI
   ENDIF   

    IF LEN(_aRecEsto) > 0 .AND. ASCAN(_aRecEsto,NFS->SF2_REC) = 0//DA TELA DO RESULTADO DO ESTORNO
       NFS->(Dbskip())
       LOOP
    ENDIF
	oProc:cCaption := ("Lendo Nota: "+NFS->F2_DOC+"/"+NFS->F2_SERIE+" - "+STRZERO(_npv,_nTam) +" de "+ _cTot)
	ProcessMessages()

   _nPerTransp := Posicione('ZGX',1,xFilial("ZGX")+NFS->F2_FILIAL+NFS->TRANSPORT+NFS->LOJATRANSP,'ZGX_PERSEG')
   If ! Empty(_nPerTransp)
      _nPSeguro := _nPerTransp
   Else
      _nPSeguro := _nPercSeguro
   EndIf
 
   _cNFTitSeg := ""
   IF LEN(_aRecEsto) > 0 //DA TELA DO RESULTADO DO ESTORNO NÃO MOSTRA MENSAGEM Nenhuma
      _cNFTitSeg := ""
   ELSEIF _lSoma .OR. MV_PAR06 = 1//JÁ EMITIDOS
      If NFS->F2_I_GERTS <> "N"
         _cNFTitSeg := "NF UTILIZADA CALCULO SEGURO"
      Else 
         _cNFTitSeg := "NF NÃO UTILIZADA CALCULO SEGURO"
      EndIf
   EndIf 
 
   _aItens:={}
   IF _lSoma 
      AADD(_aItens,(NFS->F2_I_GERTS <> "N"))//01
   ELSE
      AADD(_aItens,EMPTY(NFS->F2_I_NDFSE))//01
   ENDIF
	AADD(_aItens,NFS->F2_DOC+"/"+NFS->F2_SERIE)//02 
	AADD(_aItens,DTOC(STOD(NFS->F2_EMISSAO)))//03
	AADD(_aItens,TRANSFORM(NFS->TOTAL* _nPSeguro,"@E 999,999,999.9999") )// _nPercSeguro,"@E 999,999,999.9999") )//04
  	AADD(_aItens,TRANSFORM(NFS->TOTAL             ,"@E 999,999,999.99") )//06
	AADD(_aItens,TRANSFORM(NFS->F2_VALMERC        ,"@E 999,999,999.99") )//05
	AADD(_aItens,TRANSFORM(NFS->F2_I_FRET         ,"@E 999,999,999.99") )//07
	AADD(_aItens,NFS->A2_I_AVERB)
	AADD(_aItens,NFS->A2_EST)
	AADD(_aItens,NFS->A2_LOJA)
	AADD(_aItens,NFS->A2_NREDUZ)
	AADD(_aItens,_cNFTitSeg)
   AADD(_aItens,NFS->F2_I_NDFSE)
	AADD(_aLinhas,_aItens)

    //CONTA NA OPCAO EMITIDOS OU SE NÃO EMITIDOS E ESTIVER EM BRANCO F2_I_NDFSE
    IF _lSoma .OR. EMPTY(NFS->F2_I_NDFSE)
       If NFS->F2_I_GERTS <> "N"
          _aTotais[1]+=NFS->TOTAL * _nPSeguro // _nPercSeguro
          _aTotais[2]+=NFS->TOTAL
          _aTotais[3]+=NFS->F2_VALMERC
          _aTotais[4]+=NFS->F2_I_FRET
          _aTotais[7]++
       EndIf 
    ELSEIF !EMPTY(NFS->F2_I_NDFSE)//CONTA QUANDO NÃO EMITIDOS MAS TEM ALGUMAS NOTAS GERADAS
       If NFS->F2_I_GERTS <> "N"
          _aTotais[8]+=NFS->TOTAL * _nPSeguro // _nPercSeguro   
       EndIf 
    ENDIF   

	NFS->(Dbskip())

ENDDO

_cTot:=ALLTRIM(STR(_nTotNfs))
 
IF !EMPTY(_cChave)
   RETURN _cTot
ENDIF
If Len(_aLinhas) = 0
   U_ITMSG("Nenhum Nota localizada","Atenção",,1)
   RETURN .F.
ENDIF

_aItens:={}
IF (_aTotais[7]) > 0
   AADD(_aItens,.T.)//01
   AADD(_aItens,"TOTAIS:")//02
   AADD(_aItens,ALLTRIM(STR(_aTotais[7]))+" Notas")//03
   AADD(_aItens,TRANSFORM(_aTotais[1],"@E 999,999,999,999.99") )//04
   AADD(_aItens,TRANSFORM(_aTotais[2],"@E 999,999,999,999.99") )//05
   AADD(_aItens,TRANSFORM(_aTotais[3],"@E 999,999,999,999.99") )//06
   AADD(_aItens,TRANSFORM(_aTotais[4],"@E 999,999,999,999.99") )//07
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
ENDIF

AADD(_aLinhas,_aItens)

//Monta _aCab
aadd(_aCab,"")
aadd(_aCab,"Nota/Serie")   
aadd(_aCab,"Emissao")      //07
aadd(_aCab,"Seguro")       //01
aadd(_aCab,"Valor Bruto")//02
aadd(_aCab,"Valor Mercadoria") //03
aadd(_aCab,"Frete") //04
aadd(_aCab,"Averbacao")    
aadd(_aCab,"Estado")       
aadd(_aCab,"Loja")         
aadd(_aCab,"Nome Transportador")
aadd(_aCab,"Calculo Titulo Seguro")
aadd(_aCab,"Chave Gerada")      

If Len(_aLinhas) > 0
   _cTitulo:="Nfs do transportador " + ALLTRIM(TRBF->COD)+" - "+TRBF->TRANSP
   _cMsgTop:=NIL
   IF (_aTotais[7]) > 0
      _cMsgTop:=ALLTRIM(STR(_aTotais[7]))+" Notas: Valor do Seguro das Nfs"+IF(_aTotais[8]<>0," NÃO Geradas","")+" R$ "+ALLTRIM(TRANSFORM(_aTotais[1],"@E 999,999,999.99"))+;
      IF(_aTotais[8]<>0," / Valor do Seguro das Nfs Geradas R$ "+ALLTRIM(TRANSFORM(_aTotais[8],"@E 999,999,999.99")),"")
   ENDIF
// U_ITListBox(_cTitAux, _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
   U_ITLISTBOX(_cTitulo, _aCab    , _aLinhas  , .T.      , 4      ,_cMsgTop)
Endif

If Select("TRBSF2") > 0 
   TRBSF2->(DbSetOrder(1))
EndIf 

Return (Len(_aLinhas) > 0)

/*
===============================================================================================================================
Programa----------: AOMS114 Filtro()
Autor-------------: Alex Wallauer 
Data da Criacao---: 22/07/2019
===============================================================================================================================
Descrição---------: Filtro Básico
===============================================================================================================================
Parametros--------: _lLerNotas,_lGera
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114Filtro(_lLerNotas,_lGera)
LOCAL cFiltro:=""

// Filtra Filial das tabelas 
If !Empty( xFilial("SF2") )
   cFiltro += " AND SF2.F2_FILIAL = '"+cFilant+"' "
EndIf

IF MV_PAR06 = 1//SIM: JÁ EMITIDOS ********************************************************************

   IF _lLerNotas
      //Filtra transportador posicionado
      cFiltro += " AND SF2.F2_I_CTRA  = '" + TRBF->COD + "' "
      IF !EMPTY(TRBF->F2_I_NDFSE)//SE EM BRANCO É QUE ESTORNOU O FILTRO VAI SER pela tabela: _aRecEsto
          cFiltro += " AND SF2.F2_I_NDFSE = '" + TRBF->F2_I_NDFSE + "' "//CHAVE DOS TIUTLOS
      ENDIF   

   ELSE

      cFiltro += " AND SF2.F2_I_NDFSE <>  ' ' "
/*
      // Filtra Emissao da SF2
      IF !EMPTY(MV_PAR02)
         cFiltro += " AND SF2.F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
      ELSEIF !EMPTY(MV_PAR01) 
         cFiltro += " AND SF2.F2_EMISSAO >= '" + DTOS(MV_PAR01) + "'"
      ENDIF
*/

      // Filtra Transportadores
      IF !EMPTY(MV_PAR03)
         IF LEN(ALLTRIM(MV_PAR03)) > 6
            cFiltro += " AND SF2.F2_I_CTRA IN " + FormatIn(ALLTRIM(MV_PAR03),";")
         ELSE
            //cFiltro += " AND SA2.A2_COD    = '" + ALLTRIM(MV_PAR03) + "' "
            cFiltro += " AND SF2.F2_I_CTRA = '" + ALLTRIM(MV_PAR03) + "' "
         ENDIF   
      ENDIF 

   ENDIF 

ELSEIF MV_PAR06 = 2//NÃO: NAO EMITIDOS ********************************************************************

/*
   // Filtra Emissao da SF2
   IF !EMPTY(MV_PAR02)
      cFiltro += " AND SF2.F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
   ELSEIF !EMPTY(MV_PAR01) 
      cFiltro += " AND SF2.F2_EMISSAO >= '" + DTOS(MV_PAR01) + "'"
   ENDIF
*/

   IF _lLerNotas

      IF !EMPTY(TRBF->F2_I_NDFSE)//DEPOIS QUE GEROU TÁ PREENCHIDO
         cFiltro += " AND SF2.F2_I_NDFSE = '" + TRBF->F2_I_NDFSE + "' "//CHAVE DOS TIUTLOS
      ELSEIF _lGera//NA HORA DE GERAR SÓ PEGA OS EM BRANCO
         cFiltro += " AND SF2.F2_I_NDFSE = ' ' "         
      ENDIF   
      //Filtra transportador posicionado
      cFiltro += " AND SF2.F2_I_CTRA  = '" + TRBF->COD + "' "

   ELSE

      cFiltro += " AND SF2.F2_I_NDFSE = ' ' "

      // Filtra Transportadores
      IF !EMPTY(MV_PAR03)
         IF LEN(ALLTRIM(MV_PAR03)) > 6
            cFiltro += " AND SF2.F2_I_CTRA IN " + FormatIn(ALLTRIM(MV_PAR03),";")
         ELSE
            cFiltro += " AND SF2.F2_I_CTRA = '" + ALLTRIM(MV_PAR03) + "' "
         ENDIF   
      ENDIF 

   ENDIF

   // Filtra Armazém
/*   IF !EMPTY(MV_PAR04) 
      cFiltro += " AND  EXISTS (SELECT 'Y' "
      cFiltro += " 	              FROM " + RetSqlName("SD2")+" SD2 "
      cFiltro += " 	               WHERE  SD2.D_E_L_E_T_ = ' ' "
      cFiltro += " 	                  AND SD2.D2_FILIAL     = SF2.F2_FILIAL "
      cFiltro += " 	                  AND SD2.D2_DOC        = SF2.F2_DOC    "
      cFiltro += " 	                  AND SD2.D2_SERIE      = SF2.F2_SERIE  "
      cFiltro += " 	                  AND SD2.D2_CLIENTE    = SF2.F2_CLIENTE"
      cFiltro += " 	                  AND SD2.D2_LOJA       = SF2.F2_LOJA   "
      IF LEN(ALLTRIM(MV_PAR04)) > 3
         cFiltro += " 	              AND SD2.D2_LOCAL IN " + FormatIn(ALLTRIM(MV_PAR04),";")+" ) "
      ELSE
         cFiltro += " 	              AND SD2.D2_LOCAL = '"+ALLTRIM(MV_PAR04)+"' ) "
      ENDIF   
   ENDIF
*/

   // Filtra Transportadores por averbacao
   IF MV_PAR05 == 1
      cFiltro += " AND SA2.A2_I_AVERB = '1'"
   ELSEIF MV_PAR05 == 2
      cFiltro += " AND SA2.A2_I_AVERB = '2'"
   ENDIF

   IF SuperGetMV("IT_AMBTEST",.F.,.T.)
      cFiltro+="	AND SA2.A2_I_CLASS IN ('T','A','G') "
   ELSE
      cFiltro+= "	AND SA2.A2_I_TPFRT = 'S' "//SÓ NA PRODUCAO TESTA
   ENDIF   

ENDIF

If !EMPTY(MV_PAR01) 
   cFiltro += " AND SF2.F2_EMISSAO >= '" + DTOS(MV_PAR01) + "'"
EndIf  

If !EMPTY(MV_PAR02) 
   cFiltro += " AND SF2.F2_EMISSAO <= '" + DTOS(MV_PAR02) + "'"
EndIf 

IF !EMPTY(MV_PAR04)  
   IF LEN(ALLTRIM(MV_PAR04)) > 3
      cFiltro += " 	              AND SD2.D2_LOCAL IN " + FormatIn(ALLTRIM(MV_PAR04),";")
   ELSE
      cFiltro += " 	              AND SD2.D2_LOCAL = '"+ALLTRIM(MV_PAR04)+"' "
   ENDIF   
ENDIF
//====================================================================================================

RETURN cFiltro

/*
===============================================================================================================================
Programa----------: AOMS114GE()
Autor-------------: Alex Wallauer 
Data da Criacao---: 22/07/2019
===============================================================================================================================
Descrição---------: Le Transportadores marcados para gera os titulos
===============================================================================================================================
Parametros--------: oProc,_lEMail,_lGera
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114GE(oProc,_lEMail,_lGera)
LOCAL _nConta:=0
LOCAL _aCab :={} 
LOCAL _aSize:={}
LOCAL _cTot := TRBF->(LASTREC())
DEFAULT _lEMail:=.F.
PRIVATE _aTLinhas:={}

oProc:cCaption := ("Processando Titulos de Seguro...")
ProcessMessages()

TRBF->(DBGOTOP())
DO WHILE TRBF->(!EOF())
   IF _lEMail 
      IF !EMPTY(TRBF->OK) .AND. !EMPTY(TRBF->F2_I_NDFSE)
         _nConta++
      ENDIF   
   ELSEIF _lGera .AND. !EMPTY(TRBF->OK).AND. EMPTY(TRBF->F2_I_NDFSE)//GERACAO
      _nConta++
   ELSEIF !_lGera .AND. !EMPTY(TRBF->OK) .AND. !EMPTY(TRBF->F2_I_NDFSE) .AND. SE2->(Dbseek(xfilial("SE2")+ALLTRIM(TRBF->F2_I_NDFSE)))//ESTORNO
      _nConta++
   ENDIF   
   TRBF->(Dbskip())
ENDDO 

IF _nConta = 0
   IF _lEMail
      U_ITMSG("Nenhum Titulo de Seguro Gerado","Atenção",,1)
   ELSE
      U_ITMSG("Nenhum registro Marcado","Atenção",,1)
   ENDIF   
   RETURN .F.
ENDIF

_cTot:=ALLTRIM(STR(_nConta))
_nTam:=LEN(_cTot)+1
_nConta:=0

SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

_aRecEsto:={}
TRBF->(DBGOTOP())
DO WHILE TRBF->(!EOF())

   IF _lEMail 

      IF !EMPTY(TRBF->OK) .AND. !EMPTY(TRBF->F2_I_NDFSE) .AND. SE2->(Dbseek(xfilial("SE2")+ALLTRIM(TRBF->F2_I_NDFSE)))
         _nConta++
          oProc:cCaption := ("Lendo Titulo: "+ALLTRIM(STR(_nConta,_nTam)) +" de "+ _cTot+" - Transp.: "+TRBF->COD)
         ProcessMessages()
         _aItens:={}
         AADD(_aItens,.T.             )     //01
         AADD(_aItens,SE2->E2_PREFIXO )     //02
         AADD(_aItens,SE2->E2_NUM     )     //03
         AADD(_aItens,SE2->E2_PARCELA )     //04
         AADD(_aItens,SE2->E2_TIPO    )     //05
         AADD(_aItens,SE2->E2_NATUREZ )     //06
         AADD(_aItens,SE2->E2_FORNECE )     //07
         AADD(_aItens,SE2->E2_LOJA    )     //08
         AADD(_aItens,DTOC(SE2->E2_EMISSAO))//09
         AADD(_aItens,DTOC(SE2->E2_VENCTO)) //10
         AADD(_aItens,ALLTRIM(TRANSFORM(SE2->E2_VALOR,"@E 999,999,999,999.99")))//11
         AADD(_aItens,SE2->E2_HIST)         //12
         AADD(_aItens,DTOC(SE2->E2_DATALIB))//13
         AADD(_aItens,SE2->E2_USUALIB)      //14
         AADD(_aItens,TRBF->QTDENF)         //15
         AADD(_aItens,"Gerado com Sucesso") //16
         AADD(_aItens, SE2->(RECNO()) )     //17
         AADD(_aTLinhas,_aItens)
      ENDIF

   ELSEIF _lGera .AND. !EMPTY(TRBF->OK) .AND. EMPTY(TRBF->F2_I_NDFSE)//GERACAO
      _nConta++
      oProc:cCaption := ("Gerando Titulo: "+ALLTRIM(STR(_nConta,_nTam))+" de "+ _cTot+" - Transp.: "+TRBF->COD)
      ProcessMessages()

      AOMS114SE(oProc,ALLTRIM(STR(TRBF->QTDENF)))//GERACAO

   ELSEIF !_lGera .AND. !EMPTY(TRBF->OK) .AND. !EMPTY(TRBF->F2_I_NDFSE) .AND. SE2->(Dbseek(xfilial("SE2")+ALLTRIM(TRBF->F2_I_NDFSE)))//ESTORNO
      _nConta++
      oProc:cCaption := ("Estornando Titulo: "+ALLTRIM(STR(_nConta,_nTam))+" de "+ _cTot+" - Transp.: "+TRBF->COD)
      ProcessMessages()

      AOM114Estorno(oProc,ALLTRIM(STR(TRBF->QTDENF)))//ESTORNO

   ENDIF   
    
   TRBF->(Dbskip())

ENDDO
TRBF->(DBGOTOP())

//Monta aheader
aadd(_aCab,"")//01
aadd(_aSize,5)
AAdd(_aCab,Getsx3cache("E2_PREFIXO","X3_TITULO"))//02
aadd(_aSize,5)
AAdd(_aCab,Getsx3cache("E2_NUM"    ,"X3_TITULO"))//03
aadd(_aSize,9)
AAdd(_aCab,Getsx3cache("E2_PARCELA","X3_TITULO"))//04
aadd(_aSize,5)
AAdd(_aCab,Getsx3cache("E2_TIPO"   ,"X3_TITULO"))//05
aadd(_aSize,5)
AAdd(_aCab,Getsx3cache("E2_NATUREZ","X3_TITULO"))//06
aadd(_aSize,8)
AAdd(_aCab,Getsx3cache("E2_FORNECE","X3_TITULO"))//07
aadd(_aSize,15)
AAdd(_aCab,Getsx3cache("E2_LOJA"   ,"X3_TITULO"))//08	
aadd(_aSize,5)
AAdd(_aCab,Getsx3cache("E2_EMISSAO","X3_TITULO"))//09
aadd(_aSize,15)
AAdd(_aCab,Getsx3cache("E2_VENCTO" ,"X3_TITULO"))//10
aadd(_aSize,15)
AAdd(_aCab,Getsx3cache("E2_VALOR"  ,"X3_TITULO"))//11
aadd(_aSize,15)
AAdd(_aCab,Getsx3cache("E2_HIST"   ,"X3_TITULO"))//12
aadd(_aSize,30)
AAdd(_aCab,Getsx3cache("E2_DATALIB","X3_TITULO"))//13
aadd(_aSize,15)
AAdd(_aCab,Getsx3cache("E2_USUALIB","X3_TITULO"))//14
aadd(_aSize,15)
AAdd(_aCab,"Qtde NF")  //15
aadd(_aSize,10)
AAdd(_aCab,"Resultado")//16
aadd(_aSize,15)
AAdd(_aCab,"Registro") //17
aadd(_aSize,10)

If Len(_aTLinhas) > 0

   AOMS114Email(_aTLinhas,_lEMail,oProc,_lGera,_aCab)

   IF _lEMail
      RETURN  .T.
   ENDIF   
   nPosResu:=LEN(_aCab)//Posiçao do "Resultado"
   nPosRecn:=LEN(_aTLinhas[1])//Posiçao do Recno do TRB
   aBotoes:={}                                            //oProc,_cChave,_nRecTRBF                              ,_lGrava,_lSoma
   AADD( aBotoes , { "" , {|| FWMSGRUN(,{ |oProc| AOMS114NF(oProc,""     ,oLbxAux:aArray[oLbxAux:nAt][ nPosRecn ],.F.    ,.T.   )}, "","") },"","Visualiza NFs"} )
   AADD( aBotoes , { "" , {|| AVISO("ATENCAO",oLbxAux:aArray[oLbxAux:nAt][ nPosResu ],{"Fechar"},3) }	, "" , "Visualizar Erro"		  } )
//    ITListBox(_cTitAux               , _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
	U_ITLISTBOX("Titulos Processados: ", _aCab    , _aTLinhas , .T.      , 4      ,          ,          , _aSize  ,         ,     ,        , aBotoes)
Else
	U_ITMSG("Nenhum registro localizado","Atenção",,1)
Endif

RETURN  .T.
/*
===============================================================================================================================
Programa----------: AOMS114SE()
Autor-------------: Alex Wallauer 
Data da Criacao---: 23/07/2019
===============================================================================================================================
Descrição---------: Gera os titulos dos Transportadores marcados
===============================================================================================================================
Parametros--------: oProc,_cTot
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114SE(oProc,_cTot) 
Local _nModAux  := nModulo
Local _cModAux  := cModulo
Local _lRet     := .T.  
LOCAL _cNatureza:= U_ITGETMV("IT_NDFNATU","112006    ")
LOCAL _cCodigo  :="" , nSeq
LOCAL _cFornece :=TRBF->COD
LOCAL _cLoja    :=TRBF->A2_LOJA
LOCAL _nValortit:=TRBF->SEGURO
LOCAL _cHistoric:="SEGURO - "+TRBF->TRANSP
cUserName:=cUserName

SA2->( DBSetOrder(1) ) 
If SA2->(Dbseek(xfilial("SA2")+TRBF->COD+TRBF->A2_LOJA))
	IF SA2->A2_MSBLQL == '1'
		SA2->(Dbseek(xfilial("SA2")+TRBF->COD))
		DO WHILE TRBF->COD == SA2->A2_COD .AND. xfilial("SA2") = SA2->A2_FILIAL .AND. SA2->(!EOF())
   			IF SA2->A2_MSBLQL <> '1'
      			_cLoja:=SA2->A2_LOJA//Pega a primeira loja não bloqueada
      			EXIT
   			ENDIF
   			SA2->(DBSKIP())
		ENDDO
	EndIf
EndIf
SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
FOR nSeq := 0 TO 999
   _cCodigo:=STRZERO(nSeq,3)+STRTRAN( DTOC(DATE()),"/","")
   IF !SE2->(Dbseek(xfilial("SE2")+"MAN"+_cCodigo+"01"+"NDF"))//+_cFornece+_cLoja
      EXIT
   ENDIF   
NEXT

_aAutoSE2 := {}
AAdd( _aAutoSE2 , { "E2_PREFIXO"	, "MAN"			, NIL } )		
AAdd( _aAutoSE2 , { "E2_NUM"		, _cCodigo		, NIL } )
AAdd( _aAutoSE2 , { "E2_PARCELA"	, "01"			, NIL } )	
AAdd( _aAutoSE2 , { "E2_TIPO"		, "NDF"			, NIL } )
AAdd( _aAutoSE2 , { "E2_NATUREZ"	, _cNatureza	, NIL } ) 
AAdd( _aAutoSE2 , { "E2_FORNECE"	, _cFornece 	, NIL } )	
AAdd( _aAutoSE2 , { "E2_LOJA"		, _cLoja 		, NIL } )	
AAdd( _aAutoSE2 , { "E2_EMISSAO"	, DDataBase	   , NIL } )   // AAdd( _aAutoSE2 , { "E2_EMISSAO"	, DATE()		, NIL } )
AAdd( _aAutoSE2 , { "E2_VENCTO"	, dDtVenc	   , NIL } )
AAdd( _aAutoSE2 , { "E2_VALOR"	, _nValortit   , NIL } )
AAdd( _aAutoSE2 , { "E2_HIST"		, _cHistoric   , Nil } )
AAdd( _aAutoSE2 , { "E2_DATALIB"	, DDataBase		, NIL } )     // AAdd( _aAutoSE2 , { "E2_DATALIB"	, DATE()		, NIL } )
AAdd( _aAutoSE2 , { "E2_USUALIB"	, cUserName		, NIL } )
AAdd( _aAutoSE2 , { "E2_ORIGEM"	, "AOMS114"    , NIL } )

_aItens:={}
AADD(_aItens,.T.     )
AADD(_aItens,"MAN"   )
AADD(_aItens,_cCodigo)
AADD(_aItens,"01"    )
AAdd(_aItens,"NDF"   ) 
AAdd(_aItens,_cNatureza) 
AAdd(_aItens,_cFornece )	
AAdd(_aItens,_cLoja    )		 	
AAdd(_aItens,DTOC(DDataBase)) // AAdd(_aItens,DTOC(DATE()) )
AAdd(_aItens,DTOC(dDtVenc) )
AAdd(_aItens,ALLTRIM(TRANSFORM(_nValortit,"@E 999,999,999,999.99")))//11
AAdd(_aItens,_cHistoric   )
AAdd(_aItens,DTOC(DDataBase)) // AAdd(_aItens,DTOC(DATE()) )
AAdd(_aItens,cUserName    )

nModulo	   := 6
cModulo	   := "FIN"
lMsErroAuto:=.F.
   		  		
MSEXECAUTO({|X,Y| FINA050(X,Y)},_aAutoSE2,3) //Inclusao

_cErro:="Gerado com Sucesso"  		  		
If lMsErroAuto

   _cErro:=(MOSTRAERRO(GETTEMPPATH()))
   _cErro:="Não Gerou. Acesse Visualizar Erro: "+CHR(13)+CHR(10)+ALLTRIM(_cErro)
   _aItens[1]:=.F.
	_lRet:= .F.  

ELSE
  _cChave:="MAN"+_cCodigo+"01"+"NDF"+_cFornece+_cLoja
  
  _aTRBF[ TRBF->(RECNO()),01]:=SPACE(2)
  _aTRBF[ TRBF->(RECNO()),14]:=_cChave
                 //oProc,_cChave,_nRecTRBF      ,_lGrava,_lSoma,lGera
  _cTot:=AOMS114NF(oProc,_cChave,TRBF->(RECNO()),.T.    ,.F.   ,.T.  )//GRAVA O CAMPO F2_I_NDFSE DAS NOTAS
  TRBF->OK        :=Space(2)
  TRBF->F2_I_NDFSE:=_cChave//Grava despois pq causa dos controles do filtro em cima desse campo na gravação
  
Endif
AAdd(_aItens,_cTot)//15
AAdd(_aItens,_cErro)//16
AAdd(_aItens,TRBF->(RECNO()))//17

AADD(_aTLinhas,_aItens)

nModulo:= _nModAux
cModulo:= _cModAux

RETURN _lRet

/*
===============================================================================================================================
Programa----------: AOMS114Email()
Autor-------------: Alex Wallauer
Data da Criacao---: 25/07/2019
===============================================================================================================================
Descrição---------: Monta e envia email 
===============================================================================================================================
Parametros--------: _aTLinhas,_lTela,oProc,_lGera,_aCab
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS114Email(_aTLinhas,_lTela,oProc,_lGera,_aCab)
Local _aConfig	:= U_ITCFGEML('')
Local _cEmlLog	:= ""
Local _cMsgEml	:= ""
Local nOpcA		:= 2   , _nI , oDlgMail , _aSizes:={}
Local cGetAnx	:= ""
Local cGetCc	:= SPACE(200)
Local cGetMens	:= SPACE(999)//Esta é uma mensagem automática
Local cGetPara	:= U_ITGETMV("IT_NDFEMAIL", " " ) + SPACE(150)
Local _cTot     := ALLTRIM(STR(LEN(_aTLinhas)))
Local _nTam     := LEN(_cTot)
Local _cNomeFil := cFilant+" - "+AllTrim( Posicione('SM0',1,"01"+cFilant,'M0_FILIAL') )
Local cGetAssun	:= "Geração de Titulos de Seguro de Frete / "+_cNomeFil+" - ["+DTOC(DATE())+"]"

If (LEN(PSWRET()) # 0) // Quando nao for rotina automatica do configurador
   PswOrder(1)
   PswSeek(__cUserID,.T.)
   aUsuario:= PswRet()
   cGetCc  := LOWER(Alltrim(aUsuario[1,14]))+SPACE(150)// Pega e-mail do usuario
Endif
IF EMPTY(cGetPara)
   cGetPara:=cGetCc
ENDIF   
_cMsgEml := '<html>'
IF _lGera
  _cMsgEml += '<head><title>Geração de Titulos de Seguro de Frete</title></head>'
ELSE
   cGetAssun:= "Estorno de Titulos de Seguro de Frete / "+_cNomeFil+" - ["+DTOC(DATE())+"]"
  _cMsgEml += '<head><title>Estorno de Titulos de Seguro de Frete</title></head>'
ENDIF
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '	     <td class="titulos"><center>'+cGetAssun+'</center></td>'
_cMsgEml += '	 </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados de envio</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Enviado por: </b></td>'
_cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>' 
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
_cMsgEml += '      <td class="itens" >'+ _cNomeFil +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Observações:</b></td>'
_cMsgEml += '      <td class="itens" >#OBS#</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1200">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="9" class="grupos">Titulos de Seguro de Frete</b></td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
//        02   03   04   05    06   07   08   09   10   11   12   13   14
_aSizes:={"4","7","4","4","  ","  ","  ","7","7","7","50","  ","10"}
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCab[02]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCab[03]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>'+_aCab[04]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>'+_aCab[05]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[08]+'%"><b>'+_aCab[09]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[09]+'%"><b>'+_aCab[10]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[10]+'%"><b>'+_aCab[11]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[11]+'%"><b>Codigo-Loja / Historico</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[13]+'%"><b>'+_aCab[14]+'</b></td>'

_cMsgEml += '    </tr>'

_cMsgEml += '    #LISTA#'

_cMsgEml += '</table>'
	
_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [AOMS114]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'

IF _lTela

   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo

   DEFINE MSDIALOG oDlgMail TITLE "E-Mail de: "+Lower(AllTrim(UsrRetMail(RetCodUsr()))) FROM 000, 000  TO 415,999 COLORS 0, 16777215 PIXEL
     _nLinha:=05
     _nPula :=16
     _nWidth:=((oDlgMail:nClientWidth-6)/2)-8
     _nSize :=_nWidth-24
	// Para:
	@ _nLinha+2, 005 SAY "Para:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ _nLinha  , 030 MSGET cGetPara SIZE _nSize, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL
     _nLinha+=_nPula

	// Com cópia:
	@ _nLinha+2, 005 SAY "Cc:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ _nLinha  , 030 MSGET cGetCc SIZE _nSize, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL
     _nLinha+=_nPula

	// Assunto:
	@ _nLinha+2, 005 SAY "Assunto:" SIZE 022, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ _nLinha  , 030 MSGET cGetAssun SIZE _nSize, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL
     _nLinha+=_nPula

	// Mensagem:
	@ _nLinha+2, 005 SAY "Observ.:" SIZE 030, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ _nLinha  , 030 MSGET cGetMens SIZE _nSize, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL
     _nLinha+=_nPula

	// LISTA
  //TCBrowse():New( [ nRow ], [ nCol ], [ nWidth ], [ nHeight ], [ bLine ], [ aHeaders ], [ aColSizes ], [ oWnd ], [ cField ], [ uValue1 ], [ uValue2 ], [ bChange ], [ bLDblClick ]  , [ bRClick ], [ oFont ], [ oCursor ], [ nClrFore ], [ nClrBack ], [ cMsg ], [ uParam20 ], [ cAlias ], [ lPixel ], [ bWhen ], [ uParam24 ], [ bValid ], [ lHScroll ], [ lVScroll ] )
	oMark2:= TCBrowse():New(070 , 006  ,_nWidth , 110  ,          ,             ,              , oDlgMail ,           ,            ,            ,            ,                 ,            ,          ,            ,             ,             ,         ,    .F.      ,           ,   .T.     ,          ,    .F.      ,           ,             ,              )
	oMark2:SetArray(_aTLinhas)
  	oMark2:AddColumn(TCColumn():New(_aCab[01],{|| LoadBitmap(GetResources(), IF(_aTLinhas[oMark2:nat,01],"BR_VERDE","BR_VERMELHO")) },,,,,,.T.,.F.,,,,.F., ) )
	oMark2:AddColumn(TCColumn():New(_aCab[02],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,02], ' ') },"@!"       	,,,"LEFT" ,020,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[03],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,03], ' ') },"@!"       	,,,"LEFT" ,020,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[04],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,04], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[05],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,05], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[06],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,06], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[07],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,07], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[08],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,08], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[09],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,09], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[10],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,10], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[11],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,11], ' ') },"@!"        ,,,"RIGHT",050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[12],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,12], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[13],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,13], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	oMark2:AddColumn(TCColumn():New(_aCab[14],{|| iif(len(_aTLinhas)>0,_aTLinhas[oMark2:nat,14], ' ') },"@!"       	,,,"LEFT" ,050,.F.,.F.,,,,,))
	                                     
	@ 189, 005 BUTTON "ENVIAR"		SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 1 , oDlgMail:End() ) PIXEL
	@ 189, 050 BUTTON "CANCELAR"	SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 2 , oDlgMail:End() ) PIXEL

   ACTIVATE MSDIALOG oDlgMail CENTERED

ELSE
   cGetMens:="Esta é uma mensagem automática"
ENDIF   

If nOpcA == 1 .OR. !_lTela

   _cMsgEml:=STRTRAN(_cMsgEml,"#OBS#",cGetMens)
   _cGetLista:=""
   _lEnvia:=.F.
   For _nI := 1 To LEN(_aTLinhas)
	   oProc:cCaption := ("Lendo dados dos Titulo: "+ALLTRIM(STR(_nI,_nTam))+" de "+ _cTot)
       ProcessMessages()
       IF !_aTLinhas[_nI,01]
          LOOP
       ENDIF
	   _cGetLista += '    <tr>'
	   _cGetLista += '      <td class="itens" align="center" width="'+_aSizes[01]+'%">'+ _aTLinhas[_nI][02]+'</td>'
	   _cGetLista += '      <td class="itens" align="center" width="'+_aSizes[02]+'%">'+ _aTLinhas[_nI][03]+'</td>'
	   _cGetLista += '      <td class="itens" align="center" width="'+_aSizes[03]+'%">'+ _aTLinhas[_nI][04]+'</td>'
  	   _cGetLista += '      <td class="itens" align="center" width="'+_aSizes[04]+'%">'+ _aTLinhas[_nI][05]+'</td>'
	   _cGetLista += '      <td class="itens" align="center" width="'+_aSizes[08]+'%">'+ _aTLinhas[_nI][09]+'</td>'
	   _cGetLista += '      <td class="itens" align="center" width="'+_aSizes[09]+'%">'+ _aTLinhas[_nI][10]+'</td>'
	   _cGetLista += '      <td class="itens" align="right" width="'+_aSizes[10]+'%">'+ _aTLinhas[_nI][11]+'</td>'
	   _cGetLista += '      <td class="itens" align="left" width="'+_aSizes[11]+'%">'+ _aTLinhas[_nI][07]+"-"+_aTLinhas[_nI][08]+" / "+_aTLinhas[_nI][12]+'</td>'
	   _cGetLista += '      <td class="itens" align="center" width="'+_aSizes[13]+'%">'+ _aTLinhas[_nI][14]+'</td>'
	   _cGetLista += '    </tr>'
	   _lEnvia:=.T.
   Next
   
	IF _lEnvia
		
		_cMsgEml:=STRTRAN(_cMsgEml,"#LISTA#",_cGetLista)
		
		// Chama a função para envio do e-mail
		U_ITENVMAIL( Lower(AllTrim(UsrRetMail(RetCodUsr()))), cGetPara, cGetCc, "", cGetAssun, _cMsgEml, cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
		
		U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
		"E-mail para: "+cGetPara +CHR(13)+CHR(10)+;
		"Com Copia: "+cGetCc+CHR(13)+CHR(10),"Envio do E-MAIL",,3)

	ENDIF
   
EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: AOM114Trava()
Autor-------------: Alex Wallauer 
Data da Criacao---: 31/07/2019
===============================================================================================================================
Descrição---------: Travaa tela para um usuario por filial
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function AOM114Trava()
Local _nCnt01  	:= 0
Local _lLockZP1	:= .F.

DbSelectArea( "ZP1" )
ZP1->( DBSetOrder(2) )
If ZP1->( MsSeek( xFilial('ZP1') + cFilant + _cMV_ZP1 ) )//TRAVA POR FILIAL
   DO WHILE !_lLockZP1 .And. (++_nCnt01 < 03)
	  If InTransact()
	  	_lLockZP1 := RecLock("ZP1")
	  Else
	 	_lLockZP1 := MsRLock()
	  EndIf
	  If !_lLockZP1
	     Inkey(1)
	  EndIf
   EndDo
ELSE
   ZP1->(RECLOCK("ZP1",.T.))
   ZP1->ZP1_FILIAL:=xFilial("ZP1")
   ZP1->ZP1_MODULO:="39"
   ZP1->ZP1_GRUPO :="P"
   ZP1->ZP1_ROTINA:="AOMS114"
   ZP1->ZP1_DESROT:="Central de seguros de frete"
   ZP1->ZP1_FILPAR:=cFilant
   ZP1->ZP1_PARAM :=_cMV_ZP1
   ZP1->ZP1_DESCRI:="Trava por filial + usuario do Programa AOMS114"
   ZP1->ZP1_TIPO  :="C"
   _lLockZP1:=.T.
EndIf
ZP1->( DBSetOrder(1) )
If _lLockZP1
   ZP1->ZP1_CONTEU:=UsrFullName(__cUserID)+" - "+DTOC(DATE())+" - "+TIME()
Else
   U_ITMSG( "O Programa esta sendo utilizado pelo Usuario: "+ALLTRIM(ZP1->ZP1_CONTEU),"Parametro "+_cMV_ZP1+" na ZP1","Aguarde o usuario finalizar",1) 
   RETURN .F.
EndIf

IF MV_PAR01 < _dDtCorte .OR. MV_PAR01 > MV_PAR02
   U_ITMSG("Intervalo de datas invalido","Parametro ITNDFDTCOR na ZP1","Data inicial deve ser maior ou igual que data de Corte: "+DTOC(_dDtCorte),1) 
   RETURN .F.
EndIf

RETURN .T.
/*
===============================================================================================================================
Programa----------: AOM114Estorno()
Autor-------------: Alex Wallauer 
Data da Criacao---: 31/07/2019
===============================================================================================================================
Descrição---------: Estorna Titulo do seguro
===============================================================================================================================
Parametros--------: oProc,_cTot
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function AOM114Estorno(oProc,_cTot)
Local _aAutoSE2:= {}
Local _nModAux  := nModulo
Local _cModAux  := cModulo
Local _lRet     := .T.  
					
AAdd( _aAutoSE2 , { "E2_FILIAL"		, SE2->E2_FILIAL		, nil } )	
AAdd( _aAutoSE2 , { "E2_PREFIXO"	, SE2->E2_PREFIXO		, nil } )		
AAdd( _aAutoSE2 , { "E2_NUM"		, SE2->E2_NUM			, nil } )
AAdd( _aAutoSE2 , { "E2_PARCELA"	, SE2->E2_PARCELA		, nil } )	
AAdd( _aAutoSE2 , { "E2_TIPO"		, SE2->E2_TIPO			, nil } )
AAdd( _aAutoSE2 , { "E2_NATUREZ"	, SE2->E2_NATUREZ		, nil } ) 
AAdd( _aAutoSE2 , { "E2_FORNECE"	, SE2->E2_FORNECE		, nil } )	
AAdd( _aAutoSE2 , { "E2_LOJA"		, SE2->E2_LOJA			, nil } )	
AAdd( _aAutoSE2 , { "E2_EMISSAO"	, SE2->E2_EMISSAO		, nil } )
AAdd( _aAutoSE2 , { "E2_VENCTO"	, SE2->E2_VENCTO		, nil } )
AAdd( _aAutoSE2 , { "E2_VALOR"	, SE2->E2_VALOR		, nil } )
AAdd( _aAutoSE2 , { "E2_HIST"		, SE2->E2_HIST 		, Nil } )
AAdd( _aAutoSE2 , { "E2_DATALIB"	, SE2->E2_DATALIB		, nil } )
AAdd( _aAutoSE2 , { "E2_USUALIB"	, SE2->E2_USUALIB		, nil } )

_aItens:={}
AADD(_aItens,.T.)
AADD(_aItens,SE2->E2_PREFIXO)
AADD(_aItens,SE2->E2_NUM)
AADD(_aItens,SE2->E2_PARCELA)
AAdd(_aItens,SE2->E2_TIPO) 
AAdd(_aItens,SE2->E2_NATUREZ) 
AAdd(_aItens,SE2->E2_FORNECE)	
AAdd(_aItens,SE2->E2_LOJA   )		 	
AAdd(_aItens,DTOC(SE2->E2_EMISSAO))
AAdd(_aItens,DTOC(SE2->E2_VENCTO))
AAdd(_aItens,ALLTRIM(TRANSFORM(SE2->E2_VALOR,"@E 999,999,999,999.99")))//11
AAdd(_aItens,SE2->E2_HIST   )
AAdd(_aItens,DTOC(SE2->E2_DATALIB))
AAdd(_aItens,SE2->E2_USUALIB)
   
nModulo	   := 6
cModulo	   := "FIN"
lMsErroAuto:=.F.

MSExecAuto({|v,h,k,l,m,n,o| Fina050(v,h,k,l,m,n,o)},_aAutoSE2,,5,,,.F.,.T.)//Exclusão

_cErro:="Estornado com Sucesso"  		  		
If lMsErroAuto

   _cErro:=(MOSTRAERRO(GETTEMPPATH()))
   _cErro:="Não Estornou. Acesse Visualizar Erro: "+CHR(13)+CHR(10)+_cErro
   _aItens[1]:=.F.

ELSE

  _aTRBF[ TRBF->(RECNO()),01]:=SPACE(2)
  _aTRBF[ TRBF->(RECNO()),14]:=""
                 //oProc,_cChave         ,_nRecTRBF      ,_lGrava,_lSoma,lGera
  _cTot:=AOMS114NF(oProc,TRBF->F2_I_NDFSE,TRBF->(RECNO()),.T.    ,.F.   ,.F.  )//LIMPA O CAMPO F2_I_NDFSE DAS NOTAS
  TRBF->OK        :=Space(2)
  TRBF->F2_I_NDFSE:=""//Limpa despois pq causa dos controles do filtro em cima desse campo no estorno
  
Endif
AAdd(_aItens,_cTot)//15
AAdd(_aItens,_cErro)//16
AAdd(_aItens,TRBF->(RECNO()))//17

AADD(_aTLinhas,_aItens)

nModulo:= _nModAux
cModulo:= _cModAux

RETURN _lRet

/*
===============================================================================================================================
Programa----------: AOMS11 4B()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/06/2021
===============================================================================================================================
Descrição---------: Cria tabela temporária e carrega com os dados das notas fiscais selecionadas nos filtros.
===============================================================================================================================
Parametros--------: _oProc - objeto da regua de processamento.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function AOMS114B(_oProc,QRYNFS)
Local _aStruct := {}
//Local _oTRBSF2, _nI , _cQry
//Local _aDadosPesq := {}, _nTotRegs
Local _nPerTransp, _nPSeguro
//Local _nPercSeguro := U_ITGETMV("IT_PERCSEG",0.13)//Padrão é 0.13% criar o parametro tipo numerico
//Local _cFiltro := ""
//Local _lGera := .T.  
//Local _nQtdNfs, _nTotSeguro

Begin Sequence
   
If Select("TRBSF2") = 0
	//   TRBSF2->(DBCLOSEAREA())
   //EndIf

   _oProc:cCaption := ("Criando arquivo detalhes das notas...")
   ProcessMessages()

   Aadd(_aStruct,{"WK_OK"     ,"C",2,0})
   Aadd(_aStruct,{"F2_FILIAL" ,"C",2,0})
   Aadd(_aStruct,{"F2_DOC"    ,"C",Getsx3cache("F2_DOC","X3_TAMANHO"),0})
   Aadd(_aStruct,{"F2_SERIE"  ,"C",Getsx3cache("F2_DOC","X3_TAMANHO"),0})
   Aadd(_aStruct,{"F2_EMISSAO","D",8,0})
   Aadd(_aStruct,{"A2_I_AVERB",Getsx3cache("A2_I_AVERB","X3_TIPO"), Getsx3cache("A2_I_AVERB","X3_TAMANHO"),Getsx3cache("A2_I_AVERB","X3_DECIMAL")})
   Aadd(_aStruct,{"A2_COD"    ,"C",Getsx3cache("A2_COD","X3_TAMANHO"),0})   
   Aadd(_aStruct,{"A2_LOJA"   ,"C",Getsx3cache("A2_LOJA","X3_TAMANHO"),0}) 
   Aadd(_aStruct,{"A2_EST"    ,"C",Getsx3cache("A2_EST","X3_TAMANHO"),0}) 
   Aadd(_aStruct,{"A2_NREDUZ" ,"C",Getsx3cache("A2_NREDUZ","X3_TAMANHO"),0}) 
   Aadd(_aStruct,{"F2_I_NDFSE","C", Getsx3cache("F2_I_NDFSE","X3_TAMANHO"),0}) // Nota Fiscal do Seguro
   Aadd(_aStruct,{"F2_I_FRET" ,"N",Getsx3cache("F2_I_FRET","X3_TAMANHO"),Getsx3cache("F2_I_FRET","X3_DECIMAL")}) 
   Aadd(_aStruct,{"F2_VALMERC","N",Getsx3cache("F2_VALMERC","X3_TAMANHO"),Getsx3cache("F2_VALMERC","X3_DECIMAL")}) 
   Aadd(_aStruct,{"F2_VALBRUT","N",Getsx3cache("F2_VALBRUT","X3_TAMANHO"),Getsx3cache("F2_VALBRUT","X3_DECIMAL")}) 
   Aadd(_aStruct,{"WK_PERSEGU","N",14,8}) 
   Aadd(_aStruct,{"WK_SEGURO" ,"N",18,6}) 
   Aadd(_aStruct,{"F2_I_CTRA" ,"C",Getsx3cache("F2_I_CTRA","X3_TAMANHO"),0})   // Transportadora
   Aadd(_aStruct,{"F2_I_LTRA" ,"C",Getsx3cache("F2_I_LTRA","X3_TAMANHO"),0})   // Loja Transportadora
   Aadd(_aStruct,{"WK_RECNO"  ,"C",10,0})
   Aadd(_aStruct,{"WK_RECSF2" ,"C",10,0})

   _oTRBSF2 := FWTemporaryTable():New( "TRBSF2", _aStruct )
   _oTRBSF2:AddIndex( "1", {"WK_RECNO"} )
   _oTRBSF2:AddIndex( "2", {"WK_RECSF2"} )

   _oTRBSF2:Create()
ENDIF
   //_oProc:cCaption := ("Iniciando processo de gravação detalhes das notas...")
   //ProcessMessages()

   //If ValType(_nPercSeguro) <> "N"
   //   _nPercSeguro := 0.13/100
   //Else
   //   _nPercSeguro:=(_nPercSeguro/100)
   //EndIf

   //TRBF->(DbGoTop())
   //Do While ! TRBF->(Eof())
   //   Aadd(_aDadosPesq, {TRBF->COD,TRBF->F2_I_NDFSE,TRBF->(Recno())})
   //   
   //   TRBF->(DbSkip())
   //EndDo

   //TRBF->(DbGoTop())
   //_nTotRegs := Len(_aDadosPesq)
   //For _nI := 1 To _nTotRegs
   //    _oProc:cCaption := ("Gravando Detalhes das Notas "+AllTrim(Str(_nI,10)) + "/" + AllTrim(Str(_nTotRegs,10))+"...")
   //    ProcessMessages()

   //   TRBF->(DbGoTo(_aDadosPesq[_nI,3]))  
       
       //_cFiltro:=AOMS114Filtro(.T.,_lGera) 
       //If Select("QRYNFS") > 0
	    //   QRYNFS->(DBCLOSEAREA())
       //EndIf       _cQry:= " SELECT "
       //_cQry+= " SF2.F2_FILIAL , "
       //_cQry+= " SF2.F2_DOC    , "
       //_cQry+= " SF2.F2_SERIE  , "
       //_cQry+= " SF2.F2_EMISSAO, "
       //_cQry+= " SA2.A2_I_AVERB, " 
       //_cQry+= " SA2.A2_COD    , "
       //_cQry+= " SA2.A2_LOJA   , " 
       //_cQry+= " SA2.A2_EST    , "
       //_cQry+= " SA2.A2_NREDUZ , " 
       //_cQry+= " SF2.F2_I_NDFSE, "
       //_cQry+= " SF2.F2_I_FRET , "
       //_cQry+= " SF2.F2_VALMERC, "
       //_cQry+= " SF2.F2_VALBRUT, " 
       //_cQry+= " SF2.R_E_C_N_O_ SF2_REC, "
       //_cQry+= " SF2.F2_I_CTRA AS TRANSPORT, "  // Transportadora
       //_cQry+= " SF2.F2_I_LTRA AS LOJATRANSP, "  // Loja Transportadora
       //_cQry+= " SF2.F2_I_GERTS "   
       //_cQry+= " FROM " + RetSqlName("SF2")+" SF2 "
       //_cQry+= " JOIN " + RetSqlName("SA2")+" SA2 ON SA2.A2_COD = SF2.F2_I_CTRA	AND SA2.A2_LOJA	 = SF2.F2_I_LTRA "
       //_cQry+= " WHERE SF2.D_E_L_E_T_ = ' '	"
       //_cQry+= " AND SA2.D_E_L_E_T_ = ' '	"
       //_cQry+= " AND SF2.F2_CARGA  <> ' '  "
       //_cQry+= _cFiltro
       //_cQry+= " ORDER BY F2_I_NDFSE,SF2.F2_FILIAL,SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO "
       //MPSysOpenQuery( _cQry , "QRYNFS" )  
       //TCSetField( "QRYNFS", "F2_EMISSAO", "D", 8, 0)
       
       //_nQtdNfs    := 0
       //_nTotSeguro := 0

       //Do While ! QRYNFS->(Eof())
          _nPerTransp := Posicione('ZGX',1,xFilial("ZGX")+(QRYNFS)->F2_FILIAL+(QRYNFS)->TRANSPORT+(QRYNFS)->LOJATRANSP,'ZGX_PERSEG')
          If ! Empty(_nPerTransp)
             _nPSeguro := (_nPerTransp/100)
          Else
             _nPSeguro := _nPercSeguro
          EndIf 

          TRBSF2->(DBAPPEND())
          TRBSF2->WK_OK      := _cMarca
          TRBSF2->F2_FILIAL  := (QRYNFS)->F2_FILIAL
          TRBSF2->F2_DOC     := (QRYNFS)->F2_DOC
          TRBSF2->F2_SERIE   := (QRYNFS)->F2_SERIE
          TRBSF2->F2_EMISSAO := (QRYNFS)->F2_EMISSAO
          TRBSF2->A2_I_AVERB := (QRYNFS)->A2_I_AVERB
          TRBSF2->A2_COD     := (QRYNFS)->A2_COD
          TRBSF2->A2_LOJA    := (QRYNFS)->A2_LOJA
          TRBSF2->A2_EST     := (QRYNFS)->A2_EST
          TRBSF2->A2_NREDUZ  := (QRYNFS)->A2_NREDUZ
          TRBSF2->F2_I_NDFSE := (QRYNFS)->F2_I_NDFSE
          TRBSF2->F2_I_FRET  := (QRYNFS)->F2_I_FRET
          TRBSF2->F2_VALMERC := (QRYNFS)->F2_VALMERC
          TRBSF2->F2_VALBRUT := (QRYNFS)->F2_VALBRUT
          TRBSF2->F2_I_CTRA  := (QRYNFS)->TRANSP
          TRBSF2->F2_I_LTRA  := (QRYNFS)->LOJATRANSP
          TRBSF2->WK_SEGURO  := (QRYNFS)->F2_VALBRUT * _nPSeguro
          TRBSF2->WK_PERSEGU := _nPSeguro * 100
          TRBSF2->WK_RECNO   := StrZero( TRBF->(Recno()) ,10) // Grava o Recno da tabela TRBF
          TRBSF2->WK_RECSF2  := StrZero((QRYNFS)->SF2_REC,10) 
          //TRBSF2->(MsUnLock())
   
          //=========================================================================
          //If MV_PAR06 == 1 // Emitidos  
          //   If QRYNFS->F2_I_GERTS <> "N"
          //      _nQtdNfs    += 1
          //      _nTotSeguro += (QRYNFS->F2_VALBRUT * _nPSeguro)
          //   EndIf
          //EndIf
          //=========================================================================
          
       //   QRYNFS->(DbSkip())
       //EndDo
       //If MV_PAR06 == 1 // Emitidos
       //   TRBF->(RecLock("TRBF",.F.))
       //   TRBF->QTDENF := _nQtdNfs
       //   TRBF->SEGURO := _nTotSeguro 
       //   TRBF->(MsUnLock())
       //EndIf

   //Next

   //_nTotRegs := Len(_aTRBF)  
   //For _nI := 1 To _nTotRegs
   //    _oProc:cCaption := ("Atualizando Dados Tela Principal... "+AllTrim(Str(_nI,10)) + "/" + AllTrim(Str(_nTotRegs,10))+"...")
   //    ProcessMessages()
   //    TRBF->(DbGoTo(_aTRBF[_nI,15]))
   //    If _aTRBF[_nI,10] <> TRBF->QTDENF 
   //       _aTRBF[_nI,10] := TRBF->QTDENF 
   //       _aTRBF[_nI,13] := TRBF->SEGURO
   //    EndIf  
   //Next  
   
End Sequence

//If Select("QRYNFS") > 0
//	QRYNFS->(DBCLOSEAREA())
//EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS114R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 02/06/2021
===============================================================================================================================
Descrição---------: Permite selecionar as notas fiscais que serão utilizadas na geração dos titulos de seguro.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS114R()
//Local _oPanelSF2		:= Nil
//Local _oDlgNfs			:= Nil
Local _nHeight		:= 0
Local _nWidth		:= 0
Local _aSize			:= {}
Local _aBotoes		:= {}

Local _nOpca  := 0
Local _cChavePesq 

Private _oMark	
Private _oQtdNfs
Private _oValorSeg
Private _aNotas := {}
Private _nQtdNfs, _nValSegNf
Private _oPanelSF2
Private _oDlgNfs

Begin Sequence 
   //=================================================================
   // Carrega os dados das notas fiscais no array _aNotas.
   //=================================================================
   _nQtdNfs := 0
   _nValSegNf := 0

   TRBSF2->(DbSetOrder(1))
   _cChavePesq := StrZero(_aTRBF[oMark:NAT,15],10)
   TRBSF2->(MsSeek(_cChavePesq))
   Do While ! TRBSF2->(Eof()) .And. _cChavePesq == TRBSF2->WK_RECNO
      Aadd(_aNotas,{TRBSF2->WK_OK,;                                // 1
                    TRBSF2->F2_FILIAL,;                            // 2
                    TRBSF2->F2_DOC,;                               // 3
                    TRBSF2->F2_SERIE,;                             // 4
                    TRBSF2->F2_EMISSAO,;                           // 5
                    If(TRBSF2->A2_I_AVERB=="1","Sim","Não"),;      // 6
                    TRBSF2->A2_COD,;                               // 7
                    TRBSF2->A2_LOJA,;                              // 8
                    TRBSF2->A2_NREDUZ,;                            // 9  
                    TRBSF2->A2_EST,;                               // 10
                    TRBSF2->F2_I_NDFSE,;                           // 11
                    TRBSF2->F2_VALMERC,;                           // 12
                    TRBSF2->F2_I_FRET,;                            // 13
                    TRBSF2->F2_VALBRUT,;                           // 14
                    TRBSF2->F2_I_CTRA,;                            // 15  
                    TRBSF2->F2_I_LTRA,;                            // 16
                    TRBSF2->WK_PERSEGU,; // "% seguro "            // 17  
                    TRBSF2->WK_SEGURO,;  // "Valor do Seguro"      // 18
                    TRBSF2->WK_RECNO,;                             // 19 
                    TRBSF2->(Recno())})                            // 20

      If ! Empty(TRBSF2->WK_OK)              
         _nQtdNfs += 1
         _nValSegNf += TRBSF2->WK_SEGURO
      EndIf 
      TRBSF2->(DbSkip())
   EndDo 
   
   _nValSegNf := Round(_nValSegNf,2)

   //=================================================================
   // Botoes da tela.
   //=================================================================
   Aadd( _aBotoes , { "" , {|| U_AOMS114M("T") }   , "" , "Marca/Desmarca Todos"} )

   //=================================================================
   // Faz o calculo automatico de dimensoes da tela do computador
   //=================================================================
   _aSize := MSADVSIZE() 

   _nOpca:= 2
   DEFINE MSDIALOG _oDlgNfs TITLE "Seleção de Notas para Geração dos Títulos" From 0,0 To _aSize[6],_aSize[5] PIXEL

	_oPanelSF2:= TPanel():New(30,0,'',_oDlgNfs,, .T., .T.,, ,315,20,.T.,.T. )
	oFont := TFont():New('Times New Roman',,-16,.T.)

	_nCol:=005
	_nSize:=60
	_nPula:=70
   
   @ 003,_nCol BUTTON "Marca/Desmarca Todos" SIZE _nSize, 015 PIXEL OF _oPanelSF2 ACTION (U_AOMS114M("T"))
   _nCol+=_nPula

   _oQtdNfs := TSay():New(05,_nCol,{||'Qtde Notas: '+ALLTRIM(TRANSFORM(_nQtdNfs,"@E 99,999,999,999"))},_oPanelSF2,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)//450
	_nCol+=_nPula

	_oValorSeg := TSay():New(05,_nCol,{||'Valor seguro: '+ALLTRIM(TRANSFORM(_nValSegNf,"@E 999,999,999.99"))},_oPanelSF2,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)//550
	
	If FlatMode()
		aCoors	:= GetScreenRes()
		_nHeight	:= aCoors[2]
		_nWidth	:= aCoors[1]
	Else
		_nHeight	:= 143
		_nWidth	:= 315
	Endif

  //TCBrowse():New( [ nRow ], [ nCol ], [ _nWidth ], [ _nHeight ], [ bLine ], [ aHeaders ], [ aColSizes ], [ oWnd ], [ cField ], [ uValue1 ], [ uValue2 ], [ bChange ], [ bLDblClick ]  , [ bRClick ], [ oFont ], [ oCursor ], [ nClrFore ], [ nClrBack ], [ cMsg ], [ uParam20 ], [ cAlias ], [ lPixel ], [ bWhen ], [ uParam24 ], [ bValid ], [ lHScroll ], [ lVScroll ] )
	_oMark := TCBrowse():New(35,  01   , 35+_nHeight, 01+_nWidth  ,          ,             ,              , _oDlgNfs   ,           ,            ,            ,            ,                 ,            ,          ,            ,             ,             ,         ,    .F.      ,           ,   .T.     ,          ,    .F.      ,           ,             ,              )

	_oMark:SetArray(_aNotas)
	_oMark:bLDblClick   := {|| U_AOMS114M("P")}
	
	_oMark:AddColumn(TCColumn():New(" "       	   	 ,{|| LoadBitmap(GetResources(), IF(LEN(_aNotas)>0,IF(_aNotas[_oMark:nat,01]==_cMarca,"LBOK","LBNO"),"LBNO") ) },,,,,,.T.,.F.,,,,.F., ) )
  	_oMark:AddColumn(TCColumn():New("Filial"            ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,02], ' ') },"@!"       			  ,,,"LEFT" ,010,.F.,.F.,,,,,))
	_oMark:AddColumn(TCColumn():New("Nota Fiscal"		 ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,03], ' ') },"@!"       			  ,,,"LEFT" ,20,.F.,.F.,,,,,))
	_oMark:AddColumn(TCColumn():New("Serie"		       ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,04], ' ') },"@!"       			  ,,,"LEFT" ,6,.F.,.F.,,,,,))
	_oMark:AddColumn(TCColumn():New("Emissão"		       ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,05], ' ') },"@D"       			  ,,,"CENTER" ,10,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("Averbação"		    ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,06], ' ') },"@!"       			  ,,,"LEFT" ,10,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("Fornecedor"		    ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,07], ' ') },"@!"       			  ,,,"LEFT" ,10,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("Loja Forn."		    ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,08], ' ') },"@!"       			  ,,,"LEFT" ,10,.F.,.F.,,,,,))
	_oMark:AddColumn(TCColumn():New("Nome"		          ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,09], ' ') },"@!"       			  ,,,"LEFT" ,20,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("Estado"		       ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,10], ' ') },"@!"       			  ,,,"LEFT" ,6,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("Nota Fiscal Seguro",{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,11], ' ') },"@!"       			  ,,,"LEFT" ,30,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("Valor Mercadoria"	 ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,12], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("Frete" 				 ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,13], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
	_oMark:AddColumn(TCColumn():New("Valor Bruto" 		 ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,14], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
   _oMark:AddColumn(TCColumn():New("% Seguro" 			 ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,17], ' ') },"@E 99,999,999,999.999",,,"RIGHT",050,.F.,.F.,,,,,))
	_oMark:AddColumn(TCColumn():New("Seguro" 			    ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,18], ' ') },"@E 999,999,999,999.99",,,"RIGHT",050,.F.,.F.,,,,,))
	//_oMark:AddColumn(TCColumn():New("Recno"      		 ,{|| if(len(_aNotas)>0,_aNotas[_oMark:nat,19], ' ') },"@E 99999999999"       ,,,"CENTER",050,.F.,.F.,,,,,))
	
	_oDlgNfs:lMaximized:=.T.

   Activate MSDIALOG _oDlgNfs ON INIT ( EnchoiceBar(_oDlgNfs,{|| If(U_AOMS114V(),(_nOpca:= 1,_oDlgNfs:End()),_nOpca:= 2) },;
                                                       {|| _nOpca:= 2,_oDlgNfs:End() },,_aBotoes),;
                                     _oPanelSF2:Align:=CONTROL_ALIGN_TOP ,;
                                     _oMark:Align:=CONTROL_ALIGN_ALLCLIENT ,;
                                     _oMark:Refresh())
    If _nOpca = 1
       nValTit-=TRBF->SEGURO//Tira o valor ANTERIOR
       
       TRBF->(DbGoTo(_aTRBF[oMark:NAT,15]))
       TRBF->(RecLock("TRBF",.F.))
       TRBF->QTDENF := _nQtdNfs
       TRBF->SEGURO := _nValSegNf
       TRBF->(MsUnLock())
       
       nValTit+=TRBF->SEGURO//Coloca o valor ATUAL

       _aTRBF[oMark:NAT,10] := _nQtdNfs 
       _aTRBF[oMark:NAT,13] := _nValSegNf
    EndIf

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS114R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 02/06/2021
===============================================================================================================================
Descrição---------: Marca e desmar itens. Posicionado ou todos.
===============================================================================================================================
Parametros--------: _cTipoMarca = "P" = Marca e desmarca apenas o Item posicionado.
                                  "T" = Marca e desmarca todos os itens.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS114M(_cTipoMarca)
Local _nI 
Local _lMarcar := .T.
Local _cMarkSF2 
Local _nItens, _nTotSegur

Begin Sequence 
   //=================================================
   // Marca/desmarca apenas o item posicionado.
   //=================================================
   If _cTipoMarca == "P"
      If Empty(_aNotas[_oMark:nat,01])
         TRBSF2->(DbGoTo(_aNotas[_oMark:nat,20]))
         TRBSF2->(RecLock("TRBSF2",.F.))
         TRBSF2->WK_OK :=_cMarca                     
         TRBSF2->(MsUnLock())
         _aNotas[_oMark:nat,01] := _cMarca
		Else
         TRBSF2->(DbGoTo(_aNotas[_oMark:nat,20]))
         TRBSF2->(RecLock("TRBSF2",.F.))
         TRBSF2->WK_OK := Space(2)                     
         TRBSF2->(MsUnLock())
         _aNotas[_oMark:nat,01] := Space(2)
      EndIf 
   Else
      //=================================================
      // Marca/desmarca todos os itens
      //=================================================
      For _nI := 1 To Len(_aNotas)
          If ! Empty(_aNotas[_nI,01])  
             _lMarcar := .F.
          EndIf 
      Next 
      
      If _lMarcar
         _cMarkSF2 := _cMarca 
      Else  
         _cMarkSF2 := Space(2)
      EndIf 

      For _nI := 1 To Len(_aNotas)
          TRBSF2->(DbGoTo(_aNotas[_nI,20]))
          TRBSF2->(RecLock("TRBSF2",.F.))
          TRBSF2->WK_OK := _cMarkSF2
          TRBSF2->(MsUnLock())
          _aNotas[_nI,01] := _cMarkSF2
      Next 

   EndIf 
   
   _nItens := 0
   _nTotSegur := 0

   For _nI := 1 To Len(_aNotas)
       If ! Empty(_aNotas[_nI,01])
          _nItens += 1
          _nTotSegur += _aNotas[_nI,18] 
       EndIf 
   Next 

   _nQtdNfs := _nItens 
   _oQtdNfs:SetText('Qtde Notas: '+ALLTRIM(TRANSFORM(_nQtdNfs,"@E 99,999,999,999")))
   _oQtdNfs:CtrlRefresh()
   
   _nValSegNf := _nTotSegur
   _oValorSeg:SetText('Valor seguro: '+ALLTRIM(TRANSFORM(_nValSegNf,"@E 999,999,999.99")))
   _oValorSeg:CtrlRefresh()

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS114V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 02/06/2021
===============================================================================================================================
Descrição---------: Valida a Gravação do valor das notas selecionadas para geração de titulos de seguros.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet = .T. validação correta.
                            .F. Problema encontrados na validação.
===============================================================================================================================
*/
User Function AOMS114V()
Local _lRet := .T.
Local _nI, _lTemNf 

Begin Sequence
    If ! U_ITMSG("Confirma a atualização dos valores de titulos de seguros a serem gerados, com base no valor do seguro das notas fiscais selecionadas?",;
               "Atenção", , ,2, 2)
       _lRet := .F.
       Break
    EndIf 
    
    _lTemNf := .F.
    For _nI := 1 To Len(_aNotas)
        If ! Empty(_aNotas[_nI,01])
           _lTemNf := .T.
           Exit 
        EndIf 
    Next 

    If ! _lTemNf  
       U_ITMSG("Nenhuma nota fiscal foi selecionada.","Atenção","Selecione pelo menos uma nota fiscal, ou desmarque a geração de tiluos para esta transportadora.",1) 
       _lRet := .F.
       Break
    EndIf

    //If _aTRBF[oMark:NAT,10] == _nQtdNfs // Tirei pq pode ser desmacado um e marcado outro
    //   U_ITMSG("Nenhuma alteração foi realizada. O numero de notas fiscais selecionadas continua o mesmo.","Atenção",,1) 
    //   _lRet := .F.
    //EndIf 

End Sequence

Return _lRet 
