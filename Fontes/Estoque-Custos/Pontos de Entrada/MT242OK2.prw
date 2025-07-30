/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
 Josué Danich     | 22/08/2016 | Inclusão de validação de saldos retroativos para desmontagem - Chamado 17785                 |
===============================================================================================================================
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa--------: MT242OK2
Autor-----------: Josué Danich Prestes
Data da Criacao-: 22/08/2016
===============================================================================================================================
Descrição-------: Ponto de Entrada que valida lancamento no cabecalho da desmontagem 
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Lógico, permitindo ou não a gravação o movimento
===============================================================================================================================
*/

User Function MT242OK2()

Local 	_aArea	:=	GetArea()
Local	_lret	:=	.T.

Private aSldNeg := {}
	
if substr(cproduto,1,4) = "0006"

	if nqtdorigse = 0

			xmaghelpfis("Segunda Unidade de Medida Vazio","Para esse produto e obrigatorio o preenchimento da segunda unidade de medida (Peças).",;
						"Favor preencher a segunda unidade de medida (Peças)!!")
			_lret := .F.

	endif

endif

//Varre os saldos de cada dia atá a data de hoje buscando por saldo insuficiente
MsAguarde({|| aSldNeg := U_VldEstRetrNeg(cProduto, cLocorig, nQtdorig, dEmis260) },"Verificando saldos...")   
  

If Len(aSldNeg) > 0
   
	xmaghelpfis("Atenção!", "Não permitido, pois o produto " + alltrim(cProduto) + " no armazém " + cLocorig + " não tem saldo suficiente em " + dtoc(aSldNeg[1]) + ". Saldo na data:" + TRANSFORM(aSldNeg[2],"@E 999,999.99"),;
   						"Selecionar quantidade ou data de produto que não gere saldos negativos.")
    _lret  := .F.
   
EndIf      
	
	
RestArea(_aArea)
	
return _lret