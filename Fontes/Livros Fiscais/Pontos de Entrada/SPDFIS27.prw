/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Darcio Sporl  | 31/01/17   | Foi reajustado o tratamento de retorno da conta cont�bil. Chamado 4058
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
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
Descri��o-------: Ponto de Entrada no SPED Fiscal para que seja poss�vel manipular a escritura��o do c�digo da conta cont�bil
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Conta cont�bil (cConta)
===============================================================================================================================
*/
User Function SPDFIS27()
Local cConta	:= ""
Local cReg		:= PARAMIXB[1]
Local _cFilial	:= ""	// Filial
// Para registros de nota
Local cTpMovto	:= ""	//Entrada ou sa�da?
Local cSerie	:= ""	//S�rie da nota fiscal
Local cNotaFisc	:= ""	//C�digo da nota fiscal
Local cClieFor	:= ""	//C�digo do Cliente/Fornecedor
Local cLoja		:= ""	//C�digo da Loja
Local cItem		:= ""	//Item da nota
Local cProduto	:= ""	//Produto

Begin Sequence 
   If cReg $ "C170|C300|C350|D100|D500|D300"
	  // Neste momento a vari�vel PARAMIXB possui 9 posi��es, sendo elas informa��es da tabela SFT
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