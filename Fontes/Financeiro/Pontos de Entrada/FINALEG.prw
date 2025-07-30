/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 18/10/2017 | Mudança de ordem da legenda de bloqueio cnab- Chamado 22056
===============================================================================================================================
*/
#Include 'Protheus.ch'
/*
===============================================================================================================================
Programa----------: FINALEG
Autor-------------: Josué Danich Prestes
Data da Criacao---: 14/11/2016
===============================================================================================================================
Descrição---------: Ponto de entrada para refazer a legenda padrão da rotina Contas a Receber. Chamado 16924
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function FINALEG
Local nReg     := PARAMIXB[1]
Local cAlias   := PARAMIXB[2]
Local aLegenda := { {"BR_VERDE"		,	"Titulo em aberto"							},;
					{"BR_AZUL"		,	"Baixado parcialmente"						},;
					{"BR_VERMELHO"	,	"Titulo Baixado"							},;
					{"BR_PRETO"		,	"Titulo em Bordero"							},;
					{"BR_BRANCO"	,	"Adiantamento com saldo"					},;
					{"BR_CINZA"		,	"Titulo baixado parcialmente e em bordero"	},;
					{"BR_MARROM"	,	"Adiantamento de Imp. Bx. com saldo"		} }
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	If cAlias = "SE1"   
		
   		Aadd(aLegenda, {"BR_LARANJA","Titulo Bloqueado por Cnab"})
		Aadd(aLegenda, {"BR_AMARELO", "Titulo Protestado"})

		Aadd(uRetorno, { 'ROUND(E1_SALDO,2) = 0'																			, aLegenda[3][1]	} ) //"Titulo Baixado" 
		Aadd(uRetorno, { '!Empty(E1_NUMBOR) .and.(ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2))'									, aLegenda[6][1]	} ) //"Titulo baixado parcialmente e em bordero"
		Aadd(uRetorno, { 'E1_TIPO == "'+MVRECANT+'".and. ROUND(E1_SALDO,2) > 0 .And. !FXAtuTitCo()'							, aLegenda[5][1]	} ) //"Adiantamento com saldo"
		Aadd(uRetorno, { '!Empty(E1_NUMBOR)'																				, aLegenda[4][1]	} ) //"Titulo em Bordero"
		Aadd(uRetorno, { 'ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2) .And. !FXAtuTitCo() '										, aLegenda[2][1]	} ) //"Baixado parcialmente"
		Aadd(uRetorno, { 'U_CNABBL()'																						, aLegenda[8][1]	} ) //"Bloqueado Cnab"
		Aadd(uRetorno, { 'ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. E1_SITUACA == "F" '									, aLegenda[Len(aLegenda)][1]	} ) //"Titulo Protestado"

		Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
	Else
		IF GetMv("MV_CTLIPAG")           
			Aadd(aLegenda, {"BR_AMARELO", "Titulo aguardando liberacao"})
			Aadd(uRetorno, { ' !( SE2->E2_TIPO $ MVPAGANT ).and. EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > GetMV("MV_VLMINPG") .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } ) 
		EndIf
						
		Aadd(uRetorno, { 'E2_TIPO $ "INA/'+MVTXA+'" .and. ROUND(E2_SALDO,2) > 0 .And. E2_OK == "TA"  ', aLegenda[7][1] } )			
		Aadd(uRetorno, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0', aLegenda[5][1] } )			
		Aadd(uRetorno, { 'ROUND(E2_SALDO,2) + ROUND(E2_SDACRES,2)  = 0', aLegenda[3][1] } )
		Aadd(uRetorno, { '!Empty(E2_NUMBOR) .and.(ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2))', aLegenda[6][1] } )						
		Aadd(uRetorno, { '!Empty(E2_NUMBOR)', aLegenda[4][1] } )
		Aadd(uRetorno, { 'ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2)', aLegenda[2][1] } )
		Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
	Endif
Else
	If cAlias = "SE1"
		Aadd(aLegenda, {"BR_LARANJA","Titulo Bloqueado por Cnab"})
		Aadd(aLegenda, {"BR_AMARELO", "Titulo Protestado"})
    Else 
    	IF GetMv("MV_CTLIPAG")    
    		Aadd(aLegenda, {"BR_AMARELO",  "Titulo aguardando liberacao"})
    	EndIf
	EndIf
	BrwLegenda(cCadastro, "Contas a Receber - Legenda", aLegenda)
Endif

Return uRetorno

/*
===============================================================================================================================
Programa----------: CNABBL
Autor-------------: Josué Danich Prestes
Data da Criacao---: 14/11/2016
===============================================================================================================================
Descrição---------: Teste de bloqueio cnab do titulo posicionado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lret - se o título está bloqueado por regra cnab
===============================================================================================================================
*/

User Function Cnabbl()

Local _lret := .F.

if EMPTY(ALLTRIM(SE1->E1_NUMBCO)) 
			
		If !EMPTY(ALLTRIM(SE1->E1_IDCNAB)) .OR. !EMPTY(ALLTRIM(SE1->E1_I_NUMBC))

			_lret := .T.
			
		Endif
	
Endif

Return _lret