/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
   Autor          |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 16/04/2019 | Validação p/ não permitir fracionamento de UM que são inteiras. Chamado 28685
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
/*
===============================================================================================================================
Programa----------: MA270TOK
Autor-------------: Renato de Morcerf
Data da Criacao---: 03/02/2009
===============================================================================================================================
Descrição---------: Ponto de Entrada que valida movimento lancamento de inventario
===============================================================================================================================
Uso---------------: Valida a obrigatoriedade do preenchimento da segunda unidade de medida quando os produtos pertence ao
------------------: grupo de produto 0006(Queijo) para controle de estoque de pecas de queijo.
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------: .T. = Permite confirmar lancamento
------------------: .F. = Nao Permite confirmar lancamento
===============================================================================================================================
*/
User Function MA270TOK()

Local	aArea	:= GetArea()
Local 	_npl  	:= M->B7_COD
Local 	nQtd2UM := M->B7_QTSEGUM
Local	nQtd    := M->B7_QUANT
Local 	n_ret	:= .T.   
Local _cUM_NO_Fracionada:=U_ITGetMV("IT_UMNOFRAC","PC,UN")
Local _lValidFrac1UM:=.T.

If SubStr(_npl,1,4) == "0006"
	If nQtd2UM == 0 .and. nQtd > 0 
		xmaghelpfis("Segunda Unidade de Medida Vazio","Para esse produto e obrigatorio o preenchimento da segunda unidade de medida (Peças).",;
		"Favor preencher a segunda unidade de medida (Peças)!!")
		n_ret := .F.
	EndIf
EndIf

If Altera .and. M->B7_I_ACERT = "1" .and. !empty(M->B7_I_DTACE)
	xmaghelpfis("Inventário já processado","Alteração não permitida para inventários já processados",;
		"Favor incluir novo lançamento de inventário")
	n_ret := .F.
Endif

ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
   If ZZL->(FIELDPOS("ZZL_PEFRPA")) = 0 .OR. ZZL->ZZL_PEFRPA == "S"
	  _lValidFrac1UM:=.F.
   EndIf
EndIf
ZZL->( DBSetOrder(1) )

SB1->(DBSETORDER(1))
IF n_ret .AND._lValidFrac1UM .AND. SB1->(dbSeek(xFilial("SB1") + M->B7_COD )) //.AND. SB1->B1_TIPO == "PA" 
   IF (SB1->B1_UM $ _cUM_NO_Fracionada .AND. M->B7_QUANT <> Int(M->B7_QUANT))
		U_ITMSG("Não é permitido fracionar a quantidade da 1a. UM de produto onde a Unid. Medida for "+_cUM_NO_Fracionada+".",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		        "Validação Fracionado",;
		        "Favor informar apenas quantidades inteiras na Primeira Unidade de Medida.",1)

		n_ret := .F. 
   ENDIF
   IF ( SB1->B1_SEGUM $ _cUM_NO_Fracionada .AND. M->B7_QTSEGUM <> Int(M->B7_QTSEGUM) )
		U_ITMSG("Não é permitido fracionar a quantidade da 2a. UM de produto onde a Unid. Medida for "+_cUM_NO_Fracionada+".",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		        "Validação Fracionado",;
		        "Favor informar apenas quantidades inteiras na Segunda Unidade de Medida.",1)

		n_ret := .F. 
	ENDIF
ENDIF
	

RestArea(aArea)
Return n_ret
