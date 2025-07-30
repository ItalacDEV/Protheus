/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 15/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Totvs.Ch"

/*
===============================================================================================================================
Programa--------: AOMS030
Autor-----------: Julio de Paula Paz
Data da Criacao-: 06/07/2016
===============================================================================================================================
Descrição-------: Rotinas variadas de tratamento do Armazem 40. Chamado 15690.
                  a) Não permitir que o armazem do pallet seja alterado se o armazem do pedido de origem for o armazem 40.
                  b) Quando o armazem do pedido de origem for alterado de armazem 40 para outro armazem, alterar o armazem do 
                  pallet para o armazem de origem do pallet (BZ_LOCAL).
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS030(_cChamada)
Local _lRet := .T.
Local _nLocal, _nI
Local _cArm40 := AllTrim( U_ItGetMv("IT_ARMAZE40") )
Local _lTemArm40, _lNaoTemArm40

Begin Sequence                 
   Do Case 
      Case _cChamada == "ITEM_PALLET" 
           //==============================================================================================
           // Esta rotina deve ser chamada apenas na operação alteração.
           //==============================================================================================
           If ! Altera
              Break
           EndIf
      
           //==============================================================================================
           // Não permitir que o armazém de um item de pallet seja alterado quando este estiver vinculado
           // a um pedido de origem, cujo os itens estejam em um armazém 40.
           //==============================================================================================
           _lTemArm40 := .F.
           
           If !Empty(M->C5_I_NPALE)  .And. M->C5_I_PEDGE <> "S" // Indica que é pedido de Pallet            
              //==============================================================================================
              // Verifica se há armazem 40 no item do pedido de origem.
              //==============================================================================================
              SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO           
              SC6->(DbSeek(xFilial("SC6")+M->C5_I_NPALE)) 
              Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+M->C5_I_NPALE
                 If AllTrim(_cArm40) == AllTrim(SC6->C6_LOCAL)
                    _lTemArm40 := .T.                                          
                    Exit
                 EndIf  
                 
                 SC6->(DbSkip())
              EndDo
              
              _nLocal := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_LOCAL"	} )
              
              //==============================================================================================
              // Se existir armazem 40 no item do pedido de origem, não permite mudar o armazem no item do
              // pallet.
              //==============================================================================================
              If _lTemArm40
                 //If AllTrim(aCols[n,_nLocal]) <> AllTrim(_cArm40)
                 If AllTrim(M->C6_LOCAL) <> AllTrim(_cArm40)
                    _lRet := .F.
                    MsgStop("Não é permitido mudar o armazém de um item de pallet, quando o pedido que originou o pedido de pallet está vinculado a um armazém 40.","Atenção")                                             
                 EndIf
              EndIf
           EndIf
           
      Case _cChamada == "ITEM_PEDIDO_ORIGEM"     
           _lNaoTemArm40 := .F.
           
           If !Empty(M->C5_I_NPALE)  .And. M->C5_I_PEDGE == "S" // Indica que é um pedido de origem.
              _nLocal := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "C6_LOCAL"	}) 
              //==============================================================================================
              // Verifica se os armazens de todos os itens do pedido de origem foram alterados para armazens
              // diferentes do armazem 40.
              //==============================================================================================
              For _nI := 1 To Len(aCols)
                  If !aCols[_nI][Len(aCols[_nI])]  // Se a linha do aCols não estiver deletada.
	                 If AllTrim(aCols[_nI,_nLocal]) <> AllTrim(_cArm40)
                        _lNaoTemArm40 := .T.		  
		             EndIf
                  EndIf   
              Next   
           EndIf        
           
           If _lNaoTemArm40
              //==============================================================================================
              // Se todos os itens do pedido de origem estiver com armazem diferente de 40, altera os 
              // armazens dos pallets para os armazens de origem.
              //==============================================================================================
              SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO           
              SC6->(DbSeek(xFilial("SC6")+M->C5_I_NPALE)) 
              Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+M->C5_I_NPALE
                 SC6->(RecLock("SC6",.F.))
                 SC6->C6_LOCAL := Posicione("SBZ",1,xFilial("SBZ") + SC6->C6_PRODUTO,"BZ_LOCPAD")
                 SC6->(MsUnlock())
                 
                 SC6->(DbSkip())
              EndDo
           
           EndIf
   EndCase           

End Sequence

Return _lRet