/*
=============================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=============================================================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 19/09/2023 | Chamado 33887. Preenchimento da 2 UM do produto quando PA e sem conversão.
=============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
=============================================================================================================================================================
Programa----------: PNEU002
Autor-------------: Alex Wallauer
Data da Criacao---: 19/09/2023
=============================================================================================================================================================
Descrição---------: P.E. no final da tela da função A103NFORI() do Fonte MATA103.PRW. Botões F7 e "Origem".
=============================================================================================================================================================
Parametros--------: Nenhum
=============================================================================================================================================================
Retorno-----------: Nenhum
=============================================================================================================================================================
*/

User Function PNEU002()
Local _aArea    := GetArea()
Local _aArea2   := SD2->(GetArea())
LOCAL nPosD1COD	:= ASCAN(aHeader,{|x| AllTrim(x[2])=='D1_COD'    })
LOCAL nPosD1LOC := ASCAN(aHeader,{|x| AllTrim(x[2])=='D1_LOCAL'  })
LOCAL nPosD1NFO := ASCAN(aHeader,{|X| AllTrim(X[2])=="D1_NFORI"  })
LOCAL nPosD1SRO := ASCAN(aHeader,{|X| AllTrim(X[2])=="D1_SERIORI"})
LOCAL nPosD1FOR := ASCAN(aHeader,{|X| AllTrim(X[2])=="D1_FORNECE"})
LOCAL nPosD1LOJ := ASCAN(aHeader,{|X| AllTrim(X[2])=="D1_LOJA"   })
LOCAL nPosD1ITO := ASCAN(aHeader,{|X| AllTrim(X[2])=="D1_ITEMORI"})
LOCAL nPosD1QTS := ASCAN(aHeader,{|x| AllTrim(x[2])=='D1_QTSEGUM'})

If nPosD1LOC > 0 .AND. nPosD1COD > 0 .AND. !EMPTY(aCols[N][nPosD1COD]) .AND. cTipo = 'D' .AND. Posicione("SB1",1,xFilial("SB1")+aCols[N][nPosD1COD],"B1_TIPO") = 'PA'
   aCols[N][nPosD1LOC] := '31'
   IF SB1->B1_CONV = 0 .AND. !EMPTY(SB1->B1_SEGUM) .AND. nPosD1QTS > 0 .AND. nPosD1NFO > 0  .AND. nPosD1SRO > 0  .AND. nPosD1FOR > 0  .AND. nPosD1LOJ > 0  .AND. nPosD1ITO > 0  
       SD2->(DBSETORDER(3))  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
       IF SD2->(DBSEEK(xFILIAL("SD2")+aCols[N][nPosD1NFO]+;
	                                  aCols[N][nPosD1SRO]+;
									  CA100FOR+;
									  CLOJA+;
									  aCols[N][nPosD1COD]+;
									  aCols[N][nPosD1ITO]))
          aCols[N][nPosD1QTS] := SD2->D2_QTSEGUM
	   ENDIF
	ENDIF
EndIf

RestArea( _aArea )
RestArea( _aArea2)

Return .T.	        

