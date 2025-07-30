/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex          | 26/12/2024 | Chamado 48915. Ajustes para a integração WebService Italac x Evomilk
Julio Paz     | 11/02/2025 | Chamado 49770. Desenvolvimento de Rotina para o Usuário Reenviar Produtores, Associações ou 
              |            | Cooperativas informando Código e Loja, CNPJ e Setor.
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
===============================================================================================================================
*/

#include "APWEBSRV.CH"  
#Include 'Protheus.ch'  
#INCLUDE "TBICONN.CH"   

/*
===============================================================================================================================
Programa----------: AGLT056
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/02/2022
Descrição---------: Permite Visualizar os Produtores Rejeitados e Aceitos no Envio de Dados para a Cia do Leite e Evomilk.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT056()
 Local _aCores := {}
 Local _aParAux:= {}
 Local _aParRet:= {}
 Local _aOpcoes:= {}
 Local nI As Numeric
 AADD( _aOpcoes , "1–Integrações Evomilk")
 AADD( _aOpcoes , "2–Integrações Cia do Leite")
 AADD( _aOpcoes , "3–SEM FILTRO") 
 MV_PAR01:=1 

 AADD( _aParAux , { 3 , "Filtrar", MV_PAR01, _aOpcoes, 99, "", .T., .T. , .T. } )

 For nI := 1 To Len( _aParAux )
     aAdd( _aParRet , _aParAux[nI][03] )
 Next nI
 
 _cFiltro:=NIL
 IF !ParamBox( _aParAux , "FILTROS" , @_aParRet,,, .T. , , , , , .T. , .T. )
    RETURN .F.///////////////////// RETORNA //////////////////////////
 EndIf
 _cFiltroSQL:=""//USADO NO U_MGLT32OM() E U_MGLT29OM()
 cCadastro := "Produtores Integrados para os Sistemas Cia do Leite e/ou Evomilk"   

 Private aRotina := {}
 Aadd(aRotina,{"Pesquisar"                                                    ,"AxPesqui"       ,0,1})
 Aadd(aRotina,{"Visualizar"                                                   ,"AxVisual"       ,0,2})
 Aadd(aRotina,{"Produtores Aceitos"                                           ,"U_AGLT056V('A')",0,2})
 Aadd(aRotina,{"Produtores Rejeitados"                                        ,"U_AGLT056V('R')",0,2})
 Aadd(aRotina,{"Gera Arquivo Texto Produtores Ativos/Inativos"                ,'U_MGLT29OM("A")',0,2})
 Aadd(aRotina,{"Gera Arquivo Texto Produtores Usuarios Tanques Col."          ,'U_MGLT29OM("B")',0,2})
 Aadd(aRotina,{"Gera Arquivo Texto Produtores Mais de Uma Propriedade"        ,'U_MGLT29OM("C")',0,2})
 
 IF MV_PAR01 <> 3
    IF MV_PAR01 = 1 
       _cFiltro:=" ZBH_WEBINT = 'E' "
       _cFiltroSQL:=" AND ZBH_WEBINT = 'E' "//USADO NO U_MGLT32OM() E U_MGLT29OM()
       cCadastro := "Produtores Integrados para o Sistema Evomilk"   
       Aadd(aRotina,{"Gera Arquivo Texto Produtores Rejeitados nas Integrações"     ,'U_MGLT32OM("D")',0,2})
       Aadd(aRotina,{"Gera Arquivo Texto Produtores Aceitos nas Integrações"        ,'U_MGLT32OM("E")',0,2})
    ELSE
       _cFiltro:=" ZBH_WEBINT <> 'E' "
       _cFiltroSQL:=" AND ZBH_WEBINT <> 'E' "//USADO NO U_MGLT32OM() E U_MGLT29OM()
       cCadastro := "Produtores Integrados para o Sistema Cia do Leite"   
       Aadd(aRotina,{"Gera Arquivo Texto Produtores Rejeitados nas Integrações"     ,'U_MGLT29OM("D")',0,2})
       Aadd(aRotina,{"Gera Arquivo Texto Produtores Aceitos nas Integrações"        ,'U_MGLT29OM("E")',0,2})
       Aadd(aRotina,{"Gera Arquivo Texto Associações/Cooperativas Ativas e Inativas",'U_MGLT29OM("H")',0,2})

       Aadd(aRotina,{"Reenviar Produtor Comum",'U_AGLT056A("PRD_COMUM")',0,2})
       Aadd(aRotina,{"Reenviar Associação/Cooperativa por Código/Loja",'U_AGLT056A("ASS_CODIGO_LOJA")',0,2})
       Aadd(aRotina,{"Reenviar Associação/Cooperativa por CNPJ",'U_AGLT056A("ASS_CNPJ")',0,2})
       Aadd(aRotina,{"Reenviar Produtor por Setor",'U_AGLT056A("SETOR")',0,2})
    EndIf
 Else
    Aadd(aRotina,{"Gera Arquivo Texto Produtores Rejeitados nas Integrações"     ,'U_MGLT29OM("D")',0,2})
    Aadd(aRotina,{"Gera Arquivo Texto Produtores Aceitos nas Integrações"        ,'U_MGLT29OM("E")',0,2})
    Aadd(aRotina,{"Gera Arquivo Texto Associações/Cooperativas Ativas e Inativas",'U_MGLT29OM("H")',0,2})
 EndIf 
 
 Aadd(aRotina,{"Legenda"                                                      ,"U_AGLT056L()"       ,0,2}) 
 
 Aadd(_aCores,{"ZBH_STATUS == 'A'" ,"BR_VERDE"   })
 Aadd(_aCores,{"ZBH_STATUS == 'R'" ,"BR_VERMELHO"}) 
 
 DbSelectArea("ZBH")
 ZBH->(DbSetOrder(1))  

 IF MV_PAR01 <> 3
    FWMSGRUN(,{||  mBrowse(,,,,"ZBH",,,,,,_aCores,,,,,,,,_cFiltro) },'Aguarde Filtrando...',cCadastro)
 Else
    mBrowse(,,,,"ZBH",,,,,,_aCores) 
 Endif

Return Nil

/*
===============================================================================================================================
Programa----------: AGLT056V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/02/2022
Descrição---------: Permite Visualizar os Produtores Rejeitados e Aceitos no Envio de Dados para a Cia do Leite.
Parametros--------: _cTipoDado == "R" = Dados rejeitados na integração
                                  "A" = Dados aceitos na integração
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT056V(_cTipoDado)

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

   Aadd(aRotina,{"Pesquisar"                      ,"AxPesqui"   ,0,1,0})
   Aadd(aRotina,{"Visualizar"                     ,"U_AGLT056W('ZBH', _aCampos, cCadastro)" ,0,2,0})

   DbSelectArea("ZBH")
   ZBH->(DbSetOrder(1)) 
   ZBH->(DbGoTop())
      
   MBrowse(6,1,22,75,"ZBH")

   ZBH->(DBClearFilter())

End Sequence 

Return Nil    

/*
=================================================================================================================================
Programa--------: AGLT056W()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 18/04/2024
Descrição-------: Tela de Visualização dos dados de Integração Webservice Protheus x App Cia do Leite.
Parametros------: _cTab    = Alias da Tabela para Visualização dos Dados.
                  _aCampos = Campos que serão visualizados.
                  _cTitulo = Titulo da tela para a rotina que chamou a tela de visualização de dados.
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AGLT056W(_cTab, _aCampos, _cTitulo)
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
Programa----------: AGLT056L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/04/2024
Descrição---------: Rotina de Exibição da Legenda do MBrowse.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT056L()     
Local _aLegenda := {}

Begin Sequence
   Aadd(_aLegenda,{"BR_VERDE"    ,"Integrados com Sucesso!" })
   Aadd(_aLegenda,{"BR_VERMELHO","Rejeitados!" })
      
   BrwLegenda(cCadastro, "Legenda", _aLegenda)

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AGLT056A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/02/2025
Descrição---------: Rotina de Reenvio de Produtores e Associação/Cooperativas para o App Cia do Leite.
Parametros--------: _cOpcao = Opção de Reenvio.
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGLT056A(_cOpcao)
Local _oDlgP	  := Nil 
Local _nOpca	  := 0
Local _cTitulo   := ""
Local _cCodigo   := ""
Local _cLoja     := ""
Local _cCnpj     := ""
Local _cSetor    := ""
Local _cPergunta := ""

Private _cNome  := ""
Private _lHaDadosP := .F. // Indica se há dados dos produtores para Integração.
Private _cUnidVinc := SM0->M0_CGC // Unidade na qual os produtores e coletas estão vinculados.
Private _lJaTemAss := .F.  

Begin Sequence 

   If _cOpcao == "PRD_COMUM"
      _cTitulo   := "Reenviar Produtor Comum"
   ElseIf _cOpcao == "ASS_CODIGO_LOJA"
      _cTitulo   := "Reenviar Associação/Cooperativa por Código e Loja"
   ElseIf _cOpcao == "ASS_CNPJ"
      _cTitulo   := "Reenviar Associação/Cooperativa por CNPJ" 
   ElseIf _cOpcao == "SETOR" 
      _cTitulo   := "Reenviar Produtor Comum por Setor"
   EndIf 

   _cCodigo   := Space(6)
   _cLoja     := Space(4)
   _cCnpj     := Space(14)
   _cSetor    := Space(6)

   DEFINE MSDIALOG _oDlgP TITLE _cTitulo FROM 00,00 TO 10,50
      
      If _cOpcao == "PRD_COMUM"
         
         @ 15,10 Say "Código Produtor: " Of _oDlgP Pixel 
         @ 12,70 MsGet _cCodigo Size 30, 12 F3 "SA2" Picture "@!" Of _oDlgP Pixel
      
         @ 30,10 Say "Loja Produtor: " Of _oDlgP Pixel
         @ 27,70 MsGet _cLoja   Size 20, 12 Of _oDlgP Pixel

      ElseIf _cOpcao == "ASS_CODIGO_LOJA"

             @ 15,10 Say "Código Produtor: "  Of _oDlgP Pixel 
             @ 12,70 MsGet _cCodigo Size 30, 12 F3 "SA2" Picture "@!" Of _oDlgP Pixel
      
             @ 30,10 Say "Loja Produtor: " Of _oDlgP Pixel
             @ 27,70 MsGet _cLoja   Size 20, 12 Of _oDlgP Pixel
      
      ElseIf _cOpcao == "ASS_CNPJ"

             @ 15,10 Say "CNPJ Associação/Cooperativa: " Of _oDlgP Pixel 
             @ 12,90 MsGet _cCnpj Size 70, 12 F3 "SAX"   Of _oDlgP Pixel
      
      ElseIf _cOpcao == "SETOR" 

             @ 15,10 Say "Setor Produtor: " Of _oDlgP Pixel 
             @ 12,70 MsGet _cSetor Size 30, 12 F3 "ZL2_01" Of _oDlgP Pixel
      
      EndIf 
	
	   
      DEFINE SBUTTON FROM 55, 050 TYPE 1 ENABLE ACTION (If(U_AGLT056B(_cOpcao,_cCodigo,_cLoja,_cCnpj,_cSetor),( _nOpca := 1 , _oDlgP:End()),"") ) OF _oDlgP
	   DEFINE SBUTTON FROM 55, 090 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlgP:End() ) OF _oDlgP
   ACTIVATE MSDIALOG _oDlgP CENTERED

   If _nOpca == 1
      If _cOpcao == "PRD_COMUM"
         _cPergunta := "Confirma o Reenvio do Produtor: " + _cCodigo + "-" + _cLoja + "-" + _cNome + ", para o App Cia do Leite?"
      ElseIf _cOpcao == "ASS_CODIGO_LOJA"
         _cPergunta := "Confirma o Reenvio da Associação/Cooperativa (Associado/Cooperado): " + _cCodigo + "-" + _cLoja + "-" + _cNome + ", para o App Cia do Leite?"
      ElseIf _cOpcao == "ASS_CNPJ"
         _cPergunta := "Confirma o Reenvio da Associação/Cooperativa e dos Associados/Cooperados que possuem o CNPJ: " + Transform(_cCnpj,"@R! NN.NNN.NNN/NNNN-99") + "-" + _cNome + ", para o App Cia do Leite?"
      ElseIf _cOpcao == "SETOR" 
         _cPergunta := "Confirma o Reenvio de todos os produtores do Setor: " + _cSetor + "-" + _cNome + ", para o App Cia do Leite?"
      EndIf 

      If U_ITMSG(_cPergunta,"Atenção" , , ,2, 2)
         U_AGLT056C(_cOpcao,_cCodigo,_cLoja,_cCnpj,_cSetor)
      EndIf 

   EndIf 

End Sequence

Return Nil 

/*
===============================================================================================================================
Programa----------: AGLT056B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 06/02/2025
Descrição---------: Validar a digitação dos dados de reenvio de Produtor e Associação/Cooperativa.
Parametros--------: _cOpcao    = Opção de Reenvio.
                    _cCodProd  = Codigo do Produtor
                    _cLojaProd = Loja do Produtor
                    _cCnpjProd = Cnpj do Produtor
                    _cSetor    = Setor do Produtor
Retorno-----------: _lRet      = .T. = Sucesso na validação
                               = .F. = Problemas na validação
===============================================================================================================================
*/  
User Function AGLT056B(_cOpcao,_cCodProd,_cLojaProd,_cCnpjProd,_cSetor)
Local _lRet := .T.
Local _cQry := ""
Local _cAlias 
Local _cFilial 
Local _cNomeFil

Begin Sequence 

   If _cOpcao == "PRD_COMUM" .Or. _cOpcao == "ASS_CODIGO_LOJA"
      If Empty(_cCodProd) .Or. Empty(_cLojaProd)
         U_ItMsg("O preenchimento do código e da loja do produtor são obrigatórios.","Atenção",,2)
         _lRet := .F.
         Break
      EndIf 

      SA2->(DbSetOrder(1))
      If ! SA2->(MsSeek(xFilial("SA2")+_cCodProd+_cLojaProd))
         U_ItMsg("O código e loja do produtor informado, não existe no cadastro de produtores.","Atenção",,2)
         _lRet := .F.
         Break
      EndIf 

      If _cOpcao == "PRD_COMUM" .And. SA2->A2_L_NFPRO = 'S' 
          U_ItMsg("O produtor informado não é um produtor comum. Está cadastrado como uma Associação/Cooperativa ou Pessoa Jurídica.","Atenção",,2)
         _lRet := .F.
         Break
      EndIf 

      If _cOpcao == "ASS_CODIGO_LOJA" .And. SA2->A2_L_NFPRO <> 'S' 
          U_ItMsg("O produtor informado não é ou não faz parte de uma Associação/Cooperativa.","Atenção",,2)
         _lRet := .F.
         Break
      EndIf 

      ZL3->(DbSetOrder(1)) //ZL3_FILIAL+ZL3_COD+ZL3_TIPO
      If ! ZL3->(MsSeek(xFilial("ZL3")+SA2->A2_L_LI_RO))
         _cQry := " SELECT ZL3_FILIAL FROM " + RetSqlName("ZL3") + " ZL3 " 
         _cQry += " WHERE ZL3.D_E_L_E_T_ = ' ' AND ZL3_COD = '" + SA2->A2_L_LI_RO + "' "

         _cAlias := GetNextAlias()
         
         MPSysOpenQuery( _cQry , _cAlias)
         
         _cFilial := (_cAlias)->ZL3_FILIAL
         
         (_cAlias)->(DbCloseArea())

         _aFilial  := FwLoadSM0()

         _nI := Ascan(_aFilial,{|x| x[2] = _cFilial})
         
         If _nI > 0
            _cNomeFil := AllTrim(_aFilial[_nI,7])
         Else
            _cNomeFil := ""
         EndIf 

         U_ItMsg("O produtor informado não está vinculado a esta filial.","Atenção","Para reenviá-lo para o App Cia do Leite faça login na filial: " + _cNomeFil ,2)
         _lRet := .F.
         Break 
      EndIf 
      
      _cNome  := AllTrim(SA2->A2_NOME)

   EndIf 

   If _cOpcao == "ASS_CNPJ"
      If Empty(_cCnpjProd) 
         U_ItMsg("O preenchimento do CNPJ da Associação/Cooperativa é obrigatório.","Atenção",,2)
         _lRet := .F.
         Break
      EndIf 

      SA2->(DbSetOrder(3))
      If ! SA2->(MsSeek(xFilial("SA2")+_cCnpjProd))
         U_ItMsg("O CNPJ da Associação/Cooperativa informado, não existe no cadastro de produtores.","Atenção",,2)
         _lRet := .F.
         Break
      EndIf 

      If Empty(SA2->A2_L_LI_RO)
         Do While ! SA2->(Eof()) .And. SA2->A2_FILIAL + SA2->A2_CGC == xFilial("SA2")+_cCnpjProd
            If SA2->A2_L_ATIVO == "S" .And. ! Empty(SA2->A2_L_LI_RO)
               Exit 
            EndIf 
            SA2->(DbSkip())
         EndDo 
      EndIf 

      ZL3->(DbSetOrder(1)) //ZL3_FILIAL+ZL3_COD+ZL3_TIPO
      If ! ZL3->(MsSeek(xFilial("ZL3")+SA2->A2_L_LI_RO))
         _cQry := " SELECT ZL3_FILIAL FROM " + RetSqlName("ZL3") + " ZL3 " 
         _cQry += " WHERE ZL3.D_E_L_E_T_ = ' ' AND ZL3_COD = '" + SA2->A2_L_LI_RO + "' "

         _cAlias := GetNextAlias()
         
         MPSysOpenQuery( _cQry , _cAlias)
         
         _cFilial := (_cAlias)->ZL3_FILIAL
         
         (_cAlias)->(DbCloseArea())

         _aFilial  := FwLoadSM0()

         _nI := Ascan(_aFilial,{|x| x[2] = _cFilial})
         
         If _nI > 0
            _cNomeFil := AllTrim(_aFilial[_nI,7])
         Else
            _cNomeFil := ""
         EndIf 

         U_ItMsg("A Associação/Cooperativa informada não está vinculado a esta filial.","Atenção","Para reenviá-la para o App Cia do Leite faça login na filial: " + _cNomeFil ,2)
         _lRet := .F.
         Break 
      EndIf 
      
      _cNome  := AllTrim(SA2->A2_NOME )

   EndIf 

   If _cOpcao == "SETOR"
      If Empty(_cSetor) 
         U_ItMsg("O preenchimento do Setor é obrigatório.","Atenção",,2)
         _lRet := .F.
         Break
      EndIf 
  
      ZL2->(DbSetOrder(1)) //ZL2_FILIAL+ZL2_COD 
      
      If ! ZL2->(MsSeek(xFilial("ZL2")+_cSetor))
         _cQry := " SELECT ZL2_FILIAL FROM " + RetSqlName("ZL2") + " ZL2 " 
         _cQry += " WHERE ZL2.D_E_L_E_T_ = ' ' AND ZL2_COD = '" + _cSetor + "' "

         _cAlias := GetNextAlias()
         
         MPSysOpenQuery( _cQry , _cAlias)
         
         If ! (_cAlias)->(Eof()) .And. ! (_cAlias)->(Bof()) 
            _cFilial := (_cAlias)->ZL2_FILIAL
            (_cAlias)->(DbCloseArea())
         Else 
            (_cAlias)->(DbCloseArea())
            U_ItMsg("O Setor informado não existe no Cadastro de Setores.","Atenção",,2)
            _lRet := .F.
            Break
         EndIf 

         _aFilial  := FwLoadSM0()

         _nI := Ascan(_aFilial,{|x| x[2] = _cFilial})
         
         If _nI > 0
            _cNomeFil := AllTrim(_aFilial[_nI,7])
         Else
            _cNomeFil := ""
         EndIf 

         U_ItMsg("O Setor Informado não está vinculado a esta filial.","Atenção","Para reenviá-lo para o App Cia do Leite faça login na filial: " + _cNomeFil ,2)
         _lRet := .F.
         Break 
      EndIf 

      _cNome := AllTrim(ZL2->ZL2_DESCRI)

   EndIf 

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AGLT056C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 06/02/2025
Descrição---------: Reenvia os Produtores e Associações/Cooperativas conforme a opção de reenvio.
Parametros--------: _cOpcao    = Opção de Reenvio.
                    _cCodProd  = Codigo do Produtor
                    _cLojaProd = Loja do Produtor
                    _cCnpjProd = Cnpj do Produtor
                    _cSetor    = Setor do Produtor
Retorno-----------: Nenhum.
===============================================================================================================================
*/  
User Function AGLT056C(_cOpcao,_cCodProd,_cLojaProd,_cCnpjProd,_cSetor)

Begin Sequence 
   
   If _cOpcao == "PRD_COMUM"
      //==========================================================
      // "Reenviar Produtor Comum"
      //==========================================================
      ProcRegua(0)

      _lHaDadosP := .F.

      Processa( {|| U_MGLT029P(.F.,"PRD_COMUM",_cCodProd,_cLojaProd,_cCnpjProd,_cSetor) } , 'Aguarde!' , 'Lendo dados dos Produtores...' )
      
      If _lHaDadosP  
         Processa( {|| U_MGLT029Q("M","PRD_COMUM",_cCodProd,_cLojaProd,_cCnpjProd,_cSetor) } , 'Aguarde!' , 'Enviando dados dos Produtores...' ) // Envia os dados dos Produtores via Integração WebService.
      EndIf

      U_ItMsg("Envio dos dados dos Produtores para o sistema Companhia do Leite concluído.","Atenção",,2)

   ElseIf _cOpcao == "ASS_CODIGO_LOJA"
      //==========================================================
      // "Reenviar Associação/Cooperativa por Código e Loja"
      //==========================================================
      ProcRegua(0)
         
      _lHaDadosP := .F.

      Processa( {|| U_MGLT029P(.F.,"ASS_CODIGO_LOJA",_cCodProd,_cLojaProd,_cCnpjProd,_cSetor) } , 'Aguarde!' , 'Lendo dados dos Produtores...' )
      
      If _lHaDadosP  
         Processa( {|| U_MGLT029K("M","REENVASS")} , 'Aguarde!' , 'Reenviando dados das Associações / Cooperativas...' ) 
      EndIf

      U_ItMsg("Reenvio dos dados das Associações / Cooperativas para o sistema Companhia do Leite Concluido.","Atenção",,2)

   ElseIf _cOpcao == "ASS_CNPJ"
      //==========================================================
      // "Reenviar Associação/Cooperativa por CNPJ" 
      //==========================================================
      ProcRegua(0)

      _lHaDadosP := .F.

      Processa( {|| U_MGLT029P(.F.,"ASS_CNPJ",_cCodProd,_cLojaProd,_cCnpjProd,_cSetor) } , 'Aguarde!' , 'Lendo dados dos Produtores...' )

      If _lHaDadosP  
         Processa( {|| U_MGLT029K("M","REENVASS")} , 'Aguarde!' , 'Reenviando dados das Associações / Cooperativas...' ) 
      EndIf

      U_ItMsg("Reenvio dos dados das Associações / Cooperativas para o sistema Companhia do Leite Concluido.","Atenção",,2)


   ElseIf _cOpcao == "SETOR" 
      //==========================================================
      // "Reenviar Produtor Comum por Setor"
      //==========================================================
      ProcRegua(0)

      _lHaDadosP := .F.

      Processa( {|| U_MGLT029P(.F.,"SETOR",_cCodProd,_cLojaProd,_cCnpjProd,_cSetor) } , 'Aguarde!' , 'Lendo dados dos Produtores...' )
      
      If _lHaDadosP  
         Processa( {|| U_MGLT029Q("M","SETOR",_cCodProd,_cLojaProd,_cCnpjProd,_cSetor) } , 'Aguarde!' , 'Enviando dados dos Produtores...' ) // Envia os dados dos Produtores via Integração WebService.
      EndIf

      U_ItMsg("Reenvio dos dados dos Produtores por Setor para o sistema Companhia do Leite concluído.","Atenção",,2)

   EndIf 
End Sequence 

Return Nil 
