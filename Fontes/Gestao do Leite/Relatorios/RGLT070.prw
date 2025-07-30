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
Programa----------: RGLT070
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2022
===============================================================================================================================
Descrição---------: Relatório de Programado X Realizado leite de terceiros . Chamado 39218
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT070()//U_RGLT070 

Local _cTitulo := "Relatório Programado X Realizado leite de terceiros" 
Local _aDados	:= {}
Local oproc    := nil
Local nI		   := 0 
Local _aParRet	:= {}
Local _aParAux := {}

_cSelecSC7 :="SELECT DISTINCT C7_NUM   , C7_EMISSAO FROM "+RETSQLNAME("SC7")+" SC7 WHERE D_E_L_E_T_ <> '*' AND C7_FILIAL = '"+xFilial("SC7")+"' ORDER BY C7_NUM " //AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' 
_cSelSA2   :="SELECT A2_COD,A2_LOJA,A2_NREDUZ FROM "+RETSQLNAME("SA2")+" SA2 WHERE SUBSTR(A2_COD,1,1) IN ('P','G','L') AND D_E_L_E_T_ <> '*' ORDER BY A2_COD, A2_LOJA "
_cSelectSB1:="SELECT B1_COD , B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ <> '*' AND B1_TIPO = 'MP' ORDER BY B1_COD "

_aItalac_F3:={}//       1           2         3                      4                      5          6                      7         8          9         10         11        12
//  (_aItalac_F3,{"CPOCAMPO",_cTabela   ,_nCpoChave            , _nCpoDesc               ,_bCondTab   , _cTitAux           , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03",_cSelecSC7 ,{|Tab| (Tab)->C7_NUM }, {|Tab|DTOC(STOD((Tab)->C7_EMISSAO))},,"Pedidos"           ,          ,          ,          ,.F.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR04",_cSelSA2   ,{|Tab|(Tab)->A2_COD+(Tab)->A2_LOJA},{|Tab| (Tab)->A2_NREDUZ},,"Fornecedores"      ,          ,          ,          ,.F.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR05",_cSelectSB1,{|Tab|(Tab)->B1_COD},{|Tab|(Tab)->B1_DESC}                  ,,"Produtos Tipo = MP",          ,          ,          ,.F.        ,       , } )

MV_PAR01:=dDataBase
MV_PAR02:=dDataBase
MV_PAR03:=SPACE(200)
MV_PAR04:=SPACE(200)
MV_PAR05:=SPACE(200)
MV_PAR06:=1

_aStatus:={"Todos            ",;
           "Abertos          ",;
		   "Parciais         ",;
		   "Paciais + Abertos",;
		   "Encerrados       "}
 
_aParAux:={}
AADD( _aParAux , { 1 , "Data de"	  , MV_PAR01, "@D"	, ""	, ""		, "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Data ate"	  , MV_PAR02, "@D"	, ""	, ""		, "" , 050 , .F. } )
aAdd( _aParAux , { 1 , "Pedidos"	  , MV_PAR03, "@!"    , ""	, 'F3ITLC'	, "" , 100 , .F. } )
aAdd( _aParAux , { 1 , "Fornecedor"	  , MV_PAR04, "@!"    , ""	, 'F3ITLC'	, "" , 100 , .F. } )
aAdd( _aParAux , { 1 , "Produtos"     , MV_PAR05, "@!"    , ""	, 'F3ITLC'	, "" , 100 , .F. } )
AADD( _aParAux , { 3 , "Status"       , MV_PAR06, _aStatus,100          , "", .T., .T. , .T. } )

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


   FWMSGRUN( ,{|oproc| _aDados := RGLT070SEL(oproc) } , "Aguarde!" , "Lendo dados..." )

    IF LEN(_aDados) > 0

        aCab:={}
        AADD(aCab,"Pedido")
        AADD(aCab,"Dt Emissao")
        AADD(aCab,"Cod. Fornecedor")
        AADD(aCab,"Nome Fornecedor")
        AADD(aCab,"Cod. Produto")
        AADD(aCab,"Nome Produto")
        AADD(aCab,"Quant Prevista")
        AADD(aCab,"Quant Realizada")
        AADD(aCab,"Diferença")

        _cTitulo2:=_cTitulo+' - Data: ' + DtoC(Date()) 
        _cMsgTop:="Par. 1: "+ALLTRIM(AllToChar(MV_PAR01))+"; Par. 2: "+ALLTRIM(AllToChar(MV_PAR02))+"; Par. 3: "+ALLTRIM(AllToChar(MV_PAR03))+"; Par. 4: "+ALLTRIM(AllToChar(MV_PAR04))+;
                "; Par. 5: "+ALLTRIM(AllToChar(MV_PAR05))+"; Par. 6: "+ALLTRIM(AllToChar(MV_PAR06))+" -  H.I.: "+cTimeInicial+" H.F.: "+TIME()

                                //        ,_aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca )
       _lSair:=!U_ITListBox(_cTitulo2,aCab,_aDados , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        ,          ,       ,         ,          ,            )
    
    ELSE
      
      U_ITMSG("Não á registro para esses filtros",'Atenção!',"Tente novamente com outros filtros",3)
      
      LOOP
    
    ENDIF

   //IF _lSair
    //  EXIT
   //ENDIF   

ENDDO


Return Nil


/*
===============================================================================================================================
Programa----------: RGLT070SEL
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2022
===============================================================================================================================
Descrição---------: Carga de dados para o relatório
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processmento 
===============================================================================================================================
Retorno-----------: _aret - dados coletados do banco
===============================================================================================================================
*/
Static Function RGLT070SEL(oproc)
Local _aRet		:= {}
Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()

_cQuery := " SELECT "
_cQuery += " R_E_C_N_O_ RECNO  "	  
_cQuery += " FROM "+ RetSqlName("SC7") +" SC7 "+ CRLF
_cQuery += " WHERE SC7.C7_FILIAL = '" + cFilAnt + "' "
_cQuery += "   AND SC7.D_E_L_E_T_ = ' ' "

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

IF MV_PAR06 = 2     // ABERTOS
	_cQuery += "AND C7_QUJE = '0' AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' "		
ELSEIF MV_PAR06 = 3 // PARCIAL
	_cQuery += "AND C7_QUJE < C7_QUANT AND C7_QUJE >  '0' AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' "	
ElseIf MV_PAR06 = 4 // PARCIAL + ABERTOS
	_cQuery += "AND C7_QUJE < C7_QUANT AND C7_QUJE >= '0' AND C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' "
ElseIf MV_PAR06 = 5 // ENCERRADO
	_cQuery += "AND (C7_ENCER = 'E' OR C7_RESIDUO = 'S') "	
Endif

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
SPI->(DBSETORDER(2))

	(_cAlias)->( DBGoTop() )
	_nni := 0

	Do while (_cAlias)->( !Eof() )
		
		_nni++
		oproc:cCaption := ("Lendo registro: " +STRZERO(_nni,_nTam) +" de "+ _cTot )
		ProcessMessages()

      SC7->( DBGOTO((_cAlias)->RECNO) )
      aItem:={}
      AADD(aItem,SC7->C7_NUM)
      AADD(aItem,SC7->C7_EMISSAO)
      AADD(aItem,SC7->C7_FORNECE+SC7->C7_LOJA)
      AADD(aItem,POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA, "A2_NOME"))
      AADD(aItem,SC7->C7_PRODUTO)
      AADD(aItem,Posicione("SB1",1,Xfilial("SB1")+SC7->C7_PRODUTO,"B1_DESC"))
      AADD(aItem,TRANS(SC7->C7_I_QTORI,"@E 999,999,999,999.99"))
      AADD(aItem,TRANS(SC7->C7_QUJE,"@E 999,999,999,999.99"))
      AADD(aItem,TRANS(SC7->C7_I_QTORI-SC7->C7_QUJE,"@E 999,999,999,999.99"))
      AADD(_aRet,aItem)
      (_cAlias)->(Dbskip())
		
	Enddo


Return( _aRet )

