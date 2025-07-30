/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |17/10/2019| Chamado 28346. Removidos os Warning na compila��o da release 12.1.25
Lucas Borges  |09/10/2024| Chamado 48465. Retirada da fun��o de conout
Lucas Borges  |21/05/2025| Chamado 50617. Corrigir chamada est�tica no nome das tabelas do sistema
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FONT.CH"

#define	MB_OK				0
#define MB_ICONASTERISK		64

/*
===============================================================================================================================
Programa----------: ACOM017
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016
Descri��o---------: Rotina responsavel pelo Monitor de Compras
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM017()
Local cAlias		:= "ZY1"
Local aCores 		:=	{	{'ZY1_DTFAT - Date() >= 15 .AND. ZY1_ENCMON <> "S"'									, 'BR_VERDE'	},;
							{'ZY1_DTFAT - Date() >= 10 .And. ZY1_DTFAT - Date() <= 14 .AND. ZY1_ENCMON <> "S"'	, 'BR_AMARELO'	},;
							{'ZY1_DTFAT - Date() <= 9 .AND. ZY1_ENCMON <> "S"' 									, 'BR_VERMELHO'	},;
							{'ZY1_ENCMON == "S"', 'BR_BRANCO'	} }

Private _cFiltro	:= ""

Private cCadastro	:= ""
Private aRotina		:= MenuDef()
Private nMaxGravado := 0

If !Pergunte('ACOM017A',.T.)
     Return
EndIf

//======================================================================
// Grava log de acesso ao cadastro de monitoramento de Pedido de Compras 
//====================================================================== 
U_ITLOGACS('ACOM017')

//======================================================================
// Exibe o Browser principal da rotina.
//======================================================================
If MV_PAR01 == 2
	_cFiltro := " ZY1_ENCMON <> 'S' "
EndIf

cCadastro	:= "Monitoramento Pedido de Compras"
dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1))
mBrowse( 6, 1,22,75,cAlias,,,,,,aCores,,,,,,,,_cFiltro)

Return

/*
===============================================================================================================================
Programa----------: ACOM017
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016
Descri��o---------: Rotina responsavel pela cria��o das op��es de menu
Parametros--------: Nenhum
Retorno-----------: aRotina = Array com as op��es de menu.
===============================================================================================================================
*/
Static Function MenuDef()

Private aRotina	:=  {	{"Pesquisar"		,"AxPesqui"		, 0, 1, 0, .F.},;
						{"Visualizar"		,"U_ACOM017Z()"	, 0, 2, 0, nil},;
						{"Incluir"			,"U_ACOM017I()" , 0, 3, 0, nil},;
						{"Alterar"			,"U_ACOM017A()"	, 0, 4, 0, .F.},;
						{"Notas"			,"U_A017PLA()"	, 0, 2, 0, .F.},;
						{"E-mail"			,"U_ACOM017E()"	, 0, 2, 0, .F.},;
						{"Encerra Monit."	,"U_A017ENC()"	, 0, 2, 0, .F.},;
						{"Alt.Dt.Fat.PC"	,"U_A017DTFT(,ZY1->ZY1_NUMPC)", 0, 2, 0, .F.},;
						{"Legenda"			,"U_A017LEG"	, 0, 2, 0, .F.} }

Return (aRotina)

/*
===============================================================================================================================
Programa----------: ACOM017Z
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016
Descri��o---------: Fun��o de Visualiza��o de registros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM017Z()
Local _oSayFO
Local _oGetFO
Local _cGetFO := Space(60)

Local _oSayFR
Local _oGetFR
Local _cGetFR := Space(9)

Local _oSayNE
Local _oGetNE
Local _dGetNE := StoD("")

Local _oSayNF
Local _oGetNF
Local _cGetNF := Space(60)

Local _oSayOR
Local _oGetOR
Local _cGetOR := Space(40)

Local _oSayPC
Local _oGetPC

Local _oSaySC
Local _oGetSC
Local _cGetSC := Space(TamSX3("C1_NUM")[1])

Local _oSaySP
Local _oGetSP
Local _cGetSP := Space(60)

Local _oSayVL
Local _oGetVL
Local _nGetVL := 0

Local _aPosObj	:= {}
Local _aObjects	:= {}
Local _aSize	:= {}
Local _aPosGet	:= {}
Local _aInfo	:= {}

Local _nX		:= 0
Local _nOpca	:= 0

Private _oSayEE
Private _oGetEE
Private _dGetEE := StoD("")

Private _cGetPC := ZY1->ZY1_NUMPC

Private _aTELA[0][0]
Private _aGETS[0]

Private _aHeader		:= {}
Private _aCols			:= {}
Private _aFieldFill		:= {}
Private _aFields		:= {"ZY1_SEQUEN","ZY1_DTMONI","ZY1_HRMONI","ZY1_COMENT","ZY1_CODUSR","ZY1_NOMUSR"}
Private _aAlterFields	:= {"ZY1_COMENT"}

Private _oMSNewGeZY1
Private _oDlg

//popula aheader
Aadd(_aHeader,   {"Sequencia"    ,"ZY1_SEQUEN"," ",4,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Dt Monitoram" ,"ZY1_DTMONI"," ",8,0," "," ","D"," "," "})
Aadd(_aHeader,   {"Hr Monitoram" ,"ZY1_HRMONI"," ",5,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Comentario"   ,"ZY1_COMENT"," ",200,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Cod Usuario"  ,"ZY1_CODUSR"," ",6,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Nome Usuario" ,"ZY1_NOMUSR"," ",40,0," "," ","C"," "," "})

U_ACOM017V(_cGetPC,@_cGetSC,@_cGetNF,@_dGetNE,@_cGetFR,@_nGetVL,@_cGetFO,@_cGetOR,@_cGetSP,@_dGetEE)

_cQryZY1 := "SELECT ZY1_SEQUEN, ZY1_DTMONI, ZY1_HRMONI, ZY1_COMENT, ZY1_CODUSR, ZY1_NOMUSR "
_cQryZY1 += "FROM " + RetSqlName("ZY1") + " "
_cQryZY1 += "WHERE ZY1_FILIAL = '" + xFilial("ZY1") + "' "
_cQryZY1 += "  AND ZY1_NUMPC = '" + _cGetPC + "' "
_cQryZY1 += "  AND D_E_L_E_T_ = ' ' "
_cQryZY1 := ChangeQuery(_cQryZY1)

MPSysOpenQuery(_cQryZY1,"TRBZY1")

dbSelectArea("TRBZY1")
TRBZY1->(dbGoTop())

If !TRBZY1->(Eof())

   A017GrvaCols()

Else
	For _nX := 1 to Len(_aFields)
		If _aFields[_nX] == "ZY1_SEQUEN"
			Aadd(_aFieldFill, "0001")
		Else
			Aadd(_aFieldFill, CriaVar(_aFields[_nX]))
		EndIf
	Next _nX
	Aadd(_aFieldFill, .F.)
	Aadd(_aCols, _aFieldFill)
EndIf

TRBZY1->(dbCloseArea())

_aSize    := MsAdvSize()
_aObjects := {}

AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 015, .T., .F. } )

_aInfo   := { _aSize[ 1 ],_aSize[ 2 ],_aSize[ 3 ],_aSize[ 4 ],03,03 }
_aPosObj := MsObjSize( _aInfo, _aObjects )
_aPosGet := MsObjGetPos(_aSize[3]-_aSize[1],315,{{003,157,189,236,268}})

DEFINE MSDIALOG _oDlg TITLE "Monitoramento Pedido de Compras" FROM _aSize[7],0 to _aSize[6],_aSize[5] of oMainWnd PIXEL

	@ 035, 002 SAY _oSayPC PROMPT "N�mero PC:" SIZE 031, 007 OF _oDlg COLORS 16711680, 16777215 PIXEL
	@ 047, 002 MSGET _oGetPC VAR _cGetPC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 F3 "SC7" READONLY PIXEL

	@ 035, 066 SAY _oSaySC PROMPT "N�mero Solicita��o:" SIZE 050, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 066 MSGET _oGetSC VAR _cGetSC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 122 SAY _oSayNF PROMPT "N�mero NF / Vencimento:" SIZE 080, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 122 MSGET _oGetNF VAR _cGetNF SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 394 SAY _oSayNE PROMPT "Dt. Necessidade: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 394 MSGET _oGetNE VAR _dGetNE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PICTURE READONLY PIXEL

	
	@ 035, 450 SAY _oSayEE PROMPT "Dt. Faturamento: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 450 MSGET _oGetEE VAR _dGetEE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PICTURE READONLY PIXEL

	@ 035, 500 SAY _oSayFR PROMPT "Tp Frete:" SIZE 025, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 500 MSGET _oGetFR VAR _cGetFR SIZE 030, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 590 SAY _oSayVL PROMPT "Valor: " SIZE 017, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 590 MSGET _oGetVL VAR _nGetVL SIZE 060, 010 OF _oDlg COLORS 0, 16777215 PICTURE PesqPict("SC7","C7_TOTAL") READONLY PIXEL

	@ 063, 002 SAY _oSayFO PROMPT "Fornecedor:" SIZE 031, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 002 MSGET _oGetFO VAR _cGetFO SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 063, 222 SAY _oSaySP PROMPT "Obs Pedido de Compras: " SIZE 040, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 222 MSGET _oGetSP VAR _cGetSP SIZE 336, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 091, 002 SAY _oSayOR PROMPT "Origem: " SIZE 020, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 103, 002 MSGET _oGetOR VAR _cGetOR SIZE 118, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	_oMSNewGeZY1 := MsNewGetDados():New( _aPosGet[1,1] + 115, _aPosGet[1,1] - 5, _aPosGet[1,2] - 15, _aPosGet[1,4] + _aPosGet[1,2] - _aPosObj[2,1] - 10, 0, "AllwaysTrue", "AllwaysTrue", "+ZY1_SEQUEN", _aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", _oDlg, _aHeader, _aCols)

ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg,{||_nOpca := 1, _oDlg:End()},{||_nOpca := 0, _oDlg:End() })

Return

/*
===============================================================================================================================
Programa----------: ACOM017I
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016
Descri��o---------: Fun��o de Inclus�o de registros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM017I()
Local _oSayFO
Local _oGetFO
Local _cGetFO := Space(60)

Local _oSayFR
Local _oGetFR
Local _cGetFR := Space(9)

Local _oSayNE
Local _oGetNE
Local _dGetNE := StoD("")

Local _oSayNF
Local _oGetNF
Local _cGetNF := Space(60)

Local _oSayOR
Local _oGetOR
Local _cGetOR := Space(40)

Local _oSayPC
Local _oGetPC

Local _oSaySC
Local _oGetSC
Local _cGetSC := Space(TamSX3("C1_NUM")[1])

Local _oSaySP
Local _oGetSP
Local _cGetSP := Space(60)

Local _oSayVL
Local _oGetVL
Local _nGetVL := 0

Local _aPosObj	:= {}
Local _aObjects	:= {}
Local _aSize	:= {}
Local _aPosGet	:= {}
Local _aInfo	:= {}

Local _nX		:= 0
Local _nOpca	:= 0

Private _oSayEE
Private _oGetEE
Private _dGetEE := StoD("")

Private _cGetPC := Space(TamSX3("ZY1_NUMPC")[1])

Private _aTELA[0][0]
Private _aGETS[0]

Private _aHeader		:= {}
Private _aCols			:= {}
Private _aFieldFill		:= {}
Private _aFields		:= {"ZY1_SEQUEN","ZY1_DTMONI","ZY1_HRMONI","ZY1_COMENT","ZY1_CODUSR","ZY1_NOMUSR"}
Private _aAlterFields	:= {"ZY1_COMENT"}

Private _oMSNewGeZY1
Private _oDlg

//popula aheader
Aadd(_aHeader,   {"Sequencia"    ,"ZY1_SEQUEN"," ",4,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Dt Monitoram" ,"ZY1_DTMONI"," ",8,0," "," ","D"," "," "})
Aadd(_aHeader,   {"Hr Monitoram" ,"ZY1_HRMONI"," ",5,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Comentario"   ,"ZY1_COMENT"," ",200,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Cod Usuario"  ,"ZY1_CODUSR"," ",6,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Nome Usuario" ,"ZY1_NOMUSR"," ",40,0," "," ","C"," "," "})

// Define field values
For _nX := 1 to Len(_aFields)
	If _aFields[_nX] == "ZY1_SEQUEN"
		Aadd(_aFieldFill, "0001")
	Else
		Aadd(_aFieldFill, CriaVar(_aFields[_nX]))
	EndIf
Next _nX
Aadd(_aFieldFill, .F.)
Aadd(_aCols, _aFieldFill)

_aSize    := MsAdvSize()
_aObjects := {}

AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 015, .T., .F. } )

_aInfo   := { _aSize[ 1 ],_aSize[ 2 ],_aSize[ 3 ],_aSize[ 4 ],03,03 }
_aPosObj := MsObjSize( _aInfo, _aObjects )
_aPosGet := MsObjGetPos(_aSize[3]-_aSize[1],315,{{003,157,189,236,268}})

DEFINE MSDIALOG _oDlg TITLE "Monitoramento Pedido de Compras" FROM _aSize[7],0 to _aSize[6],_aSize[5] of oMainWnd PIXEL

	@ 035, 002 SAY _oSayPC PROMPT "N�mero PC:" SIZE 031, 007 OF _oDlg COLORS 16711680, 16777215 PIXEL
	@ 047, 002 MSGET _oGetPC VAR _cGetPC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 F3 "SC7" VALID U_ACOM017V(_cGetPC,@_cGetSC,@_cGetNF,@_dGetNE,@_cGetFR,@_nGetVL,@_cGetFO,@_cGetOR,@_cGetSP,@_dGetEE) PIXEL

	@ 035, 066 SAY _oSaySC PROMPT "N�mero Solicita��o:" SIZE 050, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 066 MSGET _oGetSC VAR _cGetSC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 122 SAY _oSayNF PROMPT "N�mero NF / Vencimento:" SIZE 080, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 122 MSGET _oGetNF VAR _cGetNF SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 394 SAY _oSayNE PROMPT "Dt. Necessidade: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 394 MSGET _oGetNE VAR _dGetNE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PICTURE READONLY PIXEL
	
	@ 035, 450 SAY _oSayEE PROMPT "Dt. Faturamento: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 450 MSGET _oGetEE VAR _dGetEE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PICTURE READONLY PIXEL

	@ 035, 500 SAY _oSayFR PROMPT "Tp Frete:" SIZE 025, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 500 MSGET _oGetFR VAR _cGetFR SIZE 030, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 590 SAY _oSayVL PROMPT "Valor: " SIZE 017, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 590 MSGET _oGetVL VAR _nGetVL SIZE 060, 010 OF _oDlg COLORS 0, 16777215 PICTURE PesqPict("SC7","C7_TOTAL") READONLY PIXEL

	@ 063, 002 SAY _oSayFO PROMPT "Fornecedor:" SIZE 031, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 002 MSGET _oGetFO VAR _cGetFO SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 063, 222 SAY _oSaySP PROMPT "Obs Pedido de Compras: " SIZE 040, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 222 MSGET _oGetSP VAR _cGetSP SIZE 336, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 091, 002 SAY _oSayOR PROMPT "Origem: " SIZE 020, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 103, 002 MSGET _oGetOR VAR _cGetOR SIZE 118, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	_oMSNewGeZY1 := MsNewGetDados():New( _aPosGet[1,1] + 115, _aPosGet[1,1] - 5, _aPosGet[1,2] - 15, _aPosGet[1,4] + _aPosGet[1,2] - _aPosObj[2,1] - 10, GD_INSERT+GD_UPDATE, "U_A017LOK()", "U_A017TOK()", "+ZY1_SEQUEN", _aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", _oDlg, _aHeader, _aCols)

ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg,{||_nOpca := 1, _oDlg:End()},{||_nOpca := 0, _oDlg:End() }) VALID U_A017TOK()

If _nOpca == 1
	Begin Transaction
		For _nX := 1 To Len(_oMSNewGeZY1:aCols)
			If !_oMSNewGeZY1:aCols[_nX, Len(_oMSNewGeZY1:aHeader) + 1]
				RecLock("ZY1", .T.)
					Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
					Replace ZY1->ZY1_NUMPC	With _cGetPC
					Replace ZY1->ZY1_SEQUEN	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_SEQUEN"})]
					Replace ZY1->ZY1_DTMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_DTMONI"})]
					Replace ZY1->ZY1_HRMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_HRMONI"})]
					Replace ZY1->ZY1_COMENT	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})]
					Replace ZY1->ZY1_CODUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_CODUSR"})]
					Replace ZY1->ZY1_NOMUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_NOMUSR"})]
					Replace ZY1->ZY1_DTNECE With _dGetNE
					Replace ZY1->ZY1_DTFAT With _dGetEE
				MsUnLock()
			EndIf
		Next
	End Transaction
EndIf

Return

/*
===============================================================================================================================
Programa----------: ACOM017A
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016 
Descri��o---------: Fun��o de Altera��o de registros
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM017A()
Local _oSayFO
Local _oGetFO
Local _cGetFO := Space(60)

Local _oSayFR
Local _oGetFR
Local _cGetFR := Space(9)

Local _oSayNE
Local _oGetNE
Local _dGetNE := StoD("")

Local _oSayNF
Local _oGetNF
Local _cGetNF := Space(60)

Local _oSayOR
Local _oGetOR
Local _cGetOR := Space(40)

Local _oSayPC
Local _oGetPC

Local _oSaySC
Local _oGetSC
Local _cGetSC := Space(TamSX3("C1_NUM")[1])

Local _oSaySP
Local _oGetSP
Local _cGetSP := Space(60)

Local _oSayVL
Local _oGetVL
Local _nGetVL := 0

Local _aPosObj	:= {}
Local _aObjects	:= {}
Local _aSize	:= {}
Local _aPosGet	:= {}
Local _aInfo	:= {}

Local _nX		:= 0
Local _nOpca	:= 0

Private _oSayEE
Private _oGetEE
Private _dGetEE := StoD("")

Private _cGetPC := ZY1->ZY1_NUMPC

Private _aTELA[0][0]
Private _aGETS[0]

Private _aHeader		:= {}
Private _aCols			:= {}
Private _aFieldFill		:= {}
Private _aFields		:= {"ZY1_SEQUEN","ZY1_DTMONI","ZY1_HRMONI","ZY1_COMENT","ZY1_CODUSR","ZY1_NOMUSR"}
Private _aAlterFields	:= {"ZY1_COMENT"}

Private _oMSNewGeZY1
Private _oDlg

If ZY1->ZY1_ENCMON == "S"
	u_itmsg('Foi encerrado o monitoramento deste pedido, sendo assim este n�o pode ser alterado.',"Aten��o",,1)
	Return
EndIf

//popula aheader
Aadd(_aHeader,   {"Sequencia"    ,"ZY1_SEQUEN"," ",4,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Dt Monitoram" ,"ZY1_DTMONI"," ",8,0," "," ","D"," "," "})
Aadd(_aHeader,   {"Hr Monitoram" ,"ZY1_HRMONI"," ",5,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Comentario"   ,"ZY1_COMENT"," ",200,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Cod Usuario"  ,"ZY1_CODUSR"," ",6,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Nome Usuario" ,"ZY1_NOMUSR"," ",40,0," "," ","C"," "," "})

U_ACOM017V(_cGetPC,@_cGetSC,@_cGetNF,@_dGetNE,@_cGetFR,@_nGetVL,@_cGetFO,@_cGetOR,@_cGetSP,@_dGetEE)

_cQryZY1 := "SELECT ZY1_SEQUEN, ZY1_DTMONI, ZY1_HRMONI, ZY1_COMENT, ZY1_CODUSR, ZY1_NOMUSR "
_cQryZY1 += "FROM " + RetSqlName("ZY1") + " "
_cQryZY1 += "WHERE ZY1_FILIAL = '" + xFilial("ZY1") + "' "
_cQryZY1 += "  AND ZY1_NUMPC = '" + _cGetPC + "' "
_cQryZY1 += "  AND D_E_L_E_T_ = ' ' "
_cQryZY1 := ChangeQuery(_cQryZY1)

MPSysOpenQuery(_cQryZY1,"TRBZY1")

dbSelectArea("TRBZY1")
TRBZY1->(dbGoTop())

If !TRBZY1->(Eof())

   A017GrvaCols()

Else
	// Define field values
	For _nX := 1 to Len(_aFields)
		If _aFields[_nX] == "ZY1_SEQUEN"
			Aadd(_aFieldFill, "0001")
		Else
			Aadd(_aFieldFill, CriaVar(_aFields[_nX]))
		EndIf
	Next _nX
	Aadd(_aFieldFill, .F.)
	Aadd(_aCols, _aFieldFill)
EndIf

TRBZY1->(dbCloseArea())

_aSize    := MsAdvSize()
_aObjects := {}

AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 015, .T., .F. } )

_aInfo   := { _aSize[ 1 ],_aSize[ 2 ],_aSize[ 3 ],_aSize[ 4 ],03,03 }
_aPosObj := MsObjSize( _aInfo, _aObjects )
_aPosGet := MsObjGetPos(_aSize[3]-_aSize[1],315,{{003,157,189,236,268}})
_dGetOri := _dGetEE

DEFINE MSDIALOG _oDlg TITLE "Monitoramento Pedido de Compras" FROM _aSize[7],0 to _aSize[6],_aSize[5] of oMainWnd PIXEL

	@ 035, 002 SAY _oSayPC PROMPT "N�mero PC:" SIZE 031, 007 OF _oDlg COLORS 16711680, 16777215 PIXEL
	@ 047, 002 MSGET _oGetPC VAR _cGetPC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 F3 "SC7" READONLY PIXEL

	@ 035, 066 SAY _oSaySC PROMPT "N�mero Solicita��o:" SIZE 050, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 066 MSGET _oGetSC VAR _cGetSC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 122 SAY _oSayNF PROMPT "N�mero NF / Vencimento:" SIZE 080, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 122 MSGET _oGetNF VAR _cGetNF SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 394 SAY _oSayNE PROMPT "Dt. Necessidade: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 394 MSGET _oGetNE VAR _dGetNE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PICTURE READONLY PIXEL
	
	@ 035, 450 SAY _oSayEE PROMPT "Dt. Faturamento: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 450 MSGET _oGetEE VAR _dGetEE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PIXEL

	@ 035, 500 SAY _oSayFR PROMPT "Tp Frete:" SIZE 025, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 500 MSGET _oGetFR VAR _cGetFR SIZE 030, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 590 SAY _oSayVL PROMPT "Valor: " SIZE 017, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 590 MSGET _oGetVL VAR _nGetVL SIZE 060, 010 OF _oDlg COLORS 0, 16777215 PICTURE PesqPict("SC7","C7_TOTAL") READONLY PIXEL

	@ 063, 002 SAY _oSayFO PROMPT "Fornecedor:" SIZE 031, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 002 MSGET _oGetFO VAR _cGetFO SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 063, 222 SAY _oSaySP PROMPT "Obs Pedido de Compras: " SIZE 040, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 222 MSGET _oGetSP VAR _cGetSP SIZE 336, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 091, 002 SAY _oSayOR PROMPT "Origem: " SIZE 020, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 103, 002 MSGET _oGetOR VAR _cGetOR SIZE 118, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	_oMSNewGeZY1 := MsNewGetDados():New( _aPosGet[1,1] + 115, _aPosGet[1,1] - 5, _aPosGet[1,2] - 15, _aPosGet[1,4] + _aPosGet[1,2] - _aPosObj[2,1] - 10, GD_INSERT+GD_UPDATE, "U_A017LOK()", "AllwaysTrue", /*"+ZY1_SEQUEN"*/, _aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", _oDlg, _aHeader, _aCols)

ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg,{||_nOpca := 1, _oDlg:End()},{||_nOpca := 0, _oDlg:End() }) VALID U_A017TOK()

If _nOpca == 1
	Begin Transaction
	
		//Atualiza a data de faturamento
		If _dGetEE != _dGetOri 
		
			U_A017DTFT(_dGetEE,_cGetPC)
			
			//Se s� tem uma linha no acols com descri��o em branco preenche descri��o para registrar mudan�a de data
			If len(_oMSNewGeZY1:aCols) == 1 .and. empty(_oMSNewGeZY1:aCols[1, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})])
			
				_oMSNewGeZY1:aCols[1, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})] := "Data de faturamento alterada de " + dtoc(_dGetOri) + " para " + dtoc(_dGetEE)
			
			Else
			   
				aadd(_oMSNewGeZY1:aCols,{	"",;//STRZERO(nMaxGravado,4),;
										date()			,;
										time()			,;
										"Data de faturamento alterada de " + dtoc(_dGetOri) + " para " + dtoc(_dGetEE)				,;
										__CUSERID 		,;
										USRFULLNAME(__CUSERID),;
										.F. })
															
		
			Endif
			
		Endif
	
		dbSelectArea("ZY1")
		ZY1->(dbSetOrder(1))

		For _nX := 1 To Len(_oMSNewGeZY1:aCols)

			If !_oMSNewGeZY1:aCols[_nX, Len(_oMSNewGeZY1:aHeader) + 1]
			
				_cSequen:=_oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_SEQUEN"})]
				If !EMPTY(_cSequen) .AND. ZY1->(dbSeek(xFilial("ZY1") + _cGetPC + _cSequen ))
					RecLock("ZY1", .F.)
						Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
						Replace ZY1->ZY1_NUMPC	With _cGetPC
						Replace ZY1->ZY1_SEQUEN	With _cSequen
						Replace ZY1->ZY1_DTMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_DTMONI"})]
						Replace ZY1->ZY1_HRMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_HRMONI"})]
						Replace ZY1->ZY1_COMENT	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})]
						Replace ZY1->ZY1_CODUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_CODUSR"})]
						Replace ZY1->ZY1_NOMUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_NOMUSR"})]
					MsUnLock()
				Else
  				    nMaxGravado++
					RecLock("ZY1", .T.)
						Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
						Replace ZY1->ZY1_NUMPC	With _cGetPC
						Replace ZY1->ZY1_SEQUEN	With STRZERO(nMaxGravado,4)
						Replace ZY1->ZY1_DTMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_DTMONI"})]
						Replace ZY1->ZY1_HRMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_HRMONI"})]
						Replace ZY1->ZY1_COMENT	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})]
						Replace ZY1->ZY1_CODUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_CODUSR"})]
						Replace ZY1->ZY1_NOMUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_NOMUSR"})]
						Replace ZY1->ZY1_DTNECE With _dGetNE
						Replace ZY1->ZY1_DTFAT With _dGetEE
					MsUnLock()
				EndIf
			EndIf
		Next
	End Transaction

    if _dGetEE = _dGetOri 
	   U_ITMSG("Grava��o completada com sucesso", "Aten��o",,2)
  	ELSE
       U_ITMSG("Data de Faturamento alterada de " + dtoc(_dGetOri) + " para " + DTOC(_dGetEE) +" e Grava��o completada com sucesso.","Aten��o",,2)
	ENDIF
EndIf

Return

/*
===============================================================================================================================
Programa----------: ACOM017V
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016 
Descri��o---------: Fun��o criada para valida��o das informa��es digitadas e carregamentos dos campos do cabe�alho
Parametros--------: _cGetPC - N�mero do Pedido de Compras
------------------: _cGetSC - Campo que receber� a informa��o da Solicita��o de Compras
------------------: _cGetNF - Campo que receber� a informa��o da Nota Fiscal de Entrada + Vencimento
------------------: _dGetNE - Campo que receber� a informa��o da Data de Necessidade
------------------: _dGetEE - Campo que receber� a informa��o da Data de Faturamento
------------------: _cGetFR - Campo que receber� a informa��o de Tipo de Frete
------------------: _nGetVL - Campo que receber� a informa��o de Valor Total do Pedido de Compras
------------------: _cGetFO - Campo que receber� a informa��o dos dados do Fornecedor
------------------: _cGetOR - Campo que receber� a informa��o dos dados de Origem (Filial de Origem)
------------------: _cGetSP - Campo que receber� a informa��o da Observa��o do Pedido de Compras
------------------: _lCriaAmb	- Indica se foi criado ambiente para JOB ou n�o
------------------: _cFilial	- Cont�m a filial do registro
Retorno-----------: _lRet - .T. Contina processo cabe�alho / .F. N�o continua processo
===============================================================================================================================
*/
User Function ACOM017V(_cGetPC,_cGetSC,_cGetNF,_dGetNE,_cGetFR,_nGetVL,_cGetFO,_cGetOR,_cGetSP,_dGetEE,_lCriaAmb,_cFilial)
Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cQrySC7	:= ""
Local _cQrySC1	:= ""
Local _cQrySE2	:= ""

Local _nTotPed	:= 0
Local _dDtNece	:= StoD("")
Local _cTpFret	:= ""
Local _cFornec	:= ""
Local _cLoja	:= ""
Local _dDtFat 	:= StoD("")
Local _cNome	:= ""
Local _cNumSC	:= ""
Local _cNumNF	:= ""
Local _cObsSC	:= ""
Local _nApoio	:= 0
Local _cFilPed	:= ""
Local _nI		:= 0

Default _cGetPC		:= ""
Default _cGetSC		:= ""
Default _cGetNF		:= ""
Default _dGetEE		:= StoD("")
Default _dGetNE		:= StoD("")
Default _cGetFR		:= ""
Default _nGetVL		:= 0
Default _cGetFO		:= ""
Default _cGetOR		:= ""
Default _cGetSP		:= ""
Default _lCriaAmb	:= .F.
Default _cFilial	:= "01"

If Empty(_cGetPC)
	U_ITMSG("Um pedido de compras deve ser selecionado.","Aten��o!",,1)
	_lRet := .F.
Else

	_cQrySC7 := "SELECT C7_FILIAL, C7_FORNECE, C7_LOJA, C7_TPFRETE, C7_DATPRF, C7_TOTAL, C7_OBS, A2_NREDUZ, A2_MUN, A2_EST, C7_I_DTFAT "
	_cQrySC7 += "FROM " + RetSqlName("SC7") + " SC7 "
	_cQrySC7 += "JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	_cQrySC7 += "WHERE C7_NUM = '" + _cGetPC + "' "
	If _lCriaAmb
		_cQrySC7 += "  AND C7_FILIAL = '" + _cFilial + "' "
	Else
		_cQrySC7 += "  AND C7_FILIAL = '" + xFilial("SC7") + "' "
	EndIf
	_cQrySC7 += "  AND SC7.D_E_L_E_T_ = ' ' "
	_cQrySC7 := ChangeQuery(_cQrySC7)
	
	MPSysOpenQuery(_cQrySC7,"TRBSC7")
	
	TRBSC7->(dbGoTop())
	
	While !TRBSC7->(Eof())
		_nI++
		_nTotPed	+= TRBSC7->C7_TOTAL
			
		//Grava maior data de faturamento e necessidade
		
		If StoD(TRBSC7->C7_I_DTFAT) > _dDtFat
		
			_dDtFat	:= StoD(TRBSC7->C7_I_DTFAT)
			
		Endif
		
		If StoD(TRBSC7->C7_DATPRF) > _dDtNece
		
			_dDtNece	:= StoD(TRBSC7->C7_DATPRF)
			
		Endif
		
		_cTpFret	:= TRBSC7->C7_TPFRETE
		_cFornec	:= TRBSC7->C7_FORNECE
		_cLoja		:= TRBSC7->C7_LOJA
		_cNome		:= AllTrim(TRBSC7->A2_NREDUZ)
		_cFilPed	:= TRBSC7->C7_FILIAL
		_cGetOR		:= AllTrim(TRBSC7->A2_MUN) + " - " + AllTrim(TRBSC7->A2_EST)

		If _nI == 1
			_cGetSP		:= TRBSC7->C7_OBS
		EndIf

		_cQrySD1 := "SELECT D1_DOC, D1_LOJA "
		_cQrySD1 += "FROM " + RetSqlName("SD1") + " "
		_cQrySD1 += "WHERE D1_PEDIDO = '" + _cGetPC + "' "
		If _lCriaAmb
			_cQrySD1 += "  AND D1_FILIAL = '" + _cFilial + "' "
		Else
			_cQrySD1 += "  AND D1_FILIAL = '" + xFilial("SD1") + "' "
		EndIf
		_cQrySD1 += "  AND D_E_L_E_T_ = ' ' "
		_cQrySD1 := ChangeQuery(_cQrySD1)
		
		MPSysOpenQuery(_cQrySD1,"TRBSD1")
			
		TRBSD1->(dbGoTop())
			
		While !TRBSD1->(Eof())
	
			_cQrySE2 := "SELECT E2_PARCELA, E2_VENCREA "
			_cQrySE2 += "FROM " + RetSqlName("SE2") + " "
			_cQrySE2 += "WHERE E2_NUM = '" + TRBSD1->D1_DOC + "' "
			If _lCriaAmb
				_cQrySE2 += "  AND E2_FILIAL = '" + _cFilial + "' "
			Else
				_cQrySE2 += "  AND E2_FILIAL = '" + xFilial("SE2") + "' "
			EndIf
			_cQrySE2 += "  AND E2_FORNECE = '" + _cFornec + "' "
			_cQrySE2 += "  AND E2_LOJA = '" + TRBSD1->D1_LOJA + "' "
			_cQrySE2 += "  AND D_E_L_E_T_ = ' ' "
			_cQrySE2 := ChangeQuery(_cQrySE2)
			
			MPSysOpenQuery(_cQrySE2,"TRBSE2")

			TRBSE2->(dbGoTop())

			While !TRBSE2->(Eof())

				If !(TRBSD1->D1_DOC + " - " + DtoC(StoD(TRBSE2->E2_VENCREA)) + " | " $ _cNumNF) 
					If !(TRBSD1->D1_DOC + " - " + TRBSE2->E2_PARCELA + " - " + DtoC(StoD(TRBSE2->E2_VENCREA)) + " | " $ _cNumNF)
						If Empty(TRBSE2->E2_PARCELA)
							_cNumNF	+= TRBSD1->D1_DOC + " - " + DtoC(StoD(TRBSE2->E2_VENCREA)) + " | "
						Else
							_cNumNF	+= TRBSD1->D1_DOC + " - " + TRBSE2->E2_PARCELA + " - " + DtoC(StoD(TRBSE2->E2_VENCREA)) + " | "
						EndIf
					EndIf
				EndIf

				TRBSE2->(dbSkip())
			End

			TRBSE2->(dbCloseArea())
	
			TRBSD1->(dbSkip())
		End
		
		_cGetNF := _cNumNF
		
		TRBSD1->(dbCloseArea())

		TRBSC7->(dbSkip())
	End
	
	_dGetEE := _dDtFat
	_nGetVL := _nTotPed
	_dGetNE := _dDtNece
	_cGetFO	:= _cFornec + "/" + _cLoja + " - " + _cNome
	
	If _cTpFret == "C"
		_cGetFR := "CIF"
	ElseIf _cTpFret == "F"
		_cGetFR := "FOB"
	ElseIf _cTpFret == "T"
		_cGetFR := "TERCEIROS"
	ElseIf _cTpFret == "S"
		_cGetFR := "SEM FRETE"
	EndIf

	TRBSC7->(dbCloseArea())
	
	_cQrySC1 := "SELECT C1_NUM, C1_OBS "
	_cQrySC1 += "FROM " + RetSqlName("SC1") + " "
	_cQrySC1 += "WHERE C1_PEDIDO = '" + _cGetPC + "' "
	If _lCriaAmb
		_cQrySC1 += "  AND C1_FILIAL = '" + _cFilial + "' "
	Else
		_cQrySC1 += "  AND C1_FILIAL = '" + xFilial("SC1") + "' "
	EndIf
	_cQrySC1 += "  AND D_E_L_E_T_ = ' ' "
	_cQrySC1 := ChangeQuery(_cQrySC1)
	MPSysOpenQuery(_cQrySC1,"TRBSC1")

	TRBSC1->(dbGoTop())
	
	While !TRBSC1->(Eof())
		_nApoio++

		_cNumSC	:= TRBSC1->C1_NUM
		If _nApoio == 1
			_cObsSC	:= AllTrim(TRBSC1->C1_OBS)
		EndIf

		TRBSC1->(dbSkip())
	End

	_cGetSC := _cNumSC

	TRBSC1->(dbCloseArea())

EndIf

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: A017LOK
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016 
Descri��o---------: Fun��o de valida��o da linha digitada
Parametros--------: Nenhum
Retorno-----------: _lRet - .T. Continua o processo / .F. Fica na linha do _aCols posicionado, n�o continua o processo
===============================================================================================================================
*/
User Function A017LOK()
Local _lRet	:= .T.

If Empty(_oMSNewGeZY1:aCols[_oMSNewGeZY1:nAt, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})])
	u_itmsg("� necess�rio o preenchimento do campo coment�rio.","Aten��o",,1)
	_lRet := .F.
EndIf

Return(_lRet)

/*
===============================================================================================================================
Programa----------: ACOM017
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016 
Descri��o---------: Fun��o de valida��o ap�s confirma��o tudook.
Parametros--------: Nenhum
Retorno-----------: _lRet - .T. Continua grava��o / .F. N�o continua com a grava��o
===============================================================================================================================
*/
User Function A017TOK()
Local _lRet	:= .T.
Local _nX	:= 0

If Empty(_cGetPC)
	u_itmsg("Dever� ser informado um Pedido de Compras.","Aten��o",,1)
	_lRet := .F.
EndIf

If _lRet 
	For _nX := 1 To Len(_oMSNewGeZY1:aCols)
		If Empty(_oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})]) .and. ;
			!(_oGetEE:ctext != _dGetOri .and. _nX == 1)
			u_itmsg("O campo coment�rio da linha " + AllTrim(Str(_nX)) + " n�o est� preenchido.","Aten��o","Favor preencher o campo corretamente.",1)
			_lRet := .F.
		EndIf
	Next _nX
EndIf

Return(_lRet)

/*
===============================================================================================================================
Programa----------: A017PLA
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 27/04/2016 
Descri��o---------: Fun��o criada para gerar tela para exporta��o dos dados para planilha
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A017PLA()
Local _aArea	:= GetArea()
Local _aCampPla	:= {	'�ndice',;
						'Nota',;
						'S�rie',;
						'Dt. Emiss�o',;
						'Dt. Digita��o',;
						'Fornecedor',;
						'Item',;
						'Produto',;
						'Descri��o',;
						'Quantidade',;
						'Pre�o Unit�rio',;
						'Valor Total'}
Local _aLogPla	:= {}
Local _cQrySD1	:= ""
Local _nCont	:= 1

_cQrySD1 := "SELECT D1_DOC, D1_EMISSAO, D1_SERIE, D1_EMISSAO, D1_DTDIGIT, D1_FORNECE, D1_LOJA, D1_ITEM, D1_COD, D1_QUANT, D1_VUNIT, D1_TOTAL, A2_NREDUZ, B1_DESC "
_cQrySD1 += "FROM " + RetSqlName("SD1") + " SD1 "
_cQrySD1 += "JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ' '"
_cQrySD1 += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = ' ' "
_cQrySD1 += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
_cQrySD1 += "  AND D1_PEDIDO = '" + ZY1->ZY1_NUMPC + "' "
_cQrySD1 += "  AND SD1.D_E_L_E_T_ = ' ' "
_cQrySD1 := ChangeQuery(_cQrySD1)

MPSysOpenQuery(_cQrySD1,"TRBSD1")

TRBSD1->(dbGoTop())

If !TRBSD1->(Eof())
	While !TRBSD1->(Eof())
		aAdd( _aLogPla , {	StrZero(_nCont++,4),;																//[1]�ndice
							TRBSD1->D1_DOC,;																	//[2]Nota
							TRBSD1->D1_SERIE,;																	//[3]S�rie
							StoD(TRBSD1->D1_EMISSAO),;											 				//[4]Dt. Emiss�o
							StoD(TRBSD1->D1_DTDIGIT),;										   					//[5]Dt. Digita��o
							TRBSD1->D1_FORNECE + "/" + TRBSD1->D1_LOJA + " - " + AllTrim(TRBSD1->A2_NREDUZ),;	//[6]Fornecedor
							TRBSD1->D1_ITEM,;														  			//[7]Item
							TRBSD1->D1_COD,;														   			//[8]Produto
							TRBSD1->B1_DESC,;																	//[9]Descri��o
							AllTrim(Transform(TRBSD1->D1_QUANT,PesqPict("SD1","D1_QUANT"))),;					//[10]Quantidade
							AllTrim(Transform(TRBSD1->D1_VUNIT,PesqPict("SD1","D1_VUNIT"))),;					//[11]Pre�o Unit�rio
							AllTrim(Transform(TRBSD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL"))) })					//[12]Valor Total
							
		TRBSD1->(dbSkip())
	End

	U_ITListBox( 'Gera��o Planilha' , _aCampPla , _aLogPla , .T. , 1 )

Else
	u_itmsg("N�o existem dados a serem mostrados para o Pedido selecionado.","Aten��o","Favor selecionar outro pedido.",1)
EndIf

TRBSD1->(dbCloseArea())

RestArea(_aArea)
Return

/*
===============================================================================================================================
Programa----------: ACOM017P
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/04/2016 
Descri��o---------: Fun��o de Inclus�o/Altera��o de registros da tabela ZY1, chamado atrav�s do menu o PC
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM017P()
Local _oSayFO
Local _oGetFO
Local _cGetFO := Space(60)

Local _oSayFR
Local _oGetFR
Local _cGetFR := Space(9)

Local _oSayNE
Local _oGetNE
Local _dGetNE := StoD("")
Local _dGetEE := StoD("")

Local _oSayNF
Local _oGetNF
Local _cGetNF := Space(60)

Local _oSayOR
Local _oGetOR
Local _cGetOR := Space(40)

Local _oSayPC
Local _oGetPC

Local _oSaySC
Local _oGetSC
Local _cGetSC := Space(TamSX3("C1_NUM")[1])

Local _oSaySP
Local _oGetSP
Local _cGetSP := Space(60)

Local _oSayVL
Local _oGetVL
Local _nGetVL := 0

Local _aPosObj	:= {}
Local _aObjects	:= {}
Local _aSize	:= {}
Local _aPosGet	:= {}
Local _aInfo	:= {}

Local _nX		:= 0
Local _nOpca	:= 0

Private _cGetPC := SC7->C7_NUM

Private _aTELA[0][0]
Private _aGETS[0]

Private _aHeader		:= {}
Private _aCols			:= {}
Private _aFieldFill		:= {}
Private _aFields		:= {"ZY1_SEQUEN","ZY1_DTMONI","ZY1_HRMONI","ZY1_COMENT","ZY1_CODUSR","ZY1_NOMUSR"}
Private _aAlterFields	:= {"ZY1_COMENT"}
Private nMaxGravado     := 0
Private _oMSNewGeZY1
Private _oDlg

//popula aheader
Aadd(_aHeader,   {"Sequencia"    ,"ZY1_SEQUEN"," ",4,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Dt Monitoram" ,"ZY1_DTMONI"," ",8,0," "," ","D"," "," "})
Aadd(_aHeader,   {"Hr Monitoram" ,"ZY1_HRMONI"," ",5,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Comentario"   ,"ZY1_COMENT"," ",200,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Cod Usuario"  ,"ZY1_CODUSR"," ",6,0," "," ","C"," "," "})
Aadd(_aHeader,   {"Nome Usuario" ,"ZY1_NOMUSR"," ",40,0," "," ","C"," "," "})

U_ACOM017V(_cGetPC,@_cGetSC,@_cGetNF,@_dGetNE,@_cGetFR,@_nGetVL,@_cGetFO,@_cGetOR,@_cGetSP,@_dGetEE)

_cQryZY1 := "SELECT ZY1_SEQUEN, ZY1_DTMONI, ZY1_HRMONI, ZY1_COMENT, ZY1_CODUSR, ZY1_NOMUSR, ZY1_ENCMON "
_cQryZY1 += "FROM " + RetSqlName("ZY1") + " "
_cQryZY1 += "WHERE ZY1_FILIAL = '" + xFilial("ZY1") + "' "
_cQryZY1 += "  AND ZY1_NUMPC = '" + _cGetPC + "' "
_cQryZY1 += "  AND D_E_L_E_T_ = ' ' "
_cQryZY1 := ChangeQuery(_cQryZY1)

MPSysOpenQuery(_cQryZY1,"TRBZY1")

TRBZY1->(dbGoTop())

If !TRBZY1->(Eof())
	If TRBZY1->ZY1_ENCMON == "S"
		u_itmsg("Foi encerrado o monitoramento deste pedido.","Aten��o","Favor consultar o monitoramento atrav�s da rotina de monitoramento.",1)
		dbSelectArea("TRBZY1")
		TRBZY1->(dbCloseArea())
		Return
	EndIf

    A017GrvaCols()

Else
	// Define field values
	For _nX := 1 to Len(_aFields)
		If _aFields[_nX] == "ZY1_SEQUEN"
			Aadd(_aFieldFill, "0001")
		Else
			Aadd(_aFieldFill, CriaVar(_aFields[_nX]))
		EndIf
	Next _nX
	Aadd(_aFieldFill, .F.)
	Aadd(_aCols, _aFieldFill)
EndIf

TRBZY1->(dbCloseArea())

_aSize    := MsAdvSize()
_aObjects := {}

AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 100, .T., .T. } )
AAdd( _aObjects, { 100, 015, .T., .F. } )

_aInfo   := { _aSize[ 1 ],_aSize[ 2 ],_aSize[ 3 ],_aSize[ 4 ],03,03 }
_aPosObj := MsObjSize( _aInfo, _aObjects )
_aPosGet := MsObjGetPos(_aSize[3]-_aSize[1],315,{{003,157,189,236,268}})
_dGetOri := _dGetEE

DEFINE MSDIALOG _oDlg TITLE "Monitoramento Pedido de Compras" FROM _aSize[7],0 to _aSize[6],_aSize[5] of oMainWnd PIXEL

	@ 035, 002 SAY _oSayPC PROMPT "N�mero PC:" SIZE 031, 007 OF _oDlg COLORS 16711680, 16777215 PIXEL
	@ 047, 002 MSGET _oGetPC VAR _cGetPC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 F3 "SC7" READONLY PIXEL

	@ 035, 066 SAY _oSaySC PROMPT "N�mero Solicita��o:" SIZE 050, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 066 MSGET _oGetSC VAR _cGetSC SIZE 039, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 122 SAY _oSayNF PROMPT "N�mero NF / Vencimento:" SIZE 080, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 122 MSGET _oGetNF VAR _cGetNF SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL
	
	@ 035, 450 SAY _oSayEE PROMPT "Dt. Faturamento: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 450 MSGET _oGetEE VAR _dGetEE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PIXEL
	
	@ 035, 394 SAY _oSayNE PROMPT "Dt. Necessidade: " SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 394 MSGET _oGetNE VAR _dGetNE SIZE 040, 010 OF _oDlg COLORS 0, 16777215 PICTURE READONLY PIXEL

	@ 035, 500 SAY _oSayFR PROMPT "Tp Frete:" SIZE 025, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 500 MSGET _oGetFR VAR _cGetFR SIZE 030, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 035, 590 SAY _oSayVL PROMPT "Valor: " SIZE 017, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 047, 590 MSGET _oGetVL VAR _nGetVL SIZE 060, 010 OF _oDlg COLORS 0, 16777215 PICTURE PesqPict("SC7","C7_TOTAL") READONLY PIXEL

	@ 063, 002 SAY _oSayFO PROMPT "Fornecedor:" SIZE 031, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 002 MSGET _oGetFO VAR _cGetFO SIZE 213, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 063, 222 SAY _oSaySP PROMPT "Obs Pedido de Compras: " SIZE 040, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 075, 222 MSGET _oGetSP VAR _cGetSP SIZE 336, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 091, 002 SAY _oSayOR PROMPT "Origem: " SIZE 020, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 103, 002 MSGET _oGetOR VAR _cGetOR SIZE 118, 010 OF _oDlg COLORS 0, 16777215 READONLY PIXEL

	_oMSNewGeZY1 := MsNewGetDados():New( _aPosGet[1,1] + 115, _aPosGet[1,1] - 5, _aPosGet[1,2] - 15, _aPosGet[1,4] + _aPosGet[1,2] - _aPosObj[2,1] - 10, GD_INSERT+GD_UPDATE, "U_A017LOK()", "AllwaysTrue", /*"+ZY1_SEQUEN"*/, _aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", _oDlg, _aHeader, _aCols)

ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg,{||_nOpca := 1, _oDlg:End()},{||_nOpca := 0, _oDlg:End() }) VALID U_A017TOK()

If _nOpca == 1

	//Atualiza a data de faturamento
	If _dGetEE != _dGetOri 
		
		U_A017DTFT(_dGetEE,_cGetPC)
		
		//Se s� tem uma linha no acols com descri��o em branco preenche descri��o para registrar mudan�a de data
		If len(_oMSNewGeZY1:aCols) == 1 .and. empty(_oMSNewGeZY1:aCols[1, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})])
			
			_oMSNewGeZY1:aCols[1, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})] := "Data de faturamento alterada de " + dtoc(_dGetOri) + " para " + dtoc(_dGetEE)
			
		Else
						
			aadd(_oMSNewGeZY1:aCols,{	"",;//STRZERO(len(_oMSNewGeZY1:aCols)+1,4),;
										date()			,;
										time()			,;
										"Data de faturamento alterada de " + dtoc(_dGetOri) + " para " + dtoc(_dGetEE)				,;
										__CUSERID 		,;
										USRFULLNAME(__CUSERID),;
										.F. })
															
				
		Endif
		
			
	Endif
	

	Begin Transaction
		For _nX := 1 To Len(_oMSNewGeZY1:aCols)
			If !_oMSNewGeZY1:aCols[_nX, Len(_oMSNewGeZY1:aHeader) + 1]
				dbSelectArea("ZY1")
				ZY1->(dbSetOrder(1))
				_cSequen:=_oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_SEQUEN"})]
				If !EMPTY(_cSequen) .AND. ZY1->(dbSeek(xFilial("ZY1") + _cGetPC + _cSequen ))
					RecLock("ZY1", .F.)
						Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
						Replace ZY1->ZY1_NUMPC	With _cGetPC
						Replace ZY1->ZY1_SEQUEN	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_SEQUEN"})]
						Replace ZY1->ZY1_DTMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_DTMONI"})]
						Replace ZY1->ZY1_HRMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_HRMONI"})]
						Replace ZY1->ZY1_COMENT	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})]
						Replace ZY1->ZY1_CODUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_CODUSR"})]
						Replace ZY1->ZY1_NOMUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_NOMUSR"})]
					ZY1->(MsUnLock())
				Else
  				    nMaxGravado++
					RecLock("ZY1", .T.)
						Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
						Replace ZY1->ZY1_NUMPC	With _cGetPC
						Replace ZY1->ZY1_SEQUEN	With STRZERO(nMaxGravado,4)
						Replace ZY1->ZY1_DTMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_DTMONI"})]
						Replace ZY1->ZY1_HRMONI	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_HRMONI"})]
						Replace ZY1->ZY1_COMENT	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_COMENT"})]
						Replace ZY1->ZY1_CODUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_CODUSR"})]
						Replace ZY1->ZY1_NOMUSR	With _oMSNewGeZY1:aCols[_nX, aScan(_oMSNewGeZY1:aHeader,{|x| AllTrim(x[2]) == "ZY1_NOMUSR"})]
						Replace ZY1->ZY1_DTNECE With _dGetNE
						Replace ZY1->ZY1_DTFAT With _dGetEE
					ZY1->(MsUnLock())
				EndIf
			EndIf
		Next
	End Transaction

    if _dGetEE = _dGetOri 
	   U_ITMSG("Grava��o completada com sucesso", "Aten��o",,2)
  	ELSE
       U_ITMSG("Data de Faturamento alterada de " + dtoc(_dGetOri) + " para " + dtoc(_dGetEE)+" e Grava��o completada com sucesso.","Aten��o",,2)
	ENDIF

EndIf

Return

/*
===============================================================================================================================
Programa----------: ACOM017E
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 28/04/2016 
Descri��o---------: Fun��o criada enviar e-mail dos monitoramentos do dia atual
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM017E()
Local _aTables		:= {"ZY1","SC7","SA2","SD1","SC1"}
Local _lCriaAmb		:= .F.
Local _aAlias		:= {}
Local _cAlias		:= ""
Local _aColumns 	:= {}
Local _cFilial		:= ""
Local _cFilBKP		:= ""
Local _cHtml		:= ""
Local _cHead		:= ""
Local _cItem		:= ""
Local _cTail		:= ""

Local _cTo			:= ""
Local _cGetCc		:= ""
Local _cMailCom		:= ""
Local _cGetAssun	:= ""
Local _cGetAnx		:= ""
Local _cQryZY1		:= ""

Local _cGetSC		:= ""
Local _cGetNF		:= ""
Local _dGetNE		:= ""
Local _cGetFR		:= ""
Local _nGetVL		:= ""
Local _cGetFO		:= ""
Local _cGetOR		:= ""
Local _cGetSP		:= ""

Local _cEmailWFC 	:= ""
Local _cEmailWFG 	:= ""
Local _dGetEE := StoD("")

Local _aConfig		:= {}
Local _cEmlLog		:= ""

Private _cPerg		:= "ACOM017"
Private _cHostWF	:= ""
Private _dDtIni		:= ""
Private _cNumPCd	:= ""
Private _cNumPCa	:= ""
Private _dDtMond	:= CtoD("//")
Private _dDtMona	:= CtoD("//")

//=============================================================
// Verifica a necessidade de criar um ambiente, caso nao esteja
// criado anteriormente um ambiente, pois ocorrera erro
//=============================================================
If Select("SX3") <= 0
	_lCriaAmb:= .T.
EndIf

If _lCriaAmb

	//=====================
	// Nao consome licensas
	//=====================
	RPCSetType(3)

	//===========================================
	// Seta o ambiente com a empresa 01 filial 01
	//===========================================
	RpcSetEnv("01","01",,,,"SCHEDULE_WF_MONITORAMENTO",_aTables)

	//========================================================================================
	// Mensagem que ficara armazenada no arquivo totvsconsole.log para posterior monitoramento
	//======================================================================================== 
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01701"/*cMsgId*/, "ACOM01701 - Gerando envio de e-mail do monitoramento dos pedidos de compras na data: " + Dtoc(DATE()) + " - " + Time()/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

EndIf

_aConfig	:= U_ITCFGEML('')
_cHostWF 	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4034/")
_dDtIni		:= DtoS(U_ItGetMv("IT_WFDTINI","20150101"))

If _lCriaAmb
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01702"/*cMsgId*/, "ACOM01702 - Carregando filiais..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	_aAlias := ACOM017M(_lCriaAmb, .T.)
Else
	If !Pergunte(_cPerg,.T.)
	     Return
	EndIf

	FwMsgRun(,{|| _aAlias := ACOM017M(_lCriaAmb, .T.)},,"Aguarde, gerando e processando e-mail...")
	
    _cAlias:= _aAlias[1]
	IF (_cAlias)->(Eof()) .AND. (_cAlias)->(BOF())
	   U_ITMSG( "N�o tem registros para esses filtros",'ATEN��O',"Selecione outros filtros e tente novamente",2 )
	   RETURN .F.
	ENDIF

	_dDtMond	:= DtoS(mv_par03)
	_dDtMona	:= DtoS(mv_par04)
EndIf

_cAlias		:= _aAlias[1]
_aColumns 	:= _aAlias[2]

(_cAlias)->(dbGoTop())

Do while !(_cAlias)->(Eof())

	_cFilial	:= (_cAlias)->ZY1_FILIAL
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01703"/*cMsgId*/, "ACOM01703 - Montando dados da filial " + _cfilial + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	_cHead := '<html>'
	_cHead += '<head>'
	_cHead += '<meta charset="UTF-8">'
	_cHead += '<meta name="description" content="Monitoramento Pedidos de Compras">'
	_cHead += '<meta name="keywords" content="HTML,CSS,XML,JavaScript">'
	_cHead += '<meta name="author" content="Darcio Ribeiro Sporl">'
	_cHead += '<title>Pedido de Compras</title>'
	_cHead += '</head>'
	
	_cHead += '<style type="text/css"><!--'
	_cHead += 'table.bordasimples { border-collapse: collapse; }'
	_cHead += 'table.bordasimples tr td { border:1px solid #777777; }'
	_cHead += 'td.grupos	{ font-family:VERDANA; font-size:20px; V-align:middle; background-color: #C6E2FF; color:#000080; }'
	_cHead += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #EEDD82; }'
	_cHead += 'td.mensagem	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
	_cHead += 'td.texto	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; }'
	_cHead += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #DDDDDD; }'
	_cHead += 'td.totais	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #7f99b2; color:#FFFFFF; }'
	_cHead += '--></style>'
	
	_cHead += '<body bgcolor="#FFFFFF">'
	_cHead += '<center>'
	_cHead += '<table width="100%" cellspacing="0" cellpadding="2" border="0">'
	_cHead += '  <tr>'
	_cHead += '    <td width="02%" class="grupos">'
	_cHead += '      <center><img src="http://www.italac.com.br/wp-content/themes/italac/assets/images/logo.svg" width="100px" height="030px"></center>'
	_cHead += '	</td>'
	_cHead += '    <td width="98%" class="grupos"><center>Lista de Monitoramento de Pedidos de Compras</center></td>'
	_cHead += '  </tr>'
	_cHead += '</table>'
	_cHead += '<table border="0" width="100%">'
	_cHead += '	<tr>'
	_cHead += '		<td valign="top" class="texto">'
	_cHead += '			<br><br>Existe(m) Pedido(s) de Compra(s) Monitorados.'
	_cHead += '		</td>'
	_cHead += '	</tr>'
	_cHead += '</table>'
	_cHead += '<br>'
	
	_cHead += '<table width="100%" border="0" CellSpacing="2" CellPadding="0">'

	_cTail := '<tr>'
	_cTail +=     '<td valign="top" align="left" colspan="13">&nbsp;</td>'
	_cTail += '</tr>'

	_cTail += '</table>'
	_cTail += '</center>'
	
	_cTail += '<br>'
	_cTail += '<br>'
	
	_cTail += '<table width="38%" border="0" CellSpacing="2" CellPadding="0">'
	_cTail += '	<tr>'
	_cTail += '		<td valign="top" align="center" class="mensagem"><font color="red">Mensagem enviada autom�tica, favor n�o responder este e-mail.</fonte></td>'
	_cTail += '	</tr>'
	_cTail += '</table>'
	
	_cTail += '</body>'
	_cTail += '</html>'

	If !(_cAlias)->(Eof())
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01704"/*cMsgId*/, "ACOM01704 - Carregando monitoramentos da filial " + _cfilial + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

		_cQryZY1 := "SELECT ZY1_FILIAL, ZY1_NUMPC, ZY1_SEQUEN, ZY1_DTMONI, ZY1_HRMONI, ZY1_COMENT, ZY1_CODUSR, ZY1_NOMUSR "
		_cQryZY1 += "FROM " + RetSqlName("ZY1") + " ZY1 "
		_cQryZY1 += "WHERE ZY1.ZY1_FILIAL = '" + (_cAlias)->ZY1_FILIAL + "'"  
		 		
		If !_lCriaAmb
			_cQryZY1 += "  AND ZY1.ZY1_DTMONI BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' "
			_cQryZY1 += "  AND ZY1.ZY1_NUMPC BETWEEN '" + MV_PAR01 + "' AND '" + mv_par02 + "' "
		EndIf
		
		_cQryZY1 += "  AND ZY1.ZY1_ENCMON <> 'S' "
		_cQryZY1 += "  AND ZY1.R_E_C_N_O_ = (SELECT MAX(ZY1A.R_E_C_N_O_) ZY1A_RECNO FROM " + RetSqlName("ZY1") + " ZY1A 
		_cQryZY1 += "                              WHERE ZY1A.ZY1_FILIAL = ZY1.ZY1_FILIAL AND ZY1A.ZY1_NUMPC = ZY1.ZY1_NUMPC AND ZY1A.D_E_L_E_T_ = ' ' "
		_cQryZY1 += "                                    AND NOT UPPER(ZY1A.ZY1_COMENT) LIKE 'DATA DE FATURAMENTO ALTERADA DE%' ) "

		_cQryZY1 += "  AND ZY1.D_E_L_E_T_ = ' ' "

		_cQryZY1 += "ORDER BY ZY1_FILIAL, ZY1_NUMPC "
		_cQryZY1 := ChangeQuery(_cQryZY1)

		MPSysOpenQuery(_cQryZY1,"TRBZY1")
		
		_ntot := 0
		_nni := 0
		
		TRBZY1->(dbGoTop())
		COUNT TO _nTot
		TRBZY1->(dbGoTop())

		_cItem := ""
		
		If !TRBZY1->(Eof())
		
			Do While !TRBZY1->(Eof())

				_nni++
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01705"/*cMsgId*/, "ACOM01705 - Carregando monitoramentos da filial " + _cfilial + " - " + strzero(_nni,6) + " de " + strzero(_ntot,6) + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

				_cItem += '<tr>'
				_cItem += 	  '<td align="center" class="totais">Filial</td>
				_cItem +=     '<td align="center" class="totais">Solicita��o</td>'
				_cItem +=     '<td align="center" class="totais">Pedido</td>'
				_cItem +=     '<td align="center" class="totais">N� da NF</td>'
				_cItem +=     '<td align="center" class="totais">Fornecedor</td>'
				_cItem +=     '<td align="center" class="totais">Origem</td>'
				_cItem +=     '<td align="center" class="totais">Dt. Necessidade</td>'
				_cItem +=     '<td align="center" class="totais">Dt. Faturamento</td>'
				_cItem +=     '<td align="center" class="totais">Frete</td>'
				_cItem +=     '<td align="center" class="totais">Valor</td>'
				_cItem +=     '<td align="center" class="totais">Obs Pedido de Compras</td>'
				_cItem += '</tr>'

				U_ACOM017V(TRBZY1->ZY1_NUMPC,@_cGetSC,@_cGetNF,@_dGetNE,@_cGetFR,@_nGetVL,@_cGetFO,@_cGetOR,@_cGetSP,@_dGetEE,_lCriaAmb,TRBZY1->ZY1_FILIAL)

				_cItem += '<tr>'
				_cItem += 	  '<td valign="top" align="left"	class="itens">' + (_cAlias)->ZY1_FILIAL + " - " + AllTrim(FwFilialName(cEmpAnt,(_cAlias)->ZY1_FILIAL)) + '</td>'
				_cItem +=     '<td valign="top" align="center"	class="itens">' + _cGetSC + '</td>'
				_cItem +=     '<td valign="top" align="center"	class="itens">' + TRBZY1->ZY1_NUMPC + '</td>'
				_cItem +=     '<td valign="top" align="left"	class="itens">' + _cGetNF + '</td>'
				_cItem +=     '<td valign="top" align="left"	class="itens">' + AllTrim(_cGetFO) + '</td>'
				_cItem +=     '<td valign="top" align="center"	class="itens">' + _cGetOR + '</td>'
				_cItem +=     '<td valign="top" align="left"	class="itens">' + DtoC(_dGetNE) + '</td>'
				_cItem +=     '<td valign="top" align="left"	class="itens">' + DtoC(_dGetEE) + '</td>'
				_cItem +=     '<td valign="top" align="center"	class="itens">' + _cGetFR + '</td>'
				_cItem +=     '<td valign="top" align="center"	class="itens">' + Transform(_nGetVL,PesqPict("SC7","C7_TOTAL")) + '</td>'
				_cItem +=     '<td valign="top" align="center"	class="itens">' + _cGetSP + '</td>'
				_cItem += '</tr>'

				_cItem += '<tr>'
				_cItem +=     '<td valign="top" align="left" colspan="13" class="itens">Status: ' + TRBZY1->ZY1_SEQUEN + " - " + DtoC(StoD(TRBZY1->ZY1_DTMONI)) + " - " + TRBZY1->ZY1_HRMONI + " - " + AllTrim(TRBZY1->ZY1_COMENT) + " ( " + TRBZY1->ZY1_CODUSR + "-" + AllTrim(TRBZY1->ZY1_NOMUSR) + " ) </td>'
				_cItem += '</tr>'

				ZY1->(dbSetOrder(1))
				ZY1->(dbSeek(TRBZY1->ZY1_FILIAL + TRBZY1->ZY1_NUMPC + TRBZY1->ZY1_SEQUEN))

				RecLock("ZY1", .F.)
					Replace ZY1->ZY1_ENVIAD With "S"
				MsUnLock()
				TRBZY1->(dbSkip())
			
			Enddo
			
		EndIf

		TRBZY1->(dbCloseArea())

		_cHtml := _cHead
		_cHtml += _cItem
		_cHtml += _cTail

		If _lCriaAmb
		 
			_cFilBKP := cFilAnt
			
 			 cFilAnt := (_cAlias)->ZY1_FILIAL

			_cEmailWFC 	:= AllTrim(U_ItGetMv("IT_EMAILWFC",""))
			_cEmailWFG 	:= AllTrim(U_ItGetMv("IT_EMAILWFG",""))

			_cTo := _cEmailWFG + ";" + _cEmailWFC

			cFilAnt := _cFilBKP

		Else

			_cEmailWFC 	:= AllTrim(U_ItGetMv("IT_EMAILWFC",""))
			_cEmailWFG 	:= AllTrim(U_ItGetMv("IT_EMAILWFG",""))

			_cTo := _cEmailWFG + ";" + _cEmailWFC
			

		EndIf

		//=================================================================
		//Chama a fun��o para cria��o do arquivo em PDF para envio em anexo
		//=================================================================
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01706"/*cMsgId*/, "ACOM01706 - Montando da filial " + _cfilial + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		A017PDF((_cAlias)->ZY1_FILIAL, @_cGetAnx, _lCriaAmb)

		_cGetAssun	:= "Lista de Monitoramento de Pedidos de Compras Filial: " + (_cAlias)->ZY1_FILIAL + " - " + AllTrim(FwFilialName(cEmpAnt,(_cAlias)->ZY1_FILIAL))

		//====================================
		// Chama a fun��o para envio do e-mail
		//====================================

		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01707"/*cMsgId*/, "ACOM01707 - Enviando email da filial " + _cfilial + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		If _cItem != ""
//          ITEnvMail(cFrom,cEmailTo,cEmailCo,cEmailBcc,cAssunto  ,cMensagem,cAttach  ,cAccount     ,cPassword    ,cServer      ,cPortCon     ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro  ,lExibeAmb)		
		  U_ITENVMAIL( ""  , _cTo   , _cGetCc,_cMailCom,_cGetAssun, _cHtml  , _cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
		  
		Endif
	
		If  !_lCriaAmb
			u_itmsg( _cEmlLog , 'T�rmino do processamento!' ,"Enviado para "+_cTo ,2 )
		Else
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01708"/*cMsgId*/, "ACOM01708 - Email monitoramento da filial " + _cfilial +  " enviado com log:  " + _cEmlLog/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf

		_cHtml := ""
		_cItem := ""

		//========================================================
		// Chama a fun��o para exclus�o do arquivo PDF do servidor
		//========================================================
		A017DEL(_cGetAnx)

	EndIf
	
	(_cAlias)->( Dbskip() )

Enddo

If _lCriaAmb

	//=============================================================
	// Limpa o ambiente, liberando a licen�a e fechando as conexoes
	//=============================================================
	RpcClearEnv()

	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01709"/*cMsgId*/, "ACOM01709 - Termino do envio do envio de monitoramento de pedidos de compras na data: " + Dtoc(DATE()) + " - " + Time()/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

EndIf

Return

/*
===============================================================================================================================
Programa----------: ACOM017M
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 28/04/2016 
Descri��o---------: Fun��o utilizada para montar a query e arquivo tempor�rio
Parametros--------: Nenhum
Retorno-----------: Array [1] - Tabela tempor�ria / [2] - Colunas do browse
===============================================================================================================================
*/
Static Function ACOM017M(_lCriaAmb, _lfiliais)
Local _cAliasTrb	:= GetNextAlias()		
Local _aFields		:= {'ZY1_NUMPC','ZY1_FILIAL'}
Local _cSelect		:= ""
Local _aStructZY1	:= ZY1->(DBSTRUCT())
Local _aColumns		:= {}
Local _nX			:= 0					
Local _cTempTab		:= "" , nX

//Variaveis utilizadas para montar o where da query, referente aos filtros preenchidos pelo usuario.
Local _cWNumPC		:= ""
Local _cWDtMon		:= ""

Default _lfiliais := .F.

ProcRegua(0)
IncProc('Inicializando a rotina...')

If !_lCriaAmb

	_cNumPCd	:= MV_PAR01
	_cNumPCa	:= mv_par02
	_dDtMond	:= DtoS(mv_par03)
	_dDtMona	:= DtoS(mv_par04)

EndIf

For _nX := 1 To Len(_aFields)
	_cSelect += _aFields[_nX] + ", "
Next _nX

If _lCriaAmb

	
	If _lfiliais
	
		
		BeginSQL alias _cAliasTrb

			SELECT DISTINCT(ZY1_FILIAL) ZY1_FILIAL
			FROM %table:ZY1% ZY1
			WHERE ZY1.%notDel%
			GROUP BY ZY1_FILIAL
			ORDER BY ZY1_FILIAL

		EndSql
	
			
	Else
	
	
		BeginSQL alias _cAliasTrb

			SELECT DISTINCT(ZY1_FILIAL) ZY1_FILIAL, ZY1_NUMPC
			FROM %table:ZY1% ZY1
			WHERE ZY1.%notDel%
			ORDER BY ZY1_FILIAL

		EndSql
		
	Endif
	
Else

	//===========================================================
	//Tratamento da clausula where do N�mero do Pedido de Compras
	//===========================================================
	_cWNumPC := "%"
	_cWNumPC += " ZY1_NUMPC BETWEEN '" + _cNumPCd + "' AND '" + _cNumPCa + "' "
	_cWNumPC += "%"
	
	//=====================================================
	//Tratamento da clausula where da Data de Monitoramento
	//=====================================================
	_cWDtMon := "%"
	_cWDtMon += " ZY1_DTMONI BETWEEN '" + _dDtMond + "' AND '" + _dDtMona + "' "
	_cWDtMon += "%"
	
	If _lfiliais
	
			BeginSQL alias _cAliasTrb

			SELECT DISTINCT(ZY1_FILIAL) ZY1_FILIAL
			FROM %table:ZY1% ZY1
			WHERE ZY1_FILIAL = %xFilial:ZY1%
			  AND %Exp:_cWNumPC%
			  AND %Exp:_cWDtMon%	
		 	  AND ZY1.%notDel%
		 	GROUP BY ZY1_FILIAL
			ORDER BY ZY1_FILIAL

		EndSql	
	
	Else
	
		BeginSQL alias _cAliasTrb

			SELECT DISTINCT(ZY1_FILIAL) ZY1_FILIAL, ZY1_NUMPC
			FROM %table:ZY1% ZY1
			WHERE ZY1_FILIAL = %xFilial:ZY1%
			  AND %Exp:_cWNumPC%
			  AND %Exp:_cWDtMon%	
		 	  AND ZY1.%notDel%
			ORDER BY ZY1_FILIAL

		EndSql
		
	Endif
		
EndIf

//----------------------------------------------------------------------
// Cria arquivo de dados tempor�rio
//----------------------------------------------------------------------
_cTempTab := GETNEXTALIAS()
_otemp := FWTemporaryTable():New( _cTempTab, _aStructZY1 )
_otemp:Create()

(_cAliasTrb)->(Dbgotop())

Do while !(_cAliasTrb)->(Eof())

	Reclock(_cTempTab,.T.)
	If _lfiliais
		(_cTempTab)->ZY1_FILIAL := (_cAliasTrb)->ZY1_FILIAL
	Else
		(_cTempTab)->ZY1_FILIAL := (_cAliasTrb)->ZY1_FILIAL
		(_cTempTab)->ZY1_NUMPC := (_cAliasTrb)->ZY1_NUMPC
	Endif
	
	(_cAliasTrb)->(Dbskip())
	
Enddo

If ( Select( _cAliasTrb ) > 0 )
	(_cAliasTrb)->(DbCloseArea())
EndIf

IncProc('Lendo os dados...')

(_cTempTab)->( DBGoTop() )

For nX := 1 To Len(_aFields)
	If _aFields[nX] $ _cSelect 
		AAdd(_aColumns,FWBrwColumn():New())

		_aColumns[Len(_aColumns)]:SetData( &("{||" + _aFields[nX] + "}") )
		_aColumns[Len(_aColumns)]:SetTitle(RetTitle(_aFields[nX])) 
		_aColumns[Len(_aColumns)]:SetSize(TamSX3(_aFields[nX])[1]) 
		_aColumns[Len(_aColumns)]:SetDecimal(TamSX3(_aFields[nX])[2])
		_aColumns[Len(_aColumns)]:SetPicture(PesqPict("ZY1",_aFields[nX]))
	EndIf
Next nX

Return( { _cTempTab , _aColumns } )

/*
===============================================================================================================================
Programa----------: A017ENC
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 28/04/2016 
Descri��o---------: Fun��o utilizada para fazer o encerramento do monitoramento.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A017ENC()
Local _aArea	:= GetArea()
Local _cNumPC	:= ZY1->ZY1_NUMPC
Local _cQryZY1	:= ""
Local _nSeq		:= 0

If ZY1->ZY1_ENCMON == "S"
	u_itmsg('O monitoramento deste pedido j� foi encerrado.','Aten��o','Favor verificar o pedido selecionado.',1)
Else
	If u_itmsg('Deseja realmente encerrar o monitoramento do pedido selecionado?',"Aten��o",,3,2,2)
		ZY1->(dbSetOrder(1))
		ZY1->(dbSeek(ZY1->ZY1_FILIAL + ZY1->ZY1_NUMPC))
	
		While !ZY1->(Eof()) .And. ZY1->ZY1_NUMPC == _cNumPC
			RecLock("ZY1", .F.)
				Replace ZY1->ZY1_ENCMON With "S"
			ZY1->(MsUnLock())
			ZY1->(dbSkip())
		EndDo

		_cQryZY1 := "SELECT ZY1_FILIAL, ZY1_NUMPC, ZY1_SEQUEN, ZY1_DTMONI, ZY1_HRMONI, ZY1_COMENT, ZY1_CODUSR, ZY1_NOMUSR "
		_cQryZY1 += "FROM " + RetSqlName("ZY1") + " "
		_cQryZY1 += "WHERE ZY1_FILIAL = '" + xFilial("ZY1") + "' "
		_cQryZY1 += "  AND ZY1_NUMPC = '" + _cNumPC + "' "
		_cQryZY1 += "  AND D_E_L_E_T_ = ' ' "
		_cQryZY1 := ChangeQuery(_cQryZY1)

		MPSysOpenQuery(_cQryZY1,"TRBZY1")

		TRBZY1->(dbGoTop())

		If !TRBZY1->(Eof())
			While !TRBZY1->(Eof())
				_nSeq++
				TRBZY1->(dbSkip())
			End

			_nSeq++

			dbSelectArea("ZY1")
			ZY1->(dbSetOrder(1))
			RecLock("ZY1",.T.)
				Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
				Replace ZY1->ZY1_NUMPC	With _cNumPC
				Replace ZY1->ZY1_SEQUEN	With StrZero(_nSeq++,4)
				Replace ZY1->ZY1_DTMONI	With dDataBase
				Replace ZY1->ZY1_HRMONI	With Time()
				Replace ZY1->ZY1_COMENT	With "********** O pedido " + _cNumPC + " foi encerrado o monitoramento. **********"
				Replace ZY1->ZY1_CODUSR	With __cUserID
				Replace ZY1->ZY1_NOMUSR	With AllTrim(UsrFullName(__cUserID))
				Replace ZY1->ZY1_ENCMON With "S"
			ZY1->(MsUnLock())
		Else
			ZY1->(dbSetOrder(1))
			RecLock("ZY1",.T.)
				Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
				Replace ZY1->ZY1_NUMPC	With _cNumPC
				Replace ZY1->ZY1_SEQUEN	With StrZero("0001",4)
				Replace ZY1->ZY1_DTMONI	With dDataBase
				Replace ZY1->ZY1_HRMONI	With Time()
				Replace ZY1->ZY1_COMENT	With "********** O pedido " + _cNumPC + " foi encerrado o monitoramento. **********"
				Replace ZY1->ZY1_CODUSR	With __cUserID
				Replace ZY1->ZY1_NOMUSR	With AllTrim(UsrFullName(__cUserID))
				Replace ZY1->ZY1_ENCMON With "S"
			ZY1->(MsUnLock())
		EndIf

	TRBZY1->(dbCloseArea())

	Else
		u_itmsg('Processo cancelado pelo usu�rio.',"Aten��o",,1)
	EndIf
EndIf

RestArea(_aArea)
Return

/*
===============================================================================================================================
Programa----------: A017LEG
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 28/04/2016 
Descri��o---------: Fun��o utilizada para montar a legenda
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A017LEG()
aLegenda :=	{	{"BR_VERDE"		, "Acima 15 Dias"		},;
				{"BR_AMARELO"	, "Entre 10 e 14 Dias"	},;
				{"BR_VERMELHO"	, "Abaixo 9 Dias"		},;
				{"BR_BRANCO"	, "Monit Encerrado"		} }

BrwLegenda("Situa��o da previs�o de faturamento","Legenda",aLegenda)

return

/*
===============================================================================================================================
Programa----------: A017PDF
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 24/05/2016 
Descri��o---------: Rotina respons�vel por emitir monitoramento em PDF
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function A017PDF(_cFilAtu, _cGetAnx, _lCriaAmb)
Local _aArea		:= GetArea()
Local _cFilial		:= SC7->C7_FILIAL
Local _cPathSrvJ	:= GETMV("MV_RELT")
Local _cQryZY1A		:= ""
Local _cFileName	:= ""

Local nLinIni		:= 90		// Linha Lateral (inicial) Esquerda
Local nColIni		:= 10		// Coluna Lateral (inicial) Esquerda
Local nColMax		:= 0835		// Para implementar layout A4
Local nLinAux		:= 0
Local nCont			:= 0

Local _cGetSC		:= ""
Local _cGetNF		:= ""
Local _dGetNE		:= StoD("")
Local _dGetEE     := Stod("")
Local _cGetFR		:= ""
Local _nGetVL		:= 0
Local _cGetFO		:= ""
Local _cGetOR		:= ""
Local _cGetSP		:= ""

Local lPagina		:= .T.

Local _nTam			:= 0
Local _nI			:= 0
Local _nIni			:= 0
Local _nIni2		:= 0
Local _nTam2		:= 0
Local _nTam3		:= 0

Private oPrint		:= Nil

//============================
// Define fontes do Relatorio
//============================
Private oFont14		:= TFont():New("Arial",,14,,.F.,,,,,.F.,.F.)
Private oFont08		:= TFont():New("Arial",,08,,.F.,,,,,.F.,.F.)


		_cFileName := "Monitoramento_" + _cfilatu + "_" + AllTrim(FwFilialName(cEmpAnt,_cfilatu)) + ".pdf"

		_cQryZY1A := "SELECT ZY1_FILIAL, ZY1_NUMPC, ZY1_SEQUEN, ZY1_DTMONI, ZY1_HRMONI, ZY1_COMENT, ZY1_CODUSR, ZY1_NOMUSR "
		_cQryZY1A += "FROM " + RetSqlName("ZY1") + " ZY1 "
		_cQryZY1A += "WHERE ZY1.ZY1_FILIAL = '" + _cfilatu + "' "
		If !_lCriaAmb
			_cQryZY1A += "  AND ZY1.ZY1_DTMONI BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "' "
			_cQryZY1A += "  AND ZY1.ZY1_NUMPC BETWEEN '" + MV_PAR01 + "' AND '" + mv_par02 + "' "
		EndIf
		_cQryZY1A += "  AND ZY1.ZY1_ENCMON <> 'S' "
		_cQryZY1A += "  AND ZY1.R_E_C_N_O_ = (SELECT MAX(ZY1A.R_E_C_N_O_) ZY1A_RECNO FROM " + RetSqlName("ZY1") + " ZY1A 
		_cQryZY1A += "                              WHERE ZY1A.ZY1_FILIAL = ZY1.ZY1_FILIAL AND ZY1A.ZY1_NUMPC = ZY1.ZY1_NUMPC AND ZY1A.D_E_L_E_T_ = ' ' "
		_cQryZY1A += "                                    AND NOT UPPER(ZY1A.ZY1_COMENT) LIKE 'DATA DE FATURAMENTO ALTERADA DE%' ) "
		_cQryZY1A += "  AND ZY1.D_E_L_E_T_ = ' ' "

		_cQryZY1A += "ORDER BY ZY1_FILIAL, ZY1_NUMPC "
		_cQryZY1A := ChangeQuery(_cQryZY1A)

		MPSysOpenQuery(_cQryZY1A,"TRBZY1A")
		
		TRBZY1A->(dbGoTop())

		If !TRBZY1A->(Eof())

			nLinIni	:= 005
			nColIni	:= 000
			nCont++

			_cFilial	:= _cfilatu

			//==========================
			// Cria Arquivo do Relatorio
			//==========================
			oPrint := FWMSPrinter():New( _cFileName , IMP_PDF , .F. , _cPathSrvJ , .T. ,,,, .T. )

			//=====================================
			// Configura modo Paisagem de Impressao
			//=====================================
			oPrint:SetLandscape()

			//=============================
			// Define impressao em papel A4
			//=============================
			oPrint:SetPaperSize(9)
			oPrint:SetMargin(0,0,0,0)	// nEsquerda, nSuperior, nDireita, nInferior
	
			//=========================================================
			// Se enviar por e-mail nao abre o arquivo apos a impressao
			//=========================================================
			oPrint:SetViewPDF(.F.)
			oPrint:cPathPDF := _cPathSrvJ	// Caso seja utilizada impress�o em IMP_PDF

			oPrint:StartPage()

			//==================================
			// Chama fun��o para desenhar o grid
			//==================================
			A017GRID(_cFilial)

			nLinAux := nLinIni + 095
			
			_nnii := 0
			_ntoti := 0
			TRBZY1A->(Dbgotop())
			Count to _ntoti
			TRBZY1A->(Dbgotop())

			While !TRBZY1A->(Eof())
			
				_nnii++
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01710"/*cMsgId*/, "ACOM01710 - Montando pdf da filial " + _cfilatu + " - Linha " + strzero(_nnii,6) + " de " + strzero(_ntoti,6) + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
			
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf
             
				U_ACOM017V(TRBZY1A->ZY1_NUMPC,@_cGetSC,@_cGetNF,@_dGetNE,@_cGetFR,@_nGetVL,@_cGetFO,@_cGetOR,@_cGetSP,@_dGetEE,_lCriaAmb,_cfilatu)

				oPrint:Say( (nLinAux) , (nColIni+015) , "Solicita��o"			, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+060) , "Pedido"				, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+100) , "Fornecedor"			, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+250) , "Origem"				, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+370) , "Dt. Nec"		     , oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+410) , "Dt. Fat"		     , oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+465) , "Frete"					, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+500) , "Valor"					, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+560) , "Obs Pedido de Compras"	, oFont08 )

				nLinAux := nLinAux + 05

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
			
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf

				oPrint:Line( nLinAux , nColIni + 10 , nLinAux , nColMax	)

				nLinAux := nLinAux + 10

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
			
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf
                     	
				oPrint:Say( (nLinAux) , (nColIni+015) , _cGetSC											, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+060) , TRBZY1A->ZY1_NUMPC								, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+100) , AllTrim(_cGetFO)								, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+250) , _cGetOR											, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+370) , DtoC(_dGetNE)									, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+410) , DtoC(_dGetEE)									, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+465) , _cGetFR											, oFont08 )
				oPrint:Say( (nLinAux) , (nColIni+500) , Transform(_nGetVL,PesqPict("SC7","C7_TOTAL"))	, oFont08 )
				If Len(AllTrim(_cGetSP)) > 60
					_nTam := Len(AllTrim(_cGetSP)) / 60
					_nTam := NoRound(_nTam,0) + 1
					_nIni := 1
					For _nI := 1 To _nTam
						oPrint:Say( (nLinAux) , (nColIni+560) , SubStr(AllTrim(_cGetSP), _nIni , 60)			, oFont08 )
						_nIni := _nIni + 60
						nLinAux := nLinAux + 08
						If nLinAux > (nLinIni+590)
							lPagina := .T.
							oPrint:EndPage()
							oPrint:StartPage()
							A017GRID(_cFilial)
					
							nLinIni	:= 095
							nLinAux := nLinIni
							nColIni	:= 000
							nCont++
						EndIf
					Next _nI
				Else
					oPrint:Say( (nLinAux) , (nColIni+560) , AllTrim(_cGetSP)			, oFont08 )
					_nIni := _nIni + 60
					nLinAux := nLinAux + 08
					If nLinAux > (nLinIni+590)
						lPagina := .T.
						oPrint:EndPage()
						oPrint:StartPage()
						A017GRID(_cFilial)
					
						nLinIni	:= 095
						nLinAux := nLinIni
						nColIni	:= 000
						nCont++
					EndIf
				EndIf

				nLinAux := nLinAux + 05

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
					
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf

				oPrint:Line( nLinAux , nColIni + 10 , nLinAux , nColMax	)

				nLinAux	:= nLinAux + 10

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
					
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf

				_cGetNF := "NF/T�tulo: " + _cGetNF

				If Len(AllTrim(_cGetNF)) > 182
					_nTam3 := Len(AllTrim(_cGetNF)) / 182
					_nTam3 := NoRound(_nTam3,0) + 1
					_nIni := 1
					For _nI := 1 To _nTam3
						oPrint:Say( (nLinAux) , (nColIni + 015) , SubStr(AllTrim(_cGetNF),_nIni,12)				, oFont08 )
						_nIni := _nIni + 12
						nLinAux := nLinAux + 08
						
						If nLinAux > (nLinIni+590)
							lPagina := .T.
							oPrint:EndPage()
							oPrint:StartPage()
							A017GRID(_cFilial)
					
							nLinIni	:= 095
							nLinAux := nLinIni
							nColIni	:= 000
							nCont++
						EndIf
					Next _nI
					
				Else
					oPrint:Say( (nLinAux) , (nColIni + 015) , AllTrim(_cGetNF)									, oFont08 )
					_nIni := _nIni + 182
					nLinAux := nLinAux + 08
					
					If nLinAux > (nLinIni+590)
						lPagina := .T.
						oPrint:EndPage()
						oPrint:StartPage()
						nLinIni	:= 095
						nLinAux := nLinIni
						nColIni	:= 000
						nCont++
					EndIf
				EndIf

				nLinAux := nLinAux + 05

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf

				oPrint:Line( nLinAux , nColIni + 10 , nLinAux , nColMax	)

				nLinAux	:= nLinAux + 10

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
				
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf

				_cStatus := AllTrim("Status: " + TRBZY1A->ZY1_SEQUEN + " - " + DtoC(StoD(TRBZY1A->ZY1_DTMONI)) + " - " + TRBZY1A->ZY1_HRMONI + " - " + AllTrim(TRBZY1A->ZY1_COMENT) + " ( " + TRBZY1A->ZY1_CODUSR + "-" + AllTrim(TRBZY1A->ZY1_NOMUSR) + " )")

				If Len(_cStatus) > 182
					_nTam2 := Len(_cStatus) / 182
					_nTam2 := NoRound(_nTam2,0) + 1
					_nIni2 := 1
					For _nI := 1 To _nTam2
						oPrint:Say( (nLinAux) , (nColIni + 015) , SubStr(_cStatus, _nIni2, 182)	, oFont08 )
						_nIni2 := _nIni2 + 182
						nLinAux := nLinAux + 08
						If nLinAux > (nLinIni+590)
							lPagina := .T.
							oPrint:EndPage()
							oPrint:StartPage()
							A017GRID(_cFilial)
					
							nLinIni	:= 095
							nLinAux := nLinIni
							nColIni	:= 000
							nCont++
						EndIf
					Next _nI
				Else
					oPrint:Say( (nLinAux) , (nColIni+015) , _cStatus	, oFont08 )
					_nIni2 := _nIni2 + 182
					nLinAux := nLinAux + 08
					If nLinAux > (nLinIni+590)
						lPagina := .T.
						oPrint:EndPage()
						oPrint:StartPage()
						A017GRID(_cFilial)
				
						nLinIni	:= 095
						nLinAux := nLinIni
						nColIni	:= 000
						nCont++
					EndIf
				EndIf

				nLinAux := nLinAux + 05

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
			
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf

				oPrint:Line( nLinAux , nColIni + 10 , nLinAux , nColMax	)

				nLinAux := nLinAux + 20

				If nLinAux > (nLinIni+590)
					lPagina := .T.
					oPrint:EndPage()
					oPrint:StartPage()
					A017GRID(_cFilial)
			
					nLinIni	:= 095
					nLinAux := nLinIni
					nColIni	:= 000
					nCont++
				EndIf

				TRBZY1A->(dbSkip())
			End
			
			oPrint:EndPage()
			oPrint:lViewPDF := .F.
			oPrint:Preview()
			FreeObj(oPrint)
			
		EndIf

		TRBZY1A->(dbCloseArea())

If File(_cPathSrvJ + _cFileName)
	_cGetAnx := _cPathSrvJ + _cFileName
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: A017GRID
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/05/2016 
Descri��o---------: Rotina respons�vel por criar o layout de impress�o
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function A017GRID(_cFilial)
Local nLinIni		:= 0		// Linha Lateral (inicial) Esquerda
Local nColIni		:= 0		// Coluna Lateral (inicial) Esquerda
Local nLinMax		:= 0600		// Para implementar layout A4
Local nColMax		:= 0835		// Para implementar layout A4
Local cPathImg		:= GetSrvProfString("Startpath","")
Local cFileImg		:= ""

nLinIni	:= 013
nColIni	:= 000

cFileImg := cPathImg + "LGRL01.BMP"

//==============
// Box Principal
//==============
oPrint:Box( nLinIni, nColIni + 010, nLinMax, nColMax, "-4")

nLinIni := nLinIni + 10

//=========
// Logotipo
//=========
oPrint:SayBitmap( nLinIni, nColIni + 018 , cFileImg , 170 , 058 )

oPrint:Say( (nLinIni+025) , (nColIni+350) , "LISTA DE MONITORAMENTO DE PEDIDOS DE COMPRAS" , oFont14 )

oPrint:Say( (nLinIni+045) , (nColIni+450) , _cFilial + " - " + AllTrim(FwFilialName(cEmpAnt,_cFilial)) , oFont14 )

nLinIni := nLinIni + 60

//=================
// Linha Horizontal
//=================
oPrint:Line( nLinIni, nColIni + 10 , nLinIni , nColMax	)

Return

/*
===============================================================================================================================
Programa----------: A017DEL
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 25/05/2016 
Descri��o---------: Fun��o respons�vel pela exclus�o do arquivo pdf gerado no servidor.
Parametros--------: cFile - Caminho + nome do arquivo pdf
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function A017DEL(cFile)
Local nRet := 0

If File(cFile)
	nRet := fErase(cFile)
	If nRet <> 0
		FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01711"/*cMsgId*/, "ACOM01711 - Erro ao excluir o arquivo: " + cFile + " - Erro: " + str(FError())/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "ACOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "ACOM01712"/*cMsgId*/, "ACOM01712 - Arquivo: " + cFile + " foi exclu�do com sucesso."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa----------: A017DTFT
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 06/06/2016 
Descri��o---------: Rotina para altera��o de data de faturamento por pedido de compras.
Parametros--------: _ddtfat - data para grava��o autom�tica
					_cGetPC - pedido de compras
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A017DTFT(_ddtfat,_cGetPC)

Local aArea			:= GetArea()
Local cGet1			:= StoD("//")
Local nX			:= 0
Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()
Local aHeader		:= {}
Local aCols			:= {}
Local aRecnos		:= {}
Local aAlterFields	:= {}
Local nOpc			:= 0
Local aRecnos2	    := {}
Local _cMotivo   	:= SPACE(LEN(ZY1->ZY1_COMENT))

Local oGet1
Local oSayNDF
Local oSButton1
Local oSButton2

Default _ddtfat := stod("20010101")//Controle quando vem direto do menu do monitor e do PC
Default _cGetPC := SC7->C7_NUM

Private oDlg
Private oMSNewSC7

dbSelectArea("SY1")
SY1->(dbSetOrder(3)) //Y1_FILIAL + Y1_USER
If SY1->(dbSeek(xFilial("SY1") + __cUserID))
	
	//popula aheader
	Aadd(aHeader,   {"Numero PC   "    	,"C7_NUM"		," ",6	,0," "," ","C"," "," "})
	Aadd(aHeader,   {"Tipo" 				,"C7_TIPO"		," ",1	,0," "," ","N"," "," "})
	Aadd(aHeader,   {"Hr Monitoram" 		,"C7_ITEM"		," ",4	,0," "," ","C"," "," "})
	Aadd(aHeader,   {"Produto     "   		,"C7_PRODUTO"	," ",15	,0," "," ","C"," "," "})
	Aadd(aHeader,   {"Descricao   "  		,"C7_DESCRI"	," ",100,0," "," ","C"," "," "})
	Aadd(aHeader,   {"Dt Faturado " 		,"C7_I_DTFAT"	," ",8	,0," "," ","D"," "," "})
	Aadd(aHeader,   {"Raz�o Social" 		,"A2_NOME"		," ",40	,0," "," ","C"," "," "})
	
	
	// Somente sao selecionados itens que nao possuem restricoes
	cQry := "SELECT C7_NUM,C7_TIPO,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_I_DTFAT,C7_FORNECE,C7_LOJA,SC7.R_E_C_N_O_ AS RECSC7,A2_NOME "
	cQry += "FROM " + RetSqlName("SC7") + " SC7 "
	cQry += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	cQry += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQry += "  AND C7_NUM = '" + _cGetPC + "' "
	cQry += "  AND ((C7_QUJE < C7_QUANT "
	cQry += "  OR C7_QTDACLA > 0 ) "
	cQry += "  AND C7_RESIDUO <> 'S') "
	cQry += "  AND SC7.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)

	MPSysOpenQuery(cQry,cAliasQry)

	(cAliasQry)->( DBGoTop() )
	
	If !(cAliasQry)->(Eof())
	
		While (cAliasQry)->(!Eof())
			Aadd(aCols,		{(cAliasQry)->C7_NUM, (cAliasQry)->C7_TIPO, (cAliasQry)->C7_ITEM, (cAliasQry)->C7_PRODUTO, (cAliasQry)->C7_DESCRI, StoD((cAliasQry)->C7_I_DTFAT), (cAliasQry)->A2_NOME,.F.})
			Aadd(aRecnos,	(cAliasQry)->RECSC7)
			(cAliasQry)->(dbSkip())
		End
		
		_npos := ZY1->( Recno() )
		
		_cfilial := xFilial("SC7")
		_cnumpc := _cGetPC

		ZY1->( Dbgotop() )
		ZY1->( Dbseek( _cfilial + _cnumpc) )
		
		
		Do while ZY1->(!Eof()) .And. _cfilial == ZY1->ZY1_FILIAL .and. _cnumpc == ZY1->ZY1_NUMPC
		
			Aadd(aRecnos2, ZY1->( Recno() ) )
			
			ZY1->( Dbskip() )
			
		Enddo
		
		ZY1->( Dbgoto(_npos) )
		
		cGet1 :=  ZY1->ZY1_DTFAT  
		
		If _ddtfat == stod("20010101")
		
			DEFINE MSDIALOG oDlg TITLE "Pedido de Compra - Alt.Dt.Fat.PC" FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL
	
				oMSNewSC7 := MsNewGetDados():New( 001, 002, 101, 348, , "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader, aCols)

			    @ 109, 002 SAY oSayNDF PROMPT "Nova Data Faturamento: " SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
			    @ 107, 064 MSGET oGet1 VAR cGet1 SIZE 055, 010 OF oDlg VALID U_VLDDTFAT(cGet1,2,aRecnos) COLORS 0, 16777215 PIXEL

			    @ 109, 125 SAY "Comentario:" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
			    @ 107, 155 MSGET _cMotivo    SIZE 190, 010 OF oDlg COLORS 0, 16777215 PIXEL			

				DEFINE SBUTTON oSButton1 FROM 129, 142 TYPE 01 OF oDlg ENABLE ACTION (nOpc := 1, oDlg:End())
				DEFINE SBUTTON oSButton2 FROM 129, 175 TYPE 02 OF oDlg ENABLE ACTION (nOpc := 2, oDlg:End())
	
			ACTIVATE MSDIALOG oDlg CENTERED
			
		Else
		
			nOpc := 1
			cGet1 := _ddtfat
			
		Endif
		
		If nOpc == 1
			If U_VLDDTFAT(cGet1,2,aRecnos)

		        _dDataOld:=CTOD("")
				dbSelectArea("SC7")
				For nX := 1 To Len(aRecnos)
					SC7->(dbGoTo(aRecnos[nX]))
			        _dDataOld:=SC7->C7_I_DTFAT
					RecLock("SC7",.F.)
					SC7->C7_I_DTFAT := cGet1
					SC7->(MsUnLock() )
				Next nX
				
				_nmax := 1
				dbSelectArea("ZY1")
				For nX := 1 To Len(aRecnos2)
					ZY1->(dbGoTo(aRecnos2[nX]))
					If val(ZY1->ZY1_SEQUEN) > _nmax
						_nmax := val(ZY1->ZY1_SEQUEN)
					Endif
					RecLock("ZY1",.F.)
					ZY1->ZY1_DTFAT :=cGet1
					ZY1->(MsUnLock())
				Next nX
				
  	            If _ddtfat == stod("20010101")
	            
	            	//Cria registro de mudan�a da data de faturamento
	            	ZY1->(Reclock("ZY1",.T.))
	            	ZY1->ZY1_FILIAL := xfilial("ZY1")
	            	ZY1->ZY1_SEQUEN := STRZERO(_nmax,4)
	            	ZY1->ZY1_NUMPC  := SC7->C7_NUM
	            	ZY1->ZY1_DTMONI := DATE()
	            	ZY1->ZY1_HRMONI := TIME()
                    IF EMPTY(_cMotivo)
                       ZY1->ZY1_COMENT:="Data de faturamento alterada de " + dtoc(_dDataOld) + " para " + DTOC(SC7->C7_I_DTFAT)
                    ELSE
                       ZY1->ZY1_COMENT:=_cMotivo
                    ENDIF   	            	
	            	ZY1->ZY1_CODUSR := __CUSERID                                                                                                                       
	            	ZY1->ZY1_NOMUSR := USRFULLNAME(__CUSERID)
	            	ZY1->ZY1_DTFAT  := SC7->C7_I_DTFAT
	            	ZY1->ZY1_DTNECE := SC7->C7_DATPRF  
	            	ZY1->(Msunlock())

	            	
  	            Endif

                //Atualiza tabela ZZH de indicaores de pagamentos para pedidos de compra
                U_ACOM008ZZH(alltrim(SC7->C7_FILIAL), alltrim(SC7->C7_NUM))	//Fica depois pq desposiciona o SC7

  	            If _ddtfat == stod("20010101")
	            	U_ITMSG("Data de Faturamento alterada de " + dtoc(_dDataOld) + " para " + DTOC(cGet1) +" com sucesso.","Aten��o",,2)
	            ENDIF	
	            
			Else
				u_itmsg("Processo n�o p�de ser finalizado.","Aten��o",,1)
			EndIf
		EndIf
		
	Else
	
		u_ITMSG("Pedido n�o pode sofrer altera��o de data de faturamento." , "Aten��o","Pedido j� recebeu movimento de faturamento",1)
	
	EndIf
	
	(cAliasQry)->( DBCloseArea() )
Else
				
	U_ITMSG("Usu�rio Inv�lido, O usu�rio: " + USRFULLNAME(__CUSERID) + " n�o possui acesso para alterar data de faturamento.", "Aten��o", "Verifique o cadastro deste usu�rio como comprador.",1)
	
EndIf

RestArea(aArea)

Return


/*
===============================================================================================================================
Programa----------: A017GrvaCols()
Autor-------------: Alex Wallauer
Data da Criacao---: 20/09/2018 
Descri��o---------: Rotina para carregar acols
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function A017GrvaCols()
nMaxGravado:=0
DO WHILE !TRBZY1->(Eof())
    
    IF ! "DATA DE FATURAMENTO ALTERADA DE" $ UPPER(TRBZY1->ZY1_COMENT)
	   AADD(_aCols,{TRBZY1->ZY1_SEQUEN, STOD(TRBZY1->ZY1_DTMONI), TRBZY1->ZY1_HRMONI, TRBZY1->ZY1_COMENT, TRBZY1->ZY1_CODUSR, TRBZY1->ZY1_NOMUSR, .F.})
	ENDIF   
    IF VAL(TRBZY1->ZY1_SEQUEN) > nMaxGravado
       nMaxGravado:=VAL(TRBZY1->ZY1_SEQUEN)
    ENDIF   

    TRBZY1->(dbSkip())
ENDDO                 

RETURN LEN(_aCols)
