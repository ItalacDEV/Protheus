/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor     |    Data    |                                             Motivo                                           
------------------------------------------------------------------------------------------------------------------------------- 
                 |            |
=============================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
  
/*
===============================================================================================================================
Programa----------: AOMS128()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Cadastro de Itens por Operador Log�stico.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS128()
Local _aArea   := GetArea()
Local _oBrowse
Private _cTitulo  

Begin Sequence   
   _cTitulo := "Cadastro de Itens por Operador Log�stico"   

   _oBrowse := FWMBrowse():New()
   _oBrowse:SetAlias("ZGL")
   _oBrowse:SetMenuDef('AOMS128')
   _oBrowse:SetDescription(_cTitulo)
   _oBrowse:Activate()

End Sequence       

RestArea(_aArea)

Return Nil

/*
===============================================================================================================================
Programa----------: MenuDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Define o Menu do fonte AOMS128.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local _aRotina := {}
      
ADD OPTION _aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.AOMS128' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION _aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.AOMS128' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION _aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.AOMS128' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION _aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.AOMS128' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return _aRotina

/*
===============================================================================================================================
Programa----------: ModelDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Define o modelo de dados do fonte AOMS128.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oModel    := Nil 
Local _oStruCab  := FWFormStruct(1, 'ZGL', {|cCampo| AllTRim(cCampo) $ "ZGL_FORNEC;ZGL_LOJA;ZGL_NOMFOR;"})
Local _oStruGrid := FWFormStruct(1, 'ZGL', {|cCampo| AllTRim(cCampo) $ "ZGL_PRODUT;ZGL_DESCPR;ZGL_MSBLQL;"}) //fModStruct()
 
_oModel := MPFormModel():New('AOMS128M', /*bPreValidacao*/, /*{|| fValidGrid()}*/, /*bCommit*/, /*bCancel*/ )
 
_oModel:AddFields('MdFieldZGL', NIL, _oStruCab)
_oModel:AddGrid('MdGridZGL', 'MdFieldZGL', _oStruGrid, , )
 
_oModel:SetRelation('MdGridZGL', {;
            {'ZGL_FILIAL', 'xFilial("ZGL")'},;
            {"ZGL_FORNEC", "ZGL_FORNEC"},;
            {"ZGL_LOJA"  , "ZGL_LOJA"}}, ZGL->(IndexKey(1)))
// oModel:SetRelation("DETAILSZ2",{{"Z2_FILIAL","xFilial(�Z02�)"},{"Z2_DOC","Z1_DOC"},{"Z2_SERIE","Z1_SERIE"}},SZ2->(IndexKey(1)))        
     
_oModel:GetModel("MdGridZGL"):SetMaxLine(9999)
_oModel:SetDescription("Cadastro de Itens por Operador Log�stico")
_oModel:SetPrimaryKey({"ZGL_FILIAL", "ZGL_FORNEC", "ZGL_FORNEC","ZGL_PRODUT"})
_oModel:GetModel( 'MdGridZGL' ):SetUniqueLine( { 'ZGL_PRODUT' } )
 
Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Define a View de dados do fonte AOMS128.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oView     := NIL
Local _oModel    := FWLoadModel('AOMS128')
Local _oStruCab  := FWFormStruct(2, "ZGL", {|cCampo| AllTRim(cCampo) $ "ZGL_FORNEC;ZGL_LOJA;ZGL_NOMFOR;"})
//Local _oStruGRID := FWFormStruct(2, "ZGL", {|cCampo| !AllTRim(cCampo) $ "ZGL_FORNEC;ZGL_LOJA;ZGL_NOMFOR;"}) //FViewStruct()
Local _oStruGRID := FWFormStruct(2, "ZGL", {|cCampo| AllTRim(cCampo) $ "ZGL_PRODUT;ZGL_DESCPR;ZGL_MSBLQL;"}) //FViewStruct()
 
_oStruCab:SetNoFolder()
 
_oView:= FWFormView():New() 
_oView:SetModel(_oModel)              
 
_oView:AddField('VIEW_ZGL', _oStruCab, 'MdFieldZGL')
_oView:AddGrid ('GRID_ZGL', _oStruGRID, 'MdGridZGL' )
 
_oView:CreateHorizontalBox("MAIN", 25)
_oView:CreateHorizontalBox("GRID", 75)
 
_oView:SetOwnerView('VIEW_ZGL', 'MAIN')
_oView:SetOwnerView('GRID_ZGL', 'GRID')
_oView:EnableControlBar(.T.)
 
Return _oView

/*
===============================================================================================================================
Programa----------: AOMS128I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Fun��o chamada no inicializador padr�o dos campos virtuais.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou o inicializador padr�o.
===============================================================================================================================
Retorno-----------: _cRet conte�do a ser utilizado como incializador padr�o.
===============================================================================================================================
*/  
User Function AOMS128I(_cCampo)
Local _oModel     := FWModelActive()
Local _oModelGRID := _oModel:GetModel('MdGridZGL')
Local _oModelMain := _oModel:GetModel('MdFieldZGL')
Local _cRet := ""
Local _cCod
Local _cLoja

Begin Sequence
   If _cCampo == "ZGL_DESCPRD"
      _cCod     := _oModelGRID:GetValue('ZGL_PRODUT')
      _cRet     := Posicione("SB1",1,xFilial("SB1")+_cCod,"B1_DESC")

   ElseIf _cCampo == "ZGL_NOMFOR"
      _cCod     := _oModelMain:GetValue('ZGL_FORNEC')
      _cLoja    := _oModelMain:GetValue('ZGL_LOJA')
      _cRet     := Posicione("SA2",1,xFilial("SB1")+_cCod+_cLoja,"A2_NOME")

   EndIf 

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Programa----------: AOMS128G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Fun��o chamada no gatilho dos campos para preenchimento de dados.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou o gatilho.
===============================================================================================================================
Retorno-----------: _cRet conte�do de retorno do gatiolho.
===============================================================================================================================
*/  
User Function AOMS128G(_cCampo)
Local _oModel     := FWModelActive()
Local _oModelGRID := _oModel:GetModel('MdGridZGL')
Local _oModelMain := _oModel:GetModel('MdFieldZGL')
Local _cRet := ""
Local _cCod
Local _cLoja

Begin Sequence
   If _cCampo == "ZGL_PRODUT"
      _cCod     := _oModelGRID:GetValue('ZGL_PRODUT')
      _cRet     := Posicione("SB1",1,xFilial("SB1")+_cCod,"B1_DESC")

   ElseIf _cCampo == "ZGL_FORNEC"
      _cCod     := _oModelMain:GetValue('ZGL_FORNEC')
      _cRet     := Posicione("SA2",1,xFilial("SA2")+_cCod,"A2_NOME")
   
   ElseIf _cCampo == "ZGL_LOJA"
      _cCod     := _oModelMain:GetValue('ZGL_FORNEC')
      _cLoja    := _oModelMain:GetValue('ZGL_LOJA')
      _cRet     := Posicione("SA2",1,xFilial("SA2")+_cCod+_cLoja,"A2_NOME")

   EndIf 

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Programa----------: AOMS128V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Valida o preenchimento dos dados conforme campo passado por par�metro.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a valida��o.
===============================================================================================================================
Retorno-----------: _lRet == .T. = Valida��o Ok.
                             .F. = n�o conformidade na valida��o.
===============================================================================================================================
*/  
User Function AOMS128V(_cCampo)
Local _lRet := .T.
Local _oModel     := FWModelActive()
Local _oModelGRID := _oModel:GetModel('MdGridZGL')
Local _oModelMain := _oModel:GetModel('MdFieldZGL')
Local _cCod
Local _cLoja

Begin Sequence

   If _cCampo == "ZGL_FORNEC"
      _cCod     := _oModelMain:GetValue('ZGL_FORNEC')
      IF ! ExistCpo("SA2", _cCod)
         _lRet := .F.
      EndIf       

   ElseIf _cCampo == "ZGL_LOJA"
      _cCod     := _oModelMain:GetValue('ZGL_FORNEC')
      _cLoja    := _oModelMain:GetValue('ZGL_LOJA')

      If ! ExistCpo("SA2", _cCod + _cLoja)
         _lRet := .F.
      EndIf   

   ElseIf _cCampo == "ZGL_PRODUT"
      _cCod     := _oModelGRID:GetValue('ZGL_PRODUT')
      IF ! ExistCpo("SB1", _cCod)
         _lRet := .F.
      EndIf  
   EndIf 

End Sequence 

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS128W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/07/2021
===============================================================================================================================
Descri��o---------: Determina se um campo ser� edit�vel ou n�o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet == .T. = o campo pode ser editado.
                             .F. = o campo n�o pode ser editado.
===============================================================================================================================
*/  
User Function AOMS128W()
Local _lRet := .T.
Local _oModel     := FWModelActive()
Local _oModelGRID := _oModel:GetModel('MdGridZGL')

Begin Sequence

   If ! _oModelGRID:IsInserted() 
      _lRet := .F.  
   EndIf 

End Sequence

Return _lRet 


