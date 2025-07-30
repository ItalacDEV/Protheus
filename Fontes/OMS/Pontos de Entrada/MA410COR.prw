/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor  |    Data  |                                             Motivo                                     
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 12/06/17 | Chamado 20246. Incluida legenda para bloqueio de estoque.
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich | 20/07/17 | Chamado 20753. Ajuste e revisão para 12.
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich | 11/04/19 | Chamado 28694. Inclusão de legenda de pedido com bloqueio logistico.
------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 20/02/24 | Chamado 43677. Andre. Nova legenda para Pedido de Venda em O.C. 
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: MA410COR
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 01/08/2011
===============================================================================================================================
Descrição---------: Ponto de Entrada para inclusao de novos status na legenda do pedido de venda
===============================================================================================================================
Parametros--------: recebe PARAMIXB com cores de legenda padrão
===============================================================================================================================
Retorno-----------: _aCorLegen - array com cores de legenda ajustado
===============================================================================================================================
*/

User Function MA410COR()//Chamado do User Function MA440COR() tb

Local _aCorLegen := PARAMIXB //Armazena a legenda padrao utilizada  
Local _x         := 1

// PADRAO MATA410.PRX
// aCores:={{ "EMPTY(C5_LIBEROK) .AND. EMPTY(C5_NOTA) .AND. EMPTY(C5_BLQ)"	- 'ENABLE'	   - 01 - Pedido em Aberto - VERDE
//          { "!EMPTY(C5_NOTA) .OR. C5_LIBEROK=='E' .AND. EMPTY(C5_BLQ)"	- 'DISABLE'	   - 02 - Pedido Encerrado - VERMELHO
//          { "!EMPTY(C5_LIBEROK) .AND. EMPTY(C5_NOTA) .AND. EMPTY(C5_BLQ)"	- 'BR_AMARELO' - 03 - Pedido Liberado
//          { "C5_BLQ == '1'"												- 'BR_AZUL'	   - 04 - Pedido Bloquedo por regra
//          { "C5_BLQ == '2'"												- 'BR_LARANJA' - 05 - Pedido Bloquedo por verba

//=============================================================================================
//Inclui a condicao C5_I_BLOQ == ' ' nos itens padroes do sistema
//para que os dois novos status funcionem adequadamente.   
// Inclui também C5_I_BLOG != 'S' para que a legenda de bloqueio logistico tenha prioridade      
//=============================================================================================
For _x:=1 To Len(_aCorLegen)      
	_aCorLegen[_x,1] += " .AND. (C5_I_BLOQ == ' ' .OR. C5_I_BLOQ == 'L') .AND. "
	_aCorLegen[_x,1] += " ( C5_I_BLPRC == ' ' .OR. C5_I_BLPRC == 'L' .OR. C5_I_BLPRC == 'C') "
	_aCorLegen[_x,1] += " .AND. (C5_I_BLCRE == ' ' .OR. C5_I_BLCRE == 'L' .OR. C5_I_BLCRE == 'C') .AND. C5_I_STATU <> '04'  "
	_aCorLegen[_x,1] += " .AND. (C5_I_BLOG != 'S' .OR. !EMPTY(C5_LIBEROK)) "
Next x

_aCorLegen[3,1] += " .AND. EMPTY(POSICIONE('SC9',1,C5_FILIAL+C5_NUM,'C9_CARGA'))  " // AMARELO - PADRÃO 
AADD(_aCorLegen,{"!EMPTY(POSICIONE('SC9',1,C5_FILIAL+C5_NUM,'C9_CARGA')) .AND. EMPTY(C5_NOTA) ",'AVGARMAZEM','Pedido de Venda em O.C.'})

aAdd(_aCorLegen,{"C5_I_BLOG  == 'S' .AND. EMPTY(C5_LIBEROK)  ",'CARGASEQ'  ,'Pedido de Venda com Bloqueio de Logistica'  })
aAdd(_aCorLegen,{"C5_I_BLOQ  == 'B' "                         ,'BR_PRETO'  ,'Pedido de Venda com Bloqueio de Bonificacao'})
aAdd(_aCorLegen,{"C5_I_BLOQ  == 'R' "                         ,'BR_CINZA'  ,'Pedido de Venda com Bonificacao Rejeitada'  })
aAdd(_aCorLegen,{"C5_I_BLPRC == 'B' "                         ,'BR_BRANCO' ,'Pedido de Venda com Bloqueio de Preço'      }) 
aAdd(_aCorLegen,{"C5_I_BLPRC == 'R' "                         ,'BR_MARROM' ,'Pedido de Venda com Preço Rejeitado'        }) 
aAdd(_aCorLegen,{"C5_I_BLCRE == 'B' "                         ,'BR_VIOLETA','Pedido de Venda com Bloqueio de Credito'    }) 
aAdd(_aCorLegen,{"C5_I_BLCRE == 'R' "                         ,'BR_MARRON' ,'Pedido de Venda com Credito Rejeitado'      }) 

//Projeto de unificação de pedidos de troca nota - O Controle de Liberacao dos Pedidos Troca Nota vão para os 4 ultimos status
_aCorLegen[1,1] += " .And. (C5_I_TRCNF <> 'S' .OR. C5_I_PDPR = C5_NUM  )" // VERDE   - PADRÃO  
_aCorLegen[3,1] += " .And. (C5_I_TRCNF <> 'S' .OR. C5_I_PDPR = C5_NUM  )" // AMARELO - PADRÃO 

aAdd(_aCorLegen,{"C5_I_TRCNF = 'S' .AND. Empty(C5_I_PDFT) .AND. C5_I_STATU = '04'"                             ,'PMSTASK6','Pedido Carregamento Troca Nota c/ Bloqueio de Estoque'})//Pedido Carregamento Troca Nota c/ Bloqueio de Estoque
aAdd(_aCorLegen,{"C5_I_TRCNF = 'S' .AND. Empty(C5_I_PDFT) .AND. Empty(C5_LIBEROK) "                            ,'PMSTASK4','Pedido Carregamento Troca Nota Aberto'  })//Pedido Carregamento Troca Nota
aAdd(_aCorLegen,{"C5_I_TRCNF = 'S' .AND. Empty(C5_I_PDFT) .AND. !Empty(C5_LIBEROK) .and. C5_I_STATU <> '04'"   ,'PMSTASK2','Pedido Carregamento Troca Nota Liberado'})//Pedido Carregamento Troca Nota Liberado

aAdd(_aCorLegen,{"C5_I_TRCNF = 'S' .AND. C5_I_PDFT = C5_NUM .AND. Empty(C5_LIBEROK)"                           ,'BPMSEDT3','Pedido Faturamento Troca Nota Aberto'   })//Pedido Faturamento Troca Nota
aAdd(_aCorLegen,{"C5_I_TRCNF = 'S' .AND. C5_I_PDFT = C5_NUM .AND. !Empty(C5_LIBEROK) .and. C5_I_STATU <> '04' ",'BPMSEDT2','Pedido Faturamento Troca Nota Liberado' })//Pedido Faturamento Troca Nota Liberado
//Projeto de unificação de pedidos de troca nota - O Controle de Liberacao dos Pedidos Troca Nota vão para os 4 ultimos status

aAdd(_aCorLegen,{"C5_I_STATU = '04' ",'BR_AZUL_CLARO','Pedido de Venda com Bloqueio de Estoque'})   //Pedido de Vendas Com Bloqueio de Estoque

Return _aCorLegen
