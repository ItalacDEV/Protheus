/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
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
Programa----------: AOMS132()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/01/2022
===============================================================================================================================
Descrição---------: Rotina de Manutenção no Pré Cadastro do Pedido de Vendas Com base no Pedido de Compras dos Clientes.
                    Chamado 37652.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS132()
Local _oBrowse
Local _aNoFields, _nI
Local _cCampo

Private _cTitulo
Private aHeader := {}, aCols := {}

Begin Sequence
   //=======================================================================================
   // Inicializa variaveis de memória SC5 e ACols para simular pedido de vendas.
   //=======================================================================================
   _aNoFields := {"C5_REC_WT","C5_ALI_WT","C5_I_DESCO","C5_I_NOUSU","C5_NOMMOT","C5_I_V4NOM","C5_I_V5NOM","C5_I_DTAB"}
   
   RegToMemory( "SC5", .F., .F. )
   
   FillGetDados(1     ,"SC5"   ,1       ,          ,             ,{||.T.}, _aNoFields ,,,,,.T.)
   
   //                     1            2         3           4          5        6        7       8       9       10     
   // aAdd(aHeader,{trim(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo, x3_f3,x3_context})
   For _nI := 1 To Len(aHeader)      
       If ! AllTrim( aHeader[_nI,2]) $ "C5_REC_WT/C5_ALI_WT/C5_I_DESCO/C5_I_NOUSU/C5_NOMMOT/C5_I_V4NOM/C5_I_V5NOM/C5_I_DTAB"
          &("M->" + aHeader[_nI,2]) := CriaVar(aHeader[_nI,2])
       EndIf
   Next     

   aHeader := {}
   aCols   := {}
   
   //==================================================================
   // Campos que não serão exibidos na msgetdados.
   //==================================================================           
   _aNoFields := {"C6_SLDALIB",;
                  "C6_INFAD",;
                  "C6_I_QESP",; 
                  "C6_GRADE",;  
                  "C6_TPOP",;   
                  "C6_TPCONTR",;
                  "C6_REGWMS",; 
                  "C6_TPDEDUZ",;
                  "C6_MOTDED",; 
                  "C6_I_DIFPE",;
                  "C6_VDMOST",; 
                  "C6_RATEIO",; 
                  "C6_INTROT",;
                  "C6_TPPROD"} 

   //=============================================================================
   // Montagem do aheader                                                        
   //============================================================================= 
   FillGetDados(1     ,"SC6"   ,1       ,          ,             ,{||.T.}    ,_aNoFields ,,,,,.T.)   

   Aadd(aCols,Array(Len(aHeader)+1))  
       
   For _nI := 1 To Len(aHeader)
	    _cCampo := Alltrim(aHeader[_nI,2])
	       
	    If (aHeader[_nI,10] # "V" .And. ! (_cCampo $ "C6_QTDLIB/C6_ALI_WT/C6_REC_WT")) 
	       aCols[Len(aCols)][_nI] := CriaVar(_cCampo)
	    EndIf
	       
   Next    
        
   aCols[Len(aCols)][Len(aHeader)+1] := .F.

   //=======================================================================================
   // Rotina Principal
   //=======================================================================================
   _cTitulo := "Pré Cadastro de Pedido de Vendas com Base no Pedido de Compras dos Clientes"   

   _oBrowse := FWmBrowse():New()
   _oBrowse:SetAlias( 'ZBC' )
   _oBrowse:SetMenuDef('AOMS132')
   _oBrowse:SetDescription( _cTitulo )
   _oBrowse:Activate()

End Sequence 

Return NIL

/*
===============================================================================================================================
Programa----------: MenuDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/01/2022
===============================================================================================================================
Descrição---------: Define o Menu da Rotina.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'                Action 'VIEWDEF.AOMS132' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'                   Action 'VIEWDEF.AOMS132' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'                   Action 'VIEWDEF.AOMS132' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'                   Action 'VIEWDEF.AOMS132' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Lista Tipos de Veiculos'   Action 'U_AOMS132T'      OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Gerar Pre-Pedidos Vend.'   Action 'U_AOMS132I'      OPERATION 2 ACCESS 0 // U_AOMS132G
ADD OPTION aRotina Title 'Manutenção Pre-Pedidos V.' Action 'U_AOMS132N'      OPERATION 2 ACCESS 0 
ADD OPTION aRotina Title 'Efetivar Pre-Pedidos V.'   Action 'U_AOMS132E'      OPERATION 2 ACCESS 0

Return aRotina

/*
===============================================================================================================================
Programa----------: ModelDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/01/2022
===============================================================================================================================
Descrição---------: Define o Modelo de Dados.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local _oStruZBC := FWFormStruct( 1, 'ZBC', /*bAvalCampo*/, /*lViewUsado*/ )
Local _oStruZBD := FWFormStruct( 1, 'ZBD', /*bAvalCampo*/, /*lViewUsado*/ )
Local _oModel

// Cria o objeto do Modelo de Dados
_oModel := MPFormModel():New( 'AOMS132M', {|| U_AOMS132V("PRE-VALID")} /*bPreValidacao*/, {|| U_AOMS132V("BOTAO_OK")} /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
_oModel:AddFields( 'ZBCMASTER', /*cOwner*/, _oStruZBC )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
_oModel:AddGrid( 'ZBDDETAIL', 'ZBCMASTER', _oStruZBD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, {|| U_AOMS132V("VALIDA_LINHA")} /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
//_oModel:SetRelation( 'ZBDDETAIL', { { 'ZBD_FILIAL', 'xFilial( "ZBD" )' }, { 'ZBD_PEDCOM', 'ZBC_PEDCOM' },{"ZBC_CLIENT", "ZBD_CLIENT"},{"ZBC_LOJACL", "ZBD_LOJACL"} }, ZBD->( IndexKey( 3 ) ) )
//_oModel:SetRelation( 'ZBDDETAIL', { { 'ZBD_FILIAL', 'ZBC_FILIAL' }, { 'ZBD_PEDCOM', 'ZBC_PEDCOM' },{"ZBC_CLIENT", "ZBD_CLIENT"},{"ZBC_LOJACL", "ZBD_LOJACL"} }, ZBD->( IndexKey( 1 ) ) )
//_oModel:SetRelation( 'ZBDDETAIL', { { 'ZBD_FILIAL', 'xFilial( "ZBD" )' }, { 'ZBD_PEDCOM', 'ZBC_PEDCOM' } }, ZBD->( IndexKey( 1 ) ) ) 
_oModel:SetRelation( 'ZBDDETAIL', { { 'ZBD_FILIAL', 'xFilial( "ZBD" )' }, { 'ZBD_CHAVE', 'ZBC_CHAVE' } }, ZBD->( IndexKey( 1 ) ) ) 


// configurando a chave primária.
_oModel:SetPrimaryKey({"ZBD_FILIAL", "ZBD_PEDCOM", "ZBD_CLIENT","ZBD_LOJACL","ZBD_PRODUT"})

// Liga o controle de nao repeticao de linha
_oModel:GetModel( 'ZBDDETAIL' ):SetUniqueLine( { 'ZBD_PRODUT' } )

// Adiciona a descricao do Modelo de Dados
_oModel:SetDescription( 'Pedidos de Compras dos Clientes' )

// Adiciona a descricao do Componente do Modelo de Dados
_oModel:GetModel( 'ZBCMASTER' ):SetDescription( 'Pedidos de Compras dos Clientes' )
_oModel:GetModel( 'ZBDDETAIL' ):SetDescription( 'Itens dos Pedidos de Compras dos Clientes')

Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/01/2022
===============================================================================================================================
Descrição---------: Define View/Exibição de Dados.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local _oStruZBC := FWFormStruct( 2, 'ZBC' )
Local _oStruZBD := FWFormStruct( 2, 'ZBD' )
// Cria a estrutura a ser usada na View
Local _oModel   := FWLoadModel( 'AOMS132' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( _oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZBC', _oStruZBC, 'ZBCMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZBD', _oStruZBD, 'ZBDDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZBC', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZBD', 'INFERIOR' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZBD', 'ZBD_ITEM' )

// Criar novo botao na barra de botoes
//oView:AddUserButton( 'Inclui Autor', 'CLIPS', { |oView| COMP021BUT() } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZBD')
oView:EnableTitleView('VIEW_ZBD',_cTitulo)

// Liga a Edição de Campos na FormGrid
oView:SetViewProperty( 'VIEW_ZBD', "ENABLEDGRIDDETAIL", { 50 } )

// Habilita a pesquisa
//oView:SetViewProperty( 'VIEW_ZBD', "GRIDSEEK" )

Return oView

/*
===============================================================================================================================
Programa----------: AOMS132V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/01/2022
===============================================================================================================================
Descrição---------: Valida o preenchimento dos dados conforme campo passado por parâmetro.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a validação.
===============================================================================================================================
Retorno-----------: _lRet == .T. = Validação Ok.
                             .F. = não conformidade na validação.
===============================================================================================================================
*/  
User Function AOMS132V(_cCampo)
Local _lRet := .T.
Local _oModel     
Local _oModelZBD  
Local _oModelZBC  
Local _cCod  := Space(6)
Local _cLoja := Space(4) 
Local _lValidCli := .F.
Local _nQtd, _nQtd2 
Local _nCXPalet, _nQtdPalet 
Local _nPrcVend, _nValorTot 
Local _cOperac, _dDtEntreg, _cPedCom, _cCliente
Local _nI, _nTotLin 
Local _nOperacao, _cTabPrc, _aTabPrc, _dDtEntr 
Local _cVend1, _cVend2, _cVend3, _cVend4, _cRede
Local _cTipoVend, _cDescPrd 
Local _cTrocaNf, _cFilCarre, _cFilFatur 

Private N := 1

Begin Sequence

   _oModel     := FWModelActive()
   _oModelZBD  := _oModel:GetModel('ZBDDETAIL')
   _oModelZBC  := _oModel:GetModel('ZBCMASTER')
   _nOperacao  := _oModel:GetOperation()
   
   If _cCampo == "BOTAO_OK"
      If _nOperacao == MODEL_OPERATION_DELETE
         _cPedCompra := _oModelZBC:GetValue('ZBC_PEDCOM')
      
         If ! Empty(_cPedCompra)
            ZBF->(DbSetOrder(1))
            If ZBF->(MsSeek(xFilial("ZBF")+_cPedCompra))
               Help( ,, 'Atenção',, 'Este pedido de compras já está vinculado a um pré-pedido de vendas e não pode ser excluido.', 1, 0 )
               _lRet := .F.
               Break 
            EndIf        
         EndIf
      EndIf 
   EndIf 

   If _nOperacao <> MODEL_OPERATION_UPDATE .And. _nOperacao <> MODEL_OPERATION_INSERT
      Break
   EndIf 

   If _cCampo == "PRE-VALID" .And. _nOperacao == MODEL_OPERATION_UPDATE
      //_cPedCom   := _oModelZBC:GetValue('ZBC_PEDCOM')
      //_cCliente  := _oModelZBC:GetValue('ZBC_CLIENT') 
      //_cLoja     := _oModelZBC:GetValue('ZBC_LOJACL')

      //ZBE->(DbSetOrder(2))
      //If ZBE->(MsSeek(xFilial("ZBE")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
       ZBF->(DbSetOrder(3))
       If ZBF->(MsSeek(xFilial("ZBF")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL))) //.And. !Empty(ZBF->ZBF_PVPROT)
         Help( ,, 'Atenção',, 'Para este pedido de compras já foi gerado pré pedidos de vendas e não pode ser alterado.', 1, 0 )
         _lRet := .F.
         Break
      EndIf 

   EndIf 

   If _cCampo == "ZBC_CLIENT"
      _cCod     := _oModelZBC:GetValue('ZBC_CLIENT')
      IF ! ExistCpo("SA1", _cCod)
         _lRet := .F.
		 Break
      EndIf      
	  _lValidCli := .T. 

   ElseIf _cCampo == "ZBC_LOJACL"
      _cCod     := _oModelZBC:GetValue('ZBC_CLIENT')
      _cLoja    := _oModelZBC:GetValue('ZBC_LOJACL')

      If ! ExistCpo("SA1", _cCod + _cLoja)
         _lRet := .F.
		 Break
      EndIf   
      _lValidCli := .T.

   ElseIf _cCampo == "ZBD_PRODUT"
      _cCod     := _oModelZBD:GetValue('ZBD_PRODUT')
      IF ! ExistCpo("SB1", _cCod)
         _lRet := .F.
         Break 
      EndIf  
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial("SB1")+_cCod))
      
      _oModelZBD:LoadValue('ZBD_SEGUM',SB1->B1_SEGUM)
      _oModelZBD:LoadValue('ZBD_UM',SB1->B1_UM)     
      _oModelZBD:LoadValue('ZBD_LOCAL',SB1->B1_LOCPAD) 
      _oModelZBD:LoadValue('ZBD_DESCRI',SB1->B1_DESC)

   ElseIf _cCampo == "ZBD_UNSVEN" // quantidade segunda unidade de medida 

      _nQtd2  := _oModelZBD:GetValue('ZBD_UNSVEN')
      _nPrcVend := _oModelZBD:GetValue('ZBD_PRCVEN') 
             
      If _nQtd2 == 0
         Break 
      EndIf 

      _cCod     := _oModelZBD:GetValue('ZBD_PRODUT')
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial("SB1")+_cCod))
      
      _cDescPrd  :=  _oModelZBD:GetValue('ZBD_DESCRI')

      If Empty(_cDescPrd)
         _oModelZBD:LoadValue('ZBD_DESCRI',SB1->B1_DESC)
      EndIf 

      If SB1->B1_TIPCONV == "M"
         _nQtd  := _nQtd2 / SB1->B1_CONV   
      Else
         _nQtd  := _nQtd2 * SB1->B1_CONV
      EndIf

   	_nCXPalet  :=	SB1->B1_I_CXPAL
      
      If _nCXPalet == 0
         Help( ,, 'Atenção',, 'A quantidade de caixas por palete não foi informada para este produto.', 1, 0 )
         _lRet := .F.
         Break
      EndIf 

	   If mod(_nQtd2, _nCXPalet) > 0
         Help( ,, 'Atenção',, 'A quantidade informada na segunda unidade de medida não é multipla das quantidade de caixas por palete para este item. ['+;
              StrZero(_nCXPalet,4)+"] por palete.", 1, 0 )
         _lRet := .F.
         Break
      EndIf 

      _oModelZBD:LoadValue('ZBD_QTDVEN',_nQtd)  

      _nQtdPalet := 0 

      If _nCXPalet <> 0

	      If mod(_nQtd2, _nCXPalet) > 0

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) + 1 		

	      Else

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) 

	      EndIf

      EndIf
      
      _nValorTot := _nPrcVend * _nQtd 
      
      _oModelZBD:LoadValue('ZBD_QTDPAL', _nQtdPalet)
      _oModelZBD:LoadValue('ZBD_VALOR', _nValorTot)

   ElseIf _cCampo == "ZBD_QTDVEN"  // quantidade primeira unidade

      _nQtd     := _oModelZBD:GetValue('ZBD_QTDVEN')
      _nPrcVend := _oModelZBD:GetValue('ZBD_PRCVEN') 

      If _nQtd == 0
         
         Help( ,, 'Atenção',, 'O preenchimento da quantidade do item na primeira unidade de medida é obritório.', 1, 0 )
         _lRet := .F.
         Break 
      EndIf 

      _cCod     := _oModelZBD:GetValue('ZBD_PRODUT')
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial("SB1")+_cCod))
      
      _cDescPrd  :=  _oModelZBD:GetValue('ZBD_DESCRI')

      If Empty(_cDescPrd)
         _oModelZBD:LoadValue('ZBD_DESCRI',SB1->B1_DESC)
      EndIf 

      If SB1->B1_TIPCONV == "M"
         _nQtd2 := _nQtd * SB1->B1_CONV   
      Else
         _nQtd2  := _nQtd / SB1->B1_CONV
      EndIf
      
      _nCXPalet  :=	SB1->B1_I_CXPAL

      If _nCXPalet == 0
         Help( ,, 'Atenção',, 'A quantidade de caixas por palete não foi informada para este produto.', 1, 0 )
         _lRet := .F.
         Break
      EndIf 

	   If mod(_nQtd2, _nCXPalet) > 0
         Help( ,, 'Atenção',, 'A quantidade informada na primeira unidade de medida não é multipla das quantidade de caixas por palete para este item. ['+;
              StrZero(_nCXPalet,4)+"] por palete.", 1, 0 )
         _lRet := .F.
         Break
      EndIf 

      _oModelZBD:LoadValue('ZBD_UNSVEN',_nQtd2)

      _nQtdPalet := 0 

      If _nCXPalet <> 0

	      If mod(_nQtd2, _nCXPalet) > 0

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) + 1 		

	      Else

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) 

	      EndIf

      EndIf
    
      _nValorTot := _nPrcVend * _nQtd 

      _oModelZBD:LoadValue('ZBD_QTDPAL', _nQtdPalet)
      _oModelZBD:LoadValue('ZBD_VALOR', _nValorTot)

   ElseIf _cCampo == "ZBD_PRCVEN"  //preço unitário
      _nPrcVend := _oModelZBD:GetValue('ZBD_PRCVEN') 
      _nQtd     := _oModelZBD:GetValue('ZBD_QTDVEN')
      
      If _nPrcVend == 0
         
         Help( ,, 'Atenção',, 'O preenchimento do preço unitário do item é obritório.', 1, 0 )
         _lRet := .F.
         Break 
      EndIf 

      _nValorTot := _nPrcVend * _nQtd 
      _oModelZBD:LoadValue('ZBD_VALOR', _nValorTot)

   EndIf

   If _lValidCli
      SA1->(DbSetOrder(1))
      SA3->(DbSetOrder(1))

      If _cCampo == "ZBC_CLIENT"
         SA1->(MsSeek(xFilial("SA1")+_cCod))
      Else
         SA1->(MsSeek(xFilial("SA1")+_cCod+_cLoja))
      EndIf 

      _cVend1  := SA1->A1_VEND
      _cVend2  := Space(6)
      _cVend3  := Space(6)
      _cVend4  := Space(6)
      _cRede   := SA1->A1_GRPVEN 
      _cOperac := _oModelZBC:GetValue('ZBC_OPERAC')

      _oModelZBC:LoadValue('ZBC_NOME'  , SA1->A1_NOME)   
      _oModelZBC:LoadValue('ZBC_FANTAS', SA1->A1_NREDUZ) 
      _oModelZBC:LoadValue('ZBC_EST'   , SA1->A1_EST)    
      _oModelZBC:LoadValue('ZBC_CMUN'  , SA1->A1_COD_MUN)
      _oModelZBC:LoadValue('ZBC_MUN'   , SA1->A1_MUN)    
      _oModelZBC:LoadValue('ZBC_CEP'   , SA1->A1_CEP)    
      _oModelZBC:LoadValue('ZBC_CLENTR', SA1->A1_COD) 
      _oModelZBC:LoadValue('ZBC_LOJAEN', SA1->A1_LOJA) 
      _oModelZBC:LoadValue('ZBC_ENDENT', SA1->A1_ENDENT)  
      _oModelZBC:LoadValue('ZBC_BAIREN', SA1->A1_BAIRROE)
      _oModelZBC:LoadValue('ZBC_DDD'   , SA1->A1_DDD)    
      _oModelZBC:LoadValue('ZBC_TELEFO', SA1->A1_TEL)    
      _oModelZBC:LoadValue('ZBC_VEND1' , SA1->A1_VEND)        //    - Vendedor 
      
      If SA3->(MsSeek(xFilial("SA3")+SA1->A1_VEND))
         _oModelZBC:LoadValue('ZBC_VEND2' , SA3->A3_SUPER)    //   - Coordenador
         _oModelZBC:LoadValue('ZBC_VEND3' , SA3->A3_GEREN)    //   - Gerente
         _oModelZBC:LoadValue('ZBC_VEND4' , SA3->A3_I_SUPE)   //  - Supervisor 
         _cVend2 := SA3->A3_SUPER
         _cVend3 := SA3->A3_GEREN
         _cVend4 := SA3->A3_I_SUPE
      EndIf 

      _cTabPrc := SA1->A1_TABELA 
      If ! Empty(SA1->A1_TABELA)
         _oModelZBC:LoadValue('ZBC_TABPRC', SA1->A1_TABELA)
         _oModelZBC:LoadValue('ZBC_DSCTBP', Posicione("DA0",1,xFilial("DA0")+SA1->A1_TABELA, "DA0_DESCRI"))
      EndIf 

      If ! Empty(SA1->A1_COND)
         _oModelZBC:LoadValue('ZBC_CONDPG', SA1->A1_COND)     //    = Condição de pagamento
      EndIf 
      
      If Empty(_cOperac)
         _cOperac := "01"
      EndIf 

      M->C5_I_OPER  := _cOperac
      M->C5_VEND4   := _cVend4
      M->C5_I_GRPVE := _cRede
      M->C5_FILGCT  := xFilial("ZBC")
      M->C5_I_FILFT := xFilial("ZBC")
      M->C5_VEND3   := _cVend3
      M->C5_VEND2   := _cVend2
      M->C5_VEND1   := _cVend1
      M->C5_CLIENTE := SA1->A1_COD
      M->C5_LOJACLI := SA1->A1_LOJA

      If Empty(_cTabPrc)
         _aTabPrc := U_ITTABPRC(xFilial("SC5"),xFilial("SC5"),_cVend3,_cVend2,_cVend1,SA1->A1_COD,SA1->A1_LOJA,.T.,,_cVend4,_cRede ,  , _cOperac)
         If Len(_aTabPrc) > 1
            _cTabPrc := _aTabPrc[1]
            _oModelZBC:LoadValue('ZBC_TABPRC', _cTabPrc)
            _oModelZBC:LoadValue('ZBC_DSCTBP', Posicione("DA0",1,xFilial("DA0")+_cTabPrc, "DA0_DESCRI"))
         EndIf 
      EndIf 
      
      M->C5_I_TAB   := _cTabPrc

      _cTipoVend := _oModelZBC:GetValue('ZBC_TPVEN') 
      If Empty(_cTipoVend)
         _cTipoVend := "F"
      EndIf   
                           // OMSVLDENT(_ddent,_cclient    ,_cloja      ,_cfilft      ,_cpedido,_nret,_lshow,_cFilCarreg   ,_cOperPedV,_cTipoVenda)
      _dDtEntr := Date() + U_OmsVlDent(Date(),SA1->A1_COD,SA1->A1_LOJA,xFilial("ZBC"), ""    ,1    ,.F.    ,xFilial("ZBC"),_cOperac,_cTipoVend) + 1 
      
      _oModelZBC:LoadValue('ZBC_DTENT', _dDtEntr)
      
      M->C5_I_DTENT := _dDtEntr

      _cPedCom   := _oModelZBC:GetValue('ZBC_PEDCOM')
      _cCliente  := _oModelZBC:GetValue('ZBC_CLIENT') 
      _cLoja     := _oModelZBC:GetValue('ZBC_LOJACL')
      _oModelZBC:LoadValue('ZBC_CHAVE', _cPedCom + _cCliente + _cLoja)

   ElseIf _cCampo == "BOTAO_OK"
       
       If _nOperacao == MODEL_OPERATION_UPDATE
          //ZBE->(DbSetOrder(2))
          //If ZBE->(MsSeek(xFilial("ZBE")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
          ZBF->(DbSetOrder(3))
          If ZBF->(MsSeek(xFilial("ZBF")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL))) //.And. !Empty(ZBF->ZBF_PVPROT)
             Help( ,, 'Atenção',, 'Para este pedido de compras já foi gerado pré pedidos de vendas e não pode ser alterado.', 1, 0 )
             _lRet := .F.
             Break
          EndIf 
       EndIf 
      
       _cOperac   := _oModelZBC:GetValue('ZBC_OPERAC')
       _dDtEntreg := _oModelZBC:GetValue('ZBC_DTENT')
       _cPedCom   := _oModelZBC:GetValue('ZBC_PEDCOM')
       _cCliente  := _oModelZBC:GetValue('ZBC_CLIENT') 
       _cLoja     := _oModelZBC:GetValue('ZBC_LOJACL')
       _cTrocaNf  := _oModelZBC:GetValue('ZBC_TRCNF')
       _cFilCarre := _oModelZBC:GetValue('ZBC_FLFNC')
       _cFilFatur := _oModelZBC:GetValue('ZBC_FILFT')

       If _cTrocaNf == "S" 
          If Empty(_cFilFatur)
             Help( ,, 'Atenção',, 'Este é um pedido de vendas troca Nota Fiscal. O preenchimento da filial de faturamento é obrigatório.', 1, 0 )
             _lRet := .F.
             Break 
          Else 
             _oModelZBC:LoadValue('ZBC_FLFNC', xFilial("ZBC"))
          EndIf 
       Else 
          _oModelZBC:LoadValue('ZBC_FLFNC', "")
          _oModelZBC:LoadValue('ZBC_FILFT', "")
          _oModelZBC:LoadValue('ZBC_TRCNF', "N")
       EndIf 

       _nTotLin := _oModelZBD:Length()
       
       For _nI := 1 To _nTotLin
           _oModelZBD:GoLine( _nI )
           _oModelZBD:LoadValue('ZBD_OPER', _cOperac)
           _oModelZBD:LoadValue('ZBD_ENTREG', _dDtEntreg)
           _oModelZBD:LoadValue('ZBD_PEDCLI', _cPedCom)
           _oModelZBD:LoadValue('ZBD_PEDCOM', _cPedCom)
           _oModelZBD:LoadValue('ZBD_CLIENT', _cCliente)
           _oModelZBD:LoadValue('ZBD_LOJACL', _cLoja)

           _oModelZBD:LoadValue('ZBD_CHAVE', _cPedCom + _cCliente + _cLoja) 

           _nPrcVend := _oModelZBD:GetValue('ZBD_PRCVEN') 
           _nQtd     := _oModelZBD:GetValue('ZBD_QTDVEN')
           _cCod     := _oModelZBD:GetValue('ZBD_PRODUT')
      
           If _nPrcVend == 0 .Or. _nQtd == 0 .Or. Empty(_cCod)
              Help( ,, 'Atenção',, 'O Código de Produto, ou a Qantidade, ou o Preço Unitário de item não foi informado.', 1, 0 )
             _lRet := .F.
             Break 
           EndIf

       Next  

       _oModelZBC:LoadValue('ZBC_CHAVE', _cPedCom + _cCliente + _cLoja)

       _oModelZBD:GoLine( 1 )
       
   ElseIf _cCampo == "VALIDA_LINHA"  
           
      _cPedCompra := _oModelZBC:GetValue('ZBC_PEDCOM')

      If _oModelZBD:IsDeleted() .And. ! Empty(_cPedCompra)
         ZBF->(DbSetOrder(1))
         If ZBF->(MsSeek(xFilial("ZBF")+_cPedCompra))
            Help( ,, 'Atenção',, 'Este produto já está vinculado a um pré-pedido de vendas e não pode ser excluido.', 1, 0 )
            _lRet := .F.
            Break 
         EndIf        
      EndIf 

   EndIf 
   
End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS132W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/01/2022
===============================================================================================================================
Descrição---------: Função usada em dicionário de dados para permitir ou não a edição de campos.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a Funão.
===============================================================================================================================
Retorno-----------: _lRet == .T. = Validação Ok.
                             .F. = não conformidade na validação.
===============================================================================================================================
*/  
User Function AOMS132W(_cCampo)
Local _lRet := .T.
Local _oModel     := FWModelActive()
Local _oModelZBD  := _oModel:GetModel('ZBDDETAIL')
//Local _oModelZBC  := _oModel:GetModel('ZBCMASTER')

Begin Sequence 
   If _cCampo == "ZBD_PRODUT" 
      If _oModelZBD:IsInserted()
         _lRet := .T.
      else
         _lRet := .F.
      EndIf

   EndIf 

End Sequence

Return _lRet 

/*
===============================================================================================================================
Programa----------: AOMS132T
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/01/2022
===============================================================================================================================
Descrição---------: Lista os tipos de veiculos aceitos pelos clientes e suas respectivas quantidades de pallets.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132T()
Local _nQtdPalete
Local _aDados 

Begin Sequence 

   DUT->(DbSetOrder(1)) // DUT_FILIAL+DUT_TIPVEI
   ZBB->(DbSetOrder(1)) // ZBB_FILIAL+ZBB_CLIENT+ZBB_LOJA+ZBB_TPVEIC      
   If ! ZBB->(MsSeek(xFilial("ZBB")+ZBC->ZBC_CLIENT+ZBC->ZBC_LOJACL)) 
      Help( ,, 'Atenção',, 'Não existem tipos de veiculos cadastrados para este cliente.', 1, 0 )
      Break 
   EndIf 
   
   _aDados := {}

   Do While ! ZBB->(Eof()) .And. ZBB->(ZBB_FILIAL+ZBB_CLIENT+ZBB_LOJA) == xFilial("ZBB")+ZBC->ZBC_CLIENT+ZBC->ZBC_LOJACL
      _nQtdPalete := 0  
      If DUT->(MsSeek(xFilial("DUT")+ZBB->ZBB_TPVEIC))
         _nQtdPalete := DUT->DUT_I_QPAL
      EndIf 
      
      Aadd(_aDados,{ZBB->ZBB_CLIENT,ZBB->ZBB_LOJA,ZBB->ZBB_NOMCLI,ZBB->ZBB_TPVEIC,ZBB->ZBB_NOMVEI,_nQtdPalete})

      ZBB->(DbSkip())
   EndDo

   _aTitulos := {"Cliente",;
                 "Loja Cliente",;
                 "Nome Cliente",;
                 "Tipo Veiculo",;
                 "Nome Veiculo",;
                 "Qtde.Pallets"}

   U_ITListBox( 'Lista de Tipos de Veiculos para o Clinte' ,  _aTitulos , _aDados , .T. ,1)

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS132E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/01/2022
===============================================================================================================================
Descrição---------: Efetiva o Pré-Pedido de Vendas. Ou Seja, gera o Pedido de Vendas no Protheus.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132E()
Local _nLinha 
Local _aSizeAut  := MsAdvSize(.T.)
Local _nOpc := 0
Local _lFinalizar := .F. 
Local _cNomeTipoV, _cVeiculo 
Local _cTipoAcao

Private _cTipoVeic  := ""
Private _aTipoVeic  := {}
Private _aDadosVeic := {}
Private _cCodTpVeic := ""
Private _nQtdPalet 
Private aHeader := {}
Private aRotina := {}
Private _nTotPallet := 0, _oTotPallet
Private b2Click 
Private _cColunas   := "6,8" // Colunas editáveis // WK_GERPED , ZBD_UNSVEN , ZBD_QTDVEN
Private _nPaletVeic := 0
Private _oTipoVeic
Private _nTotItZBD  := 0
Private _oGetTRBF 
Private Altera := .T.
Private Inclui := .F.
Private _oBtnGerPr
Private _OBtnEfetiva 
Private _OBtnSair
Private _aDadosZBD 
Private _lJaGerouPV := .F.
Private _lTipoVeic
Private _cFilPedVe

/*
Local _bCond, _cCond

Private CCADASTRO := "Efetiva o Pré-Pedido de Vendas"
Private _oBrowse 
Private aRotina 
*/

/*
   DbSelectArea("ZBE")

   aRotina := {}
   Aadd(aRotina,{"Pesquisar"                      ,"AxPesqui"     ,0,1})
   Aadd(aRotina,{"Visualizar"                     ,"U_AOMS132H()" ,0,2})
   AADD(aRotina,{"Efetivar Pre Pedido"            ,"U_AOMS132P()" ,0,3})
   AADD(aRotina,{"Excluir"	   	                 ,"U_AOMS132R()" ,0,5})

   _bCond := { || ZBC->ZBC_PEDCOM == ZBE_PEDCOM .And. ZBC->ZBC_FILIAL == ZBE_FILIAL }
   _cCond := "ZBC->ZBC_PEDCOM == ZBE_PEDCOM .And. ZBC->ZBC_FILIAL == ZBE_FILIAL"
   
   ZBE->(DBSetFilter( _bCond , _cCond )) 
   
   ZBE->(DbSetOrder(1)) 
   ZBE->(DbGoTop())
      
   MBrowse(6,1,22,75,"ZBE")
*/

Begin Sequence 
   
   ZBF->(DbSetOrder(3))
   If ! ZBF->(MsSeek(xFilial("ZBF")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
      U_ItMsg("Não existes Pre-Pedidos de Vendas Cadastrados para geração de pedidos de vendas no Protheus.","Atenção","",1)
      Break
   EndIf 

   If Empty(ZBF->ZBF_FILGPV)
      U_ItMsg("A filial de geração dos pedidos de vendas não foi informada.","Atenção","Acesse a rotina de manutenção para informar a filial de geração do pedido de vendas.",1)
      Break
   EndIf 
   
   _cFilPedVe := Space(2)

   If ! Empty(ZBF->ZBF_FILGPV)
      _cFilPedVe := ZBF->ZBF_FILGPV
   EndIf 

   //=======================================================================
   // Carrega os itens da tabela ZBD para validação de Quantidades
   //=======================================================================  
   ZBD->(DbSetOrder(1))
   ZBD->(MsSeek(xFilial("ZBD")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
   
   _aDadosZBD := {}
   _nTotPallet := 0

   Do While ! ZBD->(Eof()) .And. ZBD->(ZBD_FILIAL+ZBD_PEDCOM+ZBD_CLIENT+ZBD_LOJACL) == xFilial("ZBD")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)
      Aadd(_aDadosZBD, {ZBD->ZBD_ITEM,;     // Item
                        ZBD->ZBD_PRODUT,;   // Codigo do Produto
                        ZBD->ZBD_DESCRI,;   // Descrição do Produto
                        ZBD->ZBD_UNSVEN,;   // Qtd. Segunda Unidade Med.
                        ZBD->ZBD_SEGUM,;    // Segunda Unidade Medida
                        ZBD->ZBD_QTDVEN,;   // Qtd. Primeira Unidade Medida
                        ZBD->ZBD_UM,;       // Primeira Unidade Medida
                        ZBD->ZBD_PRCVEN,;   // Preço Unitário Liquido
                        ZBD->ZBD_VALOR,;    // Valor Total
                        ZBD->ZBD_QTDPAL})   // Quantidade de Paletes
      
      _nTotPallet += ZBD->ZBD_QTDPAL

      ZBD->(DbSkip())
   EndDo   

 
   //=======================================================================
   // Carrega os dados de capa para exibição da tela.
   //======================================================================= 
   _nPaletVeic  := Posicione("DUT",1,xFilial("DUT")+ZBE->ZBE_TPVEIC,"DUT_I_QPAL") 
   _cNomeTipoV  := Posicione("DUT",1,xFilial("DUT")+ZBE->ZBE_TPVEIC,"DUT_DESCRI")
   _cVeiculo    := ZBE->ZBE_TPVEIC + "-" + _cNomeTipoV
   
   M->ZBC_PEDCOM := ZBC->ZBC_PEDCOM  // C	6	0	Ped.Compras	Pedido de Compras Cliente
   M->ZBC_CLIENT := ZBC->ZBC_CLIENT  // C	6	0	Cliente	Codigo do Cliente
   M->ZBC_LOJACL := ZBC->ZBC_LOJACL  // C	4	0	Loja Cliente	Loja do Cliente
   M->ZBC_NOME   := ZBC->ZBC_NOME 	 // C	60	0	Nome Cliente	Nome Cliente
   M->ZBC_EST    := ZBC->ZBC_EST     // C	2	0	Estado	Estado
   M->ZBC_MUN    := ZBC->ZBC_MUN 	 // C	50	0	Municipio	Municipio
   M->ZBC_CEP    := ZBC->ZBC_CEP  	 // C	8	0	CEP	CEP
   M->ZBC_BAIREN := ZBC->ZBC_BAIREN  // C	50	0	Bairro	Bairro
   M->ZBC_DDD    := ZBC->ZBC_DDD     // C	3	0	DDD	DDD
   M->ZBC_TELEFO := ZBC->ZBC_TELEFO  // C	15	0	Telefone	Telefone
   M->ZBC_OPERAC := ZBC->ZBC_OPERAC  // C	2	0	Tp.Operação 	Tipo de Operação
   M->ZBC_AGENDA := ZBC->ZBC_AGENDA  // C	1	0	Tp Entrega  	Tipo de Entrega
   M->ZBC_TIPO   := ZBC->ZBC_TIPO    // C	1	0	Tipo Pedido 	Tipo de Pedido
   M->ZBC_DTENT  := ZBC->ZBC_DTENT   // D	8	0	Data Entrega	Data de Entrega
   M->ZBC_VEND1  := ZBC->ZBC_VEND1   // C	6	0	Vendedor	Vendedor

   M->ZBC_TRCNF  := If(ZBC->ZBC_TRCNF=="S","Sim","Nao")
   M->ZBC_FLFNC  := ZBC->ZBC_FLFNC 
   M->ZBC_FILFT  := ZBC->ZBC_FILFT
   
   //===============================================================
   // Work com a capa dos Pré Pedidos de Vendas.
   //===============================================================
   _aStruct2 := {}
   Aadd(_aStruct2, {"ZBF_PEDCOM", "C", 20, 0}) // Pedido de Compras
   Aadd(_aStruct2, {"ZBF_SEQ"   , "C", 3 , 0}) // Sequencia
   Aadd(_aStruct2, {"ZBF_AGRUPA", "C", 1 , 0}) // Agrupador
   Aadd(_aStruct2, {"WK_PEDPROT", "C", 6, 0}) // Pedido de Vendas Protheus
   Aadd(_aStruct2, {"WK_PEDPALT", "C", 6, 0}) // Pedido de Paletes 
   Aadd(_aStruct2, {"ZBF_ITEM"  , "C", 2 , 0}) // Item
   Aadd(_aStruct2, {"ZBF_PRODUT", "C", 15, 0}) // Codigo do Produto
   Aadd(_aStruct2, {"ZBF_DESCRI", "C", 50, 0}) // Descrição do Produto
   Aadd(_aStruct2, {"ZBF_UNSVEN", "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct2, {"WK_UNSVEN" , "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct2, {"ZBF_SEGUM" , "C", 2 , 0}) // Segunda Unidade Medida
   Aadd(_aStruct2, {"ZBF_QTDVEN", "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct2, {"WK_QTDVEN" , "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct2, {"ZBF_UM"    , "C", 2 , 0}) // Primeira Unidade Medida
   Aadd(_aStruct2, {"ZBF_PRCVEN", "N", 18, 8}) // Preço Unitário Liquido
   Aadd(_aStruct2, {"ZBF_VALOR" , "N", 12, 2}) // Valor Total
   Aadd(_aStruct2, {"ZBF_LOCAL" , "C", 2 , 0}) // Armazém
   Aadd(_aStruct2, {"ZBF_QTDPAL", "N", 3 , 0}) // Quantidade de Paletes
   Aadd(_aStruct2, {"WK_RECNO"  , "N", 10, 0}) // Recno do Item ZBD
   
   If Select("TRBZBF") > 0
	   TRBZBF->(Dbclosearea())
   EndIf

   _otemp2 := FWTemporaryTable():New("TRBZBF", _aStruct2 )
   _otemp2:AddIndex( "01", {"ZBF_PEDCOM", "ZBF_SEQ" , "ZBF_ITEM"} )
   
   _otemp2:Create()
   
   //==============================================================================
   // Grava os dados da tabela temporaria TRBZBF
   //==============================================================================
   ZBF->(DbSetOrder(3))
   ZBF->(MsSeek(xFilial("ZBF")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
   
   Do While ! ZBF->(Eof()) .And. ZBF->(ZBF_FILIAL+ZBF_PEDCOM+ZBF_CLIENT+ZBF_LOJACL) == xFilial("ZBF")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)
      TRBZBF->(DbAppend())
      TRBZBF->ZBF_PEDCOM   := ZBF->ZBF_PEDCOM   // Pedido de Compras
      TRBZBF->ZBF_SEQ      := ZBF->ZBF_SEQ      // Sequencia
      TRBZBF->ZBF_AGRUPA   := ZBF->ZBF_AGRUPA   // Agrupador
      TRBZBF->ZBF_ITEM     := ZBF->ZBF_ITEM     // Item
      TRBZBF->ZBF_PRODUT   := ZBF->ZBF_PRODUT   // Codigo do Produto
      TRBZBF->ZBF_DESCRI   := ZBF->ZBF_DESCRI   // Descrição do Produto
      TRBZBF->ZBF_UNSVEN   := ZBF->ZBF_UNSVEN   // Qtd. Segunda Unidade Med.
      TRBZBF->WK_UNSVEN    := ZBF->ZBF_UNSVEN   // Qtd. Segunda Unidade Med.
      TRBZBF->ZBF_SEGUM    := ZBF->ZBF_SEGUM    // Segunda Unidade Medida
      TRBZBF->ZBF_QTDVEN   := ZBF->ZBF_QTDVEN   // Qtd. Primeira Unidade Medida
      TRBZBF->WK_QTDVEN    := ZBF->ZBF_QTDVEN   // Qtd. Primeira Unidade Medida
      TRBZBF->ZBF_UM       := ZBF->ZBF_UM       // Primeira Unidade Medida
      TRBZBF->ZBF_PRCVEN   := ZBF->ZBF_PRCVEN   // Preço Unitário Liquido
      TRBZBF->ZBF_VALOR    := ZBF->ZBF_VALOR    // Valor Total
      TRBZBF->ZBF_LOCAL    := ZBF->ZBF_LOCAL    // Armazém
      TRBZBF->ZBF_QTDPAL   := ZBF->ZBF_QTDPAL   // Quantidade de Paletes
      TRBZBF->WK_PEDPROT   := ZBF->ZBF_PVPROT   // Pedido de Vendas Protheus
      TRBZBF->WK_PEDPALT   := ZBF->ZBF_PLPROT   // Pedido de Paletes
      TRBZBF->WK_RECNO     := ZBF->(Recno())    // Recno do Item ZBD
      TRBZBF->(MsUnLock())

      If ! Empty(ZBF->ZBF_PVPROT) 
         _lJaGerouPV := .T.
      EndIf 

      ZBF->(DbSkip())
   EndDo 

   //==============================================================================
   // Monta aHeader do msgetdb.
   //==============================================================================
   Aadd(aHeader,{"Pedido Comparas"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_PEDCOM"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PEDCOM","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PEDCOM","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                                                      0 ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Sequencia"                           ,;   // 1  = X3_TITULO                   3
                 "ZBF_SEQ"                             ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEQ","X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 8                                     ,;   // 4  = X3_TAMANHO // getsx3cache("ZBF_SEQ","X3_TAMANHO")
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Agrupador"                            ,;   // 1  = X3_TITULO                   2
                 "ZBF_AGRUPA"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_AGRUPA","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                                                      10,;   // 4  = X3_TAMANHO            
                                                       0,;   // 5  = X3_DECIMAL
                 getsx3cache("ZBF_AGRUPA","X3_VALID")   ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 getsx3cache("ZBF_AGRUPA","X3_CBOX")    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Nr.Ped.Vendas Protheus"               ,;   // 1  = X3_TITULO                   2
                 "WK_PEDPROT"                           ,;   // 2  = X3_CAMPO
                 "@!"                                   ,;   // 3  = X3_PICTURE                    
                                                      10,;   // 4  = X3_TAMANHO            
                                                       0,;   // 5  = X3_DECIMAL
                                                     "" ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                      })   // 10 = X3_CBOX

    Aadd(aHeader,{"Nr.Ped.Paletes"                            ,;   // 1  = X3_TITULO                   2
                 "WK_PEDPALT"                           ,;   // 2  = X3_CAMPO
                 "@!"                                   ,;   // 3  = X3_PICTURE                    
                                                      10,;   // 4  = X3_TAMANHO            
                                                       0,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Item"                               ,;   // 1  = X3_TITULO                   3
                 "ZBF_ITEM"                            ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_ITEM","X3_PICTURE")  ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_ITEM","X3_TAMANHO")  ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Produto"                             ,;   // 1  = X3_TITULO                4   
                 "ZBF_PRODUT"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRODUT","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRODUT","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Descrição Prod"                      ,;   // 1  = X3_TITULO                 5  
                 "ZBF_DESCRI"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_DESCRI","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_DESCRI","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Qtde Paletes"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_QTDPAL"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDPAL","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDPAL","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDPAL","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "N"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Qtd.Atual.2 Un.Med."                     ,;   // 1  = X3_TITULO                  6 
                 "WK_UNSVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UNSVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UNSVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_UNSVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX 
   Aadd(aHeader,{"Qtd.2 Unid.Med."                     ,;   // 1  = X3_TITULO                  6 
                 "ZBF_UNSVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UNSVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UNSVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_UNSVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX 

   Aadd(aHeader,{"Seg.Unid.Medida"                     ,;  // 1  = X3_TITULO                 7  
                 "ZBF_SEGUM"                           ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEGUM","X3_PICTURE") ,;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_SEGUM" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                    ,;    // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
 
   Aadd(aHeader,{"Qtd.1 Unid Med"                      ,;  // 1  = X3_TITULO                   8
                 "ZBF_QTDVEN"                          ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDVEN","X3_PICTURE"),;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDVEN" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDVEN","X3_DECIMAL"),;    // 5  = X3_DECIMAL
                 ""                                    ,;    // 6  = X3_VALID                 
                                                     "",;    // 7  = X3_USADO
                 "N"                                   ,;    // 8  = X3_TIPO                   
                                                     "",;    // 9  = X3_CONTEXT
                 ""                                    })    // 10 = X3_CBOX

   Aadd(aHeader,{"Qtd.Atual 1 Un Med"                 ,;     // 1  = X3_TITULO                   8
                 "WK_QTDVEN"                          ,;     // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDVEN","X3_PICTURE"),;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDVEN" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDVEN","X3_DECIMAL"),;    // 5  = X3_DECIMAL
                 ""                                    ,;    // 6  = X3_VALID                 
                                                     "",;    // 7  = X3_USADO
                 "N"                                   ,;    // 8  = X3_TIPO                   
                                                     "",;    // 9  = X3_CONTEXT
                 ""                                    })    // 10 = X3_CBOX

   Aadd(aHeader,{"1.Unid.Medida"                       ,;   // 1  = X3_TITULO                  9 
                 "ZBF_UM"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UM" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UM" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Prc.Unitario"                        ,;   // 1  = X3_TITULO                 10  
                 "ZBF_PRCVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRCVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRCVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_PRCVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Valor Total"                         ,;   // 1  = X3_TITULO                11   
                 "ZBF_VALOR"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_VALOR","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_VALOR","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_VALOR","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Armazém"                                ,;   // 1  = X3_TITULO               12    
                 "ZBF_LOCAL"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_LOCAL" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_LOCAL" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                        ,;   // 5  = X3_DECIMAL
                 ""                                       ,;   // 6  = X3_VALID                 
                                                     ""   ,;   // 7  = X3_USADO
                 "C"                                      ,;   // 8  = X3_TIPO                   
                                                     ""   ,;   // 9  = X3_CONTEXT
                 ""                                       })   // 10 = X3_CBOX

   //======================================================
   // Configurações iniciais
   //======================================================
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 

   aRotina := {}   
   AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"		,"AxExclui",0,5})
   Inclui := .F.
   Altera := .T.
   
   //_bGerPrePd := {|| Processa( {|| U_AOMS132D() , _oDlgManut:End()} , 'Aguarde!' , 'Gerando Pré Pedido de Vendas...' )}
   _lTipoVeic := .F.
   
   _cTipoAcao := "Tela de Efetivação"

   If _lJaGerouPV
      _cTipoAcao := "Tela de Visualização" 
      U_ItMsg("Pre-Pedidos de Vendas já efetivados. Tela de visualização.","Atenção","",1)
   EndIf 

   Do While .T. 
      TRBZBF->(DbGoTop())

      DEFINE MSDIALOG _oDlgEfet TITLE "Efetivação dos Pré Pedido de Vendas - " + _cTipoAcao  FROM _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] PIXEL // 00,00 TO 300,400

          @ _aPosObj[2,3]-30, 05  BUTTON _OBtnEfetiva PROMPT "&Efetivar Pre Pedido"  SIZE 70, 012 OF _oDlgEfet ACTION ( U_AOMS132P() ) PIXEL
          @ _aPosObj[2,3]-30, 90  BUTTON _OBtnSair  PROMPT "&Sair"	 SIZE 50, 012 OF _oDlgEfet ACTION ( (_nOpc := 0, _lFinalizar := .T. ,_oDlgEfet:End()) ) PIXEL

          If _lJaGerouPV
             _OBtnEfetiva:Disable()
          EndIf 

          _nLinha := 15
          @ _nLinha, 10 Say "Ped.Compras"	Pixel Size  030,012 Of _oDlgEfet
          @ _nLinha, 60 MSGet M->ZBC_PEDCOM  Pixel Size 040,012 WHEN .F. Of _oDlgEfet
     
          @ _nLinha, 115 Say "Tipo de Veiculo"	Pixel Size 040,012 Of _oDlgEfet
          @ _nLinha, 170 MSGet _cVeiculo  Pixel Size 130,012 WHEN .F. Of _oDlgEfet
         // @ _nLinha, 170 MSCOMBOBOX _oTipoVeic Var _cTipoVeic ITEMS _aTipoVeic Valid(U_AOMS132Z("TIPO_VEICULO")) Pixel Size 160, 012 Of _oDlgEfet 

          @ _nLinha, 320 Say "Filial para Geração Ped.Venda"	Pixel Size 050,022 Of _oDlgEfet
          @ _nLinha, 375 MSGet _cFilPedVe  Pixel Size 20,012 WHEN .F. Of _oDlgEfet 
   
          @ _nLinha, 406 Say "Total Pallets Veiculo:"	Pixel Size  080,012 Of _oDlgEfet
          @ _nLinha, 465 MSGet _nPaletVeic Pixel Size 040,012 WHEN .F. Of _oDlgEfet
      
          @ _nLinha, 520 Say "Total de Pallets do Pedido:"	Pixel Size  080,012 Of _oDlgEfet
          @ _nLinha, 590 MSGet _oTotPallet Var _nTotPallet Pixel Size 040,012 WHEN .F. Of _oDlgEfet

//=========================================================================================================
          _nLinha += 20
          @ _nLinha, 10 Say "Troca Nota"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 60 MSGet M->ZBC_TRCNF Pixel Size 040,012 WHEN .F. Of _oDlgEfet

          @ _nLinha, 115 Say "Filial Faturamento"	Pixel Size 040,020 Of _oDlgEfet
          @ _nLinha, 170 MSGet M->ZBC_FLFNC Pixel Size 040,009 WHEN .F. Of _oDlgEfet

          @ _nLinha, 255 Say "Filial Carregamento"	Pixel Size 040,020 Of _oDlgEfet
          @ _nLinha, 305 MSGet M->ZBC_FILFT Pixel Size 100,012 WHEN .F. Of _oDlgEfet
//=========================================================================================================      

          _nLinha += 20
          @ _nLinha, 10 Say "Cliente"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 60 MSGet M->ZBC_CLIENT Pixel Size 040,012 WHEN .F. Of _oDlgEfet

          @ _nLinha, 115 Say "Loja Cliente"	Pixel Size 040, 012 Of _oDlgEfet
          @ _nLinha, 170 MSGet M->ZBC_LOJACL Pixel Size 040,009 WHEN .F. Of _oDlgEfet

          @ _nLinha, 255 Say "Nome Cliente"	Pixel Size 040,012 Of _oDlgEfet
          @ _nLinha, 305 MSGet M->ZBC_NOME Pixel Size 100,012 WHEN .F. Of _oDlgEfet
        
          _nLinha += 20

          @ _nLinha, 10 Say "Estado"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 60 MSGet M->ZBC_EST Pixel Size 040,012 WHEN .F. Of _oDlgEfet

          @ _nLinha, 115 Say "Municipio"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 170 MSGet M->ZBC_MUN Pixel Size 060,012 WHEN .F. Of _oDlgEfet

          @ _nLinha, 255 Say "CEP"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 305 MSGet M->ZBC_CEP Pixel Size 040,012 WHEN .F. Of _oDlgEfet
        
          @ _nLinha, 375 Say "Bairro"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 415 MSGet M->ZBC_BAIREN Pixel Size 080,012 WHEN .F. Of _oDlgEfet
        
          _nLinha += 20

          @ _nLinha, 10 Say "DDD"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 60 MSGet M->ZBC_DDD Pixel Size 040,012 WHEN .F. Of _oDlgEfet

          @ _nLinha, 115 Say "Telefone"	Pixel Size 030,012 Of _oDlgEfet
          @ _nLinha, 170 MSGet M->ZBC_TELEFO Pixel Size 040,012 WHEN .F. Of _oDlgEfet

          @ _nLinha, 255 Say "Tp.Operação"	Pixel Size 040,012 Of _oDlgEfet
          @ _nLinha, 305 MSGet M->ZBC_OPERAC Pixel Size 040,012 WHEN .F. Of _oDlgEfet

          @ _nLinha, 375 Say "Tipo Pedido"	Pixel Size 040,012 Of _oDlgEfet
          @ _nLinha, 415 MSGet M->ZBC_TIPO Pixel Size 040,012 WHEN .F. Of _oDlgEfet

          //_nLinha += 20

          @ _nLinha, 475 Say "Data Entrega"	Pixel Size 040,012 Of _oDlgEfet
          @ _nLinha, 515 MSGet M->ZBC_DTENT Pixel Size 040,012 WHEN .F. Of _oDlgEfet
        
          @ _nLinha, 570 Say "Vendedor"	Pixel Size 040,012 Of _oDlgEfet
          @ _nLinha, 605 MSGet M->ZBC_VEND1 Pixel Size 040,012 WHEN .F. Of _oDlgEfet
          _nLinha += 20

                //MsGetDB():New ( < nTop>, < nLeft>, < nBottom>       , < nRight>         ,< nOpc>, [ cLinhaOk]             , [ cTudoOk]            ,[ cIniCpos], [ lDelete] , [ aAlter]      , [ nFreeze], [ lEmpty], [ uPar1], < cTRB>  , [ cFieldOk]            , [ uPar2], [ lAppend], [ oWnd] , [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] ) --> oObj
          _oGetTRBF := MsGetDB():New (_nLinha, 0       , _aPosObj[2,3]-50 , _aPosObj[2,4]     , 4     , "U_AOMS132O('LINHAOK_MANUT')" , "U_AOMS132O('TUDOOK_MANUT')", ""         , .F.       , {}             , 0         , .F.       ,        , "TRBZBF" , "U_AOMS132O('FIELDOK_MANUT')",         , .F.       , _oDlgEfet, .F.) //         ,         ,""        , "")
       
          //b2Click := _oGetTRBF:oBrowse:bLDblClick
          // _oGetTRBF:oBrowse:bLDblClick := { || U_AOMS132Y("TRBZBD" , TRBZBD->WK_GERPED) }

          //_oGetTRBF:oBrowse:bAdd := {||.T.} // não inclui novos itens MsGetDb()
          _oGetTRBF:Enable( ) 
          
          If _lTipoVeic 
             _oTipoVeic:Disable()  
          EndIf 
          
          TRBZBF->(DbGoTop())
          _oGetTRBF:ForceRefresh( )

      ACTIVATE MSDIALOG _oDlgEfet CENTERED
    
      If _lFinalizar
         Exit 
      EndIf 

   EndDo  

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS132Z
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/02/2022
===============================================================================================================================
Descrição---------: Valida a digitação dos Pré Pedidos de Vendas.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a validação.
===============================================================================================================================
Retorno-----------: _lRet  = .T. = Campo validado.
                           = .F. = Campo não validado.
===============================================================================================================================
*/  
User Function AOMS132Z(_cCampo)
Local _lRet := .T.
Local _nI
Local _nQtdPalet

Begin Sequence 

   If _cCampo == "ZBD_UNSVEN" // quantidade segunda unidade de medida 
      
      _nTotPallet -= TRBZBD->ZBD_QTDPAL

      _nQtd2    := M->ZBD_UNSVEN
      _nPrcVend := TRBZBD->ZBD_PRCVEN
                   
      If _nQtd2 == 0
         Break 
      EndIf 

      _cCod := TRBZBD->ZBD_PRODUT
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial("SB1")+_cCod))
      
      If SB1->B1_TIPCONV == "M"
         _nQtd  := _nQtd2 / SB1->B1_CONV   
      Else
         _nQtd  := _nQtd2 * SB1->B1_CONV
      EndIf
      
      TRBZBD->ZBD_QTDVEN := _nQtd

   	_nCXPalet  :=	SB1->B1_I_CXPAL
      _nQtdPalet := 0 

      If _nCXPalet <> 0

	      If mod(_nQtd2, _nCXPalet) > 0

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) + 1 		

	      Else

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) 

	      EndIf

      EndIf
      
      _nValorTot := _nPrcVend * _nQtd 
      
      TRBZBD->ZBD_QTDPAL := _nQtdPalet
      TRBZBD->ZBD_VALOR  := _nValorTot
      _nTotPallet += TRBZBD->ZBD_QTDPAL
      _oTotPallet:Refresh()

   ElseIf _cCampo == "ZBD_QTDVEN"  // quantidade primeira unidade
     
      _nTotPallet -= TRBZBD->ZBD_QTDPAL
     
      _nQtd     := M->ZBD_QTDVEN
      _nPrcVend := TRBZBD->ZBD_PRCVEN
      _nQtd2    := TRBZBD->ZBD_UNSVEN

      If _nQtd == 0
         U_ItMsg("No preenchimento da quantidade do item na primeira unidade de medida é obritório.","Atenção","",1)
         _lRet := .F.
         Break 
      EndIf 

      _cCod     := TRBZBD->ZBD_PRODUT
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial("SB1")+_cCod))
      
      If SB1->B1_TIPCONV == "M"
         _nQtd2 := _nQtd * SB1->B1_CONV  
      Else
         _nQtd2  := _nQtd / SB1->B1_CONV
      EndIf
      
      TRBZBD->ZBD_UNSVEN := _nQtd2
      
      _nCXPalet  :=	SB1->B1_I_CXPAL
      _nQtdPalet := 0 

      If _nCXPalet <> 0

	      If mod(_nQtd2, _nCXPalet) > 0

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) + 1 		

	      Else

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) 

	      EndIf

      EndIf
    
      _nValorTot := _nPrcVend * _nQtd 

      TRBZBD->ZBD_QTDPAL := _nQtdPalet
      TRBZBD->ZBD_VALOR  := _nValorTot
      _nTotPallet += TRBZBD->ZBD_QTDPAL
      _oTotPallet:Refresh()

   ElseIf _cCampo == "TIPO_VEICULO" 

      _nI := Ascan(_aTipoVeic, _cTipoVeic)
      If _nI > 0 
         _nPaletVeic  := _aDadosVeic[_nI,3]
         _cCodTpVeic  := _aDadosVeic[_nI,1]
      EndIf 

   ElseIf _cCampo == "LINHAOK" .Or. _cCampo == "TUDOOK" //.Or. _cCampo ==  "FIELDOK"

   ElseIf _cCampo == "GRAVAR"
      
      TRBZBF->(DbGoTop())
      If TRBZBF->(Eof()) .Or. TRBZBF->(Bof())
         U_ItMsg("Não há dados para gravação do Pré-Pedido de Vendas.","Atenção","",1)
         _lRet := .F.
         Break 
      EndIf 

   EndIf

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS132Y
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/02/2022
===============================================================================================================================
Descrição---------: Marca ou desmarca no clique/espaço
===============================================================================================================================
Parametros--------: _ctab     - Alias dos dados
					     _cStatus - se marca ou desmarca itens
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132Y(_cTab,_cStatus)

Begin Sequence 

   If AllTrim(Str(_oGetDB:oBrowse:nColPos,2)) $ _cColunas//Colunas editaveis 8 , 9 , 10 
      If (_cTab)->WK_GERPED = "LBOK"
         Break  // Return Eval(b2Click)
      EndIf
   EndIf 
   
   If _cStatus = "LBNO" // Space(2)
      _nTotPallet += TRBZBD->ZBD_QTDPAL
	   (_cTab)->WK_GERPED := "LBOK"
   Else
      _nTotPallet -= TRBZBD->ZBD_QTDPAL
	   (_cTab)->WK_GERPED := "LBNO"
   EndIf

   _oTotPallet:Refresh()

End Sequence 

Return EVAL(b2Click)

/*
===============================================================================================================================
Programa----------: AOMS132H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/01/2022
===============================================================================================================================
Descrição---------: Visualização dos dados do Pré-Pedido de Vendas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132H()
Local _aStruct 
Local _nLinha 
Local _aSizeAut  := MsAdvSize(.T.)
Local _nOpc := 0
Local _cNomeTipoV

Private _cTipoVeic  := ""
Private _aTipoVeic  := {}
Private _aDadosVeic := {}
Private _cCodTpVeic := ""
Private _nQtdPalet 
Private aHeader := {}
Private aRotina := {}
Private _nTotPallet := 0, _oTotPallet
Private b2Click 
Private _cColunas   := "6,8" 
Private _nPaletVeic := 0

Begin Sequence 
    
   M->ZBE_PEDCOM := ZBE->ZBE_PEDCOM  // C	6	0	Ped.Compras	Pedido de Compras Cliente
   M->ZBE_CLIENT := ZBE->ZBE_CLIENT  // C	6	0	Cliente	Codigo do Cliente
   M->ZBE_LOJACL := ZBE->ZBE_LOJACL  // C	4	0	Loja Cliente	Loja do Cliente
   M->ZBE_NOME   := ZBE->ZBE_NOME 	 // C	60	0	Nome Cliente	Nome Cliente
   M->ZBE_EST    := ZBE->ZBE_EST     // C	2	0	Estado	Estado
   M->ZBE_MUN    := ZBE->ZBE_MUN 	 // C	50	0	Municipio	Municipio
   M->ZBE_CEP    := ZBE->ZBE_CEP  	 // C	8	0	CEP	CEP
   M->ZBE_BAIREN := ZBE->ZBE_BAIREN  // C	50	0	Bairro	Bairro
   M->ZBE_DDD    := ZBE->ZBE_DDD     // C	3	0	DDD	DDD
   M->ZBE_TELEFO := ZBE->ZBE_TELEFO  // C	15	0	Telefone	Telefone
   M->ZBE_OPERAC := ZBE->ZBE_OPERAC  // C	2	0	Tp.Operação 	Tipo de Operação
   M->ZBE_AGENDA := ZBE->ZBE_AGENDA  // C	1	0	Tp Entrega  	Tipo de Entrega
   M->ZBE_TIPO   := ZBE->ZBE_TIPO    // C	1	0	Tipo Pedido 	Tipo de Pedido
   M->ZBE_DTENT  := ZBE->ZBE_DTENT   // D	8	0	Data Entrega	Data de Entrega
   M->ZBE_VEND1  := ZBE->ZBE_VEND1   // C	6	0	Vendedor	Vendedor
   M->ZBE_TPVEIC := ZBE->ZBE_TPVEIC  // Tipo de Veiculo
   M->ZBE_PVPROT := ZBE->ZBE_PVPROT  // Numero do pedido de vendas Protheus 
   M->ZBE_PLPROT := ZBE->ZBE_PLPROT  // Numero do Peidod de Paletes

   M->ZBE_TRCNF  := If(ZBE->ZBE_TRCNF=="S","Sim","Nao")
   M->ZBE_FLFNC  := ZBE->ZBE_FLFNC 
   M->ZBE_FILFT  := ZBE->ZBE_FILFT
   
   _aStruct := {}
   Aadd(_aStruct, {"ZBF_SEQ"   , "C", 3 , 0}) // Sequencia
   Aadd(_aStruct, {"ZBF_AGRUPA", "C", 1 , 0}) // Agrupador
   Aadd(_aStruct, {"ZBF_ITEM"  , "C", 2 , 0}) // Item
   Aadd(_aStruct, {"ZBF_PRODUT", "C", 15, 0}) // Codigo do Produto
   Aadd(_aStruct, {"ZBF_DESCRI", "C", 50, 0}) // Descrição do Produto
   Aadd(_aStruct, {"ZBF_UNSVEN", "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct, {"ZBF_SEGUM" , "C", 2 , 0}) // Segunda Unidade Medida
   Aadd(_aStruct, {"ZBF_QTDVEN", "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct, {"ZBF_UM"    , "C", 2 , 0}) // Primeira Unidade Medida
   Aadd(_aStruct, {"ZBF_PRCVEN", "N", 18, 8}) // Preço Unitário Liquido
   Aadd(_aStruct, {"ZBF_VALOR" , "N", 12, 2}) // Valor Total
   Aadd(_aStruct, {"ZBF_LOCAL" , "C", 2 , 0}) // Armazém
   Aadd(_aStruct, {"ZBF_QTDPAL", "N", 3 , 0}) // Quantidade de Paletes
   Aadd(_aStruct, {"WK_RECNO"  , "N", 10, 0}) // Quantidade de Paletes
   
   If Select("TRBZBF") > 0
	   TRBZBF->(Dbclosearea())
   EndIf

   _otemp := FWTemporaryTable():New("TRBZBF", _aStruct )
   _otemp:AddIndex( "01", {"ZBF_SEQ" , "ZBF_ITEM" , "ZBF_PRODUT"} )
   
   _otemp:Create()

   DBSelectArea( "TRBZBF" )

   ZBF->(DbSetOrder(1))	//  ZBF_FILIAL+ZBF_PEDCOM+ZBF_SEQ+ZBF_CLIENT+ZBF_LOJACL+ZBF_PRODUT+ZBF_ITEM 
   ZBF->(MsSeek(ZBE->(ZBE_FILIAL+ZBE_PEDCOM+ZBE_SEQ+ZBE_CLIENT+ZBE_LOJACL)))
   Do While ! ZBF->(Eof()) .And. ZBE->(ZBE_FILIAL+ZBE_PEDCOM+ZBE_SEQ+ZBE_CLIENT+ZBE_LOJACL) == ZBF->(ZBF_FILIAL+ZBF_PEDCOM+ZBF_SEQ+ZBF_CLIENT+ZBF_LOJACL)
      
      TRBZBF->(DbAppend())
      TRBZBF->ZBF_SEQ      := ZBF->ZBF_SEQ    // Sequencia
      TRBZBF->ZBF_AGRUPA   := ZBF->ZBF_AGRUPA // Agrupador
      TRBZBF->ZBF_ITEM     := ZBF->ZBF_ITEM   // Item
      TRBZBF->ZBF_PRODUT   := ZBF->ZBF_PRODUT // Codigo do Produto
      TRBZBF->ZBF_DESCRI   := ZBF->ZBF_DESCRI // Descrição do Produto
      TRBZBF->ZBF_UNSVEN   := ZBF->ZBF_UNSVEN // Qtd. Segunda Unidade Med.
      TRBZBF->ZBF_SEGUM    := ZBF->ZBF_SEGUM  // Segunda Unidade Medida
      TRBZBF->ZBF_QTDVEN   := ZBF->ZBF_QTDVEN // Qtd. Primeira Unidade Medida
      TRBZBF->ZBF_UM       := ZBF->ZBF_UM     // Primeira Unidade Medida
      TRBZBF->ZBF_PRCVEN   := ZBF->ZBF_PRCVEN // Preço Unitário Liquido
      TRBZBF->ZBF_VALOR    := ZBF->ZBF_VALOR  // Valor Total
      TRBZBF->ZBF_LOCAL    := ZBF->ZBF_LOCAL  // Armazém
      TRBZBF->ZBF_QTDPAL   := ZBF->ZBF_QTDPAL // Quantidade de Paletes
      TRBZBF->WK_RECNO     := ZBF->(Recno())  // Recno da tabela ZBF
      TRBZBF->(MsUnlock())

      ZBF->(DbSkip())
   EndDo 
  /* 
   Aadd(aHeader,{"Selecionado?"                        ,;   // 1  = X3_TITULO                   1
                 "WK_GERPED"                           ,;   // 2  = X3_CAMPO
                 "@BMP"                                ,;   // 3  = X3_PICTURE                    
                 1                                     ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 "S=SIM;N=NAO"                         })   // 10 = X3_CBOX
*/
  
  Aadd(aHeader,{"Agrupador"                            ,;    // 1  = X3_TITULO                   2
                 "ZBF_AGRUPA"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_AGRUPA","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                                                      10,;   // 4  = X3_TAMANHO            
                                                       0,;   // 5  = X3_DECIMAL
                 getsx3cache("ZBF_AGRUPA","X3_VALID")   ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX  

   Aadd(aHeader,{"Sequencia"                           ,;   // 1  = X3_TITULO                   3
                 "ZBF_SEQ"                             ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEQ","X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 8                                     ,;   // 4  = X3_TAMANHO // getsx3cache("ZBF_SEQ","X3_TAMANHO")
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Qtde Paletes"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_QTDPAL"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDPAL","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDPAL","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDPAL","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "N"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Item"                               ,;   // 1  = X3_TITULO                   3
                 "ZBF_ITEM"                            ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_ITEM","X3_PICTURE")  ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_ITEM","X3_TAMANHO")  ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Produto"                             ,;   // 1  = X3_TITULO                4   
                 "ZBF_PRODUT"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRODUT","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRODUT","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Descrição Prod"                      ,;   // 1  = X3_TITULO                 5  
                 "ZBF_DESCRI"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_DESCRI","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_DESCRI","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Qtd.2 Unid.Med."                     ,;   // 1  = X3_TITULO                  6 
                 "ZBF_UNSVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UNSVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UNSVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_UNSVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX 

   Aadd(aHeader,{"Seg.Unid.Medida"                     ,;  // 1  = X3_TITULO                 7  
                 "ZBF_SEGUM"                           ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEGUM","X3_PICTURE") ,;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_SEGUM" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                    ,;    // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
 
   Aadd(aHeader,{"Qtd.1 Unid Med"                      ,;  // 1  = X3_TITULO                   8
                 "ZBF_QTDVEN"                          ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDVEN","X3_PICTURE"),;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDVEN" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDVEN","X3_DECIMAL"),;    // 5  = X3_DECIMAL
                 ""                                    ,;    // 6  = X3_VALID                 
                                                     "",;    // 7  = X3_USADO
                 "N"                                   ,;    // 8  = X3_TIPO                   
                                                     "",;    // 9  = X3_CONTEXT
                 ""                                    })    // 10 = X3_CBOX
   
   Aadd(aHeader,{"1.Unid.Medida"                       ,;   // 1  = X3_TITULO                  9 
                 "ZBF_UM"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UM" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UM" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Prc.Unitario"                        ,;   // 1  = X3_TITULO                 10  
                 "ZBF_PRCVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRCVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRCVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_PRCVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Valor Total"                         ,;   // 1  = X3_TITULO                11   
                 "ZBF_VALOR"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_VALOR","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_VALOR","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_VALOR","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Armazém"                                ,;   // 1  = X3_TITULO               12    
                 "ZBF_LOCAL"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_LOCAL" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_LOCAL" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                        ,;   // 5  = X3_DECIMAL
                 ""                                       ,;   // 6  = X3_VALID                 
                                                     ""   ,;   // 7  = X3_USADO
                 "C"                                      ,;   // 8  = X3_TIPO                   
                                                     ""   ,;   // 9  = X3_CONTEXT
                 ""                                       })   // 10 = X3_CBOX
      
   //======================================================
   // Configurações iniciais
   //======================================================
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 

   aRotina := {}   
   AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"		,"AxExclui",0,5})
   Inclui := .F.
   Altera := .T.
   
   _nQtdPalet  := Posicione("DUT",1,xFilial("DUT")+ZBE->ZBE_TPVEIC,"DUT_I_QPAL")
   _cNomeTipoV := Posicione("DUT",1,xFilial("DUT")+ZBE->ZBE_TPVEIC,"DUT_DESCRI")

   TRBZBF->(DbGoTop())

    DEFINE MSDIALOG _oDlgPre TITLE "Visualiza Pré Pedido de Vendas" FROM _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] PIXEL // 00,00 TO 300,400
        
        //@ _aPosObj[2,3]-30, 05 BUTTON _OButtonGrv PROMPT "&Gravar" SIZE 50, 012 OF _oDlgPre ACTION ( If(U_AOMS132Z("TUDOOK"),(_nOpc := 1,_oDlgPre:End()),_nOpc := 0)) PIXEL
        @ _aPosObj[2,3]-30, 05 BUTTON _OButtonGrv PROMPT "&Sair"	 SIZE 50, 012 OF _oDlgPre ACTION ( (_nOpc := 0,_oDlgPre:End()) ) PIXEL

        _nLinha := 15
        @ _nLinha, 10 Say "Ped.Compras"	Pixel Size  040,012 Of _oDlgPre
        @ _nLinha, 60 MSGet M->ZBE_PEDCOM  Pixel Size 040,012 WHEN .F. Of _oDlgPre
     
        @ _nLinha, 115 Say "Tipo de Veiculo"	Pixel Size 040,012 Of _oDlgPre
        @ _nLinha, 170 MSGet M->ZBE_TPVEIC  Pixel Size 130,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 255 Say "Descrição Veiculo:"	Pixel Size  080,012 Of _oDlgPre
        @ _nLinha, 305 MSGet _cNomeTipoV Pixel Size 110,012 WHEN .F. Of _oDlgPre
      
        @ _nLinha, 425 Say "Total Pallets Veiculo:"	Pixel Size  080,012 Of _oDlgPre
        @ _nLinha, 485 MSGet _nQtdPalet Pixel Size 040,012 WHEN .F. Of _oDlgPre

//=========================================================================================================
        _nLinha += 20
        @ _nLinha, 10 Say "Troca Nota"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 60 MSGet M->ZBE_TRCNF Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 115 Say "Filial Faturamento"	Pixel Size 040, 020 Of _oDlgPre
        @ _nLinha, 170 MSGet M->ZBE_FLFNC Pixel Size 040,009 WHEN .F. Of _oDlgPre

        @ _nLinha, 255 Say "Filial Carregamento"	Pixel Size 040,020 Of _oDlgPre
        @ _nLinha, 305 MSGet M->ZBE_FILFT Pixel Size 100,012 WHEN .F. Of _oDlgPre
//=========================================================================================================      

        _nLinha += 20
        @ _nLinha, 10 Say "Cliente"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 60 MSGet M->ZBE_CLIENT Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 115 Say "Loja Cliente"	Pixel Size 040, 012 Of _oDlgPre
        @ _nLinha, 170 MSGet M->ZBE_LOJACL Pixel Size 040,009 WHEN .F. Of _oDlgPre

        @ _nLinha, 255 Say "Nome Cliente"	Pixel Size 040,012 Of _oDlgPre
        @ _nLinha, 305 MSGet M->ZBE_NOME Pixel Size 100,012 WHEN .F. Of _oDlgPre
        
        _nLinha += 20

        @ _nLinha, 10 Say "Estado"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 60 MSGet M->ZBE_EST Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 115 Say "Municipio"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 170 MSGet M->ZBE_MUN Pixel Size 060,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 255 Say "CEP"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 305 MSGet M->ZBE_CEP Pixel Size 040,012 WHEN .F. Of _oDlgPre
        
        @ _nLinha, 425 Say "Bairro"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 465 MSGet M->ZBE_BAIREN Pixel Size 080,012 WHEN .F. Of _oDlgPre
        
        _nLinha += 20

        @ _nLinha, 10 Say "DDD"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 60 MSGet M->ZBE_DDD Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 115 Say "Telefone"	Pixel Size 030,012 Of _oDlgPre
        @ _nLinha, 170 MSGet M->ZBE_TELEFO Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 255 Say "Tp.Operação"	Pixel Size 040,012 Of _oDlgPre
        @ _nLinha, 305 MSGet M->ZBE_OPERAC Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 425 Say "Tipo Pedido"	Pixel Size 040,012 Of _oDlgPre
        @ _nLinha, 465 MSGet M->ZBE_TIPO Pixel Size 040,012 WHEN .F. Of _oDlgPre

        _nLinha += 20

        @ _nLinha, 10 Say "Data Entrega"	Pixel Size 040,012 Of _oDlgPre
        @ _nLinha, 60 MSGet M->ZBE_DTENT Pixel Size 040,012 WHEN .F. Of _oDlgPre
        
        @ _nLinha, 115 Say "Vendedor"	Pixel Size 040,012 Of _oDlgPre
        @ _nLinha, 170 MSGet M->ZBE_VEND1 Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 255 Say "Nr.Pedido Vendas"	Pixel Size 060,012 Of _oDlgPre
        @ _nLinha, 305 MSGet M->ZBE_PVPROT Pixel Size 040,012 WHEN .F. Of _oDlgPre

        @ _nLinha, 420 Say "Nr.Pedido Paletes"	Pixel Size 040,012 Of _oDlgPre
        @ _nLinha, 465 MSGet M->ZBE_PLPROT Pixel Size 040,012 WHEN .F. Of _oDlgPre
        _nLinha += 30

                //MsGetDB():New ( < nTop>, < nLeft>, < nBottom>       , < nRight> ,< nOpc>, [ cLinhaOk]             , [ cTudoOk]            ,[ cIniCpos], [ lDelete], [ aAlter]                     , [ nFreeze], [ lEmpty], [ uPar1], < cTRB>  , [ cFieldOk]            , [ uPar2], [ lAppend], [ oWnd] , [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] ) --> oObj
       _oGetDB := MsGetDB():New (_nLinha, 0 , _aPosObj[2,3]-40 , _aPosObj[2,4]    , 4     , ".T." , ".T.", ""         , .F.       , {} , 0         , .F.      ,         , "TRBZBF" , ".T.",         , .F.       , _oDlgPre, .T.) //         ,         ,""        , "")
       
       b2Click := _oGetDB:oBrowse:bLDblClick
       _oGetDB:oBrowse:bLDblClick := { || U_AOMS132Y("TRBZBF" , TRBZBF->WK_GERPED) }

       _oGetDB:oBrowse:bAdd := {||.F.} // não inclui novos itens MsGetDb()
       _oGetDB:Enable( ) 

       TRBZBF->(DbGoTop())
       _oGetDB:ForceRefresh ( )

    ACTIVATE MSDIALOG _oDlgPre CENTERED

End Sequence 

If Select("TRBZBF") > 0
   TRBZBF->(Dbclosearea())
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS132S
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/01/2022
===============================================================================================================================
Descrição---------: Retorna a próxima sequencia do Pré Pedido de Vendas.
===============================================================================================================================
Parametros--------: _cCodFilial = Filial do Pedido de Compras do Cliente
                    _cPedCompra = Pedido de Compras do Cliente
                    _cCliente   = Código do cliente
                    _cLojaCli   = Loja do Cliente
===============================================================================================================================
Retorno-----------: _cRet = Próxima sequencia do Pré Pedido de Compras.
===============================================================================================================================
*/  
User Function AOMS132S(_cCodFilial, _cPedCompra, _cCliente, _cLojaCli)
Local _cRet := "00"
Local _nSeq := 0 

Begin Sequence 
   
   ZBE->(DbSetOrder(1)) // ZBE_FILIAL+ZBE_PEDCOM+ZBE_SEQ+ZBE_CLIENT+ZBE_LOJACL
   ZBE->(MsSeek(_cCodFilial+_cPedCompra))

   Do While ! ZBE->(Eof()) .And. _cCodFilial+_cPedCompra ==  ZBE->(ZBE_FILIAL+ZBE_PEDCOM)
      If _cCliente+_cLojaCli == ZBE->(ZBE_CLIENT+ZBE_LOJACL)
         _nSeq += 1
      EndIf 

      ZBE->(DbSkip())
   EndDo 

   _nSeq += 1

   _cRet := StrZero(_nSeq, 2)

End Sequence

Return _cRet 

/*
===============================================================================================================================
Programa----------: AOMS132H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/01/2022
===============================================================================================================================
Descrição---------: Efetiva um pré pedido de vendas. Gera um novo Pedido de Vendas no Protheus(SC5 e SC6).
                    E abate os saldos dos pedido de compras do cliente principal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132P()
Local _aItensPV,_aItemPV 
Local _aCabPV 
Local _nTotPalete := 0
Local _aAgrupaPV, _nI
Local _aPVPorGrp, _aPVPorSeq
Local _cAgrupa, _aRecnoZBF 
Local _cSequen 
Local _lGerouPV := .F.

Begin Sequence 
   
   ZBF->(DbSetOrder(3))
   ZBF->(MsSeek(ZBC->(ZBC_FILIAL+ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))

   Do While ! ZBF->(Eof()) .And. ZBF->(ZBF_FILIAL+ZBF_PEDCOM+ZBF_CLIENT+ZBF_LOJACL) == ZBC->(ZBC_FILIAL+ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)
      If !Empty(ZBF->ZBF_PVPROT)
         U_ITMSG("Já existe o Pedido de Vendas [" + ZBF->ZBF_PVPROT+",...] gerado para este pedido de compras." ,"Atenção",,1)
         Break
      EndIf

      ZBF->(DbSkip())
   EndDo

   If ! U_ItMsg("Confirma a efetivação dos Pré Pedidos de Vendas?" ,"Atenção", , ,2, 2)
      Break
   EndIf 

   ZBE->(DbSetOrder(2))
   ZBE->(MsSeek(ZBC->(ZBC_FILIAL+ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))

   //=================================================================
   // Monta os arrays de inclusão de dados com MSEXECAUTO.
   // Capa do Pedido de Vendas
   //=================================================================
   _aCabPV := {} 
   Aadd( _aCabPV, { "C5_FILIAL"   , ZBE->ZBE_FILGPV , NiL})  // Filial  // ZBE_FILIAL
   Aadd( _aCabPV, { "C5_CLIENTE"  , ZBE->ZBE_CLIENT , NiL})  // Cliente
   Aadd( _aCabPV, { "C5_LOJACLI"  , ZBE->ZBE_LOJACL , NiL})  // Loja Cliente
   Aadd( _aCabPV, { "C5_I_NOME"   , ZBE->ZBE_NOME   , NiL})  // Nome Cliente
   Aadd( _aCabPV, { "C5_I_FANTA"  , ZBE->ZBE_FANTAS , NiL})  // Nom.Fantasia
   Aadd( _aCabPV, { "C5_I_EST"    , ZBE->ZBE_EST    , NiL})  // Estado
   Aadd( _aCabPV, { "C5_I_CMUN"   , ZBE->ZBE_CMUN   , NiL})  // Cod.Municipi
   Aadd( _aCabPV, { "C5_I_MUN"    , ZBE->ZBE_MUN    , NiL})  // Municipio
   Aadd( _aCabPV, { "C5_I_CEP"    , ZBE->ZBE_CEP    , NiL})  // CEP
   Aadd( _aCabPV, { "C5_CLIENT"   , ZBE->ZBE_CLENTR , NiL})  // Clien.Entreg 
   Aadd( _aCabPV, { "C5_LOJAENT"  , ZBE->ZBE_LOJAEN , NiL})  // Loja Entrega
   Aadd( _aCabPV, { "C5_I_END"    , ZBE->ZBE_ENDENT , NiL})  // End.Entrega
   Aadd( _aCabPV, { "C5_I_BAIRR"  , ZBE->ZBE_BAIREN , NiL})  // Bairro
   Aadd( _aCabPV, { "C5_I_DDD"    , ZBE->ZBE_DDD    , NiL})  // DDD
   Aadd( _aCabPV, { "C5_I_TEL"    , ZBE->ZBE_TELEFO , NiL})  // Telefone
   Aadd( _aCabPV, { "C5_I_OPER"   , ZBE->ZBE_OPERAC , NiL})  // Tp.Operação 
   Aadd( _aCabPV, { "C5_I_AGEND"  , ZBE->ZBE_AGENDA , NiL})  // Tp Entrega  
   Aadd( _aCabPV, { "C5_TIPO"     , ZBE->ZBE_TIPO   , NiL})  // Tipo Pedido 
   Aadd( _aCabPV, { "C5_I_DTENT"  , ZBE->ZBE_DTENT  , NiL})  // Data Entrega
   Aadd( _aCabPV, { "C5_VEND1"    , ZBE->ZBE_VEND1  , NiL})  // Vendedor
   Aadd( _aCabPV, { "C5_VEND2"    , ZBE->ZBE_VEND2  , NiL})  // Coordenador
   Aadd( _aCabPV, { "C5_VEND3"    , ZBE->ZBE_VEND3  , NiL})  // Gerente
   Aadd( _aCabPV, { "C5_VEND4"    , ZBE->ZBE_VEND4  , NiL})  // Supervisor 
   Aadd( _aCabPV, { "C5_I_TPVEN"  , ZBE->ZBE_TPVEN  , NiL})  // Tipo Venda
   Aadd( _aCabPV, { "C5_TPFRETE"  , ZBE->ZBE_TPFRET , NiL})  // Tipo Frete
   Aadd( _aCabPV, { "C5_I_TAB"    , ZBE->ZBE_TABPRC , NiL})  // Tabela Preços
   Aadd( _aCabPV, { "C5_CONDPAG"  , ZBE->ZBE_CONDPG , NiL})  // Cond.Pagto

   Aadd( _aCabPV, { "C5_I_TRCNF"  , ZBE->ZBE_TRCNF  , NiL})  // Troca Nota 
   Aadd( _aCabPV, { "C5_I_FLFNC"  , ZBE->ZBE_FLFNC  , NiL})  // Filial Carregamento Troca Nota 
   Aadd( _aCabPV, { "C5_I_FILFT"  , ZBE->ZBE_FILFT  , NiL})  // Filial Faturamento Troca Nota 

   _aAgrupaPV := {}
   
   //ZBF->(DbSetOrder(1))	//  ZBF_FILIAL+ZBF_PEDCOM+ZBF_SEQ+ZBF_CLIENT+ZBF_LOJACL+ZBF_PRODUT+ZBF_ITEM 
   //ZBF->(MsSeek(ZBE->(ZBE_FILIAL+ZBE_PEDCOM)))

   ZBF->(DbSetOrder(3))
   ZBF->(MsSeek(ZBC->(ZBC_FILIAL+ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
   
   Do While ! ZBF->(Eof()) .And. ZBE->(ZBE_FILIAL+ZBE_PEDCOM+ZBE_CLIENT+ZBE_LOJACL) == ZBF->(ZBF_FILIAL+ZBF_PEDCOM+ZBF_CLIENT+ZBF_LOJACL)
      Aadd(_aAgrupaPV,{ZBF->ZBF_AGRUPA,;  // 1
                       ZBF->ZBF_SEQ,;     // 2
                       ZBF->ZBF_ITEM,;    // 3
                       ZBF->ZBF_PRODUT,;  // 4 '
                       ZBF->(Recno())})   // 5

      ZBF->(DbSkip())
   EndDo 

   //==========================================================================
   // Faz a ordenação do Array _aAgrupaPV para a geração dos Pedidos de vendas 
   //==========================================================================
   ASORT(_aAgrupaPV, , , { | x,y | x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4] } )

   _aPVPorGrp := {} // Array com agrupamento de pedidos de vendas.
   _aPVPorSeq := {} // Array com separação de pedidos por sequencia.
   
   For _nI := 1 To Len(_aAgrupaPV)
       If ! Empty(_aAgrupaPV[_nI,1])
          Aadd(_aPVPorGrp, AClone(_aAgrupaPV[_nI]))  // Array com agrupamento de pedidos de vendas.
       EndIf  
       
       If Empty(_aAgrupaPV[_nI,1])
          Aadd(_aPVPorSeq, AClone(_aAgrupaPV[_nI]))  // Array com separação de pedidos por sequencia.
       EndIf  
   Next 

   //==========================================================================================
   // Gera os pedidos de vendas com agrupamento de itens.
   //==========================================================================================
   /*
      Aadd(_aAgrupaPV,{ZBF->ZBF_AGRUPA,;  // 1
                       ZBF->ZBF_SEQ,;     // 2
                       ZBF->ZBF_ITEM,;    // 3
                       ZBF->ZBF_PRODUT,;  // 4 
                       ZBF->(Recno())})   // 5
   */

   _aItensPV := {}
   _aItemPV  := {}
   
   If Len(_aPVPorGrp) > 0 
      
      _aRecnoZBF := {}
      _cAgrupa   := _aPVPorGrp[1,1] 

      For _nI := 1 To Len(_aPVPorGrp)
          If _cAgrupa  <> _aPVPorGrp[_nI,1] .And. _nI > 1
             _cAgrupa   := _aPVPorGrp[_nI,1]  

             _lGerouPV := U_AOMS132F(_aCabPV, _aItensPV, _aRecnoZBF, _nTotPalete) // Gera pedido de vendas no Protheus. SC5 e SC6.

             _aRecnoZBF := {}
             _aItensPV := {}
             _aItemPV  := {} 
          EndIf 

          ZBF->(DbGoTo(_aPVPorGrp[_nI,5])) // Posciona na tabela ZBF
          
          Aadd(_aRecnoZBF, ZBF->(Recno()))

          AAdd( _aItemPV , { "C6_FILIAL"   ,ZBF->ZBF_FILGPV  , Nil})  // Filial // ZBF_FILIAL
          AAdd( _aItemPV , { "C6_ITEM"     ,ZBF->ZBF_ITEM    , Nil})  // Item
          AAdd( _aItemPV , { "C6_ITEMPC"   ,ZBF->ZBF_ITEM    , Nil})  // (grava C6_ITEM)
          AAdd( _aItemPV , { "C6_PRODUTO"  ,ZBF->ZBF_PRODUT  , Nil})  // Produto
          AAdd( _aItemPV , { "C6_DESCRI"   ,ZBF->ZBF_DESCRI  , Nil})  // Desc.Produto
          AAdd( _aItemPV , { "C6_UNSVEN"   ,ZBF->ZBF_UNSVEN  , Nil})  // Qtd.2.Um
          AAdd( _aItemPV , { "C6_SEGUM"    ,ZBF->ZBF_SEGUM   , Nil})  // Segunda Um
          AAdd( _aItemPV , { "C6_QTDVEN"   ,ZBF->ZBF_QTDVEN  , Nil})  // Qtd.1.Um 
          AAdd( _aItemPV , { "C6_UM"       ,ZBF->ZBF_UM      , Nil})  // Primeira Um
          AAdd( _aItemPV , { "C6_PRCVEN"   ,ZBF->ZBF_PRCVEN  , Nil})  // Prc.Unitário
          AAdd( _aItemPV , { "C6_OPER"     ,ZBF->ZBF_OPER    , Nil})  // Tp. Operacao
          AAdd( _aItemPV , { "C6_VALOR"    ,ZBF->ZBF_VALOR   , Nil})  // Vlr.Total   
          AAdd( _aItemPV , { "C6_LOCAL"    ,ZBF->ZBF_LOCAL   , Nil})  // Armazem
          AAdd( _aItemPV , { "C6_ENTREG"   ,ZBF->ZBF_ENTREG  , Nil})  // Dt.Entrega
          AAdd( _aItemPV , { "C6_QTDLIB"   ,ZBF->ZBF_QTDLIB  , Nil})  // Qtd.Liberada
          AAdd( _aItemPV , { "C6_QTDLIB2"  ,ZBF->ZBF_QTDLB2  , Nil})  // Qtd.2.Liberada
          AAdd( _aItemPV , { "C6_PEDCLI"   ,ZBF->ZBF_PEDCLI  , Nil})  // Nr.Ped.Clien
          AAdd( _aItemPV , { "C6_NUMPCOM"  ,ZBF->ZBF_PEDCOM  , Nil})  // Ped.Compras
          AAdd( _aItemPV , { "C5_CLIENTE"  ,ZBF->ZBF_CLIENT  , Nil})  // Cliente
          AAdd( _aItemPV , { "C5_LOJACLI"  ,ZBF->ZBF_LOJACL  , Nil})  // Loja Cliente
          AAdd( _aItemPV , { "C6_I_QPALT"  ,ZBF->ZBF_QTDPAL  , Nil})  // Qtde.Paletes

          AAdd( _aItensPV ,_aItemPV )
          _aItemPV := {}
       
          _nTotPalete += ZBF->ZBF_QTDPAL 
        
      Next 

      If Len(_aItensPV) > 0
         _lGerouPV := U_AOMS132F(_aCabPV, _aItensPV, _aRecnoZBF, _nTotPalete) // Gera pedido de vendas no Protheus. SC5 e SC6.
      EndIf 
   
   EndIf 

   //==========================================================================================
   // Gera os pedidos de vendas com por sequencia.
   //==========================================================================================
   _aItensPV := {}
   _aItemPV  := {}
   
   If Len(_aPVPorSeq) > 0 
      
      _aRecnoZBF := {}
      _cSequen   := _aPVPorSeq[1,2]

      For _nI := 1 To Len(_aPVPorSeq)
          If _cSequen  <> _aPVPorSeq[_nI,2] .And. _nI > 1
             _cSequen   := _aPVPorSeq[_nI,2]  

             _lGerouPV := U_AOMS132F(_aCabPV, _aItensPV, _aRecnoZBF, _nTotPalete) // Gera pedido de vendas no Protheus. SC5 e SC6.

             _aRecnoZBF := {}
             _aItensPV := {}
             _aItemPV  := {} 
          EndIf 

          ZBF->(DbGoTo(_aPVPorSeq[_nI,5])) // Posciona na tabela ZBF
          
          Aadd(_aRecnoZBF, ZBF->(Recno()))

          AAdd( _aItemPV , { "C6_FILIAL"   ,ZBF->ZBF_FILGPV  , Nil})  // Filial // ZBF_FILIAL
          AAdd( _aItemPV , { "C6_ITEM"     ,ZBF->ZBF_ITEM    , Nil})  // Item
          AAdd( _aItemPV , { "C6_ITEMPC"   ,ZBF->ZBF_ITEM    , Nil})  // (grava C6_ITEM)
          AAdd( _aItemPV , { "C6_PRODUTO"  ,ZBF->ZBF_PRODUT  , Nil})  // Produto
          AAdd( _aItemPV , { "C6_DESCRI"   ,ZBF->ZBF_DESCRI  , Nil})  // Desc.Produto
          AAdd( _aItemPV , { "C6_UNSVEN"   ,ZBF->ZBF_UNSVEN  , Nil})  // Qtd.2.Um
          AAdd( _aItemPV , { "C6_SEGUM"    ,ZBF->ZBF_SEGUM   , Nil})  // Segunda Um
          AAdd( _aItemPV , { "C6_QTDVEN"   ,ZBF->ZBF_QTDVEN  , Nil})  // Qtd.1.Um 
          AAdd( _aItemPV , { "C6_UM"       ,ZBF->ZBF_UM      , Nil})  // Primeira Um
          AAdd( _aItemPV , { "C6_PRCVEN"   ,ZBF->ZBF_PRCVEN  , Nil})  // Prc.Unitário
          AAdd( _aItemPV , { "C6_OPER"     ,ZBF->ZBF_OPER    , Nil})  // Tp. Operacao
          AAdd( _aItemPV , { "C6_VALOR"    ,ZBF->ZBF_VALOR   , Nil})  // Vlr.Total   
          AAdd( _aItemPV , { "C6_LOCAL"    ,ZBF->ZBF_LOCAL   , Nil})  // Armazem
          AAdd( _aItemPV , { "C6_ENTREG"   ,ZBF->ZBF_ENTREG  , Nil})  // Dt.Entrega
          AAdd( _aItemPV , { "C6_QTDLIB"   ,ZBF->ZBF_QTDLIB  , Nil})  // Qtd.Liberada
          AAdd( _aItemPV , { "C6_QTDLIB2"  ,ZBF->ZBF_QTDLB2  , Nil})  // Qtd.2.Liberada
          AAdd( _aItemPV , { "C6_PEDCLI"   ,ZBF->ZBF_PEDCLI  , Nil})  // Nr.Ped.Clien
          AAdd( _aItemPV , { "C6_NUMPCOM"  ,ZBF->ZBF_PEDCOM  , Nil})  // Ped.Compras
          AAdd( _aItemPV , { "C5_CLIENTE"  ,ZBF->ZBF_CLIENT  , Nil})  // Cliente
          AAdd( _aItemPV , { "C5_LOJACLI"  ,ZBF->ZBF_LOJACL  , Nil})  // Loja Cliente
          AAdd( _aItemPV , { "C6_I_QPALT"  ,ZBF->ZBF_QTDPAL  , Nil})  // Qtde.Paletes

          AAdd( _aItensPV ,_aItemPV )
          _aItemPV := {}
       
          _nTotPalete += ZBF->ZBF_QTDPAL 
        
      Next 

      If Len(_aItensPV) > 0
         _lGerouPV := U_AOMS132F(_aCabPV, _aItensPV, _aRecnoZBF, _nTotPalete) // Gera pedido de vendas no Protheus. SC5 e SC6.
      EndIf 
   
   EndIf 

   //==========================================================================================
   // Atualiza Work com os numeros dos Pedidos de Vendas Geredos.
   //==========================================================================================
   TRBZBF->(DbGotop())

   Do While ! TRBZBF->(Eof())
      
      ZBF->(DbGoTo(TRBZBF->WK_RECNO))

      TRBZBF->(RecLock("TRBZBF",.F.))
      TRBZBF->WK_PEDPROT := ZBF->ZBF_PVPROT
      TRBZBF->WK_PEDPALT := ZBF->ZBF_PLPROT
      TRBZBF->(MsUnLock() ) 

      TRBZBF->(DbSkip())
   Enddo 

   TRBZBF->(DbGotop())

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS132H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/01/2022
===============================================================================================================================
Descrição---------: Exclui um pré pedido de vendas e retorna os saldos para pedido de compras do cliente principal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132R()
Local _nQtdlib, _nQtd2lib
Local _nI, _aRecnoZBF

Begin Sequence 

   If ! U_ItMsg("Confirma a exclusão do Pré Pedido de Vendas?" ,"Atenção", , ,2, 2)
      Break
   EndIf

   ZBF->(DbSetOrder(1))	// ZBF_FILIAL+ZBF_PEDCOM+ZBF_SEQ+ZBF_CLIENT+ZBF_LOJACL+ZBF_PRODUT+ZBF_ITEM 
   ZBD->(DbSetOrder(1)) // ZBD_FILIAL+ZBD_PEDCOM+ZBD_CLIENT+ZBD_LOJACL+ZBD_PRODUT+ZBD_ITEM
   ZBF->(MsSeek(ZBE->(ZBE_FILIAL+ZBE_PEDCOM+ZBE_SEQ+ZBE_CLIENT+ZBE_LOJACL)))

   Begin Transaction  

      _aRecnoZBF := {}

      Do While ! ZBF->(Eof()) .And. ZBE->(ZBE_FILIAL+ZBE_PEDCOM+ZBE_SEQ+ZBE_CLIENT+ZBE_LOJACL) == ZBF->(ZBF_FILIAL+ZBF_PEDCOM+ZBF_SEQ+ZBF_CLIENT+ZBF_LOJACL)
         
         If ZBD->(MsSeek(ZBF->(ZBF_FILIAL+ZBF_PEDCOM+ZBF_CLIENT+ZBF_LOJACL+ZBF_PRODUT+ZBF_ITEM)))
            
            _nQtdlib := ZBD->ZBD_QTDLIB - ZBF->ZBF_QTDVEN
            _nQtd2lib := ZBD->ZBD_QTDLB2 - ZBF->ZBF_UNSVEN	

            If _nQtdlib < 0
               _nQtdlib := 0
            EndIf 

            If _nQtd2lib < 0
               _nQtd2lib := 0
            EndIf 

            ZBD->(RecLock("ZBD",.F.))
            ZBD->ZBD_QTDLIB := _nQtdlib
            ZBD->ZBD_QTDLB2 := _nQtd2lib
            ZBD->(MsUnLock())

         EndIf 
         
         Aadd(_aRecnoZBF, ZBF->(Recno()) )

         ZBF->(DbSkip())
      EndDo    

      If Len(_aRecnoZBF) > 0
         For _nI := 1 To Len(_aRecnoZBF)
             ZBF->(DbGoTo(_aRecnoZBF[_nI]))

             ZBF->(RecLock("ZBF",.F.))
             ZBF->(DbDelete())
             ZBF->(MsUnLock())
         Next 
      EndIf 

      ZBE->(RecLock("ZBE",.F.))
      ZBE->(DbDelete())
      ZBE->(MsUnLock())

   End Transaction 

   U_ITMSG("Exclusão de Pré Pedido de Vendas finalizada." ,"Atenção",,2)

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa--------: AOMS132Q
Autor-----------: Julio de Paula Paz
Data da Criacao-: 17/02/2022
===============================================================================================================================
Descrição-------: Gera Pedido de Paletes
===============================================================================================================================
Parametros------: _cPedOrigem = Numero do Pedido de Origem   
                  _nPallet    = Quantidade de Palete
                  _RecnoSC5   = Recno Pedido de Vendas de Origem 
==============================================================================================================================
Retorno---------: _cRet = Numero do Pedido de Palete
===============================================================================================================================
*/
User Function AOMS132Q(_cPedOrigem, _nPallet,_RecnoSC5)
Local _cRet := ""
Local _cDesc  := "",_cPedPallet
Local _nPreco := _nTotVlrPal :=0
//Local _cUM	  := "",_Ped
//Local _ntot := 0
//Local _npos := 1
//Local _citls := AllTrim( U_ITGETMV( 'IT_CHEPITLS' ) )
//Local _citln := AllTrim( U_ITGETMV( 'IT_CHEPITLN' ) )
Local _cclis := AllTrim( U_ITGETMV( 'IT_CHEPCLIS' ) )
Local _cclin := AllTrim( U_ITGETMV( 'IT_CHEPCLIN' ) )
Local _cchep := GetMV( "IT_CCHEP" )
Local _cpbr :=  GetMV( "IT_PPBR" )
//Local _cPBRITLP :=  AllTrim( U_ITGETMV( 'IT_PBRITLP','51' ) )
Local _cPBRCLIP := AllTrim( U_ITGETMV( 'IT_PBRCLIP','51' ) )

Begin Sequence 

   SBZ->( DBSetOrder(1) )
   SC5->( DBSetOrder(1) )
   DA4->( DBSetOrder(1) )
   SA1->(DbSetOrder(1))

   SA1->(MsSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

   _cFilOrigem := SC5->C5_FILIAL
   _cPedOrigem := SC5->C5_NUM 
   cTipoPV		:= SC5->C5_TIPO
   cCliente	   := SC5->C5_CLIENTE
   cLoja		   := SC5->C5_LOJACLI
   _dDtEnt		:= If(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT) //Para nao travar a criacao do Pedido de Pallet
	_cLocal     := Posicione('SC6',1,SC5->C5_FILIAL+SC5->C5_NUM,"C6_LOCAL")
    
	_aCabPV		:= {}
   _aItemPV	:= {}
	_TipoC		:= SA1->A1_I_CHEP 
   If Empty(_TipoC)  
      _TipoC := "C"//1-Pallet Chep
   EndIf 
   cTpOper		:= ''
   lMsErroAuto	:= .F.
   nItem		:= 1
   _cDesc      := ""
   _nPreco     := 0
   _cUM	    := ""

   If _TipoC == "C"
		_cProduto := _cchep
	ElseIf _TipoC == "P"
		_cProduto := _cpbr
	EndIf
	
	_clichep := "N"
	
	If Len(AllTrim(SA1->A1_I_CCHEP)) == 10 
      _clichep := "S"
   EndIf 
	
	If _TipoC == "C" //Pallet Chep
		If _clichep == "S"
			cTpOper	:= _cclis
		Else
			cTpOper	:= _cclin
		EndIf
   Elseif _TipoC == "P" //Pallet PBR
		cTpOper	:= _cPBRCLIP 
	EndIf

	//====================================================================================================
	// Monta o cabeçalho do pedido de Pallet
	//====================================================================================================
   _aCabPV :={	{ "C5_TIPO"		, cTipoPV			, Nil },; // Tipo de pedido				
					{ "C5_I_OPER"	, cTpOper			, Nil },; // Tipo da operacao
					{ "C5_FILIAL"	, _cFilOrigem   	, Nil },; // filial
					{ "C5_CLIENTE"	, cCliente			, Nil },; // Codigo do cliente
					{ "C5_LOJAENT"	, cLoja				, Nil },; // Loja para entrada
					{ "C5_LOJACLI"	, cLoja				, Nil },; // Loja do cliente
					{ "C5_EMISSAO"	, date()			   , Nil },; // Data de emissao
					{ "C5_CONDPAG"	, '001'				, Nil },; // Codigo da condicao de pagamanto*
					{ "C5_TIPLIB"	, "1"				   , Nil },; // Tipo de Liberacao
					{ "C5_MOEDA"	, 1					, Nil },; // Moeda
					{ "C5_LIBEROK"	, " "				   , Nil },; // Liberacao Total
					{ "C5_TIPOCLI"	, "F"				   , Nil },; // Tipo do Cliente
					{ "C5_I_NPALE"	, _cPedOrigem		, Nil },; // Numero que originou a pedido de palete
					{ "C5_I_PEDPA"	, "S"				   , Nil },; // Pedido Refere a um pedido de Pallet
					{ "C5_I_DTENT"	, _dDtEnt			, Nil } } // Dt de Entrega
				
   //================================================================================
	// Localiza armazém do produto
	//================================================================================
   If _cLocal != '36'
	   _cLocal := ""
		If SBZ->( DBSeek( xFilial('SBZ') + _cProduto ) )
		   _cLocal := SBZ->BZ_LOCPAD
		EndIf
   EndIf
				
   //================================================================================
   // Localiza nome do produto, preço e UM
   //================================================================================
   SB1->(DBSetOrder(1))
   If SB1->(DBSeek(xFilial("SB1")+_cProduto))				
		_cDesc := ALLTRIM(SB1->B1_DESC)
		_nPreco:= SB1->B1_PRV1
		_cUM	  := SB1->B1_UM
	EndIf
	_nTotVlrPal   := _nPallet * _nPreco
				
   //====================================================================================================
	// Monta o item do pedido de Pallet
	AAdd( _aItemPV , {	{ "C6_ITEM"		, StrZero( nItem , 2 )	, Nil },; // Numero do Item no Pedido
								{ "C6_FILIAL"	, _cFilOrigem			   , Nil },;
								{ "C6_PRODUTO"	, _cProduto				   , Nil },; // Codigo do Produto
								{ "C6_QTDVEN"	, _nPallet				   , Nil },; // Quantidade Vendida
								{ "C6_PRCVEN"	, _nPreco				   , Nil },; // Preco Unitario Liquido
								{ "C6_PRUNIT"	, _nPreco				   , Nil },; // Preco Unitario Liquido
								{ "C6_ENTREG"	, _dDtEnt				   , Nil },; // Data da Entrega
								{ "C6_SUGENTR"	, _dDtEnt				   , Nil },; // Data da Entrega
								{ "C6_VALOR"	, _nTotVlrPal			   , Nil },; // valor total do item
								{ "C6_UM"		, _cUM					   , Nil },; // Unidade de Medida Primar.
								{ "C6_LOCAL"	, _cLocal				   , Nil },; // Almoxarifado
								{ "C6_DESCRI"	, _cDesc				      , Nil },; // Descricao
								{ "C6_QTDLIB"	, 0						   , Nil }}) // Quantidade Liberada
				
   //====================================================================================================
	// Geração do  pedido de Pallet
   //====================================================================================================
	MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItemPV , 3 )
				
	If lMsErroAuto
		If ( __lSx8 )
			RollBackSx8()
		EndIf
      
      U_ITMSG("Não foi possivel gerar pedido de palete. " ,"Atenção",,1)
      Mostraerro()

	Else
   	SC5->( RecLock( 'SC5' , .F. ) )
		SC5->C5_I_NPALE := _cPedOrigem
		SC5->C5_I_PEDPA := 'S'//É o Pedido de Pallet
	   SC5->C5_I_PEDGE := ''
		SC5->( MsUnlock() )
   	
      //====================================================================================================
		// Faz a amarração do pedido de origem no pedido de Pallet
		//====================================================================================================
      _cRet := SC5->C5_NUM
		_cPedPallet := SC5->C5_NUM
		SC5->(DbGoto(_RecnoSC5))
		SC5->( RecLock( 'SC5' , .F. ) )
		SC5->C5_I_NPALE := _cPedPallet
		SC5->C5_I_PEDPA := ''  
		SC5->C5_I_PEDGE := 'S' //É o Pedido Gerador de Pallet
		SC5->( MsUnlock() )

      U_ITMSG("Pedido de Pelete gerado com sucesso. " ,"Atenção",,1)
	EndIf
	
End Sequence 

Return _cRet  

/*
===============================================================================================================================
Programa----------: AOMS132I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/03/2022
===============================================================================================================================
Descrição---------: Gera o Pré-Pedido de Vendas com base na quantidade de Pallets o Pedido de compras do Cliente.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132I()
Local _cTexto 
Local _aStruct 
Local _nQtd, _nQtd2Un
Local _nLinha 
Local _aSizeAut  := MsAdvSize(.T.)
Local _nOpc := 0
//Local _nQtdlib, _nQtd2lib
//Local _cSequen
Local _bGerPrePd
Local _lFinalizar := .F. 
Local _cSeqPed

Private _cTipoVeic  := ""
Private _aTipoVeic  := {}
Private _aDadosVeic := {}
Private _cCodTpVeic := ""
Private _nQtdPalet 
Private aHeader := {}
Private aRotina := {}
Private _nTotPallet := 0, _oTotPallet
Private b2Click 
Private _cColunas   := "6,8" // Colunas editáveis // WK_GERPED , ZBD_UNSVEN , ZBD_QTDVEN
Private _nPaletVeic := 0
Private _oTipoVeic
Private _nTotItZBD  := 0
Private _oGetDBF 
Private Altera := .T.
Private Inclui := .F.
Private _oBtnGerPr
Private _OBtnGrava 
Private _OBtnSair

Private _lBtnGerPr
Private _lTipoVeic

Begin Sequence 
   
   ZBE->(DbSetOrder(2)) // ZBE_FILIAL+ZBE_PEDCOM+ZBE_CLIENT+ZBE_LOJACL 
   If ZBE->(MsSeek(xFilial("ZBE")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
      U_ItMsg("Já existe Pre-Pedido de Vendas Cadastrado para este pedido de compras.","Atenção","",1)
      Break
   EndIf 

   ZBB->(DbSetOrder(1)) // ZBB_FILIAL+ZBB_CLIENT+ZBB_LOJA+ZBB_TPVEIC
   If ! ZBB->(MsSeek(xFilial("ZBB")+ZBC->ZBC_CLIENT+ZBC->ZBC_LOJACL))
      U_ItMsg("Não existem tipos de veiculos cadastrados para este cliente!","Atenção","Cadastre os tipos de veiculos aceitados por este cliente.",1)
      Break
   EndIf

   Do While ! ZBB->(Eof()) .And. ZBB->(ZBB_FILIAL+ZBB_CLIENT+ZBB_LOJA) == xFilial("ZBB")+ZBC->ZBC_CLIENT+ZBC->ZBC_LOJACL
      _nQtdPalet := Posicione("DUT",1,xFilial("DUT")+ZBB->ZBB_TPVEIC,"DUT_I_QPAL")
      _cTexto := AllTrim(ZBB->ZBB_NOMVEI) + "-[" + StrZero(_nQtdPalet,3)+"]-PALETES"
      Aadd(_aTipoVeic, _cTexto)
      Aadd(_aDadosVeic, {ZBB->ZBB_TPVEIC, ZBB->ZBB_NOMVEI,_nQtdPalet}) 

      ZBB->(DbSkip())
   EndDo 
   
   M->ZBC_PEDCOM := ZBC->ZBC_PEDCOM  // C	6	0	Ped.Compras	Pedido de Compras Cliente
   M->ZBC_CLIENT := ZBC->ZBC_CLIENT  // C	6	0	Cliente	Codigo do Cliente
   M->ZBC_LOJACL := ZBC->ZBC_LOJACL  // C	4	0	Loja Cliente	Loja do Cliente
   M->ZBC_NOME   := ZBC->ZBC_NOME 	 // C	60	0	Nome Cliente	Nome Cliente
   M->ZBC_EST    := ZBC->ZBC_EST     // C	2	0	Estado	Estado
   M->ZBC_MUN    := ZBC->ZBC_MUN 	 // C	50	0	Municipio	Municipio
   M->ZBC_CEP    := ZBC->ZBC_CEP  	 // C	8	0	CEP	CEP
   M->ZBC_BAIREN := ZBC->ZBC_BAIREN  // C	50	0	Bairro	Bairro
   M->ZBC_DDD    := ZBC->ZBC_DDD     // C	3	0	DDD	DDD
   M->ZBC_TELEFO := ZBC->ZBC_TELEFO  // C	15	0	Telefone	Telefone
   M->ZBC_OPERAC := ZBC->ZBC_OPERAC  // C	2	0	Tp.Operação 	Tipo de Operação
   M->ZBC_AGENDA := ZBC->ZBC_AGENDA  // C	1	0	Tp Entrega  	Tipo de Entrega
   M->ZBC_TIPO   := ZBC->ZBC_TIPO    // C	1	0	Tipo Pedido 	Tipo de Pedido
   M->ZBC_DTENT  := ZBC->ZBC_DTENT   // D	8	0	Data Entrega	Data de Entrega
   M->ZBC_VEND1  := ZBC->ZBC_VEND1   // C	6	0	Vendedor	Vendedor

   M->ZBC_TRCNF  := If(ZBC->ZBC_TRCNF=="S","Sim","Nao")
   M->ZBC_FLFNC  := ZBC->ZBC_FLFNC 
   M->ZBC_FILFT  := ZBC->ZBC_FILFT
   
   _aStruct := {}
   //Aadd(_aStruct, {"WK_GERPED" , "C", 4 , 0}) // Gera Pedido Marcado/Desmarcado
   Aadd(_aStruct, {"ZBD_ITEM"  , "C", 2 , 0}) // Item
   Aadd(_aStruct, {"ZBD_PRODUT", "C", 15, 0}) // Codigo do Produto
   Aadd(_aStruct, {"ZBD_DESCRI", "C", 50, 0}) // Descrição do Produto
   Aadd(_aStruct, {"ZBD_UNSVEN", "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct, {"WK_UNSVEN" , "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct, {"ZBD_SEGUM" , "C", 2 , 0}) // Segunda Unidade Medida
   Aadd(_aStruct, {"ZBD_QTDVEN", "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct, {"WK_QTDVEN" , "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct, {"ZBD_UM"    , "C", 2 , 0}) // Primeira Unidade Medida
   Aadd(_aStruct, {"ZBD_PRCVEN", "N", 18, 8}) // Preço Unitário Liquido
   Aadd(_aStruct, {"ZBD_VALOR" , "N", 12, 2}) // Valor Total
   Aadd(_aStruct, {"ZBD_LOCAL" , "C", 2 , 0}) // Armazém
   Aadd(_aStruct, {"ZBD_QTDPAL", "N", 3 , 0}) // Quantidade de Paletes
   Aadd(_aStruct, {"WK_QTDPAL" , "N", 3 , 0}) // Quantidade de Paletes
   Aadd(_aStruct, {"WK_CXPALET", "N",  4, 0}) // Quantidade de Caixas por Palete
   Aadd(_aStruct, {"WK_QTDPPAL", "N", 13, 3}) // Quantidade por Paletes
   Aadd(_aStruct, {"WK_RECNO"  , "N", 10, 0}) // Quantidade de Paletes
   
   If Select("TRBZBD") > 0
	   TRBZBD->(Dbclosearea())
   EndIf

   _otemp := FWTemporaryTable():New("TRBZBD", _aStruct )
   _otemp:AddIndex( "01", {"ZBD_ITEM","ZBD_PRODUT"} )
   
   _otemp:Create()

   //===============================================================
   // Work com a capa dos Pré Pedidos de Vendas.
   //===============================================================
   _aStruct2 := {}
   Aadd(_aStruct2, {"ZBF_PEDCOM", "C", 20, 0}) // Pedido de Compras
   Aadd(_aStruct2, {"ZBF_SEQ"   , "C", 3 , 0}) // Sequencia
   Aadd(_aStruct2, {"ZBF_ITEM"  , "C", 2 , 0}) // Item
   Aadd(_aStruct2, {"ZBF_PRODUT", "C", 15, 0}) // Codigo do Produto
   Aadd(_aStruct2, {"ZBF_DESCRI", "C", 50, 0}) // Descrição do Produto
   Aadd(_aStruct2, {"ZBF_UNSVEN", "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct2, {"WK_UNSVEN" , "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct2, {"ZBF_SEGUM" , "C", 2 , 0}) // Segunda Unidade Medida
   Aadd(_aStruct2, {"ZBF_QTDVEN", "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct2, {"WK_QTDVEN" , "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct2, {"ZBF_UM"    , "C", 2 , 0}) // Primeira Unidade Medida
   Aadd(_aStruct2, {"ZBF_PRCVEN", "N", 18, 8}) // Preço Unitário Liquido
   Aadd(_aStruct2, {"ZBF_VALOR" , "N", 12, 2}) // Valor Total
   Aadd(_aStruct2, {"ZBF_LOCAL" , "C", 2 , 0}) // Armazém
   Aadd(_aStruct2, {"ZBF_QTDPAL", "N", 3 , 0}) // Quantidade de Paletes
   Aadd(_aStruct2, {"WK_QTDPAL" , "N", 3 , 0}) // Quantidade de Paletes
   Aadd(_aStruct2, {"WK_QTDPPAL", "N", 13, 3}) // Quantidade por Paletes
   Aadd(_aStruct2, {"WK_RECNO"  , "N", 10, 0}) // Recno do Item ZBD
   
   If Select("TRBZBF") > 0
	   TRBZBF->(Dbclosearea())
   EndIf

   _otemp2 := FWTemporaryTable():New("TRBZBF", _aStruct2 )
   _otemp2:AddIndex( "01", {"ZBF_PEDCOM", "ZBF_SEQ", "ZBF_ITEM"} )
   
   _otemp2:Create()

   //======================================================================
   // Grava work trb ZBD.
   //======================================================================
   DBSelectArea( "TRBZBD" )

   SB1->(DbSetOrder(1))

   ZBD->(DbSetOrder(1))	// ZBD_FILIAL+ZBD_PEDCOM+ZBD_CLIENT+ZBD_LOJACL+ZBD_PRODUT+ZBD_ITEM
   ZBD->(MsSeek(ZBC->(ZBC_FILIAL+ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
   Do While ! ZBD->(Eof()) .And. ZBC->(ZBC_FILIAL+ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL) == ZBD->(ZBD_FILIAL+ZBD_PEDCOM+ZBD_CLIENT+ZBD_LOJACL)
      /*
      If ZBD->ZBD_QTDLIB == ZBD->ZBD_QTDVEN 
         ZBD->(DbSkip())
         Loop
      EndIf 
      */

      _nQtd    := ZBD->ZBD_QTDVEN // - ZBD->ZBD_QTDLIB     	// Quantidade Liberada 1 Unidade
      _nQtd2Un := ZBD->ZBD_UNSVEN // - ZBD->ZBD_QTDLB2      // Quantidade Liberada 2 Unidade
     
      SB1->(MsSeek(xFilial("SB1")+ZBD->ZBD_PRODUT))
      
      _nCXPalet  :=	SB1->B1_I_CXPAL
      _nQtdPalet := 0 
      _nQtdDecP  := 0 

      If _nCXPalet <> 0
         
         _nQtdDecP  := _nQtd2Un /_nCXPalet // Quantidade de Paletes com decimais. Sem truncamento.

	      If mod(_nQtd2Un, _nCXPalet) > 0
		      _nQtdPalet := int(_nQtd2Un /_nCXPalet) + 1 		            
	      Else
		      _nQtdPalet := int(_nQtd2Un /_nCXPalet) 
	      EndIf

      EndIf
      
      TRBZBD->(DbAppend())
      //TRBZBD->WK_GERPED    := "LBOK" // "LBNO" = SEM CLIQUE
      TRBZBD->ZBD_ITEM     := ZBD->ZBD_ITEM   // Item
      TRBZBD->ZBD_PRODUT   := ZBD->ZBD_PRODUT // Codigo do Produto
      TRBZBD->ZBD_DESCRI   := ZBD->ZBD_DESCRI // Descrição do Produto
      TRBZBD->ZBD_UNSVEN   := ZBD->ZBD_UNSVEN // _nQtd2Un        // Qtd. Segunda Unidade Med.
      TRBZBD->ZBD_SEGUM    := ZBD->ZBD_SEGUM  // Segunda Unidade Medida
      TRBZBD->ZBD_QTDVEN   := ZBD->ZBD_QTDVEN // _nQtd           // Qtd. Primeira Unidade Medida
      TRBZBD->ZBD_UM       := ZBD->ZBD_UM     // Primeira Unidade Medida
      TRBZBD->ZBD_PRCVEN   := ZBD->ZBD_PRCVEN // Preço Unitário Liquido
      TRBZBD->ZBD_VALOR    := (ZBD->ZBD_PRCVEN * ZBD->ZBD_QTDVEN)  // Valor Total
      TRBZBD->ZBD_LOCAL    := ZBD->ZBD_LOCAL  // Armazém
      TRBZBD->ZBD_QTDPAL   := _nQtdPalet      // Quantidade de Paletes
      TRBZBD->WK_RECNO     := ZBD->(Recno())  // Recno da tabela ZBD
      TRBZBD->WK_QTDPPAL   := _nCXPalet       // Quantidade da segunda unidade de medida por Palete.
      TRBZBD->WK_QTDPAL    := _nQtdPalet      // Quantidade de Paletes
      TRBZBD->WK_CXPALET   := _nCXPalet       // Quantidade de Caixas por Palete
      TRBZBD->(MsUnlock())
      
      _nTotPallet += _nQtdPalet

      ZBD->(DbSkip())
   EndDo 
   
   Aadd(aHeader,{"Pedido Comparas"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_PEDCOM"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PEDCOM","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PEDCOM","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                                                      0 ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Sequencia"                           ,;   // 1  = X3_TITULO                   3
                 "ZBF_SEQ"                             ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEQ","X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 8                                     ,;   // 4  = X3_TAMANHO // getsx3cache("ZBF_SEQ","X3_TAMANHO")
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
/*
   Aadd(aHeader,{"Qtde Paletes"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_QTDPAL"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDPAL","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDPAL","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDPAL","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "N"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX
*/
   Aadd(aHeader,{"Item"                               ,;   // 1  = X3_TITULO                   3
                 "ZBF_ITEM"                            ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_ITEM","X3_PICTURE")  ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_ITEM","X3_TAMANHO")  ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Produto"                             ,;   // 1  = X3_TITULO                4   
                 "ZBF_PRODUT"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRODUT","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRODUT","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Descrição Prod"                      ,;   // 1  = X3_TITULO                 5  
                 "ZBF_DESCRI"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_DESCRI","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_DESCRI","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Qtde Paletes"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_QTDPAL"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDPAL","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDPAL","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDPAL","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "N"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Qtd.2 Unid.Med."                     ,;   // 1  = X3_TITULO                  6 
                 "ZBF_UNSVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UNSVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UNSVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_UNSVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX 

   Aadd(aHeader,{"Seg.Unid.Medida"                     ,;  // 1  = X3_TITULO                 7  
                 "ZBF_SEGUM"                           ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEGUM","X3_PICTURE") ,;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_SEGUM" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                    ,;    // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
 
   Aadd(aHeader,{"Qtd.1 Unid Med"                      ,;  // 1  = X3_TITULO                   8
                 "ZBF_QTDVEN"                          ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDVEN","X3_PICTURE"),;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDVEN" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDVEN","X3_DECIMAL"),;    // 5  = X3_DECIMAL
                 ""                                    ,;    // 6  = X3_VALID                 
                                                     "",;    // 7  = X3_USADO
                 "N"                                   ,;    // 8  = X3_TIPO                   
                                                     "",;    // 9  = X3_CONTEXT
                 ""                                    })    // 10 = X3_CBOX
   
   Aadd(aHeader,{"1.Unid.Medida"                       ,;   // 1  = X3_TITULO                  9 
                 "ZBF_UM"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UM" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UM" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Prc.Unitario"                        ,;   // 1  = X3_TITULO                 10  
                 "ZBF_PRCVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRCVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRCVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_PRCVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Valor Total"                         ,;   // 1  = X3_TITULO                11   
                 "ZBF_VALOR"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_VALOR","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_VALOR","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_VALOR","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Armazém"                                ,;   // 1  = X3_TITULO               12    
                 "ZBF_LOCAL"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_LOCAL" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_LOCAL" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                        ,;   // 5  = X3_DECIMAL
                 ""                                       ,;   // 6  = X3_VALID                 
                                                     ""   ,;   // 7  = X3_USADO
                 "C"                                      ,;   // 8  = X3_TIPO                   
                                                     ""   ,;   // 9  = X3_CONTEXT
                 ""                                       })   // 10 = X3_CBOX

   //======================================================
   // Configurações iniciais
   //======================================================
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 

   aRotina := {}   
   AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"		,"AxExclui",0,5})
   Inclui := .F.
   Altera := .T.
   
   _cTipoVeic  := _aTipoVeic[1]
   _nPaletVeic := _aDadosVeic[1,3]  
   _cCodTpVeic := _aDadosVeic[1,1]

   _bGerPrePd := {|| Processa( {|| U_AOMS132D() , _oDlgPre:End()} , 'Aguarde!' , 'Gerando Pré Pedido de Vendas...' )}
   _lBtnGerPr := .F.
   _lTipoVeic := .F.

   Do While .T. 
      TRBZBD->(DbGoTop())

      DEFINE MSDIALOG _oDlgPre TITLE "Gera Pré Pedido de Vendas" FROM _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] PIXEL // 00,00 TO 300,400
        
          @ _aPosObj[2,3]-30, 05  BUTTON _oBtnGerPr PROMPT "&Gerar Pre Pedidos Vendas" SIZE 100, 012 OF _oDlgPre ACTION ( Eval(_bGerPrePd) ) PIXEL
          @ _aPosObj[2,3]-30, 115 BUTTON _OBtnGrava PROMPT "&Gravar" SIZE 70, 012 OF _oDlgPre ACTION ( If(U_AOMS132Z("GRAVAR"),(_nOpc := 1, _lFinalizar := .T. ,_oDlgPre:End()),_nOpc := 0)) PIXEL
          @ _aPosObj[2,3]-30, 200 BUTTON _OBtnSair  PROMPT "&Sair"	 SIZE 50, 012 OF _oDlgPre ACTION ( (_nOpc := 0, _lFinalizar := .T. ,_oDlgPre:End()) ) PIXEL

          _nLinha := 15
          @ _nLinha, 10 Say "Ped.Compras"	Pixel Size  030,012 Of _oDlgPre
          @ _nLinha, 60 MSGet M->ZBC_PEDCOM  Pixel Size 040,012 WHEN .F. Of _oDlgPre
     
          @ _nLinha, 115 Say "Tipo de Veiculo"	Pixel Size 040,012 Of _oDlgPre
          @ _nLinha, 170 MSCOMBOBOX _oTipoVeic Var _cTipoVeic ITEMS _aTipoVeic Valid(U_AOMS132Z("TIPO_VEICULO")) Pixel Size 160, 012 Of _oDlgPre 

          @ _nLinha, 350 Say "Total Pallets Veiculo:"	Pixel Size  080,012 Of _oDlgPre
          @ _nLinha, 415 MSGet _nPaletVeic Pixel Size 040,012 WHEN .F. Of _oDlgPre
      
          @ _nLinha, 470 Say "Total de Pallets do Pedido:"	Pixel Size  080,012 Of _oDlgPre
          @ _nLinha, 540 MSGet _oTotPallet Var _nTotPallet Pixel Size 040,012 WHEN .F. Of _oDlgPre

          _nLinha += 20
          @ _nLinha, 10 Say "Troca Nota"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 60 MSGet M->ZBC_TRCNF Pixel Size 040,012 WHEN .F. Of _oDlgPre

          @ _nLinha, 115 Say "Filial Faturamento"	Pixel Size 040, 020 Of _oDlgPre
          @ _nLinha, 170 MSGet M->ZBC_FLFNC Pixel Size 040,009 WHEN .F. Of _oDlgPre

          @ _nLinha, 255 Say "Filial Carregamento"	Pixel Size 040,020 Of _oDlgPre
          @ _nLinha, 305 MSGet M->ZBC_FILFT Pixel Size 100,012 WHEN .F. Of _oDlgPre

          _nLinha += 20
          @ _nLinha, 10 Say "Cliente"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 60 MSGet M->ZBC_CLIENT Pixel Size 040,012 WHEN .F. Of _oDlgPre

          @ _nLinha, 115 Say "Loja Cliente"	Pixel Size 040, 012 Of _oDlgPre
          @ _nLinha, 170 MSGet M->ZBC_LOJACL Pixel Size 040,009 WHEN .F. Of _oDlgPre

          @ _nLinha, 255 Say "Nome Cliente"	Pixel Size 040,012 Of _oDlgPre
          @ _nLinha, 305 MSGet M->ZBC_NOME Pixel Size 100,012 WHEN .F. Of _oDlgPre
        
          _nLinha += 20

          @ _nLinha, 10 Say "Estado"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 60 MSGet M->ZBC_EST Pixel Size 040,012 WHEN .F. Of _oDlgPre

          @ _nLinha, 115 Say "Municipio"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 170 MSGet M->ZBC_MUN Pixel Size 060,012 WHEN .F. Of _oDlgPre

          @ _nLinha, 255 Say "CEP"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 305 MSGet M->ZBC_CEP Pixel Size 040,012 WHEN .F. Of _oDlgPre
        
          @ _nLinha, 375 Say "Bairro"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 415 MSGet M->ZBC_BAIREN Pixel Size 080,012 WHEN .F. Of _oDlgPre
        
          _nLinha += 20

          @ _nLinha, 10 Say "DDD"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 60 MSGet M->ZBC_DDD Pixel Size 040,012 WHEN .F. Of _oDlgPre

          @ _nLinha, 115 Say "Telefone"	Pixel Size 030,012 Of _oDlgPre
          @ _nLinha, 170 MSGet M->ZBC_TELEFO Pixel Size 040,012 WHEN .F. Of _oDlgPre

          @ _nLinha, 255 Say "Tp.Operação"	Pixel Size 040,012 Of _oDlgPre
          @ _nLinha, 305 MSGet M->ZBC_OPERAC Pixel Size 040,012 WHEN .F. Of _oDlgPre

          @ _nLinha, 375 Say "Tipo Pedido"	Pixel Size 040,012 Of _oDlgPre
          @ _nLinha, 415 MSGet M->ZBC_TIPO Pixel Size 040,012 WHEN .F. Of _oDlgPre

          //_nLinha += 20

          @ _nLinha, 475 Say "Data Entrega"	Pixel Size 040,012 Of _oDlgPre
          @ _nLinha, 515 MSGet M->ZBC_DTENT Pixel Size 040,012 WHEN .F. Of _oDlgPre
        
          @ _nLinha, 570 Say "Vendedor"	Pixel Size 040,012 Of _oDlgPre
          @ _nLinha, 605 MSGet M->ZBC_VEND1 Pixel Size 040,012 WHEN .F. Of _oDlgPre
          _nLinha += 20

                //MsGetDB():New ( < nTop>, < nLeft>, < nBottom>       , < nRight>         ,< nOpc>, [ cLinhaOk]             , [ cTudoOk]            ,[ cIniCpos], [ lDelete] , [ aAlter]      , [ nFreeze], [ lEmpty], [ uPar1], < cTRB>  , [ cFieldOk]            , [ uPar2], [ lAppend], [ oWnd] , [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] ) --> oObj
          _oGetDBF := MsGetDB():New (_nLinha, 0       , _aPosObj[2,3]-50 , _aPosObj[2,4]     , 4     , "U_AOMS132Z('LINHAOK')" , "U_AOMS132Z('TUDOOK')", ""         , .F.       , {}             , 0         , .F.       ,        , "TRBZBF" , "U_AOMS132Z('FIELDOK')",         , .F.       , _oDlgPre, .F.) //         ,         ,""        , "")
       
          //b2Click := _oGetDBF:oBrowse:bLDblClick
          // _oGetDBF:oBrowse:bLDblClick := { || U_AOMS132Y("TRBZBD" , TRBZBD->WK_GERPED) }

          //_oGetDBF:oBrowse:bAdd := {||.T.} // não inclui novos itens MsGetDb()
          _oGetDBF:Enable( ) 
          
          If _lBtnGerPr 
             _oBtnGerPr:Disable()
          EndIf  
          
          If _lTipoVeic 
             _oTipoVeic:Disable()  
          EndIf 
          
          TRBZBD->(DbGoTop())
          _oGetDBF:ForceRefresh( )

      ACTIVATE MSDIALOG _oDlgPre CENTERED
    
      If _lFinalizar
         Exit 
      EndIf 

   EndDo  

   If _nOpc == 1
       
      If ! U_ItMsg("Confirma a geração do Pré Pedido de Vendas?" ,"Atenção", , ,2, 2)
         Break
      EndIf 

      Begin Transaction 
         TRBZBF->(Dbgotop())
         
         _cSeqPed := Space(3)
         
         Do While ! TRBZBF->(Eof())
            If _cSeqPed <> TRBZBF->ZBF_SEQ
               ZBE->(RecLock("ZBE",.T.))
               ZBE->ZBE_FILIAL	:= ZBC->ZBC_FILIAL    // Filial do Sistema
               ZBE->ZBE_PEDCOM	:= ZBC->ZBC_PEDCOM 	 // Pedido de Compras Cliente
               ZBE->ZBE_SEQ      := TRBZBF->ZBF_SEQ
               ZBE->ZBE_CLIENT	:= ZBC->ZBC_CLIENT    // Codigo do Cliente
               ZBE->ZBE_LOJACL	:= ZBC->ZBC_LOJACL 	 // Loja do Cliente
               ZBE->ZBE_NOME	   := ZBC->ZBC_NOME  	 // Nome Cliente
               ZBE->ZBE_FANTAS	:= ZBC->ZBC_FANTAS 	 // Nome Fantasia
               ZBE->ZBE_EST	   := ZBC->ZBC_EST   	 // Estado
               ZBE->ZBE_CMUN	   := ZBC->ZBC_CMUN  	 // Código Municipio
               ZBE->ZBE_MUN	   := ZBC->ZBC_MUN   	 // Municipio
               ZBE->ZBE_CEP	   := ZBC->ZBC_CEP	    // CEP
               ZBE->ZBE_CLENTR	:= ZBC->ZBC_CLENTR  	 // Cliente de Entrega
               ZBE->ZBE_LOJAEN	:= ZBC->ZBC_LOJAEN 	 // Loja de Entrega
               ZBE->ZBE_ENDENT	:= ZBC->ZBC_ENDENT    // Endereço de Entrega
               ZBE->ZBE_BAIREN	:= ZBC->ZBC_BAIREN  	 // Bairro
               ZBE->ZBE_DDD 	   := ZBC->ZBC_DDD   	 // DDD
               ZBE->ZBE_TELEFO	:= ZBC->ZBC_TELEFO  	 // Telefone
               ZBE->ZBE_OPERAC	:= ZBC->ZBC_OPERAC  	 // Tipo de Operação
               ZBE->ZBE_AGENDA	:= ZBC->ZBC_AGENDA    // Tipo de Entrega
               ZBE->ZBE_TIPO	   := ZBC->ZBC_TIPO      // Tipo de Pedido
               ZBE->ZBE_DTENT	   := ZBC->ZBC_DTENT     // Data de Entrega
               ZBE->ZBE_VEND1	   := ZBC->ZBC_VEND1     // Vendedor
               ZBE->ZBE_VEND2	   := ZBC->ZBC_VEND2     // Coordenador
               ZBE->ZBE_VEND3	   := ZBC->ZBC_VEND3     // Gerente
               ZBE->ZBE_VEND4	   := ZBC->ZBC_VEND4     // Supervisor 
               ZBE->ZBE_TPVEN	   := ZBC->ZBC_TPVEN     // Tipo de Venda
               ZBE->ZBE_TPFRET	:= ZBC->ZBC_TPFRET 	 // Tipo do Frete Utilizado  
               ZBE->ZBE_TABPRC	:= ZBC->ZBC_TABPRC 	 // Tabela de Preços
               ZBE->ZBE_DSCTBP	:= ZBC->ZBC_DSCTBP 	 // Decrição Tabela de Preços
               ZBE->ZBE_STATUS	:= ZBC->ZBC_STATUS 	 // Status do Pedido do Cliente
               ZBE->ZBE_CONDPG	:= ZBC->ZBC_CONDPG    // Condição de Pagamento
               ZBE->ZBE_TPVEIC   := _cCodTpVeic        // Codigo do Tipo de Veiculo

               ZBE->ZBE_TRCNF    := ZBC->ZBC_TRCNF	    // Troca NF.
               ZBE->ZBE_FLFNC    := ZBC->ZBC_FLFNC	    // Fil.Carregam
               ZBE->ZBE_FILFT    := ZBC->ZBC_FILFT	    // Fil.Faturame

			      ZBE->(MsUnLock())		

               _cSeqPed := TRBZBF->ZBF_SEQ
            EndIf
           
            ZBF->(RecLock("ZBF",.T.))
            ZBF->ZBF_FILIAL := ZBC->ZBC_FILIAL        // Filial do Sistema 
            ZBF->ZBF_SEQ    := TRBZBF->ZBF_SEQ
            ZBF->ZBF_ITEM	 := TRBZBF->ZBF_ITEM        // Item
            ZBF->ZBF_PRODUT := TRBZBF->ZBF_PRODUT	    // Codigo do Produto
            ZBF->ZBF_DESCRI := TRBZBF->ZBF_DESCRI      // Descrição do Produto
            ZBF->ZBF_UNSVEN := TRBZBF->ZBF_UNSVEN	    // Segunda Unidade Med.
            ZBF->ZBF_SEGUM  := TRBZBF->ZBF_SEGUM       // Segunda Unidade Medida
            ZBF->ZBF_QTDVEN := TRBZBF->ZBF_QTDVEN	    // Qtd. Primeira Unidade Medida
            ZBF->ZBF_UM	    := TRBZBF->ZBF_UM	       // Primeira Unidade Medida
            ZBF->ZBF_PRCVEN := TRBZBF->ZBF_PRCVEN   	 // Preço Unitário Liquido
            ZBF->ZBF_OPER	 := ZBC->ZBC_OPERAC         // Tipo de Operação
            ZBF->ZBF_VALOR  := TRBZBF->ZBF_VALOR	 	 // Valor Total
            ZBF->ZBF_LOCAL  := TRBZBF->ZBF_LOCAL	    // Armazém
            ZBF->ZBF_ENTREG := ZBC->ZBC_DTENT 	       // Data de Entrega
            ZBF->ZBF_QTDLIB := 0                       // Quantidade Liberada 1 Unidade
            ZBF->ZBF_QTDLB2 := 0                       // Quantidade Liberada 2 Unidade
            ZBF->ZBF_PEDCLI := ZBC->ZBC_PEDCOM	       // Nr.Pedido do Cliente
            ZBF->ZBF_PEDCOM := ZBC->ZBC_PEDCOM	       // Nr.Pedido de Compras Cliente
            ZBF->ZBF_CLIENT := ZBC->ZBC_CLIENT	       // Codigo do Cliente
            ZBF->ZBF_LOJACL := ZBC->ZBC_LOJACL	 	    // Loja do Cliente
            ZBF->ZBF_QTDPAL := TRBZBF->ZBF_QTDPAL	 	 // Quantidade de Paletes
            ZBF->(MsUnLock())
         
            TRBZBF->(DbSkip())
         EndDo 
      
      End Transaction 
   
   EndIf         
   
   U_ItMsg("Geração do Pré Pedido de Vendas concluida!","Atenção","",2)

End Sequence 

If Select("TRBZBD") > 0
   TRBZBD->(Dbclosearea())
EndIf

If Select("TRBZBF") > 0
   TRBZBF->(Dbclosearea())
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS132D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/03/2022
===============================================================================================================================
Descrição---------: Gera o Pré-Pedido de Vendas com base na quantidade de Pallets o Pedido de compras do Cliente.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132D()
Local _nSeq := 1
Local _nPaletes, _nQtdPalet
Local _nI, _nY, _nX, _nZ  
Local _nQtd, _nQtd2, _nValorTot
Local _nTotalP 
Local _aGrupoIt, _nMaxItens 
Local _nRestPale, _aRestPale := {}
Local _lGravouIt 

Private _aItens

Begin Sequence 
   
   If ! U_ItMsg("Confirma a geração do Pré Pedido de Vendas?" ,"Atenção", , ,2, 2)
      Break
   EndIf 
   
   ProcRegua(0)

   IncProc("Gerando Pre-Pedidos de Vendas....")

   TRBZBD->(DbGoTop())
    
   _nTotItZBD := 0

   Do While ! TRBZBD->(Eof())
      _nTotItZBD += 1  // Armazena o total de itens da tabela ZBD.

      TRBZBD->(DbSkip())
   EndDo 
    
   TRBZBD->(DbGoTop())

   //=============================================================================
   // Quantidade de Paletes do Veículo > Total de Paletes do Pededido de Compras.
   //=============================================================================
   IncProc("Gerando Pre-Pedidos de Vendas....")

   If _nPaletVeic >= _nTotPallet
      TRBZBD->(DbGoTop())

      Do While ! TRBZBD->(Eof())
         
         TRBZBF->(DbAppend())
         TRBZBF->ZBF_PEDCOM := M->ZBC_PEDCOM       //"C", 20, 0 // Pedido de Compras
         TRBZBF->ZBF_SEQ    := StrZero(_nSeq,3)    //"C", 2 , 0 // Sequencia
         TRBZBF->ZBF_ITEM   := TRBZBD->ZBD_ITEM    //"C", 2 , 0 // Item
         TRBZBF->ZBF_PRODUT := TRBZBD->ZBD_PRODUT  //"C", 15, 0 // Codigo do Produto
         TRBZBF->ZBF_DESCRI := TRBZBD->ZBD_DESCRI  //"C", 50, 0 // Descrição do Produto
         TRBZBF->ZBF_UNSVEN := TRBZBD->ZBD_UNSVEN  //"N", 9 , 3 // Qtd. Segunda Unidade Med.
         TRBZBF->WK_UNSVEN  := TRBZBD->ZBD_UNSVEN  //"N", 9 , 3 // Qtd. Segunda Unidade Med.
         TRBZBF->ZBF_SEGUM  := TRBZBD->ZBD_SEGUM   //"C", 2 , 0 // Segunda Unidade Medida
         TRBZBF->ZBF_QTDVEN := TRBZBD->ZBD_QTDVEN  //"N", 13, 3 // Qtd. Primeira Unidade Medida
         TRBZBF->WK_QTDVEN  := TRBZBD->ZBD_QTDVEN  //"N", 13, 3 // Qtd. Primeira Unidade Medida
         TRBZBF->ZBF_UM     := TRBZBD->ZBD_UM      //"C", 2 , 0 // Primeira Unidade Medida
         TRBZBF->ZBF_PRCVEN := TRBZBD->ZBD_PRCVEN  //"N", 18, 8 // Preço Unitário Liquido
         TRBZBF->ZBF_VALOR  := TRBZBD->ZBD_VALOR   //"N", 12, 2 // Valor Total
         TRBZBF->ZBF_LOCAL  := TRBZBD->ZBD_LOCAL   //"C", 2 , 0 // Armazém
         TRBZBF->ZBF_QTDPAL := TRBZBD->ZBD_QTDPAL  //"N", 3 , 0 // Quantidade de Paletes
         TRBZBF->WK_QTDPAL  := TRBZBD->WK_QTDPAL   //"N", 3 , 0 // Quantidade de Paletes
         TRBZBF->WK_QTDPPAL := TRBZBD->WK_QTDPPAL  //"N", 13, 3 // Quantidade por Paletes
         TRBZBF->(MsUnLock())
         
         TRBZBD->(DbSkip()) 
      EndDo 
      
      Break // Gera apenas um pedido para o veículo selecionado.

   EndIf 

   //==================================================================
   // Quantidade de itens < Quantidade de Paletes do Veiculo
   //==================================================================
   IncProc("Gerando Pre-Pedidos de Vendas....")

   If _nTotItZBD < _nPaletVeic
      _aItens := {}

      TRBZBD->(DbGoTop())
      Do While ! TRBZBD->(Eof())
         Aadd(_aItens, {TRBZBD->ZBD_ITEM,;    // Item                                  // 1
                        TRBZBD->ZBD_PRODUT,;  // Codigo do Produto                     // 2
                        TRBZBD->ZBD_QTDPAL,;  // Quantidade de Paletes                 // 3
                        TRBZBD->WK_QTDPAL,;   // Quantidade de Paletes                 // 4
                        TRBZBD->WK_QTDPPAL,;  // Quantidade por Paletes                // 5
                                         0,;  // Quantidade do item para pré pedido    // 6
                        TRBZBD->(Recno()),;   // Recno da tabela TRBZBD                // 7
                        .T.               })  // Continua a gerar itens de pré pedido  // 8

         TRBZBD->(DbSkip())
      EndDo 
        
      _nTotalP := 0
      Do While .T.
         For _nX := 1 To Len(_aItens)
             If _aItens[_nX,6] < _aItens[_nX,3]  .And. (_nTotalP + 1) <= _nPaletVeic // Quantidade de Palete Pre Pedido < Quantidade Paletes por item
                _aItens[_nX,6] := _aItens[_nX,6] + 1
                _nTotalP += 1  // _aItens[_nX,6]
             EndIf 
         Next 
           
         If (_nTotalP + 1) > _nPaletVeic
            Exit 
         EndIf 
   
      EndDo 

      //==================================================================
      // Calcula a quantidade de Pré Pedidos de Vendas que serão gerados.
      //==================================================================
      _nQtdPalet := _nTotalP    // Total de Palete por Pré Pedido de Vendas.
      _nPaletes  := _nTotPallet // Total de Palete do Pedido de Compras.

      _nI := 1

      Do While _nPaletes > _nPaletVeic
         _nPaletes  := _nPaletes - _nQtdPalet
         _nI += 1
      EndDo  

      //==================================================================
      // Cria os Pré Pedidos de Vendas em Tabelas temporárias (Works).
      //==================================================================
      SB1->(DbSetOrder(1))

      For _nY := 1 To _nI

          TRBZBD->(DbGoTop())
          
          _nRestPale := 0  // Quantidade de Paletes residuais
          _aRestPale := {}

          Do While ! TRBZBD->(Eof())

             If TRBZBD->WK_QTDPAL == 0
                TRBZBD->(DbSkip())
                Loop 
             EndIf 

             _nX := Ascan(_aItens, {|x| x[1] == TRBZBD->ZBD_ITEM .And. x[2] == TRBZBD->ZBD_PRODUT})
             
             If _aItens[_nX,3] < _aItens[_nX,6]
                _nQtd2    := _aItens[_nX,3] * TRBZBD->WK_QTDPPAL // Quantidade de Palete por Item x Quantidade por Palete
             Else 
                _nQtd2    := _aItens[_nX,6] * TRBZBD->WK_QTDPPAL // Quantidade de Palete por Item x Quantidade por Palete
             EndIf 

             SB1->(MsSeek(xFilial("SB1")+TRBZBD->ZBD_PRODUT))
      
             If SB1->B1_TIPCONV == "M"
                _nQtd  := _nQtd2 / SB1->B1_CONV   
             Else
                _nQtd  := _nQtd2 * SB1->B1_CONV
             EndIf

             _nValorTot := TRBZBD->ZBD_PRCVEN * _nQtd 

             TRBZBF->(DbAppend())
             TRBZBF->ZBF_PEDCOM := M->ZBC_PEDCOM       //"C", 20, 0 // Pedido de Compras
             TRBZBF->ZBF_SEQ    := StrZero(_nSeq,3)    //"C", 2 , 0 // Sequencia
             TRBZBF->ZBF_ITEM   := TRBZBD->ZBD_ITEM    //"C", 2 , 0 // Item
             TRBZBF->ZBF_PRODUT := TRBZBD->ZBD_PRODUT  //"C", 15, 0 // Codigo do Produto
             TRBZBF->ZBF_DESCRI := TRBZBD->ZBD_DESCRI  //"C", 50, 0 // Descrição do Produto
             TRBZBF->ZBF_UNSVEN := _nQtd2              // TRBZBD->ZBD_UNSVEN  //"N", 9 , 3 // Qtd. Segunda Unidade Med.
             TRBZBF->WK_UNSVEN  := TRBZBD->ZBD_UNSVEN  //"N", 9 , 3 // Qtd. Segunda Unidade Med.
             TRBZBF->ZBF_SEGUM  := TRBZBD->ZBD_SEGUM   //"C", 2 , 0 // Segunda Unidade Medida
             TRBZBF->ZBF_QTDVEN := _nQtd               // TRBZBD->ZBD_QTDVEN  //"N", 13, 3 // Qtd. Primeira Unidade Medida
             TRBZBF->WK_QTDVEN  := _nQtd               // TRBZBD->ZBD_QTDVEN  //"N", 13, 3 // Qtd. Primeira Unidade Medida
             TRBZBF->ZBF_UM     := TRBZBD->ZBD_UM      //"C", 2 , 0 // Primeira Unidade Medida
             TRBZBF->ZBF_PRCVEN := TRBZBD->ZBD_PRCVEN  //"N", 18, 8 // Preço Unitário Liquido
             TRBZBF->ZBF_VALOR  := _nValorTot          // TRBZBD->ZBD_VALOR   //"N", 12, 2 // Valor Total
             TRBZBF->ZBF_LOCAL  := TRBZBD->ZBD_LOCAL   //"C", 2 , 0 // Armazém
             TRBZBF->ZBF_QTDPAL := If(_aItens[_nX,3] < _aItens[_nX,6],_aItens[_nX,3],_aItens[_nX,6]) // _aItens[_nX,6] // Quantidade de Palete por Item//TRBZBD->ZBD_QTDPAL
             TRBZBF->WK_QTDPAL  := If(_aItens[_nX,3] < _aItens[_nX,6],_aItens[_nX,3],_aItens[_nX,6]) // _aItens[_nX,6] // Quantidade de Paletes
             TRBZBF->WK_QTDPPAL := TRBZBD->WK_QTDPPAL  //"N", 13, 3 // Quantidade por Paletes
             TRBZBF->(MsUnLock())
           
             //==========================================================================
             TRBZBD->(RecLock("TRBZBD", .F.))
             If (TRBZBD->WK_QTDPAL - _aItens[_nX,6]) > 0
                TRBZBD->WK_QTDPAL := TRBZBD->WK_QTDPAL - _aItens[_nX,6] 
                _aItens[_nX,3]    := _aItens[_nX,3] - _aItens[_nX,6]     // Faz o mesmo cálculo da Work para ajustar a quantidade de Palete por item. 
             Else 
                TRBZBD->WK_QTDPAL := 0
                _aItens[_nX,8]    := .F.   
                _nRestPale += _aItens[_nX,6] 
                Aadd(_aRestPale,{_nX,_aItens[_nX,6]})
             EndIf 
             TRBZBD->(MsUnLock())           
         
             TRBZBD->(DbSkip()) 
          EndDo 

          _nSeq += 1
          
          If _nRestPale > 0
             U_AOMS132L(_nRestPale,_aRestPale) 
             _nRestPale := 0   // Zera as quantidades de Paletes residuais.
          EndIf 
      Next 

      Break // Gera apenas as Works dos Pré Pedidos de Vendas que possuem quantidade de itens menores que as quantidades de Paletes do tipo de veículo.
   EndIf     

   IncProc("Gerando Pre-Pedidos de Vendas....")

   //==================================================================
   // Quantidade de itens > Quantidade de Paletes do Veiculo
   //==================================================================
   If _nTotItZBD > _nPaletVeic

      _nI := Int(_nTotItZBD / _nPaletVeic) + 1      
      _nMaxItens := Int(_nTotItZBD / _nI )      

      _aGrupoIt := {}
      _aItens   := {}
      
      _nI := 1

      TRBZBD->(DbGoTop())
      Do While ! TRBZBD->(Eof())
         Aadd(_aItens, {TRBZBD->ZBD_ITEM,;    // Item                                  // 1
                        TRBZBD->ZBD_PRODUT,;  // Codigo do Produto                     // 2
                        TRBZBD->ZBD_QTDPAL,;  // Quantidade de Paletes                 // 3
                        TRBZBD->WK_QTDPAL,;   // Quantidade de Paletes                 // 4
                        TRBZBD->WK_QTDPPAL,;  // Quantidade por Paletes                // 5
                                         0,;  // Quantidade do item para pré pedido    // 6
                        TRBZBD->(Recno()),;   // Recno da tabela TRBZBD                // 7
                        .T.               })  // Continua a gerar itens de pré pedido  // 8
         _nI += 1
         If _nI > _nMaxItens
            Aadd(_aGrupoIt, _aItens)
            _aItens   := {}
            _nI := 1
            
         EndIf 

         TRBZBD->(DbSkip())
      EndDo 

      If Len(_aItens) > 0
         Aadd(_aGrupoIt, _aItens)
         _aItens := {}
      EndIf 

      For _nZ := 1 To Len(_aGrupoIt)
          
          _aItens := AClone(_aGrupoIt[_nZ])      

          _nTotalP := 0
          Do While .T.
             For _nX := 1 To Len(_aItens)
                 If _aItens[_nX,6] < _aItens[_nX,3]  .And. (_nTotalP + 1) <= _nPaletVeic // Quantidade de Palete Pre Pedido < Quantidade Paletes por item
                    _aItens[_nX,6] := _aItens[_nX,6] + 1
                    _nTotalP += 1  // _aItens[_nX,6]
                 EndIf 
             Next 
           
             If (_nTotalP + 1) > _nPaletVeic
                Exit 
             EndIf 
   
          EndDo 

          //==================================================================
          // Calcula a quantidade de Pré Pedidos de Vendas que serão gerados.
          //==================================================================
          _nQtdPalet := _nTotalP    // Total de Palete por Pré Pedido de Vendas.
          _nPaletes  := _nTotPallet // Total de Palete do Pedido de Compras.

          _nI := 1

          Do While _nPaletes > _nPaletVeic
             _nPaletes  := _nPaletes - _nQtdPalet
             _nI += 1
          EndDo  

          //==================================================================
          // Cria os Pré Pedidos de Vendas em Tabelas temporárias (Works).
          //==================================================================
          SB1->(DbSetOrder(1))

          For _nY := 1 To _nI

              TRBZBD->(DbGoTop())
          
              _nRestPale := 0  // Quantidade de Paletes residuais
              _aRestPale := {}
              
              _lGravouIt := .F.

              Do While ! TRBZBD->(Eof())

                 If TRBZBD->WK_QTDPAL == 0
                    TRBZBD->(DbSkip())
                    Loop 
                 EndIf 

                 _nX := Ascan(_aItens, {|x| x[1] == TRBZBD->ZBD_ITEM .And. x[2] == TRBZBD->ZBD_PRODUT})

                 If _nX == 0 // Produto + Item já processado.
                    TRBZBD->(DbSkip())
                    Loop 
                 EndIf
             
                 If _aItens[_nX,3] < _aItens[_nX,6]
                    _nQtd2    := _aItens[_nX,3] * TRBZBD->WK_QTDPPAL // Quantidade de Palete por Item x Quantidade por Palete
                 Else 
                    _nQtd2    := _aItens[_nX,6] * TRBZBD->WK_QTDPPAL // Quantidade de Palete por Item x Quantidade por Palete
                 EndIf 

                 SB1->(MsSeek(xFilial("SB1")+TRBZBD->ZBD_PRODUT))
      
                 If SB1->B1_TIPCONV == "M"
                    _nQtd  := _nQtd2 / SB1->B1_CONV   
                 Else
                    _nQtd  := _nQtd2 * SB1->B1_CONV
                 EndIf

                 _nValorTot := TRBZBD->ZBD_PRCVEN * _nQtd 

                 TRBZBF->(DbAppend())
                 TRBZBF->ZBF_PEDCOM := M->ZBC_PEDCOM       //"C", 20, 0 // Pedido de Compras
                 TRBZBF->ZBF_SEQ    := StrZero(_nSeq,3)    //"C", 2 , 0 // Sequencia
                 TRBZBF->ZBF_ITEM   := TRBZBD->ZBD_ITEM    //"C", 2 , 0 // Item
                 TRBZBF->ZBF_PRODUT := TRBZBD->ZBD_PRODUT  //"C", 15, 0 // Codigo do Produto
                 TRBZBF->ZBF_DESCRI := TRBZBD->ZBD_DESCRI  //"C", 50, 0 // Descrição do Produto
                 TRBZBF->ZBF_UNSVEN := _nQtd2              // TRBZBD->ZBD_UNSVEN  //"N", 9 , 3 // Qtd. Segunda Unidade Med.
                 TRBZBF->WK_UNSVEN  := TRBZBD->ZBD_UNSVEN  //"N", 9 , 3 // Qtd. Segunda Unidade Med.
                 TRBZBF->ZBF_SEGUM  := TRBZBD->ZBD_SEGUM   //"C", 2 , 0 // Segunda Unidade Medida
                 TRBZBF->ZBF_QTDVEN := _nQtd               // TRBZBD->ZBD_QTDVEN  //"N", 13, 3 // Qtd. Primeira Unidade Medida
                 TRBZBF->WK_QTDVEN  := _nQtd               // TRBZBD->ZBD_QTDVEN  //"N", 13, 3 // Qtd. Primeira Unidade Medida
                 TRBZBF->ZBF_UM     := TRBZBD->ZBD_UM      //"C", 2 , 0 // Primeira Unidade Medida
                 TRBZBF->ZBF_PRCVEN := TRBZBD->ZBD_PRCVEN  //"N", 18, 8 // Preço Unitário Liquido
                 TRBZBF->ZBF_VALOR  := _nValorTot          // TRBZBD->ZBD_VALOR   //"N", 12, 2 // Valor Total
                 TRBZBF->ZBF_LOCAL  := TRBZBD->ZBD_LOCAL   //"C", 2 , 0 // Armazém
                 TRBZBF->ZBF_QTDPAL := If(_aItens[_nX,3] < _aItens[_nX,6],_aItens[_nX,3],_aItens[_nX,6]) // _aItens[_nX,6] // Quantidade de Palete por Item//TRBZBD->ZBD_QTDPAL
                 TRBZBF->WK_QTDPAL  := If(_aItens[_nX,3] < _aItens[_nX,6],_aItens[_nX,3],_aItens[_nX,6]) // _aItens[_nX,6] // Quantidade de Paletes
                 TRBZBF->WK_QTDPPAL := TRBZBD->WK_QTDPPAL  //"N", 13, 3 // Quantidade por Paletes
                 TRBZBF->(MsUnLock())
                 
                 _lGravouIt := .T. 

                 TRBZBD->(RecLock("TRBZBD", .F.))
                 If (TRBZBD->WK_QTDPAL - _aItens[_nX,6]) > 0
                    TRBZBD->WK_QTDPAL := TRBZBD->WK_QTDPAL - _aItens[_nX,6] 
                    _aItens[_nX,3]    := _aItens[_nX,3] - _aItens[_nX,6]     // Faz o mesmo cálculo da Work para ajustar a quantidade de Palete por item. 
                 Else 
                    TRBZBD->WK_QTDPAL := 0
                    _aItens[_nX,8]    := .F.   
                    _nRestPale += _aItens[_nX,6] 
                    Aadd(_aRestPale,{_nX,_aItens[_nX,6]})
                 EndIf 
                 TRBZBD->(MsUnLock())           
         
                 TRBZBD->(DbSkip()) 
              EndDo 
              
              If _lGravouIt 
                 _nSeq += 1
              EndIf 

              If _nRestPale > 0
                 U_AOMS132L(_nRestPale,_aRestPale) 
                 _nRestPale := 0   // Zera as quantidades de Paletes residuais.
              EndIf 
          Next 

      Next 

      Break // Gera apenas as Works dos Pré Pedidos de Vendas que possuem quantidade de itens maiores que as quantidades de Paletes do tipo de veículo.

   EndIf     

End Sequence 

U_ItMsg("Fim da geração do Pré Pedido de Vendas!","Atenção","",2)

TRBZBF->(DbGoTop())

_lBtnGerPr := .T.  // Bloqueia botão gerar pre pedido de vendas.
_lTipoVeic := .T.  // Bloqueia combobox tipo de veiculo.

_oGetDBF:ForceRefresh()

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS132D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/03/2022
===============================================================================================================================
Descrição---------: Gera o Pré-Pedido de Vendas com base na quantidade de Pallets o Pedido de compras do Cliente.
===============================================================================================================================
Parametros--------: _nRestoP = Quantidade de Paletes residuais.
                    _aRestPale = 1 = Posição de _aItens
                               = 2 = _nRestoP = Quantidade de Paletes residuais.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132L(_nRestoP, _aRestPale) 
Local _nI, _nSobraQtd, _nResiduo
Local _lTemItem := .F.
Local _nX, _nRestoPalet

Begin Sequence 
 
/*
    Aadd(_aItens, {TRBZBD->ZBD_ITEM,;    // Item                                  // 1
                   TRBZBD->ZBD_PRODUT,;  // Codigo do Produto                     // 2
                   TRBZBD->ZBD_QTDPAL,;  // Quantidade de Paletes                 // 3
                   TRBZBD->WK_QTDPAL,;   // Quantidade de Paletes                 // 4
                   TRBZBD->WK_QTDPPAL,;  // Quantidade por Paletes                // 5
                                    0,;  // Quantidade do item para pré pedido    // 6
                   TRBZBD->(Recno()),;   // Recno da tabela TRBZBD                // 7
                   .T.               })  // Continua a gerar itens de pré pedido  // 8
*/ 
   _nResiduo := _nRestoP

   For _nI := 1 To Len(_aItens)   
       If _aItens[_nI,8] // Continua a gerar itens de pré pedido de vendas.
          
          _lTemItem := .T.

          If _aItens[_nI,3] > (_aItens[_nI,6] + _nResiduo) // Quantidade de Palete disponivel > (Quantidade de Palete por item + Residuo)
             _aItens[_nI,6] := _aItens[_nI,6] + _nResiduo
             Exit 
          ElseIf _aItens[_nI,3] > _aItens[_nI,6] // Quantidade de Palete disponivel > (Quantidade de Palete por item)
             _nSobraQtd     := _aItens[_nI,6] + _nResiduo - _aItens[_nI,3]
             _aItens[_nI,6] := _aItens[_nI,3] 
             _nResiduo := _nSobraQtd
          ElseIf _aItens[_nI,3] <= _nResiduo 
             _nSobraQtd     := _aItens[_nI,3] // _nResiduo 
             _aItens[_nI,6] := _aItens[_nI,3] // _nResiduo
             _nResiduo := _aItens[_nI,3]
          ElseIf _aItens[_nI,3] <= _aItens[_nI,6] 
             _nSobraQtd     := _aItens[_nI,3] 
             _aItens[_nI,6] := _aItens[_nI,3]
             _nResiduo := _aItens[_nI,3]
          EndIf 
       EndIf 
   Next 

   If ! _lTemItem
      For _nI := 1 To Len(_aRestPale)   
          _nX          := _aRestPale[_nI,1]
          _nRestoPalet := _aRestPale[_nI,2]
      Next
      
      _aItens[_nX,6] := _aItens[_nX,3]

   EndIf 

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS132N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/03/2022
===============================================================================================================================
Descrição---------: Rotina de manutenção de Quantidades e Vinculação de Pré-Pedidos de vendas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS132N()
Local _nLinha 
Local _aSizeAut  := MsAdvSize(.T.)
Local _nOpc := 0
Local _lFinalizar := .F. 
//Local _cSeqPed
Local _cNomeTipoV, _cVeiculo 

Private _cTipoVeic  := ""
Private _aTipoVeic  := {}
Private _aDadosVeic := {}
Private _cCodTpVeic := ""
Private _nQtdPalet 
Private aHeader := {}
Private aRotina := {}
Private _nTotPallet := 0, _oTotPallet
Private b2Click 
Private _cColunas   := "6,8" // Colunas editáveis // WK_GERPED , ZBD_UNSVEN , ZBD_QTDVEN
Private _nPaletVeic := 0
Private _oTipoVeic
Private _nTotItZBD  := 0
Private _oGetTRBF 
Private Altera := .T.
Private Inclui := .F.
Private _oBtnGerPr
Private _OBtnGrava 
Private _OBtnSair
Private _aDadosZBD 
Private _cFilPedVe

Private _lTipoVeic

Begin Sequence 
   
   ZBE->(DbSetOrder(2))
   If ! ZBE->(MsSeek(xFilial("ZBE")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
      U_ItMsg("Não existes Pre-Pedidos de Vendas Cadastrados para realização de manutenção.","Atenção","",1)
      Break
   EndIf 

   _cFilPedVe := Space(2)

   If ! Empty(ZBE->ZBE_FILGPV)
      _cFilPedVe := ZBE->ZBE_FILGPV
   EndIf 

   //=======================================================================
   // Carrega os itens da tabela ZBD para validação de Quantidades
   //=======================================================================  
   ZBD->(DbSetOrder(1))
   ZBD->(MsSeek(xFilial("ZBD")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
   
   _aDadosZBD := {}
   _nTotPallet := 0

   Do While ! ZBD->(Eof()) .And. ZBD->(ZBD_FILIAL+ZBD_PEDCOM+ZBD_CLIENT+ZBD_LOJACL) == xFilial("ZBD")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)
      
      Aadd(_aDadosZBD, {ZBD->ZBD_ITEM,;     // Item
                        ZBD->ZBD_PRODUT,;   // Codigo do Produto
                        ZBD->ZBD_DESCRI,;   // Descrição do Produto
                        ZBD->ZBD_UNSVEN,;   // Qtd. Segunda Unidade Med.
                        ZBD->ZBD_SEGUM,;    // Segunda Unidade Medida
                        ZBD->ZBD_QTDVEN,;   // Qtd. Primeira Unidade Medida
                        ZBD->ZBD_UM,;       // Primeira Unidade Medida
                        ZBD->ZBD_PRCVEN,;   // Preço Unitário Liquido
                        ZBD->ZBD_VALOR,;    // Valor Total
                        ZBD->ZBD_QTDPAL})   // Quantidade de Paletes
      
      _nTotPallet += ZBD->ZBD_QTDPAL

      ZBD->(DbSkip())
   EndDo   

 
   //=======================================================================
   // Carrega os dados de capa para exibição da tela.
   //======================================================================= 
   _nPaletVeic  := Posicione("DUT",1,xFilial("DUT")+ZBE->ZBE_TPVEIC,"DUT_I_QPAL") // _nQtdPalet
   _cNomeTipoV  := Posicione("DUT",1,xFilial("DUT")+ZBE->ZBE_TPVEIC,"DUT_DESCRI")
   _cVeiculo    := ZBE->ZBE_TPVEIC + "-" + _cNomeTipoV
   
   M->ZBC_PEDCOM := ZBC->ZBC_PEDCOM  // C	6	0	Ped.Compras	Pedido de Compras Cliente
   M->ZBC_CLIENT := ZBC->ZBC_CLIENT  // C	6	0	Cliente	Codigo do Cliente
   M->ZBC_LOJACL := ZBC->ZBC_LOJACL  // C	4	0	Loja Cliente	Loja do Cliente
   M->ZBC_NOME   := ZBC->ZBC_NOME 	 // C	60	0	Nome Cliente	Nome Cliente
   M->ZBC_EST    := ZBC->ZBC_EST     // C	2	0	Estado	Estado
   M->ZBC_MUN    := ZBC->ZBC_MUN 	 // C	50	0	Municipio	Municipio
   M->ZBC_CEP    := ZBC->ZBC_CEP  	 // C	8	0	CEP	CEP
   M->ZBC_BAIREN := ZBC->ZBC_BAIREN  // C	50	0	Bairro	Bairro
   M->ZBC_DDD    := ZBC->ZBC_DDD     // C	3	0	DDD	DDD
   M->ZBC_TELEFO := ZBC->ZBC_TELEFO  // C	15	0	Telefone	Telefone
   M->ZBC_OPERAC := ZBC->ZBC_OPERAC  // C	2	0	Tp.Operação 	Tipo de Operação
   M->ZBC_AGENDA := ZBC->ZBC_AGENDA  // C	1	0	Tp Entrega  	Tipo de Entrega
   M->ZBC_TIPO   := ZBC->ZBC_TIPO    // C	1	0	Tipo Pedido 	Tipo de Pedido
   M->ZBC_DTENT  := ZBC->ZBC_DTENT   // D	8	0	Data Entrega	Data de Entrega
   M->ZBC_VEND1  := ZBC->ZBC_VEND1   // C	6	0	Vendedor	Vendedor

   M->ZBC_TRCNF  := If(ZBC->ZBC_TRCNF=="S","Sim","Nao")
   M->ZBC_FLFNC  := ZBC->ZBC_FLFNC 
   M->ZBC_FILFT  := ZBC->ZBC_FILFT
   
   //===============================================================
   // Work com a capa dos Pré Pedidos de Vendas.
   //===============================================================
   _aStruct2 := {}
   Aadd(_aStruct2, {"ZBF_PEDCOM", "C", 20, 0}) // Pedido de Compras
   Aadd(_aStruct2, {"ZBF_SEQ"   , "C", 3 , 0}) // Sequencia
   Aadd(_aStruct2, {"ZBF_AGRUPA", "C", 1 , 0}) // Agrupador
   Aadd(_aStruct2, {"ZBF_ITEM"  , "C", 2 , 0}) // Item
   Aadd(_aStruct2, {"ZBF_PRODUT", "C", 15, 0}) // Codigo do Produto
   Aadd(_aStruct2, {"ZBF_DESCRI", "C", 50, 0}) // Descrição do Produto
   Aadd(_aStruct2, {"ZBF_UNSVEN", "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct2, {"WK_UNSVEN" , "N", 9 , 3}) // Qtd. Segunda Unidade Med.
   Aadd(_aStruct2, {"ZBF_SEGUM" , "C", 2 , 0}) // Segunda Unidade Medida
   Aadd(_aStruct2, {"ZBF_QTDVEN", "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct2, {"WK_QTDVEN" , "N", 13, 3}) // Qtd. Primeira Unidade Medida
   Aadd(_aStruct2, {"ZBF_UM"    , "C", 2 , 0}) // Primeira Unidade Medida
   Aadd(_aStruct2, {"ZBF_PRCVEN", "N", 18, 8}) // Preço Unitário Liquido
   Aadd(_aStruct2, {"ZBF_VALOR" , "N", 12, 2}) // Valor Total
   Aadd(_aStruct2, {"ZBF_LOCAL" , "C", 2 , 0}) // Armazém
   Aadd(_aStruct2, {"ZBF_QTDPAL", "N", 3 , 0}) // Quantidade de Paletes
   Aadd(_aStruct2, {"WK_RECNO"  , "N", 10, 0}) // Recno do Item ZBD
   
   If Select("TRBZBF") > 0
	   TRBZBF->(Dbclosearea())
   EndIf

   _otemp2 := FWTemporaryTable():New("TRBZBF", _aStruct2 )
   _otemp2:AddIndex( "01", {"ZBF_PEDCOM", "ZBF_SEQ" , "ZBF_ITEM"} )
   
   _otemp2:Create()
   
   //==============================================================================
   // Grava os dados da tabela temporaria TRBZBF
   //==============================================================================
   ZBF->(DbSetOrder(3)) // ZBF_FILIAL+ZBF_PEDCOM+ZBF_CLIENT+ZBF_LOJACL+ZBF_SEQ 
   ZBF->(MsSeek(xFilial("ZBF")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
   
   Do While ! ZBF->(Eof()) .And. ZBF->(ZBF_FILIAL+ZBF_PEDCOM+ZBF_CLIENT+ZBF_LOJACL) == xFilial("ZBF")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)
      TRBZBF->(DbAppend())
      TRBZBF->ZBF_PEDCOM   := ZBF->ZBF_PEDCOM   // Pedido de Compras
      TRBZBF->ZBF_SEQ      := ZBF->ZBF_SEQ      // Sequencia
      TRBZBF->ZBF_AGRUPA   := ZBF->ZBF_AGRUPA   // Agrupador
      TRBZBF->ZBF_ITEM     := ZBF->ZBF_ITEM     // Item
      TRBZBF->ZBF_PRODUT   := ZBF->ZBF_PRODUT   // Codigo do Produto
      TRBZBF->ZBF_DESCRI   := ZBF->ZBF_DESCRI   // Descrição do Produto
      TRBZBF->ZBF_UNSVEN   := ZBF->ZBF_UNSVEN   // Qtd. Segunda Unidade Med.
      TRBZBF->WK_UNSVEN    := ZBF->ZBF_UNSVEN   // Qtd. Segunda Unidade Med.
      TRBZBF->ZBF_SEGUM    := ZBF->ZBF_SEGUM    // Segunda Unidade Medida
      TRBZBF->ZBF_QTDVEN   := ZBF->ZBF_QTDVEN   // Qtd. Primeira Unidade Medida
      TRBZBF->WK_QTDVEN    := ZBF->ZBF_QTDVEN   // Qtd. Primeira Unidade Medida
      TRBZBF->ZBF_UM       := ZBF->ZBF_UM       // Primeira Unidade Medida
      TRBZBF->ZBF_PRCVEN   := ZBF->ZBF_PRCVEN   // Preço Unitário Liquido
      TRBZBF->ZBF_VALOR    := ZBF->ZBF_VALOR    // Valor Total
      TRBZBF->ZBF_LOCAL    := ZBF->ZBF_LOCAL    // Armazém
      TRBZBF->ZBF_QTDPAL   := ZBF->ZBF_QTDPAL   // Quantidade de Paletes
      TRBZBF->WK_RECNO     := ZBF->(Recno())    // Recno do Item ZBD
      TRBZBF->(MsUnLock())

      ZBF->(DbSkip())
   EndDo 

   //==============================================================================
   // Monta aHeader do msgetdb.
   //==============================================================================
   Aadd(aHeader,{"Pedido Comparas"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_PEDCOM"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PEDCOM","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PEDCOM","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                                                      0 ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Sequencia"                           ,;   // 1  = X3_TITULO                   3
                 "ZBF_SEQ"                             ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEQ","X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 8                                     ,;   // 4  = X3_TAMANHO // getsx3cache("ZBF_SEQ","X3_TAMANHO")
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Agrupador"                            ,;   // 1  = X3_TITULO                   2
                 "ZBF_AGRUPA"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_AGRUPA","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                                                      10,;   // 4  = X3_TAMANHO            
                                                       0,;   // 5  = X3_DECIMAL
                 getsx3cache("ZBF_AGRUPA","X3_VALID")   ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "C"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 getsx3cache("ZBF_AGRUPA","X3_CBOX")    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Item"                               ,;   // 1  = X3_TITULO                   3
                 "ZBF_ITEM"                            ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_ITEM","X3_PICTURE")  ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_ITEM","X3_TAMANHO")  ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Produto"                             ,;   // 1  = X3_TITULO                4   
                 "ZBF_PRODUT"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRODUT","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRODUT","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Descrição Prod"                      ,;   // 1  = X3_TITULO                 5  
                 "ZBF_DESCRI"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_DESCRI","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_DESCRI","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Qtde Paletes"                         ,;   // 1  = X3_TITULO                   2
                 "ZBF_QTDPAL"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDPAL","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDPAL","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDPAL","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                     ,;   // 6  = X3_VALID                 
                                                     "" ,;   // 7  = X3_USADO
                 "N"                                    ,;   // 8  = X3_TIPO                   
                                                     "" ,;   // 9  = X3_CONTEXT
                 ""                                     })   // 10 = X3_CBOX

   Aadd(aHeader,{"Qtd.Atual.2 Un.Med."                     ,;   // 1  = X3_TITULO                  6 
                 "WK_UNSVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UNSVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UNSVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_UNSVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX 
   Aadd(aHeader,{"Qtd.2 Unid.Med."                     ,;   // 1  = X3_TITULO                  6 
                 "ZBF_UNSVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UNSVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UNSVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_UNSVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX 

   Aadd(aHeader,{"Seg.Unid.Medida"                     ,;  // 1  = X3_TITULO                 7  
                 "ZBF_SEGUM"                           ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_SEGUM","X3_PICTURE") ,;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_SEGUM" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 0                                    ,;    // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
 
   Aadd(aHeader,{"Qtd.1 Unid Med"                      ,;  // 1  = X3_TITULO                   8
                 "ZBF_QTDVEN"                          ,;    // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDVEN","X3_PICTURE"),;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDVEN" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDVEN","X3_DECIMAL"),;    // 5  = X3_DECIMAL
                 ""                                    ,;    // 6  = X3_VALID                 
                                                     "",;    // 7  = X3_USADO
                 "N"                                   ,;    // 8  = X3_TIPO                   
                                                     "",;    // 9  = X3_CONTEXT
                 ""                                    })    // 10 = X3_CBOX

   Aadd(aHeader,{"Qtd.Atual 1 Un Med"                 ,;     // 1  = X3_TITULO                   8
                 "WK_QTDVEN"                          ,;     // 2  = X3_CAMPO
                 getsx3cache("ZBF_QTDVEN","X3_PICTURE"),;    // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_QTDVEN" ,"X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_QTDVEN","X3_DECIMAL"),;    // 5  = X3_DECIMAL
                 ""                                    ,;    // 6  = X3_VALID                 
                                                     "",;    // 7  = X3_USADO
                 "N"                                   ,;    // 8  = X3_TIPO                   
                                                     "",;    // 9  = X3_CONTEXT
                 ""                                    })    // 10 = X3_CBOX

   Aadd(aHeader,{"1.Unid.Medida"                       ,;   // 1  = X3_TITULO                  9 
                 "ZBF_UM"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_UM" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_UM" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Prc.Unitario"                        ,;   // 1  = X3_TITULO                 10  
                 "ZBF_PRCVEN"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_PRCVEN","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_PRCVEN","X3_TAMANHO"),;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_PRCVEN","X3_DECIMAL"),;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Valor Total"                         ,;   // 1  = X3_TITULO                11   
                 "ZBF_VALOR"                           ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_VALOR","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_VALOR","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                 getsx3cache("ZBF_VALOR","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                 ""                                    ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "N"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""                                    })   // 10 = X3_CBOX
   
   Aadd(aHeader,{"Armazém"                                ,;   // 1  = X3_TITULO               12    
                 "ZBF_LOCAL"                              ,;   // 2  = X3_CAMPO
                 getsx3cache("ZBF_LOCAL" ,"X3_PICTURE")   ,;   // 3  = X3_PICTURE                    
                 getsx3cache("ZBF_LOCAL" ,"X3_TAMANHO")   ,;   // 4  = X3_TAMANHO            
                 0                                        ,;   // 5  = X3_DECIMAL
                 ""                                       ,;   // 6  = X3_VALID                 
                                                     ""   ,;   // 7  = X3_USADO
                 "C"                                      ,;   // 8  = X3_TIPO                   
                                                     ""   ,;   // 9  = X3_CONTEXT
                 ""                                       })   // 10 = X3_CBOX

   //======================================================
   // Configurações iniciais
   //======================================================
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 

   aRotina := {}   
   AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"		,"AxExclui",0,5})
   Inclui := .F.
   Altera := .T.
   
   //_bGerPrePd := {|| Processa( {|| U_AOMS132D() , _oDlgManut:End()} , 'Aguarde!' , 'Gerando Pré Pedido de Vendas...' )}
   _lTipoVeic := .F.

   Do While .T. 
      TRBZBF->(DbGoTop())

      DEFINE MSDIALOG _oDlgManut TITLE "Manutenção Pré Pedido de Vendas" FROM _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] PIXEL // 00,00 TO 300,400

          @ _aPosObj[2,3]-30, 05  BUTTON _OBtnGrava PROMPT "&Gravar"  SIZE 70, 012 OF _oDlgManut ACTION ( If(U_AOMS132O("TUDOOK_MANUT"),(_nOpc := 1, _lFinalizar := .T. ,_oDlgManut:End()),_nOpc := 0)) PIXEL
          @ _aPosObj[2,3]-30, 90  BUTTON _OBtnSair  PROMPT "&Sair"	 SIZE 50, 012 OF _oDlgManut ACTION ( (_nOpc := 0, _lFinalizar := .T. ,_oDlgManut:End()) ) PIXEL

          _nLinha := 15
          @ _nLinha, 10 Say "Ped.Compras"	Pixel Size  030,012 Of _oDlgManut
          @ _nLinha, 60 MSGet M->ZBC_PEDCOM  Pixel Size 040,012 WHEN .F. Of _oDlgManut
     
          @ _nLinha, 115 Say "Tipo de Veiculo"	Pixel Size 040,012 Of _oDlgManut
          @ _nLinha, 170 MSGet _cVeiculo  Pixel Size 130,012 WHEN .F. Of _oDlgManut
         // @ _nLinha, 170 MSCOMBOBOX _oTipoVeic Var _cTipoVeic ITEMS _aTipoVeic Valid(U_AOMS132Z("TIPO_VEICULO")) Pixel Size 160, 012 Of _oDlgManut 

          @ _nLinha, 320 Say "Filial para Geração Ped.Venda"	Pixel Size 050,022 Of _oDlgManut
          @ _nLinha, 375 MSGet _cFilPedVe  Pixel Size 20,012 F3 "ZZM" Valid(ExistCPO("ZZM",_cFilPedVe)) Of _oDlgManut

          @ _nLinha, 405 Say "Total Pallets Veiculo:"	Pixel Size  080,012 Of _oDlgManut
          @ _nLinha, 465 MSGet _nPaletVeic Pixel Size 040,012 WHEN .F. Of _oDlgManut
      
          @ _nLinha, 520 Say "Total de Pallets do Pedido:"	Pixel Size  080,012 Of _oDlgManut
          @ _nLinha, 590 MSGet _oTotPallet Var _nTotPallet Pixel Size 040,012 WHEN .F. Of _oDlgManut

          _nLinha += 20
          @ _nLinha, 10 Say "Troca Nota"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 60 MSGet M->ZBC_TRCNF Pixel Size 040,012 WHEN .F. Of _oDlgManut

          @ _nLinha, 115 Say "Filial Faturamento"	Pixel Size 040, 020 Of _oDlgManut
          @ _nLinha, 170 MSGet M->ZBC_FLFNC Pixel Size 040,009 WHEN .F. Of _oDlgManut

          @ _nLinha, 255 Say "Filial Carregamento"	Pixel Size 040,020 Of _oDlgManut
          @ _nLinha, 305 MSGet M->ZBC_FILFT Pixel Size 100,012 WHEN .F. Of _oDlgManut
 

          _nLinha += 20
          @ _nLinha, 10 Say "Cliente"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 60 MSGet M->ZBC_CLIENT Pixel Size 040,012 WHEN .F. Of _oDlgManut

          @ _nLinha, 115 Say "Loja Cliente"	Pixel Size 040, 012 Of _oDlgManut
          @ _nLinha, 170 MSGet M->ZBC_LOJACL Pixel Size 040,009 WHEN .F. Of _oDlgManut

          @ _nLinha, 255 Say "Nome Cliente"	Pixel Size 040,012 Of _oDlgManut
          @ _nLinha, 305 MSGet M->ZBC_NOME Pixel Size 100,012 WHEN .F. Of _oDlgManut
        
          _nLinha += 20

          @ _nLinha, 10 Say "Estado"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 60 MSGet M->ZBC_EST Pixel Size 040,012 WHEN .F. Of _oDlgManut

          @ _nLinha, 115 Say "Municipio"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 170 MSGet M->ZBC_MUN Pixel Size 060,012 WHEN .F. Of _oDlgManut

          @ _nLinha, 255 Say "CEP"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 305 MSGet M->ZBC_CEP Pixel Size 040,012 WHEN .F. Of _oDlgManut
        
          @ _nLinha, 375 Say "Bairro"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 415 MSGet M->ZBC_BAIREN Pixel Size 080,012 WHEN .F. Of _oDlgManut
        
          _nLinha += 20

          @ _nLinha, 10 Say "DDD"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 60 MSGet M->ZBC_DDD Pixel Size 040,012 WHEN .F. Of _oDlgManut

          @ _nLinha, 115 Say "Telefone"	Pixel Size 030,012 Of _oDlgManut
          @ _nLinha, 170 MSGet M->ZBC_TELEFO Pixel Size 040,012 WHEN .F. Of _oDlgManut

          @ _nLinha, 255 Say "Tp.Operação"	Pixel Size 040,012 Of _oDlgManut
          @ _nLinha, 305 MSGet M->ZBC_OPERAC Pixel Size 040,012 WHEN .F. Of _oDlgManut

          @ _nLinha, 375 Say "Tipo Pedido"	Pixel Size 040,012 Of _oDlgManut
          @ _nLinha, 415 MSGet M->ZBC_TIPO Pixel Size 040,012 WHEN .F. Of _oDlgManut

          //_nLinha += 20

          @ _nLinha, 475 Say "Data Entrega"	Pixel Size 040,012 Of _oDlgManut
          @ _nLinha, 515 MSGet M->ZBC_DTENT Pixel Size 040,012 WHEN .F. Of _oDlgManut
        
          @ _nLinha, 570 Say "Vendedor"	Pixel Size 040,012 Of _oDlgManut
          @ _nLinha, 605 MSGet M->ZBC_VEND1 Pixel Size 040,012 WHEN .F. Of _oDlgManut
          _nLinha += 20

                //MsGetDB():New ( < nTop>, < nLeft>, < nBottom>       , < nRight>         ,< nOpc>, [ cLinhaOk]             , [ cTudoOk]            ,[ cIniCpos], [ lDelete] , [ aAlter]      , [ nFreeze], [ lEmpty], [ uPar1], < cTRB>  , [ cFieldOk]            , [ uPar2], [ lAppend], [ oWnd] , [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] ) --> oObj
          _oGetTRBF := MsGetDB():New (_nLinha, 0       , _aPosObj[2,3]-50 , _aPosObj[2,4]     , 4     , "U_AOMS132O('LINHAOK_MANUT')" , "U_AOMS132O('TUDOOK_MANUT')", ""         , .F.       , {'ZBF_UNSVEN','ZBF_QTDVEN', 'ZBF_AGRUPA'}             , 0         , .F.       ,        , "TRBZBF" , "U_AOMS132O('FIELDOK_MANUT')",         , .F.       , _oDlgManut, .F.) //         ,         ,""        , "")
       
          //b2Click := _oGetTRBF:oBrowse:bLDblClick
          // _oGetTRBF:oBrowse:bLDblClick := { || U_AOMS132Y("TRBZBD" , TRBZBD->WK_GERPED) }

          //_oGetTRBF:oBrowse:bAdd := {||.T.} // não inclui novos itens MsGetDb()
          _oGetTRBF:Enable( ) 
          
          If _lTipoVeic 
             _oTipoVeic:Disable()  
          EndIf 
          
          TRBZBF->(DbGoTop())
          _oGetTRBF:ForceRefresh( )

      ACTIVATE MSDIALOG _oDlgManut CENTERED
    
      If _lFinalizar
         Exit 
      EndIf 

   EndDo  

   If _nOpc == 1
       
      If ! U_ItMsg("Confirma a gravação da manutenção do Pré Pedido de Vendas?" ,"Atenção", , ,2, 2)
         Break
      EndIf 

      ZBE->(DbSetOrder(2))
      ZBE->(MsSeek(xFilial("ZBE")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))

      Begin Transaction 
         TRBZBF->(Dbgotop())
         
         Do While ! TRBZBF->(Eof())
            
            ZBF->(DbGoto(TRBZBF->WK_RECNO))                 

            ZBF->(RecLock("ZBF",.F.))
            //ZBF->ZBF_SEQ    := TRBZBF->ZBF_SEQ
            //ZBF->ZBF_ITEM	:= TRBZBF->ZBF_ITEM         // Item
            //ZBF->ZBF_PRODUT := TRBZBF->ZBF_PRODUT	    // Codigo do Produto
            //ZBF->ZBF_DESCRI := TRBZBF->ZBF_DESCRI       // Descrição do Produto
            ZBF->ZBF_AGRUPA   := TRBZBF->ZBF_AGRUPA       // Agrupador de pedidos de vendas.
            ZBF->ZBF_UNSVEN   := TRBZBF->ZBF_UNSVEN	    // Segunda Unidade Med.
            ZBF->ZBF_SEGUM    := TRBZBF->ZBF_SEGUM        // Segunda Unidade Medida
            ZBF->ZBF_QTDVEN   := TRBZBF->ZBF_QTDVEN	    // Qtd. Primeira Unidade Medida
            //ZBF->ZBF_UM	   := TRBZBF->ZBF_UM	          // Primeira Unidade Medida
            //ZBF->ZBF_PRCVEN := TRBZBF->ZBF_PRCVEN   	 // Preço Unitário Liquido
            ZBF->ZBF_VALOR    := TRBZBF->ZBF_VALOR	 	    // Valor Total
            //ZBF->ZBF_LOCAL  := TRBZBF->ZBF_LOCAL	       // Armazém
            ZBF->ZBF_QTDPAL   := TRBZBF->ZBF_QTDPAL	 	 // Quantidade de Paletes
            ZBF->ZBF_FILGPV   := _cFilPedVe               // Filial para geração do pedido de vendas.
            ZBF->(MsUnLock())

            TRBZBF->(DbSkip())
         EndDo 

         Do While ! ZBE->(Eof()) .And. ZBE->(ZBE_FILIAL+ZBE_PEDCOM+ZBE_CLIENT+ZBE_LOJACL) == xFilial("ZBE")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)
            
            ZBE->(RecLock("ZBE",.F.))
            ZBE->ZBE_FILGPV := _cFilPedVe // Filial para geração do pedido de vendas.
            ZBE->ZBE_FLFNC  := _cFilPedVe // Filial de carregamento.
            ZBE->(MsUnLock()) 

            ZBE->(DbSkip())
         EndDo 
         
         ZBC->(RecLock("ZBC", .F.))
         ZBC->ZBC_FLFNC := _cFilPedVe  // Filial de carregamento.
         ZBC->(MsUnLock()) 

      End Transaction 
   
   EndIf         
   
   U_ItMsg("Manutenção do Pré Pedido de Vendas concluida!","Atenção","",2)

End Sequence 

If Select("TRBZBF") > 0
   TRBZBF->(Dbclosearea())
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS132N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/03/2022
===============================================================================================================================
Descrição---------: Rotina de validação das manutenções de Quantidades e Vinculação de Pré-Pedidos de vendas.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a validação.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Validado
                            .F. = Não validado
===============================================================================================================================
*/  
User Function AOMS132O(_cCampo)
Local _lRet := .T.
Local _aDadosZBD := {}
Local _nI 
Local _nRegAtu := TRBZBF->(Recno())

Begin Sequence 
   
   If _cCampo == "ZBF_UNSVEN" // quantidade segunda unidade de medida 
      M->ZBF_UNSVEN
      _nQtd2    :=  M->ZBF_UNSVEN // TRBZBF->ZBF_UNSVEN
      _nPrcVend := TRBZBF->ZBF_PRCVEN 
             
      If _nQtd2 == 0
         Break 
      EndIf 

      _cCod := TRBZBF->ZBF_PRODUT
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial("SB1")+_cCod))
      
      If SB1->B1_TIPCONV == "M"
         _nQtd  := _nQtd2 / SB1->B1_CONV   
      Else
         _nQtd  := _nQtd2 * SB1->B1_CONV
      EndIf

   	_nCXPalet  :=	SB1->B1_I_CXPAL
      
      If _nCXPalet == 0
         U_ItMsg('A quantidade de caixas por palete não foi informada para este produto.',"Atenção","",1)
         _lRet := .F.
         Break
      EndIf 

	   If mod(_nQtd2, _nCXPalet) > 0
         U_ItMsg('A quantidade informada na segunda unidade de medida não é multipla das quantidade de caixas por palete para este item. ['+ StrZero(_nCXPalet,4)+"] por palete.","Atenção","",1)
         _lRet := .F.
         Break
      EndIf 

      _nQtdPalet := 0 

      If _nCXPalet <> 0

	      If mod(_nQtd2, _nCXPalet) > 0

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) + 1 		

	      Else

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) 

	      EndIf

      EndIf
      
      _nValorTot := _nPrcVend * _nQtd 
      
      TRBZBF->(RecLock("TRBZBF",.F.))
      TRBZBF->ZBF_QTDVEN := _nQtd
      TRBZBF->ZBF_QTDPAL := _nQtdPalet
      TRBZBF->ZBF_VALOR  := _nValorTot
      TRBZBF->(MsUnLock())

   ElseIf _cCampo == "ZBF_QTDVEN"  // quantidade primeira unidade

      _nQtd     := M->ZBF_QTDVEN // TRBZBF->ZBF_QTDVEN
      _nPrcVend := TRBZBF->ZBD_PRCVEN 

      If _nQtd == 0
         U_ItMsg('O preenchimento da quantidade do item na primeira unidade de medida é obritório.',"Atenção","",1)
         _lRet := .F.
         Break 
      EndIf 

      _cCod     := TRBZBF->ZBF_PRODUT
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial("SB1")+_cCod))
      
      If SB1->B1_TIPCONV == "M"
         _nQtd2 := _nQtd * SB1->B1_CONV   
      Else
         _nQtd2  := _nQtd / SB1->B1_CONV
      EndIf
      
      _nCXPalet  :=	SB1->B1_I_CXPAL

      If _nCXPalet == 0
         U_ItMsg('A quantidade de caixas por palete não foi informada para este produto.',"Atenção","",1)
         _lRet := .F.
         Break
      EndIf 

	   If mod(_nQtd2, _nCXPalet) > 0
         U_ItMsg('A quantidade informada na primeira unidade de medida não é multipla das quantidade de caixas por palete para este item. ['+StrZero(_nCXPalet,4)+"] por palete.","Atenção","",1) 
         _lRet := .F.
         Break
      EndIf 

      _nQtdPalet := 0 

      If _nCXPalet <> 0

	      If mod(_nQtd2, _nCXPalet) > 0

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) + 1 		

	      Else

		      _nQtdPalet := int(_nQtd2 /_nCXPalet) 

	      EndIf

      EndIf
    
      _nValorTot := _nPrcVend * _nQtd 

      TRBZBF->(RecLock("TRBZBF",.F.))      
      TRBZBF->ZBF_UNSVEN  := _nQtd2
      TRBZBF->ZBF_QTDPAL  := _nQtdPalet
      TRBZBF->ZBF_VALOR   := _nValorTot
      TRBZBF->(MsUnLock())
   
   ElseIf _cCampo == "TUDOOK_MANUT" // Validação total
      
      If Empty(_cFilPedVe)
         U_ItMsg('A filial de geração do pedido de vendas precisa ser informada.',"Atenção","",1) 
         _lRet := .F.
         Break 
      EndIf 

      // 'LINHAOK_MANUT')" , "U_AOMS132O('TUDOOK_MANUT')", ""         , .F.       , {'ZBF_UNSVEN','ZBF_QTDVEN', 'ZBF_AGRUPA'}             , 0         , .F.       ,        , "TRBZBF" , "U_AOMS132O('FIELDOK_MANUT')"
      //=======================================================================
      // Carrega os itens da tabela ZBD para validação de Quantidades
      //=======================================================================  
      ZBD->(DbSetOrder(1))
      ZBD->(MsSeek(xFilial("ZBD")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)))
   
      _aDadosZBD := {}
      _nTotPallet := 0

      Do While ! ZBD->(Eof()) .And. ZBD->(ZBD_FILIAL+ZBD_PEDCOM+ZBD_CLIENT+ZBD_LOJACL) == xFilial("ZBD")+ZBC->(ZBC_PEDCOM+ZBC_CLIENT+ZBC_LOJACL)
      
         Aadd(_aDadosZBD, {ZBD->ZBD_PEDCOM,;   // Pedido de Compras               // 1
                           ZBD->ZBD_ITEM,;     // Item                            // 2
                           ZBD->ZBD_PRODUT,;   // Codigo do Produto               // 3
                           ZBD->ZBD_DESCRI,;   // Descrição do Produto            // 4
                           ZBD->ZBD_UNSVEN,;   // Qtd. Segunda Unidade Med.       // 5 
                           ZBD->ZBD_SEGUM,;    // Segunda Unidade Medida          // 6
                           ZBD->ZBD_QTDVEN,;   // Qtd. Primeira Unidade Medida    // 7   
                           ZBD->ZBD_UM,;       // Primeira Unidade Medida         // 8
                           ZBD->ZBD_PRCVEN,;   // Preço Unitário Liquido          // 9
                           ZBD->ZBD_VALOR,;    // Valor Total                     // 10
                           ZBD->ZBD_QTDPAL})   // Quantidade de Paletes           // 11 
         ZBD->(DbSkip())
      EndDo   

      For _nI := 1 To Len(_aDadosZBD)
          TRBZBF->(MsSeek(_aDadosZBD[_nI,1]+_aDadosZBD[_nI,2]))
        
          _nSomaQtd1 := 0
          _nSomaQtd2 := 0
          Do While ! TRBZBF->(Eof()) .And. TRBZBF->ZBF_PEDCOM + TRBZBF->ZBF_ITEM == _aDadosZBD[_nI,1]+_aDadosZBD[_nI,2]
             _nSomaQtd1 += TRBZBF->ZBF_QTDVEN
             _nSomaQtd2 += TRBZBF->ZBF_UNSVEN

             TRBZBF->(DbSkip())
          EndDo 
          
          If _nSomaQtd1 >  _aDadosZBD[_nI,7] .Or. _nSomaQtd2 >  _aDadosZBD[_nI,5] 
             U_ItMsg('As quantidades informadas para o item: '+AllTrim(_aDadosZBD[_nI,2])+" - "+ AllTrim(_aDadosZBD[_nI,3])+" - "+AllTrim(_aDadosZBD[_nI,4])+;
                     ', é superior as quantidades informadas no pedido de compras principal.',"Atenção","",1) 
             _lRet := .F.
             Break
          EndIf 

      Next 

   EndIf

End Sequence 

TRBZBF->(DbGoto(_nRegAtu))
_oGetTRBF:ForceRefresh()

Return _lRet 


/*
===============================================================================================================================
Programa----------: AOMS132F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 24/03/2022
===============================================================================================================================
Descrição---------: Rotina de Geração dos Pedidos de Vendas no Protheus. Gera SC5 e SC6.
===============================================================================================================================
Parametros--------: _aCab    = Cabeçalho do Pedidos de Vendas
                    _aDet    = Itens do Pedido de Vendas
                    _aRecZBF = Array com os recnos da tabela ZBF
===============================================================================================================================
Retorno-----------: _lRet = .T. = Gerou pedido de vendas.
                            .F. = Não gerou pedido de vendas.
===============================================================================================================================
*/  
User Function AOMS132F(_aCab, _aDet, _aRecZBF, _nTotPalete)
Local _lRet := .T.
Local _nI 
Local _nRecPedOrig, _cPedOrigem, _cPedPallet

Begin Sequence 

   lMsErroAuto := .F.
   
   MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCab , _aDet, 3 )

   IF lMSErroAuto
      If ( __lSx8 )
			RollBackSx8()
		EndIf

      U_ITMSG("Não foi possivel incluir o pedido de vendas. " ,"Atenção",,1)
      Mostraerro()
      _lRet := .F.

   Else 
      _nRecPedOrig := SC5->(Recno())
      _cPedOrigem  := SC5->C5_NUM
      U_ITMSG("Pedido de Vendas incluido com sucesso. Pedido de Vendas Numero: " + AllTrim(SC5->C5_NUM)+".","Atenção",,2)
         
      ProcRegua(0)
      Processa( {|| _cPedPallet := U_AOMS132Q(SC5->C5_NUM, _nTotPalete, SC5->(Recno())) } , 'Aguarde!' , 'Gerando pedido de paletes...' )
      
      For _nI := 1 To Len(_aRecZBF)
          ZBF->(DbGoTo(_aRecZBF[_nI]))

          ZBF->(RecLock("ZBF",.F.))
          ZBF->ZBF_PVPROT := _cPedOrigem
          If ! Empty(_cPedPallet)
             ZBF->ZBF_PLPROT := _cPedPallet
          EndIf 
          ZBF->(MsUnLock())
      Next 

   EndIf 

End Sequence 

Return _lRet 

