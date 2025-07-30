/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
                                                                          | 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Totvs.Ch"

/*
===============================================================================================================================
Programa--------: AOMS073
Autor-----------: Josué Danich Prestes
Data da Criacao-: 15/08/2016
===============================================================================================================================
Descrição-------: Validação de campos de segunda unidade - Chamado 16569
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: _ccampo - Campo sendo validado
===============================================================================================================================
Retorno---------: .T. ou .F. se campo pode ser editado ou não
===============================================================================================================================
*/
User Function AOMS073(_ccampo)

Local _lret := .T.
Local _cproduto := ""
Local _nproduto := 0 
Local _cgrupo := ""
Local _nquant := 0


If _ccampo == "D1_COD" 

		_nproduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "D1_COD"	}) 
		_cproduto := acols[n][_nproduto] 
		_nquant := M->D1_QTSEGUM
		
Endif

If _ccampo == "C7_PRODUTO" 

		_nproduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "C7_PRODUTO"	}) 
		_cproduto := acols[n][_nproduto] 
		_nquant := M->C7_QTSEGUM
		
Endif

If _ccampo == "C1_PRODUTO" 

		_nproduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "C1_PRODUTO"	}) 
		_cproduto := acols[n][_nproduto] 
		_nquant := M->C1_QTSEGUM
		
Endif

If _ccampo == "C2_PRODUTO" 

		_cproduto := M->C2_PRODUTO
		_nquant := M->C2_QTSEGUM
		
Endif

If _ccampo == "BC_PRODUTO" 

		_nproduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "BC_PRODUTO"	}) 
		_cproduto := acols[n][_nproduto] 
		_nquant := M->BC_QTSEGUM
		
Endif

If _ccampo == "C6_PRODUTO" 

		_nproduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "C6_PRODUTO"	})  
		_cproduto := acols[n][_nproduto] 
		_nquant := M->C6_UNSVEN
		
Endif

If _ccampo == "D3_COD" 

		If alltrim(funname()) == "MATA241" 
		
			_nproduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "D3_COD"	}) 
			_cproduto := ALLTRIM(acols[n][_nproduto]) 
			_nquant := M->D3_QTSEGUM
			
		Elseif funname() == "MATA240"
		
			_cproduto := alltrim(M->D3_COD)
			_nquant := M->D3_QTSEGUM
			
		Endif
		
Endif

_cgrupo := posicione("SB1",1,xFilial("SB1")+alltrim(_cproduto),"B1_GRUPO")


if _nquant > 0 .and. posicione("SB1",1,xFilial("SB1")+alltrim(_cproduto),"B1_CONV") == 0 .AND. !(alltrim(posicione("SB1",1,xFilial("SB1")+alltrim(_cproduto),"B1_GRUPO ")) $ alltrim(U_ITGETMV("IT_GRP2U", "0006")))

		messagebox("Produto " + _cproduto + " não tem fator de conversão cadastrado, impossível usar segunda medida!", "Atenção", 16)
		
		_lret := .F.
		
Endif


Return _lret
