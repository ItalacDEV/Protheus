/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço      | 29/10/2021 | Inclusão do campo F1_I_FUNDF para preenchimento na inclusão e classificação. Chamado 38037 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço      | 18/11/2021 | Colocado como inicialização padrão Nao o campo F1_I_FUNDF na inclusão e classificação. Chamado 38289 
===============================================================================================================================
*/

#include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MA103BUT
Autor-------------: Julio de Paula Paz
Data da Criacao---: 16/09/2019
===============================================================================================================================
Descrição---------: Ponto de entrada da criação de botões do menu da tela de classificação de notas fiscais de entradas.
                    Chamado 29762 e 30834. 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MA103BUT()
Local aButtons := {}
Local aArea := GetArea()
Local lEdit
Local nAba
Local oCbxFUNDFIX
Local _aBoxFUNDF := RetSX3Box(GetSX3Cache("F1_I_FUNDF", "X3_CBOX"),,,1)
Local _cIPFUNDF  := ""
Local _aCombo    := {}
Local _nI        := 0
Public _cFUNDFIX := ""

Begin Sequence
   
   Aadd(aButtons, {"Replica Tp.Op." , {|| U_A103TpOp() } , "Replica Dados para as Linhas"})

End Sequence
 
//Adiciona uma nova aba no documento de entrada
oFolder:AddItem("Italac", .T.)
nAba := Len(oFolder:aDialogs)

For _nI := 1 To Len(_aBoxFUNDF)
    AAdd(_aCombo,_aBoxFUNDF[_nI][3])
Next

If INCLUI
    _cFUNDFIX := CriaVar("F1_I_FUNDF",.F.)
    _cIPFUNDF := GetSX3Cache("F1_I_FUNDF","X3_RELACAO") 
    _cIPFUNDF := IIf(Empty(Alltrim(_cIPFUNDF))," ",&(Alltrim(_cIPFUNDF)))
    _cFUNDFIX := U_ITRetBox( _cIPFUNDF , "F1_I_FUNDF" )

    lEdit := .T.
Else
    _cFUNDFIX := U_ITRetBox( SF1->F1_I_FUNDF , "F1_I_FUNDF" )

    If Empty(Alltrim(_cFUNDFIX))
        _cIPFUNDF := GetSX3Cache("F1_I_FUNDF","X3_RELACAO") 
        _cIPFUNDF := IIf(Empty(Alltrim(_cIPFUNDF))," ",&(Alltrim(_cIPFUNDF)))
        _cFUNDFIX := U_ITRetBox( _cIPFUNDF , "F1_I_FUNDF" )
    EndIf

    lEdit := .F.
EndIf

//Criando na janela o campo 
@ 005, 003 SAY Alltrim(RetTitle("F1_I_FUNDF")) OF oFolder:aDialogs[nAba] PIXEL SIZE 050,006
@ 003, 053 COMBOBOX oCbxFUNDFIX VAR _cFUNDFIX ITEMS _aCombo SIZE 030, 006 OF oFolder:aDialogs[nAba] COLORS 0, 16777215  PIXEL 
oCbxFUNDFIX:bHelp := {|| ShowHelpCpo( "F1_I_FUNDF", {GetHlpSoluc("F1_I_FUNDF")[1]}, 5  )}

//Se não houver edição, desabilita os gets
If ! lEdit
    If TYPE("_lClassif") != "U"
        oCbxFUNDFIX:lActive := .T.
    Else
        oCbxFUNDFIX:lActive := .F.
    EndIf
EndIf

RestArea(aArea)

Return (aButtons)

/*
===============================================================================================================================
Programa----------: A103TpOp
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/09/2019
===============================================================================================================================
Descrição---------: Replica o tipo de operação para os itens da nota fiscal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A103TpOp()
Local _bOk, _bCancel
Local _lRet := .F.
Local _nLinha := N 
Local _nPosOper , T
Local _cValidOper := Getsx3cache("D1_OPER","X3_VALID")
Local _nPosProd, _nPosCC
Local _cValidCC := Getsx3cache("D1_CC","X3_VALID")

Private _cTipoOper := Space(2)
Private _cCodCC    := Space(9)                             

Begin Sequence
 
   _bOk := {|| _lRet := .T., _oDlgTPOp:End()}
   _bCancel := {|| _lRet := .F., _oDlgTPOp:End()}
                       
   _cTitulo := "Replica Dados Para os Itens da Nota Fiscal de Entrada"
   
   Define MsDialog _oDlgTPOp Title _cTitulo From 0,0 To 15, 80 Of oMainWnd 

      @ 040,010 SAY "Tipo de Operação:"	SIZE 065,010 PIXEL OF _oDlgTPOp 
      @ 040,060 MSGET _cTipoOper PICTURE "@!" F3 "DJ" Valid(Vazio() .Or. ExistCpo("SX5","DJ" + _cTipoOper)) SIZE 40,010 PIXEL OF _oDlgTPOp 
      
      @ 055,010 SAY "Centro de Custo:"	SIZE 065,010 PIXEL OF _oDlgTPOp 
      @ 055,060 MSGET _cCodCC PICTURE "@!" F3 "CTT" Valid(Vazio() .Or. ExistCpo("CTT",_cCodCC)) SIZE 40,010 PIXEL OF _oDlgTPOp

   Activate MsDialog _oDlgTPOp On Init EnchoiceBar(_oDlgTPOp,_bOk,_bCancel) CENTERED 

   If _lRet
      _nPosOper := AsCan(aHeader,{|x| AllTrim(x[2]) == "D1_OPER"})
      _nPosProd := AsCan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})      
      _nPosCC   := AsCan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"})
                                  
      If ! Empty(_cTipoOper)     
         __ReadVar := 'M->D1_OPER'
      
         For T := 1 To Len(aCols)
             N := T
             M->D1_OPER := _cTipoOper
             aCols[N,_nPosOper] := _cTipoOper
         
             If ! &(_cValidOper)
                U_ITMSG("Tipo de operação informado inexistente [" + aCols[N,_nPosOper] + "], para o Produto ["+AllTrim(aCols[N,_nPosProd])+"], linha: " + StrZero(N,3) + "." ,"Atenção", ,1)
                Exit
             EndIf

             If ExistTrigger("D1_OPER   ")  
                RunTrigger(2,T,,,"D1_OPER   ")  
             EndIf            
         Next 
      EndIf                  
      
      If ! Empty(_cCodCC)
         __ReadVar := 'M->D1_CC'
      
         For T := 1 To Len(aCols)
             N := T
             M->D1_CC := _cCodCC
             aCols[N,_nPosCC] := _cCodCC
         
             If ! &(_cValidCC)
                U_ITMSG("O Centro de Custo informado inexistente [" + aCols[N,_nPosCC] + "], para o Produto ["+AllTrim(aCols[N,_nPosProd])+"], linha: " + StrZero(N,3) + "." ,"Atenção", ,1)
                Exit
             EndIf

             If ExistTrigger("D1_CC     ")  
                RunTrigger(2,T,,,"D1_CC     ")  
             EndIf            
         Next
      EndIf
      
   EndIf

End Sequence

N := _nLinha

Return Nil 


