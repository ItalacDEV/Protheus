/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
   Autor          |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 12/04/2019 | Validação p/ não permitir fracionamento de UM que são inteiras. Chamado 28685
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"   
#DEFINE CRLF CHR(13)+CHR(10)   

/*
===============================================================================================================================
Programa----------: MA650TOK
Autor-------------: Carlos Cleber A.Silva
Data da Criacao---: 08/01/2014 
===============================================================================================================================
Descricao---------: Geração de Ordens de Produção chamado da função A650TudoOk() do MATA650
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet := .T. Prossegue com a criacao da OP 
                    lRet := .F. Nao prossegue com a criacao da OP
===============================================================================================================================
*/
User Function MA650TOK()    

Local lRet     := .T.  
Local dDtServ  := dDataBase
Local dDtAtual := DATE() 
Local dDtEms   := (M->C2_EMISSAO)
Local _lValidFrac1UM:=.T.

If dDtServ > dDtAtual .Or. dDtEms > dDtServ  
   U_ITMSG("Para incluir Ordem de Produção a 'Data de emissão' não pode ser maior que a 'Data atual do servidor ou Data base do sistema'. Não é permitido criar Ordem de Produção com data futura! ",;
	       "PROBLEMA DATA BASE","Data Atual(SO): "+DTOC(dDtAtual)+" "+CRLF+"Data Base(Sistema): "+DTOC(dDtServ)+" "+CRLF+"Data Emissão: "+DTOC(dDtEms),; 
		   "Conferir a 'Data Base do sistema' e ajustar a 'Data de emissão' se necessário.",1)
   lRet := .F. 
EndIf

ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
   If ZZL->(FIELDPOS("ZZL_PEFRPA")) = 0 .OR. ZZL->ZZL_PEFRPA == "S"
	  _lValidFrac1UM:=.F.
   EndIf
EndIf
ZZL->( DBSetOrder(1) )

SB1->(DBSETORDER(1))
IF _lValidFrac1UM .AND. SB1->(dbSeek(xFilial("SB1") + M->C2_PRODUTO )) .AND. SB1->B1_TIPO == "PA" 
   IF (SB1->B1_UM == "UN" .AND. M->C2_QUANT <> Int(M->C2_QUANT))
		U_ITMSG("Não é permitido fracionar a quantidade da 1a. UM de produto onde a Unid. Medida for UN.",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		        "Validação Fracionado",;
		        "Favor informar apenas quantidades inteiras na Primeira Unidade de Medida.",1)

		lRet := .F. 
   ENDIF
   IF ( SB1->B1_SEGUM = "PC" .AND. LEFT(M->C2_PRODUTO,4)=="0006" .AND. M->C2_QTSEGUM <> Int(M->C2_QTSEGUM) )
		U_ITMSG("Não é permitido fracionar a quantidade da 2a. UM de produto do grupo 0006 onde a Unid. Medida for PC.",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		        "Validação Fracionado",;
		        "Favor informar apenas quantidades inteiras na Segunda Unidade de Medida.",1)

		lRet := .F. 
	ENDIF
ENDIF

Return(lRet)