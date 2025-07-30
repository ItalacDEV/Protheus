/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |03/04/2022| Chamado 39846 - Correcao do erro.log variable does not exist _CCODIGO. 
Julio Paz     |27/05/2022| Chamado 39091 - Desenvolver rotina que permita copiar regras de comiss�o para varios vendedores
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipula��o do SX1
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
================================================================================================================================

=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Altera��o
---------------------------------------------------------------------------------------------------------------------------------------------------------
Antonio Ramos    -  Igor Melga�o     - 27/09/2024 - 24/10/2024 - 47892   - Filtro de produto na consulta padrao.
Antonio Ramos    -  Igor Melga�o     - 22/10/2024 - 24/10/2024 - 47892   - Ajuste no Filtro de produto na consulta padrao.
Antonio Ramos    -  Igor Melga�o     - 04/07/2025 - 04/07/2025 - 51135   - Ajustes para corre��o de error.log
=========================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

#Define CRLF Chr(13)+Chr(10)
#Define _nOperInclusao 3
#Define _nOperAlteracao 4
#Define _nOperExclusao 5

Static __LAFIN004 := .F.

/*
===============================================================================================================================
Programa----------: AFIN004
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Cadastro das Regras de Comiss�o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AFIN004()
LOCAL _nI
LOCAL _aBoxAux:= RetSX3Box(GetSX3Cache("B1_I_BIMIX", "X3_CBOX"),,,LEN(SB1->B1_I_BIMIX))

Private _aGridVld   := {} 
Private _cProduto, _cCliente, _cLoja, _cRede
Private _cFiltroRede    := Space(6)
Private _cFiltroCliente := Space(6)
Private _cFiltroLoja    := Space(4)
Private _cFiltroPrd     := Space(15)
Private _cFiltroGrupo   := Space(4)
Private _cFiltroExato   := Space(1)
Private _oBrowse	    := Nil
Private aRotina         := MenuDef()
Private _aDadosCapa     := {}
Private _aDadosItem     := {}
Private _aBoxMix        := {}
Private _cMIXBI         := "  "

__LAFIN004 := .T. 

For _nI := 1 To Len(_aBoxAux)
	IF !EMPTY(_aBoxAux[_nI][2])
       AADD(_aBoxMix, _aBoxAux[_nI][2] + "-" + _aBoxAux[_nI][3])
	ENDIF
Next
 _cMIXBI:= SPACE((Len(_aBoxAux)*3))

Public _cVenCRC	:= ''

U_ITUNQSX2( 'ZAE' , 'ZAE_FILIAL+ZAE_VEND+ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA' )

//Grava Log de uso
U_ITLOGACS()

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias('ZAE')
_oBrowse:SetDescription( 'Cadastro das Regras de Comiss�o' )
_oBrowse:SetFilterDefault( "" )
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Retorna o menu para a rotina principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MenuDef()

Local _aRotina	:= {}

ADD OPTION _aRotina Title 'Visualizar' 		Action 'VIEWDEF.AFIN004'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'	   		Action 'VIEWDEF.AFIN004'	OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'	   		Action 'U_AFIN004H'	        OPERATION 4 ACCESS 0 // VIEWDEF.AFIN004
ADD OPTION _aRotina Title 'Excluir'	   		Action 'VIEWDEF.AFIN004'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Imprimir '    	Action 'U_RFIN012()'        OPERATION 6 ACCESS 0 
ADD OPTION _aRotina Title 'Exp. Excel '    	Action 'U_AFIN004D(0)'      OPERATION 7 ACCESS 0   
ADD OPTION _aRotina Title 'Exp. CSV '    	Action 'U_AFIN004D(1)'      OPERATION 8 ACCESS 0
ADD OPTION _aRotina Title 'Exp. XML '    	Action 'U_AFIN004D(2)'      OPERATION 8 ACCESS 0
ADD OPTION _aRotina Title 'Copiar'	   		Action 'VIEWDEF.AFIN004'	OPERATION 9 ACCESS 0
ADD OPTION _aRotina Title 'Copiar p/Varios Representantes' Action 'U_AFIN0042()'    OPERATION 9 ACCESS 0
ADD OPTION _aRotina Title 'Add. Produto'	Action 'U_AFIN004C(1)'		OPERATION 4 ACCESS 0 // 2 ACCESS 0
ADD OPTION _aRotina Title '% Cood/Super/Geren/Ger.Nacional'	Action 'U_AFIN004C(2)'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Liberar'			Action 'U_AFIN004B()'		OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Hist�rico'		Action 'U_AF004HIST()'		OPERATION 2 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Monta o Modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ModelDef()

Local _oStruCAB	:= FWFormStruct( 1 , 'ZAE' , { |_cCampo| AFIN004CPO( _cCampo , 1 ) } )
Local _oStruITN	:= FWFormStruct( 1 , 'ZAE' , { |_cCampo| AFIN004CPO( _cCampo , 2 ) } )
Local _oModel	:= Nil
Local _aGatAux	:= {}

_aGatAux := FwStruTrigger( 'ZAE_PROD'	, 'ZAE_CODSUP'	, 'SA3->A3_SUPER' , .T. , 'SA3' , 1 , 'xFilial("SA3")+M->ZAE_VEND' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZAE_PROD'	, 'ZAE_CODGER'	, 'SA3->A3_GEREN' , .T. , 'SA3' , 1 , 'xFilial("SA3")+M->ZAE_VEND' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZAE_PROD'	, 'ZAE_CODSUI'	, 'SA3->A3_I_SUPE' , .T. , 'SA3' , 1 , 'xFilial("SA3")+M->ZAE_VEND' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'ZAE_PROD'	, 'ZAE_CODGNC'	, 'SA3->A3_I_GERNC' , .T. , 'SA3' , 1 , 'xFilial("SA3")+M->ZAE_VEND' )
_oStruITN:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] ) 

//oModel := MPFormModel():New("zMVCMd1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
//_oModel  := MPFormModel():New( 'AFIN004M',/*bPre*/, {|| U_AFIN004A(_oModel:GetOperation(), _oModel)} /*bPos*/, {|| U_AFIN004E(_oModel:GetOperation(), _oModel)} /*bCommit*/,/*bCancel*/ )
_oModel  := MPFormModel():New( 'AFIN004M',/*bPre*/, {|| U_AFIN004A(_oModel:GetOperation(), _oModel)} /*bPos*/,  /*bCommit*/,/*bCancel*/ )

_oModel:SetDescription( 'Cadastro de Regras de Comiss�o' )

_oModel:AddFields(	"ZAEMASTER" , /*cOwner*/  , _oStruCAB , /*bPreValidacao*/ , /*bPosValidacao*/ , /*bCarga*/ )
_oModel:AddGrid(	"ZAEDETAIL" , "ZAEMASTER" , _oStruITN , /*bPreValidacao*/ , /*bPosValidacao*/ , /*bCarga*/ )

_oModel:SetRelation( "ZAEDETAIL" , {	{ "ZAE_FILIAL"	, 'xFilial("ZAE")'	} ,;
										{ "ZAE_VEND"	, "ZAE_VEND"		} }, ZAE->( IndexKey( 1 ) ) )

_oModel:GetModel( 'ZAEDETAIL' ):SetUniqueLine( { 'ZAE_PROD' , 'ZAE_GRPVEN' , 'ZAE_CLI' , 'ZAE_LOJA' } )
_oModel:GetModel( "ZAEMASTER" ):SetDescription( "Vendedor"				)
_oModel:GetModel( "ZAEDETAIL" ):SetDescription( "Regras de Comiss�o"	)

_oModel:GetModel("ZAEMASTER"):AFLDNOCOPY := { "ZAE_VEND" , "ZAE_NVEND" }

_oModel:SetPrimaryKey( { 'ZAE_FILIAL' , 'ZAE_VEND' , 'ZAE_ITEM' } )
_oModel:SetVldActivate( { |_oModel| AFIN004INI( _oModel ) } )

_omodel:aallsubmodels[2]:nmaxline := 999999

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Alexandre Villar
Data da Criacao---: 13/08/2014
===============================================================================================================================
Descri��o---------: Define a View de dados para a rotina de cadastro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()

//================================================================================
// Prepara a estrutura do objeto da View
//================================================================================
Local _oModel  	:= FWLoadModel( 'AFIN004' )
Local _oStruCAB	:= FWFormStruct( 2 , 'ZAE' , { |cCampo| AFIN004CPO( cCampo , 1 ) } )
Local _oStruITN	:= FWFormStruct( 2 , 'ZAE' , { |cCampo| AFIN004CPO( cCampo , 2 ) } )
Local _oView	:= Nil

_oStruITN:SetProperty( 'ZAE_CODSUP' , MVC_VIEW_CANCHANGE , .F. )
_oStruITN:SetProperty( 'ZAE_CODGER' , MVC_VIEW_CANCHANGE , .F. )
_oStruITN:SetProperty( 'ZAE_CODSUI' , MVC_VIEW_CANCHANGE , .F. )
_oStruITN:SetProperty( 'ZAE_CODGNC' , MVC_VIEW_CANCHANGE , .F. ) 

//================================================================================
// Instancia o Objeto da View
//================================================================================
_oView := FWFormView():New()

//================================================================================
// Define o modelo de dados da view
//================================================================================
_oView:SetModel( _oModel )

//================================================================================
// Instancia os objetos da View com as estruturas de dados
//================================================================================
_oView:AddField( "VIEW_CAB"	, _oStruCAB	, "ZAEMASTER" )
_oView:AddGrid(  "VIEW_ITN"	, _oStruITN	, "ZAEDETAIL" )

//================================================================================
// Cria os Box horizontais para a View
//================================================================================
_oView:CreateHorizontalBox( 'BOX0101' , 15 )
_oView:CreateHorizontalBox( 'BOX0102' , 85 )


//================================================================================
// Define as estruturas da View para cada Box
//================================================================================
_oView:SetOwnerView( "VIEW_CAB" , "BOX0101" )
_oView:SetOwnerView( "VIEW_ITN" , "BOX0102" )

//================================================================================
// Define campo incremental para o GRID
//================================================================================
_oView:AddIncrementField( 'VIEW_ITN' , 'ZAE_ITEM' )

_oView:AddUserButton( 'Produtos'  , 'Produtos' , {|_oView| U_AFIN004R(.T.) } )
_oView:AddUserButton( 'Atualizar' , 'Atualiza' , {|_oView| U_AFIN004U(.T.) } )

_oView:AVIEWS[2][3]:BCHANGELINE := {|_oView| U_AFIN004L(_oView) }

_oView:EnableTitleView( 'VIEW_CAB' , 'Dados do Vendedor' )
_oView:EnableTitleView( 'VIEW_ITN' , 'Regras de Comiss�o' )

Return( _oView )

/*
===============================================================================================================================
Programa----------: AFIN004CPO
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Valida os Campos que ser�o exibidos no Browse
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o c�digo foi validado ou seje j� existe
===============================================================================================================================
*/

Static Function AFIN004CPO( _cCampo , _nOpc)

Local _lRet := AllTrim(_cCampo) $ 'ZAE_VEND,ZAE_NOME,ZAE_MSBLQL'

If _nOpc == 2
	_lRet := !_lRet
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004INI
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Valida��o inicial do modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o c�digo foi validado ou seje j� existe
===============================================================================================================================
*/

Static Function AFIN004INI( _oModel )

Local _aArea	:= GetArea()
Local _aInfHlp	:= {}
Local _lRet		:= .T.
Local _nOper	:= _oModel:GetOperation()
Local _nPerMax	:= GetMv( 'IT_COMMAX'  ,, 0 )

If _nPerMax == 0
	
	_aInfHlp := {}
	aAdd( _aInfHlp , { "O par�metro [IT_COMMAX] n�o existe ou "	 ,"n�o foi corretamente inicializado!"		} )
	aAdd( _aInfHlp , { "Informe a �rea de TI/ERP para liberar a ","utiliza��o da rotina."					} )
	
    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
	//U_ITCADHLP( _aInfHlp , "AFIN00406" )
	
	_lRet := .F.
	
EndIf

If _nPerMax == 0
	
	_aInfHlp := {}
	aAdd( _aInfHlp , { "O par�metro [IT_COMMAXS] n�o existe ou " ,"n�o foi corretamente inicializado!"		} )
	aAdd( _aInfHlp , { "Informe a �rea de TI/ERP para liberar a ","utiliza��o da rotina."					} )
	
    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
	//U_ITCADHLP( _aInfHlp , "AFIN00406" )
	
	_lRet := .F.
	
EndIf

If _nOper <> 1 

	_lRet := U_ITVLDUSR(5) .OR. SuperGetMV("IT_AMBTEST",.F.,.T.)
	
	If !_lRet
	
		_aInfHlp := {}
		aAdd( _aInfHlp	, { "Usu�rio sem acesso � manuten��o das "	,"regras de comiss�o! "						} )
		aAdd( _aInfHlp	, { "Verifique com a �rea de TI/ERP para "	,"solicitar a libera��o. "					} )
		
      //U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
	    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) //U_ITCADHLP( _aInfHlp , "AFIN00405" )
		
	EndIf
	
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004P
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Valida��es do modelo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AFIN004P( _nOpc , _nValAux )

Local _aInfHlp	:= {}
Local _lRet		:= .T.
Local _nPerMax	:= 0
Local _nValCom	:= 0
Local _nValCo2	:= 0
Local _cDesc	:= ''
Local _lVldVen	:= .F.
Local _oModel	:= FWModelActive()
Local _cCampoAtual:=UPPER(ReadVar())
Local _cContuAtual:=&(_cCampoAtual)
PRIVATE _cFornec:=""

If _nOpc == 1 // Valida��o no campo ZAE_COMIS1
	
   If ALTERA//SEM MVC
      IF _cCampoAtual = "M->ZAE_COMIS1"
         _nValCo1:=      M->ZAE_COMIS1//VENDEDOR
         _nValCo2:= TRBZAE->ZAE_COMIS2//COORDENADOR
	     _nValCo3:= TRBZAE->ZAE_COMIS3//GERENTE
	     _nValCo4:= TRBZAE->ZAE_COMIS4//SUPERVISOR
	     _nValCo5:= TRBZAE->ZAE_COMIS5//GERENTE NACIONAL
	  ELSE
         _nValCo1:=      M->ZAE_COMVA1//VENDEDOR
         _nValCo2:= TRBZAE->ZAE_COMVA2//COORDENADOR
	     _nValCo3:= TRBZAE->ZAE_COMVA3//GERENTE      
	     _nValCo4:= TRBZAE->ZAE_COMVA4//SUPERVISOR         
	     _nValCo5:= TRBZAE->ZAE_COMVA5//GERENTE NACIONAL
	  ENDIF
	ELSE//COM MVC
	   _cCodVend:= _oModel:GetValue( 'ZAEMASTER' , 'ZAE_VEND' )
      IF _cCampoAtual = "M->ZAE_COMIS1"
         _nValCo1:=      M->ZAE_COMIS1//VENDEDOR
         _nValCo2:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS2')//COORDENADOR
	     _nValCo3:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS3')//GERENTE
	     _nValCo4:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS4')//SUPERVISOR
	     _nValCo5:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS5')//GERENTE NACIONAL
	  ELSE
         _nValCo1:=      M->ZAE_COMVA1//VENDEDOR
         _nValCo2:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA2')//COORDENADOR
	     _nValCo3:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA3')//GERENTE      
	     _nValCo4:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA4')//SUPERVISOR         
	     _nValCo5:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA5')//GERENTE NACIONAL
	  ENDIF	
	ENDIF
    _cFornec:= Posicione('SA3',1,xFilial('SA3')+_cCodVend,'A3_FORNECE')
	IF EMPTY(_cFornec)
 	   U_ITMSG("Favor verificar o codigo do fornecedor amarrado a este vendedor",'Aten��o!',"Preencha o codigo do fornecedor amarrado a este vendedor",1, , ,ALTERA) 
	   RETURN .F.
	ENDIF

	_lVldVen	:= AFIN004VCG( 1 , _cCodVend,"A3_SUPER"  )//VENDERDOR CONTRA COORDENADOR
	If _lVldVen .And. _nValCo1 > 0 .And. _nValCo2 > 0
		_lRet := .F.
		_cDesc:="Coodernador"		
	EndIf
	_lVldVen	:= AFIN004VCG( 1 , _cCodVend,"A3_GEREN" )//VENDERDOR CONTRA GERENTE      
	If _lVldVen .And. _nValCo1 > 0 .And. _nValCo3 > 0
		_lRet := .F.
		_cDesc:="Gerente"
	EndIf
	_lVldVen	:= AFIN004VCG( 1 , _cCodVend,"A3_I_SUPE"  )//VENDERDOR CONTRA SUPERVISOR         
	If _lVldVen .And. _nValCo1 > 0 .And. _nValCo4 > 0
		_lRet := .F.
		_cDesc:="Supervisor"
	EndIf
	_lVldVen	:= AFIN004VCG( 1 , _cCodVend,"A3_I_GERNC")//VENDERDOR CONTRA GERENTE NACIONAL
	If _lVldVen .And. _nValCo1 > 0 .And. _nValCo5 > 0
		_lRet := .F.
		_cDesc:="Gerente Nacional"
	EndIf

	If !_lRet
		_aInfHlp := {}
		aAdd( _aInfHlp , { "N�o � permitido informar percentual de ","comiss�o para Vendedor e "+_cDesc+" quando forem o mesmo Fornecedor ("+_cCodVend+")"} )
		aAdd( _aInfHlp , { "Para esses casos o percentual deve ser ","cadastrado zerado [0.00]."														} )
        If ALTERA
	       U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
		ELSE
  		   U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) //U_ITCADHLP( _aInfHlp , "AFIN00411" )
		ENDIF
	EndIf

	_nPerMax	:= GetMv( 'IT_COMMAX' ,, 0 ) //Armazena o valor maximo que podera ser gerado para as comissoes dos Vendedores
	_cDesc		:= 'Vendedores'
	_nValCom    := _nValCo1

ElseIf  (_nOpc == 2 .or. _nOpc == 3 .or. _nOpc == 6 .or. _nOpc == 7)// Valida��o nos campos:
                                                                    // ZAE_COMIS2 - ZAE_COMVA2 (2)
                                                                    // ZAE_COMIS3 - ZAE_COMVA3 (3)
																	// ZAE_COMIS4 - ZAE_COMVA4 (6)
																	// ZAE_COMIS5 - ZAE_COMVA5 (7)
    If ALTERA//SEM MVC
       IF "M->ZAE_COMIS" $ _cCampoAtual//COMISSOES
	      _nValCo1 := IF(_cCampoAtual="M->ZAE_COMIS1",_cContuAtual,TRBZAE->ZAE_COMIS1)//VENDEDOR
	      _nValCo2 := IF(_cCampoAtual="M->ZAE_COMIS2",_cContuAtual,TRBZAE->ZAE_COMIS2)//COORDENADOR
	      _nValCo3 := IF(_cCampoAtual="M->ZAE_COMIS3",_cContuAtual,TRBZAE->ZAE_COMIS3)//GERENTE
	      _nValCo4 := IF(_cCampoAtual="M->ZAE_COMIS4",_cContuAtual,TRBZAE->ZAE_COMIS4)//SUPERVISOR
	      _nValCo5 := IF(_cCampoAtual="M->ZAE_COMIS5",_cContuAtual,TRBZAE->ZAE_COMIS5)//GERENTE NACIONAL
	   ELSE//COMISSOES VAREJO
	      _nValCo1 := IF(_cCampoAtual="M->ZAE_COMVA1",_cContuAtual,TRBZAE->ZAE_COMVA1)//VENDEDOR
	      _nValCo2 := IF(_cCampoAtual="M->ZAE_COMVA2",_cContuAtual,TRBZAE->ZAE_COMVA2)//COORDENADOR
	      _nValCo3 := IF(_cCampoAtual="M->ZAE_COMVA3",_cContuAtual,TRBZAE->ZAE_COMVA3)//GERENTE
	      _nValCo4 := IF(_cCampoAtual="M->ZAE_COMVA4",_cContuAtual,TRBZAE->ZAE_COMVA4)//SUPERVISOR
	      _nValCo5 := IF(_cCampoAtual="M->ZAE_COMVA5",_cContuAtual,TRBZAE->ZAE_COMVA5)//GERENTE NACIONAL
	   ENDIF
	ELSE//PELO MVC
	  _cCodVend:= _oModel:GetValue( 'ZAEMASTER' , 'ZAE_VEND' )
      IF "M->ZAE_COMIS" $ _cCampoAtual
         _nValCo1:= IF(_cCampoAtual="M->ZAE_COMIS1",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS1'))//VENDEDOR
         _nValCo2:= IF(_cCampoAtual="M->ZAE_COMIS2",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS2'))//COORDENADOR
	     _nValCo3:= IF(_cCampoAtual="M->ZAE_COMIS3",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS3'))//GERENTE
	     _nValCo4:= IF(_cCampoAtual="M->ZAE_COMIS4",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS4'))//SUPERVISOR
	     _nValCo5:= IF(_cCampoAtual="M->ZAE_COMIS5",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMIS5'))//GERENTE NACIONAL
	  ELSE//COMISSOES VAREJO
         _nValCo1:= IF(_cCampoAtual="M->ZAE_COMVA1",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA1'))//VENDEDOR
         _nValCo2:= IF(_cCampoAtual="M->ZAE_COMVA2",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA2'))//COORDENADOR
	     _nValCo3:= IF(_cCampoAtual="M->ZAE_COMVA3",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA3'))//GERENTE      
	     _nValCo4:= IF(_cCampoAtual="M->ZAE_COMVA4",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA4'))//SUPERVISOR         
	     _nValCo5:= IF(_cCampoAtual="M->ZAE_COMVA5",_cContuAtual,_oModel:GetValue( 'ZAEDETAIL' , 'ZAE_COMVA5'))//GERENTE NACIONAL
	  ENDIF	
	ENDIF

    If ALTERA//SEM MVC
       _cCODSUP	:= TRBZAE->ZAE_CODSUP
       _cCODGER	:= TRBZAE->ZAE_CODGER
       _cCODSUI	:= TRBZAE->ZAE_CODSUI
       _cCODGNC	:= TRBZAE->ZAE_CODGNC
	ELSE//PELO MVC
       _cCODSUP	:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_CODSUP')
       _cCODGER	:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_CODGER')
       _cCODSUI	:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_CODSUI')
       _cCODGNC	:= _oModel:GetValue( 'ZAEDETAIL' , 'ZAE_CODGNC')
	ENDIF

    IF _nOpc == 2 //COORDENADOR ********************************************
	   _cDesc	:= 'Coordenador'
   	   _nValCom := _nValCo2
	   _cFornec := _cCODSUP

	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUP,_cCodVend  )// COORDENADOR CONTRA VENDERDOR
	   If _lVldVen .And. _nValCo2 > 0 .And. _nValCo1 > 0
	   	_lRet := .F.
	   	_cDesc2:="Vendedor"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUP,_cCODGER )//COORDENADOR CONTRA GERENTE      
	   If _lVldVen .And. _nValCo2 > 0 .And. _nValCo3 > 0
	   	_lRet := .F.
	   	_cDesc2:="Gerente"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUP,_cCODSUI )//COORDENADOR CONTRA SUPERVISOR         
	   If _lVldVen .And. _nValCo2 > 0 .And. _nValCo4 > 0
	   	_lRet := .F.
	   	_cDesc2:="Supervisor"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUP,_cCODGNC)//COORDENADOR CONTRA GERENTE NACIONAL
	   If _lVldVen .And. _nValCo2 > 0 .And. _nValCo5 > 0
	   	_lRet := .F.
	   	_cDesc2:="Gerente Nacional"
	   EndIf
    
	ELSEIF _nOpc == 3//GERENTE *******************************************************
	   _cDesc	:= 'Gerente'
   	   _nValCom := _nValCo3
	   _cFornec := _cCODGER
   
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGER,_cCodVend  )// GERENTE CONTRA VENDERDOR
	   If _lVldVen .And. _nValCo3 > 0 .And. _nValCo1 > 0
	   	_lRet := .F.
	   	_cDesc2:="Vendedor"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGER,_cCODSUP )//GERENTE CONTRA COORDENADOR      
	   If _lVldVen .And. _nValCo3 > 0 .And. _nValCo2 > 0
	   	_lRet := .F.
	   	_cDesc2:="Coordenador"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGER,_cCODSUI )//GERENTE CONTRA SUPERVISOR         
	   If _lVldVen .And. _nValCo3 > 0 .And. _nValCo4 > 0
	   	_lRet := .F.
	   	_cDesc2:="Supervisor"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGER,_cCODGNC)//GERENTE CONTRA GERENTE NACIONAL
	   If _lVldVen .And. _nValCo3 > 0 .And. _nValCo5 > 0
	   	_lRet := .F.
	   	_cDesc2:="Gerente Nacional"
	   EndIf

	ELSEIF _nOpc == 6//SUPERVISOR *******************************************************
	   _cDesc	:= 'Supervisor'
   	   _nValCom := _nValCo4
	   _cFornec := _cCODSUI
   
	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUI,_cCodVend  )// SUPERVISOR CONTRA VENDERDOR
	   If _lVldVen .And. _nValCo4 > 0 .And. _nValCo1 > 0
	   	_lRet := .F.
	   	_cDesc2:="Vendedor"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUI,_cCODSUP )//SUPERVISOR CONTRA COORDENADOR      
	   If _lVldVen .And. _nValCo4 > 0 .And. _nValCo2 > 0
	   	_lRet := .F.
	   	_cDesc2:="Coordenador"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUI,_cCODGER )//SUPERVISOR CONTRA GERENTE         
	   If _lVldVen .And. _nValCo4 > 0 .And. _nValCo3 > 0
	   	_lRet := .F.
	   	_cDesc2:="Gerente"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODSUI,_cCODGNC)//SUPERVISOR CONTRA GERENTE NACIONAL
	   If _lVldVen .And. _nValCo4 > 0 .And. _nValCo5 > 0
	   	_lRet := .F.
	   	_cDesc2:="Gerente Nacional"
	   EndIf	
    
	ELSEIF _nOpc == 7//GERENTE NACIONAL *******************************************************
	   _cDesc	:= 'Gerente Nacional'
   	   _nValCom := _nValCo5
	   _cFornec := _cCODGNC
   
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGNC,_cCodVend  )// GERENTE NACIONAL CONTRA VENDERDOR
	   If _lVldVen .And. _nValCo5 > 0 .And. _nValCo1 > 0
	   	_lRet := .F.
	   	_cDesc2:="Vendedor"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGNC,_cCODSUP )//GERENTE NACIONAL CONTRA COORDENADOR      
	   If _lVldVen .And. _nValCo5 > 0 .And. _nValCo2 > 0
	   	_lRet := .F.
	   	_cDesc2:="Coordenador"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGNC,_cCODGER )//GERENTE NACIONAL CONTRA GERENTE         
	   If _lVldVen .And. _nValCo5 > 0 .And. _nValCo3 > 0
	   	_lRet := .F.
	   	_cDesc2:="Gerente"
	   EndIf
	   _lVldVen	:= AFIN004VCG( 5 , _cCODGNC,_cCODSUI)//GERENTE NACIONAL CONTRA SUPERVISOR 
	   If _lVldVen .And. _nValCo5 > 0 .And. _nValCo4 > 0
	   	_lRet := .F.
	   	_cDesc2:="Supervisor"
	   EndIf
	ENDIF

	If !_lRet
		_aInfHlp := {}
		aAdd( _aInfHlp , { "N�o � permitido informar percentual de ","comiss�o para "+_cDesc+" e "+_cDesc2+" quando forem o mesmo Fornecedor ("+_cFornec+")"} )
		aAdd( _aInfHlp , { "Para esses casos o percentual deve ser ","cadastrado zerado [0.00]."														} )
       If ALTERA
	      U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) //
	   ELSE
  		  U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) //U_ITCADHLP( _aInfHlp , "AFIN00411" )
       ENDIF
	EndIf

	_nPerMax	:= GetMv( 'IT_COMMAXS' ,, 0 ) //Armazena o valor maximo que podera ser gerado para as comissoes dos Coord./Gerente/Supervisor/Gerente Nac

ElseIf _nOpc == 4 // Valida��o na Botao "Add. Produto" campo "% Padr�o:"

	_nValCom	:= _nValAux
	_nPerMax	:= GetMv( 'IT_COMMAX' ,, 0 ) //Armazena o valor maximo que podera ser gerado para as comissoes dos Vendedores
	_cDesc		:= 'Vendedores'

ElseIf _nOpc == 5 // Valida��o na Botao "% Cood/Super/Geren/Ger.Nacional" campo "% Padr�o:"

	_nValCom	:= _nValAux
	_nPerMax	:= GetMv( 'IT_COMMAXS' ,, 0 ) //Armazena o valor maximo que podera ser gerado para as comissoes dos Coord./Gerente/Supervisor/Gerente Nac
	_cDesc		:= 'Coord./Gerente/Supervisor/Gerente Nac'

EndIf

If _lRet .And. _nPerMax == 0
	
	_aInfHlp := {}
	If _nOpc == 1 .Or. _nOpc == 4// Vendedores
	   aAdd( _aInfHlp , { "O par�metro [IT_COMMAX] n�o existe ou "	, "n�o foi corretamente inicializado!"		} )
	Else// Coord./Gerente/Supervisor/Gerente Nac
	   aAdd( _aInfHlp , { "O par�metro [IT_COMMAXS] n�o existe ou "	, "n�o foi corretamente inicializado!"		} )
	EndIF
	aAdd( _aInfHlp , { "Informe a �rea de TI/ERP para liberar a "	, "utiliza��o da rotina."					} )
	
    If ALTERA .OR. _nOpc = 5
	   U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
	ELSE
	   U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) //U_ITCADHLP( _aInfHlp , "AFIN00406" )
	ENDIF	
	_lRet := .F.
	
EndIf

If _lRet .And. _nValCom > _nPerMax

	_aInfHlp := {}
	aAdd( _aInfHlp , { "O valor de comiss�o informado n�o � ", "v�lido!"																} )
	aAdd( _aInfHlp , { "O limite atual para percentual de "	 , "comiss�o de "+ _cDesc+" � [ "+ AllTrim( Transform( _nPerMax , '@E 999.99' ) ) +" ]."	} )

    If ALTERA
	   U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
	ELSE		
       U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) //U_ITCADHLP( _aInfHlp , "AFIN00407" )
	ENDIF
	
	_lRet := .F.

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004R
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Grava comiss�o para grupos de vendedores
===============================================================================================================================
Parametros--------: _lRotinaMVC = .T. rotina chamada atrav�s de aplica��o MVC; _lRotinaMVC= .F. rotina chamada atrav�s de  
                    fun��o padr�o do Protheus.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AFIN004R(_lRotinaMVC)

Local _aArea	:= GetArea()

Local _oGrupo	:= Nil
Local _oDescr	:= Nil
Local _oPerPad	:= Nil
Local _oDlgPro	:= Nil
Local _cContr	:= Space(12)
Local _cDescr	:= Space(99)
Local _nDescto	:= 0
Local _oRede      
Local _oClienVend 
Local _oLojaCVend 

Local _oModel	  
Local _oModDet	  
Local _nOperation 
Local _nColPos
Local _lNMostSel  := .T.

Private _cGrupo		:= Space(100)
Private _oBoxLib	:= Nil
Private _nOpc		:= 0
Private _bMarkNo	:= LoadBitmap( GetResources(), "LBNO" )
Private _bMarkOk	:= LoadBitmap( GetResources(), "LBOK" )
Private _aGrid		:= { { LoadBitmap( GetResources() , "BR_CINZA" ) , _bMarkNo , "" , "" , "" , "" } }//INICIALIZACAO DO _aGrid 
Private _nPerPad	:= 0
Private _nPerPadVar	:= 0 
Private _nPerCoord	:= 0
Private _nPerCooVar := 0 
Private _nPerSuper	:= 0
Private _nPerSupVar	:= 0 
Private _nPerGerenc	:= 0
Private _nPerGerVar	:= 0 
Private _nPerGNac	:= 0 
Private _nPerGNcVar	:= 0 
Private _cRede      := Space(6)
Private _cClienVend := Space(6)
Private _cLojaCVend := Space(4)

Default _lRotinaMVC := .T.

Begin Sequence
   If _lRotinaMVC
      _oModel	  := FWModelActive()
      _oModDet	  := _oModel:GetModel( 'ZAEDETAIL' )
      _nOperation := _oModel:GetOperation()
      
   EndIf
   
   //====================================================================================================
   // Carrega no array _aGridVld todos os dados ja cadastados para regra de comiss�o de vendedores.
   //====================================================================================================
   If _lRotinaMVC
      U_AFIN004Y(.T.)
   Else
      U_AFIN004Y(.F.)
   EndIf

   _aItalac_F3:={}         //        1              2                3               4               5                    6                  7    8  9  10  11  12
   Aadd(_aItalac_F3,{"_cMIXBI",/*_cTabela*/ ,/*_nCpoChave*/ , /*_nCpoDesc*/ , /*_bCondTab*/ , "Lista de MIX BI" , LEN(SB1->B1_I_BIMIX) , _aBoxMix, ,   ,   ,   ,  })

   SetKey( VK_F5 , {|| FWMSGRUN(,{|oProc| AFIN004FB1(_cGrupo,_cDescr,oProc,_lNMostSel,_lRotinaMVC,_oModDet),'Aguarde processamento...','Lendo dados...' }) } )
   SetKey( VK_F6 , {|| MsgRun( "Carregando os produtos..." , "Aguarde!" , {|| AFIN004GRD( _nDescto , _cContr , _nPerPad, _cRede, _cClienVend, _cLojaCVend,.F.,_nPerCoord, _nPerGerenc,_nPerSup) , _oDlgPro:End() } ) } )
   _nCol01:=10
   _nCol02:=_nCol01+72
   _nLin01:=10
   _nLin02:=18
   _nLin03:=14+36
   _nLin04:=22+37
   _nLinFim1:=40
   _cTotal  :="0"
   //====================================================================================================
   // Tela para escolha do produto.
   //====================================================================================================
   DEFINE MSDIALOG _oDlgPro TITLE "Pesquisa de Produtos" FROM 178,181 TO 665+50,1450 PIXEL // 665,967
   
   @ 003,004          TO _nLinFim1,620 LABEL " Pesquisa : "	    PIXEL OF _oDlgPro
   @ _nLinFim1+2,004  TO 045+30,620    LABEL " Regras : "		PIXEL OF _oDlgPro
   @ 047+30,004       TO 220+30,620    LABEL " Resultados : "	PIXEL OF _oDlgPro

   @ _nLin01,_nCol01 Say "Grupo :"	COLOR CLR_BLACK			    PIXEL OF _oDlgPro Size 065,006
   @ _nLin02,_nCol01 MSGet _oGrupo	Var _cGrupo F3 "SBM_02"	    PIXEL OF _oDlgPro Size 070,009 Picture "@!"

   @ _nLin01,_nCol02 Say "Descri��o do Produto :"         	    PIXEL OF _oDlgPro Size 065,006
   @ _nLin02,_nCol02 MsGet _oDescr Var _cDescr Picture "@!"	    PIXEL OF _oDlgPro Size 130,009

   @ _nLin02+12,_nCol01 CHECKBOX _oChkSel  VAR _lNMostSel PROMPT "N�o mostra itens j� selecionados" SIZE 100,010 ON CLICK( _oChkSel:Refresh() ) OF _oDlgPro PIXEL

   @ _nLin01,220 Say "Mix BI :"								    PIXEL OF _oDlgPro Size 065,006
   @ _nLin02,220 MSGet _cMIXBI F3 "F3ITLC"  Picture "@!"	    PIXEL OF _oDlgPro Size 055,009 

   @ _nLin01,350 Say "Total de Produtos :"					    PIXEL OF _oDlgPro Size 065,006
   @ _nLin02,350 MSGet _oTotal Var _cTotal    WHEN .F.          PIXEL OF _oDlgPro Size 050,009

   _nColPos := _nCol01 
   @ _nLin03,_nColPos Say "Rede:" COLOR CLR_BLACK								               PIXEL OF _oDlgPro Size 026,006
   @ _nLin04,_nColPos MsGet _oRede Var _cRede F3 "ACY" Picture "@!"	Valid(U_AFIN004X("REDE"))  PIXEL OF _oDlgPro Size 050,009 COLOR CLR_BLACK
   _nColPos += 60 

   @ _nLin03,_nColPos Say "Cliente:" COLOR CLR_BLACK								                       PIXEL OF _oDlgPro Size 026,006
   @ _nLin04,_nColPos MsGet _oClienVend Var _cClienVend F3 "SA1" Picture "@!" Valid(U_AFIN004X("CLIENTE")) PIXEL OF _oDlgPro Size 050,009 COLOR CLR_BLACK
   _nColPos += 60 

   @ _nLin03,_nColPos Say "Loja:" COLOR CLR_BLACK								               PIXEL OF _oDlgPro Size 026,006
   @ _nLin04,_nColPos MsGet _oLojaCVend Var _cLojaCVend Picture "@!" Valid(U_AFIN004X("LOJA")) PIXEL OF _oDlgPro Size 030,009 COLOR CLR_BLACK
   _nColPos += 40  

   _nColPos := 190 
   @ _nLin03,_nColPos Say "% Atacado:" COLOR CLR_BLACK								           PIXEL OF _oDlgPro Size 026,006
   @ _nLin04,_nColPos MsGet _oPerPad Var _nPerPad Picture "@E 999.999"				           PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 

   @ _nLin03,_nColPos Say "% Varejo:" COLOR CLR_BLACK								           PIXEL OF _oDlgPro Size 026,006
   @ _nLin04,_nColPos MsGet _oPerPadVar Var _nPerPadVar Picture "@E 999.999"				   PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 

   @ _nLin03,_nColPos Say "% Supervisor:" COLOR CLR_BLACK							           PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oSuperPad Var _nPerSuper Picture "@E 999.999"			           PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 

   @ _nLin03,_nColPos Say "% Sup.Varejo:" COLOR CLR_BLACK							           PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oPerSupVar Var _nPerSupVar Picture "@E 999.999"			       PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 

   @ _nLin03,_nColPos Say "% Coorden.:" COLOR CLR_BLACK							               PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oCoordPad Var _nPerCoord Picture "@E 999.999"			           PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 
   @ _nLin03,_nColPos Say "% Coo.Varejo:" COLOR CLR_BLACK							           PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oPerCooVar Var _nPerCooVar Picture "@E 999.999"			       PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40
   @ _nLin03,_nColPos Say "% Gerente:" COLOR CLR_BLACK								           PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oGerenPad Var _nPerGerenc Picture "@E 999.999"			           PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 
   @ _nLin03,_nColPos Say "% Ger.Varejo:" COLOR CLR_BLACK								       PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oPerGerVar Var _nPerGerVar Picture "@E 999.999"			       PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 

   @ _nLin03,_nColPos Say "% Ger.Nacional:" COLOR CLR_BLACK								       PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oPerGNac Var _nPerGNac Picture "@E 999.999"			           PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   _nColPos += 40 

   @ _nLin03,_nColPos Say "% Ger.Nac.Var:" COLOR CLR_BLACK								       PIXEL OF _oDlgPro Size 060,006
   @ _nLin04,_nColPos MsGet _oPerGNcVar Var _nPerGNcVar Picture "@E 999.999"			       PIXEL OF _oDlgPro Size 025,009 COLOR CLR_BLACK  
   //_nColPos += 40 
   
   @ 055+30,007 ListBox _oBoxLib Fields Headers " "," ","C�digo","Descri��o","Grupo","Mix BI"  PIXEL OF _oDlgPro Size 600,163 ON DBLCLICK ( AFIN004MLN() ) 

   _oBoxLib:SetArray( _aGrid )
   _oBoxLib:bLine := {|| {	_aGrid[_oBoxLib:nAt][01]	,;
						    _aGrid[_oBoxLib:nAt][02]	,;
						    _aGrid[_oBoxLib:nAt][03]	,;
						    _aGrid[_oBoxLib:nAt][04]	,;
						    _aGrid[_oBoxLib:nAt][05]	,;
						    _aGrid[_oBoxLib:nAt][06]	}}

   _oBoxLib:bHeaderClick := {|| AFIN004MAL() , _oBoxLib:Refresh() }

   @ 225+30,250 Button "PESQUISAR [ F5 ]" Size 50,012 PIXEL OF _oDlgPro Action(FWMSGRUN(,{|oProc| AFIN004FB1(_cGrupo,_cDescr,oProc,_lNMostSel,_lRotinaMVC,_oModDet),'Aguarde processamento...','Lendo dados...' }))
   @ 225+30,340 Button "OK  [ F6 ]"       Size 45,012 PIXEL OF _oDlgPro Action(MsgRun("Carregando os produtos...","Aguarde!",{|| AFIN004GRD(_nDescto,_cContr,_nPerPad, _cRede, _cClienVend, _cLojaCVend,_lRotinaMVC, _nPerCoord, _nPerGerenc,_nPerSuper,_nPerGNac,_nPerGNcVar,_nPerPadVar,_nPerCooVar,_nPerSupVar,_nPerGerVar)}),_oDlgPro:End())
   @ 225+30,400 Button "SAIR [ ESQ ]"     Size 45,012 PIXEL OF _oDlgPro Action(_oDlgPro:End())

   ACTIVATE MSDIALOG _oDlgPro CENTERED

End Sequence

SetKey(VK_F5,Nil)
SetKey(VK_F6,Nil)

_cMIXBI:= SPACE((Len(_aBoxMix)*3))

RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: AFIN004GRD
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Monta grid
===============================================================================================================================
Parametros--------: _nDescto     = N�o utilizado.
                    _cContr      = N�o utilizado.
                    _nPerPad     = Percentual de comiss�o.
                    _cRede       = Codigo da Rede.
                    _cClienVend  = Codigo do Cliente do Representante.
                    _cLojaCVend  = Loja do Cliente do Representante.
                    _lRotinaMVC  = .T./.F. = Indica se a fun��o foi ou n�o chamada de uma fun��o MVC.
                    _nPerCoord   = Percentual de comiss�o do Coordenador
                    _nPerGerenc  = Percentual de comiss�o do Gerente
                    _nPerSuper  = Percentual de comiss�o do Supervisor
					_nPerGNac   = Percentual de comiss�o Gerente Nacional
					_nPerGNcVar = Percentual de comiss�o varejo Gerente Nacional
					_nPerPadVar = Percentual de comiss�o varejo Vendedor
					_nPerCooVar = Percentual de comiss�o varejo Coordenador
					_nPerSupVar = Percentual de comiss�o varejo Supervisor
					_nPerGerVar = Percentual de comiss�o varejo Gerente
					
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AFIN004GRD( _nDescto , _cContr , _nPerPad, _cRede, _cClienVend, _cLojaCVend,_lRotinaMVC, _nPerCoord, _nPerGerenc,_nPerSuper,_nPerGNac,_nPerGNcVar,_nPerPadVar,_nPerCooVar,_nPerSupVar,_nPerGerVar)

Local _oModel	
Local _oModDet	
Local _nLinDet	:= 0
Local _nLinIni	:= 0
Local _nI		:= 0
Local _nX		:= 0
Local _nY       := 0
Local _lGrava	:= .T.
Local _lNewLin	:= .F.
Local _aGrvGrid := {}
Local _nItem    := 0
Local _cCODSUP
Local _cNSUP
Local _cCODGER
Local _cNGEREN
Local _cMSBLQL
Local _cCodGnc, _cNomGnc
//--------------------------------//
Local _aCabecalho
Local _cTitulo
Local _aDadosMsg := {}
Local _cDescrPrd
Local _lGrvDadosMvc
Local _cCodProd
Local _nK
//--------------------------------//

Default _lRotinaMVC := .T.

If _lRotinaMVC
   _oModel	:= FWModelActive()
   _oModDet	:= _oModel:GetModel( 'ZAEDETAIL' )
   _nLinDet	:= _oModDet:Length()
   _nLinIni	:= _nLinDet
   _cCodProd := ""
   
   //============================================================================================
   // Este trecho refere-se a apenas chamadas de rotinas que est�o utilizando MVC.
   //============================================================================================
   For _nI := 1 To Len( _aGrid )
	
	   If ( _aGrid[_nI][02] == _bMarkOk )
		
		   _lGrava := .T.
		
		   _aGrvGrid := {}
		   For _nX := 1 To _nLinDet
			
			   _oModDet:GoLine( _nX )
			
			   If _aGrid[_nI][03] == _oModDet:GetValue( 'ZAE_PROD' )
			      //=======================================================
			      // Valida se j� existe dados gravados obedecendo a regra
			      // Produto + Rede + Cliente +Loja.
			      //=======================================================
			      _cProd      := _oModDet:GetValue( 'ZAE_PROD' )
			   
			      For _nY := 1 To Len(_aGridVld)
			          If _cProd == _aGridVld[_nY,1] // C�digo do Produto
			             If ! Empty(_cRede) 
			                If _cRede == _aGridVld[_nY,3] // Codigo da Rede
		
			                   _lGrava := .F.
		                       _cDescrPrd := AllTrim( Posicione('SB1',1,xFilial('SB1')+_aGrid[_nI][03],'B1_DESC') ) 
                               _cCodProd := _aGrid[_nI][03]
        	                   Exit 
		
			                EndIf
			             EndIf
			       
			             If ! Empty(_cClienVend) .And. ! Empty(_cLojaCVend) 
			                If _cClienVend  == _aGridVld[_nY,4] .And. _cLojaCVend == _aGridVld[_nY,5] 			             
		
			                   _lGrava := .F.
		                       _cDescrPrd := AllTrim( Posicione('SB1',1,xFilial('SB1')+_aGrid[_nI][03],'B1_DESC') ) 
	                            _cCodProd := _aGrid[_nI][03]
        	                   Exit
		
			                EndIf
			             EndIf             
			             If Empty(_cRede) .And. Empty(_cClienVend)
		
			                _lGrava := .F. 
		                    _cDescrPrd := AllTrim( Posicione('SB1',1,xFilial('SB1')+_aGrid[_nI][03],'B1_DESC') ) 
		                    _cCodProd := _aGrid[_nI][03]
        	                Exit
		
			             EndIf
			          EndIf
			      Next
		
			      If _lGrava
			         Aadd(_aGrvGrid, _nX)
			      Else
			         If !Empty(_cCodProd)
			            _nK := Ascan(_aDadosMsg,{|x| x[1]==_cCodProd .And. x[3]==_cRede .And. x[4]== _cClienVend .And. x[5]==_cLojaCVend })
			            If _nK == 0 
			               Aadd(_aDadosMsg,{_cCodProd, _cDescrPrd,  _cRede, _cClienVend, _cLojaCVend })
			            EndIf
			         EndIf
			      EndIf
		
			   EndIf
			
		   Next _nX
		
           If Len(_aGrvGrid) > 0 .Or. _lGrava
		
			  If _nLinDet == 1
				
				 _oModDet:GoLine( 01 )
				
				 If Empty( _oModDet:GetValue( 'ZAE_PROD' ) ) .Or. _oModDet:IsDeleted()
				
					If _oModDet:IsDeleted()
						_oModDet:UnDeleteLine()
					EndIf
					
					_lNewLin := .F.
					
				 Else
					_lNewLin := .T.
				 EndIf
				
		      Else
				 _lNewLin := .T.
			  EndIf
			
			  _lGrvDadosMvc := .T.
			   
			  If _lNewLin
				 _nLinDet := _oModDet:AddLine()
			  Else            
			     If !(_nLinDet == 1 .And. Empty( _oModDet:GetValue( 'ZAE_PROD' ) ) )
		            _lGrvDadosMvc := .F.
		         EndIf
			  EndIf

              If _lGrvDadosMvc
			     _oModDet:GoLine( _nLinDet )
			
			     _oModDet:SetValue( 'ZAE_PROD'	, _aGrid[_nI][03] )
			     _oModDet:SetValue( 'ZAE_NPROD'	, AllTrim( Posicione('SB1',1,xFilial('SB1')+_aGrid[_nI][03],'B1_DESC') ) )

			     _oModDet:LoadValue( 'ZAE_COMIS1'	, _nPerPad ) // Comiss�o vendedor
			     _oModDet:LoadValue( 'ZAE_COMIS2'	, _nPerCoord )  // Comiss�o coordenador   
			     _oModDet:LoadValue( 'ZAE_COMIS3'	, _nPerGerenc ) // Comiss�o gerente  
			     _oModDet:LoadValue( 'ZAE_COMIS4'	, _nPerSuper )  // Comiss�o supervisor  // _nPerGerenc
				 _oModDet:LoadValue( 'ZAE_COMIS5'	, _nPerGNac )    // Comiss�o Gerente Nacional 

				 _oModDet:LoadValue( 'ZAE_COMVA1'	, _nPerPadVar )  // Comiss�o Varejo Vendedor 
				 _oModDet:LoadValue( 'ZAE_COMVA2'	, _nPerCooVar )  // Comiss�o Varejo Coordenador 
				 _oModDet:LoadValue( 'ZAE_COMVA3'	, _nPerGerVar )  // Comiss�o Varejo Gerente 
				 _oModDet:LoadValue( 'ZAE_COMVA4'	, _nPerSupVar )  // Comiss�o Varejo Supervisor 
				 _oModDet:LoadValue( 'ZAE_COMVA5'	, _nPerGNcVa )   // Comiss�o Varejo Gerente Nacional 
			
			     If ! Empty(_cRede)
			        _oModDet:SetValue( 'ZAE_GRPVEN'	, _cRede)
		         EndIf
			
			     If ! Empty(_cClienVend) .And. !Empty(_cLojaCVend)
			        _oModDet:SetValue( 'ZAE_CLI   '	, _cClienVend)
			        _oModDet:SetValue( 'ZAE_LOJA  '	, _cLojaCVend)			
		         EndIf
		      EndIf
		   EndIf
	    EndIf
	
   Next nI

   If _nLinIni > 0
	  _oModDet:GoLine( _nLinIni )
   EndIf

Else
   //============================================================================================
   // Este trecho refere-se a apenas chamadas de rotinas que N�O est�o utilizando MVC.
   //============================================================================================
   _nItem    := 0
   TRBZAE->(DbSetOrder(2)) // ZAE_VEND+ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA
   TRBZAE->(DbClearFilter())  
   TRBZAE->(DbGoTop())
   
   _cCODSUP := TRBZAE->ZAE_CODSUP
   _cNSUP   := TRBZAE->WK_NSUP
   _cCODGER := TRBZAE->ZAE_CODGER
   _cNGEREN := TRBZAE->WK_NGEREN
   _cCODSUI := TRBZAE->ZAE_CODSUI
   _cNSUI   := TRBZAE->WK_NSUI
   _cMSBLQL := TRBZAE->ZAE_MSBLQL
   //------------------------------
   _cCodGnc := TRBZAE->ZAE_CODGNC
   _cNomGnc := TRBZAE->WK_NGNC
   
   Do While !TRBZAE->(Eof())
      If Val(AllTrim(TRBZAE->ZAE_ITEM)) > _nItem  
         _nItem := Val(AllTrim(TRBZAE->ZAE_ITEM)) 
      EndIf
      
      TRBZAE->(DbSkip())   
   EndDo

   For _nI := 1 To Len( _aGrid )
	   If ( _aGrid[_nI][02] == _bMarkOk )
	      _lNewLin := .T.

          If ! Empty(_cRede) .And. ! Empty(_cClienVend) .And. ! Empty(_cLojaCVend)
             
			 TRBZAE->(DbSetOrder(2)) // ZAE_VEND+ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA
			 If TRBZAE->(DbSeek(_cCodVend + _aGrid[_nI][03] + _cRede + _cClienVend + _cLojaCVend)) 
                _lNewLin := .F.
             EndIf  

          ElseIf ! Empty(_cRede) .And. Empty(_cClienVend) .And. Empty(_cLojaCVend)

             TRBZAE->(DbSetOrder(3)) // ZAE_VEND+ZAE_PROD+ZAE_GRPVEN
			 If TRBZAE->(DbSeek(_cCodVend + _aGrid[_nI][03] + _cRede )) 
                _lNewLin := .F.
             EndIf 
		  
		  ElseIf Empty(_cRede) .And. ! Empty(_cClienVend) .And. Empty(_cLojaCVend)

             TRBZAE->(DbSetOrder(4)) // ZAE_VEND+ZAE_PROD+ZAE_CLI
			 If TRBZAE->(DbSeek(_cCodVend + _aGrid[_nI][03] + _cClienVend )) 
                _lNewLin := .F.
             EndIf 

		  ElseIf Empty(_cRede) .And. ! Empty(_cClienVend) .And. ! Empty(_cLojaCVend)
          
		     TRBZAE->(DbSetOrder(5)) // ZAE_VEND+ZAE_PROD+ZAE_CLI+ZAE_LOJA
			 If TRBZAE->(DbSeek(_cCodVend + _aGrid[_nI][03] + _cClienVend + _cLojaCVend)) 
                _lNewLin := .F.
             EndIf 
		  
		  ElseIf Empty(_cRede) .And. Empty(_cClienVend) .And. Empty(_cLojaCVend)
          
		     TRBZAE->(DbSetOrder(6)) // ZAE_VEND+ZAE_PROD
			 If TRBZAE->(DbSeek(_cCodVend + _aGrid[_nI][03] )) 
                _lNewLin := .F.
             EndIf 
          
		  EndIf

		  /*
          If TRBZAE->(DbSeek(_cCodVend + _aGrid[_nI][03] + _cRede + _cClienVend + _cLojaCVend)) // ZAE_VEND+ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA			
             _lNewLin := .F.
          Else
             _lNewLin := .T.
          EndIf  
          */

 		  If _lNewLin
			 TRBZAE->(RecLock("TRBZAE",.T.))
			 _nItem += 1
			 TRBZAE->ZAE_FILIAL := xFilial("ZAE")
             TRBZAE->ZAE_ITEM   := StrZero(_nItem,3)
             TRBZAE->ZAE_CODSUP := _cCODSUP
             TRBZAE->WK_NSUP    := _cNSUP   
             TRBZAE->ZAE_CODSUI := _cCODSUI
             TRBZAE->WK_NSUI    := _cNSUI   
             TRBZAE->ZAE_CODGER := _cCODGER
             TRBZAE->WK_NGEREN  := _cNGEREN
             TRBZAE->ZAE_MSBLQL := _cMSBLQL
		     TRBZAE->ZAE_PROD   := _aGrid[_nI][03] 
		     TRBZAE->WK_NPROD   := AllTrim( Posicione('SB1',1,xFilial('SB1')+_aGrid[_nI][03],'B1_DESC') ) 
	         TRBZAE->WKGRUPO    := SB1->B1_GRUPO  
             TRBZAE->WK_BIMIX   := SB1->B1_I_BIMIX
		     TRBZAE->ZAE_COMIS1 := _nPerPad 
			 TRBZAE->ZAE_COMIS2 := _nPerCoord  // Comiss�o coordenador  
			 TRBZAE->ZAE_COMIS3 := _nPerGerenc // Comiss�o gerente  
			 TRBZAE->ZAE_COMIS4 := _nPerSuper  //Comiss�o supervisor
			 TRBZAE->ZAE_COMVA1 := _nPerPadVar
			 TRBZAE->ZAE_COMVA2 := _nPerCooVar  // Comiss�o coordenador  
			 TRBZAE->ZAE_COMVA3 := _nPerGerVar // Comiss�o gerente  
			 TRBZAE->ZAE_COMVA4 := _nPerSupVar  //Comiss�o supervisor
			 //----------------------------------------
			 TRBZAE->ZAE_CODGNC := _cCodGnc
   	         TRBZAE->WK_NGNC    := _cNomGnc
			 TRBZAE->ZAE_COMIS5 := _nPerGNac
			 TRBZAE->ZAE_COMVA5 := _nPerGNcVar

		     If ! Empty(_cRede)
		        TRBZAE->ZAE_GRPVEN := _cRede
	         EndIf
			
		     If  ! Empty(_cClienVend) .And. !Empty(_cLojaCVend)
		        TRBZAE->ZAE_CLI  := _cClienVend
		        TRBZAE->ZAE_LOJA := _cLojaCVend			
	         EndIf
	      	 TRBZAE->(MsUnLock())
	      Else
	         // Adiciona ao array _aDadosMsg, os produtos que j� possuem regras definidadas.
	         _cDescrPrd := AllTrim( Posicione('SB1',1,xFilial('SB1')+_aGrid[_nI][03],'B1_DESC') ) 
	         Aadd(_aDadosMsg,{_aGrid[_nI][03], _cDescrPrd,  _cRede, _cClienVend, _cLojaCVend })
          EndIf
       EndIf
                       
   Next nI
   
   TRBZAE->(DbSetOrder(1))
   TRBZAE->(DbGoTop())
EndIf   

If Len(_aDadosMsg) > 0
   _aCabecalho := {}
   
   Aadd(_aCabecalho,"Produto")
   Aadd(_aCabecalho,"Descri��o")
   Aadd(_aCabecalho,"Rede")
   Aadd(_aCabecalho,"Cliente")
   Aadd(_aCabecalho,"Loja")
   
   _cTitulo  := "Lista de Produtos com Regras de Comiss�o j� Cadastradas para o Vendedor: " + If(Altera,_cCodVend,M->ZAE_VEND)
   
   u_ITListBox( _cTitulo , _aCabecalho , _aDadosMsg) // Exibe uma tela de resultado.
   _aDadosMsg := {}
   
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AFIN004MLN
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Invert sele��o no markbrowse
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004MLN()

If ( _aGrid[_oBoxLib:nAt][02] == _bMarkNo )
	_aGrid[_oBoxLib:nAt][02] := _bMarkOk
Else
	_aGrid[_oBoxLib:nAt][02] := _bMarkNo
EndIf

_oBoxLib:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: AFIN004FB1
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Carrega dados do grid de produtos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004FB1( _cGrupo , _cDescr , oproc,_lNMostSel,_lRotinaMVC,_oModDet)

Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()
Local _bVerde	:= LoadBitmap( GetResources() , "BR_VERDE" )
Local _cProds  := AFIN4FPRO(_lRotinaMVC,_oModDet)

Default _lNMostSel  := .F.

oproc:cCaption := ("Lendo dados...")
ProcessMessages()

_cQuery := " SELECT SB1.B1_COD , SB1.B1_I_DESCD , SB1.B1_GRUPO , SB1.B1_I_BIMIX "
_cQuery += " FROM  "+ RetSqlName('SB1') +" SB1 "
_cQuery += " WHERE "+ RetSqlCond('SB1')
_cQuery += " AND SB1.B1_MSBLQL <> '1'"

If !Empty(_cGrupo) //Se o grupo nao esta vazio
	_cQuery += " AND SB1.B1_GRUPO IN "+ FormatIn( AllTrim(_cGrupo) , ';' )
ENDIF

If !Empty(_cMIXBI) //Se o MIX BI nao esta vazio
	_cQuery += " AND SB1.B1_I_BIMIX IN "+ FormatIn( AllTrim(_cMIXBI) , ';' )
ENDIF

If _lNMostSel .AND. !Empty(_cProds)
   _cQuery += "  AND SB1.B1_COD NOT IN " + FormatIn(_cProds,";") 
EndIf

If !Empty(_cDescr) //Se a descricao nao esta vazia, verifica se a expressao contem na descricao do produto
	_cQuery += " AND B1_I_DESCD LIKE '%"+ AllTrim( _cDescr ) +"%' "
EndIf

_cQuery += " ORDER BY SB1.B1_COD "

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

_aGrid := {}

DBSelectArea(_cAlias)
nTotal:=_npos:=0
COUNT TO nTotal

_cTotal:=TRANSFORM(nTotal,"@E 999,999,999")
_oTotal:Refresh()

BEGIN SEQUENCE
IF nTotal > 32700
   IF Empty(_cGrupo+_cMIXBI+_cDescr) 
      U_ITMSG("N�o foi informado nenhum par�metro de pesquisa.","Aten��o","Informe algum par�metro de pesquisa para dar continuidade.",3)  
   ELSE
      U_ITMSG("Os dados informados na pesquisa excedem limite de processamento.","Aten��o","Filtre menos itens ou divida sua busca para dar continuidade",3)
   ENDIF
   BREAK
ENDIF

(_cAlias)->( DBGoTop() )
While (_cAlias)->( !EoF() )

   oproc:cCaption := ("Lendo Produto" + STRZERO(_npos,9) + " de " + STRZERO(nTotal,9))
   ProcessMessages()
   _npos++

	aAdd( _aGrid , {	_bVerde	             ,;
						_bMarkNo			 ,;
						(_cAlias)->B1_COD	 ,;
						(_cAlias)->B1_I_DESCD,;
						(_cAlias)->B1_GRUPO  ,;
						(_cAlias)->B1_I_BIMIX})
	

(_cAlias)->( DBSkip() )
EndDo

END SEQUENCE

If Empty( _aGrid )

	_aGrid := { {	LoadBitmap( GetResources() , "BR_CINZA" )	,;
					_bMarkNo									,;
					""											,;
					""											,;
					""											,;
					""											}}

EndIf

(_cAlias)->( DBCloseArea() )

_oBoxLib:SetArray( _aGrid )

_oBoxLib:bLine := {|| {	_aGrid[_oBoxLib:nAt][01]	,;
						_aGrid[_oBoxLib:nAt][02]	,;
						_aGrid[_oBoxLib:nAt][03]	,;
						_aGrid[_oBoxLib:nAt][04]	,;
						_aGrid[_oBoxLib:nAt][05]	,;
						_aGrid[_oBoxLib:nAt][06]	}}

_oBoxLib:Refresh()

Return .T.

/*
===============================================================================================================================
Programa----------: AFIN004MAL
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Invert marca��es do grid
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004MAL()

Local _nI		:= 0
Local _lMark	:= ( _aGrid[01][02] == _bMarkOk )

For _nI := 1 To Len( _aGrid )

	_aGrid[_nI][02] := IIf( _lMark , _bMarkNo , _bMarkOk )
	
Next _nI

_oBoxLib:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: AFIN004GRV
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Grava��o para inclus�o de produtos no cadastro de v�rios vendedores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004GRV( _cCodPrd , _nSetPer , _aItens )

Local _cQuery 		:= ''
Local _cItem  		:= ''
Local _cAlias 		:= GetNextAlias()
Local _nTotReg		:= Len( _aItens )
Local _nRegAtu		:= 0
Local _nRegGrv		:= 0
Local _nI			:= 0

If _nTotReg > 0
	
	ProcRegua( _nTotReg )
	
	For _nI := 1 To _nTotReg
		
		_nRegAtu++
		IncProc( 'Verificando vendedor: ['+ StrZero( _nRegAtu , 6 ) +'] de ['+ StrZero( _nTotReg , 6 ) +']' )
		
		DBSelectArea('SA3')
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFilial('SA3') + _aItens[_nI][01] ) )
			
			DBSelectArea('ZAE')
			ZAE->( DBSetOrder(1) )
			If ZAE->( DBSeek( xFilial('ZAE') + _aItens[_nI][01] + _cCodPrd ) )
			    
				ZAE->( RecLock( 'ZAE' , .F. ) )
				ZAE->ZAE_COMIS1 := _nSetPer
				ZAE->( MsUnLock() )
				
				_nRegGrv++
			
			Else
				
				_cQuery := " SELECT MAX(ZAE.ZAE_ITEM) AS ITEM FROM "+ RetSqlName('ZAE') +" ZAE WHERE "+ RetSqlCond('ZAE') +" AND ZAE.ZAE_VEND = '"+ _aItens[_nI][01] +"' "
				
				DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )
				DBSelectArea(_cAlias)
				(_cAlias)->( DBGoTop() )
				
				If Empty( (_cAlias)->ITEM )
					_cItem := '001'
				Else
					_cItem := Soma1( (_cAlias)->ITEM )
				EndIf
				
				(_cAlias)->( DBCloseArea() )
				
				ZAE->( RecLock( 'ZAE' , .T. ) )
				ZAE->ZAE_FILIAL	:= xFilial('ZAE')
				ZAE->ZAE_VEND	:= _aItens[_nI][01]
				ZAE->ZAE_ITEM	:= _cItem
				ZAE->ZAE_PROD	:= _cCodPrd
				ZAE->ZAE_COMIS1	:= _nSetPer
				ZAE->ZAE_CODSUP	:= SA3->A3_SUPER
				ZAE->ZAE_CODGER	:= SA3->A3_GEREN
				ZAE->ZAE_CODSUI := SA3->A3_I_SUPE
				ZAE->ZAE_CODGNC := SA3->A3_I_GERNC  

				ZAE->( MsUnLock() )
				
				_nRegGrv++
				
			EndIf
			
		EndIf
		
	Next _nI
	
EndIf

Return( _nRegGrv )

/*
===============================================================================================================================
Programa----------: AFIN004C
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Inclus�o de comiss�o por supervisor/coordenador/gerente/gerente nacional.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN004C( _nOpc )

Local _bOk			:= {|| IIF( AFIN004VGR( _cCodVen , _nPerPad , aItens , _nOpc ) , ( _nCtrl := 1 , _oDlg:End() ) , Nil ) }
Local _bCancel		:= {|| _oDlg:End() }

Local aCoors		:= FWGetDialogSize( oMainWnd )
Local aItens		:= {}

Local _oLayer		:= Nil
Local _oPanCfg		:= Nil
Local _oPanGrp		:= Nil
Local _oPanPrd		:= Nil
Local _oRelSB1		:= Nil
Local _oCodGer		:= Nil
Local _oCodGNc		:= Nil 
Local _oCodSup		:= Nil
Local _oNomVen		:= Nil 
Local _oPerPad		:= Nil
Local _oCheck		:= Nil
Local _oCodVen		:= Nil
Local bChkMarca		:= {|| }
Local lMarcou		:= .F.
Local bMarca		:= {|| }
Local bMarcaAll		:= {|| }

Local _cTipo		:= '1-Coordenador'
Local _cNomVen		:= Space(40)
Local _aCols		:= {}
Local _lCheck		:= .F.

Local _cTitAux		:= IIF( _nOpc == 1 , 'Inclus�o de novos produtos para Vendedores' , 'Atualiza��o da Configura��o de Supervisores/Coordenadores/Gerentes' )

Local _aBkpARotina  

Private _nCtrl		:= 0
Private _cCodVen	:= Space(06)
Private _oDlg		:= Nil
Private _oBrwPrd	:= Nil
Private _oBrwGrp	:= Nil
Private _nPerPad	:= 0
Private _aGrupoIt   := {}

_lRet := U_ITVLDUSR(5) .OR. SuperGetMV("IT_AMBTEST",.F.,.T.)
	
If !_lRet

	_aInfHlp := {}
	aAdd( _aInfHlp	, { "Usu�rio sem acesso � manuten��o das "	,"regras de comiss�o! "						} )
	aAdd( _aInfHlp	, { "Verifique com a �rea de TI/ERP para "	,"solicitar a libera��o. "					} )
	
    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
    //U_ITCADHLP( _aInfHlp , "AFIN00405" )
	
EndIf

//====================================================================================================
// O menu principal est� sendo exibido em rotina secund�ria chamada pelo pr�prio menu prnciapal.
// As instru��es a seguir desabilita a exibi��o do menu principal na rotina secund�ria.
//====================================================================================================
_aBkpARotina  := Aclone(aRotina) 
aRotina := {} 

//====================================================================================================
// Monta area onde serao incluidos os paineis
//====================================================================================================
Define MsDialog _oDlg Title _cTitAux From aCoors[1], aCoors[2] To aCoors[3]+100, aCoors[4] Pixel

_oLayer := FWLayer():New()

_oLayer:Init( _oDlg , .F. , .T. )

//====================================================================================================
// Monta os Pain�is
//====================================================================================================
_oLayer:AddLine( "UpLine" , 050 , .F. ) 					// Cria uma "linha" com 50% da tela

_oLayer:AddCollumn( "Esq" , 050 , .T. , "UpLine" )			// Na "linha" criada utilizar uma coluna com 035% da tamanho dela
_oLayer:AddCollumn( "Dir" , 050 , .T. , "UpLine" )			// Na "linha" criada utilizar uma coluna com 065% da tamanho dela

_oPanCfg := _oLayer:GetColPanel( "Esq" , "UpLine" )			// Cria o objeto superior esquerdo
_oPanGrp := _oLayer:GetColPanel( "Dir" , "UpLine" )			// Cria o objeto superior direito

//====================================================================================================
// Monta Painel Inferior
//====================================================================================================
_oLayer:AddLine( "ParLine" , 050 , .F. )						// Cria uma "linha" com 50% da tela
_oLayer:AddCollumn( "Par" , 100 , .T. , "ParLine" )				// Na "linha" criada utilizar uma coluna com 100% da tamanho dela
_oPanPrd := _oLayer:GetColPanel( "Par" , "ParLine" )	   		// Cria o Objeto Inferior

//====================================================================================================
// Monta Browse Principal
//====================================================================================================
If _nOpc == 1
	
	_cCodVen	:= Space(015)
	_cNomVen	:= Space(100)
	_nPerPad	:= 0
	bChkMarca	:= {|| If( aScan( aItens , { |x| x[1] == TEMP->CODIGO } ) == 0 , 'LBNO', 'LBOK' ) }
	lMarcou		:= .F.
	bMarca		:= {|| ( IIf ( ( nPos := aScan( aItens , { |x| x[1] == TEMP->CODIGO } ) ) == 0 , ( aAdd( aItens , { TEMP->CODIGO } ) , lMarcou := .T. ) , ( aDel( aItens , nPos ) , aSize( aItens , Len( aItens ) -1 ) , lMarcou := .F. ) ) ) }
	bMarcaAll	:= {|| AFIN004MTP( @aItens , _oBrwPrd , _nOpc ) , _oBrwPrd:Refresh() }
	
	@ 046,008 Say "Produto:" COLOR CLR_BLACK						PIXEL OF _oPanCfg Size 050,006
	@ 053,008 MSGet _oCodVen Var _cCodVen  F3 'SB1_04'			 	PIXEL OF _oPanCfg Size 050,010 VALID ( !Empty( _cNomVen := AllTrim( POSICIONE('SB1',1,xFilial('SB1')+_cCodVen,'B1_DESC') ) ) )
	
	@ 046,060 Say "Descri��o:" COLOR CLR_BLACK						PIXEL OF _oPanCfg Size 050,006
	@ 053,060 MsGet _oNomVen Var _cNomVen Picture "@!"				PIXEL OF _oPanCfg Size 200,010 COLOR CLR_BLACK WHEN .F.
	
	@ 066,008 Say "% Padr�o:" COLOR CLR_BLACK						PIXEL OF _oPanCfg Size 050,006
	@ 073,008 MsGet _oPerPad Var _nPerPad Picture "@E 999.999"		PIXEL OF _oPanCfg Size 050,010 COLOR CLR_BLACK VALID ( U_AFIN004P( 4 , _nPerPad ) ) 
	
	//====================================================================================================
	// Monta Browse dos Grupos
	//====================================================================================================
	_oBrwGrp := FWMBrowse():New()
	_oBrwGrp:SetOwner( _oPanGrp )
	_oBrwGrp:SetDescription( "Coordenadores" )
	_oBrwGrp:SetMenuDef( "XXXXXXXX" )
	_oBrwGrp:DisableDetails()
	_oBrwGrp:SetAlias( "SA3" )
	_oBrwGrp:SetProfileID( "2" )
	_oBrwGrp:SetFilterDefault( ' SA3->A3_I_TIPV == "C" ' )
	_oBrwGrp:SetOnlyFields( { 'A3_COD' , 'A3_NOME' } )
	_oBrwGrp:DisableConfig()
	_oBrwGrp:DisableFilter()
	_oBrwGrp:Activate()
	_oBrwGrp:OptionReport(.f.)
	
	_cQuery := " SELECT "
	_cQuery += "     SA3.A3_COD   AS CODIGO ,"
	_cQuery += "     SA3.A3_NOME  AS NOME   ,"
	_cQuery += "     SA3.A3_SUPER AS SUPER   "
	_cQuery += " FROM  "+ RetSqlName('SA3') +" SA3 "
	_cQuery += " WHERE "+ RetSqlCond('SA3')
	_cQuery += " AND SA3.A3_MSBLQL <> '1' "
	_cQuery += " ORDER BY SA3.A3_COD "
	
	//====================================================================================================
	// Monta Browse dos Produtos
	//====================================================================================================
	_oBrwPrd := FWMBrowse():New()
	_oBrwPrd:SetOwner( _oPanPrd )
	_oBrwPrd:SetDescription( "Vendedores" )
	_oBrwPrd:SetMenuDef( "XXXXXXXX" )
	_oBrwPrd:DisableDetails()
	_oBrwPrd:SetDataQuery()
	_oBrwPrd:SetQuery( _cQuery )
	_oBrwPrd:SetAlias( 'TEMP' )
	_oBrwPrd:SetProfileID( "3" )
	_oBrwPrd:AddMarkColumns( bChkMarca , bMarca , bMarcaAll )
	
	AAdd( _aCols , FWBrwColumn():New() )
	_aCols[01]:SetData( &("{|| TEMP->CODIGO }") )
	_aCols[01]:SetTitle( 'C�digo' )
	_aCols[01]:SetSize( 06 )
	_aCols[01]:SetDecimal( 0 )
	_aCols[01]:XPICTURE := "@!"
	
	AAdd( _aCols , FWBrwColumn():New() )
	_aCols[02]:SetData( &("{|| TEMP->NOME }") )
	_aCols[02]:SetTitle( 'Nome' )
	_aCols[02]:SetSize( 06 )
	_aCols[02]:SetDecimal( 0 )
	_aCols[02]:XPICTURE := "@!"

	_oBrwPrd:SetColumns( _aCols )
	_oBrwPrd:DisableConfig()
	_oBrwPrd:Activate()
	
	_oRelSB1 := FWBrwRelation():New()
	_oRelSB1:AddRelation( _oBrwGrp , _oBrwPrd , { { "A3_SUPER" , "A3_COD" } } )
	_oRelSB1:Activate()
	
Else

	bChkMarca	:= {|| If( aScan( aItens , { |x| x[1] == SB1->B1_COD } ) == 0 , 'LBNO', 'LBOK' ) }
	lMarcou		:= .F.
	bMarca		:= {|| ( IIf ( ( nPos := aScan( aItens , { |x| x[1] == SB1->B1_COD } ) ) == 0 , ( aAdd( aItens , { SB1->B1_COD } ) , lMarcou := .T. ) , ( aDel( aItens , nPos ) , aSize( aItens , Len( aItens ) -1 ) , lMarcou := .F. ) ) ) }
	bMarcaAll	:= {|| AFIN004MTP( @aItens , _oBrwPrd , _nOpc ) }

	@ 026,008 Say "Tipo:"									   		PIXEL OF _oPanCfg SIZE 050,006
	@ 033,008 ComboBox _cTipo ITEMS {'1-Coordenador','2-Gerente','3-Supervisor','4-Gerente Nacional'}	; 
			PIXEL OF _oPanCfg SIZE 070,010 Valid( IF( SubStr(_cTipo,1,1) == '1',( _oCodSup:Show() , _oCodGer:Hide() , _oCodSui:Hide(),_oCodGNc:Hide(), _cNomVen := '' , _cCodVen := '      ' ) ,;
			 									  If( SubStr(_cTipo,1,1) == '2',( _oCodSup:Hide() , _oCodGer:Show() , _oCodSui:Hide(),_oCodGNc:Hide(), _cNomVen := '' , _cCodVen := '      ' ),;
			 									  If( SubStr(_cTipo,1,1) == '3',( _oCodSup:Hide() , _oCodGer:Hide() , _oCodGNc:Hide(),_oCodSui:Show(), _cNomVen := '' , _cCodVen := '      ' ),;
																			    ( _oCodSup:Hide() , _oCodGer:Hide() , _oCodSui:Hide(),_oCodGNc:Show(), _cNomVen := '' , _cCodVen := '      ' ) ) ) ))
																					 
	@ 046,008 Say "C�digo:"	COLOR CLR_BLACK						   	PIXEL OF _oPanCfg Size 050,006
	@ 053,008 MSGet _oCodSup Var _cCodVen						   	PIXEL OF _oPanCfg Size 040,010 F3 'SA3_01' VALID ( Vazio() .Or. AFIN004VCS( _cCodVen , 2 , 1 ) .And. !Empty( _cNomVen := AllTrim( POSICIONE('SA3',1,xFilial('SA3')+_cCodVen,'A3_NOME') ) ) )
	@ 053,008 MSGet _oCodGer Var _cCodVen						   	PIXEL OF _oPanCfg Size 040,010 F3 'SA3_02' VALID ( Vazio() .Or. AFIN004VCS( _cCodVen , 2 , 2 ) .And. !Empty( _cNomVen := AllTrim( POSICIONE('SA3',1,xFilial('SA3')+_cCodVen,'A3_NOME') ) ) )
	@ 053,008 MSGet _oCodSui Var _cCodVen						   	PIXEL OF _oPanCfg Size 040,010 F3 'SA3_03' VALID ( Vazio() .Or. AFIN004VCS( _cCodVen , 2 , 3 ) .And. !Empty( _cNomVen := AllTrim( POSICIONE('SA3',1,xFilial('SA3')+_cCodVen,'A3_NOME') ) ) )
	@ 053,008 MSGet _oCodGNc Var _cCodVen						   	PIXEL OF _oPanCfg Size 040,010 F3 'SA3_04' VALID ( Vazio() .Or. AFIN004VCS( _cCodVen , 2 , 4 ) .And. !Empty( _cNomVen := AllTrim( POSICIONE('SA3',1,xFilial('SA3')+_cCodVen,'A3_NOME') ) ) )
	
	_oCodSup:Show() ; _oCodGer:Hide() ; _oCodSui:Hide() ; _oCodGNc:Hide()
	
	@ 046,050 Say "Coord./Gerente/Superv./Gerente Nac:" COLOR CLR_BLACK			   		PIXEL OF _oPanCfg Size 110,006
	@ 053,050 MsGet _oNomVen Var _cNomVen Picture "@!"		   		PIXEL OF _oPanCfg Size 200,010 COLOR CLR_BLACK WHEN .F.
	
	@ 066,008 Say "% Padr�o:" COLOR CLR_BLACK				   		PIXEL OF _oPanCfg Size 050,006
	@ 073,008 MsGet _oPerPad Var _nPerPad Picture "@E 999.999"  		PIXEL OF _oPanCfg Size 050,010 COLOR CLR_BLACK VALID ( U_AFIN004P( 5 , _nPerPad ) ) 
	
	@ 075,065 Checkbox _oCheck VAR _lCheck PROMPT "Aplicar � todos os Produtos"	PIXEL OF _oPanCfg SIZE 200,008 ON CLICK( AFIN004TPT( _lCheck , @aItens ) , _oBrwPrd:Refresh() )

    @ 095,008 Button "Sele��o por Grupo"        Size 090,012 PIXEL OF _oPanCfg Action(FWMsgRun(,{||AFIN004N(@aItens,SBM->BM_GRUPO),_oBrwPrd:Refresh()},"Marcando/Desmarcando itens...","Aguarde!")) // 226,353


	//====================================================================================================
	// Monta Browse dos Grupos
	//====================================================================================================
	_oBrwGrp := FWMBrowse():New()
	_oBrwGrp:SetOwner( _oPanGrp )
	_oBrwGrp:SetDescription( "Grupos de Produtos" )
	_oBrwGrp:SetMenuDef( "XXXXXXXX" )
	_oBrwGrp:DisableDetails()
	_oBrwGrp:SetAlias( "SBM" )
	_oBrwGrp:SetProfileID( "2" )
	_oBrwGrp:SetFilterDefault( ' U_AFIN004W( SBM->BM_GRUPO ) ' )
	_oBrwGrp:SetOnlyFields( { 'BM_GRUPO' , 'BM_DESC' } )
	_oBrwGrp:DisableConfig()
	_oBrwGrp:DisableFilter()
	_oBrwGrp:Activate()
	
	//====================================================================================================
	// Monta Browse dos Produtos
	//====================================================================================================
	_oBrwPrd := FWMBrowse():New()
	_oBrwPrd:SetOwner( _oPanPrd )
	_oBrwPrd:SetDescription( "Produtos" )
	_oBrwPrd:SetMenuDef( "XXXXXXXX" )
	_oBrwPrd:DisableDetails()
	_oBrwPrd:SetAlias( "SB1" )
	_oBrwPrd:SetProfileID( "3" )
	_oBrwPrd:SetOnlyFields( {'B1_COD','B1_DESC','B1_TIPO'} )
	_oBrwPrd:SetFilterDefault( ' SB1->B1_MSBLQL <> "1" .And. SB1->B1_TIPO == "PA" ' )
	_oBrwPrd:AddMarkColumns( bChkMarca , bMarca , bMarcaAll )
	_oBrwPrd:DisableConfig()
	_oBrwPrd:Activate()
	
	_oRelSB1 := FWBrwRelation():New()
	_oRelSB1:AddRelation( _oBrwGrp , _oBrwPrd , { { "B1_FILIAL" , "xFilial('SB1')" } , { "B1_GRUPO" , "BM_GRUPO" } } )
	_oRelSB1:Activate()

EndIf

Activate MsDialog _oDlg ON INIT EnchoiceBar(_oDlg,_bOk,_bCancel) CENTERED	

If _nCtrl == 1
	FWMsgRun(,{|oProc| AFIN004GCC( oProc,_nOpc , Val( SubStr(_cTipo,1,1) ) , _cCodVen , _nPerPad , aItens ) },"Processando registros... "+TIME(),"Aguarde!" )
EndIf

//====================================================================================================
// Volta as op��es do menu principal.
//====================================================================================================
aRotina := Aclone(_aBkpARotina)  

//Fecha objeto do fwmbrowse
_oBrwPrd:Destroy()  

_oBrwPrd := nil

Return()

/*
===============================================================================================================================
Programa----------: AFIN004MTP
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Marca todos os itens do browse
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004MTP( aItens , oBrowseAux , _nOpc )

Local _aRegs	:= {}
Local _nI		:= 0
Local _nPos		:= 0
Local _lMarca	:= .F.

If _nOpc == 1
	
	TEMP->( DBGoTop() )
	_lMarca := ( _nPos := aScan( aItens , { |x| x[1] == TEMP->CODIGO } ) ) == 0
	
	While ( TEMP->( !Eof() ) )
		
		If _lMarca
			
			If ( _nPos := aScan( aItens , { |x| x[1] == TEMP->CODIGO } ) ) == 0
				aAdd( aItens , { TEMP->CODIGO } )
			EndIf
			
		Else
		
			If ( _nPos := aScan( aItens , { |x| x[1] == TEMP->CODIGO } ) ) <> 0
				aDel(  aItens , _nPos            )
				aSize( aItens , Len( aItens ) -1 )
			EndIf
			
		EndIf
		
	TEMP->( DBSkip() )
	EndDo
	
	TEMP->( DBGoTop() )
	
Else

	_aRegs := oBrowseAux:aVisibleReg
	_nRegs2:= oBrowseAux:LogicLen()
	_nTotal:= Len( _aRegs )
	
	oBrowseAux:GoTop()
	
	If ( _nPos := aScan( aItens , { |x| x[1] == SB1->B1_COD } ) ) == 0
		
		For _nI := 1 To _nTotal
		
			oBrowseAux:GoTo( _aRegs[_nI] )
			
			If ( _nPos := aScan( aItens , { |x| x[1] == SB1->B1_COD } ) ) == 0
				aAdd( aItens , { SB1->B1_COD } )
			EndIf
			
		Next _nI
	
	Else
	
		For _nI := 1 To Len( _aRegs )
		
			oBrowseAux:GoTo( _aRegs[_nI] )
			
			If ( _nPos := aScan( aItens , { |x| x[1] == SB1->B1_COD } ) ) <> 0
				
				aDel(  aItens , _nPos            )
				aSize( aItens , Len( aItens ) -1 )
				
			EndIf
			
		Next _nI
		
	EndIf
	IF LEN(_aRegs) > 0 
	   oBrowseAux:GoTo( _aRegs[1] )
	ELSE
		oBrowseAux:GoTop()
    ENDIF

EndIf

Return()

/*
===============================================================================================================================
Programa----------: AFIN004W
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Monta filtro do grid
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AFIN004W( _cCodGrp )

Local _lRet		:= .F.
Local _cQuery	:= " SELECT COUNT(1) AS GRUPO FROM "+ RETSQLNAME('SB1') +" SB1 WHERE "+ RETSQLCOND('SB1') +" AND B1_GRUPO = '"+ _cCodGrp +"' AND B1_TIPO = 'PA' AND B1_MSBLQL <> '1'"
Local _cAlias	:= GetNextAlias()

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() ) .And. (_cAlias)->GRUPO > 0
	_lRet := .T.
EndIf

(_cAlias)->( DBCloseArea() )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: FILCSA3
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Filtro para verificar o c�digo de Coordenadores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function FILCSA3( _cCodSup )

Local _lRet		:= .F.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

If _nCtrl <> 0
	Return( .T. )
EndIf

_cQuery := " SELECT COUNT(1) AS CODIGO "
_cQuery += " FROM  "+ RetSqlName('SA3') +" SA3 "
_cQuery += " WHERE "+ RetSqlCond('SA3')
_cQuery += " AND SA3.A3_COD    = '"+ _cCodSup +"' "
_cQuery += " AND SA3.A3_MSBLQL <> '1' "
_cQuery += " AND EXISTS ( SELECT AUX.A3_COD FROM "+ RetSqlName('SA3') +" AUX WHERE AUX.D_E_L_E_T_ = ' ' AND AUX.A3_MSBLQL <> '1' AND AUX.A3_SUPER = SA3.A3_COD ) "

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() ) .And. (_cAlias)->CODIGO > 0
	_lRet := .T.
EndIf

(_cAlias)->( DBCloseArea() )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: FILSSA3
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Filtro para verificar o c�digo de Supervisores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function FILSSA3( _cCodSup )

Local _lRet		:= .F.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

If _nCtrl <> 0
	Return( .T. )
EndIf

_cQuery := " SELECT COUNT(1) AS CODIGO "
_cQuery += " FROM  "+ RetSqlName('SA3') +" SA3 "
_cQuery += " WHERE "+ RetSqlCond('SA3')
_cQuery += " AND SA3.A3_COD    = '"+ _cCodSup +"' "
_cQuery += " AND SA3.A3_MSBLQL <> '1' "
_cQuery += " AND EXISTS ( SELECT AUX.A3_COD FROM "+ RetSqlName('SA3') +" AUX WHERE AUX.D_E_L_E_T_ = ' ' AND AUX.A3_MSBLQL <> '1' AND AUX.A3_I_SUPE = SA3.A3_COD ) "

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() ) .And. (_cAlias)->CODIGO > 0
	_lRet := .T.
EndIf

(_cAlias)->( DBCloseArea() )

Return( _lRet )


/*
===============================================================================================================================
Programa----------: AFIN004GCC
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Valida comiss�o
===============================================================================================================================
Parametros--------: oProc,_nOpc , _nCfg , _cCodVen , _nSetPer , _aItens
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004GCC( oProc,_nOpc , _nCfg , _cCodVen , _nSetPer , _aItens )

Local _aVends	:= {}
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _cSuper	:= ''
Local _cGeren	:= ''
Local _cGerNac	:= ''
Local _nRegT	:= 0
Local _nRegGrv	:= 0
Local _nI		:= 0
Local _nX		:= 0
Local _lTemMsm	:= .F.

If _nOpc == 1

	Processa( {|| _nRegGrv := AFIN004GRV( _cCodVen , _nSetPer , _aItens ) } , "Processando" , "Verificando os dados, aguarde..." , .F. )

Else

	_cQuery := " SELECT DISTINCT "
	_cQuery += "     ZAE.ZAE_VEND AS CODIGO, "
	_cQuery += "     SA3.A3_NOME  AS NOME "
	_cQuery += " FROM  "+ RETSQLNAME('ZAE') +" ZAE "
	_cQuery += " JOIN  "+ RETSQLNAME('SA3') +" SA3 ON ZAE.ZAE_VEND = SA3.A3_COD "
	_cQuery += " WHERE "+ RETSQLCOND('ZAE,SA3')
	
	If _nCfg == 1
		_cQuery += " AND ZAE.ZAE_CODSUP = '"+ _cCodVen +"' "
	ElseIF _NcFG == 2
		_cQuery += " AND ZAE.ZAE_CODGER = '"+ _cCodVen +"' "
	ElseIF _NcFG == 3
		_cQuery += " AND ZAE.ZAE_CODSUI = '"+ _cCodVen +"' "
	ElseIF _NcFG == 4
		_cQuery += " AND ZAE.ZAE_CODGNC = '"+ _cCodVen +"' "
	EndIf
	
	_cQuery += " ORDER BY SA3.A3_NOME "
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	While (_cAlias)->( !Eof() )
		
		aAdd( _aVends , { .F. , (_cAlias)->CODIGO , (_cAlias)->NOME } )
		
	(_cAlias)->( DBSkip() )
	EndDo
		
	If LEN(_aVends) > 0 .AND. U_ITListBox( 'Vendedores:' , { '[X]' , 'C�digo' , 'Nome' } , @_aVends , .F. , 2 , 'Selecione os vendedores que ser�o atualizados:' )
	
		_nRegT := Len( _aVends )
		
		For _nI := 1 To _nRegT
	
			If _aVends[_nI][01]
				
				If _nSetPer > 0
					
					//====================================================================================================
					// Valida se o Vendedor est� configurado como Supervisor ou Coordenador ou Gerente ou Gerente Nacional
					// de outro Vendedor.
					//====================================================================================================
					If AFIN004VCG( 5 , _aVends[_nI][02] , _cCodVen)//Valida o vendendor marcado (_aVends[_nI][02]) contra o codigo digitado (_cCodVen)
					
						U_ITMSG('N�o � permitido definir valores de comiss�o para o '+ IF(_nCfg == 1,"coordenador",;
						                                                               IF(_nCfg == 2,'gerente'    ,;
																					   IF(_nCfg == 3,'supervisor' ,;
																					         'gerente nacional' )));
						 		+' quando o vendedor selecionado for '+ IF(_nCfg == 1,"coordenador",;
						                                                IF(_nCfg == 2,'gerente'    ,;
																	    IF(_nCfg == 3,'supervisor' ,;
																	          'gerente nacional' )));
						 		+' tambem.' , 'Aten��o!' ,;
								'Vendedor selecionado: '+ _aVends[_nI][02] +"-"+ ALLTRIM(Posicione('SA3',1,xFilial('SA3')+_aVends[_nI][02],'A3_NOME')) ,1 )
						Loop
					
					EndIf
					
				EndIf
				
				_lTemMsm := .F.//CONTROLE PARA A MENSAGEM GERAL POR VENDEDOR
				
				For _nX := 1 To Len( _aItens )
				
					DBSelectArea('ZAE')
					ZAE->( DBSetOrder(1) )
					If ZAE->( DBSeek( xFilial('ZAE') + _aVends[_nI][02] + _aItens[_nX][01] ) )
					    
					   DO WHILE ZAE->(!EOF()) .AND. xFilial('ZAE') + _aVends[_nI][02] + _aItens[_nX][01] == ZAE->ZAE_FILIAL+ZAE->ZAE_VEND+ZAE->ZAE_PROD
					     
						 _lLoop:=.F.//CONTROLE DE CADA LINNHA DE VAI DAR LOOP OU N�O NA LINHA
					     
						 If _nCfg == 1 .And. ZAE->ZAE_CODSUP == _cCodVen//COORDENADOR
							
							If _nSetPer > 0 
							
								_cCoord := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUP , 'A3_FORNECE' )
								
								IF !Empty( ZAE->ZAE_CODGER ) .And. (ZAE->ZAE_COMIS3 > 0 .OR. ZAE->ZAE_COMVA3 > 0 )
								   _cGeren := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGER , 'A3_FORNECE' )
							       If _cCoord == _cGeren 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODSUI ) .And. (ZAE->ZAE_COMIS4 > 0 .OR. ZAE->ZAE_COMVA4 > 0 )
								   _cSuper := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUI , 'A3_FORNECE' )
							       If _cCoord == _cSuper 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODGNC ) .And. (ZAE->ZAE_COMIS5 > 0 .OR. ZAE->ZAE_COMVA5 > 0 )
								   _cGerNac := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGNC , 'A3_FORNECE' )
							       If _cCoord == _cGerNac 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
							EndIf
                            
							IF _lLoop
							   ZAE->(DBSKIP())
							   Loop
							ENDIF
					    	
							ZAE->( RecLock( 'ZAE' , .F. ) )
							ZAE->ZAE_COMIS2 := _nSetPer
							ZAE->ZAE_COMVA2 := _nSetPer
							ZAE->( MsUnLock() )
							
						 ElseIf _nCfg == 3 .And. ZAE->ZAE_CODSUI == _cCodVen
						
							If _nSetPer > 0 
							
								_cSuper := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUI , 'A3_FORNECE' )
								IF !Empty( ZAE->ZAE_CODSUP ) .And. (ZAE->ZAE_COMIS2 > 0 .OR. ZAE->ZAE_COMVA2 > 0 )
								   _cCoord := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUP , 'A3_FORNECE' )
							       If _cSuper == _cCoord 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODGER ) .And. (ZAE->ZAE_COMIS3 > 0 .OR. ZAE->ZAE_COMVA3 > 0 )
								   _cGeren := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGER , 'A3_FORNECE' )
							       If _cSuper == _cGeren 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODGNC ) .And. (ZAE->ZAE_COMIS5 > 0 .OR. ZAE->ZAE_COMVA5 > 0 )
								   _cGerNac := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGNC , 'A3_FORNECE' )
							       If _cSuper == _cGerNac 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
							EndIf

							IF _lLoop
							   ZAE->(DBSKIP())
							   Loop
							ENDIF
							
							ZAE->( RecLock( 'ZAE' , .F. ) )
							ZAE->ZAE_COMIS4 := _nSetPer
							ZAE->ZAE_COMVA4 := _nSetPer
							ZAE->( MsUnLock() )
						
						 ElseIf _nCfg == 2 .And. ZAE->ZAE_CODGER == _cCodVen
						
							If _nSetPer > 0 
							
								_cGeren := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGER , 'A3_FORNECE' )
							
								IF !Empty( ZAE->ZAE_CODSUP ) .And. (ZAE->ZAE_COMIS2 > 0 .OR. ZAE->ZAE_COMVA2 > 0 )
								   _cCoord := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUP , 'A3_FORNECE' )
							       If _cGeren == _cCoord 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODSUI ) .And. (ZAE->ZAE_COMIS4 > 0 .OR. ZAE->ZAE_COMVA4 > 0 )
								   _cSuper := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUI , 'A3_FORNECE' )
							       If _cGeren == _cSuper 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODGNC ) .And. (ZAE->ZAE_COMIS5 > 0 .OR. ZAE->ZAE_COMVA5 > 0 )
								   _cGerNac := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGNC , 'A3_FORNECE' )
							       If _cGeren == _cGerNac 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
							EndIf
                            
							IF _lLoop
							   ZAE->(DBSKIP())
							   Loop
							ENDIF
							
							ZAE->( RecLock( 'ZAE' , .F. ) )
							ZAE->ZAE_COMIS3 := _nSetPer
							ZAE->ZAE_COMVA3 := _nSetPer
							ZAE->( MsUnLock() )
		                
                         ElseIf _nCfg == 4 .And. ZAE->ZAE_CODGNC == _cCodVen 
						
							If _nSetPer > 0 
							
								_cGerNac:= Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGNC , 'A3_FORNECE' )
								
								IF !Empty( ZAE->ZAE_CODSUP ) .And. (ZAE->ZAE_COMIS2 > 0 .OR. ZAE->ZAE_COMVA2 > 0 )
								   _cCoord := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUP , 'A3_FORNECE' )
							       If _cGerNac == _cCoord 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODGER ) .And. (ZAE->ZAE_COMIS3 > 0 .OR. ZAE->ZAE_COMVA3 > 0 )
								   _cGeren := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODGER , 'A3_FORNECE' )
							       If _cGerNac == _cGeren 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
								IF !Empty( ZAE->ZAE_CODSUI ) .And. (ZAE->ZAE_COMIS4 > 0 .OR. ZAE->ZAE_COMVA4 > 0 )
								   _cSuper := Posicione( 'SA3' , 1 , xFilial('SA3') + ZAE->ZAE_CODSUI , 'A3_FORNECE' )
							       If _cGerNac == _cSuper 							    	
							    	  _lTemMsm := .T.
									  _lLoop:=.T.
								   ENDIF
								ENDIF
							EndIf
                            
							IF _lLoop
							   ZAE->(DBSKIP())
							   Loop
							ENDIF
							
							ZAE->( RecLock( 'ZAE' , .F. ) )
							ZAE->ZAE_COMIS5 := _nSetPer
							ZAE->ZAE_COMVA5 := _nSetPer
							ZAE->( MsUnLock() )		

						 EndIf
					    _nRegGrv++
						ZAE->(DBSKIP())
					 ENDDO	

			         oproc:cCaption := "Lendo Vend.: "+ _aVends[_nI][02]+" ["+ALLTRIM(STR(_nI)) +'/'+ alltrim(Str(_nRegT)) +'] / Item: '+ ALLTRIM(STR(_nX)) +'/'+ alltrim(Str( Len( _aItens )) ) +' / Atualizados: '+alltrim(Str( _nRegGrv  ))
			         ProcessMessages()

					EndIf
				
				Next _nX
				
				If _lTemMsm
				
					u_itmsg(	'Existem produtos que n�o tiveram o % atualizado pois n�o � poss�vel configurar comiss�o para Gerente e Coordenador e Gerente Nacional '	+;
								'ao mesmo tempo quando ambos estiverem amarrados ao mesmo Fornecedor no cadastro de Vendedores do Sistema! '+ CRLF		+;
								'Vendedor selecionado: '+ _aVends[_nI][02] +"-"+ ALLTRIM(Posicione('SA3',1,xFilial('SA3')+_aVends[_nI][02],'A3_NOME')) , 'Aten��o!' ,,3 )
				
				EndIf
			
			EndIf
			
		Next _nI
	
	Elseif len(_aVends) == 0
	
		u_itmsg("N�o foram localizados registros para atualizar!","Aten��o","Verifique os filtros",1)
		
	Elseif len(_aVends) > 0
	
		//u_itmsg("Processo cancelado pelo usu�rio","Aten��o",,1)
	
	EndIf

EndIf

If _nRegGrv > 0
	u_itmsg(  '['+ StrZero( _nRegGrv , 6 ) +'] registros atualizados com sucesso!' , 'Conclu�do!' ,,3 )
Else
	u_itmsg(  'N�o foram encontrados registros para atualizar! Verifique os filtros e dados informados e tente novamente.' , 'Aten��o!' ,,1 )
EndIf

Return()

/*
===============================================================================================================================
Programa----------: F3SUPGER
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Filtro para verificar o c�digo de Gerentes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function F3SUPGER()

Local _lRet	   	:= .F.
Local _nRet 	:= 0
Local _cQuery  	:= ""

_cQuery := " SELECT "
_cQuery += "     SA3.A3_COD  , "
_cQuery += "     SA3.A3_NOME , "
_cQuery += "     SA3.R_E_C_N_O_ AS REGSA3 "
_cQuery += " FROM  "+ RETSQLNAME('SA3') +" SA3 "
_cQuery += " WHERE "
_cQuery += "     SA3.D_E_L_E_T_ = ' ' "
_cQuery += " AND EXISTS ( SELECT AUX.A3_COD FROM "+ RETSQLNAME('SA3') +" AUX WHERE AUX.D_E_L_E_T_ = ' ' AND ( AUX.A3_SUPER = SA3.A3_COD OR AUX.A3_GEREN = SA3.A3_COD ) ) "

If Tk510F3Qry( _cQuery , "SA3_03" , "REGSA3" , @_nRet ,, {"A3_COD","A3_NOME"} , "SA3" )

	SA3->( DBGoto( _nRet ) )
	_lRet := .T.
	
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004VGR
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Valida��o da tela de Inclusao de Produtos/Altera��o de % de Supervisores/Coordenadores/Gerentes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004VGR( _cCodVen , _nPerPad , aItens , _nOpc )

Local _lRet		:= .T.

If Empty( _cCodVen )

	If _nOpc == 1
		u_itmsg( 'Para confirmar � necess�rio informar um c�digo de Produto para a inclus�o!' , 'Aten��o!' , ,1 )
	Else
		u_itmsg( 'Para confirmar � necess�rio informar um c�digo de Supervisor, Coordenador ou Gerente de Vendas!' , 'Aten��o!' , ,1 )
	EndIf
	
	_lRet := .F.
	
Else
	
	If Empty( aItens )
		
		If _nOpc == 1
			u_itmsg( 'Para confirmar � necess�rio selecionar pelo menos um vendedor para a atualiza��o!' , 'Aten��o!' , ,1 )
		Else
			u_itmsg( 'Para confirmar � necess�rio selecionar pelo menos um produto para a atualiza��o!' , 'Aten��o!' , ,1 )
		EndIf
		
		_lRet := .F.
		
	ElseIf _nOpc == 2 .or. _nopc == 3
	
		_lRet := AFIN004VCS( _cCodVen , _nOpc )
	
	EndIf
	
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004VCS
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Valida��o do c�digo de Vendedor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004VCS( _cCodVen , _nOpc , _nAux )

Local _aInfHlp	:= {}
Local _lRet		:= .T.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

Default _nAux	:= 0

If _nOpc == 1
	
	DBSelectArea('SB1')
	SB1->( DBSetOrder(1) )
	If SB1->( DBSeek( xFilial('SB1') + _cCodVen ) )
		
		If SB1->B1_MSBLQL == '1'	
			_lRet := .F.
		EndIf
		
	Else
	
		_lRet := .F.
		
	EndIf
	
	If !_lRet
		
		_aInfHlp := {}
		aAdd( _aInfHlp , { "O c�digo de Produto informado n�o � "		, "v�lido!"								} )
		aAdd( _aInfHlp , { "Deve ser informado um c�digo de Produto "	, "existente e ativo no sistema!"		} )
		
	    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
		//U_ITCADHLP( _aInfHlp , "AFIN00409" )
		
	EndIf

Else

	_cQuery := " SELECT COUNT(1) AS CONTA FROM "+ RETSQLNAME('SA3') +" SA3 "
	_cQuery += " WHERE "+ RETSQLCOND('SA3')
	If _nAux == 1
	   _cQuery += " AND SA3.A3_COD = '"+ _cCodVen +"' AND SA3.A3_I_TIPV = 'C' "
	ElseIf _nAux == 2
	   _cQuery += " AND SA3.A3_COD = '"+ _cCodVen +"' AND SA3.A3_I_TIPV = 'G' "
	ElseIf _nAux == 3
	   _cQuery += " AND SA3.A3_COD = '"+ _cCodVen +"' AND SA3.A3_I_TIPV = 'S' "
	ElseIf _nAux == 4
	   _cQuery += " AND SA3.A3_COD = '"+ _cCodVen +"' AND SA3.A3_I_TIPV = 'N' " 
	Else
	   _cQuery += " AND SA3.A3_COD = '"+ _cCodVen +"' AND SA3.A3_I_TIPV IN ('C','G','S','N') " 
	EndIf
		
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	
	_lRet := ( (_cAlias)->( !Eof() ) .And. (_cAlias)->CONTA > 0 )
	
	(_cAlias)->( DBCloseArea() )
	
	If _lRet
		
		DBSelectArea('SA3')
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFilial('SA3') + _cCodVen ) )
			_lRet := SA3->A3_MSBLQL <> '1'
		Else
			_lRet := .F.
		EndIf
		
	EndIf
	
	If !_lRet
		
		_aInfHlp := {}
		aAdd( _aInfHlp , { "O c�digo de Supervisor/Coordenador/Gerente informado ","n�o � v�lido!"								} )
		aAdd( _aInfHlp , { "Deve ser informado um c�digo de Gerente"	          ,", Coordenador ou Supervisor de vendas ativo no sistema!"	} )
		
	    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
		//U_ITCADHLP( _aInfHlp , "AFIN00408" )
		
	EndIf

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004U
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Atualiza��o das amarra��es de Supervisor/Coordenador/Gerente do cadastro de regras do Vendedor aberto
===============================================================================================================================
Parametros--------: _lRotinaMVC = .T. rotina chamada atrav�s de aplica��o MVC; _lRotinaMVC= .F. rotina chamada atrav�s de  
                    fun��o padr�o do Protheus.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AFIN004U(_lRotinaMVC)

Local _cNomSup	:= ''
Local _cNomGer	:= ''
Local _cNomSui  := ''
Local _cNomeGnc := ''

Local _oModel	
Local _oModDet	
Local _nLinDet	
Local _nI		:= 0
Local _cCODSUP  := ""
Local _cCODGER  := ""
Local _cCodGNC  := ""

Local _lAtualizou := .F.

Default _lRotinaMVC := .T.

If MsgYesNo(	'Confirma a atualiza��o dos dados do Vendedor de acordo com o cadastro do sistema? '		+;
				'Essa atualiza��o ir� zerar os percentuais de comiss�o de todos os registros que forem '	+;
				'atualizados ( Supervisor/Gerente ).' , 'Aten��o!'											 )
	
   DBSelectArea('SA3')
   SA3->( DBSetOrder(1) )
   
   If _lRotinaMVC
      _oModel	:= FWModelActive()
      _oModDet	:= _oModel:GetModel( 'ZAEDETAIL' )
      _nLinDet	:= _oModDet:Length()
      	
      If SA3->( DBSeek( xFilial('SA3') + _oModel:GetValue( 'ZAEMASTER' , 'ZAE_VEND' ) ) ) .And. SA3->A3_I_TIPV == 'V'
		
         For _nI := 1 To _nLinDet
			
             _oModDet:GoLine(_nI)

             If AllTrim( _oModDet:GetValue('ZAE_CODSUP') ) <> AllTrim( SA3->A3_SUPER )
                _oModDet:LoadValue( 'ZAE_CODSUP' , SA3->A3_SUPER )
                _oModDet:LoadValue( 'ZAE_COMIS2' , 0 )
				_oModDet:LoadValue( 'ZAE_COMVA2' , 0 ) 
                _lAtualizou := .T.
             EndIf
             
             If AllTrim( _oModDet:GetValue('ZAE_CODGER') ) <> AllTrim( SA3->A3_GEREN )
                _oModDet:LoadValue( 'ZAE_CODGER' , SA3->A3_GEREN )
                _oModDet:LoadValue( 'ZAE_COMIS3' , 0 )                
				_oModDet:LoadValue( 'ZAE_COMVA3' , 0 ) 
                _lAtualizou := .T.
             EndIf
             
             If AllTrim( _oModDet:GetValue('ZAE_CODSUI') ) <> AllTrim( SA3->A3_I_SUPE )
                _oModDet:LoadValue( 'ZAE_CODSUI' , SA3->A3_I_SUPE )
                _oModDet:LoadValue( 'ZAE_COMIS4' , 0 )                
				_oModDet:LoadValue( 'ZAE_COMVA4' , 0 ) 
                _lAtualizou := .T.
             EndIf
            
			 If AllTrim( _oModDet:GetValue('ZAE_CODGNC') ) <> AllTrim( SA3->A3_I_GERNC )
                _oModDet:LoadValue( 'ZAE_CODGNC' , SA3->A3_I_GERNC )
                _oModDet:LoadValue( 'ZAE_COMIS5' , 0 )                
				_oModDet:LoadValue( 'ZAE_COMVA5' , 0 ) 
                _lAtualizou := .T.
             EndIf
             
         Next _nI

         If !Empty( _oModDet:GetValue('ZAE_CODSUP') )
            _cNomSup := AllTrim( Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODSUP'),'A3_NOME') )
         EndIf
		
         If !Empty( _oModDet:GetValue('ZAE_CODGER') )
            _cNomGer := AllTrim( Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODGER'),'A3_NOME') )
         EndIf
         
         If !Empty( _oModDet:GetValue('ZAE_CODSUI') )
            _cNomSui := AllTrim( Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODSUI'),'A3_NOME') )
         EndIf

		 If !Empty( _oModDet:GetValue('ZAE_CODGNC') )
            _cNomeGnc := AllTrim( Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODGNC'),'A3_NOME') )
         EndIf
         
		 

         For _nI := 1 To _nLinDet
             
             _oModDet:GoLine(_nI)
		 	 _oModDet:LoadValue( 'ZAE_NSUP'   , _cNomSup )
		 	 _oModDet:LoadValue( 'ZAE_NGEREN' , _cNomGer )
		 	 _oModDet:LoadValue( 'ZAE_NSUI'   , _cNomSui )
			 _oModDet:LoadValue( 'ZAE_NGERNC' , _cNomeGnc )
             		
         Next _nI
         
         _oModDet:GoLine(1)
         		
      Else
           		
         u_itmsg(  'O c�digo do vendedor selecionado n�o � v�lido no cadastro do sistema! Verifique os dados informados e tente novamente.' ,'Aten��o!' ,,1 )
         
      EndIf
   Else
      TRBZAE->(DbGoTop())
      _cCODSUP  := TRBZAE->ZAE_CODSUP
      _cCODGER  := TRBZAE->ZAE_CODGER
      _cCODSUI  := TRBZAE->ZAE_CODSUI
      _cCodGNC  := TRBZAE->ZAE_CODGNC

      _cNomSup  := TRBZAE->WK_NSUP
      _cNomGer  := TRBZAE->WK_NGEREN  
      _cNomSui  := TRBZAE->WK_NSUI
      _cNomeGnc := TRBZAE->WK_NGNC

      If SA3->( DBSeek( xFilial('SA3') + TRBZAE->ZAE_VEND ) ) .And. SA3->A3_I_TIPV == 'V'
		 _cCODSUP := SA3->A3_SUPER
         _cCODGER := SA3->A3_GEREN
         _cCODSUI := SA3->A3_I_SUPE 
		 _cCodGNC := SA3->A3_I_GERNC

         _cNomSup := AllTrim( Posicione('SA3',1,xFilial('SA3')+_cCODSUP,'A3_NOME') )
         _cNomGer := AllTrim( Posicione('SA3',1,xFilial('SA3')+_cCODGER,'A3_NOME') )  
         _cNomSui := AllTrim( Posicione('SA3',1,xFilial('SA3')+_cCODSUI,'A3_NOME') )   
         _cNomeGnc := AllTrim( Posicione('SA3',1,xFilial('SA3')+_cCodGNC,'A3_NOME') )

         Do While ! TRBZAE->(Eof())
            If AllTrim(TRBZAE->ZAE_CODSUP) <> AllTrim( _cCODSUP ) .Or. AllTrim(TRBZAE->ZAE_CODGER) <> AllTrim( _cCODGER) .Or. AllTrim(TRBZAE->ZAE_CODSUI) <> AllTrim( _cCODSUI)
               TRBZAE->(RecLock("TRBZAE",.F.))
               
               If AllTrim(TRBZAE->ZAE_CODSUP) <> AllTrim( _cCODSUP )
                  TRBZAE->ZAE_CODSUP := _cCODSUP
                  TRBZAE->WK_NSUP    := _cNomSup
                  TRBZAE->ZAE_COMIS2 := 0   // Comis. Coordenador
				  TRBZAE->ZAE_COMVA2 := 0   // Comis. Varejo Coordenador 
                  _lAtualizou := .T.
               EndIf
               
               If AllTrim(TRBZAE->ZAE_CODGER) <> AllTrim( _cCODGER)
                  TRBZAE->ZAE_CODGER := _cCODGER
                  TRBZAE->WK_NGEREN  := _cNomGer
                  TRBZAE->ZAE_COMIS3 := 0   // Comissao Ger
				  TRBZAE->ZAE_COMVA3 := 0   // Comis. Varejo Gerente 
                  _lAtualizou := .T.
               EndIf
               
               If AllTrim(TRBZAE->ZAE_CODSUI) <> AllTrim( _cCODSUI)
                  TRBZAE->ZAE_CODSUI := _cCODSUI
                  TRBZAE->WK_NSUI    := _cNomSui
                  TRBZAE->ZAE_COMIS4 := 0   // Comissao Supervisor
				  TRBZAE->ZAE_COMVA4 := 0   // Comis. Varejo Supervisor 
                  _lAtualizou := .T.
               EndIf
               
			   If AllTrim(TRBZAE->ZAE_CODGNC) <> AllTrim( _cCodGNC)
                  TRBZAE->ZAE_CODGNC := _cCodGNC
                  TRBZAE->WK_NGNC    := _cNomeGnc
                  TRBZAE->ZAE_COMIS5 := 0   // Comissao Gerente Nacional
				  TRBZAE->ZAE_COMVA5 := 0   // Comis. Varejo Gerente Nacional 
                  _lAtualizou := .T.
               EndIf
               
               TRBZAE->(MsUnlock())
            EndIf
            TRBZAE->(DbSkip())
         EndDo
      Else
         U_ItMsg('O c�digo do vendedor selecionado n�o � v�lido no cadastro do sistema! Verifique os dados informados e tente novamente.' ,'Aten��o!' ,,1 )
      EndIf
      
      TRBZAE->(DbGoTop())
      
   EndIf
   
   If _lAtualizou
      U_ItMsg('Atualiza��o realizada com sucesso.' ,'Aten��o!',,2 )	
   Else
      U_ItMsg('N�o h� dados a serem atualizados.' ,'Aten��o!' ,,1 )	
   EndIf
   
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AFIN004L
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Valida��o da inclus�o de novas linhas na estrutura de regras
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AFIN004L(_oView)

Local _oModel	:= FWModelActive()
Local _oModDet	:= _oModel:GetModel( 'ZAEDETAIL' )

If !Inclui .And. _oModDet:IsInserted()
	
	If Empty( _oModDet:GetValue('ZAE_PROD') )
		_oModDet:LoadValue('ZAE_NPROD',' ')
	EndIf
	
	If Empty( _oModDet:GetValue('ZAE_CODSUP') )
		_oModDet:LoadValue( 'ZAE_CODSUP' , Posicione('SA3',1,xFilial('SA3')+_oModel:GetValue('ZAEMASTER','ZAE_VEND'),'A3_SUPER') )
	EndIf
	
	If !Empty( _oModDet:GetValue('ZAE_CODSUP') )
		_oModDet:LoadValue( 'ZAE_NSUP' , Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODSUP'),'A3_NOME') )
	EndIf
	
	If Empty( _oModDet:GetValue('ZAE_CODSUI') )
		_oModDet:LoadValue( 'ZAE_CODSUI' , Posicione('SA3',1,xFilial('SA3')+_oModel:GetValue('ZAEMASTER','ZAE_VEND'),'A3_I_SUPE') )
	EndIf
	
	If !Empty( _oModDet:GetValue('ZAE_CODSUI') )
		_oModDet:LoadValue( 'ZAE_NSUI' , Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODSUI'),'A3_NOME') )
	EndIf
		
	If Empty( _oModDet:GetValue('ZAE_CODGER') )
		_oModDet:LoadValue( 'ZAE_CODGER' , Posicione('SA3',1,xFilial('SA3')+_oModel:GetValue('ZAEMASTER','ZAE_VEND'),'A3_GEREN') )
	EndIf
	
	If !Empty( _oModDet:GetValue('ZAE_CODGER') )
		_oModDet:LoadValue( 'ZAE_NGEREN' , Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODGER'),'A3_NOME') )
	EndIf

	If Empty( _oModDet:GetValue('ZAE_CODGNC') )
		_oModDet:LoadValue( 'ZAE_CODGNC' , Posicione('SA3',1,xFilial('SA3')+_oModel:GetValue('ZAEMASTER','ZAE_VEND'),'A3_I_GERNC') )
	EndIf
	
	If !Empty( _oModDet:GetValue('ZAE_CODGNC') )
		_oModDet:LoadValue( 'ZAE_NGERNC' , Posicione('SA3',1,xFilial('SA3')+_oModDet:GetValue('ZAE_CODGNC'),'A3_NOME') )
	EndIf
	
	_oView:Refresh()
	_oView:ACURRENTSELECT[1] := 'VIEW_ITN'
	_oView:ACURRENTSELECT[2] := 'ZAE_PROD'
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AFIN004VCG
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2014
===============================================================================================================================
Descri��o---------: Valida��o do c�digo de Supervisor/Coordenador/Gerente
===============================================================================================================================
Parametros--------: Nenhum 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AFIN004VCG( _nOpc , _cCodVen , _cCodAux )

Local _aArea	:= GetArea()
Local _lRet		:= .F.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
//Local _cFornec	:= ''
Local _cSuper	:= ''
Local _cGeren	:= ''
Local _cSui		:= ''
Local _cGerNC   := ''

If Empty( _cCodVen )
	Return( _lRet )
EndIf

_cFornec	:= Posicione('SA3',1,xFilial('SA3')+_cCodVen,'A3_FORNECE')
_cSuper		:= SA3->A3_SUPER
_cGeren		:= SA3->A3_GEREN
_cSui		:= SA3->A3_I_SUPE
_cGerNC     := SA3->A3_I_GERNC

If Empty( _cFornec )
	Return( _lRet )
EndIf

If _nOpc == 1

    IF EMPTY(_cCodAux)
       _cCodAux:="A3_SUPER"
    ENDIF
	DBSelectArea('SA3')
	SA3->( DBSetOrder(1) )
	If _cCodAux = "A3_SUPER" .AND. SA3->( DBSeek( xFilial('SA3') + _cSuper ) )
		_lRet := SA3->A3_FORNECE == _cFornec
	EndIf
	If _cCodAux = "A3_GEREN"  .AND. SA3->( DBSeek( xFilial('SA3') + _cGeren ) )
		_lRet := SA3->A3_FORNECE == _cFornec
	EndIf
	If _cCodAux = "A3_I_SUPE"  .AND. SA3->( DBSeek( xFilial('SA3') + _cSui ) )
		_lRet := SA3->A3_FORNECE == _cFornec
	EndIf
	If _cCodAux = "A3_I_GERNC"  .AND. SA3->( DBSeek( xFilial('SA3') + _cGerNC ) )
		_lRet := SA3->A3_FORNECE == _cFornec
	EndIf
	
	If !_lRet

		_cQuery := " SELECT "
		_cQuery += "     COUNT(1) AS CONTA "
		_cQuery += " FROM "+ RetSqlName('SA3') +" SA3 "
		_cQuery += " WHERE "
		_cQuery += "     SA3.A3_FORNECE = '"+ _cFornec +"' "
		_cQuery += " AND SA3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND EXISTS ( SELECT SAX.A3_COD FROM "+ RetSqlName('SA3') +" SAX WHERE SAX.D_E_L_E_T_ = ' ' AND SAX."+_cCodAux+" = SA3.A3_COD ) "
	
	EndIf
	
ElseIf _nOpc == 2

	DBSelectArea('SA3')
	SA3->( DBSetOrder(1) )
	If SA3->( DBSeek( xFilial('SA3') + _cGeren ) )
		_lRet := SA3->A3_FORNECE == _cFornec
	EndIf
	
	If !_lRet
	
		_cQuery += " SELECT "
		_cQuery += "     COUNT(1) AS CONTA "
		_cQuery += " FROM "+ RetSqlName('SA3') +" SA3 "
		_cQuery += " WHERE "
		_cQuery += "     SA3.A3_FORNECE = '"+ _cFornec +"' "
		_cQuery += " AND SA3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND EXISTS ( SELECT SAZ.A3_COD FROM "+ RetSqlName('SA3') +" SAZ WHERE SAZ.D_E_L_E_T_ = ' ' AND SAZ.A3_GEREN = SA3.A3_COD ) "
	
	EndIf

ElseIf _nOpc == 3

	DBSelectArea('SA3')
	SA3->( DBSetOrder(1) )
	If SA3->( DBSeek( xFilial('SA3') + _cSui ) )
		_lRet := SA3->A3_FORNECE == _cFornec
	EndIf
	
	If !_lRet
	
		_cQuery += " SELECT "
		_cQuery += "     COUNT(1) AS CONTA "
		_cQuery += " FROM "+ RetSqlName('SA3') +" SA3 "
		_cQuery += " WHERE "
		_cQuery += "     SA3.A3_FORNECE = '"+ _cFornec +"' "
		_cQuery += " AND SA3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND EXISTS ( SELECT SAZ.A3_COD FROM "+ RetSqlName('SA3') +" SAZ WHERE SAZ.D_E_L_E_T_ = ' ' AND SAZ.A3_I_SUPE = SA3.A3_COD ) "
	
	EndIf

ElseIf _nOpc == 4

	DBSelectArea('SA3')
	SA3->( DBSetOrder(1) )
	If SA3->( DBSeek( xFilial('SA3') + _cGerNC ) )
		_lRet := SA3->A3_FORNECE == _cFornec
	EndIf
	
	If !_lRet
	
		_cQuery += " SELECT "
		_cQuery += "     COUNT(1) AS CONTA "
		_cQuery += " FROM "+ RetSqlName('SA3') +" SA3 "
		_cQuery += " WHERE "
		_cQuery += "     SA3.A3_FORNECE = '"+ _cFornec +"' "
		_cQuery += " AND SA3.D_E_L_E_T_ = ' ' "
		_cQuery += " AND EXISTS ( SELECT SAZ.A3_COD FROM "+ RetSqlName('SA3') +" SAZ WHERE SAZ.D_E_L_E_T_ = ' ' AND SAZ.A3_I_GERNC = SA3.A3_COD ) "
	
	EndIf

ElseIf _nOpc == 5 
	
	If !Empty( _cCodAux )
		
		DBSelectArea('SA3')
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFilial('SA3') + _cCodAux ) )
			_lRet := ( SA3->A3_FORNECE == _cFornec )
		EndIf
		
	EndIf

EndIf

If _nOpc < 5 .And. !_lRet 

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	_lRet := (_cAlias)->( !Eof() ) .And. (_cAlias)->CONTA > 0
	
	(_cAlias)->( DBCloseArea() )

EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004V
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Valida os Campos que ser�o exibidos no Browse
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o c�digo foi validado ou seje j� existe
===============================================================================================================================
*/

User Function AFIN004V()

Local _lRet		:= .T.
Local _oModel	:= FWModelActive()
Local _cCodVen	:= _oModel:GetValue( 'ZAEMASTER' , 'ZAE_VEND' )
Local _cAlias	:= GetNextAlias()

_cVenCRC := _cCodVen

If Empty( _cCodVen )

	_aInfHlp := {}
	aAdd( _aInfHlp , { "� obrigat�rio informar um c�digo de " ,"Vendedor para o cadastro das regras de comiss�o!"} )
	aAdd( _aInfHlp , { "Verifique o c�digo informado e tente ","novamente."								         } )
	
    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) 
	//U_ITCADHLP( _aInfHlp , "AFIN00401" )
	
	_lRet := .F.
	
EndIf

If _lRet

	DBSelectArea("ZAE")
	ZAE->( DBSetOrder(1) ) //ZAE_FILIAL+ZAE_VEND+ZAE_PROD+ZAE_CLI+ZAE_LOJA
	IF ZAE->( DBSeek( xFILIAL("ZAE") + ALLTRIM( _cCodVen ) ) )
	
		_aInfHlp := {}
		aAdd( _aInfHlp , { "O Vendedor informado j� possui cadastro ","de regras de comiss�o!"} )
		aAdd( _aInfHlp , { "Caso necess�rio, efetue a manuten��o no ","cadastro existente."	 } )
		
	    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) 
		//U_ITCADHLP( _aInfHlp , "AFIN00402" )
		
		_lRet := .F.
	
	Else
		
		DBSelectArea("SA3")
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFILIAL("SA3") + ALLTRIM( _cCodVen ) ) )
			
			If SA3->A3_MSBLQL == '1'
			
				_aInfHlp := {}
				aAdd( _aInfHlp , { "O cadastro do Vendedor informado est� ","bloqueado no Sistema!"} )
				aAdd( _aInfHlp , { "Verifique o c�digo informado e tente " ,"novamente."		   } )
				
	            U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) 
				//U_ITCADHLP( _aInfHlp , "AFIN00403" )
				
				_lRet := .F.
			
			ElseIf SA3->A3_I_TIPV <> 'V'
			
				_aInfHlp := {}
				aAdd( _aInfHlp , { "O cadastro do Vendedor informado n�o foi ","classificado como 'Vendedor'!"} )
				aAdd( _aInfHlp , { "Verifique o c�digo informado e tente "	  ,"novamente."					  } )
				
	            U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) 
				//U_ITCADHLP( _aInfHlp , "AFIN00410" )
				
				_lRet := .F.

	        ELSEIF EMPTY(SA3->A3_FORNECE)
	        
			    U_ITMSG("Favor verificar o codigo do fornecedor amarrado a este vendedor",'Aten��o!',"Preencha o codigo do fornecedor amarrado a este vendedor",1, , ,.T.) 
			    _lRet := .F.
			
			EndIf                 
			
		Else
		
			_aInfHlp := {}
			aAdd( _aInfHlp , { "N�o foi encontrado o vendedor com o " ,"c�digo informado!"} )
			aAdd( _aInfHlp , { "Verifique o c�digo informado e tente ","novamente."		  } )
			
            U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1, , ,.T.) 
			//U_ITCADHLP( _aInfHlp , "AFIN00404" )
			
			_lRet := .F.
		
		EndIf
	
	EndIf

EndIf

If _lret

	_cQuery := " SELECT "
	_cQuery += "     SA3.A3_SUPER AS CODSUP , "
	_cQuery += "     SA3.A3_GEREN AS CODGER ,  "
	_cQuery += "     SA3.A3_I_SUPE AS CODSUI   "
	_cQuery += " FROM "+ RetSqlName('SA3') +" SA3 "
	_cQuery += " WHERE "
	_cQuery += "     SA3.D_E_L_E_T_ = ' ' "
	_cQuery += " AND SA3.A3_COD     = '"+ ALLTRIM( _cCodVen ) +"' "
	_cQuery += " AND SA3.A3_I_TIPV  = 'V' "

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf

	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->( !Eof() )
	
		If Empty( (_cAlias)->CODSUP )
		
			_lret := .F.
			Help(NIL, NIL, "Aten��o", NIL, 'O cadastro do vendedor no sistema est� incompleto pois n�o possui um coordenador amarrado � ele!',;
			 				1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do vendedor para corrigir os dados antes de incluir regras de comiss�o.'})
		
		Else
	
			DBSelectArea('SA3')
			SA3->( DBSetOrder(1) )
			If SA3->( DBSeek( xFilial('SA3') + (_cAlias)->CODSUP ) )
			
				If SA3->A3_I_TIPV <> 'C'
				
					_lret := .F.
					Help(NIL, NIL, "Aten��o", NIL, 'O cadastro do vendedor no sistema � inv�lido pois o coordenador amarrado a ele n�o est� classificado como coordenador!',;
			 				1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do vendedor e a amarra��o "vendedor x coordenador" antes de incluir regras de comiss�o.'})
					
				EndIf
			
			Else
			
				_lret := .F.
				Help(NIL, NIL, "Aten��o", NIL, 'O cadastro do vendedor no sistema � inv�lido pois o coordenador amarrado a ele n�o foi encontrado no cadastro de vendedores!',;
			 				1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do vendedor e a amarra��o "vendedor x coordenador" antes de incluir regras de comiss�o.'})
				
			EndIf
		
		EndIf
	
		If !Empty( (_cAlias)->CODSUI )
			
			DBSelectArea('SA3')
			SA3->( DBSetOrder(1) )
			If SA3->( DBSeek( xFilial('SA3') + (_cAlias)->CODSUI ) )
			
				If SA3->A3_I_TIPV <> 'S'
				
					_lret := .F.
					Help(NIL, NIL, "Aten��o", NIL, 'O cadastro do vendedor no sistema � inv�lido pois o supervisor amarrado a ele n�o est� classificado como supervisor!',;
			 				1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do vendedor e a amarra��o "vendedor x supervisor" antes de incluir regras de comiss�o.'})
									
				EndIf
			
			Else
			
				_lret := .F.
				Help(NIL, NIL, "Aten��o", NIL, 'O cadastro do vendedor no sistema � inv�lido pois o supervisor amarrado a ele n�o foi encontrado no cadastro de vendedores!',;
			 				1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do vendedor e a amarra��o "vendedor x supervisor" antes de incluir regras de comiss�o.'})
							
			EndIf
		
		EndIf
	
	
		If !Empty( (_cAlias)->CODGER )
		
			DBSelectArea('SA3')
			SA3->( DBSetOrder(1) )
			If SA3->( DBSeek( xFilial('SA3') + (_cAlias)->CODGER ) )
			
				If SA3->A3_I_TIPV <> 'G'
				
					_lret := .F.
					Help(NIL, NIL, "Aten��o", NIL, 'O cadastro do vendedor no sistema � inv�lido pois o gerente amarrado a ele n�o est� classificado como gerente!',;
			 				1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do vendedor e a amarra��o "vendedor x gerente" antes de incluir regras de comiss�o.'})
				
				EndIf
			
			Else
			
				_lret := .F.
				Help(NIL, NIL, "Aten��o", NIL, 'O cadastro do vendedor no sistema � inv�lido pois o gerente amarrado a ele n�o foi encontrado no cadastro de vendedores!',;
			 				1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique o cadastro do vendedor e a amarra��o "vendedor x gerente" antes de incluir regras de comiss�o.'})
							
			EndIF
		
		EndIf
	
	Endif

Endif

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AFIN004B
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Valida��o e libera��o dos cadastros de Regras
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o c�digo foi validado ou seje j� existe
===============================================================================================================================
*/

User Function AFIN004B()

Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _cAlias2	:= GetNextAlias()
Local _lOk		:= .T.
Local _lSqlOk	:= .F.

_cQuery := " SELECT "
_cQuery += "     SA3.A3_SUPER AS CODSUP , "
_cQuery += "     SA3.A3_GEREN AS CODGER ,  "
_cQuery += "     SA3.A3_I_SUPE AS CODSUI   "
_cQuery += " FROM "+ RetSqlName('SA3') +" SA3 "
_cQuery += " WHERE "
_cQuery += "     SA3.D_E_L_E_T_ = ' ' "
_cQuery += " AND SA3.A3_COD     = '"+ ZAE->ZAE_VEND +"' "
_cQuery += " AND SA3.A3_I_TIPV  = 'V' "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() )
	
	If Empty( (_cAlias)->CODSUP )
		
		_lOk := .F.
		u_itmsg(	'O cadastro do vendedor no sistema est� incompleto pois n�o possui um coordenador amarrado � ele!' +CRLF+;
					'Verifique o cadastro do vendedor para corrigir os dados antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1)
		
	Else
	
		DBSelectArea('SA3')
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFilial('SA3') + (_cAlias)->CODSUP ) )
			
			If SA3->A3_I_TIPV <> 'C'
				
				_lOk := .F.
				u_itmsg(	'O cadastro do vendedor no sistema � inv�lido pois o coordenador amarrado a ele n�o est� classificado como coordenador!' +CRLF+;
							'Verifique o cadastro do vendedor e a amarra��o "vendedor x coordenador" antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1 )
				
			EndIf
			
		Else
			
			_lOk := .F.
			u_itmsg(	'O cadastro do vendedor no sistema � inv�lido pois o coordenador amarrado a ele n�o foi encontrado no cadastro de vendedores!' +CRLF+;
						'Verifique o cadastro do vendedor e a amarra��o "vendedor x coordenador" antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1 )
			
		EndIf
		
	EndIf
	
	If !Empty( (_cAlias)->CODSUI )
			
		DBSelectArea('SA3')
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFilial('SA3') + (_cAlias)->CODSUI ) )
			
			If SA3->A3_I_TIPV <> 'S'
				
				_lOk := .F.
				u_itmsg(	'O cadastro do vendedor no sistema � inv�lido pois o supervisor amarrado a ele n�o est� classificado como supervisor!' +CRLF+;
							'Verifique o cadastro do vendedor e a amarra��o "vendedor x supervisor" antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1 )
				
			EndIf
			
		Else
			
			_lOk := .F.
			u_itmsg(	'O cadastro do vendedor no sistema � inv�lido pois o supervisor amarrado a ele n�o foi encontrado no cadastro de vendedores!' +CRLF+;
						'Verifique o cadastro do vendedor e a amarra��o "vendedor x supervisor" antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1 )
			
		EndIf
		
	EndIf
	
	
	If !Empty( (_cAlias)->CODGER )
		
		DBSelectArea('SA3')
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFilial('SA3') + (_cAlias)->CODGER ) )
			
			If SA3->A3_I_TIPV <> 'G'
				
				_lOk := .F.
				u_itmsg(	'O cadastro do vendedor no sistema � inv�lido pois o gerente amarrado a ele n�o est� classificado como gerente!' +CRLF+;
							'Verifique o cadastro do vendedor e a amarra��o "vendedor x gerente" antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1 )
				
			EndIf
			
		Else
			
			_lOk := .F.
			u_itmsg(	'O cadastro do vendedor no sistema � inv�lido pois o gerente amarrado a ele n�o foi encontrado no cadastro de vendedores!' +CRLF+;
						'Verifique o cadastro do vendedor e a amarra��o "vendedor x gerente" antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1 )
			
		EndIF
		
	EndIf
	
	If _lOk
	
		_cQuery := " SELECT DISTINCT "
		_cQuery += "     ZAE.ZAE_CODSUP AS CODSUP , "
		_cQuery += "     ZAE.ZAE_CODGER AS CODGER,   "
		_cQuery += "     ZAE.ZAE_CODSUI AS CODSUI   "
		_cQuery += " FROM "+ RetSqlName('ZAE') +" ZAE "
		_cQuery += " WHERE "
		_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAE.ZAE_VEND   = '"+ ZAE->ZAE_VEND +"' "
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias2 , .T. , .F. )
		
		DBSelectArea(_cAlias2)
		(_cAlias2)->( DBGoTop() )
		While (_cAlias2)->( !Eof() )
			
			If ( (_cAlias)->CODSUP <> (_cAlias2)->CODSUP ) .Or. ( (_cAlias)->CODGER <> (_cAlias2)->CODGER ) .Or. ( (_cAlias)->CODSUI <> (_cAlias2)->CODSUI )
			
				_lOk := .F.
				u_itmsg(	'Para desbloquear o cadastro de Regras o mesmo deve estar alinhado ao cadastro do vendedor no sistema com rela��o � Supervis�o, Coordena��o e Ger�ncia!' +CRLF+;
							'Verifique o cadastro de vendedores e o cadastro das regras para corrigir os dados antes de solicitar o desbloqueio.' , 'Aten��o!' , ,1 )
				Exit
				
			EndIf
			
		(_cAlias2)->( DBSkip() )
		EndDo
		
		(_cAlias2)->( DBCloseArea() )
	
	EndIf
	
	If _lOk
	    
		_cQuery := " UPDATE "+ RetSqlName('ZAE') +" ZAE "
		_cQuery += " SET ZAE.ZAE_MSBLQL = '2' "
		_cQuery += " WHERE "
		_cQuery += "     ZAE.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAE.ZAE_VEND   = '"+ ZAE->ZAE_VEND +"' "
		
		_lSqlOk := !( TCSqlExec(_cQuery) < 0 )
		
		If _lSqlOk
		
			u_itmsg(   'O cadastro das regras de comiss�o atual foi desbloqueado com sucesso! '	 ,	'Aten��o!' ,;
							'Verifique os percentuais e os dados das regras que j� est�o dispon�veis para utiliza��o.' , 1 )
			
		Else
		
			u_itmsg(	 'Falha ao atualizar o cadastro das regras de comiss�o do vendedor selecionado!','Aten��o!' ,;
							 'Verifique o cadastro das regras atual e tente novamente. ' ,		1 )
			
		EndIf		
	
	EndIf

Else
	
	u_itmsg(	'O vendedor do cadastro de regras selecionado n�o foi encontrado no cadastro de vendedores do sistema ou o cadastro n�o � v�lido!' +CRLF+;
				'Verifique o cadastro de vendedores e o cadastro das regras para corrigir os dados que dever�o estar alinhados para o desbloqueio.' , 'Aten��o!' ,,1 )
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AFIN004M
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Gerenciamento dos Pontos de Entrada do MVC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o c�digo foi validado ou seje j� existe
===============================================================================================================================
*/

User Function AFIN004M()

Local _xRet		:= .T.
Local _aInfHlp	:= {}
Local _aParam	:= PARAMIXB
Local _oModel	:= Nil
Local _oView	:= Nil
Local _cQuery	:= ''
Local _cFornec	:= ''
Local _cForSup	:= ''
Local _cForSui	:= ''
Local _cForGer	:= ''
Local _cAlias	:= GetNextAlias()
Local _nLinhas	:= 0
Local _nI		:= 0
Local _lForSup	:= .F.
Local _lForGer	:= .F.
Local _lForSui	:= .F.

If _aParam[02] == "MODELPOS"
	
	_oModel	:= FWModelActive()
	_oView	:= FWViewActive()
	
	If _oModel:GetOperation() <> 1 .And. _oModel:GetOperation() <> MODEL_OPERATION_DELETE

		DBSelectArea('SA3')
		SA3->( DBSetOrder(1) )
		If SA3->( DBSeek( xFilial('SA3') + _oModel:GetValue('ZAEMASTER','ZAE_VEND') ) ) .And. SA3->A3_I_TIPV == 'V' .And. SA3->A3_MSBLQL <> '1'
			
			If Empty( SA3->A3_SUPER )
				
				_xRet    := .F.
				_aInfHlp := {}
				aAdd( _aInfHlp , { "O cadastro do Vendedor est� incompleto ","no Cadastro de Vendedores do sistema!"	} )
				aAdd( _aInfHlp , { "Todo vendedor deve estar amarrado � um ","Coordenador de Vendas."					} )
				
                U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
				//U_ITCADHLP( _aInfHlp , "CRCTOK001" )
				
			Else
			
				_cQuery := " SELECT SA3.A3_I_TIPV, SA3.A3_FORNECE FROM "+ RetSqlName('SA3') +" SA3 WHERE SA3.D_E_L_E_T_ = ' ' AND SA3.A3_COD = '"+ SA3->A3_SUPER +"' "
				
				If Select(_cAlias) > 0
					(_cAlias)->( DBCloseArea() )
				EndIf
				
				DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
				
				DBSelectArea(_cAlias)
				(_cAlias)->( DBGoTop() )
				If (_cAlias)->( !Eof() )
					
					If (_cAlias)->A3_I_TIPV <> 'C'
						
						_xRet    := .F.
						_aInfHlp := {}
						aAdd( _aInfHlp , { "Existe um erro no cadastro do Vendedor "	, "no Cadastro de Vendedores do sistema!"						} )
						aAdd( _aInfHlp , { "O coordenador informado no cadastro do "	, "Vendedor n�o est� classificado como Coordenador."	} )
						
                        U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
						//U_ITCADHLP( _aInfHlp , "CRCTOK002" )
						
					EndIf
					
				Else
					
					_xRet    := .F.
					_aInfHlp := {}
					aAdd( _aInfHlp , { "Existe um erro no cadastro do Vendedor "	, "no Cadastro de Vendedores do sistema!"	} )
					aAdd( _aInfHlp , { "O coordenador informado no cadastro do "	, "Vendedor n�o � v�lido. "					} )
					
                    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
					//U_ITCADHLP( _aInfHlp , "CRCTOK003" )
					
				EndIf
				
				(_cAlias)->( DBCloseArea() )
				
			EndIf
			
			If !Empty( SA3->A3_I_SUPE )
							
				_cQuery := " SELECT SA3.A3_I_TIPV, SA3.A3_FORNECE FROM "+ RetSqlName('SA3') +" SA3 WHERE SA3.D_E_L_E_T_ = ' ' AND SA3.A3_COD = '"+ SA3->A3_I_SUPE +"' "
				
				If Select(_cAlias) > 0
					(_cAlias)->( DBCloseArea() )
				EndIf
				
				DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
				
				DBSelectArea(_cAlias)
				(_cAlias)->( DBGoTop() )
				If (_cAlias)->( !Eof() )
					
					If (_cAlias)->A3_I_TIPV <> 'S'
						
						_xRet    := .F.
						_aInfHlp := {}
						aAdd( _aInfHlp , { "Existe um erro no cadastro do Vendedor ", "no Cadastro de Vendedores do sistema!"			} )
						aAdd( _aInfHlp , { "O supervisor informado no cadastro do "	, "Vendedor n�o est� classificado como supervisor."	} )
						
                        U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
						//U_ITCADHLP( _aInfHlp , "CRCTOK002" )
						
					EndIf
					
				Else
					
					_xRet    := .F.
					_aInfHlp := {}
					aAdd( _aInfHlp , { "Existe um erro no cadastro do Vendedor ", "no Cadastro de Vendedores do sistema!"	} )
					aAdd( _aInfHlp , { "O supervisor informado no cadastro do "	, "Vendedor n�o � v�lido. "					} )
					
                    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
					//U_ITCADHLP( _aInfHlp , "CRCTOK003" )
					
				EndIf
				
				(_cAlias)->( DBCloseArea() )
				
			EndIf
			
			
			If !Empty( SA3->A3_GEREN )
				
				_cQuery := " SELECT SA3.A3_I_TIPV FROM "+ RetSqlName('SA3') +" SA3 WHERE SA3.D_E_L_E_T_ = ' ' AND SA3.A3_COD = '"+ SA3->A3_GEREN +"' "
				
				If Select(_cAlias) > 0
					(_cAlias)->( DBCloseArea() )
				EndIf
				
				DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
				
				DBSelectArea(_cAlias)
				(_cAlias)->( DBGoTop() )
				If (_cAlias)->( !Eof() )
					
					If (_cAlias)->A3_I_TIPV <> 'G'
						
						_xRet    := .F.
						_aInfHlp := {}
						aAdd( _aInfHlp , { "Existe um erro no cadastro do Vendedor "	, "no Cadastro de Vendedores do sistema!"					} )
						aAdd( _aInfHlp , { "O Gerente informado no cadastro do "		, "Vendedor n�o est� classificado como Gerente."	} )
						
                        U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
						//U_ITCADHLP( _aInfHlp , "CRCTOK004" )
						
					EndIf
					
				Else
					
					_xRet    := .F.
					_aInfHlp := {}
					aAdd( _aInfHlp , { "Existe um erro no cadastro do Vendedor "	, "no Cadastro de Vendedores do sistema!"	} )
					aAdd( _aInfHlp , { "O Gerente informado no cadastro do "		, "Vendedor n�o � v�lido. "					} )
					
                    U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
					//U_ITCADHLP( _aInfHlp , "CRCTOK005" )
					
				EndIF
				
				(_cAlias)->( DBCloseArea() )
				
			EndIf	
			
			If _xRet
			
				_nLinhas := _oModel:GetModel('ZAEDETAIL'):Length()
				
				For _nI := 1 To _nLinhas
					
					_oModel:GetModel('ZAEDETAIL'):GoLine( _nI )
					
					If ( _oModel:GetValue('ZAEDETAIL','ZAE_CODSUP') <> SA3->A3_SUPER ) .Or. ( _oModel:GetValue('ZAEDETAIL','ZAE_CODGER') <> SA3->A3_GEREN );
					 																			.Or. ( _oModel:GetValue('ZAEDETAIL','ZAE_CODSUI') <> SA3->A3_I_SUPE )
					
						_xRet    := .F.
						_aInfHlp := {}
						aAdd( _aInfHlp , { "O cadastro do Vendedor est� divergente "	, "das Regras de Comiss�o!"					} )
						aAdd( _aInfHlp , { "A amarra��o de Supervisor/Coordenador/ "     ,"Gerente deve ser igual nos cadastros."		} )
						
                        U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
						//U_ITCADHLP( _aInfHlp , "CRCTOK006" )
						Exit
						
					EndIf
					
				Next _nI
				
				_oModel:GetModel('ZAEDETAIL'):GoLine( 01 )
				
			EndIf
			
		Else
			
			_xRet    := .F.
			_aInfHlp := {}
			aAdd( _aInfHlp , { "O Vendedor informado no cadastro das ", "Regras de Comiss�o n�o � v�lido ou est� bloqueado!"				} )
			aAdd( _aInfHlp , { "Verifique os dados informados e/ou o ", "cadastro do Vendedor que n�o pode estar bloqueado para utiliza��o."} )
			
            U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2],1) 
			//U_ITCADHLP( _aInfHlp , "CRCTOK007" )
			
		EndIf
		
		If _xRet
			
			_cFornec := Posicione('SA3',1,xfilial('SA3')+_oModel:GetValue('ZAEMASTER','ZAE_VEND')	,'A3_FORNECE')
			
			For _nI := 1 To _oModel:GetModel('ZAEDETAIL'):Length()
				
				_oModel:GetModel('ZAEDETAIL'):GoLine(_nI)
				
				_cForSup := Posicione('SA3',1,xfilial('SA3')+_oModel:GetValue('ZAEDETAIL','ZAE_CODSUP')	,'A3_FORNECE')
				_cForGer := Posicione('SA3',1,xfilial('SA3')+_oModel:GetValue('ZAEDETAIL','ZAE_CODGER')	,'A3_FORNECE')
				_cForSui := Posicione('SA3',1,xfilial('SA3')+_oModel:GetValue('ZAEDETAIL','ZAE_CODSUI')	,'A3_FORNECE')
				
				If _cForSup == _cFornec .And. _oModel:GetValue('ZAEDETAIL','ZAE_COMIS2') > 0
					_lForSup := .T.
					_oModel:LoadValue('ZAEDETAIL','ZAE_COMIS2',0)
				EndIf
				
				If _cForGer == _cFornec .And. _oModel:GetValue('ZAEDETAIL','ZAE_COMIS3') > 0
					_lForGer := .T.
					_oModel:LoadValue('ZAEDETAIL','ZAE_COMIS3',0)
				EndIf
				
				If _cForSui == _cFornec .And. _oModel:GetValue('ZAEDETAIL','ZAE_COMIS4') > 0
					_lForSui := .T.
					_oModel:LoadValue('ZAEDETAIL','ZAE_COMIS4',0)
				EndIf
					
			Next _nI
			
			_oModel:GetModel('ZAEDETAIL'):GoLine(01)
			
			If _lForSup .Or. _lForGer .or. _lForSui
			
				_xRet    := .F.
				_aInfHlp := {}
				//					|....:....|....:....|....:....|....:....|
				aAdd( _aInfHlp , {	'Foi definido um valor de comiss�o para '	,;
									'superv, coord ou gerente, por�m est�o '	,;
									'configurados com o mesmo fornecedor do '	,;
									'vendedor no cadastro do Sistema(SA3)!'		})
				//					|....:....|....:....|....:....|....:....|
				aAdd( _aInfHlp , {	'Para esses casos o % de comiss�o do '		,;
									'superv, coord ou gerente ser� zerado '		,;
									'pois n�o � permitido cadastrar comiss�o '	,;
									'se o fornecedor for o mesmo que o do'		,;
									'vendedor configurado.'						})
				
                U_ITMSG(_aInfHlp[1,1]+_aInfHlp[1,2]+_aInfHlp[1,3]+_aInfHlp[1,4],'Aten��o!',_aInfHlp[2,1]+_aInfHlp[2,2]+_aInfHlp[2,3]+_aInfHlp[2,4]+_aInfHlp[2,5],1) 
				//U_ITCADHLP( _aInfHlp , "CRCTOK008" )
				
				_oView:Refresh()
				
			EndIf
			
		EndIf
	
	EndIf
		
EndIf

Return( _xRet )

/*
===============================================================================================================================
Programa----------: AFIN004F
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Valida��o e Inicializador padr�o para o campo ZAE_NCLI
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o c�digo foi validado ou seje j� existe
===============================================================================================================================
*/

User Function AFIN004F( _cCodGrp , _cCodCli , _cLojCli )

Local _cRet	:= ''

Default _cCodGrp	:= ''
Default _cCodCli	:= ''
Default _cLojCli	:= ''

If !Empty( _cCodGrp ) .And. Empty( _cCodCli )

	_cRet := Posicione( 'ACY' , 1 , xFilial('ACY') + _cCodGrp , 'ACY_DESCRI' )
	
EndIf

If Empty( _cCodGrp ) .And. !Empty( _cCodCli )

	_cRet := Posicione( 'SA1' , 1 , xFilial('SA1') + _cCodCli + AllTrim( _cLojCli ) , 'A1_NOME' )
	
EndIf

Return( _cRet )

/*
===============================================================================================================================
Programa----------: AFIN004TPT
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Monta matriz com produtos tipo PA
===============================================================================================================================
Parametros--------: _lCheck - determina se roda fun��o
					 aItens - matriz a ser populada
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function AFIN004TPT( _lCheck , aItens )

Local _cQuery := ''
Local _cAlias := GetNextAlias()

aItens := {}

If _lCheck

	_cQuery := " SELECT SB1.B1_COD "
	_cQuery += " FROM  "+ RetSqlName('SB1') +" SB1 "
	_cQuery += " WHERE "+ RetSqlCond('SB1')
	_cQuery += " AND SB1.B1_TIPO = 'PA' "
	//_cQuery += " AND SB1.B1_MSBLQL <> '1' "
	_cQuery += " ORDER BY SB1.B1_COD "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	While (_cAlias)->( !Eof() )
		
		aAdd( aItens , { (_cAlias)->B1_COD } )
		
	(_cAlias)->( DBSkip() )
	EndDo
	
	(_cAlias)->( DBCloseArea() )

EndIf

Return()

/*
===============================================================================================================================
Programa----------: AFIN004Z
Autor-------------: Alexandre Villar
Data da Criacao---: 09/02/2015
===============================================================================================================================
Descri��o---------: Valida e corrige comiss�es
===============================================================================================================================
Parametros--------: _cCodVen - vendedor que ter� comiss�es validadas
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/

User Function AFIN004Z( _cCodVen )

Local _aArea	:= GetArea()
Local _oModel	:= FWModelActive()
Local _oModDet	:= _oModel:GetModel('ZAEDETAIL')
Local _cForSup	:= ''
Local _cForGer	:= ''
Local _cForSui	:= ''
Local _cFornec	:= Posicione( 'SA3' , 1 , xFilial('SA3') + _oModel:GetValue('ZAEMASTER','ZAE_VEND') , 'A3_FORNECE' )
Local _nLinhas	:= _oModDet:Length()
Local _nI		:= 0
Local _lForSup	:= .F.
Local _lForGer	:= .F.
Local _lForSui	:= .F.
Local _cMsgAux	:= ''

For _nI := 1 To _nLinhas
	
	_oModDet:GoLine( _nI )
	_cForSup := Posicione( 'SA3' , 1 , xFilial('SA3') + _oModDet:GetValue('ZAE_CODSUP') , 'A3_FORNECE' )
	_cForGer := Posicione( 'SA3' , 1 , xFilial('SA3') + _oModDet:GetValue('ZAE_CODGER') , 'A3_FORNECE' )
	_cForSui := Posicione( 'SA3' , 1 , xFilial('SA3') + _oModDet:GetValue('ZAE_CODSUI') , 'A3_FORNECE' )
	
	If _cFornec == _cForSup
		_oModDet:LoadValue( 'ZAE_COMIS2' , 0 )
		_lForSup := .T.
	EndIf
	
	If _cFornec == _cForGer
		_oModDet:LoadValue( 'ZAE_COMIS3' , 0 )
		_lForGer := .T.
	EndIf
	
	If _cFornec == _cForSui
		_oModDet:LoadValue( 'ZAE_COMIS4' , 0 )
		_lForSui := .T.
	EndIf

Next _nI

_oModDet:GoLine(01)

If _lForSup .Or. _lForGer .Or. _lForSui

	_cMsgAux := ' <html> '
	_cMsgAux +=	' <body> '
	_cMsgAux := ' <p> Foram encontrados % de comiss�o configurados para o '
	_cMsgAux += IIf( _lForSui					, 'supervisor, '		, '' )
	_cMsgAux += IIf( _lForSup					, 'coordenador, '	, '' )
	_cMsgAux += IIf( _lForGer					, 'gerente, '		, '' )
	_cMsgAux += ' <br> onde o fornecedor amarrado � igual ao configurado no vendedor informado! </p> '
	_cMsgAux += ' <hr> '
	_cMsgAux += ' <p> Para esses casos o % foi zerado pois n�o � permitido informar % de comiss�o '
	_cMsgAux += ' <br> para superv, coord ou gerente que tenham o mesmo fornecedor do vendedor. <br>'
	_cMsgAux += ' <br><b> � recomend�vel revisar o cadastro atual e os % aplicados nas regras. </b></p>'
	_cMsgAux += ' </body> '
	_cMsgAux += ' </html> '
	
	u_itmsg( _cMsgAux , 'Aten��o' , ,1 )

EndIf

RestArea(_aArea)

Return( .T. )

/*
===============================================================================================================================
Programa----------: AFIN004D
Autor-------------: Josu� Prestes
Data da Criacao---: 16/07/2015
===============================================================================================================================
Descri��o---------: Exporta lista de regras de comiss�o para excel
===============================================================================================================================
Parametros--------: _nopc - 0 exporta para excel
							1 exporta para csv
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AFIN004D(_nopc,oproc)

FWMSGRUN(,{|oproc|  AFIN004D(_nopc,oproc) },'Aguarde processamento...','Lendo dados...')

RETURN .T.

STATIC Function AFIN004D(_nopc,oproc)

Local _aVends	:= {}
Local _cQuery	:= '' , _nCpo
Local _cAlias	:= GetNextAlias()
Local _aCabec   := {}            

Default _nopc := 0 
Private cperg := "AFIN004D"

if !Pergunte(cPerg,.t.)
  return
endif

oproc:cCaption := ("Lendo dados selecionados...")
ProcessMessages()

//carrega tudo que ser� exportado de acordo com o filtro
_cQuery := "SELECT"
_cQuery += " ZAE_VEND,ZAE_ITEM,ZAE_PROD,ZAE_COMIS1,ZAE_GRPVEN,ZAE_CLI,ZAE_LOJA,"                                                  
_cQuery += " ZAE_CODSUP,ZAE_COMIS2,ZAE_CODGER,ZAE_COMIS3,ZAE_CODSUI,ZAE_COMIS4, "
_cQuery += " ZAE_CODGNC,ZAE_COMIS5, ZAE_COMVA1,ZAE_COMVA2,ZAE_COMVA3,ZAE_COMVA4,ZAE_COMVA5 "
_cQuery += "FROM "                              
_cQuery += RetSqlName("ZAE") + " "         
_cQuery += "WHERE"               
_cQuery += " D_E_L_E_T_ = ' ' "
_cQuery += " AND ZAE_FILIAL = '" + xfilial("ZAE") + "'" 
	
If !Empty(MV_PAR01)
  _cQuery += " AND ZAE_CODSUP IN " + FormatIn(mv_par01,";")
EndIF

If !Empty(MV_PAR02)
  _cQuery += " AND ZAE_VEND IN " + FormatIn(mv_par02,";")
EndIF
		
_cQuery += " ORDER BY ZAE_VEND,ZAE_PROD,ZAE_CLI,ZAE_LOJA"  
	
	
DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
DBSelectArea(_cAlias)
COUNT TO _ntot

_npos:=0
(_cAlias)->( DBGoTop() ) 
	
//monta matriz de acols e header para fun��o de exporta��o
While (_cAlias)->( !Eof() )

   oproc:cCaption := ("Lendo Regras " + STRZERO(_npos,9) + " de " + STRZERO(_ntot,9))
   ProcessMessages()
   _npos++

  aAdd( _aVends ,{(_cAlias)->ZAE_ITEM,;
	              (_cAlias)->ZAE_VEND,;
                  Posicione("SA3",1,xFilial("SA3") + (_cAlias)->ZAE_VEND,"A3_NOME"),;
                  (_cAlias)->ZAE_PROD,;
                  Posicione("SB1",1,xFilial("SB1") + (_cAlias)->ZAE_PROD,"SB1->B1_I_DESCD"),;
	              (_CALIAS)->ZAE_COMIS1,;
				  (_CALIAS)->ZAE_COMVA1,;
                  (_cAlias)->ZAE_GRPVEN,;
                  SubStr(Posicione("ACY",1,xFilial("ACY") + (_cAlias)->ZAE_GRPVEN,"ACY->ACY_DESCRI"),1,19),;
               	  (_cAlias)->ZAE_CLI,;
	              (_cAlias)->ZAE_LOJA,;
	              SubStr(AllTrim(Posicione("SA1",1,xFilial("SA1") + (_cAlias)->ZAE_CLI+(_cAlias)->ZAE_LOJA,"A1_NOME")),1,30),;
	              AllTrim(SubStr(Posicione("SA3",1,xFilial("SA3") + (_cAlias)->ZAE_CODSUP,"A3_NOME"),1,13)),;
	              (_CALIAS)->ZAE_COMIS2,;
				  (_CALIAS)->ZAE_COMVA2,;
	              AllTrim(SubStr(Posicione("SA3",1,xFilial("SA3") + (_cAlias)->ZAE_CODGER,"A3_NOME"),1,13)),;
	              (_cAlias)->ZAE_COMIS3,;
				  (_cAlias)->ZAE_COMVA3,;
	              AllTrim(SubStr(Posicione("SA3",1,xFilial("SA3") + (_cAlias)->ZAE_CODSUI,"A3_NOME"),1,13)),;
	              (_cAlias)->ZAE_COMIS4,;
				  (_cAlias)->ZAE_COMVA4,;
				  AllTrim(SubStr(Posicione("SA3",1,xFilial("SA3") + (_cAlias)->ZAE_CODGNC,"A3_NOME"),1,13)),;
	              (_cAlias)->ZAE_COMIS5,;
				  (_cAlias)->ZAE_COMVA5,;
	              Posicione("SB1",1,xFilial("SB1") + (_cAlias)->ZAE_PROD,"B1_GRUPO"),;
				  Posicione("SB1",1,xFilial("SB1") + (_cAlias)->ZAE_PROD,"B1_I_BIMIX")})
		
  (_cAlias)->( DBSkip() )
	  
EndDo
	
	
_aCabec := { 'Item',;           //01
             'Vendedor' ,;      //02
             'Nome' ,;          //03
             'Produto',;        //04
             'Descricao',;      //05
             'Comissao Vend.',; //06 *
             'Com.Var.Vend.',;  //07 *
             'Rede',;           //08
             'Nome Rede',;      //09
             'Cliente',;        //10
             'Loja',;           //11
             'Nome Cliente',;   //12
             'Coordenador',;    //13
             'Comissao Coord.',;//14 *
			 'Com.Var.Coord.',; //15 *
             'Gerente',;        //16
             'Comissao Ger.',;  //17 *
			 'Com.Var.Geren',;  //18 *
             'Supervisor',;     //19
             'Comissao Sup.',;  //20 *
             'Com.Var.Sup.',;   //21 *
			 'Ger.Nacional',;   //22
			 'Comiss.Ger.Nac',; //23 *
			 'Com.Var.Ger.Nac',;//24 *
			 'Grupo',;          //25
			 'MIX BI'}          //26
 
//se achou algum item abre a tela de exporta��o 
IF LEN(_aVends) > 0   
 
   oproc:cCaption := ("Gerando Planilha...")
   ProcessMessages()
   //se veio com nopc igual a 0 ou sem par�metro exporta direto para o excel, sen�o abre tela de exporta��o de csv
   if _nopc == 0
    DlgToExcel( { { "ARRAY" , "Regras de comiss�o" , @_aCabec , @_aVends } } )
  elseif _nopc == 1
    U_ITGERARQ( "Regras de comiss�o" , @_aCabec , @_aVends )
  else

   // Montando Cabe�alho do Relat�rio
   _aCabecalho := {}//- Array de cabecalho da planilha {{"Titulo 1","Alinhamento","Formatacao","Totaliza(s/n)"},
   For _nCpo := 1 to len(_aCabec)
   		// Alinhamento: 1-Left   ,2-Center,3-Right
   		// Formata��o.: 1-General,2-Number,3-Monet�rio,4-DateTime
   		//                   Titulo das Colunas ,Alinhamento ,Formata��o, Totaliza?
   		IF STRZERO(_nCpo,2) $ "06,07,14,15,17,18,20,21,23,24"
   		   Aadd(_aCabecalho,{_aCabec[_nCpo]     ,3           ,2         ,.F.})
   		ELSE
   		   Aadd(_aCabecalho,{_aCabec[_nCpo]     ,1           ,1         ,.F.})
   		ENDIF   
   	Next

   // Abrindo o relat�rio no Excel.
   oproc:cCaption := ("Abrindo o relat�rio no Excel...")
   ProcessMessages()
    _cDir := GetTempPath()  // Diret�rio de Gera��o das planilhas.
    _cArq := "COMISSOES_"+Dtos(Date())+"_"+StrTran(Time(),":","")+".xml"  // Nome da planilha a ser gerada.   

   U_ITGEREXCEL(_cArq,_cDir,"REGRAS DE COMISS�O","RELATORIO",_aCabecalho,_aVends)   
	
  endif

else
  ALERT("N�o foram encontradas regras com os par�metros selecionados!")
endif
	

Return() 

/*
===============================================================================================================================
Programa----------: AFIN004X
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/09/2017
===============================================================================================================================
Descri��o---------: Valida a digita��o dos dados de filtro da tela se sele��o de produtos a serem informados percentual de 
                    comiss�o dos representantes/coordenadores/gerentes.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN004X(_cCampo)
Local _lRet := .T.
Local _aOrd := SaveOrd({"SA1"})
Local _cChavPesq

Begin Sequence
   If _cCampo == "REDE"
      If !Empty(_cRede)
         ACY->(DbSetOrder(1)) // ACY_FILIAL+ACY_GRPVEN
         If ! ACY->(DbSeek(xFilial("ACY")+_cRede))
            U_ItMsg("C�digo de rede n�o cadastrado!", 'Aten��o!' , 'Informe um c�digo de rede v�lido ou tecle F3 para abrir a tela de consultas de redes, para que voc� possa selecionar um codigo de rede v�lido.',1)
            _lRet := .F.
            Break   
         EndIf
      EndIf
   ElseIf _cCampo == "CLIENTE"
      If !Empty(_cClienVend)
         If !Empty(_cRede)
            U_ItMsg("J� existe um c�digo de rede definido para cria��o de regra de comiss�o!", 'Aten��o!' , 'Limpe o conte�do do c�digo da rede para definir uma regra de comiss�o por cliente.',1)
            _lRet := .F.
            Break
         EndIf
       
         SA1->(DbSetOrder(1))
         If ! Empty(_cLojaCVend)
            _cChavPesq := _cClienVend + _cLojaCVend
         Else
            _cChavPesq := _cClienVend
         EndIf
         
         If ! SA1->(DbSeek(xFilial("SA1")+_cChavPesq))
            U_ItMsg("Cliente n�o cadastrado!", 'Aten��o!' , 'Informe um c�digo+loja de cliente v�lido.',1)
            _lRet := .F.
            Break
         Else
            If !Empty(SA1->A1_GRPVEN) .And. SA1->A1_GRPVEN <> "999999"  
               U_ItMsg("Este cliente pertence a rede: " + SA1->A1_GRPVEN +"." , 'Aten��o!' , 'Voc� deve criar uma regra para a rede: '+ SA1->A1_GRPVEN + ".",1)
               _lRet := .F.
               Break
            EndIf
         EndIf
      EndIf

   ElseIf _cCampo == "LOJA"
      If !Empty(_cLojaCVend)
         If !Empty(_cRede)
            U_ItMsg("J� existe um c�digo de rede definido para cria��o de regra de comiss�o!", 'Aten��o!' , 'Limpe o conte�do do c�digo da rede para definir uma regra de comiss�o por cliente+loja.',1)
            _lRet := .F.
            Break
         EndIf
      
         If !Empty(_cClienVend) 
            SA1->(DbSetOrder(1))
            _cChavPesq := _cClienVend + _cLojaCVend
                     
            If ! SA1->(DbSeek(xFilial("SA1")+_cChavPesq))
               U_ItMsg("Cliente n�o cadastrado!", 'Aten��o!' , 'Informe um c�digo+loja de cliente v�lido.',1)
               _lRet := .F.
               Break
            Else
               If !Empty(SA1->A1_GRPVEN) .And. SA1->A1_GRPVEN <> "999999"  
                  U_ItMsg("Este cliente pertence a rede: " + SA1->A1_GRPVEN +"." , 'Aten��o!' , 'Voc� deve criar uma regra para a rede: '+ SA1->A1_GRPVEN + ".",1)
                  _lRet := .F.
                  Break
               EndIf
            EndIf
         Else 
            U_ItMsg("C�digo de cliente n�o informado!", 'Aten��o!' , 'Voc� deve informar o c�digo do cliente, antes de informar a loja.',1)
            _lRet := .F.
            Break
         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa----------: AFIN004Y
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/09/2017
===============================================================================================================================
Descri��o---------: Carregar array com dados que ser�o utilizados na valida��o da inser��o de novos dados.
===============================================================================================================================
Parametros--------: _lRotinaMVC = .T./.F. indica se esta rotina foi ou n�o chamada atrav�s de rotinas em MVC.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN004Y(_lRotinaMVC)
Local _oModel	// := FWModelActive()
Local _oModDet	// := _oModel:GetModel( 'ZAEDETAIL' )
Local _nLinDet	// := _oModDet:Length()
Local _nI, _cCodProd, _cDescr, _cRedeCli, _cCliente, _cLojaCli

Default _lRotinaMVC := .T.

Begin Sequence
   If _lRotinaMVC
      _oModel	:= FWModelActive()
      _oModDet	:= _oModel:GetModel( 'ZAEDETAIL' )
      _nLinDet	:= _oModDet:Length()

      _aGridVld   := {}
      For _nI := 1 To _nLinDet
          _oModDet:GoLine(_nI)
          _cCodProd := _oModDet:GetValue('ZAE_PROD')
          _cDescr   := _oModDet:GetValue('ZAE_NPROD')
          _cRedeCli := _oModDet:GetValue('ZAE_GRPVEN')
          _cCliente := _oModDet:GetValue('ZAE_CLI')
          _cLojaCli := _oModDet:GetValue('ZAE_LOJA')

          Aadd(_aGridVld,{_cCodProd, _cDescr, _cRedeCli, _cCliente, _cLojaCli})
      Next
   Else
      TRBZAE->(DbGoTop())
      Do While ! TRBZAE->(Eof())
         _cCodProd := TRBZAE->ZAE_PROD
         _cDescr   := TRBZAE->WK_NPROD
         _cRedeCli := TRBZAE->ZAE_GRPVEN
         _cCliente := TRBZAE->ZAE_CLI
         _cLojaCli := TRBZAE->ZAE_LOJA

         Aadd(_aGridVld,{_cCodProd, _cDescr, _cRedeCli, _cCliente, _cLojaCli})
   
         TRBZAE->(DbSkip())
      EndDo
      
   EndIf
End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AFIN004N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/09/2017
===============================================================================================================================
Descri��o---------: Marca e desmarca todos os itens pertencentes a um determinado grupo.
===============================================================================================================================
Parametros--------: aItens   - matriz a ser populada
                    _cGrupo - C�digo do grupo selecionado para sele��o do item do produto.
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function AFIN004N( aItens, _cGrupo )
Local _cQuery := ''
Local _cAlias := GetNextAlias()
Local _nI, _nJ := 0
Local _cChavePesq
Local _nni	:= 0

Begin Sequence
   _nI := Ascan(_aGrupoIt,{|x| x[1] == _cGrupo})
   
   If _nI  > 0 
      //=========================================================================================
      // O array aItens quando preenchido determina os itens selecionados na tela.
      // Este trecho remove os itens do array aItens para desmarcar os itens.
      //=========================================================================================
      For _nI := 1 To Len(_aGrupoIt) 
       
          If _cGrupo == _aGrupoIt[_nI,1]
         
             _cChavePesq := _aGrupoIt[_nI,2]
             _nJ := Ascan(aItens,{|x| x[1] == _cChavePesq})
           
             If _nJ > 0                
                
                _atemp := aItens
                aItens := {}
                
                For _nni :=1 to len(_atemp)
                
                	If _nni != _nj
                		aadd(aItens,_atemp[_nni])
                	Endif
                
                Next
                
             EndIf
      
          EndIf
      Next
      //=========================================================================================
      // Este trecho remove do array de controle _aGrupoIt, os grupos pertencentes aos itens que
      // foram desmarcados.
      //=========================================================================================
      _atemp := _aGrupoIt
      _aGrupoIt := {}
      
      For _nJ := 1 To Len(_atemp)
           If alltrim(_atemp[_nJ,1]) != (_cGrupo)
               aadd(_aGrupoIt,_atemp[_nj])
           EndIf
      Next
      
   Else
    
      //=============================================================================================
      // Este trecho grava no array aItens, os itens que ser�o marcados e grava o no array _aGrupoIt
      // os grupos e itens que foram selecionados.
      //=============================================================================================
	  _cQuery := " SELECT SB1.B1_COD "
	  _cQuery += " FROM  "+ RetSqlName('SB1') +" SB1 "
	  _cQuery += " WHERE "+ RetSqlCond('SB1')
	  _cQuery += " AND SB1.B1_TIPO = 'PA' "
	  _cQuery += " AND SB1.B1_GRUPO = '"+_cGrupo+"' "
	  //_cQuery += " AND SB1.B1_MSBLQL <> '1' "
	  _cQuery += " ORDER BY SB1.B1_COD "
	
	  If Select(_cAlias) > 0
		 (_cAlias)->( DBCloseArea() )
	  EndIf
	
	  DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
	  DBSelectArea(_cAlias)
	  (_cAlias)->( DBGoTop() )
      
      Do While (_cAlias)->( !Eof() )
		 
		 If !(Ascan(aItens,{|x| x[1] == (_cAlias)->B1_COD})>0)
		 	aAdd( aItens , { (_cAlias)->B1_COD } )
		 Endif
		 Aadd(_aGrupoIt, {_cGrupo,(_cAlias)->B1_COD})

	     (_cAlias)->( DBSkip() )
	  EndDo
	
	  (_cAlias)->( DBCloseArea() )
   EndIf
   
End Sequence 

Return()

/*
===============================================================================================================================
Programa----------: AFIN004K
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/09/2017
===============================================================================================================================
Descri��o---------: Tela de filtragem dos dados de comiss�o dos representantes.
===============================================================================================================================
Parametros--------: _cAcao = A��o de filtro a ser tomada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AFIN004K(_cAcao)

Local _nRegAtu
Local _bCondFiltro, _cCondFiltro

Begin Sequence
   If _cAcao == "FILTRAR"
      _cCondFiltro := ""

      If _cFiltroExato == "S"
         If ! Empty(_cFiltroGrupo) .And.  Empty(_cFiltroPrd) .And. Empty(_cFiltroRede) .And. Empty(_cFiltroCliente) .And. Empty(_cFiltroLoja)     
            _cCondFiltro := " WKGRUPO == '"+ _cFiltroGrupo + "' "
         Else
            If !Empty(_cFiltroGrupo)
               _cCondFiltro += " WKGRUPO == '"+ _cFiltroGrupo + "' "
            EndIf
      
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " ZAE_PROD == '"+_cFiltroPrd+"' "
         
            _cCondFiltro += " .And. ZAE_GRPVEN == '"+_cFiltroRede+"' "
      
            _cCondFiltro += " .And. ZAE_CLI == '"+_cFiltroCliente+"' .And. ZAE_LOJA == '"+_cFiltroLoja+"' "
         EndIf      
      Else
         If Empty(_cFiltroGrupo) .And.  Empty(_cFiltroPrd) .And. Empty(_cFiltroRede) .And. Empty(_cFiltroCliente) .And. Empty(_cFiltroLoja) .AND. Empty(_cMIXBI)
            _cCondFiltro := " ZAE_PROD == '"+Space(15)+"' "
         EndIf

         If !Empty(_cFiltroGrupo)
            _cCondFiltro += " WKGRUPO == '"+ _cFiltroGrupo + "' "
         EndIf
      
         If ! Empty(_cFiltroPrd)
             _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " ZAE_PROD == '"+_cFiltroPrd+"' "
         EndIf
      
         If ! Empty(_cFiltroRede)
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " ZAE_GRPVEN == '"+_cFiltroRede+"' "
         EndIf
      
         If ! Empty(_cFiltroCliente) .And. Empty(_cFiltroLoja)
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " ZAE_CLI == '"+_cFiltroCliente+"' "
         EndIf

         If ! Empty(_cFiltroCliente) .And. ! Empty(_cFiltroLoja)
            _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " ZAE_CLI == '"+_cFiltroCliente+"' .And. ZAE_LOJA == '"+_cFiltroLoja+"' "
         EndIf
      EndIf
      If !Empty(_cMIXBI)
         _cCondFiltro += If(!Empty(_cCondFiltro)," .And. ","") + " WK_BIMIX $ '"+ALLTRIM(_cMIXBI)+"' "
      EndIf
      
      _cCondFiltro := "{ | | " + _cCondFiltro + "} "
      
      _bCondFiltro := &_cCondFiltro
      
      TRBZAE->(DbSetFilter(_bCondFiltro, _cCondFiltro))      
   Else//LIMPARFILTRO
      _nRegAtu := TRBZAE->(Recno())
      TRBZAE->(DbClearFilter())
      TRBZAE->(DbGoTo(_nRegAtu))
   EndIf
   
   _oGetDB:Refresh()
   TRBZAE->(DbGoTop())
   
End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AFIN004H()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 19/09/2017
=================================================================================================================================
Descri��o-------: Chama Rotina de altera��o e manuten��o das regras de comiss�o.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AFIN004H()

fwmsgrun(,{|| U_AFIN004J()},"Aguarde...","Carregando regras...")

Return


/*
=================================================================================================================================
Programa--------: AFIN004J()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 19/09/2017
=================================================================================================================================
Descri��o-------: Rotina de altera��o e manuten��o das regras de comiss�o.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AFIN004J()

Local _aStrucZAE
Local _aButtons := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _oDlgEnch, _nI
Local _cCmpVirtuais
Local _cCamposTela
Local _lOk := .F.
Local _nLinha := 22

Private aHeader := {}
Private _aAltera := {}
Private _oGetDB
Private _cCodVend, _cNomeVend

Begin Sequence
   //================================================================================
   // Inclui bot�es adicionais
   //================================================================================
   AADD(_aButtons,{"Produtos",{|| U_AFIN004R(.F.) },"Produtos","Produtos"}) 
   AADD(_aButtons,{"Atualizar",{|| U_AFIN004U(.F.) },"Atualizar","Atualizar"}) 
   
   //================================================================================
   // Codigo do vendedor posicionado no Mbrowse
   //================================================================================
   _cCodVend := ZAE->ZAE_VEND 
   _cNomeVend := Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_VEND,'A3_NOME')
   
   //================================================================================
   // Monta as colunas do MSGETDB para a tabela tempor�ria TRBZAE 
   //================================================================================
   _cCamposTela := "ZAE_FILIAL,ZAE_ITEM,ZAE_PROD,ZAE_NPROD,ZAE_COMIS1,ZAE_GRPVEN,ZAE_CLI,ZAE_LOJA,ZAE_NCLI,ZAE_CODSUI,ZAE_NSUI,"
   _cCamposTela += "ZAE_COMIS4,ZAE_CODSUP,ZAE_NSUP,ZAE_COMIS2,ZAE_CODGER,ZAE_NGEREN,ZAE_COMIS3,ZAE_MSBLQL,ZAE_VEND,ZAE_CODGNC,ZAE_NGERNC,ZAE_COMIS5,ZAE_COMVA5"
   _aStrucZAE   := {}
   
   _cCmpVirtuais := "ZAE_NOME  /ZAE_NPROD /ZAE_NCLI  /ZAE_NSUP  /ZAE_NGEREN/ZAE_NSUI / ZAE_NGERNC /"
   
   //================================================================================
   // Cria as estruturas das tabelas tempor�rias
   //================================================================================
   
   	Aadd(_aStrucZAE, {"ZAE_FILIAL","C" ,2  ,0})
   	Aadd(_aStrucZAE, {"ZAE_ITEM"  ,"C" ,3  ,0})
   	Aadd(_aStrucZAE, {"ZAE_VEND"  ,"C" ,6  ,0})
   	Aadd(_aStrucZAE, {"ZAE_PROD"  ,"C" ,15 ,0})
   	Aadd(_aStrucZAE, {"WK_NPROD"  ,"C" ,100,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS1","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA1","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"ZAE_GRPVEN","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"ZAE_CLI"   ,"C" ,6  ,0})
   	Aadd(_aStrucZAE, {"ZAE_LOJA"  ,"C" ,4  ,0})
   	Aadd(_aStrucZAE, {"WK_NCLI"   ,"C" ,60 ,0})
   	Aadd(_aStrucZAE, {"ZAE_CODSUP","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NSUP"   ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS2","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA2","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"ZAE_CODGER","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NGEREN" ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS3","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA3","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"ZAE_MSBLQL","C" ,1  ,0})
   	Aadd(_aStrucZAE, {"ZAE_CODSUI","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NSUI"   ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS4","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA4","N" ,7  ,3})
    Aadd(_aStrucZAE, {"ZAE_CODGNC","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NGNC"   ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS5","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA5","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"WKGRUPO"   ,"C" ,04 ,0}) // C�digo do Grupo de Produtos.
   	Aadd(_aStrucZAE, {"WK_BIMIX" , "C" ,02 ,0}) // C�digo do Mix BI.
   	Aadd(_aStrucZAE, {"WKRECNO"   ,"N" ,10 ,0})
   	Aadd(_aStrucZAE, {"DELETED"   ,"L" ,1  ,0})
   
    Aadd(aHeader,   {"Item"        ,"ZAE_ITEM"    ,"@!        ",3  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Produto"     ,"ZAE_PROD"    ,"@!        ",15 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Produto","WK_NPROD"    ,"@!        ",100,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comis. Prod" ,"ZAE_COMIS1"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Vend"  ,"ZAE_COMVA1"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})

    Aadd(aHeader,   {"Rede"        ,"ZAE_GRPVEN"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Cliente"     ,"ZAE_CLI"     ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Loja"        ,"ZAE_LOJA"    ,"@!        ",4  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome"        ,"WK_NCLI"     ,"@!        ",60 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Cod Coord"   ,"ZAE_CODSUP"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nomed Coord.","WK_NSUP"     ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comis. Coord","ZAE_COMIS2"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Cord","ZAE_COMVA2"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})

    Aadd(aHeader,   {"Cod. Gerente","ZAE_CODGER"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Gerente","WK_NGEREN"   ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comissao Ger","ZAE_COMIS3"  ,"@E 999.999" ,6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Gere","ZAE_COMVA3"  ,"@E 999.999" ,6  ,2," "," ","N"," "," "})

    Aadd(aHeader,   {"Bloqueado?"  ,"ZAE_MSBLQL"  ," "         ,1  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Cod Superv"  ,"ZAE_CODSUI"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Superv" ,"WK_NSUI"     ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comissao Sup","ZAE_COMIS4"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Sup" ,"ZAE_COMVA4"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
//===========================================================================================
    Aadd(aHeader,   {"Cod Ger.Nac."    ,"ZAE_CODGNC","@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Ger.Nac."   ,"WK_NGNC"   ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comissao Ger.Nac","ZAE_COMIS5","@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Ger.Nac" ,"ZAE_COMVA5","@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Grupo"           ,"WKGRUPO"   ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"MIX BI"          ,"WK_BIMIX"  ,"@!        ",25 ,0," "," ","C"," "," "})
//===========================================================================================
   _cCmpVirtuais += "WKRECNO/WK_NPROD/WK_NCLI/WK_NSUI/WK_NSUP/WK_NGEREN/DELETED/WKGRUPO/WK_NGNC/WK_BIMIX"
   
         
   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZAE") > 0
      TRBZAE->( DBCloseArea() )
   EndIf
   
   //================================================================================
   // Abre o arquivo TRBZAE criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZAE",  _aStrucZAE )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZAE_PROD","ZAE_CLI","ZAE_LOJA"} )
   _otemp:AddIndex( "02", {"ZAE_VEND","ZAE_PROD","ZAE_GRPVEN","ZAE_CLI","ZAE_LOJA"} )
   _otemp:AddIndex( "03", {"ZAE_VEND","ZAE_PROD","ZAE_GRPVEN"} )          
   _otemp:AddIndex( "04", {"ZAE_VEND","ZAE_PROD","ZAE_CLI"} )             
   _otemp:AddIndex( "05", {"ZAE_VEND","ZAE_PROD","ZAE_CLI","ZAE_LOJA"} )  
   _otemp:AddIndex( "06", {"ZAE_VEND","ZAE_PROD"} )                       

   _otemp:Create()
        
   //================================================================================
   // Array com os campos que poder�o ser alterados.
   //================================================================================                                                                                  
   Aadd(_aAltera,"ZAE_COMIS1")
   Aadd(_aAltera,"ZAE_COMIS2")
   Aadd(_aAltera,"ZAE_COMIS3")
   Aadd(_aAltera,"ZAE_COMIS4")
   Aadd(_aAltera,"ZAE_COMIS5")
   Aadd(_aAltera,"ZAE_COMVA1")
   Aadd(_aAltera,"ZAE_COMVA2")
   Aadd(_aAltera,"ZAE_COMVA3")
   Aadd(_aAltera,"ZAE_COMVA4")
   Aadd(_aAltera,"ZAE_COMVA5")

   Aadd(_aAltera,"ZAE_GRPVEN")
   Aadd(_aAltera,"ZAE_CLI")
   Aadd(_aAltera,"ZAE_LOJA")
   
   //================================================================================
   // Carrega os dados da tabela ZAE
   //================================================================================
   ZAE->(DbSetOrder(1)) // ZAE_FILIAL+ZAE_VEND+ZAE_PROD+ZAE_CLI+ZAE_LOJA 
   ZAE->(DbSeek(xFilial("ZAE")+_cCodVend))
   
   Do While ! ZAE->(Eof()) .And. ZAE->(ZAE_FILIAL+ZAE_VEND) == xFilial("ZAE")+_cCodVend
      
      TRBZAE->(RecLock("TRBZAE",.T.))
      For _nI := 1 To TRBZAE->(FCount())
          If AllTrim(TRBZAE->(FieldName(_nI))) $ _cCmpVirtuais //"ZAE_NOME"
             Loop
          EndIf

          &("TRBZAE->"+TRBZAE->(FieldName(_nI))) :=  &("ZAE->"+TRBZAE->(FieldName(_nI)))   
      Next
      
      TRBZAE->WKRECNO   := ZAE->(Recno())
      TRBZAE->WK_NPROD  := AllTrim(Posicione('SB1',1,xFilial('SB1')+ZAE->ZAE_PROD,'B1_DESC'))
      TRBZAE->WKGRUPO   := SB1->B1_GRUPO  
      TRBZAE->WK_BIMIX  := SB1->B1_I_BIMIX
      TRBZAE->WK_NCLI   := AllTrim(U_AFIN004F(ZAE->ZAE_GRPVEN,ZAE->ZAE_CLI,ZAE->ZAE_LOJA))                          

      TRBZAE->WK_NSUP   := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODSUP,'A3_NOME'))
      TRBZAE->WK_NSUI   := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODSUI,'A3_NOME'))
      TRBZAE->WK_NGEREN := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODGER,'A3_NOME'))
	  TRBZAE->WK_NGNC   := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODGNC,'A3_NOME'))
      
      TRBZAE->(MsUnlock())
      
      ZAE->(DbSkip())
   EndDo
   TRBZAE->(DbGoTop())

   _bOk     := {|| _lOk := .T., _oDlgEnch:End()}
   _bCancel := {|| _lOk := .F., _oDlgEnch:End()}

   _aItalac_F3:={}         //        1              2                3               4               5                    6                  7    8  9  10  11  12
   Aadd(_aItalac_F3,{"_cMIXBI",/*_cTabela*/ ,/*_nCpoChave*/ , /*_nCpoDesc*/ , /*_bCondTab*/ , "Lista de MIX BI" , LEN(SB1->B1_I_BIMIX) , _aBoxMix, ,   ,   ,   ,  })

                       
   _cTitulo := "Regras de Comiss�o - Altera��o"
   _nTam:=11
   
   Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
      
      @ 25+_nLinha, 06 Say "Cod. Vend."	Pixel Size 099,006  Of _oDlgEnch
      @ 35+_nLinha, 06 MSGet _cCodVend When .F. Pixel Size 030,_nTam Of _oDlgEnch
      
      @ 25+_nLinha, 55 Say "Nome Vended."	Pixel Size 099,006  Of _oDlgEnch
      @ 35+_nLinha, 55 MSGet _cNomeVend When .F. Pixel Size 150,_nTam Of _oDlgEnch

      @ 15+_nLinha, 215 Button 'FILTRAR'       Size 45, 14 Message 'Filtrar dados de regras de comiss�o'    Pixel Action AFIN004k( 'FILTRAR' ) of _oDlgEnch
      @ 35+_nLinha, 215 Button 'LIMPAR FILTRO' Size 45, 14 Message 'Limpar o filtro das regras de comiss�o' Pixel Action AFIN004k( 'LIMPARFILTRO' ) of _oDlgEnch

      @ 25+_nLinha, 270 Say "Grupo Prod:"	Pixel Size 018,006  Of _oDlgEnch
      @ 35+_nLinha, 270 MSGet _cFiltroGrupo F3 "SBM" Valid(Vazio() .Or. ExistCpo("SBM",_cFiltroGrupo)) Pixel Size 040,_nTam Of _oDlgEnch
      
      @ 25+_nLinha, 320 Say "Produto:"	Pixel Size 018,006  Of _oDlgEnch
      @ 35+_nLinha, 320 MSGet _cFiltroPrd F3 "SB1_04" Valid(Vazio() .Or. ExistCpo("SB1",_cFiltroPrd)) Pixel Size 060,_nTam Of _oDlgEnch

      @ 25+_nLinha, 390 Say "Rede:"	Pixel Size 018,006 Of _oDlgEnch 
      @ 35+_nLinha, 390 MSGet _cFiltroRede F3 "ACY" Valid(Vazio() .Or. ExistCpo("ACY",_cFiltroRede)) Pixel Size 040,_nTam Of _oDlgEnch

      @ 25+_nLinha, 440 Say "Cliente:"	Pixel Size 018,006 Of _oDlgEnch
      @ 35+_nLinha, 440 MSGet _cFiltroCliente  F3 "SA1" Valid(Vazio() .Or. ExistCpo("SA1",_cFiltroCliente)) Pixel Size 040,_nTam Of _oDlgEnch

      @ 25+_nLinha, 490 Say "Loja:"	Pixel Size 018,006 Of _oDlgEnch
      @ 35+_nLinha, 490 MSGet _cFiltroLoja Valid(Vazio() .Or. ExistCpo("SA1",_cFiltroCliente+_cFiltroLoja)) Pixel Size 030,_nTam Of _oDlgEnch
      
      @ 25+_nLinha, 530 Say "Filtro Exato?"	Pixel Size 030,006 Of _oDlgEnch
      @ 35+_nLinha, 530 MSCOMBOBOX _oFiltroExato Var _cFiltroExato ITEMS {"S=Sim","N=Nao"} Valid (Pertence('SN')) Pixel Size 037, 15 Of _oDlgEnch

      @ 25+_nLinha, 580 Say "Mix BI :"	Pixel Size 030,006 Of _oDlgEnch
      @ 35+_nLinha, 580 MSGet _cMIXBI  F3 "F3ITLC" Pixel Size 055,_nTam Of _oDlgEnch

      //         MsGetDB():New ( < nTop>, < nLeft>, < nBottom>, < nRight>   , < nOpc>, [ cLinhaOk]    , [ cTudoOk]    , [ cIniCpos]  , [ lDelete], [ aAlter], [ nFreeze], [ lEmpty], [ uPar1], < cTRB> , [ cFieldOk]    , [ uPar2], [ lAppend], [ oWnd], [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] )
      _oGetDB := MsGetDB():New(_aSizeAut[7]+60+_nLinha, 05, _aSizeAut[4],_aSizeAut[3], 3     , "U_AFIN004O"/*"U_LINHAOK"*/, /*"U_TUDOOK"*/, /*"+A1_COD"*/, .T.       , _aAltera , 1         , .F.      ,         , "TRBZAE", /*"U_FIELDOK"*/,         , .F.       , _oDlgEnch, .T., ,/*"U_DELOK"*/, /*"U_SUPERDEL"*/)
      _oGetDB:oBrowse:bAdd  := {||.F.} // n�o inclui novos itens MsGetDb()  
      
   Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel,,_aButtons) 
   
   //================================================================================
   // Grava��o dos dados alterados.
   //================================================================================                    
   If _lOk
      TRBZAE->(DbClearFilter())   
      //=====================================================================================
      // Verifica quais altera��es foram realizadas e grava estas informa��es em Arrays
      // para serem gravadas nas tabelas de hist�ricos de altera��es.                              
      //=====================================================================================
      U_AFIN004A(_nOperAlteracao) 
      
      TRBZAE->(DbGoTop())
      Do While ! TRBZAE->(Eof())
         //===========================================================================================
         // C�digo de produto em branco na tabela tempor�ria, indica que houve tentativa de inclus�o 
         // de dados. Nesta rotina n�o � permitido.
         //===========================================================================================
         If Empty(TRBZAE->ZAE_PROD) 
            TRBZAE->(DbSkip())
            Loop
         EndIf
                  
         //================================================================================
         // Verifica e realiza a exclus�o de registros.
         //================================================================================                    
         If TRBZAE->DELETED   //  TRBZAE->(Deleted())
            If TRBZAE->WKRECNO > 0
               ZAE->(DbGoTo(TRBZAE->WKRECNO))  
               ZAE->(RecLock("ZAE",.F.))
               ZAE->(DbDelete())
               ZAE->(MsUnLock())
            EndIf
            
            TRBZAE->(DbSkip())
            Loop
         EndIf
         
         //================================================================================
         // Grava os registros alterados.
         //================================================================================                    
         //Verifica se n�o tem registro duplicado
         _lachou := .F.
         _nrecno := TRBZAE->WKRECNO
         If Empty(TRBZAE->WKRECNO)
         
         	ZAE->(Dbsetorder(4))
         	If ZAE->(Dbseek(TRBZAE->ZAE_FILIAL+_cCodVend+TRBZAE->ZAE_PROD+TRBZAE->ZAE_GRPVEN+TRBZAE->ZAE_CLI+TRBZAE->ZAE_LOJA))
         		
         		_lachou := .T.
         		_nrecno := ZAE->(Recno())
         		
         	Endif
         	
         Endif
         	
         If Empty(TRBZAE->WKRECNO) .and. !_lachou
            ZAE->(RecLock("ZAE",.T.))
            ZAE->ZAE_FILIAL := TRBZAE->ZAE_FILIAL
            ZAE->ZAE_ITEM   := TRBZAE->ZAE_ITEM 
            ZAE->ZAE_VEND   := _cCodVend  // TRBZAE->ZAE_VEND
            ZAE->ZAE_PROD   := TRBZAE->ZAE_PROD
            ZAE->ZAE_MSBLQL := TRBZAE->ZAE_MSBLQL
         Else       
            ZAE->(DbGoTo(_nrecno))
            ZAE->(RecLock("ZAE",.F.))
         EndIf
         ZAE->ZAE_CODSUP := TRBZAE->ZAE_CODSUP 
         ZAE->ZAE_CODGER := TRBZAE->ZAE_CODGER
         ZAE->ZAE_CODSUI := TRBZAE->ZAE_CODSUI
		 ZAE->ZAE_CODGNC := TRBZAE->ZAE_CODGNC

         ZAE->ZAE_COMIS1 := TRBZAE->ZAE_COMIS1
         ZAE->ZAE_COMIS2 := TRBZAE->ZAE_COMIS2
         ZAE->ZAE_COMIS3 := TRBZAE->ZAE_COMIS3
         ZAE->ZAE_COMIS4 := TRBZAE->ZAE_COMIS4
		 ZAE->ZAE_COMIS5 := TRBZAE->ZAE_COMIS5

         ZAE->ZAE_COMVA1 := TRBZAE->ZAE_COMVA1
         ZAE->ZAE_COMVA2 := TRBZAE->ZAE_COMVA2
         ZAE->ZAE_COMVA3 := TRBZAE->ZAE_COMVA3
         ZAE->ZAE_COMVA4 := TRBZAE->ZAE_COMVA4
		 ZAE->ZAE_COMVA5 := TRBZAE->ZAE_COMVA5

         ZAE->ZAE_GRPVEN := TRBZAE->ZAE_GRPVEN
         ZAE->ZAE_CLI    := TRBZAE->ZAE_CLI
         ZAE->ZAE_LOJA   := TRBZAE->ZAE_LOJA
         ZAE->(MsUnLock())
         
         TRBZAE->(DbSkip())
      EndDo
      
      //=======================================================================================
      // Grava os dados de altera��es contidos nos arrays na tabela de Hist�rico de Altera��es   
      //=======================================================================================
      U_AFIN004E(_nOperAlteracao) 
   
   EndIf

End Sequence

//================================================================================
// Fecha e exclui as tabelas tempor�rias
//================================================================================                    
If Select("TRBZAE") > 0
   TRBZAE->(DbCloseArea())
   _otemp:Delete()
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: AFIN004O
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/09/2017
===============================================================================================================================
Descri��o---------: Rotina de valida��o da exclus�o de dados, na altera��o das regras de comiss�o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN004O()
Local _lRet := .T.

Begin Sequence
   If Empty(TRBZAE->ZAE_PROD)
      U_ItMsg("N�o � permitido a inclus�o de novos registros nesta tela!", 'Aten��o!' , 'Utilize o recurso adicionar produtos.',1) 
      _lRet := .F.  
   EndIf   
   
   If Empty(TRBZAE->ZAE_VEND)    
      TRBZAE->(RecLock("TRBZAE",.F.))
      TRBZAE->ZAE_VEND := _cCodVend
      TRBZAE->(MsUnlock())
   EndIf
   
End Sequence

Return _lRet 

/*
===============================================================================================================================
Programa----------: AFIN004Q
Autor-------------: Julio de Paula Paz
Data da Criacao---: 16/11/2017
===============================================================================================================================
Descri��o---------: Retorna os dados dos modelos de dados do MVC.
===============================================================================================================================
Parametros--------: _cCampo = Nome do campo a retornar os dados.
=============================================================================================================================
Retorno-----------: _cRet = Conte�do do campo passado como par�metro.
===============================================================================================================================
*/
User Function AFIN004Q(_cCampo)
Local _cRet := ""
Local _oModel	:= FWModelActive()
Local _oModDet  := _oModel:GetModel( 'ZAEDETAIL' )

Begin Sequence
   If _cCampo == "ZAE_CLI"
      _cRet := _oModDet:GetValue('ZAE_CLI')  
   ElseIf _cCampo == "ZAE_LOJA"
      _cRet := _oModDet:GetValue('ZAE_LOJA')  
   EndIf
   
End Sequence

Return _cRet 

/*
===============================================================================================================================
Programa----------: AFIN004A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/11/2018
===============================================================================================================================
Descri��o---------: Verifica se houve inclus�o, altera��o ou exclus�o de dados e grava as informa��es em um Array para a 
                    grava��o de hist�rico.
===============================================================================================================================
Parametros--------: _nOper = 3 = Inclus�o
                           = 4 = Altera��o
                           = 5 = Exclus�o
                    _oModel = Modelo de dados para as rotinas em MVC.
=============================================================================================================================
Retorno-----------: _lRet = .T. 
===============================================================================================================================
*/
User Function AFIN004A(_nOper, _oModel)
Local _lRet := .T.
Local _oModelCapa := Nil
Local _oModelDet  := Nil
Local _aOrd := SaveOrd({"ZAE"})
Local _nRegZAE := ZAE->(Recno())
Local _nI, _nJ, _aDet, _nk
Local _cCampoZY6
Local _lAchouZAE
Local _cMsg
Local _cNomeV, _cCodV 
Local _nVersao, _cVersao
Local _cExcluido
Local _cItem, _cCodProd, _cNomeProd
Local _cNomeGer, _cNomeSup, _cNomeCoord
Local _cCodGer, _cCodSup, _cCodCoord, _cCodGnc, _cNomeGnc
Local _cBloq

Private _aVersao := {}

Begin Sequence
   _aDadosCapa := {}
   _aDadosItem := {}
   
   If _nOper == _nOperInclusao
      _oModelCapa := _oModel:GetModel("ZAEMASTER")
      _oModelDet  := _oModel:GetModel("ZAEDETAIL")
      
      For _nI := 1 To ZAE->(FCount())
          If AFIN004CPO(ZAE->(FieldName(_nI)) , 1 )
             Aadd(_aDadosCapa,{ZAE->(FieldName(_nI)), _oModelCapa:GetValue(ZAE->(FieldName(_nI)))})
          EndIf
      Next
      
      For _nI := 1 To _oModelDet:Length()
          _oModelDet:GoLine( _nI )
          _aDet := {}
          
          _cCodV   := _oModelCapa:GetValue("ZAE_VEND")
          _cNomeV  := _oModelCapa:GetValue("ZAE_NOME")
          _cBloq   := _oModelCapa:GetValue("ZAE_MSBLQL") 
          
          Aadd(_aDet,{"ZY6->ZY6_FILIAL" , xFilial("ZAE")})     // 'Filial'
          
          
          For _nJ := 1 To ZAE->(FCount())
             If AFIN004CPO(ZAE->(FieldName(_nJ)) , 2 ) .And. ! (AllTrim(ZAE->(FieldName(_nJ))) $ "ZY6_DATA/ZY6_HORA/ZY6_USUAR/ZY6_DELET/ZY6_VERSAO/ZY6_DSCALT")
                
                If AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_ITEM"
                   _cItem := _oModelDet:GetValue("ZAE_ITEM")
                   Aadd(_aDet,{"ZY6->ZY6_ITEM"   , _cItem})   // 'Item'  
                   Aadd(_aDet,{"ZY6->ZY6_VEND"   , _cCodV})   // 'Cod. Vend.'	
                   Aadd(_aDet,{"ZY6->ZY6_NOME"   , _cNomeV})  // 'Nome Vended.'
                
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_PROD"
                
                   _cCodProd := _oModelDet:GetValue("ZAE_PROD")
                   _cCampoZY6 := "ZY6->ZY6_PROD"
                   Aadd(_aDet,{_cCampoZY6, _cCodProd}) 
                
                   _cNomeProd := Posicione('SB1',1,xFilial('SB1')+_cCodProd,'B1_DESC')
                   
                   _cCampoZY6 := "ZY6->ZY6_NPROD"
                   Aadd(_aDet,{_cCampoZY6, _cNomeProd}) 
                   
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODSUP"  
                   _cCodCoord := _oModelDet:GetValue("ZAE_CODSUP") // Codigo Coordenador
                   
                   _cCampoZY6 := "ZY6->ZY6_CODSUP"
                   Aadd(_aDet,{_cCampoZY6, _cCodCoord}) 
                   
                   _cNomeCoord := Posicione('SA3',1,xFilial('SA3')+_cCodCoord,'A3_NOME') // Nome Coordenador
                   
                   _cCampoZY6 := "ZY6->ZY6_NSUP"                
                   Aadd(_aDet,{_cCampoZY6, _cNomeCoord}) 
                   
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODGER"
                   _cCodGer := _oModelDet:GetValue("ZAE_CODGER")  // Codigo Gerente
                   
                   _cCampoZY6 := "ZY6->ZY6_CODGER"
                   Aadd(_aDet,{_cCampoZY6, _cCodGer})
                   
                   _cNomeGer  := Posicione('SA3',1,xFilial('SA3')+_cCodGer,'A3_NOME') // Nome Gerente
                           
                   _cCampoZY6 := "ZY6->ZY6_NGEREN"
                   Aadd(_aDet,{_cCampoZY6, _cNomeGer})
                   
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODSUI"
                   _cCodSup := _oModelDet:GetValue("ZAE_CODSUI") // C�digo Supervisor
                   
                   _cCampoZY6 := "ZY6->ZY6_CODSUI"
                   Aadd(_aDet,{_cCampoZY6, _cCodSup})
                   
                   _cNomeSup := Posicione('SA3',1,xFilial('SA3')+_cCodSup,'A3_NOME') // Nome Supervisor
                   
                   _cCampoZY6 := "ZY6->ZY6_NSUI"
                   Aadd(_aDet,{_cCampoZY6, _cNomeSup})

               ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODGNC"
                   _cCodGnc := _oModelDet:GetValue("ZAE_CODGNC") // C�digo do Gerente Nacional
                   
                   _cCampoZY6 := "ZY6->ZY6_CODGNC"
                   Aadd(_aDet,{_cCampoZY6, _cCodGnc})
                   
                   _cNomeGnc := Posicione('SA3',1,xFilial('SA3')+_cCodGnc,'A3_NOME') // Nome Supervisor
                   
                   _cCampoZY6 := "ZY6->ZY6_NGERNC"
                   Aadd(_aDet,{_cCampoZY6,_cNomeGnc})

                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_MSBLQL"   
                   _cBloq := _oModelDet:GetValue("ZAE_MSBLQL")
                   
                   _cCampoZY6 := "ZY6->ZY6_NSUI"
                   Aadd(_aDet,{_cCampoZY6, AllTrim(_cBloq)})                   
                   
                Else   // Demais campos.
                   _cCampoZY6 := "ZY6->ZY6"+AllTrim(SubStr(ZAE->(FieldName(_nJ)),4,10))
                   Aadd(_aDet,{_cCampoZY6, _oModelDet:GetValue(ZAE->(FieldName(_nJ)))}) 
                   
                EndIf
             EndIf
          Next
          
          _nK := Ascan(_aVersao, {|x| x[1] == xFilial("ZAE") .And. x[2] == _cCodV .And. x[3] == _cItem .And. x[4] == _cCodProd})
            
          If _nK > 0
             _nVersao := _aVersao[_nK,5]            
          Else
             _nVersao := 0
          EndIf
            
          _nVersao := U_AFIN004S(xFilial("ZAE") , _cCodV, _cItem, _cCodProd, _nVersao)
          _cVersao := StrZero(_nVersao,2)
          
          If _nK > 0
             _aVersao[_nK,5] := _nVersao
          Else
             Aadd(_aVersao,{ xFilial("ZAE") , _cCodV, _cItem , _cCodProd, _nVersao}) 
          EndIf
          
          _cExcluido := "Incluido"
          _cMsg := "Incluidas novas regras do representante."
          
          //Aadd(_aDet,{"ZY6->ZY6_FILIAL" , xFilial("ZAE")})     // 'Filial'
          //Aadd(_aDet,{"ZY6->ZY6_VEND"   , _cCodV})             // 'Cod. Vend.'	
          //Aadd(_aDet,{"ZY6->ZY6_NOME"   , _cNomeV})            // 'Nome Vended.'
          
          Aadd(_aDet,{"ZY6->ZY6_DATA"   , Date()})             // 'Data Alterac'	
          Aadd(_aDet,{"ZY6->ZY6_HORA"   , Time()})             // 'Hora Alterac'
          Aadd(_aDet,{"ZY6->ZY6_USUAR"  , __cUserId})          // 'Usuario Alte'
          Aadd(_aDet,{"ZY6->ZY6_DELET"  , _cExcluido})         // 'Deletado'	// TRBZAE->DELETED
          Aadd(_aDet,{"ZY6->ZY6_VERSAO" ,  _cVersao})          // 'Versao'
          Aadd(_aDet,{"ZY6->ZY6_DSCALT" , _cMsg})              // 'Descric.Alte'				
          
          Aadd(_aDadosItem,_aDet)
      Next
      
      //================================================================
      // Grava Log de Inclus�o de Dados na tabela ZY6
      //================================================================
      U_AFIN004E(_nOper, _oModel)
      
   ElseIf _nOper ==  _nOperExclusao
      _oModelCapa := _oModel:GetModel("ZAEMASTER")
      _oModelDet  := _oModel:GetModel("ZAEDETAIL")
   
      //ZAE_FILIAL+ZAE_VEND+ZAE_ITEM
      For _nI := 1 To ZAE->(FCount())
          If AFIN004CPO(ZAE->(FieldName(_nI)) , 1 )
             Aadd(_aDadosCapa,{ZAE->(FieldName(_nI)), _oModelCapa:GetValue(ZAE->(FieldName(_nI)))})
          EndIf
      Next
 
      For _nI := 1 To _oModelDet:Length()
          _oModelDet:GoLine( _nI )
          _aDet := {}
          
          _cCodV   := _oModelCapa:GetValue("ZAE_VEND")
          _cNomeV  := _oModelCapa:GetValue("ZAE_NOME")
          _cBloq   := _oModelCapa:GetValue("ZAE_MSBLQL") 
          
          Aadd(_aDet,{"ZY6->ZY6_FILIAL" , xFilial("ZAE")})     // 'Filial'
          
          For _nJ := 1 To ZAE->(FCount())
             If AFIN004CPO(ZAE->(FieldName(_nJ)) , 2 ) .And. ! (AllTrim(ZAE->(FieldName(_nJ))) $ "ZY6_DATA/ZY6_HORA/ZY6_USUAR/ZY6_DELET/ZY6_VERSAO/ZY6_DSCALT")
                If AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_ITEM"
                   _cItem := _oModelDet:GetValue("ZAE_ITEM")
                   Aadd(_aDet,{"ZY6->ZY6_ITEM"   , _cItem})   // 'Item'  
                   Aadd(_aDet,{"ZY6->ZY6_VEND"   , _cCodV})   // 'Cod. Vend.'	
                   Aadd(_aDet,{"ZY6->ZY6_NOME"   , _cNomeV})  // 'Nome Vended.'

                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_PROD"
                   _cCodProd := _oModelDet:GetValue("ZAE_PROD")
                   _cCampoZY6 := "ZY6->ZY6_PROD"
                   Aadd(_aDet,{_cCampoZY6, _cCodProd}) 
                
                   _cNomeProd := Posicione('SB1',1,xFilial('SB1')+_cCodProd,'B1_DESC')
                   
                   _cCampoZY6 := "ZY6->ZY6_NPROD"
                   Aadd(_aDet,{_cCampoZY6, _cNomeProd}) 
                   
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODSUP"  
                   _cCodCoord := _oModelDet:GetValue("ZAE_CODSUP") // Codigo Coordenador
                   
                   _cCampoZY6 := "ZY6->ZY6_CODSUP"
                   Aadd(_aDet,{_cCampoZY6, _cCodCoord}) 
                   
                   _cNomeCoord := Posicione('SA3',1,xFilial('SA3')+_cCodCoord,'A3_NOME') // Nome Coordenador
                   
                   _cCampoZY6 := "ZY6->ZY6_NSUP"                
                   Aadd(_aDet,{_cCampoZY6, _cNomeCoord}) 
                   
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODGER"
                   _cCodGer := _oModelDet:GetValue("ZAE_CODGER")  // Codigo Gerente
                   
                   _cCampoZY6 := "ZY6->ZY6_CODGER"
                   Aadd(_aDet,{_cCampoZY6, _cCodGer})
                   
                   _cNomeGer  := Posicione('SA3',1,xFilial('SA3')+_cCodGer,'A3_NOME') // Nome Gerente
                           
                   _cCampoZY6 := "ZY6->ZY6_NGEREN"
                   Aadd(_aDet,{_cCampoZY6, _cNomeGer})
                   
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODSUI"
                   _cCodSup := _oModelDet:GetValue("ZAE_CODSUI") // C�digo Supervisor
                   
                   _cCampoZY6 := "ZY6->ZY6_CODSUI"
                   Aadd(_aDet,{_cCampoZY6, _cCodSup})
                   
                   _cNomeSup := Posicione('SA3',1,xFilial('SA3')+_cCodSup,'A3_NOME') // Nome Supervisor
                   
                   _cCampoZY6 := "ZY6->ZY6_NSUI"
                   Aadd(_aDet,{_cCampoZY6, _cNomeSup}) 

                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_CODGNC"
                   _cCodGnc := _oModelDet:GetValue("ZAE_CODGNC") // C�digo do Gerente Nacional
                   
                   _cCampoZY6 := "ZY6->ZY6_CODGNC"
                   Aadd(_aDet,{_cCampoZY6, _cCodGnc})
                   
                   _cNomeGnc := Posicione('SA3',1,xFilial('SA3')+_cCodGnc,'A3_NOME') // Nome Gerente Nacional
                   
                   _cCampoZY6 := "ZY6->ZY6_NGERNC"
                   Aadd(_aDet,{_cCampoZY6, _cNomeGnc})
                
                ElseIf AllTrim(ZAE->(FieldName(_nJ))) == "ZAE_MSBLQL"   
                   _cBloq := _oModelDet:GetValue("ZAE_MSBLQL")
                   
                   _cCampoZY6 := "ZY6->ZY6_NSUI"
                   Aadd(_aDet,{_cCampoZY6, _cBloq})
                
                Else   // Demais campos.
                
                   _cCampoZY6 := "ZY6->ZY6"+AllTrim(SubStr(ZAE->(FieldName(_nJ)),4,10))
                   Aadd(_aDet,{_cCampoZY6, _oModelDet:GetValue(ZAE->(FieldName(_nJ)))}) 
                   
                EndIf
                
             EndIf
          Next
          
          //_cCodV  := _oModelCapa:GetValue("ZAE_VEND")
          //_cNomeV := _oModelCapa:GetValue("ZAE_NOME")
          //_cNomeProd := Posicione('SB1',1,xFilial('SB1')+_cCodProd,'B1_NOME')
           
          _nK := Ascan(_aVersao, {|x| x[1] == xFilial("ZAE") .And. x[2] == _cCodV .And. x[3] == _cItem .And. x[4] == _cCodProd})
            
          If _nK > 0
             _nVersao := _aVersao[_nK,5]            
          Else
             _nVersao := 0
          EndIf
            
          _nVersao := U_AFIN004S(xFilial("ZAE") , _cCodV, _cItem, _cCodProd, _nVersao)
          _cVersao := StrZero(_nVersao,2)
          
          If _nK > 0
             _aVersao[_nK,5] := _nVersao
          Else
             Aadd(_aVersao,{ xFilial("ZAE") , _cCodV, _cItem , _cCodProd, _nVersao}) 
          EndIf
          
          _cExcluido := "Excluido"
          _cMsg := "Exclus�o total das regras do representante."
          
          Aadd(_aDet,{"ZY6->ZY6_FILIAL" , xFilial("ZAE")})     // 'Filial'
          Aadd(_aDet,{"ZY6->ZY6_VEND"   , _cCodV})             // 'Cod. Vend.'	
          Aadd(_aDet,{"ZY6->ZY6_NOME"   , _cNomeV})            // 'Nome Vended.'
          
          Aadd(_aDet,{"ZY6->ZY6_DATA"   , Date()})             // 'Data Alterac'	
          Aadd(_aDet,{"ZY6->ZY6_HORA"   , Time()})             // 'Hora Alterac'
          Aadd(_aDet,{"ZY6->ZY6_USUAR"  , __cUserId})          // 'Usuario Alte'
          Aadd(_aDet,{"ZY6->ZY6_DELET"  , _cExcluido})         // 'Deletado'	// TRBZAE->DELETED
          Aadd(_aDet,{"ZY6->ZY6_VERSAO" ,  _cVersao})          // 'Versao'
          Aadd(_aDet,{"ZY6->ZY6_DSCALT" , _cMsg})              // 'Descric.Alte'	
          
          Aadd(_aDadosItem,_aDet)			
      Next
      
      //================================================================
      // Grava Log de Exclus�o de Dados na tabela ZY6.
      //================================================================
      U_AFIN004E(_nOper, _oModel)
      
   ElseIf _nOper == _nOperAlteracao
         
      ZAE->(DbSetOrder(2)) // ZAE_FILIAL+ZAE_VEND+ZAE_ITEM
      
      TRBZAE->(DbGoTop())
      Do While ! TRBZAE->(Eof())
         _lAchouZAE := .F.
         
         If ! Empty(TRBZAE->WKRECNO)
            ZAE->(DbGoTo(TRBZAE->WKRECNO))
            If ! ZAE->(Eof())
               _lAchouZAE := .T.
            ElseIf ZAE->(DbSeek(xFilial("ZAE")+TRBZAE->ZAE_VEND+TRBZAE->ZAE_ITEM) )
               _lAchouZAE := .T.
            EndIf
         EndIf
         
         _cExcluido := ""
         
         _cMsg := ""
         If TRBZAE->DELETED .And. _lAchouZAE // Registro Excluido
            _cMsg      := "Registro excluido."        
            _cExcluido := "Excluido Item"
         ElseIf _lAchouZAE // Registro alterado 
            If AllTrim(TRBZAE->ZAE_PROD) <> AllTrim(ZAE->ZAE_PROD)
               _cMsg +=" C�digo de produto(ZAE_PROD) alterado de '"+ AllTrim(ZAE->ZAE_PROD) + "' para '"+ AllTrim(TRBZAE->ZAE_PROD)+"'. "  
            EndIf
             
   	        If TRBZAE->ZAE_COMIS1 <> ZAE->ZAE_COMIS1  
   	           _cMsg +=" Percentual de comiss�o produto(ZAE_COMIS1) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMIS1,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMIS1,6,2))+"'. "  
   	        EndIf
   	        
   	        If AllTrim(TRBZAE->ZAE_GRPVEN) <> AllTrim(ZAE->ZAE_GRPVEN)  
   	           _cMsg +=" Grupo de vendas(ZAE_GRPVEN) alterado de '" + AllTrim(ZAE->ZAE_GRPVEN)+"' para '"+ AllTrim(TRBZAE->ZAE_GRPVEN) +"'. "
   	        EndIf
   	        
   	        If AllTrim(TRBZAE->ZAE_CLI) <> AllTrim(ZAE->ZAE_CLI)
   	           _cMsg +=" Codigo do cliente(ZAE_CLI) alterado de '" + AllTrim(ZAE->ZAE_CLI)+"' para '"+ AllTrim(TRBZAE->ZAE_CLI) +"'. "
   	        EndIf
   	        
            If AllTrim(TRBZAE->ZAE_LOJA) <> AllTrim(ZAE->ZAE_LOJA)
               _cMsg +=" Loja do cliente(ZAE_LOJA) alterado de '" + AllTrim(ZAE->ZAE_LOJA)+"' para '"+ AllTrim(TRBZAE->ZAE_LOJA) +"'. "
            EndIf
            
   	        If AllTrim(TRBZAE->ZAE_CODSUP) <> AllTrim(ZAE->ZAE_CODSUP)
   	           _cMsg +=" Codigo do coordenador(ZAE_CODSUP) alterado de '" + AllTrim(ZAE->ZAE_CODSUP)+"' para '"+ AllTrim(TRBZAE->ZAE_CODSUP) +"'. "
   	        EndIf
   	        
   	        If TRBZAE->ZAE_COMIS2 <> ZAE->ZAE_COMIS2
   	           _cMsg +=" Percentual de comiss�o coordenador(ZAE_COMIS2) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMIS2,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMIS2,6,2))+"'. "   
   	        EndIf
   	        
   	        If AllTrim(TRBZAE->ZAE_CODGER) <> AllTrim(ZAE->ZAE_CODGER)
   	           _cMsg +=" Codigo do gerente(ZAE_CODGER) alterado de '" + AllTrim(ZAE->ZAE_CODGER)+"' para '"+ AllTrim(TRBZAE->ZAE_CODSUP) +"'. "
   	        EndIf
   	        
   	        If TRBZAE->ZAE_COMIS3 <> ZAE->ZAE_COMIS3
   	           _cMsg +=" Percentual de comiss�o gerente(ZAE_COMIS3) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMIS3,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMIS3,6,2))+"'. "   
   	        EndIf
   	        
   	        If AllTrim(TRBZAE->ZAE_MSBLQL) <> AllTrim(ZAE->ZAE_MSBLQL)
   	           _cMsg +=" Campo de bloqueio do item(ZAE_MSBLQL) alterado de  '" + AllTrim(ZAE->ZAE_MSBLQL)+"' para '"+ AllTrim(TRBZAE->ZAE_MSBLQL) +"'. "
   	        EndIf
   	        
   	        If AllTrim(TRBZAE->ZAE_CODSUI) <> AllTrim(ZAE->ZAE_CODSUI)
   	           _cMsg +=" Codigo do supervisor(ZAE_CODSUI) alterado de '" + AllTrim(ZAE->ZAE_CODSUI)+"' para '"+ AllTrim(TRBZAE->ZAE_CODSUI) +"'. "
   	        EndIf
   	        
   	        If TRBZAE->ZAE_COMIS4 <> ZAE->ZAE_COMIS4
   	           _cMsg +=" Percentual de comiss�o Supervisor(ZAE_COMIS4) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMIS4,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMIS4,6,2))+"'. "  
            EndIf

            If TRBZAE->ZAE_COMIS5 <> ZAE->ZAE_COMIS5
   	           _cMsg +=" Percentual de comiss�o Gerente Nacional(ZAE_COMIS5) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMIS5,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMIS5,6,2))+"'. "  
            EndIf

			If TRBZAE->ZAE_COMVA1 <> ZAE->ZAE_COMVA1
   	           _cMsg +=" Percentual de comiss�o produto(ZAE_COMVA1) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMVA1,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMVA1,6,2))+"'. "  
   	        EndIf

			If TRBZAE->ZAE_COMVA2 <> ZAE->ZAE_COMVA2
   	           _cMsg +=" Percentual de comiss�o produto(ZAE_COMVA2) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMVA2,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMVA2,6,2))+"'. "  
   	        EndIf

			If TRBZAE->ZAE_COMVA3 <> ZAE->ZAE_COMVA3
   	           _cMsg +=" Percentual de comiss�o produto(ZAE_COMVA3) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMVA3,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMVA3,6,2))+"'. "  
   	        EndIf
			   
			If TRBZAE->ZAE_COMVA4 <> ZAE->ZAE_COMVA4
   	           _cMsg +=" Percentual de comiss�o produto(ZAE_COMVA4) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMVA4,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMVA4,6,2))+"'. "  
   	        EndIf

			If TRBZAE->ZAE_COMVA5 <> ZAE->ZAE_COMVA5
   	           _cMsg +=" Percentual de comiss�o varejo, Gerente Nacional, produto(ZAE_COMVA5) alterado de '"+ AllTrim(Str(ZAE->ZAE_COMVA5,6,2)) + "' para '"+ AllTrim(Str(TRBZAE->ZAE_COMVA5,6,2))+"'. "  
   	        EndIf   
         
            _cExcluido := "Alterado"
         
         ElseIf ! _lAchouZAE // Registro Incluido
            _cMsg := "Registro Inclu�do."
            
            _cExcluido := "Inclu�do"
         EndIf
         
         If ! Empty( _cMsg)
            _cNomeV := _cNomeVend // _oModelCapa:GetValue("ZAE_NOME")
           
            _nK := Ascan(_aVersao, {|x| x[1] == TRBZAE->ZAE_FILIAL .And. x[2] == TRBZAE->ZAE_VEND .And. x[3] == TRBZAE->ZAE_ITEM .And. x[4] == TRBZAE->ZAE_PROD})
            
            If _nK > 0
               _nVersao := _aVersao[_nK,5]            
            Else
               _nVersao := 0
            EndIf
            
            _nVersao := U_AFIN004S(TRBZAE->ZAE_FILIAL, TRBZAE->ZAE_VEND, TRBZAE->ZAE_ITEM, TRBZAE->ZAE_PROD,_nVersao)
            _cVersao := StrZero(_nVersao,2)

            If _nK > 0
               _aVersao[_nK,5] := _nVersao
            Else
               Aadd(_aVersao,{TRBZAE->ZAE_FILIAL, TRBZAE->ZAE_VEND, TRBZAE->ZAE_ITEM, TRBZAE->ZAE_PROD, _nVersao}) 
            EndIf
            
            _aDet := {}
            Aadd(_aDet,{"ZY6->ZY6_FILIAL" , TRBZAE->ZAE_FILIAL}) // 'Filial'
            Aadd(_aDet,{"ZY6->ZY6_ITEM"   , TRBZAE->ZAE_ITEM})   // 'Item'	
            Aadd(_aDet,{"ZY6->ZY6_VEND"   , TRBZAE->ZAE_VEND})   // 'Cod. Vend.'	
            Aadd(_aDet,{"ZY6->ZY6_NOME"   , _cNomeV})            // 'Nome Vended.'
            Aadd(_aDet,{"ZY6->ZY6_PROD"   , TRBZAE->ZAE_PROD})   // 'Produto'
            Aadd(_aDet,{"ZY6->ZY6_NPROD"  , TRBZAE->WK_NPROD})   // 'Nome Produto' 
            Aadd(_aDet,{"ZY6->ZY6_DATA"   , Date()})             // 'Data Alterac'	
            Aadd(_aDet,{"ZY6->ZY6_HORA"   , Time()})             // 'Hora Alterac'
            Aadd(_aDet,{"ZY6->ZY6_USUAR"  , __cUserId})          // 'Usuario Alte'
            Aadd(_aDet,{"ZY6->ZY6_DELET"  , _cExcluido})         // 'Deletado'	// TRBZAE->DELETED
            Aadd(_aDet,{"ZY6->ZY6_VERSAO" ,  _cVersao})          // 'Versao'
            Aadd(_aDet,{"ZY6->ZY6_DSCALT" , _cMsg})              // 'Descric.Alte'				
            Aadd(_aDet,{"ZY6->ZY6_COMIS1" , TRBZAE->ZAE_COMIS1}) // 'Comis. Prod'
            Aadd(_aDet,{"ZY6->ZY6_COMVA1" , TRBZAE->ZAE_COMVA1}) // 'Comis. Prod'
            Aadd(_aDet,{"ZY6->ZY6_GRPVEN" , TRBZAE->ZAE_GRPVEN}) // 'Rede'
            Aadd(_aDet,{"ZY6->ZY6_CLI"    , TRBZAE->ZAE_CLI})    // 'Cliente' 
            Aadd(_aDet,{"ZY6->ZY6_CODSUP" , TRBZAE->ZAE_CODSUP}) // 'Cod Coord'	
            Aadd(_aDet,{"ZY6->ZY6_NSUP"   , TRBZAE->WK_NSUP})    // 'Nomed Coord.'
            Aadd(_aDet,{"ZY6->ZY6_COMIS2" , TRBZAE->ZAE_COMIS2}) // 'Comis. Coord'
            Aadd(_aDet,{"ZY6->ZY6_COMVA2" , TRBZAE->ZAE_COMVA2}) // 'Comis. Coord'
            Aadd(_aDet,{"ZY6->ZY6_CODGER" , TRBZAE->ZAE_CODGER}) // 'Cod. Gerente'
            Aadd(_aDet,{"ZY6->ZY6_NGEREN" , TRBZAE->WK_NGEREN})  // 'Nome Gerente' 
            Aadd(_aDet,{"ZY6->ZY6_COMIS3" , TRBZAE->ZAE_COMIS3}) // 'Comissao Ger'
            Aadd(_aDet,{"ZY6->ZY6_COMVA3" , TRBZAE->ZAE_COMVA3}) // 'Comissao Ger'
            Aadd(_aDet,{"ZY6->ZY6_MSBLQL" , TRBZAE->ZAE_MSBLQL}) // 'Bloqueado?'	
            Aadd(_aDet,{"ZY6->ZY6_CODSUI" , TRBZAE->ZAE_CODSUI}) // 'Cod Superv'
            Aadd(_aDet,{"ZY6->ZY6_NSUI"   , TRBZAE->WK_NSUI})    // 'Nome Superv'
            Aadd(_aDet,{"ZY6->ZY6_COMIS4" , TRBZAE->ZAE_COMIS4}) // 'Comissao Sup'
            Aadd(_aDet,{"ZY6->ZY6_COMVA4" , TRBZAE->ZAE_COMVA4}) // 'Comissao Sup'

			Aadd(_aDet,{"ZY6->ZY6_CODGNC" , TRBZAE->ZAE_CODGNC}) // 'Cod Gerente Nacional'
            Aadd(_aDet,{"ZY6->ZY6_NGERNC" , TRBZAE->WK_NGNC})    // 'Nome Grente Nacional'
            Aadd(_aDet,{"ZY6->ZY6_COMIS5" , TRBZAE->ZAE_COMIS5}) // 'Comissao Gerente Nacioanal'
            Aadd(_aDet,{"ZY6->ZY6_COMVA5" , TRBZAE->ZAE_COMVA5}) // 'Comissao Varejo Gerente Naiconal'
            
            Aadd(_aDadosItem,_aDet)        
         EndIf
                 
         TRBZAE->(DbSkip())
      EndDo
   EndIf

End Sequence

RestOrd(_aOrd)
ZAE->(DbGoTo(_nRegZAE))

Return _lRet

/*
===============================================================================================================================
Programa----------: AFIN004S
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/11/2018
===============================================================================================================================
Descri��o---------: Retorna o proximo numero sequencial do campo vers�o, relacionado a vers�o de altera��o.
===============================================================================================================================
Parametros--------: _cFilZY6  := C�digo da filial
                    _cVend    := C�digo do vendedor
                    _cItem    := numero do item
                    _cProd    := C�digo do produto
                    _nVersion := numero da ultima vers�o.
=============================================================================================================================
Retorno-----------: _nRet = numero da pr�xima vers�o dispon�vel.
===============================================================================================================================
*/
User Function AFIN004S(_cFilZY6, _cVend, _cItem, _cProd,_nVersion)
Local _nRet
Local _aOrd := SaveOrd({"ZY6"}) 
Local _nRegAtu := ZY6->(Recno())
Local _nSeq

Begin Sequence
   ZY6->(DbSetOrder(4)) // ZY6_FILIAL+ZY6_VEND+ZY6_ITEM+ZY6_PROD+ZY6_VERSAO
   
   _nSeq := 0
   ZY6->(DbSeek(_cFilZY6 + _cVend + _cItem + _cProd))
   Do While ! ZY6->(Eof()) .And. ZY6->(ZY6_FILIAL+ZY6_VEND+ZY6_ITEM+ZY6_PROD) == _cFilZY6 + _cVend + _cItem + _cProd
      If Val(ZY6->ZY6_VERSAO) > _nSeq  
         _nSeq := Val(ZY6->ZY6_VERSAO)  
      EndIf
      
      ZY6->(DbSkip())
   EndDo
   
   If _nVersion > _nSeq
      _nSeq := _nVersion 
   EndIf
   
   _nRet := _nSeq + 1 
   
End Sequence

RestOrd(_aOrd)
ZY6->(DbGoTo(_nRegAtu))

Return _nRet

/*
===============================================================================================================================
Programa----------: AFIN004E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/11/2018
===============================================================================================================================
Descri��o---------: Gravar os Arrays contendo as informa��es de log de altera��es na tabela ZY6.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet = .T. = Deve sempre retornar true pois esta rotina � de grava��o e n�o de valida��o.
===============================================================================================================================
*/
User Function AFIN004E(_nOper, _oModel)
Local _lRet := .T.
Local _nI, _nJ
Local _aDados

Begin Sequence
   If Empty(_aDadosItem)
      Break // N�o existem dados para grava��o.
   EndIf

   If (_nOper == _nOperInclusao) .Or. (_nOper ==  _nOperExclusao)
         
         For _nI := 1 To Len(_aDadosItem)
             _aDados := _aDadosItem[_nI]
             
             ZY6->(RecLock("ZY6",.T.))

             For _nJ := 1 To Len(_aDadosCapa)
                 &(_aDadosCapa[_nJ,1]) := _aDadosCapa[_nJ,2]
             Next
             
             For _nJ := 1 To Len(_aDados)
                 &(_aDados[_nJ,1]) := _aDados[_nJ,2]
             Next 
             
             ZY6->ZY6_VEND := M->ZAE_VEND
             
             ZY6->(MsUnLock())
         Next

   ElseIf _nOper == _nOperAlteracao
      Begin Transaction
         For _nI := 1 To Len(_aDadosItem)
             _aDados := _aDadosItem[_nI]
             ZY6->(RecLock("ZY6",.T.))
             For _nJ := 1 To Len(_aDados)
                 &(_aDados[_nJ,1]) := _aDados[_nJ,2]
             Next
             
             ZY6->ZY6_VEND := _cCodVend 
      
             ZY6->(MsUnLock())
         Next
      End Transaction

   EndIf

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AF004HIST
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/11/2018
===============================================================================================================================
Descri��o---------: Exibir o hist�rico de altera��es das regras de comiss�es.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AF004HIST()
Local _aOrd := SaveOrd({"ZY6"})
Local _nRegAtu := ZY6->(Recno())
Local _aHeader, _aDados
Local _cCodVend  := Space(Len(ZAE->ZAE_VEND))
Local _cNomeVend := U_ITKEY(" ","ZAE_NOME")
//Local _cNomeExcVend := Space(Len(ZAE->ZAE_VEND))

Local _oDlgHist
Local _lRet := .T.
Local _aDadosExcl
Local _nTamChav := Len(ZAE->ZAE_VEND)
Local _nMaxSelecao := 1
Local _cTitulo

Private _oTipoVisual, _cTipoVisual  := "A"
Private _aItalac_F3  := {}
Private _cCodExcVend := Space(Len(ZY6->ZY6_DELET))

Begin Sequence
   //======================================================
   // Tela para sele��o do hist�rico a ser exibido.
   //======================================================
   _bOk     := {|| _lRet := .T., _oDlgHist:End()} 
   _bCancel := {|| _lRet := .F., _oDlgHist:End()}
   
   _cCodVend  := ZAE->ZAE_VEND
   _cNomeVend := Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_VEND,'A3_NOME')     
   
   _aDadosExcl := U_AF004EHIST()
   
                  //        1              2             3               4               5                           6                                               7             8            9      10  11  12
   Aadd(_aItalac_F3,{"_cCodExcVend",/*_cTabela*/ ,/*_nCpoChave*/ , /*_nCpoDesc*/ , /*_bCondTab*/ , "Lista de Representantes Excluidos e Contidos no Hist�rico" , _nTamChav , _aDadosExcl, _nMaxSelecao,   ,   ,   })
   
   _cTitulo := "Tela de Sele��o do Representante a Ter Hist�rico Exibido"
   
   DEFINE MSDIALOG _oDlgHist TITLE _cTitulo FROM 0,0 TO  20, 80 OF oMainWnd // PIXEL
		            
      @ 35, 010 Say "Representante Atual:" Pixel Size 100,010  Of _oDlgHist 
      @ 35, 110 MSGet _cCodVend  Pixel Size 060,009 When .F. Of _oDlgHist

      @ 55, 010 Say "Nome Repres.Atual:" Pixel Size 100,010 Of _oDlgHist 
      @ 55, 110 MSGet _cNomeVend Pixel Size 120,009 When .F. Of _oDlgHist

      @ 75, 010 Say "Representante Excluido:" Pixel Size 100,010 Of _oDlgHist  
      @ 75, 110 MSGet _cCodExcVend F3 "F3ITLC" Pixel Size 040,009 Of _oDlgHist

      //@ 25+_nLinha, 240 Say "Nome Repres.Excluido:"	Pixel Size 018,006 Of _oDlgHist
      //@ 35+_nLinha, 240 MSGet _cFiltroLoja Valid(Vazio() .Or. ExistCpo("SA1",_cFiltroCliente+_cFiltroLoja)) Pixel Size 030,009 Of _oDlgHist
            
      @ 95, 010 Say "Visualizar Representante?"	Pixel Size 100,010 Of _oDlgHist 
      @ 95, 110 MSCOMBOBOX _oTipoVisual Var _cTipoVisual ITEMS {"A=Atual","E=Excluido"} Valid (Pertence('AE')) Pixel Size 060, 020 Of _oDlgHist
	  		
   ACTIVATE MSDIALOG _oDlgHist ON INIT EnchoiceBar(_oDlgHist, _bOk, _bCancel) CENTERED 

   If ! _lRet
      //U_ITMSG("Visualiza��o do hist�rico cancelado pelo usu�rio.","Aten��o", ,1)  
      Break
   EndIf

   If _cTipoVisual == "E" .And. Empty(_cCodExcVend)
      U_ITMSG("Foi Solicitado a Visualiza��o de um hist�rico de um representante exclu�do, por�m, o c�digo do representente excluido n�o foi informado. Rotina de hist�rico cancelada.","Aten��o", ,1)  
      Break
   ElseIf _cTipoVisual == "E"
      _cCodVend := _cCodExcVend   
   EndIf
   
   If Empty(_cCodVend)
      U_ITMSG("O C�digo do representante n�o foi informado. Rotina de hist�rico cancelada.","Aten��o", ,1)  
      Break
   EndIf
   
   ZY6->(DbSetOrder(4)) // ZY6_FILIAL+ZY6_VEND+ZY6_ITEM+ZAE_PROD+ZY6_VERSAO
   
   If ! ZY6->(DbSeek(xFilial("ZY6")+_cCodVend)) // ZY6->(DbSeek(xFilial("ZY6")+ZAE->ZAE_VEND))
      U_ITMSG("N�o existem dados de hist�rico a serem exibidos.","Aten��o", ,1)  
      Break
   EndIf 
   
   _aHeader := {'Item',;	
                'Cod. Vend.',;	
                'Nome Vended.',;
                'Produto',;
                'Nome Produto',; 
                'Data Alterac',;	
                'Hora Alterac',;
                'Usuario Alte',;
                'Deletado',;
                'Versao',;
                'Descric.Alte',;				
                'Comis. Prod',;
				'Comiss Exc1',;
                'Rede',;
                'Cliente',; 
                'Cod Coord',;	
                'Nomed Coord.',;
                'Comis. Coord',;
				'Comiss Exc1',;
                'Cod. Gerente',;
                'Nome Gerente',; 
                'Comissao Ger',;
				'Comiss Exc1',;
                'Bloqueado?',;	
                'Cod Superv',;
                'Nome Superv',;
                'Comissao Sup',;
				'Comiss Exc1',;
				'Cod Ger Nac',;
                'Nome Ger Nac',;
                'Comissao Ger Nac',;
				'Comis Var Ger Nac'}

   _aDados := {}
   
   Do While ! ZY6->(Eof()) .And. ZY6->(ZY6_FILIAL+ZY6_VEND) == xFilial("ZY6")+_cCodVend // ZAE->ZAE_VEND
      
      Aadd(_aDados,{ZY6->ZY6_ITEM,;      // 'Item'	         1
                    ZY6->ZY6_VEND,;      // 'Cod. Vend.'	 2
                    ZY6->ZY6_NOME,;      // 'Nome Vended.'   3
                    ZY6->ZY6_PROD,;      // 'Produto'        4
                    ZY6->ZY6_NPROD,;     // 'Nome Produto'   5
                    ZY6->ZY6_DATA,;      // 'Data Alterac'	 6 
                    ZY6->ZY6_HORA,;      // 'Hora Alterac'   7 
                    ZY6->ZY6_USUAR,;     // 'Usuario Alte'
                    ZY6->ZY6_DELET,;     // 'Deletado'	// TRBZAE->DELETED
                    ZY6->ZY6_VERSAO,;    // 'Versao'
                    ZY6->ZY6_DSCALT,;    // 'Descric.Alte'				
                    ZY6->ZY6_COMIS1,;    // 'Comis. Prod'
					ZY6->ZY6_COMVA1,;
                    ZY6->ZY6_GRPVEN,;    // 'Rede'
                    ZY6->ZY6_CLI,;       // 'Cliente' 
                    ZY6->ZY6_CODSUP,;    // 'Cod Coord'	
                    ZY6->ZY6_NSUP,;      // 'Nomed Coord.'
                    ZY6->ZY6_COMIS2,;    // 'Comis. Coord'
					ZY6->ZY6_COMVA2,;
                    ZY6->ZY6_CODGER,;    // 'Cod. Gerente'
                    ZY6->ZY6_NGEREN,;    // 'Nome Gerente' 
                    ZY6->ZY6_COMIS3,;    // 'Comissao Ger'
					ZY6->ZY6_COMVA3,;
                    ZY6->ZY6_MSBLQL,;    // 'Bloqueado?'	
                    ZY6->ZY6_CODSUI,;    // 'Cod Superv'
                    ZY6->ZY6_NSUI,;      // 'Nome Superv'
                    ZY6->ZY6_COMIS4,;	 // 'Comissao Sup'
					ZY6->ZY6_COMVA4,;    // 'Comissao Var Sup'    
                    ZY6->ZY6_CODGNC,;    // 'Cod Ger.Nac'
                    ZY6->ZY6_NGERNC,;    // 'Nome Ger.Nac'
                    ZY6->ZY6_COMIS5,;	 // 'Comissao Ger Nac'
					ZY6->ZY6_COMVA5})    // 'Comis.Var.Ger Nac' 
      ZY6->(DbSkip())  
   EndDo
   
   ASort(_aDados, , , { | x,y | x[2]+DTOS(x[6])+x[7]+x[4] < y[2]+DTOS(y[6])+y[7]+y[4] }) 
   
   If ! Empty(_aDados)
      U_ITListBox( 'Hist�rico de Altera��es no Cadastro de Regras de Comiss�es' ,_aheader , _adados , .T. , 1 )
   Else
      U_ITMSG("N�o existem dados de hist�rico a serem exibidos.","Aten��o", ,1)  
      Break
   EndIf

End Sequence

RestOrd(_aOrd)
ZY6->(DbGoto(_nRegAtu))
 
Return Nil

/*
===============================================================================================================================
Programa----------: AF004EHIST
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/11/2018
===============================================================================================================================
Descri��o---------: Montar um array com c�digo e nome dos representantes que foram excluidos e est�o gravados no hist�rico.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AF004EHIST()
Local _aRet := {}
Local _cQry := ""
Local _cDado := ""

Begin Sequence
   _cQry := " SELECT DISTINCT ZY6_VEND, ZY6_NOME "
   _cQry += " FROM "+ RetSqlName('ZY6') +" ZY6 "
   _cQry += " WHERE "
   _cQry += " ZY6.D_E_L_E_T_ = ' ' AND ZY6.ZY6_DELET = 'Excluido            ' "
   _cQry += " ORDER BY ZY6_VEND "
	
   If Select("ZY6F3") > 0
      ZY6F3->( DBCloseArea() )
   EndIf
		
   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "ZY6F3" , .T. , .F. )
   
   If ZY6F3->(Eof()) .Or. ZY6F3->(Bof())
      _cDado := Space(6) + "-" + U_ITKEY(" ", "ZY6_NOME")
      Aadd(_aRet, _cDado)
      Break
   EndIf
   
   Do While ! ZY6F3->(Eof())
      _cDado := ZY6F3->ZY6_VEND + "-" + U_ITKEY(ZY6F3->ZY6_NOME, "ZY6_NOME")
      Aadd(_aRet, _cDado)
      
      ZY6F3->(DbSkip())
   EndDo

End Sequence

If Select("ZY6F3") > 0
   ZY6F3->( DBCloseArea() )
EndIf

Return _aRet

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>///

/*
=================================================================================================================================
Programa--------: AFIN0042()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 19/09/2017
=================================================================================================================================
Descri��o-------: Rotina de c�pia e manuten��o das regras de comiss�o para multiplos vendedores.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AFIN0042()

Local _aStrucZAE
Local _aButtons := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _oDlgCpy, _nI
Local _cCmpVirtuais
Local _cCamposTela
Local _lOk := .F.
Local _nLinha := 22

Private aHeader := {}
Private _aAltera := {}
Private _oGetDBCpy
Private _cCodVend, _cNomeVend, _cVendDest := Space(100)
Private _aTipoAtua := {"Somente Existentes","Toda Regra"}
Private _cTipoAtua := "", _nTotRegs

Begin Sequence
   //================================================================================
   // Inclui bot�es adicionais
   //================================================================================
   //AADD(_aButtons,{"Copiar Regras de Comiss�o",{|| U_AFIN0043(.F.) },"Copiar Regras de Comiss�o","Copiar Regras de Comiss�o"}) 
   //AADD(_aButtons,{"Atualizar",{|| U_AFIN004U(.F.) },"Atualizar","Atualizar"}) 
   
   //================================================================================
   // Codigo do vendedor posicionado no Mbrowse
   //================================================================================
   _cCodVend  := ZAE->ZAE_VEND 
   _cNomeVend := Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_VEND,'A3_NOME')
   
   _cTipoAtua := _aTipoAtua[1]

   //================================================================================
   // Monta as colunas do MSGETDB para a tabela tempor�ria TRBZAECPY 
   //================================================================================
   _cCamposTela := "ZAE_FILIAL,ZAE_ITEM,ZAE_PROD,ZAE_NPROD,ZAE_COMIS1,ZAE_GRPVEN,ZAE_CLI,ZAE_LOJA,ZAE_NCLI,ZAE_CODSUI,ZAE_NSUI,"
   _cCamposTela += "ZAE_COMIS4,ZAE_CODSUP,ZAE_NSUP,ZAE_COMIS2,ZAE_CODGER,ZAE_NGEREN,ZAE_COMIS3,ZAE_MSBLQL,ZAE_VEND,ZAE_CODGNC,ZAE_NGERNC,ZAE_COMIS5,ZAE_COMVA5"
   _aStrucZAE   := {}
   
   _cCmpVirtuais := "ZAE_NOME  /ZAE_NPROD /ZAE_NCLI  /ZAE_NSUP  /ZAE_NGEREN/ZAE_NSUI / ZAE_NGERNC /"
   
   //================================================================================
   // Cria as estruturas das tabelas tempor�rias
   //================================================================================
   
   	Aadd(_aStrucZAE, {"ZAE_FILIAL","C" ,2  ,0})
   	Aadd(_aStrucZAE, {"ZAE_ITEM"  ,"C" ,3  ,0})
   	Aadd(_aStrucZAE, {"ZAE_VEND"  ,"C" ,6  ,0})
   	Aadd(_aStrucZAE, {"ZAE_PROD"  ,"C" ,15 ,0})
   	Aadd(_aStrucZAE, {"WK_NPROD"  ,"C" ,100,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS1","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA1","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"ZAE_GRPVEN","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"ZAE_CLI"   ,"C" ,6  ,0})
   	Aadd(_aStrucZAE, {"ZAE_LOJA"  ,"C" ,4  ,0})
   	Aadd(_aStrucZAE, {"WK_NCLI"   ,"C" ,60 ,0})
   	Aadd(_aStrucZAE, {"ZAE_CODSUP","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NSUP"   ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS2","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA2","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"ZAE_CODGER","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NGEREN" ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS3","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA3","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"ZAE_MSBLQL","C" ,1  ,0})
   	Aadd(_aStrucZAE, {"ZAE_CODSUI","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NSUI"   ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS4","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA4","N" ,7  ,3})
    Aadd(_aStrucZAE, {"ZAE_CODGNC","C" ,6  ,0})
   	Aadd(_aStrucZAE, {"WK_NGNC"   ,"C" ,40 ,0})
   	Aadd(_aStrucZAE, {"ZAE_COMIS5","N" ,7  ,3})
   	Aadd(_aStrucZAE, {"ZAE_COMVA5","N" ,7  ,3})

   	Aadd(_aStrucZAE, {"WKGRUPO"   ,"C" ,04 ,0}) // C�digo do Grupo de Produtos.
   	Aadd(_aStrucZAE, {"WK_BIMIX" , "C" ,02 ,0}) // C�digo do Mix BI.
   	Aadd(_aStrucZAE, {"WKRECNO"   ,"N" ,10 ,0})
   	Aadd(_aStrucZAE, {"DELETED"   ,"L" ,1  ,0})
   
    Aadd(aHeader,   {" Item"       ,"ZAE_ITEM"    ,"@!        ",3  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Produto"     ,"ZAE_PROD"    ,"@!        ",15 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Produto","WK_NPROD"    ,"@!        ",100,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comis. Prod" ,"ZAE_COMIS1"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Vend","ZAE_COMVA1"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})

    Aadd(aHeader,   {"Rede"        ,"ZAE_GRPVEN"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Cliente"     ,"ZAE_CLI"     ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Loja"        ,"ZAE_LOJA"    ,"@!        ",4  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome"        ,"WK_NCLI"     ,"@!        ",60 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Cod Coord"   ,"ZAE_CODSUP"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nomed Coord.","WK_NSUP"     ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comis. Coord","ZAE_COMIS2"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Cord","ZAE_COMVA2"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})

    Aadd(aHeader,   {"Cod. Gerente","ZAE_CODGER"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Gerente","WK_NGEREN"   ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comissao Ger","ZAE_COMIS3"  ,"@E 999.999" ,6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Gere","ZAE_COMVA3"  ,"@E 999.999" ,6  ,2," "," ","N"," "," "})

    Aadd(aHeader,   {"Bloqueado?"  ,"ZAE_MSBLQL"  ," "         ,1  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Cod Superv"  ,"ZAE_CODSUI"  ,"@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Superv" ,"WK_NSUI"     ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comissao Sup","ZAE_COMIS4"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Sup" ,"ZAE_COMVA4"  ,"@E 999.999 ",6  ,2," "," ","N"," "," "})
//===========================================================================================
    Aadd(aHeader,   {"Cod Ger.Nac."    ,"ZAE_CODGNC","@!        ",6  ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Nome Ger.Nac."   ,"WK_NGNC"   ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"Comissao Ger.Nac","ZAE_COMIS5","@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Con.Var.Ger.Nac" ,"ZAE_COMVA5","@E 999.999 ",6  ,2," "," ","N"," "," "})
    Aadd(aHeader,   {"Grupo"           ,"WKGRUPO"   ,"@!        ",40 ,0," "," ","C"," "," "})
    Aadd(aHeader,   {"MIX BI"          ,"WK_BIMIX"  ,"@!        ",25 ,0," "," ","C"," "," "})
//===========================================================================================
   _cCmpVirtuais += "WKRECNO/WK_NPROD/WK_NCLI/WK_NSUI/WK_NSUP/WK_NGEREN/DELETED/WKGRUPO/WK_NGNC/WK_BIMIX"
         
   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZAECPY") > 0
      TRBZAECPY->( DBCloseArea() )
   EndIf
   
   //================================================================================
   // Abre o arquivo TRBZAECPY criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZAECPY",  _aStrucZAE )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZAE_PROD","ZAE_CLI","ZAE_LOJA"} )
   _otemp:AddIndex( "02", {"ZAE_VEND","ZAE_PROD","ZAE_GRPVEN","ZAE_CLI","ZAE_LOJA"} )
   _otemp:AddIndex( "03", {"ZAE_VEND","ZAE_PROD","ZAE_GRPVEN"} )          
   _otemp:AddIndex( "04", {"ZAE_VEND","ZAE_PROD","ZAE_CLI"} )             
   _otemp:AddIndex( "05", {"ZAE_VEND","ZAE_PROD","ZAE_CLI","ZAE_LOJA"} )  
   _otemp:AddIndex( "06", {"ZAE_VEND","ZAE_PROD"} )                       

   _otemp:Create()
        
   //================================================================================
   // Array com os campos que poder�o ser alterados.
   //================================================================================    
                                                                                 
   Aadd(_aAltera,"ZAE_COMIS1")
   Aadd(_aAltera,"ZAE_COMIS2")
   Aadd(_aAltera,"ZAE_COMIS3")
   Aadd(_aAltera,"ZAE_COMIS4")
   Aadd(_aAltera,"ZAE_COMIS5")
   Aadd(_aAltera,"ZAE_COMVA1")
   Aadd(_aAltera,"ZAE_COMVA2")
   Aadd(_aAltera,"ZAE_COMVA3")
   Aadd(_aAltera,"ZAE_COMVA4")
   Aadd(_aAltera,"ZAE_COMVA5")

   Aadd(_aAltera,"ZAE_GRPVEN")
   Aadd(_aAltera,"ZAE_CLI")
   Aadd(_aAltera,"ZAE_LOJA")
   
   //================================================================================
   // Carrega os dados da tabela ZAE
   //================================================================================
   ZAE->(DbSetOrder(1)) // ZAE_FILIAL+ZAE_VEND+ZAE_PROD+ZAE_CLI+ZAE_LOJA 
   ZAE->(DbSeek(xFilial("ZAE")+_cCodVend))
   
   _nTotRegs := 0

   Do While ! ZAE->(Eof()) .And. ZAE->(ZAE_FILIAL+ZAE_VEND) == xFilial("ZAE")+_cCodVend
      
      TRBZAECPY->(RecLock("TRBZAECPY",.T.))
      For _nI := 1 To TRBZAECPY->(FCount())
          If AllTrim(TRBZAECPY->(FieldName(_nI))) $ _cCmpVirtuais //"ZAE_NOME"
             Loop
          EndIf

          &("TRBZAECPY->"+TRBZAECPY->(FieldName(_nI))) :=  &("ZAE->"+TRBZAECPY->(FieldName(_nI)))   
      Next
      
      TRBZAECPY->WKRECNO   := ZAE->(Recno())
      TRBZAECPY->WK_NPROD  := AllTrim(Posicione('SB1',1,xFilial('SB1')+ZAE->ZAE_PROD,'B1_DESC'))
      TRBZAECPY->WKGRUPO   := SB1->B1_GRUPO  
      TRBZAECPY->WK_BIMIX  := SB1->B1_I_BIMIX
      TRBZAECPY->WK_NCLI   := AllTrim(U_AFIN004F(ZAE->ZAE_GRPVEN,ZAE->ZAE_CLI,ZAE->ZAE_LOJA))                          

      TRBZAECPY->WK_NSUP   := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODSUP,'A3_NOME'))
      TRBZAECPY->WK_NSUI   := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODSUI,'A3_NOME'))
      TRBZAECPY->WK_NGEREN := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODGER,'A3_NOME'))
	  TRBZAECPY->WK_NGNC   := AllTrim(Posicione('SA3',1,xFilial('SA3')+ZAE->ZAE_CODGNC,'A3_NOME'))
      
      TRBZAECPY->(MsUnlock())
      
      _nTotRegs += 1

      ZAE->(DbSkip())
   EndDo

���TRBZAECPY->(DbGoTop())

   _bOk     := {|| _lOk := .T., _oDlgCpy:End()}
   _bCancel := {|| _lOk := .F., _oDlgCpy:End()}

  // _aItalac_F3:={}         //        1              2                3               4               5                    6                  7    8  9  10  11  12
  // Aadd(_aItalac_F3,{"_cMIXBI",/*_cTabela*/ ,/*_nCpoChave*/ , /*_nCpoDesc*/ , /*_bCondTab*/ , "Lista de MIX BI" , LEN(SB1->B1_I_BIMIX) , _aBoxMix, ,   ,   ,   ,  })
                       
   _cTitulo := "Regras de Comiss�o - Copia das Regras para Multiplos Representantes"
   _nTam := 12
   
   Define MsDialog _oDlgCpy Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
      
      @ 25+_nLinha, 06 Say "Cod. Vend."	Pixel Size 099,006  Of _oDlgCpy
      @ 35+_nLinha, 06 MSGet _cCodVend When .F. Pixel Size 030,_nTam Of _oDlgCpy
      
      @ 25+_nLinha, 55 Say "Nome Vended."	Pixel Size 099,006  Of _oDlgCpy
      @ 35+_nLinha, 55 MSGet _cNomeVend When .F. Pixel Size 150,_nTam Of _oDlgCpy
      
      @ 25+_nLinha, 220 Say "Vendedor(es) de Destino:"	Pixel Size 100,006  Of _oDlgCpy
      @ 35+_nLinha, 220 MSGet _cVendDest F3 "LSTVEN" Pixel Size 100,_nTam Of _oDlgCpy

      @ 25+_nLinha, 340 Say "Tipo de Atualiza��o:"	Pixel Size 100,006 Of _oDlgCpy
      @ 35+_nLinha, 340 MSCOMBOBOX _oTipoAtua Var _cTipoAtua ITEMS _aTipoAtua Pixel Size 080, 15 Of _oDlgCpy

      @ 35+_nLinha, 450 Button 'Copiar Regras de Comiss�o' Size 90, 14 Message 'Copiar Regras de Comiss�es para os Representates Informados.' Pixel Action U_AFIN0043(_cVendDest) of _oDlgCpy

      //         MsGetDB():New ( < nTop>, < nLeft>, < nBottom>, < nRight>   , < nOpc>, [ cLinhaOk]    , [ cTudoOk]    , [ cIniCpos]  , [ lDelete], [ aAlter], [ nFreeze], [ lEmpty], [ uPar1], < cTRB> , [ cFieldOk]    , [ uPar2], [ lAppend], [ oWnd], [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] )
      _oGetDBCpy := MsGetDB():New(_aSizeAut[7]+60+_nLinha, 05, _aSizeAut[4],_aSizeAut[3], 3     , /*"U_AFIN004O"//"U_LINHAOK"*/, /*"U_TUDOOK"*/, /*"+A1_COD"*/, .T.       , _aAltera , 1         , .F.      ,         , "TRBZAECPY", /*"U_FIELDOK"*/,         , .F.       , _oDlgCpy, .T., ,/*"U_DELOK"*/, /*"U_SUPERDEL"*/)
      _oGetDBCpy:oBrowse:bAdd  := {||.F.} // n�o inclui novos itens MsGetDb()  
      
   Activate MsDialog _oDlgCpy On Init EnchoiceBar(_oDlgCpy,_bOk,_bCancel,,_aButtons) 

 /*  
   //================================================================================
   // Grava��o dos dados alterados.
   //================================================================================                    
   If _lOk
      TRBZAECPY->(DbClearFilter())   
      //=====================================================================================
      // Verifica quais altera��es foram realizadas e grava estas informa��es em Arrays
      // para serem gravadas nas tabelas de hist�ricos de altera��es.                              
      //=====================================================================================
      U_AFIN004A(_nOperAlteracao) 
      
      TRBZAECPY->(DbGoTop())
      Do While ! TRBZAECPY->(Eof())
         //===========================================================================================
         // C�digo de produto em branco na tabela tempor�ria, indica que houve tentativa de inclus�o 
         // de dados. Nesta rotina n�o � permitido.
         //===========================================================================================
         If Empty(TRBZAECPY->ZAE_PROD) 
            TRBZAECPY->(DbSkip())
            Loop
         EndIf
                  
         //================================================================================
         // Verifica e realiza a exclus�o de registros.
         //================================================================================                    
         If TRBZAECPY->DELETED   //  TRBZAECPY->(Deleted())
            If TRBZAECPY->WKRECNO > 0
               ZAE->(DbGoTo(TRBZAECPY->WKRECNO))  
               ZAE->(RecLock("ZAE",.F.))
               ZAE->(DbDelete())
               ZAE->(MsUnLock())
            EndIf
            
            TRBZAECPY->(DbSkip())
            Loop
         EndIf
         
         //================================================================================
         // Grava os registros alterados.
         //================================================================================                    
         //Verifica se n�o tem registro duplicado
         _lachou := .F.
         _nrecno := TRBZAECPY->WKRECNO
         If Empty(TRBZAECPY->WKRECNO)
         
         	ZAE->(Dbsetorder(4))
         	If ZAE->(Dbseek(TRBZAECPY->ZAE_FILIAL+_cCodVend+TRBZAECPY->ZAE_PROD+TRBZAECPY->ZAE_GRPVEN+TRBZAECPY->ZAE_CLI+TRBZAECPY->ZAE_LOJA))
         		
         		_lachou := .T.
         		_nrecno := ZAE->(Recno())
         		
         	Endif
         	
         Endif
         	
         If Empty(TRBZAECPY->WKRECNO) .and. !_lachou
            ZAE->(RecLock("ZAE",.T.))
            ZAE->ZAE_FILIAL := TRBZAECPY->ZAE_FILIAL
            ZAE->ZAE_ITEM   := TRBZAECPY->ZAE_ITEM 
            ZAE->ZAE_VEND   := _cCodVend  // TRBZAECPY->ZAE_VEND
            ZAE->ZAE_PROD   := TRBZAECPY->ZAE_PROD
            ZAE->ZAE_MSBLQL := TRBZAECPY->ZAE_MSBLQL
         Else       
            ZAE->(DbGoTo(_nrecno))
            ZAE->(RecLock("ZAE",.F.))
         EndIf
         ZAE->ZAE_CODSUP := TRBZAECPY->ZAE_CODSUP 
         ZAE->ZAE_CODGER := TRBZAECPY->ZAE_CODGER
         ZAE->ZAE_CODSUI := TRBZAECPY->ZAE_CODSUI
		 ZAE->ZAE_CODGNC := TRBZAECPY->ZAE_CODGNC

         ZAE->ZAE_COMIS1 := TRBZAECPY->ZAE_COMIS1
         ZAE->ZAE_COMIS2 := TRBZAECPY->ZAE_COMIS2
         ZAE->ZAE_COMIS3 := TRBZAECPY->ZAE_COMIS3
         ZAE->ZAE_COMIS4 := TRBZAECPY->ZAE_COMIS4
		 ZAE->ZAE_COMIS5 := TRBZAECPY->ZAE_COMIS5

         ZAE->ZAE_COMVA1 := TRBZAECPY->ZAE_COMVA1
         ZAE->ZAE_COMVA2 := TRBZAECPY->ZAE_COMVA2
         ZAE->ZAE_COMVA3 := TRBZAECPY->ZAE_COMVA3
         ZAE->ZAE_COMVA4 := TRBZAECPY->ZAE_COMVA4
		 ZAE->ZAE_COMVA5 := TRBZAECPY->ZAE_COMVA5

         ZAE->ZAE_GRPVEN := TRBZAECPY->ZAE_GRPVEN
         ZAE->ZAE_CLI    := TRBZAECPY->ZAE_CLI
         ZAE->ZAE_LOJA   := TRBZAECPY->ZAE_LOJA
         ZAE->(MsUnLock())
         
         TRBZAECPY->(DbSkip())
      EndDo
      
      //=======================================================================================
      // Grava os dados de altera��es contidos nos arrays na tabela de Hist�rico de Altera��es   
      //=======================================================================================
      U_AFIN004E(_nOperAlteracao) 
   
   EndIf
*/

End Sequence

//================================================================================
// Fecha e exclui as tabelas tempor�rias
//================================================================================                    
If Select("TRBZAECPY") > 0
   TRBZAECPY->(DbCloseArea())
   _otemp:Delete()
EndIf

Return Nil

/*
=================================================================================================================================
Programa--------: AFIN0043()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 26/05/2022
=================================================================================================================================
Descri��o-------: Rotina de efetiva��o da c�pia das regras de comiss�o exibidas na tela para os Vendedores informados.
=================================================================================================================================
Parametros------: _cVendCpy = Vendedores a serem copiadas as regras de comiss�o.
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AFIN0043(_cVendCpy)
Local _aVends     := {}
Local _aRepresen  := {}
Local _cRepresen  := ""
Local _aVendErro  := {}, _nI 
Local _aVenErLst  := {}
Local _cVendErro  := ""
Local _aVendDiver := {}
Local _nTamVends 

Begin Sequence 
   
   If Empty(_cVendCpy)
      U_ITMSG("Para copiar as regras de comiss�o � preciso informar um vendedor de destino.","Aten��o", "Informe pelo menos um vendedor de destino para utilizar esta rotina." ,1)  
      Break
   EndIf 

   _cVendCpy  := AllTrim(_cVendCpy)
   _nTamVends := Len(_cVendCpy)

   If _nTamVends > 0 .And. SubStr(_cVendCpy,_nTamVends,1) <> ";"
      _cVendCpy += ";"
   EndIf 

   _aVends := U_ITTXTARRAY(_cVendCpy,";",50)

   //=============================================================
   // Obtem dados de amarra��o Gerente x Coordenador x Supervisor
   //=============================================================   
   SA3->(DbSetOrder(1))
   SA3->(MsSeek(xFilial("SA3")+TRBZAECPY->ZAE_VEND))
   _cCodCoord  := SA3->A3_SUPER    // Coordenador
   _cCodGeren  := SA3->A3_GEREN    // Gerente
   _cDodSuper  := SA3->A3_I_SUPE   // Supervisor 
   _cCodGerNc  := SA3->A3_I_GERNC  // Gerente Nacional 
       
   For _nI := 1 To Len(_aVends)
       If AllTrim(TRBZAECPY->ZAE_VEND) == AllTrim(_aVends[_nI]) .Or. Empty(_aVends[_nI])
          Loop // O vendedor de origem da c�pia das regras n�o pode fazer parte da lista de vendedores de destino da c�pia.
	   EndIf 

       If SA3->(MsSeek(xFilial("SA3")+_aVends[_nI]))
          If AllTrim(_cCodCoord)  <> AllTrim(SA3->A3_SUPER) .Or. ;
		     AllTrim(_cCodGeren)  <> AllTrim(SA3->A3_GEREN)  .Or. ; 
			 AllTrim(_cDodSuper)  <> AllTrim(SA3->A3_I_SUPE) .Or. ;
			 AllTrim(_cCodGerNc)  <> AllTrim(SA3->A3_I_GERNC)
             Aadd(_aVendDiver,{SA3->A3_COD,AllTrim(SA3->A3_NOME)})
          Else 
             Aadd(_aRepresen,{AllTrim(_aVends[_nI]), AllTrim(SA3->A3_NOME)})   // Vendedores localizados no cadastro de vendedores.
		  EndIf 
	   Else 
          Aadd(_aVendErro,AllTrim(_aVends[_nI])) // Vendedores n�o localizados no cadastr do vendedores.
		  Aadd(_aVenErLst,{AllTrim(_aVends[_nI])})
       EndIf 
   Next 

   If Len(_aVendErro) > 0 
      _cVendErro := ""
      For _nI := 1 To Len(_aVendErro)
          _cVendErro += AllTrim(_aVendErro[_nI]) + "; "
	  Next 

      _aCab := {"Codigo"}   
      U_ITListBox( "Vendedores n�o Localizados no Cadastro" , _aCab , _aVenErLst) 

      If ! U_ItMsg("Os vendedores a seguir n�o foram localizados no cadastro de vendedores: " + _cVendErro + " Deseja prosseguir com a c�pia das regras de comiss�es? ","Aten��o",,2,2,2)
         Break
	  EndIf 
   EndIf 
   
   If Len(_aVendDiver) > 0 
      _aCab := {"Codigo", "Nome"}   
      U_ITListBox("Vendedores Com Divergencia na Amarra��o Supervisor x Coordenador x Gerente x Gerente Nacional" , _aCab , _aVendDiver) 
   EndIf 

   If Len(_aRepresen) == 0 
      U_ITMSG("N�o foi informado nenhum representante v�lido para atualiza��o das regras de comiss�es.","Aten��o", "Para utilizar esta rotina, informe representantes cadastrados no cadastro de vendedores." ,1)  
      Break
   EndIf 
 
   _cRepresen := ""
   For _nI := 1 To Len(_aRepresen)
       _cRepresen += AllTrim(_aRepresen[_nI,1]) + "-" + AllTrim(_aRepresen[_nI,2]) + "; "
   Next 

   _aCab := {"Codigo", "Nome"}   
   U_ITListBox("Representantes Validos para Atualiza��o das Regras de Comiss�es" , _aCab , _aRepresen) 

   If ! U_ItMsg("Confirma a c�pia das regras de comiss�es para os representantes: " + _cRepresen + " ? ","Aten��o",,2,2,2)
      Break
   EndIf 

   For _nI := 1 To Len(_aRepresen)
       Processa( {|| U_AFIN0044(_aRepresen[_nI] ) } , "Atualizado Regras Comiss�es Representante: "+_aRepresen[_nI,1]+"-"+_aRepresen[_nI,2] , "Atualizando Regras de comiss�es para os Representante: " +_aRepresen[_nI,1]+"-"+_aRepresen[_nI,2], .F. )
   Next 

End Sequence 

Return Nil 

/*
=================================================================================================================================
Programa--------: AFIN0044()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 26/05/2022
=================================================================================================================================
Descri��o-------: Rotina de grava��o das copias das regras de comiss�es para os representantes de destino.
=================================================================================================================================
Parametros------: _aVendCpy = _aVendCpy[1] = Codigo do Vendedor de destino das regras de comiss�o.
                              _aVendCpy[2] = Nome do Vendedor de destino das regras de comiss�o.
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AFIN0044(_aVendCpy)
Local _cCodVend, _cNomeVend 
Local _lInclui , _nI

Begin Sequence
   
   _cCodVend  := _aVendCpy[1]
   _cNomeVend := _aVendCpy[2]

   ProcRegua(_nTotRegs)

   //ZAE->(DbSetOrder(1)) // ZAE_FILIAL+ZAE_VEND+ZAE_PROD+ZAE_CLI+ZAE_LOJA

   ZAE->(DbSetOrder(4)) // ZAE_FILIAL+ZAE_VEND+ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA

   _nI := 1

   TRBZAECPY->(DbGoTop())
   Do While ! TRBZAECPY->(Eof())
      
	  IncProc("Atualizando dados: " + StrZero(_nI,6) + " de " + StrZero(_nTotRegs,6) + ".")   
	  _nI += 1

	  _lInclui := .F.

      If _cTipoAtua == _aTipoAtua[1] // {"Somente Existentes","Toda Regra"}
	     //==========================================================================================
		 // Atualiza apenas as regras j� existentes. Que forem encontradas na pesquisa.
		 //==========================================================================================
	     If ! ZAE->(MsSeek(xFilial("ZAE")+U_ITKEY(_cCodVend,"ZAE_VEND")+TRBZAECPY->(ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA)))
            TRBZAECPY->(DbSkip())
			Loop
         EndIf
         
         ZAE->(RecLock("ZAE",.F.))
      Else 
         //===========================================================================================
		 // Atualiza toda Regra. As que existirem s�o alteradas. As que n�o existirem s�o incluidas.
		 //===========================================================================================
	     If ! ZAE->(MsSeek(xFilial("ZAE")+U_ITKEY(_cCodVend,"ZAE_VEND")+TRBZAECPY->(ZAE_PROD+ZAE_GRPVEN+ZAE_CLI+ZAE_LOJA)))
            ZAE->(RecLock("ZAE",.T.)) // Inclui uma nova regra
			_lInclui := .T.
		 Else 
		    ZAE->(RecLock("ZAE",.F.)) // Altera uma regra existente
         EndIf
	  EndIf
      
	  If _lInclui
         ZAE->ZAE_FILIAL := TRBZAECPY->ZAE_FILIAL
         ZAE->ZAE_ITEM   := TRBZAECPY->ZAE_ITEM 
         ZAE->ZAE_VEND   := _cCodVend  // TRBZAECPY->ZAE_VEND
         ZAE->ZAE_PROD   := TRBZAECPY->ZAE_PROD
         ZAE->ZAE_MSBLQL := TRBZAECPY->ZAE_MSBLQL
      EndIf

      ZAE->ZAE_CODSUP := TRBZAECPY->ZAE_CODSUP 
      ZAE->ZAE_CODGER := TRBZAECPY->ZAE_CODGER
      ZAE->ZAE_CODSUI := TRBZAECPY->ZAE_CODSUI
	  ZAE->ZAE_CODGNC := TRBZAECPY->ZAE_CODGNC

      ZAE->ZAE_COMIS1 := TRBZAECPY->ZAE_COMIS1
      ZAE->ZAE_COMIS2 := TRBZAECPY->ZAE_COMIS2
      ZAE->ZAE_COMIS3 := TRBZAECPY->ZAE_COMIS3
      ZAE->ZAE_COMIS4 := TRBZAECPY->ZAE_COMIS4
	  ZAE->ZAE_COMIS5 := TRBZAECPY->ZAE_COMIS5

      ZAE->ZAE_COMVA1 := TRBZAECPY->ZAE_COMVA1
      ZAE->ZAE_COMVA2 := TRBZAECPY->ZAE_COMVA2
      ZAE->ZAE_COMVA3 := TRBZAECPY->ZAE_COMVA3
      ZAE->ZAE_COMVA4 := TRBZAECPY->ZAE_COMVA4
	  ZAE->ZAE_COMVA5 := TRBZAECPY->ZAE_COMVA5

      ZAE->ZAE_GRPVEN := TRBZAECPY->ZAE_GRPVEN
      ZAE->ZAE_CLI    := TRBZAECPY->ZAE_CLI
      ZAE->ZAE_LOJA   := TRBZAECPY->ZAE_LOJA
      ZAE->(MsUnLock())
         
      TRBZAECPY->(DbSkip())
   EndDo

   TRBZAECPY->(DbGoTop())

End Sequence 

Return Nil


/*
===============================================================================================================================
Programa----------: AFIN4FIL
Autor-------------: Igor Melga�o
Data da Criacao---: 27/09/2024
===============================================================================================================================
Descri��o---------: Filtro na consulta padrao de produto 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet - Indica se o Produto ser� exibido na consulta padr�o
===============================================================================================================================
*/
User Function AFIN4FIL()
Local _lRet    := .T.
Local _cProds  := ""
   
   If __LAFIN004
      _cProds := AFIN4FPRO()
      If !Empty(_cProds)
         If SB1->B1_COD $ _cProds
            _lRet := .F.
         Else
            _lRet := .T.
         EndIf
      Else
         _lRet := .T.
      EndIf
   EndIf

Return(_lRet)

/*
===============================================================================================================================
Programa----------: AFIN4FPRO
Autor-------------: Igor Melga�o
Data da Criacao---: 01/10/2024
===============================================================================================================================
Descri��o---------: Retorna a lista de produtos j� selecionados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cProds
===============================================================================================================================
*/
Static Function AFIN4FPRO(_lRotinaMVC,_oModDet)
Local _nLinhas := 0
loCAL _nI      := 0
Local _cProds  := ""
Local lBuscaTemp:= .F.
 
Default _lRotinaMVC := .F.
Default _oModDet    := Nil

   If __LAFIN004
      If _lRotinaMVC .AND. Valtype(_oModDet) <> "U"
         _nLinhas := _oModDet:Length()
         If _nLinhas > 1 
            For _nI := 1 to _nLinhas
               _oModDet:GoLine(_nI)
               If !(_oModDet:IsDeleted())
                  _cProds += Iif(Empty(Alltrim(_cProds)),"",";") + _oModDet:GetValue('ZAE_PROD')
               EndIf
            Next
         Else
            lBuscaTemp := .T.
         EndIf
      Else
         lBuscaTemp := .T.
      EndIf

      If lBuscaTemp .AND. SELECT("TRBZAE") > 0 
         TRBZAE->(DbGoTop())
         Do While TRBZAE->(!EOF())
            If !TRBZAE->DELETED
               _cProds += Iif(Empty(Alltrim(_cProds)),"",";") + TRBZAE->ZAE_PROD
            EndIf
            TRBZAE->(DbSkip())
         EndDo
      EndIf
   EndIf

Return(_cProds)
