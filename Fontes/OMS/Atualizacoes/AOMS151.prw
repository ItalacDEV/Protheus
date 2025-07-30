/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista      - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o                                               Motivo                                           
=============================================================================================================================== 
Jerry          - Julio Paz    - 08/04/25 - 14/04/25 - 48275   - Inclus�o de valida��o de produtos bloqueados por filial, com base no cadastro de produtos bloqueados por filial.
Jerry          - Julio Paz    - 08/04/25 - 02/05/25 - 48275   - Alterar a rotina para for�ar a atualiza��o do Banco de dados imediatamente ap�s o bloquei ou desbloqueio do produto.
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================
Andre    - Igor Melga�o  - 16/07/25 - 18/07/25 -  51403  - Ajustes para adi��o de menudef.
Lucas    - Igor Melga�o  - 16/07/25 - 18/07/25 -  51490  - Ajustes para corre��o de error.log
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch" 
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH" 
//#Include "FwMVCDef.ch"

/*
===============================================================================================================================
Fun��o-------------: AOMS151
Autor--------------: Julio de Paula Paz
Data da Criacao----: 17/02/2025
===============================================================================================================================
Descri��o----------: Rotina de manuten��o do cadastro de produtos bloqueados para vendas, por filial. Chamado 48275.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151()
Local _aArea   := GetArea() As Array
Local _oBrowse As Object
Private _cTitulo  As Character
Private _cArqSB1 As Character
Private _cQrySB1 As Character
Private _cArqFil As Character

Begin Sequence   
   
   Processa( {|| U_AOMS151D() } , 'Aguarde!' , 'Criando tabelas tempor�rias e lendo cadastro de Produtos/Filiais...' )

   _cTitulo := "Cadastro de Produtos x Filial com Bloqueio de Vendas"   

   _oBrowse := FWMBrowse():New()
   _oBrowse:SetAlias("ZBS")
   _oBrowse:SetMenuDef( 'AOMS151' )
   _oBrowse:SetDescription(_cTitulo)
   _oBrowse:AddLegend ( "ZBS->ZBS_SITUAC=='D'","BR_VERDE"   ,"Desbloqueado")
   _oBrowse:AddLegend ( "ZBS->ZBS_SITUAC=='B'","BR_VERMELHO","Bloqueado")


   _oBrowse:Activate()

End Sequence       

If Select(_cArqSB1) > 0
   (_cArqSB1)->(DbCloseArea())
EndIf

If Select(_cArqFil) > 0
   (_cArqFil)->(DbCloseArea())
EndIf

RestArea(_aArea)

Return Nil



/*
===============================================================================================================================
Programa--------: MenuDef
Autor-----------: Igor Melga�o
Data da Criacao-: 16/07/2025
Descri��o-------: Rotina para cria��o do menu na tela inicial
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef() As Array
Local _aRotina := {} As Array

   Aadd(_aRotina,{"Pesquisar"                                ,"AxPesqui"   ,0,1, 0, .F.})
   Aadd(_aRotina,{"Bloquear/Desbloquear Produto Posicionado" ,"U_AOMS151P" ,0,2, 0, nil})   
   Aadd(_aRotina,{"Bloquear/Desbloquear Produto x Filial"    ,"U_AOMS151F" ,0,3, 0, nil})
   Aadd(_aRotina,{"Hist�rico de Bloqueio/Desbloqueio"        ,"U_AOMS151H" ,0,2, 0, nil})

Return( _aRotina )

/*
===============================================================================================================================
Fun��o------------: AOMS151P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/02/2025
===============================================================================================================================
Descri��o---------: Permite bloquear ou desbloquear o Produto x filial posicionado na tela.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151P()
Local _cSituacao := "" As Character
Local _cMsg := "" As Character
Local _cSitAnt := "" As Character
Local _cMsgOk := "" As Character
Local _cMsgCanc := "" As Character

Begin Sequence 

   _cSitAnt := ZBS->ZBS_SITUAC

   If ZBS->ZBS_SITUAC == "B"
      _cSituacao := "D"
      _cMsg     := "Confirma o Desbloqueio do  produto: " + AllTrim(ZBS->ZBS_CODPRO) + ", na filial: " + ZBS->ZBS_CODFIL + " ?"
      _cMsgOk   := "Desbloqueio do  produto: " + AllTrim(ZBS->ZBS_CODPRO) + ", na filial: " + ZBS->ZBS_CODFIL + " realizado com sucesso."
      _cMsgCanc := "Desbloqueio do  produto: " + AllTrim(ZBS->ZBS_CODPRO) + ", na filial: " + ZBS->ZBS_CODFIL + " cancelado pelo usu�rio."
   Else 
      _cSituacao := "B"
      _cMsg      := "Confirma o Bloqueio do  produto: " + AllTrim(ZBS->ZBS_CODPRO) + ", na filial: " + ZBS->ZBS_CODFIL + " ?"
      _cMsgOk    := "Bloqueio do  produto: " + AllTrim(ZBS->ZBS_CODPRO) + ", na filial: " + ZBS->ZBS_CODFIL + " realizado com sucesso."
      _cMsgCanc  := "Bloqueio do  produto: " + AllTrim(ZBS->ZBS_CODPRO) + ", na filial: " + ZBS->ZBS_CODFIL + " cancelado pelo usu�rio."
   EndIf 

   If U_ITMSG(_cMsg,"Aten��o" , , ,2, 2)
      Begin Transaction

         ZBS->(RecLock("ZBS",.F.))
         ZBS->ZBS_SITUAC := _cSituacao
         ZBS->ZBS_DTALT  := Date()
         ZBS->ZBS_HRALT  := Time()
         ZBS->ZBS_USRALT := __cUserID
         ZBS->ZBS_NOMUSR := UsrFullName(__cUserID)    
         ZBS->(MsUnlock())
   
         ZBT->(RecLock("ZBT",.T.))
         ZBT->ZBT_FILIAL	:= ZBS->ZBS_FILIAL //	Filial
         ZBT->ZBT_CODFIL	:= ZBS->ZBS_CODFIL //	Codigo Filial
         ZBT->ZBT_CODPRO	:= ZBS->ZBS_CODPRO //	Cod.Produto
         ZBT->ZBT_DSCPRO	:= ZBS->ZBS_DSCPRO //	Desc.Produto
         ZBT->ZBT_SITANT	:= _cSitAnt        //	Sit.Anterior
         ZBT->ZBT_SITATU	:= _cSituacao      //	Sit.Atual
         ZBT->ZBT_DTALT	   := Date()          //	Dt.Alteracao
         ZBT->ZBT_HRALT	   := Time()          //	Hr.Alteracao
         ZBT->ZBT_USRALT	:= __cUserID       //	Usuario Alt.
         ZBT->ZBT_NOMUSR	:= UsrFullName(__cUserID) //	Nome Usuar.
         ZBT->(MsUnlock()) 

      End Transaction

      ZBS->( DBCommit() ) // For�a a atualiza��o do Banco de dados.

      U_ItMsg(_cMsgOk,"Aten��o",,2) 
   Else 
      U_ItMsg(_cMsgCanc,"Aten��o",,2) 
   EndIf 

End Sequence

Return Nil 

/*
===============================================================================================================================
Fun��o------------: AOMS151D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/02/2025
===============================================================================================================================
Descri��o---------: Cria Tabelas tempor�rias e d� carga de dados de produtos e filiais.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151D()
Local _aStruct := {} As Array
Local _cQry As Character
Local _nTotRegs As Numeric

Begin Sequence 

   //==========================================================================
   // Cria Tabela Tempor�ria de Produtos e gravas os dados.
   //==========================================================================
   Aadd(_aStruct,{"WK_MARCA"  ,"C",2  ,0})
   Aadd(_aStruct,{"B1_COD"    ,"C",15 ,0})  // Cod.Produto
   Aadd(_aStruct,{"B1_DESC"   ,"C",100,0})  // Desc.Produto
   
   _cArqSB1 := GetNextAlias() 
 
   //================================================================================
   // Abre o arquivo TRBCABA criado dentro do banco de dados protheus.
   //================================================================================
   _oTemp := FWTemporaryTable():New( _cArqSB1 ,  _aStruct )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp:AddIndex( "01", {"B1_COD"} )
   _oTemp:AddIndex( "02", {"B1_DESC"} )
   _oTemp:Create()
   
   DBSelectArea(_cArqSB1) 

   _cQrySB1 := GetNextAlias()

   _cQry := " SELECT B1_COD, B1_DESC "
   _cQry += " FROM " + RetSqlName("SB1") + " SB1 "
   _cQry += " WHERE SB1.D_E_L_E_T_ = ' ' AND B1_TIPO = 'PA' "

   MPSysOpenQuery( _cQry , _cQrySB1)
   DBSelectArea(_cQrySB1)
   Count To _nTotRegs

   ProcRegua(_nTotRegs)

   (_cQrySB1)->(DbGoTop())

   Do While ! (_cQrySB1)->(Eof()) 
      IncProc("Lendo dados dos Produtos...")

      (_cArqSB1)->(DbAppend())
      (_cArqSB1)->B1_COD  := (_cQrySB1)->B1_COD
      (_cArqSB1)->B1_DESC := (_cQrySB1)->B1_DESC

      (_cQrySB1)->(DbSkip())
   EndDo 

   If Select(_cQrySB1) > 0
      (_cQrySB1)->(DbCloseArea())
   EndIf

   (_cArqSB1)->(DbGoTop())

   //==========================================================================
   // Cria Tabela Tempor�ria de Filiais e gravas os dados.
   //==========================================================================
   _aStruct := {}
   Aadd(_aStruct,{"WK_MARCA"  ,"C",2  ,0})
   Aadd(_aStruct,{"WK_CODFIL" ,"C",2 ,0})  // Cod.Produto
   Aadd(_aStruct,{"WK_DESCFIL","C",40,0})  // Desc.Produto
   
   _cArqFil := GetNextAlias() 
 
   //================================================================================
   // Abre o arquivo TRBCABA criado dentro do banco de dados protheus.
   //================================================================================
   _oTempFil := FWTemporaryTable():New( _cArqFil ,  _aStruct )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTempFil:AddIndex( "01", {"WK_CODFIL"} )
   _oTempFil:Create()
   
   DBSelectArea(_cArqFil) 

   ZZM->(DbGoTop())
   ProcRegua(0)

   Do While ! ZZM->(Eof()) 
      IncProc("Lendo dados das filiais...")

      (_cArqFil)->(DbAppend())
      (_cArqFil)->WK_CODFIL  := ZZM->ZZM_CODIGO
      (_cArqFil)->WK_DESCFIL := ZZM->ZZM_DESCRI

      ZZM->(DbSkip())
   EndDo 

   (_cArqFil)->(DbGoTop())

End Sequence 

Return Nil 

/*
===============================================================================================================================
Fun��o------------: AOMS151F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/02/2025
===============================================================================================================================
Descri��o---------: Permite bloquear ou desbloquear o Produto x filial em lotes.
                    Selecionando varios produtos e varias filiais.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151F()
Local _aFieldPrd  := {} As Array
Local _aFieldFil  := {} As Array
Local _bBloquear  := {|| Processa( {|| U_AOMS151E("B") } , "Aguarde!" , "Bloqueando os produtos...")} As Block
Local _bDesBloq   := {|| Processa( {|| U_AOMS151E("D") } , "Aguarde!" , "Desbloqueando os produtos...")} As Block
Local _bDesmPrd   := {|| Processa( {|| U_AOMS151A() }    , "Aguarde!" , "Desmarcando Todos os Produtos...")} As Block
Local _bDesmFil   := {|| Processa( {|| U_AOMS151B() }    , "Aguarde!" , "Desmarcando Todas as Filiais...")} As Block
Local _bSair      := {|| _oDlg:End() } As Block
Local _aPesqPrd   := {} As Array

Local aCoors      := FWGetDialogSize( oMainWnd ) As Array

Local _oLayer     := Nil As Object
Local _oTelaPrd   := Nil As Object
Local _oTelaFil   := Nil As Object

Local _cTitAux    := "Rotina de Bloqueio e Desbloqueio de Produtos por Filiais" As Character

Private _oDlg     := Nil As Object
Private _oBrwPrd  := Nil As Object
Private _oBrwFil  := Nil As Object

Begin Sequence 

   //====================================================================================================
   // Monta area onde serao incluidos os paineis
   //====================================================================================================
   Define MsDialog _oDlg Title _cTitAux From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel // aCoors[3]+100, aCoors[4] Pixel

      _oLayer := FWLayer():New()

      _oLayer:Init( _oDlg , .F. , .T. )

      //====================================================================================================
      // Monta os Pain�is
      //====================================================================================================
      _oLayer:AddLine( "UpLine" , 80 , .F. ) 					   // Cria uma "linha" com 90% da tela

      _oLayer:AddCollumn( "Esq" , 050 , .T. , "UpLine" )			// Na "linha" criada utilizar uma coluna com 050% da tamanho dela
      _oLayer:AddCollumn( "Dir" , 050 , .T. , "UpLine" )			// Na "linha" criada utilizar uma coluna com 050% da tamanho dela

      _oTelaPrd := _oLayer:GetColPanel( "Esq" , "UpLine" )		// Cria o objeto superior esquerdo
      _oTelaFil := _oLayer:GetColPanel( "Dir" , "UpLine" )		// Cria o objeto superior direito

      //====================================================================================================
      // Monta Painel Inferior
      //====================================================================================================
      _oLayer:AddLine( "ParLine" , 020 , .F. )						// Cria uma "linha" com 10% da tela
      _oLayer:AddCollumn( "Par" , 100 , .T. , "ParLine" )		// Na "linha" criada utilizar uma coluna com 100% da tamanho dela
      _oPanPrd := _oLayer:GetColPanel( "Par" , "ParLine" )	   // Cria o Objeto Inferior

      @ 10,040  Button "Bloquear"     Size 50,20  Of _oPanPrd Pixel Action EVAL(_bBloquear)
      @ 10,105  Button "Desbloquear"  Size 50,20  Of _oPanPrd Pixel Action EVAL(_bDesBloq)
      @ 10,170  Button "Desmarcar Todos Produtos" Size 80,20  Of _oPanPrd Pixel Action EVAL(_bDesmPrd)
      @ 10,265  Button "Desmarcar Todas Filiais"  Size 80,20  Of _oPanPrd Pixel Action EVAL(_bDesmFil)
      
      @ 10,360  Button "Sair"         Size 50,20  Of _oPanPrd Pixel Action EVAL(_bSair)

      //====================================================================================================
      // Monta Browse Produtos 
      //====================================================================================================
      aAdd( _aFieldPrd , { "Produto"	, {|| (_cArqSB1)->B1_COD }  		 , "C" , "@!" , 0 , Getsx3cache("B1_COD","X3_TAMANHO")  , 0 } )
      aAdd( _aFieldPrd , { "Descricao"	, {|| (_cArqSB1)->B1_DESC }		 , "C" , "@!" , 0 , Getsx3cache("B1_DESC","X3_TAMANHO") , 0 } )

      Aadd(_aPesqPrd,{"Produto"  ,{{"","C",15 ,0,"Produto"  ,"@!"}}}) 
      //Aadd(_aPesqPrd,{"Descricao",{{"","c",100,0,"Descricao","@!"}}})

      _oBrwPrd := FWMarkBrowse():New()		   												// Inicializa o Browse
      _oBrwPrd:SetOwner( _oTelaPrd )
      _oBrwPrd:SetAlias( _cArqSB1 )			   												// Define Alias que ser� a Base do Browse
      _oBrwPrd:SetDescription( "Lista de Produtos Acabados" )	                  // Define o titulo do browse de marcacao
      _oBrwPrd:SetFieldMark( "WK_MARCA" )														// Define o campo que sera utilizado para a marca��o
      _oBrwPrd:SetAllMark( {|| _oBrwPrd:AllMark() } )						            // A��o do Clique no Header da Coluna de Marca��o
      _oBrwPrd:SetFields( _aFieldPrd )													 		// Campos para exibi��o
      //_oBrwPrd:AddButton( "Pesquisar" , {|| Processa( {|| U_AOMS151C() } , "Pesquisa um Produto..." , "Aguarde!" ) } ,, 4 )
      _oBrwPrd:SetSeek(.T., _aPesqPrd)

      _oBrwPrd:DisableConfig()                                                   // Desabilita a utiliza��o das configura��es do Browse
      _oBrwPrd:Activate()																		   // Ativacao da classe

      //====================================================================================================
      // Monta Browse Filiais 
      //====================================================================================================
      aAdd( _aFieldFil , { "C�digo Filial"  , {|| (_cArqFil)->WK_CODFIL }  		 , "C" , "@!" , 0 , 2  , 0 } )
      aAdd( _aFieldFil , { "Nome Filial"	  , {|| (_cArqFil)->WK_DESCFIL}			 , "C" , "@!" , 0 , 30 , 0 } )

      _oBrwFil := FWMarkBrowse():New()		   												// Inicializa o Browse
      _oBrwFil:SetOwner( _oTelaFil )
      _oBrwFil:SetAlias( _cArqFil)			   												// Define Alias que ser� a Base do Browse
      _oBrwFil:SetDescription( "Filiais Italac" )	                              // Define o titulo do browse de marcacao
      _oBrwFil:SetFieldMark( "WK_MARCA" )														// Define o campo que sera utilizado para a marca��o
      _oBrwFil:SetAllMark( {|| _oBrwFil:AllMark() } )						            // A��o do Clique no Header da Coluna de Marca��o
      _oBrwFil:SetFields( _aFieldFil )													 		// Campos para exibi��o
      _oBrwFil:DisableConfig()                                                 // Desabilita a utiliza��o das configura��es do Browse 

      _oBrwFil:Activate()																		   // Ativacao da classe

   Activate MsDialog _oDlg CENTERED	

End Sequence 

Return()

/*
===============================================================================================================================
Fun��o------------: AOMS151A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/02/2025
===============================================================================================================================
Descri��o---------: Realiza a desmarca��o de todos os produtos da tela.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151A()

Begin Sequence 

   If ! U_ITMSG("Confirma a desmarca��o de todos os Produtos?","Aten��o" , , ,2, 2)
      Break 
   EndIf 

   ProcRegua(0)

   (_cArqSB1)->(DbGoTop())

   Do While ! (_cArqSB1)->(Eof()) 
      IncProc("Desmarcando Produtos...")
      
      (_cArqSB1)->WK_MARCA := Space(2)
      
      (_cArqSB1)->(DbSkip())
   EndDo 
   
   (_cArqSB1)->(DbGoTop())

End Sequence 

_oBrwPrd:Refresh()

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS151B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/02/2025
===============================================================================================================================
Descri��o---------: Realiza a desmarca��o de todas as filiais da tela.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151B()

Begin Sequence 

   If ! U_ITMSG("Confirma a desmarca��o de todas as Filiais?","Aten��o" , , ,2, 2)
      Break 
   EndIf 

   ProcRegua(0)

   (_cArqFil)->(DbGoTop())

   Do While ! (_cArqFil)->(Eof()) 
      IncProc("Desmarcando Filiais...")

      (_cArqFil)->WK_MARCA := Space(2)

      (_cArqFil)->(DbSkip())
   EndDo 

   (_cArqFil)->(DbGoTop())

End Sequence 

_oBrwFil:Refresh()

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS151C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/02/2025
===============================================================================================================================
Descri��o---------: Rotina de pesquisa de produtos por C�digo ou Descri��o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151C()
Local _bOk As Block
Local _bCancel As Block
Local _oRadio As Object
Local _nRadio := 1 As Numeric
Local _lRet := .F. As Logical
Local _cCodigo := Space(15) As Character
Local _cDescri := Space(100) As Character
Local _oCodigo As Object
Local _oDescri As Object
Local _nRegAtu := (_cArqSB1)->(Recno()) As Numeric
Local _nRegPesq As Numeric

Private _oDlgPesq As Object

Begin Sequence
   _bOk := {|| _lRet := .T., _oDlgPesq:End()}
   _bCancel := {|| _lRet := .F., _oDlgPesq:End()}
                                                
   _cTitulo := "Pesquisar Produtos"
   
   //================================================================================
   // Monta a tela de Pesquisa de Dados.
   //================================================================================      
   Define MsDialog _oDlgPesq Title _cTitulo From 9,0 To 25,70 Of oMainWnd      
      
      @ 03,08 Say " Ordem de Pesquisa " Pixel of _oDlgPesq                 
      @ 10,04 To 40,80 Pixel of _oDlgPesq       
      @ 15,10 Radio _oRadio Var _nRadio Items "Por C�digo", "Por Descri��o" Size 70,25 Pixel Of _oDlgPesq // On Change U_AOMS084E(_nRadio) 
            
      @ 50,10 Say "Codigo Produto" Pixel of _oDlgPesq                                                     
      @ 50,70 MsGet _oCodigo  Var _cCodigo Picture "@!" F3 "SB1" Size 60,10 Pixel Of _oDlgPesq
                                                   
      @ 70,10 Say "Descri��o Produto" Pixel of _oDlgPesq                                                 
      @ 70,70 MsGet _oDescri  Var _cDescri Picture "@!" Size 200,10 Pixel Of _oDlgPesq  
  
      @ 90,090  Button "Pesquisar" Size 50,20  Of _oDlgPesq Pixel Action EVAL(_bOk)
      @ 90,155  Button "Sair"      Size 50,20  Of _oDlgPesq Pixel Action EVAL(_bCancel)
      
   Activate MsDialog _oDlgPesq CENTERED //On Init EnchoiceBar(_oDlgPesq,_bOk,_bCancel) 

   If _lRet
      If _nRadio == 1
         If Empty(_cCodigo)
            U_ItMsg("C�digo do Produto n�o informado.","Aten��o",,1)
            Break 
         EndIf 
         
         (_cArqSB1)->(DbSetOrder(1))

         If ! (_cArqSB1)->(MsSeek(_cCodigo))
            (_cArqSB1)->(DbGoTo(_nRegAtu))
            Break
         EndIf 
      Else
         If Empty(_cDescri)
            U_ItMsg("Descri��o do Produto n�o informado.","Aten��o",,1)
            Break 
         EndIf 

         (_cArqSB1)->(DbSetOrder(2))
         _oBrwPrd:Refresh()

         If ! (_cArqSB1)->(MsSeek(AllTrim(_cDescri)))
            (_cArqSB1)->(DbGoTo(_nRegAtu))
            Break
         Else 
            _nRegPesq := (_cArqSB1)->(Recno())
            (_cArqSB1)->(DbSetOrder(1))
            _oBrwPrd:Refresh()
            (_cArqSB1)->(DbGoto(_nRegPesq))
         EndIf
      EndIf
   EndIf

End Sequence

_oBrwPrd:Refresh()

Return Nil

/*
===============================================================================================================================
Fun��o------------: AOMS151E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/02/2025
===============================================================================================================================
Descri��o---------: Bloqueia os produtos selecionados para todas as filiais selecionadas.
===============================================================================================================================
Parametros--------: _cBotao = "B" = Bloqueio
                            = "D" = Desbloqueio
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151E(_cBotao As Character)
Local _aFilSelec := {} As Array
Local _aPrdSelec := {} As Array
Local _cMsg := "" As Character
Local _nI := 0 As Numeric
Local _nJ := 0 As Numeric
Local _cSitAnt := "" As Character

Begin Sequence
   If _cBotao == "B"
      _cMsg := "Confirma o bloqueio dos produtos selecionados, em todas as filiais selecionadas?" 
   Else 
      _cMsg := "Confirma o desbloqueio dos produtos selecionados, em todas as filiais selecionadas?" 
   EndIf 

   If ! U_ITMSG(_cMsg,"Aten��o" , , ,2, 2)
      Break 
   EndIf 

   //=================================================================
   // Lendo as filiais selecionadas.
   //=================================================================
   ProcRegua(0)

   (_cArqFil)->(DbGoTop())

   Do While ! (_cArqFil)->(Eof()) 
      IncProc("Lendo as filiais selecionadas...")

      If ! Empty((_cArqFil)->WK_MARCA) 
         Aadd(_aFilSelec, {(_cArqFil)->WK_CODFIL,(_cArqFil)->(Recno())})
         //(_cArqFil)->WK_MARCA := Space(2)
      EndIf 

      (_cArqFil)->(DbSkip())
   EndDo 

   If Len(_aFilSelec) == 0
      If _cBotao == "B"
         _cMsg := "Nenhuma filial foi selecionada. N�o ser� poss�vel bloquear os produtos." 
      Else 
         _cMsg := "Nenhuma filial foi selecionada. N�o ser� poss�vel desbloquear os produtos."
      EndIf
      U_ItMsg(_cMsg,"Aten��o",,1)
      Break 
   EndIf 

   //=================================================================
   // Lendo os produtos selecionados.
   //=================================================================
   (_cArqSB1)->(DbGoTop())

   Do While ! (_cArqSB1)->(Eof()) 
      IncProc("Lendo os produtos selecionados...")
      
      If ! Empty((_cArqSB1)->WK_MARCA) 
         Aadd(_aPrdSelec, {(_cArqSB1)->B1_COD,(_cArqSB1)->B1_DESC,(_cArqSB1)->(Recno())})
         //(_cArqSB1)->WK_MARCA := Space(2)
      EndIf
      
      (_cArqSB1)->(DbSkip())
   EndDo 
   
   If Len(_aPrdSelec) == 0
      If _cBotao == "B"
         _cMsg := "Nenhum produto foi selecionado. N�o ser� poss�vel bloquear os produtos." 
      Else 
         _cMsg := "Nenhum produto foi selecionado. N�o ser� poss�vel desbloquear os produtos."
      EndIf

      U_ItMsg(_cMsg,"Aten��o",,1)
      Break 
   EndIf

   ZBS->(DbSetOrder(1))
   For _nI := 1 To Len(_aFilSelec)
       IncProc("Gravando cadastro de produtos bloqueados...")

       For _nJ := 1 To Len(_aPrdSelec)
           
           //=================================================================
           // Grava o cadastro de produtos bloqueados/desbloqueados.
           //=================================================================  
           If ZBS->(MsSeek(xFilial("ZBS")+_aFilSelec[_nI,1]+_aPrdSelec[_nJ,1]))
              _cSitAnt := ZBS->ZBS_SITUAC
              
              Begin Transaction
                 ZBS->(RecLock("ZBS",.F.))
                 ZBS->ZBS_SITUAC := _cBotao
                 ZBS->ZBS_DTALT  := Date()
                 ZBS->ZBS_HRALT  := Time()
                 ZBS->ZBS_USRALT := __cUserID
                 ZBS->ZBS_NOMUSR := UsrFullName(__cUserID)  
                 ZBS->(MsUnlock())
              End Transaction
           Else
              _cSitAnt := " "
              
              Begin Transaction
                 ZBS->(RecLock("ZBS",.T.))
                 ZBS_FILIAL      := xFilial("ZBS")
                 ZBS->ZBS_CODFIL := _aFilSelec[_nI,1]
                 ZBS->ZBS_CODPRO := _aPrdSelec[_nJ,1]
                 ZBS->ZBS_DSCPRO := _aPrdSelec[_nJ,2]
                 ZBS->ZBS_SITUAC := _cBotao
                 ZBS->ZBS_DTALT  := Date()
                 ZBS->ZBS_HRALT  := Time()
                 ZBS->ZBS_USRALT := __cUserID
                 ZBS->ZBS_NOMUSR := UsrFullName(__cUserID)    
                 ZBS->(MsUnlock())
              End Transaction 
           EndIf 

           ZBS->( DBCommit() ) // For�a a atualiza��o do Banco de dados.

           //=================================================================
           // Grava a tabela de log.
           //=================================================================  
           Begin Transaction
              ZBT->(RecLock("ZBT",.T.))
              ZBT->ZBT_FILIAL	:= ZBS->ZBS_FILIAL //	Filial
              ZBT->ZBT_CODFIL	:= ZBS->ZBS_CODFIL //	Codigo Filial
              ZBT->ZBT_CODPRO	:= ZBS->ZBS_CODPRO //	Cod.Produto
              ZBT->ZBT_DSCPRO	:= ZBS->ZBS_DSCPRO //	Desc.Produto
              ZBT->ZBT_SITANT	:= _cSitAnt        //	Sit.Anterior
              ZBT->ZBT_SITATU	:= _cBotao         //	Sit.Atual
              ZBT->ZBT_DTALT	:= Date()          //	Dt.Alteracao
              ZBT->ZBT_HRALT	:= Time()          //	Hr.Alteracao
              ZBT->ZBT_USRALT	:= __cUserID       //	Usuario Alt.
              ZBT->ZBT_NOMUSR	:= UsrFullName(__cUserID) //	Nome Usuar.
              ZBT->(MsUnlock()) 
           End Transaction
       Next _nJ
   Next _nI 
   
   //=================================================================
   // Remove as marcas de selec��o dos produtos e filiais.
   // Este procedimento na leitura dos dados, interrompe o While.
   //=================================================================  
   For _nI := 1 To Len(_aFilSelec)
       IncProc("Desmarcando filiais seleciondas...")
       (_cArqFil)->(DbGoTo(_aFilSelec[_nI,2]))

       (_cArqFil)->WK_MARCA := Space(2)
   Next 
   _oBrwFil:Refresh()

   For _nI := 1 To Len(_aPrdSelec)
       IncProc("Desmarcando produtos seleciondas...")
       (_cArqSB1)->(DbGoTo(_aPrdSelec[_nI,3]))

       (_cArqSB1)->WK_MARCA := Space(2)
    Next 
    _oBrwPrd:Refresh() 

   If _cBotao == "B"
      _cMsg := "Bloqueio de produtos x filiais concluido." 
   Else 
      _cMsg := "Desbloqueio de produtos x filiais concluido." 
   EndIf
   
   U_ItMsg(_cMsg,"Aten��o",,2)

End Sequence

Return Nil 

/*
===============================================================================================================================
Fun��o------------: AOMS151H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/02/2025
===============================================================================================================================
Descri��o---------: Rotina de Listagem do Hist�rico de bloqueio e desbloqueio de produtos.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS151H() 
Local _aParAux := {} As Array
Local _aParRet := {} As Array
Local _cQry := "" As Character
Local _cQryZBT := Nil As Character
Local _aDados := {} As Array
Local _aCab   := {} As Array
Local _cSitAnt := "" As Character
Local _cSitAtu := "" As Character

Begin Sequence 

   MV_PAR01 := Ctod("  /  /  ")
   MV_PAR02 := Ctod("  /  /  ")
   MV_PAR03 := Space(120)

   Aadd( _aParAux , { 1 , "Data Inicial", MV_PAR01, "@D", ""	, ""	    , ""          ,050      , .F. } )
   Aadd( _aParAux , { 1 , "Data Final"  , MV_PAR02, "@D", ""	, ""	    , ""          ,050      , .F. } )
   Aadd( _aParAux , { 1 , "Produtos"    , MV_PAR03, "@!", ""   , "SB1_05", ""          ,120      , .F. } )
   
   Aadd(_aParRet,"MV_PAR01")
   Aadd(_aParRet,"MV_PAR02")
   Aadd(_aParRet,"MV_PAR03")

   IF !ParamBox( _aParAux , "Listagem do Hist�rico do Bloqueio e Desbloqueio de Produtos" , @_aParRet,,, .T. , , , , , .T. , .T. )
      U_ItMsg( "Opera��o cancelada pelo usu�rio!" , "Aten��o!",,1 )
      Break
   EndIf

   _cQryZBT := GetNextAlias()

   _cQry := " SELECT ZBT_CODFIL,ZBT_CODPRO,ZBT_DSCPRO,ZBT_SITANT,ZBT_SITATU,ZBT_DTALT,ZBT_HRALT,ZBT_USRALT,ZBT_NOMUSR "
   _cQry += " FROM " + RetSqlName("ZBT") + " ZBT "
   _cQry += " WHERE ZBT.D_E_L_E_T_ = ' ' "
   If ! Empty(MV_PAR01)
      _cQry += " AND ZBT_DTALT >= '" + Dtos(MV_PAR01) + "' "
   EndIf 
   
   If ! Empty(MV_PAR02)
      _cQry += " AND ZBT_DTALT <= '" + Dtos(MV_PAR02) + "' "
   EndIf 

   If ! Empty(MV_PAR03)
      _cQry += " AND ZBT_CODPRO IN " + FormatIn(MV_PAR03,";") 
   EndIf 

   _cQry += " ORDER BY ZBT_DTALT, ZBT_CODPRO, ZBT_CODFIL "

   MPSysOpenQuery( _cQry , _cQryZBT)
   DBSelectArea(_cQryZBT)
   Count To _nTotRegs

   If _nTotRegs == 0
      U_ItMsg( "N�o h� dados que satisfa�a as condi��es de filtro para a emiss�o da listagem!" , "Aten��o!",,1 )
      Break
   EndIf 

   ProcRegua(_nTotRegs)

   (_cQryZBT)->(DbGoTop())

   Do While ! (_cQryZBT)->(Eof()) 
      IncProc("Lendo hist�rico de Bloqueios/Desbloqueios...")
      

      _cSitAnt := " "
      If (_cQryZBT)->ZBT_SITANT == "B"
         _cSitAnt := "Bloqueado"
      ElseIf (_cQryZBT)->ZBT_SITANT == "D"
         _cSitAnt := "Desbloqueado"
      EndIf 

      _cSitAtu := " "
      If (_cQryZBT)->ZBT_SITATU == "B"
         _cSitAtu := "Bloqueado"
      ElseIf (_cQryZBT)->ZBT_SITATU == "D"
         _cSitAtu := "Desbloqueado"
      EndIf 

      Aadd(_aDados,{ (_cQryZBT)->ZBT_CODFIL,;      // Filial
                     (_cQryZBT)->ZBT_CODPRO,;      // Produto
                     (_cQryZBT)->ZBT_DSCPRO,;      // Descri��o Produto
                     Stod((_cQryZBT)->ZBT_DTALT),; // Data
                     (_cQryZBT)->ZBT_HRALT,;       // Hora
                     (_cQryZBT)->ZBT_USRALT,;      // C�digo Usu�rio
                     (_cQryZBT)->ZBT_NOMUSR,;      // Nome Usu�rio 
                     _cSitAnt,;                    // Status antes 
                     _cSitAtu})                    // Status Gravado
      
      (_cQryZBT)->(DbSkip())
   EndDo 

   _aCab:={"Filial", "Produto", "Descri��o Produto","Data Altera��o","Hora", "C�digo Usu�rio","Nome Usu�rio", "Status anterior","Status Atual"}
           //                ,_aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk)
   U_ITListBox(_cTitulo,_aCab,_aDados, .T.    , 1    ,        ,          ,        ,         ,     ,        ,          ,       ,        ,          ,           ,         ,       ,         )

End Sequence

If Select(_cQryZBT) > 0
   (_cQryZBT)->(DbCloseArea())
EndIf

Return Nil
