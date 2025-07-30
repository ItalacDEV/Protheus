/*
=========================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=============================================================================================================================== 
Analista        - Programador     - Inicio     - Envio      - Chamado - Motivo de Alteração
===============================================================================================================================
Antonio Ramos   - Igor Melgaço    - 18/12/2025 - 23/01/2025 - 49056   - Ajustes para gravação de historico de alterações de campo da SE2
=============================================================================================================================== 
*/

/*
===============================================================================================================================
Programa----------: FA050ALT
Autor-------------: Igor Melgaço
Data da Criacao---: 02/01/2025	
===============================================================================================================================
Descrição---------: O ponto de entrada FA050ALT sera executado na validacao da alteracao dos dados do contas a pagar
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/

User Function FA050ALT() As Logical

Local lRet As Logical
Local _a2Struct As Array
Local _nI As Numeric
Local _cPict As Character
Local _cOrig As Character
Local _cAlt As Character

_a2Struct := FWSX3Util():GetListFieldsStruct( "SE2" , .F. /*lVirtual*/)
lRet   := .T.
_nI    := 0
_cPict := ""
_cOrig := ""
_cAlt  := ""

For _nI := 1 to Len(_a2Struct)
   If SE2->&(_a2Struct[_nI,1]) <> M->&(_a2Struct[_nI,1]) 
      
      If Alltrim(_a2Struct[_nI,2]) == "N"

         _cPict := PesqPict( "SE2",_a2Struct[_nI,1])
         _cOrig := Transform(SE2->&(_a2Struct[_nI,1]),_cPict) 
         _cAlt  := Transform(M->&(_a2Struct[_nI,1]),_cPict) 

      ElseIf Alltrim(_a2Struct[_nI,2]) == "D"

         _cOrig := DTOC(SE2->&(_a2Struct[_nI,1]))
         _cAlt  := DTOC(M->&(_a2Struct[_nI,1]))

      ElseIf Alltrim(_a2Struct[_nI,2]) == "L"

         _cOrig := Iif(SE2->&(_a2Struct[_nI,1]),".T.",".F.")
         _cAlt  := Iif(M->&(_a2Struct[_nI,1]),".T.",".F.")

      Else

         _cOrig := SE2->&(_a2Struct[_nI,1])
         _cAlt  := M->&(_a2Struct[_nI,1])

      EndIf

      U_FA040L("SE2",1,_a2Struct[_nI,1],_cOrig,_cAlt,SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),SE2->E2_FILIAL,SE2->E2_NUM,"FINA050")
   EndIf	
Next

Return lRet
