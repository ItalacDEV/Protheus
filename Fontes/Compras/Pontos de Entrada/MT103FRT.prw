/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
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
Descri��o---------: Ponto de Entrada para gera��o da reten��o de PCC na emissao
					O ponto de entrada MT103FRT, deve retornar um array com a lista de filiais as quais o fornecedor responde/
					pertence. (CGC)O cadastro de fornecedores tem o seguintes c�digo:FORNECEDOR 000001 LOJA 01 Esse fornecedor
					tem t�tulos em mais de uma filial, de forma que considerando/somando os t�tulos de todas as filiais para o 
					mesmo fornecedor, o valor � superior ao valor m�nimo de reten��o (MV_VL10925)Caso a opera��o exija que o 
					sistema retenha impostos considerando todas as filiais. � necess�rio implementar o RDMake e retornar a 
					lista de filiais que devem ser consideradas na reten��o de impostos PCC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aFiliais -> A -> Filiais consideradas na reten��o Pis, Cofins e CSLL.
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