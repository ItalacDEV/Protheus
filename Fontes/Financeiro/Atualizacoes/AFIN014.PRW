/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 07/05/2018 | Padronização dos cabeçalhos dos fontes e funções do módulo financeiro. Chamado 24726.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TOPCONN.CH"

/*
===============================================================================================================================
Programa----------: AFIN014
Autor-------------: Josué Danich Prestes
Data da Criacao---: 28/10/2015
===============================================================================================================================
Descrição---------: Fazer manutenção na tabela de dados bancarios para boleto por filial - Chamado 12253
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN014()

Local oBrowse
Local aArea := ZZJ->(GetArea())
Local _lret := .T.

//VERIFICA PERMISSÃO DE ACESSO
_lRet := U_ITVACESS( 'ZZL' , 3 , 'ZZL_DADBOL' , "S" )

If !_lRet

//									|....:....|....:....|....:....|....:....|
	ShowHelpDlg( 'AFIN004001' ,	{	'Usuário sem acesso à rotina de dados '	,;
									'bancarios para boletos Italac!'						} , 2 ,;
								{	'Caso necessário solicite a manutenção à '		,;
									'um usuário com acesso ou, se necessário, '		,;
									'solicite o acesso à área de TI/ERP.'			} , 3  )
	
	Return()
	
EndIf


oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'ZZJ' )
oBrowse:SetDescription( 'Dados bancarios para boleto por filial' )
oBrowse:SetOnlyFields( { 'ZZJ_FILIAL','ZZJ_FILACE','ZZJ_BANCO','ZZJ_AGENCI' , 'ZZJ_CONTA' , 'ZZJ_SUBCON' , 'ZZJ_OPER' , 'ZZJ_DEFAUL' } )
oBrowse:DisableDetails()

oBrowse:Activate()

RestArea(aArea)

Return .T.


/*
===============================================================================================================================
Programa----------: MENUDEF
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/10/2015
===============================================================================================================================
Descrição---------: menu de opções
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Vetor de opções
===============================================================================================================================
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.AFIN014' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.AFIN014' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.AFIN014' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.AFIN014' OPERATION 5 ACCESS 0

Return aRotina


/*
===============================================================================================================================
Programa----------: MODELDEF
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/10;/2015
===============================================================================================================================
Descrição---------: Criação do modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Modelo dados
===============================================================================================================================
*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruPAI := FWFormStruct( 1, 'ZZJ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'MAFIN014' , /*bPreValidacao*/ , /*bPosValidacao*/ {|oMdl| MDPosVld(oMdl,oModel:GetOperation())}, /*bCommit*/ , /*bCancel*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Dados bancarios para boleto por filial' )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZZJPAI', NIL, oStruPAI,/*bPre-Validacao*/ ,/*bPos-Validacao*/,/*bCarga*/ )

//define a chave primaria
oModel:SetPrimaryKey( {"ZZJ_FILIAL",'ZZJ_FILACE',"ZZJ_BANCO","ZZJ_AGENC","ZZJ_CONTA","ZZJ_SUBCON"})


//validacao da ativacao do modelo
oModel:SetVldActivate( { |oModel| AtivaModelo( oModel ) } )

Return oModel

/*
===============================================================================================================================
Programa----------: VIEWDEF
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/10;2015
===============================================================================================================================
Descrição---------: Criação da visão dos dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Visão dos dados
===============================================================================================================================
*/
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruPAI := FWFormStruct( 2, 'ZZJ' )

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'AFIN014' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_PAI' , oStruPAI, 'ZZJPAI'  )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'BOXPAI'  , 98)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_PAI' , 'BOXPAI'  )

// Liga apresentação dos titulso dos componentes
oView:EnableTitleView( 'VIEW_PAI' )

//fechamento da view
oView:SetCloseOnOk({|oModel| If(oModel:GetOperation()=MODEL_OPERATION_UPDATE,.T.,.F.)})

Return oView

/*
===============================================================================================================================
Programa----------: AtivaModelo
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/10/2015
===============================================================================================================================
Descrição---------: Validar ativação do modelo
===============================================================================================================================
Parametros--------: Objeto da modelo de dados
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
*/
Static Function AtivaModelo(oModel)

Local aArea		:= GetArea()
Local lRet      := .T.

RestArea(aArea)

Return lRet

/*
===============================================================================================================================
Programa----------: MDPosVld
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/10/2015
===============================================================================================================================
Descrição---------: Validação da modelo de dados
===============================================================================================================================
Parametros--------: Objeto do modelo de dados
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
*/
Static Function MDPosVld(oMdl,_nopc)

Local oModelCab 	:= oMdl:GetModel( 'ZZJPAI' )
Local aArea			:= GetArea()
Local _lret 		:= .T.
Local _csituatu		:= ZZJ->ZZJ_DEFAUL //pega situação atual do registro para o caso de ser alteração
Local _nrecno		:= ZZJ->( recno() ) //pega registro atual para caso de ser alteração

//============================================================
//Se está marcando o banco como default verifica se não existe
// outro registro com mesma filial marcado como default
//Verifica também se não é registro duplicado    
//Se é exclusão não executa validação
//============================================================

If !(_nopc == 5)

 	DBSelectArea("ZZJ")
	If ZZJ->( DBSeek(xfilial("ZZJ")+oModelCab:GetValue('ZZJ_FILACE')) )
	
		Do While	ZZJ->ZZJ_FILIAL == xfilial("ZZJ") .AND. 	ZZJ->ZZJ_FILACE 	== oModelCab:GetValue('ZZJ_FILACE') .and. _lRet	
				
			If (_nopc == 4 .and. _csituatu <> "S") .or. _nopc <> 4
			
				If ZZJ->ZZJ_DEFAUL == 'S' .and. _lRet .and. oModelCab:GetValue('ZZJ_DEFAUL') == 'S'
			
					Help( ,, 'AFIN004002',, "Já existe banco default para essa filial!", 1, 0 )
					_lRet := .F.
				
				Endif
				
			Endif
			
			If 	alltrim(ZZJ->ZZJ_BANCO) 	== alltrim(oModelCab:GetValue('ZZJ_BANCO')) 	.AND. ;
				alltrim(ZZJ->ZZJ_AGENCI)	== alltrim(oModelCab:GetValue('ZZJ_AGENCI'))	.AND. ;
				alltrim(ZZJ->ZZJ_CONTA) 	== alltrim(oModelCab:GetValue('ZZJ_CONTA')) 	.AND. ;
				alltrim(ZZJ->ZZJ_SUBCON)	== alltrim(oModelCab:GetValue('ZZJ_SUBCON')) 	.AND. ;
				(_nopc <> 4 .or. ZZJ->( RECNO() ) <> _nrecno) .and.	_lret
	
				Help( ,, 'AFIN004003',, "Já existe mesmo bco/ag/conta/subconta nessa filial!", 1, 0 )
	
				_lRet := .F.
				
			Endif				
			
			ZZJ->( DBSKIP())
			
		enddo
		
	Endif

Endif

RestArea(aArea)

Return _lRet