/*
=====================================================================================================================================
        						 ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
   Autor     |	Data	 |										Motivo																
-------------------------------------------------------------------------------------------------------------------------------------
Josué Danich | 06/04/2017| Ajuste para evitar errorlog quando paramixb[1] vem vazio - Chamado 19648                                  
--------------------------------------------------------------------------------------------------------------------------------------
 Andre       | 19/07/17  | Incluir tipo "MN" no array de tipos . Chamado 20834	
--------------------------------------------------------------------------------------------------------------------------------------
Josué Danich | 28/12/17  | Sempre enviar tipo de produto 03 quando for produto 08000000039 na filial 40 - Chamado 23035		
--------------------------------------------------------------------------------------------------------------------------------------
Josué Danich | 19/01/17  | Ajustado produto e filial para mudar tipo em parâmetros - Chamado 23298 											
--------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 10/10/18  | Teste da variavel "_cAliSpd" se existe - Chamado 26578
--------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 02/10/19  | Teste dos campos 'FT_PRODUTO' e 'FT_FILIAL' se existem - Chamado 30726
=====================================================================================================================================
*/
#include "protheus.ch"
#include "TopConn.ch"    
#include "RwMake.ch"

/*
===============================================================================================================================
Programa----------: SPDFIS001
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 28/09/2016
===============================================================================================================================
Descrição---------: Ponto de Entrada para tratar tipos de produtos
===============================================================================================================================
Parametros--------: ParamIXB[1] - Contém os tipos de produtos padrão
===============================================================================================================================
Retorno-----------: _aTipo - Contém os tipos de produtos padrão mais os de usuário
===============================================================================================================================
*/

User Function SPDFIS001()
Local _aArea    := GetArea()
Local _aAreaSB1	:= SB1->(GetArea())
Local _aAreaSBZ	:= SBZ->(GetArea())
Local _aTipo	:= ParamIXB[1]    
Local _cProdut 	:= ""
Local _cTipFab	:= ""
Local _nPosPrd 	:= 0
Local _nPosFil  := 0
Local _cFilial  := ""  , _ni
  
If !funname() == "MATR241"

	If TYPE("_cAliSpd") = "C" .and. select(_cAliSpd) > 0 .and. len(_cAliSpd) > 3 
       _nPosPrd:= (_cAliSpd)->(FieldPos('FT_PRODUTO'))
       _nPosFil:= (_cAliSpd)->(FieldPos('FT_FILIAL'))
	   If _nPosPrd <> 0 .AND. _nPosFil <> 0
		   _cProdut := (_cAliSpd)->(FieldGet(_nPosPrd)) 	
		   _cFilial := (_cAliSpd)->(FieldGet(_nPosFil)) 
		   _cTipFab := Posicione("SBZ",1,xFilial("SBZ")+_cProdut,"BZ_I_REVEN")
	   endif   
	Endif

	IF EMPTY(_cProdut)
	   _cProdut := SB1->B1_COD
	   _cFilial := xfilial("SBZ")
	   _cTipFab := Posicione("SBZ",1,xFilial("SBZ")+_cProdut,"BZ_I_REVEN")
	Endif


	If alltrim(_cTipFab) == "S" .AND. len(_aTipo) >= 5
		_aTipo[5][2] := "00"
	Else
		aAdd(_aTipo,	{"IN","10"} )
		aAdd(_aTipo,	{"SV","09"} )
		aAdd(_aTipo,	{"MN","07"} )		
	Endif	
	
	//Ajuste para bloco 0210, k0230, k0235
	If alltrim(_cProdut) $ u_itgetmv("IT_PK0210","08000000039") .AND. alltrim(_cFilial) $ U_ITGETMV("IT_FK0210","40,04")
	
		For _ni := 1 to len(_aTipo)
		
			_aTipo[_ni][2] := "03"
			
		Next
			
	Endif
	
Endif

Restarea(_aAreaSB1)
Restarea(_aAreaSBZ)
RestArea(_aArea)

Return _aTipo