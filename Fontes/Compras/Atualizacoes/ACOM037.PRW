/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================

/*
===============================================================================================================================
Programa----------: ACOM037
Autor-------------: Josué Danich Prestes
Data da Criacao---: 10/04/2019
===============================================================================================================================
Descrição---------: Função chamada dos gatilhos do campo D1_TES - Chamado 28865
===============================================================================================================================
Parametros--------: _ncampo - gatilho que está sendo chamado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM037(_ncampo)

Local _nPosPROD := aScan( aHeader , {|X| Upper( Alltrim( X[2] ) ) == "D1_COD"     } ) // Código do produto
Local _cgrupo := posicione("SB1",1,XFILIAL("SB1")+acols[n][_nPosPROD],"B1_GRUPO")
Local _npostotal	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "D1_TOTAL" } )
Local _nposvalicm	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "D1_VALICM" } )
Local _xret

//Correção de bases para  PORTARIA CAT 42/2018 - Chamado 28559
If M->D1_TES $ u_itgetmv("ITTESCAT42","491")
			
	_nbasest := POSICIONE("SBM",1,xfilial("SBM")+_cgrupo,"BM_I_BASEN")
	_naliqn  := u_itgetmv("ITALICAT42",18)

	If _nbasest > 0

        If _ncampo == 1

	        _xret := acols[n][_npostotal] * _nbasest
	
        Elseif _ncampo == 2

	        _xret := (acols[n][_npostotal] * _nbasest * (_naliqn/100)) - acols[n][_nposvalicm]

        Elseif _ncampo == 3
	    
            _xret := _naliqn
	
        Else

            _xret := " "

        Endif

	Endif

Endif

Return _xret