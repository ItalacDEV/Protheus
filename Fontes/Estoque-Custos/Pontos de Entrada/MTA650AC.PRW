/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich      | 27/10/2015 | Incluido campo D4_I_P_GOR na acols da tela de empenho - Chamado 12006                         
André Lisboa      | 06/04/2016 | Alterada picture do campo D4_QUANT - Chamado 15016                        		       
Alex Wallauer     | 03/01/2019 | Inserido o campo de Estoque e validação do Local - Chamado 27300
Alex Wallauer     | 16/07/2019 | Ajuste para não dar mais ERROR.LOG na funcao MTA650AC - Chamado 29966
Alex Wallauer     | 05/09/2019 | Ajustes na gravação dos campos D4_I_QTORI e D4_I_QORSG - Chamado 27300
============================================================================================================================================================
Analista         - Programador     - Inicio     - Envio    - Chamado - Motivo da Alteração
------------------------------------------------------------------------------------------------------------------------------------------------------------
Andre Carvalho   - Igor Melgaço    - 10/06/25   -          - 50977   - Ajustes nas pictures dos campos D4_QUANT e D4_I_PGOR 
============================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1) 
                     
/*
===============================================================================================================================
Programa----------: MTA650AC
Autor-------------: Carlos Cleber A.Silva
Data da Criacao---: 13/11/2013
===============================================================================================================================
Descrição---------: Ponto de entrada para incluir campo na tela de empenhos - Chamado 04605
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Uma array com os dados de um campo novo no aHearder
===============================================================================================================================
*/ 
User Function MTA650AC() As Array

Local _aArray  := {} As Array
Local _atam    := "" As Character
LOCAL nPosLocal:= 0 As Numeric

IF IsInCallStack("A650REPLD4")
   RETURN _aArray
ENDIF

IF (nPosLocal:=aScan(aHeader,{|x| AllTrim(x[2])=="D4_LOCAL"})) > 0
   aHeader[nPosLocal,6] := aHeader[nPosLocal,6]+" .AND. U_A650ADCOL(.T.) "
ENDIF   

_atam:=TamSX3("B1_DESC") //Posicao original 14 mudado para visualizacao na posicao 02
 
	 aHeader[2,1] := 'Descricao'
	 aHeader[2,2] := 'B1_DESC'
	 aHeader[2,3] := PesqPict("SB1","B1_DESC",_atam[1])
	 aHeader[2,4] := _atam[1]
	 aHeader[2,5] := _atam[2]
	 aHeader[2,7] := USADO
	 aHeader[2,8] := "C"
	 aHeader[2,9] := "SB1"
 
_atam:=TamSX3("D4_QUANT") //Posicao original 02 mudado para visualizacao na posicao 04
 
	 aHeader[4,1] := 'Quantidade Empenho'
	 aHeader[4,2] := 'D4_QUANT'
	 aHeader[4,3] := PesqPict("SD4","D4_QUANT",_atam[1]) 
	 aHeader[4,4] := _atam[1]
	 aHeader[4,5] := _atam[2]
	 aHeader[4,6] := "A650ConvUM(2) .And. M->D4_QUANT # 0"
	 aHeader[4,7] := USADO
	 aHeader[4,8] := "N"
	 aHeader[4,9] := "SD4"    
 
_atam:=TamSX3("G1_TRT") //Posicao original 04 mudado para visualizacao na posicao 14
 
	 aHeader[14,1] := 'Sequencia'
	 aHeader[14,2] := 'G1_TRT'
	 aHeader[14,3] := PesqPict("SG1","G1_TRT",_atam[1])
	 aHeader[14,4] := _atam[1]
	 aHeader[14,5] := _atam[2]
	 aHeader[14,6] := "A650Seq()"
	 aHeader[14,7] := USADO
	 aHeader[14,8] := "C"
	 aHeader[14,9] := "SG1"

//===================================================
//Adiciona campo D4_I_PGOR no acols
//===================================================

_atam:=TamSX3("D4_I_PGOR")

aadd(_aArray,{"Porc Gord", "D4_I_PGOR", PesqPict("SD4","D4_I_PGOR",_atam[1]) , _atam[1], _atam[2],"", .T.  , "N" , "SD4", " "})

aadd(_aArray,"SD4->D4_I_PGOR")

_atam:=TamSX3("B2_QATU")

aadd(aHeader,{"Estoque"     , "B2_QATU"   , PesqPict("SB2","B2_QATU")   , _atam[1], _atam[2],"", .F.  , "N" , "SB2", "V"})
aadd(aHeader,{"Qtde Ori"    , "D4_I_QTORI", PesqPict("SD4","D4_I_QTORI"), _atam[1], _atam[2],"", .F.  , "N" , "SD4", "V"})
aadd(aHeader,{"Qtde Seg Ori", "D4_I_QORSG", PesqPict("SD4","D4_I_QORSG"), _atam[1], _atam[2],"", .F.  , "N" , "SD4", "V"})
 
Return(_aArray) 
