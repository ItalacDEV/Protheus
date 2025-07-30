/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista   - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o                                                                                    
=============================================================================================================================== 
Andr�       - Julio Paz    - 16/09/24 - 17/01/25 -  48539  - Recalcular e alterar as quantidades dos itens de pedidos de compras do tipo servi�o, conforme regras definidas.                              
=============================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch" 
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH" 
/*
===============================================================================================================================
Fun��o-------------: ACOM041
Autor--------------: Julio de Paula Paz
Data da Criacao----: 16/09/2024
===============================================================================================================================
Descri��o----------: Fun��o de controle de inclus�es de solicita��es de compras e pedidos de compras que possuem 
                     produtos do tipo presta��o de servi�os.
                     Retorna conte�do para os campos C1_I_SVPAR e C7_I_SVPAR.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: _cRet = "S" = Sim, possui controle de entregas parciais.
                           = "N" = N�o, n�o possui controle de entregas parciais.
===============================================================================================================================
*/  
User Function ACOM041()
Local _cRet := "N"

Begin Sequence 
   
   If FWISINCALLSTACK("MATA110") // Chamada da Solicita��o de Vendas

      _nPosProd  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C1_PRODUTO"}) 
      _cTipo   := Posicione("SB1",1,xFilial("SB1")+Acols[N,_nPosProd],"B1_TIPO") 
      
      If _cTipo == "SV"
         If U_ITMSG("Produto servi�o: controlar entregas parciais?","Aten��o" , , ,2, 2)
            _cRet := "S"
         EndIf 
      EndIf 
   Else // Chamada do Pedido de Vendas
      _nPosProd  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_PRODUTO"}) 
      _cTipo   := Posicione("SB1",1,xFilial("SB1")+Acols[N,_nPosProd],"B1_TIPO") 
      
      If _cTipo == "SV"
         If U_ITMSG("Produto servi�o: controlar entregas parciais?","Aten��o" , , ,2, 2)
            _cRet := "S"
         EndIf 
      EndIf 
   EndIf 

End Sequence

Return _cRet 

/*
===============================================================================================================================
Fun��o-------------: ACOM041
Autor--------------: Julio de Paula Paz
Data da Criacao----: 16/09/2024
===============================================================================================================================
Descri��o----------: Fun��o de controle de inclus�es de solicita��es de compras e pedidos de compras que possuem 
                     produtos do tipo presta��o de servi�os.
                     Retorna conte�do para os campos C1_I_SVPAR e C7_I_SVPAR.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: _cRet = "S" = Sim, possui controle de entregas parciais.
                           = "N" = N�o, n�o possui controle de entregas parciais.
===============================================================================================================================
*/  
User Function ACOM041P()
Local _nI
Local _nPosProd
Local _cTipo  
Local _nPosCrlEn

Begin Sequence 
   
   SC1->(DbSetOrder(2)) // C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM+C1_FORNECE+C1_LOJA

   _nPosCrlEn  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_I_SVPAR"}) 
   _nPosItem   := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_ITEM"}) 
   _nPosItSC   := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_ITEMSC"}) 
   _nPosNrSC   := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_NUMSC"}) 
   _nPosDesc   := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_DESCRI"})
   _nPosQtd    := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_QUANT"})
   _nPosQtdSo  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_QTDSOL"})
   _nPosTotal  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_TOTAL"})
   _nPosPreco  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_PRECO"})
   _nPosProd   := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C7_PRODUTO"})  

   For _nI := 1 To Len(aCols)
   
       _cTipo      := Posicione("SB1",1,xFilial("SB1")+Acols[_nI,_nPosProd],"B1_TIPO") 
      
       If _cTipo == "SV"
          
          If U_ITMSG("Produto servi�o: controlar entregas parciais?" + CRLF + ;
                     "Item: " + Acols[_nI,_nPosItem] + CRLF + ;
                     "Produto: " + AllTrim(Acols[_nI,_nPosProd]) + CRLF + ;
                     "Descri��o: " + AllTrim(Acols[_nI,_nPosDesc]) ;
                     ,"Aten��o" , , ,2, 2)

             //====================================================
             // Posicionar na SC1 para obten��o das Quantidades 
             //====================================================
             // Indice 2: C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM+C1_FORNECE+C1_LOJA
             SC1->(MsSeek(xFilial("SC1")+Acols[_nI,_nPosProd]+Acols[_nI,_nPosNrSC]+Acols[_nI,_nPosItSC]))
             
             //====================================================
             // Atualizar a SC7 com as quantidades da SC1 
             //====================================================
             Acols[_nI,_nPosCrlEn] := "S"
             /*
             Acols[_nI,_nPosQtd]   := SC1->C1_I_ORTOT //SC1->C1_TOTAL //Acols[_nI,_nPosTotal]
             Acols[_nI,_nPosQtdSo] := SC1->C1_I_ORTOT //SC1->C1_TOTAL //Acols[_nI,_nPosTotal]
             Acols[_nI,_nPosPreco] := 1
             Acols[_nI,_nPosTotal] := SC1->C1_I_ORTOT
             */
          EndIf 
       EndIf
       
   Next 

End Sequence 

Return Nil 

