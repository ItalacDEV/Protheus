/*
==============================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteracao
==============================================================================================================================================================
Bremmer  - Alex Wallauer - 07/10/24 - 08/10/24 - 48629   - Tratamento para o campo novo HC_I_DESCP, descricao do produto.
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch" 

/*
===============================================================================================================================
Função-------------: MT750CMP()
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/06/2024
===============================================================================================================================
Descrição----------: Chamado 46914. Ponto de entrada para adição de campos na tela do cadastro do Plano Mestre de Produção. 
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function MT750CMP()
Local _aCampos := ParamIxb[1]
Local _nI, _aCmpTela := {}

Begin Sequence 
   
   For _nI := 1 To Len(_aCampos)
       
       Aadd(_aCmpTela,_aCampos[_nI])

       If AllTrim(_aCampos[_nI]) == "HC_PRODUTO"
          Aadd(_aCmpTela,"HC_I_DESCP")
       ENDIF

       If AllTrim(_aCampos[_nI]) == "HC_DATA"
          Aadd(_aCmpTela,"HC_I_UNIMD")
       EndIf

       If AllTrim(_aCampos[_nI]) == "HC_QUANT"
          Aadd(_aCmpTela,"HC_I_QTD2U")
          Aadd(_aCmpTela,"HC_I_2UNIM ")
       EndIf
   Next

   _aCampos := Aclone(_aCmpTela)

End Sequence 

Return _aCampos

/*
===============================================================================================================================
Função-------------: MT750GAT()
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/06/2024
===============================================================================================================================
Descrição----------: Gatilhos para os campos do cadastro do Plano Mestre de Produção.
===============================================================================================================================
Parametros---------: _cCampo = Campo que chamou a função
===============================================================================================================================
Retorno------------: _xRet = Retorno para o campo Contradomínio.
===============================================================================================================================
*/  
User Function MT750GAT(_cCampo)
Local _xRet 

Begin Sequence 
   
   SB1->(DbSetOrder(1))

   If _cCampo == "HC_PRODUTO"
      _xRet := M->HC_PRODUTO
      
      If SB1->(MsSeek(xFilial("SB1")+M->HC_PRODUTO))
         M->HC_I_UNIMD := SB1->B1_UM   
         M->HC_I_DESCP := SB1->B1_DESC
         M->HC_I_2UNIM := SB1->B1_SEGUM    
      EndIf 

   ElseIf _cCampo == "HC_QUANT"
       _xRet := M->HC_QUANT

       If SB1->(MsSeek(xFilial("SB1")+M->HC_PRODUTO))
          If SB1->B1_TIPCONV == "M"  // M=Multiplicador
             M->HC_I_QTD2U :=  M->HC_QUANT * SB1->B1_CONV  
          ElseIf SB1->B1_TIPCONV == "D"  // D=Divisor
             M->HC_I_QTD2U :=  M->HC_QUANT / SB1->B1_CONV
          EndIF 

          If Empty(M->HC_I_UNIMD)
             M->HC_I_UNIMD := SB1->B1_UM   
          EndIf 

          If Empty(M->HC_I_2UNIM)
             M->HC_I_2UNIM := SB1->B1_SEGUM    
          EndIf 

       EndIf

   ElseIf _cCampo == "HC_I_QTD2U"
       _xRet := M->HC_I_QTD2U

       If SB1->(MsSeek(xFilial("SB1")+M->HC_PRODUTO))
          If SB1->B1_TIPCONV == "M"  // M=Multiplicador
             M->HC_QUANT :=  M->HC_I_QTD2U / SB1->B1_CONV  
          ElseIf SB1->B1_TIPCONV == "D"  // D=Divisor
             M->HC_QUANT :=  M->HC_I_QTD2U * SB1->B1_CONV
          EndIF 

          If Empty(M->HC_I_UNIMD)
             M->HC_I_UNIMD := SB1->B1_UM   
          EndIf 

          If Empty(M->HC_I_2UNIM)
             M->HC_I_2UNIM := SB1->B1_SEGUM    
          EndIf 
       EndIf 
       
   EndIf 

End Sequence 

Return _xRet 


