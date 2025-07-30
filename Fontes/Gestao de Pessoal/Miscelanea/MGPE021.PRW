/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"

/*
===============================================================================================================================
Programa----------: MGPE021
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 23/10/2019
===============================================================================================================================
Descrição---------: Relatorio de transferências de setor - Chamado 30942
===============================================================================================================================
Retorno-----------: Nenhum  
===============================================================================================================================
*/
User Function MGPE021()

Local _aParAux:={} , nI
Local _aParRet:={}

MV_PAR01:=SPACE(200)
MV_PAR02:=dDataBase
MV_PAR03:=dDataBase
MV_PAR04:=SPACE(LEN(SRE->RE_CCD))
MV_PAR05:=SPACE(LEN(SRE->RE_CCP))

AADD( _aParAux , { 1 , "Filial"               , MV_PAR01, "@!"  , ""    ,"LSTFIL"   , "" , 060 , .T. } ) 
AADD( _aParAux , { 1 , "Data de"	          , MV_PAR02, "@D"	, ""	, ""		, "" , 060 , .T. } )
AADD( _aParAux , { 1 , "Data ate"             , MV_PAR03, "@D"	, ""	, ""		, "" , 060 , .T. } )
AADD( _aParAux , { 1 , "Centro de Custo de"   , MV_PAR04, "@!"  , ""    , "CTT"     , "" , 060 , .F. } ) 
AADD( _aParAux , { 1 , "Centro de Custo ate"  , MV_PAR05, "@!"  , ""    , "CTT"     , "" , 060 , .F. } ) 

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next 

DO WHILE .T.

   lSair:=.T.
   
   IF !ParamBox( _aParAux , "Seleção de dados do Relatorio de transferências" , @_aParRet )
      Return .T.
   EndIf

   FWMSGRUN( ,{|oproc| lSair:=MPGE021INI(oproc) } , "Processando..." , "Iniciando o processamento..." )

   IF lSair
      EXIT
   ENDIF

ENDDO

Return .T.



/*
===============================================================================================================================
Programa----------: MPGE021INI
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 29/07/2019
===============================================================================================================================
Descrição---------: Rotina de montagem da tela de processamento
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static Function MPGE021INI(oproc)

Local _cquery	:= ""
Local _aDados	:= {}
Private cAliasAux	:= GetNextAli8as()

//Grava Log de execução da rotina
U_ITLOGACS( "MPGE021" )

oproc:cCaption := ("Lendo dados...")
ProcessMessages()

_cquery := " SELECT  R_E_C_N_O_ REC_SRE "
_cquery += " FROM " +RETSQLNAME("SRE") + " SRE WHERE  "
_cquery += "(   SRE.RE_FILIALD IN "+ FormatIn(ALLTRIM(MV_PAR01), ";" )
_cquery += " OR SRE.RE_FILIALP IN "+ FormatIn(ALLTRIM(MV_PAR01), ";" )+")"
IF !EMPTY(MV_PAR02)
   _cquery += " AND RE_DATA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
ELSEIF !EMPTY(MV_PAR01) 
   _cquery += " AND RE_DATA >= '" + DTOS(MV_PAR02) + "'"
ENDIF
IF !EMPTY(MV_PAR05)
   _cquery += " AND (   RE_CCP  BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "
   _cquery += "      OR RE_CCD  BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "')"
ELSEIF !EMPTY(MV_PAR04) 
   _cquery += " AND (   RE_CCD  >= '" + MV_PAR04 + "'"
   _cquery += "      OR RE_CCP  >= '" + MV_PAR04 + "')"
ENDIF
_cquery += "  AND D_E_L_E_T_ <> '*' " 

_cquery += " ORDER BY RE_DATA,RE_CCP,RE_MATP "
	
MPSysOpenQuery( _cquery , cAliasAux ) 

oProc:cCaption := ("Contando os dados lidos...")
ProcessMessages()
DBSELECTAREA(cAliasAux)
(cAliasAux)->(Dbgotop())
_cTot := 0
COUNT TO _cTot
_cTot:=ALLTRIM(STR(_cTot))
_nTam:=LEN(_cTot)
(cAliasAux)->(Dbgotop())
_npv:=0

DO While (cAliasAux)->(!EOF())

    SRE->(DBGOTO((cAliasAux)->REC_SRE))
	_npv++
	oProc:cCaption := ("Processando Dados: "+ STRZERO(_npv,_nTam) +" de "+ _cTot)
	ProcessMessages()

    _aItens:={}
	AADD(_aItens,DTOC(SRE->RE_DATA))
	AADD(_aItens,SRE->RE_FILIALD)
	AADD(_aItens,SRE->RE_MATD)
	AADD(_aItens,SRE->RE_CCD+"-"+POSICIONE("CTT",1,XFILIAL("CTT")+SRE->RE_CCD,"CTT_DESC01"))
	AADD(_aItens,Posicione("SRA",1,ALLTRIM(SRE->RE_FILIALP)+SRE->RE_MATP,"RA_NOME"))
	AADD(_aItens,SRE->RE_FILIALP)
	AADD(_aItens,SRE->RE_MATP)
	AADD(_aItens,SRE->RE_CCP+"-"+POSICIONE("CTT",1,XFILIAL("CTT")+SRE->RE_CCP,"CTT_DESC01"))
	cSetor:=Posicione("SRA",1,ALLTRIM(SRE->RE_FILIALP)+SRE->RE_MATP,"RA_I_SETOR")
	IF !EMPTY(cSetor)
       AADD(_aItens,cSetor+"-"+Posicione("ZAK",1,xFilial("ZAK")+cSetor,"ZAK_DESCRI"))
    ELSE   
       AADD(_aItens," ")
    ENDIF   
	AADD(_aDados,_aItens)

    (cAliasAux)->(DBSKIP())
 
ENDDO

(cAliasAux)->( DBCloseArea() )


//Monta _aCab
_aCab:={}
_aSizes:={}
AAdd(_aCab,Getsx3cache("RE_DATA"   ,"X3_TITULO"))
AAdd(_aSizes,38)
AAdd(_aCab,Getsx3cache("RE_FILIALD","X3_TITULO"))
AAdd(_aSizes,37)
AAdd(_aCab,Getsx3cache("RE_MATD"   ,"X3_TITULO"))
AAdd(_aSizes,39)
AAdd(_aCab,Getsx3cache("RE_CCD"    ,"X3_TITULO"))
AAdd(_aSizes,140)
AAdd(_aCab,Getsx3cache("RA_NOME"   ,"X3_TITULO"))
AAdd(_aSizes,130)
AAdd(_aCab,Getsx3cache("RE_FILIALP","X3_TITULO"))
AAdd(_aSizes,37)
AAdd(_aCab,Getsx3cache("RE_MATP"   ,"X3_TITULO"))
AAdd(_aSizes,39)
AAdd(_aCab,Getsx3cache("RE_CCP"    ,"X3_TITULO"))
AAdd(_aSizes,140)
AAdd(_aCab,"Setor Atual")
AAdd(_aSizes,200)

If LEN(_aDados) > 0
   _cTitulo:="Relatorio de transferências de Setor"
   _cMsgTop:="Relatorio de transferências de Setor"
//    ITListBox(_cTitAux, _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
	U_ITLISTBOX(_cTitulo, _aCab    , _aDados   , .T.      , 1      ,_cMsgTop  ,          , _aSizes )
Else
	U_ITMSG("Nenhum registro gerado!","Atenção",,1)
Endif

Return .F.