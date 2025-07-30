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
Programa----------: AOMS155
Autor-------------: Igor Melga�o
Data da Criacao---: 08/05/2025
===============================================================================================================================
Descri��o---------: Premissa Vs Coordenador. Chamado: 50568 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AOMS155()
Local _oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z40")
_oBrowse:SetMenuDef( 'AOMS155' )
_oBrowse:SetDescription("Premissa Vs Coordenador")
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/05/2025
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

ADD OPTION _aRotina Title 'Visualizar'	Action 'VIEWDEF.AOMS155'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'   	Action 'VIEWDEF.AOMS155'	OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'   	Action 'VIEWDEF.AOMS155'	OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'	   Action 'VIEWDEF.AOMS155'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Copiar'     Action 'VIEWDEF.AOMS155'   OPERATION 9 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/05/2025
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/ 
Static Function ModelDef()
Local _oStZ40CAB := FWFormStruct(1,"Z40",{ |x| ALLTRIM(x) $ 'Z40_COD, Z40_DESC, Z40_PERIOD' } )
Local _oStZ40DET := FWFormStruct(1,"Z40",{ |x| ALLTRIM(x) $ 'Z40_COORD,Z40_NOME,Z40_ALVO, Z40_ATING' } )
Local _oModel

_oModel := MPFormModel():New("AOMS155M",/*bPreValidacao*/ ,/*_bPosValidacao*/ ,/*bCommit*/,/*bCancel*/) 

// MPFORMMODEL():AddFields(< cId >, < cOwner >, < oModelStruct >, < bPre >, < bPost >, < bLoad >)-
_oModel:AddFields("Z40MASTER",/*cOwner*/,_oStZ40CAB)

//      AddGrid(<cId >     ,<cOwner >  ,<oModelStruct, _bLinePre, _bLinePost , _bPre > , _bLinePost >, _bLoad >)
_oModel:AddGrid("Z40DETAIL" , "Z40MASTER" , _oStZ40DET , ,,)
_oModel:SetRelation( "Z40DETAIL" , {	{ 'Z40_FILIAL'	, 'xFilial("Z40")'	} ,;
                                        { 'Z40_COD'	    , 'Z40_COD'	    } ,;
                                        { 'Z40_PERIOD'	, 'Z40_PERIOD'	    } }, Z40->( IndexKey( 1 ) ) )

_oModel:GetModel( 'Z40DETAIL' ):SetUniqueLine( { 'Z40_COORD' } )   

_oModel:SetPrimaryKey({'Z40_FILIAL','Z40_COD','Z40_PERIOD'})
     
_oModel:SetDescription("Premissa Vs Coordenador")

// Define valida��o inical do modelo
_oModel:SetVldActivate( { |_oModel| .T. } )

Return _oModel


/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/05/2025
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oModel := FWLoadModel("AOMS155")
Local _oStZ40CAB := FWFormStruct(2,"Z40",{ |x| ALLTRIM(x) $ 'Z40_COD, Z40_DESC, Z40_PERIOD' } )
Local _oStZ40DET := FWFormStruct(2,"Z40",{ |x| ALLTRIM(x) $ 'Z40_COORD,Z40_NOME,Z40_ALVO, Z40_ATING' } )
Local _oView := Nil
 
_oView := FWFormView():New()
_oView:SetModel(_oModel)
     
_oView:AddField( "VIEW_MASTER", _oStZ40CAB	, "Z40MASTER" )
_oView:AddGrid(  "VIEW_DETAIL", _oStZ40DET	, "Z40DETAIL" )
     
_oView:CreateHorizontalBox( 'BOX0101' , 20 )
_oView:CreateHorizontalBox( 'BOX0102' , 80 )
_oView:SetOwnerView( "VIEW_MASTER" , "BOX0101" )
_oView:SetOwnerView( "VIEW_DETAIL" , "BOX0102" )

//_oView:EnableTitleView('VIEW_Z40', ' ' )  
     
//For�a o fechamento da janela na confirma��o
_oView:SetCloseOnOk({||.T.})
     
//O formul�rio da interface ser� colocado dentro do container
//_oView:SetOwnerView("VIEW_Z40","TELA")

Return _oView

/*
===============================================================================================================================
Programa----------: AOMS155I
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
User Function AOMS155I()
   Local lRet := .T. As Logical
   Local _oModel := FWModelActive()
   Local _cPeriodo := _oModel:GetValue("Z40MASTER","Z40_PERIOD") 

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
Programa----------: AOMS155J
Autor-------------: Igor Melga�o
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Inicializa o campo Z40_COD
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cCod
===============================================================================================================================
*/ 
User Function AOMS155J()

   If INCLUI
     _cCod := Space(len(Z40->Z40_COD))
   Else
      _cCod := Z40->Z40_COD
   EndIf
   
Return _cCod


/*
===============================================================================================================================
Programa----------: AOMS155L
Autor-------------: Igor Melga�o
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Inicializa o campo Z40_PERIOD
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cCod
===============================================================================================================================
*/ 
User Function AOMS155L()

   If INCLUI  
     _cCod := Space(len(Z40->Z40_PERIOD))
   Else
      _cCod := Z40->Z40_PERIOD
   EndIf
   
Return _cCod
