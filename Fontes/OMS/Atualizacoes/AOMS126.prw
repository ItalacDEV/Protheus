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
Data da Criacao---: 28/06/2021
===============================================================================================================================
Descri��o---------: Cadastro de Capacidade de Carregamento. Chamado: 36841
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AOMS126()
Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z24")
_oBrowse:SetMenuDef( 'AOMS126' )
_oBrowse:SetDescription("Cadastro de Capacidade de Carregamento")
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/06/2021
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

Return( FWMVCMenu("AOMS126") )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/ 
Static Function ModelDef()
Local _oStruZ24 := FWFormStruct(1,"Z24")
Local _oModel
Local _bPosValidacao := {||U_AOMS126V()}

_oModel := MPFormModel():New("AOMS126M" ,  /*bPreValidacao*/ , _bPosValidacao , /*bCommit*/ , /*bCancel*/)
_oModel:AddFields("Z24MASTER", /*cOwner*/ , _oStruZ24 , /*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCarga*/)
_oModel:SetDescription("Capacidade de Carregamento")
_oModel:GetModel('Z24MASTER'):SetDescription("Capacidade de Carregamento")
_oModel:SetPrimaryKey( {'Z24_FILIAL','Z24_FILORI','Z24_OPER'} )

Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oStruZ24 := FWFormStruct(2,"Z24")
Local _oModel := FWLoadModel("AOMS126")
Local _oView := Nil

_oView := FWFormView():New()
_oView:SetModel(_oModel)
_oView:AddField("VIEW_Z24", _oStruZ24 , "Z24MASTER")

_oView:CreateHorizontalBox("TELA",100)
_oView:SetOwnerView("VIEW_Z24","TELA")

Return _oView


/*
===============================================================================================================================
Programa----------: AOMS126V
Autor-------------: Igor Melga�o
Data da Criacao---: 28/06/2021
===============================================================================================================================
Descri��o---------: Rotina de valida��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lReturn  
===============================================================================================================================
*/ 
User Function AOMS126V()
Local _lReturn      := .T.
Local _aOrd         := SaveOrd({"Z24"})
Local _oModel       := FwModelActivete()
Local _oModelMaster := _oModel:GetModel("Z24MASTER")
Local _cFilOri      := _oModelMaster:GetValue('Z24_FILORI' ) 
Local _cOper        := _oModelMaster:GetValue('Z24_OPER' ) 
Local _nOperation   := _oModel:GetOperation() 
Local _lValida      := .F.

If Empty(Alltrim(_cFilOri)) .And. Empty(Alltrim(_cOper))
    _lReturn := .F.
    
	U_ITMSG("Filial e Opera��o n�o prenchida.",;
            "Aten��o",;
            "Preencha o campo Filial ou Opera��o para conclus�o do cadastro.  ",3 , , , .T.)
Else
    If _nOperation == MODEL_OPERATION_INSERT 
        _lValida := .T.
    ElseIf _nOperation == MODEL_OPERATION_UPDATE
        If (_cFilOri+_cOper) <> (Z24->Z24_FILORI+Z24->Z24_OPER)
            _lValida := .T.
        EndIf
    EndIf

    If _lValida
        Z24->(DbSetOrder(1))
        If Z24->( Dbseek(xFilial("Z24")+_cFilOri+_cOper) )
            _lReturn := .F.

    		U_ITMSG("Chave ( Filial + Opera��o ) informada j� consta no cadastro. ",;
                    "Aten��o",;
                    "Verifique e modifique o chave digitada.  ",3 , , , .T.)	
              
        EndIf
    EndIf
EndIf

RestOrd(_aOrd)

Return _lReturn
