/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
              |            | 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa--------: AFIN026
Autor-----------: Julio de Paula Paz
Data da Criacao-: 11/07/2018
===============================================================================================================================
Descri��o-------: Rotina que permite reabir ou fechar titulos das comiss�es dos vendedores.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AFIN026()
Local _aOrd := SaveOrd({"SE3"})
Local _cI_Fech := ""
Local _aRecnoSE3 := {}
Local _nI

Begin Sequence
   If ! U_ITACSUSR( "ZZL_ALTFEC" , "S" , __CUSERID )
      U_ITMSG("Usu�rio sem permiss�o para alterar a situa��o do t�tulo de comiss�o, de fechado para aberto ou de aberto para fechado.","Aten��o", ,1)     
      Break
   EndIf
    
   SE3->(DbSetOrder(1)) // E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND                                                                                                           
   If ! SE3->(DbSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA)))
      U_ITMSG("N�o foram encontrados t�tulos de comiss�o, vinculados a este Titulo Financeiro.","Aten��o", ,1)     
      Break
   EndIf
   
   If SE3->E3_I_FECH == "S"
      If U_ITMSG("O t�tulo de comiss�o vinculado a este t�tulo do financeiro j� foi fechado.","Aten��o" ,"Deseja reabr�-lo?", ,2, 2)
         _cI_Fech := "N"
      Else
         Break
      EndIf 
   Else
      If U_ITMSG("O t�tulo de comiss�o vinculado a este t�tulo do financeiro est� aberto.","Aten��o" ,"Deseja fech�-lo?", ,2, 2)     
         _cI_Fech := "S"
      Else
         Break
      EndIf
   EndIf
   
   Do While !  SE3->(Eof()) .And. SE3->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA) == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA)
     
      Aadd(_aRecnoSE3, SE3->(Recno()))
   
      SE3->(DbSkip())
   EndDo

   For _nI := 1 To Len(_aRecnoSE3)   
       //=================================================================
       // Posicina no registro da tabe SE3.
       //=================================================================     
       SE3->(DbGoTo(_aRecnoSE3[_nI]))
       
       //=================================================================
       // Grava o t�tulo da tabela SE3 como fechado ou reaberto.
       //=================================================================     
       SE3->(RecLock("SE3",.F.))
       SE3->E3_I_FECH := _cI_Fech 
       SE3->(MsUnlock())
       
       //=================================================================
       // Grava log em tabela tempor�ria.
       //=================================================================     
       ZGK->(RecLock("ZGK", .T.))
       ZGK->ZGK_FILIAL  := SE3->E3_FILIAL    //  Filial
       ZGK->ZGK_VEND    := SE3->E3_VEND      //  Vendedor
       ZGK->ZGK_NOMEVD  := Posicione("SA3",1,xFilial("SA3")+SE3->E3_VEND,"A3_NOME")  //  Nome Vended
       ZGK->ZGK_NUM     := SE3->E3_NUM       //  No. Titulo
       ZGK->ZGK_EMISSAO := SE3->E3_EMISSAO   //  Dt Comiss�o
       ZGK->ZGK_SERIE   := SE3->E3_SERIE     //  Serie N.F.
       ZGK->ZGK_CODCLI  := SE3->E3_CODCLI    //  Cliente
       ZGK->ZGK_LOJA    := SE3->E3_LOJA      //  Loja
       ZGK->ZGK_NOMECL  := Posicione("SA1",1,xFilial("SA1")+SE3->E3_CODCLI+SE3->E3_LOJA,"A1_NOME")   //  Nome Cliente
       ZGK->ZGK_BASE    := SE3->E3_BASE      //  Vlr.Base
       ZGK->ZGK_PORC    := SE3->E3_PORC      //  % Vl.Base
       ZGK->ZGK_COMIS   := SE3->E3_COMIS     //  Comiss�o
       ZGK->ZGK_DATA    := SE3->E3_DATA      //  Data Pagto
       ZGK->ZGK_MENSAG  := If(_cI_Fech == "S","O t�tulo de comiss�o estava aberto e foi fechado.","O t�tulo de comiss�o estava fechado e foi aberto.")   //  Mensagem Vld
       ZGK->ZGK_USUARI  := __cUserId         //  Cod.Usuario
       ZGK->ZGK_DTLOG   := Date()            //  Dt.Grv.Log
       ZGK->(MsUnlock())      
   Next
      
End Sequence

RestOrd(_aOrd)

Return Nil