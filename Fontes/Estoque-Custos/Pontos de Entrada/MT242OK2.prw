/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
 Josu� Danich     | 22/08/2016 | Inclus�o de valida��o de saldos retroativos para desmontagem - Chamado 17785                 |
===============================================================================================================================
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa--------: MT242OK2
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 22/08/2016
===============================================================================================================================
Descri��o-------: Ponto de Entrada que valida lancamento no cabecalho da desmontagem 
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: L�gico, permitindo ou n�o a grava��o o movimento
===============================================================================================================================
*/

User Function MT242OK2()

Local 	_aArea	:=	GetArea()
Local	_lret	:=	.T.

Private aSldNeg := {}
	
if substr(cproduto,1,4) = "0006"

	if nqtdorigse = 0

			xmaghelpfis("Segunda Unidade de Medida Vazio","Para esse produto e obrigatorio o preenchimento da segunda unidade de medida (Pe�as).",;
						"Favor preencher a segunda unidade de medida (Pe�as)!!")
			_lret := .F.

	endif

endif

//Varre os saldos de cada dia at� a data de hoje buscando por saldo insuficiente
MsAguarde({|| aSldNeg := U_VldEstRetrNeg(cProduto, cLocorig, nQtdorig, dEmis260) },"Verificando saldos...")   
  

If Len(aSldNeg) > 0
   
	xmaghelpfis("Aten��o!", "N�o permitido, pois o produto " + alltrim(cProduto) + " no armaz�m " + cLocorig + " n�o tem saldo suficiente em " + dtoc(aSldNeg[1]) + ". Saldo na data:" + TRANSFORM(aSldNeg[2],"@E 999,999.99"),;
   						"Selecionar quantidade ou data de produto que n�o gere saldos negativos.")
    _lret  := .F.
   
EndIf      
	
	
RestArea(_aArea)
	
return _lret