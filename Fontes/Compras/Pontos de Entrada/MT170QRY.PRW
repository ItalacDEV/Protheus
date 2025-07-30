/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
	Autor	 |	Data	   |										Motivo																
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/
//Includes da função
#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#Include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: MT170QRY
Autor-------------: Alex Wallauer
Data da Criacao---: 24/02/2022
===============================================================================================================================
Descrição---------: Ponto de entrada antes da  geração das SCs. Chamado: 39266 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT170QRY()
Local _aParRet	:= {} , nI
Local _aParAux  := {}
Local _aPars    := {}

Public cUrgen:= " "
Public cCCust:= SPACE(LEN(SC1->C1_CC     ))
Public cAprov:= SPACE(LEN(SC1->C1_I_CODAP))
Public cObsSC:= SPACE(LEN(SC1->C1_I_OBSSC))

//Guarda parametros atuais e refaz pergunte
For nI = 1 to 10
	_cNome := "MV_PAR" + strzero(nI,2)
	aadd(_aPars, &(_cNome) )
Next	

MV_PAR01:= SPACE(LEN(SC1->C1_CC     ))
MV_PAR02:= SPACE(LEN(SC1->C1_I_CODAP))
MV_PAR03:= "N"
MV_PAR04:= SPACE(LEN(SC1->C1_I_OBSSC))
_cValCC := ' cCCust:=MV_PAR02 , U_VldInf("C") .AND. U_VldZLH(cFilAnt) .AND.  Ctb105CC() '
_cValAP := ' cAprov:=MV_PAR03 , U_VldInf("A") '

_aParAux:={}
AADD( _aParAux , { 1 , "'C. Custo'"	  , MV_PAR01, "@!" , _cValCC, "CTTZLH"	, "" , 050 , .T. } )
aAdd( _aParAux , { 1 , "Aprovador"	  , MV_PAR02, "@!" , _cValAP, 'ZZ7APR'	, "" , 050 , .T. } )
AADD( _aParAux , { 2 , "Urgente"      , MV_PAR03, {"S-Sim","N-Nao"}     , 050 ,".T.",.T.,".T."}) 
aAdd( _aParAux , { 1 , "Obs. Generica", MV_PAR04, "@!"    , ""	, ''	    , "" , 100 , .F. } )

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next 

// ParamBox( _aParAux , cTitle                  , @aRet     ,[bOk]    , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
IF ParamBox( _aParAux , "Digite os dados da SC" , @_aParRet ,{||.T.}  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
   cCCust:= MV_PAR01
   cAprov:= MV_PAR02
   cUrgen:= MV_PAR03
   cObsSC:= MV_PAR04
ENDIF
For nI = 1 to 10
	_cNome    := "MV_PAR" + STRZERO(nI,2)
	&(_cNome) := _apars[nI]
Next	
RETURN .T.

/*//Posição referente ao Urgente
//============================
@ _nLinA, aPosGet[1,5]   	SAY 'Urgente' PIXEL SIZE 28,9 Of oNewDialog 
@ _nLinA, aPosGet[1,6]		MSCOMBOBOX  cUrgen ITEMS {"","S=Sim","N=Não"} SIZE 036, 010 OF oNewDialog COLORS 0, 16777215 PIXEL WHEN _lWhen 
//====================================
//Posição referente ao centro de custo
//====================================
@ _nLinB, aPosGet[1,1]		SAY 'C. Custo' PIXEL SIZE 28,9 Of oNewDialog
@ _nLinB, aPosGet[1,2]		MSGET cCCust F3 'CTTZLH' PIXEL SIZE 40,08 OF oNewDialog Valid {|| U_VldInf("C") .AND. U_VldZLH(cFilAnt) .AND.  Ctb105CC()} WHEN _lWhen
@ _nLinB, aPosGet[1,2]+50	MSGET cDsCus PIXEL SIZE 100,08 Of oNewDialog WHEN .F.
//==============================
//Posição referente ao Aprovador
//==============================
@ _nLinB, aPosGet[1,3]+10  	SAY 'Aprovador' PIXEL SIZE 28,9 Of oNewDialog 
@ _nLinB, aPosGet[1,4]		MSGET cAprov F3 'ZZ7APR' PIXEL SIZE 10,08 Of oNewDialog Valid {|| U_VldInf("A")} WHEN _lWhen
@ _nLinB, aPosGet[1,4]+40	MSGET cDsApr PIXEL SIZE 100,08 Of oNewDialog WHEN .F.
//==============================
//Posição referente a Observação
//==============================
@ _nLinB, aPosGet[1,5]		SAY 'Obs. Generica' PIXEL SIZE 40,9 Of oNewDialog
@ _nLinB, aPosGet[1,6]   	MSGET cObsSC PIXEL SIZE 100,08 Of oNewDialog WHEN _lWhen*/
