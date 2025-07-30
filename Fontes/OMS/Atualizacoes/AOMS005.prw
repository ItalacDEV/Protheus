/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================


#INCLUDE "Protheus.ch"
#Include "FwMVCDef.ch"
#Include "RWMAKE.CH"
#Include "TopConn.ch"
#Include "FWMBROWSE.CH"

/*
===============================================================================================================================
Programa--------: AOMS005
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 06/05/2016
===============================================================================================================================
Descri��o-------: Cadastro de tipo de ocorr�ncias de frete - Chamado 15345
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS005()

Local _aArea   := GetArea()
Local _oBrowse
     
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    _oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    _oBrowse:SetAlias("ZFC")
 
    //Setando a descri��o da rotina
    _oBrowse:SetDescription("Cadastro de tipos de ocorr�ncia de frete")
        
    //Ativa a Browse
    _oBrowse:Activate()
     
    RestArea(_aArea)
    
Return Nil

/*
===============================================================================================================================
Programa--------: AOMS005 - MenuDef
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 06/05/2016
===============================================================================================================================
Descri��o-------: MenuDef do MVC
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aRot
===============================================================================================================================
*/

Static Function MenuDef()
 
Private _aRot := {}
     
//Adicionando op��es
ADD OPTION _aRot TITLE 'Visualizar' ACTION 'VIEWDEF.AOMS005' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION _aRot TITLE 'Incluir'    ACTION 'VIEWDEF.AOMS005' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION _aRot TITLE 'Alterar'    ACTION 'VIEWDEF.AOMS005' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION _aRot TITLE 'Excluir'    ACTION 'VIEWDEF.AOMS005' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return _aRot

/*
===============================================================================================================================
Programa--------: AOMS005 - ModelDef 
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 06/05/2016
===============================================================================================================================
Descri��o-------: ModelDef  do MVC
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _oModel
===============================================================================================================================
*/ 
 
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local _oModel := Nil
     
//Cria��o da estrutura de dados utilizada na interface
Local _oStZFC := FWFormStruct(1, "ZFC")
     
//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
_oModel := MPFormModel():New("AOMS005M",/*bPre*/, {|| U_ITLOGACS(),.T. }/*bPos*/,/*bCommit*/,/*bCancel*/) 
     
//Atribuindo formul�rios para o modelo
_oModel:AddFields("FORMZFC",/*cOwner*/,_oStZFC)
     
//Setando a chave prim�ria da rotina
_oModel:SetPrimaryKey({'ZFC_FILIAL','ZFC_CODIGO'})
     
//Adicionando descri��o ao modelo
_oModel:SetDescription("Cadastro de Tipos de Ocorr�ncias de Frete")
     
//Setando a descri��o do formul�rio
_oModel:GetModel("FORMZFC"):SetDescription("Cadastro de Tipos de Ocorr�ncias de Frete")

Return _oModel


/*
===============================================================================================================================
Programa--------: AOMS005 - ViewDef 
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 06/05/2016
===============================================================================================================================
Descri��o-------: ViewDef  do MVC
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _oView
===============================================================================================================================
*/
Static Function ViewDef()
 
//Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
Local _oModel := FWLoadModel("AOMS005")
     
//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
Local _oStZFC := FWFormStruct(2, "ZFC")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZFC_NOME|ZFC_DTAFAL|'}
     
//Criando _oView como nulo
Local _oView := Nil
 
//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
_oView := FWFormView():New()
_oView:SetModel(_oModel)
     
//Atribuindo formul�rios para interface
_oView:AddField("VIEW_ZFC", _oStZFC, "FORMZFC")
     
//Criando um container com nome tela com 100%
_oView:CreateHorizontalBox("TELA",100)
     
//Colocando t�tulo do formul�rio
_oView:EnableTitleView('VIEW_ZFC', 'Dados do Grupo de Produtos' )  
     
//For�a o fechamento da janela na confirma��o
_oView:SetCloseOnOk({||.T.})
     
//O formul�rio da interface ser� colocado dentro do container
_oView:SetOwnerView("VIEW_ZFC","TELA")

Return _oView

/*
===============================================================================================================================
Programa--------: AOMS005I
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 06/05/2016
===============================================================================================================================
Descri��o-------: Retorna pr�ximo c�digo da ZFD
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _ccod - pr�ximo c�digo de tipo de ocorr�ncia
===============================================================================================================================
*/  
 
User Function AOMS005I()

Local _ccod := "000001"
Local _cquery := ""

_cquery += " SELECT MAX(ZFC_CODIGO) MAXIMO FROM " + Retsqlname("ZFC") 
_cquery += " WHERE D_E_L_E_T_ <> '*' AND ZFC_FILIAL = '" + xfilial("ZFC") + "'"

TCQUERY _cQuery New Alias "ZFCT"
dbSelectArea("ZFCT")

If  !(ZFCT->( EOF() )) 

 _ccod := strzero((val(ZFCT->MAXIMO)+1),6)
	
Endif

ZFCT->( Dbclosearea() )


Return _ccod


