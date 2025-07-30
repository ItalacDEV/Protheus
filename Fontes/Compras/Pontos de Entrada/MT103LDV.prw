/*
=============================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=============================================================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 09/01/2018 | Chamado 23154, 23145, 23147, 23142. PE reescrito pq toda a lógica não fazia sentido e dava erro. 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 18/09/2023 | Chamado 33887. Preenchimento da 2 UM do produto quando PA e sem conversão.
=============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"

/*
=============================================================================================================================================================
Programa----------: MT103LDV
Autor-------------: Talita
Data da Criacao---: 01/03/2013
=============================================================================================================================================================
Descrição---------: Verifica no retorno do documento de saída se o produto é do Tipo PA para utilizar o armazém 31.
					Este ponto de entrada é executado durante o preenchimento da linhas a serem enviadas para a rotina automatica
=============================================================================================================================================================
Parametros--------: ParamIxb[1] - Vetor - Recebe um array na seguinte estrutura: [n][1] Campo ; [n][2] Conteudo ; [n][3] Nil
					Paramixb[2]	- Caracter - Alias da tabela SD2
=============================================================================================================================================================
Retorno-----------: Retorno- Vetor - Retorna um array na seguinte estrutura: [n][1] Campo ; [n][2] Conteudo ; [n][3] Nil
=============================================================================================================================================================
*/
User Function MT103LDV()

Local _aArea    := GetArea()
Local _aArea2   := SD2->(GetArea())
Local _aRet	    := {}
Local _nI	    := 0
Local aLinha    := ParamIxb[1]//Vetor - Recebe um array na seguinte estrutura: [n][1] Campo ; [n][2] Conteudo ; [n][3] Nil
Local cAliasSD2 := Paramixb[2]//Caracter - Alias da tabela SD2
Local nPosD1COD := ASCAN( aLinha , { |X| AllTrim( X[01] ) == "D1_COD"    } )
Local nPosD1LOC := ASCAN( aLinha , { |X| AllTrim( X[01] ) == "D1_LOCAL"  } )
Local nPosD1VUN := ASCAN( aLinha , { |X| AllTrim( X[01] ) == "D1_VUNIT"  } )
Local nPosD1QTS := ASCAN( aLinha , { |X| AllTrim( X[01] ) == "D1_QTSEGUM"} )

If nPosD1LOC > 0 .AND. nPosD1COD > 0 .AND. Posicione("SB1",1,xFilial("SB1")+aLinha[nPosD1COD][02],"B1_TIPO") = 'PA'
	aLinha[nPosD1LOC][02] := '31'
	IF IsinCallStack("M103FILDV") .AND. IsinCallStack("A103DEVOL") .AND. SB1->B1_CONV = 0 .AND. !EMPTY(SB1->B1_SEGUM) 
	   IF nPosD1QTS > 0  
	      aLinha[nPosD1QTS][02] := (cAliasSD2)->D2_QTSEGUM
	   ELSE
		  AAdd( aLinha, { "D1_SEGUM"    , (cAliasSD2)->D2_SEGUM   , Nil } )
		  AAdd( aLinha, { "D1_QTSEGUM"  , (cAliasSD2)->D2_QTSEGUM , Nil } )
		  AAdd( aLinha, { "D1_VUNIT"    , aLinha[nPosD1VUN][02]   , Nil } )

	   ENDIF
	ENDIF
EndIf

For _nI := 1 To Len( aLinha )
	aAdd( _aRet , { aLinha[_nI][01] , aLinha[_nI][2] , aLinha[_nI][3] } )
Next

RestArea( _aArea )
RestArea( _aArea2)

Return( _aRet )
