/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data     |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 12/06/17 | Chamado 20246. Incluida legenda para bloqueio de estoque.
------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 24/09/18 | Chamado 26347. Nova legenda para Pedido Carregamento Troca Nota c/ Bloqueio de Estoque.
------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich | 11/04/19 | Chamado 28694. Inlcuidas legendas de PV com bloqueio logistico.
------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 20/02/24 | Chamado 43677. Andre. Nova legenda para Pedido de Venda em O.C. 
==============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: MA410LEG
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 01/08/2011
===============================================================================================================================
Descri��o---------: Ponto de Entrada para inclusao de novos status na legenda do pedido de venda 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MA410LEG()

Local _aCorLegen:= PARAMIXB //Armazena a legenda padrao utilizada 

// PADRAO MATA410.PRX
// aCores:={{ "EMPTY(C5_LIBEROK) .AND. EMPTY(C5_NOTA) .AND. EMPTY(C5_BLQ)"	- 'ENABLE'	   - 01 - Pedido em Aberto - VERDE
//          { "!EMPTY(C5_NOTA) .OR. C5_LIBEROK=='E' .AND. EMPTY(C5_BLQ)"	- 'DISABLE'	   - 02 - Pedido Encerrado - VERMELHO
//          { "!EMPTY(C5_LIBEROK) .AND. EMPTY(C5_NOTA) .AND. EMPTY(C5_BLQ)"	- 'BR_AMARELO' - 03 - Pedido Liberado
//          { "C5_BLQ == '1'"												- 'BR_AZUL'	   - 04 - Pedido Bloquedo por regra
//          { "C5_BLQ == '2'"												- 'BR_LARANJA' - 05 - Pedido Bloquedo por verba

aAdd(_aCorLegen,{'BR_AZUL_CLARO','Pedido de Venda com Bloqueio de Estoque'      }) // Azul Claro   
aAdd(_aCorLegen,{'BR_PRETO'		,'Pedido de Venda com Bloqueio de Bonificacao'	})
aAdd(_aCorLegen,{'BR_CINZA'		,'Pedido de Venda com Bonificacao Rejeitada'  	})
aAdd(_aCorLegen,{'BR_BRANCO'	,'Pedido de Venda com Bloqueio de Pre�o'		})
aAdd(_aCorLegen,{'BR_MARROM'	,'Pedido de Venda com Pre�o Rejeitado'  		})
aAdd(_aCorLegen,{'BR_VIOLETA'	,'Pedido de Venda com Bloqueio de Credito'  	})
aAdd(_aCorLegen,{'BR_MARRON'	,'Pedido de Venda com Credito Rejeitado'  		})
aAdd(_aCorLegen,{'CARGASEQ'	    ,'Pedido de Venda em Planejamento Logistico'    })  // Icone de planeta

aAdd(_aCorLegen,{'PMSTASK6'	      ,'Pedido Carregamento Troca Nota c/ Bloqueio de Estoque'  })//Quadarado Azul
aAdd(_aCorLegen,{'PMSTASK4'	      ,'Pedido Carregamento Troca Nota Aberto'  })  // Quadarado Verde
aAdd(_aCorLegen,{'PMSTASK2'	      ,'Pedido Carregamento Troca Nota Liberado'})  // Quadarado Amarelo
aAdd(_aCorLegen,{'BPMSEDT3'	      ,'Pedido Faturamento Troca Nota Aberto'   })  // Triangulo Verde
aAdd(_aCorLegen,{'BPMSEDT2'	      ,'Pedido Faturamento Troca Nota Liberado' })  // Triangulo Amarelo  

aAdd(_aCorLegen,{'AVGARMAZEM'	      ,'Pedido de Venda em O.C.' })

Return _aCorLegen
