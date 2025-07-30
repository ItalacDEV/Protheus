/*
=====================================================================================================================================
        						 ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
   Autor     |	Data	 |										Motivo																
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges |23/07/25| Chamado 51340. Ajustar função para validação de ambiente de teste
=====================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
//#INCLUDE "PROTHEUS.CH"
//#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa----------: RFIN021
Autor-------------: Alex Wallauer
Data da Criacao---: 08/04/2022
===============================================================================================================================
Descrição---------: Conferencia de Titulos de Operação Triangula. CHAMADO 39671
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RFIN021()
Local _nI        := 0
Local _aParRet   := {}
Local _aParAux   := {}
Local _bOK       := {|| IF(MV_PAR06 >= MV_PAR05 .OR. MV_PAR05 > DATE(),.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo ate a data de hoje",3),.F.) ) }
Local _lRet      := .F.
Local _nTamNum	  := LEN(SE1->E1_NUM)
Local _nTamFor   := LEN(SA2->A2_COD)
Local _nTamLoja  := LEN(SA2->A2_LOJA)
PRIVATE _cTitulo := "Conferencia de Titulos de Operação Triangular"

MV_PAR01 := Space(200)
MV_PAR02 := Space(200)
MV_PAR03 := Space(_nTamNum)
MV_PAR04 := Space(_nTamNum)
MV_PAR05 := Ctod("")
MV_PAR06 := Ctod("")
MV_PAR07 := Space(_nTamFor)
MV_PAR08 := Space(_nTamLoja)
MV_PAR09 := Space(_nTamFor)
MV_PAR10 := Space(_nTamLoja)
MV_PAR11 := Space(_nTamFor)
MV_PAR12 := Space(_nTamLoja)
MV_PAR13 := Space(_nTamFor)
MV_PAR14 := Space(_nTamLoja)

MV_PAR15 := "2"

AADD( _aParAux , { 1 , "Filiais: "	               , MV_PAR01, ""	   , ""	, "LSTFIL"	, "" , 100        , .F. } )
AADD( _aParAux , { 1 , "Prefixos:   "        	   , MV_PAR02, ""	   , ""	, ""		   , "" , 100        , .F. } )
AADD( _aParAux , { 1 , "Numero de Título de: "	   , MV_PAR03, ""	   , ""	, ""		   , "" , 50         , .F. } )
AADD( _aParAux , { 1 , "Numero de Título até: "	   , MV_PAR04, ""	   , ""	, ""		   , "" , 50         , .F. } )
AADD( _aParAux , { 1 , "Emissão de"	               , MV_PAR05, "@D"	, ""  , ""	      , "" , 50         , .T. } )
AADD( _aParAux , { 1 , "Emissão ate"               , MV_PAR06, "@D"	, ""  , ""	      , "" , 50         , .T. } )
AADD( _aParAux , { 1 , "Cliente Fat. de: "	      , MV_PAR07, ""	   , ""	, "SA1"		, "" , 50         , .F. } )
AADD( _aParAux , { 1 , "Loja Fat de: "	            , MV_PAR08, ""	   , ""	, ""		   , "" , 25         , .F. } )
AADD( _aParAux , { 1 , "Cliente Fat. até: "	      , MV_PAR09, ""	   , ""	, "SA1"		, "" , 50         , .F. } )
AADD( _aParAux , { 1 , "Loja Fat até: "	         , MV_PAR10, ""	   , ""	, ""		   , "" , 25         , .F. } )
AADD( _aParAux , { 1 , "Cliente Final de: "	      , MV_PAR11, ""	   , ""	, "SA1"		, "" , 50         , .F. } )
AADD( _aParAux , { 1 , "Loja Final de: "	         , MV_PAR12, ""	   , ""	, ""		   , "" , 25         , .F. } )
AADD( _aParAux , { 1 , "Cliente Final até: "	      , MV_PAR13, ""	   , ""	, "SA1"		, "" , 50         , .F. } )
AADD( _aParAux , { 1 , "Loja Final até: "	         , MV_PAR14, ""	   , ""	, ""		   , "" , 25         , .F. } )

AADD( _aParAux , { 2 , "Saldo dos titulos"     , MV_PAR15,{"1=Zerado","2=Com Saldo","3-Ambos"},060 ,".T.", .T. } )

For _nI := 1 To Len( _aParAux )
      aAdd( _aParRet , _aParAux[_nI][03] )
Next _nI

DO WHILE .T. 
    //aParametros, cTitle            , @aRet   ,[bOk]  , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
   IF !ParamBox( _aParAux , _cTitulo , @_aParRet,  _bOK , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
      EXIT
   Else
      _cTimeIni  := Time()
      FWMSGRUN( ,{|oProc|  _lRet := RFIN021PR(oProc) } , "Hora Inicial: "+_cTimeIni+" Pesquisando títulos... " )   
   EndIf
ENDDO
Return _lRet



/*
===============================================================================================================================
Programa----------: RFIN021PR
Autor-------------: Alex Wallauer
Data da Criacao---: 08/04/2022
===============================================================================================================================
Descrição---------: Processamento da rotina
===============================================================================================================================
Parametros--------: oProc = objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RFIN021PR(oProc)
Local _aTit     := {}
Local _cMsgTop  
Local _lRet     := .F.
Local _aCab := {}
Local _aSizes := {}

Private _cTot

_aTit := RFIN021QRY(oProc)

_cMsgTop:=" Total de Titulos: "+_cTot+" / Hora inical: "+_cTimeIni+", Hora Final: "+TIME()

If Len(_aTit) = 0
   U_ITMSG( "De acordo com os parâmetros imputados não foi encontrado registro no periodo!" , "Atenção!",,2 )
Else
   _aCab := {}
   _aSizes:={}
   AADD(_aCab,Getsx3cache("E1_FILIAL"  ,"X3_TITULO"))
   AADD(_aSizes,20)
   AADD(_aCab,Getsx3cache("E1_PREFIXO" ,"X3_TITULO"))
   AADD(_aSizes,20)
   AADD(_aCab,Getsx3cache("E1_TIPO"    ,"X3_TITULO"))
   AADD(_aSizes,20)
   AADD(_aCab,Getsx3cache("E1_NUM"     ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_PARCELA" ,"X3_TITULO"))
   AADD(_aSizes,20)
   AADD(_aCab,Getsx3cache("E1_EMISSAO" ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_VENCTO"  ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_VENCREA" ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_CLIENTE" ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_LOJA"    ,"X3_TITULO"))
   AADD(_aSizes,20)
   AADD(_aCab,Getsx3cache("A2_NOME"    ,"X3_TITULO"))
   AADD(_aSizes,150)
   AADD(_aCab,Getsx3cache("E1_VALOR"   ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_SALDO"   ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_I_CLIEN" ,"X3_TITULO"))
   AADD(_aSizes,40)
   AADD(_aCab,Getsx3cache("E1_I_LOJEN" ,"X3_TITULO"))
   AADD(_aSizes,20)
   AADD(_aCab,Getsx3cache("E1_I_NOMEN" ,"X3_TITULO"))
   AADD(_aSizes,150)
            
   _lRet := U_ITListBox(_cTitulo, _aCab, @_aTit, .T., 1, @_cMsgTop, .F., _aSizes ,,,,,,  ,,,,,  )

EndIf

Return _lRet


/*
===============================================================================================================================
Programa----------: RFIN021QRY
Autor-------------: Alex Wallauer
Data da Criacao---: 08/04/2022
===============================================================================================================================
Descrição---------: Executa Busca de Títulos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: oProc = Status de Processamento
===============================================================================================================================
*/
Static Function RFIN021QRY(oProc)
Local _cFiltro:= "% "
Local _aTit   := {}
Local _cMask1 := PesqPict( "SE1" , "E1_VALOR" )
Local _cMask2 := PesqPict( "SE1" , "E1_SALDO" ) 
Local _cAlias := ""


If !empty(MV_PAR01)

	_cFiltro += " AND E1_FILIAL IN " + FormatIn(Alltrim(MV_PAR01),";") 
	
Endif


If !Empty(Alltrim(MV_PAR02))

	_cFiltro += " AND E1_PREFIXO IN " + FormatIn(Alltrim(MV_PAR02),";") 
	
EndIf

If !Empty(Alltrim(MV_PAR04))

	_cFiltro += " AND E1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "

ELSEIf !Empty(Alltrim(MV_PAR03))

	_cFiltro += " AND E1_NUM >= '" + MV_PAR03 + "' "
	
EndIf


_cFiltro += " AND E1_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "


If !Empty(Alltrim(MV_PAR09))

	_cFiltro += " AND E1_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR09 + "' "

ELSEIf !Empty(Alltrim(MV_PAR07))

	_cFiltro += " AND E1_CLIENTE >='" + MV_PAR07 + "' "

EndIf

If !Empty(Alltrim(MV_PAR10))

	_cFiltro += " AND E1_LOJA BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "' "

ELSEIf !Empty(Alltrim(MV_PAR08))

	_cFiltro += " AND E1_LOJA >= '" + MV_PAR08 + "' "

EndIf

If !Empty(Alltrim(MV_PAR13))

	_cFiltro += " AND E1_I_CLIEN BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR13 + "' "

ELSEIf !Empty(Alltrim(MV_PAR11))

	_cFiltro += " AND E1_I_CLIEN >='" + MV_PAR11 + "' "

EndIf

If !Empty(Alltrim(MV_PAR14))

	_cFiltro += " AND E1_I_LOJEN BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR14 + "' "

ELSEIf !Empty(Alltrim(MV_PAR12))

	_cFiltro += " AND E1_I_LOJEN >= '" + MV_PAR12 + "' "

EndIf

If MV_PAR15 = "1"
	_cFiltro += " AND E1_SALDO = 0 "
ELSEIf MV_PAR15 = "2"
	_cFiltro += " AND E1_SALDO > 0 "
ENDIF
_cFiltro += " AND E1_I_CLIEN <> ' ' "


_cFiltro += " %"
	
_cAlias:= GetNextAlias()
If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

BeginSql Alias _cAlias
      
      SELECT R_E_C_N_O_ RECSE1
      FROM %table:SE1% SE1
      WHERE SE1.%notDel%
            %Exp:_cFiltro%
      ORDER BY E1_FILIAL, E1_PREFIXO,E1_NUM

EndSql

_nTot:=nConta:=0
COUNT TO _nTot
_cTot:=ALLTRIM(STR(_nTot))

(_cAlias)->(DBGoTop())

Do While (_cAlias)->(!EOF())
   nConta++
   oProc:cCaption := ('Lendo: '+ALLTRIM(STR(nConta))+" de "+_cTot )
   ProcessMessages()

   SE1->(DBGOTO((_cAlias)->RECSE1))
   _aItens:={}
   AADD(_aItens,SE1->E1_FILIAL)
   AADD(_aItens,SE1->E1_PREFIXO)
   AADD(_aItens,SE1->E1_TIPO   )
   AADD(_aItens,SE1->E1_NUM    )
   AADD(_aItens,SE1->E1_PARCELA)
   AADD(_aItens,DTOC(SE1->E1_EMISSAO))
   AADD(_aItens,DTOC(SE1->E1_VENCTO) )
   AADD(_aItens,DTOC(SE1->E1_VENCREA) )
   AADD(_aItens,SE1->E1_CLIENTE)
   AADD(_aItens,SE1->E1_LOJA   )
   AADD(_aItens,POSICIONE("SA1",1,xfilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME")  )
   AADD(_aItens,TRANSFORM(  SE1->E1_VALOR  , _cMask1)   )
   AADD(_aItens,TRANSFORM(  SE1->E1_SALDO  , _cMask2)   )
   AADD(_aItens,SE1->E1_I_CLIEN)
   AADD(_aItens,SE1->E1_I_LOJEN)
   AADD(_aItens,POSICIONE("SA1",1,xfilial("SA1")+SE1->E1_I_CLIEN+SE1->E1_I_LOJEN,"A1_NOME")  )
   
   AADD(_aTit,_aItens)
   
   (_cAlias)->(dbSkip())

EndDo

(_cAlias)->(DBCloseArea())

Return _aTit
