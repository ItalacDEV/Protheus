/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Chamado 28346 - Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melgaço     | 21/03/2023 | Chamado 41686 - Ajuste para alimentação do Codigo FCI.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MSD2460
Autor-------------: Wodson Reis Silva
Data da Criacao---: 06/02/2009
===============================================================================================================================
Descrição---------: Usado para gravar os campos de usuario do Pedido de Venda no item da Nota.
					Grava a quantidade de caixas dos itens do grupo queijo, vendidos no Pedido.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MSD2460()

Local _cAlias  := Alias()
Local _aAmb    := GetArea()

//Salvando Integridade do Sistema.
dbSelectArea("SF2")
_nOrdSF2 := IndexOrd()
_nRecSF2 := Recno()

dbSelectArea("SD2")
_nOrdSD2 := IndexOrd()
_nRecSD2 := Recno()

dbSelectArea("SB1")
_nOrdSB1 := IndexOrd()
_nRecSB1 := Recno()

dbSelectArea("SF4")
_nOrdSF4 := IndexOrd()
_nRecSF4 := Recno()

dbSelectArea("SC5")
_nOrdSC5 := IndexOrd()
_nRecSC5 := Recno()

dbSelectArea("SC6")
_nOrdSC6 := IndexOrd()
_nRecSC6 := Recno()                    

dbSelectArea("SBZ")
_nOrdSBZ := IndexOrd()
_nRecSBZ := Recno()                    

//Gravacao de campo de usuario do SC6 no SD2
DbselectArea("SC6")
DbsetOrder(1)//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
If DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)
	Reclock("SD2",.F.)
	SD2->D2_I_DQESP := SC6->C6_I_DQESP
	SD2->(MsUnlock())
EndIf

DbSelectArea("SBZ")
SBZ->( DbSetOrder(1) )    //BZ_FILIAL+BZ_COD
If SBZ->( DbSeek(xFilial("SBZ") + SD2->D2_COD) )
	If !Empty(Alltrim(SBZ->BZ_I_FCICO ))
		Reclock("SD2",.F.)
		SD2->D2_FCICOD := SBZ->BZ_I_FCICO 
		SD2->(MsUnlock())
	EndIf
EndIf
                           
dbSelectArea("SD2")
dbSetOrder(_nOrdSD2)
dbGoto(_nRecSD2)

dbSelectArea("SF2")
dbSetOrder(_nOrdSF2)
dbGoto(_nRecSF2)

dbSelectArea("SB1")
dbSetOrder(_nOrdSB1)
dbGoto(_nRecSB1)

dbSelectArea("SF4")
dbSetOrder(_nOrdSF4)
dbGoto(_nRecSF4)

dbSelectArea("SC5")
dbSetOrder(_nOrdSC5)
dbGoto(_nRecSC5)

dbSelectArea("SC6")
dbSetOrder(_nOrdSC6)
dbGoto(_nRecSC6)

dbSelectArea("SBZ")
dbSetOrder(_nOrdSBZ)
dbGoto(_nRecSBZ)

dbSelectArea(_cAlias)
RestArea(_aAmb)

Return
