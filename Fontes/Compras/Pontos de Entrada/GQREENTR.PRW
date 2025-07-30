/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 21/11/2019 |Alterar rotina CAT 42/2018 para ler aliquotas/margens de cadastro e não de parâmetro.Chamado 30971.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================

/*
===============================================================================================================================
Programa----------: GQREENTR
Autor-------------: Josué Danich Prestes
Data da Criacao---: 10/04/2019
===============================================================================================================================
Descrição---------: Ponto de Entrada após todas as gravações do documento de entrada - Chamado 28559
===============================================================================================================================
Parametros--------: _ncampo - gatilho que está sendo chamado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function GQREENTR()

//=====================================================================================================
// Atualiza campos da CAT 42/2018
//===================================================================================================== 
ZM2->(DbSetOrder(1)) // ZM2_FILIAL+ZM2_TES+ZM2_GRUPO

SD1->(Dbsetorder(1))
_cindice := SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
If SD1->(Dbseek(_cindice))

	_lprimeiro := .T.
	_ntotal := 0
	_nbtot := 0

	Do while _cindice == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

		If ZM2->(DbSeek(SD1->D1_FILIAL+SD1->D1_TES+SD1->D1_GRUPO)) 
			
			_nbasest := ZM2->ZM2_MARGEM 
			_naliqn  := ZM2->ZM2_ALIQUO 

			If _nbasest > 0

				SFT->(Dbsetorder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM
				_cindsft := SD1->D1_FILIAL+"E"+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM

				SF3->(Dbsetorder(5)) //F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA
				_cindsf3 := SD1->D1_FILIAL+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA

				If SFT->(Dbseek(_cindsft)) .and. (!_lprimeiro .OR. SF3->(Dbseek(_cindsf3)))

					If _lprimeiro

						_lprimeiro := .F.
						
					Endif                                                                                     
					
					_ntotal += (SD1->D1_TOTAL * _nbasest * (_naliqn/100)) - SD1->D1_VALICM
					_nbtot += SD1->D1_TOTAL * _nbasest

					Reclock("SD1",.F.)

	        		SD1->D1_BASNDES := SD1->D1_TOTAL * _nbasest
					SD1->D1_ICMNDES := (SD1->D1_TOTAL * _nbasest * (_naliqn/100)) - SD1->D1_VALICM
					SD1->D1_ALQNDES := _naliqn

					SD1->(Msunlock())

					Reclock("SFT",.F.)

	        		SFT->FT_BASNDES := SD1->D1_TOTAL * _nbasest
					SFT->FT_ICMNDES := (SD1->D1_TOTAL * _nbasest * (_naliqn/100)) - SD1->D1_VALICM
					SFT->FT_ALQNDES := _naliqn

					SFT->(Msunlock())

				Endif

			Endif        
        Else 
           //=================================================================================
           // Ver se dá para inserir a nova forma de cálculo.
           //=================================================================================
        
        Endif

		SD1->(Dbskip())

	Enddo

	If !_lprimeiro

		Reclock("SF3",.F.)
		SF3->F3_BASNDES := _nbtot
		SF3->F3_ICMNDES := _ntotal
		SF3->(Msunlock())

	Endif

Endif


Return
