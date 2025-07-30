/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch'
#Include "FWMVCDef.ch"

/*
===============================================================================================================================
Programa----------: AGLT024
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/10/2019
===============================================================================================================================
Descri��o---------: Cadastro de Eventos para cr�ditos no Leite de Terceiros. Chamado 30962
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT024

Local _oBrowse	:= Nil

//Iniciamos a constru��o b�sica de um Browse.
_oBrowse := FWMBrowse():New()
//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
_oBrowse:SetAlias("ZT1")
//_oBrowse:SetMenuDef("AGLT024")
//Definimos o t�tulo que ser� exibido como m�todo SetDescription
_oBrowse:SetDescription("Cadastro de Eventos no Leite de Terceiros")
//Desliga a exibi��o dos detalhes
_oBrowse:DisableDetails()
//Ativamos a classe
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/10/2019
===============================================================================================================================
Descri��o---------: Rotina de defini��o autom�tica do menu via MVC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title "Pesquisar"	Action "PesqBrw" 			Operation OP_PESQUISAR 	Access 0
Add Option aRotina Title "Visualizar"	Action "ViewDef.AGLT024" 	Operation OP_VISUALIZAR Access 0
Add Option aRotina Title "Incluir"		Action "ViewDef.AGLT024" 	Operation OP_INCLUIR 	Access 0
Add Option aRotina Title "Alterar"		Action "ViewDef.AGLT024" 	Operation OP_ALTERAR 	Access 0
Add Option aRotina Title "Excluir"		Action "ViewDef.AGLT024" 	Operation OP_EXCLUIR 	Access 0
Add Option aRotina Title "Imprimir"		Action "ViewDef.AGLT024" 	Operation OP_IMPRIMIR 	Access 0
Add Option aRotina Title "Copiar"		Action "ViewDef.AGLT024" 	Operation OP_COPIA 		Access 0

Return(aRotina)

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/10/2019
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: oModel - Objeto do modelo de dados do MVC
===============================================================================================================================
*/
Static Function ModelDef()

Local _oStruZT1	:= FWFormStruct( 1 , "ZT1", /*bAvalCampo*/,/*lViewUsado*/ )  // Constru��o de uma estrutura de dados
Local _oModel	:= Nil

//Cria o objeto do Modelo de Dados
_oModel := MPFormModel():New('AGLT024M'/*cID*/,/*bPreValidacao*/,{|_oModel|AGLT024POS(_oModel)} /*bPostValidacao*/,/*bCommit*/,/*bCancel*/)
	
_oModel:SetDescription( 'Cr�ditos' )
// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
_oModel:AddFields( 'ZT1MASTER' ,, _oStruZT1 )
// Adiciona a descricao do Componente do Modelo de Dados
_oModel:GetModel( 'ZT1MASTER' ):SetDescription( 'Cadastro de Cr�ditos' )

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/10/2019
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function ViewDef()

Local _oModel	:= FWLoadModel("AGLT024")
Local _oStruZT1	:= FWFormStruct( 2 , "ZT1" )
Local _oView	:= Nil

// Cria o objeto de View
_oView := FWFormView():New()
// Define qual o Modelo de dados ser� utilizado
_oView:SetModel( _oModel )
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
_oView:AddField( "VIEW_ZT1" , _oStruZT1 , "ZT1MASTER" )
// Criar um "box" horizontal para receber algum elemento da view
_oView:CreateHorizontalBox( 'BOX0101' , 100 )
// Relaciona o ID da View com o "box" para exibicao
_oView:SetOwnerView( "VIEW_ZT1", "BOX0101" )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT024POS
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/10/2019
===============================================================================================================================
Descri��o---------: Valida��o da inclus�o de registros (Equivalente ao TUDOOK)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function AGLT024POS(_oModel)

Local _lRet		:= .T.
If _oModel:GetOperation() == MODEL_OPERATION_DELETE
	_lRet := U_ChkReg("ZT0","ZT0_EVENTO = '"+ZT1->ZT1_COD+"' AND ZT0_FILIAL = '"+xFilial("ZT0")+"'")
EndIf

Return( _lRet )