/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 29/03/2019 | Correção de leitura de aheader dinâmico - Chamado 28765
===============================================================================================================================
*/


//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================================================================
Programa----------: A175GRV
Autor-------------: Josué Danich Prestes
Data da Criacao---: 23/07/2018
===============================================================================================================================
Descrição---------: PE chamado após a gravação de todos os dados após liberacao/Rejeicao do Material no CQ.- Chamado 25600
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A175GRV()

Local nRecSD3   := SD3->(Recno())
Local nIndSD3   := SD3->(IndexOrd())
Local cSeekSD3  := xfilial("SD3") + padr(CA175NUM,9)+cA175Prod
Local _nposnum  := ascan(aheader,{|x| x[2] = "D7_NUMSEQ"})

SD3->(dbSetOrder(2))//D3_FILIAL+D3_DOC+D3_COD
_arecs := {}

If SD3->(dbSeek(cSeekSD3))

	//==============================================================
	// Grava data em todos os movimentos do d3 com mesmo doc mas 
	// que o numseq não conste do acols      
	//==============================================================
	Do while !SD3->(EOF()) .AND. SD3->D3_FILIAL+SD3->D3_DOC+SD3->D3_COD == cSeekSD3
	
		If ascan(acols,{ |_vaux| _vaux[_nposnum] == SD3->D3_NUMSEQ}) == 0
		
			RecLock("SD3",.F.)
			SD3->D3_I_DTAP := DATE()
			SD3->D3_I_HRAP := TIME()
			MsUnLock()
				
		Endif

		SD3->(Dbskip())
		
	Enddo
	
EndIf
	
SD3->(dbSetOrder(nIndSD3))
SD3->(dbGoTo(nRecSD3))

Return