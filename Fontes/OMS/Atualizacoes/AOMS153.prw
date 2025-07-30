/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------

===============================================================================================================================
*/

#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"


/*
===============================================================================================================================
Programa----------: AOMS153
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2021
===============================================================================================================================
Descri��o---------: Cadastro de Premissa. Chamado: 50568 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AOMS153()
Local _oBrowse := Nil
Private __cCod := "" As Character
Private __cPeriod := "" As Character
_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z38")
_oBrowse:SetMenuDef( 'AOMS153' )
_oBrowse:SetDescription("Premissa")
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de defini��o autom�tica do menu via MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef()
Local _aRotina	:= {}

ADD OPTION _aRotina Title 'Visualizar'	Action 'VIEWDEF.AOMS153'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'   	Action 'VIEWDEF.AOMS153'	OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'   	Action 'VIEWDEF.AOMS153'	OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'		Action 'VIEWDEF.AOMS153'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Copiar'     Action 'VIEWDEF.AOMS153'   OPERATION 9 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/
Static Function ModelDef()
Local _oStruZ38 := FWFormStruct(1,"Z38")
Local _oStruZ39 := FWFormStruct(1,"Z39",{ |x| ALLTRIM(x) $ 'Z39_COD, Z39_DESC, Z39_PERIOD,Z39_PRODUT,Z39_DESCP,Z39_TIPO, Z39_UM, Z39_FATOR, Z39_TPCONV' } )
Local _oStruZ40 := FWFormStruct(1,"Z40",{ |x| ALLTRIM(x) $ 'Z40_COD, Z40_DESC, Z40_PERIOD,Z40_COORD,Z40_NOME,Z40_ALVO, Z40_ATING' } )
Local _oModel
Local _aAuxFWDGat := {}
Local _bPosValidacao := {|| U_AOMS153H(_oModel) }
Local _bCommit := {|| U_AOMS153K(_oModel) }
Local _aZ39Rel := {}
Local _aZ40Rel := {}

_oStruZ38:AddField( ;
        AllTrim('Bloqueado?') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'Z38_MSBLQL' , ;            // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        1 , ;                       // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || Iif(INCLUI, "2",Z38->Z38_MSBLQL) } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        .T. , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virt

// Monta a estrutura dos gatilhos
_aAuxFWDGat := FwStruTrigger('Z38_COD','Z38_DESC','U_AOMS153G(M->Z38_FILIAL,M->Z38_COD)',.F.)
_oStruZ38:AddTrigger(_aAuxFWDGat[01],_aAuxFWDGat[02],_aAuxFWDGat[03],_aAuxFWDGat[04])

_oModel := MPFormModel():New('AOMS153M' ,/*bPreValidacao*/ , _bPosValidacao /*_bPosValidacao*/ , _bCommit /*bCommit*/ , /*bCancel*/)

_oModel:AddFields("Z38MASTER",/*cOwner*/,_oStruZ38)

aAdd(_aZ39Rel, {'Z39_FILIAL', 'Z38MASTER.Z38_FILIAL'} )
aAdd(_aZ39Rel, {'Z39_COD'   , 'Z38MASTER.Z38_COD'})
aAdd(_aZ39Rel, {'Z39_PERIOD', 'Z38MASTER.Z38_PERIOD'})

_oModel:AddGrid("Z39DETAIL" , "Z38MASTER" , _oStruZ39 , )
_oModel:SetRelation( "Z39DETAIL" , _aZ39Rel , Z39->( IndexKey( 1 ) ) )

aAdd(_aZ40Rel, {'Z40_FILIAL', 'Z38MASTER.Z38_FILIAL'} )
aAdd(_aZ40Rel, {'Z40_COD'   , 'Z38MASTER.Z38_COD'})
aAdd(_aZ40Rel, {'Z40_PERIOD', 'Z38MASTER.Z38_PERIOD'})

_oModel:AddGrid("Z40DETAIL" , "Z38MASTER" , _oStruZ40 , )
_oModel:SetRelation( "Z40DETAIL" , _aZ40Rel , Z40->( IndexKey( 1 ) ) )


_oModel:GetModel('Z40DETAIL'):SetNoInsertLine( .T. )
//_oModel:GetModel('SE1DETAIL'):SetNoDeleteLine( .T. )
_oModel:GetModel('Z40DETAIL'):SetNoUpdateLine( .T. )
_oModel:GetModel('Z40DETAIL'):SetOptional(.T.)
//_oModel:GetModel('Z40DETAIL'):SetOnlyQuery(.T.)
//_oModel:GetModel('Z40DETAIL'):SetOnlyView(.T.) 

_oModel:GetModel('Z39DETAIL'):SetNoInsertLine( .T. )
//_oModel:GetModel('Z39DETAIL'):SetNoDeleteLine( .T. )
_oModel:GetModel('Z39DETAIL'):SetNoUpdateLine( .T. )
_oModel:GetModel('Z39DETAIL'):SetOptional(.T.)
//_oModel:GetModel('Z39DETAIL'):SetOnlyQuery(.T.)
//_oModel:GetModel('Z39DETAIL'):SetOnlyView(.T.) 

_oModel:SetPrimaryKey( {'Z38_FILIAL','Z38_COD','Z38_PERIOD' } )
_oModel:SetDescription("Premissas")

_oModel:SetVldActivate( { |_oModel| .T. } )

Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oStruZ38 := FWFormStruct(2,"Z38")
Local _oStruZ39 := FWFormStruct(2,"Z39",{ |x| ALLTRIM(x) $ 'Z39_PRODUT,Z39_DESCP,Z39_TIPO, Z39_UM, Z39_FATOR, Z39_TPCONV' } )
Local _oStruZ40 := FWFormStruct(2,"Z40",{ |x| ALLTRIM(x) $ 'Z40_COORD,Z40_NOME,Z40_ALVO, Z40_ATING' } )
Local _oModel := FWLoadModel("AOMS153")
Local _oView := Nil

    _oStruZ38:AddField( ;                       // Ord. Tipo Desc.
        'Z38_MSBLQL'                    , ;     // [01] C   Nome do Campo
        "99"                            , ;     // [02] C   Ordem
        AllTrim( 'Bloqueado?' )         , ;     // [03] C   Titulo do campo
        AllTrim( 'Bloqueado?' )         , ;     // [04] C   Descricao do campo
        { 'Legenda' }                   , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        ''                              , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                              , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo � alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        {"1=Sim","2=Nao"}               , ;     // [13] A   Lista de valores permitido do campo (Combo)
        2                               , ;     // [14] N   Tamanho maximo da maior op��o do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .F.                             , ;     // [16] L   Indica se o campo � virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 
 
 
_oStruZ39:RemoveField('Z39_DESC')


_oView := FWFormView():New()
_oView:SetModel(_oModel)

_oView:AddField( "VIEW_MASTER", _oStruZ38	, "Z38MASTER" )
_oView:AddGrid(  "VIEW_DETAIL1", _oStruZ39	, "Z39DETAIL" )
_oView:AddGrid(  "VIEW_DETAIL2", _oStruZ40	, "Z40DETAIL" )

_oView:CreateHorizontalBox( 'BOX0101' , 30 )
_oView:CreateHorizontalBox( 'BOX0102' , 35 )
_oView:CreateHorizontalBox( 'BOX0103' , 35 )

_oView:SetOwnerView( "VIEW_MASTER"  , "BOX0101" )
_oView:SetOwnerView( "VIEW_DETAIL1" , "BOX0102" )
_oView:SetOwnerView( "VIEW_DETAIL2" , "BOX0103" )

_oView:EnableTitleView('VIEW_DETAIL1', 'Produtos' )  
_oView:EnableTitleView('VIEW_DETAIL2', 'Coordenador' )  
     
//For�a o fechamento da janela na confirma��o
_oView:SetCloseOnOk({||.T.})

//_oView:SetOwnerView("VIEW_Z39","TELA")

Return _oView

/*
===============================================================================================================================
Programa----------: AOMS153H
Autor-------------: Igor Melga�o
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Pos Valida��o
===============================================================================================================================
Parametros--------: _oModel
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/ 
User Function AOMS153H(_oModel)
   Local lRet := .T. As Logical
   Local _cFilial := xFilial("Z38")
   Local _cCod := _oModel:GetValue("Z38MASTER","Z38_COD") 
   Local _cPeriodo := _oModel:GetValue("Z38MASTER","Z38_PERIOD") 
   Local nOper := _oModel:GetOperation()
   
   If nOper == 3 //Inclusao
      DbSelectArea("Z38")
      DbSetOrder(1)
      If DbSeek(_cFilial+_cCod+_cPeriodo)
         lRet := .F.
         U_ITMSG("J� existe um registro nesse cadastro com a mesma chave digitada Codigo: "+_cCod+" Periodo: "+_cPeriodo,"Aten��o","Prencha pelo menos um desses campos com valores difrentes dos citados.",3 , , , .T.)
      Else
         lRet := .T.
      EndIf
   ElseIf nOper == 5 //Exclus�o
      lRet := .T.
      DbSelectArea("Z39")
      DbSetOrder(1)
      If DbSeek(_cFilial+_cCod+_cPeriodo)
         lRet := .F.
         U_ITMSG("Existem registros relacionados a esse codigo: "+_cCod+" no cadastro de Premissa Vs Produtos.","Aten��o","Antes da exclus�o dessa Premissa exclua os registros relacionados no Cadastro de Premissa Vs Produtos.",3 , , , .T.)
      EndIf

      If lRet
         DbSelectArea("Z40")
         DbSetOrder(1)
         If DbSeek(_cFilial+_cCod+_cPeriodo)
            lRet := .F.
            U_ITMSG("Existem registros relacionados a esse codigo: "+_cCod+" no cadastro de Premissa Vs Coordenador.","Aten��o","Antes da exclus�o dessa Premissa exclua os registros relacionados no Cadastro de Premissa Vs Coordenador.",3 , , , .T.)
         EndIf
      EndIf
   Else
      nRecno := Z38->(Recno()) 
      DbSelectArea("Z38")
      DbSetOrder(1)
      If DbSeek(_cFilial+_cCod+_cPeriodo)
         Do While _cFilial+_cCod+_cPeriodo == Z38->(Z38_FILIAL+Z38_COD+Z38_PERIOD) .AND. Z38->(!EOF())
            If Z38->(Recno()) <> nRecno
               lRet := .F.
               U_ITMSG("J� existe um registro nesse cadastro com a mesma chave digitada Codigo: "+_cCod+" Periodo: "+_cPeriodo,"Aten��o","Prencha pelo menos um desses campos com valores difrentes dos citados.",3 , , , .T.)
               Exit
            EndIf
            Z38->(DbSkip())
         EndDo
         lRet := .T.
      Else
         lRet := .T.
      EndIf
   EndIf
   
Return lRet

/*
===============================================================================================================================
Programa----------: AOMS153G
Autor-------------: Igor Melga�o
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Pos Valida��o
===============================================================================================================================
Parametros--------: _cFilial,_cCod
===============================================================================================================================
Retorno-----------: _cRetorno
===============================================================================================================================
*/ 
User Function AOMS153G(_cFilial,_cCod)
   Local _cRetorno := "" As Character
   Local _aAreaZ38 := {}

   _aAreaZ38 := GetArea("Z38")

   DbSelectArea("Z38")
   DbSetOrder(1)
   DbSeek(_cFilial+_cCod)
   _cRetorno := Z38->Z38_DESC
   
   RestArea(_aAreaZ38)

Return _cRetorno

/*
===============================================================================================================================
Programa----------: AOMS153I
Autor-------------: Igor Melga�o
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Valida��o do campo periodo
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/ 
User Function AOMS153I()
   Local lRet := .T. As Logical
   Local _cPeriodo := M->Z38_PERIOD //_oModel:GetValue("Z38CAB","Z38_PERIOD") 
   
   If Len(ALLTRIM(_cPeriodo)) < 6
      U_ITMSG("Contuedo inv�lido preenchido!","Aten��o","Preencha com Ano e M�s (AAAA/MM) no Campo.",3 , , , .T.) 
      lRet := .F.
   ElseIf Subs(_cPeriodo,5,2) > "12"
      lRet := .F.
      U_ITMSG("M�s digitado inv�lido!","Aten��o","",3 , , , .T.)
   Else
      lRet := .T.
   EndIf

Return lRet


/*
===============================================================================================================================
Programa----------: AOMS153J
Autor-------------: Igor Melga�o
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Inicializa o campo Z38_COD
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cCod
===============================================================================================================================
*/ 
User Function AOMS153J()
Local _cCod := Z38->Z38_COD
   
   If ALTERA
      __cCod := Z38->Z38_COD
      __cPeriod := Z38->Z38_PERIOD
   Else
      __cCod := ""
      __cPeriod := ""
      If INCLUI
         _cCod := Space(Len(Z38->Z38_COD))
      EndIf
   EndIf
   
Return _cCod

/*
===============================================================================================================================
Programa----------: AOMS153K
Autor-------------: Igor Melga�o
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Commit
===============================================================================================================================
Parametros--------: _oModel
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/ 
User Function AOMS153K(_oModel)
Local _cFilial := xFilial("Z38")
Local _cCod := _oModel:GetValue("Z38MASTER","Z38_COD") 
Local _cPeriodo := _oModel:GetValue("Z38MASTER","Z38_PERIOD") 
Local aZ39 := {}
Local aZ40 := {}
Local i  := 0
Local _nOperation := _oModel:GetOperation()
Local lContinua := .F.

Begin Transaction

If _nOperation = 3 .AND. !Empty(ALLTRIM(__cCod)) .AND. !Empty(ALLTRIM(__cPeriod))

   FWFormCommit( _oModel )

   Dbselectarea("Z39")
   DbSetOrder(1)
   If Dbseek( _cFilial + __cCod + __cPeriod)
      lContinua := .T.
   EndIf

   Dbselectarea("Z40")
   DbSetOrder(1)
   If Dbseek( _cFilial + __cCod + __cPeriod)
      lContinua := .T.
   EndIf

   If lContinua .AND. U_ITMSG("Deseja copiar tb os registros relacionados de Premissa Vs Produtos e Premissa Vs Coordenador?",'Aten��o!',,2,2,2)
      Dbselectarea("Z39")
      DbSetOrder(1)
      If Dbseek( _cFilial + __cCod + __cPeriod)
         Do While _cFilial + __cCod + __cPeriod == Z39->(Z39_FILIAL+Z39_COD+Z39_PERIOD) .AND. Z39->(!EOF())
            AADD(aZ39,{Z39->Z39_PRODUT,Z39->Z39_TIPO,Z39->Z39_UM,Z39->Z39_FATOR,Z39->Z39_TPCONV})         
            Z39->(DbSkip())
         EndDo
      EndIf

      Dbselectarea("Z40")
      DbSetOrder(1)
      If Dbseek( _cFilial + __cCod + __cPeriod)
         Do While _cFilial + __cCod + __cPeriod == Z40->(Z40_FILIAL+Z40_COD+Z40_PERIOD) .AND. Z40->(!EOF())
            AADD(aZ40,{Z40->Z40_COORD,Z40->Z40_ALVO,Z40->Z40_ATING})         
            Z40->(DbSkip())
         EndDo
      EndIf

      Dbselectarea("Z39")
      For i := 1 To Len(aZ39)
         Z39->(RecLock("Z39",.T.))
         Z39->Z39_FILIAL := _cFilial
         Z39->Z39_COD    := _cCod
         Z39->Z39_PERIOD := _cPeriodo
         Z39->Z39_PRODUT := aZ39[i][1]
         Z39->Z39_TIPO   := aZ39[i][2]
         Z39->Z39_UM     := aZ39[i][3]
         Z39->Z39_FATOR  := aZ39[i][4]
         Z39->Z39_TPCONV := aZ39[i][5]
         Z39->(MsUnlock())
      Next

      Dbselectarea("Z40")
      
      For i := 1 To Len(aZ40)
         Z40->(RecLock("Z40",.T.))
         Z40->Z40_FILIAL := _cFilial
         Z40->Z40_COD    := _cCod
         Z40->Z40_PERIOD := _cPeriodo
         Z40->Z40_COORD := aZ40[i][1]
         Z40->Z40_ALVO  := aZ40[i][2]
         Z40->Z40_ATING := aZ40[i][3]
         Z40->(MsUnlock())
      Next
   EndIf
Else

   FWFormCommit( _oModel )

EndIf

End Transaction

Return .t.
