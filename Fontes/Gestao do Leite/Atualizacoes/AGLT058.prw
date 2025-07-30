/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
     Autor     |    Data    |                                             Motivo                                           
------------------------------------------------------------------------------------------------------------------------------- 
               |            | 
=============================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch" 

/*
===============================================================================================================================
Programa----------: AGLT058
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/05/2024
===============================================================================================================================
Descrição---------: Permite Visualizar Integração de Notas Fiscais Rejeitadas e Aceitas no Envio de Dados para a Cia do Leite.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT058()
Local _aCores := {}
Private cCadastro 

Private aRotina := {}

   Aadd(aRotina,{"Pesquisar"                                             ,"AxPesqui"       ,0,1})
   Aadd(aRotina,{"Visualizar"                                            ,"AxVisual"       ,0,2})
   Aadd(aRotina,{"Notas Fiscais/Demonstrativos Aceitos"                  ,"U_AGLT058Y('A')",0,2})
   Aadd(aRotina,{"Notas Fiscais/Demonstrativos Rejeitadas"               ,"U_AGLT058Y('R')",0,2})
   Aadd(aRotina,{"Gera Arquivo Texto Notas Fiscais/Demonstrativos Rejeitadas nas Integrações" ,'U_MGLT29OM("J")',0,2})
   Aadd(aRotina,{"Gera Arquivo Texto Notas Fiscais/Demonstrativos Aceitas nas Integrações"    ,'U_MGLT29OM("K")',0,2})
   Aadd(aRotina,{"Legenda"                                               ,"U_AGLT058L() "       ,0,2})

   Aadd(_aCores,{"ZBM_STATUS == 'A'" ,"BR_AZUL" })
   Aadd(_aCores,{"ZBM_STATUS == 'R'" ,"BR_VERMELHO" })
   Aadd(_aCores,{"ZBM_STATUS == ' ' .And. (ZBM_STATNF == ' ' .Or. ZBM_STATNF == 'N') " ,"BR_AMARELO" })

   DbSelectArea("ZBM")
   ZBM->(DbSetOrder(1)) 
   ZBM->(DbGoTop())

   cCadastro := "Integração de Notas Fiscais e Demonstrativos para o App Cia do Leite"   

   MBrowse(6,1,22,75,"ZBM", , , , , , _aCores)

Return Nil

/*
===============================================================================================================================
Programa----------: AGLT058Y
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/02/2022
===============================================================================================================================
Descrição---------: Permite Visualizar os dados das Notas Fiscais e Demonstrativos Rejeitadas no Envio de Dados para a Cia do 
                    Leite.
===============================================================================================================================
Parametros--------: _cTipoDado == "R" = Dados rejeitados na integração
                                  "A" = Dados aceitos na integração
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT058Y(_cTipoDado)

Private aRotina := {}
Private cCadastro 
Private _aCampos := {}

Begin Sequence 
   
   If _cTipoDado == "R"
      ZBM->(DbSetFilter( { || ZBM_STATUS == "R" }, 'ZBM_STATUS == "R"' ) )
      cCadastro := "Dados das Notas Fiscais e Demonstrativos Rejeitados no Envio de Dados para o Sistema Cia do Leite"
   Else
      ZBM->(DbSetFilter( { || ZBM_STATUS == "A" }, 'ZBM_STATUS == "A"' ) )
      cCadastro := "Dados das Notas Fiscais e Demonstrativos Aceitos no Envio de Dados para o Sistema Cia do Leite"
   EndIf 

   _aCampos := {}
   Aadd(_aCampos,"ZBM_NRNFE")
   Aadd(_aCampos,"ZBM_SERNFE")
   Aadd(_aCampos,"ZBM_CHVNFE")
   Aadd(_aCampos,"ZBM_DTEMIS")
   Aadd(_aCampos,"ZBM_CODPRO")
   Aadd(_aCampos,"ZBM_LOJPRO")
   Aadd(_aCampos,"ZBM_NOMPRO")
   Aadd(_aCampos,"ZBM_PDFNFE")
   Aadd(_aCampos,"ZBM_PDFEXT")
   Aadd(_aCampos,"ZBM_RETNFE")
   Aadd(_aCampos,"ZBM_DTRETN")
   Aadd(_aCampos,"ZBM_HRRETN")
   Aadd(_aCampos,"ZBM_RETEXT")
   Aadd(_aCampos,"ZBM_DTRETE")
   Aadd(_aCampos,"ZBM_HRRETE")
   Aadd(_aCampos,"ZBM_JSONNF")
   Aadd(_aCampos,"ZBM_JSONEX")
   Aadd(_aCampos,"ZBM_DTENVN")
   Aadd(_aCampos,"ZBM_HRENVN")
   Aadd(_aCampos,"ZBM_STATNF")
   Aadd(_aCampos,"ZBM_DTENVE")
   Aadd(_aCampos,"ZBM_HRENVE")
   Aadd(_aCampos,"ZBM_STATEX")
   Aadd(_aCampos,"ZBM_CNPJLV")
   Aadd(_aCampos,"ZBM_VALNFE")
   Aadd(_aCampos,"ZBM_QTDLIT")
   Aadd(_aCampos,"ZBM_VALLIT")
   Aadd(_aCampos,"ZBM_AMREFE")
   Aadd(_aCampos,"ZBM_STATUS")
   Aadd(_aCampos,"ZBM_XMLNFE")

   ZBM->(DBGoTop())

   Aadd(aRotina,{"Pesquisar"                      ,"AxPesqui"   ,0,1,0})
   //Aadd(aRotina,{"Visualizar"                     ,"U_AGLT058W('ZBM', _aCampos, cCadastro)" ,0,2,0})
   Aadd(aRotina,{"Visualizar"                     ,"U_AGLT058V()" ,0,2,0})

   DbSelectArea("ZBM")
   ZBM->(DbSetOrder(1)) 
   ZBM->(DbGoTop())
      
   MBrowse(6,1,22,75,"ZBM")

   ZBM->(DBClearFilter())

End Sequence 

Return Nil    

/*
=================================================================================================================================
Programa--------: AGLT058W()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 18/04/2024
=================================================================================================================================
Descrição-------: Tela de Visualização dos dados de Integração Webservice Protheus x App Cia do Leite.
=================================================================================================================================
Parametros------: _cTab    = Alias da Tabela para Visualização dos Dados.
                  _aCampos = Campos que serão visualizados.
                  _cTitulo = Titulo da tela para a rotina que chamou a tela de visualização de dados.
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AGLT058W(_cTab, _aCampos, _cTitulo)
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel 
Local _oDlgEnch, _nI
Local _nReg := 2 , _nOpcx := 2

Private aHeader := {} , aCols := {}

Begin Sequence
  
   //================================================================================
   // Carrega os dados da tabela para visulização de dados.
   //================================================================================
   For _nI := 1 To Len(_aCampos)
       &("M->" + _aCampos[_ni]) :=  &(_cTab + "->" +_aCampos[_nI])
   Next
 
   //================================================================================
   // Monta a tela Enchoice 
   //================================================================================    
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk := {|| _oDlgEnch:End()}
   _bCancel := {|| _oDlgEnch:End()}
   
   Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
      
      EnChoice( _cTab ,_nReg, _nOpcx, , , ,_aCampos , _aPosObj[1], , 3 )
                        
   Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel) 

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AGLT058L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/05/2024
===============================================================================================================================
Descrição---------: Rotina de Exibição da Legenda do MBrowse.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT058L()      
Local _aLegenda := {}

Private cCadastro

Begin Sequence
   cCadastro := "Status das Integrações de Notas Fiscais e Demostrativos"

   Aadd(_aLegenda,{"BR_AZUL"    ,"Integrados com Sucesso!" })
   Aadd(_aLegenda,{"BR_VERMELHO","Rejeitados!" })
   Aadd(_aLegenda,{"BR_AMARELO" ,"Aguardando Integração!" })
      
   BrwLegenda(cCadastro, "Legenda", _aLegenda)

End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AGLT058V
Autor-----------: Julio de Paula Paz
Data da Criacao-: 08/05/2024
=================================================================================================================================
Descrição-------: Exibe os dados das integrações das notas fiscais e demonstrativos via WebService.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AGLT058V()
Local _aStrucZBN
Local _aCmpZBN := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _lInvZBN := .F.
Local _oDlgEnch, _nI
Local _nReg := 2 , _nOpcx := 2

Private _oMarkZBN, _cMarcaZBN := GetMark() 
Private aHeader := {} , aCols := {}

Begin Sequence
  
//------------------------------------------------------------------------------------------------ <<<<<<<<<<  
//============================================================================
   //Montagem do aheader                                                        
   //=============================================================================
   aHeader := {}
   FillGetDados(1,"ZBN",1,,,{||.T.},,,,,,.T.)
   
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   _aStrucZBN := {}
   //Aadd(_aStrucZBN,{"WKRECNO", "N", 10,0})
   For _nI := 1 To Len(aHeader)
       If AllTrim(aHeader[_nI,2])=="ZBN_FILIAL"
          Loop
       EndIf
       
       //                     Campo                 Titulo           Picture
       Aadd( _aCmpZBN , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
       
       Aadd(_aStrucZBN,{aHeader[_nI,2], aHeader[_nI,8], aHeader[_nI,4] ,aHeader[_nI,5]})
   Next   

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZBN") > 0
      TRBZBN->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZBN criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZBN",  _aStrucZBN )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZBN_ITEM"} )
   _otemp:Create()   
                                                                                 
   //================================================================================
   // Carrega os dados da tabela ZBM
   //================================================================================
   For _nI := 1 To ZBM->(FCount())
       &("M->"+ZBM->(FieldName(_nI))) :=  &("ZBM->"+ZBM->(FieldName(_nI)))
   Next
   
   //================================================================================
   // Carrega os dados da tabela ZBN
   //================================================================================
   ZBN->(DbSetOrder(5))  // ZBN_FILIAL+ZBN_CHVNFE+ZBN_STATNF+Dtos(ZBN_DTENVN)
   ZBN->(DbSeek(ZBM->(ZBM_FILIAL+ZBM_CHVNFE)))
   Do While ! ZBN->(Eof()) .And. ZBN->(ZBN_FILIAL+ZBN_CHVNFE) == ZBM->(ZBM_FILIAL+ZBM_CHVNFE)
      If ZBN->ZBN_REGCAP <> ZBM->ZBM_REGCAP
         ZBN->(DbSkip())
         Loop
      EndIf
      
      TRBZBN->(RecLock("TRBZBN",.T.))
      For _nI := 1 To TRBZBN->(FCount())
          If AllTrim(TRBZBN->(FieldName(_nI))) == "ZBN_ALI_WT" 
             TRBZBN->ZBN_ALI_WT := "ZBN" 
          ElseIf AllTrim(TRBZBN->(FieldName(_nI))) == "ZBN_REC_WT"
             TRBZBN->ZBN_REC_WT := ZBN->(Recno())
          Else
             &("TRBZBN->"+TRBZBN->(FieldName(_nI))) :=  &("ZBN->"+TRBZBN->(FieldName(_nI)))
          EndIf
      Next
      TRBZBN->(MsUnlock())
      
      ZBN->(DbSkip())
   EndDo
   TRBZBN->(DbGoTop())
                                       
   //================================================================================
   // Monta a tela Enchoice ZBM  x MsSelect ZBN
   //================================================================================    
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk := {|| _oDlgEnch:End()}
   _bCancel := {|| _lRet := .F., _oDlgEnch:End()}
                       
   _cTitulo := "Integração de Notas Fiscais e Demonstrativos Via WebService para a Cia do Leite - Visualização"
   
   Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
      
      EnChoice( "ZBM" ,_nReg, _nOpcx, , , , , _aPosObj[1], , 3 )
            
      _oMarkZBN := MsSelect():New("TRBZBN","","",_aCmpZBN,@_lInvZBN, @_cMarcaZBN,{_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4]})      
        
   Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel) 

End Sequence

//================================================================================
// Fecha e exclui as tabelas temporárias
//================================================================================                    
If Select("TRBZBN") > 0
   TRBZBN->(DbCloseArea())
EndIf

Return Nil
   