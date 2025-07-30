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
#include 'protheus.ch'
#include "topconn.ch"
#DEFINE ENTER CHR(13)+CHR(10)


/*
===============================================================================================================================
Programa--------: RFIN018
Autor-----------: Alex Wallauer
Data da Criacao-: 22/10/2019
===============================================================================================================================
Descrição-------: Relação de CLAIMs - Chamado 29718
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION RFIN018()
Local _aParRet :={}
Local _aParAux :={} , nI 
Local _bOK1    :={|| IF(MV_PAR04 >= MV_PAR03,.T.,(U_ITMSG("Periodo INVALIDO",'Dt Emissão'    ,"Tente novamente com um periodo Valido"  ,3),.F.) ) }
Local _bOK2    :={|| IF(MV_PAR06 >= MV_PAR05,.T.,(U_ITMSG("Periodo INVALIDO",'Dt Vencto Real',"Tente novamente com um periodo Valido"  ,3),.F.) ) }
Local _bOK3    :={|| IF(MV_PAR08 >= MV_PAR07,.T.,(U_ITMSG("Periodo INVALIDO",'Dt Liberação ' ,"Tente novamente com um periodo Valido"  ,3),.F.) ) }
Local _bOK4    :={|| IF(MV_PAR10 >= MV_PAR09,.T.,(U_ITMSG("Intervalo INVALIDO",'No. Titulo ' ,"Tente novamente com um Intervalo Valido",3),.F.) ) }

Private aLog := {}
Private _cFecham	:= ""

_aOpca:={}
AADD( _aOpca , "1-Sim  ")
AADD( _aOpca , "2-Nao  ")
AADD( _aOpca , "3-Ambos")

MV_PAR01:=SPACE(200)
MV_PAR02:="1–Sim  "
MV_PAR03:=dDataBase
MV_PAR04:=dDataBase
MV_PAR05:=dDataBase
MV_PAR06:=dDataBase
MV_PAR07:=dDataBase
MV_PAR08:=dDataBase
MV_PAR09:=SPACE(LEN(SE2->E2_NUM))
MV_PAR10:=SPACE(LEN(SE2->E2_NUM))

AADD( _aParAux , { 1 , "Filial"               , MV_PAR01, "@!"  , ""    ,"LSTFIL"   , "" , 060 , .F. } ) 
AADD( _aParAux , { 2 , "CLAIM"                , MV_PAR02, _aOpca                         , 060 ,".T.",.F.}) 
AADD( _aParAux , { 1 , "Dt Emissão de"	      , MV_PAR03, "@D"	, ""	, ""		, "" , 060 , .F. } )
AADD( _aParAux , { 1 , "Dt Emissão ate"       , MV_PAR04, "@D"	, ""	, ""		, "" , 060 , .F. } )
AADD( _aParAux , { 1 , "Dt Vencto Real de"	  , MV_PAR05, "@D"	, ""	, ""		, "" , 060 , .F. } )
AADD( _aParAux , { 1 , "Dt Vencto Real ate"   , MV_PAR06, "@D"	, ""	, ""		, "" , 060 , .F. } )
AADD( _aParAux , { 1 , "Dt Liberação de"	  , MV_PAR07, "@D"	, ""	, ""		, "" , 060 , .F. } )
AADD( _aParAux , { 1 , "Dt Liberação ate"     , MV_PAR08, "@D"	, ""	, ""		, "" , 060 , .F. } )
AADD( _aParAux , { 1 , "No. Titulo de"        , MV_PAR09, "@!"  , ""    , ""        , "" , 060 , .F. } ) 
AADD( _aParAux , { 1 , "No. Titulo ate"       , MV_PAR10, "@!"  , ""    , ""        , "" , 060 , .F. } ) 

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

   lSair:=.T.
   
   IF !ParamBox( _aParAux , "Seleção de dados do Relação de Titulos CLAIMs" , @_aParRet ,{|| ( EVAL(_bOK1) .AND. EVAL(_bOK2) .AND. EVAL(_bOK3) .AND. EVAL(_bOK4) )} )
      Return .T.
   EndIf

   FWMSGRUN( ,{|oproc| lSair:=RFIN018INI(oproc) } , "Processando..." , "Iniciando o processamento..." )

   IF lSair
      EXIT
   ENDIF

ENDDO

Return .T.



/*
===============================================================================================================================
Programa----------: RFIN018INI
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
Static Function RFIN018INI(oproc)

Local _cquery	:= ""
Local _aDados	:= {}
Private cAliasAux	:= GetNextAli8as()

//Grava Log de execução da rotina
U_ITLOGACS( "RFIN018" )

oproc:cCaption := ("Lendo dados...")
ProcessMessages()

_cquery := " SELECT  SE2.R_E_C_N_O_ REC_SE2 , SD1.R_E_C_N_O_ REC_SD1 "
_cquery += " FROM " +RETSQLNAME("SE2") + " SE2 
_cquery += " INNER JOIN " +RETSQLNAME("SD1") + " SD1 ON SE2.E2_FILIAL	= SD1.D1_FILIAL	 AND "
_cquery += " 											SE2.E2_FORNECE 	= SD1.D1_FORNECE AND "
_cquery += " 											SE2.E2_LOJA 	= SD1.D1_LOJA	 AND "
_cquery += " 											SE2.E2_NUM		= SD1.D1_DOC         "
_cquery += " WHERE  "
_cquery += " SE2.E2_FILIAL IN "+ FormatIn(ALLTRIM(MV_PAR01), ";" )
IF !EMPTY(MV_PAR04)
   _cquery += " AND E2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'"
ELSEIF !EMPTY(MV_PAR03) 
   _cquery += " AND E2_EMISSAO >= '" + DTOS(MV_PAR03) + "'"
ENDIF
IF !EMPTY(MV_PAR06)
   _cquery += " AND E2_VENCREA BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
ELSEIF !EMPTY(MV_PAR05) 
   _cquery += " AND E2_VENCREA >= '" + DTOS(MV_PAR05) + "'"
ENDIF
IF !EMPTY(MV_PAR08)
   _cquery += " AND E2_DATALIB BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "'"
ELSEIF !EMPTY(MV_PAR07) 
   _cquery += " AND E2_DATALIB >= '" + DTOS(MV_PAR07) + "'"
ENDIF
IF !EMPTY(MV_PAR10)
   _cquery += " AND E2_NUM BETWEEN '" + DTOS(MV_PAR09) + "' AND '" + DTOS(MV_PAR10) + "'"
ELSEIF !EMPTY(MV_PAR09) 
   _cquery += " AND E2_NUM >= '" + DTOS(MV_PAR09) + "'"
ENDIF
IF MV_PAR02 = "1"
   _cquery += " AND E2_I_CLAIM = '1' "
ELSEIF MV_PAR02 = "2"
   _cquery += " AND E2_I_CLAIM = '2' "
ELSE
   _cquery += " AND E2_I_CLAIM <> ' ' "
ENDIF
_cquery += "  AND SE2.D_E_L_E_T_ <> '*' " 
_cquery += "  AND SD1.D_E_L_E_T_ <> '*' " 
_cquery += " ORDER BY SE2.E2_I_CLAIM , SE2.E2_NUM "
	
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

    SE2->(DBGOTO((cAliasAux)->REC_SE2))
    SD1->(DBGOTO((cAliasAux)->REC_SD1))
	_npv++
	oProc:cCaption := ("Processando Dados: "+ STRZERO(_npv,_nTam) +" de "+ _cTot)
	ProcessMessages()

    _aItens:={}
	AADD(_aItens,IF(SE2->E2_I_CLAIM="1","Sim","Não"))
	AADD(_aItens,SE2->E2_FILIAL)
	AADD(_aItens,SE2->E2_PREFIXO)
	AADD(_aItens,SE2->E2_NUM)
	AADD(_aItens,SE2->E2_PARCELA)
	AADD(_aItens,DTOC(SE2->E2_EMISSAO))
	AADD(_aItens,DTOC(SE2->E2_VENCREA))
	AADD(_aItens,DTOC(SE2->E2_DATALIB))
	AADD(_aItens,SD1->D1_PEDIDO)
	AADD(_aItens,SD1->D1_COD)
	AADD(_aItens,Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_I_DESCD"))	
	AADD(_aItens,Transform(SD1->D1_QUANT,PesqPict("SD1","D1_QUANT")) )
	AADD(_aItens,Transform(SD1->D1_VUNIT,PesqPict("SD1","D1_VUNIT")) )
	AADD(_aItens,Transform(SD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL")) )
	AADD(_aDados,_aItens)

    (cAliasAux)->(DBSKIP())
 
ENDDO

(cAliasAux)->( DBCloseArea() )


//Monta _aCab
aTitCol:={}
_aSizes:={}
AADD(aTitCol,"CLAIM")
AAdd(_aSizes,30)
AADD(aTitCol,"Filial")
AAdd(_aSizes,30)
AADD(aTitCol,"Prefixo")
AAdd(_aSizes,30)
AADD(aTitCol,"No Titulo")
AAdd(_aSizes,40)
AADD(aTitCol,"Parcela")
AAdd(_aSizes,30)
AADD(aTitCol,"Dt Emisaão")
AAdd(_aSizes,40)
AADD(aTitCol,"Dt Vencto Real")
AAdd(_aSizes,45)
AADD(aTitCol,"Dt Liberação")
AAdd(_aSizes,40)
AADD(aTitCol,"Pedido")
AAdd(_aSizes,40)
AADD(aTitCol,"Produto")
AAdd(_aSizes,40)
AADD(aTitCol,"Descrição do Produto")
AAdd(_aSizes,100)
AADD(aTitCol,"Quantidade")
AAdd(_aSizes,40)
AADD(aTitCol,"Vlr Unitário")
AAdd(_aSizes,40)
AADD(aTitCol,"Vlr Total Prod.")
AAdd(_aSizes,50)

If LEN(_aDados) > 0
   _cTitulo:="Relação Titulos a Pagar de CLAIMs"
   _cMsgTop:=_cTitulo
//    ITListBox(_cTitAux, _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
	U_ITLISTBOX(_cTitulo, aTitCol  , _aDados   , .T.      , 1      ,_cMsgTop  ,          , _aSizes )
Else
	U_ITMSG("Nenhum registro gerado!","Atenção",,1)
Endif

Return .F.