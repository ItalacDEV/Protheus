/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 17/07/2023 | Chamado 44400. Todo t�tulo de ICM n�o ser protestado enviando instru��o "00" 
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 22/11/2024 | Chamado 49206. Adequar ao modelo 2 as instru��es do Bradesco
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 10/04/2025 | Chamado 50437. Alterar tipo de protesto
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa----------: AFIN029
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/05/2021
===============================================================================================================================
Descri��o---------: Fun��o que retorna conte�dos espec�ficos para serem utilizados na montagem do arquivo CNab. Chamado 36451.
                    Regra de Retorno dos dados:
                    +--------------------------+
                    |VENDEDOR|CLIENTE|RESULTADO|
                    +--------------------------+
                    |S	     |S	    |6        |
                    +--------------------------+
                    |N	     |S	    |0        |
                    +--------------------------+
                    |S	     |N	    |6        |
                    +--------------------------+
                    |N	     |N	    |0        |
                    +--------------------------+
===============================================================================================================================
Parametros--------: _cOpcao = Determina qual op��o ser� tratada e retornada pela fun��o.
===============================================================================================================================
Retorno-----------: _cRet   = Conte�do a ser retornado para o Cnab.
===============================================================================================================================
VANDERLEI 21/07/2023
Banco do Brasil
Protestar
	Instru��o 1 = "1"
	Instru��o 2 = "07"
N�o Protestar
	Instru��o 1 = "3"
	Instru��o 2 = "00"

Bradesco
Protestar
	Instru��o 1 = "06"
	Instru��o 2 = "07"
N�o Protestar
	Instru��o 1 = "00"
	Instru��o 2 = "00"
	
Itau
Protestar
	Instru��o 1 = "34"
	Instru��o 2 = "07"
N�o Protestar
	Instru��o 1 = "10"
	Instru��o 2 = "00"

*/
User Function AFIN029(_cOpcao)
Local _cRet := "  "

Begin Sequence 

   If _cOpcao == "INSTPRI"
      //===============================================================
      // Considera estar posicionado no registro da tabela SE1
      //===============================================================
      SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA  
      SA3->(DbSetOrder(1)) // A3_FILIAL+A3_COD 
      
      If ! SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
         Break
      EndIf

      If ! SA3->(MsSeek(xFilial("SA3")+SE1->E1_VEND1))
         Break
      EndIf
			//NAO PROTESTAR (INCLUINDO OS TITULOS DE ICM)
			If (SA1->A1_I_PRTCB == 'N' .Or. SA3->A3_I_PRTCB == 'N') .OR. SE1->E1_TIPO == "ICM"
				If SE1->E1_PORTADO == "001"  //BANCO DO BRASIL
					_cRet := "3"
				ElseIf SE1->E1_PORTADO == "237" //BRADESCO
					If MV_PAR09 == 1
						_cRet := "00"
					Else
						_cRet := "3"
					EndIf
				ElseIf SE1->E1_PORTADO == "341" //ITAU
					_cRet := "10"
				ENDIF
			else  //PROTESTAR
				If SE1->E1_PORTADO == "001" //BANCO DO BRASIL
					_cRet := "1"
				ElseIf SE1->E1_PORTADO == "237" // BRADESCO
					If MV_PAR09 == 1
						_cRet := "06"
					Else
						_cRet := "1"
					EndIf 
				ElseIf SE1->E1_PORTADO == "341" //ITAU
					_cRet := "1"
				ENDIF
			ENDIF

		ElseIf _cOpcao == "INSTSEC"
			//===============================================================
			// Considera estar posicionado no registro da tabela SE1
			//===============================================================
			SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
			SA3->(DbSetOrder(1)) // A3_FILIAL+A3_COD

			If ! SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
				Break
			EndIf

			If ! SA3->(MsSeek(xFilial("SA3")+SE1->E1_VEND1))
				Break
			EndIf

			//NAO PROTESTAR (INCLUINDO OS TITULOS DE ICM)
			If (SA1->A1_I_PRTCB == 'N' .Or. SA3->A3_I_PRTCB == 'N') .OR. SE1->E1_TIPO == "ICM"
				If SE1->E1_PORTADO == "001"  //BANCO DO BRASIL
					_cRet := "00"
				ElseIf SE1->E1_PORTADO == "237" //BRADESCO
					_cRet := "00"
				ElseIf SE1->E1_PORTADO == "341" //ITAU
					_cRet := "00"
				ENDIF
			else  //PROTESTAR
				If SE1->E1_PORTADO == "001" //BANCO DO BRASIL
					_cRet := "07"
				ElseIf SE1->E1_PORTADO == "237" // BRADESCO
					_cRet := "07"
				ElseIf SE1->E1_PORTADO == "341" //ITAU
					_cRet := "07"
				ENDIF
			ENDIF
		EndIf

	End Sequence

Return _cRet

