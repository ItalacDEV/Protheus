/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaco      | 11/01/2023 | Chamado 42331. Mudan�a layout e exclus�o de compensa��o.
Igor Melga�o      | 11/07/2023 | Chamado 44438. Ajustes para Reintegra��o quando o Status for N�o Integrado.
Igor Melga�o      | 08/12/2023 | Chamado 45694. Ajustes para configura��o da n�o integra��o do t�tulo no financeiro e integra��o por lote.
Igor Melga�o      | 24/04/2024 | Chamado 46970. Ajustes para corre��o de processo de reintegra��o.
Igor Melga�o      | 31/05/2024 | Chamado 47373. Ajustes para corre��o de query.
====================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Altera��o
----------------------------------------------------------------------------------------------------------------------------------------------------
Ant�nio Ramos    - Igor Melga�o      - 03/07/2027 -            - 51062   - Ajustes para valida��o do Fornecedor e da Filial posicionada antes da integra��o.
====================================================================================================================================================
*/

#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
===============================================================================================================================
Programa----------: AFIN031
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2021
===============================================================================================================================
Descri��o---------: Monitor Paytrack. Chamado: 42331 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AFIN031()
Local _oBrowse := Nil As Object

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z29")
_oBrowse:SetMenuDef( 'AFIN031' )
_oBrowse:SetDescription("Monitor Paytrack")
_oBrowse:AddLegend( "Z29_STATUS=='I'", "GREEN"      ,"Integrado")
_oBrowse:AddLegend( "Z29_STATUS=='N'", "BLACK"      ,"Nao Integrado")
_oBrowse:AddLegend( "Z29_STATUS=='E'", "RED"        ,"Excluido")
_oBrowse:AddLegend( "Z29_STATUS=='R'", "ORANGE"      ,"Reintegrado")

_oBrowse:Activate()

/*
S�o poss�veis as seguintes cores:

GREEN  � Para a cor Verde
RED    � Para a cor Vermelha
YELLOW � Para a cor Amarela
ORANGE � Para a cor Laranja
BLUE   � Para a cor Azul
GRAY   � Para a cor Cinza
BROWN  � Para a cor Marrom
BLACK  � Para a cor Preta
PINK   � Para a cor Rosa
WHITE  � Para a cor Branca
*/
Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de defini��o autom�tica do menu via MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef() As Array
Local _aRotina	:= {} As Array

ADD OPTION _aRotina Title 'Integrar'                    Action 'U_AFIN031G()'		OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Reintegrar'                  Action 'U_AFIN031R()'		OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Excluir Integracao'          Action 'U_AFIN031I("E")'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Visualizar'	                Action 'VIEWDEF.AFIN031'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Visualizar Financeiro'       Action 'U_AFIN031F()'		OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Parametros'                  Action 'U_AFIN032()'		OPERATION 3 ACCESS 0

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/ 
Static Function ModelDef() As Object
Local _oStruZ29 := FWFormStruct(1,"Z29") As Object
Local _oStruZ26 := FWFormStruct(1,"Z26") As Object
Local _oStruZ27 := FWFormStruct(1,"Z27") As Object
Local _oStruZ28 := FWFormStruct(1,"Z28") As Object
Local _oStruCZ26 := FWFormStruct(1,"Z26") As Object
Local _oStruCZ27 := FWFormStruct(1,"Z27") As Object
Local _oStruCZ28 := FWFormStruct(1,"Z28") As Object

Local _oModel As Object
Local _aZ26Rel := {} As Array
Local _aZ27Rel := {} As Array
Local _aZ28Rel := {} As Array

Local _aCZ26Rel := {} As Array
Local _aCZ27Rel := {} As Array
Local _aCZ28Rel := {} As Array

_oStruZ26:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'Z26_LEGEND' , ;            // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || AFIN031L() } , ;       // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .T. )                       // [14] L Indica se o campo � virtual 

_oStruCZ26:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'Z26_LEGEND' , ;            // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || AFIN031L() } , ;       // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .T. )                       // [14] L Indica se o campo � virtual 

_oModel := MPFormModel():New('AFIN031M' ,  /*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCommit*/ , /*bCancel*/)

_oModel:AddFields('Z29CAB', /*cOwner*/ ,_oStruZ29,/*bPreValidacao*/ , /*_bPosValidacao*/ , /*bCarga*/)
_oModel:AddGrid('Z29DETAIL','Z29CAB'   ,_oStruZ29,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)

_oModel:AddGrid('Z26DETAIL','Z29DETAIL',_oStruZ26,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('Z27DETAIL','Z26DETAIL',_oStruZ27,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('Z28DETAIL','Z26DETAIL',_oStruZ28,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)

_oModel:AddGrid('CZ26DETAIL','Z29DETAIL' ,_oStruCZ26,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('CZ27DETAIL','CZ26DETAIL',_oStruCZ27,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('CZ28DETAIL','CZ26DETAIL',_oStruCZ28,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)

aAdd(_aZ26Rel, {'Z26_FILIAL', 'Z29CAB.Z29_FILIAL'} )
aAdd(_aZ26Rel, {'Z26_NUM'   , 'Z29CAB.Z29_NUM'})
aAdd(_aZ26Rel, {'Z26_PREFIX', 'Z29CAB.Z29_PREFIX'})

aAdd(_aZ27Rel, {'Z27_IDINTE', 'Z26DETAIL.Z26_IDINTE'} )
aAdd(_aZ28Rel, {'Z28_IDINTE', 'Z26DETAIL.Z26_IDINTE'} )

aAdd(_aCZ26Rel, {'Z26_FILIAL', 'Z29CAB.Z29_FILIAL'} )
aAdd(_aCZ26Rel, {'Z26_NUM'   , 'Z29CAB.Z29_NUM'})
aAdd(_aCZ26Rel, {'Z26_PREORI', 'Z29CAB.Z29_PREFIX'})

aAdd(_aCZ27Rel, {'Z27_IDINTE', 'CZ26DETAIL.Z26_IDINTE'} )
aAdd(_aCZ28Rel, {'Z28_IDINTE', 'CZ26DETAIL.Z26_IDINTE'} )

_oModel:SetRelation('Z26DETAIL', _aZ26Rel, Z26->(IndexKey(1)))
_oModel:SetRelation('Z27DETAIL', _aZ27Rel, Z27->(IndexKey(1)))
_oModel:SetRelation('Z28DETAIL', _aZ28Rel, Z28->(IndexKey(1)))

_oModel:SetRelation('CZ26DETAIL', _aCZ26Rel, Z26->(IndexKey(1)))
_oModel:SetRelation('CZ27DETAIL', _aCZ27Rel, Z27->(IndexKey(1)))
_oModel:SetRelation('CZ28DETAIL', _aCZ28Rel, Z28->(IndexKey(1)))

_oModel:SetPrimaryKey( {'Z29_FILIAL','Z29_PREFIX','Z29_NUM','Z29_PARCEL','Z29_TIPO','Z29_FORNEC','Z29_LOJA' } )
_oModel:SetDescription("Modelo de Dados Monitor Paytrack")

Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oStruZ29 := FWFormStruct(2,"Z29") As Object
Local _oStruZ26 := FWFormStruct(2,"Z26") As Object
Local _oStruZ27 := FWFormStruct(2,"Z27") As Object
Local _oStruZ28 := FWFormStruct(2,"Z28") As Object
Local _oStruCZ26 := FWFormStruct(2,"Z26") As Object
Local _oStruCZ27 := FWFormStruct(2,"Z27") As Object
Local _oStruCZ28 := FWFormStruct(2,"Z28") As Object
Local _oModel := FWLoadModel("AFIN031") As Object
Local _oView := Nil As Object

    _oStruZ26:RemoveField('Z26_PREORI')
    _oStruCZ26:RemoveField('Z26_PREORI')

    //_oStruZ26:RemoveField('Z26_EXCLUI')
    //_oStruCZ26:RemoveField('Z26_EXCLUI')

    _oStruZ26:AddField( ;                       // Ord. Tipo Desc.
        'Z26_LEGEND'                    , ;     // [01] C   Nome do Campo
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
 
    _oStruCZ26:AddField( ;                       // Ord. Tipo Desc.
        'Z26_LEGEND'                    , ;     // [01] C   Nome do Campo
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
_oView:AddField("VIEW_Z29",_oStruZ29,"Z29CAB"   ,,)
_oView:AddGrid('VIEW_Z26' ,_oStruZ26,'Z26DETAIL',,)
_oView:AddGrid('VIEW_Z27' ,_oStruZ27,'Z27DETAIL',,)
_oView:AddGrid('VIEW_Z28' ,_oStruZ28,'Z28DETAIL',,)

_oView:AddGrid('VIEW_CZ26' ,_oStruCZ26,'CZ26DETAIL',,)
_oView:AddGrid('VIEW_CZ27' ,_oStruCZ27,'CZ27DETAIL',,)
_oView:AddGrid('VIEW_CZ28' ,_oStruCZ28,'CZ28DETAIL',,)


//Setando o dimensionamento de tamanho
_oView:CreateHorizontalBox('CABEC',30)
_oView:CreateHorizontalBox('DETAIL',70)

_oView:CreateFolder('FOLDER1','DETAIL')

_oView:AddSheet('FOLDER1','SHEET1','Adiantamentos ou Reembolsos')
_oView:AddSheet('FOLDER1','SHEET2','Compensacoes')

_oView:CreateHorizontalBox('S1_BOX1',50,,,'FOLDER1','SHEET1')
_oView:CreateHorizontalBox('S1_BOX2',50,,,'FOLDER1','SHEET1')

_oView:CreateHorizontalBox('S2_BOX1',50,,,'FOLDER1','SHEET2')
_oView:CreateHorizontalBox('S2_BOX2',50,,,'FOLDER1','SHEET2')

_oView:CreateVerticalBox('S1_BOX2_V1',50,'S1_BOX2',,'FOLDER1','SHEET1')
_oView:CreateVerticalBox('S1_BOX2_V2',50,'S1_BOX2',,'FOLDER1','SHEET1')

_oView:CreateVerticalBox('S2_BOX2_V1',50,'S2_BOX2',,'FOLDER1','SHEET2')
_oView:CreateVerticalBox('S2_BOX2_V2',50,'S2_BOX2',,'FOLDER1','SHEET2')

//Amarrando a view com as box
_oView:SetOwnerView('VIEW_Z29','CABEC')
_oView:SetOwnerView('VIEW_Z26','S1_BOX1')
_oView:SetOwnerView('VIEW_Z27','S1_BOX2_V1')
_oView:SetOwnerView('VIEW_Z28','S1_BOX2_V2')

_oView:SetOwnerView('VIEW_CZ26','S2_BOX1')
_oView:SetOwnerView('VIEW_CZ27','S2_BOX2_V1')
_oView:SetOwnerView('VIEW_CZ28','S2_BOX2_V2')

//Habilitando t�tulo
_oView:EnableTitleView('VIEW_Z29','Dados de Integra��o')

_oView:EnableTitleView('VIEW_Z26','Registros de Payload')
_oView:EnableTitleView('VIEW_Z27','Rateio por Natureza')
_oView:EnableTitleView('VIEW_Z28','Rateio por Centro de Custo')

_oView:EnableTitleView('VIEW_CZ26','Registros de Payload')
_oView:EnableTitleView('VIEW_CZ27','Rateio por Natureza')
_oView:EnableTitleView('VIEW_CZ28','Rateio por Centro de Custo')

_oView:SetViewProperty("VIEW_Z26", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_Z26", "GRIDFILTER", {.F.}) 

_oView:SetViewProperty("VIEW_Z27", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_Z27", "GRIDFILTER", {.F.}) 

_oView:SetViewProperty("VIEW_Z28", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_Z28", "GRIDFILTER", {.F.}) 

_oView:SetViewProperty("VIEW_CZ26", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_CZ26", "GRIDFILTER", {.F.}) 

_oView:SetViewProperty("VIEW_CZ27", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_CZ27", "GRIDFILTER", {.F.}) 

_oView:SetViewProperty("VIEW_CZ28", "GRIDSEEK", {.F.})
_oView:SetViewProperty("VIEW_CZ28", "GRIDFILTER", {.F.}) 

//_oView:AddUserButton( 'Excluir T�tulo da Guia Compensa��es', 'CLIPS', {|_oView| AFIN031X(_oView)} )
_oView:AddUserButton( 'Excluir T�tulos das Compensa��es', 'CLIPS', {|_oView| U_AFIN033(Z29->Z29_FILIAL+"CVI"+Z29->Z29_NUM)} )

//_oModel:GetValue('Z29_FILIAL') + _oModel:GetValue('Z29_PREFIX') + _oModel:GetValue('Z29_NUM') 
//Tratativa padr�o para fechar a tela
_oView:SetCloseOnOk({||.T.})

Return _oView

/*
===============================================================================================================================
Programa----------: AFIN031F
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de Visualiza��o de Titulo a Pagar
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
User Function AFIN031F()
Local _nRecnoSE2 := 0 As Numeric
Local _cErro := "N�o encontrado o Titulo no Contas a Pagar." As Character

    DbSelectArea("SE2")
    DbSetOrder(1)
    If DBSeek(Z29->Z29_FILIAL+Z29->Z29_PREFIX+Z29->Z29_NUM+Z29->Z29_PARCEL+Z29->Z29_TIPO+Z29->Z29_FORNEC+Z29->Z29_LOJA)
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
Programa----------: AFIN031I
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Realiza de Integra��o
===============================================================================================================================
Parametros--------: _cOper - Opera��o I - Inclus�o E - Exclus�o
===============================================================================================================================
Retorno-----------: _lReturn => Confirma��o de Execu��o
===============================================================================================================================
*/ 
User Function AFIN031I(_cOper As Character) As Logical
Local _lContinua := .F. As Logical
Local _cErro     := "" As Character
Local _lRest     := .F. As Logical
Local _cJson     := "" As Character

_cJson := Z26->Z26_PAYLOA
_lContinua := U_MFIN021I(Z26->Z26_PAYLOA,@_cErro,_lRest,@_cJson,_cOper)

If !_lContinua
    U_ITMSG(_cErro,"Aten��o","",3 , , , .T.)
EndIf

Return _lContinua

/*
===============================================================================================================================
Programa----------: AFIN031G
Autor-------------: Igor Melga�o
Data da Criacao---: 07/12/2023
===============================================================================================================================
Descri��o---------: Realiza de Integra��o em lote
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/ 
User Function AFIN031G(oProc As Object)
Local _aParAux := {} As Array
Local _aParRet := {} As Array
Local _bOK       := {|| AFIN031VPA() } As CodeBlock
Local nA := 0 As Numeric
Local _cTitAux := "Integra��o Paytrack" As Character

MV_PAR01 := U_MFIN021VEN(dDatabase)
_aTipos:={"1-Reembolso de Viagem Italac","2-Adiantamento de Viagem Italac"}
AADD( _aParAux , { 1 , "Data de Pagamento", MV_PAR01, "@D", "", ""	, "" , 050 , .F.  })
AADD( _aParAux , { 2 , "Tipo"            , MV_PAR02,_aTipos, 120   ,".T.",.T. ,".T."}) 

For nA := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nA][03] )
Next
                         //aParametros, cTitle                                , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
If ParamBox( _aParAux , _cTitAux, @_aParRet, _bOK, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
   FWMSGRUN(,{|oproc|  AFIN031H(oproc) },'Aguarde processamento...','Lendo dados...')
EndIf

Return
/*
===============================================================================================================================
Programa----------: AFIN031G
Autor-------------: Igor Melga�o
Data da Criacao---: 06/12/2023
===============================================================================================================================
Descri��o---------: Rotina de Integra��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
Static Function AFIN031H(oProc) As Logical
Local _lContinua := .F. As Logical
Local _cZ29Temp := "" As Character
Local _aLog     := {} As Array
Local _aCabec   := {} As Array
Local _cErro     := "" As Character
Local _lRest     := .F. As Logical
Local _cJson     := "" As Character
Local _nTotal    := 0 As Numeric
Local _nLin      := 0 As Numeric
Local _cPrefixo  := "" As Character
Local _cNrIntegr := "" As Character
Local lBuscaComp := .F. As Logical
Local _aDadosZ29 := {} As Array
Local _nI := 0 As Numeric
Local _aButtons := {} As Array

    _cPrefixo := Iif(Subs(MV_PAR02,1,1) = "2","AVI","RVI','CVI")
    _cZ29Temp := GetNextAlias()
    
    BeginSql Alias _cZ29Temp

        SELECT Z29.R_E_C_N_O_ AS RECNOZ29, Z29_FILIAL, Z29_PREFIX, Z29_NUM, Z29_CGC, Z29_FORNEC, Z29_LOJA, Z29_NOMFOR, Z29_EMISSA, Z29_VENCTO, Z29_VALOR
        FROM	%Table:Z29% Z29
        WHERE Z29.Z29_STATUS = 'N'
            AND Z29.Z29_PREFIX IN  (%Exp:_cPrefixo%)  
            AND Z29.%NotDel%
        ORDER BY Z29_FILIAL,Z29_NUM

    EndSql

    (_cZ29Temp)->(Dbgotop())

    If (_cZ29Temp)->(!Eof())

        AADD(_aCabec,"")
        AADD(_aCabec,"Filial")
        AADD(_aCabec,"Prefixo")
        AADD(_aCabec,"Numero")
        AADD(_aCabec,"CPF/CNPJ")
        AADD(_aCabec,"Cod Fornecedor")
        AADD(_aCabec,"Loja")
        AADD(_aCabec,"Mome Fornecedor")
        AADD(_aCabec,"Emiss�o")
        AADD(_aCabec,"Vencimento")
        AADD(_aCabec,"Valor")
        AADD(_aCabec,"Recno")

        DBSelectArea("Z29")
        Do While ( (_cZ29Temp)->(!Eof()) )

            AADD(_aDadosZ29,{.F.,;
            (_cZ29Temp)->Z29_FILIAL,;
            (_cZ29Temp)->Z29_PREFIX,;
            (_cZ29Temp)->Z29_NUM,;
            (_cZ29Temp)->Z29_CGC,;
            (_cZ29Temp)->Z29_FORNEC,;
            (_cZ29Temp)->Z29_LOJA,;
            (_cZ29Temp)->Z29_NOMFOR,;
            DTOC(STOD((_cZ29Temp)->Z29_EMISSA)),;
            DTOC(STOD((_cZ29Temp)->Z29_VENCTO)),;
            ALLTRIM(Transform((_cZ29Temp)->Z29_VALOR,"@E 999,999,999,999,999.99")),;
            (_cZ29Temp)->RECNOZ29 })

            (_cZ29Temp)->(dbSkip())

        EndDo

        If Len(_aDadosZ29) > 0
            If u_ITListBox( "Processamento de Inetegra��o Paytrack" , _aCabec, @_aDadosZ29,.F.,2, 'Selecione os relatorios a integrar: '  )
                _cFilAntBkp := cFilAnt
                
                For _nI := 1 To Len(_aDadosZ29)
                    If _aDadosZ29[_nI,1]
                        Z29->(MsGoto(_aDadosZ29[_nI,12]))

                        _nLin++
                        lBuscaComp := .F.
                        cFilAnt := Z29->Z29_FILIAL
                        
                        _cNrIntegr := Z29->Z29_IDINTE
                        _cJson := ""

                        lContinua := .T.
        				//Valida Fornecedor
        				DbSelectArea("SA2")
        				DbSetOrder(1)
        				If Dbseek(xFilial("SA2")+Z29->(Z29_FORNEC+Z29_LOJA))
                            If SA2->A2_MSBLQL == '1'
                                lContinua := .F.
                                _cErro := "Cadastro do Fornecedor " + Z29->Z29_FORNEC + " Loja " + Z29->Z29_LOJA + " esta bloqueado!"
                            ElseIf !Empty(SA2->(A2_BANCO+A2_AGENCIA+A2_NUMCON)) 
                                _cErro := "Cadastro do Fornecedor " + Z29->Z29_FORNEC + " Loja " + Z29->Z29_LOJA + " n�o possui dados banc�rios preenchidos!"
                            EndIf
                        Else
                            lContinua := .F.
                            _cErro := "Fornecedor " + Z29->Z29_FORNEC + " Loja " + Z29->Z29_LOJA + " n�o encontrado no Cadastro!"
                        EndIf

                        If lContinua 
                            If Z29->Z29_PREFIX == "AVI"
                                DbSelectArea("Z26")
                                DbSetOrder(1)
                                If Z26->(DBSeek(Z29->Z29_IDINTE))
                                    If Z26->Z26_EXCLUI
                                        lBuscaComp := .T.
                                    Else
                                        lBuscaComp := .F.
                                    EndIf
                                EndIf
                                
                                If lBuscaComp .And. !Empty(Alltrim(Z29->Z29_IDCOMP)) .AND. Z26->(DBSeek(Z29->Z29_IDCOMP))
                                    If Z26->Z26_EXCLUI
                                        _cNrIntegr := Z29->Z29_IDCOMP
                                    EndIf
                                EndIf
                            EndIf

                            DbSelectArea("Z26")
                            DbSetOrder(1)
                            If Z26->(DBSeek(_cNrIntegr)) //posiciono no ultimo registro de integra��o para realizar sua inclus�o posteriormente 
                                _cJson := ""

                                //Begin Transaction

                                    If !Empty(Z26->Z26_PAYLOA)

                                        oProc:cCaption := ("Processando registro "+Alltrim(Str(_nLin))+" de "+Alltrim(Str(_nTotal))+".")
                                        ProcessMessages()
                                        
                                        _cErro := ""

                                        _lContinua := U_MFIN021I(Z26->Z26_PAYLOA,@_cErro,_lRest,@_cJson,"I")

                                        aAdd(_aLog,{_lContinua,Z29->Z29_PREFIX,Z29->Z29_NUM,Z29->Z29_EMISSA,Z29->Z29_NOMFOR,Z29->Z29_IDINTE,_cErro,_cJson})

                                    EndIf

                                //End Transaction
                            EndIf
                        Else
                            aAdd(_aLog,{_lContinua,Z29->Z29_PREFIX,Z29->Z29_NUM,Z29->Z29_EMISSA,Z29->Z29_NOMFOR,Z29->Z29_IDINTE,_cErro,_cJson})
                        EndIf
                    EndIf
                Next
                
                cFilAnt := _cFilAntBkp

                If Len(_aLog) > 0
                	_aButtons := {}
                    AADD(_aButtons,{"LEGENDA",{||  U_AFIN031Y() },"Legenda", "Legenda" }) 

                    _cTitAux := 'Log de Processamento da Integra��o'
                    _aCabec  := {"Status","Prefixo","Numero","Emissao","Fornecedor","ID Integra��o","Erro","Json" }
                    _cMsgTop := "Log de processamento"
                    
                    //ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda                      ,_lHasOk,_bHeadClk,_aSX1)
                    //U_ITListBox( _cTitAux , _aCabec  , _aLog   , .F.      , 2      , _cMsgTop ,          ,         ,         ,     ,        ,_aButtons,       ,         ,          ,           , {|C,L|U_AFIN31L2(C,L)}        , .F.   ,         ,     )
                    U_ITListBox( _cTitAux , _aCabec  , _aLog   , .T.      , 4      , _cMsgTop ,          ,         ,         ,     ,        ,_aButtons,       ,         ,          ,           , {|C,L|U_AFIN31L2(C,L)}        , .F.   ,         ,     )
 	
                EndIf
            EndIf
        Else
            U_ITMSG("N�o encontrado registros para integra��o!","Aten��o","",3 , , , .T.)
        EndIf
    Else
        U_ITMSG("N�o encontrado registros para integra��o!","Aten��o","",3 , , , .T.)
    EndIf

    (_cZ29Temp)->(DbCloseArea())

Return _lContinua

/*
===============================================================================================================================
Programa----------: AFIN031R
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina de Reintegra��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:   
===============================================================================================================================
*/ 
User Function AFIN031R() As Logical
    Local _lContinua := .F. As Logical
        
    Begin Transaction

        DbSelectArea("Z26")
        DbSetOrder(1)
        If DBSeek(Z29->Z29_IDINTE) //posiciono no ultimo registro de integra��o para realizar sua inclus�o posteriormente 
            
            _lContinua := .T.

            If Z29->Z29_STATUS == "E" .OR. Z29->Z29_STATUS == "N" 
                _lContinua := U_AFIN031I("E") //Exclus�o
            EndIf

            If _lContinua
                _lContinua := U_AFIN031I("R") //Reintegra��o
            EndIf
        Else
            U_ITMSG("N�o encontrado registro de integra��o!","Aten��o","",3 , , , .T.)
        EndIf

    End Transaction

Return _lContinua


/*
===============================================================================================================================
Programa----------: AFIN031L
Autor-------------: Igor Melga�o
Data da Criacao---: 28/12/2022
===============================================================================================================================
Descri��o---------: Rotina para reorno da cor da Legenda
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cRetorno => Cor referente a legenda
===============================================================================================================================
*/ 
Static Function AFIN031L() As Character
Local _cRetorno := "" As Character

Do Case
    Case Z26->Z26_STATUS=='I'
        _cRetorno := "BR_VERDE"
    Case Z26->Z26_STATUS=='N'
        _cRetorno := "BR_PRETO"  
    Case Z26->Z26_STATUS=='E'
        _cRetorno := "BR_VERMELHO"  
    Case Z26->Z26_STATUS=='R'
        _cRetorno := "BR_LARANJA"  
End Case

Return _cRetorno


/*
===============================================================================================================================
Programa----------: AFIN031X
Autor-------------: Igor Melga�o
Data da Criacao---: 11/01/2023
===============================================================================================================================
Descri��o---------: Exclus�o do CVI
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lReturn => Confirma��o de Execu��o
===============================================================================================================================
*/ 
Static Function AFIN031X(oView As Object)
Local _cErro      := "" As Character
Local _lReturn    := .F. As Logical
Local _aOrd       := SaveOrd({"Z26"}) As Array
Local _oModel     := FwModelActivete() As Object
Local _oModelCZ26 := _oModel:GetModel("CZ26DETAIL") As Object
Local _cIdInte    := _oModelCZ26:GetValue("Z26_IDINTE") As Character
Local _cStatus    := _oModelCZ26:GetValue("Z26_STATUS") As Character
Local _oView      := Nil As Object

If _cStatus == "I" .OR. _cStatus == "R"
    DbSelectArea("Z26")
    DbSetOrder(1)
    If DBSeek(_cIdInte)
        _lReturn := U_MFIN021I("",@_cErro,.F.,"","X")
    Else
        _lReturn := .F.
        _cErro   := "N�o encontrado o registro do CVI para exclus�o."
    EndIf
Else
    _lReturn := .F.
    If _cStatus == "N"
        _cErro   := "Registro n�o integrado. N�o � possivel concluir essa opera��o!"
    ElseIf _cStatus == "E"
        _cErro   := "Registro de exclus�o. N�o � possivel concluir essa opera��o!"
    EndIf
EndIf

If _lReturn
    _oView := FwViewActive()
    _oView:Refresh('VIEW_CZ26')

    _oModel:DeActivate()
    _oModel:Activate()
Else
    U_ITMSG(_cErro,"Aten��o","",3 , , , .T.)
EndIf

RestOrd(_aOrd)

Return _lReturn

/*
===============================================================================================================================
Programa----------: AFIN31L2
Autor-------------: Igor Melga�o
Data da Criacao---: 07/10/2023
===============================================================================================================================
Descri��o---------: Monta Legenda
===============================================================================================================================
Parametros--------: _aCol,_nLinha
===============================================================================================================================
Retorno-----------: cRet
===============================================================================================================================
*/
USER Function AFIN31L2(_aCol As Array, _nLinha As Numeric) As Object
    Local oVerm := LoadBitmap( , "BR_VERMELHO") As Object // VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO
    Local oVerd := LoadBitmap( , "BR_VERDE"   ) As Object // VERDE ESTOQUE TUDO OK .T.

    IF _aCol[_nLinha,1]
        RETURN oVerd
    ELSE
        RETURN oVerm
    ENDIF

RETURN oVerm


/*
===============================================================================================================================
Programa----------: AFIN031VPA
Autor-------------: Igor Melga�o
Data da Criacao---: 07/05/2024
===============================================================================================================================
Descri��o---------: Rotina valida��o de data de pagamento na integra��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: lRet 
===============================================================================================================================
*/ 
Static Function AFIN031VPA() As Logical
Local lRet := .T. As Logical

If MV_PAR01 < dDatabase
    U_ITMSG("Data de pagamento inv�lida!","Aten��o","Selecione uma data maior ou igual a data atual.",3 , , , .T.)
    lRet := .F.
EndIf

Return lRet

/*
===============================================================================================================================
Programa----------: AFIN031L
Autor-------------: Igor Melga�o
Data da Criacao---: 12/10/2023
===============================================================================================================================
Descri��o---------: Monta Legenda
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function AFIN031Y() As Logical

Local _aLegenda := { { "BR_VERMELHO", "Falha de Integra��o" }, ;
                     { "BR_VERDE",    "Registro Integrado" }  } As Array

BRWLEGENDA( "Integra��o de Registros do Paytrack", "Legenda", _aLegenda )

Return .T.
