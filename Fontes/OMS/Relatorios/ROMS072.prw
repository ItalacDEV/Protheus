/*  
========================================================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
========================================================================================================================================================
    Autor    |    Data    |                                             Motivo                                           
--------------------------------------------------------------------------------------------------------------------------------------------------------
             |            | 
========================================================================================================================================================
*/
//===========================================================================
//| Definições de Includes                                                  |
//===========================================================================
#Include "protheus.ch"
 
/*
===============================================================================================================================
Programa----------: ROMS072
Autor-------------: Julio de Paula Paz
Data da Criacao---: 02/12/2022
===============================================================================================================================
Descrição---------: Lista Condições de Pagamento Personalizada para o cliente posicionado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function ROMS072()
Local _aDados := {}
Local _aTitulos := {}

Begin Sequence 
   
   //_aTitulos := {"Condição Pagamento","Desc.Cond.Pagto","Item","Filial da Regra","Produto","Desc.Produto","Rede","Nome da Rede"}
   _aTitulos := {"Condição Pagamento","Desc.Cond.Pagto","Produto","Desc.Produto","Rede","Nome da Rede"}

   ZGO->(DbSetOrder(2)) // ZGO_CLIENT+ZGO_LOJA
   ZGO->(DbSeek(SA1->A1_COD+SA1->A1_LOJA))
   
   Do While ! ZGO->(Eof()) .And. ZGO->ZGO_CLIENT+ZGO->ZGO_LOJA == SA1->A1_COD+SA1->A1_LOJA
      
      Aadd(_aDados,{ZGO->ZGO_CONDPA,; // Condição Pagto  // SE4
                    POSICIONE("SE4",1,XFILIAL("SE4")+ZGO->ZGO_CONDPA,"E4_DESCRI"),;// ZGO->ZGO_CONDNI // Descrição Cond.Pagtp.  // virtual //ZGO->ZGO_ITEM,;   // Item  //ZGO->ZGO_FILCD,;  // Filial da regra
                    ZGO->ZGO_PRODUT,; // Produto
                    If(!empty(ZGO->ZGO_PRODUT),POSICIONE("SB1",1,XFILIAL("SB1")+ZGO->ZGO_PRODUT,"B1_DESC"),""),;  //ZGO->ZGO_PRONOM // Descrição Produto 
                    ZGO->ZGO_REDE,;   // Rede 
                    If(!Empty(ZGO->ZGO_REDE),POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI"),"")}) // ZGO->ZGO_REDNOM // Nome da rede.         // virtual // IF(!INCLUI,POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI")," ")
      
      ZGO->(DbSkip()) 
   EndDo 
   
   If Empty(_aDados)
      ZGO->(DbSetOrder(5)) // ZGO_REDE
      ZGO->(DbSeek(SA1->A1_GRPVEN))
   
      Do While ! ZGO->(Eof()) .And. ZGO->ZGO_REDE == SA1->A1_GRPVEN
      
         Aadd(_aDados,{ZGO->ZGO_CONDPA,; // Condição Pagto  // SE4
                       POSICIONE("SE4",1,XFILIAL("SE4")+ZGO->ZGO_CONDPA,"E4_DESCRI"),;// ZGO->ZGO_CONDNI // Descrição Cond.Pagtp.  // virtual //ZGO->ZGO_ITEM,;   // Item  //ZGO->ZGO_FILCD,;  // Filial da regra
                       ZGO->ZGO_PRODUT,; // Produto
                       If(!empty(ZGO->ZGO_PRODUT),POSICIONE("SB1",1,XFILIAL("SB1")+ZGO->ZGO_PRODUT,"B1_DESC"),""),;  //ZGO->ZGO_PRONOM // Descrição Produto 
                       ZGO->ZGO_REDE,;   // Rede 
                       If(!Empty(ZGO->ZGO_REDE),POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI"),"")}) // ZGO->ZGO_REDNOM // Nome da rede.         // virtual // IF(!INCLUI,POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI")," ")
      
         ZGO->(DbSkip()) 
      EndDo 
   EndIf

   If Empty(_aDados)
      Aadd(_aDados,{" ",; // Condição Pagto  // SE4
               " ",; // Desc.Cond.Pagto //" ",; // Item  " ",; // Filial da regra
               " ",; // Produto
               " ",; // Descrição Produto 
               " ",; // Rede 
               " "}) // Desc.Rede
   EndIf 

   U_ITListBox("Listagem de Condições de Pagamento Personalizada" , _aTitulos , _aDados , .T. , 1 , "Exportação excel/arquivo")

End Sequence 

Return Nil 
