/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 25/09/2015 | Chamado 11949. Modificado browse para permitir pesquisa
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 12/06/2019 | Chamado 29593. Ajustes para loboguara.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/09/2024 | Chamado 48465. Removendo warning de compilação.
==============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Colors.ch"

/*
===============================================================================================================================
Programa----------: CEST001
Autor-------------: Xavier
Data da Criacao---: 15/04/2015
===============================================================================================================================
Descrição---------: Consultar saldos e valores de produtos por filiais
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CEST001

Local _aStru	:= {}
Local _cQry		:= ''
Local _cPerg	:= "CEST001"
Local _cProd1	:= _cProd2 := _cGrupo1 := _cGrupo2 := _cDesc1 := _cDesc2 := ""
Local _aAreaSM0 := SM0->(FWGetArea())

Private cAlias:= GetNextAlias()
Private _aCpos := {}

If ! Pergunte(_cPerg,.T.)
	Return Nil
EndIf

_cProd1  := MV_PAR01
_cProd2  := MV_PAR02
_cGrupo1 := MV_PAR03
_cGrupo2 := MV_PAR04
_cDesc1  := MV_PAR05
_cDesc2  := MV_PAR06
_lSldZero := (MV_PAR07 = 1) //SIM

//criar estrutura de arquivo temporario
AADD(_aStru,{"PRODUTO","C",TamSx3("B1_COD")[1],TamSx3("B1_COD")[2]})
AADD(_aStru,{"DESCR"   ,"C",TamSx3("B1_DESC")[1],TamSx3("B1_DESC")[2]})
AADD(_aStru,{"GRUPO"  ,"C",TamSx3("B1_GRUPO")[1],TamSx3("B1_GRUPO")[2]})
AADD(_aStru,{"UM"     ,"C",TamSx3("B1_UM")[1],TamSx3("B1_UM")[2]})
AADD(_aStru,{"DESCD"   ,"C",TamSx3("B1_DESC")[1],TamSx3("B1_I_DESCD")[2]})

_aAreaSM0 := SM0->(GetArea())

SM0->(DbSeek(cEmpAnt))

While SM0->(!EOF()) .And. SM0->M0_CODIGO = cEmpAnt
	
	AADD(_aStru,{"QTD"+ALLTRIM(SM0->M0_CODFIL),"N",TamSx3("B2_QATU")[1]+2,TamSx3("B2_QATU")[2]})
	AADD(_aStru,{"VLR"+ALLTRIM(SM0->M0_CODFIL),"N",TamSx3("B2_VATU1")[1]+2,TamSx3("B2_VATU1")[2]})
	
	SM0->(DbSkip())

EndDo

FWRestArea(_aAreaSM0)

AADD(_aStru,{"TOTQTD","N",( TamSx3("B2_QATU")[1] )+2,TamSx3("B2_QATU")[2]})
AADD(_aStru,{"TOTVLR","N",( TamSx3("B2_VATU1")[1] )+2,TamSx3("B2_VATU1")[2]})

_otemp := FWTemporaryTable():New( "ZTRB", _aStru )

_otemp:AddIndex( "01", {"PRODUTO"} )
_otemp:AddIndex( "02", {"DESCR"} )
_otemp:AddIndex( "03", {"DESCD"} )

_otemp:Create()

//consultar os dados de estoque atual
_cQry += " SELECT B2_COD, B2_FILIAL, SUM(B2_QATU) B2_QATU, SUM(B2_VATU1) B2_VATU1, B1_UM, B1_DESC, B1_GRUPO "
_cQry += " FROM "+RetSqlname("SB2")+" B2 "
_cQry += " INNER JOIN "+RetSqlname("SB1")+" B1 "
_cQry += " ON B2_COD = B1_COD "
_cQry += " WHERE B2.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' '"
_cQry += " AND B2_COD BETWEEN '"+_cProd1+"' AND '"+_cProd2+"' "
_cQry += " AND B1_GRUPO BETWEEN '"+_cGrupo1+" ' AND '"+_cGrupo2+"' "
_cQry += " AND B1_DESC BETWEEN '"+_cDesc1+"' AND '"+_cDesc2+"' "
_cQry += " AND B2_STATUS <> '2' "
_cQry += " AND B2_QATU > 0 "
_cQry += " GROUP BY B2_COD , B2_FILIAL , B1_UM, B1_DESC, B1_GRUPO "
_cQry += " ORDER BY B2_COD, B2_FILIAL "

_cQry := ChangeQuery(_cQry)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

MsAguarde({|| CEST001A() },"Filtrando registros...")

Return Nil

/*
===============================================================================================================================
Programa----------: CEST001A
Autor-------------: Xavier
Data da Criacao---: 15-04-2015
===============================================================================================================================
Descrição---------: Filtrando dados para apresentação da planilha
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CEST001A()

Local _nx := 0
Local _aFil := {}
Local _aCpos := {}
Local _aAreaSM0 := SM0->(FWGetArea())
Local _lInc := .T.
Local _cQTD := ""
Local _cVLR := ""
Private aRotina := {}

//atualizar arquivo de trabalho
(cAlias)->(DbGoTop())
DBSelectArea("ZTRB")
ZTRB->(DBSetOrder(2))

While (cAlias)->(!EOF())
	
	MsProcTxt("Processando produto "+AllTrim((cAlias)->B2_COD))
	
	_lInc := .T.
	If ZTRB->(DbSeek((cAlias)->B2_COD))
		_lInc := .F.
	EndIf
	
	RecLock("ZTRB",_lInc)
	If _lInc
		ZTRB->PRODUTO := alltrim((cAlias)->B2_COD)
		ZTRB->DESCR    := alltrim((cAlias)->B1_DESC)
		ZTRB->DESCD    := alltrim(POSICIONE("SB1",1,xfilial("SB1")+alltrim((cAlias)->B2_COD),"B1_I_DESCD"))
		ZTRB->GRUPO   := alltrim((cAlias)->B1_GRUPO)
		ZTRB->UM      := alltrim((cAlias)->B1_UM)
	EndIf
	
	//gravar o conteudo referente a filial
	_cQTD := "QTD"+(cAlias)->B2_FILIAL
	_cVLR := "VLR"+(cAlias)->B2_FILIAL
	
	ZTRB->&(_cQTD) := (cAlias)->B2_QATU
	ZTRB->&(_cVLR) := (cAlias)->B2_VATU1
	ZTRB->TOTQTD  := ZTRB->TOTQTD + (cAlias)->B2_QATU
	ZTRB->TOTVLR  := ZTRB->TOTVLR + (cAlias)->B2_VATU1
	ZTRB->(MsUnLock())
	
	//identificar as filiais que possuem quantidades
	If AScan(_aFil, { |x| x = (cAlias)->B2_FILIAL }) <= 0
		AAdd(_aFil, (cAlias)->B2_FILIAL )
	EndIf
	
	(cAlias)->(DbSkip())
	
EndDo

(cAlias)->(DbCloseArea())

//refazer os campos que apareceram no browse
_aCpos := {;
{"Produto" ,"PRODUTO" ,"C",PesqPict("SB1","B1_COD"),2,TamSx3("B1_COD")[1],TamSx3("B1_COD")[2]},;
{"Descricao" ,"DESCR" ,"C",PesqPict("SB1","B1_DESC"),1,TamSx3("B1_DESC")[1],TamSx3("B1_DESC")[2]},;
{"Desc Detalhada" ,"DESCD" ,"C",PesqPict("SB1","B1_DESC"),1,TamSx3("B1_DESC")[1],TamSx3("B1_DESC")[2]},;
{"Grupo" ,"GRUPO" ,"C",PesqPict("SB1","B1_GRUPO"),2,TamSx3("B1_GRUPO")[1],TamSx3("B1_GRUPO")[2]},;
{"UM" ,"UM" ,"C",PesqPict("SB1","B1_UM"),2,TamSx3("B1_UM")[1],TamSx3("B1_UM")[2]}}

If ! _lSldZero //apresentar somente filiais com quantidades
	For _nx := 1 To Len(_aFil)
		SM0->(DbSeek(cEmpAnt+_aFil[_nx]))
		AADD(_aCpos,{"Qt."+Alltrim(SM0->M0_FILIAL),"QTD"+_aFil[_nx],"N",PesqPict("SB2","B2_QATU"),2,TamSx3("B2_QATU")[1]+2,TamSx3("B2_QATU")[2]})
		AADD(_aCpos,{"Vl."+Alltrim(SM0->M0_FILIAL),"VLR"+_aFil[_nx],"N",PesqPict("SB2","B2_VATU1"),2,TamSx3("B2_VATU1")[1]+2,TamSx3("B2_VATU1")[2]})
	Next _nx
Else  //apresentar todas as filiais
	SM0->(DbSeek(cEmpAnt))
	While SM0->(!EOF()) .And. SM0->M0_CODIGO = cEmpAnt
		AADD(_aCpos,{"Qt."+Alltrim(SM0->M0_FILIAL),"QTD"+ALLTRIM(SM0->M0_CODFIL),"N",PesqPict("SB2","B2_QATU"),2,TamSx3("B2_QATU")[1]+2,TamSx3("B2_QATU")[2]})
		AADD(_aCpos,{"Vl."+Alltrim(SM0->M0_FILIAL),"VLR"+ALLTRIM(SM0->M0_CODFIL),"N",PesqPict("SB2","B2_VATU1"),2,TamSx3("B2_VATU1")[1]+2,TamSx3("B2_VATU1")[2]})
		SM0->(DbSkip())
	EndDo
EndIf

AADD(_aCpos,{"Qtd.Total","TOTQTD","N",PesqPict("SB2","B2_QATU"),2,TamSx3("B2_QATU")[1]+2,TamSx3("B2_QATU")[2]})
AADD(_aCpos,{"Vlr.Total","TOTVLR","N",PesqPict("SB2","B2_VATU1"),2,TamSx3("B2_VATU1")[1]+2,TamSx3("B2_VATU1")[2]})
       
FWRestArea(_aAreaSM0)

//apresentar a planilha de registros
ZTRB->(DbGoTop())

//Instaciamento
oBrw := FWMBrowse():New()

//tabela que será utilizada
oBrw:SetAlias( "ZTRB" )

//Titulo
oBrw:SetDescription( "Saldos de Produtos" )

//seta as colunas para o browse
oBrw:SetFields(_aCpos)

_apesq  := {}
_apesq2 := {}

aadd(_apesq,"Descricao")
aadd(_apesq,{{"     " ,"C",TamSx3("B1_DESC")[1],TamSx3("B1_DESC")[2],"Descrição",PesqPict("SB1","B1_DESC"),"DESCR"}})
aadd(_apesq,4)
aadd(_apesq,.T.)

aadd(_apesq2,_apesq)
_apesq := {}

aadd(_apesq,"Codigo")
aadd(_apesq,{{"     " ,"C",TamSx3("B1_COD")[1],TamSx3("B1_COD")[2],"Código Produto",PesqPict("SB1","B1_COD"),"PRODUTO"}})
aadd(_apesq,2)
aadd(_apesq,.T.)

aadd(_apesq2,_apesq)
_apesq := {}

aadd(_apesq,"Desc Detalhada")
aadd(_apesq,{{"     " ,"C",TamSx3("B1_DESC")[1],TamSx3("B1_DESC")[2],"Desc Detalhada",PesqPict("SB1","B1_DESC"),"DESCD"}})
aadd(_apesq,5)
aadd(_apesq,.T.)

aadd(_apesq2,_apesq)

oBrw:SetSeek(.T.,_apesq2)

//define as legendas
oBrw:AddLegend('TOTVLR > 0 ',"BR_VERDE" ,"Valor Total Positivo")
oBrw:AddLegend('TOTVLR <= 0 ',"BR_VERMELHO","Valor total zerado ou negativo")

//Desabilita tela de detalhes e walthru e ambiente
OBrw:SetWalkThru(.F.)
OBrw:SetAmbiente(.F.)
oBrw:DisableDetails()

//botão sair
ADD OPTION aRotina Title ''	Action ''				OPERATION 1 ACCESS 0

//ativa
oBrw:Activate()

ZTRB->(DbCloseArea())

Return
