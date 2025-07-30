/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 29/09/2021 | Gravacao do campo E1_I_DTPRO no titulo da DCT. Chamado 37873
 Alex Wallauer    | 08/10/2021 | Gravacao do campo E1_VENCREA com M->E1_I_DTPRO+1. Chamado 37884
 Alex Wallauer    | 06/04/2022 | Retirda da confirma��o da altera��o do titulo DCT. Chamado 39648
 Julio Paz        | 17/11/2022 | Corre��es nas valida��es campo data de prorroga��o quando n�o estiver preenchido.Chamado 41853
 Julio Paz        | 12/12/2022 | Fazer Preenchimento da data de Prorroga��o(E1_I_DTPRO) seja sempre dia util. Chamado 42100
 Julio Paz        | 06/01/2023 | Alterar rotina p/permitir remover o conte�do do campo Dt.Prorroga��o(E1_I_DTPRO).Chamado 42444
===============================================================================================================================

=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Altera��o
---------------------------------------------------------------------------------------------------------------------------------------------------------
Antonio Ramos    -  Igor Melga�o     - 18/12/2024 - 23/01/2025 - 49056   - Ajustes para grava��o de historico de altera��es de campo da SE1
Antonio Ramos    -  Igor Melga�o     - 10/04/2025 - 10/04/2025 - 47833   - Ajustes para corre��o de vencto.
Antonio Ramos    -  Igor Melga�o     - 16/05/2025 - 30/05/2025 - 50527   - Ajustes para mudan�a de regra de vencto.
=========================================================================================================================================================
*/

/*
===============================================================================================================================
Programa----------: FA040ALT
Autor-------------: Lucas Borges Ferreira 
Data da Criacao---: 07/02/2012	
===============================================================================================================================
Descri��o---------: O ponto de entrada FA040ALT sera executado na validacao da alteracao dos dados do contas a receber
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/

User Function FA040ALT() As Logical

Local uRet As Logical
Local _aArea As Array
Local _a1Struct As Array
Local _nI As Numeric
Local _cPict As Character
Local _cOrig As Character
Local _cAlt As Character
Local _lAFIN037 As Logical
Local _lRetem As Logical

_aArea:= SE1->(GetArea())
_a1Struct := FWSX3Util():GetListFieldsStruct( "SE1" , .F. /*lVirtual*/)
uRet   := .T.
_nI    := 0
_cPict := ""
_cOrig := ""
_cAlt  := ""
_lAFIN037 := FWIsInCallStack("AFIN037") // Verifica se o ponto de entrada foi chamado pelo AFIN037
_lRetem := .F.

If SE1->E1_I_DTPRO <> M->E1_I_DTPRO .And. !Empty(M->E1_I_DTPRO) 
   If _lAFIN037
      _lRetem := DTVENC(M->E1_CLIENTE, M->E1_LOJA, M->E1_I_DTPRO)

      If _lRetem
         M->E1_VENCREA := DataValida(M->E1_I_DTPRO+1,.T.)
      Else
         M->E1_VENCREA := M->E1_I_DTPRO
      Endif
   Else
      M->E1_I_DTPRO := DataValida(M->E1_I_DTPRO,.T.)
      M->E1_VENCREA := DataValida(M->E1_I_DTPRO+1,.T.)
   EndIf
EndIf

If	SE1->E1_VENCTO <> M->E1_VENCTO 
	M->E1_I_ALTVE := DATE()
EndIf              

If uRet
   _cChave :=SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+"DCT"+SE1->E1_NUM+SE1->E1_PARCELA
   SE1->(DBSETORDER(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
   IF SE1->(DBSEEK(_cChave))
      bBloco:={||  U_ITMsgLog("FILIAL: "+SE1->E1_FILIAL+CHR(13)+CHR(10)+;
                          "- PREFIXO: "+SE1->E1_PREFIXO+CHR(13)+CHR(10)+;
                           "- NUMERO: "+SE1->E1_NUM+CHR(13)+CHR(10)+;
   					   "- PARCELA: "+SE1->E1_PARCELA+CHR(13)+CHR(10)+;
   					   "- CLIENTE: "+SE1->E1_CLIENTE+CHR(13)+CHR(10)+;
   					   "- LOJA: "+SE1->E1_LOJA+CHR(13)+CHR(10)+;
   					"- VENCIMENTO: "+DTOC(SE1->E1_VENCTO), "DADOS DA DCT") }
      //IF U_ITMSG("Foi localizado uma DCT que foi gerada para este titulo. Deseja alterar a data de prorroga��o deste DCT?",;
      //           'ALTERACAO DATA DA PRORROGACAO',"Clique em Ver Detalhes para ver dados da DCT",1,2,2,,,,bBloco)
         SE1->(RecLock("SE1",.F.))
   	   SE1->E1_I_DTPRO  := M->E1_I_DTPRO
   	   SE1->(MsUnLock())
      //ENDIF
   ENDIF

   SE1->(DBSETORDER(1))

   RestArea(_aArea)

   For _nI := 1 to Len(_a1Struct)
      If	SE1->&(_a1Struct[_nI,1]) <> M->&(_a1Struct[_nI,1]) 
         
         If Alltrim(_a1Struct[_nI,2]) == "N"

            _cPict := PesqPict( "SE1",_a1Struct[_nI,1])
            _cOrig := Transform(SE1->&(_a1Struct[_nI,1]),_cPict) 
            _cAlt  := Transform(M->&(_a1Struct[_nI,1]),_cPict) 

         ElseIf Alltrim(_a1Struct[_nI,2]) == "D"

            _cOrig := DTOC(SE1->&(_a1Struct[_nI,1]))
            _cAlt  := DTOC(M->&(_a1Struct[_nI,1]))

         ElseIf Alltrim(_a1Struct[_nI,2]) == "L"

            _cOrig := Iif(SE1->&(_a1Struct[_nI,1]),".T.",".F.")
            _cAlt  := Iif(M->&(_a1Struct[_nI,1]),".T.",".F.")

         Else

            _cOrig := SE1->&(_a1Struct[_nI,1])
            _cAlt  := M->&(_a1Struct[_nI,1])

         EndIf

         U_FA040L("SE1",1,_a1Struct[_nI,1],_cOrig,_cAlt,SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),SE1->E1_FILIAL,SE1->E1_NUM,"FINA040")
      EndIf	
   Next
EndIf

Return uRet



/*
===============================================================================================================================
Programa----------: FA040L
Autor-------------: Igor Melga�o
Data da Criacao---: 02/01/2025
===============================================================================================================================
Descri��o---------: Grava log de ajuste de flag de planejamento log�stico
===============================================================================================================================
Parametros--------: _cAlias,_nOrdem,_cCampo,_cOrig,_cAlt,_cChave,_cFilial,_cID,_cOrigem
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function FA040L(_cAlias As Character,_nOrdem As Numeric,_cCampo As Character,_cOrig As Character,_cAlt As Character,_cChave As Character,_cFilial As Character,_cID As Character,_cOrigem As Character)

Z07->( RecLock( "Z07" , .T. ) )
						
Z07->Z07_FILIAL	:= xFilial("Z07")
Z07->Z07_ALIAS		:= _cAlias
Z07->Z07_ORDEM		:= _nOrdem
Z07->Z07_CHAVE		:= _cChave //SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
Z07->Z07_OPCAO		:= 'B'
Z07->Z07_CAMPO		:= _cCampo //'E1_VENCTO'
Z07->Z07_CONORG	:= _cOrig
Z07->Z07_CONALT	:= _cAlt
Z07->Z07_CODUSU	:= RetCodUsr()
Z07->Z07_DATA		:= Date()
Z07->Z07_HORA		:= Time()
Z07->Z07_IFILIA	:= _cFilial
Z07->Z07_INUM		:= _cID
IF Z07->(FIELDPOS("Z07_ORIGEM")) <> 0
   Z07->Z07_ORIGEM := _cOrigem
ENDIF
											
Z07->( MsUnLock() )

Return



