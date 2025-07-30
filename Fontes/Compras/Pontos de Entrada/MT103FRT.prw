/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT103FRT
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 25/10/2008
===============================================================================================================================
Descrição---------: Ponto de Entrada para geração da retenção de PCC na emissao
					O ponto de entrada MT103FRT, deve retornar um array com a lista de filiais as quais o fornecedor responde/
					pertence. (CGC)O cadastro de fornecedores tem o seguintes código:FORNECEDOR 000001 LOJA 01 Esse fornecedor
					tem títulos em mais de uma filial, de forma que considerando/somando os títulos de todas as filiais para o 
					mesmo fornecedor, o valor é superior ao valor mínimo de retenção (MV_VL10925)Caso a operação exija que o 
					sistema retenha impostos considerando todas as filiais. É necessário implementar o RDMake e retornar a 
					lista de filiais que devem ser consideradas na retenção de impostos PCC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aFiliais -> A -> Filiais consideradas na retenção Pis, Cofins e CSLL.
===============================================================================================================================
*/
User Function MT103FRT

Local aFilial := {} 
Local nRegSM0 := SM0->(RECNO()) 
Local cEmpAtu := SM0->M0_CODIGO 
Local cCnpj   := SUBSTR(SM0->M0_CGC,1,8) 

DBSelectArea ("SM0") 
SM0->(DBSeek(cEmpAtu))

While !Eof() .and. SM0->M0_CODIGO == cEmpAtu 
	If Substr(SM0->M0_CGC,1,8) == cCnpj 
    	AADD(aFilial,AllTrim(SM0->M0_CODFIL)) 
    Endif 
	DBSkip() 
Enddo

SM0->(dbGoto(nRegSM0))

Return (aFilial)