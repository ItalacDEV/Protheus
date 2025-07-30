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
Programa----------: AOMS139
Autor-------------: Igor Melga�o
Data da Criacao---: 26/07/2023
===============================================================================================================================
Descri��o---------: Bloqueio de produtos por Filial Chamado: 44407 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AOMS139()
Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("SB1")
_oBrowse:SetMenuDef( 'AOMS139' )
_oBrowse:SetDescription("Bloqueio de Produtos por Filial")
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 26/07/2023
===============================================================================================================================
Descri��o---------: Rotina de defini��o autom�tica do menu via MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.AOMS139' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Bloquear ou Desblquear" ACTION 'VIEWDEF.AOMS139' OPERATION 4 ACCESS 0 //"Alterar"

Return( aRotina ) 

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 26/07/2023
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/ 
Static Function ModelDef()
Local _oStruSB1 := FWFormStruct(1,"SB1"  ,{|cCampo| AllTrim(cCampo) $ "B1_COD|B1_DESC|B1_TIPO|B1_UM|B1_GRUPO|B1_MSBLQL|B1_LOCPAD|B1_I_DESCD|"},/*lViewUsado*/)
Local _oStruSBZ := FWFormStruct(1,"SBZ"  ,{|cCampo| AllTrim(cCampo) $ "BZ_FILIAL|BZ_I_BLQPR"},/*lViewUsado*/)
Local _oModel
Local _aSBZRel := {}

_oStruSBZ:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'BZ_FIL' , ;                // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        2 , ;                       // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SBZ->BZ_FILIAL } , ;   // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oModel := MPFormModel():New('AOMS139M' ,  /*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCommit*/ , /*bCancel*/)

_oModel:AddFields('SB1CAB', /*cOwner*/ ,_oStruSB1,/*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCarga*/)
_oModel:AddGrid('SBZDETAIL','SB1CAB'   ,_oStruSBZ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)

_oModel:GetModel( 'SBZDETAIL' ):SetNoInsertLine( .T. )

aAdd(_aSBZRel, {'BZ_COD'    , 'SB1CAB.B1_COD'   })

_oModel:SetRelation('SBZDETAIL', _aSBZRel, SBZ->(IndexKey(1)))

_oModel:SetPrimaryKey( {'B1_FILIAL','B1_COD'} )
_oModel:SetDescription("Bloqueio de Produto por Filial")

Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 26/07/2023
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oStruSB1 := FWFormStruct(2,"SB1"  ,{|cCampo| AllTrim(cCampo) $ "B1_COD|B1_DESC|B1_TIPO|B1_UM|B1_GRUPO|B1_MSBLQL|B1_LOCPAD|B1_I_DESCD|"},/*lViewUsado*/)
Local _oStruSBZ := FWFormStruct(2,"SBZ"  ,{|cCampo| AllTrim(cCampo) $ "BZ_FILIAL|BZ_I_BLQPR"},/*lViewUsado*/)
Local _oModel := FWLoadModel("AOMS139")
Local _oView := Nil

    _oStruSBZ:AddField( ;                       // Ord. Tipo Desc.
        'BZ_FIL'                        , ;     // [01] C   Nome do Campo
        "01"                            , ;     // [02] C   Ordem
        AllTrim( 'Filial' )             , ;     // [03] C   Titulo do campo
        AllTrim( 'Filial' )             , ;     // [04] C   Descricao do campo
        { 'Legenda' }                   , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        ''                              , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                              , ;     // [09] C   Consulta F3
        .F.                             , ;     // [10] L   Indica se o campo � alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo � virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSB1:SetProperty( 'B1_COD'     , MVC_VIEW_CANCHANGE  , .F. )
_oStruSB1:SetProperty( 'B1_DESC'    , MVC_VIEW_CANCHANGE  , .F. )
_oStruSB1:SetProperty( 'B1_TIPO'    , MVC_VIEW_CANCHANGE  , .F. )
_oStruSB1:SetProperty( 'B1_UM'      , MVC_VIEW_CANCHANGE  , .F. )
_oStruSB1:SetProperty( 'B1_GRUPO'   , MVC_VIEW_CANCHANGE  , .F. )
_oStruSB1:SetProperty( 'B1_MSBLQL'  , MVC_VIEW_CANCHANGE  , .F. )
_oStruSB1:SetProperty( 'B1_LOCPAD'  , MVC_VIEW_CANCHANGE  , .F. )
_oStruSB1:SetProperty( 'B1_I_DESCD' , MVC_VIEW_CANCHANGE  , .F. )

_oView := FWFormView():New()
_oView:SetModel(_oModel)

// Configura as estruturas de modelo de dados
_oView:AddField("VIEW_SB1",_oStruSB1,"SB1CAB"   ,,)
_oView:AddGrid('VIEW_SBZ' ,_oStruSBZ,'SBZDETAIL',,)

//Setando o dimensionamento de tamanho
_oView:CreateVERTICALBox('CABEC' ,80)
_oView:CreateVERTICALBox('DETAIL',20)

//Amarrando a view com as box
_oView:SetOwnerView('VIEW_SB1','CABEC')
_oView:SetOwnerView('VIEW_SBZ','DETAIL')

//Habilitando t�tulo
//_oView:EnableTitleView('VIEW_SB1','Dados de Integra��o' )
//_oView:EnableTitleView('VIEW_SBZ','Registros de Payload')

_oView:AddUserButton( 'Desbloquear Todas Filiais'   , 'CLIPS', {|_oView| AOMS139X(_oView,"N")} )
_oView:AddUserButton( 'Bloquear Todas Filiais'      , 'CLIPS', {|_oView| AOMS139X(_oView,"S")} )

//_oModel:GetValue('Z29_FILIAL') + _oModel:GetValue('Z29_PREFIX') + _oModel:GetValue('Z29_NUM') 
//Tratativa padr�o para fechar a tela
_oView:SetCloseOnOk({||.T.})

Return _oView






/*
===============================================================================================================================
Programa----------: AOMS139X
Autor-------------: Igor Melga�o
Data da Criacao---: 26/07/2023
===============================================================================================================================
Descri��o---------: Bloqueia ou Desbloqueia todas as filiais
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/ 
Static Function AOMS139X(_oView,cTipo)
Local _oModel     := FwModelActivete()
Local _oModelSBZ  := _oModel:GetModel("SBZDETAIL")
Local nLinha      := 1 
Local _nQtdLin	  := _oModelSBZ:Length()
Local _nLinPos    := _oModelSBZ:GetLine() 

For nLinha := 1 To _nQtdLin 
    _oModelSBZ:Goline(nLinha)
    _oModelSBZ:SetValue('BZ_I_BLQPR',cTipo)
Next

_oView:Refresh('SBZDETAIL')
_oView:Refresh()

_oModelSBZ:GoLine( _nLinPos ) 

Return 
