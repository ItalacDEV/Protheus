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
Programa----------: AFIN033
Autor-------------: Igor Melga�o
Data da Criacao---: 23/12/2022
===============================================================================================================================
Descri��o---------: Registros de Compensa��o Paytrack. Chamado: 42331
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AFIN033(_cChave)
Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z26")
_oBrowse:SetMenuDef( 'AFIN033' )
_oBrowse:SetDescription("Compensa��es de Adiantamento Paytrack")
_oBrowse:AddLegend( "Z26_STATUS=='I'", "GREEN"      ,"Integrado")
_oBrowse:AddLegend( "Z26_STATUS=='N'", "BLACK"      ,"Nao Integrado")
_oBrowse:AddLegend( "Z26_STATUS=='E'", "RED"        ,"Excluido")
_oBrowse:AddLegend( "Z26_STATUS=='R'", "ORANGE"     ,"Reintegrado")
_oBrowse:SetFilterDefault( "Z26_EXCLUI = .F. .AND. Z26_PREFIX=='CVI' .AND. (Z26_STATUS=='I' .OR. Z26_STATUS=='R') "+Iif(!Empty(Alltrim(_cChave)),".AND. Z26->(Z26_FILIAL+Z26_PREFIX+Z26_NUM) == '"+_cChave+"'",'') )

_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
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

ADD OPTION _aRotina Title 'Excluir Titulo relacionado'  Action 'U_AFIN033X()'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Visualizar'	                Action 'VIEWDEF.AFIN033'	OPERATION 2 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/ 
Static Function ModelDef()
Local _oStruZ26 := FWFormStruct(1,"Z26")
Local _oStruZ27 := FWFormStruct(1,"Z27")
Local _oStruZ28 := FWFormStruct(1,"Z28")
Local _oStruSE2 := FWFormStruct(1,"SE2")
Local _oModel
Local _bPosValidacao := {||U_AFIN033V()}
Local _aZ27Rel := {}
Local _aZ28Rel := {}
Local _aSE2Rel := {}

_oStruSE2:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'SE2_LEGEND' , ;            // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || AFIN033L() } , ;       // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .T. )                       // [14] L Indica se o campo � virtual 


_oModel := MPFormModel():New('AFIN033M' ,  /*bPreValidacao*/ , _bPosValidacao , /*bCommit*/ , /*bCancel*/)

_oModel:AddFields('Z26CAB', /*cOwner*/ ,_oStruZ26,/*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCarga*/)

_oModel:AddGrid('Z27DETAIL','Z26CAB',_oStruZ27,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('Z28DETAIL','Z26CAB',_oStruZ28,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('SE2DETAIL','Z26CAB',_oStruSE2,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)


aAdd(_aZ27Rel, {'Z27_IDINTE', 'Z26CAB.Z26_IDINTE'} )

aAdd(_aZ28Rel, {'Z28_IDINTE', 'Z26CAB.Z26_IDINTE'} )

aAdd(_aSE2Rel, {'E2_FILIAL' , 'Z26CAB.Z26_FILIAL'} )
aAdd(_aSE2Rel, {'E2_PREFIXO', 'Z26CAB.Z26_PREFIX'} )
aAdd(_aSE2Rel, {'E2_NUM'    , 'Z26CAB.Z26_NUM'   } )
aAdd(_aSE2Rel, {'E2_PARCELA', 'Z26CAB.Z26_PARCEL'} )
aAdd(_aSE2Rel, {'E2_FORNECE', 'Z26CAB.Z26_FORNEC'} )
aAdd(_aSE2Rel, {'E2_LOJA'   , 'Z26CAB.Z26_LOJA'  } )

_oModel:SetRelation('Z27DETAIL', _aZ27Rel, Z27->(IndexKey(1)))
_oModel:SetRelation('Z28DETAIL', _aZ28Rel, Z28->(IndexKey(1)))
_oModel:SetRelation('SE2DETAIL', _aSE2Rel, SE2->(IndexKey(1)))

_oModel:SetPrimaryKey( {'Z26_FILIAL','Z26_PREFIX','Z26_NUM','Z26_PARCEL','Z26_TIPO' } )
_oModel:SetDescription("Compensa��o de Adiantamento Paytrack")


Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oStruZ26 := FWFormStruct(2,"Z26")
Local _oStruZ27 := FWFormStruct(2,"Z27")
Local _oStruZ28 := FWFormStruct(2,"Z28")
Local _oStruSE2 := FWFormStruct(2,"SE2")
Local _oModel   := FWLoadModel("AFIN033")
Local _oView    := Nil

    _oStruSE2:AddField( ;                       // Ord. Tipo Desc.
        'SE2_LEGEND'                    , ;     // [01] C   Nome do Campo
        "00"                            , ;     // [02] C   Ordem
        AllTrim( ''    )                , ;     // [03] C   Titulo do campo
        AllTrim( '' )                   , ;     // [04] C   Descricao do campo
        { 'Legenda' }                   , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        '@BMP'                          , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                              , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo � alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo � virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 
 
_oView := FWFormView():New()
_oView:SetModel(_oModel)

_oView:AddField("VIEW_Z26",_oStruZ26,"Z26CAB"   ,,)


_oView:AddGrid('VIEW_Z27' ,_oStruZ27,'Z27DETAIL',,)
_oView:AddGrid('VIEW_Z28' ,_oStruZ28,'Z28DETAIL',,)
_oView:AddGrid('VIEW_SE2' ,_oStruSE2,'SE2DETAIL',,)

//Setando o dimensionamento de tamanho
_oView:CreateHorizontalBox('CABEC',40)
_oView:CreateHorizontalBox('DETAIL',30)
_oView:CreateHorizontalBox('DETAIL_SE2',30)
_oView:CreateVerticalBox('DETAIL_Z27',50,'DETAIL',,,)
_oView:CreateVerticalBox('DETAIL_Z28',50,'DETAIL',,,)

//Amarrando a view com as box
_oView:SetOwnerView('VIEW_Z26','CABEC')
_oView:SetOwnerView('VIEW_Z27','DETAIL_Z27')
_oView:SetOwnerView('VIEW_Z28','DETAIL_Z28')
_oView:SetOwnerView('VIEW_SE2','DETAIL_SE2')

_oView:EnableTitleView('VIEW_Z27','Rateio por Natureza')
_oView:EnableTitleView('VIEW_Z28','Rateio por Centro de Custo')
_oView:EnableTitleView('VIEW_SE2','Titulos Relacionados')

//Habilitando t�tulo
_oView:EnableTitleView('VIEW_Z26',"Principal")

//Tratativa padr�o para fechar a tela
_oView:SetCloseOnOk({||.T.})

Return _oView


/*
===============================================================================================================================
Programa----------: AFIN033V
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Rotina de Valida��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lReturn
===============================================================================================================================
*/ 
User Function AFIN033V()
Local _lReturn      := .T.
Local _aOrd         := SaveOrd({"Z21"})
Local _oModel       := FwModelActivete()
Local _cFilial      := xFilial("Z26")
Local _nOperation   := _oModel:GetOperation() 
Local _lValida      := .F.

If _nOperation == MODEL_OPERATION_INSERT 
    _lValida      := .T.
ElseIf _nOperation == MODEL_OPERATION_UPDATE
    If _cFilial <> Z26->Z26_FILIAL
        _lValida      := .T.
    EndIf
EndIf

If _lValida
    Z26->(DbSetOrder(1))
    If Z26->( Dbseek(_cFilial) )
        _lReturn := .F.
        U_ITMSG("Os Par�metros para esta filial j� foram cadastrados. ",;
              "Aten��o",;
              "Clique em alterar ou acesse outra filial para inser��o dos par�metros.  ",3 , , , .T.)
                                           
    EndIf
EndIf

RestOrd(_aOrd)

Return _lReturn


/*
===============================================================================================================================
Programa----------: AFIN033X
Autor-------------: Igor Melga�o
Data da Crziacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Exclus�o de Integra��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lReturn => Confirma��o de Execu��o
===============================================================================================================================
*/ 
User Function AFIN033X()
Local _cErro     := ""
Local _lContinua := .F.

_lContinua := U_MFIN021I("",@_cErro,.F.,"","X")

If !_lContinua
    U_ITMSG(_cErro,"Aten��o","",3 , , , .T.)
EndIf

Return _lContinua


/*
===============================================================================================================================
Programa----------: AFIN033L
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina para reorno da cor da Legenda
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cRetorno => Cor referente a legenda
===============================================================================================================================
*/ 
Static Function AFIN033L()
Local _cRetorno := ""

If SE2->E2_SALDO > 0
    _cRetorno := "BR_VERDE"
Else
    _cRetorno := "BR_VERMELHO"  
EndIf

Return _cRetorno
