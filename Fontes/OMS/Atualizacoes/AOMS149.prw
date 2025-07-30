/*
=====================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o
===============================================================================================================================
Vanderlei     - Igor Melga�o - 03/04/25 - 15/07/25 - 48781   - Monitor de Integra��o.
=====================================================================================================================================
*/

#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
===============================================================================================================================
Programa----------: AOMS149
Autor-------------: Igor Melga�o
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descri��o---------: Integra��o de Faturas TMS . Chamado: 48781
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AOMS149()
Local _oBrowse As Object

_oBrowse := Nil

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z34")
_oBrowse:SetMenuDef( 'AOMS149' )
_oBrowse:SetDescription("Monitor de Integra��o de Faturas Italac <---> TMS")
_oBrowse:AddLegend( "Z34_STATUS=='I'", "BLUE"   ,"Integrado sem Gera��o da Fatura")
_oBrowse:AddLegend( "Z34_STATUS=='N'", "BLACK"  ,"Nao Integrado")
_oBrowse:AddLegend( "Z34_STATUS=='G'", "GREEN"  ,"Ingrado com Fatura Gerada")

_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descri��o---------: Rotina de defini��o autom�tica do menu via MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef()
Local _aRotina	As Array

_aRotina	:= {}

ADD OPTION _aRotina Title 'Visualizar'	                 Action 'VIEWDEF.AOMS149'	OPERATION 2 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/ 
Static Function ModelDef()
Local _oStruZ32 As Object
Local _oStruZ33 As Object
Local _oStruZ34 As Object
Local _oModel As Object
Local _aZ32Rel As Array
Local _aZ33Rel As Array

_oStruZ32 := FWFormStruct(1,"Z32")
_oStruZ33 := FWFormStruct(1,"Z33")
_oStruZ34 := FWFormStruct(1,"Z34")
_oModel   := Nil
_aZ32Rel  := {}
_aZ33Rel  := {}

_oStruZ32:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'Z32_LEGEND' , ;            // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || AOMS149L() } , ;       // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .T. )                       // [14] L Indica se o campo � virtual 

_oModel := MPFormModel():New('AOMS149M' ,  /*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCommit*/ , /*bCancel*/)

_oModel:AddFields('Z34CAB', /*cOwner*/ ,_oStruZ34,/*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCarga*/)
_oModel:AddGrid('Z32DETAIL','Z34CAB'   ,_oStruZ32,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('Z33DETAIL','Z32DETAIL',_oStruZ33,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)

aAdd(_aZ32Rel, {'Z32_FILIAL', 'Z34CAB.Z34_FILIAL'} )
aAdd(_aZ32Rel, {'Z32_NRFAT', 'Z34CAB.Z34_NRFAT'} )

aAdd(_aZ33Rel, {'Z33_FILIAL', 'Z32DETAIL.Z32_FILIAL'} )
aAdd(_aZ33Rel, {'Z33_IDINTE', 'Z32DETAIL.Z32_IDINTE'} )

_oModel:SetRelation('Z32DETAIL', _aZ32Rel, Z32->(IndexKey(7)))
_oModel:SetRelation('Z33DETAIL', _aZ33Rel, Z33->(IndexKey(1)))

_oModel:SetPrimaryKey( {'Z34_FILIAL','Z34_NRFAT'} )
_oModel:SetDescription("Modelo de Dados Monitor de Fatura")

Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
   Local _oStruZ32 As Object
   Local _oStruZ33 As Object
   Local _oStruZ34 As Object
   Local _oModel As Object
   Local _oView As Object

   _oStruZ32 := FWFormStruct(2,"Z32")
   _oStruZ33 := FWFormStruct(2,"Z33")
   _oStruZ34 := FWFormStruct(2,"Z34")
   _oModel := FWLoadModel("AOMS149")
   _oView := Nil

   _oStruZ32:AddField( ;                       // Ord. Tipo Desc.
        'Z32_LEGEND'                    , ;     // [01] C   Nome do Campo
        "00"                            , ;     // [02] C   Ordem
        AllTrim( ''    )                , ;     // [03] C   Titulo do campo
        AllTrim( '' )                   , ;     // [04] C   Descricao do campo
        { 'Legenda' }                   , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        '@BMP'                          , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                              , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo � alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo � virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oView := FWFormView():New()
_oView:SetModel(_oModel)

// Configura as estruturas de modelo de dados
_oView:AddField("VIEW_Z34",_oStruZ34,"Z34CAB"   ,,)
_oView:AddGrid('VIEW_Z32' ,_oStruZ32,'Z32DETAIL',,)
_oView:AddGrid('VIEW_Z33' ,_oStruZ33,'Z33DETAIL',,)

//Setando o dimensionamento de tamanho
_oView:CreateHorizontalBox('CABEC',40)
_oView:CreateHorizontalBox('DETAIL1',30)
_oView:CreateHorizontalBox('DETAIL2',30)

//Amarrando a view com as box
_oView:SetOwnerView('VIEW_Z34','CABEC')
_oView:SetOwnerView('VIEW_Z32','DETAIL1')
_oView:SetOwnerView('VIEW_Z33','DETAIL2')

//Habilitando t�tulo
_oView:EnableTitleView('VIEW_Z34','Dados Principais')
_oView:EnableTitleView('VIEW_Z32','Registros de Integra��o ')
_oView:EnableTitleView('VIEW_Z33','Documentos da Fatura')

_oView:SetViewProperty("VIEW_Z32", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_Z32", "GRIDFILTER", {.F.}) 

_oView:SetViewProperty("VIEW_Z33", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_Z33", "GRIDFILTER", {.F.}) 

//Tratativa padr�o para fechar a tela
_oView:SetCloseOnOk({||.T.})

Return _oView

/*
===============================================================================================================================
Programa----------: AOMS149F
Autor-------------: Igor Melga�o
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descri��o---------: Rotina de Visualiza��o de Titulo a Pagar
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
User Function AOMS149F()
Local _nRecnoSE2 As Numeric
Local _cErro As Character

_nRecnoSE2 := 0
_cErro := "N�o encontrado o Titulo no Contas a Pagar."

   DbSelectArea("SE2")
   DbSetOrder(1)
   If DBSeek(Z32->Z32_FILIAL+Z32->Z32_PREFIX+Z32->Z32_NUM+Z32->Z32_PARCEL+Z32->Z32_TIPO+Z32->Z32_FORNEC+Z32->Z32_LOJA)
      cCadastro:= "Visualiza��o do Titulo"
      _nRecnoSE2 := SE2->(Recno())
      DBSelectArea("SE2")
      AxVisual("SE2",_nRecnoSE2,2)
   Else
      U_ITMSG(_cErro,"Aten��o","",3 , , , .T.)
   EndIf

Return 



/*
===============================================================================================================================
Programa----------: AOMS149L
Autor-------------: Igor Melga�o
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descri��o---------: Rotina para reorno da cor da Legenda
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cRetorno => Cor referente a legenda
===============================================================================================================================
*/ 
Static Function AOMS149L() As Character
Local _cRetorno As Character

_cRetorno := ""

Do Case
    Case Z32->Z32_STATUS=='I' // Integrado
        _cRetorno := "BR_AZUL"
    Case Z32->Z32_STATUS=='N' // N�o Integrado
        _cRetorno := "BR_PRETO"  
    Case Z32->Z32_STATUS=='E' // Exclu�da
        _cRetorno := "BR_VERMELHO"  
    Case Z32->Z32_STATUS=='R' // Reintegrado
        _cRetorno := "BR_LARANJA"  
    Case Z32->Z32_STATUS=='G' // 
        _cRetorno := "BR_VERDE"  
End Case

Return _cRetorno



/*
===============================================================================================================================
Programa----------: AOMS149L2
Autor-------------: Igor Melga�o
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descri��o---------: Monta Legenda
===============================================================================================================================
Parametros--------: _aCol,_nLinha
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
USER Function AOMS149L2(_aCol As Array,_nLinha As Numeric) As Object
	Local oVerm As Object
	Local oVerd As Object

	oVerm := LoadBitmap( , "BR_VERMELHO")// VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO
	oVerd := LoadBitmap( , "BR_VERDE"   )// VERDE ESTOQUE TUDO OK .T.

	IF _aCol[_nLinha,1]
		RETURN oVerd
	ELSE
		RETURN oVerm
	ENDIF

RETURN oVerm
