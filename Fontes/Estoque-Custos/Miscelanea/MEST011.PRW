/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 27/04/2017 | Chamado 19813. Inclusão da função de Log ITLOGACS().
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 11/06/2019 | Chamado 29593. Ajustes para loboguara
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/09/2024 | Chamado 48465. Removendo warning de compilação.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MEST011
Autor-------------: Josué Danich Prestes
Data da Criacao---: 08/01/2015
===============================================================================================================================
Descrição---------: Geração planilhas de suporte ao fechamento de custo médio - Chamado 9696
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MEST011()


Local _cPerg   	:="MEST011"
Local _bprocess	:= nil
Local _oprocess	:= nil

Private _lsai		:= .F.

Do While .not. _lsai
	_lsai := .T.
	//============================================
	//Cria interface principal
	//============================================
	_bProcess    := {|_oprocess| MEST011PR(_oprocess) }
	tNewProcess():New( _cPerg, "Geração de planilhas de suporte ao fechamento de custo",;
								 _bProcess, "Rotina de geracao de planilhas de suporte ao fechamento de custo","MEST011")
EndDo

Return

/*
===============================================================================================================================
Programa----------: MEST011PR
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Processamento principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST011PR(_oProcess)

Local _cHRINI		:= TIME()
Local _aSTRU		:= {}
Local _cARQTMPES	:= ""
Local _cARQTMP	:= ""
Private MV_PAR07 	:= 2 //Definido aqui para poder trabalhar sem a pergunta no SX1 quando necessário

Private _nSeqCalc	:=STRZERO(1,10)

_lsai := .F.  //Se veio para rotina não sai da tela principal

If MV_PAR07==1
	_oProcess:SetRegua2(11)
Else
	_oProcess:SetRegua2(10)
EndIf

_oProcess:IncRegua2("Saldos Iniciais")
PROCESSMESSAGES()
_oProcess:SaveLog( "Iniciada geração de planilhas - " + dtoc(date()) + " - " + _cHrini + " - " + cusername )

If LastKey() == 27
	Return
EndIf

AADD(_aSTRU,{"ARMAZ"      ,"C", 02,0})
AADD(_aSTRU,{"PRODUTO"    ,"C", 15,0})
AADD(_aSTRU,{"TIPO"       ,"C", 02,0})
AADD(_aSTRU,{"GRUPO"      ,"C", 02,0})
AADD(_aSTRU,{"UNMED"      ,"C", 05,0})
AADD(_aSTRU,{"DATASLD"    ,"D", 08,0})
AADD(_aSTRU,{"QTDE"       ,"N", 12,2})
AADD(_aSTRU,{"CUSTO"      ,"N", 14,2})
AADD(_aSTRU,{"CMCALC"     ,"N", 20,4})
AADD(_aSTRU,{"CST_SIGA"   ,"N", 12,2})
AADD(_aSTRU,{"CM_SIGA"    ,"N", 14,4})
AADD(_aSTRU,{"QTDE_CALC"  ,"N", 14,2})
AADD(_aSTRU,{"CSTQ_CALC"  ,"N", 20,2})
AADD(_aSTRU,{"DIF_CST"    ,"N", 14,2})  //CUSTO - CST_SIGA
AADD(_aSTRU,{"PVAR_CM"    ,"N", 14,2})  // % DE VARIACAO DO CUSTO MÉDIO(CMCALC) EM RELACAO AO HISTÓRICO(HIST_CM)

If Select("TEMPOES") <> 0
	TEMPOES->(DBCloseArea())
EndIf

_otemp := FWTemporaryTable():New( "TEMPOES", _aSTRU)

_otemp:AddIndex( "01", {"ARMAZ", "PRODUTO","DATASLD"} )
_otemp:Create()

_aSTRU:={}
AADD(_aSTRU,{"ARMAZ"      ,"C", 02,0})
AADD(_aSTRU,{"PRODUTO"    ,"C", 15,0})
AADD(_aSTRU,{"TIPO"       ,"C", 02,0})
AADD(_aSTRU,{"GRUPO"      ,"C", 02,0})
AADD(_aSTRU,{"UNMED"      ,"C", 05,0})
AADD(_aSTRU,{"DATAMOV"    ,"D", 08,0})
AADD(_aSTRU,{"DOC"        ,"C", 09,0})
AADD(_aSTRU,{"SIGA_CF"    ,"C", 03,0})
AADD(_aSTRU,{"SIGA_TPMOV" ,"C", 03,0})
AADD(_aSTRU,{"OP"         ,"C", 13,0})
AADD(_aSTRU,{"QTDE"       ,"N", 12,2})
AADD(_aSTRU,{"VLRSIGA"    ,"N", 12,2})
AADD(_aSTRU,{"VLRCALC"    ,"N", 20,2})
AADD(_aSTRU,{"CMCALC"     ,"N", 20,4})
AADD(_aSTRU,{"PRIORIDADE" ,"C", 03,0})
AADD(_aSTRU,{"TRANSACAO"  ,"C", 04,0})
AADD(_aSTRU,{"NUMSEQ"     ,"C", 06,0})
AADD(_aSTRU,{"SEQCALCULO" ,"C", 10,0})

AADD(_aSTRU,{"ORIGEM"     ,"C", 03,0})
AADD(_aSTRU,{"TIPONF"     ,"C", 01,0})
AADD(_aSTRU,{"QTDACM"     ,"N", 14,2})
AADD(_aSTRU,{"CSTACM"     ,"N", 24,2})
AADD(_aSTRU,{"CMACM"      ,"N", 20,4})
AADD(_aSTRU,{"TES"        ,"C",  3,0})
AADD(_aSTRU,{"TES_PODER3" ,"C",  1,0})
AADD(_aSTRU,{"IDENTB6"    ,"C",  6,0})
AADD(_aSTRU,{"USUARIO"    ,"C", 15,0})  // USUÁRIO QUE EFETUOU O LANÇAMENTO (SD3)

If Select("TEMPO") <> 0
	TEMPO->(DBCloseArea())
EndIf

_otemp := FWTemporaryTable():New( "TEMPO", _aSTRU)

_otemp:AddIndex( "01", {"ARMAZ", "PRODUTO","DATAMOV","SEQCALCULO"} )
_otemp:AddIndex( "02", {"OP", "PRIORIDADE","DATAMOV","SEQCALCULO"} )
_otemp:AddIndex( "03", {"OP", "DATAMOV"} )
_otemp:Create()

MEST011B9(_oProcess)

_oProcess:IncRegua2("Notas de Entrada")
PROCESSMESSAGES()
MEST011D1(_oProcess)

_oProcess:IncRegua2("Movtos Internos") 
PROCESSMESSAGES()
MEST011D3(_oProcess)

_oProcess:IncRegua2("Notas de saída") 
PROCESSMESSAGES()
MEST011D2(_oProcess)

_oProcess:IncRegua2("Calculo 1/4") 
PROCESSMESSAGES()
MEST011PV(_oProcess)

_oProcess:IncRegua2("Calculo 2/4") 
PROCESSMESSAGES()
MEST011PV(_oProcess)

_oProcess:IncRegua2("Calculo 3/4") 
PROCESSMESSAGES()
MEST011PV(_oProcess)

_oProcess:IncRegua2("Calculo 4/4") 
PROCESSMESSAGES()
MEST011PV(_oProcess)

_oProcess:IncRegua2("Gera saldos finais") 
PROCESSMESSAGES()
MEST011GE(_oProcess)

If MV_PAR07==1
	_oProcess:IncRegua2("Limpando Armazens") 
	PROCESSMESSAGES()
	MEST011LA(_oProcess)
EndIf

//Gera arquivo de exportação
_oProcess:IncRegua2("Gerando planilhas") 
PROCESSMESSAGES()
MEST011GA(_cARQTMP,_cARQTMPES,_cHRINI,_oprocess)

//========================================================================
// Grava log de Geração planilhas de suporte ao fechamento de custo médio
//======================================================================== 
U_ITLOGACS('MEST011')

Return

/*
===============================================================================================================================
Programa----------: MEST011B9
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Carga de dados do SB9
===============================================================================================================================
Parametros--------: _oProcess - Objeto da tela principal
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST011B9(_oProcess)

Local _dDtAux	:= MV_PAR01-1

SB1->(DBSetOrder(1))

DBSelectArea("SB9")
SB9->(DBSetOrder(3))

_oProcess:SetRegua1(SB9->(RECCOUNT()))

SB9->(DBSeek(xFilial("SB9")+DTOS(_dDtAux),.T.))

Do While (xFilial("SB9")+DTOS(SB9->B9_DATA)==xFilial("SB9")+DTOS(_dDtAux)) .AND. (! EOF())

	_oProcess:IncRegua1("Data-Produto: " + DTOC(SB9->B9_DATA) + "-" + SB9->B9_COD)//Incrementa primeira régua
	PROCESSMESSAGES()
	
	If (SB9->B9_DATA <> _dDtAux)
		DBSkip()
		Loop
	EndIf

	DBSelectArea("TEMPO")
	DBAppend()
	_FIELD->ARMAZ      := SB9->B9_LOCAL
	_FIELD->PRODUTO    := SB9->B9_COD
	_FIELD->TIPO       := RETFIELD("SB1",1,xFilial("SB1")+SB9->B9_COD,"SB1->B1_TIPO")
	_FIELD->GRUPO      := RETFIELD("SB1",1,xFilial("SB1")+SB9->B9_COD,"SB1->B1_GRUPO")
	_FIELD->UNMED      := RETFIELD("SB1",1,xFilial("SB1")+SB9->B9_COD,"SB1->B1_UM")
	_FIELD->DATAMOV    := SB9->B9_DATA
	_FIELD->DOC        := ""
	_FIELD->OP         := ""
	_FIELD->SIGA_CF    := ""
	_FIELD->SIGA_TPMOV := ""
	_FIELD->QTDE       := SB9->B9_QINI
	_FIELD->VLRSIGA    := SB9->B9_VINI1
	_FIELD->VLRCALC    := SB9->B9_VINI1
	_FIELD->CMCALC     := (VLRCALC/QTDE)
	_FIELD->PRIORIDADE := "100"
	_FIELD->TRANSACAO  := STRZERO(1,4)   //4 DIGITOS
	_FIELD->NUMSEQ     := "000000"
	_FIELD->SEQCALCULO := _nSeqCalc
	_FIELD->ORIGEM     := "SB9"
	
	_nSeqCalc	:= STRZERO( (VAL(_nSeqCalc) + 1) ,10)
	
	SB9->(DBSkip())	
EndDo

Return

/*
===============================================================================================================================
Programa----------: MEST011D1
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Carga de dados do SD1
===============================================================================================================================
Parametros--------: _oProcess - Objeto da tela principal
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MEST011D1(_oProcess)

Local _aAREAD1 := {}
Local _aAREAD2 := {}
Local _nAREAANT := ""

SB1->(DBSetOrder(1))
SF4->(DBSetOrder(1))

DBSelectArea("SD1")
SD1->(DBSetOrder(6))

_oProcess:SETREGUA1(SD1->(RECCOUNT()))

SD1->(DBSeek(xFilial("SD1")+DTOS(MV_PAR01),.T.))

Do While (D1_FILIAL+DTOS(D1_DTDIGIT)<=xFilial("SD1")+DTOS(MV_PAR02)) .AND. (! EOF())

	_oProcess:INCREGUA1("Data: "+DTOC(D1_DTDIGIT))
	PROCESSMESSAGES()
	SF4->(DBSeek(xFilial("SF4")+SD1->D1_TES))

	If (SF4->F4_ESTOQUE<>"S") .OR. (RTrim(SD1->D1_COD)=="SERVICOS")
		SD1->(DBSkip())
		Loop
	EndIf

	DBSelectArea("TEMPO")
	DBAppend()
	_FIELD->ARMAZ      := SD1->D1_LOCAL
	_FIELD->PRODUTO    := SD1->D1_COD
	_FIELD->TIPO       := RETFIELD("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_TIPO")
	_FIELD->GRUPO      := RETFIELD("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_GRUPO")
	_FIELD->UNMED      := RETFIELD("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_UM")
	_FIELD->DATAMOV    := SD1->D1_DTDIGIT
	_FIELD->DOC        := SD1->D1_DOC
	_FIELD->OP         := ""
	_FIELD->SIGA_CF    := ""
	_FIELD->SIGA_TPMOV := ""
	_FIELD->QTDE       := SD1->D1_QUANT
	_FIELD->VLRSIGA    := SD1->D1_CUSTO

	If RTrim(SD1->D1_TIPO)=="D"

		_FIELD->VLRCALC   := SD1->D1_CUSTO  // Alterado para sempre pegar o custo do siga que é sempre igual ao da NF original.
		_FIELD->CMCALC    := (VLRCALC/QTDE) //      ||
		_FIELD->TRANSACAO := STRZERO(300,4)   //4 DIGITOS
		
		If (VLRCALC==0)  //2010 07 01  QDO DEV E O CUSTO FOR ZERO VAI BUSCAR CUSTO MEDIO DA NF ORIGEM SE A MESMA EXISTIR NO SD2

			_nAREAANT	:=	SELECT()
			_aAREAD1	:=	SD1->(GETAREA())
			_aAREAD2	:=	SD2->(GETAREA())
			
			SD2->(DBSetOrder(3))  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(DBSeek(xFilial("SD2") + RTrim(SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI)))

			If SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_ITEM == ;
					xFilial("SD2") + RTrim(SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI)
				_FIELD->CMCALC    := SD2->(D2_CUSTO1/D2_QUANT)
				_FIELD->VLRCALC   := _FIELD->CMCALC * SD1->D1_QUANT
			EndIf

			RestArea(_aAREAD1)
			RestArea(_aAREAD2)
			
			DBSelectArea(_nAREAANT)

		EndIf
		
	Else

		_FIELD->VLRCALC   := SD1->D1_CUSTO
		_FIELD->CMCALC    := (_FIELD->VLRCALC / _FIELD->QTDE)
		_FIELD->TRANSACAO := STRZERO(100,4)   //4 DIGITOS

	EndIf

	_FIELD->PRIORIDADE := "100"
	_FIELD->NUMSEQ     := SD1->D1_NUMSEQ
	_FIELD->SEQCALCULO := _nSeqCalc
	_FIELD->ORIGEM     := "SD1"
	_FIELD->TIPONF     := SD1->D1_TIPO
	
	_FIELD->TES        := SD1->D1_TES
	_FIELD->TES_PODER3 := SF4->F4_PODER3
	_FIELD->IDENTB6    := SD1->D1_IDENTB6
	
	_nSeqCalc	:= STRZERO( (VAL(_nSeqCalc) + 1) ,10)
	
	SD1->( DBSkip() )

EndDo

Return

/*
===============================================================================================================================
Programa----------: MEST011D3
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Carga de dados do SD3
===============================================================================================================================
Parametros--------: _oProcess - objeto da tela principal
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MEST011D3(_oProcess)

Local _cDocAce	:= "AC"+SUBSTR(DTOS(MV_PAR02),3,4)
Local _cTmpVal		:= ""

SB1->(DBSetOrder(1))

DBSelectArea("SD3")
SD3->(DBSetOrder(6))

_oProcess:Setregua1(SD3->(RECCOUNT()))

SD3->(DBSeek(xFilial("SD3") + DTOS(MV_PAR01),.T.))

Do While (SD3->D3_FILIAL + DTOS(SD3->D3_EMISSAO) <= xFilial("SD3") + DTOS(MV_PAR02)) .AND. (! EOF())

	_oProcess:INCREGUA1("Data: " + DTOC(SD3->D3_EMISSAO))
	PROCESSMESSAGES()
	
	_cTmpVal := RETFIELD("SF5",1,xFilial("SF5") + SD3->D3_TM,"SF5->F5_VAL")
	
	If (SD3->D3_ESTORNO == "S") .OR. ( ( _cTmpVal == "S" .AND. SD3->D3_QUANT == 0) .AND. (MV_PAR05 == 2) )
		SD3->( DBSkip() )
		Loop
	EndIf
	
	DBSelectArea("TEMPO")
	DBAppend()
	_FIELD->ARMAZ     := SD3->D3_LOCAL
	_FIELD->PRODUTO   := SD3->D3_COD
	_FIELD->TIPO      := RETFIELD("SB1",1,xFilial("SB1") + SD3->D3_COD,"SB1->B1_TIPO")
	_FIELD->GRUPO     := RETFIELD("SB1",1,xFilial("SB1") + SD3->D3_COD,"SB1->B1_GRUPO")
	_FIELD->UNMED     := RETFIELD("SB1",1,xFilial("SB1") + SD3->D3_COD,"SB1->B1_UM")
	_FIELD->DATAMOV   := SD3->D3_EMISSAO
	_FIELD->DOC       := SD3->D3_DOC
	_FIELD->OP        := SD3->D3_OP
	_FIELD->SIGA_CF   := SD3->D3_CF
	_FIELD->SIGA_TPMOV:= SD3->D3_TM
	_FIELD->QTDE      := SD3->D3_QUANT
	_FIELD->VLRSIGA   := SD3->D3_CUSTO1
	
	
	If _cTmpVal == "S" .AND. _FIELD->QTDE > 0
		_FIELD->VLRCALC   := SD3->D3_CUSTO1
		_FIELD->CMCALC    := (SD3->D3_CUSTO1 / SD3->D3_QUANT)
	ElseIf _cTmpVal == "S" .AND. (MV_PAR05 == 1 .AND. _FIELD->QTDE == 0) .AND. RTrim(_FIELD->DOC) <> _cDocAce
		_FIELD->VLRCALC   := SD3->D3_CUSTO1
		_FIELD->CMCALC    := (SD3->D3_CUSTO1 / SD3->D3_QUANT)
	Else
		_FIELD->VLRCALC   := 0
		_FIELD->CMCALC    := 0
	EndIf
	
	If SUBSTR(_FIELD->SIGA_CF,1,2)=="RE" .AND. ! Empty(_FIELD->OP)
		_FIELD->PRIORIDADE:="098"
	ElseIf SUBSTR(_FIELD->SIGA_CF,1,2)=="DE" .AND. ! Empty(_FIELD->OP)
		_FIELD->PRIORIDADE:="099"
	Else
		_FIELD->PRIORIDADE:="100"
	EndIf
	
	_FIELD->TRANSACAO  := STRZERO(100,4)
	_FIELD->NUMSEQ     := SD3->D3_NUMSEQ
	_FIELD->SEQCALCULO := _nSeqCalc
	_FIELD->ORIGEM     := "SD3"
	_FIELD->USUARIO    := SD3->D3_USUARIO
	
	_nSeqCalc:=STRZERO( (VAL(_nSeqCalc) + 1) ,10)

	SD3->(DBSkip())
EndDo

Return

/*
===============================================================================================================================
Programa----------: MEST011D2
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Carga de dados do SD2
===============================================================================================================================
Parametros--------: _oProcess - objeto da tela principal
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST011D2(_oProcess)

Local _aDescarta	:= {}  //MATRIZ REF. MOVTOS QUE PROVAVELMENTE NÃO EFETUARAM MOVTO DE ESTOQUE NA ÉPOCA
Local _nRetAux	:= 0

AADD(_aDescarta,"699812")
AADD(_aDescarta,"699814")

ASORT(_aDescarta)

SB1->(DBSetOrder(1))
SF4->(DBSetOrder(1))

DBSelectArea("SD2")
SD2->( DBSetOrder(5) )

_oProcess:Setregua1(SD2->(RECCOUNT()))


SD2->(DBSeek(xFilial("SD2")+DTOS(MV_PAR01),.T.))

Do While (SD2->D2_FILIAL + DTOS(SD2->D2_EMISSAO) <= xFilial("SD2") + DTOS(MV_PAR02)) .AND. (!(SD2->(EOF())))

	SF4->(DBSeek(xFilial("SF4") + SD2->D2_TES))
	
	_oProcess:INCREGUA1("Data: " + DTOC(SD2->D2_EMISSAO))
	PROCESSMESSAGES()
	_nRetAux:=ASCAN(_aDescarta,SD2->D2_NUMSEQ)

	If (SF4->F4_ESTOQUE<>"S") .OR. _nRetAux>0
		SD2->( DBSkip() )
		Loop
	EndIf
	
	DBSelectArea("TEMPO")
	DBAppend()
	_FIELD->ARMAZ      := SD2->D2_LOCAL
	_FIELD->PRODUTO    := SD2->D2_COD
	_FIELD->TIPO       := RETFIELD("SB1",1,xFilial("SB1") + SD2->D2_COD,"SB1->B1_TIPO")
	_FIELD->GRUPO      := RETFIELD("SB1",1,xFilial("SB1") + SD2->D2_COD,"SB1->B1_GRUPO")
	_FIELD->UNMED      := RETFIELD("SB1",1,xFilial("SB1") + SD2->D2_COD,"SB1->B1_UM")
	_FIELD->DATAMOV    := SD2->D2_EMISSAO
	_FIELD->DOC        := SD2->D2_DOC
	_FIELD->OP         := ""
	_FIELD->SIGA_CF    := ""
	_FIELD->SIGA_TPMOV := ""
	_FIELD->QTDE       := SD2->D2_QUANT
	_FIELD->VLRSIGA    := SD2->D2_CUSTO1
	_FIELD->VLRCALC    := 0
	_FIELD->CMCALC     := 0
	
	
	If RTrim(SD2->D2_TIPO)=="D"  //dev COMPRAS
		_FIELD->TRANSACAO :=STRZERO(1000,4)   //4 DIGITOS
	Else
		_FIELD->TRANSACAO :=STRZERO(1500,4)   //4 DIGITOS
	EndIf

	_FIELD->PRIORIDADE := "100"
	_FIELD->NUMSEQ     := SD2->D2_NUMSEQ
	_FIELD->SEQCALCULO := _nSeqCalc
	_FIELD->ORIGEM     := "SD2"
	_FIELD->TIPONF     := SD2->D2_TIPO
	
	_FIELD->TES        := SD2->D2_TES
	_FIELD->TES_PODER3 := SF4->F4_PODER3
	_FIELD->IDENTB6    := SD2->D2_IDENTB6
	
	_nSeqCalc := STRZERO( (VAL(_nSeqCalc) + 1) ,10)
	
	SD2->( DBSkip() )

EndDo

Return

/*
===============================================================================================================================
Programa----------: MEST011PV
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Calculo de valorização
===============================================================================================================================
Parametros--------: _oProcess - objeto da tela principal					  
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST011PV(_oProcess)

Local _aCstSiga	:=	{}
Local _aCstFixo	:=	{}   //MATRIZ PARA GUARDAR O CASO DE CUSTO FIXO   INFORMAR   { NUMSEQ , CM UNITÁRIO }
Local _cArmaz		:=	""
Local _cProd 		:= 	""
Local _nQtde 		:=	0
Local _nCST  		:=	0
Local _nCM   		:=	0
Local _nAcMaux	:= 	0
Local _cTmTipo	:= 	""
Local _cNumSeq 	:= 	""
Local _nVlrRE4 	:= 	0
Local _nRegAux 	:= 	0
Local _nOrdAux 	:= 	0

AADD(_aCstSiga,"99HG3X")
AADD(_aCstSiga,"99HG58")
AADD(_aCstSiga,"99HG5D")
AADD(_aCstSiga,"99HG5G")
AADD(_aCstSiga,"99HCXQ")
AADD(_aCstSiga,"99HCXR")
// FIM 2010 12

// INICIO 2011 03
AADD(_aCstSiga,"99HWSW")
// FIM 2011 03

// INICIO 2011 04
AADD(_aCstSiga,"99IBZB")
// FIM 2011 04

// INICIO 2013 11
AADD(_aCstSiga,"9A8WFV")
// FIM 2013 11

ASORT(_aCstSiga)
ASORT(_aCstFixo,,,{|X,Y| X[1]<Y[1]})

DBSelectArea("TEMPO")
TEMPO->( DBSetOrder(2) )
TEMPO->( DBGOTOP() )

_oProcess:SETREGUA1(RECCOUNT())

_cArmaz:=	TEMPO->ARMAZ
_cProd :=	TEMPO->PRODUTO
_nQtde :=	0
_nCST  :=	0
_nCM   :=	0

Do While ! TEMPO->( EOF() )

	_oProcess:INCREGUA1("ARMAZ-PROD:" + TEMPO->ARMAZ + "-" + TEMPO->PRODUTO)
	PROCESSMESSAGES()
	
	If TEMPO->ORIGEM=="SB9" .OR. TEMPO->ORIGEM=="B9C"

		_FIELD->QTDACM := TEMPO->QTDE
		_FIELD->CSTACM := TEMPO->VLRCALC
		_nAcMaux := (TEMPO->VLRCALC / TEMPO->QTDE)

		If _nAcMaux > 99999999999.9999 .OR. _nAcMaux < -99999999999.9999
			_nAcMaux := 99999999999.9999
		EndIf

		_FIELD->CMACM := _nAcMaux
		
		_nQtde := _nQtde + TEMPO->QTDE
		_nCST  := _nCST + TEMPO->VLRCALC
		_nCM   := (_nCST / _nQtde)
		
		
	ElseIf (TEMPO->ORIGEM=="SD1")

		If (TEMPO->TIPONF == "N") .OR. (TEMPO->TIPONF == "C") .OR. (TEMPO->TIPONF == "D") 
			
			If (ASCAN(_aCstSiga,TEMPO->NUMSEQ)>0)
				_FIELD->VLRCALC := TEMPO->VLRSIGA
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			Else
				_nRetAux:=ASCAN(_aCstFixo,{|x| UPPER(AllTrim(x[1])) == TEMPO->NUMSEQ})
				If _nRetAux>0
					_FIELD->CMCALC :=_aCstFixo[_nRetAux,2]
					_FIELD->VLRCALC:=(TEMPO->QTDE * TEMPO->CMCALC)
				EndIf
			EndIf
			
			_nQtde := _nQtde + TEMPO->QTDE
			_nCST  := _nCST + TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			_nCM  :=(_nCST / _nQtde)
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->CMACM :=_nCM

		Else

			If (ASCAN(_aCstSiga,TEMPO->NUMSEQ)>0)
				_FIELD->VLRCALC := TEMPO->VLRSIGA
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			Else
				_FIELD->VLRCALC := (TEMPO->QTDE * _nCM)
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			EndIf
			
			_nQtde := _nQtde + TEMPO->QTDE
			_nCST  := _nCST + TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			_nCM  :=(_nCST / _nQtde)
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			_FIELD->CMACM := _nCM
		EndIf

	ElseIf TEMPO->ORIGEM == "SD2"
		If (ASCAN(_aCstSiga, TEMPO->NUMSEQ) > 0)
			_FIELD->VLRCALC := TEMPO->VLRSIGA
			_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
		Else
			_nRetAux:=ASCAN(_aCstFixo,{|x| UPPER(AllTrim(x[1])) == TEMPO->NUMSEQ})
			If _nRetAux > 0
				_FIELD->CMCALC  := _aCstFixo[_nRetAux,2]
				_FIELD->VLRCALC := (TEMPO->QTDE * TEMPO->CMCALC)
			Else
				_FIELD->VLRCALC := (TEMPO->QTDE *_nCM)
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			EndIf
		EndIf
		
		_nQtde := _nQtde - TEMPO->QTDE
		_nCST  := _nCST - TEMPO->VLRCALC
		
		// Custo acumulado nunca pode ficar negativo
		If _nCST < 0 .or. _nQtde < 0
			_nCST := 0
		EndIf
		
		If _nQtde<>0    //Sempre que houve movimentação de quantidade deve atualizar o custo médio
			_nCM  :=(_nCST / _nQtde)
		EndIf
		
		_FIELD->QTDACM := _nQtde
		_FIELD->CSTACM := _nCST
		
		If _nCM > 99999999999.9999 .OR. _nCM <- 99999999999.9999
			_nCM := 99999999999.9999
		EndIf
		
		_FIELD->CMACM :=_nCM

	ElseIf TEMPO->ORIGEM == "SD3"
		_cTmpVal := RETFIELD("SF5",1,xFilial("SF5") + SIGA_TPMOV,"SF5->F5_VAL")
		_cTmTipo := RETFIELD("SF5",1,xFilial("SF5") + SIGA_TPMOV,"SF5->F5_TIPO")
		
		If _cTmpVal == "S" .AND. _cTmTipo == "D" //ENTR VALORIZ COM QTDE  OU SEM QTDE DESDE QUE MV_PAR05==1
			_nQtde:=_nQtde + TEMPO->QTDE
			_nCST :=_nCST + TEMPO->VLRCALC
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			_nCM  :=(_nCST /_nQtde)
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			_FIELD->CMACM  := _nCM
			
		ElseIf _cTmpVal == "S" .AND. _cTmTipo == "R"
			_nQtde := _nQtde - TEMPO->QTDE
			_nCST  := _nCST - TEMPO->VLRCALC
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .OR. _nQtde < 0
				_nCST := 0
			EndIf
			
			If _nQtde <> 0    //Sempre que houve movimentação de quantidade deve atualizar o custo médio
				_nCM  :=(_nCST / _nQtde)
			EndIf
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->CMACM := _nCM

		ElseIf TEMPO->SIGA_CF $ "RE0/RE1" //REQUISICAO - INVETARIO SAIDA
			If (ASCAN(_aCstSiga,TEMPO->NUMSEQ) > 0)
				_FIELD->VLRCALC := TEMPO->VLRSIGA
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			Else
				_FIELD->VLRCALC := (TEMPO->QTDE * _nCM)

				If _nCST <  _FIELD->VLRCALC        // Sendo uma saída, se o custo acumulado for menor que a saída, usar o valor acumulado
					_FIELD->VLRCALC := _nCST
				EndIf
				_FIELD->CMCALC :=(TEMPO->VLRCALC / TEMPO->QTDE)
			EndIf
			
			_nQtde := _nQtde - TEMPO->QTDE
			_nCST  := _nCST - TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .OR. _nQtde < 0
				_nCST := 0
			EndIf
			
			If _nQtde <> 0    //Sempre que houve movimentação de quantidade deve atualizar o custo médio
				_nCM  := (_nCST / _nQtde)
			EndIf
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->CMACM := _nCM
			
		ElseIf TEMPO->SIGA_CF $ "DE0/DE1"  //DEVOL REQUISICAO - INVENTARIO ENTR
			If (ASCAN(_aCstSiga,TEMPO->NUMSEQ) > 0)
				_FIELD->VLRCALC := TEMPO->VLRSIGA
				_FIELD->CMCALC := (TEMPO->VLRCALC / TEMPO->QTDE)
			Else
				_nRetAux:=ASCAN(_aCstFixo,{|x| UPPER(AllTrim(x[1])) == TEMPO->NUMSEQ})
				If _nRetAux > 0
					_FIELD->CMCALC  := _aCstFixo[_nRetAux,2]
					_FIELD->VLRCALC := (TEMPO->QTDE * TEMPO->CMCALC)
				Else
					If _nCM <> 0
						_FIELD->VLRCALC:=(TEMPO->QTDE * _nCM)
					Else
						_FIELD->VLRCALC := TEMPO->VLRSIGA
					EndIf
					_FIELD->CMCALC :=(TEMPO->VLRCALC / TEMPO->QTDE)
				EndIf
			EndIf
			
			_nQtde := _nQtde + TEMPO->QTDE
			_nCST  := _nCST + TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			_nCM  :=(_nCST / _nQtde)
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->CMACM :=_nCM

		ElseIf TEMPO->SIGA_CF $ "RE4"
			If (ASCAN(_aCstSiga,TEMPO->NUMSEQ) > 0)
				_FIELD->VLRCALC := TEMPO->VLRSIGA
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			Else
				_FIELD->VLRCALC := (TEMPO->QTDE * _nCM)
				If _nCST < _FIELD->VLRCALC        // Sendo uma saída, se o custo acumulado for menor que a saída, usar o valor acumulado
					_FIELD->VLRCALC := _nCST
				EndIf
				_FIELD->CMCALC :=(TEMPO->VLRCALC / TEMPO->QTDE)
			EndIf
			
			_nQtde := _nQtde - TEMPO->QTDE
			_nCST  := _nCST - TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .OR. _nQtde < 0
				_nCST := 0
			EndIf
			
			If _nQtde <> 0    //Sempre que houve movimentação de quantidade deve atualizar o custo médio
				_nCM  := (_nCST / _nQtde)
			EndIf
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
		
			_FIELD->CMACM := _nCM

		ElseIf TEMPO->SIGA_CF $ "DE4"

			_cProdORI :=""
			_cNumSeq := TEMPO->NUMSEQ
			_nVlrRE4 := 0
			_nRegAux := RECNO()
			_nOrdAux := INDEXORD()
			
			TEMPO->( DBSetOrder(1))
			TEMPO->( DBSeek(_cNumSeq))

			Do While TEMPO->NUMSEQ == _cNumSeq .AND. ! TEMPO->(EOF())
				If TEMPO->SIGA_CF == "RE4"
					_cProdORI := TEMPO->PRODUTO
					_nVlrRE4  := TEMPO->VLRCALC
					Exit
				EndIf
				TEMPO->(DBSkip())
			EndDo
			
			TEMPO->(DBSetOrder(_nOrdAux))
			TEMPO->(DBGOTO(_nRegAux))
			
			_FIELD->VLRCALC := _nVlrRE4
			_FIELD->CMCALC := (TEMPO->VLRCALC / TEMPO->QTDE)
			
			_nQtde := _nQtde + TEMPO->QTDE
			_nCST  := _nCST + TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			_nCM  :=(_nCST / _nQtde)
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->CMACM := _nCM

		ElseIf TEMPO->SIGA_CF $ "PR0"
			If (ASCAN(_aCstSiga,TEMPO->NUMSEQ) > 0)
				_FIELD->VLRCALC := TEMPO->VLRSIGA
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			Else
				_FIELD->VLRCALC := MEST011CP(TEMPO->OP,TEMPO->DATAMOV,TEMPO->NUMSEQ)
				_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
			EndIf
			
			_nQtde := _nQtde + TEMPO->QTDE
			_nCST  := _nCST + TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			If _nQtde<>0    //Sempre que houve movimentação de quantidade deve atualizar o custo médio
				_nCM  :=(_nCST / _nQtde)
			EndIf
						
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->CMACM := _nCM
			
		// tratamento dos movimentos de desmembramento de lotes
		ElseIf TEMPO->SIGA_CF $ "RE7"
			
			_FIELD->VLRCALC := TEMPO->VLRSIGA
			_FIELD->CMCALC  := (TEMPO->VLRCALC / TEMPO->QTDE)
		
			_nQtde := _nQtde - TEMPO->QTDE
			_nCST  := _nCST - TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			If _nQtde<>0    //Sempre que houve movimentação de quantidade deve atualizar o custo médio
				_nCM  :=(_nCST / _nQtde)
			EndIf
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			_nCMAUX:=(_nCST / _nQtde)
			
			If _nCMAUX > 99999999999.9999 .OR. _nCMAUX < -99999999999.9999
				_nCMAUX = 99999999999.9999
			EndIf
			
			_FIELD->CMACM := _nCMAUX 
			
		ElseIf TEMPO->SIGA_CF $ "DE7"
			
			_FIELD->VLRCALC := TEMPO->VLRSIGA
			_FIELD->CMCALC  := (TEMPO->VLRCALC/TEMPO->QTDE)
			
			_nQtde := _nQtde + TEMPO->QTDE
			_nCST  := _nCST + TEMPO->VLRCALC
			
			// Custo acumulado nunca pode ficar negativo
			If _nCST < 0 .or. _nQtde < 0
				_nCST := 0
			EndIf
			
			_nCM  :=(_nCST / _nQtde)
			
			_FIELD->QTDACM := _nQtde
			_FIELD->CSTACM := _nCST
			
			If _nCM > 99999999999.9999 .OR. _nCM < -99999999999.9999
				_nCM := 99999999999.9999
			EndIf
			
			_FIELD->CMACM := _nCM
			
			// fim tratamento dos movs. de desmembramento de lotes
		EndIf
	EndIf
	
	TEMPO->( DBSkip())
	
	If RTrim(_cArmaz + _cProd) <> RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO)
		_cArmaz := ARMAZ
		_cProd  := PRODUTO
		_nQtde  := 0
		_nCST   := 0
		_nCM    := 0
	EndIf
EndDo

Return

/*
===============================================================================================================================
Programa----------: MEST011CP
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: LEVANTAR O CUSTO DE REQUISICOES DE UMA PRODUÇÃO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST011CP(_cOP,_dDatPro,_cNumSeq)

Local _nRet		:= 0
Local _nAreaPr	:= SELECT()
Local _nOrdPr 	:= INDEXORD()
Local _nRegPr 	:= RECNO()
Local _nOrdTmp	:= 0
Local _nRegTmp	:= 0 
Local _lAutom		:=.F.  //VERIFICA SE A REQUIS É AUTOMÁTICA
Local _lMovSd3	:=.T. // VERIFICA SE OS MOVTOS REF.OP ESTÃO NO MES ATUAL OU BUSCARÁ DO SD3 EM MESES ANTERIORES
Local _aMovD3 	:= {}
Local _nNiD3			:= 0

DBSelectArea("TEMPO")

_nOrdTmp:=INDEXORD()
_nRegTmp:=RECNO()

TEMPO->( DBSetOrder(3))   ///OP+PRIORIDADE+DATAMOV
TEMPO->( DBGOTOP() )

TEMPO->( DBSeek(_cOP))

Do While TEMPO->OP ==_cOP .and. ! TEMPO->( EOF() )
	If TEMPO->SIGA_CF $ "RE1/DE1" .AND. SUBSTR(TEMPO->PRODUTO,1,3) <> "MOD"   // para nao considerar casos com re0 mp e re1 mod
		_lAutom:=.T.
	EndIf
	TEMPO->( DBSkip() )
EndDo

If _lAutom
	TEMPO->(DBGOTOP())
	TEMPO->(DBSeek(_cOP))

	Do While TEMPO->OP == _cOP .AND. ! TEMPO->( EOF() )
		If TEMPO->NUMSEQ == _cNumSeq
			If TEMPO->SIGA_CF == "RE1"
				_nRet := _nRet + TEMPO->VLRCALC
			EndIf
		EndIf
		TEMPO->(DBSkip())
	EndDo
Else

	_lMovSd3:=.T. // VERIFICA SE OS MOVTOS REF.OP ESTÃO NO MES ATUAL OU BUSCARÁ DO SD3 EM MESES ANTERIORES
	TEMPO->(DBSetOrder(4)) ///OP+DATA
	TEMPO->(DBSeek(_cOP))

	Do While RTrim(OP)==RTrim(_cOP) .AND. TEMPO->(!EOF())
		If TEMPO->DATAMOV<=_dDatPro
			If SUBSTR(SIGA_CF,1,2)=="RE" .AND. SUBSTR(PRODUTO,1,3)<>"MOD"
				_nRet:=_nRet+VLRCALC
				_lMovSd3:=.F.
			ElseIf SUBSTR(SIGA_CF,1,2)=="DE"
				_nRet:=_nRet-VLRCALC
			ElseIf (SUBSTR(SIGA_CF,1,2)=="PR") .AND. (TEMPO->DATAMOV<>_dDatPro)
				_nRet:=0
			EndIf
		EndIf
		TEMPO->(DBSkip())
	EndDo

	If _nRet<=0 .AND. _lMovSd3

		DBSelectArea("SD3")
		SD3->( DBSetOrder(1)) ///OP
		SD3->( DBSeek(xFilial("SD3")+_cOP))
		_aMovD3 := {}  // D3_COD,D3_LOCAL,D3_CF,D3_QUANT,D3_EMISSAO,D3_CUSTO1

		Do While SD3->D3_FILIAL + SD3->D3_OP == xFilial("SD3") + _cOP .AND. ! SD3->( EOF() )
			If SD3->D3_EMISSAO <= _dDatPro
				AADD(_aMovD3,{SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_CF,SD3->D3_QUANT,SD3->D3_EMISSAO,SD3->D3_CUSTO1,SD3->D3_NUMSEQ})
			EndIf
			SD3->( DBSkip() )
		EndDo

		DBSelectArea("TEMPO")
		
		ASORT(_aMovD3,,,{|x,y|DTOS(X[5])+X[7]<DTOS(y[5])+y[7]})
		
		For _nNiD3:=1 To LEN(_aMovD3)
			If SUBSTR(_aMovD3[_nNiD3,3],1,2) == "RE"
				_nRet := _nRet +_aMovD3[_nNiD3,6]
			ElseIf SUBSTR(_aMovD3[_nNiD3,3],1,2) == "DE"
				_nRet := _nRet -_aMovD3[_nNiD3,6]
			ElseIf (SUBSTR(_aMovD3[_nNiD3,3],1,2) == "PR") .AND. (_aMovD3[_nNiD3,5] <> _dDatPro)
				_nRet := 0
			EndIf

		Next _nNiD3
	EndIf
EndIf

SD3->( DBSetOrder(1) )
SD3->( DBGOTOP())

DBSelectArea("TEMPO")
TEMPO->( DBSetOrder(_nOrdTmp) )
TEMPO->( DBGOTO(_nRegTmp) )

DBSelectArea(_nAreaPr)
_nAreaPr->(DBSetOrder(_nOrdPr))
_nAreaPr->(DBGoTo(_nRegPr) )

Return(_nRet)

/*
===============================================================================================================================
Programa----------: MEST011GE
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Gera Estoque na tabela temporária
===============================================================================================================================
Parametros--------: _oProcess - objeto da tela principal
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST011GE(_oProcess)

Local _nI := 0

DBSelectArea("TEMPO")
TEMPO->( DBGOTOP() )

_oProcess:SETREGUA1(RECCOUNT())

Do While !(TEMPO->( EOF() ))

	_oProcess:INCREGUA1("ARMAZ-PROD:" + TEMPO->ARMAZ + "-" + TEMPO->PRODUTO)
	PROCESSMESSAGES()
	
	DBSelectArea("TEMPOES")
	TEMPOES->(DBSeek(TEMPO->(ARMAZ + PRODUTO) + DTOS(MV_PAR02)))
	
	If !(TEMPOES->( FOUND() ))

		TEMPOES->( DBAppend() ) 
		_FIELD->ARMAZ    	:= TEMPO->ARMAZ
		_FIELD->PRODUTO  	:= TEMPO->PRODUTO
		_FIELD->TIPO     	:= RETFIELD("SB1",1,xFilial("SB1")+TEMPO->PRODUTO,"SB1->B1_TIPO")
		_FIELD->GRUPO    	:= RETFIELD("SB1",1,xFilial("SB1")+TEMPO->PRODUTO,"SB1->B1_GRUPO")
		_FIELD->UNMED    	:= RETFIELD("SB1",1,xFilial("SB1")+TEMPO->PRODUTO,"SB1->B1_UM")
		_FIELD->DATASLD  	:= MV_PAR02
		_FIELD->QTDE     	:= MEST011SF(TEMPO->ARMAZ,TEMPO->PRODUTO)
		_FIELD->CUSTO    	:= MEST011BU(TEMPO->ARMAZ,TEMPO->PRODUTO,MV_PAR02)
		
		If TEMPOES->PRODUTO="D2000002"
			_Ni := 1
		EndIf
		
		If TEMPOES->CUSTO > 9999999999
			_FIELD->CUSTO := 9999999999
		ElseIf TEMPOES->CUSTO< -999999999
			_FIELD->CUSTO := -999999999
		EndIf
		
		_FIELD->CMCALC   := (TEMPOES->CUSTO / TEMPOES->QTDE)
		_FIELD->CST_SIGA := MEST011VF(TEMPOES->ARMAZ,TEMPOES->PRODUTO)
		_FIELD->CM_SIGA  := (TEMPOES->CST_SIGA / TEMPOES->QTDE)
		_FIELD->QTDE_CALC:= MEST011QF(TEMPOES->ARMAZ,TEMPOES->PRODUTO,MV_PAR02)
		_FIELD->CSTQ_CALC:= (TEMPOES->QTDE_CALC * TEMPOES->CMCALC)
		_FIELD->DIF_CST  := TEMPOES->CUSTO - TEMPOES->CST_SIGA
		
		SB2->(DBSetOrder(1))
		SB2->(DBSeek( xFilial("SB2")+TEMPO->(PRODUTO + ARMAZ) ))
	EndIf

	DBSelectArea("TEMPO")
	TEMPO->( DBSkip() )
EndDo

DBSelectArea("TEMPO")
TEMPO->( DBSetOrder(1) )

Return

/*
===============================================================================================================================
Programa----------: MEST011BU
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Busca Situação tributária
===============================================================================================================================
Parametros--------: 	_cArmaz - Armazém
						_cProduto - Produto
						_dDatPro - Data Produção
===============================================================================================================================
Retorno-----------: _nRet - Situação Tributária
===============================================================================================================================
*/

Static Function MEST011BU(_cArmaz,_cProduto,_dDatPro)

Local _nRet 		:= 0
Local _nAreaTmp 	:= SELECT()
Local _nOrdTmp	:= 0
Local _nRegTmp	:= 0

DBSelectArea("TEMPO")
_nOrdTmp	:= INDEXORD()
_nRegTmp	:= RECNO()

TEMPO->(DBSetOrder(2))
TEMPO->(DBGOTOP())
TEMPO->(DBSeek(_cArmaz+_cProduto+DTOS(_dDatPro),.T.))

If (RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO) == RTrim(_cArmaz + _cProduto)) .AND. (TEMPO->DATAMOV <= _dDatPro)
	Do While (RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO) == RTrim(_cArmaz + _cProduto)) .AND. (TEMPO->DATAMOV <= _dDatPro) .AND. ! TEMPO->(EOF())
		_nRet := TEMPO->CSTACM // CMCALC
		TEMPO->(DBSkip())
	EndDo
Else
	TEMPO->(DBSkip(-1))
	Do While (RTrim(TEMPO->ARMAZ + PRODUTO)==RTrim(_cArmaz + _cProduto)) .AND. (TEMPO->DATAMOV <= _dDatPro) .AND. ! TEMPO->(EOF())
		_nRet := TEMPO->CSTACM  //CMCALC
		TEMPO->(DBSkip())
	EndDo
EndIf

TEMPO->(DBSetOrder(_nOrdTmp))
TEMPO->(DBGOTO(_nRegTmp))

DBSelectArea(_nAreaTmp)

Return(_nRet)

/*
===============================================================================================================================
Programa----------: MEST011SF
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Busca Saldo final do produto
===============================================================================================================================
Parametros--------: 	_cArmaz - Armazém
						_cProduto - Produto
===============================================================================================================================
Retorno-----------: _nRet - Saldo final do produto
===============================================================================================================================
*/
Static Function MEST011SF(_cArmaz,_cProduto)

Local _nRet		:= 0
Local _nAreaSF	:= SELECT()

If MV_PAR04 >= MV_PAR02
	DBSelectArea("SB9")
	SB9->(DBSetOrder(1))
	SB9->(DBGOTOP())
	SB9->(DBSeek(xFilial("SB9")+_cProduto+_cArmaz+DTOS(MV_PAR02)))
	_nRet := SB9->B9_QINI
ElseIf (MONTH(MV_PAR02) - MONTH(MV_PAR04)) <= 1
	DBSelectArea("SB2")
	SB2->(DBSetOrder(1))
	SB2->(DBGOTOP())
	SB2->(DBSeek(xFilial("SB2")+_cProduto+_cArmaz))
	_nRet := SB2->B2_QFIM
ElseIf (MONTH(MV_PAR02) - MONTH(MV_PAR04)) > 1
	
	DBSelectArea("TEMPO")
	_nOrdTmp := TEMPO->(INDEXORD())
	_nRegTmp := TEMPO(RECNO())
	TEMPO->(DBSetOrder(2))
	TEMPO->(DBGOTOP())
	TEMPO->(DBSeek(_cArmaz+_cProduto+DTOS(MV_PAR02),.T.))
	
	If (RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO) == RTrim(_cArmaz + _cProduto)) .AND. (TEMPO->DATAMOV <= MV_PAR02)
		Do While (RTrim(TEMPO->ARMAZ + PRODUTO) == RTrim(_cArmaz + _cProduto)) .AND. (TEMPO->DATAMOV <= MV_PAR02) .AND. ! TEMPO->(EOF())
			_nRet := TEMPO->QTDACM // CMCALC
			TEMPO->(DBSkip())
		EndDo
	Else
		TEMPO->(DBSkip(-1))
		Do While (RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO) == RTrim(_cArmaz + _cProduto)) .AND. (TEMPO->DATAMOV <= MV_PAR02) .AND. ! TEMPO->(EOF())
			_nRet := TEMPO->QTDACM  //CMCALC
			TEMPO->(DBSkip())
		EndDo
	EndIf
	TEMPO->(DBSetOrder(_nOrdTmp))
	TEMPO->(DBGOTO(_nRegTmp))
EndIf

DBSelectArea(_nAreaSF)

Return(_nRet)

/*
===============================================================================================================================
Programa----------: MEST011VF
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Busca valor final do produto
===============================================================================================================================
Parametros--------: 	_cArmaz - Armazém
						_cProduto - Produto
===============================================================================================================================
Retorno-----------: _nRet - Valor final do produto
===============================================================================================================================
*/
Static Function MEST011VF(_cArmaz,_cProduto)

Local _nRet		:=0
Local _nAreaSF	:=SELECT()

If MV_PAR04 >= MV_PAR02
	DBSelectArea("SB9")
	SB9->(DBSetOrder(1))
	SB9->(DBGOTOP())
	SB9->(DBSeek(xFilial("SB9")+_cProduto+_cArmaz+DTOS(MV_PAR02)))
	_nRet := SB9->B9_VINI1
Else
	DBSelectArea("SB2")
	SB2->(DBSetOrder(1))
	SB2->(DBGOTOP())
	SB2->(DBSeek(xFilial("SB2")+_cProduto+_cArmaz))
	_nRet := SB2->B2_VFIM1
EndIf

DBSelectArea(_nAreaSF)

Return(_nRet)

/*
===============================================================================================================================
Programa----------: MEST011LA
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Busca valor final do produto
===============================================================================================================================
Parametros--------: 	_oProcess - objeto da tela principal
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MEST011LA(_oProcess)

DBSelectArea("TEMPO")
TEMPO->(DBGOTOP())

_oProcess:SETREGUA1(RECCOUNT())

Do While ! TEMPO->(EOF())
	_oProcess:INCREGUA1("1/3-Armz-Produto:" + TEMPO->ARMAZ + "-" + TEMPO->PRODUTO)
	PROCESSMESSAGES()
	If (TEMPO->ARMAZ == "05" .OR. TEMPO->ARMAZ >= "22") .AND. (TEMPO->ARMAZ <> "90")
		TEMPO->(DBDELETE())
	EndIf
	TEMPO->(DBSkip())
EndDo

DBSelectArea("TEMPOES")
TEMPOES->(DBGOTOP())
_oProcess:SETREGUA1(RECCOUNT())

Do While ! TEMPOES->(EOF())
	_oProcess:INCREGUA1("3/3-Armz-Produto:" + TEMPOES->ARMAZ + "-" + TEMPOES->PRODUTO)
	PROCESSMESSAGES()

	If (TEMPOES->ARMAZ == "05" .OR. TEMPOES->ARMAZ >= "22") .AND. (TEMPOES->ARMAZ <> "90")
		TEMPOES->(DBDELETE())
	EndIf
	TEMPOES->(DBSkip())
EndDo

Return

/*
===============================================================================================================================
Programa----------: MEST011QF
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Retorna a ultima quantidade acumulada do armazem + produto
===============================================================================================================================
Parametros--------: 	_cArmaz - Armazém
						_cProduto - Produto
						_dDatPro - Data produção
===============================================================================================================================
Retorno-----------: _nret - Ultima quantidade acumulada
===============================================================================================================================
*/
Static Function MEST011QF(_cArmaz,_cProduto,_dDatPro)

Local _nRet := 0
Local _nAreaTmp := SELECT()

DBSelectArea("TEMPO")

_nOrdTmp := TEMPO->(INDEXORD())
_nRegTmp := TEMPO->(RECNO())

TEMPO->(DBSetOrder(2))
TEMPO->(DBGOTOP())
TEMPO->(DBSeek(_cArmaz + _cProduto + DTOS(_dDatPro),.T.))

If (RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO) == RTrim(_cArmaz + _cProduto))
	Do While RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO) + DTOS(TEMPO->DATAMOV) <= RTrim(_cArmaz + _cProduto) + DTOS(_dDatPro) .AND. ! TEMPO->(EOF())
		_nRet := TEMPO->QTDACM
		TEMPO->(DBSkip())
	EndDo
Else
	TEMPO->(DBSkip(-1))
	If RTrim(TEMPO->ARMAZ + TEMPO->PRODUTO) == RTrim(_cArmaz + _cProduto)
		_nRet := TEMPO->QTDACM
	EndIf
EndIf

TEMPO->(DBSetOrder(_nOrdTmp))
TEMPO->(DBGOTO(_nRegTmp))

DBSelectArea(_nAreaTmp)

Return(_nRet)

/*
===============================================================================================================================
Programa----------: MEST011GA
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/12/2015
===============================================================================================================================
Descrição---------: Gera arquivo excel de exportação
===============================================================================================================================
Parametros--------: 	_cARQTMP - Arquivo principal de dados
						_cARQTMPES - Arquivo auxiliar de dados
						_cHRINI - Hora do inicio do processamento
						_oprocess - objeto da interface principal
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST011GA(_cARQTMP,_cARQTMPES,_cHRINI,_oprocess)

Local _cArqAux2  	:= ""
Local _cArqAux2E 	:= ""
Local _cHRFIM		:= TIME()
Local _alinhas	:= {}
Local _alinhasE	:= {}
Local _nH			:= 0
Local _nHE			:= 0
Local _nI			:= 0
Local _cnome		:= ""

_oProcess:SetRegua1((TEMPO->(RECCOUNT()) + TEMPOES->(RECCOUNT())) * 2)

//trata nome do arquivo
If right(AllTrim(MV_PAR03),4) = ".XML" .or. right(AllTrim(MV_PAR03),4) = ".xml"  
	_cnome := LEFT(AllTrim(MV_PAR03),( LEN(AllTrim(MV_PAR03)) - 4))
Else
	_cnome := AllTrim(MV_PAR03)
EndIf

_cArqAux2  	:= _cnome + ".XML"
_cArqAux2E 	:= _cnome + "ES" + ".XML"

//===========================================================================
//Cria array do primeiro arquivo
//===========================================================================

aadd(_aLinhas,{'<?xml version="1.0"?>'})
aadd(_aLinhas,{'<?mso-application progid="Excel.Sheet"?>'})
aadd(_aLinhas,{'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'})
aadd(_aLinhas,{' xmlns:o="urn:schemas-microsoft-com:office:office"'})
aadd(_aLinhas,{' xmlns:x="urn:schemas-microsoft-com:office:excel"'})
aadd(_aLinhas,{' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'})
aadd(_aLinhas,{' xmlns:html="http://www.w3.org/TR/REC-html40">'})
aadd(_aLinhas,{' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'})
aadd(_aLinhas,{'  <Created>2006-09-16T00:00:00Z</Created>'})
aadd(_aLinhas,{'  <LastSaved>2015-12-29T17:57:05Z</LastSaved>'})
aadd(_aLinhas,{'  <Version>15.00</Version>'})
aadd(_aLinhas,{' </DocumentProperties>'})
aadd(_aLinhas,{' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">'})
aadd(_aLinhas,{'  <AllowPNG/>'})
aadd(_aLinhas,{'  <RemovePersonalInformation/>'})
aadd(_aLinhas,{' </OfficeDocumentSettings>'})
aadd(_aLinhas,{' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'})
aadd(_aLinhas,{'  <WindowHeight>0</WindowHeight>'})
aadd(_aLinhas,{'  <WindowWidth>2370</WindowWidth>'})
aadd(_aLinhas,{'  <WindowTopX>0</WindowTopX>'})
aadd(_aLinhas,{'  <WindowTopY>0</WindowTopY>'})
aadd(_aLinhas,{'  <ProtectStructure>False</ProtectStructure>'})
aadd(_aLinhas,{'  <ProtectWindows>False</ProtectWindows>'})
aadd(_aLinhas,{' </ExcelWorkbook>'})
aadd(_aLinhas,{' <Styles>'})
aadd(_aLinhas,{'  <Style ss:ID="Default" ss:Name="Normal">'})
aadd(_aLinhas,{'   <Alignment ss:Vertical="Bottom"/>'})
aadd(_aLinhas,{'   <Borders/>'})
aadd(_aLinhas,{'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'})
aadd(_aLinhas,{'   <Interior/>'})
aadd(_aLinhas,{'   <NumberFormat/>'})
aadd(_aLinhas,{'   <Protection/>'})
aadd(_aLinhas,{'  </Style>'})
aadd(_aLinhas,{' </Styles>'})
aadd(_aLinhas,{' <Worksheet ss:Name="Plan1">'})
aadd(_aLinhas,{'  <Table ss:ExpandedColumnCount="999999" ss:ExpandedRowCount="999999" x:FullColumns="1"'})
aadd(_aLinhas,{'   x:FullRows="1" ss:DefaultRowHeight="15">'})
aadd(_aLinhas,{'   <Column ss:Width="54.75" ss:Span="19"/>'}) 

//==================================================================================
//Carrega dados do primeiro arquivo
//==================================================================================

DBSelectArea("TEMPOES")
TEMPO->( DBGOTOP() )

Do While .not. TEMPO->( Eof() )

	aadd(_aLinhas,{'   <Row ss:AutoFitHeight="0">'})
	
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->ARMAZ) 											+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->PRODUTO) 										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->TIPO) 											+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->GRUPO) 											+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->UNMED) 											+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + DTOC(TEMPO->DATAMOV) 											+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->DOC) 												+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->SIGA_CF) 										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->SIGA_TPMOV) 										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->OP) 												+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPO->QTDE, 	"999999999.99"))			+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPO->VLRSIGA, 	"999999999.99"))			+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPO->VLRCALC, 	"999999999.99"))			+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPO->CMCALC, 	"999999999.99")) 			+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->PRIORIDADE)										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->TRANSACAO)										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->NUMSEQ)	 										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->SEQCALCULO)										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->ORIGEM) 											+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->TIPONF) 											+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPO->QTDACM, 	"999999999.99")) 			+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPO->CSTACM, 	"999999999.99")) 			+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPO->CMACM, 	"999999999.99")) 			+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->TES) 												+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->TES_PODER3) 										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->IDENTB6) 										+ '</Data></Cell>'})
	aadd(_aLinhas,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPO->USUARIO) 										+ '</Data></Cell>'})
	
	aadd(_aLinhas,{'   </Row>'})

	TEMPO->( DBSkip() )
	
	_oProcess:IncRegua1("Primeira planilha - " + AllTrim(TEMPO->ARMAZ) + " - " + AllTrim(TEMPO->PRODUTO) )//Incrementa primeira régua
	PROCESSMESSAGES()
EndDo

//=========================================================================================
//Fecha array do primeiro arquivo
//=========================================================================================

aadd(_aLinhas,{'  </Table>'})
aadd(_aLinhas,{'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'})
aadd(_aLinhas,{'   <PageSetup>'})
aadd(_aLinhas,{'    <Header x:Margin="0.3"/>'})
aadd(_aLinhas,{'    <Footer x:Margin="0.3"/>'})
aadd(_aLinhas,{'    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>'})
aadd(_aLinhas,{'   </PageSetup>'})
aadd(_aLinhas,{'   <Unsynced/>'})
aadd(_aLinhas,{'   <Selected/>'})
aadd(_aLinhas,{'   <Panes>'})
aadd(_aLinhas,{'    <Pane>'})
aadd(_aLinhas,{'     <Number>3</Number>'})
aadd(_aLinhas,{'     <ActiveCol>1</ActiveCol>'})
aadd(_aLinhas,{'    </Pane>'})
aadd(_aLinhas,{'   </Panes>'})
aadd(_aLinhas,{'   <ProtectObjects>False</ProtectObjects>'})
aadd(_aLinhas,{'   <ProtectScenarios>False</ProtectScenarios>'})
aadd(_aLinhas,{'  </WorksheetOptions>'})
aadd(_aLinhas,{' </Worksheet>'})
aadd(_aLinhas,{'</Workbook>'})

//=============================================================================
//Carrega array do segundo arquivo
//=============================================================================

aadd(_aLinhasE,{'<?xml version="1.0"?>'})
aadd(_aLinhasE,{'<?mso-application progid="Excel.Sheet"?>'})
aadd(_aLinhasE,{'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'})
aadd(_aLinhasE,{' xmlns:o="urn:schemas-microsoft-com:office:office"'})
aadd(_aLinhasE,{' xmlns:x="urn:schemas-microsoft-com:office:excel"'})
aadd(_aLinhasE,{' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'})
aadd(_aLinhasE,{' xmlns:html="http://www.w3.org/TR/REC-html40">'})
aadd(_aLinhasE,{' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'})
aadd(_aLinhasE,{'  <Created>2006-09-16T00:00:00Z</Created>'})
aadd(_aLinhasE,{'  <LastSaved>2015-12-29T17:57:05Z</LastSaved>'})
aadd(_aLinhasE,{'  <Version>15.00</Version>'})
aadd(_aLinhasE,{' </DocumentProperties>'})
aadd(_aLinhasE,{' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">'})
aadd(_aLinhasE,{'  <AllowPNG/>'})
aadd(_aLinhasE,{'  <RemovePersonalInformation/>'})
aadd(_aLinhasE,{' </OfficeDocumentSettings>'})
aadd(_aLinhasE,{' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'})
aadd(_aLinhasE,{'  <WindowHeight>0</WindowHeight>'})
aadd(_aLinhasE,{'  <WindowWidth>2370</WindowWidth>'})
aadd(_aLinhasE,{'  <WindowTopX>0</WindowTopX>'})
aadd(_aLinhasE,{'  <WindowTopY>0</WindowTopY>'})
aadd(_aLinhasE,{'  <ProtectStructure>False</ProtectStructure>'})
aadd(_aLinhasE,{'  <ProtectWindows>False</ProtectWindows>'})
aadd(_aLinhasE,{' </ExcelWorkbook>'})
aadd(_aLinhasE,{' <Styles>'})
aadd(_aLinhasE,{'  <Style ss:ID="Default" ss:Name="Normal">'})
aadd(_aLinhasE,{'   <Alignment ss:Vertical="Bottom"/>'})
aadd(_aLinhasE,{'   <Borders/>'})
aadd(_aLinhasE,{'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'})
aadd(_aLinhasE,{'   <Interior/>'})
aadd(_aLinhasE,{'   <NumberFormat/>'})
aadd(_aLinhasE,{'   <Protection/>'})
aadd(_aLinhasE,{'  </Style>'})
aadd(_aLinhasE,{' </Styles>'})
aadd(_aLinhasE,{' <Worksheet ss:Name="Plan1">'})
aadd(_aLinhasE,{'  <Table ss:ExpandedColumnCount="99999" ss:ExpandedRowCount="999999" x:FullColumns="1"'})
aadd(_aLinhasE,{'   x:FullRows="1" ss:DefaultRowHeight="15">'})
aadd(_aLinhasE,{'   <Column ss:Width="54.75" ss:Span="19"/>'})

//======================================================================================
//Carrega dados do segundo arquivo
//======================================================================================

DBSelectArea("TEMPOES")
TEMPOES->( DBGOTOP() )

Do While .not. TEMPOES->( Eof() )

	aadd(_aLinhasE,{'   <Row ss:AutoFitHeight="0">'})
	
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPOES->ARMAZ) 											+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPOES->PRODUTO) 											+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPOES->TIPO) 											+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPOES->GRUPO) 											+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="String">' + AllTrim(TEMPOES->UNMED) 											+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="String">' + AllTrim(DTOC(TEMPOES->DATASLD)) 									+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->QTDE, 			"999999999.99"))  	+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->CUSTO, 		"999999999.99"))		+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->CMCALC, 		"999999999.99"))		+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->CST_SIGA,		"999999999.99"))		+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->CM_SIGA, 		"999999999.99"))		+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->QTDE_CALC,	"999999999.99"))		+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->CSTQ_CALC, 	"999999999.99"))		+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->DIF_CST, 		"999999999.99"))		+ '</Data></Cell>'})
	aadd(_aLinhasE,{'    <Cell><Data ss:Type="Number">' + AllTrim(TRANSFORM(TEMPOES->PVAR_CM, 		"999999999.99"))		+ '</Data></Cell>'})
	
	aadd(_aLinhasE,{'   </Row>'})

	_oProcess:IncRegua1("Segunda planilha - " + AllTrim(TEMPOES->ARMAZ) + " - " + AllTrim(TEMPOES->PRODUTO) )//Incrementa primeira régua
	PROCESSMESSAGES()

	TEMPOES->( DBSkip() )
EndDo

//==========================================================================================
//Fecha array do segundo arquivo
//==========================================================================================

aadd(_aLinhasE,{'  </Table>'})
aadd(_aLinhasE,{'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'})
aadd(_aLinhasE,{'   <PageSetup>'})
aadd(_aLinhasE,{'    <Header x:Margin="0.3"/>'})
aadd(_aLinhasE,{'    <Footer x:Margin="0.3"/>'})
aadd(_aLinhasE,{'    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>'})
aadd(_aLinhasE,{'   </PageSetup>'})
aadd(_aLinhasE,{'   <Unsynced/>'})
aadd(_aLinhasE,{'   <Selected/>'})
aadd(_aLinhasE,{'   <Panes>'})
aadd(_aLinhasE,{'    <Pane>'})
aadd(_aLinhasE,{'     <Number>3</Number>'})
aadd(_aLinhasE,{'     <ActiveCol>1</ActiveCol>'})
aadd(_aLinhasE,{'    </Pane>'})
aadd(_aLinhasE,{'   </Panes>'})
aadd(_aLinhasE,{'   <ProtectObjects>False</ProtectObjects>'})
aadd(_aLinhasE,{'   <ProtectScenarios>False</ProtectScenarios>'})
aadd(_aLinhasE,{'  </WorksheetOptions>'})
aadd(_aLinhasE,{' </Worksheet>'})
aadd(_aLinhasE,{'</Workbook>'})

//===================================================================================
//Cria arquivos xml
//===================================================================================

_nH := fCreate(_cArqAux2) 
_nHE := fCreate(_cArqAux2E) 

If _nH == -1 
   MsgStop("Falha ao criar arquivo - " + _cArqAux2 + " - erro " + str(ferror())) 
   Return 
EndIf 

If _nHE == -1 
   MsgStop("Falha ao criar arquivo - " + _cArqAux2E + " - erro " + str(ferror())) 
   _oProcess:SaveLog( "Falha ao salvar planilhas - " + dtoc(date()) + " - " + _cHrini + " - " + cusername )
   Return 
EndIf 

_ninc := 0
_ctemp := ""

For _ni := 1 to len(_aLinhas)
	_ninc++
	If _ninc = 5000 .or. _ni == len(_aLinhas)
		_ctemp += _aLinhas[_ni][1] + chr(13) + chr(10)
		fWrite(_nH, _ctemp )
		_oProcess:IncRegua1("Gravando " + _cArqAux2 + " - Linha " + strzero(_ni,10) + " de " + strzero(len(_aLinhas),10))//Incrementa primeira régua
		PROCESSMESSAGES()
		
		_ninc := 0
		_ctemp := "" 
	Else
		_ctemp += _aLinhas[_ni][1] + chr(13) + chr(10)
	EndIf
Next

_ninc := 0
_ni := 1
_ctemp := ""

For _ni := 1 to len(_aLinhasE)

	_ninc++
	
	If _ninc = 5000 .or. _ni == len(_aLinhasE)
		_ctemp += _aLinhasE[_ni][1] + chr(13) + chr(10)
		fWrite(_nHE,_ctemp )
		_oProcess:IncRegua1("Gravando " + _cArqAux2E + " - Linha " + strzero(_ni,6) + " de " + strzero(len(_aLinhasE),6))//Incrementa primeira régua
		PROCESSMESSAGES()
		
		_ninc := 0
		_ctemp := "" 
	Else
		_ctemp += _aLinhasE[_ni][1] + chr(13) + chr(10)
	EndIf
Next _ni

fClose(_nH) 
fClose(_nHE)

ShellExecute("open", _cArqAux2, "", "c:\", 1)
ShellExecute("open", _cArqAux2E, "", "c:\", 1)

DBSelectArea("TEMPO")

TEMPO->(DBCloseArea())
FERASE((_cARQTMP+".DBF"))
FERASE((_cARQTMP+".CDX"))

DBSelectArea("TEMPOES")

TEMPOES->(DBCloseArea())
FERASE((_cARQTMPES+"ES.DBF"))
FERASE((_cARQTMPES+"ES.CDX"))

_cHRFIM := time()

_oProcess:SaveLog( "Planilhas geradas com sucesso - " + dtoc(date()) + " - " + _cHRFIM + " - " + cusername )

MsgStop("Arquivos gerados " + 	chr(13)+;
									_cArqAux2+CHR(13)+;
									_cArqAux2E+CHR(13)+;
									CHR(13)+;
									"Inicio "+_cHRINI+CHR(13)+;
									"Fim    "+_cHRFIM)
									

Return
