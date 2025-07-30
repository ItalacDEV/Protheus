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
Programa----------: AGLT022
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/10/2019
===============================================================================================================================
Descri��o---------: Permite inclus�o de cr�ditos para fornecedor no Leite de Terceiros. A rotina funciona como um facilitador
					para a inclus�o de t�tulos no Contas a Pagar sem que o usu�rio do Leite precise ter acesso ao Financeiro.
					Chamado 30962
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT022

Local _oBrowse	:= Nil

//Iniciamos a constru��o b�sica de um Browse.
_oBrowse := FWMBrowse():New()
//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
_oBrowse:SetAlias("ZT0")
//_oBrowse:SetMenuDef("AGLT022")
//Definimos o t�tulo que ser� exibido como m�todo SetDescription
_oBrowse:SetDescription("Cadastro de Cr�ditos para Fornecedores de Leite de Terceiros")
//Desliga a exibi��o dos detalhes
_oBrowse:DisableDetails()
// Adiciona legenda no Browse
_oBrowse:AddLegend( "ZT0_STATUS == 'A'" , 'GREEN'	, 'Cr�dito em aberto'	)
_oBrowse:AddLegend( "ZT0_STATUS == 'P'" , 'BLUE'	, 'Cr�dito baixado parcialmente')
_oBrowse:AddLegend( "ZT0_STATUS == 'B'" , 'RED'		, 'Cr�dito baixado'	)
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
Add Option aRotina Title "Visualizar"	Action "ViewDef.AGLT022" 	Operation OP_VISUALIZAR Access 0
Add Option aRotina Title "Incluir"		Action "ViewDef.AGLT022" 	Operation OP_INCLUIR 	Access 0
Add Option aRotina Title "Alterar"		Action "ViewDef.AGLT022" 	Operation OP_ALTERAR 	Access 0
Add Option aRotina Title "Excluir"		Action "ViewDef.AGLT022" 	Operation OP_EXCLUIR 	Access 0
Add Option aRotina Title "Imprimir"		Action "ViewDef.AGLT022" 	Operation OP_IMPRIMIR 	Access 0
Add Option aRotina Title "Copiar"		Action "ViewDef.AGLT022" 	Operation OP_COPIA 		Access 0

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

Local _oStruZT0	:= FWFormStruct( 1 , "ZT0", /*bAvalCampo*/,/*lViewUsado*/ )  // Constru��o de uma estrutura de dados
Local _oModel	:= Nil

//Cria o objeto do Modelo de Dados
//Irie usar uma fun��o MVC001V que ser� acionada quando eu clicar no bot�o "Confirmar"
_oModel := MPFormModel():New('AGLT022M'/*cID*/,{|_oModelnLine|AGLT022PRE(_oModel) }/*bPreValidacao*/,{|_oModel|AGLT022POS(_oModel)}/*bPostValidacao*/,/*bCommit*/,/*bCancel*/)
	
_oModel:SetDescription( 'Cr�ditos' )
// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
_oModel:AddFields( 'ZT0MASTER' ,/*cOwner*/, _oStruZT0 )
// Adiciona a descricao do Componente do Modelo de Dados
_oModel:GetModel( 'ZT0MASTER' ):SetDescription( 'Cadastro de Cr�ditos' )
//_oModel:SetVldActivate( {|_oModel| AGLT022VLI(_oModel) } )

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

Local _oModel	:= FWLoadModel("AGLT022")
Local _oStruZT0	:= FWFormStruct( 2 , "ZT0" )
Local _oView	:= Nil

// Cria o objeto de View
_oView := FWFormView():New()
// Define qual o Modelo de dados ser� utilizado
_oView:SetModel( _oModel )
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
_oView:AddField( "VIEW_ZT0" , _oStruZT0 , "ZT0MASTER" )
//Remove os campos que n�o ir�o aparecer	
//_oStruZT0:RemoveField( 'X5_DESCENG' )
// Criar um "box" horizontal para receber algum elemento da view
_oView:CreateHorizontalBox( 'BOX0101' , 100 )
// Relaciona o ID da View com o "box" para exibicao
_oView:SetOwnerView( "VIEW_ZT0", "BOX0101" )
//_oView:EnableTitleView('Formulario' , 'Grupo Tribut�rio' )	
//_oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

//For�a o fechamento da janela na confirma��o
//_oView:SetCloseOnOk({||.T.})

Return( _oView )

/*
===============================================================================================================================
Programa----------: AGLT022PRE
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 22/10/2019
===============================================================================================================================
Descri��o---------: Valida��o inicial do modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function AGLT022PRE( _oModel )

Local _lRet		:= .T.

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AGLT022POS
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
Static Function AGLT022POS(_oModel)

Local _lRet		:= .T.
Local _aAutSE2	:= {}
Local _nModAux	:= nModulo
Local _cModAux	:= cModulo
 
PRIVATE lMsErroAuto := .F.

//Realiza valida��es com o MV_DATAFIN. Na inclus�o n�o estou validando pela emiss�o pois o Financeiro tamb�m n�o valida.
//Se come�arem os problemas, travar para a emiss�o ser igual � database
If _oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. _oModel:GetOperation() == MODEL_OPERATION_DELETE
	If DDatabase < SuperGetMV('MV_DATAFIN')
		_oModel:SetErrorMessage("ZT0MASTER","ZT0_EMISSA","ZT0MASTER","ZT0_EMISSA","AGLT22001","A DataBase do Sistema n�o � v�lida de acordo com o par�metro Financeiro.", "Corrija a DataBase ou solicite libera��o para a Contabilidade.")
		_lRet := .F.
	EndIf
EndIf

//Inclui t�tulo no Contas a Pagar
If _lRet .And. _oModel:GetOperation() == MODEL_OPERATION_INSERT
	Begin Transaction
		_aAutSE2 := { { "E2_PREFIXO", _oModel:GetValue("ZT0MASTER","ZT0_PREFIX")	, NIL },;
		            { "E2_NUM"      , _oModel:GetValue("ZT0MASTER","ZT0_COD")		, NIL },;
		            { "E2_TIPO"     , "NF"             								, NIL },;
		            { "E2_NATUREZ"  , _oModel:GetValue("ZT0MASTER","ZT0_NATURE")	, NIL },;
		            { "E2_FORNECE"  , _oModel:GetValue("ZT0MASTER","ZT0_FORNEC")	, NIL },;
		            { "E2_LOJA"		, _oModel:GetValue("ZT0MASTER","ZT0_LOJA") 		, NIL },;
		            { "E2_EMISSAO"  , _oModel:GetValue("ZT0MASTER","ZT0_EMISSA")	, NIL },;
		            { "E2_VENCTO"   , _oModel:GetValue("ZT0MASTER","ZT0_VENCTO")	, NIL },;
		            { "E2_VENCREA"  , DataValida(_oModel:GetValue("ZT0MASTER","ZT0_VENCTO")), NIL },;
		            { "E2_VALOR"    , _oModel:GetValue("ZT0MASTER","ZT0_VALOR")		, NIL },;
		            { "E2_ORIGEM"   , "AGLT022"										, NIL },;
   		            { "E2_HIST"   	, "GLT CR�DITOS PARA TERCEIROS"					, NIL }}

		nModulo := 6
		cModulo := "FIN"
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, _aAutSE2,, 3)  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
		 
		If lMsErroAuto
			_lRet := .F.
		    MostraErro()
		EndIf
		
		nModulo := _nModAux
		cModulo := _cModAux
	If !_lRet
		DisarmTransaction()
	EndIf
	End Transaction
//Exclui t�tulo no Contas a Pagar
ElseIf _lRet .And. _oModel:GetOperation() == MODEL_OPERATION_DELETE

	DBSelectArea("SE2")
	SE2->( DBSetOrder(1) )
	If SE2->( DBSeek( xFilial("SE2")+_oModel:GetValue("ZT0MASTER","ZT0_PREFIX")+_oModel:GetValue("ZT0MASTER","ZT0_COD")+PadR("",GetSX3Cache("E2_PARCELA","X3_TAMANHO")," ")+;
			 "NF " + _oModel:GetValue("ZT0MASTER","ZT0_FORNEC") + _oModel:GetValue("ZT0MASTER","ZT0_LOJA") ) )
		If !Empty(SE2->E2_BAIXA)
			_oModel:SetErrorMessage("ZT0MASTER","ZT0_COD","ZT0MASTER","ZT0_COD","AGLT02202","T�tulo sofreu baixas e n�o poder� ser exclu�do.", "Exclua a baixa antes de realizar a opera��o.")
		    _lRet := .F.
		Else
			Begin Transaction
				nModulo := 6
				cModulo := "FIN"
	
				_aAutSE2 := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
			                { "E2_NUM"     , SE2->E2_NUM     , NIL } }
		
				MSExecAuto( {|x,y,z| Fina050(x,y,z) } , _aAutSE2 ,, 5 )
		
				If lMsErroAuto
					MostraErro()
					_oModel:SetErrorMessage("ZT0MASTER","ZT0_COD","ZT0MASTER","ZT0_COD","AGLT02203","Falhou ao excluir o t�tulo de cr�dito no Financeiro!", "Informe a �rea de TI/ERP.")
					_lRet := .F.
				EndIf
	
				nModulo := _nModAux
				cModulo := _cModAux
				If !_lRet
					DisarmTransaction()
				EndIf
			End Transaction
	    EndIf
    Else
		_oModel:SetErrorMessage("ZT0MASTER","ZT0_COD","ZT0MASTER","ZT0_COD","AGLT02203","T�tulo n�o localizado no Financeiro.", "Informe a �rea de TI/ERP.")
		_lRet := .F.
	EndIf
EndIf

Return( _lRet )