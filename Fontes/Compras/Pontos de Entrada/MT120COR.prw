/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Darcio Sporl     | 07/12/2015 | Foi incluído o ponto de entrada para inclusão de novas legendas. Chamado 11737 e 11831		  |
-------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 01/04/2016 | Foi incluído legenda para PC Rejeitado:  Chamado 14908                                        
-------------------------------------------------------------------------------------------------------------------------------
 Jerry            | 06/04/2016 | Foi alterado a tratativa para legenda para PC Rejeitado:  Chamado 14970                      
-------------------------------------------------------------------------------------------------------------------------------
 Alex Walaleur    | 07/12/2020 | Correção do erro do padrão pq colocaram 2 veses a cor verde na array aCores. Chamado 34914
===============================================================================================================================
*/
#Include 'Protheus.ch'
/*
===============================================================================================================================
Programa--------: MT120COR
Autor-----------: Darcio Sporl
Data da Criacao-: 07/12/2015
===============================================================================================================================
Descrição-------: Ponto de entrada para incluir/alterar as cores e condições da legenda.
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
Setor-----------: TI
===============================================================================================================================
*/
User Function MT120COR()
Local aArea		:= GetArea()
Local aNewCores	:= aClone(PARAMIXB[1])  //--aCores
Local nPosLib	:= aScan(aNewCores,{|x| x[2] == 'ENABLE'	})
Local nPosBlq	:= aScan(aNewCores,{|x| x[2] == 'BR_AZUL'	})

aNewCores[nPosLib][1] := 'C7_QUJE == 0 .And. C7_QTDACLA == 0 .And. C7_CONAPRO == "L"'									                            	//--Liberado
aNewCores[nPosBlq][1] := 'C7_ACCPROC <> "1" .And. C7_CONAPRO == "B" .And. C7_I_SITWF <> "3" .And. C7_QUJE < C7_QUANT .And. C7_APROV <> "PENLIB"'	//--Pendente Aprovação

aNewCores[nPosLib][2] := 'xxxxxxx'//Correção do erro do padrão pq colocaram 2 veses a cor verde na array aCores
IF (nPosLib2:= aScan(aNewCores,{|x| x[2] == 'ENABLE'	})) <> 0
   aNewCores[nPosLib2][1] := 'C7_QUJE == 0 .And. C7_QTDACLA == 0 .And. C7_CONAPRO == "L"'									                            	//--Liberado
ENDIF
aNewCores[nPosLib][2] := 'ENABLE'//Correção do erro do padrão pq colocara 2 veses a cor verde na array aCores

aAdd(aNewCores,{ 'C7_CONAPRO == "B" .And.C7_QUJE < C7_QUANT .And. C7_APROV == "PENLIB"'	, 'BR_MARROM'	 })	//--Pendente Liberação por Compras
aAdd(aNewCores,{ 'C7_CONAPRO == "B" .And. C7_APROV <> "PENLIB"','F12_VERM' })	//--PC Rejeitados

RestArea(aArea)

Return(aNewCores)

