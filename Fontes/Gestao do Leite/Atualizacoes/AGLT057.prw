/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração                                               
=============================================================================================================================== 
Alex          - Julio Paz    - 26/12/24 - 26/12/24 - 49101   - Realização de ajustes nos filtros de dados e na instrução Count utilizando a função MPSysOpenQuery().
=============================================================================================================================== 
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"

/*
===============================================================================================================================
Programa----------: AGLT057V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/02/2022
===============================================================================================================================
Descrição---------: Permite Visualizar Coletas Rejeitadas e Aceitas no Envio de Dados para a Cia do Leite e Evomilk.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT057()
Local _aCores := {}
Local _nI As Numeric
Local _aParAux:= {}
Local _aParRet:= {}
Local _aOpcoes:= {}

Private aRotina := {}

Begin Sequence 

   Aadd( _aOpcoes , "1–Integrações Evomilk")
   Aadd( _aOpcoes , "2–Integrações Cia do Leite")
   Aadd( _aOpcoes , "3–Sem Filtro") 
 
   MV_PAR01 := 1 

   Aadd( _aParAux , { 3 , "Filtrar", MV_PAR01, _aOpcoes, 99, "", .T., .T. , .T. } )

   For _nI := 1 To Len( _aParAux )
       Aadd( _aParRet , _aParAux[_nI][03] )
   Next _nI 
 
   _cFiltro := NIL
   If ! ParamBox( _aParAux , "Filtros" , @_aParRet,,, .T. , , , , , .T. , .T. )
      Break
   EndIf
   
   _cFiltroSQL := ""

   Aadd(aRotina,{"Pesquisar"                                             ,"AxPesqui"       ,0,1})
   Aadd(aRotina,{"Visualizar"                                            ,"AxVisual"       ,0,2})
   Aadd(aRotina,{"Coletas Aceitas"                                       ,"U_AGLT057Y('A')",0,2})
   Aadd(aRotina,{"Coletas Rejeitadas"                                    ,"U_AGLT057Y('R')",0,2})
   Aadd(aRotina,{"Gera Arquivo Texto Coletas Rejeitadas nas Integrações" ,'U_MGLT29OM("F")',0,2})
   Aadd(aRotina,{"Gera Arquivo Texto Coletas Aceitas nas Integrações"    ,'U_MGLT29OM("G")',0,2})
   Aadd(aRotina,{"Legenda"                                               ,"U_AGLT057L() "       ,0,2})

   If MV_PAR01 <> 3
      If MV_PAR01 = 1 
         _cFiltro:=" ZBI_WEBINT = 'E' "
         _cFiltroSQL:=" AND ZBI_WEBINT = 'E' "
         cCadastro := "Coletas Integradas para o Sistema Evomilk"   
      Else
         _cFiltro:=" ZBI_WEBINT <> 'E' "
         _cFiltroSQL:=" AND ZBI_WEBINT <> 'E' "
         cCadastro := "Coletas Integradas para o Sistema Cia do Leite"   
      EndIf
   Else 
      cCadastro := "Coletas Integradas para os Apps Cia do Leite e Evomilk - Sem Filtro"   
   EndIf
   
   Aadd(_aCores,{"ZBI_STATUS == 'A'" ,"BR_AZUL" })
   Aadd(_aCores,{"ZBI_STATUS == 'R'" ,"BR_VERMELHO" })

   DbSelectArea("ZBI")
   ZBI->(DbSetOrder(1)) 
   ZBI->(DbGoTop())

   If MV_PAR01 <> 3
      FWMSGRUN(,{||  mBrowse(6,1,22,75,"ZBI",,,,,,_aCores,,,,,,,,_cFiltro) },'Aguarde Filtrando...',cCadastro)
   Else
      MBrowse(6,1,22,75,"ZBI", , , , , , _aCores)
   EndIf 

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AGLT057V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/02/2022
===============================================================================================================================
Descrição---------: Permite Visualizar os Produtores Rejeitados e Aceitos no Envio de Dados para a Cia do Leite.
===============================================================================================================================
Parametros--------: _cTipoDado == "R" = Dados rejeitados na integração
                                  "A" = Dados aceitos na integração
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
* /  
User Function AGLT057V(_cTipoDado)

Private aRotina := {}
Private cCadastro 
Private _aCampos := {}

Begin Sequence 
   
   If _cTipoDado == "R"
      //(cT1)->(DbSetFilter( { || Left( FIELD_NAME, 4 ) = "BABA" }, 'Left(FIELD_NAME, 4) = "BABA"' ) )
      ZBH->(DbSetFilter( { || ZBH_STATUS == "R" }, 'ZBH_STATUS == "R"' ) )
      cCadastro := "Produtores Rejeitados no Envio de Dados para o Sistema Cia do Leite" 
   Else
      ZBH->(DbSetFilter( { || ZBH_STATUS == "A" }, 'ZBH_STATUS == "A"' ) )
      cCadastro := "Produtores Aceitos no Envio de Dados para o Sistema Cia do Leite"
   EndIf 

   ZBH->(DBGoTop())

   _aCampos := {}
   Aadd(_aCampos,"ZBH_CODPRO")
   Aadd(_aCampos,"ZBH_LOJPRO")
   Aadd(_aCampos,"ZBH_NOMPRO")
   Aadd(_aCampos,"ZBH_MOTIVO")
   Aadd(_aCampos,"ZBH_DTREJ")
   Aadd(_aCampos,"ZBH_HRREJ") 
   Aadd(_aCampos,"ZBH_JSONEN")
   Aadd(_aCampos,"ZBH_DTENV") 
   Aadd(_aCampos,"ZBH_HRENV")
   Aadd(_aCampos,"ZBH_STATUS")

   Aadd(aRotina,{"Pesquisar"                      ,"AxPesqui"   ,0,1,5})
   Aadd(aRotina,{"Visualizar"                     ,"U_AGLT057W('ZBH', _aCampos, cCadastro)" ,0,2,5})

   DbSelectArea("ZBH")
   ZBH->(DbSetOrder(1)) 
   ZBH->(DbGoTop())
      
   MBrowse(6,1,22,75,"ZBH")

   ZBH->(DBClearFilter())

End Sequence 

Return Nil    
*/


/*
===============================================================================================================================
Programa----------: AGLT057Y
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/02/2022
===============================================================================================================================
Descrição---------: Permite Visualizar os dados das Coletas Rejeitadas no Envio de Dados para a Cia do Leite.
===============================================================================================================================
Parametros--------: _cTipoDado == "R" = Dados rejeitados na integração
                                  "A" = Dados aceitos na integração
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT057Y(_cTipoDado)

Private aRotina := {}
Private cCadastro 
Private _aCampos := {}

Begin Sequence 
   
   If _cTipoDado == "R"
      ZBI->(DbSetFilter( { || ZBI_STATUS == "R" }, 'ZBI_STATUS == "R"' ) )
      cCadastro := "Dados das Coletas Rejeitadas no Envio de Dados para o Sistema Cia do Leite"
   Else
      ZBI->(DbSetFilter( { || ZBI_STATUS == "A" }, 'ZBI_STATUS == "A"' ) )
      cCadastro := "Dados das Coletas Aceitas no Envio de Dados para o Sistema Cia do Leite"
   EndIf 

   _aCampos := {}
   Aadd(_aCampos,"ZBI_TICKET")
   Aadd(_aCampos,"ZBI_DTCOLE")
   Aadd(_aCampos,"ZBI_CODPRO")
   Aadd(_aCampos,"ZBI_LOJPRO")
   Aadd(_aCampos,"ZBI_NOMPRO")
   Aadd(_aCampos,"ZBI_MOTIVO") 
   Aadd(_aCampos,"ZBI_DTREJ")
   Aadd(_aCampos,"ZBI_HRREJ") 
   Aadd(_aCampos,"ZBI_JSONEN")
   Aadd(_aCampos,"ZBI_DTENV")
   Aadd(_aCampos,"ZBI_HRENV")
   Aadd(_aCampos,"ZBI_STATUS")

   ZBI->(DBGoTop())

   Aadd(aRotina,{"Pesquisar"                      ,"AxPesqui"   ,0,1,0})
   Aadd(aRotina,{"Visualizar"                     ,"U_AGLT057W('ZBI', _aCampos, cCadastro)" ,0,2,0})

   DbSelectArea("ZBI")
   ZBI->(DbSetOrder(1)) 
   ZBI->(DbGoTop())
      
   MBrowse(6,1,22,75,"ZBI")

   ZBI->(DBClearFilter())

End Sequence 

Return Nil    

/*
=================================================================================================================================
Programa--------: AGLT057W()
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
User Function AGLT057W(_cTab, _aCampos, _cTitulo)
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
Programa----------: AGLT057L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/04/2024
===============================================================================================================================
Descrição---------: Rotina de Exibição da Legenda do MBrowse.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT057L()      
Local _aLegenda := {}

Begin Sequence
   Aadd(_aLegenda,{"BR_AZUL"    ,"Integrados com Sucesso!" })
   Aadd(_aLegenda,{"BR_VERMELHO","Rejeitados!" })
      
   BrwLegenda(cCadastro, "Legenda", _aLegenda)

End Sequence

Return Nil
