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
Programa----------: AOMS112
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Cadastro de MicroRegi�o. Chamado: 36780
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AOMS124()
Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z22")
_oBrowse:SetMenuDef( 'AOMS124' )
_oBrowse:SetDescription("Cadastro de Microregi�o")
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

Return( FWMVCMenu("AOMS124") )

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
Local _oStruZ22 := FWFormStruct(1,"Z22")
Local _oModel
Local _bPosValidacao := {||U_AOMS124V()}
Local _aGatAux	:= {}

_aGatAux := FwStruTrigger( 'Z22_EST', 'Z22_REGIAO', 'U_AOMS123E(M->Z22_EST)', .F. )
_oStruZ22:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel := MPFormModel():New("AOMS124M" ,  /*bPreValidacao*/ , _bPosValidacao , /*bCommit*/ , /*bCancel*/)
_oModel:AddFields("Z22MASTER", /*cOwner*/ , _oStruZ22 , /*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCarga*/)
_oModel:SetDescription("Modelo de Dados Microregi�o")
_oModel:GetModel('Z22MASTER'):SetDescription("Dados Microregi�o")
_oModel:SetPrimaryKey( {'Z22_FILIAL','Z22_COD' } )

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
Local _oStruZ22 := FWFormStruct(2,"Z22")
Local _oModel := FWLoadModel("AOMS124")
Local _oView := Nil

_oView := FWFormView():New()
_oView:SetModel(_oModel)
_oView:AddField("VIEW_Z22", _oStruZ22 , "Z22MASTER")

_oView:CreateHorizontalBox("TELA",100)
_oView:SetOwnerView("VIEW_Z22","TELA")

Return _oView


/*
===============================================================================================================================
Programa----------: AOMS124V
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Rotina de valida��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lReturn  
===============================================================================================================================
*/ 
User Function AOMS124V()
Local _lReturn      := .T.
Local _aOrd         := SaveOrd({"Z22"})
Local _oModel       := FwModelActivete()
Local _oModelMaster := _oModel:GetModel("Z22MASTER")
Local _cCod         := _oModelMaster:GetValue('Z22_COD' ) 
Local _nOperation   := _oModel:GetOperation() 
Local _lValida      := .F.

If _nOperation == MODEL_OPERATION_INSERT 
    _lValida      := .T.
ElseIf _nOperation == MODEL_OPERATION_UPDATE
    If _cCod <> Z22->Z22_COD
        _lValida      := .T.
    EndIf
EndIf

If _lValida
    Z22->(DbSetOrder(1))
    If Z22->( Dbseek(xFilial("Z22")+_cCod) )
        _lReturn := .F.
        U_ITMSG("C�digo da Microregi�o informado j� consta no cadastro. ",;
              "Aten��o",;
              "Modifique o c�digo digitado.  ",3 , , , .T.)

        _lRet := .F.
          
    EndIf
EndIf

RestOrd(_aOrd)

Return _lReturn
