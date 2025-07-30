/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Darcio Sporl  | 31/01/17   | Foi reajustado o tratamento de retorno da conta contábil. Chamado 4058
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 13/12/2019 | Alterar rotina para obter conta contabil para funcionar como rotina Sped Pis/Cofins. Chamado 31211
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa--------: SPDFIS27
Autor-----------: Andre Lisboa
Data da Criacao-: 23/01/2017
===============================================================================================================================
Descrição-------: Ponto de Entrada no SPED Fiscal para que seja possível manipular a escrituração do código da conta contábil
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Conta contábil (cConta)
===============================================================================================================================
*/
User Function SPDFIS27()
Local cConta	:= ""
Local cReg		:= PARAMIXB[1]
Local _cFilial	:= ""	// Filial
// Para registros de nota
Local cTpMovto	:= ""	//Entrada ou saída?
Local cSerie	:= ""	//Série da nota fiscal
Local cNotaFisc	:= ""	//Código da nota fiscal
Local cClieFor	:= ""	//Código do Cliente/Fornecedor
Local cLoja		:= ""	//Código da Loja
Local cItem		:= ""	//Item da nota
Local cProduto	:= ""	//Produto

Begin Sequence 
   If cReg $ "C170|C300|C350|D100|D500|D300"
	  // Neste momento a variável PARAMIXB possui 9 posições, sendo elas informações da tabela SFT
	  _cFilial	:= PARAMIXB[2]	// Filial
	  cTpMovto	:= PARAMIXB[3]
	  cSerie	:= PARAMIXB[4]
	  cNotaFisc	:= PARAMIXB[5]
	  cClieFor	:= PARAMIXB[6]
	  cLoja		:= PARAMIXB[7]
	  cItem		:= PARAMIXB[8]
	  cProduto	:= PARAMIXB[9]
       
      //_cContAju := SPDPIS7C(_cFilial   , _cTipoMov ,  _cSerie  , _cNFiscal , _cClieForn, _cLoja    , _cItem    , _cProduto )
      cConta      := U_SPDPIS7C(_cFilial   ,cTpMovto   ,cSerie     ,cNotaFisc  ,cClieFor   ,cLoja      ,cItem      ,cProduto)
                       
   EndIf

End Sequence

Return cConta