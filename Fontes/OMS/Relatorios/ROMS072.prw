/*  
========================================================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
========================================================================================================================================================
    Autor    |    Data    |                                             Motivo                                           
--------------------------------------------------------------------------------------------------------------------------------------------------------
             |            | 
========================================================================================================================================================
*/
//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#Include "protheus.ch"
 
/*
===============================================================================================================================
Programa----------: ROMS072
Autor-------------: Julio de Paula Paz
Data da Criacao---: 02/12/2022
===============================================================================================================================
Descri��o---------: Lista Condi��es de Pagamento Personalizada para o cliente posicionado.
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
   
   //_aTitulos := {"Condi��o Pagamento","Desc.Cond.Pagto","Item","Filial da Regra","Produto","Desc.Produto","Rede","Nome da Rede"}
   _aTitulos := {"Condi��o Pagamento","Desc.Cond.Pagto","Produto","Desc.Produto","Rede","Nome da Rede"}

   ZGO->(DbSetOrder(2)) // ZGO_CLIENT+ZGO_LOJA
   ZGO->(DbSeek(SA1->A1_COD+SA1->A1_LOJA))
   
   Do While ! ZGO->(Eof()) .And. ZGO->ZGO_CLIENT+ZGO->ZGO_LOJA == SA1->A1_COD+SA1->A1_LOJA
      
      Aadd(_aDados,{ZGO->ZGO_CONDPA,; // Condi��o Pagto  // SE4
                    POSICIONE("SE4",1,XFILIAL("SE4")+ZGO->ZGO_CONDPA,"E4_DESCRI"),;// ZGO->ZGO_CONDNI // Descri��o Cond.Pagtp.  // virtual //ZGO->ZGO_ITEM,;   // Item  //ZGO->ZGO_FILCD,;  // Filial da regra
                    ZGO->ZGO_PRODUT,; // Produto
                    If(!empty(ZGO->ZGO_PRODUT),POSICIONE("SB1",1,XFILIAL("SB1")+ZGO->ZGO_PRODUT,"B1_DESC"),""),;  //ZGO->ZGO_PRONOM // Descri��o Produto 
                    ZGO->ZGO_REDE,;   // Rede 
                    If(!Empty(ZGO->ZGO_REDE),POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI"),"")}) // ZGO->ZGO_REDNOM // Nome da rede.         // virtual // IF(!INCLUI,POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI")," ")
      
      ZGO->(DbSkip()) 
   EndDo 
   
   If Empty(_aDados)
      ZGO->(DbSetOrder(5)) // ZGO_REDE
      ZGO->(DbSeek(SA1->A1_GRPVEN))
   
      Do While ! ZGO->(Eof()) .And. ZGO->ZGO_REDE == SA1->A1_GRPVEN
      
         Aadd(_aDados,{ZGO->ZGO_CONDPA,; // Condi��o Pagto  // SE4
                       POSICIONE("SE4",1,XFILIAL("SE4")+ZGO->ZGO_CONDPA,"E4_DESCRI"),;// ZGO->ZGO_CONDNI // Descri��o Cond.Pagtp.  // virtual //ZGO->ZGO_ITEM,;   // Item  //ZGO->ZGO_FILCD,;  // Filial da regra
                       ZGO->ZGO_PRODUT,; // Produto
                       If(!empty(ZGO->ZGO_PRODUT),POSICIONE("SB1",1,XFILIAL("SB1")+ZGO->ZGO_PRODUT,"B1_DESC"),""),;  //ZGO->ZGO_PRONOM // Descri��o Produto 
                       ZGO->ZGO_REDE,;   // Rede 
                       If(!Empty(ZGO->ZGO_REDE),POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI"),"")}) // ZGO->ZGO_REDNOM // Nome da rede.         // virtual // IF(!INCLUI,POSICIONE("ACY",1,XFILIAL("ACY")+ZGO->ZGO_REDE,"ACY_DESCRI")," ")
      
         ZGO->(DbSkip()) 
      EndDo 
   EndIf

   If Empty(_aDados)
      Aadd(_aDados,{" ",; // Condi��o Pagto  // SE4
               " ",; // Desc.Cond.Pagto //" ",; // Item  " ",; // Filial da regra
               " ",; // Produto
               " ",; // Descri��o Produto 
               " ",; // Rede 
               " "}) // Desc.Rede
   EndIf 

   U_ITListBox("Listagem de Condi��es de Pagamento Personalizada" , _aTitulos , _aDados , .T. , 1 , "Exporta��o excel/arquivo")

End Sequence 

Return Nil 
