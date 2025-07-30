/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 22/05/2019 |  Ajsutes na valida��o do Armazem 31. Chamado 29346
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 05/09/2024 | Retirado trecho que atualiza o armaz�m na classifica��o. Chamado 48462
===============================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: A103CLAS
Autor-------------: Alexandre Villar
Data da Criacao---: 25/01/2016
===============================================================================================================================
Descri��o---------: Ponto de entrada na inicializa��o da classifica��o do documento de entrada
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/

User Function A103CLAS()

Local _aArea	:= FWGetArea()
Local _aAreaSF4 := SF4->(FwGetArea())
Local _aAreaSD2 := SD2->(FwGetArea())
Local _nI		:= 0
Local _nPosTES	:= aScan(aHeader,{|x|AllTrim(x[2])=='D1_TES'	})
Local _nPosNFO	:= aScan(aHeader,{|x|AllTrim(x[2])=='D1_NFORI'	})
Local _nPosSRO	:= aScan(aHeader,{|x|AllTrim(x[2])=='D1_SERIORI'})
Local _nPosITO	:= aScan(aHeader,{|x|AllTrim(x[2])=='D1_ITEMORI'})
Local _nPosFOR	:= aScan(aHeader,{|x|AllTrim(x[2])=='D1_FORNECE'})
Local _nPosLOJ	:= aScan(aHeader,{|x|AllTrim(x[2])=='D1_LOJA'	})
Local _nPosCOD	:= aScan(aHeader,{|x|AllTrim(x[2])=='D1_COD'	})

DBSelectArea('SD2')
SD2->(DBSetOrder(3))
DBSelectArea('SF4')
SF4->(DBSetOrder(1))

For _nI := 1 To Len( aCols )
	//====================================================================================================
	// Verifica se preenche a TES automaticamente caso esteja em branco
	//====================================================================================================
	If !Empty(aCols[_nI][_nPosNFO]) .And. !Empty(aCols[_nI][_nPosSRO]) .And. !Empty(aCols[_nI][_nPosITO]) .And. Empty(aCols[_nI][_nPosTES])
		If SD2->(DBSeek(SF1->F1_FILIAL+aCols[_nI][_nPosNFO]+aCols[_nI][_nPosSRO]+aCols[_nI][_nPosFOR]+aCols[_nI][_nPosLOJ]+aCols[_nI][_nPosCOD]+aCols[_nI][_nPosITO]))
			If SF4->(DBSeek(xFilial('SF4')+SD2->D2_TES)) .And. !Empty(SF4->F4_TESDV)
				aCols[_nI][_nPosTES] := SF4->F4_TESDV
			EndIf
		EndIf
	EndIf
Next _nI

SF4->(FwRestArea(_aAreaSF4))
SD2->(FwRestArea(_aAreaSD2))
FWRestArea(_aArea)

Return
