/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: RGLT071
Autor-------------: Alex Wallauer
Data da Criacao---: 16/03/2022
===============================================================================================================================
Descrição---------: Relatório de Aprovações dos Pedidos de Compras . Chamado 39218
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT071()//U_RGLT071 

Local _cTitulo := "Relatório de Aprovações dos Pedidos de Compras" 
Local _aDados	 := {}
Local oproc    := nil
Local nI	:= C := 0 
Local _aParRet := {}
Local _aParAux := {}

_cSelecSC7 :="SELECT DISTINCT C7_NUM   , C7_EMISSAO FROM "+RETSQLNAME("SC7")+" SC7 WHERE D_E_L_E_T_ <> '*' AND C7_FILIAL = '"+xFilial("SC7")+"' ORDER BY C7_NUM " //AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' 
_cSelSA2   :="SELECT A2_COD,A2_LOJA,A2_NREDUZ FROM "+RETSQLNAME("SA2")+" SA2 WHERE SUBSTR(A2_COD,1,1) IN ('P','G','L') AND D_E_L_E_T_ <> '*' ORDER BY A2_COD, A2_LOJA "
_cSelectSB1:="SELECT B1_COD , B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ <> '*' AND B1_TIPO = 'MP' ORDER BY B1_COD "
_cSelectSAK:="SELECT AK_COD , AK_NOME FROM "+RETSQLNAME("SAK")+" SAK WHERE D_E_L_E_T_ <> '*' AND AK_MSBLQL <> '1' ORDER BY AK_NOME "

_aItalac_F3:={}//       1           2         3                      4                      5          6                      7         8          9         10         11        12
//  (_aItalac_F3,{"CPOCAMPO",_cTabela   ,_nCpoChave            , _nCpoDesc               ,_bCondTab   , _cTitAux           , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03",_cSelecSC7 ,{|Tab| (Tab)->C7_NUM }, {|Tab|DTOC(STOD((Tab)->C7_EMISSAO))},,"Pedidos"           ,          ,          ,          ,.F.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR04",_cSelSA2   ,{|Tab|(Tab)->A2_COD+(Tab)->A2_LOJA},{|Tab| (Tab)->A2_NREDUZ},,"Fornecedores"      ,          ,          ,          ,.F.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR05",_cSelectSB1,{|Tab|(Tab)->B1_COD},{|Tab|(Tab)->B1_DESC}                  ,,"Produtos Tipo = MP",          ,          ,          ,.F.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR09",_cSelectSAK,{|Tab|(Tab)->AK_COD},{|Tab|(Tab)->AK_NOME}                  ,,"Aprovadores"       ,          ,          ,          ,.F.        ,       , } )

MV_PAR01:=dDataBase
MV_PAR02:=dDataBase
MV_PAR03:=SPACE(200)
MV_PAR04:=SPACE(200)
MV_PAR05:=SPACE(200)

_aStatus:={"1-Todos            ",;
           "2-Abertos          ",;
		       "3-Parciais         ",;
		       "4-Paciais + Abertos",;
		       "5-Encerrados       "}
_aFretes:={"1-Todos    ",;
           "2-CIF      ",;
		     "3-FOB      ",;
           "4-Terceiros",;
           "5-Sem Frete"}
_aGordur:={"1-Ambos",;
           "2-Sim  ",;
		     "3-Nao  "}
_aCFretes:={"1-Por Qtde Entregue",;
            "2-Por Quantidade   "}           

MV_PAR06:=_aStatus[1]
MV_PAR07:=_aGordur[1]
MV_PAR08:=_aFretes[1]
MV_PAR09:=SPACE(200)
MV_PAR10:=SPACE(200)
MV_PAR11:=_aCFretes[1]

_aParAux:={}
AADD( _aParAux , { 1 , "Data de"	     , MV_PAR01, "@D"	 , ""	, ""		   , "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Data ate"	  , MV_PAR02, "@D"	 , ""	, ""		   , "" , 050 , .F. } )
aAdd( _aParAux , { 1 , "Pedidos"	     , MV_PAR03, "@!"    , ""	, 'F3ITLC'	, "" , 100 , .F. } )
aAdd( _aParAux , { 1 , "Fornecedor"	  , MV_PAR04, "@!"    , ""	, 'F3ITLC'	, "" , 100 , .F. } )
aAdd( _aParAux , { 1 , "Produtos"     , MV_PAR05, "@!"    , ""	, 'F3ITLC'	, "" , 100 , .F. } )
AADD( _aParAux , { 2 , "Status"       , MV_PAR06, _aStatus ,50 ,".T.",.T.,".T."}) 
AADD( _aParAux , { 2 , "PC C/ Gordura", MV_PAR07, _aGordur ,50 ,".T.",.T.,".T."}) 
AADD( _aParAux , { 2 , "Frete"        , MV_PAR08, _aFretes ,50 ,".T.",.T.,".T."}) 
aAdd( _aParAux , { 1 , "Aprovadores"  , MV_PAR09, "@!"     , "", 'F3ITLC'  , "" , 100 , .F. } )//'SAK'
aAdd( _aParAux , { 1 , "Filiais"      , MV_PAR10, "@!"     , "", 'LSTFIL'  , "" , 100 , .F. } )
AADD( _aParAux , { 2 , "Calculo Frete", MV_PAR11, _aCFretes,50 ,".T.",.T.,".T."}) 

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

     //ParamBox( _aParAux , cTitle                                 , @aRet     ,[bOk]    , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
   IF !ParamBox( _aParAux , "Digite os filtros dos dados do Leite" , @_aParRet ,{||.T.}  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
       EXIT
   EndIf

   IF !EMPTY(MV_PAR01) .AND.  !EMPTY(MV_PAR02) .AND.  MV_PAR01 > MV_PAR02
      U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo com as 2 datas preenchidas",3)
      LOOP
   ENDIF
   //Log de utilização
   U_ITLOGACS()

   _aDados  := {}
   _lSair   := .F.
   cTimeInicial:=TIME()
   _nSalvaTotalCol:=0

   FWMSGRUN( ,{|oproc| _aDados := RGLT071SEL(oproc) } , "Aguarde!" , "Hora Inicial: "+cTimeInicial+", Lendo de "+DTOC(MV_PAR01)+" Ate "+DTOC(MV_PAR02) )

    IF LEN(_aDados) > 0

        aCab:={}
        AADD(aCab,"Filial")
        AADD(aCab,"Código Forn.")
        AADD(aCab,"Nome fornecedor")	
        AADD(aCab,"Numero PC")	
        AADD(aCab,"Data de Emissão")	
        AADD(aCab,"Data Faturado")	
        AADD(aCab,"Produto")	
        AADD(aCab,"Volume programado")	
        AADD(aCab,"Volume entregue")	
        AADD(aCab,"Preço unitário")	
        AADD(aCab,"Aliq. ICMS")	
        AADD(aCab,"Pagto Gord. Mínima")	
        AADD(aCab,"Gordura")	
        AADD(aCab,"Frete")	
        AADD(aCab,"Frete p/ Lt")
        _nSalvaTotalCol:=_nSalvaTotalCol-LEN(aCab)
        FOR C := 1 TO  _nSalvaTotalCol
            AADD(aCab,"Data e hora da aprovação "+STRZERO(C,2))
        NEXT
        _cConfere:=STRZERO(LEN(aCab),2)
        //MsgInfo(_cConfere, "Conferencia")

        _cTitulo2:=_cTitulo+' - Data: ' + DtoC(Date()) +" - Hora: "+TIME()
        _cMsgTop:="Par. 1: "+ALLTRIM(AllToChar(MV_PAR01))+"; Par. 2: "+ALLTRIM(AllToChar(MV_PAR02))+"; Par. 3: "+ALLTRIM(AllToChar(MV_PAR03))+"; Par. 4: "+ALLTRIM(AllToChar(MV_PAR04))+;
                "; Par. 5: "+ALLTRIM(AllToChar(MV_PAR05))+"; Par. 6: "+ALLTRIM(AllToChar(MV_PAR06))+"; Par. 7: "+ALLTRIM(AllToChar(MV_PAR06))+"; Par. 8: "+ALLTRIM(AllToChar(MV_PAR08))+;
                "; Par. 9: "+ALLTRIM(AllToChar(MV_PAR09))+"; Par.10: "+ALLTRIM(AllToChar(MV_PAR10))+" -  H.I.: "+cTimeInicial+" H.F.: "+TIME()

                                //        ,_aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca )
       _lSair:=!U_ITListBox(_cTitulo2,aCab,_aDados , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        ,          ,       ,         ,          ,            )
    
    ELSE
      
      U_ITMSG("Não á registro para esses filtros",'Atenção!',"Tente novamente com outros filtros",3)
      
      LOOP
    
    ENDIF

ENDDO

Return Nil


/*
===============================================================================================================================
Programa----------: RGLT071SEL
Autor-------------: Alex Wallauer
Data da Criacao---: 16/03/2022
===============================================================================================================================
Descrição---------: Carga de dados para o relatório
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processmento 
===============================================================================================================================
Retorno-----------: _aret - dados coletados do banco
===============================================================================================================================
*/
Static Function RGLT071SEL(oproc)
Local _aRet		:= {} , C
Local _cQuery	:= "" , D
Local _cC7_I_QTORI:=GetSX3Cache("C7_I_QTORI","X3_PICTURE")
Local _cC7_QUJE  	:=GetSX3Cache("C7_QUJE"   ,"X3_PICTURE")
Local _cC7_PRECO 	:=GetSX3Cache("C7_PRECO"  ,"X3_PICTURE")
Local _cC7_PICM	:=GetSX3Cache("C7_PICM"   ,"X3_PICTURE")
Local _cC7_L_PMGB	:=GetSX3Cache("C7_L_PMGB" ,"X3_PICTURE")
Local _cC7_L_EXEMG:=GetSX3Cache("C7_L_EXEMG","X3_PICTURE")
Local _cC7_VALFRE :=GetSX3Cache("C7_VALFRE" ,"X3_PICTURE")
Local _cAlias	   :=GetNextAlias()


_cQuery := " SELECT "
_cQuery += " R_E_C_N_O_ RECNO  "	  
_cQuery += " FROM "+ RetSqlName("SC7") +" SC7 "+ CRLF
_cQuery += " WHERE SC7.C7_FILIAL = '" + cFilAnt + "' AND SC7.D_E_L_E_T_ = ' '  "

If !Empty(MV_PAR01)
	_cQuery += " AND C7_EMISSAO >= '"+DTOS(MV_PAR01)+"' "
EndIf
If !Empty(MV_PAR02)
	_cQuery += " AND C7_EMISSAO <= '"+DTOS(MV_PAR02)+"' "
EndIf
If !Empty(MV_PAR03)
	_cQuery += " AND C7_NUM IN "+FormatIn(ALLTRIM(MV_PAR03),";")
EndIf
If !Empty(MV_PAR04)
	_cQuery += " AND C7_FORNECE||C7_LOJA IN "+FormatIn(ALLTRIM(MV_PAR04),";")
EndIf
If !Empty(MV_PAR05)
	_cQuery += " AND C7_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR05),";")
EndIf

IF MV_PAR06 = "2"     // ABERTOS
	_cQuery += "AND C7_QUJE = '0' AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' "		
ELSEIF MV_PAR06 = "3" // PARCIAL
	_cQuery += "AND C7_QUJE < C7_QUANT AND C7_QUJE >  '0' AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' "	
ElseIf MV_PAR06 = "4" // PARCIAL + ABERTOS
	_cQuery += "AND C7_QUJE < C7_QUANT AND C7_QUJE >= '0' AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' "
ElseIf MV_PAR06 = "5" // ENCERRADO
	_cQuery += "AND (C7_ENCER = 'E' OR C7_RESIDUO = 'S') "	
Endif

IF MV_PAR07 = "2"     // PC C/ Gordura ? SIM
	_cQuery += "AND C7_L_PMGB <> 0  "		
ELSEIF MV_PAR07 = "3" // PC C/ Gordura ? NAO
	_cQuery += "AND C7_L_PMGB = 0  "	
Endif

IF MV_PAR08 = "2"     // CIF 
	_cQuery += "AND C7_TPFRETE = 'C'  "		
ELSEIF MV_PAR08 = "3" // FOB
	_cQuery += "AND C7_TPFRETE = 'F'  "	
ELSEIF MV_PAR08 = "4" // TERCEIROS
  _cQuery += "AND C7_TPFRETE = 'T' "	
ELSEIF MV_PAR08 = "5" // SEM FRETE
	_cQuery += "AND C7_TPFRETE = 'S' "	
Endif

IF !EMPTY(MV_PAR09)
   _cQuery += "AND EXISTS (SELECT 'Y' FROM "+RetSqlName("SCR")+" SCR "
   _cQuery += "             WHERE SC7.C7_FILIAL = SCR.CR_FILIAL AND SC7.C7_NUM = TRIM(SCR.CR_NUM) AND SCR.CR_TIPO = 'PC' AND SCR.D_E_L_E_T_ = ' ' AND "
   _cQuery += "                   SCR.CR_APROV IN "+FormatIn(ALLTRIM(MV_PAR09),";")+" )"
ENDIF

If !Empty(MV_PAR10)
	_cQuery += " AND C7_FILIAL IN "+FormatIn(ALLTRIM(MV_PAR10),";")
EndIf

_cQuery += " ORDER BY C7_NUM "	

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
_cTot := 0
COUNT TO  _cTot
_cTot:=ALLTRIM(STR(_cTot))
_nTam:=LEN(_cTot)

SCR->(DBSETORDER(1))

(_cAlias)->( DBGoTop() )
_nni := 0
 _nSalvaTotalCol:=0

Do while (_cAlias)->( !Eof() )
  _nTotalCol:=0
	_nni++
	oproc:cCaption := ("Lendo registro: " +STRZERO(_nni,_nTam) +" de "+ _cTot )
	ProcessMessages()
  SC7->( DBGOTO((_cAlias)->RECNO) )
  aItem:={}
  AADD(aItem,SC7->C7_FILIAL)
  AADD(aItem,SC7->C7_FORNECE+"-"+SC7->C7_LOJA)
  AADD(aItem,POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA, "A2_NREDUZ"))
  AADD(aItem,SC7->C7_NUM)
  AADD(aItem,DTOC(SC7->C7_EMISSAO))
  AADD(aItem,DTOC(SC7->C7_I_DTFAT))
  AADD(aItem,SC7->C7_PRODUTO)
  //AADD(aItem,Posicione("SB1",1,Xfilial("SB1")+SC7->C7_PRODUTO,"B1_DESC"))
  AADD(aItem,TRANS(IF(EMPTY(SC7->C7_I_QTORI),SC7->C7_QUANT,SC7->C7_I_QTORI),_cC7_I_QTORI))
  AADD(aItem,TRANS(SC7->C7_QUJE,_cC7_QUJE))
  AADD(aItem,TRANS(SC7->C7_PRECO,_cC7_PRECO))
  AADD(aItem,TRANS(SC7->C7_PICM,_cC7_PICM))
  AADD(aItem,TRANS(SC7->C7_L_PMGB,_cC7_L_PMGB))
  AADD(aItem,TRANS(SC7->C7_L_EXEMG,_cC7_L_EXEMG))
  IF MV_PAR11 = "1"//entrega
     _nQtde:=SC7->C7_QUJE
  ELSE
     _nQtde:=IF(EMPTY(SC7->C7_I_QTORI),SC7->C7_QUANT,SC7->C7_I_QTORI)//SC7->C7_QUANT
  ENDIF
  IF SC7->C7_TPFRETE = 'F'//FOB
     AADD(aItem,TRANS(SC7->C7_FRETCON,_cC7_VALFRE))
     AADD(aItem,TRANS((SC7->C7_FRETCON /_nQtde),_cC7_VALFRE))
  ELSE//IF SC7->C7_TPFRETE = 'C'//CIF
     AADD(aItem,TRANS(SC7->C7_FRETE ,_cC7_VALFRE))
     AADD(aItem,TRANS((SC7->C7_FRETE /_nQtde),_cC7_VALFRE))
  ENDIF

  IF SCR->(dbSeek(SC7->C7_FILIAL + "PC" + SC7->C7_NUM))
	   DO While !SCR->(Eof()) .AND. SCR->CR_FILIAL == SC7->C7_FILIAL .And. SCR->CR_TIPO == "PC" .And. ALLTRIM(SCR->CR_NUM) == ALLTRIM(SC7->C7_NUM)
        //IF !EMPTY(MV_PAR09) .AND. !SCR->CR_APROV $ ALLTRIM(MV_PAR09)
        //   SCR->(DBSKIP())      
        //   Loop
        //ENDIF
        AADD(aItem,	DTOC(SCR->CR_DATALIB)+" - "+SCR->CR_I_HRAPR+" - "+ALLTRIM(POSICIONE("SAK",1,xfilial("SAK")+SCR->CR_APROV,"AK_NOME"))+" ("+SCR->CR_NIVEL+")")
        SCR->(DBSKIP())
	   Enddo
  ENDIF
  _nTotalCol:=LEN(aItem)
  IF _nTotalCol > _nSalvaTotalCol
     _nSalvaTotalCol:=_nTotalCol
  ENDIF
  
  AADD(_aRet,aItem)
  (_cAlias)->(Dbskip())
Enddo

_aRetAux:={}
_cConfere:=STRZERO(_nSalvaTotalCol,2)+" ** "
FOR C := 1 TO LEN(_aRet)
    _cConfere+=STRZERO(LEN(_aRet[C]),2)+"=>"
    FOR D := LEN(_aRet[C]) TO (_nSalvaTotalCol-1)
       AADD(_aRet[C],"")
    NEXT  
    AADD(_aRetAux,_aRet[C])
    _cConfere+=STRZERO(LEN(_aRet[C]),2)+" / " 
NEXT

//MsgInfo(_cConfere, "Conferencia")

Return( _aRetAux )

