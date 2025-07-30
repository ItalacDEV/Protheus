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
Programa----------: AFIN032
Autor-------------: Igor Melga�o
Data da Criacao---: 23/12/2022
===============================================================================================================================
Descri��o---------: Par�metros de Integra��o Paytrack. Chamado: 42331
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AFIN032()
Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z30")
_oBrowse:SetMenuDef( 'AFIN032' )
_oBrowse:SetDescription("Par�metros de Integra��o Paytrack")
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

//===========================================================================
//| FWMVCMenu - Gera o menu padr�o para o Modelo Informado (Inc/Alt/Vis/Exc) |
//===========================================================================

Return( FWMVCMenu("AFIN032") )

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
Local _oStruZ30 := FWFormStruct(1,"Z30")
Local _oModel
Local _bPosValidacao := {||U_AFIN032V()}

_oModel := MPFormModel():New('AFIN032M' ,  /*bPreValidacao*/ , _bPosValidacao , /*bCommit*/ , /*bCancel*/)

_oModel:AddFields('Z30CAB', /*cOwner*/ ,_oStruZ30,/*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCarga*/)
_oModel:SetPrimaryKey( {'Z30_FILIAL' } )
_oModel:SetDescription("Par�metros de Integra��o Paytrack")

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
Local _oStruZ30 := FWFormStruct(2,"Z30")
Local _oModel := FWLoadModel("AFIN032")
Local _oView := Nil

_oView := FWFormView():New()
_oView:SetModel(_oModel)

_oView:AddField("VIEW_Z30",_oStruZ30,"Z30CAB"   ,,)
//Setando o dimensionamento de tamanho
_oView:CreateHorizontalBox('CABEC',100)


//Amarrando a view com as box
_oView:SetOwnerView('VIEW_Z30','CABEC')

//Habilitando t�tulo
//_oView:EnableTitleView('VIEW_Z30',"Par�metros de Integra��o Paytrack")

//Tratativa padr�o para fechar a tela
_oView:SetCloseOnOk({||.T.})

Return _oView


/*
===============================================================================================================================
Programa----------: AFIN032V
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
User Function AFIN032V()
Local _lReturn      := .T.
Local _aOrd         := SaveOrd({"Z21"})
Local _oModel       := FwModelActivete()
Local _cFilial      := xFilial("Z30")
Local _nOperation   := _oModel:GetOperation() 
Local _lValida      := .F.

If _nOperation == MODEL_OPERATION_INSERT 
    _lValida      := .T.
ElseIf _nOperation == MODEL_OPERATION_UPDATE
    If _cFilial <> Z30->Z30_FILIAL
        _lValida      := .T.
    EndIf
EndIf

If _lValida
    Z30->(DbSetOrder(1))
    If Z30->( Dbseek(_cFilial) )
        _lReturn := .F.
        U_ITMSG("Os Par�metros para esta filial j� foram cadastrados. ",;
              "Aten��o",;
              "Clique em alterar ou acesse outra filial para inser��o dos par�metros.  ",3 , , , .T.)
                                           
    EndIf
EndIf

RestOrd(_aOrd)

Return _lReturn
